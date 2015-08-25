
CREATE EXCEPTION GD_E_DOCUMENTTYPE_RUID
  'Document of this type already exists!';

CREATE EXCEPTION GD_E_DOCUMENTTYPE_NAME
  'Document of this type already exists!';

/*
 *  Значение позиции типового
 *  документа:
 *  B - branch (ветка)
 *  D - document (документ)
 *
 */

CREATE DOMAIN ddocumenttype
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('B', 'D'));

/* Тип документа */
CREATE TABLE gd_documenttype
(
  id                      dintkey,
  parent                  dparent,
  lb                      dlb,
  rb                      drb,

  name                    dname,
  description             dtext180,

  classname               dclassname,
  documenttype            ddocumenttype DEFAULT 'D',

  options                 DBLOB1024,
  headerrelkey            dforeignkey,
  linerelkey              dforeignkey,

  afull                   dsecurity,
  achag                   dsecurity,
  aview                   dsecurity,

  editiondate             deditiondate,

  disabled                dboolean DEFAULT 0,
  ruid                    druid,                     /* Хранит руид документа  */
  branchkey               dforeignkey,               /* Ветка в исследователе */
  reportgroupkey          dforeignkey,               /* Группа отчетов */
  reserved                dreserved,
  iscommon                dboolean DEFAULT 0,
  ischecknumber           SMALLINT DEFAULT 0,        /* Дублирование номеров: 0 -- не проверять, 1 -- всегда, 2 -- в теч года, 3 -- в теч м-ца */
  headerfunctionkey       dforeignkey,
  headerfunctiontemplate  dblob80,
  linefunctionkey         dforeignkey,
  linefunctiontemplate    dblob80,

  CONSTRAINT gd_chck_icn_documenttype CHECK (ischecknumber BETWEEN 0 AND 3)
);

COMMIT;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_pk_documenttype
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_parent
  FOREIGN KEY (parent) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_header
  FOREIGN KEY (headerrelkey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_line
  FOREIGN KEY (linerelkey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE GD_DOCUMENTTYPE ADD CONSTRAINT FK_GD_DOCUMENTTYPE_HF
  FOREIGN KEY (HEADERFUNCTIONKEY) REFERENCES GD_FUNCTION (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

ALTER TABLE GD_DOCUMENTTYPE ADD CONSTRAINT FK_GD_DOCUMENTTYPE_LF
  FOREIGN KEY (LINEFUNCTIONKEY) REFERENCES GD_FUNCTION (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;
COMMIT;

CREATE INDEX gd_x_documenttype_ruid
  ON gd_documenttype(ruid);

CREATE UNIQUE INDEX gd_x_documenttype_name ON gd_documenttype
  (name);

COMMIT;

CREATE EXCEPTION gd_e_cannotchangebranch 'Can not change branch!';

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_au_documenttype FOR gd_documenttype
  ACTIVE
  AFTER UPDATE
  POSITION 20000
AS
  DECLARE VARIABLE new_root dintkey;
  DECLARE VARIABLE old_root dintkey;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    SELECT id FROM gd_documenttype
    WHERE parent IS NULL AND lb <= NEW.lb AND rb >= NEW.rb
    INTO :new_root;

    SELECT id FROM gd_documenttype
    WHERE parent IS NULL AND lb <= OLD.lb AND rb >= OLD.rb
    INTO :old_root;

    IF (:new_root <> :old_root) THEN
    BEGIN
      IF (:new_root IN (804000, 805000) OR :old_root IN (804000, 805000)) THEN
        EXCEPTION gd_e_cannotchangebranch;
    END
    
    IF (NEW.documenttype = 'B') THEN
    BEGIN
      IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> 'B' AND id = NEW.parent)) THEN
        EXCEPTION gd_e_exception 'Document class can not include a folder.';
    END
  END
END
^

CREATE OR ALTER TRIGGER gd_aiu_documenttype FOR gd_documenttype
  ACTIVE
  AFTER INSERT OR UPDATE
  POSITION 20001
AS
BEGIN
  IF (NEW.documenttype = 'B') THEN
  BEGIN
    IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> 'B' AND id = NEW.parent)) THEN
      EXCEPTION gd_e_exception 'Document class can not include a folder.';
  END
END
^

