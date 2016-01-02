
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    rp_report.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  18.12.00  JKL    Initial version

  Status 
    
*/

/****************************************************

   Таблица для хранения шаблонов отчетов.

*****************************************************/

CREATE TABLE rp_reporttemplate
(
  id             dintkey,
  name           dname,
  description    dtext180,
  templatedata   dreporttemplate,
  templatetype   dtemplatetype,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  editiondate    deditiondate,           /* Дата последнего редактирования */
  editorkey      dintkey,                /* Ссылка на пользователя, который редактировал запись*/
  reserved       dinteger
);

ALTER TABLE rp_reporttemplate
  ADD CONSTRAINT rp_pk_reporttemplate PRIMARY KEY (id);

COMMIT;

CREATE EXCEPTION rp_e_invalidreporttemplate 'Unknown template type';

CREATE UNIQUE INDEX rp_x_reporttemplate_name ON rp_reporttemplate
  (name);

ALTER TABLE rp_reporttemplate ADD CONSTRAINT rp_fk_reporttemplate_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER rp_bi_reporttemplate FOR rp_reporttemplate
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  NEW.templatetype = UPPER(NEW.templatetype);
  IF ((NEW.templatetype <> 'RTF') AND (NEW.templatetype <> 'FR') AND
   (NEW.templatetype <> 'XFR') AND (NEW.templatetype <> 'GRD') AND (NEW.templatetype <> 'FR4')) THEN
    EXCEPTION rp_e_invalidreporttemplate;
END
^

CREATE TRIGGER rp_bi_reporttemplate5 FOR rp_reporttemplate
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER rp_bu_reporttemplate5 FOR rp_reporttemplate
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения групп отчетов.

*****************************************************/

CREATE TABLE rp_reportgroup
(
  id             dintkey,
  parent         dforeignkey,
  name           dname,
  description    dtext180,
  lb             dlb,
  rb             drb,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  editiondate    deditiondate,
  usergroupname  dname DEFAULT '',
  reserved       dinteger
);

ALTER TABLE rp_reportgroup
  ADD CONSTRAINT rp_pk_reportgroup PRIMARY KEY (id);

CREATE UNIQUE INDEX rp_x_reportgroup_ugn ON rp_reportgroup
  (usergroupname);

CREATE UNIQUE INDEX rp_x_reportgroup_lrn ON
  rp_reportgroup (name, parent);

