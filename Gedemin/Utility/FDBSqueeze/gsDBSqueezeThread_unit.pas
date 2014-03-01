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

type
  TErrorEvent = procedure(const ErrorMsg: String) of object;
  TLogSQLEvent = procedure(const MsgLogSQL: String)of object;
  TGetConnectedEvent = procedure(const MsgConnected: Boolean) of object;
  TGetInfoTestConnectEvent = procedure(const MsgConnectSuccess: Boolean; const MsgConnectInfoList: TStringList) of object;
  TUsedDBEvent =  procedure(const MsgFunctionKey: Integer; const MsgState: Integer; const MsgCallTime: String; const MsgErrorMessage: String) of object;
  TGetDBPropertiesEvent = procedure(const MsgPropertiesList: TStringList) of object;
  TCbbEvent = procedure (const MsgStrList: TStringList) of object;
  TSetDocTypeStringsEvent = procedure (const MsgDocTypeList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String; const MsgInvCardStr: String) of object;
  TGetProcStatisticsEvent = procedure (const MsgProcGdDocStr: String; const MsgProcAcEntryStr: String; const MsgProcInvMovementStr: String; const MsgProcInvCardStr: String) of object;
  TFinishEvent = procedure of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FFinish: Boolean;
    FBusy: TidThreadSafeInteger;
    FLogFileName: TidThreadSafeString;
    FBackupFileName: TidThreadSafeString;
    FRestoreDBName: TidThreadSafeString;
    FSaveLog, FCreateBackup: Boolean;
    FContinueReprocess: Boolean;
    FCompanyKey: Integer;

    FDocTypesList: TStringList;
    FIsProcDocTypes: Boolean;

    FConnectInfo: TgsDBConnectInfo;

    FClosingDate: TDateTime;
    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;
    FAccount00: Boolean;

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
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;
    procedure DoOnGetProcStatisticsSync;

    procedure LogSQL(const AMsgLogSQL: String);
    procedure GetConnected(const AMsgConnected: Boolean);
    procedure GetInfoTestConnect(const AMsgConnectSuccess: Boolean; const AMsgConnectInfoList: TStringList);
    procedure UsedDB(const AMessageFunctionKey: Integer;const AMessageState: Integer;
      const AMessageCallTime: String; const AMessageErrorMessage: String);
    procedure GetDBProperties(const AMessageProperties: TStringList);
    procedure SetItemsCbb(const AMessageStrList: TStringList);
    procedure SetDocTypeStrings(const AMessageDocTypeList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String);
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

    procedure ContinueProcessing(const AFunctionKey: Integer; const AState: Integer);

    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const AnAccount00: Boolean);
    procedure SetCompanyKey(const ACompanyKey: Integer);
    procedure SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);
    procedure SetDBParams(const ADatabaseName: String; const AHost: String; const AUserName: String; const APassword: String; const ACharacterSet: String; const APort: Integer = 0);
    procedure SetClosingDate(const AClosingDate: TDateTime);
    procedure SetOptions(const ASaveLog: Boolean; const ACreateBackup: Boolean; const ALogFileName: String; const ABackupFileName: String; const ARestoreDBName: String; const AContinueReprocess: Boolean);
    //function GetConnected: Boolean;

    //property Connected: Boolean read GetConnected;
    property State: Boolean read GetState;
    property Busy: Boolean read GetBusy;

    property OnFinishEvent: TFinishEvent read FOnFinish write FOnFinish;
    property OnLogSQL: TLogSQLEvent read FOnLogSQL write FOnLogSQL;
    property OnGetConnected: TGetConnectedEvent read FOnGetConnected write FOnGetConnected;
    property OnGetInfoTestConnect: TGetInfoTestConnectEvent read FOnGetInfoTestConnect write FOnGetInfoTestConnect;
    property OnUsedDB: TUsedDBEvent read FOnUsedDB write FOnUsedDB;
    property OnGetDBProperties: TGetDBPropertiesEvent read FOnGetDBProperties write FOnGetDBProperties;
    property OnSetItemsCbb: TCbbEvent read FOnSetItemsCbb write FOnSetItemsCbb;
    property OnSetDocTypeStrings: TSetDocTypeStringsEvent read FOnSetDocTypeStrings write FOnSetDocTypeStrings;
    property OnGetDBSize: TGetDBSizeEvent read FOnGetDBSize write FOnGetDBSize;
    property OnGetStatistics: TGetStatisticsEvent read FOnGetStatistics write FOnGetStatistics;
    property OnGetProcStatistics: TGetProcStatisticsEvent read FOnGetProcStatistics write FOnGetProcStatistics;
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
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FDBS.OnGetProcStatistics := GetProcStatistics;
  FDocTypesList :=  TStringList.Create;
  FLogFileName := TIdThreadSafeString.Create;
  FBackupFileName := TIdThreadSafeString.Create;
  FRestoreDBName := TIdThreadSafeString.Create;
  FBusy := TIdThreadSafeInteger.Create;
  FState := TIdThreadSafeInteger.Create;
  FConnected := TIdThreadSafeInteger.Create;
  FMsgConnectInfoList := TStringList.Create;
  FMessageStrList := TStringList.Create;
  FMessageDocTypeList := TStringList.Create;
  FMessagePropertiesList := TStringList.Create;
  FState.Value := 1;
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
  FMessagePropertiesList.Free;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  //if not Connected then

    PostMsg(WM_DBS_CONNECT);
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  //if Connected and (not Busy) then         ///tmp
    PostMsg(WM_DBS_DISCONNECT);
