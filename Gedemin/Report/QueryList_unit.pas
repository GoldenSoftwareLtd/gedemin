// ShlTanya, 27.02.2019

unit QueryList_unit;

interface

uses
  Classes, IBDatabase, IBQuery;

type
  TQueryList = class
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    FQueryList: TList;

    function GetQuery(AnIndex: Integer): TIBQuery;
    procedure SetQuery(AnIndex: Integer; AnValue: TIBQuery);
  protected

  public
    constructor Create;
    destructor Destroy; override;

    function AddQuery: Integer;
    procedure DeleteQuery(const AnIndex: Integer);
    procedure Clear;

    property Querys[AnIndex: Integer]: TIBQuery read GetQuery;
  end;

implementation

constructor TQueryList.Create;
begin
  inherited Create;

  FDatabase := nil;
  FTransaction := nil;

  FQueryList := TList.Create;
end;

destructor TQueryList.Destroy;
begin
  Clear;
  FQueryList.Free;

  FDatabase := nil;
  FTransaction := nil;

  inherited Destroy;
end;

function TQueryList.AddQuery: Integer;
begin
  Result := FQueryList.Add(TIBQuery.Create(nil));
  TIBQuery(FQueryList.Items[Result]).Database := FDatabase;
  TIBQuery(FQueryList.Items[Result]).Transaction := FTransaction;
end;

procedure TQueryList.DeleteQuery(const AnIndex: Integer);
begin
  Assert((AnIndex > 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  TIBQuery(FQueryList.Items[AnIndex]).Free;
  FQueryList.Delete(AnIndex);
end;

procedure TQueryList.Clear;
var
  I: Integer;
begin
  for I := FQueryList.Count - 1 downto 0 do
    DeleteQuery(I);
end;

function TQueryList.GetQuery(AnIndex: Integer): TIBQuery;
begin
  Assert((AnIndex > 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  Result := FQueryList.Items[AnIndex];
end;

procedure TQueryList.SetQuery(AnIndex: Integer; AnValue: TIBQuery);
begin
  Assert((AnIndex > 0) and (AnIndex < FQueryList.Count), 'Index out of range');
  TIBQuery(FQueryList.Items[AnIndex]).Assign(AnValue);
end;

end.
