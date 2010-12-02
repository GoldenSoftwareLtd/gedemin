
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    gd_const.sql

  Abstract

    Константы

  Author

    Anton Smirnov (15.09.2001)

  Revisions history

    Initial  15.09.2001  SAI    Initial version

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

/* 1 бит - 1 - периодичная */
/* 2 бит - 1 - привязан к пользователю */
/* 3 бит - 1 - привязан к клиенту */

CREATE DOMAIN dconsttype
  AS SMALLINT
  DEFAULT 0
  NOT NULL
  CHECK ((VALUE >= 0) AND (VALUE <= 7));

COMMIT;

/* Справочник переменных */

CREATE TABLE gd_const
(
  id               dintkey,
  name             dname,
  comment          dtext120,
  consttype        dconsttype,
  datatype         CHAR(1), /* NULL, S -- string, N -- numeric, D -- Date, Time */

  editorkey        dforeignkey,     /* Кто создал или изменил запись */
  editiondate      deditiondate,    /* Когда создана или изменена запись */

  afull            dsecurity,
  achag            dsecurity,
  aview            dsecurity,

  reserved         dreserved
);

ALTER TABLE gd_const
  ADD CONSTRAINT gd_pk_const PRIMARY KEY (id);

ALTER TABLE gd_const ADD CONSTRAINT gd_fk_editor_const
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE UNIQUE INDEX gd_x_const_name ON gd_const
  /*COMPUTED BY (UPPER(name));*/
  (name);

/*ALTER TABLE gd_const ADD CONSTRAINT gd_uq_name_const
  UNIQUE (name);*/

/* Значения переменных */

CREATE TABLE gd_constvalue
(
  id            dintkey,
  userkey       dforeignkey,
  companykey    dforeignkey,
  constkey      dintkey,
  constdate     date,
  constvalue    dtext120,
  editorkey     dforeignkey,     /* Кто создал или изменил запись */
  editiondate   deditiondate    /* Когда создана или изменена запись */
);

ALTER TABLE gd_constvalue
  ADD CONSTRAINT gd_pk_constvalue PRIMARY KEY (id);

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_user_constvalue
  FOREIGN KEY (userkey) REFERENCES gd_contact(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_oc_constvalue
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_vn_constvalue
  FOREIGN KEY (constkey) REFERENCES gd_const(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_ek_constvalue
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE EXCEPTION gd_e_invalidconstname 'Constant already exists'
^

CREATE TRIGGER gd_bi_const FOR gd_const
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS (SELECT * FROM gd_const WHERE UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_invalidconstname;
  END
END
^

CREATE TRIGGER gd_bu_const FOR gd_const
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_const WHERE UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id)) THEN
  BEGIN
    EXCEPTION gd_e_invalidconstname;
  END
END
^

CREATE TRIGGER gd_bi_constvalue FOR gd_constvalue
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^


COMMIT;


