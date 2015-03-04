unit XPEdit;

interface

uses Windows, Messages, Forms, Graphics, Controls, Classes, SysUtils, XPButton,
  StdCtrls, MySpin;

const
  BORDER_ENABLED = $00BF9F7F;
  BORDER_DISABLED = $00B8D8D7;
  ENABLED_WIDTH = 1;
  DISABLED_WIDTH = 1;
  MAX_ENABLED_WIDTH = 3;
  MIN_ENABLED_WIDTH = 1;
  MAX_DISABLED_WIDTH = 3;
  MIN_DISABLED_WIDTH = 1;

type
  TEditCharCase = (ecNormal, ecUpperCase, ecLowerCase);

  TSelection = record
    StartPos, EndPos: Integer;
  end;

  TXPEdit = class(TWinControl)
  private
    FAutoSize: Boolean;
    FMaxLength: Integer;
    FPasswordChar: Char;
    FReadOnly: Boolean;
    FCharCase: TEditCharCase;
    FCreating: Boolean;
    FModified: Boolean;
    FEnabledBorderColor: TColor;
    FDisabledBorderColor: TColor;
    FEnabledBorderWidth: Integer;
    FDisabledBorderWidth: Integer;
    FOnChange: TNotifyEvent;
    FMouseEnter: TNotifyEvent;
    FMouseLeave: TNotifyEvent;
    procedure AdjustHeight;
    function GetModified: Boolean;
    function GetCanUndo: Boolean;
    procedure SetAutoSize(NewAutoSize: Boolean); reintroduce;
    procedure SetCharCase(NewCharCase: TEditCharCase);
    procedure SetMaxLength(NewMaxLength: Integer);
    procedure SetModified(NewModified: Boolean);
    procedure SetPasswordChar(NewPasswordChar: Char);
    procedure SetReadOnly(NewReadOnly: Boolean);
    procedure SetEnabledBorderColor(NewEnabledBorderColor: TColor);
    procedure SetDisabledBorderColor(NewDisabledBorderColor: TColor);
    procedure SetEnabledBorderWidth(NewEnabledBorderWidth: Integer);
    procedure SetDisabledBorderWidth(NewDisabledBorderWidth: Integer);
    procedure SetSelText(const Value: string);
    procedure UpdateHeight;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure Paint(var Message: TMessage); message WM_Paint;
  protected
    procedure Change; dynamic;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DoSetMaxLength(Value: Integer); virtual;
    function GetSelLength: Integer; virtual;
    function GetSelStart: Integer; virtual;
    function GetSelText: string; virtual;
    procedure SetSelLength(Value: Integer); virtual;
    procedure SetSelStart(Value: Integer); virtual;
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
    procedure Clear; virtual;
    procedure ClearSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure DefaultHandler(var Message); override;
    procedure PasteFromClipboard;
    procedure Undo;
    procedure ClearUndo;
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer; virtual;
    procedure SelectAll;
    procedure SetSelTextBuf(Buffer: PChar);
    property CanUndo: Boolean read GetCanUndo;
    property Modified: Boolean read GetModified write SetModified;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
  published
    property Align;
    property Anchors;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Font;
    property Hint;
    property Enabled;
    property Color default clWhite;
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
    property CharCase: TEditCharCase read FCharCase write SetCharCase default ecNormal;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property PasswordChar: Char read FPasswordChar write SetPasswordChar default #0;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Height default 25;
    property OnClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
    property OnExit;
    property OnDblClick;
    property OnContextPopup;
    property OnMouseEnter: TNotifyEvent read FMouseEnter write FMouseEnter;
    property OnMouseLeave: TNotifyEvent read FMouseLeave write FMouseLeave;
    property ShowHint;
    property Text;
    property Visible;
    property TabStop default True;
    property TabOrder;
    property Width default 121;
  end;

  TXPMemo = class(TCustomMemo)
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FDisabledBorderColor: TColor;
    FEnabledBorderColor: TColor;
    procedure Paint(var Message: TMessage); message WM_Paint;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
  protected
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property Lines;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TXPTimerSpeedButton = class(TTimerSpeedButton)
  protected
    procedure Paint; override;
  end;

  TXPSpinButton = class(TSpinButton)
  protected
    function GetTimerSpeedButton: TTimerSpeedButtonClass; override;
  end;

  TXPSpinEdit = class(TMySpinEdit)
    procedure Paint(var Message: TMessage); message WM_Paint;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FEnabledBorderColor: TColor;
    FDisabledBorderColor: TColor;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
  protected
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;
    function GetSpinButtonClass: TSpinButtonClass; override;
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
  end;

