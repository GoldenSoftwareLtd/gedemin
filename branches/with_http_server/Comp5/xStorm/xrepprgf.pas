unit xRepPrgF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, xProgr, xMemo, xBulbBtn, xBasics, Dialogs;

type
  TReportProgressForm = class(TForm)
    Panel1: TPanel;
    ProgressLbl: TLabel;
    xMemo1: TxMemo;
    xBulbButton1: TxBulbButton;
    Bevel1: TBevel;
    SaveDialog: TSaveDialog;
    procedure xBulbButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Terminated: Boolean;
  end;

var
  ReportProgressForm: TReportProgressForm;

implementation

{$R *.DFM}

procedure TReportProgressForm.xBulbButton1Click(Sender: TObject);
begin
  FormStyle := fsNormal;
  try
    if MessageBox(0, 'Создание отчета еще не завершено. ' +
      'Вы действительно хотите прервать процесс?', 'Прерывание',
      MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = mrYes then
      Terminated := true;
  finally
    FormStyle := fsStayOnTop;
  end;
end;

procedure TReportProgressForm.FormCreate(Sender: TObject);
begin
  Terminated := false;
end;

end.
