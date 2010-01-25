
{++

  Basic functions and classes for xStorm collection
  Copyright (c) 1996 - 98 by Golden Software

  Module

    xBasics.pas

  Abstract

    Some basic functions and classes to be used by other units.

  Author

    Vladimir Belyi (17-September-1996)

  Contact address

    andreik@gs.minsk.by

  Uses

    xReadStr - a form files for reading strings

  Revisions history

    1.00  17-sep-1996  belyi   Initial version: Trim function.
    1.01  28-sep-1996  belyi   ReplaceAll function.
    1.02  30-sep-1996  belyi   ExStorm exception class added.
    1.03   3-nov-1996  belyi   TClassList class added.
    1.04  13-nov-1996    >     EndOfString function.
    1.05   5-dec-1996    >     New methods and properties in TClassList.
                               ReadString function.
    1.06   7-dec-1996  belyi   StrToBool function.
    1.07  12-dec-1996    >     MinInt, MaxInt; IndexOf in ClassList.
                               ReplaceNonPrintable.
    1.08  20-dec-1996    >     BoolToStr function.
    1.09   7-jan-1997    >     LongDiv, LongMul. TxListProperty class.
    1.10  27-feb-1997          FreeObject
    1.11  14-mar-1997    >     FirstWord, xStrToInt
    1.12   6-apr-1997  belyi   RealFileName function; StrAdd
    1.13   9-apr-1997  belyi   AHIncr, GlobalDuplicate procs; TxValueList class
    1.14  16-apr-1997  belyi   DuplicateBitmap
    1.15  19-apr-1997  belyi   StringToFloat
    1.16  21-aug-1997  belyi   32 bit; bugs; StrInArray; LastChar(s)
    1.17  22-nov-1997  belyi   StringsIntersect
    1.18  23-nov-1997  andreik ANSIEqualText added. Ternary functions added.
    1.19  25-nov-1997  belyi   xIntToHex
    1.20  25-dec-1997  belyi
    1.21  25-feb-1998  sai     TIntegerList class
    1.22  21-mar-1998  andreik Changes in the Trim and StripStr added.
    1.23  08-may-1999  sai     TestNull
    1.24  30-oct-1999  andreik d:\golden\comp5 path specified.
    1.25  2-dec-1999   sai     WordFile
    1.26  28-apr-2000  andreik Minor changes.

  Known bugs

    -

  Wishes

    -

--}


unit xBasics;

interface

uses
  WinTypes, WinProcs, Classes, SysUtils, Forms, Controls, DsgnIntF, Windows,
  Registry, DB, ComObj;

var
  xStormPath: string = '';

type
  Float = Extended;

  PxByteArray = ^TByteArray;
  TxByteArray = array[0..2147483646] of byte;


{ this function converts file name with references to real file name.
  E.g.: in construction '%t\xxx.fln' %t will be changed to the path to
  system Temp directory
    %x - xStorm collection directory (see xStormPath constant)
    %t - system temporary directory
    %w - windows directory
    %s - windows system directory
    %d - EXE-module directory
}
function RealFileName(s: string): string;

