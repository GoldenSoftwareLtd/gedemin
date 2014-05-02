unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  MAX_PROGRESS_STEP = 12500;
  PROGRESS_STEP = MAX_PROGRESS_STEP div 100;

  WM_DBS_SETPARAMS             = WM_GD_THREAD_USER + 4;
  WM_DBS_GETDBSIZE             = WM_GD_THREAD_USER + 5;
  WM_DBS_CONNECT               = WM_GD_THREAD_USER + 6;

  WM_DBS_SETDOCTYPESRINGS      = WM_GD_THREAD_USER + 7;

  WM_DBS_GETCARDFEATURES       = WM_GD_THREAD_USER + 8;

  WM_DBS_CREATEDBSSTATEJOURNAL = WM_GD_THREAD_USER + 9;
  WM_DBS_GETDBPROPERTIES       = WM_GD_THREAD_USER + 10;
  WM_DBS_SETCLOSINGDATE        = WM_GD_THREAD_USER + 11;
  WM_DBS_SETCOMPANYKEY         = WM_GD_THREAD_USER + 12;
  WM_DBS_SETSALDOPARAMS        = WM_GD_THREAD_USER + 13;
  WM_DBS_SETSELECTEDDOCTYPES   = WM_GD_THREAD_USER + 14;
  WM_DBS_GETSTATISTICS         = WM_GD_THREAD_USER + 16;
  WM_DBS_GETPROCSTATISTICS     = WM_GD_THREAD_USER + 17;
  WM_DBS_STARTPROCESSING       = WM_GD_THREAD_USER + 18;
  WM_DBS_STOPPROCESSING        = WM_GD_THREAD_USER + 19;
  WM_DBS_RECONNECT             = WM_GD_THREAD_USER + 20;
  WM_DBS_SETFVARIABLLES        = WM_GD_THREAD_USER + 21;
  WM_DBS_CREATEMETADATA        = WM_GD_THREAD_USER + 22;
  WM_DBS_SAVEMETADATA          = WM_GD_THREAD_USER + 23;
  WM_DBS_CALCULATEACSALDO      = WM_GD_THREAD_USER + 24;
  WM_DBS_CALCULATEINVSALDO     = WM_GD_THREAD_USER + 25;
  WM_DBS_PREPAREREBINDINVCARDS = WM_GD_THREAD_USER + 26;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_GD_THREAD_USER + 27;
  WM_DBS_PREPAREDB             = WM_GD_THREAD_USER + 28;
  WM_DBS_DELETEOLDBALANCE      = WM_GD_THREAD_USER + 29;
  WM_DBS_DELETEDOCHIS          = WM_GD_THREAD_USER + 30;
  WM_DBS_CREATEACENTRIES       = WM_GD_THREAD_USER + 31;
  WM_DBS_CREATEINVSALDO        = WM_GD_THREAD_USER + 32;
  WM_DBS_RESTOREDB             = WM_GD_THREAD_USER + 33;
  WM_DBS_REBINDINVCARDS        = WM_GD_THREAD_USER + 34;
  WM_DBS_CLEARDBSTABLES        = WM_GD_THREAD_USER + 35;
  WM_DBS_FINISH                = WM_GD_THREAD_USER + 38;
  WM_DBS_FINISHED              = WM_GD_THREAD_USER + 39;
  WM_DBS_DISCONNECT            = WM_GD_THREAD_USER + 40;
  WM_DBS_CREATE_INV_BALANCE    = WM_GD_THREAD_USER + 41;

  WM_GD_EXIT_THREAD            = WM_GD_THREAD_USER + 42;
