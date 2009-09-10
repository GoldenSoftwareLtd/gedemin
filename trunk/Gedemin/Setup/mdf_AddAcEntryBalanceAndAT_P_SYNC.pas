unit mdf_AddAcEntryBalanceAndAT_P_SYNC;

interface

uses
  IBDatabase, gdModify;

procedure AddAcEntryBalanceAndAT_P_SYNC(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddMissedGrantsToAcEntryBalanceProcedures(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, gdcMetaData, mdf_MetaData_unit;

const
  cCreateGenerator = 'CREATE GENERATOR gd_g_entry_balance_date';

  cInsertCommand =
    ' INSERT INTO gd_command (id, parent, name, cmd, classname, imgindex) ' +
    ' VALUES (714200, 714000, ''Переход на новый месяц'', '''', ''TfrmCalculateBalance'', 87)';

  cAC_ENTRY_BALANCETemplate =
    'CREATE TABLE ac_entry_balance ( '#13#10 +
    '  id                      dintkey, '#13#10 +
    '  companykey              dintkey, '#13#10 +
    '  accountkey              dintkey, '#13#10 +
    '  debitncu                dcurrency, '#13#10 +
    '  debitcurr               dcurrency, '#13#10 +
    '  debiteq                 dcurrency, '#13#10 +
    '  creditncu               dcurrency, '#13#10 +
    '  creditcurr              dcurrency, '#13#10 +
    '  crediteq                dcurrency, '#13#10 +
    '  currkey                 dintkey ';

  cBalancePrimaryKey =
    'ALTER TABLE ac_entry_balance ADD CONSTRAINT pk_ac_entry_bal PRIMARY KEY (id)';

  cBalanceForeignKey =
    'ALTER TABLE ac_entry_balance ADD CONSTRAINT gd_fk_entry_bal_ac FOREIGN KEY (accountkey) REFERENCES ac_account (id) ON UPDATE CASCADE';

  cBalanceAutoincrementTrigger =
    'CREATE OR ALTER TRIGGER ac_bi_entry_balance FOR ac_entry_balance '#13#10 +
    'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.ID IS NULL) THEN '#13#10 +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    '  IF (NEW.debitncu IS NULL) THEN '#13#10 +
    '    NEW.debitncu = 0; '#13#10 +
    '  IF (NEW.debitcurr IS NULL) THEN '#13#10 +
    '    NEW.debitcurr = 0; '#13#10 +
    '  IF (NEW.debiteq IS NULL) THEN '#13#10 +
    '    NEW.debiteq = 0; '#13#10 +
    '  IF (NEW.creditncu IS NULL) THEN '#13#10 +
    '    NEW.creditncu = 0; '#13#10 +
    '  IF (NEW.creditcurr IS NULL) THEN '#13#10 +
    '    NEW.creditcurr = 0; '#13#10 +
    '  IF (NEW.crediteq IS NULL) THEN '#13#10 +
    '    NEW.crediteq = 0; '#13#10 +
    'END ';

  cBalanceGrant =
    'GRANT ALL ON ac_entry_balance TO ADMINISTRATOR';

  cAC_CIRCULATIONLIST_BALGrant =
    'GRANT EXECUTE ON PROCEDURE ac_circulationlist_bal TO ADMINISTRATOR';

  cCreateAC_CIRCULATIONLIST_BAL =
    ' CREATE OR ALTER PROCEDURE ac_circulationlist_bal( '#13#10 +
    '     datebegin DATE, '#13#10 +
    '     dateend DATE, '#13#10 +
    '     companykey INTEGER, '#13#10 +
    '     allholdingcompanies INTEGER, '#13#10 +
    '     accountkey INTEGER, '#13#10 +
    '     currkey INTEGER, '#13#10 +
    '     dontinmove INTEGER) '#13#10 +
    ' RETURNS ( '#13#10 +
    '     alias VARCHAR(20), '#13#10 +
    '     name VARCHAR(180), '#13#10 +
    '     id INTEGER, '#13#10 +
    '     ncu_begin_debit NUMERIC(15, 4), '#13#10 +
    '     ncu_begin_credit NUMERIC(15, 4), '#13#10 +
    '     ncu_debit NUMERIC(15, 4), '#13#10 +
    '     ncu_credit NUMERIC(15, 4), '#13#10 +
    '     ncu_end_debit NUMERIC(15, 4), '#13#10 +
    '     ncu_end_credit NUMERIC(15, 4), '#13#10 +
    '     curr_begin_debit NUMERIC(15, 4), '#13#10 +
    '     curr_begin_credit NUMERIC(15, 4), '#13#10 +
    '     curr_debit NUMERIC(15, 4), '#13#10 +
    '     curr_credit NUMERIC(15, 4), '#13#10 +
    '     curr_end_debit NUMERIC(15, 4), '#13#10 +
    '     curr_end_credit NUMERIC(15, 4), '#13#10 +
    '     eq_begin_debit NUMERIC(15, 4), '#13#10 +
    '     eq_begin_credit NUMERIC(15, 4), '#13#10 +
    '     eq_debit NUMERIC(15, 4), '#13#10 +
    '     eq_credit NUMERIC(15, 4), '#13#10 +
    '     eq_end_debit NUMERIC(15, 4), '#13#10 +
    '     eq_end_credit NUMERIC(15, 4), '#13#10 +
    '     offbalance INTEGER) '#13#10 +
    ' AS '#13#10 +
    '   DECLARE VARIABLE activity VARCHAR(1); '#13#10 +
    '   DECLARE VARIABLE saldo NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE saldocurr NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE saldoeq NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE fieldname VARCHAR(60); '#13#10 +
    '   DECLARE VARIABLE lb INTEGER; '#13#10 +
    '   DECLARE VARIABLE rb INTEGER; '#13#10 +
    '   DECLARE VARIABLE closedate DATE; '#13#10 +
    ' BEGIN '#13#10 +
    '   closedate = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
    '  '#13#10 +
      ' SELECT '#13#10 +
    '     c.lb, c.rb '#13#10 +
    '   FROM '#13#10 +
    '     ac_account c '#13#10 +
    '   WHERE '#13#10 +
    '     c.id = :accountkey '#13#10 +
    '   INTO '#13#10 +
    '     :lb, :rb; '#13#10 +
    '  '#13#10 +
      ' FOR '#13#10 +
    '     SELECT '#13#10 +
    '       a.id, a.alias, a.activity, f.fieldname, a.name, a.offbalance '#13#10 +
    '     FROM '#13#10 +
    '       ac_account a '#13#10 +
    '       LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id '#13#10 +
    '     WHERE '#13#10 +
    '       a.accounttype IN (''A'', ''S'') '#13#10 +
    '       AND a.lb >= :lb AND a.rb <= :rb AND a.alias <> ''00'' '#13#10 +
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
    '  '#13#10 +
    '     IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
    '     BEGIN '#13#10 +
    '       IF (:closedate <= :datebegin) THEN '#13#10 +
    '       BEGIN '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(main.debitncu - main.creditncu), '#13#10 +
    '           SUM(main.debitcurr - main.creditcurr), '#13#10 +
    '           SUM(main.debiteq - main.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '         ( '#13#10 +
    '           SELECT '#13#10 +
    '             bal.debitncu, '#13#10 +
    '             bal.creditncu, '#13#10 +
    '             bal.debitcurr, '#13#10 +
    '             bal.creditcurr, '#13#10 +
    '             bal.debiteq, '#13#10 +
    '             bal.crediteq '#13#10 +
    '           FROM '#13#10 +
    '             ac_entry_balance bal '#13#10 +
    '           WHERE '#13#10 +
    '             bal.accountkey = :id '#13#10 +
    '             AND (bal.companykey + 0 = :companykey '#13#10 +
    '               OR (:allholdingcompanies = 1 '#13#10 +
    '                 AND bal.companykey + 0 IN ( '#13#10 +
    '                   SELECT '#13#10 +
    '                     h.companykey '#13#10 +
    '                   FROM '#13#10 +
    '                     gd_holding h '#13#10 +
    '                   WHERE '#13#10 +
    '                     h.holdingkey = :companykey))) '#13#10 +
    '             AND ((0 = :currkey) OR (bal.currkey = :currkey)) '#13#10 +
    '  '#13#10 +
    '           UNION ALL '#13#10 +
    '  '#13#10 +
    '           SELECT '#13#10 +
    '             e.debitncu, '#13#10 +
    '             e.creditncu, '#13#10 +
    '             e.debitcurr, '#13#10 +
    '             e.creditcurr, '#13#10 +
    '             e.debiteq, '#13#10 +
    '             e.crediteq '#13#10 +
    '           FROM '#13#10 +
    '             ac_entry e '#13#10 +
    '           WHERE '#13#10 +
    '             e.accountkey = :id '#13#10 +
    '             AND e.entrydate >= :closedate '#13#10 +
    '             AND e.entrydate < :datebegin '#13#10 +
    '             AND (e.companykey + 0 = :companykey '#13#10 +
    '               OR (:allholdingcompanies = 1 '#13#10 +
    '               AND e.companykey + 0 IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = :companykey))) '#13#10 +
    '             AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '         ) main '#13#10 +
    '         INTO '#13#10 +
    '           :saldo, :saldocurr, :saldoeq; '#13#10 +
    '       END '#13#10 +
    '       ELSE '#13#10 +
    '       BEGIN '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(main.debitncu - main.creditncu), '#13#10 +
    '           SUM(main.debitcurr - main.creditcurr), '#13#10 +
    '           SUM(main.debiteq - main.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '         ( '#13#10 +
    '           SELECT '#13#10 +
    '             bal.debitncu, '#13#10 +
    '             bal.creditncu, '#13#10 +
    '             bal.debitcurr, '#13#10 +
    '             bal.creditcurr, '#13#10 +
    '             bal.debiteq, '#13#10 +
    '             bal.crediteq '#13#10 +
    '           FROM '#13#10 +
    '             ac_entry_balance bal '#13#10 +
    '           WHERE '#13#10 +
    '             bal.accountkey = :id '#13#10 +
    '             AND (bal.companykey + 0 = :companykey '#13#10 +
    '               OR (:allholdingcompanies = 1 '#13#10 +
    '                 AND bal.companykey + 0 IN ( '#13#10 +
    '                   SELECT '#13#10 +
    '                     h.companykey '#13#10 +
    '                   FROM '#13#10 +
    '                     gd_holding h '#13#10 +
    '                   WHERE '#13#10 +
    '                     h.holdingkey = :companykey))) '#13#10 +
    '             AND ((0 = :currkey) OR (bal.currkey = :currkey)) '#13#10 +
    '  '#13#10 +
    '           UNION ALL '#13#10 +
    '  '#13#10 +
    '           SELECT '#13#10 +
    '             - e.debitncu, '#13#10 +
    '             - e.creditncu, '#13#10 +
    '             - e.debitcurr, '#13#10 +
    '             - e.creditcurr, '#13#10 +
    '             - e.debiteq, '#13#10 +
    '             - e.crediteq '#13#10 +
    '           FROM '#13#10 +
    '             ac_entry e '#13#10 +
    '           WHERE '#13#10 +
    '             e.accountkey = :id '#13#10 +
    '             AND e.entrydate >= :datebegin '#13#10 +
    '             AND e.entrydate < :closedate '#13#10 +
    '             AND (e.companykey + 0 = :companykey '#13#10 +
    '               OR (:allholdingcompanies = 1 '#13#10 +
    '               AND e.companykey + 0 IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = :companykey))) '#13#10 +
    '             AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '         ) main '#13#10 +
    '         INTO '#13#10 +
    '           :saldo, :saldocurr, :saldoeq; '#13#10 +
    '       END '#13#10 +
    '  '#13#10 +
    '       IF (saldo IS NULL) THEN '#13#10 +
    '         saldo = 0; '#13#10 +
    '  '#13#10 +
    '       IF (saldocurr IS NULL) THEN '#13#10 +
    '         saldocurr = 0; '#13#10 +
    '  '#13#10 +
    '       IF (saldoeq IS NULL) THEN '#13#10 +
    '         saldoeq = 0; '#13#10 +
    '  '#13#10 +
    '  '#13#10 +
    '       IF (saldo > 0) THEN '#13#10 +
    '         ncu_begin_debit = saldo; '#13#10 +
    '       ELSE '#13#10 +
    '         ncu_begin_credit = 0 - saldo; '#13#10 +
    '  '#13#10 +
    '       IF (saldocurr > 0) THEN '#13#10 +
    '         curr_begin_debit = saldocurr; '#13#10 +
    '       ELSE '#13#10 +
    '         curr_begin_credit = 0 - saldocurr; '#13#10 +
    '  '#13#10 +
    '       IF (saldoeq > 0) THEN '#13#10 +
    '         eq_begin_debit = saldoeq; '#13#10 +
    '       ELSE '#13#10 +
    '         eq_begin_credit = 0 - saldoeq; '#13#10 +
    '     END '#13#10 +
    '     ELSE '#13#10 +
    '     BEGIN '#13#10 +
    '       SELECT '#13#10 +
    '         debitsaldo, '#13#10 +
    '         creditsaldo '#13#10 +
    '       FROM '#13#10 +
    '         ac_accountexsaldo_bal(:datebegin, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) '#13#10 +
    '       INTO '#13#10 +
    '         :ncu_begin_debit, '#13#10 +
    '         :ncu_begin_credit; '#13#10 +
    '     END '#13#10 +
    '  '#13#10 +
    '     IF (allholdingcompanies = 0) THEN '#13#10 +
    '     BEGIN '#13#10 +
    '       IF (dontinmove = 1) THEN '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(e.debitncu), '#13#10 +
    '           SUM(e.creditncu), '#13#10 +
    '           SUM(e.debitcurr), '#13#10 +
    '           SUM(e.creditcurr), '#13#10 +
    '           SUM(e.debiteq), '#13#10 +
    '           SUM(e.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = :id '#13#10 +
    '           AND e.entrydate >= :datebegin '#13#10 +
    '           AND e.entrydate <= :dateend '#13#10 +
    '           AND e.companykey + 0 = :companykey '#13#10 +
    '           AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '           AND NOT EXISTS ( '#13#10 +
    '             SELECT '#13#10 +
    '               e_cm.id '#13#10 +
    '             FROM '#13#10 +
    '               ac_entry e_cm '#13#10 +
    '             WHERE '#13#10 +
    '               e_cm.recordkey = e.recordkey '#13#10 +
    '               AND e_cm.accountpart <> e.accountpart '#13#10 +
    '               AND e_cm.accountkey=e.accountkey '#13#10 +
    '               AND (e.debitncu=e_cm.creditncu '#13#10 +
    '                 OR e.creditncu=e_cm.debitncu '#13#10 +
    '                 OR e.debitcurr=e_cm.creditcurr '#13#10 +
    '                 OR e.creditcurr=e_cm.debitcurr)) '#13#10 +
    '         INTO '#13#10 +
    '           :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; '#13#10 +
    '       ELSE '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(e.debitncu), '#13#10 +
    '           SUM(e.creditncu), '#13#10 +
    '           SUM(e.debitcurr), '#13#10 +
    '           SUM(e.creditcurr), '#13#10 +
    '           SUM(e.debiteq), '#13#10 +
    '           SUM(e.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = :id '#13#10 +
    '           AND e.entrydate >= :datebegin '#13#10 +
    '           AND e.entrydate <= :dateend '#13#10 +
    '           AND e.companykey + 0 = :companykey '#13#10 +
    '           AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '         INTO '#13#10 +
    '           :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; '#13#10 +
    '     END '#13#10 +
    '     ELSE '#13#10 +
    '     BEGIN '#13#10 +
    '       IF (dontinmove = 1) THEN '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(e.debitncu), '#13#10 +
    '           SUM(e.creditncu), '#13#10 +
    '           SUM(e.debitcurr), '#13#10 +
    '           SUM(e.creditcurr), '#13#10 +
    '           SUM(e.debiteq), '#13#10 +
    '           SUM(e.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = :id '#13#10 +
    '           AND e.entrydate >= :datebegin '#13#10 +
    '           AND e.entrydate <= :dateend '#13#10 +
    '           AND (e.companykey + 0 = :companykey '#13#10 +
    '             OR e.companykey + 0 IN ( '#13#10 +
    '               SELECT '#13#10 +
    '                 h.companykey '#13#10 +
    '               FROM '#13#10 +
    '                 gd_holding h '#13#10 +
    '               WHERE '#13#10 +
    '                 h.holdingkey = :companykey)) '#13#10 +
    '           AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '           AND NOT EXISTS ( '#13#10 +
    '             SELECT '#13#10 +
    '               e_cm.id '#13#10 +
    '             FROM '#13#10 +
    '               ac_entry e_cm '#13#10 +
    '             WHERE '#13#10 +
    '               e_cm.recordkey = e.recordkey '#13#10 +
    '               AND e_cm.accountpart <> e.accountpart '#13#10 +
    '               AND e_cm.accountkey=e.accountkey '#13#10 +
    '               AND (e.debitncu=e_cm.creditncu '#13#10 +
    '                 OR e.creditncu=e_cm.debitncu '#13#10 +
    '                 OR e.debitcurr=e_cm.creditcurr '#13#10 +
    '                 OR e.creditcurr=e_cm.debitcurr)) '#13#10 +
    '         INTO '#13#10 +
    '           :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; '#13#10 +
    '       ELSE '#13#10 +
    '         SELECT '#13#10 +
    '           SUM(e.debitncu), '#13#10 +
    '           SUM(e.creditncu), '#13#10 +
    '           SUM(e.debitcurr), '#13#10 +
    '           SUM(e.creditcurr), '#13#10 +
    '           SUM(e.debiteq), '#13#10 +
    '           SUM(e.crediteq) '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = :id '#13#10 +
    '           AND e.entrydate >= :datebegin '#13#10 +
    '           AND e.entrydate <= :dateend '#13#10 +
    '           AND (e.companykey + 0 = :companykey '#13#10 +
    '             OR e.companykey + 0 IN ( '#13#10 +
    '               SELECT '#13#10 +
    '                 h.companykey '#13#10 +
    '               FROM '#13#10 +
    '                 gd_holding h '#13#10 +
    '               WHERE '#13#10 +
    '                 h.holdingkey = :companykey)) '#13#10 +
    '           AND ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
    '         INTO '#13#10 +
    '           :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; '#13#10 +
    '     END '#13#10 +
    '  '#13#10 +
    '     IF (ncu_debit IS NULL) THEN '#13#10 +
    '       ncu_debit = 0; '#13#10 +
    '  '#13#10 +
    '     IF (ncu_credit IS NULL) THEN '#13#10 +
    '       ncu_credit = 0; '#13#10 +
    '  '#13#10 +
    '     IF (curr_debit IS NULL) THEN '#13#10 +
    '       curr_debit = 0; '#13#10 +
    '  '#13#10 +
    '     IF (curr_credit IS NULL) THEN '#13#10 +
    '       curr_credit = 0; '#13#10 +
    '  '#13#10 +
    '     IF (eq_debit IS NULL) THEN '#13#10 +
    '       eq_debit = 0; '#13#10 +
    '  '#13#10 +
    '     IF (eq_credit IS NULL) THEN '#13#10 +
    '       eq_credit = 0; '#13#10 +
    '  '#13#10 +
    '     ncu_end_debit = 0; '#13#10 +
    '     ncu_end_credit = 0; '#13#10 +
    '     curr_end_debit = 0; '#13#10 +
    '     curr_end_credit = 0; '#13#10 +
    '     eq_end_debit = 0; '#13#10 +
    '     eq_end_credit = 0; '#13#10 +
    '  '#13#10 +
    '     IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
    '     BEGIN '#13#10 +
    '       saldo = ncu_begin_debit - ncu_begin_credit + ncu_debit - ncu_credit; '#13#10 +
    '       IF (saldo > 0) THEN '#13#10 +
    '         ncu_end_debit = saldo; '#13#10 +
    '       ELSE '#13#10 +
    '         ncu_end_credit = 0 - saldo; '#13#10 +
    '  '#13#10 +
    '       saldocurr = curr_begin_debit - curr_begin_credit + curr_debit - curr_credit; '#13#10 +
    '       IF (saldocurr > 0) THEN '#13#10 +
    '         curr_end_debit = saldocurr; '#13#10 +
    '       ELSE '#13#10 +
    '         curr_end_credit = 0 - saldocurr; '#13#10 +
    '  '#13#10 +
    '       saldoeq = eq_begin_debit - eq_begin_credit + eq_debit - eq_credit; '#13#10 +
    '       IF (saldoeq > 0) THEN '#13#10 +
    '         eq_end_debit = saldoeq; '#13#10 +
    '       ELSE '#13#10 +
    '         eq_end_credit = 0 - saldoeq; '#13#10 +
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
    '           debitsaldo, creditsaldo, '#13#10 +
    '           currdebitsaldo, currcreditsaldo, '#13#10 +
    '           eqdebitsaldo, eqcreditsaldo '#13#10 +
    '         FROM '#13#10 +
    '           ac_accountexsaldo_bal(:dateend + 1, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) '#13#10 +
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
    'END ';

  cAT_P_SYNC =
    ' ALTER PROCEDURE AT_P_SYNC  '#13#10 +
    ' AS '#13#10 +
    ' DECLARE VARIABLE ID INTEGER; '#13#10 +
    ' DECLARE VARIABLE ID1 INTEGER; '#13#10 +
    ' DECLARE VARIABLE FN VARCHAR(31); '#13#10 +
    ' DECLARE VARIABLE FS VARCHAR(31); '#13#10 +
    ' DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
    ' DECLARE VARIABLE NFS VARCHAR(31); '#13#10 +
    ' DECLARE VARIABLE VS BLOB SUB_TYPE 0 SEGMENT SIZE 80; '#13#10 +
    ' DECLARE VARIABLE EN VARCHAR(31); '#13#10 +
    ' DECLARE VARIABLE DELRULE VARCHAR(20); '#13#10 +
    ' DECLARE VARIABLE WASERROR SMALLINT; '#13#10 +
    ' DECLARE VARIABLE GN VARCHAR(64); '#13#10 +
    ' BEGIN  '#13#10 +
    '  /* пакольк_ каскады не выкарыстоўваюцца мус_м */  '#13#10 +
    '  /* п_льнавацца пэўнага парадку                */  '#13#10 +
      '  '#13#10 +
    '  /* выдал_м не _снуючыя ўжо пал_ табл_цаў      */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT fieldname, relationname  '#13#10 +
    '      FROM at_relation_fields LEFT JOIN rdb$relation_fields  '#13#10 +
    '        ON fieldname=rdb$field_name AND relationname=rdb$relation_name  '#13#10 +
    '      WHERE  '#13#10 +
    '        rdb$field_name IS NULL  '#13#10 +
    '      INTO :FN, :RN  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      DELETE FROM at_relation_fields WHERE fieldname=:FN AND relationname=:RN;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* дададз_м новыя дамены */  '#13#10 +
    '    INSERT INTO AT_FIELDS (fieldname, lname, description) '#13#10 +
    '    SELECT g_s_trim(rdb$field_name, '' ''), g_s_trim(rdb$field_name, '' ''), '#13#10 +
    '      g_s_trim(rdb$field_name, '' '') '#13#10 +
    '    FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
    '      WHERE fieldname IS NULL; '#13#10 +
      '  '#13#10 +
    '  /* для _снуючых палёў аднав_м _нфармацыю аб тыпе */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT fieldsource, fieldname, relationname  '#13#10 +
    '      FROM at_relation_fields  '#13#10 +
    '      INTO :FS, :FN, :RN  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      SELECT rf.rdb$field_source, f.id  '#13#10 +
    '      FROM rdb$relation_fields rf JOIN at_fields f ON rf.rdb$field_source = f.fieldname  '#13#10 +
    '      WHERE rdb$relation_name=:RN AND rdb$field_name = :FN  '#13#10 +
    '      INTO :NFS, :ID;  '#13#10 +
      '  '#13#10 +
    '      IF (:NFS <> :FS AND (NOT (:NFS IS NULL))) THEN  '#13#10 +
    '      UPDATE at_relation_fields SET fieldsource = :NFS, fieldsourcekey = :ID  '#13#10 +
    '      WHERE fieldname = :FN AND relationname = :RN;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* выдал_м з табл_цы даменаў не _снуючыя дамены */  '#13#10 +
    '    DELETE FROM at_fields f WHERE '#13#10 +
    '    NOT EXISTS (SELECT rdb$field_name FROM rdb$fields '#13#10 +
    '      WHERE rdb$field_name = f.fieldname); '#13#10 +
    '  '#13#10 +
      '  '#13#10 +
    '  /*Теперь будем аккуратно проверять на несуществующие уже таблицы и существующие  '#13#10 +
    '  домены, которые ссылаются на эти таблицы. Такая ситуация может возникнуть из-за  '#13#10 +
    '  ошибки при создании мета-данных*/  '#13#10 +
      '  '#13#10 +
    '    WASERROR = 0;  '#13#10 +
      '  '#13#10 +
    '    FOR  '#13#10 +
    '  /*Выберем все поля и удалим*/  '#13#10 +
    '      SELECT rf.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN at_fields f ON r.id = f.reftablekey  '#13#10 +
    '      LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      WASERROR = 1;  '#13#10 +
    '      DELETE FROM at_relation_fields WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '    FOR  '#13#10 +
    '  /*Выберем все домены и удалим*/  '#13#10 +
    '      SELECT f.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN at_fields f ON r.id = f.reftablekey  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      WASERROR = 1;  '#13#10 +
    '      DELETE FROM at_fields WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '    FOR  '#13#10 +
    '  /*Выберем все поля и удалим*/  '#13#10 +
    '      SELECT rf.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN at_fields f ON r.id = f.settablekey  '#13#10 +
    '      LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      WASERROR = 1;  '#13#10 +
    '      DELETE FROM at_relation_fields WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '    FOR  '#13#10 +
    '  /*Выберем все домены и удалим*/  '#13#10 +
    '      SELECT f.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN at_fields f ON r.id = f.settablekey  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      WASERROR = 1;  '#13#10 +
    '      DELETE FROM at_fields WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '    FOR  '#13#10 +
    ' /*выберем все документы, у которых шапка ссылается на несуществующие таблицы и удалим*/  '#13#10 +
    '      SELECT dt.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN gd_documenttype dt ON dt.headerrelkey =r.id  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      DELETE FROM gd_documenttype WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
     '  '#13#10 +
       ' FOR  '#13#10 +
    ' /*выберем все документы, у которых позиция ссылается на несуществующие таблицы и удалим*/  '#13#10 +
    '      SELECT dt.id  '#13#10 +
    '      FROM at_relations r  '#13#10 +
    '      LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname  '#13#10 +
    '      LEFT JOIN gd_documenttype dt ON dt.linerelkey =r.id  '#13#10 +
    '      WHERE rdb.rdb$relation_name IS NULL  '#13#10 +
    '      INTO :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      DELETE FROM gd_documenttype WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
    '    IF (WASERROR = 1) THEN  '#13#10 +
    '    BEGIN  '#13#10 +
    '  /* Перечитаем домены. Теперь те домены, которые были проблемными добавятся без ошибок */  '#13#10 +
    '      INSERT INTO AT_FIELDS (fieldname, lname, description) '#13#10 +
    '      SELECT g_s_trim(rdb$field_name, '' ''), g_s_trim(rdb$field_name, '' ''), '#13#10 +
    '        g_s_trim(rdb$field_name, '' '') '#13#10 +
    '      FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
    '        WHERE fieldname IS NULL; '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* выдал_м табл_цы, як_х ужо няма */  '#13#10 +
    '    DELETE FROM at_relations r WHERE '#13#10 +
    '    NOT EXISTS (SELECT rdb$relation_name FROM rdb$relations '#13#10 +
    '      WHERE rdb$relation_name = r.relationname ); '#13#10 +
      '  '#13#10 +
    '  /* дададз_м новыя табл_цы */  '#13#10 +
    '  /* акрамя с_стэмных  */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT rdb$relation_name, rdb$view_source  '#13#10 +
    '      FROM rdb$relations LEFT JOIN at_relations ON relationname=rdb$relation_name  '#13#10 +
    '      WHERE (relationname IS NULL) AND (NOT rdb$relation_name CONTAINING ''RDB$'')  '#13#10 +
    '      INTO :RN, :VS  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      RN = g_s_trim(RN, '' '');  '#13#10 +
    '      IF (:VS IS NULL) THEN  '#13#10 +
    '        INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description)  '#13#10 +
    '        VALUES (:RN, ''T'', :RN, :RN, :RN);  '#13#10 +
    '      ELSE  '#13#10 +
    '        INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description)  '#13#10 +
    '        VALUES (:RN, ''V'', :RN, :RN, :RN);  '#13#10 +
    '      END  '#13#10 +
      '  '#13#10 +
    '  /* дадаем новыя пал_ */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT  '#13#10 +
    '        rr.rdb$field_name, rr.rdb$field_source, rr.rdb$relation_name, r.id, f.id  '#13#10 +
    '      FROM  '#13#10 +
    '        rdb$relation_fields rr JOIN at_relations r ON rdb$relation_name = r.relationname  '#13#10 +
    '      JOIN at_fields f ON rr.rdb$field_source = f.fieldname  '#13#10 +
    '      LEFT JOIN at_relation_fields rf ON rr.rdb$field_name = rf.fieldname  '#13#10 +
    '      AND rr.rdb$relation_name = rf.relationname  '#13#10 +
    '      WHERE  '#13#10 +
    '        (rf.fieldname IS NULL) AND (NOT rr.rdb$field_name CONTAINING ''RDB$'')  '#13#10 +
    '      INTO  '#13#10 +
    '        :FN, :FS, :RN, :ID, :ID1  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      FN = g_s_trim(FN, '' '');  '#13#10 +
    '      FS = g_s_trim(FS, '' '');  '#13#10 +
    '      RN = g_s_trim(RN, '' '');  '#13#10 +
    '      INSERT INTO at_relation_fields (fieldname, relationname, fieldsource, lname, description,  '#13#10 +
    '        relationkey, fieldsourcekey, colwidth, visible)  '#13#10 +
    '      VALUES(:FN, :RN, :FS, :FN, :FN, :ID, :ID1, 20, 1);  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* обновим информацию о правиле удаления для полей ссылок */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT rf.rdb$delete_rule, f.id  '#13#10 +
    '      FROM rdb$relation_constraints rc  '#13#10 +
    '      LEFT JOIN rdb$index_segments rs ON rc.rdb$index_name = rs.rdb$index_name  '#13#10 +
    '      LEFT JOIN at_relation_fields f ON rc.rdb$relation_name = f.relationname  '#13#10 +
    '      AND  rs.rdb$field_name = f.fieldname  '#13#10 +
    '      LEFT JOIN rdb$ref_constraints rf ON rf.rdb$constraint_name = rc.rdb$constraint_name  '#13#10 +
    '      WHERE  '#13#10 +
    '      rc.rdb$constraint_type = ''FOREIGN KEY''  '#13#10 +
    '      AND ((f.deleterule <> rf.rdb$delete_rule)  '#13#10 +
    '      OR ((f.deleterule IS NULL) AND (rf.rdb$delete_rule IS NOT NULL))  '#13#10 +
    '      OR ((f.deleterule IS NOT NULL) AND (rf.rdb$delete_rule IS NULL)))  '#13#10 +
    '      INTO :DELRULE, :ID  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      UPDATE at_relation_fields SET deleterule = :DELRULE WHERE id = :ID;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* выдал_м не _снуючыя ўжо выключэннi */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT exceptionname  '#13#10 +
    '      FROM at_exceptions LEFT JOIN rdb$exceptions  '#13#10 +
    '      ON exceptionname=rdb$exception_name  '#13#10 +
    '      WHERE  '#13#10 +
    '        rdb$exception_name IS NULL  '#13#10 +
    '      INTO :EN  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      DELETE FROM at_exceptions WHERE exceptionname=:EN;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* дадаем новыя выключэннi */  '#13#10 +
    '    INSERT INTO at_exceptions(exceptionname) '#13#10 +
    '    SELECT g_s_trim(rdb$exception_name, '' '') '#13#10 +
    '    FROM rdb$exceptions '#13#10 +
    '    LEFT JOIN at_exceptions e ON e.exceptionname=rdb$exception_name '#13#10 +
    '    WHERE e.exceptionname IS NULL; '#13#10 +
    '  '#13#10 +
    '  /* выдал_м не _снуючыя ўжо працэдуры */  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT procedurename  '#13#10 +
    '      FROM at_procedures LEFT JOIN rdb$procedures  '#13#10 +
    '        ON procedurename=rdb$procedure_name  '#13#10 +
    '      WHERE  '#13#10 +
    '        rdb$procedure_name IS NULL  '#13#10 +
    '      INTO :EN  '#13#10 +
    '    DO BEGIN  '#13#10 +
    '      DELETE FROM at_procedures WHERE procedurename=:EN;  '#13#10 +
    '    END  '#13#10 +
      '  '#13#10 +
    '  /* дадаем новыя працэдуры */  '#13#10 +
    '    INSERT INTO at_procedures(procedurename) '#13#10 +
    '    SELECT g_s_trim(rdb$procedure_name, '' '') '#13#10 +
    '    FROM rdb$procedures '#13#10 +
    '    LEFT JOIN at_procedures e ON e.procedurename = rdb$procedure_name '#13#10 +
    '    WHERE e.procedurename IS NULL; '#13#10 +
           '  '#13#10 +
    '  /* удалим не существующие уже генераторы */  '#13#10 +
    '    GN = NULL;  '#13#10 +
    '    FOR   '#13#10 +
    '      SELECT generatorname  '#13#10 +
    '      FROM at_generators  '#13#10 +
    '      LEFT JOIN rdb$generators ON generatorname=rdb$generator_name  '#13#10 +
    '      WHERE rdb$generator_name IS NULL  '#13#10 +
    '      INTO :GN   '#13#10 +
    '    DO   '#13#10 +
    '    BEGIN  '#13#10 +
    '      DELETE FROM at_generators WHERE generatorname=:GN;   '#13#10 +
    '    END  '#13#10 +
           '  '#13#10 +
    '  /* добавим новые генераторы */   '#13#10 +
    '    INSERT INTO at_generators(generatorname) '#13#10 +
    '    SELECT G_S_TRIM(rdb$generator_name, '' '') '#13#10 +
    '    FROM rdb$generators '#13#10 +
    '    LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name '#13#10 +
    '    WHERE t.generatorname IS NULL; '#13#10 +
           '  '#13#10 +
    '  /* удалим не существующие уже чеки */  '#13#10 +
    '    EN = NULL;  '#13#10 +
    '    FOR  '#13#10 +
    '      SELECT T.CHECKNAME  '#13#10 +
    '      FROM AT_CHECK_CONSTRAINTS T  '#13#10 +
    '      LEFT JOIN RDB$CHECK_CONSTRAINTS C ON T.CHECKNAME = C.RDB$CONSTRAINT_NAME  '#13#10 +
    '      WHERE C.RDB$CONSTRAINT_NAME IS NULL  '#13#10 +
    '      INTO :EN  '#13#10 +
    '    DO  '#13#10 +
    '    BEGIN  '#13#10 +
    '      DELETE FROM AT_CHECK_CONSTRAINTS WHERE CHECKNAME = :EN;  '#13#10 +
    '    END  '#13#10 +
           '  '#13#10 +
    '  /* добавим новые чеки */  '#13#10 +
    '    INSERT INTO AT_CHECK_CONSTRAINTS(CHECKNAME) '#13#10 +
    '    SELECT G_S_TRIM(C.RDB$CONSTRAINT_NAME,  '' '') '#13#10 +
    '    FROM RDB$TRIGGERS T '#13#10 +
    '    LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME '#13#10 +
    '    LEFT JOIN AT_CHECK_CONSTRAINTS CON ON CON.CHECKNAME = C.RDB$CONSTRAINT_NAME '#13#10 +
    '    WHERE T.RDB$TRIGGER_SOURCE LIKE ''CHECK%'' '#13#10 +
    '      AND CON.CHECKNAME IS NULL; '#13#10 +
    '  '#13#10 +
    ' END ';

  cAc_AccountExSaldo_BalGrant =
    'GRANT EXECUTE ON PROCEDURE AC_ACCOUNTEXSALDO_BAL TO ADMINISTRATOR';

  cCreateAc_AccountExSaldo_Bal =
    ' CREATE OR ALTER PROCEDURE AC_ACCOUNTEXSALDO_BAL( '#13#10 +
    '     DATEEND DATE, '#13#10 +
    '     ACCOUNTKEY INTEGER, '#13#10 +
    '     FIELDNAME VARCHAR(60), '#13#10 +
    '     COMPANYKEY INTEGER, '#13#10 +
    '     ALLHOLDINGCOMPANIES INTEGER, '#13#10 +
    '     CURRKEY INTEGER) '#13#10 +
    ' RETURNS ( '#13#10 +
    '     DEBITSALDO NUMERIC(15, 4), '#13#10 +
    '     CREDITSALDO NUMERIC(15, 4), '#13#10 +
    '     CURRDEBITSALDO NUMERIC(15, 4), '#13#10 +
    '     CURRCREDITSALDO NUMERIC(15, 4), '#13#10 +
    '     EQDEBITSALDO NUMERIC(15, 4), '#13#10 +
    '     EQCREDITSALDO NUMERIC(15, 4)) '#13#10 +
    ' AS '#13#10 +
    ' DECLARE VARIABLE SALDO NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE SALDOCURR NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE SALDOEQ NUMERIC(15, 4); '#13#10 +
    '   DECLARE VARIABLE TEMPVAR varchar(60); '#13#10 +
    '   DECLARE VARIABLE CLOSEDATE DATE; '#13#10 +
    '   declare variable sqlstatement varchar(2048); '#13#10 +
    ' BEGIN  '#13#10 +
    '   DEBITSALDO = 0;  '#13#10 +
    '   CREDITSALDO = 0;  '#13#10 +
    '   CURRDEBITSALDO = 0;  '#13#10 +
    '   CURRCREDITSALDO = 0;  '#13#10 +
    '   EQDEBITSALDO = 0;  '#13#10 +
    '   EQCREDITSALDO = 0;  '#13#10 +
    '   CLOSEDATE = CAST((CAST(''17.11.1858'' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); '#13#10 +
    '  '#13#10 +
    '   IF (:dateend >= :CLOSEDATE) THEN '#13#10 +
    '   BEGIN '#13#10 +
    '     sqlstatement = '#13#10 +
    '       ''SELECT '#13#10 +
    '         main.'' || FIELDNAME || '', '#13#10 +
    '         SUM(main.debitncu - main.creditncu), '#13#10 +
    '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
    '         SUM(main.debiteq - main.crediteq) '#13#10 +
    '       FROM '#13#10 +
    '       ( '#13#10 +
    '         SELECT '#13#10 +
    '           bal.'' || FIELDNAME || '', '#13#10 +
    '           bal.debitncu, bal.creditncu, '#13#10 +
    '           bal.debitcurr, bal.creditcurr, '#13#10 +
    '           bal.debiteq, bal.crediteq '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry_balance bal '#13#10 +
    '         WHERE '#13#10 +
    '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
    '            AND (bal.companykey = '' || CAST(:companykey AS VARCHAR(20)) || '' OR '#13#10 +
    '             ('' || CAST(:ALLHOLDINGCOMPANIES AS VARCHAR(20)) || '' = 1 '#13#10 +
    '             AND '#13#10 +
    '               bal.companykey IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || ''))) '#13#10 +
    '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (bal.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
    '        '#13#10 +
    '         UNION ALL '#13#10 +
    '        '#13#10 +
    '         SELECT '#13#10 +
    '           e.'' || FIELDNAME || '', '#13#10 +
    '           e.debitncu, e.creditncu, '#13#10 +
    '           e.debitcurr, e.creditcurr, '#13#10 +
    '           e.debiteq, e.crediteq '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
    '           AND e.entrydate >= '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
    '           AND e.entrydate < '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
    '           AND (e.companykey = '' || CAST(:companykey AS VARCHAR(20)) || '' OR '#13#10 +
    '             ('' || CAST(:ALLHOLDINGCOMPANIES AS VARCHAR(20)) || '' = 1 '#13#10 +
    '             AND '#13#10 +
    '               e.companykey IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || ''))) '#13#10 +
    '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (e.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
    '        '#13#10 +
    '       ) main '#13#10 +
    '       GROUP BY '#13#10 +
    '         main.'' || FIELDNAME; '#13#10 +
    '   END '#13#10 +
    '   ELSE '#13#10 +
    '   BEGIN '#13#10 +
    '     sqlstatement = '#13#10 +
    '       ''SELECT '#13#10 +
    '         main.'' || FIELDNAME || '', '#13#10 +
    '         SUM(main.debitncu - main.creditncu), '#13#10 +
    '         SUM(main.debitcurr - main.creditcurr), '#13#10 +
    '         SUM(main.debiteq - main.crediteq) '#13#10 +
    '       FROM '#13#10 +
    '       ( '#13#10 +
    '         SELECT '#13#10 +
    '           bal.'' || FIELDNAME || '', '#13#10 +
    '           bal.debitncu, bal.creditncu, '#13#10 +
    '           bal.debitcurr, bal.creditcurr, '#13#10 +
    '           bal.debiteq, bal.crediteq '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry_balance bal '#13#10 +
    '         WHERE '#13#10 +
    '           bal.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
    '            AND (bal.companykey = '' || CAST(:companykey AS VARCHAR(20)) || '' OR '#13#10 +
    '             ('' || CAST(:ALLHOLDINGCOMPANIES AS VARCHAR(20)) || '' = 1 '#13#10 +
    '             AND '#13#10 +
    '               bal.companykey IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || ''))) '#13#10 +
    '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (bal.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
    '        '#13#10 +
    '         UNION ALL '#13#10 +
    '        '#13#10 +
    '         SELECT '#13#10 +
    '           e.'' || FIELDNAME || '', '#13#10 +
    '          - e.debitncu, - e.creditncu, '#13#10 +
    '          - e.debitcurr, - e.creditcurr, '#13#10 +
    '          - e.debiteq, - e.crediteq '#13#10 +
    '         FROM '#13#10 +
    '           ac_entry e '#13#10 +
    '         WHERE '#13#10 +
    '           e.accountkey = '' || CAST(:accountkey AS VARCHAR(20)) || '' '#13#10 +
    '           AND e.entrydate >= '''''' || CAST(:dateend AS VARCHAR(20)) || '''''' '#13#10 +
    '           AND e.entrydate < '''''' || CAST(:closedate AS VARCHAR(20)) || '''''' '#13#10 +
    '           AND (e.companykey = '' || CAST(:companykey AS VARCHAR(20)) || '' OR '#13#10 +
    '             ('' || CAST(:ALLHOLDINGCOMPANIES AS VARCHAR(20)) || '' = 1 '#13#10 +
    '             AND '#13#10 +
    '               e.companykey IN ( '#13#10 +
    '                 SELECT '#13#10 +
    '                   h.companykey '#13#10 +
    '                 FROM '#13#10 +
    '                   gd_holding h '#13#10 +
    '                 WHERE '#13#10 +
    '                   h.holdingkey = '' || CAST(:companykey AS VARCHAR(20)) || ''))) '#13#10 +
    '           AND ((0 = '' || CAST(:currkey AS VARCHAR(20)) || '') OR (e.currkey = '' || CAST(:currkey AS VARCHAR(20)) || '')) '#13#10 +
    '        '#13#10 +
    '       ) main '#13#10 +
    '       GROUP BY '#13#10 +
    '         main.'' || FIELDNAME; '#13#10 +
    '   END '#13#10 +
    '  '#13#10 +
    '   FOR '#13#10 +
    '     EXECUTE STATEMENT '#13#10 +
    '       sqlstatement '#13#10 +
    '     INTO '#13#10 +
    '       :TEMPVAR, :SALDO, :SALDOCURR, :SALDOEQ '#13#10 +
    '   DO  '#13#10 +
    '   BEGIN  '#13#10 +
    '     IF (SALDO IS NULL) THEN  '#13#10 +
    '       SALDO = 0;  '#13#10 +
    '     IF (SALDO > 0) THEN  '#13#10 +
    '       DEBITSALDO = DEBITSALDO + SALDO;  '#13#10 +
    '     ELSE  '#13#10 +
    '       CREDITSALDO = CREDITSALDO - SALDO;  '#13#10 +
    '     IF (SALDOCURR IS NULL) THEN '#13#10 +
    '        SALDOCURR = 0; '#13#10 +
    '     IF (SALDOCURR > 0) THEN '#13#10 +
    '       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR; '#13#10 +
    '     ELSE '#13#10 +
    '       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR; '#13#10 +
    '     IF (SALDOEQ IS NULL) THEN '#13#10 +
    '        SALDOEQ = 0; '#13#10 +
    '     IF (SALDOEQ > 0) THEN '#13#10 +
    '       EQDEBITSALDO = EQDEBITSALDO + SALDOEQ; '#13#10 +
    '     ELSE '#13#10 +
    '       EQCREDITSALDO = EQCREDITSALDO - SALDOEQ; '#13#10 +
    '   END '#13#10 +
    '   SUSPEND; '#13#10 +
    ' END ';

procedure AddAcEntryBalanceAndAT_P_SYNC(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, ibsqlFields: TIBSQL;
  AcEntryBalanceStr: String;
  ACTriggerText: String;
  ACFieldList, NewFieldList, OLDFieldList: String;
  gdcField: TgdcField;
begin
  // Проверим на версию сервера, нам нужен Firebird >= 2.0
  if not (IBDB.IsFirebirdConnect and (IBDB.ServerMajorVersion >= 2)) then
    raise EgsWrongServerVersion.Create('Firebird 2.0+');

  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      FTransaction.StartTransaction;

      try
        FIBSQL.SQL.Text := cAT_P_SYNC;
        FIBSQL.ExecQuery;
        Log('Корректировка процедуры AT_P_SYNC прошла успешно');

        // генератор GD_G_ENTRY_BALANCE_DATE
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$generator_name FROM rdb$generators WHERE rdb$generator_name = ''GD_G_ENTRY_BALANCE_DATE'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateGenerator;
          FIBSQL.ExecQuery;
          Log('Создание триггера GD_G_ENTRY_BALANCE_DATE прошло успешно');
        end;

        // таблица AC_ENTRY_BALANCE
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$relation_name FROM rdb$relations WHERE rdb$relation_name = ''AC_ENTRY_BALANCE'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          AcEntryBalanceStr := cAC_ENTRY_BALANCETemplate;
          ibsqlFields := TIBSQL.Create(nil);
          gdcField := TgdcField.Create(nil);
          try
            gdcField.SubSet := 'ByFieldName';
            ibsqlFields.Transaction := FTransaction;
            ibsqlFields.ParamCheck := False;
            ibsqlFields.SQL.Text :=
              ' SELECT ' +
              '   r.rdb$field_name AS FieldName, ' +
              '   r.rdb$field_source AS DomainName ' +
              ' FROM ' +
              '   rdb$relation_fields r ' +
              ' WHERE ' +
              '   r.rdb$relation_name = ''AC_ENTRY'' ' +
              '   AND r.rdb$field_name STARTING WITH ''USR$'' ';
            ibsqlFields.ExecQuery;
            while not ibsqlFields.Eof do
            begin
              gdcField.Close;
              gdcField.ParamByName('fieldname').AsString := Trim(ibsqlFields.FieldByName('DomainName').AsString);
              gdcField.Open;

              ACFieldList := ACFieldList + ', ' + Trim(ibsqlFields.FieldByName('FIELDNAME').AsString);
              NEWFieldList := NEWFieldList + ', NEW.' + Trim(ibsqlFields.FieldByName('FIELDNAME').AsString);
              OLDFieldList := OLDFieldList + ', OLD.' + Trim(ibsqlFields.FieldByName('FIELDNAME').AsString);

              AcEntryBalanceStr := AcEntryBalanceStr + ', ' +
                Trim(ibsqlFields.FieldByName('FIELDNAME').AsString) + '  ' +
                gdcField.GetDomainText(False, True);

              ibsqlFields.Next;
            end;
            AcEntryBalanceStr := AcEntryBalanceStr + ')';
          finally
            gdcField.Free;
            ibsqlFields.Free;
          end;

          FIBSQL.Close;
          FIBSQL.SQL.Text := AcEntryBalanceStr;
          FIBSQL.ExecQuery;
          Log('Создание таблицы AC_ENTRY_BALANCE прошло успешно');

          FIBSQL.Close;
          FIBSQL.SQL.Text := cBalancePrimaryKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cBalanceForeignKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cBalanceAutoincrementTrigger;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cBalanceGrant;
          FIBSQL.ExecQuery;
        end;

        // процедура AC_ACCOUNTEXSALDO_BAL
        FIBSQL.Close;
        FIBSQL.SQL.Text := cCreateAc_AccountExSaldo_Bal;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := cAc_AccountExSaldo_BalGrant;
        FIBSQL.ExecQuery;
        Log('Создание/корректировка процедуры AC_ACCOUNTEXSALDO_BAL прошло успешно');

        // процедура AC_CIRCULATIONLIST_BAL
        FIBSQL.Close;
        FIBSQL.SQL.Text := cCreateAC_CIRCULATIONLIST_BAL;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := cAC_CIRCULATIONLIST_BALGrant;
        FIBSQL.ExecQuery;
        Log('Создание/корректировка процедуры AC_CIRCULATIONLIST_BAL прошло успешно');

        // триггер AC_ENTRY_DO_BALANCE на AC_ENTRY
        ACTriggerText :=
          '  CREATE OR ALTER TRIGGER ac_entry_do_balance FOR ac_entry '#13#10 +
          '  ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 15 '#13#10 +
          '  AS '#13#10 +
          '  BEGIN '#13#10 +
          '    IF (INSERTING AND ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '        (companykey, accountkey, currkey, '#13#10 +
          '         debitncu, debitcurr, debiteq, '#13#10 +
          '         creditncu, creditcurr, crediteq ' +
            ACFieldList + ') '#13#10 +
          '      VALUES '#13#10 +
          '     (NEW.companykey, '#13#10 +
          '      NEW.accountkey, '#13#10 +
          '      NEW.currkey, '#13#10 +
          '      NEW.debitncu, '#13#10 +
          '      NEW.debitcurr, '#13#10 +
          '      NEW.debiteq, '#13#10 +
          '      NEW.creditncu, '#13#10 +
          '      NEW.creditcurr, '#13#10 +
          '      NEW.crediteq ' +
            NEWFieldList + '); '#13#10 +
          '  END '#13#10 +
          '  ELSE '#13#10 +
          '  IF (UPDATING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '      (companykey, accountkey, currkey, '#13#10 +
          '       debitncu, debitcurr, debiteq, '#13#10 +
          '       creditncu, creditcurr, crediteq ' +
            ACFieldList + ') '#13#10 +
          '    VALUES '#13#10 +
          '      (OLD.companykey, '#13#10 +
          '       OLD.accountkey, '#13#10 +
          '       OLD.currkey, '#13#10 +
          '       -OLD.debitncu, '#13#10 +
          '       -OLD.debitcurr, '#13#10 +
          '       -OLD.debiteq, '#13#10 +
          '       -OLD.creditncu, '#13#10 +
          '       -OLD.creditcurr, '#13#10 +
          '       -OLD.crediteq ' +
            OLDFieldList + '); '#13#10 +
          '    IF ((NEW.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0)) THEN '#13#10 +
          '      INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '        (companykey, accountkey, currkey, '#13#10 +
          '         debitncu, debitcurr, debiteq, '#13#10 +
          '         creditncu, creditcurr, crediteq '#13#10 +
            ACFieldList + ') '#13#10 +
          '       VALUES '#13#10 +
          '         (NEW.companykey, '#13#10 +
          '          NEW.accountkey, '#13#10 +
          '          NEW.currkey, '#13#10 +
          '          NEW.debitncu, '#13#10 +
          '          NEW.debitcurr, '#13#10 +
          '          NEW.debiteq, '#13#10 +
          '          NEW.creditncu, '#13#10 +
          '          NEW.creditcurr, '#13#10 +
          '          NEW.crediteq ' +
            NEWFieldList + '); '#13#10 +
          '  END '#13#10 +
          '  ELSE '#13#10 +
          '  IF (DELETING AND ((OLD.entrydate - CAST(''17.11.1858'' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    INSERT INTO AC_ENTRY_BALANCE '#13#10 +
          '      (companykey, accountkey, currkey, '#13#10 +
          '       debitncu, debitcurr, debiteq, '#13#10 +
          '       creditncu, creditcurr, crediteq '#13#10 +
            ACFieldList + ') '#13#10 +
          '    VALUES '#13#10 +
          '     (OLD.companykey, '#13#10 +
          '      OLD.accountkey, '#13#10 +
          '      OLD.currkey, '#13#10 +
          '      -OLD.debitncu, '#13#10 +
          '      -OLD.debitcurr, '#13#10 +
          '      -OLD.debiteq, '#13#10 +
          '      -OLD.creditncu, '#13#10 +
          '      -OLD.creditcurr, '#13#10 +
          '      -OLD.crediteq ' +
            OLDFieldList + '); '#13#10 +
          '  END '#13#10 +
          ' END ';
        FIBSQL.Close;
        FIBSQL.SQL.Text := ACTriggerText;
        FIBSQL.ExecQuery;
        Log('Создание триггера для таблицы AC_ENTRY прошло успешно');

        // Проверим существование ярлыка "Переход на новый месяц"
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT id FROM gd_command WHERE id = 714200';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cInsertCommand;
          FIBSQL.ExecQuery;
          Log('Создание ярлыка "Переход на новый месяц" прошло успешно');
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (109, ''0000.0001.0000.0141'', ''15.10.2008'', ''Добавлен расчет сальдо по проводкам'') ';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      except
        on E: Exception do
        begin
          Log('Произошла ошибка: ' + E.Message);
          if FTransaction.InTransaction then
            FTransaction.Rollback;
          raise;
        end;
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure AddMissedGrantsToAcEntryBalanceProcedures(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      FTransaction.StartTransaction;
      try
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$procedure_name FROM rdb$procedures WHERE rdb$procedure_name = ''AC_ACCOUNTEXSALDO_BAL''';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount > 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cAc_AccountExSaldo_BalGrant;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT rdb$procedure_name FROM rdb$procedures WHERE rdb$procedure_name = ''AC_CIRCULATIONLIST_BAL''';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount > 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cAC_CIRCULATIONLIST_BALGrant;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_companyaccount DROP CONSTRAINT ac_pk_companyaccount ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE ac_companyaccount '#13#10 +
          '  ADD CONSTRAINT ac_pk_companyaccount PRIMARY KEY (companykey, accountkey) ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (112, ''0000.0001.0000.0144'', ''25.04.2009'', ''Проставлены пропущенные гранты'') ';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      except
        on E: Exception do
        begin
          Log('Произошла ошибка: ' + E.Message);
          if FTransaction.InTransaction then
            FTransaction.Rollback;
          raise;
        end;
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
