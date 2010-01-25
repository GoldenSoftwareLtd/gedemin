
{

  Copyright (c) 1998 by Golden Software

  Module

    xBulbImage.pas

  Abstract

    visual Component - bulb image.


  Author

    Romanovski Denis (December-1998)

  Contact addresses

    andreik@gs.minsk.by

  Uses

    Units:

    Forms:

    Other files:

  Revisions history

    Initial    11-Dec-1998  dennis    

  Known bugs

    -

  Wishes

  Notes / comments

    -

}

unit xBulbImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TxBulbImage = class(TImage)
  private
    FBulbPicture: TPicture;
    FOldPicture: TPicture;

    procedure SetBulbPicture(const Value: TPicture);

  protected
    procedure Loaded; override;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property BulbPicture: TPicture read FBulbPicture write SetBulbPicture;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TxBulbImage]);
end;

{ TxBulbImage }

constructor TxBulbImage.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBulbPicture := TPicture.Create;
  FOldPicture := TPicture.Create;
end;

destructor TxBulbImage.Destroy;
begin
  FBulbPicture.Free;
  FOldPicture.Free;

  inherited Destroy;
end;

procedure TxBulbImage.Loaded;
begin
  inherited Loaded;

  FOldPicture.Assign(Picture);
end;

procedure TxBulbImage.SetBulbPicture(const Value: TPicture);
begin
  FBulbPicture.Assign(Value);
end;

procedure TxBulbImage.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  Picture.Assign(FOldPicture);
end;

procedure TxBulbImage.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;

  if not MouseCapture then
  begin
    MouseCapture := True;
    Picture.Assign(FBulbPicture);
  end else if (Message.XPos < 0) or (Message.XPos > Width) or
   (Message.YPos < 0) or (Message.YPos > Height) then
  begin
    MouseCapture := False;
    Picture.Assign(FOldPicture);
  end;
end;

end.
