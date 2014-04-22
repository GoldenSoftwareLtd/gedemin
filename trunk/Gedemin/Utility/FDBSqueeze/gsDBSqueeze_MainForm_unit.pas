unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl,
  ActnList, ComCtrls, Buttons, StdCtrls, Grids, Spin, ExtCtrls,
  gsDBSqueeze_DocTypesForm_unit,gsDBSqueezeThread_unit, gsDBSqueezeIniOptions_unit, gd_ProgressNotifier_unit,
  DBCtrls, CommCtrl, Db, ADODB;

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

    ActionList: TActionList;
    actBackPage: TAction;
    actClearLog: TAction;
    actCompany: TAction;
    actConfigBrowse: TAction;
    actDatabaseBrowse: TAction;
    actDefocus: TAction;
    actDirectoryBrowse: TAction;
    actDisconnect: TAction;
    actGet: TAction;
    actGo: TAction;
    actNextPage: TAction;
    actStop: TAction;
    actUpdate: TAction;
    btnGetStatistics: TButton;
    btnUpdateStatistics: TBitBtn;
    Label1: TLabel;
    mLog: TMemo;
    pbMain: TProgressBar;
    pgcMain: TPageControl;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    pnl4: TPanel;
    shp10: TShape;
    shp1: TShape;
    shp2: TShape;
    shp3: TShape;
    shp4: TShape;
    shp5: TShape;
    shp6: TShape;
    shp7: TShape;
    shp8: TShape;
    statbarMain: TStatusBar;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
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
    tsAbout: TTabSheet;
    tsLogs: TTabSheet;
    tsSettings: TTabSheet;
    tsStatistics: TTabSheet;
    txt10: TStaticText;
    txt2: TStaticText;
    txt3: TStaticText;
    txt4: TStaticText;
    txt5: TStaticText;
    txt6: TStaticText;
    pgcSettings: TPageControl;
    tsConnection: TTabSheet;
    StaticText4: TStaticText;
    cbbCharset: TComboBox;
    sttxtStateTestConnect: TStaticText;
    StaticText3: TStaticText;
    btnNext1: TButton;
    btntTestConnection: TButton;
    sttxtActivUserCount: TStaticText;
    sttxtServerName: TStaticText;
    sttxtActivConnects: TStaticText;
    sttxtTestConnectState: TStaticText;
    sttxtTestServer: TStaticText;
    tsSqueezeSettings: TTabSheet;
    lbl5: TLabel;
    dtpClosingDate: TDateTimePicker;
    btnNext2: TButton;
    btnBack1: TButton;
    chk00Account: TCheckBox;
    btnLoadConfigFile: TButton;
    tsOptions: TTabSheet;
    lblLogDir: TLabel;
    lblBackup: TLabel;
    lblRestore: TLabel;
    btnNext3: TButton;
    btnBack2: TButton;
    chkbSaveLogs: TCheckBox;
    chkBackup: TCheckBox;
    edLogs: TEdit;
    btnLogDirBrowse: TButton;
    edtBackup: TEdit;
    btnBackupBrowse: TButton;
    edtRestore: TEdit;
    btnRestoreBrowse: TButton;
    chkRestore: TCheckBox;
    txt8: TStaticText;
    tsReviewSettings: TTabSheet;
    btnGo: TBitBtn;
    btnBack3: TBitBtn;
    mReviewSettings: TMemo;
    txt11: TStaticText;
    chkCalculateSaldo: TCheckBox;
    mIgnoreDocTypes: TMemo;
    tbcDocTypes: TTabControl;
    btnSelectDocTypes: TButton;
    txt13: TStaticText;
    shp14: TShape;
    txt14: TStaticText;
    txt15: TStaticText;
    shp11: TShape;
    txt16: TStaticText;
    shp12: TShape;
    chkGetStatiscits: TCheckBox;
    btnSaveConfigFile: TButton;
    TabSheet1: TTabSheet;
    mSqlLog: TMemo;
    Panel1: TPanel;
    btnClearGeneralLog: TButton;
    btnStop: TButton;
    Panel2: TPanel;
    btnClearSqlLog: TButton;
    lbl1: TLabel;
    edDatabaseName: TEdit;
    btnDatabaseBrowse: TButton;
    Label2: TLabel;
    lbl2: TLabel;
    edUserName: TEdit;
    lbl3: TLabel;
    edPassword: TEdit;
    Label3: TLabel;

    procedure actBackPageExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure actClearLogUpdate(Sender: TObject);
    procedure actConfigBrowseExecute(Sender: TObject);
    procedure actDatabaseBrowseExecute(Sender: TObject);
    procedure actDefaultPortExecute(Sender: TObject);
    procedure actDefocusExecute(Sender: TObject);
    procedure actDirectoryBrowseExecute(Sender: TObject);
    procedure actDirectoryBrowseUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure actGetUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure actGoUpdate(Sender: TObject);
    procedure actNextPageExecute(Sender: TObject);
    procedure actNextPageUpdate(Sender: TObject);
    procedure actRadioLocationExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure btnBackupBrowseMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnClearGeneralLogMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure statbarMainDrawPanel(StatusBar: TStatusBar;Panel: TStatusPanel; const Rect: TRect);
    procedure tbcPageControllerChange(Sender: TObject);
    procedure btnSelectDocTypesClick(Sender: TObject);
    procedure btnGetStatisticsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      
  private
    FStartupTime: TDateTime;
    FSThread: TgsDBSqueezeThread;
    FLogFileStream: TFileStream;

    FProcessing: Boolean;

    FConnected: Boolean;
    FSaveLogs: Boolean;
    FWrited: Boolean;
    FIsProcessStop: Boolean;

    FWasSelectedDocTypes: Boolean;
    FDocTypesList: TStringList;
    FDatabaseName: String;

    procedure ThreadDestroy;
    procedure RecLog(const ARec: String);
    procedure SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
    procedure SetTextDocTypesMemo(Text: String);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
    procedure WriteToLogFile(const AStr: String);
    procedure CheckFreeDiskSpace(const APath: String; const AFileSize: Int64);

    procedure ErrorEvent(const AErrorMsg: String);
    procedure FinishEvent(const AIsFinished: Boolean);
    procedure GetConnectedEvent(const AConnected: Boolean);
    procedure GetDBPropertiesEvent(const AProperties: TStringList);
    procedure GetDBSizeEvent(const AnDBSize: String);
    procedure GetInfoTestConnectEvent(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList);
    procedure GetProcStatisticsEvent(const AProcGdDoc: String; const AnProcAcEntry: String; const AnProcInvMovement: String; const AnProcInvCard: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String);
    procedure LogSQLEvent(const ALogSQL: String);
    procedure SetDocTypeStringsEvent(const ADocTypes: TStringList);
    procedure SetDocTypeBranchEvent(const ABranchList: TStringList);
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
var
  I: Integer;
