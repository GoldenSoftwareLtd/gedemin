
{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{                                                       }
{       Copyright (c) 1996,97 Borland International     }
{       Copyright (c) 1998 Golden Software              }
{                                                       }
{*******************************************************}

{ readboolex added }
{ createex added }

unit xRegistry;

{$R-}

interface

uses Windows, Classes, SysUtils;

type
  ERegistryException = class(Exception);

  TRegKeyInfo = record
    NumSubKeys: Integer;
    MaxSubKeyLen: Integer;
    NumValues: Integer;
    MaxValueLen: Integer;
    MaxDataLen: Integer;
    FileTime: TFileTime;
  end;

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;

  TxRegistry = class(TObject)
  private
    FCurrentKey: HKEY;
    FRootKey: HKEY;
    FLazyWrite: Boolean;
    FCurrentPath: string;
    FCloseRootKey: Boolean;

    procedure SetRootKey(Value: HKEY);

  protected
    procedure ChangeKey(Value: HKey; const Path: string);
    function GetBaseKey(Relative: Boolean): HKey;
    function GetData(const Name: string; Buffer: Pointer;
      BufSize: Integer; var RegData: TRegDataType): Integer;
    function GetKey(const Key: string): HKEY;
    procedure PutData(const Name: string; Buffer: Pointer; BufSize: Integer; RegData: TRegDataType);
    procedure SetCurrentKey(Value: HKEY);

  public
    constructor Create;
    constructor CreateEx(ARootKey: HKEY);
    destructor Destroy; override;

    procedure CloseKey;
    function CreateKey(const Key: string): Boolean;
    function DeleteKey(const Key: string): Boolean;
    function DeleteValue(const Name: string): Boolean;
    function GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
    function GetDataSize(const ValueName: string): Integer;
    function GetDataType(const ValueName: string): TRegDataType;
    function GetKeyInfo(var Value: TRegKeyInfo): Boolean;
    procedure GetKeyNames(Strings: TStrings);
    procedure GetValueNames(Strings: TStrings);
    function HasSubKeys: Boolean;
    function KeyExists(const Key: string): Boolean;
    function LoadKey(const Key, FileName: string): Boolean;
    procedure MoveKey(const OldName, NewName: string; Delete: Boolean);
    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
    function ReadCurrency(const Name: string): Currency;
    function ReadBinaryData(const Name: string; var Buffer; BufSize: Integer): Integer;
    function ReadBool(const Name: string): Boolean;
    function ReadBoolEx(const Name: string; const Default: Boolean): Boolean;
    function ReadDate(const Name: string): TDateTime;
    function ReadDateTime(const Name: string): TDateTime;
    function ReadFloat(const Name: string): Double;
    function ReadInteger(const Name: string): Integer;
    function ReadString(const Name: string): string;
    function ReadTime(const Name: string): TDateTime;
    function RegistryConnect(const UNCName: string): Boolean;
    procedure RenameValue(const OldName, NewName: string);
    function ReplaceKey(const Key, FileName, BackUpFileName: string): Boolean;
    function RestoreKey(const Key, FileName: string): Boolean;
    function SaveKey(const Key, FileName: string): Boolean;
    function UnLoadKey(const Key: string): Boolean;
    function ValueExists(const Name: string): Boolean;
    procedure WriteCurrency(const Name: string; Value: Currency);
    procedure WriteBinaryData(const Name: string; var Buffer; BufSize: Integer);
    procedure WriteBool(const Name: string; Value: Boolean);
    procedure WriteDate(const Name: string; Value: TDateTime);
    procedure WriteDateTime(const Name: string; Value: TDateTime);
    procedure WriteFloat(const Name: string; Value: Double);
    procedure WriteInteger(const Name: string; Value: Integer);
    procedure WriteString(const Name, Value: string);
    procedure WriteExpandString(const Name, Value: string);
    procedure WriteTime(const Name: string; Value: TDateTime);
    property CurrentKey: HKEY read FCurrentKey;
    property CurrentPath: string read FCurrentPath;
    property LazyWrite: Boolean read FLazyWrite write FLazyWrite;
    property RootKey: HKEY read FRootKey write SetRootKey;
  end;

  TRegIniFile = class(TxRegistry)
  private
    FFileName: string;
  public
    constructor Create(const FileName: string);
    function ReadString(const Section, Ident, Default: string): string;
    procedure WriteString(const Section, Ident, Value: String);
    function ReadInteger(const Section, Ident: string;
      Default: Longint): Longint;
    procedure WriteInteger(const Section, Ident: string; Value: Longint);
    function ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
    procedure WriteBool(const Section, Ident: string; Value: Boolean);
    procedure ReadSection(const Section: string; Strings: TStrings);
    procedure ReadSections(Strings: TStrings);
    procedure ReadSectionValues(const Section: string; Strings: TStrings);
    procedure EraseSection(const Section: string);
    procedure DeleteKey(const Section, Ident: String);
    property FileName: string read FFileName;
  end;

implementation

uses Consts;

procedure ReadError(const Name: string);
begin
  raise ERegistryException.CreateFmt(SInvalidRegType, [Name]);
end;

function IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

function RegDataToDataType(Value: TRegDataType): Integer;
begin
  case Value of
    rdString: Result := REG_SZ;
    rdExpandString: Result := REG_EXPAND_SZ;
    rdInteger: Result := REG_DWORD;
    rdBinary: Result := REG_BINARY;
  else
    Result := REG_NONE;
  end;
end;

function DataTypeToRegData(Value: Integer): TRegDataType;
begin
  if Value = REG_SZ then Result := rdString
  else if Value = REG_EXPAND_SZ then Result := rdExpandString
  else if Value = REG_DWORD then Result := rdInteger
  else if Value = REG_BINARY then Result := rdBinary
  else Result := rdUnknown;
end;

constructor TxRegistry.Create;
begin
  RootKey := HKEY_CURRENT_USER;
  LazyWrite := True;
end;

constructor TxRegistry.CreateEx(ARootKey: HKEY);
begin
  RootKey := ARootKey;
  LazyWrite := True;
end;

destructor TxRegistry.Destroy;
begin
  CloseKey;
  inherited;
end;

procedure TxRegistry.CloseKey;
begin
  if CurrentKey <> 0 then
  begin
    if LazyWrite then
      RegCloseKey(CurrentKey) else
      RegFlushKey(CurrentKey);
    FCurrentKey := 0;
    FCurrentPath := '';
  end;
end;

procedure TxRegistry.SetRootKey(Value: HKEY);
begin
  if RootKey <> Value then
  begin
    if FCloseRootKey then
    begin
      RegCloseKey(RootKey);
      FCloseRootKey := False;
    end;
    FRootKey := Value;
    CloseKey;
  end;
end;

procedure TxRegistry.ChangeKey(Value: HKey; const Path: string);
begin
  CloseKey;
  FCurrentKey := Value;
  FCurrentPath := Path;
end;

function TxRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
  if (CurrentKey = 0) or not Relative then
    Result := RootKey else
    Result := CurrentKey;
end;

procedure TxRegistry.SetCurrentKey(Value: HKEY);
begin
  FCurrentKey := Value;
end;

function TxRegistry.CreateKey(const Key: string): Boolean;
var
  TempKey: HKey;
  S: string;
  Disposition: Integer;
  Relative: Boolean;
begin
  TempKey := 0;
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  Result := RegCreateKeyEx(GetBaseKey(Relative), PChar(S), 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_WRITE or KEY_READ, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then RegCloseKey(TempKey)
  else raise ERegistryException.CreateFmt(SRegCreateFailed, [Key]);
end;

function TxRegistry.OpenKey(const Key: string; CanCreate: Boolean): Boolean;
var
  TempKey: HKey;
  S: string;
  Disposition: Integer;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  if not CanCreate or (S = '') then
  begin
    Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      KEY_WRITE or KEY_READ, TempKey) = ERROR_SUCCESS;
  end else
    Result := RegCreateKeyEx(GetBaseKey(Relative), PChar(S), 0, nil,
      REG_OPTION_NON_VOLATILE, KEY_WRITE or KEY_READ, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then
  begin
    if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end;

function TxRegistry.DeleteKey(const Key: string): Boolean;
var
  I, Len: Cardinal;
  Relative: Boolean;
  S, KeyName: string;
  OldKey, DeleteKey: HKEY;
  Info: TRegKeyInfo;
begin
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  OldKey := CurrentKey;
  DeleteKey := GetKey(Key);
  if DeleteKey <> 0 then
  try
    SetCurrentKey(DeleteKey);
    if GetKeyInfo(Info) then
    begin
      SetString(KeyName, nil, Info.MaxSubKeyLen + 1);
      for I := 0 to Info.NumSubKeys - 1 do
      begin
        Len := Info.MaxSubKeyLen + 1;
        if Windows.RegEnumKeyEx(DeleteKey, I, PChar(KeyName), Len, nil, nil, nil, nil) = ERROR_SUCCESS then
          Self.DeleteKey(PChar(KeyName));
      end;
    end;
  finally
    SetCurrentKey(OldKey);
    RegCloseKey(DeleteKey);
  end;
  Result := RegDeleteKey(GetBaseKey(Relative), PChar(S)) = ERROR_SUCCESS;
end;

function TxRegistry.DeleteValue(const Name: string): Boolean;
begin
  Result := RegDeleteValue(CurrentKey, PChar(Name)) = ERROR_SUCCESS;
end;

function TxRegistry.GetKeyInfo(var Value: TRegKeyInfo): Boolean;
begin
  FillChar(Value, SizeOf(TRegKeyInfo), 0);
  Result := RegQueryInfoKey(CurrentKey, nil, nil, nil, @Value.NumSubKeys,
    @Value.MaxSubKeyLen, nil, @Value.NumValues, @Value.MaxValueLen,
    @Value.MaxDataLen, nil, @Value.FileTime) = ERROR_SUCCESS;
end;

procedure TxRegistry.GetKeyNames(Strings: TStrings);
var
  I, Len: Cardinal;
  Info: TRegKeyInfo;
  S: string;
begin
  Strings.Clear;
  if GetKeyInfo(Info) then
  begin
    SetString(S, nil, Info.MaxSubKeyLen + 1);
    for I := 0 to Info.NumSubKeys - 1 do
    begin
      Len := Info.MaxSubKeyLen + 1;
      RegEnumKeyEx(CurrentKey, I, PChar(S), Len, nil, nil, nil, nil);
      Strings.Add(PChar(S));
    end;
  end;
end;

procedure TxRegistry.GetValueNames(Strings: TStrings);
var
  I, Len: Cardinal;
  Info: TRegKeyInfo;
  S: string;
begin
  Strings.Clear;
  if GetKeyInfo(Info) then
  begin
    SetString(S, nil, Info.MaxValueLen + 1);
    for I := 0 to Info.NumValues - 1 do
    begin
      Len := Info.MaxValueLen + 1;
      RegEnumValue(CurrentKey, I, PChar(S), Len, nil, nil, nil, nil);
      Strings.Add(PChar(S));
    end;
  end;
end;

function TxRegistry.GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
var
  DataType: Integer;
begin
  FillChar(Value, SizeOf(TRegDataInfo), 0);
  Result := RegQueryValueEx(CurrentKey, PChar(ValueName), nil, @DataType, nil,
    @Value.DataSize) = ERROR_SUCCESS;
  Value.RegData := DataTypeToRegData(DataType);
end;

function TxRegistry.GetDataSize(const ValueName: string): Integer;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(ValueName, Info) then
    Result := Info.DataSize else
    Result := -1;
end;

function TxRegistry.GetDataType(const ValueName: string): TRegDataType;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(ValueName, Info) then
    Result := Info.RegData else
    Result := rdUnknown;
end;

procedure TxRegistry.WriteString(const Name, Value: string);
begin
  PutData(Name, PChar(Value), Length(Value), rdString);
end;

procedure TxRegistry.WriteExpandString(const Name, Value: string);
begin
  PutData(Name, PChar(Value), Length(Value), rdExpandString);
end;

function TxRegistry.ReadString(const Name: string): string;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetDataSize(Name);
  if Len > 0 then
  begin
    SetString(Result, nil, Len);
    GetData(Name, PChar(Result), Len, RegData);
    if (RegData = rdString) or (RegData = rdExpandString) then
      SetLength(Result, StrLen(PChar(Result)))
    else ReadError(Name);
  end
  else Result := '';
end;

procedure TxRegistry.WriteInteger(const Name: string; Value: Integer);
begin
  PutData(Name, @Value, SizeOf(Integer), rdInteger);
end;

function TxRegistry.ReadInteger(const Name: string): Integer;
var
  RegData: TRegDataType;
begin
  GetData(Name, @Result, SizeOf(Integer), RegData);
  if RegData <> rdInteger then ReadError(Name);
end;

procedure TxRegistry.WriteBool(const Name: string; Value: Boolean);
begin
  WriteInteger(Name, Ord(Value));
end;

function TxRegistry.ReadBool(const Name: string): Boolean;
begin
  Result := ReadInteger(Name) <> 0;
end;

function TxRegistry.ReadBoolEx(const Name: string; const Default: Boolean): Boolean;
begin
  try
    Result := ReadBool(Name);
  except
    on Exception do
      Result := Default;
  end;
end;

procedure TxRegistry.WriteFloat(const Name: string; Value: Double);
begin
  PutData(Name, @Value, SizeOf(Double), rdBinary);
end;

function TxRegistry.ReadFloat(const Name: string): Double;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetData(Name, @Result, SizeOf(Double), RegData);
  if (RegData <> rdBinary) or (Len <> SizeOf(Double)) then
    ReadError(Name);
end;

procedure TxRegistry.WriteCurrency(const Name: string; Value: Currency);
begin
  PutData(Name, @Value, SizeOf(Currency), rdBinary);
end;

function TxRegistry.ReadCurrency(const Name: string): Currency;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetData(Name, @Result, SizeOf(Currency), RegData);
  if (RegData <> rdBinary) or (Len <> SizeOf(Currency)) then
    ReadError(Name);
end;

procedure TxRegistry.WriteDateTime(const Name: string; Value: TDateTime);
begin
  PutData(Name, @Value, SizeOf(TDateTime), rdBinary);
end;

function TxRegistry.ReadDateTime(const Name: string): TDateTime;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetData(Name, @Result, SizeOf(TDateTime), RegData);
  if (RegData <> rdBinary) or (Len <> SizeOf(TDateTime)) then
    ReadError(Name);
end;

procedure TxRegistry.WriteDate(const Name: string; Value: TDateTime);
begin
  WriteDateTime(Name, Value);
end;

function TxRegistry.ReadDate(const Name: string): TDateTime;
begin
  Result := ReadDateTime(Name);
end;

procedure TxRegistry.WriteTime(const Name: string; Value: TDateTime);
begin
  WriteDateTime(Name, Value);
end;

function TxRegistry.ReadTime(const Name: string): TDateTime;
begin
  Result := ReadDateTime(Name);
end;

procedure TxRegistry.WriteBinaryData(const Name: string; var Buffer; BufSize: Integer);
begin
  PutData(Name, @Buffer, BufSize, rdBinary);
end;

function TxRegistry.ReadBinaryData(const Name: string; var Buffer; BufSize: Integer): Integer;
var
  RegData: TRegDataType;
  Info: TRegDataInfo;
begin
  if GetDataInfo(Name, Info) then
  begin
    Result := Info.DataSize;
    RegData := Info.RegData;
    if (RegData = rdBinary) and (Result <= BufSize) then
      GetData(Name, @Buffer, Result, RegData)
    else ReadError(Name);
  end else
    Result := 0;
end;

procedure TxRegistry.PutData(const Name: string; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
var
  DataType: Integer;
begin
  DataType := RegDataToDataType(RegData);
  if RegSetValueEx(CurrentKey, PChar(Name), 0, DataType, Buffer,
    BufSize) <> ERROR_SUCCESS then
    raise ERegistryException.CreateFmt(SRegSetDataFailed, [Name]);
end;

function TxRegistry.GetData(const Name: string; Buffer: Pointer;
  BufSize: Integer; var RegData: TRegDataType): Integer;
var
  DataType: Integer;
begin
  DataType := REG_NONE;
  if RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(Buffer),
    @BufSize) <> ERROR_SUCCESS then
    raise ERegistryException.CreateFmt(SRegGetDataFailed, [Name]);
  Result := BufSize;
  RegData := DataTypeToRegData(DataType);
end;

function TxRegistry.HasSubKeys: Boolean;
var
  Info: TRegKeyInfo;
begin
  Result := GetKeyInfo(Info) and (Info.NumSubKeys > 0);
end;

function TxRegistry.ValueExists(const Name: string): Boolean;
var
  Info: TRegDataInfo;
begin
  Result := GetDataInfo(Name, Info);
end;

function TxRegistry.GetKey(const Key: string): HKEY;
var
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  Result := 0;
  RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
    KEY_WRITE or KEY_READ, Result);
end;

function TxRegistry.RegistryConnect(const UNCName: string): Boolean;
var
  TempKey: HKEY;
begin
  Result := RegConnectRegistry(PChar(UNCname), RootKey, TempKey) = ERROR_SUCCESS;
  if Result then
  begin
    RootKey := TempKey;
    FCloseRootKey := True;
  end;
end;

function TxRegistry.LoadKey(const Key, FileName: string): Boolean;
var
  S: string;
begin
  S := Key;
  if not IsRelative(S) then Delete(S, 1, 1);
  Result := RegLoadKey(RootKey, PChar(S), PChar(FileName)) = ERROR_SUCCESS;
end;

function TxRegistry.UnLoadKey(const Key: string): Boolean;
var
  S: string;
begin
  S := Key;
  if not IsRelative(S) then Delete(S, 1, 1);
  Result := RegUnLoadKey(RootKey, PChar(S)) = ERROR_SUCCESS;
end;

function TxRegistry.RestoreKey(const Key, FileName: string): Boolean;
var
  RestoreKey: HKEY;
begin
  Result := False;
  RestoreKey := GetKey(Key);
  if RestoreKey <> 0 then
  try
    Result := RegRestoreKey(RestoreKey, PChar(FileName), 0) = ERROR_SUCCESS;
  finally
    RegCloseKey(RestoreKey);
  end;
end;

function TxRegistry.ReplaceKey(const Key, FileName, BackUpFileName: string): Boolean;
var
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);
  if not Relative then Delete(S, 1, 1);
  Result := RegReplaceKey(GetBaseKey(Relative), PChar(S),
    PChar(FileName), PChar(BackUpFileName)) = ERROR_SUCCESS;
