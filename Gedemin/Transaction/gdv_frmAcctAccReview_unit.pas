unit gdv_frmAcctAccReview_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmAcctBaseForm_unit, ExtCtrls, Menus, IBDatabase, Db, ibsql,
  IBCustomDataSet, flt_sqlFilter, gd_ReportMenu, gd_MacrosMenu, ActnList,
  gdvParamPanel, gdv_frAcctCompany_unit, gdv_frAcctAnalytics_unit,
  gdv_frAcctSum_unit, gdv_frAcctQuantity_unit, StdCtrls, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsIBLookupComboBox, Mask, xDateEdits, Buttons,
  TB2Item, TB2Dock, TB2Toolbar, gsStorage_CompPath, gd_ClassList, Storages,
  AcctUtils, AcctStrings, gdv_AcctConfig_unit, gdcBaseInterface, at_classes,
  gd_createable_form, gdvAcctBase, gdvAcctAccReview;

type
  Tgdv_frmAcctAccReview = class(Tgdv_frmAcctBaseForm)
    ppCorrAccount: TgdvParamPanel;
    Label3: TLabel;
    cbCorrAccounts: TComboBox;
    btnCorrAccounts: TButton;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
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
    cbShowCorrSubAccounts: TCheckBox;
    ibdsMain: TgdvAcctAccReview;
    procedure cbCorrAccountsChange(Sender: TObject);
    procedure btnCorrAccountsClick(Sender: TObject);
    procedure cbCorrAccountsExit(Sender: TObject);
    procedure cbShowCorrSubAccountsClick(Sender: TObject);
  protected
    class function ConfigClassName: string; override;

    function GetGdvObject: TgdvAcctBase; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;

    procedure Go_to(NewWindow: Boolean = false); override;
    function  CanGo_to: boolean; override;

    procedure DoBeforeBuildReport; override;
    procedure DoAfterBuildReport; override;
    procedure SetParams; override;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdv_frmAcctAccReview: Tgdv_frmAcctAccReview;

implementation

uses
  gdv_frmAcctAccCard_unit;

{$R *.DFM}

const
  cNCUPrefix = 'NCU';
  cCURRPrefix = 'CURR';
  cEQPrefix = 'EQ';
  cQuantityDisplayFormat = '### ##0.##';

{ Tgdv_frmAcctAccountReview }

procedure Tgdv_frmAcctAccReview.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTACCREVIEW', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTACCREVIEW', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTACCREVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTACCREVIEW',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTACCREVIEW' then
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
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTACCREVIEW', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTACCREVIEW', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctAccReview.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTACCREVIEW', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTACCREVIEW', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTACCREVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTACCREVIEW',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTACCREVIEW' then
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

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTACCREVIEW', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTACCREVIEW', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

class function Tgdv_frmAcctAccReview.ConfigClassName: string;
begin
  Result := 'TAccReviewConfig';
end;

