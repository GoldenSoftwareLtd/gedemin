{
  װמנלא הכÿ מעקועמג
}

unit rp_PrintReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xReport, Db, StdCtrls, xRTFView, ExtCtrls, xRTF, ComCtrls, ToolWin, Registry;

type
  TfrmPrintReport = class(TForm)
    xReport: TxReport;
    Panel1: TPanel;
    Viewer: TxRTFViewer;
    SaveDialog: TSaveDialog;
    dsReport: TDataSource;
    ControlBar1: TControlBar;
    ToolBar1: TToolBar;
    tbSave: TToolButton;
    tbPrint: TToolButton;
    tbForm: TToolButton;
    tbWord: TToolButton;
    tbValues: TToolButton;
    xRTFScaleCombo1: TxRTFScaleCombo;
    tbRefresh: TToolButton;
    tbClose: TToolButton;
    cbCloseAffterPrint: TCheckBox;
    procedure xReportReportReady(Sender: TObject; var RTFFile: TxRTFFile);
    procedure tbSaveClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure tbRefreshClick(Sender: TObject);
    procedure tbFormClick(Sender: TObject);
    procedure tbPrintClick(Sender: TObject);
    procedure tbValuesClick(Sender: TObject);
    procedure tbWordClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FEditTemplate: Boolean;

  public
    property EditTemplate: Boolean read FEditTemplate write FEditTemplate;
  end;

var
  frmPrintReport: TfrmPrintReport;

implementation

{$R *.DFM}

uses
  ComObj, rp_Variable_unit, rp_Common, dmDataBase_unit, Ternaries;

procedure TfrmPrintReport.xReportReportReady(Sender: TObject;
  var RTFFile: TxRTFFile);
begin
  Viewer.ExchangeData(RTFFile);
end;

procedure TfrmPrintReport.tbSaveClick(Sender: TObject);
begin
  SaveDialog.FileName := '*.rtf';
  if SaveDialog.Execute then
    Viewer.SaveRTF(SaveDialog.FileName);
end;

procedure TfrmPrintReport.tbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrintReport.tbRefreshClick(Sender: TObject);
begin
  xReport.Execute;
end;

procedure TfrmPrintReport.tbFormClick(Sender: TObject);
begin
  EditFile(xReport.FormFile);
  FEditTemplate := True;
end;

procedure TfrmPrintReport.tbPrintClick(Sender: TObject);
begin
  if not Viewer.Data.PrintRTF2 then
  begin
    Viewer.Invalidate;
  end;
  if cbCloseAffterPrint.Checked then
    Close;

end;

procedure TfrmPrintReport.tbValuesClick(Sender: TObject);
begin
  with TfrmVariable.Create(Self) do
  try
    dsVariable.DataSet := dsReport.DataSet;
    Memo.Lines.Assign(xReport.Vars);
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmPrintReport.tbWordClick(Sender: TObject);
var
  FileName: String;
  NameRTFChar, Path: array [0..255] of Char;
begin
  GetTempPath(SizeOf(Path), Path);
  GetTempFileName(Path, 'rtf', 0, NameRTFChar);

  FileName := StrPas(NameRTFChar);
  FileName := Copy(FileName, 0, Length(FileName) - 3);
  FileName := FileName + 'rtf';
  Viewer.SaveRTF(FileName);
  EditFile(FileName);
end;

procedure TfrmPrintReport.FormCreate(Sender: TObject);
begin
  FEditTemplate := False;
  with UserStorage.OpenFolder('\rp_PrintReport', True) do
    cbCloseAffterPrint.Checked :=
      ReadInteger('CloseAffterPrint', 0) = 1;
end;

procedure TfrmPrintReport.FormDestroy(Sender: TObject);
begin
  with UserStorage.OpenFolder('\rp_PrintReport', True) do
    WriteInteger('CloseAffterPrint',
      Ternary(cbCloseAffterPrint.Checked, 1, 0));
end;

end.
