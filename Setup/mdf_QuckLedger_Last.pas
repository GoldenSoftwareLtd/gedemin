unit mdf_QuckLedger_Last;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure QuickLedger_last(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
   ProcCount = 4;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName: 'AC_L_S1'; Description: '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    PARAM INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    DATEPARAM INTEGER,'#13#10 +
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
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (:SQLHANDLE = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      JOIN ac_record r1 ON r1.id = e1.recordkey AND e1.entrydate < :abeginentrydate'#13#10 +
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
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin,'#13#10 +
        '         :saldobegincurr;'#13#10 +
        '    if (saldobegin IS NULL) then'#13#10 +
        '      saldobegin = 0;'#13#10 +
        '    if (saldobegincurr IS NULL) then'#13#10 +
        '      saldobegincurr = 0;'#13#10 +
        '    '#13#10 +
        '    C = 0;'#13#10 +
        '    FORCESHOW = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        SUM(e.debitncu - e.creditncu),'#13#10 +
        '        SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '        g_d_getdateparam(e.entrydate, :param)'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        JOIN ac_record r ON r.id = e.recordkey AND'#13#10 +
        '          e.entrydate <= :aendentrydate AND'#13#10 +
        '          e.entrydate >= :abeginentrydate'#13#10 +
        '  '#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      group by 3'#13#10 +
        '      INTO :O,'#13#10 +
        '           :OCURR,'#13#10 +
        '           :dateparam'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = 0;'#13#10 +
        '      CREDITNCUBEGIN = 0;'#13#10 +
        '      DEBITNCUEND = 0;'#13#10 +
        '      CREDITNCUEND = 0;'#13#10 +
        '      DEBITCURRBEGIN = 0;'#13#10 +
        '      CREDITCURRBEGIN = 0;'#13#10 +
        '      DEBITCURREND = 0;'#13#10 +
        '      CREDITCURREND = 0;'#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITNCUEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '      if (SALDOBEGINCURR > 0) then'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      if (SALDOENDCURR > 0) then'#13#10 +
        '        DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '    '#13#10 +
        '      IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '        DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '        CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '      END'#13#10 +
        '      FORCESHOW = 1;'#13#10 +
        '    '#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        '  ELSE'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a'#13#10 +
        '      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate'#13#10 +
        '      AND a.sqlhandle = :sqlhandle '#13#10 +
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
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin,'#13#10 +
        '         :saldobegincurr;'#13#10 +
        '    if (saldobegin IS NULL) then'#13#10 +
        '      saldobegin = 0;'#13#10 +
        '    if (saldobegincurr IS NULL) then'#13#10 +
        '      saldobegincurr = 0;'#13#10 +
        '    '#13#10 +
        '    C = 0;'#13#10 +
        '    FORCESHOW = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        SUM(e.debitncu - e.creditncu),'#13#10 +
        '        SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '        g_d_getdateparam(e.entrydate, :param)'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts a'#13#10 +
        '        JOIN ac_entry e ON a.accountkey = e.accountkey AND'#13#10 +
        '             e.entrydate <= :aendentrydate AND'#13#10 +
        '             e.entrydate >= :abeginentrydate'#13#10 +
        '      AND a.sqlhandle = :sqlhandle '#13#10 +         
        '        LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      group by 3'#13#10 +
        '      INTO :O,'#13#10 +
        '           :OCURR,'#13#10 +
        '           :dateparam'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = 0;'#13#10 +
        '      CREDITNCUBEGIN = 0;'#13#10 +
        '      DEBITNCUEND = 0;'#13#10 +
        '      CREDITNCUEND = 0;'#13#10 +
        '      DEBITCURRBEGIN = 0;'#13#10 +
        '      CREDITCURRBEGIN = 0;'#13#10 +
        '      DEBITCURREND = 0;'#13#10 +
        '      CREDITCURREND = 0;'#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITNCUEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '      if (SALDOBEGINCURR > 0) then'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      if (SALDOENDCURR > 0) then'#13#10 +
        '        DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '    '#13#10 +
        '      IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '        DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '        CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '      END'#13#10 +
        '      FORCESHOW = 1;'#13#10 +
        '  '#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        '  '#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_L_S'; Description:
        '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ENTRYDATE DATE,'#13#10 +
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
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (:SQLHANDLE = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      JOIN ac_record r1 ON r1.id = e1.recordkey AND e1.entrydate < :abeginentrydate'#13#10 +
        '    WHERE'#13#10 +
        '      (r1.companykey + 0 = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r1.companykey  + 0 IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin,'#13#10 +
        '         :saldobegincurr;'#13#10 +
        ''#13#10 +
        '    IF (saldobegin IS NULL) THEN'#13#10 +
        '      saldobegin = 0;'#13#10 +
        '    IF (saldobegincurr IS NULL) THEN'#13#10 +
        '      saldobegincurr = 0;'#13#10 +
        '  '#13#10 +
        '    C = 0;'#13#10 +
        '    FORCESHOW = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        e.entrydate,'#13#10 +
        '        SUM(e.debitncu - e.creditncu),'#13#10 +
        '        SUM(e.debitcurr - e.creditcurr)'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        JOIN ac_record r ON r.id = e.recordkey AND'#13#10 +
        '        e.entrydate <= :aendentrydate AND'#13#10 +
        '        e.entrydate >= :abeginentrydate'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY e.entrydate'#13#10 +
        '      INTO :ENTRYDATE,'#13#10 +
        '           :O,'#13#10 +
        '           :OCURR'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = 0;'#13#10 +
        '      CREDITNCUBEGIN = 0;'#13#10 +
        '      DEBITNCUEND = 0;'#13#10 +
        '      CREDITNCUEND = 0;'#13#10 +
        '      DEBITCURRBEGIN = 0;'#13#10 +
        '      CREDITCURRBEGIN = 0;'#13#10 +
        '      DEBITCURREND = 0;'#13#10 +
        '      CREDITCURREND = 0;'#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITNCUEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '      if (SALDOBEGINCURR > 0) then'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      if (SALDOENDCURR > 0) then'#13#10 +
        '        DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      ENTRYDATE = :abeginentrydate;'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '  '#13#10 +
        '      IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '        DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '        CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '      END'#13#10 +
        '  '#13#10 +
        '      FORCESHOW = 1;'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        '  ELSE'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a JOIN'#13#10 +
        '      ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate'#13#10 +
        '      AND a.sqlhandle = :sqlhandle '#13#10 + 
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      (r1.companykey + 0 = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r1.companykey  + 0 IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin,'#13#10 +
        '         :saldobegincurr;'#13#10 +
        ''#13#10 +
        '    IF (saldobegin IS NULL) THEN'#13#10 +
        '      saldobegin = 0;'#13#10 +
        '    IF (saldobegincurr IS NULL) THEN'#13#10 +
        '      saldobegincurr = 0;'#13#10 +
        '  '#13#10 +
        '    C = 0;'#13#10 +
        '    FORCESHOW = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        e.entrydate,'#13#10 +
        '        SUM(e.debitncu - e.creditncu),'#13#10 +
        '        SUM(e.debitcurr - e.creditcurr)'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts a'#13#10 +
        '        JOIN ac_entry e ON a.accountkey = e.accountkey AND'#13#10 +
        '            e.entrydate <= :aendentrydate AND'#13#10 +
        '            e.entrydate >= :abeginentrydate'#13#10 +
        '            AND a.sqlhandle = :sqlhandle '#13#10 +
        '        JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY e.entrydate'#13#10 +
        '      INTO :ENTRYDATE,'#13#10 +
        '           :O,'#13#10 +
        '           :OCURR'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = 0;'#13#10 +
        '      CREDITNCUBEGIN = 0;'#13#10 +
        '      DEBITNCUEND = 0;'#13#10 +
        '      CREDITNCUEND = 0;'#13#10 +
        '      DEBITCURRBEGIN = 0;'#13#10 +
        '      CREDITCURRBEGIN = 0;'#13#10 +
        '      DEBITCURREND = 0;'#13#10 +
        '      CREDITCURREND = 0;'#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITNCUEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '      if (SALDOBEGINCURR > 0) then'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      if (SALDOENDCURR > 0) then'#13#10 +
        '        DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '      else'#13#10 +
        '        CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      ENTRYDATE = :abeginentrydate;'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        ''#13#10 +
        '      IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '        DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '        CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '      END'#13#10 +
        ''#13#10 +
        '      FORCESHOW = 1;'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_Q_S'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ENTRYDATE DATE,'#13#10 +
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
        'BEGIN'#13#10 +
        '  IF (:sqlhandle = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT'#13#10 +
        '      IIF(SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
        '        SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      JOIN ac_record r1 ON r1.id = e1.recordkey AND e1.entrydate < :abeginentrydate '#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
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
        '        e.entrydate,'#13#10 +
        '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '          SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        JOIN ac_record r ON r.id = e.recordkey AND'#13#10 +
        '          e.entrydate <= :aendentrydate AND'#13#10 +
        '          e.entrydate >= :abeginentrydate'#13#10 +
        '        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
        '          q.valuekey = :valuekey'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY e.entrydate'#13#10 +
        '      INTO :ENTRYDATE,'#13#10 +
        '           :O'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (O IS NULL) THEN O = 0;'#13#10 +
        '      DEBITBEGIN = 0;'#13#10 +
        '      CREDITBEGIN = 0;'#13#10 +
        '      DEBITEND = 0;'#13#10 +
        '      CREDITEND = 0;'#13#10 +
        '      DEBIT = 0;'#13#10 +
        '      CREDIT = 0;'#13#10 +
        '      IF (O > 0) THEN'#13#10 +
        '        DEBIT = :O;'#13#10 +
        '      ELSE'#13#10 +
        '        CREDIT = - :O;'#13#10 +
        '  '#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITEND =  - :SALDOEND;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      ENTRYDATE = :abeginentrydate;'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '  END'#13#10 +
        '  ELSE'#13#10 +
        '  BEGIN'#13#10 +
        ''#13#10 +
        '    SELECT'#13#10 +
        '      IIF(SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
        '        SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a'#13#10 +
        '      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND'#13#10 +
        '        e1.entrydate < :abeginentrydate'#13#10 +
        '      AND a.sqlhandle = :sqlhandle '#13#10 + 
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
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
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      q.valuekey = :valuekey AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin;'#13#10 +
        '    if (saldobegin IS NULL) then'#13#10 +
        '      saldobegin = 0;'#13#10 +
        '  '#13#10 +
        '    C = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        e.entrydate,'#13#10 +
        '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '          SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts a'#13#10 +
        '        JOIN ac_entry e ON a.accountkey = e.accountkey AND'#13#10 +
        '          e.entrydate <= :aendentrydate AND'#13#10 +
        '          e.entrydate >= :abeginentrydate'#13#10 +
        '          AND a.sqlhandle = :sqlhandle '#13#10 + 
        '        LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
        '          q.valuekey = :valuekey'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY e.entrydate'#13#10 +
        '      INTO :ENTRYDATE,'#13#10 +
        '           :O'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (O IS NULL) THEN O = 0;'#13#10 +
        '      DEBITBEGIN = 0;'#13#10 +
        '      CREDITBEGIN = 0;'#13#10 +
        '      DEBITEND = 0;'#13#10 +
        '      CREDITEND = 0;'#13#10 +
        '      DEBIT = 0;'#13#10 +
        '      CREDIT = 0;'#13#10 +
        '      IF (O > 0) THEN'#13#10 +
        '        DEBIT = :O;'#13#10 +
        '      ELSE'#13#10 +
        '        CREDIT = - :O;'#13#10 +
        '  '#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITEND =  - :SALDOEND;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      ENTRYDATE = :abeginentrydate;'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '  END'#13#10 +
          'END'),
     (ProcedureName: 'AC_Q_S1'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    PARAM INTEGER,'#13#10 +
        '    CURRKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    DATEPARAM INTEGER,'#13#10 +
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
        'BEGIN'#13#10 +
        '  IF (:sqlhandle = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SALDOBEGIN = 0;'#13#10 +
        '    SELECT'#13#10 +
        '      SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
        '    WHERE'#13#10 +
        '      e1.entrydate < :abeginentrydate AND'#13#10 +
        '      (r1.companykey + 0 = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r1.companykey + 0 IN ('#13#10 +
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
        ''#13#10 +
        '    if (SALDOBEGIN IS NULL) THEN'#13#10 +
        '      SALDOBEGIN = 0;'#13#10 +
        '  '#13#10 +
        '    C = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        g_d_getdateparam(e.entrydate, :param),'#13#10 +
        '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '          SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e'#13#10 +
        '        LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey'#13#10 +
        '      WHERE'#13#10 +
        '        e.entrydate <= :aendentrydate AND'#13#10 +
        '        e.entrydate >= :abeginentrydate AND'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY 1'#13#10 +
        '      INTO :dateparam,'#13#10 +
        '           :O'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (O IS NULL) THEN O = 0;'#13#10 +
        '      DEBITBEGIN = 0;'#13#10 +
        '      CREDITBEGIN = 0;'#13#10 +
        '      DEBITEND = 0;'#13#10 +
        '      CREDITEND = 0;'#13#10 +
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
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        '  ELSE'#13#10 +
        '  BEGIN'#13#10 +
        ''#13#10 +
        '    SALDOBEGIN = 0;'#13#10 +
        '    SELECT'#13#10 +
        '      SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e1.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_accounts a'#13#10 +
        '      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND'#13#10 +
        '        e1.entrydate < :abeginentrydate'#13#10 +
        '        AND a.sqlhandle = :sqlhandle '#13#10 + 
        '      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
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
        '      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '      q.valuekey = :valuekey AND'#13#10 +
        '      ((0 = :currkey) OR (e1.currkey = :currkey))'#13#10 +
        '    INTO :saldobegin;'#13#10 +
        '  '#13#10 +
        '    if (SALDOBEGIN IS NULL) THEN'#13#10 +
        '      SALDOBEGIN = 0;'#13#10 +
        '  '#13#10 +
        '    C = 0;'#13#10 +
        '    FOR'#13#10 +
        '      SELECT'#13#10 +
        '        g_d_getdateparam(e.entrydate, :param),'#13#10 +
        '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '          SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '      FROM'#13#10 +
        '        ac_ledger_accounts a'#13#10 +
        '        JOIN ac_entry e ON a.accountkey = e.accountkey AND'#13#10 +
        '          e.entrydate <= :aendentrydate AND'#13#10 +
        '          e.entrydate >= :abeginentrydate'#13#10 +
        '          AND a.sqlhandle = :sqlhandle '#13#10 + 
        '        LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey'#13#10 +
        '      WHERE'#13#10 +
        '        (r.companykey + 0 = :companykey OR'#13#10 +
        '        (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '        r.companykey + 0 IN ('#13#10 +
        '          SELECT'#13#10 +
        '            h.companykey'#13#10 +
        '          FROM'#13#10 +
        '            gd_holding h'#13#10 +
        '          WHERE'#13#10 +
        '            h.holdingkey = :companykey))) AND'#13#10 +
        '        G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
        '        ((0 = :currkey) OR (e.currkey = :currkey))'#13#10 +
        '      GROUP BY 1'#13#10 +
        '      INTO :dateparam,'#13#10 +
        '           :O'#13#10 +
        '    DO'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (O IS NULL) THEN O = 0;'#13#10 +
        '      DEBITBEGIN = 0;'#13#10 +
        '      CREDITBEGIN = 0;'#13#10 +
        '      DEBITEND = 0;'#13#10 +
        '      CREDITEND = 0;'#13#10 +
        '      DEBIT = 0;'#13#10 +
        '      CREDIT = 0;'#13#10 +
        '      IF (O > 0) THEN'#13#10 +
        '        DEBIT = :O;'#13#10 +
        '      ELSE'#13#10 +
        '        CREDIT = - :O;'#13#10 +
        '  '#13#10 +
        '      SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '      if (SALDOBEGIN > 0) then'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      else'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      if (SALDOEND > 0) then'#13#10 +
        '        DEBITEND = :SALDOEND;'#13#10 +
        '      else'#13#10 +
        '        CREDITEND =  - :SALDOEND;'#13#10 +
        '      SUSPEND;'#13#10 +
        '      SALDOBEGIN = :SALDOEND;'#13#10 +
        '      C = C + 1;'#13#10 +
        '    END'#13#10 +
        '    /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '    IF (C = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '      IF (SALDOBEGIN > 0) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '        DEBITEND = :SALDOBEGIN;'#13#10 +
        '      END ELSE'#13#10 +
        '      BEGIN'#13#10 +
        '        CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '        CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '      END'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '  END'#13#10 +
        'END')
   );

procedure QuickLedger_last(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin

  for I := 0 to ProcCount - 1 do
  begin
     Log(Format('Изменение процедуры %s ', [Procs[i].ProcedureName]));
    if ProcedureExist(Procs[i], IBDB) then
      AlterProcedure(Procs[i], IBDB)
    else
      CreateProcedure(Procs[i], IBDB)
  end;
end;

end.
