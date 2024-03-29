// ShlTanya, 24.02.2019

unit gd_debug;

// ���� ��� �������� ����������, ��� ������ ���� ���������������
// ������ ��� ����������� ������� ������ ���������.
{$IFNDEF DEBUG}
...
{$ENDIF}

interface

procedure LogRecord(const S: String); overload;
procedure LogRecord(const S: String; const I: Int64); overload;

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

procedure LogRecord(const S: String; const I: Int64); overload;
begin
  LogRecord(S + ', ' + IntToStr(I));
end;

end.

