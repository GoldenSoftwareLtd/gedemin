
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    credit.pas

  Abstract

    A Delphi visual component. Credits window.

  Author

    Denis Romanovski (13-Oct-95)

  Contact address

    goldsoft%swatogor.belpak.minsk.by@demos.su

  Revisions history

    0.00                 dennis     Pre-initial version.
    1.00    20-Oct-95    andreik    Initial version.
    1.01    20-Oct-95    andreik    Minor change.
    1.02    26-Oct-95    andreik    Added Assign method, ECreditError class,
                                    ClickActivate property and OnActivate event.
    1.03    01-Jan-96    andreik    Added sound properties.
    1.04    15-Feb-97    andreik    Minor change.
    1.05    20-Oct-97    andreik    Ported to Delphi32.
--}

unit Credit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DsgnIntf, ExtCtrls;

const
  DefWidth = 250;
  DefHeight = 150;
  DefSpeed = 90;
  DefTextColor = clYellow;
  DefBackgroundColor = clBlack;
  DefDblClickActivate = True;
  DefText3D = True;
  DefShadowColor = clOlive;
  DefBackColor = clBtnFace;
  DefFrame = False;
  DefAdjustToSplash = False;
  DefStep = 1;
  DefDepth = 2;
  DefCaptureMouse = True;
  DefClickActivate = False;
  DefLoopPlay = False;

const
  { auxiliry message }
  AM_STOPTIMER = WM_USER + 17;

type
  TCredit = class(TCustomControl)
  private
    FSplash: TBitmap;
    FText: TStringList;
    FSpeed: Word;
    FTextColor: TColor;
    FBackgroundColor: TColor;
    FDblClickActivate: Boolean;
    FText3D: Boolean;
    FShadowColor: TColor;
    FBackColor: TColor;
    FFrame: Boolean;
    FAdjustToSplash: Boolean;
    FStep: Word;
    FDepth: Word;
    FCaptureMouse: Boolean;
    FClickActivate: Boolean;
    FOnActivate: TNotifyEvent;
    FActive: Boolean;
    FWaveFile: String;
    FLoopPlay: Boolean;

    Position: Word;
    CreditBMP: TBitmap;
    Timer: TTimer;

    procedure SetSplash(ASplash: TBitmap);
    procedure SetText(AText: TStringList);
    procedure SetBackColor(ABackColor: TColor);
    procedure SetFrame(AFrame: Boolean);
    procedure SetAdjustToSplash(AnAdjustToSplash: Boolean);
    procedure SetActive(AnActive: Boolean);

    procedure DrawRunningText;
    procedure DoOnTimer(Sender: TObject);

    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure AMStopTimer(var Message: TMessage);
      message AM_STOPTIMER;

  protected
    procedure Loaded; override;
    procedure DestroyWnd; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(ACredit: TPersistent); override;
    procedure Start;
    procedure Stop;

    property Active: Boolean read FActive write SetActive;

  published
    property Splash: TBitmap read FSplash write SetSplash;
    property Text: TStringList read FText write SetText;
    property Speed: Word read FSpeed write FSpeed default DefSpeed;
    property TextColor: TColor read FTextColor write FTextColor
      default DefTextColor;
    property BackgroundColor: TColor read FBackgroundColor
      write FBackgroundColor default DefBackgroundColor;
    property DblClickActivate: Boolean read FDblClickActivate
      write FDblClickActivate default DefDblClickActivate;
    property Text3D: Boolean read FText3D write FText3D
      default DefText3D;
    property ShadowColor: TColor read FShadowColor write FShadowColor
      default DefShadowColor;
    property BackColor: TColor read FBackColor write SetBackColor
      default DefBackColor;
    property Frame: Boolean read FFrame write SetFrame
      default DefFrame;
    property AdjustToSplash: Boolean read FAdjustToSplash write SetAdjustToSplash
      default DefAdjustToSplash;
    property Step: Word read FStep write FStep default DefStep;
    property Depth: Word read FDepth write FDepth default DefDepth;
    property CaptureMouse: Boolean read FCaptureMouse write FCaptureMouse
      default DefCaptureMouse;
    property ClickActivate: Boolean read FClickActivate write FClickActivate
      default DefClickActivate;
    property WaveFile: String read FWaveFile write FWaveFile;
    property LoopPlay: Boolean read FLoopPlay write FLoopPlay
      default DefLoopPlay;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;

    { inherited properties }
    property Font;
    property Width default DefWidth;
    property Height default DefHeight;
    property Enabled;
    property DragCursor;
    property DragMode;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

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

type
  ECreditError = class(Exception);

procedure Register;

implementation

uses
  MMSystem, Rect;

type
  TWaveFileProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

{ TCredit ------------------------------------------------}

