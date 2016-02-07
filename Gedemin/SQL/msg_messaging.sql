
CREATE TABLE msg_box (
  id             dintkey,
  parent         dparent,
  lb             dlb,
  rb             drb,
  name           dname,
  afull          dsecurity,
  reserved       dreserved
);

ALTER TABLE msg_box ADD CONSTRAINT msg_pk_box_id
  PRIMARY KEY (id);

ALTER TABLE msg_box ADD CONSTRAINT msg_fk_parent
  FOREIGN KEY (parent) REFERENCES msg_box (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

SET TERM ^ ;


CREATE TRIGGER msg_bi_box FOR msg_box
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;


COMMIT;

CREATE TABLE msg_message (
  id            dintkey,
  boxkey        dintkey,
  msgtype       dmsgtype,

  msgstart      dtimestamp NOT NULL,
  msgstartdate  COMPUTED (CAST (msgstart AS date)),
  msgstartmonth COMPUTED BY (g_d_formatdatetime('yyyy.mm', msgstart)),
  msgend        dtimestamp,

  subject       dtext254,
  header        dblobtext80,
  body          dblobtext80_1251,
  bdata         dblob4096,

  messageid     dtext60,
  fromid        dtext120,
  fromcontactkey dforeignkey,

  copy          dblobtext80,
  bcc           dblobtext80,

  toid          dtext120,
  tocontactkey  dforeignkey,

  operatorkey   dintkey,

  replykey      dforeignkey,

  cost          dcurrency,      /* кошт тэлефоннага званка */

  attachmentcount smallint,

  afull         dsecurity,
  achag         dsecurity,
  aview         dsecurity,

  reserved      dreserved,

  CHECK (msgtype IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'))
);

/*
входящий звонок	A
исходящий звонок	B
входящее электронное письмо	C
исходящее электронное письмо	D
входящий факс	E
исходящий факс	F
входящее письмо	G
исходящее письмо	H
*/

ALTER TABLE msg_message ADD CONSTRAINT msg_pk_message_id
  PRIMARY KEY (id);

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_boxkey
  FOREIGN KEY (boxkey) REFERENCES msg_box (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_fromck
  FOREIGN KEY (fromcontactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_tock
  FOREIGN KEY (tocontactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_replykey
  FOREIGN KEY (replykey) REFERENCES msg_message (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE INDEX msg_x_message_messageid ON msg_message
  (messageid);

CREATE DESC INDEX msg_x_message_msgstart_d ON msg_message
  (msgstart);

CREATE ASC INDEX msg_x_message_msgstart_a ON msg_message
  (msgstart);

SET TERM ^ ;

CREATE TRIGGER msg_bi_message FOR msg_message
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.attachmentcount IS NULL) THEN
    NEW.attachmentcount = 0;
END
^


SET TERM ; ^

COMMIT;

CREATE TABLE msg_target
(
  messagekey  dintkey,
  contactkey  dintkey,
  viewed      dboolean DEFAULT 0 NOT NULL
);

ALTER TABLE msg_target ADD CONSTRAINT msg_pk_target
  PRIMARY KEY (messagekey, contactkey);

ALTER TABLE msg_target ADD CONSTRAINT msg_fk_target_mk
  FOREIGN KEY (messagekey) REFERENCES  msg_message (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE msg_target ADD CONSTRAINT msg_fk_target_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE msg_attachment (
  id           dintkey,
  messagekey   dmasterkey,
  filename     dtext254,
  bdata        dblob4096,

  reserved     dinteger
);

ALTER TABLE msg_attachment ADD CONSTRAINT msg_pk_attachment_id
  PRIMARY KEY (id);

ALTER TABLE msg_attachment ADD CONSTRAINT msg_fk_attachment_mk
  FOREIGN KEY (messagekey) REFERENCES msg_message (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_attachment FOR msg_attachment
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER msg_ai_attachment FOR msg_attachment
  AFTER INSERT
  POSITION 1000
AS
BEGIN
  UPDATE msg_message SET attachmentcount = attachmentcount + 1
    WHERE id = NEW.messagekey;
END
^

CREATE TRIGGER msg_au_attachment FOR msg_attachment
  AFTER UPDATE
  POSITION 1000
AS
BEGIN
  IF (NEW.messagekey <> OLD.messagekey) THEN
  BEGIN
    UPDATE msg_message SET attachmentcount = attachmentcount + 1
      WHERE id = NEW.messagekey;

    UPDATE msg_message SET attachmentcount = attachmentcount - 1
      WHERE id = OLD.messagekey;
  END
END
^

CREATE TRIGGER msg_ad_attachment FOR msg_attachment
  AFTER DELETE
  POSITION 1000
AS
BEGIN
  UPDATE msg_message SET attachmentcount = attachmentcount - 1
    WHERE id = OLD.messagekey;
END
^

SET TERM ; ^

COMMIT;

/*   */

CREATE TABLE msg_account (
  id           dintkey,
  name         dname,
  userkey      dintkey,
  displayname  dname,
  emailaddress dname,
  pop3server   dtext40,
  pop3port     dSMALLINT DEFAULT 110 NOT NULL,
  smtpserver   dtext40,
  smtpport     dSMALLINT DEFAULT 25 NOT NULL,
  accname      dname,
  accpassword  dname,
  rempassword  dboolean DEFAULT 1 NOT NULL,
  autoreceive  dboolean DEFAULT 1 NOT NULL,
  deleteafter  dboolean DEFAULT 0 NOT NULL,

  reserved     dinteger
);

COMMIT;

ALTER TABLE msg_account ADD CONSTRAINT msg_pk_account_id
  PRIMARY KEY (id);

ALTER TABLE msg_account ADD CONSTRAINT msg_fk_account_uk
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_account FOR msg_account
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE msg_messagerules (
  id             dintkey,
  ruleorder      dSMALLINT,
  name           dname,
  data           dblob80,

  reserved       dinteger
);

ALTER TABLE msg_messagerules ADD CONSTRAINT msg_pk_messagerules
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_messagerules FOR msg_messagerules
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.ruleorder IS NULL) THEN
  BEGIN
    SELECT MAX(ruleorder) FROM msg_messagerules INTO :I;
    IF (:I IS NULL) THEN
      I = 0;
    NEW.ruleorder = :I + 1;
  END
END
^

SET TERM ; ^

COMMIT;

/*

CREATE TABLE msg_feedback (
  id              dintkey,
  
  msgstate        dinteger NOT NULL,
  
  msgtype         dinteger NOT NULL,
  subject
  msgbody
  rating          dinteger,
  
  prevkey
  
  companyname     dname,
  companyid       druid,
  
  contactkey      dforeignkey, 
  contactid       druid,
  contactname     dname,
  contactphone    dphone,
  
  userkey         dforeignkey,
  username        dname,
  
  callback        dboolean_notnull,
  
  toname
  toid
  
  hostname        dname,
  
  posted
  sent
  
  creationdate
  creatorkey
  
  editiondate
  editorkey
  
  CONSTRAINT msg_pk_feedback PRIMARY KEY (id),
  CONSTRAINT msg_fk_feedback_contactkey FOREIGN KEY (contactkey)
    REFERENCES gd_contact (id)
    ON UPDATE CASCADE,
  CONSTRAINT msg_fk_feedback_userkey FOREIGN KEY (userkey)
    REFERENCES gd_user (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT msg_chk_feedback_rating CHECK (rating BETWEEN 0 AND 10)    
);

*/
