unit gdvAcctAccReview;

interface

uses
  classes, AcctStrings, AcctUtils, gdvAcctBase, gd_KeyAssoc, gdv_AvailAnalytics_unit,
  gdv_AcctConfig_unit, IBCustomDataSet;

type
  TgsSaldoRecord = record
    Ncu: Currency;
    Curr: Currency;
    EQ: Currency;
  end;

  TgdvAcctAccReview = class(TgdvAcctBase)
  protected
    FCorrDebit: Boolean;
    FWithCorrSubAccounts: Boolean;

    FIBDSSaldoBegin: TIBDataset;
    FIBDSSaldoEnd: TIBDataset;
    FIBDSCirculation: TIBDataset;

    FSaldoBegin: TgsSaldoRecord;
    FSaldoEnd: TgsSaldoRecord;
    FActualAnalytics: TList;
    FCorrActualAnalytics: TList;

    FAvailableAnalytics: TgdvAvailAnalytics;

    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;

    procedure CheckAvailAnalytics;
    procedure ActualAnalytics(AccountIDs, CorrAccountIDs: TgdKeyArray; Analytics: TList);
    procedure SQLAnalytics(ActualAnalyticsList: TList;
      Alias: string; var ASelect, AFrom, AGroup: string; FieldNamePrefix, CaptionPrefix: string);

    procedure SetDefaultParams; override;

    procedure DoBeforeBuildReport; override;
    procedure DoBuildSQL; override;
    procedure DoEmptySQL; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear; override;

    property CorrDebit: Boolean read FCorrDebit write FCorrDebit;
    property WithCorrSubAccounts: Boolean read FWithCorrSubAccounts write FWithCorrSubAccounts;

    property IBDSSaldoBegin: TIBDataset read FIBDSSaldoBegin;
    property IBDSSaldoEnd: TIBDataset read FIBDSSaldoEnd;
    property IBDSCirculation: TIBDataset read FIBDSCirculation;

    property SaldoBeginNcu: Currency read FSaldoBegin.Ncu;
    property SaldoBeginCurr: Currency read FSaldoBegin.Curr;
    property SaldoBeginEQ: Currency read FSaldoBegin.EQ;
    property SaldoEndNcu: Currency read FSaldoEnd.Ncu;
    property SaldoEndCurr: Currency read FSaldoEnd.Curr;
    property SaldoEndEQ: Currency read FSaldoEnd.EQ;
  end;

const
  // Кол-во полей по умолчанию входящих в запрос бух. отчета
  AccReviewFieldCount = 11;
  AccReviewQuantityFieldCount = 2;
  // Поля по умолчанию входящие в запрос бух. отчета
  AccReviewFieldList: array[0 .. AccReviewFieldCount - 1] of TgdvFieldInfoRec =(
    (FieldName: 'ALIAS'; Caption: 'Счет'; DisplayFieldName: ''),
    (FieldName: 'CORRALIAS'; Caption: 'Корр. счет'; DisplayFieldName: ''),
    (FieldName: 'NAME'; Caption: 'Наименование счета'; DisplayFieldName: ''),
    (FieldName: 'CORRNAME'; Caption: 'Наименование корр. счета'; DisplayFieldName: ''),
    (FieldName: 'NCU_DEBIT'; Caption: 'Оборот Д'; DisplayFieldName: ''),
    (FieldName: 'NCU_CREDIT'; Caption: 'Оборот К'; DisplayFieldName: ''),
    (FieldName: 'CURR_DEBIT'; Caption: 'Оборот Д, вал'; DisplayFieldName: 'NCU_DEBIT'),
    (FieldName: 'CURR_CREDIT'; Caption: 'Оборот К, вал'; DisplayFieldName: 'NCU_CREDIT'),
    (FieldName: 'EQ_DEBIT'; Caption: 'Оборот Д, экв'; DisplayFieldName: 'NCU_DEBIT'),
    (FieldName: 'EQ_CREDIT'; Caption: 'Оборот К, экв'; DisplayFieldName: 'NCU_CREDIT'),
    (FieldName: 'CURRENCYNAME'; Caption: 'Валюта'; DisplayFieldName: '')
    );

  AccReviewQuantityFieldList: array[0 .. AccReviewQuantityFieldCount - 1] of TgdvQuantityFieldInfoRec =(
    (FieldName: 'Q_D_%s'; Caption: 'Оборот Д, %s'; DisplayFieldName: '%s_DEBIT'),
    (FieldName: 'Q_C_%s'; Caption: 'Оборот К, %s'; DisplayFieldName: '%s_CREDIT')
    );  

