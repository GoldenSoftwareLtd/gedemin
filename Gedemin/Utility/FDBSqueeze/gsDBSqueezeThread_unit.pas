unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  WM_DBS_STARTTESTCONNECT      = WM_USER + 1;
  WM_DBS_GETINFOTESTCONNECT    = WM_USER + 2;
  WM_DBS_STOPTESTCONNECT       = WM_USER + 3;
  WM_DBS_SETPARAMS             = WM_USER + 4;
  WM_DBS_GETDBSIZE             = WM_USER + 5;
  WM_DBS_CONNECT               = WM_USER + 6;
  WM_DBS_CREATEDBSSTATEJOURNAL = WM_USER + 7;
  WM_DBS_SETCBBITEMS           = WM_USER + 8;
  WM_DBS_GETDBPROPERTIES       = WM_USER + 9;
  WM_DBS_SETCLOSINGDATE        = WM_USER + 10;
  WM_DBS_SETCOMPANYNAME        = WM_USER + 11;
  WM_DBS_SETSALDOPARAMS        = WM_USER + 12;
  WM_DBS_SETOPTIONS            = WM_USER + 13;
  WM_DBS_GETSTATISTICS         = WM_USER + 14;
  WM_DBS_STARTPROCESSING       = WM_USER + 15;
  WM_DBS_STOPPROCESSING        = WM_USER + 16;
  WM_DBS_SETFVARIABLLES        = WM_USER + 17;
  WM_DBS_CREATEMETADATA        = WM_USER + 18;
  WM_DBS_SAVEMETADATA          = WM_USER + 19;
  WM_DBS_CALCULATEACSALDO      = WM_USER + 20;
  WM_DBS_CALCULATEINVSALDO     = WM_USER + 21;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_USER + 22;
  WM_DBS_PREPAREDB             = WM_USER + 23;
  WM_DBS_DELETEOLDBALANCE      = WM_USER + 24;
  WM_DBS_DELETEDOCHIS          = WM_USER + 25;
  WM_DBS_CREATEACENTRIES       = WM_USER + 26;
  WM_DBS_CREATEINVSALDO        = WM_USER + 27;
  WM_DBS_REBINDINVCARDS        = WM_USER + 28;
  WM_DBS_RESTOREDB             = WM_USER + 29;
  WM_DBS_FINISHED              = WM_USER + 30;
  WM_DBS_DISCONNECT            = WM_USER + 31;

