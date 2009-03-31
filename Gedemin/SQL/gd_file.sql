
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2001 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE DOMAIN DFILETYPE AS CHAR(1) NOT NULL CHECK (VALUE IN('D','F'));

COMMIT;

CREATE TABLE gd_file
(
  id              dintkey,
  /* Левая (верхняя) граница. Одновременно может использоваться */
  /* как второй уникальный индекс, если группы и список */
  /* находятся в разных таблицах */
  lb              dlb,
  rb              drb,          /* Правая (нижняя) граница */

  parent          dparent,
  filetype        dfiletype,    /* D - директория, F - файл  */
  name            dfilename NOT NULL, /* _мя файла без пуцi     */
  datasize        dinteger,          /* размер файла */
  data            dblob4096,         /* данные сжатые */
  crc             dinteger,          /* код для проверки содержимого файла */
  description     dtext80,           /* описание сод файла */
 
  afull           dsecurity,           /* права доступа                   */
  achag           dsecurity,
  aview           dsecurity,

  creatorkey      dintkey,             /* хто стварыў дакумент            */
  creationdate    dcreationdate,       /* дата _ час стварэньня           */
  editorkey       dintkey,             /* хто рэдактаваў                  */
  editiondate     deditiondate,        /* дата _ час рэдактаваньня        */
  reserved        dreserved

);


COMMIT;

ALTER TABLE gd_file
  ADD CONSTRAINT gd_pk_file PRIMARY KEY (id);

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_parent
  FOREIGN KEY (parent) REFERENCES gd_file(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;


COMMIT;

CREATE EXCEPTION gd_e_invalidfilename 'You entered invalid file name!';

COMMIT;

SET TERM ^ ;

/*
  При вставке и обновлении записи автоматически инициализируем
  поля Дата создания и Дата редактирования, если программист не
  присвоил их самостоятельно.
*/

CREATE TRIGGER gd_bi_file FOR gd_file
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.creatorkey IS NULL) THEN
    NEW.creatorkey = 650002;
  IF (NEW.creationdate IS NULL) THEN
    NEW.creationdate = CURRENT_TIMESTAMP;

  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;

  IF (NEW.parent IS NULL) THEN
  BEGIN
    SELECT id FROM gd_file
    WHERE parent IS NULL AND UPPER(name) = UPPER(NEW.name)
    INTO :id;
  END
  ELSE
  BEGIN
    SELECT id FROM gd_file
    WHERE parent = NEW.parent AND UPPER(name) = UPPER(NEW.name)
    INTO :id;
  END

  IF (:id IS NOT NULL) THEN
    EXCEPTION gd_e_InvalidFileName;

END
^

CREATE TRIGGER gd_bu_file FOR gd_file
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    SELECT id FROM gd_file
    WHERE parent IS NULL AND UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id
    INTO :id;
  END
  ELSE
  BEGIN
    SELECT id FROM gd_file
    WHERE parent = NEW.parent AND UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id
    INTO :id; 
  END

  IF (:id IS NOT NULL) THEN
    EXCEPTION gd_e_InvalidFileName;

END
^

SET TERM ; ^

COMMIT;
