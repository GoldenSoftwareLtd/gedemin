
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    makerng.pas

  Abstract

    Functions for TxRegistration.

--}

unit MakeRgN;

interface

uses
  Windows, SysUtils;

const
  MaxLenProt = 10;

type
  TProtType = array [1..MaxLenProt] of Byte;
  TByte = array[0..3] of Byte; // для даты Windows directory

// Получение рег. номера по параметру и коду программы
function MakeRegCodeV1(Parametr, ProgramCode: String): String;

// Перевернута строка
procedure TurnStr(var S: String);

// Получение текущего параметра компьютера
procedure GetParametrs(var Parametr: String);

// Кодирование Value
procedure ConvertedValue(var Value: String; ProductID: String; Comp: Boolean);

implementation

// Получение зашифрованного параметра

procedure GetParametrs(var Parametr: String);
var
  WinDir: Integer;
  SystemPath: array[0..MAX_PATH] of Char;
  SR: TSearchRec;
  FindResult: Integer;
  SystemCreationTime: TFileTime; //dwLowDateTime, dwHighDateTime

  RootPath: array[0..255] of Char;
  SectorsPerCluster,
  BytesPerSector,
  FreeClusters,
  TotalClusters: Integer;

begin
  // Определям TotalClusters (количество кластеров на диске c Windows)
  GetWindowsDirectory(RootPath, SizeOf(RootPath));
  StrLCopy(RootPath, RootPath, 3);
  GetDiskFreeSpace(RootPath, SectorsPerCluster, BytesPerSector,
    FreeClusters, TotalClusters);

  // определяем время создания каталога Windows
  GetSystemDirectory(SystemPath, SizeOf(SystemPath));
  FindResult := FindFirst(StrPas(SystemPath), faDirectory + faSysFile + faHidden, SR);
  try
    if FindResult <> 0 then
      raise Exception.Create('Registration failed');
    SystemCreationTime := SR.FindData.ftCreationTime;
    if (SystemCreationTime.dwHighDateTime = 0) and
       (SystemCreationTime.dwHighDateTime = 0) then
      SystemCreationTime := SR.FindData.ftLastWriteTime;
  finally
    FindClose(SR);
  end;

  with SystemCreationTime do
    WinDir := Abs(dwHighDateTime xor dwLowDateTime);
  Str(Abs(WinDir xor TotalClusters), Parametr);
  if Length(Parametr) > 8 then
    Parametr := Copy(Parametr, 1, 8);
end;

// Получение перевернутой строки

procedure TurnStr(var S: String);
var
  I, L: Integer;
  Ch: Char;
begin
  L := Length(S);
  for I := 1 to (L div 2) do
  begin
    Ch := S[I];
    S[I] := S[L - I + 1];
    S[L - I + 1] := Ch;
  end;
end;

// Получение кода строки из масива Byte TPromType

function MakeCodeString(Temp: TProtType): String;
var
  TempStr: String;
  i: Byte;
begin
  TempStr := '';
  for i := 1 to MaxLenProt do
  begin
    TempStr := TempStr + '  ';                                {place divider}
    TempStr[(i * 2) - 1] := chr(48 + (temp[i] mod 10));       {revert numeric to char}
    TempStr[(i * 2)] := chr(48 + ((temp[i] mod 100) div 10)); {revert numeric to char}
  end;
  for i := 4 downto 1 do
    Insert(' ', TempStr, (i * 4) + 1);
  Result := TempStr;
end;

// Получение регистрационного номера (Версия 1) по
// Размеру диска, коду программы, названию компании
//
//  function MakeRegCodeV1
//
//  input:
//    DiskSizeStr -- количество кластеров на диске на котором
//    ProgramCode -- код программы
//    WinDir      -- дата Windows Directory
//  output:
//    Возвращает регистрационный номер. Строка максимум 24 символа.
//
function MakeRegCodeV1(Parametr, ProgramCode: String): String;
var
  TempStr: string;
  ProtString: TProtType;
  i, j: byte;
begin
  TempStr := Parametr + ProgramCode;

  // Доплоняем TempStr пробелами до 10 символов
  while Length(TempStr) < 10 do
    TempStr := TempStr + ' ';

  // Получаем рег номер.
  for i := 1 to MaxLenProt do
  begin
    ProtString[i] := ord(TempStr[i]);
    for j := 1 to length(TempStr) do
      ProtString[i] := ((ProtString[i]) xor ord(TempStr[j])) xor j;
  end;
  TempStr := MakeCodeString(ProtString);
  Result := TempStr;
end;

// Кодирование Value
//
// procedure ConvertedValue
//
// Value     -- кодируемое число
// ProductID -- код программы
// Comp      -- флаг   True - закодировать False - разкодировать

procedure ConvertedValue(var Value: String; ProductID: String; Comp: Boolean);
var
  VStr, PIDStr: String;
  I, Index, Er: Integer;

  // Result = Number + Delta
  function ConvertCode(NumberStr, DeltaStr: String): Char;
  var
    Number, Delta: Integer;
  begin
    Val(NumberStr, Number, Er);
    Val(DeltaStr, Delta, Er);
    if Comp then
    begin
      Inc(Number, Delta);
      if Number > 9 then
        Dec(Number, 10);
    end
    else
    begin
      Dec(Number, Delta);
      if Number < 0 then
        Inc(Number, 10);
    end;
    Str(Number, NumberStr);
    Result := NumberStr[1];
  end;

begin
  Index := 1;
  for I := 1 to Length(Value) do
  begin
    VStr := Value[I];
    PIDStr := ProductID[Index];
    Value[I] := ConvertCode(VStr, PIDStr);
    Inc(Index);
    if Index = 3 then
      Index := 1;
  end;
end;

end.
