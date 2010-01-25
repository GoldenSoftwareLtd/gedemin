/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/****************************************************/
/**                                                **/
/**   ��������� ��������� �������� ��� �������     **/
/**   � ���������� ��� ���� �� ���                 **/
/**                                                **/
/****************************************************/

SET TERM ^ ;

ALTER PROCEDURE rp_p_el_reportgroup (Parent INTEGER, Delta INTEGER,
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
  FROM rp_reportgroup
  WHERE id = :Parent
  INTO :R, :L;

  /* �������� ������� ������ ������� ����� */
  SELECT MAX(rb)
  FROM rp_reportgroup
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
    UPDATE rp_reportgroup SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* �������� ��� ������� ������ ������ */
    FOR
      SELECT id
      FROM rp_reportgroup
      WHERE lb > :R AND NOT (lb >= :LB2 AND rb <= :RB2)
      ORDER BY lb DESC
      INTO :MKey
    DO
      UPDATE rp_reportgroup
        SET lb = lb + :MultiDelta, rb = rb + :MultiDelta
        WHERE id = :MKey;
  END

  /* ����������� ���������, ������ ��������������� ������� */
  LeftBorder = :R2 + 1;
END
^

/****************************************************/
/**                                                **/
/**   ������� �������������� ���������� ������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER rp_before_insert10_reportgroup FOR rp_reportgroup
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
    FROM rp_reportgroup
    INTO NEW.lb;

    /* ��������� ��������� �� �������� ���� */
    IF (NEW.lb IS NULL) THEN
      /* ���_�� ����, ������ ����, ����� */
      NEW.lb = 1;
    ELSE
      /* ���� ���� ������ */
      NEW.lb = NEW.lb + 1;

    NEW.rb = NEW.lb;
  END ELSE
  BEGIN
    /* ���� ��������� � ���������� */
    /* ������ �����������                    */
    /* �������� ���� _��������, ���� ������  */

    EXECUTE PROCEDURE rp_p_el_reportgroup (NEW.parent, 1, -1, -1)
      RETURNING_VALUES NEW.lb;

    NEW.rb = NEW.lb;
  END
END
^


/****************************************************/
/**                                                **/
/**   ������ �������������� ��������� ��������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER rp_before_update10_reportgroup FOR rp_reportgroup
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
    IF (EXISTS (SELECT * FROM rp_reportgroup
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION rp_e_invalidtreereportgroup;
    ELSE
    BEGIN
      IF (NEW.parent IS NULL) THEN
      BEGIN
        /* �������� ������� ������ ������� */
        SELECT MAX(rb)
        FROM rp_reportgroup
        WHERE parent IS NULL
        INTO :NewL;
        /* �������������� ��� ���������� ���� �� ���� ������� � ���� �������� */
        /* ������� �� UPDATE, ������� ������� ������ ����������� �� ��������� */
        NewL = :NewL + 1;
      END ELSE
      BEGIN
        /* �������� �������� ����� ����� ������� */
        A = OLD.rb - OLD.lb + 1;
        EXECUTE PROCEDURE rp_p_el_reportgroup (NEW.parent, A, OLD.lb, OLD.rb)
          RETURNING_VALUES :NewL;
      END

      /* ���������� �������� ������. +1 ����������� � ��������� */
      OldDelta = :NewL - OLD.lb;
      /* �������� ������� �������� ����� */
      NEW.lb = OLD.lb + :OldDelta;
      NEW.rb = OLD.rb + :OldDelta;
      /* �������� ������� ����� */
      UPDATE rp_reportgroup SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
    END
  END
END
^

/****************************************************/
/**                                                **/
/**   ��������� ���������� ���������� �����        **/
/**   �� ������� ��������                          **/
/**                                                **/
/****************************************************/
ALTER PROCEDURE rp_p_gchc_reportgroup (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* ����������� ��������� �������� */
  LastIndex = :FirstIndex + 1;

  /* ���������� ����� �� ������� */
  FOR
    SELECT id
    FROM rp_reportgroup
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    /* �������� ������� ����� */
    EXECUTE PROCEDURE rp_p_gchc_reportgroup (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + 9;

  /* �������� ������� �������� */
  UPDATE rp_reportgroup SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

/****************************************************/
/**                                                **/
/**   ��������� ������� ��������� ������           **/
/**                                                **/
/****************************************************/
ALTER PROCEDURE rp_p_restruct_reportgroup
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
    FROM rp_reportgroup
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... ������ ������� ��� ����� */
    EXECUTE PROCEDURE rp_p_gchc_reportgroup (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END
END
^

CREATE TRIGGER rp_before_update_reportgroup FOR rp_reportgroup
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  IF (((OLD.parent IS NULL) OR (NEW.parent <> OLD.parent)) AND (NOT NEW.parent IS NULL)) THEN
  BEGIN
    EXECUTE PROCEDURE rp_p_checkgrouptree(NEW.parent, NEW.id)
     returning_values :I;
    if (I <> 0) then
      EXCEPTION rp_e_invalidtreereportgroup;
  END
END
^

COMMIT
^

GRANT EXECUTE ON PROCEDURE rp_p_el_reportgroup TO administrator^
GRANT EXECUTE ON PROCEDURE rp_p_gchc_reportgroup TO administrator^
GRANT EXECUTE ON PROCEDURE rp_p_restruct_reportgroup TO administrator^

SET TERM ; ^

COMMIT;

