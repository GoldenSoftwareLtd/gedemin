
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xColorTabSet.pas

  Abstract

    A multi colors tab set.

  Author

    Andrei Kireev (01-Jul-98)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    2-Jul-98    andreik    Initial version.
    1.01    8-Sep-98    andreik    Property added.
    1.02    9-Nov-98    andreik    Одной ошибкой исправлена другая!!! Разобраться.

--}

unit xColorTabSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, xPanel;

type
  TxctsOrientation = (ctsoTop, ctsoRight);

const
  DefOrientation = ctsoRight;

type
  TxColorTabSet = class(TxPanel)
  private
    FTabs, FTabColors: String;
    FActiveIndex: Integer;
    D: Integer;  //!!!
    FNotebook: TNotebook;
    FHighlightColor: TColor;
    FOrientation: TxctsOrientation;
    ColorsArray: array of TColor;
    Flag: Boolean;
    FHighlightIndex: Integer;
    FDisabledIndex: Integer;
    FDisabledIndex2: Integer;

    procedure SetTabs(const ATabs: String);
    procedure SetTabColors(ATabColors: String);
    procedure SetActiveIndex(const AnActiveIndex: Integer);
    function GetTabsCount: Integer;
    function GetTabHeight: Integer;
    procedure SetHighlightColor(AHighlightColor: TColor);
    function GetTabText(ATab: Integer): String;
    procedure SetOrientation(const Value: TxctsOrientation);
    procedure SetNotebook(const Value: TNotebook);
    function GetColorsArr(const Index: Integer): TColor;
    procedure SetColorsArr(const Index: Integer; const Value: TColor);
    procedure SyncTabColors;
    procedure SetHighlightIndex(const Value: Integer);
    procedure SetDisabledIndex(const Value: Integer);
    procedure SetDisabledIndex2(const Value: Integer);

  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure DrawText(const ATab: Integer; const AText: String);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure CMWantSpecialKey(var Message: TCMDialogKey);
      message CM_WANTSPECIALKEY;

    procedure KeyDown(var Key: Word; Shift: TShiftState);
      override;

    property HighlightIndex: Integer read FHighlightIndex write SetHighlightIndex;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure ForceNotebook;
    procedure DoOnPageChanged(Sender: TObject);
    procedure SetAllColors(const AColor: TColor);

    property TabsCount: Integer read GetTabsCount;
    property TabHeight: Integer read GetTabHeight;
    property TabColorsArr[const Index: Integer]: TColor read GetColorsArr write SetColorsArr;


  published
    property Tabs: String read FTabs write SetTabs;
    property TabColors: String read FTabColors write SetTabColors;
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex;
    property Notebook: TNotebook read FNotebook write SetNotebook;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor
      default clWhite;
    property Orientation: TxctsOrientation read FOrientation write SetOrientation
      default DefOrientation;
    property DisabledIndex: Integer read FDisabledIndex write SetDisabledIndex
      default -1;
    property DisabledIndex2: Integer read FDisabledIndex2 write SetDisabledIndex2
      default -1;
  end;

procedure Register;

implementation

(*

function Ternary(const F: Boolean; const A, B: Byte): Byte;
begin
  if F then Result := A
    else Result := B;
end;

procedure DoDelay(Pause: Word);
var
  OldTime: LongInt;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do { nothing };
end;

*)

{ TxColorTabSet ------------------------------------------}

constructor TxColorTabSet.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FHighlightColor := clWhite;
  FOrientation := DefOrientation;
  D := 6;
  Flag := True;
  FHighlightIndex := -1;
  FDisabledIndex := -1;
  FDisabledIndex2 := -1;
end;

procedure TxColorTabSet.ForceNotebook;
begin
  if Assigned(FNotebook) then
  begin
    Flag := False;
    FNotebook.PageIndex := FActiveIndex;
    Flag := True;
  end;
end;

procedure TxColorTabSet.Paint;
var
  I: Integer;
  ActiveColor: TColor;