begin
  inherited;

  FDocTypesList := TStringList.Create;
  // скрытие ярлыков PageControl
  pgcMain.ActivePage := tsSettings;
  pgcSettings.ActivePage := tsConnection;

  mSqlLog.Clear;
  mLog.ReadOnly := True;
  mSqlLog.ReadOnly := True;
  dtpClosingDate.Date := Date;

  edUserName.Text := DEFAULT_USER_NAME;
  edPassword.Text := DEFAULT_PASSWORD;

  pbMain.Parent := statbarMain;
  //remove progress bar border
  SetWindowLong(pbMain.Handle, GWL_EXSTYLE, GetWindowLong(pbMain.Handle,GWL_EXSTYLE) - WS_EX_STATICEDGE);
  SendMessage(pbMain.Handle, PBM_SETBARCOLOR, 0, $005555EC);
  pbMain.Max := MAX_PROGRESS_STEP;

  btnStop.Enabled := False;

  cbbCharset.Items.CommaText := CHARSET_LIST_CH1 + ',' + CHARSET_LIST_CH2;
  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);

  gsDBSqueeze_MainForm.DefocusControl(tbcDocTypes, False);

  FConnected := False;
  FStartupTime := Now;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnGetInfoTestConnect := GetInfoTestConnectEvent;
  FSThread.OnUsedDB := UsedDBEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnSetDocTypeBranch := SetDocTypeBranchEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  if Assigned(FLogFileStream) then
    FLogFileStream.Free;
  FDocTypesList.Free;
  inherited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.ThreadDestroy;
begin
  FStartupTime := Now;

  FWasSelectedDocTypes := False;
  gsDBSqueeze_DocTypesForm.ClearData;                                              ///////////////////////////
  mIgnoreDocTypes.Clear;
  FDocTypesList.Clear;

  FSaveLogs := False;

  sttxtStateTestConnect.Caption := 'unknown';
  sttxtServerName.Caption := '';
  sttxtActivUserCount.Caption := '';
  sttxtServerName.Visible := False;
  sttxtTestServer.Visible := False;
  sttxtActivUserCount.Visible := False;
  sttxtActivConnects.Visible := False;

  cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);
  dtpClosingDate.Date := Date;
  chk00Account.Checked := False;
  tbcDocTypes.TabIndex := 0;
  chkbSaveLogs.Checked := False;
  chkBackup.Checked := False;
  chkRestore.Checked := False;
  edLogs.Text := '';
  edtBackup.Text := '';
  edtRestore.Text := '';
  chkGetStatiscits.Checked := True;
  mReviewSettings.Clear;

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

  FreeAndNil(FSThread);
  if Assigned(FLogFileStream) then
    FreeAndNil(FLogFileStream);
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnLogSQL := LogSQLEvent;
  FSThread.OnGetInfoTestConnect := GetInfoTestConnectEvent;
  FSThread.OnUsedDB := UsedDBEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;

  SetProgress(' ', 0);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
