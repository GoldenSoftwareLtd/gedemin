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
    tbs07: TTabSheet;
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
    lblStep07: TLabel;
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
    lblSubstituteFunction: TLabel;
    mProcessInformation: TMemo;
    actBrowseBackupFile: TAction;
    actBrowseCopyFile: TAction;
    GroupBox1: TGroupBox;
    lblBackupName: TLabel;
    lblTempDatabaseName: TLabel;
    eTempDatabaseName: TEdit;
    eBackupName: TEdit;
    btnBrowseBackupName: TButton;
    btnBrowseTempDatabaseName: TButton;
    GroupBox2: TGroupBox;
    lblOriginalDatabase: TLabel;
    lblOriginalDBVersion: TLabel;
    lblOriginalServerVersion: TLabel;
    eOriginalServerVersion: TEdit;
    eOriginalDBVersion: TEdit;
    eOriginalDatabase: TEdit;
    GroupBox3: TGroupBox;
    lblNewServerVersion: TLabel;
    eNewServerVersion: TEdit;
    lblBAKDatabaseCopy: TLabel;
    eBAKDatabaseCopy: TEdit;
    lblNeedFreeSpace: TLabel;
    Image1: TImage;
    lblStep04Comment: TLabel;
    lblStep07Comment: TLabel;
    actBrowseOriginalDatabase: TAction;
    lblCurrentProgressStep: TLabel;
    eNeedFreeSpace: TMemo;
    Animate: TAnimate;
    pnlDBProperties: TPanel;
    lblPageSize: TLabel;
    lblPageSize_02: TLabel;
    lblBufferSize: TLabel;
    lblBufferSize_02: TLabel;
    lblCharacterSet: TLabel;
    cbPageSize: TComboBox;
    eBufferSize: TEdit;
    cbCharacterSet: TComboBox;
    lblLink: TLabel;
    sgDeleteUDF: TStringGrid;
    lblDeleteUdf: TLabel;
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
    procedure actBrowseOriginalDatabaseExecute(Sender: TObject);
    procedure eBackupNameChange(Sender: TObject);
    procedure eTempDatabaseNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lblLinkClick(Sender: TObject);
    procedure lblLinkMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnlButtonsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    FControlsEnabled: Boolean;
    FBeforeQuitActivePage: TTabSheet;
    FConvertController: TgsFDBConvertController;

    procedure SetEnabledToControls(const AEnabled: Boolean);
    procedure InitializeLocalization;
  public
    procedure AddMessage(const AMessage: String);
    procedure SetCurrentStep(const AStepText: String);

    procedure DisableControls;
    procedure EnableControls;
  end;

  // Функция обработки сообщений API-функции копирования файла
  procedure FormCopyProgressRoutine(TotalFileSize, TotalBytesTransferred: Int64);
  // Функция обработки сообщений сервисов сервера
  procedure FormServiceProgressRoutine(const AServiceMessage: String);
  // Функция обработки сообщений при редактировании метаданных
  procedure FormMetadataProgressRoutine(const AMessage: String; const AMaxProgress, ACurrentProgress: Integer);


var
  gsFDBConvertFormView: TgsFDBConvertFormView;

implementation

uses
  gsFDBConvertLocalization_unit, gsFDBConvertHelper_unit, ShellAPI;

{$R *.DFM}
{$R convert.res}

procedure FormCopyProgressRoutine(TotalFileSize, TotalBytesTransferred: Int64);
const
  PROGRESS_BAR_SIZE = 1000;
var
  CurrentPercent: Integer;
begin
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

procedure TgsFDBConvertFormView.actCloseExecute(Sender: TObject);
begin
  gsFDBConvertFormView.Close;
end;

