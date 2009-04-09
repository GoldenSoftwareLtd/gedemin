// Tech yourself UDF programming in 21 minutes!
// Delta version

{********************************************************}
{                                                        }
{       InterBase User Defined Fuctions examples         }
{       Copyright (c) 1996,1997 Oleg Kukartsev           }
{                                                        }
{       Written by:                                      }
{         Oleg Kukarthev                                 }
{       E-mail: Please look at InterBase List Server     }
{               interbase@esunix1.emporia.edu            }
{                                                        }
{********************************************************}
// In this version:
// Char(N), VarChar(N) and CString(N) differencies.
// New tips about returning output values (parameters).
// Debugger output to console. (It was tested only on W95)
// Console output scrolling. OEM console output.
// Tips about input/output null values.
// UDF returning BLOb, [to read BLOb data from external file]
// Propagation exception to interbase not supported (yet).
// You can use UDF with Local Interbase 16 bit, but
//  1. Replace Integer to Longint
//  2. Always specify file extension in module_name "UDFDemo.dll";

// Under development:
// UDF to show time "delta" between two dates

// Creating User Defined Fuctions is explained in the
// InterBase Programmer's Guide, chapter 11, pp.213-224

// Declaring with User Defined Fuctions is explained in the
// InterBase Data Definition Guide, chapter 11, pp.171-174

{.$Define Debug}

{$ALIGN OFF}

unit UDFLib;

interface
uses SysUtils, Classes;

type
// C, C++     Delphi          InterBase
  Short     = SmallInt;    // SmallInt
  Long      = Longint;     // Integer
  // int    = Integer;     // Integer
  Float     = Single;      // Float
  // Double = Double;      // Double
  // *void, *char = PChar; // Char(???), VarChar(???), CString

  PSmallInt = ^SmallInt;
  PInteger  = ^Integer;
  PShort    = ^Short;
  PLong     = ^Long;
  PFloat    = ^Float;
  PDouble   = ^Double;

  TBLOb = record
    GetSegment : function(Handle : Pointer; Buffer : PChar;
     MaxLength : Long; var ReadLength : Long) : WordBool; cdecl;
    Handle : Pointer;               // BLOb handle
    SegCount,                       // Number of BLOb segments
    MaxSegLength,                   // Max length of BLOb segment
    TotalLength : Long;             // Total BLOb length
    PutSegment : procedure(Handle : Pointer; Buffer : PChar;
      Length : Long); cdecl;
    // Seek : function : Long; cdecl; // I don'n know input parameters
  end;

  PIBDateTime = ^TIBDateTime;
  TIBDateTime = record
    Days,                           // Date: Days since 17 November 1858
    MSec10 : Integer;               // Time: Millisecond * 10 since midnigth
  end;

const                               // Date translation constants
  MSecsPerDay10 = MSecsPerDay * 10; // Milliseconds per day * 10
  IBDateDelta = 15018;              // Days between Delphi and InterBase dates

  MaxBLObPutLength = 80;

implementation
{$Ifdef Debug}
  uses Debugger;
{$Endif}

// SmallInt, Integer, Single and Double usage examples:

// ==============================================
// User Defined Function definition example:
//  declare external function Add_Short_Long  <- InterBase Name of UDF
//    smallint, integer    <- parameters are passed by REFERENCE ALWAYS !!!
//  returns
//    integer by value     <- Result is returned either by VALUE or by REFERENCE
//  entry_point "Add_A"    <- Delphi Name of UDF, this name is case sensitive !!!
//  module_name "UDFDemo"; <- This is DLL name, where function resides
//                            you can or can't use file extension like "UDFDemo.dll"
// ==============================================
function Add_A(var iSmall: SmallInt; var iLong: Integer): Integer; cdecl; export;
//             ^^^                   ^^^                  ^^^^^^^  ^^^^^  ^^^^^^
//          by reference          by reference         by value    call convention
begin
  Result := iSmall + iLong;
end;

