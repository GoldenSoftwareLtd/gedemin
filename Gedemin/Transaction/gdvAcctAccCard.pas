unit gdvAcctAccCard;

interface

uses
  classes, AcctStrings, AcctUtils, gdvAcctBase, gdvAcctAccReview,
  gdv_AcctConfig_unit, IBCustomDataSet;

type

  TgdvAcctAccCard = class(TgdvAcctAccReview)
  private
    FDoGroup: Boolean;
  protected
    FIBDSSaldoQuantityBegin: TIBDataset;
    FIBDSSaldoQuantityEnd: TIBDataset;

    procedure SetDefaultParams; override;

    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;

    procedure DoBeforeBuildReport; override;
    procedure DoBuildSQL; override;
    procedure DoEmptySQL; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property IBDSSaldoQuantityBegin: TIBDataset read FIBDSSaldoQuantityBegin;
    property IBDSSaldoQuantityEnd: TIBDataset read FIBDSSaldoQuantityEnd;

    property DoGroup: Boolean read FDoGroup write FDoGroup;
  end;

const
  AccCardAdditionalFieldCount = 12;

  AccCardAdditionalFieldList: array[0 .. AccCardAdditionalFieldCount - 1] of TgdvFieldInfoRec =(
    (FieldName: 'ID'; Caption: 'Ключ проводки'; DisplayFieldName: ''),
    (FieldName: 'DOCUMENTKEY'; Caption: 'Ключ документа'; DisplayFieldName: ''),
    (FieldName: 'ALIAS'; Caption: 'Счет'; DisplayFieldName: ''),
    (FieldName: 'CORRALIAS'; Caption: 'Корр. счет'; DisplayFieldName: ''),
    (FieldName: 'CURRENCYNAME'; Caption: 'Валюта'; DisplayFieldName: ''),
    (FieldName: 'NAME'; Caption: 'Наименование документа'; DisplayFieldName: ''),
    (FieldName: 'TRANSACTIONKEY'; Caption: 'Ключ операции'; DisplayFieldName: ''),
    (FieldName: 'TRANSACTIONNAME'; Caption: 'Типовая хоз. операция'; DisplayFieldName: ''),
    (FieldName: 'DESCRIPTION'; Caption: 'Описание'; DisplayFieldName: ''),
    (FieldName: 'NUMBER'; Caption: 'Номер'; DisplayFieldName: ''),
    (FieldName: 'ENTRYDATE'; Caption: 'Дата проводки'; DisplayFieldName: ''),
    (FieldName: 'TRRECORDNAME'; Caption: 'Типовая проводка'; DisplayFieldName: '')
    );

procedure Register;

implementation

uses
  ibsql, Sysutils, Controls, gdcBaseInterface;

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctAccCard]);
end;

{ TgdvAcctAccCard }

constructor TgdvAcctAccCard.Create(AOwner: TComponent);
begin
  inherited;
  FIBDSSaldoQuantityBegin := TIBDataset.Create(nil);
  FIBDSSaldoQuantityEnd := TIBDataset.Create(nil);
end;

destructor TgdvAcctAccCard.Destroy;
begin
  FIBDSSaldoQuantityBegin.Free;
  FIBDSSaldoQuantityEnd.Free;
  inherited;
end;

