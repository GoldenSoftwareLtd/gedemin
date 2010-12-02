{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgUserEditorForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_DLGEDITFROM_UNIT, ActnList, StdCtrls, ComCtrls, ExtCtrls, SynEdit,
  wiz_FunctionBlock_unit, SynCompletionProposal, SynEditHighlighter,
  SynHighlighterVBScript, TB2Dock, TB2Item, TB2Toolbar, menus;

type
  TdlgUserEditorForm = class(TBlockEditForm)
    Label3: TLabel;
    SynVBScriptSyn: TSynVBScriptSyn;
    SynCompletionProposal: TSynCompletionProposal;
    actAddFunction: TAction;
    actAddAccount: TAction;
    actAddAnalytics: TAction;
    actAddVar: TAction;
    Panel2: TPanel;
    seScript: TSynEdit;
    TBDock1: TTBDock;
    tbtMain: TTBToolbar;
    TBItem3: TTBItem;
    tbiAddAccount: TTBItem;
    tbiAddAnalitics: TTBItem;
    TBItem4: TTBItem;
    Label4: TLabel;
    lbReservedVars: TListBox;
    Button3: TButton;
    Button5: TButton;
    actReserveVar: TAction;
    actReleaseVar: TAction;
    Button6: TButton;
    actEditReservedVar: TAction;
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    function GetStatament(var Str: String; Pos: Integer): String;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddAccountExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
    procedure actAddVarExecute(Sender: TObject);
    procedure tbiAddAccountClick(Sender: TObject);
    procedure tbiAddAnaliticsClick(Sender: TObject);
    procedure actReserveVarExecute(Sender: TObject);
    procedure actReleaseVarExecute(Sender: TObject);
    procedure actReleaseVarUpdate(Sender: TObject);
    procedure actEditReservedVarExecute(Sender: TObject);
  private
    { Private declarations }
    procedure ParserInit;
  protected
    FAccountPopupMenu: TAccountPopupMenu;
    FAnalPopupMenu: TAnalPopupMenu;

    procedure SetBlock(const Value: TVisualBlock); override;
    procedure UpDateSyncs;
    procedure UpdateSelectedColor;

    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);

    procedure ClickAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
//    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  dlgUserEditorForm: TdlgUserEditorForm;

implementation
uses prp_i_VBProposal, VBParser, syn_ManagerInterface_unit,
  wiz_frmAvailableTaxFunc_unit, gdc_frmAccountSel_unit, tax_frmAnalytics_unit,
  wiz_dlgVarSelect_unit, wiz_dlgReserveVarName_unit;
{$R *.DFM}

{ TdlgUserEditorForm }

function TdlgUserEditorForm.GetStatament(var Str: String;
  Pos: Integer): String;
