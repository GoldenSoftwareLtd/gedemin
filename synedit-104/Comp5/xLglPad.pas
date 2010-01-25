
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xlglpad.pas

  Abstract

    Legal Pad

  Author

    Anton Smirnov (20-may-97)

  Contact address

  Revisions history

    1.00    20-may-97    sai        Initial version.
    1.01    24-may-97    andreik    Little changes.
    1.02     2-jun-97    sai        Add function SetByIndex and GetByIndex.
    1.03    21-jun-97    andreik    Fixed bug.
    1.04    23-jun-97    sai        Mark by index routines added.
    1.05    26-jun-97    andreik    Additional.
    1.06    27-jun-97    andreik    With corner property added.
    1.07    27-jun-97    andreik    Add Secod red line.
    1.08    10-oct-97    andreik    Added some useful routines.
    1.09    19-nov-97    anton      Ported to 32bit Delphi.
    1.10    23-dec-97    anton      CornerIcon removed 'cuz of problems
                                    with application icon.
    1.11    24-dec-97    andreik    PopupMenu property added.
    1.12    01-oct-98    andreik    AddSecondByIndex added.

--}

unit xLglPad;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TClickLineEvent = procedure(Sender: TObject; LineIndex: Integer;
                           var LabelMark: Boolean) of object;

type
  TxLegalPad = class(TCustomControl)
  private
    FMarkLabel, FItems, OldItems: TStringList;
    FLineHeight, FRedFieldWidth, FRedSecondFieldWidth, FTopFieldHeight: Integer;
    FColor, FColorVertLine, FColorHorzLine: TColor;
    FMarkBitmap, FWallPaper: TBitmap;
    FClickLine: TClickLineEvent;
    FTitle: String;
    FFontTitle: TFont;
    FWithCorner: Boolean;
    FHighlightIndex: Integer;

{    CornerIcon: TIcon;}
    procedure MakeMarkLabel;
    procedure LoadResurceBitmap;

    procedure SetMarkLabel(AMarkLabel: TStringList);
    procedure SetItems(AnItems: TStringList);
    procedure SetLineHeight(ALineHeight: Integer);
    procedure SetRedFieldWidth(ARedFieldWidth: Integer);
    procedure SetRedSecondFieldWidth(ARedSecondFieldWidth: Integer);
    procedure SetTopFieldHeight(ATopFieldHeight: Integer);
    procedure SetColor(AColor: TColor);
    procedure SetMarkBitmap(AMarkBitmap: TBitmap);
    procedure SetTitle(ATitle: String);
    procedure SetFontTitle(AFontTitle: TFont);
    procedure SetWallPaper(AWallPaper: TBitmap);
    procedure SetColorVertLine(AColorVertLine: TColor);
    procedure SetColorHorzLine(AColorHorzLine: TColor);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;

    procedure DrawMark(I: Integer);
    procedure ItemsChange(Sender: TObject);
    procedure SetHighlightIndex(const Value: Integer);
    procedure DrawText;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;

    function FullMarks: Boolean;
    procedure SetByIndex(Index: Integer; St: String);
    function GetByIndex(Index: Integer): String;
    procedure SetMarkByIndex(Index: Integer; Value: Boolean);
    function GetMarkByIndex(Index: Integer): Boolean;
    procedure SetSecondByIndex(const Index: Integer; St: String);
    procedure AddSecondByIndex(const Index: Integer; const St: String);
    function GetSecondByIndex(const Index: Integer): String;

    property HighlightIndex: Integer read FHighlightIndex write SetHighlightIndex;
    
  published
    property Font;
    property Items: TStringList read FItems write SetItems;
    property MarkLabel: TStringList read FMarkLabel write SetMarkLabel;
    property LineHeight: Integer read FLineHeight write SetLineHeight;
    property RedFieldWidth: Integer read FRedFieldWidth write SetRedFieldWidth;
    property TopFieldHeight: Integer read FTopFieldHeight write SetTopFieldHeight;
    property Color: TColor read FColor write SetColor;
    property MarkBitmap: TBitmap read FMarkBitmap write SetMarkBitmap;
    property OnClickLine: TClickLineEvent read FClickLine write FClickLine;
    property Align;
    property Title: String read FTitle write SetTitle;
    property FontTitle: TFont read FFontTitle write SetFontTitle;
    property WallPaper: TBitmap read FWallPaper write SetWallPaper;
    property ColorVertLine: TColor read FColorVertLine write SetColorVertLine;
    property ColorHorzLine: TColor read FColorHorzLine write SetColorHorzLine;
    property WithCorner: Boolean read FWithCorner write FWithCorner default True;
    property RedSecondFieldWidth: Integer read FRedSecondFieldWidth write
      SetRedSecondFieldWidth;

    property PopupMenu;
    property TabOrder;
    property TabStop;
  end;

  ExLegalPadError = class(Exception);

