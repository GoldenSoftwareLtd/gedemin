unit gdc_dlgAutoTask_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, ExtCtrls, xDateEdits, ComCtrls, gd_WebClientControl_unit,
  gd_messages_const;

type
  Tgdc_dlgAutoTask = class(Tgdc_dlgTR)
    odCmdLine: TOpenDialog;
    actExecTask: TAction;
    lbPriority: TLabel;
    Label2: TLabel;
    lbStartTime: TLabel;
    lbEndTime: TLabel;
    Label4: TLabel;
    gbTimeTables: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    rbExactDate: TRadioButton;
    xdbeExactDate: TxDateDBEdit;
    rbMonthly: TRadioButton;
    rbWeekly: TRadioButton;
    dbcbWeekly: TDBComboBox;
    rbDaily: TRadioButton;
    dbcbMonthly: TDBComboBox;
    rbAtStartup: TRadioButton;
    dbcbPriority: TDBComboBox;
    xdbeStartTime: TxDateDBEdit;
    xdbeEndTime: TxDateDBEdit;
    btnClearTime: TButton;
    lbName: TLabel;
    lbDescription: TLabel;
    lbUser: TLabel;
    dbcbDisabled: TDBCheckBox;
    dbedName: TDBEdit;
    dbmDescription: TDBMemo;
    pcTask: TPageControl;
    tsFunction: TTabSheet;
    iblkupFunction: TgsIBLookupComboBox;
    tsCmd: TTabSheet;
    Label1: TLabel;
    dbeCmdLine: TDBEdit;
    btnCmdLine: TButton;
    tsBackup: TTabSheet;
    Label7: TLabel;
    dbeBackup: TDBEdit;
    btBackup: TButton;
    iblkupUser: TgsIBLookupComboBox;
    btExecTask: TButton;
    Label8: TLabel;
    dbedComputer: TDBEdit;
    btnIP: TButton;
    btnCN: TButton;
    Label9: TLabel;
    dbedPulse: TDBEdit;
    tsReport: TTabSheet;
    iblkupReport: TgsIBLookupComboBox;
    dbcbExportType: TDBComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    iblkupSMTP: TgsIBLookupComboBox;
    iblkupGroup: TgsIBLookupComboBox;
    Label13: TLabel;
    dbeRecipients: TDBEdit;
    Label15: TLabel;
    procedure btnCmdLineClick(Sender: TObject);
    procedure btnClearTimeClick(Sender: TObject);
    procedure btBackupClick(Sender: TObject);
    procedure actExecTaskExecute(Sender: TObject);
    procedure actExecTaskUpdate(Sender: TObject);
    procedure btnCNClick(Sender: TObject);
    procedure btnIPClick(Sender: TObject);

  private
    procedure OnWebClientThreadNotify(var Msg : TMessage);
      message WM_GD_FINISH_SEND_EMAIL;

  protected
    procedure DestroyWindowHandle; override;

  public
    procedure SetupRecord; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgAutoTask: Tgdc_dlgAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList, gd_security, gd_common_functions, gd_AutoTaskThread,
  jclSysInfo;

procedure Tgdc_dlgAutoTask.OnWebClientThreadNotify(var Msg : TMessage);
var
  State: TgdEmailMessageState;
  ErrorMsg: String;
