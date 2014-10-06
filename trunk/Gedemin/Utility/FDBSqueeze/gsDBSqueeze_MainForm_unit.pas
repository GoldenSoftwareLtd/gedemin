unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, ActnList, ComCtrls, Buttons, StdCtrls, Grids, Spin, ExtCtrls,
  gsDBSqueeze_CardMergeForm_unit, gsDBSqueeze_DocTypesForm_unit,
  gsDBSqueezeThread_unit, gsDBSqueezeIniOptions_unit, gd_ProgressNotifier_unit,
  gdMessagedThread, CommCtrl, Db, Menus, Registry;

const
  DEFAULT_USER_NAME = 'SYSDBA';
  DEFAULT_PASSWORD = 'masterkey';
  DEFAULT_CHARACTER_SET = 'WIN1251';
  DEFAULT_BUFFER = 20000;
  CHARSET_LIST_CH1 = 'NONE, CYRL, DOS437, DOS737, DOS775, DOS850, DOS852, DOS857, DOS858, DOS860, DOS861, DOS862, DOS863, DOS864, DOS865, DOS866, DOS869, ISO8859_1, ISO8859_13, ISO8859_2, ISO8859_3, ISO8859_4, ISO8859_5, ISO8859_6, ISO8859_7';
  CHARSET_LIST_CH2 = 'ISO8859_8, ISO8859_9, KOI8R, KOI8U, NEXT, TIS620, WIN1250, WIN1251, WIN1252, WIN1253, WIN1254, WIN1255, WIN1256, WIN1257, WIN1258, ASCII, UNICODE_FSS, UTF8';
  MAX_PROGRESS_STEP = 12500;
  PROGRESS_COLOR = $001F67FC;

  WM_STOPNOTIFY = WM_GD_THREAD_USER + 42;

