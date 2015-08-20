unit gd_AutoTaskThread;

interface

uses
  Windows, Classes, Controls, Contnrs, SysUtils, gdMessagedThread,
  gd_WebClientControl_unit, Messages, idThreadSafe;

type
  TgdAutoTask = class(TObject)
  private
    FId: Integer;
    FName: String;
    FDescription: String;
    FExactDate: TDateTime;
    FMonthly: Integer;
    FWeekly: Integer;
    FDaily: Boolean;
    FStartTime: TTime;
    FEndTime: TTime;
    FPriority: Integer;
    FAtStartup: Boolean;
    FErrorMsg: String;
    FPulse: Integer;
    FLastExecuted: TDateTime;
    FDone: Boolean;

    FNextStartTime, FNextEndTime: TDateTime;

    procedure Log(const AMsg: String);
    procedure LogStartTask;
    procedure LogEndTask;
    procedure LogErrorMsg;

  protected
    function IsAsync: Boolean; virtual;
    procedure TaskExecute; virtual;
    function Compare(ATask: TgdAutoTask): Integer;
    procedure Setup; virtual;

  public
    procedure Execute;
    procedure TaskExecuteForDlg; virtual;
    procedure Schedule;

    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
    property ExactDate: TDateTime read FExactDate write FExactDate;
    property Monthly: Integer read FMonthly write FMonthly;
    property Weekly: Integer read FWeekly write FWeekly;
    property Daily: Boolean read FDaily write FDaily;
    property StartTime: TTime read FStartTime write FStartTime;
    property EndTime: TTime read FEndTime write FEndTime;
    property Priority: Integer read FPriority write FPriority;
    property Pulse: Integer read FPulse write FPulse;
    property NextStartTime: TDateTime read FNextStartTime write FNextStartTime;
    property NextEndTime: TDateTime read FNextEndTime write FNextEndTime;
    property AtStartup: Boolean read FAtStartup write FAtStartup;
    property Done: Boolean read FDone write FDone;
    property LastExecuted: TDateTime read FLastExecuted write FLastExecuted;
  end;

  TgdAutoFunctionTask = class(TgdAutoTask)
  private
    FFunctionKey: Integer;

  protected
    procedure TaskExecute; override;

  public
    property FunctionKey: Integer read FFunctionKey write FFunctionKey;
  end;

  TgdAutoCmdTask = class(TgdAutoTask)
  private
    FCmdLine: String;

  protected
    function IsAsync: Boolean; override;
    procedure TaskExecute; override;

  public
    property CmdLine: String read FCmdLine write FCmdLine;
  end;

  TgdAutoBackupTask = class(TgdAutoTask)
  private
    FBackupFile: String;
    FPassw: String;
    FPort: Integer;
    FServer, FFileName: String;

    procedure SetupBackupTask;

  protected
    function IsAsync: Boolean; override;
    procedure TaskExecute; override;
    procedure Setup; override;

  public
    procedure TaskExecuteForDlg; override;

    property BackupFile: String read FBackupFile write FBackupFile;
  end;

  TgdAutoReportTask = class(TgdAutoTask)
  private
    FReportKey: Integer;
    FExportType: String;
    FRecipients: String;
    FGroupKey: Integer;
    FSMTPKey: Integer;

  protected
    procedure TaskExecute; override;

  public
    property ReportKey: Integer read FReportKey write FReportKey;
    property ExportType: String read FExportType write FExportType;
    property Recipients: String read FRecipients write FRecipients;
    property GroupKey: Integer read FGroupKey write FGroupKey;
    property SMTPKey: Integer read FSMTPKey write FSMTPKey;
  end;

  TgdAutoTaskThread = class(TgdMessagedThread)
  private
    FTaskList: TObjectList;
    FNotificationContext: Integer;
    FSkipAtStartup: Boolean;
    FForbid: TidThreadSafeInteger;

    procedure LoadFromRelation;
    procedure FindAndExecuteTask;
    procedure UpdateTaskList;
    procedure RemoveExecuteOnceTask;

  protected
    procedure Timeout; override;
    function ProcessMessage(var Msg: TMsg): Boolean; override;

    procedure SendNotification(const AText: String;
      const AClearNotifications: Boolean = False;
      const AShowTime: DWORD = 2000);

  public
    constructor Create;
    destructor Destroy; override;

    procedure SetInitialDelay;
    procedure ReLoadTaskList;
    procedure Forbid;
  end;

