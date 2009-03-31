
(*

  З мэтай адладкі мы ствараем лог файл. Гэжта тэкставы файл, які
  мае такую ж назву, як і асноўны экзэшнік і расшырэньне ЛОГ.

  Каб выкарыстоўваць ЛОГ файл трэба: па-першае, вызначыць сымбаль
  умоўнай кампіляцыі DEBUG, па-другое, падключыць модуль
  gd_debug, абавязкова праз умоўную кампіляцыю:

  ...
  {$IFDEF DEBUG}
  gd_debug,
  {$ENDIF}
  ...

  Пасля гэтага можна карыстацца працэдурамі LogRecord для занясеньня запісаў
  у ЛОГ файл.

  З дапамогай DeleteLogFile -- можна выдаліць ЛОГ файл.

*)

unit gd_debug;

// гэты код уведзены спецыяльна, каб нельга было перакампіліраваць
// модуль без вызначанага сымбаля ўмоўнай кампіляцыі.
{$IFNDEF DEBUG}
...
{$ENDIF}

interface

procedure LogRecord(const S: String); overload;
procedure LogRecord(const S: String; const I: Integer); overload;
procedure DeleteLogFile;

implementation

uses
  Forms, SysUtils;

var
  LogFileName: String;

procedure CreateLogFileName;
begin
  LogFileName := ChangeFileExt(Application.EXEName, '.LOG');
end;

function GetTimeStamp: String;
begin
  Result := FormatDateTime('dd.mm.yy hh:nn:ss', Now);
end;

procedure DeleteLogFile;
begin
  if LogFileName = '' then
    CreateLogFileName;

  DeleteFile(LogFileName);
end;

procedure LogRecord(const S: String);
var
  FText: TextFile;
begin
  if LogFileName = '' then
    CreateLogFileName;

  AssignFile(FText, LogFileName);
  if FileExists(LogFileName) then
    Append(FText)
  else
    Rewrite(FText);  
  try
    Writeln(FText, GetTimeStamp + '  ' + S);
  finally
    CloseFile(FText);
  end;
end;

procedure LogRecord(const S: String; const I: Integer);
begin
  LogRecord(S + ', ' + IntToStr(I));
end;

initialization
  LogFileName := '';

end.

