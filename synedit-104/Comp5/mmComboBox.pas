   
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmComboBox.pas

  Abstract

    Original ComboBox without nasty Ctl3d.

  Author

    Romanovski Denis (17-04-99)

  Revisions history

    Initial  17-04-99  Dennis  Initial version.

    Beta1    22-04-99  Dennis  Everything like in Microsoft Money!
--}

unit mmComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls;

type
  TmmComboBox = class(TComboBox)
  private
    Pressed, Active: Boolean; // ����� ��������� ������
    FColorBt: TColor;

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

    procedure SetColorBt(const Value: TColor);

  protected
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
      ComboProc: Pointer); override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property ColorBt: TColor read FColorBt write SetColorBt default $0094A2A5;
  end;

type
  TmmDBComboBox = class(TDBComboBox)
  private
    Pressed, Active: Boolean; // ����� ��������� ������

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
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
      ComboProc: Pointer); override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
  end;

implementation

{
  ������ �� ����� � Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

{
  -----------------------------
  ---   TmmComboBox Class   ---
  -----------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  ������ ��������� ���������.
}

constructor TmmComboBox.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FColorBt := $0094A2A5;
  Pressed := False;
  Active := False;
end;


{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  ������������� ��������� � ������������ ������� � �������� ������� �
  ���������� �� ��������� ����� �����������.
}

procedure TmmComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
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

  inherited ComboWndProc(Message, ComboWnd, ComboProc);
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  � ���� ������ � ��������� �������������� �����������, �.�. ����� ����������
  ������� ��� API �������.
}

procedure TmmComboBox.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawBody;
end;

{
  ������� ����� ������ ����. ���������� �����������.
}

procedure TmmComboBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  Pressed := True;
  DrawBody;
end;

{
  ����������� ����� ������ ����. ���������� �����������.
}

procedure TmmComboBox.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Pressed := False;
  DrawBody;
end;

{
  ������ ������ � �������. ���������� �����������.
}

procedure TmmComboBox.CMMouseEnter(var Message: TMessage);
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
  ������ ������� �� ��������. ���������� �����������.
}

procedure TmmComboBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if Active then
  begin
    Active := False;
    DrawBody;
  end;
end;

{
  �������� ���� ������ ��������. ���������� �����������.
}

procedure TmmComboBox.WMMouseMove(var Message: TWMMouseMove);
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
  ������ �������� ����� ��������.
}

procedure TmmComboBox.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
var
  DC: hDC;
  Wnd: hWnd;
  Brsh, BlackBrsh, ButtonBrsh: hBrush;
  Pen, BlackPen, OldPen: hPen;
  LB: LOGBRUSH;
  P: TPoint;
begin
  if Ctl3d or not HandleAllocated then Exit;
//  if Ctl3d then Exit;

  if WithDC then
    DC := PaintDC
  else 
    DC := GetDeviceContext(Wnd);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := ColorToRGB(Color);
  Brsh := CreateBrushIndirect(LB);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := RGB(0, 0, 0);
  BlackBrsh := CreateBrushIndirect(LB);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := ColorToRGB(FColorBt);//RGB(165, 162, 148);
  ButtonBrsh := CreateBrushIndirect(LB);

  if (Active and not DroppedDown) or Pressed then
    Pen := CreatePen(PS_SOLID, 1, ColorToRGB(Color))
  else
    Pen := CreatePen(PS_SOLID, 1, RGB(0, 0, 0));

  BlackPen := CreatePen(PS_SOLID, 1, RGB(0, 0, 0));

  try
    FrameRect(DC, Rect(0, 0, Width, Height), BlackBrsh);
    FrameRect(DC, Rect(1, 1, Width - 1, Height - 1), Brsh);

    if Pressed then
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), BlackBrsh)
    else
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), ButtonBrsh);

    DrawTriangle(DC, Pen);

    OldPen := SelectObject(DC, BlackPen);

    MoveToEx(DC, Width - 18, 0, @P);
    LineTo(DC, Width - 18, Height);
    MoveToEx(DC, P.X, P.Y, @P);

    SelectObject(DC, OldPen);

  finally
    DeleteObject(Brsh);
    DeleteObject(BlackBrsh);
    DeleteObject(ButtonBrsh);

    DeleteObject(BlackPen);
    DeleteObject(Pen);

    if not WithDC then ReleaseDC(Handle, DC);
  end;
