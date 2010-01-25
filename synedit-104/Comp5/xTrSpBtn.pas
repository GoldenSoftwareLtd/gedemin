
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtrspbtn.pas

  Abstract

    Transparent speed buttons.

  Author

    Andrei Kireev (01-Jul-96)

  Contact address

  Revisions history

    1.00    01-Jul-96    andreik    Initial version.
    1.01    15-Jul-96    andreik    Minor change.
    1.02    16-Jul-96    andreik    Minor change.
    1.03    14-Sep-96    andreik    Overrided Click method.
    1.04    11-Dec-96    andreik    Minor change.
    1.05    19-Feb-97    andreik    PartTag property Added.
    1.05    01-Jun-97    andreik    IconBW propery added.
    1.06    05-Jun-97    andreik    Minor change.
    1.07    28-Jul-97    andreik    Minor change.
    1.08    31-Jul-97    andreik    Slightly changed behavior.
    1.09    10-Mar-98    andreik    Web style underline added.
    1.10    24-May-98    andreik    Minor bug with font in Calendar btn fixed.
    1.11    01-Sep-98    andreik    Minor bug with Enabled/Disabled redrawing fixed.
    1.12    12-Oct-98    andreik    Highlight color added.

--}

unit xTrSpBtn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls, ExtCtrls;

type
  TxTransSpeedButton = class(TSpeedButton)
  private
    FIcon, FIconBW: TIcon;
    FTextShadow: Boolean;
    FPartTag: Integer;
    FRaise: Boolean;
    FHighlightColor: TColor;

    Timer: TTimer;

    procedure SetIcon(AnIcon: TIcon);
    procedure SetIconBW(AnIcon: TIcon);
    procedure SetTextShadow(ATextShadow: Boolean);
    procedure SetRaise(ARaise: Boolean);
    procedure SetDown(ADown: Boolean);
    function GetDown: Boolean;

    procedure DoOnTimer(Sender: TObject);

  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Click; override;

  published
    property Width default 52;
    property Height default 52;
    property ParentFont default True;

    property Icon: TIcon read FIcon write SetIcon;
    property IconBW: TIcon read FIconBW write SetIconBW;
    property TextShadow: Boolean read FTextShadow write SetTextShadow
      default True;
    property PartTag: Integer read FPartTag write FPartTag
      default 0;
    property _Raise: Boolean read FRaise write SetRaise
      default False;
    property Down: Boolean read GetDown write SetDown;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor
      default clBlue;
  end;

type
  TxCalendarSpeedButton = class(TxTransSpeedButton)
  private
    procedure WMTimeChange(var Message: TMessage);
      message WM_TIMECHANGE;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property Icon stored False;
    property IconBW stored False;
  end;

procedure Register;

implementation

{$R TRSPBTN.RES}

var
  RaisedButton: TxTransSpeedButton;

{ TxTransSpeedButton -------------------------------------}

constructor TxTransSpeedButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle - [csOpaque] + [csCaptureMouse];
  Width := 52;
  Height := 52;
  ParentFont := True;
  FIcon := TIcon.Create;
  FIconBW := TIcon.Create;
  FTextShadow := True;
  FPartTag := 0;
  FRaise := False;
  FHighlightColor := clBlue;
  Timer := nil;
end;

destructor TxTransSpeedButton.Destroy;
begin
  FIcon.Free;
  FIconBW.Free;
  if Assigned(Timer) then Timer.Free;
  if RaisedButton = Self then
    RaisedButton := nil;
  inherited Destroy;
end;

procedure TxTransSpeedButton.Click;
begin
  Down := True;
  inherited Click;
end;

procedure TxTransSpeedButton.Paint;
var
  R: TRect;
  S: array[0..31] of Char;
  DX, DY: Integer;
