
{++

  Copyright (c) 1995-98 by Golden Software of Belarus

  Module

    xspin.pas
                                   
  Abstract

    Spin button and spin edit like those in the Delphi
    samples but extended with mouse dragging support.

  Author

    Denis Romanovski (17-Dec-95)

    Borland's samples had been used as prototypes
    for these components.

  Revisions history

    1.00    17-Feb-96    dennis,    Initial version.
                         andreik
    1.01    17-Jul-96    andreik    Minor changes.
    1.02    02-Sep-96    andreik    Minor changes.
    1.03    09-Sep-96    andreik    Defaults changed.
    1.04    20-Oct-97    andreik    Ported to Delphi32.
    1.04    12-Aug-98    dennis     Minor changes under Delphi 4.

--}

unit xSpin;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, Menus, StdCtrls, ExtCtrls;

const
  InitRepeatPause = 400;
  DefRepeatPause = 100;
  crDragSpin = 17555; { must be unique identifier }

const
  DefWidth = 20;
  DefHeight = 25;
  DefSpinGap = 2;
  DefStep = 1;
  DefGapColor = clBtnShadow;
  DefDecDigits = 1;
  DefIncrement = 1;
  DefSpinButtonWidth = 14;
  DefSpinButtonHeight = 17;
  DefValue = 0;
  EmptyString = '';

type
  TxSpinButtonEvent = procedure(Sender: TObject; Delta: Integer) of object;

type
  TxTimerSpeedButton = class(TSpeedButton)
  private
    FRepeatTimer: TTimer;
    FRepeatPause: LongInt;

    procedure SetRepeatPause(ARepeatPause: LongInt);

    procedure TimerExpired(Sender: TObject);

    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property RepeatPause: LongInt read FRepeatPause write SetRepeatPause
      default DefRepeatPause;
  end;

type
  TxSpinButton = class(TCustomControl)
  private
    FUpButton: TxTimerSpeedButton;
    FDownButton: TxTimerSpeedButton;
    FSpinGap: Integer;
    FStep: Integer;
    FSpinGapColor: TColor;
    FSpinCursor: TCursor;

    FOnUpClick: TxSpinButtonEvent;
    FOnDownClick: TxSpinButtonEvent;
    FOnMoveSpin: TxSpinButtonEvent;

    CurrPosition: Integer;

    function CreateButton: TxTimerSpeedButton;
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    function GetRepeatPause: LongInt;

    procedure SetUpGlyph(Value: TBitmap);
    procedure SetDownGlyph(Value: TBitmap);
    procedure SetSpinGap(ASpinGap: Integer);
    procedure SetStep(AStep: Integer);
    procedure SetSpinGapColor(ASpinGapColor: TColor);
    procedure SetSpinCursor(ASpinCursor: TCursor);
    procedure SetRepeatPause(ARepeatPause: LongInt);

    procedure BtnClick(Sender: TObject);
    procedure ResizeButtons;

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
      message WM_GETDLGCODE;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;

  protected
    SaveUpGlyph, SaveDownGlyph: Boolean;

    procedure Loaded; override;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph
      stored SaveUpGlyph;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph
      stored SaveDownGlyph;
    property Step: Integer read FStep write SetStep
      default DefStep;
    property SpinGap: Integer read FSpinGap write SetSpinGap
      default DefSpinGap;
    property SpinGapColor: TColor read FSpinGapColor write SetSpinGapColor
      default DefGapColor;
    property SpinCursor: TCursor read FSpinCursor write SetSpinCursor;
    property RepeatPause: LongInt read GetRepeatPause write SetRepeatPause
      default DefRepeatPause;

    { publish inherited properties }
    property Align;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width default DefWidth;
    property Height default DefHeight;

    { events }
    property OnUpClick: TxSpinButtonEvent read FOnUpClick write FOnUpClick;
    property OnMoveSpin: TxSpinButtonEvent read FOnMoveSpin write FOnMoveSpin;
    property OnDownClick: TxSpinButtonEvent read FOnDownClick write FOnDownClick;

    { publish inherited events }
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
  end;

