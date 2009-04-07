{
  Настройки системы
}

unit mmOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, UserLogin,
  DBTables;

type
  TmmOptions = class(TComponent)
  private
    FDataBaseName: String;
    SubSystemKey: Integer;

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
    property DataBaseName: String read FDataBaseName write FDataBaseName;
  end;

  ExOptionsError = class(Exception);

  var
    Options: TmmOptions;

implementation

{ TmmOptions ---------------------------------------------}

constructor TmmOptions.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDataBaseName := 'xxx';
  if Assigned(Options) then
    raise ExOptionsError.Create('Only one instance of TmmOptions allowed');
  Options := Self;
end;

destructor TmmOptions.Destroy;
begin
  Options := nil;
  inherited Destroy;
end;

procedure TmmOptions.SetDate(Options: String; User: Boolean; Value: TDate);
begin
  SetValue(Options, User, DateToStr(Value), 'D');
end;

procedure TmmOptions.SetDateTime(Options: String; User: Boolean;
  Value: TDateTime);
begin
  SetValue(Options, User, DateTimeToStr(Value), 'T');
end;

procedure TmmOptions.SetFloat(Options: String; User: Boolean; Value: Double);
begin
  SetValue(Options, User, FloatToStr(Value), 'F');
end;

procedure TmmOptions.SetInteger(Options: String; User: Boolean; Value: Integer);
begin
  SetValue(Options, User, IntToStr(Value), 'I');
end;

procedure TmmOptions.SetString(Options: String; User: Boolean; Value: String);
begin
  SetValue(Options, User, Value, 'S');
end;

function TmmOptions.GetDate(Options: String; var Value: TDate): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'D');
  if Result then
    Value := StrToDate(V);
end;

function TmmOptions.GetDateTime(Options: String; var Value: TDateTime): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'T');
  if Result then
    Value := StrToDateTime(V);
end;

function TmmOptions.GetFloat(Options: String; var Value: Double): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'F');
  if Result then
    Value := StrToFloat(V);
end;

function TmmOptions.GetInteger(Options: String; var Value: Integer): Boolean;
var
  V, T: String;
begin
  Result := GetValue(Options, V, T) and (T = 'I');
  if Result then
    Value := StrToInt(V);
end;

function TmmOptions.GetString(Options: String; var Value: String): Boolean;
var
  T: String;
begin
  Result := GetValue(Options, Value, T)
end;

function TmmOptions.GetValue(Options: String; var Value,
  TypeValue: String): Boolean;
var
  Query: TQuery;

  procedure MakeValue;
  begin
    Value := Query.FieldByName('optionsvalue').AsString;
    TypeValue := UpperCase(Query.FieldByName('optionstype').AsString);
    Result := True;
  end;
  
begin
  Result := False;
  Query := TQuery.Create(Self);
  try
    Query.DataBaseName := FDataBaseName;
    Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
      'subsystemkey = %d and name = "%s"', [UserKey, SubSystemKey, UpperCase(Options)]);
    Query.Open;
    if Query.RecordCount <> 0 then
      MakeValue
    else
    begin
      Query.Close;
      Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
        'subsystemkey = %d and name = "%s"', [-1, SubSystemKey, UpperCase(Options)]);
      Query.Open;
      if Query.RecordCount <> 0 then
        MakeValue
      else
      begin
        Query.Close;
        Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey IS NULL and ' +
          'subsystemkey = %d and name = "%s"', [SubSystemKey, UpperCase(Options)]);
        Query.Open;
        if Query.RecordCount <> 0 then
          MakeValue
      end;
    end;
  finally
    Query.Free;
  end;
end;

procedure TmmOptions.SetValue(Options: String; User: Boolean; Value,
  TypeValue: String);
var
  Query: TQuery;
begin
  Query := TQuery.Create(Self);
  try
    Query.DataBaseName := FDataBaseName;
    Query.RequestLive := True;
    if User then
      Query.SQL.Text := Format('SELECT * FROM fin_options WHERE userkey = %d and ' +
        'subsystemkey = %d and name = "%s"', [UserKey, SubSystemKey, UpperCase(Options)])
    else
      Query.SQL.Text := Format('SELECT * FROM fin_options WHERE (userkey IS NULL) and' +
        '(subsystemkey = %d) and (name = "%s")', [SubSystemKey, UpperCase(Options)]);
    Query.Open;
    if Query.RecordCount <> 0 then
      Query.Edit
    else
      Query.Append;
    if User then  
      Query.FieldByName('userkey').AsInteger := UserKey;
      
    Query.FieldByName('name').AsString := UpperCase(Options);
    Query.FieldByName('subsystemkey').AsInteger := SubSystemKey;
    Query.FieldByName('optionsvalue').AsString := Value;
    Query.FieldByName('optionstype').AsString := UpperCase(TypeValue);
    
    Query.Post;
  finally
    Query.Free;
  end;
end;

function TmmOptions.GetUser: Integer;
begin
  if CurrentUser <> nil then
    Result := CurrentUser.UserKey
  else
    Result := -1;
end;


procedure TmmOptions.Loaded;
begin
  inherited Loaded;
  GetUser;
  SubSystemKey := 230;
end;

initialization

  Options := nil;

finalization

  if Assigned(Options) then
  begin
    Options.Free;
    Options := nil;
  end;

end.
