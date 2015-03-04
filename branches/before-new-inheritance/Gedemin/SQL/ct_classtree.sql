
CREATE DOMAIN dunitname AS VARCHAR(52) NOT NULL;
CREATE DOMAIN dobjectname AS VARCHAR(52) NOT NULL;

COMMIT;

CREATE TABLE ct_unit (
  id         dintkey,
  name       dunitname,
  filename   dtext254,
  comment    BLOB SUB_TYPE 1 SEGMENT SIZE  256 CHARACTER SET WIN1251,
  source     BLOB SUB_TYPE 1 SEGMENT SIZE 4096 CHARACTER SET WIN1251,
  reserved   dinteger
);

ALTER TABLE ct_unit ADD CONSTRAINT ct_pk_unit_id
  PRIMARY KEY (id);

SET TERM ^ ;

CREATE TRIGGER ct_before_insert FOR ct_unit
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
  BEGIN
      NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  END
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE ct_uses (
  unitkey    dintkey,
  useskey    dintkey
);

ALTER TABLE ct_uses ADD CONSTRAINT ct_pk_uses
  PRIMARY KEY (unitkey, useskey);

ALTER TABLE ct_uses ADD CONSTRAINT ct_fk_uses_unitkey
  FOREIGN KEY (unitkey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE ct_uses ADD CONSTRAINT ct_fk_uses_useskey
  FOREIGN KEY (useskey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_var (
  unitkey     dintkey,
  name        dobjectname,
  decloration BLOB SUB_TYPE 1 SEGMENT SIZE  256 CHARACTER SET WIN1251,
  comment     BLOB SUB_TYPE 1 SEGMENT SIZE  256 CHARACTER SET WIN1251,
  reserved    dinteger
);

ALTER TABLE ct_var ADD CONSTRAINT ct_pk_var
  PRIMARY KEY (unitkey, name);

ALTER TABLE ct_var ADD CONSTRAINT ct_fk_var_unitkey
  FOREIGN KEY (unitkey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_const (
  unitkey     dintkey,
  name        dobjectname,
  decloration dtext254,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_const ADD CONSTRAINT ct_pk_const
  PRIMARY KEY (unitkey, name);

ALTER TABLE ct_const ADD CONSTRAINT ct_fk_const_unitkey
  FOREIGN KEY (unitkey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_routine (
  unitkey     dintkey,
  name        dobjectname,
  decloration dtext254,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_routine ADD CONSTRAINT ct_pk_routine
  PRIMARY KEY (unitkey, name);

ALTER TABLE ct_routine ADD CONSTRAINT ct_fk_routine_unitkey
  FOREIGN KEY (unitkey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_class (
  unitkey     dintkey,
  name        dobjectname UNIQUE,
  parent      dobjectname,
  decloration BLOB SUB_TYPE 1 SEGMENT SIZE 256,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_class ADD CONSTRAINT ct_pk_class
  PRIMARY KEY (unitkey, name);

ALTER TABLE ct_class ADD CONSTRAINT ct_fk_class_unitkey
  FOREIGN KEY (unitkey) REFERENCES ct_unit (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE ct_class ADD CONSTRAINT ct_fk_class_parent
  FOREIGN KEY (parent) REFERENCES ct_class (name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_property (
  class       dobjectname UNIQUE,
  name        dobjectname,
  decloration dtext80,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_property ADD CONSTRAINT ct_fk_property_class
  FOREIGN KEY (class) REFERENCES ct_class (name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_field (
  class       dobjectname UNIQUE,
  name        dobjectname,
  decloration dtext80,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_field ADD CONSTRAINT ct_fk_field_class
  FOREIGN KEY (class) REFERENCES ct_class (name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE ct_method (
  class       dobjectname UNIQUE,
  name        dobjectname,
  decloration dtext254,
  comment     dtext254,
  reserved    dinteger
);

ALTER TABLE ct_method ADD CONSTRAINT ct_fk_method_class
  FOREIGN KEY (class) REFERENCES ct_class (name)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

SET TERM ; ^

COMMIT;