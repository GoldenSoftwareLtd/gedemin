{$Define DebugToConsole}

unit Debugger;

interface

var
  X : Text;

{$Ifdef DebugToConsole}
  {.$Define SupportOEM}
{$Else}
  const
    // This is a path on IB Server !!!
    // D: is native (not mapped) server drive, change it as you need
    DebuggerFileName = 'd:\ib\bin\UDFDemo.log';
{$Endif}

implementation
{$Ifdef DebugToConsole}
  uses Windows;

  var
    ConsoleTitle : PChar = 'Interbase UDF Debug Console';
    ConsoleOutputHandle: THandle = INVALID_HANDLE_VALUE;
    ConsoleWinHandle: THandle = INVALID_HANDLE_VALUE;

  {$Ifdef SupportOEM}
    function InOutFuncX(var TR: TTextRec): Integer; far;
    var
      WrittenLen: DWord;
    begin
      with TR do begin
        if BufPos <> 0 then begin
          CharToOemBuff(PChar(BufPtr), PChar(BufPtr), BufPos);
          WriteConsole(ConsoleOutputHandle, PChar(BufPtr), BufPos, WrittenLen, nil);
          BufPos := 0;
        end;
      end;
      Result := 0;
    end;

    function CloseFuncX(var TR: TTextRec): Integer; far;
    begin
      Result := 0;
    end;

    function OpenX(var TR: TTextRec): Integer; far;
    begin
      with TR do begin
        InOutFunc := @InOutFuncX; FlushFunc := @InOutFuncx; CloseFunc := @CloseFuncx;
        Mode := fmOutput;
      end;
      Result := 0;
    end;

    procedure AssignConsole(var T: Text);
    begin
      with TTextRec(T) do begin
        Handle := $FFFF; BufSize := SizeOf(Buffer); BufPtr := @Buffer;
        BufPos := 0; OpenFunc := @OpenX; Name[0] := #0; Mode := fmClosed;
      end;
    end;
  {$Endif SupportOEM}

  function ChangeScreenSize(Handle: THandle): Bool;
  var
    CSI : TConsoleScreenBufferInfo;
  begin
    GetConsoleScreenBufferInfo(Handle, CSI);
    with CSI.dwSize do begin
      x := x * 2; y := y * 10; // Set X & Y console screen length 80*2 X 25*10
    end;

    Result := SetConsoleScreenBufferSize(Handle, CSI.dwSize);

    if Result then
      with CSI.dwSize do
        Writeln('Screen size changed to ', x, ' x ', y);
  end;

  {
  function EnumWindowsProc(hW : Hwnd; L : Longint) : Bool; stdcall; export;
  var
    OtherCaption : Array[0..100] of Char;
  begin
    GetWindowText(hW, @OtherCaption, SizeOf(OtherCaption));
    if (StrComp(ConsoleTitle, OtherCaption) = 0) then
      ConsoleWinHandle := hW;
    Result := True;
  end;
  }

  procedure CreateConsole;
  var
    ConsoleTitleOld : PChar;
    ChangeScreenSizeResult: Bool;
  begin
    AllocConsole;
    Writeln('This is ', ConsoleTitle, '. Don''t try to close it!');

    GetMem(ConsoleTitleOld, 1024);
    GetConsoleTitle(ConsoleTitleOld, 1024);
    ConsoleWinHandle := FindWindow('tty', ConsoleTitleOld);
    FreeMem(ConsoleTitleOld, 1024);

    SetConsoleTitle(ConsoleTitle);

    {
    Sleep(100);
    EnumWindows(@EnumWindowsProc, 0);
    }

    ConsoleOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    ChangeScreenSizeResult := ChangeScreenSize(ConsoleOutputHandle);
    if not ChangeScreenSizeResult and (ConsoleWinHandle <> 0) then begin
      SendMessage(ConsoleWinHandle, $0414, $47160001, 0);
      ChangeScreenSizeResult := ChangeScreenSize(ConsoleOutputHandle);
    end;

    if not ChangeScreenSizeResult then begin
      Writeln('Can''t change screen size...');
      Writeln('Press Ctrl-Enter to switch between full-screen and window.');
    end;

// Set console code page = database code page

// Call for Win NT [Not tested yet...]
//  SetConsoleOutputCP(1251);

