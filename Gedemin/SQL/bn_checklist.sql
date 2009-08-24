
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    bn_checklist.sql

  Abstract

    ������ �����

  Author

    Anton Smirnov

  Revisions history

    Initial  08.02.2001  Anton    Initial version

    Modification 23.08.2001 Julie 

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* ����� ����� */

CREATE TABLE bn_checklist
(
  documentkey       dintkey,      /* ������ �� ������� ����������  */
  accountkey        dintkey,      /* ��������� ���� ������������� */

  bankkey           dintkey,      /* ���������������� ��������, � ������� ���� ������ */

  owncomptext       dtext180,     /* ����������� �������� (��������� ���-���) */
  owntaxid          dtext20,      /* ����������� ��� */
  owncountry        dtext20,      /* ������ */

  ownbanktext       dtext180,     /* ����������� �������� (��������� ���-���) */
  ownbankcity       dtext20,      /* ����� */
  ownaccount        dbankaccount,      /* ��� ����� */
  ownaccountcode    dtext20,      /* ��� ����� */

  banktext          dtext180,     /* ����� �������� ����� */
  bankcity          dtext20,      /* ����� */
  bankcode          dtext20,      /* ��� ����� */

  amount            dcurrency,    /* ����� �� ��������� */

  proc              dtext20,      /* ��� ��������� */
  oper              dtext20,      /* ��� �������� */
  bankgroup         dtext20,      /* ��� �������� */
  queue             dtext20,      /* ����������� ������� */
  destcodekey       dforeignkey,      /* ���������� ������� (���) */
  destcode          dtext20,      /* ���������� ������� ����� */
  term              ddate,         /* ���� ������� */
  destination       dtext1024     /* ���������� ������� */
);


ALTER TABLE bn_checklist
  ADD CONSTRAINT bn_pk_checklist PRIMARY KEY (documentkey);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON DELETE CASCADE;

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_bankkey
  FOREIGN KEY (bankkey) REFERENCES gd_bank(bankkey);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_destcodekey
  FOREIGN KEY (destcodekey) REFERENCES bn_destcode(id);

COMMIT;

CREATE TABLE bn_checklistline
(
  id                dintkey,
  documentkey       dintkey,      /* ����� � ����������, ������ ������� 
                                     �������������� � ������� GD_DOCUMENT */
  number            dtext20,
  checklistkey      dintkey,      /* ������ �� ������� ����������  */
  accountkey        dintkey,      /* ��������� ���� ���������� */
  accounttext       dbankaccount,
  sumncu            dcurrency
);


ALTER TABLE bn_checklistline
  ADD CONSTRAINT bn_pk_checklistline PRIMARY KEY (id);

ALTER TABLE bn_checklistline ADD CONSTRAINT bn_fk_cll_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON DELETE CASCADE ON UPDATE CASCADE;
  

ALTER TABLE bn_checklistline ADD CONSTRAINT bn_fk_cll_checklistkey
  FOREIGN KEY (checklistkey) REFERENCES bn_checklist(documentkey) ON DELETE CASCADE;

SET TERM ^ ;

/*
CREATE TRIGGER bn_bi_wording FOR bn_wording
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^
*/

/* ����� ������� ������ � ������� ������� ����� ��������� 
   ������ ����� � ��������� */

CREATE TRIGGER bn_ai_checklistline FOR bn_checklistline
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE add_sumncu NUMERIC(15, 4);
BEGIN
  IF (NEW.sumncu IS NULL) THEN
    add_sumncu = 0;
  ELSE
    add_sumncu = NEW.sumncu;

  UPDATE bn_checklist
  SET amount = amount + :add_sumncu
  WHERE documentkey = NEW.checklistkey;

END
^

/* ����� �������� ������� ������� ����� ��������� 
   ����� ����� � ��������� */

CREATE TRIGGER bn_ad_checklistline FOR bn_checklistline
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE old_sumncu NUMERIC(15, 4);
BEGIN
  IF (OLD.sumncu IS NULL) THEN
    old_sumncu = 0;
  ELSE
    old_sumncu = OLD.sumncu;

  UPDATE bn_checklist
    SET amount = amount - :old_sumncu
  WHERE documentkey = OLD.checklistkey;
END
^

/*

  ������ ��������� ��������� ����������� ��������� ��������
  ��� ������� ����� ��������� ������.

*/
CREATE PROCEDURE bn_p_update_checklist(CK INTEGER)
AS
  DECLARE VARIABLE sumncu NUMERIC(15, 4);

BEGIN
  SELECT SUM(sumncu)
  FROM bn_checklistline WHERE checklistkey = :CK
  INTO :sumncu;

  IF (:sumncu IS NULL) THEN sumncu = 0;

  UPDATE bn_checklist 
  SET
    amount = :sumncu
  WHERE documentkey = :CK;
END
^

/*

  ����� ��������� ������ �� ������� ����� ����������� ��������� �������� ���
  ����� ������� �����.

*/
CREATE TRIGGER bn_au_checklistline FOR bn_checklistline
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  EXECUTE PROCEDURE bn_p_update_checklist(NEW.checklistkey);
END
^

SET TERM ; ^

COMMIT;

