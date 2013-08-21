unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  WM_DBS_SETPARAMS             = WM_USER + 1;
  WM_DBS_STARTTESTCONNECTION   = WM_USER + 2;
  WM_DBS_GETSERVERVERSION      = WM_USER + 3;
  WM_DBS_STOPTESTCONNECTION    = WM_USER + 4;
  WM_DBS_GETDBSIZE             = WM_USER + 5;
  WM_DBS_CONNECT               = WM_USER + 6;
  WM_DBS_SETFVARIABLLES        = WM_USER + 7;
  WM_DBS_CREATEDBSSTATEJOURNAL = WM_USER + 8;
  WM_DBS_GETSTATISTICS         = WM_USER + 9;
  WM_DBS_SETSALDOPARAMS        = WM_USER + 10;
  WM_DBS_SETCBBITEMS           = WM_USER + 11;
  WM_DBS_SETCLOSINGDATE        = WM_USER + 12;
  WM_DBS_SETCOMPANYNAME        = WM_USER + 13;
  WM_DBS_CREATEMETADATA        = WM_USER + 14;
  WM_DBS_SAVEMETADATA          = WM_USER + 15;
  WM_DBS_CALCULATEACSALDO      = WM_USER + 16;
  WM_DBS_CALCULATEINVSALDO     = WM_USER + 17;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_USER + 18;
  WM_DBS_PREPAREDB             = WM_USER + 19;
  WM_DBS_DELETEOLDBALANCE      = WM_USER + 20;
  WM_DBS_DELETEDOCHIS          = WM_USER + 21;
  WM_DBS_CREATEACENTRIES       = WM_USER + 22;
  WM_DBS_CREATEINVSALDO        = WM_USER + 23;
  WM_DBS_REBINDINVCARDS        = WM_USER + 24;
  WM_DBS_RESTOREDB             = WM_USER + 25;
  WM_DBS_FINISHED              = WM_USER + 26;
  WM_DBS_DISCONNECT            = WM_USER + 27;

type
  //TGetConnectedEvent = procedure (const MsgConnected: Boolean) of object;
  TGetServerVersionEvent = procedure (const MsgServerVersionStr: String) of object;
  TCbbEvent = procedure (const MsgStrList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FBusy: TidThreadSafeInteger;
    FCompanyName: TidThreadSafeString;
    FDatabaseName, FUserName, FPassword: TidThreadSafeString;
    FClosingDate: TDateTime;

    FDBS: TgsDBSqueeze;

    FState: TidThreadSafeInteger;

    //FMessageConnected: Boolean;
    FMessageServerVersionStr: String;    
    FMessageStrList: TStringList;
    FMessageDBSizeStr: String;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr: String;

    //FOnGetConnected: TGetConnectedEvent;
    FOnGetServerVersion: TGetServerVersionEvent;
    FOnSetItemsCbb: TCbbEvent;
    FOnGetDBSize: TGetDBSizeEvent;
    FOnGetStatistics: TGetStatisticsEvent;

    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    //procedure DoOnGetConnectedSync;
    procedure DoOnGetServerVersionSync;
    procedure DoOnSetItemsCbbSync;
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;

    //procedure GetConnected(const MessageConnected: Boolean);
    procedure GetServerVersion(const AMessageServerVersionStr: String);
    procedure SetItemsCbb(const AMessageStrList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String);

    function GetConnected: Boolean;
    function GetBusy: Boolean;
    function GetState: Boolean;
  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    procedure StartTestConnection;
    procedure StopTestConnection;

    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean);
    //procedure DoGetConnected;
    procedure DoGetServerVersion;
    procedure DoSetItemsCbb;
    procedure DoGetDBSize;
    procedure DoGetStatistics;
    procedure SetCompanyName(const ACompanyName: String);
    procedure SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String);
    procedure SetClosingDate(const AClosingDate: TDateTime);

    property Connected: Boolean read GetConnected;
    property State: Boolean read GetState;
    property Busy: Boolean read GetBusy;
    //property OnGetConnected: TGetConnectedEvent read TOnGetConnected write TOnGetConnected;
    property OnGetServerVersion: TGetServerVersionEvent read FOnGetServerVersion write FOnGetServerVersion;
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
  //FDBS.OnGetConnected := DoOnGetConnected;
  FDBS.OnGetServerVersionEvent := GetServerVersion;
  FDBS.OnSetItemsCbbEvent := SetItemsCbb;
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FDatabaseName := TIdThreadSafeString.Create;
  FUserName := TIdThreadSafeString.Create;
  FPassword := TIdThreadSafeString.Create;
  FCompanyName := TIdThreadSafeString.Create;
  FBusy := TIdThreadSafeInteger.Create;

  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FDatabaseName.Free;
  FUserName.Free;
  FPassword.Free;
  FCompanyName.Free;
  FBusy.Free;
