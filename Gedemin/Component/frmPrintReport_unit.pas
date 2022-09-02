// ShlTanya, 20.02.2019

{
  Форма для отчетов
}

unit frmPrintReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xReport, Db, FrmPlSvr, mBitButton, StdCtrls, xRTFView, ExtCtrls, xLabel, xRTF,
  Registry, xBasics, xMsgBox, mmOptions;

type
  TfrmPrintReport = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SaveDialog: TSaveDialog;
    FormPlaceSaver1: TFormPlaceSaver;
    dsReport2: TDataSource;
    dsReport1: TDataSource;
    Panel3: TPanel;
    xlbReport: TxLabel;
    Panel4: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edFile: TEdit;
    procedure xReportReportReady(Sender: TObject; var RTFFile: TxRTFFile);
    procedure mbbFormClick(Sender: TObject);
    procedure mbbSaveClick(Sender: TObject);
    procedure mbbPrintClick(Sender: TObject);
    procedure mbbCloseClick(Sender: TObject);
    procedure mbbValuesClick(Sender: TObject);
    procedure mbbTableClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure mbbWordDDEClick(Sender: TObject);
    procedure mBitButton1Click(Sender: TObject);
  private
  public
    RTFFile: String;
    SourceFileName: string;
    SaveFile: Boolean;
    Saved: Boolean;

    procedure Save;
  end;

var
  frmPrintReport: TfrmPrintReport;

implementation

{$R *.DFM}

uses
  frmValues_unit, frmViewGrid_unit, RentaBasics_unit;

{public --------------------------------------------------}

procedure TfrmPrintReport.Save;
begin
  SaveDialog.FileName := edFile.Text;
  if SaveDialog.Execute then
  begin
    edFile.Text := SaveDialog.FileName;
    SaveFile := False;
    Saved := True;
  end;
end;

{events --------------------------------------------------}


procedure TfrmPrintReport.xReportReportReady(Sender: TObject;
  var RTFFile: TxRTFFile);
begin
  Viewer.ExchangeData(RTFFile);
end;

procedure TfrmPrintReport.mbbFormClick(Sender: TObject);
begin
  WordFile(xReport.FormFile);
end;

procedure TfrmPrintReport.mbbSaveClick(Sender: TObject);
begin
  Save;
end;

procedure TfrmPrintReport.mbbPrintClick(Sender: TObject);
begin
  if not Viewer.Data.PrintRTF2 then
    Viewer.Invalidate;
end;

procedure TfrmPrintReport.mbbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrintReport.mbbValuesClick(Sender: TObject);
var
  frmValues: TfrmValues;
  I: Integer;
begin
  frmValues := TfrmValues.Create(Self);
  try
    frmValues.Memo.Clear;
    for I := 0 to xReport.Vars.Count - 1 do
      frmValues.Memo.Lines.Add(xReport.Vars.Names[I] + '=' + xReport.Vars.Values[I]);
    frmValues.ShowModal;
  finally
    frmValues.Free;
  end;
end;

procedure TfrmPrintReport.mbbTableClick(Sender: TObject);
var
  frmViewGrid: TfrmViewGrid;
begin
  frmViewGrid := TfrmViewGrid.Create(Self);
  try
    if dsReport1.DataSet <> nil then
    begin
      frmViewGrid.Grid.DataSource := dsReport1;
      frmViewGrid.ShowModal;
    end;
    if dsReport2.DataSet <> nil then
    begin
      frmViewGrid.Grid.DataSource := dsReport2;
      frmViewGrid.ShowModal;
    end;
  finally
    frmViewGrid.Free;
  end;
end;

procedure TfrmPrintReport.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if SaveFile and (MessageBox(Handle, 'Сохранить данный документ на диск?', 'Внимание!',
      MB_ICONQUESTION or MB_YESNO) = mrYes) then
  begin
    Viewer.SaveRTF(edFile.Text);
    Saved := True;
  end;
end;

procedure TfrmPrintReport.FormCreate(Sender: TObject);
begin
  SaveFile := False;
  Saved := False;
end;

procedure TfrmPrintReport.mbbWordDDEClick(Sender: TObject);
var
  NameRTFChar, Path: array [0..255] of Char;
  NameRTF: String;
begin
  GetTempPath(SizeOf(Path), Path);
  GetTempFileName(Path, 'rtf', 0, NameRTFChar);
  NameRTF := StrPas(NameRTFChar);
  Viewer.SaveRTF(NameRTF);

  WordFile(NameRTF);
end;

procedure TfrmPrintReport.mBitButton1Click(Sender: TObject);
begin
  xReport.Execute;
end;

end.
