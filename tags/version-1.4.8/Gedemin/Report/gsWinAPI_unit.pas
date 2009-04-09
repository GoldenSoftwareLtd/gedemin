
unit gsWinAPI_unit;

interface

uses
  Classes, SysUtils, Dialogs, contnrs, ComServ, ComObj, Gedemin_TLB;

type
  TgsWinAPI = class(TAutoObject, IgsWinAPI)
  private
  protected
    function  GetDC(hWnd: LongWord): LongWord; safecall;
    function  ReleaseDC(hWnd: LongWord; hDC: LongWord): Integer; safecall;
    function  GetTickCount: Integer; safecall;
    procedure Sleep(Param1: LongWord); safecall;
    function  GetAsyncKeyState(Param1: Integer): Integer; safecall;
    function  Beep(Freq: LongWord; Duration: LongWord): WordBool; safecall;
    function  GetKeyState(Param1: Integer): Integer; safecall;
    function  GetComputerName: WideString; safecall;
    function  GetTopWindow(hWnd: Integer): Integer; safecall;
    function  GetNextWindow(hWnd: Integer; wCmd: Integer): Integer; safecall;
    function  GetWindowText(hWnd: Integer): WideString; safecall;

    function  ArrangeIconicWindows(hWnd: LongWord): LongWord; safecall;
    function  BeginDeferWindowPos(nNumWindows: Integer): LongWord; safecall;
    function  BringWindowToTop(hWnd: LongWord): WordBool; safecall;
    function  CloseWindow(hWnd: LongWord): WordBool; safecall;

    function  DeferWindowPos(hWinPosInfo: LongWord; hWnd: LongWord; hWndInsertAfter: LongWord;
                             x: Integer; y: Integer; cx: Integer; cy: Integer; uFlags: LongWord): LongWord; safecall;
    function  EnableWindow(hWnd: LongWord; bEnable: WordBool): WordBool; safecall;
    function  EndDeferWindowPos(hWinPosInfo: LongWord): WordBool; safecall;
    function  FindWindow(const lpClassName: WideString; const lpWindowName: WideString): LongWord; safecall;
    function  GetClientRect(hWnd: LongWord; var Left: OleVariant; var Top: OleVariant;
                            var Right: OleVariant; var Bottom: OleVariant): WordBool; safecall;
    function  GetDesktopWindow: LongWord; safecall;
    function  GetForegroundWindow: LongWord; safecall;
    function  GetLastActivePopup(hWnd: LongWord): LongWord; safecall;
    function  GetParent(hWnd: LongWord): LongWord; safecall;
    function  GetWindow(hWnd: LongWord; uCmd: LongWord): LongWord; safecall;
    function  GetWindowRect(hWnd: LongWord; var Left: OleVariant; var Top: OleVariant;
                            var Right: OleVariant; var Bottom: OleVariant): WordBool; safecall;
    function  GetWindowTextLength(hWnd: LongWord): Integer; safecall;
    function  IsChild(hWndParent: LongWord; hWnd: LongWord): WordBool; safecall;
    function  IsIconic(hWnd: LongWord): WordBool; safecall;
    function  IsWindow(hWnd: LongWord): WordBool; safecall;
    function  IsWindowUnicode(hWnd: LongWord): WordBool; safecall;
    function  IsWindowVisible(hWnd: LongWord): WordBool; safecall;
    function  IsZoomed(hWnd: LongWord): WordBool; safecall;
    function  MoveWindow(hWnd: LongWord; x: Integer; y: Integer; nWidth: Integer; nHeight: Integer;
                         bRepaint: WordBool): WordBool; safecall;
    function  OpenIcon(hWnd: LongWord): WordBool; safecall;
    function  SetForegroundWindow(hWnd: LongWord): WordBool; safecall;
    function  SetParent(hWndChild: LongWord; hWndNewParent: LongWord): LongWord; safecall;
    function  SetWindowLong(hWnd: LongWord; nIndex: Integer; dwNewLong: Integer): Integer; safecall;
    function  SetWindowPos(hWnd: LongWord; hWndInsertAfter: LongWord; x: Integer; y: Integer;
                           cx: Integer; cy: Integer; uFlags: LongWord): WordBool; safecall;
    function  SetWindowText(hWnd: LongWord; const lpString: WideString): WordBool; safecall;
    function  ShowOwnedPopups(hWnd: LongWord; fShow: WordBool): WordBool; safecall;
    function  ShowWindow(hWnd: LongWord; nCmdShow: Integer): WordBool; safecall;
    function  AnyPopup: WordBool; safecall;

    function  ActivateKeyboardLayout(hkl: LongWord; Flags: LongWord): LongWord; safecall;
    function  GetActiveWindow: LongWord; safecall;
    function  GetFocus: LongWord; safecall;
    function  GetKeyboardLayoutName(const pwszKLID: WideString): WordBool; safecall;
    function  GetKeyNameText(lParam: Integer; const lpString: WideString; nSize: Integer): Integer; safecall;
    function  IsWindowEnabled(hWnd: LongWord): WordBool; safecall;
    procedure keybd_event(bVk: Shortint; bScan: Shortint; dwFlags: LongWord; dwExtraInfo: LongWord); safecall;
    function  LoadKeyboardLayout(const pwszKLID: WideString; Flags: LongWord): LongWord; safecall;
    function  MapVirtualKey(uCode: LongWord; uMapType: LongWord): LongWord; safecall;
    function  OemKeyScan(wOemChar: Word): LongWord; safecall;
    function  RegisterHotKey(hWnd: LongWord; id: Integer; fsModifiers: LongWord; vk: LongWord): WordBool; safecall;
    function  SetActiveWindow(hWnd: LongWord): LongWord; safecall;
    function  SetFocus(hWnd: LongWord): LongWord; safecall;
    function  UnloadKeyboardLayout(hkl: LongWord): WordBool; safecall;
    function  UnregisterHotKey(hWnd: LongWord; id: Integer): WordBool; safecall;
    function  VkKeyScan(ch: Byte): Smallint; safecall;
    function  GetKBCodePage: LongWord; safecall;

    function  GetCapture: LongWord; safecall;
    function  GetDoubleClickTime: LongWord; safecall;
    procedure mouse_event(dwFlags: LongWord; dx: LongWord; dy: LongWord; dwData: LongWord;
                          dwExtraInfo: LongWord); safecall;
    function  ReleaseCapture: WordBool; safecall;
    function  SetCapture(hWnd: LongWord): LongWord; safecall;
    function  SetDoubleClickTime(uInterval: LongWord): WordBool; safecall;
    function  SwapMouseButton(fSwap: WordBool): WordBool; safecall;

    function  DefWindowProc(hWnd: LongWord; Msg: LongWord; wParam: LongWord; lParam: LongWord): Integer; safecall;
    function  GetInputState: WordBool; safecall;
    function  GetMessageExtraInfo: Integer; safecall;
    function  GetMessagePos: LongWord; safecall;
    function  GetMessageTime: Integer; safecall;
    function  GetQueueStatus(flags: LongWord): LongWord; safecall;
    function  InSendMessage: WordBool; safecall;
    function  PostMessage(hWnd: LongWord; Msg: LongWord; wParam: Integer; lParam: Integer): WordBool; safecall;
    procedure PostQuitMessage(nExitCode: Integer); safecall;
    function  ReplyMessage(lResult: Integer): WordBool; safecall;
    function  SendMessage(hWnd: LongWord; Msg: LongWord; wParam: Integer; lParam: Integer): Integer; safecall;
    function  SendMessageTimeout(hWnd: LongWord; Msg: LongWord; wParam: Integer; lParam: Integer;
                                 fuFlag: LongWord; uTimeout: LongWord; var lpdwResult: OleVariant): Integer; safecall;
    function  SendNotifyMessage(hWnd: LongWord; Msg: LongWord; wParam: Integer; lParam: Integer): WordBool; safecall;
    function  SetMessageExtraInfo(lParam: Integer): Integer; safecall;
    function  WaitMessage: WordBool; safecall;
    function  GetModuleHandle(const ModuleName: WideString): Integer; safecall;
    function  LoadIcon(Instance: Integer; const IconName: WideString): Integer; safecall;
    function  GetSystemMetrics(Index: Integer): Integer; safecall;

    function  GetDeviceCaps(hdc: LongWord; nIndex: Integer): Integer; safecall;
    function  DrawIcon(hDC: LongWord; X: Integer; Y: Integer; hIcon: LongWord): WordBool; safecall;
    function  GetModuleFileName(Module: Integer): WideString; safecall;
    function  LoadLibrary(const lpLibFileName: WideString): LongWord; safecall;
    function  FreeLibrary(hLibModule: LongWord): WordBool; safecall;

    function  GetProfileInt(const lpAppName: WideString; const lpKeyName: WideString;
                            nDefault: LongWord): LongWord; safecall;
    function  GetProfileSection(const lpAppName: WideString; out lpReturnedString: OleVariant): LongWord; safecall;
    function  GetProfileString(const lpAppName: WideString; const lpKeyName: WideString;
                               const lpDefault: WideString; out lpReturnedString: OleVariant): LongWord; safecall;
    function  GetPrivateProfileInt(const lpAppName: WideString; const lpKeyName: WideString;
                                   nDefault: LongWord; const lpFileName: WideString): LongWord; safecall;
    function  GetPrivateProfileSection(const lpAppName: WideString;
                                       out lpReturnedString: OleVariant;
                                       const lpFileName: WideString): LongWord; safecall;
    function  GetPrivateProfileSectionNames(out lpszReturnBuffer: OleVariant;
                                            const lpFileName: WideString): LongWord; safecall;
    function  GetPrivateProfileString(const lpAppName: WideString; const lpKeyName: WideString;
                                      const lpDefault: WideString;
                                      out lpReturnedString: OleVariant; const lpFileName: WideString): LongWord; safecall;
    function ExitWindowsEx(uFlags: Integer; dwReserved: Integer): WordBool; safecall;
    function  ShellExecute(hwnd: LongWord; const lpOperation: WideString; const lpFile: WideString;
                           const lpParameters: WideString; const lpDirectory: WideString;
                           nShowCmd: Integer): LongWord; safecall;
    function  GetTempPath: WideString; safecall;
    function  GetTempFileName(const PathName: WideString; const PrefixString: WideString;
                              UniqueNumber: Integer): WideString; safecall;
    function  LockWindowUpdate(hWnd: LongWord): WordBool; safecall;
    function  WideCharToMultiByte(CodePage: Integer; const WideCharStr: WideString): WideString; safecall;
    function  MultiByteToWideChar(CodePage: Integer; const MultiByteStr: WideString): WideString; safecall;
  public
    destructor Destroy; override;

  end;

