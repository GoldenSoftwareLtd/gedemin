// ShlTanya, 30.01.2019

unit gdc_dlgBaseStatementLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList,  StdCtrls, IBDatabase,
  gsIBLookupComboBox, Db, IBCustomDataSet, gdcBase, gdcClasses, Mask,
  DBCtrls, gdc_dlgG_unit, gdcContacts, gd_security, gd_security_body, IBSQL,
  gd_security_OperationConst, IBQuery,
  gdcStatement, gdc_dlgTR_unit, gdcTree, Menus, ExtCtrls;

type
  Tgdc_dlgBaseStatementLine = class(Tgdc_dlgTR)
    ibcmbCompany: TgsIBLookupComboBox;
    Label2: TLabel;
    edtDocNumber: TDBEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    edtOperationType: TDBEdit;
    edtCSumNCU: TDBEdit;
    edtDSumNCU: TDBEdit;
    edtPaymentMode: TDBEdit;
    memComment: TDBMemo;
    edDoc: TEdit;
    actDocLink: TAction;
    dbeAccount: TDBEdit;
    dbeBank: TDBEdit;
    lbInfo: TLabel;
    lbInfo2: TLabel;
    lbCurrency: TLabel;
    Label1: TLabel;
    ibsql: TIBSQL;
    cbDontRecalc: TCheckBox;
    lblAcctAccount: TLabel;
    iblkAccountKey: TgsIBLookupComboBox;
    Bevel1: TBevel;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
    procedure SyncField(Field: TField; SyncList: TList); override;
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

  end;

var
  gdc_dlgBaseStatementLine: Tgdc_dlgBaseStatementLine;

implementation

uses
  dmDataBase_unit, gd_ClassList, Gedemin_TLB,
  Storages, gsStorage_CompPath, gdcBaseInterface;

{$R *.DFM}

{ Tgdc_dlgBaseStatementLine }

procedure Tgdc_dlgBaseStatementLine.BeforePost;
begin
  inherited;
  (gdcObject as TgdcBaseLine).SetCompanyAccount;
end;

function Tgdc_dlgBaseStatementLine.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := inherited CallSyncField(Field, SyncList) or
    ((Field.DataSet = gdcObject) and
      ((Field.FieldName = 'ACCOUNT') or
        (Field.FieldName = 'BANKCODE') or
        (Field.FieldName = 'COMPANYKEYLINE') or
        (Field.FieldName = 'CSUMNCU') or
        (Field.FieldName = 'CSUMCURR') or
        (Field.FieldName = 'DSUMNCU') or
        (Field.FieldName = 'DSUMCURR')));

end;

