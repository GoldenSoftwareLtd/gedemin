
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    bn_checklist.sql

  Abstract

    Реестр чеков

  Author

    Anton Smirnov

  Revisions history

    Initial  08.02.2001  Anton    Initial version

    Modification 23.08.2001 Julie 

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* Реест чеков */

CREATE TABLE bn_checklist
(
  documentkey       dintkey,      /* ссылка на таблицу документов  */
  accountkey        dintkey,      /* расчетный счет чекодержателя */

  bankkey           dintkey,      /* корреспонирующая компания, с которой идет расчет */

  owncomptext       dtext180,     /* собственная компания (текстовая инф-ция) */
  owntaxid          dtext20,      /* собственный УНН */
  owncountry        dtext20,      /* страна */

  ownbanktext       dtext180,     /* собственная компания (текстовая инф-ция) */
  ownbankcity       dtext20,      /* город */
  ownaccount        dbankaccount,      /* код банка */
  ownaccountcode    dtext20,      /* код банка */

  banktext          dtext180,     /* текст названия банка */
  bankcity          dtext20,      /* город */
  bankcode          dtext20,      /* код банка */

  amount            dcurrency,    /* сумма по поручению */

  proc              dtext20,      /* вид обработки */
  oper              dtext20,      /* вид операции */
  bankgroup         dtext20,      /* вид операции */
  queue             dtext20,      /* очередность платежа */
  destcodekey       dforeignkey,      /* назначение платежа (код) */
  destcode          dtext20,      /* назначение платежа текст */
  term              ddate,         /* срок платежа */
  destination       dtext1024     /* назначение платежа */
);


ALTER TABLE bn_checklist
  ADD CONSTRAINT bn_pk_checklist PRIMARY KEY (documentkey);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON DELETE CASCADE;

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_bankkey
  FOREIGN KEY (bankkey) REFERENCES gd_bank(bankkey);

ALTER TABLE bn_checklist ADD CONSTRAINT bn_fk_chl_destcodekey
  FOREIGN KEY (destcodekey) REFERENCES bn_destcode(id);

COMMIT;

CREATE TABLE bn_checklistline
(
  id                dintkey,
  documentkey       dintkey,      /* связь с документом, каждая позиция 
                                     регистрируется в таблице GD_DOCUMENT */
  number            dtext20,
  checklistkey      dintkey,      /* ссылка на таблицу документов  */
  accountkey        dintkey,      /* расчетный счет чекодателя */
  accounttext       dbankaccount,
  sumncu            dcurrency
);


ALTER TABLE bn_checklistline
  ADD CONSTRAINT bn_pk_checklistline PRIMARY KEY (id);

ALTER TABLE bn_checklistline ADD CONSTRAINT bn_fk_cll_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON DELETE CASCADE ON UPDATE CASCADE;
  

ALTER TABLE bn_checklistline ADD CONSTRAINT bn_fk_cll_checklistkey
  FOREIGN KEY (checklistkey) REFERENCES bn_checklist(documentkey) ON DELETE CASCADE;

SET TERM ^ ;

/*
CREATE TRIGGER bn_bi_wording FOR bn_wording
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^
*/

/* После вставки записи в позицию реестра чеков обновляем 
   общуюю сумму в заголовке */

CREATE TRIGGER bn_ai_checklistline FOR bn_checklistline
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE add_sumncu NUMERIC(15, 4);
BEGIN
  IF (NEW.sumncu IS NULL) THEN
    add_sumncu = 0;
  ELSE
    add_sumncu = NEW.sumncu;

  UPDATE bn_checklist
  SET amount = amount + :add_sumncu
  WHERE documentkey = NEW.checklistkey;

END
^

/* После удажения позиции реестра чеков обновляем 
   общую сумму в заголовке */

CREATE TRIGGER bn_ad_checklistline FOR bn_checklistline
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE old_sumncu NUMERIC(15, 4);
BEGIN
  IF (OLD.sumncu IS NULL) THEN
    old_sumncu = 0;
  ELSE
    old_sumncu = OLD.sumncu;

  UPDATE bn_checklist
    SET amount = amount - :old_sumncu
  WHERE documentkey = OLD.checklistkey;
END
^

/*

  Данная процедура позволяет пересчитать суммарные значения
  для реестра чеков заданного ключем.

*/
CREATE PROCEDURE bn_p_update_checklist(CK INTEGER)
AS
  DECLARE VARIABLE sumncu NUMERIC(15, 4);

BEGIN
  SELECT SUM(sumncu)
  FROM bn_checklistline WHERE checklistkey = :CK
  INTO :sumncu;

  IF (:sumncu IS NULL) THEN sumncu = 0;

  UPDATE bn_checklist 
  SET
    amount = :sumncu
  WHERE documentkey = :CK;
END
^

/*

  После изменения строки по реестру чеков пересчитаем суммарные значения для
  этого реестра чеков.

*/
CREATE TRIGGER bn_au_checklistline FOR bn_checklistline
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  EXECUTE PROCEDURE bn_p_update_checklist(NEW.checklistkey);
END
^

SET TERM ; ^

COMMIT;

