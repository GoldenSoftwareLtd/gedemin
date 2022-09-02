// ShlTanya, 30.01.2019

unit gdc_dlgBankStatementLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, IBDatabase,
  gsIBLookupComboBox, Db, IBCustomDataSet, Mask, gdcBase,
  DBCtrls, gdcContacts, gd_security, gd_security_body, IBSQL,
  gd_security_OperationConst, IBQuery,
  gdcStatement, gdc_dlgTR_unit, gdc_dlgBaseStatementLine_unit, gdcTree,
  Menus, ExtCtrls;

type
  Tgdc_dlgBankStatementLine = class(Tgdc_dlgBaseStatementLine)
    lbCCurr: TLabel;
    lbDCurr: TLabel;
    edtCSumCurr: TDBEdit;
    edtDSumCurr: TDBEdit;
    Label10: TLabel;
    iblkTransaction: TgsIBLookupComboBox;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgBankStatementLine: Tgdc_dlgBankStatementLine;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

{ Tgdc_dlgBankStatementLine }

procedure Tgdc_dlgBankStatementLine.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKSTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENTLINE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENTLINE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  lbDCurr.Enabled := not gdcObject.FieldByName('DSUMCURR').ReadOnly;
  edtDSumCurr.Enabled := not gdcObject.FieldByName('DSUMCURR').ReadOnly;
  lbCCurr.Enabled := not gdcObject.FieldByName('CSUMCURR').ReadOnly;
  edtCSumCurr.Enabled := not gdcObject.FieldByName('CSUMCURR').ReadOnly;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENTLINE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;


initialization
  RegisterFrmClass(Tgdc_dlgBankStatementLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgBankStatementLine);

end.
