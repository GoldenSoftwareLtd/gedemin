
unit gd_CmdLineParams_unit;

interface

uses
  Classes, Windows;

type
  Tgd_CmdLineParams = class(TObject)
  private
    FUnMethodMacro: Boolean;
    FUnEventMacro: Boolean;
    FServerName: String;
    FUserName: String;
    FUserPassword: String;
    FUseLog: Boolean;
    FSaveLogToFile: Boolean;
    FLoadSettingPath: String;
    FLoadSettingFileName: String;
    FTraceSQL: Boolean;
    FUILanguage: String;
    FLangSave: Boolean;
    FLangFile: String;
    FNoGarbageCollect: Boolean;
    FNoSplash: Boolean;
    FQuietMode: Boolean;
    FNoCache: Boolean;
    FClearDBID: Boolean;
    FUnmethod: Boolean;
    FUnevent: Boolean;
    FEmbedding: Boolean;
    FRestorePageSize: Integer;
    FRestoreBufferSize: Integer;
    FRestoreUser: String;
    FRestorePassword: String;
    FRestoreServer: String;
    FRestoreBKFile: String;
    FRestoreDBFile: String;
    FWarning: String;
    FRemoteServer: String;
    FSendLogEmail: String;
    FConvertDocOptions: Boolean;
    FRun: String;
    FExit: Boolean;

    function StripQuotes(const S: String): String;
    function CompareAnyString(const S: String; const S2: array of String): Boolean; overload;
    function CompareAnyString(const S: String; const S2: array of String; out Value: String): Boolean; overload;

  protected
    procedure Clear;
    procedure ReadCmdLine(const ACmdLine: String);

  public
    constructor Create;

    function CouldShowSplash: Boolean;

    property UnMethodMacro: Boolean read FUnMethodMacro;
    property UnEventMacro: Boolean read FUnEventMacro;
    property ServerName: String read FServerName;
    property UserName: String read FUserName;
    property UserPassword: String read FUserPassword;
    property UseLog: Boolean read FUseLog;
    property SaveLogToFile: Boolean read FSaveLogToFile;
    property LoadSettingPath: String read FLoadSettingPath;
    property LoadSettingFileName: String read FLoadSettingFileName;
    property TraceSQL: Boolean read FTraceSQL;
    property UILanguage: String read FUILanguage;
    property LangSave: Boolean read FLangSave;
    property LangFile: String read FLangFile;
    property NoGarbageCollect: Boolean read FNoGarbageCollect;
    property NoSplash: Boolean read FNoSplash;
    property QuietMode: Boolean read FQuietMode;
    property NoCache: Boolean read FNoCache;
    property ClearDBID: Boolean read FClearDBID;
    property Unmethod: Boolean read FUnmethod;
    property Unevent: Boolean read FUnevent;
    property Embedding: Boolean read FEmbedding;
    property RestoreServer: String read FRestoreServer;
    property RestoreBKFile: String read FRestoreBKFile;
    property RestoreDBFile: String read FRestoreDBFile;
    property RestoreUser: String read FRestoreUser;
    property RestorePassword: String read FRestorePassword;
    property RestorePageSize: Integer read FRestorePageSize;
    property RestoreBufferSize: Integer read FRestoreBufferSize;
    property Warning: String read FWarning;
    property RemoteServer: String read FRemoteServer;
    property SendLogEmail: String read FSendLogEmail;
    property ConvertDocOptions: Boolean read FConvertDocOptions;
    property Run: String read FRun;
    property _Exit: Boolean read FExit;
  end;

var
  gd_CmdLineParams: Tgd_CmdLineParams;

implementation

uses
  Forms, SysUtils, jclStrings;

{ Tgd_CmdLineParams }

procedure Tgd_CmdLineParams.Clear;
begin
  FUnMethodMacro := False;
  FUnEventMacro := False;
  FServerName := '';
  FUserName := '';
  FUserPassword := '';
  FUseLog := False;
  FSaveLogToFile := False;
  FLoadSettingPath := '';
  FLoadSettingFileName := '';
  FTraceSQL := False;
  FUILanguage := '';
  FLangSave := False;
  FLangFile := '';
  FNoGarbageCollect := False;
  FNoSplash := False;
  FQuietMode := False;
  FNoCache := False;
  FClearDBID := False;
  FUnmethod := False;
  FUnevent := False;
  FEmbedding := False;
  FRestorePageSize := 0;
  FRestoreBufferSize := 0;
  FRestoreUser := '';
  FRestorePassword := '';
  FRestoreServer := '';
  FRestoreBKFile := '';
  FRestoreDBFile := '';
  FWarning := '';
