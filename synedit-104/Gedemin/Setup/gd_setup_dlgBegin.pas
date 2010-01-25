
unit gd_setup_dlgBegin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls;

type
  TdlgBeginSetup = class(TForm)
    btnOk: TButton;
    Memo1: TMemo;
    Image1: TImage;
    btnExit: TButton;
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgBeginSetup: TdlgBeginSetup;

implementation

{$R *.DFM}

end.
