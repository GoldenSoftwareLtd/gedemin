
unit gd_licence_unit;

interface

const
  MinYear = 2001;
  MaxYear = 2008;
  MinDay = 1;
  MaxDay = 365;
  LicenceLength = 24;

type
  TLicence = String[LicenceLength];

type
  TYear = MinYear..MaxYear;
  TDay = MinDay..MaxDay;
  TLicenceMatrix = array[TYear, TDay] of TLicence;

(*
  Шыфраваньне стракі ліцэнзіі.
*)
function EncodeLicence(S: TLicence): TLicence;

(*
  Дэшыфраваньне стракі ліцэнзіі.
*)
function DecodeLicence(S: TLicence): TLicence;

(*
*)
function GetHDDNumber: Longint;

(*

  Функция получает на вход регистрационный номер программы,
  номер диска, номер версии программы, код программы и версию
  алгоритма шифрования.

  На выходе, функция дает строку лицензии.

*)

function Encode(RegNumber: String;
  HDDNumber: String): String;

procedure Decode(RegNumber, Licence: String;
  var HDDNumber: String);

function Check(ProgramCode: Integer): Integer;

implementation

uses
  Windows, SysUtils, Dialogs;

const
  DataCoderArray: array[1..10] of Char =
    ('1', '3', '8', '0', '9', '2', '4', '5', '7', '6');

const
  Matrix: array[1..20, 1..10] of Char = (
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0'),
    ('7','8','4','2','1','9','6','3','5','0')
  );

function AddChar(A, B: Char): Char;
begin
  Result := Chr(48 + (((Ord(A) - 48) + (Ord(B) - 48)) mod 10));
end;

function ExtractChar(A, B: Char): Char;
begin
  if A >= B then
    Result := Chr(48 + Ord(A) - Ord(B))
  else
    Result := Chr(48 + Ord(A) + 10 - Ord(B));
end;