implementation

uses
  Windows, gd_SetDatabase, ShellAPI;

procedure WideStrToPChar(var Dest: PChar; const Source: WideString);
begin
  if Trim(Source) = '' then
  begin
    Dest := nil;
    Exit;
  end;

//  New(Dest);
  GetMem(Dest, Length(Source) + 1);
  Dest := StrPCopy(Dest, Source);
end;

procedure FreePChar(var P: PChar);
begin
  if P <> nil then
  begin
    Dispose(P);
  end;
  P := nil;
end;

{ TgsWinAPI }

destructor TgsWinAPI.Destroy;
begin
  inherited;
end;

function TgsWinAPI.GetAsyncKeyState(Param1: Integer): Integer;
begin
  Result := Windows.GetAsyncKeyState(Param1);
end;

function TgsWinAPI.GetDC(hWnd: LongWord): LongWord;
begin
  Result := Windows.GetDC(hWnd);
end;

function TgsWinAPI.GetTickCount: Integer;
begin
  Result := Integer(Windows.GetTickCount);
end;

function TgsWinAPI.Beep(Freq: LongWord; Duration: LongWord): WordBool;
begin
  Result := Windows.Beep(Freq , Duration);
end;

function TgsWinAPI.ReleaseDC(hWnd, hDC: LongWord): Integer;
begin
  Result := Windows.ReleaseDC(hWnd, hDC);