procedure Register;

implementation

uses
  ibsql, at_classes, Sysutils, Controls, gdcBaseInterface;

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctAccReview]);
end;

{ TgdvAcctAccReview }

constructor TgdvAcctAccReview.Create(AOwner: TComponent);
begin
  inherited;

  FActualAnalytics := TList.Create;
  FCorrActualAnalytics := TList.Create;
  FAvailableAnalytics := TgdvAvailAnalytics.Create;

  FIBDSSaldoBegin := TIBDataset.Create(Self);
  FIBDSSaldoEnd := TIBDataset.Create(Self);
  FIBDSCirculation := TIBDataset.Create(Self);
end;

destructor TgdvAcctAccReview.Destroy;
begin
  FActualAnalytics.Free;
  FCorrActualAnalytics.Free;
  FAvailableAnalytics.Free;

  FIBDSSaldoBegin.Free;
  FIBDSSaldoEnd.Free;
  FIBDSCirculation.Free;

  inherited;
end;

procedure TgdvAcctAccReview.Clear;
begin
  inherited;

  FActualAnalytics.Clear;
  FCorrActualAnalytics.Clear;

  FSaldoBegin.Ncu := 0;
  FSaldoBegin.Curr := 0;
  FSaldoBegin.Eq := 0;
  FSaldoEnd.Ncu := 0;
  FSaldoEnd.Curr := 0;
  FSaldoEnd.Eq := 0;
end;

procedure TgdvAcctAccReview.CheckAvailAnalytics;
begin
  FAvailableAnalytics.Clear;
  FAvailableAnalytics.Refresh;
end;

procedure TgdvAcctAccReview.ActualAnalytics(AccountIDs, CorrAccountIDs: TgdKeyArray; Analytics: TList);
var
  ibsql: TIBSQL;
  I: Integer;
  S: string;
  F: TatRelationField;
  WhereClause: string;