procedure Register;

procedure Frame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);

implementation

uses Math, Buttons;

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPEdit, TXPMemo, TXPSpinEdit]);
end;

procedure Frame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);

  procedure DoRect;
  var
    TopRight, BottomLeft: TPoint;
  begin
    with Canvas, Rect do
    begin
      TopRight.X := Right;
      TopRight.Y := Top;
      BottomLeft.X := Left;
      BottomLeft.Y := Bottom;
      Pen.Color := TopColor;
      PolyLine([BottomLeft, TopLeft, TopRight]);
      Pen.Color := BottomColor;
      Dec(BottomLeft.X);
      PolyLine([TopRight, BottomRight, BottomLeft]);
    end;
  end;

begin
  Canvas.Pen.Width := 1;
  Dec(Rect.Bottom); Dec(Rect.Right);
  while Width > 0 do
  begin
    Dec(Width);
    DoRect;
    InflateRect(Rect, -1, -1);
  end;
  Inc(Rect.Bottom); Inc(Rect.Right);
end;

constructor TXPEdit.Create(AOwner: TComponent);
const
  EditStyle = [csClickEvents, csSetCaption, csDoubleClicks, csFixedHeight];
begin
  inherited Create(AOwner);
  if NewStyleControls then
    ControlStyle := EditStyle else
    ControlStyle := EditStyle + [csFramed];
  Color := clWhite;
  Width := 121;
  Height := 25;
  FAutoSize := True;
  AdjustHeight;
  TabStop := True;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPEdit.DoSetMaxLength(Value: Integer);
begin
  SendMessage(Handle, EM_LIMITTEXT, Value, 0)
end;

procedure TXPEdit.SetAutoSize(NewAutoSize: Boolean);
begin
  if NewAutoSize <> FAutoSize then
  begin
    FAutoSize := NewAutoSize;
    UpdateHeight;
  end;
end;

procedure TXPEdit.SetCharCase(NewCharCase: TEditCharCase);
begin
  if NewCharCase <> FCharCase then
  begin
    FCharCase := NewCharCase;
    RecreateWnd;
  end;
end;

procedure TXPEdit.SetMaxLength(NewMaxLength: Integer);
var S: string;
begin
  if NewMaxLength <> FMaxLength then
    begin
      FMaxLength := NewMaxLength;
      if HandleAllocated then DoSetMaxLength(NewMaxLength);
      if (MaxLength <= 0) or (Length(Text) <= MaxLength) then
        Exit;
      S := Text;
      SetLength(S, MaxLength);
      Text := S;
    end;
end;

function TXPEdit.GetModified: Boolean;
begin
  Result := FModified;
  if HandleAllocated then Result := SendMessage(Handle, EM_GETMODIFY, 0, 0) <> 0;
end;

function TXPEdit.GetCanUndo: Boolean;
begin
  Result := False;
  if HandleAllocated then Result := SendMessage(Handle, EM_CANUNDO, 0, 0) <> 0;
end;

procedure TXPEdit.SetModified(NewModified: Boolean);
begin
  if HandleAllocated then
    SendMessage(Handle, EM_SETMODIFY, Byte(NewModified), 0) else
    FModified := NewModified;
