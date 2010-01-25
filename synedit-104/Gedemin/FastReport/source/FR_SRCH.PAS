
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Search text dialog             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Srch;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Const;

type
  TfrPreviewSearchForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    GroupBox2: TGroupBox;
    RB1: TRadioButton;
    RB2: TRadioButton;
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

procedure TfrPreviewSearchForm.FormActivate(Sender: TObject);
begin
  Edit1.SetFocus;
  Edit1.SelectAll;
end;

procedure TfrPreviewSearchForm.Localize;
begin
  Caption := frLoadStr(frRes + 000);
  Label1.Caption := frLoadStr(frRes + 001);
  GroupBox1.Caption := frLoadStr(frRes + 002);
  CB1.Caption := frLoadStr(frRes + 003);
  GroupBox2.Caption := frLoadStr(frRes + 004);
  RB1.Caption := frLoadStr(frRes + 005);
  RB2.Caption := frLoadStr(frRes + 006);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrPreviewSearchForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

