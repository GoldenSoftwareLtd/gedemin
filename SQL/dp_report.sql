
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    dp_report.sql

  Abstract

    Шаблоны отчетов для Департамента

  Author

    Anton Smirnov (27.12.2000),
    Teryokhina Julia (04.02.02) 

  Revisions history

    Initial  27.12.2000  SAI    Initial version

  Status

    Draft

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* Акт описи и оценки  */

CREATE TABLE dp_report
(
  id         dintkey,
  parent     dinteger,
  reporttype dinteger,
  name       dname,
  filename   dtext254,
  afull      dsecurity,
  achag      dsecurity,
  aview      dsecurity,
  reserved   dinteger
);

ALTER TABLE dp_report
  ADD CONSTRAINT dp_pk_report PRIMARY KEY (id);

ALTER TABLE dp_report ADD CONSTRAINT dp_fk_report
  FOREIGN KEY (parent) REFERENCES dp_report(id);

SET TERM ^ ;

CREATE TRIGGER dp_bi_report FOR dp_report
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/* Для отчета 2 остаток по клиенту на дату */

CREATE PROCEDURE DP_P_GETCOMPANYREST (
    COMPANYKEY INTEGER,
    RESTDATE DATE,
    INGROUP INTEGER)
RETURNS (
    SUMNCU NUMERIC(15,4))
AS
  DECLARE VARIABLE S DECIMAL(15, 4);
  DECLARE VARIABLE SS DECIMAL(15, 4);
BEGIN
  sumncu = 0;

  SELECT SUM(t1.sumncustart) FROM dp_transfer t1, gd_document d1, gd_document ivdoc1 
  WHERE t1.documentkey = d1.id and t1.companykey = :companykey and ivdoc1.id = t1.inventorykey 
        and d1.documentdate <= :RestDate
        and g_sec_testall(ivdoc1.aview, ivdoc1.achag, ivdoc1.afull, :ingroup) <> 0
  INTO :S;

  IF (:S IS NOT NULL) THEN
    sumncu = :S;

  SELECT SUM(r.sumncuadd), SUM(r.sumncudel) FROM
    dp_revaluation r, gd_document d, dp_transfer t, gd_document i
  WHERE
    r.transferkey = t.documentkey and
    d.id = t.documentkey and
    t.inventorykey = i.id and
    d.documentdate <= :RestDate and
    t.companykey = :CompanyKey and
    g_sec_testall(i.aview, i.achag, i.afull, :ingroup) <> 0
  INTO :S, :SS;

  IF (:S IS NOT NULL) THEN
    sumncu = :sumncu + :s;

  IF (:SS IS NOT NULL) THEN
    sumncu = :sumncu - :ss;


  SELECT SUM(bsl2.csumncu)
  FROM bn_bankstatementline bsl2, bn_bankstatement bs2,
       gd_document d2, bn_bslinedocument bsld, dp_transfer t2, gd_document dinv2
  WHERE bsl2.bankstatementkey = bs2.documentkey and
        bs2.documentkey = d2.id and bsl2.companykey = :COMPANYKEY and
        bsld.bslinekey = bsl2.id and bsld.documentkey = t2.documentkey and
        dinv2.id = t2.inventorykey and
        g_sec_testall(dinv2.aview, dinv2.achag, dinv2.afull, :ingroup) <> 0 and
        d2.documentdate <= :RestDate
  INTO :S;


  IF (:S IS NOT NULL) THEN
    sumncu = :sumncu - :s;
  SUSPEND;
END
^

CREATE PROCEDURE DP_P_GETCOMPANYREST2 (
    COMPANYKEY INTEGER,
    RESTDATE DATE,
    INGROUP INTEGER)
RETURNS (
    SUMNCU NUMERIC(15,4))
AS
  DECLARE VARIABLE S DECIMAL(15, 4);
  DECLARE VARIABLE SS DECIMAL(15, 4);
BEGIN
  sumncu = 0;

  SELECT SUM(t1.sumncustart) FROM dp_transfer t1, gd_document d1, gd_document ivdoc1
  WHERE t1.documentkey = d1.id and t1.companykey = :companykey and ivdoc1.id = t1.inventorykey
        and d1.documentdate <= :RestDate
        and g_sec_testall(ivdoc1.aview, ivdoc1.achag, ivdoc1.afull, :ingroup) <> 0
  INTO :S;

  IF (:S IS NOT NULL) THEN
    sumncu = :S;

  SELECT SUM(r.sumncuadd), SUM(r.sumncudel) FROM
    dp_revaluation r, gd_document d, dp_transfer t, gd_document i
  WHERE
    r.transferkey = t.documentkey and
    d.id = t.documentkey and
    t.inventorykey = i.id and
    d.documentdate <= :RestDate and
    t.companykey = :CompanyKey and
    g_sec_testall(i.aview, i.achag, i.afull, :ingroup) <> 0
  INTO :S, :SS;

  IF (:S IS NOT NULL) THEN
    sumncu = :sumncu + :s;

  IF (:SS IS NOT NULL) THEN
    sumncu = :sumncu - :ss;


  SELECT SUM(bsl2.csumncu)
  FROM bn_bankstatementline bsl2, bn_bankstatement bs2,
       gd_document d2
  WHERE bsl2.bankstatementkey = bs2.documentkey and
        bs2.documentkey = d2.id and bsl2.companykey = :COMPANYKEY and
        d2.documentdate <= :RestDate
  INTO :S;


  IF (:S IS NOT NULL) THEN
    sumncu = :sumncu - :s;
  SUSPEND;
