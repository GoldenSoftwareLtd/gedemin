// ShlTanya, 10.02.2019

unit gdcFilter;

interface

uses
  Classes, gdcBase, gdcBaseInterface, sysutils, gd_KeyAssoc;

type
  TgdcComponentFilter = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
  end;

  TgdcSavedFilter = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

procedure Register;

implementation

uses
  DB, gd_ClassList, gdc_flt_frmMain_unit, gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [
    TgdcComponentFilter,
    TgdcSavedFilter
  ]);
end;

{ TgdcComponentFilter }

function TgdcComponentFilter.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCOMPONENTFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPONENTFILTER', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPONENTFILTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPONENTFILTER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPONENTFILTER' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT id FROM flt_componentfilter ' +
      'WHERE UPPER(fullname)=UPPER(:fullname) AND crc=:crc ' +
      '  AND UPPER(formname)=UPPER(:formname)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format(
      'SELECT id FROM flt_componentfilter WHERE UPPER(fullname)=UPPER(''%s'') AND crc=%d ' +
      '  AND UPPER(formname)=UPPER(''%s'')',
      [StringReplace(FieldByName('fullname').AsString, '''', '''''', [rfReplaceAll]),
       FieldByName('crc').AsInteger,
       StringReplace(FieldByName('formname').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPONENTFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPONENTFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcComponentFilter.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'fullname';
end;

class function TgdcComponentFilter.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'flt_componentfilter';
end;

class function TgdcComponentFilter.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_flt_frmMain';
end;

{ TgdcSavedFilter }

function TgdcSavedFilter.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCSAVEDFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSAVEDFILTER', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSAVEDFILTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSAVEDFILTER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSAVEDFILTER' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM flt_savedfilter WHERE name=:name AND componentkey=:componentkey AND userkey IS NOT DISTINCT FROM :userkey'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    if FieldByName('userkey').IsNull then
      Result := Format('SELECT id FROM flt_savedfilter WHERE name=''%s'' AND componentkey = %d AND userkey IS NULL',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
         TID264(FieldByName('componentkey'))])
    else
      Result := Format('SELECT id FROM flt_savedfilter WHERE name=''%s'' AND componentkey = %d AND userkey = %d',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
         TID264(FieldByName('componentkey')), TID264(FieldByName('userkey'))]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSAVEDFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSAVEDFILTER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcSavedFilter.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcSavedFilter.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'flt_savedfilter';
end;

class function TgdcSavedFilter.GetNotStreamSavedField(
  const IsReplicationMode: Boolean): String;
begin
  Result := inherited GetNotStreamSavedField(IsReplicationMode);
  if Result <> '' then
    Result := Result + ',';
  Result := Result + 'LASTEXTIME,READCOUNT';
end;

class function TgdcSavedFilter.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByComponentFilter;';
end;

class function TgdcSavedFilter.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_flt_frmMain';
end;

procedure TgdcSavedFilter.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByComponentFilter') then
    S.Add('z.componentkey = :ComponentKey');
end;

class function TgdcSavedFilter.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
//при загрузке с потока будем обновлять фильтр
  Result := True;
end;

procedure TgdcSavedFilter._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
begin
  if FieldByName('userkey').IsNull then
    inherited
  else
    raise Exception.Create('Фильтр ' + QuotedStr(FieldByName('name').AsString) + #13#10 +
      'Вы не можете сохранить в пространство имен пользовательский фильтр с пометкой "Фильтр только для меня"!');
end;

initialization
  RegisterGDCClass(TgdcComponentFilter, 'Фильтр');
  RegisterGDCClass(TgdcSavedFilter);

finalization
  UnregisterGdcClass(TgdcComponentFilter);
  UnregisterGdcClass(TgdcSavedFilter);
end.

 