begin
  inherited Paint;

  //
  if (TabsCount = 1) or (TabsCount > High(ColorsArray) + 1) then
    exit;

  //
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsSolid;

  ActiveColor := clBlack; // avoid compiler msg

  if FOrientation = ctsoRight then
  begin
    for I := 0 to TabsCount - 1 do
    begin
      Canvas.Pen.Style := psClear;
      Canvas.Pen.Color := clBlack;

      Canvas.Brush.Color := ColorsArray[I];

      if I <> FActiveIndex then
      begin
        Canvas.Polygon([Point(0, I * TabHeight - D * I),
          Point(Width - 1, I * TabHeight + 5 - D * I),
          Point(Width - 1, I * TabHeight + TabHeight - 5 - 1 - D * I),
          Point(0, I * TabHeight + TabHeight - 1 - D * I)]);
          DrawText(I, GetTabText(I));
      end else
        ActiveColor := Canvas.Brush.Color;

      Canvas.Pen.Color := clBtnHighlight;
      Canvas.Pen.Style := psSolid;
      Canvas.Polyline([
        Point(1, I * TabHeight + TabHeight - 1 - D * I - 1),
        Point(1, I * TabHeight - D * I + 1),
        Point(Width - 1 - 1, I * TabHeight + 5 - D * I + 1)]);

      Canvas.Pen.Color := clBtnShadow;
      Canvas.Polyline([
        Point(Width - 1 - 1, I * TabHeight + 5 - D * I + 1),
        Point(Width - 1 - 1, I * TabHeight + TabHeight - 5 - 1 - D * I - 1),
        Point(1, I * TabHeight + TabHeight - 1 - D * I - 1)])
    end;

    //
    (*
    Canvas.Brush.Color := TColor(RGB(Ternary(GetRValue(ActiveColor) < 205, GetRValue(ActiveColor) + 50, $FF),
      Ternary(GetGValue(ActiveColor) < 205, GetGValue(ActiveColor) + 50, $FF),
      Ternary(GetBValue(ActiveColor) < 205, GetBValue(ActiveColor) + 50, $FF)));
    *)

    Canvas.Pen.Color := clBlack;
    Canvas.Pen.Style := psClear;

    if FHighlightColor <> clNone then
      Canvas.Brush.Color := FHighlightColor
    else
      Canvas.Brush.Color := ActiveColor;

    Canvas.Polygon([Point(0, FActiveIndex * TabHeight - D * FActiveIndex),
      Point(Width - 1, FActiveIndex * TabHeight + 5 - D * FActiveIndex),
      Point(Width - 1, FActiveIndex * TabHeight + TabHeight - 5 - 1 - D * FActiveIndex),
      Point(0, FActiveIndex * TabHeight + TabHeight - 1 - D * FActiveIndex)]);

    Canvas.Pen.Style := psSolid;

    Canvas.Pen.Color := clBtnHighlight;
    Canvas.Polyline([
      Point(0, FActiveIndex * TabHeight + TabHeight - 1 - D * FActiveIndex - 1),
      Point(0, FActiveIndex * TabHeight - D * FActiveIndex + 1),
      Point(Width - 1 - 1, FActiveIndex * TabHeight + 5 - D * FActiveIndex + 1)]);

    Canvas.Pen.Color := clBtnShadow;
    Canvas.Polyline([
      Point(Width - 1 - 1, FActiveIndex * TabHeight + 5 - D * FActiveIndex + 1),
      Point(Width - 1 - 1, FActiveIndex * TabHeight + TabHeight - 5 - 1 - D * FActiveIndex - 1),
      Point(1, FActiveIndex * TabHeight + TabHeight - 1 - D * FActiveIndex - 1)]);

    DrawText(FActiveIndex, GetTabText(FActiveIndex));
  end
  else if FOrientation = ctsoTop then
  begin
    for I := 0 to TabsCount - 1 do
    begin
      Canvas.Pen.Style := psClear;
