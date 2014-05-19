unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  MAX_PROGRESS_STEP = 12500;
  PROGRESS_STEP = MAX_PROGRESS_STEP div 100;

  WM_DBS_SETPARAMS             = WM_GD_THREAD_USER + 4;
  WM_DBS_CONNECT               = WM_GD_THREAD_USER + 6;

  WM_DBS_SETDOCTYPESRINGS      = WM_GD_THREAD_USER + 7;

  WM_DBS_GETCARDFEATURES       = WM_GD_THREAD_USER + 8;

  WM_DBS_CREATEDBSSTATEJOURNAL = WM_GD_THREAD_USER + 9;
  WM_DBS_GETDBPROPERTIES       = WM_GD_THREAD_USER + 10;
  WM_DBS_SETCLOSINGDATE        = WM_GD_THREAD_USER + 11;

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
  WM_DBS_UPDATEINVCARD         = WM_GD_THREAD_USER + 26;
  WM_DBS_PREPAREREBINDINVCARDS = WM_GD_THREAD_USER + 27;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_GD_THREAD_USER + 28;
  WM_DBS_PREPAREDB             = WM_GD_THREAD_USER + 29;
  WM_DBS_DELETEOLDBALANCE      = WM_GD_THREAD_USER + 30;
  WM_DBS_DELETEDOCHIS          = WM_GD_THREAD_USER + 31;
  WM_DBS_CREATEACENTRIES       = WM_GD_THREAD_USER + 32;
  WM_DBS_CREATEINVSALDO        = WM_GD_THREAD_USER + 33;
  WM_DBS_RESTOREDB             = WM_GD_THREAD_USER + 34;
  WM_DBS_REBINDINVCARDS        = WM_GD_THREAD_USER + 35;
  WM_DBS_CLEARDBSTABLES        = WM_GD_THREAD_USER + 36;
  WM_DBS_FINISH                = WM_GD_THREAD_USER + 37;
  WM_DBS_FINISHED              = WM_GD_THREAD_USER + 38;
  WM_DBS_DISCONNECT            = WM_GD_THREAD_USER + 39;
  WM_DBS_CREATE_INV_BALANCE    = WM_GD_THREAD_USER + 40;

  WM_DBS_MERGECARDS            = WM_GD_THREAD_USER + 41;

  WM_STOPNOTIFY                = WM_GD_THREAD_USER + 42;

  WM_GD_EXIT_THREAD            = WM_USER + 117;