end;

function TxRegistry.SaveKey(const Key, FileName: string): Boolean;
var
  SaveKey: HKEY;
begin
  Result := False;
  SaveKey := GetKey(Key);
  if SaveKey <> 0 then
  try
    Result := RegSaveKey(SaveKey, PChar(FileName), nil) = ERROR_SUCCESS;
  finally
    RegCloseKey(SaveKey);
  end;
end;

function TxRegistry.KeyExists(const Key: string): Boolean;
var
  TempKey: HKEY;
begin
  TempKey := GetKey(Key);
  if TempKey <> 0 then RegCloseKey(TempKey);
  Result := TempKey <> 0;
end;

procedure TxRegistry.RenameValue(const OldName, NewName: string);
var
  Len: Integer;
  RegData: TRegDataType;
  Buffer: PChar;
begin
  if ValueExists(OldName) and not ValueExists(NewName) then
  begin
    Len := GetDataSize(OldName);
    if Len > 0 then
    begin
      Buffer := AllocMem(Len);
      try
        Len := GetData(OldName, Buffer, Len, RegData);
        DeleteValue(OldName);
        PutData(NewName, Buffer, Len, RegData);
      finally
        FreeMem(Buffer);
      end;
    end;
  end;
end;

procedure TxRegistry.MoveKey(const OldName, NewName: string; Delete: Boolean);
var
  SrcKey, DestKey: HKEY;

  procedure MoveValue(SrcKey, DestKey: HKEY; const Name: string);
  var
    Len: Integer;
    OldKey, PrevKey: HKEY;
    Buffer: PChar;
    RegData: TRegDataType;
  begin
    OldKey := CurrentKey;
    SetCurrentKey(SrcKey);
    try
      Len := GetDataSize(Name);
      if Len > 0 then
      begin
        Buffer := AllocMem(Len);
        try
          Len := GetData(Name, Buffer, Len, RegData);
          PrevKey := CurrentKey;
          SetCurrentKey(DestKey);
          try
            PutData(Name, Buffer, Len, RegData);
          finally
            SetCurrentKey(PrevKey);
          end;
        finally
          FreeMem(Buffer);
        end;
      end;
    finally
      SetCurrentKey(OldKey);
    end;
  end;

  procedure CopyValues(SrcKey, DestKey: HKEY);
  var
    I, Len: Cardinal;
    KeyInfo: TRegKeyInfo;
    S: string;
    OldKey: HKEY;
  begin
    OldKey := CurrentKey;
    SetCurrentKey(SrcKey);
    try
      if GetKeyInfo(KeyInfo) then
      begin
        MoveValue(SrcKey, DestKey, '');
        SetString(S, nil, KeyInfo.MaxValueLen + 1);
        for I := 0 to KeyInfo.NumValues - 1 do
        begin
          Len := KeyInfo.MaxValueLen + 1;
          if RegEnumValue(SrcKey, I, PChar(S), Len, nil, nil, nil, nil) = ERROR_SUCCESS then
            MoveValue(SrcKey, DestKey, PChar(S));
        end;
      end;
    finally
      SetCurrentKey(OldKey);
    end;
  end;

  procedure CopyKeys(SrcKey, DestKey: HKEY);
  var
    I, Len: Cardinal;
    Info: TRegKeyInfo;
    S: string;
    OldKey, PrevKey, NewSrc, NewDest: HKEY;
  begin
    OldKey := CurrentKey;
    SetCurrentKey(SrcKey);
    try
      if GetKeyInfo(Info) then
      begin
        SetString(S, nil, Info.MaxSubKeyLen + 1);
        for I := 0 to Info.NumSubKeys - 1 do
        begin
          Len := Info.MaxSubKeyLen + 1;
          if RegEnumKeyEx(SrcKey, I, PChar(S), Len, nil, nil, nil, nil) = ERROR_SUCCESS then
          begin
            NewSrc := GetKey(PChar(S));
            if NewSrc <> 0 then
            try
              PrevKey := CurrentKey;
              SetCurrentKey(DestKey);
              try
                CreateKey(PChar(S));
                NewDest := GetKey(PChar(S));
                try
                  CopyValues(NewSrc, NewDest);
                  CopyKeys(NewSrc, NewDest);
                finally
                  RegCloseKey(NewDest);
                end;
              finally
                SetCurrentKey(PrevKey);
              end;
            finally
              RegCloseKey(NewSrc);
            end;
          end;
        end;
      end;
    finally
      SetCurrentKey(OldKey);
    end;
  end;