type
  TGetConnectedEvent = procedure (const MsgConnected: Boolean) of object;
  TGetInfoTestConnectEvent = procedure(const MsgConnectSuccess: Boolean; const MsgConnectInfoList: TStringList) of object;
  TUsedDBEvent =  procedure(const MsgFunctionKey: Integer; const MsgState: Integer; const MsgCallTime: String; const MsgErrorMessage: String) of object;
  TGetDBPropertiesEvent = procedure(const MsgPropertiesList: TStringList) of object;
  TCbbEvent = procedure (const MsgStrList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FBusy: TidThreadSafeInteger;
    FLogFileName: TidThreadSafeString;
    FBackupFileName: TidThreadSafeString;
    FSaveLog, FCreateBackup: Boolean;
    FContinueReprocess: Boolean;
    FCompanyName: TidThreadSafeString;
    FDatabaseName, FUserName, FPassword: TidThreadSafeString;
    FClosingDate: TDateTime;
    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    FDBS: TgsDBSqueeze;

    FConnected: TidThreadSafeInteger;  ///
    FState: TidThreadSafeInteger;

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
    FMessageDBSizeStr: String;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr: String;

    FOnGetConnected: TGetConnectedEvent;
    FOnGetInfoTestConnect: TGetInfoTestConnectEvent;
    FOnUsedDB: TUsedDBEvent;
    FOnGetDBProperties: TGetDBPropertiesEvent;
    FOnSetItemsCbb: TCbbEvent;
    FOnGetDBSize: TGetDBSizeEvent;
    FOnGetStatistics: TGetStatisticsEvent;

    procedure DoOnGetConnectedSync;
    procedure DoOnGetInfoTestConnectSync;
    procedure DoOnUsedDBSync;
    procedure DoOnGetDBPropertiesSync;
    procedure DoOnSetItemsCbbSync;
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;

    procedure GetConnected(const AMsgConnected: Boolean);
    procedure GetInfoTestConnect(const AMsgConnectSuccess: Boolean; const AMsgConnectInfoList: TStringList);
    procedure UsedDB(const AMessageFunctionKey: Integer;const AMessageState: Integer;
      const AMessageCallTime: String; const AMessageErrorMessage: String);
    procedure GetDBProperties(const AMessageProperties: TStringList);
    procedure SetItemsCbb(const AMessageStrList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String);

    function GetBusy: Boolean;
    function GetState: Boolean;
  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure StartTestConnect(const ADatabaseName: String; const AUserName: String; const APassword: String);
    procedure StopTestConnect;

    procedure StartProcessing;
    procedure StopProcessing;

    //procedure DoGetConnected;
    procedure DoGetInfoTestConnect;
    procedure DoGetDBProperties;
    procedure DoSetItemsCbb;
    procedure DoGetDBSize;
    procedure DoGetStatistics;

    procedure ContinueProcessing(const AFunctionKey: Integer; const AState: Integer);

    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean);
    procedure SetCompanyName(const ACompanyName: String);
    procedure SetDBParams(const ADatabaseName: String; const AUserName: String; const APassword: String);
    procedure SetClosingDate(const AClosingDate: TDateTime);
    procedure SetOptions(const ASaveLog, ACreateBackup: Boolean;
      const ALogFileName: String; const ABackupFileName: String; AContinueReprocess: Boolean);
    //function GetConnected: Boolean;
    
    //property Connected: Boolean read GetConnected;
    property State: Boolean read GetState;
    property Busy: Boolean read GetBusy;

    property OnGetConnected: TGetConnectedEvent read FOnGetConnected write FOnGetConnected;
    property OnGetInfoTestConnect: TGetInfoTestConnectEvent read FOnGetInfoTestConnect write FOnGetInfoTestConnect;
    property OnUsedDB: TUsedDBEvent read FOnUsedDB write FOnUsedDB;
    property OnGetDBProperties: TGetDBPropertiesEvent read FOnGetDBProperties write FOnGetDBProperties;
    property OnSetItemsCbb: TCbbEvent read FOnSetItemsCbb write FOnSetItemsCbb;
    property OnGetDBSize: TGetDBSizeEvent read FOnGetDBSize write FOnGetDBSize;
    property OnGetStatistics: TGetStatisticsEvent read FOnGetStatistics write FOnGetStatistics;
  end;

implementation

{ TgsDBSqueezeThread }

constructor TgsDBSqueezeThread.Create(const CreateSuspended: Boolean);
begin
  FDBS := TgsDBSqueeze.Create;
  FDBS.OnProgressWatch := DoOnProgressWatch;
  FDBS.OnGetConnectedEvent := GetConnected;
  FDBS.OnUsedDBEvent := UsedDB;
  FDBS.OnGetInfoTestConnectEvent := GetInfoTestConnect;
  FDBS.OnGetDBPropertiesEvent := GetDBProperties;
  FDBS.OnSetItemsCbbEvent := SetItemsCbb;
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FLogFileName := TIdThreadSafeString.Create;
  FBackupFileName := TIdThreadSafeString.Create;
  FDatabaseName := TIdThreadSafeString.Create;
  FUserName := TIdThreadSafeString.Create;
  FPassword := TIdThreadSafeString.Create;
  FCompanyName := TIdThreadSafeString.Create;
  FBusy := TIdThreadSafeInteger.Create;
  FState := TIdThreadSafeInteger.Create;
  FConnected := TIdThreadSafeInteger.Create;
  FMsgConnectInfoList := TStringList.Create;      ///
  FMessageStrList := TStringList.Create;
  FMessagePropertiesList := TStringList.Create;

  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FLogFileName.Free;
  FBackupFileName.Free;
  FDatabaseName.Free;
  FUserName.Free;
  FPassword.Free;
  FCompanyName.Free;
  FBusy.Free;
  FState.Free;
  FConnected.Free;
  FMsgConnectInfoList.Free;
  FMessageStrList.Free;
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

