unit PageControlEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TPageControlEx = class(TPageControl)
  private
    { Private declarations }
    FBPWidth: Integer;
    FBPRad: Integer;
    FtbLeft: TToolButton;
    FtbRight: TToolButton;
  protected
    { Protected declarations }
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Win32', [TPageControlEx]);
end;

{ TPageControlEx }

constructor TPageControlEx.Create(AOwner: TComponent);
begin
  inherited;
  FBPWidth := 100;
  FBPRad := 2;

  FtbLeft := TToolButton.Create(Self);
  FtbLeft.Name := 'tbLeft';

  FtbRight := TToolButton.Create(Self);
  FtbRight.Name := 'tbRight';
end;

destructor TPageControlEx.Destroy;
begin

end;

procedure TPageControlEx.DrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
var
  R: TRect;
  Color: TColor;
begin
  inherited;
  with Canvas do
  begin
    R := ClientRect;
    R.Left := R.Right - FBPWidth;
    R.Bottom := Rect.Bottom;
    FillRect(R);
    Color := Pen.Color;
    Pen.Color := clBtnHighlight;
    PenPos := Point(R.Left, R.Bottom - 2);
    LineTo(R.Left, R.Top + FBPRad);
    LineTo(R.Left + FBPRad, R.Top);
    LineTo(R.Right - FBPRad, R.Top);
    Pen.Color := cl3DDkShadow;
    PenPos := Point(R.Right - 1, R.Bottom);
    LineTo(R.Right - 1, R.Top + FBPRad);
    Pen.Color := clBtnShadow;
    PenPos := Point(R.Right - 2, R.Bottom);
    LineTo(R.Right - 2, R.Top + (FBPRad div 2));
  end;
end;

end.
