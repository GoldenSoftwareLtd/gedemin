CREATE TABLE gd_backgroup
(
  id            dintkey  PRIMARY KEY,
  groupdate     dtimestamp,
  description   dintkey
 );

COMMIT;

CREATE TABLE gd_backversion
(
  id            dintkey  PRIMARY KEY,
  classkey      dintkey,
  versiondate   dtimestamp,
  backdescr     dblobtext80
 );

ALTER TABLE gd_backversion
ADD CONSTRAINT fk_gd_backversion
FOREIGN KEY (classkey)
REFERENCES evt_object(id);

COMMIT;

CREATE TABLE gd_backup
(
  id            dintkey  PRIMARY KEY,
  savedate      dtimestamp,
  revdate      dtimestamp,
  recid         dinteger,
  versionkey    dintkey,
  groupkey      dintkey,
  objectstream  dblob1024
 );

ALTER TABLE gd_backup
ADD CONSTRAINT fk_gd_backup_v
FOREIGN KEY (versionkey)
REFERENCES gd_backversion(id);

ALTER TABLE gd_backup
ADD CONSTRAINT fk_gd_backup_g
FOREIGN KEY (groupkey)
REFERENCES gd_backgroup(id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_backup FOR gd_backup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  new.savedate = CURRENT_TIMESTAMP;
END ^

SET TERM ; ^

COMMIT;
            