type
  TxSpinEdit = class(TCustomEdit)
  private
    FMinValue: Double;
    FMaxValue: Double;
    FIncrement: Double;
    FButton: TxSpinButton;
    FEditorEnabled: Boolean;
    FSpinGap: Integer;
    FSpinStep: Integer;
    FSpinGapColor: TColor;
    FDecDigits: Word;
    FPostFix: String;
    FPreFix: String;
    FValue: Double;

    function GetMinHeight: Integer;
    function GetIntValue: LongInt;
    function CheckValue(AValue: Double): Double;
    function GetValue: Double;
    function GetSpinGap: Integer;
    function GetSpinStep: Integer;
    function GetSpinGapColor: TColor;
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    function GetSpinButtonWidth: Integer;
    function GetRepeatPause: LongInt;
    function GetSpinCursor: TCursor;

    procedure SetValue(AValue: Double);
    procedure SetIntValue(AnIntValue: LongInt);
    procedure SetSpinGap(ASpinGap: Integer);
    procedure SetSpinStep(ASpinStep: Integer);
    procedure SetSpinGapColor(ASpinGapColor: TColor);
    procedure SetUpGlyph(AnUpGlyph: TBitmap);
    procedure SetDownGlyph(ADownGlyph: TBitmap);
    procedure SetDecDigits(ADecDigits: Word);
    procedure SetPostFix(APostFix: String);
    procedure SetPreFix(APreFix: String);
    procedure SetSpinButtonWidth(ASpinButtonWidth: Integer);
    procedure SetRepeatPause(ARepeatPause: LongInt);
    procedure SetSpinCursor(ASpinCursor: TCursor);

    procedure SetEditRect;

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus);
      message CM_ENTER;
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste);
      message WM_PASTE;
    procedure WMCut(var Message: TWMCut);
      message WM_CUT;

    function SaveUpGlyph: Boolean;
    function SaveDownGlyph: Boolean;

  protected
    procedure Loaded; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure UpClick(Sender: TObject; Delta: Integer);
    procedure DownClick(Sender: TObject; Delta: Integer);
    procedure MoveSpin(Sender: TObject; Delta: Integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Button: TxSpinButton read FButton;

  published
    property Value: Double read GetValue write SetValue;
    property IntValue: LongInt read GetIntValue write SetIntValue
      default DefValue;
    property MaxValue: Double read FMaxValue write FMaxValue;
    property MinValue: Double read FMinValue write FMinValue;
    property Increment: Double read FIncrement write FIncrement;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled
      default True;
    property SpinGap: Integer read GetSpinGap write SetSpinGap
      default DefSpinGap;
    property SpinStep: Integer read GetSpinStep write SetSpinStep
      default DefStep;
    property SpinGapColor: TColor read GetSpinGapColor write SetSpinGapColor
      default DefGapColor;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph
      stored SaveDownGlyph;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph
      stored SaveUpGlyph;
    property DecDigits: Word read FDecDigits write SetDecDigits
      default DefDecDigits;
    property PreFix: String read FPreFix write SetPreFix;
    property PostFix: String read FPostFix write SetPostFix;
    property SpinButtonWidth: Integer read GetSpinButtonWidth write SetSpinButtonWidth
      default DefSpinButtonWidth;
    property RepeatPause: LongInt read GetRepeatPause write SetRepeatPause
      default DefRepeatPause;
    property SpinCursor: TCursor read GetSpinCursor write SetSpinCursor;

    { publish inherited properties }
    property AutoSelect;
    property AutoSize;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    { events }
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

{$R 'XSPIN.RES'}

{ Auxiliry functions -------------------------------------}

function CalcNumOfGlyphs(Bm: TBitmap): Integer;
begin
  if (Bm <> nil) and((Bm.Width mod Bm.Height) = 0)
      and ((Bm.Width div Bm.Height) in [1, 2, 3, 4]) then
    Result := Bm.Width div Bm.Height
  else
    Result := 1;
end;

{ TxTimerSpeedButton -------------------------------------}

constructor TxTimerSpeedButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Cursor := crArrow;
  FRepeatPause := DefRepeatPause;
end;

destructor TxTimerSpeedButton.Destroy;
begin
  if FRepeatTimer <> nil then FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TxTimerSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  Down := True;

  if FRepeatTimer = nil then
  begin
    FRepeatTimer := TTimer.Create(Self);
    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
  end;

  FRepeatTimer.Enabled  := True;
end;

procedure TxTimerSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Down := False;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled := False;
end;

procedure TxTimerSpeedButton.SetRepeatPause(ARepeatPause: LongInt);
begin
  FRepeatPause := ARepeatPause;
end;

procedure TxTimerSpeedButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := FRepeatPause;
  if Down and MouseCapture then
  begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

procedure TxTimerSpeedButton.WMMouseMove(var Message: TWMMouseMove);

  {$IFDEF VER80}
  function Belong(P: TPoint; R: TRect): Boolean;
  {$ELSE}
  function Belong(P: TSmallPoint; R: TRect): Boolean;
  {$ENDIF}
  begin
    Result := (P.X >= R.Left) and (P.X <= R.Right) and (P.Y >= R.Top) and (P.Y <= R.Bottom);
  end;

begin
  if Cursor <> crArrow then Cursor := crArrow;
  Down := Belong(Message.Pos, ClientRect) and MouseCapture;
end;

{ TxSpinButton -------------------------------------------}

constructor TxSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];

  FUpButton := CreateButton;
  FUpButton.GroupIndex := 1;
  FUpButton.AllowAllUp := True;

  FDownButton := CreateButton;
  FDownButton.GroupIndex := 2;
  FDownButton.AllowAllUp := True;
  FStep := DefStep;
  FSpinGap := DefSpinGap;
  FSpinCursor := crDragSpin;

  Cursor := FSpinCursor;

  UpGlyph := nil;
  DownGlyph := nil;
  FSpinGapColor := DefGapColor;

  Width := DefWidth;
  Height := DefHeight;

  CurrPosition := 0;

  SaveUpGlyph := False;
  SaveDownGlyph := False;
