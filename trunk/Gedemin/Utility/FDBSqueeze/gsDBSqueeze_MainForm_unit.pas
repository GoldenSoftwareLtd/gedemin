unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl, 
  ActnList, StdCtrls, gsDBSqueezeThread_unit, gd_ProgressNotifier_unit,
  ComCtrls, DBCtrls, Buttons, ExtCtrls, Spin, Grids;

type
  TgsDBSqueeze_MainForm = class(TForm, IgdProgressWatch)

    ActionList: TActionList;
    actTestConnect: TAction;
    actDisconnect: TAction;
    actGo: TAction;
    actCompany: TAction;
    actDatabaseBrowse: TAction;
    actGet: TAction;
    actUpdate: TAction;
    actRadioLocation: TAction;
    actDefaultPort: TAction;
    pnl1: TPanel;
    tbcPageController: TTabControl;
    pgcMain: TPageControl;
    tsSettings: TTabSheet;
    pgcSettings: TPageControl;
    tsConnection: TTabSheet;
    tsSqueezeSettings: TTabSheet;
    lbl5: TLabel;
    lbl6: TLabel;
    dtpClosingDate: TDateTimePicker;
    rbAllOurCompanies: TRadioButton;
    rbCompany: TRadioButton;
    cbbCompany: TComboBox;
    btnNext2: TButton;
    tsOptions: TTabSheet;
    btnNext3: TButton;
    tsProcess: TTabSheet;
    tsLogs: TTabSheet;
    mLog: TMemo;
    tsStatistics: TTabSheet;
    btnNext1: TButton;
    actNextPage: TAction;
    btnBack1: TButton;
    btnBack2: TButton;
    actBackPage: TAction;
    grpDatabase: TGroupBox;
    rbRemote: TRadioButton;
    rbLocale: TRadioButton;
    lbl4: TLabel;
    edtHost: TEdit;
    lbl8: TLabel;
    chkDefaultPort: TCheckBox;
    sePort: TSpinEdit;
    lbl1: TLabel;
    edDatabaseName: TEdit;
    btnDatabaseBrowse: TButton;
    grpAuthorization: TGroupBox;
    lbl2: TLabel;
    lbl3: TLabel;
    edUserName: TEdit;
    edPassword: TEdit;
    sttxt1: TStaticText;
    btntTestConnection: TButton;
    sttxt16: TStaticText;
    sttxt17: TStaticText;
    tsReviewSettings: TTabSheet;
    sttxt18: TStaticText;
    mSqlLog: TMemo;
    btnClearGeneralLog: TButton;
    btnClearSqlLog: TButton;
    sttxt19: TStaticText;
    sttxt20: TStaticText;
    sttxt21: TStaticText;
    txt2: TStaticText;
    btnGo: TBitBtn;
    btnBack3: TBitBtn;
    sttxtStateTestConnect: TStaticText;
    chkbSaveLogs: TCheckBox;
    lblLogDir: TLabel;
    chkBackup: TCheckBox;
    lblBackup: TLabel;
    edLogs: TEdit;
    btnLogDirBrowse: TButton;
    edtBackup: TEdit;
    btnBackupBrowse: TButton;
    mReviewSettings: TMemo;
    btnDisconnect: TButton;
    grpReprocessingType: TGroupBox;
    rbStartOver: TRadioButton;
    rbContinue: TRadioButton;
    sttxtActivUserCount: TStaticText;
    statbarMain: TStatusBar;
    pbMain: TProgressBar;
    btnStop: TButton;
    actDirectoryBrowse: TAction;
    actStop: TAction;
    shp3: TShape;
    pnl2: TPanel;
    StaticText6: TStaticText;
    sttxtUser: TStaticText;
    sttxtDialect: TStaticText;
    StaticText5: TStaticText;
    sttxt32: TStaticText;
    sttxtServerVer: TStaticText;
    sttxt34: TStaticText;
    sttxtODSVer: TStaticText;
    sttxtRemoteProtocol: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    sttxtRemoteAddr: TStaticText;
    sttxtPageSize: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    sttxtPageBuffers: TStaticText;
    sttxtForcedWrites: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    sttxtGarbageCollection: TStaticText;
    sttxt30: TStaticText;
    shp4: TShape;
    pnl3: TPanel;
    sttxt28: TStaticText;
    sttxt29: TStaticText;
    sttxtDBSizeBefore: TStaticText;
    sttxtDBSizeAfter: TStaticText;
    shp2: TShape;
    shp5: TShape;
    shp1: TShape;
    pnl4: TPanel;
    txt10: TStaticText;
    sttxt11: TStaticText;
    sttxtGdDocAfter: TStaticText;
    sttxtGdDoc: TStaticText;
    txt3: TStaticText;
    txt4: TStaticText;
    sttxtAcEntry: TStaticText;
    sttxtAcEntryAfter: TStaticText;
    txt5: TStaticText;
    sttxtInvMovement: TStaticText;
    sttxtInvMovementAfter: TStaticText;
    txt6: TStaticText;
    sttxtInvCard: TStaticText;
    sttxtInvCardAfter: TStaticText;
    sttxt2: TStaticText;
    sttxt3: TStaticText;
    sttxt4: TStaticText;
    sttxt5: TStaticText;
    sttxt6: TStaticText;
    sttxtProcGdDoc: TStaticText;
    sttxtProcAcEntry: TStaticText;
    sttxtProcInvMovement: TStaticText;
    sttxtProcInvCard: TStaticText;
    sttxtAfterProcGdDoc: TStaticText;
    sttxtAfterProcAcEntry: TStaticText;
    sttxtAfterProcInvMovement: TStaticText;
    sttxtAfterProcInvCard: TStaticText;
    shp6: TShape;
    btnGetStatistics: TButton;
    btnUpdateStatistics: TBitBtn;
    shp7: TShape;
    shp8: TShape;
    shp9: TShape;
    shp10: TShape;
    shp11: TShape;
    shp12: TShape;
    shp13: TShape;
    sttxtServerName: TStaticText;
    sttxtTestServer: TStaticText;
    sttxtActivConnects: TStaticText;
    sttxtTestConnectState: TStaticText;
    tsSettings2: TTabSheet;
    btn1: TButton;
    btn2: TButton;
    txt1: TStaticText;
    shp14: TShape;
    btnTMPstart: TButton;
    btnTMPstop: TButton;
    tbcDocTypes: TTabControl;
    strngrdIgnoreDocTypes: TStringGrid;
    mIgnoreDocTypes: TMemo;

    procedure actTestConnectExecute(Sender: TObject);
    procedure actTestConnectUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure actGoUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCompanyUpdate(Sender: TObject);
    procedure actCompanyExecute(Sender: TObject);
    procedure actDatabaseBrowseExecute(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure tbcPageControllerChange(Sender: TObject);
    procedure tbcPageControllerChanging(Sender: TObject; var AllowChange: Boolean);
    procedure actRadioLocationExecute(Sender: TObject);
    procedure actDefaultPortExecute(Sender: TObject);
    procedure actDefaultPortUpdate(Sender: TObject);
    procedure actNextPageExecute(Sender: TObject);
    procedure actNextPageUpdate(Sender: TObject);
    procedure actBackPageExecute(Sender: TObject);
    procedure actBackPageUpdate(Sender: TObject);
    procedure btnClearGeneralLogClick(Sender: TObject);
    procedure btnClearSqlLogClick(Sender: TObject);
    procedure actDirectoryBrowseExecute(Sender: TObject);
    procedure btnBackupBrowseMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actDirectoryBrowseUpdate(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure strngrdIgnoreDocTypesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure strngrdIgnoreDocTypesDblClick(Sender: TObject);

  private
    FSThread: TgsDBSqueezeThread;
    FContinueProcFunctionKey, FContinueProcState: Integer;
    FStartupTime : TDateTime;
    FConnected: Boolean;
    FSaveLogs: Boolean;
    FLogFileStream: TFileStream;
    FDatabaseName: String;

    FProcRowsSelectBits: TBits;
    FIgnoreRowsSelectBits: TBits;

    //FDocTypeIDArr: TIntegerDynArray;

    procedure ErrorEvent(const AErrorMsg: String);
    procedure GetConnectedEvent(const AConnected: Boolean);
    procedure WriteToLogFile(const AStr: String);
    procedure RecLog(const ARec: String);
    procedure LogSQLEvent(const ALogSQL: String);
    procedure GetInfoTestConnectEvent(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList);
    procedure UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);
    procedure GetDBPropertiesEvent(const AProperties: TStringList);
    procedure SetDocTypeStringsEvent(const ADocTypes: TStringList);
    procedure SetItemsCbbEvent(const ACompanies: TStringList);
    procedure GetDBSizeEvent(const AnDBSize: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String; const AnInvCard: String);
    procedure GetProcStatisticsEvent(const AProcGdDoc: String; const AnProcAcEntry: String; const AnProcInvMovement: String; const AnProcInvCard: String);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);

    procedure UpdateDocTypesMemo;
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
begin
  inherited;

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

  FConnected := False;
  FStartupTime := Now;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnErrorEvent := ErrorEvent;
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
  FContinueProcFunctionKey := 0;

  FProcRowsSelectBits := TBits.Create;
  FIgnoreRowsSelectBits := TBits.Create;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  if Assigned(FLogFileStream) then
    FLogFileStream.Free;
  FProcRowsSelectBits.Free;
  FIgnoreRowsSelectBits.Free;
  inherited;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := FConnected;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
