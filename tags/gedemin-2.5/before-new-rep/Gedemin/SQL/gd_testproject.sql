
CREATE TABLE GD_CONTACT (
       ID                   DINTKEY,
       PARENT               DINTKEY,
       NAME                 DNAME
);

CREATE UNIQUE INDEX XPKGD_CONTACT ON GD_CONTACT
(
       ID
);


ALTER TABLE GD_CONTACT
       ADD PRIMARY KEY (ID);


CREATE TABLE MSG_MESSAGE (
       ID                   DINTKEY,
       PROJECTKEY           DINTKEY,
       CONTACTKEY           DINTKEY,
       SUBJECT              DTEXT120
);

CREATE UNIQUE INDEX XPKMSG_MESSAGE ON MSG_MESSAGE
(
       ID
);


ALTER TABLE MSG_MESSAGE
       ADD PRIMARY KEY (ID);


CREATE TABLE PR_ACTIONTYPE (
       ID                   DINTKEY,
       NAME                 DNAME,
       EXECUTETIMEPLAN      CHAR(18)
);

CREATE UNIQUE INDEX XPKPR_ACTIONTYPE ON PR_ACTIONTYPE
(
       ID
);


ALTER TABLE PR_ACTIONTYPE
       ADD PRIMARY KEY (ID);


CREATE TABLE PRJ_ACTION (
       ID                   DINTKEY,
       PROJECTTYPEKEY       DINTKEY,
       PROJECTKEY           DINTKEY,
       NAME                 DNAME,
       STATE                CHAR(18),
       CREATEDATE           DTIMESTAMP,
       STARTDATE            DTIMESTAMP,
       FINISHDATE           DTIMESTAMP,
       EXECUTETIMEPLAN      DTIMESTAMP,
       EXECUTETIMEFACT      DTIMESTAMP
);

CREATE UNIQUE INDEX XPKPRJ_ACTION ON PRJ_ACTION
(
       ID
);


ALTER TABLE PRJ_ACTION
       ADD PRIMARY KEY (ID);


CREATE TABLE PRJ_ACTIONCONTACT (
       CONTACTKEY           DINTKEY,
       ACTIONKEY            DINTKEY
);

CREATE UNIQUE INDEX XPKPRJ_ACTIONCONTACT ON PRJ_ACTIONCONTACT
(
       CONTACTKEY,
       ACTIONKEY
);


ALTER TABLE PRJ_ACTIONCONTACT
       ADD PRIMARY KEY (CONTACTKEY, ACTIONKEY);


