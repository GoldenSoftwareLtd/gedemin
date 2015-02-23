
CREATE DOMAIN rp2_dstate AS CHAR(1)
 CHECK(VALUE IN ('L', 'B', 'S', 'F'));

CREATE DOMAIN rp2_dstate_arch AS CHAR(1)
 CHECK(VALUE IN ('I', 'C', 'R'));

CREATE DOMAIN rp2_doptype AS CHAR(1)
 CHECK(VALUE IN ('I', 'U', 'D'));

CREATE TABLE rp2_base (
  id              dintkey,
  name            dname UNIQUE,
  connection_data dtext254,

  CONSTRAINT rp2_pk_base_id PRIMARY KEY (id)
);

SET TERM ^ ;

CREATE TRIGGER rp2_bi_base FOR rp2_base
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

CREATE TABLE rp2_main_base (
  id              dintkey,
  lock_rec        dinteger_notnull DEFAULT 1 UNIQUE,

  CONSTRAINT rp2_pk_main_base_id PRIMARY KEY (ID),
  CONSTRAINT rp2_fk_main_base_id FOREIGN KEY (ID)
    REFERENCES rp2_base (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CHECK (lock_rec = 1)
);

COMMIT;

CREATE TABLE rp2_domain (
  id             dintkey,
  name           dname UNIQUE,
  generator_name dname UNIQUE,

  CONSTRAINT rp2_pk_domain_id PRIMARY KEY (ID)
);

SET TERM ^ ;

CREATE TRIGGER rp2_bi_domain FOR rp2_domain
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

CREATE TABLE rp2_domain_base (
  domainkey  dintkey,
  basekey    dintkey,

  CONSTRAINT rp2_pk_domain_base PRIMARY KEY (domainkey, basekey),
  CONSTRAINT rp2_fk_domain_base_basekey FOREIGN KEY (basekey)
    REFERENCES rp2_base (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT rp2_fk_domain_base_domainkey FOREIGN KEY (domainkey)
    REFERENCES rp2_domain (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp2_aiu_main_base FOR rp2_main_base
  BEFORE INSERT OR UPDATE
  POSITION 100
AS
  DECLARE VARIABLE D dintkey;
BEGIN
  FOR
    SELECT DISTINCT d.id FROM rp2_domain d WHERE
      NOT EXISTS (SELECT * FROM rp2_domain_base r WHERE r.domainkey = d.id AND r.basekey = NEW.id)
    INTO :D
  DO BEGIN
    INSERT INTO rp2_domain_base (basekey, domainkey) VALUES (NEW.id, :D);
  END
END
^

CREATE EXCEPTION rp2_e_cannot_exclude_mainbase 'Can not exclude a main database from domain'
^

CREATE TRIGGER rp2_aud_domain_base FOR rp2_domain_base
  AFTER UPDATE OR DELETE
  POSITION 100
AS
BEGIN
  IF (EXISTS(SELECT * FROM rp2_main_base WHERE id = OLD.basekey)) THEN
  BEGIN
    EXCEPTION rp2_e_cannot_exclude_mainbase;
  END
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE rp2_domain_class (
  id         dintkey,
  domainkey  dintkey,
  name       dname,
  classname  dname,
  subtype    VARCHAR(60),
  tablename  dtablename,
  condition  dtext254,

  CONSTRAINT rp2_pk_domain_class PRIMARY KEY (id),
  CONSTRAINT rp2_fk_domain_class_domainkey FOREIGN KEY (domainkey)
    REFERENCES rp2_domain (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

COMMIT;


/*

  CREATE TABLE rp2_rlog (
    domainkey
    rec_num
    obj_id UNIQUE
    obj_class
    obj_subtype 
    obj_table
    obj_state
    obj_operation
    logged
 
    PRIMARY KEY (domainkey, rec_num)
  )

  CREATE TABLE rp2_rlog_arch (
    domainkey
    rec_num
    obj_id
    obj_class
    obj_subtype 
    obj_table
    obj_state_arch
    obj_operation
    logged

    PRIMARY KEY (domainkey, rec_num)
  )

  CREATE TABLE rp2_rdomain (
    domainkey
    expiration
  )

  CREATE TABLE rp2_rbase (
    basekey
  )

*/
