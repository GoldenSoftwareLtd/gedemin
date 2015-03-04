unit TestMetod_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_ClassList, StdCtrls, gdcTemplate;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit3: TEdit;
    Label3: TLabel;
    ListBox1: TListBox;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateList;
  public
    { Public declarations }
    function Sum(A, B: Integer): Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  RegisterClassMethod(TForm1, Edit1.Text, Edit2.Text, Edit3.Text);
  UpdateList;
end;

function TForm1.Sum(A, B: Integer): Integer;
begin
  Result := A + B;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateList;
end;

procedure TForm1.UpdateList;
var
  MethodList: TgdcMethodList;
  I: Integer;
begin
  ListBox1.Clear;
  MethodList := GetComponentClassMethods(TForm1);
  if Assigned(MethodList) then
    for I := 0 to MethodList.Count - 1 do
      ListBox1.Items.Add(MethodList[I].Name);
end;

end.
