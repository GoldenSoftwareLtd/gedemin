// ShlTanya, 09.03.2019

unit AcctUtils;

interface

uses
  Classes, Windows, stdctrls, Forms, Controls, Dialogs, gd_KeyAssoc, gdcBaseInterface;

type
  TgdvSumInfo = record
    Show: Boolean;
    DecDigits: Integer;
    Scale: Integer;
  end;

function IIF(Exp: Boolean; S1, S2: string): string;
// ������� ���������� �������������� ����� ������� ��� ���������
//   ����������� ����� ���� �� ����������� ����
// ���� ������� ����������� ADateParam, ������������ ������ AFieldName
function GetSQLForDateParam(const AFieldName: String; const ADateParam: String): String;
//���������� ���-�� ���. ������ � ����. ����������
function LocateDecDigits: Integer;

function GetNCUKey: TID;
function GetNCUDecDigits: Integer;
function GetCurrDecDigits(const ACurrCode: String): Integer;
procedure ResetNCUCache;
function GetEqKey: TID;

function DisplayFormat(DecDig: Integer): string;
//��������� ������ ����� ��������
procedure GetAnalyticsFieldsExtended(const List: TList; const ShowAddAnaliseLines: boolean = True);
procedure GetAnalyticsFields(const List: TList);
procedure GetAnalyticsFieldsWithoutAddAnaliseLines(const List: TList);
//��������� ������ �������� �� ����������� � ��
procedure CheckAnalyticsList(const List: TStringList);
//���������� �� ����� �� ������ ��� ��������� ����� ������
function GetAccountKeyByAlias(const AnAlias: String): TID; overload;
//���� �����, ������ ��� ���������� ����� ������
function GetAccountKeyByAlias(const AnAlias: string; const AnAccountCardKey: TID): TID; overload;
function GetAlias(Id: TID): string;
function GetAccountRUIDStringByAlias(Alias: string): string;
function GetAliasByRUIDString(RUID: string): string;

function GetCurrNameById(Id: TID): string;

function IDList(List: TList; Context: string): string; overload;
function IDList(List: TgdKeyArray): string; overload;

function AccountDialog(ComboBox: TCustomComboBox; ActiveAccount: TID): Boolean;
procedure SetAccountIDs(AccountsComboBox: TCustomComboBox; var AccountIds: TList;
  AIncSubAccounts: Boolean; Context: String; ShowMessage: Boolean = True);
procedure SaveHistory(ComboBox: TCustomComboBox);
//���������� ���� ��������� ����� ������ ��� ��������� ��������
function GetActiveAccount(CompanyKey: TID): TID;
//���������� ������ ������ ��������� ����� ������
function GetAccounts: String;

procedure UpdateTabOrder(C: TWinControl);
// ���������� ���� ���������� ������� ������, ���� ������ �� ���������� ������ 0
function GetCalculatedBalanceDate: TDate;
// ���������� ������ ����� �� ������� �� ����� ������� ���. ������ (������ - ';FIELDNAME1;FIELDNAME2;FIELDNAME3;')
function GetDontBalanceAnalyticList: String;

// ��������� ���� ������ � ����� � ������� �����
procedure SetSaldoValue(AValue: Currency; ADebit, ACredit: TEdit; ADecDigits: Integer);

function CheckActiveAccount(CompanyKey: TID; AShowMessage: Boolean = True): Boolean;
function GetGeneralAnalyticField(const AnAccountID: TID): String;

function GetCurrRate(ForDate: TDateTime; ValidDays: Integer; RegulatorKey: OleVariant;
  FromCurrKey: OleVariant; ToCurrKey: OleVariant; CrossCurrKey: OleVariant; Amount: Currency;
  ForceCross: WordBool; UseInverted: WordBool; RaiseException: WordBool): Double;

const
  cInputParam = '/*INPUT PARAM*/';
  IBDateDelta = 15018;              // Days between Delphi and InterBase dates

implementation

uses
  {$IFDEF GEDEMIN}
  at_classes, gdv_dlgAccounts_unit,
  {$ENDIF}
  AcctStrings, SysUtils, IBSQL, gd_security, gdcConstants,
  IBDatabase
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , Graphics, Storages;

