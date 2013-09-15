
CREATE DOMAIN drelationtype
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('T', 'V'));

COMMIT;

/*
 *
 * ������� ������. �������� ������ ���� ������
 * ���� ������. ���������� ��� ���������
 * ������� ���������.
 *
 */

CREATE TABLE at_relations (
  id              dintkey,

  relationname    dtablename NOT NULL,

  relationtype    drelationtype,                    /* ���: T -- table,  V -- view */


  lname           dname,                            /* �������������� ���                    */
  lshortname      dname,                            /* �������������� �������� ���           */
  description     dtext180,                         /* ��������                              */

  afull           dsecurity,                        /* ����� �������                         */
  achag           dsecurity,
  aview           dsecurity,

  referencekey    dforeignkey,                      /* ������ �� �������,
                                                       �� ������� ��������������� ����� ��������� ����  */
  branchkey       dforeignkey,                      /* ����� ������ �� ���������� */
  listfield       dfieldname,                       /* ���� ��� ����������� */
  extendedfields  dtext254,                         /* ���� ��� ������������ �����������, ��� �������� ����� ������� */

  editiondate     deditiondate,                     /* ���� ���������� �������������� */
  editorkey       dintkey,                          /* ������ �� ������������, ������� ������������ ������*/
  reserved        dinteger                          /* ��������������� ��� ������� ��������� */
);

COMMIT;

ALTER TABLE at_relations ADD CONSTRAINT at_pk_relations_id
  PRIMARY KEY (id);


ALTER TABLE at_relations ADD  CONSTRAINT at_fk_relations_referencekey
 FOREIGN KEY (referencekey) REFERENCES at_relations (id);


ALTER TABLE at_relations ADD CONSTRAINT at_fk_relations_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_relations_rn ON at_relations
  (relationname);

CREATE UNIQUE INDEX at_x_relations_ln ON at_relations
  (lname);

CREATE UNIQUE INDEX at_x_relations_lsn ON at_relations
  (lshortname);

COMMIT;

/*
 * �������, ��� �������������� ��� ������, ���� �����.
 * ����� 1-�-1 � ������� rdb$fields.
 * ������ ������� ���������� ��� ��� �����������,
 * ��������� ���� �������, ��������� ���������� ��������.
 *
 */
CREATE DOMAIN dvisible
  AS SMALLINT
  DEFAULT 1
  CHECK ((VALUE IS NULL) OR (VALUE IN (0, 1)));

CREATE DOMAIN dcolwidth
  AS SMALLINT
  DEFAULT 20
  CHECK ((VALUE IS NULL) OR (VALUE >= 0));

COMMIT;

CREATE TABLE at_fields(
  id              dintkey,

  fieldname       dfieldname NOT NULL,              /* ������������ ������                 */

  lname           dname,                            /* �������������� ������������         */
  description     dtext180,                         /* �����������                         */

  reftable        dtablename,                       /* ��� ���� ������� ��������� */
  reflistfield    dfieldname,                       /* ������������ ����, ������� ��������� ��� ������ �������� ��������� */
  refcondition    dtext255,                          /* ������� ����������� ���������       */

  reftablekey     dforeignkey,                          /* ��� ���� ������� ��������� */
  reflistfieldkey dforeignkey,

  settable        dtablename,                       /* ��� ���� ���������                     */
  setlistfield    dfieldname,                       /*                                        */
  setcondition    dtext255,                          /* ������� ����������� ���������       */

  settablekey     dforeignkey,                          /* ��� ���� ���������                     */
  setlistfieldkey dforeignkey,

  /* ���������� ��������� �� ��������� ��� ����� ������� ���� */

  alignment       dtextalignment,                   /* ������������ �� ���������           */
  format          dtext60,                          /* ������ �����������                  */
  visible         dvisible,                         /* ������� ���� ��� ���                */
  colwidth        dcolwidth,                        /* ������ �������, ��� �����. � �����  */

  readonly        dboolean DEFAULT 0,               /* ��������� �� ���������� �������������� ���� */

  gdclassname     dtext60,                          /* ������������ ������ */
  gdsubtype       dtext60,                          /* ������ ������ */

  numeration      dnumerationblob,                  /* ������ �������� ������������ */

  disabled        dboolean DEFAULT 0,               /* �� ������������                     */
  editiondate     deditiondate,                     /* ���� ���������� �������������� */
  editorkey       dintkey,                          /* ������ �� ������������, ������� ������������ ������*/
  reserved        dinteger
);

