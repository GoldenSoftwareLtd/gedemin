// ShlTanya, 10.03.2019

unit flt_AdditionalFunctions;

interface

uses
  Classes, SysUtils, Windows, IBDatabase, IBSQL, flt_sqlfilter_condition_type,
  flt_sqlFilter, contnrs, gdcBaseInterface;

// Функция для Мишы. Проверка выполнения по значению условий.
function CheckIncludeCondition(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction;
 const AnCondition, AnValues: TFilterConditionList): Boolean;

implementation

function CheckIncludeCondition(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction;
 const AnCondition, AnValues: TFilterConditionList): Boolean;
var
  I, J: Integer;
  Coincidence: Boolean;
  ibsqlWork: TIBSQL;
  SQLList: TStrings;
  TrState, DbState: Boolean;

  function BoolOperation(const AnFirstValue, AnSecondValue, AnIsAnd: Boolean): Boolean;
  begin
    if AnIsAnd then
      Result := AnFirstValue and AnSecondValue
    else
      Result := AnFirstValue or AnSecondValue;
  end;

  function ConvertToType(const AnValue: String; const DataType: TFilterFieldType): Variant;
  begin
    case DataType of
      GD_DT_DIGITAL, GD_DT_BOOLEAN:
        Result := StrToFloat(AnValue);
      GD_DT_DATE, GD_DT_TIME, GD_DT_TIMESTAMP:
        Result := VarAsType(AnValue, varDate);
    else
      Result := AnsiUpperCase(AnValue);
    end;
  end;

  function CheckValueList(const AnValue: String; const AnValueList: TStrings): Boolean;
  var
    LocI: Integer;
    TempVal: TID;
  begin
    Result := False;
    if Trim(AnValue) = '' then
      Exit;
    TempVal := GetTID(AnValue);
    for LocI := 0 to AnValueList.Count - 1 do
      if TempVal = GetTID(AnValueList.Objects[LocI], cEmptyContext) then
      begin
        Result := True;
        Exit;
      end;
  end;

  function GetPrefix(const AnIndex: Integer): String;
  begin
    Result := 'tbl' + IntToStr(AnIndex);
  end;

  function AddSQLColection(const AnSQLList: TStrings; const AnCurrentCondition: TFilterCondition; const AnFieldValue: String): Boolean;
  const
    Prf1 = ' tbl0';
    Prf2 = ' tbl1';
    Prf3 = ' tbl3';
    Pnt = '.';
  var
    LocI: Integer;
    S, S2: String;
  begin
    Result := False;
    Assert(((AnCurrentCondition.ConditionType in
     [GD_FC_INCLUDES, GD_FC_ACTUATES, GD_FC_NOT_ACTUATES, GD_FC_EMPTY,
     GD_FC_NOT_EMPTY]) and
     ((AnCurrentCondition.FieldData.FieldType = GD_DT_REF_SET) or
      (AnCurrentCondition.FieldData.FieldType = GD_DT_CHILD_SET)) or
      ((AnCurrentCondition.ConditionType in [GD_FC_ACTUATES_TREE,
      GD_FC_NOT_ACTUATES_TREE]) and
      ((AnCurrentCondition.FieldData.FieldType = GD_DT_REF_SET) or
      (AnCurrentCondition.FieldData.FieldType = GD_DT_CHILD_SET) or
      (AnCurrentCondition.FieldData.FieldType = GD_DT_REF_SET_ELEMENT)))),
     'Нельзя вызывать данную функцию с текущими параметрами.');
    S := 'EXISTS(SELECT * FROM ';
    S2 := 'WHERE ';
    case AnCurrentCondition.ConditionType of
      GD_FC_ACTUATES_TREE, GD_FC_NOT_ACTUATES_TREE:
      begin
        if (AnCurrentCondition.ValueList.Count = 0) then
          Exit;
        if AnCurrentCondition.ConditionType = GD_FC_NOT_ACTUATES_TREE then
          S := 'NOT ' + S;
        case AnCurrentCondition.FieldData.FieldType of
          GD_DT_CHILD_SET:
            S := S + AnCurrentCondition.FieldData.LinkTable + Prf1 + ', ' +
             AnCurrentCondition.FieldData.LinkTable + Prf2 + ' WHERE ' +
             Prf1 + Pnt + fltTreeLeftBorder + ' <= ' + Prf2 + Pnt + fltTreeLeftBorder + ' AND ' +
             Prf1 + Pnt + fltTreeRightBorder + ' >= ' + Prf2 + Pnt + fltTreeRightBorder + ' AND ' +
             Prf2 + Pnt + AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue + ' AND ' +
             Prf1 + Pnt + AnCurrentCondition.FieldData.LinkTargetField + ' in (';
          GD_DT_REF_SET:
            S := S + AnCurrentCondition.FieldData.RefTable + Prf1 + ', ' +
             AnCurrentCondition.FieldData.RefTable + Prf2 + ', ' +
             AnCurrentCondition.FieldData.LinkTable + Prf3 + ' WHERE ' +
             Prf1 + Pnt + fltTreeLeftBorder + ' <= ' + Prf2 + Pnt + fltTreeLeftBorder + ' AND ' +
             Prf1 + Pnt + fltTreeRightBorder + ' >= ' + Prf2 + Pnt + fltTreeRightBorder + ' AND ' +
             Prf3 + Pnt + AnCurrentCondition.FieldData.LinkTargetField + ' = ' +
             Prf2 + Pnt + AnCurrentCondition.FieldData.RefField + ' AND ' +
             Prf3 + Pnt + AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue + ' AND ' +
             Prf1 + Pnt + AnCurrentCondition.FieldData.RefField + ' in (';
          GD_DT_REF_SET_ELEMENT:
            S := S + AnCurrentCondition.FieldData.RefTable + Prf1 + ', ' +
             AnCurrentCondition.FieldData.RefTable + Prf2 + ' WHERE ' +
             Prf1 + Pnt + fltTreeLeftBorder + ' <= ' + Prf2 + Pnt + fltTreeLeftBorder + ' AND ' +
             Prf1 + Pnt + fltTreeRightBorder + ' >= ' + Prf2 + Pnt + fltTreeRightBorder + ' AND ' +
             Prf2 + Pnt + AnCurrentCondition.FieldData.RefField + ' = ' + AnFieldValue + ' AND ' +
             Prf1 + Pnt + AnCurrentCondition.FieldData.RefField + ' in (';
        end;
        for LocI := 0 to AnCurrentCondition.ValueList.Count - 1 do
          S := S + TID2S(GetTID(AnCurrentCondition.ValueList.Objects[LocI], cEmptyContext)) + ',';
        S[Length(S)] := ')';
      end;

      GD_FC_ACTUATES, GD_FC_NOT_ACTUATES:
      begin
        if (AnCurrentCondition.ValueList.Count = 0) then
          Exit;
        if AnCurrentCondition.ConditionType = GD_FC_NOT_ACTUATES then
          S := 'NOT ' + S;
        S := S + AnCurrentCondition.FieldData.LinkTable + ' WHERE ' +
         AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue + ' AND ' +
         AnCurrentCondition.FieldData.LinkTargetField + ' in (';
        for LocI := 0 to AnCurrentCondition.ValueList.Count - 1 do
          S := S + TID2S(GetTID(AnCurrentCondition.ValueList.Objects[LocI], cEmptyContext)) + ',';
        S[Length(S)] := ')';
      end;

      GD_FC_INCLUDES:
      begin
        if (AnCurrentCondition.ValueList.Count = 0) then
          Exit;
        for LocI := 0 to AnCurrentCondition.ValueList.Count - 1 do
        begin
          S := S + AnCurrentCondition.FieldData.LinkTable + ' ' + GetPrefix(LocI) + ',';
          S2 := S2 + GetPrefix(LocI) + '.' + AnCurrentCondition.FieldData.LinkSourceField +
           ' = ' + AnFieldValue + ' AND ';
          S2 := S2 + GetPrefix(LocI) + '.' + AnCurrentCondition.FieldData.LinkTargetField +
           ' = ' + TID2S(GetTID(AnCurrentCondition.ValueList.Objects[LocI], cEmptyContext)) + ' AND ';
        end;
        S[Length(S)] := ' ';
        Delete(S2, Length(S2) - 3, 4);
        S := S + S2;
      end;

      GD_FC_NOT_EMPTY:
        S := S + AnCurrentCondition.FieldData.LinkTable + ' WHERE ' +
         AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue;

      GD_FC_EMPTY:
        S := 'NOT ' + S + AnCurrentCondition.FieldData.LinkTable + ' WHERE ' +
         AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue;
    end;
    S := S + ')';
    AnSQLList.Add(S);
  end;

  function AddSQLFilter(const AnSQLList: TStrings; const AnCurrentCondition: TFilterCondition; const AnFieldValue: String): Boolean;
  var
    S: String;
    gsSQLFilter: TgsSQLFilter;

    function GetBasicQuery(const AnTableName, AnFieldName: String): String;
    var
      LocI: Integer;
    begin
      Result := 'SELECT * FROM ' + AnTableName +
       ' mntbl WHERE mntbl.' + AnFieldName + ' = ' + AnFieldValue;
      gsSQLFilter.FilterData.ConditionList.Assign(AnCurrentCondition.SubFilter);
      for LocI := 0 to gsSQLFilter.FilterData.ConditionList.Count - 1 do
        gsSQLFilter.FilterData.ConditionList.Conditions[LocI].FieldData.TableAlias := 'mntbl.';
    end;
  begin
    Result := False;
    Assert((AnCurrentCondition.ConditionType in
     [GD_FC_COMPLEXFIELD, GD_FC_CUSTOM_FILTER]) and
     ((AnCurrentCondition.FieldData.FieldType = GD_DT_REF_SET) or
      (AnCurrentCondition.FieldData.FieldType = GD_DT_CHILD_SET) or
      (AnCurrentCondition.FieldData.FieldType = GD_DT_REF_SET_ELEMENT)),
     'Нельзя вызывать данную функцию с текущими параметрами.');
    gsSQLFilter := TgsSQLFilter.Create(nil);
    try
      case AnCurrentCondition.ConditionType of
        GD_FC_CUSTOM_FILTER:
        begin
          case AnCurrentCondition.FieldData.FieldType of
            GD_DT_REF_SET_ELEMENT:
            begin
              S := GetBasicQuery(AnCurrentCondition.FieldData.RefTable,
               AnCurrentCondition.FieldData.RefField);
            end;
            GD_DT_CHILD_SET:
            begin
              S := GetBasicQuery(AnCurrentCondition.FieldData.LinkTable,
               AnCurrentCondition.FieldData.LinkSourceField);
            end;
            GD_DT_REF_SET:
            begin
              S := 'SELECT * FROM ' + AnCurrentCondition.FieldData.LinkTable + ' mntbl' +
               ' WHERE mntbl.' + AnCurrentCondition.FieldData.LinkSourceField + ' = ' + AnFieldValue;
              gsSQLFilter.FilterData.ConditionList.AddCondition(nil);
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.TableName :=
               AnCurrentCondition.FieldData.LinkTable;
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.TableAlias := 'mntbl.';
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.FieldName :=
               AnCurrentCondition.FieldData.LinkTargetField;
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.RefTable :=
               AnCurrentCondition.FieldData.RefTable;
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.RefField :=
               AnCurrentCondition.FieldData.RefField;
              gsSQLFilter.FilterData.ConditionList.Conditions[0].FieldData.FieldType := GD_DT_REF_SET_ELEMENT;
              gsSQLFilter.FilterData.ConditionList.Conditions[0].SubFilter.Assign(
               AnCurrentCondition.SubFilter);
              gsSQLFilter.FilterData.ConditionList.Conditions[0].ConditionType := GD_FC_CUSTOM_FILTER;
            end;
          end;
        end;

        GD_FC_COMPLEXFIELD:
        begin
          S := GetBasicQuery(AnCurrentCondition.FieldData.LinkTable,
           AnCurrentCondition.FieldData.LinkSourceField);
        end;
      end;
      gsSQLFilter.SetQueryText(S);
      gsSQLFilter.CreateSQL;

      S := 'EXISTS(' + gsSQLFilter.FilteredSQL.Text + ')';
      AnSQLList.Add(S);
    finally
      gsSQLFilter.Free;
    end;
  end;

  function GetStringOperator: String;
  begin
    if AnCondition.IsAndCondition then
      Result := ' AND '
    else
      Result := ' OR ';
  end;
