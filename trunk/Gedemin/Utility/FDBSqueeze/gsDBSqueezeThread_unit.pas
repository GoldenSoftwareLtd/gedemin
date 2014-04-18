unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  MAX_PROGRESS_STEP = 12500;
  PROGRESS_STEP = MAX_PROGRESS_STEP div 100;

  WM_DBS_STARTTESTCONNECT      = WM_USER + 1;
  WM_DBS_GETINFOTESTCONNECT    = WM_USER + 2;
  WM_DBS_STOPTESTCONNECT       = WM_USER + 3;
  WM_DBS_SETPARAMS             = WM_USER + 4;
  WM_DBS_GETDBSIZE             = WM_USER + 5;
  WM_DBS_CONNECT               = WM_USER + 6;
  WM_DBS_CREATEDBSSTATEJOURNAL = WM_USER + 7;
  WM_DBS_SETCBBITEMS           = WM_USER + 8;
  WM_DBS_SETDOCTYPESRINGS      = WM_USER + 9;
  WM_DBS_GETDBPROPERTIES       = WM_USER + 10;
  WM_DBS_SETCLOSINGDATE        = WM_USER + 11;
  WM_DBS_SETCOMPANYKEY         = WM_USER + 12;
  WM_DBS_SETSALDOPARAMS        = WM_USER + 13;
  WM_DBS_SETSELECTEDDOCTYPES   = WM_USER + 14;
  WM_DBS_SETOPTIONS            = WM_USER + 15;
  WM_DBS_GETSTATISTICS         = WM_USER + 16;
  WM_DBS_GETPROCSTATISTICS     = WM_USER + 17;
  WM_DBS_STARTPROCESSING       = WM_USER + 18;
  WM_DBS_STOPPROCESSING        = WM_USER + 19;
  WM_DBS_RECONNECT             = WM_USER + 20;
  WM_DBS_SETFVARIABLLES        = WM_USER + 21;
  WM_DBS_CREATEMETADATA        = WM_USER + 22;
  WM_DBS_SAVEMETADATA          = WM_USER + 23;
  WM_DBS_CALCULATEACSALDO      = WM_USER + 24;
  WM_DBS_CALCULATEINVSALDO     = WM_USER + 25;
  WM_DBS_PREPAREREBINDINVCARDS = WM_USER + 26;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_USER + 27;
  WM_DBS_PREPAREDB             = WM_USER + 28;
  WM_DBS_DELETEOLDBALANCE      = WM_USER + 29;
  WM_DBS_DELETEDOCHIS          = WM_USER + 30;
  WM_DBS_CREATEACENTRIES       = WM_USER + 31;
  WM_DBS_CREATEINVSALDO        = WM_USER + 32;
  WM_DBS_RESTOREDB             = WM_USER + 33;
  WM_DBS_REBINDINVCARDS        = WM_USER + 34;
  WM_DBS_CLEARDBSTABLES        = WM_USER + 35;
  WM_DBS_BACKUPDATABASE        = WM_USER + 36;
  WM_DBS_RESTOREBK             = WM_USER + 37;
  WM_DBS_FINISH                = WM_USER + 38;
  WM_DBS_FINISHED              = WM_USER + 39;
  WM_DBS_DISCONNECT            = WM_USER + 40;

  WM_DBS_CREATE_INV_BALANCE    = WM_USER + 41;

  WM_GD_EXIT_THREAD            = WM_USER + 117;
