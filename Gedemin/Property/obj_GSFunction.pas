// ShlTanya, 25.02.2019

unit obj_GSFunction;

interface

uses
  ComObj, Gedemin_TLB, Comserv, Controls, gdcTaxFunction, Classes, IBSQL,
  NumConv, at_classes, gdcConstants, AcctStrings, AcctUtils, IBDataBase, dialogs,
  gdcBaseInterface;

type
  TBalanceType = (gsDebit, gsCredit);

type
  TobjGSFunction = class;

  TGsFunctionNotifier = class(TComponent)
    FGSFunction: TobjGSFunction;
    FTransaction: TIBTransaction;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  end;

  TobjGSFunction = class(TAutoObject, IgsGSFunction)
  private
    FIBSQL: TIBSQL;
    FNumberConvert: TNumberConvert;
    //������ ����� ���������
    FFieldList: TStringList;
    FTransaction: TIBTransaction;
    FGsFunctionNotifier: TGsFunctionNotifier;
    FCalcBalanceDate: TDate;
    procedure FillCalcBalanceDate;

    //function GetWithAnDefault(AccountID: Integer): String;
    function GetWithAnDefaultSql(AccountID: TID; const TableAlias: String = ''): String;
    function  GetBalance(const Account: WideString;
      const OnDate: TDateTime; const Analytics: WideString;
      const BalType: TBalanceType): Currency; safecall;

    function  GetCurrBalance(const Account: WideString;
      const OnDate: TDateTime; const Analytics: WideString;
      const BalType: TBalanceType;
      const CurrKey: TID): Currency; safecall;

    function  GetEqBalance(const Account: WideString;
      const OnDate: TDateTime; const Analytics: WideString;
      const BalType: TBalanceType): Currency; safecall;


    function  GetQuantBalance(ValueKey: TID;
      const Account: WideString; const OnDate: TDateTime;
      const Analytics: WideString; const BalType: TBalanceType): Currency; safecall;

    function GetAnalyticsSQL(const Analytics: String; const TableAlias: String = ''): String;
    procedure InitFIBSQL;
    procedure CheckNumConv;
    function GetNumberConvert: TNumberConvert;
    function GetAccountKey(const Account: String): TID;
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetupTransaction(SQL: TIBSQl);

    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
  protected
    // �������, ������������ �������������� ������������ �� ���������
    function  K_SK(ValueKey: ATID; const Account: WideString; OnDate: TDateTime;
                             const Analytics: WideString): Currency; safecall;
    function  K_SD(ValueKey: ATID; const Account: WideString; OnDate: TDateTime;
                              const Analytics: WideString): Currency; safecall;
    function  K_OD(ValueKey: ATID; const Account: WideString; BDate: TDateTime;
                               EDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  K_OK(ValueKey: ATID; const Account: WideString; BDate: TDateTime;
                                EDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  K_O(ValueKey: ATID; const AccDeb: WideString;
                              const AccCred: WideString; BDate: TDateTime; EDate: TDateTime;
                              const AnalyticsDeb: WideString; const AnalyticsCred: WideString): Currency; safecall;

    // �������, ������������ ����� �� ���������
    function  SALDO(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  SK(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  SD(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString): Currency; safecall;

    function  E_SK(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  E_SD(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString): Currency; safecall;


    function  V_SK(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString;
      CurrKey: ATID): Currency; safecall;

    function  V_SD(const Account: WideString;
      OnDate: TDateTime; const Analytics: WideString;
      CurrKey: ATID): Currency; safecall;

    function  OD(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  OK(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency; safecall;

    function  E_OD(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency; safecall;
    function  E_OK(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency; safecall;


    function  V_OD(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString;
      CurrKey: ATID): Currency; safecall;
    function  V_OK(const Account: WideString;
      BDate: TDateTime; EDate: TDateTime; const Analytics: WideString;
      CurrKey: ATID): Currency; safecall;
    function  V_O(const AccDeb: WideString; const AccCred: WideString; BDate: TDateTime;
                         EDate: TDateTime; const AnalyticsDeb: WideString;
                         const AnalyticsCred: WideString; CurrKey: ATID): Currency; safecall;

    function  O(const AccDeb: WideString; const AccCred: WideString; BDate: TDateTime;
                         EDate: TDateTime; const AnalyticsDeb: WideString;
                         const AnalyticsCred: WideString): Currency; safecall;

    function  E_O(const AccDeb: WideString; const AccCred: WideString; BDate: TDateTime;
                         EDate: TDateTime; const AnalyticsDeb: WideString;
                         const AnalyticsCred: WideString): Currency; safecall;


    function  NG(cDate: TDateTime): TDateTime; safecall;
    function  NK(cDate: TDateTime): TDateTime; safecall;
    function  NP: TDateTime; safecall;
    function  OP: TDateTime; safecall;
    function  GetValue(const FName: WideString): OleVariant; safecall;
    function  IncMonth(Date: TDateTime; NumberOfMonths: Integer): TDateTime; safecall;
    // ��������� ��� VBS DateAdd, ��������� ������ ���������� ���, ���� ������� ���� ������ ATBLCID, �� ����� �������� �� ����,
    //  ����� �� ����������� ���������� �� ���������
    function  DateAddBank(const Interval: WideString; Number: Integer;
      DateValue: TDateTime; TBLCALID: ATID = -1): TDateTime; safecall;

    function  NM(Date: TDateTime): TDateTime; safecall;
    function  KM(Date: TDateTime): TDateTime; safecall;

    function  CreditValue(Sum: Currency): Currency; safecall;
    function  DebibValue(Sum: Currency): Currency; safecall;

    function  GetAnalyticStr(const SQL: IgsIBSQL): WideString; safecall;
    function  GetAnalyticValue(const Analytics: WideString;
      const AnalyticName: WideString): OleVariant; safecall;
    function  GetAnalytics(const Analytics: WideString;
      const Names: WideString): WideString; safecall;

    function  GetSumCurr(CurrKey: OleVariant; Sum: OleVariant; CentPrecision: OleVariant;
                         ShowCent: WordBool): OleVariant; safecall;
    function  GetSumStr(D1: OleVariant; D2: Shortint): OleVariant; safecall;
    function  GetRubSumStr(D: OleVariant): OleVariant; safecall;
    function  GetFullRubSumStr(D: OleVariant): OleVariant; safecall;

    function  GetNumeral(const AFormat: WideString; AValue: Double; ARounding: Double;
                         AFracBase: Integer; ACase: Integer; AParts: Integer;
                         const ANames: WideString): WideString; safecall;
    function  GetCurrNumeral(ACurrKey: ATID; const AFormat: WideString; AValue: Double;
                             ARounding: Double; ACase: Integer; AParts: Integer;
                             const ASubst: WideString; const ADecimalSeparator: WideString;
                             const AThousandSeparator: WideString): WideString; safecall;

    function  GetAccountKeyByAlias(const AnAlias: WideString): ATID; safecall;
    function  MulDiv(ANumber: Double; ANumerator: Double; ADenominator: Double; 
                     ARoundMethod: Integer; ADecPlaces: Integer): Double; safecall;

    property NumberConvert: TNumberConvert read GetNumberConvert;

  public
    destructor Destroy; override;
    procedure Initialize; override;

    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;


implementation

uses
  dmDataBase_unit, SysUtils, gdc_frmTaxDesignTime_unit,
  gd_security, prp_methods, wiz_Utils_unit, gdcOLEClassList, gd_convert;

type
  TAnalyticsSymb = (anlName, anlValue);

  TCrackGdc_frmTaxDesignTime = class(Tgdc_frmTaxDesignTime);

var
  FBPeriod: TDate;
  FEPeriod: TDate;

const
  ISNULL = 'IS NULL';

  MSG_INVALID_NAME = '��������� � ������ "%s" �� �������.'#13#10'����������� ������: <���_����_��������������_��������1>=<��������1>[;<���_����_��������������_��������2>=<��������2>...]';
  MSG_INVALID_VALUE = '������������ �������� ��������� "%s"';

function GetKopWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := '�������';
      2, 3, 4: Result := '�������';
    else
      Result := '������';
    end
  else
    Result := '������';
end;

function GetRubbleWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := '�����';
      2, 3, 4: Result := '�����';
    else
      Result := '������';
    end
  else
    Result := '������';
end;

{ TobjGSFunction }

function TobjGSFunction.SALDO(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString): Currency;
begin
  Assert(False, '������� �� �����������.');
end;

function TobjGSFunction.NK(cDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(cDate, Year, Month, Day);
  case Month of
    1..3:   Month := 1;
    4..6:   Month := 4;
    7..9:   Month := 7;
    10..12: Month := 10;
  end;
  Result := EncodeDate(Year, Month, 1);
end;

function TobjGSFunction.NG(cDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(cDate, Year, Month, Day);
  Result := EncodeDate(Year, 1, 1);
end;

function TobjGSFunction.O(const AccDeb: WideString;
  const AccCred: WideString; BDate: TDateTime; EDate: TDateTime;
  const AnalyticsDeb: WideString; const AnalyticsCred: WideString): Currency;
var
  IBSQL: TIBSQL;
  DAccountKey, CAccountKey: TID;
  AnalDebReady, AnalCredReady: String;
begin
  Result := 0;
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    DAccountKey := GetAccountKey(AccDeb);
    CAccountKey := GetAccountKey(AccCred);
    with IBSQL do
    begin
      AnalDebReady := GetAnalyticsSQL(AnalyticsDeb, 'ed');
      if AnalDebReady > '' then
      begin
        AnalDebReady :=
          '  AND ' +
          '  (ed.accountpart = ''D'' AND ' +
          AnalDebReady + ' ) ';
      end;
      AnalCredReady := GetAnalyticsSQL(AnalyticsCred, 'ec');
      if AnalCredReady > '' then
      begin
        AnalCredReady :=
          '  AND ' +
          '  (ec.accountpart = ''C'' AND ' +
          AnalCredReady + ' ) ';
      end;

      SQL.Text :=
        'SELECT ' +
        '  SUM(iif(ec.issimple = 1, ed.debitncu, ec.creditncu)) ' +
        'FROM ' +
        '  ac_entry ed ' +
        '  JOIN ac_entry ec ON ed.recordkey = ec.recordkey AND ' +
        '    ed.accountpart <> ec.accountpart AND ' +
        '  (ed.entrydate >= :bdate AND ed.entrydate <= :edate) AND ' +
        '  ((ed.accountpart = ''D'' AND ed.accountkey IN (' + TID2S(DAccountKey) + ')) AND ' +
        '  (ec.accountpart = ''C'' AND ec.accountkey IN (' + TID2S(CAccountKey) + '))) ' +
        AnalDebReady +
        AnalCredReady+
        'WHERE ' +
           GetCompCondition('ed.companykey');

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;

      ExecQuery;

      while not Eof do
      begin
        Result := Result + Fields[0].AsCurrency;
        Next;
      end;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.E_O(const AccDeb: WideString;
  const AccCred: WideString; BDate: TDateTime; EDate: TDateTime;
  const AnalyticsDeb: WideString; const AnalyticsCred: WideString): Currency;
var
  IBSQL: TIBSQL;
  DAccountKey, CAccountKey: TID;
  AnalDebReady, AnalCredReady: String;
begin
  Result := 0;
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    DAccountKey := GetAccountKey(AccDeb);
    CAccountKey := GetAccountKey(AccCred);
    with IBSQL do
    begin
      Transaction := gdcBaseManager.ReadTransaction;

      AnalDebReady :=  GetAnalyticsSQL(AnalyticsDeb, 'ed');
      if AnalDebReady > '' then
      begin
        AnalDebReady :=
          '  AND ' +
          '  (ed.accountpart = ''D'' AND ' +
          AnalDebReady + ' ) ';
      end;
      AnalCredReady := GetAnalyticsSQL(AnalyticsCred, 'ec');
      if AnalCredReady > '' then
      begin
        AnalCredReady :=
          '  AND ' +
          '  (ec.accountpart = ''C'' AND ' +
          AnalCredReady + ' ) ';
      end;

      SQL.Text :=
        'SELECT ' +
        '  SUM(iif(ec.issimple = 1, ed.debiteq, ec.crediteq)) ' +
        'FROM ' +
        '  ac_entry ed ' +
        '  JOIN ac_entry ec ON ed.recordkey = ec.recordkey AND ' +
        '    ed.accountpart <> ec.accountpart AND ' +
        '  (ed.entrydate >= :bdate AND ed.entrydate <= :edate) AND ' +
        '  ((ed.accountpart = ''D'' AND ed.accountkey IN (' + TID2S(DAccountKey) + ')) AND ' +
        '  (ec.accountpart = ''C'' AND ec.accountkey IN (' + TID2S(CAccountKey) + '))) ' +
        AnalDebReady +
        AnalCredReady+
        'WHERE ' +
           GetCompCondition('ed.companykey');


      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
//      ParamByName('ingroup').AsInteger := IbLogin.Ingroup;

      ExecQuery;

      while not Eof do
      begin
        Result := Result +  Fields[0].AsCurrency;
        Next;
      end;
    end;
  finally
    IBSQL.Free;
  end;
end;


function TobjGSFunction.OK(const Account: WideString;
  BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > ''then AnalyticsReady := '  AND ' + AnalyticsReady;
      SQL.Text :=
        'SELECT SUM(z.creditncu) FROM ' +
        '  ac_account a ' +
        '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  JOIN ac_entry z ON z.accountkey = a1.id ' +
        ' AND ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);

      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.OD(const Account: WideString;
  BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  ID: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then  AnalyticsReady := '  AND ' + AnalyticsReady;

      SQL.Text :=
        'SELECT SUM(z.debitncu) FROM ' +
        '  ac_account a ' +
        '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  JOIN ac_entry z ON z.accountkey = a1.id ' +
        ' AND ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);
      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.E_OK(const Account: WideString;
  BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > ''then AnalyticsReady := '  AND ' + AnalyticsReady;
      SQL.Text :=
        'SELECT SUM(z.crediteq) FROM ' +
        '  ac_account a ' +
        '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  JOIN ac_entry z ON z.accountkey = a1.id ' +
        ' AND ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);

      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.E_OD(const Account: WideString;
  BDate: TDateTime; EDate: TDateTime; const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  ID: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then  AnalyticsReady := '  AND ' + AnalyticsReady;

      SQL.Text :=
        'SELECT SUM(z.debiteq) FROM ' +
        '  ac_account a ' +
        '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  JOIN ac_entry z ON z.accountkey = a1.id ' +
        ' AND ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);
      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;


destructor TobjGSFunction.Destroy;
begin
  inherited;

  FIBSQL.Free;
  FNumberConvert.Free;
  FFieldList.Free;
  FGsFunctionNotifier.Free;
end;

procedure TobjGSFunction.Initialize;
begin
  inherited;
  
  FIBSQL := nil;
end;

function TobjGSFunction.NP: TDateTime;
begin
  Result := FBPeriod;
end;

function TobjGSFunction.OP: TDateTime;
begin
  Result := FEPeriod;
end;

function TobjGSFunction.GetAnalyticsSQL(const Analytics, TableAlias: String): String;
var
  I: Integer;
  S: TStrings;
  AN, AV, A: string;
  Index: Integer;
  ID: TID;
  F: TatRelationField;
  L: TList;
const
  anlSeparator = ';';
begin
  Result := '';
  if FFieldList = nil then
  begin
    FFieldList := TStringList.Create;
    FFieldList.Sorted := True;
    L := TList.Create;
    try
      GetAnalyticsFields(L);
      for I := 0 to L.Count - 1 do
      begin
        FFieldList.AddObject(TatRelationField(L[I]).FieldName, L[I]);
      end;
    finally
      L.Free;
    end;
  end;

  S := TStringList.Create;
  try
    S.Text := StringReplace(Analytics, anlSeparator, #13#10, [rfReplaceAll]);
    for I := 0 to S.Count - 1 do
    begin
      A := '';
      AN := S.Names[I];
      AV := Trim(S.Values[AN]);
      AN := Trim(AN);
      Index := FFieldList.IndexOf(AN);
      if Index > - 1 then
      begin
        F := TatRelationField(FFieldList.Objects[Index]);

        if Result > '' then Result := Result + ' AND ';
        if AV = ISNULL then
        begin
          Result := Result + Format(' %s.%s IS NULL ', [TableAlias, AN]);
        end else
        begin
          if F.ReferencesField <> nil then
          begin
            //���� ���� ������ �� ������ ���� ������� ���� ��� ��
            if CheckRUID(AV) then
            begin
              try
                Id := gdcBaseManager.GetIDByRUIDString(AV);
              except
                raise Exception.Create(Format(MSG_INVALID_VALUE,[AN]))
              end;
              Result := Result + Format(' %s.%s = ''%d''', [TableAlias, AN, TID264(Id)])
            end else
            begin
              try
                StrToInt(AV);
              except
                raise Exception.Create(Format(MSG_INVALID_VALUE,[AN]))
              end;

              Result := Result + Format(' %s.%s = ''%s''', [TableAlias, AN, AV]);
            end;
          end else
            Result := Result + Format(' %s.%s = ''%s''', [TableAlias, AN, AV]);
        end;
      end else
        raise Exception.Create(Format(MSG_INVALID_NAME,[AN]));
    end;
  finally
    S.Free;
  end;
end;

function TobjGSFunction.SK(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString): Currency;
begin
  Result := GetBalance(Account, OnDate, Analytics, gsCredit);
  if Result > 0 then
    Result := 0
  else
    Result := Abs(Result);
end;

function TobjGSFunction.E_SD(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString): Currency;
begin
  Result := GetEqBalance(Account, OnDate, Analytics, gsDebit);
  if Result < 0 then
    Result := 0
  else
    Result := Result;
end;

function TobjGSFunction.E_SK(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString): Currency;
begin
  Result := GetEqBalance(Account, OnDate, Analytics, gsCredit);
  if Result > 0 then
    Result := 0
  else
    Result := Abs(Result);
end;

function TobjGSFunction.SD(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString): Currency;
begin
  Result := GetBalance(Account, OnDate, Analytics, gsDebit);
  if Result < 0 then
    Result := 0
  else
    Result := Result;
end;


function TobjGSFunction.GetValue(const FName: WideString): OleVariant;
begin
  raise Exception.Create('������ ������� �������� � ����� �������');
end;

function TobjGSFunction.IncMonth(Date: TDateTime;
  NumberOfMonths: Integer): TDateTime;
begin
  Result := Sysutils.IncMonth(Date, NumberOfMonths);
end;

function TobjGSFunction.NM(Date: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(Date, Year, Month, Day);
  Result := EncodeDate(Year, Month, 1);
end;

function TobjGSFunction.KM(Date: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  Date := Sysutils.IncMonth(Date, 1);
  DecodeDate(Date, Year, Month, Day);
  Result := EncodeDate(Year, Month, 1);
  Result := Result - 1;
end;

function TobjGSFunction.CreditValue(Sum: Currency): Currency;
begin
  if Sum > 0 then
    Result := 0
  else
    Result := Sum;
end;

function TobjGSFunction.DebibValue(Sum: Currency): Currency;
begin
  if Sum < 0 then
    Result := 0
  else
    Result := Abs(Sum);
end;

procedure TobjGSFunction.InitFIBSQL;
begin
  if FIBSQL = nil then
  begin
    FIBSQL := TIBSQL.Create(nil);
  end;

  if Transaction <> nil then
    FIBSQL.Transaction := FTransaction
  else
    FIBSQL.Transaction := gdcBaseManager.ReadTransaction;
end;

function TobjGSFunction.GetBalance(const Account: WideString;
  const OnDate: TDateTime; const Analytics: WideString;
  const BalType: TBalanceType): Currency;
var
  AnalyticsReady: String;
  MainAnalNameB, MainAnalNameE, MainAnalNameZ: String;
  Id: TID;
  AnalyticsReadyB, AnalyticsReadyE: String;
begin
  Result := 0;
  InitFIBSQL;

  Id := GetAccountKey(Account);

  if Analytics = '' then
  begin
    MainAnalNameB := GetWithAnDefaultSql(id, 'b');
    MainAnalNameE := GetWithAnDefaultSql(id, 'e');
    MainAnalNameZ := GetWithAnDefaultSql(id, 'z');
  end
  else
  begin
    MainAnalNameB := '';
    MainAnalNameE := '';
    MainAnalNameZ := '';
  end;

  FillCalcBalanceDate;
  if FCalcBalanceDate > 0 then
  begin
    AnalyticsReadyB := GetAnalyticsSQL(Analytics, 'b');
    if AnalyticsReadyB > '' then
      AnalyticsReadyB := '  AND ' + AnalyticsReadyB;
    AnalyticsReadyE := GetAnalyticsSQL(Analytics, 'e');
    if AnalyticsReadyE > '' then
      AnalyticsReadyE := '  AND ' + AnalyticsReadyE;

    FIBSQL.Close;
    FIBSQL.SQL.Text :=
      'SELECT ' +
      '  SUM(z.debitncu - z.creditncu) as saldo ' +
      'FROM ' +
      '( ' +
      '  SELECT ' +
      '    b.debitncu, ' +
      '    b.creditncu ' +
        IIF(MainAnalNameB <> '', ', ' + MainAnalNameB, '') +
      '  FROM ' +
      '    ac_account a ' +
      '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
      '    JOIN ac_entry_balance b ON b.accountkey = a1.id ' +
      '  WHERE ' +
      '    a.id = :accountkey ' +
      '    AND ' + GetCompCondition('b.companykey') +
        IIF(MainAnalNameB = '', AnalyticsReadyB, '') +
      '  UNION ALL ' +
      '  SELECT ' +
        IIF(FCalcBalanceDate > OnDate,
          ' - e.debitncu, - e.creditncu ',
          ' e.debitncu, e.creditncu ') +
        IIF(MainAnalNameE <> '', ', ' + MainAnalNameE, '') +
      '  FROM ' +
      '    ac_account a ' +
      '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
      '    JOIN ac_entry e ON e.accountkey = a1.id ' +
      '  WHERE ' +
      '    a.id = :accountkey ' +
      '    AND ' + GetCompCondition('e.companykey') +
        IIF(FCalcBalanceDate > OnDate,
          ' AND (e.entrydate > :ondate AND e.entrydate < :balancedate) ',
          ' AND (e.entrydate <= :ondate AND e.entrydate >= :balancedate) ') +
        IIF(MainAnalNameB = '', AnalyticsReadyE, '') +
      ') z ' +
        IIF(MainAnalNameZ <> '', 'GROUP BY ' + MainAnalNameZ, '');
    FIBSQL.ParamByName('ondate').AsDate := OnDate;
    FIBSQL.ParamByName('balancedate').AsDate := FCalcBalanceDate;
    SetTID(FIBSQL.ParamByName('accountkey'), Id);
    FIBSQL.ExecQuery;

    
    if FIBSQL.RecordCount > 0 then
    begin
      if MainAnalNameB <> '' then
      begin
        while not FIBSQL.Eof do
        begin
          case BalType of
            gsDebit:
              if FIBSQL.FieldByName('saldo').AsCurrency > 0 then
                Result := Result + FIBSQL.FieldByName('saldo').AsCurrency;
            gsCredit:
              if FIBSQL.FieldByName('saldo').AsCurrency < 0 then
                Result := Result + FIBSQL.FieldByName('saldo').AsCurrency;
          end;
          FIBSQL.Next;
        end;
      end
      else
        Result := FIBSQL.Fields[0].AsCurrency;
    end;
  end
  else

    if MainAnalNameB = '' then
    begin
      with FIBSQL do
      begin
        Close;
        AnalyticsReady := GetAnalyticsSQL(Analytics, 'z');
        if AnalyticsReady > '' then AnalyticsReady := '  AND ' + AnalyticsReady;

        SQL.Text :=
          'SELECT SUM(z.debitncu - z.creditncu) as saldo FROM ' +
          '  ac_account a ' +
          '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  JOIN ac_entry z ON z.accountkey = a1.id ' +
          '  AND  ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' and ' +
          '  z.entrydate <= :ondate ' +
          AnalyticsReady;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);
        ExecQuery;

        if RecordCount > 0 then
          Result := Fields[0].AsCurrency;
      end
    end
    else
    begin
      with FIBSQL do
      begin
        Close;

        SQL.Text :=
          'SELECT SUM(z.debitncu - z.creditncu) as saldo FROM ' +
          '  ac_account a ' +
          '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
          'WHERE ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' AND ' +
          '  z.entrydate <= :ondate ' +
          'GROUP BY ' + MainAnalNameZ;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);

        ExecQuery;
        while not Eof do
        begin
          case BalType of
            gsDebit:
              if FieldByName('saldo').AsCurrency > 0 then
                Result := Result + FieldByName('saldo').AsCurrency;
            gsCredit:
              if FieldByName('saldo').AsCurrency < 0 then
                Result := Result + FieldByName('saldo').AsCurrency;
          end;

          Next;
        end;
      end;
    end;
end;

{function TobjGSFunction.GetCompCondition(const CompKeyFieldName: String): String;
begin
  if IBLogin.IsHolding then
    Result := ' ' + CompKeyFieldName + ' IN (' + IBLogin.HoldingList + ') '
  else
    Result := ' ' + CompKeyFieldName + ' = ' + IntToStr(IBLogin.CompanyKey) + ' ';
end;}

function  TobjGSFunction.GetAnalyticStr(const SQL: IgsIBSQL): WideString; safecall;
var
  I: Integer;
  S: TIBSQL;
begin
  Result := '';
  if SQL <> nil then
  begin
    S := InterfaceToObject(SQL) as TIBSQL;
    for I := 0 to S.Current.Count - 1 do
    begin
      if Result > '' then Result := Result + '; ';
      if S.Current.Vars[I].IsNull then
        Result := Result + S.Current.Vars[I].Name + ' ' + ISNULL + ' '
      else
        Result := Result + S.Current.Vars[I].Name + ' = ' + S.Current.Vars[I].AsString;
    end;
  end;
end;

function TobjGSFunction.GetAnalyticValue(const Analytics,
  AnalyticName: WideString): OleVariant;
var
  P: Integer;
  I: Integer;
  S: TStrings;
  LAnalytics, LAnalyticName: WideString;
const
  cError = '�������� ������ ���������';
  cnotFound = '��������� %s �� �������';
begin
  Result := NULL;
  LAnalytics := Trim(UpperCase(Analytics));
  LAnalyticName := Trim(UpperCase(AnalyticName));
  P := Pos(LAnalyticName, LAnalytics);
  if P > 0 then
  begin
    S := TStringList.Create;
    try
      ParseString(LAnalytics, S);
      for I := 0 to s.Count - 1 do
      begin
        P := Pos(LAnalyticName, S[I]);
        if P = 1 then
        begin
          P := Pos('=', S[I]);
          if P > 0 then
          begin
            Result := Trim(Copy(S[I], P + 1, Length(S[i]) - P));
            Exit;
          end else
          begin
            P := Pos(ISNULL, UpperCase(S[I]));
            if P = 0 then
              raise Exception.Create(cError)
            else
              Exit;
          end;
        end;
      end;
    finally
      S.Free;
    end;
  end else
    raise Exception.Create(Format(cNotFound, [AnalyticName]));
end;

function TobjGSFunction.GetAnalytics(const Analytics,
  Names: WideString): WideString;
var
  S: TStrings;
  I: Integer;
  Value: OleVariant;
begin
  Result := '';
  S := TStringList.Create;
  try
    ParseString(Names, S);
    for I := 0 to S.Count - 1 do
    begin
      Value := GetAnalyticValue(Analytics, S[i]);
      if not VarIsNull(Value) then
      begin
        if Result > '' then Result := Result +'; ';
        Result := Result + S[i] + '=' + Value;
      end
      else
      begin
        if Result > '' then Result := Result +'; ';
        Result := Result + S[i] + '=IS NULL';
      end
    end;
  finally
    S.Free;
  end;
end;

function TobjGSFunction.K_O(ValueKey: ATID; const AccDeb: WideString;
  const AccCred: WideString; BDate: TDateTime; EDate: TDateTime;
  const AnalyticsDeb: WideString; const AnalyticsCred: WideString): Currency;
var
  IBSQL: TIBSQL;
  DAccountKey, CAccountKey: TID;
  AnalDebReady, AnalCredReady: String;
begin
  Result := 0;
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    DAccountKey := GetAccountKey(AccDeb);
    CAccountKey := GetAccountKey(AccCred);
    with IBSQL do
    begin
      Transaction := gdcBaseManager.ReadTransaction;

      AnalDebReady :=  GetAnalyticsSQL(AnalyticsDeb, 'ed');
      if AnalDebReady > '' then AnalDebReady := '  AND ' +
        '  (ed.accountpart = ''D'' AND ' + AnalDebReady + ' ) ';

      AnalCredReady := GetAnalyticsSQL(AnalyticsCred, 'ec');
      if AnalCredReady > '' then  AnalCredReady := '  AND ' +
        '  (ec.accountpart = ''C'' AND ' +  AnalCredReady + ' ) ';

      SQL.Text :=
        'SELECT ' +
        '  SUM(qd.quantity) ' +
        'FROM ' +
        '  ac_entry ed ' +
        '  JOIN ac_quantity qd ON qd.entrykey = ed.id and qd.valuekey = :valuekey ' +
        '  JOIN ac_entry ec ON ed.recordkey = ec.recordkey ' +
        ' ' +
        'WHERE ' +
        '  (ed.entrydate >= :bdate AND ed.entrydate <= :edate) AND ' +
        '  ((ed.accountpart = ''D'' AND ed.accountkey = :daccountkey) AND ' +
        '  (ec.accountpart = ''C'' AND ec.accountkey = :caccountkey)) AND ' +
        '  (ed.debitncu <= ec.creditncu) AND ' +
        GetCompCondition('ed.companykey') +
        AnalDebReady +
        AnalCredReady +
        'UNION ALL ' +
        'SELECT ' +
        '  SUM(qc.quantity) ' +
        'FROM ' +
        '  ac_entry ed ' +
        '  JOIN ac_entry ec ON ed.recordkey = ec.recordkey ' +
        '  JOIN ac_quantity qc ON qc.entrykey = ec.id  and qc.valuekey = :valuekey ' +
        'WHERE ' +
        '  (ed.entrydate >= :bdate AND ed.entrydate <= :edate) AND ' +
        '  ((ed.accountpart = ''D'' AND ed.accountkey = :daccountkey) AND ' +
        '  (ec.accountpart = ''C'' AND ec.accountkey = :caccountkey)) AND ' +
        '  (ed.debitncu > ec.creditncu) AND ' +
        GetCompCondition('ed.companykey') +
        AnalDebReady +
        AnalCredReady;

      SetTID(ParamByName('valuekey'), GetTID(ValueKey));
      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName('daccountkey'), DAccountKey);
      SetTID(ParamByName('caccountkey'), CAccountKey);

      ExecQuery;

      while not Eof do
      begin
        Result := Result +  Fields[0].AsCurrency;
        Next;
      end;
    end;
  finally
    IBSQl.Free;
  end;
end;

function TobjGSFunction.K_SK(ValueKey: ATID;
  const Account: WideString; OnDate: TDateTime;
  const Analytics: WideString): Currency;
begin
  Result := GetQuantBalance(GetTID(ValueKey), Account, OnDate, Analytics, gsCredit);
  if Result > 0 then
    Result := 0
  else
    Result := Abs(Result);
end;

function TobjGSFunction.K_OK(ValueKey: ATID;
  const Account: WideString; BDate, EDate: TDateTime;
  const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then  AnalyticsReady := '  AND ' + AnalyticsReady;
      SQL.Text :=
        'SELECT SUM(qd.quantity) FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        '  LEFT JOIN ac_quantity qd ON qd.entrykey = z.id and qd.valuekey = :valuekey and z.accountpart = ''C'' ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate AND z.entrydate <= :edate ' +
        AnalyticsReady;

      SetTID(ParamByName('valuekey'), GetTID(ValueKey));
      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName('accountkey'), Id);

      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.K_SD(ValueKey: ATID;
  const Account: WideString; OnDate: TDateTime;
  const Analytics: WideString): Currency;
begin
  Result := GetQuantBalance(GetTID(ValueKey), Account, OnDate, Analytics, gsDebit);
  if Result < 0 then
    Result := 0
  else
    Result := Result;
end;

function TobjGSFunction.K_OD(ValueKey: ATID;
  const Account: WideString; BDate, EDate: TDateTime;
  const Analytics: WideString): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then AnalyticsReady := '  AND ' + AnalyticsReady;

      SQL.Text :=
        'SELECT SUM(qd.quantity) AS dsum FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        '  LEFT JOIN ac_quantity qd ON qd.entrykey = z.id and qd.valuekey = :valuekey and z.accountpart = ''D'' ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate AND z.entrydate <= :edate ' +
        AnalyticsReady;

      SetTID(ParamByName('valuekey'), GetTID(ValueKey));
      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName('accountkey'), Id);

      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.GetQuantBalance(ValueKey: TID;
  const Account: WideString; const OnDate: TDateTime;
  const Analytics: WideString; const BalType: TBalanceType): Currency;
var
  AnalyticsReady: String;
  MainAnalNameZ: String;
  Id: TID;
  QuantSaldo: Currency;
begin
  Result := 0;
  InitFIBSQL;

  Id := GetAccountKey(Account);

  if Analytics = '' then
    MainAnalNameZ := GetWithAnDefaultSql(id, 'z')
  else
    MainAnalNameZ := '';

  if MainAnalNameZ = '' then
  begin
    with FIBSQL do
    begin
      Close;
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then AnalyticsReady := '  AND ' + AnalyticsReady;

      SQL.Text :=
        'SELECT SUM(qd.quantity) AS dsum, SUM(qc.quantity) AS csum FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        '  LEFT JOIN ac_quantity qd ON qd.entrykey = z.id and qd.valuekey = :valuekey and z.accountpart = ''D'' ' +
        '  LEFT JOIN ac_quantity qc ON qc.entrykey = z.id and qc.valuekey = :valuekey and z.accountpart = ''C'' ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate <= :ondate ' +
        AnalyticsReady;

      SetTID(ParamByName('valuekey'), ValueKey);
      ParamByName('ondate').AsDate := OnDate;
      SetTID(ParamByName('accountkey'), Id);
      ExecQuery;

      if not Eof then
        Result := FieldByName('dsum').AsCurrency - FieldByName('csum').AsCurrency;
    end
  end else
    with FIBSQL do
    begin
      if Open then
        Close;
      SQL.Text :=
        'SELECT SUM(qd.quantity) AS dsum, SUM(qc.quantity) AS csum FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        '  LEFT JOIN ac_quantity qd ON qd.entrykey = z.id and qd.valuekey = :valuekey and z.accountpart = ''D'' ' +
        '  LEFT JOIN ac_quantity qc ON qc.entrykey = z.id and qc.valuekey = :valuekey and z.accountpart = ''C'' ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate <= :ondate ' +
        ' GROUP BY ' + MainAnalNameZ;

      SetTID(ParamByName('valuekey'), ValueKey);
      ParamByName('ondate').AsDate := OnDate;
      SetTID(ParamByName('accountkey'), Id);


      ExecQuery;
      while not Eof do
      begin
        QuantSaldo := FieldByName('dsum').AsCurrency - FieldByName('csum').AsCurrency;
        case BalType of
          gsDebit:
            if QuantSaldo > 0 then
              Result := Result + QuantSaldo;
          gsCredit:
            if QuantSaldo < 0 then
              Result := Result - QuantSaldo;
        end;

        Next;
      end;
    end;
end;

procedure TobjGSFunction.CheckNumConv;
begin
  if FNumberConvert = nil then
  begin
    FNumberConvert := TNumberConvert.Create(nil);
    FNumberConvert.Language := lRussian;
  end;
end;

function TobjGSFunction.GetFullRubSumStr(D: OleVariant): OleVariant;
begin
  Result := gd_convert.GetFullRubSumStr(D);
end;

function TobjGSFunction.GetRubSumStr(D: OleVariant): OleVariant;
begin
  Result := gd_convert.GetRubSumStr(D);
end;

function TobjGSFunction.GetSumCurr(CurrKey: OleVariant; Sum: OleVariant; CentPrecision: OleVariant;
  ShowCent: WordBool): OleVariant;
begin
  if VarType(CentPrecision) = varBoolean then
    Result := gd_convert.GetSumCurr(GetTID(CurrKey), Sum, CentPrecision, ShowCent)
  else
    Result := gd_convert.GetSumCurr(GetTID(CurrKey), Sum, CentPrecision <> 0, ShowCent);
end;

function TobjGSFunction.GetSumStr(D1: OleVariant; D2: ShortInt): OleVariant;
begin
  Result := gd_convert.GetSumStr(D1, D2);
end;

function TobjGSFunction.GetNumberConvert: TNumberConvert;
begin
  CheckNumConv;
  Result := FNumberConvert; 
end;

function TobjGSFunction.GetCurrBalance(const Account: WideString;
  const OnDate: TDateTime; const Analytics: WideString;
  const BalType: TBalanceType; const CurrKey: TID): Currency;
var
  AnalyticsReady: String;
  MainAnalNameB, MainAnalNameE, MainAnalNameZ: String;
  Id: TID;
  AnalyticsReadyB, AnalyticsReadyE: String;
begin
  Result := 0;
  InitFIBSQL;

  Id := GetAccountKey(Account);

  if Trim(Analytics) = '' then
  begin
    MainAnalNameB := GetWithAnDefaultSql(id, 'b');
    MainAnalNameE := GetWithAnDefaultSql(id, 'e');
    MainAnalNameZ := GetWithAnDefaultSql(id, 'z');
  end
  else
  begin
    MainAnalNameB := '';
    MainAnalNameE := '';
    MainAnalNameZ := '';
  end;


  FillCalcBalanceDate;
  if FCalcBalanceDate > 0 then
  begin
    AnalyticsReadyB := GetAnalyticsSQL(Analytics, 'b');
    if AnalyticsReadyB > '' then
      AnalyticsReadyB := '  AND ' + AnalyticsReadyB;
    AnalyticsReadyE := GetAnalyticsSQL(Analytics, 'e');
    if AnalyticsReadyE > '' then
      AnalyticsReadyE := '  AND ' + AnalyticsReadyE;
    with FIBSQL do
    begin
      Close;
      SQL.Text :=
        'SELECT ' +
        '  SUM(z.debitcurr - z.creditcurr) as saldo ' +
        'FROM ' +
        '( ' +
        '  SELECT ' +
        '    b.debitcurr, ' +
        '    b.creditcurr ' +
          IIF(MainAnalNameB <> '', ', ' + MainAnalNameB, '') +
        '  FROM ' +
        '    ac_account a ' +
        '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '    JOIN ac_entry_balance b ON b.accountkey = a1.id ' +
        '  WHERE ' +
        '    a.id = :accountkey ' +
        '    AND b.currkey = :currkey ' +
        '    AND ' + GetCompCondition('b.companykey') +
          IIF(MainAnalNameB = '', AnalyticsReadyB, '') +
        '  UNION ALL ' +
        '  SELECT ' +
          IIF(FCalcBalanceDate > OnDate,
          ' - e.debitcurr, - e.creditcurr ',
          ' e.debitcurr, e.creditcurr ') +
          IIF(MainAnalNameE <> '', ', ' + MainAnalNameE, '') +
        '  FROM ' +
        '    ac_account a ' +
        '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '    JOIN ac_entry e ON e.accountkey = a1.id ' +
        '  WHERE ' +
        '    a.id = :accountkey ' +
        '    AND e.currkey = :currkey ' +
        '    AND ' + GetCompCondition('e.companykey') +
          IIF(FCalcBalanceDate > OnDate,
          ' AND (e.entrydate > :ondate AND e.entrydate < :balancedate) ',
          ' AND (e.entrydate <= :ondate AND e.entrydate >= :balancedate) ') +
          IIF(MainAnalNameE = '', AnalyticsReadyE, '') +
        ') z ' +
          IIF(MainAnalNameZ <> '', 'GROUP BY ' + MainAnalNameZ, '');
      ParamByName('ondate').AsDate := OnDate;
      ParamByName('balancedate').AsDate := FCalcBalanceDate;
      SetTID(ParamByName('accountkey'), Id);
      SetTID(ParamByName('currkey'), CurrKey);
      ExecQuery;

      if RecordCount > 0 then
      begin
        if MainAnalNameB <> '' then
        begin
          while not Eof do
          begin
            case BalType of
              gsDebit:
                if FieldByName('saldo').AsCurrency > 0 then
                  Result := Result + FieldByName('saldo').AsCurrency;
              gsCredit:
                if FieldByName('saldo').AsCurrency < 0 then
                  Result := Result + FieldByName('saldo').AsCurrency;
            end;
            Next;
          end;
        end
        else
          Result := Fields[0].AsCurrency;
      end;
    end
  end
  else

    if MainAnalNameB = '' then
    begin
      with FIBSQL do
      begin
        Close;
        AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
        if AnalyticsReady > '' then AnalyticsReady := '  AND ' + AnalyticsReady;

        SQL.Text :=
          'SELECT SUM(z.debitcurr - z.creditcurr) FROM ' +
          '  ac_account a ' +
          '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
          'WHERE ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' and ' +
          '  z.entrydate <= :ondate AND z.currkey = :currkey ' +
          AnalyticsReady;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);
        SetTID(ParamByName('currkey'), CurrKey);
        ExecQuery;

        if RecordCount > 0 then
          Result := Fields[0].AsCurrency;
      end
    end
    else
    begin
      with FIBSQL do
      begin
        if Open then
          Close;
        SQL.Text :=
          'SELECT SUM(z.debitcurr - z.creditcurr) as saldo FROM ' +
          '  ac_account a ' +
          '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
          'WHERE ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' and ' +
          '  z.entrydate <= :ondate AND z.currkey = :currkey ' +
          ' GROUP BY ' + MainAnalNameZ;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);
        SetTID(ParamByName('currkey'), CurrKey);

        ExecQuery;
        while not Eof do
        begin
          case BalType of
            gsDebit:
              if FieldByName('saldo').AsCurrency > 0 then
                Result := Result + FieldByName('saldo').AsCurrency;
            gsCredit:
              if FieldByName('saldo').AsCurrency < 0 then
                Result := Result - FieldByName('saldo').AsCurrency;
          end;

          Next;
        end;
      end;
    end;
end;

function  TobjGSFunction.GetEqBalance(const Account: WideString;
      const OnDate: TDateTime; const Analytics: WideString;
      const BalType: TBalanceType): Currency; safecall;
var
  AnalyticsReady: String;
  MainAnalNameB, MainAnalNameE, MainAnalNameZ: string;
  Id: TID;
  AnalyticsReadyB, AnalyticsReadyE: String; 
begin
  Result := 0;
  InitFIBSQL;

  Id := GetAccountKey(Account);

  if Analytics = '' then
  begin
    MainAnalNameB := GetWithAnDefaultSql(id, 'b');
    MainAnalNameE := GetWithAnDefaultSql(id, 'e');
    MainAnalNameZ := GetWithAnDefaultSql(id, 'z');
  end
  else
  begin
    MainAnalNameB := '';
    MainAnalNameE := '';
    MainAnalNameZ := '';
  end;

  FillCalcBalanceDate;
  if FCalcBalanceDate > 0 then
  begin
    AnalyticsReadyB := GetAnalyticsSQL(Analytics, 'b');
    if AnalyticsReadyB > '' then
      AnalyticsReadyB := '  AND ' + AnalyticsReadyB;
    AnalyticsReadyE := GetAnalyticsSQL(Analytics, 'e');
    if AnalyticsReadyE > '' then
      AnalyticsReadyE := '  AND ' + AnalyticsReadyE;
    with FIBSQL do
    begin
      Close;
      SQL.Text :=
        'SELECT ' +
        '  SUM(z.debiteq - z.crediteq) as saldo ' +
        'FROM ' +
        '( ' +
        '  SELECT ' +
        '    b.debiteq, ' +
        '    b.crediteq ' +
          IIF(MainAnalNameB <> '', ', ' + MainAnalNameB, '') +
        '  FROM ' +
        '    ac_account a ' +
        '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '    JOIN ac_entry_balance b ON b.accountkey = a1.id ' +
        '  WHERE ' +
        '    a.id = :accountkey ' +
        '    AND ' + GetCompCondition('b.companykey') +
          IIF(MainAnalNameB = '', AnalyticsReadyB, '') +
        '  UNION ALL ' +
        '  SELECT ' +
          IIF(FCalcBalanceDate > OnDate,
          ' - e.debiteq, - e.crediteq ',
          ' e.debiteq, e.crediteq ') +
          IIF(MainAnalNameE <> '', ', ' + MainAnalNameE, '') +
        '  FROM ' +
        '    ac_account a ' +
        '    JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '    JOIN ac_entry e ON e.accountkey = a1.id ' +
        '  WHERE ' +
        '    a.id = :accountkey ' +
        '    AND ' + GetCompCondition('e.companykey') +
          IIF(FCalcBalanceDate > OnDate,
          ' AND (e.entrydate > :ondate AND e.entrydate < :balancedate) ',
          ' AND (e.entrydate <= :ondate AND e.entrydate >= :balancedate) ') +
          IIF(MainAnalNameE = '', AnalyticsReadyE, '') +
        ') z ' +
          IIF(MainAnalNameZ <> '', 'GROUP BY ' + MainAnalNameZ, '');
      ParamByName('ondate').AsDate := OnDate;
      ParamByName('balancedate').AsDate := FCalcBalanceDate;
      SetTID(ParamByName('accountkey'), Id);
      ExecQuery;

      if RecordCount > 0 then
      begin
        if MainAnalNameB <> '' then
        begin
          while not Eof do
          begin
            case BalType of
              gsDebit:
                if FieldByName('saldo').AsCurrency > 0 then
                  Result := Result + FieldByName('saldo').AsCurrency;
              gsCredit:
                if FieldByName('saldo').AsCurrency < 0 then
                  Result := Result + FieldByName('saldo').AsCurrency;
            end;
            Next;
          end;
        end
        else
          Result := Fields[0].AsCurrency;
      end;
    end
  end
  else

    if MainAnalNameB = '' then
    begin
      with FIBSQL do
      begin
        Close;
        AnalyticsReady := GetAnalyticsSQL(Analytics, 'z');
        if AnalyticsReady > '' then AnalyticsReady := '  AND ' + AnalyticsReady;

        SQL.Text :=
          'SELECT SUM(z.debiteq - z.crediteq) as saldo FROM ' +
          '  ac_account a ' +
          '  JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  JOIN ac_entry z ON z.accountkey = a1.id ' +
          '  AND  ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' and ' +
          '  z.entrydate <= :ondate ' +
          AnalyticsReady;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);
  //      ParamByName('ingroup').AsInteger := IBLogin.Ingroup;
        ExecQuery;

        if RecordCount > 0 then
          Result := Fields[0].AsCurrency;
      end
    end
    else
    begin
      with FIBSQL do
      begin
        Close;

        SQL.Text :=
          'SELECT SUM(z.debiteq - z.crediteq) as saldo FROM ' +
          '  ac_account a ' +
          '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
          '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
          'WHERE ' +
          '  a.id = :accountkey AND ' +
          GetCompCondition('z.companykey') + ' AND ' +
          '  z.entrydate <= :ondate ' +
          'GROUP BY ' + MainAnalNameZ;

        ParamByName('ondate').AsDate := OnDate;
        SetTID(ParamByName('accountkey'), Id);
  //      ParamByName('ingroup').AsInteger := IBLogin.Ingroup;

        ExecQuery;
        while not Eof do
        begin
          case BalType of
            gsDebit:
              if FieldByName('saldo').AsCurrency > 0 then
                Result := Result + FieldByName('saldo').AsCurrency;
            gsCredit:
              if FieldByName('saldo').AsCurrency < 0 then
                Result := Result + FieldByName('saldo').AsCurrency;
          end;

          Next;
        end;
      end;
    end;
end;


function TobjGSFunction.V_SK(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString;
  CurrKey: ATID): Currency;
begin
  Result := GetCurrBalance(Account, OnDate, Analytics, gsCredit, GetTID(CurrKey));
  if Result > 0 then
    Result := 0
  else
    Result := Abs(Result);

end;

function TobjGSFunction.V_SD(const Account: WideString;
  OnDate: TDateTime; const Analytics: WideString;
  CurrKey: ATID): Currency;
begin
  Result := GetCurrBalance(Account, OnDate, Analytics, gsDebit, GetTID(CurrKey));
  if Result < 0 then
    Result := 0
  else
    Result := Result;
end;

function TobjGSFunction.V_OK(const Account: WideString; BDate,
  EDate: TDateTime; const Analytics: WideString;
  CurrKey: ATID): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id :=  GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > '' then
      begin
        AnalyticsReady :=
          '  AND ' + AnalyticsReady;
      end;
      SQL.Text :=
        'SELECT SUM(z.creditcurr) FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate AND ' +
        '  z.currkey = :currkey ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);
//      ParamByName('ingroup').AsInteger := IBLogin.Ingroup;
      SetTID(ParamByName('currkey'), GetTID(CurrKey));
      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.V_OD(const Account: WideString; BDate,
  EDate: TDateTime; const Analytics: WideString;
  CurrKey: ATID): Currency;
var
  IBSQL: TIBSQL;
  AnalyticsReady: String;
  Id: TID;
begin
  Result := 0;
  Id := GetAccountKey(Account);
  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    with IBSQL do
    begin
      AnalyticsReady :=  GetAnalyticsSQL(Analytics, 'z');
      if AnalyticsReady > ''then  AnalyticsReady := '  AND ' + AnalyticsReady;

      SQL.Text :=
        'SELECT SUM(z.debitcurr) FROM ' +
        '  ac_account a ' +
        '  LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND a1.rb <= a.rb ' +
        '  LEFT JOIN ac_entry z ON z.accountkey = a1.id ' +
        'WHERE ' +
        '  a.id = :accountkey AND ' +
        GetCompCondition('z.companykey') + ' and ' +
        '  z.entrydate >= :bdate and z.entrydate <= :edate AND ' +
        '  z.currkey = :currkey ' +
        AnalyticsReady;

      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName(fnAccountKey), Id);
//      ParamByName('ingroup').AsInteger := IBLogin.Ingroup;
      SetTID(ParamByName('currkey'), GetTID(CurrKey));
      ExecQuery;

      if not Eof then
        Result := Fields[0].AsCurrency;
    end;
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.GetAccountKey(const Account: String): TID;
begin
  if CheckRUID(Account) then
  begin
    Result := gdcBaseManager.GetIdByRUIDString(Account);
  end else
  begin
    // ��� ������� �� �����, ��� ��� ����� � ���������
    // �������������. ��������� ��� ����� �������� (2-3 �������)
    // ��� ����� ��������� �� �������� ��������
    if GetTID(Account, -1) > 99999 then
      Result := GetTID(Account)
    else
      Result := AcctUtils.GetAccountKeyByAlias(Account);
  end;

  if Result = 0 then
    raise Exception.Create(Format(MSG_ACCOUNTINCORRECT, [Account]));
end;

{function TobjGSFunction.GetWithAnDefault(AccountID: Integer): String;
begin
  FIBSQL.Close;

  FIBSQL.SQL.Text :=
    'SELECT rf.fieldname FROM ac_accanalyticsext aa ' +
    '  JOIN at_relation_fields rf ON rf.id = aa.valuekey ' +
    'WHERE ' +
    '  aa.accountkey = :id';

  FIBSQL.ParamByName(fnId).AsInteger := AccountId;
  FIBSQL.ExecQuery;

  try
    if FIBSQL.RecordCount = 0 then
      Result := ''
    else
      Result := FIBSQL.FieldByName(fnfieldName).AsString;
  finally
    FIBSQL.Close;
  end;
end;}

function TobjGSFunction.GetWithAnDefaultSql(AccountID: TID;
  const TableAlias: String): String;
begin
  FIBSQL.Close;

  FIBSQL.SQL.Text :=
    'SELECT rf.fieldname FROM ac_accanalyticsext aa ' +
    '  JOIN at_relation_fields rf ON rf.id = aa.valuekey ' +
    'WHERE ' +
    '  aa.accountkey = :id';

  SetTID(FIBSQL.ParamByName(fnId), AccountId);
  FIBSQL.ExecQuery;

  try
    if FIBSQL.RecordCount = 0 then
      Result := ''
    else
    begin
      while not FIBSQL.Eof do
      begin
        Result := Result + TableAlias + '.' + FIBSQL.FieldByName(fnfieldName).AsString + ' ,';
        FIBSQL.next;
      end;
      Result := Copy(Result,0, Length(Result)-2);
    end;
  finally
    FIBSQL.Close;
  end;
end;

function TobjGSFunction.V_O(const AccDeb, AccCred: WideString; BDate,
  EDate: TDateTime; const AnalyticsDeb, AnalyticsCred: WideString;
  CurrKey: ATID): Currency;
var
  IBSQL: TIBSQL;
  DAccountKey, CAccountKey: TID;
  AnalDebReady, AnalCredReady: String;
begin
  Result := 0;

  IBSQL := TIBSQL.Create(nil);
  try
    SetupTransaction(IBSQL);
    DAccountKey := GetAccountKey(AccDeb);
    CAccountKey := GetAccountKey(AccCred);

    with IBSQL do
    begin
      Transaction := gdcBaseManager.ReadTransaction;

      AnalDebReady :=  GetAnalyticsSQL(AnalyticsDeb, 'ed');
      if AnalDebReady > '' then
      begin
        AnalDebReady :=
          '  AND ' +
          '  (ed.accountpart = ''D'' AND ' +
          AnalDebReady + ' ) ';
      end;
      AnalCredReady := GetAnalyticsSQL(AnalyticsCred, 'ec');
      if AnalCredReady > '' then
      begin
        AnalCredReady :=
          '  AND ' +
          '  (ec.accountpart = ''C'' AND ' +
          AnalCredReady + ' ) ';
      end;

      SQL.Text :=
        'SELECT ' +
        '  SUM(iif(ec.issimple = 1, ed.debitcurr, ec.creditcurr)) ' +
        'FROM ' +
        '  ac_entry ed ' +
        '  JOIN ac_entry ec ON ed.recordkey = ec.recordkey AND ' +
        '    ed.accountpart <> ec.accountpart ' +
        'WHERE ' +
        '  (ed.entrydate >= :bdate AND ed.entrydate <= :edate) AND ' +
        '  ((ed.accountpart = ''D'' AND ed.accountkey IN (' + TID2S(DAccountKey) + ')) AND ' +
        '  (ec.accountpart = ''C'' AND ec.accountkey IN (' + TID2S(CAccountKey) + '))) AND ' +
        '  ed.currkey = :currkey AND ec.currkey = :currkey AND ' +
        GetCompCondition('ed.companykey') +
        AnalDebReady +
        AnalCredReady;


      ParamByName('bdate').AsDate := BDate;
      ParamByName('edate').AsDate := EDate;
      SetTID(ParamByName('currkey'), GetTID(CurrKey));

      ExecQuery;

      while not Eof do
      begin
        Result := Result +  Fields[0].AsCurrency;
        Next;
      end;
    end;
  finally
    IBSQL.Free;
  end;
end;

procedure TobjGSFunction.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
  if FGsFunctionNotifier = nil then
  begin
    FGsFunctionNotifier := TGsFunctionNotifier.Create(nil);
    FGsFunctionNotifier.FGSFunction := Self;
  end;

  FGsFunctionNotifier.FTransaction := Value;
  if Value <> nil then
  begin
    Value.FreeNotification(FGsFunctionNotifier);
  end;
end;

procedure TobjGSFunction.SetupTransaction(SQL: TIBSQl);
begin
  if (FTransaction <> nil) and FTransaction.InTransaction then
    SQL.Transaction := FTransaction
  else
    SQL.Transaction := gdcBaseManager.ReadTransaction;  
end;

function TobjGSFunction.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(FTransaction) as IgsIBTransaction;
end;

procedure TobjGSFunction.Set_Transaction(const Value: IgsIBTransaction);
begin
  Transaction := InterfaceToObject(Value) as TIBTransaction
end;

{ TgsSetTaxFunction }

procedure TobjGSFunction.FillCalcBalanceDate;
begin
  FCalcBalanceDate := GetCalculatedBalanceDate;
end;

function TobjGSFunction.DateAddBank(const Interval: WideString; Number: Integer;
  DateValue: TDateTime; TBLCALID: ATID = -1): TDateTime;
var
  IBSQL: TIBSQL;
  WorkingDate: TDate;
  HourValue, MinuteValue, SecondValue, MSecondValue: Word;
  Factor: Integer;

  function FormResultDate: TDateTime;
  begin
    Result := WorkingDate;
    ReplaceTime(Result, EncodeTime(HourValue, MinuteValue, SecondValue, MSecondValue));
  end;

  function IsWeekEnd(const ADate: TDateTime): Boolean;
  begin
    Result := Sysutils.DayOfWeek(ADate) in [1, 7];
  end;

  function IsHolyday(const ADate: TDateTime): Boolean;
  begin
    IBSQL.ParamByName('THEDATE').AsDateTime := ADate;
    IBSQL.ExecQuery;
    Result := not IBSQL.EOF;
    IBSQL.Close;
  end;

  function IsDayOff(const ADate: TDateTime): Boolean;
  begin
    if TBLCALID > 0 then
      Result := IsHolyday(ADate) // ���� ������� ������, �� �������� ���� ��� ����� ���� �������
    else
      Result := IsWeekEnd(ADate) or IsHolyday(ADate);
  end;

  procedure LocIncDay(const AValue: Integer);
  var
    DayCounter: Integer;
  begin
    if Factor > 0 then
      DayCounter := AValue
    else
      DayCounter := Abs(AValue);

    while DayCounter > 0 do
    begin
      WorkingDate := WorkingDate + Factor;
      if not IsDayOff(FormResultDate) then
        Dec(DayCounter);
    end;
  end;

  procedure LocIncYear(const AValue: Integer);
  var
    YearValue, MonthValue, DayValue: Word;
  begin
    DecodeDate(WorkingDate, YearValue, MonthValue, DayValue);
    YearValue := YearValue + AValue;
    // ���� ���� ���� 29 ������� � ������� �� �� ���������� ���, �������� �� 28 �������
    if not IsLeapYear(YearValue) and (MonthValue = 2) and (DayValue = 29) then
      DayValue := 28;
    WorkingDate := EncodeDate(YearValue, MonthValue, DayValue);
    // ���� ������ �� �������� ����, �� �������� �� ��������� �������
    if IsDayOff(WorkingDate) then
      LocIncDay(1);
  end;

  procedure LocIncQuarter(const AValue: Integer);
  begin
    WorkingDate := Sysutils.IncMonth(WorkingDate, AValue * 3);
    // ���� ������ �� �������� ����, �� �������� �� ��������� �������
    if IsDayOff(WorkingDate) then
      LocIncDay(1);
  end;

  procedure LocIncMonth(const AValue: Integer);
  begin
    WorkingDate := Sysutils.IncMonth(WorkingDate, AValue);
    // ���� ������ �� �������� ����, �� �������� �� ��������� �������
    if IsDayOff(WorkingDate) then
      LocIncDay(1);
  end;

  procedure LocIncWeek(const AValue: Integer);
  begin
    WorkingDate := WorkingDate + AValue * 7;
    // ���� ������ �� �������� ����, �� �������� �� ��������� �������
    if IsDayOff(WorkingDate) then
      LocIncDay(1);
  end;

  procedure LocIncHour(const AValue: Integer);
  var
    LocalValue: Integer;
  begin
    LocalValue := HourValue + AValue;
    if LocalValue >= 0 then
    begin
      HourValue := LocalValue mod 24;
      if LocalValue >= 24 then
        LocIncDay(LocalValue div 24);
    end
    else
    begin
      HourValue := 24 + (LocalValue mod 24);
      LocIncDay((-24 + LocalValue) div 24);
    end;
  end;

  procedure LocIncMinute(const AValue: Integer);
  var
    LocalValue: Integer;
  begin
    LocalValue := MinuteValue + AValue;
    if LocalValue >= 0 then
    begin
      MinuteValue := LocalValue mod 60;
      if LocalValue >= 60 then
        LocIncHour(LocalValue div 60);
    end
    else
    begin
      MinuteValue := 60 + (LocalValue mod 60);
      LocIncHour((-60 + LocalValue) div 60);
    end;
  end;

  procedure LocIncSecond(const AValue: Integer);
  var
    LocalValue: Integer;
  begin
    LocalValue := SecondValue + AValue;
    if LocalValue >= 0 then
    begin
      SecondValue := LocalValue mod 60;
      if LocalValue >= 60 then
        LocIncMinute(LocalValue div 60);
    end
    else
    begin
      SecondValue := 60 + (LocalValue mod 60);
      LocIncMinute((-60 + LocalValue) div 60);
    end;
  end;

begin
  Result := DateValue;
  WorkingDate := DateValue;

  if Number >= 0 then
    Factor := 1
  else
    Factor := -1;

  IBSQL := TIBSQL.Create(nil);
  try
    // ���������� ����������
    SetupTransaction(IBSQL);
    // �������� �����
    DecodeTime(DateValue, HourValue, MinuteValue, SecondValue, MSecondValue);
    // ���������� ������ ��� ����������� ��������� ���
    if TBLCALID > 0 then
    begin
      // ���� ������ ���� ������
      IBSQL.SQL.Text := 'SELECT id FROM wg_tblcalday WHERE tblcalkey = :tblkey AND theday = :thedate AND workday = 0';
      SetTID(IBSQL.ParamByName('TBLKEY'), GetTID(TBLCALID));
    end else
      IBSQL.SQL.Text := 'SELECT id FROM wg_holiday WHERE holidaydate = :thedate';

    if UpperCase(Interval) = 'YYYY' then           // ���
    begin
      LocIncYear(Number);
    end
    else if UpperCase(Interval) = 'Q' then         // �������
    begin
      LocIncQuarter(Number);
    end
    else if UpperCase(Interval) = 'M' then         // �����
    begin
      LocIncMonth(Number);
    end
    else if (UpperCase(Interval) = 'Y')
      or (UpperCase(Interval) = 'D')
      or (UpperCase(Interval) = 'W') then          // ����
    begin
      LocIncDay(Number);
    end
    else if UpperCase(Interval) = 'WW' then        // ������
    begin
      LocIncWeek(Number);
    end
    else if UpperCase(Interval) = 'H' then         // ���
    begin
      LocIncHour(Number);
    end
    else if UpperCase(Interval) = 'N' then         // ������
    begin
      LocIncMinute(Number);
    end
    else if UpperCase(Interval) = 'S' then         // �������
    begin
      LocIncSecond(Number);
    end;

    Result := FormResultDate;            
  finally
    IBSQL.Free;
  end;
end;

function TobjGSFunction.GetAccountKeyByAlias(
  const AnAlias: WideString): ATID;
begin
  Result := Self.GetAccountKey(AnAlias);
end;

function TobjGSFunction.GetCurrNumeral(ACurrKey: ATID;
  const AFormat: WideString; AValue, ARounding: Double; ACase,
  AParts: Integer; const ASubst, ADecimalSeparator,
  AThousandSeparator: WideString): WideString;
begin
  Result := gd_convert.GetCurrNumeral(GetTID(ACurrKey), AFormat, AValue, ARounding,
    ACase, AParts, ASubst, ADecimalSeparator, AThousandSeparator);
end;

function TobjGSFunction.GetNumeral(const AFormat: WideString; AValue,
  ARounding: Double; AFracBase, ACase, AParts: Integer;
  const ANames: WideString): WideString;
begin
  Result := gd_convert.GetNumeral(AFormat, AValue, ARounding, AFracBase,
    ACase, AParts, ANames);
end;

function TobjGSFunction.MulDiv(ANumber, ANumerator, ADenominator: Double;
  ARoundMethod, ADecPlaces: Integer): Double;
begin
  Result := gd_convert.MulDiv(ANumber, ANumerator, ADenominator,
    ARoundMethod, ADecPlaces);
end;


{ TGsFunctionNotifier }

procedure TGsFunctionNotifier.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FTransaction) then
  begin
    if FGSFunction <> nil then
    begin
      FGSFunction.Transaction := nil;
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TobjGSFunction, CLASS_gs_GSFunction,
    ciMultiInstance, tmApartment);
  gsFunction := TobjGSFunction.Create as IDispatch;

finalization
  gsFunction := nil;
end.
