
unit gdcLBRBTreeMetaData;

interface

uses
  Classes, IBDatabase;

type
  TWritelnCallback = procedure(const S: String);

  TLBRBTreeMetaNames = record
    ChldCtName,
    ExLimName,
    RestrName,
    ExceptName,
    BITriggerName,
    BUTriggerName,
    LBIndexName,
    RBIndexName: String
  end;

procedure CreateLBRBTreeMetaDataScript(AScript: TStrings;
  const APrefix, AName, ATableName: String;
  const ATr: TIBTransaction = nil; const JustAlter: Boolean = False);
function UpdateLBRBTreeBase(const Tr: TIBTransaction; const JustAlter: Boolean;
  _Writeln: TWritelnCallback): Boolean;
function GetLBRBTreeDependentNames(const ARelName: String; const ATr: TIBTRansaction;
  out Names: TLBRBTreeMetaNames): Integer;
function RestrLBRBTree(const ARelName: String; const ATr: TIBTRansaction): Integer;

implementation

uses
  SysUtils, IBSQL;

type
  TNameLabels = (
    nlbTableName,   // Полное имя таблицы
    nlbPrefix,      // Префикс
    nlbName,        // Только имя, без префикса
    nlbMetaName,    // Команда с именем объекта
    nlbExLimName,   // Имя процедуры ExLim
    nlbChldCtName,  // Имя процедуры ChldCt
    nlbExceptName   // Имя исключения
  );

