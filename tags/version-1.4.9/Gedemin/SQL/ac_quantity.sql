/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    ac_quantity.sql

  Abstract

    An Interbase script for quantity parameter entry.           

  Author

    Dubrovnik Alexander (02.05.2003)

  Revisions history

    Initial  02.05.2003  DAlex    Initial version

  Status

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

  Таблица связка счета с ед.измерения

*****************************************************/

CREATE TABLE ac_accvalue
(
  id          dintkey  PRIMARY KEY,
  accountkey  dmasterkey,
  valuekey    dintkey
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_accvalue
  ON ac_accvalue (accountkey, valuekey);

COMMIT;

ALTER TABLE ac_accvalue
ADD CONSTRAINT fk_ac_accvalue_account
FOREIGN KEY (accountkey)
REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_accvalue
ADD CONSTRAINT fk_ac_accvalue_value
FOREIGN KEY (valuekey)
REFERENCES gd_value(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

  Таблица количестенных показателей проводки

*****************************************************/

CREATE TABLE ac_quantity
(
  id          dintkey  PRIMARY KEY,
  entrykey    dmasterkey,
  valuekey    dintkey,
  quantity    dcurrency
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_quantity
  ON ac_quantity (entrykey, valuekey);

COMMIT;

ALTER TABLE ac_quantity
ADD CONSTRAINT fk_ac_quantity_entry
FOREIGN KEY (entrykey)
REFERENCES ac_entry(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_quantity
ADD CONSTRAINT fk_ac_quantity_accvalue
FOREIGN KEY (valuekey)
REFERENCES gd_value(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;