end;

procedure TXPEdit.SetPasswordChar(NewPasswordChar: Char);
begin
  if NewPasswordChar <> FPasswordChar then
  begin
    FPasswordChar := NewPasswordChar;
    if HandleAllocated then
    begin
      SendMessage(Handle, EM_SETPASSWORDCHAR, Ord(FPasswordChar), 0);
      SetTextBuf(PChar(Text));
    end;
  end;
end;

procedure TXPEdit.SetReadOnly(NewReadOnly: Boolean);
begin
  if NewReadOnly <> FReadOnly then
  begin
    FReadOnly := NewReadOnly;
    if HandleAllocated then
      SendMessage(Handle, EM_SETREADONLY, Ord(NewReadOnly), 0);
  end;
end;

procedure TXPEdit.SetEnabledBorderColor(NewEnabledBorderColor: TColor);
begin
  if NewEnabledBorderColor <> FEnabledBorderColor then
    begin
      FEnabledBorderColor := NewEnabledBorderColor;
      Invalidate;
    end;
end;

procedure TXPEdit.SetDisabledBorderColor(NewDisabledBorderColor: TColor);
begin
  if NewDisabledBorderColor <> FDisabledBorderColor then
    begin
      FDisabledBorderColor := NewDisabledBorderColor;
      Invalidate;
    end;
end;

procedure TXPEdit.SetEnabledBorderWidth(NewEnabledBorderWidth: Integer);
begin
  if NewEnabledBorderWidth = FEnabledBorderWidth then
    Exit;
  if NewEnabledBorderWidth > MAX_ENABLED_WIDTH then
    begin
      FEnabledBorderWidth := MAX_ENABLED_WIDTH;
      Invalidate;
      Exit;
    end;
  if NewEnabledBorderWidth < MIN_ENABLED_WIDTH then
    begin
      FEnabledBorderColor := MIN_ENABLED_WIDTH;
      Invalidate;
      Exit;
    end;
  FEnabledBorderWidth := NewEnabledBorderWidth;
  Invalidate;
end;

procedure TXPEdit.SetDisabledBorderWidth(NewDisabledBorderWidth: Integer);
begin
  if NewDisabledBorderWidth = FDisabledBorderWidth then
    Exit;
  if NewDisabledBorderWidth > MAX_DISABLED_WIDTH then
    begin
      FDisabledBorderWidth := MAX_DISABLED_WIDTH;
      Invalidate;
      Exit;
    end;
  if NewDisabledBorderWidth < MIN_DISABLED_WIDTH then
    begin
      FDisabledBorderColor := MIN_DISABLED_WIDTH;
      Invalidate;
      Exit;
    end;
  FDisabledBorderWidth := NewDisabledBorderWidth;
  Invalidate;
end;

function TXPEdit.GetSelStart: Integer;
begin
  SendMessage(Handle, EM_GETSEL, Longint(@Result), 0);
end;

procedure TXPEdit.SetSelStart(Value: Integer);
begin
  SendMessage(Handle, EM_SETSEL, Value, Value);
end;

function TXPEdit.GetSelLength: Integer;
var
  Selection: TSelection;
begin
  SendMessage(Handle, EM_GETSEL, Longint(@Selection.StartPos), Longint(@Selection.EndPos));
  Result := Selection.EndPos - Selection.StartPos;
end;

procedure TXPEdit.SetSelLength(Value: Integer);
var
  Selection: TSelection;
begin
  SendMessage(Handle, EM_GETSEL, Longint(@Selection.StartPos), Longint(@Selection.EndPos));
  Selection.EndPos := Selection.StartPos + Value;
  SendMessage(Handle, EM_SETSEL, Selection.StartPos, Selection.EndPos);
  SendMessage(Handle, EM_SCROLLCARET, 0,0);
end;

procedure TXPEdit.Clear;
begin
  SetWindowText(Handle, '');
end;

