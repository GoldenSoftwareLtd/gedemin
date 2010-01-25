
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmCheckBoxEx.pas

  Abstract

    Original CheckBox without nasty Ctl3d.

  Author

    Romanovski Denis (22-04-99)

  Revisions history

    Initial  22-04-99  Dennis  Initial version.
    
    Initial  24-04-99  Dennis  Everything works.
    
--}

unit mmCheckBoxEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, imgList, DBCtrls;

type
  TmmCheckBoxEx = class(TCheckBox)
  private
    IsActive: Boolean;
    IsPressed: Boolean;
    BMP: TBitmap;

    procedure WMPaint(var Message: TWMPaint);
      message WM_PAINT;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;

    procedure DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;

type
  TmmDBCheckBoxEx = class(TDBCheckBox)
  private
    IsActive: Boolean;
    IsPressed: Boolean;
    BMP: TBitmap;

    procedure WMPaint(var Message: TWMPaint);
      message WM_PAINT;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;

    procedure DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('x-Button', [TmmCheckBoxEx]);
end;


{
  -------------------------------
  ---   TmmCheckBoxEx Class   ---
  -------------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmCheckBoxEx.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  IsActive := False;
  isPressed := False;

  BMP := TBitmap.Create;
  BMP.Width := 13;
  BMP.Height := 14;
end;

{
  Высвобождаем память.
}

destructor TmmCheckBoxEx.Destroy;
begin
  BMP.Free;
  inherited Destroy;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Обрабатываем все необходимые сообщения.
}

procedure TmmCheckBoxEx.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);

  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK: IsPressed := True;
    WM_LBUTTONUP: IsPressed := False;
    WM_KEYFIRST..WM_KEYLAST: if Focused then DrawBody;
    BM_SETCHECK, WM_SETTEXT, WM_ENABLE: DrawBody;
  end;

  if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then DrawBody;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производим перерисовку.
}

procedure TmmCheckBoxEx.WMPaint(var Message: TWMPaint);
begin
//  Font.CharSet := RUSSIAN_CHARSET; 

  inherited;
  DrawBody;
end;

{
  По входу мыши в контрол производим его перерисовку.
}

procedure TmmCheckBoxEx.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  IsActive := True;
  DrawBody;
end;

{
  По выходу мыши из контрола производим его перерисовку.
}

procedure TmmCheckBoxEx.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  IsActive := False;
  DrawBody;
end;

{
  Производим прорисовку контрола самостоятельно.
}

procedure TmmCheckBoxEx.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);  
var
  DC: hDC;
  Wnd: hWnd;
  X, Y: Integer;
  BackBrsh: hBrush;
  LB: LOGBRUSH;

  // Производит рисоваине CheckBox-а
  procedure DrawCheckRect(DrawDC: hDC);
  var
    CheckBackBrsh, OldBrsh: hBrush;
    P1, P2: TPoint;
  begin
    if ((IsActive and not IsPressed) or (not IsActive and IsPressed)) and not
      (csDesigning in ComponentState)
    then
      CheckBackBrsh := GetStockObject(LTGRAY_BRUSH)
    else
      CheckBackBrsh := GetStockObject(WHITE_BRUSH);

    FillRect(DrawDC, Rect(0, 0, 13, 13), CheckBackBrsh);
    FrameRect(DrawDC, Rect(0, 0, 13, 13), BackBrsh);

    FillRect(DrawDC, Rect(0, 13, 14, 15), BackBrsh);
    FrameRect(DrawDC, Rect(1, 1, 12, 12), GetStockObject(BLACK_BRUSH));

    if (Checked and not IsPressed) or (not Checked and IsPressed and IsActive) or
      (Checked and IsPressed and not IsActive) then
    begin
      OldBrsh := SelectObject(DrawDC, GetStockObject(BLACK_BRUSH));

      MoveToEx(DrawDC, 3, 7, @P1);
      LineTo(DrawDC, 5, 9);
      LineTo(DrawDC, 10, 4);

      MoveToEx(DrawDC, 3, 6, @P2);
      LineTo(DrawDC, 5, 8);
      LineTo(DrawDC, 10, 3);

      MoveToEx(DrawDC, 3, 5, @P2);
      LineTo(DrawDC, 5, 7);
      LineTo(DrawDC, 10, 2);

      MoveToEx(DrawDC, P1.X, P1.Y, @P2);
      SelectObject(DrawDC, OldBrsh);
    end;
  end;