{ Trim deletes leading and end white spaces (i.e. #32, #9) in the string }
function Trim(const S: string): string;

{ StripStr is another name for Trim }
function StripStr(const S: string): string;
 
{converts integer into hex representation }
function xIntToHex(x: Integer): string;

function xMessageBox(Text, Caption: string; Options: Integer): Integer;

{ returns True if S1 is equal to S2 }
{ case insensitive, russian letters allowable }
function ANSIEqualText(const S1, S2: String): Boolean;
function ANSIEqTxt(const S1, S2: String): Boolean;

{ adds string to a PChar string, which should be allocated on heap.
  (Src will be expanded, if it has not enough space)
  Resulting pointer may differ from Src - BE CAREFUL }
function StrAdd(Src: PChar; Add: string): PChar;

function TestNull(Field: TField; Form: TForm; Mes: String; WinControl: TWinControl): Boolean;

{ this function replaces all occurences of line 'Old' in S with
  the line 'New' }
function ReplaceAll(S: string; Old, New: string): string;

{ returns the part of string starting from 'From' character and till the
  end of line }
function EndOfString(AString: string; From: integer): string;

{ true if stringa have some similiar characters }
function StringsIntersect(s1, s2: string): Boolean;

{ Displays a message screen and asks for a string input.
  Comment is a comment foruser. Value is a default input value on start
  and the value user has entered on exit.
  Function returns true if Value contains a new value (otherwise user has
  pressed Cancel button) }
function ReadString(Comment: string; var Value: string): boolean;

{ returns true if s = 'true' or false if s = 'false' }
function StrToBool(const s: string): Boolean;

{ converts string to float number. if string contaions illegal symbols, they
  are simply ignored! }
function xStrToFloat(const s: String): Extended;
function StringToFloat(const s: String): Extended;

{ converts boolean value to string notation }
function BoolToStr(const Value: Boolean): string;

function MinInt(a, b: LongInt): LongInt;
function MaxInt(a, b: LongInt): LongInt;

{ ternary }
{ all these routines return either A or B }
{ depending on F }

function TernaryInt(const F: Boolean; const A, B: LongInt): LongInt;
function TernaryStr(const F: Boolean; const A, B: String): String;
function TernaryFloat(const F: Boolean; const A, B: Double): Double;

{ next two functions work properly when swap values exceed type limit
  example: 20 * 20 / 20 may give wrong result when all vars are byte }
function LongDiv(a, b: LongInt): LongInt;
function LongMul(a, b: LongInt): LongInt;

{ converts all non-printable characters to ReplaceTo character (for the
  lines supposed to be printed on the screen) }
function ReplaceNonPrintable(s: string; ReplaceTo: string): string;

function HexCharToByte(ch: Char): byte;

{ Calculates x^n where n is any float value.
  NOTE: x should be above zero }
function FindPower(x, n: Extended): Extended;

{ Frees object referenced by AnObject and sets AnObkect to nil }
procedure FreeObject(var AnObject: TObject);

{ finds the first word in the string (english) }
function FirstWord(const s: string): string;

{ like StrToInt but empty string is considered to be zero }
function xStrToInt(Value: string): LongInt;

function xParamCount(s: string): Integer;
function xParamName(s: string; Index: Integer): string;
function xParamValue(s: string; Index: Integer): string;
function xParamIndex(s: string; Param: string): Integer;

{$IFDEF VER80}

{ to work with 32-bit long memory structures(see usage in the code below) }
procedure AHIncr; far;

{ compare two blocks of memory [c)Borland source codes] }
function BlockCompare(const Buf1, Buf2; Count: Word): Boolean;

{ returns last char of a string }
function LastChar(const s: string): Char;

{ this func duplicates a blovk of global memory }
function GlobalDuplicate(Src: THandle): THandle;

{$ELSE}

{ returns last char of a string }
function LastChar(const s: string): Char; register;

{ executes program and waits for it to end }
procedure ExecuteProgram(Name: string);

{$ENDIF}

{ creates a copy of a Bitmap and returns its handle }
function DuplicateBitmap(Src: HBITMAP): HBITMAP;

{ returns last chars of a string }
function LastChars(const s: string; Count: Integer): string;

{ returns string without Count last/first chars }
function SkipLastChars(const s: string; Count: Integer): string;
function SkipFirstChars(const s: string; Count: Integer): string;

{ returns true if aString can be found in Choices }
function StrInArray(const aString: string;
  const Choices: array of string): Boolean;

{ returns index of AString in the Choices or }
{ -1 if AString not found }
{ case insensitive, russian chars allowable }
{ index is zero based }
function FindStrInArray(const AString: string;
  const Choices: array of string): Integer;

const
   c1251: string = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя';
   c866: string = 'ЂЃ‚ѓ„……†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ЎўЈ¤ҐҐ¦§Ё©Є«¬­®Їабвгдежзийклмноп';

function Char866to1251(ch: char): char;
function Char1251to866(ch: char): char;

function String866to1251(St: string): string;
function String1251to866(St: string): string;

function CurrentSecond: Integer;
function CurrentMSecond: Integer;

function CurrentDay: Integer;
function CurrentMonth: Integer;
function CurrentYear: Integer;

// next func Duplicates a Global Memory Block
function GlobalDuplicate(Source: THandle): THandle;

procedure WordFile(FileName: String);

(*
  Функция:
    MonthsBetweenDates

  Описание:
    Возвращает количество месяцев между двумя датами.

  Вход:
    Date1, Date2: TDateTime -- две даты, между которыми считается
                               количество месяцев.

  Выход:
    Integer -- количество месяцев.

  Примечание:
    Количество месяцев м-ду двумя датами рассчитывается по формуле:
    m2 - m1 + (y2 - y1) * 12. Где m2, m1, y2, y1 -- год и месяц первой и второй
    даты соответственно.

    Если Date1 > Date2, то генерируется исключение.
*)
function MonthsBetweenDates(Date1, Date2: TDateTime): Integer;

{
  TxValueList holds a list of strings where each string is a variable and
  its value. Here is an example of a string in this list:
   ThisVar = 'Delphi variable'
}
type
  TxValue = record
    Name: string;
    Value: string;
  end;

  TxValueList = class(TStringList)
  protected
    function GetVar(Index: Integer): TxValue;
    function GetValue(Index: Integer): string;
    procedure SetValue(Index: Integer; Value: string);
    function GetName(Index: Integer): string;
    procedure SetName(Index: Integer; Value: string);
  public
    function GetVarValue(Name: string): string;
    function VarIndex(Name: string): Integer;
    property Names[Index: Integer]: string read GetName write SetName;
    property Values[Index: Integer]: string read GetValue write SetValue;
  end;

{ TClassList - the list which frees memory used by every element of
  the list. It meens, this list will call Free method for every object
  stored here before deleting the reference to this object }
type
  TClassList = class
  private
    FList: TList;
    function Get(Index: Integer): TObject;
    function GetCount: Integer;
    function GetLast: TObject;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Item: TObject): Integer;
    function Equals(List: TClassList): Boolean;
    function IndexOf(Item: TObject): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Remove(Item: TObject);
    procedure Insert(Index: Integer; Item: TObject);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TObject read Get; default;
    property Last: TObject read GetLast;
    property List: TList read FList; { just read - better never change}
  end;

