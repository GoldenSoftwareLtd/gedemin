
/*

   0 прочее
  10 страна
  20 область
  30 район
  40 населенный пункт
  50 район в нас пункте
  60 улица
  70 дом

*/

CREATE DOMAIN dplacetype
  AS VARCHAR(10) CHARACTER SET WIN1251
  DEFAULT ''
  NOT NULL
  COLLATE PXW_CYRL;

CREATE TABLE gd_place (
  id          dintkey,
  parent      dparent,
  lb          dlb,
  rb          drb,
  name        dname,
  placetype   dplacetype,
  telprefix   dtext8,           /* телефонный код места (города ) */
  code        dtext8,           /* код местности*/
  lat         dlat,
  lon         dlon,
  editiondate deditiondate
);

COMMIT;

ALTER TABLE gd_place ADD CONSTRAINT gd_pk_place
  PRIMARY KEY (id);

ALTER TABLE gd_place ADD CONSTRAINT gd_fk_place_parent
  FOREIGN KEY (parent)
  REFERENCES gd_place (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE EXCEPTION gd_e_placeexists 'Place already exists';

SET TERM ^ ;

CREATE TRIGGER gd_bi_place FOR gd_place
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS(SELECT * FROM gd_place WHERE COALESCE(parent, 0) = COALESCE(NEW.parent, 0)
    AND UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_placeexists;
  END
END
^

CREATE TRIGGER gd_bu_place FOR gd_place
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS(SELECT * FROM gd_place WHERE COALESCE(parent, 0) = COALESCE(NEW.parent, 0)
    AND UPPER(name) = UPPER(NEW.name)
    AND ID <> NEW.id)) THEN
  BEGIN
    EXCEPTION gd_e_placeexists;
  END
END
^

SET TERM ; ^

COMMIT;