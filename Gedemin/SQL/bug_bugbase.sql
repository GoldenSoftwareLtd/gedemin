
/*
 *  Усе памылкі і пажаданьні да праграмы мы збіраем у табліцы
 *  bug_bugbase.
 *
 *
 *
 *
 */

CREATE TABLE bug_bugbase
(
  /* ідэнтыфікатар памылкі/пажаданьня */
  id             dintkey,

  /* назва падсістэмы                 */
  subsystem      dtext20 NOT NULL,

  /* вэрсія падсістэмы                */
  versionfrom    dtext20,
  versionto      dtext20,

  /* прыярытэт памылкі                */
  priority       dsmallint,

  /* вобласць памылкі/пажаданьня      */
  /* магчымыя значэньні:              */
  /*                                  */
  bugarea        dtext20 NOT NULL,
  /* тып памылкі/пажаданьня           */
  /* магчымыя значэньні:              */
  /*   ЗРАБІЦЬ                        */
  /*   ТРЭБА ЗРАБІЦЬ                  */
  /*   НЕДАХОП                        */
  /*   ПАМЫЛКА                        */
  /*   КАТАСТРОФА                     */
  bugtype        dtext20 NOT NULL,
  /* частата з'яўленьня               */
  /* магчымыя значэньні:              */
  /*   НІКОЛІ                         */
  /*   ЗРЭДКУ                         */
  /*   ЧАСАМ                          */
  /*   ЧАСТА                          */
  /*   ЗАЎСЁДЫ                        */
  /*   НЕ ПРЫКЛАДАЕЦЦА                */
  bugfrequency   dtext20 NOT NULL,
  /* апісаньне памылкі                */
  bugdescription dtext1024 NOT NULL,
  /* як вызваць памылку               */
  buginstruction dtext1024,

  /* хто знайшоў памылку              */
  founderkey     dintkey,
  /* калі ўнесена ў базу              */
  raised         ddate DEFAULT CURRENT_DATE NOT NULL,

  /* хто адказны                      */
  responsiblekey  dintkey,

  /* стан запісу                      */
  /* магчымыя значэньні:              */
  /*   АДКРЫТА                        */
  /*   ЗРОБЛЕНА                       */
  /*   САСТАРЭЛА                      */
  /*   АДХІЛЕНА                       */
  /*   ЧАСТКОВА                       */
  decision       dtext20 NOT NULL,
  /* калі выпраўлена                  */
  decisiondate   ddate,
  /* хто выправіў/прыняў рашэньне     */
  fixerkey       dforeignkey,
  /* каментар да рашэньня/выпраўленьня */
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
  CHECK (bugtype IN ('ЗРАБІЦЬ', 'ТРЭБА ЗРАБІЦЬ', 'НЕДАХОП', 'ПАМЫЛКА', 'КАТАСТРОФА'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_bugfrequency
  CHECK (bugfrequency IN ('НІКОЛІ', 'ЗРЭДКУ', 'ЧАСАМ', 'ЧАСТА', 'ЗАЎСЁДЫ', 'НЕ ПРЫКЛАДАЕЦЦА'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_decision
  CHECK (decision IN ('АДКРЫТА', 'ЗРОБЛЕНА', 'САСТАРЭЛА', 'АДХІЛЕНА', 'ЧАСТКОВА', 'ВЫДАЛЕНА'));

/* калі стан запісу іншы за АДКРЫТА, трэба каб было пазначана хто */
/* выправіў памылку, альбо прыняў рашэньне і калі                 */
ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_fixerkey
  CHECK ((decision = 'АДКРЫТА' AND fixerkey IS NULL AND decisiondate IS NULL) OR (decision <> 'АДКРЫТА' AND NOT fixerkey IS NULL AND NOT decisiondate IS NULL));

/* нельга выправіць памылку раней, чым яна была ўнесена ў базу    */
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
  IF (OLD.decision <> 'ВЫДАЛЕНА') THEN
    EXCEPTION bug_e_canntdelete;
END
^

SET TERM ; ^

COMMIT;