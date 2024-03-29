
/*
 *
 *  ���������� �����
 *  A - (active) ��������
 *  P - (passive) ���������
 *  B - (both) �������-���������
 *
 *  NULL - ��� ����� ������, ������ ������
 *
 */

CREATE DOMAIN daccountactivity
  AS CHAR(1)
  CHECK (VALUE IN ('A', 'P', 'B'));

/*
 *
 *  ����� ����� ������
 *  C - (chart of account) ���� ������
 *  F - (folder) ����� (������) ������
 *  A - (account) ����
 *  S - (subaccount) �������
 *
 */

CREATE DOMAIN dchartofaccountpart
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('C', 'F', 'A', 'S'));

/*
 *
 *  ������ ������ ������������� ������, ���������
 *  �� ����� ������, ������ � ���������
 *
 */


CREATE TABLE ac_account
(
  id               dintkey,             /* ������������� */
  parent           dparent,             /* ������������ ����� */

  lb               dlb,                 /* ����� ������� */
  rb               drb,                 /* ������ ������� */

  name             dtext180,            /* ������������ ����� */
  alias            daccountalias,       /* ��� ����� */

  analyticalfield  dforeignkey,         /* ������������� ���� ��� �������-��������� ������ */

  activity         daccountactivity,    /* ���������� ����� */

  accounttype      dchartofaccountpart, /* ����� ����� ������ */

  multycurr        dboolean DEFAULT 0,  /* �������� �� ���� �������� */
  offbalance       dboolean DEFAULT 0,  /* ������������ ���� */

  afull            dsecurity,           /* ����������� ������������ */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  fullname         COMPUTED BY (COALESCE(ALIAS, '') || ' ' || COALESCE(NAME, '')),

  description      dblobtext80_1251,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,

  CONSTRAINT ac_chk_account_activity CHECK(
    (activity IS NULL AND accounttype IN ('C', 'F')) OR (activity IS NOT NULL)
  )
);

COMMIT;

ALTER TABLE ac_account
  ADD CONSTRAINT ac_pk_account PRIMARY KEY (id);

