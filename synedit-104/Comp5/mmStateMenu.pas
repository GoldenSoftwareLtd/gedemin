
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmStateMenu.pas

  Abstract

    Special panel with menu. A label is on the panel. It shows current
    state of the menu.

  Author

    Romanovski Denis (21-01-99)

  Revisions history

    Initial  21-01-99  Dennis  Initial version.

    Beta1    22-01-99  Dennis  Beta version. Everything works.
    
    Beta2    04-02-99  Dennis  Beta version. Notification method added.
--}

unit mmStateMenu;

interface

uses
  Windows,      Messages,     SysUtils,     Classes,      Graphics,
  Controls,     Forms,        Dialogs,      mmTopPanel,   Menus;

const
  DefLightLiter = $00C0C0C0;
  DefLowLiter = clWhite;
  DefWindowColor = $009C6331;

type
  TmmStateMenu = class(TmmPanel)
  private
    FColorLowLiter: TColor; // Цвет надписи в обычном состоянии
    FColorLightLiter: TColor; // Цвет нажатой надписи
    FMouseIn: Boolean; // Мышь в пределах компоненты
    FMenuActive: Boolean; // Активировано ли меню?
    FStatePopupMenu: TPopupMenu; // Меню для работы
    FPrefix: String; // Приставка к строке состояния меню

    procedure SetColorLowLiter(const Value: TColor);
    procedure SetStatePopupMenu(const Value: TPopupMenu);
    procedure SetPrefix(const Value: String);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMCommand(var Message: TWMCommand);
      message WM_COMMAND;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;

    function MakeMenuState: String;

  protected
    procedure Paint; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure AdjustAppearance; override;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure UpdateComponentState;

  published
    // Цвет надписи в нажатом состоянии
    property ColorLightLiter: TColor read FColorLightLiter write FColorLightLiter
      default DefLightLiter;
    // Цвет надписи в обычном состоянии
    property ColorLowLiter: TColor read FColorLowLiter write SetColorLowLiter
      default DefLowLiter;
    // Меню по левой кнопке мыши
    property StatePopupMenu: TPopupMenu read FStatePopupMenu write SetStatePopupMenu;
    // Текст, идущий перед текстом состояния меню
    property Prefix: String read FPrefix write SetPrefix;
  end;

implementation


{
   ***********************
   ***   Public Part   ***
   ***********************
}

{
  В конструктре делаем начальные установки.
}

constructor TmmStateMenu.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FMouseIn := False;
  FStatePopupMenu := nil;
  FMenuActive := False;

  FColorLightLiter := DefLightLiter;
  FColorLowLiter := DefLowLiter;
  Color := DefWindowColor;
  Align := alTop;
  Alignment := taLeftJustify;
  Height := 20;
  FPrefix := 'Состояние: ';
end;

{
  Производим перерисовку состояния компоненты.
}

procedure TmmStateMenu.UpdateComponentState;
var
  R: TRect;
  Text: array[0..255] of Char;
  S: String;

  procedure DrawTriAngle(X, Y: Integer);
  begin
    Canvas.Pen.Color := Canvas.Font.Color;

    Canvas.MoveTo(X, Y + 5);
    Canvas.LineTo(X + 7, Y + 5);

    Canvas.MoveTo(X + 1, Y + 6);
    Canvas.LineTo(X + 6, Y + 6);

    Canvas.MoveTo(X + 2, Y + 7);
    Canvas.LineTo(X + 5, Y + 7);

    Canvas.Pixels[X + 3, Y + 8] := Canvas.Font.Color;

    Canvas.MoveTo(X + 13, Y + 1);
    Canvas.LineTo(X + 13, Y + 13);
  end;
