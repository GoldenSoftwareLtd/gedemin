
{++

  Copyright (c) 1995-98 by Golden Software

  Module name

    colcb.pas

  Abstract

    Delphi visual component. Color combo box.

  Author

    Michael Shoihet (8-Oct-95)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    17-Oct-95    michael    Initial version.
    1.01    18-Oct-95    michael    Minor change.
    1.02    19-Oct-95    michael    Minor changes.
    1.03    13-Dec-95    andreik    Minor change.
    1.04    13-Dec-95    andreik    Russian captions instead of english.
    1.05    07-Feb-98    andreik    Fixed minor bug with squarefrompoint method.
    1.06    15-Nov-98    andreik    Parent color support added.
    1.07    16-Feb-99    dennis     Included CM_ENABLEDCHANGED message.

--}

unit ColCB;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TCount = 1..5;
  TGridWidth = 0..10;
  TCellSide = 1..50;

const
  DefStyle = bsNew;
  DefColor = clWhite;
  DefWidth = 42;
  DefHeight = 21;

  DefHorzCount = 4;
  DefVertCount = 5;
  DefCellSide = 21;
  DefGridWidth = 2;
  DefColorButtonHeight = 21;
  DefColorButtonWidth = 62;

  DefColorButtonText = '&Другой...';
{  DefColorButtonText= '&Other...';  }

  NumPaletteEntries = 26;

type

  TColorWindow = class(TCustomControl)
  private
    FPaletteEntries: array[0..NumPaletteEntries] of TPaletteEntry;
    FColorButton: Boolean;
    FHorzCount: TCount;
    FVertCount: TCount;
    FCellSide: TCellSide;
    FGridWidth: TGridWidth;
    FColor: TColor;

    OtherButton: TButton;
    CurrentPos: Integer;
    OldWidth: Integer;

    procedure SetColorButton(AColorButton: Boolean);
    procedure SetHorzCount(AHorzCount: TCount);
    procedure SetVertCount(AVertCount: TCount);
    procedure SetCellSide(ACellSide: TCellSide);
    procedure SetGridWidth(AGridWidth: TGridWidth);
    procedure SetColor(AColor: TColor);

    procedure CalcNewSize;
    procedure DrawSquare(Which: Integer);
    function SquareFromPoint(X, Y: Integer): Integer;
    function GetNumColor(AColor: TColor): Integer;
    procedure SetPalette;

    procedure DownAction(var Message: TWMMouse);
    procedure UpAction(var Message: TWMMouse);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMRButtonDown(var Message: TWMLButtonDown);
      message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Message: TWMLButtonUp);
      message WM_RBUTTONUP;
    procedure WMCommand(var Message: TWMCommand);
      message WM_COMMAND;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMActivate(var Message: TWMActivate);
      message WM_ACTIVATE;

  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    procedure SetButtonText(aText: String);
    procedure SetButtonFont(aFont: TFont);
    procedure SetButtonWidth(aWidth: Integer);
    procedure SetButtonHeight(aHeight: Integer);

  published
    property ColorButton: Boolean read FColorButton write SetColorButton
      default True;
    property HorzCount: TCount read FHorzCount write SetHorzCount
      default DefHorzCount;
    property VertCount: TCount read FVertCount write SetVertCount
      default DefVertCount;
    property CellSide: TCellSide read FCellSide
      write SetCellSide default DefCellSide;
    property GridWidth: TGridWidth read FGridWidth
      write SetGridWidth default DefGridWidth;
    property Color: TColor read FColor write SetColor
      default DefColor;
    property Visible;
  end;

  TColorComboBox = class(TCustomControl)
  private
    { Private declarations }

    FShowColorWindow: Boolean;
    FColor: TColor;
    FActive: Boolean;
    FDown: Boolean;
    FStyle: TButtonStyle;
    FColorButton: Boolean;
    FHorzCount: TCount;
    FVertCount: TCount;
    FCellSide: TCellSide;
    FGridWidth: TGridWidth;
    FColorButtonText: String;
    FColorButtonFont: TFont;
    FColorButtonWidth: Integer;
    FColorButtonHeight: Integer;
    FOnChange: TNotifyEvent;

    ColorWindow: TColorWindow;
    KeyPressed: Boolean;
    FButtonHeight: Integer;
    FButtonWidth: Integer;

    isResizeColorWindow : Boolean;
    isFirst: Boolean;
    OldShowHint: Boolean;
    FColorButtonColor: TColor;

    procedure SetState(NewState: Boolean);
    procedure SetColor(NewColor: TColor);
