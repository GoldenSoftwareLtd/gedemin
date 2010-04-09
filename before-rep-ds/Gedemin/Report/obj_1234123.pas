unit obj_1234123;

interface

uses
  ComObj, ActiveX, TestPr2_TLB, StdVcl, IBQuery;

type
  TcoQuery = class(TAutoObject, IcoQuery)
  private
    FIBQuery: TIBQuery;
    FIsResult: Boolean;
  protected
    function Get_ResultData: WordBool; safecall;
    procedure Close; safecall;
    procedure Open; safecall;
    procedure Set_ResultData(Value: WordBool); safecall;
    function Get_Eof: WordBool; safecall;
    function Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    { Protected declarations }
  public
    constructor Create;
    destructor Destroy; override;

    property IBQuery: TIBQuery read FIBQuery;
    property IsResult: Boolean read FIsResult;
  end;

implementation

uses ComServ;

constructor TcoQuery.Create;
begin
  FIBQuery := TIBQuery.Create(nil);
end;

destructor TcoQuery.Destroy;
begin
  FIBQuery.Free;

  inherited;
end;

function TcoQuery.Get_ResultData: WordBool;
begin
  Result := FIsResult;
end;

procedure TcoQuery.Close;
begin
  FIBQuery.Close;
end;

procedure TcoQuery.Open;
begin
  FIBQuery.Open;
end;

procedure TcoQuery.Set_ResultData(Value: WordBool);
begin
  FIsResult := Value;
end;

function TcoQuery.Get_Eof: WordBool;
begin
  Result := FIBQuery.Eof;
end;

function TcoQuery.Get_SQL: WideString;
begin
  Result := FIBQuery.SQL.Text;
end;

procedure TcoQuery.Set_SQL(const Value: WideString);
begin
  FIBQuery.SQL.Text := Value;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TcoQuery, Class_coQuery,
    ciMultiInstance, tmApartment);
end.
