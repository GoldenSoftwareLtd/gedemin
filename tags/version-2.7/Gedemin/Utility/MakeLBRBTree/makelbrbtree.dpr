
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
  ServerName, InputFileName, OutputFileName: String;
  SelfTransaction: TIBTransaction;
  SelfDatabase: TIBDatabase;
  ScriptText: TStringList;

  procedure ReadCommandLineParams;
  var
    SL: TStringList;
    I: Integer;
  begin
    ServerName := '';
    OutputFileName := '';
    SL := TStringList.Create;
    try
      ExtractStrings([' '], [' '], GetCommandLine, SL);
      for I := 0 to SL.Count - 2 do
      begin
        if AnsiSameText(SL[I], '-SN') or AnsiSameText(SL[I], '/SN') then
        begin
          ServerName := SL[I + 1];
        end;

        if AnsiSameText(SL[I], '-FI') or AnsiSameText(SL[I], '/FI') then
        begin
          InputFileName := SL[I + 1];
        end;

        if AnsiSameText(SL[I], '-FO') or AnsiSameText(SL[I], '/FO') then
        begin
          OutputFileName := SL[I + 1];
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
  ScriptText := nil;

  ReadCommandLineParams;
  if (ServerName = '')
    or ((Pos('\', ServerName) > 0) and (Pos('\', ServerName) < Pos(':', ServerName))) then
  begin
    _Writeln('');
    _Writeln('makelbrbtree.exe: ������� ������� ���������!');
    _Writeln('');
    _Writeln('makelbrbtree.exe /sn [���_�������[/port]:]����_�_����_��_������� [/fi ���_�����] [/fo ���_�����]');
    Exit;
  end;

  if InputFileName = '' then
    ScriptText := TStringList.Create
  else begin
    if not FileExists(InputFileName) then
    begin
      _Writeln('');
      _Writeln('makelbrbtree.exe: �������� ���� �� ������.');
      _Writeln('');
      Exit;
    end;

    ScriptText := TStringList.Create;
    try
      ScriptText.LoadFromFile(InputFileName);
    except
      on E: Exception do
      begin
        _Writeln('makelbrbtree.exe: ������ ��� ������ �����.');
        _Writeln('makelbrbtree.exe: ' + E.Message);
        FreeAndNil(ScriptText);
      end;
    end;

    if ScriptText = nil then
      Exit;
  end;

  if not InitializeDatabase then
  begin
    _Writeln('makelbrbtree.exe: ������� ������ ���� � ���� ������.');
    Exit;
  end;

  if not UpdateLBRBTreeBase(SelfTransaction, False, _Writeln, ScriptText) then
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
        _Writeln('makelbrbtree.exe: ������ ��� ���������� ���������.');
        _Writeln('makelbrbtree.exe: ' + E.Message);
      end;
    end;
  end;

  if ScriptText <> nil then
  try
    if OutputFileName = '' then
      OutputFileName := InputFileName;

    SysUtils.DeleteFile(OutputFileName);

    ScriptText.SaveToFile(OutputFileName);
  except
    on E: Exception do
    begin
      _Writeln('makelbrbtree.exe: ������ ��� ������ ���������� �����.');
      _Writeln('makelbrbtree.exe: ' + E.Message);
      FreeAndNil(ScriptText);
    end;
  end;

  SelfTransaction.Free;
  SelfDatabase.Free;
  ScriptText.Free;
end.
