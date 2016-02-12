unit gdvAcctLedger;

interface

uses
  classes, gdv_AvailAnalytics_unit, AcctStrings, AcctUtils, gdvAcctBase,
  at_classes, contnrs, DB, ibsql, gdv_AcctConfig_unit;

type
  TgdvAcctAnalyticLevels = class
  private
    FField: TatRelationField;
    FLevels: TStrings;
    procedure SetField(const Value: TatRelationField);
    procedure SetValue(const Value: String);
    function GetValue: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CheckProcedure;
    function SPName: String;
    function IsEmpty: Boolean;

    property Field: TatRelationField read FField write SetField;
    property Levels: TStrings read FLevels;
    property Value: String read GetValue write SetValue;
  end;

  TgdvCorrFieldInfo = class
  private
    FAccount: Integer;
    FDisplayAccount: Integer;
    FCaption: string;
    FAccountPart: string;
    procedure SetAccount(const Value: Integer);
    procedure SetCaption(const Value: string);
    procedure SetDisplayAccount(const Value: Integer);
    procedure SetAccountPart(const Value: string);
    function GetAlias: string;
  public
    property Caption: string read FCaption write SetCaption;
    property Account: Integer read FAccount write SetAccount;
    property DisplayAccount: Integer read FDisplayAccount write SetDisplayAccount;
    property AccountPart: string read FAccountPart write SetAccountPart;
    property Alias: string read GetAlias;
  end;

  TgdvCorrFieldInfoList = class(TObjectList)
  private
    function AddFieldInfo(Caption: string; Account, DisplayAccount: Integer): Integer;
    function GetItems(Index: Integer): TgdvCorrFieldInfo;
  public
    procedure Assign(Source: TgdvCorrFieldInfoList);
    property Items[Index: Integer]: TgdvCorrFieldInfo read GetItems;
  end;

  TgdvLedgerFieldInfo = class(TgdvFieldInfo)
  private
    FAccountKey: Integer;
    FAccountPart: string;
    procedure SetAccountKey(const Value: Integer);
    procedure SetAccountPart(const Value: string);
  public
    property AccountKey: Integer read FAccountKey write SetAccountKey;
    property AccountPart: string read FAccountPart write SetAccountPart;
  end;

  TgdvLedgerTotalBlocks = class;

  TgdvLedgerTotal = class
  private
    FTotal: boolean;
    FField: TField;
    FValueField: TField;
    FFieldName: string;
    FValueFieldName: string;
    FTotalBlocks: TgdvLedgerTotalBlocks;
    FatRelationField: TatRelationField;
    procedure SetField(const Value: TField);
    procedure SetTotal(const Value: boolean);
    procedure SetValueField(const Value: TField);
    function GetTotalBlocks: TgdvLedgerTotalBlocks;
    procedure SetFieldName(const Value: string);
    procedure SetValueFieldName(const Value: string);
    procedure SetatRelationField(const Value: TatRelationField);
  public
    destructor Destroy; override;
    procedure InitField(DataSet: TDataSet);
    procedure Calc;
    procedure SetValues;
    procedure DropValues;

    property Field: TField read FField write SetField;
    property ValueField: TField read FValueField write SetValueField;
    property Total: boolean read FTotal write SetTotal;
    property TotalBlocks: TgdvLedgerTotalBlocks read GetTotalBlocks;
    property FieldName: string read FFieldName write SetFieldName;
    property ValueFieldName: string read FValueFieldName write SetValueFieldName;
    property atRelationField: TatRelationField read FatRelationField write SetatRelationField;
  end;

  TgdvLedgerTotals = class(TObjectList)
  private
    function GetTotals(Index: Integer): TgdvLedgerTotal;
  public
    destructor Destroy; override;
    procedure InitField(DataSet: TDataSet);
    procedure Calc;
    procedure SetValues;
    procedure DropValues;

    property Totals[Index: Integer]: TgdvLedgerTotal read GetTotals; default;
  end;

  TgdvLedgerTotalUnit = class
  private
    FValue: Currency;
    FField: TField;
    FFieldName: string;
    procedure SetField(const Value: TField);
    procedure SetValue(const Value: Currency);
    procedure SetFieldName(const Value: string);
    function GetField: TField;
  public
    procedure InitField(DataSet: TDataSet);
    property FieldName: string read FFieldName write SetFieldName;
    property Field: TField read GetField write SetField;
    property Value: Currency read FValue write SetValue;
  end;

  TgdvCustomLedgerTotalBlockClass = class of TgdvCustomLedgerTotalBlock;
  TgdvCustomLedgerTotalBlock = class(TObjectList)
  private
    FEndCredit: TgdvLedgerTotalUnit;
    FCredit: TgdvLedgerTotalUnit;
    FBeginDebit: TgdvLedgerTotalUnit;
    FEndDebit: TgdvLedgerTotalUnit;
    FDebit: TgdvLedgerTotalUnit;
    FBeginCredit: TgdvLedgerTotalUnit;
    FBlockName: string;

    procedure SetBeginCredit(const Value: TgdvLedgerTotalUnit);
    procedure SetBeginDebit(const Value: TgdvLedgerTotalUnit);
    procedure SetCredit(const Value: TgdvLedgerTotalUnit);
    procedure SetDebit(const Value: TgdvLedgerTotalUnit);
    procedure SetEndCredit(const Value: TgdvLedgerTotalUnit);
    procedure SetEndDebit(const Value: TgdvLedgerTotalUnit);
    procedure SetBlockName(const Value: string);
    function GetFields(Index: Integer): TgdvLedgerTotalUnit;

  protected
    procedure DoCalc; virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear; override;
    procedure Calc; virtual;
    procedure DropValues; virtual;
    procedure Drop;
    procedure SetValues;
    procedure InitFields(DataSet: TDataSet);

    property BlockName: string read FBlockName write SetBlockName;
    property BeginDebit: TgdvLedgerTotalUnit read FBeginDebit write SetBeginDebit;
    property BeginCredit: TgdvLedgerTotalUnit read FBeginCredit write SetBeginCredit;
    property Debit: TgdvLedgerTotalUnit read FDebit write SetDebit;
    property Credit: TgdvLedgerTotalUnit read FCredit write SetCredit;
    property EndDebit: TgdvLedgerTotalUnit read FEndDebit write SetEndDebit;
    property EndCredit: TgdvLedgerTotalUnit read FEndCredit write SetEndCredit;

    property Fields[Index: Integer]: TgdvLedgerTotalUnit read GetFields;
  end;

  TgdvLedgerTotalBlocks = class(TObjectList)
  private
    function GetBlocks(Index: Integer): TgdvCustomLedgerTotalBlock;
  public
    procedure Calc;
    procedure SetValues;
    procedure DropValues;

    procedure InitFields(DataSet: TDataSet);
    property Blocks[Index: Integer]: TgdvCustomLedgerTotalBlock read GetBlocks;
  end;

  TgdvSimpleLedgerTotalBlock = class(TgdvCustomLedgerTotalBlock)
  protected
    procedure DoCalc; override;
  end;

  TgdvEncancedLedgerTotalBlock = class(TgdvCustomLedgerTotalBlock)
  protected
    procedure DoCalc; override;
  end;

  TgdvStorageLedgerTotalBlock = class(TgdvCustomLedgerTotalBlock)
  protected
    procedure DoCalc; override;
  end;

  TgdvStorageLedgerTotalBlock1 = class(TgdvCustomLedgerTotalBlock)
  protected
    FDroped: Boolean;
    procedure DoCalc; override;
  public
    constructor Create; override; 
    procedure DropValues; override;
  end;

  TgdvAcctLedger = class(TgdvAcctBase)
  private
    FNcuDebitAliases: TStrings;
    FNcuCreditAliases: TStrings;
    FCurrDebitAliases: TStrings;
    FCurrCreditAliases: TStrings;
    FEQDebitAliases: TStrings;
    FEQCreditAliases: TStrings;
    FQuantDebitAliases: TStrings;
    FQuantCreditAliases: TStrings;

    FTotals: TgdvLedgerTotals;
    FNcuTotalBlock: TgdvCustomLedgerTotalBlock;
    FCurrTotalBlock: TgdvCustomLedgerTotalBlock;
    FEQTotalBlock: TgdvCustomLedgerTotalBlock;
    FQuantityTotalBlock: TgdvCustomLedgerTotalBlock;

    FDebitCorrFieldInfoList: TgdvCorrFieldInfoList;
    FCreditCorrFieldInfoList: TgdvCorrFieldInfoList;
    FCorrFieldInfoList: TgdvCorrFieldInfoList;

    FEntryDateIsFirst: Boolean;
    FEntryDateInFields: Boolean;

    FSumJoinClause: string;
    FDebitSumSelectClause: string;
    FCreditSumSelectClause: string;
    FDebitCurrSumSelectClause: string;
    FCreditCurrSumSelectClause: string;
    FDebitEQSumSelectClause: string;
    FCreditEQSumSelectClause: string;

    FQuantityJoinClause: string;
    FDebitQuantitySelectClause: string;
    FCreditQuantitySelectClause: string;
    FDebitCurrQuantitySelectClause: string;
    FCreditCurrQuantitySelectClause: string;
    FDebitEQQuantitySelectClause: string;
    FCreditEQQuantitySelectClause: string;

    FHavingClause: string;

    function IndexOfAnalyticLevel(AFieldName: String): Integer;
    procedure CreditCorrAccounts(const Strings: TgdvCorrFieldInfoList);
    procedure DebitCorrAccounts(const Strings: TgdvCorrFieldInfoList);

    procedure CheckAnalyticLevelProcedures;
    procedure UpdateEntryDateIsFirst;
    
    //процедура возвращает СКЛ запрос для вычисления начального сальдо
    //когда выбрана фиксированная аналитика и дата стоит первой аналитикой
    //для группировки
    procedure SaldoBeginSQL(const SQL: TIBSQL);
  protected
    FSQLHandle: Integer;

    FShowDebit: Boolean;
    FShowCredit: Boolean;
    FShowCorrSubAccounts: Boolean;
    FEnchancedSaldo: Boolean;
    FSumNull: Boolean;

    FAcctAnalyticLevels: TObjectList;
    FAcctGroupBy: TgdvAnalyticsList;

    function AccountInClause(Alias: string): string;
    procedure CorrAccounts(const Strings: TgdvCorrFieldInfoList; AccountPart: string = '');

    function GetHavingClause: string;
    function GetSumJoinClause: string;
    function GetQuantityJoinClause: string;

    function GetDebitSumSelectClause: string;
    function GetCreditSumSelectClause: string;
    function GetDebitCurrSumSelectClause: string;
    function GetCreditCurrSumSelectClause: string;
    function GetDebitEQSumSelectClause: string;
    function GetCreditEQSumSelectClause: string;
    function GetDebitQuantitySelectClause: string;
    function GetCreditQuantitySelectClause: string;

    function GetDebitSumSelectClauseBalance: String;
    function GetCreditSumSelectClauseBalance: String;
    function GetDebitCurrSumSelectClauseBalance: String;
    function GetCreditCurrSumSelectClauseBalance: String;
    function GetDebitEQSumSelectClauseBalance: String;
    function GetCreditEQSumSelectClauseBalance: String;

    procedure AddLedgerFieldInfo(FieldName, Caption, DisplayFormat: string;
      Visible, Condition: Boolean; AccountKey: Integer; AccountPart: string;
      DisplayField: string = '');

    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;

    procedure DoBeforeBuildReport; override;
    procedure DoBuildSQL; override;
    procedure DoAfterBuildReport; override;

    procedure SetSQLParams; override;
    procedure SetDefaultParams; override;

    function LargeSQLErrorMessage: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Добавляет аналитику по которой будут сгруппированы данные
    procedure AddGroupBy(GroupFieldName: String; ShowTotal: Boolean = False; const ListFieldName: String = ''); overload;
    procedure AddGroupBy(Analytic: TgdvAnalytics); overload;
    // Добавляет уровни аналитики
    procedure AddAnalyticLevel(AnalyticName: String; Levels: String);

    procedure Clear; override;
    function InternalMovementClause(TableAlias: String = 'e'): string; override;

    property Totals: TgdvLedgerTotals read FTotals write FTotals;

    property ShowDebit: Boolean read FShowDebit write FShowDebit;
    property ShowCredit: Boolean read FShowCredit write FShowCredit;
    property ShowCorrSubAccounts: Boolean read FShowCorrSubAccounts write FShowCorrSubAccounts;
    property EnchancedSaldo: Boolean read FEnchancedSaldo write FEnchancedSaldo;
    property SumNull: Boolean read FSumNull write FSumNull;
  end;

procedure Register;

implementation

uses
  sysutils, IBDatabase, IBHeader, gdcBaseInterface, gd_KeyAssoc,
  mdf_MetaData_unit, gdcConstants, gd_common_functions;

const
  cAccountPartDebit = 'D';
  cAccountPartCredit = 'C';
  cNcuDebitFieldNameTemplate = 'NCU_DEBIT_%s';
  cNcuCreditFieldNameTemplate = 'NCU_CREDIT_%s';
  cCurrDebitFieldNameTemplate = 'CURR_DEBIT_%s';
  cCurrCreditFieldNameTemplate = 'CURR_CREDIT_%s';
  cEqDebitFieldNameTemplate = 'EQ_DEBIT_%s';
  cEqCreditFieldNameTemplate = 'EQ_CREDIT_%s';
  cCaptionDebit = 'Д - K%s';
  cCaptionCredit = 'К - Д%s';
  cCaptionDebitCurr = 'Д - K%s, вал';
  cCaptionCreditCurr = 'К - Д%s, вал';
  cCaptionDebitEQ = 'Д - K%s, экв';
  cCaptionCreditEQ = 'К - Д%s, экв';

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctLedger]);
end;

{ TgdvAcctLedger }

constructor TgdvAcctLedger.Create(AOwner: TComponent);
begin
  inherited;

  FAcctAnalyticLevels := TObjectList.Create;
  FAcctGroupBy := TgdvAnalyticsList.Create;

  FDebitCorrFieldInfoList := TgdvCorrFieldInfoList.Create;
  FCreditCorrFieldInfoList := TgdvCorrFieldInfoList.Create;
  FCorrFieldInfoList := TgdvCorrFieldInfoList.Create;

  FNcuDebitAliases := TStringList.Create;
  FNcuCreditAliases := TStringList.Create;
  FCurrDebitAliases := TStringList.Create;
  FCurrCreditAliases := TStringList.Create;
  FEQDebitAliases := TStringList.Create;
  FEQCreditAliases := TStringList.Create;
  FQuantDebitAliases := TStringList.Create;
  FQuantCreditAliases := TStringList.Create;

  FSumJoinClause := '';
  FDebitSumSelectClause := '';
  FCreditSumSelectClause := '';
  FDebitCurrSumSelectClause := '';
  FCreditCurrSumSelectClause := '';
  FDebitEQSumSelectClause := '';
  FCreditEQSumSelectClause := '';

  FQuantityJoinClause := '';
  FDebitQuantitySelectClause := '';
  FCreditQuantitySelectClause := '';
  FDebitCurrQuantitySelectClause := '';
  FCreditCurrQuantitySelectClause := '';
  FDebitEQQuantitySelectClause := '';
  FCreditEQQuantitySelectClause := '';

  FHavingClause := '';
end;

destructor TgdvAcctLedger.Destroy;
begin
  FAcctAnalyticLevels.Free;
  FAcctGroupBy.Free;

  FDebitCorrFieldInfoList.Free;
  FCreditCorrFieldInfoList.Free;
  FCorrFieldInfoList.Free;

  FNcuDebitAliases.Free;
  FNcuCreditAliases.Free;
  FCurrDebitAliases.Free;
  FCurrCreditAliases.Free;
  FEQDebitAliases.Free;
  FEQCreditAliases.Free;
  FQuantDebitAliases.Free;
  FQuantCreditAliases.Free;

  inherited;
end;

procedure TgdvAcctLedger.Clear;
begin
  inherited;

  FDebitCorrFieldInfoList.Clear;
  FCreditCorrFieldInfoList.Clear;
  FCorrFieldInfoList.Clear;

  FNcuDebitAliases.Clear;
  FNcuCreditAliases.Clear;
  FCurrDebitAliases.Clear;
  FCurrCreditAliases.Clear;
  FEQDebitAliases.Clear;
  FEQCreditAliases.Clear;
  FQuantDebitAliases.Clear;
  FQuantCreditAliases.Clear;

  FAcctGroupBy.Clear;
  FAcctAnalyticLevels.Clear;

  FSumJoinClause := '';
  FDebitSumSelectClause := '';
  FCreditSumSelectClause := '';
  FDebitCurrSumSelectClause := '';
  FCreditCurrSumSelectClause := '';
  FDebitEQSumSelectClause := '';
  FCreditEQSumSelectClause := '';

  FQuantityJoinClause := '';
  FDebitQuantitySelectClause := '';
  FCreditQuantitySelectClause := '';
  FDebitCurrQuantitySelectClause := '';
  FCreditCurrQuantitySelectClause := '';
  FDebitEQQuantitySelectClause := '';
  FCreditEQQuantitySelectClause := '';

  FHavingClause := '';
end;

procedure TgdvAcctLedger.AddGroupBy(Analytic: TgdvAnalytics);
begin
  if Assigned(Analytic) then
    FAcctGroupBy.Add(Analytic);
end;

procedure TgdvAcctLedger.AddGroupBy(GroupFieldName: String; ShowTotal: Boolean = False; const ListFieldName: String = '');
var
  A: TgdvAnalytics;
  FieldName, Caption, Additional: String;
  Field: TatRelationField;
begin
  if GroupFieldName <> '' then
  begin
    FieldName := '';
    Caption := '';
    Additional := '';
    Field := nil;

    if AnsiCompareText(GroupFieldName, 'YEAR') = 0 then
    begin
      FieldName := 'YEAR';
      Caption := 'Год';
      Additional := '3';
    end
    else
    begin
      if AnsiCompareText(GroupFieldName, 'QUARTER') = 0 then
      begin
        FieldName := 'QUARTER';
        Caption := 'Квартал';
        Additional := '4';
      end
      else
      begin
        if AnsiCompareText(GroupFieldName, MONTH) = 0 then
        begin
          FieldName := MONTH;
          Caption := 'Месяц';
          Additional := '1';
        end
        else
        begin
          Field := atDatabase.FindRelationField(AC_ENTRY, UpperCase(GroupFieldName));
          if Assigned(Field) then
          begin
            FieldName := Field.FieldName;
            Caption := Field.LName;
          end;  
        end;
      end;
    end;

    A := TgdvAnalytics.Create;
    A.FieldName := FieldName;
    A.Caption := Caption;
    A.Field := Field;
    A.Additional := Additional;
    A.Total := ShowTotal;
    A.SetListFieldByFieldName(ListFieldName);
    Self.AddGroupBy(A);
  end;
end;

procedure TgdvAcctLedger.AddAnalyticLevel(AnalyticName: String; Levels: String);
var
  I: Integer;
  AnalyticLevel: TgdvAcctAnalyticLevels;
  F: TatRelationField;
  TempLevels: String;
begin
  if (AnalyticName <> '') and (Levels <> '') then
  begin
    // Возможно у нас уже есть уровни по этой аналитике
    for I := 0 to FAcctAnalyticLevels.Count - 1 do
    begin
      if TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Field.FieldName = AnalyticName then
      begin
        TempLevels := TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Value;
        TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Value := TempLevels + ',' + Levels;
        Exit;
      end;
    end;
    // Если это уровни по новой аналитике
    if UpperCase(AnalyticName) = 'DOCUMENTTYPEKEY' then
      F := atDatabase.FindRelationField('GD_DOCUMENT', AnalyticName)
    else
      F := atDatabase.FindRelationField(AC_ENTRY, AnalyticName);
    if Assigned(F) then
    begin
      AnalyticLevel := TgdvAcctAnalyticLevels.Create;
      AnalyticLevel.Field := F;
      AnalyticLevel.Value := Levels;
      FAcctAnalyticLevels.Add(AnalyticLevel);
    end
    else
      raise Exception.Create('Неизвестное поле');
  end;
end;

procedure TgdvAcctLedger.DoBeforeBuildReport;
var
  I: Integer;
  ibsql: TIBSQL;
  Tr: TIBTransaction;
  DontBalanceAnalytic: String;