// ==============================================
//  declare external function ...
//    smallint, integer    <- parameters are passed by REFERENCE
//  returns
//    integer              <- Result is returned ether by REFERENCE,
//  entry_point "Add_B"       It's default behavior and not necessary
//  module_name "UDFDemo";    secify it.
// ==============================================
// Variable to return values in, needs to be static (global).
var
  ResultInteger: Integer;

function Add_B(var iSmall: SmallInt; var iLong: Integer): PInteger; cdecl; export;
//             ^^^                   ^^^                  ^^^^^^^^
//          by reference          by reference         by reference
begin
  ResultInteger := iSmall + iLong;
//^^^^^^^^^^^^^ this is static (global) variable in DataSeg, not on Stack !!!
// Win32 each process using DLL maps DLLs DataSeg to the process address space,
// so each process have its own copy of ResultInteger

// For InterBase 4.1 and less each connect to database run separate process
// so each connect have its own copy of ResultInteger.

// Due to significant changes in architecture for InterBase 4.2 and greater (?)
// all connects share single copy of ResultInteger.

// To avoid any problem, it's better to return result by value,
// or use technique shown in next example

  Result := @ResultInteger;
end;

// ==============================================
//  declare external function ...
//    smallint, integer    <- parameters are passed by REFERENCE
//  returns
//    integer              <- Result is returned ether by VALUE or by REFERENCE
//  entry_point "Add_B2"
//  ...
// ==============================================
function Add_B2(var iSmall: SmallInt; var iLong: Integer): PInteger; cdecl; export;
//              ^^^                   ^^^                  ^^^^^^^^
//           by reference          by reference         by reference
begin
  iLong := iSmall + iLong;
// Although input parameters are passed by REFERENCE ALWAYS, you can
// change them freely in Delphi code,
// this DOESN'T CHANGE corresponding values in Stored Procedures or SQL query!!!
// InterBase make local copy of input parameters and pass pointers to UDF.
// So you can use this space to return result in!

  Result := @iLong;
// We change value of input parameter iLong and return to InterBase pointer to it!
end;


// ==============================================
//  declare external function ...
//    smallint
//  returns
//    double by value
//  ...
// ==============================================
function Factorial(var n: SmallInt): Double; cdecl; export;
var
 n_1 : SmallInt;
begin
  n_1 := n - 1;
  if (n < 0) or (n > 100) then
    Result := -1.0
  else if n = 0 then
    Result := 1.0
  else
    Result := Factorial(n_1) * n;
end;


// CString, VarChar and Char usage examples:
// InterBase table columns, procedure variables, etc.
// string types are VarChar and Char.
// UDF parameters string types are CString, VarChar and Char.
// You can mix them freely, when call UDF from InterBase,
// i.e. pass VarChar as any of CString, VarChar and Char.
// Within Delphi you always use PChar type, but its "usage"
// depends on how you define UDF in InterBase.

// Can anybody describe this part more clearly? !!!!!!!!

// CString means C string i.e. string ending with #0
//
// VarChar is similar to ShortString Delphi type, but
// ShortString have one byte length in first char and
// VarChar have two bytes length in two first chars.
// VarChar isn't ending with #0.

// Char(N) is similar to Array[0..N-1] of Char Delphi type,
// Char isn't ending with #0.

// CString and VarChar length depends on actual parameter size
// passed to UDF.

// Char(N) length is N always.

// Attention:
//  Store string 'ABCDE' to a Char(10) field,
//  now it contains 'ABCDE     ' i.e. Char(NNN) fields always padded
//  with spaces to the length NNN.

//  So 'A', 'A    ' and 'A         ' strings are equal from the point
//  of view Char(10) field,

//  if You want to make a distinguish between there strings, use VarChar(10) field.

// Strings and BLObs (with subtype Text) in InterBase always have
// Character set property.
// It used to proper convert (xlat) between database and client character sets.
// If you have an error
//   Statement failed, SQLCODE = -802
//   arithmetic exception, numeric overflow, or string truncation
//   -Cannot transliterate character between character sets
// you probably must check database and client Character sets.
// Character set 'NONE' can't transliterate to any other then 'NONE' Character set