begin
  if KeyExists(OldName) and not KeyExists(NewName) then
  begin
    SrcKey := GetKey(OldName);
    if SrcKey <> 0 then
    try
      CreateKey(NewName);
      DestKey := GetKey(NewName);
      if DestKey <> 0 then
      try
        CopyValues(SrcKey, DestKey);
        CopyKeys(SrcKey, DestKey);
        if Delete then DeleteKey(OldName);
      finally
        RegCloseKey(DestKey);
      end;
    finally
      RegCloseKey(SrcKey);
    end;
  end;
end;

constructor TRegIniFile.Create(const FileName: string);
begin
  inherited Create;
  FFileName := FileName;
  OpenKey(FileName, True);
end;

function TRegIniFile.ReadString(const Section, Ident, Default: string): string;
var
  Key, OldKey: HKEY;
begin
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      if ValueExists(Ident) then
        Result := inherited ReadString(Ident) else
        Result := Default;
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end
  else Result := Default;
end;

procedure TRegIniFile.WriteString(const Section, Ident, Value: String);
var
  Key, OldKey: HKEY;
begin
  CreateKey(Section);
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited WriteString(Ident, Value);
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end;
end;

function TRegIniFile.ReadInteger(const Section, Ident: string; Default: LongInt): LongInt;
var
  Key, OldKey: HKEY;
  S: string;
