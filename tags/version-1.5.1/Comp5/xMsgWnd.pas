{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xmsgwnd.pas

  Abstract

    Form for MessageBox.

  Author

    Anton Smirnov (26-mar-97)

  Contact address

  Revisions history

    1.00    3-mar-97    sai    Initial version.
    1.01    27-mar-97
    1.02    27-mar-97   sai    Small change.
    1.03    25-08-97    sai    Small change.
--}

unit Xmsgwnd;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, xBulbBtn;

type
  TSubtitle = (sbApplication, sbUser);
  TIconType = (itIconStop, itQuestion, itExclamation, itIconInformation, itNone);
  TDialogType = (dtAbortRetryIgnore, dtOk, dtOkCancel, dtRetryCancel, dtYesNo,
                 dtYesNoCancel, dtNone);
  TCallout = (clLeft, clRight, clTop, clBottom, clNone);
  TLanguage = (lngEnglish, lngRussian);

const
  Def_FontName = 'Arial';
  Def_FontSize = 8;
  Def_FontStyle = [];
  Def_Gap = 7;
  Def_Color = clBtnFace;
  Def_Width = 100;
  Def_Height = 22;
  CalloutSize = 20;

  DefAutoSize = False;
  DefDefault = False;
  DefCancel = False;

type
  TxMessageForm = class(TForm)
  private
    FShadow: Boolean;
    FShadowDepth, FBorderWidth, FCalloutDisplaysment, FMaxWidth,
    FMinWidth: Integer;
    FFont, FSubtitleFont: TFont;
    FWordWrap: Boolean;
    FColor, FBorderColor: TColor;
    FCaption, FSubtitleName: String;
    FSubtitle: TSubtitle;
    FIconType: TIconType;
    FDialogType: TDialogType;
    FCallout: TCallout;
    FAlignment: TAlignment;
    FLanguage: TLanguage;
    Button1, Button2, Button3: TxBulbButton;
    DrawBMP: Boolean;
    BMPResurce: TBitmap;
    TxtRect: TRect;
    WindowBMP: TBitmap;
    OldOnActivate, OldOnDeActivate: TNotifyEvent;

    procedure SetSubtitleFont(AFont: TFont);
    procedure SetFont(AFont: TFont);
    procedure DoOnActivate(Sender: TObject);
    procedure DoOnDeactivate(Sender: TObject);
    function CountButton(var S1, S2, S3: String; var K1, K2, K3: Integer): Integer;
    function TestButton(var HH, WidthButtons: Integer): Integer;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;

  protected
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;
    procedure DataCalculation(var W, H: Integer);

  published
    property Shadow: Boolean read FShadow write FShadow;
    property ShadowDepth: Integer read FShadowDepth write FShadowDepth;
    property SubtitleFont: TFont read FSubtitleFont write SetSubtitleFont;
    property Color: TColor read FColor write FColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property Caption: String read FCaption write FCaption;
    property SubtitleName: String read FSubtitleName write FSubtitleName;
    property Subtitle: TSubtitle read FSubtitle write FSubtitle;
    property TextFont: TFont read FFont write SetFont;
    property IconType: TIconType read FIconType write FIconType;
    property DialogType: TDialogType read FDialogType write FDialogType;
    property Callout: TCallout read FCallout write FCallout;
    property CalloutDisplaysment: Integer read FCalloutDisplaysment write FCalloutDisplaysment;
    property Alignment: TAlignment read FAlignment write FAlignment;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property Language: TLanguage read FLanguage write FLanguage;
    property xtRext: TRect read TxtRect write TxtRect;

  end;

  ExWindowMessageError= class(Exception);

implementation

{$R XMSGWND.RES}

uses
  Rect
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  , gsMultilingualSupport
  {$ENDIF}
  ;

const
  ButtonName :array [0..1, 0..6] of String[12] =
     (('Abort', 'Cancel', 'Ignore', 'No', 'Ok', 'Retry', 'Yes'),
     ('Прервать', 'Отменить', 'Игнорировать', 'Нет', 'Оk', 'Повторить', 'Да'));

{TxMessageForm -----------------------------------------}

