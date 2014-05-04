unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, ActnList, ComCtrls, Buttons, StdCtrls, Grids, Spin, ExtCtrls,
  gsDBSqueeze_CardMergeForm_unit, gsDBSqueeze_DocTypesForm_unit, gsDBSqueezeThread_unit, gsDBSqueezeIniOptions_unit,
  gd_ProgressNotifier_unit, CommCtrl, Db, Menus;

const
  DEFAULT_HOST = 'localhost';
  DEFAULT_PORT = 3050;
  DEFAULT_USER_NAME = 'SYSDBA';
  DEFAULT_PASSWORD = 'masterkey';
  DEFAULT_CHARACTER_SET = 'WIN1251';
  CHARSET_LIST_CH1 = 'NONE, CYRL, DOS437, DOS737, DOS775, DOS850, DOS852, DOS857, DOS858, DOS860, DOS861, DOS862, DOS863, DOS864, DOS865, DOS866, DOS869, ISO8859_1, ISO8859_13, ISO8859_2, ISO8859_3, ISO8859_4, ISO8859_5, ISO8859_6, ISO8859_7';
  CHARSET_LIST_CH2 = 'ISO8859_8, ISO8859_9, KOI8R, KOI8U, NEXT, TIS620, WIN1250, WIN1251, WIN1252, WIN1253, WIN1254, WIN1255, WIN1256, WIN1257, WIN1258, ASCII, UNICODE_FSS, UTF8';
  MAX_PROGRESS_STEP = 12500;

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
    btnCardSetup: TButton;
    btnClearGeneralLog: TButton;
    btnConnect: TButton;
    btnDatabaseBrowse: TButton;
    btnGetStatistics: TButton;
    btnSelectDocTypes: TButton;
    btntTestConnection: TButton;
    btnUpdateStatistics: TBitBtn;
    cbbCharset: TComboBox;
    chkCalculateSaldo: TCheckBox;
    chkGetStatiscits: TCheckBox;
    chkMergeCard: TCheckBox;
    dtpClosingDate: TDateTimePicker;
    edDatabaseName: TEdit;
    edPassword: TEdit;
    edUserName: TEdit;
    GroupBox1: TGroupBox;
    grpOptions: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl5: TLabel;
    lblProgress: TLabel;
    MainMenu: TMainMenu;
    mIgnoreDocTypes: TMemo;
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
    pnl3: TPanel;
    pnl4: TPanel;
    pnlLogButton: TPanel;
    pnlLogs: TPanel;
    rbExcluding: TRadioButton;
    rbIncluding: TRadioButton;
    shp10: TShape;
    shp1: TShape;
    shp2: TShape;
    shp3: TShape;
    shp4: TShape;
    shp5: TShape;
    shp6: TShape;
    shp7: TShape;
    shp8: TShape;
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
    sttxt21: TStaticText;
    sttxt28: TStaticText;
    sttxt29: TStaticText;
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
    sttxtDBSizeAfter: TStaticText;
    sttxtDBSizeBefore: TStaticText;
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
    procedure actClearLogExecute(Sender: TObject);
    procedure actDatabaseBrowseExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure actGetUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure btnBackupBrowseMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnGetStatisticsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

  private
    FLogFileStream: TFileStream;
    FSThread: TgsDBSqueezeThread;

    FConnected: Boolean;
    FIsProcessStop: Boolean;

    FCardFeaturesList: TStringList;
    FDatabaseName: String;
    FDocTypesList: TStringList;
    FMergeDocTypesList: TStringList;
    FStartupTime: TDateTime;
    FWasSelectedDocTypes: Boolean;

    procedure CheckFreeDiskSpace(const APath: String; const AFileSize: Int64);
    procedure DataDestroy;
    procedure RecLog(const ARec: String);
    procedure SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
    procedure SetTextDocTypesMemo(Text: String);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
    procedure WriteToLogFile(const AStr: String);

    procedure ErrorEvent(const AErrorMsg: String);
    procedure FinishEvent(const AIsFinished: Boolean);
    procedure GetCardFeaturesEvent(const ACardFatures: TStringList);
    procedure GetConnectedEvent(const AConnected: Boolean);
    procedure GetDBPropertiesEvent(const AProperties: TStringList);
    procedure GetDBSizeEvent(const AnDBSize: String);
    procedure GetProcStatisticsEvent(const AProcGdDoc: String; const AnProcAcEntry: String; const AnProcInvMovement: String; const AnProcInvCard: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String);
    procedure LogSQLEvent(const ALogSQL: String);
    procedure SetDocTypeBranchEvent(const ABranchList: TStringList);
    procedure SetDocTypeStringsEvent(const ADocTypes: TStringList);
    procedure UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

