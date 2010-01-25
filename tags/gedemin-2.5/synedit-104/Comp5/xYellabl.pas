
{++

  Copyright (c) 1995-98 by Golden Software of Belarus

  Module

    xyellabl.pas

  Abstract

    Yellow label visual component.

  Author

    Andrei Kireev

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.04   20-Oct-97    andreik    32bit version.
    1.05   03-Jan-98    andreik    Property Lines added.
    1.06   17-Jan-98    andreik    Minor bug fixed.
    1.07   21-Jul-98    andreik    Bug with color fixed.
    1.08   17-Oct-98    andreik    Property Speed added.

--}

unit xYellabl;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

const
  DefSpeed = 40;

type
  TxYellowLabel = class(TLabel)
  private
    FirstTime: Boolean;
    Timer: TTimer;
    W, H, DX, DY: Integer;
    FLines: TStringList;
    FSpeed: Integer;

    procedure Draw(R: TRect; const ShowText: Boolean);
    procedure DoOnTimer(Sender: TObject);

    procedure SetLines(AStringList: TStringList);
    procedure SetSpeed(const Value: Integer);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    { по умолчанию анимационный эффект используется только
      при самой первой прорисовке метки. Если окно с меткой
      создается, прорисовывается, затем скрывается (но не удаляется),
      то при всех его последующих показываниях анимационного эффекта
      не будет. Если необходимо, чтобы метка рисовалась с анимацией
      каждый раз, то перед прорисовками следует вызывать метод
      ForceAnimation }
    procedure ForceAnimation;

  published
    property AutoSize default False; { set new default }

    { если проперти Caption не пуста, то выводится ее значение,
      иначе используется текст из Lines }
    property Lines: TStringList read FLines write SetLines;
    property Color default $C0FFFF;
    property Speed: Integer read FSpeed write SetSpeed
      default DefSpeed;
  end;

procedure Register;

implementation

constructor TxYellowLabel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle - [csOpaque];

  FirstTime := True;
  W := 0;
  H := 0;
  Timer := nil;
  AutoSize := False;

  FLines := TStringList.Create;

  Color := $C0FFFF;
  FSpeed := DefSpeed;
end;

destructor TxYellowLabel.Destroy;
begin
  if Assigned(Timer) then
    Timer.Free;
  FLines.Free;
  inherited Destroy;
end;

procedure TxYellowLabel.ForceAnimation;
begin
  FirstTime := True;
end;

procedure TxYellowLabel.Paint;
begin
  if csDesigning in ComponentState then
  begin
    Draw(GetClientRect, True);
    exit;
  end;

  if FirstTime then
  begin
    FirstTime := False;

    W := 0;
    H := 0;
    DX := (Width div 5) + 1;
    DY := (Height div 5) + 1;

    Timer := TTimer.Create(Self);
    Timer.OnTimer := DoOnTimer;
    Timer.Interval := FSpeed;
    Timer.Enabled := True;

    exit;
  end;

  if not Assigned(Timer) then
    Draw(GetClientRect, True);
end;

procedure TxYellowLabel.Draw(R: TRect; const ShowText: Boolean);
var
  SavedR: TRect;
  S: PChar;
  Format: Word;
  I: Integer;
begin
  SavedR := R;

  Inc(R.Left, 3);
  Inc(R.Top, 2);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clBtnShadow;
  Canvas.Pen.Style := psClear;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 10, 10);

  R := SavedR;
  Dec(R.Right, 3);
  Dec(R.Bottom, 2);
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := clBtnText;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 10, 10);

  if ShowText then
  begin
    R := SavedR;
    Inc(R.Left, 3);
    Inc(R.Top, 3);
    Dec(R.Right, 6);
    Dec(R.Bottom, 5);

    Canvas.Font := Font;
    Canvas.Brush.Style := bsClear;

    Format := DT_WORDBREAK;
    case Alignment of
      taRightJustify: Format := Format or DT_RIGHT;
      taCenter: Format := Format or DT_CENTER;
    else
      Format := Format or DT_LEFT;
    end;

    if Caption > '' then
    begin
      S := StrAlloc(Length(Caption) + 1);
      try
        StrPCopy(S, Caption);
        DrawText(Canvas.Handle, S, Length(Caption), R, Format);
      finally
        StrDispose(S);
      end;
    end else
    begin
      { Caption = '' }
      S := StrAlloc(Length(FLines.Text) + 1);
      try
        for I := 1 to Length(FLines.Text) do // strpcopy работает с ошибкой!!!
          S[I - 1] := FLines.Text[I];
        DrawText(Canvas.Handle, S, Length(FLines.Text), R, Format);
      finally
        StrDispose(S);
      end;
    end;
  end;
end;

procedure TxYellowLabel.DoOnTimer(Sender: TObject);
var
  X, Y: Integer;
begin
  Inc(W, DX);
  Inc(H, DY);

  if W > Width then
    W := Width;

  if H > Height then
    H := Height;

  if (W = Width) and (H = Height) then
  begin
    Timer.Free;
    Timer := nil;
    Draw(GetClientRect, True);
  end else
  begin
    X := (Width - W) div 2;
    Y := (Height - H) div 2;
    Draw(Rect(X, Y, X + W, Y + H), False);
  end;
end;

procedure TxYellowLabel.SetLines(AStringList: TStringList);
begin
  FLines.Assign(AStringList);
  Invalidate;
end;

procedure TxYellowLabel.SetSpeed(const Value: Integer);
begin
  Assert((Value > 0) and (Value < 1000));
  FSpeed := Value;
end;

// Registration -----------------------------------------------------

procedure Register;
begin
  RegisterComponents('gsVC', [TxYellowLabel]);
end;

end.




