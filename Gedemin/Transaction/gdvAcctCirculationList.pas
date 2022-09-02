// ShlTanya, 09.03.2019

unit gdvAcctCirculationList;

interface

uses
  classes, gd_ClassList, AcctStrings, AcctUtils, gdvAcctBase, gdvAcctLedger, gdv_AcctConfig_unit;

type
  TgdvAcctCirculationList = class(TgdvAcctLedger)
  private
    FOnlyAccounts: Boolean;
    
  protected
    class function ConfigClassName: string; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;

    procedure SetDefaultParams; override;
    procedure DoBuildSQL; override;

  public
    constructor Create(AOwner: TComponent); override;
    property OnlyAccounts: boolean read FOnlyAccounts write FOnlyAccounts;
  end;


procedure Register;

implementation

uses
  Sysutils, IBSQL, gdcBaseInterface;

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctCirculationList]);
end;

{ TgdvAcctCirculationList }

constructor TgdvAcctCirculationList.Create(AOwner: TComponent);
begin
  inherited;

  Self.DeleteSQL.Text := 'DELETE FROM AC_LEDGER_ACCOUNTS WHERE ACCOUNTKEY = -1';
end;

class function TgdvAcctCirculationList.ConfigClassName: string;
begin
  Result := 'TAccCirculationListConfig';
end;

procedure TgdvAcctCirculationList.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;

  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    FOnlyAccounts := C.OnlyAccounts;
  end;
end;

procedure TgdvAcctCirculationList.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;

  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    C.OnlyAccounts := FOnlyAccounts;
  end;
end;

procedure TgdvAcctCirculationList.DoBuildSQL;
var
  DebitCreditSQL: string;
  QuantitySelectClause, SelectClause, FromClause, GroupClause, OrderClause: string;
  IDSelect, NameSelect, QuantityGroup: String;
  CurrId: string;
  NcuDecDig, CurrDecDig, EQDecDig: String;
  FI: TgdvFieldInfo;
  Q_S, L_S: string;

  ibsql: TIBSQL;
  LB, RB: Integer;

  BalanceCondition, EntryCondition: String;
