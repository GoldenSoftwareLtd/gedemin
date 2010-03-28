unit gdUpdateIndiceStat;

interface

uses
  IBDatabase;

type
  Tcst_def_KeyWords =
    (CURRENT_DATE, CURRENT_TIME, CURRENT_USER, CURRENT_ROLE, CURRENT_TIMESTAMP);

const
  cst_def_KeyWords: array[Tcst_def_KeyWords] of String =
    ('CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_USER', 'CURRENT_ROLE', 'CURRENT_TIMESTAMP');

  function GetDefValueInQuotes(const DefaultValue: String): String;
  function GetDomainText(ADataBase : TIBDataBase; FieldName : String; const isCharSet: Boolean = True): String;
  function GetParamsText(ProcedureName : String; ADataBase : TIBDataBase): String;
  procedure UpdateIndicesStat(ADataBase : TIBDataBase);
  procedure RecompileTriggers(ADataBase : TIBDataBase);
  procedure RecompileProcedures(ADataBase : TIBDataBase);
  procedure ReCreateComputedFields(ADataBase : TIBDataBase);
  procedure ReCreateView(ADataBase : TIBDataBase);

implementation

uses
  IBSQL, IBHeader, IBCustomDataSet, SysUtils, Classes;

const
  Temp_FieldName = 'TEMP_COMPUTED';
  Temp_View = 'TEMP_VIEW';

procedure UpdateIndicesStat(ADataBase : TIBDataBase);
var
  q1, q2: TIBSQL;
  Tr, ReadTr: TIBTransaction;
begin
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  ReadTr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    ReadTr.DefaultDatabase := ADataBase;
    ReadTr.StartTransaction;
    q1.Transaction := Tr;

    q2.Transaction := ReadTr;
    q2.SQL.Text := 'SELECT rdb$index_name FROM rdb$indices ';
    q2.ExecQuery;
    while not q2.EOF do
    begin
      Tr.StartTransaction;
      q1.SQL.Text := 'SET STATISTICS INDEX "' + q2.Fields[0].AsTrimString + '"';
      q1.ExecQuery;

      q1.Close;
      Tr.Commit;

      q2.Next;
    end;
    q2.Close;
    ReadTr.Commit;
  finally
    q1.Free;
    q2.Free;
    Tr.Free;
    ReadTr.Free;
  end;
end;

procedure RecompileTriggers(ADataBase : TIBDataBase);
var
  q1, q2: TIBSQL;
  Tr, ReadTr: TIBTransaction;
begin
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  ReadTr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    ReadTr.DefaultDatabase := ADataBase;
    ReadTr.StartTransaction;
    q1.Transaction := Tr;

    q2.Transaction := ReadTr;
    q2.SQL.Text := 'SELECT tr.RDB$TRIGGER_NAME, tr.RDB$TRIGGER_SOURCE FROM RDB$TRIGGERS tr '#13#10 +
      'WHERE NOT tr.RDB$TRIGGER_SOURCE IS NULL'#13#10 +
      'AND NOT tr.RDB$TRIGGER_NAME LIKE ''CHECK%''';
    q2.ExecQuery;
    while not q2.EOF do
    begin
      Tr.StartTransaction;
      q1.SQL.Text := 'ALTER TRIGGER "' + q2.Fields[0].AsTrimString + '" ' + q2.Fields[1].AsTrimString;
      q1.ParamCheck := False;
      q1.ExecQuery;

      q1.Close;
      Tr.Commit;

      q2.Next;
    end;
    q2.Close;
    ReadTr.Commit;
  finally
    q1.Free;
    q2.Free;
    Tr.Free;
    ReadTr.Free;
  end;
end;

procedure RecompileProcedures(ADataBase : TIBDataBase);
var
  q1, q2: TIBSQL;
  Tr, ReadTr: TIBTransaction;