begin
  inherited;

  // Поищем аналитику USR$GS_DOCUMENT, если такая есть то будем строить старым методом
  // Также старым методом будем строить если есть групировка по типу документа
  if FUseEntryBalance then
  begin
    DontBalanceAnalytic := GetDontBalanceAnalyticList;
    for I := 0 to FAcctGroupBy.Count - 1 do
      if (AnsiPos(';' + FAcctGroupBy.Analytics[I].FieldName + ';', DontBalanceAnalytic) > 0)
        or (FAcctGroupBy.Analytics[I].FieldName = 'DOCUMENTTYPEKEY') then
      begin
        FUseEntryBalance := False;
        Break;
      end;
  end;

  if not FMakeEmpty then
  begin
    UpdateEntryDateIsFirst;

    if (FAccounts.Count > 0) or
      ((FAcctConditions.Count > 0) and FEntryDateIsFirst) then
    begin
      FSQLHandle := gdcBaseManager.GetNextID;

      Tr := TIBTransaction.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        Tr.StartTransaction;
        ibsql := TIBSQL.Create(nil);
        try
          ibsql.Transaction := Tr;
          //В случае если аналитика по дате стоит первой и заданы фиксированные
          //значения аналитик то в таб. AC_LEDGER_ENTRIES заносим Ид всех проводок,
          //удовлет. заданным условием в противном случае в таб. AC_LEDGER_ACCOUNTS
          //заносим ИД счетов по которым строится журнал
          if (FAccounts.Count > 0) and (not ((FAcctConditions.Count > 0) and FEntryDateIsFirst)) then
          begin
            ibsql.SQL.Text := 'INSERT INTO AC_LEDGER_ACCOUNTS(ACCOUNTKEY, SQLHANDLE) ' +
              'VALUES(:ACCOUNTKEY, :SQLHANDLE)';
            for I := 0 to FAccounts.Count - 1 do
            begin
              ibsql.ParamByName('accountkey').AsInteger := FAccounts.Keys[I];
              ibsql.ParamByName('sqlhandle').AsInteger := FSQLHandle;
              ibsql.ExecQuery;
              ibsql.Close;
            end;
          end;

          if (FAcctConditions.Count > 0) and FEntryDateIsFirst then
          begin
            ibsql.SQL.Clear;
            ibsql.SQL.Add('INSERT INTO ac_ledger_entries (entrykey, sqlhandle)');
            ibsql.SQL.Add('SELECT');
            ibsql.SQL.Add('e.id,');
            ibsql.SQL.Add(IntToStr(FSQLHandle));
            ibsql.SQL.Add('FROM ac_entry e LEFT JOIN ac_record r ON r.id = e.recordkey');
            ibsql.SQL.Add(GetJoinTableClause('e'));
            ibsql.SQL.Add('WHERE');
            if FAccounts.Count > 0 then
              ibsql.SQL.Add('e.accountkey IN (' + IDList(FAccounts) + ') AND');
            ibsql.SQL.Add('e.entrydate >= :begindate AND');
            ibsql.SQL.Add('e.entrydate <= :enddate AND');
            ibsql.SQL.Add('r.companykey IN (' + FCompanyList + ') AND');
            ibsql.SQL.Add(Self.GetCondition('e'));
            ibsql.ParamByName('begindate').AsDateTime := FDateBegin;
            ibsql.ParamByName('enddate').AsDateTime := FDateEnd;
            ibsql.ExecQuery;
          end;
        finally
          ibsql.Free;
        end;
        Tr.Commit;
      finally
        if Tr.InTransaction then
          Tr.RollBack;
        Tr.Free;
      end;
    end
    else
      FSQLHandle := 0;

    CheckAnalyticLevelProcedures;
  end;  
end;