end;

procedure TxSpinButton.Loaded;
begin
  inherited Loaded;

  FUpButton.NumGlyphs := CalcNumOfGlyphs(FUpButton.Glyph);
  FUpButton.Invalidate;
  FDownButton.NumGlyphs := CalcNumOfGlyphs(FDownButton.Glyph);
  FDownButton.Invalidate;

  ResizeButtons;
end;

procedure TxSpinButton.Paint;
begin
  Canvas.Brush.Color := FSpinGapColor;
  Canvas.FillRect(ClientRect);
end;

procedure TxSpinButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP: FUpButton.Click;
    VK_DOWN: FDownButton.Click;
  end;
end;

function TxSpinButton.CreateButton: TxTimerSpeedButton;
begin
  Result := TxTimerSpeedButton.Create(Self);
  Result.OnClick := BtnClick;
  Result.Visible := True;
  Result.Enabled := True;
  Result.Parent := Self;
end;

function TxSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpButton.Glyph;
end;

function TxSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownButton.Glyph;
end;

function TxSpinButton.GetRepeatPause: LongInt;
begin
  Result := FUpButton.RepeatPause;
end;

procedure TxSpinButton.SetUpGlyph(Value: TBitmap);
begin
  if Value <> nil then
  begin
    if FUpButton.Glyph.Handle <> Value.Handle then
    begin
      FUpButton.Glyph.Assign(Value);
      SaveUpGlyph := True;
    end;
  end else
  begin
    FUpButton.Glyph.Handle := LoadBitmap(hInstance, 'XSPIN_UP');
    SaveUpGlyph := False;
  end;

  FUpButton.NumGlyphs := CalcNumOfGlyphs(FUpButton.Glyph);
  FUpButton.Invalidate;
end;

procedure TxSpinButton.SetDownGlyph(Value: TBitmap);
begin
  if Value <> nil then
  begin
    if FDownButton.Glyph.Handle <> Value.Handle then
    begin
      FDownButton.Glyph.Assign(Value);
      SaveDownGlyph := True;
    end;
  end else
  begin
    FDownButton.Glyph.Handle := LoadBitmap(hInstance, 'XSPIN_DOWN');
    SaveDownGlyph := False;
  end;

  FDownButton.NumGlyphs := CalcNumOfGlyphs(FDownButton.Glyph);
  FDownButton.Invalidate;
end;

procedure TxSpinButton.SetSpinGap(ASpinGap: Integer);
begin
  if (FSpinGap <> ASpinGap) and (ASpinGap > 0) then
  begin
    FSpinGap := ASpinGap;
    ResizeButtons;
  end;
end;

procedure TxSpinButton.SetStep(AStep: Integer);
begin
  if (FStep <> AStep) and (AStep > 0) then FStep := AStep;
end;

procedure TxSpinButton.SetSpinGapColor(ASpinGapColor: TColor);
begin
  if FSpinGapColor <> ASpinGapColor then
  begin
    FSpinGapColor := ASpinGapColor;
    Invalidate;
  end;
end;

procedure TxSpinButton.SetSpinCursor(ASpinCursor: TCursor);
begin
  if FSpinCursor <> ASpinCursor then
  begin
    FSpinCursor := ASpinCursor;
    Cursor := ASpinCursor;
  end;
end;

procedure TxSpinButton.SetRepeatPause(ARepeatPause: LongInt);
begin
  if GetRepeatPause <> ARepeatPause then
  begin
    FUpButton.RepeatPause := ARepeatPause;
    FDownButton.RepeatPause := ARepeatPause;
  end;
end;

