// ShlTanya, 10.02.2019

{
  Места адм. территориального расположения
  TgdcPlace
}

unit gdcPlace;

interface

uses
  Classes, IBCustomDataSet, gdcBase, gdcTree, Forms,
  gd_createable_form, gdcBaseInterface;

type
  TgdcPlace = class(TgdcLBRBTree)
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
  DB,              IBSQL,                SysUtils,
  JclStrings,      gd_security,          gd_security_operationconst,
  Dialogs,         Controls,             IBDataBase,
  Windows,         dmDataBase_unit,      gdc_dlgPlace_unit,
  gdc_frmPlace_unit,                     gd_ClassList,
  gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcPlace]);
end;

{ TgdcPlace }

function TgdcPlace.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCPLACE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPLACE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPLACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPLACE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCPLACE(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPLACE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT p.id FROM gd_place p ' +
      'WHERE UPPER(p.name) = UPPER(:name) ' +
      '  AND UPPER(p.placetype) = UPPER(:placetype) ' +
      '  AND p.parent IS NOT DISTINCT FROM :parent '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
  begin
    Result :=
      'SELECT id FROM gd_place ' +
      'WHERE UPPER(name) = UPPER(''' +
        StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]) +
        ''')' +
      '  AND UPPER(placetype) = UPPER(''' +
        StringReplace(FieldByName('placetype').AsString, '''', '''''', [rfReplaceAll]) +
        ''')';
    if FieldByName('parent').IsNull then
      Result := Result + ' AND parent IS NULL'
    else
      Result := Result + ' AND parent = ' + FieldByName('parent').AsString;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPLACE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPLACE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcPlace.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgPlace';
end;

class function TgdcPlace.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcPlace.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_PLACE';
end;

class function TgdcPlace.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmPlace';
end;

initialization
  RegisterGdcClass(TgdcPlace, 'Административно-территориальная единица');

finalization
  UnregisterGdcClass(TgdcPlace);
end.


