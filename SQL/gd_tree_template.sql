
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* set windows code page */
SET NAMES WIN1251;

SET SQL DIALECT 3;

CONNECT 'czech:k:\bases\gedemin\etalon.fdb'
  USER 'SYSDBA' PASSWORD 'masterkey';

COMMIT;

/****************************************************/
/**                                                **/
/**   Тестовая таблица для проверки дерева         **/
/**   с интервалами                                **/
/**                                                **/
/****************************************************/
CREATE TABLE tst_treetbl (
  id      dintkey,       /* Уникальный ключ */
  parent  dinteger,      /* Парент на родителя */
  lb      dlb,           /* Левый предел, меньший индекс */
  rb      drb,           /* Правый предел, больший индекс */

  name    dname          /* Наименование поле для примера */
);

COMMIT;

ALTER TABLE tst_treetbl ADD CONSTRAINT tst_pk_treetbl_id
  PRIMARY KEY (id);

ALTER TABLE tst_treetbl ADD CONSTRAINT tst_fk_treetbl_parent
  FOREIGN KEY (parent) REFERENCES tst_treetbl (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE tst_treetbl ADD CONSTRAINT tst_chk_treetbl_tree_limit
  CHECK ((lb <= rb) or ((rb is NULL) and (lb is NULL)));

CREATE DESC INDEX tst_x_treetbl_rb
  ON tst_treetbl(rb);

CREATE ASC INDEX tst_x_treetbl_lb
  ON tst_treetbl(lb);

COMMIT;

SET TERM ^ ;

/****************************************************/
/**                                                **/
/**   Процедура проверяет диапозон для вставки     **/
/**   и раздвигает его если он мал                 **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE tst_p_expandlimit_treetbl (Parent INTEGER, Delta INTEGER,
  LB2 INTEGER, RB2 INTEGER)
RETURNS (LeftBorder INTEGER)
AS
  DECLARE VARIABLE R INTEGER;
  DECLARE VARIABLE L INTEGER;
  DECLARE VARIABLE R2 INTEGER;
  DECLARE VARIABLE MKey INTEGER;
  DECLARE VARIABLE MultiDelta INTEGER;
BEGIN
  /* Получаем границы родителя */
  SELECT rb, lb
  FROM tst_treetbl
  WHERE id = :Parent
  INTO :R, :L;

  /* Получаем крайнюю правую границу детей */
  SELECT MAX(rb)
  FROM tst_treetbl
  WHERE lb > :L AND lb <= :R
  INTO :R2;

  /* Если нет детей устанавливаем левую границу */
  IF (:R2 IS NULL) THEN
    R2 = :L;

  IF (:R - :R2 < :Delta) THEN
  BEGIN
    /* Если места нет раздвигаем */
    /* Диапозон увеличивается в 10 раз */
    MultiDelta = (:R - :L + 1) * 9;

    /* Проверяем удовлетворяет ли нас новый диапазон */
    IF (:Delta > :MultiDelta) THEN
      MultiDelta = :Delta;

    /* Сдвигаем правую границу родителей */
    UPDATE tst_treetbl SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* Сдвигаем обе границы нижних ветвей */
    FOR
      SELECT id
      FROM tst_treetbl
      WHERE lb > :R AND NOT (lb >= :LB2 AND rb <= :RB2)
      ORDER BY lb DESC
      INTO :MKey
    DO
      UPDATE tst_treetbl
        SET lb = lb + :MultiDelta, rb = rb + :MultiDelta
        WHERE id = :MKey;
  END

  /* Присваиваем результат, первый удовлетворяющий элемент */
  LeftBorder = :R2 + 1;
END
^

/****************************************************/
/**                                                **/
/**   Триггер обрабатывающий добавление нового     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER tst_bi_treetbl FOR tst_treetbl
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE R INTEGER;
  DECLARE VARIABLE L INTEGER;
  DECLARE VARIABLE R2 INTEGER;
  DECLARE VARIABLE MULTIDELTA INTEGER;
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.parent IS NULL) THEN
  BEGIN
    /* Если добавление происходит в корень */
    /* Устанавливаем левую границу диапозона */
    SELECT MAX(rb)
    FROM tst_treetbl
    INTO NEW.lb;

    /* Проверяем присвоено ли значение поля */
    IF (NEW.lb IS NULL) THEN
      /* запісаў няма, дадаем новы, першы */
      NEW.lb = 1;
    ELSE
      /* Если есть записи */
      NEW.lb = NEW.lb + 1;

    NEW.rb = NEW.lb;
  END ELSE
  BEGIN
    /* Если добавляем в подуровень */
    /* дадаем падузровень                    */
    /* вызначым мяжу інтэрвала, куды дадаем  */

    EXECUTE PROCEDURE tst_p_expandlimit_treetbl (NEW.parent, 1, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^

CREATE EXCEPTION tst_e_invalidtreetreetbl 'You made an attempt to cycle branch'
^

/****************************************************/
/**                                                **/
/**   Тригер обробатывающий изменение родителя     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER tst_bu_treetbl FOR tst_treetbl
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE OldDelta INTEGER;
  DECLARE VARIABLE L INTEGER;
  DECLARE VARIABLE R INTEGER;
  DECLARE VARIABLE NewL INTEGER;
  DECLARE VARIABLE A INTEGER;
BEGIN
  /* Проверяем факт изменения PARENT */
  IF ((NEW.parent <> OLD.parent) OR
     ((OLD.parent IS NULL) AND NOT (NEW.parent IS NULL)) OR 
     ((NEW.parent IS NULL) AND NOT (OLD.parent IS NULL))) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM tst_treetbl 
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tst_e_invalidtreetreetbl;
    ELSE
    BEGIN
      IF (NEW.parent IS NULL) THEN
      BEGIN
        /* Получаем крайнюю правую границу */
        SELECT MAX(rb)
        FROM tst_treetbl
        WHERE parent IS NULL
        INTO :NewL;
        /* Предпологается что существует хотя бы один элемент с нулл парентом */
        /* Триггер на UPDATE, поэтому условие должно выполняться по идеологии */
        NewL = :NewL + 1;
      END ELSE
      BEGIN
        /* Получаем значение новой левой границы */
        A = OLD.rb - OLD.lb + 1; 
        EXECUTE PROCEDURE tst_p_expandlimit_treetbl (NEW.parent, A, OLD.lb, OLD.rb)
          RETURNING_VALUES :NewL;
      END

      /* Определяем величину сдвига. +1 выполняется в процедуре */
      OldDelta = :NewL - OLD.lb;
      /* Сдвигаем границы основной ветви */
      NEW.lb = OLD.lb + :OldDelta;
      NEW.rb = OLD.rb + :OldDelta;
      /* Сдвигаем границы детей */
      UPDATE tst_treetbl SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
    END
  END
END
^

/****************************************************/
/**                                                **/
/**   Процедура вытягивает количество детей        **/
/**   по Паренту родителя                          **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE tst_p_getchildcount_treetbl (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* Присваиваем начальное значение */
  LastIndex = :FirstIndex + 1;

  /* Вытягиваем детей по паренту */
  FOR
    SELECT id
    FROM tst_treetbl
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    /* Изменяем границы детей */
    EXECUTE PROCEDURE tst_p_getchildcount_treetbl (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + 9;

  /* Изменяем границы родителя */
  UPDATE tst_treetbl SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

/****************************************************/
/**                                                **/
/**   Процедура сжимает интервалы дерева           **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE tst_p_restruct_treetbl 
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* Устанавливаем начало свободного пространства */
  /* Мы не ищем свободного пространства, по причине */
  /* не уникальности индексов для LB, RB. */

  CurrentIndex = 1;

  /* Для всех элементов корневого дерево ... */
  FOR
    SELECT id
    FROM tst_treetbl
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы для детей */
    EXECUTE PROCEDURE tst_p_getchildcount_treetbl (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END
END
^

SET TERM ; ^

COMMIT;