end;

procedure TgsDBSqueezeThread.StartProcessing;
begin

  PostMsg(WM_DBS_STARTPROCESSING);
end;

procedure TgsDBSqueezeThread.StopProcessing;
begin
  if (not Busy) then
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

procedure TgsDBSqueezeThread.DoOnUsedDBSync;
begin
  if Assigned(FOnUsedDB) then
    FOnUsedDB(FMessageFunctionKey, FMessageState, FMessageCallTime,  FMessageErrorMessage);
end;

procedure TgsDBSqueezeThread.DoOnFinishSync;
begin
  if Assigned(FOnFinish) then
    FOnFinish;
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
end;

procedure TgsDBSqueezeThread.DoOnGetProcStatisticsSync;
begin
  if Assigned(FOnGetProcStatistics) then
    FOnGetProcStatistics(FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr);
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
        //if FState.Value = 1 then
        //begin
          FDBS.GetInfoTestConnectEvent;
          FState.Value := 1;
        //end;
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
        //if FConnected.Value = 0 then
        //begin
          FDBS.GetDBSizeEvent;
          FBusy.Value := 1;
        //end;
        FState.Value := 1;

        if FFinish then
          PostThreadMessage(ThreadID, WM_DBS_CONNECT, 0, 0);

        Result := True;
      end;

    WM_DBS_CONNECT:
      begin
        FDBS.Connect(False, True);        // garbage collect ON
       // FConnected.Value := 1;
        FState.Value := 1;

   //     FBusy.Value := 1;

        if not FFinish then
          PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0)
        else
          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);

        Result := True;
      end;

    WM_DBS_CREATEDBSSTATEJOURNAL:
      begin
        //if FConnected.Value = 1 then
        //begin
          FDBS.CreateDBSStateJournal;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_GETDBPROPERTIES, 0, 0);
        //end;
        Result := True;
      end;

    WM_DBS_SETCBBITEMS:
      begin
        //if FConnected.Value = 1 then
       // begin
          //FBusy.Value := 1;
          FDBS.SetItemsCbbEvent;
       // end;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_SETDOCTYPESRINGS:
      begin
        //if FConnected.Value = 1 then
       // begin
          //FBusy.Value := 1;
          FDBS.SetDocTypeStringsEvent;
       // end;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_GETDBPROPERTIES:
      begin
        //if FConnected.Value = 1 then
        //begin
          FDBS.GetDBPropertiesEvent;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;
        //end;
        Result := True;
      end;

    WM_DBS_SETCLOSINGDATE:
      begin
        FDBS.ClosingDate := FClosingDate;
        Result := True;
      end;

    WM_DBS_SETCOMPANYKEY:
      begin
       // if FConnected.Value = 1 then
       // begin
         // FBusy.Value := 1;
          FDBS.CompanyKey := FCompanyKey;
       // end;
        Result := True;
      end;

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
        FDBS.OnlyCompanySaldo := FOnlyCompanySaldo;
        FDBS.DoAccount00Saldo := FAccount00;

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
       // FBusy.Value := 1;
        FDBS.SaveLog := FCreateBackup;
        FDBS.CreateBackup := FCreateBackup;
        FDBS.LogFileName := FLogFileName.Value;
        FDBS.BackupFileName := FBackupFileName.Value;
        FDBS.RestoreDBName := FRestoreDBName.Value;
        FDBS.ContinueReprocess := FContinueReprocess;

        Result := True;
      end;

    WM_DBS_GETSTATISTICS:
      begin
        //if FConnected.Value = 0 then
        //begin

          FDBS.GetStatisticsEvent;
        //end;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_GETPROCSTATISTICS:
      begin
        //if FConnected.Value = 0 then
        //begin
          FDBS.GetProcStatisticsEvent;
        //end;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_STARTPROCESSING:
      begin
        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;
        PostThreadMessage(ThreadID, WM_DBS_SETFVARIABLLES, 0, 0);

        Result := True;
      end;

    WM_DBS_STOPPROCESSING:
      begin
        // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);

       // end;
        Result := True;
      end;

    WM_DBS_SETFVARIABLLES:
      begin
          FDBS.ProgressMsgEvent('Инициализация...', 0);                         //1%
          FDBS.SetFVariables;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEMETADATA, 0, 0);
          Result := True;
      end;

    WM_DBS_CREATEMETADATA:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Создание таблиц для метаданных...', 1*PROGRESS_STEP);          // 1%
          FDBS.CreateMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_SAVEMETADATA, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_SAVEMETADATA:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Получение метаданных... ', 1*PROGRESS_STEP);  //1%
          FDBS.SaveMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEACSALDO, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_CALCULATEACSALDO:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Вычисление бухгалтерского сальдо...', 1*PROGRESS_STEP);         //7%
          FDBS.CalculateAcSaldo;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEINVSALDO, 0, 0);
        //end;
        Result := True;
      end;

    WM_DBS_CALCULATEINVSALDO:
      begin
        //if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Вычисление складского сальдо...', 7*PROGRESS_STEP);            // 7%
          FDBS.CalculateInvSaldo;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_PREPAREREBINDINVCARDS, 0, 0);
        //end;
        Result := True;
      end;

    WM_DBS_PREPAREREBINDINVCARDS:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;

          ///////FDBS.PrepareRebindInvCards;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEHIS_INCLUDEHIS, 0, 0);

       // end;
        Result := True;
      end;

    WM_DBS_CREATEHIS_INCLUDEHIS:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Выявление записей, которые должны остаться...', 7*PROGRESS_STEP);// 16%
          FDBS.CreateHIS_IncludeInHIS;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_PREPAREDB:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          //FDBS.Reconnect(True, True);    // garbage collect OFF
          FDBS.ProgressMsgEvent('Подготовка БД к удалению записей...', 0);         // 3%
          FDBS.PrepareDB;
                                                                               
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEOLDBALANCE, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_DELETEOLDBALANCE:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Очистка от неактуальных данных...', 3*PROGRESS_STEP);           //2%
          FDBS.DeleteOldAcEntryBalance;                                         
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEDOCHIS, 0, 0);
       // end;

        Result := True;
      end;

    WM_DBS_DELETEDOCHIS:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Удаление записей...', 2*PROGRESS_STEP);        //8%
          FDBS.DeleteDocuments_DeleteHIS;                                       
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEACENTRIES, 0, 0);
       // end;

        Result := True;
      end;

    WM_DBS_CREATEACENTRIES:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Сохранение бухгалтерского сальдо...', 8*PROGRESS_STEP);  //7%
          FDBS.CreateAcEntries;                                                 
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEINVSALDO, 0, 0);
       // end;

        Result := True;
      end;

    WM_DBS_CREATEINVSALDO:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.ProgressMsgEvent('Сохранение складского сальдо...', 7*PROGRESS_STEP);   //7%
          FDBS.CreateInvSaldo;                                                  

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_RESTOREDB, 0, 0);
       // end;

        Result := True;
      end;

    WM_DBS_RESTOREDB:
      begin
       // if FConnected.Value = 1 then
       // begin
          FDBS.ProgressMsgEvent('Восстановление БД...', 7*PROGRESS_STEP);       // 30%
          FDBS.RestoreDB;
          FDBS.Reconnect(False, True);                                         

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_REBINDINVCARDS, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_REBINDINVCARDS:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;

          ///////FDBS.RebindInvCards;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CLEARDBSTABLES, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_CLEARDBSTABLES:
      begin
        FBusy.Value := 1;
        FDBS.ProgressMsgEvent('Удаление метаданных...', 0);      //1%
        FDBS.ClearDBSTables;

        //FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        FDBS.ProgressMsgEvent('', 1*PROGRESS_STEP);
        PostThreadMessage(ThreadID, WM_DBS_BACKUPDATABASE, 0, 0);
        Result := True;
      end;

    WM_DBS_BACKUPDATABASE:
      begin
        if FBackupFileName.Value <> '' then
        begin
          FDBS.ProgressMsgEvent('Создание backup-файла...', 0);                 //3%
          FDBS.BackupDatabase;
        end;
        FState.Value := 1;

        FDBS.ProgressMsgEvent('', 3*PROGRESS_STEP);
        PostThreadMessage(ThreadID, WM_DBS_RESTOREBK, 0, 0);
        Result := True;
      end;

    WM_DBS_RESTOREBK:
      begin
        if FRestoreDBName.Value <> '' then
        begin
          FDBS.ProgressMsgEvent('Восcтановление БД из backup-файла...', 0);     //6%
          FDBS.RestoreDatabaseFromBackup;
        end;
        FState.Value := 1;

        FDBS.ProgressMsgEvent('', 6*PROGRESS_STEP);
        PostThreadMessage(ThreadID, WM_DBS_FINISH, 0, 0);
        Result := True;
      end;

    WM_DBS_FINISH:
      begin
        FDBS.GetDBSizeEvent;

        FFinish:= True;
        FDBS.ProgressMsgEvent('Обработка БД завершена.');
        FDBS.LogEvent('FINISH!');
        DoOnFinishSync;

        //PostThreadMessage(ThreadID, WM_DBS_DISCONNECT, 0, 0);
        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FFinish:= False;
        FBusy.Value := 0;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin
       // if FConnected.Value = 1 then
      //  begin
          FDBS.Disconnect;
          FConnected.Value := 0;

          FState.Value := 1;
       // end;
        Result := True;
      end;
  else
    Result := False;
  end;
 except
  on E: Exception do
  begin
    FDBS.LogEvent('[error]' + E.Message);
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
  //if not Connected then
  //begin
      FConnectInfo.DatabaseName := ADatabaseName;
      FConnectInfo.Host := AHost;
      FConnectInfo.UserName := AUserName;
      FConnectInfo.Password := APassword;
      FConnectInfo.CharacterSet := ACharacterSet;
      FConnectInfo.Port := APort;

    PostMsg(WM_DBS_STARTTESTCONNECT);
  //end;
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

