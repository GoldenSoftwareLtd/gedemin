
{++

  Copyright (c) 2000-2014 by Golden Software of Belarus

  Module

    gdcConst.pas

  Abstract

    Business-classes for constants support.

  Author

    Anton Smirnov, Andrei Kireev

  Contact address

    support@gsbelarus.com

  Revisions history

    1.00    29.10.00    sai        Initial version.
    1.01    22.06.02    andreik    Revised.

--}

unit gdcConst;

interface

uses
  Classes,              IBCustomDataSet,           gdcBase,
  Forms,                gd_createable_form,        SysUtils,
  gdcBaseInterface,     Controls;

type
  TgdcConst = class(TgdcBase)
  private
    class function _QGetValue(const AnID: Integer; const AName: String;
      ADate: TDateTime; AUserKey, ACompanyKey: Integer): Variant;

  public
    function CheckTheSameStatement: String; override;

    ///////////////////////////////////////////////////////
    // является ли текущая запись константой, привязанной
    // к пользователю?
    function IsUser: Boolean;

    ///////////////////////////////////////////////////////
    // является ли текущая запись константой, привязанной
    // к компании?
    function IsCompany: Boolean;

    ///////////////////////////////////////////////////////
    // является ли текущая запись периодической константой?
    //
    function IsPeriod: Boolean;

    ///////////////////////////////////////////////////////
    // возвращает значение константы, заданной именем
    // если константы нет, то возвращается значение Unassigned
    // если константа периодическая, или привязанная к
    // пользователю, или -- к компании, то берутся, соответственно,
    // текущая дата, ключ текущего пользователя из ИБЛогин,
    // ключ текущей компании из ИБЛогин
    class function QGetValueByName(const AName: String): Variant;

    ///////////////////////////////////////////////////////
    // аналогично предыдущему, только дата указывается
    // непосредственно если константа не периодическая, то
    // просто возвращается ее значение
    class function QGetValueByNameAndDate(const AName: String; const ADate: TDateTime): Variant;

    ///////////////////////////////////////////////////////
    // аналогично QGetValueByName, только константа задается
    // идентификатором
    class function QGetValueByID(const AnID: TID): Variant;

    ///////////////////////////////////////////////////////
    // аналогично QGetValueByNameAndDate, только константа
    // задается идентификатором
    class function QGetValueByIDAndDate(const AnID: TID; const ADate: TDateTime): Variant;

    ///////////////////////////////////////////////////////
    // возвращает значение константы, заданной именем
    // позволяет указать конкретную дату, идентификатор
    // пользователя и компании, если константа периодическая
    // пользовательская или привязана к компании.
    // если указать 0 для даты -- будет взята текущая дата,
    // если указать -1 для идентификатора пользователя или
    // компании, будут взяты соответствующие ключи из
    // глобальной компоненты IBLogin
    class function QGetValueByName2(const AName: String; ADate: TDateTime; AUserKey, ACompanyKey: Integer): Variant;

    ///////////////////////////////////////////////////////
    // все аналогично предыдущей функции, только константа
    // задается идентификатором
    class function QGetValueByID2(const AnID: Integer; ADate: TDateTime; AUserKey, ACompanyKey: Integer): Variant;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function StringToDate(const S: String): TDateTime;
    class function StringToFloat(const S: String): Double;
  end;

  TgdcConstValue = class(TgdcBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure _DoOnNewRecord; override;

  public
    ///////////////////////////////////////////////////////
    // является ли текущая запись константой, привязанной
    // к пользователю?
    function IsUser: Boolean;

    ///////////////////////////////////////////////////////
    // является ли текущая запись константой, привязанной
    // к компании?
    function IsCompany: Boolean;

    ///////////////////////////////////////////////////////
    // является ли текущая запись периодической константой?
    //
    function IsPeriod: Boolean;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  EgdcConst = class(Exception);

procedure Register;

implementation

{ TgdcConst }

uses
  DB,                 IBSQL,                             gd_security,
  gdc_dlgConst_unit,  gdc_dlgConstValue_unit,            gdc_dlgAdminConstValue_unit,
  gdc_frmConst_unit,  gd_ClassList, gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcConst]);
  RegisterComponents('gdc', [TgdcConstValue]);
end;

function TgdcConst.isUser: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 2);
end;

function TgdcConst.isCompany: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 4);
end;

