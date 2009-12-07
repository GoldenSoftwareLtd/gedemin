
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

SET TERM ^ ;

ALTER PROCEDURE gd_p_el_contact (Parent INTEGER, Delta INTEGER,
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
  FROM gd_contact
  WHERE id = :Parent
  INTO :R, :L;

  /* Получаем крайнюю правую границу детей */
  SELECT MAX(rb)
  FROM gd_contact
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
    UPDATE gd_contact SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* Сдвигаем обе границы нижних ветвей */
    FOR
      SELECT id
      FROM gd_contact
      WHERE lb > :R AND NOT (lb >= :LB2 AND rb <= :RB2)
      ORDER BY lb DESC
      INTO :MKey
    DO
      UPDATE gd_contact
        SET lb = lb + :MultiDelta, rb = rb + :MultiDelta
        WHERE id = :MKey;
  END

  /* Присваиваем результат, первый удовлетворяющий элемент */
  LeftBorder = :R2 + 1;
END
^

ALTER TRIGGER gd_bi_contact10 /*FOR gd_contact*/
  BEFORE INSERT
  POSITION 10
AS
  DECLARE VARIABLE K INTEGER;
BEGIN
  IF (NEW.CONTACTTYPE = 0 OR NEW.CONTACTTYPE = 3) THEN
    K = 100;
  ELSE
    K = 1;

  IF (NEW.parent IS NULL) THEN
  BEGIN
    /* Устанавливаем левую границу диапазона */
    SELECT MAX(rb)
    FROM gd_contact
    INTO NEW.lb;

    IF (NEW.lb IS NULL) THEN
      /* зап_саў няма, дадаем новы, першы */
      NEW.lb = 1;
    ELSE
      /* Если есть записи */
      NEW.lb = NEW.lb + 1;

    NEW.rb = NEW.lb + K - 1;
  END ELSE
  BEGIN
    /* дадаем падузровень                    */
    /* вызначым мяжу _нтэрвала, куды дадаем  */

    EXECUTE PROCEDURE gd_p_el_contact (NEW.parent, K, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^

SET TERM ; ^

COMMIT;
