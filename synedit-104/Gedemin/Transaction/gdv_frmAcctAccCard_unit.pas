unit gdv_frmAcctAccCard_unit;

interface             
                       
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmAcctBaseForm_unit, flt_sqlFilter, gd_ReportMenu,
  ActnList, Db, ExtCtrls, StdCtrls, Mask, xDateEdits, Menus, gd_MacrosMenu,
  Buttons, TB2Item, TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBCustomDataSet, gdvParamPanel, gd_ClassList, Storages,
  gdv_frAcctAnalytics_unit, gdv_frAcctSum_unit, gdv_frAcctQuantity_unit,
  gsStorage_CompPath, IBSQL, AcctUtils, gd_security, gdcBaseInterface,
  gdv_frAcctCompany_unit, AcctStrings, IBDatabase, gsIBLookupComboBox,
  gdv_AcctConfig_unit, gdc_frmTransaction_unit, gd_createable_form,
  gdvAcctBase, gdvAcctAccCard, gdvAcctAccReview;

type
  Tgdv_frmAcctAccCard = class(Tgdv_frmAcctBaseForm)
    ppCorrAccount: TgdvParamPanel;
    Label3: TLabel;
    cbCorrAccounts: TComboBox;
    btnCorrAccounts: TButton;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
    cbShowCorrSubAccounts: TCheckBox;
    Panel3: TPanel;
    Bevel2: TBevel;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label9: TLabel;
    edBeginSaldoDebit: TEdit;
    edBeginSaldoCredit: TEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label18: TLabel;
    edEndSaldoCredit: TEdit;
    edEndSaldoDebit: TEdit;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label8: TLabel;
    edBeginSaldoDebitCurr: TEdit;
    edBeginSaldoCreditCurr: TEdit;
    GroupBox4: TGroupBox;
    Label10: TLabel;
    Label19: TLabel;
    edEndSaldoDebitCurr: TEdit;
    edEndSaldoCreditCurr: TEdit;
    GroupBox5: TGroupBox;
    Label4: TLabel;
    Label11: TLabel;
    edBeginSaldoDebitEQ: TEdit;
    edBeginSaldoCreditEQ: TEdit;
    GroupBox6: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    edEndSaldoDebitEQ: TEdit;
    edEndSaldoCreditEQ: TEdit;
    cbGroup: TCheckBox;
    actEditDocument: TAction;
    tbiEditDocument: TTBItem;
    nEditDocument: TMenuItem;
    TBSeparatorItem5: TTBSeparatorItem;
    actEditDocumentLine: TAction;
    tbiEditDocumentLine: TTBItem;
    nEditDocumentLine: TMenuItem;
    ibdsMain: TgdvAcctAccCard;
    procedure actEditDocumentExecute(Sender: TObject);
    procedure actEditDocumentUpdate(Sender: TObject);
    procedure ibgrMainKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure actEditDocumentLineExecute(Sender: TObject);
    procedure btnCorrAccountsClick(Sender: TObject);
    procedure cbCorrAccountsChange(Sender: TObject);
    procedure cbCorrAccountsExit(Sender: TObject);
    procedure cbShowCorrSubAccountsClick(Sender: TObject);
  private
    procedure EditDocument(ALine: boolean);
  protected
    procedure InitColumns; override;
    procedure DoBeforeBuildReport; override;
    procedure DoAfterBuildReport; override;

    function GetGdvObject: TgdvAcctBase; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
    class function ConfigClassName: string; override;
    procedure SetParams; override;
    procedure Go_to(NewWindow: Boolean = false); override;
    function CanGo_to: boolean; override;
  public
    { Public declarations }
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdv_frmAcctAccCard: Tgdv_frmAcctAccCard;

implementation

uses
  at_classes, gdcAcctEntryRegister, gdcClasses;

{$R *.DFM}