constructor TxMessageForm.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FShadow := True;
  FShadowDepth := 6;
  FCalloutDisplaysment := 20;
  BmpResurce := TBitMap.Create;
  WindowBMP := TBitmap.Create;
  BmpResurce.Handle := LoadBitmap(hInstance, 'XWindowMessage_SHADOW');
  if BmpResurce.Handle = 0 then
    raise ExWindowMessageError.Create('Can''t load resource bitmap');
  FFont := TFont.Create;
  FFont.Name := Def_FontName;
  FFont.Size := Def_FontSize;
  FFont.Style := Def_FontStyle;

  FSubtitleFont := TFont.Create;
  FSubtitleFont.Name := Def_FontName;
  FSubtitleFont.Size := Def_FontSize;
  FSubtitleFont.Style := [fsBold];

  FShadow :=  True;
  FShadowDepth := 4;
  FBorderWidth := 1;
  FWordWrap :=  True;
  FColor := $00C0FFFF;
  FBorderColor := clBlack;
  FCaption := '';
  FSubtitleName := '';
  FSubtitle := sbUser;
  FIconType := itNone;
  FDialogType := dtNone;
  FAlignment := taCenter;
  FMaxWidth := 400;
  FMinWidth := 200;
  FCallout := clNone;
  ControlStyle := [];
  Button1 := TxBulbButton.Create(Self);
  Button1.Parent := Self;
  Button1.Visible := False;
  Button1.AutoSize := True;
  Button1.Color := FColor;
  Button2 := TxBulbButton.Create(Self);
  Button2.Parent := Self;
  Button2.Visible := False;
  Button2.Color := FColor;
  Button2.AutoSize := True;
  Button3 := TxBulbButton.Create(Self);
  Button3.Parent := Self;
  Button3.Visible := False;
  Button3.Color := FColor;
  Button3.AutoSize := True;
  DrawBMP := False;
  Visible := False;
  Left := -100;
  Top := -100;
  Width := 1;
  Height := 1;
  OldOnDeActivate := Application.OnDeActivate;
  OldOnActivate := Application.OnActivate;
  Application.OnDeActivate := DoOnDeActivate;
  Application.OnActivate := DoOnActivate;
end;

destructor TxMessageForm.Destroy;
begin
  Application.OnDeActivate := OldOnDeActivate;
  Application.OnActivate := OldOnActivate;
  FFont.Free;
  FSubtitleFont.Free;
  BMPResurce.Free;
  WindowBMP.Free;
  Button1.Free;
  Button2.Free;
  Button3.Free;
  inherited Destroy;
end;

procedure TxMessageForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style:= WS_POPUP;
    Params.WindowClass.hbrBackground := 0;
      WindowClass.hbrBackground := 0;
  end;
end;

function TxMessageForm.CountButton(var S1, S2, S3: String; var K1, K2, K3: Integer): Integer;
var
  Lng: Integer;
begin
  S1 := '';
  S2 := '';
  S3 := '';
  K1 := -1;
  K2 := -1;
  K3 := -1;
  Result := 0;
  Lng := 1;
  if FLanguage = lngEnglish then
    Lng := 0;
  case FDialogType of
    dtAbortRetryIgnore:
    begin
      K1 := 0;
      K2 := 5;
      K3 := 2;
    end;
    dtOk:
      K1 := 4;
    dtOkCancel:
    begin
      K1 := 4;
      K2 := 1;
    end;
    dtRetryCancel:
    begin
      K1 := 5;
      K2 := 1;
    end;
    dtYesNo:
    begin
      K1 := 6;
      K2 := 3;
    end;
    dtYesNoCancel:
    begin
      K1 := 6;
      K2 := 3;
      K3 := 1;
    end;
  end;
  if K1 > -1 then
  begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
    S1 := TranslateText(ButtonName[Lng, K1]);
  {$ELSE}
    S1 := ButtonName[Lng, K1];
  {$ENDIF}
    Inc(Result);
  end;
  if K2 > -1 then
  begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
    S2 := TranslateText(ButtonName[Lng, K2]);
  {$ELSE}
    S2 := ButtonName[Lng, K2];
  {$ENDIF}

    Inc(Result);
  end;
  if K3 > -1 then
  begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
    S3 := TranslateText(ButtonName[Lng, K3]);
  {$ELSE}
    S3 := ButtonName[Lng, K3];
  {$ENDIF}
    Inc(Result);
  end;
end;

function TxMessageForm.TestButton(var HH, WidthButtons: Integer): Integer;
var
  K1, K2, K3: Integer;
  S1, S2, S3: String;