// Auxiliary  procedure to drop spaces
procedure TrimX(var CString: PChar; Mode : Integer);
var
  PChr: PChar;
begin
// Trim left
  if Mode and 2 > 0 then
    while (CString^ = ' ') do
     Inc(CString);

// Trim right
  if Mode and 1 > 0 then begin
    PChr := CString + StrLen(CString) - 1;
    while (PChr > CString) and (PChr^ = ' ') do
     Dec(PChr);
    PChr[1] := #0;
  end;
end;

// ==============================================
//  declare external function Trim
//    cstring(1000), integer
//  returns
//    cstring(1000)        <- Result is returned by REFERENCE
//  ...
// ==============================================
function Trim(CString: PChar; var Mode : Integer): PChar; cdecl; export;
begin
// At first see comments in function Add_B2
// As I definitely know output string is less then input,
// I can use it space to return result in!

  {$Ifdef Debug}
    Writeln(X, '>', CString, '< ', StrLen(CString));
  {$Endif}

  TrimX(CString, Mode);
  Result := CString;

  {$Ifdef Debug}
    Writeln(X, '>', CString, '< ', StrLen(CString));
    Flush(X);
  {$Endif}
end;

// ==============================================
//  declare external function ConcatA2
//    cstring(1000), varchar(1000), varchar(1000)
//  returns
//    parameter 3          <- Result is returned by REFERENCE
//  ...                       in 3-nd input variable. Memory for result is allocated
//  ...                       by InterBase before call UDF.
//                            Calling rules for ConcatA and ConcatA2 are the same
//                            Look at UDfDemo.sql
// Does a returned parameter need to be always the last one? Of course no!
//
// ==============================================
// Caution:
//  returns
//    parameter N
// work only for CString, Char and VarChar types
procedure ConcatString_A(CString, VarChar, ResVarChar: PChar); cdecl; export;
//                                         ^^^^^^^^^^
//               preallocated area pointer, use it for store function result
var
  CStringLength, VarCharLength: SmallInt;
begin
  TrimX(CString, 1);

  CStringLength := StrLen(CString);
  //               ^^^^^^ UDF can use some functions ...

  // 1st and 2nd bytes of a VarChar are the length of the VarChar
  VarCharLength := PSmallInt(VarChar)^;
  // VarCharLength := StrLen(VarChar + 2); <- Never use that !!!

  {$Ifdef Debug}
    Writeln(X, '*** ConcatString_A ***');
    Writeln(X, 'CStringLength ', CStringLength);
    Writeln(X, 'VarCharLength ', VarCharLength);
    Writeln(X);
    Flush(X);
  {$Endif}

  StrCopy(ResVarChar + 2, CString);
  StrLCat(ResVarChar + 2, VarChar + 2, CStringLength + VarCharLength);

  // Set VarChar length
  PSmallInt(ResVarChar)^ := CStringLength + VarCharLength;
end;

// ==============================================
//  declare external function ...
//    cstring(1000), varchar(1000), cstring(1000)
//  returns
//    parameter 3
//  ...
// ==============================================
procedure ConcatString_B(CString, VarChar, ResCString: PChar); cdecl; export;
var
  CStringLength, VarCharLength: SmallInt;
begin
  TrimX(CString, 1);

  CStringLength := StrLen(CString);
  VarCharLength := PSmallInt(VarChar)^;

  StrCopy(ResCString, CString);
  StrLCat(ResCString, VarChar + 2, CStringLength + VarCharLength);
  ResCString[CStringLength + VarCharLength] := #0;
end;

// ==============================================
//  declare external function ...
//    cstring(1000)
//  returns
//    integer by value
//  ...
// ==============================================
function CStrLength(CString: PChar): Integer; cdecl; export;
begin
  Result := StrLen(CString);
