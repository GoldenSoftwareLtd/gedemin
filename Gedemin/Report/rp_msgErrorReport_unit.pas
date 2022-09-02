// ShlTanya, 27.02.2019

unit rp_msgErrorReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TmsgErrorReport = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Panel4: TPanel;
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FxtRect: TRect;

    procedure DataCalculation(var W, H: Integer);
    { Private declarations }
  public
    procedure MessageBox(AnCaption, AnText: String);
  end;

var
  msgErrorReport: TmsgErrorReport;

implementation

{$R *.DFM}

procedure TmsgErrorReport.MessageBox(AnCaption, AnText: String);
var
  W, H: Integer;
begin
  Caption := AnCaption;
  Label1.Caption := AnText;
  DataCalculation(W, H);
  H := Height;
  Height := Height + FxtRect.Bottom - FxtRect.Top - Label1.Height;
  if Height < H then
    Height := H;
  ShowModal;
end;

procedure TmsgErrorReport.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TmsgErrorReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TmsgErrorReport.DataCalculation(var W, H: Integer);
var
  B: TBitmap;
  M, K, {TB,} N, X, Y: Integer;
  S1, S2, S3, S4: String;
begin
  B := TBitmap.Create;
  try
    W := 0;
    H := 40;
    M := Label1.Width;
    B.Canvas.Font.Assign(Label1.Font);
//    if FShadow then
//      Inc(H, FShadowDepth);
    Inc(H, 32);
    S1 := Label1.Caption;
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
    if W > Label1.Width then
      W := Label1.Width;
    Inc(H, B.Canvas.TextHeight(Label1.Caption) * N);
//    TB := TestButton(HH, WidthButtons);
//    if TB > W then
//      W := TB;
    X := 0;
    Y := 0;
{    case FCallout of
      clLeft:
        X := CalloutSize;
      clTop:
        Y := 20;
    end;}
    if W < Label1.Width then
      W := Label1.Width;
{    Button1.Left := X + (W - WidthButtons) div 2;
    Button1.Top := Y + H - 10 - FShadowDepth;
    Button2.Left := Button1.Left + Button1.Width + 10;
    Button2.Top := Y + H - 10 - FShadowDepth;
    Button3.Left := Button2.Left + Button2.Width + 10;
    Button3.Top := Y + H - 10 - FShadowDepth;}
{    if TB <> 0 then
      Inc(H, HH);
    if (FCallout = clLeft) or (FCallout = clRight) then
      Inc(W, CalloutSize);
    if (FCallout = clTop) or (FCallout = clBottom) then
      Inc(H, CalloutSize);
    if FCallout = clLeft then
      X := CalloutSize;
    if FCallout = clTop then
      Y := CalloutSize;
}
    FxtRect.Left := X{ + 10};
    FxtRect.Top := {42 + }Y;
    FxtRect.Right := W{ - 10} + X;
    FxtRect.Bottom := {42 + }(N{ + 1}) * B.Canvas.TextHeight('a') + Y;
  finally
    B.Free;
  end;

//  Inc(W, FShadowDepth);
end;

end.