const
  cMaxHistoryQuantity = 30;

var
  FNCUKey: TID;
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
  //�������� ���-�� �������� ����� �������
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_IDIGITS, @B, cCharCount);
  Result := StrToInt(PChar(@B));
end;

function GetNCUKey: TID;
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
        FNCUKey := GetTID(q.FieldByName('id'));
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

function GetEqKey: TID;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT id FROM gd_curr WHERE iseq <> 0';
    q.ExecQuery;

    if q.EOF then
      Result := -1
    else
      Result := GetTID(q.FieldByName('id'));
  finally
    q.Free;
  end;
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
begin
  GetAnalyticsFieldsExtended(List, True);
end;

procedure GetAnalyticsFieldsWithoutAddAnaliseLines(const List: TList);
begin
  GetAnalyticsFieldsExtended(List, False);
end;

procedure GetAnalyticsFieldsExtended(const List: TList; const ShowAddAnaliseLines: boolean = True);
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

    if ShowAddAnaliseLines then
    begin
      F := atDatabase.FindRelationField(AC_ENTRY, 'CURRKEY');
      if F <> nil then
      begin
        List.Add(F);
      end;

      F := atDatabase.FindRelationField(AC_ENTRY, 'MASTERDOCKEY');
      if F <> nil then
      begin
        F := atDatabase.FindRelationField('GD_DOCUMENT', 'DOCUMENTTYPEKEY');
        List.Add(F);
      end;

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

function GetAccountKeyByAlias(const AnAlias: string): TID;
var
  SQL: TIBSQL;
begin
  Result := 0;
  //���� ����� ���������� ��� ������(20), ������� ���� ������ �����������
  //��������� ������ ��� 20, �� ��� �������� ������������ �����
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
        'WHERE ca.companykey = :companykey AND ca.IsActive = 1 AND a1.alias = :alias ';

      SQL.ParamByName(fnAlias).AsString := AnAlias;
      SetTID(SQL.ParamByName(fnCompanyKey), IBLogin.CompanyKey);
      SQL.ExecQuery;
      if not SQL.EOF then
        Result := GettID(SQL.FieldByName(fnId));
    finally
      SQL.Free;
    end;
  end;
end;

function GetAccountKeyByAlias(const AnAlias: string; const AnAccountCardKey: TID): TID;
var
  SQL: TIBSQL;
begin
  Result := 0;
  //���� ����� ���������� ��� ������(20), ������� ���� ������ �����������
  //��������� ������ ��� 20, �� ��� �������� ������������ �����
  if Length(AnAlias) <= 20 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      SQL.SQL.Text := 'SELECT a1.id FROM ac_account a ' +
        'LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND ' +
        'a1.rb <= a.rb AND a1.alias = :alias WHERE a.id = :id';

      SQL.ParamByName(fnAlias).AsString := AnAlias;
      SetTID(SQL.ParamByName(fnId), AnAccountCardKey);
      SQL.ExecQuery;
      if not SQL.EOF then
        Result := GetTID(SQL.FieldByName(fnId));
    finally
      SQL.Free;
    end;
  end;
end;

function GetAlias(Id: TID): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT a.alias FROM ac_account a ' +
      'WHERE a.id = :id';
    SetTID(SQL.ParamByName('id'), Id);
    SQl.ExecQuery;
    Result := SQl.FieldByName('alias').AsString;
  finally
    SQL.Free;
  end;
end;

function GetGeneralAnalyticField(const AnAccountID: TID): String;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT LIST(rf.fieldname, '', '') fieldname ' +
      'FROM  ac_accanalyticsext aa ' +
      '  JOIN at_relation_fields rf ON aa.valuekey = rf.id ' +
      'WHERE aa.accountkey = :id ' +
      'GROUP BY aa.accountkey  ';

    SetTID(q.ParamByName('id'), AnAccountID);
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
  Id: TID;
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
  Id: TID;
