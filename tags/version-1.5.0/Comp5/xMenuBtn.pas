{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xmenubtn.pas

  Abstract

    Button with pulldown menu.

  Author

    Andrei Kireev (28-Apr-96)

  Contact address

    220047, Belarus, Minsk, PO Box 129

  Revisions history

    1.00    29-Apr-96    andreik    Initial version.
    1.01    17-Jun-96    andreik    Minor change.

--}

unit xMenuBtn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Menus;

type
  TxMenuButton = class(TBitBtn)
  private
    FLinkMenu: TPopupMenu;

    procedure SetLinkMenu(ALinkMenu: TPopupMenu);
    procedure DoMenu;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property LinkMenu: TPopupMenu read FLinkMenu write SetLinkMenu;

    property Layout default blGlyphRight;
  end;

procedure Register;

implementation

{$R xMenuBtn.res}

{ TxMenuButton -------------------------------------------}

constructor TxMenuButton.Create(AnOwner: TComponent);
var
  Arrow: TBitmap;
begin
  inherited Create(AnOwner);

  { Layout := blGlyphRight; }
  Width := (Width * 3) div 2;

  Arrow := TBitmap.Create;
  try
    Arrow.Handle := LoadBitmap(hInstance, 'XMB_ARROW');
    if Arrow.Handle = 0 then
      raise Exception.Create('Can''t load resource bitmap');
    Arrow.Width := 16;
    Glyph.Assign(Arrow);
  finally
    Arrow.Free;
  end;
end;

procedure TxMenuButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  DoMenu;
end;

procedure TxMenuButton.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  if Message.CharCode = VK_SPACE then
    DoMenu;
end;

procedure TxMenuButton.SetLinkMenu(ALinkMenu: TPopupMenu);
begin
  FLinkMenu := ALinkMenu;
  Enabled := Assigned(FLinkMenu) and (FLinkMenu.ComponentCount > 0);
end;

procedure TxMenuButton.DoMenu;
var
  P: TPoint;
begin
  if Assigned(FLinkMenu) then
  begin
    P := Point(0, Height);
    MapWindowPoints(Handle, 0, P, 1);
    FLinkMenu.Popup(P.X, P.Y);
    SendMessage(Handle, WM_LBUTTONUP, 0, MAKELONG(1, 1)); { release button }
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool', [TxMenuButton]);
end;

end.

