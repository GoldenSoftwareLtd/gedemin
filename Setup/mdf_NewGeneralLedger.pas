unit mdf_NewGeneralLedger;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure NewGeneralLedger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

const
   ProcCount = 3;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName:'AC_G_L_S'; Description:
        '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER,'#13#10 +
        '    ANALYTICFIELD VARCHAR(60))'#13#10 +
        'RETURNS ('#13#10 +
        '    M INTEGER,'#13#10 +
        '    Y INTEGER,'#13#10 +
        '    BEGINDATE DATE,'#13#10 +
        '    ENDDATE DATE,'#13#10 +
        '    DEBITNCUBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITNCUBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBITNCUEND NUMERIC(15,4),'#13#10 +
        '    CREDITNCUEND NUMERIC(15,4),'#13#10 +
        '    DEBITCURRBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITCURRBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBITCURREND NUMERIC(15,4),'#13#10 +
        '    CREDITCURREND NUMERIC(15,4),'#13#10 +
        '    FORCESHOW INTEGER)'#13#10 +
        'AS'#13#10 +
        'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINDEBIT NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCREDIT NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDDEBIT NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCREDIT NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINDEBITCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCREDITCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDDEBITCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCREDITCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SD NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SC NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SDC NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SCC NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'DECLARE VARIABLE ACCOUNTKEY INTEGER;'#13#10 +
        'DECLARE VARIABLE D DATE;'#13#10 +
        'DECLARE VARIABLE DAYINMONTH INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  saldobegindebit = 0;'#13#10 +
        '  saldobegincredit = 0;'#13#10 +
        '  saldobegindebitcurr = 0;'#13#10 +
        '  saldobegincreditcurr = 0;'#13#10 +
        ''#13#10 +
        '  IF (ANALYTICFIELD = '''') THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF((NOT SUM(e1.debitncu - e1.creditncu) IS NULL) AND'#13#10 +
        '        (SUM(e1.debitncu - e1.creditncu) > 0), SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '      IIF((NOT SUM(e1.creditncu - e1.debitncu) IS NULL) AND'#13#10 +
        '        (SUM(e1.creditncu - e1.debitncu) > 0), SUM(e1.creditncu - e1.debitncu),  0),'#13#10 +
        '      IIF((NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL) AND'#13#10 +
        '        (SUM(e1.debitcurr - e1.creditcurr) > 0), SUM(e1.debitcurr - e1.creditcurr),  0),'#13#10 +
        '      IIF((NOT SUM(e1.creditcurr - e1.debitcurr) IS NULL) AND'#13#10 +
        '        (SUM(e1.creditcurr - e1.debitcurr) > 0), SUM(e1.creditcurr - e1.debitcurr),  0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a'#13#10 +
        '      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate'#13#10 +
        '        AND a.sqlhandle = :sqlhandle'#13#10 +
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      (r1.companykey + 0 = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r1.companykey + 0 IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegindebit,'#13#10 +
        '         :saldobegincredit,'#13#10 +
        '         :saldobegindebitcurr,'#13#10 +
        '         :saldobegincreditcurr;'#13#10 +
        '  END ELSE'#13#10 +
        '  BEGIN'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        la.accountkey'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts la'#13#10 +
        '      WHERE'#13#10 +
        '        la.sqlhandle = :sqlhandle'#13#10 +
        '      INTO :accountkey'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      SELECT'#13#10 +
        '        a.DEBITSALDO,'#13#10 +
        '        a.CREDITSALDO,'#13#10 +
        '        a.CURRDEBITSALDO,'#13#10 +
        '        a.CURRCREDITSALDO'#13#10 +
        '      FROM'#13#10 +
        '        ac_accountexsaldo(:abeginentrydate, :accountkey, :analyticfield, :companykey,'#13#10 +
        '          :allholdingcompanies, -1, :currkey) a'#13#10 +
        '      INTO :sd,'#13#10 +
        '           :sc,'#13#10 +
        '           :sdc,'#13#10 +
        '           :scc;'#13#10 +
        ''#13#10 +
        '      IF (sd IS NULL) then SD = 0;'#13#10 +
        '      IF (sc IS NULL) then SC = 0;'#13#10 +
        '      IF (sdc IS NULL) then SDC = 0;'#13#10 +
        '      IF (scc IS NULL) then SCC = 0;'#13#10 +
        ''#13#10 +
        '      saldobegindebit = :saldobegindebit + :sd;'#13#10 +
        '      saldobegincredit = :saldobegincredit + :sc;'#13#10 +
        '      saldobegindebitcurr = :saldobegindebitcurr + :sdc;'#13#10 +
        '      saldobegincreditcurr = :saldobegincreditcurr + :scc;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FORCESHOW = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      SUM(e.debitncu - e.creditncu),'#13#10 +
        '      SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '      EXTRACT(MONTH FROM e.entrydate),'#13#10 +
        '      EXTRACT(YEAR FROM e.entrydate)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a'#13#10 +
        '      JOIN ac_entry e ON a.accountkey = e.accountkey AND'#13#10 +
        '           e.entrydate <= :aendentrydate AND'#13#10 +
        '           e.entrydate >= :abeginentrydate'#13#10 +
        '    AND a.sqlhandle = :sqlhandle '#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      (r.companykey + 0 = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey + 0 IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '    group by 3, 4'#13#10 +
        '    ORDER BY 4, 3'#13#10 +
        '    INTO :O, :OCURR, :M, :Y'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    begindate = CAST(:Y || ''-'' || :M || ''-'' || 1 as DATE);'#13#10 +
        '    IF (begindate < :abeginentrydate) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      begindate = :abeginentrydate;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    DAYINMONTH = EXTRACT(DAY FROM g_d_incmonth(1, CAST(:Y || ''-'' || :M || ''-'' || 1 as DATE)) - 1);'#13#10 +
        ''#13#10 +
        '    D = CAST(:Y || ''-'' || :M || ''-'' || :dayinmonth as DATE);'#13#10 +
        ''#13#10 +
        '    IF (D > :aendentrydate) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      D = :aendentrydate;'#13#10 +
        '    END'#13#10 +
        '    ENDDATE = D;'#13#10 +
        '    DEBITNCUBEGIN = 0;'#13#10 +
        '    CREDITNCUBEGIN = 0;'#13#10 +
        '    DEBITNCUEND = 0;'#13#10 +
        '    CREDITNCUEND = 0;'#13#10 +
        '    DEBITCURRBEGIN = 0;'#13#10 +
        '    CREDITCURRBEGIN = 0;'#13#10 +
        '    DEBITCURREND = 0;'#13#10 +
        '    CREDITCURREND = 0;'#13#10 +
        '    IF (analyticfield = '''') THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (:saldobegindebit - :saldobegincredit + :o > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        SALDOENDDEBIT = :saldobegindebit - :saldobegincredit + :o;'#13#10 +
        '        SALDOENDCREDIT = 0;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        SALDOENDDEBIT = 0;'#13#10 +
        '        SALDOENDCREDIT =  - (:saldobegindebit - :saldobegincredit + :o);'#13#10 +
        '      END'#13#10 +
        ''#13#10 +
        '      IF (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        SALDOENDDEBITCURR = :saldobegindebitCURR - :saldobegincreditCURR + :ocurr;'#13#10 +
        '        SALDOENDCREDITCURR = 0;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        SALDOENDDEBITCURR = 0;'#13#10 +
        '        SALDOENDCREDITCURR =  - (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr);'#13#10 +
        '      END'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      saldoenddebit = 0;'#13#10 +
        '      saldoendcredit = 0;'#13#10 +
        '      saldoenddebitcurr = 0;'#13#10 +
        '      saldoendcreditcurr = 0;'#13#10 +
        ''#13#10 +
        '      FOR'#13#10 +
        '        SELECT'#13#10 +
        '          la.accountkey'#13#10 +
        '        FROM'#13#10 +
        '          ac_ledger_accounts la'#13#10 +
        '        WHERE'#13#10 +
        '          la.sqlhandle = :sqlhandle'#13#10 +
        '        INTO :accountkey'#13#10 +
        '      DO'#13#10 +
        '      BEGIN'#13#10 +
        ''#13#10 +
        '        SELECT'#13#10 +
        '          a.DEBITSALDO,'#13#10 +
        '          a.CREDITSALDO,'#13#10 +
        '          a.CURRDEBITSALDO,'#13#10 +
        '          a.CURRCREDITSALDO'#13#10 +
        '        FROM'#13#10 +
        '          ac_accountexsaldo(:d + 1, :accountkey, :analyticfield, :companykey,'#13#10 +
        '            :allholdingcompanies, -1, :currkey) a'#13#10 +
        '        INTO :sd,'#13#10 +
        '             :sc,'#13#10 +
        '             :sdc,'#13#10 +
        '             :scc;'#13#10 +
        ''#13#10 +
        '        IF (sd IS NULL) then SD = 0;'#13#10 +
        '        IF (sc IS NULL) then SC = 0;'#13#10 +
        '        IF (sdc IS NULL) then SDC = 0;'#13#10 +
        '        IF (scc IS NULL) then SCC = 0;'#13#10 +
        '    '#13#10 +
        '        saldoenddebit = :saldoenddebit + :sd;'#13#10 +
        '        saldoendcredit = :saldoendcredit + :sc;'#13#10 +
        '        saldoenddebitcurr = :saldoenddebitcurr + :sdc;'#13#10 +
        '        saldoendcreditcurr = :saldoendcreditcurr + :scc;'#13#10 +
        '      END'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    DEBITNCUBEGIN = :SALDOBEGINDEBIT;'#13#10 +
        '    CREDITNCUBEGIN =  :SALDOBEGINCREDIT;'#13#10 +
        '    DEBITNCUEND = :SALDOENDDEBIT;'#13#10 +
        '    CREDITNCUEND =  :SALDOENDCREDIT;'#13#10 +
        ''#13#10 +
        '    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR;'#13#10 +
        '    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR;'#13#10 +
        '    DEBITCURREND = :SALDOENDDEBITCURR;'#13#10 +
        '    CREDITCURREND =  :SALDOENDCREDITCURR;'#13#10 +
        ''#13#10 +
        '    SUSPEND;'#13#10 +
        ''#13#10 +
        '    SALDOBEGINDEBIT = :SALDOENDDEBIT;'#13#10 +
        '    SALDOBEGINCREDIT = :SALDOENDCREDIT;'#13#10 +
        ''#13#10 +
        '    SALDOBEGINDEBITCURR = :SALDOENDDEBITCURR;'#13#10 +
        '    SALDOBEGINCREDITCURR = :SALDOENDCREDITCURR;'#13#10 +
        ''#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    M = EXTRACT(MONTH FROM :abeginentrydate);'#13#10 +
        '    Y = EXTRACT(YEAR FROM :abeginentrydate);'#13#10 +
        '    DEBITNCUBEGIN = :SALDOBEGINDEBIT;'#13#10 +
        '    CREDITNCUBEGIN =  :SALDOBEGINCREDIT;'#13#10 +
        '    DEBITNCUEND = :SALDOBEGINDEBIT;'#13#10 +
        '    CREDITNCUEND =  :SALDOBEGINCREDIT;'#13#10 +
        ''#13#10 +
        '    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR;'#13#10 +
        '    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR;'#13#10 +
        '    DEBITCURREND = :SALDOBEGINDEBITCURR;'#13#10 +
        '    CREDITCURREND =  :SALDOBEGINCREDITCURR;'#13#10 +
        '    BEGINDATE = :abeginentrydate;'#13#10 +
        '    ENDDATE = :abeginentrydate;'#13#10 +
        ''#13#10 +
        '    FORCESHOW = 1;'#13#10 +
        ''#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName:'AC_Q_G_L'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    DATEBEGIN DATE,'#13#10 +
        '    DATEEND DATE,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    M INTEGER,'#13#10 +
        '    Y INTEGER,'#13#10 +
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
        '  SELECT'#13#10 +
        '    IIF(SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
        '      SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
        '  FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
        '  WHERE'#13#10 +
        '    e1.entrydate < :datebegin AND'#13#10 +
        '    e1.accountkey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        a.accountkey'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts a'#13#10 +
        '      WHERE'#13#10 +
        '        a.sqlhandle = :sqlhandle) AND'#13#10 +
        '    (r1.companykey = :companykey OR'#13#10 +
        '    (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '    r1.companykey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        h.companykey'#13#10 +
        '      FROM'#13#10 +
        '        gd_holding h'#13#10 +
        '      WHERE'#13#10 +
        '        h.holdingkey = :companykey))) AND'#13#10 +
        '    q.valuekey = :valuekey AND'#13#10 +
        '    ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '  INTO :saldobegin;'#13#10 +
        '  if (saldobegin IS NULL) then'#13#10 +
        '    saldobegin = 0;'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      EXTRACT(MONTH FROM e.entrydate),'#13#10 +
        '      EXTRACT(YEAR FROM e.entrydate),'#13#10 +
        '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
        '        q.valuekey = :valuekey'#13#10 +
        '    WHERE'#13#10 +
        '      e.entrydate <= :dateend AND'#13#10 +
        '      e.entrydate >= :datebegin AND'#13#10 +
        '      e.accountkey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          a.accountkey'#13#10 +
        '        FROM'#13#10 +
        '          ac_ledger_accounts a'#13#10 +
        '        WHERE'#13#10 +
        '          a.sqlhandle = :sqlhandle'#13#10 +
        '      ) AND'#13#10 +
        '      (r.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '    GROUP BY 1, 2'#13#10 +
        '    ORDER BY 2, 1'#13#10 +
        '    INTO :M, :Y, :O'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    IF (O IS NULL) THEN O = 0;'#13#10 +
        '    DEBITBEGIN = 0;'#13#10 +
        '    CREDITBEGIN = 0;'#13#10 +
        '    DEBITEND = 0;'#13#10 +
        '    CREDITEND = 0;'#13#10 +
        '    DEBIT = 0;'#13#10 +
        '    CREDIT = 0;'#13#10 +
        '    IF (O > 0) THEN'#13#10 +
        '      DEBIT = :O;'#13#10 +
        '    ELSE'#13#10 +
        '      CREDIT = - :O;'#13#10 +
        ''#13#10 +
        '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '    if (SALDOBEGIN > 0) then'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '    else'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '    if (SALDOEND > 0) then'#13#10 +
        '      DEBITEND = :SALDOEND;'#13#10 +
        '    else'#13#10 +
        '      CREDITEND =  - :SALDOEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    C = C + 1;'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    M = EXTRACT(MONTH FROM :datebegin);'#13#10 +
        '    Y = EXTRACT(YEAR FROM :datebegin);'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        '    DEBIT = 0;'#13#10 +
        '    CREDIT = 0;'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_L_Q'; Description:
        '('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ACCOUNTKEY INTEGER,'#13#10 +
        '    AACCOUNTPART VARCHAR(1))'#13#10 +
        'RETURNS ('#13#10 +
        '    DEBITQUANTITY NUMERIC(15,4),'#13#10 +
        '    CREDITQUANTITY NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        'DECLARE VARIABLE ACCOUNTPART VARCHAR(1);'#13#10 +
        'DECLARE VARIABLE QUANTITY NUMERIC(15,4);'#13#10 +
        'begin'#13#10 +
        '  SELECT'#13#10 +
        '    e.accountpart,'#13#10 +
        '    q.quantity'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e'#13#10 +
        '    LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND'#13#10 +
        '      e1.accountpart <> e.accountpart '#13#10 +
        '    LEFT JOIN ac_quantity q ON q.entrykey = iif(e.issimple = 1 and e1.issimple = 1,'#13#10 +
        '      e.id, iif(e.issimple = 0, e.id, e1.id))'#13#10 +
        '  WHERE'#13#10 +
        '    e.id = :entrykey AND'#13#10 +
        '    q.valuekey = :valuekey AND'#13#10 +
        '    e1.accountkey = :accountkey'#13#10 +
        '  INTO'#13#10 +
        '    :accountpart,'#13#10 +
        '    :quantity;'#13#10 +
        '  IF (quantity IS NULL) THEN'#13#10 +
        '    quantity = 0;'#13#10 +
        ''#13#10 +
        '  debitquantity = 0;'#13#10 +
        '  creditquantity = 0;'#13#10 +
        '  IF (accountpart = ''D'') THEN'#13#10 +
        '    debitquantity = :quantity;'#13#10 +
        '  ELSE'#13#10 +
        '    creditquantity = :quantity;'#13#10 +
        ''#13#10 +
        '  suspend;'#13#10 +
        'END')
   );

procedure NewGeneralLedger(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  for I := 0 to ProcCount - 1 do
  begin
    Log(Format('Добавление процедуры %s', [Procs[I].ProcedureName]));
    try
      if ProcedureExist(Procs[i], IBDB) then
        AlterProcedure(Procs[i], IBDB)
      else
        CreateProcedure(Procs[i], IBDB);
    except
      on E: Exception do
        Log('Ошибка:' +  E.Message);
    end;
  end;
end;



end.
