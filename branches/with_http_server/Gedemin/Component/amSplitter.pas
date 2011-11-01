unit amSplitter;

// -----------------------------------------------------------------------------
// Thanks Anders Melander for idea.
// -----------------------------------------------------------------------------

interface

uses
  Classes, Messages, Controls, ExtCtrls;

type
  TSplitter = class(ExtCtrls.TSplitter)
  private
    FPosSaved: Boolean;
    FPosMoved: Integer;

  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  Windows, Graphics;

const
  MouseThreshold = 22;

var
  LArr, RArr, TArr, BArr: TBitmap;

procedure TSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  R: TRect;
  CX, CY: integer;
begin
  R := ClientRect;
  if (Align in [alLeft, alRight]) then
  begin
    CY := (R.Top + R.Bottom) div 2;
    if Abs(Y - CY) < MouseThreshold then
    begin
      if FPosSaved then
      begin
        FPosSaved := False;
        inherited MouseDown(mbLeft, [], 0, 0);
        MouseMove([ssLeft], -FPosMoved, 0);
        MouseUp(mbLeft, [], -FPosMoved, 0);
      end else
      begin
        FPosMoved := -Left;
        FPosSaved := True;
        inherited MouseDown(mbLeft, [], 0, 0);
        MouseMove([ssLeft], FPosMoved, 0);
        MouseUp(mbLeft, [], FPosMoved, 0);
        FPosMoved := FPosMoved + Left;
      end;
    end else
      inherited;
  end else
  begin
    CX := (R.Left + R.Right) div 2;
    if Abs(X - CX) < MouseThreshold then
    begin
      if FPosSaved then
      begin
        FPosSaved := False;
        inherited MouseDown(mbLeft, [], 0, 0);
        MouseMove([ssLeft], 0, -FPosMoved);
        MouseUp(mbLeft, [], 0, -FPosMoved);
      end else
      begin
        FPosSaved := True;
        FPosMoved := -Top;
        inherited MouseDown(mbLeft, [], 0, 0);
        MouseMove([ssLeft], 0, FPosMoved);
        MouseUp(mbLeft, [], 0, FPosMoved);
        FPosMoved := FPosMoved + Top;
      end;
    end else
      inherited;
  end;
end;

procedure TSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
begin
  inherited;

  R := ClientRect;
  if Align in [alLeft, alRight] then
  begin
    if Abs(Y - ((R.Top + R.Bottom) div 2)) < MouseThreshold then
      Cursor := crDefault
    else
      Cursor := crHSplit;
  end else
  begin
    if Abs(X - ((R.Left + R.Right) div 2)) < MouseThreshold then
      Cursor := crDefault
    else
      Cursor := crVSplit;
  end;
end;

procedure TSplitter.Paint;
var
  R: TRect;
  CX, CY: integer;
begin
  R := ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  if (Align in [alLeft, alRight]) then
  begin
    CY := (R.Top + R.Bottom) div 2;
    if FPosSaved then
    begin
      Canvas.Draw((Width - RArr.Width) div 2, CY, RArr);
      Canvas.Draw((Width - RArr.Width) div 2, CY - 12, RArr);
      Canvas.Draw((Width - RArr.Width) div 2, CY + 12, RArr);
    end else
    begin
      Canvas.Draw((Width - LArr.Width) div 2, CY, LArr);
      Canvas.Draw((Width - LArr.Width) div 2, CY - 12, LArr);
      Canvas.Draw((Width - LArr.Width) div 2, CY + 12, LArr);
    end;
  end else
  begin
    CX := (R.Left + R.Right) div 2;
    if FPosSaved then
    begin
      Canvas.Draw(CX, (Height - BArr.Height) div 2, BArr);
      Canvas.Draw(CX + 12, (Height - BArr.Height) div 2, BArr);
      Canvas.Draw(CX - 12, (Height - BArr.Height) div 2, BArr);
    end else
    begin
      Canvas.Draw(CX, (Height - TArr.Height) div 2, TArr);
      Canvas.Draw(CX + 12, (Height - TArr.Height) div 2, TArr);
      Canvas.Draw(CX - 12, (Height - TArr.Height) div 2, TArr);
    end;
  end;
end;

