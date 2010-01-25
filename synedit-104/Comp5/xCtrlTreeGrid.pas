
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xCtrlTreeGrid.pas

  Abstract

    Ordinary DBGrid with ability to insert controls inside it.

  Author

    Michael Shoihet & Romanovski Denis (11-08-98)

  Revisions history

    Initial  11-08-98  Dennis  Initial Delphi 4 version.

    beta1    12-08-98  Dennis  Beta1. Controls supported.
    
--}

unit xCtrlTreeGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  Grids, DBGrids, ExList, DB, mmDBGridTree;

type
  TOnSetCtrlEvent = procedure (Sender: TObject; Ctrl: TWinControl;
    Column: TColumn; var Show: Boolean) of object;

type
  TxCtrlGridTree = class(TmmDBGridTree)
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
    // ���������� �� �������
    property ControlStarted: Boolean read FControlStarted;
    // ������� �������
    property CurrCtrl: TWinControl read GetCurrCtrl;

  published
    // Event �� ��������� control-�
    property OnSetCtrl: TOnSetCtrlEvent read FOnSetCtrl write FOnSetCtrl;
  end;

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
  ������ ��������� ���������
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
  --------------------------------
  ---   TxCtrlGridTree Class   ---
  --------------------------------
}

{
  ***********************
  **   Private Part   ***
  ***********************
}


{
  �� ����� ������ ��� ��������������
}

procedure TxCtrlGridTree.WMChar(var Message: TWMChar);
var
  CurrCtrl: TCtrl;
begin
  CurrCtrl := TCtrl(GetCurrControl);

  if CurrCtrl <> nil then
  begin
    ShowCtrl(CurrCtrl.Control);
    SendMessage(CurrCtrl.Control.HANDLE, wm_Char, Message.CharCode, Message.KeyData);
  end else
    inherited;
end;

{
  �� ������ �� grid-�
}

procedure TxCtrlGridTree.CMExit(var Message: TMessage);
begin
  if not FControlStarted then inherited;
end;

{
  ���� ������� control ��� ���������� ����
}

function TxCtrlGridTree.GetCurrControl: TObject;
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
  �� ������ �� control-�
}

procedure TxCtrlGridTree.DoOnCtrlExit(Sender: TObject);
var
  CurrCtrl: TCtrl;
begin
  if ActiveCtrl <> nil then
  begin
    CurrCtrl := TCtrl(GetCurrControl);

    if Assigned(CurrCtrl.OldOnExit) then CurrCtrl.OldOnExit(Sender);

    ActiveCtrl.Visible := False;
    ActiveCtrl.SendToBack;
    FControlStarted := False;

    if GetParentForm(Self).Enabled and GetParentForm(Self).Visible and
      Enabled and Visible
    then
      SetFocus;
  end;
end;

{
  �� ������� ������� � ��������
}

procedure TxCtrlGridTree.DoOnCtrlKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  CurrCtrl: TCtrl;
  D: TDataLink;
begin
  if ActiveCtrl <> nil then
  begin
    CurrCtrl := TCtrl(GetCurrControl);

    if Assigned(CurrCtrl.OldOnKeyDown) then CurrCtrl.OldOnKeyDown(Sender, Key, Shift);

    if (Key = vk_Escape) or (Key = vk_Return) then
    begin
      D := TDataLink(SendMessage(ActiveCtrl.Handle, CM_GETDATALINK, 0, 0));
      if Key = vk_Escape then
      begin
        if DataSource.State in [dsEdit, dsInsert] then DataSource.DataSet.Cancel;

        if (D <> nil) and D.Active and (D.DataSource <> DataSource) and
          (D.DataSource.State in [dsEdit, dsInsert])
        then
          D.DataSet.Cancel;

        SetFocus;
        ActiveCtrl.Visible := False;
        ActiveCtrl.SendToBack;
      end else begin
//        if Key = vk_Return then SendMessage(CurrCtrl.Control.Handle, WM_CHAR, VK_RETURN, 0);
        SetFocus;
        if Focused then
        begin
          ActiveCtrl.Visible := False;
          ActiveCtrl.SendToBack;
        end;
      end;  

//      if not (DataSource.DataSet is TClientDataSet) then DataSource.DataSet.Refresh;
    end;
  end;
end;

function TxCtrlGridTree.GetCurrCtrl: TWinControl;
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
  �� ������� ������ ����
}

procedure TxCtrlGridTree.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TxCtrlGridTree.Notification(AComponent: TComponent; Operation: TOperation);
var
  SearchCtrl: TObject;

  function SearchControl: TObject;
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
  ���������� ��������� ���������
}

constructor TxCtrlGridTree.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Ctrls := nil;
  Ctrls := TExList.Create;
  FControlStarted := False;
  ActiveCtrl := nil;
end;

{
  ������������ ������
}

destructor TxCtrlGridTree.Destroy;
begin
  Ctrls.Free;
  Ctrls := nil;

  inherited Destroy;
end;

{
  ���������� control
}

procedure TxCtrlGridTree.ShowCtrl(Ctrl: TWinControl);
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
  ��������� control � ������
}

procedure TxCtrlGridTree.AddControl(AFieldName: String; AControl: TWinControl;
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
  ������� control �� ������
}

procedure TxCtrlGridTree.DeleteControl(AFieldName: String;
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

end.