ALTER TABLE ac_account ADD CONSTRAINT ac_fk_account_parent
  FOREIGN KEY (parent) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_account ADD CONSTRAINT ac_fk_account_anltcf
  FOREIGN KEY (analyticalfield) REFERENCES at_relation_fields(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT BN_FK_BSL_ACCOUNTKEY
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE;

CREATE ASC INDEX ac_x_account_alias
  ON ac_account(alias);

COMMIT;

CREATE EXCEPTION ac_e_invalidaccount 'Invalid account!';
CREATE EXCEPTION ac_e_duplicateaccount 'Duplicate account!';

SET TERM ^;

CREATE OR ALTER TRIGGER AC_AIU_ACCOUNT_CHECKALIAS FOR AC_ACCOUNT
  ACTIVE
  AFTER INSERT OR UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE P CHAR(1) = NULL;
  DECLARE VARIABLE A daccountalias;
BEGIN
  IF (INSERTING OR (NEW.alias <> OLD.alias)) THEN
  BEGIN
    IF (EXISTS
        (SELECT
           root.id, UPPER(TRIM(allacc.alias)), COUNT(*)
         FROM ac_account root
           JOIN ac_account allacc ON allacc.lb > root.lb AND allacc.rb <= root.rb
         WHERE
           root.parent IS NULL
         GROUP BY
           1, 2
         HAVING
           COUNT(*) > 1)
        )
      THEN
        EXCEPTION ac_e_duplicateaccount '����������� ������������ ' || NEW.alias;

    IF (NEW.accounttype = 'A' AND (POSITION('.' IN NEW.alias) <> 0)) THEN
      EXCEPTION ac_e_invalidaccount '����� ����� �� ����� ��������� �����. ����: ' || NEW.alias;

    IF (COALESCE(NEW.disabled, 0) = 0) THEN
    BEGIN
      IF (NEW.accounttype = 'S') THEN
      BEGIN
        SELECT alias FROM ac_account WHERE id = NEW.parent INTO :A;

        IF (POSITION(:A IN NEW.alias) <> 1) THEN
          EXCEPTION ac_e_invalidaccount '����� �������� ������ ���������� � ������ ������������ �����/��������. �������: ' || NEW.alias;
      END
    END
  END

  IF (INSERTING OR (NEW.parent IS DISTINCT FROM OLD.parent)
    OR (NEW.accounttype <> OLD.accounttype)) THEN
  BEGIN
    SELECT accounttype FROM ac_account WHERE id = NEW.parent INTO :P;
    P = COALESCE(:P, 'Z');

    IF (NEW.accounttype = 'C' AND NOT (NEW.parent IS NULL)) THEN
      EXCEPTION ac_e_invalidaccount '���� ������ �� ����� ������� � ������ ���� ������ ��� ������.';

    IF (NEW.accounttype = 'F' AND NOT (:P IN ('C', 'F'))) THEN
      EXCEPTION ac_e_invalidaccount '������ ������ ������� � ���� ������ ��� ������ ������.';

    IF (NEW.accounttype = 'A' AND NOT (:P IN ('C', 'F'))) THEN
      EXCEPTION ac_e_invalidaccount '���� ������ ������� � ���� ������ ��� ������.';

    IF (NEW.accounttype = 'S' AND NOT (:P IN ('A', 'S'))) THEN
      EXCEPTION ac_e_invalidaccount '������� ������ ������� � ���� ��� �������.';
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

  �������-������ ����� � ��������� ��������� ��� ������������ ������

*****************************************************/

CREATE TABLE ac_accanalyticsext
(
  id          dintkey,
  accountkey  dintkey,
  valuekey    dintkey,

  CONSTRAINT ac_pk_ac_accanalyticsext PRIMARY KEY (id)
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_accanalyticsext
  ON ac_accanalyticsext (accountkey, valuekey);

COMMIT;

ALTER TABLE ac_accanalyticsext ADD CONSTRAINT fk_ac_accanalyticsext_account
  FOREIGN KEY (accountkey) REFERENCES ac_account (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_accanalyticsext ADD CONSTRAINT fk_ac_accanalyticsext_value
  FOREIGN KEY (valuekey) REFERENCES at_relation_fields(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/*
 *
 *  ������ ������ ������, ������������ ���� ��� �����
 *  �������������. ������ ����������� ����� ������ ����
 *  �������� ���� ������.
 */

CREATE TABLE ac_companyaccount
(
  companykey       dintkey,             /* ���� ������� �������� */
  accountkey       dintkey,             /* ���� ����� ������ */

  isactive         dboolean DEFAULT 0,  /* ������� �� ���� ������ ��� ����������� */

  reserved         dinteger
);

COMMIT;

ALTER TABLE ac_companyaccount
  ADD CONSTRAINT ac_pk_companyaccount PRIMARY KEY (companykey, accountkey);

ALTER TABLE ac_companyaccount ADD CONSTRAINT ac_fk_companyaccount_accnt
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_companyaccount ADD CONSTRAINT ac_fk_companyaccount_compny
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/*
 *
 *  ������ ������� ��������.
 *
 */

CREATE TABLE ac_transaction
(
  id               dintkey,             /* ������������� */
  parent           dparent,             /* ������������ ����� */

  lb               dlb,                 /* ����� ������� */
  rb               drb,                 /* ������ ������� */

  name             dname,               /* ������������ ��������  */
  description      dtext180,            /* �������� �������� */

  companykey       dforeignkey,         /* ��������, ������� ����������� �������� */
                                        /* �� ����� ���� ������ - ����� ����� ��������*/
  isinternal       dboolean,            /* ���������� �������� */

  afull            dsecurity,           /* ����������� ������������ */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  autotransaction  dboolean             /*������� �������������� ��������*/
);

COMMIT;

ALTER TABLE ac_transaction
  ADD CONSTRAINT ac_pk_transaction PRIMARY KEY (id);

ALTER TABLE ac_transaction ADD CONSTRAINT ac_fk_transaction_parent
  FOREIGN KEY (parent) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_transaction ADD CONSTRAINT ac_fk_transaction_compn
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_transactionkey
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id) ON UPDATE CASCADE;

COMMIT;

/*
 *  ����� �����
 *  D - �����
 *  C - ������
 */

CREATE DOMAIN daccountpart
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('D', 'C'));

/*
 *
 *  ������ ������� �������� ��
 *  ������� ��������.
 *
 */

CREATE TABLE ac_trrecord (
  id               dintkey,             /* ������������� */
  transactionkey   dmasterkey,          /* ���� ������� �������� */

  description      dtext180,            /* �������� �������� */
  issavenull       dboolean,            /* ��������� ������� �������� */
  accountkey       dforeignkey,         /* ���� ������ */

  afull            dsecurity,           /* ����������� ������������ */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  functionkey      dforeignkey,         /* ���� �������*/
  documenttypekey  dforeignkey,         /* ��� ��������� �������� */
  functiontemplate dblob80,             /* ������ ������� */
  documentpart     dtext10,             /* ��� ��������� ��������� */

  dbegin           ddate,               /* ���� ������ �������� ������� �������� */
  dend             ddate                /* ���� ��������� �������� ������� �������� */
);

ALTER TABLE ac_trrecord
  ADD CONSTRAINT ac_pk_trrecord PRIMARY KEY (id);

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_tr
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_function
  FOREIGN KEY (functionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_documenttype
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_ak
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_chk_trrecord_date
  CHECK ((dbegin IS NULL) OR (dend IS NULL) OR (dbegin <= dend));

COMMIT;

/*
 *
 *  ������������� ��������.
 *
 */

CREATE TABLE ac_record(
  id               dintkey,             /* ������������� */

  trrecordkey      dintkey,             /* ���� ������� �������� */
  transactionkey   dintkey,             /* ���� ������� �������� */

  recorddate       ddate NOT NULL,      /* ���� �������� */
  description      dtext180,            /* �������� �������� */

  documentkey      dmasterkey,          /* ���� ���������, �� �������� ������� �������� */
  masterdockey     dintkey,             /* ���� ����� ��������� */
  companykey       dintkey,             /* ���� ����� �� ������� ������������ �������� */

/* ����� �� �������� ������������ ��� �������� ������������ ����� �������� */

  debitncu         dcurrency,           /* ����� �������� �� ������ � ��� */
  debitcurr        dcurrency,           /* ����� �������� �� ������ � ��� */

  creditncu        dcurrency,           /* ����� �������� �� ������� � ��� */
  creditcurr       dcurrency,           /* ����� �������� �� ������� � ��� */

  delayed          dboolean DEFAULT 0,  /* ���������� �������� ��� ��� */
  incorrect        dboolean DEFAULT 0,  /* ������������ �������� */

  afull            dsecurity,           /* ����������� ������������ */
  achag            dsecurity,
  aview            dsecurity,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger
);

ALTER TABLE ac_record
  ADD CONSTRAINT ac_pk_record PRIMARY KEY (id);

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_trrec
  FOREIGN KEY (trrecordkey) REFERENCES ac_trrecord(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_tr
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_doc
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_mdoc
  FOREIGN KEY (masterdockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_compn
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

/*
 *
 *  ������ ������������� ��������
 *
 */


CREATE TABLE ac_entry(
  id               dintkey,             /* ������������� */
  recordkey        dmasterkey,          /* ���� �������� */
  entrydate        ddate,               /* ���� �������� */

  transactionkey   dintkey,             /* ���� ������� �������� */
  documentkey      dmasterkey,          /* ���� ���������, �� �������� ������� �������� */
  masterdockey     dintkey,             /* ���� ����� ��������� */
  companykey       dintkey,             /* ���� ����� �� ������� ������������ �������� */


  accountkey       dintkey,             /* ��� �������������� ����� */

  accountpart      daccountpart,        /* ����� ����� D - �����, K - ������ */

  debitncu         dcurrency,           /* ����� �� ������ � ������ */
  debitcurr        dcurrency,           /* ����� �� ������ � ������ */
  debiteq          dcurrency,           /* ����� �� ������ � ����������� */

  creditncu        dcurrency,           /* ����� �� ������� � ������ */
  creditcurr       dcurrency,           /* ����� �� ������� � ������ */
  crediteq         dcurrency,           /* ����� �� ������� � ����������� */

  currkey          dintkey,             /* ���� ������ */

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  issimple         DBOOLEAN_NOTNULL NOT NULL  /*��� �������� �� �� ���
                   ������ ����� �������� �������� �������*/
);

COMMIT;

ALTER TABLE ac_entry
  ADD CONSTRAINT ac_pk_entry PRIMARY KEY (id);

ALTER TABLE ac_entry ADD CONSTRAINT ac_fk_entry_rk
  FOREIGN KEY (recordkey) REFERENCES ac_record(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_entry ADD CONSTRAINT gd_fk_entry_ac
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_entry ADD CONSTRAINT gd_fk_entry_curr
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_COMPANYKEY
  FOREIGN KEY (COMPANYKEY) REFERENCES GD_COMPANY (CONTACTKEY)
  ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_DOCKEY
  FOREIGN KEY (DOCUMENTKEY) REFERENCES GD_DOCUMENT (ID)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_MASTERDOCKEY
  FOREIGN KEY (MASTERDOCKEY) REFERENCES GD_DOCUMENT (ID)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_TRANSACTIONKEY
  FOREIGN KEY (TRANSACTIONKEY) REFERENCES AC_TRANSACTION (ID)
  ON UPDATE CASCADE;


COMMIT;

CREATE INDEX AC_ENTRY_ACKEY_ENTRYDATE ON AC_ENTRY (ACCOUNTKEY, ENTRYDATE);
CREATE INDEX AC_ENTRY_ENTRYDATE ON AC_ENTRY (ENTRYDATE);
CREATE INDEX AC_ENTRY_RECKEY_ACPART ON AC_ENTRY (RECORDKEY, ACCOUNTPART);
COMMIT;

/*
* � ��������� ��������� ���� ���������� ������ ����� �� ���������
* (������� � ���� ����� ����� ������� � 17.11.1858)
*/
CREATE GENERATOR gd_g_entry_balance_date;
SET GENERATOR GD_G_ENTRY_BALANCE_DATE TO 0;

/*
*
* ������ �� ��������� �� ���� (�� ���������� gd_g_entry_balance_date)
*  ���� �������� ac_entry (�� ����������� ��������������).
*
*/

CREATE TABLE ac_entry_balance (
  id                      dintkey,
  companykey              dintkey,
  accountkey              dintkey,
  currkey                 dintkey,

  debitncu                dcurrency,
  debitcurr               dcurrency,
  debiteq                 dcurrency,
  creditncu               dcurrency,
  creditcurr              dcurrency,
  crediteq                dcurrency
);

COMMIT;

ALTER TABLE ac_entry_balance ADD CONSTRAINT pk_ac_entry_bal PRIMARY KEY (id);
ALTER TABLE ac_entry_balance ADD CONSTRAINT gd_fk_entry_bal_ac FOREIGN KEY (accountkey) REFERENCES ac_account (id) ON UPDATE CASCADE;
CREATE INDEX ac_entry_balance_accountkey ON ac_entry_balance (accountkey);

COMMIT;

SET TERM ^;

CREATE OR ALTER TRIGGER ac_bi_entry_balance FOR ac_entry_balance
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  IF (NEW.debitncu IS NULL) THEN
    NEW.debitncu = 0;
  IF (NEW.debitcurr IS NULL) THEN
    NEW.debitcurr = 0;
  IF (NEW.debiteq IS NULL) THEN
    NEW.debiteq = 0;
  IF (NEW.creditncu IS NULL) THEN
    NEW.creditncu = 0;
  IF (NEW.creditcurr IS NULL) THEN
    NEW.creditcurr = 0;
  IF (NEW.crediteq IS NULL) THEN
    NEW.crediteq = 0;
END
^
SET TERM ;^


/*
 *
 *  ��� ������� ��� �������
 *  ��������:
 *  B - ������ ����������� ����� �������� ������ ������ ��������
 *  A - ������ ����������� ����� ������� ������ ������ ��������
 *  E - ������ ����������� ������ ��� ���������� ������� ��������
 *
 */

CREATE DOMAIN daccountingscriptkind
  AS CHAR(1)
  CHECK (VALUE IN ('B', 'A', 'E'));

SET TERM ^ ;

CREATE TRIGGER ac_bi_account FOR ac_account
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
 *
 *  ���� ��������� �������� ���� ������
 *  ������ ����� ������������� ������ �� ���������.
 */

CREATE OR ALTER TRIGGER ac_bi_companyaccount FOR ac_companyaccount
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
  DECLARE VARIABLE ActiveID DFOREIGNKEY = NULL;
BEGIN
  SELECT FIRST 1 accountkey FROM ac_companyaccount
    WHERE companykey = NEW.companykey AND isactive = 1
    INTO :ActiveID;

  IF (:ActiveID IS NULL) THEN
    NEW.isactive = 1;
  ELSE
    IF ((:ActiveID <> NEW.accountkey) AND (NEW.isactive = 1)) THEN
      UPDATE ac_companyaccount SET isactive = 0
      WHERE companykey = NEW.companykey AND accountkey = :ActiveID;
END
^

CREATE OR ALTER TRIGGER ac_ad_companyaccount FOR ac_companyaccount
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.isactive = 1) THEN
    UPDATE ac_companyaccount SET isactive = 1
    WHERE companykey = OLD.companykey AND accountkey <> OLD.accountkey
    ROWS 1;
END
^

CREATE OR ALTER TRIGGER ac_entry_do_balance FOR ac_entry
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 15
AS
BEGIN
  IF (GEN_ID(gd_g_entry_balance_date, 0) > 0) THEN
  BEGIN
    /* ������� ��������� ������ � ������� ac_entry_balance � ����������� � ����������� � ac_entry */
    IF (INSERTING AND ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
     (NEW.companykey,
      NEW.accountkey,
      NEW.currkey,
      NEW.debitncu,
      NEW.debitcurr,
      NEW.debiteq,
      NEW.creditncu,
      NEW.creditcurr,
      NEW.crediteq);
    END
    ELSE
    IF (UPDATING AND ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
        (OLD.companykey,
         OLD.accountkey,
         OLD.currkey,
         -OLD.debitncu,
         -OLD.debitcurr,
         -OLD.debiteq,
         -OLD.creditncu,
         -OLD.creditcurr,
         -OLD.crediteq);
      IF ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0)) THEN
        INSERT INTO ac_entry_balance
          (companykey, accountkey, currkey,
           debitncu, debitcurr, debiteq,
           creditncu, creditcurr, crediteq)
         VALUES
           (NEW.companykey,
            NEW.accountkey,
            NEW.currkey,
            NEW.debitncu,
            NEW.debitcurr,
            NEW.debiteq,
            NEW.creditncu,
            NEW.creditcurr,
            NEW.crediteq);
    END
    ELSE
    IF (DELETING AND ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
       (OLD.companykey,
        OLD.accountkey,
        OLD.currkey,
        -OLD.debitncu,
        -OLD.debitcurr,
        -OLD.debiteq,
        -OLD.creditncu,
        -OLD.creditcurr,
        -OLD.crediteq);
    END
  END
END
^

CREATE TRIGGER ac_bi_transaction FOR ac_transaction
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*****************************************************/
/*                                                   */
/*    ac_trrecord                                    */
/*    �������� � �������� ���������                  */
/*                                                   */
/*****************************************************/

CREATE TRIGGER ac_bi_trrecord FOR ac_trrecord
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION AC_E_CANTDELETETRENTRY 'Can not delete entry'
^

CREATE TRIGGER ac_bd_trrecord FOR ac_trrecord
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  /* ������ ������� ����������������� ��������  */
  IF (OLD.ID < 147000000) THEN
    EXCEPTION AC_E_CANTDELETETRENTRY;
END
^

/*****************************************************/
/*                                                   */
/*    ac_record                                      */
/*    �������� � �������� ���������                  */
/*                                                   */
/*****************************************************/

CREATE GLOBAL TEMPORARY TABLE ac_incorrect_record (
  id    dintkey,
  CONSTRAINT ac_pk_incorrect_record PRIMARY KEY (id)
)
  ON COMMIT DELETE ROWS
^

CREATE EXCEPTION ac_e_invalidentry 'Invalid entry'
^

CREATE OR ALTER TRIGGER ac_bi_record FOR ac_record
  BEFORE INSERT
  POSITION 31700
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.debitncu = 0;
  NEW.debitcurr = 0;
  NEW.creditncu = 0;
  NEW.creditcurr = 0;

  INSERT INTO ac_incorrect_record (id) VALUES (NEW.id);
END
^

CREATE OR ALTER TRIGGER ac_bu_record FOR ac_record
  BEFORE UPDATE
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK') IS NULL) THEN
  BEGIN
    NEW.debitncu = OLD.debitncu;
    NEW.creditncu = OLD.creditncu;
    NEW.debitcurr = OLD.debitcurr;
    NEW.creditcurr = OLD.creditcurr;
  END

  IF (NEW.debitncu IS DISTINCT FROM OLD.debitncu OR
    NEW.creditncu IS DISTINCT FROM OLD.creditncu) THEN
  BEGIN
    IF (NEW.debitncu IS DISTINCT FROM NEW.creditncu) THEN
      UPDATE OR INSERT INTO ac_incorrect_record (id) VALUES (NEW.id)
        MATCHING (id);
    ELSE
      DELETE FROM ac_incorrect_record WHERE id = NEW.id;
  END

  IF (NEW.recorddate <> OLD.recorddate
    OR NEW.transactionkey <> OLD.transactionkey
    OR NEW.documentkey <> OLD.documentkey
    OR NEW.masterdockey <> OLD.masterdockey
    OR NEW.companykey <> OLD.companykey) THEN
  BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', 1);
    UPDATE ac_entry e
    SET e.entrydate = NEW.recorddate,
      e.transactionkey = NEW.transactionkey,
      e.documentkey = NEW.documentkey,
      e.masterdockey = NEW.masterdockey,
      e.companykey = NEW.companykey
    WHERE
      e.recordkey = NEW.id;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', NULL);
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ad_record FOR ac_record
  AFTER DELETE
  POSITION 31700
AS
BEGIN
  DELETE FROM ac_incorrect_record WHERE id = OLD.id;
END
^

CREATE OR ALTER TRIGGER ac_tc_record
  ACTIVE
  ON TRANSACTION COMMIT
  POSITION 9000
AS
  DECLARE VARIABLE ID DFOREIGNKEY;
  DECLARE VARIABLE STM VARCHAR(512);
  DECLARE VARIABLE DNCU DCURRENCY;
  DECLARE VARIABLE CNCU DCURRENCY;
  DECLARE VARIABLE OFFBALANCE INTEGER;
  DECLARE VARIABLE EID DFOREIGNKEY;
BEGIN
  IF (EXISTS (SELECT * FROM ac_incorrect_record)) THEN
  BEGIN
    STM =
      'SELECT r.id, r.debitncu, r.creditncu, a.offbalance, e.id ' ||
      'FROM ac_record r ' ||
      '  JOIN ac_incorrect_record ir ON ir.id = r.id ' ||
      '  LEFT JOIN ac_entry e ON e.recordkey = r.id ' ||
      '  LEFT JOIN ac_account a ON a.id = e.accountkey';

    FOR
      EXECUTE STATEMENT (:STM)
      INTO :ID, :DNCU, :CNCU, :OFFBALANCE, :EID
    DO BEGIN
      IF ((:EID IS NULL)
        OR ((:OFFBALANCE IS DISTINCT FROM 1) AND (:DNCU <> :CNCU))) THEN
      BEGIN
        EXCEPTION ac_e_invalidentry '������� ��������� ������������ �������� � ��: ' || :ID;
      END
    END
  END
END
^

/****************************************************/
/**                                                **/
/**   ����� ����������� ��������� ����������       **/
/**   ������������� � �������� �������� �����      **/
/**                                                **/
/****************************************************/

CREATE OR ALTER TRIGGER ac_bi_entry FOR ac_entry
  BEFORE INSERT
  POSITION 31700
AS
  DECLARE VARIABLE Cnt DFOREIGNKEY = 0;
  DECLARE VARIABLE Cnt2 DFOREIGNKEY = 0;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.accountpart = 'C') THEN
  BEGIN
    NEW.debitncu = 0;
    NEW.debitcurr = 0;
    NEW.debiteq = 0;
    NEW.creditncu = COALESCE(NEW.creditncu, 0);
    NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0));
    NEW.crediteq = COALESCE(NEW.crediteq, 0);
  END ELSE
  BEGIN
    NEW.creditncu = 0;
    NEW.creditcurr = 0;
    NEW.crediteq = 0;
    NEW.debitncu = COALESCE(NEW.debitncu, 0);
    NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0));
    NEW.debiteq = COALESCE(NEW.debiteq, 0);
  END

  SELECT recorddate, transactionkey, documentkey, masterdockey, companykey
  FROM ac_record
  WHERE id = NEW.recordkey
  INTO NEW.entrydate, NEW.transactionkey, NEW.documentkey, NEW.masterdockey, NEW.companykey;

  SELECT
    COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0),
    COALESCE(SUM(IIF(accountpart <> NEW.accountpart, 1, 0)), 0)
  FROM ac_entry
  WHERE recordkey = NEW.recordkey
  INTO :Cnt, :Cnt2;

  IF (:Cnt > 0 AND :Cnt2 > 1) THEN
    EXCEPTION ac_e_invalidentry;

  IF (:Cnt = 0) THEN
    NEW.issimple = 1;
  ELSE BEGIN
    NEW.issimple = 0;
    IF (:Cnt = 1) THEN
    BEGIN
      WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
      IF (:WasSetIsSimple IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
      UPDATE ac_entry SET issimple = 0
      WHERE recordkey = NEW.recordkey AND accountpart = NEW.accountpart
        AND id <> NEW.id;
      IF (:WasSetIsSimple IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ai_entry FOR ac_entry
  AFTER INSERT
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
  UPDATE
    ac_record
  SET
    debitncu = debitncu + NEW.debitncu,
    creditncu = creditncu + NEW.creditncu,
    debitcurr = debitcurr + NEW.debitcurr,
    creditcurr = creditcurr + NEW.creditcurr
  WHERE
    id = NEW.recordkey;
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);


  WHEN ANY DO

  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_bu_entry FOR ac_entry
  BEFORE UPDATE
  POSITION 31700
AS
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE') IS NOT NULL) THEN
    EXIT;

  NEW.recordkey = OLD.recordkey;

  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK') IS NULL) THEN
  BEGIN
    NEW.entrydate = OLD.entrydate;
    NEW.transactionkey = OLD.transactionkey;
    NEW.documentkey = OLD.documentkey;
    NEW.masterdockey = OLD.masterdockey;
    NEW.companykey = OLD.companykey;
    NEW.issimple = OLD.issimple;
  END

  IF (NEW.currkey IS NULL) THEN
  BEGIN
    NEW.creditcurr = 0;
    NEW.debitcurr = 0;
  END

  IF (NEW.accountpart <> OLD.accountpart) THEN
  BEGIN
    IF (NEW.accountpart = 'C') THEN
    BEGIN
      NEW.debitncu = 0;
      NEW.debitcurr = 0;
      NEW.debiteq = 0;
      NEW.creditncu = COALESCE(NEW.creditncu, 0);
      NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0));
      NEW.crediteq = COALESCE(NEW.crediteq, 0);
    END ELSE
    BEGIN
      NEW.creditncu = 0;
      NEW.creditcurr = 0;
      NEW.crediteq = 0;
      NEW.debitncu = COALESCE(NEW.debitncu, 0);
      NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0));
      NEW.debiteq = COALESCE(NEW.debiteq, 0);
    END
  END
END
^

CREATE OR ALTER TRIGGER ac_au_entry FOR ac_entry
  AFTER UPDATE
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
  DECLARE VARIABLE Cnt INTEGER;
  DECLARE VARIABLE Cnt2 INTEGER;
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE') IS NOT NULL) THEN
    EXIT;

  IF ((OLD.debitncu <> NEW.debitncu) or (OLD.creditncu <> NEW.creditncu) or
      (OLD.debitcurr <> NEW.debitcurr) or (OLD.creditcurr <> NEW.creditcurr))
  THEN BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
    UPDATE ac_record SET debitncu = debitncu - OLD.debitncu + NEW.debitncu,
      creditncu = creditncu - OLD.creditncu + NEW.creditncu,
      debitcurr = debitcurr - OLD.debitcurr + NEW.debitcurr,
      creditcurr = creditcurr - OLD.creditcurr + NEW.creditcurr
    WHERE
      id = OLD.recordkey;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);

  END

  IF (NEW.accountpart <> OLD.accountpart) THEN
  BEGIN
    SELECT
      COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0),
      COALESCE(SUM(IIF(accountpart = OLD.accountpart, 1, 0)), 0)
    FROM ac_entry
    WHERE recordkey = NEW.recordkey AND id <> NEW.id
    INTO :Cnt, :Cnt2;

    IF (:Cnt > 1 AND :Cnt2 > 1) THEN
      EXCEPTION ac_e_invalidentry;

    WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
    IF (:WasSetIsSimple IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
    UPDATE ac_entry SET
      issimple = IIF(accountpart = NEW.accountpart,
        IIF(:Cnt > 1, 0, 1),
        IIF(:Cnt2 > 1, 0, 1))
    WHERE recordkey = NEW.recordkey;
    IF (:WasSetIsSimple IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ad_entry FOR ac_entry
  AFTER DELETE
  POSITION 31700
AS
  DECLARE VARIABLE Cnt INTEGER = 0;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NOT EXISTS(SELECT id FROM ac_entry WHERE recordkey = OLD.recordkey)) THEN
    DELETE FROM ac_record WHERE id = OLD.recordkey;
  ELSE BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
    UPDATE ac_record SET
      debitncu = debitncu - OLD.debitncu,
      creditncu = creditncu - OLD.creditncu,
      debitcurr = debitcurr - OLD.debitcurr,
      creditcurr = creditcurr - OLD.creditcurr
    WHERE
      id = OLD.recordkey;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);

    IF (OLD.issimple = 0) THEN
    BEGIN
      SELECT COUNT(*) FROM ac_entry
      WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart
      INTO :Cnt;

      IF (:Cnt = 1) THEN
      BEGIN
        WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
        IF (:WasSetIsSimple IS NULL) THEN
          RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
        UPDATE ac_entry SET issimple = 1
        WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart;
        IF (:WasSetIsSimple IS NULL) THEN
          RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE TRIGGER ac_bi_entry_block FOR ac_entry
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = NEW.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER ac_bu_entry_block FOR ac_entry
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))
      OR ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = NEW.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER ac_bd_entry_block FOR ac_entry
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = OLD.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

