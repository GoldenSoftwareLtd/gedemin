{



}
unit gd_registration;

interface

type
  TRegParams = record
    BlockVersion,
    ProgCode,
    Period,
    UserCount,       
    Reserved: Integer;
  end;

  TUnregParams = record
    DocCount: Integer;
  end;

const
// ��������� ������ �������������������� ������
  UnregParams: TUnregParams = (DocCount: 40);
  regInitialDate = 38015; // StrToDate('29.01.2004')

var
  RegParams: TRegParams;
  IsRegisteredCopy: Boolean;

  function GetVisRegNumber: String;
  procedure DoRegister(aCode: LongWord);
  function CheckRegistration: Boolean;

  function GetCode(aParams: String): Longword;

implementation

uses
  SysUtils, Windows, Classes, jclMath, Registry, inst_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  regBlockVersion = 0;
  regProgCode = 0;
  regReserved = 0;

  RegSecureCodeValue = 'InnerParams';
  RegKey = cClientRegPath;

// �������� CRC ���������� ������
function GetCRC32FromText(Text: String): LongWord;
begin
  Result := LongWord(Crc32_P(@Text[1], Length(Text), 0));
end;

// ���������� ����, �������. ���������
function GetComputerKey: LongWord;
var
  R: TRegistry;
  BIOSDate: String;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    R := TRegistry.Create(KEY_READ);
    BIOSDate := '';
    try
      try
        R.RootKey := HKEY_LOCAL_MACHINE;
        R.OpenKeyReadOnly('\HARDWARE\DESCRIPTION\System');
        BIOSDate := BIOSDate + R.ReadString('SystemBiosDate');
        BIOSDate := BIOSDate + R.ReadString('VideoBiosDate');
      except
        BIOSDate := '256918198432';
      end;
    finally
      R.Free;
    end;
  end else
  begin
    try
      SetString(BIOSDate, PChar(Ptr($FFFF5)), 8);
      BIOSDate := BIOSDate + '893621';
    except
      BIOSDate := '102987232154';
    end;
  end;

  Result := GetCRC32FromText(BIOSDate);
end;

// ����������� �����
function Encryption(const aCode, aCompKey: LongWord): LongWord;
var
  RandNumber: LongWord;
begin
  RandSeed := aCompKey;

  RandNumber := Random(MaxInt) + Random(MaxInt);
  if Odd(RandNumber) then
    RandNumber := Random(MaxInt) + Random(MaxInt);

  Result := aCode xor RandNumber;
end;

// GetVisRegNumber - ���������� ����������� ����� (����) ��� ����������� �� ������
function GetVisRegNumber: String;
begin
  Result := FormatFloat('#,###', GetComputerKey);
end;

// GetRegNum - ���������� ��������. ��� �������������, ����������� � �������
function GetRegNum(var Code: LongWord): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(RegKey) and
       Reg.ValueExists(RegSecureCodeValue) then
    begin
      Code := Encryption(Reg.ReadInteger(RegSecureCodeValue), GetComputerKey);
      Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

// GetUnlockCode - ���������� ��� �������������, ����. �� ���������� �����������
function GetUnlockCodeByParams(aParams: TRegParams): LongWord;
begin
  Result := aParams.BlockVersion;
  Result := Result * 256 or LongWord(aParams.ProgCode);
  Result := Result * 256 or LongWord(aParams.Period);
  Result := Result * 256 or LongWord(aParams.UserCount);
  Result := Result * 64  or LongWord(aParams.Reserved);
end;

// GetUnlockCode - ���������� ��������� ����������� �� ���� �������������
function GetParamsByUnlockCode(aCode: LongWord): TRegParams;
begin
  Result.Reserved := aCode and $3F;
  Result.UserCount := (aCode and $3FC0) shr 6;
  Result.Period := (aCode and $3FC000) shr (6 + 8);
  Result.ProgCode := (aCode and $3FC00000) shr (6 + 8 + 8);
  Result.BlockVersion := (aCode and $C0000000) shr (6 + 8 + 8 + 8);
end;

// SaveParamsInReg - ����. � ������� ���������� ����
procedure SaveUnlockCodeToReg(aCode: LongWord);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey(RegKey, True);
    try
      Reg.WriteInteger(RegSecureCodeValue, aCode);
    except                  