begin
  if Analytics.Count = 0 then
  begin
    if FAvailableAnalytics.Count > 0 then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;

        S := '';
        for I := 0 to FAvailableAnalytics.Count - 1 do
        begin
          if Assigned(FAvailableAnalytics[I].Field)
             and (FAvailableAnalytics[I].FieldName <> ENTRYDATE)
             and (FAvailableAnalytics[I].FieldName <> 'ACCOUNTKEY')
             and (FAvailableAnalytics[I].FieldName <> 'CURRKEY')
             and (FAvailableAnalytics[I].FieldName <> 'COMPANYKEY') then
          begin
            if S > '' then
              S := S + ', '#13#10;
            S := S + Format('  SUM(a.%0:s) AS %0:s', [FAvailableAnalytics[I].FieldName]);
          end;
        end;

        if S > '' then
        begin
          ibsql.SQL.Text := 'SELECT '#13#10 + S + #13#10'FROM'#13#10'  ac_account a ';
          if AccountIDs.Count > 0 then
            WhereClause := WhereClause + Format(' WHERE a.id IN (%s)'#13#10, [IDList(AccountIDs)]);

          if CorrAccountIDs.Count > 0 then
          begin
            if AccountIDs.Count > 0 then
              WhereClause := WhereClause + Format(' OR a.id IN (%s)'#13#10, [IDList(CorrAccountIDs)])
            else
              WhereClause := WhereClause + Format(' WHERE a.id IN (%s)'#13#10, [IDList(CorrAccountIDs)]);
          end;

          ibsql.SQL.Add(WhereClause);
          ibsql.ExecQuery;

          if ibsql.RecordCount > 0 then
          begin
            for I := 0 to ibsql.Current.Count - 1 do
            begin
              if ibsql.Current[I].AsInteger > 0 then
              begin
                F := atDatabase.FindRelationField(AC_ENTRY, ibsql.Current[I].Name);
                if Assigned(F) then
                  Analytics.Add(F);
              end;
            end;
          end;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end;
end;

procedure TgdvAcctAccReview.DoBeforeBuildReport;
begin
  inherited;

  if FIBDSSaldoBegin.Active then
    FIBDSSaldoBegin.Close;
  if FIBDSSaldoEnd.Active then
    FIBDSSaldoEnd.Close;
  if FIBDSCirculation.Active then
    FIBDSCirculation.Close;
  FIBDSSaldoBegin.Transaction := gdcBaseManager.ReadTransaction;
  FIBDSSaldoEnd.Transaction := gdcBaseManager.ReadTransaction;
  FIBDSCirculation.Transaction := gdcBaseManager.ReadTransaction;

  // Если строим отчет с субсчетами, то получим список субсчетов для выбранных главных счетов
  if FWithCorrSubAccounts then
    FillSubAccounts(FCorrAccounts);

  if not FMakeEmpty then
  begin
    // Очистим списки аналитик
    FActualAnalytics.Clear;
    FCorrActualAnalytics.Clear;

    CheckAvailAnalytics;
    if not (Self.ClassName = 'TgdvAcctAccReview') then
    begin
      Self.ActualAnalytics(FAccounts, FCorrAccounts, FActualAnalytics);
      Self.ActualAnalytics(FCorrAccounts, FAccounts, FCorrActualAnalytics);
    end;  
  end;
end;

procedure TgdvAcctAccReview.DoBuildSQL;
var
  BalanceCondition, EntryCondition, CompanyS: String;
  AccWhere: String;
  AccWhereQuantity: String;
  ValueSelect, ValueJoin, ValueAlias, QuantityAlias: string;
  K: Integer;
//  ASelect, AGroup, AFrom, ACorrSelect, ACorrFrom, ACorrGroup: string;
  CompanySBalance, AccWhereBalance: String;
  CurrentKeyAlias: String;

  function FormBalanceQuery(ADate: TDate): String;
  begin
    Result := Format(
      'SELECT '#13#10 +
      '  main.accountkey AS ID, '#13#10 +
      '  CAST(SUM(main.debitncu - main.creditncu) / %d AS NUMERIC(15, %d)) AS Saldo, '#13#10 +
      '  CAST(SUM(main.debitcurr - main.creditcurr) / %d AS NUMERIC(15, %d)) AS SaldoCurr, '#13#10 +
      '  CAST(SUM(main.debiteq - main.crediteq) / %d AS NUMERIC(15, %d)) AS SaldoEQ ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
         FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
      'FROM '#13#10 +
      '('#13#10 +
      '  SELECT '#13#10 +
      '    bal.accountkey, '#13#10 +
      '    bal.debitncu, '#13#10 +
      '    bal.creditncu, '#13#10 +
      '    bal.debitcurr, '#13#10 +
      '    bal.creditcurr, '#13#10 +
      '    bal.debiteq, '#13#10 +
      '    bal.crediteq '#13#10 +
      '  FROM '#13#10 +
      '    ac_entry_balance bal '#13#10 +
      '  WHERE '#13#10 +
      '    ' + AccWhereBalance + CompanySBalance +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0), '    AND bal.currkey = ' + IntToStr(FCurrkey) + #13#10, '') +
        IIF(BalanceCondition <> '', ' AND ' + BalanceCondition + #13#10, '');
    if FEntryBalanceDate <> ADate then
    begin
      Result := Result + #13#10'  UNION ALL '#13#10#13#10'  SELECT ';
      if FEntryBalanceDate > ADate then
      begin
        Result := Result +
          '   e.accountkey, '#13#10 +
          '   - e.debitncu, '#13#10 +
          '   - e.creditncu, '#13#10 +
          '   - e.debitcurr, '#13#10 +
          '   - e.creditcurr, '#13#10 +
          '   - e.debiteq, '#13#10 +
          '   - e.crediteq '#13#10 +
          '  FROM '#13#10 +
          '    ac_entry e '#13#10 +
            IIF(FCorrAccounts.Count > 0,
              '    JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart '#13#10, '') +
          '  WHERE '#13#10 +
            AccWhere + CompanyS +
          '    AND e.entrydate >= :begindate '#13#10 +
          '    AND e.entrydate < CAST(CAST(''17.11.1858'' AS DATE) + ' + IntToStr(Round(FEntryBalanceDate + IBDateDelta)) + ' AS DATE)';
      end
      else
      begin
        Result := Result +
          '   e.accountkey, '#13#10 +
          '   e.debitncu, '#13#10 +
          '   e.creditncu, '#13#10 +
          '   e.debitcurr, '#13#10 +
          '   e.creditcurr, '#13#10 +
          '   e.debiteq, '#13#10 +
          '   e.crediteq '#13#10 +
          '  FROM '#13#10 +
          '    ac_entry e '#13#10 +
            IIF(FCorrAccounts.Count > 0,
              '    JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart '#13#10, '') +
          '  WHERE '#13#10 +
            AccWhere + CompanyS +
          '    AND e.entrydate >= CAST(CAST(''17.11.1858'' AS DATE) + ' + IntToStr(Round(FEntryBalanceDate + IBDateDelta)) + ' AS DATE) '#13#10 +
          '    AND e.entrydate < :begindate ';
      end;
      if FCurrSumInfo.Show and (FCurrkey > 0) then
        Result := Result + #13#10 + '    AND e.currkey = ' + IntToStr(FCurrkey);

      if EntryCondition > '' then
        Result := Result + ' AND ' + EntryCondition;
    end
    else
    begin
      // Заглушка для скриптов, ранее в запросе обязательно присутствовал параметр :begindate
      Result := Result + ' AND ((:begindate > CAST(''17.11.1858'' AS DATE)) OR (1 = 1)) ';
    end;
    Result := Result + ') main '#13#10 +
      ' GROUP BY '#13#10 +
      '   main.accountkey ';
  end;

begin
  ValueSelect := '';
  ValueJoin := '';
  AccWhereQuantity := '';
  //Количественные показатели
  if FAcctValues.Count > 0 then
  begin
    for K := 0 to FAcctValues.Count - 1 do
    begin
      CurrentKeyAlias := GetKeyAlias(FAcctValues.Names[K]);
      ValueAlias := 'v_' + CurrentKeyAlias;
      QuantityAlias := 'q_' + CurrentKeyAlias;
      ValueSelect := ValueSelect + ', '#13#10 +
        Format(
          '  SUM(IIF(e.accountpart = ''D'' AND (NOT %0:s.quantity IS NULL), %0:s.quantity, 0)) AS Q_D_%1:s,'#13#10 +
          '  SUM(IIF(e.accountpart = ''C'' AND (NOT %0:s.quantity IS NULL), %0:s.quantity, 0)) AS Q_C_%1:s'#13#10,
          [QuantityAlias, CurrentKeyAlias]);

      ValueJoin := ValueJoin + #13#10 +
        Format('  LEFT JOIN ac_quantity %0:s ON %0:s.entrykey = e.id AND '#13#10 +
          '     %0:s.valuekey = %1:s'#13#10 +
          '  LEFT JOIN gd_value %2:s ON %2:s.id = %0:s.valuekey',
          [QuantityAlias, FAcctValues.Names[K], ValueAlias]);
      if AccWhereQuantity > '' then
        AccWhereQuantity := AccWhereQuantity + ' OR ';
      AccWhereQuantity := AccWhereQuantity + QuantityAlias + '.quantity <> 0 ';
    end;  
  end;

  // Аналитика
  //SQLAnalytics(FActualAnalytics, 'e', ASelect, AFrom, AGroup, '', '');
  //SQLAnalytics(FCorrActualAnalytics, 'e1', ACorrSelect, ACorrFrom, ACorrGroup, 'CORR_', 'Кор. ');
  // Список компаний
  CompanyS := ' (e.companykey + 0 IN (' + FCompanyList + '))';
  // Счета
  if FAccounts.Count > 0 then
    AccWhere := 'e.accountkey IN (' + IDList(FAccounts) + ') AND e.accountkey <> 300003 AND '
  else
    AccWhere := ' e.accountkey <> 300003 AND ';
  // Корреспондирующие счета
  if FCorrAccounts.Count > 0 then
  begin
    if FCorrDebit then
      AccWhere := AccWhere + ' e1.accountkey IN (' + IDList(FCorrAccounts) +
        ') AND e1.accountpart = ''D'' AND '
    else
      AccWhere := AccWhere + ' e1.accountkey IN (' + IDList(FCorrAccounts) +
        ') AND e1.accountpart = ''C'' AND ';
  end;
  // Ограничения накладываемые аналитиками
  BalanceCondition := Self.GetCondition('bal');
  EntryCondition := Self.GetCondition('e');

  FIBDSSaldoBegin.Close;
  // Сальдо на начало
  if UseEntryBalance and (FCorrAccounts.Count = 0) and (FAcctValues.Count = 0) then
  begin
    CompanySBalance := 'bal.companykey + 0 IN (' + FCompanyList + ')';

    if FAccounts.Count > 0 then
      AccWhereBalance := 'bal.accountkey IN (' + IDList(FAccounts) + ')'#13#10'    AND '
    else
      AccWhereBalance := '';

    FIBDSSaldoBegin.SelectSQL.Text := FormBalanceQuery(FDateBegin);
  end
  else
  begin
    FIBDSSaldoBegin.SelectSQL.Text := Format(
      'SELECT e.accountkey AS id, '#13#10 +
      '  CAST(SUM(e.debitncu - e.creditncu) / %d AS NUMERIC(15, %d))AS Saldo, '#13#10 +
      '  CAST(SUM(e.debitcurr - e.creditcurr) / %d AS NUMERIC(15, %d)) AS SaldoCurr, '#13#10 +
      '  CAST(SUM(e.debiteq - e.crediteq) / %d AS NUMERIC(15, %d)) AS SaldoEQ ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
       FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
      ' FROM '#13#10 +
      '   ac_entry e  ' +
        IIF(FCorrAccounts.Count > 0,
          ' JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart '#13#10, '') +
      ' WHERE ' + AccWhere + '   e.entrydate < :begindate AND ' + CompanyS +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          ' AND e.currkey = ' + IntToStr(FCurrkey) + #13#10, '') +
        IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition, '') +
      ' GROUP BY 1';
  end;
  FIBDSSaldoBegin.ParamByName(BeginDate).AsDateTime := FDateBegin;
  FIBDSSaldoBegin.Open;

  while not FIBDSSaldoBegin.Eof do
  begin
    FSaldoBegin.Ncu := FSaldoBegin.Ncu + FIBDSSaldoBegin.FieldByName('saldo').AsCurrency;
    FSaldoBegin.Curr := FSaldoBegin.Curr + FIBDSSaldoBegin.FieldByName('saldocurr').AsCurrency;
    FSaldoBegin.EQ := FSaldoBegin.EQ + FIBDSSaldoBegin.FieldByName('saldoeq').AsCurrency;
    FIBDSSaldoBegin.Next;
  end;

  // Сальдо на конец
  FIBDSSaldoEnd.Close;
  if FUseEntryBalance and (FCorrAccounts.Count = 0) and (FAcctValues.Count = 0) then
  begin
    FIBDSSaldoEnd.SelectSQL.Text := FormBalanceQuery(FDateEnd + 1);
  end
  else
  begin
    FIBDSSaldoEnd.SelectSQL.Text := FIBDSSaldoBegin.SelectSQL.Text;
  end;
  FIBDSSaldoEnd.ParamByName(BeginDate).AsDateTime := FDateEnd + 1;
  FIBDSSaldoEnd.Open;

  while not FIBDSSaldoEnd.Eof do
  begin
    FSaldoEnd.Ncu := FSaldoEnd.Ncu + FIBDSSaldoEnd.FieldByName('saldo').AsCurrency;
    FSaldoEnd.Curr := FSaldoEnd.Curr + FIBDSSaldoEnd.FieldByName('saldocurr').AsCurrency;
    FSaldoEnd.EQ := FSaldoEnd.EQ + FIBDSSaldoEnd.FieldByName('saldoeq').AsCurrency;
    FIBDSSaldoEnd.Next;
  end;

  // Используется в печатной форме
  FIBDSCirculation.Close;
  FIBDSCirculation.SelectSQL.Text :=
    Format(
      'SELECT e.accountkey AS id, '#13#10 +
      '  CAST(SUM(e.debitncu) / %0:d AS NUMERIC(15, %1:d))AS ncu_debit_circulation, '#13#10 +
      '  CAST(SUM(e.creditncu) / %0:d AS NUMERIC(15, %1:d))AS ncu_credit_circulation, '#13#10 +
      '  CAST(SUM(e.debitcurr) / %2:d AS NUMERIC(15, %3:d)) AS curr_debit_circulation, '#13#10 +
      '  CAST(SUM(e.creditcurr) / %2:d AS NUMERIC(15, %3:d)) AS curr_credit_circulation, '#13#10 +
      '  CAST(SUM(e.debiteq) / %4:d AS NUMERIC(15, %5:d)) AS eq_debit_circulation, '#13#10 +
      '  CAST(SUM(e.crediteq) / %4:d AS NUMERIC(15, %5:d)) AS eq_credit_circulation FROM ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
         FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
    ' ac_entry e  ' +
      IIF(FCorrAccounts.Count > 0,
        ' JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart '#13#10, '') +
    ' WHERE ' + AccWhere +
    '   e.entrydate >= :begindate AND e.entrydate <= :enddate AND ' + CompanyS +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0), ' AND e.currkey = ' + IntToStr(FCurrkey) + #13#10, '') +
      InternalMovementClause('e') + 
      IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition + #13#10, '') +
    ' GROUP BY 1 ';
  FIBDSCirculation.ParamByName(BeginDate).AsDateTime := FDateBegin;
  FIBDSCirculation.ParamByName(EndDate).AsDateTime := FDateEnd;  
  FIBDSCirculation.Open;  
  // Основной запрос для анализа счета
  if FUseEntryBalance and (FCorrAccounts.Count = 0) and (FAcctValues.Count = 0) then
  begin
    Self.SelectSQL.Text := Format(
      'SELECT '#13#10 +
      '  a.alias AS alias, '#13#10 +
      '  corr_a.alias AS corralias, '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0), '  curr.ShortName as CURRENCYNAME, '#13#10, '') +
      '  a.id AS id, '#13#10 +
      '  corr_a.id AS corrid, '#13#10 +
      '  a.name AS name, '#13#10 +
      '  corr_a.name AS corrname, '#13#10 +
      '  main.ncu_debit, '#13#10 +
      '  main.ncu_credit, '#13#10 +
      '  main.curr_debit, '#13#10 +
      '  main.curr_credit, '#13#10 +
      '  main.eq_debit, '#13#10 +
      '  main.eq_credit '#13#10 +
      'FROM '#13#10 +
      '  ( '#13#10 +
      '    SELECT '#13#10 +
      '      entry.accountkey, '#13#10 +
      '      corr_entry.accountkey AS corr_accountkey, '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          ' IIF(corr_entry.issimple = 0 and entry.currkey <> corr_entry.currkey and corr_entry.debitcurr = 0 and corr_entry.creditcurr = 0, corr_entry.currkey, entry.currkey) AS currkey, '#13#10, '') +
      '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.creditncu, entry.debitncu) / %0:d AS NUMERIC(15, %1:d))) AS ncu_debit, '#13#10 +
      '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.debitncu, entry.creditncu) / %0:d AS NUMERIC(15, %1:d))) AS ncu_credit, '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          '      SUM(CAST(IIF(corr_entry.issimple = 0, IIF(entry.currkey <> corr_entry.currkey, entry.debitcurr, corr_entry.creditcurr), entry.debitcurr) / %2:d AS NUMERIC(15, %3:d))) AS curr_debit, '#13#10 +
          '      SUM(CAST(IIF(corr_entry.issimple = 0, IIF(entry.currkey <> corr_entry.currkey, entry.creditcurr, corr_entry.debitcurr), entry.creditcurr) / %2:d AS NUMERIC(15, %3:d))) AS curr_credit, ',
          '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.creditcurr, entry.debitcurr) / %2:d AS NUMERIC(15, %3:d))) AS curr_debit, '#13#10 +
          '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.debitcurr, entry.creditcurr) / %2:d AS NUMERIC(15, %3:d))) AS curr_credit, ')  + #13#10 +
      '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.crediteq, entry.debiteq) / %4:d AS NUMERIC(15, %5:d))) AS eq_debit, '#13#10 +
      '      SUM(CAST(IIF(corr_entry.issimple = 0, corr_entry.debiteq, entry.crediteq) / %4:d AS NUMERIC(15, %5:d))) AS eq_credit '#13#10 +
      '    FROM '#13#10 +
      '    ( '#13#10 +
      '      SELECT '#13#10 +
      '        e.recordkey, '#13#10 +
      '        e.accountkey, '#13#10 +
      '        e.accountpart, '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0), ' e.currkey, '#13#10, '') +
      '        e.debitncu, '#13#10 +
      '        e.creditncu, '#13#10 +
      '        e.debitcurr, '#13#10 +
      '        e.creditcurr, '#13#10 +
      '        e.debiteq, '#13#10 +
      '        e.crediteq '#13#10 +
      '      FROM '#13#10 +
      '        ac_entry e '#13#10 +
        IIF(FCorrAccounts.Count > 0,
          ' LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart'#13#10,
          '') +
      '      WHERE '#13#10 +
        AccWhere + #13#10 + CompanyS + ' AND '#13#10 +
        IIF(Trim(AccWhereQuantity) > '', '        (' + AccWhereQuantity + ') AND '#13#10, '') +
      '        e.entrydate >= :begindate '#13#10 +
      '        AND e.entrydate <= :enddate '#13#10 +
        IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition, '') +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0), ' AND e.currkey = ' + IntToStr(FCurrkey) + #13#10, '') +
        InternalMovementClause +
      '    ) entry '#13#10 +
      '    LEFT JOIN ac_entry corr_entry ON corr_entry.recordkey = entry.recordkey AND corr_entry.accountpart <> entry.accountpart '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          '     AND 1 = IIF(corr_entry.issimple = 0 and corr_entry.currkey <> entry.currkey and corr_entry.debitcurr = 0 and corr_entry.creditcurr = 0, 0, 1)'#13#10 , '') +
      '    GROUP BY '#13#10 +
      '      1, 2 ' + IIF(FCurrSumInfo.Show and (FCurrkey > 0), ', 3 ', '') + #13#10 +
      '  ) main '#13#10 +
      '  LEFT JOIN ac_account corr_a ON main.corr_accountkey = corr_a.id '#13#10 +
      '  LEFT JOIN ac_account a ON a.id = main.accountkey '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          '  LEFT JOIN gd_curr curr ON curr.id = main.currkey '#13#10, '') +
      'ORDER BY '#13#10 +
      '  1, 2 ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
       FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]);
  end
  else
  begin
    Self.SelectSQL.Text := Format(
      'SELECT '#13#10 +
      '  a.alias AS alias, '#13#10 +
      '  corr_a.alias AS corralias, '#13#10 +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
      '  curr.ShortName as CURRENCYNAME, '#13#10, '')  +
      '  a.id AS id, '#13#10 +
      '  corr_a.id AS corrid, '#13#10 +
      '  a.name AS name, '#13#10 +
      '  corr_a.name AS corrname, '#13#10 +
      '  SUM(CAST(IIF(e1.issimple = 0, e1.creditncu, e.debitncu) / %0:d AS NUMERIC(15, %1:d))) AS NCU_DEBIT, '#13#10 +
      '  SUM(CAST(IIF(e1.issimple = 0, e1.debitncu, e.creditncu) / %0:d AS NUMERIC(15, %1:d))) AS NCU_CREDIT, '#13#10 +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        '  SUM(CAST(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.debitcurr, e1.creditcurr), e.debitcurr) / %2:d AS NUMERIC(15, %3:d))) AS CURR_DEBIT, '#13#10 +
        '  SUM(CAST(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.creditcurr, e1.debitcurr), e.creditcurr) / %2:d AS NUMERIC(15, %3:d))) AS CURR_CREDIT, ',
        '  SUM(CAST(IIF(e1.issimple = 0, e1.creditcurr, e.debitcurr) / %2:d AS NUMERIC(15, %3:d))) AS CURR_DEBIT, '#13#10 +
        '  SUM(CAST(IIF(e1.issimple = 0, e1.debitcurr, e.creditcurr) / %2:d AS NUMERIC(15, %3:d))) AS CURR_CREDIT, ')  + #13#10 +
      '  SUM(CAST(IIF(e1.issimple = 0, e1.crediteq, e.debiteq) / %4:d AS NUMERIC(15, %5:d))) AS EQ_DEBIT, '#13#10 +
      '  SUM(CAST(IIF(e1.issimple = 0, e1.debiteq, e.crediteq) / %4:d AS NUMERIC(15, %5:d))) AS EQ_CREDIT '#13#10 +
      ValueSelect + #13#10 +
      ' FROM ac_entry e  '#13#10 +
      '  LEFT JOIN ac_entry e1 ON e.recordkey = e1.recordkey AND e.accountpart <> e1.accountpart '#13#10 +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        ' AND 1 = IIF(e1.issimple = 0 and e1.currkey <> e.currkey and e1.debitcurr = 0 and e1.creditcurr = 0, 0, 1)'#13#10 , '') +
      '  LEFT JOIN ac_account corr_a ON e1.accountkey = corr_a.id '#13#10 +
      '  LEFT JOIN gd_curr curr ON curr.id = ' +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        'IIF(e1.issimple = 0 and e.currkey <> e1.currkey and e1.debitcurr = 0 and e1.creditcurr = 0, e1.currkey, e.currkey)',
        'e.currkey ') + #13#10 +
      '  LEFT JOIN ac_transaction t ON e.transactionkey = t.id '#13#10 +
      '  LEFT JOIN ac_account a ON a.id = e.accountkey '#13#10 +
      ValueJoin + #13#10 + {AFrom + ACorrFrom +} #13#10 +
      ' where '#13#10 + AccWhere + #13#10 + CompanyS + ' AND '#13#10 +
      IIF(Trim(AccWhereQuantity) > '', '  (' + AccWhereQuantity + ') AND '#13#10, '') + 
      '  e.entrydate >= :begindate AND e.entrydate <= :enddate '#13#10 +
      IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition + #13#10, '') +
      InternalMovementClause,
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
       FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0), ' AND e.currkey = ' + IntToStr(FCurrkey), '') +
      IIF(FCorrAccounts.Count > 0,
        IIF(FCorrDebit,
          ' AND e1.accountkey IN (' + IDList(FCorrAccounts) + ') AND e1.accountpart = ''D''',
          ' AND e1.accountkey IN (' + IDList(FCorrAccounts) + ') AND e1.accountpart = ''C''') + #13#10, '') +
      ' GROUP BY 1, 2, 3, 4, 5, 6 ' +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0), ', 7', '') + #13#10 +
      ' ORDER BY 1, 2';
  end;
