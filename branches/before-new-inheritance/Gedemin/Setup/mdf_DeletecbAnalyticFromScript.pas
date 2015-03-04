unit mdf_DeletecbAnalyticFromScript;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

procedure DeletecbAnalyticFromScript(IBDB: TIBDatabase; Log: TModifyLog);
procedure DeletecbAnalyticFromAcc_BuildAcctCard(IBDB: TIBDatabase; Log: TModifyLog);

implementation                                                

uses
  classes, jclStrings;

function FindBlock(const Substr, S: String): Boolean;

  function StripSpaces(const S: String): String;
  var
    I, J: Integer;
  begin
    SetLength(Result, Length(S));
    J := 0;
    for I := 1 to Length(S) do
    begin
      if not (S[I] in [#9, #10, #13, #32]) then
      begin
        Inc(J);
        Result[J] := S[I];
      end;
    end;
    SetLength(Result, J);
  end;

begin
  Result := StrIPos(StripSpaces(Substr), StripSpaces(S)) > 0;
end;

procedure DeletecbAnalyticFromScript(IBDB: TIBDatabase; Log: TModifyLog);
const
  FirstLineComment1 = 'set P = OwnerForm.FindComponent("frAcctAnalytics").FindComponent("ppAnalytics")';
  FirstLineComment2 = 'set P = OwnerForm.FindComponent("frAcctAnalytics").GetComponent("ppAnalytics")';
  LastLineComment   = 'Other.FieldByName("Params").AsString = S';
  NewBlock          =
    '  Set P = OwnerForm.GetComponent("frAcctAnalytics")'#13#10 +
    '  Other.FieldByName("Params").AsString = P.Description'#13#10;
  FindBlock1        =
    'set P = OwnerForm.FindComponent("frAcctAnalytics").FindComponent("ppAnalytics")'#13#10 +
    'for I = 0 to P.ControlCount - 1'#13#10 +
    'set L = P.Controls(i)'#13#10 +
    'set eAnalitic = L.FindComponent("eAnalitic")'#13#10 +
    'set cbAnalitic = L.FindComponent("cbAnalitic")'#13#10 +
    'set xdeDateTime = L.FindComponent("xdeDateTime")'#13#10 +
    'set lAnaliticName = L.FindComponent("lAnaliticName")'#13#10 +
    'if eAnalitic.Text > "" then';
  FindBlock2        =
    'set P = OwnerForm.FindComponent("frAcctAnalytics").GetComponent("ppAnalytics")'#13#10 +
    'for I = 0 to P.ControlCount - 1'#13#10 +
    'set L = P.Controls(i)'#13#10 +
    'set eAnalitic = L.GetComponent("eAnalitic")'#13#10 +
    'set cbAnalitic = L.GetComponent("cbAnalitic")'#13#10 +
    'set xdeDateTime = L.GetComponent("xdeDateTime")'#13#10 +
    'set lAnaliticName = L.GetComponent("lAnaliticName")'#13#10 +
    'if eAnalitic.Text > "" then';
var
  SQL, SQLUpdate: TIBSQL;
  Tr: TIBTransaction;
  SL: TStringList;
  I: Integer;
  AddComment: Boolean;
  S: String;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  SL := TStringList.Create;
  SQLUpdate := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SQLUpdate.Transaction := Tr;
    SQLUpdate.SQL.Text := 'UPDATE gd_function SET script = :s WHERE id = :id';

    SQL.Transaction := Tr;
    SQL.SQL.Text := 'SELECT f.script, f.id FROM gd_function f';
    try
      SQL.ExecQuery;

      while not SQL.Eof do
      begin
        S := SQL.FieldByName('script').AsString;
        if FindBlock(FindBlock1, S) or FindBlock(FindBlock2, S) then
        begin
          SL.Text := S;

          AddComment := False;
          for I := 0 to SL.Count - 1 do
          begin
            if FindBlock(FirstLineComment1, SL[I]) or FindBlock(FirstLineComment2, SL[I]) then
              AddComment := True;

            if AddComment then
              SL[I] := '  ''' + Trim(SL[I]);

            if FindBlock(LastLineComment, SL[I]) then
            begin
              SL.Insert(I + 1, NewBlock);
              break;
            end;
          end;

          SQLUpdate.ParamByName('s').AsString := SL.Text;
          SQLUpdate.ParamByName('id').AsInteger := SQL.FieldByName('id').AsInteger;
          SQLUpdate.ExecQuery;
          SQLUpdate.Close;
        end;

        SQL.Next;
      end;

      SQL.Close;
      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (162, ''0000.0001.0000.0193'', ''14.11.2012'', ''Delete cbAnalytic from script.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SL.Free;
    SQLUpdate.Free;
    SQL.Free;
    Tr.Free;
  end;
end;

procedure DeletecbAnalyticFromAcc_BuildAcctCard(IBDB: TIBDatabase; Log: TModifyLog);
const
  FB =
    'for i = 0 to MAnList.Count - 1'#13#10 +
    '  set atf = atDatabase.FindRelationField("AC_ENTRY", MAnList(I))'#13#10 +
    '  if Assigned(atf) then'#13#10 +
    '    if Assigned(atf.References) then'#13#10 +
    '      AccountForm.GetComponent("frAcctAnalytics").GetComponent("frAcctAnaliticLine_" & Replace(MAnList(i), "$", "_")).GetComponent("cbAnalitic").CurrentKey = _'#13#10 +
    '        ibds.FieldByName(MAnList(i)).AsString'#13#10 +
    '    else'#13#10 +
    '      select case atf.Field.FieldType'#13#10 +
    '        case ftDate'#13#10 +
    '          AccountForm.GetComponent("frAcctAnalytics").GetComponent("frAcctAnaliticLine_" & Replace(MAnList(i), "$", "_")).GetComponent("xdeDateTime").Date = _'#13#10 +
    '            ibds.FieldByName(MAnList(i)).AsDateTime'#13#10 +
    '        case else'#13#10 +
    '          AccountForm.GetComponent("frAcctAnalytics").GetComponent("frAcctAnaliticLine_" & Replace(MAnList(i), "$", "_")).GetComponent("eAnalitic").Text = _'#13#10 +
    '            ibds.FieldByName(MAnList(i)).AsString'#13#10 +
    '      end select'#13#10 +
    '    end if'#13#10 +
    '  end if'#13#10 +
    'next';

  NB =
    '  dim A'#13#10 +
    '  A = ""'#13#10 +
    '  for i = 0 to MAnList.Count - 1'#13#10 +
    '    set atf = atDatabase.FindRelationField("AC_ENTRY", MAnList(I))'#13#10 +
    '    if Assigned(atf) then'#13#10 +
    '      if A > "" then'#13#10 +
    '        A = A & VbCrLf'#13#10 +
    '      end if'#13#10 +
    '      if not ibds.FieldByName(MAnList(i)).IsNull then'#13#10 +
    '        A = A & MAnList(I) & "=" & ibds.FieldByName(MAnList(i)).AsString'#13#10 +
    '      else'#13#10 +
    '        A = A & MAnList(I) & "=Null"'#13#10 +
    '      end if'#13#10 +
    '    end if'#13#10 +
    '  next'#13#10 +
    '  AccountForm.GetComponent("frAcctAnalytics").Values = A';
  FLC = 'for i = 0 to MAnList.Count - 1';
  LLC = 'next';

var
  SQL, SQLUpdate: TIBSQL;
  Tr: TIBTransaction;
  SL: TStringList;
  I: Integer;
  AddComment: Boolean;
  S: String;
begin
  Tr := TIBTransaction.Create(nil);
  SQL := TIBSQL.Create(nil);
  SL := TStringList.Create;
  SQLUpdate := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SQLUpdate.Transaction := Tr;
    SQLUpdate.SQL.Text := 'UPDATE gd_function SET script = :s WHERE id = :id';

    SQL.Transaction := Tr;
    SQL.SQL.Text := 'SELECT f.script, f.id FROM gd_function f';
    try
      SQL.ExecQuery;

      while not SQL.Eof do
      begin
        S := SQL.FieldByName('script').AsString;
        if FindBlock(FB, S) then
        begin
          SL.Text := S;

          AddComment := False;
          for I := 0 to SL.Count - 1 do
          begin
            if FindBlock(FLC, SL[I]) then
              AddComment := True;

            if AddComment then
              SL[I] := '''' + SL[I];

            if FindBlock(LLC, SL[I]) then
            begin
              SL.Insert(I + 1, NB);
              break;
            end;
          end;

          SQLUpdate.ParamByName('s').AsString := SL.Text;
          SQLUpdate.ParamByName('id').AsInteger := SQL.FieldByName('id').AsInteger;
          SQLUpdate.ExecQuery;
          SQLUpdate.Close;
        end;

        SQL.Next;
      end;

      SQL.Close;
      SQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (191, ''0000.0001.0000.0222'', ''18.10.2013'', ''Delete cbAnalytic from Acc_BuildAcctCard.'') ' +
        '  MATCHING (id)';
      SQL.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SL.Free;
    SQLUpdate.Free;
    SQL.Free;
    Tr.Free;
  end;
end;

end.
