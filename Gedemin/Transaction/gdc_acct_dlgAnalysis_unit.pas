// ShlTanya, 09.03.2019

unit gdc_acct_dlgAnalysis_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls, gsIBLookupComboBox,
  IBCustomDataSet, gdcBase, gdcMetaData, gdc_dlgTR_unit, IBDatabase,
  ExtCtrls;

type
  Tgdc_acct_dlgAnalysis = class(Tgdc_dlgTR)
    Label1: TLabel;
    iblcFields: TgsIBLookupComboBox;
    Label2: TLabel;
    edLName: TEdit;
    Label3: TLabel;
    edLShortName: TEdit;
    gdcTable: TgdcTable;
    gdcTableField: TgdcTableField;
    dsMeta: TDataSource;
    Label4: TLabel;
    edFieldIB: TEdit;
    Bevel1: TBevel;
  private
    { Private declarations }
  protected
    function DlgModified: Boolean; override;
    procedure Post; override;
  public
    { Public declarations }
    function TestCorrect: Boolean; override;
  end;

var
  gdc_acct_dlgAnalysis: Tgdc_acct_dlgAnalysis;

implementation

{$R *.DFM}

uses
  at_classes, gd_ClassList;

{ Tgdc_acct_dlgAnalysis }

function Tgdc_acct_dlgAnalysis.DlgModified: Boolean;
begin
  Result := True;
end;

procedure Tgdc_acct_dlgAnalysis.Post;

procedure AddField(const TableName, Domain: String);
begin
  gdcTableField.Insert;
  gdcTableField.FieldByName('RELATIONNAME').AsString := TableName;

  if Pos(UserPrefix, edFieldIB.Text) <> 1 then
    edFieldIB.Text := UserPrefix + edFieldIB.Text;

  gdcTableField.FieldByName('FIELDNAME').AsString := edFieldIB.Text;
  gdcTableField.FieldByName('LNAME').AsString := edLName.Text;
  gdcTableField.FieldByName('LSHORTNAME').AsString := edLShortName.Text;
  gdcTableField.FieldByName('FIELDSOURCE').AsString := Domain;
  gdcTableField.Post;
end;

  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ACCT_DLGANALYSIS', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ACCT_DLGANALYSIS', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGANALYSIS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGANALYSIS',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGANALYSIS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  gdcObject.Close;
  gdcTable.Close;
  gdcTable.Transaction.StartTransaction;
  try
    try
      gdcTable.Close;
      gdcTable.ParamByName('relationname').AsString := 'AC_ACCOUNT';
      gdcTable.Open;
      AddField('AC_ACCOUNT', 'DBOOLEAN');
      gdcTable.Close;
      gdcTable.ParamByName('relationname').AsString := 'AC_ENTRY';
      gdcTable.Open;
      AddField('AC_ENTRY', atDatabase.Fields.ByID(iblcFields.CurrentKeyInt).FieldName);
      gdcTable.Close;
    except
      if gdcTable.Transaction.InTransaction then
        gdcTable.Transaction.Rollback;
    end;
  finally
    if gdcTable.Transaction.InTransaction then
      gdcTable.Transaction.Commit;
    gdcObject.Open;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGANALYSIS', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGANALYSIS', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_acct_dlgAnalysis.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_ACCT_DLGANALYSIS', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_ACCT_DLGANALYSIS', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGANALYSIS') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGANALYSIS',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGANALYSIS' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := (iblcFields.CurrentKey > '') and (edFieldIB.Text > '') and
    (edLName.Text > '') and (edLShortName.Text > '');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGANALYSIS', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGANALYSIS', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_acct_dlgAnalysis);

finalization
  UnRegisterFrmClass(Tgdc_acct_dlgAnalysis);

end.
