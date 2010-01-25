
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    ptydesk.pas

  Abstract

    Pretty looking desktop.

  Author

    Andrei Kireev (01-Jul-96)

  Contact address

  Revisions history

    1.00    01-Jul-96    andreik    Initial version.
    1.01    15-Jul-96    andreik    Image added.
    1.02    16-Jul-96    andreik    Minor change.
    1.03    23-Sep-96    andreik    Minor change.
    1.04    07-Dec-96    andreik    Fixed minor bug. Popup menu added.
    1.05    24-Dec-96    andreik    Wallpaper property added.
    1.06    20-Oct-97    andreik    Ported to Delphi32.

  Wishes

    Instead of two menu items show/hide logo use one,
    checked or unchecked.

    Save bitmap name between sessions.

--}

unit xPtyDesk;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls;

const
  DefShadowColor = clBlack;
  DefHighlightColor = $C0C0C0;
  DefAlign = alClient;
  DefColor = clTeal;
  DefBorderWidth = 5;

type
  TxPrettyDesktop = class(TPanel)
  private
    FImage: TBitmap;
    FShowImage: Boolean;
    FWallpaper: TBitmap;
    FShadowColor, FHighlightColor: TColor;
    FWallPaperFile: String;

    PopupMenu: TPopupMenu;
    ShowLogoItem: TMenuItem;

    procedure SetImage(AnImage: TBitmap);
    procedure SetShowImage(AShowImage: Boolean);
    procedure SetWallPaper(AWallPaper: TBitmap);
    procedure SetShadowColor(AShadowColor: TColor);
    procedure SetHighlightColor(AHighlightColor: TColor);
    procedure SetWallPaperFile(const AWallPaperFile: String);

    procedure CalculateMasks;
    procedure PaintImage;

    procedure DoOnColor(Sender: TObject);
    procedure DoOnFont(Sender: TObject);
    procedure DoOnWallpaper(Sender: TObject);
    procedure DoOnShowImage(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;

    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property WallPaperFile: String read FWallPaperFile write SetWallPaperFile;

  published
    property Align default DefAlign;
    property Alignment stored False;
    property BevelWidth stored False;
    property BevelInner stored False;
    property BevelOuter stored False;
    property Caption stored False;
    property Ctl3D stored False;
    property Color default DefColor;
    property BorderWidth default DefBorderWidth;

    property ShowImage: Boolean read FShowImage write SetShowImage
      default True;
    property WallPaper: TBitmap read FWallPaper write SetWallPaper;
    property ShadowColor: TColor read FShadowColor write SetShadowColor
      default DefShadowColor;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor
      default DefHighlightColor;
    property Image: TBitmap read FImage write SetImage;
  end;

procedure Register;

implementation


uses
  xRGBDlg;

{ TxPrettyDesktop ----------------------------------------}

constructor TxPrettyDesktop.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Align := DefAlign;
  Color := DefColor;
  BorderWidth := DefBorderWidth;

  FImage := TBitmap.Create;
  FShowImage := True;
  FWallPaper := TBitmap.Create;
  FShadowColor := DefShadowColor;
  FHighlightColor := DefHighlightColor;
  FWallPaperFile := '';

  ShowLogoItem := NewItem('Показать заставку', 0, False, True,
    DoOnShowImage, 0, 'ShowLogoItem');
  PopupMenu := NewPopupMenu(Self, 'PopupMenu', paLeft, False,
    [NewItem('Цвет...', 0, False, True, DoOnColor, 0, 'ColorItem'),
     NewItem('Шрифт...', 0, False, True, DoOnFont, 0, 'FontItem'),
     NewItem('Обои...', 0, False, True, DoOnWallPaper, 0, 'WallPaperItem'),
     NewLine,
     ShowLogoItem]);
end;

destructor TxPrettyDesktop.Destroy;
begin
  FImage.Free;
  FWallPaper.Free;
  PopupMenu.Free;
  inherited Destroy;
end;

procedure TxPrettyDesktop.Loaded;
begin
  inherited Loaded;
  ShowLogoItem.Checked := ShowImage;
end;

procedure TxPrettyDesktop.Paint;
var
  K, I: Integer;
begin
  with Canvas do
  begin
    if FWallPaper.Empty then
    begin
      Brush.Color := Color;
      Brush.Style := bsSolid;
      FillRect(GetClientRect);
    end else
    begin
      for I := 0 to (Width div FWallPaper.Width) do
        for K := 0 to (Height div FWallPaper.Height) do
          Draw(I * FWallPaper.Width, K * FWallPaper.Height, FWallPaper);
    end;

    Pen.Style := psSolid;
    Pen.Color := ShadowColor;
    Pen.Width := 1;
    Brush.Style := bsClear;

    { draw frame }
    Rectangle(0, 0, Width, Height);

    { draw bevels }
    PolyLine([
      Point(4, Height - 14),
      Point(4, 4),
      Point(Width - 13, 4)]);

    Pen.Color := HighlightColor;
    PolyLine([
      Point(13, Height - 4),
      Point(Width - 4, Height - 4),
      Point(Width - 4, 12)]);

    PolyLine([
      Point(1, Height - 17),
      Point(1, 1),
      Point(Width - 16, 1)]);

    { draw corners }

    { left-top }
    Pen.Color := ShadowColor;
    PolyLine([
      Point(1, 15),
      Point(5, 11),
      Point(5, 5),
      Point(11, 5),
      Point(16, 0)]);
    Pen.Color := clYellow;
    PolyLine([
      Point(1, 14),
      Point(1, 1),
      Point(15, 1)]);
    Pen.Color := clOlive;
    PolyLine([
      Point(2, 13),
      Point(2, 2),
      Point(14, 2)]);
    PolyLine([
      Point(3, 12),
      Point(3, 3),
      Point(13, 3)]);
    PolyLine([
      Point(4, 11),
      Point(4, 4),
      Point(12, 4)]);

    { right-top }
    Pen.Color := ShadowColor;
    PolyLine([
      Point(Width - 16, 1),
      Point(Width - 12, 5),
      Point(Width - 5, 5),
      Point(Width - 5, 11),
      Point(Width, 16)]);
    Pen.Color := clYellow;
    PolyLine([
      Point(Width - 16, 1),
      Point(Width - 1, 1)]);
    PolyLine([
      Point(Width - 5, 5),
      Point(Width - 5, 12)]);
    Pen.Color := clOlive;
    PolyLine([
      Point(Width - 14, 2),
      Point(Width - 2, 2),
      Point(Width - 2, 14)]);
    PolyLine([
      Point(Width - 13, 3),
      Point(Width - 3, 3),
      Point(Width - 3, 13)]);
    PolyLine([
      Point(Width - 12, 4),
      Point(Width - 4, 4),
      Point(Width - 4, 12)]);

    { right-bottom }
    Pen.Color := clYellow;
    PolyLine([
      Point(Width - 2, Height - 15),
      Point(Width - 5, Height - 12),
      Point(Width - 5, Height - 5),
      Point(Width - 11, Height - 5),
      Point(Width - 16, Height)]);
    Pen.Color := clOlive;
    PolyLine([
      Point(Width - 2, Height - 14),
      Point(Width - 2, Height - 2),
      Point(Width - 14, Height - 2)]);
    PolyLine([
      Point(Width - 3, Height - 13),
      Point(Width - 3, Height - 3),
      Point(Width - 13, Height - 3)]);
    PolyLine([
      Point(Width - 4, Height - 12),
      Point(Width - 4, Height - 4),
      Point(Width - 12, Height - 4)]);

    { left-bottom }
    Pen.Color := ShadowColor;
    PolyLine([
      Point(1, Height - 16),
      Point(5, Height - 12),
      Point(5, Height - 5),
      Point(11, Height - 5),
      Point(16, Height)]);
    Pen.Color := clYellow;
    PolyLine([
      Point(1, Height - 2),
      Point(1, Height - 16),
      Point(5, Height - 12)]);
    PolyLine([
      Point(6, Height - 5),
      Point(11, Height - 5)]);
    Pen.Color := clOlive;
    PolyLine([
      Point(2, Height - 14),
      Point(2, Height - 2),
      Point(14, Height - 2)]);
    PolyLine([
      Point(3, Height - 13),
      Point(3, Height - 3),
      Point(13, Height - 3)]);
    PolyLine([
      Point(4, Height - 12),
      Point(4, Height - 4),
      Point(12, Height - 4)]);
  end; { with Canvas }

  PaintImage;
end;

procedure TxPrettyDesktop.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if Button = mbRight then
  begin
    P := Self.ClientToScreen(Point(X, Y));
    PopupMenu.Popup(P.X, P.Y);
  end;
end;

procedure TxPrettyDesktop.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TxPrettyDesktop.SetImage(AnImage: TBitmap);
var
  R: TRect;
begin
  if Assigned(AnImage) and (not AnImage.Empty)
    and ((FImage.Width <> AnImage.Width) or (FImage.Height <> AnImage.Height)) then
      { preserve from second assignment }
  begin
    FImage.Width := AnImage.Width;
    FImage.Height := AnImage.Height * 3;

    { copy image }
    R := Rect(0, 0, AnImage.Width, AnImage.Height);
    FImage.Canvas.CopyRect(R, AnImage.Canvas, R);
    CalculateMasks;
  end else
    FImage.Assign(AnImage);

  Invalidate;
end;

procedure TxPrettyDesktop.SetShowImage(AShowImage: Boolean);
begin
  if AShowImage <> FShowImage then
  begin
    FShowImage := AShowImage;
    Invalidate;
  end;
end;

procedure TxPrettyDesktop.SetWallPaper(AWallPaper: TBitmap);
begin
  FWallPaper.Assign(AWallPaper);
  Invalidate;
end;

procedure TxPrettyDesktop.SetShadowColor(AShadowColor: TColor);
begin
  if FShadowColor <> AShadowColor then
  begin
    FShadowColor := AShadowColor;
    Invalidate;
  end;
end;

procedure TxPrettyDesktop.SetHighlightColor(AHighlightColor: TColor);
begin
  if FHighlightColor <> AHighlightColor then
  begin
    FHighlightColor := AHighlightColor;
    Invalidate;
  end;
end;

procedure TxPrettyDesktop.SetWallPaperFile(const AWallPaperFile: String);
begin
  FWallPaperFile := AWallPaperFile;
  if FWallPaperFile > '' then
    WallPaper.LoadFromFile(FWallPaperFile)
  else
    WallPaper.Assign(nil);
  Invalidate;
end;

procedure TxPrettyDesktop.CalculateMasks;
var
  X, Y, W, H: Integer;
  R, R2: TRect;
begin
  if not FImage.Empty then
  begin
    W := FImage.Width;
    H := FImage.Height div 3;
    R := Rect(0, 0, W, H);

    { making AND mask }
    R2 := Rect(0, H, W, H * 2);
    FImage.Canvas.CopyRect(R2, FImage.Canvas, R);
    for X := 0 to FImage.Width - 1 do
      for Y := H to H * 2 - 1 do
        if FImage.Canvas.Pixels[X, Y] = clBlack then { Black is transparent }
          FImage.Canvas.Pixels[X, Y] := clWhite
        else
          FImage.Canvas.Pixels[X, Y] := clBlack;

    { making OR mask }
    R2 := Rect(0, H * 2, W, H * 3);
    FImage.Canvas.Brush.Color := clBlack;
    FImage.Canvas.Brush.Style := bsSolid;
    FImage.Canvas.BrushCopy(R2, FImage, R, clBlack);
  end;
end;

procedure TxPrettyDesktop.PaintImage;
var
  Bm: TBitmap;
  R1, R2: TRect;
  X, Y, H, W, FullW, FullH: Integer;
begin
  if FShowImage and (not FImage.Empty) then
  begin
    W := FImage.Width;
    H := FImage.Height div 3;
    FullW := W + 3; { shadow depth is 3 }
    FullH := H + 3;
    X := (Width - FullW) div 2;
    Y := (Height - FullH) div 2;

    Bm := TBitmap.Create;
    try
      Bm.Width := W;
      Bm.Height := H;
      R1 := Rect(X, Y, X + W, Y + H);
      R2 := Rect(0, 0, W, H);

      BitBlt(Canvas.Handle, X + 3, Y + 3,
        W, H, FImage.Canvas.Handle, 0, H, SRCAND);

      Bm.Canvas.CopyRect(R2, Canvas, R1);
      BitBlt(Bm.Canvas.Handle, 0, 0, W, H, FImage.Canvas.Handle, 0, H, SRCAND);
      BitBlt(Bm.Canvas.Handle, 0, 0, W, H, FImage.Canvas.Handle, 0, H * 2, SRCPAINT);
      Canvas.CopyRect(R1, Bm.Canvas, R2);
    finally
      Bm.Free;
    end;
  end;
end;

procedure TxPrettyDesktop.DoOnColor(Sender: TObject);
var
  xRGBDialog: TxRGBDialog;
begin
  xRGBDialog := TxRGBDialog.Create(Self);
  try
    { must be changed in future versions }
    xRGBDialog.Font.Name := 'Arial';
    xRGBDialog.Font.Style := [];
    xRGBDialog.Font.Size := 8;

    xRGBDialog.Color := Self.Color;

    if xRGBDialog.Execute then
    begin
      Self.Color := xRGBDialog.Color;
      WallPaperFile := '';  { clear bitmap }
    end;
  finally
    xRGBDialog.Free;
  end;
end;

procedure TxPrettyDesktop.DoOnFont(Sender: TObject);
var
  FontDialog: TFontDialog;
begin
  FontDialog := TFontDialog.Create(Self);
  try
    FontDialog.Font.Assign(Self.Font);
    if FontDialog.Execute then
      Self.Font := FontDialog.Font;
  finally
    FontDialog.Free;
  end;
end;

procedure TxPrettyDesktop.DoOnWallpaper(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(Self);
  try
    OpenDialog.DefaultExt := 'bmp';
    if FWallPaperFile > '' then
    begin
      OpenDialog.FileName := FWallPaperFile;
      OpenDialog.InitialDir := ExtractFilePath(FWallPaperFile);
    end else
      OpenDialog.FileName := '*.bmp';
    OpenDialog.Filter := 'Bitmap files|*.bmp';
    OpenDialog.Options := [ofFileMustExist, ofHideReadOnly];
    if OpenDialog.Execute then
      WallPaperFile := OpenDialog.FileName;
  finally
  end;
end;

procedure TxPrettyDesktop.DoOnShowImage(Sender: TObject);
begin
  ShowImage := not ShowImage;
  ShowLogoItem.Checked := ShowImage;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsVC', [TxPrettyDesktop]);
end;

end.