//    procedure SetActive(AnActive: Boolean);
    procedure SetDown(ADown: Boolean);
    procedure SetStyle(AStyle: TButtonStyle);
    procedure SetColorButton(AColorButton: Boolean);
    procedure SetHorzCount(AHorzCount: TCount);
    procedure SetVertCount(AVertCount: TCount);
    procedure SetCellSide(ACellSide: TCellSide);
    procedure SetGridWidth(AGridWidth: TGridWidth);
    procedure SetButtonWidth(AButtonWidth: Integer);
    procedure SetButtonHeight(AButtonHeight: Integer);
    procedure SetColorButtonText(aText: String);
    procedure SetColorButtonFont(aFont: TFont);
    procedure SetColorButtonWidth(aValue: Integer);
    procedure SetColorButtonHeight(aValue: Integer);

    procedure DrawComboButton;
    procedure MoveColorWindow;

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;
    procedure WMMove(var Message: TWMMove);
      message WM_MOVE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;

//    property Active: Boolean read FActive write SetActive;
    property Down: Boolean read FDown write SetDown;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth
      default DefWidth;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight
      default DefHeight;
    procedure SetColorButtonColor(const Value: TColor);

  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure Change; dynamic;

  public
    { Public declarations }
    isSetFocus: Boolean;
    constructor Create(AnOwner: TComponent); override;
    procedure Click; override;

  published
    { Published declarations }
    property Color: TColor read FColor write SetColor
      default DefColor;
    property Style: TButtonStyle read FStyle write SetStyle default DefStyle;
    property ColorButton: Boolean read FColorButton write SetColorButton
      default True;
    property ColorButtonColor: TColor read FColorButtonColor write SetColorButtonColor
      default clBtnFace;
    property HorzCount: TCount read FHorzCount write SetHorzCount
      default DefHorzCount;
    property VertCount: TCount read FVertCount write SetVertCount
      default DefVertCount;
    property CellSide: TCellSide read FCellSide
      write SetCellSide default DefCellSide;
    property GridWidth: TGridWidth read FGridWidth
      write SetGridWidth default DefGridWidth;
    property ShowColorWindow: Boolean read FShowColorWindow write SetState
      default False;
    property ColorButtonText: String read FColorButtonText
      write SetColorButtonText;
    property ColorButtonFont: TFont read FColorButtonFont
      write SetColorButtonFont;
    property ColorButtonWidth: Integer read FColorButtonWidth
      write SetColorButtonWidth;
    property ColorButtonHeight: Integer read FColorButtonHeight
      write SetColorButtonHeight default DefColorButtonHeight;
    property Width default DefWidth;
    property Height default DefHeight;
    property Visible;
    property Enabled;
    property ShowHint;
    property ParentShowHint;
    property DragCursor;
    property TabStop;
    property TabOrder;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
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

uses
  Rect;

(*
type
  TResourceBitmap = class(TBitmap)
    constructor Create;
  end;
*)

const
  COMBO_WIDTH = 4;
  COMBO_HEIGHT = 2;

  ColorsArray: array[0..15] of TColor =
  (clWhite, clBlack, clLtGray, clDkGray, clRed, clMaroon, clYellow,
   clOlive, clLime, clGreen, clAqua, clTeal, clBlue,
   clNavy, clFuchsia, clPurple);

(*
constructor TResourceBitmap.Create;
begin
  inherited Create;
  HANDLE:= LoadBitmap(0, MakeIntResource(OBM_COMBO));
end;
*)

function Max(A, B: Integer): Integer;
begin
  if A > B then
    Max:= A
  else
    Max:= B;
end;

{ TColorWindow -------------------------------------------}

constructor TColorWindow.Create(AnOwner: TComponent);
var
  i: Integer;
  N1: array[0..3] of TPaletteEntry;
begin
  inherited Create(AnOwner);

  FColorButton:= True;
  FVertCount:= DefVertCount;
  FHorzCount:= DefHorzCount;
  FCellSide:= DefCellSide;
  FGridWidth:= DefGridWidth;
  FColor:= DefColor;

  ParentShowHint:= false;

  OtherButton:= TButton.Create(Self);

  OldWidth:= DefColorButtonWidth;

  OtherButton.Height:= DefColorButtonHeight;
  OtherButton.Width:= DefColorButtonWidth;
  OtherButton.Caption:= DefColorButtonText;

  GetPaletteEntries(GetStockObject(DEFAULT_PALETTE), 0, NumPaletteEntries,
    FPaletteEntries);

  for i:= 8 to 11 do
    N1[i-8]:= FPaletteEntries[i];

  for i:= 8 to 15 do
    FPaletteEntries[i]:= FPaletteEntries[i+4];

  for i:= 16 to 19 do
    FPaletteEntries[i]:= N1[i-16];

  SetPalette;
  CurrentPos:= -1;

  Visible:= False;
end;

procedure TColorWindow.SetPalette;
var
  i: Integer;
