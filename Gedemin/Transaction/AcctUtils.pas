
unit AcctUtils;

interface

uses
  Classes, Windows, stdctrls, Forms, Controls, Dialogs, gd_KeyAssoc;

type
  TgdvSumInfo = record
    Show: Boolean;
    DecDigits: Integer;
    Scale: Integer;
  end;

function IIF(Exp: Boolean; S1, S2: string): string;
// Функция возвращает сформированный кусок запроса для получения
//   необходимой части даты из переданного поля
// Если передан неизвестный ADateParam, возвращается просто AFieldName
function GetSQLForDateParam(const AFieldName: String; const ADateParam: String): String;
//Возвращает кол-во дес. знаков в сист. установках
function LocateDecDigits: Integer;

function GetNCUKey: Integer;
function GetNCUDecDigits: Integer;
function GetCurrDecDigits(const ACurrCode: String): Integer;
procedure ResetNCUCache;

function DisplayFormat(DecDig: Integer): string;
//заполняет список полей аналитик
procedure GetAnalyticsFields(const List: TList);
procedure GetAnalyticsFields2(const List: TList);
//проверяет список аналитик на присутствие в БД
procedure CheckAnalyticsList(const List: TStringList);
//Возвращает ид счета по алиасу для астивного плана счетов
function GetAccountKeyByAlias(const AnAlias: String): Integer; overload;
//Тоже самое, только для указанного плана счетов
function GetAccountKeyByAlias(const AnAlias: string; const AnAccountCardKey: Integer): Integer; overload;
function GetAlias(Id: Integer): string;
function GetAccountRUIDStringByAlias(Alias: string): string;
function GetAliasByRUIDString(RUID: string): string;

function GetCurrNameById(Id: Integer): string;

function IDList(List: TList): string; overload;
function IDList(List: TgdKeyArray): string; overload;

function AccountDialog(ComboBox: TCustomComboBox; ActiveAccount: Integer): Boolean;
procedure SetAccountIDs(AccountsComboBox: TCustomComboBox; var AccountIds: TList;
  AIncSubAccounts: Boolean; ShowMessage: Boolean = True);
procedure SaveHistory(ComboBox: TCustomComboBox);
//Возвращает ключ астивного плана счетов для указанной компании
function GetActiveAccount(CompanyKey: Integer): Integer;
procedure UpdateTabOrder(C: TWinControl);
// Возвращает дату последнего расчета сальдо, если сальдо не рассчитано вернет 0
function GetCalculatedBalanceDate: TDate;
// Возвращает список полей по которым не нужно строить бух. сальдо (формат - ';FIELDNAME1;FIELDNAME2;FIELDNAME3;')
function GetDontBalanceAnalyticList: String;

// Заполняет поля сальдо в Карте и Анализе счета
procedure SetSaldoValue(AValue: Currency; ADebit, ACredit: TEdit; ADecDigits: Integer);

function CheckActiveAccount(CompanyKey: Integer; AShowMessage: Boolean = True): Boolean;
function GetGeneralAnalyticField(const AnAccountID: Integer): String;

const
  cInputParam = '/*INPUT PARAM*/';
  IBDateDelta = 15018;              // Days between Delphi and InterBase dates

implementation

uses
  {$IFDEF GEDEMIN}
  at_classes, gdv_dlgAccounts_unit,
  {$ENDIF}
  AcctStrings, SysUtils, IBSQL, gd_security, gdcConstants,
  IBDatabase, gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , Graphics, Storages;

const
  cMaxHistoryQuantity = 30;

var
  FNCUKey: Integer;
  FCurrCode: String;
  FNCUDecDigits, FCurrDecDigits: Integer;

function IIF(Exp: Boolean; S1, S2: string): string;
begin
  if Exp then
    Result := S1
  else
    Result := S2;
end;