begin
  FSThread.Disconnect;

  sttxtStateTestConnect.Caption := 'unknown';
  sttxtServerName.Caption := '';
  sttxtActivUserCount.Caption := '';
  sttxtServerName.Visible := False;
  sttxtTestServer.Visible := False;
  sttxtActivUserCount.Visible := False;
  sttxtActivConnects.Visible := False;

  cbbCompany.Clear;

  dtpClosingDate.Date := Date;
  rbAllOurCompanies.Checked := True;
  grpReprocessingType.Enabled := False;
  mReviewSettings.Clear;

  FConnected := False;
  FStartupTime := Now;

  btnGetStatistics.Enabled := False;
  btnUpdateStatistics.Enabled := False;

  mSqlLog.Clear;
  mLog.Clear;
end;

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

procedure TgsDBSqueeze_MainForm.UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);
var
  MsgStr: String;
begin
   case  AState of
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
   end;
end;

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;                  ///TODO: доработать
  var CanClose: Boolean);
var
  MsgStr: String;
begin
  MsgStr:= 'Do you really want to close?';
  ///CanClose := not FSThread.Busy;
  if MessageDlg(MsgStr, mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
    CanClose := False;

  if CanClose and FConnected then
    FSThread.Disconnect;
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

procedure TgsDBSqueeze_MainForm.ErrorEvent(const AErrorMsg: String);
begin
  Application.MessageBox(PChar(AErrorMsg), 'Ошибка', MB_OK + MB_ICONSTOP + MB_TOPMOST);
end;

procedure TgsDBSqueeze_MainForm.SetItemsCbbEvent(const ACompanies: TStringList);
begin
  if rbCompany.Checked then
  begin
    cbbCompany.Clear;
    cbbCompany.Items.AddStrings(ACompanies);
  end;
end;

procedure TgsDBSqueeze_MainForm.SetDocTypeStringsEvent(const ADocTypes: TStringList);
var
  I: Integer;
begin
  FIgnoreRowsSelectBits.Size := ADocTypes.Count;
  FProcRowsSelectBits.Size := ADocTypes.Count;

  strngrdIgnoreDocTypes.ColCount := 2;
  strngrdIgnoreDocTypes.RowCount :=  ADocTypes.Count;

  for I:=0 to ADocTypes.Count-1 do
  begin
    strngrdIgnoreDocTypes.Cells[0, I] := ADocTypes.Values[ADocTypes.Names[I]];  // имя типа дока
    strngrdIgnoreDocTypes.Cells[1, I] := ADocTypes.Names[I];                    // id типа
  end;
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

procedure TgsDBSqueeze_MainForm.UpdateProgress(
  const AProgressInfo: TgdProgressInfo);
begin
  if (AProgressInfo.Message > '') then
  begin
    RecLog(AProgressInfo.Message);
  end;
end;

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

procedure TgsDBSqueeze_MainForm.RecLog(const ARec: String);
var
  RecStr: String;
begin
  RecStr := FormatDateTime('h:nn:ss', Now) + ' -- ' + ARec;
  statbarMain.Panels[2].Text := ARec;
  mLog.Lines.Add(RecStr);

  WriteToLogFile(RecStr);  // запись в лог-файл
end;

procedure TgsDBSqueeze_MainForm.actCompanyUpdate(Sender: TObject);
begin
  cbbCompany.Enabled := (rbCompany.Checked) and (FConnected);
end;

procedure TgsDBSqueeze_MainForm.actCompanyExecute(Sender: TObject);
begin
  FSThread.DoSetItemsCbb;
end;

procedure TgsDBSqueeze_MainForm.actDatabaseBrowseExecute(Sender: TObject);
var
  openDialog : TOpenDialog;
begin
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

procedure TgsDBSqueeze_MainForm.actGetExecute(Sender: TObject);
begin
  FSThread.DoGetStatistics;
  FSThread.DoGetProcStatistics;
end;

procedure TgsDBSqueeze_MainForm.tbcPageControllerChange(Sender: TObject);
begin
    pgcMain.ActivePageIndex := tbcPageController.TabIndex;
end;

procedure TgsDBSqueeze_MainForm.tbcPageControllerChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
//
end;

procedure TgsDBSqueeze_MainForm.actRadioLocationExecute(Sender: TObject);
begin
  if rbLocale.Checked then
  begin
    gsDBSqueeze_MainForm.DefocusControl(rbLocale, False);
    edtHost.Text := 'localhost'
  end
  else begin
    gsDBSqueeze_MainForm.DefocusControl(rbRemote, False);
    edtHost.Text := '';
  end;
  edtHost.Enabled := rbRemote.Checked;
  chkDefaultPort.Checked := rbLocale.Checked;
end;

procedure TgsDBSqueeze_MainForm.actDefaultPortExecute(Sender: TObject);
begin
  sePort.Enabled := not chkDefaultPort.Checked;
end;

procedure TgsDBSqueeze_MainForm.actDefaultPortUpdate(Sender: TObject);
begin
  //
end;

procedure TgsDBSqueeze_MainForm.actNextPageExecute(Sender: TObject);
var
  LogFileName: String;
  BackupFileName: String;
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
      
      if (actDefaultPort.Enabled) and (chkDefaultPort.Checked) then
        FSThread.SetDBParams(
          edtHost.Text + ':' + edDatabaseName.Text,
          edUserName.Text,
          edPassword.Text)
      else if not chkDefaultPort.Checked then
        FSThread.SetDBParams(
        edtHost.Text + '/' + sePort.Text + ':' + edDatabaseName.Text,
        edUserName.Text,
        edPassword.Text);
      FDatabaseName := edDatabaseName.Text;

      FSThread.Connect;
      if btnGo.Enabled then
        FSThread.DoSetDocTypeStrings;
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
        FSThread.SetCompanyName(Trim(Copy(cbbCompany.Text, 1, Pos('|', cbbCompany.Text)-1)));

      FSThread.SetClosingDate(dtpClosingDate.Date);

      FSThread.SetSaldoParams(
        rbAllOurCompanies.Checked,
        rbCompany.Checked);

      btnGetStatistics.Enabled := FConnected;
      btnUpdateStatistics.Enabled := FConnected;
    end;
  end
  else if pgcSettings.ActivePage = tsSettings2 then
  begin
   if btnGo.Enabled then
    begin
      //if tbcDocTypes then
      //  SetFDocTypeIDArr
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
          LogFileName := Trim(edLogs.Text) + 'DBS_' + FDatabaseName + '_'+ FormatDateTime('yy-mm-dd_hh-mm', FStartupTime) + '.log'
        else
          LogFileName := Trim(edLogs.Text) + '\DBS_' + FDatabaseName + '_'+ FormatDateTime('yy-mm-dd_hh-mm', FStartupTime) + '.log';
      end;
      if edtBackup.Enabled then
      begin
        if (Trim(edtBackup.Text))[Length(Trim(edtBackup.Text))] = '\' then
          BackupFileName := Trim(edtBackup.Text) + 'DBS_Backup_' + FDatabaseName + '_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.bk'
        else
          BackupFileName := Trim(edtBackup.Text) + '\DBS_Backup_' + FDatabaseName + '_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.bk'
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
        rbContinue.Checked);

      mReviewSettings.Clear;
      mReviewSettings.Lines.Add('Host: ' + edtHost.Text);
      if chkDefaultPort.Checked then
        mReviewSettings.Lines.Add('Port: default')
      else
        mReviewSettings.Lines.Add('Port: ' + sePort.Text);
      mReviewSettings.Lines.Add('Database: ' + edDatabaseName.Text);
      mReviewSettings.Lines.Add('Username: ' + edUserName.Text);
      mReviewSettings.Lines.Add('Delete documents where DOCUMENTDATE < ' + DateToStr(dtpClosingDate.Date));
      if rbAllOurCompanies.Checked then
        mReviewSettings.Lines.Add('Calculate balance for companies: ' + 'ALL our companies')
      else
        mReviewSettings.Lines.Add('Calculate balance for companies: ' + cbbCompany.Text);
      if chkbSaveLogs.Checked then
      begin
        mReviewSettings.Lines.Add('Save logs to file: YES');
        mReviewSettings.Lines.Add('Log File: ' + LogFileName);
      end
      else
        mReviewSettings.Lines.Add('Save logs to file: NO');
      if chkBackup.Checked then
      begin
        mReviewSettings.Lines.Add('Backing up the database: YES');
        mReviewSettings.Lines.Add('Backup File: ' + BackupFileName);
      end
      else
        mReviewSettings.Lines.Add('Backing up the database: NO');
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
end;

