
{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xInplace.pas

  Abstract

    A Delphi visual component. An inplace edit, which changes own
    sizes with changing the text. Also it includes word wrap.

  Author

    Denis Romanovski (13-Jan-96)

  Revisions history

    1.00          19-Feb-96         Initial version. 

--}

unit xInplace;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids;

const
  WM_GETINPLACECOORD = WM_USER + 777;

type
  TxInplaceEdit = class(TInplaceEdit)
  private
    WasWMChar: Boolean;
    WillHide: Boolean;
    ColHeight: Integer;
    Lines: Integer;
    Time: Integer;

    function GetExtent(S: String): LongInt;
    function GetMaxCharWidth: Integer;
    function GetMaxCharHeight: Integer;
    function CheckCoord: Integer;
    procedure CheckForScrollBars(var AGridWidth, AGridHeight: Integer);

    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure EMSetRectNP(var Message: TMessage);
      message EM_SETRECTNP;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

  public
    constructor Create(AnOwner: TComponent); override;
    
  end;

implementation

{
  Private Part ----------------------------------------------------------------
}

function TxInplaceEdit.GetExtent(S: String): LongInt;
var
{  DC: hDC;
  SaveFont: hFont;}

  BMP: TBitMap;
begin
{  DC := GetDC(Handle);
  SaveFont := SelectObject(DC, Font.Handle);
  S := S + #0;
  Result := GetTextExtent(DC, @S[1], StrLen(@S[1]));}

  BMP := TBitMap.Create;
  try
    BMP.Canvas.Font.Assign(Font);
    Result := BMP.Canvas.TextWidth(S);
  finally  
    BMP.Free;
  end;  

{  SelectObject(DC, SaveFont);
  ReleaseDC(Handle, DC);}
end;

function TxInplaceEdit.GetMaxCharWidth: Integer;
var
  DC: hDC;
  Metrics: TTextMetric;
  OldFont: HFont;
begin
  DC := GetDC(Handle);
  OldFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  Result := Metrics.tmMaxCharWidth;
  SelectObject(DC, OldFont);
  ReleaseDC(Handle, DC);
end;

function TxInplaceEdit.GetMaxCharHeight: Integer;
var
  DC: hDC;
  Metrics: TTextMetric;
  OldFont: HFont;
begin
  DC := GetDC(Handle);
  OldFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  if LOWORD(GetVersion) < 4 then
    Result := (Metrics.tmHeight * 3) div 2
  else
    Result := Metrics.tmHeight;
  SelectObject(DC, OldFont);
  ReleaseDC(Handle, DC);
end;

function TxInplaceEdit.CheckCoord: Integer;
begin
  Result := SendMessage(TCustomGrid(Owner).Handle, WM_GETINPLACECOORD, 0, 0);
end;

procedure TxInplaceEdit.CheckForScrollBars(var AGridWidth, AGridHeight: Integer);
var
  L: LongInt;
begin
  L := GetWindowLong(TCustomGrid(Owner).Handle, GWL_STYLE);
  if (L and WS_HSCROLL) <> 0 then Dec(AGridHeight, GetSystemMetrics(SM_CXVSCROLL));
  if (L and WS_VSCROLL) <> 0 then Dec(AGridWidth, GetSystemMetrics(SM_CYHSCROLL));
end;

procedure TxInplaceEdit.WMChar(var Message: TWMChar);
var
  GridWidth, GridHeight: Integer;
  TextSize: LongInt;
  W, H: Integer;
begin
  inherited;

  if WillHide then
    WillHide := FALSE
  else
    WasWMChar := TRUE;

  GridWidth := TCustomGrid(Owner).Width - Left;
  GridHeight := TCustomGrid(Owner).Height - Top;
  CheckForScrollBars(GridWidth, GridHeight);
  TextSize := GetExtent(Text);

  if LoWord(TextSize) + GetMaxCharWidth * 2 > GridWidth then
  begin
    Lines := LoWord(TextSize) div GridWidth;
    W := LoWord(TextSize) - Lines * GridWidth + GetMaxCharWidth * (Lines + 1);
    Lines := (Lines * GridWidth + W) div GridWidth + 1;

    Width := GridWidth - 1;
    H := HiWord(TextSize) * Lines + HiWord(TextSize) div 2;
    if H > GridHeight then
      Height := GridHeight - 1
    else
      Height := H;
  end else begin
    Lines := 1;
    Width := LoWord(TextSize) + GetMaxCharWidth * 2;
    Height := ColHeight{GetMaxCharHeight};
  end;
end;

procedure TxInplaceEdit.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  GridWidth, GridHeight: Integer;
  TextSize: LongInt;
  W, L: Integer;
begin
  inherited;

  if Time > 0 then Dec(Time);

  if Time = 0 then
  begin
    Time := -1;
    ColHeight := Message.WindowPos^.cy;
    L := CheckCoord;
    if L <> 0 then Message.WindowPos^.x := L;
  end else
    if not WasWMChar then
    begin
      ColHeight := Message.WindowPos^.cy;
      L := CheckCoord;
      if L <> 0 then Message.WindowPos^.x := L;
    end;

  if (Message.WindowPos^.flags and SWP_HIDEWINDOW) <> 0 then
  begin
    WasWMChar := FALSE;
    WillHide := TRUE;
  end;

  if Time = -1 then
  begin
    with Message.WindowPos^ do
    begin
      GridWidth := (Owner as TCustomGrid).Width - X;
      GridHeight := (Owner as TCustomGrid).Height - Top;
      CheckForScrollBars(GridWidth, GridHeight);
      TextSize := GetExtent(Text);

      if LoWord(TextSize) + GetMaxCharWidth * 2 > GridWidth then
      begin
        Lines := LoWord(TextSize) div GridWidth;
        W := LoWord(TextSize) - Lines * GridWidth + GetMaxCharWidth * (Lines + 1);
        Lines := (Lines * GridWidth + W) div GridWidth + 1;

        CX := GridWidth - 1;
        CY := HiWord(TextSize) * Lines + HiWord(TextSize) div 2;
        if CY > GridHeight then CY := GridHeight - 1;
      end else begin
        Lines := 1;
        CX := LoWord(TextSize) + GetMaxCharWidth * 2;
        if HiByte(LoWord(GetVersion)) > 11 then
          CY := ColHeight {GetMaxCharHeight}
        else
          CY := Height;
      end;
    end;
  end;
end;

procedure TxInplaceEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  TCustomGrid(Owner).Invalidate;
end;

procedure TxInplaceEdit.EMSetRectNP(var Message: TMessage);
var
  R: PRect;
////  GridWidth: Integer;
  TextSize: LongInt;
begin
  R := PRect(Message.LParam);
////  GridWidth := (Owner as TCustomGrid).Width - Left - 4;
  TextSize := GetExtent(Text);

  R^.Right := R^.Left + Width - 4;
  R^.Bottom := R^.Top + ColHeight{GetMaxCharHeight} + HiWord(TextSize) * (Lines - 1);
  inherited;
end;

{
  Protected Part ---------------------------------------------------------------
}

procedure TxInplaceEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style and not (ES_AUTOHSCROLL or ES_MULTILINE or ES_AUTOVSCROLL);
end;

{
  Public Part -----------------------------------------------------------------
}

constructor TxInplaceEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  
  BorderStyle := bsSingle;
  WasWMChar := FALSE;
  WillHide := FALSE;
  ColHeight := 0;
  Lines := 1;
  Time := 2;
  AutoSize:= False;
  {Font.Name:= 'Arial';}
end;

end.
