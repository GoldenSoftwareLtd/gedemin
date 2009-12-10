unit gdvAcctGeneralLedger;

interface

uses
  classes, gd_ClassList, gd_KeyAssoc, AcctStrings, AcctUtils, gdvAcctLedger,
  gdv_AcctConfig_unit;

type
  TgdvAcctGeneralLedger = class(TgdvAcctLedger)
  protected
    procedure FillSubAccounts(var AccountArray: TgdKeyArray); override;

    function LargeSQLErrorMessage: String; override;

    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;

    procedure DoBeforeBuildReport; override;
    procedure DoBuildSQL; override;
  end;

procedure Register;

implementation

uses
  ibsql, gdvAcctBase, gdcBaseInterface, sysutils, gdcConstants;

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctGeneralLedger]);
end;

{ TgdvAcctGeneralLedger }

class function TgdvAcctGeneralLedger.ConfigClassName: string;
begin
  Result := 'TAccGeneralLedgerConfig';
end;

procedure TgdvAcctGeneralLedger.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  if Config is TAccGeneralLedgerConfig then
  begin
    C := Config as TAccGeneralLedgerConfig;
    FShowDebit := C.ShowDebit;
    FShowCredit := C.ShowCredit;
    FShowCorrSubAccounts := C.ShowCorrSubAccounts;
  end;
end;

procedure TgdvAcctGeneralLedger.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  if Config is TAccGeneralLedgerConfig then
  begin
    C := Config as TAccGeneralLedgerConfig;
    C.ShowDebit := FShowDebit;
    C.ShowCredit := FShowCredit;
    C.ShowCorrSubAccounts := FShowCorrSubAccounts;
  end;
end;

procedure TgdvAcctGeneralLedger.DoBeforeBuildReport;
begin
  // Установим в True, чтобы в TgdvAcctBase.DoBeforeBuildReport
  //   вызвалась функция FillSubAccounts
  FWithSubAccounts := True;
  inherited;
end;

procedure TgdvAcctGeneralLedger.DoBuildSQL;
var
  K, I: Integer;
  SQL: TIBSQL;
  FI: TgdvFieldInfo;
  DebitStrings, CreditStrings: TgdvCorrFieldInfoList;
  Accounts: TStringList;
  AnalyticField: string;
  DebitCreditSQL: string;
  QuantitySelectClause, SelectClause, FromClause, FromClause1, GroupClause, OrderClause: string;
  IDSelect, NameSelect, WhereClause, QuantityGroup: String;
  CurrId: string;
  NcuDecDig, CurrDecDig, EQDecDig: String;
  ValueAlias, QuantityAlias: String;
  VKeyAlias: string;
  L_S, Q_S, QS: string;
  AccountIDs: String;
  CorrSelect, CorrSubSelect, CorrInto: String;

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

  procedure FillQueryWithCorrAccounts(AAccounts: TStrings; EntryPart: String);
  var
    I, J: Integer;
  begin
    if FShowCorrSubAccounts then
    begin
      for I := 0 to AAccounts.Count - 1 do
      begin
        CorrSelect := CorrSelect + Format(', SUM(m.%0:s) AS %0:s ', [AAccounts.Names[I]]);
        CorrInto := CorrInto + ', :' + AAccounts.Names[I];
        if EntryPart = 'D' then
          CorrSubSelect := CorrSubSelect +
            Format(', IIF(emc.accountkey = %0:s, IIF(emc.issimple = 0, emc.creditncu, e.debitncu), 0) AS %1:s '#13#10,
            [Accounts.Values[AAccounts.Names[I]], AAccounts.Names[I]])
        else
          CorrSubSelect := CorrSubSelect +
            Format(', IIF(emc.accountkey = %0:s, IIF(emc.issimple = 0, emc.debitncu, e.creditncu), 0) AS %1:s '#13#10,
            [Accounts.Values[AAccounts.Names[I]], AAccounts.Names[I]]);
      end;
    end
    else
    begin
      for I := 0 to AAccounts.Count - 1 do
      begin
        CorrSelect := CorrSelect + Format(', SUM(m.%0:s) AS %0:s ', [AAccounts.Strings[I]]);
        CorrInto := CorrInto + ', :' + AAccounts.Strings[I];
        CorrSubSelect := CorrSubSelect + ', IIF(emc.accountkey IN (';
        for J := 0 to TgdKeyArray(AAccounts.Objects[I]).Count - 1 do
        begin
          CorrSubSelect := CorrSubSelect + IntToStr(TgdKeyArray(AAccounts.Objects[I]).Keys[J]);
          if J <> TgdKeyArray(AAccounts.Objects[I]).Count - 1 then
            CorrSubSelect := CorrSubSelect + ', ';
        end;
        if EntryPart = 'D' then
          CorrSubSelect := CorrSubSelect + '), IIF(emc.issimple = 0, emc.creditncu, e.debitncu), 0) AS ' + AAccounts.Strings[I] + #13#10
        else
          CorrSubSelect := CorrSubSelect + '), IIF(emc.issimple = 0, emc.debitncu, e.creditncu), 0) AS ' + AAccounts.Strings[I] + #13#10;
      end;
    end;
  end;