begin
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  ReadTr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    ReadTr.DefaultDatabase := ADataBase;
    ReadTr.StartTransaction;
    q1.Transaction := Tr;

    q2.Transaction := ReadTr;
    q2.SQL.Text := 'SELECT pr.RDB$PROCEDURE_NAME, pr.RDB$PROCEDURE_SOURCE FROM RDB$PROCEDURES pr '#13#10 +
      'WHERE NOT pr.RDB$PROCEDURE_SOURCE IS NULL';
    q2.ExecQuery;
    while not q2.EOF do
    begin
      Tr.StartTransaction;
      q1.SQL.Text := 'ALTER PROCEDURE "' + q2.Fields[0].AsTrimString + '" ' + GetParamsText(q2.FieldByName('RDB$PROCEDURE_NAME').AsString , ADataBase) +
        ' AS ' + q2.Fields[1].AsTrimString;
      q1.ParamCheck := False;
      q1.ExecQuery;

      q1.Close;
      Tr.Commit;

      q2.Next;
    end;
    q2.Close;
    ReadTr.Commit;
  finally
    q1.Free;
    q2.Free;
    Tr.Free;
    ReadTr.Free;
  end;
end;

function GetParamsText(ProcedureName : String; ADataBase : TIBDataBase ): String;
var
  ibsql: TIBSQl;
  S1, S2: String;
  Tr : TIBTransaction;
begin
  Result := '';
  ibsql := TIBSQL.Create(nil);;
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    Tr.StartTransaction;

    ibsql.Transaction := Tr;
    ibsql.SQL.Text := 'SELECT * FROM rdb$procedure_parameters pr ' +
                      'WHERE pr.rdb$procedure_name = :pn AND pr.rdb$parameter_type = :pt ' +
                      'ORDER BY pr.rdb$parameter_number ASC ';
    ibsql.ParamByName('pn').AsString := ProcedureName;
    ibsql.ParamByName('pt').AsInteger := 0;
    ibsql.ExecQuery;

    S1 := '';
    while not ibsql.EOF do
    begin
      if S1 = '' then
        S1 := '('#13#10;
      S1 := S1 + '    ' + Trim(ibsql.FieldByName('rdb$parameter_name').AsString) + ' ' +
         GetDomainText(ADataBase ,ibsql.FieldByName('rdb$field_source').AsString, False);
      ibsql.Next;
      if not ibsql.EOF then
        S1 := S1 + ','#13#10
      else
        S1 := S1 + ')';
    end;

    S1 := S1 + #13#10;

    ibsql.Close;
    ibsql.ParamByName('pt').AsInteger := 1;

    ibsql.ExecQuery;
    S2 := '';
    while not ibsql.EOF do
    begin
      if S2 = '' then
        S2 := 'RETURNS ( '#13#10;
      S2 := S2 + '    ' + Trim(ibsql.FieldByName('rdb$parameter_name').AsString) + ' ' + GetDomainText(ADataBase, ibsql.FieldByName('rdb$field_source').AsString, False);
      ibsql.Next;
      if not ibsql.EOF then
        S2 := S2 + ','#13#10
      else
        S2 := S2 + ')'#13#10;
    end;

    Result := S1 + S2;
    Tr.Commit
  finally
    ibsql.Free;
    Tr.Free;
  end;
end;