type
  TErrorEvent = procedure(const ErrorMsg: String) of object;
  TLogSQLEvent = procedure(const MsgLogSQL: String)of object;
  TGetConnectedEvent = procedure(const MsgConnected: Boolean) of object;
  TGetInfoTestConnectEvent = procedure(const MsgConnectSuccess: Boolean; const MsgConnectInfoList: TStringList) of object;
  TUsedDBEvent =  procedure(const MsgFunctionKey: Integer; const MsgState: Integer; const MsgCallTime: String; const MsgErrorMessage: String) of object;
  TGetDBPropertiesEvent = procedure(const MsgPropertiesList: TStringList) of object;
  TCbbEvent = procedure (const MsgStrList: TStringList) of object;
  TSetDocTypeStringsEvent = procedure (const MsgDocTypeList: TStringList) of object;
  TSetDocTypeBranchEvent = procedure (const MsgBranchList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String; const MsgInvCardStr: String) of object;
  TGetProcStatisticsEvent = procedure (const MsgProcGdDocStr: String; const MsgProcAcEntryStr: String; const MsgProcInvMovementStr: String; const MsgProcInvCardStr: String) of object;
  TFinishEvent = procedure (const MsgIsFinished: Boolean) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FDoGetStatisticsAfterProc: Boolean;
    FDoStopProcessing: Boolean;    ///////////////
    FFinish: Boolean;
    FBusy: TidThreadSafeInteger;
    FIsFinishMsg: TidThreadSafeInteger;
    FLogFileName: TidThreadSafeString;
    FBackupFileName: TidThreadSafeString;
    FRestoreDBName: TidThreadSafeString;
    FSaveLog, FCreateBackup: Boolean;
    FContinueReprocess: Boolean;
    FCompanyKey: Integer;

    FDocTypesList: TStringList;
    FIsProcDocTypes: Boolean;

    FConnectInfo: TgsDBConnectInfo;
    FDBSize: Int64;

    FClosingDate: TDateTime;
    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;
    FAccount00: Boolean;
    FCalculateSaldo: Boolean;

    FDBS: TgsDBSqueeze;

    FConnected: TidThreadSafeInteger;  ///
    FState: TidThreadSafeInteger;

    FMsgLogSQL: String;

    FMsgConnected: Boolean;

    FMsgConnectSuccess: Boolean;
    FMsgConnectInfoList: TStringList;

    FMessageFunctionKey: Integer;
    FMessageState: Integer;
    FMessageCallTime: String;
    FMessageErrorMessage: String;

    //FMessageConnected: Boolean;
    FMessagePropertiesList: TStringList;
    FMessageStrList: TStringList;
    FMessageDocTypeList: TStringList;
    FMessageDocTypeBranchList: TStringList;
    FMessageDBSizeStr: String;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr, FMessageInvCardStr: String;
    FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr: String;

    FOnFinish: TFinishEvent;
    FOnLogSQL: TLogSQLEvent;
    FOnGetConnected: TGetConnectedEvent;
    FOnGetInfoTestConnect: TGetInfoTestConnectEvent;
    FOnUsedDB: TUsedDBEvent;
    FOnGetDBProperties: TGetDBPropertiesEvent;
    FOnSetItemsCbb: TCbbEvent;
    FOnSetDocTypeStrings: TSetDocTypeStringsEvent;
    FOnSetDocTypeBranch: TSetDocTypeBranchEvent;
    FOnGetDBSize: TGetDBSizeEvent;
    FOnGetStatistics: TGetStatisticsEvent;
    FOnGetProcStatistics: TGetProcStatisticsEvent;

    procedure DoOnFinishSync;
    procedure DoOnLogSQLSync;
    procedure DoOnGetConnectedSync;
    procedure DoOnGetInfoTestConnectSync;
    procedure DoOnUsedDBSync;
    procedure DoOnGetDBPropertiesSync;
    procedure DoOnSetItemsCbbSync;
    procedure DoOnSetDocTypeStringsSync;
    procedure DoOnSetDocTypeBranchSync;
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;
    procedure DoOnGetProcStatisticsSync;

    procedure Finish(const AIsFinished: Boolean);

    procedure LogSQL(const AMsgLogSQL: String);
    procedure GetConnected(const AMsgConnected: Boolean);
    procedure GetInfoTestConnect(const AMsgConnectSuccess: Boolean; const AMsgConnectInfoList: TStringList);
    procedure UsedDB(const AMessageFunctionKey: Integer;const AMessageState: Integer;
      const AMessageCallTime: String; const AMessageErrorMessage: String);
    procedure GetDBProperties(const AMessageProperties: TStringList);
    procedure SetItemsCbb(const AMessageStrList: TStringList);
    procedure SetDocTypeStrings(const AMessageDocTypeList: TStringList);
    procedure SetDocTypeBranch(const AMessageBranchList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String; const ADBSize: Int64);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String; const AMessageInvCardStr: String);
    procedure GetProcStatistics(const AMessageProcGdDocStr: String; const AMessageProcAcEntryStr: String; const AMessageProcInvMovementStr: String; const AMessageProcInvCardStr: String);

    function GetBusy: Boolean;
    function GetState: Boolean;
  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure StartTestConnect(const ADatabaseName: String; const AHost: String; const AUserName: String; const APassword: String; const ACharacterSet: String; const APort: Integer = 0);
    procedure StopTestConnect;

    procedure StartProcessing;
    procedure StopProcessing;

    //procedure DoGetConnected;
    procedure DoGetInfoTestConnect;
    procedure DoGetDBProperties;
    procedure DoSetItemsCbb;
    procedure DoSetDocTypeStrings;
    procedure DoGetDBSize;
    procedure DoGetStatistics;
    procedure DoGetProcStatistics;

    //procedure ContinueProcessing(const AFunctionKey: Integer; const AState: Integer);

    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const AnAccount00: Boolean; const ACalculateSaldo: Boolean);
    procedure SetCompanyKey(const ACompanyKey: Integer);
    procedure SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);
    procedure SetDBParams(const ADatabaseName: String; const AHost: String; const AUserName: String; const APassword: String; const ACharacterSet: String; const APort: Integer = 0);
    procedure SetClosingDate(const AClosingDate: TDateTime);
    procedure SetOptions(const ASaveLog: Boolean; const ACreateBackup: Boolean; const ALogFileName: String; const ABackupFileName: String; const ARestoreDBName: String; const AContinueReprocess: Boolean);
    //function GetConnected: Boolean;

    //property Connected: Boolean read GetConnected;
    property State: Boolean read GetState;
    property Busy: Boolean  read GetBusy;
    property DBSize: Int64  read FDBSize;
    property DoGetStatisticsAfterProc: Boolean read FDoGetStatisticsAfterProc write FDoGetStatisticsAfterProc;

    property OnFinishEvent: TFinishEvent
      read FOnFinish             write FOnFinish;
    property OnLogSQL: TLogSQLEvent
      read FOnLogSQL             write FOnLogSQL;
    property OnGetConnected: TGetConnectedEvent
      read FOnGetConnected       write FOnGetConnected;
    property OnGetInfoTestConnect: TGetInfoTestConnectEvent
      read FOnGetInfoTestConnect write FOnGetInfoTestConnect;
    property OnUsedDB: TUsedDBEvent
      read FOnUsedDB             write FOnUsedDB;
    property OnGetDBProperties: TGetDBPropertiesEvent
      read FOnGetDBProperties    write FOnGetDBProperties;
    property OnSetItemsCbb: TCbbEvent
      read FOnSetItemsCbb        write FOnSetItemsCbb;
    property OnSetDocTypeStrings: TSetDocTypeStringsEvent
      read FOnSetDocTypeStrings  write FOnSetDocTypeStrings;
    property OnSetDocTypeBranch: TSetDocTypeBranchEvent
      read FOnSetDocTypeBranch   write FOnSetDocTypeBranch;
    property OnGetDBSize: TGetDBSizeEvent
      read FOnGetDBSize          write FOnGetDBSize;
    property OnGetStatistics: TGetStatisticsEvent
      read FOnGetStatistics      write FOnGetStatistics;
    property OnGetProcStatistics: TGetProcStatisticsEvent
      read FOnGetProcStatistics  write FOnGetProcStatistics;
  end;