end;

procedure TgsWinAPI.Sleep(Param1: LongWord);
begin
  Windows.Sleep(Param1);
end;

function TgsWinAPI.GetKeyState(Param1: Integer): Integer;
begin
  Result := Windows.GetKeyState(Param1);
end;

function TgsWinAPI.GetComputerName: WideString;
begin
  Result := rpGetComputerName;
end;

function TgsWinAPI.GetNextWindow(hWnd, wCmd: Integer): Integer;
begin
  Result := Windows.GetNextWindow(hWnd, wCmd);
end;

function TgsWinAPI.GetTopWindow(hWnd: Integer): Integer;
begin
  Result := Windows.GetTopWindow(hWnd);
end;

function TgsWinAPI.GetWindowText(hWnd: Integer): WideString;
var
  B: array[0..1024] of Char;
begin
  Result := '';
  if Windows.GetWindowText(hWnd, B, SizeOf(B) - 1) > 0 then
    Result := StrPas(B);
end;

function TgsWinAPI.ArrangeIconicWindows(hWnd: LongWord): LongWord;
begin
  Result := Windows.ArrangeIconicWindows(hWnd);
end;

function TgsWinAPI.BeginDeferWindowPos(nNumWindows: Integer): LongWord;
begin
  Result := Windows.BeginDeferWindowPos(nNumWindows);
end;

function TgsWinAPI.BringWindowToTop(hWnd: LongWord): WordBool;
begin
  Result := Windows.BringWindowToTop(hWnd);
end;

function TgsWinAPI.CloseWindow(hWnd: LongWord): WordBool;
begin
  result := Windows.CloseWindow(hWnd);
end;

function TgsWinAPI.AnyPopup: WordBool;
begin
  result := Windows.AnyPopup;
end;

function TgsWinAPI.DeferWindowPos(hWinPosInfo, hWnd,
  hWndInsertAfter: LongWord; x, y, cx, cy: Integer;
  uFlags: LongWord): LongWord;
begin
  result := Windows.DeferWindowPos(hWinPosInfo, hWnd, hWndInsertAfter,
    x, y, cx, cy, uFlags);
end;

function TgsWinAPI.EnableWindow(hWnd: LongWord;
  bEnable: WordBool): WordBool;
begin
  result := Windows.EnableWindow(hWnd, bEnable)
end;

function TgsWinAPI.EndDeferWindowPos(hWinPosInfo: LongWord): WordBool;
begin
  result := Windows.EndDeferWindowPos(hWinPosInfo)
end;

function TgsWinAPI.FindWindow(const lpClassName,
  lpWindowName: WideString): LongWord;
var
  CN, WN: PChar;
begin
  WideStrToPChar(CN, lpClassName);
  WideStrToPChar(WN, lpWindowName);
  result := Windows.FindWindow(CN, WN);
  FreePChar(CN);
  FreePChar(WN);
end;

function TgsWinAPI.GetClientRect(hWnd: LongWord; var Left, Top, Right,
  Bottom: OleVariant): WordBool;
var
  LRect: TRect;
begin
  LRect.Left := Left;
  LRect.Top := Top;
  LRect.Right := Right;
  LRect.Bottom := Bottom;
  result := Windows.GetClientRect(hWnd, LRect);
  Left := LRect.Left;
  Top := LRect.Top;
  Right := LRect.Right;
  Bottom := LRect.Bottom;
end;

function TgsWinAPI.GetDesktopWindow: LongWord;
begin
  result := Windows.GetDesktopWindow;
end;

function TgsWinAPI.GetForegroundWindow: LongWord;
begin
  result := Windows.GetForegroundWindow;
end;

function TgsWinAPI.GetLastActivePopup(hWnd: LongWord): LongWord;
begin
  result := Windows.GetLastActivePopup(hWnd)
end;

function TgsWinAPI.GetParent(hWnd: LongWord): LongWord;
begin
  result := Windows.GetParent(hWnd)
end;