begin
  Result := AnCondition.IsAndCondition;
  Coincidence := True;
  TrState := AnDatabase.Connected;
  DbState := AnTransaction.InTransaction;
  ibsqlWork := TIBSQL.Create(nil);
  try
    SQLList := TStringList.Create;
    try
      ibsqlWork.SQL.Text := 'SELECT 1 FROM rdb$database WHERE ';
      ibsqlWork.Database := AnDatabase;
      ibsqlWork.Transaction := AnTransaction;

      for I := 0 to AnValues.Count - 1 do
      begin
        for J := 0 to AnCondition.Count - 1 do
        begin
          if (AnValues.Conditions[I].FieldData.FieldName = AnCondition.Conditions[J].FieldData.FieldName)
           //and (AnValues.Conditions[I].FieldData.FieldType = AnCondition.Conditions[J].FieldData.FieldType)
           and (AnValues.Conditions[I].FieldData.TableName = AnCondition.Conditions[J].FieldData.TableName)
           and (AnValues.Conditions[I].FieldData.TableAlias = AnCondition.Conditions[J].FieldData.TableAlias)
           //and (AnValues.Conditions[I].FieldData.RefField = AnCondition.Conditions[J].FieldData.RefField)
           //and (AnValues.Conditions[I].FieldData.RefTable = AnCondition.Conditions[J].FieldData.RefTable)
           //and (AnValues.Conditions[I].FieldData.LinkTable = AnCondition.Conditions[J].FieldData.LinkTable)
           //and (AnValues.Conditions[I].FieldData.LinkTargetField = AnCondition.Conditions[J].FieldData.LinkTargetField)
           then
          begin
            case AnCondition.Conditions[J].ConditionType of
              GD_FC_EQUAL_TO:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) =
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_NOT_EQUAL_TO:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <>
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_LESS_THAN:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_LESS_OR_EQUAL_TO:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) >=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_GREATER_THAN:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_GREATER_OR_EQUAL_TO:
                Result := BoolOperation(Result,
                 ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType),
                 AnCondition.IsAndCondition);
              GD_FC_BETWEEN:
                Result := BoolOperation(Result,
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) and
                 (ConvertToType(AnCondition.Conditions[J].Value2, AnCondition.Conditions[J].FieldData.FieldType) >=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_BETWEEN_LIMIT:
                Result := BoolOperation(Result,
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) and
                 (ConvertToType(AnCondition.Conditions[J].Value2, AnCondition.Conditions[J].FieldData.FieldType) >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_OUT:
                Result := BoolOperation(Result,
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) >=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) or
                 (ConvertToType(AnCondition.Conditions[J].Value2, AnCondition.Conditions[J].FieldData.FieldType) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_OUT_LIMIT:
                Result := BoolOperation(Result,
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) or
                 (ConvertToType(AnCondition.Conditions[J].Value2, AnCondition.Conditions[J].FieldData.FieldType) <
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_NOT_EMPTY:
                if (AnCondition.Conditions[J].FieldData.FieldType = GD_DT_REF_SET) or
                 (AnCondition.Conditions[J].FieldData.FieldType = GD_DT_CHILD_SET) then
                  AddSQLColection(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1)
                else
                  Result := BoolOperation(Result, AnValues.Conditions[I].Value1 > '', AnCondition.IsAndCondition);
              GD_FC_EMPTY:
                if (AnCondition.Conditions[J].FieldData.FieldType = GD_DT_REF_SET) or
                 (AnCondition.Conditions[J].FieldData.FieldType = GD_DT_CHILD_SET) then
                  AddSQLColection(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1)
                else
                  Result := BoolOperation(Result, AnValues.Conditions[I].Value1 = '', AnCondition.IsAndCondition);
              GD_FC_BEGINS_WITH:
                  Result := BoolOperation(Result,
                   Pos(AnsiUpperCase(AnCondition.Conditions[J].Value1), AnsiUpperCase(AnValues.Conditions[I].Value1)) = 1,
                   AnCondition.IsAndCondition);
              GD_FC_CONTAINS:
                Result := BoolOperation(Result,
                 Pos(AnsiUpperCase(AnCondition.Conditions[J].Value1), AnsiUpperCase(AnValues.Conditions[I].Value1)) <> 0,
                 AnCondition.IsAndCondition);
              GD_FC_DOESNT_CONTAIN:
                Result := BoolOperation(Result,
                 Copy(AnsiUpperCase(AnValues.Conditions[I].Value1),
                  Length(AnValues.Conditions[I].Value1) - Length(AnCondition.Conditions[J].Value1) + 1,
                  Length(AnCondition.Conditions[J].Value1)) <>
                 AnsiUpperCase(AnCondition.Conditions[J].Value1),
                 AnCondition.IsAndCondition);
              GD_FC_ENDS_WITH:
                Result := BoolOperation(Result,
                 Copy(AnsiUpperCase(AnValues.Conditions[I].Value1),
                  Length(AnValues.Conditions[I].Value1) - Length(AnCondition.Conditions[J].Value1) + 1,
                  Length(AnCondition.Conditions[J].Value1)) =
                 AnsiUpperCase(AnCondition.Conditions[J].Value1),
                 AnCondition.IsAndCondition);
              GD_FC_TODAY:
                Result := BoolOperation(Result,
                 (Int(Now) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) and
                 (Int(Now + 1) >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_LAST_N_DAYS:
                Result := BoolOperation(Result,
                 (Now - StrToInt(AnCondition.Conditions[J].Value1) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) and
                 (Now >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_SELDAY:
                Result := BoolOperation(Result,
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) <=
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)) and
                 (ConvertToType(AnCondition.Conditions[J].Value1, AnCondition.Conditions[J].FieldData.FieldType) + 1 >
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType)),
                 AnCondition.IsAndCondition);
              GD_FC_TRUE:
                Result := BoolOperation(Result,
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType) <> 0,
                 AnCondition.IsAndCondition);
              GD_FC_FALSE:
                Result := BoolOperation(Result,
                 ConvertToType(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].FieldData.FieldType) = 0,
                 AnCondition.IsAndCondition);
              GD_FC_INCLUDES, GD_FC_ACTUATES_TREE, GD_FC_NOT_ACTUATES_TREE:
                AddSQLColection(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1);
              GD_FC_ACTUATES:
                case AnCondition.Conditions[J].FieldData.FieldType of
                  GD_DT_REF_SET_ELEMENT:
                    Result := BoolOperation(Result,
                     CheckValueList(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].ValueList),
                     AnCondition.IsAndCondition);
                else
                  AddSQLColection(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1);
                end;
              GD_FC_NOT_ACTUATES:
                case AnCondition.Conditions[J].FieldData.FieldType of
                  GD_DT_REF_SET_ELEMENT:
                    Result := BoolOperation(Result,
                     not CheckValueList(AnValues.Conditions[I].Value1, AnCondition.Conditions[J].ValueList),
                     AnCondition.IsAndCondition);
                else
                  AddSQLColection(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1);
                end;
              GD_FC_CUSTOM_FILTER:
                AddSQLFilter(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1);
              GD_FC_COMPLEXFIELD:
                AddSQLFilter(SQLList, AnCondition.Conditions[J], AnValues.Conditions[I].Value1);
              GD_FC_QUERY_WHERE:
                raise Exception.Create('Условие "введено условие" не поддерживается.');
              GD_FC_QUERY_ALL:
                raise Exception.Create('Условие "задан запрос" не поддерживается.');
            end;
            Coincidence := False;
          end;
        end;
      end;
      if SQLList.Count > 0 then
      begin
        for I := 0 to SQLList.Count - 1 do
          if I = SQLList.Count - 1 then
            ibsqlWork.SQL.Add(SQLList.Strings[I])
          else
            ibsqlWork.SQL.Add(SQLList.Strings[I] + GetStringOperator);
        if not TrState then
          AnDatabase.Connected := True;
        if not DbState then
          AnTransaction.StartTransaction;
        ibsqlWork.ExecQuery;
        Result := BoolOperation(Result, GetTID(ibsqlWork.Fields[0]) <> 0, AnCondition.IsAndCondition);
      end;
      Result := Result or Coincidence;
    finally
      SQLList.Free;
    end;
  finally
    if not DbState and AnTransaction.InTransaction then
      AnTransaction.Commit;
    if not TrState then
      AnDatabase.Connected := False;
    ibsqlWork.Free;
  end;
end;

end.