implementation

{ TgsDBSqueezeThread }

constructor TgsDBSqueezeThread.Create(const CreateSuspended: Boolean);
begin
  FDBS := TgsDBSqueeze.Create;
  FDBS.OnProgressWatch := DoOnProgressWatch;
  FDBS.OnLogSQLEvent := LogSQL;
  FDBS.OnGetConnectedEvent := GetConnected;
  FDBS.OnUsedDBEvent := UsedDB;
  FDBS.OnGetInfoTestConnectEvent := GetInfoTestConnect;
  FDBS.OnGetDBPropertiesEvent := GetDBProperties;
  FDBS.OnSetItemsCbbEvent := SetItemsCbb;
  FDBS.OnSetDocTypeStringsEvent := SetDocTypeStrings;
  FDBS.OnSetDocTypeBranchEvent := SetDocTypeBranch;
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FDBS.OnGetProcStatistics := GetProcStatistics;
  FDocTypesList :=  TStringList.Create;
  FLogFileName := TIdThreadSafeString.Create;
  FBackupFileName := TIdThreadSafeString.Create;
  FRestoreDBName := TIdThreadSafeString.Create;
  FIsFinishMsg := TIdThreadSafeInteger.Create;
  FBusy := TIdThreadSafeInteger.Create;
  FState := TIdThreadSafeInteger.Create;
  FConnected := TIdThreadSafeInteger.Create;
  FMsgConnectInfoList := TStringList.Create;
  FMessageStrList := TStringList.Create;
  FMessageDocTypeList := TStringList.Create;
  FMessageDocTypeBranchList := TStringList.Create;
  FMessagePropertiesList := TStringList.Create;
  FState.Value := 1;
  FBusy.Value := 0;
  FIsFinishMsg.Value := 0;
  FFinish := False;
  
  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FDocTypesList.Free;
  FLogFileName.Free;
  FBackupFileName.Free;
  FRestoreDBName.Free;
  FBusy.Free;
  FState.Free;
  FConnected.Free;
  FMsgConnectInfoList.Free;
  FMessageStrList.Free;
  FMessageDocTypeList.Free;
  FMessageDocTypeBranchList.Free;
  FMessagePropertiesList.Free;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  PostMsg(WM_DBS_GETDBSIZE);//PostMsg(WM_DBS_CONNECT);
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  PostMsg(WM_DBS_DISCONNECT);
end;