end;

{
  ������ �����������.
}

procedure TmmComboBox.DrawTriangle(DC: hDC; Pen: hPen);
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

procedure TmmComboBox.SetColorBt(const Value: TColor);
begin
  if FColorBt <> Value then
  begin
    FColorBt := Value;
    Repaint;
  end;  
end;

{
  -----------------------------
  ---   TmmDBComboBox Class   ---
  -----------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  ������ ��������� ���������.
}

constructor TmmDBComboBox.Create(AnOwner: TComponent);
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
  ������������� ��������� � ������������ ������� � �������� ������� �
  ���������� �� ��������� ����� �����������.
}

procedure TmmDBComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
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

  inherited ComboWndProc(Message, ComboWnd, ComboProc);
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  � ���� ������ � ��������� �������������� �����������, �.�. ����� ����������
  ������� ��� API �������.
}

procedure TmmDBComboBox.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawBody;
end;

{
  ������� ����� ������ ����. ���������� �����������.
}

procedure TmmDBComboBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  Pressed := True;
  DrawBody;
end;

{
  ����������� ����� ������ ����. ���������� �����������.
}

procedure TmmDBComboBox.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Pressed := False;
  DrawBody;
end;

{
  ������ ������ � �������. ���������� �����������.
}

procedure TmmDBComboBox.CMMouseEnter(var Message: TMessage);
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
  ������ ������� �� ��������. ���������� �����������.
}

procedure TmmDBComboBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if Active then
  begin
    Active := False;
    DrawBody;
  end;
end;

{
  �������� ���� ������ ��������. ���������� �����������.
}

procedure TmmDBComboBox.WMMouseMove(var Message: TWMMouseMove);
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
  ������ �������� ����� ��������.
}

procedure TmmDBComboBox.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
var
  DC: hDC;
  Wnd: hWnd;
  Brsh, BlackBrsh, ButtonBrsh: hBrush;
  Pen, BlackPen, OldPen: hPen;
  LB: LOGBRUSH;
  P: TPoint;
begin
  if Ctl3d then Exit;

  if WithDC then
    DC := PaintDC
  else
    DC := GetDeviceContext(Wnd);

  LB.lbStyle := BS_SOLID;
  LB.lbColor := ColorToRGB(Color);
  Brsh := CreateBrushIndirect(LB);

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
    FrameRect(DC, Rect(0, 0, Width, Height), BlackBrsh);
    FrameRect(DC, Rect(1, 1, Width - 1, Height - 1), Brsh);

    if Pressed then
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), BlackBrsh)
    else
      FillRect(DC, Rect(Width - 18, 1, Width - 1, Height - 1), ButtonBrsh);

    DrawTriangle(DC, Pen);

    OldPen := SelectObject(DC, BlackPen);

    MoveToEx(DC, Width - 18, 0, @P);
    LineTo(DC, Width - 18, Height);
    MoveToEx(DC, P.X, P.Y, @P);

    SelectObject(DC, OldPen);

  finally
    DeleteObject(Brsh);
    DeleteObject(BlackBrsh);
    DeleteObject(ButtonBrsh);

    DeleteObject(BlackPen);
    DeleteObject(Pen);

    if not WithDC then ReleaseDC(Handle, DC);
  end;
end;

{
  ������ �����������.
}

procedure TmmDBComboBox.DrawTriangle(DC: hDC; Pen: hPen);
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

end.

