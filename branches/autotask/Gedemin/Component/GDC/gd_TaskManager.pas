unit gd_TaskManager;

interface

uses
  Windows, Classes, Controls, Contnrs, SysUtils;

type
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

    function GetRightTime: Boolean;
    function GetRightUser: Boolean;

    function GetTaskLog(Index: Integer): TgdTaskLog;
    function GetCount: Integer;

  protected
    procedure ExecuteFunction;
    procedure ExecuteCmdLine;
    procedure ExecuteBackupFile;
    procedure CheckMissedTasks(AStartDate: TDateTime; AEndDate: TDateTime);

    procedure AddLog(AnAutoTaskKey: Integer; AnEventText: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure TaskExecute;

    property RightTime: Boolean read GetRightTime;
    property RightUser: Boolean read GetRightUser;

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

    property Count: Integer read GetCount;
    property TaskLogList[Index: Integer]: TgdTaskLog read GetTaskLog; default;
  end;

  TTaskManagerThread = class(TThread)
  private
    FTask: TgdTask;
  protected
    procedure Execute; override;
  end;

  TgdTaskManager = class(TObject)
  private
    FTaskList: TObjectList;
    FTaskTread: TTaskManagerThread;

    function GetTask(Index: Integer): TgdTask;
    function GetCount: Integer;

    procedure LoadFromRelation;
    
  protected

  public
    constructor Create;
    destructor Destroy; override;

    function FindPriorityTask: TgdTask;

    procedure Run;

    property Count: Integer read GetCount;
    property TaskList[Index: Integer]: TgdTask read GetTask; default;
  end;

var
  _gdTaskManager: TgdTaskManager;

  function gdTaskManager: TgdTaskManager;

implementation

uses
  at_classes, gdcBaseInterface, IBSQL, rp_BaseReport_unit, scr_i_FunctionList,
  gd_i_ScriptFactory, ShellApi, gdcAutoTask, gd_security;

{ TaskManagerThread }

procedure TTaskManagerThread.Execute;
begin
  while True do
  begin
    if Self.Terminated then
      break;

    Sleep(100);

    if FTask = nil then
    begin
      FTask := gdTaskManager.FindPriorityTask;
      if FTask = nil then
        break;
    end
    else if FTask.RightTime then
    begin
      try
        FTask.TaskExecute;
      finally
        FTask := nil;
      end;
    end;
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

function TgdTask.GetRightTime: Boolean;
begin
  if FExactDate <> 0 then
    Result := Now > FExactDate
  else
    Result := (FStartTime < Time) and (Time < FEndTime);
end;

function TgdTask.GetRightUser: Boolean;
begin
  Result := (FUserKey = 0) or (IBLogin.UserKey = FUserKey);
end;

function TgdTask.GetTaskLog(Index: Integer): TgdTaskLog;
begin
  Result := Self.FTaskLogList[Index] as TgdTaskLog;
end;

function TgdTask.GetCount: Integer;
begin
  if FTaskLogList <> nil then
    Result := FTaskLogList.Count
  else
    Result := 0;
end;

procedure TgdTask.CheckMissedTasks(AStartDate: TDateTime; AEndDate: TDateTime);
begin
  // возможно во время выполнения текущей задачи
  // было пропущено выполнение других задач
  // надо записать соответствующий лог

 //1) задача "такая-то" будет выполнена по завершении активных задач
 //2) задача "такая-то" не может быть выполнена так как истек установленный интервал для выполения
  //'Missed'
end;

procedure TgdTask.AddLog(AnAutoTaskKey: Integer; AnEventText: String);
var
  TL: TgdTaskLog;
  NTD: TDateTime;
  gdcAutoTaskLog: TgdcAutoTaskLog;
begin
  NTD := Now;

  TL := TgdTaskLog.Create;
  TL.AutotaskKey := AnAutoTaskKey;
  TL.EventText := AnEventText;
  TL.EventTime := NTD;

  Self.FTaskLogList.Add(TL);

  // дописать добавление лога в базу

  gdcAutoTaskLog := TgdcAutoTaskLog.Create(nil);
  try
    gdcAutoTaskLog.Open;
    gdcAutoTaskLog.Insert;
    gdcAutoTaskLog.FieldByName('autotaskkey').AsInteger := AnAutoTaskKey;
    gdcAutoTaskLog.FieldByName('eventtime').AsDateTime := NTD;
    gdcAutoTaskLog.FieldByName('eventtext').AsString := AnEventText;
    gdcAutoTaskLog.Post;
  finally
    gdcAutoTaskLog.Free;
  end;
end;

procedure TgdTask.TaskExecute;
var
  SDate: TDateTime;
  EDate: TDateTime;
begin
  SDate := Now;

  if FunctionKey > 0 then
    ExecuteFunction
  else if CmdLine > '' then
    ExecuteCmdLine
  else if BackupFile > '' then
    ExecuteBackupFile;

  EDate := Now;
  CheckMissedTasks(SDate, EDate);
end;

procedure TgdTask.ExecuteFunction;
var
  F: TrpCustomFunction;
  P: Variant;
begin
  AddLog(ID, 'Started');

  F := glbFunctionList.FindFunction(Self.FFunctionKey);
  if Assigned(F) then
  try
    try
      P := VarArrayOf([]);
      if ScriptFactory.InputParams(F, P) then
        ScriptFactory.ExecuteFunction(F, P);
      AddLog(ID, 'Done');
    except
      on E: Exception do
      begin
        AddLog(ID, E.Message);
      end;
    end;
  finally
    glbFunctionList.ReleaseFunction(F);
  end;
end;

procedure TgdTask.ExecuteCmdLine;
var
  ExecInfo: TShellExecuteInfo;
begin
  AddLog(ID, 'Started');

  FillChar(ExecInfo, SizeOf(ExecInfo), 0);
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(Self.CmdLine);
  ExecInfo.lpParameters := nil;
  ExecInfo.lpDirectory := nil;
  ExecInfo.nShow := SW_SHOWNORMAL;
  ExecInfo.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;

  if ShellExecuteEx(@ExecInfo) then
    AddLog(ID, 'Done')
  else
    AddLog(ID, PChar(SysErrorMessage(GetLastError)));
end;

procedure TgdTask.ExecuteBackupFile;
begin
  //////
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

function TgdTaskManager.GetTask(Index: Integer): TgdTask;
begin
  Result := Self.FTaskList[Index] as TgdTask;
end;

function TgdTaskManager.GetCount: Integer;
begin
  if Self.FTaskList <> nil then
    Result := Self.FTaskList.Count
  else
    Result := 0;
end;

function TgdTaskManager.FindPriorityTask: TgdTask;

  function DayOfTheWeek(const AValue: TDateTime): Word;
  begin
    Result := (DateTimeToTimeStamp(AValue).Date - 1) mod 7 + 1;
  end;

  function DayOfTheMonth(const AValue: TDateTime): Word;
  var
    LYear, LMonth: Word;
  begin
    DecodeDate(AValue, LYear, LMonth, Result);
  end;

  function DaysInMonth(const AValue: TDateTime): Word;
  var
    LYear, LMonth, LDay: Word;
  begin
    DecodeDate(AValue, LYear, LMonth, LDay);
    Result := MonthDays[(LMonth = 2) and IsLeapYear(LYear), LMonth];
  end;

  // проверяем подходящий ли день недели или месяца для выполнения.
  function GoodDay(AgdTask: TgdTask; ANTD: TDateTime): Boolean;
  begin
    Assert(AgdTask <> nil);

    Result := False;

    // наверно в днях недели не стоит использовать отрицательные числа
    if AgdTask.Weekly <> 0 then
      Result := AgdTask.Weekly = DayOfTheWeek(ANTD)
    else if (AgdTask.Monthly <> 0) then
    begin
      if (AgdTask.Monthly > 0) then
        Result := AgdTask.Monthly = DayOfTheMonth(ANTD)
      else
        Result := (DaysInMonth(ANTD) - AgdTask.Monthly + 1) = DayOfTheMonth(ANTD);
    end;
  end;

  // проверяем по логу была ли задача уже выполнена.
  // любая запись в логе в подходящем временном интервале
  // говорит о том что задача уже запускалась и ее исключаем
  function TaskExecuted(AgdTask: TgdTask; ANTD: TDateTime): Boolean;
  var
    I: Integer;
  begin
    Result := False;

    if AgdTask.ExactDate <> 0 then
    begin
      for I := AgdTask.Count - 1 downto 0 do
      begin
        Result := AgdTask[I].EventTime >= AgdTask.ExactDate;
        if Result then
          exit;
      end;
    end
    else
    begin
      for I := AgdTask.Count - 1 downto 0 do
      begin
        Result := Trunc(AgdTask[I].EventTime) = Date;
        if Result then
          exit;
      end;
    end;
  end;

var
  I: Integer;
  NDT: TDateTime;
  MinDT: TDateTime;
begin
  // приоритет отдается задаче у которой наименьшее стартовое время
  Result := nil;

  if Self.Count = 0 then
    exit;

  NDT := Now;

  MinDT := 0;

  for I := 0 to Self.Count - 1 do
  begin
    if Self[I].ExactDate <> 0 then
    begin
      if Self[I].RightUser and (not Self[I].Disabled)
        and (not TaskExecuted(Self[I], NDT)) then
      begin
        if (MinDT > Self[I].ExactDate)
          or (MinDT = 0) then
        begin
          MinDT := Self[I].ExactDate;
          Result := Self[I];
        end;
      end;
    end
    else if Self[I].StartTime <> 0 then
    begin
      if Self[I].RightUser and (not Self[I].Disabled)
        and GoodDay(Self[I], NDT)
        and (not TaskExecuted(Self[I], NDT)) then
      begin
        if (MinDT > (Trunc(NDT) + Self[I].StartTime))
          or (MinDT = 0) then
        begin
          MinDT := Trunc(NDT) + Self[I].StartTime;
          Result := Self[I];
        end;
      end;
    end
    else
      raise Exception.Create('invalid task');
  end;
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

         q.Next;
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