begin
  Result := '';
  Id := gdcBaseManager.GetIDByRUIDString(RUID);
  if Id > 0 then
  begin
    Result := GetAlias(Id);
  end;
end;

function GetCurrNameById(Id: TID): string;
var
  SQL: TIBSQL;
begin
  Result := '';
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT name FROM gd_curr WHERE id = :id';
    SetTID(SQL.ParamByName(fnId), Id);
    SQL.ExecQuery;
    if SQl.RecordCount > 0 then
      Result := SQL.FieldByName(fnName).AsString;
  finally
    SQL.Free;
  end;
end;

function IDList(List: TList; Context: string): string;
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
      Result := Result + TID2S(GetTID(List[I], Context));
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
      Result := Result + TID2S(List.Keys[I]);
    end;
  end;
end;

function AccountDialog(ComboBox: TCustomComboBox; ActiveAccount: TID): Boolean;
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
  AIncSubAccounts: Boolean; Context: string; ShowMessage: Boolean = True);
var
  S: TStrings;
  I: Integer;
  ID: TID;
begin
  Assert(AccountIds <> nil, '������ �� ���������������');

  AccountIDs.Clear;

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
        Abort;
      end else
        if AccountIDs.IndexOf(TID2Pointer(Id, Context)) = - 1 then
          AccountIDs.Add(TID2Pointer(Id, Context));
    end;
  finally
    S.Free;
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

function GetActiveAccount(CompanyKey: TID): TID;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT ca.accountkey FROM ac_companyaccount ca ' +
      'WHERE ca.companykey = :companykey AND ca.IsActive = 1';
    SetTID(SQL.ParamByName(fnCompanyKey), CompanyKey);
    SQL.ExecQuery;
    if not SQL.EOF then
      Result := GetTID(SQl.FieldByName(fnAccountKey))
    else
      Result := -1;
  finally
    SQL.Free;
  end;
end;

function GetAccounts: String;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT '#13#10 +
      '  LIST(a.id, '','') '#13#10 +
      'FROM '#13#10 +
      '  ac_account aparent '#13#10 +
      '  JOIN ac_companyaccount ca '#13#10 +
      '    ON aparent.id = ca.accountkey AND ca.companykey = :companykey AND ca.isactive = 1 '#13#10 +
      '  JOIN ac_account a '#13#10 +
      '    ON a.lb >= aparent.lb AND a.rb <= aparent.rb '#13#10 +
      'WHERE '#13#10 +
      '  a.accounttype IN (''A'', ''S'')';
    SetTID(SQL.ParamByName('companykey'), IBLogin.CompanyKey);
    SQL.ExecQuery;
    if not SQL.EOF then
      Result := SQL.Fields[0].AsString
    else
      Result := '';
  finally
    SQL.Free;
  end;
end;