uses
  gd_common_functions;

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
begin
  inherited;

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

  pbMain.Max := MAX_PROGRESS_STEP;

  lblProgress.Parent := pbMain;
  lblProgress.Width := pbMain.Width - 8;
  lblProgress.Left := pbMain.Left + 4;
  lblProgress.Top := 2;
  lblProgress.Transparent := True;
  lblProgress.Caption := '';

  cbbCharset.Items.CommaText := CHARSET_LIST_CH1 + ',' + CHARSET_LIST_CH2;
  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);

  FConnected := False;
  FStartupTime := Now;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnUsedDB := UsedDBEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetInvCardFeatures := GetCardFeaturesEvent;
  FSThread.OnSetDocTypeBranch := SetDocTypeBranchEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
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
  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);
  dtpClosingDate.Date := Date;
  rbIncluding.Checked := True;
  mIgnoreDocTypes.Clear;
  chkGetStatiscits.Checked := True;
  chkMergeCard.Checked := False;

  FStartupTime := Now;
  FWasSelectedDocTypes := False;
  mIgnoreDocTypes.Clear;
  FDocTypesList.Clear;
  FMergeDocTypesList.Clear;
  FCardFeaturesList.Clear;
  FDatabaseName := '';

  gsDBSqueeze_DocTypesForm.DataDestroy;
  gsDBSqueeze_CardMergeForm.DataDestroy;

  sttxtDBSizeBefore.Caption := '';
  sttxtDBSizeAfter.Caption := '';
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

  if Assigned(FLogFileStream) then
    FreeAndNil(FLogFileStream);

  FreeAndNil(FSThread);
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnUsedDB := UsedDBEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetInvCardFeatures := GetCardFeaturesEvent;
  FSThread.OnSetDocTypeBranch := SetDocTypeBranchEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;

  SetProgress(' ', 0);
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


procedure TgsDBSqueeze_MainForm.GetDBSizeEvent(const AnDBSize: String);
begin
  if Trim(sttxtDBSizeBefore.Caption) = '' then
    sttxtDBSizeBefore.Caption := AnDBSize
  else begin
    sttxtDBSizeAfter.Enabled := True;
    sttxtDBSizeAfter.Caption := AnDBSize;
  end;
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