procedure TgsDBSqueezeThread.ContinueProcessing(const AFunctionKey: Integer; const AState: Integer);
begin
  if (not Busy) then//Connected and (not Busy) then
  begin
    FDBS.SetFVariables;                                         //////////
    FDBS.InsertDBSStateJournal(WM_USER + 15, 1);
    if (AState = -1) or (AState = 0) then
      PostMsg(AFunctionKey)
    else if (AState = 1) and ((AState+1) < WM_DBS_FINISHED) then
      PostMsg(AFunctionKey + 1);
  end;
    /// TODO: exception proc
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
  if Assigned(FOnGetInfoTestConnect) then
    FOnGetInfoTestConnect(FMsgConnectSuccess, FMsgConnectInfoList);
end;

procedure TgsDBSqueezeThread.GetInfoTestConnect(const AMsgConnectSuccess: Boolean; const AMsgConnectInfoList: TStringList);
begin
  FMsgConnectSuccess := AMsgConnectSuccess;
  FMsgConnectInfoList := AMsgConnectInfoList;
  Synchronize(DoOnGetInfoTestConnectSync);
end;

procedure TgsDBSqueezeThread.DoOnSetItemsCbbSync;
begin
  if Assigned(FOnSetItemsCbb) then
    FOnSetItemsCbb(FMessageStrList);
end;

procedure TgsDBSqueezeThread.DoOnUsedDBSync;
begin
  if Assigned(FOnUsedDB) then
    FOnUsedDB(FMessageFunctionKey, FMessageState, FMessageCallTime,  FMessageErrorMessage);
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
    FOnGetStatistics(FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr);
end;

function TgsDBSqueezeThread.GetBusy: Boolean;
begin
  Result := FBusy.Value <> 0;
end;

function TgsDBSqueezeThread.GetState: Boolean;
begin
  Result := FState.Value <> 0;
end;

{
function TgsDBSqueezeThread.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;
}

function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
 try
  case Msg.Message of
    WM_DBS_STARTTESTCONNECT:
      begin
        FDBS.DatabaseName := FDatabaseName.Value;
        FDBS.UserName := FUserName.Value;
        FDBS.Password := FPassword.Value;
        FDBS.Connect(False, True);        // garbage collect ON
        
        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_GETINFOTESTCONNECT:
      begin
        if FState.Value = 1 then
        begin
          FDBS.GetInfoTestConnectEvent;
          FState.Value := 1;
        end;
        Result := True;
      end;

    WM_DBS_STOPTESTCONNECT:
      begin
        if FState.Value = 1 then
          FDBS.Disconnect;
        FDBS.DatabaseName := '';
        FDBS.UserName := '';
        FDBS.Password := '';
        
        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_SETPARAMS:
      begin
        FDBS.DatabaseName := FDatabaseName.Value;
        FDBS.UserName := FUserName.Value;
        FDBS.Password := FPassword.Value;

        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_GETDBSIZE:
      begin
        //if FConnected.Value = 0 then
        //begin
          FDBS.GetDBSizeEvent;
        //end;
        Result := True;
      end;

    WM_DBS_CONNECT:
      begin
        try
          FDBS.Connect(False, True);        // garbage collect ON
         // FConnected.Value := 1;
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0);
          Result := True;
        except
          on E: Exception do
          begin
            FDBS.LogEvent('[error]' + E.Message);

            FState.Value := 0;
            //Event на форму
          end;
        end;
      end;

    WM_DBS_CREATEDBSSTATEJOURNAL:
      begin
        //if FConnected.Value = 1 then
        //begin
          FDBS.CreateDBSStateJournal;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;
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

    WM_DBS_SETCOMPANYNAME:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
          FDBS.CompanyName := FCompanyName.Value;
       // end;
        Result := True;
      end;

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
        FDBS.OnlyCompanySaldo := FOnlyCompanySaldo;


        Result := True;
      end;

    WM_DBS_SETOPTIONS:
      begin
        FBusy.Value := 1;
        FDBS.SaveLog := FCreateBackup;
        FDBS.CreateBackup := FCreateBackup;
        FDBS.LogFileName := FLogFileName.Value;
        FDBS.BackupFileName := FBackupFileName.Value;
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

    WM_DBS_STARTPROCESSING:
      begin
        if FDBS.CreateBackup then
          FDBS.BackupDatabase;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;
        PostThreadMessage(ThreadID, WM_DBS_SETFVARIABLLES, 0, 0);
        Result := True;
      end;

    WM_DBS_STOPPROCESSING:
      begin
        //
      end;

    WM_DBS_SETFVARIABLLES:
      begin
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
          FDBS.CalculateInvSaldo;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEHIS_INCLUDEHIS, 0, 0);
        //end;
        Result := True;
      end;

    WM_DBS_CREATEHIS_INCLUDEHIS:
      begin
       // if FConnected.Value = 1 then
       // begin
          FBusy.Value := 1;
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

          FDBS.DeleteOldAcEntryBalance;
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

          FDBS.CreateInvSaldo;
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

          FDBS.PrepareRebindInvCards;
          FDBS.RebindInvCards;

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
          //FDBS.Reconnect(False, True);   // garbage collect ON

          FDBS.RestoreDB;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);
       // end;
        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FBusy.Value := 0;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin
       // if FConnected.Value = 1 then
      //  begin
          FDBS.Disconnect;
      //    FConnected.Value := 0;

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
    FDBS.LogEvent('[error]' + E.Message);  /// в лог ошибок
    FState.Value := 0;
    //Event на форму
  end;
 end;