function TgsWinAPI.GetWindow(hWnd, uCmd: LongWord): LongWord;
begin
  result := Windows.GetWindow(hWnd, uCmd)
end;

function TgsWinAPI.GetWindowRect(hWnd: LongWord; var Left, Top, Right,
  Bottom: OleVariant): WordBool;
var
  LRect: TRect;
begin
  LRect.Left := Left;
  LRect.Top := Top;
  LRect.Right := Right;
  LRect.Bottom := Bottom;
  result := Windows.GetWindowRect(hWnd, LRect);
  Left := LRect.Left;
  Top := LRect.Top;
  Right := LRect.Right;
  Bottom := LRect.Bottom;
end;

function TgsWinAPI.GetWindowTextLength(hWnd: LongWord): Integer;
begin
  result := Windows.GetWindowTextLength(hWnd);
end;

function TgsWinAPI.IsChild(hWndParent, hWnd: LongWord): WordBool;
begin
  result := Windows.IsChild(hWndParent, hWnd)
end;

function TgsWinAPI.IsIconic(hWnd: LongWord): WordBool;
begin
  result := Windows.IsIconic(hWnd)
end;

function TgsWinAPI.IsWindow(hWnd: LongWord): WordBool;
begin
  result := Windows.IsWindow(hWnd)
end;

function TgsWinAPI.IsWindowUnicode(hWnd: LongWord): WordBool;
begin
  result := Windows.IsWindowUnicode(hWnd)
end;

function TgsWinAPI.IsWindowVisible(hWnd: LongWord): WordBool;
begin
  result := Windows.IsWindowVisible(hWnd)
end;

function TgsWinAPI.IsZoomed(hWnd: LongWord): WordBool;
begin
  result := Windows.IsZoomed(hWnd)
end;

function TgsWinAPI.MoveWindow(hWnd: LongWord; x, y, nWidth,
  nHeight: Integer; bRepaint: WordBool): WordBool;
begin
  result := Windows.MoveWindow(hWnd, x, y, nWidth, nHeight, bRepaint)
end;

function TgsWinAPI.OpenIcon(hWnd: LongWord): WordBool;
begin
  result := Windows.OpenIcon(hWnd)
end;

function TgsWinAPI.SetForegroundWindow(hWnd: LongWord): WordBool;
begin
  result := Windows.SetForegroundWindow(hWnd)
end;

function TgsWinAPI.SetParent(hWndChild, hWndNewParent: LongWord): LongWord;
begin
  result := Windows.SetParent(hWndChild, hWndNewParent)
end;

function TgsWinAPI.SetWindowLong(hWnd: LongWord; nIndex,
  dwNewLong: Integer): Integer;
begin
  result := Windows.SetWindowLong(hWnd, nIndex, dwNewLong)
end;

function TgsWinAPI.SetWindowPos(hWnd, hWndInsertAfter: LongWord; x, y, cx,
  cy: Integer; uFlags: LongWord): WordBool;
begin
  result := Windows.SetWindowPos(hWnd, hWndInsertAfter, x, y, cx, cy, uFlags)
end;

function TgsWinAPI.SetWindowText(hWnd: LongWord;
  const lpString: WideString): WordBool;
var
  S: PChar;
begin
  WideStrToPChar(S, lpString);
  result := Windows.SetWindowText(hWnd, S);
  FreePChar(S);
end;

function TgsWinAPI.ShowOwnedPopups(hWnd: LongWord;
  fShow: WordBool): WordBool;
begin
  result := Windows.ShowOwnedPopups(hWnd, fShow)
end;

function TgsWinAPI.ShowWindow(hWnd: LongWord; nCmdShow: Integer): WordBool;
begin
  result := Windows.ShowWindow(hWnd, nCmdShow)
end;

(*
function TgsWinAPI.RegCloseKey(hKey: LongWord): Integer;
begin
  result := Windows.RegCloseKey(hKey)
end;

function TgsWinAPI.RegConnectRegistry(const lpMachineName: WideString;
  hKey: LongWord; var phkResult: OleVariant): Integer;
var
  LHKEY: Windows.HKEY;
  Ch: PChar;
begin
  LHKEY := phkResult;
  WideStrToPChar(Ch, lpMachineName);
  result := Windows.RegConnectRegistry(Ch, hKey, LHKEY);
  phkResult := Integer(LHKEY);
  FreePChar(Ch);
end;

function TgsWinAPI.RegCreateKey(hKey: LongWord; const lpSubKey: WideString;
  var phkResult: OleVariant): Integer;
var
  LHKEY: Windows.HKEY;
  Ch: PChar;
begin
  LHKEY := phkResult;
  WideStrToPChar(Ch, lpSubKey);
  result := Windows.RegCreateKey(hKey, Ch, LHKEY);
  phkResult := Integer(LHKEY);
  FreePChar(Ch);
end;

function TgsWinAPI.RegDeleteKey(hKey: LongWord;
  const lpSubKey: WideString): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpSubKey);
  result := Windows.RegDeleteKey(hKey, Ch);
  FreePChar(Ch);
end;

function TgsWinAPI.RegDeleteValue(hKey: LongWord;
  const lpValueName: WideString): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpValueName);
  result := Windows.RegDeleteValue(hKey, Ch)
end;

function TgsWinAPI.RegEnumKey(hKey: LongWord; dwIndex: LongWord;
  const lpName: WideString; cbName: LongWord): LongWord;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpName);
  result := Windows.RegEnumKey(hKey, dwIndex, Ch, cbName);
  FreePChar(Ch);
