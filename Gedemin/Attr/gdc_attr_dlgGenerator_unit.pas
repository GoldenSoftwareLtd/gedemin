unit gdc_attr_dlgGenerator_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  IBSQL, gdcBaseInterface;

type
  Tgdc_dlgGenerator = class(Tgdc_dlgGMetaData)
    dbeGeneratorName: TDBEdit;
    lblGeneratorName: TLabel;
    lblGeneratorValue: TLabel;
    edGeneratorValue: TEdit;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgGenerator: Tgdc_dlgGenerator;

implementation

uses
  gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgGenerator.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGGENERATOR', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGGENERATOR', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGENERATOR',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (gdcObject.State = dsEdit) and (dbeGeneratorName.Text > '') then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT GEN_ID(' + dbeGeneratorName.Text + ', 0) AS GenValue FROM RDB$DATABASE';
      q.ExecQuery;
      if not q.EOF then
        edGeneratorValue.Text := q.Fields[0].AsString
      else
        edGeneratorValue.Text := '';
    finally
      q.Free;
    end;
  end else
    edGeneratorValue.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGENERATOR', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGENERATOR', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgGenerator);

finalization
  UnRegisterFrmClass(Tgdc_dlgGenerator);
end.
