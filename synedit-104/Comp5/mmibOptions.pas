{
  Настройки системы
}

unit mmibOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, UserLogin,
  IBCustomDataSet, IBSQL, IBDatabase;

type
  TmmibOptions = class(TComponent)
  private
    SubSystemKey: Integer;
    FDatabase: TIBDatabase;
    Query: TIBSQL;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;

    function GetValue(Options: String; var Value: String; var TypeValue: String): Boolean;

    function GetString(Options: String; var Value: String): Boolean;
    function GetInteger(Options: String; var Value: Integer): Boolean;
    function GetFloat(Options: String; var Value: Double): Boolean;
    function GetDate(Options: String; var Value: TDate): Boolean;
    function GetDateTime(Options: String; var Value: TDateTime): Boolean;

    procedure SetValue(Options: String; User: Boolean;
      Value: String; TypeValue: String);

    procedure SetString(Options: String; User: Boolean; Value: String);
    procedure SetInteger(Options: String; User: Boolean; Value: Integer);
    procedure SetFloat(Options: String; User: Boolean; Value: Double);
    procedure SetDate(Options: String; User: Boolean; Value: TDate);
    procedure SetDateTime(Options: String; User: Boolean; Value: TDateTime);
    function GetUser: Integer;

    property UserKey: Integer read GetUser;

  published
    property Database: TIBDatabase read FDatabase write FDatabase;
  end;

  ExibOptionsError = class(Exception);

  var
    ibOptions: TmmibOptions;

implementation

{ TmmOptions ---------------------------------------------}

constructor TmmibOptions.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Query := TIBSQL.Create(Self);

  if Assigned(ibOptions) then
    raise ExibOptionsError.Create('Only one instance of TmmOptions allowed');
  ibOptions := Self;
end;

destructor TmmibOptions.Destroy;
begin
  Query.Free;
  ibOptions := nil;
  inherited Destroy;
end;

procedure TmmibOptions.SetDate(Options: String; User: Boolean; Value: TDate);
begin
  SetValue(Options, User, DateToStr(Value), 'D');
end;

procedure TmmibOptions.SetDateTime(Options: String; User: Boolean;
  Value: TDateTime);
begin
  SetValue(Options, User, DateTimeToStr(Value), 'T');
end;

procedure TmmibOptions.SetFloat(Options: String; User: Boolean; Value: Double);
begin
  SetValue(Options, User, FloatToStr(Value), 'F');
end;

procedure TmmibOptions.SetInteger(Options: String; User: Boolean; Value: Integer);
begin
  SetValue(Options, User, IntToStr(Value), 'I');
end;

procedure TmmibOptions.SetString(Options: String; User: Boolean; Value: String);
begin
  SetValue(Options, User, Value, 'S');
end;

function TmmibOptions.GetDate(Options: String; var Value: TDate): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'D');
  if Result then
    Value := StrToDate(V);
end;

function TmmibOptions.GetDateTime(Options: String; var Value: TDateTime): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'T');
  if Result then
    Value := StrToDateTime(V);
end;

function TmmibOptions.GetFloat(Options: String; var Value: Double): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'F');
  if Result then
    Value := StrToFloat(V);
end;

function TmmibOptions.GetInteger(Options: String; var Value: Integer): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'I');
  if Result then
    Value := StrToInt(V);
end;

function TmmibOptions.GetString(Options: String; var Value: String): Boolean;
var
  T: String;
begin
  Result := GetValue(Options, Value, T)
end;

function TmmibOptions.GetValue(Options: String; var Value,
  TypeValue: String): Boolean;

  procedure MakeValue;
  begin
    Value := Query.FieldByName('optionsvalue').AsString;
    TypeValue := UpperCase(Query.FieldByName('optionstype').AsString);
    Result := True;
  end;

begin
  Result := False;

  Query.Close;
  Query.DataBase := FDataBase;
  Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
    'subsystemkey = %d and name = "%s"', [UserKey, SubSystemKey, UpperCase(Options)]);
  Query.ExecQuery;
  if Query.RecordCount <> 0 then
    MakeValue
  else
  begin
    Query.Close;
    Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
      'subsystemkey = %d and name = "%s"', [-1, SubSystemKey, UpperCase(Options)]);
    Query.ExecQuery;
    if Query.RecordCount <> 0 then
      MakeValue
    else
    begin
      Query.Close;
      Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey IS NULL and ' +
        'subsystemkey = %d and name = "%s"', [SubSystemKey, UpperCase(Options)]);
      Query.ExecQuery;
      if Query.RecordCount <> 0 then
        MakeValue
    end;
  end;

end;

procedure TmmibOptions.SetValue(Options: String; User: Boolean; Value,
  TypeValue: String);
var
  id: Integer;
begin
  Query.Close;
  Query.DataBase := FDataBase;
//  Query.RequestLive := True;
  if User then
    Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
      'subsystemkey = %d and name = "%s"', [UserKey, SubSystemKey, UpperCase(Options)])
  else
    Query.SQL.Text := Format('SELECT * FROM fin_options WHERE (userkey IS NULL) and' +
      '(subsystemkey = %d) and (name = "%s")', [SubSystemKey, UpperCase(Options)]);
  Query.ExecQuery;

  if Query.RecordCount <> 0 then
  begin
    id := Query.FieldByName('id').AsInteger;
    Query.Close;
    Query.SQL.Text := Format(
    ' UPDATE fin_options SET name = "%s", subsystemkey = %d, ' +
      'optionsvalue = "%s", optionstype = "%s"',
    [UpperCase(Options), SubSystemKey, Value, UpperCase(TypeValue)]);
    if User then
      Query.SQL.Add(', user = ' + IntToStr(UserKey));
    Query.SQL.Add('WHERE id = ' + IntToStr(id));
  end
  else
  begin
    Query.Close;
    if User then
      Query.SQL.Text := Format(
        ' INSERT INTO fin_options(name, subsystemkey, optionsvalue, optionstype)' +
        ' VALUES("%s", %d, "%s", "%s") ',
        [UpperCase(Options), SubSystemKey, Value, UpperCase(TypeValue)])
    else
      Query.SQL.Text := Format(
        ' INSERT INTO fin_options(name, subsystemkey, optionsvalue, optionstype, userkey)' +
        ' VALUES("%s", %d, "%s", "%s", %d) ',
        [UpperCase(Options), SubSystemKey, Value, UpperCase(TypeValue), UserKey]);
  end;
  Query.ExecQuery;
end;

function TmmibOptions.GetUser: Integer;
begin
  if CurrentUser <> nil then
    Result := CurrentUser.UserKey
  else
    Result := -1;
end;


procedure TmmibOptions.Loaded;
begin
  inherited Loaded;
  GetUser;
  SubSystemKey := 230;
end;

initialization

  ibOptions := nil;

finalization

  if Assigned(ibOptions) then
  begin
    ibOptions.Free;
    ibOptions := nil;
  end;

end.
