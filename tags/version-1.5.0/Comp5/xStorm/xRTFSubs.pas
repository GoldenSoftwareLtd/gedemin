{++

  Some internal routines for xRTF unit.
  Copyright c) 1996 - 97 by Golden Software

  Module

    xRTFSubs.pas

  Abstract

    Internal.

  Author

    Vladimir Belyi (5-oct-1997)

  Contact address

    andreik@gs.minsk.by
    vladimir@belyi.minsk.by

  Uses

    Units:

    Forms:

    Other files:

  Revisions history

    1.00   5-oct-1997  belyi   Moved from xRTFSubs and updated.
    1.01  13-oct-1997  belyi  TxRTFPrinter class added

  Known bugs

    -

  Wishes

    -

  Notes / comments

    -

--}



unit xRTFSubs;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, DsgnIntF,
  xBasics, xRTFPrgF, xWorld;

const
  rtfUnknown            = 0;
  rtfGroupStart         = 1;
  rtfGroupEnd           = 2;
  rtfPlainText          = 3;
  rtfControlSymbol      = 4;
  rtfControlWord        = 5;
  rtfDestination        = 6;

const
  ReaderDataSize = 1000;
  WriterDataSize = 1000;

type
  TxRTFControlWord = record
    CWord: string[10];
    Value: string[10];
  end;

  // class to read RTF file from disk
  TxRTFReader = class
  private
    FFile: file;
    Data: array[0..ReaderDataSize - 1] of char;
    DataHead: Integer;
    DataTail: Integer;
    DataBytes: Integer; { bytes in data }
    FileSize: LongInt;
    FileRead: LongInt;
    UpdateStep: LongInt;
    function GetItem(Index: LongInt): Char;
  protected
    procedure ReadData; virtual;
  public
    constructor Create(FileName: string);
    destructor Destroy; override;
    function Next: LongInt;
    function ReadControlWord: TxRTFControlWord;
    function ReadControlSymbol: char;
    function ReadGroupStart: Boolean;
    function ReadGroupEnd: Boolean;
    function ReadPlainTextChar: Char;
    function ReadHex: Byte;
    procedure Skip(Amount: LongInt);
    procedure SkipGroup;
    procedure SkipTillGroupEnd;
    procedure ReadError;
    property Items[Index: LongInt]: Char read GetItem;
  end;

  TxRTFReaderStream = class(TxRTFReader)
  private
    FStream: TStream;
  protected
    procedure ReadData; override;
  public
    constructor Create(AnStream: TStream); reintroduce;
  end;

  // class to write RTF file to disk
  TxRTFWriter = class
  private
    FFile: file;
    Data: array[0..ReaderDataSize - 1] of char;
    DataBytes: Integer; { bytes in data }
  public
    constructor Create(FileName: string);
    destructor Destroy; override;
    procedure WriteString(const s: string);
    procedure FlushData;
    procedure StartGroup;
    procedure EndGroup;
    procedure WriteLongWord(AWord: string; Value: Integer);
    procedure WriteShortWord(AWord: string);
    procedure WritePChar(Value: PChar);

    { next procs have code moved from xRTF }
    procedure xWriteGroup(aGroup: TObject);
  end;

  // class to keep single page
  TxPages = class
    From: Integer; // first character on the page
    Till: Integer; // last character on the page
  end;

  // class used to pring RTF including all user interface
  TxRTFPrinter = class
  private
    FPrinters: TStringList;
    RTFFile: TObject;
  protected
    procedure GetPrinters;
  public
    Device, Driver, Port: array[0..255] of char;
    DeviceMode: THandle;
    Pages: TClassList;
    Copies: Integer;
    constructor Create(anRTFFile: TObject);
    destructor Destroy; override;
    function ShowDialog: Boolean;
  end;


  { ** some minor staff ** }

const
  DataFileVersion = 1;
  SupportedVersions = [1];

const
  DefWidth = 100;
  DefHeight = 100;
  //gap between headers(footers) and body text in preview window
  HeaderFooterGap = 5;

  //size of memory allocated at one step when picture data is getting read
  MemAllocStep = 50000;

  // default width for borders
  DefaultBorderWidth = 10;

const
  WM_REDRAWIMAGE = WM_USER + 1;

var
  PicFile: File Of Byte;

