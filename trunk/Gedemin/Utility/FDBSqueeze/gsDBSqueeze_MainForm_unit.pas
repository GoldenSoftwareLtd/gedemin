unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl, 
  ActnList, StdCtrls, gsDBSqueezeThread_unit, gd_ProgressNotifier_unit,
  ComCtrls, DBCtrls, Buttons, ExtCtrls, Spin;

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
    btnGetStatistics: TButton;
    sttxt21: TStaticText;
    txt10: TStaticText;
    sttxt11: TStaticText;
    txt3: TStaticText;
    txt5: TStaticText;
    txt4: TStaticText;
    sttxtGdDoc: TStaticText;
    sttxtGdDocAfter: TStaticText;
    sttxtAcEntry: TStaticText;
    sttxtAcEntryAfter: TStaticText;
    sttxtInvMovement: TStaticText;
    sttxtInvMovementAfter: TStaticText;
    txt2: TStaticText;
    sttxt28: TStaticText;
    sttxt29: TStaticText;
    btnUpdateStatistics: TBitBtn;
    sttxtDBSizeBefore: TStaticText;
    sttxtDBSizeAfter: TStaticText;
    sttxt30: TStaticText;
    StaticText6: TStaticText;
    StaticText5: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    sttxtODSVer: TStaticText;
    sttxtServerVer: TStaticText;
    sttxt32: TStaticText;
    sttxt34: TStaticText;
    sttxtUser: TStaticText;
    sttxtDialect: TStaticText;
    sttxtRemoteProtocol: TStaticText;
    sttxtRemoteAddr: TStaticText;
    sttxtPageSize: TStaticText;
    sttxtPageBuffers: TStaticText;
    sttxtForcedWrites: TStaticText;
    sttxtGarbageCollection: TStaticText;
    btnGo: TBitBtn;
    btnBack3: TBitBtn;
    sttxtStateTestConnect: TStaticText;
    sttxtServer: TStaticText;
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
    lblTestConnectState: TLabel;
    lblServerVersion: TLabel;
    lblActivConnectCount: TLabel;
    statbarMain: TStatusBar;
    pbMain: TProgressBar;
    btnStop: TButton;
    actDirectoryBrowse: TAction;

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
    procedure actGetUpdate(Sender: TObject);
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
    
  private
    FSThread: TgsDBSqueezeThread;
    FContinueProcFunctionKey, FContinueProcState: Integer;
    FStartupTime : TDateTime;
    FConnected: Boolean;

    procedure GetConnectedEvent(const AConnected: Boolean);
    procedure RecLog(const ARec: String);
    procedure GetInfoTestConnectEvent(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList);
    procedure UsedDBEvent(const AFunctionKey: Integer; const AState: Integer; const ACallTime: String; const AErrorMessage: String);
    procedure GetDBPropertiesEvent(const AProperties: TStringList);
    procedure SetItemsCbbEvent(const ACompanies: TStringList);
    procedure GetDBSizeEvent(const AnDBSize: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);

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

  pnl1.Color := RGB(255,228,148);
  mLog.ReadOnly := True;
  dtpClosingDate.Date := Date;

  FConnected := False;
  FStartupTime := Now;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetConnected := GetConnectedEvent;
  FSThread.OnGetInfoTestConnect := GetInfoTestConnectEvent;
  FSThread.OnUsedDB := UsedDBEvent;
  FSThread.OnGetDBProperties := GetDBPropertiesEvent;
  FSThread.OnSetItemsCbb := SetItemsCbbEvent;
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
  FContinueProcFunctionKey := 0;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  inherited;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := FConnected;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
begin
  cbbCompany.Clear;
  lblTestConnectState.Enabled := False;
  sttxtStateTestConnect.Enabled := False;
  sttxtStateTestConnect.Caption := '';
  sttxtServer.Caption := '';
  sttxtActivUserCount.Caption := '';
  sttxtServer.Visible := False;
  sttxtActivUserCount.Visible := False;
  lblServerVersion.Visible := False;
  lblActivConnectCount.Visible := False;
  FSThread.Disconnect;

  FSThread.DoGetDBSize;
end;

