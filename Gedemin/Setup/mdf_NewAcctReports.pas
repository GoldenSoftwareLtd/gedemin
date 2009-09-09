unit mdf_NewAcctReports;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure NewAcctReports(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddAccountReview(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

const
  AC_ACCT_CONFIG: TmdfTable = (TableName: 'AC_ACCT_CONFIG';
    Description:'('#13#10 +
      '    ID              DINTKEY,'#13#10 +
      '    NAME            DTEXT32 NOT NULL,'#13#10 +
      '    CLASSNAME       DTEXT60 NOT NULL,'#13#10 +
      '    CONFIG          DBLOB,'#13#10 +
      '    SHOWINEXPLORER  DBOOLEAN,'#13#10 +
      '    FOLDER          DFOREIGNKEY,'#13#10 +
      '    IMAGEINDEX      DINTEGER);'#13#10 +
      'ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT PK_AC_ACCT_CONFIG_ID PRIMARY KEY (ID);'#13#10 +
      'ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT FK_AC_ACCT_CONFIG_FOLDER FOREIGN KEY (FOLDER) REFERENCES GD_COMMAND (ID) ON DELETE SET NULL ON UPDATE CASCADE;');

  AC_LEDGER_ACCOUNTS: TmdfTable = (TableName: 'AC_LEDGER_ACCOUNTS';
    Description: '('#13#10 +
      '    ACCOUNTKEY  DFOREIGNKEY NOT NULL,'#13#10 +
      '    SQLHANDLE   DINTEGER_NOTNULL NOT NULL);'#13#10 +
      'ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT PK_AC_LEDGER_ACCOUNTS PRIMARY KEY (ACCOUNTKEY, SQLHANDLE);'#13#10 +
      'ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT FK_AC_LEDGER_ACCOUNTS FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);');

  AC_L_Q: TmdfStoredProcedure = (ProcedureName: 'AC_L_Q';
    Description: '('#13#10 +
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
      'DECLARE VARIABLE I INTEGER;'#13#10 +
      'begin'#13#10 +
      '  I = 0;'#13#10 +
      '  FOR'#13#10 +
      '    SELECT'#13#10 +
      '      e.accountpart,'#13#10 +
      '      q.quantity'#13#10 +
      '    FROM'#13#10 +
      '      ac_entry e'#13#10 +
      '      LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND'#13#10 +
      '        e.accountpart <> e1.accountpart'#13#10 +
      '      LEFT JOIN ac_quantity q ON q.entrykey = e1.id AND'#13#10 +
      '        q.valuekey = :valuekey'#13#10 +
      '    WHERE'#13#10 +
      '      e.id = :entrykey AND'#13#10 +
      '      e1.accountkey = :accountkey AND'#13#10 +
      '      e1.accountpart = :aaccountpart AND'#13#10 +
      '      (SELECT'#13#10 +
      '        COUNT(*)'#13#10 +
      '       FROM'#13#10 +
      '         ac_entry ec'#13#10 +
      '       WHERE'#13#10 +
      '         ec.recordkey = e.recordkey AND'#13#10 +
      '         ec.accountpart <> e.accountpart) > 1'#13#10 +
      '    UNION'#13#10 +
      '    SELECT'#13#10 +
      '      e.accountpart,'#13#10 +
      '      q.quantity'#13#10 +
      '    FROM'#13#10 +
      '      ac_entry e'#13#10 +
      '      LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND'#13#10 +
      '        e.accountpart <> e1.accountpart'#13#10 +
      '      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND'#13#10 +
      '        q.valuekey = :valuekey'#13#10 +
      '    WHERE'#13#10 +
      '      e.id = :entrykey AND'#13#10 +
      '      e1.accountkey = :accountkey AND'#13#10 +
      '      e1.accountpart = :aaccountpart AND'#13#10 +
      '      (SELECT'#13#10 +
      '        COUNT(*)'#13#10 +
      '       FROM'#13#10 +
      '         ac_entry ec'#13#10 +
      '       WHERE'#13#10 +
      '         ec.recordkey = e.recordkey AND'#13#10 +
      '         ec.accountpart <> e.accountpart) = 1'#13#10 +
      '    INTO'#13#10 +
      '      :accountpart,'#13#10 +
      '      :quantity'#13#10 +
      '  DO'#13#10 +
      '  BEGIN'#13#10 +
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
      '    I = I + 1;'#13#10 +
      '  END'#13#10 +
      ''#13#10 +
      '  IF (I = 0) THEN'#13#10 +
      '  BEGIN'#13#10 +
      '    debitquantity = 0;'#13#10 +
      '    creditquantity = 0;'#13#10 +
      '    SUSPEND;'#13#10 +
      '  END'#13#10 +
      'END');

  AC_L_S: TmdfStoredProcedure = (ProcedureName: 'AC_L_S';
    Description: '('#13#10 +
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
    '    CREDITCURREND NUMERIC(15,4))'#13#10 +
    'AS'#13#10 +
    'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
    'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
    'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
    'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
    'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
    'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
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
    'if (saldobegin IS NULL) then'#13#10 +
    '  saldobegin = 0;'#13#10 +
    'if (saldobegincurr IS NULL) then'#13#10 +
    '  saldobegincurr = 0;'#13#10 +
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
    '  END'#13#10 +
    'END');

  AC_L_S1: TmdfStoredProcedure = (ProcedureName: 'AC_L_S1';
    Description: '(ABEGINENTRYDATE DATE,'#13#10 +
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
      '    CREDITCURREND NUMERIC(15,4))'#13#10 +
      'AS'#13#10 +
      'DECLARE VARIABLE O NUMERIC(18,4);'#13#10 +
      'DECLARE VARIABLE SALDOBEGIN NUMERIC(18,4);'#13#10 +
      'DECLARE VARIABLE SALDOEND NUMERIC(18,4);'#13#10 +
      'DECLARE VARIABLE OCURR NUMERIC(18,4);'#13#10 +
      'DECLARE VARIABLE SALDOBEGINCURR NUMERIC(18,4);'#13#10 +
      'DECLARE VARIABLE SALDOENDCURR NUMERIC(18,4);'#13#10 +
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
      '  END'#13#10 +
      'END');

  AC_Q_S: TmdfStoredProcedure = (ProcedureName: 'AC_Q_S';
    Description:'('#13#10 +
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
      'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE I INTEGER;'#13#10 +
      'BEGIN'#13#10 +
      '  I = 0;'#13#10 +
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
      '  FOR'#13#10 +
      '    SELECT'#13#10 +
      '      e.entrydate,'#13#10 +
      '      IIF(SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
      '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0)) > 0,'#13#10 +
      '        SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
      '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0)), 0)'#13#10 +
      '    FROM'#13#10 +
      '      ac_entry e'#13#10 +
      '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
      '      LEFT JOIN ac_quantity q ON q.entrykey = e.id'#13#10 +
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
      '      G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
      '      q.valuekey = :valuekey'#13#10 +
      '    GROUP BY e.entrydate'#13#10 +
      '    INTO :ENTRYDATE,'#13#10 +
      '         :O'#13#10 +
      '  DO'#13#10 +
      '  BEGIN'#13#10 +
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
      '    I = I + 1;'#13#10 +
      '  END'#13#10 +
      'END');

  AC_Q_S1: TmdfStoredProcedure = (ProcedureName: 'AC_Q_S1';
    Description:'('#13#10 +
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
      'DECLARE VARIABLE O NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE SALDOEND NUMERIC(15,4);'#13#10 +
      'DECLARE VARIABLE I INTEGER;'#13#10 +
      'BEGIN'#13#10 +
      '  I = 0;'#13#10 +
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
      '  FOR'#13#10 +
      '    SELECT'#13#10 +
      '      g_d_getdateparam(e.entrydate, :param),'#13#10 +
      '      SUM(IIF(e.accountpart = ''D'', q.quantity, 0)) -'#13#10 +
      '        SUM(IIF(e.accountpart = ''C'', q.quantity, 0))'#13#10 +
      '    FROM'#13#10 +
      '      ac_entry e'#13#10 +
      '      LEFT JOIN ac_record r ON r.id = e.recordkey'#13#10 +
      '      LEFT JOIN ac_quantity q ON q.entrykey = e.id'#13#10 +
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
      '      G_SEC_TEST(r.aview, :ingroup) <> 0 AND'#13#10 +
      '      q.valuekey = :valuekey'#13#10 +
      '    GROUP BY 1'#13#10 +
      '    INTO :dateparam,'#13#10 +
      '         :O'#13#10 +
      '  DO'#13#10 +
      '  BEGIN'#13#10 +
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
      '    I = I + 1;'#13#10 +
      '  END'#13#10 +
      'END');

  AC_GETSIMPLEENTRY: TmdfStoredProcedure = (ProcedureName: 'AC_GETSIMPLEENTRY';
    Description: '(ENTRYKEY INTEGER,'#13#10 +
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
      '  /*if (DEBIT IS NULL) then'#13#10 +
      '    DEBIT = 0;'#13#10 +
      '  if (CREDIT IS NULL) then'#13#10 +
      '    CREDIT = 0;'#13#10 +
      '  if (DEBITCURR IS NULL) then'#13#10 +
      '    DEBITCURR = 0;'#13#10 +
      '  if (CREDITCURR IS NULL) then'#13#10 +
      '    CREDITCURR = 0;*/'#13#10 +
      ''#13#10 +
      '  SUSPEND;'#13#10 +
      'END');

procedure NewAcctReports(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Transaction: TIBTransaction;
begin
  Log(Format('Изменение процедуры %s', [AC_GETSIMPLEENTRY.ProcedureName]));
  try
    AlterProcedure(AC_GETSIMPLEENTRY, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка при изменении процедуры %s', [E.Message]));
  end;

  Log(Format('Создание таблицы %s', [AC_ACCT_CONFIG.TableName]));
  try
    CreateRelation(AC_ACCT_CONFIG, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание таблицы %s', [AC_LEDGER_ACCOUNTS.TableName]));
  try
    CreateRelation(AC_LEDGER_ACCOUNTS, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание процедуры %s', [AC_L_Q.ProcedureName]));
  try
    CreateProcedure(AC_L_Q, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание процедуры %s', [AC_L_S.ProcedureName]));
  try
    CreateProcedure(AC_L_S, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание процедуры %s', [AC_L_S1.ProcedureName]));
  try
    CreateProcedure(AC_L_S1, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание процедуры %s', [AC_Q_S.ProcedureName]));
  try
    CreateProcedure(AC_Q_S, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Log(Format('Создание процедуры %s', [AC_Q_S1.ProcedureName]));
  try
    CreateProcedure(AC_Q_S1, IBDB);
  except
    on E: Exception do
      Log(Format('Ошибка %s', [E.Message]));
  end;

  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBase := IBDB;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      Transaction.StartTransaction;
      try
        SQL.SQl.text := 'DECLARE EXTERNAL FUNCTION G_D_GETDATEPARAM'#13#10 +
          '    DATE,'#13#10 +
          '    INTEGER'#13#10 +
          'RETURNS INTEGER BY VALUE'#13#10 +
          'ENTRY_POINT ''g_d_getdateparam'' MODULE_NAME ''GUDF.dll''';
        SQL.ExecQuery;
        Transaction.Commit;
      except
        on E: Exception do
        begin
          Transaction.Rollback;
          Log(Format('Ошибка %s', [E.Message]));
        end;
      end;

      Transaction.StartTransaction;
      try
        SQL.Close;
        SQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714022';
        SQL.ExecQuery;
        if SQL.Eof then
        begin
          SQL.Close;
          SQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714022, 714000, ''Журнал-ордер'', ' +
            ' '''', ''Tgdv_frmAcctLedger'', NULL, 17)';
          SQL.ExecQuery;
          SQL.Close;
        end else
          SQL.Close;

        SQL.Close;
        SQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714098';
        SQL.ExecQuery;
        if SQL.Eof then
        begin
          SQL.Close;
          SQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714098, 714000, ''Карта счета'', ' +
            ' '''', ''Tgdv_frmAcctAccCard'', NULL, 17)';
          SQL.ExecQuery;
          SQL.Close;
        end else
          SQL.Close;
        Transaction.Commit;
      except
        on E: Exception do
        begin
          Transaction.Rollback;
          Log(Format('Ошибка %s', [E.Message]));
        end;
      end
    finally
      SQL.Free;
    end;
  finally
    Transaction.Free;
  end;
end;

procedure AddAccountReview(IBDB: TIBDatabase; Log: TModifyLog);
var
  SQL: TIBSQL;
  Transaction: TIBTransaction;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBase := IBDB;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      Transaction.StartTransaction;
      try
        SQL.Close;
        SQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714030';
        SQL.ExecQuery;
        if SQL.Eof then begin
          SQL.Close;
          SQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714030, 714000, ''Анализ счета'', ' +
            ' '''', ''Tgdv_frmAcctAccReview'', NULL, 220)';
          SQL.ExecQuery;
        end
        else begin
          SQL.Close;
          SQL.SQL.Text := ' UPDATE gd_command SET classname = ''Tgdv_frmAcctAccReview'' ' +
                          ' WHERE id = 714030 ';
          SQL.ExecQuery;
        end;
        Transaction.Commit;
      except
        on E: Exception do
        begin
          if Transaction.InTransaction then
            Transaction.Rollback;
          Log(Format('Ошибка %s', [E.Message]));
          raise;
        end;
      end;
    finally
      SQL.Free;
    end;
  finally
    Transaction.Free;
  end;
end;

end.
