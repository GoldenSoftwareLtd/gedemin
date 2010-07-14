
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
    SelfTransaction.DefaultDatabase := SelfDatabase;

    try
      SelfDatabase.Open;
      SelfTransaction.StartTransaction;
      Result := True;
    except
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

  if not UpdateLBRBTreeBase(SelfTransaction, False, _Writeln) then
  begin
    if SelfTransaction.InTransaction then
      SelfTransaction.Rollback;
  end else
  begin
    if SelfTransaction.InTransaction then
    try
      SelfTransaction.Commit;
    except
      on E: Exception do
      begin
        SelfTransaction.Rollback;
        _Writeln('makelbrbtree.exe: ошибка при сохранении изменений.');
        _Writeln('makelbrbtree.exe: ' + E.Message);
      end;
    end;
  end;  

  SelfTransaction.Free;
  SelfDatabase.Free;
end.
