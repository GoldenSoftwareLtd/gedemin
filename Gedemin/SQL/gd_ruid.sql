
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
  CHECK(
    (id >= 147000000 AND xid >= 147000000)
    OR
    (id < 147000000 AND dbid = 17 AND id = xid)
  );

ALTER TABLE gd_ruid ADD CONSTRAINT gd_uniq_ruid
  UNIQUE (xid, dbid);

COMMIT;

SET TERM ^ ;

CREATE OR ALTER PROCEDURE GD_P_GETRUID(ID DFOREIGNKEY)
  RETURNS (XID DFOREIGNKEY, DBID DFOREIGNKEY)
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

CREATE OR ALTER PROCEDURE GD_P_GETID(XID DFOREIGNKEY, DBID DFOREIGNKEY)
  RETURNS (ID DFOREIGNKEY)
AS
BEGIN
  IF (:XID < 147000000 OR :DBID = 17) THEN
  BEGIN
    ID = :XID;
  END ELSE
  BEGIN
    ID = NULL;

    SELECT id
    FROM gd_ruid
    WHERE xid=:XID AND dbid=:DBID
    INTO :ID;

    IF (ID IS NULL) THEN
    BEGIN
      EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
        :XID || ', DBID = ' || :DBID || '.';
    END
  END

  SUSPEND;
END
^

SET TERM ; ^

CREATE TABLE gd_available_id (
  id_from       dintkey,
  id_to         dintkey,
  
  CONSTRAINT gd_pk_available_id PRIMARY KEY (id_from, id_to),
  CONSTRAINT gd_chk_available_id CHECK (id_from <= id_to)
);

COMMIT;

SET TERM ^ ;

CREATE OR ALTER PROCEDURE gd_p_getnextid_ex
  RETURNS(id DFOREIGNKEY)
AS
  DECLARE VARIABLE id_from DFOREIGNKEY;
  DECLARE VARIABLE id_to DFOREIGNKEY;
  DECLARE VARIABLE limit_id DFOREIGNKEY;
  DECLARE VARIABLE rc INTEGER = 0;
  DECLARE VARIABLE delta DFOREIGNKEY = 1;
BEGIN
  id = COALESCE(RDB$GET_CONTEXT('USER_SESSION', 'GD_CURRENT_ID'), 0);
  limit_id = COALESCE(RDB$GET_CONTEXT('USER_SESSION', 'GD_LIMIT_ID'), 0);

  IF (:id > 0 AND :id <= :limit_id) THEN
    RDB$SET_CONTEXT('USER_SESSION', 'GD_CURRENT_ID', :id + 1);
  ELSE BEGIN
    id = -1;

    FOR
      SELECT id_from, id_to
      FROM gd_available_id
      INTO :id_from, :id_to
    DO BEGIN
      IF ((:id_to - :id_from + 1) <= :delta) THEN
        IN AUTONOMOUS TRANSACTION DO
        BEGIN
          DELETE FROM gd_available_id WHERE id_from = :id_from AND id_to = :id_to;
          rc = ROW_COUNT;
        END
      ELSE BEGIN
        IN AUTONOMOUS TRANSACTION DO
        BEGIN
          UPDATE gd_available_id SET id_from = :id_from + :delta WHERE id_from = :id_from AND id_to = :id_to;
          rc = ROW_COUNT;
        END
        id_to = :id_from + (:delta - 1);
      END

      IF (:rc = 1) THEN
      BEGIN
        id = :id_from;

        RDB$SET_CONTEXT('USER_SESSION', 'GD_CURRENT_ID', :id + 1);
        RDB$SET_CONTEXT('USER_SESSION', 'GD_LIMIT_ID', :id_to);

        LEAVE;
      END

      WHEN ANY DO
      BEGIN
        id = -1;
      END
    END

    IF (id = -1) THEN
    BEGIN
      id_to = GEN_ID(gd_g_unique, 1);
      /*
      id = :id_to - 100 + 1;
      RDB$SET_CONTEXT('USER_SESSION', 'GD_CURRENT_ID', :id + 1);
      RDB$SET_CONTEXT('USER_SESSION', 'GD_LIMIT_ID', :id_to);
      */
    END
  END
END
^

CREATE OR ALTER PROCEDURE gd_p_getnextid
  RETURNS(id DFOREIGNKEY)
AS
BEGIN
  EXECUTE PROCEDURE gd_p_getnextid_ex
    RETURNING_VALUES :id;  

  SUSPEND;
END
^

/*
CREATE OR ALTER TRIGGER gd_db_disconnect_save_id
  ACTIVE
  ON DISCONNECT
  POSITION 32000
AS
  DECLARE VARIABLE id_from INTEGER;
  DECLARE VARIABLE id_to INTEGER;
BEGIN
  id_from = COALESCE(RDB$GET_CONTEXT('USER_SESSION', 'GD_CURRENT_ID'), 0);
  id_to = COALESCE(RDB$GET_CONTEXT('USER_SESSION', 'GD_LIMIT_ID'), 0);
  
  IF (:id_from > 0 AND :id_from <= :id_to) THEN
    IN AUTONOMOUS TRANSACTION DO
      INSERT INTO gd_available_id (id_from, id_to) VALUES (:id_from, :id_to);
END
^  
*/

SET TERM ; ^