END
^


CREATE PROCEDURE DP_P_GETFINREST (
    CONTACTKEY INTEGER,
    RESTDATE DATE)
RETURNS (
    SUMNCU DOUBLE PRECISION)
AS
  declare variable tempsum double precision;
BEGIN
  sumncu = 0;
  
  SELECT SUM(bsl2.csumncu)
  FROM
    bn_bankstatementline bsl2,
    bn_bankstatement bs2,
    gd_document d2,
    bn_bslinedocument bsld,
    dp_transfer t2,
    dp_inventory inv2,
    dp_authority a,
    dp_decree d
    
  WHERE
    bsl2.bankstatementkey = bs2.documentkey and
        bs2.documentkey = d2.id and
        bsld.bslinekey = bsl2.id and
        bsld.documentkey = t2.documentkey and
        inv2.documentkey = t2.inventorykey and
        inv2.authoritykey = a.companykey and
        d2.documentdate <= :RestDate and
        a.financialkey = :contactkey and
        inv2.decreekey = d.id and
        d.percent = 50
  INTO :tempsum;

  if (:tempsum is NOT NULL) then
    sumncu = :sumncu + :tempsum;
    
  SELECT SUM(bsl.dsumncu)
  FROM
    bn_bankstatementline bsl,
    bn_bankstatement bs,
    gd_document d
  WHERE
    bsl.bankstatementkey = bs.documentkey and
    bsl.companykey = :contactkey and
    d.id = bs.documentkey and
    d.documentdate <= :RestDate
  INTO
    :tempsum;

  if (:tempsum is NOT NULL) then
    sumncu = :sumncu - :tempsum;

  sumncu = :sumncu / 2;

  SUSPEND;
END
^

/* Процедура для вычисления задолженности по актам. Используется в фильтрах */

CREATE PROCEDURE DP_CALC_DEBTS_FOR_ACTS (
    INVENTORYKEY INTEGER,
    SUMNCU DECIMAL (15, 4))
RETURNS (
    HAS_DEBTS DOUBLE PRECISION)
AS
  DECLARE VARIABLE tempsumncu DOUBLE precision;
BEGIN
  has_debts = sumncu;
  
  SELECT SUM(r.sumncuadd - r.sumncudel)
  FROM dp_revaluation r
  JOIN dp_transfer t ON r.transferkey = t.documentkey
  WHERE
    t.inventorykey = :inventorykey
  INTO :tempsumncu;
  
  IF (tempsumncu IS NOT NULL) THEN
    has_debts = has_debts + tempsumncu;
    
  SELECT SUM(bsld.sumncu)
  FROM dp_transfer t
  JOIN bn_bslinedocument bsld ON bsld.documentkey = t.documentkey
  WHERE
    t.inventorykey = :inventorykey
  INTO :tempsumncu;

  IF (tempsumncu IS NOT NULL) THEN
    has_debts = has_debts - tempsumncu;
    
  SUSPEND;
END
^





SET TERM ; ^

COMMIT;

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009910, NULL, 1, '1. Реестр полученных денежных средств',
    'Реестр средств.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009920, NULL, 2, '2. Оборотная ведомость', 'Оборотная ведомость.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009930, NULL, 3, '3. Поступление денежных средств',
    'Поступление денежных средств.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009940, NULL, 4, '4. Нереализованное в срок иммущество',
    'Нереализованное в срок иммущество.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009950, NULL, 5, '5. Карточка по реализаторам',
    'Карточка по реализаторам.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009960, NULL, 6, '6. Суммы для перечисления в бюджет',
    'Суммы для перечисления в бюджет.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009970, NULL, 7, '7. Перечисления со счета Департамента',
    'Перечисления со счета Департамента.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009980, NULL, 8, '8. Оборотная ведомость по валюте',
    'Оборотная ведомость по валюте.RTF');

INSERT INTO dp_report(id, parent, reporttype, name, filename)
  VALUES(1009990, NULL, 9, '9. Движение иностранной валюты',
    'Движение иностранной валюты.RTF');

/*DEPARTAMENT 1009900..1010000*/

COMMIT;