end;

function TgsDBSqueezeThread.GetConnected: Boolean;
begin
  Result := FDBS.Connected;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  if not FDBS.Connected then
    PostMsg(WM_DBS_CONNECT);
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  if FDBS.Connected and (not Busy) then
    PostMsg(WM_DBS_DISCONNECT);
end;

procedure TgsDBSqueezeThread.StartTestConnection;
begin
  if Connected and (not Busy) then
    PostMsg(WM_DBS_STARTTESTCONNECTION);
end;

procedure TgsDBSqueezeThread.StopTestConnection;
begin
  if Connected and (not Busy) then
    PostMsg(WM_DBS_STOPTESTCONNECTION);
end;

procedure TgsDBSqueezeThread.DoOnGetServerVersionSync;
begin
  if Assigned(FOnGetServerVersion) then
    FOnGetServerVersion(FMessageServerVersionStr);
end;

procedure TgsDBSqueezeThread.DoOnSetItemsCbbSync;
begin
  if Assigned(FOnSetItemsCbb) then
    FOnSetItemsCbb(FMessageStrList);
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

function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
 try
  case Msg.Message of
    WM_DBS_SETPARAMS:
      begin
        FDBS.DatabaseName := FDatabaseName.Value;
        FDBS.UserName := FUserName.Value;
        FDBS.Password := FPassword.Value;

        FState.Value := 1;
        Result := True;
      end;

    WM_DBS_STARTTESTCONNECTION:
      begin
        FDBS.StartTestConnection;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_GETSERVERVERSION:
      begin
        FDBS.GetServerVersionEvent;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_STOPTESTCONNECTION:
      begin
        FDBS.StopTestConnection;

        FDBS.InsertDBSStateJournal(Msg.Message, 1);
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

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0);
          Result := True;
        except
          on E: Exception do
          begin
            FDBS.LogEvent('[error]' + E.Message);  /// в лог ошибок
            FState.Value := 0;
            //Event на форму: перепроверьте корректность данных.
          end;
        end;
      end;

    WM_DBS_CREATEDBSSTATEJOURNAL:
      begin

          FDBS.CreateDBSStateJournal;


        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        PostThreadMessage(ThreadID, WM_DBS_SETFVARIABLLES, 0, 0);
        Result := True;
      end;

    WM_DBS_SETFVARIABLLES:
      begin
          FDBS.SetFVariables;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEDBSSTATEJOURNAL, 0, 0);
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

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
        FDBS.OnlyCompanySaldo := FOnlyCompanySaldo;
        PostThreadMessage(ThreadID, WM_DBS_CREATEMETADATA, 0, 0);

        Result := True;
      end;

    WM_DBS_SETCBBITEMS:
      begin

          //FBusy.Value := 1;
          FDBS.SetItemsCbbEvent;


        FDBS.InsertDBSStateJournal(Msg.Message, 1);
        FState.Value := 1;

        Result := True;
      end;

    WM_DBS_SETCLOSINGDATE:
      begin
        FDBS.ClosingDate := FClosingDate;
        Result := True;
      end;

    WM_DBS_SETCOMPANYNAME:
      begin

          FBusy.Value := 1;
          FDBS.CompanyName := FCompanyName.Value;

        Result := True;
      end;

    WM_DBS_CREATEMETADATA:
      begin

          FBusy.Value := 1;
          FDBS.CreateMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_SAVEMETADATA, 0, 0);

        Result := True;
      end;

    WM_DBS_SAVEMETADATA:
      begin

          FBusy.Value := 1;
          FDBS.SaveMetadata;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEACSALDO, 0, 0);

        Result := True;
      end;

    WM_DBS_CALCULATEACSALDO:
      begin

          FBusy.Value := 1;
          FDBS.CalculateAcSaldo;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CALCULATEINVSALDO, 0, 0);

        Result := True;
      end;

    WM_DBS_CALCULATEINVSALDO:
      begin

          FBusy.Value := 1;
          FDBS.CalculateInvSaldo;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEHIS_INCLUDEHIS, 0, 0);

        Result := True;
      end;

    WM_DBS_CREATEHIS_INCLUDEHIS:
      begin

          FBusy.Value := 1;
          FDBS.CreateHIS_IncludeInHIS;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);

        Result := True;
      end;

    WM_DBS_PREPAREDB:
      begin

          FBusy.Value := 1;
          //FDBS.Reconnect(True, True);    // garbage collect OFF
          FDBS.PrepareDB;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEOLDBALANCE, 0, 0);

        Result := True;
      end;

    WM_DBS_DELETEOLDBALANCE:
      begin

          FBusy.Value := 1;

          FDBS.DeleteOldAcEntryBalance;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_DELETEDOCHIS, 0, 0);


        Result := True;
      end;

    WM_DBS_DELETEDOCHIS:
      begin

          FBusy.Value := 1;

          FDBS.DeleteOldAcEntryBalance;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEACENTRIES, 0, 0);


        Result := True;
      end;

    WM_DBS_CREATEACENTRIES:
      begin

          FBusy.Value := 1;

          FDBS.CreateAcEntries;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_CREATEINVSALDO, 0, 0);


        Result := True;
      end;

    WM_DBS_CREATEINVSALDO:
      begin

          FBusy.Value := 1;

          FDBS.CreateInvSaldo;
          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_REBINDINVCARDS, 0, 0);


        Result := True;
      end;

    WM_DBS_REBINDINVCARDS:
      begin

          FBusy.Value := 1;

          FDBS.PrepareRebindInvCards;
          FDBS.RebindInvCards;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_RESTOREDB, 0, 0);

        Result := True;
      end;

    WM_DBS_RESTOREDB:
      begin

          //FDBS.Reconnect(False, True);   // garbage collect ON

          FDBS.RestoreDB;

          FDBS.InsertDBSStateJournal(Msg.Message, 1);
          FState.Value := 1;

          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);

        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FBusy.Value := 0;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin

          FDBS.Disconnect;

          FState.Value := 1;
        
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
    //Event на форму: завершение!
  end;
 end;
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

procedure TgsDBSqueezeThread.DoSetItemsCbb;
begin
  PostMsg(WM_DBS_SETCBBITEMS);
end;

procedure TgsDBSqueezeThread.SetItemsCbb(const AMessageStrList: TStringList);
begin
  FMessageStrList := AMessageStrList;
  Synchronize(DoOnSetItemsCbbSync);
end;

procedure TgsDBSqueezeThread.DoGetServerVersion;
begin
  PostMsg(WM_DBS_GETSERVERVERSION);
end;

procedure TgsDBSqueezeThread.GetServerVersion(const AMessageServerVersionStr: String);
begin
  FMessageServerVersionStr := AMessageServerVersionStr;
  Synchronize(DoOnGetServerVersionSync);
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
