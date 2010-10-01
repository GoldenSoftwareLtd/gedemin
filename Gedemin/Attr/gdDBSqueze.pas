
unit gdDBSqueze;

interface

uses
  IBDatabase;

type
  TgdDBSqueze = class(TObject)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    

  public
    constructor Create;
    destructor Destroy; override;

    procedure Squeze;
  end;

implementation

{ TgdDBSqueze }

constructor TgdDBSqueze.Create;
begin
  FDatabase := TIBDatabase.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
end;

destructor TgdDBSqueze.Destroy;
begin
  FTransaction.Free;
  FDatabase.Free;
  inherited;
end;

procedure TgdDBSqueze.Squeze;
begin
  FDatabase.DatabaseName := 'localhost:d:\t.fdb';
  FDatabase.Params.Text := 'user_name=SYSDBA'#13#10'password=masterkey'#13#10'lc_ctype=win1251';
  FDatabase.LoginPrompt := False;
  FDatabase.Connected := True;

  FTransaction.DefaultDatabase := FDatabase;
  FTransaction.StartTransaction;
end;

end.