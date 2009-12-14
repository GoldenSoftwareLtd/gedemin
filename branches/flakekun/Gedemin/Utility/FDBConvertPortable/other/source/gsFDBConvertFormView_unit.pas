unit gsFDBConvertFormView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsFDBConvertController_unit, ComCtrls, ExtCtrls, ActnList,
  Grids;

type
  TgsFDBConvertFormView = class(TForm)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pcMain: TPageControl;
    tbs01: TTabSheet;
    tbs02: TTabSheet;
    tbs03: TTabSheet;
    pnlButtons: TPanel;
    btnExit: TButton;
    btnNext: TButton;
    btnPrev: TButton;
    tbs04: TTabSheet;
    tbs05: TTabSheet;
    tbs06: TTabSheet;
    tbs08: TTabSheet;
    lblHello: TLabel;
    lblLanguage: TLabel;
    cbLanguage: TComboBox;
    lblDatabaseBrowseDescription: TLabel;
    btnDatabaseBrowse: TButton;
    ActionList1: TActionList;
    actPrevPage: TAction;
    actNextPage: TAction;
    actClose: TAction;
    lblStep01: TLabel;
    lblStep02: TLabel;
    lblStep03: TLabel;
    lblStep04: TLabel;
    lblStep05: TLabel;
    lblStep06: TLabel;
    lblStep08: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel8: TBevel;
    lblOriginalFunction: TLabel;
    eDatabaseName: TEdit;
    sgSubstituteList: TStringGrid;
    pbMain: TProgressBar;
    mProgress: TMemo;
    eOriginalDatabase: TEdit;
    lblOriginalDatabase: TLabel;
    lblOriginalDBVersion: TLabel;
    eOriginalDBVersion: TEdit;
    lblOriginalServerVersion: TLabel;
    eOriginalServerVersion: TEdit;
    lblNewServerVersion: TLabel;
    eNewServerVersion: TEdit;
    lblBackupName: TLabel;
    eBackupName: TEdit;
    btnBrowseBackupName: TButton;
    lblTempDatabaseName: TLabel;
    eTempDatabaseName: TEdit;
    btnBrowseTempDatabaseName: TButton;
    lblPageSize: TLabel;
    eBufferSize: TEdit;
    cbPageSize: TComboBox;
    lblPageSize_02: TLabel;
    lblBufferSize: TLabel;
    lblBufferSize_02: TLabel;
    lblCharacterSet: TLabel;
    cbCharacterSet: TComboBox;
    lblSubstituteFunction: TLabel;
    mProcessInformation: TMemo;
    actBrowseBackupFile: TAction;
    actBrowseCopyFile: TAction;
    tbs07: TTabSheet;
    Bevel7: TBevel;
    lblStep07: TLabel;
    mAfterProcessInformation: TMemo;
    procedure btnDatabaseBrowseClick(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actNextPageExecute(Sender: TObject);
    procedure actPrevPageExecute(Sender: TObject);
    procedure actPrevPageUpdate(Sender: TObject);
    procedure actNextPageUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbLanguageChange(Sender: TObject);
    procedure tbs05Show(Sender: TObject);
    procedure tbs06Show(Sender: TObject);
    procedure actBrowseBackupFileExecute(Sender: TObject);
    procedure actBrowseCopyFileExecute(Sender: TObject);
  private
    FConvertController: TgsFDBConvertController;

    procedure SetEnabledToControls(const AEnabled: Boolean);
    procedure InitializeLocalization;
  public
    procedure AddMessage(const AMessage: String);

    procedure DisableControls;
    procedure EnableControls;
  end;

  // Функция обработки сообщений API-функции копирования файла
  function FormCopyProgressRoutine(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: TLargeInteger;
    dwStreamNumber, dwCallbackReason: DWORD; hSourceFile, hDestinationFile: THandle; lpData: Pointer): DWORD; stdcall;
  // Функция обработки сообщений сервисов сервера
  procedure FormServiceProgressRoutine(const AServiceMessage: String);
  // Функция обработки сообщений при редактировании метаданных
  procedure FormMetadataProgressRoutine(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);


var
  gsFDBConvertFormView: TgsFDBConvertFormView;

implementation

uses
  gsFDBConvertLocalization_unit;

{$R *.DFM}

function FormCopyProgressRoutine(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: TLargeInteger;
  dwStreamNumber, dwCallbackReason: DWORD; hSourceFile, hDestinationFile: THandle; lpData: Pointer): DWORD; stdcall;
const
  PROGRESS_BAR_SIZE = 1000;
var
  CurrentPercent: Integer;
begin
  Result := 0;
  if TotalBytesTransferred = 0 then
    gsFDBConvertFormView.AddMessage(Format('%s: %s', [TimeToStr(Time), GetLocalizedString(lsDatabaseFileCopyingProcess)]));

  // Установим параметры прогрессбара
  CurrentPercent := Round((TotalBytesTransferred / TotalFileSize) * PROGRESS_BAR_SIZE);
  if gsFDBConvertFormView.pbMain.Max <> PROGRESS_BAR_SIZE then
    gsFDBConvertFormView.pbMain.Max := PROGRESS_BAR_SIZE;
  if gsFDBConvertFormView.pbMain.Position <> CurrentPercent then
    gsFDBConvertFormView.pbMain.Position := CurrentPercent;
end;

procedure FormServiceProgressRoutine(const AServiceMessage: String);
begin
  if Assigned(gsFDBConvertFormView) and (AServiceMessage <> '') then
  begin
    gsFDBConvertFormView.AddMessage(AServiceMessage);
  end;
end;

procedure FormMetadataProgressRoutine(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);
begin
  // Установим параметры прогрессбара
  if gsFDBConvertFormView.pbMain.Max <> AMaxProgress then
    gsFDBConvertFormView.pbMain.Max := AMaxProgress;
  if gsFDBConvertFormView.pbMain.Position <> ACurrentProgress then
    gsFDBConvertFormView.pbMain.Position := ACurrentProgress;
  // Выведем переданнное сообщение
  if AMessage <> '' then
    gsFDBConvertFormView.AddMessage(AMessage);
end;

procedure TgsFDBConvertFormView.btnDatabaseBrowseClick(Sender: TObject);
var
  odDatabase: TOpenDialog;
begin
  odDatabase := TOpenDialog.Create(Self);
  try
    odDatabase.DefaultExt := 'FDB';
    odDatabase.Filter := Format('%s|*.*|%s (*.FDB; *.GDB), %s (*.BK)|*.FDB;*.GDB;*.BK',
      [GetLocalizedString(lsAllFilesBrowseMask),
       GetLocalizedString(lsDatabaseBrowseMask),
       GetLocalizedString(lsBackupBrowseMask)]);
    odDatabase.Options := [ofHideReadOnly, ofFileMustExist];

    if odDatabase.Execute then
      eDatabaseName.Text := odDatabase.Filename;
  finally
    FreeAndNil(odDatabase);
  end;
end;

procedure TgsFDBConvertFormView.actCloseExecute(Sender: TObject);
begin
  gsFDBConvertFormView.Close;
end;

procedure TgsFDBConvertFormView.actNextPageExecute(Sender: TObject);
begin
  if pcMain.ActivePage <> tbs08 then
  begin
    // Переход со страницы "2/8 - Выбор файла базы данных"
    if pcMain.ActivePage = tbs02 then
    begin
      if eDatabaseName.Text = '' then
      begin
        eDatabaseName.SetFocus;
        Application.MessageBox(PChar(GetLocalizedString(lsChooseDatabaseMessage)),
          PChar(GetLocalizedString(lsInformationDialogCaption)), MB_OK or MB_ICONWARNING or MB_APPLMODAL);
        Exit;
      end
      else
      begin
        // Укажем что это новый процесс конвертации
        FConvertController.ClearConvertParams;
        // Установить параметры конвертации (на этом шаге устанавливается только имя БД)
        FConvertController.SetProcessParameters;
        // Получить предварительную информацию о процессе конвертации
        FConvertController.ViewPreProcessInformation;
      end;
    end;

    // Переход со страницы "3/8 - Подробная информация"
    if pcMain.ActivePage = tbs03 then
    begin
      try
        // Установить параметры конвертации (на этом шаге устанавливаются все остальные параметры, кроме заменяемых функций)
        FConvertController.SetProcessParameters;
        // ПРоверить правильность указанных параметров
        FConvertController.CheckProcessParams;
      except
        on E: Exception do
        begin
          Application.MessageBox(PChar(E.Message),
            PChar(GetLocalizedString(lsInformationDialogCaption)), MB_OK or MB_ICONWARNING or MB_APPLMODAL);
          Exit;
        end;
      end;
    end;

    pcMain.ActivePageIndex := pcMain.ActivePageIndex + 1;
  end;
end;

procedure TgsFDBConvertFormView.actPrevPageExecute(Sender: TObject);
begin
  if pcMain.ActivePage <> tbs01 then
    pcMain.ActivePageIndex := pcMain.ActivePageIndex - 1;
end;

procedure TgsFDBConvertFormView.actPrevPageUpdate(Sender: TObject);
begin
  actPrevPage.Enabled := (pcMain.ActivePage <> tbs01);
end;

procedure TgsFDBConvertFormView.actNextPageUpdate(Sender: TObject);
begin
  actNextPage.Enabled := (pcMain.ActivePage <> tbs08);
end;

procedure TgsFDBConvertFormView.FormShow(Sender: TObject);
begin
  pcMain.ActivePage := tbs01;
  InitializeLocalization;
end;

procedure TgsFDBConvertFormView.AddMessage(const AMessage: String);
begin
  mProgress.Lines.Add(AMessage);
end;

procedure TgsFDBConvertFormView.FormCreate(Sender: TObject);
var
  TabCounter: Integer;
begin
  // Скроем заголовки табов
  for TabCounter := 0 to pcMain.PageCount - 1 do
    pcMain.Pages[TabCounter].TabVisible := False;

  FConvertController := TgsFDBConvertController.Create(Self);
  FConvertController.ProcessForm := Self;
  FConvertController.SetupDialogForm;
end;

procedure TgsFDBConvertFormView.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FConvertController);
end;

