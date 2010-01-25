
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    rp_report.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  08.06.2001  JKL    Initial version

  Status 
    
    Draft

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/****************************************************

   Таблица для хранения авторов.

*****************************************************/

CREATE TABLE kn_writer
(
  id            dintkey,

  borndate      dtimestamp,

  name          dtext254,
  firstname     dtext60,
  midlename     dtext60,
  secondname    dtext60,
  subject       dtext1024,
  header        dblobtext80,
  body          dblobtext80_1251,
  bdata         dblob4096,

  reserved      dinteger
);

ALTER TABLE kn_writer
  ADD CONSTRAINT kn_pk_writer PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER kn_before_insert_writer FOR kn_writer
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения информации.

*****************************************************/

CREATE TABLE kn_book
(
  id            dintkey,
  shrift        dtext60,
  shriftowner   dtext60,

  registreddate dtimestamp,

  name          dtext254 NOT NULL,
  shotkeys      dtext254,
  subject       dtext1024,
  header        dblobtext80,
  body          dblobtext80_1251,
  bdata         dblob4096,

  issuetown     dforeignkey,
  issuedate     ddate,
  issuer        dtext60, 

  reserved      dinteger
);

ALTER TABLE kn_book
  ADD CONSTRAINT kn_pk_book PRIMARY KEY (id);

ALTER TABLE kn_book ADD CONSTRAINT kn_fk_book_issuetown
  FOREIGN KEY (issuetown) REFERENCES gd_place(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER kn_before_insert_book FOR kn_book
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки книг к авторам.

*****************************************************/

CREATE TABLE kn_writerbook
(
  bookkey             dintkey,
  writerkey         dintkey,
  orderno        INTEGER,
  reserved       dinteger
);

ALTER TABLE kn_writerbook
  ADD CONSTRAINT kn_pk_writerbook PRIMARY KEY (bookkey,writerkey);

ALTER TABLE kn_writerbook ADD CONSTRAINT kn_fk_writerbook_bookkey
  FOREIGN KEY (bookkey) REFERENCES kn_book(id)
  ON UPDATE CASCADE;

ALTER TABLE kn_writerbook ADD CONSTRAINT kn_fk_writerbook_writerkey
  FOREIGN KEY (writerkey) REFERENCES kn_writer(id)
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

   Таблица для регистрации ссылочной литературы.

*****************************************************/

CREATE TABLE kn_literaturebook
(
  mainbookkey             dintkey,
  basicbookkey         dintkey,
  orderno        INTEGER,
  reserved       dinteger
);

ALTER TABLE kn_literaturebook
  ADD CONSTRAINT kn_pk_literaturebook PRIMARY KEY (mainbookkey,basicbookkey);

ALTER TABLE kn_literaturebook ADD CONSTRAINT kn_fk_lb_mainbookkey
  FOREIGN KEY (mainbookkey) REFERENCES kn_book(id)
  ON UPDATE CASCADE;

ALTER TABLE kn_literaturebook ADD CONSTRAINT kn_fk_lb_basicbookkey
  FOREIGN KEY (basicbookkey) REFERENCES kn_book(id)
  ON UPDATE CASCADE;

COMMIT;


