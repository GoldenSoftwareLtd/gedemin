// ShlTanya, 10.02.2019

unit gdcTemplate;

interface

uses
  gdcBase, DB, gdcBaseInterface;

type
  TgdcTemplate = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function CheckTheSameStatement: String; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList, Classes, IBSQL, gd_SetDatabase, Sysutils, gdcConstants,
  gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcTemplate]);
end;

{ TgdcTemplate }

function TgdcTemplate.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCTEMPLATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTEMPLATE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTEMPLATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTEMPLATE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTEMPLATE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM rp_reporttemplate WHERE UPPER(name)=UPPER(:name)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format(
      'SELECT id FROM rp_reporttemplate WHERE UPPER(name)=UPPER(''%s'')',
      [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTEMPLATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTEMPLATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcTemplate.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcTemplate.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'RP_REPORTTEMPLATE';
end;

class function TgdcTemplate.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

initialization
  RegisterGDCClass(TgdcTemplate, 'Шаблон отчета');

finalization
  UnregisterGdcClass(TgdcTemplate);
end.
