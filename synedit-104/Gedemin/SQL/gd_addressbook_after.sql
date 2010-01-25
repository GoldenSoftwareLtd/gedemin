
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
  /* �������� ������� �������� */
  SELECT rb, lb
  FROM gd_contact
  WHERE id = :Parent
  INTO :R, :L;

  /* �������� ������� ������ ������� ����� */
  SELECT MAX(rb)
  FROM gd_contact
  WHERE lb > :L AND lb <= :R
  INTO :R2;

  /* ���� ��� ����� ������������� ����� ������� */
  IF (:R2 IS NULL) THEN
    R2 = :L;

  IF (:R - :R2 < :Delta) THEN
  BEGIN
    /* ���� ����� ��� ���������� */
    /* �������� ������������� � 10 ��� */
    MultiDelta = (:R - :L + 1) * 9;

    /* ��������� ������������� �� ��� ����� �������� */
    IF (:Delta > :MultiDelta) THEN
      MultiDelta = :Delta;

    /* �������� ������ ������� ��������� */
    UPDATE gd_contact SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* �������� ��� ������� ������ ������ */
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

  /* ����������� ���������, ������ ��������������� ������� */
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
    /* ������������� ����� ������� ��������� */
    SELECT MAX(rb)
    FROM gd_contact
    INTO NEW.lb;

    IF (NEW.lb IS NULL) THEN
      /* ���_�� ����, ������ ����, ����� */
      NEW.lb = 1;
    ELSE
      /* ���� ���� ������ */
      NEW.lb = NEW.lb + 1;

    NEW.rb = NEW.lb + K - 1;
  END ELSE
  BEGIN
    /* ������ �����������                    */
    /* �������� ���� _��������, ���� ������  */

    EXECUTE PROCEDURE gd_p_el_contact (NEW.parent, K, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^

SET TERM ; ^

COMMIT;