begin
  for i:= 0 to 15 do
    with FPaletteEntries[i] do begin
      peRed:= GetRValue(ColorsArray[i]);
      peGreen:= GetGValue(ColorsArray[i]);
      peBlue:= GetBValue(ColorsArray[i]);
    end;
end;

procedure TColorWindow.SetButtonText(aText: String);
begin
  OtherButton.Caption:= aText;
  TColorComboBox(Parent).ColorButtonWidth:= Canvas.TextWidth(aText) + 5;
end;

procedure TColorWindow.SetButtonFont(aFont: TFont);
var
  Temp: array[0..255] of Char;
begin
  OtherButton.Font.Assign(aFont);
  Canvas.Font.Assign(aFont);

  TColorComboBox(Parent).ColorButtonWidth:=
                       Canvas.TextWidth(OtherButton.Caption) + 5;
  StrPCopy(Temp, OtherButton.Caption);
  if Temp[0] <> #0 then
    TColorComboBox(Parent).ColorButtonHeight := Canvas.TextExtent(Temp).cy + 3;
end;

procedure TColorWindow.SetButtonWidth(aWidth: Integer);
begin
  if OtherButton.Width = aWidth then exit;

  OldWidth:= aWidth;
  OtherButton.Width:= aWidth;

  if (CurrentPos < NumPaletteEntries) or
     (OtherButton.Width < Width - DefCellSide)
  then
    OtherButton.Width:= OldWidth
  else
    OtherButton.Width:= OtherButton.Width - DefCellSide;

end;

procedure TColorWindow.SetButtonHeight(aHeight: Integer);
begin
  if OtherButton.Height <> aHeight then
  begin
    OtherButton.Height:= aHeight;
    CalcNewSize;
  end;
end;

procedure TColorWindow.SetColorButton(AColorButton: Boolean);
begin
  if FColorButton <> AColorButton then begin
    FColorButton:= AColorButton;
    if not FColorButton then
      OtherButton.Hide
    else
      OtherButton.Show;
    CalcNewSize;
  end;
end;

procedure TColorWindow.SetHorzCount(AHorzCount: TCount);
begin

  if AHorzCount <> FHorzCount then begin
    FHorzCount:= AHorzCount;
    CalcNewSize;
    if Visible then
      Invalidate;
  end;
end;

procedure TColorWindow.SetVertCount(AVertCount: TCount);
begin

  if AVertCount <> FVertCount then begin
    FVertCount:= AVertCount;
    CalcNewSize;
    if Visible then
      Invalidate;
  end;

end;

procedure TColorWindow.SetCellSide(ACellSide: TCellSide);
begin

  if ACellSide <> FCellSide then begin
    FCellSide:= ACellSide;
    CalcNewSize;
    if Visible then
      Invalidate;
  end;
end;

procedure TColorWindow.SetGridWidth(AGridWidth: TGridWidth);
begin

  if AGridWidth <> FGridWidth then begin
    FGridWidth:= AGridWidth;
    CalcNewSize;
    if Visible then
      Invalidate;
  end;

  OtherButton.Top:= Height - OtherButton.Height - FGridWidth * 2;
  OtherButton.Left:= FGridWidth * 2;
end;

procedure TColorWindow.SetColor(AColor: TColor);
begin

  FColor:= AColor;
  CurrentPos:= GetNumColor(FColor);

  if (CurrentPos = NumPaletteEntries) and FColorButton then
    with FPaletteEntries[CurrentPos] do begin
      peRed:= GetRValue(FColor);
      peGreen:= GetGValue(FColor);
      peBlue:= GetBValue(FColor);
    end;

  if (CurrentPos < NumPaletteEntries) or
     (OldWidth < Width - DefCellSide)
  then begin
    if OldWidth <> 0 then
      OtherButton.Width:= OldWidth
  end
  else
    OtherButton.Width:= OldWidth - DefCellSide;

  if Visible then
    Invalidate;

end;

procedure TColorWindow.CalcNewSize;
begin
  Width:= FCellSide * FHorzCount + FGridWidth * 2;

  Height:= FCellSide * FVertCount + FGridWidth * 2;
  if OtherButton.Visible then
    Height:= Height + OtherButton.Height + 4 + FGridWidth * 2;

  OtherButton.Top:= Height - OtherButton.Height - FGridWidth * 2;
end;

procedure TColorWindow.CreateWnd;
begin
  inherited CreateWnd;

  OtherButton.Parent:= Self;
  OtherButton.Default:= False;

  CalcNewSize;

  OtherButton.Top:= Height - OtherButton.Height - FGridWidth * 2;
  OtherButton.Left:= FGridWidth * 2;

  if FColorButton then
    OtherButton.Show
  else
    OtherButton.Hide;

  CurrentPos:= GetNumColor(FColor);

  if (CurrentPos = NumPaletteEntries) and FColorButton then
  begin
    with FPaletteEntries[CurrentPos] do begin
      peRed:= GetRValue(FColor);
      peGreen:= GetGValue(FColor);
      peBlue:= GetBValue(FColor);
    end;
    if (OtherButton.Width + DefCellSide > Width) then begin
      OldWidth:= OtherButton.Width;
      OtherButton.Width:= OtherButton.Width - DefCellSide;
    end;
  end;