var
  gdAutoTaskThread: TgdAutoTaskThread;

implementation

uses
  Forms, at_classes, gdcBaseInterface, IBDatabase, IBSQL, rp_BaseReport_unit,
  scr_i_FunctionList, gd_i_ScriptFactory, ShellApi, gdcAutoTask, gd_security,
  gdNotifierThread_unit, gd_ProgressNotifier_unit, IBServices,
  gd_common_functions, gd_directories_const, gd_messages_const, jclSysInfo;

{ TgdAutoTask }

procedure TgdAutoTask.TaskExecute;
begin
  //
end;

procedure TgdAutoTask.Execute;
begin
  Assert(gdAutoTaskThread <> nil);

  gdAutoTaskThread.Synchronize(LogStartTask);

  FErrorMsg := '';

  gdAutoTaskThread.SendNotification('����������� ���������� ' + Name + '...', True, INFINITE);

  Setup;

  if IsAsync then
    TaskExecute
  else
    gdAutoTaskThread.Synchronize(TaskExecute);

  FLastExecuted := Now;  

  if FErrorMsg > '' then
  begin
    gdAutoTaskThread.SendNotification('������ ��� ���������� ����������: ' + FErrorMsg, True);
    gdAutoTaskThread.Synchronize(LogErrorMsg);
  end else 
  begin
    gdAutoTaskThread.SendNotification('���������� "' + Name + '" ���������.', True);
    gdAutoTaskThread.Synchronize(LogEndTask);
  end;
end;

procedure TgdAutoTask.TaskExecuteForDlg;
begin
  FErrorMsg := '';
  TaskExecute;
  if FErrorMsg > '' then
    MessageBox(0, PChar(FErrorMsg), '������ ��� ���������� ������',
      MB_OK or MB_TASKMODAL or MB_ICONHAND);
end;

procedure TgdAutoTask.Schedule;
var
  Y, M, D, K: Word;
  NextPulse: TDateTime;
