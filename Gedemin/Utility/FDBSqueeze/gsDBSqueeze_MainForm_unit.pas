unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl, 
  ActnList, ComCtrls, Buttons, StdCtrls, Grids, Spin, ExtCtrls,
  gsDBSqueezeThread_unit, gsDBSqueezeIniOptions_unit, gd_ProgressNotifier_unit,
  DBCtrls, CommCtrl;

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
    actDatabaseBrowse: TAction;
    actDefaultPort: TAction;
    actDefocus: TAction;
    actDirectoryBrowse: TAction;
    actDisconnect: TAction;
    actGet: TAction;
    actGo: TAction;
    actNextPage: TAction;
    actRadioLocation: TAction;
    actStop: TAction;
    actUpdate: TAction;
    btn1: TButton;
    btn2: TButton;
    btnBack1: TButton;
    btnBack2: TButton;
    btnBack3: TBitBtn;
    btnBackupBrowse: TButton;
    btnClearGeneralLog: TButton;
    btnClearSqlLog: TButton;
    btnDatabaseBrowse: TButton;
    btnGetStatistics: TButton;
    btnGo: TBitBtn;
    btnLogDirBrowse: TButton;
    btnNext1: TButton;
    btnNext2: TButton;
    btnNext3: TButton;
    btnRestoreBrowse: TButton;
    btnStop: TButton;
    btntTestConnection: TButton;
    btnUpdateStatistics: TBitBtn;
    cbbCharset: TComboBox;
    cbbCompany: TComboBox;
    chk00Account: TCheckBox;
    chk1: TCheckBox;
    chkBackup: TCheckBox;
    chkbSaveLogs: TCheckBox;
    chkDefaultPort: TCheckBox;
    chkRestore: TCheckBox;
    dtpClosingDate: TDateTimePicker;
    edDatabaseName: TEdit;
    edLogs: TEdit;
    edPassword: TEdit;
    edtBackup: TEdit;
    edtHost: TEdit;
    edtRestore: TEdit;
    edUserName: TEdit;
    grpAuthorization: TGroupBox;
    grpDatabase: TGroupBox;
    grpReprocessingType: TGroupBox;
    Label1: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl8: TLabel;
    lblBackup: TLabel;
    lblLogDir: TLabel;
    lblRestore: TLabel;
    mIgnoreDocTypes: TMemo;
    mLog: TMemo;
    mReviewSettings: TMemo;
    mSqlLog: TMemo;
    pbMain: TProgressBar;
    pgcMain: TPageControl;
    pgcSettings: TPageControl;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    pnl4: TPanel;
    rbAllOurCompanies: TRadioButton;
    rbCompany: TRadioButton;
    rbContinue: TRadioButton;
    rbLocale: TRadioButton;
    rbRemote: TRadioButton;
    rbStartOver: TRadioButton;
    sePort: TSpinEdit;
    shp10: TShape;
    shp11: TShape;
    shp12: TShape;
    shp13: TShape;
    shp14: TShape;
    shp1: TShape;
    shp2: TShape;
    shp3: TShape;
    shp4: TShape;
    shp5: TShape;
    shp6: TShape;
    shp7: TShape;
    shp8: TShape;
    shp9: TShape;
    statbarMain: TStatusBar;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    strngrdIgnoreDocTypes: TStringGrid;
    sttxt11: TStaticText;
    sttxt17: TStaticText;
    sttxt18: TStaticText;
    sttxt19: TStaticText;
    sttxt1: TStaticText;
    sttxt20: TStaticText;
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
    sttxtActivConnects: TStaticText;
    sttxtActivUserCount: TStaticText;
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
    sttxtServerName: TStaticText;
    sttxtServerVer: TStaticText;
    sttxtStateTestConnect: TStaticText;
    sttxtTestConnectState: TStaticText;
    sttxtTestServer: TStaticText;
    sttxtUser: TStaticText;
    tbcDocTypes: TTabControl;
    tbcPageController: TTabControl;
    tsAbout: TTabSheet;
    tsConnection: TTabSheet;
    tsLogs: TTabSheet;
    tsOptions: TTabSheet;
    tsReviewSettings: TTabSheet;
    tsSettings2: TTabSheet;
    tsSettings: TTabSheet;
    tsSqueezeSettings: TTabSheet;
    tsStatistics: TTabSheet;
    txt10: TStaticText;
    txt1: TStaticText;
    txt2: TStaticText;
    txt3: TStaticText;
    txt4: TStaticText;
    txt5: TStaticText;
    txt6: TStaticText;
    btnSaveConfigFile: TButton;
    txt7: TStaticText;
    txt9: TStaticText;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    txt8: TStaticText;
    txt11: TStaticText;
    btnLoadConfigFile: TButton;
    actConfigBrowse: TAction;

    procedure actBackPageExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure actClearLogUpdate(Sender: TObject);
    procedure actCompanyExecute(Sender: TObject);
    procedure actCompanyUpdate(Sender: TObject);
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
    procedure cbbCompanyDrawItem(Control: TWinControl; Index: Integer;Rect: TRect; State: TOwnerDrawState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure statbarMainDrawPanel(StatusBar: TStatusBar;Panel: TStatusPanel; const Rect: TRect);
    procedure strngrdIgnoreDocTypesDblClick(Sender: TObject);
    procedure strngrdIgnoreDocTypesDrawCell(Sender: TObject; ACol,ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure tbcPageControllerChange(Sender: TObject);
    procedure actConfigBrowseExecute(Sender: TObject);

  private
    FStartupTime: TDateTime;
    FSThread: TgsDBSqueezeThread;
    FLogFileStream: TFileStream;

    FConnected: Boolean;
    FSaveLogs: Boolean;
    FWrited: Boolean;
    FIsProcessStop: Boolean;

    FRowsSelectBits: TBits;
    FDocTypesList: TStringList;
    FDatabaseName: String;

    procedure ThreadDestroy;
    procedure RecLog(const ARec: String);
    procedure SetProgress(const ACurrentStepName: String; const ACurrentStep: Integer);
    procedure UpdateDocTypesMemo;
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
    procedure SetItemsCbbEvent(const ACompanies: TStringList);
    procedure UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
var
  I: Integer;
  CharsetList: TStringList;
begin
  inherited;

  CharsetList := TStringList.Create;
  FRowsSelectBits := TBits.Create;
  FDocTypesList := TStringList.Create;
  try
    // скрытие ярлыков PageControl
    for I := 0 to pgcMain.PageCount - 1 do
      pgcMain.Pages[I].TabVisible := False;
    pgcMain.ActivePage := tsSettings;
    for I := 0 to pgcSettings.PageCount - 1 do
      pgcSettings.Pages[I].TabVisible := False;
    pgcSettings.ActivePage := tsConnection;

    pnl1.Color := $00B7DEFF;
    mSqlLog.Clear;
    mLog.ReadOnly := True;
    mSqlLog.ReadOnly := True;
    dtpClosingDate.Date := Date;

    edtHost.Text := DEFAULT_HOST;
    sePort.Value := DEFAULT_PORT;
    edUserName.Text := DEFAULT_USER_NAME;
    edPassword.Text := DEFAULT_PASSWORD;

    pbMain.Parent := statbarMain;
    //remove progress bar border
    SetWindowLong(pbMain.Handle, GWL_EXSTYLE, GetWindowLong(pbMain.Handle,GWL_EXSTYLE) - WS_EX_STATICEDGE);
    SendMessage(pbMain.Handle, PBM_SETBARCOLOR, 0, $005555EC);
    pbMain.Max := MAX_PROGRESS_STEP;

    btnStop.Enabled := False;

    CharsetList.CommaText := CHARSET_LIST_CH1 + ',' + CHARSET_LIST_CH2;
    cbbCharset.Items.AddStrings(CharsetList);
    cbbCharset.ItemIndex := cbbCharset.Items.IndexOf(DEFAULT_CHARACTER_SET);

    cbbCompany.Style := csOwnerDrawFixed;
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
    FSThread.OnSetItemsCbb := SetItemsCbbEvent;
    FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
    FSThread.OnGetDBSize := GetDBSizeEvent;
    FSThread.OnGetStatistics := GetStatisticsEvent;
    FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
    FSThread.OnFinishEvent := FinishEvent;
  finally
    CharsetList.Free;
  end;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  if Assigned(FLogFileStream) then
    FLogFileStream.Free;
  FRowsSelectBits.Free;
  FDocTypesList.Free;
  inherited;
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
    actDisconnect.Enabled := btnNext1.Enabled;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.ThreadDestroy;
var
  I: Integer;
begin
  FStartupTime := Now;

  with strngrdIgnoreDocTypes do
  for I:=0 to ColCount-1 do
    Cols[I].Clear;

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
  cbbCompany.Clear;
  rbAllOurCompanies.Checked := True;
  chk00Account.Checked := False;
  tbcDocTypes.TabIndex := 0;
  mIgnoreDocTypes.Clear;
  chkbSaveLogs.Checked := False;
  chkBackup.Checked := False;
  chkRestore.Checked := False;
  edLogs.Text := '';
  edtBackup.Text := '';
  edtRestore.Text := '';
  grpReprocessingType.Enabled := False;
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
  FSThread.OnSetItemsCbb := SetItemsCbbEvent;
  FSThread.OnSetDocTypeStrings := SetDocTypeStringsEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FSThread.OnGetProcStatistics := GetProcStatisticsEvent;
  FSThread.OnFinishEvent := FinishEvent;

  SetProgress(' ', 0);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btntTestConnection, False);
  if actDisconnect.Caption = 'Disconnect' then
  begin
    GetConnectedEvent(False); //FSThread.Disconnect;                            ///TODO: после сообщения о дисконнекте разрушить
    ThreadDestroy;
    //btnGo.Enabled := False;
    //FConnected := False;
    mLog.Clear;
    mSqlLog.Clear;
  end
  else begin// test connect
    sttxtTestServer.Visible := False;
    sttxtServerName.Visible := False;
    sttxtActivConnects.Visible := False;
    sttxtActivUserCount.Visible := False;
    sttxtStateTestConnect.Caption:= 'unknown';
    sttxtServerName.Caption := '';
    sttxtActivUserCount.Caption := '';

    if (actDefaultPort.Enabled) and (chkDefaultPort.Checked) then
      FSThread.StartTestConnect(
        edDatabaseName.Text,
        edtHost.Text,
        edUserName.Text,
        edPassword.Text,
        cbbCharset.Text)
    else if not chkDefaultPort.Checked then
      FSThread.StartTestConnect(
        edDatabaseName.Text,
        edtHost.Text,
        edUserName.Text,
        edPassword.Text,
        cbbCharset.Text,
        sePort.Value);
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
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;                 ///TODO: доработать
  var CanClose: Boolean);
