unit xConectionWords;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TxConectionWords = class(TCustomControl)
  private
    Number, First, Second: Integer;
    FWallPaper: TBitmap;
    Down: Integer;
    FDrawWallPaper: Boolean;

    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMRButtonDown(var Message: TWMRButtonDown);
      message WM_RButtonDown;
    procedure WMRButtonUp(var Message: TWMRButtonUp);
      message WM_RButtonUp;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;

    procedure SetWallPaper(AWallPaper: TBitmap);
    procedure SetDrawWallPaper(ADrawWallPaper: Boolean);
    procedure ButtonUp;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
  public
    Y: array[0..4] of Integer;
    Conect: array[0..4, 0..4] of Integer;
    procedure Clear;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
    property WallPaper: TBitmap read FWallPaper write SetWallPaper;
    property DrawWallPaper: Boolean read FDrawWallPaper write SetDrawWallPaper;
  end;

procedure Register;

implementation

constructor TxConectionWords.Create(AnOwner: TComponent);
var
  I, T: Integer;
begin
  inherited Create(AnOwner);
  for I := 0 to 4 do
    for T := 0 to 4 do
    begin
      Y[I] := 25 + I * 50;
      Conect[I, T] := 0;
    end;
  Width := 37;
  Height := 254;
  Number := -1;
  FWallPaper := TBitmap.Create;
  First := -1;
  Second := -1;
  Down := 0;
  DrawWallPaper := True;
end;

destructor TxConectionWords.Destroy;
begin
  FWallPaper.Free;
  inherited Destroy;
end;

procedure TxConectionWords.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hbrBackground := 0;
end;

procedure TxConectionWords.Paint;
var
  I, T, K, D, DD: Integer;
begin
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := clBtnShadow;
  Canvas.Pen.Width := 2;
  if not FWallPaper.Empty and FDrawWallPaper then
    for I := 0 to Width div FWallPaper.Width do
      for K := 0 to Height div FWallPaper.Height do
        Canvas.Draw(I * FWallPaper.Width, K * FWallPaper.Height, FWallPaper)
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.Pen.Color := Color;
    Canvas.Rectangle(0, 0, Width, Height);
  end;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := clBtnShadow;
  Canvas.Pen.Width := 2;

  for I := 0 to 3 do
    for T := I + 1 to 4 do
    begin
      if Conect[I, T] <> 0 then
      begin
        D := (T - I) * 10;
        DD := 10 - (T - I) * 3;
        if Conect[I, T] = -1 then
          Canvas.Pen.Color := clRed
        else
          Canvas.Pen.Color := clBtnShadow;

        Canvas.MoveTo(0, Y[I] + DD);
        Canvas.LineTo(30 + D, Y[I] + DD);
        Canvas.LineTo(30 + D, Y[T] - DD);
        Canvas.LineTo(0, Y[T] - DD);
      end;
    end;
end;

procedure TxConectionWords.Clear;
var
  I, T: Integer;
begin
  for I := 0 to 4 do
    for T := 0 to 4 do
      Conect[I, T] := 0;
  Repaint;
end;

procedure TxConectionWords.WMMouseMove(var Message: TWMMouseMove);
var
  N: Integer;
begin
  inherited;
  MouseCapture := True;
  with Message do
  begin
    if (Down <> 0) and (First <> -1) then
    begin
      Repaint;
      Canvas.Pen.Style := psDot;
      Canvas.Pen.Width := 1;
      if Down = -1 then
        Canvas.Pen.Color := clRed
      else
        Canvas.Pen.Color := clBtnShadow;
      Canvas.MoveTo(0, Y[First]);
      Canvas.LineTo(50, Y[First]);
      Canvas.LineTo(50, YPos);
      Canvas.LineTo(0, YPos);
    end;
    if (XPos < 0) or (XPos > Width) or (YPos < 0) and (YPos > Height) then
    begin
      MouseCapture := False;
      Number := -1;
      Down := 0;
      Repaint;
    end
    else
    begin
      N := Trunc(YPos / 50);
      if (N <> Number) then
        Number := N;
    end;
  end;
end;

procedure TxConectionWords.SetWallPaper(AWallPaper: TBitmap);
begin
  FWallPaper.Assign(AWallPaper);
end;

procedure TxConectionWords.SetDrawWallPaper(ADrawWallPaper: Boolean);
begin
  FDrawWallPaper := ADrawWallPaper;
  Repaint;
end;

procedure TxConectionWords.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Number <> - 1 then
  begin
    First := Number;
    Down := 1;
  end;
end;

procedure TxConectionWords.ButtonUp;
var
  Temp: Integer;
  
  function Test: Boolean;
  var
    I, T: Integer;
  begin
    Result := True;
    for I := 0 to 3 do
      for T := I + 1 to 4 do
        if Conect[I, T] <> 0 then
          if ((First > I) and (First < T) and (Second > T)) or
             ((First < I) and (Second > I) and (Second < T)) then
            Result := False;
  end;

begin
  inherited;
  Second := Number;
  if First > Second then
  begin
    Temp := First;
    First := Second;
    Second := Temp;
  end;
  if (Down <> 0) and (Second <> First) and ((Second - First) < 4) and Test then
  begin
    Conect[First, Second] := Down;
    Conect[Second, First] := Down;
  end;
  First := -1;
  Second := -1;
  Down := 0;
  Number := -1;
  Repaint;
end;

procedure TxConectionWords.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  ButtonUp;
end;

procedure TxConectionWords.WMRButtonDown(var Message: TWMRButtonDown);
begin
  inherited;
  if Number <> - 1 then
  begin
    First := Number;
    Down := -1;
  end;
end;

procedure TxConectionWords.WMRButtonUp(var Message: TWMRButtonUp);
begin
  inherited;
  ButtonUp;
end;

procedure TxConectionWords.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure Register;
begin
  RegisterComponents('Advices', [TxConectionWords]);
end;

end.