{
  TxElementList class is dedicated to work with sentences and enumerated lists.
  Sentence is a list of words delimited by ' ', '.', ',', and so on
  Enumerated list is smth like this: xxx.yyy.z.xxc.rt or rt,er,sfd,rte
  ***
  Delimiters - list of chars which can delimit separate words/elements
  MainDelimiters - list of chars which can delimit separate words/elements and
                   which are at the same moment are words/elements, and, thus,
                   are included in final elements list
  Elements - all elements found in the string Text
  Text - source string to be divided
  AllowEmpty - shows whether final elements list may contain empty strings
}
type
  TxElementList = class
  private
    FDelimiters: string;
    FAllowEmpty: Boolean;
    FMainDelimiters: string; // they are delimiters but will be included as
                           // elements in final division
    procedure SetDelimiters(Value: string);
    procedure SetMainDelimiters(Value: string);
    function GetElementCount: Integer;
    function GetElement(Index: Integer): string;
    function GetLastElement: string;
    procedure SetAllowEmpty(Value: Boolean);
  protected
    FText: string;
    FElements: TStringList;
    Evaluated: Boolean;
    procedure FillList; virtual;
    procedure Evaluate;
    procedure SetText(Value: string); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    property ElementCount: Integer read GetElementCount;
    property Elements[Index: Integer]: string read GetElement; default;
    property LastElement: string read GetLastElement;
    property Text: string read FText write SetText;
    property Delimiters: string read FDelimiters write SetDelimiters;
    property MainDelimiters: string read FMainDelimiters write SetMainDelimiters;
    property AllowEmpty: Boolean read FAllowEmpty write SetAllowEmpty;
    property List: TStringList read FElements; 
  end;

type
  TxListProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual; abstract;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TxSortedListProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

  TIntegerList = class(TList)
  private
    function GetItem(Index: Integer): Integer;
  public
    procedure Add(const Value: Integer);
    procedure Assign(Source: TIntegerList);
    property Items[Index: Integer]: Integer read GetItem;
  end;

{ all exceptions in xStorm collection has this parent: }
type
  ExStorm = class(Exception);
  ExClasslist = class(ExStorm);

var
  MSWord: Variant;
  MSApplication: Variant;

implementation

uses
  xReadStr{, xMsgBox};

function WordConnected: Boolean;
begin
  try
    MSWord := GetActiveOleObject('Word.Basic');
    MSApplication := GetActiveOleObject('Word.Application');
    Result := True;
  except
    on Exception do Result := False;
  end;
end;

function ConnectToWord: Boolean;
begin
  try
    if not WordConnected then
    begin
      MSWord := CreateOleObject('Word.Basic');
      MSApplication := CreateOleObject('Word.Application');
      Result := True;
    end
    else
      Result := False;
  except
    Result := False;
  end;
end;

procedure WordFile(FileName: String);
var
  Reg: TRegistry;
  KeyPath, WordPath: string;
  StartupInfo: TStartupInfo;
  aProcess: TProcessInformation;
  Works: Boolean;
