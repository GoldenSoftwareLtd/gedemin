
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xbmpeff.pas

  Abstract

    Several bitmap effects.

  Author

    Andrei Kireev (10-Feb-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00     16-Feb-96    andreik    Initial version.
    1.01     08-Jul-96    andreik    Minor change.
    1.02     23-may-97    andreik    Multitasking.
    1.03     21-oct-97    andreik    Delphi32 version.

  Known bugs

    If Align set to no alClient then effects are not working.
--}

unit xBmpEff;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TDirection = (dLeft2Right, dRight2Left, dTop2Bottom, dBottom2Top,
    dInside2Outside, dOutside2Inside);

type
  TEffect = (efNone, efExplode, efShade, efSlide, efChessBoard,
    efMove, efStripes);

type
  TStep = 1..65535;

const
  DefDelay = 0;
  DefDirection = dLeft2Right;
  DefEffect = efShade;
  DefStep = 10;

type
  TxBitmapEffect = class(TGraphicControl)
  private
    FBitmap: TBitmap;
    FDelay: Word;
    FDirection: TDirection;
    FEffect: TEffect;
    FStep: TStep;

    OldBitmap: TBitmap;

    ReEnterFlag: Boolean;

    procedure SetBitmap(ABitmap: TBitmap);
    procedure SetDelay(ADelay: Word);
    procedure SetDirection(ADirection: TDirection);
    procedure SetEffect(AnEffect: TEffect);
    procedure SetStep(AStep: TStep);

    function GetIsDoingEffect: Boolean;

    procedure _DoEffect;
    procedure DoEffect;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property Delay: Word read FDelay write SetDelay
      default DefDelay;
    property Direction: TDirection read FDirection write SetDirection
      default DefDirection;
    property Effect: TEffect read FEffect write SetEffect
      default DefEffect;
    property Step: TStep read FStep write SetStep
      default DefStep;
    property IsDoingEffect: Boolean read GetIsDoingEffect;

    property Align;
    property Width default 28;
    property Height default 28;
  end;

  TxBitmapEffectEx = class(TxBitmapEffect)
  private
    FHelpBitmap: TBitmap;

    procedure SetHelpBitmap(ABitmap: TBitmap);

  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property HelpBitmap: TBitmap read FHelpBitmap write SetHelpBitmap;
  end;                            

  ExBitmapEffectError = class(Exception);

procedure Register;

implementation

{$R XBMPEFF.RES}

const
  IconBitmapId = 'XBMPEFFICON';

procedure DoDelay(Pause: LongWord);
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do
    Application.ProcessMessages;
end;

constructor TxBitmapEffect.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBitmap := TBitmap.Create;
  FDelay := DefDelay;
  FDirection := DefDirection;
  FEffect := DefEffect;
  FStep := DefStep;

  Width := 28;
  Height := 28;

  OldBitmap := TBitmap.Create;

  ReEnterFlag := False;
end;

destructor TxBitmapEffect.Destroy;
begin
  if ReEnterFlag then
    raise ExBitmapEffectError.Create('Can not destroy');

  FBitmap.Free;
  OldBitmap.Free;
  inherited Destroy;
end;

procedure TxBitmapEffect.Paint;
var
  Bm: TBitmap;
begin
  if (not Assigned(FBitmap)) or (FBitmap.Empty) then
  begin
    if not (csDesigning in ComponentState) then
      exit;

    Bm := TBitmap.Create;
    try
      Bm.Handle := LoadBitmap(hInstance, IconBitmapId);

      Width := Bm.Width;
      Height := Bm.Height;

      Canvas.Draw(0, 0, Bm);
    finally
      Bm.Free;
    end;
  end else
    Canvas.Draw(0, 0, FBitmap);
end;

procedure TxBitmapEffect.SetBitmap(ABitmap: TBitmap);
begin
  if Assigned(ABitmap) then
  begin
    if (ABitmap.Width = Width) and (ABitmap.Height = Height) then
    begin
      OldBitmap.Assign(FBitmap);
      FBitmap.Assign(ABitmap);
      DoEffect;
    end else
    begin
      FBitmap.Assign(ABitmap);
      Width := FBitmap.Width;
      Height := FBitmap.Height;
      Repaint;
    end;
  end else
  begin
    OldBitmap.Assign(nil);
    FBitmap.Assign(nil);
    Width := 0;
    Height := 0;
  end;
