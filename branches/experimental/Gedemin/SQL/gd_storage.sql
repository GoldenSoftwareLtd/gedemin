
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_storage.sql

  Abstract


  Author


  Revisions history


*/

CREATE DOMAIN dstoragedata
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 1024;

CREATE DOMAIN dstoragetype
  AS CHAR(1)
  CHECK (VALUE IN ('F', 'V')); /* F -- Folder, V -- Value */

COMMIT;

/*
 *
 */

/*
CREATE TABLE gd_storage (
  id         dintkey,
  parent     dparent,
  lb         dlb,
  rb         drb,
  stype      dstoragetype,
  name       dname,
  data       VARCHAR(80),
  bdata      dstoragedata,

  CONSTRAINT gd_pk_storage PRIMARY KEY (id),
  CONSTRAINT gd_fk_storage_parent FOREIGN KEY (parent)
    REFERENCES gd_storage (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE INDEX gd_x_storage_name ON gd_storage (name);
*/

SET TERM ^ ;

/*
CREATE EXCEPTION gd_e_storage_duplicate_name 'Storage value or folder with given name already exists'
^

CREATE TRIGGER gd_bi_storage FOR gd_storage
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.parent IS NULL) THEN
  BEGIN
    IF (EXISTS(SELECT * FROM gd_storage WHERE UPPER(NEW.name) = UPPER(name) AND parent IS NULL)) THEN
      EXCEPTION gd_e_storage_duplicate_name;
  END ELSE BEGIN
    IF (EXISTS(SELECT * FROM gd_storage WHERE UPPER(NEW.name) = UPPER(name) AND parent = NEW.parent)) THEN
      EXCEPTION gd_e_storage_duplicate_name;
  END
END
^

CREATE TRIGGER gd_bu_storage FOR gd_storage
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE NP INTEGER;
  DECLARE VARIABLE OP INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
    NP = -1;
  ELSE
    NP = NEW.parent;

  IF (OLD.parent IS NULL) THEN
    OP = -1;
  ELSE
    OP = OLD.parent;

  IF ((NP <> OP) OR (NEW.name <> OLD.name)) THEN
  BEGIN
    IF (NEW.parent IS NULL) THEN
    BEGIN
      IF (EXISTS(SELECT * FROM gd_storage WHERE UPPER(NEW.name) = UPPER(name) AND parent IS NULL)) THEN
        EXCEPTION gd_e_storage_duplicate_name;
    END ELSE BEGIN
      IF (EXISTS(SELECT * FROM gd_storage WHERE UPPER(NEW.name) = UPPER(name) AND parent = NEW.parent)) THEN
        EXCEPTION gd_e_storage_duplicate_name;
    END
  END
END
^
*/

SET TERM ; ^

COMMIT;