end;

function Tgd_CmdLineParams.CompareAnyString(const S: String;
  const S2: array of String): Boolean;
var
  I: Integer;
begin
  for I := Low(S2) to High(S2) do
  begin
    if (AnsiCompareText(S, '/' + S2[I]) = 0) or
      (AnsiCompareText(S, '-' + S2[I]) = 0) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function Tgd_CmdLineParams.CompareAnyString(const S: String;
  const S2: array of String; out Value: String): Boolean;
var
  I, P: Integer;
  Key: String;
begin
  P := Pos(':', S);
  if P > 0 then
  begin
    Key := Copy(S, 1, P - 1);
    Value := Copy(S, P + 1, 1024);
  end else
  begin
    Key := S;
    Value := '';
  end;

  for I := Low(S2) to High(S2) do
  begin
    if (AnsiCompareText(Key, '/' + S2[I]) = 0) or
      (AnsiCompareText(Key, '-' + S2[I]) = 0) then
    begin
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function Tgd_CmdLineParams.CouldShowSplash: Boolean;
begin
  Result := (not NoSplash) and (not Embedding) and (not QuietMode)
    and (LoadSettingPath = '')
    and (RestoreBKFile = ''); 
end;

constructor Tgd_CmdLineParams.Create;
begin
  inherited;
  ReadCmdLine(GetCommandLine);
end;

procedure Tgd_CmdLineParams.ReadCmdLine(const ACmdLine: String);
var
  SL: TStringList;
  I, J: Integer;
  Value: String;
  {$IFDEF DUNIT_TEST}
  h: THandle;
  ss: array [0..0] of PChar;
  LogType: Integer;
  {$ENDIF}