function GetSQLForDateParam(const AFieldName, ADateParam: String): String;
begin
  if ADateParam = '0' then
    Result := Format(EXTRACT_DAY, [AFieldName])
  else if ADateParam = '1' then
    Result := Format(EXTRACT_MONTH, [AFieldName])
  else if ADateParam = '3' then
    Result := Format(EXTRACT_YEAR, [AFieldName])
  else if ADateParam = '4' then
    Result := Format(EXTRACT_QUARTER, [AFieldName])
  else
    Result := AFieldName;
end;

function LocateDecDigits: integer;
const
  cCharCount = 3;
  cCharSize = 2;
var
  B: array[0..cCharCount*cCharSize - 1] of byte;
begin
  //Получаем кол-во символов после запятой
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_IDIGITS, @B, cCharCount);
  Result := StrToInt(PChar(@B));
end;

function GetNCUKey: Integer;
var
  q: TIBSQL;
begin
  if (FNCUKey = -1) and (gdcBaseManager <> nil) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
          'SELECT id, code, decdigits '#13#10 +
          'FROM gd_curr '#13#10 +
          'WHERE isncu <> 0';
      q.ExecQuery;
      if not q.EOF then
      begin
        FNCUKey := q.FieldByName('id').AsInteger;
        FNCUDecDigits := q.FieldByName('decdigits').AsInteger;
        FCurrCode := q.FieldByName('code').AsString;
        FCurrDecDigits := q.FieldByName('decdigits').AsInteger;
      end;
    finally
      q.Free;
    end;
  end;
  Result := FNCUKey;
end;

function GetNCUDecDigits: Integer;
begin
  if GetNCUKey > -1 then
    Result := FNCUDecDigits
  else
    Result := LocateDecDigits;
end;

function GetCurrDecDigits(const ACurrCode: String): Integer;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  if FCurrCode <> ACurrCode then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
          'SELECT decdigits '#13#10 +
          'FROM gd_curr '#13#10 +
          'WHERE code = :code';
      q.ParamByName('code').AsString := ACurrCode;
      q.ExecQuery;
      FCurrCode := ACurrCode;
      if q.EOF then
        FCurrDecDigits := LocateDecDigits
      else
        FCurrDecDigits := q.FieldByName('decdigits').AsInteger;
    finally
      q.Free;
    end;
  end;
  Result := FCurrDecDigits;
end;

procedure ResetNCUCache;
begin
  FNCUKey := -1;
  FCurrCode := '';
  FNCUDecDigits := 0;
  FCurrDecDigits := 0;
end;

function DisplayFormat(DecDig: Integer): string;
begin
  if DecDig > 0  then
    Result := '.' + StringOfChar('0', DecDig)
  else
    Result := '';
  Result := '#,##0' + Result
end;

procedure GetAnalyticsFields(const List: TList);
{$IFDEF GEDEMIN}
var
  R: TatRelation;
  I, Index: Integer;
{$ENDIF}

{$IFDEF GEDEMIN}
  function IndexOf(Relation: TatRelation; FieldName: string): integer;
  var
    I: Integer;
  begin
    Result := - 1;
    if Relation <> nil then
    begin
      for I :=  0 to Relation.RelationFields.Count - 1 do
      begin
        if Relation.RelationFields[I].FieldName = FieldName then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if List <> nil then
  begin
    List.Clear;
    R := atDatabase.Relations.ByRelationName('AC_ENTRY');
    if R <> nil then
      for i := 0 to R.RelationFields.Count - 1 do
        if Pos('USR$', UpperCase(R.RelationFields[I].FieldName)) = 1 then
          List.Add(R.RelationFields[I]);
    R := atDataBase.Relations.ByRelationName('AC_ACCOUNT');
    if R <> nil then
    begin
      for I := List.Count - 1 downto 0 do
      begin
        Index := IndexOf(R, TatRelationField(List[I]).FieldName);
        if Index = - 1 then List.Delete(I);
      end;
    end else
      List.Clear;
  end;
{$ENDIF}
end;

