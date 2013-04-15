
unit gsDBSqueezeThread_unit;

interface

uses
  Classes, SyncObjs, Messages, gsDBSqueeze_unit, gdMessagedThread, Windows,
  idThreadSafe, gd_ProgressNotifier_unit;

const
  WM_DBS_SET_PARAMS   = WM_USER + 1;
  WM_DBS_CONNECT      = WM_USER + 2;
  WM_DBS_DISCONNECT   = WM_USER + 3;

type
  TgsDBSqueezeThread = class(TgdMessagedThread)
  private
    FDBS: TgsDBSqueeze;
    FDatabaseName, FUserName, FPassword: TidThreadSafeString;
    FConnected: TidThreadSafeInteger;

    function GetConnected: Boolean;
    function GetBusy: Boolean;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;

  public
    constructor Create(const CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure SetDBParams(const ADatabaseName: String; const AUserName: String;
      const APassword: String);
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
  FConnected := TIdThreadSafeInteger.Create;
  inherited Create(CreateSuspended);
end;

destructor TgsDBSqueezeThread.Destroy;
begin
  inherited;
  FDBS.Free;
  FDatabaseName.Free;
  FUserName.Free;
  FPassword.Free;
  FConnected.Free;
end;

procedure TgsDBSqueezeThread.Disconnect;
begin
  if Connected then
    PostMsg(WM_DBS_DISCONNECT);
end;

function TgsDBSqueezeThread.GetBusy: Boolean;
begin
  Result := False;
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
      Result := True;
    end;

    WM_DBS_CONNECT:
    begin
      FDBS.Connect;
      FConnected.Value := 1;
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
end;

procedure TgsDBSqueezeThread.SetDBParams(const ADatabaseName, AUserName,
  APassword: String);
begin
  FDatabaseName.Value := ADatabaseName;
  FUserName.Value := AUserName;
  FPassword.Value := APassword;
  PostMsg(WM_DBS_SET_PARAMS);
end;

end.