var
  Server, FileName: String;
  Port: Integer;
begin
  gsDBSqueeze_MainForm.DefocusControl(btntTestConnection, False);

  if actDisconnect.Caption = 'Disconnect' then
  begin
    GetConnectedEvent(False); //FSThread.Disconnect;                            ///TODO: после сообщения о дисконнекте разрушить
    ThreadDestroy;
    mLog.Clear;
    mSqlLog.Clear;
  end
  else begin// test connect
    FProcessing := True;

    sttxtTestServer.Visible := False;
    sttxtServerName.Visible := False;
    sttxtActivConnects.Visible := False;
    sttxtActivUserCount.Visible := False;
    sttxtStateTestConnect.Caption:= 'unknown';
    sttxtServerName.Caption := '';
    sttxtActivUserCount.Caption := '';

    ParseDatabaseName(edDatabaseName.Text, Server, Port, FileName);

    if Port = 0 then Port := 3050;

    FSThread.StartTestConnect(
      FileName,
      Server,
      edUserName.Text,
      edPassword.Text,
      cbbCharset.Text,
      Port);
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDisconnectUpdate(Sender: TObject);
begin
  if FConnected then
  begin
    actDisconnect.Caption := 'Disconnect';
    actDisconnect.Enabled := not actStop.Enabled;
  end
  else begin
    actDisconnect.Caption := 'Test Connect';
    actDisconnect.Enabled := btnNext1.Enabled and (not FProcessing);
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.GetInfoTestConnectEvent(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList);
begin
  if AConnectSuccess then
  begin
    sttxtStateTestConnect.Caption := 'SUCCESS';
    sttxtServerName.Caption := sttxtServerName.Caption + AConnectInfoList.Values['ServerName'] + ' ' + AConnectInfoList.Values['ServerVersion'];
    sttxtActivUserCount.Caption := sttxtActivUserCount.Caption + AConnectInfoList.Values['ActivConnectCount'];
    sttxtServerName.Visible := True;
    sttxtTestServer.Visible := True;
    sttxtActivUserCount.Visible := True;
    sttxtActivConnects.Visible := True;
  end
  else begin
    sttxtStateTestConnect.Caption := 'FAIL';
  end;
  FProcessing := False;
end;

//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.GetDBSizeEvent(const AnDBSize: String);
begin
  if Trim(sttxtDBSizeBefore.Caption) = '' then
    sttxtDBSizeBefore.Caption := AnDBSize
  else begin
    sttxtDBSizeAfter.Enabled := True;
    sttxtDBSizeAfter.Caption := AnDBSize;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.GetStatisticsEvent(
  const AGdDoc: String;
  const AnAcEntry: String;
  const AnInvMovement: String;
  const AnInvCard: String);
begin
  WriteToLogFile('================= Number of recods in a table =================');
  if ((Trim(sttxtGdDoc.Caption) > '') or (Trim(sttxtAcEntry.Caption) > '') or (Trim(sttxtInvMovement.Caption) > '')) or 
     ((btnUpdateStatistics.Tag = 1) and ((Trim(sttxtGdDoc.Caption) > '') or (Trim(sttxtAcEntry.Caption) > '') or (Trim(sttxtInvMovement.Caption) > ''))) then
  begin
    sttxtGdDocAfter.Caption := AGdDoc;
    sttxtAcEntryAfter.Caption := AnAcEntry;
    sttxtInvMovementAfter.Caption := AnInvMovement;
    sttxtInvCardAfter.Caption := AnInvCard;
    WriteToLogFile('Current: ');
  end
  else begin
    sttxtGdDoc.Caption := AGdDoc;
    sttxtAcEntry.Caption := AnAcEntry;
    sttxtInvMovement.Caption := AnInvMovement;
    sttxtInvCard.Caption := AnInvCard;
    WriteToLogFile('Original: ');
  end;
  WriteToLogFile('GD_DOCUMENT: ' + AGdDoc);
  WriteToLogFile('AC_ENTRY: ' + AnAcEntry);
  WriteToLogFile('INV_MOVEMENT: ' + AnInvMovement);
  WriteToLogFile('INV_CARD: ' + AnInvCard);
  WriteToLogFile('===============================================================');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.GetProcStatisticsEvent(
  const AProcGdDoc: String;
  const AnProcAcEntry: String;
  const AnProcInvMovement: String;
  const AnProcInvCard: String);