procedure TgsFDBConvertFormView.cbLanguageChange(Sender: TObject);
begin
  FConvertController.LoadLanguage(cbLanguage.Items[cbLanguage.ItemIndex]);
  // Заполнить визуальные элементы локализованным текстом
  InitializeLocalization;
end;

procedure TgsFDBConvertFormView.DisableControls;
begin
  SetEnabledToControls(False);
end;

procedure TgsFDBConvertFormView.EnableControls;
begin
  SetEnabledToControls(True);
end;

procedure TgsFDBConvertFormView.SetEnabledToControls(const AEnabled: Boolean);
begin
  btnPrev.Enabled := AEnabled;
  btnNext.Enabled := AEnabled;
  btnExit.Enabled := AEnabled;
end;

procedure TgsFDBConvertFormView.tbs05Show(Sender: TObject);
begin
  // Установить параметры конвертации (на этом шаге устанавливаются все остальные параметры)
  FConvertController.SetProcessParameters;
  // Получить информацию о процессе конвертации
  FConvertController.ViewPreProcessInformation;
end;

procedure TgsFDBConvertFormView.tbs06Show(Sender: TObject);
begin
  FConvertController.DoConvertDatabase;
end;

procedure TgsFDBConvertFormView.actBrowseBackupFileExecute(Sender: TObject);
var
  sdDatabase: TSaveDialog;
