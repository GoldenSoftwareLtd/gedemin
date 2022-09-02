// ShlTanya, 30.01.2019

unit gdc_dlgBankCatalogueLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, ActnList, StdCtrls, Db, DBClient,
  gsIBLookupComboBox, DBCtrls, Mask, dmDatabase_unit, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, xDateEdits, IBSQL,
  gd_security_operationconst, gdcStatement, gdcContacts, FrmPlSvr,
  gdc_dlgTR_unit, gdcTree, Menus, xCalculatorEdit;

type
  Tgdc_dlgBankCatalogueLine = class(Tgdc_dlgTR)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    dbeDocNumber: TDBEdit;
    dbePaymentDest: TDBEdit;
    dbeFine: TxDBCalculatorEdit;
    dbeSumNCU: TxDBCalculatorEdit;
    dbeAccount: TDBEdit;
    dbeBankCode: TDBEdit;
    dbmComment: TDBMemo;
    ibcmbCompany: TgsIBLookupComboBox;
    dbeAcceptDate: TxDateDBEdit;
    edtDocLink: TEdit;
    Label10: TLabel;
    ibsql: TIBSQL;

  protected
    procedure BeforePost; override;

  public
    procedure SyncField(Field: TField; SyncList: TList); override;
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; override;

    procedure SetupRecord; override;
  end;

var
  gdc_dlgBankCatalogueLine: Tgdc_dlgBankCatalogueLine;

implementation

{$R *.DFM}

uses
  gd_CLassList, Gedemin_TLB, gdcBaseInterface;

{ Tgdc_dlgBankCatalogueLine }

procedure Tgdc_dlgBankCatalogueLine.BeforePost;
begin
  inherited;
  (gdcObject as TgdcBaseLine).SetCompanyAccount;
end;

function Tgdc_dlgBankCatalogueLine.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := inherited CallSyncField(Field, SyncList) or
    ((Field.DataSet = gdcObject) and
      ((Field.FieldName = 'ACCOUNT') or
        (Field.FieldName = 'BANKCODE') or
        (Field.FieldName = 'COMPANYKEYLINE')));
end;

procedure Tgdc_dlgBankCatalogueLine.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKCATALOGUELINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKCATALOGUELINE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKCATALOGUELINE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if GetTID(gdcObject.FieldByName('linkdocumentkey')) > 0 then
    edtDocLink.Text := '№ ' + gdcObject.FieldByName('docnumberlink').AsString +
      ' от ' + gdcObject.FieldByName('documentdatelink').AsString
  else
    edtDocLink.Text := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKCATALOGUELINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKCATALOGUELINE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBankCatalogueLine.SyncField(Field: TField;
  SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGBANKCATALOGUELINE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBANKCATALOGUELINE', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKCATALOGUELINE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKCATALOGUELINE',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKCATALOGUELINE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  if ((Field.FieldName = 'ACCOUNT') or (Field.FieldName = 'BANKCODE')) and
    (Field.Dataset = gdcObject) and
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

  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKCATALOGUELINE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKCATALOGUELINE', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgBankCatalogueLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgBankCatalogueLine);

end.
