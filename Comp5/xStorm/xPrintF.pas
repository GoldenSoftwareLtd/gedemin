{
  Print dialog (originally designed for xRTF)
  Copyright c) 1996 - 97 by Golden Software
  Author: Vladimir Belyi
}

unit xPrintF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Dialogs, ExtCtrls, xSpin, Spin, xBulbBtn, xYellabl,
  gsMultilingualSupport;

type
  TxPrintDialog = class(TForm)
    Label1: TLabel;
    PrinterSetupDialog: TPrinterSetupDialog;
    GroupBox1: TGroupBox;
    RangeAll: TRadioButton;
    RangePages: TRadioButton;
    PagesRange: TEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    PrinterName: TxYellowLabel;
    xBulbButton1: TxBulbButton;
    xBulbButton2: TxBulbButton;
    xBulbButton3: TxBulbButton;
    Copies: TSpinEdit;
    gsMultilingualSupport1: TgsMultilingualSupport;
    procedure Button1Click(Sender: TObject);
    procedure PagesRangeChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Device, Driver, Port: array[0..255] of char;
    DeviceMode: THandle;
    procedure SetPrinter(ADevice, ADriver, APort: PChar; ADeviceMode: THandle);
    procedure GetPrinter(ADevice, ADriver, APort: PChar; var ADeviceMode: THandle);
    procedure UpdateView;
  end;

var
  xPrintDialog: TxPrintDialog;

implementation

{$R *.DFM}

uses Printers;

procedure TxPrintDialog.Button1Click(Sender: TObject);
begin
  PrinterSetupDialog.Execute;
  UpdateView;
end;

procedure TxPrintDialog.PagesRangeChange(Sender: TObject);
begin
  RangePages.Checked := true;
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
end;

procedure TxPrintDialog.FormActivate(Sender: TObject);
begin
  UpdateView;
end;

procedure TxPrintDialog.UpdateView;
begin
{  PrinterName.Lines.Clear;
  PrinterName.Lines.Add(Printer.Printers[Printer.PrinterIndex]);}
  PrinterName.Caption := Printer.Printers[Printer.PrinterIndex];
end;

procedure TxPrintDialog.SetPrinter(ADevice, ADriver, APort: PChar;
  ADeviceMode: THandle);
begin
  Printer.SetPrinter(ADevice, ADriver, APort, ADeviceMode);
//  Printer.PrinterIndex := Printer.Printers.IndexOf(ADevice);
  UpdateView;
end;

procedure TxPrintDialog.GetPrinter(ADevice, ADriver, APort: PChar;
  var ADeviceMode: THandle);
begin
  Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
end;

end.
