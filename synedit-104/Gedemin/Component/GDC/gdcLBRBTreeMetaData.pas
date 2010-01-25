
unit gdcLBRBTreeMetaData;

interface

uses
  Classes;

procedure CreateLBRBTreeMetaDataScript(AScript: TStrings; const APrefix, AName, ATableName: String);

implementation

uses
  SysUtils;

type
  TNameLabels = (nlbTableName, nlbPrefix, nlbName);

const
  NameLabelsText : array [TNameLabels] of String = ('::TABLENAME', '::PREFIX', '::NAME');

  cCount = 12;
  cScript: array[1..cCount] of String = (
    '/****************************************************/'#13#10 +
    '/**                                                **/'#13#10 +
    '/**   ��������� ��������� �������� ��� �������     **/'#13#10 +
    '/**   � ���������� ��� ���� �� ���                 **/'#13#10 +
    '/**                                                **/'#13#10 +
    '/****************************************************/'#13#10 +
    ''#13#10 +
    'CREATE OR ALTER PROCEDURE ::PREFIX_p_el_::NAME (Parent INTEGER, Delta INTEGER,'#13#10 +
    '  LB2 INTEGER, RB2 INTEGER)'#13#10 +
    'RETURNS (LeftBorder INTEGER)'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE R INTEGER;'#13#10 +
    '  DECLARE VARIABLE L INTEGER;'#13#10 +
    '  DECLARE VARIABLE R2 INTEGER;'#13#10 +
    '  DECLARE VARIABLE MKey INTEGER;'#13#10 +
    '  DECLARE VARIABLE MultiDelta INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  /* �������� ������� �������� */'#13#10 +
    '  SELECT rb, lb'#13#10 +
    '  FROM ::TABLENAME'#13#10 +
    '  WHERE id = :Parent'#13#10 +
    '  INTO :R, :L;'#13#10 +
    ''#13#10 +
    '  /* �������� ������� ������ ������� ����� */'#13#10 +
    '  R2 = NULL;'#13#10 +
    '  SELECT MAX(rb)'#13#10 +
    '  FROM ::TABLENAME'#13#10 +
    '  WHERE lb > :L AND lb <= :R'#13#10 +
    '  INTO :R2;'#13#10 +
    ''#13#10 +
    '  /* ���� ��� ����� ������������� ����� ������� */'#13#10 +
    '  IF (:R2 IS NULL) THEN'#13#10 +
    '    R2 = :L;'#13#10 +
    ''#13#10 +
    '  IF (:R - :R2 < :Delta) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    MultiDelta = :R - :L + 100;'#13#10 +
    ''#13#10 +
    '    /* ��������� ������������� �� ��� ����� �������� */'#13#10 +
    '    IF (:Delta > :MultiDelta) THEN'#13#10 +
    '      MultiDelta = :Delta;'#13#10 +
    ''#13#10 +
    '    /* �������� ������ ������� ��������� */'#13#10 +
    '    UPDATE ::TABLENAME SET rb = rb + :MultiDelta'#13#10 +
    '      WHERE lb <= :L AND rb >= :R'#13#10 +
    '        AND NOT (lb >= :LB2 AND rb <= :RB2);'#13#10 +
    ''#13#10 +
    '    /* �������� ��� ������� ������ ������ */'#13#10 +
    '    FOR'#13#10 +
    '      SELECT id'#13#10 +
    '      FROM ::TABLENAME'#13#10 +
    '      WHERE lb > :R'#13#10 +
    '        AND NOT (lb >= :LB2 AND rb <= :RB2)'#13#10 +
    '      ORDER BY lb DESC'#13#10 +
    '      INTO :MKey'#13#10 +
    '    DO'#13#10 +
    '      UPDATE ::TABLENAME'#13#10 +
    '        SET lb = lb + :MultiDelta, rb = rb + :MultiDelta'#13#10 +
    '        WHERE id = :MKey;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  /* ����������� ���������, ������ ��������������� ������� */'#13#10 +
    '  LeftBorder = :R2 + 1;'#13#10 +
    'END',

    '/****************************************************/'#13#10 +
    '/**                                                **/'#13#10 +
    '/**   ��������� ���������� ���������� �����        **/'#13#10 +
    '/**   �� ������� ��������                          **/'#13#10 +
    '/**                                                **/'#13#10 +
    '/****************************************************/'#13#10 +
    'CREATE OR ALTER PROCEDURE ::PREFIX_p_gchc_::NAME (Parent INTEGER, FirstIndex INTEGER)'#13#10 +
    '  RETURNS (LastIndex INTEGER)'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE ChildKey INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  /* ����������� ��������� �������� */'#13#10 +
    '  LastIndex = :FirstIndex + 1;'#13#10 +
    ''#13#10 +
    '  /* ���������� ����� �� ������� */'#13#10 +
    '  FOR'#13#10 +
    '    SELECT id'#13#10 +
    '    FROM ::TABLENAME'#13#10 +
    '    WHERE parent = :Parent'#13#10 +
    '    INTO :ChildKey'#13#10 +
    '  DO'#13#10 +
    '  BEGIN'#13#10 +
    '    /* �������� ������� ����� */'#13#10 +
    '    EXECUTE PROCEDURE ::PREFIX_p_gchc_::NAME (:ChildKey, :LastIndex)'#13#10 +
    '      RETURNING_VALUES :LastIndex;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  LastIndex = :LastIndex + 9;'#13#10 +
    ''#13#10 +
    '  /* �������� ������� �������� */'#13#10 +
    '  UPDATE ::TABLENAME SET lb = :FirstIndex + 1, rb = :LastIndex'#13#10 +
    '    WHERE id = :Parent;'#13#10 +
    'END',

    '/****************************************************/'#13#10 +
    '/**                                                **/'#13#10 +
    '/**   ��������� ������� ��������� ������           **/'#13#10 +
    '/**                                                **/'#13#10 +
    '/****************************************************/'#13#10 +
    'CREATE OR ALTER PROCEDURE ::PREFIX_p_restruct_::NAME'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE CurrentIndex INTEGER;'#13#10 +
    '  DECLARE VARIABLE ChildKey INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  /* ������������� ������ ���������� ������������ */'#13#10 +
    '  /* �� �� ���� ���������� ������������, �� ������� */'#13#10 +
    '  /* �� ������������ �������� ��� LB, RB. */'#13#10 +
    ''#13#10 +
    '  CurrentIndex = 1;'#13#10 +
    ''#13#10 +
    '  /* ��� ���� ��������� ��������� ������ ... */'#13#10 +
    '  FOR'#13#10 +
    '    SELECT id'#13#10 +
    '    FROM ::TABLENAME'#13#10 +
    '    WHERE parent IS NULL'#13#10 +
    '    INTO :ChildKey'#13#10 +
    '  DO'#13#10 +
    '  BEGIN'#13#10 +
    '    /* ... ������ ������� ��� ����� */'#13#10 +
    '    EXECUTE PROCEDURE ::PREFIX_p_gchc_::NAME (:ChildKey, :CurrentIndex)'#13#10 +
    '      RETURNING_VALUES :CurrentIndex;'#13#10 +
    '  END'#13#10 +
    'END',

    '/****************************************************/'#13#10 +
    '/**                                                **/'#13#10 +
    '/**   ������� �������������� ���������� ������     **/'#13#10 +
    '/**   �������� ������, ��������� ��������,         **/'#13#10 +
    '/**   �������� ��������� ������ ���� ����          **/'#13#10 +
    '/**                                                **/'#13#10 +
    '/****************************************************/'#13#10 +
    'CREATE OR ALTER TRIGGER ::PREFIX_bi_::NAME10 FOR ::TABLENAME'#13#10 +
    '  BEFORE INSERT'#13#10 +
    '  POSITION 10'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE R INTEGER;'#13#10 +
    '  DECLARE VARIABLE L INTEGER;'#13#10 +
    '  DECLARE VARIABLE R2 INTEGER;'#13#10 +
    '  DECLARE VARIABLE MULTIDELTA INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  IF (NEW.parent IS NULL) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    /* ���� ���������� ���������� � ������ */'#13#10 +
    '    /* ������������� ����� ������� ��������� */'#13#10 +
    '    NEW.lb = NULL;'#13#10 +
    '    SELECT MAX(rb)'#13#10 +
    '    FROM ::TABLENAME'#13#10 +
    '    INTO NEW.lb;'#13#10 +
    ''#13#10 +
    '    /* ��������� ��������� �� �������� ���� */'#13#10 +
    '    IF (NEW.lb IS NULL) THEN'#13#10 +
    '      /* ����� ����, ������ ����, ����� */'#13#10 +
    '      NEW.lb = 1;'#13#10 +
    '    ELSE'#13#10 +
    '      /* ���� ���� ������ */'#13#10 +
    '      NEW.lb = NEW.lb + 1;'#13#10 +
    ''#13#10 +
    '    NEW.rb = NEW.lb;'#13#10 +
    '  END ELSE'#13#10 +
    '  BEGIN'#13#10 +
    '    /* ���� ��������� � ���������� */'#13#10 +
    '    /* ������ �����������                    */'#13#10 +
    '    /* �������� ���� ���������, ���� ������  */'#13#10 +
    ''#13#10 +
    '    EXECUTE PROCEDURE ::PREFIX_p_el_::NAME (NEW.parent, 1, -1, -1)'#13#10 +
    '      RETURNING_VALUES NEW.lb;'#13#10 +
    ''#13#10 +
    '    NEW.rb = NEW.lb;'#13#10 +
    ''#13#10 +
    '    IF ((NEW.rb IS NULL) OR (NEW.lb IS NULL)) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      EXCEPTION tree_e_invalid_parent;'#13#10 +
    '    END'#13#10 +
    '  END'#13#10 +
    'END',

    'CREATE EXCEPTION ::PREFIX_e_invalidtree::NAME ''You made an attempt to cycle branch''',

    '/****************************************************/'#13#10 +
    '/**                                                **/'#13#10 +
    '/**   ������ �������������� ��������� ��������     **/'#13#10 +
    '/**   �������� ������, ��������� ��������,         **/'#13#10 +
    '/**   �������� ��������� ������ ���� ����          **/'#13#10 +
    '/**                                                **/'#13#10 +
    '/****************************************************/'#13#10 +
    'CREATE OR ALTER TRIGGER ::PREFIX_bu_::NAME10 FOR ::TABLENAME'#13#10 +
    '  BEFORE UPDATE'#13#10 +
    '  POSITION 10'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE OldDelta INTEGER;'#13#10 +
    '  DECLARE VARIABLE L INTEGER;'#13#10 +
    '  DECLARE VARIABLE R INTEGER;'#13#10 +
    '  DECLARE VARIABLE NewL INTEGER;'#13#10 +
    '  DECLARE VARIABLE A INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  /* ��������� ���� ��������� PARENT */'#13#10 +
    '  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    /* ������ �������� �� ������������ */'#13#10 +
    '    IF (EXISTS (SELECT * FROM ::TABLENAME'#13#10 +
    '          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN'#13#10 +
    '      EXCEPTION ::PREFIX_e_invalidtree::NAME;'#13#10 +
    '    ELSE'#13#10 +
    '    BEGIN'#13#10 +
    '      IF (NEW.parent IS NULL) THEN'#13#10 +
    '      BEGIN'#13#10 +
    '        /* �������� ������� ������ ������� */'#13#10 +
    '        SELECT MAX(rb)'#13#10 +
    '        FROM ::TABLENAME'#13#10 +
    '        WHERE parent IS NULL'#13#10 +
    '        INTO :NewL;'#13#10 +
    '        /* �������������� ��� ���������� ���� �� ���� ������� � ���� �������� */'#13#10 +
    '        /* ������� �� UPDATE, ������� ������� ������ ����������� �� ��������� */'#13#10 +
    '        NewL = :NewL + 1;'#13#10 +
    '      END ELSE'#13#10 +
    '      BEGIN'#13#10 +
    '        /* �������� �������� ����� ����� ������� */'#13#10 +
    '        A = OLD.rb - OLD.lb + 1;'#13#10 +
    '        EXECUTE PROCEDURE ::PREFIX_p_el_::NAME (NEW.parent, A, OLD.lb, OLD.rb)'#13#10 +
    '          RETURNING_VALUES :NewL;'#13#10 +
    '      END'#13#10 +
    ''#13#10 +
    '      /* ���������� �������� ������. +1 ����������� � ��������� */'#13#10 +
    '      OldDelta = :NewL - OLD.lb;'#13#10 +
    '      /* �������� ������� �������� ����� */'#13#10 +
    '      NEW.lb = OLD.lb + :OldDelta;'#13#10 +
    '      NEW.rb = OLD.rb + :OldDelta;'#13#10 +
    '      /* �������� ������� ����� */'#13#10 +
    '      UPDATE ::TABLENAME SET lb = lb + :OldDelta, rb = rb + :OldDelta'#13#10 +
    '        WHERE lb > OLD.lb AND rb <= OLD.rb;'#13#10 +
    '    END'#13#10 +
    '  END'#13#10 +
    'END',

    'ALTER TABLE ::TABLENAME ADD CONSTRAINT ::PREFIX_chk_::NAME_tr_lmt'#13#10 +
    '  CHECK ((lb <= rb) /*or ((rb is NULL) and (lb is NULL))*/)',

    'CREATE DESC INDEX ::PREFIX_x_::NAME_rb'#13#10 +
    '  ON ::TABLENAME (rb)',

    'CREATE UNIQUE ASC INDEX ::PREFIX_x_::NAME_lb'#13#10 +
    '  ON ::TABLENAME (lb)',

    'GRANT EXECUTE ON PROCEDURE ::PREFIX_p_el_::NAME TO administrator',

    'GRANT EXECUTE ON PROCEDURE ::PREFIX_p_gchc_::NAME TO administrator',

    'GRANT EXECUTE ON PROCEDURE ::PREFIX_p_restruct_::NAME TO administrator');

procedure CreateLBRBTreeMetaDataScript(AScript: TStrings; const APrefix, AName, ATableName: String);
var
  I: Integer;
  S: String;
begin
  for I := 1 to cCount do
  begin
    S := StringReplace(cScript[I], NameLabelsText[nlbPrefix], APrefix, [rfReplaceAll]);
    S := StringReplace(S, NameLabelsText[nlbName], AName, [rfReplaceAll]);
    AScript.Add(StringReplace(S, NameLabelsText[nlbTableName], ATableName, [rfReplaceAll]));
  end;
end;

end.