end;

function TgsWinAPI.RegFlushKey(hKey: LongWord): Integer;
begin
  result := Windows.RegFlushKey(hKey)
end;

function TgsWinAPI.RegLoadKey(hKey: LongWord; const lpSubKey,
  lpFile: WideString): Integer;
var
  ChSubKey: PChar;
  ChFile: PChar;
begin
  WideStrToPChar(ChSubKey, lpSubKey);
  WideStrToPChar(ChFile, lpFile);
  result := Windows.RegLoadKey(hKey, ChSubKey, ChFile);
  FreePChar(ChSubKey);
  FreePChar(ChFile);
end;

function TgsWinAPI.RegNotifyChangeKeyValue(hKey: LongWord;
  bWatchSubtree: WordBool; dwNotifyFilter: Word; hEvent: LongWord;
  fAsynchronus: WordBool): Integer;
begin
  result := Windows.RegNotifyChangeKeyValue(hKey, bWatchSubtree,
    dwNotifyFilter, hEvent, fAsynchronus)
end;

function TgsWinAPI.RegOpenKey(hKey: LongWord; const lpSubKey: WideString;
  var phkResult: OleVariant): Integer;
var
  LHKEY: Windows.HKEY;
  Ch: PChar;
begin
  LHKEY := phkResult;
  WideStrToPChar(Ch, lpSubKey);
  result := Windows.RegOpenKey(hKey, Ch, LHKEY);
  phkResult := Integer(LHKEY);
  FreePChar(Ch);
end;

function TgsWinAPI.RegOpenKeyEx(hKey: LongWord; const lpSubKey: WideString;
  ulOptions, samDesired: LongWord; var phkResult: OleVariant): Integer;
var
  LHKEY: Windows.HKEY;
  Ch: PChar;
begin
  LHKEY := phkResult;
  WideStrToPChar(Ch, lpSubKey);
  result := Windows.RegOpenKeyEx(hKey, Ch, ulOptions,  samDesired, LHKEY);
  phkResult := Integer(LHKEY);
  FreePChar(Ch);
end;

function TgsWinAPI.RegQueryValue(hKey: LongWord; const lpSubKey,
  lpValue: WideString; var lpcbValue: OleVariant): Integer;
var
  LL: Longint;
  ChSubKey: PChar;
  ChValue: PChar;
begin
  LL := lpcbValue;
  WideStrToPChar(ChSubKey, lpSubKey);
  WideStrToPChar(ChValue, lpValue);
  Result := Windows.RegQueryValue(hKey, ChSubKey, ChValue, LL);
  lpcbValue := LL;
  FreePChar(ChSubKey);
  FreePChar(ChValue);
end;

function TgsWinAPI.RegReplaceKey(hKey: LongWord; const lpSubKey, lpNewFile,
  lpOldFile: WideString): Integer;
var
  ChSubkey: PChar;
  ChNewFile: PChar;
  ChOldFile: PChar;
begin
  WideStrToPChar(ChSubkey, lpSubKey);
  WideStrToPChar(ChNewFile, lpNewFile);
  WideStrToPChar(ChOldFile, lpOldFile);
  Result := Windows.RegReplaceKey(hKey, ChSubkey, ChNewFile, ChOldFile);
  FreePChar(ChSubKey);
  FreePChar(ChNewFile);
  FreePChar(ChOldFile);
end;

function TgsWinAPI.RegRestoreKey(hKey: LongWord; const lpFile: WideString;
  dwFlags: LongWord): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpFile);
  Result := Windows.RegRestoreKey(hKey, Ch, dwFlags);
  FreePChar(Ch);
end;

function TgsWinAPI.RegSetValue(hKey: LongWord; const lpSubKey: WideString;
  dwType: LongWord; const lpData: WideString; cbData: LongWord): Integer;
var
  ChSubKey: PChar;
  ChData: PChar;
begin
  WideStrToPChar(ChSubKey, lpSubKey);
  WideStrToPChar(ChData, lpData);
  Result := Windows.RegSetValue(hKey, ChSubKey, dwType, ChData, cbData);
  FreePChar(ChSubKey);
  FreePChar(ChData);
end;

function TgsWinAPI.RegUnLoadKey(hKey: LongWord;
  const lpSubKey: WideString): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpSubKey);
  Result := Windows.RegUnLoadKey(hKey, Ch);
  FreePChar(Ch);
end;
*)

function TgsWinAPI.ActivateKeyboardLayout(hkl, Flags: LongWord): LongWord;
begin
  Result := Windows.ActivateKeyboardLayout(hkl, Flags);
end;

function TgsWinAPI.GetActiveWindow: LongWord;
begin
  Result := Windows.GetActiveWindow;
end;

function TgsWinAPI.GetFocus: LongWord;
begin
  Result := Windows.GetFocus;
end;

function TgsWinAPI.GetKBCodePage: LongWord;
begin
  Result := Windows.GetKBCodePage;
end;

function TgsWinAPI.GetKeyboardLayoutName(
  const pwszKLID: WideString): WordBool;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, pwszKLID);
  Result := Windows.GetKeyboardLayoutName(Ch);
  FreePChar(Ch);
end;