//  Button: TxBulbButton;

  procedure DoOnClick(xBulb: TxBulbButton; N: Integer);
  begin
    case N of
      0:
        xBulb.ModalResult := mrAbort;
      1:
      begin
        xBulb.ModalResult := mrCancel;
	xBulb.Cancel := True;
      end;
      2:
        xBulb.ModalResult := mrIgnore;
      3:
        xBulb.ModalResult := mrNo;
      4:
      begin
        xBulb.ModalResult := mrOk;
	if FDialogType = dtOk then
	  xBulb.Cancel := True;
      end;
      5:
        xBulb.ModalResult := mrRetry;
      6:
        xBulb.ModalResult := mrYes
    end;
  end;

begin
{  Button := TxBulbButton.Create(Self);
  try
    Button.Parent := Self;
    Button.Font.Assign(FFont);
    Button.AutoSize := True;
    Result := 10;
    CountButton(S1, S2, S3, K1, K2, K3);
    if K1 >= 0 then
    begin
      Button.Caption := S1;
      Inc(Result, 10 + Button.Width);
    end;
    if K2 >= 0 then
    begin
      Button.Caption := S2;
      Inc(Result, 10 + Button.Width);
    end;
    if K3 >= 0 then
    begin
      Button.Caption := S3;
      Inc(Result, 10 + Button.Width);
    end;
    HH := Button.Height;
    if Result = 10 then
      Result := 0;
  finally
    Button.Free;
  end;}
    Button1.Visible := False;
    Button1.Font.Assign(FFont);
    Button1.AutoSize := True;
    Result := 10;
    CountButton(S1, S2, S3, K1, K2, K3);
    if K1 >= 0 then
    begin
      Button1.Caption := S1;
      Inc(Result, 10 + Button1.Width);
    end;
    if K2 >= 0 then
    begin
      Button1.Caption := S2;
      Inc(Result, 10 + Button1.Width);
    end;
    if K3 >= 0 then
    begin
      Button1.Caption := S3;
      Inc(Result, 10 + Button1.Width);
    end;
    HH := Button1.Height;
    if Result = 10 then
      Result := 0;

  Button1.Visible := True;

  Button1.Font.Assign(FFont);
  Button2.Font.Assign(FFont);
  Button3.Font.Assign(FFont);
  WidthButtons := 0;
  if K1 >= 0 then
  begin
    Button1.Caption := S1;
    DoOnClick(Button1, K1);
    Inc(WidthButtons, 10 + Button1.Width);
    Button1.Top := 62;
    Button1.Show;
  end
  else
    Button1.Hide;
  if K2 >= 0 then
  begin
    Button2.Caption := S2;
    DoOnClick(Button2, K2);
    Inc(WidthButtons, 10 + Button2.Width);
    Button2.Top := 62;
    Button2.Show;
  end
  else
    Button2.Hide;
  if K3 >= 0 then
  begin
    Button3.Caption := S3;
    DoOnClick(Button3, K3);
    Inc(WidthButtons, 10 + Button3.Width);
    Button3.Top := 62;
    Button3.Show;
  end
  else
    Button3.Hide;
end;

procedure TxMessageForm.DataCalculation(var W, H: Integer);
var
  B: TBitmap;
  M, K, HH, TB, WidthButtons, N, X, Y: Integer;
  S1, S2, S3, S4: String;
