
unit gdDBSqueeze;

interface

uses
  IBDatabase;

type
  TgdDBSqueeze = class(TObject)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    

  public
    constructor Create;
    destructor Destroy; override;

    procedure Squeeze;
  end;

implementation

{ TgdDBSqueeze }

constructor TgdDBSqueeze.Create;
begin
  FDatabase := TIBDatabase.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
end;

destructor TgdDBSqueeze.Destroy;
begin
  FTransaction.Free;
  FDatabase.Free;
  inherited;
end;

procedure TgdDBSqueeze.Squeeze;
begin
  FDatabase.DatabaseName := 'localhost:d:\t.fdb';
  FDatabase.Params.Text := 'user_name=SYSDBA'#13#10'password=masterkey'#13#10'lc_ctype=win1251';
  FDatabase.LoginPrompt := False;
  FDatabase.Connected := True;

  FTransaction.DefaultDatabase := FDatabase;
  FTransaction.StartTransaction;
end;

end.