end;

procedure TxBitmapEffect.SetDelay(ADelay: Word);
begin
  if ADelay <> FDelay then
  begin
    FDelay := ADelay;
    if csDesigning in ComponentState then DoEffect;
  end;
end;

procedure TxBitmapEffect.SetDirection(ADirection: TDirection);
begin
  if ADirection <> FDirection then
  begin
    FDirection := ADirection;
    if csDesigning in ComponentState then
      try
        DoEffect;
      except
        raise ExBitmapEffectError.Create('This direction is not compatible with current effect');
      end;
  end;
end;

procedure TxBitmapEffect.SetEffect(AnEffect: TEffect);
begin
  if AnEffect <> FEffect then
  begin
    FEffect := AnEffect;
    if csDesigning in ComponentState then
      try
        DoEffect;
      except
        raise ExBitmapEffectError.Create('This effect is not compatible with current direction');
      end;
  end;
end;

procedure TxBitmapEffect.SetStep(AStep: TStep);
begin
  if AStep <> FStep then
  begin
    FStep := AStep;
    if csDesigning in ComponentState then DoEffect;
  end;
end;

function TxBitmapEffect.GetIsDoingEffect: Boolean;
begin
  Result := ReEnterFlag;
end;

procedure TxBitmapEffect._DoEffect;
var
  R1, R2, R3, R4: TRect;
  I, W, H, K, X, Y: Integer;
  P: PPoint;
  List: TList;
  B: Boolean;

  Br1Bm, Br2Bm: TBitmap;
  Bm1, Bm2, Tmp: TBitmap;

  S: array[0..63] of Char;