type
  TgsDBSqueeze_MainForm = class(TForm, IgdProgressWatch)
    actAbout: TAction;
    actCardSetup: TAction;
    actClearLog: TAction;
    actCompany: TAction;
    actConfigBrowse: TAction;
    actConnect: TAction;
    actDatabaseBrowse: TAction;
    actDefocus: TAction;
    actDisconnect: TAction;
    actExit: TAction;
    actGet: TAction;
    actGo: TAction;
    ActionList: TActionList;
    actLoadConfig: TAction;
    actMergeCardDlg: TAction;
    actSaveConfig: TAction;
    actSaveLog: TAction;
    actSelectDocTypes: TAction;
    actStop: TAction;
    actUpdate: TAction;
    btnClearGeneralLog: TButton;
    btnConnect: TButton;
    btnDatabaseBrowse: TButton;
    btnGetStatistics: TButton;
    btntTestConnection: TButton;
    btnUpdateStatistics: TBitBtn;
    cbbCharset: TComboBox;
    edDatabaseName: TEdit;
    edPassword: TEdit;
    edUserName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lblProgress: TLabel;
    MainMenu: TMainMenu;
    mLog: TMemo;
    mSqlLog: TMemo;
    N10: TMenuItem;
    N11: TMenuItem;                             
    N13: TMenuItem;
    N14: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    Panel1: TPanel;
    pbMain: TProgressBar;
    pgcMain: TPageControl;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl4: TPanel;
    pnlLogButton: TPanel;
    pnlLogs: TPanel;
    shp10: TShape;
    shp2: TShape;
    shp3: TShape;
    shp4: TShape;
    shp6: TShape;
    Splitter1: TSplitter;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    stConnect: TStaticText;
    STOP1: TMenuItem;
    sttxt11: TStaticText;
    sttxt2: TStaticText;
    sttxt30: TStaticText;
    sttxt32: TStaticText;
    sttxt34: TStaticText;
    sttxt3: TStaticText;
    sttxt4: TStaticText;
    sttxt5: TStaticText;
    sttxt6: TStaticText;
    sttxtAcEntry: TStaticText;
    sttxtAcEntryAfter: TStaticText;
    sttxtAfterProcAcEntry: TStaticText;
    sttxtAfterProcGdDoc: TStaticText;
    sttxtAfterProcInvCard: TStaticText;
    sttxtAfterProcInvMovement: TStaticText;
    sttxtDialect: TStaticText;
    sttxtForcedWrites: TStaticText;
    sttxtGarbageCollection: TStaticText;
    sttxtGdDoc: TStaticText;
    sttxtGdDocAfter: TStaticText;
    sttxtInvCard: TStaticText;
    sttxtInvCardAfter: TStaticText;
    sttxtInvMovement: TStaticText;
    sttxtInvMovementAfter: TStaticText;
    sttxtODSVer: TStaticText;
    sttxtPageBuffers: TStaticText;
    sttxtPageSize: TStaticText;
    sttxtProcAcEntry: TStaticText;
    sttxtProcGdDoc: TStaticText;
    sttxtProcInvCard: TStaticText;
    sttxtProcInvMovement: TStaticText;
    sttxtRemoteAddr: TStaticText;
    sttxtRemoteProtocol: TStaticText;
    sttxtServerVer: TStaticText;
    sttxtUser: TStaticText;
    tsLogs: TTabSheet;
    tsSettings: TTabSheet;
    tsStatistics: TTabSheet;
    txt10: TStaticText;
    txt2: TStaticText;
    txt3: TStaticText;
    txt4: TStaticText;
    txt5: TStaticText;
    txt6: TStaticText;
    seBuffer: TSpinEdit;
    lbl4: TLabel;
    N12: TMenuItem;
    N15: TMenuItem;
    actSaldoTest: TAction;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    lbl5: TLabel;
    dtpClosingDate: TDateTimePicker;
    chkCalculateSaldo: TCheckBox;
    btnSelectDocTypes: TButton;
    mIgnoreDocTypes: TMemo;
    rbExcluding: TRadioButton;
    rbIncluding: TRadioButton;
    grpOptions: TGroupBox;
    chkGetStatiscits: TCheckBox;
    Panel3: TPanel;
    TEST1: TMenuItem;
    Panel4: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    StaticText29: TStaticText;
    sttxtOrigInvCard: TStaticText;
    sttxtCurInvCard: TStaticText;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    btnGetStatisticsInvCard: TButton;
    btnUpdateStatisticsInvCard: TBitBtn;
    txt1: TStaticText;
    actGetStatisticsInvCard: TAction;
    procedure actClearLogExecute(Sender: TObject);
    procedure actDatabaseBrowseExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure actGetUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure btnGetStatisticsMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actConnectUpdate(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actExitUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actSaveConfigExecute(Sender: TObject);
    procedure actLoadConfigExecute(Sender: TObject);
    procedure actSelectDocTypesExecute(Sender: TObject);
    procedure actSelectDocTypesUpdate(Sender: TObject);
    procedure actGoUpdate(Sender: TObject);
    procedure actLoadConfigUpdate(Sender: TObject);
    procedure actSaveConfigUpdate(Sender: TObject);
    procedure actCardSetupExecute(Sender: TObject);
    procedure actCardSetupUpdate(Sender: TObject);
    procedure actSaveLogExecute(Sender: TObject);
    procedure actSaveLogUpdate(Sender: TObject);
    procedure actDatabaseBrowseUpdate(Sender: TObject);
    procedure actDefocusExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actSaldoTestExecute(Sender: TObject);
    procedure actSaldoTestUpdate(Sender: TObject);
    procedure actGetStatisticsInvCardExecute(Sender: TObject);
    procedure actGetStatisticsInvCardUpdate(Sender: TObject);

  private
    FLogFileStream: TFileStream;
    FSThread: TgsDBSqueezeThread;

    FCardFeaturesList: TStringList;
    FConnected: Boolean;
    FDocTypesList: TStringList;
    FIsProcessStop: Boolean;
    FMergeDocTypesList: TStringList;
    FStartupTime: TDateTime;
    FWasSelectedDocTypes: Boolean;

    procedure DataDestroy;
    procedure RecLog(const ARec: String);
    procedure SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
    procedure WriteToLogFile(const AStr: String);

    procedure ErrorEvent(const AErrorMsg: String);
    procedure FinishEvent(const AIsFinished: Boolean);
    procedure GetCardFeaturesEvent(const ACardFatures: TStringList);
    procedure GetConnectedEvent(const AConnected: Boolean);
    procedure GetDBPropertiesEvent(const AProperties: TStringList);
    procedure GetProcStatisticsEvent(const AProcGdDoc: String; const AnProcAcEntry: String; const AnProcInvMovement: String; const AnProcInvCard: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String);
    procedure GetInvCardStatisticsEvent(const InvCardCount: String);
    procedure LogSQLEvent(const ALogSQL: String);
    procedure SetDocTypeBranchEvent(const ABranchList: TStringList);
    procedure SetDocTypeStringsEvent(const ADocTypes: TStringList);

    procedure StopNotify(var Msg: TMessage); message WM_STOPNOTIFY;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

uses
  gd_common_functions, gsDBSqueeze_AboutForm_unit;

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
var
  RegIni: TRegIniFile;
begin
  inherited;

  RegIni := TRegIniFile.Create('DBS');
  try
    edDatabaseName.Text := RegIni.ReadString('ConnectParams', 'Path', edDatabaseName.Text);
  finally
    RegIni.Free;
  end;

  FMergeDocTypesList := TStringList.Create;
  FCardFeaturesList := TStringList.Create;
  FDocTypesList := TStringList.Create;
  pgcMain.ActivePage := tsSettings;

  mSqlLog.Clear;
  mLog.ReadOnly := True;
  mSqlLog.ReadOnly := True;
  dtpClosingDate.Date := Date;
  edUserName.Text := DEFAULT_USER_NAME;
  edPassword.Text := DEFAULT_PASSWORD;
  seBuffer.Value := DEFAULT_BUFFER;
  pbMain.Max := MAX_PROGRESS_STEP;
  SendMessage(pbMain.Handle, PBM_SETBARCOLOR, 0, PROGRESS_COLOR);
  cbbCharset.Items.CommaText := CHARSET_LIST_CH1 + ',' + CHARSET_LIST_CH2;
  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);

  lblProgress.Parent := pbMain;
  lblProgress.Width := pbMain.Width - 8;
  lblProgress.Left := pbMain.Left + 4;
  lblProgress.Top := 2;
  lblProgress.Transparent := True;
  lblProgress.Caption := '';

  FStartupTime := Now;
  FConnected := False;
  FSThread := TgsDBSqueezeThread.Create(False);

  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetInvCardFeatures := GetCardFeaturesEvent;
  FSThread.OnSetDocTypeBranch := SetDocTypeBranchEvent;
  FSThread.OnGetInvCardStatistics := GetInvCardStatisticsEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  if Assigned(FLogFileStream) then
    FLogFileStream.Free;
  FMergeDocTypesList.Free;
  FCardFeaturesList.Free;
  FDocTypesList.Free;

  inherited;
