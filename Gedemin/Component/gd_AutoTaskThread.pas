unit gd_AutoTaskThread;

interface

uses
  Windows, Classes, Controls, Contnrs, SysUtils, gdMessagedThread,
  gdNotifierThread_unit, gd_ProgressNotifier_unit;

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

    procedure AddLog(AnEventText: String);

  protected
    procedure TaskExecute; virtual;

  public
    procedure Execute;

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
    procedure TaskExecute; override;

  public
    property CmdLine: String read FCmdLine write FCmdLine;
  end;

  TgdAutoTaskThread = class(TgdMessagedThread)
  private
    FTaskList: TObjectList;
    FNotificationContext: Integer;

    procedure LoadFromRelation;
    procedure FindAndExecuteTask;

  protected
    procedure Timeout; override;
    function ProcessMessage(var Msg: TMsg): Boolean; override;

    procedure SendNotification(const AText: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure SetInitialDelay;
  end;

var
  gdAutoTaskThread: TgdAutoTaskThread;

implementation

uses
  at_classes, gdcBaseInterface, IBSQL, rp_BaseReport_unit, scr_i_FunctionList,
  gd_i_ScriptFactory, ShellApi, gdcAutoTask, gd_security;

const
  WM_GD_FIND_AND_EXECUTE_TASK = WM_GD_THREAD_USER + 1;

{ TgdAutoTask }

procedure TgdAutoTask.AddLog(AnEventText: String);
begin
  with TgdcAutoTaskLog.Create(nil) do
    try
      Open;
      Insert;
      FieldByName('autotaskkey').AsInteger := Self.ID;
      FieldByName('eventtime').AsDateTime := Now;
      FieldByName('eventtext').AsString := AnEventText;
      Post;
    finally
      Free;
    end;
end;

procedure TgdAutoTask.TaskExecute;
begin
  //
end;

procedure TgdAutoTask.Execute;
begin
  // проверим, может уже где-то выполняется
  // или выполнилось
  // или удалено, отключено и т.п.

  // пишем в лог о начале выполнения
  // выводим на экран

  TaskExecute;

  // пишем в лог о завершении выполнения
  // выводим на экран
end;

{ TgdAutoTaskThread }

constructor TgdAutoTaskThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  Priority := tpLowest;
  FNotificationContext := gdNotifierThread.GetNextContext;
end;

destructor TgdAutoTaskThread.Destroy;
begin
  FTaskList.Free;
  inherited;
end;

procedure TgdAutoTaskThread.LoadFromRelation;

  {procedure InitTask(AQ: TIBSQL);
  var
    Task: TgdAutoTask;
  begin
    Task := TgdAutoTask.Create;
    Task.Id := AQ.FieldbyName('id').AsInteger;
    Task.Name := AQ.FieldbyName('name').AsString;
    Task.Description := AQ.FieldbyName('description').AsString;
    Task.FunctionKey := AQ.FieldbyName('functionkey').AsInteger;
    Task.AutoTrKey := AQ.FieldbyName('autotrkey').AsInteger;
    Task.ReportKey := AQ.FieldbyName('reportkey').AsInteger;
    Task.CmdLine := AQ.FieldbyName('cmdline').AsString;
    Task.BackupFile := AQ.FieldbyName('backupfile').AsString;
    Task.UserKey := AQ.FieldbyName('userkey').AsInteger;
    Task.ExactDate := AQ.FieldbyName('exactdate').AsDateTime;
    Task.Monthly := AQ.FieldbyName('monthly').AsInteger;
    Task.Weekly := AQ.FieldbyName('weekly').AsInteger;
    Task.Daily := AQ.FieldbyName('daily').AsInteger = 1;
    Task.StartTime := AQ.FieldbyName('starttime').AsTime;
    Task.EndTime := AQ.FieldbyName('endtime').AsTime;
    Task.Priority := AQ.FieldbyName('priority').AsInteger;
    Task.Disabled := AQ.FieldbyName('disabled').AsInteger = 1;
    FTaskList.Add(Task);
  end;}

var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  SendNotification('Считываем список автозадач...');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_autotask';
    q.ExecQuery;

    while not q.EOF do
    begin
      //InitTask(q);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

procedure TgdAutoTaskThread.Timeout;
begin
  if FTaskList = nil then
  begin
    Synchronize(LoadFromRelation);
    PostMsg(WM_GD_FIND_AND_EXECUTE_TASK);
  end else
    Synchronize(FindAndExecuteTask);
end;

function TgdAutoTaskThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  case Msg.Message of
    WM_GD_FIND_AND_EXECUTE_TASK:
    begin
      Synchronize(FindAndExecuteTask);
      Result := True;
    end;
  else
    Result := False;
  end;
end;

procedure TgdAutoTaskThread.SendNotification(const AText: String);
begin
  // проверить не работает ли программа в тихом режиме
  // и только тогда отсылать

  gdNotifierThread.Add(AText, FNotificationContext, 2000);
end;

procedure TgdAutoTaskThread.SetInitialDelay;
begin
  Resume;
  SetTimeOut(5 * 60 * 1000);
end;

procedure TgdAutoTaskThread.FindAndExecuteTask;
begin

end;

{ TgdAutoFunctionTask }

procedure TgdAutoFunctionTask.TaskExecute;
var
  F: TrpCustomFunction;
  P: Variant;
begin
  F := glbFunctionList.FindFunction(Self.FFunctionKey);
  if Assigned(F) then
  try
    try
      P := VarArrayOf([]);
      if ScriptFactory.InputParams(F, P) then
        ScriptFactory.ExecuteFunction(F, P);
    except
      on E: Exception do
      begin
        AddLog(E.Message);
        raise;
      end;
    end;
  finally
    glbFunctionList.ReleaseFunction(F);
  end;
end;

{ TgdAutoCmdTask }

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
  ExecInfo.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;

  if not ShellExecuteEx(@ExecInfo) then
    AddLog(PChar(SysErrorMessage(GetLastError)));
end;

initialization
  gdAutoTaskThread := nil;
end.