begin
  if ReEnterFlag then
    exit;

  if FBitmap.Empty or OldBitmap.Empty then
  begin
    Repaint;
    exit;
  end;

  ReEnterFlag := True;
  try

    case FEffect of
      efStripes:
      begin
        case FDirection of
          dLeft2Right:
          begin
            W := Trunc(Width / Step);
            for I := 0 to Step - 1 do
            begin
              for K := 0 to W - 1 do
              begin
                R1 := Rect(K * Step + I, 0, K * Step + I + 1, Height);
                Canvas.CopyRect(R1, FBitmap.Canvas, R1);
              end;
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Left2Right }

          dRight2Left:
          begin
            W := Trunc(Width / Step);
            for I := Step - 1 downto 0 do
            begin
              for K := 0 to W - 1 do
              begin
                R1 := Rect(K * Step + I, 0, K * Step + I + 1, Height);
                Canvas.CopyRect(R1, FBitmap.Canvas, R1);
              end;
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Right2Left }

          dTop2Bottom:
          begin
            H := Trunc(Height / Step);
            for I := 0 to Step - 1 do
            begin
              for K := 0 to H - 1 do
              begin
                R1 := Rect(0, K * Step + I, Width, K * Step + I + 1);
                Canvas.CopyRect(R1, FBitmap.Canvas, R1);
              end;
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Top2Bottom }

          dBottom2Top:
          begin
            H := Trunc(Height / Step);
            for I := Step - 1 downto 0 do
            begin
              for K := 0 to H - 1 do
              begin
                R1 := Rect(0, K * Step + I, Width, K * Step + I + 1);
                Canvas.CopyRect(R1, FBitmap.Canvas, R1);
              end;
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Bottom2Top }
        else
          raise ExBitmapEffectError.Create('The direction is not implemented');
        end;
      end;

      efMove:
      begin
        case FDirection of
          dLeft2Right:
          begin
            R4 := Rect(0, 0, Step, Height);
            for I := 0 to (Width div Step) - 1 do
            begin
              R1 := Rect(0, 0, Step * I, Height);
              R2 := Rect(Step, 0, Step * I + Step, Height);
              Canvas.CopyRect(R2, Canvas, R1);
              R3 := Rect(Width - Step * I - Step, 0,
                Width - Step * I, Height);
              Canvas.CopyRect(R4, FBitmap.Canvas, R3);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Left2Right }

          dRight2Left:
          begin
            R4 := Rect(Width - Step, 0, Width, Height);
            for I := 0 to (Width div Step) - 1 do
            begin
              R1 := Rect(Width - I * Step, 0, Width, Height);
              R2 := Rect(Width - I * Step - Step, 0, Width - Step, Height);
              Canvas.CopyRect(R2, Canvas, R1);
              R3 := Rect(Step * I, 0, Step * I + Step, Height);
              Canvas.CopyRect(R4, FBitmap.Canvas, R3);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Right2Left }

          dTop2Bottom:
          begin
            R4 := Rect(0, 0, Width, Step);
            for I := 0 to (Height div Step) - 1 do
            begin
              R1 := Rect(0, 0, Width, I * Step);
              R2 := Rect(0, Step, Width, I * Step + Step);
              Canvas.CopyRect(R2, Canvas, R1);
              R3 := Rect(0, Height - Step * I - Step, Width, Height - Step * I);
              Canvas.CopyRect(R4, FBitmap.Canvas, R3);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Top2Bottom }

          dBottom2Top:
          begin
            R4 := Rect(0, Height - Step, Width, Height);
            for I := 0 to (Height div Step) - 1 do
            begin
              R1 := Rect(0, Height - Step * I, Width, Height);
              R2 := Rect(0, Height - Step * I - Step, Width, Height - Step);
              Canvas.CopyRect(R2, Canvas, R1);
              R3 := Rect(0, Step * I, Width, Step * I + Step);
              Canvas.CopyRect(R4, FBitmap.Canvas, R3);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Bottom2Top }

          dInside2Outside:
          begin
            X := Width div 2;
            Y := Height div 2;
            try
              K := X div Step;
            except
              K := 1;
            end;
            H := Trunc(Y / K);
            for I := 1 to K - 1 do
            begin
              R1 := Rect(X - Step * I, Y - H * I, X + Step * I, Y + H * I);
              Canvas.CopyRect(R1, FBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { InsideOutside }

          dOutside2Inside:
          begin
            X := Width div 2;
            Y := Height div 2;
            try
              K := X div Step;
            except
              K := 1;
            end;
            H := Trunc(Y / K);
            Tmp := TBitmap.Create;
            try
              for I := K - 1 downto 1 do
              begin
                Tmp.Assign(FBitmap);
                R1 := Rect(X - Step * I, Y - H * I, X + Step * I, Y + H * I);
                Tmp.Canvas.CopyRect(R1, OldBitmap.Canvas, R1);
                Canvas.Draw(0, 0, Tmp);
                DoDelay(FDelay);
              end;
            finally
              Tmp.Free;
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { OutsideInside }
        else
          raise ExBitmapEffectError.Create('This direction is not implemented');
        end;
      end;

      efChessBoard:
      begin
        List := TList.Create;
        try
          W := Round(Width / Step);
          while List.Count < ((Width div W) + 1) * ((Height div W) + 1) do
          begin
            X := Random((Width div W) + 1);
            Y := Random((Height div W) + 1);

            B := False;
            for K := 0 to List.Count - 1 do
              if (PPoint(List[K])^.X = X) and (PPoint(List[K])^.Y = Y) then
              begin
                B := True;
                break;
              end;
            if B then continue;

            P := New(PPoint);
            P^.X := X;
            P^.Y := Y;
            List.Add(P);

            R1 := Rect(X * W, Y * W, X * W + W, Y * W + W);
            Canvas.CopyRect(R1, FBitmap.Canvas, R1);
            DoDelay(FDelay);
          end;
        finally
          for I := 0 to List.Count - 1 do
            Dispose(PPoint(List[I]));
          List.Free;
        end;
      end;

      efExplode:
      begin
        case FDirection of
          dLeft2Right:
          begin
            R1 := Rect(0, 0, Width, Height);
            for I := 1 to Step do
            begin
              R2 := Rect(0, 0, (Width div Step) * I, Height);
              Canvas.CopyRect(R2, FBitmap.Canvas, R1);
              R4 := Rect((Width div Step) * I, 0, Width, Height);
              Canvas.CopyRect(R4, OldBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Left2Right }

          dRight2Left:
          begin
            R1 := Rect(0, 0, Width, Height);
            for I := Step downto 1 do
            begin
              R2 := Rect(0, 0, (Width div Step) * I, Height);
              Canvas.CopyRect(R2, OldBitmap.Canvas, R1);
              R4 := Rect((Width div Step) * I, 0, Width, Height);
              Canvas.CopyRect(R4, FBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Right2Left }

          dTop2Bottom:
          begin
            R1 := Rect(0, 0, Width, Height);
            for I := 1 to Step do
            begin
              R2 := Rect(0, 0, Width, (Height div Step) * I);
              Canvas.CopyRect(R2, FBitmap.Canvas, R1);
              R4 := Rect(0, (Height div Step) * I, Width, Height);
              Canvas.CopyRect(R4, OldBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Top2Bottom }

          dBottom2Top:
          begin
            R1 := Rect(0, 0, Width, Height);
            for I := Step downto 1 do
            begin
              R2 := Rect(0, 0, Width, (Height div Step) * I);
              Canvas.CopyRect(R2, OldBitmap.Canvas, R1);
              R4 := Rect(0, (Height div Step) * I, Width, Height);
              Canvas.CopyRect(R4, FBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Top2Bottom }

          dInside2Outside:
          begin
            X := Width div 2;
            Y := Height div 2;
            R1 := Rect(0, 0, Width, Height);
            for I := 1 to Step do
            begin
              R2 := Rect(X - (X div Step) * I, Y - (Y div Step) * I,
                X + (X div Step) * I, Y + (Y div Step) * I);
              Canvas.CopyRect(R2, FBitmap.Canvas, R1);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end;

          dOutside2Inside:
          begin
            X := Width div 2;
            Y := Height div 2;
            R1 := Rect(0, 0, Width, Height);
            Tmp := TBitmap.Create;
            try
              for I := Step downto 1 do
              begin
                Tmp.Assign(FBitmap);
                R2 := Rect(X - (X div Step) * I, Y - (Y div Step) * I,
                  X + (X div Step) * I, Y + (Y div Step) * I);
                Tmp.Canvas.CopyRect(R2, OldBitmap.Canvas, R1);
                Canvas.Draw(0, 0, Tmp);
                DoDelay(FDelay);
              end;
            finally
              Tmp.Free;
            end;
            Canvas.Draw(0, 0, FBitmap);
          end;
        else
          raise ExBitmapEffectError.Create('The direction is not implemented');
        end;
      end; { efExplode }

      efSlide:
      begin
        case FDirection of
          dLeft2Right:
          begin
            R1 := Rect(0, 0, Width - Step, Height);
            R2 := Rect(Step, 0, Width, Height);
            R3 := Rect(0, 0, Step, Height);
            for I := 0 to (Width div Step) - 1 do
            begin
              Canvas.CopyRect(R2, Canvas, R1);
              R4 := Rect(Width - Step * I - Step, 0, Width - Step * I, Height);
              Canvas.CopyRect(R3, FBitmap.Canvas, R4);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Left2Right }

          dRight2Left:
          begin
            R1 := Rect(Step, 0, Width, Height);
            R2 := Rect(0, 0, Width - Step + 1, Height);
            R3 := Rect(Width - Step, 0, Width, Height);
            for I := 0 to (Width div Step) - 1 do
            begin
              Canvas.CopyRect(R2, Canvas, R1);
              R4 := Rect(Step * I, 0, Step * I + Step, Height);
              Canvas.CopyRect(R3, FBitmap.Canvas, R4);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Right2Left }

          dTop2Bottom:
          begin
            R1 := Rect(0, 0, Width, Height - Step);
            R2 := Rect(0, Step, Width, Height);
            R3 := Rect(0, 0, Width, Step);
            for I := 0 to (Height div Step) - 1 do
            begin
              Canvas.CopyRect(R2, Canvas, R1);
              R4 := Rect(0, Height - Step * I - Step, Width, Height - Step * I);
              Canvas.CopyRect(R3, FBitmap.Canvas, R4);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Top2Bottom }

          dBottom2Top:
          begin
            R1 := Rect(0, Step, Width, Height);
            R2 := Rect(0, 0, Width, Height - Step);
            R3 := Rect(0, Height - Step, Width, Height);
            for I := 0 to (Height div Step) - 1 do
            begin
              Canvas.CopyRect(R2, Canvas, R1);
              R4 := Rect(0, Step * I, Width, Step * I + Step);
              Canvas.CopyRect(R3, FBitmap.Canvas, R4);
              DoDelay(FDelay);
            end;
            Canvas.Draw(0, 0, FBitmap);
          end; { Bottom2Top }

        else
          raise ExBitmapEffectError.Create('Invalid direction for this effect');
        end;
      end; { efSlide }

      efShade:
      begin
        Br1Bm := TBitmap.Create;
        Br2Bm := TBitmap.Create;

        Bm1 := TBitmap.Create;
        Bm2 := TBitmap.Create;

        Tmp := TBitmap.Create;
        try
          for I := 1 to 8 do
          begin
            Bm1.Free;
            Bm2.Free;

            Bm1 := TBitmap.Create;
            Bm2 := TBitmap.Create;

            Br1Bm.LoadFromResourceName(hInstance, Format('bmeff_patt_%da', [I]));
            Br2Bm.LoadFromResourceName(hInstance, Format('bmeff_patt_%db', [I]));

            Bm1.Assign(OldBitmap);
            Bm1.Canvas.Brush.Bitmap := Br1Bm;
            BitBlt(Bm1.Canvas.Handle, 0, 0, Bm1.Width, Bm1.Height,
              OldBitmap.Canvas.Handle, 0, 0, MERGECOPY);

            Bm2.Assign(FBitmap);
            Bm2.Canvas.Brush.Bitmap := Br2Bm;
            BitBlt(Bm2.Canvas.Handle, 0, 0, Bm2.Width, Bm2.Height,
              FBitmap.Canvas.Handle, 0, 0, MERGECOPY);

            BitBlt(Bm1.Canvas.Handle, 0, 0, Bm1.Width, Bm1.Height,
              Bm2.Canvas.Handle, 0, 0, SRCPAINT);

            Canvas.CopyMode := srcCopy;
            Canvas.Draw(0, 0, Bm1);