end;

procedure TgsDBSqueeze_MainForm.DataDestroy;
begin
  seBuffer.Value := DEFAULT_BUFFER;
  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);
  dtpClosingDate.Date := Date;
  rbIncluding.Checked := True;
  mIgnoreDocTypes.Clear;
  chkGetStatiscits.Checked := True;

  sttxtOrigInvCard.Caption := '';
  sttxtCurInvCard.Caption := '';
  sttxtUser.Caption := '';
  sttxtDialect.Caption := '';
  sttxtServerVer.Caption := '';
  sttxtODSVer.Caption := '';
  sttxtRemoteProtocol.Caption := '';
  sttxtRemoteAddr.Caption := '';
  sttxtPageSize.Caption := '';
  sttxtPageBuffers.Caption := '';
  sttxtForcedWrites.Caption := '';
  sttxtGarbageCollection.Caption := '';
  sttxtGdDoc.Caption := '';
  sttxtAcEntry.Caption := '';
  sttxtInvMovement.Caption := '';
  sttxtInvCard.Caption := '';
  sttxtGdDocAfter.Caption := '';
  sttxtAcEntryAfter.Caption := '';
  sttxtInvMovementAfter.Caption := '';
  sttxtInvCardAfter.Caption := '';
  sttxtProcGdDoc.Caption := '';
  sttxtProcAcEntry.Caption := '';
  sttxtProcInvMovement.Caption := '';
  sttxtProcInvCard.Caption := '';
  sttxtAfterProcGdDoc.Caption := '';
  sttxtAfterProcAcEntry.Caption := '';
  sttxtAfterProcInvMovement.Caption := '';
  sttxtAfterProcInvCard.Caption := '';

  FStartupTime := Now;
  FWasSelectedDocTypes := False;

  FDocTypesList.Clear;
  FMergeDocTypesList.Clear;
  FCardFeaturesList.Clear;

  if Assigned(FLogFileStream) then
    FreeAndNil(FLogFileStream);

  FreeAndNil(FSThread);
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetInvCardFeatures := GetCardFeaturesEvent;
  FSThread.OnSetDocTypeBranch := SetDocTypeBranchEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnGetInvCardStatistics := GetInvCardStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;

  gsDBSqueeze_DocTypesForm.DataDestroy;
  gsDBSqueeze_CardMergeForm.DataDestroy;

  SetProgress(' ', 0);
end;

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (FSThread = nil) or ((not FConnected) and (not FSThread.Busy)); //actExit.Enabled;
end;

// =============================== Меню ========================================

procedure TgsDBSqueeze_MainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TgsDBSqueeze_MainForm.actExitUpdate(Sender: TObject);
begin
  actExit.Enabled := (FSThread = nil) or ((not FConnected) and (not FSThread.Busy));
end;

procedure TgsDBSqueeze_MainForm.actConnectExecute(Sender: TObject);
var
  Server, FileName: String;
  Port: Integer;
  RegIni: TRegIniFile;
