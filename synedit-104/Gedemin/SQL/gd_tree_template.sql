
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
/**   �������� ������� ��� �������� ������         **/
/**   � �����������                                **/
/**                                                **/
/****************************************************/
CREATE TABLE tst_treetbl (
  id      dintkey,       /* ���������� ���� */
  parent  dinteger,      /* ������ �� �������� */
  lb      dlb,           /* ����� ������, ������� ������ */
  rb      drb,           /* ������ ������, ������� ������ */

  name    dname          /* ������������ ���� ��� ������� */
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
/**   ��������� ��������� �������� ��� �������     **/
/**   � ���������� ��� ���� �� ���                 **/
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
  /* �������� ������� �������� */
  SELECT rb, lb
  FROM tst_treetbl
  WHERE id = :Parent
  INTO :R, :L;

  /* �������� ������� ������ ������� ����� */
  SELECT MAX(rb)
  FROM tst_treetbl
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
    UPDATE tst_treetbl SET rb = rb + :MultiDelta
      WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2);

    /* �������� ��� ������� ������ ������ */
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
CREATE TRIGGER tst_bi_treetbl FOR tst_treetbl
  BEFORE INSERT
  POSITION 0
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
    FROM tst_treetbl
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
/**   ������ �������������� ��������� ��������     **/
/**   �������� ������, ��������� ��������,         **/
/**   �������� ��������� ������ ���� ����          **/
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
  /* ��������� ���� ��������� PARENT */
  IF ((NEW.parent <> OLD.parent) OR
     ((OLD.parent IS NULL) AND NOT (NEW.parent IS NULL)) OR 
     ((NEW.parent IS NULL) AND NOT (OLD.parent IS NULL))) THEN
  BEGIN
    /* ������ �������� �� ������������ */
    IF (EXISTS (SELECT * FROM tst_treetbl 
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tst_e_invalidtreetreetbl;
    ELSE
    BEGIN
      IF (NEW.parent IS NULL) THEN
      BEGIN
        /* �������� ������� ������ ������� */
        SELECT MAX(rb)
        FROM tst_treetbl
        WHERE parent IS NULL
        INTO :NewL;
        /* �������������� ��� ���������� ���� �� ���� ������� � ���� �������� */
        /* ������� �� UPDATE, ������� ������� ������ ����������� �� ��������� */
        NewL = :NewL + 1;
      END ELSE
      BEGIN
        /* �������� �������� ����� ����� ������� */
        A = OLD.rb - OLD.lb + 1; 
        EXECUTE PROCEDURE tst_p_expandlimit_treetbl (NEW.parent, A, OLD.lb, OLD.rb)
          RETURNING_VALUES :NewL;
      END

      /* ���������� �������� ������. +1 ����������� � ��������� */
      OldDelta = :NewL - OLD.lb;
      /* �������� ������� �������� ����� */
      NEW.lb = OLD.lb + :OldDelta;
      NEW.rb = OLD.rb + :OldDelta;
      /* �������� ������� ����� */
      UPDATE tst_treetbl SET lb = lb + :OldDelta, rb = rb + :OldDelta
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
CREATE PROCEDURE tst_p_getchildcount_treetbl (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  /* ����������� ��������� �������� */
  LastIndex = :FirstIndex + 1;

  /* ���������� ����� �� ������� */
  FOR
    SELECT id
    FROM tst_treetbl
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    /* �������� ������� ����� */
    EXECUTE PROCEDURE tst_p_getchildcount_treetbl (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + 9;

  /* �������� ������� �������� */
  UPDATE tst_treetbl SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

/****************************************************/
/**                                                **/
/**   ��������� ������� ��������� ������           **/
/**                                                **/
/****************************************************/
CREATE PROCEDURE tst_p_restruct_treetbl 
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
    FROM tst_treetbl
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... ������ ������� ��� ����� */
    EXECUTE PROCEDURE tst_p_getchildcount_treetbl (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END
END
^

SET TERM ; ^

COMMIT;