function GetDomainText(ADataBase : TIBDataBase; FieldName :String; const isCharSet: Boolean = True): String;

  function FormFloatDomain(dsDomain: TIBSQL): String;
  var
    fscale: Integer;
  begin
    if dsDomain.FieldByName('fsubtype').AsInteger = 1 then
      Result := 'NUMERIC'
    else
      Result := 'DECIMAL';

    if dsDomain.FieldByName('fscale').AsInteger < 0 then
      fscale := -dsDomain.FieldByName('fscale').AsInteger
    else
      fscale := dsDomain.FieldByName('fscale').AsInteger;

    if dsDomain.FieldByName('fprecision').AsInteger = 0 then
      Result := Format('%s(9, %s)',
        [Result, IntToStr(fscale)])
    else
      Result := Format('%s(%s, %s)',
        [Result, dsDomain.FieldByName('fprecision').AsString, IntToStr(fscale)]);
  end;

  function GetDomain (dsDomain: TIBSQL): String;
  begin
    case dsDomain.FieldByName('ffieldtype').AsInteger of

    blr_Text, blr_varying:
      begin
        if dsDomain.FieldByName('ffieldtype').AsInteger = blr_Text then
          Result := 'CHAR'
        else
          Result := 'VARCHAR';

        Result := Format('%s(%s)', [Result, dsDomain.FieldByName('fcharlength').AsString]);

        if isCharSet and (dsDomain.FieldByName('CHARSET').AsString <> '') then
        begin
          Result := Format('%s CHARACTER SET %s',
            [Result, Trim(dsDomain.FieldByName('CHARSET').AsString)]);
        end;
      end;

    blr_d_float, blr_double, blr_float:
      Result := 'DOUBLE PRECISION';

    blr_int64:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'BIGINT';

    blr_long:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'INTEGER';

    blr_short:
      if (dsDomain.FieldByName('fsubtype').AsInteger > 0) or
        (dsDomain.FieldByName('fprecision').AsInteger > 0) or
        (dsDomain.FieldByName('fscale').AsInteger < 0) then
      begin
        Result := FormFloatDomain(dsDomain)
      end else
        Result := 'SMALLINT';

    blr_sql_time:
      Result := 'TIME';

    blr_sql_date:
      Result := 'DATE';

    blr_timestamp:
      Result := 'TIMESTAMP';

    blr_blob:
      begin
        Result := 'BLOB';
        Result := Format
        (
          ' %s SUB_TYPE %s SEGMENT SIZE %s',
          [
            Result,
            dsDomain.FieldByName('fsubtype').AsString,
            dsDomain.FieldByName('seglength').AsString
          ]
        );
        if isCharSet and (dsDomain.FieldByName('CHARSET').AsString <> '') then
        begin
          Result := Format('%s CHARACTER SET %s',
            [Result, dsDomain.FieldByName('CHARSET').AsString]);
        end;

      end;
    end;
    Result := Trim(Result);
  end;

var
  qry: TIBSQL;
  Transaction : TIBTransaction;
begin
  qry := TIBSQL.Create(nil);
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := ADataBase;
    Transaction.StartTransaction;
    qry.Transaction := Transaction;
    try
      qry.SQL.Text := 'SELECT ' +
        ' /* z.*,  refr.lname as reflname, refrf.lname as reflistlname, ' +
        '  setr.lname as setlistlname, */ rdb.rdb$null_flag AS flag, ' +
        '  rdb.rdb$field_type as ffieldtype, ' +
        '  rdb.rdb$field_sub_type as fsubtype, ' +
        '  rdb.rdb$field_precision as fprecision, ' +
        '  rdb.rdb$field_scale as fscale, ' +
        '  rdb.rdb$field_length as flength, ' +
        '  rdb.rdb$character_length as fcharlength, ' +
        '  rdb.rdb$segment_length as seglength, ' +
        '  rdb.rdb$validation_source AS checksource, ' +
        '  rdb.rdb$default_source as defsource, ' +
        '  rdb.rdb$computed_source as computed_value, ' +
        '  cs.rdb$character_set_name AS charset, ' +
        '  cl.rdb$collation_name AS collation ' +
        '  FROM rdb$fields rdb ' +
        '    LEFT JOIN ' +
        '      rdb$character_sets cs ' +
        '    ON ' +
        '      rdb.rdb$character_set_id = cs.rdb$character_set_id ' +
        '    LEFT JOIN ' +
        '      rdb$collations cl ' +
        '    ON ' +
        '      rdb.rdb$collation_id = cl.rdb$collation_id ' +
        '        AND ' +
        '      rdb.rdb$character_set_id = cl.rdb$character_set_id ' +
        '    LEFT JOIN at_fields z ON ' +
        '     rdb.rdb$field_name = z.fieldname ' +
        ' WHERE rdb.rdb$field_name = :fieldname ';

      qry.ParamByName('fieldname').AsString := FieldName;
      qry.ExecQuery;

      if qry.RecordCount > 0 then
        Result := GetDomain(qry)
      else
        raise Exception.Create('Неопределен тип домена');

      if Transaction.InTransaction then
        Transaction.Commit;
    except
      if Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    qry.Free;
    Transaction.Free;
  end;
