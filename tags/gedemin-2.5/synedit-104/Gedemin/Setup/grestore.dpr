program grestore;
{$APPTYPE CONSOLE}
uses
  SysUtils, 
  IBServices, 
  Windows, 
  gd_Encrypt;

procedure IncorrectParams;
begin
  MessageBox(0, 'Некорректные параметры', 'Вниамние',
             MB_ICONSTOP or MB_OK);
  Halt(0);
end;

var
  FServerName, FDbName, FUser, FPassword: String; 
  FProtocol: TProtocol;
begin
  FProtocol := TCP;
  if not (ParamCount in [5, 6]) then IncorrectParams;            
  
  if MessageBox(0, 'Процесс апгрейда БД не был завершен. '#10#13 + 
                'Перевести БД в многопользовательский режим? ',
                'Внимание',
                MB_ICONQUESTION or MB_YESNO) = IDNO then Exit;


  FServerName := ParamStr(1);
  FDbName := ParamStr(2);      
    
  if AnsiUpperCase(ParamStr(3)) = 'TCP' then
    FProtocol := TCP
  else
    if AnsiUpperCase(ParamStr(3)) = 'SPX' then
      FProtocol := SPX
    else
      if AnsiUpperCase(ParamStr(3)) = 'NAMEDPIPE' then
        FProtocol := NamedPipe
      else
        if AnsiUpperCase(ParamStr(3)) = 'LOCAL' then
          FProtocol := Local
        else
          IncorrectParams;    

  FUser := ParamStr(4);  
  if AnsiUpperCase(ParamStr(6)) = '-R' then
    FPassword := DecodeString(ParamStr(5), ParamStr(2)) 
  else
    FPassword := ParamStr(5);        

  try
    //Удаляем временный файл
   
    //Переводим БД в многопользовательский режим
    with TIBConfigService.Create(nil) do
    try
      ServerName := FServerName;
      Protocol := FProtocol;
      DatabaseName := FDbName;
      Params.Add('user_name=' + FUser);
      Params.Add('password=' + FPassword);
      LoginPrompt := False;
      Active := True;
      BringDatabaseOnline;

      while IsServiceRunning do Sleep(5);

      Active := False;
    
      MessageBox(0, 'БД переведена в многопользовательский режим.',
                  '', MB_ICONINFORMATION or MB_OK);
                
    finally
      Free;
    end;

  except
    MessageBox(0, 'Ошибка при переводе базы в многопользовательский режим',
               'Внимание', MB_ICONSTOP or MB_OK);
  end;

  if FileExists(ExtractFilePath(FDbName) + 'gdbase_new.gdb') then
    DeleteFile(PChar(ExtractFilePath(FDbName) + 'gdbase_new.gdb'));

end. 