procedure TgsDBSqueeze_MainForm.actNextPageUpdate(Sender: TObject);
var
  EnabledValue: Boolean;
begin
  if not FConnected then
  begin
    btnNext1.Enabled := (rbLocale.Checked or rbRemote.Checked)
      and (edtHost.Text > '')
      and (chkDefaultPort.Checked or sePort.Enabled)
      and (edDatabaseName.Text > '')
      and (edUserName.Text > '')
      and (edPassword.Text > '');
  end;
  btnNext2.Enabled := ((rbAllOurCompanies.Checked) or (rbCompany.Checked)) and (FSThread.State);

  EnabledValue := True;
  if chkbSaveLogs.Checked then
    EnabledValue := edLogs.Text > '';
  if chkBackup.Checked then
    EnabledValue := (EnabledValue) and (edtBackup.Text > '');
  if grpReprocessingType.Enabled then
    EnabledValue := (EnabledValue) and ((rbStartOver.Checked) or (rbContinue.Checked));
  btnNext3.Enabled := EnabledValue;
end;

procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
begin
  btnGo.Enabled := False;
  pgcSettings.ActivePage := tsConnection;
  tbcPageController.TabIndex := 2;
  pgcMain.ActivePage := tsLogs;
  
  WriteToLogFile('====================== Settings =======================');
  WriteToLogFile(mReviewSettings.Text);
  WriteToLogFile('=======================================================');
  WriteToLogFile(mLog.Text);

  if (rbContinue.Checked) and (FContinueProcFunctionKey > 0) then
    FSThread.ContinueProcessing(FContinueProcFunctionKey, FContinueProcState)
  else
    FSThread.StartProcessing;