var
  BeginPos, EndPos: Integer;
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((system.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos > 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Dec(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

procedure TdlgUserEditorForm.ParserInit;
begin
  if VBProposal <> nil then
    VBProposal.ClearFKObjects;
end;

procedure TdlgUserEditorForm.SaveChanges;
begin
  inherited;

  with FBlock as TUserBlock do
  begin
    Script.Assign(seScript.Lines);
    Reserved := lbReservedVars.Items.Text;
  end;
end;

procedure TdlgUserEditorForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;

  with FBlock as TUserBlock do
  begin
    seScript.Lines.Assign(Script);
    lbReservedVars.Items.Text := Reserved;
  end;
end;

procedure TdlgUserEditorForm.SynCompletionProposalExecute(
  Kind: SynCompletionType; Sender: TObject; var AString: String; x,
  y: Integer; var CanExecute: Boolean);
var
  Str: String;
  Script: TStrings;
begin
  CanExecute := False;
  if Assigned(VBProposal) then
  begin
    ParserInit;
    Str := seScript.LineText;
    Str := GetStatament(Str, seScript.CaretX);

    Script := TStringList.Create;
    try
      Script.Assign(seScript.Lines);
      VBProposal.PrepareScript(Str, Script, seScript.CaretY);
    finally
      Script.Free;
    end;
    SynCompletionProposal.ItemList.Assign(VBProposal.ItemList);
    SynCompletionProposal.InsertList.Assign(VBProposal.InsertList);
    CanExecute := SynCompletionProposal.ItemList.Count > 0;
  end;
end;

procedure TdlgUserEditorForm.UpdateSelectedColor;
var
  SynVBScriptSyn: TSynVBScriptSyn;
begin
  SynVBScriptSyn := TSynVBScriptSyn(seScript.Highlighter);
  if SynVBScriptSyn <> nil then
  begin
    seScript.SelectedColor.Foreground :=
      SynVBScriptSyn.MarkBlockAttri.Foreground;
    seScript.SelectedColor.Background :=
      SynVBScriptSyn.MarkBlockAttri.Background;
  end else
  begin
    seScript.SelectedColor.Foreground := clHighlightText;
    seScript.SelectedColor.Background := clHighlight;
  end;
end;

procedure TdlgUserEditorForm.UpDateSyncs;
begin
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynVBScriptSyn);
    seScript.BeginUpdate;
    try
      seScript.Font.Assign(SynManager.GetHighlighterFont);
      SynManager.GetSynEditOptions(TSynEdit(seScript));

      UpdateSelectedColor;
    finally
      seScript.EndUpdate;
    end;
    seScript.Repaint;
  end;
end;

procedure TdlgUserEditorForm.FormCreate(Sender: TObject);
begin
  inherited;

  SynCompletionProposal.EndOfTokenChr := '()[].,=<>-+&"';

  UpDateSyncs;
end;

procedure TdlgUserEditorForm.FormShow(Sender: TObject);
begin
  inherited;

  UpDateSyncs;
end;

procedure TdlgUserEditorForm.actAddFunctionExecute(Sender: TObject);
begin
  with TwizfrmAvailableTaxFunc.CreateWithParams(Self) do
  try
    Block := FBlock;
    if ShowModal = idOk then
    begin
      seScript.SelText := SelectedFunction;
    end;
  finally
    Free;
  end;
end;

procedure TdlgUserEditorForm.actAddAccountExecute(Sender: TObject);
begin
  with TfrmAccountSel.Create(nil) do
  try
    if ShowModal = idOk then
      seScript.SelText := '"' + ibcbAnalytics.Text + '"';
  finally
    Free;
  end
end;

procedure TdlgUserEditorForm.actAddAnalyticsExecute(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  D := TfrmAnalytics.Create(nil);
  try
    D.Block := Self.Block;
    if D.ShowModal = idOk then
    begin
      seScript.SelText := '"' + D.Analytics + '"';
    end;
  finally
    D.Free
  end;
end;

procedure TdlgUserEditorForm.actAddVarExecute(Sender: TObject);
var
  F: TdlgVarSelect;
  Strings: TStrings;
begin
  F := TdlgVarSelect.Create(nil);
  try
    Strings := TStringList.Create;
    try
      VarsList(Strings, FBlock);
      F.VarsList := Strings;
      if F.ShowModal = mrOK then
      begin
        seScript.SelText := F.VarName;
      end;
    finally
      Strings.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgUserEditorForm.ClickAccount(Sender: TObject);
begin
  actAddAccount.Execute;
end;

procedure TdlgUserEditorForm.ClickAccountCicle(Sender: TObject);
begin
  seScript.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName, 'alias'])
end;

procedure TdlgUserEditorForm.ClickAnal(Sender: TObject);
begin
  actAddAnalytics.Execute;
end;

procedure TdlgUserEditorForm.ClickAnalCycle(Sender: TObject);
begin
  seScript.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption])
end;

procedure TdlgUserEditorForm.tbiAddAccountClick(Sender: TObject);
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

procedure TdlgUserEditorForm.tbiAddAnaliticsClick(Sender: TObject);
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
  end;
  FAnalPopupMenu.Popup(R.Left, R.Bottom);
end;

procedure TdlgUserEditorForm.actReserveVarExecute(Sender: TObject);
var
  F: TdlgReserveVarName;

begin
  F := TdlgReserveVarName.Create(Application);
  try
    if F.ShowModal = mrOk then
    begin
      if lbReservedVars.Items.IndexOf(UpperCase(F.VarName)) = - 1 then
        lbReservedVars.Items.Add(F.VarName);
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgUserEditorForm.actReleaseVarExecute(Sender: TObject);
begin
  if lbReservedVars.ItemIndex > - 1 then
    lbReservedVars.Items.Delete(lbReservedVars.ItemIndex);
end;

procedure TdlgUserEditorForm.actReleaseVarUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbReservedVars.ItemIndex > - 1;
end;

procedure TdlgUserEditorForm.actEditReservedVarExecute(Sender: TObject);
var
  F: TdlgReserveVarName;
begin
  F := TdlgReserveVarName.Create(Application);
  try
    F.VarName := lbReservedVars.Items[lbReservedVars.ItemIndex];
    if F.ShowModal = mrOk then
      lbReservedVars.Items[lbReservedVars.ItemIndex] := F.VarName; 
  finally
    F.Free;
  end;
end;

end.