end;

procedure TColorWindow.DestroyWnd;
begin
  if MouseCapture then
    MouseCapture:= False;
  inherited DestroyWnd;
end;

procedure TColorWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  with Params do
  begin
    if (csDesigning in Parent.ComponentState) then
      Style:= ws_Child
    else
      Style:= ws_Popup;
  end;
end;

procedure TColorWindow.DrawSquare(Which: Integer);
var
  WinTop, WinLeft: Integer;
  CellRect: TRect;
  VarColor: TColor;
begin
  if (Which >=0) and (Which <= NumPaletteEntries) then
  begin

    WinTop := (Which div FHorzCount) * FCellSide + FGridWidth;

    if Which < NumPaletteEntries then begin
      WinLeft := (Which mod FHorzCount) * FCellSide +
        FGridWidth;
      CellRect := Bounds(WinLeft, WinTop, FCellSide,
        FCellSide);
    end
    else begin

      if not OtherButton.Visible then exit;

      WinLeft := Width - DefCellSide - FGridWidth;
      CellRect := Bounds(WinLeft, Height -
        OtherButton.Height - FGridWidth * 2, DefCellSide,
        DefCellSide);
    end;

    with FPaletteEntries[Which] do
      begin
        VarColor:= TColor(RGB(peRed, peGreen, peBlue));
        Canvas.Brush.Color := VarColor;
        if Ctl3D then
          Canvas.Pen.Color := VarColor;
      end;

    if Ctl3D then
    begin
      Canvas.Pen.Color := clBtnFace;
      with CellRect do
        Canvas.Rectangle(Left, Top, Right, Bottom);

      if Which <> CurrentPos then begin
        InflateRect(CellRect, -1, -1);
        Frame3D(Canvas, CellRect, clBtnShadow, clBtnHighlight, FGridWidth)
      end
      else begin
        InflateRect(CellRect, -1, -1);
        Canvas.Pen.Width := 1;
        Canvas.Pen.Mode  := pmCopy;
        Canvas.Brush.Style:= bsClear;
        Canvas.Pen.Style := psSolid;
        with CellRect do begin
          Canvas.Pen.Color := clBtnText;
          Canvas.Rectangle(Left, Top, Right, Bottom);
          InflateRect(CellRect, -1, -1);
          Canvas.Pen.Color := clBtnHighlight;
          Canvas.Rectangle(Left, Top, Right, Bottom);
          InflateRect(CellRect, -1, -1);
          Canvas.Pen.Color := clBtnText;
          Canvas.Rectangle(Left, Top, Right, Bottom);
          Canvas.Brush.Style:= bsSolid;
        end;
      end;

    end
    else begin
      Canvas.Pen.Color := clBlack;
      with CellRect do
        Canvas.Rectangle(Left, Top, Right, Bottom);
    end;

  end;
end;

procedure TColorWindow.DownAction(var Message: TWMMouse);
var
  R: TPoint;
begin
  if MouseCapture then
    with Message do begin
      R:= Point(XPos, YPos);
      MapWindowPoints(Handle, GetDesktopWindow, R, 1);
      if (OtherButton <> nil) and (WindowFromPoint(R) = OtherButton.Handle) then
      begin
        MouseCapture:= False;
        SendMessage(OtherButton.Handle, wm_LButtonDown, Keys,
          MakeLong(XPos, YPos));
        exit;
      end;
    end;
end;

procedure TColorWindow.UpAction(var Message: TWMMouse);
var
  Num: Integer;
begin
  if MouseCapture then begin
    with Message do
      Num:= SquareFromPoint(XPos, YPos);

    MouseCapture:= False;
    if (Num >= 0) and (Num <= FHorzCount * FVertCount) then
    begin
      with FPaletteEntries[Num] do
        FColor:= TColor(RGB(peRed, peGreen, peBlue));
      TColorComboBox(Parent).Color:= FColor;
    end;
    TColorComboBox(Parent).ShowColorWindow:= False;
  end;
end;

procedure TColorWindow.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if not (csDesigning in Parent.ComponentState) then
    DownAction(Message);
end;

procedure TColorWindow.WMLButtonUp;
begin
  if not (csDesigning in Parent.ComponentState) then
    UpAction(Message);
  inherited;
end;

procedure TColorWindow.WMRButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if not (csDesigning in Parent.ComponentState) then
    DownAction(Message);
end;

