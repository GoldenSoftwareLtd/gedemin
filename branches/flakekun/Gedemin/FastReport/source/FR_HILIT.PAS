
{******************************************}
{                                          }
{             FastReport v2.53             }
{       Highlight attributes dialog        }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Hilit;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, FR_Ctrls, FR_Const;

type
  TfrHilightForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB3: TCheckBox;
    Button3: TButton;
    Button4: TButton;
    ColorDialog1: TColorDialog;
    SpeedButton1: TfrSpeedButton;
    SpeedButton2: TfrSpeedButton;
    RB1: TRadioButton;
    RB2: TRadioButton;
    GroupBox3: TGroupBox;
    Edit1: TfrComboEdit;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure RB1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit1ButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    FontColor, FillColor: TColor;
  end;


implementation

uses FR_Desgn, FR_Class, FR_Expr, FR_Utils;

{$R *.DFM}


procedure TfrHilightForm.SpeedButton1Click(Sender: TObject);
begin
  ColorDialog1.Color := FontColor;
  if ColorDialog1.Execute then
  begin
    FontColor := ColorDialog1.Color;
    frSetGlyph(FontColor, SpeedButton1, 0);
  end;
end;

procedure TfrHilightForm.SpeedButton2Click(Sender: TObject);
begin
  ColorDialog1.Color := FillColor;
  if ColorDialog1.Execute then
  begin
    FillColor := ColorDialog1.Color;
    frSetGlyph(FillColor, SpeedButton2, 1);
  end;
end;

procedure TfrHilightForm.FormActivate(Sender: TObject);
begin
  frSetGlyph(FontColor, SpeedButton1, 0);
  frSetGlyph(FillColor, SpeedButton2, 1);
  if FillColor = clNone then
    RB1.Checked := True else
    RB2.Checked := True;
  RB1Click(nil);
end;

procedure TfrHilightForm.RB1Click(Sender: TObject);
begin
  SpeedButton2.Enabled := RB2.Checked;
  if RB1.Checked then FillColor := clNone;
end;

procedure TfrHilightForm.Edit1ButtonClick(Sender: TObject);
begin
  with TfrExprForm.Create(nil) do
  begin
    ExprMemo.Text := Edit1.Text;
    if ShowModal = mrOk then
      Edit1.Text := ExprMemo.Text;
    Free;
  end;
end;

procedure TfrHilightForm.Localize;
begin
  Caption := frLoadStr(frRes + 520);
  GroupBox3.Caption := frLoadStr(frRes + 521);
  GroupBox1.Caption := frLoadStr(frRes + 522);
  SpeedButton1.Caption := frLoadStr(frRes + 523);
  CB1.Caption := frLoadStr(frRes + 524);
  CB2.Caption := frLoadStr(frRes + 525);
  CB3.Caption := frLoadStr(frRes + 526);
  GroupBox2.Caption := frLoadStr(frRes + 527);
  SpeedButton2.Caption := frLoadStr(frRes + 528);
  RB1.Caption := frLoadStr(frRes + 529);
  RB2.Caption := frLoadStr(frRes + 530);
  Edit1.ButtonHint := frLoadStr(frRes + 575);
  Button3.Caption := frLoadStr(SOk);
  Button4.Caption := frLoadStr(SCancel);
end;

procedure TfrHilightForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