SET TERM ; ^

CREATE TABLE gd_documenttype_option (
  id                    dintkey,
  dtkey                 dintkey,
  option_name           dname,
  bool_value            dboolean,
  str_value             dtext255,
  relationkey           dforeignkey,
  relationfieldkey      dforeignkey,
  contactkey            dforeignkey,
  disabled              ddisabled,
  
  CONSTRAINT gd_pk_dt_option PRIMARY KEY (id),
  CONSTRAINT gd_fk_dt_option_dtkey FOREIGN KEY (dtkey)
    REFERENCES gd_documenttype (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_relkey FOREIGN KEY (relationkey)
    REFERENCES at_relations (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_relfkey FOREIGN KEY (relationfieldkey)
    REFERENCES at_relation_fields (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_contactkey FOREIGN KEY (contactkey)
    REFERENCES gd_contact (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_uq_dt_option UNIQUE (dtkey, option_name)
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_documenttype_option FOR gd_documenttype_option
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^    

SET TERM ; ^

/* Нумерация документов */

CREATE TABLE gd_lastnumber
(
  documenttypekey       dintkey,
  ourcompanykey         dintkey,

  lastnumber            dinteger, /* Последний номер */
  addnumber             dinteger, /* Увеливать на */
  mask                  dtext80,  /* маска */
  fixlength             dfixlength, /* фиксированная длина номера */

  disabled              dboolean DEFAULT 0
);

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_pk_lastnumber
  PRIMARY KEY (documenttypekey, ourcompanykey);

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_fk_ln_documenttypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_fk_ln_ourcompanykey
  FOREIGN KEY (ourcompanykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;


/**********************************************************

  Документ

  Мы планируем хранить документы и позиции по ним в одной
  таблице. Связь между документом и позицией будет устанав-
  ливаться через ссылку Parent.

***********************************************************/

CREATE TABLE gd_document
(
  id              dintkey,             /* Ідэнтыфікатар дакумента         */
  parent          dforeignkey,         /* Спасылка ад пазіцыі да дакумента*/

  documenttypekey dintkey,             /* Тып дакумента                   */
  trtypekey       dforeignkey,         /* Привязка документа к операции   */
  transactionkey  dforeignkey,         /* Привязка документа к новой операции   */

  number          ddocumentnumber,     /* нумар дакумента                 */
  documentdate    ddocumentdate,       /* дата дакумента                  */
  description     dtext180,            /* каментарый                      */
  sumncu          dcurrency,           /* сума ў НГА                      */
  sumcurr         dcurrency,           /* сума ў валюце                   */
  sumeq           dcurrency,           /* сума ў эквіваленце              */
                                       /* УВАГА! гэтыя сумы выключна для  */
                                       /* даведкі. Заўсёды трэба браць су-*/
                                       /* му з адпаведнай табліцы         */

  delayed         dboolean,            /* отложенный документ             */
                                       /* документ оформлен, но в учете не*/
                                       /* фигурирует                      */

  afull           dsecurity,           /* права доступа                   */
  achag           dsecurity,
  aview           dsecurity,

  currkey         dforeignkey,         /* валюта дакумента                */
  companykey      dintkey,             /* фірма, калі ўлік вядзецца па    */
                                       /* некалькіх фірмах                */

  creatorkey      dintkey,             /* хто стварыў дакумент            */
  creationdate    dcreationdate,       /* дата і час стварэньня           */
  editorkey       dintkey,             /* хто рэдактаваў                  */
  editiondate     deditiondate,        /* дата і час рэдактаваньня        */

  printdate       ddate,               /* дата последней печати документа */

  disabled        ddisabled,
  reserved        dreserved
);

ALTER TABLE gd_document
  ADD CONSTRAINT gd_pk_document PRIMARY KEY (id);

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_parent
  FOREIGN KEY (parent) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_doctypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id) ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE DESC INDEX gd_x_document_documentdate
  ON gd_document(documentdate);

CREATE  INDEX gd_x_document_number
  ON gd_document(number);


COMMIT;

SET TERM ^ ;

/****************************************************/
/**                                                **/
/**   Триггер обрабатывающий добавление нового     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER gd_bi_documenttype FOR gd_documenttype
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS(SELECT id FROM gd_documenttype WHERE ruid = NEW.ruid)) THEN
  BEGIN
    EXCEPTION gd_e_documenttype_ruid;
  END

  IF (EXISTS(SELECT id FROM gd_documenttype WHERE UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_documenttype_name;
  END
END
^

/*
  При вставке и обновлении записи автоматически инициализируем
  поля Дата создания и Дата редактирования, если программист не
  присвоил их самостоятельно.
*/

CREATE TRIGGER gd_bi_document FOR gd_document
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  /*
  теперь эти поля заполняются в бизнес-объекте

  IF (NEW.creationdate IS NULL) THEN
    NEW.creationdate = CURRENT_TIMESTAMP;

  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
  */
END
^

CREATE TRIGGER GD_AU_DOCUMENT FOR GD_DOCUMENT
  AFTER UPDATE 
  POSITION 0
AS
BEGIN
  IF (NEW.PARENT IS NULL) THEN
  BEGIN
    IF ((OLD.documentdate <> NEW.documentdate) OR (OLD.number <> NEW.number) 
      OR (OLD.companykey <> NEW.companykey)) THEN
    BEGIN
      IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN
        UPDATE gd_document SET documentdate = NEW.documentdate,
          number = NEW.number, companykey = NEW.companykey
        WHERE (parent = NEW.ID)
          AND ((documentdate <> NEW.documentdate)
           OR (number <> NEW.number) OR (companykey <> NEW.companykey));
      ELSE                                                                  
        UPDATE gd_document SET documentdate = NEW.documentdate,
          companykey = NEW.companykey
        WHERE (parent = NEW.ID)
          AND ((documentdate <> NEW.documentdate)
          OR  (companykey <> NEW.companykey));
    END
  END ELSE
  BEGIN
    IF (NEW.editiondate <> OLD.editiondate) THEN
      UPDATE gd_document SET editiondate = NEW.editiondate,
        editorkey = NEW.editorkey
      WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);
  END

  /* просто игнорируем все ошибки */
  WHEN ANY DO
  BEGIN
  END
END
^

CREATE TRIGGER GD_AD_DOCUMENT FOR GD_DOCUMENT
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (NOT (OLD.PARENT IS NULL)) THEN
  BEGIN
    UPDATE gd_document SET editiondate = 'NOW'
    WHERE ID = OLD.parent;
  END
END
^

CREATE TRIGGER GD_AI_DOCUMENT FOR GD_DOCUMENT
  AFTER INSERT
  POSITION 0
AS
BEGIN
  IF (NOT (NEW.PARENT IS NULL)) THEN
  BEGIN
    UPDATE gd_document SET editiondate = NEW.editiondate,
      editorkey = NEW.editorkey
    WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);
  END
END
^

/*

  На вход процедуры передается идентификатор
  типа документа.

  На выходе:

    1 -- документ такого типа не подлежит блокировке.
    0 -- документ может быть заблокирован (если он
         входит в заблокированный период).

*/

CREATE PROCEDURE gd_p_exclude_block_dt(DT INTEGER)
  RETURNS(F INTEGER)
AS
BEGIN
  F = 0;
END
^

CREATE TRIGGER gd_bi_document_block FOR gd_document
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
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

CREATE TRIGGER gd_bu_document_block FOR gd_document
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) 
      OR ((OLD.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
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

CREATE TRIGGER gd_bd_document_block FOR gd_document
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (OLD.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
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

SET TERM ; ^

COMMIT;


/********************************************************************/
/*   Таблица хранит коды связанных документов                       */
/*   GD_DOCUMENTLINK                                                */
/********************************************************************/

CREATE TABLE gd_documentlink(
  sourcedockey         dintkey,   /* Документ источник              */
  destdockey           dintkey,   /* Документ назначение            */
                                                                    
  sumncu               dcurrency, /* Сумма в НДЕ                    */
  sumcurr              dcurrency, /* Сумма в валюте                 */
  sumeq                dcurrency, /* Сумма в эквиваленте            */

  reserved             dinteger 
);

COMMIT;

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_pk_documentlink
  PRIMARY KEY (sourcedockey, destdockey);

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_fk_documentlink_source
  FOREIGN KEY (sourcedockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_fk_documentlink_dest
  FOREIGN KEY (destdockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;
