
unit gd_registration;

interface

type
  TRegistrationState = (rsUnknown, rsRegistered, rsUnregistered, rsInvalid, rsExpired, rsUserCountExceeded);

  TRegParams = class(TObject)
  private
    FState: TRegistrationState;
    FValidUntil: TDateTime;
    FMaxUserCount: Word;

    class function GetComputerKey: LongWord;
    class function GetMask(const AKey: LongWord): LongWord;
    class function Decode(W: LongWord; var AValidUntil: TDateTime;
      var AMaxUserCount: Word; const AKey: LongWord): Boolean;
    class function Encode(const AValidUntil: TDateTime;
      AMaxUserCount: Word; const AKey: LongWord): LongWord;

    procedure Check;
    function GetState: TRegistrationState;
    function GetMaxUserCount: Integer;
    function GetValidUntil: TDateTime;

  public
    constructor Create;

    class function GetControlNumber: String;
    class function GetCode(const AParams: String): Longword;

    function CheckRegistration(const AShowMessage: Boolean;
      const ADisabledFunction: String = ''): Boolean;
    procedure RegisterProgram(const ANumber: LongWord);

    property State: TRegistrationState read GetState;
    property ValidUntil: TDateTime read GetValidUntil;
    property MaxUserCount: Integer read GetMaxUserCount;
  end;

var
  RegParams: TRegParams;


implementation

uses
  SysUtils, Windows, Classes, jclMath, Registry, inst_const,
  gd_security, gd_CmdLineParams_unit, gd_GlobalParams_unit,
  IBDatabase, IBSQL
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure TRegParams.Check;
var
  W: LongWord;
  S: String;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  if FState = rsUnknown then
  begin
    FValidUntil := 0;
    FMaxUserCount := 0;

    S := gd_GlobalParams.InnerParam;

    if (S = '') or (StrToInt64Def(S, 0) <> StrToInt64Def(S, 1)) then
      FState := rsUnregistered
    else begin
      W := StrToInt64Def(S, 0);

      if not Decode(W, FValidUntil, FMaxUserCount, GetComputerKey) then
        FState := rsInvalid
      else
        FState := rsRegistered;
    end;    
  end;

  if FState = rsRegistered then
  begin
    if (FValidUntil > 0) and (FValidUntil < Date) then
      FState := rsExpired
    else if (FMaxUserCount > 0) and Assigned(IBLogin) and IBLogin.LoggedIn then
    begin
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := IBLogin.Database;
        Tr.StartTransaction;
        q.Transaction := Tr;
        q.SQL.Text := 'SELECT COUNT(*) FROM mon$attachments';
        q.ExecQuery;
        if q.Fields[0].AsInteger > FMaxUserCount then
          FState := rsUserCountExceeded;
      finally
        q.Free;
        Tr.Free;
      end;
    end;
  end;
end;

function TRegParams.CheckRegistration(const AShowMessage: Boolean;
  const ADisabledFunction: String = ''): Boolean;
var
  MessageText: String;
