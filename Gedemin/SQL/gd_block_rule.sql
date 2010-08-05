
/*

  Copyright (c) 2001-2010 by Golden Software of Belarus


  Script

    gd_block_rule.sql

  Abstract
  
    Таблицы, триггеры, хранимые процедуры 
    механизма блокировки периода

  Author

    Alex Stav
*/

CREATE TABLE GD_BLOCK_RULE 
(
  ID                    DINTKEY,                     /*Первичный ключ*/
  NAME                  DNAME,                       /*Наименование правила*/
  ORDR                  DINTEGER_NOTNULL,            /*Порядковый номер правила*/
  FORDOCS               DBOOLEAN_NOTNULL DEFAULT 1,  /*Правило для документов*/
  ALLDOCTYPES           DBOOLEAN_NOTNULL DEFAULT 1,  /*для всех типов документов*/
  INCLDOCTYPES          DBOOLEAN_NOTNULL DEFAULT 1,  /*блокировка распространяется на документы из GD_BLOCK_DT*/
  TABLENAME             DTABLENAME,                  /*Имя таблицы, на которую устанавливается блокировка*/
  ROOTKEY               DFOREIGNKEY,                 /*идентификатор ветви*/
  INCLSUBLEVELS         DBOOLEAN_NOTNULL DEFAULT 1,  /*должно входить в ветвь*/
  ALLRECORDS            DBOOLEAN_NOTNULL DEFAULT 1,  /*блокируются все записи*/
  SELECTCONDITION       DTEXT1024,                   /*Произвольное условие отбора записей*/
  ANYDATE               DBOOLEAN_NOTNULL DEFAULT 1,  /*блокировка вне зависимости от даты*/
  DATEFIELDNAME         DFIELDNAME,                  /*Имя поля с датой в таблице tablename*/
  FIXEDDATE             DBOOLEAN_NOTNULL DEFAULT 0,  /*Признак фиксированной даты блокировкаи*/
  BLOCKDATE             DDATE,                       /*Фиксированная дата блокировки*/
  DAYNUMBER             DINTEGER_NOTNULL DEFAULT 0,  /*Номер дня относительно начала единицы периода*/
  DATEUNIT              CHAR(2),                     /*Единица периода*/
  ALLUSERS              DBOOLEAN_NOTNULL DEFAULT 1,  /*Правило для всех пользователей*/
  INCLUSERS             DBOOLEAN_NOTNULL DEFAULT 1,  /*включать указанные группы в блокировку*/
  USERGROUPS            DINTKEY,                     /*Битовая маска групп пользователей*/
  CREATORKEY            DINTKEY,                     /*Кто создал запись*/
  CREATIONDATE          DCREATIONDATE,               /*Дата создания*/
  EDITORKEY             DINTKEY,                     /*Кто последним менял запись*/
  EDITIONDATE           DEDITIONDATE,                /*Дата изменения*/
  DISABLED              DDISABLED DEFAULT 0          /*Правило отключено*/
);