//      Canvas.Pen.Color := clBlack;

      Canvas.Brush.Color := ColorsArray[I];
      Canvas.Brush.Style := bsSolid;

      if I <> FActiveIndex then
      begin
        Canvas.Polygon([Point(I * TabHeight - D * I - 1, Height {- 1}),
          Point(I * TabHeight - D * I + 5 - 1, 0),
          Point(I * TabHeight + TabHeight - D * I - 5, 0),
          Point(I * TabHeight + TabHeight - D * I, Height {- 1})]);
        DrawText(I, GetTabText(I));

        Canvas.Pen.Color := clBtnHighlight;
        Canvas.Pen.Style := psSolid;
        Canvas.Polyline([
          Point(I * TabHeight - D * I - 1, Height),
          Point(I * TabHeight - D * I - 1 + 5, 0),
          Point(I * TabHeight + TabHeight - 5 - D * I, 0)]);

        Canvas.Pen.Color := clBtnShadow;
        Canvas.Polyline([
          Point(I * TabHeight + TabHeight - 5 - D * I, 1),
          Point(I * TabHeight + TabHeight - D * I, Height - 1),
          Point(I * TabHeight - D * I, Height - 1)])
      end else
        ActiveColor := Canvas.Brush.Color;
    end;

    Canvas.Pen.Color := clBlack;
    Canvas.Pen.Style := psClear;

    if FHighlightColor <> clNone then
      Canvas.Brush.Color := FHighlightColor
    else
      Canvas.Brush.Color := ActiveColor;

    Canvas.Polygon([Point(FActiveIndex * TabHeight - D * FActiveIndex - 1, Height {- 1}),
      Point(FActiveIndex * TabHeight - D * FActiveIndex + 5 - 1, 0),
      Point(FActiveIndex * TabHeight + TabHeight - D * FActiveIndex - 5, 0),
      Point(FActiveIndex * TabHeight + TabHeight - D * FActiveIndex, Height {- 1})]);

    Canvas.Pen.Style := psSolid;

    Canvas.Pen.Color := clBtnHighlight;
    Canvas.Pen.Style := psSolid;
    Canvas.Polyline([
      Point(0, Height - 1),
      Point(FActiveIndex * TabHeight - D * FActiveIndex - 1, Height - 1),
      Point(FActiveIndex * TabHeight - D * FActiveIndex - 1 + 5, 0),
      Point(FActiveIndex * TabHeight + TabHeight - 5 - D * FActiveIndex, 0)]);

    Canvas.Pen.Color := clBtnShadow;
    Canvas.Polyline([
      Point(FActiveIndex * TabHeight + TabHeight - 5 - D * FActiveIndex, 1),
      Point(FActiveIndex * TabHeight + TabHeight - D * FActiveIndex, Height - 1),
      Point(Width, Height - 1)]);

    Canvas.Pen.Color := Canvas.Brush.Color;
    Canvas.Polyline([
      Point(FActiveIndex * TabHeight + TabHeight - D * FActiveIndex - 1, Height - 1),
      Point(FActiveIndex * TabHeight - D * FActiveIndex - 1, Height - 1)]);

    DrawText(FActiveIndex, GetTabText(FActiveIndex));
  end;
end;

procedure TxColorTabSet.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  // must be an ActiveIndex
  if FOrientation = ctsoRight then
    ActiveIndex := Trunc((Y / Height) * TabsCount)
  else
    ActiveIndex := Trunc((X / Width) * TabsCount);

  SetFocus;  

//  Invalidate;
end;

procedure TxColorTabSet.DrawText(const ATab: Integer; const AText: String);
var
  DC: TCanvas;
  XForm: TXForm;
  Ch: array[0..255] of Char;
  R: TRect;
begin
  if FOrientation = ctsoRight then
  begin
    DC := TCanvas.Create;
    DC.Handle := GetDC(Self.Handle);
    try
      SetGraphicsMode(DC.Handle, GM_ADVANCED);

      XForm.eM11 := Cos(Pi / 2);
      XForm.eM12 := Sin(Pi / 2);
      XForm.eM21 := - Sin(Pi / 2);
      XForm.eM22 := Cos(Pi / 2);
      XForm.eDx := 0;
      XForm.eDy := 0;

      SetWorldTransform(DC.Handle, XForm);

      DC.Font.Assign(Self.Font);
      if (ATab = FDisabledIndex) or (ATab = FDisabledIndex2) then
        DC.Font.Color := clGray;

      SetBkMode(DC.Handle, TRANSPARENT);

      R.Left := ATab * TabHeight - ATab * D;
      R.Top := - Width + 2;
      R.Right := ATab * TabHeight + TabHeight - ATab * D;
      R.Bottom := - 2;

      StrPCopy(Ch, AText);
      DrawTextEx(DC.Handle, Ch, StrLen(Ch), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE, nil);

    finally
      ReleaseDC(Self.Handle, DC.Handle);
      DC.Free;
    end;
  end
  else if FOrientation = ctsoTop then
  begin
    SetBkMode(Canvas.Handle, TRANSPARENT);

    R.Left := ATab * TabHeight - ATab * D;
    R.Top := 2;
    R.Right := ATab * TabHeight + TabHeight - ATab * D;
    R.Bottom := Height - 2;

    if (ATab = FDisabledIndex) or (ATab = FDisabledIndex2) then
      Canvas.Font.Color := clGray
    else
      if ATab = FHighlightIndex then
        Canvas.Font.Color := clBlue
      else
        Canvas.Font.Color := clBlack;

    StrPCopy(Ch, AText);
    DrawTextEx(Canvas.Handle, Ch, StrLen(Ch), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE, nil);

    //
    if Focused and (ATab = FActiveIndex) then
    begin
      R.Left := R.Left + D;
      R.Right := R.Right - D;
      Canvas.Brush.Color := clGray;
      Canvas.Brush.Style := bsSolid;
      Canvas.FrameRect(R);
    end;
  end;