type
  TErrorEvent = procedure(const ErrorMsg: String) of object;
  TLogSQLEvent = procedure(const MsgLogSQL: String)of object;
  TGetConnectedEvent = procedure(const MsgConnected: Boolean) of object;
  TGetDBPropertiesEvent = procedure(const MsgPropertiesList: TStringList) of object;
  TSetDocTypeStringsEvent = procedure (const MsgDocTypeList: TStringList) of object;
  TGetInvCardFeaturesEvent =  procedure (const MsgCardFeaturesList: TStringList) of object;
  TSetDocTypeBranchEvent = procedure (const MsgBranchList: TStringList) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String; const MsgInvCardStr: String) of object;
  TGetProcStatisticsEvent = procedure (const MsgProcGdDocStr: String; const MsgProcAcEntryStr: String; const MsgProcInvMovementStr: String; const MsgProcInvCardStr: String) of object;
  TFinishEvent = procedure (const MsgIsFinished: Boolean) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private

    FMainFrmHandle: THandle;

    FDBS: TgsDBSqueeze;

    FBusy: TidThreadSafeInteger;
    FDoGetStatisticsAfterProc: TidThreadSafeInteger;

    FDoStopProcessing: TidThreadSafeInteger;

    FAllOurCompaniesSaldo: Boolean;                                             ///TODO убрать
    FCalculateSaldo: Boolean;
    FClosingDate: TDateTime;
    FConnectInfo: TgsDBConnectInfo;
    FDocTypesList: TStringList;
    FFinish: Boolean;
    FIsProcDocTypes: Boolean;
    FMergeCardFeatures: TStringList;
    FMergeDocDate: TDateTime;
    FMergeDocTypes: TStringList;

    FMessageCardFeatures:  TStringList;
    FMessageDocTypeBranchList: TStringList;
    FMessageDocTypeList: TStringList;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr, FMessageInvCardStr: String;
    FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr: String;
    FMessagePropertiesList: TStringList;
    FMsgConnected: Boolean;
    FMsgConnectInfoList: TStringList;
    FMsgLogSQL: String;

    FOnFinish: TFinishEvent;
    FOnGetConnected: TGetConnectedEvent;
    FOnGetDBProperties: TGetDBPropertiesEvent;
    FOnGetInvCardFeatures: TGetInvCardFeaturesEvent;
    FOnGetProcStatistics: TGetProcStatisticsEvent;
    FOnGetStatistics: TGetStatisticsEvent;
    FOnLogSQL: TLogSQLEvent;
    FOnSetDocTypeBranch: TSetDocTypeBranchEvent;
    FOnSetDocTypeStrings: TSetDocTypeStringsEvent;

    procedure DoOnFinishSync;
    procedure DoOnGetCardFeaturesSync;
    procedure DoOnGetConnectedSync;
    procedure DoOnGetDBPropertiesSync;
    procedure DoOnGetProcStatisticsSync;
    procedure DoOnGetStatisticsSync;
    procedure DoOnLogSQLSync;
    procedure DoOnSetDocTypeBranchSync;
    procedure DoOnSetDocTypeStringsSync;

    procedure Finish;
    procedure GetCardFeatures(const AMessageCardFeatures: TStringList);
    procedure GetConnected(const AMsgConnected: Boolean);
    procedure GetDBProperties(const AMessageProperties: TStringList);
    procedure GetProcStatistics(const AMessageProcGdDocStr: String; const AMessageProcAcEntryStr: String; const AMessageProcInvMovementStr: String; const AMessageProcInvCardStr: String);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String; const AMessageInvCardStr: String);
    procedure LogSQL(const AMsgLogSQL: String);
    procedure SetDocTypeBranch(const AMessageBranchList: TStringList);
    procedure SetDocTypeStrings(const AMessageDocTypeList: TStringList);
    procedure SetParamStatisticsAfterProc(AParam: Boolean);

    function GetBusy: Boolean;
    function GetParamStatisticsAfterProc: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure StartProcessing;
    procedure StopProcessing;
    procedure DoMergeCards;
    procedure DoGetDBProperties;
    procedure DoGetStatistics;
    procedure DoGetProcStatistics;

    procedure SetClosingDate(const AClosingDate: TDateTime);
    procedure SetDBParams(const ADatabaseName: String; const AHost: String; const AUserName: String; const APassword: String; const ACharacterSet: String; const ANumBuffers: Integer; const APort: Integer = 0);
    procedure SetMergeCardParams(const ADocDate: TDateTime; const ADocTypesList: TStringList; const ACardFeaturesList:  TStringList);
    procedure SetSelectDocTypes(const ADocTypes: TStringList; const AnIsProcDocTypes: Boolean);


    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const ACalculateSaldo: Boolean);             ///

    property MainFrmHandle: THandle read FMainFrmHandle write FMainFrmHandle;

    property Busy: Boolean  read GetBusy;
    property DoGetStatisticsAfterProc: Boolean
      read GetParamStatisticsAfterProc write SetParamStatisticsAfterProc;
    property OnFinishEvent: TFinishEvent
      read FOnFinish                   write FOnFinish;
    property OnGetConnected: TGetConnectedEvent
      read FOnGetConnected             write FOnGetConnected;
    property OnGetDBProperties: TGetDBPropertiesEvent
      read FOnGetDBProperties          write FOnGetDBProperties;
    property OnGetInvCardFeatures: TGetInvCardFeaturesEvent
      read FOnGetInvCardFeatures       write FOnGetInvCardFeatures;
    property OnGetProcStatistics: TGetProcStatisticsEvent
      read FOnGetProcStatistics        write FOnGetProcStatistics;
    property OnGetStatistics: TGetStatisticsEvent
      read FOnGetStatistics            write FOnGetStatistics;
    property OnLogSQL: TLogSQLEvent
      read FOnLogSQL                   write FOnLogSQL;
    property OnSetDocTypeBranch: TSetDocTypeBranchEvent
      read FOnSetDocTypeBranch         write FOnSetDocTypeBranch;
    property OnSetDocTypeStrings: TSetDocTypeStringsEvent
      read FOnSetDocTypeStrings        write FOnSetDocTypeStrings;
  end;

