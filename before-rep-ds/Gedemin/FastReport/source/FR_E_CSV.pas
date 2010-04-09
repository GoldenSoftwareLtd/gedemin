
{******************************************}
{                                          }
{             FastReport v2.53             }
{            CSV export filter             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_E_CSV;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls,
  FR_Class, FR_E_TXT, Controls;

type
  TfrCSVExport = class(TfrTextExport)
  private
    FDelimiter: Char;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
    procedure OnEndPage; override;
  published
    property Delimiter: Char read FDelimiter write FDelimiter;
  end;

  TfrCSVExportForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    Label4: TLabel;
    E3: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses FR_Const, FR_Utils;

{$R *.DFM}


{ TfrCSVExport }

constructor TfrCSVExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(SCSVFile) + ' (*.csv)', '*.csv');
  ShowDialog := True;
  ScaleX := 1;
  ScaleY := 1;
  KillEmptyLines := True;
  ConvertToOEM := False;
  Delimiter := ';';
end;

function TfrCSVExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrCSVExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ConvertToOEM;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);
    E3.Text := Delimiter;

    Result := ShowModal;
    try
      ScaleX := frStrToFloat(E1.Text);
    except
      ScaleX := 1;
    end;
    try
      ScaleY := frStrToFloat(E2.Text);
    except
      ScaleY := 1;
    end;
    KillEmptyLines := CB1.Checked;
    ConvertToOEM := CB2.Checked;
    if E3.Text <> '' then
      Delimiter := E3.Text[1];
    Free;
  end;
end;

procedure TfrCSVExport.OnEndPage;
var
  i, j, n, tc1, tc2: Integer;
  p: PfrTextRec;
  s: String;
begin
  n := Lines.Count - 1;
  while n >= 0 do
  begin
    if Lines[n] <> nil then break;
    Dec(n);
  end;

  for i := 0 to n do
  begin
    s := '';
    tc1 := 0;
    p := PfrTextRec(Lines[i]);
    while p <> nil do
    begin
      tc2 := Round(p^.X / (64 / ScaleX));
      for j := 0 to tc2 - tc1 - 1 do
        s := s + Delimiter;
      if Pos(Delimiter, p^.Text) <> 0 then
        s := s + '"' + p^.Text + '"' else
        s := s + p^.Text;
      tc1 := tc2;
      p := p^.Next;
    end;
    if not KillEmptyLines or (s <> '') then
    begin
      if ConvertToOEM then
        CharToOEMBuff(@s[1], @s[1], Length(s));
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
    end;
  end;
end;


procedure TfrCSVExportForm.Localize;
begin
  Caption := frLoadStr(frRes + 1810);
  CB1.Caption := frLoadStr(frRes + 1801);
  CB2.Caption := frLoadStr(frRes + 1802);
  Label1.Caption := frLoadStr(frRes + 1806);
  Label4.Caption := frLoadStr(frRes + 1811);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrCSVExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;


end.