//            MessageBox(0, 'aaa', 'bb', MB_OK);
            DoDelay(FDelay);
          end;

          for I := 7 downto 1 do
          begin
            Bm1.Free;
            Bm2.Free;

            Bm1 := TBitmap.Create;
            Bm2 := TBitmap.Create;

            Br1Bm.Handle := LoadBitmap(hInstance, StrFmt(S, 'bmeff_patt_%da', [I]));
            Br2Bm.Handle := LoadBitmap(hInstance, StrFmt(S, 'bmeff_patt_%db', [I]));

            Bm1.Assign(FBitmap);
            Bm1.Canvas.Brush.Bitmap := Br1Bm;
            BitBlt(Bm1.Canvas.Handle, 0, 0, Bm1.Width, Bm1.Height,
              FBitmap.Canvas.Handle, 0, 0, MERGECOPY);

            Bm2.Assign(OldBitmap);
            Bm2.Canvas.Brush.Bitmap := Br2Bm;
            BitBlt(Bm2.Canvas.Handle, 0, 0, Bm2.Width, Bm2.Height,
              OldBitmap.Canvas.Handle, 0, 0, MERGECOPY);

            BitBlt(Bm1.Canvas.Handle, 0, 0, Bm1.Width, Bm1.Height,
              Bm2.Canvas.Handle, 0, 0, SRCPAINT);

            Canvas.Draw(0, 0, Bm1);

