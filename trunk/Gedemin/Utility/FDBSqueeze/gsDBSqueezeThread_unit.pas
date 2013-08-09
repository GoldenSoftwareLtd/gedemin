unit gsDBSqueezeThread_unit;

interface

uses
  SysUtils, Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  WM_DBS_SETPARAMS             = WM_USER + 1;
  WM_DBS_GETDBSIZE             = WM_USER + 2;
  WM_DBS_CONNECT               = WM_USER + 3;
  WM_DBS_GETSTATISTICS         = WM_USER + 4;
  WM_DBS_SETSALDOPARAMS        = WM_USER + 5;
  WM_DBS_SETCBBITEMS           = WM_USER + 6;
  WM_DBS_SETCLOSINGDATE        = WM_USER + 7;
  WM_DBS_SETCOMPANYNAME        = WM_USER + 8;
  WM_DBS_TESTANDCREATEMETADATA = WM_USER + 9;
  WM_DBS_CALCULATESALDO        = WM_USER + 10;
  WM_DBS_PREPAREDB             = WM_USER + 11;
  WM_DBS_DELETEDOCS            = WM_USER + 12;
  WM_DBS_RESTOREDB             = WM_USER + 13;
  WM_DBS_FINISHED              = WM_USER + 14;
  WM_DBS_DISCONNECT            = WM_USER + 15;

type
  TCbbEvent = procedure (const MsgStrList: TStringList) of object;
  TGetDBSizeEvent = procedure (const MsgStr: String) of object;
  TGetStatisticsEvent = procedure (const MsgGdDocStr: String; const MsgAcEntryStr: String; const MsgInvMovementStr: String) of object;

  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FBusy: TidThreadSafeInteger;
    FCompanyName: TidThreadSafeString;
    FConnected: TidThreadSafeInteger;
    FDatabaseName, FUserName, FPassword: TidThreadSafeString;
    FClosingDate: TDateTime;

    FDBS: TgsDBSqueeze;

    FMessageStrList: TStringList;
    FMessageDBSizeStr: String;
    FMessageGdDocStr, FMessageAcEntryStr, FMessageInvMovementStr: String;

    FOnSetItemsCbb: TCbbEvent;
    FOnGetDBSize: TGetDBSizeEvent;
    FOnGetStatistics: TGetStatisticsEvent;

    FAllOurCompaniesSaldo: Boolean;
    FOnlyCompanySaldo: Boolean;

    procedure DoOnSetItemsCbbSync;
    procedure DoOnGetDBSizeSync;
    procedure DoOnGetStatisticsSync;
    procedure SetItemsCbb(const AMessageStrList: TStringList);
    procedure GetDBSize(const AMessageDBSizeStr: String);
    procedure GetStatistics(const AMessageGdDocStr: String; const AMessageAcEntryStr: String; const AMessageInvMovementStr: String);

    function GetBusy: Boolean;
    function GetConnected: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure SetSaldoParams(const AAllOurCompanies: Boolean; const AOnlyCompany: Boolean);
    procedure DoSetItemsCbb;
    procedure DoGetDBSize;
    procedure DoGetStatistics;
    procedure SetCompanyName(const ACompanyName: String);
    procedure SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String);
    procedure SetClosingDate(const AClosingDate: TDateTime);

    property Busy: Boolean read GetBusy;
    property Connected: Boolean read GetConnected;
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
  FDBS.OnSetItemsCbbEvent := SetItemsCbb;
  FDBS.OnGetDBSizeEvent := GetDBSize;
  FDBS.OnGetStatistics := GetStatistics;
  FDatabaseName := TIdThreadSafeString.Create;
  FUserName := TIdThreadSafeString.Create;
  FPassword := TIdThreadSafeString.Create;
  FCompanyName := TIdThreadSafeString.Create;
  FConnected := TIdThreadSafeInteger.Create;
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
  FConnected.Free;
  FBusy.Free;
end;

procedure TgsDBSqueezeThread.Connect;
begin
  if not Connected then
    PostMsg(WM_DBS_CONNECT);
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  if Connected and (not Busy) then
    PostMsg(WM_DBS_DISCONNECT);
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

function TgsDBSqueezeThread.GetConnected: Boolean;
begin
  Result := FConnected.Value <> 0;
end;

function TgsDBSqueezeThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  case Msg.Message of
    WM_DBS_SETPARAMS:
      begin
        FDBS.DatabaseName := FDatabaseName.Value;
        FDBS.UserName := FUserName.Value;
        FDBS.Password := FPassword.Value;
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
        FDBS.Connect;
        FConnected.Value := 1;

        Result := True;
      end;

    WM_DBS_GETSTATISTICS:
      begin
        //if FConnected.Value = 0 then
        //begin
          FDBS.GetStatisticsEvent;
        //end;
        Result := True;
      end;

    WM_DBS_SETSALDOPARAMS:
      begin
        FDBS.AllOurCompaniesSaldo := FAllOurCompaniesSaldo;
        FDBS.OnlyCompanySaldo := FOnlyCompanySaldo;
        PostThreadMessage(ThreadID, WM_DBS_TESTANDCREATEMETADATA, 0, 0);
        Result := True;
      end;

    WM_DBS_SETCBBITEMS:
      begin
        if FConnected.Value = 1 then
        begin
          //FBusy.Value := 1;
          FDBS.SetItemsCbbEvent;
        end;
        Result := True;
      end;

    WM_DBS_SETCLOSINGDATE:
      begin
        FDBS.ClosingDate := FClosingDate;
        Result := True;
      end;

    WM_DBS_SETCOMPANYNAME:
      begin
        if FConnected.Value = 1 then
        begin
          FBusy.Value := 1;
          FDBS.CompanyName := FCompanyName.Value;
        end;
        Result := True;
      end;

    WM_DBS_TESTANDCREATEMETADATA:
      begin
        if FConnected.Value = 1 then
        begin
          FBusy.Value := 1;
          FDBS.TestAndCreateMetadata;
          PostThreadMessage(ThreadID, WM_DBS_CALCULATESALDO, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_CALCULATESALDO:
      begin
        if FConnected.Value = 1 then
        begin
          //FDBS.SetBlockTriggerActive(False);

          FDBS.CalculateAcSaldo;
          //FDBS.CalculateInvSaldo;

          //FDBS.SetBlockTriggerActive(True);

          PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_PREPAREDB:
      begin
        if FConnected.Value = 1 then
        begin
          FDBS.PrepareDB;
          PostThreadMessage(ThreadID, WM_DBS_DELETEDOCS, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_DELETEDOCS:
      begin
        if FConnected.Value = 1 then
        begin
          FBusy.Value := 1;
          FDBS.DeleteDocuments;
          FDBS.CreateAcEntries;                                                 ///TODO: оформить
          PostThreadMessage(ThreadID, WM_DBS_RESTOREDB, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_RESTOREDB:
      begin
        if FConnected.Value = 1 then
        begin
          FDBS.RestoreDB;
          PostThreadMessage(ThreadID, WM_DBS_FINISHED, 0, 0);
        end;
        Result := True;
      end;

    WM_DBS_FINISHED:
      begin
        FBusy.Value := 0;
        Result := True;
      end;

    WM_DBS_DISCONNECT:
      begin
        if FConnected.Value = 1 then
        begin
          FDBS.Disconnect;
          FConnected.Value := 0;
        end;
        Result := True;
      end;
  else
    Result := False;
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