procedure TxSpinButton.BtnClick(Sender: TObject);
begin
  if Sender = FUpButton then
  begin
    if Assigned(FOnUpClick) then FOnUpClick(Self, 1);
  end else
    if Assigned(FOnDownClick) then FOnDownClick(Self, -1);
end;

procedure TxSpinButton.ResizeButtons;
begin
  if (FUpButton = nil) or (csLoading in ComponentState) then Exit;

  FUpButton.SetBounds (0, 0, Width, Height div 2 - FSpinGap div 2);
  FDownButton.SetBounds (0, FUpButton.Height + FSpinGap, Width,
    Height - FUpButton.Height - FSpinGap);
end;

procedure TxSpinButton.WMSize(var Message: TWMSize);
begin
  inherited;
  ResizeButtons;
end;

procedure TxSpinButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TxSpinButton.WMMouseMove(var Message: TWMMouseMove);
var
  Delta: Integer;
begin
  if Cursor <> FSpinCursor then Cursor := FSpinCursor;

  Delta := (CurrPosition - Message.YPos) div FStep;

  if Assigned(FOnMoveSpin) and (Delta <> 0) and MouseCapture then
  begin
    FOnMoveSpin(Self, Delta);
    CurrPosition := CurrPosition - Delta * FStep;
  end;
end;

procedure TxSpinButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  MouseCapture := True;
  FDownButton.Down := True;
  FUpButton.Down := True;
  CurrPosition := Message.YPos;
end;

procedure TxSpinButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FUpButton.Down := False;
  FDownButton.Down := False;
  MouseCapture := False;
end;

{ TxSpinEdit ---------------------------------------------}

constructor TxSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TxSpinButton.Create(Self);
  FButton.Width := DefSpinButtonWidth;
  FButton.Height := DefSpinButtonHeight;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
  FButton.OnMoveSpin := MoveSpin;

  FSpinGap := DefSpinGap;
  FSpinStep := DefStep;
  FSpinGapColor := DefGapColor;
  FIncrement := DefIncrement;
  FEditorEnabled := True;
  FPostFix := EmptyString;
  FPreFix := EmptyString;

  FValue := DefValue;
  FMaxValue := DefValue;
  FMinValue := DefValue;

  Text := FPreFix + '0' + FPostFix;
  ControlStyle := ControlStyle - [csSetCaption];
end;