begin
  ParseDatabaseName(edDatabaseName.Text, Server, Port, FileName);

  if Trim(Server) = '' then
    Server := 'localhost';

  FSThread.SetDBParams(
    FileName,
    Server,
    edUserName.Text,
    edPassword.Text,
    cbbCharset.Text,
    seBuffer.Value,
    Port);
  FSThread.Connect;

  RegIni:=TRegIniFile.Create('DBS');
  try
    RegIni.WriteString('ConnectParams', 'Path', edDatabaseName.Text);
  finally
    RegIni.Free;
  end;  
end;

procedure TgsDBSqueeze_MainForm.actConnectUpdate(Sender: TObject);
begin
  actConnect.Enabled := not FConnected;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
begin
  GetConnectedEvent(False);
  DataDestroy;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
var
  I: Integer;
  LogFileName, BackupFileName: String;
begin

  if not FWasSelectedDocTypes then
    Application.MessageBox(PChar('Выбор типов документов обязателен! Осуществите выбор.'), PChar('Предупреждение'),
        MB_OK + MB_ICONWARNING + MB_TOPMOST)
  else begin
    LogFileName := '';
    BackupFileName := '';

    FSThread.SetClosingDate(dtpClosingDate.Date);

    FSThread.SetSaldoParams(
      True,
      chkCalculateSaldo.Checked);

    if FWasSelectedDocTypes then
    begin
      FDocTypesList.Clear;
      FDocTypesList.CommaText := gsDBSqueeze_DocTypesForm.GetSelectedIdDocTypes;
      if FDocTypesList.Count > 0 then
        FSThread.SetSelectDocTypes(FDocTypesList, rbIncluding.Checked);
    end;

    FSThread.DoGetStatisticsAfterProc := chkGetStatiscits.Checked;

    RecLog('====================== Settings =======================');

    RecLog('Database: ' + edDatabaseName.Text);
    RecLog('Username: ' + edUserName.Text);
    RecLog('Удалить документы с DOCUMENTDATE < ' + DateToStr(dtpClosingDate.Date));

    if chkCalculateSaldo.Checked then
      RecLog('Сохранить сальдо, вычисленное программой: ДА')
    else
      RecLog('Сохранить сальдо, вычисленное программой: НЕТ');

    if FDocTypesList.Count > 0 then
    begin
      if rbExcluding.Checked then
        RecLog('Не обрабатывать документы с  DOCUMENTTYPE: ')
      else
        RecLog('Обрабатывать только документы с DOCUMENTTYPE: ');
      for I:=0 to FDocTypesList.Count-1 do
        RecLog(FDocTypesList[I]);
    end;
    if chkGetStatiscits.Checked then
      RecLog('По завершению обработки получить статистику: ДА')
    else
      RecLog('По завершению обработки получить статистику: НЕТ');

    RecLog('=======================================================');
    RecLog(mLog.Text);

    if FSThread.DoGetStatisticsAfterProc then
    begin
      sttxtGdDoc.Caption := '';
      sttxtAcEntry.Caption := '';
      sttxtInvMovement.Caption := '';
      sttxtInvCard.Caption := '';
      sttxtGdDocAfter.Caption := '';
      sttxtAcEntryAfter.Caption := '';
      sttxtInvMovementAfter.Caption := '';
      sttxtInvCardAfter.Caption := '';
      sttxtProcGdDoc.Caption := '';
      sttxtProcAcEntry.Caption := '';
      sttxtProcInvMovement.Caption := '';
      sttxtProcInvCard.Caption := '';
      sttxtAfterProcGdDoc.Caption := '';
      sttxtAfterProcAcEntry.Caption := '';
      sttxtAfterProcInvMovement.Caption := '';
      sttxtAfterProcInvCard.Caption := '';
    end;

    FSThread.StartProcessing;
  end;  
end;

procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  actGo.Enabled := Assigned(FSThread) and FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actStopExecute(Sender: TObject);
begin
  case Application.MessageBox(
    PChar('Прервать процесс обработки БД?' + #13#10 +
      'Возобновить процесс будет невозможно.'),
      PChar('Подтверждение'),
      MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) of
      IDOK:
        begin
          SetProgress('Прерывание...', 0);
          FSThread.MainFrmHandle := gsDBSqueeze_MainForm.Handle;
          FSThread.StopProcessing;
        end;
  end;
end;

procedure TgsDBSqueeze_MainForm.actStopUpdate(Sender: TObject);
begin
  actStop.Enabled := Assigned(FSThread) and FConnected and (not FIsProcessStop) and (FSThread.Busy);              
