SET TERM ^;
CREATE PROCEDURE AC_CIRCULATIONLIST (
    DATEBEGIN DATE,
    DATEEND DATE,
    COMPANYKEY INTEGER,
    ALLHOLDINGCOMPANIES INTEGER,
    ACCOUNTKEY INTEGER,
    INGROUP INTEGER,
    CURRKEY INTEGER)
RETURNS (
    ALIAS VARCHAR(20),
    NAME VARCHAR(180),
    ID INTEGER,
    NCU_BEGIN_DEBIT NUMERIC(15,4),
    NCU_BEGIN_CREDIT NUMERIC(15,4),
    NCU_DEBIT NUMERIC(15,4),
    NCU_CREDIT NUMERIC(15,4),
    NCU_END_DEBIT NUMERIC(15,4),
    NCU_END_CREDIT NUMERIC(15,4),
    CURR_BEGIN_DEBIT NUMERIC(15,4),
    CURR_BEGIN_CREDIT NUMERIC(15,4),
    CURR_DEBIT NUMERIC(15,4),
    CURR_CREDIT NUMERIC(15,4),
    CURR_END_DEBIT NUMERIC(15,4),
    CURR_END_CREDIT NUMERIC(15,4),
    EQ_BEGIN_DEBIT NUMERIC(15,4),
    EQ_BEGIN_CREDIT NUMERIC(15,4),
    EQ_DEBIT NUMERIC(15,4),
    EQ_CREDIT NUMERIC(15,4),
    EQ_END_DEBIT NUMERIC(15,4),
    EQ_END_CREDIT NUMERIC(15,4),
    OFFBALANCE INTEGER)
AS
  DECLARE VARIABLE ACTIVITY CHAR(1);
  DECLARE VARIABLE SALDO NUMERIC(15,4);
  DECLARE VARIABLE SALDOCURR NUMERIC(15,4);
  DECLARE VARIABLE SALDOEQ NUMERIC(15,4);
  DECLARE VARIABLE FIELDNAME VARCHAR(60);
  DECLARE VARIABLE LB INTEGER;
  DECLARE VARIABLE RB INTEGER;
BEGIN
  /* Procedure Text */

  SELECT c.lb, c.rb FROM ac_account c
  WHERE c.id = :ACCOUNTKEY
  INTO :lb, :rb;
 
  FOR 
    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance 
    FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id 
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
      SELECT
        SUM(e.DEBITNCU - e.CREDITNCU),
        SUM(e.DEBITCURR - e.CREDITCURR),
        SUM(e.DEBITEQ - e.CREDITEQ)
      FROM
        ac_entry e
        LEFT JOIN ac_record r ON e.recordkey = r.id 
      WHERE
        e.accountkey = :id AND e.entrydate < :datebegin AND 
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
 
 
    SELECT
      SUM(e.DEBITNCU),
      SUM(e.CREDITNCU),
      SUM(e.DEBITCURR),
      SUM(e.CREDITCURR),
      SUM(e.DEBITEQ),
      SUM(e.CREDITEQ)
    FROM
      ac_entry e
      LEFT JOIN ac_record r ON e.recordkey = r.id 
    WHERE 
      e.accountkey = :id AND e.entrydate >= :datebegin AND 
      e.entrydate <= :dateend AND 
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
    INTO :NCU_DEBIT, :NCU_CREDIT,
      :CURR_DEBIT, CURR_CREDIT,
      :EQ_DEBIT, EQ_CREDIT;

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
END^

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
    /*≈сли за указанный период нет движени€ то выводим сальдо на начало периода*/
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

SET TERM ;^