function AddString(A, B: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(A) do
    Result := Result + AddChar(A[I], B[I]);
end;

function ExtractString(A, B: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(A) do
    Result := Result + ExtractChar(A[I], B[I]);
end;

function StripHyphen(S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if S[I] <> '-' then Result := Result + S[I];
end;

function AddHyphen(S: String): String;
begin
  Result := StripHyphen(S);
  Insert('-', Result, 5);
  Insert('-', Result, 10);
  Insert('-', Result, 15);
  Insert('-', Result, 20);
end;

function Encode(RegNumber: String;
  HDDNumber: String): String;
begin
  RegNumber := StripHyphen(RegNumber);
  Result := HDDNumber;
  if Length(Result) < 10 then
    Result := '0' + IntToStr(Length(Result)) + Result
  else
    Result := IntToStr(Length(Result)) + Result;
  Randomize();
  while Length(Result) < 20 do
    Result := Result + Chr(Random(10) + 48);
  Result := AddString(Result, RegNumber);
  Result := EncodeLicence(Result);
  Result := AddHyphen(Result);
end;

procedure Decode(RegNumber, Licence: String;
  var HDDNumber: String);
begin
  RegNumber := StripHyphen(RegNumber);
  Licence := StripHyphen(Licence);
  Licence := DecodeLicence(Licence);
  Licence := ExtractString(Licence, RegNumber);
  HDDNumber := Copy(Licence, 3, StrToInt(Copy(Licence, 1, 2)));
end;

function EncodeLicence(S: TLicence): TLicence;
var
  I: Integer;
begin
  Result := '';
  S := StripHyphen(S);
  for I := 1 to Length(S) do
  begin
    Result := Result + Matrix[I, Ord(S[I]) - 48 + 1];
  end;
  Result := AddHyphen(Result);
end;

function DecodeLicence(S: TLicence): TLicence;
var
  I, K: Integer;
begin
  Result := '';
  S := StripHyphen(S);
  for I := 1 to Length(S) do
  begin
    for K := 1 to 10 do
      if Matrix[I, K] = S[I] then
        Result := Result + Chr(48 + K - 1);
  end;
//  Result := AddHyphen(Result);
end;

function GetHDDNumber: Longint;
{$IFDEF VER70}
  begin
    Result := DiskSize(3);
  end;
{$ELSE}
  {$IFDEF VER80}
    begin
      Result := DiskSize(3);
    end;
  {$ELSE}
    var
      dwTemp1, dwTemp2: Longword;
    begin
       GetVolumeInformation(PChar('C:\'), nil, 0, @Result, dwTemp1, dwTemp2, nil, 0);
    end;
  {$ENDIF}
{$ENDIF}

function EncodeKey(S: String): String;
var
  I: Integer;
begin
  Result := '';
  Randomize();
  if Length(S) < 10 then
    S := '0' + IntToStr(Length(S)) + S
  else
    S := IntToStr(Length(S)) + S;
  while Length(S) < 20 do
    S := S + IntToStr(Random(10));
  for I:= 1 to Length(S) do
    Result := Result + DataCoderArray[StrToInt(S[I]) + 1];
end;

function DecodeKey(S: String): String;
var
  I, K : Integer;
  DecodeString: String;
begin
  for I := 1 to Length(S) do
    for K := 1 to 10 do
      if DataCoderArray[K] = S[I] then
        DecodeString := DecodeString + IntToStr(K - 1);
  Result := Copy (DecodeString, 3, StrToInt(Copy(DecodeString, 1, 2)));
end;

function DateCoder(ADate: TDateTime): String;
var
  i: Integer;
  Year, Month, Day: Word;
  S: String;
begin
  Result := '';
  DecodeDate(ADate, Year, Month, Day);
  S := IntToStr(Length(IntToStr(Day))) + IntToStr(Length(IntToStr(Month))) +
    IntToStr(Length(IntToStr(Year)));
  S := S + IntToStr(Day) + IntToStr(Month) + IntToStr(Year);
  Randomize();
  while Length(S) < 15 do
    S := S + IntToStr(Random(10));
  for i:= 1 to Length(S) do
    Result := Result + DataCoderArray[StrToInt(S[I]) + 1];
end;

function DateDecoder(S: String): TDateTime;
var
  I, K: Integer;
  Year, Month, Day: Word;
  DecodeString: String;
begin
  DecodeString := '';
  for I := 1 to Length(S) do
    for K := 1 to 10 do
      if DataCoderArray[K] = S[I] then
        DecodeString := DecodeString + IntToStr(K - 1);
  Day := StrToInt(Copy(DecodeString, 4, StrToInt(Copy(DecodeString,1,1))));
  Month := StrToInt(Copy(DecodeString, 4 + StrToInt(Copy(DecodeString,1,1)),
    StrToInt(Copy(DecodeString,2,1))));
  Year := StrToInt(Copy(DecodeString, 4 + StrToInt(Copy(DecodeString,1,1)) +
    StrToInt(Copy(DecodeString,2,1)), StrToInt(Copy(DecodeString,3,1))));
  Result := EncodeDate(Year, Month, Day);
end;

procedure CheckDate(S: String; ADemo: boolean = false);
var
  LastDate: TDateTime;
  LastYear, CurrYear, Month, Day: Word;
begin
  LastDate := DateDecoder(S);
  DecodeDate (Date, CurrYear, Month, Day);
  DecodeDate (LastDate, LastYear, Month, Day);
  if ADemo then
  begin
    if (Date - LastDate > 30) or (Date - LastDate < 0)then
    begin
      ShowMessage('Срок лицензии истек!');
      Halt(1);
    end
    else
      ShowMessage('Лицензия на использование программного средства истечет через ' +
        IntToStr(30 - Round(Date - LastDate)) + ' дней');
  end
  else
  begin
    if (Date - LastDate > 365) or (Date - LastDate < 0)then
      ShowMessage('Программа устарела, нуждается в обновлении!');
  end;
end;

procedure NewCopy(AppName, KeyName, DateName: PChar);
var
  KeyValue: String;
  StartDateValue: String;
begin
  KeyValue := EncodeKey(IntToStr(GetHDDNumber));
  StartDateValue := DateCoder(Date);
  WriteProfileString(AppName, KeyName, PChar(KeyValue));
  WriteProfileString(AppName, DateName, PChar(StartDateValue));
end;

function Check(ProgramCode: Integer): Integer;
var
  AppName, KeyName, DateName, Default, ReturnedString: array[0..255] of Char;
begin
  {St := EncodeKey('111111');
  ShowMessage(DecodeKey(St));
  St := DateCoder(StrToDate('25.12.2001'));
  ShowMessage (DateToStr(DateDecoder(St)));}
  Result := 0; // Проверка пройдена
  StrCopy(AppName, PChar(IntToStr(ProgramCode)){'VMDdriver'});
  StrCopy(KeyName, 'Data');
  StrCopy(DateName, 'Start');
  StrCopy(Default, 'NoData');
  GetProfileString(AppName, KeyName, Default, ReturnedString, 255);
  if ReturnedString = 'NoData' then
  begin
    GetProfileString(AppName, DateName, Default, ReturnedString, 255);
    if ReturnedString = 'NoData' then
    begin
       Result := 1;
{      ShowMessage('Register, please!');
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      NewCopy(AppName, KeyName, DateName);}
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
    else
    begin
      ShowMessage('Вы используете Демо-версию!');
      CheckDate(ReturnedString, true);
    end;
  end
  else
    if DecodeKey(ReturnedString) <> IntToStr(GetHDDNumber) then
    begin
      ShowMessage('Незарегистрированная копия программы!');
      Halt(1);
    end
    else
    begin
      GetProfileString(AppName, DateName, Default, ReturnedString, 255);
      CheckDate(ReturnedString);
    end;
end;

end.