function TgdcConst.isPeriod: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 1);
end;

class function TgdcConst.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_CONST';
end;

class function TgdcConst.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcConst.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmConst';
end;

class function TgdcConst.QGetValueByName(const AName: String): Variant;
begin
  Result := QGetValueByName2(AName, 0, -1, -1);
end;

class function TgdcConst.QGetValueByNameAndDate(const AName: String;
  const ADate: TDateTime): Variant;
begin
  Result := QGetValueByName2(AName, ADate, -1, -1);
end;

class function TgdcConst.QGetValueByID(const AnID: TID): Variant;
begin
  Result := QGetValueByID2(AnID, 0, -1, -1);
end;

class function TgdcConst.QGetValueByIDAndDate(const AnID: TID;
  const ADate: TDateTime): Variant;
begin
  Result := QGetValueByID2(AnID, ADate, -1, -1);
end;

class function TgdcConst.QGetValueByID2(const AnID: Integer;
  ADate: TDateTime; AUserKey, ACompanyKey: Integer): Variant;
begin
  Result := _QGetValue(AnID, '', ADate, AUserKey, ACompanyKey);
end;

class function TgdcConst.QGetValueByName2(const AName: String;
  ADate: TDateTime; AUserKey, ACompanyKey: Integer): Variant;
begin
  Result := _QGetValue(-1, AName, ADate, AUserKey, ACompanyKey);
end;

function TgdcConst.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCONST', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONST', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONST' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM gd_const WHERE UPPER(name) = UPPER(:name)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := 'SELECT id FROM gd_const WHERE UPPER(name) = ''' +
      StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]) + '''';
       
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONST', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONST', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcConst.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgConst';
end;

class function TgdcConst._QGetValue(const AnID: Integer;
  const AName: String; ADate: TDateTime; AUserKey,
  ACompanyKey: Integer): Variant;
var
  q: TIBSQL;
  S, DT: String;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));
  Assert(gdcBaseManager.ReadTransaction.Active);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    
    if AnID > -1 then
    begin
      q.SQL.Text := 'SELECT * FROM gd_const WHERE id=:id';
      q.ParamByName('id').AsInteger := AnID;
    end else
    begin
      q.SQL.Text := 'SELECT * FROM gd_const WHERE UPPER(name)=:name';
      q.ParamByName('name').AsString := AnsiUpperCase(AName);
    end;

    q.ExecQuery;

    if q.EOF then
      raise EgdcConst.Create('Invalid constant ID');

    S := 'SELECT FIRST 1 constvalue FROM gd_constvalue WHERE constkey = ' +
      q.FieldByName('id').AsString + ' ';

    if (q.FieldByName('consttype').AsInteger and 2) <> 0 then
    begin
      if AUserKey = -1 then
        AUserKey := IBLogin.ContactKey;

      S := Format('%s AND userkey = %d ', [S, AUserKey]);
    end;

    if (q.FieldByName('consttype').AsInteger and 4) <> 0 then
    begin
      if ACompanyKey <> -1 then
        S := Format('%s AND companykey = %d ', [S, ACompanyKey])
      else
        S := Format('%s AND companykey IN (%s) ', [S, IBLogin.HoldingList]);
    end;

    if (q.FieldByName('consttype').AsInteger and 1) <> 0 then
    begin
      if ADate = 0 then
        ADate := SysUtils.Date;

      S := Format('%s AND constdate < :d ORDER BY constdate DESC', [S]);
    end;

    DT := q.FieldByName('datatype').AsString;

    q.Close;
    q.SQL.Text := S;
    q.Prepare;
    if q.Params.Count = 1 then
      q.Params[0].AsDateTime := Trunc(ADate) + 1;
    q.ExecQuery;

    if q.EOF then
      Result := Unassigned
    else begin
      if DT = 'D' then
        Result := StringToDate(q.Fields[0].AsString)
      else if DT = 'N' then
        Result := StringToFloat(q.Fields[0].AsString)
      else
        Result := q.Fields[0].AsString;
    end;
  finally
    q.Free;
  end;
end;

class function TgdcConst.StringToDate(const S: String): TDateTime;
var
  Tmp: String;
  D, M, Y, B, E: Word;