begin
  if Ctl3d or not HandleAllocated then Exit;

  if WithDC then
    DC := PaintDC
  else
    DC := GetDeviceContext(Wnd);

  try
    LB.lbStyle := BS_SOLID;
    LB.lbColor := ColorToRGB(Color);
    BackBrsh := CreateBrushIndirect(LB);

    if Alignment = taLeftJustify then
      X := Width - 13
    else
      X := 0;

    Y := Height div 2 - 7;

    // При рисовании используем Bitmap для избавления от мигания
    DrawCheckRect(BMP.Canvas.Handle);
    BitBlt(DC, X, Y, 13, 14, BMP.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    DeleteObject(BackBrsh);
    if not WithDC then ReleaseDC(Handle, DC);
  end;
end;


{
  ---------------------------------
  ---   TmmDBCheckBoxEx Class   ---
  ---------------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmDBCheckBoxEx.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  IsActive := False;
  isPressed := False;

  BMP := TBitmap.Create;
  BMP.Width := 13;
  BMP.Height := 13;
end;

{
  Высвобождаем память.
}

destructor TmmDBCheckBoxEx.Destroy;
begin
  BMP.Free;
  inherited Destroy;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Обрабатываем все необходимые сообщения.
}

procedure TmmDBCheckBoxEx.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);

  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK: IsPressed := True;
    WM_LBUTTONUP: IsPressed := False;
    WM_KEYFIRST..WM_KEYLAST: if Focused then DrawBody;
    BM_SETCHECK, WM_SETTEXT, WM_ENABLE: DrawBody;
  end;

  if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then DrawBody;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производим перерисовку.
}

procedure TmmDBCheckBoxEx.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawBody;
end;

{
  По входу мыши в контрол производим его перерисовку.
}

procedure TmmDBCheckBoxEx.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  IsActive := True;
  DrawBody;
end;

{
  По выходу мыши из контрола производим его перерисовку.
}

procedure TmmDBCheckBoxEx.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  IsActive := False;
  DrawBody;
end;

{
  Производим прорисовку контрола самостоятельно.
}

procedure TmmDBCheckBoxEx.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);  
var
  DC: hDC;
  Wnd: hWnd;
  X, Y: Integer;
  BackBrsh: hBrush;
  LB: LOGBRUSH;

  // Производит рисоваине CheckBox-а
  procedure DrawCheckRect(DrawDC: hDC);
  var
    CheckBackBrsh, OldBrsh: hBrush;
    P1, P2: TPoint;
  begin
    if ((IsActive and not IsPressed) or (not IsActive and IsPressed)) and not
      (csDesigning in ComponentState)
    then
      CheckBackBrsh := GetStockObject(LTGRAY_BRUSH)
    else
      CheckBackBrsh := GetStockObject(WHITE_BRUSH);

    FillRect(DrawDC, Rect(0, 0, 13, 13), CheckBackBrsh);
    FrameRect(DrawDC, Rect(0, 0, 13, 13), BackBrsh);
    FrameRect(DrawDC, Rect(1, 1, 12, 12), GetStockObject(BLACK_BRUSH));

    if (Checked and not IsPressed) or (not Checked and IsPressed and IsActive) or
      (Checked and IsPressed and not IsActive) then
    begin
      OldBrsh := SelectObject(DrawDC, GetStockObject(BLACK_BRUSH));

      MoveToEx(DrawDC, 3, 7, @P1);
      LineTo(DrawDC, 5, 9);
      LineTo(DrawDC, 10, 4);

      MoveToEx(DrawDC, 3, 6, @P2);
      LineTo(DrawDC, 5, 8);
      LineTo(DrawDC, 10, 3);

      MoveToEx(DrawDC, 3, 5, @P2);
      LineTo(DrawDC, 5, 7);
      LineTo(DrawDC, 10, 2);

      MoveToEx(DrawDC, P1.X, P1.Y, @P2);
      SelectObject(DrawDC, OldBrsh);
    end;
  end;

begin
  if Ctl3d or not HandleAllocated then Exit;
  
  if WithDC then
    DC := PaintDC
  else
    DC := GetDeviceContext(Wnd);

  try
    LB.lbStyle := BS_SOLID;
    LB.lbColor := ColorToRGB(Color);
    BackBrsh := CreateBrushIndirect(LB);

    if Alignment = taLeftJustify then
      X := Width - 13
    else
      X := 0;
      
    Y := Height div 2 - 6; 

    // При рисовании используем Bitmap для избавления от мигания
    DrawCheckRect(BMP.Canvas.Handle);
    BitBlt(DC, X, Y, 13, 14, BMP.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    DeleteObject(BackBrsh);
    if not WithDC then ReleaseDC(Wnd, DC);
  end;
end;

end.