procedure TgsFDBConvertFormView.actNextPageExecute(Sender: TObject);
begin
  if pcMain.ActivePage <> tbs07 then
  begin
    // Переход со страницы "2/8 - Выбор файла базы данных"
    if pcMain.ActivePage = tbs02 then
    begin
      if not FileExists(eDatabaseName.Text) then
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
        // Проверить правильность указанных параметров
        try
          FConvertController.CheckProcessParams(True);
        except
          // Ничего не делаем в случае исключения, потому что CheckProcessParams(True)
          //  будет отображать результаты проверки на форме
        end;  
      end;
    end;

    // Переход со страницы "3/8 - Подробная информация"
    if pcMain.ActivePage = tbs03 then
    begin
      try
        // Установить параметры конвертации (на этом шаге устанавливаются все остальные параметры, кроме заменяемых функций)
        FConvertController.SetProcessParameters;
        // Проверить правильность указанных параметров
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
  // Если возвращаемся с последней страницы, но попали на нее не с предпоследней
  if Assigned(FBeforeQuitActivePage) then
  begin
    pcMain.ActivePage := FBeforeQuitActivePage;
    FBeforeQuitActivePage := nil;
  end
  else
  begin
    if pcMain.ActivePage <> tbs01 then
      pcMain.ActivePageIndex := pcMain.ActivePageIndex - 1;
  end;
end;

procedure TgsFDBConvertFormView.actPrevPageUpdate(Sender: TObject);
begin
  if FControlsEnabled then
    actPrevPage.Enabled := (pcMain.ActivePage <> tbs01);
end;

procedure TgsFDBConvertFormView.actNextPageUpdate(Sender: TObject);
begin
  if FControlsEnabled then
  begin
    if pcMain.ActivePage <> tbs07 then
    begin
      if pcMain.ActivePage = tbs02 then
        actNextPage.Enabled := FileExists(eDatabaseName.Text)
      else
        actNextPage.Enabled := True;
    end else
      actNextPage.Enabled := False;
  end;    
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
  //FConvertController.ProcessForm := Self;
  FConvertController.SetupDialogForm;

  FControlsEnabled := True;
  FBeforeQuitActivePage := nil;

  Animate.ResName := 'convert';
  Animate.ResHandle := hInstance;
  Animate.Active := True;
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
  actPrevPage.Enabled := AEnabled;
  actNextPage.Enabled := AEnabled;
  actClose.Enabled := AEnabled;

  FControlsEnabled := AEnabled;
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
    sdDatabase.FileName := eBackupName.Text;

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
    sdDatabase.Filename := eTempDatabaseName.Text;

    if sdDatabase.Execute then
      eTempDatabaseName.Text := sdDatabase.Filename;
  finally
    FreeAndNil(sdDatabase);
  end;
end;

procedure TgsFDBConvertFormView.InitializeLocalization;
begin
  Application.Title := GetLocalizedString(lsApplicationCaption);
  gsFDBConvertFormView.Caption := GetLocalizedString(lsApplicationCaption);

  lblStep01.Caption := '1/7 - ' + GetLocalizedString(lsStep01);
  lblHello.Caption := GetLocalizedString(lsHello);
  lblLanguage.Caption := GetLocalizedString(lsLanguage);
  lblStep02.Caption := '2/7 - ' + GetLocalizedString(lsStep02);
  lblDatabaseBrowseDescription.Caption := GetLocalizedString(lsDatabaseBrowseDescription);
  lblStep03.Caption := '3/7 - ' + GetLocalizedString(lsStep03);
  GroupBox1.Caption := Format(' %s ', [GetLocalizedString(lsStep03Group01)]);
  GroupBox2.Caption := Format(' %s ', [GetLocalizedString(lsStep03Group02)]);
  GroupBox3.Caption := Format(' %s ', [GetLocalizedString(lsStep03Group03)]);
  lblOriginalDatabase.Caption := GetLocalizedString(lsOriginalDatabase);
  lblOriginalDBVersion.Caption := GetLocalizedString(lsOriginalDBVersion);
  lblOriginalServerVersion.Caption := GetLocalizedString(lsOriginalServerVersion);
  lblNewServerVersion.Caption := GetLocalizedString(lsNewServerVersion);
  lblBackupName.Caption := GetLocalizedString(lsBackupName);
  lblTempDatabaseName.Caption := GetLocalizedString(lsTempDatabaseName);
  lblPageSize.Caption := GetLocalizedString(lsPageSize);
  lblPageSize_02.Caption := GetLocalizedString(lsPageSize_02);
  lblBufferSize.Caption := GetLocalizedString(lsBufferSize);
  lblBufferSize_02.Caption := GetLocalizedString(lsBufferSize_02);
  lblCharacterSet.Caption := GetLocalizedString(lsCharacterSet);
  lblNeedFreeSpace.Caption := GetLocalizedString(lsWantDiskSpace);
  lblStep04.Caption := '4/7 - ' + GetLocalizedString(lsStep04);
  lblOriginalFunction.Caption := GetLocalizedString(lsOriginalFunction);
  lblSubstituteFunction.Caption := GetLocalizedString(lsSubstituteFunction);
  lblStep04Comment.Caption := GetLocalizedString(lsStep04Comment);
  lblDeleteUdf.Caption := GetLocalizedString(lsDeleteUDF);
  lblStep05.Caption := '5/7 - ' + GetLocalizedString(lsStep05);
  lblStep06.Caption := '6/7 - ' + GetLocalizedString(lsStep06);
  lblStep07.Caption := '7/7 - ' + GetLocalizedString(lsStep07);
  lblStep07Comment.Caption := GetLocalizedString(lsStep07Comment);
  lblBAKDatabaseCopy.Caption := GetLocalizedString(lsBAKDatabaseCopy);

  actPrevPage.Caption := '< ' + GetLocalizedString(lsPrevButton);
  actNextPage.Caption := GetLocalizedString(lsNextButton) + ' >';
  actClose.Caption := GetLocalizedString(lsExitButton);
  actBrowseOriginalDatabase.Caption := GetLocalizedString(lsDatabaseBrowseButton);
