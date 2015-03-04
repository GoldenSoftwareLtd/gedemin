unit mdf_CirculationList;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure CirculationList(IBDB: TIBDatabase; Log: TModifyLog);
function CreateAccCirculationList(IBDB: TIBDataBase): String; 
implementation

uses
  IBSQL, SysUtils, IBScript, classes;

const
   ProcCount = 2;

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
        '    CURR_END_CREDIT NUMERIC(15,4))'#13#10 +
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
        '    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name '#13#10 +
        '    FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id '#13#10 +
        '    WHERE '#13#10 +
        '      a.accounttype IN (''A'', ''S'') AND '#13#10 +
        '      a.LB >= :LB AND a.RB <= :RB AND a.alias <> ''00'' '#13#10 +
        '    ORDER BY a.alias '#13#10 +
        '    INTO :id, :ALIAS, :activity, :fieldname, :name '#13#10 +
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
        'END'),
     (ProcedureName:'AC_Q_CIRCULATION'; Description:
        ' ('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    DATEBEGIN DATE,'#13#10 +
        '    DATEEND DATE,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    ACCOUNTKEY INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ID INTEGER,'#13#10 +
        '    DEBITBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITEND NUMERIC(15,4),'#13#10 +
        '    CREDITEND NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'begin'#13#10 +
        '  id = :accountkey;'#13#10 +
        '  SELECT'#13#10 +
        '    IIF(SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
        '      SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
        '  FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
        '    WHERE'#13#10 +
        '      e1.entrydate < :datebegin AND'#13#10 +
        '      e1.accountkey = :id AND'#13#10 +
        '      (r1.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r1.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      q.valuekey = :valuekey AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin;'#13#10 +
        '    if (saldobegin IS NULL) then'#13#10 +
        '      saldobegin = 0;'#13#10 +
        ''#13#10 +
        '    C = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '          SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
        '          q.valuekey = :valuekey'#13#10 +
        '      WHERE'#13#10 +
        '        e.entrydate <= :dateend AND'#13#10 +
        '        e.entrydate >= :datebegin AND'#13#10 +
        '        e.accountkey = :id AND'#13#10 +
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
        '      INTO :O'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (O IS NULL) THEN O = 0;'#13#10 +
        '      DEBITBEGIN = 0;'#13#10 +
        '      CREDITBEGIN = 0;'#13#10 +
        '      DEBITEND = 0;'#13#10 +
        '       CREDITEND = 0;'#13#10 +
        '      DEBIT = 0;'#13#10 +
        '      CREDIT = 0;'#13#10 +
        '      IF (O > 0) THEN'#13#10 +
        '        DEBIT = :O;'#13#10 +
        '      ELSE'#13#10 +
        '        CREDIT = - :O;'#13#10 +
        ''#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITEND =  - :SALDOEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*≈сли за указанный период нет движени€ то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '    END'#13#10 +
        '  SUSPEND;'#13#10 +
        'end')
   );


