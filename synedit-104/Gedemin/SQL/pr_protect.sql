
/*

  Copyright (c) 2000 by Golden Software of Belarus


  Script


  Abstract


  Author


  Revisions history


  Status 

    
*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/*
 * ��� ������� ������ ��������� ����� ����������� ��
 * ���������� ��������������� ����� � ��������� � ����
 * ������.
 *
 */

CREATE TABLE pr_regnumber
(
  id             dintkey,
  companykey     dintkey,              /* ��������-���������� */
  goodkey        dintkey,              /* ��������� */
  regnumber      VARCHAR(20) NOT NULL, /* ��������������� ����� */
  regnumberdate  ddate DEFAULT CURRENT_DATE,
  contactkey     dforeignkey,          /* ���������� ���� */
  operatorkey    dintkey,
  reserved       dinteger,
  comment        DTEXT1024 collate PXW_CYRL,  /* ����������� ������� */
  KEYCOUNT       dinteger  
);

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_pk_regnumber_id
  PRIMARY KEY (id);

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_ck
  FOREIGN KEY (companykey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_gk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE;

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

/*
  ���� ������ �������� ������ ���� ���������
  � ��� ���� � ��������??
*/

CREATE UNIQUE INDEX pr_x_regnumber_ckgk
  ON pr_regnumber
(
  companykey,
  goodkey
);

SET TERM ^ ;

CREATE TRIGGER pr_bi_regnumber FOR pr_regnumber
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

/*

  ������ ��������� ������������ �� ������ ����� ����������� � ����.

*/

CREATE TABLE pr_key
(
  regnumberkey     dintkey,
  code             VARCHAR(20) NOT NULL, /* ���, ������� ��� ������� ������������ */
  licence          VARCHAR(20) NOT NULL, /* ��������, ������� �� ������� */
  licencedate      DDATE NOT NULL,       /* ����, ����� ������������� �������� */
  operatorkey      dintkey
);

ALTER TABLE pr_key ADD CONSTRAINT pr_fk_key_regnumberkey
  FOREIGN KEY (regnumberkey) REFERENCES pr_regnumber (id);

ALTER TABLE pr_key ADD CONSTRAINT pr_fk_key_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

