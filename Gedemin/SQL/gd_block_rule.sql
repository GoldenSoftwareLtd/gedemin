
/*

  Copyright (c) 2001-2008 by Golden Software of Belarus


  Script

    gd_block_rule.sql

  Abstract
  
    Таблицы, триггеры, хранимые процедуры 
    механизма блокировки периода

  Author

    Alex Stav
*/

CREATE TABLE GD_BLOCK_RULE 
(
  ID                    DINTKEY,                     /*Первичный ключ*/
  NAME                  DNAME,                       /*Наименование правила*/
  ORDR                  DINTEGER_NOTNULL,            /*Порядковый номер правила*/
  DISABLED              DDISABLED DEFAULT 0          /*Правило отключено*/
);

COMMIT;

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT UNQ1_GD_BLOCK_RULE UNIQUE (ORDR);

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT PK_GD_BLOCK_RULE PRIMARY KEY (ID);

GRANT ALL ON GD_BLOCK_RULE TO ADMINISTRATOR;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER GD_BI_BLOCK_RULE FOR GD_BLOCK_RULE
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
end
^

SET TERM ; ^

COMMIT;
