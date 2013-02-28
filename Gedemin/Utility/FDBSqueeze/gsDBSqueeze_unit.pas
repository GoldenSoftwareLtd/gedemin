unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase;

type
  TgsDBSqueeze = class(TObject)
  private
    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    function GetConnected: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property Connected: Boolean read GetConnected;
  end;

implementation

{ TgsDBSqueeze }

procedure TgsDBSqueeze.Connect;
begin
  FIBDatabase.DatabaseName := FDatabaseName;
  FIBDatabase.LoginPrompt := False;
  FIBDatabase.Params.Text :=
    'user_name=' + FUserName + #13#10 +
    'password=' + FPassword + #13#10 +
    'lc_ctype=win1251';
  FIBDatabase.Connected := True;  
end;

constructor TgsDBSqueeze.Create;
begin
  inherited;
  FIBDatabase := TIBDatabase.Create(nil);
end;

destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;
  inherited;
end;

procedure TgsDBSqueeze.Disconnect;
begin
  FIBDatabase.Connected := False;
end;

function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;

end.