procedure TColorWindow.WMRButtonUp(var Message: TWMLButtonUp);
begin
  if not (csDesigning in Parent.ComponentState) then
    UpAction(Message);
  inherited;
end;

procedure TColorWindow.WMCommand(var Message: TWMCommand);
var
  Dialog: TColorDialog;
begin
  inherited;

  if csDesigning in Parent.ComponentState then exit;

  Hide;
  Dialog:= TColorDialog.Create(Self);
  Dialog.Color:= FColor;
  if Dialog.Execute then
  begin
    FColor:= Dialog.Color;
    TColorComboBox(Parent).Color:= FColor;
  end;

  TColorComboBox(Parent).ShowColorWindow:= False;
  TColorComboBox(Parent).SetFocus;
  TColorComboBox(Parent).Change;

  CurrentPos:= GetNumColor(FColor);

  if CurrentPos = NumPaletteEntries then begin
     with FPaletteEntries[CurrentPos] do begin
       peRed:= GetRValue(FColor);
       peGreen:= GetGValue(FColor);
       peBlue:= GetBValue(FColor);
     end;
  end;

end;

procedure TColorWindow.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  if Message.CharCode = vk_Escape then begin
    MouseCapture:= False;
    TColorComboBox(Parent).ShowColorWindow:= False;
  end
  else
    if FColorButton then
      OtherButton.SetFocus;
end;

procedure TColorWindow.WMActivate(var Message: TWMActivate);
begin
  inherited;
  if Message.Active = WA_INACTIVE then
  begin
    MouseCapture:= False;
    TColorComboBox(Parent).isSetFocus:= False;
    TColorComboBox(Parent).ShowColorWindow:= False;
  end;
end;

procedure TColorWindow.WMMouseMove(var Message: TWMMouseMove);
var
  Which, OldWhich: Integer;
begin
  inherited;
  if csDesigning in Parent.ComponentState then exit;
  if MouseCapture then begin
    with Message do begin

      Which:= SquareFromPoint(XPos, YPos);

      if (Which <> CurrentPos) and (Which <> -1) then begin
        OldWhich:= CurrentPos;
        CurrentPos:= Which;
        DrawSquare(OldWhich);
        DrawSquare(CurrentPos);
      end;

    end;
  end;
end;

procedure TColorWindow.Paint;
var
  R: TRect;
  Row: Integer;
begin
  R:= GetClientRect;
  Frame3D(Canvas, R, clBtnHighlight, clBtnShadow, FGridWidth);
  if (Parent <> nil) and (Parent is TColorComboBox) then
    Canvas.Brush.Color := (Parent as TColorComboBox).ColorButtonColor
  else
    Canvas.Brush.Color := clBtnFace;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(R);

  for Row := 0 to FHorzCount * FVertCount - 1 do
    DrawSquare(Row);

  if OtherButton.Visible then begin

    if CurrentPos = NumPaletteEntries then
      DrawSquare( CurrentPos );

    Canvas.Pen.Color:= clBtnHighlight;
    Canvas.Pen.Width:= 1;
    Canvas.Pen.Style := psSolid;
    Canvas.MoveTo(FGridWidth + 1,
      Height - OtherButton.Height - FGridWidth * 2 - 3);
    Canvas.LineTo(Width - FGridWidth - 1,
      Height - OtherButton.Height - FGridWidth * 2 - 3);

    Canvas.Pen.Color:= clBtnShadow;
    Canvas.MoveTo(FGridWidth + 1,
      Height - OtherButton.Height - FGridWidth * 2 - 4);
    Canvas.LineTo(Width - FGridWidth - 1,
      Height - OtherButton.Height - FGridWidth * 2 - 4);

  end;

end;

function TColorWindow.SquareFromPoint(X, Y: Integer): Integer;
begin
  SquareFromPoint:= -1;

  if (X < 0) or (Y < 0) then
    exit;

  if (X >= Width - FGridWidth * 2) or (X <= FGridWidth *2) then exit;
  if (Y >= Height - FGridWidth) or (Y <= FGridWidth) then exit;

  try
    Result:= (Y div FCellSide) * FHorzCount + X div FCellSide;
  except
    Result:= -1;
  end;

  if (Result >= FHorzCount * FVertCount) and
     (GetNumColor(FColor) < NumPaletteEntries)
  then
    Result:= -1
  else
    if (GetNumColor(FColor) = NumPaletteEntries) and
       (Result >= FHorzCount * FVertCount)
    then
      Result:= NumPaletteEntries;
end;

function TColorWindow.GetNumColor(AColor: TColor): Integer;
var
  i: Integer;
begin
  Result:= NumPaletteEntries;
  for i:= 0 to FHorzCount * FVertCount - 1 do
    with FPaletteEntries[i] do
      if AColor = TColor(RGB(peRed, peGreen, peBlue)) then
      begin
        Result:= i;
        Break;
      end;