COMMIT;

ALTER TABLE at_fields ADD CONSTRAINT at_pk_fields_id
  PRIMARY KEY (id);

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_rt
  FOREIGN KEY (reftablekey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_st
  FOREIGN KEY (settablekey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_chk_fields_numeration
  CHECK ((NUMERATION IS NULL) OR (OCTET_LENGTH(NUMERATION) > 0));

COMMIT;

CREATE UNIQUE INDEX at_x_fields_fn ON at_fields (fieldname);

COMMIT;

/* ������� �������� ��� �����-������ */
CREATE DOMAIN ddeleterule AS
VARCHAR(11) CHARACTER SET WIN1251
COLLATE PXW_CYRL;

/*
 *  ������� ������ ���� ��� ������ ������� � �������.
 *
 *
 *
 */

CREATE TABLE at_relation_fields(
  id              dintkey,

  fieldname       dfieldname NOT NULL,              /* ������������ ���� � IB                 */

  relationname    dtablename NOT NULL,              /* ������ �� �������                      */
  fieldsource     dfieldname,                       /* ������ �� ��� ���� (�����)             */

  crosstable      dtablename,                       /* ��� ���� ���������                     */
  crossfield      dfieldname,                       /*                                        */


  relationkey     dmasterkey,                       /* ������ �� �������                      */
  fieldsourcekey  dintkey,                          /* ������ �� ��� ���� (�����)             */

  crosstablekey   dforeignkey,                      /* ��� ���� ���������                     */
  crossfieldkey   dforeignkey,                      /*                                        */

  lname           dname,                            /* �������������� ������������ ����       */
  lshortname      dtext20,                          /* �������������� ������������ ����       */
  description     dtext180,                         /* �������� ���������� ����               */

  /* ���������� ��������� ��� ���� */

  visible         dboolean,                         /* ������� ����                           */
  format          dtext60,                          /* ������ ������                          */
  alignment       dtextalignment,                   /* ������������                           */
  colwidth        dsmallint,                        /* ������ ���� � �����                    */

  readonly        dboolean DEFAULT 0,               /* ��������� �� ���������� �������������� ���� */

  gdclassname     dtext180,                         /* ������������ ������ */
  gdsubtype       dtext180,                         /* ������ ������ */

  afull           dsecurity,                        /* ����� �������                          */
  achag           dsecurity,
  aview           dsecurity,

  objects         dblobtext80_1251,                 /* ������ ������-��������, ��� ������� ��� ���� ������������ */
  deleterule      ddeleterule,                      /* ������� �������� ��� ����� ������ */
  editiondate     deditiondate,                     /* ���� ���������� �������������� */
  editorkey       dintkey,                          /* ������ �� ������������, ������� ������������ ������*/
  reserved        dinteger                           /* ��������������� ��� ������� ���������  */
);

COMMIT;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_pk_relation_fields_id
  PRIMARY KEY (id);

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_rn
  FOREIGN KEY (relationkey) REFERENCES at_relations (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_fs
  FOREIGN KEY (fieldsourcekey) REFERENCES at_fields (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_ct
  FOREIGN KEY (crosstablekey) REFERENCES at_relations (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_cf
  FOREIGN KEY (crossfieldkey) REFERENCES at_relation_fields (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_relation_fields_fr ON at_relation_fields
  (fieldname, relationname);

CREATE INDEX at_x_relation_fields_rn ON at_relation_fields
   (relationname);

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_rlf
  FOREIGN KEY (reflistfieldkey) REFERENCES at_relation_fields (id) 
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_slf
  FOREIGN KEY (setlistfieldkey) REFERENCES at_relation_fields (id) 
  ON UPDATE CASCADE ON DELETE SET NULL;


COMMIT;

/*
 *
 *  ���������� ����������, ���� �������� � �����������
 *  ��������� ��� ����� ��� � ����� �����������.
 *
 */

CREATE TABLE at_transaction(
  trkey           dintkey,                           /* ���� ���������� */
  numorder        dsmallint NOT NULL,                /* ����� �� ������� */
  script          dscript,                         /* ������, ������� ����� ��������� */
  successfull     dboolean DEFAULT 0                 /* ������ �� ������ �������� */
);

ALTER TABLE at_transaction ADD CONSTRAINT at_pk_transaction_tr
  PRIMARY KEY (trkey, numorder);

COMMIT;

/*
 *
 *  ��� ������� ���� ���� ��������� ���������� ������� �������������
 *  ������� � �������.
 *  ��� ��������� ���� ���� �������� �� ����� ������������ ���������.
 *
 */

CREATE GENERATOR gd_g_triggercross;
SET GENERATOR gd_g_triggercross TO 10;

/*
 *
 *  ��� ��������� ����������� ������ ATFIELD, AT_RELATION
 *  T_RELATION_FIELD �������� ���� ���������.
 *  ��������� ��������� ��� ������������ ������ ���������
 *
 */

CREATE GENERATOR gd_g_attr_version;
SET GENERATOR gd_g_attr_version TO 12;

COMMIT;

SET TERM ^ ;


/*
 *
 *  �������� ��� ������� �����
 *
 */


CREATE TRIGGER at_bi_fields FOR at_fields
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_ai_fields FOR at_fields
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_fields FOR at_fields
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ad_fields FOR at_fields
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_fields5 FOR at_fields
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_fields5 FOR at_fields
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

/*
 *
 *  �������� ��� ������� ������
 *
 */

CREATE TRIGGER at_bi_relations FOR at_relations
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_ai_relations FOR at_relations
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_relations FOR at_relations
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ad_relations FOR at_relations
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_relations5 FOR at_relations
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_relations5 FOR at_relations
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

/*
 *
 *  �������� ��� ������� ����� ������
 *
 */

CREATE TRIGGER at_bi_rf FOR at_relation_fields
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (g_s_trim(NEW.relationname, ' ') = '') THEN
  BEGIN
    SELECT relationname FROM at_relations WHERE id = NEW.relationkey
    INTO NEW.relationname;
  END
  IF (NEW.crossfield= '') THEN NEW.crossfield=NULL;
  IF (NEW.crosstable = '') THEN NEW.crosstable=NULL;
END
^

CREATE TRIGGER at_bu_rf FOR at_relation_fields
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.crossfield= '') THEN NEW.crossfield=NULL;
  IF (NEW.crosstable = '') THEN NEW.crosstable=NULL;
END
^

CREATE TRIGGER at_ai_relation_field FOR at_relation_fields
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_relation_field FOR at_relation_fields
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ad_relation_field FOR at_relation_fields
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_relation_fields5 FOR at_relation_fields
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_relation_fields5 FOR at_relation_fields
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

/*
 *
 * ���������, �������������� ������������ ������
 * �������� ������ ���� ������
 * ��������� 6400 ������ ��� �������.
 *
 */

/*06.09.02 ������� �� ������������� */
CREATE PROCEDURE GD_P_RELATION_FORMATS
RETURNS
  (
    RELATION_ID VARCHAR(32000),
    RELATION_FORMAT VARCHAR(32000)
  )
AS
  DECLARE VARIABLE REL_ID INTEGER;
  DECLARE VARIABLE REL_FORMAT INTEGER;

BEGIN
  RELATION_ID = '';
  RELATION_FORMAT = '';

  FOR
    SELECT
      RDB$RELATION_ID, RDB$FORMAT
    FROM
      RDB$RELATIONS
    WHERE
      RDB$SYSTEM_FLAG = 0
    ORDER BY
      RDB$RELATION_ID
  INTO
    :REL_ID, :REL_FORMAT
  DO BEGIN
    RELATION_ID = RELATION_ID || '_' || CAST(REL_ID AS VARCHAR(4));
    RELATION_FORMAT = RELATION_FORMAT || '_' || CAST(REL_FORMAT AS VARCHAR(4));
  END

  SUSPEND;
END
^


SET TERM ; ^

COMMIT;


CREATE DOMAIN ddescription AS
BLOB SUB_TYPE 1 SEGMENT SIZE 80 CHARACTER SET WIN1251 ;

CREATE DOMAIN dexceptionname AS
VARCHAR(31) CHARACTER SET WIN1251
NOT NULL
COLLATE PXW_CYRL;

CREATE DOMAIN dmessage AS
VARCHAR(78) CHARACTER SET WIN1251
COLLATE PXW_CYRL;

COMMIT;

/* ������� ���������� */
CREATE TABLE at_exceptions (
  id               dintkey NOT NULL, /* ������������� */
  exceptionname    dexceptionname    /* ������������ ���������� */
                   NOT NULL collate PXW_CYRL,
  lmessage         dtext80          /* �������������� ��������� */
                   collate PXW_CYRL,
  editiondate      deditiondate,    /* ���� ���������� �������������� */
  editorkey        dintkey          /* ������ �� ������������, ������� ������������ ������*/
                   );

COMMIT;

ALTER TABLE at_exceptions ADD CONSTRAINT at_pk_exceptions PRIMARY KEY(id);

CREATE UNIQUE INDEX at_x_exceptions_en ON at_exceptions
   (exceptionname);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_ad_exceptions FOR at_exceptions
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ai_exceptions FOR at_exceptions
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_exceptions FOR at_exceptions
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_exceptions FOR at_exceptions
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_bi_exceptions5 FOR at_exceptions
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_exceptions5 FOR at_exceptions
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^
SET TERM ; ^

COMMIT;

/*������� ����� */
CREATE TABLE AT_CHECK_CONSTRAINTS (
  id                dintkey,
  checkname         dtablename NOT NULL,
  msg               dtext80 COLLATE PXW_CYRL,
  editiondate       deditiondate
);

COMMIT;

ALTER TABLE AT_CHECK_CONSTRAINTS ADD CONSTRAINT AT_PK_CHECK_CONSTRAINTS 
  PRIMARY KEY (ID);

CREATE UNIQUE INDEX AT_X_CONSTRAINTS_IN 
  ON AT_CHECK_CONSTRAINTS (CHECKNAME);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER AT_AIUD_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER AT_BI_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE at_generators (
  id               dintkey,
  generatorname    dtablename NOT NULL,
  editiondate      deditiondate,
  editorkey        dintkey
);

COMMIT;

ALTER TABLE at_generators ADD CONSTRAINT at_pk_generators
  PRIMARY KEY(id);

ALTER TABLE AT_GENERATORS ADD CONSTRAINT AT_FK_GENERATORS_EDITORKEY
  FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE;

CREATE UNIQUE INDEX at_x_generators_en
  ON at_generators (generatorname);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_aiud_generators FOR at_generators
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_generators FOR at_generators
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_generators FOR at_generators
  ACTIVE
  BEFORE UPDATE
  POSITION 27000
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

CREATE DOMAIN dindexname AS VARCHAR(31)
  CHARACTER SET WIN1251 COLLATE WIN1251;

COMMIT;

CREATE DOMAIN dprocedurename AS VARCHAR(31)
  CHARACTER SET WIN1251 COLLATE WIN1251;

/*������� ��� ������-��������*/
CREATE TABLE AT_PROCEDURES (
  id              dintkey NOT NULL,        /* ������������� */
  procedurename   dprocedurename NOT NULL  /* ������������ ��������� */
                  collate WIN1251,
  proceduresource dblobtext80_1251,        /* ������ ���� ���������. ������������
                                              ������ ��� ���������� � �����
                                             (�.�. �� �� ����� ��������� ��������� ��������� ��������� ) */
  editiondate     deditiondate,            /* ���� ���������� �������������� */
  editorkey       dintkey                  /* ������ �� ������������, ������� ������������ ������*/
);

ALTER TABLE at_procedures ADD CONSTRAINT pk_at_procedures PRIMARY KEY (id);

CREATE UNIQUE INDEX at_x_procedures_pn ON at_procedures
   (procedurename);

ALTER TABLE at_procedures ADD CONSTRAINT at_fk_procedures_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_ad_procedures FOR at_procedures ACTIVE
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ai_procedures FOR at_procedures ACTIVE
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_procedures FOR at_procedures ACTIVE
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_procedures FOR at_procedures ACTIVE
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_bi_procedures5 FOR at_procedures
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_procedures5 FOR at_procedures
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE at_indices(
  id                  dintkey,                /* ������������� */
  indexname           dindexname              /* ������������ ������� */
                      NOT NULL,

  relationname        dtablename              /* ������������ ������� */
                      NOT NULL,

  fieldslist          dtext255,               /* ������ ����� */

  relationkey         dmasterkey              /* ������������� ������� */
                      NOT NULL,

  unique_flag         dboolean DEFAULT 0,     /* 0-������������ ������, 1-���������� */

  index_inactive      dboolean DEFAULT 0,     /* 0-�������� ������, 1-����������*/
  editiondate         deditiondate,           /* ���� ���������� �������������� */
  editorkey           dintkey                 /* ������ �� ������������, ������� ������������ ������*/
);

COMMIT;

ALTER TABLE at_indices ADD CONSTRAINT at_pk_indices PRIMARY KEY(id);

ALTER TABLE at_indices ADD CONSTRAINT at_fk_indices_relationkey FOREIGN KEY(relationkey)
REFERENCES at_relations(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX at_x_indices_rn ON at_indices
   (relationname);

CREATE UNIQUE INDEX at_x_indices_in ON at_indices
   (indexname);

ALTER TABLE at_indices ADD CONSTRAINT at_fk_indices_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;


SET TERM ^ ;

/* Triggers definition */



CREATE TRIGGER at_ad_indices FOR at_indices
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_au_indices FOR at_indices
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_ai_indices FOR at_indices
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_bi_indices FOR at_indices
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (g_s_trim(NEW.relationname, ' ') = '') THEN
  BEGIN
    SELECT relationname FROM at_relations WHERE id = NEW.relationkey
    INTO NEW.relationname;
  END
END
^

CREATE TRIGGER at_bi_indices5 FOR at_indices
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_indices5 FOR at_indices
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^
COMMIT;


CREATE DOMAIN dtriggername AS
VARCHAR(31) CHARACTER SET WIN1251
COLLATE WIN1251;

CREATE TABLE at_triggers(
  id                  dintkey,                /* ������������� */
  triggername         dtriggername            /* ������������ �������� */
                      NOT NULL,

  relationname        dtablename              /* ������������ ������� */
                      NOT NULL,

  relationkey         dmasterkey              /* ������������� ������� */
                      NOT NULL,

  trigger_inactive    dboolean DEFAULT 0,     /* 0-�������� ������, 1-����������*/
  editiondate         deditiondate,           /* ���� ���������� �������������� */
  editorkey           dintkey                 /* ������ �� ������������, ������� ������������ ������*/

);

COMMIT;

ALTER TABLE at_triggers ADD CONSTRAINT at_pk_triggers PRIMARY KEY(id);

ALTER TABLE at_triggers ADD CONSTRAINT at_fk_trigger_relationkey FOREIGN KEY(relationkey)
REFERENCES at_relations(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX at_x_triggers_rn ON at_triggers
   (relationname);

ALTER TABLE at_triggers ADD CONSTRAINT at_fk_triggers_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_triggers_tn ON at_triggers
   (triggername);

COMMIT;

SET TERM ^ ;

/* Triggers definition */



CREATE TRIGGER at_ad_triggers FOR at_triggers
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_ai_triggers FOR at_triggers
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_au_triggers FOR at_triggers
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_bi_triggers FOR at_triggers
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (g_s_trim(NEW.relationname, ' ') = '') THEN
  BEGIN
    SELECT relationname FROM at_relations WHERE id = NEW.relationkey
    INTO NEW.relationname;
  END
END
^

CREATE TRIGGER at_bi_triggers5 FOR at_triggers
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER at_bu_triggers5 FOR at_triggers
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

COMMIT ^



/*@DECLARE MACRO ATTR_TRG(%TableName%, %TableAlias%)

CREATE TRIGGER gd_ai_%TableAlias% FOR %TableName%
  AFTER INSERT
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_au_%TableAlias% FOR %TableName%
  AFTER UPDATE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_ad_%TableAlias% FOR %TableName%
  AFTER DELETE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

END MACRO*/

/*@UNFOLD MACRO ATTR_TRG(RDB$FIELDS, RDB_FIELDS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$RELATIONS, RDB_RELATIONS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@.CALL MACRO ATTR_TRG(RDB$RELATION_FIELDS, RDB_RELATION_FIELDS)*/
/*@UNFOLD MACRO ATTR_TRG(RDB$TRIGGERS, RDB_TRIGGERS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$PROCEDURES, RDB_PROCEDURES)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$PROCEDURE_PARAMETERS, RDB_PROCEDURE_PARAMETERS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$INDICES, RDB_INDICES)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$INDEX_SEGMENTS, RDB_INDEX_SEGMENTS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/


CREATE TRIGGER gd_ai_rdb_relation_fields FOR rdb$relation_fields
  AFTER INSERT
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^
/*  ��� ����������� IBExpert-��, IBExpert �������� �������� ����
  rdb$description ������� rdb$database ������� ��� ���� ������� �
  �������������, ���������� ��������� */
CREATE TRIGGER gd_au_rdb_relation_fields FOR rdb$relation_fields
  AFTER UPDATE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  IF ((NEW.rdb$field_name <> OLD.rdb$field_name)
    OR (NEW.rdb$relation_name <> OLD.rdb$relation_name))
  THEN
    I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_ad_rdb_relation_fields FOR rdb$relation_fields
  AFTER DELETE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

SET TERM ; ^

COMMIT;

/*
 *
 *   FKManager
 *
 */

CREATE EXCEPTION gd_e_fkmanager 'Exception in FK manager code';

CREATE DOMAIN d_fk_metaname AS CHAR(31) CHARACTER SET unicode_fss;

CREATE TABLE gd_ref_constraints (
  id               dintkey,
  constraint_name  d_fk_metaname UNIQUE,
  const_name_uq    d_fk_metaname,
  match_option     char(7)  character set none,
  update_rule      char(11) character set none,
  delete_rule      char(11) character set none,

  constraint_rel   d_fk_metaname,
  constraint_field d_fk_metaname,
  ref_rel          d_fk_metaname,
  ref_field        d_fk_metaname,

  ref_state        char(8) character set none,
  ref_next_state   char(8) character set none,

  constraint_rec_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
      WHERE
        rc.rdb$relation_name = constraint_rel
        AND rc.rdb$constraint_type = 'PRIMARY KEY')),

  constraint_uq_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$index_segments iseg
        ON iseg.rdb$index_name = i.rdb$index_name
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
    WHERE
      iseg.rdb$field_name = constraint_field
      AND i.rdb$segment_count = 1
      AND rc.rdb$constraint_name = constraint_name
      AND rc.rdb$constraint_type = 'FOREIGN KEY'
  )),

  ref_rec_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
    WHERE
      rc.rdb$relation_name = ref_rel
      AND rc.rdb$constraint_type = 'PRIMARY KEY')),

  CONSTRAINT gd_pk_ref_constraint PRIMARY KEY (id),
  CONSTRAINT gd_chk1_ref_contraint CHECK (ref_state IN ('ORIGINAL', 'TRIGGER')),
  CONSTRAINT gd_chk2_ref_contraint CHECK (ref_next_state IN ('ORIGINAL', 'TRIGGER'))
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_ref_constraints FOR gd_ref_constraints
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_bd_ref_constraints FOR gd_ref_constraints
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.ref_state <> 'ORIGINAL') THEN
    EXCEPTION gd_e_fkmanager 'Ref constraint is not in ORIGINAL state';
END
^

SET TERM ; ^

CREATE TABLE gd_ref_constraint_data (
  constraintkey    dintkey,
  value_data       INTEGER,

  CONSTRAINT gd_pk_ref_constraint_data PRIMARY KEY (value_data, constraintkey),
  CONSTRAINT gd_fk_ref_constraint_data FOREIGN KEY (constraintkey)
    REFERENCES gd_ref_constraints (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_biu_ref_constraint_data FOR gd_ref_constraint_data
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'REF_CONSTRAINT_UNLOCK') IS DISTINCT FROM '1') THEN
    EXCEPTION gd_e_fkmanager 'Constraint data is locked';
END
^

SET TERM ; ^

COMMIT;

CREATE GLOBAL TEMPORARY TABLE gd_object_dependencies (
  sessionid         dintkey,
  masterid          dintkey,
  reflevel          dinteger_notnull,
  relationname      dtablename NOT NULL,
  fieldname         dfieldname NOT NULL,
  crossrelation     dboolean_notnull,
  refobjectid       dintkey,
  refobjectname     dname,
  refrelationname   dname,
  refclassname      dname,
  refsubtype        dname,
  refeditiondate    TIMESTAMP,

  PRIMARY KEY (sessionid, masterid, reflevel, relationname, fieldname)
)
  ON COMMIT DELETE ROWS;

COMMIT;