procedure Tgdv_frmAcctAccReview.cbCorrAccountsChange(Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear;
end;

procedure Tgdv_frmAcctAccReview.btnCorrAccountsClick(Sender: TObject);
begin
  if AccountDialog(cbCorrAccounts, GetActiveAccount(frAcctCompany.CompanyKey)) then
  begin
    if FCorrAccountIDs <> nil then
      FCorrAccountIDs.Clear;
  end;
end;          

procedure Tgdv_frmAcctAccReview.cbCorrAccountsExit(Sender: TObject);
begin
  CheckActiveAccount(frAcctCompany.CompanyKey, False);
end;

procedure Tgdv_frmAcctAccReview.cbShowCorrSubAccountsClick(
  Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear;
end;

procedure Tgdv_frmAcctAccReview.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
  S: TStrings;
  Value: string;
  SQL: TIBSQL;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    C.ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
    cbCorrAccounts.Text := C.CorrAccounts;
    rbDebit.Checked := C.AccountPart = 'D';
    rbCredit.Checked := C.AccountPart <> 'D';

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

procedure Tgdv_frmAcctAccReview.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    C.ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
    C.CorrAccounts := cbCorrAccounts.Text;
    if rbDebit.Checked then C.AccountPart := 'D';
    if rbCredit.Checked then C.AccountPart := 'C';
  end;
end;

procedure Tgdv_frmAcctAccReview.DoBeforeBuildReport;
var
  I, J: Integer;
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

  FFieldInfos.Clear;
  for I := 0 to AccReviewFieldCount - 1 do begin
    F := FFieldInfos.AddInfo;
    F.FieldName := AccReviewFieldList[I].FieldName;
    F.Caption := AccReviewFieldList[I].Caption;
    F.Condition := True;
    F.Total := True;
    if Pos('NCU_', AccReviewFieldList[I].FieldName) = 1 then begin
      F.DisplayFormat := DisplayFormat(frAcctSum.NcuDecDigits);
      if frAcctSum.InNcu then
        F.Visible := fvVisible;
    end
    else
      if Pos('CURR_', AccReviewFieldList[I].FieldName) = 1 then
      begin
        F.DisplayFormat := DisplayFormat(frAcctSum.CurrDecDigits);
        if (frAcctSum.InCurr) and (not frAcctSum.InNcu) then
          F.Visible := fvVisible;
        if (frAcctSum.InCurr) and (frAcctSum.InNcu) then
          F.DisplayFields.Add(AccReviewFieldList[I].DisplayFieldName);
      end
      else
        if Pos('EQ_', AccReviewFieldList[I].FieldName) = 1 then
        begin
          F.DisplayFormat := DisplayFormat(frAcctSum.EQDecDigits);
          if (frAcctSum.InEQ) and (not frAcctSum.InNcu) then
            F.Visible := fvVisible;
          if (frAcctSum.InEQ) and (frAcctSum.InNcu) then
            F.DisplayFields.Add(AccReviewFieldList[I].DisplayFieldName);
        end
        else
        begin
          {F.Visible := ((AccReviewFieldList[I].FieldName = 'ALIAS') and ((FAccountIDs.Count > 1) or (FAccountIDs.Count = 0)))
            or (AccReviewFieldList[I].FieldName = 'CORRALIAS')
            or (AccReviewFieldList[I].FieldName = 'NAME')
            or (AccReviewFieldList[I].FieldName = 'CORRNAME')}
          F.Visible := fvUnknown; 
        end;
  end;

  if FValueList.Count > 0 then
  begin
    for J := 0 to AccReviewQuantityFieldCount - 1 do
    begin
      for I := 0 to FValueList.Count - 1 do
      begin
        F := FFieldInfos.AddInfo;
        F.FieldName := Format(AccReviewQuantityFieldList[J].FieldName, [KeyAlias(FValueList.Names[I])]);
        F.Caption := Format(AccReviewQuantityFieldList[J].Caption,
            [FValueList.Values[FValueList.Names[I]]]);
        F.Visible := fvHidden;
        F.Total := True;

        F.DisplayFields.Add(Format(AccReviewQuantityFieldList[J].DisplayFieldName, [cNCUPrefix]));
        F.DisplayFields.Add(Format(AccReviewQuantityFieldList[J].DisplayFieldName, [cCURRPrefix]));
        F.DisplayFields.Add(Format(AccReviewQuantityFieldList[J].DisplayFieldName, [cEQPrefix]));
        F.DisplayFormat := '';
      end;
    end;
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

procedure Tgdv_frmAcctAccReview.DoAfterBuildReport;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    // Значения сальдо на начало периода
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoBeginNcu, edBeginSaldoDebit,
      edBeginSaldoCredit, frAcctSum.NcuDecDigits);
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoBeginCurr, edBeginSaldoDebitCurr,
      edBeginSaldoCreditCurr, frAcctSum.CurrDecDigits);
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoBeginEQ, edBeginSaldoDebitEQ,
      edBeginSaldoCreditEQ, frAcctSum.EQDecDigits);

    // Значения сальдо на конец периода
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoEndNcu, edEndSaldoDebit,
      edEndSaldoCredit, frAcctSum.NcuDecDigits);
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoEndCurr, edEndSaldoDebitCurr,
      edEndSaldoCreditCurr, frAcctSum.CurrDecDigits);
    SetSaldoValue(TgdvAcctAccReview(gdvObject).SaldoEndEQ, edEndSaldoDebitEQ,
      edEndSaldoCreditEQ, frAcctSum.EQDecDigits);
  end;
end;

procedure Tgdv_frmAcctAccReview.SetParams;
var
  I: Integer;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    for I := 0 to FCorrAccountIDs.Count - 1 do
      gdvObject.AddCorrAccount(Integer(FCorrAccountIDs.Items[I]));

    TgdvAcctAccReview(gdvObject).CorrDebit := rbDebit.Checked;
    TgdvAcctAccReview(gdvObject).WithCorrSubAccounts := cbShowCorrSubAccounts.Checked;
  end;