begin
  if FIcon.Empty then
  begin
    inherited Paint;
    exit;
  end;

  {
  if FState in [bsDown, bsExclusive] then
  begin
    DX := 1;
    DY := 1;
  end
  else if FRaise then
  begin
    DX := -1;
    DY := -1;
  end else
  begin
    DX := 0;
    DY := 0;
  end;
  }
  DX := 0;
  DY := 0;

  if (not (FState in [bsDown, bsExclusive])) and (not FRaise) and (not FIconBW.Empty) then
    Canvas.Draw(((Width - FIcon.Width - 2) div 2) + DX, 1 + DY, FIconBW)
  else
    Canvas.Draw(((Width - FIcon.Width - 2) div 2) + DX, 1 + DY, FIcon);

  Canvas.Font := Font;
  if (FState in [bsDown, bsExclusive]) or FRaise then
  begin
    Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  end;
  Canvas.Brush.Style := bsClear;
  if Length(Caption) < SizeOf(S) then
    StrPCopy(S, Caption)
  else
    raise Exception.Create('Caption too long');

  if FTextShadow then
  begin
    Canvas.Font.Color := clBtnShadow;
    R := Rect(2 + DX, FIcon.Height + 2 + 2 + DY, Width + 2, Height + 2);
    DrawText(Canvas.Handle, S, Length(Caption), R, DT_CENTER);
  end;

  if Enabled then
  begin
    if (FState in [bsDown, bsExclusive]) or FRaise then
      Canvas.Font.Color := FHighlightColor
    else
      Canvas.Font.Color := Font.Color
  end else
    Canvas.Font.Color := clSilver;
  R := Rect(1 + DX, FIcon.Height + 2 + 1 + DY, Width + 1, Height + 1);
  DrawText(Canvas.Handle, S, Length(Caption), R, DT_CENTER);

  { draw bevel }
  R := GetClientRect;
  if FState in [bsDown, bsExclusive] then
    Frame3D(Canvas, R, clBlack, clWhite, 1)
  else if FRaise and FIconBW.Empty then
    Frame3D(Canvas, R, clWhite, clBlack, 1);
end;

procedure TxTransSpeedButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);

  _Raise := (X > 0) and (X < Width) and (Y > 0) and (Y < Height);

  if FRaise and (not Assigned(Timer)) then
  begin
    Timer := TTimer.Create(Self);
    Timer.Interval := 200;
    Timer.OnTimer := DoOnTimer;
  end;
end;

procedure TxTransSpeedButton.SetIcon(AnIcon: TIcon);
begin
  FIcon.Assign(AnIcon);
  Invalidate;
end;

procedure TxTransSpeedButton.SetIconBW(AnIcon: TIcon);
begin
  FIconBW.Assign(AnIcon);
  Invalidate;
end;

procedure TxTransSpeedButton.SetTextShadow(ATextShadow: Boolean);
begin
  if FTextShadow <> ATextShadow then
  begin
    FTextShadow := ATextShadow;
    Invalidate;
  end;
end;

procedure TxTransSpeedButton.SetRaise(ARaise: Boolean);
begin
  if ARaise = FRaise then
    exit;

  if ARaise and Assigned(RaisedButton) and (RaisedButton <> Self) then
    RaisedButton._Raise := False;

  if (not ARaise) and (RaisedButton = Self) then
  begin
    RaisedButton := nil;
    Timer.Free;
    Timer := nil;
  end;

  if ARaise then
    RaisedButton := Self;

  FRaise := ARaise;

  Invalidate;
end;

procedure TxTransSpeedButton.SetDown(ADown: Boolean);
begin
  if ADown then
    _Raise := False;

  inherited Down := ADown;
  Invalidate;
end;

function TxTransSpeedButton.GetDown: Boolean;
begin
  Result := inherited Down;
end;

procedure TxTransSpeedButton.DoOnTimer(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);

  if (P.X < 0) or (P.X > Width) or (P.Y < 0) or (P.Y > Height) then
  begin
    Timer.Free;
    Timer := nil;
    _Raise := False;
  end;
end;

{ TxCalendarButton ---------------------------------------}

constructor TxCalendarSpeedButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FIcon.Handle := LoadIcon(hInstance, 'TRSPBTN_CALENDAR');
  if FIcon.Handle = 0 then
    raise Exception.Create('Invalid resource');
end;

procedure TxCalendarSpeedButton.Paint;
var
  S: array[0..15] of Char;
  R: TRect;
begin
  inherited Paint;

  with Canvas do
  begin
    Font.Name := 'MS Sans Serif';
    Font.Style := [fsBold];
    Font.Size := 8;
    Font.Color := clRed;
    Font.CharSet := RUSSIAN_CHARSET;
    Brush.Style := bsClear;
    StrPCopy(S, FormatDateTime('d', Date));
    R := Rect(0, 0, Width - 2, 30);
    DrawText(Handle, S, StrLen(S), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

    Font.Name := 'Arial';
    Font.Color := clBlack;
{    Font.Style := []; }
    Font.Size := 6;
    Font.CharSet := RUSSIAN_CHARSET;
    StrPCopy(S, FormatDateTime('mmm', Date));
    R := Rect(0, 18, Width - 2, 31);
    DrawText(Handle, S, StrLen(S), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure TxCalendarSpeedButton.WMTimeChange(var Message: TMessage);
begin
  Invalidate;
  Message.Result := 0;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsBtn', [TxTransSpeedButton]);
  RegisterComponents('gsBtn', [TxCalendarSpeedButton]);
end;

initialization
  RaisedButton := nil;
end.
