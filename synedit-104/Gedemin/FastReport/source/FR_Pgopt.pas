
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Page options                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_pgopt;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, FR_Ctrls;

type
  TfrPgoptForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox2: TGroupBox;
    imgLandScape: TImage;
    imgPortrait: TImage;
    RB1: TRadioButton;
    RB2: TRadioButton;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    GroupBox3: TGroupBox;
    ComB1: TComboBox;
    E1: TEdit;
    E2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox4: TGroupBox;
    CB5: TCheckBox;
    E3: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    E4: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    E5: TEdit;
    E6: TEdit;
    GroupBox5: TGroupBox;
    Label7: TLabel;
    E7: TEdit;
    Label8: TLabel;
    Edit1: TEdit;
    Panel8: TPanel;
    SB1: TfrSpeedButton;
    SB2: TfrSpeedButton;
    TabSheet4: TTabSheet;
    GroupBox6: TGroupBox;
    BinList: TListBox;
    CB2: TCheckBox;
    procedure RB1Click(Sender: TObject);
    procedure RB2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComB1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SB1Click(Sender: TObject);
    procedure SB2Click(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses FR_Prntr, FR_Class, FR_Const, FR_Utils;

procedure TfrPgoptForm.RB1Click(Sender: TObject);
begin
  ImgPortrait.Show;
  ImgLandscape.Hide;
end;

procedure TfrPgoptForm.RB2Click(Sender: TObject);
begin
  ImgLandscape.Show;
  ImgPortrait.Hide;
end;

procedure TfrPgoptForm.FormActivate(Sender: TObject);
begin
  if RB1.Checked then RB1Click(nil) else RB2Click(nil);
  ComB1Click(nil);
  ComB1.Perform(CB_SETDROPPEDWIDTH, 200, 0);
end;

procedure TfrPgoptForm.ComB1Click(Sender: TObject);
begin
  frEnableControls([Label1, Label2, E1, E2],
    Prn.PaperSizes[ComB1.ItemIndex] = $100);
end;

procedure TfrPgoptForm.Localize;
begin
  Caption := frLoadStr(frRes + 390);
  TabSheet1.Caption := frLoadStr(frRes + 391);
  GroupBox2.Caption := frLoadStr(frRes + 392);
  RB1.Caption := frLoadStr(frRes + 393);
  RB2.Caption := frLoadStr(frRes + 394);
  GroupBox3.Caption := frLoadStr(frRes + 395);
  Label1.Caption := frLoadStr(frRes + 396);
  Label2.Caption := frLoadStr(frRes + 397);
  TabSheet2.Caption := frLoadStr(frRes + 398);
  GroupBox4.Caption := frLoadStr(frRes + 399);
  Label3.Caption := frLoadStr(frRes + 400);
  Label4.Caption := frLoadStr(frRes + 401);
  Label5.Caption := frLoadStr(frRes + 402);
  Label6.Caption := frLoadStr(frRes + 403);
  CB5.Caption := frLoadStr(frRes + 404);
  TabSheet3.Caption := frLoadStr(frRes + 405);
  GroupBox1.Caption := frLoadStr(frRes + 406);
  CB1.Caption := frLoadStr(frRes + 407);
  CB2.Caption := frLoadStr(frRes + 413);
  GroupBox5.Caption := frLoadStr(frRes + 408);
  Label7.Caption := frLoadStr(frRes + 409);
  Label8.Caption := frLoadStr(frRes + 410);
  TabSheet4.Caption := frLoadStr(frRes + 411);
  GroupBox6.Caption := frLoadStr(frRes + 412);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrPgoptForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrPgoptForm.SB1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Edit1.Text);
  Inc(i);
  Edit1.Text := IntToStr(i);
end;

procedure TfrPgoptForm.SB2Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Edit1.Text);
  Dec(i);
  if i < 0 then i := 0;
  Edit1.Text := IntToStr(i);
end;

end.

