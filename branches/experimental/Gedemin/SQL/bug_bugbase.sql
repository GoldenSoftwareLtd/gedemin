
/*
 *  ��� ������ � ��������� �� �������� �� ������ � ������
 *  bug_bugbase.
 *
 *
 *
 *
 */

CREATE TABLE bug_bugbase
(
  /* ������������� ������/���������� */
  id             dintkey,

  /* ����� ���������                 */
  subsystem      dtext20 NOT NULL,

  /* ����� ���������                */
  versionfrom    dtext20,
  versionto      dtext20,

  /* ��������� ������                */
  priority       dsmallint,

  /* �������� ������/����������      */
  /* �������� ��������:              */
  /*                                  */
  bugarea        dtext20 NOT NULL,
  /* ��� ������/����������           */
  /* �������� ��������:              */
  /*   �������                        */
  /*   ����� �������                  */
  /*   �������                        */
  /*   �������                        */
  /*   ����������                     */
  bugtype        dtext20 NOT NULL,
  /* ������� �'��������               */
  /* �������� ��������:              */
  /*   Ͳ��˲                         */
  /*   ������                         */
  /*   �����                          */
  /*   �����                          */
  /*   ���Ѩ��                        */
  /*   �� ������������                */
  bugfrequency   dtext20 NOT NULL,
  /* �������� ������                */
  bugdescription dtext1024 NOT NULL,
  /* �� ������� �������               */
  buginstruction dtext1024,

  /* ��� ������ �������              */
  founderkey     dintkey,
  /* ��� ������� � ����              */
  raised         ddate DEFAULT CURRENT_DATE NOT NULL,

  /* ��� �������                      */
  responsiblekey  dintkey,

  /* ���� �����                      */
  /* �������� ��������:              */
  /*   �������                        */
  /*   ��������                       */
  /*   ���������                      */
  /*   ��ղ����                       */
  /*   ��������                       */
  decision       dtext20 NOT NULL,
  /* ��� ���������                  */
  decisiondate   ddate,
  /* ��� �����Ⳣ/������ ��������     */
  fixerkey       dforeignkey,
  /* �������� �� ��������/����������� */
  fixcomment     dtext1024,

  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,

  reserved       dinteger
);

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_pk_bugbase_id
  PRIMARY KEY (id);

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_founderkey
  FOREIGN KEY (founderkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_responsiblekey
  FOREIGN KEY (responsiblekey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_fixerkey
  FOREIGN KEY (fixerkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_bugtype
  CHECK (bugtype IN ('�������', '����� �������', '�������', '�������', '����������'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_bugfrequency
  CHECK (bugfrequency IN ('Ͳ��˲', '������', '�����', '�����', '���Ѩ��', '�� ������������'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_decision
  CHECK (decision IN ('�������', '��������', '���������', '��ղ����', '��������', '��������'));

/* ��� ���� ����� ���� �� �������, ����� ��� ���� ��������� ��� */
/* �����Ⳣ �������, ����� ������ �������� � ���                 */
ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_fixerkey
  CHECK ((decision = '�������' AND fixerkey IS NULL AND decisiondate IS NULL) OR (decision <> '�������' AND NOT fixerkey IS NULL AND NOT decisiondate IS NULL));

/* ������ �������� ������� �����, ��� ��� ���� ������� � ����    */
ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_ddate
  CHECK ((decisiondate IS NULL) OR (decisiondate >= raised));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_priority
  CHECK ((priority IS NULL) OR (priority IN (0, 1, 2, 3, 4, 5)));

SET TERM ^ ;

CREATE TRIGGER bug_bi_bugbase FOR bug_bugbase
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.bugtype = UPPER(NEW.bugtype);
  NEW.bugfrequency = UPPER(NEW.bugfrequency);
  NEW.decision = UPPER(NEW.decision);
END
^

CREATE EXCEPTION bug_e_canntdelete 'Can not delete record not marked for deletion'^

CREATE TRIGGER bug_bd_bugbase FOR bug_bugbase
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.decision <> '��������') THEN
    EXCEPTION bug_e_canntdelete;
END
^

SET TERM ; ^

COMMIT;