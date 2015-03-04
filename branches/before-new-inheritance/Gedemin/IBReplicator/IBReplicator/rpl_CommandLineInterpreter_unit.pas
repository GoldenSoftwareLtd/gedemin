unit rpl_CommandLineInterpreter_unit;

interface
uses Windows, rpl_ReplicationServer_unit, rpl_BaseTypes_unit, SysUtils,
  rpl_ResourceString_unit, Classes, rpl_ProgressState_Unit;
type
  TrplCommand = (cNone, cImport, cExport);
  TrplCommandLineInterpreter = class(TObject)
  protected
    FServer: string;
//    FDBFileName: string;
    FFileName: string;
    FUser: string;
    FCommand: TrplCommand;
    FSDBName: string;
    FPassword: string;
    FCharSet: string;
  public
  published
    function Execute: Boolean;
    function NoWallImage: boolean;
  end;

function CommandLineInterpreter: TrplCommandLineInterpreter;
implementation
var
  _CommandLineInterpreter: TrplCommandLineInterpreter;

function CommandLineInterpreter: TrplCommandLineInterpreter;
begin
 if _CommandLineInterpreter = nil then
 begin
   _CommandLineInterpreter := TrplCommandLineInterpreter.Create;
 end;

 Result := _CommandLineInterpreter;
end;
{ TrplCommandLineInterpreter }

function TrplCommandLineInterpreter.Execute: Boolean;
var
  I: Integer;
  S: String;
  C: Integer;
  Str: TStream;
  Index: Integer;
begin
  C := 0;
  FCommand := cNone;
  for I := 0 to CommandString.Count - 1 do
  begin
    //  Имя сервера
    if (CompareAnyString(CommandString[I], ['-SN', '/SN'])) and (I < CommandString.Count - 1) then
    begin
      S := CommandString[I + 1];
      if (Length(S) > 1) and (S[1] = '"')
        and (S[Length(S)] = '"') then
      begin
        S := Copy(S, 2, Length(S) - 2);
      end;
      FServer := S;
      Inc(C);
    end else
    // имя базы данных
{    if (CompareAnyString(CommandString[I], ['-DBN', '/DBN'])) and (I < CommandString.Count - 1) then
    begin
      S := CommandString[I + 1];
      if (Length(S) > 1) and (S[1] = '"')
        and (S[Length(S)] = '"') then
      begin
        S := Copy(S, 2, Length(S) - 2);
      end;
      FDBFileName := S;
    end else}
    // Имя пользователя
    if (CompareAnyString(CommandString[I], ['/USER', '-USER'])) and (I < CommandString.Count - 1) then
    begin
      if I <= CommandString.Count - 2 then
      begin
        FUser := CommandString[I + 1];
        Inc(C);
      end;
    end else
    // Импортировать файл
    if (CompareAnyString(CommandString[I], ['/IF', '-IF'])) and (I < CommandString.Count - 1) then
    begin
      FCommand := cImport;
      if I <= CommandString.Count - 2 then
      begin
        FFileName := CommandString[I + 1];
        Inc(C);
      end;
    end else
    // Импортировать файл
    if (CompareAnyString(CommandString[I], ['/EF', '-EF'])) and (I < CommandString.Count - 1) then
    begin
      FCommand := cExport;
      if I <= CommandString.Count - 3 then
      begin
        FSDBName := CommandString[I + 1];
        FFileName := CommandString[I + 2];
        Inc(C);
      end;
    end else
    //  Пароль
    if (CompareAnyString(CommandString[I], ['/PASSWORD', '-PASSWORD'])) and (I < CommandString.Count - 1) then
    begin
      if I <= CommandString.Count - 2 then
      begin
        FPassword := CommandString[I + 1];
        Inc(C);
      end;
    end else
    //Кодовая страница
    if (CompareAnyString(CommandString[I], ['/CHARSET', '-CHARSET'])) and (I < CommandString.Count - 1) then
    begin
      if I <= CommandString.Count - 2 then
      begin
        FCharSet := CommandString[I + 1];
        Inc(C);
      end;
    end;
  end;

  Result := C > 0;

  if Result then
  begin
    try
      ReplDataBase.LoginPrompt := False;
      ReplDataBase.DatabaseName := FServer;
      ReplDataBase.Params.Add('user_name=' + FUser);
      ReplDataBase.Params.Add('password=' + FPassword);
      ReplDataBase.Params.Add('lc_ctype=' + FCharSet);

      ReplDataBase.Connected := True;

      if ReplDataBase.CheckReplicationSchema then
      begin
        case FCommand of
          cImport:
          begin
            if FFileName = '' then raise Exception.Create(EnterReplicationFileName);
            Str := TFileStream.Create(FFileName, fmOpenRead);
            try
              ProgressState := TSimpleProgressState.Create;
              try
                ReplicationServer.ImportData(Str, True);
              finally
                FreeAndNil(ProgressState);
              end;
            finally
              Str.Free;
            end;
          end;
          cExport:
          begin
            if FFileName = '' then raise Exception.Create(EnterReplicationFileName);
            Str := TFileStream.Create(FFileName, fmOpenReadWrite or fmCreate);
            try
              if FSDBName = '' then raise Exception.Create(EnterDBName);
              Index := ReplDataBase.DBList.IndexByDBName(FSDBName);
              if Index > - 1 then
              begin
                ProgressState := TSimpleProgressState.Create;
                try
                  ReplicationServer.ExportData(Str, ReplDataBase.DBList.ItemsByIndex[Index].DBKey);
                finally
                  FreeAndNil(ProgressState);
                end;
              end else
                raise Exception.Create(Format(InvalidDataBaseName, [FSDBName]));
            finally
              Str.Free;
            end;
          end;
        end;
      end else
        raise Exception.Create(ReplicationSchemaNotFound);
    except
      on E: Exception do
      begin
        ShowErrorMessage(E.Message, MSG_CAPTION);
      end
    end;
  end;
end;

function TrplCommandLineInterpreter.NoWallImage: boolean;
var
  i: integer;
begin
  Result:= False;
  for I := 0 to CommandString.Count - 1 do
    if CompareAnyString(CommandString[I], ['-NOWALL', '/NOWALL']) then begin
      Result:= True;
      Exit
    end;
end;

end.