end;

procedure TgdvAcctAccReview.DoEmptySQL;
var
  I: Integer;
  SQLText: String;
begin
  SQLText := '';

  for I := 0 to AccReviewFieldCount - 1 do
  begin
    if SQLText > '' then
      SQLText := SQLText + ', '#13#10;
    SQLText := SQLText + Format('CAST(NULL AS NUMERIC(15, 4)) AS %s', [AccReviewFieldList[I].FieldName]);
  end;
  SQLText := 'SELECT ' + SQLText + ', CAST(NULL AS VARCHAR(180)) AS NAME FROM rdb$database WHERE RDB$CHARACTER_SET_NAME = ''_''';

  Self.SelectSQL.Text := SQLText;
end;

procedure TgdvAcctAccReview.SetDefaultParams;
begin
  inherited;

  FCorrDebit := True;
  FWithCorrSubAccounts := False;
end;

procedure TgdvAcctAccReview.SQLAnalytics(ActualAnalyticsList: TList;
  Alias: string; var ASelect, AFrom, AGroup: string; FieldNamePrefix, CaptionPrefix: string);
var
  S: String;
  I: Integer;
  F: TatRelationField;
  FieldInfo: TgdvFieldInfo;
begin
  ASelect := '';
  AFrom := '';
  AGroup := '';
  for I := 0 to ActualAnalyticsList.Count - 1 do
  begin
    F := TatRelationField(ActualAnalyticsList[I]);
    if ASelect > '' then
      ASelect := ASelect + ', '#13#10;
    AGroup := AGroup + ', '#13#10;

    if not Assigned(F.ReferencesField) then
    begin
      ASelect := ASelect + Format('  %s.%s AS %s ', [Alias, F.FieldName, FieldNamePrefix + F.FieldName]);
      AGroup := AGroup + Format('  %s.%s', [Alias, F.FieldName]);
      Self.ExtendedFields(F, S, ASelect, AGroup);
      S := F.FieldName;
    end
    else
    begin
      S := Self.GetNameAlias(FieldNamePrefix + F.FieldName + '_' + F.Field.RefListFieldName);
      ASelect := ASelect + '  ' + S + '.' +
        F.Field.RefListFieldName + ' AS ' + S;
      AGroup := AGroup + '  ' + S + '.' + F.Field.RefListFieldName;

      AFrom := AFrom + Format('  LEFT JOIN %0:s %1:s ON %1:s.%2:s = %3:s.%4:s ',
        [F.References.RelationName, S, F.ReferencesField.FieldName,
        Alias, F.FieldName]);

      Self.ExtendedFields(F, S, ASelect, AGroup);
    end;
    // Описание столбца для грида
    if Assigned(FFieldInfos) then
    begin
      FieldInfo := FFieldInfos.AddInfo;
      FieldInfo.FieldName := S;
      FieldInfo.DisplayFormat := '';
      FieldInfo.Visible := fvVisible;
      FieldInfo.Caption := CaptionPrefix + F.LName;
    end;
  end;
  if ASelect > '' then
    ASelect := ASelect + ','#13#10;