begin
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      if ValueExists(Ident) then
      begin
        S := inherited ReadString(Ident);
        if (Length(S) > 2) and (S[1] = '0') and (UpCase(S[2]) = 'X') then
          S := '$' + Copy(S, 3, Maxint);
        Result := StrToIntDef(S, Default);
      end else
        Result := Default;
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end
  else Result := Default;
end;

procedure TRegIniFile.WriteInteger(const Section, Ident: string; Value: LongInt);
var
  Key, OldKey: HKEY;
begin
  CreateKey(Section);
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited WriteString(Ident, IntToStr(Value));
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end;
end;

function TRegIniFile.ReadBool(const Section, Ident: string; Default: Boolean): Boolean;
begin
  Result := ReadInteger(Section, Ident, Ord(Default)) <> 0;
end;

procedure TRegIniFile.WriteBool(const Section, Ident: string; Value: Boolean);
const
  Values: array[Boolean] of string = ('0', '1');
var
  Key, OldKey: HKEY;
begin
  CreateKey(Section);
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited WriteString(Ident, Values[Value]);
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end;
end;

procedure TRegIniFile.ReadSection(const Section: string; Strings: TStrings);
var
  Key, OldKey: HKEY;
begin
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited GetValueNames(Strings);
    finally
      SetCurrentKey(OldKey);
    end;
  finally
    RegCloseKey(Key);
  end;
end;

procedure TRegIniFile.ReadSections(Strings: TStrings);
begin
  GetKeyNames(Strings);
end;

procedure TRegIniFile.ReadSectionValues(const Section: string; Strings: TStrings);
var
  KeyList: TStringList;
  I: Integer;
begin
  KeyList := TStringList.Create;
  try
    ReadSection(Section, KeyList);
    Strings.BeginUpdate;
    try
      for I := 0 to KeyList.Count - 1 do
        Strings.Values[KeyList[I]] := ReadString(Section, KeyList[I], '');
    finally
      Strings.EndUpdate;
    end;
  finally
    KeyList.Free;
  end;
end;

procedure TRegIniFile.EraseSection(const Section: string);
begin
  inherited DeleteKey(Section);
end;

procedure TRegIniFile.DeleteKey(const Section, Ident: String);
var
  Key, OldKey: HKEY;
begin
  Key := GetKey(Section);
  if Key <> 0 then
  try
    OldKey := CurrentKey;
    SetCurrentKey(Key);
    try
      inherited DeleteValue(Ident);
    finally
      SetCurrentKey(OldKey);
    end;    
  finally
    RegCloseKey(Key);
  end;
end;

end.


