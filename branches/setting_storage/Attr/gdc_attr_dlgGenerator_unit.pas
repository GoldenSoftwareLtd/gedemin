unit gdc_attr_dlgGenerator_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  xCalculatorEdit, IBSQL, gdcBaseInterface;

type
  Tgdc_dlgGenerator = class(Tgdc_dlgGMetaData)
    dbeGeneratorName: TDBEdit;
    lblGeneratorName: TLabel;
    lblGeneratorValue: TLabel;
    edGeneratorValue: TEdit;
  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgGenerator: Tgdc_dlgGenerator;

implementation

uses at_classes, gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgGenerator.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGGENERATOR', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGGENERATOR', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGENERATOR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGENERATOR',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGENERATOR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //  добавляем USR$ префикс;
  with gdcObject do
    if (State = dsInsert) and
      (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('generatorname').AsString)) <> 1)
    then
      FieldByName('generatorname').AsString :=
        UserPrefix + FieldByName('generatorname').AsString;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGENERATOR', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGENERATOR', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgGenerator.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  IBSQL: TIBSQL;
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
  
  if gdcObject.State = dsEdit then
    dbeGeneratorName.Enabled := False;

  if dbeGeneratorName.Text <> '' then
  begin
    IBSQL := TIBSQL.Create(Self);
    try
      IBSQL.Transaction := gdcBaseManager.ReadTransaction;
      IBSQL.SQL.Text := 'SELECT GEN_ID(' + dbeGeneratorName.Text + ', 0) AS GenValue FROM RDB$GENERATORS';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount > 0 then
        edGeneratorValue.Text :=  IBSQL.FieldByName('GenValue').AsString
      else
        edGeneratorValue.Text := '0';
    finally
      IBSQL.Free;
    end;
  end else
    edGeneratorValue.Text := '0';

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
