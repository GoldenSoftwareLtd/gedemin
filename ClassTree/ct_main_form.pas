
unit ct_main_form;

{TODO }
{TODO }
{TODO }
{TODO }
{TODO }
{TODO }
{TODO }
{TODO }
{TODO }
{TODO }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ct_pascal_parser, StdCtrls, xFileList, ct_class, IBDatabase, Db;

type
  TForm1 = class(TForm)
    Edit: TEdit;
    Button1: TButton;
    xFileList: TxFileList;
    Label1: TLabel;
    IBDatabase: TIBDatabase;
    IBTransaction: TIBTransaction;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  I: Integer;
  UL: TctUnits;
begin
  UL := TctUnits.Create;

  xFileList.Include.Add(Edit.Text);
  xFileList.CreateList;

  for I := 0 to xFileList.FullNamesList.Count - 1 do
  begin
    Label1.Caption := xFileList.FullNamesList[I];
    Application.ProcessMessages;
    UL.Add(ParseUnit(xFileList.FullNamesList[I]));
  end;

//  ParseUnit(Edit1.Text).SaveAsText(TFileStream.Create('d:\golden\gedemin\classtree\test\t.txt', fmOpenWrite));

  Label1.Caption := 'Saving...';
  Application.ProcessMessages;
//  UL.SaveAsText(TFileStream.Create('d:\golden\gedemin\classtree\test\t.txt', fmCreate or fmShareDenyWrite));

  Label1.Caption := 'Saved!';

  UL.Sort;
//  UL.SaveAsHtml('d:\golden\gedemin\classtree\template', 'd:\golden\gedemin\classtree\output');

  IBDatabase.Connected := True;
  UL.SaveAsDatabase(IBDatabase, IBTransaction);

  UL.Free;
end;

end.