begin
  with Canvas do
  begin

    Brush.Style := bsSolid;
    Brush.Color := Color;

    R := ClientRect;
    Canvas.FillRect(R);
    Canvas.Font := Self.Font;

    if FMouseIn then
      Canvas.Font.Color := FColorLightLiter
    else
      Canvas.Font.Color := FColorLowLiter;

    DrawTriangle(R.Left + 7, (R.Bottom - R.Top) div 2 - 7);

    Inc(R.Left, 28);
    Dec(R.Right, 2);

    S := MakeMenuState;

    DrawText(
      Canvas.Handle,
      StrPCopy(Text, S),
      Length(S),
      R,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE
    );
  end
end;


{
   **************************
   ***   Protected Part   ***
   **************************
}


{
  Производим перерисовку содержимого окна компоненты.
}

procedure TmmStateMenu.Paint;
begin
  UpdateComponentState;
end;

{
  Отслеживаем удаление PopupMenu.
}

procedure TmmStateMenu.Notification(AComponent: TComponent; Operation: TOperation); 
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FStatePopupMenu) then
    FStatePopupMenu := nil;
end;

{
  Устанавливаем цвет Interface manager-а.
}

procedure TmmStateMenu.AdjustAppearance;
begin
  if Assigned(FInterfaceManager) then
  begin
    Color := FInterfaceManager.ThemeColor;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Устанавливаем property ColorLowLeter.
}

procedure TmmStateMenu.SetColorLowLiter(const Value: TColor);
begin
  FColorLowLiter := Value;
  UpdateComponentState;
end;

{
  Устанавливает popup menu, который будет использоваться в дальнейшем
  компонентой
}

procedure TmmStateMenu.SetStatePopupMenu(const Value: TPopupMenu);
begin
  FStatePopupMenu := Value;
  UpdateComponentState;
end;

{
  Устанавливает приставку с начала строки к состоянию меню.
}

procedure TmmStateMenu.SetPrefix(const Value: String);
begin
  FPrefix := Value;
  UpdateComponentState;
end;

{
  По нажатию кнопки мыши производим активацию меню.
}

procedure TmmStateMenu.WMLButtonDown(var Message: TWMLButtonDown);
var
  P: TPoint;
begin
  inherited;

  if not FMenuActive and (FStatePopupMenu <> nil) then
  begin
    P := ClientToScreen(Point(0, Height));

    FMenuActive := True;
    FMouseIn := False;
    UpdateComponentState;

    TrackPopupMenuEx(FStatePopupMenu.Handle, 0, P.X, P.Y, Handle, nil);

    Application.ProcessMessages;
    FMenuActive := False;

    UpdateComponentState;
  end;
end;

{
  Движение курсора мыши внутри компоненты.
}

procedure TmmStateMenu.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if (GetCapture = 0) and not FMouseIn then
  begin
    FMouseIn := True;
    UpdateComponentState;
  end;
end;

{
  Производим симуляцию выбора пункта меню для компоненты меню.
}

procedure TmmStateMenu.WMCommand(var Message: TWMCommand);
begin
  inherited;
  FStatePopupMenu.DispatchCommand(Message.ItemID);
end;

{
  Курсор мыши входит в пределы данной компоненты.
}

procedure TmmStateMenu.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  // Если в данный момент времени Capture мыши не принадлежит ни одному окну,
  // то работа возможна, если же нет - дальнейшие действия прерываются.
  if GetCapture = 0 then
  begin
    FMouseIn := True;
    UpdateComponentState;
  end;
end;

{
  Курсор мыши выходит из пределов данной копноненты.
}

procedure TmmStateMenu.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  FMouseIn := False;
  UpdateComponentState;
end;

{
  Возвращает строку состояния меню.
}

function TmmStateMenu.MakeMenuState: String;
var
  I: Integer;
begin
  Result := FPrefix;

  if FStatePopupMenu <> nil then
    for I := 0 to FStatePopupMenu.Items.Count - 1 do
      if FStatePopupMenu.Items[I].Checked then
      begin
        if Result <> Prefix then Result := Result + ', ';
        Result := Result + FStatePopupMenu.Items[I].Caption;
      end;
end;

end.