procedure Tgdv_frmAcctAccCard.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTACCCARD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTACCCARD', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTACCCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTACCCARD',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTACCCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    cbCorrAccounts.Items.Text := UserStorage.ReadString(ComponentPath, 'CorrAccountHistory', '');
    ppCorrAccount.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'CorrAccountUnwraped', True);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTACCCARD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTACCCARD', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctAccCard.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTACCCARD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTACCCARD', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTACCCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTACCCARD',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTACCCARD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    UserStorage.WriteString(ComponentPath, 'CorrAccountHistory', cbCorrAccounts.Items.Text);
    UserStorage.WriteBoolean(ComponentPath, 'CorrAccountUnwraped', ppCorrAccount.Unwraped);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTACCCARD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTACCCARD', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctAccCard.DoBeforeBuildReport;
var
  I: Integer;
  F: TgdvFieldInfo;
begin
  if FCorrAccountIDs = nil then
    FCorrAccountIDs := TList.Create
  else
    FCorrAccountIDs.Clear;

  if not FMakeEmpty then
    SetAccountIDs(cbCorrAccounts, FCorrAccountIDs, cbShowCorrSubAccounts.Checked);

  SaveHistory(cbCorrAccounts);

  inherited;

  // дополнительные поля TgdvAcctAccCard
  for I := 0 to AccCardAdditionalFieldCount - 1 do
  begin
    F := FFieldInfos.AddInfo;
    F.FieldName := AccCardAdditionalFieldList[I].FieldName;
    F.Caption := AccCardAdditionalFieldList[I].Caption;
    F.Condition := True;
    F.Visible := fvUnknown;
  end;

  edBeginSaldoDebit.Text := FormatFloat(DisplayFormat(frAcctSum.NcuDecDigits), 0);
  edBeginSaldoCredit.Text := FormatFloat(DisplayFormat(frAcctSum.NcuDecDigits), 0);
  edBeginSaldoDebitCurr.Text := FormatFloat(DisplayFormat(frAcctSum.CurrDecDigits), 0);
  edBeginSaldoCreditCurr.Text := FormatFloat(DisplayFormat(frAcctSum.CurrDecDigits), 0);
  edBeginSaldoDebitEQ.Text := FormatFloat(DisplayFormat(frAcctSum.EQDecDigits), 0);
  edBeginSaldoCreditEQ.Text := FormatFloat(DisplayFormat(frAcctSum.EQDecDigits), 0);

  edEndSaldoDebit.Text := FormatFloat(DisplayFormat(frAcctSum.NcuDecDigits), 0);
  edEndSaldoCredit.Text := FormatFloat(DisplayFormat(frAcctSum.NcuDecDigits), 0);
  edEndSaldoDebitCurr.Text := FormatFloat(DisplayFormat(frAcctSum.CurrDecDigits), 0);
  edEndSaldoCreditCurr.Text := FormatFloat(DisplayFormat(frAcctSum.CurrDecDigits), 0);
  edEndSaldoDebitEQ.Text := FormatFloat(DisplayFormat(frAcctSum.EQDecDigits), 0);
  edEndSaldoCreditEQ.Text := FormatFloat(DisplayFormat(frAcctSum.EQDecDigits), 0);

  FSortColumns := False;
end;

procedure Tgdv_frmAcctAccCard.InitColumns;
begin
  inherited;

  if (FAccountIDs.Count = 0) and (FCorrAccountIDs.Count = 0) then
  begin
    ibgrMain.GroupFieldName := 'ID';
  end;
end;

procedure Tgdv_frmAcctAccCard.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
  S: TStrings;
  Value: string;
  SQL: TIBSQL;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
    cbCorrAccounts.Text := C.CorrAccounts;
    rbDebit.Checked := C.AccountPart = 'D';
    rbCredit.Checked := C.AccountPart <> 'D';
    cbShowCorrSubAccounts.Checked := C.IncCorrSubAccounts;
    cbGroup.Checked := C.Group;

    S := TStringList.Create;
    try
      S.Text := C.Analytics;

      Value := S.Values['ACCOUNTKEY'];
      if Value > '' then
      begin
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := gdcBaseManager.ReadTransaction;
          SQL.SQL.Text := 'SELECT alias FROM ac_account WHERE id = :id';
          SQL.ParamByName('id').AsInteger := StrToInt(Value);
          SQL.ExecQuery;
          cbAccounts.Text := SQl.FieldByName('alias').AsString;
        finally
          SQL.Free;
        end;
      end;

      Value := S.Values['CURRKEY'];

      if Value > '' then
      begin
        frAcctSum.Currkey := StrToInt(Value);
        frAcctSum.InCurr := True;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure Tgdv_frmAcctAccCard.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
    C.CorrAccounts := cbCorrAccounts.Text;
    if rbDebit.Checked then C.AccountPart := 'D';
    if rbCredit.Checked then C.AccountPart := 'C';
    C.IncCorrSubAccounts := cbShowCorrSubAccounts.Checked;
    C.Group := cbGroup.Checked;
  end;
