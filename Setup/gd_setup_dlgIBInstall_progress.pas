unit gd_setup_dlgIBInstall_progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, xProgr, StdCtrls, jpeg;

type
  TdlgIBSetupProgress = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    btnExit: TButton;
    Memo1: TMemo;
    Label2: TLabel;
    ProgressBar: TxProgressBar;
    Label3: TLabel;
    Label4: TLabel;
    lblSourceDir: TLabel;
    lblTargetDir: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgIBSetupProgress: TdlgIBSetupProgress;

implementation

{$R *.DFM}

end.