procedure TgdvAcctAccCard.DoBuildSQL;
var
  CurrentKeyAlias: String;
  BalanceCondition, EntryCondition, CompanyS: String;
  AccWhere: String;
  CompanySBalance: String;
  AccWhereBalance: String;
  AccWhereQuantity: String;
  ValueSelect, ValueJoin, ValueAlias, QuantityAlias, IDValues: String;
  K: Integer;
  ASelect, AFrom, AGroup, ACorrSelect, ACorrFrom, ACorrGroup: String;

  function FormBalanceQuery(ADate: TDate): String;
  begin
    Result := Format(
      'SELECT '#13#10 +
      '  CAST(SUM(main.debitncu - main.creditncu) / %d AS NUMERIC(15, %d)) AS Saldo, '#13#10 +
      '  CAST(SUM(main.debitcurr - main.creditcurr) / %d AS NUMERIC(15, %d)) AS SaldoCurr, '#13#10 +
      '  CAST(SUM(main.debiteq - main.crediteq) / %d AS NUMERIC(15, %d)) AS SaldoEQ ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale, FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
      'FROM '#13#10 +
      '('#13#10 +
      '  SELECT '#13#10 +
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
          '    AND e.entrydate < CAST(CAST(''17.11.1858'' AS DATE) + ' + IntToStr(Round(FEntryBalanceDate + IBDateDelta)) + ' AS DATE) ';
      end
      else
      begin
        Result := Result +
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
    Result := Result + ') main';
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
      if FDoGroup then
        ValueSelect := ValueSelect + ','#13#10 +
          Format('  MAX(%0:s.name) AS QUANTITY_NAME_%1:s,'#13#10 +
            '  CAST(SUM(IIF(e.accountpart = ''D'' AND (NOT %2:s.quantity IS NULL), %2:s.quantity, 0)) / %3:d AS NUMERIC(15, %4:d)) AS Q_D_%1:s,'#13#10 +
            '  CAST(SUM(IIF(e.accountpart = ''C'' AND (NOT %2:s.quantity IS NULL), %2:s.quantity, 0)) / %3:d AS NUMERIC(15, %4:d)) AS Q_C_%1:s'#13#10,
            [ValueAlias, CurrentKeyAlias, QuantityAlias, FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits])
      else
        ValueSelect := ValueSelect + ','#13#10 +
          Format('  %0:s.name AS QUANTITY_NAME_%1:s,'#13#10 +
            '  CAST(IIF(e.accountpart = ''D'' AND (NOT %2:s.quantity IS NULL), %2:s.quantity, 0) / %3:d AS NUMERIC(15, %4:d)) AS Q_D_%1:s,'#13#10 +
            '  CAST(IIF(e.accountpart = ''C'' AND (NOT %2:s.quantity IS NULL), %2:s.quantity, 0) / %3:d AS NUMERIC(15, %4:d)) AS Q_C_%1:s'#13#10,
            [ValueAlias, CurrentKeyAlias, QuantityAlias, FQuantitySumInfo.Scale, FQuantitySumInfo.DecDigits]);

      ValueJoin := ValueJoin + #13#10 +
        Format('  LEFT JOIN ac_quantity %0:s ON %0:s.entrykey = e.id AND '#13#10 +
          '     %0:s.valuekey = %1:s'#13#10 +
          '  LEFT JOIN gd_value %2:s ON %2:s.id = %0:s.valuekey',
          [QuantityAlias, FAcctValues.Names[K], ValueAlias]);

{ Зачем-то было добавлено ограничение на вывод проводок только с кол-ными показателями если они указаны }
{ Но при это не видны остальные проводки, а по идее

{      if AccWhereQuantity > '' then
        AccWhereQuantity := AccWhereQuantity + ' OR ';
      AccWhereQuantity := AccWhereQuantity + ' coalesce(' + QuantityAlias + '.quantity, 0) <> 0 '; }
    end; 
  end;

  // Аналитика
  SQLAnalytics(FActualAnalytics, 'e', ASelect, AFrom, AGroup, '', '');
  SQLAnalytics(FCorrActualAnalytics, 'e1', ACorrSelect, ACorrFrom, ACorrGroup, 'CORR_', 'Кор. ');

  CompanyS := ' (e.companykey IN (' + FCompanyList + '))';

  if FAccounts.Count > 0 then
    AccWhere := 'e.accountkey IN (' + IDList(FAccounts) + ') AND '
  else
    AccWhere := '';

  if FCorrAccounts.Count > 0 then
  begin
    if FCorrDebit then
      AccWhere := AccWhere + ' e1.accountkey IN (' + IDList(FCorrAccounts) +
        ') AND e1.accountpart = ''D'' AND '
    else
      AccWhere := AccWhere + ' e1.accountkey IN (' + IDList(FCorrAccounts) +
        ') AND e1.accountpart = ''C'' AND ';
  end;

  BalanceCondition := Self.GetCondition('bal');
  EntryCondition := Self.GetCondition('e');

  // Сальдо на начало
  if FIBDSSaldoBegin.Active then
    FIBDSSaldoBegin.Close;
  if FUseEntryBalance and (FCorrAccounts.Count = 0) and (FAcctValues.Count = 0) then
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
      'SELECT CAST(SUM(e.debitncu - e.creditncu) / %d AS NUMERIC(15, %d))AS Saldo, '#13#10 +
      ' CAST(SUM(e.debitcurr - e.creditcurr) / %d AS NUMERIC(15, %d)) AS SaldoCurr, '#13#10 +
      ' CAST(SUM(e.debiteq - e.crediteq) / %d AS NUMERIC(15, %d)) AS SaldoEQ ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits, FCurrSumInfo.Scale,
       FCurrSumInfo.DecDigits, FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
      ' FROM '#13#10 +
      '   ac_entry e  ' +
        IIF(FCorrAccounts.Count > 0,
          ' JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart '#13#10, '') +
          GetJoinTableClause('e') +
      ' WHERE ' + AccWhere + ' e.entrydate < :begindate AND ' + CompanyS +
        IIF(FCurrSumInfo.Show and (FCurrkey > 0),
          ' AND e.currkey = ' + IntToStr(FCurrkey) + #13#10, '') +
        IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition, '');
  end;
  FIBDSSaldoBegin.ParamByName(BeginDate).AsDateTime := FDateBegin;
  FIBDSSaldoBegin.Open;

  // Перенесем значения в запись FSaldoBegin
  if FIBDSSaldoBegin.RecordCount > 0 then
  begin
    FSaldoBegin.Ncu := FIBDSSaldoBegin.FieldByName('saldo').AsCurrency;
    FSaldoBegin.Curr := FIBDSSaldoBegin.FieldByName('saldocurr').AsCurrency;
    FSaldoBegin.EQ := FIBDSSaldoBegin.FieldByName('saldoeq').AsCurrency;
  end;

  // Сальдо на конец
  if FIBDSSaldoEnd.Active then
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

  // Перенесем значения в запись FSaldoEnd
  if FIBDSSaldoEnd.RecordCount > 0 then
  begin
    FSaldoEnd.Ncu := FIBDSSaldoEnd.FieldByName('saldo').AsCurrency;
    FSaldoEnd.Curr := FIBDSSaldoEnd.FieldByName('saldocurr').AsCurrency;
    FSaldoEnd.EQ := FIBDSSaldoEnd.FieldByName('saldoeq').AsCurrency;
  end;

  // Количественый учет
  IDValues := '';
  for K := 0 to FAcctValues.Count - 1 do
  begin
    if IDValues <> '' then IDValues := IDValues + ',';
    IDValues := IDValues + FAcctValues.Names[K];
  end;
  if IDValues = '' then
    IDValues := '-1';

  if FIBDSSaldoQuantityBegin.Active then
    FIBDSSaldoQuantityBegin.Close;
  FIBDSSaldoQuantityBegin.SelectSQL.Text :=
    'SELECT ' +
    '  CAST(SUM(CASE WHEN e.debitncu > 0 THEN q.quantity ELSE -q.quantity END) AS NUMERIC(15, 4)) AS Saldo '#13#10 +
    'FROM ' +
    '  ac_entry e  ' +
    '  JOIN ac_quantity q ON e.id = q.entrykey AND q.valuekey IN (' + IDValues + ')' +
    GetJoinTableClause('e');

  if FCorrAccounts.Count > 0 then
    FIBDSSaldoQuantityBegin.SelectSQL.Text := FIBDSSaldoQuantityBegin.SelectSQL.Text +
      ' JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.accountpart <> e.accountpart ';
  FIBDSSaldoQuantityBegin.SelectSQL.Text := FIBDSSaldoQuantityBegin.SelectSQL.Text + ' WHERE ' + AccWhere +
    '   e.entrydate < :begindate AND ' + CompanyS;
  if FCurrSumInfo.Show and (FCurrkey > 0) then
    FIBDSSaldoQuantityBegin.SelectSQL.Text := FIBDSSaldoQuantityBegin.SelectSQL.Text + ' AND e.currkey = ' + IntToStr(FCurrkey);
  if EntryCondition <> '' then
    FIBDSSaldoQuantityBegin.SelectSQL.Text := FIBDSSaldoQuantityBegin.SelectSQL.Text + ' AND ' + EntryCondition;
  FIBDSSaldoQuantityBegin.ParamByName(BeginDate).AsDateTime := FDateBegin;
  //FIBDSSaldoQuantityBegin.Open;

  if FIBDSSaldoQuantityEnd.Active then
    FIBDSSaldoQuantityEnd.Close;
  FIBDSSaldoQuantityEnd.SelectSQL.Text := FIBDSSaldoQuantityBegin.SelectSQL.Text;
  FIBDSSaldoQuantityEnd.ParamByName(BeginDate).AsDateTime := FDateEnd;
  //FIBDSSaldoQuantityEnd.Open;


  if not FDoGroup then
  begin
    // Запрос в случае отсутствия группировки записей
    Self.SelectSQL.Text := Format(
    'SELECT '#13#10 +
    '  e.recordkey as id,'#13#10 +
    '  doc.number,'#13#10 +
    '  doc.editiondate,'#13#10 +
    '  e.entrydate,'#13#10 +
    '  CAST(IIF(e1.issimple = 0, e1.creditncu, e.debitncu) / %0:d AS NUMERIC(15, %1:d)) AS NCU_DEBIT,'#13#10 +
    '  CAST(IIF(e1.issimple = 0, e1.debitncu, e.creditncu) / %0:d AS NUMERIC(15, %1:d)) AS NCU_CREDIT, '#13#10 +
    IIF(FCurrSumInfo.Show and (FCurrkey > 0),
      '  CAST(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.debitcurr, e1.creditcurr), e.debitcurr) / %2:d AS NUMERIC(15, %3:d)) AS CURR_DEBIT,'#13#10 +
      '  CAST(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.creditcurr, e1.debitcurr), e.creditcurr) / %2:d AS NUMERIC(15, %3:d)) AS CURR_CREDIT,',
      '  CAST(IIF(e1.issimple = 0, e1.creditcurr, e.debitcurr) / %2:d AS NUMERIC(15, %3:d)) AS CURR_DEBIT,'#13#10 +
      '  CAST(IIF(e1.issimple = 0, e1.debitcurr, e.creditcurr) / %2:d AS NUMERIC(15, %3:d)) AS CURR_CREDIT,')  + #13#10 +
    '  CAST(IIF(e1.issimple = 0, e1.crediteq, e.debiteq) / %4:d AS NUMERIC(15, %5:d)) AS EQ_DEBIT,'#13#10 +
    '  CAST(IIF(e1.issimple = 0, e1.debiteq, e.crediteq) / %4:d AS NUMERIC(15, %5:d)) AS EQ_CREDIT,'#13#10 +
    '  a.alias, '#13#10 +
    '  corr_a.alias AS corralias,'#13#10 + ASelect + ACorrSelect +
    '  curr.ShortName as CurrencyName,'#13#10 +
    '  doct.name,'#13#10 +
    '  t.Name as TransactionName, '#13#10 +
    '  r.description, '#13#10 +
    '  e.documentkey, '#13#10 +
    '  e.transactionkey, '#13#10 +
    '  tr.description as trrecordname ' +
    ValueSelect + #13#10 +
    ' FROM ac_entry e  '#13#10 +
    '  LEFT JOIN gd_document doc ON e.documentkey = doc.id '#13#10 +
    '  LEFT JOIN gd_documenttype doct ON doc.documenttypekey = doct.id '#13#10 +
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
    '  LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
    '  LEFT JOIN ac_trrecord tr ON r.trrecordkey = tr.id'#13#10 +
    GetJoinTableClause('e') +
    ValueJoin + #13#10 + AFrom + ACorrFrom + #13#10 +
    ' WHERE '#13#10 + AccWhere +
    '  ' + CompanyS + ' AND '#13#10 +
    IIF(Trim(AccWhereQuantity) > '', '  (' + AccWhereQuantity + ') AND'#13#10, '') +
    '  e.entrydate >= :begindate AND e.entrydate <= :enddate '#13#10 +
      IIF(EntryCondition <> '', ' AND ' + EntryCondition, '') +
    Self.InternalMovementClause,
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits,
      FCurrSumInfo.Scale, FCurrSumInfo.DecDigits,
      FEQSumInfo.Scale, FEQSumInfo.DecDigits]);

    if FCurrSumInfo.Show and (FCurrkey > 0) then
      Self.SelectSQL.Text := Self.SelectSQL.Text + ' AND e.currkey = ' + IntToStr(FCurrkey);

    if FCorrAccounts.Count > 0 then
    begin
      if FCorrDebit then
        Self.SelectSQL.Text := Self.SelectSQL.Text + ' AND e1.accountkey IN (' + IDList(FCorrAccounts) +
          ') AND e1.accountpart = ''D'''
      else
        Self.SelectSQL.Text := Self.SelectSQL.Text + ' AND e1.accountkey IN (' + IDList(FCorrAccounts) +
          ') AND e1.accountpart = ''C''';
    end;
  end
  else
  begin
    // Запрос в случае группировки записей
    Self.SelectSQL.Text :=
    'SELECT'#13#10 + Format(
    '  MAX(e.recordkey) AS ID,'#13#10 +
    '  doc.number,'#13#10 +
    '  doc.editiondate,'#13#10 +
    '  e.entrydate, '#13#10 +
    '  CAST(SUM(IIF(e1.issimple = 0, e1.creditncu, e.debitncu)) / %0:d AS NUMERIC(15, %1:d)) AS NCU_DEBIT,'#13#10 +
    '  CAST(SUM(IIF(e1.issimple = 0, e1.debitncu, e.creditncu)) / %0:d AS NUMERIC(15, %1:d)) AS NCU_CREDIT, '#13#10 +
    IIF(FCurrSumInfo.Show and (FCurrkey > 0),
      '  CAST(SUM(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.debitcurr, e1.creditcurr), e.debitcurr)) / %2:d AS NUMERIC(15, %3:d)) AS CURR_DEBIT,'#13#10 +
      '  CAST(SUM(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.creditcurr, e1.debitcurr), e.creditcurr)) / %2:d AS NUMERIC(15, %3:d)) AS CURR_CREDIT,',
      '  CAST(SUM(IIF(e1.issimple = 0, e1.creditcurr, e.debitcurr)) / %2:d AS NUMERIC(15, %3:d)) AS CURR_DEBIT,'#13#10 +
      '  CAST(SUM(IIF(e1.issimple = 0, e1.debitcurr, e.creditcurr)) / %2:d AS NUMERIC(15, %3:d)) AS CURR_CREDIT,')  + #13#10 +
    '  CAST(SUM(IIF(e1.issimple = 0, e1.crediteq, e.debiteq)) / %4:d AS NUMERIC(15, %5:d)) AS EQ_DEBIT,'#13#10 +
    '  CAST(SUM(IIF(e1.issimple = 0, e1.debiteq, e.crediteq)) / %4:d AS NUMERIC(15, %5:d)) AS EQ_CREDIT,'#13#10 +
    '  a.alias, '#13#10 +
    '  corr_a.alias AS corralias,'#13#10 + ASelect + ACorrSelect +
    '  curr.ShortName as CurrencyName,'#13#10 +
    '  doct.name,'#13#10 +
    '  t.Name as TransactionName, '#13#10 +
    '  r.description, '#13#10 +
    '  e.masterdockey, '#13#10 +
    '  e.transactionkey, '#13#10 +
    '  tr.description as trrecordname ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits,
      FCurrSumInfo.Scale, FCurrSumInfo.DecDigits,
      FEQSumInfo.Scale, FEQSumInfo.DecDigits]) +
    ValueSelect + #13#10 +
    ' FROM ac_entry e  '#13#10 +
    '  LEFT JOIN gd_document doc ON e.masterdockey = doc.id '#13#10 +
    '  LEFT JOIN gd_documenttype doct ON doc.documenttypekey = doct.id '#13#10 +
    '  LEFT JOIN ac_entry e1 ON e.recordkey = e1.recordkey AND e.accountpart <> e1.accountpart '#13#10 +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        ' AND 1 = IIF(e1.issimple = 0 and e1.currkey <> e.currkey and e1.debitcurr = 0 and e1.creditcurr = 0, 0, 1)'#13#10 , '') +
    '  LEFT JOIN ac_account a ON e.accountkey = a.id '#13#10 +
    '  LEFT JOIN gd_curr curr ON curr.id = ' +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        'IIF(e1.issimple = 0 and e.currkey <> e1.currkey and e1.debitcurr = 0 and e1.creditcurr = 0, e1.currkey, e.currkey)',
        'e.currkey ') + #13#10 +
    '  LEFT JOIN ac_transaction t ON e.transactionkey = t.id '#13#10 +
    '  LEFT JOIN ac_account corr_a ON e1.accountkey = corr_a.id '#13#10 +
    '  LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
    '  LEFT JOIN ac_trrecord tr ON r.trrecordkey = tr.id '#13#10 +
      ValueJoin + #13#10 + AFrom + ACorrFrom +
      GetJoinTableClause('e') +
    ' WHERE '#13#10 + AccWhere +
    '  ' + CompanyS + ' AND '#13#10 +
    '  e.entrydate >= :begindate AND e.entrydate <= :enddate '#13#10 +
      IIF(EntryCondition <> '', ' AND ' + EntryCondition, '') +
      Self.InternalMovementClause +
      IIF(FCurrSumInfo.Show and (FCurrkey > 0),
        ' AND e.currkey = ' + IntToStr(FCurrkey), '') +
    ' GROUP BY doc.number, doc.editiondate, e.entrydate, doct.name, a.alias, corr_a.alias, '#13#10 +
    '   r.description, doc.parent, '#13#10 +
    '   curr.ShortName, e.transactionkey, t.Name, tr.description, e.masterdockey ' + AGroup + ACorrGroup + #13#10 +
    ' HAVING '#13#10+
    '   SUM(IIF(e1.issimple = 0, e1.creditncu, e.debitncu)) <> 0 OR'#13#10 +
    '   SUM(IIF(e1.issimple = 0, e1.debitncu, e.creditncu)) <> 0 OR'#13#10 +
    IIF(FCurrSumInfo.Show and (FCurrkey > 0),
      '  SUM(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.debitcurr, e1.creditcurr), e.debitcurr)) <> 0 OR'#13#10 +
      '  SUM(IIF(e1.issimple = 0, IIF(e.currkey <> e1.currkey, e.creditcurr, e1.debitcurr), e.creditcurr)) <> 0 OR '#13#10,
      '  SUM(IIF(e1.issimple = 0, e1.creditcurr, e.debitcurr)) <> 0 OR '#13#10 +
      '  SUM(IIF(e1.issimple = 0, e1.debitcurr, e.creditcurr)) <> 0 OR '#13#10) +
    '  SUM(IIF(e1.issimple = 0, e1.crediteq, e.debiteq)) <> 0 OR '#13#10 +
    '  SUM(IIF(e1.issimple = 0, e1.debiteq, e.crediteq)) <> 0';
  end;

  Self.SelectSQL.Text := Self.SelectSQL.Text +
    'ORDER BY e.entrydate, doc.number, a.alias, corr_a.alias';
end;

procedure TgdvAcctAccCard.SetDefaultParams;
begin
  inherited;

  FDoGroup := False;
end;

procedure TgdvAcctAccCard.DoEmptySQL;
var
  I: Integer;
  SQLText: String;
begin
  SQLText := '';

  for I := 0 to AccCardAdditionalFieldCount - 1 do
  begin
    if SQLText > '' then
      SQLText := SQLText + ', '#13#10;
    SQLText := SQLText + Format('CAST(NULL AS NUMERIC(15, 4)) AS %s', [AccCardAdditionalFieldList[I].FieldName]);
  end;

  for I := 0 to BaseAcctFieldCount - 1 do
  begin
    if SQLText > '' then
      SQLText := SQLText + ', '#13#10;
    SQLText := SQLText + Format('CAST(NULL AS NUMERIC(15, 4)) AS %s', [BaseAcctFieldList[I].FieldName]);
  end;
  SQLText := 'SELECT ' + SQLText + ', CAST(NULL AS VARCHAR(180)) AS NAME FROM rdb$database WHERE RDB$CHARACTER_SET_NAME = ''_''';

  // Заглушка для отчетов которые не проверяют состояние датасета, а сразу пытаются обратится к параметрам запроса
  SQLText := SQLText + ' AND ((:begindate > CAST(''17.11.1858'' AS DATE)) OR (1 = 1)) ' +
    ' AND ((:enddate > CAST(''17.11.1858'' AS DATE)) OR (1 = 1)) ';

  Self.SelectSQL.Text := SQLText;
end;

procedure TgdvAcctAccCard.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
  S: TStrings;
  Value: string;
  I: Integer;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
    S := TStringList.Create;
    try
      S.Text := C.CorrAccountsRUIDList;
      for I := 0 to S.Count - 1 do
        AddCorrAccount(gdcBaseManager.GetIDByRUIDString(Trim(S.Strings[I])));
      FCorrDebit := C.AccountPart = 'D';
      FWithSubAccounts := C.IncCorrSubAccounts;
      FDoGroup := C.Group;

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

procedure TgdvAcctAccCard.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
  StringList: TStringList;
  I: Integer;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
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
    C.IncCorrSubAccounts := FWithCorrSubAccounts;
    C.Group := FDoGroup;
  end;
end;

class function TgdvAcctAccCard.ConfigClassName: string;
begin
  Result := 'TAccCardConfig'; 
end;

procedure TgdvAcctAccCard.DoBeforeBuildReport;
begin
  inherited;
  if FIBDSSaldoQuantityBegin.Active then
    FIBDSSaldoQuantityBegin.Close;
  if FIBDSSaldoQuantityEnd.Active then
    FIBDSSaldoQuantityEnd.Close;
  FIBDSSaldoQuantityBegin.Transaction := gdcBaseManager.ReadTransaction;
  FIBDSSaldoQuantityEnd.Transaction := gdcBaseManager.ReadTransaction;
end;

end.
