
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
    FColorLowLiter: TColor; // ���� ������� � ������� ���������
    FColorLightLiter: TColor; // ���� ������� �������
    FMouseIn: Boolean; // ���� � �������� ����������
    FMenuActive: Boolean; // ������������ �� ����?
    FStatePopupMenu: TPopupMenu; // ���� ��� ������
    FPrefix: String; // ��������� � ������ ��������� ����

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
    // ���� ������� � ������� ���������
    property ColorLightLiter: TColor read FColorLightLiter write FColorLightLiter
      default DefLightLiter;
    // ���� ������� � ������� ���������
    property ColorLowLiter: TColor read FColorLowLiter write SetColorLowLiter
      default DefLowLiter;
    // ���� �� ����� ������ ����
    property StatePopupMenu: TPopupMenu read FStatePopupMenu write SetStatePopupMenu;
    // �����, ������ ����� ������� ��������� ����
    property Prefix: String read FPrefix write SetPrefix;
  end;

implementation


{
   ***********************
   ***   Public Part   ***
   ***********************
}

{
  � ����������� ������ ��������� ���������.
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
  FPrefix := '���������: ';
end;

{
  ���������� ����������� ��������� ����������.
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
  ���������� ����������� ����������� ���� ����������.
}

procedure TmmStateMenu.Paint;
begin
  UpdateComponentState;
end;

{
  ����������� �������� PopupMenu.
}

procedure TmmStateMenu.Notification(AComponent: TComponent; Operation: TOperation); 
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FStatePopupMenu) then
    FStatePopupMenu := nil;
end;

{
  ������������� ���� Interface manager-�.
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
  ������������� property ColorLowLeter.
}

procedure TmmStateMenu.SetColorLowLiter(const Value: TColor);
begin
  FColorLowLiter := Value;
  UpdateComponentState;
end;

{
  ������������� popup menu, ������� ����� �������������� � ����������
  �����������
}

procedure TmmStateMenu.SetStatePopupMenu(const Value: TPopupMenu);
begin
  FStatePopupMenu := Value;
  UpdateComponentState;
end;

{
  ������������� ��������� � ������ ������ � ��������� ����.
}

procedure TmmStateMenu.SetPrefix(const Value: String);
begin
  FPrefix := Value;
  UpdateComponentState;
end;

{
  �� ������� ������ ���� ���������� ��������� ����.
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
  �������� ������� ���� ������ ����������.
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
  ���������� ��������� ������ ������ ���� ��� ���������� ����.
}

procedure TmmStateMenu.WMCommand(var Message: TWMCommand);
begin
  inherited;
  FStatePopupMenu.DispatchCommand(Message.ItemID);
end;

{
  ������ ���� ������ � ������� ������ ����������.
}

procedure TmmStateMenu.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  // ���� � ������ ������ ������� Capture ���� �� ����������� �� ������ ����,
  // �� ������ ��������, ���� �� ��� - ���������� �������� �����������.
  if GetCapture = 0 then
  begin
    FMouseIn := True;
    UpdateComponentState;
  end;
end;

{
  ������ ���� ������� �� �������� ������ ����������.
}

procedure TmmStateMenu.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  FMouseIn := False;
  UpdateComponentState;
end;

{
  ���������� ������ ��������� ����.
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

