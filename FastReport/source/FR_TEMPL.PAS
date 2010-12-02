
{******************************************}
{                                          }
{             FastReport v2.53             }
{            New Template form             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Templ;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FR_Const;

type
  TfrTemplNewForm = class(TForm)
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Utils;

{$R *.DFM}

procedure TfrTemplNewForm.Button1Click(Sender: TObject);
begin
  OpenDialog1.Filter := frLoadStr(SBMPFile) + ' (*.bmp)|*.bmp';
  with OpenDialog1 do
  if Execute then
    Image1.Picture.LoadFromFile(FileName);
end;

procedure TfrTemplNewForm.FormActivate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Image1.Picture.Assign(nil);
  Memo1.SetFocus;
end;

procedure TfrTemplNewForm.Localize;
begin
  Caption := frLoadStr(frRes + 320);
  Label1.Caption := frLoadStr(frRes + 321);
  GroupBox2.Caption := frLoadStr(frRes + 322);
  Button1.Caption := frLoadStr(frRes + 323);
  Button2.Caption := frLoadStr(SOk);
  Button3.Caption := frLoadStr(SCancel);
end;

procedure TfrTemplNewForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

