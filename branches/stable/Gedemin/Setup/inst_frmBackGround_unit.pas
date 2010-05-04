
unit inst_frmBackGround_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Bkground, StdCtrls;

type
  TfrmBackGround = class(TForm)
    GradientFill: TGradientFill;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBackGround: TfrmBackGround;

implementation

uses InstallMainFrom_unit;

{$R *.DFM}

procedure TfrmBackGround.FormActivate(Sender: TObject);
begin
  Assert(InstallMainFrom = nil);
  InstallMainFrom := TInstallMainFrom.Create(Self);
  InstallMainFrom.ShowModal;
  Close;
end;

procedure TfrmBackGround.FormCreate(Sender: TObject);
begin
{ TODO -oYuri : Проверить целостность инсталляции. }
// В частости:
// 1. files.ini;
// 2.
end;

end.