end;

procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  actGo.Enabled := FConnected
    and (rbAllOurCompanies.Checked or rbCompany.Checked);
end;

procedure TgsDBSqueeze_MainForm.actTestConnectExecute(Sender: TObject);
begin
  sttxtTestServer.Visible := False;
  sttxtServerName.Visible := False;
  sttxtActivConnects.Visible := False;
  sttxtActivUserCount.Visible := False;
  sttxtStateTestConnect.Caption:= 'unknown';
  sttxtServerName.Caption := '';
  sttxtActivUserCount.Caption := '';

  if (actDefaultPort.Enabled and chkDefaultPort.Checked) then
    FSThread.StartTestConnect(
      edtHost.Text + ':' + edDatabaseName.Text,
      edUserName.Text,
      edPassword.Text)
  else if not chkDefaultPort.Checked then
    FSThread.StartTestConnect(
      edtHost.Text + '/' + sePort.Text + ':' + edDatabaseName.Text,
      edUserName.Text,
      edPassword.Text);

  FSThread.DoGetInfoTestConnect;
  FSThread.StopTestConnect;
end;

procedure TgsDBSqueeze_MainForm.actTestConnectUpdate(Sender: TObject);
begin
  actTestConnect.Enabled := (not FConnected) and (actNextPage.Enabled);
