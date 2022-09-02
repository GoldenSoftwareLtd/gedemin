// ShlTanya, 10.02.2019

unit gdcTriggerHelper;

interface

uses
  Classes;

function GetTypeID(const AName: String): Integer;
function GetTypeName(const AnID: Integer): String;
function GetTypeAcronym(const AnID: Integer): String;
procedure EnumTableTriggerTypes(S: TStrings);
procedure EnumDBTriggerTypes(S: TStrings);

implementation

uses
  SysUtils, jclStrings;

const
  TableTriggerTypesCount = 14;
  TableTriggerTypeIDs: array[0..TableTriggerTypesCount - 1] of Integer = (
    1,
    2,
    3,
    4,
    5,
    6,
    17,
    18,
    25,
    26,
    27,
    28,
    113,
    114
  );
  TableTriggerTypeNames: array[0..TableTriggerTypesCount - 1] of String = (
    'BEFORE INSERT',
    'AFTER INSERT',
    'BEFORE UPDATE',
    'AFTER UPDATE',
    'BEFORE DELETE',
    'AFTER DELETE',
    'BEFORE INSERT OR UPDATE',
    'AFTER INSERT OR UPDATE',
    'BEFORE INSERT OR DELETE',
    'AFTER INSERT OR DELETE',
    'BEFORE UPDATE OR DELETE',
    'AFTER UPDATE OR DELETE',
    'BEFORE INSERT OR UPDATE OR DELETE',
    'AFTER INSERT OR UPDATE OR DELETE'
  );
  TableTriggerTypeAcronyms: array[0..TableTriggerTypesCount - 1] of String = (
    'BI',
    'AI',
    'BU',
    'AU',
    'BD',
    'AD',
    'BIU',
    'AIU',
    'BID',
    'AID',
    'BUD',
    'AUD',
    'BIUD',
    'AIUD'
  );


  DBTriggerTypesCount = 5;
  DBTriggerTypeIDs: array[0..DBTriggerTypesCount - 1] of Integer = (
    8192,
    8193,
    8194,
    8195,
    8196
  );
  DBTriggerTypeNames: array[0..DBTriggerTypesCount - 1] of String = (
    'ON CONNECT',
    'ON DISCONNECT',
    'ON TRANSACTION START',
    'ON TRANSACTION COMMIT',
    'ON TRANSACTION ROLLBACK'
  );

function GetTypeID(const AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  if StrIPos('ON', AName) = 1 then
  begin
    for I := 0 to DBTriggerTypesCount - 1 do
      if DBTriggerTypeNames[I] = AName then
      begin
        Result := DBTriggerTypeIDs[I];
        break;
      end;
  end else
  begin
    for I := 0 to TableTriggerTypesCount - 1 do
      if TableTriggerTypeNames[I] = AName then
      begin
        Result := TableTriggerTypeIDs[I];
        break;
      end;
  end;
  if Result = -1 then
    raise Exception.Create('Invalid trigger type name');
end;

function GetTypeName(const AnID: Integer): String;
var
  I: Integer;
begin
  Result := '';
  if AnID > 8000 then
  begin
    for I := 0 to DBTriggerTypesCount - 1 do
      if DBTriggerTypeIDs[I] = AnID then
      begin
        Result := DBTriggerTypeNames[I];
        break;
      end;
  end else
  begin
    for I := 0 to TableTriggerTypesCount - 1 do
      if TableTriggerTypeIDs[I] = AnID then
      begin
        Result := TableTriggerTypeNames[I];
        break;
      end;
  end;
  if Result = '' then
    raise Exception.Create('Invalid trigger type ID');
end;

function GetTypeAcronym(const AnID: Integer): String;
var
  I: Integer;
begin
  Result := '';
  if AnID < 8000 then
  begin
    for I := 0 to TableTriggerTypesCount - 1 do
      if TableTriggerTypeIDs[I] = AnID then
      begin
        Result := TableTriggerTypeAcronyms[I];
        break;
      end;
  end;
  if Result = '' then
    raise Exception.Create('Invalid trigger type ID');
end;

procedure EnumTableTriggerTypes(S: TStrings);
var
  I: Integer;
begin
  Assert(S <> nil);
  S.Clear;
  for I := 0 to TableTriggerTypesCount - 1 do
    S.Add(TableTriggerTypeNames[I]);
end;

procedure EnumDBTriggerTypes(S: TStrings);
var
  I: Integer;
begin
  Assert(S <> nil);
  S.Clear;
  for I := 0 to DBTriggerTypesCount - 1 do
    S.Add(DBTriggerTypeNames[I]);
end;

end.