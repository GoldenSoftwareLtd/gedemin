unit gd_DatabasesListDlg_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tgd_DatabasesListDlg = class(TForm)
    Label1: TLabel;
    edName: TEdit;
    Label2: TLabel;
    edServer: TEdit;
    Label3: TLabel;
    edPort: TEdit;
    Label4: TLabel;
    edFileName: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label5: TLabel;
    edDBParams: TEdit;
    Button3: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_DatabasesListDlg: Tgd_DatabasesListDlg;

implementation

{$R *.DFM}

end.