end;

procedure TgsDBSqueeze_MainForm.actBackPageExecute(Sender: TObject);
begin
  pgcSettings.ActivePageIndex := pgcSettings.ActivePageIndex - 1;
end;

procedure TgsDBSqueeze_MainForm.actBackPageUpdate(Sender: TObject);
begin
 //
end;

procedure TgsDBSqueeze_MainForm.btnClearGeneralLogClick(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnClearGeneralLog, False);
  mLog.Clear;
end;

procedure TgsDBSqueeze_MainForm.btnClearSqlLogClick(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(btnClearSqlLog, False);
  mSqlLog.Clear;
end;

procedure TgsDBSqueeze_MainForm.actDirectoryBrowseExecute(Sender: TObject);
var
  FDir: String;
begin
  if SelectDirectory('Select Directory', '', FDir) then
  begin
    if btnLogDirBrowse.Tag = 1 then
    begin
      edLogs.Text := FDir;
      btnLogDirBrowse.Tag := 0;
    end
    else if btnBackupBrowse.Tag = 1 then
    begin
      edtBackup.Text := FDir;
      btnLogDirBrowse.Tag := 0;
    end;
  end;
end;

procedure TgsDBSqueeze_MainForm.btnBackupBrowseMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TButton then
    TButton(Sender).Tag := 1;
end;

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
  end;
end;

procedure TgsDBSqueeze_MainForm.GetConnectedEvent(const AConnected: Boolean);
begin
  if AConnected then
    statbarMain.Panels[3].Text := '        Connected'
  else
    statbarMain.Panels[3].Text := '     Not Connected';
  FConnected := AConnected;
end;

procedure TgsDBSqueeze_MainForm.LogSQLEvent(const ALogSQL: String);
begin
  mSqlLog.Lines.Add(ALogSQL);
  WriteToLogFile(ALogSQL);
end;

procedure TgsDBSqueeze_MainForm.actStopExecute(Sender: TObject);
begin
  /// dialog
  FSThread.StopProcessing;
end;

procedure TgsDBSqueeze_MainForm.actStopUpdate(Sender: TObject);
begin
  actStop.Enabled := not btnGo.Enabled;
end;

procedure TgsDBSqueeze_MainForm.strngrdIgnoreDocTypesDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  AGrid:=TStringGrid(Sender);

   if not FIgnoreRowsSelectBits[ARow] then
     AGrid.Canvas.Brush.Color := clWhite
   else
     AGrid.Canvas.Brush.Color := $0088AEFF;

   if (gdSelected in State) then
   begin
     if not FIgnoreRowsSelectBits[ARow] then
     begin
       AGrid.Canvas.Brush.Color := $0088AEFF;
     end
     else
       AGrid.Canvas.Brush.Color := $001F67FC;
   end;
    AGrid.Canvas.FillRect(Rect);  //paint the backgorund color
    AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
end;

procedure TgsDBSqueeze_MainForm.strngrdIgnoreDocTypesDblClick(
  Sender: TObject);
begin
  if Sender = strngrdIgnoreDocTypes then
  begin
    if not FIgnoreRowsSelectBits[(Sender as TStringGrid).Row] then
      FIgnoreRowsSelectBits[(Sender as TStringGrid).Row] := True
    else begin
      FIgnoreRowsSelectBits[(Sender as TStringGrid).Row] := False;
    end;
    (Sender as TStringGrid).Repaint;

    UpdateDocTypesMemo;
  end;
end;

procedure TgsDBSqueeze_MainForm.UpdateDocTypesMemo;
var
  I: Integer;
  Str: String;
  Delimiter: String;
begin
  for I:=0 to FIgnoreRowsSelectBits.Size-1 do
  begin
    if FIgnoreRowsSelectBits[I] then
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

end.