const
  cwUnknown             = 0;
  cwVersion             = 1;

const
  { characters which result in words delimiting. the place where they occur may be
    used for hypernation }
  WordDelimiters = ' ,.?!''";:*`~@#$%^&-=+()[]{}';

  // default colors to draw text and background
  DefForeColor: TRGBTRIPLE =
    (rgbtBlue: 0;
     rgbtGreen: 0;
     rgbtRed: 0);
  DefBKColor: TRGBTRIPLE =
    (rgbtBlue: 255;
     rgbtGreen: 255;
     rgbtRed: 255);

type
  TxRTFDocFormat = record
    PaperWidth: LongInt;
    PaperHeight: LongInt;
    LeftMargin: LongInt;
    RightMargin: LongInt;
    TopMargin: LongInt;
    BottomMargin: LongInt;
    LandScape: Boolean;
    FirstPage: LongInt;
    HeaderY: LongInt;
    FooterY: LongInt;
  end;

  TxRTFFileHeader = record
    Version: LongInt;
    CharSet: string[4];
    DefaultFont: LongInt;
  end;

const
  ColorTableSize = 100;

type
  PColorTable = ^TColorTable;
  TColorTable = array[0..ColorTableSize - 1] of TRGBTRIPLE;

const
  MaxTabXNum = 10;