CREATE TABLE PRJ_ACTIONDURATION (
       ACTIONKEY            DINTKEY,
       STARTTIME            DTIMESTAMP NOT NULL,
       FINISHTIME           DTIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX XPKPRJ_ACTIONDURATION ON PRJ_ACTIONDURATION
(
       ACTIONKEY
);


ALTER TABLE PRJ_ACTIONDURATION
       ADD PRIMARY KEY (ACTIONKEY);


CREATE TABLE PRJ_ACTIONLINK (
       LINKKEY              DINTKEY,
       SOURCEKEY            DINTKEY
);

CREATE UNIQUE INDEX XPKPRJ_ACTIONLINK ON PRJ_ACTIONLINK
(
       LINKKEY,
       SOURCEKEY
);


ALTER TABLE PRJ_ACTIONLINK
       ADD PRIMARY KEY (LINKKEY, SOURCEKEY);


CREATE TABLE PRJ_PROJECT (
       ID                   DINTKEY,
       CONTACTKEY           DINTKEY,
       PARENT               DINTKEY,
       NAME                 DNAME
);

CREATE UNIQUE INDEX XPKPRJ_PROJECT ON PRJ_PROJECT
(
       ID
);


ALTER TABLE PRJ_PROJECT
       ADD PRIMARY KEY (ID);


CREATE TABLE PRJ_PROJECTACTIONTYPE (
       PROJECTTYPEKEY       DINTKEY,
       ACTIONTYPEKEY        DINTKEY
);

CREATE UNIQUE INDEX XPKPRJ_PROJECTACTIONTYPE ON PRJ_PROJECTACTIONTYPE
(
       PROJECTTYPEKEY,
       ACTIONTYPEKEY
);


ALTER TABLE PRJ_PROJECTACTIONTYPE
       ADD PRIMARY KEY (PROJECTTYPEKEY, ACTIONTYPEKEY);


CREATE TABLE PRJ_PROJECTTYPE (
       ID                   DINTKEY,
       PARENT               DINTKEY,
       NAME                 DNAME
);

CREATE UNIQUE INDEX XPKPRJ_PROJECTTYPE ON PRJ_PROJECTTYPE
(
       ID
);


ALTER TABLE PRJ_PROJECTTYPE
       ADD PRIMARY KEY (ID);


ALTER TABLE GD_CONTACT
       ADD FOREIGN KEY (PARENT)
                             REFERENCES GD_CONTACT;


ALTER TABLE MSG_MESSAGE
       ADD FOREIGN KEY (PROJECTKEY)
                             REFERENCES PRJ_PROJECT;


ALTER TABLE MSG_MESSAGE
       ADD FOREIGN KEY (CONTACTKEY)
                             REFERENCES GD_CONTACT;


ALTER TABLE PRJ_ACTION
       ADD FOREIGN KEY (PROJECTTYPEKEY)
                             REFERENCES PRJ_PROJECTTYPE;


ALTER TABLE PRJ_ACTION
       ADD FOREIGN KEY (PROJECTKEY)
                             REFERENCES PRJ_PROJECT;


ALTER TABLE PRJ_ACTIONCONTACT
       ADD FOREIGN KEY (ACTIONKEY)
                             REFERENCES PRJ_ACTION;


ALTER TABLE PRJ_ACTIONCONTACT
       ADD FOREIGN KEY (CONTACTKEY)
                             REFERENCES GD_CONTACT;


ALTER TABLE PRJ_ACTIONDURATION
       ADD FOREIGN KEY (ACTIONKEY)
                             REFERENCES PRJ_ACTION;


ALTER TABLE PRJ_ACTIONLINK
       ADD FOREIGN KEY (SOURCEKEY)
                             REFERENCES PRJ_ACTION;


ALTER TABLE PRJ_ACTIONLINK
       ADD FOREIGN KEY (LINKKEY)
                             REFERENCES PRJ_ACTION;


ALTER TABLE PRJ_PROJECT
       ADD FOREIGN KEY (CONTACTKEY)
                             REFERENCES GD_CONTACT;


ALTER TABLE PRJ_PROJECT
       ADD FOREIGN KEY (PARENT)
                             REFERENCES PRJ_PROJECT;


ALTER TABLE PRJ_PROJECTACTIONTYPE
       ADD FOREIGN KEY (ACTIONTYPEKEY)
                             REFERENCES PR_ACTIONTYPE;


ALTER TABLE PRJ_PROJECTACTIONTYPE
       ADD FOREIGN KEY (PROJECTTYPEKEY)
                             REFERENCES PRJ_PROJECTTYPE;


ALTER TABLE PRJ_PROJECTTYPE
       ADD FOREIGN KEY (PARENT)
                             REFERENCES PRJ_PROJECTTYPE;



CREATE EXCEPTION ERWIN_PARENT_INSERT_RESTRICT "Cannot INSERT Parent table because Child table exists.";
CREATE EXCEPTION ERWIN_PARENT_UPDATE_RESTRICT "Cannot UPDATE Parent table because Child table exists.";
CREATE EXCEPTION ERWIN_PARENT_DELETE_RESTRICT "Cannot DELETE Parent table because Child table exists.";
CREATE EXCEPTION ERWIN_CHILD_INSERT_RESTRICT "Cannot INSERT Child table because Parent table does not exist.";
CREATE EXCEPTION ERWIN_CHILD_UPDATE_RESTRICT "Cannot UPDATE Child table because Parent table does not exist.";
CREATE EXCEPTION ERWIN_CHILD_DELETE_RESTRICT "Cannot DELETE Child table because Parent table does not exist.";


CREATE TRIGGER tD_GD_CONTACT FOR GD_CONTACT AFTER DELETE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* DELETE trigger on GD_CONTACT */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* GD_CONTACT R/23 PRJ_ACTIONCONTACT ON PARENT DELETE RESTRICT */
    select count(*)
      from PRJ_ACTIONCONTACT
      where
        /*  %JoinFKPK(PRJ_ACTIONCONTACT,OLD," = "," and") */
        PRJ_ACTIONCONTACT.CONTACTKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_DELETE_RESTRICT;
    END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_GD_CONTACT FOR GD_CONTACT AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on GD_CONTACT */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* GD_CONTACT R/23 PRJ_ACTIONCONTACT ON PARENT UPDATE RESTRICT */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    select count(*)
      from PRJ_ACTIONCONTACT
      where
        /*  %JoinFKPK(PRJ_ACTIONCONTACT,OLD," = "," and") */
        PRJ_ACTIONCONTACT.CONTACTKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_UPDATE_RESTRICT;
    END
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* GD_CONTACT R/9 PRJ_PROJECT ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_PROJECT
      set
        /*  %JoinFKPK(PRJ_PROJECT,NEW," = ",",") */
        PRJ_PROJECT.CONTACTKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_PROJECT,OLD," = "," and") */
        PRJ_PROJECT.CONTACTKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* GD_CONTACT R/7 GD_CONTACT ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update GD_CONTACT
      set
        /*  %JoinFKPK(GD_CONTACT,NEW," = ",",") */
        GD_CONTACT.PARENT = NEW.ID
      where
        /*  %JoinFKPK(GD_CONTACT,OLD," = "," and") */
        GD_CONTACT.PARENT = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* GD_CONTACT R/4 MSG_MESSAGE ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update MSG_MESSAGE
      set
        /*  %JoinFKPK(MSG_MESSAGE,NEW," = ",",") */
        MSG_MESSAGE.CONTACTKEY = NEW.ID
      where
        /*  %JoinFKPK(MSG_MESSAGE,OLD," = "," and") */
        MSG_MESSAGE.CONTACTKEY = OLD.ID;
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tD_PR_ACTIONTYPE FOR PR_ACTIONTYPE AFTER DELETE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* DELETE trigger on PR_ACTIONTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PR_ACTIONTYPE R/14 PRJ_PROJECTACTIONTYPE ON PARENT DELETE RESTRICT */
    select count(*)
      from PRJ_PROJECTACTIONTYPE
      where
        /*  %JoinFKPK(PRJ_PROJECTACTIONTYPE,OLD," = "," and") */
        PRJ_PROJECTACTIONTYPE.ACTIONTYPEKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_DELETE_RESTRICT;
    END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PR_ACTIONTYPE FOR PR_ACTIONTYPE AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PR_ACTIONTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PR_ACTIONTYPE R/14 PRJ_PROJECTACTIONTYPE ON PARENT UPDATE RESTRICT */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    select count(*)
      from PRJ_PROJECTACTIONTYPE
      where
        /*  %JoinFKPK(PRJ_PROJECTACTIONTYPE,OLD," = "," and") */
        PRJ_PROJECTACTIONTYPE.ACTIONTYPEKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_UPDATE_RESTRICT;
    END
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tD_PRJ_ACTION FOR PRJ_ACTION AFTER DELETE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* DELETE trigger on PRJ_ACTION */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_ACTION R/24 PRJ_ACTIONCONTACT ON PARENT DELETE RESTRICT */
    select count(*)
      from PRJ_ACTIONCONTACT
      where
        /*  %JoinFKPK(PRJ_ACTIONCONTACT,OLD," = "," and") */
        PRJ_ACTIONCONTACT.ACTIONKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_DELETE_RESTRICT;
    END

    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_ACTION R/20 PRJ_ACTIONDURATION ON PARENT DELETE CASCADE */
    delete from PRJ_ACTIONDURATION
      where
        /*  %JoinFKPK(PRJ_ACTIONDURATION,OLD," = "," and") */
        PRJ_ACTIONDURATION.ACTIONKEY = OLD.ID;

    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_ACTION R/19 PRJ_ACTIONLINK ON PARENT DELETE CASCADE */
    delete from PRJ_ACTIONLINK
      where
        /*  %JoinFKPK(PRJ_ACTIONLINK,OLD," = "," and") */
        PRJ_ACTIONLINK.SOURCEKEY = OLD.ID;

    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_ACTION R/18 PRJ_ACTIONLINK ON PARENT DELETE CASCADE */
    delete from PRJ_ACTIONLINK
      where
        /*  %JoinFKPK(PRJ_ACTIONLINK,OLD," = "," and") */
        PRJ_ACTIONLINK.LINKKEY = OLD.ID;


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PRJ_ACTION FOR PRJ_ACTION AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PRJ_ACTION */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_ACTION R/24 PRJ_ACTIONCONTACT ON PARENT UPDATE RESTRICT */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    select count(*)
      from PRJ_ACTIONCONTACT
      where
        /*  %JoinFKPK(PRJ_ACTIONCONTACT,OLD," = "," and") */
        PRJ_ACTIONCONTACT.ACTIONKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_UPDATE_RESTRICT;
    END
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_ACTION R/20 PRJ_ACTIONDURATION ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_ACTIONDURATION
      set
        /*  %JoinFKPK(PRJ_ACTIONDURATION,NEW," = ",",") */
        PRJ_ACTIONDURATION.ACTIONKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_ACTIONDURATION,OLD," = "," and") */
        PRJ_ACTIONDURATION.ACTIONKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_ACTION R/19 PRJ_ACTIONLINK ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_ACTIONLINK
      set
        /*  %JoinFKPK(PRJ_ACTIONLINK,NEW," = ",",") */
        PRJ_ACTIONLINK.SOURCEKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_ACTIONLINK,OLD," = "," and") */
        PRJ_ACTIONLINK.SOURCEKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_ACTION R/18 PRJ_ACTIONLINK ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_ACTIONLINK
      set
        /*  %JoinFKPK(PRJ_ACTIONLINK,NEW," = ",",") */
        PRJ_ACTIONLINK.LINKKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_ACTIONLINK,OLD," = "," and") */
        PRJ_ACTIONLINK.LINKKEY = OLD.ID;
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tI_PRJ_ACTIONCONTACT FOR PRJ_ACTIONCONTACT AFTER INSERT AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* INSERT trigger on PRJ_ACTIONCONTACT */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_ACTION R/24 PRJ_ACTIONCONTACT ON CHILD INSERT RESTRICT */
    select count(*)
      from PRJ_ACTION
      where
        /* %JoinFKPK(NEW,PRJ_ACTION," = "," and") */
        NEW.ACTIONKEY = PRJ_ACTION.ID into numrows;
    IF (
      /* %NotnullFK(NEW," is not null and") */
      
      numrows = 0
    ) THEN
    BEGIN
      EXCEPTION ERWIN_CHILD_INSERT_RESTRICT;
    END

    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* GD_CONTACT R/23 PRJ_ACTIONCONTACT ON CHILD INSERT RESTRICT */
    select count(*)
      from GD_CONTACT
      where
        /* %JoinFKPK(NEW,GD_CONTACT," = "," and") */
        NEW.CONTACTKEY = GD_CONTACT.ID into numrows;
    IF (
      /* %NotnullFK(NEW," is not null and") */
      
      numrows = 0
    ) THEN
    BEGIN
      EXCEPTION ERWIN_CHILD_INSERT_RESTRICT;
    END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PRJ_ACTIONCONTACT FOR PRJ_ACTIONCONTACT AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PRJ_ACTIONCONTACT */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_ACTION R/24 PRJ_ACTIONCONTACT ON CHILD UPDATE RESTRICT */
  select count(*)
    from PRJ_ACTION
    where
      /* %JoinFKPK(NEW,PRJ_ACTION," = "," and") */
      NEW.ACTIONKEY = PRJ_ACTION.ID into numrows;
  IF (
    /* %NotnullFK(NEW," is not null and") */
    
    numrows = 0
  ) THEN
  BEGIN
    EXCEPTION ERWIN_CHILD_UPDATE_RESTRICT;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* GD_CONTACT R/23 PRJ_ACTIONCONTACT ON CHILD UPDATE RESTRICT */
  select count(*)
    from GD_CONTACT
    where
      /* %JoinFKPK(NEW,GD_CONTACT," = "," and") */
      NEW.CONTACTKEY = GD_CONTACT.ID into numrows;
  IF (
    /* %NotnullFK(NEW," is not null and") */
    
    numrows = 0
  ) THEN
  BEGIN
    EXCEPTION ERWIN_CHILD_UPDATE_RESTRICT;
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PRJ_PROJECT FOR PRJ_PROJECT AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PRJ_PROJECT */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECT R/11 PRJ_ACTION ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_ACTION
      set
        /*  %JoinFKPK(PRJ_ACTION,NEW," = ",",") */
        PRJ_ACTION.PROJECTKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_ACTION,OLD," = "," and") */
        PRJ_ACTION.PROJECTKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECT R/8 MSG_MESSAGE ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update MSG_MESSAGE
      set
        /*  %JoinFKPK(MSG_MESSAGE,NEW," = ",",") */
        MSG_MESSAGE.PROJECTKEY = NEW.ID
      where
        /*  %JoinFKPK(MSG_MESSAGE,OLD," = "," and") */
        MSG_MESSAGE.PROJECTKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECT R/5 PRJ_PROJECT ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_PROJECT
      set
        /*  %JoinFKPK(PRJ_PROJECT,NEW," = ",",") */
        PRJ_PROJECT.PARENT = NEW.ID
      where
        /*  %JoinFKPK(PRJ_PROJECT,OLD," = "," and") */
        PRJ_PROJECT.PARENT = OLD.ID;
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tI_PRJ_PROJECTACTIONTYPE FOR PRJ_PROJECTACTIONTYPE AFTER INSERT AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* INSERT trigger on PRJ_PROJECTACTIONTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PR_ACTIONTYPE R/14 PRJ_PROJECTACTIONTYPE ON CHILD INSERT RESTRICT */
    select count(*)
      from PR_ACTIONTYPE
      where
        /* %JoinFKPK(NEW,PR_ACTIONTYPE," = "," and") */
        NEW.ACTIONTYPEKEY = PR_ACTIONTYPE.ID into numrows;
    IF (
      /* %NotnullFK(NEW," is not null and") */
      
      numrows = 0
    ) THEN
    BEGIN
      EXCEPTION ERWIN_CHILD_INSERT_RESTRICT;
    END

    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_PROJECTTYPE R/13 PRJ_PROJECTACTIONTYPE ON CHILD INSERT RESTRICT */
    select count(*)
      from PRJ_PROJECTTYPE
      where
        /* %JoinFKPK(NEW,PRJ_PROJECTTYPE," = "," and") */
        NEW.PROJECTTYPEKEY = PRJ_PROJECTTYPE.ID into numrows;
    IF (
      /* %NotnullFK(NEW," is not null and") */
      
      numrows = 0
    ) THEN
    BEGIN
      EXCEPTION ERWIN_CHILD_INSERT_RESTRICT;
    END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PRJ_PROJECTACTIONTYPE FOR PRJ_PROJECTACTIONTYPE AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PRJ_PROJECTACTIONTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PR_ACTIONTYPE R/14 PRJ_PROJECTACTIONTYPE ON CHILD UPDATE RESTRICT */
  select count(*)
    from PR_ACTIONTYPE
    where
      /* %JoinFKPK(NEW,PR_ACTIONTYPE," = "," and") */
      NEW.ACTIONTYPEKEY = PR_ACTIONTYPE.ID into numrows;
  IF (
    /* %NotnullFK(NEW," is not null and") */
    
    numrows = 0
  ) THEN
  BEGIN
    EXCEPTION ERWIN_CHILD_UPDATE_RESTRICT;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECTTYPE R/13 PRJ_PROJECTACTIONTYPE ON CHILD UPDATE RESTRICT */
  select count(*)
    from PRJ_PROJECTTYPE
    where
      /* %JoinFKPK(NEW,PRJ_PROJECTTYPE," = "," and") */
      NEW.PROJECTTYPEKEY = PRJ_PROJECTTYPE.ID into numrows;
  IF (
    /* %NotnullFK(NEW," is not null and") */
    
    numrows = 0
  ) THEN
  BEGIN
    EXCEPTION ERWIN_CHILD_UPDATE_RESTRICT;
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tD_PRJ_PROJECTTYPE FOR PRJ_PROJECTTYPE AFTER DELETE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* DELETE trigger on PRJ_PROJECTTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
    /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
    /* PRJ_PROJECTTYPE R/13 PRJ_PROJECTACTIONTYPE ON PARENT DELETE RESTRICT */
    select count(*)
      from PRJ_PROJECTACTIONTYPE
      where
        /*  %JoinFKPK(PRJ_PROJECTACTIONTYPE,OLD," = "," and") */
        PRJ_PROJECTACTIONTYPE.PROJECTTYPEKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_DELETE_RESTRICT;
    END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

