unit gd_setup_dlgSetupType;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls;

type
  TdlgSetupType = class(TForm)
    btnOk: TButton;
    Memo1: TMemo;
    Image1: TImage;
    btnExit: TButton;
    Bevel1: TBevel;
    rbServer: TRadioButton;
    rbClient: TRadioButton;
    Label1: TLabel;
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgSetupType: TdlgSetupType;

implementation

{$R *.DFM}

procedure TdlgSetupType.btnExitClick(Sender: TObject);
begin
  if MessageBox(Handle,
    'Вы действительно хотите прервать установку и выйти из программы?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then ModalResult := mrCancel;
end;

end.
