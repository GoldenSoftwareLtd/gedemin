CREATE TABLE gd_autotask
 (
   id               dintkey,
   name             dname,
   description      dtext180,
   functionkey      dforeignkey,      /* ���� ������ -- ����� ����������� ������-������� */
   autotrkey        dforeignkey,      /* ���� ������ -- ����� ����������� �������������� ������������� �������� */
   reportkey        dforeignkey,      /* ���� ������ -- ����� ����������� ���������� ������ */
   emailgroupkey    dforeignkey,
   emailrecipients  dtext1024,
   emailsmtpkey     dforeignkey,
   emailexporttype  VARCHAR(4),
   cmdline          dtext255,         /* ���� ������ -- ��������� ������ ��� ������ ������� ��������� */
   backupfile       dtext255,         /* ���� ������ -- ��� ����� ������ */
   userkey          dforeignkey,      /* ������� ������, ��� ������� ���������. ���� �� ������ -- ��������� ��� �����*/
   computer         dtext60,
   atstartup        dboolean,
   exactdate        dtimestamp,       /* ���� � ����� ������������ ���������� ����������. ������ ����� ��������� �� ������ ���������� �������� */
   monthly          dinteger,
   weekly           dinteger,
   daily            dboolean,
   starttime        dtime,            /* ����� ������ ��������� ��� ���������� */
   endtime          dtime,            /* ����� ����� ��������� ��� ����������  */
   priority         dinteger_notnull DEFAULT 0, 
   pulse            dinteger,    
   creatorkey       dforeignkey,
   creationdate     dcreationdate,
   editorkey        dforeignkey,
   editiondate      deditiondate,
   afull            dsecurity,
   achag            dsecurity,
   aview            dsecurity,
   disabled         ddisabled,
   CONSTRAINT gd_pk_autotask PRIMARY KEY(id),
   CONSTRAINT gd_fk_autotask_esk
     FOREIGN KEY (emailsmtpkey) REFERENCES gd_smtp(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_fk
     FOREIGN KEY (functionkey) REFERENCES gd_function(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_atrk
     FOREIGN KEY (autotrkey) REFERENCES ac_transaction(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_rk
     FOREIGN KEY (reportkey) REFERENCES rp_reportlist(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_uk
     FOREIGN KEY (userkey) REFERENCES gd_user(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_ck
     FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_ek
     FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_chk_autotask_emailrecipients CHECK(emailrecipients > ''),
   CONSTRAINT gd_chk_autotask_recipients CHECK((emailrecipients > '') OR (emailgroupkey IS NOT NULL)),
   CONSTRAINT gd_chk_autotask_monthly CHECK (monthly BETWEEN -31 AND 31 AND monthly <> 0),
   CONSTRAINT gd_chk_autotask_weekly CHECK (weekly BETWEEN 1 AND 7),
   CONSTRAINT gd_chk_autotask_priority CHECK (priority >= 0),
   CONSTRAINT gd_chk_autotask_time CHECK((starttime IS NULL AND endtime IS NULL) OR (starttime < endtime)),
   CONSTRAINT gd_chk_autotask_cmd CHECK(cmdline > ''),
   CONSTRAINT gd_chk_autotask_backupfile CHECK(backupfile > ''),
   CONSTRAINT gd_chk_autotask_pulse CHECK(pulse >= 0),
   CONSTRAINT gd_chk_autotask_exporttype CHECK(emailexporttype IN ('DOC', 'RTF', 'XLS', 'PDF', 'XML', 'TXT', 'HTM', 'ODS', 'ODT'))
 );
 
SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_autotask FOR gd_autotask
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^ 

CREATE OR ALTER TRIGGER gd_biu_autotask FOR gd_autotask
  BEFORE INSERT OR UPDATE
  POSITION 27000
AS
BEGIN
  IF (NOT NEW.atstartup IS NULL) THEN
  BEGIN
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.exactdate IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.monthly IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.weekly IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.daily IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
  END

  IF (NOT NEW.functionkey IS NULL) THEN
  BEGIN
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.autotrkey IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.reportkey IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
  END

  IF (NOT NEW.cmdline IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.backupfile = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.backupfile IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END
END
^ 

SET TERM ; ^
 
CREATE TABLE gd_autotask_log
(
  id               dintkey,
  autotaskkey      dintkey,
  eventtext        dtext255 NOT NULL,   
  connection_id    dinteger DEFAULT CURRENT_CONNECTION, 
  client_address   dtext60,  
  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  CONSTRAINT gd_pk_autotask_log PRIMARY KEY (id),
  CONSTRAINT gd_fk_autotask_log_autotaskkey
    FOREIGN KEY (autotaskkey) REFERENCES gd_autotask (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_autotask_log_ck
    FOREIGN KEY (creatorkey) REFERENCES gd_contact (id)
    ON UPDATE CASCADE
 );
 
CREATE INDEX gd_x_autotask_log_cnid ON gd_autotask_log (connection_id);
CREATE DESC INDEX gd_x_autotask_log_cd ON gd_autotask_log (creationdate);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_autotask_log FOR gd_autotask_log
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
  IF (NEW.client_address IS NULL) THEN
    NEW.client_address = RDB$GET_CONTEXT('SYSTEM', 'CLIENT_ADDRESS');  
END
^ 

SET TERM ; ^
 
COMMIT;