initialization
  RArr := TBitmap.Create;
  RArr.Width := 4;
  RArr.Height := 5;
  RArr.Canvas.Brush.Color := clBtnShadow;
  RArr.Canvas.FillRect(Rect(0, 0, 3, 5));
  RArr.Canvas.Pixels[2, 0] := clBtnFace;
  RArr.Canvas.Pixels[3, 0] := clBtnFace;
  RArr.Canvas.Pixels[3, 1] := clBtnFace;
  RArr.Canvas.Pixels[3, 3] := clBtnFace;
  RArr.Canvas.Pixels[3, 4] := clBtnFace;
  RArr.Canvas.Pixels[2, 4] := clBtnFace;
  RArr.Canvas.Pixels[1, 0] := clBtnHighlight;
  RArr.Canvas.Pixels[2, 1] := clBtnHighlight;
  RArr.Canvas.Pixels[3, 2] := clBtnHighlight;
  RArr.Canvas.Pixels[2, 3] := clBtnHighlight;
  RArr.Canvas.Pixels[1, 4] := clBtnHighlight;
  RArr.Canvas.Pixels[0, 5] := clBtnHighlight;

  LArr := TBitmap.Create;
  LArr.Width := 4;
  LArr.Height := 5;
  LArr.Canvas.Brush.Color := clBtnShadow;
  LArr.Canvas.FillRect(Rect(0, 0, 3, 5));
  LArr.Canvas.Pixels[0, 0] := clBtnFace;
  LArr.Canvas.Pixels[0, 1] := clBtnFace;
  LArr.Canvas.Pixels[1, 0] := clBtnFace;
  LArr.Canvas.Pixels[3, 0] := clBtnFace;
  LArr.Canvas.Pixels[0, 4] := clBtnFace;
  LArr.Canvas.Pixels[0, 5] := clBtnFace;
  LArr.Canvas.Pixels[1, 5] := clBtnFace;
  LArr.Canvas.Pixels[0, 3] := clBtnHighlight;
  LArr.Canvas.Pixels[1, 4] := clBtnHighlight;
  LArr.Canvas.Pixels[3, 4] := clBtnHighlight;
  LArr.Canvas.Pixels[3, 3] := clBtnHighlight;
  LArr.Canvas.Pixels[3, 2] := clBtnHighlight;
  LArr.Canvas.Pixels[3, 1] := clBtnHighlight;

  TArr := TBitmap.Create;
  TArr.Width := 5;
  TArr.Height := 4;
  TArr.Canvas.Brush.Color := clBtnShadow;
  TArr.Canvas.FillRect(Rect(0, 0, 5, 3));
  TArr.Canvas.Pixels[0, 0] := clBtnFace;
  TArr.Canvas.Pixels[0, 1] := clBtnFace;
  TArr.Canvas.Pixels[1, 0] := clBtnFace;
  TArr.Canvas.Pixels[4, 0] := clBtnFace;
  TArr.Canvas.Pixels[3, 0] := clBtnHighlight;
  TArr.Canvas.Pixels[4, 1] := clBtnHighlight;
  TArr.Canvas.Pixels[0, 3] := clBtnHighlight;
  TArr.Canvas.Pixels[1, 3] := clBtnHighlight;
  TArr.Canvas.Pixels[2, 3] := clBtnHighlight;
  TArr.Canvas.Pixels[3, 3] := clBtnHighlight;
  TArr.Canvas.Pixels[4, 3] := clBtnHighlight;

  BArr := TBitmap.Create;
  BArr.Width := 5;
  BArr.Height := 4;
  BArr.Canvas.Brush.Color := clBtnShadow;
  BArr.Canvas.FillRect(Rect(0, 0, 5, 3));
  BArr.Canvas.Pixels[0, 1] := clBtnFace;
  BArr.Canvas.Pixels[0, 2] := clBtnFace;
  BArr.Canvas.Pixels[0, 3] := clBtnFace;
  BArr.Canvas.Pixels[1, 2] := clBtnFace;
  BArr.Canvas.Pixels[1, 3] := clBtnFace;
  BArr.Canvas.Pixels[3, 3] := clBtnFace;
  BArr.Canvas.Pixels[4, 2] := clBtnFace;
  BArr.Canvas.Pixels[4, 3] := clBtnFace;
  BArr.Canvas.Pixels[2, 3] := clBtnHighlight;
  BArr.Canvas.Pixels[3, 2] := clBtnHighlight;
  BArr.Canvas.Pixels[4, 1] := clBtnHighlight;

finalization
  LArr.Free;
  RArr.Free;
  TArr.Free;
  BArr.Free;
end.