begin
  B := TBitmap.Create;
  try
    W := 0;
    H := 40;
    M := FMaxWidth - 20;
    B.Canvas.Font.Assign(FFont);
    if FShadow then
      Inc(H, FShadowDepth);
    Inc(H, 32);
    S1 := FCaption;
    S2 := '';
    N := 0;
    while True do
    begin
      if (Pos(#10, S1) <> 0) or (B.Canvas.TextWidth(S1) > M) then
      begin
        Inc(N);
        if (Pos(#10, S1) = 0) then
        begin
          S2 := S1;
          S1 := '';
        end
        else
        begin
          S2 := S2 + Copy(S1, 0, Pos(#10, S1) - 1);
          S1 := Copy(S1, Pos(#10, S1) + 1, Length(S1));
        end;
        if B.Canvas.TextWidth(S2) > M then
        begin
          S3 := '';
          while True do
          begin
            if Pos(' ', S2) <> 0 then
            begin
              S4 := S3;
              S3 := S3 + Copy(S2, 0, Pos(' ', S2));
              K := B.Canvas.TextWidth(S3);
              if K > M then
              begin
                Inc(N);
                if Pos(' ', S3) = 0 then
                begin
                  S2 := Copy(S2, Pos(' ', S2) + 1, Length(S2));
                  if K > W then
                    W := K;
                end
                else
                  if S4 <> '' then
                    if B.Canvas.TextWidth(S4) > W then
                      W := B.Canvas.TextWidth(S4)
                  else
                  begin
                    S2 := Copy(S2, Pos(' ', S2) + 1, Length(S2));
                    if K > W then
                      W := K;
                  end;
                S3 := '';
              end
              else
                S2 := Copy(S2, Pos(' ', S2) + 1, Length(S2));
            end
            else
              if Pos(#9, S2) <> 0 then
              begin
                S4 := S3;
                S3 := S3 + Copy(S1, 0, Pos(#9, S3));
                if B.Canvas.TextWidth(S3) > M then
                begin
                  Inc(N);
                  S3 := '';
                end
                else
                  S2 := Copy(S2, Pos(#9, S2), Length(S2));
              end
              else
              begin
                if (B.Canvas.TextWidth(S3) > W) then
                  W := B.Canvas.TextWidth(S3);
                if (B.Canvas.TextWidth(S3 + S2) < M)
                    and (B.Canvas.TextWidth(S3 + S2) > W) then
                  W := B.Canvas.TextWidth(S3 + S2)
                else
                  Inc(N);
                if B.Canvas.TextWidth(S2) > W then
                  W := B.Canvas.TextWidth(S2);
                S2 := '';
                Break;
              end;
          end;
        end;
      end
      else
      begin
        if B.Canvas.TextWidth(S1) > W then
        begin
          Inc(N);
          W := B.Canvas.TextWidth(S1);
        end;
        Break;
      end;
    end;
    Inc(W, 20);
    if W > FMaxWidth then
      W := FMaxWidth;
    Inc(H, B.Canvas.TextHeight(FCaption) * N);
    TB := TestButton(HH, WidthButtons);
    if TB > W then
      W := TB;
    X := 0;
    Y := 0;
    case FCallout of
      clLeft:
        X := CalloutSize;
      clTop:
        Y := CalloutSize;
    end;
    if W < FMinWidth then
      W := FMinWidth;
    Button1.Left := X + (W - WidthButtons) div 2;
    Button1.Top := Y + H - 10 - FShadowDepth;
    Button2.Left := Button1.Left + Button1.Width + 10;
    Button2.Top := Y + H - 10 - FShadowDepth;
    Button3.Left := Button2.Left + Button2.Width + 10;
    Button3.Top := Y + H - 10 - FShadowDepth;
    if TB <> 0 then
      Inc(H, HH);
    if (FCallout = clLeft) or (FCallout = clRight) then
      Inc(W, CalloutSize);
    if (FCallout = clTop) or (FCallout = clBottom) then
      Inc(H, CalloutSize);
    if FCallout = clLeft then
      X := CalloutSize;
    if FCallout = clTop then
      Y := CalloutSize;

    TxtRect.Left := X + 10;
    TxtRect.Top := 42 + Y;
    TxtRect.Right := W - 10 + X;
    TxtRect.Bottom := 42 + (N + 1) * B.Canvas.TextHeight('a') + Y;
  finally
    B.Free;
  end;

  Inc(W, FShadowDepth);
end;

procedure TxMessageForm.Paint;
var
  W, H, X, Y: Integer;
  BmpWindow, Bmp, GridBmp: TBitmap;
  R: TRect;
  procedure DrawShadow;
  var
    A, B: Integer;
    Canvas: TCanvas;
  begin
    Button1.Color := FColor;
    Button2.Color := FColor;
    Button3.Color := FColor;
    Bmp := TBitMap.Create;
    GridBmp := TBitMap.Create;
    BmpWindow := TBitMap.Create;
    try
      Bmp.Width := Width - FShadowDepth;
      Bmp.Height := Height - FShadowDepth;
      GridBmp.Width := Bmp.Width;
      GridBmp.Height := Bmp.Height;
      BMPWindow.Width := Bmp.Width + ShadowDepth;
      BMPWindow.Height := Bmp.Height + ShadowDepth;
      with Bmp.Canvas do
      begin
        Brush.Style := bsSolid;
        Brush.Color := clBlack;
        Brush.Style := bsSolid;
        Pen.Color := clBlack;
        Rectangle(0, 0, Bmp.Width, Bmp.Height);
        Brush.Color := clWhite;
        RoundRect(X, Y, X + W, Y + H, 20, 20);
        Pen.Style := psClear;
          case FCallout of
            clLeft:
              Polygon([Point(0, FCalloutDisplaysment), Point(X, FCalloutDisplaysment),
                       Point(X, FCalloutDisplaysment - CalloutSize div 2),
                       Point(0, FCalloutDisplaysment)]);

            clRight:
              Polygon([Point(X + W - 1, FCalloutDisplaysment), Point(Self.Width, FCalloutDisplaysment),
                       Point(W - 1, FCalloutDisplaysment - CalloutSize div 2),
                       Point(X + W - 1, FCalloutDisplaysment)]);
            clTop:
              Polygon([Point(FCalloutDisplaysment, 0), Point(FCalloutDisplaysment, Y),
                       Point(FCalloutDisplaysment - CalloutSize div 2, Y),
                       Point(FCalloutDisplaysment, 0)]);
            clBottom:
              Polygon([Point(FCalloutDisplaysment, H - 1),
                       Point(FCalloutDisplaysment, Self.Height - 1 - FShadowDepth),
                       Point(FCalloutDisplaysment - CalloutSize div 2, H - 1),
                       Point(FCalloutDisplaysment, H - 1)]);
          end;
      end;
      for A := 1 to (Bmp.Width div BMPResurce.Width) + 1 do
        for B := 1 to (Bmp.Height div BMPResurce.Height)  + 1 do
          GridBmp.Canvas.CopyRect(RectSet((A - 1) * BMPResurce.Width, (B - 1) * BMPResurce.Height,
                              A * BMPResurce.Width, B * BMPResurce.Height),
                              BMPResurce.Canvas,
                              RectSet(0, 0, BMPResurce.Width, BMPResurce.Height));
      BitBlt(GridBmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
             Bmp.Canvas.Handle, 0, 0, SrcAnd);
      BitBlt(GridBmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
             GridBmp.Canvas.Handle, 0, 0, NOTSRCCOPY);

      GetWindowRect(Self.Handle, R);
      Canvas := TCanvas.Create;
      try
        Canvas.Handle := GetDC(0);
        WindowBMP.Canvas.CopyRect(Classes.Rect(0, 0, WindowBMP.Width, WindowBMP.Height),
          Canvas, R);
      finally
        ReleaseDC(0, Canvas.Handle);
        Canvas.Handle := 0;
        Canvas.Free;
      end;

      BitBlt(WindowBMP.Canvas.Handle, 0 + ShadowDepth, 0 + ShadowDepth, BmpWindow.Width, BmpWindow.Height,
             GridBmp.Canvas.Handle, 0, 0, SRCAND);
      SetFocus;
      Button1.SetFocus;
    finally
      Bmp.Free;
      GridBmp.Free;
      BMPWindow.Free;
    end;
  end;

  procedure DrawWindowMessage;
  var
    BMP: TBitmap;
    BMPIcon: TIcon;
    PS: array[0..255] of Char;
    Format: Word;

    procedure IconLoad(Id: PChar);
    begin
      BMPIcon := TIcon.Create;
      BMPIcon.Handle := LoadIcon(hInstance, Id);
      if BMPIcon.Handle = 0 then
	Exception.Create('Can''t load resource icon');
    end;

  begin
    BMP := TBitmap.Create;
    try
      with WindowBMP.Canvas do
      begin
        Pen.Color := FBorderColor;
        Pen.Width := FBorderWidth;
        Brush.Color := FColor;
        RoundRect(X, Y, X + W, Y + H, 20, 20);
        case FCallout of
          clLeft:
          begin
            Polygon([Point(0, FCalloutDisplaysment), Point(X, FCalloutDisplaysment),
                     Point(X, FCalloutDisplaysment - CalloutSize div 2),
                     Point(0, FCalloutDisplaysment)]);
            Pen.Color := FColor;
            MoveTo(X, FCalloutDisplaysment);
            LineTo(X, FCalloutDisplaysment - CalloutSize div 2);
          end;
          clRight:
          begin
            Polygon([Point(X + W - 1, FCalloutDisplaysment),
                     Point(Self.Width - FShadowDepth, FCalloutDisplaysment),
                     Point(W - 1, FCalloutDisplaysment - CalloutSize div 2),
                     Point(X + W - 1, FCalloutDisplaysment)]);
            Pen.Color := FColor;
            MoveTo(W - 1, FCalloutDisplaysment);
            LineTo(W - 1, FCalloutDisplaysment - CalloutSize div 2);
          end;
          clTop:
          begin
            Polygon([Point(FCalloutDisplaysment, 0), Point(FCalloutDisplaysment, Y),
                     Point(FCalloutDisplaysment - CalloutSize div 2, Y),
                     Point(FCalloutDisplaysment, 0)]);
            Pen.Color := FColor;
            MoveTo(FCalloutDisplaysment, Y);
            LineTo(FCalloutDisplaysment - CalloutSize div 2, Y);
          end;
          clBottom:
          begin
              Polygon([Point(FCalloutDisplaysment, H - 1),
                       Point(FCalloutDisplaysment, Self.Height - FShadowDepth),
                       Point(FCalloutDisplaysment - CalloutSize div 2, H - 1),
                       Point(FCalloutDisplaysment, H - 1)]);
            Pen.Color := FColor;
            MoveTo(FCalloutDisplaysment, H - 1);
            LineTo(FCalloutDisplaysment - CalloutSize div 2, H - 1);
          end;
        end;
        case FIconType of
          itIconStop:
            IconLoad('xWindowMessage_Stop_Icon');
          itQuestion:
            IconLoad('xWindowMessage_Question_Icon');
          itExclamation:
            IconLoad('XWINDOWMESSAGE_EXLAMATION_ICON');
          itIconInformation:
            IconLoad('xWindowMessage_Information_Icon');
        end;
        if FIconType <> itNone then
        begin
          Draw(X + 5, Y + 5, BMPIcon);
        end;
        WindowBMP.Canvas.Font.Assign(FSubtitleFont);
        WindowBMP.Canvas.Brush.Style := bsClear;
        TextOut(X + 42, Y + 37 - Canvas.TextHeight(FSubtitleName), FSubTitleName);
        WindowBMP.Canvas.Font.Assign(FFont);
        StrPCopy(PS, FCaption);
        Format := DT_WORDBREAK;
        case FAlignment of
          taRightJustify: Format := Format or DT_RIGHT;
          taCenter: Format := Format or DT_CENTER;
        end;
        WindowBMP.Canvas.Font.Assign(FFont);
        DrawText(WindowBMP.Canvas.Handle, PS, Length(FCaption), TxtRect, Format);
        WindowBMP.Canvas.Pen.Color := clBtnFace;
        MoveTo(X + 5, Button1.Top - 5);
        LineTo(X + W - 5, Button1.Top - 5);
      end;
    finally
      if (BMPIcon <> nil) and (FIconType <> itNone) then
        BMPIcon.Free;
      BMP.Free;
    end;
  end;

begin
  DrawBMP := True;
  WindowBMP.Width := Width;
  WindowBMP.Height := Height;
  if FShadow then
  begin
    W := Width - FShadowDepth;
    H := Height - FShadowDepth;
    X := 0;
    Y := 0;
    case FCallout of
      clLeft:
      begin
        X := CalloutSize;
        Dec(W, CalloutSize);
      end;
      clTop:
      begin
        Y := CalloutSize;
        Dec(H, CalloutSize);
      end;
      clBottom:
        Dec(H, CalloutSize);
      clRight:
        Dec(W, CalloutSize);
    end;
    DrawShadow;
  end
  else
  begin
    W := Width;
    H := Height;
  end;
  DrawWindowMessage;
  Canvas.Draw(0, 0, WindowBMP);
end;

procedure TxMessageForm.Repaint;
begin
  Invalidate;
end;

procedure TxMessageForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure TxMessageForm.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

procedure TxMessageForm.SetSubtitleFont(AFont: TFont);
begin
  FSubtitleFont.Assign(AFont);
end;

procedure TxMessageForm.DoOnActivate(Sender: TObject);
begin
{  Application.ProcessMessages;}
  Visible := True;
end;

procedure TxMessageForm.DoOnDeactivate(Sender: TObject);
begin
  Visible := False;
end;

{$R *.DFM}

end.

