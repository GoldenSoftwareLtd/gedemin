
{ 1.01  23-02-98  andreik  Font changed. }

unit xRTFPrnF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, xBulbBtn, gsMultilingualSupport;

type
  TRTFPrintingForm = class(TForm)
    Panel: TPanel;
    PageLabel: TLabel;
    Label1: TLabel;
    xBulbButton1: TxBulbButton;
    gsMultilingualSupport1: TgsMultilingualSupport;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Terminated: Boolean;
  end;

var
  RTFPrintingForm: TRTFPrintingForm;

implementation

{$R *.DFM}

procedure TRTFPrintingForm.BitBtn1Click(Sender: TObject);
begin
  if MessageDlg('Печать еще не завершена. Прервать?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
      Terminated := true;
end;

end.