procedure TXPEdit.ClearSelection;
begin
  SendMessage(Handle, WM_CLEAR, 0, 0);
end;

procedure TXPEdit.CopyToClipboard;
begin
  SendMessage(Handle, WM_COPY, 0, 0);
end;

procedure TXPEdit.CutToClipboard;
begin
  SendMessage(Handle, WM_CUT, 0, 0);
end;

procedure TXPEdit.PasteFromClipboard;
begin
  SendMessage(Handle, WM_PASTE, 0, 0);
end;

procedure TXPEdit.Undo;
begin
  SendMessage(Handle, WM_UNDO, 0, 0);
end;

procedure TXPEdit.ClearUndo;
begin
  SendMessage(Handle, EM_EMPTYUNDOBUFFER, 0, 0);
end;

procedure TXPEdit.SelectAll;
begin
  SendMessage(Handle, EM_SETSEL, 0, -1);
end;

function TXPEdit.GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
var
  P: PChar;
  StartPos: Integer;
begin
  StartPos := GetSelStart;
  Result := GetSelLength;
  P := StrAlloc(GetTextLen + 1);
  try
    GetTextBuf(P, StrBufSize(P));
    if Result >= BufSize then Result := BufSize - 1;
    StrLCopy(Buffer, P + StartPos, Result);
  finally
    StrDispose(P);
  end;
end;

procedure TXPEdit.SetSelTextBuf(Buffer: PChar);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, LongInt(Buffer));
end;

function TXPEdit.GetSelText: string;
var
  P: PChar;
  SelStart, Len: Integer;
begin
  SelStart := GetSelStart;
  Len := GetSelLength;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then
  begin
    P := StrAlloc(GetTextLen + 1);
    try
      GetTextBuf(P, StrBufSize(P));
      Move(P[SelStart], Pointer(Result)^, Len);
    finally
      StrDispose(P);
    end;
  end;
end;

procedure TXPEdit.SetSelText(const Value: String);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

procedure TXPEdit.CreateParams(var Params: TCreateParams);
const
  Passwords: array[Boolean] of DWORD = (0, ES_PASSWORD);
  ReadOnlys: array[Boolean] of DWORD = (0, ES_READONLY);
  CharCases: array[TEditCharCase] of DWORD = (0, ES_UPPERCASE, ES_LOWERCASE);
  HideSelections: array[Boolean] of DWORD = (ES_NOHIDESEL, 0);
  OEMConverts: array[Boolean] of DWORD = (0, ES_OEMCONVERT);