end;

procedure TgsDBSqueeze_MainForm.actSaveConfigExecute(Sender: TObject);
var
  SaveDlg: TSaveDialog;
begin
  SaveDlg := TSaveDialog.Create(Self);
  try
    SaveDlg.InitialDir := GetCurrentDir;
    SaveDlg.Options := [ofFileMustExist, ofEnableSizing];
    SaveDlg.Filter := 'Configuration File (*.INI)|*.ini';
    SaveDlg.FilterIndex := 1;
    SaveDlg.DefaultExt := 'ini';

    if SaveDlg.Execute then
    begin
      gsIniOptions.ClosingDate := dtpClosingDate.Date;
      gsIniOptions.DoCalculateSaldo := chkCalculateSaldo.Checked;
      gsIniOptions.DoProcessDocTypes := rbIncluding.Checked;
      gsIniOptions.SelectedDocTypeKeys := gsDBSqueeze_DocTypesForm.GetSelectedDocTypesStr;
      gsIniOptions.SelectedBranchRows := gsDBSqueeze_DocTypesForm.GetSelectedBranchRowsStr;
      gsIniOptions.MergingDate := gsDBSqueeze_CardMergeForm.GetDate;
      gsIniOptions.MergingDocTypeKeys := gsDBSqueeze_CardMergeForm.GetSelectedDocTypesStr;
      gsIniOptions.MergingBranchRows := gsDBSqueeze_CardMergeForm.GetSelectedBranchRowsStr;
      gsIniOptions.MergingCardFeatures := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;
      gsIniOptions.MergingFeaturesRows := gsDBSqueeze_CardMergeForm.GetSelectedFeaturesRows;

      gsIniOptions.SaveToFile(SaveDlg.FileName);
    end;
  finally
    SaveDlg.Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actSaveConfigUpdate(Sender: TObject);
begin
  actSaveConfig.Enabled :=  (FSThread <> nil) and FConnected;
end;

