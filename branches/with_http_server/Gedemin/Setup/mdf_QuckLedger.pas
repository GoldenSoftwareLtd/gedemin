unit mdf_QuckLedger;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure QuickLedger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  AC_LEDGER_ENTRIES: TmdfTable = (TableName: 'AC_LEDGER_ENTRIES';
    Description:'('#13#10 +
      'ENTRYKEY   DINTKEY NOT NULL,'#13#10 +
      'SQLHANDLE  DINTKEY NOT NULL'#13#10 +
      ');'#13#10 +
      'ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT PK_AC_LEDGER_ENTRIES PRIMARY KEY (SQLHANDLE, ENTRYKEY);'#13#10 +
      'ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT FK_AC_LEDGER_ENTRIES FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE;'
    );
  TriggerCount = 2;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'AC_BI_ENTRY_ISSIMPLE'; Description:
      'FOR AC_ENTRY'#13#10 +
      'ACTIVE BEFORE INSERT POSITION 0'#13#10 +
      'AS'#13#10 +
      'begin'#13#10 +
      '  if (exists(select'#13#10 +
      '    e.id'#13#10 +
      '  from'#13#10 +
      '    ac_entry e'#13#10 +
      '  where'#13#10 +
      '    e.recordkey = new.recordkey'#13#10 +
      '    and'#13#10 +
      '    e.accountpart = new.accountpart'#13#10 +
      '    and'#13#10 +
      '    e.id != new.id))'#13#10 +
      '  then'#13#10 +
      '  begin'#13#10 +
      '    new.issimple = 0;'#13#10 +
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 1'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart != new.accountpart;'#13#10 +
      ''#13#10 +
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 0'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart = new.accountpart;'#13#10 +
      '  end'#13#10 +
      '  else'#13#10 +
      '  begin'#13#10 +
      '    new.issimple = 1;'#13#10 +
      '    update'#13#10 +
      '      ac_entry e'#13#10 +
      '    set'#13#10 +
      '      e.issimple = 0'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = new.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart != new.accountpart;'#13#10 +
      '  end'#13#10 +
      'end'),
    (TriggerName:  'AC_AD_ENTRY_ISSIMPLE'; Description:
      'FOR AC_ENTRY'#13#10 +
      'ACTIVE AFTER DELETE POSITION 0'#13#10 +
      'AS'#13#10 +
      'declare variable CountEntry integer;'#13#10 +
      'begin'#13#10 +
      '  CountEntry = 0;'#13#10 +
      '  if (old.issimple = 0) then'#13#10 +
      '  begin'#13#10 +
      '    select'#13#10 +
      '      count(e.id)'#13#10 +
      '    from'#13#10 +
      '      ac_entry e'#13#10 +
      '    where'#13#10 +
      '      e.recordkey = old.recordkey'#13#10 +
      '      and'#13#10 +
      '      e.accountpart = old.accountpart'#13#10 +
      '      and'#13#10 +
      '      e.id != old.id'#13#10 +
      '    into :CountEntry;'#13#10 +
      '    if ( CountEntry = 1)'#13#10 +
      '    then'#13#10 +
      '    begin'#13#10 +
      '      update'#13#10 +
      '        ac_entry e'#13#10 +
      '      set'#13#10 +
      '        e.issimple = 1'#13#10 +
      '      where'#13#10 +
      '        e.recordkey = old.recordkey'#13#10 +
      '        and'#13#10 +
      '        e.accountpart = old.accountpart;'#13#10 +
      '    end'#13#10 +
      '  end'#13#10 +
      'end')
  );

  ISSIMPLE: TmdfField = (
    RelationName: 'AC_ENTRY'; FieldName: 'ISSIMPLE'; Description: 'DBOOLEAN_NOTNULL');

  {
  SET_ISSIMPLE_ENTRY: TmdfStoredProcedure = (ProcedureName: 'SET_ISSIMPLE_ENTRY';
    Description:'AS'#13#10 +
      '/*Версия 1*/'#13#10 +
      'DECLARE VARIABLE RECORDKEY INTEGER;'#13#10 +
      'DECLARE VARIABLE ACCOUNTPART CHAR(1);'#13#10 +
      'DECLARE VARIABLE COUNTENTRY INTEGER;'#13#10 +
      'begin'#13#10 +
      '  for'#13#10 +
      '    select'#13#10 +
      '      e1.recordkey, e1.accountpart, count(e1.id)'#13#10 +
      '    from'#13#10 +
      '      ac_entry e1'#13#10 +
      '      where'#13#10 +
      '        CAST(e1.entrydate AS INTEGER) >= GEN_ID(gd_g_block, 0)'#13#10 +
      '    group by'#13#10 +
      '      e1.recordkey, e1.accountpart'#13#10 +
      '    into :RECORDKEY, :ACCOUNTPART, :COUNTENTRY'#13#10 +
      '  do'#13#10 +
      '  begin'#13#10 +
      '    if (COUNTENTRY > 1) then'#13#10 +
      '      update'#13#10 +
      '        ac_entry e'#13#10 +
      '      set'#13#10 +
      '        e.issimple = 0'#13#10 +
      '      where'#13#10 +
      '        e.recordkey = :RECORDKEY'#13#10 +
      '        and'#13#10 +
      '        e.accountpart = :ACCOUNTPART;'#13#10 +
      '    else'#13#10 +
      '      update'#13#10 +
      '        ac_entry e'#13#10 +
      '      set'#13#10 +
      '        e.issimple = 1'#13#10 +
      '      where'#13#10 +
      '        e.recordkey = :RECORDKEY'#13#10 +
      '        and'#13#10 +
      '        e.accountpart = :ACCOUNTPART;'#13#10 +
      '  end'#13#10 +
      'end');
   }   

   ProcCount = 10;

   Procs: array[0..ProcCount - 1] of TmdfStoredProcedure = (
     (ProcedureName: 'AC_L_S1'; Description: '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER,'#13#10 +
        '    PARAM INTEGER)'#13#10 +
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
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT'#13#10 +
        '    IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '    IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e1'#13#10 +
        '    LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '  WHERE'#13#10 +
        '    e1.entrydate < :abeginentrydate AND'#13#10 +
        '    ((:SQLHandle = 0) OR'#13#10 +
        '    (:SQLHandle > 0 AND e1.accountkey IN('#13#10 +
        '       SELECT'#13#10 +
        '         a.accountkey'#13#10 +
        '       FROM'#13#10 +
        '         ac_ledger_accounts a'#13#10 +
        '       WHERE'#13#10 +
        '        a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '    (r1.companykey = :companykey OR'#13#10 +
        '    (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '    r1.companykey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        h.companykey'#13#10 +
        '      FROM'#13#10 +
        '        gd_holding h'#13#10 +
        '      WHERE'#13#10 +
        '        h.holdingkey = :companykey))) AND'#13#10 +
        '    G_SEC_TEST(r1.aview, :ingroup) <> 0'#13#10 +
        '  INTO :saldobegin,'#13#10 +
        '       :saldobegincurr;'#13#10 +
        '  if (saldobegin IS NULL) then'#13#10 +
        '    saldobegin = 0;'#13#10 +
        '  if (saldobegincurr IS NULL) then'#13#10 +
        '    saldobegincurr = 0;'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FORCESHOW = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      SUM(e.debitncu - e.creditncu),'#13#10 +
        '      SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '      g_d_getdateparam(e.entrydate, :param)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      e.entrydate <= :aendentrydate AND'#13#10 +
        '      e.entrydate >= :abeginentrydate AND'#13#10 +
        '      ((:SQLHandle = 0) OR'#13#10 +
        '      (:SQLHandle > 0 AND e.accountkey IN('#13#10 +
        '         SELECT'#13#10 +
        '           a.accountkey'#13#10 +
        '         FROM'#13#10 +
        '           ac_ledger_accounts a'#13#10 +
        '         WHERE'#13#10 +
        '           a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '      (r.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r.aview, :ingroup) <> 0'#13#10 +
        '    group by 3'#13#10 +
        '    INTO :O,'#13#10 +
        '         :OCURR,'#13#10 +
        '         :dateparam'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    DEBITNCUBEGIN = 0;'#13#10 +
        '    CREDITNCUBEGIN = 0;'#13#10 +
        '    DEBITNCUEND = 0;'#13#10 +
        '    CREDITNCUEND = 0;'#13#10 +
        '    DEBITCURRBEGIN = 0;'#13#10 +
        '    CREDITCURRBEGIN = 0;'#13#10 +
        '    DEBITCURREND = 0;'#13#10 +
        '    CREDITCURREND = 0;'#13#10 +
        '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '    if (SALDOBEGIN > 0) then'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '    if (SALDOEND > 0) then'#13#10 +
        '      DEBITNCUEND = :SALDOEND;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '    if (SALDOBEGINCURR > 0) then'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '    if (SALDOENDCURR > 0) then'#13#10 +
        '      DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '    END'#13#10 +
        '    FORCESHOW = 1;'#13#10 +
        ''#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_L_S'; Description:
        '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER)'#13#10 +
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
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT'#13#10 +
        '    IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),'#13#10 +
        '    IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0)'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e1'#13#10 +
        '    LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '  WHERE'#13#10 +
        '    e1.entrydate < :abeginentrydate AND'#13#10 +
        '    ((:SQLHandle = 0) OR'#13#10 +
        '    (:SQLHandle > 0 AND e1.accountkey IN('#13#10 +
        '       SELECT'#13#10 +
        '         a.accountkey'#13#10 +
        '       FROM'#13#10 +
        '         ac_ledger_accounts a'#13#10 +
        '       WHERE'#13#10 +
        '        a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '    (r1.companykey = :companykey OR'#13#10 +
        '    (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '    r1.companykey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        h.companykey'#13#10 +
        '      FROM'#13#10 +
        '        gd_holding h'#13#10 +
        '      WHERE'#13#10 +
        '        h.holdingkey = :companykey))) AND'#13#10 +
        '    G_SEC_TEST(r1.aview, :ingroup) <> 0'#13#10 +
        '  INTO :saldobegin,'#13#10 +
        '       :saldobegincurr;'#13#10 +
        '  IF (saldobegin IS NULL) THEN'#13#10 +
        '    saldobegin = 0;'#13#10 +
        '  IF (saldobegincurr IS NULL) THEN'#13#10 +
        '    saldobegincurr = 0;'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FORCESHOW = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      e.entrydate,'#13#10 +
        '      SUM(e.debitncu - e.creditncu),'#13#10 +
        '      SUM(e.debitcurr - e.creditcurr)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      e.entrydate <= :aendentrydate AND'#13#10 +
        '      e.entrydate >= :abeginentrydate AND'#13#10 +
        '      ((:SQLHandle = 0) OR'#13#10 +
        '      (:SQLHandle > 0 AND e.accountkey IN('#13#10 +
        '         SELECT'#13#10 +
        '           a.accountkey'#13#10 +
        '         FROM'#13#10 +
        '           ac_ledger_accounts a'#13#10 +
        '         WHERE'#13#10 +
        '           a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '      (r.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r.aview, :ingroup) <> 0'#13#10 +
        '    GROUP BY e.entrydate'#13#10 +
        '    INTO :ENTRYDATE,'#13#10 +
        '         :O,'#13#10 +
        '         :OCURR'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    DEBITNCUBEGIN = 0;'#13#10 +
        '    CREDITNCUBEGIN = 0;'#13#10 +
        '    DEBITNCUEND = 0;'#13#10 +
        '    CREDITNCUEND = 0;'#13#10 +
        '    DEBITCURRBEGIN = 0;'#13#10 +
        '    CREDITCURRBEGIN = 0;'#13#10 +
        '    DEBITCURREND = 0;'#13#10 +
        '    CREDITCURREND = 0;'#13#10 +
        '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '    if (SALDOBEGIN > 0) then'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '    if (SALDOEND > 0) then'#13#10 +
        '      DEBITNCUEND = :SALDOEND;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '    if (SALDOBEGINCURR > 0) then'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '    if (SALDOENDCURR > 0) then'#13#10 +
        '      DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    ENTRYDATE = :abeginentrydate;'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    FORCESHOW = 1;'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_E_L_S'; Description:
        '('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    SALDOBEGIN NUMERIC(18,4),'#13#10 +
        '    SALDOBEGINCURR NUMERIC(18,4),'#13#10 +
        '    SQLHANDLE INTEGER)'#13#10 +
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
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (saldobegin IS NULL) THEN'#13#10 +
        '    saldobegin = 0;'#13#10 +
        '  IF (saldobegincurr IS NULL) THEN'#13#10 +
        '    saldobegincurr = 0;'#13#10 +
        '  C = 0;'#13#10 +
        '  FORCESHOW = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      e.entrydate,'#13#10 +
        '      SUM(e.debitncu - e.creditncu),'#13#10 +
        '      SUM(e.debitcurr - e.creditcurr)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_entries le'#13#10 +
        '      LEFT JOIN ac_entry e ON le.entrykey = e.id'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      le.sqlhandle = :sqlhandle'#13#10 +
        '    group by e.entrydate'#13#10 +
        '    INTO :ENTRYDATE,'#13#10 +
        '         :O,'#13#10 +
        '         :OCURR'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    DEBITNCUBEGIN = 0;'#13#10 +
        '    CREDITNCUBEGIN = 0;'#13#10 +
        '    DEBITNCUEND = 0;'#13#10 +
        '    CREDITNCUEND = 0;'#13#10 +
        '    DEBITCURRBEGIN = 0;'#13#10 +
        '    CREDITCURRBEGIN = 0;'#13#10 +
        '    DEBITCURREND = 0;'#13#10 +
        '    CREDITCURREND = 0;'#13#10 +
        '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '    if (SALDOBEGIN > 0) then'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '    if (SALDOEND > 0) then'#13#10 +
        '      DEBITNCUEND = :SALDOEND;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '    if (SALDOBEGINCURR > 0) then'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '    if (SALDOENDCURR > 0) then'#13#10 +
        '      DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    ENTRYDATE = :abeginentrydate;'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    FORCESHOW = 1;'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_E_L_S1'; Description:'('#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    SALDOBEGIN NUMERIC(18,4),'#13#10 +
        '    SALDOBEGINCURR NUMERIC(18,4),'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    PARAM INTEGER)'#13#10 +
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
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (saldobegin IS NULL) THEN'#13#10 +
        '    saldobegin = 0;'#13#10 +
        '  IF (saldobegincurr IS NULL) THEN'#13#10 +
        '    saldobegincurr = 0;'#13#10 +
        '  C = 0;'#13#10 +
        '  FORCESHOW = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      SUM(e.debitncu - e.creditncu),'#13#10 +
        '      SUM(e.debitcurr - e.creditcurr),'#13#10 +
        '      g_d_getdateparam(e.entrydate, :param)'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_entries le'#13#10 +
        '      LEFT JOIN ac_entry e ON le.entrykey = e.id'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '    WHERE'#13#10 +
        '      le.sqlhandle = :sqlhandle'#13#10 +
        '    group by 3'#13#10 +
        '    INTO :O,'#13#10 +
        '         :OCURR,'#13#10 +
        '         :dateparam'#13#10 +
        '  DO'#13#10 +
        '  BEGIN'#13#10 +
        '    DEBITNCUBEGIN = 0;'#13#10 +
        '    CREDITNCUBEGIN = 0;'#13#10 +
        '    DEBITNCUEND = 0;'#13#10 +
        '    CREDITNCUEND = 0;'#13#10 +
        '    DEBITCURRBEGIN = 0;'#13#10 +
        '    CREDITCURRBEGIN = 0;'#13#10 +
        '    DEBITCURREND = 0;'#13#10 +
        '    CREDITCURREND = 0;'#13#10 +
        '    SALDOEND = :SALDOBEGIN + :O;'#13#10 +
        '    if (SALDOBEGIN > 0) then'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '    if (SALDOEND > 0) then'#13#10 +
        '      DEBITNCUEND = :SALDOEND;'#13#10 +
        '    else'#13#10 +
        '      CREDITNCUEND =  - :SALDOEND;'#13#10 +
        '    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;'#13#10 +
        '    if (SALDOBEGINCURR > 0) then'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '    if (SALDOENDCURR > 0) then'#13#10 +
        '      DEBITCURREND = :SALDOENDCURR;'#13#10 +
        '    else'#13#10 +
        '      CREDITCURREND =  - :SALDOENDCURR;'#13#10 +
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    SALDOBEGINCURR = :SALDOENDCURR;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITNCUBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITNCUEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITNCUBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITNCUEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    IF (SALDOBEGINCURR > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITCURRBEGIN = :SALDOBEGINCURR;'#13#10 +
        '      DEBITCURREND = :SALDOBEGINCURR;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITCURRBEGIN =  - :SALDOBEGINCURR;'#13#10 +
        '      CREDITCURREND =  - :SALDOBEGINCURR;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    FORCESHOW = 1;'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_E_Q_S1'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    SALDOBEGIN NUMERIC(15,4),'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    PARAM INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    DATEPARAM INTEGER,'#13#10 +
        '    DEBITBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITEND NUMERIC(15,4),'#13#10 +
        '    CREDITEND NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  C = 0;'#13#10 +
        '  if (SALDOBEGIN IS NULL) THEN'#13#10 +
        '    SALDOBEGIN = 0;'#13#10 +
        ''#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      g_d_getdateparam(e.entrydate, :param),'#13#10 +
        '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_entries le'#13#10 +
        '      LEFT JOIN ac_entry e ON le.entrykey = e.id'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey'#13#10 +
        '    WHERE'#13#10 +
        '      le.sqlhandle = :SQLHANDLE'#13#10 +
        '    GROUP BY 1'#13#10 +
        '    INTO :dateparam,'#13#10 +
        '         :O'#13#10 +
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
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_L_Q '; Description:
        '('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ACCOUNTKEY INTEGER,'#13#10 +
        '    AACCOUNTPART VARCHAR(1))'#13#10 +
        'RETURNS ('#13#10 +
        '    DEBITQUANTITY NUMERIC(15,4),'#13#10 +
        '    CREDITQUANTITY NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE ACCOUNTPART VARCHAR(1);'#13#10 +
        'DECLARE VARIABLE QUANTITY NUMERIC(15,4);'#13#10 +
        'begin'#13#10 +
        '    SELECT'#13#10 +
        '      e.accountpart,'#13#10 +
        '      q.quantity'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND'#13#10 +
        '        e1.accountpart <> e.accountpart AND'#13#10 +
        '        e1.accountkey = :accountkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = iif(e.issimple = 0, e.id, e1.id)'#13#10 +
        '    WHERE'#13#10 +
        '      e.id = :entrykey AND'#13#10 +
        '      q.valuekey = :valuekey'#13#10 +
        '    INTO'#13#10 +
        '      :accountpart,'#13#10 +
        '      :quantity;'#13#10 +
        '    IF (quantity IS NULL) THEN'#13#10 +
        '      quantity = 0;'#13#10 +
        ''#13#10 +
        '    debitquantity = 0;'#13#10 +
        '    creditquantity = 0;'#13#10 +
        '    IF (accountpart = ''D'') THEN'#13#10 +
        '      debitquantity = :quantity;'#13#10 +
        '    ELSE'#13#10 +
        '      creditquantity = :quantity;'#13#10 +
        ''#13#10 +
        '    suspend;'#13#10 +
        'END'),
     (ProcedureName: 'AC_Q_S'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    AENDENTRYDATE DATE,'#13#10 +
        '    SQLHANDLE INTEGER,'#13#10 +
        '    COMPANYKEY INTEGER,'#13#10 +
        '    ALLHOLDINGCOMPANIES INTEGER,'#13#10 +
        '    INGROUP INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ENTRYDATE DATE,'#13#10 +
        '    DEBITBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITEND NUMERIC(15,4),'#13#10 +
        '    CREDITEND NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT'#13#10 +
        '    IIF(SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
        '      SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e1'#13#10 +
        '    LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '    LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
        '  WHERE'#13#10 +
        '    e1.entrydate < :abeginentrydate AND'#13#10 +
        '    ((:SQLHandle = 0) OR'#13#10 +
        '    (:SQLHandle > 0 AND e1.accountkey IN('#13#10 +
        '       SELECT'#13#10 +
        '         a.accountkey'#13#10 +
        '       FROM'#13#10 +
        '         ac_ledger_accounts a'#13#10 +
        '       WHERE'#13#10 +
        '        a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '    (r1.companykey = :companykey OR'#13#10 +
        '    (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '    r1.companykey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        h.companykey'#13#10 +
        '      FROM'#13#10 +
        '        gd_holding h'#13#10 +
        '      WHERE'#13#10 +
        '        h.holdingkey = :companykey))) AND'#13#10 +
        '    G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '    q.valuekey = :valuekey'#13#10 +
        '  INTO :saldobegin;'#13#10 +
        '  if (saldobegin IS NULL) then'#13#10 +
        '    saldobegin = 0;'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      e.entrydate,'#13#10 +
        '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
        '        q.valuekey = :valuekey'#13#10 +
        '    WHERE'#13#10 +
        '      e.entrydate <= :aendentrydate AND'#13#10 +
        '      e.entrydate >= :abeginentrydate AND'#13#10 +
        '      ((:SQLHandle = 0) OR'#13#10 +
        '      (:SQLHandle > 0 AND e.accountkey IN('#13#10 +
        '         SELECT'#13#10 +
        '           a.accountkey'#13#10 +
        '         FROM'#13#10 +
        '           ac_ledger_accounts a'#13#10 +
        '         WHERE'#13#10 +
        '           a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '      (r.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r.aview, :ingroup) <> 0'#13#10 +
        '    GROUP BY e.entrydate'#13#10 +
        '    INTO :ENTRYDATE,'#13#10 +
        '         :O'#13#10 +
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
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    ENTRYDATE = :abeginentrydate;'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        '    SUSPEND;'#13#10 +
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
        '    PARAM INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    DATEPARAM INTEGER,'#13#10 +
        '    DEBITBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITEND NUMERIC(15,4),'#13#10 +
        '    CREDITEND NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  SALDOBEGIN = 0;'#13#10 +
        '  SELECT'#13#10 +
        '    SUM(IIF(e1.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '      SUM(IIF(e1.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e1'#13#10 +
        '    LEFT JOIN ac_record r1 ON r1.id = e1.recordkey'#13#10 +
        '    LEFT JOIN ac_quantity q ON q.entrykey = e1.id'#13#10 +
        '  WHERE'#13#10 +
        '    e1.entrydate < :abeginentrydate AND'#13#10 +
        '    ((:SQLHandle = 0) OR'#13#10 +
        '    (:SQLHandle > 0 AND e1.accountkey IN('#13#10 +
        '       SELECT'#13#10 +
        '         a.accountkey'#13#10 +
        '       FROM'#13#10 +
        '         ac_ledger_accounts a'#13#10 +
        '       WHERE'#13#10 +
        '        a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '    (r1.companykey = :companykey OR'#13#10 +
        '    (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '    r1.companykey IN ('#13#10 +
        '      SELECT'#13#10 +
        '        h.companykey'#13#10 +
        '      FROM'#13#10 +
        '        gd_holding h'#13#10 +
        '      WHERE'#13#10 +
        '        h.holdingkey = :companykey))) AND'#13#10 +
        '    G_SEC_TEST(r1.aview, :ingroup) <> 0 AND'#13#10 +
        '    q.valuekey = :valuekey'#13#10 +
        '  INTO :saldobegin;'#13#10 +
        ''#13#10 +
        '  if (SALDOBEGIN IS NULL) THEN'#13#10 +
        '    SALDOBEGIN = 0;'#13#10 +
        ''#13#10 +
        '  C = 0;'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      g_d_getdateparam(e.entrydate, :param),'#13#10 +
        '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey'#13#10 +
        '    WHERE'#13#10 +
        '      e.entrydate <= :aendentrydate AND'#13#10 +
        '      e.entrydate >= :abeginentrydate AND'#13#10 +
        '      ((:SQLHandle = 0) OR'#13#10 +
        '      (:SQLHandle > 0 AND e.accountkey IN('#13#10 +
        '         SELECT'#13#10 +
        '           a.accountkey'#13#10 +
        '         FROM'#13#10 +
        '           ac_ledger_accounts a'#13#10 +
        '         WHERE'#13#10 +
        '           a.SQLHandle = :SQLHandle))) AND'#13#10 +
        '      (r.companykey = :companykey OR'#13#10 +
        '      (:ALLHOLDINGCOMPANIES = 1 AND'#13#10 +
        '      r.companykey IN ('#13#10 +
        '        SELECT'#13#10 +
        '          h.companykey'#13#10 +
        '        FROM'#13#10 +
        '          gd_holding h'#13#10 +
        '        WHERE'#13#10 +
        '          h.holdingkey = :companykey))) AND'#13#10 +
        '      G_SEC_TEST(r.aview, :ingroup) <> 0'#13#10 +
        '    GROUP BY 1'#13#10 +
        '    INTO :dateparam,'#13#10 +
        '         :O'#13#10 +
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
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName: 'AC_E_Q_S'; Description:
        '('#13#10 +
        '    VALUEKEY INTEGER,'#13#10 +
        '    ABEGINENTRYDATE DATE,'#13#10 +
        '    SALDOBEGIN NUMERIC(15,4),'#13#10 +
        '    SQLHANDLE INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ENTRYDATE DATE,'#13#10 +
        '    DEBITBEGIN NUMERIC(15,4),'#13#10 +
        '    CREDITBEGIN NUMERIC(15,4),'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITEND NUMERIC(15,4),'#13#10 +
        '    CREDITEND NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
        'DECLARE VARIABLE C INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  C = 0;'#13#10 +
        '  if (saldobegin IS NULL) then'#13#10 +
        '    saldobegin = 0;'#13#10 +
        ''#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      e.entrydate,'#13#10 +
        '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
        '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
        '    FROM'#13#10 +
        '      ac_ledger_entries le'#13#10 +
        '      LEFT JOIN ac_entry e ON le.entrykey = e.id'#13#10 +
        '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
        '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey'#13#10 +
        '    WHERE'#13#10 +
        '      le.sqlhandle = :SQLHANDLE'#13#10 +
        '    GROUP BY e.entrydate'#13#10 +
        '    INTO :ENTRYDATE,'#13#10 +
        '         :O'#13#10 +
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
        '    SUSPEND;'#13#10 +
        '    SALDOBEGIN = :SALDOEND;'#13#10 +
        '    C = C + 1;'#13#10 +
        '  END'#13#10 +
        '  /*Если за указанный период нет движения то выводим сальдо на начало периода*/'#13#10 +
        '  IF (C = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    ENTRYDATE = :abeginentrydate;'#13#10 +
        '    IF (SALDOBEGIN > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      DEBITBEGIN = :SALDOBEGIN;'#13#10 +
        '      DEBITEND = :SALDOBEGIN;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      CREDITBEGIN =  - :SALDOBEGIN;'#13#10 +
        '      CREDITEND =  - :SALDOBEGIN;'#13#10 +
        '    END'#13#10 +
        '    SUSPEND;'#13#10 +
        '  END'#13#10 +
        'END'),
     (ProcedureName:'AC_GETSIMPLEENTRY'; Description:
        '('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    ACORRACCOUNTKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ID INTEGER,'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITCURR NUMERIC(15,4),'#13#10 +
        '    CREDITCURR NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        '/*Версия 1*/'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT'#13#10 +
        '    e.id,'#13#10 +
        '    iif(corr_e.issimple = 0, corr_e.debitncu, e.debitncu),'#13#10 +
        '    iif(corr_e.issimple = 0, corr_e.creditncu, e.creditncu),'#13#10 +
        '    iif(corr_e.issimple = 0, corr_e.debitcurr, e.debitcurr),'#13#10 +
        '    iif(corr_e.issimple = 0, corr_e.creditcurr, e.creditcurr)'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e'#13#10 +
        '    JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and'#13#10 +
        '      e.accountpart <> corr_e.accountpart'#13#10 +
        '  WHERE'#13#10 +
        '    e.id = :entrykey AND'#13#10 +
        '    corr_e.accountkey = :acorraccountkey'#13#10 +
        '  INTO :ID,'#13#10 +
        '       :DEBIT,'#13#10 +
        '       :CREDIT,'#13#10 +
        '       :DEBITCURR,'#13#10 +
        '       :CREDITCURR;'#13#10 +
        '  SUSPEND;'#13#10 +
        'END'#13#10 +
        '/*CREATE PROCEDURE AC_GETSIMPLEENTRY ('#13#10 +
        '    ENTRYKEY INTEGER,'#13#10 +
        '    ACORRACCOUNTKEY INTEGER)'#13#10 +
        'RETURNS ('#13#10 +
        '    ID INTEGER,'#13#10 +
        '    DEBIT NUMERIC(15,4),'#13#10 +
        '    CREDIT NUMERIC(15,4),'#13#10 +
        '    DEBITCURR NUMERIC(15,4),'#13#10 +
        '    CREDITCURR NUMERIC(15,4))'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  SELECT'#13#10 +
        '    e.id,'#13#10 +
        '    e.debitncu,'#13#10 +
        '    e.creditncu,'#13#10 +
        '    e.debitcurr,'#13#10 +
        '    e.creditcurr'#13#10 +
        '  FROM'#13#10 +
        '    ac_entry e'#13#10 +
        '    LEFT JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and'#13#10 +
        '      e.accountpart <> corr_e.accountpart'#13#10 +
        '  WHERE'#13#10 +
        '    e.id = :entrykey AND'#13#10 +
        '    corr_e.accountkey = :acorraccountkey AND '#13#10 +
        '    (SELECT'#13#10 +
        '      COUNT(*)'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e1'#13#10 +
        '    WHERE'#13#10 +
        '      e1.recordkey = e.recordkey AND'#13#10 +
        '      e1.accountpart <> e.accountpart) = 1'#13#10 +
        '  UNION ALL'#13#10 +
        '    SELECT'#13#10 +
        '      e.id,'#13#10 +
        '      corr_e.creditncu,'#13#10 +
        '      corr_e.debitncu,'#13#10 +
        '      corr_e.creditcurr,'#13#10 +
        '      corr_e.debitcurr'#13#10 +
        '    FROM'#13#10 +
        '      ac_entry e'#13#10 +
        '      LEFT JOIN ac_entry corr_e ON e.recordkey = corr_e.recordkey AND'#13#10 +
        '        e.accountpart <> corr_e.accountpart'#13#10 +
        '    WHERE'#13#10 +
        '      e.id = :entrykey AND'#13#10 +
        '      corr_e.accountkey = :acorraccountkey AND'#13#10 +
        '      (SELECT'#13#10 +
        '        COUNT(*)'#13#10 +
        '      FROM'#13#10 +
        '        ac_entry e1'#13#10 +
        '      WHERE'#13#10 +
        '         e1.recordkey = e.recordkey AND'#13#10 +
        '         e1.accountpart <> e.accountpart) > 1'#13#10 +
        '    INTO :ID,'#13#10 +
        '       :DEBIT,'#13#10 +
        '       :CREDIT,'#13#10 +
        '       :DEBITCURR,'#13#10 +
        '       :CREDITCURR;'#13#10 +
        '  SUSPEND;'#13#10 +
        'END*/')
   );
procedure QuickLedger(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
begin
  Log(Format('Создание таблицы %s', [AC_LEDGER_ENTRIES.TableName]));
  try
    CreateRelation(AC_LEDGER_ENTRIES, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка: %s', [E.Message]));
  end;

  if not FieldExist(ISSIMPLE, IBDB) then
  begin
    Log(Format('Добавление поля %s', [ISSIMPLE.FieldName]));
    try
      AddField(ISSIMPLE, IBDB);

      for I := TriggerCount - 1 downto 0 do
      begin
        if not TriggerExist(Triggers[I], IBDB) then
        begin
          Log(Format('Добавление триггера %s ', [Triggers[i].TriggerName]));
          try
            CreateTrigger(Triggers[i], IBDB);
          except
            on E: Exception do
              Log(Format('Ошибка: %s', [E.Message]));
          end;
        end;
      end;

      {if not ProcedureExist(SET_ISSIMPLE_ENTRY, IBDB) then
      begin
        Log(Format('Добавление поцедуры %s', [SET_ISSIMPLE_ENTRY.ProcedureName]));
        try
          CreateProcedure(SET_ISSIMPLE_ENTRY, IBDB);
        except
          on E: Exception do
            Log(Format('Ошибка: %s', [E.Message]));
        end;
      end;}
    except
      on E: Exception do
        Log(Format('Ошибка: %s', [E.Message]));
    end;
  end;

  for I := 0 to ProcCount - 1 do
  begin
    if ProcedureExist(Procs[i], IBDB) then
      AlterProcedure(Procs[i], IBDB)
    else
      CreateProcedure(Procs[i], IBDB)
  end;
end;

end.
