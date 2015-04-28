{++

  Components TxRTFxxxxx
  Copyright c) 1996 - 98 by Golden Software

  Module

    xRTF.pas

  Abstract

    Components to work with Rich Text Format files.

  Author

    Vladimir Belyi (January 17, 1997)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

      xBasics
      FileList

    Forms:

      xRTFPrgF
      xRTFPrnF

    Other files:

  Revisions history

    beta1 28-jan-1997  belyi  Paragraphs support and .RTF files reading.
    beta2  3-feb-1997  belyi  Tables. Indents. Fonts. Metafiles.
    beta3 12-feb-1997  belyi  Pages. Form Designer support. Scrollers.
                              Form fields.
    beta4 15-feb-1997  belyi  Bugs killing. Paragraph properties.
    beta5  3-mar-1997  belyi  All drawing is without Delphi Canvas functions now.
                              Assign function in all classes. Centered and right
                              justified text. Page Headers and Footers.
                              Table headers. Printing.
    beta6 13-mar-1997  belyi  Less bugs. PChar instead of string in TxRTFChars.
                              Some standard fields. Shading. Printing enhances.
    beta7 17-mar-1997  belyi  Resources-fixing. Speed. Bugs...
    beta8  5-apr-1997  belyi  Bugs. Less memory needed (~50 times).
                              TxRTFWord class deleted. Viewer was moved to
                              separate file (xRTFView). Now fields can store
                              text (not just a word). Empty para's and cells
                              support.
    beta9  7-apr-1997  belyi  Bugs. Less memory for fields. Fields now
                              support PChar.
    betaA  9-apr-1997  belyi  Colors. Tables shading/colors. Assigning of
                              metafiles is added.
    betaB 15-apr-1997  belyi  Bitmaps.
    betaC 21-apr-1997  belyi  Bugs. Landscape printing.
    betaD  8-may-1997  belyi  SEQ fields (see MSWord for details). Bugs.

    *******

    1.00  17-may-1997  belyi  Initial completely working version. New special
                              characters. Enhanced table borders. Symbol fields.
    1.01a 27-jul-1997  belyi  User defined tabs.
    1.01b 30-jul-1997  belyi  Tables. Multiple-row headers. Bugs. Different size
                              objects and fonts are now alligned by bottom edge.
                              Enhanced user interface.
    1.02  14-aug-1997  belyi  Bug with font loss.
    1.03   6-oct-1997  belyi  Page breaks; Russification; bugs. Some stuffed
                              moved to xRTFSubs (due to Delphi code size limit).
    1.04  13-oct-1997  belyi  Print dialog. RTF writing.

    2.00   8-jun-1998  belyi  32 bit version ready

    *******

    2.01  08-apr-1999  dennis Bug fixed. Now printing under Windows'95, '98 is supported without
                              problems.

    2.02  23-apr-1999  dennis Bug fixed. Problem with colors fixed. now i draw transparent text if
                              its color same as color of background.

    2.03 11-nov-1999   JKL    Replace PrintRTF to PrintRTF2 in all used units.
  Known bugs

    - form fields reading might be with bugs - I haven't found their
      description anywhere

    - line spacing should be after line but not above (as in current
      version)

    - Form Fields when destroyed do not destroy their references in
      parent blocks FormField list. This won't cause resource wasting but
      will leave incorrect references.

    - NextParaRef and PrevParaRef will fail if referenced block is empty -
      important for developer's use

    - fields with not fixed size (like page numbers) might fail (however,
      this was not registered yet)

    - TxRTFBitmap does not create handles from binary data

  Wishes

    -

  Notes/comments

    - Fields do not support different fonts - the font which is defined
      at the beginning will be used within whole field

    - only one section is supported - including same formatting for the
      whole documents (e.g. headers and page orientation)

    - table line should be defined from all adjusting cells in the same way:
      otherwise it may be incorrectly drawn (see .doc file for comments). 

--}

{$A+,B-,D+,F-,G+,I+,K+,L+,N+,P+,Q-,R-,S+,T-,V+,W-,X+,Y+}

{.$DEFINE BETA}