function TgsWinAPI.GetKeyNameText(lParam: Integer;
  const lpString: WideString; nSize: Integer): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpString);
  Result := Windows.GetKeyNameText(lParam, Ch, nSize);
  FreePChar(Ch);
end;

function TgsWinAPI.IsWindowEnabled(hWnd: LongWord): WordBool;
begin
  Result := Windows.IsWindowEnabled(hWnd);
end;

procedure TgsWinAPI.keybd_event(bVk, bScan: Shortint; dwFlags,
  dwExtraInfo: LongWord);
begin
  Windows.keybd_event(bVk, bScan, dwFlags, dwExtraInfo)
end;

function TgsWinAPI.LoadKeyboardLayout(const pwszKLID: WideString;
  Flags: LongWord): LongWord;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, pwszKLID);
  Result := Windows.LoadKeyboardLayout(Ch, Flags);
  FreePChar(Ch);
end;

function TgsWinAPI.MapVirtualKey(uCode, uMapType: LongWord): LongWord;
begin
  Result := Windows.MapVirtualKey(uCode, uMapType)
end;

function TgsWinAPI.OemKeyScan(wOemChar: Word): LongWord;
begin
  Result := Windows.OemKeyScan(wOemChar)
end;

function TgsWinAPI.RegisterHotKey(hWnd: LongWord; id: Integer; fsModifiers,
  vk: LongWord): WordBool;
begin
  Result := Windows.RegisterHotKey(hWnd, id, fsModifiers, vk);
end;

function TgsWinAPI.SetActiveWindow(hWnd: LongWord): LongWord;
begin
  Result := Windows.SetActiveWindow(hWnd)
end;

function TgsWinAPI.SetFocus(hWnd: LongWord): LongWord;
begin
  Result := Windows.SetFocus(hWnd)
end;

function TgsWinAPI.UnloadKeyboardLayout(hkl: LongWord): WordBool;
begin
  Result := Windows.UnloadKeyboardLayout(hkl)
end;

function TgsWinAPI.UnregisterHotKey(hWnd: LongWord; id: Integer): WordBool;
begin
  Result := Windows.UnregisterHotKey(hWnd, id)
end;

function TgsWinAPI.VkKeyScan(ch: Byte): Smallint;
begin
  Result := Windows.VkKeyScan(chr(ch));
end;

function TgsWinAPI.GetCapture: LongWord;
begin
  Result := Windows.GetCapture;
end;

function TgsWinAPI.GetDoubleClickTime: LongWord;
begin
  Result := Windows.GetDoubleClickTime;
end;

procedure TgsWinAPI.mouse_event(dwFlags, dx, dy, dwData,
  dwExtraInfo: LongWord);
begin
  Windows.MOUSE_EVENT(dwFlags, dx, dy, dwData, dwExtraInfo)
end;

function TgsWinAPI.ReleaseCapture: WordBool;
begin
  Result := Windows.ReleaseCapture;
end;

function TgsWinAPI.SetCapture(hWnd: LongWord): LongWord;
begin
  Result := Windows.SetCapture(hWnd)
end;

function TgsWinAPI.SetDoubleClickTime(uInterval: LongWord): WordBool;
begin
  Result := Windows.SetDoubleClickTime(uInterval)
end;

function TgsWinAPI.SwapMouseButton(fSwap: WordBool): WordBool;
begin
  Result := Windows.SwapMouseButton(fSwap)
end;

function TgsWinAPI.DefWindowProc(hWnd, Msg, wParam,
  lParam: LongWord): Integer;
begin
  Result := Windows.DefWindowProc(hWnd, Msg, wParam, lParam)
end;

function TgsWinAPI.GetInputState: WordBool;
begin
  Result := Windows.GetInputState
end;

function TgsWinAPI.GetMessageExtraInfo: Integer;
begin
  Result := Windows.GetMessageExtraInfo
end;

function TgsWinAPI.GetMessagePos: LongWord;
begin
  Result := Windows.GetMessagePos
end;

function TgsWinAPI.GetMessageTime: Integer;
begin
  Result := Windows.GetMessageTime
end;

function TgsWinAPI.GetQueueStatus(flags: LongWord): LongWord;
begin
  Result := Windows.GetQueueStatus(flags)
end;

function TgsWinAPI.InSendMessage: WordBool;
begin
  Result := Windows.InSendMessage
end;

function TgsWinAPI.PostMessage(hWnd, Msg: LongWord; wParam,
  lParam: Integer): WordBool;
begin
  Result := Windows.PostMessage(hWnd, Msg, wParam, lParam)
end;

procedure TgsWinAPI.PostQuitMessage(nExitCode: Integer);
begin
  Windows.PostQuitMessage(nExitCode)
end;

function TgsWinAPI.ReplyMessage(lResult: Integer): WordBool;
begin
  Result := Windows.ReplyMessage(lResult)
end;

function TgsWinAPI.SendMessage(hWnd, Msg: LongWord; wParam,
  lParam: Integer): Integer;
begin
  Result := Windows.SendMessage(hWnd, Msg, wParam, lParam)
end;

function TgsWinAPI.SendMessageTimeout(hWnd, Msg: LongWord; wParam,
  lParam: Integer; fuFlag, uTimeout: LongWord;
  var lpdwResult: OleVariant): Integer;
var
  LR: DWORD;
begin
  LR := lpdwResult;
  Result := Windows.SendMessageTimeout(hWnd, Msg, wParam, lParam,
    fuFlag, uTimeout, LR);
  lpdwResult := Integer(LR);
