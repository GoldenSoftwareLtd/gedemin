unit gsDBSqueeze_AboutForm_unit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    OKButton: TButton;
    Panel1: TPanel;
    ProductName: TLabel;
    Version: TLabel;
    lblCopyrightSymbol: TLabel;
    Comments: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
   lblCopyrightSymbol.Caption := #169;
end;

end.
 
