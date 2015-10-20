
SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_db_connect
  ACTIVE
  ON CONNECT
  POSITION 0
AS
  DECLARE VARIABLE ingroup INTEGER = 0;
  DECLARE VARIABLE userkey INTEGER = 0;
  DECLARE VARIABLE contactkey INTEGER = 0;
BEGIN
  SELECT FIRST 1 id, contactkey, ingroup 
  FROM gd_user 
  WHERE ibname = CURRENT_USER
  INTO :userkey, :contactkey, :ingroup;
  RDB$SET_CONTEXT('USER_SESSION', 'GD_USERKEY', :userkey);
  RDB$SET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY', :contactkey);
  RDB$SET_CONTEXT('USER_SESSION', 'GD_INGROUP', :ingroup);
END
^

SET TERM ; ^

COMMIT;