begin
  try
    B := 1;
    E := 1;
    Tmp := Trim(S);
    while (E < Length(Tmp)) and (Tmp[E] in ['0'..'9']) do
      Inc(E);
    D := StrToInt(System.Copy(Tmp, B, E - B));
    Inc(E);
    B := E;
    while (E < Length(Tmp)) and (Tmp[E] in ['0'..'9']) do
      Inc(E);
    M := StrToInt(System.Copy(Tmp, B, E - B));
    Y := StrToInt(System.Copy(Tmp, E + 1, 255));
    Result := EncodeDate(Y, M, D);
  except
    raise Exception.Create('Invalid date value');
  end;
end;

class function TgdcConst.StringToFloat(const S: String): Double;
begin
  Result := StrToFloat(StringReplace(Trim(S),
    '.', DecimalSeparator, []));
end;

{ TgdcConstValue }

function TgdcConstValue.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCONSTVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONSTVALUE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONSTVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONSTVALUE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONSTVALUE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    ' SELECT ' +
    '   z.id, ' +
    '   z.userkey, ' +
    '   z.companykey, ' +
    '   z.constkey, ' +
    '   z.constdate, ' +
    '   z.constvalue, ' +
    '   z.editorkey, ' +
    '   z.editiondate, ' + 
    '   u.name as username, ' +
    '   c.name as companyname, ' +
    '   t.name as constname, ' +
    '   t.datatype as datatype, ' +
    '   t.consttype as consttype ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONSTVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONSTVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcConstValue.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCONSTVALUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONSTVALUE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONSTVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONSTVALUE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONSTVALUE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    ' FROM gd_constvalue z ' +
    '   JOIN gd_const t ON t.id = z.constkey ' +
    '   LEFT JOIN gd_contact u ON u.id = z.userkey ' +
    '   LEFT JOIN gd_contact c ON c.id = z.companykey ';

  FSQLSetup.Ignores.AddAliasName('u');
  FSQLSetup.Ignores.AddAliasName('c');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONSTVALUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONSTVALUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcConstValue._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCONSTVALUE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONSTVALUE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONSTVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONSTVALUE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONSTVALUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(MasterSource) and (MasterSource.DataSet is TgdcConst) then
    with MasterSource.DataSet as TgdcConst do
  begin
    if IsUser then
      Self.FieldByName('userkey').AsInteger := IBLogin.ContactKey
    else
      Self.FieldByName('userkey').Clear;

    if IsCompany then
      Self.FieldByName('companykey').AsInteger := IBLogin.CompanyKey
    else
      Self.FieldByName('companykey').Clear;

    if IsPeriod then
      Self.FieldByName('constdate').AsDateTime := SysUtils.Date;

    Self.FieldByName('consttype').AsInteger := FieldByName('consttype').AsInteger;
    Self.FieldByName('constname').AsString := FieldByName('name').AsString;
    Self.FieldByName('datatype').AsString := FieldByName('datatype').AsString;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONSTVALUE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONSTVALUE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcConstValue.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByConst') then
    S.Add(' z.constkey = :constkey ');

  if not ((IBLogin <> nil) and IBLogin.IsUserAdmin) then
  begin
    S.Add(' (z.userkey = ' + IntToStr(IBLogin.ContactKey) + ' or z.userkey IS NULL) ');
    S.Add(' (z.companykey IN (' + IBLogin.HoldingList + ') or z.companykey IS NULL) ');
  end;
end;

class function TgdcConstValue.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_CONSTVALUE';
end;

class function TgdcConstValue.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'constvalue';
end;

class function TgdcConstValue.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

function TgdcConstValue.IsCompany: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 4);
end;

function TgdcConstValue.IsPeriod: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 1);
end;

function TgdcConstValue.IsUser: Boolean;
begin
  Result := Boolean(FieldByName('consttype').AsInteger and 2);
end;

class function TgdcConstValue.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByConst;';
end;

class function TgdcConstValue.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  if (IBLogin <> nil) and IBLogin.IsUserAdmin then
    Result := 'Tgdc_dlgAdminConstValue'
  else
    Result := 'Tgdc_dlgConstValue';
end;

initialization
  RegisterGdcClass(TgdcConst);
  RegisterGdcClass(TgdcConstValue);

finalization
  UnRegisterGdcClass(TgdcConst);
  UnRegisterGdcClass(TgdcConstValue);
end.
