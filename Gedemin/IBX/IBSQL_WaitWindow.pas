
unit IBSQL_WaitWindow;

interface

uses
  Classes, Windows, Messages, IBHeader, IBExternals;

type
  TIBSQL_WaitWindowThread = class(TThread)
  private
    FTimer: THandle;
    FCriticalSection: TRTLCriticalSection;
    FWnd, FLabel, FButton: hWnd;
    FStatusVector: PISC_STATUS;
    FDBHandle: PISC_DB_HANDLE;
    FCounter: Integer;

    procedure CreateWinAPIForm;
    procedure DestroyWinAPIForm;

  protected
    procedure Execute; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure StartSQL(AStatusVector: PISC_STATUS; ADBHandle: PISC_DB_HANDLE);
    procedure FinishSQL;
    procedure EndThread;
  end;

function IBSQL_WaitWindowThread: TIBSQL_WaitWindowThread;

implementation

uses
  SysUtils, Forms, IB, IBIntf;

const
  WindowClassName_Const = '_GdWaitWindowClass_';

  idLabel               = 1;
  idTimer               = 2;
  idButton              = 3;

  idStartMessage        = WM_USER + 0;
  idFinishMessage       = WM_USER + 1;
  idExitMessage         = WM_USER + 2;

  idMinMessage          = idStartMessage;
  idMaxMessage          = idExitMessage;

  InitialDelay          = 60000;
  RefreshRate           = 1000;

var
  _IBSQL_WaitWindowThread: TIBSQL_WaitWindowThread;

function IBSQL_WaitWindowThread: TIBSQL_WaitWindowThread;
begin
  if _IBSQL_WaitWindowThread = nil then
    _IBSQL_WaitWindowThread := TIBSQL_WaitWindowThread.Create;
  Result := _IBSQL_WaitWindowThread;
end;

{ TIBSQL_WaitWindowThread }

constructor TIBSQL_WaitWindowThread.Create;
var
  WC: TWndClassEx;
begin
  inherited Create(False);

  WC.cbsize := SizeOf(WC);
  WC.style := CS_NOCLOSE or CS_SAVEBITS or CS_BYTEALIGNWINDOW;
  WC.lpfnwndproc := @DefWindowProc;
  WC.cbclsextra := 0;
  WC.cbwndextra := 0;
  WC.hInstance := hInstance;
  WC.hIcon := LoadIcon(0, IDI_APPLICATION);
  WC.hCursor := LoadCursor(0, IDC_ARROW);
  WC.hbrBackground := 1;
  WC.lpszMenuName := nil;
  WC.lpszClassName := WindowClassName_Const;
  WC.hIconSm := LoadIcon(0, IDI_APPLICATION);
  Windows.RegisterClassEx(WC);

  FTimer := CreateWaitableTimer(nil, False, nil);
  InitializeCriticalSection(FCriticalSection);

  FreeOnTerminate := False;
  Priority := tpLowest;
end;

procedure TIBSQL_WaitWindowThread.CreateWinAPIForm;
const
  WindowHeight  = 86;
  WindowWidth   = 240;
  ButtonWidth   = 84;
  ButtonHeight  = 23;
var
  Style: Integer;
begin
  FWnd := CreateWindowEx(
    0,
    WindowClassName_Const,
    'Выполняется обработка данных...',
    WS_POPUPWINDOW or WS_DLGFRAME,
    (Screen.Width - WindowWidth) div 2,
    (Screen.Height - WindowHeight) div 2,
    WindowWidth,
    WindowHeight,
    0, 0,
    hInstance,
    nil);

  FLabel := CreateWindow(
    'static',
    '',
    WS_VISIBLE or WS_CHILD,
    12, 8,
    WindowWidth - 20, 20,
    FWnd,
    idLabel,
    hInstance,
    nil);

  if Assigned(fb_cancel_operation) then
    Style := 0
  else
    Style := WS_DISABLED;   

  FButton := CreateWindow(
    'button',
    'Прервать',
    Style or WS_VISIBLE or WS_CHILD or BS_PUSHBUTTON,
    (WindowWidth - ButtonWidth) div 2, 30,
    ButtonWidth, ButtonHeight,
    FWnd,
    idButton,
    hInstance,
    nil);

  SetTimer(FWnd, idTimer, RefreshRate, nil);

  SetWindowPos(FWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetForegroundWindow(FWnd);
  PostMessage(FWnd, WM_TIMER, idTimer, 0);
end;

destructor TIBSQL_WaitWindowThread.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);
  CloseHandle(FTimer);
  UnregisterClass(WindowClassName_Const, hInstance);
  inherited;
