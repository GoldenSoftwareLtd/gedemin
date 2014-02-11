unit BaseAddInformation; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, LMessages, Windows, ProjectCommon;

type
  { TBaseAddInformation }

  TBaseAddInformation = class(TForm)
    eInfo: TEdit;
    lInfo: TLabel;
    procedure eInfoEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations}
    FData: String;
    {$IFDEF SKORPIOX3}
    reqID: DWORD;
    hDcd: HWND;
    procedure Cleanup;
    {$ENDIF}
    procedure WM_BARCODE(var Message: TMessage); message AM_DCD_SCAN;
  protected
    procedure Enter; virtual;
    function CheckCode(const ACode: String): boolean;  virtual; abstract;
  public
    { public declarations }
    class function Execute(AMsg: String): String; virtual;
    property Data: String read FData write FData;
  end;

  {$IFNDEF SKORPIOX3}
  function registerLabelMessage(hLabelWindow: HWND; uiLabelMessage: Cardinal): Boolean;
    stdcall; external 'scaner_dll.dll' name 'registerLabelMessage';

  function getLabelText(pDestBuffer: LPTSTR; nDestBufferCapacity: Integer): Integer;
    stdcall; external 'scaner_dll.dll' name 'getLabelText';

  function getLabelTextLength: Integer;
    stdcall; external 'scaner_dll.dll' name 'getLabelTextLength';

  procedure scanEnable;
    stdcall; external 'scaner_dll.dll' name 'scanEnable';

  function isScanEnabled: Boolean;
    stdcall; external 'scaner_dll.dll' name 'isScanEnabled';

  procedure deregisterLabelMessage;
    stdcall; external 'scaner_dll.dll' name 'deregisterLabelMessage';
  {$ELSE}
  function DecodeEnumDevices(deviceCaps: Pointer): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeEnumDevices';

  function DecodeReadString(hFile: HWND; reqID: DWORD; stringLen: Pointer; readString: WideString; maxLen: DWORD; codeID: Pointer): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeReadString';

  function DecodePostRequestMsgEx(hFile: HWND; reqType: DWORD; hWnd: HWND; uMsgRead, uMsgTimeout: UINT): DWORD;
    stdcall; external 'DecodeApi.dll' name 'DecodePostRequestMsgEx';

  function DecodeCancelRequest(hFile: HWND; reqID: DWORD): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeCancelRequest';
  {$ENDIF}

implementation

{$R *.lfm}

{ TBaseAddInformation }

procedure TBaseAddInformation.FormCreate(Sender: TObject);
{$IFDEF SKORPIOX3}
var
  Num: array [0..8] of DWORD;
  DevIndex: Integer;
  DeviceName: WideString;
  B: DWORD;
{$ENDIF}
begin
  inherited;
  BorderStyle := bsNone;
  WindowState := wsNormal;

  eInfo.Font.Size := 13;
  eInfo.Text := '';
  lInfo.Caption := '';

  {$IFNDEF SKORPIOX3}
  registerLabelMessage(Handle, AM_DCD_SCAN);
  {$ELSE}
  if not DecodeEnumDevices(@Num) then
    raise Exception.Create('Device error!');
  DevIndex := 0;
  B := 1 or 2;
  for DevIndex := 0 to 8 do
  begin
    if (Num[DevIndex] and B) = B then
      break;
  end;

  DeviceName := 'DCD' + WideString(IntToStr(DevIndex + 1)) + ':';
  hDcd := CreateFile(PWideChar(deviceName), GENERIC_READ or GENERIC_WRITE, 0,
    nil, OPEN_EXISTING, 0, 0);

  if hDcd = INVALID_HANDLE_VALUE then
    raise Exception.Create('hDcd = INVALID_HANDLE_VALUE!');
  reqID := DecodePostRequestMsgEx(hDcd, (2 and 255) or 256,
    Self.Handle,
    AM_DCD_SCAN,
    AM_DCD_TIMEOUT);

  if reqID = -1 then
    raise Exception.Create('reqID = -1');
  {$ENDIF}
end;

procedure TBaseAddInformation.eInfoEnter(Sender: TObject);
begin
  eInfo.SelLength := 0;
  eInfo.SelStart := Length(eInfo.Text);
end;

procedure TBaseAddInformation.FormDestroy(Sender: TObject);
begin
  {$IFNDEF SKORPIOX3}
  deregisterLabelMessage();
  {$ELSE}
  Cleanup;
  {$ENDIF}
end;

{$IFDEF SKORPIOX3}
procedure TBaseAddInformation.Cleanup;
begin
  if (hDcd <> INVALID_HANDLE_VALUE) then
  begin
    DecodeCancelRequest(hDcd, reqID);
    CloseHandle(hDcd);
    hDcd := INVALID_HANDLE_VALUE;
  end;
end;
{$ENDIF}

procedure TBaseAddInformation.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: Enter;
    VK_ESCAPE: ModalResult := mrCancel;
  end;
end;

procedure TBaseAddInformation.FormShow(Sender: TObject);
var
  ScreenWidth, ScreenHeight: Integer;
  TaskBarWnd: THandle;
begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, ScreenWidth, ScreenHeight, 0);
  TaskBarWnd := FindWindow('HHTaskBar', '');
  if (TaskBarWnd <> 0) then
    SetWindowPos(TaskBarWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE);
end;

procedure TBaseAddInformation.WM_BARCODE(var Message: TMessage);
var
  {$IFNDEF SKORPIOX3}
  Count: Integer;
  LabelText: array [0..100] of Widechar;
  {$ELSE}
  msgReqID, maxLen, stringLen: DWORD;
  lpString: WideString;
  {$ENDIF}
begin
  {$IFNDEF SKORPIOX3}
  FillChar(LabelText, SizeOf(LabelText), 0);
  count := getLabelTextLength();
  getLabelText(@LabelText, count);
  eInfo.Text := String(Trim(LabelText));
  {$ELSE}
  msgReqID := Message.LPARAM;
  maxLen := Message.WPARAM div sizeof(WideChar);
  SetLength(lpString, maxLen);
  DecodeReadString(hDcd, msgReqID, @stringLen, lpString, maxLen - 1, nil);
  eInfo.Text := Trim(lpString);
  {$ENDIF}
end;

class function TBaseAddInformation.Execute(AMsg: String): String;
begin
  Result := '';
  with TBaseAddInformation.Create(nil) do
  try
    lInfo.Caption := AMsg;
    ShowModal;
    Result := FData;
  finally
    Free;
  end;
end;

procedure TBaseAddInformation.Enter;
begin
  FData := Trim(eInfo.Text);
  ModalResult := mrOk;
end;

end.