begin
  // �� ��������� ���������� ������ � ������
  // � ���������� ��������������� �������
  // (���� ������������ ����)
  // ������������ ��������� ��������� ����
  // ������� ������
  //
  // ��������:
  // ��� ������ ����� ��������� ���������
  // � 13 �� 14. ������ �� ���������� �� ��
  // ���� NextTime �����, ������ ����������� ������������
  // ��� �� ����. ��� ������ ������ ������� ��������
  // ��� ������� � ������� � ����. ���������,
  // ���� �������� ��� � ������� (�� ����� 15:00),
  // �� �������� �������� ����� ��� ������� ����������
  // ���������. ��. ����� ����� �� ����������!
  //
  // ���� �������� ��� ��������, �� ���������
  // ����� ������ ������� ��������� �������� �
  // ������� � ����.

  if (FPulse > 0) and (FLastExecuted > 0) and (FNextEndTime > 0) then
  begin
    NextPulse := FLastExecuted + FPulse / SecsPerDay;
    if NextPulse < FNextEndTime then
    begin
      FNextStartTime := NextPulse;
      exit;
    end;
  end;

  if FAtStartup then
  begin
    if FLastExecuted > 0 then
      FDone := True
    else begin
      FNextStartTime := Date + FStartTime;
      if FEndTime > 0 then
        FNextEndTime := Date + FEndTime
      else
        FNextEndTime := Date + 1976;
    end;
  end
  else if FExactDate > 0 then
  begin
    if FLastExecuted > 0 then
      FDone := True
    else begin
      FNextStartTime := FExactDate + FStartTime;
      FNextEndTime := FExactDate + FEndTime;
    end;
  end
  else if FDaily then
  begin
    if FNextStartTime > 0 then
    begin
      FNextStartTime := Int(FNextStartTime + 1) + FStartTime;
      FNextEndTime := Int(FNextEndTime + 1) + FEndTime;
    end else
    begin
      FNextStartTime := Date + FStartTime;
      FNextEndTime := Date + FEndTime;
    end;
  end
  else if FWeekly > 0 then
  begin
    if FNextStartTime > 0 then
    begin
      FNextStartTime := Int(FNextStartTime + 7) + FStartTime;
      FNextEndTime := Int(FNextEndTime + 7) + FEndTime;
    end else
    begin
      FNextStartTime := Date - DayOfWeek(Date) + 1 + FWeekly + FStartTime;
      FNextEndTime := FNextStartTime - FStartTime + FEndTime;
    end;
  end
  else if FMonthly > 0 then
  begin
    if FNextStartTime > 0 then
      FNextStartTime := Int(IncMonth(FNextStartTime, 1)) + FStartTime
    else begin
      DecodeDate(Date, Y, M, D);
      if (M in [4, 6, 9, 11]) and (FMonthly = 31) then
        K := 30
      else if (M = 2) and IsLeapYear(Y) and (FMonthly > 29) then
        K := 29
      else if (M = 2) and (not IsLeapYear(Y)) and (FMonthly > 28) then
        K := 28
      else
        K := FMonthly;
      FNextStartTime := EncodeDate(Y, M, K) + FStartTime;
    end;
    FNextEndTime := FNextStartTime - FStartTime + FEndTime
  end
  else if FMonthly < 0 then
  begin
    if FNextStartTime > 0 then
      FNextStartTime := Int(IncMonth(FNextStartTime, 1)) + FStartTime
    else begin
      DecodeDate(Date, Y, M, D);
      FNextStartTime := IncMonth(EncodeDate(Y, M, 1), 1) + FMonthly + FStartTime;
    end;
    FNextEndTime := FNextStartTime - FStartTime + FEndTime
  end;
end;

function TgdAutoTask.IsAsync: Boolean;
begin
  Result := False;
end;

function TgdAutoTask.Compare(ATask: TgdAutoTask): Integer;
begin
  if AtStartup and (not ATask.AtStartup) then
    Result := -1
  else if (not AtStartup) and ATask.AtStartup then
    Result := +1
  else if AtStartup and ATask.AtStartup then
    Result := 0
  else if FNextStartTime < ATask.FNextStartTime then
    Result := -1
  else if FNextStartTime > ATask.FNextStartTime then
    Result := +1
  else
    Result := 0;

  if Result = 0 then
  begin
    if FPriority < ATask.FPriority then
      Result := -1
    else if FPriority > ATask.FPriority then
      Result := +1
  end;
end;

procedure TgdAutoTask.LogEndTask;
begin
  Log('Done');
end;

procedure TgdAutoTask.LogStartTask;
begin
  Log('Started');
end;

procedure TgdAutoTask.LogErrorMsg;
begin
  Log(FErrorMsg);
end;

procedure TgdAutoTask.Log(const AMsg: String);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);
  Assert(IBLogin <> nil);

  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text :=
      'INSERT INTO gd_autotask_log (autotaskkey, eventtext, creationdate, creatorkey) ' +
      'VALUES (:atk, :etext, :cd, :ck)';
    q.ParamByName('atk').AsInteger := ID;
    q.ParamByName('etext').AsString := AMsg;
    q.ParamByName('cd').AsDateTime := Now;
    q.ParamByName('ck').AsInteger := IBLogin.ContactKey;
    q.ExecQuery;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgdAutoTask.Setup;
begin
  //
end;

{ TgdAutoReportTask }

procedure TgdAutoReportTask.TaskExecute;
var
  R: OleVariant;
  ToAddresses, Subj: String;