/* �������� ��������� ��� �������� ��������� ��������� */

CREATE PROCEDURE AC_ACCOUNTEXSALDO (
    DATEEND DATE,
    ACCOUNTKEY DFOREIGNKEY,
    FIELDNAME VARCHAR(60),
    COMPANYKEY DFOREIGNKEY,
    ALLHOLDINGCOMPANIES INTEGER,
    INGROUP INTEGER,
    CURRKEY DFOREIGNKEY)
RETURNS
    (DEBITSALDO NUMERIC(15,4),
    CREDITSALDO NUMERIC(15,4),
    CURRDEBITSALDO NUMERIC(15,4),
    CURRCREDITSALDO NUMERIC(15,4),
    EQDEBITSALDO NUMERIC(15,4),
    EQCREDITSALDO NUMERIC(15,4))
AS
BEGIN
  DEBITSALDO = 0;
  CREDITSALDO = 0;
  CURRDEBITSALDO = 0;
  CURRCREDITSALDO = 0;
  EQDEBITSALDO = 0;
  EQCREDITSALDO = 0;
  SUSPEND;
END
^

/* ��������������� ��������� ��� �������� ��������� ��������� � ������� ������������ ������ */

CREATE OR ALTER PROCEDURE AC_ACCOUNTEXSALDO_BAL (
    DATEEND DATE,
    ACCOUNTKEY DFOREIGNKEY,
    FIELDNAME VARCHAR(60),
    COMPANYKEY DFOREIGNKEY,
    ALLHOLDINGCOMPANIES INTEGER,
    CURRKEY DFOREIGNKEY)