procedure  TgsDBSqueezeThread.SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const AnAccount00: Boolean);
begin
  FAllOurCompaniesSaldo := AAllOurCompanies;
  FOnlyCompanySaldo := AOnlyCompany;
  FAccount00 := AnAccount00;
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
  //if (not Busy) then                       ///////////////////
 // begin
    FMessagePropertiesList.Text := AMessageProperties.Text;
    Synchronize(DoOnGetDBPropertiesSync);
  //end
end;


procedure TgsDBSqueezeThread.DoGetDBSize;
begin
    PostMsg(WM_DBS_GETDBSIZE);
end;

procedure TgsDBSqueezeThread.GetDBSize(const AMessageDBSizeStr: String);
begin
  //if (not Busy) then                       ///////////////////
  //begin
    FMessageDBSizeStr := AMessageDBSizeStr;
    Synchronize(DoOnGetDBSizeSync);
  //end;
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

procedure TgsDBSqueezeThread.ContinueProcessing(const AFunctionKey: Integer; const AState: Integer);
begin
  if (not Busy) then//Connected and (not Busy) then
  begin
    FDBS.SetFVariables;                                         //////////
    FDBS.InsertDBSStateJournal(WM_DBS_STARTPROCESSING, 1);
    if (AState = -1) or (AState = 0) then
      PostMsg(AFunctionKey)
    else if (AState = 1) and ((AFunctionKey+1) < WM_DBS_FINISHED) then   ///////
      PostMsg(AFunctionKey + 1);
  end;
    /// TODO: exception proc
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