begin
  WriteToLogFile('=========== Number of processing records in a table ===========');
  if ((Trim(sttxtProcGdDoc.Caption) > '') and (Trim(sttxtProcAcEntry.Caption) > '') and (Trim(sttxtProcInvMovement.Caption) > '')) or
     ((btnUpdateStatistics.Tag = 1) and ((Trim(sttxtProcGdDoc.Caption) > '') and (Trim(sttxtProcAcEntry.Caption) > '') and (Trim(sttxtProcInvMovement.Caption) > ''))) then
  begin
    sttxtAfterProcGdDoc.Caption := AProcGdDoc;
    sttxtAfterProcAcEntry.Caption := AnProcAcEntry;
    sttxtAfterProcInvMovement.Caption := AnProcInvMovement;
    sttxtAfterProcInvCard.Caption := AnProcInvCard;
    WriteToLogFile('Current: ');
  end
  else begin
    sttxtProcGdDoc.Caption := AProcGdDoc;
    sttxtProcAcEntry.Caption := AnProcAcEntry;
    sttxtProcInvMovement.Caption := AnProcInvMovement;
    sttxtProcInvCard.Caption := AnProcInvCard;
    WriteToLogFile('Original: ');
  end;
  WriteToLogFile('GD_DOCUMENT: ' + AProcGdDoc);
  WriteToLogFile('AC_ENTRY: ' + AnProcAcEntry);
  WriteToLogFile('INV_MOVEMENT: ' + AnProcInvMovement);
  WriteToLogFile('INV_CARD: ' + AnProcInvCard);
  WriteToLogFile('===============================================================');

  FProcessing := False;
  if btnGetStatistics.Tag = 1 then
    btnGetStatistics.Tag := 0
  else if btnUpdateStatistics.Tag = 1 then
    btnUpdateStatistics.Tag := 0;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetDocTypeStringsEvent(const ADocTypes: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypes(ADocTypes);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetDocTypeBranchEvent(const ABranchList: TStringList);
begin
  gsDBSqueeze_DocTypesForm.SetDocTypeBranch(ABranchList);
end;
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDatabaseBrowseExecute(Sender: TObject);
var
  openDialog : TOpenDialog;
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
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGetExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnGetStatistics, False);
  gsDBSqueeze_MainForm.DefocusControl(btnUpdateStatistics, False);

  FSThread.DoGetStatistics;
  FProcessing := True;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
  //actGet.Enabled := FConnected;
  btnGetStatistics.Enabled := FConnected and (not FProcessing);
  btnUpdateStatistics.Enabled := FConnected and (not FProcessing);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.tbcPageControllerChange(Sender: TObject);
begin
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actRadioLocationExecute(Sender: TObject);
begin
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDefaultPortExecute(Sender: TObject);
begin
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actNextPageExecute(Sender: TObject);
var
  I: Integer;
  LogFileName: String;
  BackupFileName: String;
  RestoreDBName: String;
  RequiredSize: Int64; // в байтах
  Server, FileName: String;
  Port: Integer;