ALTER TABLE rp_reportgroup ADD CONSTRAINT rp_fk_reportgroup_parent
  FOREIGN KEY (parent) REFERENCES rp_reportgroup(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_rpgroupkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup (id) ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportgroup FOR rp_reportgroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
  IF (NEW.usergroupname IS NULL) THEN
    NEW.usergroupname = CAST(NEW.id AS varchar(60));

  RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA', '100');
END
^
SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения списка отчетов.

*****************************************************/

CREATE TABLE rp_reportlist
(
  id                dintkey,                 /* идентификатор                      */
  name              dname,                   /* наименование отчета                */
  description       dtext180,                /* комментарий                        */
  frqrefresh        dinteger DEFAULT 1,      /* частота обновления в днях          */
  reportgroupkey    dintkey,
  paramformulakey   dforeignkey,
  mainformulakey    dintkey,
  eventformulakey   dforeignkey,
  templatekey       dforeignkey,
  IsRebuild         dboolean,
  afull             dsecurity,
  achag             dsecurity,
  aview             dsecurity,
  serverkey         dforeignkey,
  islocalexecute    dboolean DEFAULT 0,
  preview           dboolean DEFAULT 1,
  modalpreview      dboolean_notnull DEFAULT 0,
  globalreportkey   dinteger,               /* Глобальный идентификатор отчета     */
                                            /* Должен задаваться программистом     */
  editiondate       deditiondate,           /* Дата последнего редактирования */
  editorkey         dintkey,                /* Ссылка на пользователя, который редактировал запись*/
  displayinmenu     dboolean DEFAULT 1,     /* Отображать в меню формы */
  reserved          dinteger,
  folderkey         dforeignkey
);

ALTER TABLE rp_reportlist
  ADD CONSTRAINT rp_pk_reportlist PRIMARY KEY (id);

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_groupkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup(id)
  ON UPDATE CASCADE;

CREATE UNIQUE INDEX rp_x_reportlist_namerpgroup
  ON rp_reportlist(name, reportgroupkey);

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_paramfkey
  FOREIGN KEY (paramformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_mainfkey
  FOREIGN KEY (mainformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_eventfkey
  FOREIGN KEY (eventformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_templatefkey
  FOREIGN KEY (templatekey) REFERENCES rp_reporttemplate(id)
  ON UPDATE CASCADE;

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE RP_REPORTLIST ADD CONSTRAINT FK_RP_REPORTLIST_FOLDERKEY
  FOREIGN KEY (FOLDERKEY) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportlist FOR rp_reportlist
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  IF (NEW.islocalexecute IS NULL) THEN
    NEW.islocalexecute = 0;
END
^

CREATE TRIGGER rp_bi_reportlist5 FOR rp_reportlist
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER rp_bu_reportlist5 FOR rp_reportlist
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER gd_ad_documenttype FOR gd_documenttype
  ACTIVE
  AFTER DELETE
  POSITION 20000
AS
BEGIN
  IF (NOT EXISTS(
    SELECT *
    FROM gd_documenttype
    WHERE id <> OLD.id
      AND reportgroupkey = OLD.reportgroupkey)) THEN
  BEGIN
    IF (EXISTS(
      SELECT *
      FROM rp_reportlist l
        JOIN rp_reportgroup g ON l.reportgroupkey = g.id
        JOIN rp_reportgroup g_up ON g.lb >= g_up.lb AND g.rb <= g_up.rb
      WHERE
        g_up.id = OLD.reportgroupkey)) THEN
    BEGIN
      EXCEPTION gd_e_exception 'Перед удалением типа документа следует ' ||
        'удалить или переместить в другую группу связанные с ним отчеты.';
    END

    DELETE FROM rp_reportgroup WHERE id = OLD.reportgroupkey;
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения результатов выполнения функций.

*****************************************************/

CREATE TABLE rp_reportresult
(
  functionkey              dintkey,
  crcparam                 dinteger NOT NULL,
  paramorder               dinteger DEFAULT 0 NOT NULL,
  paramdata                dblob,
  resultdata               dblob,
  createdate               dtimestamp,
  executetime              dtime,
  lastusedate              dtimestamp,
  reserved                 dinteger
);

ALTER TABLE rp_reportresult
  ADD CONSTRAINT rp_pk_reportresult PRIMARY KEY (functionkey, crcparam, paramorder);

COMMIT;

ALTER TABLE rp_reportresult ADD CONSTRAINT rp_fk_reportresult_functionkey
  FOREIGN KEY (functionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

   Таблица для хранения параметров серверов.

*****************************************************/

CREATE TABLE rp_reportserver
(
  id                      dintkey,
  computername            dtext20 NOT NULL,
  resultpath              dtext255,
  starttime               dtime,
  endtime                 dtime,
  frqdataread             dtime,
  actualreport            dinteger DEFAULT 1,
  unactualreport          dinteger DEFAULT 2,
  ibparams                dtext255,
  localstorage            dboolean DEFAULT 1,
  usedorder               dinteger,
  serverport              dintkey DEFAULT 2048,
  reserved                dinteger
);

ALTER TABLE rp_reportserver
  ADD CONSTRAINT rp_pk_reportserver PRIMARY KEY (id);

CREATE UNIQUE INDEX RP_X_REPORTSERVER_NAME
  ON RP_REPORTSERVER (COMPUTERNAME);

ALTER TABLE rp_reportserver ADD CONSTRAINT rp_chk_reportserver_act
  CHECK(actualreport <= unactualreport);

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_serverkey
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportserver FOR rp_reportserver
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF ((NEW.frqdataread < '1:00:00') OR (NEW.frqdataread IS NULL)) THEN
    NEW.frqdataread = '1:00:00';

  IF (NEW.starttime IS NULL) THEN
  BEGIN
    NEW.starttime = '18:00:00';
    NEW.endtime = '21:00:00';
  END

  IF (NEW.endtime IS NULL) THEN
    NEW.endtime = NEW.starttime + 2;
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки сервера отчетов к клиенту.
   Для подключения по умолчанию.

*****************************************************/

CREATE TABLE rp_reportdefaultserver
(
  serverkey                dintkey,
  clientname               dtext20 NOT NULL,
  reserved                 dinteger
);

ALTER TABLE rp_reportdefaultserver
  ADD CONSTRAINT rp_pk_reportdefaultserver PRIMARY KEY (serverkey, clientname);

ALTER TABLE rp_reportdefaultserver ADD CONSTRAINT rp_fk_reportdefaultserver_sk
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

   Таблица для привязки сервера отчетов к клиенту.
   Для подключения по умолчанию.

*****************************************************/

CREATE TABLE rp_additionalfunction
(
  mainfunctionkey                dintkey,
  addfunctionkey                 dintkey,
  reserved                       dinteger
);

ALTER TABLE rp_additionalfunction
  ADD CONSTRAINT rp_pk_additionalfunction PRIMARY KEY (mainfunctionkey, addfunctionkey);

ALTER TABLE rp_additionalfunction ADD CONSTRAINT rp_fk_additionalfunction_mfk
  FOREIGN KEY (mainfunctionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE rp_additionalfunction ADD CONSTRAINT rp_fk_additionalfunction_afk
  FOREIGN KEY (addfunctionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

COMMIT;
