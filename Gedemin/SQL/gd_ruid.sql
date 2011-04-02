
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2001 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE TABLE gd_ruid
(
  id         dintkey,
  xid        dintkey,
  dbid       dintkey,
  modified   TIMESTAMP NOT NULL,
  editorkey  dforeignkey,

  CONSTRAINT gd_pk_ruid_id PRIMARY KEY (id),
  CONSTRAINT gd_fk_ruid_ek FOREIGN KEY (editorkey)
    REFERENCES gd_people (contactkey)
    ON UPDATE CASCADE
    ON DELETE SET NULL 
);

ALTER TABLE gd_ruid ADD CONSTRAINT gd_chk_ruid_etalon
  CHECK((xid >= 147000000) OR ((dbid = 17) AND (id = xid)));

CREATE UNIQUE INDEX gd_x_ruid_xid ON gd_ruid(xid, dbid);
COMMIT;

SET TERM ^ ;

CREATE OR ALTER PROCEDURE GD_P_GETRUID(ID INTEGER)
  RETURNS (XID INTEGER, DBID INTEGER)
AS
BEGIN
  XID = NULL;
  DBID = NULL;

  IF (NOT :ID IS NULL) THEN
  BEGIN
    IF (:ID < 147000000) THEN
    BEGIN
      XID = :ID;
      DBID = 17;
    END ELSE
    BEGIN
      SELECT xid, dbid
      FROM gd_ruid
      WHERE id=:ID
      INTO :XID, :DBID;

      IF (XID IS NULL) THEN
      BEGIN
        XID = ID;
        DBID = GEN_ID(gd_g_dbid, 0);

        INSERT INTO gd_ruid(id, xid, dbid, modified, editorkey)
          VALUES(:ID, :XID, :DBID, CURRENT_TIMESTAMP, NULL);
      END
    END
  END

  SUSPEND;
END
^

CREATE EXCEPTION gd_e_invalid_ruid 'Invalid ruid specified'
^

CREATE PROCEDURE GD_P_GETID(XID INTEGER, DBID INTEGER)
  RETURNS (ID INTEGER)
AS
BEGIN
  ID = NULL;

  SELECT id
  FROM gd_ruid
  WHERE xid=:XID AND dbid=:DBID
  INTO :ID;

  IF (ID IS NULL) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid;
  END

  SUSPEND;
END
^

SET TERM ; ^