end;

// ==============================================
//  declare external function ...
//    varchar(1000)
//  returns
//    integer by value
//  ...
// ==============================================
function VarCharLength(VarChar: PChar): Integer; cdecl; export;
begin
  Result := PSmallInt(VarChar)^;
  // Result := StrLen(VarChar + 2); <- Never use that !!!
end;

// ==============================================
//  declare external function ...
//    char(1000)
//  returns
//    integer by value
//  ...
// ==============================================
function CharLength(CharI: PChar): Integer; cdecl; export;
begin
  Result := 1000; // As define above
end;

// ==============================================
//  declare external function ...
//    integer, varchar(10) <- parameters are passed by REFERENCE
//  returns
//    parameter 2          <- Result is returned by REFERENCE
//  ...                       in 2-nd input variable
// ==============================================
procedure HexValue(var iLong: Integer; VarChar: PChar); cdecl; export;
var
  HexStr : ShortString;
begin
  HexStr := IntToHex(iLong, 8);
  try
    StrPCopy(VarChar + 2, HexStr);
    // StrPCopy(VarChar + 2, '$' + HexStr);
    // StrPCopy(VarChar + 2, '0x' + HexStr);
    PSmallInt(VarChar)^ := Length(HexStr);
  except
    // I'm not sure this actually protect InterBase from crush,
    // so declare ... varchar(sufficient length) to avoid any exceptions
    PSmallInt(VarChar)^ := 0; // Exit beyond preallocated area
  end;
end;

// ==============================================
//  declare external function ...
//   cstring(256), integer, integer
// returns
//   cstring(256)
//  ...
// ==============================================
function SubString(CString: PChar; var FromPos, ToPos: Integer): PChar; cdecl; export;
var
  Length: Integer;
begin
  Length := StrLen(CString);
  Result := CString + Length;
  if (FromPos > 0) and (ToPos >= FromPos) then begin
    if Length >= FromPos then Result := CString + FromPos - 1;
    if Length > ToPos then CString[ToPos] := #0;
  end;
end;

// ==============================================
//  declare external function ...
//   cstring(256), cstring(256)
// returns
//   integer by value
//  ...
// ==============================================
function Position(CSubString, CString: PChar): Integer; cdecl; export;
var
  PChr: PChar;
begin
  PChr := StrPos(CString, CSubString);
  if PChr <> nil then Result := PChr - CString + 1
  else Result := 0;
end;


// If you want to use static variable to return values for
// cstring(?), varchar(?), look at following examples:

const
  ResultStringSize = 255;

var
  ResultString: Array[0..ResultStringSize] of Char;

// ==============================================
//  declare external function ...
//    cstring(1000), varchar(1000) <- If actual parameter size > declared size,
//                                    InterBase string truncation ERROR will occur
//  returns
//    varchar(1000)                <- If result string size > declared size
//                                    result, InterBase string truncation will occur
//  ...                               If result string size < declared size
//  ...                               result string will be expanded with spaces
// ==============================================
function ConcatString_A2(CString, VarChar: PChar): PChar; cdecl; export;
var
  CStringLength, VarCharLength: SmallInt;
begin
  TrimX(CString, 1);
  CStringLength := StrLen(CString);
  VarCharLength := PSmallInt(VarChar)^;

  StrCopy(ResultString + 2, CString);
  StrLCat(ResultString + 2, VarChar + 2, CStringLength + VarCharLength);
  PSmallInt(@ResultString)^ := CStringLength + VarCharLength;

  Result := ResultString;
end;

// ==============================================
//  declare external function ...
//    cstring(1000), varchar(1000)
//  returns
//    cstring(1000)
//  ...
// ==============================================
function ConcatString_B2(CString, VarChar: PChar): PChar; cdecl; export;
var
  CStringLength, VarCharLength: SmallInt;
