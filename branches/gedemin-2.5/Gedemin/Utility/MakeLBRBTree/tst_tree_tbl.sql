
/* ��� ������� ������������ ����� */
/* ::PREFIX - ������� �������� */
/* ::NAME - �������� ��� �������� */
/* ::TABLENAME - �������� */
  
/*SET TERM ^ ;*/

/****************************************************/
/**                                                **/
/**   ��������� ��������� �������� ��� �������     **/
/**   � ���������� ��� ���� �� ���                 **/
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
  /* �������� ������� �������� */
  SELECT rb, lb
  FROM ::TABLENAME
  WHERE id = :Parent
  INTO :R, :L;

  /* �������� ������� ������ ������� ����� */
  SELECT MAX(rb)
  FROM ::TABLENAME
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
    UPDATE ::TABLENAME SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* �������� ��� ������� ������ ������ */
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

  /* ����������� ���������, ������ ��������������� ������� */
  LeftBorder = :R2 + 1;
END
^
COMMIT
^

/****************************************************/
/**                                                **/
/**   ������� �������������� ���������� ������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
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
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.parent IS NULL) THEN
  BEGIN
    /* ���� ���������� ���������� � ������ */
    /* ������������� ����� ������� ��������� */
    SELECT MAX(rb)
    FROM ::TABLENAME
    INTO NEW.lb;

    /* ��������� ��������� �� �������� ���� */
    IF (NEW.lb IS NULL) THEN
      /* ����� ����, ������ ����, ����� */
      NEW.lb = 1;
    ELSE
      /* ���� ���� ������ */
      NEW.lb = NEW.lb + 1;

    NEW.rb = NEW.lb;
  END ELSE
  BEGIN
    /* ���� ��������� � ���������� */
    /* ������ �����������                    */
    /* �������� ���� ���������, ���� ������  */

    EXECUTE PROCEDURE ::PREFIX_p_expandlimit_::NAME (NEW.parent, 1, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^
COMMIT
^

CREATE EXCEPTION ::PREFIX_e_invalidtree::NAME '��������� ������� ��������� �����.'
^
COMMIT
^


/****************************************************/
/**                                                **/
/**   ������ �������������� ��������� ��������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
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
  /* ��������� ���� ��������� PARENT */
  IF ((NEW.parent <> OLD.parent) OR
     ((OLD.parent IS NULL) AND NOT (NEW.parent IS NULL)) OR 
     ((NEW.parent IS NULL) AND NOT (OLD.parent IS NULL))) THEN
  BEGIN
    /* ������ �������� �� ������������ */
    IF (EXISTS (SELECT * FROM ::TABLENAME 
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION ::PREFIX_e_invalidtree::NAME;
    ELSE
    BEGIN
      IF (NEW.parent IS NULL) THEN
      BEGIN
        /* �������� ������� ������ ������� */
        SELECT MAX(rb)
        FROM ::TABLENAME
        WHERE parent IS NULL
        INTO :NewL;
        /* �������������� ��� ���������� ���� �� ���� ������� � ���� �������� */
        /* ������� �� UPDATE, ������� ������� ������ ����������� �� ��������� */
        NewL = :NewL + 1;
      END ELSE
      BEGIN
        /* �������� �������� ����� ����� ������� */
        A = OLD.rb - OLD.lb + 1; 
        EXECUTE PROCEDURE ::PREFIX_p_expandlimit_::NAME (NEW.parent, A, OLD.lb, OLD.rb)
          RETURNING_VALUES :NewL;
      END

      /* ���������� �������� ������. +1 ����������� � ��������� */
      OldDelta = :NewL - OLD.lb;
      /* �������� ������� �������� ����� */
      NEW.lb = OLD.lb + :OldDelta;
      NEW.rb = OLD.rb + :OldDelta;
      /* �������� ������� ����� */
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
/**   ��������� ���������� ���������� �����        **/
/**   �� ������� ��������                          **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE ::PREFIX_p_getchildcount_::NAME (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* ����������� ��������� �������� */
  LastIndex = :FirstIndex + 1;

  /* ���������� ����� �� ������� */
  FOR
    SELECT id
    FROM ::TABLENAME
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    /* �������� ������� ����� */
    EXECUTE PROCEDURE ::PREFIX_p_getchildcount_::NAME (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + 9;

  /* �������� ������� �������� */
  UPDATE ::TABLENAME SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^
COMMIT
^

/****************************************************/
/**                                                **/
/**   ��������� ������� ��������� ������           **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE ::PREFIX_p_restruct_::NAME 
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* ������������� ������ ���������� ������������ */
  /* �� �� ���� ���������� ������������, �� ������� */
  /* �� ������������ �������� ��� LB, RB. */

  CurrentIndex = 1;

  /* ��� ���� ��������� ��������� ������ ... */
  FOR
    SELECT id
    FROM ::TABLENAME
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... ������ ������� ��� ����� */
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