CREATE TRIGGER tU_PRJ_PROJECTTYPE FOR PRJ_PROJECTTYPE AFTER UPDATE AS
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* UPDATE trigger on PRJ_PROJECTTYPE */
DECLARE VARIABLE numrows INTEGER;
BEGIN
  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECTTYPE R/25 PRJ_ACTION ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_ACTION
      set
        /*  %JoinFKPK(PRJ_ACTION,NEW," = ",",") */
        PRJ_ACTION.PROJECTTYPEKEY = NEW.ID
      where
        /*  %JoinFKPK(PRJ_ACTION,OLD," = "," and") */
        PRJ_ACTION.PROJECTTYPEKEY = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECTTYPE R/15 PRJ_PROJECTTYPE ON PARENT UPDATE CASCADE */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    update PRJ_PROJECTTYPE
      set
        /*  %JoinFKPK(PRJ_PROJECTTYPE,NEW," = ",",") */
        PRJ_PROJECTTYPE.PARENT = NEW.ID
      where
        /*  %JoinFKPK(PRJ_PROJECTTYPE,OLD," = "," and") */
        PRJ_PROJECTTYPE.PARENT = OLD.ID;
  END

  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
  /* PRJ_PROJECTTYPE R/13 PRJ_PROJECTACTIONTYPE ON PARENT UPDATE RESTRICT */
  IF
    /* %JoinPKPK(OLD,NEW," <> "," or ") */
    (OLD.ID <> NEW.ID) THEN
  BEGIN
    select count(*)
      from PRJ_PROJECTACTIONTYPE
      where
        /*  %JoinFKPK(PRJ_PROJECTACTIONTYPE,OLD," = "," and") */
        PRJ_PROJECTACTIONTYPE.PROJECTTYPEKEY = OLD.ID into numrows;
    IF (numrows > 0) THEN
    BEGIN
      EXCEPTION ERWIN_PARENT_UPDATE_RESTRICT;
    END
  END


  /* ERwin Builtin Wed Mar 13 15:38:58 2002 */
END !!

