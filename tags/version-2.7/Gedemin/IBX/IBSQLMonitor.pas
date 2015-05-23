{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

unit IBSQLMonitor;

interface

uses
  SysUtils, Windows, Messages, Classes, Forms, Controls, Dialogs, StdCtrls,
  IB, IBUtils, IBSQL, IBCustomDataSet, IBDatabase, IBServices, IBXConst;

const
  WM_MIN_IBSQL_MONITOR = WM_USER;
  WM_MAX_IBSQL_MONITOR = WM_USER + 512;
  WM_IBSQL_SQL_EVENT = WM_MIN_IBSQL_MONITOR + 1;

type
  TIBCustomSQLMonitor = class;

  { TIBSQLMonitor }
  TSQLEvent = procedure(EventText: String; EventTime : TDateTime) of object;

  TIBCustomSQLMonitor = class(TComponent)
  private
    FHWnd: HWND;
    FOnSQLEvent: TSQLEvent;
    FTraceFlags: TTraceFlags;
    FEnabled: Boolean;
    procedure MonitorWndProc(var Message : TMessage);
    procedure SetEnabled(const Value: Boolean);
  protected
    property OnSQL: TSQLEvent read FOnSQLEvent write FOnSQLEvent;
    property TraceFlags: TTraceFlags read FTraceFlags write FTraceFlags;
    property Enabled : Boolean read FEnabled write SetEnabled default true;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Release;
    property Handle : HWND read FHwnd;
  end;

  TIBSQLMonitor = class(TIBCustomSQLMonitor)
  published
    property OnSQL;
    property TraceFlags;
    property Enabled;
  end;

  IIBSQLMonitorHook = interface
    ['{CF65434C-9B75-4298-BA7E-E6B85B3C769D}']
    procedure RegisterMonitor(SQLMonitor : TIBCustomSQLMonitor);
    procedure UnregisterMonitor(SQLMonitor : TIBCustomSQLMonitor);
    procedure ReleaseMonitor(Arg : TIBCustomSQLMonitor);
    procedure SQLPrepare(qry: TIBSQL);
    {$IFDEF GEDEMIN}
    procedure SQLExecute(qry: TIBSQL; const Duration: Cardinal);
    {$ELSE}
    procedure SQLExecute(qry: TIBSQL);
    {$ENDIF}
    procedure SQLFetch(qry: TIBSQL); 
    procedure DBConnect(db: TIBDatabase);
    procedure DBDisconnect(db: TIBDatabase);
    procedure TRStart(tr: TIBTransaction); 
    procedure TRCommit(tr: TIBTransaction);
    procedure TRCommitRetaining(tr: TIBTransaction); 
    procedure TRRollback(tr: TIBTransaction);
    procedure TRRollbackRetaining(tr: TIBTransaction);
    procedure ServiceAttach(service: TIBCustomService); 
    procedure ServiceDetach(service: TIBCustomService);
    procedure ServiceQuery(service: TIBCustomService);
    procedure ServiceStart(service: TIBCustomService);
    procedure SendMisc(Msg : String);
    procedure SendError(Msg : String; db: TIBDatabase); overload;
    procedure SendError(Msg : String); overload;
    function GetTraceFlags : TTraceFlags;
    function GetMonitorCount : Integer;
    procedure SetTraceFlags(const Value : TTraceFlags);
    function GetEnabled : boolean;
    procedure SetEnabled(const Value : Boolean);
    property TraceFlags: TTraceFlags read GetTraceFlags write SetTraceFlags;
    property Enabled : Boolean read GetEnabled write SetEnabled;
  end;


function MonitorHook: IIBSQLMonitorHook;
procedure EnableMonitoring;
procedure DisableMonitoring;
function MonitoringEnabled: Boolean;

implementation

uses
  contnrs, IBHeader;

type

  { TIBSQLMonitorHook }
  TIBSQLMonitorHook = class(TInterfacedObject, IIBSQLMonitorHook)
  private
    FTraceFlags: TTraceFlags;
    FEnabled: Boolean;
    FEventsCreated : Boolean;
    procedure CreateEvents;
  protected
    procedure WriteSQLData(Text: String; DataType: TTraceFlag);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterMonitor(SQLMonitor : TIBCustomSQLMonitor);
    procedure UnregisterMonitor(SQLMonitor : TIBCustomSQLMonitor);
    procedure ReleaseMonitor(Arg : TIBCustomSQLMonitor);
    procedure SQLPrepare(qry: TIBSQL); virtual;
    {$IFDEF GEDEMIN}
    procedure SQLExecute(qry: TIBSQL; const Duration: Cardinal); virtual;
    {$ELSE}
    procedure SQLExecute(qry: TIBSQL); virtual;
    {$ENDIF}
    procedure SQLFetch(qry: TIBSQL); virtual;
    procedure DBConnect(db: TIBDatabase); virtual;
    procedure DBDisconnect(db: TIBDatabase); virtual;
    procedure TRStart(tr: TIBTransaction); virtual;
    procedure TRCommit(tr: TIBTransaction); virtual;
    procedure TRCommitRetaining(tr: TIBTransaction); virtual;
    procedure TRRollback(tr: TIBTransaction); virtual;
    procedure TRRollbackRetaining(tr: TIBTransaction); virtual;
    procedure ServiceAttach(service: TIBCustomService); virtual;
    procedure ServiceDetach(service: TIBCustomService); virtual;
    procedure ServiceQuery(service: TIBCustomService); virtual;
    procedure ServiceStart(service: TIBCustomService); virtual;
    procedure SendMisc(Msg : String);
    procedure SendError(Msg : String; db: TIBDatabase); overload;
    procedure SendError(Msg : String); overload;
    function GetEnabled: Boolean;
    function GetTraceFlags: TTraceFlags;
    function GetMonitorCount : Integer;
    procedure SetEnabled(const Value: Boolean);
    procedure SetTraceFlags(const Value: TTraceFlags);
    property TraceFlags: TTraceFlags read GetTraceFlags write SetTraceFlags;
    property Enabled : Boolean read GetEnabled write SetEnabled default true;
  end;

  { There are two possible objects.  One is a trace message object.
    This object holds the flag of the trace type plus the message.
    The second object is a Release object.  It holds the handle that
    the CM_RELEASE message is to be queued to. }

  TTraceObject = Class(TObject)
    FDataType : TTraceFlag;
    FMsg : String;
    FTimeStamp : TDateTime;
  public
    constructor Create(Msg : String; DataType : TTraceFlag); overload;
    constructor Create(obj : TTraceObject); overload;
  end;

  TReleaseObject = Class(TObject)
    FHandle : THandle;
  public
    constructor Create(Handle : THandle);
  end;

  TWriterThread = class(TThread)
  private
    { Private declarations }
    FMsgs : TObjectList;
  protected
    procedure Lock;
    Procedure Unlock;
    procedure BeginWrite;
    procedure EndWrite;
    procedure Execute; override;
    procedure WriteToBuffer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure WriteSQLData(Msg : String; DataType : TTraceFlag);
    procedure ReleaseMonitor(HWnd : THandle);
  end;

  TReaderThread = class(TThread)
  private
    st : TTraceObject;
    FMonitors : TObjectList;
    { Private declarations }
  protected
    procedure BeginRead;
    procedure EndRead;
    procedure ReadSQLData;
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddMonitor(Arg : TIBCustomSQLMonitor);
    procedure RemoveMonitor(Arg : TIBCustomSQLMonitor);
  end;

const
  CM_BASE                   = $B000;
  CM_RELEASE                = CM_BASE + 33;

  MonitorHookNames: array[0..5] of String = (
    'IB.SQL.MONITOR.Mutex4_1',  {do not localize}
    'IB.SQL.MONITOR.SharedMem4_1',  {do not localize}
    'IB.SQL.MONITOR.WriteEvent4_1',   {do not localize}
    'IB.SQL.MONITOR.WriteFinishedEvent4_1',  {do not localize}
    'IB.SQL.MONITOR.ReadEvent4_1',         {do not localize}
    'IB.SQL.MONITOR.ReadFinishedEvent4_1'   {do not localize}
  );
  cMonitorHookSize = 8192; //1024
  cMaxBufferSize = cMonitorHookSize - (4 * SizeOf(Integer)) - SizeOf(TDateTime);
  cDefaultTimeout = 500; { 1 seconds }

var
  FSharedBuffer,
  FWriteLock,
  FWriteEvent,
  FWriteFinishedEvent,
  FReadEvent,
  FReadFinishedEvent : THandle;
  FBuffer : PChar;
  FMonitorCount,
  FReaderCount,
  FTraceDataType,
  FBufferSize : PInteger;
  FTimeStamp : PDateTime;

  FWriterThread : TWriterThread;
  FReaderThread : TReaderThread;
  _MonitorHook: TIBSQLMonitorHook;
  bDone: Boolean;

  CS : TRTLCriticalSection;
  
{ TIBCustomSQLMonitor }

constructor TIBCustomSQLMonitor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTraceFlags := [tfqPrepare .. tfMisc];
  FEnabled := true;
  if not (csDesigning in ComponentState) then
  begin
    FHWnd := AllocateHWnd(MonitorWndProc);
    MonitorHook.RegisterMonitor(self);
  end;
end;

destructor TIBCustomSQLMonitor.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    if FEnabled then
      MonitorHook.UnregisterMonitor(self);
    DeallocateHwnd(FHWnd);
  end;
  inherited Destroy;
end;

procedure TIBCustomSQLMonitor.MonitorWndProc(var Message: TMessage);
var
  st : TTraceObject;
begin
  case Message.Msg of
    WM_IBSQL_SQL_EVENT:
    begin
      st := TTraceObject(Message.LParam);
      if (Assigned(FOnSQLEvent)) and
         (st.FDataType in FTraceFlags) then
        FOnSQLEvent(st.FMsg, st.FTimeStamp);
      st.Free;
    end;
    CM_RELEASE :
      Free;
    else
      DefWindowProc(FHWnd, Message.Msg, Message.WParam, Message.LParam);
  end;
end;

procedure TIBCustomSQLMonitor.Release;
begin
  MonitorHook.ReleaseMonitor(self);
end;

procedure TIBCustomSQLMonitor.SetEnabled(const Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    if not (csDesigning in ComponentState) then
      if FEnabled then
        Monitorhook.RegisterMonitor(self)
      else
        MonitorHook.UnregisterMonitor(self);
  end;
end;

{ TIBSQLMonitorHook }

constructor TIBSQLMonitorHook.Create;
begin
  inherited Create;
  FEventsCreated := false;
  FTraceFlags := [tfQPrepare..tfMisc];
  FEnabled := true;
end;

procedure TIBSQLMonitorHook.CreateEvents;
var
  Sa : TSecurityAttributes;
  Sd : TSecurityDescriptor;

  function OpenLocalEvent(Idx: Integer): THandle;
  begin
    result := OpenEvent(EVENT_ALL_ACCESS, true, PChar(MonitorHookNames[Idx]));
    if result = 0 then
      IBError(ibxeCannotCreateSharedResource, [GetLastError]);
  end;

  function CreateLocalEvent(Idx: Integer; InitialState: Boolean): THandle;
  begin
    result := CreateEvent(@sa, true, InitialState, PChar(MonitorHookNames[Idx]));
    if result = 0 then
      IBError(ibxeCannotCreateSharedResource, [GetLastError]);
  end;

begin
  { Setup Secureity so anyone can connect to the MMF/Mutex/Events.  This is
    needed when IBX is used in a Service. }

  InitializeSecurityDescriptor(@Sd,SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@Sd,true,nil,false);
  Sa.nLength := SizeOf(Sa);
  Sa.lpSecurityDescriptor := @Sd;
  Sa.bInheritHandle := true;

  FSharedBuffer := CreateFileMapping($FFFFFFFF, @sa, PAGE_READWRITE,
                       0, cMonitorHookSize, PChar(MonitorHookNames[1]));

  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    FSharedBuffer := OpenFileMapping(FILE_MAP_ALL_ACCESS, false, PChar(MonitorHookNames[1]));
    if (FSharedBuffer = 0) then
      IBError(ibxeCannotCreateSharedResource, [GetLastError]);
    FBuffer := MapViewOfFile(FSharedBuffer, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if FBuffer = nil then
      IBError(ibxeCannotCreateSharedResource, [GetLastError]);
    FMonitorCount := PInteger(FBuffer + cMonitorHookSize - SizeOf(Integer));
    FReaderCount := PInteger(PChar(FMonitorCount) - SizeOf(Integer));
    FTraceDataType := PInteger(PChar(FReaderCount) - SizeOf(Integer));
    FTimeStamp := PDateTime(PChar(FTraceDataType) - SizeOf(TDateTime));
    FBufferSize := PInteger(PChar(FTimeStamp) - SizeOf(Integer));
    FWriteLock := OpenMutex(MUTEX_ALL_ACCESS, False, PChar(MonitorHookNames[0]));
    FWriteEvent := OpenLocalEvent(2);
    FWriteFinishedEvent := OpenLocalEvent(3);
    FReadEvent := OpenLocalEvent(4);
    FReadFinishedEvent := OpenLocalEvent(5);
  end
  else
  begin
    FWriteLock := CreateMutex(@sa, False, PChar(MonitorHookNames[0]));
    FWriteEvent := CreateLocalEvent(2, False);
    FWriteFinishedEvent := CreateLocalEvent(3, True);
    FReadEvent := CreateLocalEvent(4, False);
    FReadFinishedEvent := CreateLocalEvent(5, False);

    FBuffer := MapViewOfFile(FSharedBuffer, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    FMonitorCount := PInteger(FBuffer + cMonitorHookSize - SizeOf(Integer));
    FReaderCount := PInteger(PChar(FMonitorCount) - SizeOf(Integer));
    FTraceDataType := PInteger(PChar(FReaderCount) - SizeOf(Integer));
    FTimeStamp := PDateTime(PChar(FTraceDataType) - SizeOf(TDateTime));
    FBufferSize := PInteger(PChar(FTimeStamp) - SizeOf(Integer));
    FMonitorCount^ := 0;
    FReaderCount^ := 0;
    FBufferSize^ := 0;
  end;

  { This should never evaluate to true, if it does
  there has been a hiccup somewhere. }

  if FMonitorCount^ < 0 then
    FMonitorCount^ := 0;
  if FReaderCount^ < 0 then
    FReaderCount^ := 0;
  FEventsCreated := true;
end;

procedure TIBSQLMonitorHook.DBConnect(db: TIBDatabase);
var
  st : String;
begin
  if FEnabled then
  begin
    if not (tfConnect in FTraceFlags * db.TraceFlags) then
      Exit;
    st := db.Name + ': [Connect]'; {do not localize}
    WriteSQLData(st, tfConnect);
  end;
end;

procedure TIBSQLMonitorHook.DBDisconnect(db: TIBDatabase);
var
  st: String;
begin
  if FEnabled then
  begin
    if not (tfConnect in FTraceFlags * db.TraceFlags) then
      Exit;
    st := db.Name + ': [Disconnect]'; {do not localize}
    WriteSQLData(st, tfConnect);
  end;
end;

destructor TIBSQLMonitorHook.Destroy;
begin
  if FEventsCreated then
  begin
    UnmapViewOfFile(FBuffer);
    CloseHandle(FSharedBuffer);
    CloseHandle(FWriteEvent);
    CloseHandle(FWriteFinishedEvent);
    CloseHandle(FReadEvent);
    CloseHandle(FReadFinishedEvent);
    CloseHandle(FWriteLock);
  end;
  inherited Destroy;
end;

function TIBSQLMonitorHook.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TIBSQLMonitorHook.GetMonitorCount: Integer;
begin
  Result := FMonitorCount^;
end;

function TIBSQLMonitorHook.GetTraceFlags: TTraceFlags;
begin
  Result := FTraceFlags;
end;

procedure TIBSQLMonitorHook.RegisterMonitor(SQLMonitor: TIBCustomSQLMonitor);
begin
  if not FEventsCreated then
  try
    CreateEvents;
  except
    SQLMonitor.Enabled := false;
  end;
  if not Assigned(FReaderThread) then
    FReaderThread := TReaderThread.Create;
  FReaderThread.AddMonitor(SQLMonitor);
end;

procedure TIBSQLMonitorHook.ReleaseMonitor(Arg: TIBCustomSQLMonitor);
begin
  FWriterThread.ReleaseMonitor(Arg.FHWnd);
end;

procedure TIBSQLMonitorHook.SendMisc(Msg: String);
begin
  if FEnabled then
    WriteSQLData(Msg, tfMisc);
end;

procedure TIBSQLMonitorHook.SendError(Msg : String; db: TIBDatabase);
begin
  if FEnabled then
    if (tfError in FTraceFlags * db.TraceFlags) then
      WriteSQLData('[Error] ' + Msg, tfError);
end;

procedure TIBSQLMonitorHook.SendError(Msg : String);
begin
  if FEnabled then
    if (tfError in FTraceFlags) then
      WriteSQLData('[Error] ' + Msg, tfError);
end;

procedure TIBSQLMonitorHook.ServiceAttach(service: TIBCustomService);
var
  st: String;
begin
  if FEnabled then
  begin
    if not (tfService in (FTraceFlags * service.TraceFlags)) then
      Exit;
    st := service.Name + ': [Attach]'; {do not localize}
    WriteSQLData(st, tfService);
  end;
end;

procedure TIBSQLMonitorHook.ServiceDetach(service: TIBCustomService);
var
  st: String;
begin
  if FEnabled then
  begin
    if not (tfService in (FTraceFlags * service.TraceFlags)) then
      Exit;
    st := service.Name + ': [Detach]'; {do not localize}
    WriteSQLData(st, tfService);
  end;
end;

procedure TIBSQLMonitorHook.ServiceQuery(service: TIBCustomService);
var
  st: String;
begin
  if FEnabled then
  begin
    if not (tfService in (FTraceFlags * service.TraceFlags)) then
      Exit;
    st := service.Name + ': [Query]'; {do not localize}
    WriteSQLData(st, tfService);
  end;
end;

procedure TIBSQLMonitorHook.ServiceStart(service: TIBCustomService);
var
  st: String;
begin
  if FEnabled then
  begin
    if not (tfService in (FTraceFlags * service.TraceFlags)) then
      Exit;
    st := service.Name + ': [Start]'; {do not localize}
    WriteSQLData(st, tfService);
  end;
end;

procedure TIBSQLMonitorHook.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
    FEnabled := Value;
  if (not FEnabled) and (Assigned(FWriterThread)) then
  begin
    FWriterThread.Terminate;
    FWriterThread.WaitFor;
    FreeAndNil(FWriterThread);
  end;
end;

procedure TIBSQLMonitorHook.SetTraceFlags(const Value: TTraceFlags);
begin
  FTraceFlags := Value
end;

{$IFDEF GEDEMIN}
procedure TIBSQLMonitorHook.SQLExecute(qry: TIBSQL; const Duration: Cardinal);
{$ELSE}
procedure TIBSQLMonitorHook.SQLExecute(qry: TIBSQL);
{$ENDIF}
var
  st: String;
  i: Integer;
begin
  if FEnabled then
  begin
    if not ((tfQExecute in (FTraceFlags * qry.Database.TraceFlags)) or
            (tfStmt in (FTraceFlags * qry.Database.TraceFlags)) ) then
      Exit;
    if qry.Owner is TIBCustomDataSet then
      st := TIBCustomDataSet(qry.Owner).Name
    else
      st := qry.Name;
    //!!!b
    if st = '' then
      st := qry.SQL.Text
    else
    //!!!e
      st := st + ': [Execute] '+ CrLf + qry.SQL.Text; {do not localize}
    if qry.Params.Count > 0 then begin
      //!!!b
      st := st + CrLf + '[Params]';
      //!!!e
      for i := 0 to qry.Params.Count - 1 do begin
        st := st + CRLF + '  ' + qry.Params[i].Name + ' = ';  {do not localize}
        try
          if qry.Params[i].IsNull then
            st := st + '<NULL>' {do not localize}
          else
          if qry.Params[i].SQLType <> SQL_BLOB then
            st := st + qry.Params[i].AsString
          else
            st := st + '<BLOB>';   {do not localize}
        except
          st := st + '<' + SCantPrintValue + '>';  {do not localize}
        end;
      end;
    end;
    {$IFDEF GEDEMIN}
    st := st + CrLf + '[Duration: ' + IntToStr(Duration) + ']';
    {$ENDIF}
    WriteSQLData(st, tfQExecute);
  end;
end;

procedure TIBSQLMonitorHook.SQLFetch(qry: TIBSQL);
var
  st: String;
begin
  if FEnabled then
  begin
    if not ((tfQFetch in (FTraceFlags * qry.Database.TraceFlags)) or
            (tfStmt in (FTraceFlags * qry.Database.TraceFlags))) then
      Exit;
    if qry.Owner is TIBCustomDataSet then
      st := TIBCustomDataSet(qry.Owner).Name
    else
      st := qry.Name;
    st := st + ': [Fetch] ' + qry.SQL.Text; {do not localize}
    if (qry.EOF) then
      st := st + CRLF + '  ' + SEOFReached;   {do not localize}
    WriteSQLData(st, tfQFetch);
  end;
end;

procedure TIBSQLMonitorHook.SQLPrepare(qry: TIBSQL);
var
  st: String;
begin
  if FEnabled then
  begin
    if not ((tfQPrepare in (FTraceFlags * qry.Database.TraceFlags)) or
            (tfStmt in (FTraceFlags * qry.Database.TraceFlags))) then
      Exit;
    if qry.Owner is TIBCustomDataSet then
      st := TIBCustomDataSet(qry.Owner).Name
    else
      st := qry.Name;
    st := st + ': [Prepare] ' + qry.SQL.Text + CRLF; {do not localize}
    try
      st := st + '  Plan: ' + qry.Plan; {do not localize}
    except
      st := st + '  Plan: Can''t retrieve plan - too large';   {do not localize}
    end;
    WriteSQLData(st, tfQPrepare);
  end;
end;

procedure TIBSQLMonitorHook.TRCommit(tr: TIBTransaction);
var
  st: String;
begin
  if FEnabled then
  begin
    if Assigned(tr.DefaultDatabase) and
       (tfTransact in (FTraceFlags * tr.DefaultDatabase.TraceFlags)) then
    begin
      st := tr.Name + ': [Commit (Hard commit)]'; {do not localize}
      WriteSQLData(st, tfTransact);
    end;
  end;
end;

procedure TIBSQLMonitorHook.TRCommitRetaining(tr: TIBTransaction);
var
  st: String;
begin
  if FEnabled then
  begin
    if Assigned(tr.DefaultDatabase) and
       (tfTransact in (FTraceFlags * tr.DefaultDatabase.TraceFlags)) then
    begin
      st := tr.Name + ': [Commit retaining (Soft commit)]'; {do not localize}
      WriteSQLData(st, tfTransact);
    end;
  end;
end;

procedure TIBSQLMonitorHook.TRRollback(tr: TIBTransaction);
var
  st: String;
begin
  if FEnabled then
  begin
    if Assigned(tr.DefaultDatabase) and
       (tfTransact in (FTraceFlags * tr.DefaultDatabase.TraceFlags)) then
    begin
      st := tr.Name + ': [Rollback]'; {do not localize}
      WriteSQLData(st, tfTransact);
    end;
  end;
end;

procedure TIBSQLMonitorHook.TRRollbackRetaining(tr: TIBTransaction);
var
  st: String;
begin
  if FEnabled then
  begin
    if Assigned(tr.DefaultDatabase) and
       (tfTransact in (FTraceFlags * tr.DefaultDatabase.TraceFlags)) then
    begin
      st := tr.Name + ': [Rollback retaining (Soft rollback)]'; {do not localize}
      WriteSQLData(st, tfTransact);
    end;
  end;
end;

procedure TIBSQLMonitorHook.TRStart(tr: TIBTransaction);
var
  st: String;
begin
  if FEnabled then
  begin
    if Assigned(tr.DefaultDatabase) and
       (tfTransact in (FTraceFlags * tr.DefaultDatabase.TraceFlags)) then
    begin
      st := tr.Name + ': [Start transaction]'; {do not localize}
      WriteSQLData(st, tfTransact);
    end;
  end;
end;

procedure TIBSQLMonitorHook.UnregisterMonitor(SQLMonitor: TIBCustomSQLMonitor);
var
  Created : Boolean;
begin
  FReaderThread.RemoveMonitor(SQLMonitor);
  if FReaderThread.FMonitors.Count = 0 then
  begin
    FReaderThread.Terminate;

    { There is a possibility of a reader thread, but no writer one.
      When in that situation, the reader needs to be released after
      the terminate is set.  To do that, create a Writer thread, send
      the release code (a string of ' ' and type tfMisc) and then free
      it up. }
      
    Created := false;
    if not Assigned(FWriterThread) then
    begin
      FWriterThread := TWriterThread.Create;
      Created := true;
    end;
    FWriterThread.WriteSQLData(' ', tfMisc);
    FReaderThread.WaitFor;
    FreeAndNil(FReaderThread);
    if Created then
    begin
      FWriterThread.Terminate;
      FWriterThread.WaitFor;
      FreeAndNil(FWriterThread);
    end;
  end;
end;

procedure TIBSQLMonitorHook.WriteSQLData(Text: String;
  DataType: TTraceFlag);
begin
  if not FEventsCreated then
  try
    CreateEvents;
  except
    Enabled := false;
    Exit;
  end;
  EnterCriticalSection(CS);
  Text := CRLF + '[Application: ' + {DBApplication.Title +} ']' + CRLF + Text; {do not localize}
  LeaveCriticalSection(CS);
  if not Assigned(FWriterThread) then
    FWriterThread := TWriterThread.Create;
  FWriterThread.WriteSQLData(Text, DataType);
end;

{ TWriterThread }

constructor TWriterThread.Create;

begin
  inherited Create(true);
  FMsgs := TObjectList.Create(true);
  Resume;
end;

destructor TWriterThread.Destroy;
begin
  FMsgs.Free;
  inherited Destroy;
end;

procedure TWriterThread.Execute;
begin
  { Place thread code here }
  while ((not Terminated) and (not bDone)) or
        (FMsgs.Count <> 0) do
  begin
    { Any one listening? }
    if FMonitorCount^ = 0 then
    begin
      if FMsgs.Count <> 0 then
        FMsgs.Remove(FMsgs[0]);
      Sleep(50);
    end
    else
      { Anything to process? }
      if FMsgs.Count <> 0 then
      begin
       { If the current queued message is a release release the object }
        if FMsgs.Items[0] is TReleaseObject then
          PostMessage(TReleaseObject(FMsgs.Items[0]).FHandle, CM_RELEASE, 0, 0)
        else
        { Otherwise write the TraceObject to the buffer }
        begin
          WriteToBuffer;
        end;
      end
      else
        Sleep(50);
  end;
end;

procedure TWriterThread.Lock;
begin
  WaitForSingleObject(FWriteLock, INFINITE);
end;

procedure TWriterThread.Unlock;
begin
  ReleaseMutex(FWriteLock);
end;

procedure TWriterThread.WriteSQLData(Msg : String; DataType: TTraceFlag);
begin
  if FMonitorCount^ <> 0 then
    FMsgs.Add(TTraceObject.Create(Msg, DataType));
end;

procedure TWriterThread.BeginWrite;
begin
  Lock;
end;

procedure TWriterThread.EndWrite;
begin
  {
   * 1. Wait to end the write until all registered readers have
   *    started to wait for a write event
   * 2. Block all of those waiting for the write to finish.
   * 3. Block all of those waiting for all readers to finish.
   * 4. Unblock all readers waiting for a write event.
   * 5. Wait until all readers have finished reading.
   * 6. Now, block all those waiting for a write event.
   * 7. Unblock all readers waiting for a write to be finished.
   * 8. Unlock the mutex.
   }
  while WaitForSingleObject(FReadEvent, cDefaultTimeout) = WAIT_TIMEOUT do
  begin
    if FMonitorCount^ > 0 then
      InterlockedDecrement(FMonitorCount^);
    if (FReaderCount^ = FMonitorCount^ - 1) or (FMonitorCount^ = 0) then
      SetEvent(FReadEvent);
  end;
  ResetEvent(FWriteFinishedEvent);
  ResetEvent(FReadFinishedEvent);
  SetEvent(FWriteEvent); { Let all readers pass through. }
  while WaitForSingleObject(FReadFinishedEvent, cDefaultTimeout) = WAIT_TIMEOUT do
    if (FReaderCount^ = 0) or (InterlockedDecrement(FReaderCount^) = 0) then
      SetEvent(FReadFinishedEvent);
  ResetEvent(FWriteEvent);
  SetEvent(FWriteFinishedEvent);
  Unlock;
end;

procedure TWriterThread.WriteToBuffer;
var
  i, len: Integer;
  Text : String;
begin
  Lock;
  try
    { If there are no monitors throw out the message
      The alternative is to have messages queue up until a
      monitor is ready.}

    if FMonitorCount^ = 0 then
      FMsgs.Remove(FMsgs[0])
    else
    begin
      Text := TTraceObject(FMsgs[0]).FMsg;
      i := 1;
      len := Length(Text);
      while (len > 0) do begin
        BeginWrite;
        try
          FTraceDataType^ := Integer(TTraceObject(FMsgs[0]).FDataType);
          FTimeStamp^ := TTraceObject(FMsgs[0]).FTimeStamp;
          FBufferSize^ := Min(len, cMaxBufferSize);
          Move(Text[i], FBuffer[0], FBufferSize^);
          Inc(i, cMaxBufferSize);
          Dec(len, cMaxBufferSize);
        finally
          EndWrite;
        end;
      end;
      FMsgs.Remove(FMsgs[0]);
    end;
  finally
    Unlock;
  end;
end;

procedure TWriterThread.ReleaseMonitor(HWnd: THandle);
begin
  FMsgs.Add(TReleaseObject.Create(HWnd));
end;

{ TTraceObject }

constructor TTraceObject.Create(Msg : String; DataType: TTraceFlag);
begin
  FMsg := Msg;
  FDataType := DataType;
  FTimeStamp := Now;
end;

constructor TTraceObject.Create(obj: TTraceObject);
begin
  FMsg := obj.FMsg;
  FDataType := obj.FDataType;
  FTimeStamp := obj.FTimeStamp;
end;

{ TReleaseObject }

constructor TReleaseObject.Create(Handle: THandle);
begin
  FHandle := Handle;
end;

{ ReaderThread }

procedure TReaderThread.AddMonitor(Arg: TIBCustomSQLMonitor);
begin
  EnterCriticalSection(CS);
  if FMonitors.IndexOf(Arg) < 0 then
    FMonitors.Add(Arg);
  LeaveCriticalSection(CS);
end;

procedure TReaderThread.BeginRead;
begin
  {
   * 1. Wait for the "previous" write event to complete.
   * 2. Increment the number of readers.
   * 3. if the reader count is the number of interested readers, then
   *    inform the system that all readers are ready.
   * 4. Finally, wait for the FWriteEvent to signal.
   }
  WaitForSingleObject(FWriteFinishedEvent, INFINITE);
  InterlockedIncrement(FReaderCount^);
  if FReaderCount^ = FMonitorCount^ then
    SetEvent(FReadEvent);
  WaitForSingleObject(FWriteEvent, INFINITE);
end;

constructor TReaderThread.Create;
begin
  inherited Create(true);
  st := TTraceObject.Create('', tfMisc);
  FMonitors := TObjectList.Create(false);
  InterlockedIncrement(FMonitorCount^);
  Resume;
end;

destructor TReaderThread.Destroy;
begin
  if FMonitorCount^ > 0 then
    InterlockedDecrement(FMonitorCount^);
  FMonitors.Free;
  st.Free;
  inherited Destroy;
end;

procedure TReaderThread.EndRead;
begin
  if InterlockedDecrement(FReaderCount^) = 0 then
  begin
    ResetEvent(FReadEvent);
    SetEvent(FReadFinishedEvent);
  end;
end;

procedure TReaderThread.Execute;
var
  i : Integer;
  FTemp : TTraceObject;
begin
  { Place thread code here }
  while (not Terminated) and (not bDone) do
  begin
    ReadSQLData;
    if (st.FMsg <> '') and
       not ((st.FMsg = ' ') and (st.FDataType = tfMisc)) then
    begin
      for i := 0 to FMonitors.Count - 1 do
      begin
        FTemp := TTraceObject.Create(st);
        PostMessage(TIBCustomSQLMonitor(FMonitors[i]).Handle,
                    WM_IBSQL_SQL_EVENT,
                    0,
                    LPARAM(FTemp));
      end;
    end;
  end;
end;

procedure TReaderThread.ReadSQLData;
begin
  st.FMsg := '';
  BeginRead;
  if not bDone then
  try
    SetString(st.FMsg, FBuffer, FBufferSize^);
    st.FDataType := TTraceFlag(FTraceDataType^);
    st.FTimeStamp := TDateTime(FTimeStamp^);
  finally
    EndRead;
  end;
end;

procedure TReaderThread.RemoveMonitor(Arg: TIBCustomSQLMonitor);
begin
  EnterCriticalSection(CS);
  FMonitors.Remove(Arg);
  LeaveCriticalSection(CS);
end;

{ Misc methods }

function MonitorHook: IIBSQLMonitorHook;
begin
  if (_MonitorHook = nil) and (not bDone) then
  begin
    EnterCriticalSection(CS);
    if (_MonitorHook = nil) and (not bDone) then
    begin
      _MonitorHook := TIBSQLMonitorHook.Create;
      _MonitorHook._AddRef;
    end;
    LeaveCriticalSection(CS);
  end;
  result := _MonitorHook;
end;

procedure EnableMonitoring;
begin
  MonitorHook.Enabled := True;
end;

procedure DisableMonitoring;
begin
  MonitorHook.Enabled := False;
end;

function MonitoringEnabled: Boolean;
begin
  result := MonitorHook.Enabled;
end;

procedure CloseThreads;
begin
  if Assigned(FReaderThread) then
  begin
    FReaderThread.Terminate;
    FReaderThread.WaitFor;
    FreeAndNil(FReaderThread);
  end;
  if Assigned(FWriterThread) then
  begin
    FWriterThread.Terminate;
    FWriterThread.WaitFor;
    FreeAndNil(FWriterThread);
  end;
end;

initialization
  InitializeCriticalSection(CS);
  _MonitorHook := nil;
  FWriterThread := nil;
  FReaderThread := nil;
  bDone := False;

finalization
  try
    bDone := True;
    if Assigned(FReaderThread) then
    begin
      if not Assigned(FWriterThread) then
        FWriterThread := TWriterThread.Create;
      FWriterThread.WriteSQLData(' ', tfMisc);
    end;
    CloseThreads;
    if Assigned(_MonitorHook) then
      _MonitorHook._Release;
  finally
    _MonitorHook := nil;
    DeleteCriticalSection(CS);
  end;
end.