procedure Register;

implementation

{$R XLGLPAD.RES} 

uses
  Rect;

const
  WhiteSpace = ','; {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

function StripStr(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

constructor TxLegalPad.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FItems := TStringList.Create;
  OldItems := TStringList.Create;
  FItems.OnChange := ItemsChange;
  FMarkLabel := TStringList.Create;
  FLineHeight := 20;
  FRedFieldWidth := 40;
  FRedSecondFieldWidth := 100;
  FTopFieldHeight := 30;
  FColor := clYellow;
  FMarkBitmap := TBitmap.Create;
  FWallPaper := TBitmap.Create;
  FFontTitle := TFont.Create;
  FFontTitle.Size := 14;
  FFontTitle.Color := clGreen;
  Font.Color := clNavy;
  FColorVertLine := clRed;
  FColorHorzLine := clBlue;
  FWithCorner := True;
  LoadResurceBitmap;
{  CornerIcon := TIcon.Create;
  CornerIcon.Handle := LoadIcon(hInstance, 'LegalPad_IconCorner');}
{  if CornerIcon.Handle = 0 then
    Exception.Create('Can''t load resource icon');}
  Width := 200;
  Height := 200;
  FHighlightIndex := -1;
end;

destructor TxLegalPad.Destroy;
begin
  FItems.Free;
  OldItems.Free;
  FMarkLabel.Free;
  FMarkBitmap.Free;
{  CornerIcon.Free;}
  FFontTitle.Free;
  FWallPaper.Free;
  inherited Destroy;
end;

procedure TxLegalPad.DrawMark(I: Integer);
var
  BMP1, BMP2: TBitmap;
  Y: Integer;
begin
  Y := FTopFieldHeight + I * FLineHeight;
  BMP1 := TBitmap.Create;
  BMP2 := TBitmap.Create;
  BMP1.Width := FMarkBitmap.Width;
  BMP1.Height := FMarkBitmap.Height div 2;
  BMP2.Width := FMarkBitmap.Width;
  BMP2.Height := FMarkBitmap.Height div 2;
  try
    BMP1.Canvas.CopyRect(RectSet(0, 0, BMP1.Width, BMP1.Height),
                       FMarkBitmap.Canvas,
                       RectSet(0, 0, BMP1.Width, FMarkBitmap.Height div 2));
    BMP2.Canvas.CopyRect(RectSet(0, 0, BMP2.Width, BMP2.Height),
                       FMarkBitmap.Canvas,
                       RectSet(0, FMarkBitmap.Height div 2, BMP2.Width,
                       FMarkBitmap.Height));

    BitBlt(Canvas.Handle, FRedFieldWidth div 2 - BMP1.Width div 2,
                          Y + FLineHeight div 2 - BMP1.Height div 2,
                          FRedFieldWidth div 2 + BMP1.Width div 2,
                          Y + FLineHeight div 2 + BMP1.Height div 2,
           Bmp1.Canvas.Handle, 0, 0, SrcAnd);
    BitBlt(Canvas.Handle, FRedFieldWidth div 2 - BMP1.Width div 2,
                          Y + FLineHeight div 2 - BMP1.Height div 2,
                          FRedFieldWidth div 2 + BMP1.Width div 2,
                          Y + FLineHeight div 2 + BMP1.Height div 2,
           Bmp2.Canvas.Handle, 0, 0, SrcPaint);

  finally
    BMP1.Free;
    BMP2.Free;
  end;

end;

procedure TxLegalPad.Paint;
var
  I, T: Integer;
begin
  Canvas.Font.Assign(Font);
  with Canvas do
  begin
    Pen.Color := clBlack;
    Pen.Width := 1;
    Brush.Color := FColor;
    if not FWallPaper.Empty then
    begin
      for I := 0 to (Width div FWallPaper.Width) do
        for T := 0 to (Height div FWallPaper.Height) do
          Canvas.CopyRect(RectSet(I * FWallPaper.Width, T * FWallPaper.Height,
            (I + 1) * FWallPaper.Width, (T + 1) * FWallPaper.Height),
            FWallPaper.Canvas,
            RectSet(0, 0, FWallPaper.Width, FWallPaper.Height));
      PolyLine([Point(0, 0), Point(Width - 1, 0), Point(Width - 1, Height - 1),
        Point(0, Height - 1), Point(0, 0)]);
    end else
    begin
      Brush.Style := bsSolid;
      Rectangle(0, 0, Width, Height);
    end;

    //
    DrawText;

    { draw vert lines }
    Pen.Color := FColorVertLine;
    MoveTo(FRedFieldWidth, 1);
    LineTo(FRedFieldWidth, Height - 1);
    MoveTo(FRedFieldWidth + 3, 1);
    LineTo(FRedFieldWidth + 3, Height - 1);
    MoveTo(FRedFieldWidth + 6, 1);
    LineTo(FRedFieldWidth + 6, Height - 1);

    MoveTo(FRedSecondFieldWidth, 1);
    LineTo(FRedSecondFieldWidth, Height - 1);

    Font.Assign(FFontTitle);
    TextOut(FRedFieldWidth + 14,
            FTopFieldHeight div 2 - TextHeight('H') div 2, FTitle);

{    if FWithCorner then
      Canvas.Draw(Width - 32, Height - 32, CornerIcon);}
  end;
end;
procedure TxLegalPad.Repaint;
begin
  Invalidate;
end;

procedure TxLegalPad.LoadResurceBitmap;
begin
  FMarkBitmap.LoadFromResourceName(hInstance, 'LegalPad_MarkLabel');
  if FMarkBitmap.Handle = 0 then
    raise Exception.Create('Can''t load resource bitmap');
end;

procedure TxLegalPad.SetMarkLabel(AMarkLabel: TStringList);
var
  I: Integer;
begin
  if AMarkLabel.Count <> FItems.Count then
    raise ExLegalPadError.Create('MarkLabel count <> Items count')
  else begin
    for I := 0 to AMarkLabel.Count - 1 do
      if not ((AMarkLabel.Strings[I] = 'V') or (AMarkLabel.Strings[I] = '')) then
        raise ExLegalPadError.Create('Not correct');
    FMarkLabel.Assign(AMarkLabel);
  end;
end;

procedure TxLegalPad.MakeMarkLabel;
var
  L: TStringList;
  I: Integer;
begin
  L := TStringList.Create;
  try
    for I := 0 to FItems.Count - 1 do
      if (FMarkLabel.Count > I) and (FMarkLabel.Strings[I] = 'V') then
        L.Add('V')
      else
        L.Add('');
    FMarkLabel.Assign(L);
  finally
    L.Free;
  end;
  Repaint;
end;

{$HINTS OFF}
procedure TxLegalPad.ItemsChange(Sender: TObject);
var
  I, T, E: Integer;
  S: String;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I] <> '' then
    begin
      if Pos(WhiteSpace, FItems[I]) <> 0 then
      begin
        S := Copy(FItems[I], 0, Pos(WhiteSpace, FItems[I]) - 1);

        Val(S, T, E);
        if E <> 0 then
        begin
          FItems.Assign(OldItems);
          raise ExLegalPadError.Create('Error format');
        end
      end
      else
      begin
        FItems.Assign(OldItems);
        raise ExLegalPadError.Create('Error format');
      end;
    end;
  OldItems.Assign(FItems);
  MakeMarkLabel;
  Repaint;
end;
{$HINTS ON}


procedure TxLegalPad.SetItems(AnItems: TStringList);
begin
  FItems.Assign(AnItems);
  Repaint;
end;

procedure TxLegalPad.SetLineHeight(ALineHeight: Integer);
begin
  if ALineHeight <> FLineHeight then
  begin
    FLineHeight := ALineHeight;
    Repaint;
  end;
end;

procedure TxLegalPad.SetRedFieldWidth(ARedFieldWidth: Integer);
begin
  if ARedFieldWidth <> FRedFieldWidth then
  begin
    FRedFieldWidth := ARedFieldWidth;
    Repaint;
  end;
end;

procedure TxLegalPad.SetRedSecondFieldWidth(ARedSecondFieldWidth: Integer);
begin
  FRedSecondFieldWidth := ARedSecondFieldWidth;
  Repaint;
end;

procedure TxLegalPad.SetTopFieldHeight(ATopFieldHeight: Integer);
begin
  if ATopFieldHeight <> FTopFieldHeight then
  begin
    FTopFieldHeight := ATopFieldHeight;
    Repaint;
  end;
end;

procedure TxLegalPad.SetColor(AColor: TColor);
begin
  FColor := AColor;
  Repaint;
end;

procedure TxLegalPad.SetMarkBitmap(AMarkBitmap: TBitmap);
begin
  FMarkBitmap.Assign(AMarkBitmap);
  if FMarkBitmap.Empty then
    LoadResurceBitmap;
  Repaint;
end;

procedure TxLegalPad.SetWallPaper(AWallPaper: TBitmap);
begin
  FWallPaper.Assign(AWallPaper);
  Repaint;
end;

procedure TxLegalPad.WMLButtonDown(var Message: TWMLButtonDown);
var
  Number, NN, E: Integer;
  LabelMark: Boolean;
  N: Double;
  S: String;
begin
  inherited;
  with Message do
  begin
    N := (YPos - FTopFieldHeight) / FLineHeight;
    Number := Trunc(N);
    if (Number < FItems.Count) and Assigned(FClickLine) and (Number >= 0) then
    begin
      LabelMark := False;
      S := Copy(FItems[Number], 0, System.Pos(WhiteSpace, FItems[Number]) - 1);
      if S <> '' then
      begin
        Val(S, NN, E);
        FClickLine(Self, NN, LabelMark);
        if LabelMark then
        begin
          FMarkLabel.Strings[Number] := 'V';
          DrawMark(Number);
        end
        else
        begin
          FMarkLabel.Strings[Number] := '';
          Repaint;
        end;
      end
    end;
  end;
end;

procedure TxLegalPad.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TxLegalPad.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

function TxLegalPad.FullMarks: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to MarkLabel.Count - 1 do
    if MarkLabel.Strings[I] <> 'V' then
    begin
      Result := False;
      Break;
    end;
end;

procedure TxLegalPad.SetTitle(ATitle: String);
begin
  FTitle := ATitle;
  Repaint;
end;

procedure TxLegalPad.SetFontTitle(AFontTitle: TFont);
begin
  FFontTitle.Assign(AFontTitle);
  Repaint;
end;

procedure TxLegalPad.SetColorVertLine(AColorVertLine: TColor);
begin
  FColorVertLine := AColorVertLine;
  Repaint;
end;

procedure TxLegalPad.SetColorHorzLine(AColorHorzLine: TColor);
begin
  FColorHorzLine := AColorHorzLine;
  Repaint;
end;

procedure TxLegalPad.SetByIndex(Index: Integer; St: String);
var
  I, J, Code: Integer;
begin
  J := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    Val(StripStr(Copy(FItems[I], 1,
      Pos(',', FItems[I]) - 1)), J, Code);
    if (Code = 0) and (J = Index) then
    begin
      FItems[I] := Format('%d,%s', [Index, St]);
      break;
    end;
  end;

  if J = Index then
    Invalidate
  else
    raise Exception.Create('Index not found');

{
  Str(Index, S);
  S := S + ',';
  Res := False;
  for I := 0 to FItems.Count - 1 do
    if Pos(S, FItems[I]) <> 0 then
    begin
      SS := S + St;
      FItems[I] := SS;
      Res := True;
    end;
  if Res then
    Repaint
  else
    raise Exception.Create('Index not found.');
}
end;

function TxLegalPad.GetByIndex(Index: Integer): String;
var
  I, J, Code: Integer;
begin
  J := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    Val(StripStr(Copy(FItems[I], 1,
      Pos(',', FItems[I]) - 1)), J, Code);

    if (Code = 0) and (J = Index) then
    begin
      Result := Copy(FItems[I], Pos(',', FItems[I]) + 1, 255);
      break;
    end;
  end;

  if J <> Index then
    raise Exception.Create('Index not found');


{
  Str(Index, S);
  S := S + ',';
  Result := '';
  for I := 0 to FItems.Count - 1 do
    if Pos(S, FItems[I]) <> 0 then
      Result := Copy(FItems[I],
        Pos(S, FItems[I]) + Length(S), Length(FItems[I]));
}
end;

procedure TxLegalPad.SetMarkByIndex(Index: Integer; Value: Boolean);
var
  I, J, Code: Integer;
begin
  J := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    Val(StripStr(Copy(FItems[I], 1,
      Pos(',', FItems[I]) - 1)), J, Code);
    if (Code = 0) and (J = Index) then
    begin
      if Value then
        FMarkLabel.Strings[I] := 'V'
      else
        FMarkLabel.Strings[I] := '';
      break;
    end;
  end;
  if J = Index then
    Invalidate
  else
    raise Exception.Create('Index not found');
end;

function TxLegalPad.GetMarkByIndex(Index: Integer): Boolean;
var
  I, J, Code: Integer;
begin
  J := -1;
  Result := False;
  for I := 0 to FItems.Count - 1 do
  begin
    Val(StripStr(Copy(FItems[I], 1,
      Pos(',', FItems[I]) - 1)), J, Code);
    if (Code = 0) and (J = Index) then
    begin
      Result := FMarkLabel.Strings[I] = 'V';
      break;
    end;
  end;
  if J = Index then
    Invalidate
  else
    raise Exception.Create('Index not found');
end;

procedure TxLegalPad.SetSecondByIndex(const Index: Integer; St: String);
begin
  St := Copy(GetByIndex(Index), 1,
    Pos('|', GetByIndex(Index))) + St;

  SetByIndex(Index, St);
end;

function TxLegalPad.GetSecondByIndex(const Index: Integer): String;
begin
  Result := Copy(GetByIndex(Index), Pos('|', GetByIndex(Index)) + 1, 255);
end;

procedure TxLegalPad.WMMouseMove(var Message: TWMMouseMove);
begin
  with Message do
    if (YPos < 0) or (YPos >= Height) or (XPos < 0) or (XPos >= Width) then
    begin
      MouseCapture := False;
      HighlightIndex := -1;
    end else
    begin
      MouseCapture := True;
      HighlightIndex := Trunc((YPos - FTopFieldHeight) / FLineHeight);
    end;
end;

procedure TxLegalPad.SetHighlightIndex(const Value: Integer);
begin
  if FHighlightIndex <> Value then
  begin
    FHighlightIndex := Value;
    DrawText;
  end;
end;

procedure TxLegalPad.DrawText;
var
  I, Y: Integer;
  S: String;
begin
  Canvas.Font.Assign(Font);
  
  with Canvas do
  begin
    { draw horz lines }
    I := 0;
    Y := FTopFieldHeight;
    Pen.Color := FColorHorzLine;
    Brush.Style := bsClear;
    while (Y < Height) do
    begin
      //
      MoveTo(1, Y);
      LineTo(Width - 1, Y);

      if I < FItems.Count then
      begin
        S := Copy(FItems[I], Pos(WhiteSpace, FItems[I]) + Length(WhiteSpace), Length(FItems[I]));

        if I = FHighlightIndex then
          Canvas.Font.Color := clBlue
        else
          Canvas.Font.Color := clBlack;

        if CompareText(Copy(S, 1, 2), '/b') = 0 then
        begin
          Delete(S, 1, 2);
          Canvas.Font.Style := Canvas.Font.Style + [fsBold]
        end else
          Canvas.Font.Style := Canvas.Font.Style - [fsBold];

        if Pos('|', S) <> 0 then
        begin
          TextOut(FRedFieldWidth + 14, Y + FLineHeight div 2 - TextHeight('H') div 2, Copy(S, 0, Pos('|', S) - 1));
          Canvas.Font.Style := Canvas.Font.Style - [fsBold];
          TextOut(FRedSecondFieldWidth + 2, Y + FLineHeight div 2 - TextHeight('H') div 2, Copy(S, Pos('|', S) + 1, Length(S)));
        end
        else
          TextOut(FRedFieldWidth + 14, Y + FLineHeight div 2 - TextHeight('H') div 2, S);

        if MarkLabel.Strings[I] = 'V' then
          DrawMark(I);
      end;
      Inc(I);
      Inc(Y, FLineHeight);
    end;
  end;
end;

procedure TxLegalPad.AddSecondByIndex(const Index: Integer; const St: String);
begin
  SetSecondByIndex(Index, GetSecondByIndex(Index) + St);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-Misc', [TxLegalPad]);
end;

end.