procedure TgsDBSqueeze_MainForm.actLoadConfigExecute(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(Self);
  try
    OpenDlg.InitialDir := GetCurrentDir;
    OpenDlg.Options := [ofFileMustExist, ofEnableSizing];
    OpenDlg.Filter := 'Configuration File (*.INI)|*.ini';
    OpenDlg.FilterIndex := 1;

    if OpenDlg.Execute then
    begin
      gsIniOptions.LoadFromFile(OpenDlg.FileName);

      dtpClosingDate.Date := gsIniOptions.ClosingDate;
      chkCalculateSaldo.Checked := gsIniOptions.DoCalculateSaldo;

      rbIncluding.Checked := False;
      rbExcluding.Checked := False;
      if gsIniOptions.DoProcessDocTypes then
        rbIncluding.Checked := True
      else
        rbExcluding.Checked := True;

      gsDBSqueeze_DocTypesForm.ClearSelection;
      gsDBSqueeze_DocTypesForm.SetSelectedDocTypes(gsIniOptions.SelectedDocTypeKeys, gsIniOptions.SelectedBranchRows);

      mIgnoreDocTypes.Clear;
      mIgnoreDocTypes.Text := gsDBSqueeze_DocTypesForm.GetDocTypeMemoText;
      FWasSelectedDocTypes := (Trim(mIgnoreDocTypes.Text) > '');

      gsDBSqueeze_CardMergeForm.ClearSelection;
      gsDBSqueeze_CardMergeForm.SetDate(gsIniOptions.MergingDate);
      gsDBSqueeze_CardMergeForm.SetSelectedDocTypes(gsIniOptions.MergingDocTypeKeys, gsIniOptions.MergingBranchRows);
      gsDBSqueeze_CardMergeForm.SetSelectedCardFeatures(gsIniOptions.MergingCardFeatures, gsIniOptions.MergingFeaturesRows);

      FMergeDocTypesList.Clear;
      FCardFeaturesList.Clear;

        FMergeDocTypesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes;
        FCardFeaturesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;
      
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actLoadConfigUpdate(Sender: TObject);
begin
  actLoadConfig.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actSaveLogExecute(Sender: TObject);
var
  SaveDlg: TSaveDialog;
begin
  SaveDlg := TSaveDialog.Create(Self);
  try
    SaveDlg.InitialDir := GetCurrentDir;
    SaveDlg.Options := [ofFileMustExist, ofEnableSizing];
    SaveDlg.Filter := 'Log File (*.LOG)|*.log';
    SaveDlg.FilterIndex := 1;
    SaveDlg.DefaultExt := 'log';
    SaveDlg.FileName := 'DBS_' +  FormatDateTime('yymmdd_hh-mm', FStartupTime) + '.log';

    if SaveDlg.Execute then
    begin
      if not FileExists(SaveDlg.FileName) then
        with TFileStream.Create(SaveDlg.FileName, fmCreate) do Free;

      FLogFileStream := TFileStream.Create(SaveDlg.FileName, fmOpenWrite or fmShareDenyNone);
    end;
  finally
    SaveDlg.Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actSaveLogUpdate(Sender: TObject);
begin
  actSaveLog.Enabled := FConnected and (not Assigned(FLogFileStream));
end;

// ============================= Параметры =====================================

procedure TgsDBSqueeze_MainForm.actDefocusExecute(Sender: TObject);
begin
  if Sender is TControl then
    gsDBSqueeze_MainForm.DefocusControl(TWinControl(Sender), False);
end;

procedure TgsDBSqueeze_MainForm.actDatabaseBrowseExecute(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  gsDBSqueeze_MainForm.DefocusControl(btnDatabaseBrowse, False);
  openDialog := TOpenDialog.Create(Self);
  try
    openDialog.InitialDir := GetCurrentDir;
    openDialog.Options := [ofFileMustExist, ofEnableSizing];
    openDialog.Filter := 'Firebird Database File (*.FDB)|*.fdb|InterBase Database File (*.GDB)|*.gdb|All Files|*.*';
    openDialog.FilterIndex := 1;

    if openDialog.Execute then
      edDatabaseName.Text := openDialog.FileName;
  finally
    openDialog.Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actDatabaseBrowseUpdate(Sender: TObject);
begin
  actDatabaseBrowse.Enabled := not FConnected;
end;

procedure TgsDBSqueeze_MainForm.actSelectDocTypesExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnSelectDocTypes, False);
  if gsDBSqueeze_DocTypesForm.ShowModal = mrOk then
    mIgnoreDocTypes.Text := gsDBSqueeze_DocTypesForm.GetDocTypeMemoText;
  FWasSelectedDocTypes := (mIgnoreDocTypes.Text > '');
end;

procedure TgsDBSqueeze_MainForm.actSelectDocTypesUpdate(Sender: TObject);
begin
  actSelectDocTypes.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actCardSetupExecute(Sender: TObject);
begin
  case gsDBSqueeze_CardMergeForm.ShowModal of
    mrYes:
      begin
        FMergeDocTypesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes;
        FCardFeaturesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;

        // получение статистики
        FSThread.DoGetStatisticsInvCardAfterProc := gsDBSqueeze_CardMergeForm.DoGetStatisticsAfterProc;
        // параметры объединения
        FSThread.SetMergeCardParams(gsDBSqueeze_CardMergeForm.GetDate, FMergeDocTypesList, FCardFeaturesList);
        // запуск объединения карточек
        FSThread.DoMergeCards;
      end;
  end;
end;

procedure TgsDBSqueeze_MainForm.actCardSetupUpdate(Sender: TObject);
begin
  actCardSetup.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

// ============================ Журнал =========================================

procedure TgsDBSqueeze_MainForm.actClearLogExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnClearGeneralLog, False);
  mLog.Clear;
  mSqlLog.Clear;
end;

//============================ Статистика ======================================

procedure TgsDBSqueeze_MainForm.actGetExecute(Sender: TObject);
begin
  FSThread.DoGetStatistics;
end;

procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
  actGet.Enabled := FConnected and (FSThread <> nil) and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.btnGetStatisticsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;

procedure TgsDBSqueeze_MainForm.actGetStatisticsInvCardExecute(
  Sender: TObject);
begin
  FSThread.DoGetStatisticsInvCard;
end;

procedure TgsDBSqueeze_MainForm.actGetStatisticsInvCardUpdate(
  Sender: TObject);
begin
  actGetStatisticsInvCard.Enabled := FConnected and (FSThread <> nil) and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actSaldoTestUpdate(Sender: TObject);
begin
  actSaldoTest.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

//==============================================================================

procedure TgsDBSqueeze_MainForm.GetConnectedEvent(const AConnected: Boolean);
begin
  if AConnected then
    stConnect.Caption := 'Подключено'
  else
    stConnect.Caption := 'Отключено';
  FConnected := AConnected;
end;

