
CREATE EXCEPTION GD_E_DOCUMENTTYPE_RUID
  'Document of this type already exists!';

CREATE EXCEPTION GD_E_DOCUMENTTYPE_NAME
  'Document of this type already exists!';

/*
 *  �������� ������� ��������
 *  ���������:
 *  B - branch (�����)
 *  D - document (��������)
 *
 */

CREATE DOMAIN ddocumenttype
  AS VARCHAR(1)
  CHECK ((VALUE = 'B') OR (VALUE = 'D'));

/* ��� ��������� */
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

  disabled                dboolean DEFAULT 0,
  ruid                    druid,                     /* ������ ���� ��������� */
  branchkey               dforeignkey,               /* ����� � ������������� */
  reportgroupkey          dforeignkey,               /* ������ ������� */
  reserved                dreserved,
  iscommon                dboolean DEFAULT 0,
  ischecknumber           SMALLINT DEFAULT 0,        /* ������������ �������: 0 -- �� ���������, 1 -- ������, 2 -- � ��� ����, 3 -- � ��� �-�� */
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
  /*COMPUTED BY (UPPER(name));*/
  (name);

COMMIT;
/*
CREATE DESC INDEX gd_x_documenttype_rb
  ON gd_documenttype(rb);

CREATE ASC INDEX gd_x_documenttype_lb
  ON gd_documenttype(lb);
*/

/* ��������� ���������� */

CREATE TABLE gd_lastnumber
(
  documenttypekey       dintkey,
  ourcompanykey         dintkey,

  lastnumber            dinteger, /* ��������� ����� */
  addnumber             dinteger, /* ��������� �� */
  mask                  dtext80,  /* ����� */
  fixlength             dfixlength, /* ������������� ����� ������ */

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

/* ��������� ������� ��������� ��� ����������� ���. ��������� */
/*
CREATE TABLE gd_accessdoctype
(
  documenttypekey     dintkey,
  accessdoctypekey    dintkey,

  afull               dsecurity,
  achag               dsecurity,
  aview               dsecurity
);

ALTER TABLE gd_accessdoctype ADD CONSTRAINT gd_pk_accessdoctype
  PRIMARY KEY (documenttypekey, accessdoctypekey);

ALTER TABLE gd_accessdoctype ADD CONSTRAINT gd_fk_adt_documenttypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_accessdoctype ADD CONSTRAINT gd_fk_adt_accessdoctypekey
  FOREIGN KEY (accessdoctypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
*/  

/* ������� ������ �������, ������� �������� �� ���������� �������� */

/*

CREATE TABLE gd_relationtypedoc
(
  doctypekey          dintkey,             
  relationname        dtablename NOT NULL, 
  ismaindoc           dboolean             
                                           
);


ALTER TABLE gd_relationtypedoc ADD CONSTRAINT gd_pk_relationtypedoc
  PRIMARY KEY (doctypekey, relationname);

ALTER TABLE gd_relationtypedoc ADD CONSTRAINT gd_fk_relationtypedoc_doctype
  FOREIGN KEY (doctypekey) REFERENCES gd_documenttype (id)
  ON UPDATE CASCADE;

*/

COMMIT;


/**********************************************************

  ��������

  �� ��������� ������� ��������� � ������� �� ��� � �����
  �������. ����� ����� ���������� � �������� ����� �������-
  �������� ����� ������ Parent.

***********************************************************/

CREATE TABLE gd_document
(
  id              dintkey,             /* ������������� ���������         */
  parent          dforeignkey,         /* �������� �� ������ �� ���������*/

  documenttypekey dintkey,             /* ��� ���������                   */
  trtypekey       dforeignkey,         /* �������� ��������� � ��������   */
  transactionkey  dforeignkey,         /* �������� ��������� � ����� ��������   */

  number          ddocumentnumber,     /* ����� ���������                 */
  documentdate    ddocumentdate,       /* ���� ���������                  */
  description     dtext180,            /* ����������                      */
  sumncu          dcurrency,           /* ���� � ���                      */
  sumcurr         dcurrency,           /* ���� � ������                   */
  sumeq           dcurrency,           /* ���� � ����������              */
                                       /* �����! ����� ���� �������� ���  */
                                       /* ������. ����� ����� ����� ��-*/
                                       /* �� � ���������� ������         */

  delayed         dboolean,            /* ���������� ��������             */
                                       /* �������� ��������, �� � ����� ��*/
                                       /* ����������                      */

  afull           dsecurity,           /* ����� �������                   */
  achag           dsecurity,
  aview           dsecurity,

  currkey         dforeignkey,         /* ������ ���������                */
  companykey      dintkey,             /* �����, ��� ��� �������� ��    */
                                       /* �������� ������                */

  creatorkey      dintkey,             /* ��� ������� ��������            */
  creationdate    dcreationdate,       /* ���� � ��� ����������           */
  editorkey       dintkey,             /* ��� ���������                  */
  editiondate     deditiondate,        /* ���� � ��� �������������        */

  printdate       ddate,               /* ���� ��������� ������ ��������� */

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


SET TERM ^ ;


SET TERM ; ^


COMMIT;

/* ��������� ��������� ������� */
/*
CREATE TABLE gd_documentsystem
(
  subsystemkey          dintkey,
  documenttypekey       dintkey,
  reserved              dinteger
);

ALTER TABLE gd_documentsystem ADD CONSTRAINT gd_pk_documentsystem
  PRIMARY KEY (subsystemkey, documenttypekey);

ALTER TABLE gd_documentsystem ADD CONSTRAINT gd_fk_ds_subsystemkey
  FOREIGN KEY (subsystemkey) REFERENCES gd_subsystem(id) ON UPDATE CASCADE;

ALTER TABLE gd_documentsystem ADD CONSTRAINT gd_fk_ds_documenttypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id) ON UPDATE CASCADE;

COMMIT;
*/

SET TERM ^ ;


/****************************************************/
/**                                                **/
/**   ������� �������������� ���������� ������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER gd_bi_documenttype FOR gd_documenttype
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
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
  ��� ������� � ���������� ������ ������������� ��������������
  ���� ���� �������� � ���� ��������������, ���� ����������� ��
  �������� �� ��������������.
*/

CREATE TRIGGER gd_bi_document FOR gd_document
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  /*
  ������ ��� ���� ����������� � ������-�������

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

  /* ������ ���������� ��� ������ */
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

  �� ���� ��������� ���������� �������������
  ���� ���������.

  �� ������:

    1 -- �������� ������ ���� �� �������� ����������.
    0 -- �������� ����� ���� ������������ (���� ��
         ������ � ��������������� ������).

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
/*   ������� ������ ���� ��������� ����������                       */
/*   GD_DOCUMENTLINK                                                */
/********************************************************************/

CREATE TABLE gd_documentlink(
  sourcedockey         dintkey,   /* �������� ��������              */
  destdockey           dintkey,   /* �������� ����������            */
                                                                    
  sumncu               dcurrency, /* ����� � ���                    */
  sumcurr              dcurrency, /* ����� � ������                 */
  sumeq                dcurrency, /* ����� � �����������            */

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
