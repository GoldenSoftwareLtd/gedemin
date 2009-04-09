
/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* Список типовых операций */

CREATE TABLE gd_listtrtype
(
  id                 dintkey,
  parent             dinteger,
  lb                 dlb,
  rb                 drb,
  name               dname,      /* Наименование операции  */
  description        dtext180,   /* Описание операции      */

  isdocument         dboolean DEFAULT 0,   /* Операция только для документа */
                                           /*      (не для позиции)         */

  /* Скрипты */
  script             dscript,

  companykey         dforeignkey,

  disabled           dboolean DEFAULT 0,
  afull              dsecurity,
  achag              dsecurity,
  aview              dsecurity
);

ALTER TABLE gd_listtrtype
  ADD CONSTRAINT gd_pk_listtrtype PRIMARY KEY (id);

COMMIT;

ALTER TABLE gd_listtrtype ADD CONSTRAINT gd_fk_listtrtype_parent
  FOREIGN KEY (parent) REFERENCES gd_listtrtype(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_listtrtype ADD CONSTRAINT gd_fk_listtrtype_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON UPDATE CASCADE;

COMMIT;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_trtypekey
  FOREIGN KEY (trtypekey) REFERENCES gd_listtrtype(id);

SET TERM ^ ;


CREATE TRIGGER gd_bi_listtrtype FOR gd_listtrtype
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



