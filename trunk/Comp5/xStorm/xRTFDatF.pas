{
  Form file for RTF files viewing components (xRTF unit).
  Copyright c) 1996 - 97 by Golden Software
  Author: Vladimir Belyi
}

unit xRTFDatF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, xRTFView, ExtCtrls, Dialogs, xRTF;

type
  TxRTFDataForm = class(TForm)
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    Panel2: TPanel;
    RTFViewer: TxRTFViewer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MainViewer: TxRTFViewer;
  end;

var
  xRTFDataForm: TxRTFDataForm;

implementation

{$R *.DFM}

procedure TxRTFDataForm.Button1Click(Sender: TObject);
begin
  if OpenDialog.Execute then
   begin
     RTFViewer.Clear;
     RTFViewer.DataFileName := OpenDialog.FileName;
{     MainViewer.Clear;
     MainViewer.DataFileName := OpenDialog.FileName;}
   end;
end;

procedure TxRTFDataForm.Button2Click(Sender: TObject);
begin
  RTFViewer.Clear;
{  MainViewer.Clear;}
end;

end.