implementation

{ TgsDBSqueezeThread }

constructor TgsDBSqueezeThread.Create(const CreateSuspended: Boolean);
begin
  FDBS := TgsDBSqueeze.Create;
  FDBS.OnProgressWatch := DoOnProgressWatch;
  FDBS.OnLogSQLEvent := LogSQL;
  FDBS.OnGetConnectedEvent := GetConnected;
  FDBS.OnGetDBPropertiesEvent := GetDBProperties;
  FDBS.OnSetDocTypeStringsEvent := SetDocTypeStrings;
  FDBS.OnGetInvCardFeaturesEvent := GetCardFeatures;
  FDBS.OnSetDocTypeBranchEvent := SetDocTypeBranch;
  FDBS.OnGetStatistics := GetStatistics;
  FDBS.OnGetProcStatistics := GetProcStatistics;
  FDocTypesList :=  TStringList.Create;
  FBusy := TIdThreadSafeInteger.Create;
  FDoGetStatisticsAfterProc := TIdThreadSafeInteger.Create;
  FMsgConnectInfoList := TStringList.Create;
  FMessageDocTypeList := TStringList.Create;
  FMessageCardFeatures := TStringList.Create;
  FMessageDocTypeBranchList := TStringList.Create;
  FMessagePropertiesList := TStringList.Create;
  FDoStopProcessing := TIdThreadSafeInteger.Create;

  FBusy.Value := 0;
  FFinish := False;
  FDoStopProcessing.Value := 0;

  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FDocTypesList.Free;
  FBusy.Free;
  FDoGetStatisticsAfterProc.Free;
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
  FDBS.DoStopProcessing  := True;      ///TODO: cs
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

procedure TgsDBSqueezeThread.Finish;
begin
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

procedure TgsDBSqueezeThread.DoOnGetStatisticsSync;
begin
  if Assigned(FOnGetStatistics) then
    FOnGetStatistics(FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr, FMessageInvCardStr);

  if not GetParamStatisticsAfterProc then
    FBusy.Value := 0;
end;

procedure TgsDBSqueezeThread.DoOnGetProcStatisticsSync;
begin
  if Assigned(FOnGetProcStatistics) then
    FOnGetProcStatistics(FMessageProcGdDocStr, FMessageProcAcEntryStr, FMessageProcInvMovementStr, FMessageProcInvCardStr);

  if not GetParamStatisticsAfterProc then
    FBusy.Value := 0;
end;

function TgsDBSqueezeThread.GetBusy: Boolean;
begin
  Result := FBusy.Value <> 0;
end;

function TgsDBSqueezeThread.GetParamStatisticsAfterProc: Boolean;
begin
  Result := FDoGetStatisticsAfterProc.Value <> 0;
end;

