
program makelbrbtree;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Windows,
  IBDatabase,
  Db,
  IBCustomDataSet,
  IBQuery,
  IBSQL,
  IBScript,
  gdcLBRBTreeMetaData;

var
  ServerName: String;
  SelfTransaction: TIBTransaction;
  IBTransaction: TIBTransaction;
  SelfDatabase: TIBDatabase;

  procedure ReadCommandLineParams;
  var
    SL: TStringList;
    I: Integer;
  begin
    ServerName := '';
    SL := TStringList.Create;
    try
      ExtractStrings([' '], [' '], GetCommandLine, SL);
      for I := 0 to SL.Count - 2 do
      begin
        if AnsiSameText(SL[I], '-SN') or AnsiSameText(SL[I], '/SN') then
        begin
          ServerName := SL[I + 1];
          break;
        end;
      end;
    finally
      SL.Free;
    end;
  end;

  procedure _Writeln(const AStr: String);
  var
    Ch: array[0..1024] of Char;
  begin
    StrPCopy(Ch, AStr);
    CharToOEM(Ch, Ch);
    Writeln(Ch);
  end;

  function GetName(const ATableName: String): String;
  begin
    Result := AnsiUpperCase(Trim(ATableName));
    Delete(Result, 1, Pos('_', Result));
  end;

  function GetPrefix(const ATableName: String): String;
  var
    P: Integer;
  begin
    Result := AnsiUpperCase(Trim(ATableName));
    P := Pos('_', Result);
    if P > 0 then Dec(P);
    SetLength(Result, P);
  end;

  procedure UpdateBase;
  var
    qryListTable: TIBSQL;
    FIBSQL: TIBSQL;
    SQLScript: TStringList;
    TN: String;
    I: Integer;
  begin
    SQLScript := TStringList.Create;
    qryListTable := TIBSQL.Create(nil);
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := SelfTransaction;
      FIBSQL.ParamCheck := False;

      qryListTable.Transaction := IBTransaction;
      qryListTable.SQL.Text :=
        'SELECT DISTINCT rdb$relation_name as tablename ' +
        ' FROM rdb$relation_fields ' +
        ' WHERE rdb$field_name in( ''LB'', ''RB'') ' +
        ' AND (rdb$view_context is null) ';
      qryListTable.ExecQuery;

      while not qryListTable.Eof do
      begin
        TN := qryListTable.FieldByName('tablename').AsTrimString;
        try
          SQLScript.Clear;
          CreateLBRBTreeMetaDataScript(SQLScript, GetPrefix(TN), GetName(TN), TN);

          if not SelfTransaction.InTransaction then
            SelfTransaction.StartTransaction;

          for I := 0 to SQLScript.Count - 1 do
          begin
            FIBSQL.SQL.Text := SQLScript[I];
            FIBSQL.ExecQuery;
          end;

          SelfTransaction.Commit;
          _Writeln('Обработана таблица: ' + TN + '...');
        except
          on E: Exception do
          begin
            _Writeln('Ошибка при обработке таблицы: ' + TN);
            _Writeln(E.Message);
            if SelfTransaction.InTransaction then
              SelfTransaction.Rollback;
          end;
        end;
        qryListTable.Next
      end;
    finally
      SQLScript.Free;
      FIBSQL.Free;
      qryListTable.Free;
    end;
  end;

  function InitializeDatabase: Boolean;
  begin
    SelfDatabase := TIBDatabase.Create(nil);
    SelfDatabase.DatabaseName := ServerName;
    SelfDatabase.Params.Add('user_name=SYSDBA');
    SelfDatabase.Params.Add('password=masterkey');
    SelfDatabase.Params.Add('lc_ctype=WIN1251');
    SelfDatabase.LoginPrompt := False;
    SelfDatabase.SQLDialect := 3;

    SelfTransaction := TIBTransaction.Create(nil);
    SelfTransaction.Params.Add('read_committed');
    SelfTransaction.Params.Add('rec_version');
    SelfTransaction.Params.Add('nowait');
    SelfTransaction.DefaultDatabase := SelfDatabase;

    IBTransaction := TIBTransaction.Create(nil);
    IBTransaction.Params.Add('read_committed');
    IBTransaction.Params.Add('rec_version');
    IBTransaction.Params.Add('nowait');
    IBTransaction.DefaultDatabase := SelfDatabase;

    try
      SelfDatabase.Open;
      SelfTransaction.StartTransaction;
      IBTransaction.StartTransaction;
      Result := True;
    except
      IBTransaction.Free;
      SelfTransaction.Free;
      SelfDatabase.Free;
      Result := False;
    end;
  end;

begin
  ReadCommandLineParams;
  if (ServerName = '')
    or ((Pos('\', ServerName) > 0) and (Pos('\', ServerName) < Pos(':', ServerName))) then
  begin
    _Writeln('');
    _Writeln('makelbrbtree.exe: Неверно указаны параметры!');
    _Writeln('');
    _Writeln('makelbrbtree.exe /sn [имя_сервера[/port]:]путь_к_базе_на_сервере');
    Exit;
  end;

  if not InitializeDatabase then
  begin
    _Writeln('makelbrbtree.exe: неверно указан путь к базе данных.');
    Exit;
  end;

  UpdateBase;

  if SelfTransaction.InTransaction then
  try
    SelfTransaction.Commit;
  except
    SelfTransaction.Rollback;
    _Writeln('makelbrbtree.exe: ошибка при сохранении изменений.');
  end;

  if IBTransaction.InTransaction then
    IBTransaction.Commit;

  SelfTransaction.Free;
  IBTransaction.Free;
  SelfDatabase.Free;
end.