const
  NameLabelsText: array [TNameLabels] of String =
    ('::TABLENAME', '::PREFIX',    '::NAME',     '::METANAME',
     '::EXLIMNAME', '::CHLDCTNAME','::EXCEPTNAME');

  c_el_procedure_name = '::PREFIX_p_el_::NAME';
  c_el_procedure =
    '::METANAME (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)'#13#10 +
    '  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE R     INTEGER = NULL;'#13#10 +
    '  DECLARE VARIABLE L     INTEGER = NULL;'#13#10 +
    '  DECLARE VARIABLE Prev  INTEGER;'#13#10 +
    '  DECLARE VARIABLE LChld INTEGER = NULL;'#13#10 +
    '  DECLARE VARIABLE RChld INTEGER = NULL;'#13#10 +
    '  DECLARE VARIABLE Delta INTEGER;'#13#10 +
    '  DECLARE VARIABLE Dist  INTEGER;'#13#10 +
    '  DECLARE VARIABLE Diff  INTEGER;'#13#10 +
    '  DECLARE VARIABLE WasUnlock INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  IF (:LB2 = -1 AND :RB2 = -1) THEN'#13#10 +
    '    Delta = CAST(COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA''), ''10'') AS INTEGER);'#13#10 +
    '  ELSE'#13#10 +
    '    Delta = :RB2 - :LB2;'#13#10 +
    ''#13#10 +
    '  SELECT lb, rb'#13#10 +
    '  FROM ::TABLENAME'#13#10 +
    '  WHERE id = :Parent'#13#10 +
    '  INTO :L, :R;'#13#10 +
    ''#13#10 +
    '  IF (:L IS NULL) THEN'#13#10 +
    '    EXCEPTION tree_e_invalid_parent ''Invalid parent specified.'';'#13#10 +
    ''#13#10 +
    '  Prev = :L + 1;'#13#10 +
    '  LeftBorder = NULL;'#13#10 +
    ''#13#10 +
    '  FOR SELECT lb, rb FROM ::TABLENAME WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld'#13#10 +
    '  DO BEGIN'#13#10 +
    '    IF ((:LChld - :Prev) > :Delta) THEN '#13#10 +
    '    BEGIN'#13#10 +
    '      LeftBorder = :Prev;'#13#10 +
    '      LEAVE;'#13#10 +
    '    END ELSE'#13#10 +
    '      Prev = :RChld + 1;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  LeftBorder = COALESCE(:LeftBorder, :Prev);'#13#10 +
    '  RightBorder = :LeftBorder + :Delta;'#13#10 +
    ''#13#10 +
    '  WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'');'#13#10 +
    '  IF (:WasUnlock IS NULL) THEN'#13#10 +
    '     RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', 1);'#13#10 +
    ''#13#10 +
    '  IF (:RightBorder >= :R) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    Diff = :R - :L;'#13#10 +
    '    IF (:RightBorder >= (:R + :Diff)) THEN'#13#10 +
    '      Diff = :RightBorder - :R + 1;'#13#10 +
    ''#13#10 +
    '    IF (:Delta < 1000) THEN'#13#10 +
    '      Diff = :Diff + :Delta * 10;'#13#10 +
    '    ELSE'#13#10 +
    '      Diff = :Diff + 10000;'#13#10 +
    ''#13#10 +
    '    /* Сдвигаем все интервалы справа */'#13#10 +
    '    UPDATE ::TABLENAME SET lb = lb + :Diff, rb = rb + :Diff'#13#10 +
    '      WHERE lb > :R;'#13#10 +
    ''#13#10 +
    '    /* Расширяем родительские интервалы */'#13#10 +
    '    UPDATE ::TABLENAME SET rb = rb + :Diff'#13#10 +
    '      WHERE lb <= :L AND rb >= :R;'#13#10 +
    ''#13#10 +
    '    IF (:LB2 <> -1 AND :RB2 <> -1) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      IF (:LB2 > :R) THEN'#13#10 +
    '      BEGIN'#13#10 +
    '        LB2 = :LB2 + :Diff;'#13#10 +
    '        RB2 = :RB2 + :Diff;'#13#10 +
    '      END'#13#10 +
    '      Dist = :LeftBorder - :LB2;'#13#10 +
    '      UPDATE ::TABLENAME SET lb = lb + :Dist, rb = rb + :Dist '#13#10 +
    '        WHERE lb > :LB2 AND rb <= :RB2;'#13#10 +
    '    END'#13#10 +
    '  END ELSE'#13#10 +
    '  BEGIN'#13#10 +
    '    IF (:LB2 <> -1 AND :RB2 <> -1) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      Dist = :LeftBorder - :LB2;'#13#10 +
    '      UPDATE ::TABLENAME SET lb = lb + :Dist, rb = rb + :Dist '#13#10 +
    '        WHERE lb > :LB2 AND rb <= :RB2;'#13#10 +
    '    END'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (:WasUnlock IS NULL) THEN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', NULL);'#13#10 +
    'END';

  c_gchc_procedure_name = '::PREFIX_p_gchc_::NAME';
  c_gchc_procedure =
    '::METANAME (Parent INTEGER, FirstIndex INTEGER)'#13#10 +
    '  RETURNS (LastIndex INTEGER)'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE ChildKey INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  LastIndex = :FirstIndex + 1;'#13#10 +
    ''#13#10 +
    '  /* Изменяем границы детей */'#13#10 +
    '  FOR'#13#10 +
    '    SELECT id'#13#10 +
    '    FROM ::TABLENAME'#13#10 +
    '    WHERE parent = :Parent'#13#10 +
    '    INTO :ChildKey'#13#10 +
    '  DO'#13#10 +
    '  BEGIN'#13#10 +
    '    EXECUTE PROCEDURE ::CHLDCTNAME (:ChildKey, :LastIndex)'#13#10 +
    '      RETURNING_VALUES :LastIndex;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA''), ''10'') AS INTEGER) - 1;'#13#10 +
    ''#13#10 +
    '  /* Изменяем границы родителя */'#13#10 +
    '  UPDATE ::TABLENAME SET lb = :FirstIndex + 1, rb = :LastIndex'#13#10 +
    '    WHERE id = :Parent;'#13#10 +
    'END';

  c_restruct_procedure_name = '::PREFIX_p_restruct_::NAME';
  c_restruct_procedure =
    '::METANAME'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE CurrentIndex INTEGER;'#13#10 +
    '  DECLARE VARIABLE ChildKey INTEGER;'#13#10 +
    '  DECLARE VARIABLE WasUnlock INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  CurrentIndex = 1;'#13#10 +
    ''#13#10 +
    '  WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'');'#13#10 +
    '  IF (:WasUnlock IS NULL) THEN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', 1);'#13#10 +
    ''#13#10 +
    '  /* Для всех корневых элементов ... */'#13#10 +
    '  FOR'#13#10 +
    '    SELECT id'#13#10 +
    '    FROM ::TABLENAME'#13#10 +
    '    WHERE parent IS NULL'#13#10 +
    '    INTO :ChildKey'#13#10 +
    '  DO'#13#10 +
    '  BEGIN'#13#10 +
    '    /* ... меняем границы детей */'#13#10 +
    '    EXECUTE PROCEDURE ::CHLDCTNAME (:ChildKey, :CurrentIndex)'#13#10 +
    '      RETURNING_VALUES :CurrentIndex;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (:WasUnlock IS NULL) THEN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', NULL);'#13#10 +
    'END';

  c_bi_trigger_name = '::PREFIX_bi_::NAME10';
  c_bi_trigger =
    '::METANAME'#13#10 +
    '  BEFORE INSERT'#13#10 +
    '  POSITION 32000'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE D    INTEGER;'#13#10 +
    '  DECLARE VARIABLE L    INTEGER;'#13#10 +
    '  DECLARE VARIABLE R    INTEGER;'#13#10 +
    '  DECLARE VARIABLE Prev INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  IF (NEW.parent IS NULL) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    D = CAST(COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA''), ''10'') AS INTEGER);'#13#10 +
    '    Prev = 1;'#13#10 +
    '    NEW.lb = NULL;'#13#10 +
    ''#13#10 +
    '    FOR SELECT lb, rb FROM ::TABLENAME WHERE parent IS NULL ORDER BY lb INTO :L, :R'#13#10 +
    '    DO BEGIN'#13#10 +
    '      IF ((:L - :Prev) > :D) THEN '#13#10 +
    '      BEGIN'#13#10 +
    '        NEW.lb = :Prev;'#13#10 +
    '        LEAVE;'#13#10 +
    '      END ELSE'#13#10 +
    '        Prev = :R + 1;'#13#10 +
    '    END'#13#10 +
    ''#13#10 +
    '    NEW.lb = COALESCE(NEW.lb, :Prev);'#13#10 +
    '    NEW.rb = NEW.lb + :D;'#13#10 +
    '  END ELSE'#13#10 +
    '  BEGIN'#13#10 +
    '    EXECUTE PROCEDURE ::EXLIMNAME (NEW.parent, -1, -1)'#13#10 +
    '      RETURNING_VALUES NEW.lb, NEW.rb;'#13#10 +
    '  END'#13#10 +
    'END';

  {c_except_name = '::PREFIX_e_tr_::NAME';
  c_except = '::METANAME ''You made an attempt to cycle branch''';}

  c_bu_trigger_name = '::PREFIX_bu_::NAME10';
  c_bu_trigger =
    '::METANAME'#13#10 +
    '  BEFORE UPDATE'#13#10 +
    '  POSITION 32000'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE OldDelta  INTEGER;'#13#10 +
    '  DECLARE VARIABLE D         INTEGER;'#13#10 +
    '  DECLARE VARIABLE L         INTEGER;'#13#10 +
    '  DECLARE VARIABLE R         INTEGER;'#13#10 +
    '  DECLARE VARIABLE Prev      INTEGER;'#13#10 +
    '  DECLARE VARIABLE WasUnlock INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    /* Делаем проверку на зацикливание */'#13#10 +
    '    IF (EXISTS (SELECT * FROM ::TABLENAME'#13#10 +
    '          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN'#13#10 +
    '      EXCEPTION tree_e_invalid_parent ''Attempt to cycle branch in table ::TABLENAME.'';'#13#10 +
    ''#13#10 +
    '    IF (NEW.parent IS NULL) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      D = OLD.rb - OLD.lb;'#13#10 +
    '      Prev = 1;'#13#10 +
    '      NEW.lb = NULL;'#13#10 +
    ''#13#10 +
    '      FOR SELECT lb, rb FROM ::TABLENAME WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R'#13#10 +
    '      DO BEGIN'#13#10 +
    '        IF ((:L - :Prev) > :D) THEN '#13#10 +
    '        BEGIN'#13#10 +
    '          NEW.lb = :Prev;'#13#10 +
    '          LEAVE;'#13#10 +
    '        END ELSE'#13#10 +
    '          Prev = :R + 1;'#13#10 +
    '      END'#13#10 +
    ''#13#10 +
    '      NEW.lb = COALESCE(NEW.lb, :Prev);'#13#10 +
    '      NEW.rb = NEW.lb + :D;'#13#10 +
    ''#13#10 +
    '      /* Определяем величину сдвига */'#13#10 +
    '      OldDelta = NEW.lb - OLD.lb;'#13#10 +
    '      /* Сдвигаем границы детей */'#13#10 +
    '      WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'');'#13#10 +
    '      IF (:WasUnlock IS NULL) THEN'#13#10 +
    '        RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', 1);'#13#10 +
    '      UPDATE ::TABLENAME SET lb = lb + :OldDelta, rb = rb + :OldDelta'#13#10 +
    '        WHERE lb > OLD.lb AND rb <= OLD.rb;'#13#10 +
    '      IF (:WasUnlock IS NULL) THEN'#13#10 +
    '        RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', NULL);'#13#10 +
    '    END ELSE'#13#10 +
    '      EXECUTE PROCEDURE ::EXLIMNAME (NEW.parent, OLD.lb, OLD.rb)'#13#10 +
    '        RETURNING_VALUES NEW.lb, NEW.rb;'#13#10 +
    '  END ELSE'#13#10 +
    '  BEGIN'#13#10 +
    '    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'') IS NULL) THEN'#13#10 +
    '      BEGIN'#13#10 +
    '        NEW.lb = OLD.lb;'#13#10 +
    '        NEW.rb = OLD.rb;'#13#10 +
    '      END'#13#10 +
    '    END'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  WHEN ANY DO'#13#10 +
    '  BEGIN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_UNLOCK'', NULL);'#13#10 +
    '    EXCEPTION;'#13#10 +
    '  END'#13#10 +
    'END';

  c_check_name = '::PREFIX_chk_::NAME_tr_lmt';                                       
  c_check =
    'ALTER TABLE ::TABLENAME ADD CONSTRAINT ::METANAME'#13#10 +
    '  CHECK (lb <= rb)';

  c_index_rb =
    'CREATE DESC INDEX ::PREFIX_x_::NAME_rb'#13#10 +
    '  ON ::TABLENAME (rb)';

  c_index_lb =
    'CREATE ASC INDEX ::PREFIX_x_::NAME_lb'#13#10 +
    '  ON ::TABLENAME (lb)';

  c_grant =
    'GRANT EXECUTE ON PROCEDURE ::METANAME TO administrator';

