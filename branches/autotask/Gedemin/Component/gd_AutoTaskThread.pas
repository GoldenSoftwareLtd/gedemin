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

    FNextStartTime, FNextEndTime: TDateTime;

    procedure AddLog(AnEventText: String);

  protected
    procedure TaskExecute; virtual;

  public
    procedure Execute;
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
    property NextStartTime: TDateTime read FNextStartTime write FNextStartTime;
    property NextEndTime: TDateTime read FNextEndTime write FNextEndTime;
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
  // пишем в лог о начале выполнения

  TaskExecute;

  // пишем в лог о завершении выполнения
end;

procedure TgdAutoTask.Schedule;
begin
  // на основании параметров задачи и данных
  // о предыдущем запланированном запуске
  // (если планирование было)
  // рассчитываем следующее временное окно
  // запуска задачи
  //
  // например:
  // для задачи стоит выполнять ежедневно
  // с 13 до 14. послее ее считывания из БД
  // поля NextTime пусты, значит предыдущего планирования
  // еще не было. при вызове метода находим интервал
  // для сегодня и заносим в поля. проверяем,
  // если интервал уже в прошлом (на часах 15:00),
  // то повторно вызываем метод для расчета следующего
  // интервала. СМ. ЧТОБЫ МЕТОД НЕ ЗАЦИКЛИЛСЯ!
  //
  // если интервал уже прописан, то очередной
  // вызов метода находит следующий интервал и
  // заносит в поля.
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
var
  q: TIBSQL;
  Task: TgdAutoTask;
begin
  Assert(gdcBaseManager <> nil);
  Assert(IBLogin <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT * FROM gd_autotask ' +
      'WHERE disabled = 0 ' +
      '  AND (userkey IS NULL OR userkey = :uk)';
    q.ParamByName('uk').AsInteger := IBLogin.UserKey;
    q.ExecQuery;

    while not q.EOF do
    begin
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
        Task := nil;

      if Task <> nil then
      begin
        Task.Id := q.FieldbyName('id').AsInteger;
        Task.Name := q.FieldbyName('name').AsString;
        Task.Description := q.FieldbyName('description').AsString;
        Task.ExactDate := q.FieldbyName('exactdate').AsDateTime;
        Task.Monthly := q.FieldbyName('monthly').AsInteger;
        Task.Weekly := q.FieldbyName('weekly').AsInteger;
        Task.Daily := q.FieldbyName('daily').AsInteger = 1;
        Task.StartTime := q.FieldbyName('starttime').AsTime;
        Task.EndTime := q.FieldbyName('endtime').AsTime;
        Task.Priority := q.FieldbyName('priority').AsInteger;
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
  if FTaskList = nil then
  begin
    SendNotification('Считываем список автозадач...');
    Synchronize(LoadFromRelation);
    if (FTaskList = nil) or (FTaskList.Count = 0) then
    begin
      SendNotification('Нет автозадач для выполнения');
      ExitThread;
      exit;
    end;
  end;

  PostMsg(WM_GD_FIND_AND_EXECUTE_TASK);
end;

function TgdAutoTaskThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  case Msg.Message of
    WM_GD_FIND_AND_EXECUTE_TASK:
    begin
      FindAndExecuteTask;
      Result := True;
    end;
  else
    Result := False;
  end;
end;

procedure TgdAutoTaskThread.SendNotification(const AText: String);
begin
  gdNotifierThread.Add(AText, FNotificationContext, 2000);
end;

procedure TgdAutoTaskThread.SetInitialDelay;
begin
  Resume;
  SetTimeOut(5 {* 60} * 1000);
end;

procedure TgdAutoTaskThread.FindAndExecuteTask;
begin
{
  Проходим по списку:

  если планируемое время в прошлом, то рассчитываем новое
  или удаляем задачу из списка, если это однократное
  задание.

  сортируем список по времени планируемых интервалов,
  а внутри подсписка задач, интервалы которых начинаются в одно время
  по приоритету.

  цикл с первой до последней:

  берем задачу из упорядоченного списка.

  ее время выполнения пришло?

  еще нет: вычисляем таймаут до ее выполнения. выставляем таймаут
  и выходим.

  проверяем в бд для известного нам интервала времени:
  может она уже выполняется? может она уже выполнена?

  если да, то рассчитываем следующее время выполнения.
  если задача однократная -- удаляем ее.

  переходим на начало цикла.

  выполняем задачу.

  рассчитываем для задачи следующий интервал выполнения.
  если это однократное задание, то удаляем его.

  переходим на начало цикла.

  по окончании цикла проверяем остались ли задачи в списке.
  если нет, то завершаем нить.

  САМОСТОЯТЕЛЬНО ПРОДУМАТЬ как будут разрешаться ситуации, когда
  задача начала выполняться, но завис комп или возникло исключение
  при выполнении задачи.
}
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