end;

//Заключает значение по умолчанию в ковычки
//При этом идет проверка: если значение уже в ковычках, то оно так и возвращается
//в обратном случае, если ковычка встречается внутри текста, то она удваивается
function GetDefValueInQuotes(const DefaultValue: String): String;
var
  I: Integer;
  DefSt: String;
  L: Tcst_def_KeyWords;
begin
  if AnsiPos('DEFAULT', Trim(AnsiUpperCase(DefaultValue))) = 1 then
    DefSt := Trim(Copy(Trim(DefaultValue), 8, Length(Trim(DefaultValue)) - 1))
  else
    DefSt := DefaultValue;

  for L := Low(cst_def_KeyWords) to High(cst_def_KeyWords) do
  begin
    if AnsiCompareText(DefSt, cst_def_KeyWords[L]) = 0 then
    begin
      Result := DefSt;
      Exit;
    end;
  end;

  if (DefSt[1] = '''') and (DefSt[Length(DefSt)] = '''') then
  begin
    Result := DefSt;
  end else
  begin
    Result := '';
    for I := 1 to Length(DefSt) do
    begin
      if DefSt[I] = '''' then
        Result := Result + '''';
      Result := Result + DefSt[I];
    end;
    Result := '''' + Result + '''';
  end;
end;

{Пересоздание вычисляемых полей.
Раз в YA и в FB нет Alter для Computed fields, делаем
1. Находим табличу с вычисляемым полем.
2. Создаём ещё одно вычисляемое поле.
3. Переносим blr из второго поля в первое.
4. Удаляем второе поле.
}
procedure ReCreateComputedFields(ADataBase : TIBDataBase);
var
  q1, q2: TIBSQL;
  Tr, ReadTr: TIBTransaction;
begin
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  ReadTr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    q1.Transaction := Tr;

    ReadTr.DefaultDatabase := ADataBase;
    ReadTr.StartTransaction;
    q2.Transaction := ReadTr;
    
    q2.SQL.Text := 'SELECT ' +
      '  F.RDB$FIELD_NAME AS DOMAIN_NAME, ' +
      '  F.RDB$COMPUTED_SOURCE AS FIELD_SOURCE, ' +
      '  RF.RDB$FIELD_NAME AS FIELD_NAME, ' +
      '  RF.RDB$RELATION_NAME AS TABLE_NAME ' +
      'FROM RDB$FIELDS F ' +
      'JOIN RDB$RELATION_FIELDS RF ON RF.RDB$FIELD_SOURCE = F.RDB$FIELD_NAME ' +
      'WHERE F.RDB$COMPUTED_SOURCE IS NOT NULL ';
    q2.ExecQuery;
    while not q2.EOF do
    begin
      // Создали поле.
      Tr.StartTransaction;
      q1.SQL.Text := 'ALTER TABLE "' + q2.Fields[3].AsTrimString + '" ADD ' + Temp_FieldName +
        ' COMPUTED BY ' + q2.Fields[1].AsTrimString;
      q1.ExecQuery;
      q1.Close;
      Tr.Commit;

      Tr.StartTransaction;
      q1.SQL.Text := 'UPDATE RDB$FIELDS F '#13#10 +
        'SET F.RDB$COMPUTED_BLR = '#13#10 +
        '  (SELECT F1.RDB$COMPUTED_BLR '#13#10 +
        '   FROM RDB$RELATION_FIELDS RF '#13#10 +
        '   JOIN RDB$FIELDS F1 ON RF.RDB$FIELD_SOURCE = F1.RDB$FIELD_NAME '#13#10 +
        '   WHERE RF.RDB$RELATION_NAME = :table_name '#13#10 +
        '     AND RF.RDB$FIELD_NAME = :field_name) '#13#10 +
        'WHERE F.RDB$FIELD_NAME = :domain_name ';
      q1.ParamByName('table_name').AsString := q2.FieldByName('table_name').AsTrimString;
      q1.ParamByName('field_name').AsString := Temp_FieldName;
      q1.ParamByName('domain_name').AsString := q2.FieldByName('domain_name').AsTrimString;
      try
        q1.ExecQuery;
      except
        Tr.Rollback;
      end;
      q1.Close;
      if Tr.InTransaction then
        Tr.Commit;

      //удаляем поле
      Tr.StartTransaction;
      q1.SQL.Text := 'ALTER TABLE "' + q2.Fields[3].AsTrimString + '" DROP ' + Temp_FieldName;
      q1.ExecQuery;
      q1.Close;
      Tr.Commit;

      q2.Next;
    end;
    q2.Close;
    ReadTr.Commit;
  finally
    q1.Free;
    q2.Free;
    Tr.Free;
    ReadTr.Free;
  end;
end;

procedure ReCreateView(ADataBase : TIBDataBase);
var
  q1, q2: TIBSQL;
  Tr, ReadTr: TIBTransaction;
  S: String;

  function GetViewText(const FSQL: TIBSQL; const ReadTr: TIBTransaction): String;
  var
    S: String;
    ibsql: TIBSQL;
  begin
    Result := Format(
      'CREATE VIEW %s '#13#10 +
      ' ('#13#10, [Temp_View]);

    S := '';

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := ReadTr;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$relation_name = :rn ORDER BY rdb$field_position ';
      ibsql.ParamByName('rn').AsString := FSQL.FieldByName('RDB$RELATION_NAME').AsString;
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        while not ibsql.EOF do
        begin
          S := S + Trim(ibsql.FieldByName('rdb$field_name').AsString);
          ibsql.Next;
          if not ibsql.EOF then
            S := S + ','#13#10;
        end;
      end;
    finally
      ibsql.Free;
    end;

    Result := Result + S + #13#10 + ') '#13#10 + 'AS ' +
       FSQL.FieldByName('RDB$VIEW_SOURCE').AsString;
  end;

begin
  q1 := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  ReadTr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ADataBase;
    q1.Transaction := Tr;

    ReadTr.DefaultDatabase := ADataBase;
    ReadTr.StartTransaction;
    q2.Transaction := ReadTr;

    q2.SQL.Text := 'SELECT R.RDB$RELATION_NAME, R.RDB$VIEW_SOURCE ' +
      'FROM RDB$RELATIONS R ' +
      'WHERE R.RDB$VIEW_SOURCE IS NOT NULL ';
    q2.ExecQuery;
    while not q2.EOF do
    begin
      S := GetViewText(q2, ReadTr);

      Tr.StartTransaction;
      q1.SQL.Text := S;
      q1.ExecQuery;
      q1.Close;
      Tr.Commit;

      //Перенесём blr
      Tr.StartTransaction;
      q1.SQL.Text := 'UPDATE RDB$RELATIONS R ' +
        'SET R.RDB$VIEW_BLR = ' +
        '  (SELECT R1.RDB$VIEW_BLR FROM RDB$RELATIONS R1 ' +
        '   WHERE R1.RDB$RELATION_NAME = :temp_view) ' +
        'WHERE R.RDB$RELATION_NAME = :rn ';
      q1.ParamByName('temp_view').AsString := Temp_View;
      q1.ParamByName('rn').AsString := q2.FieldByName('RDB$RELATION_NAME').AsTrimString;
      try
        q1.ExecQuery;
      except
        Tr.Rollback;
      end;
      q1.Close;
      if Tr.InTransaction then
        Tr.Commit;

      Tr.StartTransaction;
      q1.SQL.Text := 'DROP VIEW ' + Temp_View;
      q1.ExecQuery;
      q1.Close;
      Tr.Commit;

      q2.Next;
    end;
    q2.Close;
    ReadTr.Commit;
  finally
    q1.Free;
    q2.Free;
    Tr.Free;
    ReadTr.Free;
  end;
end;

end.
