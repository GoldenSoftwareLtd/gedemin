unit Xoption;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, xAppReg;

type
  TxOption = class(TComponent)
  private
    { Private declarations }
    FDatabaseName: String;
    FTableName: String;
    FErrorWrite: Boolean;
    FCodeUser: Integer;

    FOptionTable: TTable;

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure InitTable;
    procedure CloseTable;
    function ReadGlobalInteger(const aPart, aKey: String; DefaultValue: LongInt): LongInt;
    function ReadGlobalDate(const aPart, aKey: String; DefaultValue: TDateTime): TDateTime;
    function ReadGlobalString(const aPart, aKey: String; DefaultValue: String): String;
    function ReadGlobalBoolean(const aPart, aKey: String; DefaultValue: Boolean): Boolean;
    function ReadInteger(const aPart, aKey: String; DefaultValue: LongInt): LongInt;
    function ReadDate(const aPart, aKey: String; DefaultValue: TDateTime): TDateTime;
    function ReadString(const aPart, aKey: String; DefaultValue: String): String;
    function ReadBoolean(const aPart, aKey: String; DefaultValue: Boolean): Boolean;

    procedure WriteGlobalInteger(const aPart, aKey: String; Value: LongInt);
    procedure WriteGlobalDate(const aPart, aKey: String; Value: TDateTime);
    procedure WriteGlobalString(const aPart, aKey: String; Value: String);
    procedure WriteGlobalBoolean(const aPart, aKey: String; Value: Boolean);
    procedure WriteInteger(const aPart, aKey: String; Value: LongInt);
    procedure WriteDate(const aPart, aKey: String; Value: TDateTime);
    procedure WriteString(const aPart, aKey: String; Value: String);
    procedure WriteBoolean(const aPart, aKey: String; Value: Boolean);
  published
    { Published declarations }
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property TableName: String read FTableName write FTableName;
    property CodeUser: Integer read FCodeUser write FCodeUser;
  end;

procedure Register;

var
  Option: TxOption;

implementation

constructor TxOption.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDatabaseName := 'GOLDENCOMMON';
  FTableName := 'options.db';

  FErrorWrite := False;

  if Option = nil then
    Option := Self
  else
    raise Exception.Create('Only one instance must be');

  FOptionTable := TTable.Create(Self);
  FCodeUser := -1;
end;

destructor TxOption.Destroy;
begin
  FOptionTable.Free;
  inherited Destroy;
end;

procedure TxOption.InitTable;
begin
  FOptionTable.DatabaseName := FDatabaseName;
  FOptionTable.TableName := FTableName;
  try
    FOptionTable.Open;
  except
  end;
end;

procedure TxOption.CloseTable;
begin
  FOptionTable.Close;
end;

function TxOption.ReadInteger(const aPart, aKey: String; DefaultValue: LongInt): LongInt;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsInteger
    else
      Result := AppRegistry.ReadInteger(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadInteger(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadDate(const aPart, aKey: String; DefaultValue: TDateTime): TDateTime;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsDateTime
    else
      Result := AppRegistry.ReadDate(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadDate(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadString(const aPart, aKey: String; DefaultValue: String): String;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsString
    else
      Result := AppRegistry.ReadString(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadString(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadBoolean(const aPart, aKey: String; DefaultValue: Boolean): Boolean;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsBoolean
    else
      Result := AppRegistry.ReadBoolean(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadBoolean(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadGlobalInteger(const aPart, aKey: String; DefaultValue: LongInt): LongInt;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([-1, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsInteger
    else
      Result := AppRegistry.ReadInteger(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadInteger(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadGlobalDate(const aPart, aKey: String; DefaultValue: TDateTime): TDateTime;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([-1, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsDateTime
    else
      Result := AppRegistry.ReadDate(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadDate(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadGlobalString(const aPart, aKey: String; DefaultValue: String): String;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([-1, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsString
    else
      Result := AppRegistry.ReadString(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadString(aPart, aKey, DefaultValue);
  end;
end;

function TxOption.ReadGlobalBoolean(const aPart, aKey: String; DefaultValue: Boolean): Boolean;
begin
  if not FOptionTable.Active then InitTable;
  try
    if FOptionTable.Active and FOptionTable.FindKey([-1, aPart, aKey]) then
      Result := FOptionTable.FieldByName('Value').AsBoolean
    else
      Result := AppRegistry.ReadBoolean(aPart, aKey, DefaultValue);
  except
    Result := AppRegistry.ReadBoolean(aPart, aKey, DefaultValue);
  end;
end;


procedure TxOption.WriteInteger(const aPart, aKey: String; Value: LongInt);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := FCodeUser; 
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsInteger := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteDate(const aPart, aKey: String; Value: TDateTime);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := FCodeUser;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsDateTime := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteString(const aPart, aKey: String; Value: String);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := FCodeUser;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsString := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteBoolean(const aPart, aKey: String; Value: Boolean);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([FCodeUser, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := FCodeUser;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsBoolean := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteGlobalInteger(const aPart, aKey: String; Value: LongInt);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([-1, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := -1;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsInteger := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteGlobalDate(const aPart, aKey: String; Value: TDateTime);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([-1, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := -1;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsDateTime := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteGlobalString(const aPart, aKey: String; Value: String);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([-1, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := -1;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsString := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;

procedure TxOption.WriteGlobalBoolean(const aPart, aKey: String; Value: Boolean);
var
  Times: Longint;
begin
  if FErrorWrite then exit;
  if not FOptionTable.Active then InitTable;
  Times := GetTickCount;
  repeat
    try
      if FOptionTable.FindKey([-1, aPart, aKey]) then
        FOptionTable.Edit
      else
        FOptionTable.Append;
      Break;
    except
      if GetTickCount - Times > 20000 then Break;
    end;
  until False;

  if FOptionTable.State in [dsEdit, dsInsert] then
  begin
    FOptionTable.FieldByName('CodeUser').AsInteger := -1;
    FOptionTable.FieldByName('Section').AsString := aPart;
    FOptionTable.FieldByName('KeyField').AsString := aKey;
    FOptionTable.FieldByName('Value').AsBoolean := Value;
    FOptionTable.Post;
  end
  else
    FErrorWrite := True;
end;


procedure Register;
begin
  RegisterComponents('xTool-3', [TxOption]);
end;

initialization

  Option := nil;

end.