end;

function TgsWinAPI.SendNotifyMessage(hWnd, Msg: LongWord; wParam,
  lParam: Integer): WordBool;
begin
  Result := Windows.SendNotifyMessage(hWnd, Msg, wParam, lParam)
end;

function TgsWinAPI.SetMessageExtraInfo(lParam: Integer): Integer;
begin
  Result := Windows.SetMessageExtraInfo(lParam)
end;

function TgsWinAPI.WaitMessage: WordBool;
begin
  Result := Windows.WaitMessage;
end;

function TgsWinAPI.GetModuleHandle(const ModuleName: WideString): Integer;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, ModuleName);
  Result := Windows.GetModuleHandle(Ch);
  FreePChar(Ch);
end;

function TgsWinAPI.LoadIcon(Instance: Integer;
  const IconName: WideString): Integer;
var
  Ch: PChar;
  P: PChar;
begin
  Ch := nil;
  if IconName = 'IDI_APPLICATION' then
    P := IDI_APPLICATION
  else if IconName = 'IDI_ASTERISK' then
    P := IDI_ASTERISK
  else if IconName = 'IDI_EXCLAMATION' then
    P := IDI_EXCLAMATION
  else if IconName = 'IDI_HAND' then
    P := IDI_HAND
  else if IconName = 'IDI_QUESTION' then
    P := IDI_QUESTION
  else if IconName = 'IDI_WINLOGO' then
    P := IDI_WINLOGO
  else begin
    if StrToIntDef(IconName, Low(Integer)) = Low(Integer) then
    begin
      WideStrToPChar(Ch, IconName);
      P := Ch;
    end else
      P := MakeIntResource(StrToIntDef(IconName, 0));
  end;
  Result := Windows.LoadIcon(Instance, P);
  FreePChar(Ch);
end;

function TgsWinAPI.GetSystemMetrics(Index: Integer): Integer;
begin
  Result := Windows.GetSystemMetrics(Index);
end;

function TgsWinAPI.DrawIcon(hDC: LongWord; X, Y: Integer;
  hIcon: LongWord): WordBool;
begin
  Result := Windows.DrawIcon(hDC, X, Y, hIcon);
end;

function TgsWinAPI.FreeLibrary(hLibModule: LongWord): WordBool;
begin
  Result := Windows.FreeLibrary(hLibModule);
end;

function TgsWinAPI.GetDeviceCaps(hdc: LongWord; nIndex: Integer): Integer;
begin
  Result := Windows.GetDeviceCaps(hdc, nIndex);
end;

function  TgsWinAPI.GetModuleFileName(Module: Integer): WideString;
var
  Ch: array[0..1024] of Char;
begin
  if Windows.GetModuleFileName(Module, Ch, SizeOf(Ch)) > 0 then
    Result := StrPas(Ch)
  else
    Result := '';
end;

function TgsWinAPI.LoadLibrary(const lpLibFileName: WideString): LongWord;
var
  Ch: PChar;
begin
  WideStrToPChar(Ch, lpLibFileName);
  Result := Windows.LoadLibrary(Ch);
  FreePChar(Ch);
end;

function TgsWinAPI.GetPrivateProfileInt(const lpAppName,
  lpKeyName: WideString; nDefault: LongWord;
  const lpFileName: WideString): LongWord;
var
  AN, KN, FN: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  WideStrToPChar(KN, lpKeyName);
  WideStrToPChar(FN, lpFileName);
  Result := Windows.GetPrivateProfileInt(AN, KN, nDefault, FN);
  FreePChar(AN);
  FreePChar(KN);
  FreePChar(FN);
end;

function TgsWinAPI.GetPrivateProfileSectionNames(
  out lpszReturnBuffer: OleVariant;
  const lpFileName: WideString): LongWord;
var
  B: array[0..1024] of Char;
  FN: PChar;
begin
  WideStrToPChar(FN, lpFileName);
  Result := Windows.GetPrivateProfileSectionNames(B, SizeOf(B) - 1, FN);
  lpszReturnBuffer := StrPas(B);
  FreePChar(FN);
end;

function TgsWinAPI.GetPrivateProfileString(const lpAppName, lpKeyName,
  lpDefault: WideString; out lpReturnedString: OleVariant;
  const lpFileName: WideString): LongWord;
var
  B: array[0..1024] of Char;
  AN, KN, D, FN: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  WideStrToPChar(KN, lpKeyName);
  WideStrToPChar(D,  lpDefault);
  WideStrToPChar(FN, lpFileName);
  Result := Windows.GetPrivateProfileString(AN, KN, D, B, SizeOf(B) - 1, FN);
  lpReturnedString := StrPas(B);
  FreePChar(AN);
  FreePChar(KN);
  FreePChar(D);
  FreePChar(FN);
end;

function TgsWinAPI.GetProfileInt(const lpAppName, lpKeyName: WideString;
  nDefault: LongWord): LongWord;
var
  AN, KN: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  WideStrToPChar(KN, lpKeyName);
  Result := Windows.GetProfileInt(AN, KN, nDefault);
  FreePChar(AN);
  FreePChar(KN);
end;

function TgsWinAPI.GetProfileSection(const lpAppName: WideString;
  out lpReturnedString: OleVariant): LongWord;
var
  B: array[0..1024] of Char;
  AN: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  Result := Windows.GetProfileSection(AN, B, SizeOf(B) - 1);
  lpReturnedString := StrPas(B);
  FreePChar(AN);