constructor TCredit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ControlStyle := ControlStyle + [csOpaque] - [csFramed];

  FSplash := TBitmap.Create;
  FText := TStringList.Create;

  Width := DefWidth;
  Height := DefHeight;
  FSpeed := DefSpeed;
  FTextColor := DefTextColor;
  FBackgroundColor := DefBackgroundColor;
  FDblClickActivate := DefDblClickActivate;
  FText3D := DefText3D;
  FShadowColor := DefShadowColor;
  FBackColor := DefBackColor;
  FFrame := DefFrame;
  FAdjustToSplash := DefAdjustToSplash;
  FStep := DefStep;
  FDepth := DefDepth;
  FCaptureMouse := DefCaptureMouse;
  FClickActivate := DefClickActivate;
  FWaveFile := '';
  FLoopPlay := DefLoopPlay;
  FOnActivate := nil;

  FActive := False;
end;

destructor TCredit.Destroy;
begin
  FSplash.Free;
  FText.Free;
  inherited Destroy;
end;

procedure TCredit.Assign(ACredit: TPersistent);
begin
  if ACredit = nil then exit;

  if Active then
    raise ECreditError.Create('Can not assign to active credit');

  Splash := (ACredit as TCredit).Splash;
  Text := (ACredit as TCredit).Text;
  Speed := (ACredit as TCredit).Speed;
  TextColor := (ACredit as TCredit).TextColor;
  BackgroundColor := (ACredit as TCredit).BackgroundColor;
  DblClickActivate := (ACredit as TCredit).DblClickActivate;
  Text3D := (ACredit as TCredit).Text3D;
  ShadowColor := (ACredit as TCredit).ShadowColor;
  BackColor := (ACredit as TCredit).BackColor;
  Frame := (ACredit as TCredit).Frame;
  AdjustToSplash := (ACredit as TCredit).AdjustToSplash;
  Step := (ACredit as TCredit).Step;
  Depth := (ACredit as TCredit).Depth;
  CaptureMouse := (ACredit as TCredit).CaptureMouse;
  ClickActivate := (ACredit as TCredit).ClickActivate;
  WaveFile := (ACredit as TCredit).WaveFile;
  Font := (ACredit as TCredit).Font;
  Hint := (ACredit as TCredit).Hint;
  ShowHint := (ACredit as TCredit).ShowHint;
  OnActivate := (ACredit as TCredit).OnActivate;
end;

procedure TCredit.Start;
var
  R: TRect;
  Format: Integer;
  I: Word;
  CWaveFile: array[0..255] of Char;
begin
  if Active or (Text.Count = 0) then Exit;

  MouseCapture := FCaptureMouse;

  CreditBMP := TBitmap.Create;

  { calculate bitmap sizes }
  CreditBMP.Canvas.Font := Font;
  Format := DT_CALCRECT or DT_CENTER;
  DrawText(CreditBMP.Canvas.Handle, FText.GetText, -1, R, Format);
  CreditBMP.Width := Width;
  CreditBMP.Height := R.Bottom - R.Top + Height;

  { fill background }
  CreditBMP.Canvas.Brush.Style := bsSolid;
  CreditBMP.Canvas.Brush.Color := FBackColor;
  R := RectSet(0, 0, Width, Height);
  CreditBMP.Canvas.FillRect(R);
  CreditBMP.Canvas.Brush.Color := FBackgroundColor;
  R := RectSet(0, Height, Width, CreditBMP.Height);
  CreditBMP.Canvas.FillRect(R);

  { draw splash bm }
  if not FSplash.Empty then
    CreditBMP.Canvas.Draw((Width - FSplash.Width) div 2,
    (Height - FSplash.Height) div 2, FSplash);

  { draw text }
  Format := DT_CENTER;
  R := RectSet(0, Height, Width, CreditBMP.Height);
  SetBkMode(CreditBMP.Canvas.Handle, TRANSPARENT);

  if FText3D then
  begin
    CreditBMP.Canvas.Font.Color := FShadowColor;
    for I := 1 to FDepth do
    begin
      RectRelativeMove(R, 1, 1);
      DrawText(CreditBMP.Canvas.Handle, FText.GetText, -1, R, Format);
    end;
    RectRelativeMove(R, -FDepth, -FDepth);
  end;

  CreditBMP.Canvas.Font.Color := FTextColor;
  DrawText(CreditBMP.Canvas.Handle, FText.GetText, -1, R, Format);

  { create and set timer }
  Timer := TTimer.Create(Self);
  Timer.Interval := FSpeed;
  Timer.OnTimer := DoOnTimer;

  { start music }
  if FWaveFile <> '' then
    if FLoopPlay then
      sndPlaySound(StrPCopy(CWaveFile, WaveFile), SND_ASYNC or SND_LOOP)
    else
      sndPlaySound(StrPCopy(CWaveFile, WaveFile), SND_ASYNC);

  FActive := True;
  Position := 0;

  if Assigned(FOnActivate) then
    FOnActivate(Self);
end;

procedure TCredit.Stop;
begin
  if Active then
  begin
    sndPlaySound(nil, 0); { stops the sound }
    Timer.Free;
    CreditBMP.Free;
    FActive := False;
    MouseCapture := False;
    InvalidateRect(Handle, nil, False);
  end;