procedure TgdvAcctLedger.DoBuildSQL;
var
  I, J, N, K, Index: Integer;
  MainEntryDateIsAdded, CorrEntryDateIsAdded: Boolean;
  Line: TgdvAcctAnalyticLevels;
  F: TatRelationField;
  T: TgdvLedgerTotal;
  BC: TgdvCustomLedgerTotalBlockClass;
  Strings: TgdvCorrFieldInfoList;
  DebitStrings, CreditStrings: TgdvCorrFieldInfoList;
  Accounts, TempVariables: TStringList;
  DebitCreditSQL: String;
  SelectClause, FromClause, FromClause1, GroupClause, GroupClause1, OrderClause: String;
  IDSelect, NameSelect, WhereClause, QuantityGroup: String;
  Alias, Name: String;
  CurrId, HavingCount, HavingClause: String;
  NcuDecDig, CurrDecDig, EQDecDig: String;
  AnalyticFilter: String;
  ValueAlias, QuantityAlias: String;
  SortName, SortSelect: String;
  VKeyAlias: String;
  NcuBegin, NcuEnd, CurrBegin, CurrEnd, EQBegin, EQEnd: String;
  L_S, Q_S, QS: String;
  AccountIDs: String;
  AnalyticReturns: String;
  AnalyticFilterE, AnalyticFilterEM, AnalyticFilterBal: String;
  MainSelect, MainSubSelect, MainSubSubSelect01, MainSubSubSelect02, MainSubSubSelect03: String;
  MainSubSubGroup03: String;
  MainJoin, MainGroup, MainOrder, MainInto: String;
  CorrSelect, CorrSubSelect, CorrSubSubSelect: String;
  CorrJoin, CorrWhere, CorrGroup, CorrOrder, CorrInto: String;
  AccWhereQuantity: String;
  GdDocJoined: Boolean;

  procedure ProcessAnalytic(CurrentAnalytic: TgdvAnalytics; IsTreeAnalytic: Boolean = False);
  var
    FI: TgdvFieldInfo;
    NameFieldLength: Integer;
    F: TatRelationField;
    RefListField: TatRelationField;
  begin
    F := CurrentAnalytic.Field;

    if Assigned(FFieldInfos) then
    begin
      FI := FFieldInfos.AddInfo;
      FI.FieldName := Name;
      FI.Caption := CurrentAnalytic.Caption;
      FI.Visible := fvVisible;
      FI.Condition := True;

      FI := FFieldInfos.AddInfo;
      FI.FieldName := Alias;
      FI.Visible := fvHidden;

      FI := FFieldInfos.AddInfo;
      FI.FieldName := SortName;
      FI.Visible := fvHidden;
    end;

    // Если присвоен объект подсчитывающий строки "Итого:"
    //  (присваивается в форме gdv_frmAcctLedger)
    if Assigned(FTotals) then
    begin
      T := TgdvLedgerTotal.Create;
      FTotals.Add(T);
      T.FieldName := Alias;
      T.ValueFieldName := Name;
      T.Total := CurrentAnalytic.Total;
      T.atRelationField := F;

      if not FEntryDateInFields then
      begin
        if FEnchancedSaldo then
          BC := TgdvEncancedLedgerTotalBlock
        else
          BC := TgdvSimpleLedgerTotalBlock;
      end
      else
      begin
        if FEntryDateIsFirst then
          BC := TgdvStorageLedgerTotalBlock
        else
          BC := TgdvStorageLedgerTotalBlock1;
      end;

      // Итого для национальной валюты
      FNcuTotalBlock := BC.Create;
      T.TotalBlocks.Add(FNcuTotalBlock);
      FNcuTotalBlock.BeginDebit.FieldName := BaseAcctFieldList[2].FieldName;
      FNcuTotalBlock.BeginCredit.FieldName := BaseAcctFieldList[3].FieldName;
      FNcuTotalBlock.Debit.FieldName := BaseAcctFieldList[0].FieldName;
      FNcuTotalBlock.Credit.FieldName := BaseAcctFieldList[1].FieldName;
      FNcuTotalBlock.EndDebit.FieldName := BaseAcctFieldList[4].FieldName;
      FNcuTotalBlock.EndCredit.FieldName := BaseAcctFieldList[5].FieldName;
      if FUseEntryBalance then
      begin
        GetDebitSumSelectClauseBalance;
        GetCreditSumSelectClauseBalance;
      end
      else
      begin
        GetDebitSumSelectClause;
        GetCreditSumSelectClause;
      end;
      FNcuTotalBlock := nil;

      // Итого для иностранной валюты
      if FCurrSumInfo.Show then
      begin
        FCurrTotalBlock := BC.Create;
        T.TotalBlocks.Add(FCurrTotalBlock);
        FCurrTotalBlock.BeginDebit.FieldName := BaseAcctFieldList[8].FieldName;
        FCurrTotalBlock.BeginCredit.FieldName := BaseAcctFieldList[9].FieldName;
        FCurrTotalBlock.Debit.FieldName := BaseAcctFieldList[6].FieldName;
        FCurrTotalBlock.Credit.FieldName := BaseAcctFieldList[7].FieldName;
        FCurrTotalBlock.EndDebit.FieldName := BaseAcctFieldList[10].FieldName;
        FCurrTotalBlock.EndCredit.FieldName := BaseAcctFieldList[11].FieldName;
        if FUseEntryBalance then
        begin
          GetDebitCurrSumSelectClauseBalance;
          GetCreditCurrSumSelectClauseBalance;
        end
        else
        begin
          GetDebitCurrSumSelectClause;
          GetCreditCurrSumSelectClause;
        end;
        FCurrTotalBlock := nil;
      end;

      // Итого для эквивалента
      if FEQSumInfo.Show then
      begin
        FEQTotalBlock := BC.Create;
        T.TotalBlocks.Add(FEQTotalBlock);
        FEQTotalBlock.BeginDebit.FieldName := BaseAcctFieldList[14].FieldName;
        FEQTotalBlock.BeginCredit.FieldName := BaseAcctFieldList[15].FieldName;
        FEQTotalBlock.Debit.FieldName := BaseAcctFieldList[12].FieldName;
        FEQTotalBlock.Credit.FieldName := BaseAcctFieldList[13].FieldName;
        FEQTotalBlock.EndDebit.FieldName := BaseAcctFieldList[16].FieldName;
        FEQTotalBlock.EndCredit.FieldName := BaseAcctFieldList[17].FieldName;
        if FUseEntryBalance then
        begin
          GetDebitEQSumSelectClauseBalance;
          GetCreditEQSumSelectClauseBalance;
        end
        else
        begin
          GetDebitEQSumSelectClause;
          GetCreditEQSumSelectClause;
        end;
        FEQTotalBlock := nil;
      end;
    end;

    NameFieldLength := 180;
    RefListField := nil;
    if Assigned(F) and Assigned(F.ReferencesField) then
    begin
      // Для аналитики-ссылки подберем поле для отображения
      if Assigned(CurrentAnalytic.ListField) then
      begin
        RefListField := CurrentAnalytic.ListField;
      end
      else
      begin
        if F.Field.RefListFieldName = '' then
          RefListField := F.References.ListField
        else
          RefListField := F.Field.RefListField;
      end;

      // Если длина отображаемого по ссылке поля больше стандартных 180, возьмем ее
      if RefListField.Field.FieldLength > NameFieldLength then
        NameFieldLength := RefListField.Field.FieldLength;
    end;

    // Используем новый или старый метод построения отчета
    if FUseEntryBalance then
    begin
      // Заполняем секцию RETURNS
      if AnalyticReturns > '' then AnalyticReturns := AnalyticReturns + ', ';
      AnalyticReturns := AnalyticReturns + Format(
        '%0:s VARCHAR(%3:d),' +
        '%1:s VARCHAR(%3:d),' +
        '%2:s VARCHAR(%3:d)'#13#10, [Alias, Name, SortName, NameFieldLength]);

      // Если аналитика это физическое поле, и оно является полем ссылкой
      if Assigned(F) and Assigned(F.ReferencesField) then
      begin
        // Если первая аналитика - аналитика даты
        if FEntryDateIsFirst then
        begin
          // Заполняем секцию SELECT дополнительного запроса
          if CorrSelect > '' then CorrSelect := CorrSelect + ', ';
          CorrSelect := CorrSelect +
            Format(
              'SUBSTRING(%0:s.%1:s from 1 for %3:d) AS %0:s, ' +
              'SUBSTRING(%0:s.%1:s from 1 for %3:d) AS %0:s, ' +
              '%0:s.%2:s',
              [Alias, RefListField.FieldName, F.ReferencesField.FieldName, NameFieldLength]);
          // Заполняем секцию ORDER BY дополнительного запроса
          if CorrOrder > '' then CorrOrder := CorrOrder + ', ';
          CorrOrder := CorrOrder + Alias + '.' + RefListField.FieldName;
          // Заполняем секцию INTO дополнительного запроса
          if CorrInto > '' then CorrInto := CorrInto + ', ';
          CorrInto := CorrInto +
            ':' + SortName  + ', ' +
            ':' + Name + ', ' +
            ':' + Alias + #13#10;

          // Не будем заполнять эти поля при обработке уровня аналитики,
          //  они заполнятся нужными значениями при обработке группировочной аналитики
          if not IsTreeAnalytic then
          begin
            if CorrSubSelect > '' then CorrSubSelect := CorrSubSelect + ', ';
            CorrSubSelect := CorrSubSelect + 'en.' + F.Fieldname;
            if CorrSubSubSelect > '' then CorrSubSubSelect := CorrSubSubSelect + ', ';
            CorrSubSubSelect := CorrSubSubSelect + 'em.' + F.Fieldname;
            if CorrGroup > '' then CorrGroup := CorrGroup + ', ';
            CorrGroup := CorrGroup + 'en.' + F.Fieldname;
          end;
          // Добавим дополнительные поля для аналитики при включенном переключателе "Расширенное отображение"
          ExtendedFieldsBalance(F, Alias, AnalyticReturns, CorrSelect, CorrInto);
        end
        else
        begin
          // Если первая аналитика - не аналитика даты
          TempVariables.Add('temp_' + Alias + '=' + Alias);
          // Заполняем секции INTO, GROUP BY главного запроса и GROUP BY третьего запроса
          //  из второго вложенного уровня в главном запросе
          if MainInto > '' then MainInto := MainInto + ', ';
          MainInto := MainInto +
            ':' + Alias + ', ' +
            ':' + Name + ', ' +
            ':' + SortName + #13#10;
          if MainGroup > '' then MainGroup := MainGroup + ', ';
          MainGroup := MainGroup +
            'en.' + F.FieldName;
          if MainSubSubGroup03 > '' then MainSubSubGroup03 := MainSubSubGroup03 + ', ';
          MainSubSubGroup03 := MainSubSubGroup03 +
            'em.' + F.FieldName;

          // Не будем заполнять эти поля при обработке уровня аналитики,
          //  они заполнятся нужными значениями при обработке группировочной аналитике
          if not IsTreeAnalytic then
          begin
            if MainSubSelect > '' then MainSubSelect := MainSubSelect + ', ';
            MainSubSelect := MainSubSelect +
              'en.' + F.FieldName;
            if MainSubSubSelect01 > '' then MainSubSubSelect01 := MainSubSubSelect01 + ', ';
            MainSubSubSelect01 := MainSubSubSelect01 +
              'bal.' + F.FieldName;
            if MainSubSubSelect02 > '' then MainSubSubSelect02 := MainSubSubSelect02 + ', ';
            MainSubSubSelect02 := MainSubSubSelect02 +
              'e.' + F.FieldName;
            if MainSubSubSelect03 > '' then MainSubSubSelect03 := MainSubSubSelect03 + ', ';
            MainSubSubSelect03 := MainSubSubSelect03 +
              'em.' + F.FieldName;
            CorrWhere := CorrWhere + ' AND em.' + F.FieldName + ' = :' + Alias;
          end;

          // Заполняем секции SELECT, ORDER BY главного запроса
          if MainSelect > '' then MainSelect := MainSelect + ', ';
          MainSelect := MainSelect +
            Format(
              '%0:s.%2:s, ' +
              'SUBSTRING(%0:s.%1:s from 1 for %3:d) AS %0:s, ' +
              'SUBSTRING(%0:s.%1:s from 1 for %3:d) AS %0:s',
              [Alias, RefListField.FieldName, F.ReferencesField.FieldName, NameFieldLength]);
          if MainOrder > '' then MainOrder := MainOrder + ', ';
          MainOrder := MainOrder + Alias + '.' + RefListField.FieldName;
          // Добавим дополнительные поля для аналитики при включенном переключателе "Расширенное отображение"
          ExtendedFieldsBalance(F, Alias, AnalyticReturns, MainSelect, MainInto);
        end;
      end
      else
      begin
        // Если аналитика это физическое поле, но оно не является полем ссылкой
        if Assigned(F) then
        begin
          // Если это поле даты проводки - ENTRYDATE
          if F.FieldName = ENTRYDATE then
          begin
            if FEntryDateInFields then
            begin
              // Заполняем секции SELECT, ORDER BY, INTO главного запроса
              if MainSelect > '' then MainSelect := MainSelect + ', ';
              MainSelect := MainSelect +
                Format(' m.dateparam_%0:s, m.dateparam_%0:s, m.dateparam_%0:s '#13#10, [Alias]);

              if (not FEntryDateIsFirst) then
              begin
                if MainOrder > '' then MainOrder := MainOrder + ', ';
                MainOrder := MainOrder +
                  Format(' m.dateparam_%0:s '#13#10, [Alias]);
              end;

              if MainInto > '' then MainInto := MainInto + ', ';
              MainInto := MainInto +
                ':' + Alias + ', ' +
                ':' + Name + ', ' +
                ':' + SortName + #13#10;
            end;

            // Заполняем секции SELECT, GROUP BY запроса первого уровня вложенности в главном запросе
            if MainSubSelect > '' then MainSubSelect := MainSubSelect + ', ';
            MainSubSelect := MainSubSelect +
              Format(' en.entrydate AS dateparam_%0:s '#13#10, [Alias]);
            if MainGroup > '' then MainGroup := MainGroup + ', ';
            MainGroup := MainGroup +
              ' en.entrydate '#13#10;
          end
          else
          begin
            // Иначе это просто текстовое, числовое или поле даты в AC_ENTRY
            TempVariables.Add('temp_' + Alias + '=' + Alias);
            // Заполняем секции SELECT, GROUP BY, ORDER BY, INTO в главном запросе
            if MainSelect > '' then MainSelect := MainSelect + ', ';
            MainSelect := MainSelect +
              Format(' m.%0:s, m.%0:s, m.%0:s '#13#10, [Alias]);
            if MainOrder > '' then MainOrder := MainOrder + ', ';
            MainOrder := MainOrder +
              Format(' m.%0:s '#13#10, [Alias]);
            if MainGroup > '' then MainGroup := MainGroup + ', ';
            MainGroup := MainGroup +
              Format(' en.%0:s '#13#10, [Alias]);
            if MainInto > '' then MainInto := MainInto + ', ';
            MainInto := MainInto +
              ':' + Alias + ', ' +
              ':' + Name + ', ' +
              ':' + SortName + #13#10;

            // Заполняем секции SELECT в запросе первого уровня вложенности в главном запросе
            if MainSubSelect > '' then MainSubSelect := MainSubSelect + ', ';
            MainSubSelect := MainSubSelect +
              Format(' en.%0:s '#13#10, [Alias]);

            // Заполняем секции SELECT во всех запросах второго уровня вложенности в главном запросе
            if MainSubSubSelect01 > '' then MainSubSubSelect01 := MainSubSubSelect01 + ', ';
            MainSubSubSelect01 := MainSubSubSelect01 +
              Format(' bal.%0:s AS %1:s '#13#10, [F.FieldName, Alias]);
            if MainSubSubSelect02 > '' then MainSubSubSelect02 := MainSubSubSelect02 + ', ';
            MainSubSubSelect02 := MainSubSubSelect02 +
              Format(' e.%0:s AS %1:s '#13#10, [F.FieldName, Alias]);
            if MainSubSubSelect03 > '' then MainSubSubSelect03 := MainSubSubSelect03 + ', ';
            MainSubSubSelect03 := MainSubSubSelect03 +
              Format(' em.%0:s AS %1:s '#13#10, [F.FieldName, Alias]);
            // Заполняем секции GROUP BY в третьем запросе второго уровня вложенности в главном запросе
            if MainSubSubGroup03 > '' then MainSubSubGroup03 := MainSubSubGroup03 + ', ';
            MainSubSubGroup03 := MainSubSubGroup03 +
              Format(' em.%0:s '#13#10, [F.FieldName]);
          end;
        end
        else
        begin
          // Если текущая аналитика не физическое поле (месяц, год, квартал)

          // Если в аналитиках присутствует дата, но она не стоит на первом месте
          if FEntryDateInFields then
          begin
            if MainSelect > '' then MainSelect := MainSelect + ', ';
            MainSelect := MainSelect +
              Format(' m.dateparam_%0:s, m.dateparam_%0:s, m.dateparam_%0:s '#13#10, [Alias]);

            if (not FEntryDateIsFirst) then
            begin
              if MainOrder > '' then MainOrder := MainOrder + ', ';
              MainOrder := MainOrder +
                Format(' m.dateparam_%0:s '#13#10, [Alias]);
            end;

            if MainInto > '' then MainInto := MainInto + ', ';
            MainInto := MainInto +
              ':' + Alias + ', ' +
              ':' + Name + ', ' +
              ':' + SortName + #13#10;
          end; 

          if MainSubSelect > '' then MainSubSelect := MainSubSelect + ', ';
          MainSubSelect := MainSubSelect +
            GetSQLForDateParam('en.entrydate', CurrentAnalytic.Additional) + ' AS dateparam_' + Alias + #13#10;
          if MainGroup > '' then MainGroup := MainGroup + ', ';
          MainGroup := MainGroup +
            GetSQLForDateParam('en.entrydate', CurrentAnalytic.Additional) + #13#10;
        end;

        // ENTRYDATE нужно брать в подзапросе только один раз
        if (not Assigned(F) or (Assigned(F) and (F.FieldName = ENTRYDATE))) and (not MainEntryDateIsAdded) then
        begin
          // Заполняем секции SELECT во всех запросах второго уровня вложенности в главном запросе
          if MainSubSubSelect01 > '' then MainSubSubSelect01 := MainSubSubSelect01 + ', ';
          MainSubSubSelect01 := MainSubSubSelect01 +
            'CAST(:datebegin AS DATE) AS entrydate'#13#10;
          if MainSubSubSelect02 > '' then MainSubSubSelect02 := MainSubSubSelect02 + ', ';
          MainSubSubSelect02 := MainSubSubSelect02 +
            'CAST(:datebegin AS DATE) AS entrydate'#13#10;
          if MainSubSubSelect03 > '' then MainSubSubSelect03 := MainSubSubSelect03 + ', ';
          MainSubSubSelect03 := MainSubSubSelect03 +
            'em.entrydate'#13#10;
          // Заполняем секции GROUP BY в третьем запросе второго уровня вложенности в главном запросе
          if MainSubSubGroup03 > '' then MainSubSubGroup03 := MainSubSubGroup03 + ', ';
          MainSubSubGroup03 := MainSubSubGroup03 +
            'em.entrydate'#13#10;
          MainEntryDateIsAdded := True;
        end;

        if CorrInto > '' then CorrInto := CorrInto + ', ';
        CorrInto := CorrInto +
          ':' + Alias + ', ' +
          ':' + Name + ', ' +
          ':' + SortName + #13#10;

        if CorrSelect > '' then CorrSelect := CorrSelect + ', ';
        if CorrSubSelect > '' then CorrSubSelect := CorrSubSelect + ', ';
        if CorrGroup > '' then CorrGroup := CorrGroup + ', ';
        if CorrOrder > '' then CorrOrder := CorrOrder + ', ';
        if Assigned(F) then
        begin
          CorrSelect := CorrSelect +
            Format(' m.%0:s, m.%0:s, m.%0:s '#13#10, [F.FieldName]);
          CorrSubSelect := CorrSubSelect + 'en.' + F.FieldName;
          // ENTRYDATE нужно брать в подзапросе только один раз
          if AnsiCompareText(F.FieldName, ENTRYDATE) = 0 then
          begin
            if not CorrEntryDateIsAdded then
            begin
              if CorrSubSubSelect > '' then CorrSubSubSelect := CorrSubSubSelect + ', ';
              CorrSubSubSelect := CorrSubSubSelect + 'em.' + F.FieldName + #13#10;
              CorrEntryDateIsAdded := True;
            end
          end
          else
          begin
            if CorrSubSubSelect > '' then CorrSubSubSelect := CorrSubSubSelect + ', ';
            CorrSubSubSelect := CorrSubSubSelect + 'em.' + F.FieldName + #13#10;
          end;
          CorrGroup := CorrGroup + 'en.' + F.FieldName;
          CorrOrder := CorrOrder + Format(' m.%0:s '#13#10, [F.FieldName]);
        end
        else
        begin
          CorrSelect := CorrSelect +
            Format(' m.%0:s, m.%0:s, m.%0:s '#13#10, [Alias]);
          CorrSubSelect := CorrSubSelect +
            GetSQLForDateParam('en.entrydate', CurrentAnalytic.Additional) + ' AS ' + Alias + #13#10;
          // ENTRYDATE нужно брать в подзапросе только один раз
          if not CorrEntryDateIsAdded then
          begin
            if CorrSubSubSelect > '' then CorrSubSubSelect := CorrSubSubSelect + ', ';
            CorrSubSubSelect := CorrSubSubSelect + 'em.entrydate'#13#10;
            CorrEntryDateIsAdded := True;
          end;
          CorrGroup := CorrGroup +
            GetSQLForDateParam('en.entrydate', CurrentAnalytic.Additional) + #13#10;
          CorrOrder := CorrOrder + Format(' m.%0:s '#13#10, [Alias]);
        end;
      end;

    end
    else
    begin

      if IDSelect > '' then
        IDSelect := IDSelect + ', ';
      if NameSelect > '' then
        NameSelect := NameSelect + ', ';
      if SortSelect > '' then
        SortSelect := SortSelect + ', ';
      if OrderClause > '' then
        OrderClause := OrderClause + ', ';

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          IDSelect := IDSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s ', [Alias,
            F.ReferencesField.FieldName, Alias]);

          NameSelect := NameSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s ', [Alias,
            RefListField.FieldName, Name]);
          SortSelect := SortSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s ', [Alias,
            RefListField.FieldName, SortName]);
          OrderClause := OrderClause + Format('%s.%s, %s.%s', [Alias,
            RefListField.FieldName, Alias, F.ReferencesField.FieldName]);
        end
        else
        begin
          if FEntryDateIsFirst and (F.FieldName = ENTRYDATE) and (I = 0) then
          begin
            IDSelect := IDSelect + Format('  SUBSTRING(ls.entrydate from 1 for 180) AS %s', [Alias]);
            NameSelect := NameSelect + Format('  SUBSTRING(ls.entrydate from 1 for 180) AS %s', [Name]);
            SortSelect := SortSelect + Format('  SUBSTRING(ls.entrydate from 1 for 180) AS %s', [SortName]);
            OrderClause := OrderClause + 'ls.entrydate';
          end
          else
          begin
            IDSelect := IDSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s', [F.FieldName, Alias]);
            NameSelect := NameSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s', [F.FieldName, Name]);
            SortSelect := SortSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s', [F.FieldName, SortName]);
            OrderClause := OrderClause + Format('e.%s', [F.FieldName]);
          end;
        end;
      end
      else
      begin
        if FEntryDateIsFirst and (I = 0) then
        begin
          IDSelect := IDSelect + Format('  SUBSTRING(ls.dateparam from 1 for 180) AS %s', [Alias]);
          NameSelect := NameSelect + Format('  SUBSTRING(ls.dateparam FROM 1 for 180) AS %s', [Name]);
          SortSelect := SortSelect + Format('  SUBSTRING(ls.dateparam from 1 for 180) AS %s', [SortName]);
          OrderClause := OrderClause + 'ls.dateparam';
        end
        else
        begin
          IDSelect := IDSelect + Format(' SUBSTRING(g_d_getdateparam(e2.entrydate, %s) from 1 for 180)AS %s',
            [CurrentAnalytic.Additional, Alias]);
          NameSelect := NameSelect + Format(' SUBSTRING(g_d_getdateparam(e2.entrydate, %s) from 1 for 180)AS %s',
            [CurrentAnalytic.Additional, Name]);
          SortSelect := SortSelect + Format(' SUBSTRING(g_d_getdateparam(e2.entrydate, %s) from 1 for 180)AS %s',
            [CurrentAnalytic.Additional, SortName]);
          OrderClause := OrderClause + Format('g_d_getdateparam(e2.entrydate, %s)',
            [CurrentAnalytic.Additional]);
        end;
      end;

      ExtendedFields(F, Alias, NameSelect, GroupClause);

      if GroupClause > '' then
        GroupClause := GroupClause + ', ';

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          GroupClause := GroupClause + Format('%s.%s, %s.%s', [Alias,
            RefListField.FieldName, Alias, F.ReferencesField.FieldName])
        end
        else
        begin
          if FEntryDateIsFirst and (F.FieldName = ENTRYDATE) and (I = 0) then
            GroupClause := GroupClause + 'ls.entrydate'
          else
            GroupClause := GroupClause + Format('e.%s', [F.FieldName])
        end;
      end
      else
      begin
        if FEntryDateIsFirst and (I = 0) then
          GroupClause := GroupClause + 'ls.dateparam'
        else
          GroupClause := GroupClause + Format('g_d_getdateparam(e2.entrydate, %s)',
            [CurrentAnalytic.Additional])
      end;
    end;
  end;

  procedure FillCorrAccountStrings(AAccounts: TStrings; EntryAccounts: TgdvCorrFieldInfoList; EntryPart: String; Currency: String);
  var
    I, Index: Integer;
    ID: TID;
    DisplayAlias: String;
    Alias: String;
  begin
    for I := 0 to EntryAccounts.Count - 1 do
    begin
      ID := EntryAccounts.Items[I].Account;
      Alias := Format(Currency + '_%s_%s', [EntryPart, Self.GetKeyAlias(EntryAccounts.Items[I].Account)]);
      if FShowCorrSubAccounts then
      begin
        AAccounts.Add(Alias + '=' + IntToStr(ID));
      end
      else
      begin
        DisplayAlias := Format(Currency + '_%s_%s', [EntryPart, Self.GetKeyAlias(EntryAccounts.Items[I].DisplayAccount)]);
        Index := AAccounts.IndexOf(DisplayAlias);
        if Index = -1 then
        begin
          Index := AAccounts.AddObject(DisplayAlias, TgdKeyArray.Create);
          TgdKeyArray(AAccounts.Objects[Index]).Add(ID);
        end
        else
        begin
          TgdKeyArray(AAccounts.Objects[Index]).Add(ID);
        end;
      end;
    end;
  end;

  // Заполняет запрос корреспондирующми счетами
  procedure FillQueryWithCorrAccounts(AAccounts: TStrings; EntryPart: String);
  var
    I, J: Integer;
    CurrencyStr: String;
    CurrencyInfo: TgdvSumInfo;

    // Возвращает префикс валюты (NCU, CURR, EQ)
    function GetCurrencyStr(const AccountName: String): String;
    begin
      Result := cNCUPrefix;
      CurrencyInfo := FNcuSumInfo;
      if AnsiPos(UpperCase(cCURRPrefix), UpperCase(AccountName)) > 0 then
      begin
        Result := cCURRPrefix;
        CurrencyInfo := FCurrSumInfo;
      end
      else if AnsiPos(UpperCase(cEQPrefix), UpperCase(AccountName)) > 0 then
      begin
        Result := cEQPrefix;
        CurrencyInfo := FEQSumInfo;
      end;
    end;

  begin
    // Если аналитика даты не является первой
    if not FEntryDateIsFirst then
    begin
      for I := 0 to AAccounts.Count - 1 do
      begin
        // Показывать корреспондирующие счета
        if FShowCorrSubAccounts then
        begin
          CurrencyStr := GetCurrencyStr(AAccounts.Names[I]);
          // Секции SELECT, INTO главного запроса
          MainSelect := MainSelect + ', m.' + AAccounts.Names[I];
          MainInto := MainInto + ', :' + AAccounts.Names[I];
          // SELECT запроса первого уровня вложенности в главном запросе
          MainSubSelect := MainSubSelect +
            Format(', COALESCE(SUM(en.%0:s) / %1:d, 0) AS %0:s '#13#10, [AAccounts.Names[I], CurrencyInfo.Scale]);
          // SELECT запросов второго уровня вложенности в главном запросе
          MainSubSubSelect01 := MainSubSubSelect01 + ', CAST(0 as numeric(15, %1:d)) AS ' + AAccounts.Names[I];
          MainSubSubSelect02 := MainSubSubSelect02 + ', CAST(0 as numeric(15, %1:d)) AS ' + AAccounts.Names[I];
          if EntryPart = cAccountPartDebit then
            MainSubSubSelect03 := MainSubSubSelect03 +
              Format(', SUM(IIF(emc.accountkey=%0:s,IIF(emc.issimple=0, emc.credit%1:s, em.debit%1:s), 0)) AS %2:s'#13#10,
              [AAccounts.Values[AAccounts.Names[I]], CurrencyStr, AAccounts.Names[I]])
          else
            MainSubSubSelect03 := MainSubSubSelect03 +
              Format(', SUM(IIF(emc.accountkey=%0:s,IIF(emc.issimple=0, emc.debit%1:s, em.credit%1:s), 0)) AS %2:s'#13#10,
              [AAccounts.Values[AAccounts.Names[I]], CurrencyStr, AAccounts.Names[I]]);
        end
        else
        begin
          CurrencyStr := GetCurrencyStr(AAccounts.Strings[I]);
          // Секции SELECT, INTO главного запроса
          MainSelect := MainSelect + ', m.' + AAccounts.Strings[I];
          MainInto := MainInto + ', :' + AAccounts.Strings[I];
          // SELECT запроса первого уровня вложенности в главном запросе
          MainSubSelect := MainSubSelect +
            Format(', COALESCE(SUM(en.%0:s) / %1:d, 0) AS %0:s '#13#10, [AAccounts.Strings[I], CurrencyInfo.Scale]);
          // SELECT запросов второго уровня вложенности в главном запросе
          MainSubSubSelect01 := MainSubSubSelect01 + ', CAST(0 as numeric(15, %1:d)) AS ' + AAccounts.Strings[I];
          MainSubSubSelect02 := MainSubSubSelect02 + ', CAST(0 as numeric(15, %1:d)) AS ' + AAccounts.Strings[I];
          MainSubSubSelect03 := MainSubSubSelect03 + ', SUM(IIF(emc.accountkey IN (';
          // Если стоит групировка счетов, то здесь в одну колонку сгруппируется несколько значений
          for J := 0 to TgdKeyArray(AAccounts.Objects[I]).Count - 1 do
          begin
            MainSubSubSelect03 := MainSubSubSelect03 + IntToStr(TgdKeyArray(AAccounts.Objects[I]).Keys[J]);
            if J <> TgdKeyArray(AAccounts.Objects[I]).Count - 1 then
              MainSubSubSelect03 := MainSubSubSelect03 + ', ';
          end;
          if EntryPart = cAccountPartDebit then
            MainSubSubSelect03 := MainSubSubSelect03 + Format('), IIF(emc.issimple=0, emc.credit%0:s, em.debit%0:s), 0)) AS %1:s'#13#10,
              [CurrencyStr, AAccounts.Strings[I]])
          else
            MainSubSubSelect03 := MainSubSubSelect03 + Format('), IIF(emc.issimple=0, emc.debit%0:s, em.credit%0:s), 0)) AS %1:s'#13#10,
              [CurrencyStr, AAccounts.Strings[I]]);
        end;
      end
    end
    else
    begin
      // Если аналитика даты стоит первой
      for I := 0 to AAccounts.Count - 1 do
      begin
        // Показывать корреспондирующие счета
        if FShowCorrSubAccounts then
        begin
          CurrencyStr := GetCurrencyStr(AAccounts.Names[I]);
          // Секции SELECT, INTO дополнительного запроса
          CorrSelect := CorrSelect + ', m.' + AAccounts.Names[I];
          CorrInto := CorrInto + ', :' + AAccounts.Names[I];
          // SELECT запроса первого уровня вложенности в дополнительном запросе
          CorrSubSelect := CorrSubSelect +
            Format(', COALESCE(SUM(en.%0:s) / %1:d, 0) AS %0:s '#13#10, [AAccounts.Names[I], CurrencyInfo.Scale]);
          // SELECT запроса второго уровня вложенности в дополнительном запросе
          if EntryPart = cAccountPartDebit then
            CorrSubSubSelect := CorrSubSubSelect +
              Format(', IIF(emc.accountkey=%0:s,IIF(emc.issimple=0, emc.credit%1:s,em.debit%1:s),0) AS %2:s'#13#10,
              [AAccounts.Values[AAccounts.Names[I]], CurrencyStr, AAccounts.Names[I]])
          else
            CorrSubSubSelect := CorrSubSubSelect +
              Format(', IIF(emc.accountkey=%0:s,IIF(emc.issimple=0, emc.debit%1:s,em.credit%1:s),0) AS %2:s'#13#10,
              [AAccounts.Values[AAccounts.Names[I]], CurrencyStr, AAccounts.Names[I]]);
        end
        else
        begin
          CurrencyStr := GetCurrencyStr(AAccounts.Strings[I]);
          // Секции SELECT, INTO дополнительного запроса
          CorrSelect := CorrSelect + ', m.' + AAccounts.Strings[I];
          CorrInto := CorrInto + ', :' + AAccounts.Strings[I];
          // SELECT запроса первого уровня вложенности в дополнительном запросе
          CorrSubSelect := CorrSubSelect +
            Format(', COALESCE(SUM(en.%0:s) / %1:d, 0) AS %0:s '#13#10, [AAccounts.Strings[I], CurrencyInfo.Scale]);
          // SELECT запроса второго уровня вложенности в дополнительном запросе
          CorrSubSubSelect := CorrSubSubSelect + ', IIF(emc.accountkey IN (';
          // Если стоит групировка счетов, то здесь в одну колонку сгруппируется несколько значений
          for J := 0 to TgdKeyArray(AAccounts.Objects[I]).Count - 1 do
          begin
            CorrSubSubSelect := CorrSubSubSelect + IntToStr(TgdKeyArray(AAccounts.Objects[I]).Keys[J]);
            if J <> TgdKeyArray(AAccounts.Objects[I]).Count - 1 then
              CorrSubSubSelect := CorrSubSubSelect + ', ';
          end;
          if EntryPart = cAccountPartDebit then
            CorrSubSubSelect := CorrSubSubSelect + Format('), IIF(emc.issimple=0,emc.credit%0:s,em.debit%0:s),0) AS %1:s '#13#10,
              [CurrencyStr, AAccounts.Strings[I]])
          else
            CorrSubSubSelect := CorrSubSubSelect + Format('), IIF(emc.issimple=0,emc.debit%0:s,em.credit%0:s),0) AS %1:s '#13#10,
              [CurrencyStr, AAccounts.Strings[I]]);
        end;
      end;
    end;
  end;

begin
  AccWhereQuantity := '';
  if FUseEntryBalance then
  begin
    // Список счетов в строковом виде
    AccountIDs := IDList(FAccounts);
    MainEntryDateIsAdded := False;
    CorrEntryDateIsAdded := False;

    // Получим выбранные условия в строковом виде с нужными префиксами
    AnalyticFilterE := Self.GetCondition('e');
    if AnalyticFilterE > '' then
      AnalyticFilterE := ' AND ' + AnalyticFilterE + #13#10;
    AnalyticFilterEM := Self.GetCondition('em');
    if AnalyticFilterEM > '' then
      AnalyticFilterEM := ' AND ' + AnalyticFilterEM + #13#10;
    AnalyticFilterBal := Self.GetCondition('bal');
    if AnalyticFilterBal > '' then
      AnalyticFilterBal := ' AND ' + AnalyticFilterBal + #13#10;

    TempVariables := TStringList.Create;
    try
      N := FAcctGroupBy.Count;        // Кол-во выбранных группировочных аналитик      
      for I := 0 to FAcctGroupBy.Count - 1 do
      begin
        F := FAcctGroupBy[I].Field;

        if Assigned(F) then
        begin
          // Индекс строки ввода уровня аналитики
          Index := IndexOfAnalyticLevel(F.FieldName);
          if Index > -1 then
          begin
            Line := TgdvAcctAnalyticLevels(FAcctAnalyticLevels[Index]);
            // Если ввели какой-либо уровень аналитики
            if not Line.IsEmpty then
            begin
              // Цикл по введенным в уровень аналитики значениям
              for J := 0 to Line.Levels.Count - 1 do
              begin
                Alias := Format('c%d', [N]);
                Name := Format('NAME%d', [N]);
                SortName := Format('s%d', [N]);
                // Заполнит части запроса и описания полей, связанные с аналитикой
                ProcessAnalytic(FAcctGroupBy[I], True);
                // Если первой является аналитика даты
                if FEntryDateIsFirst then
                  CorrJoin := CorrJoin + Format('  LEFT JOIN %s(%s, m.%s) lg_%s ON 1 = 1'#13#10,
                    [Line.SPName, Line.Levels[J], F.FieldName, Alias]) +
                    Format('  LEFT JOIN %0:s %1:s ON %1:s.%2:s = lg_%1:s.id '#13#10,
                    [F.References.RelationName, Alias, F.ReferencesField.FieldName])
                else
                  MainJoin := MainJoin + Format('  LEFT JOIN %s(%s, m.%s) lg_%s ON 1 = 1'#13#10,
                    [Line.SPName, Line.Levels[J], F.FieldName, Alias]) +
                    Format('  LEFT JOIN %0:s %1:s ON %1:s.%2:s = lg_%1:s.id '#13#10,
                    [F.References.RelationName, Alias, F.ReferencesField.FieldName]);

                Inc(N);
              end;
            end;
          end;
        end;

        Alias := Format('c%d', [I]);
        Name := Format('NAME%d', [I]);
        SortName := Format('s%d', [I]);
        // Заполнит части запроса и описания полей, связанные с аналитикой
        ProcessAnalytic(FAcctGroupBy[I]);
        // Если поле является полем ссылкой
        if Assigned(F) and Assigned(F.ReferencesField) then
          // Если первой является аналитика даты
          if FEntryDateIsFirst then
            CorrJoin := CorrJoin + Format('  LEFT JOIN %s %s ON %s.%s = m.%s '#13#10,
              [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName, F.FieldName])
          else
            MainJoin := MainJoin + Format('  LEFT JOIN %s %s ON %s.%s = m.%s '#13#10,
              [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName, F.FieldName]);
      end;

      // Если первой стоит не аналитика даты
      if not FEntryDateIsFirst then
      begin
        // Секции главного запроса
        if MainSelect > '' then MainSelect := MainSelect + ', ';
        MainSelect := MainSelect +
          'm.debitncu, m.creditncu, '#13#10 +
          'm.debitcurr, m.creditcurr, '#13#10 +
          'm.debiteq, m.crediteq '#13#10;
        if MainInto > '' then MainInto := MainInto + ', ';
        MainInto := MainInto +
          ':varncudebit, :varncucredit, '#13#10 +
          ':varcurrdebit, :varcurrcredit, '#13#10 +
          ':vareqdebit, :vareqcredit '#13#10;
        if MainSubSelect > '' then MainSubSelect := MainSubSelect + ', ';
        MainSubSelect := MainSubSelect +
          'COALESCE(SUM(en.debitncu_m), 0) AS debitncu, '#13#10 +
          'COALESCE(SUM(en.creditncu_m), 0) AS creditncu, '#13#10 +
          'COALESCE(SUM(en.debitcurr_m), 0) AS debitcurr, '#13#10 +
          'COALESCE(SUM(en.creditcurr_m), 0) AS creditcurr, '#13#10 +
          'COALESCE(SUM(en.debiteq_m), 0) AS debiteq, '#13#10 +
          'COALESCE(SUM(en.crediteq_m), 0) AS crediteq '#13#10;
        if MainSubSubSelect01 > '' then MainSubSubSelect01 := MainSubSubSelect01 + ', ';
        MainSubSubSelect01 := MainSubSubSelect01 +
          'CAST(0 as numeric(15, %1:d)) AS debitncu_m, '#13#10 +
          'CAST(0 as numeric(15, %1:d)) AS creditncu_m, '#13#10 +
          'CAST(0 as numeric(15, %3:d)) AS debitcurr_m, '#13#10 +
          'CAST(0 as numeric(15, %3:d)) AS creditcurr_m, '#13#10 +
          'CAST(0 as numeric(15, %5:d)) AS debiteq_m, '#13#10 +
          'CAST(0 as numeric(15, %5:d)) AS crediteq_m '#13#10;
        if MainSubSubSelect02 > '' then MainSubSubSelect02 := MainSubSubSelect02 + ', ';
        MainSubSubSelect02 := MainSubSubSelect02 +
          'CAST(0 as numeric(15, %1:d)) AS debitncu_m, '#13#10 +
          'CAST(0 as numeric(15, %1:d)) AS creditncu_m, '#13#10 +
          'CAST(0 as numeric(15, %3:d)) AS debitcurr_m, '#13#10 +
          'CAST(0 as numeric(15, %3:d)) AS creditcurr_m, '#13#10 +
          'CAST(0 as numeric(15, %5:d)) AS debiteq_m, '#13#10 +
          'CAST(0 as numeric(15, %5:d)) AS crediteq_m '#13#10;
        if MainSubSubSelect03 > '' then MainSubSubSelect03 := MainSubSubSelect03 + ', ';
        MainSubSubSelect03 := MainSubSubSelect03 +
          'SUM(IIF(emc.issimple=0, emc.creditncu, em.debitncu)) AS debitncu_m, '#13#10 +
          'SUM(IIF(emc.issimple=0, emc.debitncu, em.creditncu)) AS creditncu_m, '#13#10 +
          'SUM(IIF(emc.issimple=0, emc.creditcurr, em.debitcurr)) AS debitcurr_m, '#13#10 +
          'SUM(IIF(emc.issimple=0, emc.debitcurr, em.creditcurr)) AS creditcurr_m, '#13#10 +
          'SUM(IIF(emc.issimple=0, emc.crediteq, em.debiteq)) AS debiteq_m, '#13#10 +
          'SUM(IIF(emc.issimple=0, emc.debiteq, em.crediteq)) AS crediteq_m '#13#10;
      end
      else
      begin
        // Секции вспомогательного запроса
        if CorrSelect > '' then CorrSelect := CorrSelect + ', ';
        CorrSelect := CorrSelect +
          'm.debitncu, m.creditncu, '#13#10 +
          'm.debitcurr, m.creditcurr, '#13#10 +
          'm.debiteq, m.crediteq '#13#10;
        if CorrInto > '' then CorrInto := CorrInto + ', ';
        CorrInto := CorrInto +
          ':varncudebit, :varncucredit, '#13#10 +
          ':varcurrdebit, :varcurrcredit, '#13#10 +
          ':vareqdebit, :vareqcredit '#13#10;
        if CorrSubSelect > '' then CorrSubSelect := CorrSubSelect + ', ';
        CorrSubSelect := CorrSubSelect +
          'COALESCE(SUM(en.debitncu_m), 0) AS debitncu, '#13#10 +
          'COALESCE(SUM(en.creditncu_m), 0) AS creditncu, '#13#10 +
          'COALESCE(SUM(en.debitcurr_m), 0) AS debitcurr, '#13#10 +
          'COALESCE(SUM(en.creditcurr_m), 0) AS creditcurr, '#13#10 +
          'COALESCE(SUM(en.debiteq_m), 0) AS debiteq, '#13#10 +
          'COALESCE(SUM(en.crediteq_m), 0) AS crediteq '#13#10;
        if CorrSubSubSelect > '' then CorrSubSubSelect := CorrSubSubSelect + ', ';
        CorrSubSubSelect := CorrSubSubSelect +
          'IIF(emc.issimple=0, emc.creditncu, em.debitncu) AS debitncu_m, '#13#10 +
          'IIF(emc.issimple=0, emc.debitncu, em.creditncu) AS creditncu_m, '#13#10 +
          'IIF(emc.issimple=0, emc.creditcurr, em.debitcurr) AS debitcurr_m, '#13#10 +
          'IIF(emc.issimple=0, emc.debitcurr, em.creditcurr) AS creditcurr_m, '#13#10 +
          'IIF(emc.issimple=0, emc.crediteq, em.debiteq) AS debiteq_m, '#13#10 +
          'IIF(emc.issimple=0, emc.debiteq, em.crediteq) AS crediteq_m'#13#10;
      end;

      Accounts := TStringList.Create;
      try
        // Дебетовые корреспондирующие счета
        if FShowDebit then
        begin
          DebitStrings := TgdvCorrFieldInfoList.Create;
          try
            CorrAccounts(DebitStrings, cAccountPartDebit);
            if DebitStrings.Count > 0 then
            begin
              if FNcuSumInfo.Show then
                FillCorrAccountStrings(Accounts, DebitStrings, 'DEBIT', cNCUPrefix);
              if FCurrSumInfo.Show then
                FillCorrAccountStrings(Accounts, DebitStrings, 'DEBIT', cCURRPrefix);
              if FEQSumInfo.Show then
                FillCorrAccountStrings(Accounts, DebitStrings, 'DEBIT', cEQPrefix);

              FillQueryWithCorrAccounts(Accounts, cAccountPartDebit);

              for I := 0 to Accounts.Count - 1 do
                if Assigned(Accounts.Objects[I]) then
                  Accounts.Objects[I].Free;
              Accounts.Clear;
            end;
          finally
            DebitStrings.Free;
          end;
        end;

        // Кредитовые корреспондирующие счета
        if FShowCredit then
        begin
          CreditStrings := TgdvCorrFieldInfoList.Create;
          try
            CorrAccounts(CreditStrings, cAccountPartCredit);
            if CreditStrings.Count > 0 then
            begin
              if FNcuSumInfo.Show then
                FillCorrAccountStrings(Accounts, CreditStrings, 'CREDIT', cNCUPrefix);
              if FCurrSumInfo.Show then
                FillCorrAccountStrings(Accounts, CreditStrings, 'CREDIT', cCURRPrefix);
              if FEQSumInfo.Show then
                FillCorrAccountStrings(Accounts, CreditStrings, 'CREDIT', cEQPrefix);

              FillQueryWithCorrAccounts(Accounts, cAccountPartCredit);
            end;
          finally
            CreditStrings.Free;
          end;
        end;

      finally
        for I := 0 to Accounts.Count - 1 do
          if Assigned(Accounts.Objects[I]) then
            Accounts.Objects[I].Free;
        Accounts.Free;
      end;

      DebitCreditSQL :=
        ' EXECUTE BLOCK ( '#13#10 +
        '   datebegin DATE = :BEGINDATE, '#13#10 +
        '   dateend DATE = :ENDDATE '#13#10 +
        ' ) '#13#10 +
        ' RETURNS ( '#13#10 +
          AnalyticReturns + ', '#13#10 +
        '   sortfield INTEGER, '#13#10 +
        '   ncu_begin_debit NUMERIC(15, %1:d), '#13#10 +
        '   ncu_begin_credit NUMERIC(15, %1:d), '#13#10 +
          GetDebitSumSelectClauseBalance +
        '   ncu_debit NUMERIC(15, %1:d), '#13#10 +
          GetCreditSumSelectClauseBalance +
        '   ncu_credit NUMERIC(15, %1:d), '#13#10 +
        '   ncu_end_debit NUMERIC(15, %1:d), '#13#10 +
        '   ncu_end_credit NUMERIC(15, %1:d), '#13#10 +
        '   curr_begin_debit NUMERIC(15, %3:d), '#13#10 +
        '   curr_begin_credit NUMERIC(15, %3:d), '#13#10 +
          GetDebitCurrSumSelectClauseBalance +
        '   curr_debit NUMERIC(15, %3:d), '#13#10 +
          GetCreditCurrSumSelectClauseBalance +
        '   curr_credit NUMERIC(15, %3:d), '#13#10 +
        '   curr_end_debit NUMERIC(15, %3:d), '#13#10 +
        '   curr_end_credit NUMERIC(15, %3:d), '#13#10 +
        '   eq_begin_debit NUMERIC(15, %5:d), '#13#10 +
        '   eq_begin_credit NUMERIC(15, %5:d), '#13#10 +
          GetDebitEQSumSelectClauseBalance +
        '   eq_debit NUMERIC(15, %5:d), '#13#10 +
          GetCreditEQSumSelectClauseBalance +
        '   eq_credit NUMERIC(15, %5:d), '#13#10 +
        '   eq_end_debit NUMERIC(15, %5:d), '#13#10 +
        '   eq_end_credit  NUMERIC(15, %5:d) '#13#10 +
        ' ) '#13#10 +
        ' AS '#13#10 +
        ' DECLARE VARIABLE varncubegin dcurrency; '#13#10 +
        ' DECLARE VARIABLE varcurrbegin dcurrency; '#13#10 +
        ' DECLARE VARIABLE vareqbegin dcurrency; '#13#10 +
        ' DECLARE VARIABLE varncudebit dcurrency; '#13#10 +
        ' DECLARE VARIABLE varncucredit dcurrency; '#13#10 +
        ' DECLARE VARIABLE varcurrdebit dcurrency; '#13#10 +
        ' DECLARE VARIABLE varcurrcredit dcurrency; '#13#10 +
        ' DECLARE VARIABLE vareqdebit dcurrency; '#13#10 +
        ' DECLARE VARIABLE vareqcredit dcurrency; '#13#10 +
        ' DECLARE VARIABLE varncuend dcurrency; '#13#10 +
        ' DECLARE VARIABLE varcurrend dcurrency; '#13#10 +
        ' DECLARE VARIABLE vareqend dcurrency; '#13#10 +
        ' DECLARE VARIABLE wasmovement INTEGER; '#13#10 +
        ' DECLARE VARIABLE closedate DATE; '#13#10;

      if FEntryDateInFields and (not FEntryDateIsFirst) then
        for I := 0 to TempVariables.Count - 1 do
          DebitCreditSQL := DebitCreditSQL +
            ' DECLARE VARIABLE ' + TempVariables.Names[I] + ' VARCHAR(180); '#13#10;

      DebitCreditSQL := DebitCreditSQL +
        ' BEGIN '#13#10 +
        '   closedate = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10;

      if FEntryDateInFields and (not FEntryDateIsFirst) then
        for I := 0 to TempVariables.Count - 1 do
          DebitCreditSQL := DebitCreditSQL + '   ' +
            TempVariables.Names[I] + ' = ''''; '#13#10;

      DebitCreditSQL := DebitCreditSQL +
          IIF(not FEntryDateIsFirst, ' FOR '#13#10, '') +
        ' SELECT '#13#10 +
        '   m.ncu, '#13#10 +
        '   m.curr, '#13#10 +
        '   m.eq '#13#10 +
          IIF(MainSelect <> '', ', ' + MainSelect + #13#10, '') +
        ' FROM '#13#10 +
        ' ( '#13#10 +
        '   SELECT '#13#10 +
        '     COALESCE(SUM(en.debitncu - en.creditncu), 0) AS ncu, '#13#10 +
        '     COALESCE(SUM(en.debitcurr - en.creditcurr), 0) AS curr, '#13#10 +
        '     COALESCE(SUM(en.debiteq - en.crediteq), 0) AS eq ' + #13#10 +
          IIF(MainSubSelect <> '', ', ' + MainSubSelect, '') + #13#10 +
        '   FROM '#13#10 +
        '   ( '#13#10 +
        '     SELECT '#13#10 +
        '       bal.debitncu, '#13#10 +
        '       bal.creditncu, '#13#10 +
        '       bal.debitcurr, '#13#10 +
        '       bal.creditcurr, '#13#10 +
        '       bal.debiteq, '#13#10 +
        '       bal.crediteq '#13#10 +
          IIF(MainSubSubSelect01 <> '', ', ' + MainSubSubSelect01 + #13#10, '') +
        '     FROM '#13#10 +
        '       ac_entry_balance bal '#13#10 +
        '     WHERE '#13#10 +
          IIF(AccountIDs <> '', ' bal.accountkey IN (' + AccountIDs + ') AND '#13#10, '') +
          IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' bal.currkey = ' + IntToStr(FCurrKey) + ' AND '#13#10, '') +
        '       bal.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
          AnalyticFilterBal +
        '  '#13#10 +
        '     UNION ALL '#13#10 +
        '  '#13#10 +
        '     SELECT '#13#10 +
          IIF(FEntryBalanceDate > FDateBegin,
            ' - e1.debitncu, '#13#10 +
            ' - e1.creditncu, '#13#10 +
            ' - e1.debitcurr, '#13#10 +
            ' - e1.creditcurr, '#13#10 +
            ' - e1.debiteq, '#13#10 +
            ' - e1.crediteq '#13#10,
            ' e1.debitncu, '#13#10 +
            ' e1.creditncu, '#13#10 +
            ' e1.debitcurr, '#13#10 +
            ' e1.creditcurr, '#13#10 +
            ' e1.debiteq, '#13#10 +
            ' e1.crediteq '#13#10) +
          IIF(MainSubSubSelect02 <> '', ', ' + MainSubSubSelect02 + #13#10, '') +
        '     FROM '#13#10 +
        '       ac_entry e '#13#10 +
        '       LEFT JOIN ac_entry e1 ON e1.id = e.id AND ' +
          IIF(FEntryBalanceDate > FDateBegin,
            ' e1.entrydate >= :datebegin AND e1.entrydate < :closedate '#13#10,
            ' e1.entrydate >= :closedate AND e1.entrydate < :datebegin '#13#10) +
        '     WHERE '#13#10 +
          IIF(AccountIDs <> '', ' e.accountkey IN (' + AccountIDs + ') AND '#13#10, '') +
          IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' e.currkey = ' + IntToStr(FCurrKey) + ' AND '#13#10, '') + 
          IIF(FEntryBalanceDate > FDateBegin,
            ' e.entrydate >= :datebegin AND '#13#10,
            ' e.entrydate >= :closedate AND '#13#10) +
          IIF(FEntryBalanceDate > FDateEnd,
            ' e.entrydate <= :closedate AND '#13#10,
            ' e.entrydate <= :dateend AND '#13#10) +
        '       e.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
          AnalyticFilterE +
          IIF(not FEntryDateIsFirst,
            '  '#13#10 +
            ' UNION ALL '#13#10 +
            '  '#13#10 +
            ' SELECT '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS debitncu, '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS creditncu, '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS debitcurr, '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS creditcurr, '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS debiteq, '#13#10 +
            '   CAST(0 as numeric(15, 4)) AS crediteq, '#13#10 +
              MainSubSubSelect03 + #13#10 +
            ' FROM '#13#10 +
            '   ac_entry em '#13#10 +
            '   LEFT JOIN ac_entry emc ON emc.recordkey = em.recordkey AND emc.accountpart <> em.accountpart '#13#10 +
            ' WHERE '#13#10 +
              IIF(AccountIDs <> '', ' em.accountkey IN (' + AccountIDs + ') AND '#13#10, '') +
            '   em.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
              IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND em.currkey = ' + IntToStr(FCurrKey) + #13#10, '') +
            '   AND em.entrydate >= :datebegin AND em.entrydate <= :dateend '#13#10 +
              IIF(FIncludeInternalMovement, '', Self.InternalMovementClause('em') + #13#10) +
              AnalyticFilterEM + #13#10 +
            ' GROUP BY '#13#10 +
              MainSubSubGroup03 + #13#10, '') +
        '  '#13#10 +
        '   ) en '#13#10 +
          IIF(MainGroup <> '', ' GROUP BY '#13#10 + MainGroup + #13#10, '') +
        ' ) m '#13#10 +
          IIF(MainJoin <> '', MainJoin + #13#10, '') +
          IIF(MainOrder <> '', ' ORDER BY '#13#10 + MainOrder + #13#10, '') +
        ' INTO '#13#10 +
        '   :varncubegin, :varcurrbegin, :vareqbegin '#13#10 +
          IIF(MainInto <> '', ', ' + MainInto + #13#10, '') +
          IIF(not FEntryDateIsFirst, ' DO BEGIN '#13#10, ';') +
        ' sortfield = 1; '#13#10 +
        ' wasmovement = 0; '#13#10 +
        ' IF (varncubegin IS NULL) THEN '#13#10 +
        '   varncubegin = 0; '#13#10 +
        ' IF (varcurrbegin IS NULL) THEN '#13#10 +
        '   varcurrbegin = 0; '#13#10 +
        ' IF (vareqbegin IS NULL) THEN '#13#10 +
        '   vareqbegin = 0; '#13#10 +
        '  '#13#10 +
          IIF(FEntryDateIsFirst, ' FOR '#13#10 +
            ' SELECT '#13#10 +
              CorrSelect + #13#10 +
            ' FROM ( SELECT '#13#10 +
              CorrSubSelect + #13#10 +
            ' FROM ( SELECT '#13#10 +
              CorrSubSubSelect + #13#10 +
            ' FROM '#13#10 +
            '   ac_entry em '#13#10 +
            '   LEFT JOIN ac_entry emc ON em.recordkey = emc.recordkey AND em.accountpart <> emc.accountpart '#13#10 +
            ' WHERE '#13#10 +
              IIF(AccountIDs <> '', ' em.accountkey IN (' + AccountIDs + ') AND '#13#10, '') +
            '   em.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
              IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND em.currkey = ' + IntToStr(FCurrKey), '') + 
            '   AND em.entrydate >= :datebegin '#13#10 +
            '   AND em.entrydate <= :dateend '#13#10 +
              IIF(FIncludeInternalMovement, '', Self.InternalMovementClause('em') + #13#10) +
              AnalyticFilterEM + #13#10 +
              CorrWhere + #13#10 +
            ' ) en '#13#10 +
              IIF(CorrGroup <> '', ' GROUP BY '#13#10 + CorrGroup + #13#10, '') +
            ' ) m '#13#10 +
              IIF(CorrJoin <> '', CorrJoin + #13#10, '') +
              IIF(CorrOrder <> '', ' ORDER BY '#13#10 + CorrOrder + #13#10, '') +
            ' INTO '#13#10 +
              CorrInto + #13#10 +
            ' DO BEGIN '#13#10, '') +
        '     IF (varncudebit IS NULL) THEN  '#13#10 +
        '       varncudebit = 0;  '#13#10 +
        '     IF (varncucredit IS NULL) THEN  '#13#10 +
        '       varncucredit = 0;  '#13#10 +
        '     IF (varcurrdebit IS NULL) THEN  '#13#10 +
        '       varcurrdebit = 0;  '#13#10 +
        '     IF (varcurrcredit IS NULL) THEN  '#13#10 +
        '       varcurrcredit = 0;  '#13#10 +
        '     IF (vareqdebit IS NULL) THEN  '#13#10 +
        '       vareqdebit = 0;  '#13#10 +
        '     IF (vareqcredit IS NULL) THEN  '#13#10 +
        '       vareqcredit = 0;  '#13#10;

      if FEntryDateInFields and (not FEntryDateIsFirst) then
      begin
        DebitCreditSQL := DebitCreditSQL + ' IF (';
        for I := 0 to TempVariables.Count - 1 do
        begin
          DebitCreditSQL := DebitCreditSQL +
            '(' + TempVariables.Names[I] + ' = ' + TempVariables.Values[TempVariables.Names[I]] + ')';
          if I <> TempVariables.Count - 1 then
            DebitCreditSQL := DebitCreditSQL + ' AND ';
        end;
        DebitCreditSQL := DebitCreditSQL + ') THEN '#13#10'BEGIN'#13#10 +
          ' varncubegin = varncuend; '#13#10 +
          ' varcurrbegin = varcurrend; '#13#10 +
          ' vareqbegin = vareqend; '#13#10'END ELSE BEGIN'#13#10;
        for I := 0 to TempVariables.Count - 1 do
          DebitCreditSQL := DebitCreditSQL +
            TempVariables.Names[I] + ' = ' + TempVariables.Values[TempVariables.Names[I]] + ';'#13#10;
        DebitCreditSQL := DebitCreditSQL + 'END'#13#10;
      end;

      DebitCreditSQL := DebitCreditSQL +
        '     ncu_debit = CAST((varncudebit / %0:d) AS NUMERIC(15, %1:d));  '#13#10 +
        '     ncu_credit = CAST((varncucredit / %0:d) AS NUMERIC(15, %1:d));  '#13#10 +
        '     curr_debit = CAST((varcurrdebit / %2:d) AS NUMERIC(15, %3:d));  '#13#10 +
        '     curr_credit = CAST((varcurrcredit / %2:d) AS NUMERIC(15, %3:d));  '#13#10 +
        '     eq_debit = CAST((vareqdebit / %4:d) AS NUMERIC(15, %5:d));  '#13#10 +
        '     eq_credit = CAST((vareqcredit / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
        '     varncuend = varncubegin + (varncudebit - varncucredit); '#13#10 +
        '     varcurrend = varcurrbegin + (varcurrdebit - varcurrcredit); '#13#10 +
        '     vareqend = vareqbegin + (vareqdebit - vareqcredit); '#13#10 +
        '  '#13#10 +
        '     IF (varncubegin > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       ncu_begin_debit = CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
        '       ncu_begin_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       ncu_begin_debit = 0; '#13#10 +
        '       ncu_begin_credit = - CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
        '     END '#13#10 +
        '     IF (varncuend > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       ncu_end_debit = CAST((varncuend / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
        '       ncu_end_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       ncu_end_debit = 0; '#13#10 +
        '       ncu_end_credit = - CAST((varncuend / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
        '     END '#13#10 +
        '  '#13#10 +
        '     IF (varcurrbegin > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       curr_begin_debit = CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
        '       curr_begin_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       curr_begin_debit = 0; '#13#10 +
        '       curr_begin_credit = - CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
        '     END '#13#10 +
        '     IF (varcurrend > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       curr_end_debit = CAST((varcurrend / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
        '       curr_end_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       curr_end_debit = 0; '#13#10 +
        '       curr_end_credit = - CAST((varcurrend / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
        '     END '#13#10 +
        '  '#13#10 +
        '     IF (vareqbegin > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       eq_begin_debit = CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
        '       eq_begin_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       eq_begin_debit = 0; '#13#10 +
        '       eq_begin_credit = - CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
        '     END '#13#10 +
        '     IF (vareqend > 0) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       eq_end_debit = CAST((vareqend / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
        '       eq_end_credit = 0; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '     BEGIN '#13#10 +
        '       eq_end_debit = 0; '#13#10 +
        '       eq_end_credit = - CAST((vareqend / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
        '     END '#13#10 +
          IIF(FEntryDateIsFirst,
            ' varncubegin = varncuend; varcurrbegin = varcurrend; vareqbegin = vareqend;'#13#10, '') +
        ' IF ((ncu_debit <> 0) OR (ncu_credit <> 0) OR (cast((varncubegin / %0:d) AS NUMERIC(15, %1:d)) <> 0)' +
          IIF(FCurrSumInfo.Show, ' OR (curr_debit <> 0) OR (curr_credit <> 0) OR (cast((varcurrbegin / %2:d) AS NUMERIC(15, %3:d))  <> 0)', '') +
          IIF(FEQSumInfo.Show, ' OR (eq_debit <> 0) OR (eq_credit <> 0) OR (cast((vareqbegin / %4:d) AS NUMERIC(15, %5:d))  <> 0)', '') + #13#10;

      // Добавляем проверку на неравенство нулю расширенного отображения дебета и кредита
      for I := 0 to FNcuDebitAliases.Count - 1 do
        DebitCreditSQL := DebitCreditSQL + ' OR (' + FNcuDebitAliases.Strings[I] + ' <> 0) ';
      for I := 0 to FNcuCreditAliases.Count - 1 do
        DebitCreditSQL := DebitCreditSQL + ' OR (' + FNcuCreditAliases.Strings[I] + ' <> 0) ';
      // Добавляем проверку на неравенство нулю расширенного отображения дебета и кредита для валюты
      if FCurrSumInfo.Show then
      begin
        DebitCreditSQL := DebitCreditSQL + #13#10;
        for I := 0 to FCurrDebitAliases.Count - 1 do
          DebitCreditSQL := DebitCreditSQL + ' OR (' + FCurrDebitAliases.Strings[I] + ' <> 0) ';
        for I := 0 to FCurrCreditAliases.Count - 1 do
          DebitCreditSQL := DebitCreditSQL + ' OR (' + FCurrCreditAliases.Strings[I] + ' <> 0) ';
      end;
      // Добавляем проверку на неравенство нулю расширенного отображения дебета и кредита для эквивалента
      if FEQSumInfo.Show then
      begin
        DebitCreditSQL := DebitCreditSQL + #13#10;
        for I := 0 to FEQDebitAliases.Count - 1 do
          DebitCreditSQL := DebitCreditSQL + ' OR (' + FEQDebitAliases.Strings[I] + ' <> 0) ';
        for I := 0 to FEQCreditAliases.Count - 1 do
          DebitCreditSQL := DebitCreditSQL + ' OR (' + FEQCreditAliases.Strings[I] + ' <> 0) ';
      end;

      DebitCreditSQL := DebitCreditSQL + 
        ') THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       wasmovement = 1; '#13#10 +
        '       SUSPEND; '#13#10 +
        '     END '#13#10 +
        '   END '#13#10 +
        '  '#13#10 +
          IIF(FEntryDateIsFirst,
            '   IF (wasmovement = 0) THEN '#13#10 +
            '   BEGIN '#13#10 +
            '     IF (varncubegin > 0) THEN '#13#10 +
            '     BEGIN '#13#10 +
            '       ncu_begin_debit = CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
            '       ncu_begin_credit = 0; '#13#10 +
            '       ncu_end_debit = CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
            '       ncu_end_credit = 0; '#13#10 +
            '     END '#13#10 +
            '     ELSE '#13#10 +
            '     BEGIN '#13#10 +
            '       ncu_begin_debit = 0; '#13#10 +
            '       ncu_begin_credit = - CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
            '       ncu_end_debit = 0; '#13#10 +
            '       ncu_end_credit = - CAST((varncubegin / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
            '     END '#13#10 +
            '  '#13#10 +
            '     IF (varcurrbegin > 0) THEN '#13#10 +
            '     BEGIN '#13#10 +
            '       curr_begin_debit = CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
            '       curr_begin_credit = 0; '#13#10 +
            '       curr_end_debit = CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
            '       curr_end_credit = 0; '#13#10 +
            '     END '#13#10 +
            '     ELSE '#13#10 +
            '     BEGIN '#13#10 +
            '       curr_begin_debit = 0; '#13#10 +
            '       curr_begin_credit = - CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
            '       curr_end_debit = 0; '#13#10 +
            '       curr_end_credit = - CAST((varcurrbegin / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
            '     END '#13#10 +
            '  '#13#10 +
            '     IF (vareqbegin > 0) THEN '#13#10 +
            '     BEGIN '#13#10 +
            '       eq_begin_debit = CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
            '       eq_begin_credit = 0; '#13#10 +
            '       eq_end_debit = CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
            '       eq_end_credit = 0; '#13#10 +
            '     END '#13#10 +
            '     ELSE '#13#10 +
            '     BEGIN '#13#10 +
            '       eq_begin_debit = 0; '#13#10 +
            '       eq_begin_credit = - CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
            '       eq_end_debit = 0; '#13#10 +
            '       eq_end_credit = - CAST((vareqbegin / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
            '     END '#13#10 +
            '     SUSPEND; '#13#10 +
            '   END '#13#10, '') +
        ' END ';

    finally
      TempVariables.Free;
    end;

    DebitCreditSQL := Format(DebitCreditSQL,
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits,
      FCurrSumInfo.Scale, FCurrSumInfo.DecDigits,
      FEQSumInfo.Scale, FEQSumInfo.DecDigits]);

  end
  else
  ///// отсюда начинаем править код, здесь не используется ентри баланс
  begin
    Strings := TgdvCorrFieldInfoList.Create;
    try
      DebitCreditSQL := '';
      FromClause := '';
      FromClause1 := '';

      FromClause := GetJoinTableClause('e');

      GroupClause := '';
      OrderClause := '';
      IDSelect := '';
      NameSelect := '';
      WhereClause := '';

      AnalyticFilter := Self.GetCondition('e');
      if AnalyticFilter > '' then
        AnalyticFilter := ' AND '#13#10 + AnalyticFilter + #13#10;

      if FCurrSumInfo.Show and (FCurrKey > 0) then
        CurrId := Format('  AND e.currkey = %d'#13#10, [FCurrKey])
      else
        CurrId := '';
      
      NcuDecDig := Format('NUMERIC(15, %d)', [FNcuSumInfo.DecDigits]);
      CurrDecDig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);
      EQDecDig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

      if FEntryDateIsFirst then
      begin
        //Названия процедер вычисления сальдо
        if (FAcctGroupBy[0].FieldName = ENTRYDATE) then
        begin
          if (FAcctConditions.Count = 0) then
          begin
            L_S := Format('AC_L_S(:begindate, :enddate, %d, %d, %d, %d, :currkey)',
              [FSQLHandle, FCompanyKey,
              Integer(FAllHolding), -1]);
            Q_S := Format('AC_Q_S(%s, :begindate, :enddate, %d, %d, %d, %d, :currkey)',
            ['%s', FSQLHandle, FCompanyKey,
            Integer(FAllHolding), -1]);
          end
          else
          begin
            L_S := Format('AC_E_L_S(:begindate, :saldobegin, :saldobegincurr, :saldobegineq, %d, :currkey)', [FSQLHandle]);
            Q_S := Format('AC_E_Q_S(%s, :begindate, :saldobegin%s, %d, :currkey)',
            ['%s', '%s', FSQLHandle]);
          end;
        end else
        begin
          if FAcctConditions.Count = 0 then
          begin
            L_S := Format('AC_L_S1(:begindate, :enddate, %d, %d, %d, %d, %s, :currkey)',
              [FSQLHandle, FCompanyKey,
              Integer(FAllHolding), -1,
              FAcctGroupBy[0].Additional]);
            Q_S := Format('AC_Q_S1(%s, :begindate, :enddate, %d, %d, %d, %d, %s, :currkey)',
            ['%s', FSQLHandle, FCompanyKey,
            Integer(FAllHolding), -1,
            FAcctGroupBy[0].Additional]);
          end else
          begin
            L_S := Format('AC_E_L_S1(:begindate, :saldobegin, :saldobegincurr, :saldobegineq, %d, %s, :currkey)',
              [FSQLHandle, FAcctGroupBy[0].Additional]);
            Q_S := Format('AC_E_Q_S1(%s, :begindate, :saldobegin%s, %d, %s, :currkey)',
            ['%s', '%s', FSQLHandle, FAcctGroupBy[0].Additional]);
          end;
        end;
      end;

      GdDocJoined := GetIsDocTypeCondition;

      SelectClause := '';
      N := FAcctGroupBy.Count;
      for I := 0 to FAcctGroupBy.Count - 1 do
      begin
        F := FAcctGroupBy[I].Field;
        if Assigned(F) then
        begin
          Index := IndexOfAnalyticLevel(F.FieldName);
          if Index > -1 then
          begin
            Line := TgdvAcctAnalyticLevels(FAcctAnalyticLevels[Index]);
            if not Line.IsEmpty then
            begin
              for J := 0 to Line.Levels.Count - 1 do
              begin
                Alias := Format('c%d', [N]);
                Name := Format('NAME%d', [N]);
                SortName := Format('s%d', [N]);

                ProcessAnalytic(FAcctGroupBy[I]);

                if F.FieldName = 'DOCUMENTTYPEKEY' then
                begin
                  if not GdDocJoined then
                  begin
                    FromClause := FromClause + ' LEFT JOIN gd_document t_doc ON e.documentkey = t_doc.id'#13#10;
                    GdDocJoined := True;
                  end;

                  FromClause := FromClause + Format('  LEFT JOIN %s(%s, t_doc.%s) lg_%s ON 1=1'#13#10,
                    [Line.SPName, Line.Levels[J], F.FieldName, Alias]) +
                    Format('  LEFT JOIN %s %s ON %s.%s = lg_%s.Id'#13#10,
                    [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName,
                    Alias]);
                end
                else
                  FromClause := FromClause + Format('  LEFT JOIN %s(%s, e.%s) lg_%s ON 1=1'#13#10,
                    [Line.SPName, Line.Levels[J], F.FieldName, Alias]) +
                    Format('  LEFT JOIN %s %s ON %s.%s = lg_%s.Id'#13#10,
                    [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName,
                    Alias]);

                Inc(N);
              end;
            end;
          end;
        end;  
        //****
        Alias := Format('c%d', [I]);
        Name := Format('NAME%d', [I]);
        SortName := Format('s%d', [I]);

        ProcessAnalytic(FAcctGroupBy[I]);
        if Assigned(F) and Assigned(F.ReferencesField) then
        begin
          if F.FieldName = 'DOCUMENTTYPEKEY' then
          begin
            if not GdDocJoined then
            begin
              FromClause := FromClause + ' LEFT JOIN gd_document t_doc ON e.documentkey = t_doc.id'#13#10;
              GdDocJoined := True;
            end;

            FromClause := FromClause + Format('  LEFT JOIN %s %s ON %s.%s = t_doc.%s'#13#10,
              [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName,
              F.FieldName])
          end
          else
            FromClause := FromClause + Format('  LEFT JOIN %s %s ON %s.%s = e.%s'#13#10,
              [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName,
              F.FieldName]);
        end;
        //****
        QuantityGroup := '';

        if FAcctValues.Count > 0 then
        begin
          for K := 0 to FAcctValues.Count - 1 do
          begin
            VKeyAlias := Self.GetKeyAlias(FAcctValues.Names[K]);
            ValueAlias := 'v_' + Self.GetKeyAlias(FAcctValues.Names[K]);
            QuantityAlias := 'q_' + Self.GetKeyAlias(FAcctValues.Names[K]);
            AccWhereQuantity := AccWhereQuantity + 'SUM(' + QuantityAlias + '.quantity) <> 0 OR ';
            if not FEntryDateInFields then
            begin
              BC := TgdvSimpleLedgerTotalBlock;
            end
            else
            begin
              if FEntryDateIsFirst then
                BC := TgdvStorageLedgerTotalBlock
              else
                BC := TgdvStorageLedgerTotalBlock1;
            end;

            FQuantityTotalBlock := BC.Create;
            T.TotalBlocks.Add(FQuantityTotalBlock);
            FQuantityTotalBlock.BeginDebit.FieldName := Format(BaseAcctQuantityFieldList[2].FieldName, [VKeyAlias]);
            FQuantityTotalBlock.BeginCredit.FieldName := Format(BaseAcctQuantityFieldList[3].FieldName, [VKeyAlias]);
            FQuantityTotalBlock.Debit.FieldName := Format(BaseAcctQuantityFieldList[0].FieldName, [VKeyAlias]);
            FQuantityTotalBlock.Credit.FieldName := Format(BaseAcctQuantityFieldList[1].FieldName, [VKeyAlias]);
            FQuantityTotalBlock.EndDebit.FieldName := Format(BaseAcctQuantityFieldList[4].FieldName, [VKeyAlias]);
            FQuantityTotalBlock.EndCredit.FieldName := Format(BaseAcctQuantityFieldList[5].FieldName, [VKeyAlias]);
            GetDebitQuantitySelectClause;
            GetCreditQuantitySelectClause;
            FQuantityTotalBlock := nil;

            if not FEntryDateIsFirst then
            begin
              SelectClause := SelectClause + ','#13#10 +
                Format(
                  '  CAST(IIF(SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0)) > 0 AND '#13#10 +
                  '    NOT (SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0))) IS NULL, '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0)), 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_D_%1:s,'#13#10 +
                  '  CAST(IIF(SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0)) > 0 AND '#13#10 +
                  '    NOT (SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0))) IS NULL, '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e1.accountpart = ''D'', %0:s.quantity, 0)), 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_C_%1:s,'#13#10 +
                  '  CAST(SUM(IIF((e2.accountpart = ''D'') AND NOT %0:s.quantity IS NULL, %0:s.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_D_%1:s,'#13#10 +
                  '  CAST(SUM(IIF((e2.accountpart = ''C'') AND NOT %0:s.quantity IS NULL, %0:s.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_C_%1:s,'#13#10 +
                  '  CAST(IIF(SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0)) > 0 AND '#13#10 +
                  '    NOT (SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0))) IS NULL, '#13#10 +
                  '    SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0)), 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_D_%1:s,'#13#10 +
                  '  CAST(IIF(SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0)) > 0 AND '#13#10 +
                  '    NOT (SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0))) IS NULL, '#13#10 +
                  '    SUM(IIF(e.accountpart = ''C'', %0:s.quantity, 0)) - '#13#10 +
                  '    SUM(IIF(e.accountpart = ''D'', %0:s.quantity, 0)), 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_C_%1:s',
                  [QuantityAlias, VKeyAlias, FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]);
              if I = 0 then
              begin
                FromClause := FromClause + #13#10 +
                  Format('  LEFT JOIN ac_quantity %0:s ON %0:s.entrykey = e.id AND '#13#10 +
                    '     %0:s.valuekey = %1:s ', [QuantityAlias, FAcctValues.Names[K]]);
              end;
            end
            else
            begin
              if FAcctGroupBy[0].FieldName = ENTRYDATE then
              begin
                SelectClause := SelectClause + ','#13#10 +
                  Format(
                    '  CAST(IIF(NOT %0:s.debitbegin IS NULL, %0:s.debitbegin, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_D_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.creditbegin IS NULL, %0:s.creditbegin, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_C_%1:s,'#13#10 +
                    '  CAST(SUM(IIF((e2.accountpart = ''D'') AND NOT %0:s_f.quantity IS NULL, %0:s_f.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_D_%1:s,'#13#10 +
                    '  CAST(SUM(IIF((e2.accountpart = ''C'') AND NOT %0:s_f.quantity IS NULL, %0:s_f.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_C_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.debitend IS NULL, %0:s.debitend, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_D_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.creditend IS NULL, %0:s.creditend, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_C_%1:s',
                    [QuantityAlias, VKeyAlias, FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]);
                if QuantityGroup > '' then
                  QuantityGroup := QuantityGroup + ','#13#10;
                QuantityGroup := QuantityGroup + Format('%s.debitbegin, %s.creditbegin, %s.debitend, %s.creditend',
                  [QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias]);

                if I = 0 then
                begin
                  if FAcctConditions.Count = 0 then
                    QS := Format(Q_S, [FAcctValues.Names[K]])
                  else
                    QS := Format(Q_S, [FAcctValues.Names[K], VKeyAlias]);

                  FromClause1 := FromClause1 + #13#10 + Format('  LEFT JOIN %s %s '#13#10 +
                    '    ON ls.entrydate = %s.entrydate ', [QS, QuantityAlias, QuantityAlias]);

                  FromClause := FromClause + #13#10 +
                    Format('  LEFT JOIN ac_quantity %0:s_f ON %0:s_f.entrykey = e2.id AND %0:s_f.valuekey = %1:s',
                      [QuantityAlias, FAcctValues.Names[K]]);
                end;
              end
              else
              begin
                SelectClause := SelectClause + ','#13#10 +
                  Format(
                    '  CAST(IIF(NOT %0:s.debitbegin IS NULL, %0:s.debitbegin, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_D_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.creditbegin IS NULL, %0:s.creditbegin, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_B_C_%1:s,'#13#10 +
                    '  CAST(SUM(IIF((e2.accountpart = ''D'') AND NOT %0:s_f.quantity IS NULL, %0:s_f.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_D_%1:s,'#13#10 +
                    '  CAST(SUM(IIF((e2.accountpart = ''C'') AND NOT %0:s_f.quantity IS NULL, %0:s_f.quantity, 0)) / %2:d AS NUMERIC(15, %3:d)) AS Q_C_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.debitend IS NULL, %0:s.debitend, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_D_%1:s,'#13#10 +
                    '  CAST(IIF(NOT %0:s.creditend IS NULL, %0:s.creditend, 0) / %2:d AS NUMERIC(15, %3:d)) AS Q_E_C_%1:s',
                    [QuantityAlias, VKeyAlias, FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]);

                if QuantityGroup > '' then
                  QuantityGroup := QuantityGroup + ','#13#10;
                QuantityGroup := QuantityGroup + Format('%s.debitbegin, %s.creditbegin, %s.debitend, %s.creditend',
                  [QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias, QuantityAlias]);

                if I = 0 then
                begin
                  if FAcctConditions.Count = 0 then
                    QS := Format(Q_S, [FAcctValues.Names[K]])
                  else
                    QS := Format(Q_S, [FAcctValues.Names[K], VKeyAlias]);

                  FromClause1 := FromClause1 + #13#10 +  Format('  LEFT JOIN %s %s '#13#10 +
                    '    ON ls.dateparam = %s.dateparam ', [QS, QuantityAlias,
                    QuantityAlias]);

                  FromClause := FromClause + #13#10 +
                    Format('  LEFT JOIN ac_quantity %s_f ON %s_f.entrykey = e2.id AND %s_f.valuekey = %s',
                      [QuantityAlias, QuantityAlias, QuantityAlias, FAcctValues.Names[K]]);
                end;
              end;
            end;
          end;
          SelectClause := SelectClause +  GetDebitQuantitySelectClause + GetCreditQuantitySelectClause;
          if I = 0 then
            FromClause := FromClause  + #13#10 + GetQuantityJoinClause;
        end;
      end;

      SelectClause :=  SortSelect + ', '#13#10 + IDSelect + ', '#13#10 +
        NameSelect + SelectClause + ', '#13#10'  CAST(1 AS INTEGER) AS SORTFIELD';

      HavingCount := '';

      if not FEntryDateIsFirst  then
      begin
        NcuBegin :=
          Format('  CAST(IIF(SUM(e1.debitncu - e1.creditncu) > 0, SUM(e1.debitncu - e1.creditncu) / %0:d, 0) AS %1:s) AS NCU_BEGIN_DEBIT, '#13#10 +
          '  CAST(IIF(SUM(e1.creditncu - e1.debitncu) > 0, SUM(e1.creditncu - e1.debitncu) / %0:d, 0) AS %1:s) AS NCU_BEGIN_CREDIT, '#13#10,
          [FNcuSumInfo.Scale, NcuDecDig]);
        NcuEnd :=
          Format('  CAST(IIF(SUM(e.debitncu - e.creditncu) > 0, SUM(e.debitncu - e.creditncu) / %0:d, 0) AS %1:s) AS NCU_END_DEBIT, '#13#10 +
          '  CAST(IIF(SUM(e.creditncu - e.debitncu) > 0, SUM(e.creditncu - e.debitncu) / %0:d, 0) AS %1:s) AS NCU_END_CREDIT, '#13#10,
          [FNcuSumInfo.Scale, NcuDecDig]);

        if FCurrSumInfo.Show then
        begin
          CurrBegin :=
            Format('  CAST(IIF(SUM(e1.debitcurr - e1.creditcurr) > 0, SUM(e1.debitcurr - e1.creditcurr) / %0:d, 0) AS %1:s) AS CURR_BEGIN_DEBIT, '#13#10 +
            '  CAST(IIF(SUM(e1.creditcurr - e1.debitcurr) > 0, SUM(e1.creditcurr - e1.debitcurr) /%0:d, 0) AS %1:s) AS CURR_BEGIN_CREDIT, '#13#10,
            [FCurrSumInfo.Scale, CurrDecDig]);
          CurrEnd :=
            Format('  CAST(IIF(SUM(e.debitcurr - e.creditcurr) > 0, SUM(e.debitcurr - e.creditcurr) / %0:d, 0) AS %1:s) AS CURR_END_DEBIT, '#13#10 +
            '  CAST(IIF(SUM(e.creditcurr - e.debitcurr) > 0, SUM(e.creditcurr - e.debitcurr) / %0:d, 0) AS %1:s) AS CURR_END_CREDIT '#13#10,
            [FCurrSumInfo.Scale, CurrDecDig]);
        end else
        begin
          CurrBegin :=
            Format('  CAST(0 AS %0:s) AS CURR_BEGIN_DEBIT, '#13#10 +
            '  CAST(0 AS %0:s) AS CURR_BEGIN_CREDIT, '#13#10,
            [CurrDecDig]);
          CurrEnd :=
            Format('  CAST(0 AS %0:s) AS CURR_END_DEBIT, '#13#10 +
            '  CAST(0  AS %0:s) AS CURR_END_CREDIT '#13#10,
           [CurrDecDig]);
        end;

        if FEQSumInfo.Show then
        begin
          EQBegin :=
            Format('  CAST(IIF(SUM(e1.debiteq - e1.crediteq) > 0, SUM(e1.debiteq - e1.crediteq) / %0:d, 0) AS %1:s) AS EQ_BEGIN_DEBIT, '#13#10 +
            '  CAST(IIF(SUM(e1.crediteq - e1.debiteq) > 0, SUM(e1.crediteq - e1.debiteq) /%0:d, 0) AS %1:s) AS EQ_BEGIN_CREDIT, '#13#10,
            [FEQSumInfo.Scale, EQDecDig]);
          EQEnd :=
            Format('  CAST(IIF(SUM(e.debiteq - e.crediteq) > 0, SUM(e.debiteq - e.crediteq) / %0:d, 0) AS %1:s) AS EQ_END_DEBIT, '#13#10 +
            '  CAST(IIF(SUM(e.crediteq - e.debiteq) > 0, SUM(e.crediteq - e.debiteq) / %0:d, 0) AS %1:s) AS EQ_END_CREDIT '#13#10,
            [FEQSumInfo.Scale, EQDecDig]);
        end else
        begin
          EQBegin :=
            Format('  CAST(0 AS %0:s) AS EQ_BEGIN_DEBIT, '#13#10 +
            '  CAST(0 AS %0:s) AS EQ_BEGIN_CREDIT, '#13#10,
            [EQDecDig]);
          EQEnd :=
            Format('  CAST(0 AS %0:s) AS EQ_END_DEBIT, '#13#10 +
            '  CAST(0  AS %0:s) AS EQ_END_CREDIT '#13#10,
            [EQDecDig]);
        end;

        HavingClause := GetHavingClause;
        if HavingClause > '' then
          HavingClause := HavingClause + ' OR '#13#10 ;
        HavingClause := HavingClause + AccWhereQuantity + ' SUM(e2.debitncu) <> 0 OR '#13#10 +
          '  SUM(e2.creditncu) <> 0 OR '#13#10 +
          '  SUM(e1.debitncu - e1.creditncu) <> 0'#13#10;
          
        if FCurrSumInfo.Show then
        begin
          HavingClause := HavingClause + ' OR '#13#10 +
            '  SUM(e1.debitcurr - e1.creditcurr) <> 0 OR '#13#10 +
            '  SUM(e2.debitcurr) <> 0 OR SUM(e2.creditcurr) <> 0 ';
        end;

        if FEQSumInfo.Show then
        begin
          HavingClause := HavingClause + ' OR '#13#10 +
            '  SUM(e1.debiteq - e1.crediteq) <> 0 OR '#13#10 +
            '  SUM(e2.debiteq) <> 0 OR SUM(e2.crediteq) <> 0 ';
        end;

        HavingClause := 'HAVING ' + HavingClause;

        DebitCreditSQL := Format(cDebitCredit, [SelectClause, NcuBegin,
          GetDebitSumSelectClause, FNcuSumInfo.Scale, NcuDecDig,
          GetCreditSumSelectClause, FNcuSumInfo.Scale, NcuDecDig, NcuEnd,
          CurrBegin,
          GetDebitCurrSumSelectClause, FCurrSumInfo.Scale, CurrDecDig, GetCreditCurrSumSelectClause,
          FCurrSumInfo.Scale, CurrDecDig, CurrEnd,
          EQBegin,
          GetDebitEQSumSelectClause, FEQSumInfo.Scale, EQDecDig, GetCreditEQSumSelectClause,
          FEQSumInfo.Scale, EQDecDig, EQEnd,
          FromClause + Self.GetSumJoinClause, AccountInClause('e'), FCompanyList,
          CurrId, Self.InternalMovementClause + AnalyticFilter, GroupClause, HavingClause]) +
          HavingCount + DebitCreditSQL
      end
      else
      begin
          GroupClause1 := 'ls.debitncubegin, ls.debitncuend, ls.creditncubegin, ls.creditncuend, '#13#10 +
            '  ls.debitcurrbegin, ls.debitcurrend, ls.creditcurrbegin, ls.creditcurrend, '#13#10 +
            '  ls.debiteqbegin, ls.debiteqend, ls.crediteqbegin, ls.crediteqend';

          if QuantityGroup > '' then
            GroupClause1 := GroupClause1 + ', '#13#10 + QuantityGroup;

          if GroupClause > '' then
            GroupClause1 := GroupClause1 + ', '#13#10;
          GroupClause1 := GroupClause1 + GroupClause;

          if FAcctGroupBy[0].FieldName = ENTRYDATE then
          begin
            DebitCreditSQL := Format(cFirstEntryDateDebitCredit, [SelectClause,
              FNcuSumInfo.Scale, NcuDecDig, FNcuSumInfo.Scale, NcuDecDig, GetDebitSumSelectClause,
              FNcuSumInfo.Scale, NcuDecDig, GetCreditSumSelectClause, FNcuSumInfo.Scale, NcuDecDig,
              FNcuSumInfo.Scale, NcuDecDig, FNcuSumInfo.Scale, NcuDecDig,
              FCurrSumInfo.Scale, CurrDecDig,
              FCurrSumInfo.Scale, CurrDecDig, GetDebitCurrSumSelectClause, FCurrSumInfo.Scale,
              CurrDecDig, GetCreditCurrSumSelectClause, FCurrSumInfo.Scale, CurrDecDig,
              FCurrSumInfo.Scale, CurrDecDig, FCurrSumInfo.Scale, CurrDecDig,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig, GetDebitEQSumSelectClause,
              FEQSumInfo.Scale, EQDecDig, GetCreditEQSumSelectClause,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig, L_S,
              FromClause1, AccountInClause('e'), '', FromClause + GetSumJoinClause,
              FCompanyList, CurrId, InternalMovementClause + AnalyticFilter,
              GroupClause1]) +  HavingCount + DebitCreditSQL;
          end
          else
          begin
            DebitCreditSQL := Format(cFirstGroupEntryDateDebitCredit, [SelectClause,
              FNcuSumInfo.Scale, NcuDecDig, FNcuSumInfo.Scale, NcuDecDig, GetDebitSumSelectClause,
              FNcuSumInfo.Scale, NcuDecDig, GetCreditSumSelectClause, FNcuSumInfo.Scale, NcuDecDig,
              FNcuSumInfo.Scale, NcuDecDig, FNcuSumInfo.Scale, NcuDecDig,
              FCurrSumInfo.Scale, CurrDecDig,
              FCurrSumInfo.Scale, CurrDecDig, GetDebitCurrSumSelectClause,
              FCurrSumInfo.Scale, CurrDecDig, GetCreditCurrSumSelectClause,
              FCurrSumInfo.Scale, CurrDecDig,
              FCurrSumInfo.Scale, CurrDecDig,
              FCurrSumInfo.Scale, CurrDecDig,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig, GetDebitEQSumSelectClause,
              FEQSumInfo.Scale, EQDecDig, GetCreditEQSumSelectClause,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig,
              FEQSumInfo.Scale, EQDecDig,
              L_S, FromClause1,
              AccountInClause('e'), FAcctGroupBy[0].Additional, '',
              FromClause + GetSumJoinClause, FCompanyList,
              CurrId, InternalMovementClause + AnalyticFilter, GroupClause1]) +
              HavingCount + DebitCreditSQL;
          end;
      end;
      DebitCreditSQL := DebitCreditSQL + #13#10'ORDER BY ' + OrderClause;
    finally
      Strings.Free;
    end;
  end;
  Self.SelectSQL.Text := DebitCreditSQL;
end;                                             

function TgdvAcctLedger.LargeSQLErrorMessage: String;
begin
  Result := 'Указано большое количество аналитик для '#13#10 +
    'группировки либо количественных показателей.'#13#10'Построение отчета не возможно.'; 
end;

procedure TgdvAcctLedger.AddLedgerFieldInfo(FieldName, Caption,
  DisplayFormat: string; Visible, Condition: Boolean; AccountKey: Integer;
  AccountPart, DisplayField: string);
var
  FI: TgdvLedgerFieldInfo;
begin
  if Assigned(FFieldInfos) then
  begin
    FI := FFieldInfos.AddInfo(TgdvLedgerFieldInfo) as TgdvLedgerFieldInfo;
    FI.FieldName := FieldName;
    FI.Caption := Caption;
    FI.Visible := fvVisible;
    FI.DisplayFormat := DisplayFormat;
    FI.Condition := Condition;
    FI.AccountKey := AccountKey;
    FI.AccountPart := AccountPart;
    FI.Total := True;
    if DisplayField > '' then
    begin
      FI.DisplayFields.Add(DisplayField);
    end;
  end;  
end;

procedure TgdvAcctLedger.SetSQLParams;
var
  I: Integer;
  ibsql: TIBSQL;
  FieldName: String;
begin
  inherited;

  if not FUseEntryBalance then
  begin
    if FEntryDateIsFirst then
    begin
      if FCurrSumInfo.Show and (FCurrkey > 0) then
        Self.ParamByName(fnCurrKey).AsInteger := FCurrkey
      else
        Self.ParamByName(fnCurrKey).AsInteger := 0;

      if FAcctConditions.Count > 0 then
      begin
        ibsql := TIBSQL.Create(nil);
        try
          ibsql.Transaction := gdcBaseManager.ReadTransaction;
          SaldoBeginSQL(ibsql);
          ibsql.ParamByName('datebegin').AsDateTime := FDateBegin;
          ibsql.ExecQuery;

          Self.ParamByName('saldobegin').AsCurrency := ibsql.FieldByName('saldobegin').AsCurrency;
          Self.ParamByName('saldobegincurr').AsCurrency := ibsql.FieldByName('saldobegincurr').AsCurrency;
          Self.ParamByName('saldobegineq').AsCurrency := ibsql.FieldByName('saldobegineq').AsCurrency;
          for I := 0 to FAcctValues.Count - 1 do
          begin
            FieldName := Format('saldobegin%s', [GetKeyAlias(FAcctValues.Names[i])]);
            Self.ParamByName(FieldName).AsCurrency := ibsql.FieldByName(FieldName).AsCurrency;
          end;
        finally
          ibsql.Free;
        end;
      end;
    end;
  end;  
end;

procedure TgdvAcctLedger.SaldoBeginSQL(const SQL: TIBSQL);
var
  I: Integer;
  VKeyAlias: string;
begin
  SQL.SQL.Text :=
    'SELECT '#13#10 +
    'SUM(e.debitncu - e.creditncu) AS saldobegin,'#13#10 +
    'SUM(e.debitcurr - e.creditcurr) AS saldobegincurr,'#13#10 +
    'SUM(e.debiteq - e.crediteq) AS saldobegineq';
  if FAcctValues.Count > 0 then
  begin
    for I := 0 to FAcctValues.Count - 1 do
    begin
      SQL.SQL[SQL.SQL.Count - 1] := SQL.SQL[SQL.SQL.Count - 1] + ', ';
      VKeyAlias := GetKeyAlias(FAcctValues.Names[I]);
      SQL.SQL.Add(  Format('SUM(IIF(e.accountpart = ''D'', q%0:s.quantity, 0)) - '#13#10 +
        'SUM(IIF(e.accountpart = ''C'', q%0:s.quantity, 0)) AS saldobegin%0:s', [VKeyAlias]));
    end;
  end;
  SQL.SQL.Add('FROM');
  SQL.SQL.Add('  ac_entry e LEFT JOIN ac_record r ON r.id = e.recordkey');
  SQL.SQL.Add(GetJoinTableClause('e'));
  for I := 0 to FAcctValues.Count - 1 do
  begin
    VKeyAlias := GetKeyAlias(FAcctValues.Names[I]);
    SQL.SQL.Add(  Format('LEFT JOIN ac_quantity q%0:s ON q%0:s.entrykey = e.id AND q%0:s.valuekey = %1:s',
      [VKeyAlias, FAcctValues.Names[I]]));
  end;
  SQL.SQL.Add('WHERE');
  if FAccounts.Count > 0 then
    SQL.SQL.Add(Format('e.accountkey IN (%s) AND', [IDList(FAccounts)]));

  SQL.SQL.Add('e.entrydate < :datebegin AND');

  SQL.SQL.Add(Format('r.companykey IN (%s) AND', [FCompanyList]));
  if FCurrSumInfo.Show and  (FCurrKey > 0) then
  begin
    SQL.SQL.Add(Format(' e.currkey = %d AND ', [FCurrKey]));
  end;

  SQL.SQL.Text := SQL.SQL.Text + #13#10 + GetCondition('e');
end;

procedure TgdvAcctLedger.SetDefaultParams;
begin
  inherited;

  FEnchancedSaldo := False;
  FShowCorrSubAccounts := False;
  FShowDebit := True;
  FShowCredit := True;
  FSumNull := False;
end;

class function TgdvAcctLedger.ConfigClassName: string;
begin
  Result := 'TAccLedgerConfig';
end;

procedure TgdvAcctLedger.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
  TreeAnalyticList: TStringList;
  AnalyticListField: TStringList;
  ListFieldName: String;
  Stream: TStream;
  Count: Integer;
  FieldName: String;
  ShowTotal: Boolean;
  I: Integer;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    FShowDebit := C.ShowDebit;
    FShowCredit := C.ShowCredit;
    FShowCorrSubAccounts := C.ShowCorrSubAccounts;
    FSumNull := C.SumNull;
    FEnchancedSaldo := C.EnchancedSaldo;
    // группировка по аналитикам
    AnalyticListField := TStringList.Create;
    try
      // Список полей просмотра для группировочных аналитик
      AnalyticListField.Text := C.AnalyticListField;

      Stream := C.AnalyticsGroup;
      Stream.Position := 0;
      Count := ReadIntegerFromStream(Stream);
      for I := 0 to Count - 1 do
      begin
        FieldName := ReadStringFromStream(Stream);
        ShowTotal := ReadBooleanFromStream(Stream);
        // Загрузим поле отображения, если было указано
        if AnalyticListField.IndexOfName(FieldName) > -1 then
          ListFieldName := AnalyticListField.Values[FieldName]
        else
          ListFieldName := '';
        // Добавим группировку
        Self.AddGroupBy(FieldName, ShowTotal, ListFieldName);
      end;
    finally
      FreeAndNil(AnalyticListField);
    end;
    // уровни аналитики
    TreeAnalyticList := TStringList.Create;
    try
      TreeAnalyticList.Text := C.TreeAnalytic;
      for I := 0 to TreeAnalyticList.Count - 1 do
        Self.AddAnalyticLevel(TreeAnalyticList.Names[I], TreeAnalyticList.Values[TreeAnalyticList.Names[I]]);
    finally
      TreeAnalyticList.Free;
    end;
  end;
end;

procedure TgdvAcctLedger.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
  I: Integer;
  TreeAnalyticList: TStringList;
  AnalyticListField: TStringList;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    C.ShowDebit := FShowDebit;
    C.ShowCredit := FShowCredit;
    C.ShowCorrSubAccounts := FShowCorrSubAccounts;
    C.SumNull := FSumNull;
    C.EnchancedSaldo := FEnchancedSaldo;
    // группировка по аналитикам
    AnalyticListField := TStringList.Create;
    try
      C.AnalyticsGroup.Size := 0;
      SaveIntegerToStream(FAcctGroupBy.Count, C.AnalyticsGroup);
      for I := 0 to FAcctGroupBy.Count - 1 do
      begin
        SaveStringToStream(FAcctGroupBy[I].FieldName, C.AnalyticsGroup);
        SaveBooleanToStream(FAcctGroupBy[I].Total, C.AnalyticsGroup);
        if Assigned(FAcctGroupBy[I].ListField) then
          AnalyticListField.Add(FAcctGroupBy[I].FieldName + '=' + FAcctGroupBy[I].ListField.FieldName);
      end;
      C.AnalyticListField := AnalyticListField.Text;
    finally
      FreeAndNil(AnalyticListField);
    end;
    // уровни аналитики
    TreeAnalyticList := TStringList.Create;
    try
      for I := 0 to FAcctAnalyticLevels.Count - 1 do
      begin
        TreeAnalyticList.Add(TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Field.FieldName + '=' +
          TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Value);
      end;
      C.TreeAnalytic := TreeAnalyticList.Text;
    finally
      TreeAnalyticList.Free;
    end;
  end;
end;

{ TgdvLedgerFieldInfo }

procedure TgdvLedgerFieldInfo.SetAccountKey(const Value: Integer);
begin
  FAccountKey := Value;
end;

procedure TgdvLedgerFieldInfo.SetAccountPart(const Value: string);
begin
  FAccountPart := Value;
end;

function TgdvAcctLedger.InternalMovementClause(TableAlias: String): string;
var
  F: TatRelationField;
  I: Integer;
  InternalMovementWhereClause: string;
  InternalMovementWhereCondition: string;
  InternalMovementJoinGdDoc: string;
  GdDocAdded: Boolean;
begin
  Result := '';

  if not FIncludeInternalMovement then
  begin
    InternalMovementWhereClause := '';
    InternalMovementWhereCondition := '';
    InternalMovementJoinGdDoc := '';
    GdDocAdded := False;
    if FUseEntryBalance then
    begin
      for I := 0 to FAcctGroupBy.Count  - 1 do
      begin
        F := FAcctGroupBy[I].Field;

        if (F <> nil) and (F.FieldName <> EntryDate) then
        begin
          {Если тип INTEGER}
          if F.SQLType in [blr_short, blr_long, blr_int64] then
          begin
            if (F.FieldName <> 'ACCOUNTKEY') then
              InternalMovementWhereClause := InternalMovementWhereClause +
                Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s + 0 ', [TableAlias, F.FieldName])
            else
              InternalMovementWhereClause := InternalMovementWhereClause +
                Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s + 0', [TableAlias, F.FieldName]);
          end
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s', [TableAlias, F.FieldName])

        end;
      end;

      for I := 0 to FAcctConditions.Count  - 1 do
      begin
        F := atDatabase.FindRelationField(AC_ENTRY, FAcctConditions.Names[I]);

        if (F <> nil) and (F.FieldName <> EntryDate) then
        begin
          {Если тип INTEGER}
          if F.SQLType in [blr_short, blr_long, blr_int64] then
          begin
            if (F.FieldName <> 'ACCOUNTKEY') then
              InternalMovementWhereClause := InternalMovementWhereClause +
                Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s + 0 ', [TableAlias, F.FieldName])
            else
              InternalMovementWhereClause := InternalMovementWhereClause +
                Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s + 0 ', [TableAlias, F.FieldName]);
          end
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s ', [TableAlias, F.FieldName])

        end;
      end;

      Result := Format(cInternalMovementClauseTemplateNew,
        [TableAlias, InternalMovementWhereClause]);
    end
    else
    begin
      for I := 0 to FAcctGroupBy.Count  - 1 do
      begin
        F := FAcctGroupBy[I].Field;

        if (F <> nil) and (F.FieldName <> EntryDate) then
        begin
          {Если тип INTEGER}
          if F.SQLType in [blr_short, blr_long, blr_int64] then
          begin
            if F.FieldName = 'DOCUMENTTYPEKEY' then
            begin
              if  not GdDocAdded then
              begin
                InternalMovementJoinGdDoc :=
                  ' LEFT JOIN GD_DOCUMENT e_m_doc ON e_m_doc.id = e_m.documentkey'#13#10 +
                  ' LEFT JOIN GD_DOCUMENT e_cm_doc ON e_cm_doc.id = e_cm.documentkey'#13#10;
                InternalMovementWhereCondition :=
                  Format(' AND'#13#10' e_m_doc.%0:s = e_cm_doc.%0:s + 0 ', [F.FieldName]);
                GdDocAdded := True;
              end;
            end
            else
              if (F.FieldName <> 'ACCOUNTKEY') then
                InternalMovementWhereClause := InternalMovementWhereClause +
                  Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s + 0 ', [F.FieldName])
              else
                InternalMovementWhereClause := InternalMovementWhereClause +
                  Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s + 0', [F.FieldName]);
          end
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s', [F.FieldName])

        end;
      end;

      for I := 0 to FAcctConditions.Count - 1 do
      begin
        if UpperCase(Trim(FAcctConditions.Names[I])) = 'DOCUMENTTYPEKEY' then
          F := atDatabase.FindRelationField('GD_DOCUMENT', FAcctConditions.Names[I])
        else
          F := atDatabase.FindRelationField(AC_ENTRY, FAcctConditions.Names[I]);

        if (F <> nil) and (F.FieldName <> EntryDate) then
        begin
          {Если тип INTEGER}
          if F.SQLType in [blr_short, blr_long, blr_int64] then
          begin
            if F.FieldName = 'DOCUMENTTYPEKEY' then
            begin
              if  not GdDocAdded then
              begin
                InternalMovementJoinGdDoc :=
                  ' LEFT JOIN GD_DOCUMENT e_m_doc ON e_m_doc.id = e_m.documentkey'#13#10 +
                  ' LEFT JOIN GD_DOCUMENT e_cm_doc ON e_cm_doc.id = e_cm.documentkey'#13#10;
                InternalMovementWhereCondition :=
                  Format(' AND'#13#10' e_m_doc.%0:s = e_cm_doc.%0:s + 0 ', [F.FieldName]);
                GdDocAdded := True;
              end;
            end
            else
              if (F.FieldName <> 'ACCOUNTKEY') then
                InternalMovementWhereClause := InternalMovementWhereClause +
                  Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s + 0 ', [F.FieldName])
              else
                InternalMovementWhereClause := InternalMovementWhereClause +
                  Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s + 0 ', [F.FieldName]);
          end
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s ', [F.FieldName])

        end;
      end;

      Result := Format(cInternalMovementClauseTemplate,
        [InternalMovementWhereClause, InternalMovementJoinGdDoc, InternalMovementWhereCondition]);
    end;
  end;
end;

function TgdvAcctLedger.AccountInClause(Alias: string): string;
begin
  if FAccounts.Count > 0 then
    Result := Format('%s.accountkey IN(%s) AND ', [Alias, IDList(FAccounts)])
  else
    Result := '';
end;

procedure TgdvAcctLedger.CorrAccounts(const Strings: TgdvCorrFieldInfoList;
  AccountPart: string);
var
  SQL: TIBSQL;
  AccountIn: string;
  APart: string;
  AnalyticsCond: string;
  AnalyticsFrom: String;
begin
  if Assigned(Strings) then
  begin
    Strings.Clear;
    if (AccountPart = '') and (FCorrFieldInfoList.Count > 0) then
    begin
      Strings.Assign(FCorrFieldInfoList);
      Exit;
    end;

    if (AccountPart = cAccountPartDebit) and (FDebitCorrFieldInfoList.Count > 0) then
    begin
      Strings.Assign(FDebitCorrFieldInfoList);
      Exit;
    end;

    if (AccountPart = cAccountPartCredit) and (FCreditCorrFieldInfoList.Count > 0) then
    begin
      Strings.Assign(FCreditCorrFieldInfoList);
      Exit;
    end;

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      if Assigned(FAccounts) and (FAccounts.Count  > 0) then
      begin
        AccountIn := '  e.accountkey IN (' + IDList(FAccounts) + ') AND '
      end else
        AccountIn := '';

      if AccountPart > '' then
        APart := ' e.accountpart = :accountpart AND '
      else
        APart := '';

      AnalyticsCond := Self.GetCondition('e');
      if AnalyticsCond > '' then AnalyticsCond := ' AND ' + AnalyticsCond;

      AnalyticsFrom := Self.GetJoinTableClause('e');

      // Расчет с использованием AC_ENTRY_BALANCE будет работать только на FB 2.0+
      if UseEntryBalance then
      begin
        if FShowCorrSubAccounts then
        begin
          SQL.SQL.Text :=
            'SELECT ' +
            '  entry.accountkey AS account, ' +
            '  acc.id AS displayaccount, ' +
            '  acc.alias ' +
            'FROM ' +
            '  (SELECT ' +
            '     corr_e.accountkey ' +
            '   FROM ' +
            '     (SELECT ' +
            '        e.recordkey, ' +
            '        e.accountpart ' +
            '      FROM ' +
            '        ac_entry e ' +
            '      WHERE ' + AccountIn + APart +
            '        e.entrydate >= :datebegin AND e.entrydate <= :dateend AND ' +
            '        e.companykey IN (' + FCompanyList + ') ' +
              InternalMovementClause + AnalyticsCond +
            '     ) e1 ' +
            '     LEFT JOIN ac_entry corr_e ON corr_e.recordkey = e1.recordkey AND corr_e.accountpart <> e1.accountpart ' +
            '   GROUP BY ' +
            '     corr_e.accountkey ' +
            '  ) entry ' +
            '  JOIN ac_account acc ON acc.id = entry.accountkey ' +
            'ORDER BY acc.alias ';
        end
        else
        begin
          SQL.SQL.Text :=
            'SELECT ' +
            '  entry.accountkey AS account, ' +
            '  acc_main.id AS displayaccount, ' +
            '  acc_main.alias ' +
            'FROM ' +
            '  (SELECT ' +
            '     corr_e.accountkey ' +
            '   FROM ' +
            '     (SELECT ' +
            '        e.recordkey, ' +
            '        e.accountpart ' +
            '      FROM ' +
            '        ac_entry e ' +
            '      WHERE ' + AccountIn + APart +
            '        e.entrydate >= :datebegin AND e.entrydate <= :dateend AND ' +
            '        e.companykey IN (' + FCompanyList + ') ' +
              InternalMovementClause + AnalyticsCond +
            '     ) e1 ' +
            '     LEFT JOIN ac_entry corr_e ON corr_e.recordkey = e1.recordkey AND corr_e.accountpart <> e1.accountpart ' +
            '   GROUP BY ' +
            '     corr_e.accountkey ' +
            '  ) entry ' +
            '  JOIN ac_account acc ON acc.id = entry.accountkey ' +
            '  JOIN ac_account acc_main ON acc_main.accounttype = ''A'' AND acc_main.lb <= acc.lb AND acc_main.rb >= acc.rb ' +
            'ORDER BY acc_main.alias ';
        end;
      end
      else
      begin
        if FShowCorrSubAccounts then
        begin
          SQL.SQL.Text :=
            'select distinct' +
            '  e1.accountkey AS Account, ' +
            '  a.id AS DisplayAccount, ' +
            '  a.alias ' +
            'from ' +
            '  ac_entry e ' +
            '  LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey and ' +
            '    e1.accountpart <> e.accountpart ' +
            '  left join ac_account a on e1.accountkey = a.id ' +
            AnalyticsFrom +
            'where ' + AccountIn + APart +
            '  e.entrydate >= :datebegin and e.entrydate <= :dateend AND ' +
            '  e.companykey in (' + FCompanyList + ') ' +
            InternalMovementClause + AnalyticsCond + ' ORDER BY a.alias';
        end
        else
        begin
          SQL.SQL.Text :=
            'select distinct' +
            '  e1.accountkey AS account, ' +
            '  a1.id AS DisplayAccount, ' +
            '  a1.alias ' +
            'from ' +
            '  ac_entry e ' +
            '  LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey and ' +
            '    e1.accountpart <> e.accountpart ' +
            '  join ac_account a on e1.accountkey = a.id ' +
            '  join ac_account a1 on a1.accounttype = ''A'' and a1.lb <= a.lb and ' +
            '    a1.rb >= a.rb ' +
            AnalyticsFrom +
            'where ' + AccountIn + APart +
            '  e.entrydate >= :datebegin and e.entrydate <= :dateend and '+
            '  e.companykey in (' + FCompanyList + ') ' +
            InternalMovementClause + AnalyticsCond + ' ORDER BY a1.alias';
        end;
      end;

      if AccountPart > '' then
        SQL.ParamByName('accountpart').AsString := AccountPart;
      SQL.ParamByName('datebegin').AsDateTime := FDateBegin;
      SQL.ParamByName('dateend').AsDateTime := FDateEnd;
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        Strings.AddFieldInfo(SQL.FieldByName('alias').AsString,
          SQL.FieldByName('account').AsInteger,
          SQL.FieldByName('displayaccount').AsInteger);
        SQL.Next;
      end;
    finally
      SQL.Free;
    end;

    if (AccountPart = '') then
      FCorrFieldInfoList.Assign(Strings)
    else
      if (AccountPart = cAccountPartDebit) then
        FDebitCorrFieldInfoList.Assign(Strings)
      else
        if (AccountPart = cAccountPartCredit) then
          FCreditCorrFieldInfoList.Assign(Strings);
  end;
end;

procedure TgdvAcctLedger.CreditCorrAccounts(const Strings: TgdvCorrFieldInfoList);
begin
  CorrAccounts(Strings, cAccountPartCredit);
end;

procedure TgdvAcctLedger.DebitCorrAccounts(const Strings: TgdvCorrFieldInfoList);
begin
  CorrAccounts(Strings, cAccountPartDebit);
end;

function TgdvAcctLedger.IndexOfAnalyticLevel(AFieldName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FAcctAnalyticLevels.Count - 1 do
  begin
    if AnsiCompareText(TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).Field.FieldName, AFieldName) = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TgdvAcctLedger.GetCreditSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  CAST(IIF(SUM ( %s.credit ) <> 0, SUM ( %s.credit ) / %d, 0) AS %s) ';
begin
  Result := '';
  if FCreditSumSelectClause > '' then
    Result := FCreditSumSelectClause
  else
  begin
    if FShowCredit and FNCUSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FNCUSumInfo.DecDigits]);
      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias, Alias, FNCUSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionCredit, [Strings.Items[I].Caption]),
                  DisplayFormat(FNCUSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartDebit);
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FNCUSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCredit, [Strings.Items[I].Caption]),
                    DisplayFormat(FNCUSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartDebit);
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';
                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias,Alias, FNCUSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' AS ' +
                 Accounts.Names[I] + ', '#13#10;
              FNcuCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FNcuTotalBlock) then
  begin
    for I := 0 to FNcuCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FNcuCreditAliases[I];
      FNcuTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FCreditSumSelectClause > '' then
    Result := FCreditSumSelectClause
  else
  begin
    if FShowCredit and FNCUSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FNCUSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionCredit, [Strings.Items[I].Caption]),
                  DisplayFormat(FNCUSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartDebit);
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCredit, [Strings.Items[I].Caption]),
                    DisplayFormat(FNCUSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartDebit);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FNcuCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FNcuTotalBlock) then
  begin
    for I := 0 to FNcuCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FNcuCreditAliases[I];
      FNcuTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditCurrSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  IIF(SUM ( %s.creditcurr ) <> 0, SUM ( %s.creditcurr ) / %d, 0) ';
begin
  Result := '';
  if FCreditCurrSumSelectClause > '' then
    Result := FCreditCurrSumSelectClause
  else
  begin
    if FShowCredit and FCurrSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias,Alias, FCurrSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionCreditCurr, [Strings.Items[I].Caption]),
                  DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartDebit, Format(cNcuCreditFieldNameTemplate,
                  [GetKeyAlias(Strings.Items[I].Account)]));
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FCurrSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCreditCurr, [Strings.Items[I].Caption]),
                    DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartDebit, Format(cNcuCreditFieldNameTemplate,
                    [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';

                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias,Alias, FCurrSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' as ' +
                 Accounts.Names[I] + ', '#13#10;
              FCurrCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditCurrSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FCurrTotalBlock) then
  begin
    for I := 0 to FCurrCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FCurrCreditAliases[I];
      FCurrTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditCurrSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FCreditCurrSumSelectClause > '' then
    Result := FCreditCurrSumSelectClause
  else
  begin
    if FShowCredit and FCurrSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionCreditCurr, [Strings.Items[I].Caption]),
                  DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartDebit,
                  Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCreditCurr, [Strings.Items[I].Caption]),
                    DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartDebit,
                    Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FCurrCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditCurrSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FCurrTotalBlock) then
  begin
    for I := 0 to FCurrCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FCurrCreditAliases[I];
      FCurrTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditEQSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  IIF(SUM ( %s.crediteq ) <> 0, SUM ( %s.crediteq ) / %d, 0) ';
begin
  Result := '';
  if FCreditEQSumSelectClause > '' then
    Result := FCreditEQSumSelectClause
  else
  begin
    if FShowCredit and FEQSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cEqCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cEqCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionCreditEQ, [Strings.Items[I].Caption]),
                  DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartDebit,
                  Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCreditEQ, [Strings.Items[I].Caption]),
                    DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartDebit,
                    Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';

                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' as ' +
                 Accounts.Names[I] + ', '#13#10;
              FEQCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditEQSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FEQTotalBlock) then
  begin
    for I := 0 to FEQCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FEQCreditAliases[I];
      FEQTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditEQSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FCreditEQSumSelectClause > '' then
    Result := FCreditEQSumSelectClause
  else
  begin
    if FShowCredit and FEQSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cEqCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cEqCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionCreditEQ, [Strings.Items[I].Caption]),
                  DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartDebit,
                  Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionCreditEQ, [Strings.Items[I].Caption]),
                    DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FEQSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartDebit,
                    Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FEQCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditEQSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FEQTotalBlock) then
  begin
    for I := 0 to FEQCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FEQCreditAliases[I];
      FEQTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetCreditQuantitySelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I, K: Integer;
  QuantityAlias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  FI: TgdvFieldInfo;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  SUM(%s.creditquantity)';
  cQuantity = 'K - Д%s, %s';
begin
  Result := '';
  if FCreditQuantitySelectClause > '' then
    Result := FCreditQuantitySelectClause
  else
  begin
    if FShowCredit and (FAcctValues.Count > 0) then
    begin
      Strings := TgdvCorrFieldInfoList.Create;
      try
        CreditCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              for K := 0 to FAcctValues.Count - 1 do
              begin
                FieldName := Format('Q_C_%s_%s', [GetKeyAlias(Id), GetKeyAlias(FAcctValues.Names[K])]);
                DisplayFieldName := Format('Q_C_%s_%s',
                  [GetKeyAlias(Strings.Items[I].DisplayAccount), GetKeyAlias(FAcctValues.Names[K])]);

                QuantityAlias := Format('q_%s_%s_C', [GetKeyAlias(Id), GetKeyAlias(FAcctValues.Names[K])]);
                if FShowCorrSubAccounts then
                begin
                  Accounts.Add(FieldName + '=' + Format(cTemplate,
                    [QuantityAlias]));
                  if Assigned(FFieldInfos) then
                  begin
                    FI := FFieldInfos.AddInfo;
                    FI.Visible := fvHidden;
                    FI.FieldName := FieldName;
                    FI.Caption := Format(cQuantity, [Strings.Items[I].Caption, FAcctValues.Values[FAcctValues.Names[K]]]);
                    FI.DisplayFormat := '';
                    FI.DisplayFields.Add(Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
                    FI.DisplayFields.Add(Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
                    FI.Total := True;
                  end;  
                end else
                begin
                  Index := Accounts.IndexOfName(DisplayFieldName);
                  if Index = -1 then
                  begin
                    Accounts.Add(DisplayFieldName + '=' + Format(cTemplate,
                      [QuantityAlias]));
                    if Assigned(FFieldInfos) then
                    begin
                      FI := FFieldInfos.AddInfo;
                      FI.Visible := fvHidden;
                      FI.FieldName := DisplayFieldName;
                      FI.Caption := Format(cQuantity, [Strings.Items[I].Caption, FAcctValues.Values[FAcctValues.Names[K]]]);
                      FI.DisplayFormat := '';
                      FI.DisplayFields.Add(Format(cNcuCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                      FI.DisplayFields.Add(Format(cCurrCreditFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                      FI.Total := True;
                    end;  
                  end else
                  begin
                    if Accounts.Values[DisplayFieldName] > '' then
                      Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                      Format(cTemplate, [QuantityAlias]);
                  end;
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result +
                ', '#13#10 + 'CAST(' + Accounts.Values[Accounts.Names[I]] +
                Format(' / %0:d AS NUMERIC(15, %1:d)) AS ', [FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]) +
                 Accounts.Names[I];
              FQuantCreditAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FCreditQuantitySelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FQuantityTotalBlock) then
  begin
    for I := 0 to FQuantCreditAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FQuantCreditAliases[I];
      FQuantityTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  CAST(IIF(SUM ( %s.debit ) <> 0, SUM ( %s.debit ) / %d, 0) AS %s) ';
begin
  Result := '';
  if FDebitSumSelectClause > '' then
    Result := FDebitSumSelectClause
  else
  begin
    if FShowDebit and FNcuSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FNcuSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias, Alias, FNcuSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebit, [Strings.Items[I].Caption]),
                  DisplayFormat(FNcuSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartCredit);
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FNcuSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebit, [Strings.Items[I].Caption]),
                    DisplayFormat(FNcuSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartCredit);
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';
                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias, Alias, FNcuSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' AS ' +
                 Accounts.Names[I] + ', '#13#10;
              FNcuDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FNcuTotalBlock) then
  begin
    for I := 0 to FNcuDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FNcuDebitAliases[I];
      FNcuTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FDebitSumSelectClause > '' then
    Result := FDebitSumSelectClause
  else
  begin
    if FShowDebit and FNcuSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FNcuSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebit, [Strings.Items[I].Caption]),
                  DisplayFormat(FNcuSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartCredit);
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebit, [Strings.Items[I].Caption]),
                    DisplayFormat(FNcuSumInfo.DecDigits), True, True, Strings.Items[I].Account, cAccountPartCredit);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FNcuDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FNcuTotalBlock) then
  begin
    for I := 0 to FNcuDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FNcuDebitAliases[I];
      FNcuTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitCurrSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: string;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  IIF(SUM ( %s.debitcurr ) <> 0, SUM ( %s.debitcurr ) / %d, 0) ';
begin
  Result := '';
  if FDebitCurrSumSelectClause > '' then
    Result := FDebitCurrSumSelectClause
  else
  begin
    if FShowDebit and FCurrSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias, Alias, FCurrSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebitCurr, [Strings.Items[I].Caption]),
                  DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartCredit,
                  Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FCurrSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebitCurr, [Strings.Items[I].Caption]),
                    DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartCredit,
                    Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';

                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias, Alias, FCurrSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' as ' +
                 Accounts.Names[I] + ', '#13#10;
              FCurrDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitCurrSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FCurrTotalBlock) then
  begin
    for I := 0 to FCurrDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FCurrDebitAliases[I];
      FCurrTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitCurrSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FDebitCurrSumSelectClause > '' then
    Result := FDebitCurrSumSelectClause
  else
  begin
    if FShowDebit and FCurrSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebitCurr, [Strings.Items[I].Caption]),
                  DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartCredit,
                  Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebitCurr, [Strings.Items[I].Caption]),
                    DisplayFormat(FCurrSumInfo.DecDigits), (FCurrSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartCredit,
                    Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FCurrDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitCurrSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FCurrTotalBlock) then
  begin
    for I := 0 to FCurrDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FCurrDebitAliases[I];
      FCurrTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitEQSumSelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: string;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  IIF(SUM ( %s.debiteq ) <> 0, SUM ( %s.debiteq ) / %d, 0) ';
begin
  Result := '';
  if FDebitEQSumSelectClause > '' then
    Result := FDebitEQSumSelectClause
  else
  begin
    if FShowDebit and FEQSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              FieldName := Format(cEqDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cEqDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]));
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebitEQ, [Strings.Items[I].Caption]),
                  DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartCredit,
                  Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]));
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebitEQ, [Strings.Items[I].Caption]),
                    DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartCredit,
                    Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end else
                begin
                  if Accounts.Values[DisplayFieldName] > '' then
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';

                  Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                    Format(cTemplate, [Alias, Alias, FEQSumInfo.Scale, Dig]);
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Values[Accounts.Names[I]] + ' as ' +
                 Accounts.Names[I] + ', '#13#10;
              FEQDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitEQSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FEQTotalBlock) then
  begin
    for I := 0 to FEQDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FEQDebitAliases[I];
      FEQTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitEQSumSelectClauseBalance: String;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  FieldName, DisplayFieldName: string;
  Accounts: TStrings;
  Index: Integer;
  Dig: String;
  T: TgdvLedgerTotalUnit;
begin
  Result := '';
  if FDebitEQSumSelectClause > '' then
    Result := FDebitEQSumSelectClause
  else
  begin
    if FShowDebit and FEQSumInfo.Show then
    begin
      Dig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              FieldName := Format(cEqDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]);
              DisplayFieldName := Format(cEqDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]);
              if FShowCorrSubAccounts then
              begin
                Accounts.Add(FieldName + '=' + Dig);
                AddLedgerFieldInfo(FieldName, Format(cCaptionDebitEQ, [Strings.Items[I].Caption]),
                  DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                  True, Strings.Items[I].Account, cAccountPartCredit,
                  Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
              end
              else
              begin
                Index := Accounts.IndexOfName(DisplayFieldName);
                if Index = -1 then
                begin
                  Accounts.Add(DisplayFieldName + '=' + Dig);
                  AddLedgerFieldInfo(DisplayFieldName, Format(cCaptionDebitEQ, [Strings.Items[I].Caption]),
                    DisplayFormat(FEQSumInfo.DecDigits), (FEQSumInfo.Show) and (not FNcuSumInfo.Show),
                    True, Strings.Items[I].Account, cAccountPartCredit,
                    Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result + Accounts.Names[I] + ' ' + Accounts.Values[Accounts.Names[I]] + ', '#13#10;
              FEQDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitEQSumSelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FEQTotalBlock) then
  begin
    for I := 0 to FEQDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FEQDebitAliases[I];
      FEQTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetDebitQuantitySelectClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I, K: Integer;
  QuantityAlias, FieldName, DisplayFieldName: string;
  Id: string;
  Accounts: TStrings;
  Index: Integer;
  FI: TgdvFieldInfo;
  T: TgdvLedgerTotalUnit;
const
  cTemplate = '  SUM(%s.debitquantity)';
  cQuantity = 'Д - К%s, %s';
begin
  Result := '';
  if FDebitQuantitySelectClause > '' then
    Result := FDebitQuantitySelectClause
  else
  begin
    if FShowDebit and (FAcctValues.Count > 0) then
    begin
      Strings := TgdvCorrFieldInfoList.Create;
      try
        DebitCorrAccounts(Strings);
        if Strings.Count > 0 then
        begin
          Accounts := TStringList.Create;
          try
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              for K := 0 to FAcctValues.Count - 1 do
              begin
                FieldName := Format('Q_D_%s_%s', [GetKeyAlias(ID), GetKeyAlias(FAcctValues.Names[K])]);
                DisplayFieldName := Format('Q_D_%s_%s',
                  [GetKeyAlias(Strings.Items[I].DisplayAccount), GetKeyAlias(FAcctValues.Names[K])]);

                QuantityAlias := Format('q_%s_%s_D', [GetKeyAlias(ID), GetKeyAlias(FAcctValues.Names[K])]);
                if FShowCorrSubAccounts then
                begin
                  Accounts.Add(FieldName + '=' + Format(cTemplate,
                    [QuantityAlias]));
                  if Assigned(FFieldInfos) then
                  begin
                    FI := FFieldInfos.AddInfo;
                    FI.Visible := fvHidden;
                    FI.FieldName := FieldName;
                    FI.Caption := Format(cQuantity, [Strings.Items[I].Caption, FAcctValues.Values[FAcctValues.Names[K]]]);
                    FI.DisplayFormat := '';
                    FI.DisplayFields.Add(Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
                    FI.DisplayFields.Add(Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].Account)]));
                    FI.Total := True;
                  end;  
                end else
                begin
                  Index := Accounts.IndexOfName(DisplayFieldName);
                  if Index = -1 then
                  begin
                    Accounts.Add(DisplayFieldName + '=' + Format(cTemplate,
                      [QuantityAlias]));
                    if Assigned(FFieldInfos) then
                    begin
                      FI := FFieldInfos.AddInfo;
                      FI.Visible := fvHidden;
                      FI.FieldName := DisplayFieldName;
                      FI.Caption := Format(cQuantity, [Strings.Items[I].Caption, FAcctValues.Values[FAcctValues.Names[K]]]);
                      FI.DisplayFormat := '';
                      FI.DisplayFields.Add(Format(cNcuDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                      FI.DisplayFields.Add(Format(cCurrDebitFieldNameTemplate, [GetKeyAlias(Strings.Items[I].DisplayAccount)]));
                      FI.Total := True;
                    end;
                  end else
                  begin
                    if Accounts.Values[DisplayFieldName] > '' then
                      Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] + ' + '#13#10'  ';
                    Accounts.Values[DisplayFieldName] := Accounts.Values[DisplayFieldName] +
                      Format(cTemplate, [QuantityAlias]);
                  end;
                end;
              end;
            end;

            for I := 0 to Accounts.Count - 1 do
            begin
              Result := Result +
                ', '#13#10 + 'CAST(' + Accounts.Values[Accounts.Names[I]] +
                Format(' / %0:d AS NUMERIC(15, %1:d)) AS ', [FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]) +
                 Accounts.Names[I];
              FQuantDebitAliases.Add(Accounts.Names[I]);
            end;
          finally
            Accounts.Free;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FDebitQuantitySelectClause := Result;
  end;

  if Assigned(FTotals) and Assigned(FQuantityTotalBlock) then
  begin
    for I := 0 to FQuantDebitAliases.Count - 1 do
    begin
      T := TgdvLedgerTotalUnit.Create;
      T.FieldName := FQuantDebitAliases[I];
      FQuantityTotalBlock.Add(T);
    end;
  end;
end;

function TgdvAcctLedger.GetHavingClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  Alias: string;
  S: TStrings;

  procedure Acc(Part: string);
  var
    I: Integer;
  begin
    Strings.Clear;
    CorrAccounts(Strings, Part);
    for I := 0 to Strings.Count - 1 do
    begin
      if Result > '' then Result := Result + #13#10;
      Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
      if FNcuSumInfo.Show then
      begin
        if FShowDebit then
        begin
          if Result > '' then Result := Result + ' OR ';
          Result := Result + Format('SUM(%s.debit) <> 0 ', [Alias]);
        end;
        if FShowCredit then
        begin
          if Result > '' then Result := Result + ' OR ';
          Result := Result + Format('SUM(%s.credit) <> 0 ', [Alias]);
        end;
      end;
      if FCurrSumInfo.Show then
      begin
        if FShowDebit then
        begin
          if Result > '' then Result := Result + ' OR ';
          Result := Result + Format('SUM(%s.debitcurr) <> 0 ', [Alias]);
        end;
        if FShowCredit then
        begin
          if Result > '' then Result := Result + ' OR ';
          Result := Result + Format('SUM(%s.creditcurr) <> 0 ', [Alias]);
        end;
      end;
    end;
  end;

begin
  Result := '';
  if not FEntryDateIsFirst then
  begin
    if FHavingClause > '' then
      Result := FHavingClause
    else
    begin
      if FShowDebit or FShowCredit then
      begin
        Strings := TgdvCorrFieldInfoList.Create;
        try
          S := TStringList.Create;
          try
            if FShowDebit then
              Acc(cAccountPartDebit);

            if FShowCredit then
              Acc(cAccountPartCredit);
          finally
            S.Free;
          end;
        finally
          Strings.Free;
        end;
      end;
      FHavingClause := Result;
    end;
  end;
end;

function TgdvAcctLedger.GetQuantityJoinClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I, J, K: Integer;
  QuantityAlias: string;
  Id: string;
const
  cJoinTemplate = '  LEFT JOIN ac_l_q(e2.id, %s, %d, ''%s'') %s ON e.id = e.id '#13#10;
  cPartsCount = 2;
  cAccountParts: array [0..1] of char = (cAccountPartCredit, cAccountPartDebit);
  cCorrAccountParts: array [0..1] of char = (cAccountPartDebit, cAccountPartCredit);
begin
  Result := '';
  if FQuantityJoinClause > '' then
    Result := FQuantityJoinClause
  else
  begin
    if FShowDebit or FShowCredit and (FAcctValues.Count > 0) then
    begin
      Strings := TgdvCorrFieldInfoList.Create;
      try
        for J := 0 to cPartsCount - 1 do
        begin
          CorrAccounts(Strings, cAccountParts[J]);
          for I := 0 to Strings.Count - 1 do
          begin
            Id := IntToStr(Strings.Items[I].Account);
            for K := 0 to FAcctValues.Count - 1 do
            begin
              QuantityAlias := Format('q_%s_%s_%s', [GetKeyAlias(ID),
                GetKeyAlias(FAcctValues.Names[K]), cAccountParts[J]]);
              Result := Result + Format(cJoinTemplate, [FAcctValues.Names[K],
                Strings.Items[I].Account, cCorrAccountParts[J], QuantityAlias])
            end;
          end;
        end;
      finally
        Strings.Free;
      end;
    end;
    FQuantityJoinClause := Result;
  end;
end;

function TgdvAcctLedger.GetSumJoinClause: string;
var
  Strings: TgdvCorrFieldInfoList;
  I: Integer;
  Alias: string;
  Id: string;
  S: TStringList;
const
  cJoinTemplate = '  LEFT JOIN AC_GETSIMPLEENTRY(e2.id, %s) %s on  %s.id = e2.id '#13#10;
begin
  Result := '';
  if FSumJoinClause > '' then
    Result := FSumJoinClause
  else
  begin
    if FShowDebit or FShowCredit then
    begin
      Strings := TgdvCorrFieldInfoList.Create;
      try
        S := TStringList.Create;
        try
          if FShowDebit then
          begin
            CorrAccounts(Strings, cAccountPartDebit);
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              if S.IndexOf(Id) = - 1 then
              begin
                Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
                Result := Result + Format(cJoinTemplate, [ID, Alias, Alias]);
                S.Add(ID);
              end;
            end;
          end;

          if FShowCredit then
          begin
            CorrAccounts(Strings, cAccountPartCredit);
            for I := 0 to Strings.Count - 1 do
            begin
              Id := IntToStr(Strings.Items[I].Account);
              if S.IndexOf(Id) = - 1 then
              begin
                Alias := Format('e_%s', [GetKeyAlias(Strings.Items[I].Account)]);
                Result := Result + Format(cJoinTemplate, [ID, Alias, Alias]);
                S.Add(ID);
              end;
            end;
          end;
        finally
          S.Free;
        end;
      finally
        Strings.Free;
      end;
    end;
    FSumJoinClause := Result;
  end;
end;

procedure TgdvAcctLedger.CheckAnalyticLevelProcedures;
var
  I: Integer;
begin
  if Assigned(FAcctAnalyticLevels) then
    for I := 0 to FAcctAnalyticLevels.Count - 1 do
      TgdvAcctAnalyticLevels(FAcctAnalyticLevels[I]).CheckProcedure;
end;

procedure TgdvAcctLedger.DoAfterBuildReport;
var
  ibsql: TIBSQL;
  Tr: TIBTransaction;
begin
  inherited;

  if FSQLHandle > 0 then
  begin
    //Удаляем информацию из вспомогательных таблиц
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := Tr;
        ibsql.SQL.Text := 'DELETE FROM AC_LEDGER_ACCOUNTS WHERE SQLHANDLE = :SQLHANDLE';
        ibsql.ParamByName(fnSQLHandle).AsInteger := FSQLHandle;
        ibsql.ExecQuery;

        ibsql.Close;
        ibsql.SQL.Text := 'DELETE FROM AC_LEDGER_ENTRIES WHERE SQLHANDLE = :SQLHANDLE';
        ibsql.ParamByName(fnSQLHandle).AsInteger := FSQLHandle;
        ibsql.ExecQuery;
      finally
        ibsql.Free;
      end;
      Tr.Commit;
    finally
      if Tr.InTransaction then
        Tr.RollBack;
      Tr.Free;
    end;
  end;
end;

procedure TgdvAcctLedger.UpdateEntryDateIsFirst;
var
  I: Integer;
begin
  FEntryDateIsFirst := False;
  FEntryDateInFields := False;
  for I := 0 to FAcctGroupBy.Count - 1 do
  begin
    FEntryDateInFields := (FAcctGroupBy[I].FieldName = ENTRYDATE) or
      (not Assigned(FAcctGroupBy[I].Field));
    if FEntryDateInFields then
    begin
      FEntryDateIsFirst := I = 0;
      Break;
    end;
  end;
end;

{ TgdvCorrFieldInfo }

function TgdvCorrFieldInfo.GetAlias: string;
begin
  Result := ''
end;

procedure TgdvCorrFieldInfo.SetAccount(const Value: Integer);
begin
  FAccount := Value;
end;

procedure TgdvCorrFieldInfo.SetAccountPart(const Value: string);
begin
  FAccountPart := Value;
end;

procedure TgdvCorrFieldInfo.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TgdvCorrFieldInfo.SetDisplayAccount(const Value: Integer);
begin
  FDisplayAccount := Value;
end;

{ TgdvCorrFieldInfoList }


function TgdvCorrFieldInfoList.AddFieldInfo(Caption: string; Account,
  DisplayAccount: Integer): Integer;
var
  FI: TgdvCorrFieldInfo;
begin
  FI := TgdvCorrFieldInfo.Create;
  FI.Caption := Caption;
  FI.DisplayAccount := DisplayAccount;
  FI.Account := Account;
  Result := Add(FI);
end;

procedure TgdvCorrFieldInfoList.Assign(Source: TgdvCorrFieldInfoList);
var
  I: Integer;
begin
  if Source <> nil then
  begin
    Clear;
    for I := 0 to Source.Count - 1 do
    begin
      AddFieldInfo(Source.Items[I].FCaption, Source.Items[I].FAccount,
        Source.Items[I].FDisplayAccount);
    end;
  end;
end;

function TgdvCorrFieldInfoList.GetItems(Index: Integer): TgdvCorrFieldInfo;
begin
  Result := TgdvCorrFieldInfo(inherited Items[Index]);
end;

{ TgdvLedgerTotal }

procedure TgdvLedgerTotal.Calc;
begin
  TotalBlocks.Calc;
end;

destructor TgdvLedgerTotal.Destroy;
begin
  FTotalBlocks.Free;

  inherited;
end;

procedure TgdvLedgerTotal.DropValues;
begin
  TotalBlocks.DropValues;
end;

function TgdvLedgerTotal.GetTotalBlocks: TgdvLedgerTotalBlocks;
begin
  if FTotalBlocks = nil then
    FTotalBlocks := TgdvLedgerTotalBlocks.Create;
  Result := FTotalBlocks;
end;

procedure TgdvLedgerTotal.InitField(DataSet: TDataSet);
begin
  FField := DataSet.FindField(FFieldName);
  Assert(FField <> nil, '');
  FValueField := DataSet.FindField(FValueFieldName);
  Assert(FValueField <> nil, '');
  TotalBlocks.InitFields(DataSet);
end;


procedure TgdvLedgerTotal.SetatRelationField(
  const Value: TatRelationField);
begin
  FatRelationField := Value;
end;

procedure TgdvLedgerTotal.SetField(const Value: TField);
begin
  FField := Value;
end;

procedure TgdvLedgerTotal.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TgdvLedgerTotal.SetTotal(const Value: boolean);
begin
  FTotal := Value;
end;

procedure TgdvLedgerTotal.SetValueField(const Value: TField);
begin
  FValueField := Value;
end;

procedure TgdvLedgerTotal.SetValueFieldName(const Value: string);
begin
  FValueFieldName := Value;
end;

procedure TgdvLedgerTotal.SetValues;
begin
  TotalBlocks.SetValues
end;

{ TgdvLedgerTotals }

procedure TgdvLedgerTotals.Calc;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Totals[I].Calc;
  end;
end;

destructor TgdvLedgerTotals.Destroy;
begin
  inherited;
end;

procedure TgdvLedgerTotals.DropValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Totals[I].DropValues;
  end;
end;

function TgdvLedgerTotals.GetTotals(Index: Integer): TgdvLedgerTotal;
begin
  Result := TgdvLedgerTotal(Items[Index]);
end;

procedure TgdvLedgerTotals.InitField(DataSet: TDataSet);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Totals[I].InitField(DataSet);
  end;
end;

procedure TgdvLedgerTotals.SetValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Totals[I].SetValues;
  end;
end;

{ TgdvLedgerTotalUnit }

function TgdvLedgerTotalUnit.GetField: TField;
begin
  Result := FField;
  Assert(FField <> nil, '');
end;

procedure TgdvLedgerTotalUnit.InitField(DataSet: TDataSet);
begin
  FField := DataSet.FindField(FFieldName);
  Assert(FField <> nil, '');
end;

procedure TgdvLedgerTotalUnit.SetField(const Value: TField);
begin
  FField := Value;
end;

procedure TgdvLedgerTotalUnit.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TgdvLedgerTotalUnit.SetValue(const Value: Currency);
begin
  FValue := Value;
end;

{ TgdvLedgerTotalBlock }

procedure TgdvCustomLedgerTotalBlock.Calc;
var
  I: Integer;
begin
  DoCalc;

  for I := 0 to Count - 1 do
    Fields[i].Value := Fields[i].Value + Fields[i].Field.AsCurrency;
end;

procedure TgdvCustomLedgerTotalBlock.Clear;
begin
  inherited;

end;

constructor TgdvCustomLedgerTotalBlock.Create;
begin
  inherited;
  BeginDebit := TgdvLedgerTotalUnit.Create;
  BeginCredit := TgdvLedgerTotalUnit.Create;
  Debit := TgdvLedgerTotalUnit.Create;
  Credit := TgdvLedgerTotalUnit.Create;
  EndDebit := TgdvLedgerTotalUnit.Create;
  EndCredit := TgdvLedgerTotalUnit.Create;
end;

destructor TgdvCustomLedgerTotalBlock.Destroy;
begin
  BeginDebit.Free;
  BeginCredit.Free;
  Debit.Free;
  Credit.Free;
  EndDebit.Free;
  EndCredit.Free;

  inherited;
end;

procedure TgdvCustomLedgerTotalBlock.Drop;
var
  I: Integer;
begin
  DropValues;
  BeginDebit.Field := nil;
  BeginCredit.Field := nil;
  Debit.Field := nil;
  Credit.Field := nil;
  EndDebit.Field := nil;
  EndCredit.Field := nil;

  for I := 0 to Count - 1 do
  begin
    Fields[i].Field := nil;
  end;
end;

procedure TgdvCustomLedgerTotalBlock.DropValues;
var
  I: Integer;
begin
  BeginDebit.Value := 0;
  BeginCredit.Value := 0;
  Debit.Value := 0;
  Credit.Value := 0;
  EndDebit.Value := 0;
  EndCredit.Value := 0;

  for I := 0 to Count - 1 do
  begin
    Fields[I].Value := 0;
  end;
end;

function TgdvCustomLedgerTotalBlock.GetFields(
  Index: Integer): TgdvLedgerTotalUnit;
begin
  Result := TgdvLedgerTotalUnit(Items[Index])
end;

procedure TgdvCustomLedgerTotalBlock.InitFields(DataSet: TDataSet);
var
  I: Integer;
begin
  BeginDebit.InitField(DataSet);
  BeginCredit.InitField(DataSet);
  Debit.InitField(DataSet);
  Credit.InitField(DataSet);
  EndDebit.InitField(DataSet);
  EndCredit.InitField(DataSet);

  for i := 0 to Count - 1 do
  begin
    Fields[I].InitField(DataSet)
  end;
end;

procedure TgdvCustomLedgerTotalBlock.SetBeginCredit(
  const Value: TgdvLedgerTotalUnit);
begin
  FBeginCredit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetBeginDebit(
  const Value: TgdvLedgerTotalUnit);
begin
  FBeginDebit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetBlockName(const Value: string);
begin
  FBlockName := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetCredit(const Value: TgdvLedgerTotalUnit);
begin
  FCredit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetDebit(const Value: TgdvLedgerTotalUnit);
begin
  FDebit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetEndCredit(
  const Value: TgdvLedgerTotalUnit);
begin
  FEndCredit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetEndDebit(
  const Value: TgdvLedgerTotalUnit);
begin
  FEndDebit := Value;
end;

procedure TgdvCustomLedgerTotalBlock.SetValues;
var
  I: Integer;
begin
  BeginDebit.Field.AsCurrency := BeginDebit.Value;
  BeginCredit.Field.AsCurrency := BeginCredit.Value;
  Debit.Field.AsCurrency := Debit.Value;
  Credit.Field.AsCurrency := Credit.Value;
  EndDebit.Field.AsCurrency := EndDebit.Value;
  EndCredit.Field.AsCurrency := EndCredit.Value;

  for I := 0 to Count - 1 do
  begin
    Fields[i].Field.AsCurrency := Fields[i].Value
  end;
end;

{ TgdvSimpleLedgerTotalBlock }

procedure TgdvSimpleLedgerTotalBlock.DoCalc;
var
  C: Currency;
begin
  C := BeginDebit.Value - BeginCredit.Value + BeginDebit.Field.AsCurrency - BeginCredit.Field.AsCurrency;
  if C > 0 then
  begin
    BeginDebit.Value := C;
    BeginCredit.Value := 0;
  end else
  begin
    BeginDebit.Value := 0;
    BeginCredit.Value := -C;
  end;

  Debit.Value := Debit.Value + Debit.Field.AsCurrency;
  Credit.Value := Credit.Value + Credit.Field.AsCurrency;

  C := EndDebit.Value - EndCredit.Value + EndDebit.Field.AsCurrency - EndCredit.Field.AsCurrency;
  if C > 0 then
  begin
    EndDebit.Value := C;
    EndCredit.Value := 0;
  end else
  begin
    EndDebit.Value := 0;
    EndCredit.Value := -C;
  end;
end;

{ TgdvEncancedLedgerTotalBlock }

procedure TgdvEncancedLedgerTotalBlock.DoCalc;
begin
  BeginDebit.Value := BeginDebit.Value + BeginDebit.Field.AsCurrency;
  BeginCredit.Value := BeginCredit.Value + BeginCredit.Field.AsCurrency;

  Debit.Value := Debit.Value + Debit.Field.AsCurrency;
  Credit.Value := Credit.Value + Credit.Field.AsCurrency;

  EndDebit.Value := EndDebit.Value + EndDebit.Field.AsCurrency;
  EndCredit.Value := EndCredit.Value + EndCredit.Field.AsCurrency;
end;

{ TgdvStorageLedgerTotalBlock }

procedure TgdvStorageLedgerTotalBlock.DoCalc;
begin
  BeginDebit.Value := BeginDebit.Field.AsCurrency;
  BeginCredit.Value := BeginCredit.Field.AsCurrency;

  Debit.Value := Debit.Value + Debit.Field.AsCurrency;
  Credit.Value := Credit.Value + Credit.Field.AsCurrency;

  EndDebit.Value := EndDebit.Field.AsCurrency;
  EndCredit.Value := EndCredit.Field.AsCurrency;
end;

{ TgdvLedgerTotalBlocks }

procedure TgdvLedgerTotalBlocks.Calc;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Blocks[I].Calc;
  end;
end;

procedure TgdvLedgerTotalBlocks.SetValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Blocks[I].SetValues;
  end;
end;

procedure TgdvLedgerTotalBlocks.DropValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Blocks[I].DropValues;
  end;
end;

function TgdvLedgerTotalBlocks.GetBlocks(
  Index: Integer): TgdvCustomLedgerTotalBlock;
begin
  Result := TgdvCustomLedgerTotalBlock(Items[Index])
end;

procedure TgdvLedgerTotalBlocks.InitFields(DataSet: TDataSet);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Blocks[I].InitFields(DataSet)
  end;
end;

{ TgdvStorageLedgerTotalBlock1 }

constructor TgdvStorageLedgerTotalBlock1.Create;
begin
  inherited;
  FDroped := True;
end;

procedure TgdvStorageLedgerTotalBlock1.DoCalc;
begin
  if FDroped then
  begin
    BeginDebit.Value := BeginDebit.Field.AsCurrency;
    BeginCredit.Value := BeginCredit.Field.AsCurrency;
    FDroped := False;
  end;

  Debit.Value := Debit.Value + Debit.Field.AsCurrency;
  Credit.Value := Credit.Value + Credit.Field.AsCurrency;

  EndDebit.Value := EndDebit.Field.AsCurrency;
  EndCredit.Value := EndCredit.Field.AsCurrency;
end;

procedure TgdvStorageLedgerTotalBlock1.DropValues;
begin
  inherited;
  FDroped := True;
end;

{ TgdvAcctAnalyticLevel }
constructor TgdvAcctAnalyticLevels.Create;
begin
  FLevels := TStringList.Create;
end;

destructor TgdvAcctAnalyticLevels.Destroy;
begin
  FLevels.Free;
  inherited;
end;

procedure TgdvAcctAnalyticLevels.CheckProcedure;
var
  SP: TmdfStoredProcedure;
begin
  if not IsEmpty then
  begin
    SP.ProcedureName := SPName;
    if not ProcedureExist(SP, gdcBaseManager.Database) then
    begin
      SP.Description := Format(cStoredProcedureTemplate, [FField.References.RelationName,
        FField.ReferencesField.FieldName]);
      CreateProcedure(SP, gdcBaseManager.Database);
    end;
  end;
end;

function TgdvAcctAnalyticLevels.GetValue: String;
begin
  Result := FLevels.CommaText;
end;

function TgdvAcctAnalyticLevels.IsEmpty: Boolean;
begin
  Result := (FLevels.Count = 0);
end;

procedure TgdvAcctAnalyticLevels.SetField(const Value: TatRelationField);
begin
  FField := Value;
end;

procedure TgdvAcctAnalyticLevels.SetValue(const Value: String);
var
  I: Integer;
begin
  if Value <> '' then
  begin
    FLevels.Clear;
    FLevels.Text := StringReplace(Value, ',', #13#10, [rfReplaceAll]);
    for I := 0 to Flevels.Count - 1 do
    begin
      FLevels[I] := Trim(FLevels[I]);
    end;
  end;
end;

function TgdvAcctAnalyticLevels.SPName: string;
begin
  Result := Format('AC_LEDGER_%s', [FField.References.RelationName]);
end;

end.