end;

procedure TgsFDBConvertFormView.actBrowseOriginalDatabaseExecute(Sender: TObject);
var
  odDatabase: TOpenDialog;
begin
  odDatabase := TOpenDialog.Create(Self);
  try
    odDatabase.DefaultExt := 'FDB';
    odDatabase.Filter := Format('%s (*.FDB; *.GDB)|*.FDB;*.GDB|%s|*.*',
      [GetLocalizedString(lsDatabaseBrowseMask),
       GetLocalizedString(lsAllFilesBrowseMask)]);
    odDatabase.Options := [ofHideReadOnly, ofFileMustExist, ofEnableSizing];

    if odDatabase.Execute then
      eDatabaseName.Text := odDatabase.Filename;
  finally
    FreeAndNil(odDatabase);
  end;
end;

procedure TgsFDBConvertFormView.eBackupNameChange(Sender: TObject);
begin
  FConvertController.SetProcessParameters;
  try
    FConvertController.CheckProcessParams(True);
  except
  end;
end;

procedure TgsFDBConvertFormView.eTempDatabaseNameChange(Sender: TObject);
begin
  FConvertController.SetProcessParameters;
  try
    FConvertController.CheckProcessParams(True);
  except
  end;
end;

procedure TgsFDBConvertFormView.SetCurrentStep(const AStepText: String);
begin
  if AStepText > '' then
  begin
    lblCurrentProgressStep.Caption := AStepText + LINE_CUT;
    pbMain.Visible := True;
  end else
  begin
    lblCurrentProgressStep.Caption := '';
    pbMain.Visible := False;
  end;
end;

procedure TgsFDBConvertFormView.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  // Если мы находимся в процессе конвертации, то нельзя закрыть приложение
  if Assigned(FConvertController) and FConvertController.InConvertingProcess then
  begin
    CanClose := False;
  end
  else
  begin
    // Если мы находимся не на последней странице, то перейдем на нее
    if pcMain.ActivePage <> tbs07 then
    begin
      CanClose := False;
      // Запомним последнюю активную вкладку
      FBeforeQuitActivePage := pcMain.ActivePage;
      pcMain.ActivePage := tbs07;
    end
    else
    begin
      CanClose := True;
    end;
  end;
end;

procedure TgsFDBConvertFormView.lblLinkClick(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://www.gsbelarus.com',
    nil,
    nil,
    SW_SHOW);
  lblLink.Font.Color := clWindowText;
end;

procedure TgsFDBConvertFormView.lblLinkMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  lblLink.Font.Color := clBlue;
end;

procedure TgsFDBConvertFormView.pnlButtonsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  lblLink.Font.Color := clWindowText;
end;

end.
