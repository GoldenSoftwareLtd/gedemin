unit MainRM_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  rp_RemoteManager_unit;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  with TRemoteManager.Create(nil) do
  try
    ShowReportManager(Edit1.Text);
  finally
    Free;
  end;
end;

end.