begin
  Clear;

  SL := TStringList.Create;
  try
    ExtractStrings([' '], [' '], PChar(ACmdLine), SL);

    for J := 0 to SL.Count - 1 do
      SL[J] := StripQuotes(SL[J]);

    I := 0;
    while I < SL.Count do
    begin
      if CompareAnyString(SL[I], ['SL']) and (I < SL.Count - 1)
        and (Copy(SL[I + 1], 1, 1) <> '/')
        and (Copy(SL[I + 1], 1, 1) <> '-') then
      begin
        Inc(I);
        FSendLogEmail := SL[I];
      end else

      if CompareAnyString(SL[I], ['LANG'], Value) then
      begin
        FUILanguage := LowerCase(Value);
      end else

      if CompareAnyString(SL[I], ['LANGSAVE']) then
      begin
        FLangSave := True;
      end else

      if CompareAnyString(SL[I], ['LANGFILE'], Value) then
      begin
        FLangFile := Value;
      end else

      if CompareAnyString(SL[I], ['NGC']) then
      begin
        FNoGarbageCollect := True;
      end else

      if CompareAnyString(SL[I], ['NS']) then
      begin
        FNoSplash := True;
      end else

      if CompareAnyString(SL[I], ['Q']) then
      begin
        FQuietMode := True;
      end else

      if CompareAnyString(SL[I], ['NC']) then
      begin
        FNoCache := True;
      end else

      if CompareAnyString(SL[I], ['RD']) then
      begin
        FClearDBID := True;
      end else

      if CompareAnyString(SL[I], ['UNMETHOD']) then
      begin
        FUnmethod := True;
      end else

      if CompareAnyString(SL[I], ['UNEVENT']) then
      begin
        FUnevent := True;
      end else

      if CompareAnyString(SL[I], ['EMBEDDING']) then
      begin
        FEmbedding := True;
      end else

      //
      //  Имя сервера

      if CompareAnyString(SL[I], ['SN']) and (I < SL.Count - 1) then
      begin
        Inc(I);
        FServerName := SL[I];
      end else

      //
      // Имя пользователя

      if CompareAnyString(SL[I], ['USER']) and (I < SL.Count - 1) then
      begin
        Inc(I);
        FUserName := SL[I];
      end else

      //
      //  Пароль

      if CompareAnyString(SL[I], ['PASSWORD']) and (I < SL.Count - 1) then
      begin
        Inc(I);
        FUserPassword := SL[I];
      end else

      // Отключение перекрытия методов
      if CompareAnyString(SL[I], ['UNMETHOD']) then
      begin
        FUnMethodMacro := True;
      end else

      if CompareAnyString(SL[I], ['UNEVENT']) then
      begin
        FUnEventMacro := True;
      end else

      if CompareAnyString(SL[I], ['LOG']) then
      begin
        FUseLog := True;
      end else

      if CompareAnyString(SL[I], ['LOGFILE']) then
      begin
        FUseLog := True;
        FSaveLogToFile := True;
      end else

      if CompareAnyString(SL[I], ['TRACE']) then
      begin
        FTraceSQL := True;
      end else

      if CompareAnyString(SL[I], ['CDO']) then
      begin
        FConvertDocOptions := True;
      end else

      if CompareAnyString(SL[I], ['EXIT']) then
      begin
        FExit := True;
      end else

      if CompareAnyString(SL[I], ['RS'])
        and (I < SL.Count - 1) then
      begin
        Inc(I);
        FRemoteServer := SL[I];
      end else

      if CompareAnyString(SL[I], ['RUN'])
        and (I < SL.Count - 1) then
      begin
        Inc(I);
        FRun := SL[I];
      end else

      if CompareAnyString(SL[I], ['SETTINGPATH', 'SP'])
        and (I < SL.Count - 1) then
      begin
        Inc(I);
        FLoadSettingPath := SL[I];
      end else

      if CompareAnyString(SL[I], ['SETTINGFILENAME', 'SFN'])
        and (I < SL.Count - 1) then
      begin
        Inc(I);
        FLoadSettingFileName := SL[I];
      end else

      if CompareAnyString(SL[I], ['R'])
        and (I < SL.Count - 7) then
      begin
        FRestoreServer := SL[I + 1];
        FRestoreBKFile := SL[I + 2];
        FRestoreDBFile := SL[I + 3];
        FRestoreUser := SL[I + 4];
        FRestorePassword := SL[I + 5];
        FRestorePageSize := StrToIntDef(SL[I + 6], 8192);
        FRestoreBufferSize := StrToIntDef(SL[I + 7], 1024);
        Inc(I, 7);
      end else

      if StrIPos(ExtractFileName(Application.EXEName), SL[I]) = 0 then
      begin
        FWarning := FWarning + SL[I] + ' ';
      end;

      Inc(I);
    end;
  finally
    SL.Free;
  end;

  {$IFDEF DUNIT_TEST}
  if Warning > '' then
  begin
    LogType := EVENTLOG_WARNING_TYPE;
    ss[0] := PChar('Неверный параметр командной строки ' + Warning);
    h := RegisterEventSource(nil, 'Gedemin');
    try
      if h <> 0 then
        ReportEvent(h,          // event log handle
          LogType,              // event type
          0,                    // category zero
          0,                    // event identifier
          nil,                  // no user security identifier
          1,                    // one substitution string
          0,                    // no data
          @ss,                  // pointer to string array
          nil);                 // pointer to data
      // code from http://stackoverflow.com/questions/397934/writing-to-the-event-log-in-delphi
    finally
      DeregisterEventSource(h);
    end;
  end;
  {$ENDIF}

  {$IFDEF DEBUG}
  LogType := EVENTLOG_INFORMATION_TYPE;
  ss[0] := PChar('Параметры командной строки: ' + ACmdLine);
  h := RegisterEventSource(nil, 'Gedemin');
  try
    if h <> 0 then
      ReportEvent(h,          // event log handle
        LogType,              // event type
        0,                    // category zero
        0,                    // event identifier
        nil,                  // no user security identifier
        1,                    // one substitution string
        0,                    // no data
        @ss,                  // pointer to string array
        nil);                 // pointer to data
    // code from http://stackoverflow.com/questions/397934/writing-to-the-event-log-in-delphi
  finally
    DeregisterEventSource(h);
  end;
  {$ENDIF}
end;

function Tgd_CmdLineParams.StripQuotes(const S: String): String;
begin
  if (Length(S) > 1) and (S[1]= '"') and (S[Length(S)] = '"') then
    Result := Copy(S, 2, Length(S) - 2)
  else
    Result := S;
end;

initialization
  gd_CmdLineParams := Tgd_CmdLineParams.Create;

finalization
  FreeAndNil(gd_CmdLineParams);
end.