procedure  TgsDBSqueeze_MainForm.GetDBPropertiesEvent(const AProperties: TStringList);
begin
  sttxtUser.Caption := AProperties.Values['User'];
  sttxtDialect.Caption := AProperties.Values['SQLDialect'];
  sttxtServerVer.Caption := AProperties.Values['Server'];
  sttxtODSVer.Caption := AProperties.Values['ODS'];
  sttxtRemoteProtocol.Caption := AProperties.Values['RemoteProtocol'];
  sttxtRemoteAddr.Caption := AProperties.Values['RemoteAddress'];
  sttxtPageSize.Caption := AProperties.Values['PageSize'];
  sttxtPageBuffers.Caption := AProperties.Values['PageBuffers'];
  sttxtForcedWrites.Caption := AProperties.Values['ForcedWrites'];
  sttxtGarbageCollection.Caption := AProperties.Values['GarbageCollection'];
end;

procedure TgsDBSqueeze_MainForm.SetDocTypeStringsEvent(const ADocTypes: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypes(ADocTypes);
  gsDBSqueeze_CardMergeForm.SetDocTypes(ADocTypes);
end;

procedure TgsDBSqueeze_MainForm.SetDocTypeBranchEvent(const ABranchList: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypeBranch(ABranchList);
  gsDBSqueeze_CardMergeForm.SetDocTypeBranch(ABranchList);
end;

procedure TgsDBSqueeze_MainForm.GetCardFeaturesEvent(const ACardFatures: TStringList);
begin
  gsDBSqueeze_CardMergeForm.SetCardFeatures(ACardFatures);
end;

procedure  TgsDBSqueeze_MainForm.GetInvCardStatisticsEvent(const InvCardCount: String);
begin
  RecLog('================= Number of recods in INV_CARD =================');
  if (Trim(sttxtOrigInvCard.Caption) > '') or
     ((btnUpdateStatisticsInvCard.Tag = 1) and (Trim(sttxtOrigInvCard.Caption) > '')) then
  begin
    sttxtCurInvCard.Caption := InvCardCount;
    RecLog('Current: ');
  end
  else begin
    sttxtOrigInvCard.Caption := InvCardCount;
    RecLog('Original: ');
  end;
  RecLog(InvCardCount);
  RecLog('===============================================================');

  if btnGetStatisticsInvCard.Tag = 1 then
    btnGetStatisticsInvCard.Tag := 0
  else if btnUpdateStatisticsInvCard.Tag = 1 then
    btnUpdateStatisticsInvCard.Tag := 0;
end;

procedure TgsDBSqueeze_MainForm.GetStatisticsEvent(
  const AGdDoc: String;
  const AnAcEntry: String;
  const AnInvMovement: String;
  const AnInvCard: String);
begin
  RecLog('================= Number of recods in a table =================');
  if ((Trim(sttxtGdDoc.Caption) > '') or (Trim(sttxtAcEntry.Caption) > '') or (Trim(sttxtInvMovement.Caption) > '')) or
     ((btnUpdateStatistics.Tag = 1) and ((Trim(sttxtGdDoc.Caption) > '') or (Trim(sttxtAcEntry.Caption) > '') or (Trim(sttxtInvMovement.Caption) > ''))) then
  begin
    sttxtGdDocAfter.Caption := AGdDoc;
    sttxtAcEntryAfter.Caption := AnAcEntry;
    sttxtInvMovementAfter.Caption := AnInvMovement;
    sttxtInvCardAfter.Caption := AnInvCard;
    RecLog('Current: ');
  end
  else begin
    sttxtGdDoc.Caption := AGdDoc;
    sttxtAcEntry.Caption := AnAcEntry;
    sttxtInvMovement.Caption := AnInvMovement;
    sttxtInvCard.Caption := AnInvCard;
    RecLog('Original: ');
  end;
  RecLog('GD_DOCUMENT: ' + AGdDoc);
  RecLog('AC_ENTRY: ' + AnAcEntry);
  RecLog('INV_MOVEMENT: ' + AnInvMovement);
  RecLog('INV_CARD: ' + AnInvCard);
  RecLog('===============================================================');
end;

procedure TgsDBSqueeze_MainForm.GetProcStatisticsEvent(
  const AProcGdDoc: String;
  const AnProcAcEntry: String;
  const AnProcInvMovement: String;
  const AnProcInvCard: String);
begin
  RecLog('=========== Number of processing records in a table ===========');
  if ((Trim(sttxtProcGdDoc.Caption) > '') and (Trim(sttxtProcAcEntry.Caption) > '') and (Trim(sttxtProcInvMovement.Caption) > '')) or
     ((btnUpdateStatistics.Tag = 1) and ((Trim(sttxtProcGdDoc.Caption) > '') and (Trim(sttxtProcAcEntry.Caption) > '') and (Trim(sttxtProcInvMovement.Caption) > ''))) then
  begin
    sttxtAfterProcGdDoc.Caption := AProcGdDoc;
    sttxtAfterProcAcEntry.Caption := AnProcAcEntry;
    sttxtAfterProcInvMovement.Caption := AnProcInvMovement;
    sttxtAfterProcInvCard.Caption := AnProcInvCard;
    RecLog('Current: ');
  end
  else begin
    sttxtProcGdDoc.Caption := AProcGdDoc;
    sttxtProcAcEntry.Caption := AnProcAcEntry;
    sttxtProcInvMovement.Caption := AnProcInvMovement;
    sttxtProcInvCard.Caption := AnProcInvCard;
    RecLog('Original: ');
  end;
  RecLog('GD_DOCUMENT: ' + AProcGdDoc);
  RecLog('AC_ENTRY: ' + AnProcAcEntry);
  RecLog('INV_MOVEMENT: ' + AnProcInvMovement);
  RecLog('INV_CARD: ' + AnProcInvCard);
  RecLog('===============================================================');

  if btnGetStatistics.Tag = 1 then
    btnGetStatistics.Tag := 0
  else if btnUpdateStatistics.Tag = 1 then
    btnUpdateStatistics.Tag := 0;
end;

procedure TgsDBSqueeze_MainForm.FinishEvent(const AIsFinished: Boolean);
begin
  if AIsFinished then
  begin
    pbMain.Position := pbMain.Max;

    if Application.MessageBox(PChar(FormatDateTime('h:nn', Now) + ' - Обработка БД успешно завершена!' + #13#10 +
      'Затраченное время - ' + FormatDateTime('h:nn:ss', Now-FStartupTime)),
      PChar('Сообщение'),
      MB_OK + MB_ICONINFORMATION + MB_TOPMOST) = IDOK then
    begin
      pgcMain.ActivePage := tsStatistics;
    end;
  end;
end;

procedure TgsDBSqueeze_MainForm.LogSQLEvent(const ALogSQL: String);
begin
  mSqlLog.Lines.Add(ALogSQL);
  WriteToLogFile(ALogSQL);
end;

procedure TgsDBSqueeze_MainForm.ErrorEvent(const AErrorMsg: String);
begin
  RecLog('[error] ' + AErrorMsg);
  Application.MessageBox(PChar(AErrorMsg), 'Ошибка', MB_OK + MB_ICONSTOP + MB_TOPMOST);
end;

procedure TgsDBSqueeze_MainForm.StopNotify(var Msg: TMessage);
begin
  FSThread.WaitFor;        // ожидаем завершения
  DataDestroy;
  GetConnectedEvent(False);
  FIsProcessStop := False;
  SetProgress(' ', 0);
end;

//==============================================================================

procedure TgsDBSqueeze_MainForm.WriteToLogFile(const AStr: String);
var
  RecStr: String;
begin
  if Assigned(FLogFileStream) then
  begin
    RecStr := AStr + #13#10;
    FLogFileStream.Position := FLogFileStream.Size;
    FLogFileStream.Write(RecStr[1], Length(RecStr));
  end;
end;

procedure TgsDBSqueeze_MainForm.RecLog(const ARec: String);
var
  RecStr: String;
begin
  RecStr := FormatDateTime('h:nn:ss', Now) + ' -- ' + ARec;
  mLog.Lines.Add(RecStr);
  WriteToLogFile(RecStr);
end;

procedure TgsDBSqueeze_MainForm.SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
begin
  if pbMain.Position <> ACurrentStep then
    pbMain.Position := ACurrentStep;
  if ACurrentStepName > '' then
    lblProgress.Caption := ACurrentStepName;
end;

procedure TgsDBSqueeze_MainForm.UpdateProgress(const AProgressInfo: TgdProgressInfo);
begin
  case AProgressInfo.State of
    psMessage:
      RecLog(AProgressInfo.Message);
    psProgress:
      SetProgress(AProgressInfo.CurrentStepName, AProgressInfo.CurrentStep);
    psError:
      ErrorEvent(AProgressInfo.Message);
    psInit:
      Application.MessageBox(PChar(AProgressInfo.Message), PChar('Предупреждение'),
        MB_OK + MB_ICONWARNING + MB_TOPMOST);
    psDone:
      Application.MessageBox(PChar(AProgressInfo.Message), PChar('Сообщение'), MB_OK +
        MB_ICONINFORMATION + MB_TOPMOST);
  end;
end;

procedure TgsDBSqueeze_MainForm.actAboutExecute(Sender: TObject);
begin
  with TAboutBox.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actSaldoTestExecute(Sender: TObject);
begin
  case Application.MessageBox(PChar('Запустить проверку соответствия inv_balance и inv_movement?'), 
    PChar('Запуск'), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) of
    IDOK:
      begin
        FSThread.DoTest;
      end;
  end;
end;



end.