begin
  case Application.MessageBox(PChar('Вы действительно хотите выйти?'),
    PChar('Подтверждение'), MB_YESNO + MB_ICONQUESTION + MB_TOPMOST) of
    IDYES:
      CanClose := True;
    IDNO:
      CanClose := False;
  end;
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
  if (Trim(sttxtGdDoc.Caption) = '') and (Trim(sttxtAcEntry.Caption) = '') and (Trim(sttxtInvMovement.Caption) = '') then
  begin
    sttxtGdDoc.Caption := AGdDoc;
    sttxtAcEntry.Caption := AnAcEntry;
    sttxtInvMovement.Caption := AnInvMovement;
    sttxtInvCard.Caption := AnInvCard;
    WriteToLogFile('Original: ');
  end
  else begin
    sttxtGdDocAfter.Caption := AGdDoc;
    sttxtAcEntryAfter.Caption := AnAcEntry;
    sttxtInvMovementAfter.Caption := AnInvMovement;
    sttxtInvCardAfter.Caption := AnInvCard;
    WriteToLogFile('Now: ');
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
  if (Trim(sttxtProcGdDoc.Caption) = '') and (Trim(sttxtProcAcEntry.Caption) = '') and (Trim(sttxtProcInvMovement.Caption) = '') then
  begin
    sttxtProcGdDoc.Caption := AProcGdDoc;
    sttxtProcAcEntry.Caption := AnProcAcEntry;
    sttxtProcInvMovement.Caption := AnProcInvMovement;
    sttxtProcInvCard.Caption := AnProcInvCard;
    WriteToLogFile('Original: ');
  end
  else begin
    sttxtAfterProcGdDoc.Caption := AProcGdDoc;
    sttxtAfterProcAcEntry.Caption := AnProcAcEntry;
    sttxtAfterProcInvMovement.Caption := AnProcInvMovement;
    sttxtAfterProcInvCard.Caption := AnProcInvCard;
    WriteToLogFile('Now: ');
  end;
  WriteToLogFile('GD_DOCUMENT: ' + AProcGdDoc);
  WriteToLogFile('AC_ENTRY: ' + AnProcAcEntry);
  WriteToLogFile('INV_MOVEMENT: ' + AnProcInvMovement);
  WriteToLogFile('INV_CARD: ' + AnProcInvCard);
  WriteToLogFile('===============================================================');
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetItemsCbbEvent(const ACompanies: TStringList);
var
  I: Integer;