end;

procedure TCredit.Loaded;
begin
  inherited Loaded;
  if FAdjustToSplash and (not FSplash.Empty) then
  begin
    Width := FSplash.Width;
    Height := FSplash.Height;
  end;
end;

procedure TCredit.DestroyWnd;
begin
  if Active then Stop;
  inherited DestroyWnd;
end;

procedure TCredit.Paint;
var
  OffScreen: TBitmap;
  R: TRect;
begin
  if Active then
    DrawRunningText
  else begin
    OffScreen := TBitmap.Create;
    try
      R := GetClientRect;
      OffScreen.Width := RectWidth(R);
      OffScreen.Height := RectHeight(R);

      OffScreen.Canvas.Brush.Color := FBackColor;
      OffScreen.Canvas.Brush.Style := bsSolid;
      OffScreen.Canvas.FillRect(R);

      if not FSplash.Empty then
        OffScreen.Canvas.Draw((RectWidth(R) - FSplash.Width) div 2,
        (RectHeight(R) - FSplash.Height) div 2, FSplash);

      Canvas.Draw(0, 0, OffScreen);
    finally
      OffScreen.Free;
    end;
  end;
end;

procedure TCredit.SetSplash(ASplash: TBitmap);
begin
  FSplash.Assign(ASplash);

  if AdjustToSplash and (not FSplash.Empty) then
  begin
    Width := FSplash.Width;
    Height := FSplash.Height;
  end;

  Invalidate;
end;

procedure TCredit.SetText(AText: TStringList);
begin
  FText.Assign(AText);
end;

procedure TCredit.SetBackColor(ABackColor: TColor);
begin
  if FBackColor <> ABackColor then
  begin
    FBackColor := ABackColor;
    InvalidateRect(Handle, nil, False);
  end;
end;

procedure TCredit.SetFrame(AFrame: Boolean);
begin
  if AFrame <> FFrame then
  begin
    FFrame := AFrame;
    if FFrame then ControlStyle := ControlStyle + [csFramed]
      else ControlStyle := ControlStyle - [csFramed];
    RecreateWnd;
    if Owner is TWinControl then
      TWinControl(Owner).Invalidate;
  end;
end;

procedure TCredit.SetAdjustToSplash(AnAdjustToSplash: Boolean);
begin
  if AnAdjustToSplash <> FAdjustToSplash then
  begin
    FAdjustToSplash := AnAdjustToSplash;
    if FAdjustToSplash and (not FSplash.Empty) then
    begin
      Width := FSplash.Width;
      Height := FSplash.Height;
    end;
  end;
end;

procedure TCredit.SetActive(AnActive: Boolean);
begin
  if AnActive <> FActive then
    if AnActive then Start else Stop;
end;

procedure TCredit.DrawRunningText;
var
  R, R2: TRect;
begin
  if Position <= CreditBMP.Height - Height then
  begin
    R := RectSet(0, Position, Width, Position + Height);
    Canvas.CopyRect(GetClientRect, CreditBMP.Canvas, R);
  end else begin
    R := RectSet(0, 0, Width, CreditBMP.Height - Position);
    R2 := RectSet(0, Position, Width, CreditBMP.Height);
    Canvas.CopyRect(R, CreditBMP.Canvas, R2);

    R := RectSet(0, R.bottom, Width, Height);
    R2 := RectSet(0, 0, Width, Height - R.top);
    Canvas.CopyRect(R, CreditBMP.Canvas, R2);
  end;
end;

procedure TCredit.DoOnTimer(Sender: TObject);
begin
  if Position >= CreditBMP.Height + 1 then
  begin
    Timer.Enabled := False;
    PostMessage(HANDLE, AM_STOPTIMER, 0, 0);
  end else begin
    DrawRunningText;
    Inc(Position, FStep);
  end;
end;

procedure TCredit.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  if (not Active) and FDblClickActivate then Start;
end;

procedure TCredit.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if (not Active) and FClickActivate then Start;
end;

procedure TCredit.AMStopTimer(var Message: TMessage);
begin
  Stop;
end;

{ TWaveFileProperty --------------------------------------}

procedure TWaveFileProperty.Edit;
var
  FileOpen: TOpenDialog;
begin
  FileOpen := TOpenDialog.Create(Application);
  FileOpen.Filename := GetValue;
  FileOpen.Filter := 'Wave files (*.wav)|*.WAV|All files (*.*)|*.*';
  FileOpen.Options := FileOpen.Options + [ofPathMustExist, ofFileMustExist];
  try
    if FileOpen.Execute then SetValue(FileOpen.Filename);
  finally
    FileOpen.Free;
  end;
end;

function TWaveFileProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-Misc', [TCredit]);
  RegisterPropertyEditor(TypeInfo(String), TCredit, 'WaveFile',
    TWaveFileProperty);
end;

end.
