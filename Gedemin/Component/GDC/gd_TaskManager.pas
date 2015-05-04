unit gd_TaskManager;

interface

uses
  Windows, Classes, Controls, Contnrs, SysUtils;

type
  TTaskManagerThread = class(TThread)
  protected
    procedure Execute; override;
  end;


  TgdTaskLog = class(TObject)
  private
    FId: Integer;
    FAutotaskKey: Integer;
    FEventTime: TDateTime;
    FEventText: String;
    FCreatorKey: Integer;
    FCreationDate: TDateTime;
  protected

  public
    property Id: Integer read FId write FId;
    property AutotaskKey: Integer read FAutotaskKey write FAutotaskKey;
    property EventTime: TDateTime read FEventTime write FEventTime;
    property EventText: String read FEventText write FEventText;
    property CreatorKey: Integer read FCreatorKey write FCreatorKey;
    property CreationDate: TDateTime read FCreationDate write FCreationDate;
  end;

  TgdTask = class(TObject)
  private
    FId: Integer;
    FName: String;
    FDescription: String;
    FFunctionKey: Integer;
    FCmdLine: String;
    FBackupFile: String;
    FUserKey: Integer;
    FExactDate: TDateTime;
    FMonthly: Integer;
    FWeekly: Integer;
    FStartTime: TTime;
    FEndTime: TTime;
    FDisabled: Boolean;

    FTaskLogList: TObjectList;

  protected

  public
    constructor Create;
    destructor Destroy; override;


    property Id: Integer read FId write FId;
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
    property FunctionKey: Integer read FFunctionKey write FFunctionKey;
    property CmdLine: String read FCmdLine write FCmdLine;
    property BackupFile: String read FBackupFile write FBackupFile;
    property UserKey: Integer read FUserKey write FUserKey;
    property ExactDate: TDateTime read FExactDate write FExactDate;
    property Monthly: Integer read FMonthly write FMonthly;
    property Weekly: Integer read FWeekly write FWeekly;
    property StartTime: TTime read FStartTime write FStartTime;
    property EndTime: TTime read FEndTime write FEndTime;
    property Disabled: Boolean read FDisabled write FDisabled;
  end;

  TgdTaskManager = class(TObject)
  private
    FTaskList: TObjectList;
    FTaskTread: TTaskManagerThread;

    procedure LoadFromRelation;
  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
  end;

var
  _gdTaskManager: TgdTaskManager;

  function gdTaskManager: TgdTaskManager;

implementation

uses
  at_classes, gdcBaseInterface, IBSQL;

{ TaskManagerThread }

procedure TTaskManagerThread.Execute;
begin
  while True do
  begin
    if Self.Terminated then break;
    Sleep(10);
  end;
end;

{ TgdTask }

constructor TgdTask.Create;
begin
  inherited;

  FTaskLogList := TObjectList.Create(False);
end;

destructor TgdTask.Destroy;
var
  I: Integer;
begin
  for I := FTaskLogList.Count - 1 downto 0 do
    (FTaskLogList[I] as TgdTaskLog).Free;

  inherited;
end;


{ TgdTaskManager }

constructor TgdTaskManager.Create;
begin
  inherited;

  FTaskList := TObjectList.Create(False);

  FTaskTread := TTaskManagerThread.Create(True);
  FTaskTread.Priority := tpLowest;
end;

destructor TgdTaskManager.Destroy;
var
  I: Integer;
begin
  if FTaskTread <> nil then
  begin
    FTaskTread.Terminate;
    FTaskTread.Free;
  end;

  for I := FTaskList.Count - 1 downto 0 do
    (FTaskList[I] as TgdTask).Free;

  FTaskList.Free;

  inherited;
end;

procedure TgdTaskManager.Run;
begin
  //загрузка из базы
  LoadFromRelation;

  //При старте проверяется лог,
  //если были запущенные задачи, но они не завершились
  //(нет соответствующей записи в логе) или завершились с ошибкой,
  //то выдается соответствующее предупреждение на экран.
  //Естественно, перед выдачей предупреждения мы проверяем
  //не работает ли система в "тихом" режиме.

  //проверяем есть ли задачи для выполнения.
  //если есть то запускаем поток.


  FTaskTread.Resume;
end;

procedure TgdTaskManager.LoadFromRelation;

  procedure LoadLog(ATask: TgdTask);
  var
    q: TIBSQL;
    TaskLog: TgdTaskLog;
  begin
     q := TIBSQL.Create(nil);
     try
       q.Transaction := gdcBaseManager.ReadTransaction;
       q.SQL.Text := 'SELECT * FROM gd_autotask_log WHERE autotaskkey = :autotaskkey';
       q.ParamByName('autotaskkey').AsInteger := ATask.Id;
       q.ExecQuery;

       while not q.EOF do
       begin
         TaskLog := TgdTaskLog.Create;

         TaskLog.Id := q.FieldbyName('id').AsInteger;
         TaskLog.AutotaskKey := q.FieldbyName('autotaskkey').AsInteger;
         TaskLog.EventTime := q.FieldbyName('eventtime').AsDateTime;
         TaskLog.EventText := q.FieldbyName('eventtext').AsString;
         TaskLog.CreatorKey := q.FieldbyName('creatorkey').AsInteger;
         TaskLog.CreationDate := q.FieldbyName('creationdate').AsDateTime;

         ATask.FTaskLogList.Add(TaskLog);
       end;
     finally
       q.Free;
     end;
  end;

  procedure InitTask(AQ: TIBSQL);
  var
    Task: TgdTask;
  begin
    Task := TgdTask.Create;
    Task.Id := AQ.FieldbyName('id').AsInteger;
    Task.Name := AQ.FieldbyName('name').AsString;
    Task.Description := AQ.FieldbyName('description').AsString;
    Task.FunctionKey := AQ.FieldbyName('functionkey').AsInteger;
    Task.CmdLine := AQ.FieldbyName('cmdline').AsString;
    Task.BackupFile := AQ.FieldbyName('backupfile').AsString;
    Task.UserKey := AQ.FieldbyName('userkey').AsInteger;
    Task.ExactDate := AQ.FieldbyName('exactdate').AsDateTime;
    Task.Monthly := AQ.FieldbyName('monthly').AsInteger;
    Task.Weekly := AQ.FieldbyName('weekly').AsInteger;
    Task.StartTime := AQ.FieldbyName('starttime').AsTime;
    Task.EndTime := AQ.FieldbyName('endtime').AsTime;
    Task.Disabled := AQ.FieldbyName('disabled').AsInteger = 1;

    LoadLog(Task);

    FTaskList.Add(Task);
  end;

var
  q: TIBSQL;
begin
  Assert(atDatabase <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_autotask';
    q.ExecQuery;

    while not q.EOF do
    begin
      InitTask(q);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

function gdTaskManager: TgdTaskManager;
begin
  if _gdTaskManager = nil then
    _gdTaskManager := TgdTaskManager.Create;
  Result := _gdTaskManager;
end;

initialization
  _gdTaskManager := nil;

finalization
  FreeAndNil(_gdTaskManager);

end.