procedure TgsDBSqueezeThread.SetParamStatisticsAfterProc(AParam: Boolean);
begin
  if AParam then
    FDoGetStatisticsAfterProc.Value := 1
  else
    FDoGetStatisticsAfterProc.Value := 0;
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

    WM_DBS_CONNECT:
      begin
        if not FDBS.Connected then
        begin
          FDBS.Connect(True, True);        // garbage collect OFF
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

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
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
        if FDoStopProcessing.Value = 0 then
          FDBS.GetProcStatisticsEvent;
        Result := True;
      end;

    WM_DBS_STARTPROCESSING:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FBusy.Value := 1;

          if GetParamStatisticsAfterProc then
          begin
            FDBS.GetStatisticsEvent;
            if FDoStopProcessing.Value = 0 then
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

        if FDBS.DoStopProcessing then        // форма начинает ждать завершения
          PostMessage(FMainFrmHandle, WM_STOPNOTIFY, 0, 0);                

        PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);
        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FBusy.Value := 0;

        PostThreadMessage(ThreadID, WM_GD_EXIT_THREAD, 0, 0);

        Result := True;
      end;

    WM_DBS_MERGECARDS:                                                          
      begin
        FBusy.Value := 1;

        FDBS.ProgressMsgEvent('Объединение карточек...', 0);

        if FDoStopProcessing.Value = 0 then
          FDBS.MergeCards(FMergeDocDate, FMergeDocTypes, FMergeCardFeatures);

        FDBS.ProgressMsgEvent(' ', 0);

        FBusy.Value := 0;
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

            PostThreadMessage(ThreadID, WM_DBS_UPDATEINVCARD, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_UPDATEINVCARD:
      begin
        if FDoStopProcessing.Value = 0 then
        begin
          FDBS.ProgressMsgEvent('Перепривязка признаков складских карточек...', 0);
          FDBS.UpdateInvCard;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);

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

          if GetParamStatisticsAfterProc and (FDoStopProcessing.Value = 0) then
          begin
            FDBS.GetStatisticsEvent;
            if FDoStopProcessing.Value = 0 then
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
          FDBS.LogEvent('FINISH!');
          FDBS.ProgressMsgEvent('Обработка БД завершена.');
          
          FFinish:= True;
          Finish;

          FBusy.Value := 0;
        end;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin
        FDBS.Disconnect;

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

procedure TgsDBSqueezeThread.SetDBParams(
  const ADatabaseName: String;
  const AHost: String;
  const AUserName: String;
  const APassword: String;
  const ACharacterSet: String;
  const ANumBuffers: Integer;
  const APort: Integer = 0);
begin
  FConnectInfo.DatabaseName := ADatabaseName;
  FConnectInfo.Host := AHost;
  FConnectInfo.UserName := AUserName;
  FConnectInfo.Password := APassword;
  FConnectInfo.CharacterSet := ACharacterSet;
  FConnectInfo.NumBuffers := ANumBuffers;
  FConnectInfo.Port := APort;

  PostMsg(WM_DBS_SETPARAMS);
end;

procedure TgsDBSqueezeThread.SetClosingDate(const AClosingDate: TDateTime);
begin
  FClosingDate := AClosingDate;
  PostMsg(WM_DBS_SETCLOSINGDATE);
end;

procedure  TgsDBSqueezeThread.SetSaldoParams(const AAllOurCompanies: Boolean; const ACalculateSaldo: Boolean);
begin
  FAllOurCompaniesSaldo := AAllOurCompanies;
  FCalculateSaldo := ACalculateSaldo;
  PostMsg(WM_DBS_SETSALDOPARAMS);
end;

procedure TgsDBSqueezeThread.SetMergeCardParams(
  const ADocDate: TDateTime;
  const ADocTypesList: TStringList;
  const ACardFeaturesList:  TStringList);
begin
  FMergeDocDate := ADocDate;
  FMergeDocTypes := ADocTypesList;
  FMergeCardFeatures := ACardFeaturesList;
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

procedure TgsDBSqueezeThread.DoMergeCards;
begin
  PostMsg(WM_DBS_MERGECARDS);
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