COMMIT;

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT DATE_UNIT_CHECK CHECK (dateunit in ('CW','CM','CQ','CY','PW','PM','PQ','PY','TO')); 

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT UNQ1_GD_BLOCK_RULE UNIQUE (ORDR);

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT PK_GD_BLOCK_RULE PRIMARY KEY (ID);

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT FK_GD_BLOCK_RULE_1 FOREIGN KEY (CREATORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE;
ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT FK_GD_BLOCK_RULE_2 FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE;

GRANT ALL ON GD_BLOCK_RULE TO ADMINISTRATOR;

COMMIT;

CREATE TABLE GD_BLOCK_DT 
(
  BLOCKRULEKEY          DINTKEY               /* Ссылка на правило блокировки*/,
  DTKEY                 DINTKEY               /*Ссылка на тип документа*/
);

COMMIT;

ALTER TABLE GD_BLOCK_DT ADD CONSTRAINT FK_GD_BLOCK_DT_1 FOREIGN KEY (BLOCKRULEKEY) REFERENCES GD_BLOCK_RULE (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE GD_BLOCK_DT ADD CONSTRAINT FK_GD_BLOCK_DT_2 FOREIGN KEY (DTKEY) REFERENCES GD_DOCUMENTTYPE (ID) ON DELETE CASCADE ON UPDATE CASCADE;
GRANT ALL ON GD_BLOCK_DT TO ADMINISTRATOR;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER GD_BI_BLOCK_RULE FOR GD_BLOCK_RULE
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  IF (NEW.creationdate IS NULL) THEN
    NEW.creationdate = CURRENT_TIMESTAMP;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
end
^

CREATE TRIGGER GD_BU_BLOCK_RULE FOR GD_BLOCK_RULE
ACTIVE BEFORE UPDATE POSITION 0
AS
begin
  NEW.editiondate = CURRENT_TIMESTAMP;
end
^

/*Определеие даты блокировки при использовании относительной даты*/
CREATE PROCEDURE AC_CALC_DATE (
    DU CHAR(2),
    DN INTEGER)
RETURNS (
    ADATE DATE)
AS
DECLARE VARIABLE M SMALLINT;
DECLARE VARIABLE Y INTEGER;
BEGIN 

  IF (:DU = 'TO') THEN
    ADATE = CURRENT_DATE + :DN;

  IF (:DU IN ('CW','PW')) THEN
    BEGIN 
      IF (:DU = 'CW') THEN
        ADATE = CURRENT_DATE - EXTRACT(WEEKDAY FROM CURRENT_DATE) + 1;
      ELSE
        ADATE = CURRENT_DATE - EXTRACT(WEEKDAY FROM CURRENT_DATE) - 6;
      ADATE = ADATE + :DN;
    END 

  IF (:DU IN ('CM','PM')) THEN
    BEGIN
      M = EXTRACT(MONTH FROM CURRENT_DATE);
      Y = EXTRACT(YEAR FROM CURRENT_DATE); 
      IF (:DU = 'PM') THEN
        M = M - 1; 
      IF (:M = 0) THEN 
        BEGIN 
          M = 12; 
          Y = Y - 1; 
        END 
      ADATE = CAST('01.' || M || '.' || Y AS DATE) + :DN;
    END

  IF (:DU IN ('CQ','PQ')) THEN
    BEGIN
      M = EXTRACT(MONTH FROM CURRENT_DATE); 
      Y = EXTRACT(YEAR FROM CURRENT_DATE); 
--      Q = EXTRACT(QUARTER FROM CURRENT_DATE);
      M = CASE
            WHEN (:M IN (1,2,3)) THEN  1
            WHEN (:M IN (4,5,6)) THEN  4
            WHEN (:M IN (7,8,9)) THEN  7
            WHEN (:M IN (10,11,12)) THEN 10
          END;
      IF (:DU = 'PQ') THEN
        BEGIN
          IF (M = 1) THEN
            BEGIN
              M = 10;
              Y = Y - 1;
            END ELSE
          M = M - 3;
        END
      ADATE = CAST('01.' || M || '.' || Y AS DATE) + :DN;
    END

  IF (:DU IN ('CY','PY')) THEN
    BEGIN
      Y = EXTRACT(YEAR FROM CURRENT_DATE); 
      if (:DU = 'PY') then
        Y = Y - 1;
      ADATE = CAST('01.01.' || Y AS DATE) + :DN ;
    END

  SUSPEND; 

END
^

/*Проверка выполнения условий правила блокировки*/
CREATE PROCEDURE GD_P_BLOCK (
    IS_DOC SMALLINT,
    BLOCK_DATE DATE,
    DOC_TYPE INTEGER,
    BLOCK_TABLE_NAME VARCHAR(255))
RETURNS (
    IS_BLOCKED SMALLINT)
AS
DECLARE VARIABLE ID INTEGER;
DECLARE VARIABLE DATEFIELDNAME VARCHAR(60);
DECLARE VARIABLE ANYDATE SMALLINT;
DECLARE VARIABLE FIXEDDATE SMALLINT;
DECLARE VARIABLE BLOCKDATE DATE;
DECLARE VARIABLE DAYNUMBER INTEGER;
DECLARE VARIABLE DATEUNIT CHAR(2);
DECLARE VARIABLE USERGROUPS INTEGER;
DECLARE VARIABLE CALC_DATE DATE;
DECLARE VARIABLE F_DATE SMALLINT;
DECLARE VARIABLE F_UG SMALLINT;
DECLARE VARIABLE F_DT SMALLINT;
DECLARE VARIABLE IG INTEGER;
DECLARE VARIABLE ALLUSERS SMALLINT;
DECLARE VARIABLE INCLUSERS SMALLINT;
BEGIN 
  IS_BLOCKED = 0; 
  IF (:IS_DOC = 1) THEN 
    BEGIN 
      FOR 
        SELECT ID, ANYDATE, FIXEDDATE, BLOCKDATE, DAYNUMBER, DATEUNIT,
               USERGROUPS, ALLUSERS, INCLUSERS
        FROM GD_BLOCK_RULE 
        WHERE FORDOCS = 1 AND DISABLED = 0
        ORDER BY ORDR 
        INTO :ID, :ANYDATE, :FIXEDDATE, :BLOCKDATE, :DAYNUMBER,
             :DATEUNIT, :USERGROUPS, :ALLUSERS, :INCLUSERS
      DO 
        BEGIN 
          -- ДАТА БЛОКИРОВКИ 
          IF (:FIXEDDATE = 1) THEN 
            CALC_DATE = :BLOCKDATE; ELSE 
            EXECUTE PROCEDURE AC_CALC_DATE(:DATEUNIT,:DAYNUMBER)
              RETURNING_VALUES :CALC_DATE; 
          IF ((:BLOCK_DATE - CAST('17.11.1858' AS DATE)) < :CALC_DATE) THEN 
            F_DATE = 1; ELSE F_DATE = 0; 
          IF (:ANYDATE = 1) THEN F_DATE = 1;
          --ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ 
          SELECT INGROUP FROM GD_USER WHERE IBNAME = CURRENT_USER 
            INTO :IG; 
          IF (:ALLUSERS = 1) THEN
            F_UG = 1; ELSE 
            BEGIN 
              IF (BIN_AND(:USERGROUPS, :IG) = 0) THEN
                BEGIN 
                  IF (:INCLUSERS = 1)  THEN
                    F_UG = 1; ELSE F_UG = 0; 
                END  ELSE 
                BEGIN 
                  IF (:INCLUSERS = 0)  THEN
                    F_UG = 1; ELSE F_UG = 0; 
                END 
            END 
          --ТИП  ДОКУМЕНТА 
          IF (EXISTS(SELECT 0 FROM GD_BLOCK_DT WHERE BLOCKRULEKEY = :ID AND DTKEY = :DOC_TYPE)) 
            THEN 
              F_DT = 1; ELSE F_DT = 0; 
          --IS_BLOCKED 
          IF ((F_DATE =1) AND (F_DT =1) AND (F_UG = 1)) THEN 
            BEGIN 
              IS_BLOCKED = 1; 
              LEAVE; 
            END 
            ELSE IS_BLOCKED = 0; 
        END 
    END ELSE 
    BEGIN 
      FOR 
        SELECT ID, ANYDATE, DATEFIELDNAME, FIXEDDATE, BLOCKDATE, 
               DAYNUMBER, DATEUNIT, USERGROUPS, ALLUSERS, INCLUSERS
        FROM GD_BLOCK_RULE 
        WHERE FORDOCS = 0 AND DISABLED = 0 AND TABLENAME = :BLOCK_TABLE_NAME
        ORDER BY ORDR 
        INTO :ID, :ANYDATE, :DATEFIELDNAME, :FIXEDDATE, :BLOCKDATE,
             :DAYNUMBER, :DATEUNIT, :USERGROUPS, :ALLUSERS, :INCLUSERS
      DO 
        BEGIN 
          IF (DATEFIELDNAME IS NOT NULL) THEN 
          -- ДАТА БЛОКИРОВКИ 
          IF (:FIXEDDATE = 1) THEN 
            CALC_DATE = :BLOCKDATE; ELSE 
            EXECUTE PROCEDURE AC_CALC_DATE(:DATEUNIT, :DAYNUMBER)
              RETURNING_VALUES :CALC_DATE; 
          IF ((:BLOCK_DATE - CAST('17.11.1858' AS DATE)) < :CALC_DATE) THEN 
            F_DATE = 1; ELSE F_DATE = 0;     
          IF (:ANYDATE = 1) THEN F_DATE = 1;
          --ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ
          SELECT INGROUP FROM GD_USER WHERE IBNAME = CURRENT_USER 
            INTO :IG; 
          IF (:ALLUSERS = 1) THEN
            F_UG = 1; ELSE 
            BEGIN 
              IF (BIN_AND(:USERGROUPS, :IG) = 0) THEN
                BEGIN 
                  IF (:INCLUSERS = 1)  THEN
                    F_UG = 1; ELSE F_UG = 0; 
                END  ELSE 
                BEGIN 
                  IF (:INCLUSERS = 1)  THEN
                    F_UG = 1; ELSE F_UG = 0; 
                END 
            END 
          --IS_BLOCKED 
          IF ((F_DATE = 1) AND (F_UG = 1)) THEN
            BEGIN 
              IS_BLOCKED = 1; 
              LEAVE; 
            END 
            ELSE IS_BLOCKED = 0; 
        END 
    END 
  SUSPEND; 
END
^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE AC_CALC_DATE TO PUBLIC;
GRANT EXECUTE ON PROCEDURE GD_P_BLOCK TO PUBLIC;

COMMIT;