begin
  DebitCreditSQL := '';
  FromClause := '';
  GroupClause := '';
  OrderClause := '';
  IDSelect := '';
  NameSelect := '';
  SelectClause := '';

  BalanceCondition := Self.GetCondition('bal');
  EntryCondition := Self.GetCondition('e');

  if FCurrSumInfo.Show and (FCurrKey > 0) then
    CurrId := Format('  AND e.currkey = %d'#13#10, [TID264(FCurrKey)])
  else
    CurrId := '';

  NcuDecDig := Format('NUMERIC(15, %d)', [FNcuSumInfo.DecDigits]);
  CurrDecDig := Format('NUMERIC(15, %d)', [FCurrSumInfo.DecDigits]);
  EQDecDig := Format('NUMERIC(15, %d)', [FEQSumInfo.DecDigits]);

  if Assigned(FFieldInfos) then
  begin
    FI := FFieldInfos.AddInfo;
    FI.FieldName := 'ALIAS';
    FI.Caption := '—чет';
    FI.Visible := fvVisible;
    FI.Condition := False;

    FI := FFieldInfos.AddInfo;
    FI.FieldName := 'ID';
    FI.Visible := fvHidden;
  end;

  Self.GetDebitSumSelectClause;
  Self.GetCreditSumSelectClause;

  if FUseEntryBalance then
  begin
    LB := 0;
    RB := 0;
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        '   SELECT ' +
        '     c.lb, c.rb ' +
        '   FROM ' +
        '     ac_account c ' +
        '   WHERE ' +
        '     c.id = :accountkey ';
      SetTID(ibsql.ParamByName('ACCOUNTKEY'), FAccounts[0]);
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        LB := ibsql.FieldByName('LB').AsInteger;
        RB := ibsql.FieldByName('RB').AsInteger;
      end;
    finally
      ibsql.Free;
    end;

    DebitCreditSQL := Format(
      ' EXECUTE BLOCK ( '#13#10 +
      '   datebegin DATE = :begindate, '#13#10 +
      '   dateend DATE = :enddate, '#13#10 +
      '   currkey DFOREIGNKEY = :currkey) '#13#10 +
      ' RETURNS ( '#13#10 +
      '   id DINTKEY, '#13#10 +
      '   alias VARCHAR(20), '#13#10 +
      '   name VARCHAR(180), '#13#10 +
      '   offbalance INTEGER, '#13#10 +
      '   ncu_begin_debit NUMERIC(15, %1:d), '#13#10 +
      '   ncu_begin_credit NUMERIC(15, %1:d), '#13#10 +
      '   ncu_debit NUMERIC(15, %1:d), '#13#10 +
      '   ncu_credit NUMERIC(15, %1:d), '#13#10 +
      '   ncu_end_debit NUMERIC(15, %1:d), '#13#10 +
      '   ncu_end_credit NUMERIC(15, %1:d), '#13#10 +
      '   curr_begin_debit NUMERIC(15, %3:d), '#13#10 +
      '   curr_begin_credit NUMERIC(15, %3:d), '#13#10 +
      '   curr_debit NUMERIC(15, %3:d), '#13#10 +
      '   curr_credit NUMERIC(15, %3:d), '#13#10 +
      '   curr_end_debit NUMERIC(15, %3:d), '#13#10 +
      '   curr_end_credit NUMERIC(15, %3:d), '#13#10 +
      '   eq_begin_debit NUMERIC(15, %5:d), '#13#10 +
      '   eq_begin_credit NUMERIC(15, %5:d), '#13#10 +
      '   eq_debit NUMERIC(15, %5:d), '#13#10 +
      '   eq_credit NUMERIC(15, %5:d), '#13#10 +
      '   eq_end_debit NUMERIC(15, %5:d), '#13#10 +
      '   eq_end_credit NUMERIC(15, %5:d)) '#13#10 +
      ' AS '#13#10 +
      '   DECLARE VARIABLE activity VARCHAR(1); '#13#10 +
      '   DECLARE VARIABLE saldo NUMERIC(15,  %1:d); '#13#10 +
      '   DECLARE VARIABLE saldocurr NUMERIC(15,  %3:d); '#13#10 +
      '   DECLARE VARIABLE saldoeq NUMERIC(15,  %5:d); '#13#10 +
      '   DECLARE VARIABLE fieldname VARCHAR(60); '#13#10 +
      '   DECLARE VARIABLE closedate DATE; '#13#10 +
      ' BEGIN '#13#10 +
      '   closedate = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
      ' '#13#10 +
      '   FOR '#13#10 +
      '     SELECT '#13#10 +
      '       a.id, a.alias, a.activity, f.fieldname, a.name, a.offbalance '#13#10 +
      '     FROM '#13#10 +
      '       ac_account a '#13#10 +
      '     LEFT JOIN   (SELECT aa.accountkey, LIST(rf.fieldname, '', '') fieldname '#13#10 +
      '                 FROM  ac_accanalyticsext aa '#13#10 +
      '                 JOIN at_relation_fields rf ON aa.valuekey = rf.id '#13#10 +
      '                 GROUP BY aa.accountkey) f '#13#10 +
      '     ON a.id = f.accountkey '#13#10 +
      '     WHERE '#13#10 +
      '       a.accounttype IN (''A'', ''S'') '#13#10 +
      '       AND a.lb >= ' + IntToStr(LB) + ' AND a.rb <= ' + IntToStr(RB) + ' AND a.alias <> ''00'' '#13#10 +
      '     ORDER BY '#13#10 +
      '       a.offbalance DESC, a.alias '#13#10 +
      '     INTO '#13#10 +
      '       :id, :alias, :activity, :fieldname, :name, :offbalance '#13#10 +
      '   DO '#13#10 +
      '   BEGIN '#13#10 +
      '     ncu_begin_debit = 0; '#13#10 +
      '     ncu_begin_credit = 0; '#13#10 +
      '     curr_begin_debit = 0; '#13#10 +
      '     curr_begin_credit = 0; '#13#10 +
      '     eq_begin_debit = 0; '#13#10 +
      '     eq_begin_credit = 0; '#13#10 +
      ' '#13#10 +
      '     IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
      '     BEGIN '#13#10 +
      '       SELECT '#13#10 +
      '         SUM(main.debitncu - main.creditncu), '#13#10 +
      '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
      '         SUM(main.debiteq - main.crediteq) '#13#10 +
      '       FROM '#13#10 +
      '       ( '#13#10 +
      '         SELECT '#13#10 +
      '           bal.debitncu, '#13#10 +
      '           bal.creditncu, '#13#10 +
      '           bal.debitcurr, '#13#10 +
      '           bal.creditcurr, '#13#10 +
      '           bal.debiteq, '#13#10 +
      '           bal.crediteq '#13#10 +
      '         FROM '#13#10 +
      '           ac_entry_balance bal '#13#10 +
      '         WHERE '#13#10 +
      '           bal.accountkey = :id '#13#10 +
      '           AND bal.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND bal.currkey = ' + TID2S(FCurrKey) + #13#10, '') +
        IIF(BalanceCondition <> '', ' AND '#13#10 + BalanceCondition, '') +
      ' '#13#10 +
      '         UNION ALL '#13#10 +
      ' '#13#10 +
      '         SELECT '#13#10 +
        IIF(FEntryBalanceDate <= FDateBegin,
          '           e.debitncu, '#13#10 +
          '           e.creditncu, '#13#10 +
          '           e.debitcurr, '#13#10 +
          '           e.creditcurr, '#13#10 +
          '           e.debiteq, '#13#10 +
          '           e.crediteq '#13#10,
          '           - e.debitncu, '#13#10 +
          '           - e.creditncu, '#13#10 +
          '           - e.debitcurr, '#13#10 +
          '           - e.creditcurr, '#13#10 +
          '           - e.debiteq, '#13#10 +
          '           - e.crediteq '#13#10) +
      '         FROM '#13#10 +
      '           ac_entry e '#13#10 +
      '         WHERE '#13#10 +
      '           e.accountkey = :id '#13#10 +
        IIF(FEntryBalanceDate <= FDateBegin,
          '           AND e.entrydate >= :closedate '#13#10 +
          '           AND e.entrydate < :datebegin '#13#10,
          '           AND e.entrydate >= :datebegin '#13#10 +
          '           AND e.entrydate < :closedate '#13#10) +
      '           AND e.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND e.currkey = ' + TID2S(FCurrKey) + #13#10, '') +
        IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition, '') +
      '       ) main '#13#10 +
      '       INTO '#13#10 +
      '         :saldo, :saldocurr, :saldoeq; '#13#10 +
      ' '#13#10 +
      '       IF (saldo IS NULL) THEN '#13#10 +
      '         saldo = 0; '#13#10 +
      '       IF (saldocurr IS NULL) THEN '#13#10 +
      '         saldocurr = 0; '#13#10 +
      '       IF (saldoeq IS NULL) THEN '#13#10 +
      '         saldoeq = 0; '#13#10 +
      ' '#13#10 +
      '       IF (saldo > 0) THEN '#13#10 +
      '         ncu_begin_debit = CAST((saldo / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         ncu_begin_credit = - CAST((saldo / %0:d) AS NUMERIC(15, %1:d)); '#13#10 +
      ' '#13#10 +
      '       IF (saldocurr > 0) THEN '#13#10 +
      '         curr_begin_debit = CAST((saldocurr / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         curr_begin_credit = - CAST((saldocurr / %2:d) AS NUMERIC(15, %3:d)); '#13#10 +
      ' '#13#10 +
      '       IF (saldoeq > 0) THEN '#13#10 +
      '         eq_begin_debit = CAST((saldoeq / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         eq_begin_credit = - CAST((saldoeq / %4:d) AS NUMERIC(15, %5:d)); '#13#10 +
      '     END '#13#10 +
      '     ELSE '#13#10 +
      '     BEGIN '#13#10 +
      '       SELECT '#13#10 +
      '         CAST((debitsaldo / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '         CAST((creditsaldo / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '         CAST((currdebitsaldo / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '         CAST((currcreditsaldo / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '         CAST((eqdebitsaldo / %4:d) AS NUMERIC(15, %5:d)), '#13#10 +
      '         CAST((eqcreditsaldo / %4:d) AS NUMERIC(15, %5:d)) '#13#10 +
      '       FROM '#13#10 +
      '         ac_accountexsaldo_bal(:datebegin, :id, :fieldname, ' + TID2S(FCompanyKey) + ', ' + IntToStr(Integer(FAllHolding)) + ', :currkey) '#13#10 +  // !!!!!!!!!!!!!!
      '       INTO '#13#10 +
      '         :ncu_begin_debit, '#13#10 +
      '         :ncu_begin_credit, '#13#10 +
      '         :curr_begin_debit, '#13#10 +
      '         :curr_begin_credit, '#13#10 +
      '         :eq_begin_debit, '#13#10 +
      '         :eq_begin_credit; '#13#10 +
      '     END '#13#10 +
      '  '#13#10 +
      '     SELECT '#13#10 +
      '       CAST((SUM(e.debitncu) / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '       CAST((SUM(e.creditncu) / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '       CAST((SUM(e.debitcurr) / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '       CAST((SUM(e.creditcurr) / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '       CAST((SUM(e.debiteq) / %4:d) AS NUMERIC(15, %5:d)), '#13#10 +
      '       CAST((SUM(e.crediteq) / %4:d) AS NUMERIC(15, %5:d)) '#13#10 +
      '     FROM '#13#10 +
      '       ac_entry e '#13#10 +
      '     WHERE '#13#10 +
      '       e.accountkey = :id '#13#10 +
      '       AND e.entrydate >= :datebegin '#13#10 +
      '       AND e.entrydate <= :dateend '#13#10 +
      '       AND e.companykey + 0 IN (' + FCompanyList + ') '#13#10 +
        IIF(FCurrSumInfo.Show and (FCurrKey > 0), ' AND e.currkey = ' + TID2S(FCurrKey) + #13#10, '') +
        IIF(EntryCondition <> '', ' AND '#13#10 + EntryCondition, '') +
        Self.InternalMovementClause('e') +
      '         INTO '#13#10 +
      '           :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; '#13#10 +
      ' '#13#10 +
      '     IF (ncu_debit IS NULL) THEN '#13#10 +
      '       ncu_debit = 0; '#13#10 +
      '     IF (ncu_credit IS NULL) THEN '#13#10 +
      '       ncu_credit = 0; '#13#10 +
      '     IF (curr_debit IS NULL) THEN '#13#10 +
      '       curr_debit = 0; '#13#10 +
      '     IF (curr_credit IS NULL) THEN '#13#10 +
      '       curr_credit = 0; '#13#10 +
      '     IF (eq_debit IS NULL) THEN '#13#10 +
      '       eq_debit = 0; '#13#10 +
      '     IF (eq_credit IS NULL) THEN '#13#10 +
      '       eq_credit = 0; '#13#10 +
      ' '#13#10 +
      '     ncu_end_debit = 0; '#13#10 +
      '     ncu_end_credit = 0; '#13#10 +
      '     curr_end_debit = 0; '#13#10 +
      '     curr_end_credit = 0; '#13#10 +
      '     eq_end_debit = 0; '#13#10 +
      '     eq_end_credit = 0; '#13#10 +
      ' '#13#10 +
      '     IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
      '     BEGIN '#13#10 +
      '       saldo = ncu_begin_debit - ncu_begin_credit + ncu_debit - ncu_credit; '#13#10 +
      '       IF (saldo > 0) THEN '#13#10 +
      '         ncu_end_debit = CAST(saldo  AS NUMERIC(15, %1:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         ncu_end_credit = - CAST(saldo AS NUMERIC(15, %1:d)); '#13#10 +
      ' '#13#10 +
      '       saldocurr = curr_begin_debit - curr_begin_credit + curr_debit - curr_credit; '#13#10 +
      '       IF (saldocurr > 0) THEN '#13#10 +
      '         curr_end_debit = CAST(saldocurr AS NUMERIC(15, %3:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         curr_end_credit = - CAST(saldocurr  AS NUMERIC(15, %3:d)); '#13#10 +
      ' '#13#10 +
      '       saldoeq = eq_begin_debit - eq_begin_credit + eq_debit - eq_credit; '#13#10 +
      '       IF (saldoeq > 0) THEN '#13#10 +
      '         eq_end_debit = CAST(saldoeq AS NUMERIC(15, %5:d)); '#13#10 +
      '       ELSE '#13#10 +
      '         eq_end_credit = - CAST(saldoeq AS NUMERIC(15, %5:d)); '#13#10 +
      '     END '#13#10 +
      '     ELSE '#13#10 +
      '     BEGIN '#13#10 +
      '       IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR '#13#10 +
      '         (ncu_debit <> 0) OR (ncu_credit <> 0) OR '#13#10 +
      '         (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR '#13#10 +
      '         (curr_debit <> 0) OR (curr_credit <> 0) OR '#13#10 +
      '         (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR '#13#10 +
      '         (eq_debit <> 0) OR (eq_credit <> 0)) THEN '#13#10 +
      '       BEGIN '#13#10 +
      '         SELECT '#13#10 +
      '           CAST((debitsaldo / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '           CAST((creditsaldo / %0:d) AS NUMERIC(15, %1:d)), '#13#10 +
      '           CAST((currdebitsaldo / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '           CAST((currcreditsaldo / %2:d) AS NUMERIC(15, %3:d)), '#13#10 +
      '           CAST((eqdebitsaldo / %4:d) AS NUMERIC(15, %5:d)), '#13#10 +
      '           CAST((eqcreditsaldo / %4:d) AS NUMERIC(15, %5:d)) '#13#10 +
      '         FROM '#13#10 +
      '           ac_accountexsaldo_bal(:dateend + 1, :id, :fieldname, ' + TID2S(FCompanyKey) + ', ' + IntToStr(Integer(FAllHolding)) + ', :currkey) '#13#10 +
      '         INTO '#13#10 +
      '           :ncu_end_debit, :ncu_end_credit, :curr_end_debit, :curr_end_credit, :eq_end_debit, :eq_end_credit; '#13#10 +
      '       END '#13#10 +
      '     END '#13#10 +
      '     IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR '#13#10 +
      '       (ncu_debit <> 0) OR (ncu_credit <> 0) OR '#13#10 +
      '       (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR '#13#10 +
      '       (curr_debit <> 0) OR (curr_credit <> 0) OR '#13#10 +
      '       (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR '#13#10 +
      '       (eq_debit <> 0) OR (eq_credit <> 0)) THEN '#13#10 +
      '     SUSPEND; '#13#10 +
      '   END '#13#10 +
      ' END ',
      [FNcuSumInfo.Scale, FNcuSumInfo.DecDigits,
      FCurrSumInfo.Scale, FCurrSumInfo.DecDigits,
      FEQSumInfo.Scale, FEQSumInfo.DecDigits]);
  end
  else
  begin
    L_S := Format('AC_CIRCULATIONLIST(:begindate, :enddate, %d, %d, %d, %d, :currkey, %d)',
      [TID264(FCompanyKey), Integer(FAllHolding), TID264(FAccounts[0]), -1, Integer(not FIncludeInternalMovement)]);

    Q_S := Format('AC_Q_CIRCULATION(%s, :begindate, :enddate, %d, %d, cl.id, %d, :currkey)',
      ['%s', TID264(FCompanyKey), Integer(FAllHolding), -1]);

    QuantityGroup := '';
    QuantitySelectClause := '';
  {  if FValueList.Count > 0 then
    begin
      for K := 0 to FValueList.Count - 1 do
      begin
        VKeyAlias := KeyAlias(FValueList.Names[K]);
        ValueAlias := 'v_' + KeyAlias(FValueList.Names[K]);
        QuantityAlias := 'q_' + KeyAlias(FValueList.Names[K]);

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

        if frAcctAnalytics.Values = '' then
          QS := Format(Q_S, [FValueList.Names[K]])
        else
          QS := Format(Q_S, [FValueList.Names[K], VKeyAlias]);

        FromClause := FromClause + #13#10 + Format('  LEFT JOIN %s %s '#13#10 +
          '    ON cl.id = %s.id ', [QS, QuantityAlias, QuantityAlias]);
      end;
      QuantitySelectClause := QuantitySelectClause +  GetDebitQuantitySelectClause + GetCreditQuantitySelectClause;
      FromClause := FromClause  + #13#10 + GetQuantityJoinClause;
    end;}

    DebitCreditSQL := Format(cCirculationListTemplate, [
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

      QuantitySelectClause,
      L_S,
      FromClause + GetSumJoinClause,
      QuantityGroup]);
  end;

  Self.SelectSQL.Text := DebitCreditSQL;
end;

procedure TgdvAcctCirculationList.SetDefaultParams;
begin
  inherited;
  FShowDebit := False;
  FShowCredit := False;
end;

end.