begin
  sdDatabase := TSaveDialog.Create(Self);
  try
    sdDatabase.DefaultExt := 'BK';
    sdDatabase.Filter := Format('%s|*.*|%s (*.BK)|*.BK',
      [GetLocalizedString(lsAllFilesBrowseMask),
       GetLocalizedString(lsBackupBrowseMask)]);
    sdDatabase.Options := [ofHideReadOnly, ofPathMustExist];

    if sdDatabase.Execute then
      eBackupName.Text := sdDatabase.Filename;
  finally
    FreeAndNil(sdDatabase);
  end;
end;

procedure TgsFDBConvertFormView.actBrowseCopyFileExecute(Sender: TObject);
var
  sdDatabase: TSaveDialog;
begin
  sdDatabase := TSaveDialog.Create(Self);
  try
    sdDatabase.DefaultExt := 'FDB';
    sdDatabase.Filter := Format('%s|*.*|%s (*.FDB; *.GDB)|*.FDB;*.GDB',
      [GetLocalizedString(lsAllFilesBrowseMask),
       GetLocalizedString(lsDatabaseBrowseMask)]);
    sdDatabase.Options := [ofHideReadOnly, ofPathMustExist];

    if sdDatabase.Execute then
      eTempDatabaseName.Text := sdDatabase.Filename;
  finally
    FreeAndNil(sdDatabase);
  end;
