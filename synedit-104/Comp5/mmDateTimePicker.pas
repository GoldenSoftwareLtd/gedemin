
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDateTimePicker.pas

  Abstract

    Original DateTimePicker without nasty Ctl3d.

  Author

    Romanovski Denis (17-04-99)

  Revisions history

    Initial  17-04-99  Dennis  Initial version.

    Beta1    22-04-99  Dennis  Everything like in Microsoft Money!


  НЕ РАБОТАЕТ!
  НЕ РАБОТАЕТ!
  НЕ РАБОТАЕТ!
  НЕ РАБОТАЕТ!
  НЕ РАБОТАЕТ!
  НЕ РАБОТАЕТ!
-}

unit mmDateTimePicker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ComCtrls, ExtCtrls;

type
  TmmDateTimePicker = class(TDateTimePicker)
  private
    Pressed, Active: Boolean; // Флаги состояния кнопки

    procedure WMPaint(var Message: TWMPaint);
      message WM_PAINT;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;

    procedure DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
    procedure DrawTriangle(DC: hDC; Pen: hPen);

  protected
    procedure WndProc(var Message: TMessage); override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
  end;

procedure Register;

implementation

{
  Входит ли точка в Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

{
  -----------------------------
  ---   TmmDateTimePicker Class   ---
  -----------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  Делаем начальные установки.
}

constructor TmmDateTimePicker.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Pressed := False;
  Active := False;
end;


{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  Перехватываем сообщение о передвижении курсора в контроле вручную и
  производим на основании этого перерисовку.
}

procedure TmmDateTimePicker.WndProc(var Message: TMessage);
var
  P: TPoint;
begin
  if Message.Msg = WM_MOUSEMOVE then
  begin

    GetCursorPos(P);
    P := ScreenToClient(P);

    if IsInRect(Rect(Width - 18, 1, Width - 1, Height - 1), P.X, P.Y) then
    begin
      Active := True;
      DrawBody;
    end else if Active then
    begin
      Active := False;
      DrawBody;
    end;
  end;

  inherited WndProc(Message);
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  В этом методу я произвожу самстоятельную перерисовку, т.к. этого невозможно
  сделать без API функций.
}

procedure TmmDateTimePicker.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawBody;
end;

{
  Нажаите левой кнопки мыши. Производим перерисовку.
}

procedure TmmDateTimePicker.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  Pressed := True;
  DrawBody;
end;

{
  Отпускается левая кнопка мыши. Производим перерисовку.
}

procedure TmmDateTimePicker.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Pressed := False;
  DrawBody;
end;

{
  Курсор входит в контрол. Производим перерисовку.
}

procedure TmmDateTimePicker.CMMouseEnter(var Message: TMessage);
var
  P: TPoint;
begin
  inherited;

  GetCursorPos(P);
  P := ScreenToClient(P);

  if not Active and IsInRect(Rect(Width - 18, 1, Width - 1, Height - 1), P.X, P.Y) then
  begin
    Active := True;
    DrawBody;
  end else if Active then
  begin
    Active := False;
    DrawBody;
  end;
end;

{
  Курсор выходит из контрола. Производим перерисовку.
}

procedure TmmDateTimePicker.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if Active then
  begin
    Active := False;
    DrawBody;
  end;
end;

{
  Движение мыши внутри контрола. Произвлдим перерисовку.
}

procedure TmmDateTimePicker.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;

  if IsInRect(Rect(Width - 18, 1, Width - 1, Height - 1), Message.XPos, Message.YPos) then
  begin
    Active := True;
    DrawBody;
  end else if Active then
  begin
    Active := False;
    DrawBody;
  end;
end;

{
  Рисуем отделные части контрола.
}

procedure TmmDateTimePicker.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
var
  DC: hDC;
  Wnd: hWnd;
  Brsh, BlackBrsh, ButtonBrsh, ParentBrsh: hBrush;
  Pen, BlackPen, OldPen: hPen;
  LB: LOGBRUSH;
  P: TPoint;
  S: array[0..254] of Char;
  I: Integer;