procedure TgsDBSqueeze_MainForm.GetInfoTestConnectEvent(const AConnectSuccess: Boolean; const AConnectInfoList: TStringList);
begin
  lblTestConnectState.Enabled := True;
  sttxtStateTestConnect.Enabled := True;
  if AConnectSuccess then
  begin
    sttxtStateTestConnect.Caption := 'SUCCESS';
    sttxtServer.Caption := sttxtServer.Caption + AConnectInfoList.Values['ServerVersion'];
    sttxtActivUserCount.Caption := sttxtActivUserCount.Caption + AConnectInfoList.Values['ActivConnectCount'];
    sttxtServer.Visible := True;
    sttxtActivUserCount.Visible := True;
    lblServerVersion.Visible := True;
    lblActivConnectCount.Visible := True;
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

   if (AFunctionKey > WM_USER + 12) and (AFunctionKey < WM_USER + 28)  then
   begin
     grpReprocessingType.Enabled := True;
     rbContinue.Enabled := True;
     rbStartOver.Enabled := True;
     if MessageDlg(MsgStr, mtConfirmation, [mbOk, mbCancel], 0) = mrOk then
     begin
       rbContinue.Checked := True;

       FContinueProcFunctionKey := AFunctionKey;
       FContinueProcState := AState;
     end
     else
      rbStartOver.Checked := True;
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
  else
   sttxtDBSizeAfter.Caption := AnDBSize;
end;

procedure TgsDBSqueeze_MainForm.GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String);
begin
  if (Trim(sttxtGdDoc.Caption) = '') and (Trim(sttxtAcEntry.Caption) = '') and (Trim(sttxtInvMovement.Caption) = '') then
  begin
    sttxtGdDoc.Caption := AGdDoc;
    sttxtAcEntry.Caption := AnAcEntry;
    sttxtInvMovement.Caption := AnInvMovement;
  end
  else
  begin
    sttxtGdDocAfter.Caption := AGdDoc;
    sttxtAcEntryAfter.Caption := AnAcEntry;
    sttxtInvMovementAfter.Caption := AnInvMovement;
  end;
end;

procedure TgsDBSqueeze_MainForm.SetItemsCbbEvent(const ACompanies: TStringList);
begin
  if rbCompany.Checked then
  begin
    cbbCompany.Clear;
    cbbCompany.Items.AddStrings(ACompanies);
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
    RecLog(AProgressInfo.Message)
  end;
end;

procedure TgsDBSqueeze_MainForm.RecLog(const ARec: String);
begin
   mLog.Lines.Add(FormatDateTime('h:nn:ss', Now) + ' -- ' + ARec);
   statbarMain.Panels[2].Text := ARec;
   //запись в файл
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
end;

procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
      //
end;
  
procedure TgsDBSqueeze_MainForm.tbcPageControllerChange(Sender: TObject);
begin
    //
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

      FSThread.DoGetDBSize;
      FSThread.Connect;               ///////////Review
      FSThread.DoGetDBProperties;
    end;
  end;
  if pgcSettings.ActivePage = tsSqueezeSettings then
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
        FSThread.SetCompanyName(cbbCompany.Text);

      FSThread.SetClosingDate(dtpClosingDate.Date);

      FSThread.SetSaldoParams(
        rbAllOurCompanies.Checked,
        rbCompany.Checked);
    end;
  end;
  if pgcSettings.ActivePage = tsOptions then
  begin
    if btnGo.Enabled then
    begin
      if edLogs.Enabled then
      begin
        if (Trim(edLogs.Text))[Length(Trim(edLogs.Text))] = '\' then
          LogFileName := Trim(edLogs.Text) + 'DBS_Log_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.log'
        else
          LogFileName := Trim(edLogs.Text) + '\DBS_Log_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.log';
      end;
      if edtBackup.Enabled then
      begin
        if (Trim(edtBackup.Text))[Length(Trim(edtBackup.Text))] = '\' then
          BackupFileName := Trim(edtBackup.Text) + 'DBS_Backup_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.bk'
        else
          BackupFileName := Trim(edtBackup.Text) + '\DBS_Backup_' + FormatDateTime('yymmdd_hhmm', FStartupTime) + '.bk'
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
  btnNext2.Enabled := (rbAllOurCompanies.Checked) or (rbCompany.Checked);

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
  sttxtStateTestConnect.Caption:= '';
  sttxtServer.Caption := '';
  sttxtActivUserCount.Caption := '';
  //mLog.Lines.Add('Test Connect...');
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
   //if    FSThread.State then
    // сообщение об успехе
    FSThread.DoGetInfoTestConnect;
  //else
    // сообщение о провале

  FSThread.StopTestConnect;
  //mLog.Lines.Add('Test Connect... OK');
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

{
procedure TgsDBSqueeze_MainForm.Timer1Timer(Sender: TObject);
  const Str: string = '1111111111111112222222222222222222222222222223333333333333333333333333344444444444445555555555555555555555 ';
begin
  statbarMain.Panels[2].Text := Str;
  if Length(Str) > 52 then
  begin
    Str:= Copy( Str, 2, Length( Str )-1 ) + Str[1];
  end;              
end;       }

end.