//      on E: Exception do
        MessageBox(0,
          '��� ������� ����������� �������� ������!'#13#10 + 
          '��������, �� �� ��������� ������� ��������������.',
          '��������',  
          MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  finally
    Reg.Free;
  end;
end;

function GetCipher(aParams: TRegParams; aCompKey: LongWord): LongWord;
begin
  Result := Encryption(GetUnlockCodeByParams(aParams), aCompKey);
end;

// DoRegister - ������������ ��������� (����. ������ � �������)
procedure DoRegister(aCode: LongWord);
begin
  SaveUnlockCodeToReg(aCode);
end;

// GetRegistrationInfo - ����������� ���� ������������� � ��������
function CheckRegistration: Boolean;
var
  C: LongWord;
begin
  CheckRegistration := True;

  if not GetRegNum(C) then
  begin
  {$IFDEF NOGEDEMIN}
    MessageBox(0,
      '��������� �� ���������������� �� ���� ����������.'#13#10#13#10,
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ELSE}
    MessageBox(0,
      '��������� �� ���������������� �� ���� ����������.'#13#10#13#10 +
      '�� ������ ��������� ����������� ������ ������� �����������'#13#10 +
      '�� ������ ���� ������� �������� ���� ���������.'#13#10#13#10 +
      '�� ���� �������� ����������� � ���� �������� Golden Software:'#13#10 +
      '��������, �.�����, ��. �. ������ 23/1, ��. 1'#13#10 +
      '���/����: +375-17-2921333, 2313546'#13#10 +
      'http://gsbelarus.com, email: support@gsbelarus.com'#13#10 +
      '',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ENDIF}
    CheckRegistration := False;
    Exit;
  end else
    RegParams := GetParamsByUnlockCode(C);

// ���������� ������������ ����������
  if (RegParams.Reserved <> regReserved) or
     (RegParams.BlockVersion <> regBlockVersion) or
     (RegParams.ProgCode <> regProgCode) then
  begin
  {$IFDEF NOGEDEMIN}
    MessageBox(0,
      '��������� �� ���������������� �� ���� ����������.'#13#10#13#10 +
      '��������, ������������ ���������� ���� ��������.',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ELSE}
    MessageBox(0,
      '��������� �� ���������������� �� ���� ����������.'#13#10#13#10 +
      '��������, ������������ ���������� ���� ��������.'#13#10 +
      '�� ������ ��������� ����������� ������ ������� �����������'#13#10 +
      '�� ������ ���� ������� �������� ���� ���������.'#13#10#13#10 +
      '�� ���� �������� ����������� � ���� �������� Golden Software:'#13#10 +
      '��������, �.�����, ��. �. ������ 23/1, ��. 1'#13#10 +
      '���/����: +375-17-2921333, 2313546'#13#10 +
      'http://gsbelarus.com, email: support@gsbelarus.com'#13#10 +
      '',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ENDIF}
    CheckRegistration := False;
    Exit;
  end;

// ������ ��������
  if (RegParams.Period > 0) and
     (Now > IncMonth(regInitialDate, RegParams.Period * 3)) then
  begin
  {$IFDEF NOGEDEMIN}
    MessageBox(0,
      '������ ������ ��������� �����.',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ELSE}
    MessageBox(0,
      '������ ������ ��������� �����.'#13#10 +
      '�� ������ ��������� ����������� ������ ������� �����������'#13#10 +
      '�� ������ ���� ������� �������� ���� ���������.',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  {$ENDIF}
    CheckRegistration := False;
    Exit;
  end;

end;

// GetCode - ��������� ���� (��� ������� System)
function GetCode(aParams: String): Longword;
var
  Params: TRegParams;
  List: TStringList;
begin
  Result := 0;
  List := TStringList.Create;
  try
    List.CommaText := aParams;

    if List.Count <> 6 then
      raise Exception.Create('Invalid params string');

    try
      Params.BlockVersion := StrToInt(List[0]);
      Params.ProgCode     := StrToInt(List[1]);
      Params.Period       := StrToInt(List[2]);
      Params.UserCount    := StrToInt(List[3]);
      Params.Reserved     := StrToInt(List[4]);
      Result := GetCipher(Params, LongWord(StrToInt64(List[5])));
    except
      raise Exception.Create('Invalid params string');
    end;
  finally
    List.Free;
  end;
end;

initialization

  IsRegisteredCopy := False;

end.
