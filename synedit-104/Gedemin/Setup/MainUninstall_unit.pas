unit MainUninstall_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsGedeminInstall;

type
  TMainUninstall = class(TForm)
    GedeminInstall: TGedeminInstall;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainUninstall: TMainUninstall;

implementation

{$R *.DFM}

end.