begin
  LogFileName := '';
  BackupFileName := '';
  if pgcSettings.ActivePage = tsConnection then
  begin
    if not FConnected then
    begin
      sttxtGdDoc.Caption := '';
      sttxtGdDocAfter.Caption := '';
      sttxtAcEntry.Caption := '';
      sttxtAcEntryAfter.Caption := '';
      sttxtInvMovement.Caption := '';
      sttxtInvMovementAfter.Caption := '';
      sttxtInvMovement.Caption := '';
      sttxtInvMovementAfter.Caption := '';
      sttxtInvCard.Caption := '';
      sttxtInvCardAfter.Caption := '';
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
      sttxtDBSizeBefore.Caption := '';
      sttxtDBSizeAfter.Caption := '';

      ParseDatabaseName(edDatabaseName.Text, Server, Port, FileName);

      if Port = 0 then Port := 3050;

      FSThread.SetDBParams(
        FileName,
        Server,
        edUserName.Text,
        edPassword.Text,
        cbbCharset.Text,
        Port);

      FSThread.Connect;
    end;
  end
  else if pgcSettings.ActivePage = tsSqueezeSettings then
  begin
    if btnGo.Enabled then
    begin
        chkBackup.Enabled := True;
        lblBackup.Enabled := True;
        edtBackup.Enabled := True;
        btnBackupBrowse.Enabled := True;

      FSThread.SetClosingDate(dtpClosingDate.Date);

      FSThread.SetSaldoParams(
        True,
        False,
        chk00Account.Checked,
        chkCalculateSaldo.Checked);

      if FWasSelectedDocTypes then
      begin
        FDocTypesList.Clear;
        FDocTypesList.CommaText := gsDBSqueeze_DocTypesForm.GetSelectedIdDocTypes;
        if FDocTypesList.Count > 0 then
          FSThread.SetSelectDocTypes(FDocTypesList, (tbcDocTypes.TabIndex=1));
      end;
    end;
  end
  else if pgcSettings.ActivePage = tsOptions then
  begin
    if btnGo.Enabled then
    begin
      if Pos('\', FDatabaseName) <> 0 then
        Delete(FDatabaseName, 1, LastDelimiter('\', FDatabaseName));
      if edLogs.Enabled then
      begin
        FSaveLogs := True;
        if (Trim(edLogs.Text))[Length(Trim(edLogs.Text))] = '\' then
          LogFileName := Trim(edLogs.Text) + 'DBS_' + FDatabaseName + '_'+ FormatDateTime('yymmdd_hh-mm', FStartupTime) + '.log'
        else
          LogFileName := Trim(edLogs.Text) + '\DBS_' + FDatabaseName + '_'+ FormatDateTime('yymmdd_hh-mm', FStartupTime) + '.log';
      end;
      if edtBackup.Enabled then
      begin
        if (Trim(edtBackup.Text))[Length(Trim(edtBackup.Text))] = '\' then
          BackupFileName := Trim(edtBackup.Text) + 'DBS_' + FDatabaseName + '_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.fbk'
        else                                                                     
          BackupFileName := Trim(edtBackup.Text) + '\DBS_' + FDatabaseName + '_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.fbk';
      end;
      if edtRestore.Enabled then
      begin
        if (Trim(edtBackup.Text))[Length(Trim(edtBackup.Text))] = '\' then
          RestoreDBName := Trim(edtRestore.Text) + 'DBS_RESTORE_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '_' + FDatabaseName
        else
          RestoreDBName := Trim(edtRestore.Text) + '\DBS_RESTORE_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '_' + FDatabaseName;
      end;

      RequiredSize := FSThread.DBSize div 2;
      CheckFreeDiskSpace(ExtractFileDir(FDatabaseName), RequiredSize);

      if edtBackup.Enabled then
      begin
        if ExtractFileDir(FDatabaseName) = ExtractFileDir(Trim(edtBackup.Text)) then
          RequiredSize := RequiredSize + FSThread.DBSize
        else
          RequiredSize := FSThread.DBSize;

        CheckFreeDiskSpace(edtBackup.Text, RequiredSize);
      end;
      if edtRestore.Enabled then
      begin
        if (edtBackup.Enabled) and
           ((ExtractFileDir(Trim(edtBackup.Text))) = (ExtractFileDir(Trim(edtRestore.Text)))) and ((ExtractFileDir(Trim(edtBackup.Text))) = (ExtractFileDir(FDatabaseName))) then
          RequiredSize := RequiredSize + FSThread.DBSize
        else if ExtractFileDir(Trim(edtRestore.Text)) = ExtractFileDir(Trim(edtBackup.Text)) then
          RequiredSize := RequiredSize + FSThread.DBSize
        else if ExtractFileDir(Trim(edtRestore.Text)) = ExtractFileDir(FDatabaseName) then
          RequiredSize := FSThread.DBSize +  FSThread.DBSize div 2
        else
          RequiredSize := FSThread.DBSize;

        CheckFreeDiskSpace(edtRestore.Text, RequiredSize);
      end;

      if chkbSaveLogs.Checked then
      begin
        if not FileExists(LogFileName) then
          with TFileStream.Create(LogFileName, fmCreate) do Free;

        FLogFileStream := TFileStream.Create(LogFileName, fmOpenWrite or fmShareDenyNone);
      end;

      FSThread.SetOptions(
        chkbSaveLogs.Checked,
        chkBackup.Checked,
        LogFileName,
        BackupFileName,
        RestoreDBName,
        False);

      FSThread.DoGetStatisticsAfterProc := chkGetStatiscits.Checked;

      mReviewSettings.Clear;
      mReviewSettings.Lines.Add('Database: ' + edDatabaseName.Text);
      mReviewSettings.Lines.Add('Username: ' + edUserName.Text);
      mReviewSettings.Lines.Add('Удалить документы с DOCUMENTDATE < ' + DateToStr(dtpClosingDate.Date));

      if chkCalculateSaldo.Checked then
        mReviewSettings.Lines.Add('Сохранить сальдо, вычисленное программой: ДА')
      else
        mReviewSettings.Lines.Add('Сохранить сальдо, вычисленное программой: НЕТ');

      if FDocTypesList.Count > 0 then
      begin
        if tbcDocTypes.TabIndex = 0 then
          mReviewSettings.Lines.Add('Не обрабатывать документы с  DOCUMENTTYPE: ')
        else
          mReviewSettings.Lines.Add('Обрабатывать только документы с DOCUMENTTYPE: ');
        for I:=0 to FDocTypesList.Count-1 do
          mReviewSettings.Lines.Add(FDocTypesList[I]);
      end;    
      if chkbSaveLogs.Checked then
      begin
        mReviewSettings.Lines.Add('Сохранить логи в файл: ДА');
        mReviewSettings.Lines.Add('Log File: ' + LogFileName);
      end
      else
        mReviewSettings.Lines.Add('Сохранить логи в файл: НЕТ');
      if chkBackup.Checked then
      begin
        mReviewSettings.Lines.Add('Backup БД по завершению обработки: ДА');
        mReviewSettings.Lines.Add('Backup File: ' + BackupFileName);
      end
      else
        mReviewSettings.Lines.Add('Backup БД по завершению обработки: НЕТ');
      if chkRestore.Checked then
      begin
        mReviewSettings.Lines.Add('Restore БД из backup-файла: ДА');
        mReviewSettings.Lines.Add('Restore File: ' + RestoreDBName);
      end
      else
        mReviewSettings.Lines.Add('Restore БД из backup-файла: НЕТ');
      if chkGetStatiscits.Checked then
        mReviewSettings.Lines.Add('По завершению обработки получить статистику: ДА')
      else
        mReviewSettings.Lines.Add('По завершению обработки получить статистику: НЕТ');
    end;
  end;

  if pgcSettings.ActivePageIndex <> pgcSettings.PageCount-1 then
    pgcSettings.ActivePageIndex :=  pgcSettings.ActivePageIndex + 1;

  gsDBSqueeze_MainForm.DefocusControl(edLogs, False);

end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actNextPageUpdate(Sender: TObject);
var
  EnabledValue: Boolean;
begin
  if not FConnected then
  begin
    btnNext1.Enabled :=
      (Trim(edDatabaseName.Text) > '')
      and (Trim(edUserName.Text) > '')
      and (Trim(edPassword.Text) > '');
  end;
  btnNext2.Enabled := FConnected; //and (FSThread.State);

  EnabledValue := True;
  if chkbSaveLogs.Checked then
    EnabledValue := Trim(edLogs.Text) > '';
  if chkBackup.Checked then
    EnabledValue := (EnabledValue) and (Trim(edtBackup.Text) > '');
  btnNext3.Enabled := EnabledValue;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
begin
  btnGo.Enabled := False;
  pgcSettings.ActivePage := tsConnection;
  pgcMain.ActivePage := tsLogs;
  
  WriteToLogFile('====================== Settings =======================');
  WriteToLogFile(mReviewSettings.Text);
  WriteToLogFile('=======================================================');
  WriteToLogFile(mLog.Text);

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

  FWrited:= True;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  btnGo.Enabled := (not actStop.Enabled) and FConnected;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actBackPageExecute(Sender: TObject);
begin
  if Sender is TButton then
    gsDBSqueeze_MainForm.DefocusControl(TButton(Sender), False);

  pgcSettings.ActivePageIndex := pgcSettings.ActivePageIndex - 1;
  gsDBSqueeze_MainForm.DefocusControl(edDatabaseName, False);
  gsDBSqueeze_MainForm.DefocusControl(edLogs, False);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDirectoryBrowseExecute(Sender: TObject);
var
  Dir: String;
  IsExecuted: Boolean;
begin
  gsDBSqueeze_MainForm.DefocusControl(btnLogDirBrowse, False);
  gsDBSqueeze_MainForm.DefocusControl(btnBackupBrowse, False);
  gsDBSqueeze_MainForm.DefocusControl(btnRestoreBrowse, False);

  IsExecuted := SelectDirectory('Select Directory', '', Dir);

  if IsExecuted then
  begin
    if btnLogDirBrowse.Tag = 1 then
    begin
      edLogs.Text := Dir;
      btnLogDirBrowse.Tag := 0;
    end
    else if btnBackupBrowse.Tag = 1 then
    begin
      edtBackup.Text := Dir;
      btnBackupBrowse.Tag := 0;
    end
    else if btnRestoreBrowse.Tag = 1 then
    begin
      edtRestore.Text := Dir;
      btnRestoreBrowse.Tag := 0;
    end;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.btnBackupBrowseMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDirectoryBrowseUpdate(Sender: TObject);
begin
  btnLogDirBrowse.Enabled := chkbSaveLogs.Checked;
  edLogs.Enabled := chkbSaveLogs.Checked;
  lblLogDir.Enabled := chkbSaveLogs.Checked;

  if chkBackup.Enabled then
  begin
    lblBackup.Enabled := chkBackup.Checked;
    edtBackup.Enabled := chkBackup.Checked;
    btnBackupBrowse.Enabled := chkBackup.Checked;
    chkRestore.Enabled := chkBackup.Checked;

    if not chkRestore.Enabled then
      chkRestore.Checked := False;
      
    lblRestore.Enabled := chkRestore.Checked;
    edtRestore.Enabled := chkRestore.Checked;
    btnRestoreBrowse.Enabled := chkRestore.Checked;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.GetConnectedEvent(const AConnected: Boolean);
begin
  if AConnected then
  begin
    statbarMain.Panels[3].Text := '        Connected';
    FSThread.DoSetDocTypeStrings;
  end
  else  begin
    statbarMain.Panels[3].Text := '     Not Connected';
    FWrited := False;
  end;                                                        
  FConnected := AConnected;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actStopExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnStop, False);
  case Application.MessageBox(
    PChar('Прервать процесс обработки БД?' + #13#10 +
      'Прерывание произойдет после завершения последней операции.' + #13#10 +
      'Возобновить процесс будет невозможно.'),
    PChar('Подтверждение'),
    MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST) of
      IDOK:
        begin
          FSThread.StopProcessing;
          btnStop.Tag := 1;
        end;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actStopUpdate(Sender: TObject);
begin
  if Assigned(FSThread) then
    actStop.Enabled := FSThread.Busy and (btnStop.Tag <> 1)
  else
    actStop.Enabled := False;

  if FIsProcessStop then                                                        ///TODO: переделать через event
  begin
    FSThread.WaitFor;    // ожидаем завершения
    ThreadDestroy;
    GetConnectedEvent(False);
    FIsProcessStop := False;
    btnStop.Tag := 0;
  end
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetTextDocTypesMemo(Text: String);
begin
  mIgnoreDocTypes.Clear;
  mIgnoreDocTypes.Text := Text;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actClearLogExecute(Sender: TObject);
begin
  if btnClearGeneralLog.Tag = 0 then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnClearGeneralLog, False);
    mLog.Clear;
    btnClearGeneralLog.Tag := 1;
  end
  else if btnClearSqlLog.Tag = 0 then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnClearSqlLog, False);
    mSqlLog.Clear;
    btnClearGeneralLog.Tag := 1;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actClearLogUpdate(Sender: TObject);