procedure TgsDBSqueezeThread.StartProcessing;
begin
  PostMsg(WM_DBS_STARTPROCESSING);
end;

procedure TgsDBSqueezeThread.StopProcessing;
begin
  FDoStopProcessing := True;
  FDBS.DoStopProcessing  := True;                                                /////////////////////  CS
  PostMsg(WM_DBS_STOPPROCESSING);
end;

procedure  TgsDBSqueezeThread.DoOnGetConnectedSync;
begin
  if Assigned(FOnGetConnected) then
    FOnGetConnected(FMsgConnected);
end;

procedure  TgsDBSqueezeThread.GetConnected(const AMsgConnected: Boolean);
begin
  FMsgConnected := AMsgConnected;
  Synchronize(DoOnGetConnectedSync);
end;

procedure TgsDBSqueezeThread.DoOnGetInfoTestConnectSync;
begin
  if Assigned(FOnGetInfoTestConnect) and Assigned(FMsgConnectInfoList) then
    FOnGetInfoTestConnect(FMsgConnectSuccess, FMsgConnectInfoList)
  else
    FOnGetInfoTestConnect(FMsgConnectSuccess, nil);
end;

procedure TgsDBSqueezeThread.GetInfoTestConnect(const AMsgConnectSuccess: Boolean; const AMsgConnectInfoList: TStringList);
begin
  FMsgConnectSuccess := AMsgConnectSuccess;
  if AMsgConnectInfoList <> nil then
    FMsgConnectInfoList.Text := AMsgConnectInfoList.Text;
  Synchronize(DoOnGetInfoTestConnectSync);
end;

procedure TgsDBSqueezeThread.DoOnSetItemsCbbSync;
begin
  if Assigned(FOnSetItemsCbb) then
    FOnSetItemsCbb(FMessageStrList);
end;

procedure TgsDBSqueezeThread.DoOnSetDocTypeStringsSync;
begin
  if Assigned(FOnSetDocTypeStrings) then
    FOnSetDocTypeStrings(FMessageDocTypeList);
end;

procedure TgsDBSqueezeThread.DoOnSetDocTypeBranchSync;
begin
  if Assigned(FOnSetDocTypeBranch) then
    FOnSetDocTypeBranch(FMessageDocTypeBranchList);
end;

procedure TgsDBSqueezeThread.DoOnUsedDBSync;
begin
  if Assigned(FOnUsedDB) then
    FOnUsedDB(FMessageFunctionKey, FMessageState, FMessageCallTime,  FMessageErrorMessage);
end;

procedure TgsDBSqueezeThread.Finish(const AIsFinished: Boolean);
begin
  if AIsFinished then
    FIsFinishMsg.Value := 1
  else
    FIsFinishMsg.Value := 0;
  Synchronize(DoOnFinishSync);
end;

procedure TgsDBSqueezeThread.DoOnFinishSync;
begin
  if Assigned(FOnFinish) then
    FOnFinish(FFinish);//FOnFinish(FIsFinishMsg.Value);
end;

procedure TgsDBSqueezeThread.DoOnGetDBPropertiesSync;
begin
  if Assigned(FOnGetDBProperties) then
    FOnGetDBProperties(FMessagePropertiesList);
end;

procedure TgsDBSqueezeThread.DoOnGetDBSizeSync;
begin
  if Assigned(FOnGetDBSize) then
    FOnGetDBSize(FMessageDBSizeStr);
end;

procedure TgsDBSqueezeThread.DoOnGetStatisticsSync;
begin
  if Assigned(FOnGetStatistics) then
    FOnGetStatistics(FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr, FMessageInvCardStr);
  FBusy.Value := 0;
end;

procedure TgsDBSqueezeThread.DoOnGetProcStatisticsSync;
begin
  if Assigned(FOnGetProcStatistics) then
    FOnGetProcStatistics(FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr);
  FBusy.Value := 0; 
end;

function TgsDBSqueezeThread.GetBusy: Boolean;
begin
  Result := FBusy.Value <> 0;
