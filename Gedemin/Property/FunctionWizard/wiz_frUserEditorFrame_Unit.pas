// ShlTanya, 09.03.2019

unit wiz_frUserEditorFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, TB2Item, TB2Dock, TB2Toolbar,
  SynEdit, ExtCtrls, ActnList, SynCompletionProposal, SynEditHighlighter,
  SynHighlighterVBScript, wiz_FunctionBlock_unit, Menus, gdcBaseInterface,
  prp_MessageConst, ImgList, Clipbrd, gd_strings;

type
  TfrUserEditFrame = class(TfrEditFrame)
    SynVBScriptSyn: TSynVBScriptSyn;
    SynCompletionProposal: TSynCompletionProposal;
    ActionList: TActionList;
    actAddFunction: TAction;
    actAddAccount: TAction;
    actAddAnalytics: TAction;
    actAddVar: TAction;
    actReserveVar: TAction;
    actReleaseVar: TAction;
    actEditReservedVar: TAction;
    tsScript: TTabSheet;
    TBDock1: TTBDock;
    tbtMain: TTBToolbar;
    TBItem3: TTBItem;
    tbiAddAccount: TTBItem;
    tbiAddAnalitics: TTBItem;
    TBItem4: TTBItem;
    seScript: TSynEdit;
    actFind: TAction;
    actReplace: TAction;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    actAddExpression: TAction;
    TBItem5: TTBItem;
    actCopySQL: TAction;
    actPasteSQL: TAction;
    imFunction: TImageList;
    TBSeparatorItem2: TTBSeparatorItem;
    tbiCopySQL: TTBItem;
    tbiPasteSQL: TTBItem;
    Label4: TLabel;
    lbReservedVars: TListBox;
    Button6: TButton;
    Button5: TButton;
    Button3: TButton;
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddAccountExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
    procedure actAddVarExecute(Sender: TObject);
    procedure actReserveVarExecute(Sender: TObject);
    procedure actReleaseVarExecute(Sender: TObject);
    procedure actReleaseVarUpdate(Sender: TObject);
    procedure actEditReservedVarExecute(Sender: TObject);
    procedure actEditReservedVarUpdate(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    procedure tbiAddAccountClick(Sender: TObject);
    procedure tbiAddAnaliticsClick(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actAddExpressionExecute(Sender: TObject);
    procedure actCopySQLExecute(Sender: TObject);
    procedure actCopySQLUpdate(Sender: TObject);
    procedure actPasteSQLExecute(Sender: TObject);
    procedure actPasteSQLUpdate(Sender: TObject);
  private
    { Private declarations }
    FAccountPopupMenu: TAccountPopupMenu;
    FAnalPopupMenu: TAnalPopupMenu;

    function GetStatament(var Str: String; Pos: Integer): String;
    procedure ParserInit;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    procedure UpDateSyncs;
    procedure UpdateSelectedColor;

    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);

    procedure ClickAnal(Sender: TObject);
    procedure ClickCustomAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SaveChanges; override;
  end;

var
  frUserEditFrame: TfrUserEditFrame;

implementation

uses
  prp_i_VBProposal,
  VBParser,
  syn_ManagerInterface_unit,
  wiz_frmAvailableTaxFunc_unit,
  gdc_frmAccountSel_unit,
  tax_frmAnalytics_unit,
  wiz_dlgVarSelect_unit,
  wiz_dlgReserveVarName_unit,
  wiz_dlgCustumAnalytic_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TfrUserEditFrame.actAddFunctionExecute(Sender: TObject);
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

procedure TfrUserEditFrame.actAddAccountExecute(Sender: TObject);
var
  Account: string;
  AccountRUID: String;
begin
  if MainFunction <> nil then
  begin
    if MainFunction.OnClickAccount(Account, AccountRUID) then
    begin
      if CheckRuid(AccountRUID) then
        seScript.SelText := '"' + AccountRUID + '"{' + Account + '}'
      else
        seScript.SelText := AccountRUID + '{' + Account + '}'
    end;
  end;
end;

procedure TfrUserEditFrame.actAddAnalyticsExecute(Sender: TObject);
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

procedure TfrUserEditFrame.actAddVarExecute(Sender: TObject);
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
            seScript.SelText := Vb.GetVarScript(F.VarName);
          end else
            seScript.SelText := F.VarName;
        end else
          seScript.SelText := F.VarName;
      end;
    finally
      Strings.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrUserEditFrame.actReserveVarExecute(Sender: TObject);
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

procedure TfrUserEditFrame.actReleaseVarExecute(Sender: TObject);
begin
  if lbReservedVars.ItemIndex > - 1 then
    lbReservedVars.Items.Delete(lbReservedVars.ItemIndex);
end;

procedure TfrUserEditFrame.actReleaseVarUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbReservedVars.ItemIndex > - 1;
end;

procedure TfrUserEditFrame.actEditReservedVarExecute(Sender: TObject);
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

procedure TfrUserEditFrame.actEditReservedVarUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbReservedVars.ItemIndex > - 1;
end;

procedure TfrUserEditFrame.SynCompletionProposalExecute(
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

function TfrUserEditFrame.GetStatament(var Str: String;
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

constructor TfrUserEditFrame.Create(AOwner: TComponent);
begin
  inherited;

  PageControl.ActivePageIndex := 1;
  SynCompletionProposal.EndOfTokenChr := '()[].,=<>-+&"';

  UpDateSyncs;
end;

procedure TfrUserEditFrame.ParserInit;
begin
  if VBProposal <> nil then
    VBProposal.ClearFKObjects;
end;

procedure TfrUserEditFrame.ClickAccount(Sender: TObject);
begin
  actAddAccount.Execute;
end;

procedure TfrUserEditFrame.ClickAccountCicle(Sender: TObject);
begin
  seScript.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName, 'alias'])
end;

procedure TfrUserEditFrame.ClickAnal(Sender: TObject);
begin
  actAddAnalytics.Execute;
end;

procedure TfrUserEditFrame.ClickAnalCycle(Sender: TObject);
begin
  seScript.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption])