begin
  try
    if gdcBaseManager.ExecSingleQueryResult(
      'SELECT LIST(email, '','') ' +
      'FROM gd_contact c JOIN gd_contactlist l ' +
      '  ON l.contactkey = c.id ' +
      'WHERE ' +
      '  l.groupkey = :gk ' +
      '  AND c.email > '''' ',
      GroupKey,
      R) and (not VarIsNull(R[0, 0])) then
    begin
      if Trim(Recipients) > '' then
        ToAddresses := Recipients + ',' + R[0, 0]
      else
        ToAddresses := R[0, 0];
    end else
      ToAddresses := Recipients;

    if gdcBaseManager.ExecSingleQueryResult(
      'SELECT name FROM rp_reportlist WHERE id = :id', ReportKey, R) then
    begin
      Subj := R[0, 0];
    end else
      Subj := '�����';

    if gdWebClientControl <> nil then
      gdWebClientControl.SendEmail(SMTPKey, ToAddresses, Subj, '', ReportKey, ExportType, True);
  except
    on E: Exception do
      FErrorMsg := E.Message;
  end;
end;

{ TgdAutoTaskThread }

constructor TgdAutoTaskThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FForbid := TidThreadSafeInteger.Create;
end;

destructor TgdAutoTaskThread.Destroy;
begin
  inherited;
  FTaskList.Free;
  FForbid.Free;
end;

procedure TgdAutoTaskThread.LoadFromRelation;
var
  q: TIBSQL;
  Task: TgdAutoTask;
begin
  Assert(gdcBaseManager <> nil);
  Assert(IBLogin <> nil);

  if FTaskList <> nil then
    FTaskList.Clear;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT * FROM gd_autotask ' +
      'WHERE disabled = 0 ' +
      '  AND (userkey IS NULL OR userkey = :uk)' +
      '  AND (COALESCE(computer, '''') = '''' ' +
      '    OR UPPER(computer) = :comp OR computer = :ip)';
    q.ParamByName('uk').AsInteger := IBLogin.UserKey;
    q.ParamByName('comp').AsString := AnsiUpperCase(GetLocalComputerName);
    q.ParamByName('ip').AsString := GetIPAddress(GetLocalComputerName);
    q.ExecQuery;

    while not q.EOF do
    begin
      if FSkipAtStartup and (q.FieldByName('atstartup').AsInteger <> 0) then
      begin
        q.Next;
        continue;
      end;

      if q.FieldByName('functionkey').AsInteger > 0 then
      begin
        Task := TgdAutoFunctionTask.Create;
        (Task as TgdAutoFunctionTask).FunctionKey := q.FieldbyName('functionkey').AsInteger;
      end else
      if q.FieldByName('cmdline').AsString > '' then
      begin
        Task := TgdAutoCmdTask.Create;
        (Task as TgdAutoCmdTask).CmdLine := q.FieldbyName('cmdline').AsString;
      end else
      if q.FieldByName('backupfile').AsString > '' then
      begin
        Task := TgdAutoBackupTask.Create;
        (Task as TgdAutoBackupTask).BackupFile := q.FieldbyName('backupfile').AsString;
      end else
      if q.FieldByName('reportkey').AsInteger > 0 then
      begin
        Task := TgdAutoReportTask.Create;
        (Task as TgdAutoReportTask).ReportKey := q.FieldbyName('reportkey').AsInteger;
        (Task as TgdAutoReportTask).ExportType := q.FieldbyName('emailexporttype').AsString;
        (Task as TgdAutoReportTask).Recipients := q.FieldbyName('emailrecipients').AsString;
        (Task as TgdAutoReportTask).GroupKey := q.FieldbyName('emailgroupkey').AsInteger;
        (Task as TgdAutoReportTask).SMTPKey := q.FieldbyName('emailsmtpkey').AsInteger;
      end else
        Task := nil;

      if Task <> nil then
      begin
        Task.Id := q.FieldbyName('id').AsInteger;
        Task.Name := q.FieldbyName('name').AsString;
        Task.Description := q.FieldbyName('description').AsString;
        Task.ExactDate := q.FieldbyName('exactdate').AsDateTime;
        Task.Monthly := q.FieldbyName('monthly').AsInteger;
        Task.Weekly := q.FieldbyName('weekly').AsInteger;
        Task.Daily := q.FieldbyName('daily').AsInteger <> 0;
        if q.FieldbyName('starttime').IsNull then
          Task.StartTime := 0
        else
          Task.StartTime := q.FieldbyName('starttime').AsTime;
        if q.FieldbyName('endtime').IsNull or (q.FieldbyName('endtime').AsTime = 0) then
          Task.EndTime := 1
        else
          Task.EndTime := q.FieldbyName('endtime').AsTime;
        Task.AtStartup := q.FieldbyName('atstartup').AsInteger <> 0;
        Task.Priority := q.FieldbyName('priority').AsInteger;
        Task.Pulse := q.FieldbyName('pulse').AsInteger;
        Task.Schedule;

        if FTaskList = nil then
          FTaskList := TObjectList.Create(True);
        FTaskList.Add(Task);
      end;

      q.Next;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdAutoTaskThread.Timeout;
begin
  if FForbid.Value = 0 then
  begin
    if FTaskList = nil then
      PostMsg(WM_GD_LOAD_TASK_LIST)
    else
      PostMsg(WM_GD_FIND_AND_EXECUTE_TASK);
  end else
  begin
    FreeAndNil(FTaskList);
    SetTimeOut(INFINITE);
  end;
end;

function TgdAutoTaskThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := True;

  case Msg.Message of
    WM_GD_LOAD_TASK_LIST:
    begin
      if FForbid.Value = 0 then
      begin
        SendNotification('�������� ������ ���������...', True);
        Synchronize(LoadFromRelation);

        if (FTaskList = nil) or (FTaskList.Count = 0) then
        begin
          SendNotification('��� ��������� ��� ����������.', True);
          SetTimeOut(INFINITE);
        end else
          PostMsg(WM_GD_FIND_AND_EXECUTE_TASK);
      end else
        SetTimeOut(INFINITE);
    end;

    WM_GD_FIND_AND_EXECUTE_TASK:
    begin
      if FForbid.Value = 0 then
      begin
        FindAndExecuteTask;

        if (FTaskList = nil) or (FTaskList.Count = 0) then
        begin
          SendNotification('��� ���������� ���������.');
          SetTimeOut(INFINITE);
        end;
      end else
        SetTimeOut(INFINITE);
    end;

    WM_GD_RELOAD_TASK_LIST:
    begin
      FSkipAtStartup := True;
      PostMsg(WM_GD_LOAD_TASK_LIST);
    end;
  else
    Result := False;
  end;
end;

procedure TgdAutoTaskThread.SendNotification(const AText: String;
  const AClearNotifications: Boolean = False;
  const AShowTime: DWORD = 2000);
begin
  if gdNotifierThread <> nil then
  begin
    if FNotificationContext = 0 then
      FNotificationContext := gdNotifierThread.GetNextContext
    else if AClearNotifications then
    begin
      gdNotifierThread.DeleteContext(FNotificationContext);
      FNotificationContext := gdNotifierThread.GetNextContext;
    end;
    gdNotifierThread.Add(AText, FNotificationContext, AShowTime);
  end;
end;

procedure TgdAutoTaskThread.SetInitialDelay;
begin
  // �� ����� ������������� ����� ����� ������� ���������� ���������
  // ������� �������, ����� ����������, ����������� �� ����� �������
  // ����������� ������ ��� �� ������

  Resume;
  SetTimeOut(4 * 1000);
  SendNotification('������ ��������� ����� 4 �������.');
end;

procedure TgdAutoTaskThread.FindAndExecuteTask;
var
  AT: TgdAutoTask;
begin
  Synchronize(UpdateTaskList);

  if (FTaskList = nil) or (FTaskList.Count = 0) then
    exit;

  AT := FTaskList[0] as TgdAutoTask;

  if AT.NextStartTime <= Now then
  begin
    if AT.NextEndTime >= Now then
      AT.Execute;

    AT.Schedule;

    if AT.Done then
    begin
      if AT.ExactDate > 0 then
        Synchronize(RemoveExecuteOnceTask);
      FTaskList.Delete(0);
    end;

    if FTaskList.Count > 0 then
      PostMsg(WM_GD_FIND_AND_EXECUTE_TASK);
  end else
  begin
    SetTimeOut(Round((AT.NextStartTime - Now) * MSecsPerDay));
    SendNotification('���������� ���������� "' + AT.Name + '" ��������� �� ' +
      FormatDateTime('hh:nn dd.mm.yyyy', AT.NextStartTime));
  end;
end;

procedure TgdAutoTaskThread.UpdateTaskList;

  procedure SortTaskList;
  var
    I, J: Integer;
  begin
    for I := 0 to FTaskList.Count - 2 do
      for J := I + 1 to FTaskList.Count - 1 do
        if (FTaskList[J] as TgdAutoTask).Compare(FTaskList[I] as TgdAutoTask) < 0 then
          FTaskList.Exchange(J, I);
  end;

var
  q: TIBSQL;
  C: Integer;
begin
  Assert(gdcBaseManager <> nil);
  Assert(IBLogin <> nil);

  if (FTaskList = nil) or (FTaskList.Count = 0) then
    exit;

  SortTaskList;
  C := 0;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT t.disabled, t.userkey, t.computer, t.pulse, l.creationdate ' +
      'FROM gd_autotask t LEFT JOIN gd_autotask_log l ' +
      '  ON t.id = l.autotaskkey AND l.creationdate >= :et ' +
      '    AND l.connection_id <> CURRENT_CONNECTION ' +
      '    AND (l.client_address IS NULL ' +
      '      OR l.client_address IS NOT DISTINCT FROM RDB$GET_CONTEXT(''SYSTEM'', ''CLIENT_ADDRESS'')) ' +
      'WHERE t.id = :id';

    while C < FTaskList.Count do
    begin
      q.Close;
      q.ParamByName('id').AsInteger := (FTaskList[0] as TgdAutoTask).ID;
      q.ParamByName('et').AsDateTime := (FTaskList[0] as TgdAutoTask).NextStartTime;
      q.ExecQuery;

      if q.EOF
        or (q.FieldbyName('disabled').AsInteger <> 0)
        or
          (
            (q.FieldByName('userkey').AsInteger <> 0)
            and
            (q.FieldbyName('userkey').AsInteger <> IBLogin.UserKey)
          )
        or
          (
            (q.FieldByName('computer').AsString > '')
            and
            (not AnsiSameText(q.FieldByName('computer').AsString, GetLocalComputerName))
            and
            (not AnsiSameText(q.FieldByName('computer').AsString, GetIPAddress(GetLocalComputerName)))
          )  then
      begin
        FTaskList.Delete(0);
        continue;
      end;

      if q.FieldByName('creationdate').IsNull then
        break;

      if (FTaskList[0] as TgdAutoTask).ExactDate > 0 then
        FTaskList.Delete(0)
      else begin
        if (q.FieldByName('pulse').AsInteger = 0)
          or ((FTaskList[0] as TgdAutoTask).NextEndTime <= Now) then
        begin
          (FTaskList[0] as TgdAutoTask).Schedule;
          SortTaskList;
        end;
        Inc(C);
      end;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdAutoTaskThread.RemoveExecuteOnceTask;
begin
  Assert(gdcBaseManager <> nil);

  if (FTaskList <> nil) and (FTaskList.Count > 0)
    and ((FTaskList[0] as TgdAutoTask).ExactDate > 0) then
  try
    gdcBaseManager.ExecSingleQuery(
      'UPDATE gd_autotask SET disabled = 1 WHERE id = ' +
        IntToStr((FTaskList[0] as TgdAutoTask).ID));
  except
    // small chance that there would be a deadlock
    // but we don't care
  end;
end;

procedure TgdAutoTaskThread.ReLoadTaskList;
begin
  PostMsg(WM_GD_RELOAD_TASK_LIST);
end;

procedure TgdAutoTaskThread.Forbid;
begin
  Assert(FForbid.Value = 0);
  FForbid.Value := 1;
end;

{ TgdAutoFunctionTask }

procedure TgdAutoFunctionTask.TaskExecute;
var
  F: TrpCustomFunction;
  P: Variant;
  Cr: TCursor;
begin
  F := glbFunctionList.FindFunction(Self.FFunctionKey);
  if Assigned(F) then
  try
    try
      P := VarArrayOf([]);
      if ScriptFactory.InputParams(F, P) then
      begin
        Cr := Screen.Cursor;
        try
          Screen.Cursor := crHourGlass;
          ScriptFactory.ExecuteFunction(F, P);
        finally
          Screen.Cursor := Cr;
        end;
      end;
    except
      on E: Exception do
        FErrorMsg := E.Message;
    end;
  finally
    glbFunctionList.ReleaseFunction(F);
  end;
end;

{ TgdAutoCmdTask }

function TgdAutoCmdTask.IsAsync: Boolean;
begin
  Result := True;
end;

procedure TgdAutoCmdTask.TaskExecute;
var
  ExecInfo: TShellExecuteInfo;
begin
  FillChar(ExecInfo, SizeOf(ExecInfo), 0);
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(FCmdLine);
  ExecInfo.lpParameters := nil;
  ExecInfo.lpDirectory := nil;
  ExecInfo.nShow := SW_SHOWNORMAL;
  ExecInfo.fMask := SEE_MASK_FLAG_NO_UI;

  if not ShellExecuteEx(@ExecInfo) then
    FErrorMsg := SysErrorMessage(GetLastError);
end;

{ TgdAutoBackupTask }

function TgdAutoBackupTask.IsAsync: Boolean;
begin
  Result := True;
end;

procedure TgdAutoBackupTask.Setup;
begin
  gdAutoTaskThread.Synchronize(SetupBackupTask);
end;

procedure TgdAutoBackupTask.SetupBackupTask;
var
  Res: OleVariant;
begin
  Assert(IBLogin <> nil);

  if gdcBaseManager.ExecSingleQueryResult(
    'SELECT ibpassword FROM gd_user WHERE ibname=''' + SysDBAUserName + ''' ',
    Unassigned, Res) then
  begin
    FPassw := Res[0, 0];
  end;

  ParseDatabaseName(IBLogin.DatabaseName, FServer, FPort, FFileName);
end;

procedure TgdAutoBackupTask.TaskExecute;
var
  IBService: TIBBackupService;
begin
  Assert(gdAutoTaskThread <> nil);

  try
    IBService := TIBBackupService.Create(nil);
    try
      if FServer > '' then
      begin
        IBService.ServerName := FServer;
        IBService.Protocol := TCP;
      end else
        IBService.Protocol := Local;

      IBService.LoginPrompt := False;
      IBService.Params.Clear;
      IBService.Params.Add('user_name=' + SysDBAUserName);
      IBService.Params.Add('password=' + FPassw);
      IBService.Active := True;
      if not IBService.Active then
      begin
        FErrorMsg := '���������� ��������� ������ ������������� ���� ������.';
        exit;
      end;

      IBService.Verbose := False;
      IBService.Options := [];
      IBService.DatabaseName := FFileName;

      FBackupFile := ExpandMetaVariables(FBackupFile);

      IBService.BackupFile.Add(FBackupFile);

      IBService.ServiceStart;
      while (not IBService.Eof) and IBService.IsServiceRunning do
        gdAutoTaskThread.SendNotification(IBService.GetNextLine);
    finally
      IBService.Free;
    end;
  except
    on E: Exception do
      FErrorMsg := E.Message;
  end;
end;

procedure TgdAutoBackupTask.TaskExecuteForDlg;
begin
  SetupBackupTask;
  inherited;
end;

initialization
  gdAutoTaskThread := nil;
end.
