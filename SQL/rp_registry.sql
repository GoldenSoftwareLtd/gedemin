
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    rp_registry.sql

  Abstract

    Print registry.

  Author

    Anton Smirnov (13.12.2000)

  Revisions history

    Initial  13.12.2000  SAI    Initial version

  Status

    Draft

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE TABLE rp_registry
(
  id	     DINTKEY,	/*      ���������� ����. ����� ������ ����.*/
  parent     dinteger,
  name	     dtext60,	/*	������������ ������� */
/*  reporttype VARCHAR(1),	/*	CHAR(1)	G-������, R - ������, O - ������ ������� ������ */
/*  issystem   dboolean,	/*	dboolean	���� ������� �������������, �� "1",
                                ���� ������������� - "0". ������������ ����� �������
                                ������ ������ = "0". */
  filename   dtext254,	/*	dtext255	���� - ������ */
/*  lastdate   DATE,	/*	���� ���������� ����������. */
  template   dRTF,	/*	������ */
/* userkey    dforeignkey,	/*	������ ��� ����������� ������������ */
  hotkey     dhotkey,   /*	������� ������� ��� ������ */
  isregistry dboolean,  /*      ������������ ��� ������    */
  isquick    dboolean,  /*      ������������ xFastReport    */
  isPrintPreview dboolean,  /*  ������� ���� ��������� ����� ������� */
  afull      dsecurity,
  achag      dsecurity,
  aview      dsecurity,
  reserved   dinteger
);

ALTER TABLE rp_registry
  ADD CONSTRAINT rp_pk_registry PRIMARY KEY (id);

ALTER TABLE rp_registry ADD CONSTRAINT rp_fk_registry_parent
  FOREIGN KEY (parent) REFERENCES rp_registry(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_bi_registry FOR rp_registry
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