procedure GetAnalyticsFields2(const List: TList);
{$IFDEF GEDEMIN}
var
  R: TatRelation;
  F: TatRelationField;
  I, Index: Integer;
{$ENDIF}

{$IFDEF GEDEMIN}
  function IndexOf(Relation: TatRelation; FieldName: string): integer;
  var
    I: Integer;
  begin
    Result := - 1;
    if Relation <> nil then
    begin
      for I :=  0 to Relation.RelationFields.Count - 1 do
      begin
        if Relation.RelationFields[I].FieldName = FieldName then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if List <> nil then
  begin
    List.Clear;
    R := atDatabase.Relations.ByRelationName('AC_ENTRY');
    if R <> nil then
      for i := 0 to R.RelationFields.Count - 1 do
        if Pos('USR$', UpperCase(R.RelationFields[I].FieldName)) = 1 then
          List.Add(R.RelationFields[I]);
    R := atDataBase.Relations.ByRelationName('AC_ACCOUNT');
    if R <> nil then
    begin
      for I := List.Count - 1 downto 0 do
      begin
        Index := IndexOf(R, TatRelationField(List[I]).FieldName);
        if Index = - 1 then List.Delete(I);
      end;
    end else
      List.Clear;

    R := atDataBase.Relations.ByRelationName('GD_DOCUMENT');
    if R <> nil then
    begin
      F:= R.RelationFields.ByFieldName('documenttypekey');
      if F <> nil then
        List.Add(F);
    end;
  end;
{$ENDIF}
end;

procedure CheckAnalyticsList(const List: TStringList);
{$IFDEF GEDEMIN}
var
  R: TatRelation;
  I, Index: Integer;
{$ENDIF}

{$IFDEF GEDEMIN}
  function IndexOf(Relation: TatRelation; FieldName: string): integer;
  var
    I: Integer;
  begin
    Result := - 1;
    if Relation <> nil then
    begin
      for I :=  0 to Relation.RelationFields.Count - 1 do
      begin
        if Relation.RelationFields[I].FieldName = FieldName then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if List <> nil then
  begin
    R := atDatabase.Relations.ByRelationName('AC_ENTRY');
    if R <> nil then
    begin
      for I := List.Count - 1 downto 0 do
      begin
        Index := IndexOf(R, List.Names[I]);
        if Index = - 1 then List.Delete(I);
      end;
    end;
    R := atDataBase.Relations.ByRelationName('AC_ACCOUNT');
    if R <> nil then
    begin
      for I := List.Count - 1 downto 0 do
      begin
        Index := IndexOf(R, List.Names[I]);
        if Index = - 1 then List.Delete(I);
      end;
    end else
      List.Clear;
  end;
{$ENDIF}
end;

function GetAccountKeyByAlias(const AnAlias: string): Integer;
var
  SQL: TIBSQL;
begin
  Result := 0;
  //Поле алиас определено как варчар(20), поэтому если длинна переданного
  //параметра больше чем 20, то это заведомо неправильный алиас
  if Length(AnAlias) <= 20 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      SQL.SQL.Text :=
        'SELECT a1.id ' +
        'FROM ac_companyaccount ca JOIN ac_account a ' +
        '  ON a.id = ca.accountkey JOIN ac_account a1 ON a1.lb > a.lb AND ' +
        '    a1.rb <= a.rb ' +
        'WHERE ca.companykey = :companykey AND ca.IsActive = 1 AND a1.alias = :alias';

      SQL.ParamByName(fnAlias).AsString := AnAlias;
      SQL.ParamByName(fnCompanyKey).AsInteger := IBLogin.CompanyKey;
      SQL.ExecQuery;
      if not SQL.EOF then
        Result := SQL.FieldByName(fnId).AsInteger;
    finally
      SQL.Free;
    end;
  end;
end;

function GetAccountKeyByAlias(const AnAlias: string; const AnAccountCardKey: Integer): Integer;
var
  SQL: TIBSQL;