end;

function TgsDBSqueezeThread.GetState: Boolean;
begin
  Result := FState.Value <> 0;
end;

function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := False;
 try
  case Msg.Message of
    WM_DBS_STARTTESTCONNECT:
      begin
        FDBS.LogEvent('Testing connection...');

        FDBS.ConnectInfo := FConnectInfo;

        try
          FDBS.Connect(False, True);        // garbage collect ON
        except
          on E: Exception do
          begin
            FDBS.ErrorEvent('Testing connecting as having failed: ' + #13#10 + E.Message);
            GetInfoTestConnect(False, nil);
            FDBS.LogEvent('Testing connection... OK');
          end;
        end;
        FState.Value := 1;

        PostThreadMessage(ThreadID, WM_DBS_GETINFOTESTCONNECT, 0, 0);
        Result := True;
      end;

    WM_DBS_GETINFOTESTCONNECT:
      begin
        FDBS.GetInfoTestConnectEvent;
        FState.Value := 1;

        PostThreadMessage(ThreadID, WM_DBS_STOPTESTCONNECT, 0, 0);
        Result := True;
      end;

    WM_DBS_STOPTESTCONNECT:
      begin
        if FState.Value = 1 then
          FDBS.Disconnect;
        ZeroMemory(@(FDBS.ConnectInfo),SizeOf(FDBS.ConnectInfo));

        FDBS.LogEvent('Testing connection... OK');
        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_SETPARAMS:
      begin
        FDBS.ConnectInfo := FConnectInfo;

        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_GETDBSIZE:
      begin
        FDBS.GetDBSizeEvent;
        FState.Value := 1;

        //if FFinish then
          PostThreadMessage(ThreadID, WM_DBS_CONNECT, 0, 0);

        Result := True;
      end;

    WM_DBS_CONNECT:
      begin
        FDBS.Connect(False, True);        // garbage collect ON
        FState.Value := 1;

       {if not FFinish then    }
          PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0);
        {else
          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);   }

        Result := True;
      end;

    WM_DBS_CREATEDBSSTATEJOURNAL:
      begin
        FDBS.CreateDBSStateJournal;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        PostThreadMessage(ThreadID, WM_DBS_SETCBBITEMS, 0, 0);
        Result := True;
      end;

    WM_DBS_SETCBBITEMS:
      begin
        FDBS.SetItemsCbbEvent;

        PostThreadMessage(ThreadID, WM_DBS_GETDBPROPERTIES, 0, 0);
        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_SETDOCTYPESRINGS:
      begin
        FDBS.SetDocTypeStringsEvent;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_GETDBPROPERTIES:
      begin
        FDBS.GetDBPropertiesEvent;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_SETCLOSINGDATE:
      begin
        FDBS.ClosingDate := FClosingDate;
        Result := True;
      end;

    WM_DBS_SETCOMPANYKEY:
      begin
        FDBS.CompanyKey := FCompanyKey;
        Result := True;
      end;

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
        FDBS.OnlyCompanySaldo := FOnlyCompanySaldo;
        FDBS.DoAccount00Saldo := FAccount00;
        FDBS.CalculateSaldo := FCalculateSaldo;

        Result := True;
      end;

    WM_DBS_SETSELECTEDDOCTYPES:
      begin
        FDBS.DocTypesList := FDocTypesList;
        FDBS.DoProcDocTypes := FIsProcDocTypes;

        Result := True;
      end;

    WM_DBS_SETOPTIONS:
      begin
        FDBS.SaveLog := FCreateBackup;
        FDBS.CreateBackup := FCreateBackup;
        FDBS.LogFileName := FLogFileName.Value;
        FDBS.BackupFileName := FBackupFileName.Value;
        FDBS.RestoreDBName := FRestoreDBName.Value;

        Result := True;
      end;

    WM_DBS_GETSTATISTICS:
      begin
        FBusy.Value := 1;
        FDBS.GetStatisticsEvent;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        
        FState.Value := 1;
        PostThreadMessage(ThreadID, WM_DBS_GETPROCSTATISTICS, 0, 0);
        Result := True;
      end;

    WM_DBS_GETPROCSTATISTICS:
      begin
        FBusy.Value := 1;
        FDBS.GetProcStatisticsEvent;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_STARTPROCESSING:
      begin
        if not FDoStopProcessing then
        begin
          FBusy.Value := 1;

          if FDoGetStatisticsAfterProc then
          begin
            FDBS.GetStatisticsEvent;
            FDBS.GetProcStatisticsEvent;
          end;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;
          PostThreadMessage(ThreadID, WM_DBS_SETFVARIABLLES, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_STOPPROCESSING:
      begin
        FDBS.LogEvent('STOP');
        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FFinish:= False;

        Finish(FFinish);     // форма начинает ждать завершения

        //MyEvent.ResetEvent;
        //PostMessage(FWindowHandle, WM_MYMESSAGE, 0, 0);
        //MyEvent.WaitFor(0);

        FState.Value := 1;
        PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);
        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FBusy.Value := 0;

        PostThreadMessage(ThreadID, WM_GD_EXIT_THREAD, 0, 0);
        Result := True;
      end;  

    WM_DBS_SETFVARIABLLES:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Инициализация...', 0);                                         // 1%
          FDBS.SetFVariables;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEMETADATA, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEMETADATA:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Создание таблиц для метаданных...', 1*PROGRESS_STEP);          // 1%
          FDBS.CreateMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_SAVEMETADATA, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_SAVEMETADATA:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Получение метаданных... ', 1*PROGRESS_STEP);                   // 1%
          FDBS.SaveMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEACSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CALCULATEACSALDO:
      begin
        if not FDoStopProcessing then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Вычисление бухгалтерского сальдо...', 1*PROGRESS_STEP);        // 7%
            FDBS.CalculateAcSaldo;

            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 1*PROGRESS_STEP);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEINVSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CALCULATEINVSALDO:
      begin
        if not FDoStopProcessing then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Вычисление складского сальдо...', 7*PROGRESS_STEP);            // 7%
            FDBS.CalculateInvSaldo;
            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else begin
            FDBS.ProgressMsgEvent(' ', 14*PROGRESS_STEP);
          end;
          
          FState.Value := 1;
          PostThreadMessage(ThreadID, WM_DBS_CREATEHIS_INCLUDEHIS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEHIS_INCLUDEHIS:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Выявление записей, которые должны остаться...', 0);            // 16%
          FDBS.CreateHIS_IncludeInHIS;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_PREPAREDB:
      begin
        if not FDoStopProcessing then
        begin
          //FDBS.Reconnect(True, True);    // garbage collect OFF
          FDBS.ProgressMsgEvent('Подготовка БД к удалению записей...', 0);                        // 3%
          FDBS.PrepareDB;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEOLDBALANCE, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_DELETEOLDBALANCE:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Очистка от неактуальных данных...', 0);                          // 2%
          FDBS.DeleteOldAcEntryBalance;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEDOCHIS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_DELETEDOCHIS:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Удаление записей...', 2*PROGRESS_STEP);                          // 8%
          FDBS.DeleteDocuments_DeleteHIS;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEACENTRIES, 0, 0);
        end;  
        Result := True;
      end;

    WM_DBS_CREATEACENTRIES:
      begin
        if not FDoStopProcessing then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Сохранение бухгалтерского сальдо...', 8*PROGRESS_STEP);          // 7%
            FDBS.CreateAcEntries;
            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 8*PROGRESS_STEP);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEINVSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEINVSALDO:
      begin
        if not FDoStopProcessing then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Сохранение складского сальдо...', 0);                           // 7%
            FDBS.CreateInvSaldo;

            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 7*PROGRESS_STEP);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_RESTOREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_RESTOREDB:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Восстановление БД...', 0);                                       // 28%
          FDBS.RestoreDB;
          //FDBS.Reconnect(False, True);

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATE_INV_BALANCE, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATE_INV_BALANCE:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.CreateInvBalance;
          FDBS.ProgressMsgEvent('Вычисление текущих складских остатков...', 0);                    // 2%
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CLEARDBSTABLES, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CLEARDBSTABLES:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.ProgressMsgEvent('Удаление метаданных...', 2*PROGRESS_STEP);                        // 1%
          FDBS.DeleteDBSTables;

          if FDoGetStatisticsAfterProc and (not FDoStopProcessing) then
          begin
            FDBS.GetStatisticsEvent;
            FDBS.GetProcStatisticsEvent;
          end;

          //FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          FDBS.ProgressMsgEvent('', 1*PROGRESS_STEP);
          PostThreadMessage(ThreadID, WM_DBS_BACKUPDATABASE, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_BACKUPDATABASE:
      begin
        if not FDoStopProcessing then
        begin
          if FBackupFileName.Value <> '' then
          begin
            FDBS.ProgressMsgEvent('Создание backup-файла...', 0);                                 // 3%
            FDBS.BackupDatabase;
          end;
          FState.Value := 1;

          FDBS.ProgressMsgEvent('', 3*PROGRESS_STEP);
          PostThreadMessage(ThreadID, WM_DBS_RESTOREBK, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_RESTOREBK:
      begin
        if not FDoStopProcessing then
        begin
          if FRestoreDBName.Value <> '' then
          begin
            FDBS.ProgressMsgEvent('Восcтановление БД из backup-файла...', 0);                     // 6%
            FDBS.RestoreDatabaseFromBackup;
          end;
          FState.Value := 1;

          FDBS.ProgressMsgEvent('', 6*PROGRESS_STEP);
          PostThreadMessage(ThreadID, WM_DBS_FINISH, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_FINISH:
      begin
        if not FDoStopProcessing then
        begin
          FDBS.GetDBSizeEvent;
          FDBS.LogEvent('FINISH!');
          FDBS.ProgressMsgEvent('Обработка БД завершена.');
          
          FFinish:= True;
          Finish(FFinish);

          FBusy.Value := 0;
        end;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin
        FDBS.Disconnect;
        FConnected.Value := 0;

        FState.Value := 1;
        Result := True;
      end;
  else
    Result := False;
  end;
 //end;
 except
  on E: Exception do
  begin
    FDBS.ErrorEvent(E.Message);
    //сохранить ошибку в базу

    FState.Value := 0;
  end;
 end;
end;

procedure  TgsDBSqueezeThread.StartTestConnect(
  const ADatabaseName: String;
  const AHost: String;
  const AUserName: String;
  const APassword: String;
  const ACharacterSet: String;
  const APort: Integer = 0);
begin
  FConnectInfo.DatabaseName := ADatabaseName;
  FConnectInfo.Host := AHost;
  FConnectInfo.UserName := AUserName;
  FConnectInfo.Password := APassword;
  FConnectInfo.CharacterSet := ACharacterSet;
  FConnectInfo.Port := APort;

  PostMsg(WM_DBS_STARTTESTCONNECT);
end;

procedure TgsDBSqueezeThread.StopTestConnect;
begin
  ZeroMemory(@FConnectInfo, SizeOf(FDBS.ConnectInfo));

  PostMsg(WM_DBS_STOPTESTCONNECT);
end;

procedure TgsDBSqueezeThread.SetCompanyKey(const ACompanyKey: Integer);
begin
  FCompanyKey := ACompanyKey;
  PostMsg(WM_DBS_SETCOMPANYKEY);
end;

procedure TgsDBSqueezeThread.SetDBParams(
  const ADatabaseName: String;
  const AHost: String;
  const AUserName: String;
  const APassword: String;
  const ACharacterSet: String;
  const APort: Integer = 0);
begin
  FConnectInfo.DatabaseName := ADatabaseName;
  FConnectInfo.Host := AHost;
  FConnectInfo.UserName := AUserName;
  FConnectInfo.Password := APassword;
  FConnectInfo.CharacterSet := ACharacterSet;
  FConnectInfo.Port := APort;

  PostMsg(WM_DBS_SETPARAMS);
end;

procedure TgsDBSqueezeThread.SetClosingDate(const AClosingDate: TDateTime);
begin
  FClosingDate := AClosingDate;
  PostMsg(WM_DBS_SETCLOSINGDATE);
end;

procedure  TgsDBSqueezeThread.SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const AnAccount00: Boolean; const ACalculateSaldo: Boolean);
begin
  FAllOurCompaniesSaldo := AAllOurCompanies;
  FOnlyCompanySaldo := AOnlyCompany;
  FAccount00 := AnAccount00;
  FCalculateSaldo := ACalculateSaldo;
  PostMsg(WM_DBS_SETSALDOPARAMS);
end;

procedure TgsDBSqueezeThread.SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);
begin
  FDocTypesList.Text := ADocTypes.Text;
  FIsProcDocTypes := AnIsProcDocTypes;
  PostMsg(WM_DBS_SETSELECTEDDOCTYPES);
end;

procedure TgsDBSqueezeThread.SetOptions(
  const ASaveLog: Boolean;
  const ACreateBackup: Boolean;
  const ALogFileName: String;
  const ABackupFileName: String;
  const ARestoreDBName: String;
  const AContinueReprocess: Boolean);
begin
  FSaveLog := ASaveLog;
  FCreateBackup:= ACreateBackup;
  FLogFileName.Value := ALogFileName;
  FBackupFileName.Value := ABackupFileName;
  FRestoreDBName.Value := ARestoreDBName;
  FContinueReprocess := AContinueReprocess;
  PostMsg(WM_DBS_SETOPTIONS);
end;

procedure TgsDBSqueezeThread.DoGetInfoTestConnect;
begin
  PostMsg(WM_DBS_GETINFOTESTCONNECT);
end;

procedure TgsDBSqueezeThread.DoSetItemsCbb;
begin
  PostMsg(WM_DBS_SETCBBITEMS);
end;

procedure TgsDBSqueezeThread.SetItemsCbb(const AMessageStrList: TStringList);
begin
  FMessageStrList.Text := AMessageStrList.Text;
  Synchronize(DoOnSetItemsCbbSync);
end;

procedure TgsDBSqueezeThread.DoSetDocTypeStrings;
begin
  PostMsg(WM_DBS_SETDOCTYPESRINGS);
end;

procedure TgsDBSqueezeThread.SetDocTypeStrings(const AMessageDocTypeList: TStringList);
begin
  FMessageDoctypeList.Text := AMessageDocTypeList.Text;
  Synchronize(DoOnSetDocTypeStringsSync);
end;

procedure TgsDBSqueezeThread.SetDocTypeBranch(const AMessageBranchList: TStringList);
begin
  FMessageDocTypeBranchList.Text := AMessageBranchList.Text;
  Synchronize(DoOnSetDocTypeBranchSync);
end;

procedure TgsDBSqueezeThread.UsedDB(const AMessageFunctionKey: Integer; const AMessageState: Integer;
  const AMessageCallTime: String; const AMessageErrorMessage: String);
begin
  FMessageFunctionKey := AMessageFunctionKey;
  FMessageState := AMessageState;
  FMessageCallTime := AMessageCallTime;
  FMessageErrorMessage :=  AMessageErrorMessage;
  Synchronize(DoOnUsedDBSync);
end;

procedure TgsDBSqueezeThread.DoGetDBProperties;
begin
  PostMsg(WM_DBS_GETDBPROPERTIES);
end;

procedure TgsDBSqueezeThread.GetDBProperties(const AMessageProperties: TStringList);
begin
  FMessagePropertiesList.Text := AMessageProperties.Text;
  Synchronize(DoOnGetDBPropertiesSync);
end;

procedure TgsDBSqueezeThread.DoGetDBSize;
begin
  PostMsg(WM_DBS_GETDBSIZE);
end;

procedure TgsDBSqueezeThread.GetDBSize(const AMessageDBSizeStr: String; const ADBSize: Int64);
begin
  FDBSize := ADBSize;
  FMessageDBSizeStr := AMessageDBSizeStr;
  Synchronize(DoOnGetDBSizeSync);
end;

procedure TgsDBSqueezeThread.DoGetStatistics;
begin
  PostMsg(WM_DBS_GETSTATISTICS);
end;

procedure TgsDBSqueezeThread.GetStatistics(
  const AMessageGdDocStr: String;
  const AMessageAcEntryStr: String;
  const AMessageInvMovementStr: String;
  const AMessageInvCardStr: String);
begin
  FMessageGdDocStr := AMessageGdDocStr;
  FMessageAcEntryStr := AMessageAcEntryStr;
  FMessageInvMovementStr := AMessageInvMovementStr;
  FMessageInvCardStr := AMessageInvCardStr;
  Synchronize(DoOnGetStatisticsSync);
end;

procedure TgsDBSqueezeThread.DoGetProcStatistics;
begin
  PostMsg(WM_DBS_GETPROCSTATISTICS);
end;

procedure TgsDBSqueezeThread.GetProcStatistics(
  const AMessageProcGdDocStr: String;
  const AMessageProcAcEntryStr: String;
  const AMessageProcInvMovementStr: String;
  const AMessageProcInvCardStr: String);
begin
  FMessageProcGdDocStr := AMessageProcGdDocStr;
  FMessageProcAcEntryStr := AMessageProcAcEntryStr;
  FMessageProcInvMovementStr := AMessageProcInvMovementStr;
  FMessageProcInvCardStr := AMessageProcInvCardStr;
  Synchronize(DoOnGetProcStatisticsSync);
end;

procedure  TgsDBSqueezeThread.DoOnLogSQLSync;
begin
  if Assigned(FOnLogSQL) then
    FOnLogSQL(FMsgLogSQL);
end;

procedure TgsDBSqueezeThread.LogSQL(const AMsgLogSQL: String);
begin
  FMsgLogSQL := AMsgLogSQL;
  Synchronize(DoOnlogSQLSync);
end;


end.