end;

function TgsWinAPI.GetProfileString(const lpAppName, lpKeyName,
  lpDefault: WideString; out lpReturnedString: OleVariant): LongWord;
var
  B: array[0..1024] of Char;
  AN, KN, D: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  WideStrToPChar(KN, lpKeyName);
  WideStrToPChar(D, lpDefault);
  Result := Windows.GetProfileString(AN, KN, D, B, SizeOf(B) - 1);
  lpReturnedString := StrPas(B);
  FreePChar(AN);
  FreePChar(KN);
  FreePChar(D);
end;

function TgsWinAPI.GetPrivateProfileSection(const lpAppName: WideString;
  out lpReturnedString: OleVariant;
  const lpFileName: WideString): LongWord;
var
  B: array[0..1024] of Char;
  AN, FN: PChar;
begin
  WideStrToPChar(AN, lpAppName);
  WideStrToPChar(FN, lpFileName);
  Result := Windows.GetPrivateProfileSection(AN, B, SizeOf(B) - 1, FN);
  lpReturnedString := StrPas(B);
  FreePChar(AN);
  FreePChar(FN);
end;

function TgsWinAPI.ExitWindowsEx(uFlags: Integer;
  dwReserved: Integer): WordBool;
begin
  Result := Windows.ExitWindowsEx(UFlags, dwReserved);
end;

function TgsWinAPI.ShellExecute(hwnd: LongWord; const lpOperation, lpFile,
  lpParameters, lpDirectory: WideString; nShowCmd: Integer): LongWord;
var
  O, F, P, D: PChar;
begin
  WideStrToPChar(O, lpOperation);
  WideStrToPChar(F, lpFile);
  WideStrToPChar(P, lpParameters);
  WideStrToPChar(D, lpDirectory);
  
  Result := ShellAPI.ShellExecute(hwnd, O, F, P, D, nShowCmd);

  FreePChar(O);
  FreePChar(F);
  FreePChar(P);
  FreePChar(D);
end;

function TgsWinAPI.GetTempPath: WideString;
var
  SA: array[0..1024] of Char;
begin
  if Windows.GetTempPath(1025, SA) <> 0 then
    Result := StrPas(SA)
  else
    Result := '';
end;

function TgsWinAPI.GetTempFileName(const PathName,
  PrefixString: WideString; UniqueNumber: Integer): WideString;
var
  lpTempFileName: array[0..1024] of Char;
  pPathName, lpPrefixString: PChar;
begin

  WideStrToPChar(pPathName, PathName);
  WideStrToPChar(lpPrefixString, PrefixString);

  if Windows.GetTempFileName(pPathName, lpPrefixString, UniqueNumber, lpTempFileName) <> 0 then
    Result := StrPas(lpTempFileName)
  else
    Result := '';

  FreePChar(pPathName);
  FreePChar(lpPrefixString);
end;

function TgsWinAPI.LockWindowUpdate(hWnd: LongWord): WordBool;
begin
  result := Windows.LockWindowUpdate(hWnd);
end;

function TgsWinAPI.WideCharToMultiByte(CodePage: Integer;
  const WideCharStr: WideString): WideString;
var
  SourceLen, DestLen: Integer;
  Buffer: array[0..2047] of Char;
  Dest: String;
  Source: PWideChar;
begin
  Dest := '';
  if WideCharStr > '' then
  begin
    Source := @WideCharStr[1];
    SourceLen := 0;
    while Source[SourceLen] <> #0 do Inc(SourceLen);
    if SourceLen > 0 then
    begin
      if SourceLen < SizeOf(Buffer) div 2 then
        SetString(Dest, Buffer, Windows.WideCharToMultiByte(CodePage, 0,
          Source, SourceLen, Buffer, SizeOf(Buffer), nil, nil))
      else
      begin
        DestLen := Windows.WideCharToMultiByte(CodePage, 0, Source, SourceLen,
          nil, 0, nil, nil);
        SetString(Dest, nil, DestLen);
        Windows.WideCharToMultiByte(CodePage, 0, Source, SourceLen, Pointer(Dest),
          DestLen, nil, nil);
      end;
    end;
  end;

  Result := Dest;
end;

function TgsWinAPI.MultiByteToWideChar(CodePage: Integer;
  const MultiByteStr: WideString): WideString;
var
  Dest: PWideChar;
  Source: PChar;
  I, SourceLen, DestLen: Integer;
begin
  if MultiByteStr = '' then
    Result := ''
  else begin
    SourceLen := Length(MultiByteStr);
    GetMem(Source, SourceLen);
    try
      for I := 1 to SourceLen do
      begin
        Source[I - 1] := WideCharLenToString(@MultiByteStr[I], 1)[1];
      end;
      DestLen := Windows.MultiByteToWideChar(CodePage, 0, Source, SourceLen,
        nil, 0);
      GetMem(Dest, DestLen * 2 + 2);
      try
        Windows.MultiByteToWideChar(CodePage, 0, Source, SourceLen,
          Dest, DestLen);
        Dest[DestLen] := #0;
        Result := Dest;
      finally
        FreeMem(Dest, DestLen * 2 + 2);
      end;
    finally
      FreeMem(Source, SourceLen);
    end;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsWinAPI, CLASS_gsWinAPI,
    ciMultiInstance, tmApartment);
end.