end;

class function Tgdv_frmAcctAccCard.ConfigClassName: string;
begin
  Result := 'TAccCardConfig';
end;

procedure Tgdv_frmAcctAccCard.SetParams;
var
  I: Integer;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    for I := 0 to FCorrAccountIDs.Count - 1 do
      gdvObject.AddCorrAccount(Integer(FCorrAccountIDs.Items[I]));

    TgdvAcctAccCard(gdvObject).CorrDebit := rbDebit.Checked;
    TgdvAcctAccCard(gdvObject).WithCorrSubAccounts := cbShowCorrSubAccounts.Checked;
    TgdvAcctAccCard(gdvObject).DoGroup := cbGroup.Checked;
  end;
end;

procedure Tgdv_frmAcctAccCard.Go_to(NewWindow: Boolean = false);
var
  F: TCreateableForm;
const
  cMsg = 'Проводка не найдена в журнале хозяйственных операций.'#13#10 +
    'Возможно к данным применена фильтрация или отсутствуют права на просмотр.'#13#10 +
    'Переход на проводку невозможен.';
begin
  F := gd_createable_form.FindForm(Tgdc_frmTransaction);

  if not NewWindow or (F = nil) then
  begin
    with Tgdc_frmTransaction.CreateAndAssign(Application) as Tgdc_frmTransaction do
    begin
      cbGroupByDocument.Checked := False;
      if tvGroup.GoToID(gdvObject.FieldByName('transactionkey').AsInteger) and
        gdcAcctViewEntryRegister.Active and
        gdcAcctViewEntryRegister.Locate('RECORDKEY', gdvObject.FieldByName('id').AsInteger, []) then
        Show
      else
        MessageDlg(cMsg, mtWarning, [mbOK], -1);
    end;
  end else
  begin
    with Tgdc_frmTransaction.Create(Application) as Tgdc_frmTransaction do
    begin
      cbGroupByDocument.Checked := False;
      if tvGroup.GoToID(gdvObject.FieldByName('transactionkey').AsInteger) and
        gdcAcctViewEntryRegister.Active and
        gdcAcctViewEntryRegister.Locate('RECORDKEY', gdvObject.FieldByName('id').AsInteger, []) then
        Show
      else
        MessageDlg(cMsg, mtWarning, [mbOK], -1);
    end;
  end;
end;

function Tgdv_frmAcctAccCard.CanGo_to: boolean;
var
  F: TField;
begin
  Result := Assigned(gdvObject) and inherited CanGo_to;
  if Result then
  begin
    F := gdvObject.FindField('id');
    Result := (F <> nil) and (F.AsInteger > 0);
  end;
end;

procedure Tgdv_frmAcctAccCard.EditDocument(ALine: boolean);
var
  EntryRegister: TgdcAcctViewEntryRegister;
  tmpDocument: TgdcDocument;
begin
  EntryRegister := TgdcAcctViewEntryRegister.Create(nil);
  try
    EntryRegister.SubSet := 'ByID';
    EntryRegister.Id := gdvObject.FieldByName('id').AsInteger;
    EntryRegister.Open;
    if (EntryRegister.RecordCount > 0) then begin
      tmpDocument := TgdcDocument.Create(Self);
      try
        tmpDocument.SubSet := 'ByID';
        if ALine then
          tmpDocument.ParamByName('id').AsInteger := EntryRegister.FieldByName('documentkey').AsInteger
        else
          tmpDocument.ParamByName('id').AsInteger := EntryRegister.FieldByName('masterdockey').AsInteger;
        tmpDocument.Open;

        if tmpDocument.RecordCount > 0 then
        begin
          tmpDocument.EditDialog
        end;

      finally
        tmpDocument.Free;
      end;
    end
    else
      MessageDlg('Отсутствуют права на просмотр документа.', mtInformation, [mbOk], -1)
  finally
    EntryRegister.Free;
  end;
