unit ExcMagic_Gedemin;

interface

uses
  Classes, ExcMagic, ExcMagicGUI;

type
  TgdExceptionFilter = class(TBaseExcMagicFilter)
    function  ShowException(ExceptionObject: TObject; Title: String; ExceptionMessage: String;
      CallStack: TStrings; Registers: TStrings; CustomInfo: TStrings): Integer; override;
    function  LogException(ExceptionObject: TObject; Buffer: PChar; BufferSize: Integer;
      CallStack: TStrings; Registers: TStrings; CustomInfo: TStrings): Integer; override;
    function  ExceptionMessage(ExceptionObject: TObject; MessageInfo: TExceptionMessageInfo;
      Buffer: PChar; BufferSize: Integer; CustomInfo: TStrings): Integer; override;
  end;

implementation

uses
  SysUtils, gdcJournal;

var
  gdExceptionFilter: IExcMagicFilter;

function TgdExceptionFilter.ShowException(ExceptionObject: TObject; Title: String;
  ExceptionMessage: String; CallStack: TStrings; Registers: TStrings; CustomInfo: TStrings): Integer;
begin
  TgdcJournal.AddEvent(ExceptionMessage + #13#10'Call stack:'#13#10 + CallStack.Text,
    'Exception',
    -1,
    nil,
    True);

  Result := EXC_FILTER_CONTINUE;
end;

function TgdExceptionFilter.LogException(ExceptionObject: TObject; Buffer: PChar; BufferSize: Integer;
  CallStack: TStrings; Registers: TStrings; CustomInfo: TStrings): Integer;
begin
  Result := EXC_FILTER_CONTINUE;
end;

function TgdExceptionFilter.ExceptionMessage(ExceptionObject: TObject; MessageInfo: TExceptionMessageInfo;
  Buffer: PChar; BufferSize: Integer; CustomInfo: TStrings): Integer;
begin
  Result := EXC_FILTER_CONTINUE;
end;

initialization
  gdExceptionFilter := TgdExceptionFilter.Create;
  ExceptionHook.RegisterExceptionFilter(Exception, gdExceptionFilter, False);
  ExceptionHook.LogEnabled := False;

finalization
  ExceptionHook.UnRegisterExceptionFilter(gdExceptionFilter);
  gdExceptionFilter := nil;
end.