unit frTXTExpPrn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CheckLst, frTXTExp, Buttons, FR_Ctrls
{$IFDEF Delphi6}, Variants {$ENDIF}, ComCtrls, Mask;

type
  TfrPrnInit = class(TForm)
    OK: TButton;
    Cancel: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Image1: TImage;
    CB1: TComboBox;
    PropButton: TButton;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button1: TSpeedButton;
    Button2: TSpeedButton;
    E1: TMaskEdit;
    UpDown1: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure PropButtonClick(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure CB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    exp: TfrTextAdvExport;
    OldIndex: Integer;
    procedure Localize;
  public
    { Public declarations }
  end;

var
  frPrnInit: TfrPrnInit;

implementation

{$R *.dfm}

uses FR_Const, fr_utils, Printers, fr_prntr, fr_class;

procedure TfrPrnInit.FormCreate(Sender: TObject);
var
  i: integer;
begin
  CB1.Items.Assign(Printer.Printers);
  CB1.ItemIndex := Printer.PrinterIndex;
  OldIndex := Printer.PrinterIndex;
  Localize;
  SendMessage(GetWindow(ComboBox1.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  exp := TfrTextAdvExport(Owner);
  ComboBox1.Items.Clear;
  CheckListBox1.Items.Clear;
  for i := 0 to exp.PrintersCount - 1 do
    ComboBox1.Items.Add(exp.PrinterTypes[i].name);
  ComboBox1.ItemIndex := exp.SelectedPrinterType;
  ComboBox1Change(Sender);
end;

procedure TfrPrnInit.ComboBox1Change(Sender: TObject);
var
  j: integer;
begin
  CheckListBox1.Items.Clear;
  for j := 0 to exp.PrinterTypes[ComboBox1.ItemIndex].CommCount - 1 do
  begin
    CheckListBox1.Items.Add(exp.PrinterTypes[ComboBox1.ItemIndex].Commands[j].Name);
    CheckListBox1.Checked[j] := exp.PrinterTypes[ComboBox1.ItemIndex].Commands[j].Trigger;
  end;
  exp.SelectedPrinterType := ComboBox1.ItemIndex;
end;

procedure TfrPrnInit.CheckListBox1ClickCheck(Sender: TObject);
begin
  exp.PrinterTypes[ComboBox1.ItemIndex].Commands[CheckListBox1.ItemIndex].Trigger :=
     CheckListBox1.Checked[CheckListBox1.ItemIndex];
end;

procedure TfrPrnInit.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  Caption := frLoadStr(frRes + 040);
  Button1.Hint := frLoadStr(frRes + 2767);
  Button2.Hint := frLoadStr(frRes + 2768);
  OpenDialog1.Filter := frLoadStr(frRes + 2769);
  SaveDialog1.Filter := frLoadStr(frRes + 2769);
  GroupBox1.Caption := frLoadStr(frRes + 041);
  GroupBox2.Caption := frLoadStr(frRes + 2765);
  GroupBox3.Caption := frLoadStr(frRes + 043);
  Label1.Caption := frLoadStr(frRes + 2766);
  Label2.Caption := frLoadStr(frRes + 050);
  Label4.Caption := frLoadStr(frRes + 049);
  PropButton.Caption := frLoadStr(frRes + 042);

end;

procedure TfrPrnInit.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    exp.LoadPrinterInit(OpenDialog1.FileName);
    ComboBox1.ItemIndex := exp.SelectedPrinterType;
    ComboBox1Change(Sender);
  end;
end;

procedure TfrPrnInit.Button2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    exp.SavePrinterInit(SaveDialog1.FileName);
end;

procedure TfrPrnInit.FormDeactivate(Sender: TObject);
begin
  if ModalResult <> mrOk then
    Prn.PrinterIndex := OldIndex;
end;

procedure TfrPrnInit.PropButtonClick(Sender: TObject);
begin
  Prn.PropertiesDlg;
end;

procedure TfrPrnInit.CB1Click(Sender: TObject);
begin
  Prn.PrinterIndex := CB1.ItemIndex;
end;

procedure TfrPrnInit.CB1DrawItem(Control: TWinControl; Index: Integer;
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

end.
