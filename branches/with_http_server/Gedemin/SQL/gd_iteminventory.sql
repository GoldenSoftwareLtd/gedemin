
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_iteminvent.sql

  Abstract

    ����� ������� �� �������� ���

  Author

    Michael Shoihet (23 december 2000)

  Revisions history

    Initial  23.12.00  MSH    Initial version

  Status

    Draft

*/

/*********************************************************/
/*    ������� ��� �������� ����� ����� ���               */
/*    gd_inventitemcard                                  */
/*********************************************************/

CREATE TABLE gd_inventitemcard(
  id               dintkey,                 /* ���������� ����                     */
  goodkey          dintkey,                 /* ������ �� ������� � ����������� ��� */
  contactkey       dintkey,                 /* ������ �� ������� � ���������       */
  quantity         dquantity,               /* ���������� ���                      */
  sumncu           dcurrency,               /* ����� � ���                         */
  sumcurr          dcurrency,               /* ����� � ������                      */
  currkey          dforeignkey,                 /* ������ �� ������                    */

  disabled         dboolean DEFAULT 0,      /* ���������                           */
  afull            dsecurity
);

COMMIT;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_pk_inventitemcard_id
  PRIMARY KEY (id);

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_inventitemcard FOR gd_inventitemcard
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/*********************************************************/
/*       ������� �������� ������������                   */
/*       gd_doccontact                                   */
/*********************************************************/

CREATE TABLE gd_doccontact(
  id               dintkey,          /* ���������� ����                        */
  documentkey      dintkey,          /* ������ �� ��������                     */
  contactkey       dintkey,          /* ������ �� �������                      */
  contacttype      dcontacttype,     /* ��� ����������� D - �������,� -��������*/

  afull            dsecurity
);

COMMIT;

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_pk_doccontact_id
  PRIMARY KEY(id);

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_fk_doccontact_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_fk_doccontact_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_doccontact FOR gd_doccontact
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/***************************************************************/

/*********************************************************/
/*       ������� �������� ������� �� �������� ���        */
/*       gd_goodposition                                 */
/*********************************************************/

CREATE TABLE gd_goodposition(
  id               dintkey,          /* ���������� ����                        */
  documentkey      dintkey,          /* ������ �� ��������                     */
  sourcecardkey    dforeignkey,          /* ������ �� ����� ����� ��� (��������)   */
  destcardkey      dforeignkey,          /* ������ �� ����� ����� ��� (����������) */
  quantity         dquantity,        /* ����������                             */
  sumncu           dcurrency,        /* ����� � ���                            */
  sumcurr          dcurrency,        /* ����� � ������                         */
  currkey          dforeignkey,          /* ������ �� ������                       */

  reserved         dinteger
);

COMMIT;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_pk_goodposition_id
  PRIMARY KEY (id);

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_sourcecard
  FOREIGN KEY (sourcecardkey) REFERENCES gd_inventitemcard(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_destcard
  FOREIGN KEY (destcardkey) REFERENCES gd_inventitemcard(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodpos FOR gd_goodposition
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;