{$IFDEF BETA}
  {.$DEFINE DEBUGGING}  { this causes frequent calls to processmessages }
  {$DEFINE DEBUGGING1} { this may cause non full redrawing - it's debugging! }
{$ENDIF}

{.$DEFINE SHOWLBLI} { will show amount of space allocated after the RTF file
                      is read from disk }

unit xRTF;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, DsgnIntF,
  xBasics, xRTFPrgF, xWorld, xRTFSubs, gsMultilingualSupport, Printers;

type
  TxRTFFile = class;
  TxRTFBlock = class;
  TxRTFText = class;
  TxRTFTextPara = class;

  TxRTFBasic = class
  private
    RestoreRTFFont: Boolean;
    RTFFile: TxRTFFile;
    Owner: TxRTFBasic;
    FMinPos: LongInt;
    State: TxBasicState;
    iWidth: Integer; { was LongInt }
    iSize: LongInt;
    FLeftMargin: Integer;
    FDrawWidth: Integer;

    function GetPosition: TPoint;
    procedure SetPosition(Value: TPoint);
    procedure SetMinPos(Value: LongInt); virtual;
    function GetMaxPos: LongInt;
    function DoDraw(Opt: TDrawOptions): TDrawResult; virtual; abstract;
    procedure SetLeftMargin(Value: Integer); virtual;
    procedure SetDrawWidth(Value: Integer); virtual;
    procedure SetDefaultResult(var r: TDrawResult);
    function GetWidth: LongInt; virtual;
    function GetSize: LongInt;
    function GetOptions: TxRTFPreviewOptions;
    procedure SetOptions(Value: TxRTFPreviewOptions); virtual;
    function SetFontHandle(var AFont: TLogFont): THandle;
    function OwnerBlock: TxRTFBlock;
    function GetLeftMargin: Integer;
    procedure UpdateSize;

  protected
    Fnt: TLogFont;
    FontWasChanged: Word;

    procedure MoveX(NewX: LongInt); { chsnges position }
    procedure MoveY(NewY: LongInt);
    property Position: TPoint read GetPosition write SetPosition;
    procedure NewLine(Opt: TDrawOptions);
    function FontStyle(LogFont: TLogFont): TFontStyles;
    procedure SetCanvasFont; virtual;
    procedure RestoreCanvasFont; virtual;
    procedure BuildView; virtual;
    procedure Change; virtual;
    function TwipsToPixelsX(Twips: LongInt): LongInt;
    function TwipsToPixelsY(Twips: LongInt): LongInt;
    procedure ReadData(Reader: TReader); dynamic;
    procedure WriteData(Writer: TWriter); dynamic;
    function FindSize: LongInt; virtual;

  public
    constructor CreateChild(AnOwner: TxRTFBasic); virtual;
    destructor Destroy; override;

    function CanvasHandle: THandle;
    procedure WriteRTF(Writer: TxRTFWriter); virtual;
    procedure CheckIsBuilt;
    procedure ViewChanged; dynamic; { is send by anybody to force refresh
                                      of internal data }
    procedure Clear; dynamic;
    function ScaleMe(Value: Integer): Integer;
    function Draw(Opt: TDrawOptions): TDrawResult; virtual;
    procedure Assign(From: TxRTFBasic); dynamic;
    property Width: LongInt read GetWidth; { width of element if drawn }
    property Size: LongInt read GetSize; { Number of cursor positions within }
    property MinPos: LongInt read FMinPos write SetMinPos;
    property MaxPos: LongInt read GetMaxPos;
    property Options: TxRTFPreviewOptions read GetOptions write SetOptions;
    property LeftMargin: Integer read GetLeftMargin write SetLeftMargin;
  end;

  TxRTFChars = class(TxRTFBasic)
  private
    Data: PChar;
    OwningTextPara: TxRTFTextPara;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    function TxtWidth(s: PChar; Count: Integer): LongInt;
    procedure iSetData(Value: string);
  protected
    procedure Resize(NewSize: Word);
    procedure BuildView; override;
    procedure Change; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FindSize: LongInt; override;
  public
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure Clear; override;
    procedure AddData(Value: string);
    procedure SetData(Value: string);
    procedure Assign(From: TxRTFBasic); override;
    function BlockWidth(From, Till: LongInt): LongInt;

  end;

  TxRTFTabChar = class(TxRTFBasic)
  private
    function GetWidth: LongInt; override;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
  protected
    procedure Change; override;
    function FindSize: LongInt; override;
  public
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFPicture = class(TxRTFBasic)
  private
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    procedure DrawPicture(Opt: TDrawOptions); virtual; abstract;
    function PicDrawWidth: Integer;
    function PicDrawHeight: Integer;
  protected
    procedure BuildView; override;
    procedure Change; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FindSize: LongInt; override;
  public
    Info: TxPictInfo;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFMetafile = class(TxRTFPicture)
  private
    MF: THandle;
    procedure DrawPicture(Opt: TDrawOptions); override;
  protected
    procedure BuildView; override;
    procedure Change; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FindSize: LongInt; override;
  public
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFBitmap = class(TxRTFPicture)
  private
    procedure DrawPicture(Opt: TDrawOptions); override;
  protected
    procedure BuildView; override;
    procedure Change; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FindSize: LongInt; override;
  public
    BM: THandle;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFGroup = class(TxRTFBasic)
  private
    function GetCount: LongInt;
    function GetItem(Index: LongInt): TxRTFBasic;
    function GetLastItem: TxRTFBasic;
    procedure SetMinPos(Value: LongInt); override;
    procedure SetLeftMargin(Value: Integer); override;
    procedure SetDrawWidth(Value: Integer); override;

  protected
    procedure BuildView; override;
    procedure Change; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FindSize: LongInt; override;
    function CreateRTFSubclass(Name: string; aClass: TObject): TxRTFBasic;

  public
    Data: TClassList;

    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure ViewChanged; override;
    procedure Clear; override;
    procedure AddData(Value: TxRTFBasic);
    procedure DeleteItem(Index: Integer);
    property Count: LongInt read GetCount;
    property Items[Index: LongInt]: TxRTFBasic read GetItem;
    property LastItem: TxRTFBasic read GetLastItem;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFPara = class(TxRTFGroup)
  private
    function GetLinesCount: LongInt; virtual; abstract;
    function GetHeight: LongInt; virtual;
    procedure SetLeftMargin(Value: Integer); override;
    procedure SetDrawWidth(Value: Integer); override;
    function PageStartHeight(FirstLine: LongInt): LongInt; virtual;
    procedure StartPage(Opt: TDrawOptions); virtual; { supposes that Opt.From
      is first line on page and does all preceding drawings }
  protected
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
  public
    Info: TxParaInfo;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
//    function LineOffset(Line: LongInt): LongInt; virtual; abstract;
    function LineHeight(Line: LongInt): LongInt; virtual;
    function TextBottom(Line: LongInt): LongInt; virtual;
    property LinesCount: LongInt read GetLinesCount;
    property Height: LongInt read GetHeight;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFText = class(TxRTFGroup)
  private
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;

  protected
    procedure BuildView; override;
    procedure AddPict(APict: TxPictInfo);
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function WordEnd(From: LongInt): LongInt;
    function WordWidth(From, Till: LongInt): LongInt;
    function DrawWord(Opt: TDrawOptions; From, Till: LongInt): TDrawResult;
    function OwningItem(Position: LongInt): Integer;

  public
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure Append(s: string; AFnt: TLogFont);
    function AsText: string;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFField = class(TxRTFText)
  private
    HideChanges: Integer;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    procedure RegisterField;
  protected
    procedure Change; override;
    procedure BuildView; override;
    function FindSize: LongInt; override;
    procedure EvaluateField;
  public
    IsDirty: Boolean;
    IsEdited: Boolean;
    IsLocked: Boolean;
    IsFldPriv: Boolean;
    IsFldAlt: Boolean;
    Instruction: PChar;
    FieldResult: PChar;
    IsDataField: Boolean;
    DataField: TxDataFieldRec;
    IsFormField: Boolean;
    FFName: string;
    FFDefText: string;
    FFType: Integer;
    FFTypeTxt: Integer;//}
    Tag: LongInt; { might be used by RTF users }
    iSEQResult: Longint;
    iReportPointer: TObject; { for TxReport personal use!!! }
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure RegisterResult;
    procedure iSetResult(Value: string); { Change is not called }
    procedure ClearResult;
    procedure SetResult(Value: string);
    procedure AppendTextResult(Value: string);
    procedure AppendResult(Value: TxRTFBasic); { element will belong to
      the RTF file structure afterwards! }
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFTextPara = class(TxRTFPara)
  private
    LineInfo: TClassList;
    function iDraw(Opt: TDrawOptions): TDrawResult;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    function GetLinesCount: LongInt; override;
    function GetHeight: LongInt; override;
  protected
    procedure BuildView; override;
    procedure AddPict(APict: TxPictInfo);
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function NextTabStop(Shift: LongInt): LongInt;
    function OwningItem(Position: LongInt): Integer;
    procedure UpdateLineHeight(var Total: LongInt; Current: LongInt);
    procedure FillFullWidth(Y1, Y2: Integer);
  public
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
//    function LineOffset(Line: LongInt): LongInt; override;
    procedure Append(s: string; AFnt: TLogFont);
    function LineHeight(Line: LongInt): LongInt; override;
    function TextBottom(Line: LongInt): LongInt; override;
    function AsText: string;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
    function ParaHasText: Boolean;
  end;

  TxRTFBlock = class(TxRTFPara)
  private
    ForceNewPara: Boolean;
    CellIsAdded: Boolean;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    function GetLinesCount: LongInt; override;
    procedure FlushPara(NewForce: Boolean);
    function GetHeight: LongInt; override;
    function GetLastTextPara: TxRTFTextPara;
    function PageStartHeight(FirstLine: LongInt): LongInt; override;
    procedure StartPage(Opt: TDrawOptions); override;
  protected
    procedure BuildView; override;
    procedure StartTable(Inherite: Boolean);
    procedure StartField;
    procedure CloseField;
    procedure CheckCellIsAdded;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function FirstPara: TxRTFPara; { returns reference to the first para in
      the current block }
    function LastPara: TxRTFPara; { returns reference to the last para in
      the current block }
    function NextParaRef(From: TxRTFPara): TxRTFPara; { finds the next para
      (supposes that From points to the para in the current block) }
    function PrevParaRef(From: TxRTFPara): TxRTFPara; { finds the previous para
      (supposes that From points to the para in the current block) }
    procedure AddFormField(Fld: TxRTFField);
  public
    ReadingTableRow: Boolean;
    FormFields: TList;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
//    function LineOffset(Line: LongInt): LongInt; override;
    procedure AddParagraph(const s: string);
    procedure AddChar(ch: Char); { adds chars to last para }
    procedure FormattingChanging; { while appending - internal }
    procedure StartNewPara;
    procedure ClearPara;
    procedure ClosePara;
    procedure ClosePicture;
    procedure SetDefaults;
    procedure UpdateParaInfo;
    function IsEmpty: Boolean;
    procedure ResetParaInfo;
    procedure ResetFnt;
    procedure ResetPictInfo;
    function LineHeight(Line: LongInt): LongInt; override;
    property LastTextPara: TxRTFtextPara read GetLastTextPara;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
    procedure JoinBlock(From: TxRTFBlock);
    function LastLineOnPage(Line: LongInt): Boolean;
  end;

  TxRTFCell = class(TxRTFBlock)
  private
    function GetLinesCount: LongInt; override;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
  protected
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
  public
    Info: TxCellInfo;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure CopyStructure(ACell: TxRTFCell);
    procedure Assign(From: TxRTFBasic); override;
  end;

  TxRTFTableRow = class(TxRTFPara)
  private
    CurrentCell: LongInt;
    NextIsTableRow: Boolean; { i.e. next para }
    FirstHeaderRow: TxRTFTableRow;
    TopLine, BottomLine: Integer;
    procedure SetLeftMargin(Value: Integer); override;
    procedure SetDrawWidth(Value: Integer); override;
    function GetLinesCount: LongInt; override;
    function DoDraw(Opt: TDrawOptions): TDrawResult; override;
    function GetiHeight: LongInt; 
    function GetHeight: LongInt; override;
    function GetLastTextPara: TxRTFTextPara;
    function PageStartHeight(FirstLine: LongInt): LongInt; override;
    procedure StartPage(Opt: TDrawOptions); override;
  protected
    procedure BuildView; override;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    function CurrentCellItem: TxRTFCell;
  public
    IsHeader: Boolean;
    CellsSpace: LongInt;
    LeftEdge: LongInt;
    constructor CreateChild(AnOwner: TxRTFBasic); override;
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure AddCell;
    procedure AppendParagraph(s: string; AFnt: TLogFont);
    procedure AddParagraph(APara: TxRTFTextPara);
    procedure UpdateParaInfo(Info: TxParaInfo);
    procedure GoNextCell;
    procedure CopyStructure(ATable: TxRTFTableRow);
    function LineHeight(Line: LongInt): LongInt; override;
    procedure Assign(From: TxRTFBasic); override;
    function CreateTextPara: TxRTFTextPara;
  end;

  TxRTFHeaderFooter = class(TxRTFBlock)
  public
    procedure DrawHdrFtr(Opt: TDrawOptions);
  end;

  TReaderState = (rsNoSpecial, rsFontTbl, rsInfo, rsPict,
    rsField, rsFldInst, rsFldRslt, rsDataField, rsFFName, rsFFDefText,
    rsHeader, rsFooter, rsColorTable);

  TxRTFFont = class
  private
  protected
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
    procedure Assign(From: TxRTFFont);
  public
    FontNum: LongInt;
    Family: string[10];
    CharSet: LongInt;
    Name: string;
    Pitch: LongInt;
  end;

  TDestinations = (dsScreen, dsPrinter);

  TxRTFFile = class(TxRTFBlock)
  private
    CanvasPPIX: LongInt;
    CanvasPPIY: LongInt;
    iCanvasHandle: THandle;
    iCanvasFont: THandle;
    CanvasTextMetric: TTextMetric;
    ReaderState: TReaderState;
    Drawing: Boolean; { for debugging purposes }
    CurrentTableFont: TxRTFFont; { when reading font table }
    Loading: Boolean;
    Building: Boolean;
    PageInfo: TClassList;
    FOptions: TxRTFPreviewOptions;
    InFontsStack: Integer;
    LastLoadedTableRow: TxRTFTableRow; { will hold just a reference }
    OriginalOpt: TDrawOptions;
    CurrentColor: TRGBTRIPLE;
    ColorTable: TColorTable;
    ColorsInTable: Integer;
    SEQNumbers: TClassList;
    CurrentPara: string;
    CurrentFont: TLogFont;
    CurrentParaInfo: TxParaInfo;
    CurrentPict: TxPictInfo;
    CurrentField: TxRTFField;
    LastBorder: PBorderType;

    // this handle will be locked while printing and needs unlocking afterwards
    DeviceMode: THandle;

    procedure CheckWord(AWord: TxRTFControlWord; ShouldBe: string);
    procedure SetOptions(Value: TxRTFPreviewOptions); override;
    procedure SetLeftMargin(Value: Integer); override;
    procedure SetDrawWidth(Value: Integer); override;
    procedure BeforePrinting(ADevice, ADriver, APort: PChar;
      ADeviceMode: THandle);
    procedure AfterPrinting;
    procedure SetMinPos(Value: LongInt); override;
    function GetLinesCount: LongInt; override;
    function GiveSEQNumber(AutoName: string): Longint; { used by 'SEQ' fileds}
  protected
    CurrentBlock: TxRTFBlock;
    FontList: TClassList;
    Position: TPoint;
    CurrentDestination: TDestinations;
    TheDate: TDateTime; { date and time to use while printing/drawing
      document( to escape errors such as the time might change between
      printout of different pages) }
    SavedFontHandle: THandle;
    procedure LoadGroupBody(Reader: TxRTFReader;
      const GroupNameWord: TxRTFControlWord);
    procedure LoadGroup(Reader: TxRTFReader);
    procedure LoadDestination(Reader: TxRTFReader);
    procedure LoadPlainText(Reader: TxRTFReader);
    procedure LoadRTFDocument(Reader: TxRTFReader);
    procedure NewControlWord(Reader: TxRTFReader; AWord: TxRTFControlWord);
    procedure NewControlSymbol(AChar: Char);
    function FindFont(Nom: LongInt): TxRTFFont;
    function FindFontNum(Name: string): Integer;
    function FindColorIndex(aColor: TRGBTRIPLE): Integer;
    procedure Change; override;
    function FindSize: LongInt; override;
    procedure SetDefaults;
    procedure BuildView; override;
    procedure NextParaLoaded; virtual; { just to report child classes
      (if you'll write a one) that paragraph loading is over }
    procedure PrintPageBody(Page: LongInt); { prints page without initializing
      printer - use PrintPage to print a page }
    procedure PrintPageBody2(Page: LongInt);
    procedure SetCanvasFont; override;
    procedure RestoreCanvasFont; override;

    // finds pafge which holds the gived position
    function FindHoldingPage(Shift: Integer): Integer;

    // procedures to draw RTF
    procedure DrawPageBackground(PageRect: TRect);
    procedure DrawOutside(const DrawRect, PageRect: TRect);
    procedure DrawPageBeginning(const Opt: TDrawOptions; PageRect: TRect;
      PageIndex: Integer);
    procedure DrawPageFinishing(const Opt: TDrawOptions; PageRect: TRect;
      DrawPageSeparator: Boolean);
    function DrawPageBody(Opt: TDrawOptions; PageIndex: Integer): TDrawResult;
    procedure DrawTextBoundaries(Opt: TDrawOptions);
    procedure DrawContinuousPages(Opt: TDrawOptions);
    procedure DrawSinglePage(Opt: TDrawOptions);
    procedure DrawMultiplePages(Opt: TDrawOptions);
  public
    ProhibitDrawing: Boolean;
    Header: TxRTFFileHeader;
    DocFormat: TxRTFDocFormat;
    PageWidth: LongInt;
    PageFullWidth: LongInt;
    PageHeight: LongInt;
    PageFullHeight: LongInt;
    PageHeader: TxRTFHeaderFooter;
    PageFooter: TxRTFHeaderFooter;
    PageInPrint: Integer; { the page which is currently printing or drawing }
    FontInUse: TLogFont; { the font which is currently using }
    FontHInUse: THandle; {   and it's handle }
    Scale: Double;
    MemoryUsed: LongInt;
    Objects: LongInt;
    constructor Create; virtual; { do not override but make overridable }
    destructor Destroy; override;
    procedure WriteRTF(Writer: TxRTFWriter); override;
    procedure WriteRTFHeader(Writer: TxRTFWriter);
    function LoadRTF(FileName: string): Boolean; { false if not loaded due to termination by user }
    function LoadRTFFromStream(AnStream: TStream): Boolean;
    function SaveRTF(FileName: string): Boolean; { false if not saved due to termination by user }
    function DrawRTF(Opt: TDrawOptions; Continuous: Boolean): TDrawResult;
    function CountPages: Integer;
    procedure RefreshMargins;
    procedure RegisterCanvas(ACanvas: TCanvas);
    procedure RegisterCanvasHandle(AHandle: THandle);
    procedure ProceedHandleChange;
    procedure Clear; override;
    procedure Assign(From: TxRTFBasic); override;
    procedure AssignFormat(From: TxRTFBasic);
    procedure CopyHeaderFooter(From: TxRTFFile);
    procedure PrintPage(Page: LongInt);
    function PrintRTF: Boolean;
    function PrintRTF2(const ShowDlg: Boolean = True): Boolean;
    procedure ReadData(Reader: TReader); override;
    procedure WriteData(Writer: TWriter); override;
    procedure ViewChanged; override;
    procedure Statistics; { show RTF file statistics }
  end;

type
  ExRTFFile = class(ExRTF);
  ExRTFEdit = class(ExRTF);

const
  { next const is for experts only. When set, it will force assign command
    to copy FormFields to simple text. If you change this value, be sure to
    restore its original value!!! }
  xRTFCopyFormFields: Boolean = true;

implementation

uses
  xRTFPrnF, xFileList, xPrintF;

const
  lblI: Longint = 0;

{ =========== TxRTFBasic =========== }

constructor TxRTFBasic.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited Create;
  Owner := AnOwner;
  FMinPos := 0;

  { try to encapsulate owners parameters }
  if AnOwner <> nil then
   begin
     RTFFile := Owner.RTFFile;
     Fnt := AnOwner.Fnt;
     FLeftMargin := AnOwner.FLeftMargin;
     FDrawWidth := AnOwner.FDrawWidth;
   end
  else
   begin
     RTFFile := nil;
     SetDefaultFont(Fnt);
   end;

  State := [];

  iSize := 0;

  if RTFFile <> nil then
   begin
     inc(RTFFile.MemoryUsed, self.InstanceSize);
     inc(RTFFile.Objects);
   end;
end;

destructor TxRTFBasic.Destroy;
begin
  if RTFFile <> nil then
   begin
     dec(RTFFile.MemoryUsed, self.InstanceSize);
     dec(RTFFile.Objects);
   end;
  inherited Destroy;
end;

function TxRTFBasic.GetSize: LongInt;
begin
  if bsSizeValid in State then
    Result := iSize
  else
   begin
     iSize := FindSize;
     Result := iSize;
     State := State + [bsSizeValid];
   end;
end;

function TxRTFBasic.FindSize: LongInt;
begin
  Result := 0;
end;

function TxRTFBasic.GetPosition: TPoint;
begin
  Result := RTFFile.Position;
end;

procedure TxRTFBasic.SetPosition(Value: TPoint);
begin
  RTFFile.Position := Value;
end;

procedure TxRTFBasic.MoveX(NewX: LongInt);
begin
  RTFFile.Position.X := NewX;
end;

procedure TxRTFBasic.MoveY(NewY: LongInt);
begin
  RTFFile.Position.Y := NewY;
end;

function TxRTFBasic.GetWidth: LongInt;
begin
  CheckIsBuilt;
  Result := iWidth;
end;

procedure TxRTFBasic.NewLine(Opt: TDrawOptions);
begin
  case Opt.Cmd of
    dcDrawLine, dcDrawWhole:
      Position := Point(0, Position.Y + Opt.LineHeight);
    else
      Position := Point(0, Position.Y + RTFFile.CanvasTextMetric.tmHeight);
  end;
end;

procedure TxRTFBasic.SetMinPos(Value: LongInt);
begin
  FMinPos := Value;
end;

function TxRTFBasic.GetMaxPos: LongInt;
begin
  Result := MinPos + Size - 1;
end;

function TxRTFBasic.FontStyle(LogFont: TLogFont): TFontStyles;
begin
  Result := [];
  if LogFont.lfItalic <> 0 then
    Result := Result + [fsItalic];
  if LogFont.lfUnderline <> 0 then
    Result := Result + [fsUnderline];
  if LogFont.lfStrikeOut <> 0 then
    Result := Result + [fsStrikeOut];
  if LogFont.lfWeight <> FW_NORMAL then
    Result := Result + [fsBold];
end;

procedure TxRTFBasic.SetCanvasFont;
var
  aFont: THandle;
begin
  if not(BOOL(RTFFile.FontWasChanged)) then
   begin
     RestoreRTFFont := true;
     RTFFile.SetCanvasFont;
   end
  else
    RestoreRTFFont := false;

  FontWasChanged := 0;


  if (self is TxRTFChars) then
   begin
    if (not(CompareFonts(Fnt, RTFFile.FontInUse)) ) then
      begin
        aFont := SetFontHandle(Fnt);
        if not DeleteObject(RTFFile.FontHInUse) then
          MessageDlg('Resources were lost (basic.setcanvasfont)',
            mtError, [mbOk], 0);
        RTFFile.FontHInUse := aFont;
        RTFFile.FontInUse := Fnt;
        FontWasChanged := 1;
      end
   end;
end;

procedure TxRTFBasic.RestoreCanvasFont;
begin
  if RestoreRTFFont then
     RTFFile.RestoreCanvasFont;
end;

procedure TxRTFBasic.ViewChanged;
begin
  State := State - [bsViewValid];
end;

function TxRTFBasic.Draw(Opt: TDrawOptions): TDrawResult;
begin
  CheckIsBuilt;
  SetCanvasFont;
  try
    Result := DoDraw(Opt);
  finally
    RestoreCanvasFont;
  end;
end;

procedure TxRTFBasic.BuildView;
begin
  RTFProgress.Update(MinPos, '');

  iWidth := 0;

  State := State + [bsViewValid];

  UpdateSize;
end;

procedure TxRTFBasic.UpdateSize;
begin
  iSize := FindSize;
  State := State + [bsSizeValid];
end;

procedure TxRTFBasic.CheckIsBuilt;
begin
  if not(bsViewValid in State) then
   begin
     State := State + [bsBuilding];
     try
       SetCanvasFont;
       try
         {if GetTextMetrics(CanvasHandle, TM) then}
           BuildView;
       finally
         RestoreCanvasFont;
       end;
     finally
       State := State - [bsBuilding];
     end;
   end;
end;

procedure TxRTFBasic.Change;
begin
  State := State - [bsViewValid, bsSizeValid];
  if (bsSizeValid in Owner.State) or
     (bsViewValid in Owner.State) then
    Owner.Change;
end;

procedure TxRTFBasic.Clear;
begin
  { nothing to clear }
end;

procedure TxRTFBasic.SetLeftMargin(Value: Integer);
begin
  FLeftmargin := Value;
end;

procedure TxRTFBasic.SetDrawWidth(Value: Integer);
begin
  FDrawWidth := Value;
end;

function TxRTFBasic.TwipsToPixelsX(Twips: LongInt): LongInt;
begin
  Result := Round(MulDiv(Twips, RTFFile.CanvasPPIX, 1440) * RTFFile.Scale);
end;

function TxRTFBasic.TwipsToPixelsY(Twips: LongInt): LongInt;
begin
  Result := Round(MulDiv(Twips, RTFFile.CanvasPPIY, 1440) * RTFFile.Scale);
end;

procedure TxRTFBasic.ReadData(Reader: TReader);
begin
  FMinPos := Reader.ReadInteger;
{  Reader.ReadState;!}
  iWidth := Reader.ReadInteger;
  iSize := Reader.ReadInteger;
  FLeftMargin := Reader.ReadInteger;
  FDrawWidth := Reader.ReadInteger;
  Reader.ReadListBegin;
  Reader.Read(Fnt, SizeOf(Fnt));
  Reader.ReadListEnd;
end;

procedure TxRTFBasic.WriteData(Writer: TWriter);
begin
  Writer.WriteInteger(FMinPos);
  { write state }
  Writer.WriteInteger(iWidth);
  Writer.WriteInteger(iSize);
  Writer.WriteInteger(FLeftMargin);
  Writer.WriteInteger(FDrawWidth);
  Writer.WriteListBegin;
  Writer.Write(Fnt, SizeOf(Fnt));
  Writer.WriteListEnd;
end;

procedure TxRTFBasic.Assign(From: TxRTFBasic);
begin
  Fnt := From.Fnt;
  iSize := From.iSize;
  FLeftMargin := From.FLeftMargin;
  FDrawWidth := From.FDrawWidth;
  State := From.State;
  Change;
end;

procedure TxRTFBasic.SetDefaultResult(var r: TDrawResult);
begin
  with r do
   begin
     NextLineStart := -1;
     LineHeight := 0;
     TextBottom := 0;
   end;
end;

function TxRTFBasic.GetOptions: TxRTFPreviewOptions;
begin
  Result := RTFFile.FOptions;
end;

procedure TxRTFBasic.SetOptions(Value: TxRTFPreviewOptions);
begin
  RTFFile.FOptions := Value;
end;

function TxRTFBasic.CanvasHandle: THandle;
begin
  Result := RTFFile.iCanvasHandle;
end;

function TxRTFBasic.SetFontHandle(var AFont: TLogFont): THandle;
var
  RealH: LongInt;
begin
  RealH := AFont.lfHeight;
  AFont.lfHeight := TwipsToPixelsY(AFont.lfHeight);
  try
    Result := CreateFontIndirect(AFont);
  finally
    AFont.lfHeight := RealH;
  end;
  SelectObject(CanvasHandle, Result);
end;

function TxRTFBasic.OwnerBlock: TxRTFBlock;
var
  Swap: TxRTFBasic;
begin
  if self is TxRTFFile then
   begin
     Result := nil;
     exit;
   end;
  Swap := Owner;
  while not(Swap = nil) and not(Swap is TxRTFBlock) do Swap := Swap.Owner;
  Result := Swap as TxRTFBlock;
end;

function TxRTFBasic.GetLeftMargin: Integer;
begin
  Result := FLeftMargin;
end;

procedure TxRTFBasic.WriteRTF(Writer: TxRTFWriter); 
begin
end;

function TxRTFBasic.ScaleMe(Value: Integer): Integer;
begin
  Result := round(Value * RTFFile.Scale);
end;

{ ========= TxRTFGroup ========= }

constructor TxRTFGroup.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  Data := TClassList.Create;
end;

destructor TxRTFGroup.Destroy;
begin
  Data.Free;
  inherited Destroy;
end;

function TxRTFGroup.GetCount: LongInt;
begin
  Result := Data.Count;
end;

function TxRTFGroup.GetItem(Index: LongInt): TxRTFBasic;
begin
  Result := TxRTFBasic(Data[Index]);
end;

function TxRTFGroup.GetLastItem: TxRTFBasic;
begin
  Result := TxRTFBasic(Data.Last);
end;

procedure TxRTFGroup.SetMinPos(Value: LongInt);
var
  i: LongInt;
begin
  inherited SetMinPos(Value);
  for i := 0 to Count - 1 do
   begin
     Items[i].MinPos := Value;
     Value := Items[i].MaxPos + 1;
   end;
end;

procedure TxRTFGroup.ViewChanged;
var
  i: LongInt;
begin
  State := State - [bsViewValid];
  for i := 0 to Count - 1 do
    Items[i].ViewChanged;
end;

procedure TxRTFGroup.BuildView;
var
  i: LongInt;
  OldPos: TPoint;
begin
  OldPos := Position;
  State := State + [bsViewValid];
  for i := 0 to Count - 1 do
   begin
     Items[i].CheckIsBuilt;
     if (i < Count - 1) and
        (Items[i + 1].MinPos <> Items[i].MaxPos + 1)
     then
       Items[i + 1].MinPos := Items[i].MaxPos + 1;
   end;
  UpdateSize;
  Position := OldPos;
end;

procedure TxRTFGroup.Change;
begin
  inherited Change;
end;

function TxRTFGroup.FindSize: LongInt;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + Items[i].Size;
end;

procedure TxRTFGroup.Clear;
begin
  Data.Clear;
  Change;
end;

procedure TxRTFGroup.SetLeftMargin(Value: Integer);
var
  i: LongInt;
begin
  FLeftMargin := Value;
  for i := 0 to Count - 1 do
    Items[i].SetLeftMargin(Value);
end;

procedure TxRTFGroup.SetDrawWidth(Value: Integer);
var
  i: LongInt;
begin
  FDrawWidth := Value;
  for i := 0 to Count - 1 do
    Items[i].SetDrawWidth(Value);
end;

{ this routine containes many legal warnings due to construction of objects
  with abstract methods}
{$WARNINGS OFF}
function TxRTFGroup.CreateRTFSubclass(Name: string; aClass: TObject): TxRTFBasic;
begin
  Name := LowerCase(Name);
  if Name = 'txrtfbasic' then
   Result := TxRTFBasic.CreateChild(self)

  else if Name = 'txrtfchars' then
   Result := TxRTFChars.CreateChild(self)

  else if Name = 'txrtfgroup' then
   Result := TxRTFGroup.CreateChild(self)

  else if Name = 'txrtfpicture' then
   Result := TxRTFPicture.CreateChild(self)

  else if Name = 'txrtfmetafile' then
   Result := TxRTFMetafile.CreateChild(self)

  else if Name = 'txrtfbitmap' then
   Result := TxRTFBitmap.CreateChild(self)

  else if Name = 'txrtfpara' then
   Result := TxRTFPara.CreateChild(self)

  else if Name = 'txrtftext' then
   Result := TxRTFText.CreateChild(self)

  else if Name = 'txrtftextpara' then
   Result := TxRTFTextPara.CreateChild(self)

  else if Name = 'txrtfcell' then
   Result := TxRTFCell.CreateChild(self)

  else if Name = 'txrtftablerow' then
   Result := TxRTFTableRow.CreateChild(self)

  else if Name = 'txrtfblock' then
   Result := TxRTFBlock.CreateChild(self)

  else if Name = 'txrtftabchar' then
   Result := TxRTFTabChar.CreateChild(self)

  else if Name = 'txrtffield' then
   begin
     if (aClass <> nil) and (TxRTFField(aClass).IsDataField) and
        not(xRTFCopyFormFields) then
       Result := TxRTFText.CreateChild(self)
     else
       Result := TxRTFField.CreateChild(self);
   end

  else
    raise ExRTF.Create('Unknown class request. Class name: ' + Name);
end;
{$WARNINGS ON}

procedure TxRTFGroup.ReadData(Reader: TReader);
var
  AnRTF: TxRTFBasic;
  NextClass: string;
begin
  inherited ReadData(Reader);
  Reader.ReadListBegin;
  while not Reader.EndOfList do
   begin
     NextClass := Reader.ReadString;
     AnRTF := CreateRTFSubclass(NextClass, nil);
     Data.Add(AnRTF);
     AnRTF.ReadData(Reader);
   end;
  Reader.ReadListEnd;
end;

procedure TxRTFGroup.WriteData(Writer: TWriter);
var
  i: integer;
  NextClass: string;
begin
  inherited WriteData(Writer);
  Writer.WriteListBegin;
  for i := 0 to Count - 1 do
   begin
     NextClass := Items[i].ClassName;
     Writer.WriteString(NextClass);
     Items[i].WriteData(Writer);
   end;
  Writer.WriteListEnd;
end;

procedure TxRTFGroup.AddData(Value: TxRTFBasic);
begin
  Data.Add(Value);
  Change;
end;

procedure TxRTFGroup.DeleteItem(Index: Integer);
begin
  Data.Delete(Index);
  Change;
end;

procedure TxRTFGroup.Assign(From: TxRTFBasic);
var
  i: Integer;
  AnRTF: TxRTFBasic;
begin
  inherited Assign(From);
  Data.Clear;
  for i := 0 to TxRTFGroup(From).Data.Count - 1 do
   begin
     AnRTF := CreateRTFSubclass(TxRTFGroup(From).Items[i].ClassName,
       TxRTFGroup(From).Items[i]);
     Data.Add(AnRTF);
     AnRTF.Assign(TxRTFBasic(TxRTFGroup(From).Data[i]));
   end;
  Change;
end;

procedure TxRTFGroup.WriteRTF(Writer: TxRTFWriter);
begin
  Writer.xWriteGroup(self);
end;

{ ======== TxRTFChars ========== }

constructor TxRTFChars.CreateChild(AnOwner: TxRTFBasic);
var
  TheObj: TxRTFBasic;
  s: string;
begin
  inherited CreateChild(AnOwner);
  Data := StrAlloc(10);
  StrCopy(Data, '');
  OwningTextPara := nil;
  TheObj := self;
  repeat
    TheObj := TheObj.Owner;
    s := TheObj.ClassName;
    s := TheObj.Owner.ClassName;
    if TheObj is TxRTFTextPara then
      OwningTextPara := TheObj as TxRTFTextPara;
  until (TheObj = nil) or (TheObj is TxRTFFile) or (TheObj is TxRTFTextPara);
end;

destructor TxRTFChars.Destroy;
begin
  StrDispose(Data);
  inherited Destroy;
end;

function TxRTFChars.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  Len: LongInt;
  DataLength: LongInt;
  Till: LongInt;
  DrawData: PChar;
  ARect: TRect;
  TM: TTEXTMETRIC;
  OldMode: Integer;
  NotTransparent: Boolean;
begin
  SetDefaultResult(Result);
  GetTextMetrics(CanvasHandle, TM);
  if Opt.From > MaxPos then exit;
  if Opt.From > MinPos then
    DrawData := Data + Opt.From - MinPos
  else
    DrawData := Data;
  DataLength := Integer(StrLen(DrawData)) - MaxInt(0, MaxPos - Opt.Till);
  if DataLength < 0 then exit;
  Len := TxtWidth(DrawData, DataLength);

  // check if there's enough place to print the whole word on this line
  if Position.X + Len <= ScaleMe(FDrawWidth) then
    begin // enough place for the word
      // 1. find the line height
      if OwningTextPara <> nil then
        OwningTextPara.UpdateLineHeight(Result.LineHeight, TM.tmHeight)
      else
        Result.LineHeight := TM.tmHeight;

      // 2. find the bottom position of the chars
      Result.TextBottom := TM.tmAscent;

      // 3. draw the word
      if Opt.Cmd in [dcDrawWhole, dcDrawLine] then
       begin
        ARect := Rect(Position.X + ScaleMe(FLeftMargin) - Opt.HShift,
          Position.Y + Opt.TextBottom - Result.TextBottom,
          Position.X + ScaleMe(FLeftMargin) - Opt.HShift + Len,
          Position.Y + Opt.LineHeight + Opt.TextBottom - Result.TextBottom);

        NotTransparent := GetBkColor(CanvasHandle) = GetTextColor(CanvasHandle);
        if not NotTransparent then
          OldMode := SetBkMode(CanvasHandle, TRANSPARENT)
        else
          OldMode := 0;

        ExtTextOut(CanvasHandle,
          Position.X + ScaleMe(FLeftMargin) - Opt.HShift,
          Position.Y + Opt.TextBottom - Result.TextBottom,
          ETO_CLIPPED + ETO_OPAQUE * Integer(NotTransparent), @ARect, DrawData, DataLength, nil);

        if not NotTransparent then SetBkMode(CanvasHandle, OldMode);
       end;
      MoveX(Position.X + Len);
    end

  else // there's not enough place on the line to prinf the word -> trying to split it
    begin
      repeat
        Till := DataLength;
        while (Till > 0) and
              (Position.X + TxtWidth(DrawData, Till) > ScaleMe(FDrawWidth)) do
          dec(Till);
        Till := MaxInt(1, Till);
        if OwningTextPara <> nil then
          OwningTextPara.UpdateLineHeight(Result.LineHeight, TM.tmHeight)
        else
          Result.LineHeight := TM.tmHeight;
        Result.TextBottom := TM.tmAscent;
        if Opt.Cmd in [dcDrawWhole, dcDrawLine] then
         begin
          ARect := Rect(Position.X + ScaleMe(FLeftMargin) - Opt.HShift,
            Position.Y + Opt.TextBottom - Result.TextBottom,
            Position.X + ScaleMe(FLeftMargin) - Opt.HShift + TxtWidth(DrawData, Till),
            Position.Y + Opt.LineHeight + Opt.TextBottom - Result.TextBottom);

          NotTransparent := GetBkColor(CanvasHandle) = GetTextColor(CanvasHandle);
          if not NotTransparent then
            OldMode := SetBkMode(CanvasHandle, TRANSPARENT)
          else
            OldMode := 0;

          ExtTextOut(CanvasHandle, Position.X + ScaleMe(FLeftMargin) - Opt.HShift,
            Position.Y + Opt.TextBottom - Result.TextBottom,
            ETO_CLIPPED + ETO_OPAQUE  * Integer(NotTransparent), @ARect, DrawData, Till, nil);

          if not NotTransparent then SetBkMode(CanvasHandle, OldMode);
          end;
        if Till < DataLength then
          begin
            Result.LineWidth := Position.X + TxtWidth(DrawData, Till);
            NewLine(Opt);
            if Opt.Cmd in [dcDrawLine, dcFindLineHeight] then
             begin
               Result.NextLineStart := MaxInt(Opt.From, MinPos) + Till;
               exit;
             end;
            DrawData := DrawData + Till;
          end
        else
          MoveX(Position.X + TxtWidth(DrawData, Till));
        dec(DataLength, Till);
      until (DataLength = 0);
    end;
  Result.LineWidth := Position.X;
end;

function TxRTFChars.TxtWidth(s: PChar; Count: Integer): LongInt;
var
  TextExtent: TSize;
begin
  if GetTextExtentPoint(CanvasHandle, s, Count, TextExtent) then
    Result := TextExtent.cX
  else
    Result := 0;
end;

procedure TxRTFChars.BuildView;
begin
  inherited BuildView;
  iWidth := TxtWidth(Data, Size);
end;

function TxRTFChars.BlockWidth(From, Till: LongInt): LongInt;
begin
  CheckIsBuilt;
  SetCanvasFont;
  try
    Result := TxtWidth(Data + (From - MinPos), Till - From + 1);
  finally
    RestoreCanvasFont;
  end;
end;

procedure TxRTFChars.AddData(Value: string);
begin
  if StrBufSize(Data) < StrLen(Data) + Cardinal(Length(Value)) + 1 then
    Resize(StrLen(Data) + Cardinal(Length(Value)) + 10);
  StrPCopy(StrEnd(Data), Value);
  Change;
end;

procedure TxRTFChars.iSetData(Value: string);
begin
  StrDispose(Data);
  Data := StrAlloc( Length(Value) + 1 );
  StrPCopy(Data, Value);
end;

procedure TxRTFChars.SetData(Value: string);
begin
  iSetData(Value);
  Change;
end;

procedure TxRTFChars.Change;
begin
  inherited Change;
end;

function TxRTFChars.FindSize: LongInt;
begin
  Result := StrLen(Data);
end;

procedure TxRTFChars.Clear;
begin
  SetData('');
  Change;
end;

procedure TxRTFChars.ReadData(Reader: TReader);
begin
{  Data := Reader.ReadString;}
  inherited ReadData(Reader);
end;

procedure TxRTFChars.WriteData(Writer: TWriter);
begin
{  Writer.WriteString(Data);}
  inherited WriteData(Writer);
end;

procedure TxRTFChars.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  StrDispose(Data);
  Data := StrAlloc(StrLen(TxRTFChars(From).Data) + 1);
  StrCopy(Data, TxRTFChars(From).Data);
  Change;
end;

procedure TxRTFChars.Resize(NewSize: Word);
var
  OldData: PChar;
begin
  OldData := Data;
  Data := StrLCopy(StrAlloc(NewSize), Data, NewSize);
  StrDispose(OldData);
end;

procedure TxRTFChars.WriteRTF(Writer: TxRTFWriter);
begin
  Writer.StartGroup;
  Writer.WriteLongWord('f', RTFFile.FindFontNum(StrPas(Fnt.lfFaceName)));
  Writer.WriteLongWord('fs', Abs(Fnt.lfHeight) div 10);
  Writer.WriteLongWord('ul', Fnt.lfUnderline);
  if Fnt.lfWeight <> FW_NORMAL then
    Writer.WriteShortWord('b');
  Writer.WritePChar(Data);
  Writer.EndGroup;
end;

{ ======== TxRTFTabChar ========== }
constructor TxRTFTabChar.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  iSize := 1;
  State := State + [bsSizeValid];
end;

destructor TxRTFTabChar.Destroy;
begin
  inherited Destroy;
end;

function TxRTFTabChar.DoDraw(Opt: TDrawOptions): TDrawresult;
var
  NextPos: Integer;
begin
  SetDefaultResult(Result);
  NextPos := TxRTFTextPara(Owner.Owner).NextTabStop(Position.X);
  if NextPos > ScaleMe(FDrawWidth) then
   begin
     Result.LineWidth := Position.X;
     NewLine(Opt);
     Result.NextLineStart := MaxPos + 1;
   end
  else
    MoveX(NextPos);
end;

procedure TxRTFTabChar.Change;
begin
  inherited Change;
end;

function TxRTFTabChar.FindSize: LongInt;
begin
  Result := 1;
end;

function TxRTFTabChar.GetWidth: LongInt;
begin
  Result := 0;
end;

procedure TxRTFTabChar.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
end;

procedure TxRTFTabChar.WriteRTF(Writer: TxRTFWriter);
begin
  Writer.WriteShortWord('tab');
end;

{ ======== TxRTFPicture ========== }

constructor TxRTFPicture.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  Info.DataHandle := 0;
end;

destructor TxRTFPicture.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TxRTFPicture.PicDrawWidth: Integer;
begin
  Result := TwipsToPixelsX(MulDiv(Info.DesiredWidth, Info.ScaleX, 100));
  Result := MinInt(Result, ScaleMe(FDrawWidth));
end;

function TxRTFPicture.PicDrawHeight: Integer;
begin
  Result := LongMul(TwipsToPixelsY(Info.Desiredheight), Info.ScaleY) div 100;
end;

function TxRTFPicture.DoDraw(Opt: TDrawOptions): TDrawResult;
begin
  Result.NextLineStart := -1;
  Result.LineHeight := PicDrawHeight;
  Result.TextBottom := Result.LineHeight;
  case Opt.Cmd of
    dcDrawLine, dcDrawWhole: DrawPicture(Opt);
  end;
  MoveX(Position.X + PicDrawWidth);
  if Position.X >= ScaleMe(FDrawWidth) then
   begin
     Result.LineWidth := Position.X;
     NewLine(Opt);
     Result.NextlineStart := MaxPos + 1;
   end;
end;

procedure TxRTFPicture.BuildView;
begin
  iWidth := PicDrawWidth;
  inherited BuildView;
end;

procedure TxRTFPicture.Change;
begin
  inherited Change;
end;

function TxRTFPicture.FindSize: LongInt;
begin
  Result := 1;
end;

procedure TxRTFPicture.Clear;
begin
  if Info.DataHandle <> 0 then
   begin
     GlobalFree(Info.DataHandle);
     Info.DataHandle := 0;
   end;
end;

procedure TxRTFPicture.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
end;

procedure TxRTFPicture.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
end;

procedure TxRTFPicture.Assign(From: TxRTFBasic);
begin
  Clear;
  inherited Assign(From);
  Info := TxRTFPicture(From).Info;
  Info.DataPointer := nil;
  Info.DataHandle := 0; { data should be copied, but not the pointer }
  if (TxRTFPicture(From).Info.DataHandle <> 0) then
    Info.DataHandle := GlobalDuplicate(TxRTFPicture(From).Info.DataHandle);
  Change;
end;

{ ======== TxRTFMetafile ========== }

constructor TxRTFMetafile.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  MF := 0;
end;

destructor TxRTFMetafile.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TxRTFMetafile.DrawPicture(Opt: TDrawOptions);
var
  SavedDC: Integer;
  DC: HDC;
  ViewOrg: TPoint;
begin
  DC := CanvasHandle;
  SavedDC := SaveDC(DC);
  SetMapMode(DC, MM_ANISOTROPIC);
  SetWindowExtEx(DC, PicDrawWidth, PicDrawHeight, nil);
  SetViewportExtEx(DC, PicDrawWidth, PicDrawHeight, nil);
  GetViewPortOrgEx(DC, ViewOrg);
  SetViewportOrgEx(DC, ViewOrg.X + ScaleMe(FLeftMargin) + Position.X  - Opt.HShift,
    ViewOrg.Y + Position.Y + Opt.TextBottom - PicDrawHeight, nil);
  PlayMetafile(DC, MF);
  RestoreDC(DC, SavedDC);
end;

procedure TxRTFMetafile.BuildView;
begin
  Info.DataPointer := GlobalLock(Info.DataHandle);
  try
    if (MF = 0) and (Info.DataHandle <> 0) then
     begin
       MF := SetMetafileBitsEx(Info.DataRead, PChar(Info.DataPointer));
     end;
  finally
    GlobalUnlock(Info.DataHandle);
  end;

  inherited BuildView;
end;

procedure TxRTFMetafile.Change;
begin
  inherited Change;
end;

function TxRTFMetafile.FindSize: LongInt;
begin
  Result := 1;
end;

procedure TxRTFMetafile.Clear;
begin
  if MF <> 0 then
   begin
     DeleteMetafile(MF);
     MF := 0;
   end;
  inherited Clear;
end;

procedure TxRTFMetafile.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
end;

procedure TxRTFMetafile.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
end;

procedure TxRTFMetafile.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  MF := 0;
{. copies data if it storied in metafile format only
  if (Info.DataHandle = 0) and (TxRTFMetafile(From).MF <> 0) then
    Info.DataHandle := GlobalDuplicate(GetMetafileBitsEx(TxRTFMetafile(From).MF));}
  Change;
end;

{ ======== TxRTFBitmap ========== }

constructor TxRTFBitmap.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  BM := 0;
end;

destructor TxRTFBitmap.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TxRTFBitmap.DrawPicture(Opt: TDrawOptions);
var
  ADC: HDC;
  OldBitmap: THandle;
begin
  ADC := CreateCompatibleDC(CanvasHandle);
  OldBitmap := SelectObject(ADC, BM);
  try
    StretchBlt(CanvasHandle, ScaleMe(FLeftMargin) + Position.X  - Opt.HShift,
      Position.Y, PicDrawWidth, PicDrawHeight, ADC, 0, 0, Info.PicWidth,
      Info.PicHeight, SRCCOPY);
  finally
    SelectObject(ADC, OldBitmap);
    DeleteDC(ADC);
  end;
  {DC := CanvasHandle;
  SavedDC := SaveDC(DC);
  SetMapMode(DC, MM_ANISOTROPIC);
  SetWindowExtEx(DC, PicDrawWidth, PicDrawHeight, nil);
  SetViewportExtEx(DC, PicDrawWidth, PicDrawHeight, nil);
  GetViewPortOrgEx(DC, @ViewOrg);
  SetViewportOrgEx(DC, ViewOrg.X + ScaleMe(FLeftMargin) + Position.X  - Opt.HShift,
    ViewOrg.Y + Position.Y, nil);
  PlayResult := PlayBitmap(DC, MF);
  RestoreDC(DC, SavedDC);}
end;

procedure TxRTFBitmap.BuildView;
begin
{  if (BM = 0) and (Info.DataHandle <> 0) then
   begin
     BM := CreateBitmap(Info.PicWidth, Info.PicHeight, );
   end;}
  {if (BM <> 0) and (ADC = 0) then
   begin
   end;}
  inherited BuildView;
end;

procedure TxRTFBitmap.Change;
begin
  inherited Change;
end;

function TxRTFBitmap.FindSize: LongInt;
begin
  Result := 1;
end;

procedure TxRTFBitmap.Clear;
begin
  if BM <> 0 then
   begin
     DeleteObject(BM);
     BM := 0;
   end;
  inherited Clear;
end;

procedure TxRTFBitmap.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
end;

procedure TxRTFBitmap.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
end;

procedure TxRTFBitmap.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  BM := 0;
  if TxRTFBitmap(From).BM <> 0 then
    BM := DuplicateBitmap(TxRTFBitmap(From).BM);
  Change;
end;

{ ======== TxRTFField ========== }

constructor TxRTFField.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  IsDirty := false;
  IsEdited := false;
  IsLocked := false;
  IsFldPriv := false;
  IsFldAlt := false;
  iSEQResult := -1; { i.e. undefined }

  Instruction := StrAlloc(10);
  StrPCopy(Instruction, '');

  FieldResult := StrAlloc(10);
  StrPCopy(FieldResult, '');

  IsDataField := false;
  DataField.Name := '';
  DataField.DefaultText := '';

  IsFormField := false;
  FFName := '';
  FFDefText := '';
  FFType := 0;
  FFTypeTxt := 0;

  HideChanges := 0;

  iReportPointer := nil;
end;

destructor TxRTFField.Destroy;
begin
  { HERE REFERENCE TO SELF FROM BLOCK FIELDS LIST SHOULD BE DELETED }
  {  OwnerBlock.FormFields.Remove(self);}
  StrDispose(Instruction);
  StrDispose(FieldResult);
  RTFFile.FormFields.Remove(self);
  inherited destroy;
end;

function TxRTFField.DoDraw(Opt: TDrawOptions): TDrawResult;
begin
  Result := inherited DoDraw(Opt);
end;

procedure TxRTFField.RegisterResult;
var
  Swap: array[0..100] of char;
  i: Cardinal;
begin
  Clear;
  i := 0;
  while i < StrLen(FieldResult) do
   begin
     StrLCopy(Swap, FieldResult + i, 100);
     Append(StrPas(Swap), Fnt);
     inc(i, 100);
   end;
  SetMinPos(MinPos); { refresh it }
end;

procedure TxRTFField.iSetResult(Value: string);
begin
  inc(HideChanges);
  try
    SetResult(Value);
  finally
    dec(HideChanges);
  end;
end;

procedure TxRTFField.SetResult(Value: string);
begin
  StrDispose(FieldResult);
  FieldResult := StrAlloc( Length(Value) + 1 );
  StrPCopy(FieldResult, Value);
  RegisterResult;
end;

procedure TxRTFField.AppendTextResult(Value: string);
begin
  FieldResult := StrAdd(FieldResult, Value);
  RegisterResult;
end;

procedure TxRTFField.ClearResult;
begin
  StrDispose(FieldResult);
  FieldResult := StrAlloc(10);
  StrPCopy(FieldResult, '');
  RegisterResult;
end;

procedure TxRTFField.EvaluateField;
var
  s, s1: string;
  Ps1: PChar;
  FontName: string;
begin
  s := Trim(UpperCase(FirstWord(StrPas(Instruction))));
  if s = 'DATE' then
    iSetResult(DateToStr(RTFFile.TheDate))
  else if s = 'TIME' then
    iSetResult(TimeToStr(RTFFile.TheDate))
  else if s = 'PAGE' then
    iSetResult(IntToStr(RTFFile.PageInPrint))
  else if s = 'NUMPAGES' then
    iSetResult(IntToStr(RTFFile.PageInfo.Count))
  else if (s = 'SEQ') and (iSEQResult = -1) then
   begin
     s1 := Trim(StrPas(Instruction));
     delete(s1, 1, 3);
     s1 := FirstWord(Trim(s1));
     iSEQResult := RTFFile.GiveSEQNumber(s1);
     iSetResult(IntToStr(iSEQResult));
   end
  else if s = 'SYMBOL' then
   begin
     { read font name }
     Ps1 := StrPos(Instruction, '\f');
     if Ps1 = nil then
       Ps1 := StrPos(Instruction, '\F');

     if Ps1 = nil then
       FontName := 'System'
     else
      begin
        while (Ps1[0] <> '"') do Ps1 := Ps1 + 1;
        Ps1 := Ps1 + 1;
        s1 := StrPas(Ps1);
        FontName := copy(s1, 1, Pos('"', s1) - 1);
      end;

     StrPCopy(Fnt.lfFaceName, FontName);

     { read font size }
     Ps1 := StrPos(Instruction, '\s');
     if Ps1 = nil then
       Ps1 := StrPos(Instruction, '\S');

     if Ps1 <> nil then
      begin
        s1 := StrPas(Ps1);
        delete(s1, 1, 2);
        Fnt.lfHeight := StrToInt(FirstWord(s1)) * 20;
      end;

     { read char number }
     s1 := Trim(StrPas(Instruction));
     delete(s1, 1, 6);
     s1 := FirstWord(Trim(s1));
     iSetResult(chr(StrToInt(s1)));
   end;
end;

procedure TxRTFField.BuildView;
begin
  EvaluateField;
  inherited BuildView;

  { some fields should be often refreshed (like PAGE or TIME), so
    let us consider them always as being not built. Usually there is not
    that much fields and it won't take much time to rebuild them. }
  if not IsDataField then
    State := State - [bsViewValid]; 
end;

procedure TxRTFField.Change;
begin
  if not BOOL(HideChanges) then
    inherited Change;
end;

function TxRTFField.FindSize: LongInt;
begin
  Result := inherited FindSize;
{  Result := 1;}
end;

procedure TxRTFField.RegisterField;
begin
  if IsDataField then
   begin
     RTFFile.FormFields.Add(self);
     OwnerBlock.AddFormField(self);
   end;
end;

procedure TxRTFField.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  IsDirty := TxRTFField(From).IsDirty;
  IsEdited := TxRTFField(From).IsEdited;
  IsLocked := TxRTFField(From).IsLocked;
  IsFldPriv := TxRTFField(From).IsFldPriv;
  IsFldAlt := TxRTFField(From).IsFldAlt;
  StrDispose(Instruction);
  Instruction := StrNew(TxRTFField(From).Instruction);
  StrDispose(FieldResult);
  FieldResult := StrNew(TxRTFField(From).FieldResult);
  IsDataField := TxRTFField(From).IsDataField;
  DataField := TxRTFField(From).DataField;
  iReportPointer := TxRTFField(From).iReportPointer;
  IsFormField := TxRTFField(From).IsFormField;
  FFName := TxRTFField(From).FFName;
  FFDefText := TxRTFField(From).FFDefText;
  FFType := TxRTFField(From).FFType;
  FFTypeTxt := TxRTFField(From).FFType;
  Tag := TxRTFField(From).Tag;
  if IsDataField then
    RegisterField;
  Change;
  FFDefText := FFDefText;
end;

procedure TxRTFField.AppendResult(Value: TxRTFBasic);
begin
  AddData(Value);
end;

procedure TxRTFField.WriteRTF(Writer: TxRTFWriter);
begin
  if not IsDataField then
   begin
     Writer.StartGroup;
     Writer.WriteShortWord('field');
     Writer.WriteShortWord('flddirty');

     { instruction: }
     Writer.StartGroup;
     Writer.WriteShortWord('*');
     Writer.WriteShortWord('fldinst');  
     Writer.WritePChar(Instruction);
     Writer.EndGroup;

     { default result: }
     Writer.StartGroup;
     Writer.WriteShortWord('*');
     Writer.WriteShortWord('fldrslt');
     {Writer.StartGroup;
     Writer.WriteString('?');
     Writer.EndGroup;}
     {inherited WriteRTF(Writer); - somehow word mistreats this statement! }
     Writer.EndGroup;

     Writer.EndGroup;
   end
  else
   inherited WriteRTF(Writer);
end;

{ ======== TxRTFPara ========== }

constructor TxRTFPara.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
end;

destructor TxRTFPara.Destroy;
begin
  inherited Destroy;
end;

procedure TxRTFPara.SetLeftMargin(Value: Integer);
begin
  inherited SetLeftMargin(Value + TwipsToPixelsX(Info.LeftIndent));
end;

procedure TxRTFPara.SetDrawWidth(Value: Integer);
begin
  inherited SetDrawWidth(Value -
    TwipsToPixelsX(Info.LeftIndent + Info.RightIndent));
end;

function TxRTFPara.GetHeight: LongInt;
begin
  Result := TwipsToPixelsY(Info.SpaceBefore + Info.SpaceAfter);
end;

function TxRTFPara.LineHeight(Line: LongInt): LongInt;
var
  Opt: TDrawOptions;
begin
  Opt.Cmd := dcFindLineHeight;
  Opt.From := Line;
  Opt.Till := Line;
  Result := Draw(Opt).LineHeight;
  if Line = 0 then
    Result := Result + TwipsToPixelsY(Info.SpaceBefore);
  if Line = LinesCount - 1 then
    Result := Result + TwipsToPixelsY(Info.SpaceAfter);
end;

function TxRTFPara.TextBottom(Line: LongInt): LongInt;
var
  Opt: TDrawOptions;
begin
  Opt.Cmd := dcFindLineHeight;
  Opt.From := Line;
  Opt.Till := Line;
  Result := Draw(Opt).TextBottom;
  if Line = 0 then
    Result := Result + TwipsToPixelsY(Info.SpaceBefore);
end;

procedure TxRTFPara.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
  Reader.Read(Info, SizeOf(Info));
end;

procedure TxRTFPara.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
  Writer.Write(Info, SizeOf(Info));
end;

procedure TxRTFPara.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  Info := TxRTFPara(From).Info;
  Change;
end;

function TxRTFPara.PageStartHeight(FirstLine: LongInt): LongInt;
begin
  Result := 0;
end;

procedure TxRTFPara.StartPage(Opt: TDrawOptions);
begin
  { by default - skip }
end;

procedure TxRTFPara.WriteRTF(Writer: TxRTFWriter);
begin
  inherited WriteRTF(Writer);
end;


{ ======== TxRTFText ========== }

constructor TxRTFText.CreateChild(AnOwner: TxRTFBasic);
{var
  Chars: TxRTFChars;}
begin
  inherited CreateChild(AnOwner);

(*  Chars := TxRTFChars.CreateChild(self, RTFFile);
  Chars.SetData(' '); { to maintain valid parawidth even for empty paragraphs }
  AddData(Chars);*)
end;

destructor TxRTFText.Destroy;
begin
  inherited Destroy;
end;

function TxRTFText.WordEnd(From: LongInt): LongInt;
var
  SeekStart: Boolean;
  i, k: LongInt;
  s: string;
begin
  s := '';
  if (Count = 0) or (LastItem.MaxPos < From) then
   begin
     Result := -1;
     exit;
   end;
  i := 0;
  while Items[i].MaxPos < From do inc(i);
  SeekStart := false;
  while i < Count do
   begin
     if not(Items[i] is TxRTFChars) then
      begin
        Result := Items[i].MinPos - 1;
        exit;
      end; 
     for k := MaxInt(From, Items[i].MinPos) to Items[i].MaxPos do
      begin
        s := s + TxRTFChars(Items[i]).Data[k - Items[i].MinPos];
        if not SeekStart then
         begin
           if Pos(TxRTFChars(Items[i]).Data[k - Items[i].MinPos],
                  WordDelimiters) <> 0
           then
             SeekStart := true;
         end
        else
         begin
           if Pos(TxRTFChars(Items[i]).Data[k - Items[i].MinPos],
              WordDelimiters) = 0
           then
            begin
              Result := k - 1;
              exit;
            end;
         end;
      end;
     inc(i);
   end;
  Result := MaxPos;
end;

function TxRTFText.WordWidth(From, Till: LongInt): LongInt;
var
  i, j: LongInt;
begin
  Result := 0;
  j := From;
  for i := 0 to Count - 1 do
    if (j >= Items[i].MinPos) and (j <= Items[i].MaxPos) then
     begin
       if Till <= Items[i].MaxPos then
        begin
          Result := Result + TxRTFChars(Items[i]).BlockWidth(j, Till);
          j := Till + 1;
        end
       else
        begin
          Result := Result + TxRTFChars(Items[i]).BlockWidth(j, Items[i].MaxPos);
          j := Items[i].MaxPos + 1;
        end;
       if j > Till then exit;
     end;
end;

function TxRTFText.DrawWord(Opt: TDrawOptions; From, Till: LongInt): TDrawResult;
var
  i, j: LongInt;
  r: TDrawResult;
  SubOpt: TDrawOptions;
begin
  SetDefaultResult(Result);
  SubOpt := Opt;
  j := From;
  for i := 0 to Count - 1 do
    if (j >= Items[i].MinPos) and (j <= Items[i].MaxPos) then
     begin
       if Till <= Items[i].MaxPos then
        begin
          SubOpt.From := j;
          SubOpt.Till := Till;
          r := Items[i].Draw(SubOpt);
          j := Till + 1;
        end
       else
        begin
          SubOpt.From := j;
          SubOpt.Till := Items[i].MaxPos;
          r := Items[i].Draw(SubOpt);
          j := SubOpt.Till + 1;
        end;
       Result.LineHeight := MaxInt(Result.LineHeight, r.LineHeight);
       Result.TextBottom := MaxInt(Result.TextBottom, r.TextBottom);
       if (r.NextLineStart <> -1) and
          (Opt.Cmd in [dcFindLineHeight, dcDrawLine]) then
        begin
          Result.NextLineStart := r.NextLineStart;
          Result.LineWidth := r.LineWidth;
          exit;
        end;
       if j > Till then
        begin
          Result.LineWidth := r.LineWidth;
          exit;
        end;
     end;
end;

function TxRTFText.OwningItem(Position: LongInt): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if (Items[i].MinPos <= Position) and (Items[i].MaxPos >= Position) then
     begin
       Result := i;
       exit;
     end;
  Result := -1; { not found }
end;

function TxRTFText.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  i, j: LongInt;
  WrdWidth: LongInt;
  r: TDrawResult;
  AnItem: Integer;
  SubOpt: TDrawOptions;
begin
  SetDefaultResult(Result);
  Result.LineWidth := Position.X;

  { draw paragraph text }
  i := Opt.From;
  repeat
    AnItem := OwningItem(i);

    if AnItem < 0 then exit;

    if not(Items[AnItem] is TxRTFChars) then
     begin
       { next items are not text (pictures or smth else - draw them) }
       while (AnItem < Count) and not(Items[AnItem] is TxRTFChars) do
        begin
          { go next line if necessary }
          if (Position.X + Items[AnItem].Width > ScaleMe(FDrawWidth)) and
             (Items[AnItem].Width <= ScaleMe(FDrawWidth)) then
           begin
             Result.LineWidth := Position.X;
             NewLine(Opt);
             if Opt.Cmd in [dcDrawLine, dcFindLineHeight] then
              begin
                Result.NextLineStart := i;
                exit;
              end;
           end;
          { draw item }
          SubOpt := Opt;
          r := Items[AnItem].Draw(SubOpt);
          Result.LineHeight := MaxInt(Result.LineHeight, r.LineHeight);
          Result.TextBottom := MaxInt(Result.TextBottom, r.TextBottom);
          if (Opt.Cmd in [dcDrawLine, dcFindLineHeight]) and
             (r.NextLineStart <> -1) then
           begin
             Result.LineWidth := r.LineWidth;
             Result.NextLineStart := r.NextLineStart;
             exit;
           end;
          inc(AnItem);
        end;
       if AnItem < Count then
         i := Items[AnItem].MinPos;
     end;

    if AnItem < Count then
     begin
       j := WordEnd(i);

       { go next line if word too long for the current line }
       WrdWidth := WordWidth(i, j);
       if (Position.X + WrdWidth > ScaleMe(FDrawWidth)) and
          (WrdWidth <= ScaleMe(FDrawWidth)) and (i > Opt.From) then
        begin
          Result.LineWidth := Position.X;
          NewLine(Opt);
          if Opt.Cmd in [dcDrawLine, dcFindLineHeight] then
           begin
             Result.NextLineStart := i;
             exit;
           end;
        end;

       { draw a single word }
       r := DrawWord(Opt, i, j);

       { check if additional space between lines is needed }
       Result.LineHeight := MaxInt(Result.LineHeight, r.LineHeight);
       Result.TextBottom := MaxInt(Result.TextBottom, r.TextBottom);
       if (Opt.Cmd in [dcDrawLine, dcFindLineHeight]) and
          (r.NextLineStart <> -1) then
        begin
          Result.LineWidth := r.LineWidth;
          Result.NextLineStart := r.NextLineStart;
          exit;
        end;
       i := j + 1;
     end
    else
     i := MaxPos + 1;
  until i > MaxPos;

  Result.LineWidth := Position.X;
end;

procedure TxRTFText.BuildView;
begin
  inherited BuildView;
end;

procedure TxRTFText.Append(s: string; AFnt: TLogFont);
var
  i, j: LongInt;
  Chars: TxRTFChars;
  Tab: TxRTFTabChar;
begin
  i := 1;
  repeat
    j := i + 1;
    if s[i] = #9 then
     begin
       Tab := TxRTFTabChar.CreateChild(self);
       AddData(Tab);
       inc(i);
     end
    else
     begin
       while (j <= Length(s)) and not(s[j] in [#9]) do inc(j);
       dec(j);

       if (Count > 0) and (LastItem is TxRTFChars) and
          CompareFonts(TxRTFChars(LastItem).Fnt, AFnt)
       then
         TxRTFChars(LastItem).AddData(copy(s, i, j - i + 1))
       else
        begin
          Chars := TxRTFChars.CreateChild(self);
          Chars.Fnt := AFnt;
          Chars.AddData(copy(s, i, j - i + 1));
          AddData(Chars);
        end;
       i := j + 1;
     end;
  until i > Length(s);
end;

procedure TxRTFText.AddPict(APict: TxPictInfo);
var
  Metafile: TxRTFMetafile;
begin
  if APict.PictType = 'wmetafile' then
   begin
     Metafile := TxRTFMetafile.CreateChild(self);
     Metafile.Info := APict;
     AddData(Metafile);
     Metafile.Change;
   end
  else
   begin
     MessageDlg('Non-metafile picture in RTF file will be ignored.',
       mtInformation, [mbOk], 0);
     GlobalFree(APict.DataHandle);
   end;
end;

procedure TxRTFText.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
end;

procedure TxRTFText.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
end;

procedure TxRTFText.Clear;
begin
  inherited Clear;
end;

procedure TxRTFText.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
end;

function TxRTFText.AsText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    if Items[i] is TxRTFChars then
      Result := Result + StrPas(TxRTFChars(Items[i]).Data)
    else if Items[i] is TxRTFTabChar then
      Result := Result + #9;
end;

procedure TxRTFText.WriteRTF(Writer: TxRTFWriter);
begin
  inherited WriteRTF(Writer);
end;


{ ======== TxRTFTextPara ========== }

constructor TxRTFTextPara.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  LineInfo := TClassList.Create;
  Info.FirstLine := 0;
  if Owner is TxRTFCell then
   begin
     Info.Shading := TxRTFCell(Owner).Info.Shading;
     Info.ForeColor := TxRTFCell(Owner).Info.ForeColor;
     Info.BKColor := TxRTFCell(Owner).Info.BKColor;
   end
  else
   begin
     Info.Shading := 0;
     Info.ForeColor := DefForeColor;
     Info.BKColor := DefBKColor;
   end;
end;

destructor TxRTFTextPara.Destroy;
begin
  LineInfo.Free;
  inherited Destroy;
end;

function TxRTFTextPara.OwningItem(Position: LongInt): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if (Items[i].MinPos <= Position) and (Items[i].MaxPos >= Position) then
     begin
       Result := i;
       exit;
     end;
  Result := -1; { not found }
end;

// updates line height using interline spacing
procedure TxRTFTextPara.UpdateLineHeight(var Total: LongInt; Current: LongInt);
begin
  if (Info.SpaceBetweenLines <> 0) and
     (Info.SpaceBetweenLines <> 1000) then
   begin
     if Info.MultipleLineSpacing = 0 then
      begin
        if Info.SpaceBetweenLines > 0 then
          Total := MaxInt(Total,
            MaxInt(Current, TwipsToPixelsY(Abs(Info.SpaceBetweenLines))))
        else
          Total := MaxInt(Total, TwipsToPixelsY(Abs(Info.SpaceBetweenLines)));
      end

     else
      Total := MaxInt(Total, Abs(Info.SpaceBetweenLines) * Current div 240);
   end
  else
   Total := MaxInt(Total, Current);
end;

procedure TxRTFTextPara.FillFullWidth(Y1, Y2: Integer);
var
  ARect: TRect;
  aBrush: HBrush;
  LogBrush: TLOGBRUSH;
  OldBrush: THANDLE;
  RGBColor: LongInt;
begin
  RGBColor := GetRGBColor(Info.BKColor, Info.Shading);
  SetBkColor(CanvasHandle, RGBColor);
  LogBrush.lbColor := RGBColor;
  LogBrush.lbStyle := BS_SOLID;
  LogBrush.lbHatch := 0;
  aBrush := CreateBrushIndirect(LogBrush);
  OldBrush := SelectObject(CanvasHandle, aBrush);
  try
    SetRect(ARect, - RTFFile.OriginalOpt.HShift + ScaleMe(FLeftMargin), Y1,
      - RTFFile.OriginalOpt.HShift + ScaleMe(FLeftMargin) + ScaleMe(FDrawWidth), Y2);
    FillRect(CanvasHandle, ARect, aBrush);
  finally
    SelectObject(CanvasHandle, OldBrush);
    DeleteObject(aBrush);
  end;
end;

function TxRTFTextPara.iDraw(Opt: TDrawOptions): TDrawResult;
var
  i, j: LongInt;
  r: TDrawResult;
  SubOpt: TDrawOptions;
begin
  SetDefaultResult(Result);

  { draw shading }
  if Opt.Cmd = dcDrawLine then
    FillFullWidth(Position.Y, Position.Y + Opt.LineHeight);

  { indent first line:  }
  if Opt.From <= MinPos then
    MoveX(Position.X + TwipsToPixelsX(Info.FirstLine) );

  { draw paragraph text }

  SubOpt := Opt;
  j := Opt.From;
  for i := 0 to Count - 1 do
    if (j >= Items[i].MinPos) and (j <= Items[i].MaxPos) then
     begin
       SubOpt.From := j;
       SubOpt.Till := Items[i].MaxPos;
       r := Items[i].Draw(SubOpt);
       j := Items[i].MaxPos + 1;
       Result.LineHeight := MaxInt(Result.LineHeight, r.LineHeight);
       Result.TextBottom := MaxInt(Result.TextBottom, r.TextBottom);
       if (r.NextLineStart <> -1) and
          (Opt.Cmd in [dcFindLineHeight, dcDrawLine]) then
        begin
          Result.NextLineStart := r.NextLineStart;
          Result.LineWidth := r.LineWidth;
          exit;
        end;
     end;
  Result.LineWidth := Position.X;
  NewLine(Opt);
  Result.NextLineStart := MaxPos + 1;
end;

function TxRTFTextPara.ParaHasText: Boolean;
var
  i: Integer;
begin
  Result := false;
  i := 0;
  while not(Result) and (i < Count) do
   begin
     if (Items[i] is TxRTFText) then
       Result := TxRTFText(Items[i]).Count <> 0
     else
       Result := true;
     inc(i);
   end;
end;

function TxRTFTextPara.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  SubOpt: TDrawOptions;
  r: TDrawResult;
  ALine: LongInt;
begin
  { see for empty paragraph ('cause even empty para should be of
    non-zero height) }
  if not ParaHasText then
   begin
     SetDefaultResult(Result);
     Result.NextLineStart := MaxPos + 1;
     Result.LineHeight := RTFFile.CanvasTextMetric.tmHeight;
     Result.TextBottom := Result.LineHeight;
     Opt.LineHeight := Result.LineHeight;
     Opt.TextBottom := Result.TextBottom;
     NewLine(Opt);
     exit;
   end;

  if Opt.Cmd = dcDrawWhole then
   begin
     { shift vertically }
     if Opt.From = 0 then
      begin
        if Opt.Cmd in [dcDrawLine, dcDrawWhole] then
          FillFullWidth(Position.Y,
            Position.Y + TwipsToPixelsY(Info.SpaceBefore));
        MoveY(Position.Y + TwipsToPixelsY(Info.SpaceBefore));
      end;

     { draw desired lines }
     for ALine := Opt.From to MinInt(LineInfo.Count - 1, Opt.Till) do
      begin
        SubOpt := Opt;
        SubOpt.Cmd := dcDrawLine;
        SubOpt.From := TxParaLine(LineInfo[ALine]).Start;
        SubOpt.LineHeight := ScaleMe(TxParaLine(LineInfo[ALine]).Height);
        SubOpt.TextBottom := ScaleMe(TxParaLine(LineInfo[ALine]).TextBottom);
        case Info.Align of
          alLeft: { Ok };
          alRight: SubOpt.HShift := SubOpt.HShift -
            MaxInt(ScaleMe(FDrawWidth) - ScaleMe(TxParaLine(LineInfo[ALine]).Width), 0);
          alCentered: SubOpt.HShift := SubOpt.HShift -
            MaxInt(ScaleMe(FDrawWidth) - ScaleMe(TxParaLine(LineInfo[ALine]).Width), 0) div 2;
          alJustified: { wait for future version };
        end;
        r := iDraw(SubOpt);
      end;
     if Opt.Till >= LineInfo.Count - 1 then
      begin
        if Opt.Cmd in [dcDrawLine, dcDrawWhole] then
          FillFullWidth(Position.Y,
            Position.Y + TwipsToPixelsY(Info.SpaceAfter));
        MoveY(Position.Y + TwipsToPixelsY(Info.SpaceAfter));
      end;
     Result := r;
     Result.LineHeight := SubOpt.LineHeight;
     Result.TextBottom := SubOpt.TextBottom;
   end
  else
   begin
     Opt.From := TxParaLine(LineInfo[Opt.From]).Start;
     Result := iDraw(Opt);
   end;
end;

procedure TxRTFTextPara.BuildView;
var
  Opt: TDrawOptions;
  r: TDrawResult;
  Ln: TxParaLine;
  OldPos: TPoint;
  LineLeft: LongInt;
begin
  OldPos := Position;
  try
    Position := Point(0, 0);
    inherited BuildView;

    LineInfo.Clear;

    if not ParaHasText then
     begin
       Ln := TxParaLine.Create;
       Ln.Start := Opt.From;

       Opt.Cmd := dcFindLineHeight;
       LineLeft := Position.X;
       r := DoDraw(Opt);

       Ln.Height := r.LineHeight;
       Ln.TextBottom := r.TextBottom;
       Ln.Width := r.LineWidth - LineLeft;
       LineInfo.Add(Ln);
     end
    else
     begin
       Opt.From := MinPos;
       while Opt.From <= MaxPos do
        begin
          Ln := TxParaLine.Create;
          Ln.Start := Opt.From;

          Opt.Cmd := dcFindLineHeight;
          LineLeft := Position.X;
          r := iDraw(Opt);

          Ln.Height := r.LineHeight;
          Ln.TextBottom := r.TextBottom;
          Ln.Width := r.LineWidth - LineLeft;
          LineInfo.Add(Ln);

          Opt.From := r.NextLineStart;
        end;
     end;
  finally
    Position := OldPos;
  end;
end;

function TxRTFTextPara.GetLinesCount: LongInt;
begin
  CheckIsBuilt;
  Result := LineInfo.Count;
end;

function TxRTFTextPara.GetHeight: LongInt;
var
  i: LongInt;
begin
  CheckIsBuilt;
  Result := inherited GetHeight;
  for i := 0 to LineInfo.Count - 1 do
    Result := Result + ScaleMe(TxParaLine(LineInfo[i]).Height);
end;

{function TxRTFTextPara.LineOffset(Line: LongInt): LongInt;
begin
  CheckIsBuilt;
  Result := TxParaLine(LineInfo[Line]).Start;
end;}

procedure TxRTFTextPara.Append(s: string; AFnt: TLogFont);
var
  Txt: TxRTFText;
begin
  if s = '' then exit;

  if (Count = 0) or
     (not(LastItem is TxRTFText) or (LastItem is TxRTFField)) then
   begin
     Txt := TxRTFText.CreateChild(self);
     AddData(Txt);
   end
  else
   Txt := TxRTFText(LastItem);

  Txt.Append(s, AFnt);
end;

function TxRTFTextPara.LineHeight(Line: LongInt): LongInt;
begin
  CheckIsBuilt;
  Result := ScaleMe(TxParaLine(LineInfo[Line]).Height);
  if Line = 0 then
    Result := Result + TwipsToPixelsY(Info.SpaceBefore);
  if Line = LinesCount - 1 then
    Result := Result + TwipsToPixelsY(Info.SpaceAfter);
end;

function TxRTFTextPara.TextBottom(Line: LongInt): LongInt;
begin
  CheckIsBuilt;
  Result := ScaleMe(TxParaLine(LineInfo[Line]).TextBottom);
  if Line = 0 then
    Result := Result + TwipsToPixelsY(Info.SpaceBefore);
end;

procedure TxRTFTextPara.AddPict(APict: TxPictInfo);
var
  Txt: TxRTFText;
begin
  if Count = 0 then
   begin
     Txt := TxRTFText.CreateChild(self);
     AddData(Txt);
   end
  else
   Txt := TxRTFText(LastItem);

  Txt.AddPict(APict);
end;

procedure TxRTFTextPara.ReadData(Reader: TReader);
var
  ParaLine: TxParaLine;
begin
  inherited ReadData(Reader);
  LineInfo.Clear;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
   begin
     Paraline := TxParaLine.Create;
     ParaLine.ReadData(Reader);
     LineInfo.Add(ParaLine);
   end;
  Reader.ReadListEnd;
end;

procedure TxRTFTextPara.WriteData(Writer: TWriter);
var
  i: Integer;
begin
  inherited WriteData(Writer);
  Writer.WriteListBegin;
  for i := 0 to LineInfo.Count - 1 do
    TxParaLine(LineInfo[i]).WriteData(Writer);
  Writer.WriteListEnd;
end;

function TxRTFTextPara.NextTabStop(Shift: LongInt): LongInt;
var
  UseDefaultTabs: Boolean;
  i: Integer;
begin
  Result := Shift; // Delphi is stupid as usual - it makes warning in this func 

  UseDefaultTabs := true;
  for i := 0 to Info.TabXNum - 1 do
   if TwipsToPixelsX(Info.TabX[i]) > Shift then
    begin
      if not UseDefaultTabs then
        Result := MinInt(Result, TwipsToPixelsX(Info.TabX[i]))
      else
       begin
         Result := TwipsToPixelsX(Info.TabX[i]);
         UseDefaultTabs := false;
       end;
    end;

  if UseDefaultTabs then
    Result := Trunc(((Shift / RTFFile.CanvasPPIX) * 2) + 1) * RTFFile.CanvasPPIX div 2;
end;

procedure TxRTFTextPara.Clear;
begin
  LineInfo.Clear;
  inherited Clear;
end;

procedure TxRTFTextPara.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
end;

function TxRTFTextPara.AsText: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    if Items[i] is TxRTFText then
      Result := Result + TxRTFText(Items[i]).AsText
    else if Items[i] is TxRTFTabChar then
      Result := Result + #9;
end;

procedure TxRTFTextPara.WriteRTF(Writer: TxRTFWriter);
begin
  if Owner is TxRTFCell then
    Writer.WriteShortWord('intbl');

  case Info.Align of
    alLeft: Writer.WriteShortWord('ql');
    alRight: Writer.WriteShortWord('qr');
    alCentered: Writer.WriteShortWord('qc');
    alJustified: Writer.WriteShortWord('qj');
  end;
  Writer.WriteLongWord('fi', Info.FirstLine);
  Writer.WriteLongWord('li', Info.LeftIndent);
  Writer.WriteLongWord('ri', Info.RightIndent);
  Writer.WriteLongWord('sa', Info.SpaceAfter);
  Writer.WriteLongWord('sb', Info.SpaceBefore);
  Writer.WriteLongWord('sl', Info.SpaceBetweenLines);
  Writer.WriteLongWord('slmult', Info.MultipleLineSpacing);
  if Info.Intact then
    Writer.WriteShortWord('keep');
  if Info.WithNext then
    Writer.WriteShortWord('keepn');
  Writer.WriteLongWord('sb', Info.SpaceBefore);

  { here should be tabs definition }

  { para shading: }
  if not CompareColors(Info.BKColor, DefBKColor) then
    Writer.WriteLongWord('cbpat', RTFFile.FindColorIndex(Info.BKColor));
  if not CompareColors(Info.ForeColor, DefForeColor) then
    Writer.WriteLongWord('cfpat', RTFFile.FindColorIndex(Info.ForeColor));

  inherited WriteRTF(Writer);
  if not((Owner is TxRTFCell) and (TxRTFCell(Owner).LastItem = self)) then
   begin
     if Info.TerminatePageAfterPara then
       Writer.WriteShortWord('page')
     else
       Writer.WriteShortWord('par');
   end;
end;


{ ======== TxRTFCell ========== }

constructor TxRTFCell.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  Info.RightBound := 0;
  Info.Shading := 0;
  Info.ForeColor := DefForeColor;
  Info.BKColor := DefBKColor;
  Info.LeftBorder.w := 0;
  Info.TopBorder.w := 0;
  Info.BottomBorder.w := 0;
  Info.RightBorder.w := 0;
end;

destructor TxRTFCell.Destroy;
begin
  inherited destroy;
end;

function TxRTFCell.GetLinesCount: LongInt;
var
  i: LongInt;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + TxRTFPara(Items[i]).LinesCount;
end;

procedure TxRTFCell.CopyStructure(ACell: TxRTFCell);
begin
  Info := ACell.Info;
end;

procedure TxRTFCell.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
  {RightBound := Reader.ReadInteger;}
end;

procedure TxRTFCell.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
  {Writer.WriteInteger(RightBound);}
end;

procedure TxRTFCell.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  Info := TxRTFCell(From).Info;
  Change;
end;

function TxRTFCell.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  RGBColor: LongInt;
  LogBrush: TLOGBRUSH;
  aBrush: THANDLE;
  OldBrush: THandle;
  ARect: TRect;
begin
  { draw shading first }
  if Opt.Cmd in [dcDrawLine, dcDrawWhole] then
   begin
     RGBColor := GetRGBColor(Info.BKColor, Info.Shading);
     SetBkColor(CanvasHandle, RGBColor);
     LogBrush.lbColor := RGBColor;
     LogBrush.lbStyle := BS_SOLID;
     LogBrush.lbHatch := 0;
     aBrush := CreateBrushIndirect(LogBrush);
     OldBrush := SelectObject(CanvasHandle, aBrush);
     try
       SetRect(ARect,
         - RTFFile.OriginalOpt.HShift + ScaleMe(FLeftMargin) -
           TwipsToPixelsX(TxRTFTableRow(Owner).CellsSpace),
         Position.Y,
         - RTFFile.OriginalOpt.HShift + ScaleMe(FLeftMargin) + ScaleMe(FDrawWidth) +
           TwipsToPixelsX(TxRTFTableRow(Owner).CellsSpace),
         Position.Y + TxRTFTableRow(Owner).Height);
       FillRect(CanvasHandle, ARect, aBrush);
     finally
       SelectObject(CanvasHandle, OldBrush);
       DeleteObject(aBrush);
     end;
   end;

  { draw cell text }
  Result := inherited DoDraw(Opt);
end;

procedure TxRTFCell.WriteRTF(Writer: TxRTFWriter);
begin
  Writer.StartGroup;
  inherited WriteRTF(Writer);
  Writer.WriteShortWord('cell');
  Writer.EndGroup;
end;


{ ======== TxRTFTableRow ========== }

constructor TxRTFTableRow.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  CellsSpace := 0;
  CurrentCell := 0;
  NextIsTableRow := false;
  FirstHeaderRow := nil;
  IsHeader := false;
end;

destructor TxRTFTableRow.Destroy;
begin
  inherited destroy;
end;

function TxRTFTableRow.GetiHeight: LongInt;
var
  i: LongInt;
begin
  CheckIsBuilt;

  Result := 0;
  for i := 0 to Count - 1 do
    Result := MaxInt(Result, TxRTFCell(Items[i]).Height);

  { for top bound }
  Result := Result + ScaleMe(TopLine);
end;

function TxRTFTableRow.GetHeight: LongInt;
begin
  Result := GetiHeight;

  { for bottom bound (when needed) }
  if not NextIsTableRow then
    inc(Result, ScaleMe(BottomLine));
end;

procedure TxRTFTableRow.AddCell;
var
  Cell: TxRTFCell;
begin
  Cell := TxRTFCell.CreateChild(self);
  AddData(Cell);
end;

procedure TxRTFTableRow.AppendParagraph(s: string; AFnt: TLogFont);
begin
  TxRTFTextPara(TxRTFCell(Items[CurrentCell]).LastItem).Append(s, AFnt);
end;

procedure TxRTFTableRow.UpdateParaInfo(Info: TxParaInfo);
begin
  if TxRTFCell(Items[CurrentCell]).Count > 0 then
    TxRTFTextPara(TxRTFCell(Items[CurrentCell]).LastItem).Info := Info;
end;

procedure TxRTFTableRow.AddParagraph(APara: TxRTFTextPara);
begin
  TxRTFCell(Items[CurrentCell]).AddData(APara);
end;

function TxRTFTableRow.CurrentCellItem: TxRTFCell;
begin
  Result := TxRTFCell(Items[CurrentCell]);
end;

function TxRTFTableRow.CreateTextPara: TxRTFTextPara;
begin
  Result := TxRTFTextPara.CreateChild(self);
end;

procedure TxRTFTableRow.GoNextCell;
begin
  if CurrentCell < Count then
    inc(CurrentCell);
end;

procedure TxRTFTableRow.SetLeftMargin(Value: Integer);
var
  i: LongInt;
  Current: LongInt;
  Space: LongInt;
begin
  // next line incorrectly uses slacing. Must be later deleted
  FLeftMargin := Value + TwipsToPixelsX(Info.LeftIndent + LeftEdge);
  Current := 0;
  Space := TwipsToPixelsX(CellsSpace);
  for i := 0 to Count - 1 do
   begin
     TxRTFCell(Items[i]).SetLeftMargin(FleftMargin + Current + Space);
     TxRTFCell(Items[i]).SetDrawWidth(
       TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound) - Current - 2 * Space);
     Current := TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound);
   end;
end;

procedure TxRTFTableRow.SetDrawWidth(Value: Integer);
begin
  FDrawWidth := Value; { do not pass to cells }
end;

procedure TxRTFTableRow.BuildView;
var
  PrevRow: TxRTFPara;
  i: Integer;
begin
  NextIsTableRow := (TxRTFBlock(Owner).NextParaRef(self) <> nil) and
    (TxRTFBlock(Owner).NextParaRef(self) is TxRTFTableRow);
  FirstHeaderRow := nil;

  PrevRow := TxRTFBlock(Owner).PrevParaRef(self);
  if (PrevRow is TxRTFTableRow) then
   begin
     TxRTFTableRow(PrevRow).CheckIsBuilt;
     if TxRTFTableRow(PrevRow).IsHeader then
       FirstHeaderRow := TxRTFTableRow(PrevRow)
     else
       FirstHeaderRow := TxRTFTableRow(PrevRow).FirstHeaderRow;
   end;

  {find top and bottom lines width }
  TopLine := TxRTFCell(Items[0]).Info.TopBorder.w;
  BottomLine := TxRTFCell(Items[0]).Info.BottomBorder.w;
  for i := 1 to Count - 1 do
   begin
     TopLine := MaxInt(TopLine, TxRTFCell(Items[i]).Info.TopBorder.w);
     BottomLine := MaxInt(BottomLine, TxRTFCell(Items[i]).Info.BottomBorder.w);
   end;
  TopLine := TwipsToPixelsY(TopLine);
  BottomLine := TwipsToPixelsY(BottomLine);

  inherited BuildView;
end;

function TxRTFTableRow.GetLinesCount: LongInt;
begin
  Result := 1;
end;

function TxRTFTableRow.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  StartPos: TPoint;
  i: LongInt;
  SubOpt: TDrawOptions;
  aPen, OldPen: THandle;
  LeftOfs: Integer;
begin
  Result.LineHeight := Height;
  StartPos := Position;
  case Opt.Cmd of
    dcFindLineHeight:
      begin
        Result.LineHeight := Height;
      end;
    else
     begin
       SubOpt := Opt;
       for i := 0 to Count - 1 do
        begin
          Position := Point(0, StartPos.Y + ScaleMe(TopLine));
          SubOpt.From := 0;
          SubOpt.Till := TxRTFCell(Items[i]).LinesCount;
          Items[i].Draw(SubOpt);
        end;

       { vertical lines: }
       aPen := CreatePen(PS_SOLID, 1, ColorToRGB(clBlack));
       OldPen := SelectObject(CanvasHandle, aPen);
       try
         if TxRTFCell(Items[0]).Info.LeftBorder.w > 0 then
           xThickLine(CanvasHandle, Point(ScaleMe(FLeftMargin) - Opt.HShift, StartPos.Y),
             Point(ScaleMe(FLeftMargin) - Opt.HShift, StartPos.Y + GetiHeight + ScaleMe(BottomLine)),
             TwipsToPixelsX(TxRTFCell(Items[0]).Info.LeftBorder.w), 1);
         for i := 0 to Count - 1 do
          if TxRTFCell(Items[i]).Info.RightBorder.w > 0 then
            xThickLine(CanvasHandle,
              Point(ScaleMe(FLeftMargin) + TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound) - Opt.HShift,
                    StartPos.Y),
              Point(ScaleMe(FLeftMargin) + TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound) - Opt.HShift,
                    StartPos.Y + GetiHeight + ScaleMe(BottomLine)),
              TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBorder.w), 1);
       finally
         SelectObject(CanvasHandle, OldPen);
         DeleteObject(aPen);
       end;

       { horizontal lines: }
       aPen := CreatePen(PS_SOLID, 1, ColorToRGB(clBlack));
       OldPen := SelectObject(CanvasHandle, aPen);
       try
         for i := 0 to Count - 1 do
          begin
            if i > 0 then
              LeftOfs := TwipsToPixelsX(TxRTFCell(Items[i - 1]).Info.RightBound)
            else
              LeftOfs := 0;

            { Top Border }
            if TxRTFCell(Items[i]).Info.TopBorder.w > 0 then
              xThickLine(CanvasHandle,
                Point(ScaleMe(FLeftMargin) + LeftOfs - Opt.HShift, StartPos.Y + ScaleMe(TopLine div 2)),
                Point(ScaleMe(FLeftMargin) + TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound) - Opt.HShift,
                      StartPos.Y + ScaleMe(TopLine div 2)),
                1, TwipsToPixelsY(TxRTFCell(Items[i]).Info.TopBorder.w));

            { Bottom Border }
            if TxRTFCell(Items[i]).Info.BottomBorder.w > 0 then
              xThickLine(CanvasHandle,
                Point(ScaleMe(FLeftMargin) + LeftOfs - Opt.HShift, StartPos.Y + GetiHeight + ScaleMe(BottomLine div 2)),
                Point(ScaleMe(FLeftMargin)  - Opt.HShift + TwipsToPixelsX(TxRTFCell(Items[i]).Info.RightBound),
                      StartPos.Y + GetiHeight + BottomLine div 2),
               1, TwipsToPixelsY(TxRTFCell(Items[i]).Info.BottomBorder.w));
          end;
       finally
         SelectObject(CanvasHandle, OldPen);
         DeleteObject(aPen);
       end;

       Position := Point(0, StartPos.Y + Height); { = NewLine(Opt); }
     end;
  end;
end;

procedure TxRTFTableRow.CopyStructure(ATable: TxRTFTableRow);
var
  i: LongInt;
  Cell: TxRTFCell;
begin
  for i := 0 to ATable.Count - 1 do
   begin
     Cell := TxRTFCell.CreateChild(self);
     AddData(Cell);
     Cell.CopyStructure(ATable.Items[i] as TxRTFCell);
   end;
  CellsSpace := ATable.CellsSpace;
  LeftEdge := ATable.LeftEdge;
end;

function TxRTFTableRow.GetLastTextPara: TxRTFTextPara;
begin
  Result := TxRTFTextPara(TxRTFCell(Items[CurrentCell]).LastItem);
end;

function TxRTFTableRow.LineHeight(Line: LongInt): LongInt;
begin
  Result := Height;
end;

procedure TxRTFTableRow.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
  CellsSpace := Reader.ReadInteger;
  NextIsTableRow := Reader.ReadBoolean;
end;

procedure TxRTFTableRow.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
  Writer.WriteInteger(CellsSpace);
  Writer.WriteBoolean(NextIsTableRow);
end;

procedure TxRTFTableRow.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  NextIsTableRow := TxRTFTableRow(From).NextIsTableRow;
  CellsSpace := TxRTFTableRow(From).CellsSpace;
  LeftEdge := TxRTFTableRow(From).LeftEdge;
  IsHeader := TxRTFTableRow(From).IsHeader;
  Change;
end;

function TxRTFTableRow.PageStartHeight(FirstLine: LongInt): LongInt;
begin
  if FirstHeaderRow <> nil then
    Result := FirstHeaderRow.Height
  else
    Result := 0;
end;

procedure TxRTFTableRow.StartPage(Opt: TDrawOptions);
begin
  if FirstHeaderRow <> nil then
   begin
     FirstHeaderRow.StartPage(Opt);
     FirstHeaderRow.Draw(Opt);
   end;
end;

procedure TxRTFTableRow.WriteRTF(Writer: TxRTFWriter);
var
  i: Integer;
begin
  Writer.StartGroup;
  Writer.WriteShortWord('trowd');
  Writer.WriteLongWord('trgaph', CellsSpace);
  Writer.WriteLongWord('trleft', LeftEdge);
  if IsHeader then
    Writer.WriteShortWord('trhdr');
  for i := 0 to Count - 1 do
   with TxRTFCell(Items[i]).Info do
    begin
      if LeftBorder.w <> 0 then
       begin
         Writer.WriteShortWord('clbrdrl');
         Writer.WriteShortWord('brdrs');
         Writer.WriteLongWord('brdrw', LeftBorder.w);
       end;
      if RightBorder.w <> 0 then
       begin
         Writer.WriteShortWord('clbrdrr');
         Writer.WriteShortWord('brdrs');
         Writer.WriteLongWord('brdrw', RightBorder.w);
       end;
      if TopBorder.w <> 0 then
       begin
         Writer.WriteShortWord('clbrdrt');
         Writer.WriteShortWord('brdrs');
         Writer.WriteLongWord('brdrw', TopBorder.w);
       end;
      if BottomBorder.w <> 0 then
       begin
         Writer.WriteShortWord('clbrdrb');
         Writer.WriteShortWord('brdrs');
         Writer.WriteLongWord('brdrw', BottomBorder.w);
       end;

      if not CompareColors(BKColor, DefBKColor) then
        Writer.WriteLongWord('clcbpat', RTFFile.FindColorIndex(BKColor));
      if not CompareColors(ForeColor, DefForeColor) then
        Writer.WriteLongWord('clcfpat', RTFFile.FindColorIndex(ForeColor));
      if Shading <> 0 then
        Writer.WriteLongWord('clshdng', Shading);

      Writer.WriteLongWord('cellx', RightBound);
    end;
  inherited WriteRTF(Writer);
  Writer.WriteShortWord('row');
  Writer.EndGroup;
end;


{ ======== TxRTFBlock ========== }
constructor TxRTFBlock.CreateChild(AnOwner: TxRTFBasic);
begin
  inherited CreateChild(AnOwner);
  ReadingTableRow := false;
  ForceNewPara := true;
  FormFields := TList.Create;
end;

destructor TxRTFBlock.Destroy;
begin
  FormFields.Free;
  inherited destroy;
end;

procedure TxRTFBlock.BuildView;
begin
  inherited BuildView;
end;

function TxRTFBlock.DoDraw(Opt: TDrawOptions): TDrawResult;
var
  i: LongInt;
begin
  i := 0;
  while (i < Count) and
        (Position.Y < Opt.DrawRect.Bottom)  and
        (Opt.From <= Opt.Till) do
  begin
    if (Opt.From < TxRTFPara(Items[i]).LinesCount) or
       (Opt.From = 0) { - to support empty paragraphs }
    then
     begin
       Result := Items[i].Draw(Opt);
       if Opt.Cmd in [dcFindLineHeight] then exit;
       Opt.Till := Opt.Till - TxRTFPara(Items[i]).LinesCount;
       Opt.From := 0;
     end
    else
     begin
       Opt.From := Opt.From - TxRTFPara(Items[i]).LinesCount;
       Opt.Till := Opt.Till - TxRTFPara(Items[i]).LinesCount;
     end;
    inc(i);
  end;
end;

function TxRTFBlock.GetLinesCount: LongInt;
var
  i: LongInt;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + TxRTFPara(Items[i]).LinesCount;
end;

function TxRTFBlock.GetHeight: LongInt;
var
  i: LongInt;
begin
  CheckIsBuilt;
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + TxRTFCell(Items[i]).Height;
end;

function TxRTFBlock.IsEmpty: Boolean; { true if block is empty }
begin
  if RTFFile.CurrentPara <> '' then
    ClosePara;
  Result := Count = 0;
end;

{function TxRTFBlock.LineOffset(Line: LongInt): LongInt;
var
  ALine: LongInt;
  i: LongInt;
begin
  ALine := 0;
  for i := 0 to Count - 1 do
   begin
     if Line < ALine + TxRTFPara(Items[i]).LinesCount then
      begin
        Result := TxRTFPara(Items[i]).LineOffset(Line - ALine);
        exit;
      end;
     ALine := ALine + TxRTFPara(Items[i]).LinesCount;
   end;
  Result := 0;
end;}

procedure TxRTFBlock.AddParagraph(const s: string);
var
  Para: TxRTFTextPara;
begin
  Fnt := RTFFile.CurrentFont;

  if ReadingTableRow then
    Para := TxRTFTableRow(LastItem).CreateTextPara
  else
    Para := TxRTFTextPara.CreateChild(self);

  Para.Info := RTFFile.CurrentParaInfo;
  Para.Fnt := RTFFile.CurrentFont;

  if ReadingTableRow then
    TxRTFTableRow(LastItem).AddParagraph(Para)
  else
    AddData(Para);

  if s <> '' then
    Para.Append(s, RTFFile.CurrentFont);
end;

procedure TxRTFBlock.AddChar(ch: Char); { adds chars to last para }
begin
  RTFFile.CurrentPara := RTFFile.CurrentPara + ch;
  if length(RTFFile.CurrentPara) > 100 then
    FlushPara(false);
end;

procedure TxRTFBlock.FormattingChanging; { while appending - internal }
begin
  if RTFFile.CurrentPara <> '' then
    FlushPara(false);
end;

procedure TxRTFBlock.StartTable(Inherite: Boolean);
var
  Tbl: TxRTFTableRow;
begin
  if Inherite then
   begin
     if RTFFile.LastLoadedTableRow = nil then
       exit; { probably RTF format error }
     Tbl := TxRTFTableRow.CreateChild(self);
     Tbl.CopyStructure(RTFFile.LastLoadedTableRow);
     AddData(Tbl);
     ReadingTableRow := true;
     CellIsAdded := false;
     if not ForceNewPara then
      begin
        { move started para text to cell here }
        ForceNewPara := true;
      end;
   end
  else
   begin
     if (RTFFile.CurrentPara <> '') then
       FlushPara(true);
     ForceNewPara := true;
     ReadingTableRow := true;
     Tbl := TxRTFTableRow.CreateChild(self);
     AddData(Tbl);
     CellIsAdded := false;
   end;
  if ReadingTableRow then
    RTFFile.LastLoadedTableRow := Tbl;
end;

procedure TxRTFBlock.CheckCellIsAdded;
begin
  if ReadingTableRow then
   begin
     if not CellIsAdded then
      begin
        TxRTFTableRow(LastItem).AddCell;
        CellIsAdded := true;
      end;
   end;
end;

procedure TxRTFBlock.FlushPara(NewForce: Boolean);
begin
  if (RTFFile.CurrentPara = '') and ForceNewPara and not(NewForce) then exit;
  if (RTFFile.CurrentPara <> '') or ForceNewPara then
   begin
     if ForceNewPara then
       AddParagraph(RTFFile.CurrentPara)
     else
      begin
        LastTextPara.Append(RTFFile.CurrentPara, RTFFile.CurrentFont);
        UpdateParaInfo;
      end;
   end;
  RTFFile.CurrentPara := '';
  ForceNewPara := NewForce;
end;

function TxRTFBlock.GetLastTextPara: TxRTFTextPara;
begin
  if ForceNewPara then
   begin
     AddParagraph(RTFFile.CurrentPara);
     ForceNewPara := false;
   end;
  if ReadingTableRow then
    Result := TxRTFTableRow(LastItem).GetLastTextPara
  else
    Result := TxRTFTextPara(LastItem);
end;

procedure TxRTFBlock.SetDefaults;
begin
  SetDefaultFont(RTFFile.CurrentFont);
end;

procedure TxRTFBlock.StartNewPara;
begin
  Fnt := RTFFile.CurrentFont;
  FlushPara(true);
end;

procedure TxRTFBlock.ClearPara;
begin
  RTFFile.CurrentPara := '';
end;

procedure TxRTFBlock.ClosePara;
begin
  if not ForceNewPara then
    UpdateParaInfo;
  if RTFFile.CurrentPara <> '' then
    FlushPara(true);
  ForceNewPara := true;
end;

procedure TxRTFBlock.ClosePicture;
begin
  GlobalUnlock(RTFFile.CurrentPict.DataHandle);
  if RTFFile.CurrentPara <> '' then
    FlushPara(false);
  LastTextPara.AddPict(RTFFile.CurrentPict);
end;

procedure TxRTFBlock.StartField;
begin
{  if RTFFile.CurrentPara <> '' then}
    FlushPara(false);
  RTFFile.CurrentField := TxRTFField.CreateChild(LastTextPara);
  RTFFile.CurrentField.Fnt := RTFFile.CurrentFont;
  LastTextPara.AddData(RTFFile.CurrentField);
end;

procedure TxRTFBlock.CloseField;
begin
  RTFFile.CurrentField.RegisterResult;
  RTFFile.CurrentField.RegisterField;
end;

procedure TxRTFBlock.UpdateParaInfo;
begin
  if not ForceNewPara then
   begin
     if ReadingTableRow then
       TxRTFTableRow(LastItem).UpdateParaInfo(RTFFile.CurrentParaInfo)
     else
      TxRTFPara(LastItem).Info := RTFFile.CurrentParaInfo;
   end;
end;

procedure TxRTFBlock.ResetFnt;
begin
  FormattingChanging;
  SetDefaultFont(RTFFile.CurrentFont);
(*.  with RTFFile.CurrentFont do
   begin
     FontNum := RTFFile.Header.DefaultFont;
     Size := 20; { ? }
     Style := [];
     Underline := 1; { this line has no sufficient sence in this version }
     Caps := 0;
     SCaps := 0;
     Sub := 0;;
     Sup := 0;
     Outline := 0;
     Shadow := 0;
   end;*)
end;

procedure TxRTFBlock.ResetParaInfo;
begin
  with RTFFile.CurrentParaInfo do
   begin
     FirstLine := 0;
     LeftIndent := 0;
     RightIndent := 0;
     SpaceBefore := 0;
     SpaceAfter := 0;
     SpaceBetweenLines := 0;
     MultipleLineSpacing := 1;
     Style := 0;
     Hyphenate := false;
     Intact := false; { ? }
     WithNext := false;
     OutlineLevel := 0;
     BBPage := false;
     SideBySide := false; { ? }
     Align := alLeft;
     Shading := 0;
     ForeColor := DefForeColor;
     BKColor := DefBKColor;
     TabXNum := 0;
     TerminatePageAfterPara := false;
   end;

  if ReadingTableRow and
    (TxRTFTableRow(LastItem).CurrentCell < TxRTFTableRow(LastItem).Count) then
   begin
     with TxRTFTableRow(LastItem).CurrentCellItem.Info do
      begin
        RTFFile.CurrentParaInfo.Shading := Shading;
        RTFFile.CurrentParaInfo.ForeColor := ForeColor;
        RTFFile.CurrentParaInfo.BKColor := BKColor;
      end;
   end;
end;

procedure TxRTFBlock.ResetPictInfo;
begin
  with RTFFile.CurrentPict do
   begin
     PictType := '';
     PictTypeN := 0;
     PicWidth := 0;
     PicHeight := 0;
     DesiredWidth := 0;
     DesiredHeight := 0;
     ScaleX := 100;
     ScaleY := 100;
     Scaled := false;
     TopCrop := 0;
     BottomCrop := 0;
     LeftCrop := 0;
     RightCrop := 0;
     BMPinMetafile := false;
     BitsPerPixel := 1;
     BinDataSize := -1; { by default is hex data }

     DataHandle := GlobalAlloc(GMEM_MOVEABLE, MemAllocStep);
     DataPointer := GlobalLock(DataHandle);
     DataRead := 0;
     DataSize := MemAllocStep;
   end;
end;

function TxRTFBlock.LineHeight(Line: LongInt): LongInt;
var
  ALine: LongInt;
  i: LongInt;
begin
  ALine := 0;
  for i := 0 to Count - 1 do
   begin
     if Line < ALine + TxRTFPara(Items[i]).LinesCount then
      begin
        Result := TxRTFPara(Items[i]).LineHeight(Line - ALine);
        exit;
      end;
     ALine := ALine + TxRTFPara(Items[i]).LinesCount;
   end;
  Result := 0;
end;

function TxRTFBlock.LastLineOnPage(Line: LongInt): Boolean;
var
  ALine: LongInt;
  i: LongInt;
begin
  ALine := 0;
  for i := 0 to Count - 1 do
   begin
     if Line < ALine + TxRTFPara(Items[i]).LinesCount then
      begin
        if Items[i] is TxRTFBlock then
          Result := TxRTFBlock(Items[i]).LastLineOnPage(Line - ALine)
        else
          Result := TxRTFPara(Items[i]).Info.TerminatePageAfterPara;
        exit;
      end;
     ALine := ALine + TxRTFPara(Items[i]).LinesCount;
   end;
  Result := false;
end;

procedure TxRTFBlock.ReadData(Reader: TReader);
begin
  inherited ReadData(Reader);
end;

procedure TxRTFBlock.WriteData(Writer: TWriter);
begin
  inherited WriteData(Writer);
end;

procedure TxRTFBlock.Clear;
begin
  FormFields.Clear;
  inherited Clear;
  RTFFile.CurrentPara := '';
  ResetFnt;
  ResetPictInfo;
  ResetParaInfo;
end;

procedure TxRTFBlock.Assign(From: TxRTFBasic);
begin
  inherited Assign(From);
  ForceNewPara := TxRTFBlock(From).ForceNewPara;
end;

procedure TxRTFBlock.JoinBlock(From: TxRTFBlock);
var
  i: Integer;
  AnRTF: TxRTFBasic;
begin
  for i := 0 to From.Count - 1 do
   begin
     AnRTF := CreateRTFSubclass(From.Items[i].ClassName, From.Items[i]);
     AddData(AnRTF);
     AnRTF.Assign(From.Items[i]);
   end;
  Change;
end;

function TxRTFBlock.FirstPara: TxRTFPara;
begin
  Result := nil;

  if Count = 0 then  exit;

  if Items[0] is TxRTFBlock then
    Result := TxRTFBlock(Items[0]).FirstPara
  else if Items[0] is TxRTFPara then
    Result := TxRTFPara(Items[0]);
end;

function TxRTFBlock.LastPara: TxRTFPara;
begin
  Result := nil;

  if Count = 0 then exit;

  if LastItem is TxRTFBlock then
    Result := TxRTFBlock(LastItem).FirstPara
  else if LastItem is TxRTFPara then
    Result := TxRTFPara(LastItem);
end;

function TxRTFBlock.NextParaRef(From: TxRTFPara): TxRTFPara;
var
  Index: Integer;
  s: string;
begin
  Result := nil;

  Index := Data.IndexOf(From);
  if Index = Count - 1 then
   begin
     if self is TxRTFFile then
       Result := nil
     else
       Result := TxRTFBlock(Owner).NextParaRef(self);
   end
  else
   begin
     if Items[Index + 1] is TxRTFBlock then
       Result := TxRTFBlock(Items[Index + 1]).FirstPara
     else if Items[Index + 1] is TxRTFPara then
       Result := Items[Index + 1] as TxRTFPara;
   end;

  if Result <> nil then
    s := Result.ClassName;
end;

function TxRTFBlock.PrevParaRef(From: TxRTFPara): TxRTFPara;
var
  Index: Integer;
begin
  Result := nil;

  Index := Data.IndexOf(From);
  if Index = 0 then
   begin
     if self is TxRTFFile then
       Result := nil
     else
       Result := TxRTFBlock(Owner).PrevParaRef(self);
   end
  else
   begin
     if Items[Index - 1] is TxRTFBlock then
       Result := TxRTFBlock(Items[Index - 1]).LastPara
     else if Items[Index - 1] is TxRTFPara then
       Result := Items[Index - 1] as TxRTFPara;
   end;
end;

procedure TxRTFBlock.AddFormField(Fld: TxRTFField);
begin
  FormFields.Add(Fld);
  if not(self is TxRTFFile) then
    OwnerBlock.AddFormField(Fld);
end;

function TxRTFBlock.PageStartHeight(FirstLine: LongInt): LongInt;
var
  ALine: LongInt;
  i: LongInt;
begin
  Result := -1;

  ALine := 0;
  for i := 0 to Count - 1 do
   begin
     if FirstLine < ALine + TxRTFPara(Items[i]).LinesCount then
      begin
        Result := TxRTFPara(Items[i]).PageStartHeight(FirstLine - ALine);
        exit;
      end;
     ALine := ALine + TxRTFPara(Items[i]).LinesCount;
   end;
end;

procedure TxRTFBlock.StartPage(Opt: TDrawOptions);
var
  ALine: LongInt;
  i: LongInt;
begin
  ALine := 0;
  for i := 0 to Count - 1 do
   begin
     if Opt.From < ALine + TxRTFPara(Items[i]).LinesCount then
      begin
        Opt.From := Opt.From - ALine;
        TxRTFPara(Items[i]).StartPage(Opt);
        exit;
      end;
     ALine := ALine + TxRTFPara(Items[i]).LinesCount;
   end;
end;

procedure TxRTFBlock.WriteRTF(Writer: TxRTFWriter);
begin
  inherited WriteRTF(Writer);
end;


{ ======== TxRTFHeaderFooter ========== }

procedure TxRTFHeaderFooter.DrawHdrFtr(Opt: TDrawOptions);
var
  SubOpt: TDrawOptions;
begin
  RTFFile.SetCanvasFont;
  try
    SubOpt := Opt;
    Opt.Cmd := dcDrawWhole;
    Opt.From := 0;
    Opt.Till := LinesCount + 1;
    Draw(Opt);
  finally
    RTFFile.RestoreCanvasFont;
  end;
end;

{ ======== TxRTFFont ========== }

procedure TxRTFFont.ReadData(Reader: TReader);
begin
  FontNum := Reader.ReadInteger;
  Family := Reader.ReadString;
  CharSet := Reader.ReadInteger;
  Name := Reader.ReadString;
  Pitch := Reader.ReadInteger;
end;

procedure TxRTFFont.WriteData(Writer: TWriter);
begin
  Writer.WriteInteger(FontNum);
  Writer.WriteString(Family);
  Writer.WriteInteger(CharSet);
  Writer.WriteString(Name);
  Writer.WriteInteger(Pitch);
end;

procedure TxRTFFont.Assign(From: TxRTFFont);
begin
  FontNum := From.FontNum;
  Family := From.Family;
  CharSet := From.CharSet;
  Name := From.Name;
  Pitch := From.Pitch;
end;

{ ======== TxRTFFile ========== }

constructor TxRTFFile.Create;
begin
  inherited CreateChild(nil);
  Scale := 1;
  RTFFile := self;
  InFontsStack := 0;
  RTFFile := self;
  Loading := false;
  FontList := TClasslist.Create;
  Drawing := false;
  SetDefaults;
  Building := false;
  CanvasPPIX := 0;
  CanvasPPIY := 0;
  PageInfo := TClassList.Create;
  FOptions := [poShowPageBreaks];
  PageHeader := nil;
  PageFooter := nil;
  ProhibitDrawing := false;
  CurrentDestination := dsScreen; { by default draw on screen }
  SavedFontHandle := 0;
  SEQNumbers := TClassList.Create;
end;

destructor TxRTFFile.Destroy;
begin
  PageInfo.Free;
  FontList.Free;
  FreeObject(TObject(PageHeader));
  FreeObject(TObject(PageFooter));
  SEQNumbers.Free;
  inherited Destroy;
end;

procedure TxRTFFile.SetOptions(Value: TxRTFPreviewOptions);
var
  OldOpt: TxRTFPreviewOptions; 
begin
  OldOpt := FOptions; {it is needed 'cause refreshmargins will use new options }
  FOptions := Value;
  if ((poDrawLRMargins in Value) <> (poDrawLRMargins in OldOpt)) then
    RefreshMargins;
end;

procedure TxRTFFile.SetMinPos(Value: LongInt);
begin
  inherited SetMinPos(Value);
  { don't forget headers and footers; they do not use general numbering -
    thus we may assign zero to their MinPos property: }
  if PageHeader <> nil then
    PageHeader.SetMinPos(0);
  if PageFooter <> nil then
    PageFooter.SetMinPos(0);
end;

// finds page with the given index
function TxRTFFile.FindHoldingPage(Shift: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to PageInfo.Count - 1 do
   if (Shift >= TxRTFPage(PageInfo[i]).FirstLine) and
      (Shift <= TxRTFPage(PageInfo[i]).LastLine) then
    begin
      Result := i;
      exit; // would be faster
    end;
end;

procedure TxRTFFile.DrawPageBackground(PageRect: TRect);
var
  aBrush: HBrush;
begin
  aBrush := CreateSolidBrush(ColorToRGB(clWhite));
  try
    FillRect(iCanvashandle, PageRect, aBrush);
  finally
    DeleteObject(aBrush);
  end;
end;

procedure TxRTFFile.DrawOutside(const DrawRect, PageRect: TRect);
var
  aBrush: HBrush;
  SwapRect: TRect;
begin
  { fill background around the page }
  aBrush := CreateSolidBrush(ColorToRGB(clGray));
  try
    { left margin }
    SetRect(SwapRect, DrawRect.Left, 0, PageRect.Left,
      DrawRect.Bottom);
    FillRect(iCanvasHandle, SwapRect, aBrush);

    { right margin }
    SetRect(SwapRect, PageRect.Right, 0, DrawRect.Right,
      DrawRect.Bottom);
    FillRect(iCanvasHandle, SwapRect, aBrush);

    { top margin }
    SetRect(SwapRect, 0, DrawRect.Top, DrawRect.Right, PageRect.Top - 1);
    FillRect(iCanvasHandle, SwapRect, aBrush);

    { bottom margin }
    SetRect(SwapRect, 0, PageRect.Bottom + 1, DrawRect.Right,
      DrawRect.Bottom);
    FillRect(iCanvasHandle, SwapRect, aBrush);
  finally
    DeleteObject(aBrush);
  end;
end;

procedure TxRTFFile.DrawPageFinishing(const Opt: TDrawOptions; PageRect: TRect;
  DrawPageSeparator: Boolean);
var
  SwapRect: TRect;
  aBrush: HBrush;
begin
  // print footer if any
  if PageFooter <> nil then
   begin
     inc(Position.Y, HeaderFooterGap);
     PageFooter.DrawHdrFtr(Opt);
   end;

  { Draw Page separating line and bottom margin (if neccessary) }
  if (poShowPageBreaks in Options) then
   begin
     if poDrawTBMargins in Options then
       inc(Position.Y, TwipsToPixelsY(DocFormat.BottomMargin))
     else
       inc(Position.Y, 1);

     if DrawPageSeparator then
      begin
        { fill background around the page }
        aBrush := CreateSolidBrush(ColorToRGB(clGray));
        try
           { left margin }
           SetRect(SwapRect, PageRect.Left - 1, Position.Y, PageRect.Right,
             Position.Y + 30);
           FillRect(iCanvasHandle, SwapRect, aBrush);
           inc(Position.Y, 30);
        finally
          DeleteObject(aBrush);
        end;
      end;
   end;
end;

procedure TxRTFFile.DrawPageBeginning(const Opt: TDrawOptions; PageRect: TRect;
  PageIndex: Integer);
var
  SwapPositionY: Integer;
  SubOpt: TDrawOptions;
begin
  // remember original position of page start
  SwapPositionY := Position.Y;

  // draw header
  if PageHeader <> nil then
   begin
     // leave space if margins are drawn
     if poDrawTBMargins in Options then
       inc(Position.Y, TwipsToPixelsY(DocFormat.HeaderY));

     // print header
     PageHeader.DrawHdrFtr(Opt);

     // leave space for the case margins are not drawn
     inc(Position.Y, HeaderFooterGap);
   end;

  // organize gap
  if (poShowPageBreaks in Options) then
   begin
     if poDrawTBMargins in Options then
       Position.Y := SwapPositionY + TwipsToPixelsY(DocFormat.TopMargin)
     else
       Position.Y := Position.Y + 2;
   end;

  // draw the rest of the page beginning
  SubOpt := Opt;
  SubOpt.From := MaxInt(Opt.From, TxRTFPage(PageInfo[PageIndex]).FirstLine);
  SubOpt.Till := SubOpt.From;
  StartPage(SubOpt);
end;

function TxRTFFile.DrawPageBody(Opt: TDrawOptions; PageIndex: Integer): TDrawResult;
var
  SubOpt: TDrawOptions;
begin
  // draw the body text of this page (only)
  SubOpt := Opt;
  SubOpt.From := MaxInt(Opt.From, TxRTFPage(PageInfo[PageIndex]).FirstLine);
  SubOpt.Till := TxRTFPage(PageInfo[PageIndex]).LastLine;
  Result := Draw(SubOpt);
end;

procedure TxRTFFile.DrawTextBoundaries(Opt: TDrawOptions);
var
  aPen, oldPen: THandle;
begin
  if poShowSides in Options then
   begin
     aPen := CreatePen(PS_SOLID, 1, ColorToRGB(clTeal));
     OldPen := SelectObject(iCanvasHandle, aPen);
     try
       xLine(iCanvasHandle,
         Point(ScaleMe(FLeftMargin) - Opt.HShift - 1, Opt.DrawRect.Top),
         Point(ScaleMe(FLeftMargin) - Opt.HShift - 1, Opt.DrawRect.Bottom));
       xLine(iCanvasHandle,
         Point(ScaleMe(FLeftMargin) - Opt.HShift + ScaleMe(FDrawWidth) + 1, Opt.DrawRect.Top),
         Point(ScaleMe(FLeftMargin) - Opt.HShift + ScaleMe(FDrawWidth) + 1, Opt.DrawRect.Bottom));
     finally
       SelectObject(iCanvasHandle, OldPen);
       DeleteObject(aPen);
     end;
   end;
end;

procedure TxRTFFile.DrawContinuousPages(Opt: TDrawOptions);
var
  i: LongInt;
  PageRect: TRect;
begin
  // position is measured relative to top left corner of the page
  Position := Point(0, 0);
  TheDate := Now;

  IntersectRect(PageRect, Opt.DrawRect,
    Rect(-Opt.HShift, 0, ScaleMe(PageFullWidth) - Opt.HShift, Opt.DrawRect.Bottom));

  DrawPageBackground(PageRect);

  DrawOutside(Opt.DrawRect, PageRect);

  DrawTextBoundaries(Opt);

  for i := 0 to PageInfo.Count - 1 do
   if (Opt.From <= TxRTFPage(PageInfo[i]).LastLine) then
    begin
      PageInPrint := i + 1;
      OriginalOpt := Opt;

      // did last page ended?
      if (Opt.From < TxRTFPage(PageInfo[i]).FirstLine) then
       DrawPageFinishing(Opt, PageRect, true);

      // draw page header if neccessary
      if (Opt.From <= TxRTFPage(PageInfo[i]).FirstLine) then
        DrawPageBeginning(Opt, PageRect, i);

      DrawPageBody(Opt, i);

      // check if all pages are drawn
      if Position.Y > Opt.DrawRect.Bottom then exit;
    end;
end;

procedure TxRTFFile.DrawSinglePage(Opt: TDrawOptions);
var
  PageRect: TRect;
  PageW, PageH: Integer;
begin
  // position is measured relative to top left corner of the page
  TheDate := Now;

  PageH := ScaleMe(PageFullHeight);
  Position := Point(0,
    Opt.DrawRect.Top + (Opt.DrawRect.Bottom - Opt.DrawRect.Top - PageH) div 2);

  PageW := ScaleMe(PageFullWidth);
  Opt.HShift := Opt.HShift - (Opt.DrawRect.Right - Opt.DrawRect.Left - PageW) div 2;

  { Next, we set page rectangle and clip it with available rectangle
    Actually, page must be aready inside the rect, but better check }
  IntersectRect(PageRect, Opt.DrawRect,
    Rect(-Opt.HShift, Position.Y, PageW - Opt.HShift, Position.Y + PageH));

  DrawPageBackground(PageRect);

  DrawOutside(Opt.DrawRect, PageRect);

  DrawTextBoundaries(Opt);

  // search the page to draw
  PageInPrint := FindHoldingPage(Opt.From) + 1;
  if PageInPrint < 1 then exit;

  OriginalOpt := Opt;

  Opt.From := TxRTFPage(PageInfo[PageInPrint - 1]).FirstLine;
  Opt.Till := TxRTFPage(PageInfo[PageInPrint - 1]).LastLine;

  // draw page header
  DrawPageBeginning(Opt, PageRect, PageInPrint - 1);

  // draw page
  DrawPageBody(Opt, PageInPrint - 1);

  // draw footer
  DrawPageFinishing(Opt, PageRect, false);
end;

procedure TxRTFFile.DrawMultiplePages(Opt: TDrawOptions);
var
  PageH, PageW: Integer;
  InRow, InCol: Integer;
  PageHShift, PageVShift: Integer;
  i, j: Integer;
  SubOpt: TDrawOptions;
  FirstPage, NextPage: Integer;
begin
  PageW := ScaleMe(PageFullWidth);
  PageH := ScaleMe(PageFullHeight);

  if PageW <> 0 then
    InRow := (Opt.DrawRect.Right - Opt.DrawRect.Left) div (PageW * 11 div 10)
  else
    InRow := 0;

  if PageH <> 0 then
    InCol := (Opt.DrawRect.Bottom - Opt.DrawRect.Top) div (PageH * 11 div 10)
  else
    InCol := 0;

  if ((InRow <= 1) and (InCol <= 1)) or (InCol = 0) or (InRow = 0) then
    DrawContinuousPages(Opt)
  else
   begin
     // crear drawing region
     DrawOutside(Opt.DrawRect, Rect(0, 0, 0, 0));

     // steps between separate pages
     PageHShift := (Opt.DrawRect.Right - Opt.DrawRect.Left) div InRow;
     PageVShift := (Opt.DrawRect.Bottom - Opt.DrawRect.Top) div InCol;

     FirstPage := FindHoldingPage(Opt.From);

     for i := 0 to InCol - 1 do
      for j := 0 to InRow - 1 do
       begin
         NextPage := FirstPage + i * InRow + j;
         if NextPage < PageInfo.Count then
          begin
            SubOpt := Opt;
            SubOpt.From := TxRTFPage(PageInfo[NextPage]).FirstLine;
            SubOpt.Till := TxRTFPage(PageInfo[NextPage]).LastLine;
            SubOpt.DrawRect :=
              Rect(Opt.DrawRect.Left + PageHShift * j,
                   Opt.DrawRect.Top + PageVShift * i,
                   Opt.DrawRect.Left + PageHShift * (j + 1),
                   Opt.DrawRect.Top + PageVShift * (i + 1));
            Position := Subopt.DrawRect.TopLeft;
            SubOpt.HShift := - PageHShift * j;
            DrawSinglePage(SubOpt);
          end;
       end;
   end;
end;

function TxRTFFile.DrawRTF(Opt: TDrawOptions; Continuous: Boolean): TDrawResult;
begin
  if iCanvasHandle = 0 then exit;

  if ProhibitDrawing then exit; { someone has prohibited any drwings through DrawRTF }

  if Building then exit;
  CheckIsBuilt;

  SetCanvasFont;
  try
    if Continuous then
      DrawContinuousPages(Opt)
    else
      DrawMultiplePages(Opt);
  finally
    RestoreCanvasFont;
  end;
end;

function TxRTFFile.FindFont(Nom: LongInt): TxRTFFont;
var
  i: LongInt;
begin
  i := 0;
  while (i < FontList.Count) and (TxRTFFont(FontList[i]).FontNum <> Nom) do
    inc(i);
  if (i < 0) or (i >= FontList.Count) then
    raise ExRTFFile.Create('В RTF файле использован необьявленный щрифт.');
  Result := TxRTFFont(FontList[i]);
end;

function TxRTFFile.FindFontNum(Name: string): Integer;
var
  i: LongInt;
begin
  i := 0;
  while (i < FontList.Count) and (TxRTFFont(FontList[i]).Name <> Name) do
    inc(i);
  if (i < 0) or (i >= FontList.Count) then
    Result := 0
  else
    Result := TxRTFFont(FontList[i]).FontNum;
end;

procedure TxRTFFile.CheckWord(AWord: TxRTFControlWord; ShouldBe: string);
begin
  if AWord.CWord <> ShouldBe then
    raise ExRTFFile.Create('File is corrupt.');
end;

procedure TxRTFFile.NewControlWord(Reader: TxRTFReader;
  AWord: TxRTFControlWord);
var
{.  i: LongInt;
  NewHandle: THandle;
  NewPointer: Pointer;
  NewSize: LongInt;
  DataNext: PByte;}
  Index: Integer;
  Recognised: Boolean;
begin
  Recognised := false;

  if ReaderState in [rsNoSpecial, rsHeader, rsFooter, rsFldRslt] then
   begin
     Recognised := true;

     if AWord.CWord = 'pard' then
      begin
        {CurrentBlock.ResetFnt; { should this be done ? }
        CurrentBlock.ResetParaInfo;
      end

     else if AWord.CWord = 'tab' then
      CurrentBlock.AddChar(#9)

     else if AWord.CWord = 'emdash' then
      CurrentBlock.AddChar(#151)

     else if AWord.CWord = 'endash' then
      CurrentBlock.AddChar(#150)

     else if AWord.CWord = 'lquote' then
      CurrentBlock.AddChar(#145)

     else if AWord.CWord = 'rquote' then
      CurrentBlock.AddChar(#146)

     else if AWord.CWord = 'ldblquote' then
      CurrentBlock.AddChar(#147)

     else if AWord.CWord = 'rdblquote' then
      CurrentBlock.AddChar(#148)

     else if AWord.CWord = 'bullet' then
      CurrentBlock.AddChar(#149)

     else if AWord.CWord = 'plain' then
      begin
        CurrentBlock.ResetFnt;
        StrPCopy(CurrentFont.lfFaceName,
          FindFont(Header.DefaultFont).Name);
      end

     else if AWord.CWord = 'b' then
      begin
        CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.lfWeight := FW_NORMAL
        else
          CurrentFont.lfWeight := FW_BOLD
      end

     else if AWord.CWord = 'caps' then
      begin
        (*CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.Caps := 0
        else
          CurrentFont.Caps := 1;*)
      end

     else if AWord.CWord = 'scaps' then
      begin
        (*CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.SCaps := 0
        else
          CurrentFont.SCaps := 1;*)
      end

     else if AWord.CWord = 'sub' then
      begin
        (*CurrentBlock.FormattingChanging;
        CurrentFont.Sub := 1;*)
      end

     else if AWord.CWord = 'super' then
      begin
        (*CurrentBlock.FormattingChanging;
        CurrentFont.Sup := 1;*)
      end

     else if AWord.CWord = 'nosupersub' then
      begin
        (*CurrentBlock.FormattingChanging;
        CurrentFont.Sub := 0;
        CurrentFont.Sup := 0;*)
      end

     else if AWord.CWord = 'i' then
      begin
        CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.lfItalic := 0
        else
          CurrentFont.lfItalic := 1;
      end

     else if AWord.CWord = 'outl' then
      begin
        (*CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.Outline := 0
        else
          CurrentFont.Outline := 1;*)
      end

     else if AWord.CWord = 'shad' then
      begin
        {.CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.Shadow := 0
        else
          CurrentFont.Shadow := 1;}
      end

     else if AWord.CWord = 'strike' then
      begin
        CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.lfStrikeOut := 0
        else
          CurrentFont.lfStrikeOut := 1;
      end

     else if AWord.CWord = 'ul' then
      begin
        CurrentBlock.FormattingChanging;
        if AWord.Value = '0' then
          CurrentFont.lfUnderline := 0
        else
          CurrentFont.lfUnderline := 1;
        {CurrentFont.Underline := 1;}
      end

     else if AWord.CWord = 'uld' then
      begin
        CurrentBlock.FormattingChanging;
        CurrentFont.lfUnderline := 1
        {CurrentFont.Underline := 2;}
      end

     else if AWord.CWord = 'uldb' then
      begin
        CurrentBlock.FormattingChanging;
        CurrentFont.lfUnderline := 1;
        {CurrentFont.Underline := 3;}
      end

     else if AWord.CWord = 'ulw' then
      begin
        CurrentBlock.FormattingChanging;
        CurrentFont.lfUnderline := 1;
        {CurrentFont.Underline := 4;}
      end

     else if AWord.CWord = 'ulnone' then
      begin
        CurrentBlock.FormattingChanging;
        CurrentFont.lfUnderline := 0;
      end

     else if AWord.CWord = 'f' then
      begin
        CurrentBlock.FormattingChanging;
        StrPCopy(CurrentFont.lfFaceName,
          FindFont(StrToInt(AWord.Value)).Name);
      end

     else if AWord.CWord = 'fs' then
      begin
        CurrentBlock.FormattingChanging;
        CurrentFont.lfHeight := - StrToInt(AWord.Value) * 10;
      end

     else
       Recognised := false;
   end;

  if (ReaderState in [rsNoSpecial, rsHeader, rsFooter]) and
     not(Recognised) then
   begin
     if StrInArray(AWord.CWord, ['par', 'page']) then
      begin
        if AWord.CWord = 'page' then
          CurrentParaInfo.TerminatePageAfterPara := true;
        CurrentBlock.StartNewPara;
        if not(ReaderState in [rsHeader, rsFooter]) then
          NextParaLoaded;
        CurrentParaInfo.TerminatePageAfterPara := false;
      end

     else if AWord.CWord = 'fi' then
      begin
        CurrentParaInfo.FirstLine := StrToInt(AWord.Value)
      end

     else if AWord.CWord = 'shading' then
       CurrentParaInfo.Shading := StrToInt(AWord.Value)

     else if AWord.CWord = 'tx' then
      begin
        CurrentParaInfo.TabX[
          CurrentParaInfo.TabXNum] := StrToInt(AWord.Value);
        inc(CurrentParaInfo.TabXNum);
      end

     else if AWord.CWord = 'cfpat' then
      begin
        Index := StrToInt(AWord.Value);
        if (Index > ColorsInTable) or (Index < 0) then
          Index := 0;
        CurrentParaInfo.ForeColor := ColorTable[Index];
      end

     else if AWord.CWord = 'cbpat' then
      begin
        Index := StrToInt(AWord.Value);
        if (Index > ColorsInTable) or (Index < 0) then
          Index := 0;
        CurrentParaInfo.BKColor := ColorTable[Index];
      end

     else if AWord.CWord = 'li' then
        CurrentParaInfo.LeftIndent := StrToInt(AWord.Value)

     else if AWord.CWord = 'ri' then
        CurrentParaInfo.RightIndent := StrToInt(AWord.Value)

     else if AWord.CWord = 'sb' then
        CurrentParaInfo.SpaceBefore := StrToInt(AWord.Value)

     else if AWord.CWord = 'sa' then
        CurrentParaInfo.SpaceAfter := StrToInt(AWord.Value)

     else if AWord.CWord = 'sl' then
        CurrentParaInfo.SpaceBetweenLines := StrToInt(AWord.Value)

     else if AWord.CWord = 'slmult' then
        CurrentParaInfo.MultipleLineSpacing := StrToInt(AWord.Value)

     else if AWord.CWord = 's' then
        CurrentParaInfo.Style := StrToInt(AWord.Value)

     else if AWord.CWord = 'hyphpar' then
        CurrentParaInfo.Hyphenate := AWord.Value <> '0'

     else if AWord.CWord = 'keep' then
        CurrentParaInfo.Intact := true

     else if AWord.CWord = 'keepn' then
        CurrentParaInfo.WithNext := true

     else if AWord.CWord = 'level' then
        CurrentParaInfo.OutlineLevel := StrToInt(AWord.Value)

     else if AWord.CWord = 'pagebb' then
        CurrentParaInfo.BBPage := true

     else if AWord.CWord = 'sbys' then
        CurrentParaInfo.SideBySide := true

     else if AWord.CWord = 'ql' then
        CurrentParaInfo.Align := alLeft

     else if AWord.CWord = 'qr' then
        CurrentParaInfo.Align := alRight

     else if AWord.CWord = 'qc' then
        CurrentParaInfo.Align := alCentered

     else if AWord.CWord = 'qj' then
        CurrentParaInfo.Align := alJustified

     else if AWord.CWord = 'headery' then
       DocFormat.HeaderY := StrToInt(AWord.Value)

     else if AWord.CWord = 'footery' then
       DocFormat.FooterY := StrToInt(AWord.Value)

     else if AWord.CWord = 'paperw' then
       DocFormat.PaperWidth := StrToInt(AWord.Value)

     else if AWord.CWord = 'paperh' then
       DocFormat.PaperHeight := StrToInt(AWord.Value)

     else if AWord.CWord = 'margl' then
       DocFormat.LeftMargin := StrToInt(AWord.Value)

     else if AWord.CWord = 'margr' then
       DocFormat.RightMargin := StrToInt(AWord.Value)

     else if AWord.CWord = 'margt' then
       DocFormat.TopMargin := StrToInt(AWord.Value)

     else if AWord.CWord = 'margb' then
       DocFormat.BottomMargin := StrToInt(AWord.Value)

     else if AWord.CWord = 'landscape' then
       DocFormat.Landscape := true

     else if AWord.CWord = 'lndscpsxn' then
       DocFormat.Landscape := true

     else if AWord.CWord = 'pgnstart' then
       DocFormat.FirstPage := StrToInt(AWord.Value)

     else if AWord.CWord = 'trowd' then
       CurrentBlock.StartTable(false)

     else if AWord.CWord = 'intbl' then
      begin
        if not CurrentBlock.ReadingTableRow then
          CurrentBlock.StartTable(true)
      end

     else if AWord.CWord = 'trgaph' then
      begin
        if CurrentBlock.ReadingTableRow then
          TxRTFTableRow(CurrentBlock.LastItem).CellsSpace := StrToInt(AWord.Value)
        else { RTF-file error - ignoring }
      end

     else if AWord.CWord = 'trleft' then
      begin
        if CurrentBlock.ReadingTableRow then
          TxRTFTableRow(CurrentBlock.LastItem).LeftEdge := StrToInt(AWord.Value)
        else { RTF-file error - ignoring }
      end

     else if AWord.CWord = 'cellx' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.RightBound :=
             StrToInt(AWord.value);
           CurrentBlock.CellIsAdded := false;
         end;
      end

     else if AWord.CWord = 'clshdng' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.Shading :=
             StrToInt(AWord.value);
         end;
      end

     else if AWord.CWord = 'brdrw' then
      begin
        if LastBorder <> nil then
          LastBorder^.w := StrToInt(AWord.Value)
      end

     else if AWord.CWord = 'clbrdrl' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           LastBorder := @TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.LeftBorder;
           LastBorder^.w := DefaultBorderWidth;
         end;
      end

     else if AWord.CWord = 'clbrdrr' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           LastBorder := @TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.RightBorder;
           LastBorder^.w := DefaultBorderWidth;
         end;
      end

     else if AWord.CWord = 'clbrdrt' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           LastBorder := @TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.TopBorder;
           LastBorder^.w := DefaultBorderWidth;
         end;
      end

     else if AWord.CWord = 'clbrdrb' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           LastBorder := @TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.BottomBorder;
           LastBorder^.w := DefaultBorderWidth;
         end;
      end

     else if AWord.CWord = 'trbrdrt' then
       LastBorder := nil
     else if AWord.CWord = 'trbrdrl' then
       LastBorder := nil
     else if AWord.CWord = 'trbrdrb' then
       LastBorder := nil
     else if AWord.CWord = 'trbrdrr' then
       LastBorder := nil
     else if AWord.CWord = 'trbrdrh' then
       LastBorder := nil
     else if AWord.CWord = 'trbrdrv' then
       LastBorder := nil

     else if AWord.CWord = 'clcbpat' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           Index := StrToInt(AWord.Value);
           if (Index > ColorsInTable) or (Index < 0) then Index := 0;
           TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.BKColor :=
             ColorTable[Index];
         end;
      end

     else if AWord.CWord = 'clcfpat' then
      begin
        if CurrentBlock.ReadingTableRow then
         begin
           CurrentBlock.CheckCellIsAdded;
           Index := StrToInt(AWord.Value);
           if (Index > ColorsInTable) or (Index < 0) then Index := 0;
           TxRTFCell(TxRTFTableRow(CurrentBlock.LastItem).LastItem).Info.ForeColor :=
             ColorTable[Index];
         end;
      end

     else if AWord.CWord = 'cell' then
      begin
        CurrentBlock.StartNewPara;
        if CurrentBlock.ReadingTableRow then
          TxRTFTableRow(CurrentBlock.LastItem).GoNextCell;
      end

     else if AWord.CWord = 'row' then
      begin
        CurrentBlock.ClearPara;
        CurrentBlock.ReadingTableRow := false;
      end

     else if AWord.CWord = 'deff' then
      begin
        Header.DefaultFont := StrToInt(AWord.Value);
      end

     else if AWord.CWord = 'trhdr' then
      begin
        if CurrentBlock.ReadingTableRow then
          TxRTFTableRow(CurrentBlock.LastItem).IsHeader := true
        else { RTF file error };
      end;
     end;

  if ReaderState in [rsFontTbl] then
   begin
     if AWord.CWord = 'f' then
       CurrentTableFont.FontNum := StrToInt(AWord.Value)
   end;

  if ReaderState in [rsInfo] then
   begin
   end;

  if ReaderState in [rsPict] then
   begin
     if (AWord.CWord = 'macpict') or
        (AWord.CWord = 'pmmetafile') or
        (AWord.CWord = 'wmetafile') or
        (AWord.CWord = 'dibitmap') or
        (AWord.CWord = 'wbitmap') then
      begin
        CurrentPict.PictType := AWord.CWord;
        if AWord.Value <> '' then
          CurrentPict.PictTypeN := StrToInt(AWord.Value)
        else
          CurrentPict.PictTypeN := 0;
      end

     else if AWord.CWord = 'picw' then
       CurrentPict.PicWidth := StrToInt(AWord.Value)

     else if AWord.CWord = 'pich' then
       CurrentPict.PicHeight := StrToInt(AWord.Value)

     else if AWord.CWord = 'picwgoal' then
       CurrentPict.DesiredWidth := StrToInt(AWord.Value)

     else if AWord.CWord = 'pichgoal' then
       CurrentPict.Desiredheight := StrToInt(AWord.Value)

     else if AWord.CWord = 'picscalex' then
       CurrentPict.ScaleX := StrToInt(AWord.Value)

     else if AWord.CWord = 'picscaley' then
       CurrentPict.ScaleY := StrToInt(AWord.Value)

     else if AWord.CWord = 'picscaled' then
       CurrentPict.Scaled := true

     else if AWord.CWord = 'piccropt' then
       CurrentPict.TopCrop := StrToInt(AWord.Value)

     else if AWord.CWord = 'piccropb' then
       CurrentPict.BottomCrop := StrToInt(AWord.Value)

     else if AWord.CWord = 'piccropl' then
       CurrentPict.LeftCrop := StrToInt(AWord.Value)

     else if AWord.CWord = 'piccropr' then
       CurrentPict.RightCrop := StrToInt(AWord.Value)

     else if AWord.CWord = 'picbmp' then
       CurrentPict.BMPinMetafile := true

     else if AWord.CWord = 'picbpp' then
       CurrentPict.BitsPerPixel := StrToInt(AWord.Value)

{.     else if AWord.CWord = 'bin' then
      begin
       for i := 0 to StrToInt(AWord.Value) - 1 do
        begin
          with CurrentPict do
           begin
             if DataRead = DataSize then
              begin
                GlobalUnlock(DataHandle);
                NewHandle := GlobalReAlloc(DataHandle,
                  DataSize + MemAllocStep, GMEM_MOVEABLE);
                if NewHandle = 0 then
                  raise ExRTF.CreateChild('Failed to get memory from Windows.');
                DataHandle := NewHandle;
                NewPointer := GlobalLock(DataHandle);
                NewSize := GlobalSize(DataHandle);
                if DataSize >= NewSize then
                  raise ExRTF.CreateChild('Required memory was not allocated by Windows.');
                DataSize := NewSize;
                DataPointer := NewPointer;
              end;
             DataNext := Ptr(HiWord(LongInt(DataPointer)) + HiWord(DataRead) * Ofs(AHIncr),
                             LoWord(DataRead));
             DataNext^ := Byte(Reader.Items[0]);
             Reader.Skip(1);
           end;
          if RTFProgress.Terminated then
            exit;
        end;
       CurrentPict.DataRead := StrToInt(AWord.Value);
      end;}
   end;

  if ReaderState in [rsField, rsFldInst] then
   begin
     if AWord.CWord = 'flddirty' then
       CurrentField.IsDirty := true

     else if AWord.CWord = 'fldedit' then
       CurrentField.IsEdited := true

     else if AWord.CWord = 'fldlock' then
       CurrentField.IsEdited := true

     else if AWord.CWord = 'fldpriv' then
       CurrentField.IsFldPriv := true

     else if AWord.CWord = 'fldalt' then
       CurrentField.IsFldAlt := true

     else if AWord.CWord = 'formfield' then
       CurrentField.IsFormField := true

     else if AWord.CWord = 'fftype' then
       CurrentField.FFType := StrToInt(AWord.Value)

     else if AWord.CWord = 'fftypetxt' then
       CurrentField.FFTypeTxt := StrToInt(AWord.Value)
   end;

  if ReaderState in [rsColorTable] then
   begin
     if AWord.CWord = 'red' then
       CurrentColor.rgbtRed := StrToInt(AWord.Value)

     else if AWord.CWord = 'green' then
       CurrentColor.rgbtGreen := StrToInt(AWord.Value)

     else if AWord.CWord = 'blue' then
       CurrentColor.rgbtBlue := StrToInt(AWord.Value);
   end;
end;

procedure TxRTFFile.NewControlSymbol(AChar: Char);
begin
 { skip them in this version }
end;

procedure TxRTFFile.LoadPlainText(Reader: TxRTFReader);
var
  ch: Char;
  i: LongInt;
  slen: Integer;
  NewHandle: THandle;
  NewPointer: Pointer;
  NewSize: LongInt;
begin
  case ReaderState of
    rsNoSpecial, rsHeader, rsFooter:
      begin
        while Reader.Next = rtfPlainText do
         begin
           if RTFProgress.Terminated then exit;
           ch := Reader.ReadPlainTextChar;
           if ch >= #32 then
             CurrentBlock.AddChar(ch);
         end;
      end;

    rsFontTbl:
      begin
        ch := Reader.ReadPlainTextChar;
        if (ch >= #32) and (ch <> ';') then
          CurrentTableFont.Name := CurrentTableFont.Name + ch
        else if ch = ';' then
         begin
           FontList.Add(CurrentTableFont);
           CurrentTableFont := TxRTFFont.Create;
         end;
      end;

    rsInfo:
      begin
        Reader.ReadPlainTextChar;
        { skip }
      end;

    rsPict:
      begin
        while Reader.Next = rtfPlainText do
         begin
           with CurrentPict do
            begin
              if DataRead = DataSize then
               begin
                 GlobalUnlock(DataHandle);
                 NewHandle := GlobalReAlloc(DataHandle,
                   DataSize + MemAllocStep, GMEM_MOVEABLE);
                 if NewHandle = 0 then
                   raise ExRTF.Create('Failed to get memory from Windows.');
                 DataHandle := NewHandle;
                 NewPointer := GlobalLock(DataHandle);
                 NewSize := GlobalSize(DataHandle);
                 if DataSize >= NewSize then
                   raise ExRTF.Create('Required memory was not allocated by Windows.');
                 DataSize := NewSize;
                 DataPointer := NewPointer;
               end;
              PxByteArray(DataPointer)[DataRead] := Reader.ReadHex;
              inc(DataRead);
            end;
           if RTFProgress.Terminated then
             exit;
         end;
      end;

    rsFldInst:
      begin
        while Reader.Next = rtfPlainText do
         begin
           if RTFProgress.Terminated then exit;
           ch := Reader.ReadPlainTextChar;
           if ch >= #32 then
             CurrentField.Instruction :=
               StrAdd(CurrentField.Instruction, ch);
         end;
      end;

    rsFldRslt:
      begin
        CurrentField.Fnt := CurrentFont;
        while Reader.Next = rtfPlainText do
         begin
           if RTFProgress.Terminated then exit;
           ch := Reader.ReadPlainTextChar;
           if ch >= #32 then
             CurrentField.FieldResult :=
               StrAdd(CurrentField.FieldResult, ch);
         end;
      end;

    rsDataField:
      begin
        for i := 0 to 7 do
          CurrentField.DataField.Unknown[i] := Reader.ReadHex;

        CurrentField.DataField.Name := '';
        slen := Reader.ReadHex;
        for i := 1 to slen do
          CurrentField.DataField.Name :=
            CurrentField.DataField.Name + chr(Reader.ReadHex);


        CurrentField.DataField.Unknown1 := Reader.ReadHex;

        CurrentField.DataField.DefaultText := '';
        slen := Reader.ReadHex;
        for i := 1 to slen do
          CurrentField.DataField.DefaultText :=
            CurrentField.DataField.DefaultText + chr(Reader.ReadHex);

        while Reader.Next = rtfPlainText do
          Reader.ReadPlainTextChar; 
      end;

    rsFFName:
      begin
        while Reader.Next = rtfPlainText do
         begin
           if RTFProgress.Terminated then exit;
           ch := Reader.ReadPlainTextChar;
           if ch >= #32 then
             CurrentField.FFName :=
               CurrentField.FFName + ch;
         end;
      end;
    rsFFDefText:
      begin
        while Reader.Next = rtfPlainText do
         begin
           if RTFProgress.Terminated then exit;
           ch := Reader.ReadPlainTextChar;
           if ch >= #32 then
             CurrentField.FFDefText :=
               CurrentField.FFDefText + ch;
         end;
      end;
    rsColorTable:
      begin
        ch := Reader.ReadPlainTextChar;
        if (ch = ';') and (ColorsInTable < ColorTableSize) then
         begin
           ColorTable[ColorsInTable] := CurrentColor;
           CurrentColor := DefForeColor;
           inc(ColorsInTable);
         end; 
      end;
    else
      Reader.ReadPlainTextChar; { i.e. skip it }
  end;
end;

procedure TxRTFFile.LoadGroupBody(Reader: TxRTFReader;
  const GroupNameWord: TxRTFControlWord);
var
  OldReaderState: TReaderState;
  OldFnt: TLogFont;
  OldParaInfo: TxParaInfo;
  OldCurrentBlock: TxRTFBlock;

  procedure MakeDuplicates;
  begin
    OldReaderState := ReaderState;
    OldFnt := CurrentFont;
    OldParaInfo := CurrentParainfo;
    OldCurrentBlock := CurrentBlock;
  end;

  procedure RestoreFromDuplicates;
  begin
    if not(CompareFonts(OldFnt, CurrentFont)) and
       (ReaderState <> rsFontTbl) then
     begin
       CurrentBlock.FormattingChanging;
       CurrentFont := OldFnt;
     end;
    CurrentParaInfo := OldParaInfo;
    if ReaderState in [rsHeader, rsFooter] then
      CurrentBlock := OldCurrentBlock;
    ReaderState := OldReaderState;
  end;

begin
  MakeDuplicates;

  if GroupNameWord.CWord = 'fonttbl' then
   begin
     CurrentTableFont := TxRTFFont.Create;
     ReaderState := rsFontTbl;
   end

  else if GroupNameWord.CWord = 'info' then
   begin
     ReaderState := rsInfo;
   end

  else if GroupNameWord.CWord = 'pict' then
   begin
     CurrentBlock.ResetPictInfo;
     ReaderState := rsPict;
   end

  else if GroupNameWord.CWord = 'field' then
   begin
     CurrentBlock.StartField;
     ReaderState := rsField;
   end

  else if GroupNameWord.CWord = 'fldinst' then
   begin
     ReaderState := rsFldInst;
     StrPCopy(CurrentField.Instruction, '');
   end

  else if GroupNameWord.CWord = 'fldrslt' then
   begin
     ReaderState := rsFldRslt;
     StrPCopy(CurrentField.FieldResult, '');
   end

  else if GroupNameWord.CWord = 'ffname' then
   begin
     ReaderState := rsFFName;
     CurrentField.FFName := '';
   end

  else if GroupNameWord.CWord = 'ffdeftext' then
   begin
     ReaderState := rsFFDefText;
     CurrentField.FFDefText := '';
   end

  else if GroupNameWord.CWord = 'datafield' then
   begin
     ReaderState := rsDataField;
     CurrentField.IsDataField := true;
     CurrentField.DataField.Name := '';
   end

  else if GroupNameWord.CWord = 'header' then
   begin
     if PageHeader = nil then
      begin
        PageHeader := TxRTFHeaderFooter.CreateChild(self);
        CurrentBlock := PageHeader;
        ReaderState := rsHeader;
      end
     else
      begin
        MessageDlg('Your RTF file has more than one header (probably it ' +
         'has different types of headers for different pages).'#13 +
         'This program supports only one header for all document - all ' +
         'other headers will be ignored.', mtError, [mbIgnore], 0);
      end;
   end

  else if GroupNameWord.CWord = 'footer' then
   begin
     if PageFooter = nil then
      begin
        PageFooter := TxRTFHeaderFooter.CreateChild(self);
        CurrentBlock := PageFooter;
        ReaderState := rsFooter;
      end
     else
      begin
        MessageDlg('Your RTF file has more than one footer (probably it ' +
         'has different footers for different pages).'#13 +
         'This program supports only one footer for all document - all ' +
         'other footers will be ignored.', mtError, [mbIgnore], 0);
      end;
   end

  else if GroupNameWord.CWord = 'colortbl' then
   begin
     ReaderState := rsColorTable;
     CurrentColor := DefForeColor;
     ColorsInTable := 0;
   end

  else if GroupNameWord.CWord <> '' then
   begin
     NewControlWord(Reader, GroupNameWord);
   end;

  while Reader.Next <> rtfGroupEnd do
   begin
     case Reader.Next of
       rtfGroupStart: LoadGroup(Reader);
       rtfGroupEnd: Reader.ReadError;
       rtfDestination: LoadDestination(Reader);
       rtfControlWord: NewControlWord(Reader, Reader.ReadControlWord);
       rtfControlSymbol: NewControlSymbol(Reader.ReadControlSymbol);
       rtfPlainText: LoadPlainText(Reader);
     end;
     if RTFProgress.Terminated then exit;
   end;

  Reader.ReadGroupEnd;

  if ReaderState <> OldReaderState then
   begin
     case ReaderState of
       rsPict: CurrentBlock.ClosePicture;
       rsField: CurrentBlock.CloseField;
       rsFontTbl: StrPCopy(CurrentFont.lfFaceName,
                 FindFont(Header.DefaultFont).Name);
     end;
   end;

  RestoreFromDuplicates;
end;

procedure TxRTFFile.LoadGroup(Reader: TxRTFReader);
var
  AWord: TxRTFControlWord;
  Skip: Boolean;
begin
  Reader.Skip(1); { skip group start }
  if Reader.Next = rtfControlWord then
   begin
     Skip := false;
     AWord := Reader.ReadControlWord;
     if AWord.CWord = 'filetbl' then Skip := true;
     if AWord.CWord = 'stylesheet' then Skip := true;
     if AWord.CWord = 'revtbl' then Skip := true;

     if Skip then
      begin
        Reader.SkipTillGroupEnd;
        exit;
      end;
   end
  else
   AWord.CWord := '';

  LoadGroupBody(reader, AWord);
end;

procedure TxRTFFile.LoadDestination(Reader: TxRTFReader);
var
  AWord: TxRTFControlWord;
  Skip: Boolean;
begin
  Reader.Skip(3); { skip destination start }
  if Reader.Next = rtfControlWord then
   begin
     Skip := true;
     AWord := Reader.ReadControlWord;
     { mark destinations which are known by this version - all other
       destinations are ignored (RTF standard) }
     if AWord.CWord = 'fldinst' then Skip := false;
     if AWord.CWord = 'fldrslt' then Skip := false;
     if AWord.CWord = 'datafield' then Skip := false;
     if AWord.CWord = 'formfield' then Skip := false;
     if AWord.CWord = 'ffname' then Skip := false;
     if AWord.CWord = 'ffdeftext' then Skip := false;
     if AWord.CWord = 'header' then Skip := false;
     if AWord.CWord = 'footer' then Skip := false;

     if not Skip then
      begin
        LoadGroupBody(reader, AWord);
        exit;
      end;
   end;
  Reader.SkipTillGroupEnd;
end;

procedure TxRTFFile.LoadRTFDocument(Reader: TxRTFReader);
var
  AWord: TxRTFControlWord;
begin
  ReaderState := rsNoSpecial;

  AWord := Reader.ReadControlWord;
  CheckWord(AWord, 'rtf');
  Header.Version := StrToInt(AWord.Value);

  AWord := Reader.ReadControlWord;
  Header.CharSet := AWord.CWord;

  repeat
    case Reader.Next of
      rtfGroupStart: LoadGroup(Reader);
      rtfGroupEnd: Reader.ReadError;
      rtfDestination: LoadDestination(Reader);
      rtfControlWord: NewControlWord(Reader, Reader.ReadControlWord);
      rtfControlSymbol: NewControlSymbol(Reader.ReadControlSymbol);
      rtfPlainText: LoadPlainText(Reader);
    end;
    if RTFProgress.Terminated then exit;
  until Reader.Next = rtfGroupEnd; { i.e. end of file }
end;

procedure TxRTFFile.WriteRTF(Writer: TxRTFWriter);
begin
  inherited WriteRTF(Writer);
end;

procedure TxRTFFile.WriteRTFHeader(Writer: TxRTFWriter);
var
  i: Integer;
begin
  Writer.WriteShortWord('ansi');

  { save font table }
  Writer.StartGroup;
  Writer.WriteShortWord('fonttbl');
  for i := 0 to FontList.Count - 1 do
   begin
     Writer.StartGroup;
     Writer.WriteLongWord('f', TxRTFFont(FontList[i]).FontNum);
     Writer.WriteShortWord('fnil');
     Writer.WriteString(TxRTFFont(FontList[i]).Name + ';');
     Writer.EndGroup;
   end;
  Writer.EndGroup;

  { save color table }
  Writer.StartGroup;
  Writer.WriteShortWord('colortbl');
  for i := 0 to ColorsInTable - 1 do
   begin
     Writer.WriteLongWord('red', ColorTable[i].rgbtRed);
     Writer.WriteLongWord('green', ColorTable[i].rgbtGreen);
     Writer.WriteLongWord('blue', ColorTable[i].rgbtBlue);
     Writer.WriteString(';');
   end;
  Writer.EndGroup;

  { go to main text }
  { a. document formatting:}
  Writer.WriteLongWord('paperw', DocFormat.PaperWidth);
  Writer.WriteLongWord('paperh', DocFormat.PaperHeight);
  Writer.WriteLongWord('margl', DocFormat.LeftMargin);
  Writer.WriteLongWord('margr', DocFormat.RightMargin);
  Writer.WriteLongWord('margt', DocFormat.TopMargin);
  Writer.WriteLongWord('margb', DocFormat.BottomMargin);
  if DocFormat.Landscape then
    Writer.WriteShortWord('landscape');

  { b. section definition }
  Writer.WriteShortWord('sectd');
  Writer.WriteLongWord('headery', DocFormat.HeaderY);
  Writer.WriteLongWord('footery', DocFormat.FooterY);

  if PageHeader <> nil then
   begin
     Writer.StartGroup;
     Writer.WriteShortWord('header');
     PageHeader.WriteRTF(Writer);
     Writer.EndGroup;
   end;

  if PageFooter <> nil then
   begin
     Writer.StartGroup;
     Writer.WriteShortWord('footer');
     PageFooter.WriteRTF(Writer);
     Writer.EndGroup;
   end;
end;

function TxRTFFile.SaveRTF(FileName: string): Boolean;
var
  Writer: TxRTFWriter;
begin
  Writer := TxRTFWriter.Create(FileName);
  try
    WriteRTFHeader(Writer);
    WriteRTF(Writer);
  finally
    Writer.Free;
  end;

  Result := true;
end;

function TxRTFFile.LoadRTF(FileName: string): Boolean;
var
  Reader: TxRTFReader;
begin
  if Loading then
    raise ExRTFFile.Create('Loading of RTF file is already in progress...');

  Loading := true;
  try
    LblI := 0;

    Result := false;
    Clear;
    SetDefaults;
    FontList.Clear;

    CurrentBlock := TxRTFBlock.CreateChild(self);
    AddData(CurrentBlock);

    RTFProgress.Start(TranslateText('Идет чтение RTF файла.') + '#13' + TranslateText('Подождите немного...'),
      TranslateText('Подождите немного...'), TranslateText('Прервать чтение файла?'), 100);
    try
      Reader := TxRTFReader.Create(FileName);
      try
        if not Reader.ReadGroupStart then
          raise ExRTFFile.Create('Not a Rich Text Format (RTF) file or file is corrupted.');
        LoadRTFDocument(Reader);
        if RTFProgress.Terminated then
         begin
           Clear;
           exit;
         end;
        if not Reader.ReadGroupEnd then
          raise ExRTFFile.Create('Not a Rich Text Format (RTF) file or file is corrupted.');
      finally
        Reader.Free;
      end;

      {$IFDEF SHOWLBLI}
      MessageDlg('Memory allocated for RTF-file objects: ' + IntToStr(LblI),
        mtInformation, [mbOk], 0);
      {$ENDIF}
    finally
      RTFProgress.Stop;
    end;

    if CurrentBlock.IsEmpty then
      Data.Remove(CurrentBlock);

    if iCanvasHandle <> 0 then
      RefreshMargins;

    Result := True;
  finally
    Loading := false;
  end;

  Change;
end;

function TxRTFFile.LoadRTFFromStream(AnStream: TStream): Boolean;
var
  Reader: TxRTFReaderStream;
begin
  if Loading then
    raise ExRTFFile.Create('Loading of RTF file is already in progress...');

  Loading := true;
  try
    LblI := 0;

    Result := false;
    Clear;
    SetDefaults;
    FontList.Clear;

    CurrentBlock := TxRTFBlock.CreateChild(self);
    AddData(CurrentBlock);

    RTFProgress.Start(TranslateText('Идет чтение RTF файла.') + '#13' + TranslateText('Подождите немного...'),
      TranslateText('Подождите немного...'), TranslateText('Прервать чтение файла?'), 100);
    try
      Reader := TxRTFReaderStream.Create(AnStream);
      try
        if not Reader.ReadGroupStart then
          raise ExRTFFile.Create('Not a Rich Text Format (RTF) file or file is corrupted.');
        LoadRTFDocument(Reader);
        if RTFProgress.Terminated then
         begin
           Clear;
           exit;
         end;
        if not Reader.ReadGroupEnd then
          raise ExRTFFile.Create('Not a Rich Text Format (RTF) file or file is corrupted.');
      finally
        Reader.Free;
      end;

      {$IFDEF SHOWLBLI}
      MessageDlg('Memory allocated for RTF-file objects: ' + IntToStr(LblI),
        mtInformation, [mbOk], 0);
      {$ENDIF}
    finally
      RTFProgress.Stop;
    end;

    if CurrentBlock.IsEmpty then
      Data.Remove(CurrentBlock);

    if iCanvasHandle <> 0 then
      RefreshMargins;

    Result := True;
  finally
    Loading := false;
  end;

  Change;
end;

procedure TxRTFFile.Change;
begin
  State := State - [bsViewValid, bsSizeValid];
  if not Loading then
    SetMinPos(0); { this will pass through the whole RTF tree }
end;

function TxRTFFile.FindSize: LongInt;
var
  i: LongInt;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Result + Items[i].Size;
  Result := Result + Count - 1; { cause end of previous paragraph and start
                                  of the next one are different positions }
end;

function TxRTFFile.FindColorIndex(aColor: TRGBTRIPLE): Integer;
var
  i: Integer;
begin
  for i := 0 to ColorsInTable - 1 do
   if CompareColors(ColorTable[i], aColor) then
    begin
      Result := i;
      exit;
    end;
  Result := 0;
end;

procedure TxRTFFile.SetDefaults;
var
  AFont: TxRTFFont;
begin
  inherited SetDefaults;

  AFont := TxRTFFont.Create;
  AFont.FontNum := 0;
  AFont.Name := 'Times New Roman';
  FontList.Add(AFont);
  SetDefaultFont(CurrentFont);

  with Header do
   begin
     DefaultFont := 0;
   end;

  with DocFormat do
   begin
     PaperWidth := 12240;
     Paperheight := 15840;
     LeftMargin := 1800;
     RightMargin := 1800;
     TopMargin := 1440;
     BottomMargin := 1440;
     Landscape:= false;
     FirstPage := 1;
     HeaderY := 720;
     FooterY := 720;
   end;

  RefreshMargins;
end;

procedure TxRTFFile.RefreshMargins;
begin
  if iCanvasHandle = 0 then exit;
  if (iCanvasHandle = 0) then exit;
  PageFullWidth := TwipsToPixelsX(DocFormat.PaperWidth);
  PageWidth := TwipsToPixelsX(DocFormat.PaperWidth -
    DocFormat.LeftMargin - DocFormat.RightMargin);

  PageHeight := TwipsToPixelsY(DocFormat.PaperHeight -
    DocFormat.TopMargin - DocFormat.BottomMargin);
  PageFullHeight := TwipsToPixelsY(DocFormat.PaperHeight);

  if not(poDrawLRMargins in Options) and (Currentdestination = dsScreen) then
   begin
     PageFullWidth := PageWidth;
     PageFullHeight := PageHeight;
   end;

  SetDrawWidth(PageWidth);

  if (poDrawLRMargins in Options) or (CurrentDestination = dsPrinter) then
    SetLeftMargin(TwipsToPixelsX(DocFormat.LeftMargin))
  else
    SetLeftMargin(0);
end;

procedure TxRTFFile.RegisterCanvas(ACanvas: TCanvas);
begin
  iCanvasHandle := 0;
  iCanvasFont := 0;
  if (ACanvas <> nil) then
    RegisterCanvasHandle(ACanvas.Handle);
end;

procedure TxRTFFile.ProceedHandleChange;
var
  NewTextmetric: TTextMetric;
  NewPPIX: LongInt;
  NewPPIY: LongInt;
begin
  iCanvasFont := 0;
  if (iCanvasHandle <> 0) then
   begin
     // read canvas internal parameters
     GetTextMetrics(iCanvasHandle, NewTextMetric);
     NewPPIX := Round(GetDeviceCaps(iCanvasHandle, LOGPIXELSX) {* Scale});
     NewPPIY := Round(GetDeviceCaps(iCanvasHandle, LOGPIXELSY) {* Scale});
     if { - might be needed to add comparison of TextMetrics' records.
            Just don't use CompareMem - it misorients!
         not(CompareMem(@NewTextMetric, @CanvasTextMetric, SizeOf(TTextMetric)) ) or}
        (NewPPIX <> CanvasPPIX) or (NewPPIY <> CanvasPPIY) then
      begin
        CanvasTextMetric := NewTextMetric;
        CanvasPPIX := NewPPIX;
        CanvasPPIY := NewPPIY;
        RefreshMargins;
        ViewChanged;
      end;
   end;
end;

procedure TxRTFFile.RegisterCanvasHandle(AHandle: THandle);
begin
  if iCanvasHandle <> AHandle then
   begin
     iCanvasHandle := AHandle;
     ProceedHandleChange;
   end;
end;

procedure TxRTFFile.BuildView;
var
  APage: TxRTFPage;
  i: LongInt;
  Aheight: LongInt;
  LnCount: LongInt;
begin
  // if canvas is not assigned then skip building
  if iCanvasHandle = 0 then exit;


  if Building then exit;
  Building := true;

  Position := Point(0,0);
  if PageHeader <> nil then
    PageHeader.CheckIsBuilt;
  if PageFooter <> nil then
    PageFooter.CheckIsBuilt;

  try
    if Count > 0 then
     begin
       RTFProgress.Start(TranslateText('Идет форматирование текста и разбивка на страницы.') + #13+
        TranslateText('Подождите немного, пожалуйста...'), TranslateText('Подождите немного...'), '', Size);
       try
         inherited BuildView;
       finally
         RTFProgress.Stop;
       end;


       // разбивка текста на страницы

       LnCount := LinesCount;

       RTFProgress.Start(TranslateText('Идет форматирование текста и разбивка на страницы.') +#13+
        TranslateText('Подождите немного, пожалуйста...'), TranslateText('Найдено %d страниц'), '', LnCount);
       try
         { divide into pages }
         PageInfo.Clear;
         i := 0;
         while i < LnCount do
          begin
            RTFProgress.Update(i, Format(Phrases[lnPageCount], [PageInfo.Count]));

            APage := TxRTFPage.Create;
            APage.FirstLine := i;

            AHeight := PageStartHeight(i) + LineHeight(i);
            inc(i);
            while (AHeight <= PageHeight) and (i < LnCount) and
              not(LastLineOnPage(i - 1)) do
             begin
               AHeight := AHeight + LineHeight(i);
               inc(i);
             end;

            if (AHeight > PageHeight) and (i > APage.FirstLine + 1) then
             begin
               APage.LastLine := i - 2;
               dec(i);
             end
            else
              APage.LastLine := i - 1;

            PageInfo.Add(APage);
          end;
       finally
         RTFProgress.Stop;
       end;

     end

    else // empty RTF - i.e. Count = 0
     inherited BuildView;

  finally
    Building := false;
  end;
end;

procedure TxRTFFile.ReadData(Reader: TReader);
var
  AFont: TxRTFFont;
begin
  inherited ReadData(Reader);
  Reader.Read(Header, SizeOf(Header));
  Reader.Read(DocFormat, SizeOf(DocFormat));
  PageWidth := Reader.ReadInteger;
  PageFullWidth := Reader.ReadInteger;
  PageHeight := Reader.ReadInteger;
  PageFullHeight := Reader.ReadInteger;
  Reader.Read(CanvasTextMetric, SizeOf(TtextMetric));
  CanvasPPIX := Reader.ReadInteger;
  CanvasPPIY := Reader.ReadInteger;
  FontList.Clear;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
   begin
     AFont := TxRTFFont.Create;
     AFont.ReadData(Reader);
     Fontlist.Add(AFont);
   end;
  Reader.ReadListEnd;
end;

procedure TxRTFFile.WriteData(Writer: TWriter);
var
  i: integer;
begin
  inherited WriteData(Writer);
  Writer.Write(Header, SizeOf(Header));
  Writer.Write(DocFormat, SizeOf(DocFormat));
  Writer.WriteInteger(PageWidth);
  Writer.WriteInteger(PageFullWidth);
  Writer.WriteInteger(PageHeight);
  Writer.WriteInteger(PageFullHeight);
  Writer.Write(CanvasTextMetric, SizeOf(TtextMetric));
  Writer.WriteInteger(CanvasPPIX);
  Writer.WriteInteger(CanvasPPIY);
  Writer.WriteListBegin;
  for i := 0 to FontList.Count - 1 do
    TxRTFFont(FontList[i]).WriteData(Writer);
  Writer.WriteListEnd;
end;

procedure TxRTFFile.Assign(From: TxRTFBasic);
begin
  AssignFormat(From);
  inherited Assign(From);
end;

procedure TxRTFFile.AssignFormat(From: TxRTFBasic);
var
  i: Integer;
  AFont: TxRTFFont;
begin
  Clear;
  Header := TxRTFFile(From).Header;
  DocFormat := TxRTFFile(From).DocFormat;
  for i := 0 to TxRTFFile(From).FontList.Count - 1 do
   begin
     AFont := TxRTFFont.Create;
     AFont.Assign(TxRTFFont(TxRTFFile(From).FontList[i]));
     FontList.Add(AFont);
   end;
  ColorsInTable := TxRTFFile(From).ColorsInTable;
  for i := 0 to ColorsInTable - 1 do
    ColorTable[i] := TxRTFFile(From).ColorTable[i];
  RefreshMargins;
end;

procedure TxRTFFile.Clear;
begin
  FreeObject(TObject(PageHeader));
  FreeObject(TObject(PageFooter));
  FontList.Clear;
  PageInfo.Clear;
  SEQNumbers.Clear;
  SetDefaults;
  inherited Clear;
end;

procedure TxRTFFile.NextParaLoaded;
begin
  { for children }
end;

procedure TxRTFFile.SetLeftMargin(Value: Integer);
begin
  inherited SetLeftMargin(Value);
  if PageHeader <> nil then
    PageHeader.SetLeftMargin(Value);
  if PageFooter <> nil then
    PageFooter.SetLeftMargin(Value);
end;

procedure TxRTFFile.SetDrawWidth(Value: Integer);
begin
  inherited SetDrawWidth(Value);
  if PageHeader <> nil then
    PageHeader.SetDrawWidth(Value);
  if PageFooter <> nil then
    PageFooter.SetDrawWidth(Value);
end;

procedure TxRTFFile.CopyHeaderFooter(From: TxRTFFile);
begin
  FreeObject(TObject(PageHeader));
  FreeObject(TObject(PageFooter));
  { copy positions here }
  if From.PageHeader <> nil then
   begin
     PageHeader := TxRTFHeaderFooter.CreateChild(self);
     PageHeader.Assign(From.PageHeader);
   end;
  if From.PageFooter <> nil then
   begin
     PageFooter := TxRTFHeaderFooter.CreateChild(self);
     PageFooter.Assign(From.PageFooter);
   end;
  RefreshMargins;
  Change;
end;

procedure TxRTFFile.PrintPageBody2(Page: LongInt);
var
  Opt: TDrawOptions;
begin
//  WinProcs.StartPage(iCanvasHandle);
  try
    PageInPrint := Page + 1;

    SetCanvasFont;
    try
      Position := Point(0, TwipsToPixelsY(DocFormat.TopMargin));

      Opt.From := TxRTFPage(PageInfo[Page]).FirstLine;
      Opt.Till := TxRTFPage(PageInfo[Page]).LastLine;
      SetRect(Opt.DrawRect, 0, 0,
        GetDeviceCaps(iCanvasHandle, HORZRES), GetDeviceCaps(iCanvasHandle, VERTRES));
      Opt.HShift := 0;
      Opt.Cmd := dcDrawWhole;
      OriginalOpt := Opt;

      if PageHeader <> nil then
       begin
         Position := Point(0, TwipsToPixelsY(DocFormat.HeaderY));
         PageHeader.DrawHdrFtr(Opt);
       end;

      Position := Point(0, TwipsToPixelsY(DocFormat.TopMargin));

      StartPage(Opt);
      Draw(Opt);

      if PageFooter <> nil then
       begin
         Position := Point(0,
           TwipsToPixelsY(DocFormat.PaperHeight - DocFormat.FooterY));
         PageFooter.DrawHdrFtr(Opt);
       end;

    finally
      RestoreCanvasFont;
    end;

  finally
//    WinProcs.EndPage(iCanvasHandle);
  end;
end;

procedure TxRTFFile.PrintPageBody(Page: LongInt);
var
  Opt: TDrawOptions;
begin
  WinProcs.StartPage(iCanvasHandle);
  try
    PageInPrint := Page + 1;

    SetCanvasFont;
    try
      Position := Point(0, TwipsToPixelsY(DocFormat.TopMargin));

      Opt.From := TxRTFPage(PageInfo[Page]).FirstLine;
      Opt.Till := TxRTFPage(PageInfo[Page]).LastLine;
      SetRect(Opt.DrawRect, 0, 0,
        GetDeviceCaps(iCanvasHandle, HORZRES), GetDeviceCaps(iCanvasHandle, VERTRES));
      Opt.HShift := 0;
      Opt.Cmd := dcDrawWhole;
      OriginalOpt := Opt;

      if PageHeader <> nil then
       begin
         Position := Point(0, TwipsToPixelsY(DocFormat.HeaderY));
         PageHeader.DrawHdrFtr(Opt);
       end;

      Position := Point(0, TwipsToPixelsY(DocFormat.TopMargin));

      StartPage(Opt);
      Draw(Opt);

      if PageFooter <> nil then
       begin
         Position := Point(0,
           TwipsToPixelsY(DocFormat.PaperHeight - DocFormat.FooterY));
         PageFooter.DrawHdrFtr(Opt);
       end;

    finally
      RestoreCanvasFont;
    end;

  finally
    WinProcs.EndPage(iCanvasHandle);
  end;
end;

procedure TxRTFFile.PrintPage(Page: LongInt);
var
  OldCanvasHandle: THandle;
  OldScale: Double;
  OldDest: TDestinations;
begin
  if ProhibitDrawing then
   begin
     raise ExRTFFile.Create('Drawing is prohibited - try to call printing again.');
     exit;
   end;
  SetCanvasFont;
  ProhibitDrawing := true;
  OldCanvasHandle := iCanvasHandle;
  OldDest := CurrentDestination;
  OldScale := Scale;
  CurrentDestination := dsPrinter;
  try
    PageInPrint := Page;

    TheDate := Now;

    CheckIsBuilt;

    PrintPageBody(Page);

    AfterPrinting;
  finally
    CurrentDestination := OldDest;
    ProhibitDrawing := false;
    Scale := OldScale;
    { restore old output device handle }
    RegisterCanvasHandle(OldCanvasHandle);
  end;
end;

function TxRTFFile.PrintRTF2(const ShowDlg: Boolean = True): Boolean;
var
  OldCanvasHandle: THandle;
  OldScale: Double;
  OldDest: TDestinations;
  Page: LongInt;
  Form: TRTFPrintingForm;
  //Prn: TxRTFPrinter;
  From, Till: Integer;
  FirstPage: Boolean;
  PrintDialog: TPrintDialog;
begin
  Result := false;
  FirstPage := False;
  if ProhibitDrawing then
   begin
     raise ExRTFFile.Create('Drawing is prohibited - try to call printing again.');
     exit;
   end;
  ProhibitDrawing := true;
  try
   // Prn := TxRTFPrinter.Create(self);
    PrintDialog := TPrintDialog.Create(nil);
    try
   //   if Prn.ShowDialog then
      (*PrintDialog.Options := [poPageNums, poWarning];
      PrintDialog.MaxPage := PageInfo.Count;
      PrintDialog.MinPage := 1;*)
      if not ShowDlg or PrintDialog.Execute then
      begin
         OldCanvasHandle := iCanvasHandle;
         OldDest := CurrentDestination;
         CurrentDestination := dsPrinter;

         OldScale := Scale;
         Scale := 1;

         try
           TheDate := Now;

           { prepare for printing }
         //  BeforePrinting(Prn.Device, Prn.Driver, Prn.Port, Prn.DeviceMode);
           Printer.Title := ExtractFileName(Application.ExeName) + ' - печать';
           if DocFormat.Landscape then
             Printer.Orientation := poLandscape
           else
             Printer.Orientation := poPortrait;
           Printer.BeginDoc;
           RegisterCanvasHandle(Printer.Canvas.Handle);
           try
             CheckIsBuilt;

             { perform the printing itself }
             Form := TRTFPrintingForm.Create(Application);
             try
               Form.Terminated := false;
               Form.Show;
               //for i := 0 to PrintDialog.Copies - 1 do //Prn.Pages.Count - 1 do
                begin
                  if PrintDialog.PrintRange = prAllPages then
                  begin
                    From := 0;
                    Till := PageInfo.Count - 1;
                  end else

                  if PrintDialog.PrintRange = prPageNums then
                  begin
                    From := PrintDialog.FromPage - 1;
                    Till := PrintDialog.ToPage - 1;
                    if From < 0 then From := 0;
                    if Till > PageInfo.Count - 1 then Till := PageInfo.Count - 1;
                    if Till < 0 then Till := 0;
                    if From > PageInfo.Count - 1 then From := PageInfo.Count - 1;
                  end else begin
                    From := 0;
                    Till := 0;
                  end;

                  for Page := From to Till do
                   begin
                     if FirstPage then
                       Printer.NewPage
                     else
                       FirstPage := True;
                     Form.PageLabel.Caption :=
                       Format(Phrases[lnFrom], [Page + 1, PageInfo.Count]);
                     Form.PageLabel.Left :=
                       (Form.Panel.ClientWidth - Form.PageLabel.Width) div 2;
                     Application.ProcessMessages;
{                     for mc := 1 to Prn.Copies do}
                       PrintPageBody2(Page);
                     if Form.Terminated then break;
                   end;
//                  if Form.Terminated then break;
                end;
               Result := not Form.Terminated; { printing completed successfully }
             finally
               Form.Free;
             end;
           finally
             Printer.EndDoc;
           end;
         finally
           CurrentDestination := OldDest; { for security }
           Scale := OldScale;
           RegisterCanvasHandle(OldCanvasHandle);
         end;
       end;

    finally
      //Prn.Free;
      PrintDialog.Free;
    end;
  finally
    ProhibitDrawing := false;
  end;
end;

function TxRTFFile.PrintRTF: Boolean;
var
  OldCanvasHandle: THandle;
  OldScale: Double;
  OldDest: TDestinations;
  Page: LongInt;
  Form: TRTFPrintingForm;
  Prn: TxRTFPrinter;
  i: Integer;
  From, Till: Integer;
begin
  Result := false;
  if ProhibitDrawing then
   begin
     raise ExRTFFile.Create('Drawing is prohibited - try to call printing again.');
     exit;
   end;
  ProhibitDrawing := true;
  try
    Prn := TxRTFPrinter.Create(self);
    try
      if Prn.ShowDialog then
       begin
         OldCanvasHandle := iCanvasHandle;
         OldDest := CurrentDestination;
         CurrentDestination := dsPrinter;

         OldScale := Scale;
         Scale := 1;

         try
           TheDate := Now;

           { prepare for printing }
           BeforePrinting(Prn.Device, Prn.Driver, Prn.Port, Prn.DeviceMode);
           try
             CheckIsBuilt;

             { perform the printing itself }
             Form := TRTFPrintingForm.Create(Application);
             try
               Form.Terminated := false;
               Form.Show;
               for i := 0 to Prn.Pages.Count - 1 do
                begin
                  if TxPages(Prn.Pages[i]).From = -1 then
                    From := 0
                  else
                    From := TxPages(Prn.Pages[i]).From - 1;

                  if TxPages(Prn.Pages[i]).Till = -1 then
                    Till := PageInfo.Count - 1
                  else
                    Till := TxPages(Prn.Pages[i]).Till - 1;

                  { ensure page numbers are within limits }
                  if From < 0 then From := 0;

                  if Till >= PageInfo.Count then
                    Till := PageInfo.Count - 1;

                  for Page := From to Till do
                   begin
                     Form.PageLabel.Caption :=
                       Format(Phrases[lnFrom], [Page + 1, PageInfo.Count]);
                     Form.PageLabel.Left :=
                       (Form.Panel.ClientWidth - Form.PageLabel.Width) div 2;
                     Application.ProcessMessages;
{                     for mc := 1 to Prn.Copies do}
                       PrintPageBody(Page);
                     if Form.Terminated then break;
                   end;
                  if Form.Terminated then break;
                end;
               Result := not Form.Terminated; { printing completed successfully }
             finally
               Form.Free;
             end;
           finally
             AfterPrinting;
             { restore old output device handle and delete printer object }
             if not BOOL(DeleteDC(iCanvasHandle)) then
               MessageDlg('Handle after printing was not deleted!', mtError, [mbOk], 0);
           end;
         finally
           CurrentDestination := OldDest; { for security }
           Scale := OldScale;
           RegisterCanvasHandle(OldCanvasHandle);
         end;
       end;
    finally
      Prn.Free;
    end;
  finally
    ProhibitDrawing := false;
  end;
end;

procedure TxRTFFile.BeforePrinting(ADevice, ADriver, APort: PChar;
  ADeviceMode: THandle);
var
  DocInfo: TDocInfo;
  AHandle: THandle;
  DevMode: PDeviceMode;
  P: OSVERSIONINFO;
begin
  DeviceMode := ADeviceMode;
  DevMode := GlobalLock(DeviceMode);

  P.dwPlatformId := 0;
  P.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);

  if GetVersionEx(P) and (P.dwPlatformId = VER_PLATFORM_WIN32_NT) then
      AHandle := CreateDC(ADriver, ADevice, nil, DevMode)
    else
      AHandle := CreateDC(nil, ADevice, nil, DevMode);

  with DocInfo do
  begin
    cbSize := SizeOf(DocInfo);
    lpszDocName := 'Printing RTF file.'#0;
    lpszOutput := nil;
  end;
  WinProcs.StartDoc(AHandle, DocInfo);
  RegisterCanvasHandle(AHandle);
end;

procedure TxRTFFile.AfterPrinting;
begin
  WinProcs.EndDoc(iCanvasHandle);
  GlobalUnlock(DeviceMode);
end;

function TxRTFFile.CountPages: Integer;
begin
  CheckIsBuilt;
  Result := PageInfo.Count;
end;

procedure TxRTFFile.ViewChanged;
begin
  inherited ViewChanged;
  if PageHeader <> nil then PageHeader.ViewChanged;
  if PageFooter <> nil then PageFooter.ViewChanged;
end;

procedure TxRTFFile.SetCanvasFont;
begin
  inc(FontWasChanged);
  if BOOL(FontWasChanged - 1) then
    exit; { i.e. we are already drawing (draw was called while previous draw didn't finish) }

  SetDefaultFont(FontInUse);

  FontInUse.lfHeight := 0;
  FontHInUse := CreateFontIndirect(FontInUse);
  SavedFontHandle := SelectObject(iCanvasHandle, FontHInUse);
end;

procedure TxRTFFile.RestoreCanvasFont;
begin
  dec(FontWasChanged);
  if FontWasChanged = 0 then
   begin
     SelectObject(iCanvasHandle, SavedFontHandle);
     DeleteObject(FontHInUse);
     SavedFontHandle := 0;
   end;
end;

function TxRTFFile.GetLinesCount: LongInt;
begin
  if iCanvasHandle = 0 then
   begin
     Result := 0;
     exit;
   end;
  CheckIsBuilt;
  Result := inherited GetLinesCount;
end;

procedure TxRTFFile.Statistics;
begin
  MessageDlg(
   TranslateText('Информация об RTF файле:') + #13 +
     TranslateText('  Создано объектов             : ') + IntToStr(Objects) + #13 +
     TranslateText('  Память, занимаемая структурой: ') + IntToStr(MemoryUsed),
     mtInformation, [mbOk], 0);
end;

function TxRTFFile.GiveSEQNumber(AutoName: string): Longint;
var
  Index: Integer;
  NewVar: TxSeqNumber;
begin
  { is this AutoName var registered }
  Index := 0;
  while (Index < SEQNumbers.Count) and
    (CompareText(TxSeqNumber(SEQNumbers[Index]).Name, AutoName) <> 0) do
   inc(Index);

  { register var if necessary }
  if Index = SEQNumbers.Count then
   begin
     NewVar := TxSeqNumber.Create;
     NewVar.Name := AutoName;
     Index := SEQNumbers.Add(NewVar);
   end;

  { get next free number }
  inc(TxSeqNumber(SEQNumbers[Index]).LastValue);
  Result := TxSeqNumber(SEQNumbers[Index]).LastValue;
end;

end.