end;

procedure TxColorTabSet.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FNotebook) then
    FNotebook := nil;
end;

procedure TxColorTabSet.SetTabs(const ATabs: String);
begin
  if ATabs <> FTabs then
  begin
    FTabs := ATabs;
    Invalidate;
  end;
end;

procedure TxColorTabSet.SetTabColors(ATabColors: String);
var
  Cl: Longint;
  ColorStr: String;
begin
  if ATabColors <> FTabColors then
  begin
    FTabColors := ATabColors;

    SetLength(ColorsArray, 0);

    while Length(ATabColors) > 0 do
    begin
      if Pos(';', ATabColors) > 0 then
        ColorStr := Copy(ATabColors, 1, Pos(';', ATabColors) - 1)
      else
        ColorStr := ATabColors;

      Delete(ATabColors, 1, Length(ColorStr) + 1);

      SetLength(ColorsArray, High(ColorsArray) - Low(ColorsArray) + 1 + 1);

      if IdentToColor(ColorStr, Cl) then
        ColorsArray[High(ColorsArray)] := Cl
      else
        ColorsArray[High(ColorsArray)] := StringToColor(ColorStr);
    end;

    Invalidate;
  end;
end;

procedure TxColorTabSet.SetActiveIndex(const AnActiveIndex: Integer);
begin
  if (AnActiveIndex < 0) or (AnActiveIndex >= GetTabsCount) then
    raise Exception.Create('Invalid tab index');

  if (AnActiveIndex = FDisabledIndex) or (AnActiveIndex = FDisabledIndex2) then
    exit;

  if AnActiveIndex <> FActiveIndex then
  begin
    // test!!!
    FActiveIndex := AnActiveIndex;
    Invalidate;
  end;

  if Assigned(FNotebook) then
  begin
    Flag := False;
    FNotebook.PageIndex := FActiveIndex;
    Flag := True;
  end;
end;

function TxColorTabSet.GetTabsCount: Integer;
var
  I: Integer;
begin
  // lets count tabs
  Result := 1;
  for I := 1 to Length(FTabs) do
    if FTabs[I] = ';' then Result := Result + 1;
end;

function TxColorTabSet.GetTabHeight: Integer;
begin
  //
  if FOrientation = ctsoRight then
    Result := Trunc((Height + 5 * (TabsCount - 1)) / TabsCount)
  else
    Result := Trunc((Width + 5 * (TabsCount - 1)) / TabsCount);
end;

procedure TxColorTabSet.SetHighlightColor(AHighlightColor: TColor);
begin
  if AHighlightColor <> FHighlightColor then
  begin
    FHighlightColor := AHighlightColor;
    Invalidate;
  end;
end;

function TxColorTabSet.GetTabText(ATab: Integer): String;
var
  B, E, I: Integer;
begin
  Assert(ATab >= 0);

  if ATab >= TabsCount then
  begin
    Result := '';
    exit;
  end;
//  Assert(ATab < TabsCount);

  B := 1;
  E := 0;
  for I := 1 to Length(FTabs) do
    if FTabs[I] = ';' then
    begin
      B := E + 1;
      E := I;
      Dec(ATab);
      if ATab < 0 then
        break;
    end;

  if ATab >= 0 then
  begin
    B := E + 1;
    E := Length(FTabs) + 1;
  end;

  Result := Copy(FTabs, B, E - B);