//            MessageBox(0, 'aaa', 'bb', MB_OK);
            DoDelay(FDelay);
          end;

          Canvas.Draw(0, 0, FBitmap);
        finally
          Br1Bm.Free;
          Br2Bm.Free;

          Bm1.Free;
          Bm2.Free;

          Tmp.Free;
        end;
      end; { efShadow }

      efNone: Repaint;
    end; { case }
  finally
    ReEnterFlag := False;
  end;
end; { DoEffect }

procedure TxBitmapEffect.DoEffect;
begin
  _DoEffect;
end;

{ TxBitmapEffectEx -------------------------------------------------}

constructor TxBitmapEffectEx.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FHelpBitmap := TBitmap.Create;
end;

destructor TxBitmapEffectEx.Destroy;
begin
  FHelpBitmap.Free;
  inherited Destroy;
end;

procedure TxBitmapEffectEx.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  C: Boolean = True;
begin
  inherited MouseMove(Shift, X, Y);

  if C then
  begin
    Bitmap := HelpBitmap;
    C := False;
  end;
end;

procedure TxBitmapEffectEx.SetHelpBitmap(ABitmap: TBitmap);
begin
//  FHelpBitmap.Assign(ABitmap);
end;

{ Registration -----------------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-Misc', [TxBitmapEffect]);
  RegisterComponents('x-Misc', [TxBitmapEffectEx]);
end;

end.














