
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    st_setting.sql 

  Abstract


  Author
    JKL

  Revisions history


*/

/*********************************************************/
/** ���������� ������� ��������� �������� ������������� **/
/*********************************************************/

CREATE TABLE st_settingstate (
  id         dintkey,
  status     dinteger NOT NULL,		/* 0-�� �����������, 1-������������, 2-�� ���������� 3-����������� */
  statedate  dtimestamp NOT NULL, 
  comment    dblobtext80_1251
);

ALTER TABLE st_settingstate ADD CONSTRAINT st_pk_settingstate
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER st_bi_settingstate FOR st_settingstate
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  IF (NEW.statedate IS NULL) THEN
    NEW.statedate = 'now';
END
^

SET TERM ; ^

COMMIT;