begin
  TrimX(CString, 1);

  CStringLength := StrLen(CString);
  VarCharLength := PSmallInt(VarChar)^;

  StrCopy(ResultString, CString);
  StrLCat(ResultString, VarChar + 2, CStringLength + VarCharLength);
  ResultString[CStringLength + VarCharLength] := #0;

  Result := ResultString;
end;

// You can use thread variable also:

threadvar
  ThreadResultString: Array[0..ResultStringSize] of char;

// ==============================================
//  declare external function ...
//    cstring(1000), integer
//  returns
//    cstring(1000)
//  ...
// ==============================================
function Right(CString: PChar; var Number: Integer): PChar; cdecl; export;
var
  Len: Integer;
begin
  Len := StrLen(CString);
  if Number <= Len then
    Result := StrCopy(ThreadResultString, CString + Len - Number)
  else
    Result := StrCopy(ThreadResultString, '');

//  Result := ThreadResultString;

// If you get Internal error: C8922 or something like this,
// try to set optimization on.
// Look at Project/Options.../Compiler/Code generation/Optimization
end;

// A little about null values.
// Nulls for SmallInt & Integer are passed as 0,
// to recognize them I suggest to pass additional null indicator.

// It seems "null indicator" exists, but haven't been implemented properly.
// If you look at how parameters are passed to UDF, you can see strange
// value passed after each parameter. This is some garbage value, and it is
// the same for parameters of the same type, but after I pass "null" value
// this strange garbage value is changed to 0 always, and still 0 even when
// I pass "not null" values.
// Can anybody describe this part more clearly? !!!!!!!!

procedure TestNullValue(var iLong: Integer; var IsNull: WordBool; VarChar: PChar); cdecl; export;
var
  P : PChar;
  i : integer;
begin
  {$Ifdef Debug}
    Writeln(X, '*** TestValue ***');
    Writeln(X, 'iLong ', iLong, ' IsNull ', IsNull);
//    Writeln(X, '@iLong ', IntToHex(Integer(@iLong1), 8), ' ',
//      IntToHex(Integer(@iLong2), 8), ' ', IntToHex(Integer(@iLong3), 8));

    Writeln(X, 'Memory');
    P := PChar(@iLong);
    for i := 0 to 15 do begin
      Write(X, ' ', IntToHex(Byte(P[i]), 2));
      if (i + 1) mod 4 = 0 then Writeln(X);
    end;

    Writeln(X);
    Flush(X);
  {$Endif}

  if IsNull then begin
    StrCopy(VarChar + 2, '<null>');
    PSmallInt(VarChar)^ := Length('<null>');
  end
  else HexValue(iLong, VarChar);
end;

function CheckInvalidValue(CString: PChar): Integer; cdecl; export;
var
  ExceptFlag : WordBool;
begin
  ExceptFlag := False;
  try
    TrimX(CString, 1);
    StrToInt(StrPas(CString));
  except
    ExceptFlag := True;
  end;
  Result := Integer(ExceptFlag);

  {$Ifdef Debug}
    Writeln(X, CString, ' ', StrPas(CString));
    Flush(X);
  {$Endif}
end;

function StrToIntX(CString: PChar): Integer; cdecl; export;
begin
  try
    TrimX(CString, 1);
    Result := StrToInt(StrPas(CString));
  except
    Result := 0;
  end;
end;

// Propagation exception to interbase not supported yet.
// Any exception will shutdown server (IB 4.2) or
// close your connect (IB 4.1)
function RaiseException: Integer; cdecl; export;
begin
//  raise Exception.Create('UDF internal error');
//  Result := 1 / 0;
  Result := 0;
end;

// Date usage examples:
// InterBase store data in the following structure
//  PIBDateTime = ^TIBDateTime;
//  TIBDateTime = record
//    Days,                           // Date: Days since 17 November 1858
//    MSec10 : Integer;               // Time: Millisecond * 10 since midnigth
//  end;
//
// It's very simple to convert it to Delphi 2.0 TDateTime type and vice versa

