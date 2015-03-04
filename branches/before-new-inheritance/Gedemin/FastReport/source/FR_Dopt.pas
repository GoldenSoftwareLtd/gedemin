
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Report options               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Dopt;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Const, ExtCtrls, ComCtrls;

type
  TfrDocOptForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    General: TTabSheet;
    Documents: TTabSheet;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    LB1: TListBox;
    GroupBox2: TGroupBox;
    CB2: TCheckBox;
    Prop: TPageControl;
    GroupBox3: TGroupBox;
    L1: TLabel;
    E1: TEdit;
    L2: TLabel;
    E2: TEdit;
    GroupBox4: TGroupBox;
    E3: TEdit;
    L3: TLabel;
    E4: TEdit;
    L7: TLabel;
    E5: TEdit;
    L8: TLabel;
    E6: TEdit;
    L9: TLabel;
    GroupBox5: TGroupBox;
    L4: TLabel;
    M1: TMemo;
    LM2: TLabel;
    L6: TLabel;
    LM1: TLabel;
    L5: TLabel;
    CB3: TCheckBox;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses FR_Prntr, FR_Utils;


procedure TfrDocOptForm.FormActivate(Sender: TObject);
begin
  LB1.Items.Assign(Prn.Printers);
  LB1.ItemIndex := Prn.PrinterIndex;
end;

procedure TfrDocOptForm.Localize;
begin
  Caption := frLoadStr(frRes + 370);
  GroupBox1.Caption := frLoadStr(frRes + 371);
  CB1.Caption := frLoadStr(frRes + 372);
  GroupBox2.Caption := frLoadStr(frRes + 373);
  CB2.Caption := frLoadStr(frRes + 374);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
  General.Caption := frLoadStr(frRes + 2656);
  CB3.Caption := frLoadStr(frRes + 2657);
  Documents.Caption := frLoadStr(frRes + 2658);
  GroupBox3.Caption := frLoadStr(frRes + 2659);
  L1.Caption := frLoadStr(frRes + 2660);
  L2.Caption := frLoadStr(frRes + 2661);
  GroupBox4.Caption := frLoadStr(frRes + 2662);
  L3.Caption := frLoadStr(frRes + 2663);
  L7.Caption := frLoadStr(frRes + 2664);
  L8.Caption := frLoadStr(frRes + 2665);
  L9.Caption := frLoadStr(frRes + 2666);
  GroupBox5.Caption := frLoadStr(frRes + 2667);
  L4.Caption := frLoadStr(frRes + 2668);
  L6.Caption := frLoadStr(frRes + 2669);
  L5.Caption := frLoadStr(frRes + 2670);
end;

procedure TfrDocOptForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrDocOptForm.LB1DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with LB1.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clOlive);
    TextOut(ARect.Left + 24, ARect.Top + 1, LB1.Items[Index]);
  end;
end;

end.