begin
  if rbCompany.Checked then
  begin
    cbbCompany.Clear;
    for I:=0 to ACompanies.Count-1 do
      cbbCompany.Items.Add(ACompanies.Names[I] + ';' + ACompanies.Values[ACompanies.Names[I]] + ';');
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.SetDocTypeStringsEvent(const ADocTypes: TStringList);
var
  I: Integer;
begin
  FreeAndNil(FRowsSelectBits);
  FRowsSelectBits := TBits.Create;

  FRowsSelectBits.Size := ADocTypes.Count;
  strngrdIgnoreDocTypes.ColCount := 2;
  strngrdIgnoreDocTypes.RowCount :=  ADocTypes.Count;

  for I:=0 to ADocTypes.Count-1 do
  begin
    strngrdIgnoreDocTypes.Cells[0, I] := ADocTypes.Values[ADocTypes.Names[I]];  // имя типа дока
    strngrdIgnoreDocTypes.Cells[1, I] := ADocTypes.Names[I];                    // id типа
  end;
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
procedure TgsDBSqueeze_MainForm.actCompanyUpdate(Sender: TObject);
begin
  cbbCompany.Enabled := (rbCompany.Checked) and (FConnected);
end;

procedure TgsDBSqueeze_MainForm.actCompanyExecute(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(rbCompany, False);
  FSThread.DoSetItemsCbb;
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
    openDialog.Options := [ofFileMustExist];
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
  FSThread.DoGetProcStatistics;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
  //actGet.Enabled := FConnected;
  btnGetStatistics.Enabled := FConnected;
  btnUpdateStatistics.Enabled := FConnected;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.tbcPageControllerChange(Sender: TObject);
begin
  pgcMain.ActivePageIndex := tbcPageController.TabIndex;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actRadioLocationExecute(Sender: TObject);
begin
  if rbLocale.Checked then
  begin
    gsDBSqueeze_MainForm.DefocusControl(rbLocale, False);
    edtHost.Text := DEFAULT_HOST
  end
  else begin
    gsDBSqueeze_MainForm.DefocusControl(rbRemote, False);
    edtHost.Text := '';
  end;
  edtHost.Enabled := rbRemote.Checked;
  chkDefaultPort.Checked := rbLocale.Checked;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actDefaultPortExecute(Sender: TObject);
begin
  sePort.Enabled := not chkDefaultPort.Checked;
  gsDBSqueeze_MainForm.DefocusControl(chkDefaultPort, False);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actNextPageExecute(Sender: TObject);
var
  I: Integer;
  LogFileName: String;
  BackupFileName: String;
  RestoreDBName: String;
  RequiredSize: Int64; // в байтах
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

      FDatabaseName := edDatabaseName.Text;
      if Pos('\', FDatabaseName) <> 0 then
        Delete(FDatabaseName, 1, LastDelimiter('\', FDatabaseName));

      if (actDefaultPort.Enabled) and (chkDefaultPort.Checked) then
        FSThread.SetDBParams(
          edDatabaseName.Text,
          edtHost.Text,
          edUserName.Text,
          edPassword.Text,
          cbbCharset.Text)
      else if not chkDefaultPort.Checked then
        FSThread.SetDBParams(
          edDatabaseName.Text,
          edtHost.Text,
          edUserName.Text,
          edPassword.Text,
          cbbCharset.Text,
          sePort.Value);

      FSThread.Connect;
    end;
  end
  else if pgcSettings.ActivePage = tsSqueezeSettings then
  begin
    if btnGo.Enabled then
    begin
      if rbLocale.Checked then
      begin
        chkBackup.Enabled := True;
        lblBackup.Enabled := True;
        edtBackup.Enabled := True;
        btnBackupBrowse.Enabled := True;
      end
      else begin
        chkBackup.Enabled := False;
        lblBackup.Enabled := False;
        edtBackup.Enabled := False;
        btnBackupBrowse.Enabled := False;
      end;

      if rbCompany.Checked then
        FSThread.SetCompanyKey(StrToInt(Trim(Copy(cbbCompany.Text, 1, Pos(';', cbbCompany.Text)-1))));

      FSThread.SetClosingDate(dtpClosingDate.Date);

      FSThread.SetSaldoParams(
        rbAllOurCompanies.Checked,
        rbCompany.Checked,
        chk00Account.Checked);
    end;
  end
  else if pgcSettings.ActivePage = tsSettings2 then
  begin
    if btnGo.Enabled then
    begin
      FDocTypesList.Clear;
      for I:=0 to FRowsSelectBits.Size-1 do
      begin
        if FRowsSelectBits[I] then
          FDocTypesList.Append(Trim(strngrdIgnoreDocTypes.Cells[1, I]));
      end;

      if FDocTypesList.Count <> 0 then
        FSThread.SetSelectDocTypes(FDocTypesList, (tbcDocTypes.TabIndex=1));
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
          RestoreDBName := Trim(edtRestore.Text) + '\DBS_RESTORE_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '_' + FDatabaseName
        else
          RestoreDBName := Trim(edtRestore.Text) + '\DBS_RESTORE_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '_' + FDatabaseName;
      end;

      if edtBackup.Enabled then
        RequiredSize := FSThread.DBSize;
      if edtRestore.Enabled then
      begin
        if (edtBackup.Enabled) and (ExtractFileDir(Trim(edtBackup.Text)) = ExtractFileDir(Trim(edtRestore.Text))) then
          RequiredSize := RequiredSize + FSThread.DBSize
        else
          RequiredSize := FSThread.DBSize;
      end;
      CheckFreeDiskSpace(edtBackup.Text, RequiredSize);
      CheckFreeDiskSpace(edtRestore.Text, RequiredSize);

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
        rbContinue.Checked);

      mReviewSettings.Clear;
      mReviewSettings.Lines.Add('Host: ' + edtHost.Text);
      if chkDefaultPort.Checked then
        mReviewSettings.Lines.Add('Port: default')
      else
        mReviewSettings.Lines.Add('Port: ' + sePort.Text);
      mReviewSettings.Lines.Add('Database: ' + edDatabaseName.Text);
      mReviewSettings.Lines.Add('Username: ' + edUserName.Text);
      mReviewSettings.Lines.Add('Удалить документы с DOCUMENTDATE < ' + DateToStr(dtpClosingDate.Date));
      if rbAllOurCompanies.Checked then
        mReviewSettings.Lines.Add('Считать сальдо для компаний: ' + 'ВСЕХ')
      else
        mReviewSettings.Lines.Add('Считать сальдо для компании: ' + cbbCompany.Text);
      if chk00Account.Checked then
        mReviewSettings.Lines.Add('Отразить бухгалтерские остатки на счете "00 Остатки": ДА')
      else
        mReviewSettings.Lines.Add('Отразить бухгалтерские остатки на счете "00 Остатки": НЕТ');
      if FDocTypesList.Count <> 0 then
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

      if grpReprocessingType.Enabled then
      begin
        if rbStartOver.Checked then
          mReviewSettings.Lines.Add('Reprocessing type: Start Over')
        else
          mReviewSettings.Lines.Add('Reprocessing type: Continue');
      end;
    end;
  end;

  if pgcSettings.ActivePageIndex <> pgcSettings.PageCount-1 then
    pgcSettings.ActivePageIndex :=  pgcSettings.ActivePageIndex + 1;

  gsDBSqueeze_MainForm.DefocusControl(rbAllOurCompanies, False);
  gsDBSqueeze_MainForm.DefocusControl(rbCompany, False);
  gsDBSqueeze_MainForm.DefocusControl(edLogs, False);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actNextPageUpdate(Sender: TObject);
var
  EnabledValue: Boolean;
begin
  if not FConnected then
  begin
    btnNext1.Enabled := (rbLocale.Checked or rbRemote.Checked)
      and (Trim(edtHost.Text) > '')
      and (chkDefaultPort.Checked or sePort.Enabled)
      and (Trim(edDatabaseName.Text) > '')
      and (Trim(edUserName.Text) > '')
      and (Trim(edPassword.Text) > '');
  end;
  btnNext2.Enabled := ((rbAllOurCompanies.Checked) or (rbCompany.Checked and (cbbCompany.Text > ''))) and FConnected; //and (FSThread.State);

  EnabledValue := True;
  if chkbSaveLogs.Checked then
    EnabledValue := Trim(edLogs.Text) > '';
  if chkBackup.Checked then
    EnabledValue := (EnabledValue) and (Trim(edtBackup.Text) > '');
  if grpReprocessingType.Enabled then
    EnabledValue := (EnabledValue) and ((rbStartOver.Checked) or (rbContinue.Checked));
  btnNext3.Enabled := EnabledValue;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
begin
  btnGo.Enabled := False;
  pgcSettings.ActivePage := tsConnection;
  tbcPageController.TabIndex := 1;
  pgcMain.ActivePage := tsLogs;
  
  WriteToLogFile('====================== Settings =======================');
  WriteToLogFile(mReviewSettings.Text);
  WriteToLogFile('=======================================================');
  WriteToLogFile(mLog.Text);

  FSThread.StartProcessing;

  FWrited:= True;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  btnGo.Enabled := (not actStop.Enabled) and FConnected and (rbAllOurCompanies.Checked or rbCompany.Checked);
  {btnGo.Enabled := FConnected  //actGo.Enabled := FConnected
    and (rbAllOurCompanies.Checked or rbCompany.Checked); }
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.actBackPageExecute(Sender: TObject);
begin
  if Sender is TButton then
    gsDBSqueeze_MainForm.DefocusControl(TButton(Sender), False);

  pgcSettings.ActivePageIndex := pgcSettings.ActivePageIndex - 1;
  gsDBSqueeze_MainForm.DefocusControl(rbLocale, False);
  gsDBSqueeze_MainForm.DefocusControl(rbAllOurCompanies, False);
  gsDBSqueeze_MainForm.DefocusControl(rbCompany, False);
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
      'Прерывание произойдет после завершения последней операции' + #13#10 +
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
procedure TgsDBSqueeze_MainForm.strngrdIgnoreDocTypesDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  AGrid:=TStringGrid(Sender);

   if not FRowsSelectBits[ARow] then
     AGrid.Canvas.Brush.Color := clWhite
   else
     AGrid.Canvas.Brush.Color := $0088AEFF;

   if (gdSelected in State) then
   begin
     if not FRowsSelectBits[ARow] then
     begin
       AGrid.Canvas.Brush.Color := $0088AEFF;
     end
     else
       AGrid.Canvas.Brush.Color := $001F67FC;
   end;
    AGrid.Canvas.FillRect(Rect);  //paint the backgorund color
    AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.strngrdIgnoreDocTypesDblClick(
  Sender: TObject);
begin
  if Sender = strngrdIgnoreDocTypes then
  begin
    if not FRowsSelectBits[(Sender as TStringGrid).Row] then
      FRowsSelectBits[(Sender as TStringGrid).Row] := True
    else begin
      FRowsSelectBits[(Sender as TStringGrid).Row] := False;
    end;
    (Sender as TStringGrid).Repaint;

    UpdateDocTypesMemo;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.UpdateDocTypesMemo;
var
  I: Integer;
  Str: String;
  Delimiter: String;
begin
  for I:=0 to FRowsSelectBits.Size-1 do
  begin
    if FRowsSelectBits[I] then
    begin
      if Str <> '' then
        Delimiter := ', '
      else
        Delimiter := '';
      Str := Str + Delimiter + strngrdIgnoreDocTypes.Cells[0, I] + ' (' + strngrdIgnoreDocTypes.Cells[1, I] + ')';
    end;
  end;
  mIgnoreDocTypes.Clear;
  mIgnoreDocTypes.Text := Str;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.cbbCompanyDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ArrWidth: array [0..2] of Integer;
  ColumnText, CbbItemText: String;
  SeparatorPos: Integer;
  rcColumn: TRect;
begin
  cbbCompany.Canvas.Brush.Style := bsSolid;
  cbbCompany.Canvas.FillRect(Rect);

  ArrWidth[0] := 0;
  ArrWidth[1] := 65;  // Ширина первой колонки
  ArrWidth[2] := 400; // Ширина второй колонки

  CbbItemText := cbbCompany.Items[Index]; // Значения для колонок должны быть разделены ';'

  // Прорисовка первой колонки
  rcColumn.Left   := Rect.Left + ArrWidth[0] + 2;
  rcColumn.Right  := Rect.Left + ArrWidth[1] - 2;
  rcColumn.Top    := Rect.Top;
  rcColumn.Bottom := Rect.Bottom;
  // Текст первой колонки
  SeparatorPos := Pos(';', CbbItemText);
  ColumnText := Copy(CbbItemText, 1, SeparatorPos - 1);
  // Прорисовка текста
  cbbCompany.Canvas.TextRect(rcColumn, rcColumn.Left, rcColumn.Top, ColumnText);
  // Прорисовка разделительной линии между колонками
  cbbCompany.Canvas.MoveTo(rcColumn.Right, rcColumn.Top);
  cbbCompany.Canvas.LineTo(rcColumn.Right, rcColumn.Bottom);

  // Прорисовка второй колонки
  rcColumn.Left  := Rect.Left + ArrWidth[1] + 2;
  rcColumn.Right := Rect.Left + ArrWidth[2] - 2;
  // Текст второй колонки
  CbbItemText := Copy(CbbItemText, SeparatorPos + 1, Length(CbbItemText) - SeparatorPos);
  SeparatorPos := Pos(';', CbbItemText);
  ColumnText := Copy(CbbItemText, 1, SeparatorPos - 1);
  // Прорисовка текста
  cbbCompany.Canvas.TextRect(rcColumn, rcColumn.Left, rcColumn.Top, ColumnText);
  // Прорисовка разделительной линии между колонками
  cbbCompany.Canvas.MoveTo(rcColumn.Right, rcColumn.Top);
  cbbCompany.Canvas.LineTo(rcColumn.Right, rcColumn.Bottom);
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
   Application.MessageBox(PChar(FormatDateTime('h:nn', Now) + '  Обработка БД успешно завершена!'),
     PChar('Сообщение'), MB_OK + MB_ICONINFORMATION + MB_TOPMOST)
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
  openDialog: TOpenDialog;
  saveDialog: TSaveDialog;
  I: Integer;

  function PosR2L(const FindS, SrcS: String): Integer; // инндекс последнего вхождения

    function InvertS(const S: String): string;
    var
      i, Len: Integer;
    begin
      Len := Length(S);
      SetLength(Result, Len);
      for i := 1 to Len do
        Result[i] := S[Len - i + 1];
    end;

  var
    ps: Integer;
  begin
    ps := Pos(InvertS(FindS), InvertS(SrcS));
    if ps <> 0 then
      Result := Length(SrcS) - Length(FindS) - ps + 2
    else
      Result := 0;
  end;
begin
  if Sender = btnLoadConfigFile then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnLoadConfigFile, False);
    openDialog := TOpenDialog.Create(Self);
    try
      openDialog.InitialDir := GetCurrentDir;
      openDialog.Options := [ofFileMustExist];
      openDialog.Filter := 'Configuration File (*.INI)|*.ini';
      openDialog.FilterIndex := 1;

      if openDialog.Execute then
      begin
        gsIniOptions.LoadFromFile(openDialog.FileName);
        rbAllOurCompanies.Checked := False;

        with strngrdIgnoreDocTypes do
        for I:=0 to ColCount-1 do
          Cols[I].Clear;
        mIgnoreDocTypes.Clear;
        tbcDocTypes.TabIndex := 0;
        mReviewSettings.Clear;

        rbCompany.Checked := gsIniOptions.DoCalculateOnlyCompanySaldo;
        if gsIniOptions.DoCalculateOnlyCompanySaldo then
          cbbCompany.ItemIndex := cbbCompany.Items.IndexOf(IntToStr(gsIniOptions.SelectedCompanyKey) + ';' + gsIniOptions.SelectedCompanyName + ';');
        chk00Account.Checked := gsIniOptions.DoEnterOstatkyAccount;
      end;
    finally
      openDialog.Free;
    end;
  end
  else if Sender = btnSaveConfigFile then
  begin
    gsDBSqueeze_MainForm.DefocusControl(btnSaveConfigFile, False);
    saveDialog := TSaveDialog.Create(self);
    try
      saveDialog.InitialDir := GetCurrentDir;
      saveDialog.Options := [ofFileMustExist];
      saveDialog.Filter := 'Configuration File (*.INI)|*.ini';
      saveDialog.FilterIndex := 1;
      saveDialog.DefaultExt := 'ini';
      
      if saveDialog.Execute then
      begin
        gsIniOptions.DoCalculateOnlyCompanySaldo := rbCompany.Checked;
        if rbCompany.Checked then
        begin
          gsIniOptions.SelectedCompanyKey := StrToInt(Trim(Copy(Trim(cbbCompany.Text), 1, Pos(';', Trim(cbbCompany.Text))-1)));
          gsIniOptions.SelectedCompanyName := Trim(Copy(cbbCompany.Text, Pos(';', cbbCompany.Text)+1, PosR2L(';', cbbCompany.Text)-1));  ///todo
          ShowMessage(Trim(Copy(cbbCompany.Text, Pos(';', cbbCompany.Text)+1, (PosR2L(';', cbbCompany.Text)-3))));
        end;
        gsIniOptions.DoEnterOstatkyAccount := chk00Account.Checked;
        gsIniOptions.SaveToFile(saveDialog.FileName);
      end;
    finally
      saveDialog.Free;
    end;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_MainForm.CheckFreeDiskSpace(const APath: String; const AFileSize: Int64);
var
  CurDirectory: String;
  FreeSpace: Int64;
begin
  CurDirectory := GetCurrentDir;
  SetCurrentDir(ExtractFileDir(APath));
  try
    FreeSpace := DiskFree(0);
    if FreeSpace < AFileSize then
      Application.MessageBox(PChar('Недостаточно свободного места! Освободите ' + IntToStr((AFileSize - FreeSpace) div 1048576)),
        PChar('Предупреждение'), MB_OK + MB_ICONWARNING + MB_TOPMOST);
  finally
    SetCurrentDir(CurDirectory);
  end;
end;
//---------------------------------------------------------------------------

//initialization
//  ReportMemoryLeaksOnShutdown := True;

end.
