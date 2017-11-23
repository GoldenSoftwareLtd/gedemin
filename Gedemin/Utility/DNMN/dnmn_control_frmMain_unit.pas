unit dnmn_control_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    edKeyNumber: TEdit;
    Label1: TLabel;
    lblCode: TLabel;
    edCode: TEdit;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  dnmn_reg, ShellAPI;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  KeyNumber, V: Cardinal;
begin
  V := $19760212;
  KeyNumber := StrToInt64Def(StripNumber(edKeyNumber.Text), 0);
  edCode.Text := FormatFloat('#,###', V xor GetMask(KeyNumber));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'https://docs.google.com/spreadsheets/d/1HjrpD1GxhiVIqX0BV1ZgTCTK4cTYbY0y7AaqE3ma9mk/edit#gid=0',
    nil,
    nil,
    SW_SHOW);
end;

end.
