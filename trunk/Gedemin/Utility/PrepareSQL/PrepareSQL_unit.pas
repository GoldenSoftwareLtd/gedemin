unit PrepareSQL_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Memo: TMemo;
    Button1: TButton;
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
begin
  Memo.Lines.Text := Trim(StringReplace(Memo.Lines.Text, '''', '''''', [rfReplaceAll]));
  for I := 0 to Memo.Lines.Count - 1 do
    Memo.Lines[I] := '''' + Memo.Lines[I];
  for I := 0 to Memo.Lines.Count - 2 do
    Memo.Lines[I] := Memo.Lines[I] + ' ''#13#10 +';
  Memo.Lines.Text := Memo.Lines.Text + ''';';
end;

end.