type
  TxRTFPreviewOption = (poShowSides, poShowPageBreaks, poDrawTBMargins,
    poDrawLRMargins);
  TxRTFPreviewOptions = set of TxRTFPreviewOption;

  TxParaAlign = (alLeft, alRight, alCentered, alJustified);

  // information used to draw paragraph
  TxParaInfo = record
    FirstLine: LongInt;
    LeftIndent: LongInt;             // indent of the left side of para
    RightIndent: LongInt;            // indent of the right side of para
    SpaceBefore: LongInt;            // Space before the paragraph
    SpaceAfter: LongInt;             // space after the paragraph
    SpaceBetweenLines: LongInt;      //
    MultipleLineSpacing: LongInt;
    Style: Integer;                  // style index (not supported yet)
    Hyphenate: Boolean;
    Intact: Boolean;
    WithNext: Boolean;               // keep with next
    OutlineLevel: Integer;
    BBPage: Boolean;
    SideBySide: Boolean; { what is this? - i don't know }
    Align: TxParaAlign;
    Shading: Integer;
    ForeColor: TRGBTRIPLE;
    BKColor: TRGBTRIPLE;
    TabXNum: Byte;
    TabX: array[0..MaxTabXNum] of Integer;
    TerminatePageAfterPara: Boolean;
  end;

  PBorderType = ^TBorderType;
  TBorderType = record
    w: Integer;
  end;

  // Parameters of a cell in the table row
  TxCellInfo = record
    RightBound: LongInt;
    Shading: Integer;
    ForeColor: TRGBTRIPLE;
    BKColor: TRGBTRIPLE;
    LeftBorder: TBorderType;
    TopBorder: TBorderType;
    RightBorder: TBorderType;
    BottomBorder: TBorderType;
  end;

  { Information about the picture. Keeps all the fields from RTF file.
    See RTF description for details }
  TxPictInfo = record
    PictType: string[10];    // type of the picture (metafile, bitmap,...
    PictTypeN: Integer;      // format version
    PicWidth: Integer;
    PicHeight: Integer;
    DesiredWidth: Integer;
    DesiredHeight: Integer;
    ScaleX: Integer;
    ScaleY: Integer;
    Scaled: Boolean;
    TopCrop: Integer;
    BottomCrop: Integer;
    LeftCrop: Integer;
    RightCrop: Integer;
    BMPinMetafile: Boolean;
    BitsPerPixel: Integer;
    BinDataSize: LongInt;

    { next are to store picture data }
    DataRead: LongInt;
    DataSize: LongInt;
    DataHandle: THandle;
    DataPointer: PxByteArray;
  end;

  TDrawCommand =
    (dcDrawWhole,       // draws a RTF context on canvas
     dcFindLineHeight,  // calculates the height of the line
     dcDrawLine
     );

  TDrawOptions = record
    From: LongInt;         // index of the first charcter to draw
    Till: LongInt;
    Cmd: TDrawCommand;     // command to perform (e.g. draw or perform some calculations
    LineHeight: LongInt;   {  Height of the line to draw (to allighn text or pictures
                              to bottom of the line, not to the top) }
    TextBottom: LongInt;   // characterizes text bottom relative to line bottom
    Line: LongInt;
    DrawRect: TRect;       {  clipping rect for all drawings (does not affect text
                              wrapping and so on) }
    HShift: LongInt;       {  horizontal shift of the drawing. Used to allow horizontal
                              browsing during screen viewing }
  end;

  TDrawResult = record
    NextLineStart: LongInt;
    LineHeight: LongInt;
    TextBottom: LongInt;
    LineWidth: LongInt;
  end;

  TxBasicState = set of (bsViewValid, bsSizeValid, bsBuilding);

  TxDataFieldRec = record
    Unknown: array[0..7] of byte;
    Name: string;
    Unknown1: byte;
    DefaultText: string;
  end;

  // class to describe lines in paragraph
  TxParaLine = class
    Start: LongInt;      // index of the first character in the line
    Height: Integer;     // height of the line (in pixels)
    TextBottom: Integer;
    Width: Integer;      // width of the line. This value is used to perform allignings
  public
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
  end;

  TxRTFPage = class
    FirstLine: LongInt;
    LastLine: LongInt;
  public
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
  end;

  TxSeqNumber = class
    LastValue: LongInt;
    Name: string;
  end;

procedure xLine(H: THandle; a, b: TPoint);
procedure xThickLine(Handle: THandle; a, b: TPoint; w, h: Integer);
function FetchStr(var Str: PChar): PChar;
function GetRGBColor(Color: TRGBTRIPLE; Shading: Integer): LongInt;
procedure SetDefaultFont(var AFont: TLogFont);
function CompareFonts(a, b: TLogFont): Boolean;
function CompareColors(a, b: TRGBTRIPLE): Boolean;

var
  lnOpenFail: Integer;
  lnPageCount: Integer;
  lnFrom: Integer;
  lnTerminate: Integer;
  lnCreateFail: Integer;

type
  ExRTF = class(ExStorm);
  ExRTFReader = class(ExRTF);
  ExRTFWriter = class(ExRTF);

implementation

uses xRTF, xPrintF;

procedure xLine(H: THandle; a, b: TPoint);
var
  ar: array[0..1] of TPoint;
begin
  ar[0] := a;
  ar[1] := b;
  PolyLine(H, ar, 2);
end;

procedure xThickLine(Handle: THandle; a, b: TPoint; w, h: Integer);
var
  ar: array[0..1] of TPoint;
  i: Integer;
begin
  if w > 1 then
   begin
     ar[0].x := a.x - w div 2;
     ar[0].y := a.y;
     ar[1].x := b.x - w div 2;
     ar[1].y := b.y;
     for i := 1 to w do
      begin
        PolyLine(Handle, ar, 2);
        inc(ar[0].x);
        inc(ar[1].x);
      end;
   end

  else if h > 1 then
   begin
     ar[0].x := a.x;
     ar[0].y := a.y - h div 2;
     ar[1].x := b.x;
     ar[1].y := b.y - h div 2;
     for i := 1 to h do
      begin
        PolyLine(Handle, ar, 2);
        inc(ar[0].y);
        inc(ar[1].y);
      end;
   end

  else
   begin
     ar[0] := a;
     ar[1] := b;
     PolyLine(Handle, ar, 2);
   end;
end;

{ FetchStr }
function FetchStr(var Str: PChar): PChar;
var
  P: PChar;
begin
  Result := Str;
  if Str = nil then Exit;
  P := Str;
  while P^ = ' ' do Inc(P);
  Result := P;
  while (P^ <> #0) and (P^ <> ',') do Inc(P);
  if P^ = ',' then
  begin
    P^ := #0;
    Inc(P);
  end;
  Str := P;
end;

function GetRGBColor(Color: TRGBTRIPLE; Shading: Integer): LongInt;
begin
  Result := RGB(
    MulDiv(Color.rgbtRed, (10000 - Shading), 10000),
    MulDiv(Color.rgbtGreen, (10000 - Shading), 10000),
    MulDiv(Color.rgbtBlue, (10000 - Shading), 10000));
end;

procedure SetDefaultFont(var AFont: TLogFont);
begin
  with AFont do
   begin
     lfHeight := 0; { i.e. default }
     lfWidth := 0; { have font mapper choose }
     lfEscapement := 0; { only straight fonts }
     lfOrientation := 0; { no rotation }
     lfWeight := FW_NORMAL;
     lfItalic := 0;
     lfUnderline := 0;
     lfStrikeOut := 0;
     lfCharSet := RUSSIAN_CHARSET;
//     lfCharSet := DEFAULT_CHARSET;
     StrPCopy(lfFaceName, '');
     lfQuality := DEFAULT_QUALITY;
     lfOutPrecision := OUT_DEFAULT_PRECIS;
     lfClipPrecision := CLIP_DEFAULT_PRECIS;
     lfPitchAndFamily := DEFAULT_PITCH;
   end;
end;

function CompareFonts(a, b: TLogFont): Boolean;
begin
  Result := CompareMem(@a, @b, SizeOf(TLogFont) - lf_FaceSize);
  if Result then
    Result := StrIComp(a.lfFaceName, b.lfFaceName) = 0;
end;

function CompareColors(a, b: TRGBTRIPLE): Boolean;
begin
  Result := (a.rgbtRed = b.rgbtRed) and
            (a.rgbtGreen = b.rgbtGreen) and
            (a.rgbtBlue = b.rgbtBlue);
end;

{ ============ TPrinterDevice =========== }

type
  TPrinterDevice = class(TObject)
  public
    Driver, Device, Port: PChar;

    constructor Create(ADriver, ADevice, APort: PChar);
    destructor Destroy; override;

    //function IsEqual(ADriver, ADevice, APort: PChar): Boolean;
  end;

constructor TPrinterDevice.Create(ADriver, ADevice, APort: PChar);
begin
  inherited Create;
  Driver := StrNew(ADriver);
  Device := StrNew(ADevice);
  Port := StrNew(APort);
end;

destructor TPrinterDevice.Destroy;
begin
  StrDispose(Driver);
  StrDispose(Device);
  StrDispose(Port);
  inherited Destroy;
end;

{
function TPrinterDevice.IsEqual(ADriver, ADevice, APort: PChar): Boolean;
begin
  Result := (StrComp(Driver, ADriver) = 0) and (StrComp(Device, ADevice) = 0)
    and (StrComp(Port, APort) = 0);
end;
}

{ ========== TxRTFReader ============ }

constructor TxRTFReader.Create(FileName: string);
var
  OldErrorMode: Word;
  Retry: Boolean;
  aFile: string;
begin
  inherited Create;
  aFile := RealFileName(FileName);

  if not(FileExists(aFile)) or (aFile = '') then
    raise ExRTFReader.Create( Format(Phrases[LnOpenFail], [aFile]) );

  AssignFile(FFile, aFile);
  FileMode := 0;
  OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    {$I-}
    repeat
      Reset(FFile, 1);
      if IOResult <> 0 then
       begin
        Retry := MessageDlg(Format(Phrases[lnOpenFail], [aFile]), mtError,
         [mbRetry, mbAbort], 0) <> mrAbort;
        if not Retry then Abort;
       end
      else
        Retry := false;
    until not Retry;
    {$I+}
  finally
    SetErrorMode(OldErrorMode);
  end;
  FileSize := system.FileSize(FFile);
  FileRead := 0;
  RTFProgress.UpdateMaxValue(FileSize);
  UpdateStep := FileSize div 200;
  DataHead := 0;
  DataTail := 0;
  DataBytes := 0;
  ReadData;
end;

destructor TxRTFReader.Destroy;
begin
  {$I-}
  CloseFile(FFile);
  if IOResult <> 0 then {no matter};
  {$I+}
  inherited Destroy;
end;

procedure TxRTFReader.ReadData;
var
  WasRead: Integer;
begin
  if DataBytes = 0 then
   begin
     DataHead := 0;
     BlockRead(FFile, Data, ReaderDataSize, DataTail);
     DataBytes := DataTail;
     if DataTail = ReaderDataSize then
       DataTail := 0;
   end
  else
   begin
     if DataTail > DataHead then
      begin
        if DataTail < ReaderDataSize then
         begin
           BlockRead(FFile, Data[DataTail], ReaderDataSize - DataTail, WasRead);
           DataTail := DataTail + WasRead;
           DataBytes := DataBytes + WasRead;
         end;
        if DataTail = ReaderDataSize then
          DataTail := 0;
      end;
     if DataTail < DataHead then
      begin
        BlockRead(FFile, Data[DataTail], DataHead - DataTail, WasRead);
        DataTail := DataTail + WasRead;
        DataBytes := DataBytes + WasRead;
      end;
   end;
end;

procedure TxRTFReader.ReadError;
begin
  raise ExRTFReader.Create('File is corrupted.');
end;

procedure TxRTFReader.Skip(Amount: LongInt);
begin
  inc(FileRead, Amount);
  RTFProgress.Update(FileRead, '');
  while Amount > 0 do
   begin
     if DataBytes = 0 then
       ReadData;
     if DataBytes = 0 then
       raise ExRTFReader.Create('Failed to read data from RTF file.');
     if Amount >= DataBytes then
      begin
        Amount := Amount - DataBytes;
        DataBytes := 0;
      end
     else
      begin
        DataHead := (DataHead + Amount) mod ReaderDataSize;
        DataBytes := DataBytes - Amount;
        Amount := 0;
      end;
   end;
end;

function TxRTFReader.GetItem(Index: LongInt): char;
begin
  if Index >= DataBytes then
    ReadData;
  if Index >= DataBytes then
    raise ExRTFReader.Create('Failed to read data from RTF file.');
  Result := Data[(DataHead + Index) mod ReaderDataSize];
end;

function TxRTFReader.Next: LongInt;
begin
  { Next line is for debugging purposes only!
    This line is often called during loading and gives a way to terminate
    if suspended. But it slows down the reading process. }
{$IFDEF DEBUGGING}
  Application.ProcessMessages;
{$ENDIF}

  while Items[0] in [#13, #10] do Skip(1);

  case Items[0] of
    '{':
      begin
        if (Items[1] = '\') and (Items[2] = '*') then
          result := rtfDestination
        else
          Result := rtfGroupStart;
      end;
    '}': Result := rtfGroupEnd;
    '\':
      begin
        case Items[1] of
           'a'..'z': Result := rtfControlWord;
           '{', '}', '\', '''': Result := rtfPlainText;
           else Result := rtfControlSymbol;
         end;
      end;
    else
      Result := rtfPlainText;
  end;
end;

function TxRTFReader.ReadGroupStart: Boolean;
begin
  Result := Next = rtfGroupStart;
  if Result then Skip(1);
end;

function TxRTFReader.ReadGroupEnd: Boolean;
begin
  Result := Next = rtfGroupEnd;
  if Result then Skip(1);
end;

function TxRTFReader.ReadPlainTextChar: Char;
begin
  if Next <> rtfPlainText then ReadError;

  Result := Items[0];
  Skip(1);

  if Result = '\' then
   begin
     Result := Items[0];
     Skip(1);
     if Result = '''' then
      begin
        Result := Chr(HexCharToByte(Items[0]) * 16 + HexCharToByte(Items[1]));
        Skip(2);
      end;
   end;
end;

function TxRTFReader.ReadHex: Byte;
begin
  Result := HexCharToByte(Items[0]) * 16;
  Result := Result + HexCharToByte(Items[1]);
  Skip(2);
end;

function TxRTFReader.ReadControlWord: TxRTFControlWord;
var
  i: LongInt;
begin
  if Next <> rtfControlWord then ReadError;
  Result.CWord := '';
  i := 1;
  while Items[i] in ['a'..'z', 'W'] do
   begin
     Result.CWord := Result.CWord + Items[i];
     inc(i);
   end;
{
//  if AnsiPos('Width', Result.CWord) <> 0 then
//  begin
    AssignFile(F, 'd:\golden\commands.txt');

    if FileExists('d:\golden\commands.txt') then
      Append(F)
    else
      Rewrite(f);

    Writeln(F, Result.CWord);
    CloseFile(F);
//  end;
}
  if Items[i] in ['-', '0'..'9'] then
   begin
     Result.Value := Items[i];
     inc(i);
     while Items[i] in ['0'..'9'] do
      begin
        Result.value := Result.Value + Items[i];
        inc(i);
      end;
   end
  else
   begin
     Result.Value := '';
   end;

  if Items[i] = ' ' then inc(i);

  Skip(i);
end;

function TxRTFReader.ReadControlSymbol: char;
begin
  if Next <> rtfControlSymbol then ReadError;
  Result := Items[1];
  Skip(2);
end;

procedure TxRTFReader.SkipGroup;
begin
  if not(Next in [rtfGroupStart, rtfDestination]) then
    raise ExRTFReader.Create('File is corrupted.');
  skip(1);
  SkipTillGroupEnd;
end;

procedure TxRTFReader.SkipTillGroupEnd;
var
  Depth: LongInt;
begin
  Depth := 1;
  repeat
    case Next of
      rtfGroupStart, rtfDestination:
        begin
          inc(Depth);
          Skip(1);
        end;
      rtfGroupEnd:
        begin
          dec(depth);
          Skip(1);
        end;
      rtfPlainText: ReadPlainTextChar;
      rtfControlSymbol: ReadControlSymbol;
      rtfControlWord: ReadControlWord;
      else
        Skip(1);
    end;
  until Depth = 0;
end;

{ ========== TxRTFReaderStream ============ }

procedure TxRTFReaderStream.ReadData;
var
  WasRead: Integer;
begin
  if DataBytes = 0 then
   begin
     DataHead := 0;
     DataTail := FStream.Read(Data, ReaderDataSize);
     DataBytes := DataTail;
     if DataTail = ReaderDataSize then
       DataTail := 0;
   end
  else
   begin
     if DataTail > DataHead then
      begin
        if DataTail < ReaderDataSize then
         begin
           WasRead := FStream.Read(Data[DataTail], ReaderDataSize - DataTail);
           DataTail := DataTail + WasRead;
           DataBytes := DataBytes + WasRead;
         end;
        if DataTail = ReaderDataSize then
          DataTail := 0;
      end;
     if DataTail < DataHead then
      begin
        WasRead := FStream.Read(Data[DataTail], DataHead - DataTail);
        DataTail := DataTail + WasRead;
        DataBytes := DataBytes + WasRead;
      end;
   end;
end;

constructor TxRTFReaderStream.Create(AnStream: TStream);
begin
  FStream := AnStream;

  FileSize := FStream.Size;
  FileRead := 0;
  RTFProgress.UpdateMaxValue(FileSize);
  UpdateStep := FileSize div 200;
  DataHead := 0;
  DataTail := 0;
  DataBytes := 0;
  ReadData;
end;

{ ========== TxRTFWriter ============ }

constructor TxRTFWriter.Create(FileName: string);
var
  OldErrorMode: Word;
  Retry: Boolean;
  aFile: string;
begin
  inherited Create;
  aFile := RealFileName(FileName);

  if aFile = '' then
    raise ExRTFWriter.Create( Format(Phrases[LnCreateFail], [aFile]) );

  AssignFile(FFile, aFile);
  OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    {$I-}
    repeat
      Rewrite(FFile, 1);
      if IOResult <> 0 then
       begin
        Retry := MessageDlg(Format(Phrases[lnCreateFail], [aFile]), mtError,
         [mbRetry, mbAbort], 0) <> mrAbort;
        if not Retry then Abort;
       end
      else
        Retry := false;
    until not Retry;
    {$I+}
  finally
    SetErrorMode(OldErrorMode);
  end;
  DataBytes := 0;

  StartGroup;
  WriteLongWord('rtf', 1);
end;

destructor TxRTFWriter.Destroy;
begin
  EndGroup;
  FlushData;
  {$I-}
  CloseFile(FFile);
  if IOResult <> 0 then {no matter};
  {$I+}
  inherited Destroy;
end;

procedure TxRTFWriter.WriteString(const s: string);
var
  i: Integer;
begin
  for i := 1 to Length(s) do
   begin
     if DataBytes >= WriterDataSize then
       FlushData;
     Data[DataBytes] := s[i];
     inc(DataBytes);
   end;
end;

procedure TxRTFWriter.FlushData;
begin
  if DataBytes > 0 then
    BlockWrite(FFile, Data, DataBytes);
  DataBytes := 0;
end;

procedure TxRTFWriter.StartGroup;
begin
  if DataBytes >= WriterDataSize then
    FlushData;
  Data[DataBytes] := '{';
  inc(DataBytes);
end;

procedure TxRTFWriter.EndGroup;
begin
  if DataBytes >= WriterDataSize then
    FlushData;
  Data[DataBytes] := '}';
  inc(DataBytes);
end;

procedure TxRTFWriter.WriteLongWord(AWord: string; Value: Integer);
begin
  WriteString('\' + AWord + Trim(IntToStr(Value)) + ' ');
end;

procedure TxRTFWriter.WriteShortWord(AWord: string);
begin
  WriteString('\' + AWord + ' ');
end;

procedure TxRTFWriter.WritePChar(Value: PChar);
begin
  while Value^ <> #0 do
   begin
     if Value^ = '\' then
       WriteString('\\')
     else if Value^ <> #0 then
       begin
         if DataBytes >= WriterDataSize then
           FlushData;
         Data[DataBytes] := Value^;
         inc(DataBytes);
       end;

     Value := Value + 1; 
   end;
end;

procedure TxRTFWriter.xWriteGroup(aGroup: TObject);
var
  i: Integer;
begin
  for i := 0 to (aGroup as TxRTFGroup).Count - 1 do
    (aGroup as TxRTFGroup).Items[i].WriteRTF(self);
end;


{ ============== TxRTFPrinter ================= }

constructor TxRTFPrinter.Create(anRTFFile: TObject);
begin
  inherited Create;
  Device[0] := #0;
  Pages := TClassList.Create;
  RTFFile := anRTFFile;
  Copies := 1;
end;

destructor TxRTFPrinter.Destroy;
begin
  Pages.Free;
  inherited Destroy;
end;

procedure TxRTFPrinter.GetPrinters;
const
  DevicesSize = 4096;
var
  Devices: PChar;
  LineCur: PChar;
  DriverLine: array[0..79] of Char;
  Device, Driver, Port: PChar;
begin
  if FPrinters <> nil then
    FreeObject(TObject(FPrinters));
  FPrinters := TStringList.Create;
  try
    GetMem(Devices, DevicesSize);
    try
      { Get a list of devices from WIN.INI.  Stored in the form of
        <device 1>#0<device 2>#0...<driver n>#0#0 }
      GetProfileString('devices', nil, '', Devices, DevicesSize);
      Device := Devices;
      while Device^ <> #0 do
      begin
        GetProfileString('devices', Device, '', DriverLine, SizeOf(DriverLine));
        { Get driver portion of DeviceLine }
        LineCur := DriverLine;
        Driver := FetchStr(LineCur);
        { Copy the port information from the line }
        { This code is complicated because the device line is of the form:
              <device name> = <driver name> , <port> [ , <port> ]
            where port (in []) can be repeated. }
        Port := FetchStr(LineCur);
        while Port^ <> #0 do
        begin
          FPrinters.AddObject(Format('%s on %s', [Device, Port]),
            TPrinterDevice.Create(Driver, Device, Port));
          Port := FetchStr(LineCur);
        end;
        Inc(Device, StrLen(Device) + 1);
      end;
    finally
      FreeMem(Devices, DevicesSize);
    end;
  except
    FPrinters.Free;
    FPrinters := nil;
    raise;
  end;
end;

function TxRTFPrinter.ShowDialog: Boolean;
var
  Form: TxPrintDialog;
  s, s1, s2: string;
  i: Integer;
  DevMode: PDeviceMode; 

  procedure AddPages(From, Till: Integer);
  var
    x: TxPages;
  begin
    x := TxPages.Create;
    x.From := From;
    x.Till := Till;
    Pages.Add(x);
  end;
begin
  Pages.Clear;
  Form := TxPrintDialog.Create(Application);
  try
    Form.RangeAll.Checked := true;
    if Device[0] = #0 then
      Form.GetPrinter(Device, Driver, Port, DeviceMode);

    // adjust DeviceMode through giving it to Printer
    if DeviceMode = 0 then
     begin
      Form.SetPrinter(Device, Driver, Port, DeviceMode);
      Form.GetPrinter(Device, Driver, Port, DeviceMode);
     end;


    // set default orientation
    if DeviceMode <> 0 then
     begin
       DevMode := GlobalLock(DeviceMode);
       try
         if TxRTFFile(RTFFile).DocFormat.Landscape then
           DevMode.dmOrientation := DMORIENT_LANDSCAPE
         else
           DevMode.dmOrientation := DMORIENT_PORTRAIT;
       finally
         GlobalUnlock(DeviceMode);
       end;
     end;

    Form.SetPrinter(Device, Driver, Port, DeviceMode);

    // run dialog
    if Form.ShowModal = mrOk then
     begin
       Result := true;
       Copies := Form.Copies.Value;
       if Form.RangeAll.Checked then
         AddPages(1, -1)
       else if Form.RangePages.Checked then
        begin
          s := Trim(Form.PagesRange.Text);
          while length(s) > 0 do
           begin
             i := 1;
             while (i <= length(s)) and (s[i] in ['0'..'9']) do
               inc(i);
             s1 := copy(s, 1, i - 1);
             delete(s, 1, i - 1);
             s := Trim(s);
             if (Length(s) > 0) and (s[1] = '-') then
              begin
                delete(s, 1, 1);
                s := Trim(s);
                i := 1;
                while (i <= length(s)) and (s[i] in ['0'..'9']) do
                  inc(i);
                s2 := copy(s, 1, i - 1);
                delete(s, 1, i - 1);
                s := Trim(s);
                if (Length(s) > 0) and (s[1] = ',') then
                 begin
                   delete(s, 1, 1);
                   s := Trim(s);
                 end;
                { next two lines for 'opened' blocks (when first or last
                  page not specified) }
                if s1 = '' then s1 := '-1';
                if s2 = '' then s2 := '-1';

                AddPages(StrToInt(s1), StrToInt(s2));
              end
             else
              begin
                if (Length(s) > 0) and (s[1] in [',', ';']) then
                 begin
                   delete(s, 1, 1);
                   s := Trim(s);
                 end;
                AddPages(StrToInt(s1), StrToInt(s1));
              end;
           end;
        end
       else
         raise ExRTF.Create('Internal error: Don''t know what to print!?!');
     end
    else
      Result := false;

    Form.GetPrinter(Device, Driver, Port, DeviceMode);
    if Result and (DeviceMode <> 0) then
     begin
       DevMode := GlobalLock(DeviceMode);
       try
         DevMode.dmCopies := Copies;
       finally
         GlobalUnlock(DeviceMode);
       end;
       Form.SetPrinter(Device, Driver, Port, DeviceMode);
     end;
  finally
    Form.Free;
  end;
end;


{ ======== TxParaLine ========== }

procedure TxParaLine.ReadData(Reader: TReader);
begin
  Start := Reader.ReadInteger;
  Height := Reader.ReadInteger;
end;

procedure TxParaLine.WriteData(Writer: TWriter);
begin
  Writer.WriteInteger(Start);
  Writer.WriteInteger(Height);
end;

{ ======== TxRTFPage ========== }

procedure TxRTFPage.ReadData(Reader: TReader);
begin
  FirstLine := Reader.ReadInteger;
  LastLine := Reader.ReadInteger;
end;

procedure TxRTFPage.WriteData(Writer: TWriter);
begin
  Writer.WriteInteger(FirstLine);
  Writer.WriteInteger(LastLine);
end;



initialization
  Phrases.SetOrigin('xTools: Rich Text Format components');

  lnOpenFail := Phrases.AddPhrase(lEnglish, 'File ''%s'' could not be opened');
  Phrases.AddTranslation(lnOpenFail, lRussian, 'Невозможно открыть файл ''%s''');

  lnCreateFail := Phrases.AddPhrase(lEnglish, 'File ''%s'' could not be created');
  Phrases.AddTranslation(lnCreateFail, lRussian, 'Невозможно создать файл ''%s''');

  lnPageCount := Phrases.AddPhrase(lEnglish, '%d pages found.');
  Phrases.AddTranslation(lnPageCount, lRussian, 'Найдено %d страниц.');

  lnFrom := Phrases.AddPhrase(lEnglish, '%d from %d.');
  Phrases.AddTranslation(lnFrom, lRussian, '%d из %d.');

  lnTerminate := Phrases.AddPhrase(lEnglish,
    'Do you really want to terminate the file loading process?');
  Phrases.AddTranslation(lnTerminate, lRussian,
    'Вы действительно хотите прервать процесс чтения файла?');

  Phrases.ClearOrigin;

end.