end;

procedure TgdvAcctAccReview.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
  S: TStrings;
  Value: string;
  I: Integer;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    S := TStringList.Create;
    try
      C.ShowCorrSubAccounts := FWithSubAccounts;
      S.Text := C.CorrAccountsRUIDList;
      for I := 0 to S.Count - 1 do
        AddCorrAccount(gdcBaseManager.GetIDByRUIDString(Trim(S.Strings[I])));
      FCorrDebit := C.AccountPart = 'D';

      S.Clear;
      S.Text := C.Analytics;
      Value := S.Values['ACCOUNTKEY'];
      if Value > '' then
      begin
        FAccounts.Clear;
        AddAccount(StrToInt(Value));
      end;

      Value := S.Values['CURRKEY'];
      if Value > '' then
      begin
        FCurrkey := StrToInt(Value);
        FCurrSumInfo.Show := True;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TgdvAcctAccReview.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
  StringList: TStringList;
  I: Integer;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    C.ShowCorrSubAccounts := FWithCorrSubAccounts;
    StringList := TStringList.Create;
    try
      for I := 0 to FCorrAccounts.Count - 1 do
        StringList.Add(gdcBasemanager.GetRUIDStringByID(FCorrAccounts.Keys[I]));
      C.CorrAccountsRUIDList := StringList.Text;
    finally
      StringList.Free;
    end;

    if FCorrDebit then
      C.AccountPart := 'D'
    else
      C.AccountPart := 'C';
  end;
end;

class function TgdvAcctAccReview.ConfigClassName: string;
begin
  Result := 'TAccReviewConfig';
end;

end.
 