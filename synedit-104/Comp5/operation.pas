
unit Operation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables;

// тип операции
type
  TOpTypeKey = Integer;

// тип операции
type
  TOpType = class(TObject)
  private
    FAlias: String;
    FName: String;
    FOpTypeKey: TOpTypeKey;
    FParentKey: TOpTypeKey;

    procedure SetAlias(const Value: String);
    procedure SetName(const Value: String);
    procedure SetOpTypeKey(const Value: TOpTypeKey);
    procedure SetParentKey(const Value: TOpTypeKey);
//    function GetFieldDefs(Index: Integer): TboFieldDef;
//    procedure SetFieldDefs(Index: Integer; const Value: TboFieldDef);

  public
    constructor Create;
    destructor Destroy; override;

    property OpTypeKey: TOpTypeKey read FOpTypeKey write SetOpTypeKey;
    property ParentKey: TOpTypeKey read FParentKey write SetParentKey;
    property Name: String read FName write SetName;
    property Alias: String read FAlias write SetAlias;
//    property FieldDefs[Index: Integer]: TboFieldDef read GetFieldDefs write SetFieldDefs;
  end;

// операция
type
  TOperation = class(TObject)
  private
    FOpType: TOpTypeKey;
    FStartTime: TDateTime;
    FFinishTime: TDateTime;

    tblOperation: TTable;
    FOperationKey: Integer;

    procedure SetOpType(const Value: TOpTypeKey);
    procedure SetOperationKey(const Value: Integer);

  protected

  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginOp;
    procedure EndOp;
    procedure Post;

//    function FieldByName(const FieldName: String): Integer; // TField

    property OperationKey: Integer read FOperationKey write SetOperationKey;
    property OpType: TOpTypeKey read FOpType write SetOpType;
  end;

function TypeNameToId(const TypeName: String): ShortInt;
function TypeIdToName(const TypeId: ShortInt): String;

var
  CurrentOperation: TOperation;

procedure Register;

implementation

uses
  UserLogin;

(*
  10  smallint
  11  shortint
  12  longint
  13  int64
  14  byte
  15  word
  16  longword

  20  single
  21  double
  22  extended
  23  comp
  24  currency

  30  shortstring
  31  ansistring
  32  widestring

  40  ansichar
  41  widechar

  80  reference
*)

type
  TTypeRec = record
    Id: ShortInt;
    Name: String;
  end;

const
  FieldTypes: array[1..9] of TTypeRec = (
    (Id: 10; Name: 'SmallInt'),
    (Id: 11; Name: 'ShortInt'),
    (Id: 12; Name: 'LongInt'),
    (Id: 13; Name: 'Int64'),
    (Id: 14; Name: 'Byte'),
    (Id: 15; Name: 'Word'),
    (Id: 16; Name: 'LongWord'),
    (Id: 80; Name: 'Reference'),
    (Id: 90; Name: 'Enumeration')
  );

function TypeNameToId(const TypeName: String): ShortInt;
var
  I: Integer;
begin
  for I := Low(FieldTypes) to High(FieldTypes) do
    if AnsiCompareText(TypeName, FieldTypes[I].Name) = 0 then
    begin
      Result := FieldTypes[I].Id;
      exit;
    end;

  raise Exception.Create('Invalid type name');
end;

function TypeIdToName(const TypeId: ShortInt): String;
var
  I: Integer;
begin
  for I := Low(FieldTypes) to High(FieldTypes) do
    if FieldTypes[I].Id = TypeId then
    begin
      Result := FieldTypes[I].Name;
      exit;
    end;

  raise Exception.Create('Invalid type id');
end;

{ TOperation }

procedure TOperation.BeginOp;
begin
  FStartTime := Now;
end;

constructor TOperation.Create;
begin
  inherited Create;
  tblOperation := TTable.Create(nil);
  tblOperation.DatabaseName := 'xxx';
  tblOperation.TableName := 'fin_operation';
  tblOperation.Open;
end;

destructor TOperation.Destroy;
begin
  tblOperation.Close;
  tblOperation.Free;
  inherited Destroy;
end;

procedure TOperation.EndOp;
begin
  FFinishTime := Now;
end;

procedure TOperation.Post;
begin
  tblOperation.Append;
  tblOperation.FieldByName('optype').AsInteger := FOpType;
  tblOperation.FieldByName('commitdate').AsDateTime := FStartTime;
  tblOperation.FieldByName('duration').AsInteger := Round((FFinishTime - FStartTime) * 24 * 60 * 60 * 1000);
  tblOperation.FieldByName('cost').AsFloat := 0;

  tblOperation.FieldByName('sumNCU').AsFloat := 0;
  tblOperation.FieldByName('sumcurr').AsFloat := 0;
//  tblOperation.FieldByName('curr').AsInteger := 0;

  tblOperation.FieldByName('subsystem').AsInteger := CurrentUser.SubSystemKey;
  tblOperation.FieldByName('session').AsInteger := CurrentUser.SessionKey;
  tblOperation.FieldByName('operator').AsInteger := CurrentUser.UserKey;
  tblOperation.FieldByName('enterdate').AsDateTime := FStartTime;
  tblOperation.FieldByName('enterduration').AsInteger := Round((FFinishTime - FStartTime) * 24 * 60 * 60 * 1000);

  tblOperation.FieldByName('disabled').AsInteger := 0;

  tblOperation.Post;
end;

procedure TOperation.SetOperationKey(const Value: Integer);
begin
  FOperationKey := Value;
end;

procedure TOperation.SetOpType(const Value: TOpTypeKey);
begin
  FOpType := Value;
end;

procedure Register;
begin
//  RegisterComponents('gsNV', [TOperation]);
end;

{ TOpType }

constructor TOpType.Create;
begin
  inherited Create;
end;

destructor TOpType.Destroy;
begin
  inherited Destroy;
end;

//function TOpType.GetFieldDefs(Index: Integer): TboFieldDef;
//begin
//
//end;

procedure TOpType.SetAlias(const Value: String);
begin
  FAlias := Value;
end;

//procedure TOpType.SetFieldDefs(Index: Integer; const Value: TboFieldDef);
//begin
//
//end;

procedure TOpType.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TOpType.SetOpTypeKey(const Value: TOpTypeKey);
begin
  FOpTypeKey := Value;
end;

procedure TOpType.SetParentKey(const Value: TOpTypeKey);
begin
  FParentKey := Value;
end;

{ TboFieldDef }

//procedure TboFieldDef.SetFieldType(const Value: TboFieldType);
//begin
//  FFieldType := Value;
//end;

initialization
  CurrentOperation := nil;
end.