end;

procedure TfrUserEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;

  with FBlock as TUserBlock do
  begin
    seScript.Lines.Assign(Script);
    lbReservedVars.Items.Text := Reserved;
  end;
end;

procedure TfrUserEditFrame.UpdateSelectedColor;
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

procedure TfrUserEditFrame.UpDateSyncs;
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

procedure TfrUserEditFrame.SaveChanges;
begin
  inherited;

  with FBlock as TUserBlock do
  begin
    Script.Assign(seScript.Lines);
    Reserved := lbReservedVars.Items.Text;
  end;
end;

procedure TfrUserEditFrame.tbiAddAccountClick(Sender: TObject);
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

procedure TfrUserEditFrame.tbiAddAnaliticsClick(Sender: TObject);
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

procedure TfrUserEditFrame.ClickCustomAnal(Sender: TObject);
begin
  if CustomAnalyticForm.ShowModal = mrOk then
  begin
    seScript.SelText := CustomAnalyticForm.Value;
  end;
end;

procedure TfrUserEditFrame.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if seScript.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      MessageBox(Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING);
    end;
  end;
end;

procedure TfrUserEditFrame.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if seScript.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    if seScript.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_REPLACE),
       MSG_WARNING, MB_OK or MB_ICONWARNING);
    end;
  end;
end;

procedure TfrUserEditFrame.actFindExecute(Sender: TObject);
begin
  if seScript.SelAvail then
    FindDialog1.FindText := seScript.SelText
  else
    FindDialog1.FindText := seScript.WordAtCursor;
  FindDialog1.Execute;
end;

procedure TfrUserEditFrame.actReplaceExecute(Sender: TObject);
begin
  if seScript.SelAvail then
    ReplaceDialog1.FindText := seScript.SelText
  else
    ReplaceDialog1.FindText := seScript.WordAtCursor;
  ReplaceDialog1.Execute;
end;

procedure TfrUserEditFrame.actAddExpressionExecute(Sender: TObject);
begin
  seScript.SelText := FBlock.EditExpression('', FBlock);
end;

procedure TfrUserEditFrame.actCopySQLExecute(Sender: TObject);
begin
  gd_strings.CopySQL(seScript);
end;

procedure TfrUserEditFrame.actCopySQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= seScript.SelAvail;
end;

procedure TfrUserEditFrame.actPasteSQLExecute(Sender: TObject);
begin
  gd_strings.PasteSQL(seScript);
end;

procedure TfrUserEditFrame.actPasteSQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= Clipboard.HasFormat(CF_TEXT);
end;

end.
