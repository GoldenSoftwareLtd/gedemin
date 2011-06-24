{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gd_DebugLog.pas

  Abstract

    Gedemin project. TMacrosLog.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.04.01    tiptop        Initial version.

--}

unit gd_DebugLog;

interface

uses
  Classes, prp_dlgEventProperty_unit, Windows;

type
  TOnAddLog = procedure (Sender: TObject; Str: String) of Object;

type
  TMacrosLog = class(TObject)
  private
    FStream: TStream;
    FStrings: TStrings;
    FSettings: TEventLogSettings;
    FOnAddLog: TOnAddLog;
    FStreamChecked: Boolean;
    procedure SetStrings(const Value: TStrings);
    procedure SetOnAddLog(const Value: TOnAddLog);
    procedure SetSettings(const Value: TEventLogSettings);
  protected
    function CheckFileStream: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Log(AString: string);
    procedure LogLn(AString: string);

    property Strings: TStrings read FStrings write SetStrings;
    property Settings: TEventLogSettings read FSettings write SetSettings;
    property OnAddLog: TOnAddLog read FOnAddLog write SetOnAddLog;
  end;

var
  UseLog: Boolean;
  SaveLogToFile: Boolean;

function Log: TMacrosLog;

implementation

uses
  Forms, Sysutils
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  _Log: TMacrosLog;

function Log: TMacrosLog;
begin
  if _Log = nil then
  begin
    _Log := TMacrosLog.Create;
  end;

  Result := _Log;
end;
{ TMacrosLog }

procedure TMacrosLog.Log(AString: string);
begin
end;

procedure TMacrosLog.LogLn(AString: string);
{$IFDEF DEBUG}
var
  L: Integer;
  I: Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  if UseLog then
  begin
    AString := DateTimeToStr(Now) + AString;
    if not SaveLogToFile and Assigned(FStrings) then
    begin
      FStrings.Add(AString);
      if not FSettings.UnlimitSize and (FSettings.EventSize <
        FStrings.Count) then
        for I := FStrings.Count - FSettings.EventSize - 1 downto 0 do
          FStrings.Delete(I);
      if Assigned(FOnAddLog) then
        FOnAddLog(Self, AString);
    end else
    if CheckFileStream then
    begin
      L := Length(AString);
      FStream.WriteBuffer(AString[1], L);
      FStream.WriteBuffer(#13#10, 2);
    end
  end;
  {$ENDIF}
end;

constructor TMacrosLog.Create;
begin
  FStrings := TStringList.Create;
  Settings := LoadSettings;
end;

destructor TMacrosLog.Destroy;
begin
  FStrings.Free;
  FStream.Free;
  inherited;
end;

procedure TMacrosLog.SetStrings(const Value: TStrings);
begin
  FStrings := Value;
  
end;

procedure TMacrosLog.SetOnAddLog(const Value: TOnAddLog);
begin
  FOnAddLog := Value;
end;

procedure TMacrosLog.SetSettings(const Value: TEventLogSettings);
begin
  FSettings := Value;
  UseLog := FSettings.UseEventLog;
end;

function TMacrosLog.CheckFileStream: Boolean;
begin
  Result := Assigned(FStream);
  if not Assigned(FStream) and not FStreamChecked then
  try
    try
      FStream := TFileStream.Create(ExtractFilePath(Application.ExeName) +
        'Macros.log', fmCreate or fmShareDenyWrite);
      FStreamChecked := True;
      Result := True;
    except
    end;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar(E.Message), 'Îøèáêà', MB_OK or MB_TASKMODAL);
      FStream := nil;
    end;
  end;
end;

initialization
  UseLog := False;
  SaveLogToFile := True;

finalization
  FreeAndNil(_Log);

end.