procedure CreateLBRBTreeMetaDataScript(AScript: TStrings;
  const APrefix, AName, ATableName: String;
  const ATr: TIBTransaction = nil; const JustAlter: Boolean = False);

var
  Names: TLBRBTreeMetaNames;

  function PrepareStr(const S: String; const AMetaName: String = '';
    const ACheckLength: Boolean = False): String;
  begin
    Result := StringReplace(S, NameLabelsText[nlbExceptName], Names.ExceptName, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbExLimName], Names.ExLimName, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbChldCtName], Names.ChldCtName, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbMetaName], AMetaName, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbPrefix], APrefix, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbName], AName, [rfReplaceAll]);
    Result := StringReplace(Result, NameLabelsText[nlbTableName], ATableName, [rfReplaceAll]);
    if ACheckLength and (Length(Result) > 31) then
      SetLength(Result, 31);
  end;

begin
  GetLBRBTreeDependentNames(ATableName, ATr, Names);

  if JustAlter and (Names.ExLimName > '') then
    AScript.Add(PrepareStr(c_el_procedure, 'ALTER PROCEDURE ' + Names.ExLimName))
  else begin
    Names.ExLimName := c_el_procedure_name;
    AScript.Add(PrepareStr(c_el_procedure, 'CREATE PROCEDURE ' + PrepareStr(c_el_procedure_name, '', True)));
  end;

  if JustAlter and (Names.ChldCtName > '') then
    AScript.Add(PrepareStr(c_gchc_procedure, 'ALTER PROCEDURE ' + Names.ChldCtName))
  else begin
    Names.ChldCtName := c_gchc_procedure_name;
    AScript.Add(PrepareStr(c_gchc_procedure, 'CREATE PROCEDURE ' + PrepareStr(c_gchc_procedure_name, '', True)));
  end;

  if JustAlter and (Names.RestrName > '') then
    AScript.Add(PrepareStr(c_restruct_procedure, 'ALTER PROCEDURE ' + Names.RestrName))
  else
    AScript.Add(PrepareStr(c_restruct_procedure, 'CREATE PROCEDURE ' + PrepareStr(c_restruct_procedure_name, '', True)));

  if JustAlter and (Names.BITriggerName > '') then
    AScript.Add(PrepareStr(c_bi_trigger, 'ALTER TRIGGER ' + Names.BITriggerName))
  else begin
    Names.BITriggerName := c_bi_trigger_name;
    AScript.Add(PrepareStr(c_bi_trigger, 'CREATE TRIGGER ' + PrepareStr(c_bi_trigger_name, '', True) +
      ' FOR ' + ATableName));
  end;

  if JustAlter and (Names.BUTriggerName > '') then
    AScript.Add(PrepareStr(c_bu_trigger, 'ALTER TRIGGER ' + Names.BUTriggerName))
  else begin
    Names.BUTriggerName := c_bu_trigger_name;
    AScript.Add(PrepareStr(c_bu_trigger, 'CREATE TRIGGER ' + PrepareStr(c_bu_trigger_name, '', True) +
      ' FOR ' + ATableName));
  end;

  if Names.LBIndexName = '' then
    AScript.Add(PrepareStr(c_index_lb));

  if Names.RBIndexName = '' then
    AScript.Add(PrepareStr(c_index_rb));

  if not JustAlter then
  begin
    AScript.Add(PrepareStr(c_check, PrepareStr(c_check_name, '', True)));

    AScript.Add(PrepareStr(c_grant, PrepareStr(c_el_procedure_name, '', True)));
    AScript.Add(PrepareStr(c_grant, PrepareStr(c_gchc_procedure_name, '', True)));
    AScript.Add(PrepareStr(c_grant, PrepareStr(c_restruct_procedure_name, '', True)));
  end;