begin
  actClearLog.Enabled := FWrited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.btnClearGeneralLogMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 0;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.statbarMainDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel = StatusBar.Panels[1] then
  with pbMain do
  begin
    Top := Rect.Top;
    Left := Rect.Left;
    Width := Rect.Right - Rect.Left;
    Height := Rect.Bottom - Rect.Top;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.FinishEvent(const AIsFinished: Boolean);
begin
  if AIsFinished then
  begin
    pbMain.Step := pbMain.Max; 

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
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.LogSQLEvent(const ALogSQL: String);
begin
  mSqlLog.Lines.Add(ALogSQL);
  WriteToLogFile(ALogSQL);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.ErrorEvent(const AErrorMsg: String);
begin
  RecLog('[error] ' + AErrorMsg);
  Application.MessageBox(PChar(AErrorMsg), 'Ошибка', MB_OK + MB_ICONSTOP + MB_TOPMOST);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.WriteToLogFile(const AStr: String);
var
  RecStr: String;
begin
  if (FSaveLogs) and Assigned(FLogFileStream) then
  begin
    RecStr := AStr + #13#10;
    FLogFileStream.Position := FLogFileStream.Size;
    FLogFileStream.Write(RecStr[1], Length(RecStr));
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.RecLog(const ARec: String);
var
  RecStr: String;
