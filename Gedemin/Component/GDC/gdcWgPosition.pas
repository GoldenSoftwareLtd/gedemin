
unit gdcWgPosition;

interface

uses
  Classes, gdcBaseInterface, gdcBase, gd_createable_form;

type
  TgdcWgPosition = class (TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
  end;

procedure Register;

implementation

uses
  DB, SysUtils, gdc_wage_frmPosition_unit, gdc_wage_dlgPosition_unit,
  gd_ClassList, gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcWgPosition]);
end;

{ TgdcWgPosition }

function TgdcWgPosition.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCWGPOSITION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCWGPOSITION', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCWGPOSITION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCWGPOSITION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCWGPOSITION' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM wg_position WHERE UPPER(name) = UPPER(:name)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM wg_position WHERE UPPER(name) = UPPER(''%s'')',
      [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCWGPOSITION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCWGPOSITION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcWgPosition.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_wage_dlgPosition';
end;

class function TgdcWgPosition.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcWgPosition.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'WG_POSITION';
end;

class function TgdcWgPosition.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_wage_frmPosition';
end;

initialization
  RegisterGDCClass(TgdcWgPosition, 'Должность');

finalization
  UnRegisterGDCClass(TgdcWgPosition);
end.
 