end;

{ TColorComboBox component -------------------------------}

constructor TColorComboBox.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  isFirst:= true;

  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  ColorWindow:= TColorWindow.Create(nil);
  ColorWindow.Parent:= Self;

  FShowColorWindow:= False;
  FColor:= DefColor;
  FDown:= False;
  FActive:= True;
  FStyle:= DefStyle;
  FColorButton:= True;
  TabStop:= True;

  FVertCount:= DefVertCount;
  FHorzCount:= DefHorzCount;
  FCellSide:= DefCellSide;
  FGridWidth:= DefGridWidth;

  Width:= DefWidth;
  Height:= DefHeight;
  FColorButtonText:= DefColorButtonText;
  FColorButtonFont:= Font;

  FColorButtonWidth:= DefColorButtonWidth;
  FColorButtonHeight:= DefColorButtonHeight;

  FColorButtonColor := clBtnFace;

  FButtonHeight:= DefHeight;
  FButtonWidth:= DefWidth;

  KeyPressed := False;
  isResizeColorWindow:= True;
  isSetFocus:= True;

end;

procedure TColorComboBox.SetState(NewState: Boolean);
begin
  if NewState <> FShowColorWindow then begin

    FShowColorWindow:= NewState;

    if (ComponentState = [csDesigning])
    then begin

      if NewState then begin

        if ColorWindow.Width = 0 then
          ColorWindow.CalcNewSize;

        if not isFirst then begin
          ButtonHeight:= Height;
          ButtonWidth:= Width;
        end;

        isResizeColorWindow:= false;

        SetWindowPos(Handle, 0, Left, Top, Max(Width, ColorWindow.Width),
          ButtonHeight + ColorWindow.Height,  SWP_NOZORDER);

      end
      else
        SetWindowPos(Handle, 0, Left, Top, ButtonWidth, ButtonHeight,
          SWP_NOZORDER);

    end;

    if FShowColorWindow then begin
      if isFirst  then begin
        if Width <> ButtonWidth then
          Width:= ButtonWidth;
        if Height <> ButtonHeight then
          Height:= ButtonHeight;

        ColorWindow.CalcNewSize;
        FShowColorWindow:= False;
        isFirst:= false;
        exit;
      end;

      MoveColorWindow;
      ColorWindow.Show;
      ColorWindow.Color:= FColor;
      if not (csDesigning in ComponentState)  then begin
        ShowHint:= false;
        ColorWindow.MouseCapture:= True;
        ColorWindow.SetFocus;
      end;
    end
    else begin
      ColorWindow.Hide;
//        if not (csDesigning in ComponentState) and isSetFocus then SetFocus;
      ShowHint:= OldShowHint;
      isSetFocus:= True;
      if not (csDestroying in ComponentState) then
        SetFocus;
    end;
  end;
  isFirst:= false;
end;

procedure TColorComboBox.SetColor(NewColor: TColor);
begin
  if FColor <> NewColor then
  begin
    FColor:= NewColor;
    ColorWindow.Color:= NewColor;
    Change;
    Invalidate;
  end;
end;

(*
procedure TColorComboBox.SetActive(AnActive: Boolean);
begin
  if AnActive <> FActive then begin
    FActive:= AnActive;
    Invalidate;
  end;
end;
*)

procedure TColorComboBox.SetDown(ADown: Boolean);
begin
  if FDown <> ADown then begin
    FDown:= ADown;
    Invalidate;
  end;
end;

procedure TColorComboBox.SetStyle(AStyle: TButtonStyle);
begin
  if FStyle <> AStyle then begin
    FStyle:= AStyle;
    Invalidate;
  end;
end;

procedure TColorComboBox.SetColorButton(AColorButton: Boolean);
begin
  if FColorButton <> AColorButton then begin
    FColorButton:= AColorButton;
    if ColorWindow <> nil then begin
      ColorWindow.ColorButton:= AColorButton;
      if FShowColorWindow then begin
        isResizeColorWindow:= False;
        SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
           ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
      end;
    end;
  end;
end;

procedure TColorComboBox.SetHorzCount(AHorzCount: TCount);
begin
  if FHorzCount <> AHorzCount then begin
    FHorzCount:= AHorzCount;
    ColorWindow.HorzCount:= AHorzCount;
    MoveColorWindow;
    if FShowColorWindow then begin
      isResizeColorWindow:= False;
      SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
        ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
    end;
  end;
end;

procedure TColorComboBox.SetVertCount(AVertCount: TCount);
begin
  if FVertCount <> AVertCount then begin
    FVertCount:= AVertCount;
    ColorWindow.VertCount:= AVertCount;
    MoveColorWindow;
    if FShowColorWindow then begin
      isResizeColorWindow:= False;
      SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
        ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
    end;
  end;