procedure Tgdc_dlgBaseStatementLine.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBASESTATEMENTLINE', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBASESTATEMENTLINE', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBASESTATEMENTLINE',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    cbDontRecalc.Checked := UserStorage.ReadBoolean(BuildComponentPath(cbDontRecalc),
      'DontRecalc', False);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBASESTATEMENTLINE', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBASESTATEMENTLINE', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBaseStatementLine.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBASESTATEMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBASESTATEMENTLINE', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBASESTATEMENTLINE',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.WriteBoolean(BuildComponentPath(cbDontRecalc),
      'DontRecalc', cbDontRecalc.Checked);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBASESTATEMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBASESTATEMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgBaseStatementLine.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  R: OleVariant;
  D: TDateTime;
  A, C, Company: String;
  Rate: Currency;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBASESTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBASESTATEMENTLINE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBASESTATEMENTLINE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if GetTID(gdcObject.FieldByName('documentkey')) > 0 then
    edDoc.Text := '№ ' + gdcObject.FieldByName('docnumberlink').AsString +
      ' от ' + gdcObject.FieldByName('documentdatelink').AsString
  else
    edDoc.Text := '';

  D := 0;
  A := '';
  C := '';
  Company := '';
  Rate := 0;

  if (gdcObject.MasterSource <> nil)
    and (gdcObject.MasterSource.DataSet is TgdcBase)
    and (gdcObject.MasterSource.DataSet.Active) then
  begin
    D := gdcObject.MasterSource.DataSet.FieldByName('documentdate').AsDateTime;
    A := gdcObject.MasterSource.DataSet.FieldByName('account').AsString;
    C := gdcObject.MasterSource.DataSet.FieldByName('currname').AsString;
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT com.name ' +
      'FROM gd_contact com  ' +
      'WHERE com.id = :DK ',
      TID2V(gdcObject.FieldByName('companykey')),
      R);

    if not VarIsEmpty(R) then
      Company := R[0, 0];

    Rate := gdcObject.MasterSource.DataSet.FieldByName('rate').AsCurrency;
  end else
  begin
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT d.documentdate, ac.account, c.name, bs.rate, com.name ' +
      'FROM gd_companyaccount ac ' +
      'JOIN bn_bankstatement bs ON bs.accountkey = ac.id ' +
      'JOIN gd_curr c ON c.id = ac.currkey ' +
      'JOIN gd_document d ON d.id = bs.documentkey ' +
      'JOIN gd_contact com ON ac.companykey = com.id ' +
      'WHERE bs.documentkey = :DK ',
      TID2V(gdcObject.FieldByName('bankstatementkey')),
      R);

    if not VarIsEmpty(R) then
    begin
      D := R[0, 0];
      A := R[1, 0];
      C := R[2, 0];
      if not VarIsNull(R[3, 0]) then
        Rate := R[3, 0];
      Company := R[4, 0];  
    end;
  end;

  if A > '' then
  begin
    lbInfo.Caption := Format('Строка выписки за %s, по счету: %s',
      [FormatDateTime('dd.mm.yy', D), A]);

    lbInfo2.Caption := Format('Организация: %s',
      [Company]);

    if C = '' then
      lbCurrency.Caption := 'Валюта: не указана.'
    else
    begin
      lbCurrency.Caption := Format('Валюта: %s', [C]);
      if Rate > 0 then
      begin
        lbCurrency.Caption := lbCurrency.Caption +
          Format('. Курс: %g', [Rate]);
      end;
    end;
  end else
  begin
    lbInfo.Caption := '';
    lbInfo2.Caption := Format('Организация: %s.',
      [IBLogin.CompanyName]);
    lbCurrency.Caption := '';
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBASESTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBASESTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgBaseStatementLine.SyncField(Field: TField;
  SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

var
  WasCreated: Boolean;
  MO: TgdcBase;
begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGBANKSTATEMENTLINE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENTLINE', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENTLINE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENTLINE',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENTLINE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  if ((Field.FieldName = 'ACCOUNT') or (Field.FieldName = 'BANKCODE')) and
    (Field.DataSet = gdcObject) and
    (gdcObject.FieldByName('account').AsString > '') and
    (gdcObject.FieldByName('bankcode').AsString > '') and
    (gdcObject.FieldByName('companykeyline').IsNull)
  then
  begin
    ibsql.Close;
    if ibsql.Transaction <> gdcObject.ReadTransaction then
      ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.companykey FROM gd_companyaccount ca ' +
      ' JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE b.bankcode = :bc AND ca.account = :account ';
    ibsql.ParamByName('bc').AsString := gdcObject.FieldByName('bankcode').AsString;
    ibsql.ParamByName('account').AsString := gdcObject.FieldByName('account').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      SetTID(gdcObject.FieldByName('companykeyline'), ibsql.FieldByName('companykey'))
    end;
    ibsql.Close;
  end else if  (Field.FieldName = 'COMPANYKEYLINE') and
    (Field.Dataset = gdcObject) and
    (gdcObject.FieldByName('account').AsString = '') and
    (gdcObject.FieldByName('bankcode').AsString = '') and
    (not gdcObject.FieldByName('companykeyline').IsNull)
  then
  begin
    ibsql.Close;
    if ibsql.Transaction <> gdcObject.ReadTransaction then
      ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.account, b.bankcode FROM gd_company c ' +
      ' LEFT JOIN gd_companyaccount ca ON c.companyaccountkey = ca.id ' +
      ' LEFT JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE c.contactkey = :ck ';
    SetTID(ibsql.ParamByName('ck'), gdcObject.FieldByName('companykeyline'));
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      gdcObject.FieldByName('account').AsString :=
        ibsql.FieldByName('account').AsString;
      gdcObject.FieldByName('bankcode').AsString :=
        ibsql.FieldByName('bankcode').AsString;
    end;
    ibsql.Close;

  end
  else if (Field.DataSet = gdcObject) and
    ((Field.FieldName = 'DSUMNCU') OR (Field.FieldName = 'DSUMCURR') OR
     (Field.FieldName = 'CSUMNCU') OR (Field.FieldName = 'CSUMCURR')) and
    (Field.AsCurrency > 0) and
    (not cbDontRecalc.Checked)
  then begin
    {Пересчет валютных сумм}
    MO := nil;
    WasCreated := False;
    try
      if Assigned(gdcObject.MasterSource) and (gdcObject.MasterSource.DataSet is TgdcBankStatement)
      then
        MO := gdcObject.MasterSource.DataSet as TgdcBankStatement
      else
      begin
        WasCreated := True;
        MO := TgdcBankStatement.CreateSingularByID(Self, gdcObject.Database,
           gdcObject.ReadTransaction, GetTID(gdcObject.FieldByName('parent')), '');
      end;

      if MO.FieldByName('rate').AsCurrency > 0 then
      begin
        if (Field.FieldName = 'DSUMNCU') and
          (SyncList.IndexOf(gdcObject.FieldByName('dsumcurr')) = -1) then
          gdcObject.FieldByName('dsumcurr').AsCurrency :=
            Field.AsCurrency / MO.FieldByName('rate').AsCurrency;

        if (Field.FieldName = 'CSUMNCU') and
           (SyncList.IndexOf(gdcObject.FieldByName('csumcurr')) = -1) then
          gdcObject.FieldByName('csumcurr').AsCurrency :=
            Field.AsCurrency / MO.FieldByName('rate').AsCurrency;

        if (Field.FieldName = 'CSUMCURR') and
          (SyncList.IndexOf(gdcObject.FieldByName('csumncu')) = -1) then
          gdcObject.FieldByName('csumncu').AsCurrency :=
            Field.AsCurrency * MO.FieldByName('rate').AsCurrency;

        if (Field.FieldName = 'DSUMCURR') and
          (SyncList.IndexOf(gdcObject.FieldByName('dsumncu')) = -1) then
          gdcObject.FieldByName('dsumncu').AsCurrency :=
            Field.AsCurrency * MO.FieldByName('rate').AsCurrency;
      end;
    finally
      if WasCreated and Assigned(MO) then
        MO.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENTLINE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENTLINE', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgBaseStatementLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgBaseStatementLine);

end.