begin
  if gdWebClientControl.GetEmailState(Msg.WParam, State, ErrorMsg) then
  begin
    if State = emsSent then
      MessageBox(Handle,
        'Сообщение отправлено.',
        'Внимание',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL)
    else
      MessageBox(Handle,
        PChar(ErrorMsg),
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

procedure Tgdc_dlgAutoTask.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Assert(gdWebClientControl <> nil);

  inherited;

  if gdcObject.FieldByName('cmdline').AsString > '' then
    pcTask.ActivePage := tsCmd
  else if gdcObject.FieldByName('backupfile').AsString > '' then
    pcTask.ActivePage := tsBackup
  else if gdcObject.FieldByName('functionkey').AsInteger > 0 then
    pcTask.ActivePage := tsFunction
  else
    pcTask.ActivePage := tsReport;

  if gdcObject.FieldByName('atstartup').AsInteger <> 0 then
    rbAtStartup.Checked := True
  else if gdcObject.FieldByName('exactdate').AsDateTime > 0 then
    rbExactDate.Checked := True
  else if gdcObject.FieldByName('monthly').AsInteger <> 0 then
    rbMonthly.Checked := True
  else if gdcObject.FieldByName('weekly').AsInteger <> 0 then
    rbWeekly.Checked := True
  else
    rbDaily.Checked := True;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if pcTask.ActivePage = tsFunction then
  begin
    gdcObject.FieldByName('cmdline').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('reportkey').Clear;
    gdcObject.FieldByName('backupfile').Clear;
    gdcObject.FieldByName('emailgroupkey').Clear;
    gdcObject.FieldByName('emailrecipients').Clear;
    gdcObject.FieldByName('emailsmtpkey').Clear;
    gdcObject.FieldByName('emailexporttype').Clear;
  end
  else if pcTask.ActivePage = tsCmd then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('reportkey').Clear;
    gdcObject.FieldByName('backupfile').Clear;
    gdcObject.FieldByName('emailgroupkey').Clear;
    gdcObject.FieldByName('emailrecipients').Clear;
    gdcObject.FieldByName('emailsmtpkey').Clear;
    gdcObject.FieldByName('emailexporttype').Clear;
  end
  else if pcTask.ActivePage = tsBackup then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('reportkey').Clear;
    gdcObject.FieldByName('cmdline').Clear;
    gdcObject.FieldByName('emailgroupkey').Clear;
    gdcObject.FieldByName('emailrecipients').Clear;
    gdcObject.FieldByName('emailsmtpkey').Clear;
    gdcObject.FieldByName('emailexporttype').Clear;
  end
  else if pcTask.ActivePage = tsReport then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('cmdline').Clear;
    gdcObject.FieldByName('backupfile').Clear;
  end;

  if rbAtStartup.Checked then
  begin
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('daily').Clear;
    gdcObject.FieldByName('atstartup').AsInteger := 1;
  end
  else if rbExactDate.Checked then
  begin
    gdcObject.FieldByName('atstartup').Clear;
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('exactdate').IsNull then
      gdcObject.FieldByName('exactdate').AsDateTime := Date;
  end
  else if rbMonthly.Checked then
  begin
    gdcObject.FieldByName('atstartup').Clear;
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('monthly').IsNull then
      gdcObject.FieldByName('monthly').AsInteger := 1;
  end
  else if rbWeekly.Checked then
  begin
    gdcObject.FieldByName('atstartup').Clear;
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('weekly').IsNull then
      gdcObject.FieldByName('weekly').AsInteger := 1;
  end
  else if rbDaily.Checked then
  begin
    gdcObject.FieldByName('atstartup').Clear;
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('daily').AsInteger := 1;
  end;

  if (gdcObject.FieldByName('starttime').AsDateTime > 0)
    and (gdcObject.FieldByName('endtime').AsDateTime <= gdcObject.FieldByName('starttime').AsDateTime) then
  begin
    if gdcObject.FieldByName('starttime').AsDateTime < 23 / 24 then
      gdcObject.FieldByName('endtime').AsDateTime :=
        gdcObject.FieldByName('starttime').AsDateTime + 1 / 24
    else
      gdcObject.FieldByName('endtime').AsDateTime := (MSecsPerDay - 1) / MSecsPerDay;
  end;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.btnCmdLineClick(Sender: TObject);
begin
  if odCmdLine.Execute then
    gdcObject.FieldByName('cmdline').AsString := odCmdLine.FileName;
end;

procedure Tgdc_dlgAutoTask.btnClearTimeClick(Sender: TObject);
begin
  gdcObject.FieldByName('starttime').Clear;
  gdcObject.FieldByName('endtime').Clear;
end;

procedure Tgdc_dlgAutoTask.btBackupClick(Sender: TObject);
var
  Port: Integer;
  Server, FileName: String;
begin
  ParseDatabaseName(IBLogin.DatabaseName, Server, Port, FileName);
  gdcObject.FieldByName('backupfile').AsString := ChangeFileExt(FileName, '.bk');
end;

procedure Tgdc_dlgAutoTask.actExecTaskExecute(Sender: TObject);
var
  Task: TgdAutoTask;
begin
  Task := nil;
  try
    if pcTask.ActivePage = tsFunction then
    begin
      Task := TgdAutoFunctionTask.Create;
      (Task as TgdAutoFunctionTask).FunctionKey := iblkupFunction.CurrentKeyInt;
    end
    else if pcTask.ActivePage = tsCmd then
    begin
      Task := TgdAutoCmdTask.Create;
      (Task as TgdAutoCmdTask).CmdLine := dbeCmdLine.Text;
    end
    else if pcTask.ActivePage = tsBackup then
    begin
      Task := TgdAutoBackupTask.Create;
      (Task as TgdAutoBackupTask).BackupFile := dbeBackup.Text;
    end
    else if pcTask.ActivePage = tsReport then
    begin
      Task := TgdAutoReportTask.Create;
      (Task as TgdAutoReportTask).ReportKey := iblkupReport.CurrentKeyInt;
      (Task as TgdAutoReportTask).ExportType := dbcbExportType.Text;
      (Task as TgdAutoReportTask).Recipients := dbeRecipients.Text;
      (Task as TgdAutoReportTask).GroupKey := iblkupGroup.CurrentKeyInt;
      (Task as TgdAutoReportTask).SMTPKey := iblkupSMTP.CurrentKeyInt;
    end;

    if Task <> nil then
      Task.TaskExecuteForDlg;
  finally
    FreeAndNil(Task);
  end;
end;

procedure Tgdc_dlgAutoTask.actExecTaskUpdate(Sender: TObject);
begin
  actExecTask.Enabled :=
    ((pcTask.ActivePage = tsFunction) and (iblkupFunction.CurrentKeyInt > 0))
    or ((pcTask.ActivePage = tsCmd) and (Trim(dbeCmdLine.Text) > ''))
    or ((pcTask.ActivePage = tsBackup) and (Trim(dbeBackup.Text) > ''))
    or ((pcTask.ActivePage = tsReport) and (iblkupReport.CurrentKeyInt > 0)
      and (dbcbExportType.Text > '')
      and ((iblkupGroup.CurrentKeyInt > 0) or (dbeRecipients.Text > ''))
      and (gdWebClientControl <> nil)
      and (gdWebClientControl.EmailCount = 0));
end;

procedure Tgdc_dlgAutoTask.btnCNClick(Sender: TObject);
begin
  gdcObject.FieldByName('computer').AsString := GetLocalComputerName;
end;

procedure Tgdc_dlgAutoTask.btnIPClick(Sender: TObject);
begin
  gdcObject.FieldByName('computer').AsString :=
    GetIPAddress(GetLocalComputerName);
end;

procedure Tgdc_dlgAutoTask.DestroyWindowHandle;
begin
  gdWebClientControl.ClearEmailCallbackHandle(Handle, 0);
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTask, 'Автозадача');

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTask);
end.
