unit gd_alfablend_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type

  TAlfaBlendBlind = class(TWinControl)
  private
    FTransparentColor: Boolean;
    FAlphaBlend: Boolean;
    FAlphaBlendValue: Integer;
    FTransparentColorValue: TColor;
    FBlendedWnd: HWND;
    FDelta: Integer;

    procedure SetAlphaBlend(const Value: Boolean);
    procedure SetAlphaBlendValue(const Value: Integer);
    procedure SetTransaparentColor(const Value: Boolean);
    procedure SetTransparentColorValue(const Value: TColor);
    procedure SetBlendedWnd(const Value: HWND);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure SetLayeredAttribs;
    procedure InitAlphaBlending(var Params: TCreateParams);
    procedure CreateParams(var Params: TCreateParams); override;
    { Private declarations }
    procedure Paint;
    procedure OnTimer(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property TransaparentColor: Boolean read FTransparentColor write SetTransaparentColor;
    property TransparentColorValue: TColor read FTransparentColorValue write SetTransparentColorValue;
    property AlphaBlend: Boolean read FAlphaBlend write SetAlphaBlend;
    property AlphaBlendValue: Integer read FAlphaBlendValue write SetAlphaBlendValue;
    property BlendedWnd: HWND read FBlendedWnd write SetBlendedWnd;
  end;

  TBlindTimer = class(TTimer)
  private
    FNotify: TList;

    procedure _OnTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddNotify(N: TAlfaBlendBlind);
    procedure RemoveNotify(N: TAlfaBlendBlind);
  end;

  TAlfaBlendBlinds = class(TList)
  private
    function GetForms(Index: Integer): TAlfaBlendBlind;

  public
    function IndexByBlended(Handle: HWND): Integer;
    function IndexByHandle(Handle: HWND): Integer;

    property Forms[Index: Integer]: TAlfaBlendBlind read GetForms; default;
  end;

  TSetLayeredWindowAttributes = function (Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;

var
  AlfaBlendBlind: TAlfaBlendBlind;
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes = nil;

  function AlfaBlendBlinds: TAlfaBlendBlinds;
implementation
uses gd_createable_form;
//{$R *.DFM}
var
 _AlfaBlendBlinds: TAlfaBlendBlinds;
 _Timer: TBlindTimer;
  CallWndRetProcHook: HHOOK;
const
  LWA_COLORKEY = $00000001;
  LWA_ALPHA = $00000002;
  WS_EX_LAYERED = $00080000;

function AlfaBlendBlinds: TAlfaBlendBlinds;
begin
  if _AlfaBlendBlinds = nil then
    _AlfaBlendBlinds := TAlfaBlendBlinds.Create;
  Result := _AlfaBlendBlinds;
end;

procedure InitProcs;
const
  sUser32 = 'User32.dll';
var
  ModH: HMODULE;
begin
  ModH := GetModuleHandle(sUser32);
  if ModH <> 0 then
     @SetLayeredWindowAttributes := GetProcAddress(ModH, 'SetLayeredWindowAttributes');
end;

procedure ClipBlinds;
var
  Wnd, PrevWnd, BlendWND: HWND;
  Rgn, WndRgn: HRGN;
  Index, Clip: Integer;
  Rect, ARect: TRect;
  I: Integer;
begin
  for I := 0 to AlfaBlendBlinds.Count - 1 do
  begin
    BlendWnd := AlfaBlendBlinds[i].BlendedWnd;
    GetWindowRect(BlendWnd, Rect);
    Rgn := CreateRectRgnIndirect(Rect);
    Clip := SIMPLEREGION;
    Wnd := GetNextWindow(BlendWnd, GW_HWNDPREV);
    while Wnd <> 0 do
    begin
      Index := AlfaBlendBlinds.IndexByBlended(Wnd);
      if Index > - 1 then
      begin
        GetWindowRect(Wnd, Rect);
        WndRgn := CreateRectRgnIndirect(Rect);
        Clip := CombineRgn(Rgn, Rgn, WndRgn, RGN_DIFF);
        if Clip = NullRegion then Break;
      end;
      Wnd := GetNextWindow(Wnd, GW_HWNDPREV);
    end;
    if Clip <> NullRegion then
    begin
      GetWindowRect(BlendWND, ARect);
      AlfaBlendBlinds[i].SetBounds(ARect.Left + 10, ARect.Top + 10, ARect.Right - ARect.Left,
        ARect.Bottom - ARect.Top);

      Wnd := AlfaBlendBlinds[i].Handle;
      PrevWnd := GetNextWindow(BlendWnd,  GW_HWNDPREV);
//      PrevWnd := Screen.ActiveForm.Handle;
      if PrevWnd <> Wnd then
      begin
        if PrevWnd <> 0 then
        begin
          Assert(SetWindowPos(Wnd,  PrevWnd, 0, 0, 0, 0,
            SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOACTIVATE	));
        end else
          Assert(SetWindowPos(Wnd,  HWND_TOP, 0, 0, 0, 0,
            SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW or SWP_NOACTIVATE	));
      end;

      GetWindowRect(BlendWnd, Rect);
      OffsetRgn(Rgn, -Rect.Left, -Rect.Top);
      SetWindowRgn(Wnd, Rgn, False);
      SetWindowText(BlendWnd, 'Не пустой');
    end else
    begin
      SetWindowText(BlendWnd, 'Пустой');
      ShowWindow(Wnd, SW_HIDE);
    end;
  end;
end;

function CallWndRetProc(nCode: Integer; WParam, LParam: Integer): LResult; stdcall;
var
  Struc: CWPRETSTRUCT;
  Rect: TRect;
  Index: Integer;
  BlendedForm: TAlfaBlendBlind;
  I: Integer;
  F: TCustomForm;
  PrevWnd: HWND;
begin
  Result := CallNextHookEx(CallWndRetProcHook, nCode, WParam, LParam);
  if WParam = 0 then
  begin
    Struc := PCWPRetStruct(lParam)^;
    case Struc.message of
      CM_ACTIVATE:
      begin
        F := nil;
        for I := 0 to Screen.FormCount - 1 do
        begin
          if Screen.Forms[I].Handle = Struc.hwnd then
          begin
            F := Screen.Forms[I];
            Break;
          end;
        end;

        if (F <> nil) and (F is TCreateableForm) then
        begin
          if fsModal in F.FormState then
          begin
            ClipBlinds;
          end;
        end;
      end;
      CM_DEACTIVATE:
      begin
        F := nil;
        for I := 0 to Screen.FormCount - 1 do
        begin
          if Screen.Forms[I].Handle = Struc.hwnd then
          begin
            F := Screen.Forms[I];
            Break;
          end;
        end;

        if (F <> nil) and (F is TCreateableForm) then
        begin
          if fsModal in F.FormState then
          begin
            ClipBlinds;
          end;
        end;
      end;
      WM_ENABLE:
      begin
        if Struc.wParam = 0 then
        begin
          if IsWindowVisible(Struc.hwnd) then
          begin
            Index := AlfaBlendBlinds.IndexByHandle(Struc.hwnd);
            if Index = - 1 then
            begin
              F := nil;
              for I := 0 to Screen.FormCount - 1 do
              begin
                if Screen.Forms[I].Handle = Struc.hwnd then
                begin
                  F := Screen.Forms[I];
                  Break;
                end;
              end;

              if (F <> nil) and (F.HostDockSite = nil) then
              begin
                GetWindowRect(Struc.hwnd, Rect);

                Index := AlfaBlendBlinds.IndexByBlended(Struc.hwnd);
                if Index = - 1 then
                begin
                  BlendedForm := TAlfaBlendBlind.Create(nil);
                  BlendedForm.BlendedWnd := Struc.hwnd;
                end;
              end;
            end;
          end;
        end else
        begin
          Index := AlfaBlendBlinds.IndexByBlended(Struc.hwnd);
          if Index > - 1 then
          begin
            AlfaBlendBlinds.Forms[Index].Free;
          end;
        end;
      end;
      WM_DESTROY:
      begin
        Index := AlfaBlendBlinds.IndexByBlended(Struc.hwnd);
        if Index > - 1 then
        begin
          AlfaBlendBlinds.Forms[Index].Free;
//          ClipBlinds;
        end;
      end;
    end;
  end;
end;

{ TAlfaBlendBlind }

procedure TAlfaBlendBlind.SetAlphaBlend(const Value: Boolean);
begin
  if FAlphaBlend <> Value then
  begin
    FAlphaBlend := Value;
    SetLayeredAttribs;
  end;
end;

procedure TAlfaBlendBlind.SetAlphaBlendValue(const Value: Integer);
begin
  if FAlphaBlendValue <> Value then
  begin
    FAlphaBlendValue := Value;
    SetLayeredAttribs;
  end;
end;

procedure TAlfaBlendBlind.SetTransaparentColor(const Value: Boolean);
begin
  if FTransparentColor <> Value then
  begin
    FTransparentColor := Value;
    SetLayeredAttribs;
  end;
end;

procedure TAlfaBlendBlind.SetTransparentColorValue(const Value: TColor);
begin
  if FTransparentColorValue <> Value then
  begin
    FTransparentColorValue := Value;
    SetLayeredAttribs;
  end;
end;

procedure TAlfaBlendBlind.OnTimer(Sender: TObject);
begin
  if IsWindowVisible(Handle) then
  begin
    if Fdelta > 0 then
      Dec(FDelta);
    if Fdelta = 0 then
    begin
      if AlphaBlendValue >= 60 then
      begin
        Exit;
      end;
      AlphaBlendValue := AlphaBlendValue + 5;
    end;
  end;
end;

procedure TAlfaBlendBlind.SetBlendedWnd(const Value: HWND);
begin
  FBlendedWnd := Value;
end;

procedure TAlfaBlendBlind.SetLayeredAttribs;
const
  cUseAlpha: array [Boolean] of Integer = (0, LWA_ALPHA);
  cUseColorKey: array [Boolean] of Integer = (0, LWA_COLORKEY);
var
  AStyle: Integer;
begin
  if not (csDesigning in ComponentState) and
    (Assigned(SetLayeredWindowAttributes)) and HandleAllocated then
  begin
    AStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if FAlphaBlend or FTransparentColor then
    begin
      if (AStyle and WS_EX_LAYERED) = 0 then
        SetWindowLong(Handle, GWL_EXSTYLE, AStyle or WS_EX_LAYERED);
      SetLayeredWindowAttributes(Handle, FTransparentColorValue, FAlphaBlendValue,
        cUseAlpha[FAlphaBlend] or cUseColorKey[FTransparentColor]);
    end
    else
    begin
      SetWindowLong(Handle, GWL_EXSTYLE, AStyle and not WS_EX_LAYERED);
      RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);
    end;
  end;
end;

procedure TAlfaBlendBlind.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  SetLayeredAttribs;
end;

procedure TAlfaBlendBlind.InitAlphaBlending(var Params: TCreateParams);
begin
  if not (csDesigning in ComponentState) and (assigned(SetLayeredWindowAttributes)) then
    if FAlphaBlend or FTransparentColor then
      Params.ExStyle := Params.ExStyle or WS_EX_LAYERED;
end;

procedure TAlfaBlendBlind.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    if (Parent = nil) and (ParentWindow = 0) then
    begin
      WndParent := Application.Handle;
      Style := Style and not (WS_CHILD or WS_GROUP or WS_TABSTOP) or WS_POPUP;
    end;
    WindowClass.style := CS_DBLCLKS;
  end;

  InitAlphaBlending(Params);
end;

constructor TAlfaBlendBlind.Create(AOwner: TComponent);
begin
  FAlphaBlend := True;
  FAlphaBlendValue := 0;

  inherited;

  AlfaBlendBlinds.Add(Self);
  FDelta := 10;
  Color := clBlack;

  if _Timer = nil then
  begin
    _Timer := TBlindTimer.Create(nil);
  end;
  _Timer.AddNotify(Self);
end;

destructor TAlfaBlendBlind.Destroy;
begin
  _Timer.RemoveNotify(Self);
  AlfaBlendBlinds.Extract(Self);
  if AlfaBlendBlinds.Count = 0 then
  begin
    FreeAndNil(_Timer);
  end;
  inherited;
end;

procedure TAlfaBlendBlind.Paint;
{var
  I, J: Integer;}
begin
{  with Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ClientRect);
    I := 0;
    repeat
      J := 0;
      repeat
        SetPixel(Handle, j, i, clBlack);
//        Pixels[j, i] := clBlue;
        Inc(J, FDelta)
      until J > ClientWidth;
      Inc(I, FDelta);
    until I > ClientHeight;
  end;}
  inherited;
