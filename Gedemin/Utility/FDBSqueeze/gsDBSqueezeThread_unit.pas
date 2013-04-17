
unit gsDBSqueezeThread_unit;

interface

uses
  Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  WM_DBS_SET_PARAMS            = WM_USER + 1;
  WM_DBS_CONNECT               = WM_USER + 2;
  WM_DBS_DISCONNECT            = WM_USER + 3;
  WM_DBS_TESTANDCREATEMETADATA = WM_USER + 4;
  WM_DBS_PREPAREDB             = WM_USER + 5;
  WM_DBS_RESTOREDB             = WM_USER + 6;
  WM_DBS_FINISHED              = WM_USER + 7;
  WM_DBS_DELETE                = WM_USER + 8;

type
  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FDBS: TgsDBSqueeze;
    FDatabaseName, FUserName, FPassword, FDelCondition: TidThreadSafeString;
    FConnected: TidThreadSafeInteger;
    FBusy: TidThreadSafeInteger;

    function GetConnected: Boolean;
    function GetBusy: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String; const ADelCondition: String);
    procedure Connect;
    procedure Disconnect;

    property Connected: Boolean read GetConnected;
    property Busy: Boolean read GetBusy;
  end;

implementation

{ TgsDBSqueezeThread }

procedure TgsDBSqueezeThread.Connect;
begin
  if not Connected then
    PostMsg(WM_DBS_CONNECT);
end;

constructor TgsDBSqueezeThread.Create(const CreateSuspended: Boolean);
begin
  FDBS := TgsDBSqueeze.Create;
  FDBS.OnProgressWatch := DoOnProgressWatch;
  FDatabaseName := TIdThreadSafeString.Create;
  FUserName := TIdThreadSafeString.Create;
  FPassword := TIdThreadSafeString.Create;
  FDelCondition := TIdThreadSafeString.Create;
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
  FDelCondition.Free;
  FConnected.Free;
  FBusy.Free;
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  if Connected and (not Busy) then
    PostMsg(WM_DBS_DISCONNECT);
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
    WM_DBS_SET_PARAMS:
    begin
      FDBS.DatabaseName := FDatabaseName.Value;
      FDBS.UserName := FUserName.Value;
      FDBS.Password := FPassword.Value;
      FDBS.DelCondition := FDelCondition.Value;
      Result := True;
    end;

    WM_DBS_CONNECT:
    begin
      FDBS.Connect;
      FConnected.Value := 1;
      PostThreadMessage(ThreadID, WM_DBS_TESTANDCREATEMETADATA, 0, 0);
      Result := True;
    end;

    WM_DBS_TESTANDCREATEMETADATA:
    begin
      if FConnected.Value = 1 then
      begin
        FBusy.Value := 1;
        FDBS.TestAndCreateMetadata;
        PostThreadMessage(ThreadID, WM_DBS_PREPAREDB, 0, 0);
      end;
      Result := True;
    end;

    WM_DBS_DELETE:
    begin
      if FConnected.Value = 1 then
      begin
        FBusy.Value := 1;
        FDBS.Delete;
        PostThreadMessage(ThreadID, WM_DBS_DELETE, 0, 0);
      end;
      Result := True;
    end;

    WM_DBS_PREPAREDB:
    begin
      if FConnected.Value = 1 then
      begin
        FDBS.PrepareDB;
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

procedure TgsDBSqueezeThread.SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String; const ADelCondition: String);
begin
  FDatabaseName.Value := ADatabaseName;
  FUserName.Value := AUserName;
  FPassword.Value := APassword;
  FDelCondition.Value := ADelCondition;
  PostMsg(WM_DBS_SET_PARAMS);
end;

end.