begin
  Check;

  MessageText := '';
  Result := False;

  case FState of
    rsInvalid, rsUnregistered:
    begin
      MessageText := 'Вы используете незарегистрированную копию программы.'#13#10;
      if ADisabledFunction > '' then
        MessageText := MessageText + ADisabledFunction + #13#10;
    end;

    rsExpired:
    begin
      MessageText := 'Период работы программы истек.'#13#10;
      if ADisabledFunction > '' then
        MessageText := MessageText + ADisabledFunction + #13#10;
    end;

    rsUserCountExceeded:
    begin
      MessageText := 'Превышен лимит количества пользователей,'#13#10'установленный Вашей лицензией.'#13#10;
      if ADisabledFunction > '' then
        MessageText := MessageText + ADisabledFunction + #13#10;
    end;
  else
    Result := True;
  end;

  if AShowMessage and (not gd_CmdLineParams.QuietMode)
    and (gd_CmdLineParams.LoadSettingFileName = '')
    and (not gd_CmdLineParams.Embedding)
    and (MessageText > '') then
  begin
    MessageBox(0,
      PChar(
        MessageText +
        #13#10 +
        'Вы можете выполнить регистрацию вызвав соответствующую'#13#10 +
        'команду из пункта меню Справка главного окна программы.'#13#10#13#10 +
        'По всем вопросам обращайтесь в офис Golden Software, Ltd:'#13#10 +
        'Беларусь, г.Минск, ул. Скрыганова 6, оф. 2-204'#13#10 +
        'тел/факс: +375-17-2561759, 2562782'#13#10 +
        'http://gsbelarus.com, email: support@gsbelarus.com'),
      'Внимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
  end;
end;

constructor TRegParams.Create;
begin
  FState := rsUnknown;
end;

class function TRegParams.Decode(W: LongWord; var AValidUntil: TDateTime;
  var AMaxUserCount: Word; const AKey: LongWord): Boolean;
begin
  W := W xor GetMask(AKey);
  if (W shr 18) <> $2AAA then
    Result := False
  else begin
    if (W and $3FFF) = 0 then
      AValidUntil := 0
    else
      AValidUntil := EncodeDate(2014, 08, 30) + (W and $3FFF);
    AMaxUserCount := (W shr 14) and $F;
    Result := True;
  end;
end;

class function TRegParams.Encode(const AValidUntil: TDateTime;
  AMaxUserCount: Word; const AKey: LongWord): LongWord;
begin
  Result := $2AAA;

  if AMaxUserCount > $F then
    AMaxUserCount := 0;

  Result := (Result shl 4) + AMaxUserCount;

  Result := Result shl 14;

  if AValidUntil > EncodeDate(2014, 08, 30) then
    Result := Result + Trunc(AValidUntil - EncodeDate(2014, 08, 30));

  Result := Result xor GetMask(AKey);
end;

class function TRegParams.GetCode(const AParams: String): Longword;
var
  List: TStringList;
  D: TDateTime;
begin
  Result := 0;
  List := TStringList.Create;
  try
    List.CommaText := AParams;

    if List.Count <> 5 then
      raise Exception.Create('Invalid params string');

    if List[0] = '0' then
      D := 0
    else
      D := EncodeDate(StrToInt(List[0]), StrToInt(List[1]), StrToInt(List[2]));

    Result := Encode(D, StrToInt(List[3]), StrToInt64(List[4]));
  finally
    List.Free;
  end;
end;

class function TRegParams.GetComputerKey: LongWord;
var
  R: TRegistry;
  BIOSDate: AnsiString;
  I: LongWord;
begin
  SetLength(BIOSDate, MAX_COMPUTERNAME_LENGTH + 1);
  I := Length(BIOSDate);
  if GetComputerName(@BIOSDate[1], I) then
    SetLength(BIOSDate, I);

  R := TRegistry.Create(KEY_READ);
  try
    R.RootKey := HKEY_LOCAL_MACHINE;
    if R.OpenKeyReadOnly('\HARDWARE\DESCRIPTION\System') then
    begin
      BIOSDate := BIOSDate +
        R.ReadString('SystemBiosDate') +
        R.ReadString('VideoBiosDate');
      R.CloseKey;
    end;
    if R.OpenKeyReadOnly('\HARDWARE\DESCRIPTION\System\BIOS') then
    begin
      BIOSDate := BIOSDate +
        R.ReadString('SystemProductName') +
        R.ReadString('SystemVersion');
      R.CloseKey;
    end;
  finally
    R.Free;
  end;

  Result := LongWord(Crc32_P(@BIOSDate[1], Length(BIOSDate), 0));
end;

class function TRegParams.GetControlNumber: String;
begin
  Result := FormatFloat('#,###', GetComputerKey);
end;

class function TRegParams.GetMask(const AKey: LongWord): LongWord;
var
  I: Integer;
begin
  Result := 0;
  RandSeed := LongInt(AKey);
  for I := 1 to 4 do
    Result := (Result shl 8) or Byte(Random(256));
end;

function TRegParams.GetMaxUserCount: Integer;
begin
  Check;
  Result := FMaxUserCount;
end;

function TRegParams.GetState: TRegistrationState;
begin
  Check;
  Result := FState;
end;

function TRegParams.GetValidUntil: TDateTime;
begin
  Check;
  Result := FValidUntil;
end;

procedure TRegParams.RegisterProgram(const ANumber: LongWord);
var
  D: TDateTime;
  W: Word;
begin
  if not Decode(ANumber, D, W, GetComputerKey) then
    raise Exception.Create('Invalid registration number.');
  gd_GlobalParams.InnerParam := IntToStr(ANumber);
  FState := rsUnknown;
end;

initialization
  RegParams := TRegParams.Create;

finalization
  RegParams.Free;
end.
