
/* для шаблона используются метки */
/* ::PREFIX - префикс названия */
/* ::NAME - название без префикса */
/* ::TABLENAME - название */
  
/*SET TERM ^ ;*/

/****************************************************/
/**                                                **/
/**   Процедура проверяет диапозон для вставки     **/
/**   и раздвигает его если он мал                 **/
/**                                                **/
/****************************************************/

CREATE PROCEDURE ::PREFIX_p_expandlimit_::NAME (Parent INTEGER, Delta INTEGER,
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
  FROM ::TABLENAME
  WHERE id = :Parent
  INTO :R, :L;

  /* Получаем крайнюю правую границу детей */
  SELECT MAX(rb)
  FROM ::TABLENAME
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
    UPDATE ::TABLENAME SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* Сдвигаем обе границы нижних ветвей */
    FOR
      SELECT id
      FROM ::TABLENAME
      WHERE lb > :R AND NOT (lb >= :LB2 AND rb <= :RB2)
      ORDER BY lb DESC
      INTO :MKey
    DO
      UPDATE ::TABLENAME
        SET lb = lb + :MultiDelta, rb = rb + :MultiDelta
        WHERE id = :MKey;
  END

  /* Присваиваем результат, первый удовлетворяющий элемент */
  LeftBorder = :R2 + 1;
END
^
COMMIT
^

/****************************************************/
/**                                                **/
/**   Триггер обрабатывающий добавление нового     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER ::PREFIX_before_insert_::NAME10 FOR ::TABLENAME
  BEFORE INSERT
  POSITION 10
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
    FROM ::TABLENAME
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

    EXECUTE PROCEDURE ::PREFIX_p_expandlimit_::NAME (NEW.parent, 1, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^
COMMIT
^

CREATE EXCEPTION ::PREFIX_e_invalidtree::NAME 'Совершена попытка зациклить ветвь.'
^
COMMIT
^


/****************************************************/
/**                                                **/
/**   Тригер обробатывающий изменение родителя     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER ::PREFIX_before_update_::NAME10 FOR ::TABLENAME
  BEFORE UPDATE
  POSITION 10
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
    IF (EXISTS (SELECT * FROM ::TABLENAME 
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION ::PREFIX_e_invalidtree::NAME;
    ELSE
    BEGIN
      IF (NEW.parent IS NULL) THEN
      BEGIN
        /* Получаем крайнюю правую границу */
        SELECT MAX(rb)
        FROM ::TABLENAME
        WHERE parent IS NULL
        INTO :NewL;
        /* Предпологается что существует хотя бы один элемент с нулл парентом */
        /* Триггер на UPDATE, поэтому условие должно выполняться по идеологии */
        NewL = :NewL + 1;
      END ELSE
      BEGIN
        /* Получаем значение новой левой границы */
        A = OLD.rb - OLD.lb + 1; 
        EXECUTE PROCEDURE ::PREFIX_p_expandlimit_::NAME (NEW.parent, A, OLD.lb, OLD.rb)
          RETURNING_VALUES :NewL;
      END

      /* Определяем величину сдвига. +1 выполняется в процедуре */
      OldDelta = :NewL - OLD.lb;
      /* Сдвигаем границы основной ветви */
      NEW.lb = OLD.lb + :OldDelta;
      NEW.rb = OLD.rb + :OldDelta;
      /* Сдвигаем границы детей */
      UPDATE ::TABLENAME SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
    END
  END
END
^
COMMIT
^

/****************************************************/
/**                                                **/
/**   Процедура вытягивает количество детей        **/
/**   по Паренту родителя                          **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE ::PREFIX_p_getchildcount_::NAME (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* Присваиваем начальное значение */
  LastIndex = :FirstIndex + 1;

  /* Вытягиваем детей по паренту */
  FOR
    SELECT id
    FROM ::TABLENAME
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    /* Изменяем границы детей */
    EXECUTE PROCEDURE ::PREFIX_p_getchildcount_::NAME (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + 9;

  /* Изменяем границы родителя */
  UPDATE ::TABLENAME SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^
COMMIT
^

/****************************************************/
/**                                                **/
/**   Процедура сжимает интервалы дерева           **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE ::PREFIX_p_restruct_::NAME 
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
    FROM ::TABLENAME
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы для детей */
    EXECUTE PROCEDURE ::PREFIX_p_getchildcount_::NAME (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END
END
^

COMMIT
^

GRANT EXECUTE ON PROCEDURE ::PREFIX_p_expandlimit_::NAME TO administrator^
GRANT EXECUTE ON PROCEDURE ::PREFIX_p_getchildcount_::NAME TO administrator^
GRANT EXECUTE ON PROCEDURE ::PREFIX_p_restruct_::NAME TO administrator^

COMMIT
^