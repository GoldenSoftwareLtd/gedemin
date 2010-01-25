
{
  1.01 bug with spaces in file name fixed.
}

unit xRepPrvF;

interface

uses
  Windows, WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, xRTF, xRTFView, ExtCtrls, Dialogs, xBulbBtn, SysUtils,
  ComCtrls, ComObj, Registry,
  xBasics, gsMultilingualSupport;

type
  TxReportPreviewForm = class(TForm)
    Panel1: TPanel;
    Viewer: TxRTFViewer;
    BottomPanel: TPanel;
    SaveDialog: TSaveDialog;
    BtnPanel: TPanel;
    xBulbButton1: TxBulbButton;
    xBulbButton2: TxBulbButton;
    xBulbButton3: TxBulbButton;
    Panel2: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton5: TSpeedButton;
    xRTFScaleCombo1: TxRTFScaleCombo;
    SpeedButton1: TSpeedButton;
    Panel3: TPanel;
    SpeedButton7: TSpeedButton;
    Label1: TLabel;
    SpeedButton2: TSpeedButton;
    gsMultilingualSupport1: TgsMultilingualSupport;

    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BottomPanelResize(Sender: TObject);
    procedure xBulbButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SourceFileName: string;
  end;

var
  xReportPreviewForm: TxReportPreviewForm;

implementation

{$R *.DFM}

procedure TxReportPreviewForm.FormActivate(Sender: TObject);
begin
  Viewer.SetFocus;
end;

procedure TxReportPreviewForm.OKBtnClick(Sender: TObject);
begin
  if Viewer.Data.PrintRTF{2} then
    Close;
end;

procedure TxReportPreviewForm.BitBtn1Click(Sender: TObject);
begin
  if SaveDialog.Execute then
    Viewer.SaveRTF(SaveDialog.FileName);
end;

procedure TxReportPreviewForm.BottomPanelResize(Sender: TObject);
begin
  BtnPanel.Left := (BottomPanel.Width - BtnPanel.Width) div 2;
end;

procedure TxReportPreviewForm.xBulbButton3Click(Sender: TObject);
begin
  Close;
end;

procedure TxReportPreviewForm.SpeedButton5Click(Sender: TObject);
begin
  if Viewer.Data.PrintRTF2 then
    Close
  else
    Viewer.Invalidate;
end;

procedure TxReportPreviewForm.SpeedButton7Click(Sender: TObject);
begin
  Close;
end;

procedure TxReportPreviewForm.SpeedButton3Click(Sender: TObject);
begin
  if SaveDialog.Execute then
    Viewer.SaveRTF(SaveDialog.FileName);
end;

procedure TxReportPreviewForm.SpeedButton1Click(Sender: TObject);
var
  p, p1: array[0..1000] of byte;
begin
  StrPCopy(@p, TranslateText('Информация об отчете:') + #13 +
     TranslateText('  Исходный файл отчета: ') + RealFileName(SourceFileName) + #13 +
     TranslateText('  Занимаемая структурой память: ') + IntToStr(Viewer.RTFFile.MemoryUsed));
  StrPCopy(@p1, TranslateText('Информация'));
  MessageBox(handle, @p, @p1, ID_OK);
end;

procedure TxReportPreviewForm.SpeedButton2Click(Sender: TObject);
var
  Reg: TRegistry;
  KeyPath, WordPath: string;
  StartupInfo: TStartupInfo;
  aProcess: TProcessInformation;
  Works: Boolean;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;

    Works := Reg.OpenKey('Word.Backup\CLSID', False);

    if not Works then
     Works := Reg.OpenKey('Word.Application\CLSID', False);

    KeyPath := Reg.ReadString('');

    if Works and Reg.OpenKey('\CLSID\' + KeyPath + '\LocalServer32', False) then
      WordPath := Reg.ReadString('')

    else
     begin
       ShowMessage(TranslateText('Информация о Microsoft Word в реестре отсутствует. ') +
                   TranslateText('Переинсталлируйте пакет Microsoft Office!'));
       Exit;
     end;
  finally
    Reg.Free;
  end;

  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    wShowWindow := SW_RESTORE;
  end;

  if CreateProcess(nil, PChar(WordPath + ' "' + RealFileName(SourceFileName) + '"'), nil, nil, false,
     NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, aProcess) then
    ShowMessage(TranslateText('Исходная форма открыта в редакторе Microsoft Word и может быть откорректирована.'))
  else
    ShowMessage(TranslateText('Ошибка открытия программы Microsoft Word. Переинсталлируйте пакет Microsoft Office!'));

  Close;
end;

end.