begin
  inherited CreateParams(Params);
  CreateSubClass(Params, 'EDIT');
  with Params do
  begin
    Style := Style or (ES_AUTOHSCROLL or ES_AUTOVSCROLL) or
      Passwords[FPasswordChar <> #0] or
      ReadOnlys[FReadOnly] or CharCases[FCharCase];
    if NewStyleControls then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TXPEdit.CreateWindowHandle(const Params: TCreateParams);
var
  P: TCreateParams;
begin
  if SysLocale.FarEast and (Win32Platform <> VER_PLATFORM_WIN32_NT) and
    ((Params.Style and ES_READONLY) <> 0) then
  begin
    // Work around Far East Win95 API/IME bug.
    P := Params;
    P.Style := P.Style and (not ES_READONLY);
    inherited CreateWindowHandle(P);
    if WindowHandle <> 0 then
      SendMessage(WindowHandle, EM_SETREADONLY, Ord(True), 0);
  end
  else
    inherited CreateWindowHandle(Params);
end;

procedure TXPEdit.CreateWnd;
begin
  FCreating := True;
  try
    inherited CreateWnd;
  finally
    FCreating := False;
  end;
  DoSetMaxLength(FMaxLength);
  Modified := FModified;
  if FPasswordChar <> #0 then
    SendMessage(Handle, EM_SETPASSWORDCHAR, Ord(FPasswordChar), 0);
  UpdateHeight;
end;

procedure TXPEdit.DestroyWnd;
begin
  FModified := Modified;
  inherited DestroyWnd;
end;

procedure TXPEdit.UpdateHeight;
begin
   ControlStyle := ControlStyle - [csFixedHeight];
end;

procedure TXPEdit.AdjustHeight;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  if NewStyleControls then
  begin
    if Ctl3D then I := 8 else I := 6;
    I := GetSystemMetrics(SM_CYBORDER) * I;
  end else
  begin
    I := SysMetrics.tmHeight;
    if I > Metrics.tmHeight then I := Metrics.tmHeight;
    I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 4;
  end;
  Height := Metrics.tmHeight + I;
end;

procedure TXPEdit.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXPEdit.DefaultHandler(var Message);
begin
  case TMessage(Message).Msg of
    WM_SETFOCUS:
      if (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
        not IsWindow(TWMSetFocus(Message).FocusedWnd) then
        TWMSetFocus(Message).FocusedWnd := 0;
  end;
  inherited;
end;

procedure TXPEdit.WMSetFont(var Message: TWMSetFont);
begin
  inherited;
  if NewStyleControls and
    (GetWindowLong(Handle, GWL_STYLE) and ES_MULTILINE = 0) then
    SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 0);
end;

procedure TXPEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if (csFixedHeight in ControlStyle) and not ((csDesigning in
    ComponentState) and (csLoading in ComponentState)) then AdjustHeight;
end;

procedure TXPEdit.CNCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = EN_CHANGE) and not FCreating then Change;
end;

procedure TXPEdit.CMEnter(var Message: TCMGotFocus);
begin
  if not (csLButtonDown in ControlState) and
    (GetWindowLong(Handle, GWL_STYLE) and ES_MULTILINE = 0) then SelectAll;
  inherited;
end;

procedure TXPEdit.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not HandleAllocated or (GetWindowLong(Handle, GWL_STYLE) and
    ES_MULTILINE <> 0) then Change;
end;

procedure TXPEdit.CMMouseEnter(var Message: TMessage);
begin
  Include(DrawState, odHotLight);
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
  Invalidate;
end;

procedure TXPEdit.CMMouseLeave(var Message: TMessage);
begin
  Exclude(DrawState, odHotLight);
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
  Invalidate;
end;

procedure TXPEdit.Paint(var Message: TMessage);
var DC: HDC;
    R: TRect;
    Canvas: TCanvas;
begin
  Canvas := TCanvas.Create;
  DC := GetWindowDC(Handle);
  Canvas.Handle := DC;
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    if Enabled  then
      Frame3D(Canvas, R, EnabledBorderColor, EnabledBorderColor, EnabledBorderWidth)
    else
      Frame3D(Canvas, R, DisabledBorderColor, DisabledBorderColor, DisabledBorderWidth);

    if not Focused then
    begin
      if (odHotLight in DrawState) then
        Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
      else
        Frame3D(Canvas, R, Color, Color, 1);
    end else
      Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);
  finally
    ReleaseDC(Handle, DC);
    Canvas.Handle := 0;
    Canvas.Free;
  end;
  Inherited;
end;

{ TXPMemo }

procedure TXPMemo.CMMouseEnter(var Message: TMessage);
begin
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPMemo.CMMouseLeave(var Message: TMessage);
begin
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

constructor TXPMemo.Create(AOwner: TComponent);
begin
  inherited;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPMemo.Paint(var Message: TMessage);
var DC: HDC;
    R: TRect;
    Canvas: TCanvas;
begin
  inherited;
  Canvas := TCanvas.Create;
  DC := GetWindowDC(Handle);
  Canvas.Handle := DC;
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    if Enabled  then
      Frame3D(Canvas, R, EnabledBorderColor, EnabledBorderColor, EnabledBorderWidth)
    else
      Frame3D(Canvas, R, DisabledBorderColor, DisabledBorderColor, DisabledBorderWidth);

    if not Focused then
    begin
      if (odHotLight in DrawState) then
        Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
      else
        Frame3D(Canvas, R, Color, Color, 1);
    end else
      Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);
  finally
    ReleaseDC(Handle, DC);
    Canvas.Handle := 0;
    Canvas.Free;
  end;