end;

procedure TColorComboBox.SetCellSide(ACellSide: TCellSide);
begin
  if FCellSide <> ACellSide then begin
    FCellSide:= ACellSide;
    ColorWindow.CellSide:= ACellSide;
    MoveColorWindow;
    if FShowColorWindow and isResizeColorWindow then begin
      isResizeColorWindow:= False;
      SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
        ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
    end;
  end;
end;

procedure TColorComboBox.SetGridWidth(AGridWidth: TGridWidth);
begin
  if FGridWidth <> AGridWidth then begin
    FGridWidth:= AGridWidth;
    ColorWindow.GridWidth:= AGridWidth;
    MoveColorWindow;
    if FShowColorWindow then begin
      isResizeColorWindow:= False;
      SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
        ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
    end;
  end;
end;

procedure TColorComboBox.SetButtonWidth(AButtonWidth: Integer);
begin

  if aButtonWidth <> FButtonWidth then begin
    FButtonWidth:= aButtonWidth;
    if (ComponentState <> [csDesigning]) and (Width <> ButtonWidth) then
      Width:= ButtonWidth;
  end;

end;

procedure TColorComboBox.SetButtonHeight(AButtonHeight: Integer);
begin
  if aButtonHeight <> FButtonHeight then begin
    FButtonHeight:= aButtonHeight;
    if (ComponentState <> [csDesigning]) and (Height <> ButtonHeight) then
      Height:= ButtonHeight;
  end;
end;

procedure TColorComboBox.SetColorButtonText(aText: String);
begin
  if FColorButtonText <> aText then begin
    FColorButtonText:= aText;
    ColorWindow.SetButtonText(aText);
  end;
end;

procedure TColorComboBox.SetColorButtonFont(aFont: TFont);
begin
  FColorButtonFont.Assign(aFont);
  ColorWindow.SetButtonFont(aFont);
end;

procedure TColorComboBox.SetColorButtonWidth(aValue: Integer);
begin
  FColorButtonWidth:= aValue;
  ColorWindow.SetButtonWidth(aValue);
end;

procedure TColorComboBox.SetColorButtonHeight(aValue: Integer);
begin
  if FColorButtonHeight <> aValue then begin
    FColorButtonHeight:= aValue;
    ColorWindow.SetButtonHeight(aValue);
    if FShowColorWindow then begin
      isResizeColorWindow:= False;
      SetWindowPos(Handle, 0, Left, Top, Max(ButtonWidth, ColorWindow.Width),
        ButtonHeight + ColorWindow.Height, SWP_NOZORDER);
    end;
  end;
end;

procedure TColorComboBox.MoveColorWindow;
var
  P: TPoint;
begin
  if ComponentState <> [csDesigning] then begin
    P:= Point(Left, Top + Height);
    MapWindowPoints(Parent.Handle, GetDesktopWindow, P, 1);
    if ColorWindow.Parent <> nil then
      ColorWindow.SetBounds(P.X, P.Y, ColorWindow.Width, ColorWindow.Height);
//      MoveWindow(ColorWindow.HANDLE, P.X, P.Y, ColorWindow.Width, ColorWindow.Height,
//        true);
  end
  else
    if ShowColorWindow then
      ColorWindow.SetBounds(0, ButtonHeight, ColorWindow.Width, ColorWindow.Height);
//      MoveWindow(ColorWindow.HANDLE, 0, ButtonHeight, ColorWindow.Width,
//        ColorWindow.Height, true);
end;

procedure TColorComboBox.DrawComboButton;
var
  R, ColorR: TRect;
  Bitmap: TBitmap;
  PolyArray: array[0..2] of TPoint;