RETURNS (
    DEBITSALDO NUMERIC(15, 4),
    CREDITSALDO NUMERIC(15, 4),
    CURRDEBITSALDO NUMERIC(15, 4),
    CURRCREDITSALDO NUMERIC(15, 4),
    EQDEBITSALDO NUMERIC(15, 4),
    EQCREDITSALDO NUMERIC(15, 4))
 AS
   DECLARE VARIABLE SALDO NUMERIC(15, 4);
   DECLARE VARIABLE SALDOCURR NUMERIC(15, 4);
   DECLARE VARIABLE SALDOEQ NUMERIC(15, 4);
   DECLARE VARIABLE TEMPVAR varchar(60);
   DECLARE VARIABLE CLOSEDATE DATE;
   DECLARE VARIABLE CK DFOREIGNKEY;
   DECLARE VARIABLE SQLStatement VARCHAR(2048);
   DECLARE VARIABLE HoldingList VARCHAR(1024) = '';
   DECLARE VARIABLE CurrCondition_E VARCHAR(1024) = '';
   DECLARE VARIABLE CurrCondition_Bal VARCHAR(1024) = '';
 BEGIN
   DEBITSALDO = 0;
   CREDITSALDO = 0;
   CURRDEBITSALDO = 0;
   CURRCREDITSALDO = 0;
   EQDEBITSALDO = 0;
   EQCREDITSALDO = 0;
   CLOSEDATE = CAST((CAST('17.11.1858' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE);

   IF (:AllHoldingCompanies = 1) THEN
   BEGIN
     SELECT LIST(h.companykey, ',')
     FROM gd_holding h
     WHERE h.holdingkey = :companykey
     INTO :HoldingList;
     HoldingList = COALESCE(:HoldingList, '');
   END

   HoldingList = :CompanyKey || IIF(:HoldingList = '', '', ',' || :HoldingList);

   IF (:CurrKey > 0) THEN
   BEGIN
     CurrCondition_E =   ' AND (e.currkey   = ' || :currkey || ') ';
     CurrCondition_Bal = ' AND (bal.currkey = ' || :currkey || ') ';
   END

   IF (:dateend >= :CLOSEDATE) THEN
   BEGIN
     sqlstatement =
       'SELECT
         SUM(main.debitncu - main.creditncu),
         SUM(main.debitcurr - main.creditcurr),
         SUM(main.debiteq - main.crediteq),
         main.companykey
       FROM
       (
         SELECT
           bal.' || FIELDNAME || ',
           bal.debitncu, bal.creditncu,
           bal.debitcurr, bal.creditcurr,
           bal.debiteq, bal.crediteq,
           bal.companykey
         FROM
           ac_entry_balance bal
         WHERE
           bal.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || '
             AND (bal.companykey IN (' || :HoldingList || '))'
            || :CurrCondition_Bal || '

         UNION ALL

         SELECT
           e.' || FIELDNAME || ',
           e.debitncu, e.creditncu,
           e.debitcurr, e.creditcurr,
           e.debiteq, e.crediteq,
           e.companykey
         FROM
           ac_entry e
         WHERE
           e.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || '
           AND e.entrydate >= ''' || CAST(:closedate AS VARCHAR(20)) || '''
           AND e.entrydate < ''' || CAST(:dateend AS VARCHAR(20)) || '''
           AND (e.companykey IN (' || :HoldingList || '))'
          || :CurrCondition_E || '

       ) main
       GROUP BY
         main.' || FIELDNAME || ', main.companykey';
   END
   ELSE
   BEGIN
     sqlstatement =
       'SELECT
         SUM(main.debitncu - main.creditncu),
         SUM(main.debitcurr - main.creditcurr),
         SUM(main.debiteq - main.crediteq),
         main.companykey
       FROM
       (
         SELECT
           bal.' || FIELDNAME || ',
           bal.debitncu, bal.creditncu,
           bal.debitcurr, bal.creditcurr,
           bal.debiteq, bal.crediteq,
           bal.companykey
         FROM
           ac_entry_balance bal
         WHERE
           bal.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || '
             AND (bal.companykey IN (' || :HoldingList || '))'
            || :CurrCondition_Bal || '

         UNION ALL

         SELECT
           e.' || FIELDNAME || ',
          - e.debitncu, - e.creditncu,
          - e.debitcurr, - e.creditcurr,
          - e.debiteq, - e.crediteq,
          e.companykey
         FROM
           ac_entry e
         WHERE
           e.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || '
           AND e.entrydate >= ''' || CAST(:dateend AS VARCHAR(20)) || '''
           AND e.entrydate < ''' || CAST(:closedate AS VARCHAR(20)) || '''
           AND (e.companykey IN (' || :HoldingList || '))'
           || :CurrCondition_E || '
        ) main
       GROUP BY
         main.' || FIELDNAME || ', main.companykey';
   END

   FOR
     EXECUTE STATEMENT
       sqlstatement
     INTO
       :SALDO, :SALDOCURR, :SALDOEQ, :CK
   DO
   BEGIN
     SALDO = COALESCE(:SALDO, 0);
     IF (SALDO > 0) THEN
       DEBITSALDO = DEBITSALDO + SALDO;
     ELSE
       CREDITSALDO = CREDITSALDO - SALDO;
     SALDOCURR = COALESCE(:SALDOCURR, 0);
     IF (SALDOCURR > 0) THEN
       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR;
     ELSE
       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR;
     SALDOEQ = COALESCE(:SALDOEQ, 0);
     IF (SALDOEQ > 0) THEN
       EQDEBITSALDO = EQDEBITSALDO + SALDOEQ;
     ELSE
       EQCREDITSALDO = EQCREDITSALDO - SALDOEQ;
   END
   SUSPEND;
 END
^

/* ��������� ��� �������� ��������� ��������� */
CREATE OR ALTER PROCEDURE AC_CIRCULATIONLIST (
    datebegin date,
    dateend date,
    companykey dforeignkey,
    allholdingcompanies integer,
    accountkey dforeignkey,
    ingroup integer,
    currkey dforeignkey,
    dontinmove integer)
returns (
    alias varchar(20),
    name varchar(180),
    id dforeignkey,
    ncu_begin_debit numeric(15,4),
    ncu_begin_credit numeric(15,4),
    ncu_debit numeric(15,4),
    ncu_credit numeric(15,4),
    ncu_end_debit numeric(15,4),
    ncu_end_credit numeric(15,4),
    curr_begin_debit numeric(15,4),
    curr_begin_credit numeric(15,4),
    curr_debit numeric(15,4),
    curr_credit numeric(15,4),
    curr_end_debit numeric(15,4),
    curr_end_credit numeric(15,4),
    eq_begin_debit numeric(15,4),
    eq_begin_credit numeric(15,4),
    eq_debit numeric(15,4),
    eq_credit numeric(15,4),
    eq_end_debit numeric(15,4),
    eq_end_credit numeric(15,4),
    offbalance integer)
as
  DECLARE VARIABLE ACTIVITY CHAR(1);
  DECLARE VARIABLE SALDO NUMERIC(15,4);
  DECLARE VARIABLE SALDOCURR NUMERIC(15,4);
  DECLARE VARIABLE SALDOEQ NUMERIC(15,4);
  DECLARE VARIABLE FIELDNAME VARCHAR(60);
  DECLARE VARIABLE LB INTEGER;
  DECLARE VARIABLE RB INTEGER;
BEGIN
  SELECT c.lb, c.rb FROM ac_account c
  WHERE c.id = :ACCOUNTKEY
  INTO :lb, :rb;

  FOR
    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance
    FROM ac_account a
      LEFT JOIN  
        (SELECT aa.accountkey, LIST(rf.fieldname, ', ') AS fieldname
          FROM  ac_accanalyticsext aa
            JOIN at_relation_fields rf ON aa.valuekey = rf.id
          GROUP BY aa.accountkey) f
        ON a.id = f.accountkey
    WHERE
      a.accounttype IN ('A', 'S') AND
      a.LB >= :LB AND a.RB <= :RB AND a.alias <> '00'
    INTO :id, :ALIAS, :activity, :fieldname, :name, :offbalance
  DO
  BEGIN
    NCU_BEGIN_DEBIT = 0;
    NCU_BEGIN_CREDIT = 0;
    CURR_BEGIN_DEBIT = 0;
    CURR_BEGIN_CREDIT = 0;
    EQ_BEGIN_DEBIT = 0;
    EQ_BEGIN_CREDIT = 0;

    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN
    BEGIN
      IF ( ALLHOLDINGCOMPANIES = 0) THEN
      SELECT
        SUM(e.DEBITNCU - e.CREDITNCU),
        SUM(e.DEBITCURR - e.CREDITCURR),
        SUM(e.DEBITEQ - e.CREDITEQ)
      FROM
        ac_entry e
      WHERE
        e.accountkey = :id AND e.entrydate < :datebegin AND
        (e.companykey = :companykey) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      INTO :SALDO,
        :SALDOCURR, :SALDOEQ;
      ELSE
      SELECT
        SUM(e.DEBITNCU - e.CREDITNCU),
        SUM(e.DEBITCURR - e.CREDITCURR),
        SUM(e.DEBITEQ - e.CREDITEQ)
      FROM
        ac_entry e
      WHERE
        e.accountkey = :id AND e.entrydate < :datebegin AND
        (e.companykey = :companykey or e.companykey IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey)) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      INTO :SALDO,
        :SALDOCURR, :SALDOEQ;

      IF (SALDO IS NULL) THEN
        SALDO = 0;

      IF (SALDOCURR IS NULL) THEN
        SALDOCURR = 0;

      IF (SALDOEQ IS NULL) THEN
        SALDOEQ = 0;


      IF (SALDO > 0) THEN
        NCU_BEGIN_DEBIT = SALDO;
      ELSE
        NCU_BEGIN_CREDIT = 0 - SALDO;

      IF (SALDOCURR > 0) THEN
        CURR_BEGIN_DEBIT = SALDOCURR;
      ELSE
        CURR_BEGIN_CREDIT = 0 - SALDOCURR;

      IF (SALDOEQ > 0) THEN
        EQ_BEGIN_DEBIT = SALDOEQ;
      ELSE
        EQ_BEGIN_CREDIT = 0 - SALDOEQ;
    END
    ELSE
    BEGIN
      SELECT
        DEBITsaldo,
        creditsaldo
      FROM
        AC_ACCOUNTEXSALDO(:datebegin, :ID, :FIELDNAME, :COMPANYKEY,
          :allholdingcompanies, :INGROUP, :currkey)
      INTO
        :NCU_BEGIN_DEBIT,
        :NCU_BEGIN_CREDIT;
    END

    IF (ALLHOLDINGCOMPANIES = 0) THEN
    BEGIN
      IF (DONTINMOVE = 1) THEN
        SELECT
          SUM(e.DEBITNCU),
          SUM(e.CREDITNCU),
          SUM(e.DEBITCURR),
          SUM(e.CREDITCURR),
          SUM(e.DEBITEQ),
          SUM(e.CREDITEQ)
        FROM
          ac_entry e JOIN ac_transaction tr ON e.transactionkey = tr.id
        WHERE
          e.accountkey = :id AND e.entrydate >= :datebegin AND
          e.entrydate <= :dateend AND (e.companykey = :companykey) AND
          ((0 = :currkey) OR (e.currkey = :currkey)) AND
          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m 
              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND 
               e_cm.accountpart <> e_m.accountpart AND 
               e_cm.accountkey=e_m.accountkey AND 
               (e_m.debitncu=e_cm.creditncu OR 
                e_m.creditncu=e_cm.debitncu OR 
                e_m.debitcurr=e_cm.creditcurr OR 
                e_m.creditcurr=e_cm.debitcurr) 
              WHERE e_m.id=e.id) 
          AND COALESCE(tr.isinternal, 0) = 0
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT;
      ELSE
        SELECT
          SUM(e.DEBITNCU),
          SUM(e.CREDITNCU),
          SUM(e.DEBITCURR),
          SUM(e.CREDITCURR),
          SUM(e.DEBITEQ),
          SUM(e.CREDITEQ)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id AND e.entrydate >= :datebegin AND
          e.entrydate <= :dateend AND (e.companykey = :companykey) AND
          ((0 = :currkey) OR (e.currkey = :currkey))
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT;
    END
    ELSE
    BEGIN
      IF (DONTINMOVE = 1) THEN
        SELECT
          SUM(e.DEBITNCU),
          SUM(e.CREDITNCU),
          SUM(e.DEBITCURR),
          SUM(e.CREDITCURR),
          SUM(e.DEBITEQ),
          SUM(e.CREDITEQ)
        FROM
          ac_entry e JOIN ac_transaction tr ON e.transactionkey = tr.id
        WHERE
          e.accountkey = :id AND e.entrydate >= :datebegin AND
          e.entrydate <= :dateend AND
          (e.companykey = :companykey or e.companykey IN (
          SELECT h.companykey FROM gd_holding h
           WHERE h.holdingkey = :companykey)) AND
          ((0 = :currkey) OR (e.currkey = :currkey)) AND
          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m 
              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND 
               e_cm.accountpart <> e_m.accountpart AND 
               e_cm.accountkey=e_m.accountkey AND 
               (e_m.debitncu=e_cm.creditncu OR 
                e_m.creditncu=e_cm.debitncu OR 
                e_m.debitcurr=e_cm.creditcurr OR 
                e_m.creditcurr=e_cm.debitcurr) 
              WHERE e_m.id=e.id)           
          AND COALESCE(tr.isinternal, 0) = 0
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT;
      ELSE
        SELECT
          SUM(e.DEBITNCU),
          SUM(e.CREDITNCU),
          SUM(e.DEBITCURR),
          SUM(e.CREDITCURR),
          SUM(e.DEBITEQ),
          SUM(e.CREDITEQ)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id AND e.entrydate >= :datebegin AND
          e.entrydate <= :dateend AND
          (e.companykey = :companykey or e.companykey IN (
          SELECT h.companykey FROM gd_holding h
           WHERE h.holdingkey = :companykey)) AND
          ((0 = :currkey) OR (e.currkey = :currkey))
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT;
    END

    IF (NCU_DEBIT IS NULL) THEN
      NCU_DEBIT = 0;

    IF (NCU_CREDIT IS NULL) THEN
      NCU_CREDIT = 0;

    IF (CURR_DEBIT IS NULL) THEN
      CURR_DEBIT = 0;

    IF (CURR_CREDIT IS NULL) THEN
      CURR_CREDIT = 0;

    IF (EQ_DEBIT IS NULL) THEN
      EQ_DEBIT = 0;

    IF (EQ_CREDIT IS NULL) THEN
      EQ_CREDIT = 0;

    NCU_END_DEBIT = 0;
    NCU_END_CREDIT = 0;
    CURR_END_DEBIT = 0;
    CURR_END_CREDIT = 0;
    EQ_END_DEBIT = 0;
    EQ_END_CREDIT = 0;

    IF ((ACTIVITY <> 'B') OR (FIELDNAME IS NULL)) THEN
    BEGIN
      SALDO = NCU_BEGIN_DEBIT - NCU_BEGIN_CREDIT + NCU_DEBIT - NCU_CREDIT;
      IF (SALDO > 0) THEN
        NCU_END_DEBIT = SALDO;
      ELSE
        NCU_END_CREDIT = 0 - SALDO;

      SALDOCURR = CURR_BEGIN_DEBIT - CURR_BEGIN_CREDIT + CURR_DEBIT - CURR_CREDIT;
      IF (SALDOCURR > 0) THEN
        CURR_END_DEBIT = SALDOCURR;
      ELSE
        CURR_END_CREDIT = 0 - SALDOCURR;

      SALDOEQ = EQ_BEGIN_DEBIT - EQ_BEGIN_CREDIT + EQ_DEBIT - EQ_CREDIT;
      IF (SALDOEQ > 0) THEN
        EQ_END_DEBIT = SALDOEQ;
      ELSE
        EQ_END_CREDIT = 0 - SALDOEQ;
    END
    ELSE
    BEGIN
      IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR
        (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR
        (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR
        (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR
        (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR
        (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN
      BEGIN
        SELECT
          DEBITsaldo, creditsaldo,
          CurrDEBITsaldo, Currcreditsaldo,
          EQDEBITsaldo, EQcreditsaldo
        FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY,
          :allholdingcompanies, :INGROUP, :currkey)
        INTO :NCU_END_DEBIT, :NCU_END_CREDIT, :CURR_END_DEBIT, :CURR_END_CREDIT, :EQ_END_DEBIT, :EQ_END_CREDIT;
      END
    END
    IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR
      (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR
      (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR
      (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR
      (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR
      (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN
    SUSPEND;
  END
END
^

/* ��������� ��� �������� ��������� ��������� � ������� ������������ ������ */
CREATE OR ALTER PROCEDURE ac_circulationlist_bal(
  datebegin DATE,
  dateend DATE,
  companykey DFOREIGNKEY,
  allholdingcompanies INTEGER,
  accountkey DFOREIGNKEY,
  currkey DFOREIGNKEY,
  dontinmove INTEGER)
RETURNS (
  alias VARCHAR(20),
  name VARCHAR(180),
  id DFOREIGNKEY,
  ncu_begin_debit NUMERIC(15,4),
  ncu_begin_credit NUMERIC(15,4),
  ncu_debit NUMERIC(15,4),
  ncu_credit NUMERIC(15,4),
  ncu_end_debit NUMERIC(15,4),
  ncu_end_credit NUMERIC(15,4),
  curr_begin_debit NUMERIC(15,4),
  curr_begin_credit NUMERIC(15,4),
  curr_debit NUMERIC(15,4),
  curr_credit NUMERIC(15,4),
  curr_end_debit NUMERIC(15,4),
  curr_end_credit NUMERIC(15,4),
  eq_begin_debit NUMERIC(15,4),
  eq_begin_credit NUMERIC(15,4),
  eq_debit NUMERIC(15,4),
  eq_credit NUMERIC(15,4),
  eq_end_debit NUMERIC(15,4),
  eq_end_credit NUMERIC(15,4),
  offbalance INTEGER)
AS
  DECLARE VARIABLE activity CHAR(1);
  DECLARE VARIABLE saldo NUMERIC(15, 4);
  DECLARE VARIABLE saldocurr NUMERIC(15, 4);
  DECLARE VARIABLE saldoeq NUMERIC(15, 4);
  DECLARE VARIABLE fieldname VARCHAR(60);
  DECLARE VARIABLE lb INTEGER;
  DECLARE VARIABLE rb INTEGER;
  DECLARE VARIABLE closedate DATE;
BEGIN
  closedate = CAST((CAST('17.11.1858' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE);

  SELECT
    c.lb, c.rb
  FROM
    ac_account c
  WHERE
    c.id = :accountkey
  INTO
    :lb, :rb;

  FOR
    SELECT
      a.id, a.alias, a.activity, f.fieldname, a.name, a.offbalance
    FROM
      ac_account a
      LEFT JOIN  
        (SELECT aa.accountkey, LIST(rf.fieldname, ', ') AS fieldname
          FROM  ac_accanalyticsext aa
            JOIN at_relation_fields rf ON aa.valuekey = rf.id
          GROUP BY aa.accountkey) f
        ON a.id = f.accountkey
    WHERE
      a.accounttype IN ('A', 'S')
      AND a.lb >= :lb AND a.rb <= :rb AND a.alias <> '00'
    INTO
      :id, :alias, :activity, :fieldname, :name, :offbalance
  DO
  BEGIN
    ncu_begin_debit = 0;
    ncu_begin_credit = 0;
    curr_begin_debit = 0;
    curr_begin_credit = 0;
    eq_begin_debit = 0;
    eq_begin_credit = 0;

    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN
    BEGIN
      IF (:closedate <= :datebegin) THEN
      BEGIN
        SELECT
          SUM(main.debitncu - main.creditncu),
          SUM(main.debitcurr - main.creditcurr),
          SUM(main.debiteq - main.crediteq)
        FROM
        (
          SELECT
            bal.debitncu,
            bal.creditncu,
            bal.debitcurr,
            bal.creditcurr,
            bal.debiteq,
            bal.crediteq
          FROM
            ac_entry_balance bal
          WHERE
            bal.accountkey = :id
            AND (bal.companykey + 0 = :companykey
              OR (:allholdingcompanies = 1
                AND bal.companykey + 0 IN (
                  SELECT
                    h.companykey
                  FROM
                    gd_holding h
                  WHERE
                    h.holdingkey = :companykey)))
            AND ((0 = :currkey) OR (bal.currkey = :currkey))

          UNION ALL

          SELECT
            e.debitncu,
            e.creditncu,
            e.debitcurr,
            e.creditcurr,
            e.debiteq,
            e.crediteq
          FROM
            ac_entry e
          WHERE
            e.accountkey = :id
            AND e.entrydate >= :closedate
            AND e.entrydate < :datebegin
            AND (e.companykey + 0 = :companykey
              OR (:allholdingcompanies = 1
              AND e.companykey + 0 IN (
                SELECT
                  h.companykey
                FROM
                  gd_holding h
                WHERE
                  h.holdingkey = :companykey)))
            AND ((0 = :currkey) OR (e.currkey = :currkey))
        ) main
        INTO
          :saldo, :saldocurr, :saldoeq;
      END
      ELSE
      BEGIN
        SELECT
          SUM(main.debitncu - main.creditncu),
          SUM(main.debitcurr - main.creditcurr),
          SUM(main.debiteq - main.crediteq)
        FROM
        (
          SELECT
            bal.debitncu,
            bal.creditncu,
            bal.debitcurr,
            bal.creditcurr,
            bal.debiteq,
            bal.crediteq
          FROM
            ac_entry_balance bal
          WHERE
            bal.accountkey = :id
            AND (bal.companykey + 0 = :companykey
              OR (:allholdingcompanies = 1
                AND bal.companykey + 0 IN (
                  SELECT
                    h.companykey
                  FROM
                    gd_holding h
                  WHERE
                    h.holdingkey = :companykey)))
            AND ((0 = :currkey) OR (bal.currkey = :currkey))

          UNION ALL

          SELECT
            - e.debitncu,
            - e.creditncu,
            - e.debitcurr,
            - e.creditcurr,
            - e.debiteq,
            - e.crediteq
          FROM
            ac_entry e
          WHERE
            e.accountkey = :id
            AND e.entrydate >= :datebegin
            AND e.entrydate < :closedate
            AND (e.companykey + 0 = :companykey
              OR (:allholdingcompanies = 1
              AND e.companykey + 0 IN (
                SELECT
                  h.companykey
                FROM
                  gd_holding h
                WHERE
                  h.holdingkey = :companykey)))
            AND ((0 = :currkey) OR (e.currkey = :currkey))
        ) main
        INTO
          :saldo, :saldocurr, :saldoeq;
      END

      IF (saldo IS NULL) THEN
        saldo = 0;
      IF (saldocurr IS NULL) THEN
        saldocurr = 0;
      IF (saldoeq IS NULL) THEN
        saldoeq = 0;

      IF (saldo > 0) THEN
        ncu_begin_debit = saldo;
      ELSE
        ncu_begin_credit = 0 - saldo;
      IF (saldocurr > 0) THEN
        curr_begin_debit = saldocurr;
      ELSE
        curr_begin_credit = 0 - saldocurr;
      IF (saldoeq > 0) THEN
        eq_begin_debit = saldoeq;
      ELSE
         eq_begin_credit = 0 - saldoeq;
    END
    ELSE
    BEGIN
      SELECT
        debitsaldo,
        creditsaldo
      FROM
        ac_accountexsaldo_bal(:datebegin, :id, :fieldname, :companykey, :allholdingcompanies, :currkey)
      INTO
        :ncu_begin_debit,
        :ncu_begin_credit;
    END

    IF (allholdingcompanies = 0) THEN
    BEGIN
      IF (dontinmove = 1) THEN
        SELECT
          SUM(e.debitncu),
          SUM(e.creditncu),
          SUM(e.debitcurr),
          SUM(e.creditcurr),
          SUM(e.debiteq),
          SUM(e.crediteq)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id
          AND e.entrydate >= :datebegin
          AND e.entrydate <= :dateend
          AND e.companykey + 0 = :companykey
          AND ((0 = :currkey) OR (e.currkey = :currkey))
          AND NOT EXISTS (
            SELECT
              e_cm.id
            FROM
              ac_entry e_cm
            WHERE
              e_cm.recordkey = e.recordkey
              AND e_cm.accountpart <> e.accountpart
              AND e_cm.accountkey=e.accountkey
              AND (e.debitncu=e_cm.creditncu
                OR e.creditncu=e_cm.debitncu
                OR e.debitcurr=e_cm.creditcurr
                OR e.creditcurr=e_cm.debitcurr))
        INTO
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit;
      ELSE
        SELECT
          SUM(e.debitncu),
          SUM(e.creditncu),
          SUM(e.debitcurr),
          SUM(e.creditcurr),
          SUM(e.debiteq),
          SUM(e.crediteq)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id
          AND e.entrydate >= :datebegin
          AND e.entrydate <= :dateend
          AND e.companykey + 0 = :companykey
          AND ((0 = :currkey) OR (e.currkey = :currkey))
        INTO
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit;
    END
    ELSE
    BEGIN
      IF (dontinmove = 1) THEN
        SELECT
          SUM(e.debitncu),
          SUM(e.creditncu),
          SUM(e.debitcurr),
          SUM(e.creditcurr),
          SUM(e.debiteq),
          SUM(e.crediteq)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id
          AND e.entrydate >= :datebegin
          AND e.entrydate <= :dateend
          AND (e.companykey + 0 = :companykey
            OR e.companykey + 0 IN (
              SELECT
                h.companykey
              FROM
                gd_holding h
              WHERE
                h.holdingkey = :companykey))
          AND ((0 = :currkey) OR (e.currkey = :currkey))
          AND NOT EXISTS (
            SELECT
              e_cm.id
            FROM
              ac_entry e_cm
            WHERE
              e_cm.recordkey = e.recordkey
              AND e_cm.accountpart <> e.accountpart
              AND e_cm.accountkey=e.accountkey
              AND (e.debitncu=e_cm.creditncu
                OR e.creditncu=e_cm.debitncu
                OR e.debitcurr=e_cm.creditcurr
                OR e.creditcurr=e_cm.debitcurr))
        INTO
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit;
      ELSE
        SELECT
          SUM(e.debitncu),
          SUM(e.creditncu),
          SUM(e.debitcurr),
          SUM(e.creditcurr),
          SUM(e.debiteq),
          SUM(e.crediteq)
        FROM
          ac_entry e
        WHERE
          e.accountkey = :id
          AND e.entrydate >= :datebegin
          AND e.entrydate <= :dateend
          AND (e.companykey + 0 = :companykey
            OR e.companykey + 0 IN (
              SELECT
                h.companykey
              FROM
                gd_holding h
              WHERE
                h.holdingkey = :companykey))
          AND ((0 = :currkey) OR (e.currkey = :currkey))
        INTO
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit;
    END

    IF (ncu_debit IS NULL) THEN
      ncu_debit = 0;
    IF (ncu_credit IS NULL) THEN
      ncu_credit = 0;
    IF (curr_debit IS NULL) THEN
      curr_debit = 0;
    IF (curr_credit IS NULL) THEN
      curr_credit = 0;
    IF (eq_debit IS NULL) THEN
      eq_debit = 0;
    IF (eq_credit IS NULL) THEN
      eq_credit = 0;

    ncu_end_debit = 0;
    ncu_end_credit = 0;
    curr_end_debit = 0;
    curr_end_credit = 0;
    eq_end_debit = 0;
    eq_end_credit = 0;

    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN
    BEGIN
      saldo = ncu_begin_debit - ncu_begin_credit + ncu_debit - ncu_credit;
      IF (saldo > 0) THEN
        ncu_end_debit = saldo;
      ELSE
        ncu_end_credit = 0 - saldo;

      saldocurr = curr_begin_debit - curr_begin_credit + curr_debit - curr_credit;
      IF (saldocurr > 0) THEN
        curr_end_debit = saldocurr;
      ELSE
        curr_end_credit = 0 - saldocurr;

      saldoeq = eq_begin_debit - eq_begin_credit + eq_debit - eq_credit;
      IF (saldoeq > 0) THEN
        eq_end_debit = saldoeq;
      ELSE
        eq_end_credit = 0 - saldoeq;
    END
    ELSE
    BEGIN
      IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR
        (ncu_debit <> 0) OR (ncu_credit <> 0) OR
        (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR
        (curr_debit <> 0) OR (curr_credit <> 0) OR
        (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR
        (eq_debit <> 0) OR (eq_credit <> 0)) THEN
      BEGIN
        SELECT
          debitsaldo, creditsaldo,
          currdebitsaldo, currcreditsaldo,
          eqdebitsaldo, eqcreditsaldo
        FROM
          ac_accountexsaldo_bal(:dateend + 1, :id, :fieldname, :companykey, :allholdingcompanies, :currkey)
        INTO
          :ncu_end_debit, :ncu_end_credit, :curr_end_debit, :curr_end_credit, :eq_end_debit, :eq_end_credit;
      END
    END
    IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR
      (ncu_debit <> 0) OR (ncu_credit <> 0) OR
      (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR
      (curr_debit <> 0) OR (curr_credit <> 0) OR
      (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR
      (eq_debit <> 0) OR (eq_credit <> 0)) THEN
      SUSPEND;
  END
END
^

COMMIT ^

CREATE PROCEDURE AC_GETSIMPLEENTRY (
    ENTRYKEY DFOREIGNKEY,
    ACORRACCOUNTKEY DFOREIGNKEY)
RETURNS (
    ID DFOREIGNKEY,
    DEBIT NUMERIC(15,4),
    CREDIT NUMERIC(15,4),
    DEBITCURR NUMERIC(15,4),
    CREDITCURR NUMERIC(15,4),
    DEBITEQ NUMERIC(15,4),
    CREDITEQ NUMERIC(15,4))
AS
BEGIN
  ID = :ENTRYKEY;
  SELECT
    SUM(iif(corr_e.issimple = 0, corr_e.creditncu, e.debitncu)),
    SUM(iif(corr_e.issimple = 0, corr_e.debitncu, e.creditncu)),
    SUM(iif(corr_e.issimple = 0, corr_e.creditcurr, e.debitcurr)),
    SUM(iif(corr_e.issimple = 0, corr_e.debitcurr, e.creditcurr)),
    SUM(iif(corr_e.issimple = 0, corr_e.crediteq, e.debiteq)),
    SUM(iif(corr_e.issimple = 0, corr_e.debiteq, e.crediteq))
  FROM
    ac_entry e
    JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and
      e.accountpart <> corr_e.accountpart
  WHERE
    e.id = :entrykey AND
    corr_e.accountkey + 0 = :acorraccountkey
  INTO :DEBIT,
       :CREDIT,
       :DEBITCURR,
       :CREDITCURR,
       :DEBITEQ,
       :CREDITEQ;
  SUSPEND;
END
^

SET TERM ; ^

COMMIT;

/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/

CREATE TABLE AC_AUTOTRRECORD (
    ID                DINTKEY,
    SHOWINEXPLORER    DBOOLEAN,
    IMAGEINDEX        DINTEGER,
    FOLDERKEY         DFOREIGNKEY
);

ALTER TABLE AC_AUTOTRRECORD ADD
  PRIMARY KEY (ID);
ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD_FOLDER
  FOREIGN KEY (FOLDERKEY) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL
  ON UPDATE SET NULL;
ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD_ID
  FOREIGN KEY (ID) REFERENCES AC_TRRECORD (ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE AC_AUTOENTRY (
    ID             DINTKEY NOT NULL,
    ENTRYKEY       DINTKEY NOT NULL,
    TRRECORDKEY    DINTKEY NOT NULL,
    BEGINDATE      DDATE_NOTNULL NOT NULL,
    ENDDATE        DDATE_NOTNULL NOT NULL,
    CREDITACCOUNT  DINTKEY NOT NULL,
    DEBITACCOUNT   DINTKEY NOT NULL,
    EDITIONDATE    DEDITIONDATE
);

ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT PK_AC_AUTOENTRY
  PRIMARY KEY (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_CREDIT
  FOREIGN KEY (CREDITACCOUNT) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_DEBIT
  FOREIGN KEY (DEBITACCOUNT) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_ENTRYKEY
  FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE ;
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_TRRECORDKEY
  FOREIGN KEY (TRRECORDKEY) REFERENCES AC_TRRECORD (ID) ON DELETE CASCADE ON UPDATE CASCADE ;

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER ac_bi_autoentry FOR ac_autoentry
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN  
  IF (NEW.id IS NULL) THEN
    EXECUTE PROCEDURE gd_p_getnextid_ex
      RETURNING_VALUES NEW.id;  
END
^  

SET TERM ; ^
  
/*������� ��� �������� �������� ������� �����*/

CREATE TABLE AC_GENERALLEDGER (
    ID             DINTKEY NOT NULL,
    NAME           DNAME NOT NULL COLLATE PXW_CYRL,
    DEFAULTUSE     DBOOLEAN,
    INNCU          DBOOLEAN,
    INCURR         DBOOLEAN,
    NCUDECDIGITS   DINTEGER_NOTNULL,
    NCUSCALE       DINTEGER_NOTNULL,
    CURRDECDIGITS  DINTEGER_NOTNULL NOT NULL,
    CURRSCALE      DINTEGER_NOTNULL NOT NULL,
    CURRKEY        DFOREIGNKEY,
    ACCOUNTKEY     DFOREIGNKEY,
    ENHANCEDSALDO  DBOOLEAN,
    EDITIONDATE    DEDITIONDATE
);

ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT PK_AC_GENERALLEDGER
  PRIMARY KEY (ID);
ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_ACKEY
  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_CURRKEY
  FOREIGN KEY (CURRKEY) REFERENCES GD_CURR (ID);

CREATE UNIQUE INDEX ac_x_generalledger_name ON ac_generalledger
  (name);

COMMIT;

/*������� ��� �������� ������ ��������� ������� ����� � ������*/
CREATE TABLE AC_G_LEDGERACCOUNT (
    LEDGERKEY   DFOREIGNKEY NOT NULL,
    ACCOUNTKEY  DFOREIGNKEY NOT NULL
);

ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT PK_AC_G_LEDGERACCOUNT PRIMARY KEY (LEDGERKEY, ACCOUNTKEY);
ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_AKEY FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_LKEY FOREIGN KEY (LEDGERKEY) REFERENCES AC_GENERALLEDGER (ID);
/* Privileges of roles */


COMMIT;

CREATE TABLE AC_ACCT_CONFIG (
    ID              DINTKEY,
    NAME            DTEXT32 NOT NULL,
    CLASSNAME       DTEXT60 NOT NULL,
    CONFIG          DBLOB,
    SHOWINEXPLORER  DBOOLEAN,
    FOLDER          DFOREIGNKEY,
    IMAGEINDEX      DINTEGER,
    EDITIONDATE     DEDITIONDATE
);

ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT PK_AC_ACCT_CONFIG_ID PRIMARY KEY (ID);
ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT FK_AC_ACCT_CONFIG_FOLDER
  FOREIGN KEY (FOLDER) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

COMMIT;


/****************************************************

  ������� ������ ����� � ��.���������

*****************************************************/

CREATE TABLE ac_accvalue
(
  id          dintkey  PRIMARY KEY,
  accountkey  dmasterkey,
  valuekey    dintkey
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_accvalue
  ON ac_accvalue (accountkey, valuekey);

COMMIT;

ALTER TABLE ac_accvalue ADD CONSTRAINT fk_ac_accvalue_account
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_accvalue ADD CONSTRAINT fk_ac_accvalue_value
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

  ������� �������������� ����������� ��������

*****************************************************/

CREATE TABLE ac_quantity
(
  id          dintkey,
  entrykey    dmasterkey,
  valuekey    dintkey,
  quantity    dcurrency,
  
  CONSTRAINT ac_pk_quantity PRIMARY KEY (id) 
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_quantity
  ON ac_quantity (entrykey, valuekey);

COMMIT;

ALTER TABLE ac_quantity ADD CONSTRAINT fk_ac_quantity_entry
  FOREIGN KEY (entrykey) REFERENCES ac_entry(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_quantity ADD CONSTRAINT fk_ac_quantity_accvalue
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE AC_LEDGER_ACCOUNTS (
    ACCOUNTKEY  DFOREIGNKEY NOT NULL,
    SQLHANDLE   DINTEGER_NOTNULL NOT NULL
);

COMMIT;

ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT PK_AC_LEDGER_ACCOUNTS
  PRIMARY KEY (ACCOUNTKEY, SQLHANDLE);

ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT FK_AC_LEDGER_ACCOUNTS
  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE TABLE AC_LEDGER_ENTRIES (
    ENTRYKEY   DINTKEY NOT NULL,
    SQLHANDLE  DINTKEY NOT NULL
);

COMMIT;

ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT PK_AC_LEDGER_ENTRIES
  PRIMARY KEY (SQLHANDLE, ENTRYKEY);

ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT FK_AC_LEDGER_ENTRIES
  FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^;

CREATE PROCEDURE AC_L_S (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer)
returns (
    entrydate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldobegin dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegincurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable saldobegineq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN
  IF (:SQLHANDLE = 0) THEN
  BEGIN
    SELECT
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0),
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0)
    FROM
      ac_entry e1
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey  + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND
      e1.entrydate < :abeginentrydate
    INTO :saldobegin,
         :saldobegincurr,
         :saldobegineq;

    IF (saldobegin IS NULL) THEN
      saldobegin = 0;
    IF (saldobegincurr IS NULL) THEN
      saldobegincurr = 0;
    IF (saldobegineq IS NULL) THEN
      saldobegineq = 0;

    C = 0;
    FORCESHOW = 0;
    FOR
      SELECT
        e.entrydate,
        SUM(e.debitncu - e.creditncu),
        SUM(e.debitcurr - e.creditcurr),
        SUM(e.debiteq - e.crediteq)
      FROM
        ac_entry e
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey)) AND
         e.entrydate <= :aendentrydate AND
        e.entrydate >= :abeginentrydate

      GROUP BY e.entrydate
      INTO :ENTRYDATE,
           :O,
           :OCURR,
           :OEQ
    DO
    BEGIN
      DEBITNCUBEGIN = 0;
      CREDITNCUBEGIN = 0;
      DEBITNCUEND = 0;
      CREDITNCUEND = 0;
      DEBITCURRBEGIN = 0;
      CREDITCURRBEGIN = 0;
      DEBITCURREND = 0;
      CREDITCURREND = 0;
      DEBITEQBEGIN = 0;
      CREDITEQBEGIN = 0;
      DEBITEQEND = 0;
      CREDITEQEND = 0;
      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITNCUBEGIN = :SALDOBEGIN;
      else
        CREDITNCUBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITNCUEND = :SALDOEND;
      else
        CREDITNCUEND =  - :SALDOEND;
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
      if (SALDOBEGINCURR > 0) then
        DEBITCURRBEGIN = :SALDOBEGINCURR;
      else
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      if (SALDOENDCURR > 0) then
        DEBITCURREND = :SALDOENDCURR;
      else
        CREDITCURREND =  - :SALDOENDCURR;
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
      if (SALDOBEGINEQ > 0) then
        DEBITEQBEGIN = :SALDOBEGINEQ;
      else
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
      if (SALDOENDEQ > 0) then
        DEBITEQEND = :SALDOENDEQ;
      else
        CREDITEQEND =  - :SALDOENDEQ;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      SALDOBEGINCURR = :SALDOENDCURR;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      ENTRYDATE = :abeginentrydate;
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITNCUBEGIN = :SALDOBEGIN;
        DEBITNCUEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITNCUBEGIN =  - :SALDOBEGIN;
        CREDITNCUEND =  - :SALDOBEGIN;
      END

      IF (SALDOBEGINCURR > 0) THEN
      BEGIN
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR;
      END ELSE
      BEGIN
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
        CREDITCURREND =  - :SALDOBEGINCURR;
      END

      IF (SALDOBEGINEQ > 0) THEN
      BEGIN
        DEBITEQBEGIN = :SALDOBEGINEQ;
        DEBITEQEND = :SALDOBEGINEQ;
      END ELSE
      BEGIN
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
        CREDITEQEND =  - :SALDOBEGINEQ;
      END

      FORCESHOW = 1;
      SUSPEND;
    END
  END
  ELSE
  BEGIN
    SELECT
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0),
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0)
    FROM
      ac_ledger_accounts a JOIN
      ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate
      AND a.sqlhandle = :sqlhandle
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey  + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin,
         :saldobegincurr,
         :saldobegineq;

    IF (saldobegin IS NULL) THEN
      saldobegin = 0;
    IF (saldobegincurr IS NULL) THEN
      saldobegincurr = 0;
    IF (saldobegineq IS NULL) THEN
      saldobegineq = 0;

    C = 0;
    FORCESHOW = 0;
    FOR
      SELECT
        e.entrydate,
        SUM(e.debitncu - e.creditncu),
        SUM(e.debitcurr - e.creditcurr),
        SUM(e.debiteq - e.crediteq)
      FROM
        ac_ledger_accounts a
        JOIN ac_entry e ON a.accountkey = e.accountkey AND
            e.entrydate <= :aendentrydate AND
            e.entrydate >= :abeginentrydate
            AND a.sqlhandle = :sqlhandle
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      GROUP BY e.entrydate
      INTO :ENTRYDATE,
           :O,
           :OCURR,
           :OEQ
    DO
    BEGIN
      DEBITNCUBEGIN = 0;
      CREDITNCUBEGIN = 0;
      DEBITNCUEND = 0;
      CREDITNCUEND = 0;
      DEBITCURRBEGIN = 0;
      CREDITCURRBEGIN = 0;
      DEBITCURREND = 0;
      CREDITCURREND = 0;
      DEBITEQBEGIN = 0;
      CREDITEQBEGIN = 0;
      DEBITEQEND = 0;
      CREDITEQEND = 0;
      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITNCUBEGIN = :SALDOBEGIN;
      else
        CREDITNCUBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITNCUEND = :SALDOEND;
      else
        CREDITNCUEND =  - :SALDOEND;
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
      if (SALDOBEGINCURR > 0) then
        DEBITCURRBEGIN = :SALDOBEGINCURR;
      else
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      if (SALDOENDCURR > 0) then
        DEBITCURREND = :SALDOENDCURR;
      else
        CREDITCURREND =  - :SALDOENDCURR;
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
      if (SALDOBEGINEQ > 0) then
        DEBITEQBEGIN = :SALDOBEGINEQ;
      else
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
      if (SALDOENDEQ > 0) then
        DEBITEQEND = :SALDOENDEQ;
      else
        CREDITEQEND =  - :SALDOENDEQ;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      SALDOBEGINCURR = :SALDOENDCURR;
      SALDOBEGINEQ = :SALDOENDEQ;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      ENTRYDATE = :abeginentrydate;
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITNCUBEGIN = :SALDOBEGIN;
        DEBITNCUEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITNCUBEGIN =  - :SALDOBEGIN;
        CREDITNCUEND =  - :SALDOBEGIN;
      END

      IF (SALDOBEGINCURR > 0) THEN
      BEGIN
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR;
      END ELSE
      BEGIN
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
        CREDITCURREND =  - :SALDOBEGINCURR;
      END

      IF (SALDOBEGINEQ > 0) THEN
      BEGIN
        DEBITEQBEGIN = :SALDOBEGINEQ;
        DEBITEQEND = :SALDOBEGINEQ;
      END ELSE
      BEGIN
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
        CREDITEQEND =  - :SALDOBEGINEQ;
      END

      FORCESHOW = 1;
      SUSPEND;
    END
  END
END^

COMMIT ^

CREATE PROCEDURE AC_L_S1 (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldobegin dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable saldobegincurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegineq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN
  IF (:SQLHANDLE = 0) THEN
  BEGIN
    SELECT
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0),
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0)
    FROM
      ac_entry e1
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND
      e1.entrydate < :abeginentrydate
    INTO :saldobegin,
         :saldobegincurr,
         :saldobegineq;
    if (saldobegin IS NULL) then
      saldobegin = 0;
    if (saldobegincurr IS NULL) then
      saldobegincurr = 0;
    if (saldobegineq IS NULL) then
      saldobegineq = 0;

    C = 0;
    FORCESHOW = 0;
    FOR
      SELECT
        SUM(e.debitncu - e.creditncu),
        SUM(e.debitcurr - e.creditcurr),
        SUM(e.debiteq - e.crediteq),
        g_d_getdateparam(e.entrydate, :param)
      FROM
        ac_entry e
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey)) AND
          e.entrydate <= :aendentrydate AND
          e.entrydate >= :abeginentrydate
      group by 4
      INTO :O,
           :OCURR,
           :OEQ,
           :dateparam
    DO
    BEGIN
      DEBITNCUBEGIN = 0;
      CREDITNCUBEGIN = 0;
      DEBITNCUEND = 0;
      CREDITNCUEND = 0;
      DEBITCURRBEGIN = 0;
      CREDITCURRBEGIN = 0;
      DEBITCURREND = 0;
      CREDITCURREND = 0;
      DEBITEQBEGIN = 0;
      CREDITEQBEGIN = 0;
      DEBITEQEND = 0;
      CREDITEQEND = 0;
      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITNCUBEGIN = :SALDOBEGIN;
      else
        CREDITNCUBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITNCUEND = :SALDOEND;
      else
        CREDITNCUEND =  - :SALDOEND;
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
      if (SALDOBEGINCURR > 0) then
        DEBITCURRBEGIN = :SALDOBEGINCURR;
      else
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      if (SALDOENDCURR > 0) then
        DEBITCURREND = :SALDOENDCURR;
      else
        CREDITCURREND =  - :SALDOENDCURR;
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
      if (SALDOBEGINEQ > 0) then
        DEBITEQBEGIN = :SALDOBEGINEQ;
      else
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
      if (SALDOENDEQ > 0) then
        DEBITEQEND = :SALDOENDEQ;
      else
        CREDITEQEND =  - :SALDOENDEQ;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      SALDOBEGINCURR = :SALDOENDCURR;
      SALDOBEGINEQ = :SALDOENDEQ;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITNCUBEGIN = :SALDOBEGIN;
        DEBITNCUEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITNCUBEGIN =  - :SALDOBEGIN;
        CREDITNCUEND =  - :SALDOBEGIN;
      END

      IF (SALDOBEGINCURR > 0) THEN
      BEGIN
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR;
      END ELSE
      BEGIN
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
        CREDITCURREND =  - :SALDOBEGINCURR;
      END

      IF (SALDOBEGINEQ > 0) THEN
      BEGIN
        DEBITEQBEGIN = :SALDOBEGINEQ;
        DEBITEQEND = :SALDOBEGINEQ;
      END ELSE
      BEGIN
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
        CREDITEQEND =  - :SALDOBEGINEQ;
      END

      FORCESHOW = 1;
      SUSPEND;
    END
  END
  ELSE
  BEGIN
    SELECT
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0),
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0),
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0)
    FROM
      ac_ledger_accounts a
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate
      AND a.sqlhandle = :sqlhandle
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin,
         :saldobegincurr,
         :saldobegineq;
    if (saldobegin IS NULL) then
      saldobegin = 0;
    if (saldobegincurr IS NULL) then
      saldobegincurr = 0;
    if (saldobegineq IS NULL) then
      saldobegineq = 0;

    C = 0;
    FORCESHOW = 0;
    FOR
      SELECT
        SUM(e.debitncu - e.creditncu),
        SUM(e.debitcurr - e.creditcurr),
        SUM(e.debiteq - e.crediteq),
        g_d_getdateparam(e.entrydate, :param)
      FROM
        ac_ledger_accounts a
        JOIN ac_entry e ON a.accountkey = e.accountkey AND
             e.entrydate <= :aendentrydate AND
             e.entrydate >= :abeginentrydate
      AND a.sqlhandle = :sqlhandle
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      group by 4
      INTO :O,
           :OCURR,
           :OEQ,
           :dateparam
    DO
    BEGIN
      DEBITNCUBEGIN = 0;
      CREDITNCUBEGIN = 0;
      DEBITNCUEND = 0;
      CREDITNCUEND = 0;
      DEBITCURRBEGIN = 0;
      CREDITCURRBEGIN = 0;
      DEBITCURREND = 0;
      CREDITCURREND = 0;
      DEBITEQBEGIN = 0;
      CREDITEQBEGIN = 0;
      DEBITEQEND = 0;
      CREDITEQEND = 0;
      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITNCUBEGIN = :SALDOBEGIN;
      else
        CREDITNCUBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITNCUEND = :SALDOEND;
      else
        CREDITNCUEND =  - :SALDOEND;
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
      if (SALDOBEGINCURR > 0) then
        DEBITCURRBEGIN = :SALDOBEGINCURR;
      else
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      if (SALDOENDCURR > 0) then
        DEBITCURREND = :SALDOENDCURR;
      else
        CREDITCURREND =  - :SALDOENDCURR;
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
      if (SALDOBEGINEQ > 0) then
        DEBITEQBEGIN = :SALDOBEGINEQ;
      else
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
      if (SALDOENDEQ > 0) then
        DEBITEQEND = :SALDOENDEQ;
      else
        CREDITEQEND =  - :SALDOENDEQ;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      SALDOBEGINCURR = :SALDOENDCURR;
      SALDOBEGINEQ = :SALDOENDEQ;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITNCUBEGIN = :SALDOBEGIN;
        DEBITNCUEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITNCUBEGIN =  - :SALDOBEGIN;
        CREDITNCUEND =  - :SALDOBEGIN;
      END

      IF (SALDOBEGINCURR > 0) THEN
      BEGIN
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR;
      END ELSE
      BEGIN
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
        CREDITCURREND =  - :SALDOBEGINCURR;
      END

      IF (SALDOBEGINEQ > 0) THEN
      BEGIN
        DEBITEQBEGIN = :SALDOBEGINEQ;
        DEBITEQEND = :SALDOBEGINEQ;
      END ELSE
      BEGIN
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
        CREDITEQEND =  - :SALDOBEGINEQ;
      END

      FORCESHOW = 1;

      SUSPEND;
    END

  END
END^

COMMIT^

CREATE PROCEDURE AC_Q_S (
    valuekey integer,
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer)
returns (
    entrydate date,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN
  IF (:sqlhandle = 0) THEN
  BEGIN
    SELECT
      IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
        SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0)
    FROM
      ac_entry e1
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND
      e1.entrydate < :abeginentrydate
    INTO :saldobegin;
    if (saldobegin IS NULL) then
      saldobegin = 0;

    C = 0;
    FOR
      SELECT
        e.entrydate,
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_entry e
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND
          q.valuekey = :valuekey
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey)) AND
          e.entrydate <= :aendentrydate AND
          e.entrydate >= :abeginentrydate
      GROUP BY e.entrydate
      INTO :ENTRYDATE,
           :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
      CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END

    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      ENTRYDATE = :abeginentrydate;
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
      SUSPEND;
    END

  END
  ELSE
  BEGIN

    SELECT
      IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
        SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0)
    FROM
      ac_ledger_accounts a
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND
        e1.entrydate < :abeginentrydate
      AND a.sqlhandle = :sqlhandle
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin;
    if (saldobegin IS NULL) then
      saldobegin = 0;

    C = 0;
    FOR
      SELECT
        e.entrydate,
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_ledger_accounts a
        JOIN ac_entry e ON a.accountkey = e.accountkey AND
          e.entrydate <= :aendentrydate AND
          e.entrydate >= :abeginentrydate
          AND a.sqlhandle = :sqlhandle
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND
          q.valuekey = :valuekey
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      GROUP BY e.entrydate
      INTO :ENTRYDATE,
           :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
      CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      ENTRYDATE = :abeginentrydate;
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
      SUSPEND;
    END

  END
END^


COMMIT ^

CREATE PROCEDURE AC_L_Q (
    ENTRYKEY INTEGER,
    VALUEKEY INTEGER,
    ACCOUNTKEY INTEGER,
    AACCOUNTPART CHAR(1))
RETURNS (
    DEBITQUANTITY NUMERIC(15,4),
    CREDITQUANTITY NUMERIC(15,4))
AS
DECLARE VARIABLE ACCOUNTPART CHAR(1);
DECLARE VARIABLE QUANTITY NUMERIC(15,4);
begin
  SELECT
    e.accountpart,
    q.quantity
  FROM
    ac_entry e
    LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND
      e1.accountpart <> e.accountpart
    LEFT JOIN ac_quantity q ON q.entrykey = iif(e.issimple = 1 and e1.issimple = 1,
      e.id, iif(e.issimple = 0, e.id, e1.id))
  WHERE
    e.id = :entrykey AND
    q.valuekey = :valuekey AND
    e1.accountkey = :accountkey
  INTO
    :accountpart,
    :quantity;
  IF (quantity IS NULL) THEN
    quantity = 0;

  debitquantity = 0;
  creditquantity = 0;
  IF (accountpart = 'D') THEN
    debitquantity = :quantity;
  ELSE
    creditquantity = :quantity;

  suspend;
END^


CREATE PROCEDURE AC_Q_S1 (
    valuekey integer,
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN
  IF (:sqlhandle = 0) THEN
  BEGIN
    SALDOBEGIN = 0;
    SELECT
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0))
    FROM
      ac_entry e1
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      e1.entrydate < :abeginentrydate AND
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin;

    if (SALDOBEGIN IS NULL) THEN
      SALDOBEGIN = 0;

    C = 0;
    FOR
      SELECT
        g_d_getdateparam(e.entrydate, :param),
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_entry e
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey
      WHERE
        e.entrydate <= :aendentrydate AND
        e.entrydate >= :abeginentrydate AND
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      GROUP BY 1
      INTO :dateparam,
           :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
      CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
      SUSPEND;
    END
  END
  ELSE
  BEGIN

    SALDOBEGIN = 0;
    SELECT
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0))
    FROM
      ac_ledger_accounts a
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND
        e1.entrydate < :abeginentrydate
        AND a.sqlhandle = :sqlhandle
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin;

    if (SALDOBEGIN IS NULL) THEN
      SALDOBEGIN = 0;

    C = 0;
    FOR
      SELECT
        g_d_getdateparam(e.entrydate, :param),
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_ledger_accounts a
        JOIN ac_entry e ON a.accountkey = e.accountkey AND
          e.entrydate <= :aendentrydate AND
          e.entrydate >= :abeginentrydate
          AND a.sqlhandle = :sqlhandle
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey
      WHERE
        (e.companykey + 0 = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        e.companykey + 0 IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      GROUP BY 1
      INTO :dateparam,
           :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
      CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SUSPEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
      SUSPEND;
    END

  END
END^

CREATE PROCEDURE AC_Q_G_L (
    valuekey integer,
    datebegin date,
    dateend date,
    companykey integer,
    allholdingcompanies integer,
    sqlhandle integer,
    ingroup integer,
    currkey integer)
returns (
    m integer,
    y integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
begin
  SELECT
    IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0)
  FROM
      ac_entry e1
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
  WHERE
    e1.entrydate < :datebegin AND
    e1.accountkey IN (
      SELECT
        a.accountkey
      FROM
        ac_ledger_accounts a
      WHERE
        a.sqlhandle = :sqlhandle) AND
    (e1.companykey = :companykey OR
    (:ALLHOLDINGCOMPANIES = 1 AND
    e1.companykey IN (
      SELECT
        h.companykey
      FROM
        gd_holding h
      WHERE
        h.holdingkey = :companykey))) AND
    q.valuekey = :valuekey AND
    ((0 = :currkey) OR (e1.currkey = :currkey))
  INTO :saldobegin;
  if (saldobegin IS NULL) then
    saldobegin = 0;

  C = 0;
  FOR
    SELECT
      EXTRACT(MONTH FROM e.entrydate),
      EXTRACT(YEAR FROM e.entrydate),
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e.accountpart = 'C', q.quantity, 0))
    FROM
      ac_entry e
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND
        q.valuekey = :valuekey
    WHERE
      e.entrydate <= :dateend AND
      e.entrydate >= :datebegin AND
      e.accountkey IN (
        SELECT
          a.accountkey
        FROM
          ac_ledger_accounts a
        WHERE
          a.sqlhandle = :sqlhandle
      ) AND
      (e.companykey = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e.companykey IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    GROUP BY 1, 2
    ORDER BY 2, 1
    INTO :M, :Y, :O
  DO
  BEGIN
    IF (O IS NULL) THEN O = 0;
    DEBITBEGIN = 0;
    CREDITBEGIN = 0;
    DEBITEND = 0;
    CREDITEND = 0;
    DEBIT = 0;
    CREDIT = 0;
    IF (O > 0) THEN
      DEBIT = :O;
    ELSE
      CREDIT = - :O;

    SALDOEND = :SALDOBEGIN + :O;
    if (SALDOBEGIN > 0) then
      DEBITBEGIN = :SALDOBEGIN;
    else
      CREDITBEGIN =  - :SALDOBEGIN;
    if (SALDOEND > 0) then
      DEBITEND = :SALDOEND;
    else
      CREDITEND =  - :SALDOEND;
    SALDOBEGIN = :SALDOEND;
    C = C + 1;
    SUSPEND;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    M = EXTRACT(MONTH FROM :datebegin);
    Y = EXTRACT(YEAR FROM :datebegin);
    IF (SALDOBEGIN > 0) THEN
    BEGIN
      DEBITBEGIN = :SALDOBEGIN;
      DEBITEND = :SALDOBEGIN;
    END ELSE
    BEGIN
      CREDITBEGIN =  - :SALDOBEGIN;
      CREDITEND =  - :SALDOBEGIN;
    END
    DEBIT = 0;
    CREDIT = 0;
    SUSPEND;
  END
END^

CREATE PROCEDURE AC_G_L_S (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer,
    analyticfield varchar(60))
returns (
    m integer,
    y integer,
    begindate date,
    enddate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin dcurrency,
    crediteqbegin dcurrency,
    debiteqend dcurrency,
    crediteqend dcurrency,
    forceshow integer)
as
declare variable o dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegindebit dcurrency;
declare variable saldobegincredit dcurrency;
declare variable saldoenddebit dcurrency;
declare variable saldoendcredit dcurrency;
declare variable saldobegindebitcurr dcurrency;
declare variable saldobegincreditcurr dcurrency;
declare variable saldoenddebitcurr dcurrency;
declare variable saldoendcreditcurr dcurrency;
declare variable saldobegindebiteq dcurrency;
declare variable saldobegincrediteq dcurrency;
declare variable saldoenddebiteq dcurrency;
declare variable saldoendcrediteq dcurrency;
declare variable sd dcurrency;
declare variable sc dcurrency;
declare variable sdc dcurrency;
declare variable scc dcurrency;
declare variable sdeq dcurrency;
declare variable sceq dcurrency;
declare variable c integer;
declare variable accountkey integer;
declare variable d date;
declare variable dayinmonth integer;
BEGIN
  saldobegindebit = 0;
  saldobegincredit = 0;
  saldobegindebitcurr = 0;
  saldobegincreditcurr = 0;

  IF (ANALYTICFIELD = '') THEN
  BEGIN
    SELECT
      IIF((NOT SUM(e1.debitncu - e1.creditncu) IS NULL) AND
        (SUM(e1.debitncu - e1.creditncu) > 0), SUM(e1.debitncu - e1.creditncu),  0),
      IIF((NOT SUM(e1.creditncu - e1.debitncu) IS NULL) AND
        (SUM(e1.creditncu - e1.debitncu) > 0), SUM(e1.creditncu - e1.debitncu),  0),
      IIF((NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL) AND
        (SUM(e1.debitcurr - e1.creditcurr) > 0), SUM(e1.debitcurr - e1.creditcurr),  0),
      IIF((NOT SUM(e1.creditcurr - e1.debitcurr) IS NULL) AND
        (SUM(e1.creditcurr - e1.debitcurr) > 0), SUM(e1.creditcurr - e1.debitcurr),  0),
      IIF((NOT SUM(e1.debiteq - e1.crediteq) IS NULL) AND
        (SUM(e1.debiteq - e1.crediteq) > 0), SUM(e1.debiteq - e1.crediteq),  0),
      IIF((NOT SUM(e1.crediteq - e1.debiteq) IS NULL) AND
        (SUM(e1.crediteq - e1.debiteq) > 0), SUM(e1.crediteq - e1.debiteq),  0)
    FROM
      ac_ledger_accounts a
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate
        AND a.sqlhandle = :sqlhandle
    WHERE
      (e1.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegindebit,
         :saldobegincredit,
         :saldobegindebitcurr,
         :saldobegincreditcurr,
         :saldobegindebiteq,
         :saldobegincrediteq;
  END ELSE
  BEGIN
    FOR
      SELECT
        la.accountkey
      FROM
        ac_ledger_accounts la
      WHERE
        la.sqlhandle = :sqlhandle
      INTO :accountkey
    DO
    BEGIN
      SELECT
        a.DEBITSALDO,
        a.CREDITSALDO,
        a.CURRDEBITSALDO,
        a.CURRCREDITSALDO,
        a.EQDEBITSALDO,
        a.EQCREDITSALDO
      FROM
        ac_accountexsaldo(:abeginentrydate, :accountkey, :analyticfield, :companykey,
          :allholdingcompanies, -1, :currkey) a
      INTO :sd,
           :sc,
           :sdc,
           :scc,
           :sdeq,
           :sceq;

      IF (sd IS NULL) then SD = 0;
      IF (sc IS NULL) then SC = 0;
      IF (sdc IS NULL) then SDC = 0;
      IF (scc IS NULL) then SCC = 0;

      saldobegindebit = :saldobegindebit + :sd;
      saldobegincredit = :saldobegincredit + :sc;
      saldobegindebitcurr = :saldobegindebitcurr + :sdc;
      saldobegincreditcurr = :saldobegincreditcurr + :scc;
      saldobegindebiteq = :saldobegindebiteq + :sdeq;
      saldobegincrediteq = :saldobegincrediteq + :sceq;
    END
  END

  C = 0;
  FORCESHOW = 0;
  FOR
    SELECT
      SUM(e.debitncu - e.creditncu),
      SUM(e.debitcurr - e.creditcurr),
      SUM(e.debiteq - e.crediteq),
      EXTRACT(MONTH FROM e.entrydate),
      EXTRACT(YEAR FROM e.entrydate)
    FROM
      ac_ledger_accounts a
      JOIN ac_entry e ON a.accountkey = e.accountkey AND
           e.entrydate <= :aendentrydate AND
           e.entrydate >= :abeginentrydate
    AND a.sqlhandle = :sqlhandle
    WHERE
      (e.companykey + 0 = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      e.companykey + 0 IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    group by 4, 5
    ORDER BY 5, 4
    INTO :O, :OCURR, :OEQ, :M, :Y
  DO
  BEGIN
    begindate = CAST(:Y || '-' || :M || '-' || 1 as DATE);
    IF (begindate < :abeginentrydate) THEN
    BEGIN
      begindate = :abeginentrydate;
    END

    DAYINMONTH = EXTRACT(DAY FROM g_d_incmonth(1, CAST(:Y || '-' || :M || '-' || 1 as DATE)) - 1);

    D = CAST(:Y || '-' || :M || '-' || :dayinmonth as DATE);

    IF (D > :aendentrydate) THEN
    BEGIN
      D = :aendentrydate;
    END
    ENDDATE = D;
    DEBITNCUBEGIN = 0;
    CREDITNCUBEGIN = 0;
    DEBITNCUEND = 0;
    CREDITNCUEND = 0;
    DEBITCURRBEGIN = 0;
    CREDITCURRBEGIN = 0;
    DEBITCURREND = 0;
    CREDITCURREND = 0;
    DEBITEQBEGIN = 0;
    CREDITEQBEGIN = 0;
    DEBITEQEND = 0;
    CREDITEQEND = 0;
    IF (analyticfield = '') THEN
    BEGIN
      IF (:saldobegindebit - :saldobegincredit + :o > 0) THEN
      BEGIN
        SALDOENDDEBIT = :saldobegindebit - :saldobegincredit + :o;
        SALDOENDCREDIT = 0;
      END ELSE
      BEGIN
        SALDOENDDEBIT = 0;
        SALDOENDCREDIT =  - (:saldobegindebit - :saldobegincredit + :o);
      END

      IF (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr > 0) THEN
      BEGIN
        SALDOENDDEBITCURR = :saldobegindebitCURR - :saldobegincreditCURR + :ocurr;
        SALDOENDCREDITCURR = 0;
      END ELSE
      BEGIN
        SALDOENDDEBITCURR = 0;
        SALDOENDCREDITCURR =  - (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr);
      END

      IF (:saldobegindebiteq - :saldobegincrediteq + :oeq > 0) THEN
      BEGIN
        SALDOENDDEBITEQ = :saldobegindebiteq - :saldobegincrediteq + :oeq;
        SALDOENDCREDITEQ = 0;
      END ELSE
      BEGIN
        SALDOENDDEBITEQ = 0;
        SALDOENDCREDITEQ =  - (:saldobegindebiteq - :saldobegincrediteq + :oeq);
      END
    END ELSE
    BEGIN
      saldoenddebit = 0;
      saldoendcredit = 0;
      saldoenddebitcurr = 0;
      saldoendcreditcurr = 0;
      saldoenddebiteq = 0;
      saldoendcrediteq = 0;

      FOR
        SELECT
          la.accountkey
        FROM
          ac_ledger_accounts la
        WHERE
          la.sqlhandle = :sqlhandle
        INTO :accountkey
      DO
      BEGIN

        SELECT
          a.DEBITSALDO,
          a.CREDITSALDO,
          a.CURRDEBITSALDO,
          a.CURRCREDITSALDO,
          a.EQDEBITSALDO,
          a.EQCREDITSALDO
        FROM
          ac_accountexsaldo(:d + 1, :accountkey, :analyticfield, :companykey,
            :allholdingcompanies, -1, :currkey) a
        INTO :sd,
             :sc,
             :sdc,
             :scc,
             :sdeq,
             :sceq;

        IF (sd IS NULL) then SD = 0;
        IF (sc IS NULL) then SC = 0;
        IF (sdc IS NULL) then SDC = 0;
        IF (scc IS NULL) then SCC = 0;
        IF (sdeq IS NULL) then SDEQ = 0;
        IF (sceq IS NULL) then SCEQ = 0;

        saldoenddebit = :saldoenddebit + :sd;
        saldoendcredit = :saldoendcredit + :sc;
        saldoenddebitcurr = :saldoenddebitcurr + :sdc;
        saldoendcreditcurr = :saldoendcreditcurr + :scc;
        saldoenddebiteq = :saldoenddebiteq + :sdeq;
        saldoendcrediteq = :saldoendcrediteq + :sceq;
      END
    END

    DEBITNCUBEGIN = :SALDOBEGINDEBIT;
    CREDITNCUBEGIN =  :SALDOBEGINCREDIT;
    DEBITNCUEND = :SALDOENDDEBIT;
    CREDITNCUEND =  :SALDOENDCREDIT;

    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR;
    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR;
    DEBITCURREND = :SALDOENDDEBITCURR;
    CREDITCURREND =  :SALDOENDCREDITCURR;

    DEBITEQBEGIN = :SALDOBEGINDEBITEQ;
    CREDITEQBEGIN =  :SALDOBEGINCREDITEQ;
    DEBITEQEND = :SALDOENDDEBITEQ;
    CREDITEQEND =  :SALDOENDCREDITEQ;

    SUSPEND;

    SALDOBEGINDEBIT = :SALDOENDDEBIT;
    SALDOBEGINCREDIT = :SALDOENDCREDIT;

    SALDOBEGINDEBITCURR = :SALDOENDDEBITCURR;
    SALDOBEGINCREDITCURR = :SALDOENDCREDITCURR;

    SALDOBEGINDEBITEQ = :SALDOENDDEBITEQ;
    SALDOBEGINCREDITEQ = :SALDOENDCREDITEQ;

    C = C + 1;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    M = EXTRACT(MONTH FROM :abeginentrydate);
    Y = EXTRACT(YEAR FROM :abeginentrydate);
    DEBITNCUBEGIN = :SALDOBEGINDEBIT;
    CREDITNCUBEGIN =  :SALDOBEGINCREDIT;
    DEBITNCUEND = :SALDOBEGINDEBIT;
    CREDITNCUEND =  :SALDOBEGINCREDIT;

    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR;
    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR;
    DEBITCURREND = :SALDOBEGINDEBITCURR;
    CREDITCURREND =  :SALDOBEGINCREDITCURR;

    DEBITEQBEGIN = :SALDOBEGINDEBITEQ;
    CREDITEQBEGIN =  :SALDOBEGINCREDITEQ;
    DEBITEQEND = :SALDOBEGINDEBITEQ;
    CREDITEQEND =  :SALDOBEGINCREDITEQ;

    BEGINDATE = :abeginentrydate;
    ENDDATE = :abeginentrydate;

    FORCESHOW = 1;

    SUSPEND;
  END
END^

CREATE PROCEDURE AC_E_L_S (
    abeginentrydate date,
    saldobegin dcurrency,
    saldobegincurr dcurrency,
    saldobegineq dcurrency,
    sqlhandle integer,
    currkey integer)
returns (
    entrydate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldoendcurr dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN
  IF (saldobegin IS NULL) THEN
    saldobegin = 0;
  IF (saldobegincurr IS NULL) THEN
    saldobegincurr = 0;
  IF (saldobegineq IS NULL) THEN
    saldobegineq = 0;
  C = 0;
  FORCESHOW = 0;
  FOR
    SELECT
      e.entrydate,
      SUM(e.debitncu - e.creditncu),
      SUM(e.debitcurr - e.creditcurr),
      SUM(e.debiteq - e.crediteq)
    FROM
      ac_ledger_entries le
      LEFT JOIN ac_entry e ON le.entrykey = e.id
    WHERE
      le.sqlhandle = :sqlhandle AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    group by e.entrydate
    INTO :ENTRYDATE,
         :O,
         :OCURR,
         :OEQ
  DO
  BEGIN
    DEBITNCUBEGIN = 0;
    CREDITNCUBEGIN = 0;
    DEBITNCUEND = 0;
    CREDITNCUEND = 0;
    DEBITCURRBEGIN = 0;
    CREDITCURRBEGIN = 0;
    DEBITCURREND = 0;
    CREDITCURREND = 0;
    DEBITEQBEGIN = 0;
    CREDITEQBEGIN = 0;
    DEBITEQEND = 0;
    CREDITEQEND = 0;
    SALDOEND = :SALDOBEGIN + :O;
    if (SALDOBEGIN > 0) then
      DEBITNCUBEGIN = :SALDOBEGIN;
    else
      CREDITNCUBEGIN =  - :SALDOBEGIN;
    if (SALDOEND > 0) then
      DEBITNCUEND = :SALDOEND;
    else
      CREDITNCUEND =  - :SALDOEND;
    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
    if (SALDOBEGINCURR > 0) then
      DEBITCURRBEGIN = :SALDOBEGINCURR;
    else
      CREDITCURRBEGIN =  - :SALDOBEGINCURR;
    if (SALDOENDCURR > 0) then
      DEBITCURREND = :SALDOENDCURR;
    else
      CREDITCURREND =  - :SALDOENDCURR;
    SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
    if (SALDOBEGINEQ > 0) then
      DEBITEQBEGIN = :SALDOBEGINEQ;
    else
      CREDITEQBEGIN =  - :SALDOBEGINEQ;
    if (SALDOENDEQ > 0) then
      DEBITEQEND = :SALDOENDEQ;
    else
      CREDITEQEND =  - :SALDOENDEQ;
    SUSPEND;
    SALDOBEGIN = :SALDOEND;
    SALDOBEGINCURR = :SALDOENDCURR;
    SALDOBEGINEQ = :SALDOENDEQ;
    C = C + 1;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    ENTRYDATE = :abeginentrydate;
    IF (SALDOBEGIN > 0) THEN
    BEGIN
      DEBITNCUBEGIN = :SALDOBEGIN;
      DEBITNCUEND = :SALDOBEGIN;
    END ELSE
    BEGIN
      CREDITNCUBEGIN =  - :SALDOBEGIN;
      CREDITNCUEND =  - :SALDOBEGIN;
    END

    IF (SALDOBEGINCURR > 0) THEN
    BEGIN
      DEBITCURRBEGIN = :SALDOBEGINCURR;
      DEBITCURREND = :SALDOBEGINCURR;
    END ELSE
    BEGIN
      CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      CREDITCURREND =  - :SALDOBEGINCURR;
    END

    IF (SALDOBEGINEQ > 0) THEN
    BEGIN
      DEBITEQBEGIN = :SALDOBEGINEQ;
      DEBITEQEND = :SALDOBEGINEQ;
    END ELSE
    BEGIN
      CREDITEQBEGIN =  - :SALDOBEGINEQ;
      CREDITEQEND =  - :SALDOBEGINEQ;
    END

    FORCESHOW = 1;
    SUSPEND;
  END
END^

CREATE PROCEDURE AC_E_L_S1 (
    abeginentrydate date,
    saldobegin dcurrency,
    saldobegincurr dcurrency,
    saldobegineq integer,
    sqlhandle integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable oeq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN
  IF (saldobegin IS NULL) THEN
    saldobegin = 0;
  IF (saldobegincurr IS NULL) THEN
    saldobegincurr = 0;
  IF (saldobegineq IS NULL) THEN
    saldobegineq = 0;
  C = 0;
  FORCESHOW = 0;
  FOR
    SELECT
      SUM(e.debitncu - e.creditncu),
      SUM(e.debitcurr - e.creditcurr),
      SUM(e.debiteq - e.crediteq),
      g_d_getdateparam(e.entrydate, :param)
    FROM
      ac_ledger_entries le
      LEFT JOIN ac_entry e ON le.entrykey = e.id
    WHERE
      le.sqlhandle = :sqlhandle AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    group by 4
    INTO :O,
         :OCURR,
         :OEQ,
         :dateparam
  DO
  BEGIN
    DEBITNCUBEGIN = 0;
    CREDITNCUBEGIN = 0;
    DEBITNCUEND = 0;
    CREDITNCUEND = 0;
    DEBITCURRBEGIN = 0;
    CREDITCURRBEGIN = 0;
    DEBITCURREND = 0;
    CREDITCURREND = 0;
    DEBITEQBEGIN = 0;
    CREDITEQBEGIN = 0;
    DEBITEQEND = 0;
    CREDITEQEND = 0;
    SALDOEND = :SALDOBEGIN + :O;
    if (SALDOBEGIN > 0) then
      DEBITNCUBEGIN = :SALDOBEGIN;
    else
      CREDITNCUBEGIN =  - :SALDOBEGIN;
    if (SALDOEND > 0) then
      DEBITNCUEND = :SALDOEND;
    else
      CREDITNCUEND =  - :SALDOEND;
    SALDOENDCURR = :SALDOBEGINCURR + :OCURR;
    if (SALDOBEGINCURR > 0) then
      DEBITCURRBEGIN = :SALDOBEGINCURR;
    else
      CREDITCURRBEGIN =  - :SALDOBEGINCURR;
    if (SALDOENDCURR > 0) then
      DEBITCURREND = :SALDOENDCURR;
    else
      CREDITCURREND =  - :SALDOENDCURR;
    SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
    if (SALDOBEGINEQ > 0) then
      DEBITEQBEGIN = :SALDOBEGINEQ;
    else
      CREDITEQBEGIN =  - :SALDOBEGINEQ;
    if (SALDOENDEQ > 0) then
      DEBITEQEND = :SALDOENDEQ;
    else
      CREDITEQEND =  - :SALDOENDEQ;
    SUSPEND;
    SALDOBEGIN = :SALDOEND;
    SALDOBEGINCURR = :SALDOENDCURR;
    SALDOBEGINEQ = :SALDOENDEQ;
    C = C + 1;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
    IF (SALDOBEGIN > 0) THEN
    BEGIN
      DEBITNCUBEGIN = :SALDOBEGIN;
      DEBITNCUEND = :SALDOBEGIN;
    END ELSE
    BEGIN
      CREDITNCUBEGIN =  - :SALDOBEGIN;
      CREDITNCUEND =  - :SALDOBEGIN;
    END

    IF (SALDOBEGINCURR > 0) THEN
    BEGIN
      DEBITCURRBEGIN = :SALDOBEGINCURR;
      DEBITCURREND = :SALDOBEGINCURR;
    END ELSE
    BEGIN
      CREDITCURRBEGIN =  - :SALDOBEGINCURR;
      CREDITCURREND =  - :SALDOBEGINCURR;
    END

    IF (SALDOBEGINEQ > 0) THEN
    BEGIN
      DEBITEQBEGIN = :SALDOBEGINEQ;
      DEBITEQEND = :SALDOBEGINEQ;
    END ELSE
    BEGIN
      CREDITEQBEGIN =  - :SALDOBEGINEQ;
      CREDITEQEND =  - :SALDOBEGINEQ;
    END

    FORCESHOW = 1;
    SUSPEND;
  END
END^

CREATE PROCEDURE AC_E_Q_S (
    valuekey integer,
    abeginentrydate date,
    saldobegin numeric(15,4),
    sqlhandle integer,
    currkey integer)
returns (
    entrydate date,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN
  C = 0;
  if (saldobegin IS NULL) then
    saldobegin = 0;

  FOR
    SELECT
      e.entrydate,
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e.accountpart = 'C', q.quantity, 0))
    FROM
      ac_ledger_entries le
      LEFT JOIN ac_entry e ON le.entrykey = e.id
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey
    WHERE
      le.sqlhandle = :SQLHANDLE AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    GROUP BY e.entrydate
    INTO :ENTRYDATE,
         :O
  DO
  BEGIN
    IF (O IS NULL) THEN O = 0;
    DEBITBEGIN = 0;
    CREDITBEGIN = 0;
    DEBITEND = 0;
    CREDITEND = 0;
    DEBIT = 0;
    CREDIT = 0;
    IF (O > 0) THEN
      DEBIT = :O;
    ELSE
      CREDIT = - :O;

    SALDOEND = :SALDOBEGIN + :O;
    if (SALDOBEGIN > 0) then
      DEBITBEGIN = :SALDOBEGIN;
    else
      CREDITBEGIN =  - :SALDOBEGIN;
    if (SALDOEND > 0) then
      DEBITEND = :SALDOEND;
    else
      CREDITEND =  - :SALDOEND;
    SUSPEND;
    SALDOBEGIN = :SALDOEND;
    C = C + 1;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    ENTRYDATE = :abeginentrydate;
    IF (SALDOBEGIN > 0) THEN
    BEGIN
      DEBITBEGIN = :SALDOBEGIN;
      DEBITEND = :SALDOBEGIN;
    END ELSE
    BEGIN
      CREDITBEGIN =  - :SALDOBEGIN;
      CREDITEND =  - :SALDOBEGIN;
    END
    SUSPEND;
  END
END^

CREATE PROCEDURE AC_E_Q_S1 (
    valuekey integer,
    abeginentrydate date,
    saldobegin numeric(15,4),
    sqlhandle integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN
  C = 0;
  if (SALDOBEGIN IS NULL) THEN
    SALDOBEGIN = 0;

  FOR
    SELECT
      g_d_getdateparam(e.entrydate, :param),
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
        SUM(IIF(e.accountpart = 'C', q.quantity, 0))
    FROM
      ac_ledger_entries le
      LEFT JOIN ac_entry e ON le.entrykey = e.id
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey
    WHERE
      le.sqlhandle = :SQLHANDLE AND
      ((0 = :currkey) OR (e.currkey = :currkey))
    GROUP BY 1
    INTO :dateparam,
         :O
  DO
  BEGIN
    IF (O IS NULL) THEN O = 0;
    DEBITBEGIN = 0;
    CREDITBEGIN = 0;
    DEBITEND = 0;
    CREDITEND = 0;
    DEBIT = 0;
    CREDIT = 0;
    IF (O > 0) THEN
      DEBIT = :O;
    ELSE
      CREDIT = - :O;

    SALDOEND = :SALDOBEGIN + :O;
    if (SALDOBEGIN > 0) then
      DEBITBEGIN = :SALDOBEGIN;
    else
      CREDITBEGIN =  - :SALDOBEGIN;
    if (SALDOEND > 0) then
      DEBITEND = :SALDOEND;
    else
      CREDITEND =  - :SALDOEND;
    SUSPEND;
    SALDOBEGIN = :SALDOEND;
    C = C + 1;
  END
  /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
  IF (C = 0) THEN
  BEGIN
    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param);
    IF (SALDOBEGIN > 0) THEN
    BEGIN
      DEBITBEGIN = :SALDOBEGIN;
      DEBITEND = :SALDOBEGIN;
    END ELSE
    BEGIN
      CREDITBEGIN =  - :SALDOBEGIN;
      CREDITEND =  - :SALDOBEGIN;
    END
    SUSPEND;
  END
END^

SET TERM ; ^
COMMIT;

CREATE EXCEPTION AC_E_AUTOTRCANTCONTAINTR 'Can`t move transaction into autotransaction';
CREATE EXCEPTION AC_E_TRCANTCONTAINAUTOTR 'Can`t move autotransaction into transaction';

SET TERM ^;

CREATE OR ALTER TRIGGER AC_TRANSACTION_BU0 FOR AC_TRANSACTION
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE a SMALLINT = NULL;
begin
  IF ((NOT NEW.parent IS NULL)
    AND (NEW.autotransaction IS DISTINCT FROM OLD.autotransaction)) THEN
  BEGIN
    SELECT autotransaction
    FROM ac_transaction
    WHERE id = new.parent
    INTO :a;

    a = COALESCE(:a, 0);
    NEW.autotransaction = COALESCE(NEW.autotransaction, 0);

    IF (NEW.autotransaction <> a) THEN
    BEGIN
      IF (a = 1) THEN
        EXCEPTION ac_e_autotrcantcontaintr;
      ELSE
        EXCEPTION ac_e_trcantcontainautotr;
    END
  END
END^

CREATE OR ALTER TRIGGER AC_TRANSACTION_BI0 FOR AC_TRANSACTION
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
  DECLARE a SMALLINT;
begin
  if (not new.parent is null) then
  begin
    select autotransaction
    from ac_transaction
    where id = new.parent
    into :a;
    new.autotransaction = COALESCE(:a, 0);
  end
end^

commit ^
CREATE PROCEDURE AC_Q_CIRCULATION (
    VALUEKEY INTEGER,
    DATEBEGIN DATE,
    DATEEND DATE,
    COMPANYKEY INTEGER,
    ALLHOLDINGCOMPANIES INTEGER,
    ACCOUNTKEY INTEGER,
    INGROUP INTEGER,
    CURRKEY INTEGER)
RETURNS (
    ID INTEGER,
    DEBITBEGIN NUMERIC(15,4),
    CREDITBEGIN NUMERIC(15,4),
    DEBIT NUMERIC(15,4),
    CREDIT NUMERIC(15,4),
    DEBITEND NUMERIC(15,4),
    CREDITEND NUMERIC(15,4))
AS
DECLARE VARIABLE O NUMERIC(15,4);
DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);
DECLARE VARIABLE SALDOEND NUMERIC(15,4);
DECLARE VARIABLE C INTEGER;
DECLARE VARIABLE LB INTEGER;
DECLARE VARIABLE RB INTEGER;
begin
  id = :accountkey;
  SELECT
    IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0)
  FROM
      ac_entry e1
      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      e1.entrydate < :datebegin AND
      e1.accountkey = :id AND
      (r1.companykey = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      r1.companykey IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin;
    if (saldobegin IS NULL) then
      saldobegin = 0;

    C = 0;
    FOR
      SELECT
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_entry e
        LEFT JOIN ac_record r ON r.id = e.recordkey
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND
          q.valuekey = :valuekey
      WHERE
        e.entrydate <= :dateend AND
        e.entrydate >= :datebegin AND
        e.accountkey = :id AND
        (r.companykey = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        r.companykey IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        G_SEC_TEST(r.aview, :ingroup) <> 0 AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      INTO :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
       CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END
    /*���� �� ��������� ������ ��� �������� �� ������� ������ �� ������ �������*/
    IF (C = 0) THEN
    BEGIN
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
    END
  SUSPEND;
end^

COMMIT^

SET TERM ;^