type
  TErrorEvent = procedure(const ErrorMsg: String) of object;
  TLogSQLEvent = procedure(const MsgLogSQL: String)of object;
  TGetConnectedEvent = procedure(const MsgConnected: Boolean) of object;
  TUsedDBEvent =  procedure(const MsgFunctionKey: Integer; const MsgState: Integer; const MsgCallTime: String; const MsgErrorMessage: String) of object;
  TGetDBPropertiesEvent = procedure(const MsgPropertiesList: TStringList) of object;
  TSetDocTypeStringsEvent = procedure (const MsgDocTypeList: TStringList) of object;
  TGetInvCardFeaturesEvent =  procedure (const MsgCardFeaturesList: TStringList) of object;
  TSetDocTypeBranchEvent = procedure (const MsgBranchList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String; const MsgInvCardStr: String) of object;
  TGetProcStatisticsEvent = procedure (const MsgProcGdDocStr: String; const MsgProcAcEntryStr: String; const MsgProcInvMovementStr: String; const MsgProcInvCardStr: String) of object;
  TFinishEvent = procedure (const MsgIsFinished: Boolean) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FDoGetStatisticsAfterProc: Boolean;
    FDoStopProcessing: TidThreadSafeInteger;
    FFinish: Boolean;
    FBusy: TidThreadSafeInteger;
    FIsFinishMsg: TidThreadSafeInteger;
    FLogFileName: TidThreadSafeString;
    FCompanyKey: Integer;

    FDocTypesList: TStringList;
    FIsProcDocTypes: Boolean;

    FConnectInfo: TgsDBConnectInfo;
    FDBSize: Int64;

    FClosingDate: TDateTime;
    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;
    FCalculateSaldo: Boolean;

    FDBS: TgsDBSqueeze;

    FConnected: TidThreadSafeInteger;  ///

    FMsgLogSQL: String;

    FMsgConnected: Boolean;
    FMsgConnectInfoList: TStringList;

    FMessageFunctionKey: Integer;
    FMessageState: Integer;
    FMessageCallTime: String;
    FMessageErrorMessage: String;

    //FMessageConnected: Boolean;
    FMessagePropertiesList: TStringList;
    FMessageDocTypeList: TStringList;
    FMessageCardFeatures:  TStringList;
    FMessageDocTypeBranchList: TStringList;
    FMessageDBSizeStr: String;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr, FMessageInvCardStr: String;
    FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr: String;

    FOnFinish: TFinishEvent;
    FOnLogSQL: TLogSQLEvent;
    FOnGetConnected: TGetConnectedEvent;
    FOnUsedDB: TUsedDBEvent;
    FOnGetDBProperties: TGetDBPropertiesEvent;
    FOnSetDocTypeStrings: TSetDocTypeStringsEvent;
    FOnGetInvCardFeatures: TGetInvCardFeaturesEvent;
    FOnSetDocTypeBranch: TSetDocTypeBranchEvent;
    FOnGetDBSize: TGetDBSizeEvent;
    FOnGetStatistics: TGetStatisticsEvent;
    FOnGetProcStatistics: TGetProcStatisticsEvent;

    procedure DoOnFinishSync;
    procedure DoOnLogSQLSync;
    procedure DoOnGetConnectedSync;
    procedure DoOnUsedDBSync;
    procedure DoOnGetDBPropertiesSync;
    procedure DoOnSetDocTypeStringsSync;
    procedure DoOnGetCardFeaturesSync;
    procedure DoOnSetDocTypeBranchSync;
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;
    procedure DoOnGetProcStatisticsSync;

    procedure Finish(const AIsFinished: Boolean);

    procedure LogSQL(const AMsgLogSQL: String);
    procedure GetConnected(const AMsgConnected: Boolean);
    procedure UsedDB(const AMessageFunctionKey: Integer;const AMessageState: Integer;
      const AMessageCallTime: String; const AMessageErrorMessage: String);
    procedure GetDBProperties(const AMessageProperties: TStringList);
    procedure SetDocTypeStrings(const AMessageDocTypeList: TStringList);
    procedure GetCardFeatures(const AMessageCardFeatures: TStringList);
    procedure SetDocTypeBranch(const AMessageBranchList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String; const ADBSize: Int64);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String; const AMessageInvCardStr: String);
    procedure GetProcStatistics(const AMessageProcGdDocStr: String; const AMessageProcAcEntryStr: String; const AMessageProcInvMovementStr: String; const AMessageProcInvCardStr: String);

    function GetBusy: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    procedure StartProcessing;
    procedure StopProcessing;

    procedure DoGetDBProperties;
    procedure DoGetDBSize;
    procedure DoGetStatistics;
    procedure DoGetProcStatistics;

    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const ACalculateSaldo: Boolean);
    procedure SetCompanyKey(const ACompanyKey: Integer);
    procedure SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);
    procedure SetDBParams(const ADatabaseName: String; const AHost: String; const AUserName: String; const APassword: String; const ACharacterSet: String; const APort: Integer = 0);
    procedure SetClosingDate(const AClosingDate: TDateTime);

    property Busy: Boolean  read GetBusy;
    property DBSize: Int64  read FDBSize;
    property DoGetStatisticsAfterProc: Boolean read FDoGetStatisticsAfterProc write FDoGetStatisticsAfterProc;

    property OnFinishEvent: TFinishEvent
      read FOnFinish             write FOnFinish;
    property OnLogSQL: TLogSQLEvent
      read FOnLogSQL             write FOnLogSQL;
    property OnGetConnected: TGetConnectedEvent
      read FOnGetConnected       write FOnGetConnected;
    property OnUsedDB: TUsedDBEvent
      read FOnUsedDB             write FOnUsedDB;
    property OnGetDBProperties: TGetDBPropertiesEvent
      read FOnGetDBProperties    write FOnGetDBProperties;
    property OnSetDocTypeStrings: TSetDocTypeStringsEvent
      read FOnSetDocTypeStrings  write FOnSetDocTypeStrings;
    property OnGetInvCardFeatures: TGetInvCardFeaturesEvent
      read FOnGetInvCardFeatures write FOnGetInvCardFeatures;
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
  FDBS.OnGetDBPropertiesEvent := GetDBProperties;
  FDBS.OnSetDocTypeStringsEvent := SetDocTypeStrings;
  FDBS.OnGetInvCardFeaturesEvent := GetCardFeatures;
  FDBS.OnSetDocTypeBranchEvent := SetDocTypeBranch;
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FDBS.OnGetProcStatistics := GetProcStatistics;
  FDocTypesList :=  TStringList.Create;
  FLogFileName := TIdThreadSafeString.Create;
  FIsFinishMsg := TIdThreadSafeInteger.Create;
  FBusy := TIdThreadSafeInteger.Create;
  FConnected := TIdThreadSafeInteger.Create;
  FMsgConnectInfoList := TStringList.Create;
  FMessageDocTypeList := TStringList.Create;
  FMessageCardFeatures := TStringList.Create;
  FMessageDocTypeBranchList := TStringList.Create;
  FMessagePropertiesList := TStringList.Create;
  FDoStopProcessing := TIdThreadSafeInteger.Create;

  FBusy.Value := 0;
  FIsFinishMsg.Value := 0;
  FFinish := False;
  FDoStopProcessing.Value := 0;

  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FDocTypesList.Free;
  FLogFileName.Free;
  FIsFinishMsg.Free;
  FBusy.Free;
  FConnected.Free;
  FMsgConnectInfoList.Free;
  FMessageDocTypeList.Free;
  FMessageCardFeatures.Free;
  FMessageDocTypeBranchList.Free;
  FMessagePropertiesList.Free;
  FDoStopProcessing.Free;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  PostMsg(WM_DBS_CONNECT);
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
  FDoStopProcessing.Value := 1;
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