end;

procedure TXPMemo.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
end;

procedure TXPMemo.SetDisabledBorderWidth(const Value: Integer);
begin
  FDisabledBorderWidth := Value;
end;

procedure TXPMemo.SetEnabledBorderColor(const Value: TColor);
begin
  FEnabledBorderColor := Value;
end;

procedure TXPMemo.SetEnabledBorderWidth(const Value: Integer);
begin
  FEnabledBorderWidth := Value;
end;

procedure TXPEdit.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TXPEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TXPMemo.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TXPMemo.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

{ TXPSpinEdit }

procedure TXPSpinEdit.CMMouseEnter(var Message: TMessage);
begin
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPSpinEdit.CMMouseLeave(var Message: TMessage);
begin
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

constructor TXPSpinEdit.Create(AOwner: TComponent);
begin
  inherited;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPSpinEdit.DownClick(Sender: TObject);
begin
  if ReadOnly or (Value = MinValue) then MessageBeep(0)
  else Value := Value - Increment;
end;

function TXPSpinEdit.GetSpinButtonClass: TSpinButtonClass;
begin
  Result := TXPSpinButton;
end;

procedure TXPSpinEdit.Paint(var Message: TMessage);
var
  DC: HDC;
  R: TRect;
  Canvas: TCanvas;
begin
  inherited;
  Canvas := TCanvas.Create;
  DC := GetWindowDC(Handle);
  Canvas.Handle := DC;
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    if Enabled  then
      Frame3D(Canvas, R, EnabledBorderColor, EnabledBorderColor, EnabledBorderWidth)
    else
      Frame3D(Canvas, R, DisabledBorderColor, DisabledBorderColor, DisabledBorderWidth);

    if not Focused then
    begin
      if (odHotLight in DrawState) then
        Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
      else
        Frame3D(Canvas, R, Color, Color, 1);
    end else
      Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);
  finally
    ReleaseDC(Handle, DC);
    Canvas.Handle := 0;
    Canvas.Free;
  end;
end;

procedure TXPSpinEdit.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
end;

procedure TXPSpinEdit.SetDisabledBorderWidth(const Value: Integer);
begin
  FDisabledBorderWidth := Value;
end;

procedure TXPSpinEdit.SetEnabledBorderColor(const Value: TColor);
begin
  FEnabledBorderColor := Value;
end;

procedure TXPSpinEdit.SetEnabledBorderWidth(const Value: Integer);
begin
  FEnabledBorderWidth := Value;
end;

procedure TXPSpinEdit.UpClick(Sender: TObject);
begin
  if ReadOnly or (Value = MaxValue) then MessageBeep(0)
  else Value := Value + Increment;
end;

{ TXPSpinButton }

function TXPSpinButton.GetTimerSpeedButton: TTimerSpeedButtonClass;
begin
  Result := TXPTimerSpeedButton;
end;

{ TXPTimerSpeedButton }

procedure TXPTimerSpeedButton.Paint;
var
  R: TRect;
begin
  R := Bounds(0, 0, Width, Height);
  DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DFCS_FLAT or DFCS_BUTTONPUSH);
  if Glyph <> nil then
  begin
    Glyph.Transparent := True;
    Canvas.Draw((Width - Glyph.Width) div 2, (Height - Glyph.Height) Div 2,
       Glyph);
  end;
  if tbFocusRect in TimeBtnState then
  begin
    R := Bounds(0, 0, Width, Height);
    InflateRect(R, -3, -3);
    if FState = bsDown then
      OffsetRect(R, 1, 1);
    DrawFocusRect(Canvas.Handle, R);
  end;
end;

end.