function CheckActiveAccount(CompanyKey: TID; AShowMessage: Boolean = True): Boolean;
var
  SQL, q: TIBSQL;
  Tr: TIBTransaction;
  ChartID: TID;
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
          TID2S(CompanyKey);
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
            ChartID := GetTID(q.Fields[0]);
            q.Close;

            q.SQL.Text := 'INSERT INTO ac_companyaccount (companykey, accountkey, isactive) VALUES (:CK, :AK, 1) ';
            SetTID(q.ParamByName('CK'), CompanyKey);
            SetTID(q.ParamByName('AK'), ChartID);
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
        SetTID(SQL.ParamByName(fnId), CompanyKey);
        SQL.ExecQuery;
        MessageBox(0,
          PChar(Format(MSG_NOACTIVEACCOUTN, [SQL.FieldByName(fnName).AsString])),
          '��������',
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
      MessageBox(Application.Handle, PChar(MSG_CHOOSECOMPANY), '��������',
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

function GetCurrRate(ForDate: TDateTime; ValidDays: Integer; RegulatorKey: OleVariant;
  FromCurrKey: OleVariant; ToCurrKey: OleVariant; CrossCurrKey: OleVariant; Amount: Currency;
  ForceCross: WordBool; UseInverted: WordBool; RaiseException: WordBool): Double;

  procedure AdjustKey(var K: OleVariant);
  var
    q: TIBSQL;
  begin
    if VarIsEmpty(K) or VarIsNull(K) then
      K := -1
    else if (VarType(K) = varOleStr) or (VarType(K) = varString) then
    begin
      if CheckRUID(K) then
        K := TID2V(gdcBaseManager.GetIDByRUIDString(K))
      else if K = 'NCU' then
        K := TID2V(GetNCUKey)
      else begin
        q := TIBSQL.Create(nil);
        try
          q.Transaction := gdcBaseManager.ReadTransaction;
          q.SQL.Text :=
            'SELECT * FROM gd_curr WHERE code = :c';
          q.ParamByName('c').AsString := K;
          q.ExecQuery;

          if q.EOF then
            K := -1
          else begin
            K := TID2V(q.FieldByName('id'));

            q.Next;
            if not q.EOF then
              raise Exception.Create('More than one currency have code ' + q.ParamByName('c').AsString);
          end;
        finally
          q.Free;
        end;
      end;
    end else if not (VarType(K) = (varInteger)) then
      K := -1;
  end;

  function CalcRate(q: TIBSQL; const FC, TC: TID; const V: Double;
    const CanInvert: Boolean; var Output: Double): Boolean;
  begin
    Result := False;
    try
      SetTID(q.ParamByName('fc'), FC);
      SetTID(q.ParamByName('tc'), TC);
      q.ExecQuery;

      if q.EOF then
      begin
        if CanInvert then
        begin
          q.Close;
          SetTID(q.ParamByName('fc'), TC);
          SetTID(q.ParamByName('tc'), FC);
          q.ExecQuery;

          if not q.EOF then
          begin
            Output := q.FieldByName('amount').AsInteger * V / q.FieldByName('val').AsDouble;
            Result := True;
          end;
        end;
      end else
      begin
        Output := q.FieldByName('val').AsDouble * V / q.FieldByName('amount').AsInteger;
        Result := True;
      end;
    finally
      q.Close;
    end;
  end;

var
  q: TIBSQL;
begin
  try
    AdjustKey(FromCurrKey);
    AdjustKey(ToCurrKey);
    AdjustKey(CrossCurrKey);

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
        'SELECT FIRST 1 amount, val ' +
        'FROM gd_currrate ' +
        'WHERE fromcurr = :fc ' +
        '  AND tocurr = :tc ';

      if ValidDays = -1 then
        q.SQL.Add('  AND fordate <= :fd ')
      else if ValidDays = 0 then
        q.SQL.Add('  AND fordate = :fd ')
      else
        q.SQL.Add('  AND fordate <= :fd AND DATEDIFF(DAY FROM fordate TO CAST(:fd AS TIMESTAMP)) <= :vd ');

      if RegulatorKey = -1 then
        q.SQL.Add('ORDER BY fordate DESC, regulatorkey NULLS FIRST')
      else begin
        q.SQL.Add('AND regulatorkey = :rk ORDER BY fordate DESC');
        SetTID(q.ParamByName('rk'), GetTID(RegulatorKey));
      end;

      q.ParamByName('fd').AsDateTime := ForDate;

      if ValidDays > 0 then
        q.ParamByName('vd').AsInteger := ValidDays;

      if not
        (
          (
            (
              (not ForceCross)
              or
              (CrossCurrKey = -1)
            )
            and
            CalcRate(q, GetTID(FromCurrKey), GetTID(ToCurrKey), Amount, UseInverted, Result)
          )
          or
          (
            (CrossCurrKey <> -1)
            and
            CalcRate(q, GetTID(FromCurrKey), GetTID(CrossCurrKey), Amount, UseInverted, Result)
            and
            CalcRate(q, GetTID(CrossCurrKey), GetTID(ToCurrKey), Result, UseInverted, Result)
          )
        ) then
      begin
        raise Exception.Create('No currency rate found');
      end;  
    finally
      q.Free;
    end;
  except
    if RaiseException then
      raise
    else
      Result := 0;
  end;
end;

initialization
  ResetNCUCache;
end.
