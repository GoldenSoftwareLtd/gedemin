CREATE TABLE gd_autotask
(
  id               dintkey,
  name             dname,
  description      dtext180,
  functionkey      dforeignkey,      /* ���� ������ -- ����� ����������� ������-������� */
  cmdline          dtext255,         /* ���� ������ -- ��������� ������ ��� ������ ������� ��������� */
  backupfile       dtext255,         /* ���� ������ -- ��� ����� ������ */
  userkey          dforeignkey,      /* ������� ������, ��� ������� ���������. ���� �� ������ -- ��������� ��� �����*/
  exactdate        dtimestamp,       /* ���� � ����� ������������ ���������� ����������. ������ ����� �� ������� �� ������ ���������� �������� */
  monthly          dinteger,
  weekly           dinteger,
  starttime        dtime,            /* ����� ������ ��������� ��� ���������� */
  endtime          dtime,            /* ����� ����� ��������� ��� ����������  */
  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  editorkey        dforeignkey,
  editiondate      deditiondate,
  afull            dsecurity,
  achag            dsecurity,
  aview            dsecurity,
  disabled         ddisabled,
  CONSTRAINT gd_pk_autotask PRIMARY KEY (id),
  CONSTRAINT gd_chk_autotask_monthly CHECK ((monthly BETWEEN -30 AND -1) OR (monthly BETWEEN 1 AND 31)),
  CONSTRAINT gd_chk_autotask_weekly CHECK (weekly BETWEEN 1 AND 7)
);
 
CREATE TABLE gd_autotask_log
(
  id               dintkey,
  autotaskkey      dintkey,
  eventtime        dtimestamp_notnull,
  eventtext        dtext255,            
  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  CONSTRAINT gd_pk_autotask_log PRIMARY KEY (id),
  CONSTRAINT gd_fk_autotask_log_autotaskkey
    FOREIGN KEY (autotaskkey) REFERENCES gd_autotask (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
 );
 
COMMIT;