// ==============================================
//  declare external function ...
//    date, cstring(255)
//  returns
//    parameter 2
//  ...
// ==============================================
procedure DateToString(var IBDateTime: TIBDateTime; CString: PChar); cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  StrPCopy(CString,
    FormatDateTime('"Date is" dddd, dd mmmm yyyy  "Time is" h:mm:ss', DateTime));
end;


// UDF couldn't return date by value, also I don't know how to return date
// using 'returns parameter N' statement.
// So I suggest to use input parameter to return date in.
// Don't try to use time part of date returned from UDF,
// InterBase always discard it
// ==============================================
//  declare external function ...
//    date
//  returns
//    date
//  ...
// ==============================================
function ServerDate(var ServerIBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
var
  DateTime: TDateTime;
  DelphyDays : Integer;
begin
  DateTime := Now;
  DelphyDays := Trunc(DateTime);
  with ServerIBDateTime do begin
    Days := DelphyDays + IBDateDelta;
    MSec10 := Trunc((DateTime - DelphyDays) * MSecsPerDay10);
  end;
  Result := @ServerIBDateTime;
end;

// Debugging usage examples:
function CheckPoint(CString: PChar): Integer; cdecl; export;
begin
  {$Ifdef Debug}
    Writeln(X, CString);
    Flush(X);
  {$Endif}
  Result := 0;
end;

// BLOb usage examples:
// Buffer size, to read BLOb in
const
 MaxBufSize = 32768;

// ==============================================
//  declare external function ...
//    BLOb, cstring(255)
//  returns
//    parameter 2
//  ...
// ==============================================
procedure BLObInfo(var BLOb: TBLOb; CString: PChar); cdecl; export;
begin
  with BLOb do
    if Assigned(Handle) then
      StrLFmt(CString, 255, // Max result string size
        'number of segments:%d  max. segment length:%d  total length:%d',
        [SegCount, MaxSegLength, TotalLength])
    else
      StrCopy(CString, '<empty BLOb>');
end;

function SearchSample(Buf, Sample : PChar) : Boolean;
begin
  Result := StrPos(Buf, Sample) <> nil;
end;

function FillBuffer(var BLOb : TBLOb; Buf : PChar; FreeBufLen : Integer;
  var ReadLen : Integer) : Boolean;
var
  EndOfBLOb : Boolean;
  FreeBufLenX, GotLength : Long;
begin
  try
    ReadLen := 0;
    repeat
      GotLength := 0; { !?! }

      if FreeBufLen > MaxBLObPutLength then FreeBufLenX := MaxBLObPutLength
      else FreeBufLenX := FreeBufLen;

      with BLOb do
        EndOfBLOb := not GetSegment(Handle, Buf + ReadLen, FreeBufLenX, GotLength);

      Inc(ReadLen, GotLength);
      Dec(FreeBufLen, GotLength);
    until EndOfBLOb or (FreeBufLen = 0);
  except
    on E: Exception do begin
      {$Ifdef Debug}
        Writeln(X, E.Message);
        Writeln(X, ReadLen, ' ', FreeBufLen, ' ', GotLength, ' ', EndOfBLOb);
        Flush(X);
      {$Endif}
      EndOfBLOb := True;
    end;
  end;
  Buf[ReadLen] := #0;
  Result := EndOfBLOb;
end;

// ==============================================
//  declare external function ...
//    BLOb, cstring(1)
//  returns
//    integer by value
//  ...
// ==============================================
function BLObSearch(var BLOb : TBLOb; KeyWord : PChar) : Integer; cdecl; export;
var
  KeyWordLen, ReadLength, Offset : Integer;
  EndOfBLOb, Found : Boolean;
  Buf : PChar;
begin
  Result := 0;
  with BLOb do
    if (not Assigned(Handle)) or (TotalLength = 0) then Exit;

  Result := -2;
  KeyWordLen := StrLen(KeyWord) - 1;
  if KeyWordLen >= MaxBufSize then Exit;

  try
    Found := False;
    GetMem(Buf, MaxBufSize + 1);

    Result := -1;
    if not Assigned(Buf) then Exit;

    Offset := 0;
    repeat
      EndOfBLOb := FillBuffer(BLOb, Buf + Offset, MaxBufSize - Offset, ReadLength);

      if ReadLength + Offset >= KeyWordLen then begin
        Found := SearchSample(Buf, KeyWord);
        StrMove(Buf, Buf + ReadLength + Offset - KeyWordLen, KeyWordLen);
        Offset := KeyWordLen;
      end
      else
        Offset := Offset + ReadLength; // Only at the end of BLOb
    until EndOfBLOb or Found;

  finally
    FreeMem(Buf, MaxBufSize + 1);
  end;

  Result := Integer(Found);
end;

const
  MaxVarCharLength = 32767; // Max [Var]Char length

procedure BLObToCString(var BLOb: TBLOb; CString: PChar); cdecl; export;
var
  ReadLength: Integer;
begin
  try
    CString[0] := #0;
    with BLOb do
      if (not Assigned(Handle)) or (TotalLength = 0) then Exit;

    FillBuffer(BLOb, CString, MaxVarCharLength - 1, ReadLength);
  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in BLObToCString!!!');
        Writeln(X, '>', CString, '< ');
        Writeln(X, StrLen(CString), ' ', ReadLength);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
end;

procedure CStringToBLOb(CString: PChar; var BLOb: TBLOb); cdecl; export;
var
  CStringLength, PutLength: Long;
begin
  try
    CStringLength := StrLen(CString);
    if CStringLength = 0 then Exit; // Is it possible to set BLOb = null when
                                    // StrLen(CString) = 0 ?
    with BLOb do
      if not Assigned(Handle) then Exit;

    while CStringLength > 0 do begin
      if CStringLength > MaxBLObPutLength then PutLength := MaxBLObPutLength
      else PutLength := CStringLength;

      with BLOb do
        PutSegment(Handle, CString, PutLength);

      Dec(CStringLength, PutLength);
      Inc(CString, PutLength);
    end;

  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in CStringToBLOb!!!');
        Writeln(X, '>', CString, '< ');
        Writeln(X, StrLen(CString), ' ', CStringLength);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
end;

procedure LoadBLObFromFile(FileName: PChar; var BLOb: TBLOb); cdecl; export;
const
  MaxBufSize = $8192;
var
  BufSize, ReadLength, StreamSize: Integer;
  Buffer: PChar;
  Stream: TStream;
begin
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      StreamSize := Stream.Size;

      if StreamSize > MaxBufSize then BufSize := MaxBufSize else BufSize := StreamSize;
      GetMem(Buffer, BufSize);
      try
        while StreamSize <> 0 do begin
          if StreamSize > BufSize then ReadLength := BufSize else ReadLength := StreamSize;
          Stream.ReadBuffer(Buffer^, ReadLength);

          with BLOb do
            PutSegment(Handle, Buffer, ReadLength);

          Dec(StreamSize, ReadLength);
        end;
      finally
        FreeMem(Buffer, BufSize);
      end;
    finally
      Stream.Free;
    end;
  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in LoadBLObFromFile!!!');
        Writeln(X, 'FileName ', FileName);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
end;

// Don't forget to export UDFs !!!
exports
  Add_A, Add_B, Add_B2, TestNullValue, CheckInvalidValue, StrToIntX, Factorial,
  ConcatString_A, ConcatString_B, ConcatString_A2, ConcatString_B2,
  CStrLength, VarCharLength, CharLength, HexValue, RaiseException,
  DateToString, ServerDate, CheckPoint, Trim, SubString, Position, Right,
  BLObInfo, BLObSearch, BLObToCString, CStringToBLOb, LoadBLObFromFile;


//   Important !!! After reading, please comment this line.
// After your DLL with UDFs has been successfully compiled,
// You must place it
// >>> on InterBase Server <<<
// ether InterBase\bin or any other directory
// included in the search path.

end.


