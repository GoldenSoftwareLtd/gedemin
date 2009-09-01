
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
  protected
    function CreateDialogForm: TCreateableForm; override;
    function CheckTheSameStatement: String; override;

  public
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
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

  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM gd_place ' +
      ' WHERE UPPER(name) = ''%s'' ',
      [StringReplace(
        AnsiUpperCase(FieldByName('name').AsString), '''', '"', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPLACE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPLACE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcPlace.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCPLACE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPLACE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPLACE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPLACE',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPLACE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_dlgPlace.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPLACE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPLACE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcPlace.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Административно-территориальная единица';
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
  RegisterGdcClass(TgdcPlace);

finalization
  UnRegisterGdcClass(TgdcPlace);
end.


