
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Print dialog                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_PrDlg;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Ctrls, ExtCtrls;

type
  TfrPrintForm = class(TForm)
    GroupBox2: TGroupBox;
    RB1: TRadioButton;
    RB2: TRadioButton;
    RB3: TRadioButton;
    E2: TEdit;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    CB1: TComboBox;
    PropButton: TButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    E1: TEdit;
    Panel1: TPanel;
    frSpeedButton1: TfrSpeedButton;
    frSpeedButton2: TfrSpeedButton;
    CollateCB: TCheckBox;
    CollateImg: TImage;
    NonCollateImg: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    CB2: TComboBox;
    PB1: TPaintBox;
    procedure CB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure PropButtonClick(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure frSpeedButton1Click(Sender: TObject);
    procedure frSpeedButton2Click(Sender: TObject);
    procedure RB3Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure CollateCBClick(Sender: TObject);
    procedure PB1Paint(Sender: TObject);
    procedure E1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    OldIndex: Integer;
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses FR_Const, FR_Prntr, Printers, FR_Utils;


procedure TfrPrintForm.Localize;
begin
  Caption := frLoadStr(frRes + 040);
  GroupBox1.Caption := frLoadStr(frRes + 041);
  PropButton.Caption := frLoadStr(frRes + 042);
  GroupBox3.Caption := frLoadStr(frRes + 043);
  GroupBox2.Caption := frLoadStr(frRes + 044);
  RB1.Caption := frLoadStr(frRes + 045);
  RB2.Caption := frLoadStr(frRes + 046);
  RB3.Caption := frLoadStr(frRes + 047);
  Label2.Caption := frLoadStr(frRes + 048);
  Label4.Caption := frLoadStr(frRes + 049);
  Label1.Caption := frLoadStr(frRes + 050);
  Label3.Caption := frLoadStr(frRes + 051);
  Label5.Caption := frLoadStr(frRes + 052);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);

  CB2.Items.Add(frLoadStr(frRes + 053));
  CB2.Items.Add(frLoadStr(frRes + 054));
  CB2.Items.Add(frLoadStr(frRes + 055));
end;

procedure TfrPrintForm.FormCreate(Sender: TObject);
begin
  CB1.Items.Assign(Printer.Printers);
  CB1.ItemIndex := Printer.PrinterIndex;
  OldIndex := Printer.PrinterIndex;
  CollateCBClick(nil);
  Localize;
  CB2.ItemIndex := 0;
  CB2.Left := Label5.Left + Label5.Width + 11;
end;

procedure TfrPrintForm.FormDeactivate(Sender: TObject);
begin
  if ModalResult <> mrOk then
    Prn.PrinterIndex := OldIndex;
end;

procedure TfrPrintForm.CB1DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with CB1.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clOlive);
    TextOut(ARect.Left + 24, ARect.Top + 1, CB1.Items[Index]);
  end;
end;

procedure TfrPrintForm.PropButtonClick(Sender: TObject);
begin
  Prn.PropertiesDlg;
end;

procedure TfrPrintForm.CB1Click(Sender: TObject);
begin
  Prn.PrinterIndex := CB1.ItemIndex;
end;

procedure TfrPrintForm.E2Click(Sender: TObject);
begin
  RB3.Checked := True;
end;

procedure TfrPrintForm.frSpeedButton1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(E1.Text);
  Inc(i);
  E1.Text := IntToStr(i);
end;

procedure TfrPrintForm.frSpeedButton2Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(E1.Text);
  Dec(i);
  if i <= 0 then i := 1;
  E1.Text := IntToStr(i);
end;

procedure TfrPrintForm.RB3Click(Sender: TObject);
begin
  E2.SetFocus;
end;

procedure TfrPrintForm.Label3Click(Sender: TObject);
begin
  CollateCB.Checked := not CollateCB.Checked;
end;

procedure TfrPrintForm.CollateCBClick(Sender: TObject);
begin
  PB1Paint(nil);
end;

procedure TfrPrintForm.PB1Paint(Sender: TObject);
begin
  with PB1.Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, PB1.Width, PB1.Height));
    if CollateCB.Checked then
      BrushCopy(Rect(8, 0, 82, 53), CollateImg.Picture.Bitmap, Rect(0, 0, 74, 53), clSilver) else
      BrushCopy(Rect(0, 8, 92, 48), NonCollateImg.Picture.Bitmap, Rect(0, 0, 92, 40), clSilver);
  end;
end;

procedure TfrPrintForm.E1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9']) then
    Key := #0
end;

end.
