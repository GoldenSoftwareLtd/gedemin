// ShlTanya, 30.01.2019

unit gdc_dlgBankCatalogue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgHGR_unit, Db, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gsIBCtrlGrid, ComCtrls, ToolWin, ExtCtrls, StdCtrls, gsIBLookupComboBox,
  Mask, DBCtrls, gdcClasses, gd_security, gd_security_body, xDateEdits,
  gd_security_OperationConst, IBSQL, gdcStatement, gdcContacts,
  IBCustomDataSet, gdcBase, FrmPlSvr, TB2Item, TB2Dock, TB2Toolbar,
  IBDatabase, gdcTree, Menus;

type
  Tgdc_dlgBankCatalogue = class(Tgdc_dlgHGR)
    Label1: TLabel;
    Label2: TLabel;
    dbeType: TDBEdit;
    ibcmbAccount: TgsIBLookupComboBox;
    ibsql: TIBSQL;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    OldBeforePost: TDataSetNotifyEvent;
    procedure gdcBaseLineBeforePost(DataSet: TDataSet);

  public
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; override;
    procedure SyncField(Field: TField; SyncList: TList); override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgBankCatalogue: Tgdc_dlgBankCatalogue;

implementation

uses dmDataBase_unit,  gd_ClassList, Storages, Gedemin_TLB, gdcBaseInterface;

{$R *.DFM}

procedure Tgdc_dlgBankCatalogue.gdcBaseLineBeforePost(DataSet: TDataSet);
begin
  if Assigned(OldBeforePost) then
    OldBeforePost(DataSet);

  (DataSet as TgdcBaseLine).SetCompanyAccount;
end;

procedure Tgdc_dlgBankCatalogue.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKCATALOGUE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKCATALOGUE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKCATALOGUE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  ActivateTransaction(gdcObject.Transaction);
  ibcmbAccount.Condition := 'CompanyKey = ' + TID2S(IBLogin.CompanyKey);

  FgdcDetailObject := nil;
  for I := 0 to gdcObject.DetailLinksCount - 1 do
    if (gdcObject.DetailLinks[I] is TgdcBankCatalogueLine) then
    begin
      FgdcDetailObject := gdcObject.DetailLinks[I];
      Break;
    end;

  if not Assigned(FgdcDetailObject) then
  begin
    FgdcDetailObject := TgdcBankCatalogueLine.Create(Self);
    FgdcDetailObject.Close;
    FgdcDetailObject.SubSet := 'ByParent';
    FgdcDetailObject.DetailField := 'parent';
    FgdcDetailObject.MasterField := 'id';
    FgdcDetailObject.MasterSource := dsgdcBase;
    FgdcDetailObject.ReadTransaction := gdcObject.Transaction;
    FgdcDetailObject.Transaction := gdcObject.Transaction;
    FgdcDetailObject.Open;
  end;

  dsDetail.DataSet := FgdcDetailObject;
  OldBeforePost := FgdcDetailObject.BeforePost;
  FgdcDetailObject.BeforePost := gdcBaseLineBeforePost;

  SetupGrid;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKCATALOGUE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKCATALOGUE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgBankCatalogue.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKCATALOGUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKCATALOGUE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKCATALOGUE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  ActivateTransaction(gdcObject.Transaction);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKCATALOGUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKCATALOGUE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBankCatalogue.SyncField(Field: TField; SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGBANKCATALOGUE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBANKCATALOGUE', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKCATALOGUE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKCATALOGUE',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKCATALOGUE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  if ((Field.FieldName = 'ACCOUNT') or (Field.FieldName = 'BANKCODE')) and
    (Field.DataSet = gdcDetailObject) and
    (gdcDetailObject.FieldByName('account').AsString > '') and
    (gdcDetailObject.FieldByName('bankcode').AsString > '') and
    (gdcDetailObject.FieldByName('companykeyline').IsNull)
  then
  begin
    ibsql.Close;
    if ibsql.Transaction <> gdcObject.ReadTransaction then
      ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.companykey FROM gd_companyaccount ca ' +
      ' JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE b.bankcode = :bc AND ca.account = :account ';
    ibsql.ParamByName('bc').AsString := gdcDetailObject.FieldByName('bankcode').AsString;
    ibsql.ParamByName('account').AsString := gdcDetailObject.FieldByName('account').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      SetTID(gdcDetailObject.FieldByName('companykeyline'), ibsql.FieldByName('companykey'))
    end;
    ibsql.Close;
  end else if  (Field.FieldName = 'COMPANYKEYLINE') and
    (Field.Dataset = gdcDetailObject) and
    (gdcDetailObject.FieldByName('account').AsString = '') and
    (gdcDetailObject.FieldByName('bankcode').AsString = '') and
    (not gdcDetailObject.FieldByName('companykeyline').IsNull)
  then
  begin
    ibsql.Close;
    if ibsql.Transaction <> gdcDetailObject.ReadTransaction then
      ibsql.Transaction := gdcDetailObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.account, b.bankcode FROM gd_company c ' +
      ' LEFT JOIN gd_companyaccount ca ON c.companyaccountkey = ca.id ' +
      ' LEFT JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE c.contactkey = :ck ';
    SetTID(ibsql.ParamByName('ck'), gdcDetailObject.FieldByName('companykeyline'));
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      gdcDetailObject.FieldByName('account').AsString :=
        ibsql.FieldByName('account').AsString;
      gdcDetailObject.FieldByName('bankcode').AsString :=
        ibsql.FieldByName('bankcode').AsString;
    end;
    ibsql.Close;

  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKCATALOGUE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKCATALOGUE', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgBankCatalogue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//Вернем старый ивент
  FgdcDetailObject.BeforePost := OldBeforePost;
  inherited;
end;

function Tgdc_dlgBankCatalogue.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := inherited CallSyncField(Field, SyncList) or
    ((Field.DataSet = gdcDetailObject) and
      ((Field.FieldName = 'ACCOUNT') or
        (Field.FieldName = 'BANKCODE') or
        (Field.FieldName = 'COMPANYKEYLINE')));
end;

initialization
  RegisterFrmClass(Tgdc_dlgBankCatalogue);

finalization
  UnRegisterFrmClass(Tgdc_dlgBankCatalogue);

end.
