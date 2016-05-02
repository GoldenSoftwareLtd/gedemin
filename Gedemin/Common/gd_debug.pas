
unit gd_debug;

// гэты код уведзены спецы€льна, каб нельга было перакамп≥л≥раваць
// модуль без вызначанага сымбал€ ҐмоҐнай камп≥л€цы≥.
{$IFNDEF DEBUG}
...
{$ENDIF}

interface

procedure LogRecord(const S: String); overload;
procedure LogRecord(const S: String; const I: Integer); overload;

implementation

uses
  gdccClient_unit, SysUtils;

procedure LogRecord(const S: String); overload;
begin
  if gdccClient <> nil then
  begin
    gdccClient.AddLogRecord('debug', S);
  end;
end;

procedure LogRecord(const S: String; const I: Integer); overload;
begin
  LogRecord(S + ', ' + IntToStr(I));
end;

end.

