
/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 1999-2000 by                   **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

SET TERM ^ ;

CREATE TRIGGER gd_db_connect
  ACTIVE
  ON CONNECT
  POSITION 0
AS
  DECLARE VARIABLE ingroup INTEGER = 0;
BEGIN
  SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
    INTO :ingroup;
  RDB$SET_CONTEXT('USER_SESSION', 'GD_INGROUP', :ingroup);
END
^

SET TERM ; ^

COMMIT;