begin
//  if Ctl3d or not HandleAllocated then Exit;
//  if Ctl3d then Exit;

  if WithDC then
    DC := PaintDC
  else begin
//    DC := GetDeviceContext(Wnd);
{
    if csDesigning in ComponentState then
      DC := GetDCEx(GetParent(Handle), 0, DCX_CACHE or DCX_CLIPSIBLINGS)
    else
      DC := GetDC(GetParent(Handle));
}

    if csDesigning in ComponentState then
      DC := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS)
    else
      DC := GetDC(Handle);
  end;

  LB.lbStyle := BS_SOLID;
  LB.lbColor := ColorToRGB(Color);
  Brsh := CreateBrushIndirect(LB);

  LB.lbStyle := BS_SOLID;
  if Parent is TForm then
    LB.lbColor := ColorToRGB((Parent as TForm).Color)
  else
    LB.lbColor := ColorToRGB((Parent as TPanel).Color);
  ParentBrsh := CreateBrushIndirect(LB);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := RGB(0, 0, 0);
  BlackBrsh := CreateBrushIndirect(LB);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := RGB(165, 162, 148);
  ButtonBrsh := CreateBrushIndirect(LB);

  if (Active and not DroppedDown) or Pressed then
    Pen := CreatePen(PS_SOLID, 1, ColorToRGB(Color))
  else
    Pen := CreatePen(PS_SOLID, 1, RGB(0, 0, 0));

  BlackPen := CreatePen(PS_SOLID, 1, RGB(0, 0, 0));

  try
//    FrameRect(DC, Rect(0, 0, Width, Height), BlackBrsh);
{    FrameRect(DC, Rect(0, 0, Width, Height), Brsh);
    FrameRect(DC, Rect(1, 1, Width - 1, Height - 1), Brsh);
    FrameRect(DC, Rect(2, 2, Width - 2, Height - 2), Brsh);
    FrameRect(DC, Rect(3, 3, Width - 3, Height - 3), Brsh);}

    FillRect(DC, Rect(-1, -1, Width + 1, Height + 1), ParentBrsh);
{
    if Pressed then
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), BlackBrsh)
    else
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), ButtonBrsh);

    DrawTriangle(DC, Pen);

    OldPen := SelectObject(DC, BlackPen);

    MoveToEx(DC, Width - 18, 0, @P);
    LineTo(DC, Width - 18, Height);
    MoveToEx(DC, P.X, P.Y, @P);

    SelectObject(DC, OldPen);}

  finally
    DeleteObject(Brsh);
    DeleteObject(BlackBrsh);
    DeleteObject(ButtonBrsh);
    DeleteObject(ParentBrsh);

    DeleteObject(BlackPen);
    DeleteObject(Pen);

    if not WithDC then ReleaseDC(Handle, DC);
  end;
end;

{
  Рисуем треугольник.
}

procedure TmmDateTimePicker.DrawTriangle(DC: hDC; Pen: hPen);
var
  OldPen: hPen;
  P, P2: TPoint;
begin
  OldPen := SelectObject(DC, Pen);

  MoveToEx(DC, Width - 12, Height div 2 - 1, @P);
  LineTo(DC, Width - 7, Height div 2 - 1);

  MoveToEx(DC, Width - 11, Height div 2, @P2);
  LineTo(DC, Width - 8, Height div 2);

  MoveToEx(DC, Width - 10, Height div 2 + 1, @P2);
  LineTo(DC, Width - 9, Height div 2);

  MoveToEx(DC, P.X, P.Y, @P2);

  SelectObject(DC, OldPen);
end;

{
  ******************************
  ***   Register procedure   ***
  ******************************
}


procedure Register;
begin
  RegisterComponents('x-VisualControl', [TmmDateTimePicker]);
end;

end.