end;

procedure TxColorTabSet.SetOrientation(const Value: TxctsOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    Invalidate;
  end;
end;

procedure TxColorTabSet.SetNotebook(const Value: TNotebook);
begin
  FNotebook := Value;
end;

procedure TxColorTabSet.DoOnPageChanged(Sender: TObject);
begin
  if Sender <> FNotebook then
    exit;

  if Flag then
    ActiveIndex := FNotebook.PageIndex;
end;


function TxColorTabSet.GetColorsArr(const Index: Integer): TColor;
begin
  Result := ColorsArray[Index];
end;

procedure TxColorTabSet.SetColorsArr(const Index: Integer;
  const Value: TColor);
begin
  ColorsArray[Index] := Value;
  SyncTabColors;
  Invalidate;
end;

procedure TxColorTabSet.SyncTabColors;
var
  I: Integer;
begin
  FTabColors := '';
  for I := Low(ColorsArray) to High(ColorsArray) do
  begin
    FTabColors := FTabColors + ColorToString(ColorsArray[I]);
    if I <> High(ColorsArray) then
      FTabColors := FTabColors + ';';
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TxColorTabSet]);
end;

procedure TxColorTabSet.SetHighlightIndex(const Value: Integer);
begin
  if FHighlightIndex <> Value then
  begin
    FHighlightIndex := Value;
//    Paint;
  end;
end;

procedure TxColorTabSet.WMMouseMove(var Message: TWMMouseMove);
var
  OldHighlightIndex: Integer;
begin
  OldHighlightIndex := FHighlightIndex;

  with Message do
    if (YPos < 0) or (YPos >= Height) or (XPos < 0) or (XPos >= Width) then
    begin
      MouseCapture := False;
      FHighlightIndex := -1;
    end else
    begin
      MouseCapture := True;
      if FOrientation = ctsoRight then
        FHighlightIndex := Trunc((YPos / Height) * TabsCount)
      else
        FHighlightIndex := Trunc((XPos / Width) * TabsCount);
    end;

  if OldHighlightIndex <> FHighlightIndex then
  begin
    if OldHighlightIndex >= 0 then
      DrawText(OldHighlightIndex, GetTabText(OldHighlightIndex));
    if FHighlightIndex >= 0 then
    DrawText(FHighlightIndex, GetTabText(FHighlightIndex));
  end;
end;

procedure TxColorTabSet.SetDisabledIndex(const Value: Integer);
begin
  if FDisabledIndex <> Value then
  begin
    FDisabledIndex := Value;
    Invalidate;
  end;
end;

procedure TxColorTabSet.SetDisabledIndex2(const Value: Integer);
begin
  if FDisabledIndex2 <> Value then
  begin
    FDisabledIndex2 := Value;
    Invalidate;
  end;
end;

procedure TxColorTabSet.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TxColorTabSet.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TxColorTabSet.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TxColorTabSet.CMWantSpecialKey(var Message: TCMDialogKey);
const
  B: Boolean = True;
var
  I: Integer;
begin
  B := not B;

  if Message.CharCode = VK_LEFT then
  begin
    if B and (Message.KeyData = 0) then
    begin
      I := FActiveIndex;
      repeat
        if I > 0 then
          I := I - 1
        else
          I := TabsCount - 1;
      until I <> FDisabledIndex;
      ActiveIndex := I;
    end;
    Message.Result := 1;
  end
  else if Message.CharCode = VK_RIGHT then
  begin
    if B and (Message.KeyData = 0) then
    begin
      I := FActiveIndex;
      repeat
        if I < TabsCount - 1 then
          I := I + 1
        else
          I := 0;
      until I <> FDisabledIndex;
      ActiveIndex := I;
    end;
    Message.Result := 1;
  end
  else
    inherited;
end;

procedure TxColorTabSet.SetAllColors(const AColor: TColor);
var
  I: Integer;
begin
  for I := 0 to TabsCount - 1 do
  begin
    ColorsArray[I] := AColor;
  end;
  SyncTabColors;
  Invalidate;
end;

end.