begin
  if FileExists(FileName) then
  begin
    if ConnectToWord then
    begin
      MSWord.FileOpen(FileName);
      MSWord.AppShow;
    end
    else
    begin
      Reg := TRegistry.Create;
      try
        Reg.RootKey := HKEY_CLASSES_ROOT;

        Works := Reg.OpenKey('Word.Backup\CLSID', False);

        if not Works then
         Works := Reg.OpenKey('Word.Application\CLSID', False);

        KeyPath := Reg.ReadString('');

        if Works and Reg.OpenKey('\CLSID\' + KeyPath + '\LocalServer32', False) then
          WordPath := Reg.ReadString('')
        else
           Exit;
      finally
        Reg.Free;
      end;

      FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
      with StartupInfo do
      begin
        cb := SizeOf(TStartupInfo);
        dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
        wShowWindow := SW_RESTORE;
      end;
      CreateProcess(nil, PChar(WordPath + ' "' + FileName + '"'), nil, nil, false,
       NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, aProcess);
    end;
  end;
end;



{$IFDEF VER80}
procedure AHIncr; external 'KERNEL' index 114;
{$ENDIF}

function xIntToHex(x: Integer): string;
const
  hexs = '0123456789ABCDEF';
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 7 do
   begin
     Result := Hexs[x and $F + 1] + Result;
     x := x div 16;
   end;
end;

function TestNull(Field: TField; Form: TForm; Mes: String; WinControl: TWinControl): Boolean;
begin
  if Field.IsNull then
  begin
    MessageBox(Form.Handle, PChar(Mes), 'Внимание!', MB_ICONEXCLAMATION);
    Form.ModalResult := mrNone;
    WinControl.SetFocus;
    Result := False;
  end
  else
    Result := True;
end;

function StripStr(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

function Trim(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

function ANSIEqualText(const S1, S2: String): Boolean;
begin
  Result := ANSICompareText(S1, S2) = 0;
end;

function ANSIEqTxt(const S1, S2: String): Boolean;
begin
  Result := ANSICompareText(S1, S2) = 0;
end;

function RealFileName(s: string): string;
var
  d, d1: pchar;
begin
  Result := s;

  if S = '' then
    exit;

  d := StrAlloc(1000);
  d1 := StrNew('x');
  try
    if s[1] = '%' then
      begin
        if length(s) = 2 then s := s + '\';
        case UpCase(s[2]) of
          'X': begin
                 Result := xStormPath + Copy( s, 3, length(s)-2 );
               end;
          'S': begin
                 GetSystemDirectory(d, 1000);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
          'W': begin
                 GetWindowsDirectory(d, 1000);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$IFDEF VER80}
          'T': begin
                 GetTempFileName(GetTempDrive(#0), d1, 23, d);
                 Result := ExtractFilePath(StrPas(d));
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$ELSE}
          'T': begin
                 GetTempPath(1000, d);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$ENDIF}
          'D': begin
                 Result := ExtractFilePath(Application.ExeName);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
        end;
      end;
  finally
    StrDispose(d);
    StrDispose(d1);
  end;
end;

const
  StrExtraStep = 10; { amount of extra space to allocate when resizing
                       PChar-string }

function StrAdd(Src: PChar; Add: string): PChar;
begin
  if StrBufSize(Src) >= StrLen(Src) + Cardinal(Length(Add)) + 1 then
   begin
     Result := Src;
     StrPCopy(StrEnd(Src), Add);
   end
  else
   begin
     Result := StrAlloc( StrLen(Src) + Cardinal(Length(Add)) + 1 + StrExtraStep );
     StrCopy(Result, Src);
     StrDispose(Src);
     StrPCopy(StrEnd(Result), Add);
   end;
end;

function xMessageBox(Text, Caption: string; Options: Integer): Integer;
var
  p1, p2: array[0..10000] of char;
begin
  StrPCopy(p1, Text);
  StrPCopy(p2, Caption);
  if Application <> nil then
    Result := Windows.MessageBox(Application.Handle, p1, p2, Options)
  else
    Result := Windows.MessageBox(0, p1, p2, Options);
end;

function ReplaceAll(S: string; Old, New: string): string;
var
  i: Integer;
begin
  Result := s;
  i := 1;
  while i <= length(Result) - length(Old) + 1 do
    begin
      if copy(Result, i, length(Old)) = Old then
        begin
          delete(Result, i, length(old));
          if New <> '' then
            insert(New, Result, i);
          i := i + length(new) - 1;
        end;
      inc(i);
    end;
end;

function EndOfString(AString: string; From: integer): string;
begin
  Result := copy(AString, From, length(AString) + 1 - From);
end;

function StringsIntersect(s1, s2: string): Boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 1 to Length(s1) do
    if pos(s1[i], s2) <> 0 then exit;
  Result := false;
end;

function ReadString(Comment: string; var Value: string): Boolean;
var
  Form: TReadStrForm;
begin
  Application.CreateForm(TReadStrForm, Form);
  try
    Form.Comment.Lines.Strings[0] := Comment;
    Form.Edit.Text := Value;
    if Form.ShowModal = mrOk then
    begin
      Result := true;
      Value := Form.Edit.Text
    end
    else
      Result := false;
  finally
    Form.Free;
  end;
end;

function StrToBool(const s: string): Boolean;
var
  su: string;
begin
  su := UpperCase(s);
  if (su = 'TRUE') or (su = 'T') then
    Result := true
  else if (su = 'FALSE') or (su = 'F') then
    Result := false
  else
    raise EConvertError.Create('String contains non-boolean value.');
end;

function BoolToStr(const Value: Boolean): string;
begin
  if Value then
    Result := 'True'
  else
    Result := 'False'; 
end;

function StringToFloat(const s: String): Extended;
var
  s1: String;
  i: Integer;
begin
  s1 := '';
  for i := 1 to Length(s) do
    if s[i] in ['0'..'9', '-', '+', 'E', 'e', DecimalSeparator] then
      s1 := s1 + S[i];
  if s1 <> '' then
    Result := StrToFloat(s1)
  else
    Result := 0;
end;

function xStrToFloat(const s: String): Extended;
begin
  Result := StringToFloat(s);
end;

function MinInt(a, b: LongInt): LongInt;
begin
  if a < b then Result := a else Result := b;
end;

function MaxInt(a, b: LongInt): LongInt;
begin
  if a > b then Result := a else Result := b;
end;

{ ternary }

function TernaryInt(const F: Boolean; const A, B: LongInt): LongInt;
begin
  if F then Result := A else Result := B;
end;

function TernaryStr(const F: Boolean; const A, B: String): String;
begin
  if F then Result := A else Result := B;
end;

function TernaryFloat(const F: Boolean; const A, B: Double): Double;
begin
  if F then Result := A else Result := B;
end;

function LongDiv(a, b: LongInt): LongInt;
begin
  Result := a div b; { this proc is NOT stupid ! }
end;

function LongMul(a, b: LongInt): LongInt;
begin
  Result := a * b; { this proc is NOT stupid ! }
end;

function ReplaceNonPrintable(s: string; ReplaceTo: string): string;
const
  Printable = 'qwertyuiop[]'';lkjhgfdsazxcvbnm,./?><MNBVCXZASDFGHJKL:"}{' +
    'POIUYTREWQ`1234567890-=+_)(*&^%$#@!~' +
    'йцукенгшізхўэждлорпавыфячсмитьбюЮБЬТИМСЧЯФЫВАПРОЛДЖЭЎХЗІШГНЕКУЦЙщъЪЩёЁ№';
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if pos(s[i], Printable) <> 0 then
      Result := Result + s[i]
    else
      Result := Result + ReplaceTo;
end;

function HexCharToByte(ch: Char): byte;
begin
  ch := UpCase(ch);
  case ch of
    '0'..'9': Result := Ord(ch) - 48;
    'A'..'F': Result := Ord(ch) - 65 + 10;
    else
      raise ExStorm.create('Can not convert non hex to byte.');
  end;
end;

function FindPower(x, n: Extended): Extended;
begin
  if x > 0 then
    Result := Exp( n * Ln(x) )
  else if (x = 0) and (n > 0) then
    Result := 0
  else
    raise ExStorm.Create('Failed to calculate the power.');
end;

{$IFDEF VER80}
function BlockCompare(const Buf1, Buf2; Count: Word): Boolean; assembler;
asm
        PUSH    DS
        LDS     SI,Buf1
        LES     DI,Buf2
        MOV     CX,Count
        XOR     AX,AX
        CLD
        REPE    CMPSB
        JNE     @@1
        INC     AX
@@1:    POP     DS
end;

function GlobalDuplicate(Src: THandle): THandle;
var
  Dst: THandle;
  Size: LongInt;
  SrcP, DstP: Pointer;
  i: LongInt;
begin
  Size := GlobalSize(Src);
  SrcP := GlobalLock(Src);
  Dst := GlobalAlloc(GMEM_MOVEABLE, Size);
  DstP := GlobalLock(Dst);

  for i := 0 to Size - 1 do
   Byte(Ptr(HiWord(LongInt(DstP)) + HiWord(i) * Ofs(AHIncr), LoWord(i))^) :=
     Byte(Ptr(HiWord(LongInt(SrcP)) + HiWord(i) * Ofs(AHIncr), LoWord(i))^);

  GlobalUnlock(Src);
  GlobalUnlock(Dst);

  Result := Dst;
end;

{$ENDIF}

procedure FreeObject(var AnObject: TObject);
begin
  if AnObject <> nil then
   begin
     AnObject.Free;
     AnObject := nil;
   end;
end;

function FirstWord(const s: string): string;
var
  i, j: Integer;
begin
  i := 1;
  while (i <= Length(s)) and not(s[i] in ['A'..'Z','a'..'z','0'..'9','_']) do inc(i);
  j := i + 1;
  while (j <= Length(s)) and (s[j] in ['A'..'Z','a'..'z','0'..'9','_']) do inc(j);
  dec(j);
  if j >= i then
    Result := copy(s, i, j - i + 1)
  else
    Result := '';
end;

function xStrToInt(Value: string): LongInt;
begin
  if Value = '' then
    Result := 0
  else
    Result := StrToInt(Value);
end;

function xParamCount(s: string): Integer;
var
  Sub: Integer;
  i: Integer;
begin
  Result := 0;
  Sub := 0;
{  for i := 0 to Length(s) do
   begin
     if s[i] in ['"', ''''] then Sub := 1 - Sub;
     if (Sub = 0) and (s[i] in ['/']) then inc(Result);
   end;}

// Антон: 0 на 1
  for i := 1 to Length(s) do
   begin
     if s[i] in ['"', ''''] then Sub := 1 - Sub;
     if (Sub = 0) and (s[i] in ['/']) then inc(Result);
   end;

  if Sub <> 0 then
    raise ExStorm.Create('xB02: Обнаружена нескомпенсированная кавычка!');
end;


function GiveWord(s: string; Start: Integer): string;
var
  i: Integer;
begin
  i := Start;
  if s[Start] in ['''', '"'] then
   begin
     inc(i);
     while (i <= Length(s)) and (s[i] <> '"') do inc(i);
     if i > Length(s) then dec(i);
     Result := copy(s, Start, i - Start + 1);
   end
  else
   begin
     Result := '';
     while (i <= Length(s)) and
           (s[i] in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', '0'..'9', '-', '.', '_']) do
      begin
        Result := Result + s[i];
        inc(i);
      end;
   end;
end;

function xParamName(s: string; Index: Integer): string;
var
  Sub: Integer;
  Current: Integer;
  i: Integer;
begin
  Result := '';
  Sub := 0;
  Current := -1;
  for i := 0 to Length(s) do
   begin
     if s[i] in ['"', ''''] then Sub := 1 - Sub;
     if (Sub = 0) and (s[i] in ['/']) then
      begin
        inc(Current);
        if Current = Index then
         begin
           Result := GiveWord(s, i + 1);
           exit;
         end;
      end;
   end;

  raise ExStorm.Create('xB01: Неверный индекс параметра!');
end;


function xParamValue(s: string; Index: Integer): string;
var
  Sub: Integer;
  Current: Integer;
  i, j: Integer;
begin
  Result := '';
  Sub := 0;
  Current := -1;
  for i := 0 to Length(s) do
   begin
     if s[i] in ['"', ''''] then Sub := 1 - Sub;
     if (Sub = 0) and (s[i] in ['/']) then
      begin
        inc(Current);
        if Current = Index then
         begin
           Sub := 0;
           for j := i + 1 + Length(GiveWord(s, i + 1)) to Length(s) do
            begin
              if s[j] in ['"', ''''] then Sub := 1 - Sub;
              if (Sub = 0) and (s[j] in ['/']) then exit;
              Result := Result + s[j];
            end;
           exit;
         end;
      end;
   end;

  raise ExStorm.Create('xB01: Неверный индекс параметра!');
end;

function xParamIndex(s: string; Param: string): Integer;
var
  i: Integer;
begin
  for i := 0 to xParamCount(s) - 1 do
   if ANSIUpperCase(xParamName(s, i)) = ANSIUpperCase(Param) then
    begin
      Result := i;
      exit;
    end;
  Result := -1;
end; 

{ from DupBits() in graphics.pas with minor changes }
function DuplicateBitmap(Src: HBITMAP): HBITMAP;
var
  DC, Mem1, Mem2: HDC;
  Old1, Old2: HBITMAP;
  Bitmap: WinTypes.TBitmap;
begin
  Mem1 := CreateCompatibleDC(0);
  Mem2 := CreateCompatibleDC(0);

  GetObject(Src, SizeOf(Bitmap), @Bitmap);

  DC := GetDC(0);
  if DC = 0 then
    raise EOutOfResources.Create('Windows is out of resources.');
  try
    Result := CreateCompatibleBitmap(DC, Bitmap.bmWidth, Bitmap.bmHeight);
    if Result = 0 then
      raise EOutOfResources.Create('Windows is out of resources.');
  finally
    ReleaseDC(0, DC);
  end;

  if Result <> 0 then
  begin
    Old1 := SelectObject(Mem1, Src);
    Old2 := SelectObject(Mem2, Result);

    StretchBlt(Mem2, 0, 0, Bitmap.bmWidth, Bitmap.bmHeight,
               Mem1, 0, 0, Bitmap.bmWidth, Bitmap.bmHeight,
               SrcCopy);
    if Old1 <> 0 then SelectObject(Mem1, Old1);
    if Old2 <> 0 then SelectObject(Mem2, Old2);
  end;
  DeleteDC(Mem1);
  DeleteDC(Mem2);
end;

function LastChar(const s: string): Char;
begin
  Result := s[Length(s)];
end;

function LastChars(const s: string; Count: Integer): string;
begin
  if Count < Length(s) then
    Result := copy(s, Length(s) - Count + 1, Count)
  else
    Result := s;
end;

function SkipLastChars(const s: string; Count: Integer): string;
begin
  if Count < Length(s) then
    Result := copy(s, 1, Length(s) - Count)
  else
    Result := '';
end;

function SkipFirstChars(const s: string; Count: Integer): string;
begin
  if Count < Length(s) then
    Result := copy(s, Count + 1, Length(s) - Count)
  else
    Result := '';
end;

function StrInArray(const aString: string;
  const Choices: array of string): Boolean;
var
  Index: Integer;
begin
  if Low(Choices) > High(Choices) then
    Result := false
  else
   begin
     Index := Low(Choices);
     repeat
       Result := aString = Choices[Index];
       inc(Index);
     until Result or (Index > High(Choices));
   end;
end;

function FindStrInArray(const AString: string;
  const Choices: array of string): Integer;
begin
  for Result := Low(Choices) to High(Choices) do
    if ANSIEqTxt(AString, Choices[Result]) then
      exit;
  Result := -1;
end;

function Char866to1251(ch: char): char;
var
  ps: integer;
begin
  ps := pos(ch, c866);
  if ps = 0 then Result := ch
    else Result := c1251[ps];
end;

function Char1251to866(ch: char): char;
var
  ps: integer;
begin
  ps := pos(ch, c1251);
  if ps = 0 then Result := ch
    else Result := c866[ps];
end;

function String866to1251(St: string): string;
var
  i: integer;
begin
  Result := '';
  for i:=1 to length(st) do
    Result := Result + Char866to1251(st[i]);
end;

function String1251to866(St: string): string;
var
  i: integer;
begin
  Result := '';
  for i:=1 to length(st) do
    Result := Result + Char1251to866(st[i]);
end;

function CurrentSecond: Integer;
var
  h, m, s, ms: Word;
begin
  DecodeTime(Time, h, m, s, ms);
  Result := s;
end;

function CurrentMSecond: Integer;
var
  h, m, s, ms: Word;
begin
  DecodeTime(Time, h, m, s, ms);
  Result := ms;
end;

function CurrentDay: Integer;
var
  d, m, y: Word;
begin
  DecodeDate(Date, y, m, d);
  Result := d;
end;

function CurrentMonth: Integer;
var
  d, m, y: Word;
begin
  DecodeDate(Date, y, m, d);
  Result := m;
end;

function CurrentYear: Integer;
var
  d, m, y: Word;
begin
  DecodeDate(Date, y, m, d);
  Result := y;
end;

function GlobalDuplicate(Source: THandle): THandle;
var
  SourceAddr, ResultAddr: Pointer;
begin
  Result := 0;

  if Source = 0 then exit;

  SourceAddr := GlobalLock(Source);
  try
    // allocate memory
    Result := GlobalAlloc(GMEM_MOVEABLE, GlobalSize(Source));

    // perform copying
    ResultAddr := GlobalLock(Result);
    try
      CopyMemory(ResultAddr, SourceAddr, GlobalSize(Source));
      Move(SourceAddr^, ResultAddr^, GlobalSize(Source));
    finally
      GlobalUnlock(Result);
    end;
  finally
    GlobalUnlock(Source);
  end;
end;

function MonthsBetweenDates(Date1, Date2: TDateTime): Integer;
var
  Y1, M1, D1, Y2, M2, D2: Word;
begin
  if Date1 > Date2 then
    raise Exception.Create('');

  DecodeDate(Date1, Y1, M1, D1);
  DecodeDate(Date2, Y2, M2, D2);

  Result := M2 - M1 + (Y2 - Y1) * 12;
end;

{$IFNDEF VER80}
procedure ExecuteProgram(Name: string);
var
  ExitCode: DWORD;
  StartupInfo: TStartupInfo;
  aProcess: TProcessInformation;
  aPChar: array[0..1000] of char;
begin
  { Place thread code here }
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    wShowWindow := SW_SHOWMINNOACTIVE;
  end;

  StrPCopy(aPChar, Name);

  if not CreateProcess(nil, aPChar, nil, nil, false,
    NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, aProcess) then
    raise exception.create(IntToStr(GetLastError));

  repeat
    if not GetExitCodeProcess(aProcess.hProcess, ExitCode) then
      raise exception.create(IntToStr(GetLastError));
  until ExitCode <> STILL_ACTIVE;
end;
{$ENDIF}

{ TxValueList ------------------------ }
function TxValueList.GetVar(Index: Integer): TxValue;
var
  s: string;
  EqPos: Integer;
begin
  if Index >= 0 then begin
    s := Trim(Strings[Index]);
    EqPos := Pos('=', s);
    if EqPos <> 0 then
     begin
       Result.Name := Trim(copy(s, 1, EqPos - 1));
       Result.Value := Trim(EndOfString(s, EqPos + 1));
       if (Result.Value <> '') and (Result.Value[1] in ['''', '"']) and
          (LastChar(Result.Value) in ['''', '"']) then
        begin
         System.Delete(Result.Value, 1, 1);
         System.Delete(Result.Value, Length(Result.Value), 1);
        end;
     end
    else
     begin
       Result.Name := '';
       Result.Value := '';
     end;
  end
  else begin
       Result.Name := '';
       Result.Value := '';
  end;
end;

function TxValueList.VarIndex(Name: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
   if CompareText(GetVar(i).Name, Name) = 0 then
    begin
      Result := i;
      exit;
    end;
end;

function TxValueList.GetVarValue(Name: string): string;
begin
  Result := GetVar(VarIndex(Name)).Value;
end;

function TxValueList.GetValue(Index: Integer): string;
begin
  Result := GetVar(Index).Value;
end;

function TxValueList.GetName(Index: Integer): string;
begin
  Result := GetVar(Index).Name;
end;

procedure TxValueList.SetValue(Index: Integer; Value: string);
begin
  strings[Index] := Names[Index] + ' = ''' + Value + '''';
end;

procedure TxValueList.SetName(Index: Integer; Value: string);
begin
  strings[Index] := Value + ' = ''' + GetValue(Index) + '''';
end;

{ TClassList ------------------------ }

constructor TClassList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TClassList.Destroy;
begin
  Clear;
  FList.Free;    
  inherited Destroy;
end;

function TClassList.Get(Index: Integer): TObject;
begin
  Result := FList[Index];
end;

function TClassList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TClassList.Add(Item: TObject): Integer;
begin
  Result := FList.Add(Item);
end;

function TClassList.Equals(List: TClassList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if List.Count <> FList.Count then Exit;
  for I := 0 to List.Count - 1 do if List[I] <> FList[I] then Exit;
  Result := True;
end;

procedure TClassList.Clear;
var
  i: Integer;
begin
  for i := 0 to count - 1 do
   if FList[i] <> nil then
     TObject(FList[i]).Free;
  FList.Clear;
end;

procedure TClassList.Delete(Index: Integer);
begin
  if (Index > Count - 1) or (Index < 0 ) then
    raise ExClassList.Create('Index out of bounds.');
  if FList[Index] <> nil then
    TObject(FList[Index]).Free;
  FList.Delete(Index);
end;

procedure TClasslist.Remove(Item: TObject);
var
  Index: Integer;
begin
  Index := FList.IndexOf(Item);
  if Index = -1 then
    raise ExClassList.Create('Object not found.')
  else
    Delete(Index);
end;

function TClassList.GetLast: TObject;
begin
  Result := FList.Last;
end;

function TClassList.IndexOf(Item: TObject): Integer;
begin
  Result := FList.IndexOf(Item);
end;

procedure TClassList.Insert(Index: Integer; Item: TObject);
begin
  FList.Insert(Index, Item);
end;


{ *********** TElementList **************** }

constructor TxElementList.Create;
begin
  inherited Create;
  Evaluated := false;
  FText := '';
  //FDelimiters := '.';
  FDelimiters := DecimalSeparator;
  FMainDelimiters := '';
  FAllowEmpty := true;
  FElements := TStringList.Create;
end;

destructor TxElementList.Destroy;
begin
  FElements.Free;
  inherited Destroy;
end;

procedure TxElementList.FillList;
var
  i: Integer;
  s: string;
  Start: Integer;

  procedure AddThis(Value: string; FirstPos: Integer);
  begin
    FElements.Add(Value);
    FElements.Objects[FElements.Count - 1] := Pointer(FirstPos);
  end;
  
begin
  s := '';
  Start := 1;

  for i := 1 to Length(FText) do
   if (Pos(FText[i], FDelimiters) <> 0) or
      (Pos(FText[i], FMainDelimiters) <> 0) then
    begin
      if (s <> '') or FAllowEmpty then
        AddThis(s, Start);

      if Pos(FText[i], FMainDelimiters) <> 0 then
        AddThis(FText[i], i);

      s := '';
      Start := i + 1;
    end
   else
     s := s + FText[i];

   if (s <> '') or FAllowEmpty then
     AddThis(s, Start);
end;

procedure TxElementList.Evaluate;
begin
  if Evaluated then exit;

  FElements.Clear;

  FillList;

  Evaluated := true;
end;

procedure TxElementList.SetText(Value: string);
begin
  FText := Value;
  Evaluated := false;
end;

procedure TxElementList.SetAllowEmpty(Value: Boolean);
begin
  FAllowEmpty := Value;
  Evaluated := false;
end;

procedure TxElementList.SetDelimiters(Value: string);
begin
  FDelimiters := Value;
  Evaluated := false;
end;

procedure TxElementList.SetMainDelimiters(Value: string);
begin
  FMainDelimiters := Value;
  Evaluated := false;
end;

function TxElementList.GetElementCount: Integer;
begin
  if not Evaluated then Evaluate;
  Result := FElements.Count;
end;

function TxElementList.GetElement(Index: Integer): string;
begin
  if not Evaluated then Evaluate;
  Result := FElements[Index];
end;

function TxElementList.GetLastElement: string;
begin
  Result := GetElement(GetElementCount - 1);
end;

// TxListProperty and TxSortedListProperty

function TxListProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paMultiSelect];
end;

procedure TxListProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

function TxSortedListProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;


// ___TIntegerList ____________________

function TIntegerList.GetItem(Index: Integer): Integer;
var
  aValue: Pointer;
begin
  aValue := inherited Items[Index];
  Result := Integer(aValue);
end;

procedure TIntegerList.Add(const Value: Integer);
begin
  inherited Add(Pointer(Value));
end;

procedure TIntegerList.Assign(Source: TIntegerList);
var
  i: Integer;
begin
  Clear;
  for i := 0 to Source.Count - 1 do
    Add(Source.Items[i]);
end;


procedure OpenRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKey('Software\Golden Software\Shared', True) then
      raise ExStorm.Create('Ошибка открытия Registry!');

    if not Reg.ValueExists('xStormPath') then
      Reg.WriteString('xStormPath', 'd:\Golden\Comp5\xStorm');

    xStormPath := Reg.ReadString('xStormPath');
  finally
    Reg.Free;
  end;
end;

begin
{  OpenRegistry;}
end.