end;

function GetName(const ATableName: String): String;
begin
  Result := AnsiUpperCase(Trim(ATableName));
  if Pos('USR$', Result) = 1 then
    Delete(Result, 1, 4)
  else
    Delete(Result, 1, Pos('_', Result));
end;

function GetPrefix(const ATableName: String): String;
var
  P: Integer;
begin
  Result := AnsiUpperCase(Trim(ATableName));
  if Pos('USR$', Result) <> 1 then
  begin
    P := Pos('_', Result);
    if P > 0 then Dec(P);
  end else
    P := 4;
  SetLength(Result, P);
end;

function UpdateLBRBTreeBase(const Tr: TIBTransaction; const JustAlter: Boolean;
  _Writeln: TWritelnCallback): Boolean;
var
  qryListTable: TIBSQL;
  FIBSQL: TIBSQL;
  SQLScript: TStringList;
  TN, S: String;
  I: Integer;
begin
  Result := False;

  SQLScript := TStringList.Create;
  qryListTable := TIBSQL.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FIBSQL.Transaction := Tr;
    FIBSQL.ParamCheck := False;

    qryListTable.Transaction := Tr;
    qryListTable.SQL.Text :=
      'SELECT DISTINCT rdb$relation_name as tablename ' +
      ' FROM rdb$relation_fields ' +
      ' WHERE rdb$field_name in( ''LB'', ''RB'') ' +
      ' AND (rdb$view_context is null) ';
    qryListTable.ExecQuery;

    while not qryListTable.Eof do
    begin
      S := '';
      TN := qryListTable.FieldByName('tablename').AsTrimString;
      try
        SQLScript.Clear;
        CreateLBRBTreeMetaDataScript(SQLScript, GetPrefix(TN), GetName(TN), TN,
          Tr, JustAlter);

        for I := 0 to SQLScript.Count - 1 do
        begin
          S := SQLScript[I];
          FIBSQL.SQL.Text := S;
          FIBSQL.ExecQuery;
        end;

        _Writeln('Обработана таблица: ' + TN + '...');
      except
        on E: Exception do
        begin
          _Writeln('Ошибка при обработке таблицы: ' + TN);
          _Writeln(E.Message + #13#10 + S);
          exit;
        end;
      end;
      qryListTable.Next
    end;

    Result := True;
  finally
    SQLScript.Free;
    FIBSQL.Free;
    qryListTable.Free;
  end;
end;

function GetLBRBTreeDependentNames(const ARelName: String; const ATr: TIBTRansaction;
  out Names: TLBRBTreeMetaNames): Integer;
var
  q: TIBSQL;
  S: String;
begin
  with Names do
  begin
    ChldCtName := '';
    ExLimName := '';
    RestrName := '';
    ExceptName := '';
    BITriggerName := '';
    BUTriggerName := '';
    LBIndexName := '';
    RBIndexName := '';
  end;

  if ATr = nil then
    Result := -1
  else begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      q.SQL.Text :=
        'SELECT DISTINCT rdb$dependent_name FROM rdb$dependencies WHERE rdb$depended_on_name = :depname ' +
        ' AND rdb$dependent_type = 5';
      q.ParamByName('depname').AsString := ARelName;
      q.ExecQuery;

      while not q.EOF do
      begin
        S := q.Fields[0].AsTrimString;

        if (Pos('_P_EL_', S) > 1) or (Pos('_P_EXPANDLIMIT_', S) > 1)
          or (Pos('_P_EXLIM_', S) > 1) then
        begin
          Names.ExLimName := S;
        end;

        if (Pos('_P_RESTRUCT_', S) > 1) or (Pos('_P_RESTR_', S) > 1) then
        begin
          Names.RestrName := S;
        end;

        if (Pos('_P_GCHC_', S) > 1) or (Pos('_P_GETCHILDCOUNT_', S) > 1)
          or (Pos('_P_CHLDCT_', S) > 1) then
        begin
          Names.ChldCtName := S;
        end;

        q.Next;
      end;

      q.Close;
      q.SQL.Text :=
        'SELECT t.rdb$trigger_name FROM rdb$triggers t ' +
        '  JOIN rdb$dependencies d ON d.rdb$dependent_name = t.rdb$trigger_name ' +
        '    AND d.rdb$depended_on_name = :P ' +
        'WHERE t.rdb$trigger_type = :T ' +
        '  AND t.rdb$relation_name = :RN';
      q.ParamByName('T').AsInteger := 1;
      q.ParamByName('P').AsString := Names.ExLimName;
      q.ParamByName('RN').AsString := ARelName;
      q.ExecQuery;

      Names.BITriggerName := q.Fields[0].AsTrimString;

      q.Close;
      q.ParamByName('T').AsInteger := 3;
      q.ParamByName('P').AsString := Names.ExLimName;
      q.ParamByName('RN').AsString := ARelName;
      q.ExecQuery;

      Names.BUTriggerName := q.Fields[0].AsTrimString;

      q.Close;
      q.SQL.Text :=
        'SELECT DISTINCT rdb$depended_on_name FROM rdb$dependencies WHERE rdb$dependent_name = :depname ' +
        ' AND rdb$depended_on_type = 7';
      q.ParamByName('depname').AsString := Names.BUTriggerName;
      q.ExecQuery;

      while not q.EOF do
      begin
        S := q.Fields[0].AsTrimString;

        if ((Pos('_E_INVALIDTREE', S) > 1) or (Pos('_E_TR_', S) > 1))
          and (S <> 'TREE_E_INVALID_PARENT') then
        begin
          Names.ExceptName := S;
        end;

        q.Next;
      end;

      q.Close;
      q.SQL.Text :=
        'SELECT i.rdb$index_name ' +
        'FROM rdb$indices i JOIN rdb$index_segments s ON s.rdb$index_name = i.rdb$index_name ' +
        'WHERE s.rdb$field_name = :F AND i.rdb$relation_name = :RN AND i.rdb$segment_count = 1 ';
      q.ParamByName('F').AsString := 'LB';
      q.ParamByName('RN').AsString := ARelName;
      q.ExecQuery;
      Names.LBIndexName := q.Fields[0].AsTrimString;

      q.Close;
      q.ParamByName('F').AsString := 'RB';
      q.ParamByName('RN').AsString := ARelName;
      q.ExecQuery;
      Names.RBIndexName := q.Fields[0].AsTrimString;

      q.Close;
      q.SQL.Text :=
        'SELECT COUNT(DISTINCT rdb$dependent_name) FROM rdb$dependencies WHERE rdb$depended_on_name = :depname ' +
        ' AND rdb$dependent_type IN (1, 5)';
      q.ParamByName('depname').AsString := ARelName;
      q.ExecQuery;

      Result := q.Fields[0].AsInteger;
    finally
      q.Free;
    end;
  end;
end;

function RestrLBRBTree(const ARelName: String; const ATr: TIBTRansaction): Integer;
var
  q, q2: TIBSQL;
  Names: TLBRBTreeMetaNames;
begin
  Assert(ATr <> nil);
  Assert(ATr.InTransaction);

  Result := 0;
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  try
    q2.Transaction := ATr;

    q.Transaction := ATr;
    q.SQL.Text :=
      'SELECT DISTINCT r.rdb$relation_name FROM rdb$relation_fields r ' +
      '  JOIN rdb$relation_fields r2 ON r.rdb$relation_name = r2.rdb$relation_name ' +
      '    AND r2.rdb$field_name = ''RB'' AND r.rdb$field_name = ''LB'' ' +
      'WHERE r.rdb$view_context is null ';
    if ARelName > '' then
      q.SQL.Add('AND r.rdb$relation_name = ''' + UpperCase(ARelName) + ''' ');
    q.ExecQuery;

    while not q.EOF do
    begin
      GetLBRBTreeDependentNames(q.Fields[0].AsTrimString, ATr, Names);
      if Names.RestrName > '' then
      begin
        q2.SQL.Text := 'EXECUTE PROCEDURE ' + Names.RestrName;
        q2.ExecQuery;
        Inc(Result);
      end;

      q.Next;
    end;
  finally
    q.Free;
    q2.Free;
  end;
end;

end.
