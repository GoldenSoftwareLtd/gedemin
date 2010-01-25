unit mdf_CirculationList2;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure CirculationList2(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

const
   Field : TmdfField =
     (RelationName: 'AC_ACCOUNT';
      FieldName: 'FULLNAME';
      Description: 'COMPUTED BY (iif(ALIAS is null, '''', ALIAS || '' '') || iif(NAME is null,  '''', NAME))');
   ProcCount = 1;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName:'AC_CIRCULATIONLIST'; Description:
        '    (DATEBEGIN DATE,'#13#10 +
        '    DATEEND DATE,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    ACCOUNTKEY INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ALIAS VARCHAR(20),'#13#10 +
        '    NAME VARCHAR(180),'#13#10 +
        '    ID INTEGER,'#13#10 +
        '    NCU_BEGIN_DEBIT NUMERIC(15,4),'#13#10 +
        '    NCU_BEGIN_CREDIT NUMERIC(15,4),'#13#10 +
        '    NCU_DEBIT NUMERIC(15,4),'#13#10 +
        '    NCU_CREDIT NUMERIC(15,4),'#13#10 +
        '    NCU_END_DEBIT NUMERIC(15,4),'#13#10 +
        '    NCU_END_CREDIT NUMERIC(15,4),'#13#10 +
        '    CURR_BEGIN_DEBIT NUMERIC(15,4),'#13#10 +
        '    CURR_BEGIN_CREDIT NUMERIC(15,4),'#13#10 +
        '    CURR_DEBIT NUMERIC(15,4),'#13#10 +
        '    CURR_CREDIT NUMERIC(15,4),'#13#10 +
        '    CURR_END_DEBIT NUMERIC(15,4),'#13#10 +
        '    CURR_END_CREDIT NUMERIC(15,4),'#13#10 +
        '    OFFBALANCE INTEGER) '#13#10 +
        'AS'#13#10 +
        'DECLARE VARIABLE ACTIVITY VARCHAR(1);'#13#10 +
        'DECLARE VARIABLE SALDO NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOCURR NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE FIELDNAME VARCHAR(60);'#13#10 +
        'DECLARE VARIABLE LB INTEGER;'#13#10 +
        'DECLARE VARIABLE RB INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  /* Procedure Text */'#13#10 +
        ''#13#10 +
        '  SELECT c.lb, c.rb FROM ac_account c'#13#10 +
        '  WHERE c.id = :ACCOUNTKEY'#13#10 +
        '  INTO :lb, :rb;'#13#10 +
        ' '#13#10 +
        '  FOR '#13#10 +
        '    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance '#13#10 +
        '    FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id '#13#10 +
        '    WHERE '#13#10 +
        '      a.accounttype IN (''A'', ''S'') AND '#13#10 +
        '      a.LB >= :LB AND a.RB <= :RB AND a.alias <> ''00'' '#13#10 +
        '    INTO :id, :ALIAS, :activity, :fieldname, :name, :offbalance '#13#10 +
        '  DO '#13#10 +
        '  BEGIN '#13#10 +
        '    NCU_BEGIN_DEBIT = 0;'#13#10 +
        '    NCU_BEGIN_CREDIT = 0;'#13#10 +
        '    CURR_BEGIN_DEBIT = 0;'#13#10 +
        '    CURR_BEGIN_CREDIT = 0;'#13#10 +
        ''#13#10 +
        '    IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      SELECT'#13#10 +
        '        SUM(e.DEBITNCU - e.CREDITNCU),'#13#10 +
        '        SUM(e.DEBITCURR - e.CREDITCURR)'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
        '      WHERE'#13#10 +
        '        e.accountkey = :id AND e.entrydate < :datebegin AND '#13#10 +
        '        (r.companykey = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      INTO :SALDO,'#13#10 +
        '        :SALDOCURR;'#13#10 +
        ''#13#10 +
        '      IF (SALDO IS NULL) THEN '#13#10 +
        '        SALDO = 0; '#13#10 +
        ''#13#10 +
        '      IF (SALDOCURR IS NULL) THEN'#13#10 +
        '        SALDOCURR = 0;'#13#10 +
        ' '#13#10 +
        ' '#13#10 +
        '      IF (SALDO > 0) THEN '#13#10 +
        '        NCU_BEGIN_DEBIT = SALDO;'#13#10 +
        '      ELSE '#13#10 +
        '        NCU_BEGIN_CREDIT = 0 - SALDO;'#13#10 +
        ''#13#10 +
        '      IF (SALDOCURR > 0) THEN'#13#10 +
        '        CURR_BEGIN_DEBIT = SALDOCURR;'#13#10 +
        '      ELSE '#13#10 +
        '        CURR_BEGIN_CREDIT = 0 - SALDOCURR;'#13#10 +
        '    END'#13#10 +
        '    ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      SELECT'#13#10 +
        '        DEBITsaldo,'#13#10 +
        '        creditsaldo'#13#10 +
        '      FROM'#13#10 +
        '        AC_ACCOUNTEXSALDO(:datebegin, :ID, :FIELDNAME, :COMPANYKEY,'#13#10 +
        '          :allholdingcompanies, :INGROUP, :currkey)'#13#10 +
        '      INTO'#13#10 +
        '        :NCU_BEGIN_DEBIT,'#13#10 +
        '        :NCU_BEGIN_CREDIT;'#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        ' '#13#10 +
        '    SELECT'#13#10 +
        '      SUM(e.DEBITNCU),'#13#10 +
        '      SUM(e.CREDITNCU),'#13#10 +
        '      SUM(e.DEBITCURR),'#13#10 +
        '      SUM(e.CREDITCURR)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
        '    WHERE '#13#10 +
        '      e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
        '      e.entrydate <= :dateend AND '#13#10 +
        '        (r.companykey = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '    INTO :NCU_DEBIT, :NCU_CREDIT,'#13#10 +
        '      :CURR_DEBIT, CURR_CREDIT;'#13#10 +
        ' '#13#10 +
        '    IF (NCU_DEBIT IS NULL) THEN'#13#10 +
        '      NCU_DEBIT = 0;'#13#10 +
        ' '#13#10 +
        '    IF (NCU_CREDIT IS NULL) THEN'#13#10 +
        '      NCU_CREDIT = 0;'#13#10 +
        ''#13#10 +
        '    IF (CURR_DEBIT IS NULL) THEN'#13#10 +
        '      CURR_DEBIT = 0;'#13#10 +
        ' '#13#10 +
        '    IF (CURR_CREDIT IS NULL) THEN'#13#10 +
        '      CURR_CREDIT = 0;'#13#10 +
        ''#13#10 +
        '    NCU_END_DEBIT = 0;'#13#10 +
        '    NCU_END_CREDIT = 0;'#13#10 +
        '    CURR_END_DEBIT = 0;'#13#10 +
        '    CURR_END_CREDIT = 0;'#13#10 +
        ' '#13#10 +
        '    IF ((ACTIVITY <> ''B'') OR (FIELDNAME IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      SALDO = NCU_BEGIN_DEBIT - NCU_BEGIN_CREDIT + NCU_DEBIT - NCU_CREDIT;'#13#10 +
        '      IF (SALDO > 0) THEN'#13#10 +
        '        NCU_END_DEBIT = SALDO;'#13#10 +
        '      ELSE'#13#10 +
        '        NCU_END_CREDIT = 0 - SALDO;'#13#10 +
        ''#13#10 +
        '      SALDOCURR = CURR_BEGIN_DEBIT - CURR_BEGIN_CREDIT + CURR_DEBIT - CURR_CREDIT;'#13#10 +
        '      IF (SALDOCURR > 0) THEN'#13#10 +
        '        CURR_END_DEBIT = SALDOCURR;'#13#10 +
        '      ELSE'#13#10 +
        '        CURR_END_CREDIT = 0 - SALDOCURR;'#13#10 +
        '    END'#13#10 +
        '    ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR'#13#10 +
        '        (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR'#13#10 +
        '        (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR'#13#10 +
        '        (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0)) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        SELECT'#13#10 +
        '          DEBITsaldo, creditsaldo,'#13#10 +
        '          CurrDEBITsaldo, Currcreditsaldo'#13#10 +
        '        FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY,'#13#10 +
        '          :allholdingcompanies, :INGROUP, :currkey)'#13#10 +
        '        INTO :NCU_END_DEBIT, :NCU_END_CREDIT, :CURR_END_DEBIT, :CURR_END_CREDIT;'#13#10 +
        '      END'#13#10 +
        '    END'#13#10 +
        '    IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR'#13#10 +
        '      (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR'#13#10 +
        '      (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR'#13#10 +
        '      (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0)) THEN'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END')
   );

procedure CirculationList2(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  if FieldExist(Field, IBDB) then
    DropField(Field, IBDB);

  AddField(Field, IBDB);

  for I := 0 to ProcCount - 1 do
  begin
    if ProcedureExist(Procs[i], IBDB) then
      AlterProcedure(Procs[i], IBDB)
    else
      CreateProcedure(Procs[i], IBDB)
  end;
end;



end.