begin 
  RecStr := FormatDateTime('h:nn:ss', Now) + ' -- ' + ARec;

  mLog.Lines.Add(RecStr);
  WriteToLogFile(RecStr);  // запись в лог-файл
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
begin
  if pbMain.Position <> ACurrentStep then
    pbMain.Position := ACurrentStep;
  if ACurrentStepName > '' then
    statbarMain.Panels[2].Text := ' ' + ACurrentStepName;
end;
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDefocusExecute(Sender: TObject);
begin
   if Sender is TCheckBox then
     gsDBSqueeze_MainForm.DefocusControl(TCheckBox(Sender), False)
   else if Sender is TTabControl then
     gsDBSqueeze_MainForm.DefocusControl(TTabControl(Sender), False)
   else if Sender is TRadioButton then
     gsDBSqueeze_MainForm.DefocusControl(TTabControl(Sender), False);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);
{var
  MsgStr: String;  }
begin
  { case  AState of
     1: MsgStr := 'Вы хотите продолжить? Последняя операция ' + ACallTime + ' была завершена успешно.';
     0: MsgStr := 'Вы хотите повторить попытку обработки? Последняя операция ' + ACallTime + ' завершилась ошибкой: ' + AErrorMessage;
     -1:  MsgStr := 'Вы хотите продолжить? Последняя операция ' + ACallTime + ' была прервана Вами до ее завершения';
   end;

   if (AFunctionKey > WM_USER + 12) and (AFunctionKey < WM_USER + 28)  then     ///TODO: проверить
   begin
     grpReprocessingType.Enabled := True;
     rbContinue.Enabled := True;
     rbStartOver.Enabled := True;

     case Application.MessageBox(PChar(MsgStr), 'Предупреждение', MB_YESNO + MB_ICONQUESTION) of
       IDYES:
         begin
           rbContinue.Checked := True;

           FContinueProcFunctionKey := AFunctionKey;
           FContinueProcState := AState;
         end;
       IDNO:
         begin
           rbStartOver.Checked := True;
         end;
     end;
   end
   else begin
     grpReprocessingType.Enabled := False;
     rbContinue.Enabled := False;
     rbStartOver.Enabled := False;
   end;   }
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actConfigBrowseExecute(Sender: TObject);
var
  OpenDlg: TOpenDialog;
  SaveDlg: TSaveDialog;