destructor TxSpinEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TxSpinEdit.Loaded;
begin
  inherited Loaded;

  FButton.UpGlyph := FButton.UpGlyph;     { helluva trick here }
  FButton.DownGlyph := FButton.DownGlyph; { don't remove these two lines }
end;

procedure TxSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TxSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

function TxSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '+', '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)));

  if not FEditorEnabled and Result and ((Key >= #32) or
    (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then Result := False;
end;

procedure TxSpinEdit.UpClick(Sender: TObject; Delta: Integer);
begin
  if ReadOnly then
    MessageBeep(0)
  else
    SetValue(Value + FIncrement * Delta);
end;

procedure TxSpinEdit.DownClick(Sender: TObject; Delta: Integer);
begin
  if ReadOnly then
    MessageBeep(0)
  else
    SetValue(Value + FIncrement * Delta);
end;

procedure TxSpinEdit.MoveSpin(Sender: TObject; Delta: Integer);
begin
  if ReadOnly then
    MessageBeep(0)
  else
    SetValue(Value + FIncrement * Delta);
end;

procedure TxSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP: UpClick(Self, 1);
    VK_DOWN: DownClick(Self, -1);
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TxSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TxSpinEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  Result := Metrics.tmHeight + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

function TxSpinEdit.GetIntValue: LongInt;
begin
  if Abs(Value) < MaxLongInt then
    Result := Round(Value)
  else
    Result := 0;
end;

function TxSpinEdit.CheckValue(AValue: Double): Double;
begin
  Result := AValue;
  if (FMaxValue <> FMinValue) then
  begin
    if AValue < FMinValue then
      Result := FMinValue
    else
      if AValue > FMaxValue then Result := FMaxValue;
  end;
end;

function TxSpinEdit.GetValue: Double;
var
  B, E, Err: Integer;
  S: String;
begin
  B := 1;
  while (B <= Length(Text)) and not (Text[B] in ['0'..'9', '-', '+']) do
    Inc(B);

  E := Length(Text);
  while (E >= B) and not (Text[E] in ['0'..'9', '-', '+']) do
    Dec(E);

  S := Copy(Text, B, E - B + 1);
  Val(S, Result, Err);
  if Err <> 0 then Result := FValue;
end;

function TxSpinEdit.GetSpinGap: Integer;
begin
  Result := FButton.SpinGap;
end;

function TxSpinEdit.GetSpinStep: Integer;
begin
  Result := FButton.Step;
end;

function TxSpinEdit.GetSpinGapColor: TColor;
begin
  Result := FButton.SpinGapColor;
end;

function TxSpinEdit.GetUpGlyph: TBitmap;
begin
  Result := FButton.GetUpGlyph;
end;

function TxSpinEdit.GetDownGlyph: TBitmap;
begin
  Result := FButton.GetDownGlyph;
end;

function TxSpinEdit.GetSpinButtonWidth: Integer;
begin
  Result := FButton.Width;
end;

function TxSpinEdit.GetRepeatPause: LongInt;
begin
  Result := FButton.RepeatPause;
end;

function TxSpinEdit.GetSpinCursor: TCursor;
begin
  Result := FButton.SpinCursor;
end;

procedure TxSpinEdit.SetValue(AValue: Double);
var
  S: String;                       
begin
  FValue := CheckValue(AValue);
  Str(FValue: 0: DecDigits, S);
  Text := FPreFix + S + FPostFix;
  if Assigned(OnChange) then OnChange(Self);
end;

procedure TxSpinEdit.SetIntValue(AnIntValue: LongInt);
begin
  SetValue(AnIntValue);
end;

procedure TxSpinEdit.SetSpinGap(ASpinGap: Integer);
begin
  FButton.SpinGap := ASpinGap;
end;

procedure TxSpinEdit.SetSpinStep(ASpinStep: Integer);
begin
  FButton.Step := ASpinStep;
end;

procedure TxSpinEdit.SetSpinGapColor(ASpinGapColor: TColor);
begin
  FButton.SpinGapColor := ASpinGapColor;
end;

procedure TxSpinEdit.SetUpGlyph(AnUpGlyph: TBitmap);
begin
  FButton.UpGlyph := AnUpGlyph;  { assign to property }
end;

procedure TxSpinEdit.SetDownGlyph(ADownGlyph: TBitmap);
begin
  FButton.DownGlyph := ADownGlyph; { assign to property }
end;

procedure TxSpinEdit.SetDecDigits(ADecDigits: Word);
begin
  if FDecDigits <> ADecDigits then
  begin
    FDecDigits := ADecDigits;
    SetValue(GetValue);
  end;
end;

procedure TxSpinEdit.SetPostFix(APostFix: String);
begin
  if FPostFix <> APostFix then
  begin
    FPostFix := APostFix;
    SetValue(GetValue);
  end;
end;

procedure TxSpinEdit.SetPreFix(APreFix: String);
begin
  if FPreFix <> APreFix then
  begin
    FPreFix := APreFix;
    SetValue(GetValue);
  end;
end;

procedure TxSpinEdit.SetSpinButtonWidth(ASpinButtonWidth: Integer);
begin
  if GetSpinButtonWidth <> ASpinButtonWidth then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - ASpinButtonWidth - 4, 0, ASpinButtonWidth, Height - 4)
    else
      FButton.SetBounds (Width - ASpinButtonWidth, 1, ASpinButtonWidth, Height - 2);
      
    SetEditRect;
  end;
end;

procedure TxSpinEdit.SetRepeatPause(ARepeatPause: LongInt);
begin
  FButton.RepeatPause := ARepeatPause;
end;

procedure TxSpinEdit.SetSpinCursor(ASpinCursor: TCursor);
begin
  FButton.SpinCursor := ASpinCursor;
end;

procedure TxSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Top := 0;
  Loc.Left := 0;
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 2;
  SendMessage(Handle, EM_SETRECT, 0, LongInt(@Loc));
end;

procedure TxSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  if Height < MinHeight then
    Height := MinHeight
  else
    if FButton <> nil then
    begin
      if NewStyleControls and Ctl3D then
        FButton.SetBounds(Width - FButton.Width - 4, 0, FButton.Width, Height - 4)
      else
        FButton.SetBounds (Width - FButton.Width, 1, FButton.Width, Height - 2);

      SetEditRect;
    end;
end;

procedure TxSpinEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  inherited;
end;

procedure TxSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> Value then SetValue(Value);
end;

procedure TxSpinEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TxSpinEdit.WMCut(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

function TxSpinEdit.SaveUpGlyph: Boolean;
begin
  Result := FButton.SaveUpGlyph;
end;

function TxSpinEdit.SaveDownGlyph: Boolean;
begin
  Result := FButton.SaveDownGlyph;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsBtn', [TxSpinButton]);
  RegisterComponents('gsVC', [TxSpinEdit]);
end;

initialization
  Screen.Cursors[crDragSpin] := LoadCursor(hInstance, 'XSPIN_DRAGCURSOR');
end.