end;

procedure TgsFDBConvertFormView.InitializeLocalization;
begin
  lblStep01.Caption := '1/8 - ' + GetLocalizedString(lsStep01);
  lblHello.Caption := GetLocalizedString(lsHello);
  lblLanguage.Caption := GetLocalizedString(lsLanguage) + ':';
  lblStep02.Caption := '2/8 - ' + GetLocalizedString(lsStep02);
  lblDatabaseBrowseDescription.Caption := GetLocalizedString(lsDatabaseBrowseDescription) + ':';
  lblStep03.Caption := '3/8 - ' + GetLocalizedString(lsStep03);
  lblOriginalDatabase.Caption := GetLocalizedString(lsOriginalDatabase) + ':';
  lblOriginalDBVersion.Caption := GetLocalizedString(lsOriginalDBVersion) + ':';
  lblOriginalServerVersion.Caption := GetLocalizedString(lsOriginalServerVersion) + ':';
  lblNewServerVersion.Caption := GetLocalizedString(lsNewServerVersion) + ':';
  lblBackupName.Caption := GetLocalizedString(lsBackupName) + ':';
  lblTempDatabaseName.Caption := GetLocalizedString(lsTempDatabaseName) + ':';
  lblPageSize.Caption := GetLocalizedString(lsPageSize) + ':';
  lblPageSize_02.Caption := GetLocalizedString(lsPageSize_02);
  lblBufferSize.Caption := GetLocalizedString(lsBufferSize) + ':';
  lblBufferSize_02.Caption := GetLocalizedString(lsBufferSize_02);
  lblCharacterSet.Caption := GetLocalizedString(lsCharacterSet) + ':';
  lblStep04.Caption := '4/8 - ' + GetLocalizedString(lsStep04);
  lblOriginalFunction.Caption := GetLocalizedString(lsOriginalFunction);
  lblSubstituteFunction.Caption := GetLocalizedString(lsSubstituteFunction);
  lblStep05.Caption := '5/8 - ' + GetLocalizedString(lsStep05);
  lblStep06.Caption := '6/8 - ' + GetLocalizedString(lsStep06);
  lblStep07.Caption := '7/8 - ' + GetLocalizedString(lsStep07);
  lblStep08.Caption := '8/8 - ' + GetLocalizedString(lsStep08);
  btnPrev.Caption := '< ' + GetLocalizedString(lsPrevButton);
  btnNext.Caption := GetLocalizedString(lsNextButton) + ' >';
  btnExit.Caption := GetLocalizedString(lsExitButton);
  btnDatabaseBrowse.Caption := GetLocalizedString(lsDatabaseBrowseButton) + ' ...';
end;

end.
