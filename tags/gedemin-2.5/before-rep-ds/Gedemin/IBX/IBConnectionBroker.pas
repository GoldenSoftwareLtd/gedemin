{*************************************************************}
{                                                             }
{       Borland Delphi Visual Component Library               }
{       InterBase Express core components                     }
{                                                             }
{       Copyright (c) 2001 Robert Schieck and Jeff Overcash   }
{                                                             }
{    IBConnectionBroker is based in part on the work          }
{    done by Robert Schieck of MERS systems                   }
{    http://www.mers.com                                      }
{                                                             }
{*************************************************************}

unit IBConnectionBroker;

interface

uses
  Windows, SysUtils, Classes, Db, IBDatabase, IBHeader;

type

  TIBConnectionBrokerLogEvent = procedure(Sender : TObject; LogMessage : String) of object;

  TIBPooledConnection = class(TComponent)
  private
    FConnStatus: Integer;
    FConnLockTime: TDateTime;
    FConnCreateDate: TDateTime;
    FDatabase: TIBDatabase;
  public
    constructor Create(AOwner : TComponent); override;
    property Database : TIBDatabase read FDatabase;
    property ConnStatus : Integer read FConnStatus write FConnStatus;
    property ConnLockTime : TDateTime read FConnLockTime write FConnLockTime;
    property ConnCreateDate : TDateTime read FConnCreateDate write FConnCreateDate;
  end;

  TIBConnectionBroker = class(TComponent)
  private
    FConnPool : array of TIBPooledConnection;
    FDatabaseName : string;
    FCurrConnections, FConnLast, FMinConns, FMaxConns: Integer;
    FIdleTimer: Cardinal;
    FDBParams: TStrings;
    FDelay: Cardinal;
    FOnLog: TIBConnectionBrokerLogEvent;
    procedure SetDBParams(const Value: TStrings);
    procedure SetMaxConns(const Value: Integer);
    procedure SetMinConns(const Value: Integer);
    function GetAllocated: Integer;
    function GetAvailable: Integer;
  protected
    procedure CreateConn(i: Integer);
    procedure DoLog(msg: string);
    procedure Loaded; override;
  public
    CS1 : TRTLCriticalSection;
    function GetConnection: TIBDatabase;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    procedure ReleaseConnection(db: TIBDatabase);
    property AllocatedConnections : Integer read GetAllocated;
    property AvailableConnections : Integer read GetAvailable;

  published
    property DatabaseName : string read FDatabaseName write FDatabaseName;
    property Params : TStrings read FDBParams write SetDBParams;
    property MinConnections : Integer read FMinConns write SetMinConns default 10;
    property MaxConnections : Integer read FMaxConns write SetMaxConns default 20;
    property TransactionIdleTimer : Cardinal read FIdleTimer write FIdleTimer;
    property ExhustedDelay : Cardinal read FDelay write FDelay default 500;
    property OnLog : TIBConnectionBrokerLogEvent read FOnLog write FOnLog;
  end;

implementation

{ TIBPooledConnection }

constructor TIBPooledConnection.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TIBDatabase.Create(self);
  FDatabase.DefaultTransaction := TIBTransaction.Create(self);
  with FDatabase.DefaultTransaction.Params do
  begin
    Add('read_committed');
    Add('rec_version');
    Add('nowait');
  end;
  FDatabase.DefaultTransaction.DefaultDatabase := FDatabase;
end;

{ TIBConnectionBroker }
constructor TIBConnectionBroker.Create(aowner: Tcomponent);
begin
  inherited Create(aowner);
  FDelay := 500;
  FMaxConns := 20;
  FMinConns := 10;
  FDBParams := TStringList.Create;
  InitializeCriticalSection(CS1);
end;

procedure TIBConnectionBroker.CreateConn(i: Integer);
begin
  FConnPool[i].Database.DatabaseName := FDatabaseName;
  FConnPool[i].Database.Params := FDBParams;
  FConnPool[i].Database.LoginPrompt := false;
  if (FIdleTimer > 0) then
    FConnPool[i].Database.DefaultTransaction.IdleTimer := FIdleTimer;
  FConnPool[i].Database.Connected := true;
  FConnPool[i].ConnStatus := 0;
  FConnPool[i].ConnLockTime := 0;
  FConnPool[i].ConnCreateDate := Now;
  DoLog(formatdatetime('mm/dd/yyyy hh:mm:ss', Now) + '  Opening connection ' +
    IntToStr(i));
end;

destructor TIBConnectionBroker.Destroy;
var
  i: Integer;
begin
  if not (csDesigning in ComponentState) then
    for i := 0 to FMaxConns - 1 do
      FConnPool[i].Free;
  FConnPool := nil;
  DeleteCriticalSection(CS1);
  FDBParams.Free;
  inherited Destroy;
end;

procedure TIBConnectionBroker.DoLog(msg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(self, msg);
end;

procedure TIBConnectionBroker.Init;
var
  j: Integer;
begin
  if FCurrConnections <> 0 then
    Exit;
  DoLog('Starting IBConnectionBroker Version 1.0.1:');
  DoLog('Databasename = ' + FDatabaseName);
  DoLog('userName = ' + FDBParams.Values['user_name']);
  DoLog('minconnections = ' + IntToStr(FMinConns));
  DoLog('maxconnections = ' + IntToStr(FMaxConns));
  DoLog('IdleTimer = ' + IntToStr(FIdleTimer));
  DoLog('-----------------------------------------');
  FCurrConnections := FMinConns;
  for j := 0 to FMinConns - 1 do
    CreateConn(j);
end;

function TIBConnectionBroker.GetConnection: TIBDatabase;
var
  gotOne: Boolean;
  OuterLoop: Integer;
  aloop: Integer;
  roundrobin: Integer;
begin
  result := nil;
  gotOne := false;
  for outerloop := 0 to 2 do
  begin
    try
      aloop := 0;
      roundRobin := FConnLast + 1;
      if (roundRobin >= FCurrConnections) then
        roundRobin := 0;
      EnterCriticalSection(CS1);
      try
        repeat
          begin
            begin
              if (FConnPool[roundRobin].ConnStatus < 1) then
              begin
                if (FConnPool[roundRobin].Database.Connected) then
                begin
                  result := FConnPool[roundRobin].Database;
                  FConnPool[roundRobin].ConnStatus := 1;
                  FConnPool[roundRobin].ConnLockTime := now;
                  FConnLast := roundRobin;
                  gotOne := true;
                  DoLog('gave out connection ' + IntToStr(roundrobin));
                  break;
                end;
              end
              else
              begin
                inc(aloop);
                inc(roundRobin);
                if (roundRobin >= FCurrConnections) then
                  roundRobin := 0;
              end;
            end;
          end;
        until ((gotOne = true) or (aloop >= FCurrConnections));
      finally
        LeaveCriticalSection(CS1);
      end;
    except
      ///
    end;

    if (gotOne) then
    begin
      break;
    end
    else
    begin
      entercriticalsection(CS1);
      begin // Add new connections to the pool
        if (FCurrConnections < FMaxConns) then
        begin
          try
            CreateConn(FCurrConnections);
            Inc(FCurrConnections);
          except
            on E: Exception do
              DoLog('Unable to create new connection: ' + e.Message );
          end;
        end;

        sleep(FDelay);
        DoLog('-----> Connections Exhausted!  Will wait and try ' +
          'again in loop ' + IntToStr(outerloop));
      end;
      leaveCriticalSection(CS1);
    end; // End of try 10 times loop
  end;
end;

procedure TIBConnectionBroker.Loaded;
var
  i : Integer;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    SetLength(FConnPool, FMaxConns);
    for i := 0 to FMaxConns - 1 do
      FConnPool[i] := TIBPooledConnection.Create(self);
  end;
end;

procedure TIBConnectionBroker.ReleaseConnection(db: TIBDatabase);
var
  i: Integer;
begin
  EnterCriticalSection(CS1);
  if not Assigned(db) then
    DoLog('Nil database tried to be released')
  else
  for i := 0 to FCurrConnections - 1 do
  begin
    if (db.Handle = FConnPool[i].Database.Handle) then
    begin
      if(FConnPool[i].Database.DefaultTransaction.Active) then
        FConnPool[i].Database.DefaultTransaction.Active := false;
      FConnPool[i].ConnStatus := 0;
      DoLog('Release connection ' + IntToStr(i));
    end;
  end;
  LeaveCriticalSection(CS1);
end;

procedure TIBConnectionBroker.SetDBParams(const Value: TStrings);
begin
  FDBParams.Assign(Value);
end;

procedure TIBConnectionBroker.SetMaxConns(const Value: Integer);
var
  i : Integer;
begin
  if csLoading in ComponentState then
  begin
    FMaxConns := Value;
    exit;
  end;
  if csDesigning in ComponentState then
  begin
    if Value >= FMinConns then
      FMaxConns := Value
    else
      FMaxConns := FMinConns;
    Exit;
  end;
  EnterCriticalSection(CS1);
  try
    if (FMaxConns <> Value) and (Value >= FMinConns) then
    begin
      if FMaxConns < Value then
      begin
        SetLength(FConnPool, Value);
        for i := FMaxConns to Value - 1 do
          FConnPool[i] := TIBPooledConnection.Create(self);
        FMaxConns := Value;
      end
      else
        if Value >= FCurrConnections then
        begin
          for i := FMaxConns - 1 downto Value do
            FConnPool[i].Free;
          SetLength(FConnPool, Value);
          FMaxConns := Value;
        end;
    end;
  finally
    LeaveCriticalSection(CS1);
  end;
end;

procedure TIBConnectionBroker.SetMinConns(const Value: Integer);
var
  i : Integer;
begin
  if csLoading in ComponentState then
  begin
    FMinConns := Value;
    exit;
  end;
  if csDesigning in ComponentState then
  begin
    if Value < FMaxConns then
      FMinConns := Value
    else
      FMinConns := FMaxConns;
    Exit;
  end;
  EnterCriticalSection(CS1);
  try
    FMinConns := Value;
    if FMinConns > FMaxConns then
      FMinConns := FMaxConns;
    if FMinConns < FCurrConnections then
      FMinConns := FCurrConnections;
    if FMinConns > FCurrConnections then
    for i := FCurrConnections to FMinConns - 1 do
      CreateConn(i);
    FCurrConnections := FMinConns;
  finally
    LeaveCriticalSection(CS1);
  end;
end;

function TIBConnectionBroker.GetAllocated: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to FMaxConns - 1 do
    if FConnPool[i].ConnStatus = 1 then
      Inc(Result);
end;

function TIBConnectionBroker.GetAvailable: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to FMaxConns - 1 do
    if FConnPool[i].ConnStatus = 0 then
      Inc(Result);
end;

end.