begin
  if Sender = btnLoadConfigFile then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnLoadConfigFile, False);

    OpenDlg := TOpenDialog.Create(Self);
    try
      OpenDlg.InitialDir := GetCurrentDir;
      OpenDlg.Options := [ofFileMustExist, ofEnableSizing];
      OpenDlg.Filter := 'Configuration File (*.INI)|*.ini';
      OpenDlg.FilterIndex := 1;

      if OpenDlg.Execute then
      begin
        gsIniOptions.LoadFromFile(OpenDlg.FileName);

        tbcDocTypes.TabIndex := 0;
        chk00Account.Checked := False;
        mReviewSettings.Clear;

        chkCalculateSaldo.Checked := gsIniOptions.DoCalculateSaldo;
        if gsIniOptions.DoProcessDocTypes then
          tbcDocTypes.TabIndex := 1
        else
          tbcDocTypes.TabIndex := 0;

        mIgnoreDocTypes.Clear;

        gsDBSqueeze_DocTypesForm.SetSelectedDocTypes(gsIniOptions.SelectedDocTypeKeys, gsIniOptions.SelectedBranchRows);
        SetTextDocTypesMemo(gsDBSqueeze_DocTypesForm.GetDocTypeMemoText);
        FWasSelectedDocTypes := (Trim(mIgnoreDocTypes.Text) > '');
      end;
    finally
      OpenDlg.Free;
    end;
  end
  else if Sender = btnSaveConfigFile then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnSaveConfigFile, False);
    SaveDlg := TSaveDialog.Create(self);
    try
      SaveDlg.InitialDir := GetCurrentDir;
      SaveDlg.Options := [ofFileMustExist, ofEnableSizing];
      SaveDlg.Filter := 'Configuration File (*.INI)|*.ini';
      SaveDlg.FilterIndex := 1;
      SaveDlg.DefaultExt := 'ini';

      if SaveDlg.Execute then
      begin
        gsIniOptions.DoEnterOstatkyAccount := chk00Account.Checked;
        gsIniOptions.DoProcessDocTypes := (tbcDocTypes.TabIndex = 1);
        gsIniOptions.DoCalculateSaldo := chkCalculateSaldo.Checked;
        gsIniOptions.SelectedDocTypeKeys := gsDBSqueeze_DocTypesForm.GetSelectedDocTypesStr;
        gsIniOptions.SelectedBranchRows := gsDBSqueeze_DocTypesForm.GetSelectedBranchRowsStr;

        gsIniOptions.SaveToFile(SaveDlg.FileName);
      end;
    finally
      SaveDlg.Free;
    end;
  end;
end;
//---------------------------------------------------------------------------
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
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.btnSelectDocTypesClick(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(TButton(Sender), False);
  if btnGo.Enabled then
  begin
    if gsDBSqueeze_DocTypesForm.ShowModal = mrOk then
      SetTextDocTypesMemo(gsDBSqueeze_DocTypesForm.GetDocTypeMemoText);

    FWasSelectedDocTypes := (mIgnoreDocTypes.Text > '');
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.btnGetStatisticsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;

end.
