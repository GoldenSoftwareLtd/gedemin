
{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.

--}

unit wiz_ExpressionEditorForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, TB2Dock, TB2Toolbar, SynEdit, TB2Item,
  wiz_FunctionBlock_unit, menus, gdcBaseInterface;

type
  TExpressionEditorForm = class(TForm)
    TBDock: TTBDock;
    tbtMain: TTBToolbar;
    pnlButtons: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actAddFunction: TAction;
    actAddAccount: TAction;
    actAddAnalytics: TAction;
    tbiAddAnalitics: TTBItem;
    tbiAddAccount: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    actAddVar: TAction;
    pnlExpression: TPanel;
    TBToolbar1: TTBToolbar;
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Action5: TAction;
    Action6: TAction;
    Action7: TAction;
    Action8: TAction;
    _TBItem6: TTBItem;
    _TBItem7: TTBItem;
    _TBItem8: TTBItem;
    _TBItem9: TTBItem;
    _TBItem10: TTBItem;
    _TBItem11: TTBItem;
    _TBItem12: TTBItem;
    _TBItem13: TTBItem;
    _TBSeparatorItem1: TTBSeparatorItem;
    Action9: TAction;
    Action10: TAction;
    Action11: TAction;
    Action12: TAction;
    Action13: TAction;
    Action14: TAction;
    Action15: TAction;
    Action16: TAction;
    Action17: TAction;
    Action18: TAction;
    _TBItem1: TTBItem;
    _TBItem2: TTBItem;
    _TBItem5: TTBItem;
    _TBItem14: TTBItem;
    _TBItem15: TTBItem;
    _TBItem16: TTBItem;
    _TBItem17: TTBItem;
    _TBItem18: TTBItem;
    _TBItem19: TTBItem;
    _TBItem20: TTBItem;
    mExpression: TMemo;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddAccountExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
    procedure tbiAddAccountClick(Sender: TObject);
    procedure tbiAddAnaliticsClick(Sender: TObject);
    procedure actAddVarExecute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);

  private
    FAccountPopupMenu: TAccountPopupMenu;
    FAnalPopupMenu: TAnalPopupMenu;
    FBlock: TVisualBlock;

    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);

    procedure ClickAnal(Sender: TObject);
    procedure ClickCustomAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
    procedure SetBlock(const Value: TVisualBlock);

  public
    property Block: TVisualBlock read FBlock write SetBlock;
  end;

var
  ExpressionEditorForm: TExpressionEditorForm;

implementation

uses
  wiz_frmAvailableTaxFunc_unit, gdc_frmAccountSel_unit, tax_frmAnalytics_unit,
  wiz_dlgVarSelect_unit, wiz_dlgCustumAnalytic_unit;

{$R *.DFM}

procedure TExpressionEditorForm.actOkExecute(Sender: TObject);
var
  sTmp: string;
begin
  ModalResult := mrOk;
  try
    sTmp:= mExpression.Lines.Text;
    sTmp:= StringReplace(sTmp, #13#10, ' ', [rfReplaceAll]);
    mExpression.Lines.Text:= sTmp;
    GenerateExpression(mExpression.Lines.Text);
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar(E.Message), 'Œ¯Ë·Í‡', MB_OK or MB_ICONERROR);
      ModalResult := mrNone; 
    end;
  end;
end;

procedure TExpressionEditorForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TExpressionEditorForm.actAddFunctionExecute(Sender: TObject);
begin
  with TwizfrmAvailableTaxFunc.CreateWithParams(Self) do
  try
    Block := FBlock;
    if ShowModal = idOk then
    begin
      mExpression.SelText := SelectedFunction;
    end;
  finally
    Free;
  end;
end;

procedure TExpressionEditorForm.actAddAccountExecute(Sender: TObject);
var
  Account: string;
  AccountRuid: string;
begin
  if MainFunction <> nil then
  begin
    if MainFunction.OnClickAccount(Account, AccountRUID) then
    begin
      if CheckRUID(AccountRUID) then
        mExpression.SelText := '"' + AccountRUID + '"{' + Account + '}'
      else
        mExpression.SelText := AccountRUID + '{' + Account + '}'
    end;
  end;
end;

procedure TExpressionEditorForm.actAddAnalyticsExecute(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  D := TfrmAnalytics.Create(nil);
  try
    D.Block := Self.Block;
    if D.ShowModal = idOk then
    begin
      mExpression.SelText := D.Analytics;
    end;
  finally
    D.Free
  end;
end;

procedure TExpressionEditorForm.tbiAddAccountClick(Sender: TObject);
var
  R: TRect;
begin
  with tbtMain do
  begin
    R := View.Find(tbiAddAccount).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;

  if FAccountPopupMenu = nil then
  begin
    FAccountPopupMenu := TAccountPopupMenu.Create(self);
    FAccountPopupMenu.OnClickAccount := ClickAccount;
    FAccountPopupMenu.OnClickAccountCycle := ClickAccountCicle;
  end;
  FAccountPopupMenu.Popup(R.Left, R.Bottom);
end;

procedure TExpressionEditorForm.ClickAccount(Sender: TObject);
begin
  actAddAccount.Execute;
end;

procedure TExpressionEditorForm.ClickAccountCicle(Sender: TObject);
begin
  mExpression.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName, 'alias'])
end;

procedure TExpressionEditorForm.tbiAddAnaliticsClick(Sender: TObject);
var
  R: TRect;
begin
  with tbtMain do
  begin
    R := View.Find(tbiAddAnalitics).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;

  if FAnalPopupMenu = nil then
  begin
    FAnalPopupMenu := TAnalPopupMenu.Create(self);
    FAnalPopupMenu.OnClickAnal := ClickAnal;
    FAnalPopupMenu.OnClickAnalCycle := ClickAnalCycle;
    FAnalPopupMenu.OnClickCustomAnal := ClickCustomAnal;
  end;
  FAnalPopupMenu.Popup(R.Left, R.Bottom);
end;

procedure TExpressionEditorForm.ClickAnal(Sender: TObject);
begin
  actAddAnalytics.Execute;
end;

procedure TExpressionEditorForm.ClickAnalCycle(Sender: TObject);
begin
  mExpression.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption])
end;

procedure TExpressionEditorForm.actAddVarExecute(Sender: TObject);
var
  F: TdlgVarSelect;
  Strings: TStrings;
  Index: Integer;
  VB: TVisualBlock;
begin
  F := TdlgVarSelect.Create(nil);
  try
    Strings := TStringList.Create;
    try
      VarsList(Strings, FBlock);
      F.VarsList := Strings;
      if F.ShowModal = mrOK then
      begin
        Index := Strings.IndexOfName(F.VarName);
        if Index > - 1 then
        begin
          VB := TVisualBlock(Strings.Objects[Index]);
          if VB <> nil then
          begin
            mExpression.SelText := Vb.GetVarScript(F.VarName);
          end else
            mExpression.SelText := F.VarName;
        end else
          mExpression.SelText := F.VarName;
      end;
    finally
      Strings.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TExpressionEditorForm.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TExpressionEditorForm.ClickCustomAnal(Sender: TObject);
begin
  if CustomAnalyticForm.ShowModal = mrOk then
  begin
    mExpression.SelText := CustomAnalyticForm.Value;
  end;
end;

procedure TExpressionEditorForm.Action1Execute(Sender: TObject);
begin
  mExpression.SelText := TAction(Sender).Caption;
end;

end.