begin
  R := GetClientRect;

  if FShowColorWindow and (ComponentState = [csDesigning]) then begin
    R.Right:= ButtonWidth;
    R.Bottom:= ButtonHeight;
  end;

  Bitmap := TBitmap.Create;

  try
    Bitmap.Width := RectWidth(R);
    Bitmap.Height := RectHeight(R);

    R := DrawButtonFace(Bitmap.Canvas, R, 1, FStyle, False, FDown, False);

    if FColorButtonColor <> clBtnFace then
    begin
      Bitmap.Canvas.Brush.Color:= FColorButtonColor;
      Bitmap.Canvas.Brush.Style := bsSolid;
      Bitmap.Canvas.FillRect(R);
    end;

    RectGrow(R, -1);

    if Focused then Bitmap.Canvas.DrawFocusRect(R);

    SetRect(ColorR, R.left + 2, R.top + 1, round(R.right / 3 * 2),
      R.Bottom - 1);

    if Enabled then begin
      Bitmap.Canvas.Pen.Color:= clBtnText;
      Bitmap.Canvas.Pen.Width:= 1;
      Bitmap.Canvas.Pen.Style := psSolid;
      Bitmap.Canvas.Brush.Color:= Color;
      Bitmap.Canvas.Brush.Style := bsSolid;
      Bitmap.Canvas.Rectangle(ColorR.Left, ColorR.Top, ColorR.Right,
        ColorR.Bottom);
    end;

    Bitmap.Canvas.Pen.Color:= clBtnShadow;
    Bitmap.Canvas.MoveTo(ColorR.right + 3, R.top + 1);
    Bitmap.Canvas.LineTo(ColorR.right + 3, R.bottom - 1);

    Bitmap.Canvas.Pen.Color:= clBtnHighlight;
    Bitmap.Canvas.MoveTo(ColorR.right + 4, R.top + 1);
    Bitmap.Canvas.LineTo(ColorR.right + 4, R.bottom - 1);

    if Enabled then begin
      Bitmap.Canvas.Pen.Color:= clBtnText;
      Bitmap.Canvas.Brush.Color:= clBtnText;
    end
    else begin
      Bitmap.Canvas.Pen.Color:= clBtnShadow;
      Bitmap.Canvas.Brush.Color:= clBtnShadow;
    end;

    PolyArray[0].X:= ColorR.right + 3 +
      (R.Right - ColorR.right - COMBO_WIDTH) div 2;
    PolyArray[0].Y:= R.top + (R.bottom - R.top - COMBO_HEIGHT) div 2;

    PolyArray[1].X:= PolyArray[0].X + COMBO_WIDTH;
    PolyArray[1].Y:= PolyArray[0].Y;

    PolyArray[2].X:= PolyArray[1].X - (PolyArray[1].X - PolyArray[0].X) div 2;
    PolyArray[2].Y:= PolyArray[0].Y + COMBO_HEIGHT;

    Bitmap.Canvas.Polygon( PolyArray );

    if not Enabled then begin
      Bitmap.Canvas.Pen.Color:= clBtnHighlight;
      Bitmap.Canvas.MoveTo(PolyArray[1].X, PolyArray[0].Y);
      Bitmap.Canvas.LineTo(PolyArray[1].X -
        (PolyArray[1].X - PolyArray[0].X) div 2,
        PolyArray[0].Y + COMBO_HEIGHT);
    end;

    Canvas.Draw(0, 0, Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TColorComboBox.Loaded;
begin
  inherited Loaded;
  OldShowHint:= ShowHint;
end;

procedure TColorComboBox.CreateWnd;
begin
  inherited CreateWnd;

  FActive:= True;

  MoveColorWindow;
end;

procedure TColorComboBox.Paint;
begin

  DrawComboButton;
  isFirst:= false;

end;

procedure TColorComboBox.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TColorComboBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if not KeyPressed then begin
    MouseCapture := True;
    SetFocus;
    Down := True;
  end;
end;

procedure TColorComboBox.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if not KeyPressed then begin
    if MouseCapture then MouseCapture := False;
    if Down then Down := False;
    ShowColorWindow:= True;
  end;
end;

procedure TColorComboBox.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if (not KeyPressed) and MouseCapture then
    Down := (Message.XPos >= 0) and (Message.XPos < Width)
      and (Message.YPos >= 0) and (Message.YPos < Height);
end;

procedure TColorComboBox.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  if (not MouseCapture) and (Message.CharCode = vk_Space) then
  begin
    MouseCapture:= True;
    KeyPressed:= True;
    Down := True;
  end;
end;

procedure TColorComboBox.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
  if KeyPressed and (Message.CharCode = vk_Space) then
  begin
    MouseCapture:= False;
    KeyPressed:= False;
    Down := False;
    Click;
  end;
end;

procedure TColorComboBox.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode = BN_CLICKED then Click;
end;

procedure TColorComboBox.WMMove(var Message: TWMMove);
begin
  inherited;
  MoveColorWindow;
end;

procedure TColorComboBox.WMSize(var Message: TWMSize);
begin
  inherited;
  if ComponentState = [csDesigning] then begin
    if FShowColorWindow then
      if isResizeColorWindow then begin
        isResizeColorWindow:= false;
        CellSide:= (Width - GridWidth * 2) div HorzCount;
        SetWindowPos(HANDLE, 0, Left, Top, ColorWindow.Width,
          ColorWindow.Height + ButtonHeight, SWP_NOZORDER);
      end
      else
        isResizeColorWindow:= true;
  end;
end;

procedure TColorComboBox.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TColorComboBox.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TColorComboBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TColorComboBox.Click;
begin
  inherited Click;
  ShowColorWindow:= True;
end;

procedure TColorComboBox.SetColorButtonColor(const Value: TColor);
begin
  FColorButtonColor := Value;
  Invalidate;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TColorComboBox]);
end;

end.