procedure TgsDBSqueeze_MainForm.SetDocTypeStringsEvent(const ADocTypes: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypes(ADocTypes);
  gsDBSqueeze_CardMergeForm.SetDocTypes(ADocTypes);
end;

procedure TgsDBSqueeze_MainForm.GetCardFeaturesEvent(const ACardFatures: TStringList);
begin
  gsDBSqueeze_CardMergeForm.SetCardFeatures(ACardFatures);
end;

procedure TgsDBSqueeze_MainForm.SetDocTypeBranchEvent(const ABranchList: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypeBranch(ABranchList);
  gsDBSqueeze_CardMergeForm.SetDocTypeBranch(ABranchList);
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

procedure TgsDBSqueeze_MainForm.actDatabaseBrowseExecute(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
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

procedure TgsDBSqueeze_MainForm.actGetExecute(Sender: TObject);
begin
  FSThread.DoGetStatistics;
end;

procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
  actGet.Enabled := FConnected and (FSThread <> nil) and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
var
  I: Integer;
  LogFileName, BackupFileName: String;
  RequiredSize: LongInt;
begin
  LogFileName := '';
  BackupFileName := '';

  // параметры объединения
  if (chkMergeCard.Checked) and (FMergeDocTypesList.Count <> 0) then
    FSThread.SetMergeCardParams(gsDBSqueeze_CardMergeForm.GetDate, FMergeDocTypesList, FCardFeaturesList, chkMergeCard.Checked);

  FSThread.SetClosingDate(dtpClosingDate.Date);

  FSThread.SetSaldoParams(
    True,
    False,
    chkCalculateSaldo.Checked);

  if FWasSelectedDocTypes then
  begin
    FDocTypesList.Clear;
    FDocTypesList.CommaText := gsDBSqueeze_DocTypesForm.GetSelectedIdDocTypes;
    if FDocTypesList.Count > 0 then
      FSThread.SetSelectDocTypes(FDocTypesList, rbIncluding.Checked);
  end;

  if Pos('\', FDatabaseName) <> 0 then
    Delete(FDatabaseName, 1, LastDelimiter('\', FDatabaseName));

  RequiredSize := FSThread.DBSize div 2;
  CheckFreeDiskSpace(ExtractFileDir(FDatabaseName), RequiredSize);

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

procedure TgsDBSqueeze_MainForm.btnBackupBrowseMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;

procedure TgsDBSqueeze_MainForm.GetConnectedEvent(const AConnected: Boolean);
begin
  if AConnected then
    stConnect.Caption := 'Подключено'
  else
    stConnect.Caption := 'Отключено';
  FConnected := AConnected;
end;

procedure TgsDBSqueeze_MainForm.actStopExecute(Sender: TObject);
begin
  case Application.MessageBox(
    PChar('Прервать процесс обработки БД?' + #13#10 +
      'Прерывание произойдет после завершения последней операции.' + #13#10 +
      'Возобновить процесс будет невозможно.'),
      PChar('Подтверждение'),
      MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) of
      IDOK:
        begin
          FSThread.StopProcessing;
        end;
  end;
end;

procedure TgsDBSqueeze_MainForm.actStopUpdate(Sender: TObject);
begin
  actStop.Enabled := Assigned(FSThread) and FSThread.Busy;

  if FIsProcessStop then                                                        ///TODO: переделать через event
  begin
    FSThread.WaitFor;    // ожидаем завершения
    DataDestroy;
    GetConnectedEvent(False);
    FIsProcessStop := False;
  end
end;

procedure TgsDBSqueeze_MainForm.SetTextDocTypesMemo(Text: String);
begin
  mIgnoreDocTypes.Clear;
  mIgnoreDocTypes.Text := Text;
end;

procedure TgsDBSqueeze_MainForm.actClearLogExecute(Sender: TObject);
begin
  mLog.Clear;
  mSqlLog.Clear;
end;

procedure TgsDBSqueeze_MainForm.FinishEvent(const AIsFinished: Boolean);
begin
  if AIsFinished then
  begin
    pbMain.Step := MAX_PROGRESS_STEP;//pbMain.Max;

    if Application.MessageBox(PChar(FormatDateTime('h:nn', Now) + ' - Обработка БД успешно завершена!' + #13#10 +
      'Затраченное время - ' + FormatDateTime('h:nn:ss', Now-FStartupTime)),
      PChar('Сообщение'),
      MB_OK + MB_ICONINFORMATION + MB_TOPMOST) = IDOK then
    begin
      pgcMain.ActivePage := tsStatistics;
    end;
  end  
  else begin                // финиш из-за прерывания
    FIsProcessStop := True; // обработка последнего сообщения завершена
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
  end;
end; 

procedure TgsDBSqueeze_MainForm.UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);
begin
end;

procedure TgsDBSqueeze_MainForm.CheckFreeDiskSpace(const APath: String; const AFileSize: Int64);
var
  CurDirectory: String;
  FreeSpace: Int64;

  function BytesToStr(const i64Size: Int64): String;
  const
    i64GB = 1024 * 1024 * 1024;
    i64MB = 1024 * 1024;
    i64KB = 1024;
  begin
    if i64Size div i64GB > 0 then
      Result := Format('%.2f GB', [i64Size / i64GB])
    else if i64Size div i64MB > 0 then
      Result := Format('%.2f MB', [i64Size / i64MB])
    else if i64Size div i64KB > 0 then
      Result := Format('%.2f KB', [i64Size / i64KB])
    else
      Result := IntToStr(i64Size) + ' Byte(s)';
  end;

begin
  CurDirectory := GetCurrentDir;
  SetCurrentDir(ExtractFileDir(APath));
  try
    FreeSpace := DiskFree(0);
    if FreeSpace < AFileSize then
      //Application.MessageBox(PChar('Недостаточно свободного места! Освободите ' + IntToStr((AFileSize - FreeSpace) div 1048576)),  PChar('Предупреждение'), MB_OK + MB_ICONWARNING + MB_TOPMOST);
      Application.MessageBox(
        PChar('Недостаточно свободного места: ' + APath + #13#10 + ' Освободите ' + BytesToStr(AFileSize - FreeSpace)),
        PChar('Предупреждение'),
        MB_OK + MB_ICONWARNING + MB_TOPMOST);
  finally
    SetCurrentDir(CurDirectory);
  end;
end;

procedure TgsDBSqueeze_MainForm.btnGetStatisticsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;

procedure TgsDBSqueeze_MainForm.actConnectUpdate(Sender: TObject);
begin
  actConnect.Enabled := not FConnected;
end;

procedure TgsDBSqueeze_MainForm.actConnectExecute(Sender: TObject);
var
  Server, FileName: String;
  Port: Integer;
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
    Port);
  FSThread.Connect;
end;

procedure TgsDBSqueeze_MainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TgsDBSqueeze_MainForm.actExitUpdate(Sender: TObject);
begin
  actExit.Enabled := (FSThread = nil) or ((not FConnected) and (not FSThread.Busy));
end;

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := actExit.Enabled;
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
      {gsIniOptions.Database := edDatabaseName.Text;
      gsIniOptions.Charset := cbbCharset.Text;             }
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
      gsIniOptions.DoMergeCards := chkMergeCard.Checked;

      gsIniOptions.SaveToFile(SaveDlg.FileName);
    end;
  finally
    SaveDlg.Free;
  end;
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

      {edDatabaseName.Text :=  gsIniOptions.Database;
      cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(Trim(UpperCase(gsIniOptions.Charset))); }
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
      SetTextDocTypesMemo(gsDBSqueeze_DocTypesForm.GetDocTypeMemoText);
      FWasSelectedDocTypes := (Trim(mIgnoreDocTypes.Text) > '');

      gsDBSqueeze_CardMergeForm.ClearSelection;
      gsDBSqueeze_CardMergeForm.SetDate(gsIniOptions.MergingDate);
      gsDBSqueeze_CardMergeForm.SetSelectedDocTypes(gsIniOptions.MergingDocTypeKeys, gsIniOptions.MergingBranchRows);
      gsDBSqueeze_CardMergeForm.SetSelectedCardFeatures(gsIniOptions.MergingCardFeatures, gsIniOptions.MergingFeaturesRows);

      chkMergeCard.Checked := gsIniOptions.DoMergeCards;

      FMergeDocTypesList.Clear;
      FCardFeaturesList.Clear;
      if chkMergeCard.Checked then
      begin
        FMergeDocTypesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes;
        FCardFeaturesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;
      end;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TgsDBSqueeze_MainForm.actSelectDocTypesExecute(Sender: TObject);
begin
  if gsDBSqueeze_DocTypesForm.ShowModal = mrOk then
    SetTextDocTypesMemo(gsDBSqueeze_DocTypesForm.GetDocTypeMemoText);
  FWasSelectedDocTypes := (mIgnoreDocTypes.Text > '');
end;

procedure TgsDBSqueeze_MainForm.actSelectDocTypesUpdate(Sender: TObject);
begin
  actSelectDocTypes.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  actGo.Enabled := (FSThread <> nil) and FConnected and (not FSThread.Busy);
end;

procedure TgsDBSqueeze_MainForm.actLoadConfigUpdate(Sender: TObject);
begin
  actLoadConfig.Enabled := (FSThread <> nil) and FConnected;
end;

procedure TgsDBSqueeze_MainForm.actSaveConfigUpdate(Sender: TObject);
begin
  actSaveConfig.Enabled :=  (FSThread <> nil) and FConnected;
end;

procedure TgsDBSqueeze_MainForm.actCardSetupExecute(Sender: TObject);
begin
  case gsDBSqueeze_CardMergeForm.ShowModal of
    mrYes:
      begin
        chkMergeCard.Checked := False;
        FMergeDocTypesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes;
        FCardFeaturesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;

        // параметры объединения
        FSThread.SetMergeCardParams(gsDBSqueeze_CardMergeForm.GetDate, FMergeDocTypesList, FCardFeaturesList, chkMergeCard.Checked);
        // запуск объединения карточек
        FSThread.DoMergeCards;
      end;
    mrOk:
      begin
        chkMergeCard.Checked := True; // отложенный запуск
        FMergeDocTypesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes;
        FCardFeaturesList.CommaText := gsDBSqueeze_CardMergeForm.GetSelectedCardFeatures;
      end;  
  end;
end;

procedure TgsDBSqueeze_MainForm.actCardSetupUpdate(Sender: TObject);
begin
  actCardSetup.Enabled := FConnected;
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

end.