end;

procedure TIBSQL_WaitWindowThread.DestroyWinAPIForm;
begin
  DestroyWindow(FWnd);
end;

procedure TIBSQL_WaitWindowThread.EndThread;
begin
  if not Terminated then
  begin
    PostThreadMessage(ThreadID, idExitMessage, 0, 0);
    WaitFor;
  end;
end;

procedure TIBSQL_WaitWindowThread.Execute;
var
  H: THandle;
  T: Int64;
  FStartTime: TDateTime;
  Msg: TMsg;
  F: Boolean;
begin
  F := False;
  try
    while GetMessage(Msg, 0, 0, 0) do
    begin
      FStartTime := Now;

      repeat
        case Msg.Message of
          idStartMessage: F := True;
          idFinishMessage: F := False;
          idExitMessage: exit;
        end;
      until not PeekMessage(Msg, 0, 0, 0, PM_REMOVE);

      if not F then
        continue;

      T := -10000 * InitialDelay;
      SetWaitableTimer(FTimer, T, 0, nil, nil, False);
      try
        H := FTimer;
        if MsgWaitForMultipleObjects(1, H, False, INFINITE, QS_ALLINPUT) <> WAIT_OBJECT_0 then
          continue;
      finally
        CancelWaitableTimer(FTimer);
      end;

      CreateWinAPIForm;
      try
        while not Terminated do
        begin
          if GetMessage(Msg, 0, 0, 0) then
          begin
            case Msg.Message of
              idStartMessage:
              begin
                F := True;
                break;
              end;

              idFinishMessage:
              begin
                F := False;
                break;
              end;

              idExitMessage: exit;

              WM_TIMER: SetWindowText(FLabel,
                PChar('Время выполнения: ' + FormatDateTime('hh:nn:ss', Now - FStartTime)));

              WM_LBUTTONDOWN:
                if (Msg.hwnd = FButton) and Assigned(fb_cancel_operation) then
                begin
                  EnterCriticalSection(FCriticalSection);
                  try
                    fb_cancel_operation(FStatusVector,
                      FDBHandle,
                      fb_cancel_raise);
                  finally
                    LeaveCriticalSection(FCriticalSection);
                  end;

                  break;
                end;
            end;

            TranslateMessage(Msg);
            DispatchMessage(Msg);
          end else
            exit;
        end;
      finally
        DestroyWinAPIForm;
      end;
    end;
  except
    on E: Exception do
      OutputDebugString(PChar(E.Message));
  end;
end;

procedure TIBSQL_WaitWindowThread.FinishSQL;
begin
  Dec(FCounter);
  if FCounter = 0 then
    PostThreadMessage(ThreadID, idFinishMessage, 0, 0);
end;

procedure TIBSQL_WaitWindowThread.StartSQL(AStatusVector: PISC_STATUS;
  ADBHandle: PISC_DB_HANDLE);
begin
  if FCounter = 0 then
  begin
    EnterCriticalSection(FCriticalSection);
    try
      FStatusVector := AStatusVector;
      FDBHandle := ADBHandle;
    finally
      LeaveCriticalSection(FCriticalSection);
    end;
    while not PostThreadMessage(ThreadID, idStartMessage, 0, 0) do
      Sleep(1);
  end;
  Inc(FCounter);
end;

initialization
  _IBSQL_WaitWindowThread := nil;

finalization
  if _IBSQL_WaitWindowThread <> nil then
  begin
    _IBSQL_WaitWindowThread.EndThread;
    FreeAndNil(_IBSQL_WaitWindowThread);
  end;
end.