end;

procedure TgsDBSqueezeThread.StartTestConnect(const ADatabaseName: String; const AUserName: String; const APassword: String);
begin
  //if not Connected then
  //begin
    FDatabaseName.Value := ADatabaseName;
    FUserName.Value := AUserName;
    FPassword.Value := APassword;
    PostMsg(WM_DBS_STARTTESTCONNECT);
  //end;
end;

procedure TgsDBSqueezeThread.StopTestConnect;
begin
  //FDatabaseName.Value := '';
  //FUserName.Value := '';
  //FPassword.Value := '';
  PostMsg(WM_DBS_STOPTESTCONNECT);
end;

procedure TgsDBSqueezeThread.SetCompanyName(const ACompanyName: String);
begin
  FCompanyName.Value := ACompanyName;
  PostMsg(WM_DBS_SETCOMPANYNAME);
end;

procedure TgsDBSqueezeThread.SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String);
begin
  FDatabaseName.Value := ADatabaseName;
  FUserName.Value := AUserName;
  FPassword.Value := APassword;
  PostMsg(WM_DBS_SETPARAMS);
end;

procedure TgsDBSqueezeThread.SetClosingDate(const AClosingDate: TDateTime);
begin
  FClosingDate := AClosingDate;
  PostMsg(WM_DBS_SETCLOSINGDATE);
end;

procedure TgsDBSqueezeThread.SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean);
begin
  FAllOurCompaniesSaldo := AAllOurCompanies;
  FOnlyCompanySaldo := AOnlyCompany;
  PostMsg(WM_DBS_SETSALDOPARAMS);
end;

procedure TgsDBSqueezeThread.SetOptions(const ASaveLog, ACreateBackup: Boolean;
  const ALogFileName: String; const ABackupFileName: String; AContinueReprocess: Boolean);
begin
  FSaveLog := ASaveLog;
  FCreateBackup:= ACreateBackup;
  FLogFileName.Value := ALogFileName;
  FBackupFileName.Value := ABackupFileName;
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
  FMessageStrList := AMessageStrList;
  Synchronize(DoOnSetItemsCbbSync);
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
  FMessagePropertiesList := AMessageProperties;
  Synchronize(DoOnGetDBPropertiesSync);
end;

procedure TgsDBSqueezeThread.DoGetDBSize;
begin
  PostMsg(WM_DBS_GETDBSIZE);
end;

procedure TgsDBSqueezeThread.GetDBSize(const AMessageDBSizeStr: String);
begin
  FMessageDBSizeStr := AMessageDBSizeStr;
  Synchronize(DoOnGetDBSizeSync);
end;

procedure TgsDBSqueezeThread.DoGetStatistics;
begin
  PostMsg(WM_DBS_GETSTATISTICS);
end;

procedure TgsDBSqueezeThread.GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String);
begin
  FMessageGdDocStr := AMessageGdDocStr;
  FMessageAcEntryStr := AMessageAcEntryStr;
  FMessageInvMovementStr := AMessageInvMovementStr;
  Synchronize(DoOnGetStatisticsSync);
end;
end.
