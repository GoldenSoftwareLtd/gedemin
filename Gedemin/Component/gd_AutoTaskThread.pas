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
    FExecuted: Boolean;

    FNextStartTime, FNextEndTime: TDateTime;

    procedure AddLog(AnEventText: String);

    procedure SetExecuted;

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

    property Executed: Boolean read FExecuted;
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

procedure TgdAutoTask.SetExecuted;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT * FROM gd_autotask_log l '#13#10 +
      'WHERE (l.autotaskkey = :AK) AND (l.creationdate >= :ST)';
    q.ParamByName('AK').AsInteger := Self.Id;
    if Self.ExactDate > 0 then
      q.ParamByName('ST').AsDateTime := Self.ExactDate
    else
      q.ParamByName('ST').AsDateTime := NextStartTime;

    q.ExecQuery;

    FExecuted := not q.Eof;
  finally
    q.Free;
  end;
end;

procedure TgdAutoTask.TaskExecute;
begin
  //
end;

procedure TgdAutoTask.Execute;
begin
  // ����� � ��� � ������ ����������

  TaskExecute;

  // ����� � ��� � ���������� ����������
end;

procedure TgdAutoTask.Schedule;

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

var
  NTD: TDateTime;
  Diff: Integer;
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

  if ExactDate > 0 then
  begin
    NextStartTime := 0;
    NextEndTime := 0;
    exit;
  end;

  NTD := Now;

  if ExactDate = 0 then
  begin
    if Daily then
    begin
      if NextStartTime > 0 then
      begin
        NextStartTime := NextStartTime + 1;
        NextEndTime := NextStartTime + 1;
      end
      else
      begin
        NextStartTime := Trunc(NTD) + StartTime;
        NextEndTime := Trunc(NTD) + EndTime;
      end;

      if (StartTime = EndTime) and (StartTime = 0)then
      begin
        if NTD >= (NextEndTime + 1) then
          Schedule;
      end
      else if NTD > NextEndTime then
        Schedule;
    end;

    if Weekly > 0 then
    begin
      if NextStartTime > 0 then
      begin
        NextStartTime := NextStartTime + 7;
        NextEndTime := NextStartTime + 7;
      end
      else
      begin
        Diff := (Weekly - DayOfTheWeek(NTD));
        if Diff < 0 then
          Diff := 7 - Diff;

        NextStartTime := Trunc(NTD) + StartTime + Diff;
        NextEndTime := Trunc(NTD) + EndTime + Diff;
      end;

      if (StartTime = EndTime) and (StartTime = 0) then
      begin
        if NTD >= (NextEndTime + 1) then
          Schedule;
      end
      else if NTD > NextEndTime then
        Schedule;
    end;

    {if Monthly > 0 then
    begin

    end; }
  end;

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
    SendNotification('��������� ������ ���������...');
    Synchronize(LoadFromRelation);
    if (FTaskList = nil) or (FTaskList.Count = 0) then
    begin
      SendNotification('��� ��������� ��� ����������');
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

  function GetStartTime(AnObject: TObject): TDateTime;
  begin
    Result := (AnObject as TgdAutoTask).ExactDate;

    if Result = 0 then
      Result := (AnObject as TgdAutoTask).NextStartTime;
  end;

var
  I, J: Integer;
  Task: TgdAutoTask;
  NTD: TDateTime;
begin
  While FTaskList.Count > 0 do
  begin
    NTD := Now;

    for I := FTaskList.Count - 1 to 0 do
    begin
      Task := FTaskList[I] as TgdAutoTask;

      if Task.ExactDate = 0 then
      begin
        if (Task.StartTime = Task.EndTime) and (Task.StartTime = 0) then
        begin
          if NTD >= (Task.NextEndTime + 1) then
            Task.Schedule;
        end
        else if NTD > Task.NextEndTime then
          Task.Schedule;
      end
      else
      begin
        // ��� �����������
        // ��������� ��������� �� ������, ���� ���������
        // ���� ��������� � �������, �� �������
        Synchronize(Task.SetExecuted);
        if Task.Executed then
          FTaskList.Delete(I);
      end;
    end;


    // ������ ����� ������������ � �������� �������
    for I := 0 to FTaskList.Count - 2 do
    begin
      for J := I + 1 to FTaskList.Count - 1 do
      begin
        if GetStartTime(FTaskList[J]) > GetStartTime(FTaskList[I]) then
          FTaskList.Exchange(J, I);
        if GetStartTime(FTaskList[J]) = GetStartTime(FTaskList[I]) then
        begin
          if TgdAutoTask(FTaskList[J]).Priority > TgdAutoTask(FTaskList[I]).Priority then
            FTaskList.Exchange(J, I);
        end;
      end;
    end;


    for I := FTaskList.Count - 1 to 0 do
    begin



      if GetStartTime(FTaskList[I]) > Now then
      begin
        SetTimeOut(Trunc((GetStartTime(FTaskList[I]) - Now) * MSecsPerDay));
        exit;
      end;


      Synchronize(TgdAutoTask(FTaskList[I]).SetExecuted);

      if not TgdAutoTask(FTaskList[I]).Executed then
        Synchronize(TgdAutoTask(FTaskList[I]).TaskExecute);

      if TgdAutoTask(FTaskList[I]).ExactDate > 0 then
        FTaskList.Delete(I)
      else
      begin
        if (TgdAutoTask(FTaskList[I]).StartTime = TgdAutoTask(FTaskList[I]).EndTime)
          and (TgdAutoTask(FTaskList[I]).StartTime = 0) then
        begin
          if NTD >= (TgdAutoTask(FTaskList[I]).NextEndTime + 1) then
            TgdAutoTask(FTaskList[I]).Schedule;
        end
        else if NTD > TgdAutoTask(FTaskList[I]).NextEndTime then
          TgdAutoTask(FTaskList[I]).Schedule;
      end;

    end;


    if FTaskList.Count = 0 then
      ExitThread;
  end;

{
  �������� �� ������:

  ���� ����������� ����� � �������, �� ������������ �����
  ��� ������� ������ �� ������, ���� ��� �����������
  �������.

  ��������� ������ �� ������� ����������� ����������,
  � ������ ��������� �����, ��������� ������� ���������� � ���� �����
  �� ����������.

  ���� � ������ �� ���������:

  ����� ������ �� �������������� ������.

  �� ����� ���������� ������?

  ��� ���: ��������� ������� �� �� ����������. ���������� �������
  � �������.

  ��������� � �� ��� ���������� ��� ��������� �������:
  ����� ��� ��� �����������? ����� ��� ��� ���������?

  ���� ��, �� ������������ ��������� ����� ����������.
  ���� ������ ����������� -- ������� ��.

  ��������� �� ������ �����.

  ��������� ������.

  ������������ ��� ������ ��������� �������� ����������.
  ���� ��� ����������� �������, �� ������� ���.

  ��������� �� ������ �����.

  �� ��������� ����� ��������� �������� �� ������ � ������.
  ���� ���, �� ��������� ����.

  �������������� ��������� ��� ����� ����������� ��������, �����
  ������ ������ �����������, �� ����� ���� ��� �������� ����������
  ��� ���������� ������.
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
