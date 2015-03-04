
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_script.sql

  Abstract

    An Interbase script for script control.

  Author

    Romanovski Denis (01.08.00)

  Revisions history

    Initial  01.08.00  Dennis    Initial version

  Status

*/

/****************************************************

   ������� ��� �������� �������������

*****************************************************/

/*
  DFUNCTIONTYPE
  ����� ��� �������� ���� �������:
  ��� ������ ��� ���������� ������� (Event)
*/
CREATE DOMAIN DFUNCTIONTYPE
  AS CHAR(1)
  CHECK ((VALUE IS NULL) or (VALUE IN ('E', 'M')));

CREATE DOMAIN DINHERITEDRULE AS 
  SMALLINT 
  CHECK (VALUE IN (0, 1, 3) OR VALUE IS NULL);
  
CREATE TABLE gd_function
(
  id               dintkey,                     /* ��������� ���� */
  module           dtext40,                     /* ������ */
  language         dtext10,                     /* ���� ���������������� */
  name             dlongname,                   /* ������������ ������� */
  comment          dtext180,                    /* ����������� � ������� */
  script           dscript,                     /* ����� ������� */
  displayscript    dscript,                     /* ������� ����� ������� *//*������ ���� ����� �������*/

  afull            dsecurity,                   /* ����� ������� ������ *//*������ ���� ����� �������*/
  achag            dsecurity,                   /* ����� ������� �� ��������� *//*������ ���� ����� �������*/
  aview            dsecurity,                   /* ����� ������� �� �������� *//*������ ���� ����� �������*/
  modifydate       dtimestamp,                  /*������ ���� ����� �������*/

  testresult       dblob80,                     /* ���� ��� �������. ��� �������� ������ ���������. */
  ownername        dtext40,                     /*������ ���� ����� �������*/
  functiontype     dfunctiontype,               /*������ ���� ����� �������*/
  event            dtext40,

  localname        dtext40,                      /* �������� ������� �� ������� ����� *//*������ ���� ����� �������*/
  publicfunction   dboolean DEFAULT 1 NOT NULL,  /* ��������� ��� ������� ������� *//*������ ���� ����� �������*/
  shortcut         dtext10,                       /* ������� ������� *//*������ ���� ����� �������*/
  groupname        dtext20,                      /* �������� ������ *//*������ ���� ����� �������*/

  modulecode       dinteger NOT NULL,            /* ��� ������ */
  enteredparams    dblob80,
  reserved         dinteger,                      /* ��������������� */
  inheritedrule    dinheritedrule,                /*���� ��� ������� ��������� �� ������
                                                  ����������. ��� ����� ��������� ��� ��������:
                                                    0 - ����������� ���������;
                                                    1 - �������� ������������ ���������� �� ������-�������;
                                                    2 - �������� ���������� ����� ���������� ������-�������.*//*������ ���� ����� �������*/
/*  preparedbyparser dboolean,                      ���� TRUE �� ������ ������� ��� ����������� ��������
                                                   ������ ���� ��� �� ����� */
  breakpoints      dblob80,                        /* ���� ������ ���������� � ������ ����������*/
  usedebuginfo     dboolean,                       /* ��������� �� ������������� ������������� ��������� ��� ������� �������*//*������ ���� ����� �������*/
  editorstate      dblob80,                        /* �������� ��������� ������� ���������, �������� � �.�.*/
  editiondate      deditiondate,                   /* ���� ���������� �������������� */
  editorkey        dintkey                         /* ������ �� ������������, ������� ������������ ������*/
);

ALTER TABLE gd_function ADD CONSTRAINT gd_pk_function
  PRIMARY KEY (id);

/* ������ ��� �� ��������i���� 1 ���� */
ALTER TABLE gd_function ADD CONSTRAINT gd_chk_function_language
  CHECK (language IN ('JScript', 'VBScript'));

/* ����� ������i ���i��� ���� ��i������� */
/* � ����� ������ ������                 */
CREATE UNIQUE INDEX gd_x_function_name ON gd_function
  (name, modulecode);

CREATE INDEX gd_x_function_module ON gd_function
  (module);

ALTER TABLE gd_function ADD CONSTRAINT gd_fk_function_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE GENERATOR gd_g_functionch;
SET GENERATOR gd_g_functionch TO 1;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_function_ad_ch FOR gd_function
AFTER DELETE POSITION 32000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_functionch, 1);
END
^

CREATE TRIGGER gd_bi_function FOR gd_function
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

/*  NEW.modifydate = 'NOW';*/

  IF (NEW.modulecode IS NULL) then
    NEW.modulecode = 1010001;/*�� ����������*/
  IF (NEW.publicfunction IS NULL) then
    NEW.publicfunction = 0;
END
^


CREATE TRIGGER gd_bu_function FOR gd_function
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
/*  NEW.modifydate = 'NOW';*/
  IF (NEW.modulecode IS NULL) then BEGIN
    IF (OLD.modulecode IS NULL) THEN
      NEW.modulecode = 1010001;
    ELSE
      NEW.modulecode = OLD.modulecode;            
  END
  IF (NEW.publicfunction IS NULL) then BEGIN
    IF (OLD.publicfunction IS NULL) THEN          
      NEW.publicfunction = 0;                     
    ELSE                                          
      NEW.publicfunction = OLD.publicfunction;    
  END
END
^  

CREATE TRIGGER gd_bi_function5 FOR gd_function
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER gd_bu_function5 FOR gd_function
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

CREATE TABLE gd_function_log (
  id          dintkey,
  functionkey dintkey,
  revision    INTEGER,
  script      dscript,
  editorkey   dintkey,
  editiondate deditiondate
);

ALTER TABLE gd_function_log ADD CONSTRAINT gd_pk_function_log_id
  PRIMARY KEY (id);

ALTER TABLE gd_function_log ADD CONSTRAINT gd_fk_function_log_fk
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_function_log ADD CONSTRAINT gd_fk_function_log_ek
  FOREIGN KEY (editorkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER gd_bi_function_log FOR gd_function_log
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE R INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  R = 0;
  SELECT MAX(revision) FROM gd_function_log WHERE functionkey = NEW.functionkey
    INTO :R;
  NEW.revision = COALESCE(:R, 0) + 1;    
END
^

CREATE TRIGGER gd_bu_function_log FOR gd_function_log
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (OLD.revision <> COALESCE(NEW.revision, 0)) THEN
    NEW.revision = OLD.revision;
END
^

CREATE TRIGGER gd_function_au_ch FOR gd_function
AFTER UPDATE POSITION 32000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_functionch, 1);

  IF ((OLD.EDITIONDATE <> NEW.EDITIONDATE) AND (OLD.SCRIPT <> NEW.SCRIPT)) THEN
  BEGIN
    IF (NOT EXISTS (SELECT L.ID FROM GD_FUNCTION_LOG L WHERE L.FUNCTIONKEY = OLD.ID)) THEN
    BEGIN
      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (OLD.ID, OLD.SCRIPT, OLD.EDITORKEY, OLD.EDITIONDATE);

      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE);
    END ELSE
      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE);
  END
END
^

SET TERM ; ^

COMMIT;