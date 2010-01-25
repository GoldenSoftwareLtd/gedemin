
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    gsIBCtrlGrid.pas

  Abstract

    Ordinary DBGrid with ability to insert controls inside it.

  Author

    Michael Shoihet & Romanovski Denis (11-08-98)

  Revisions history

    Initial  11-08-98  Dennis  Initial Delphi 4 version.

    beta1    12-08-98  Dennis  Beta1. Controls supported.
    
--}

unit gsIBCtrlGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  Grids, DBGrids, ExList, DB, gsDBGrid, gsIBGrid;

type
  TOnSetCtrlEvent = procedure (Sender: TObject; Ctrl: TWinControl;
    Column: TColumn; var Show: Boolean) of object;

type
  TgsIBCtrlGrid = class(TgsIBGrid)
  private
    Ctrls: TExList;
    FControlStarted: Boolean;
    ActiveCtrl: TWinControl;

    FOnSetCtrl: TOnSetCtrlEvent;

    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure CMExit(var Message: TMessage);
      message CM_EXIT;

    function GetCurrControl: TObject;

    procedure DoOnCtrlExit(Sender: TObject);
    procedure DoOnCtrlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetCurrCtrl: TWinControl;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowCtrl(Ctrl: TWinControl);
    procedure AddControl(AFieldName: String; AControl: TWinControl;
      var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
    procedure DeleteControl(AFieldName: String;
      var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
    // Установлен ли контрол
    property ControlStarted: Boolean read FControlStarted;
    // Текущий контрол
    property CurrCtrl: TWinControl read GetCurrCtrl;

  published
    // Event по активации control-а
    property OnSetCtrl: TOnSetCtrlEvent read FOnSetCtrl write FOnSetCtrl;
  end;

procedure Register;

implementation

uses DBClient;

type
  TCtrl = class
  public
    FieldName: String;
    Control: TWinControl;
    OldOnExit: TNotifyEvent;
    OldOnKeyDown: TKeyEvent;

    constructor Create(AFieldName: String; AControl: TWinControl;
      ControlOnExit: TNotifyEvent; ControlOnKeyDown: TKeyEvent);
  end;

{
   -----------------------
   ---   TCtrl Class   ---
   -----------------------
}

{
  Делает начальные установки
}

constructor TCtrl.Create(AFieldName: String; AControl: TWinControl;
  ControlOnExit: TNotifyEvent; ControlOnKeyDown: TKeyEvent);
begin
  FieldName := AFieldName;
  Control := AControl;
  OldOnExit := ControlOnExit;
  OldOnKeyDown := ControlOnKeyDown;
end;


{
  ----------------------------
  ---   TgsIBCtrlGrid Class   ---
  ----------------------------
}

{
  ***********************
  **   Private Part   ***
  ***********************
}


{
  По вводу данных при редактировании
}

procedure TgsIBCtrlGrid.WMChar(var Message: TWMChar);
var
  CurrCtrl: TCtrl;
begin
  if not (Message.CharCode in [13, 32..255]) then
  begin
    inherited;
    exit;
  end;
  
  CurrCtrl := TCtrl(GetCurrControl);

  if CurrCtrl <> nil then
  begin
    ShowCtrl(CurrCtrl.Control);
    SendMessage(CurrCtrl.Control.HANDLE, wm_Char, Message.CharCode, Message.KeyData);
  end else
    inherited;
end;

{
  По выходу из grid-а
}

procedure TgsIBCtrlGrid.CMExit(var Message: TMessage);
begin
  if not FControlStarted then inherited;
end;

{
  Дает текущий control для выбранного поля
}

function TgsIBCtrlGrid.GetCurrControl: TObject;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Ctrls.Count - 1 do
    if (SelectedField <> nil) and 
      (AnsiCompareText(SelectedField.FieldName, TCtrl(Ctrls[I]).FieldName) = 0) then
    begin
      Result := Ctrls[I];
      Break;
    end;
end;

{
  По выходу из control-а
}

procedure TgsIBCtrlGrid.DoOnCtrlExit(Sender: TObject);
var
  CurrCtrl: TCtrl;
begin
  if ActiveCtrl <> nil then
  begin
    CurrCtrl := TCtrl(GetCurrControl);
    if not Assigned(CurrCtrl) then abort;
    
    if Assigned(CurrCtrl.OldOnExit) then CurrCtrl.OldOnExit(Sender);

    ActiveCtrl.Visible := False;
    ActiveCtrl.SendToBack;
    FControlStarted := False;

    if GetParentForm(Self).Enabled and GetParentForm(Self).Visible and
      Enabled and Visible
    then
    begin
      SetFocus;
    end;
  end;
end;

{
  По нажатию клавиши в контроле
}

procedure TgsIBCtrlGrid.DoOnCtrlKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CurrCtrl: TCtrl;
  D: TDataLink;
begin
  if ActiveCtrl <> nil then
  begin
    CurrCtrl := TCtrl(GetCurrControl);
    if not Assigned(CurrCtrl) then exit;

    if Assigned(CurrCtrl.OldOnKeyDown) then CurrCtrl.OldOnKeyDown(Sender, Key, Shift);

    if (Key = vk_Escape) or (Key = vk_Return) then
    begin
      D := TDataLink(SendMessage(ActiveCtrl.Handle, CM_GETDATALINK, 0, 0));
      if Key = vk_Escape then
      begin
        if DataSource.DataSet.State in [dsEdit, dsInsert] then DataSource.DataSet.Cancel;

        if (D <> nil) and D.Active and (D.DataSource <> DataSource) and
          (D.DataSource.State in [dsEdit, dsInsert])
        then
          D.DataSet.Cancel;

        SetFocus;
        ActiveCtrl.Visible := False;
        ActiveCtrl.SendToBack;
      end else begin
        SetFocus;
        if Focused then
        begin
          ActiveCtrl.Visible := False;
          ActiveCtrl.SendToBack;
        end;
      end;
      try
        if not (DataSource.DataSet is TClientDataSet) then DataSource.DataSet.Refresh;
      except
      end;
    end;
  end;
end;

function TgsIBCtrlGrid.GetCurrCtrl: TWinControl;
begin
  if GetCurrControl <> nil then
    Result := (GetCurrControl as TCtrl).Control
  else
    Result := nil;  
end;

{
  *************************
  **   Protected Part   ***
  *************************
}

{
  По нажатию кнопки мыши
}

procedure TgsIBCtrlGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R: TGridCoord;
  CurrentControl: TCtrl;
begin
  if {(dgEditing in Options) and (}Button = mbLeft{)} then
  begin
    R := MouseCoord(X, Y);

    CurrentControl := TCtrl(GetCurrControl);
    
    if (R.Y = Row) and (R.X = Col) and (CurrentControl <> nil) then
    begin
      if CurrentControl <> nil then 
        ShowCtrl(CurrentControl.Control);
    end else
      inherited MouseDown(Button, Shift, X, Y);
  end else
    inherited MouseDown(Button, Shift, X, Y);
end;

procedure TgsIBCtrlGrid.Notification(AComponent: TComponent; Operation: TOperation);
var
  SearchCtrl: TObject;

  function SearchControl: TObject;
  var
    I: Integer;
  begin
    Result := nil;

    for I := 0 to Ctrls.Count - 1 do
      if aComponent = TCtrl(Ctrls[I]).Control then
      begin
        Result := Ctrls[I];
        Break;
      end;
  end;
begin
  inherited Notification(aComponent, Operation);

  if (Operation = opRemove) and (Ctrls <> nil) then
  begin
    SearchCtrl := SearchControl;
    if SearchCtrl <> nil then Ctrls.RemoveAndFree(SearchCtrl);
  end;
end;

{
  ***********************
  **   Private Part   ***
  ***********************
}


{
  Производит начальные установки
}

constructor TgsIBCtrlGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Ctrls := nil;
  Ctrls := TExList.Create;
  FControlStarted := False;
  ActiveCtrl := nil;
end;

{
  Высвобождает память
}

destructor TgsIBCtrlGrid.Destroy;
begin
  Ctrls.Free;
  Ctrls := nil;

  inherited Destroy;
end;

{
  Активирует control
}

procedure TgsIBCtrlGrid.ShowCtrl(Ctrl: TWinControl);
var
  R: TRect;
  Show: Boolean;
begin
  if Ctrl = nil then Exit;
  Show := True;
  
  if Assigned(FOnSetCtrl) then
    FOnSetCtrl(Self, Ctrl, Columns[Col - Integer(dgIndicator in Options)], Show);

  if Show = False then Exit;
    
  FControlStarted := True;
  ActiveCtrl := Ctrl;
  
  Ctrl.Visible := True;
  R := CellRect(Col, Row);
  MapWindowPoints(HANDLE, Ctrl.Parent.HANDLE, R, 2);
  Ctrl.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
  Ctrl.BringToFront;
  Ctrl.SetFocus;
end;

{
  Добавляет control в список
}

procedure TgsIBCtrlGrid.AddControl(AFieldName: String; AControl: TWinControl;
  var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
var
  ACtrl: TCtrl;
begin
  ACtrl := TCtrl.Create(AFieldName, AControl, ControlOnExit, ControlOnKeyDown);
  Ctrls.Add(ACtrl);
  ControlOnExit := DoOnCtrlExit;
  ControlOnKeyDown := DoOnCtrlKeyDown;
end;

{
  Удаляет control из списка
}

procedure TgsIBCtrlGrid.DeleteControl(AFieldName: String;
  var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
var
  I: Integer;
begin
  for I := 0 to Ctrls.Count - 1 do
    if AnsiCompareText(TCtrl(Ctrls[I]).FieldName, AFieldName) = 0 then
    begin
      ControlOnExit := TCtrl(Ctrls[I]).OldOnExit;
      ControlOnKeyDown := TCtrl(Ctrls[I]).OldOnKeyDown;
      Ctrls.DeleteAndFree(I);
      Break;
    end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsIBCtrlGrid]);
end;


end.