begin
  if FEnchancedSaldo then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT f.fieldname FROM ac_account a LEFT JOIN ' +
        ' at_relation_fields f ON a.analyticalfield = f.id WHERE a.id = :id ';
      SQL.ParamByName('id').AsInteger := FAccounts.Keys[0];
      SQL.ExecQuery;
      AnalyticField := SQL.FieldByName('fieldname').AsString;
    finally
      SQL.Free;
    end;
  end
  else
  begin
    AnalyticField := '';
  end;

  if Assigned(FFieldInfos) then
  begin
    FI := FFieldInfos.AddInfo;
    FI.FieldName := 'M';
    FI.Caption := 'Месяц';
    FI.Visible := fvVisible;
    FI.Condition := False;

    FI := FFieldInfos.AddInfo;
    FI.FieldName := 'Y';
    FI.Caption := 'Год';
    FI.Visible := fvVisible;
    FI.Condition := False;
  end;  

  if FUseEntryBalance and (FAcctValues.Count = 0) then
  begin
    AccountIDs := IDList(FAccounts); 

    Accounts := TStringList.Create;
    try
      // Дебетовые корреспондирующие счета
      if FShowDebit then
      begin
        DebitStrings := TgdvCorrFieldInfoList.Create;
        try
          CorrAccounts(DebitStrings, 'D');
          if DebitStrings.Count > 0 then
          begin
            if FNcuSumInfo.Show then
              FillCorrAccountStrings(Accounts, DebitStrings, 'debit', 'ncu');
            if FCurrSumInfo.Show then
              FillCorrAccountStrings(Accounts, DebitStrings, 'debit', 'curr');
            if FEQSumInfo.Show then
              FillCorrAccountStrings(Accounts, DebitStrings, 'debit', 'eq');
          end;
          FillQueryWithCorrAccounts(Accounts, 'D');

          for I := 0 to Accounts.Count - 1 do
            if Assigned(Accounts.Objects[I]) then
              Accounts.Objects[I].Free;
          Accounts.Clear;   
        finally
          DebitStrings.Free;
        end;
      end;

      // Кредитовые корреспондирующие счета
      if FShowCredit then
      begin
        CreditStrings := TgdvCorrFieldInfoList.Create;
        try
          CorrAccounts(CreditStrings, 'C');
          if CreditStrings.Count > 0 then
          begin
            if FNcuSumInfo.Show then
              FillCorrAccountStrings(Accounts, CreditStrings, 'credit', 'ncu');
            if FCurrSumInfo.Show then
              FillCorrAccountStrings(Accounts, CreditStrings, 'credit', 'curr');
            if FEQSumInfo.Show then
              FillCorrAccountStrings(Accounts, CreditStrings, 'credit', 'eq');
          end;
          FillQueryWithCorrAccounts(Accounts, 'C');
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
      'EXECUTE BLOCK ( '#13#10 +
      '    datebegin DATE = :BEGINDATE, '#13#10 +
      '    dateend DATE = :ENDDATE) '#13#10 +
      'RETURNS ( '#13#10 +
      '    M INTEGER, '#13#10 +
      '    Y INTEGER, '#13#10 +
      '    NCU_BEGIN_DEBIT NUMERIC(15, %1:d), '#13#10 +
      '    NCU_BEGIN_CREDIT NUMERIC(15, %1:d), '#13#10 +
        GetDebitSumSelectClauseBalance +                                // Расшифровка по дебету NCU
      '    NCU_DEBIT NUMERIC(15, %1:d), '#13#10 +
        GetCreditSumSelectClauseBalance +                              // Расшифровка по кредиту NCU
      '    NCU_CREDIT NUMERIC(15, %1:d), '#13#10 +
      '    NCU_END_DEBIT NUMERIC(15, %1:d), '#13#10 +
      '    NCU_END_CREDIT NUMERIC(15, %1:d), '#13#10 +
      '    CURR_BEGIN_DEBIT NUMERIC(15, %3:d), '#13#10 +
      '    CURR_BEGIN_CREDIT NUMERIC(15, %3:d), '#13#10 +
        GetDebitCurrSumSelectClauseBalance +                              // Расшифровка по дебету CURR
      '    CURR_DEBIT NUMERIC(15, %3:d), '#13#10 +
        GetCreditCurrSumSelectClauseBalance +                               // Расшифровка по кредиту CURR
      '    CURR_CREDIT NUMERIC(15, %3:d), '#13#10 +
      '    CURR_END_DEBIT NUMERIC(15, %3:d), '#13#10 +
      '    CURR_END_CREDIT NUMERIC(15, %3:d), '#13#10 +
      '    EQ_BEGIN_DEBIT NUMERIC(15, %5:d), '#13#10 +
      '    EQ_BEGIN_CREDIT NUMERIC(15, %5:d), '#13#10 +
        GetDebitEQSumSelectClauseBalance +                             // Расшифровка по дебету EQ
      '    EQ_DEBIT NUMERIC(15, %5:d), '#13#10 +
        GetCreditEQSumSelectClauseBalance +                               // Расшифровка по кредиту EQ
      '    EQ_CREDIT NUMERIC(15, %5:d), '#13#10 +
      '    EQ_END_DEBIT NUMERIC(15, %5:d), '#13#10 +
      '    EQ_END_CREDIT NUMERIC(15, %5:d), '#13#10 +
      '    SORTFIELD INTEGER) '#13#10 +
      'AS '#13#10 +
      'DECLARE VARIABLE saldobegindebit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldobegincredit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoenddebit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoendcredit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldobegindebitcurr NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldobegincreditcurr NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoenddebitcurr NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoendcreditcurr NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldobegindebiteq NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldobegincrediteq NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoenddebiteq NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE saldoendcrediteq NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE varncudebit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE varncucredit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE varcurrdebit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE varcurrcredit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE vareqdebit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE vareqcredit NUMERIC(18,6); '#13#10 +
      'DECLARE VARIABLE c INTEGER; '#13#10 +
      'DECLARE VARIABLE accountkey INTEGER; '#13#10 +
      'DECLARE VARIABLE closedate DATE; '#13#10 +
      'DECLARE VARIABLE abegindate DATE; '#13#10 +
      'DECLARE VARIABLE aenddate DATE; '#13#10 +
      'BEGIN '#13#10 +
      '  closedate = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10;

    if AnalyticField = '' then
    begin
      DebitCreditSQL := DebitCreditSQL +
        '  SELECT '#13#10 +
        '    COALESCE(SUM(m.debitncu), 0) AS debitncu, '#13#10 +
        '    COALESCE(SUM(m.creditncu), 0) AS creditncu, '#13#10 +
        '    COALESCE(SUM(m.debitcurr), 0) AS debitcurr, '#13#10 +
        '    COALESCE(SUM(m.creditcurr), 0) AS creditcurr, '#13#10 +
        '    COALESCE(SUM(m.debiteq), 0) AS debiteq, '#13#10 +
        '    COALESCE(SUM(m.crediteq), 0) AS crediteq '#13#10 +
        '  FROM '#13#10 +
        '  ( '#13#10 +
        '    SELECT '#13#10 +
        '      bal.debitncu, '#13#10 +
        '      bal.creditncu, '#13#10 +
        '      bal.debitcurr, '#13#10 +
        '      bal.creditcurr, '#13#10 +
        '      bal.debiteq, '#13#10 +
        '      bal.crediteq '#13#10 +
        '    FROM '#13#10 +
        '      ac_entry_balance bal '#13#10 +
        '    WHERE '#13#10 +
        '      bal.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
        '      AND bal.accountkey IN (' + AccountIDs + ') '#13#10 +
          IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND bal.currkey = ' + IntToStr(FCurrKey) + #13#10, '') +
        ' '#13#10 +
        '    UNION ALL '#13#10 +
        ' '#13#10 +
        '    SELECT '#13#10 +
          IIF(FDateBegin >= FEntryBalanceDate,
            '      e.debitncu, '#13#10 +
            '      e.creditncu, '#13#10 +
            '      e.debitcurr, '#13#10 +
            '      e.creditcurr, '#13#10 +
            '      e.debiteq, '#13#10 +
            '      e.crediteq '#13#10,
            '    - e.debitncu, '#13#10 +
            '    - e.creditncu, '#13#10 +
            '    - e.debitcurr, '#13#10 +
            '    - e.creditcurr, '#13#10 +
            '    - e.debiteq, '#13#10 +
            '    - e.crediteq '#13#10) +
        '    FROM '#13#10 +
        '      ac_entry e '#13#10 +
        '    WHERE '#13#10 +
          IIF(FDateBegin >= FEntryBalanceDate,
            '      e.entrydate >= :closedate '#13#10 +
            '      AND e.entrydate < :datebegin '#13#10,
            '      e.entrydate >= :datebegin '#13#10 +
            '      AND e.entrydate < :closedate '#13#10) +
        '      AND e.accountkey IN (' + AccountIDs + ') '#13#10 +
        '      AND e.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
          IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND e.currkey = ' + IntToStr(FCurrKey) + #13#10, '') +
        '  ) m '#13#10 +
        '  INTO :saldobegindebit, '#13#10 +
        '       :saldobegincredit, '#13#10 +
        '       :saldobegindebitcurr, '#13#10 +
        '       :saldobegincreditcurr, '#13#10 +
        '       :saldobegindebiteq, '#13#10 +
        '       :saldobegincrediteq; '#13#10;
    end
    else
    begin
      DebitCreditSQL := DebitCreditSQL +
        Format(
          '  saldobegindebit = 0; '#13#10 +
          '  saldobegincredit = 0; '#13#10 +
          '  saldobegindebitcurr = 0; '#13#10 +
          '  saldobegincreditcurr = 0; '#13#10 +
          '    FOR '#13#10 +
          '      SELECT '#13#10 +
          '        la.accountkey '#13#10 +
          '      FROM '#13#10 +
          '        ac_ledger_accounts la '#13#10 +
          '      WHERE '#13#10 +
          '        la.sqlhandle = %0:d '#13#10 +
          '      INTO :accountkey '#13#10 +
          '    DO '#13#10 +
          '    BEGIN '#13#10 +
          '      SELECT '#13#10 +
          '        COALESCE(a.debitsaldo, 0), '#13#10 +                       
          '        COALESCE(a.creditsaldo, 0), '#13#10 +
          '        COALESCE(a.currdebitsaldo, 0), '#13#10 +
          '        COALESCE(a.currcreditsaldo, 0), '#13#10 +
          '        COALESCE(a.eqdebitsaldo, 0), '#13#10 +
          '        COALESCE(a.eqcreditsaldo, 0) '#13#10 +
          '      FROM '#13#10 +
          '        ac_accountexsaldo_bal(:datebegin, :accountkey, ''%1:s'', %2:d, %3:d, -1, %4:d) a '#13#10 +
          '      INTO :varncudebit, '#13#10 +
          '           :varncucredit, '#13#10 +
          '           :varcurrdebit, '#13#10 +
          '           :varcurrcredit, '#13#10 +
          '           :vareqdebit, '#13#10 +
          '           :vareqcredit; '#13#10 +
          '  '#13#10 +
          '      saldobegindebit = :saldobegindebit + :varncudebit; '#13#10 +
          '      saldobegincredit = :saldobegincredit + :varncucredit; '#13#10 +
          '      saldobegindebitcurr = :saldobegindebitcurr + :varcurrdebit; '#13#10 +
          '      saldobegincreditcurr = :saldobegincreditcurr + :varcurrcredit; '#13#10 +
          '      saldobegindebiteq = :saldobegindebiteq + :vareqdebit; '#13#10 +
          '      saldobegincrediteq = :saldobegincrediteq + :vareqcredit; '#13#10 +
          '    END '#13#10,
          [FSQLhandle, AnalyticField, FCompanyKey, Integer(FAllHolding), FCurrKey]);
    end;

    DebitCreditSQL := DebitCreditSQL +
      '  c = 0; '#13#10 +
      '  FOR '#13#10 +
      '    SELECT '#13#10 +
      '      EXTRACT(MONTH FROM m.entrydate) AS m, '#13#10 +
      '      EXTRACT(YEAR FROM m.entrydate) AS y, '#13#10 +
      '      SUM(m.debitncu), '#13#10 +
      '      SUM(m.creditncu), '#13#10 +
      '      SUM(m.debitcurr), '#13#10 +
      '      SUM(m.creditcurr), '#13#10 +
      '      SUM(m.debiteq), '#13#10 +
      '      SUM(m.crediteq) '#13#10 +
        CorrSelect +
      '    FROM '#13#10 +
      '    ( '#13#10 +
      '      SELECT '#13#10 +
      '        e.entrydate, '#13#10 +
      '        IIF(emc.issimple = 0, emc.creditncu, e.debitncu) AS debitncu, '#13#10 +
      '        IIF(emc.issimple = 0, emc.debitncu, e.creditncu) AS creditncu, '#13#10 +
      '        IIF(emc.issimple = 0, emc.creditcurr, e.debitcurr) AS debitcurr, '#13#10 +
      '        IIF(emc.issimple = 0, emc.debitcurr, e.creditcurr) AS creditcurr, '#13#10 +
      '        IIF(emc.issimple = 0, emc.crediteq, e.debiteq) AS debiteq, '#13#10 +
      '        IIF(emc.issimple = 0, emc.debiteq, e.crediteq) AS crediteq '#13#10 +
        CorrSubSelect +
      '      FROM '#13#10 +
      '        ac_entry e '#13#10 +
      '        LEFT JOIN ac_entry emc ON emc.recordkey = e.recordkey AND emc.accountpart <> e.accountpart '#13#10 +
      '      WHERE '#13#10 +
      '        e.entrydate <= :dateend AND e.entrydate >= :datebegin '#13#10 +
      '        AND e.accountkey IN (' + AccountIDs + ') '#13#10 +
      '        AND e.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
        IIF(not FIncludeInternalMovement, InternalMovementClause('e') + #13#10, '') +
      '    ) m '#13#10 +
      '    GROUP BY 1, 2 '#13#10 +
      '    ORDER BY 2, 1 '#13#10 +
      '    INTO '#13#10 +
      '      :m, :y, '#13#10 +
      '      :varncudebit, '#13#10 +
      '      :varncucredit, '#13#10 +
      '      :varcurrdebit, '#13#10 +
      '      :varcurrcredit, '#13#10 +
      '      :vareqdebit, '#13#10 +
      '      :vareqcredit '#13#10 +
        CorrInto +
      '  DO '#13#10 +
      '  BEGIN '#13#10 +
      '    ncu_debit = CAST(:varncudebit / %0:d AS NUMERIC(15, %1:d));  '#13#10 +
      '    ncu_credit = CAST(:varncucredit / %0:d AS NUMERIC(15, %1:d)); '#13#10 +
      '    curr_debit = CAST(:varcurrdebit / %2:d AS NUMERIC(15, %3:d)); '#13#10 +
      '    curr_credit = CAST(:varcurrcredit / %2:d AS NUMERIC(15, %3:d)); '#13#10 +
      '    eq_debit = CAST(:vareqdebit / %4:d AS NUMERIC(15, %5:d)); '#13#10 +
      '    eq_credit = CAST(:vareqcredit / %4:d AS NUMERIC(15, %5:d)); '#13#10 +
      ' '#13#10 +
      '    ncu_begin_debit = 0;  '#13#10 +
      '    ncu_begin_credit = 0;  '#13#10 +
      '    ncu_end_debit = 0;  '#13#10 +
      '    ncu_end_credit = 0;  '#13#10 +
      '    curr_begin_debit = 0;  '#13#10 +
      '    curr_begin_credit = 0;  '#13#10 +
      '    curr_end_debit = 0;  '#13#10 +
      '    curr_end_credit = 0;  '#13#10 +
      '    eq_begin_debit = 0;  '#13#10 +
      '    eq_begin_credit = 0;  '#13#10 +
      '    eq_end_debit = 0;  '#13#10 +
      '    eq_end_credit = 0;  '#13#10;

    if AnalyticField = '' then
    begin
      DebitCreditSQL := DebitCreditSQL +
        '    /* сальдо на начало */ '#13#10 +
        '    IF (:saldobegindebit - :saldobegincredit > 0) THEN  '#13#10 +
        '    BEGIN  '#13#10 +
        '      ncu_begin_debit = CAST((:saldobegindebit - :saldobegincredit) / %0:d AS NUMERIC(15, %1:d));  '#13#10 +
        '      ncu_begin_credit = 0;  '#13#10 +
        '    END  '#13#10 +
        '    ELSE  '#13#10 +
        '    BEGIN  '#13#10 +
        '      ncu_begin_debit = 0;  '#13#10 +
        '      ncu_begin_credit = CAST(- (:saldobegindebit - :saldobegincredit) / %0:d AS NUMERIC(15, %1:d));  '#13#10 +
        '    END  '#13#10 +
        ' '#13#10 +
        '    IF (:saldobegindebitcurr - :saldobegincreditcurr > 0) THEN  '#13#10 +
        '    BEGIN  '#13#10 +
        '      curr_begin_debit = CAST((:saldobegindebitcurr - :saldobegincreditcurr) / %2:d AS NUMERIC(15, %3:d));  '#13#10 +
        '      curr_begin_credit = 0;  '#13#10 +
        '    END  '#13#10 +
        '    ELSE  '#13#10 +
        '    BEGIN  '#13#10 +
        '      curr_begin_debit = 0;  '#13#10 +
        '      curr_begin_credit = CAST(- (:saldobegindebitcurr - :saldobegincreditcurr) / %2:d AS NUMERIC(15, %3:d));  '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    IF (:saldobegindebiteq - :saldobegincrediteq > 0) THEN  '#13#10 +
        '    BEGIN  '#13#10 +
        '      eq_begin_debit = CAST((:saldobegindebiteq - :saldobegincrediteq) / %4:d AS NUMERIC(15, %5:d));  '#13#10 +
        '      eq_begin_credit = 0;  '#13#10 +
        '    END  '#13#10 +
        '    ELSE  '#13#10 +
        '    BEGIN  '#13#10 +
        '      eq_begin_debit = 0;  '#13#10 +
        '      eq_begin_credit = CAST(- (:saldobegindebiteq - :saldobegincrediteq) / %4:d AS NUMERIC(15, %5:d));  '#13#10 +
        '    END '#13#10;
    end
    else
    begin
      DebitCreditSQL := DebitCreditSQL +
        Format(
          '    saldoenddebit = 0; '#13#10 +
          '    saldoendcredit = 0; '#13#10 +
          '    saldoenddebitcurr = 0; '#13#10 +
          '    saldoendcreditcurr = 0; '#13#10 +
          '    saldoenddebiteq = 0; '#13#10 +
          '    saldoendcrediteq = 0; '#13#10 +
          '  '#13#10 +
          '    FOR '#13#10 +
          '      SELECT '#13#10 +
          '        la.accountkey '#13#10 +
          '      FROM '#13#10 +
          '        ac_ledger_accounts la '#13#10 +
          '      WHERE '#13#10 +
          '        la.sqlhandle = %0:d '#13#10 +
          '      INTO :accountkey '#13#10 +
          '    DO '#13#10 +
          '    BEGIN '#13#10 +
          '  '#13#10 +
          '      SELECT '#13#10 +
          '        COALESCE(a.debitsaldo, 0), '#13#10 +
          '        COALESCE(a.creditsaldo, 0), '#13#10 +
          '        COALESCE(a.currdebitsaldo, 0), '#13#10 +
          '        COALESCE(a.currcreditsaldo, 0), '#13#10 +
          '        COALESCE(a.eqdebitsaldo, 0), '#13#10 +
          '        COALESCE(a.eqcreditsaldo, 0) '#13#10 +
          '      FROM '#13#10 +
          '        ac_accountexsaldo_bal(:aenddate, :accountkey, ''%1:s'', %2:d, %3:d, -1, %4:d) a '#13#10 +
          '      INTO :varncudebit, '#13#10 +
          '           :varncucredit, '#13#10 +
          '           :varcurrdebit, '#13#10 +
          '           :varcurrcredit, '#13#10 +
          '           :vareqdebit, '#13#10 +
          '           :vareqcredit; '#13#10 +
          '  '#13#10 +
          '      saldoenddebit = :saldoenddebit + :varncudebit; '#13#10 +
          '      saldoendcredit = :saldoendcredit + :varncucredit; '#13#10 +
          '      saldoenddebitcurr = :saldoenddebitcurr + :varcurrdebit; '#13#10 +
          '      saldoendcreditcurr = :saldoendcreditcurr + :varcurrcredit; '#13#10 +
          '      saldoenddebiteq = :saldoenddebiteq + :vareqdebit; '#13#10 +
          '      saldoendcrediteq = :saldoendcrediteq + :vareqcredit; '#13#10 +
          '    END '#13#10,
          [FSQLhandle, AnalyticField, FCompanyKey, Integer(FAllHolding), FCurrKey]);
    end;

    DebitCreditSQL := DebitCreditSQL +
      '    /* сальдо на конец */ '#13#10 +
      '    IF (:saldobegindebit - :saldobegincredit + (:varncudebit - :varncucredit) > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebit = :saldobegindebit - :saldobegincredit + (:varncudebit - :varncucredit);  '#13#10 +
      '      saldoendcredit = 0; '#13#10 +
      '      ncu_end_debit = CAST(:saldoenddebit / %0:d AS NUMERIC(15, %1:d)); '#13#10 +
      '      ncu_end_credit = 0;   '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebit = 0;  '#13#10 +
      '      saldoendcredit =  - (:saldobegindebit - :saldobegincredit + (:varncudebit - :varncucredit));  '#13#10 +
      '      ncu_end_debit = 0;  '#13#10 +
      '      ncu_end_credit = CAST(:saldoendcredit / %0:d AS NUMERIC(15, %1:d)); '#13#10 +
      '    END  '#13#10 +
      ' '#13#10 +
      '    IF (:saldobegindebitcurr - :saldobegincreditcurr + (:varcurrdebit - :varcurrcredit) > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebitcurr = :saldobegindebitcurr - :saldobegincreditcurr + (:varcurrdebit - :varcurrcredit);  '#13#10 +
      '      saldoendcreditcurr = 0;  '#13#10 +
      '      curr_end_debit = CAST(:saldoenddebitcurr / %2:d AS NUMERIC(15, %3:d)); '#13#10 +
      '      curr_end_credit = 0;  '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebitcurr = 0;  '#13#10 +
      '      saldoendcreditcurr =  - (:saldobegindebitcurr - :saldobegincreditcurr + (:varcurrdebit - :varcurrcredit));  '#13#10 +
      '      curr_end_debit = 0;  '#13#10 +
      '      curr_end_credit = CAST(:saldoendcreditcurr / %2:d AS NUMERIC(15, %3:d)); '#13#10 +
      '    END  '#13#10 +
      ' '#13#10 +
      '    IF (:saldobegindebiteq - :saldobegincrediteq + (:vareqdebit - :vareqcredit) > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebiteq = :saldobegindebiteq - :saldobegincrediteq + (:vareqdebit - :vareqcredit);  '#13#10 +
      '      saldoendcrediteq = 0;  '#13#10 +
      '      eq_end_debit = CAST(:saldoenddebiteq / %4:d AS NUMERIC(15, %5:d)); '#13#10 +
      '      eq_end_credit = 0;  '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +
      '    BEGIN  '#13#10 +
      '      saldoenddebiteq = 0;  '#13#10 +
      '      saldoendcrediteq =  - (:saldobegindebiteq - :saldobegincrediteq + (:vareqdebit - :vareqcredit));  '#13#10 +
      '      eq_end_debit = 0;  '#13#10 +
      '      eq_end_credit = CAST(:saldoendcrediteq / %4:d AS NUMERIC(15, %5:d)); '#13#10 +
      '    END  '#13#10 +
      ' '#13#10 +
      '    sortfield = 1;  '#13#10 +
      '    SUSPEND;  '#13#10 +
      ' '#13#10 +
      '    saldobegindebit = :saldoenddebit;  '#13#10 +
      '    saldobegincredit = :saldoendcredit;  '#13#10 +
      '    saldobegindebitcurr = :saldoenddebitcurr;  '#13#10 +
      '    saldobegincreditcurr = :saldoendcreditcurr;  '#13#10 +
      '    saldobegindebiteq = :saldoenddebiteq;  '#13#10 +
      '    saldobegincrediteq = :saldoendcrediteq;  '#13#10 +
      ' '#13#10 +
      '    c = c + 1;  '#13#10 +
      '  END  '#13#10 +
      ' '#13#10 +
      '  IF (c = 0) THEN  '#13#10 +
      '  BEGIN  '#13#10 +
      '    m = EXTRACT(MONTH FROM :datebegin);  '#13#10 +
      '    y = EXTRACT(YEAR FROM :datebegin);  '#13#10 +
      ' '#13#10 +
      '    ncu_debit = 0;  '#13#10 +
      '    ncu_credit = 0;  '#13#10 +
      '    curr_debit = 0;  '#13#10 +
      '    curr_credit = 0;  '#13#10 +
      '    eq_debit = 0;  '#13#10 +
      '    eq_credit = 0;  '#13#10 +
      ' '#13#10 +
      '    IF (:saldobegindebit - :saldobegincredit > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      ncu_begin_debit = CAST((:saldobegindebit - :saldobegincredit) / %0:d AS NUMERIC(15, %1:d));  '#13#10 +
      '      ncu_begin_credit = 0;  '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +
      '    BEGIN  '#13#10 +
      '      ncu_begin_debit = 0;  '#13#10 +
      '      ncu_begin_credit = CAST(- (:saldobegindebit - :saldobegincredit) / %0:d AS NUMERIC(15, %1:d));  '#13#10 +
      '    END  '#13#10 +
      ' '#13#10 +
      '    IF (:saldobegindebitcurr - :saldobegincreditcurr > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      curr_begin_debit = CAST((:saldobegindebitcurr - :saldobegincreditcurr) / %2:d AS NUMERIC(15, %3:d));  '#13#10 +
      '      curr_begin_credit = 0;  '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +                        
      '    BEGIN  '#13#10 +
      '      curr_begin_debit = 0;  '#13#10 +
      '      curr_begin_credit = CAST(- (:saldobegindebitcurr - :saldobegincreditcurr) / %2:d AS NUMERIC(15, %3:d));  '#13#10 +
      '    END '#13#10 +
      ' '#13#10 +
      '    IF (:saldobegindebiteq - :saldobegincrediteq > 0) THEN  '#13#10 +
      '    BEGIN  '#13#10 +
      '      eq_begin_debit = CAST((:saldobegindebiteq - :saldobegincrediteq) / %4:d AS NUMERIC(15, %5:d));  '#13#10 +
      '      eq_begin_credit = 0;  '#13#10 +
      '    END  '#13#10 +
      '    ELSE  '#13#10 +
      '    BEGIN  '#13#10 +
      '      eq_begin_debit = 0;  '#13#10 +
      '      eq_begin_credit = CAST(- (:saldobegindebiteq - :saldobegincrediteq) / %4:d AS NUMERIC(15, %5:d));  '#13#10 +
      '    END  '#13#10 +
      ' '#13#10 +
      '    sortfield = 1;  '#13#10 +
      '    SUSPEND;  '#13#10 +
      ' END '#13#10 +
      ' END ';

    Self.SelectSQL.Text := Format(DebitCreditSQL,
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits,
       FCurrSumInfo.Scale, FCurrSumInfo.DecDigits,
       FEQSumInfo.Scale, FEQSumInfo.DecDigits]);
  end
  else
  begin

    DebitCreditSQL := '';
    FromClause := '';
    FromClause1 := '';
    GroupClause := '';
    OrderClause := '';
    IDSelect := '';
    NameSelect := '';
    WhereClause := '';
    SelectClause := '';

    if FCurrSumInfo.Show and (FCurrKey > 0) then
      CurrId := Format('  AND e.currkey = %d'#13#10, [FCurrKey])
    else
      CurrId := '';

    NcuDecDig := Format('NUMERIC(15, %d)', [FNcuSumInfo.DecDigits]);
    CurrDecDig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);
    EQDecDig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

    L_S := Format('AC_G_L_S(:begindate, :enddate, %d, %d, %d, %d, :currkey, ''%s'')',
      [FSQLHandle, FCompanyKey, Integer(FAllHolding), -1, AnalyticField]);

    Q_S := Format('AC_Q_G_L(%s, :begindate, :enddate, %d, %d, %d, %d, :currkey)',
      ['%s', FCompanyKey, Integer(FAllHolding), FSQLHandle, -1]);

    GetDebitSumSelectClause;
    GetCreditSumSelectClause;

    QuantityGroup := '';
    QuantitySelectClause := '';
    if FAcctValues.Count > 0 then
    begin
      for K := 0 to FAcctValues.Count - 1 do
      begin
        VKeyAlias := GetKeyAlias(FAcctValues.Names[K]);
        ValueAlias := 'v_' + GetKeyAlias(FAcctValues.Names[K]);
        QuantityAlias := 'q_' + GetKeyAlias(FAcctValues.Names[K]);

        GetDebitQuantitySelectClause;
        GetCreditQuantitySelectClause;

        QuantitySelectClause := QuantitySelectClause + ','#13#10 +
          Format('  IIF(NOT %0:s.debitbegin IS NULL, %0:s.debitbegin, 0) AS Q_B_D_%1:s,'#13#10 +
            '  IIF(NOT %0:s.creditbegin IS NULL, %0:s.creditbegin, 0) AS Q_B_C_%1:s,'#13#10 +
            '  IIF(NOT %0:s.debit IS NULL, %0:s.debit, 0) AS Q_D_%1:s,'#13#10 +
            '  IIF(NOT %0:s.credit IS NULL, %0:s.credit, 0) AS Q_C_%1:s,'#13#10 +
            '  IIF(NOT %0:s.debitend IS NULL, %0:s.debitend, 0) AS Q_E_D_%1:s,'#13#10 +
            '  IIF(NOT %0:s.creditend IS NULL, %0:s.creditend, 0) AS Q_E_C_%1:s',
            [QuantityAlias, VKeyAlias]);

        QuantityGroup := QuantityGroup + ','#13#10;
        QuantityGroup := QuantityGroup + Format('%0:s.debitbegin, %0:s.creditbegin, %0:s.debitend, %0:s.creditend, %0:s.debit, %0:s.credit',
          [QuantityAlias]);

        if FAcctValues.Values[FAcctValues.Names[K]] = '' then
          QS := Format(Q_S, [FAcctValues.Names[K]])
        else
          QS := Format(Q_S, [FAcctValues.Names[K], VKeyAlias]);

        FromClause := FromClause + #13#10 + Format('  LEFT JOIN %0:s %1:s '#13#10 +
          '    ON cl.m = %1:s.m AND cl.y = %1:s.y ', [QS, QuantityAlias]);
      end;
      QuantitySelectClause := QuantitySelectClause + GetDebitQuantitySelectClause + GetCreditQuantitySelectClause;
      FromClause := FromClause  + #13#10 + GetQuantityJoinClause;
    end;

    DebitCreditSQL := Format(cGeneralLedgerTemplate, [
      FNcuSumInfo.Scale, NcuDecDig,
      FNcuSumInfo.Scale, NcuDecDig,
      GetDebitSumSelectClause,
      FNcuSumInfo.Scale, NcuDecDig,
      GetCreditSumSelectClause,
      FNcuSumInfo.Scale, NcuDecDig,
      FNcuSumInfo.Scale, NcuDecDig,
      FNcuSumInfo.Scale, NcuDecDig,

      FCurrSumInfo.Scale, CurrDecDig,
      FCurrSumInfo.Scale, CurrDecDig,
      GetDebitCurrSumSelectClause,
      FCurrSumInfo.Scale, CurrDecDig,
      GetCreditCurrSumSelectClause,
      FCurrSumInfo.Scale, CurrDecDig,
      FCurrSumInfo.Scale, CurrDecDig,
      FCurrSumInfo.Scale, CurrDecDig,

      FEQSumInfo.Scale, EQDecDig,
      FEQSumInfo.Scale, EQDecDig,
      GetDebitEQSumSelectClause,
      FEQSumInfo.Scale, EQDecDig,
      GetCreditEQSumSelectClause,
      FEQSumInfo.Scale, EQDecDig,
      FEQSumInfo.Scale, EQDecDig,
      FEQSumInfo.Scale, EQDecDig,

      QuantitySelectClause, L_S, AccountInClause('e'),
      FromClause + GetSumJoinClause,
      FCompanyList, CurrId, InternalMovementClause('e'),
      QuantityGroup]);

    Self.SelectSQL.Text := DebitCreditSQL;
  end;
end;

procedure TgdvAcctGeneralLedger.FillSubAccounts(var AccountArray: TgdKeyArray);
var
  ibsql: TIBSQL;
begin
  // По идее у нас есть только один переданный счет
  if AccountArray.Count > 0 then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      //Если не задана конфигурация книги то
      //строим книгу по счету и его субсчетам в противном случае
      //в книгу должны попасть только нужные субсчета
      if FConfigKey > -1 then
      begin
        ibsql.SQL.Text := Format(
          ' SELECT ' +
          '   a2.id ' +
          ' FROM ' +
          '   ac_account a1 ' +
          '   LEFT JOIN ac_account a2 ON a2.lb >= a1.lb and a2.rb <= a1.rb and a2.ACCOUNTTYPE in (''A'', ''S'') ' +
          ' WHERE ' +
          '   a1.id = %d AND ' +
          '   (a2.id IN (SELECT accountkey FROM AC_G_LEDGERACCOUNT ' +
          '              WHERE ledgerkey = %d) OR a2.id = a1.id)',
          [AccountArray.Keys[0], FConfigKey]);

      end
      else
      begin
        ibsql.SQL.Text := Format(
          ' SELECT ' +
          '   a2.id ' +
          ' FROM ' +
          '   ac_account a1 ' +
          '   LEFT JOIN ac_account a2 ON a2.lb >= a1.lb and a2.rb <= a1.rb and a2.ACCOUNTTYPE in (''A'', ''S'') ' +
          ' WHERE a1.id = %d ',
          [AccountArray.Keys[0]]);
      end;

      ibsql.ExecQuery;
      AccountArray.Clear;
      while not ibsql.Eof do
      begin
        if AccountArray.IndexOf(ibsql.Fields[0].AsInteger) = - 1 then
          AccountArray.Add(ibsql.Fields[0].AsInteger);
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

function TgdvAcctGeneralLedger.LargeSQLErrorMessage: String;
begin
  Result := 'Найдено слишком большое количество корреспондирующих счетов.'#13#10 +
    'Попробуйте сделать расшифровку по дебету и кредиту раздельно, '#13#10 +
    'или выбрать меньше количество счетов.'#13#10#13#10 +
    'Построение отчета не возможно.';
end;

end.