begin
  Result := 0;
  //Поле алиас определено как варчар(20), поэтому если длинна переданного
  //параметра больше чем 20, то это заведомо неправильный алиас
  if Length(AnAlias) <= 20 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      SQL.SQL.Text := 'SELECT a1.id FROM ac_account a ' +
        'LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND ' +
        'a1.rb <= a.rb AND a1.alias = :alias WHERE a.id = :id';

      SQL.ParamByName(fnAlias).AsString := AnAlias;
      SQL.ParamByName(fnId).AsInteger := AnAccountCardKey;
      SQL.ExecQuery;
      if not SQL.EOF then
        Result := SQL.FieldByName(fnId).AsInteger;
    finally
      SQL.Free;
    end;
  end;
end;

function GetAlias(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT a.alias FROM ac_account a ' +
      'WHERE a.id = :id';
    SQL.ParamByName('id').AsInteger := Id;
    SQl.ExecQuery;
    Result := SQl.FieldByName('alias').AsString;
  finally
    SQL.Free;
  end;
end;

function GetGeneralAnalyticField(const AnAccountID: Integer): String;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT rf.fieldname FROM ac_account a ' +
      '  JOIN at_relation_fields rf ON rf.id = a.analyticalfield ' +
      'WHERE ' +
      '  a.id = :id';
    q.ParamByName('id').AsInteger := AnAccountID;
    q.ExecQuery;
    if not q.Eof then
      Result := q.FieldByName('fieldname').AsString
    else
      Result := '';
  finally
    q.Free;
  end;
end;

function GetAccountRUIDStringByAlias(Alias: string): string;
var
  Id: Integer;
begin
  Result := '';
  Id := GetAccountKeyByAlias(Alias);
  if id > 0 then
  begin
    Result := gdcBaseManager.GetRUIDStringByID(ID);
  end;
end;

function GetAliasByRUIDString(RUID: string): string;
var
  Id: Integer;
begin
  Result := '';
  Id := gdcBaseManager.GetIDByRUIDString(RUID);
  if Id > 0 then
  begin
    Result := GetAlias(Id);
  end;
end;

function GetCurrNameById(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  Result := '';
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT name FROM gd_curr WHERE id = :id';
    SQL.ParamByName(fnId).AsInteger := Id;
    SQL.ExecQuery;
    if SQl.RecordCount > 0 then
      Result := SQL.FieldByName(fnName).AsString;
  finally
    SQL.Free;
  end;
end;

function IDList(List: TList): string;
var
  I: Integer;
begin
  Result := '';
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
    begin
      if Result > '' then
        Result := Result + ', ';
      Result := Result + IntToStr(Integer(List[I]));
    end;
  end;
end;

function IDList(List: TgdKeyArray): string;
var
  I: Integer;
begin
  Result := '';
  if Assigned(List) then
  begin
    for I := 0 to List.Count - 1 do
    begin
      if Result > '' then
        Result := Result + ', ';
      Result := Result + IntToStr(List.Keys[I]);
    end;
  end;
end;

function AccountDialog(ComboBox: TCustomComboBox; ActiveAccount: Integer): Boolean;
{$IFDEF GEDEMIN}
var
  F: Tgdv_dlgAccounts;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  F := Tgdv_dlgAccounts.Create(Application);
  try
    if ActiveAccount > 0 then
      F.ActiveAccountKey := ActiveAccount;

    F.Accounts := TComboBox(ComboBox).Text;
    Result := F.ShowModal = mrOk;
    if Result then
    begin
      TComboBox(ComboBox).Text := F.Accounts;
      ComboBox.Hint := TComboBox(ComboBox).Text;
    end;
  finally
    F.Free;
  end;
{$ELSE}
  Result := False;  
{$ENDIF}
end;

procedure SetAccountIDs(AccountsComboBox: TCustomComboBox; var AccountIds: TList;
  AIncSubAccounts: Boolean; ShowMessage: Boolean = True);
var
  S: TStrings;
  I: Integer;
  ID: Integer;
begin
  Assert(AccountIds <> nil, 'Список не инициализирован');

  if AccountIDs.Count = 0 then
  begin
    S := TStringList.Create;
    try
      S.Text := StringReplace(TComboBox(AccountsComboBox).Text, ',', #13#10, [rfReplaceAll]);
      for I := 0 to S.Count - 1 do
      begin
        Id := GetAccountKeyByAlias(Trim(S[I]));
        if Id = 0 then
        begin
          if ShowMessage then
          begin
            MessageBox(Application.Handle,
              PChar(Format(MSG_ACCOUNTINCORRECT, [Trim(S[I])])),
              PChar(MSG_WARNING),
              MB_OK or MB_ICONWARNING or MB_TASKMODAL);
          end;
          if AccountsComboBox.CanFocus then
            AccountsComboBox.SetFocus;
          AccountIDs.Clear;
          Abort;
        end else
          if AccountIDs.IndexOf(Pointer(Id)) = - 1 then
            AccountIDs.Add(Pointer(Id));
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure SaveHistory(ComboBox: TCustomComboBox);
var
  S1, S2: TStringList;
  I, J: Integer;
  Str: String;
begin
  S1 := TStringList.Create;
  S2 := TStringList.Create;
  try
    S1.Text := StringReplace(TComboBox(ComboBox).Text, ',', #13#10, [rfReplaceAll]);
    S1.Sort;
    for I := 0 to S1.Count - 1 do
    begin
      S1[I] := Trim(S1[I]);
    end;

    for I := 0 to ComboBox.Items.Count - 1 do
    begin
      S2.Text := StringReplace(TComboBox(ComboBox).Items[I], ',', #13#10, [rfReplaceAll]);
      S2.Sort;
      for J := 0 to S2.Count - 1 do
      begin
        S2[J] := Trim(S2[J]);
      end;

      if S2.Text = S1.Text then
      begin
        Str := TComboBox(ComboBox).Text;
        ComboBox.Items.Move(I, 0);
        TComboBox(ComboBox).Text := Str;
        Exit;
      end;
    end;

    if Trim(TComboBox(ComboBox).Text) > '' then
      ComboBox.Items.Insert(0, TComboBox(ComboBox).Text);

    if ComboBox.Items.Count > cMaxHistoryQuantity then
      ComboBox.Items.Delete(ComboBox.Items.Count - 1);
  finally
    S1.Free;
    S2.Free;
  end;
end;

function GetActiveAccount(CompanyKey: Integer): Integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT ca.accountkey FROM ac_companyaccount ca ' +
      'WHERE ca.companykey = :companykey AND ca.IsActive = 1';
    SQL.ParamByName(fnCompanyKey).AsInteger := CompanyKey;
    SQL.ExecQuery;
    if not SQL.EOF then
      Result := SQl.FieldByName(fnAccountKey).AsInteger
    else
      Result := -1;
  finally
    SQL.Free;
  end;
end;

function CheckActiveAccount(CompanyKey: Integer; AShowMessage: Boolean = True): Boolean;
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  ChartID: Integer;
begin
  if CompanyKey > -1 then
  begin
    if GetActiveAccount(CompanyKey) > -1 then
    begin
      Result := True;
      exit;
    end;
    
    try
      q := TIBSQL.Create(nil);
      Tr := TIBTransaction.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        q.Transaction := Tr;

        Tr.StartTransaction;

        q.SQL.Text := 'SELECT * FROM ac_companyaccount WHERE companykey=' +
          IntToStr(CompanyKey);
        q.ExecQuery;

        if q.EOF then
        begin
          q.Close;
          q.SQL.Text :=
            'SELECT id FROM ac_account WHERE accounttype=''C'' ' +
            'and (parent IS NULL) ' +
            'and (disabled IS NULL OR disabled = 0) ';
          q.ExecQuery;

          if not q.EOF then
          begin
            ChartID := q.Fields[0].AsInteger;
            q.Close;

            q.SQL.Text := 'INSERT INTO ac_companyaccount (companykey, accountkey, isactive) VALUES (:CK, :AK, 1) ';
            q.ParamByName('CK').AsInteger := CompanyKey;
            q.ParamByName('AK').AsInteger := ChartID;
            q.ExecQuery;
          end;
        end;

        q.Close;
        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    except
      on E: Exception do
      begin
        Application.ShowException(E);
      end;
    end;

    Result := GetActiveAccount(CompanyKey) > -1;
    if not Result and AShowMessage then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :id';
        SQL.ParamByName(fnId).AsInteger := CompanyKey;
        SQL.ExecQuery;
        MessageBox(0,
          PChar(Format(MSG_NOACTIVEACCOUTN, [SQL.FieldByName(fnName).AsString])),
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
      finally
        SQL.free;
      end;
    end;
  end
  else
  begin
    Result := False;
    if AShowMessage then
    begin
      MessageBox(Application.Handle, PChar(MSG_CHOOSECOMPANY), 'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;    
  end;
end;

procedure UpdateTabOrder(C: TWinControl);
var
  T, Index, Order: Integer;

  function GetNextIndex(ATop: Integer): Integer;
  var
    I: Integer;
    Delta: Integer;
  begin
    Delta := MaxInt;
    Result := -1;
    for I := 0 to C.ControlCount - 1 do
    begin
      if (ATop < C.Controls[I].Top) and (C.Controls[I].Top - ATop < Delta) then
      begin
        Result := I;
        Delta := C.Controls[I].Top - ATop;
      end;
    end;
  end;
begin
  T := Low(Integer);
  Order := 0;
  while GetNextIndex(T) > -1 do
  begin
    Index := GetNextIndex(T);
    T := C.Controls[Index].Top;
    if C.Controls[Index] is TWinControl then
    begin
      (C.Controls[Index] as TWinControl).TabOrder := Order;
      Inc(Order);
    end;
  end;
end;

function GetCalculatedBalanceDate: TDate;
var
  IBSQL: TIBSQL;
begin
  Result := 0;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := gdcBaseManager.ReadTransaction;
    IBSQL.SQL.Text := 'SELECT rdb$generator_name FROM rdb$generators WHERE rdb$generator_name = ''GD_G_ENTRY_BALANCE_DATE''';
    IBSQL.ExecQuery;
    if IBSQL.RecordCount <> 0 then
    begin
      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT GEN_ID(gd_g_entry_balance_date, 0) FROM rdb$database';
      IBSQL.ExecQuery;
      if IBSQL.Fields[0].AsInteger > 0 then
        Result := IBSQL.Fields[0].AsInteger - IBDateDelta;
    end;
  finally
    IBSQL.Free;
  end;
end;

function GetDontBalanceAnalyticList: String;
begin
  GetDontBalanceAnalyticList := '';
  if Assigned(GlobalStorage) then
    GetDontBalanceAnalyticList := GlobalStorage.ReadString(
      DontBalanceAnalyticStorageFolder, DontBalanceAnalyticStorageValue, '');
end;

procedure SetSaldoValue(AValue: Currency; ADebit, ACredit: TEdit; ADecDigits: Integer);
var
  C: Currency;
begin
  C:= 0;
  ADebit.Color:= $00E9E9E9;
  ACredit.Color:= $00E9E9E9;
  ADebit.Text := FormatFloat(DisplayFormat(ADecDigits), C);
  ACredit.Text := FormatFloat(DisplayFormat(ADecDigits), C);
  if AValue > 0 then
  begin
    ADebit.Text:= FormatFloat(DisplayFormat(ADecDigits), AValue);
    ADebit.Color:= clWhite;
  end
  else
    if AValue < 0 then
    begin
      ACredit.Text:= FormatFloat(DisplayFormat(ADecDigits), -AValue);
      ACredit.Color:= clWhite;
    end;
end;

initialization
  ResetNCUCache;
end.
