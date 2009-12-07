
{++

  Copyright (c) 1995-98 by Golden Software of Belarus

  Module

    xpanel.pas
                             
  Abstract

    Panel with wallpaper.

  Author

    Andrei Kireev (who knows)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.01
    1.02                      converted to 32bit Delphi
    1.03            sai       Add TWallImages
    1.04  27-12-97  andreik   Minor changes. File xPanel.res is unnecessary.
    1.05  07-01-98  andreik   Bitmap wallpaper changed with TImage. TWallImages
                              sent to hell.
    1.06  05-10-98  andreik   TabOrder prop published.
    1.07  23-10-98  dennis    OnKeyDown, OnKeyUp, OnKeyPress event made publick.
                              Very important do not erase it! 


  Known bugs

    Не отслеживается удаление Image.

--}

unit xPanel;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TxPanel = class(TPanel)
  private
    FEnableWallpaper: Boolean;
    FDrawBevel: Boolean;
    FWallpaper: TImage;

    procedure SetEnableWallpaper(AnEnableWallpaper: Boolean);
    procedure SetWallpaper(AWallpaper: TImage);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;

  published
    property Wallpaper: TImage read FWallpaper write SetWallpaper;
    property EnableWallpaper: Boolean read FEnableWallpaper write SetEnableWallpaper
      default True;
    property DrawBevel: Boolean read FDrawBevel write FDrawBevel
      default False;

    property TabOrder;
    property TabStop;  
  end;

procedure Register;

implementation

{ TxPanel ------------------------------------------------}

constructor TxPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle - [csCaptureMouse] + [csOpaque];
  FWallpaper := nil;
  FEnableWallpaper := True;
  FDrawBevel := False;
end;

procedure TxPanel.Paint;
var
  K, J: Integer;
  Rgn: HRgn;
begin
  if (not FEnableWallpaper) or (FWallpaper = nil) or
    (FWallpaper.Picture.Graphic = nil) or (FWallpaper.Picture.Graphic.Empty) then
  begin
    inherited Paint;
    exit;
  end;

  if FDrawBevel then
  begin
    inherited Paint;

    Rgn := CreateRectRgn(BevelWidth, BevelWidth,
      Width - BevelWidth, Height - BevelWidth);
    try
      SelectClipRgn(Canvas.Handle, Rgn);
    finally
      DeleteObject(Rgn);
    end;
  end;

  for K := 0 to Width div FWallpaper.Width do
    for J := 0 to Height div FWallpaper.Height do
      Canvas.Draw(K * FWallpaper.Width, J * FWallpaper.Height, FWallpaper.Picture.Graphic);

  if FDrawBevel then
    SelectClipRgn(Canvas.Handle, 0);
end;

procedure TxPanel.SetWallpaper(AWallpaper: TImage);
begin
  FWallpaper := AWallpaper;
  Invalidate;
end;

procedure TxPanel.SetEnableWallpaper(AnEnableWallpaper: Boolean);
begin
  if AnEnableWallpaper <> FEnableWallpaper then
  begin
    FEnableWallpaper := AnEnableWallpaper;
    Invalidate;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsVC', [TxPanel]);
end;

end.
