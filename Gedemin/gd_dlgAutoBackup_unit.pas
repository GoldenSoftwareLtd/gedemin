unit gd_dlgAutoBackup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  Tgd_dlgAutoBackup = class(TForm)
    Animate: TAnimate;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgAutoBackup: Tgd_dlgAutoBackup;

implementation

{$R *.DFM}

end.
