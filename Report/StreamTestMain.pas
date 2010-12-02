unit StreamTestMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses MainStrRpt_unit;

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
begin
  Form1 := TForm1.Create(Self);
  try
    Form1.ShowModal;
  finally
    Form1.Free;
  end;
end;

end.