// SetConsoleOutputCP(1251) function isn't implemented for W95
// we must use other technique
    AssignFile(X, '');                       // Console = StdOut = X

    {$Ifdef SupportOEM}
      AssignConsole(X);                        // OEM conversion on
      Writeln('OEM support enabled!');
    {$Esle}
      Writeln('OEM support disabled!');
    {$Endif SupportOEM}
  end;
{$Endif DebugToConsole}

initialization
  {$Ifdef DebugToConsole}
    CreateConsole;
  {$Else}
    AssignFile(X, DebuggerFileName);
  {$Endif}
  Rewrite(X);
finalization
  CloseFile(X);
  {$Ifdef DebugToConsole}
    FreeConsole;
  {$Endif}
end.


// ќбъ€снить, почему нельз€ использовать стековые переменные дл€ результата

Subject:
        UDFLib
    Date:
        Wed, 23 Apr 97 14:40:00 EDT
   From:
        "Bailey, Ken (Unisys)" <BaileyK@volpe3.dot.gov>
Reply-To:
        interbase@esunix1.emporia.edu
     To:
        "'interbase@esunix1.emporia.edu'" <interbase@esunix1.emporia.edu>


Oleg,

I recently downloaded UDFLib and used it to write a couple of functions.
You made my life much easier. Thanks for the effort.

Here are the functions I wrote. Use them if you wish.

Ken Bailey
Falmouth Software Works Ltd.


Interface

function make_date_time(var theDate, theTime : TIBDateTime): PIBDateTime;
cdecl; export;
function elapsed_time(var dateFrom, dateTo : TIBDateTime): Double; cdecl;
export;
function year_offset(var dateFrom: TIBDateTime; var iDelta : integer):
PIBDateTime; cdecl; export;
function month_offset(var dateFrom: TIBDateTime; var iDelta : integer):
PIBDateTime; cdecl; export;
function offset(var dateFrom: TIBDateTime; iYear, iMonth : integer):
PIBDateTime;

Implementation

{Combines a date and time into a single value}
function make_date_time(var theDate, theTime : TIBDateTime): PIBDateTime;
var
 dateOut      : TIBDateTime;
begin
    dateOut.Days := theDate.Days;
 dateOut.MSec10 := theTime.MSec10;
    result := @dateOut;
end;

{Calculates difference (in hours) between two DateTimes. Result returned   
as a double.}
function elapsed_time(var dateFrom, dateTo : TIBDateTime): Double;
var
   t_from, t_to     : TDateTime;
begin
 with dateFrom do
      t_from := Days - IBDateDelta + (MSec10) / MSecsPerDay10;
 with dateTo do
  t_to := Days - IBDateDelta + (MSec10) / MSecsPerDay10;
 t_to := 24.0 * (t_to - t_from);
 result := t_to;
end;

{Adds years and months to a date.
 Will not change months ie. adding 1 month to Jan 30 returns Feb 28 or   
29.}
function offset(var dateFrom: TIBDateTime; iYear, iMonth : integer):   
PIBDateTime;
var
   t_work       : TDateTime;
 dateOut       : TIBDateTime;
   wYear, wMonth, wDay     : word;
 wTestMo      : word;
begin
 with dateFrom do
  t_work := Days - IBDateDelta;
 decodeDate(t_work, wYear, wMonth, wDay);
 while iMonth < 0 do
 begin
     iMonth := iMonth + 12;
  iYear := iYear - 1;
 end;
 wYear := wYear + iYear;
 wMonth := wMonth + iMonth;
 while wMonth > 12 do
 begin
     wMonth := wMonth - 12;
  wYear := wYear + 1;
 end;
 t_work := encodeDate(wYear, wMonth, wDay);
 decodeDate(t_work, wYear, wTestMo, wDay);
 while (wMonth <> wTestMo) and (wDay > 1) do
 begin
  wDay := wDay - 1;
  t_work := encodeDate(wYear, wMonth, wDay);
  decodeDate(t_work, wYear, wTestMo, wDay);
 end;
 dateOut.Days := trunc(t_work) + iBDateDelta;
 dateOut.MSec10 := 0;
 result := @DateOut;
end;

{Add years to a date. Offset can be positive or negative.}
function year_offset(var dateFrom: TIBDateTime; var iOffset : integer):   
PIBDateTime;
begin
 result := offset(dateFrom, iOffset, 0);
end;

{Add months to a date. Offset can be positive or negative.}
function month_offset(var dateFrom: TIBDateTime; var iOffset : integer):   
PIBDateTime;
begin
 result := offset(dateFrom, 0, iOffset);
end;