end;

procedure Tgdv_frmAcctAccCard.actEditDocumentExecute(Sender: TObject);
var
  EntryRegister: TgdcAcctViewEntryRegister;
begin
  EntryRegister := TgdcAcctViewEntryRegister.Create(nil);
  try
    EntryRegister.SubSet := 'ByID';
    EntryRegister.Id := gdvObject.FieldByName('id').AsInteger;
    EntryRegister.Open;
    if (EntryRegister.RecordCount > 0) then begin
      if EntryRegister.FieldByName('documenttypekey').AsInteger <> DefaultDocumentTypeKey then
        EditDocument(False)
      else
        EntryRegister.EditDialog('');
    end
    else
      MessageDlg('Отсутствуют права на просмотр документа.', mtInformation, [mbOk], -1)
  finally
    EntryRegister.Free;
  end;
end;

procedure Tgdv_frmAcctAccCard.actEditDocumentLineExecute(Sender: TObject);
begin
  EditDocument(True);
end;

procedure Tgdv_frmAcctAccCard.actEditDocumentUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanGo_to;
end;

procedure Tgdv_frmAcctAccCard.ibgrMainKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and ([ssShift] * Shift <> []) and
    not (dgEditing in ibgrMain.Options) then
  begin
    Key := 0;
    actEditDocument.Execute;
  end else
    inherited;
end;

procedure Tgdv_frmAcctAccCard.ibgrMainDblClick(Sender: TObject);
begin
  if (ibgrMain.GridCoordFromMouse.Y > - 1) and
    not (dgEditing in ibgrMain.Options) and
    (GetAsyncKeyState(VK_SHIFT) shr 1 > 0) then
  begin
    actEditDocument.Execute;
  end else
    inherited;
end;

function Tgdv_frmAcctAccCard.GetGdvObject: TgdvAcctBase;
begin
  Result := ibdsMain;
end;

procedure Tgdv_frmAcctAccCard.btnCorrAccountsClick(Sender: TObject);
begin
  if AccountDialog(cbCorrAccounts, GetActiveAccount(frAcctCompany.CompanyKey)) then
  begin
    if FCorrAccountIDs <> nil then
      FCorrAccountIDs.Clear;
  end;                                  
end;

procedure Tgdv_frmAcctAccCard.cbCorrAccountsChange(Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear;
end;

procedure Tgdv_frmAcctAccCard.cbCorrAccountsExit(Sender: TObject);
begin
  CheckActiveAccount(frAcctCompany.CompanyKey, False);
end;

procedure Tgdv_frmAcctAccCard.cbShowCorrSubAccountsClick(Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear;
end;

procedure Tgdv_frmAcctAccCard.DoAfterBuildReport;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    // Значения сальдо на начало периода
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoBeginNcu, edBeginSaldoDebit,
      edBeginSaldoCredit, frAcctSum.NcuDecDigits);
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoBeginCurr, edBeginSaldoDebitCurr,
      edBeginSaldoCreditCurr, frAcctSum.CurrDecDigits);
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoBeginEQ, edBeginSaldoDebitEQ,
      edBeginSaldoCreditEQ, frAcctSum.EQDecDigits);

    // Значения сальдо на конец периода
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoEndNcu, edEndSaldoDebit,
      edEndSaldoCredit, frAcctSum.NcuDecDigits);
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoEndCurr, edEndSaldoDebitCurr,
      edEndSaldoCreditCurr, frAcctSum.CurrDecDigits);
    SetSaldoValue(TgdvAcctAccCard(gdvObject).SaldoEndEQ, edEndSaldoDebitEQ,
      edEndSaldoCreditEQ, frAcctSum.EQDecDigits);
  end;
end;

initialization
  RegisterFrmClass(Tgdv_frmAcctAccCard);
finalization
  UnRegisterFrmClass(Tgdv_frmAcctAccCard);
end.
