{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_dfBreakPoints_Unit.pas

  Abstract

    Gedemin project. TdfBreakPoints.

  Author

    Karpuk Alexander

  Revisions history

    1.00    20.01.03    tiptop        Initial version.
--}
unit prp_dfBreakPoints_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_DOCKFORM_unit, ComCtrls, IBCustomDataSet, scr_i_FunctionList, gdcBaseInterface,
  obj_i_Debugger, gdcConstants, dmImages_unit, IBSQL, ActnList, Menus,
  ExtCtrls;

type
  TdfBreakPoints = class(TDockableForm)
    lvBreakPoints: TListView;
    actEdit: TAction;
    actDelete: TAction;
    actEnable: TAction;
    actDeleteAll: TAction;
    actEnableAll: TAction;
    actDisableAll: TAction;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N15: TMenuItem;
    N14: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure lvBreakPointsDblClick(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteAllExecute(Sender: TObject);
    procedure actDeleteAllUpdate(Sender: TObject);
    procedure actEnableAllExecute(Sender: TObject);
    procedure actDisableAllExecute(Sender: TObject);
    procedure actEnableUpdate(Sender: TObject);
    procedure actEnableExecute(Sender: TObject);
  private
    { Private declarations }
    function GetselectedBreakpoint: TBreakPoint;
    procedure InvalidateFrame;
    procedure SetBreakPointsEnable(Value: Boolean);
  public
    { Public declarations }
    procedure LoadBreakPoints;
  end;

var
  dfBreakPoints: TdfBreakPoints;

implementation
uses prp_frmGedeminProperty_Unit, prp_dlgBreakPointProperty_unit, prp_BaseFrame_unit,
  rp_BaseReport_unit;

{$R *.DFM}

{ TdfBreakPoints }

procedure TdfBreakPoints.LoadBreakPoints;
var
  I: Integer;
  LI: TListItem;
  B: TBreakPoint;
  F: TrpCustomFunction;
begin
  if csDestroying in ComponentState then
    exit;

  lvBreakPoints.Items.BeginUpdate;
  try
    lvBreakPoints.Items.Clear;
    if (BreakPointList <> nil) and (glbFunctionList <> nil) then
    begin
      for I := 0 to BreakPointList.Count - 1 do
      begin
        B := BreakPointList[I];
        F := glbFunctionList.FindFunction(B.FunctionKey);
        if (F <> nil) and (lvBreakPoints <> nil) then
        try
          LI := lvBreakPoints.Items.Add;
          Li.Caption := IntToStr(B.FunctionKey);
          Li.SubItems.Add(F.Name);
          Li.SubItems.Add(IntToStr(B.Line));
          Li.SubItems.Add(B.Condition);
          Li.SubItems.Add(Format('%d of %d', [B.ValidPassCount, B.PassCount]));
          if B.Enabled then
            Li.ImageIndex := 18
          else
            Li.ImageIndex := 19;
        finally
          glbFunctionList.ReleaseFunction(F);
        end;
      end;
    end;
  finally
    if lvBreakPoints <> nil then
      lvBreakPoints.Items.EndUpdate;
  end;
end;

procedure TdfBreakPoints.FormCreate(Sender: TObject);
begin
  inherited;
  LoadBreakPoints;
end;

procedure TdfBreakPoints.lvBreakPointsDblClick(Sender: TObject);
begin
  if lvBreakPoints.Selected <> nil then
  begin
    if DockForm <> nil then
    begin
      TfrmGedeminProperty(DockForm).FindAndEdit(StrToInt(
        lvBreakPoints.Selected.Caption),
        StrToInt(lvBreakPoints.Selected.SubItems[1]), 0, False);
    end;
  end;
end;

procedure TdfBreakPoints.actEditUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvBreakPoints.Selected <> nil;
end;

procedure TdfBreakPoints.actEditExecute(Sender: TObject);
var
  F: TdlgBreakPointProperty;
  B: TBreakPoint;
begin
  if lvBreakPoints.Selected <> nil then
  begin
    B := GetselectedBreakpoint;
    F := TdlgBreakPointProperty.Create(Application);
    try
      F.BreakPoint := B;
      F.ShowModal;
      LoadBreakPoints;
      InvalidateFrame;
    finally
      F.Free;
    end;
  end;
end;

function TdfBreakPoints.GetselectedBreakpoint: TBreakPoint;
begin
  Result := nil;
  if lvBreakPoints.Selected <> nil then
    Result := BreakPointList.BreakPoint(StrToInt(lvBreakPoints.Selected.Caption),
      StrToInt(lvBreakPoints.Selected.SubItems[1]));
end;

procedure TdfBreakPoints.InvalidateFrame;
begin
  if DockForm <> nil then
    if TfrmGedeminProperty(DockForm).ActiveFrame <> nil then
      TBaseFrame(TfrmGedeminProperty(DockForm).ActiveFrame).InvalidateFrame;
end;

procedure TdfBreakPoints.actDeleteExecute(Sender: TObject);
var
  B: TBreakPoint;
  Index: Integer;
begin
  B := GetselectedBreakpoint;
  if B <> nil then
  begin
    BreakPointList.Remove(B);
    Index := lvBreakPoints.Selected.Index;
    lvBreakPoints.Selected.Delete;
    if (lvBreakPoints.Selected = nil) and (lvBreakPoints.Items.Count > 0) then
    begin
      if Index < lvBreakPoints.Items.Count then
        lvBreakPoints.Selected := lvBreakPoints.Items[Index] 
      else
        lvBreakPoints.Selected := lvBreakPoints.Items[lvBreakPoints.Items.Count - 1];
    end;
    InvalidateFrame;
    BreakPointList.SaveToStorage;
  end;
end;

procedure TdfBreakPoints.actDeleteAllExecute(Sender: TObject);
begin
  BreakPointList.Clear;
  lvBreakPoints.Items.Clear;
  InvalidateFrame;
  BreakPointList.SaveToStorage;
end;

procedure TdfBreakPoints.actDeleteAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := BreakPointList.Count > 0;
end;

procedure TdfBreakPoints.actEnableAllExecute(Sender: TObject);
begin
  SetBreakPointsEnable(True);
end;

procedure TdfBreakPoints.SetBreakPointsEnable(Value: Boolean);
var
  I: Integer;
begin
  for I := 0 to BreakPointList.Count - 1 do
    BreakPointList[I].Enabled := Value;
  lvBreakPoints.Items.BeginUpdate;
  try
    for I := 0 to lvBreakPoints.Items.Count -1 do
      lvBreakPoints.Items[i].ImageIndex := 19 - Integer(Value);
  finally
    lvBreakPoints.Items.EndUpdate;
  end;
  InvalidateFrame;
end;

procedure TdfBreakPoints.actDisableAllExecute(Sender: TObject);
begin
  SetBreakPointsEnable(False);
end;

procedure TdfBreakPoints.actEnableUpdate(Sender: TObject);
var
 B: TBreakPoint;
 A: Taction;
begin
  B := GetselectedBreakpoint;
  A := TAction(Sender);
  A.Enabled := B <> nil;
  if A.Enabled then
    A.Checked := B.Enabled
  else
    A.Checked := False;
end;

procedure TdfBreakPoints.actEnableExecute(Sender: TObject);
var
 B: TBreakPoint;
begin
  B := GetselectedBreakpoint;
  if B <> nil then
  begin
    B.Enabled := not B.Enabled;
    lvBreakPoints.Selected.ImageIndex := 19 - Integer(B.Enabled);
    InvalidateFrame;
  end;
end;

end.
