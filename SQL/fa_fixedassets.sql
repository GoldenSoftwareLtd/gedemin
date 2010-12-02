CREATE DOMAIN damortchipher AS
  VARCHAR(6) NOT NULL;

CREATE DOMAIN damortpercent AS
  NUMERIC(5, 2) NOT NULL
  CHECK(VALUE >= 0.00 AND VALUE <= 100.00);

/*
 * ���������� ������ �����������
 *
 *
 */

CREATE TABLE fa_chiper (
  id          dintkey,
  parent      dforeignkey,
  chipher     damortchipher UNIQUE, 
  percent     damortpercent,
  name        dname,
  reserved    dreserved 
);

ALTER TABLE fa_chipher ADD CONSTRAINT  fa_pk_chipher
  PRIMARY KEY (id);

ALTER TABLE fa_chipher ADD CONSTRAINT fa_fk_chipher_parent
  FOREIGN KEY (parent) REFERENCES fa_chipher(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE TRIGGER fa_bi_chipher FOR fa_chipher
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*

�� ������ ������ �������� ������� ��������� ����������� ��������.
��� ��, ���� ����������� �������� ����� ���� ������� ��� ������
����������, ���������� �������� �������, ������������� ������������
�� ����� � ��� �� ���� � ������� ���������� ����� ��������������� 
����������.

� ������������ ��������� �������� �������� ���������� ������� ���
������ �������. � ��� ����������� �������� ������������ ������������ 
� ������ �������� ������� � �������� � ���� ����������� ��������, 
���������� ������������� ��������� �������� �� �����������.

� ����� ������ ��������� ���������� � ��������������� ������� (����
�����������, �������, ���, �������) � ���������� � �������� (����
�����, ���� ������� � ��.)

� ����� ������� ���������� ���������: fa_asset � ������ ���������� ��
������� �������� �������.


*/

 
CREATE TABLE fa_asset (
  goodkey           dintkey,

  amortchipher      dforeignkey,   /* ������ �� ���� �����������      */
  amortpercent      damortpercent, /* ������� ����������� ����������� */
  correctioncoeff   dcorrectioncoeff, /* ���������� �����������       */

  
);