end;

{ TAlfaBlendBlinds }

function TAlfaBlendBlinds.GetForms(Index: Integer): TAlfaBlendBlind;
begin
  Result := TAlfaBlendBlind(Items[Index]);
end;

function TAlfaBlendBlinds.IndexByBlended(Handle: HWND): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to Count - 1 do
  begin
    if Forms[I].BlendedWnd = Handle then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TAlfaBlendBlinds.IndexByHandle(Handle: HWND): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to Count - 1 do
  begin
    if Forms[I].Handle = Handle then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TBlindTimer }

procedure TBlindTimer.AddNotify(N: TAlfaBlendBlind);
begin
  if N <> nil then
  begin
    if FNotify = nil then
      FNotify := TList.Create;

    if FNotify.IndexOf(N) = - 1 then
      FNotify.Add(N);
  end;
end;

constructor TBlindTimer.Create(AOwner: TComponent);
begin
  inherited;
  OnTimer := _OnTimer;
  Interval := 200;
  Enabled := True;
end;

destructor TBlindTimer.Destroy;
begin
  FNotify.Free;
  inherited;
end;

procedure TBlindTimer._OnTimer(Sender: TObject);
var
   I: Integer;
begin
  if FNotify <> nil then
  begin
    for I := 0 to FNotify.Count - 1 do
    begin
      TAlfaBlendBlind(FNotify[I]).OnTimer(Self);
    end;
  end;
end;

procedure TBlindTimer.RemoveNotify(N: TAlfaBlendBlind);
begin
  if (N <> nil) and (FNotify <> nil) then
  begin
    FNotify.Extract(N);
    if FNotify.Count = 0 then
    begin
      FreeAndNil(FNotify);
    end;
  end;
end;

initialization
  InitProcs;
  CallWndRetProcHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndRetProc, HInstance, GetCurrentThreadId)
finalization
  if CallWndRetProcHook <> 0 then
    UnhookWindowsHookEx(CallWndRetProcHook);
  FreeAndNil(_AlfaBlendBlinds);
end.
 