end;

procedure Tgdv_frmAcctAccReview.Go_to(NewWindow: Boolean);
var
  F: TField;
  C: TAccCardConfig;
  Form: TCreateableForm;
  sAcc, sCorrAcc: string;

  function GetAccountPart(var AAcc: string; var ACorrAcc: string): string;
  var
    ii: integer;
    slAcc, slCorrAcc: TStringList;
  begin
    AAcc:= '';
    ACorrAcc:= '';
    if rbDebit.Checked then
      Result:= 'D'
    else
      Result:= 'C';

    slAcc:= TStringList.Create;
    slCorrAcc:= TStringList.Create;
    try
      for ii:= 0 to ibgrMain.SelectedRows.Count - 1 do begin
        if ii = 0 then begin
          if frAcctSum.InNCU then begin
            if gdvObject.FieldByName('ncu_debit').AsInteger > 0 then
              Result:= 'C'
            else
              Result:= 'D';
          end
          else if frAcctSum.InCurr then begin
            if gdvObject.FieldByName('curr_debit').AsInteger > 0 then
              Result:= 'C'
            else
              Result:= 'D';
          end
          else if frAcctSum.InEq then begin
            if gdvObject.FieldByName('eq_debit').AsInteger > 0 then
              Result:= 'C'
            else
              Result:= 'D';
          end;
        end;
        gdvObject.GotoBookmark(pointer(ibgrMain.SelectedRows.Items[ii]));
        if slAcc.IndexOf(gdvObject.FieldByName('alias').AsString) = -1 then begin
          if AAcc <> '' then
            AAcc:= AAcc + ', ';
          AAcc:= AAcc + gdvObject.FieldByName('alias').AsString;
          slAcc.Add(gdvObject.FieldByName('alias').AsString);
        end;
        if slCorrAcc.IndexOf(gdvObject.FieldByName('corralias').AsString) = -1 then begin
          if ACorrAcc <> '' then
            ACorrAcc:= ACorrAcc + ', ';
          ACorrAcc:= ACorrAcc + gdvObject.FieldByName('corralias').AsString;
          slCorrAcc.Add(gdvObject.FieldByName('corralias').AsString);
        end;
      end;
    finally
      slAcc.Free;
      slCorrAcc.Free;
    end;
  end;

begin
  Form := gd_createable_form.FindForm(Tgdv_frmAcctAccCard);

  F := ibgrMain.SelectedField;
  if F <> nil then
  begin
    C := TAccCardConfig.Create;
    try
      DoSaveConfig(C);
      C.InNcu:= frAcctSum.InNcu;
      C.NcuDecDigits:= frAcctSum.NcuDecDigits;
      C.NcuScale:= frAcctSum.NcuScale;
      C.InCurr:= frAcctSum.InCurr;
      C.CurrDecDigits:= frAcctSum.CurrDecDigits;
      C.CurrScale:= frAcctSum.CurrScale;
      C.CurrKey:= frAcctSum.CurrKey;
      C.InEq:= frAcctSum.InEq;
      C.EqDecDigits:= frAcctSum.EqDecDigits;
      C.EqScale:= frAcctSum.EqScale;
      C.CompanyKey:= frAcctCompany.iblCompany.CurrentKeyInt;
      C.AllHoldingCompanies:= frAcctCompany.cbAllCompanies.Checked;
      C.IncCorrSubAccounts:= False;
      C.AccountPart:= GetAccountPart(sAcc, sCorrAcc);
      C.Accounts:= sAcc;
      C.CorrAccounts:= sCorrAcc;
      C.Analytics:= frAcctAnalytics.Values;

      if not NewWindow or (Form = nil) then
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.CreateAndAssign(Application)) do begin
          DateBegin := Self.DateBegin;
          DateEnd := Self.DateEnd;

          Show;
          Execute(C);
        end;
      end else
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.Create(Application)) do begin
          DateBegin := Self.DateBegin;
          DateEnd := Self.DateEnd;

          Show;
          Execute(C);
        end;
      end;
    finally
      C.Free;
    end;
  end;
end;

function Tgdv_frmAcctAccReview.CanGo_to: boolean;
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

function Tgdv_frmAcctAccReview.GetGdvObject: TgdvAcctBase;
begin
  Result := ibdsMain;
end;

initialization
  RegisterFrmClass(Tgdv_frmAcctAccReview);

finalization
  UnRegisterFrmClass(Tgdv_frmAcctAccReview);

end.


