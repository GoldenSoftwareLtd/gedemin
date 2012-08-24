
{++

  Copyright (c) 1997-98 by Golden Software of Belarus

  Module

    xsstart.pas

  Abstract

    ...

  Author

    Andrei Kireev (22-May-1997)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    22-may-97    andreik    Initial version.
    1.01    19-jul-97    mikle      Minor bug fixed.
    1.02    20-jul-97    andreik    ForceNormalShutdown method added.
    1.03    21-jul-97    andreik    ForceNormalShutdown method added.
    1.04    10-jul-98    andreik    Logging added.
    1.05    19-nov-98    andreik    LoggingEnabled added.

--}


unit xSStart;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  { start types }
  TStartType = (stNormal, stAfterCrash, stVeryFirst);

type
  TxSafeStart = class(TComponent)
  private
    FStartType: TStartType;

    FOnNormalStart: TNotifyEvent;
    FOnAfterCrash: TNotifyEvent;
    FOnVeryFirstStart: TNotifyEvent;

    OldOnCreate: TNotifyEvent;
    FLoggingEnabled: Boolean;

    procedure DoOnCreate(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure WriteLogString(const S: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ForceNormalShutdown;

  published
    property StartType: TStartType read FStartType stored False;
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled
      default True;

    property OnNormalStart: TNotifyEvent read FOnNormalStart write FOnNormalStart
      stored True;
    property OnAfterCrash: TNotifyEvent read FOnAfterCrash write FOnAfterCrash
      stored True;
    property OnVeryFirstStart: TNotifyEvent read FOnVeryFirstStart write FOnVeryFirstStart
      stored True;
  end;

procedure Register;

var
  SafeStart: TxSafeStart;

implementation

uses
  xAppReg;

var
  LogFileName: String;

procedure __WriteLogString(const S: String);
var
  F: TextFile;
begin
  AssignFile(F, LogFileName);
  if FileExists(LogFileName) then
    Append(F)
  else
    Rewrite(F);
  Writeln(F, DateTimeToStr(Now) + ': ' + S);

  CloseFile(F);
end;

constructor TxSafeStart.Create(AnOwner: TComponent);
begin
  if SafeStart <> nil then
    raise Exception.Create('Only one instance allowed');

  inherited Create(AnOwner);

  FLoggingEnabled := True;

  if AppRegistry.ReadBoolean('SS', 'FS', True) then
  begin
    FStartType := stVeryFirst;
    AppRegistry.WriteBoolean('SS', 'FS', False);
  end
  else if AppRegistry.ReadBoolean('SS', 'NS', False) then
  begin
    FStartType := stNormal;
    AppRegistry.WriteBoolean('SS', 'NS', False);
  end else
  begin
    FStartType := stAfterCrash;
  end;

  SafeStart := Self;
end;

destructor TxSafeStart.Destroy;
begin
  inherited Destroy;
  if AppRegistry <> nil then
    AppRegistry.WriteBoolean('SS', 'NS', True);
  SafeStart := nil;
end;

procedure TxSafeStart.ForceNormalShutdown;
begin
  if AppRegistry <> nil then
    AppRegistry.WriteBoolean('SS', 'NS', True);
end;

procedure TxSafeStart.Loaded;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    if Owner is TForm then
    begin
      OldOnCreate := (Owner as TForm).OnCreate;
      (Owner as TForm).OnCreate := DoOnCreate;
    end;
  end;

  if FLoggingEnabled then
    case FStartType of
      stVeryFirst: WriteLogString('Самый первый запуск программы.');
      stNormal: WriteLogString('Нормальный запуск.');
      stAfterCrash: WriteLogString('Запуск после некорректного выхода.');
    end;
end;

procedure TxSafeStart.WriteLogString(const S: String);
begin
  __WriteLogString(S);
end;

procedure TxSafeStart.DoOnCreate(Sender: TObject);
begin
  case StartType of
    stNormal: if Assigned(FOnNormalStart) then FOnNormalStart(Self);
    stAfterCrash: if Assigned(FOnAfterCrash) then FOnAfterCrash(Self);
    stVeryFirst: if Assigned(FOnVeryFirstStart) then FOnVeryFirstStart(Self);
  end;

  if Assigned(OldOnCreate) then
    OldOnCreate(Sender);
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TxSafeStart]);
end;

var
  OldExceptProc: Pointer;

procedure MyExceptProc; far;
begin
  ExceptProc := OldExceptProc;
  __WriteLogString('Ошибка в программе.');
end;

initialization
  SafeStart := nil;

  LogFileName := ExtractFilePath(Application.ExeName) + 'start.log';

  OldExceptProc := ExceptProc;
  ExceptProc := @MyExceptProc;
end.

