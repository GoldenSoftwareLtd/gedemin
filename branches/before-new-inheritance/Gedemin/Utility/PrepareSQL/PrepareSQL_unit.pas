unit PrepareSQL_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Memo: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

procedure TForm1.Button2Click(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  for I := 0 to Memo.Lines.Count - 1 do
  begin
    S := Trim(StringReplace(Memo.Lines[I], '#13#10', '', [rfReplaceAll]));
    if (S > '') and (S[1] = '''') then
      Delete(S, 1, 1);
    if (S > '') and (S[Length(S)] = '+') then
      SetLength(S, Length(S) - 1);
    S := TrimRight(StringReplace(S, '''''', '''', [rfReplaceAll]));

    if I = Memo.Lines.Count - 1 then
    begin
      if Copy(S, Length(S), 1) = ';' then
        SetLength(S, Length(S) - 1);
    end;

    if Copy(S, Length(S), 1) = '''' then
      SetLength(S, Length(S) - 1);

    Memo.Lines[I] := TrimRight(S);
  end;
end;

end.