procedure CirculationList(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  SP: TmdfStoredProcedure;
begin
  Sp.ProcedureName := 'AC_ACCOUNTEXSALDO';
  SP.Description := CreateAccCirculationList(IBDB);
  if ProcedureExist(SP, IBDB) then
    AlterProcedure(SP, IBDB)
  else
    CreateProcedure(SP, IBDB);


  for I := 0 to ProcCount - 1 do
  begin
    if ProcedureExist(Procs[i], IBDB) then
      AlterProcedure(Procs[i], IBDB)
    else
      CreateProcedure(Procs[i], IBDB)
  end;
end;

function CreateAccCirculationList(IBDB: TIBDataBase): String;
var
  ibsqlR: TIBSQL;
  FieldList: String;
  TextSQL: String;
  Tr: TIBTransaction;
begin
  Result := '';
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    ibsqlR := TIBSQL.Create(nil);
    try
      ibsqlR.Transaction := Tr;
      Tr.StartTransaction;
      ibsqlR.SQL.Text :=
        'SELECT * FROM at_relation_fields ' +
        'WHERE relationname = ''AC_ENTRY'' AND fieldname LIKE ''USR$%'' ' +
        'ORDER BY fieldname';
      ibsqlR.ExecQuery;
      Result :=
        '  (DATEEND DATE, '#13#10 +
        '   ACCOUNTKEY INTEGER, '#13#10 +
        '   FIELDNAME VARCHAR(60), '#13#10 +
        '   COMPANYKEY INTEGER, '#13#10 +
        '   ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '   INGROUP INTEGER,'#13#10 +
        '   CURRKEY INTEGER)'#13#10 +
        'RETURNS (DEBITSALDO NUMERIC(15, 4), '#13#10 +
        '   CREDITSALDO NUMERIC(15, 4), '#13#10 +
        '   CURRDEBITSALDO NUMERIC(15,4),'#13#10 +
        '   CURRCREDITSALDO NUMERIC(15,4),'#13#10 +
        '   EQDEBITSALDO NUMERIC(15,4),'#13#10 +
        '   EQCREDITSALDO NUMERIC(15,4))'#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE SALDOCURR NUMERIC(15,4);'#13#10 +
        '  DECLARE VARIABLE SALDOEQ NUMERIC(15,4);'#13#10;

      FieldList := '';
      TextSQL := '';
      while not ibsqlR.EOF do
      begin
        FieldList := FieldList + Format('  DECLARE VARIABLE %s INTEGER;', [ibsqlR.FieldByName('fieldname').AsString]) + #13#10;
        TextSQL := TextSQL +
        '  IF (FIELDNAME = ''' + ibsqlR.FieldByName('fieldname').AsString + ''') THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    FOR '#13#10 +
        '      SELECT ' + ibsqlR.FieldByName('fieldname').AsString + ', SUM(e.debitncu - e.creditncu), '#13#10 +
        '        SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '        SUM(e.debiteq - e.crediteq)'#13#10 +
        '        FROM ac_entry e LEFT JOIN ac_record r ON e.recordkey = r.id '#13#10 +
        '        WHERE e.accountkey = :accountkey and e.entrydate < :DATEEND AND '#13#10 +
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
        '      GROUP BY ' + ibsqlR.FieldByName('fieldname').AsString + ' '#13#10 +
        '      INTO :' + ibsqlR.FieldByName('fieldname').AsString + ', :SALDO, :SALDOCURR, :SALDOEQ '#13#10 +
        '    DO '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (SALDO IS NULL) THEN '#13#10 +
        '        SALDO = 0; '#13#10 +
        '      IF (SALDO > 0) THEN '#13#10 +
        '        DEBITSALDO = DEBITSALDO + SALDO; '#13#10 +
        '      ELSE '#13#10 +
        '        CREDITSALDO = CREDITSALDO - SALDO; '#13#10 +
        '      IF (SALDOCURR IS NULL) THEN'#13#10 +
        '         SALDOCURR = 0;'#13#10 +
        '       IF (SALDOCURR > 0) THEN'#13#10 +
        '         CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR;'#13#10 +
        '       ELSE'#13#10 +
        '         CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR;'#13#10 +
        '      IF (SALDOEQ IS NULL) THEN'#13#10 +
        '         SALDOEQ = 0;'#13#10 +
        '       IF (SALDOEQ > 0) THEN'#13#10 +
        '         EQDEBITSALDO = EQDEBITSALDO + SALDOEQ;'#13#10 +
        '       ELSE'#13#10 +
        '         EQCREDITSALDO = EQCREDITSALDO - SALDOEQ;'#13#10 +
        '    END '#13#10 +
        '  END '#13#10;
        ibsqlR.Next
      end;
      Result := Result + FieldList +
        'BEGIN '#13#10 +
        '  DEBITSALDO = 0; '#13#10 +
        '  CREDITSALDO = 0; '#13#10 +
        '  CURRDEBITSALDO = 0; '#13#10 +
        '  CURRCREDITSALDO = 0; '#13#10 +
        '  EQDEBITSALDO = 0; '#13#10 +
        '  EQCREDITSALDO = 0; '#13#10 +
        TextSQL + '  SUSPEND; '#13#10 +
        'END '#13#10;
    finally
      ibsqlR.Free;
      Tr.Commit;
    end;
  finally
    Tr.Free;
  end;
end;

end.
