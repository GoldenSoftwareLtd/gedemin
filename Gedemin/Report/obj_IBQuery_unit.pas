// ShlTanya, 27.02.2019

unit obj_IBQuery_unit;

interface

uses
  ComObj, ActiveX, TestPr_TLB, StdVcl, IBQuery, IBDatabase, SysUtils, DB, Classes;

type
  TIBQueryTest = class(TAutoObject, IIBQueryTest)
  private
    FIBQuery: TIBQuery;

  protected
    procedure Open; safecall;
    function Get_SQL: WideString; safecall;
    procedure Set_SQL(const Value: WideString); safecall;
    procedure Close; safecall;
    function Get_Eof: WordBool; safecall;
  public
    constructor Create;
    destructor Destroy; override;

    property IBQuery: TIBQuery read FIBQuery;
  end;

type
  TIBQueryList = class
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    FQueryList: TList;

    function GetQuery(AnIndex: Integer): TIBQueryTest;
    procedure SetQuery(AnIndex: Integer; AnValue: TIBQueryTest);
    function GetCount: Integer;
  protected
  public
    constructor Create(const Database: TIBDatabase; const Transaction: TIBTransaction);
    destructor Destroy; override;

    function AddQuery: Integer;
    procedure DeleteQuery(const AnIndex: Integer);
    procedure Clear;

    property Count: Integer read GetCount;
    property Querys[AnIndex: Integer]: TIBQueryTest read GetQuery write SetQuery;
  end;

type
  TQueryList = class(TAutoObject, IQueryList)
  private
    FQueryList: TIBQueryList;
    FResultIndex: Integer;

    function GetResultIndex: Integer;
  protected
    procedure AddQuery; safecall;
    procedure DeleteQuery(Index: Integer); safecall;
    function Get_Query(Index: Integer): IIBQueryTest; safecall;
    procedure Set_Query(Index: Integer; const Value: IIBQueryTest); safecall;
    function Get_Count: Integer; safecall;
    procedure Clear; safecall;
    function Get_ResultIndex: Integer; safecall;
    procedure Set_ResultIndex(AnIndex: Integer); safecall;
  public
    constructor Create(const Database: TIBDatabase; const Transaction: TIBTransaction);
    destructor Destroy; override;
    property ResultIndex: Integer read GetResultIndex;
    property QueryList: TIBQueryList read FQueryList;
    procedure ClearQuery;
  end;

implementation

uses ComServ;

constructor TIBQueryTest.Create;
begin
  inherited Create;

  FIBQuery := TIBQuery.Create(nil)
end;

destructor TIBQueryTest.Destroy;
begin
  FIBQuery.Free;
  FIBQuery := nil;

  inherited Destroy;
end;

procedure TIBQueryTest.Open;
begin
  FIBQuery.Open;
end;

function TIBQueryTest.Get_SQL: WideString;
begin
  Result := FIBQuery.SQL.Text;
end;

procedure TIBQueryTest.Set_SQL(const Value: WideString);
begin
  FIBQuery.SQL.Text := Value;
end;

procedure TIBQueryTest.Close;
begin
  FIBQuery.Close;
end;

function TIBQueryTest.Get_Eof: WordBool;
begin
  Result := FIBQuery.Eof;
end;

constructor TQueryList.Create(const Database: TIBDatabase; const Transaction: TIBTransaction);
begin
  inherited Create;

  FQueryList := TIBQueryList.Create(Database, Transaction);
  FResultIndex := -1;
end;

destructor TQueryList.Destroy;
begin
  FQueryList.Free;

  inherited Destroy;
end;

procedure TQueryList.AddQuery;
begin
  FQueryList.AddQuery;
end;

procedure TQueryList.DeleteQuery(Index: Integer);
begin
  FQueryList.DeleteQuery(Index);
end;

function TQueryList.Get_Query(Index: Integer): IIBQueryTest;
begin
  Result := FQueryList.Querys[Index];
end;

procedure TQueryList.Set_Query(Index: Integer; const Value: IIBQueryTest);
begin
end;

constructor TIBQueryList.Create(const Database: TIBDatabase; const Transaction: TIBTransaction);
begin
  inherited Create;

  FDatabase := Database;
  FTransaction := Transaction;

  FQueryList := TList.Create;
end;

destructor TIBQueryList.Destroy;
begin
//  Clear;
  FQueryList.Free;

  FDatabase := nil;
  FTransaction := nil;

  inherited Destroy;
end;

function TIBQueryList.GetCount: Integer;
begin
  Result := FQueryList.Count;
end;

function TIBQueryList.AddQuery: Integer;
begin
  Result := FQueryList.Add(TIBQueryTest.Create);
  TIBQueryTest(FQueryList.Items[Result]).IBQuery.Database := FDatabase;
  TIBQueryTest(FQueryList.Items[Result]).IBQuery.Transaction := FTransaction;
end;

procedure TIBQueryList.DeleteQuery(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  {if FQueryList.Items[AnIndex] <> nil then
    TIBQueryTest(FQueryList.Items[AnIndex]).Free;}
  FQueryList.Delete(AnIndex);
end;

procedure TIBQueryList.Clear;
var
  I: Integer;
begin
  for I := FQueryList.Count - 1 downto 0 do
    DeleteQuery(I);
end;

function TIBQueryList.GetQuery(AnIndex: Integer): TIBQueryTest;
begin
  Assert((AnIndex >= 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  Result := FQueryList.Items[AnIndex];
end;

procedure TIBQueryList.SetQuery(AnIndex: Integer; AnValue: TIBQueryTest);
begin
  Assert((AnIndex >= 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  TIBQueryTest(FQueryList.Items[AnIndex]).IBQuery.Assign(AnValue.IBQuery);
end;

function TQueryList.Get_Count: Integer;
begin
  Result := FQueryList.Count;
end;

procedure TQueryList.ClearQuery;
begin
  FQueryList.Clear;
end;

procedure TQueryList.Clear;
begin
  FQueryList.Clear;
end;

function TQueryList.GetResultIndex: Integer;
begin
  Result := FResultIndex;
end;

function TQueryList.Get_ResultIndex: Integer;
begin
  Result := FResultIndex;
end;

procedure TQueryList.Set_ResultIndex(AnIndex: Integer);
begin
  Assert((AnIndex >= 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  FResultIndex := AnIndex;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TIBQueryTest, Class_IBQueryTest,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TQueryList, Class_QueryList,
    ciMultiInstance, tmApartment);
end.