procedure TgsDBSqueezeThread.DoOnSetDocTypeStringsSync;
begin
  if Assigned(FOnSetDocTypeStrings) then
    FOnSetDocTypeStrings(FMessageDocTypeList);
end;

procedure TgsDBSqueezeThread.DoOnGetCardFeaturesSync;
begin
  if Assigned(OnGetInvCardFeatures) then
    FOnGetInvCardFeatures(FMessageCardFeatures);
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
    FOnFinish(FFinish);
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

function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  Result := False;
 try
  case Msg.Message of
    WM_DBS_SETPARAMS:
      begin
        FDBS.ConnectInfo := FConnectInfo;

        Result := True;
      end;

    WM_DBS_GETDBSIZE:
      begin
        FDBS.GetDBSizeEvent;

        PostThreadMessage(ThreadID, WM_DBS_CONNECT, 0, 0);

        Result := True;
      end;

    WM_DBS_CONNECT:
      begin
        if not FDBS.Connected then
        begin
          FDBS.Connect(False, True);        // garbage collect ON
          PostThreadMessage(ThreadID, WM_DBS_SETDOCTYPESRINGS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_SETDOCTYPESRINGS:
      begin
        FDBS.SetDocTypeStringsEvent;
        PostThreadMessage(ThreadID, WM_DBS_GETCARDFEATURES, 0, 0);
        Result := True;
      end;

    WM_DBS_GETCARDFEATURES:
      begin
        FDBS.GetInvCardFeaturesEvent;
        PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0);
        Result := True;
      end;

    WM_DBS_CREATEDBSSTATEJOURNAL:
      begin
        FDBS.CreateDBSStateJournal;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);

        PostThreadMessage(ThreadID, WM_DBS_GETDBPROPERTIES, 0, 0);
        Result := True;
      end;

    WM_DBS_GETDBPROPERTIES:
      begin
        FDBS.GetDBPropertiesEvent;
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
        FDBS.CalculateSaldo := FCalculateSaldo;

        Result := True;
      end;

    WM_DBS_SETSELECTEDDOCTYPES:
      begin
        FDBS.DocTypesList := FDocTypesList;
        FDBS.DoProcDocTypes := FIsProcDocTypes;

        Result := True;
      end;

    WM_DBS_GETSTATISTICS:
      begin
        FBusy.Value := 1;
        FDBS.GetStatisticsEvent;
        PostThreadMessage(ThreadID, WM_DBS_GETPROCSTATISTICS, 0, 0);
        Result := True;
      end;

    WM_DBS_GETPROCSTATISTICS:
      begin
        FBusy.Value := 1;
        FDBS.GetProcStatisticsEvent;
        Result := True;
      end;

    WM_DBS_STARTPROCESSING:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FBusy.Value := 1;

          if FDoGetStatisticsAfterProc then
          begin
            FDBS.GetStatisticsEvent;
            FDBS.GetProcStatisticsEvent;
          end;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          PostThreadMessage(ThreadID, WM_DBS_SETFVARIABLLES, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_STOPPROCESSING:
      begin
        FDBS.DoStopProcessing := True;
        FDBS.LogEvent('STOP');
        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FFinish:= False;

        Finish(FFinish);     // форма начинает ждать завершения

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
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Инициализация...', 0);                                         // 1%
          FDBS.SetFVariables;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_CREATEMETADATA, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEMETADATA:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Создание таблиц для метаданных...', 1*PROGRESS_STEP);          // 1%
          FDBS.CreateMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_SAVEMETADATA, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_SAVEMETADATA:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Получение метаданных... ', 1*PROGRESS_STEP);                   // 1%
          FDBS.SaveMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEACSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CALCULATEACSALDO:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Вычисление бухгалтерского сальдо...', 1*PROGRESS_STEP);        // 7%
            FDBS.CalculateAcSaldo;

            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 1*PROGRESS_STEP);

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEINVSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CALCULATEINVSALDO:
      begin
        if FDoStopProcessing.Value = 0 then
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

          PostThreadMessage(ThreadID, WM_DBS_CREATEHIS_INCLUDEHIS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEHIS_INCLUDEHIS:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Выявление записей, которые должны остаться...', 0);            // 16%
          FDBS.CreateHIS_IncludeInHIS;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_PREPAREDB:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Подготовка БД к удалению записей...', 0);                        // 3%
          FDBS.PrepareDB;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_DELETEOLDBALANCE, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_DELETEOLDBALANCE:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Очистка от неактуальных данных...', 0);                          // 2%
          FDBS.DeleteOldAcEntryBalance;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_DELETEDOCHIS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_DELETEDOCHIS:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Удаление записей...', 2*PROGRESS_STEP);                          // 8%
          FDBS.DeleteDocuments_DeleteHIS;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_CREATEACENTRIES, 0, 0);
        end;  
        Result := True;
      end;

    WM_DBS_CREATEACENTRIES:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Сохранение бухгалтерского сальдо...', 8*PROGRESS_STEP);          // 7%
            FDBS.CreateAcEntries;
            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 8*PROGRESS_STEP);

          PostThreadMessage(ThreadID, WM_DBS_CREATEINVSALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATEINVSALDO:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          if FCalculateSaldo then
          begin
            FDBS.ProgressMsgEvent('Сохранение складского сальдо...', 0);                           // 7%
            FDBS.CreateInvSaldo;

            FDBS.InsertDBSStateJournal(Msg.Message, 1);
          end
          else
            FDBS.ProgressMsgEvent(' ', 7*PROGRESS_STEP);

          PostThreadMessage(ThreadID, WM_DBS_RESTOREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_RESTOREDB:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Восстановление БД...', 0);                                       // 28%
          FDBS.RestoreDB;
          //FDBS.Reconnect(False, True);

          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_CREATE_INV_BALANCE, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CREATE_INV_BALANCE:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.CreateInvBalance;
          FDBS.ProgressMsgEvent('Вычисление текущих складских остатков...', 0);                    // 2%
          FDBS.InsertDBSStateJournal(Msg.Message, 1);

          PostThreadMessage(ThreadID, WM_DBS_CLEARDBSTABLES, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CLEARDBSTABLES:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Удаление метаданных...', 2*PROGRESS_STEP);                        // 1%
          FDBS.DeleteDBSTables;

          if FDoGetStatisticsAfterProc and (FDoStopProcessing.Value = 0) then
          begin
            FDBS.GetStatisticsEvent;
            FDBS.GetProcStatisticsEvent;
          end;

          //FDBS.InsertDBSStateJournal(Msg.Message, 1);

          FDBS.ProgressMsgEvent('', 1*PROGRESS_STEP);
          PostThreadMessage(ThreadID, WM_DBS_FINISH, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_FINISH:
      begin
        if FDoStopProcessing.Value = 0 then
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

        Result := True;
      end;
  else
    Result := False;
  end;
 except
  on E: Exception do
  begin
    FDBS.ErrorEvent(E.Message);
  end;
 end;
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

procedure  TgsDBSqueezeThread.SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean; const ACalculateSaldo: Boolean);
begin
  FAllOurCompaniesSaldo := AAllOurCompanies;
  FOnlyCompanySaldo := AOnlyCompany;
  FCalculateSaldo := ACalculateSaldo;
  PostMsg(WM_DBS_SETSALDOPARAMS);
end;

procedure TgsDBSqueezeThread.SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);
begin
  FDocTypesList.Text := ADocTypes.Text;
  FIsProcDocTypes := AnIsProcDocTypes;
  PostMsg(WM_DBS_SETSELECTEDDOCTYPES);
end;

procedure TgsDBSqueezeThread.SetDocTypeStrings(const AMessageDocTypeList: TStringList);
begin
  FMessageDoctypeList.Text := AMessageDocTypeList.Text;
  Synchronize(DoOnSetDocTypeStringsSync);
end;

procedure  TgsDBSqueezeThread.GetCardFeatures(const AMessageCardFeatures: TStringList);
begin
  FMessageCardFeatures.Text := AMessageCardFeatures.Text;
  Synchronize(DoOnGetCardFeaturesSync);
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
