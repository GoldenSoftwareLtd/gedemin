unit WMemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows, LCLType, LMessages;

type
  TWMemo = class(TMemo)
  private
    { Private declarations }
    FReadOnly:boolean;
    OldWndProc: TWndMethod;

    procedure SetRead(const value:boolean);
    procedure AddWndProc(var Message: TMessage);
    procedure WMPaint(var Msg: TMessage); message WM_Paint;
    //procedure WMSetFocus(var Msg: TMessage); message WM_SetFocus;
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHitTest;
    procedure WMKEYDOWN(VAR Message: TMessage); message WM_KEYDOWN;
  protected
    { Protected declarations }
   procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property ReadOnly:boolean read FReadOnly write SetRead;
  end;

  function ReleaseCapture:WINBOOL;
     stdcall; external 'coredll' name 'ReleaseCapture';

  function ShowCaret(hWnd:HWND):WINBOOL;
    stdcall; external 'coredll' name 'ShowCaret';

  function HideCaret(hWnd:HWND):WINBOOL;
    stdcall; external 'coredll' name 'HideCaret';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard',[TWMemo]);
end;

{ TWCMemo }

procedure TWMemo.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WindowClass.hCursor := LoadCursor(0, IDC_ARROW);
end;

procedure TWMemo.WMKEYDOWN(var Message: TMessage);
var
  Key:Integer;
begin

inherited;

end;

procedure TWMemo.WMNCHitTest(var Msg: TMessage);
begin
inherited;

end;

procedure TWMemo.WMPaint(var Msg: TMessage);
begin
inherited;
end;

{procedure TWMemo.WMSetFocus(var Msg: TMessage);
begin
inherited;

end;}

procedure TWMemo.SetRead(const value: boolean);
begin
  if TMemo(self).ReadOnly <> value then
  begin
    if value then
      ShowCaret(Handle)
    else
      HideCaret(Handle);
    TMemo(self).ReadOnly:=value;
    FReadOnly:=value;
  end;
end;

procedure TWMemo.AddWndProc(var Message: TMessage);
begin
  if (Message.Msg = LM_LBUTTONDBLCLK) or (Message.Msg = LM_LBUTTONDOWN) then
  begin
     ReleaseCapture;
  end;
  if (Message.Msg <> WM_SetFocus) then
   OldWndProc(Message);
end;


constructor TWMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OldWndProc := WindowProc;
  WindowProc := @AddWndProc;
end;

destructor TWMemo.Destroy;
begin
 WindowProc := OldWndProc;
 inherited;
end;
end.
