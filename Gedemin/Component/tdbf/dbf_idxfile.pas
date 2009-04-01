unit dbf_idxfile;

interface

{$I dbf_common.inc}

uses
{$ifdef WIN32}
  Windows,
{$else}
{$ifdef KYLIX}
  Libc,
{$endif}
  Types, dbf_wtil,
{$endif}
  SysUtils,
  Classes,
  db,
  dbf_pgfile,
{$ifdef USE_CACHE}
  dbf_pgcfile,
{$endif}
  dbf_parser,
  dbf_prsdef,
  dbf_cursor,
  dbf_common;

{$ifdef _DEBUG}
{$define TDBF_INDEX_CHECK}
{$endif}
{$ifdef _ASSERTS}
{$define TDBF_INDEX_CHECK}
{$endif}

const
  MaxIndexes = 47;

type
  TIndexPage = class;
  TIndexTag = class;

  TIndexUpdateMode = (umAll, umCurrent);
  TLocaleError = (leNone, leUnknown, leTableIndexMismatch, leNotAvailable);
  TLocaleSolution = (lsNotOpen, lsNoEdit, lsBinary);
  TIndexUniqueType = (iuNormal, iuUnique, iuDistinct);
  TIndexModifyMode = (mmNormal, mmDeleteRecall);

  TDbfLocaleErrorEvent = procedure(var Error: TLocaleError; var Solution: TLocaleSolution) of object;
  TDbfCompareKeyEvent = function(Key: PChar): Integer of object;
  TDbfCompareKeysEvent = function(Key1, Key2: PChar): Integer of object;

  PDouble = ^Double;
  PInteger = ^Integer;

//===========================================================================
  TDbfIndexDef = class;
  TDbfIndexDef = class(TCollectionItem)
  protected
    FIndexName: string;
    FExpression: string;
    FOptions: TIndexOptions;
    FTemporary: Boolean;          // added at runtime

    procedure SetIndexName(NewName: string);
    procedure SetExpression(NewField: string);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    property Temporary: Boolean read FTemporary write FTemporary;
    property Name: string read FIndexName write SetIndexName;
    property Expression: string read FExpression write SetExpression;
  published
    property IndexFile: string read FIndexName write SetIndexName;
    property SortField: string read FExpression write SetExpression;
    property Options: TIndexOptions read FOptions write FOptions;
  end;

//===========================================================================
  TIndexFile = class;
  TIndexPageClass = class of TIndexPage;

  TIndexPage = class(TObject)
  protected
    FIndexFile: TIndexFile;
    FLowerPage: TIndexPage;
    FUpperPage: TIndexPage;
    FPageBuffer: Pointer;
    FEntry: Pointer;
    FEntryNo: Integer;
    FLockCount: Integer;
    FModified: Boolean;
    FPageNo: Integer;
    FWeight: Integer;

    // bracket props
    FLowBracket: Integer;               //  = FLowIndex if FPageNo = FLowPage
    FLowIndex: Integer;
    FLowPage: Integer;
    FHighBracket: Integer;              //  = FHighIndex if FPageNo = FHighPage
    FHighIndex: Integer;
    FHighPage: Integer;

    procedure LocalInsert(RecNo: Integer; Buffer: PChar; LowerPageNo: Integer);
    procedure LocalDelete;
    procedure Delete;

    procedure SyncLowerPage;
    procedure WritePage;
    procedure Split;
    procedure LockPage;
    procedure UnlockPage;

    function RecurPrev: Boolean;
    function RecurNext: Boolean;
    procedure RecurFirst;
    procedure RecurLast;

    procedure SetEntry(RecNo: Integer; AKey: PChar; LowerPageNo: Integer);
    procedure SetEntryNo(value: Integer);
    procedure SetPageNo(NewPageNo: Integer);
    procedure SetLowPage(NewPage: Integer);
    procedure SetHighPage(NewPage: Integer);
    procedure SetUpperPage(NewPage: TIndexPage);
    procedure UpdateBounds(IsInnerNode: Boolean);

  protected
    function GetEntry(AEntryNo: Integer): Pointer; virtual; abstract;
    function GetLowerPageNo: Integer; virtual; abstract;
    function GetKeyData: PChar; virtual; abstract;
    function GetNumEntries: Integer; virtual; abstract;
    function GetKeyDataFromEntry(AEntry: Integer): PChar; virtual; abstract;
    function GetRecNo: Integer; virtual; abstract;
    function GetIsInnerNode: Boolean; virtual; abstract;
    procedure IncNumEntries; virtual; abstract;
    procedure SetNumEntries(NewNum: Integer); virtual; abstract;
    procedure SetRecLowerPageNo(NewRecNo, NewPageNo: Integer); virtual; abstract;
    procedure SetRecLowerPageNoOfEntry(AEntry, NewRecNo, NewPageNo: Integer); virtual; abstract;
{$ifdef TDBF_UPDATE_FIRST_LAST_NODE}
    procedure SetPrevBlock(NewBlock: Integer); virtual;
{$endif}

  public
    constructor Create(Parent: TIndexFile);
    destructor Destroy; override;

    function FindNearest(ARecNo: Integer): Integer;
    function PhysicalRecNo: Integer;
    function MatchKey: Integer;
    procedure GotoInsertEntry;

    procedure Clear;
    procedure GetNewPage;
    procedure Modified;
    procedure RecalcWeight;
    procedure UpdateWeight;
    procedure Flush;

    property Key: PChar read GetKeyData;
    property Entry: Pointer read FEntry;
    property EntryNo: Integer read FEntryNo write SetEntryNo;
    property IndexFile: TIndexFile read FIndexFile;
    property UpperPage: TIndexPage read FUpperPage write SetUpperPage;
    property LowerPage: TIndexPage read FLowerPage;
//    property LowerPageNo: Integer read GetLowerPageNo;        // never used
    property PageBuffer: Pointer read FPageBuffer;
    property PageNo: Integer read FPageNo write SetPageNo;
    property Weight: Integer read FWeight;

    property NumEntries: Integer read GetNumEntries;
    property HighBracket: Integer read FHighBracket write FHighBracket;
    property HighIndex: Integer read FHighIndex;
    property HighPage: Integer read FHighPage write SetHighPage;
    property LowBracket: Integer read FLowBracket write FLowBracket;
    property LowIndex: Integer read FLowIndex;
    property LowPage: Integer read FLowPage write SetLowPage;
  end;
//===========================================================================
  TIndexTag = class(TObject)
  private
    FTag: Pointer;
  protected
    function  GetHeaderPageNo: Integer; virtual; abstract;
    function  GetTagName: string; virtual; abstract;
    function  GetKeyFormat: Byte; virtual; abstract;
    function  GetForwardTag1: Byte; virtual; abstract;
    function  GetForwardTag2: Byte; virtual; abstract;
    function  GetBackwardTag: Byte; virtual; abstract;
    function  GetReserved: Byte; virtual; abstract;
    function  GetKeyType: Char; virtual; abstract;
    procedure SetHeaderPageNo(NewPageNo: Integer); virtual; abstract;
    procedure SetTagName(NewName: string); virtual; abstract;
    procedure SetKeyFormat(NewFormat: Byte); virtual; abstract;
    procedure SetForwardTag1(NewTag: Byte); virtual; abstract;
    procedure SetForwardTag2(NewTag: Byte); virtual; abstract;
    procedure SetBackwardTag(NewTag: Byte); virtual; abstract;
    procedure SetReserved(NewReserved: Byte); virtual; abstract;
    procedure SetKeyType(NewType: Char); virtual; abstract;
  public
    property HeaderPageNo: Integer read GetHeaderPageNo write SetHeaderPageNo;
    property TagName: string read GetTagName write SetTagName;
    property KeyFormat:   Byte read GetKeyFormat   write SetKeyFormat;
    property ForwardTag1: Byte read GetForwardTag1 write SetForwardTag1;
    property ForwardTag2: Byte read GetForwardTag2 write SetForwardTag2;
    property BackwardTag: Byte read GetBackwardTag write SetBackwardTag;
    property Reserved: Byte read GetReserved write SetReserved;
    property KeyType: Char read GetKeyType write SetKeyType;
    property Tag: Pointer read FTag write FTag;
  end;
//===========================================================================
{$ifdef USE_CACHE}
  TIndexFile = class(TCachedFile)
{$else}
  TIndexFile = class(TPagedFile)
{$endif}
  protected
    FIndexName: string;
    FParsers: array[0..MaxIndexes-1] of TDbfParser;
    FIndexHeaders: array[0..MaxIndexes-1] of Pointer;
    FIndexHeaderModified: array[0..MaxIndexes-1] of Boolean;
    FIndexHeader: Pointer;
    FIndexVersion: TXBaseVersion;
    FRoots: array[0..MaxIndexes-1] of TIndexPage;
    FLeaves: array[0..MaxIndexes-1] of TIndexPage;
    FCurrentParser: TDbfParser;
    FRoot: TIndexPage;
    FLeaf: TIndexPage;
    FMdxTag: TIndexTag;
    FTempMdxTag: TIndexTag;
    FEntryHeaderSize: Integer;
    FPageHeaderSize: Integer;
    FTagSize: Integer;
    FTagOffset: Integer;
    FHeaderPageNo: Integer;
    FSelectedIndex: Integer;
    FIsDescending: Boolean;
    FUniqueMode: TIndexUniqueType;
    FModifyMode: TIndexModifyMode;
    FHeaderLocked: Integer;   // used to remember which header page we have locked
    FKeyBuffer: array[0..100] of Char;
    FLowBuffer: array[0..100] of Char;
    FHighBuffer: array[0..100] of Char;
    FEntryBof: Pointer;
    FEntryEof: Pointer;
    FDbfFile: Pointer;
    FCanEdit: Boolean;
    FOpened: Boolean;
    FRangeActive: Boolean;
    FUpdateMode: TIndexUpdateMode;
    FUserKey: PChar;        // find / insert key
    FUserRecNo: Integer;    // find / insert recno
    FUserBCD: array[0..10] of Byte;
    FUserNumeric: Double;
    FForceClose: Boolean;
    FForceReadOnly: Boolean;
    FLocaleID: LCID;
    FLocaleCP: Integer;
    FCodePage: Integer;
    FCompareKey: TDbfCompareKeyEvent;
    FCompareKeys: TDbfCompareKeysEvent;
    FOnLocaleError: TDbfLocaleErrorEvent;

    function  GetNewPageNo: Integer;
    procedure TouchHeader(AHeader: Pointer);
    function  CreateTempFile(BaseName: string): TPagedFile;
    procedure WriteIndexHeader(AIndex: Integer);
    procedure SelectIndexVars(AIndex: Integer);
    procedure CalcKeyProperties;
    procedure UpdateIndexProperties;
    procedure ClearRoots;
    function  CalcTagOffset(AIndex: Integer): Pointer;

    function  FindKey(AInsert: boolean): Integer;
    procedure InsertKey(Buffer: PChar);
    procedure DeleteKey(Buffer: PChar);
    procedure InsertCurrent;
    procedure DeleteCurrent;
    procedure UpdateCurrent(PrevBuffer, NewBuffer: PChar);
    procedure ReadIndexes;
    procedure Resync(Relative: boolean);
    procedure ResyncRoot;
    procedure ResyncTree;
    procedure ResyncRange(KeepPosition: boolean);
    procedure ResetRange;
    procedure SetBracketLow;
    procedure SetBracketHigh;

    procedure WalkFirst;
    procedure WalkLast;
    function  WalkPrev: boolean;
    function  WalkNext: boolean;
    
    procedure TranslateToANSI(Src, Dest: PChar);
    function  CompareKeyNumericNDX(Key: PChar): Integer;
    function  CompareKeyNumericMDX(Key: PChar): Integer;
    function  CompareKeyString(Key: PChar): Integer;
    function  CompareKeysNumericNDX(Key1, Key2: PChar): Integer;
    function  CompareKeysNumericMDX(Key1, Key2: PChar): Integer;
    function  CompareKeysString(Key1, Key2: PChar): Integer;

    // property functions
    function  GetName: string;
    function  GetDbfLanguageId: Byte;
    function  GetKeyLen: Integer;
    function  GetKeyType: Char;
//    function  GetIndexCount Integer;
    function  GetExpression: string;
    function  GetPhysicalRecNo: Integer;
    function  GetSequentialRecNo: Integer;
    function  GetSequentialRecordCount: Integer;
    procedure SetSequentialRecNo(RecNo: Integer);
    procedure SetPhysicalRecNo(RecNo: Integer);
    procedure SetUpdateMode(NewMode: TIndexUpdateMode);
    procedure SetIndexName(const AIndexName: string);
    procedure SetLocaleID(const NewID: LCID);

    property InternalLocaleID: LCID read FLocaleID write SetLocaleID;

  public
    constructor Create(ADbfFile: Pointer);
    destructor Destroy; override;

    procedure Open;
    procedure Close;

    procedure Clear;
    procedure Flush; override;
    procedure ClearIndex;
    procedure AddNewLevel;
    procedure UnlockHeader;
    procedure InsertError;
    procedure Insert(RecNo: Integer; Buffer: PChar);
    procedure Update(RecNo: Integer; PrevBuffer, NewBuffer: PChar);
    procedure Delete(RecNo: Integer; Buffer: PChar);
    function  CheckKeyViolation(Buffer: PChar): Boolean;
    procedure RecordDeleted(RecNo: Integer; Buffer: PChar);
    procedure RecordRecalled(RecNo: Integer; Buffer: PChar);
    procedure DeleteIndex(const AIndexName: string);
    procedure RepageFile;
    procedure CompactFile;
    procedure PrepareRename(NewFileName: string);

    procedure CreateIndex(FieldDesc, TagName: string; Options: TIndexOptions);
    function  ExtractKeyFromBuffer(Buffer: PChar): PChar;
    function  SearchKey(Key: PChar; SearchType: TSearchKeyType): Boolean;
    function  Find(RecNo: Integer; Buffer: PChar): Integer;
    function  IndexOf(const AIndexName: string): Integer;

    procedure GetIndexNames(const AList: TStrings);
    procedure GetIndexInfo(const AIndexName: string; IndexDef: TDbfIndexDef);
    procedure WriteHeader; override;
    procedure WriteFileHeader;

    procedure First;
    procedure Last;
    function  Next: Boolean;
    function  Prev: Boolean;

    procedure SetRange(LowRange, HighRange: PChar);
    procedure CancelRange;
    function  MatchKey(UserKey: PChar): Integer;
    function  CompareKey(Key: PChar): Integer;
    function  CompareKeys(Key1, Key2: PChar): Integer;
    function  PrepareKey(Buffer: PChar; ResultType: TExpressionType): PChar;

    property KeyLen: Integer read GetKeyLen;
    property IndexVersion: TXBaseVersion read FIndexVersion;
    property EntryHeaderSize: Integer read FEntryHeaderSize;
    property KeyType: Char read GetKeyType;

    property SequentialRecordCount: Integer read GetSequentialRecordCount;
    property SequentialRecNo: Integer read GetSequentialRecNo write SetSequentialRecNo;
    property PhysicalRecNo: Integer read GetPhysicalRecNo write SetPhysicalRecNo;
    property HeaderPageNo: Integer read FHeaderPageNo;

    property IndexHeader: Pointer read FIndexHeader;
    property EntryBof: Pointer read FEntryBof;
    property EntryEof: Pointer read FEntryEof;
    property UniqueMode: TIndexUniqueType read FUniqueMode;
    property IsDescending: Boolean read FIsDescending;

    property UpdateMode: TIndexUpdateMode read FUpdateMode write SetUpdateMode;
    property IndexName: string read FIndexName write SetIndexName;
    property Expression: string read GetExpression;
//    property Count: Integer read GetIndexCount;

    property ForceClose: Boolean read FForceClose;
    property ForceReadOnly: Boolean read FForceReadOnly;
    property LocaleID: LCID read FLocaleID;
    property CodePage: Integer read FCodePage write FCodePage;

    property OnLocaleError: TDbfLocaleErrorEvent read FOnLocaleError write FOnLocaleError;
  end;

//------------------------------------------------------------------------------
implementation

uses
  dbf_dbffile,
  dbf_fields,
  dbf_str,
  dbf_lang;

const
  RecBOF = 0;
  RecEOF = MaxInt;

  lcidBinary = $0A03;

  KeyFormat_Expression = $00;
  KeyFormat_Data       = $10;

  KeyFormat_Descending = $08;
  KeyFormat_String     = $10;
  KeyFormat_Distinct   = $20;
  KeyFormat_Unique     = $40;

  Unique_None          = $00;
  Unique_Unique        = $01;
  Unique_Distinct      = $21;

type

  TLCIDList = class(TList)
  public
    constructor Create;

    procedure Enumerate;
  end;

  PMdxHdr = ^rMdxHdr;
  rMdxHdr = record
    MdxVersion : Byte;     // 0
    Year       : Byte;     // 1
    Month      : Byte;     // 2
    Day        : Byte;     // 3
    FileName   : array[0..15] of Char;   // 4..19
    BlockSize  : Word;     // 20..21
    BlockAdder : Word;     // 22..23
    ProdFlag   : Byte;     // 24
    NumTags    : Byte;     // 25
    TagSize    : Byte;     // 26
    Dummy1     : Byte;     // 27
    TagsUsed   : Word;     // 28..29
    Dummy2     : Byte;     // 30
    Language   : Byte;     // 31
    NumPages   : Integer;  // 32..35
    FreePage   : Integer;  // 36..39
    BlockFree  : Integer;  // 40..43
    UpdYear    : Byte;     // 44
    UpdMonth   : Byte;     // 45
    UpdDay     : Byte;     // 46
    Reserved   : array[0..481] of Byte;  // 47..528
    TagFlag    : Byte;     // 529                   // dunno what this means but it ought to be 1  :-)
  end;

  // Tags -> I don't know what to with them
  // KeyType -> Variable position, db7 different from db4

  PMdx4Tag = ^rMdx4Tag;
  rMdx4Tag = record
    HeaderPageNo   : Integer;      // 0..3
    TagName        : array [0..10] of Char;  // 4..14 of Byte
    KeyFormat      : Byte;         // 15     00h: Calculated
                                   //        10h: Data Field
    ForwardTag1    : Byte;         // 16
    ForwardTag2    : Byte;         // 17
    BackwardTag    : Byte;         // 18
    Reserved       : Byte;         // 19
    KeyType        : Char;         // 20     C : Character
                                   //        N : Numerical
                                   //        D : Date
  end;

  PMdx7Tag = ^rMdx7Tag;
  rMdx7Tag = record
    HeaderPageNo   : Integer;      // 0..3
    TagName        : array [0..32] of Char;  // 4..36 of Byte
    KeyFormat      : Byte;         // 37     00h: Calculated
                                   //        10h: Data Field
    ForwardTag1    : Byte;         // 38
    ForwardTag2    : Byte;         // 39
    BackwardTag    : Byte;         // 40
    Reserved       : Byte;         // 41
    KeyType        : Char;         // 42     C : Character
                                   //        N : Numerical
                                   //        D : Date
  end;

  PIndexHdr = ^rIndexHdr;
  rIndexHdr = record
    RootPage       : Integer;  // 0..3
    NumPages       : Integer;  // 4..7
    KeyFormat      : Byte;     // 8      00h: Right, Left, DTOC
                               //        08h: Descending order
                               //        10h: String
                               //        20h: Distinct
                               //        40h: Unique
    KeyType        : Char;     // 9      C : Character
                               //        N : Numerical
                               //        D : Date
    Dummy          : Word;     // 10..11
    KeyLen         : Word;     // 12..13
    NumKeys        : Word;     // 14..15
    sKeyType       : Word;     // 16..17 00h: DB4: C/N; DB3: C
                               //        01h: DB4: D  ; DB3: N/D
    KeyRecLen      : Word;     // 18..19 Length of key entry in page
    Version        : Word;     // 20..21
    Dummy2         : Byte;     // 22
    Unique         : Byte;     // 23
    KeyDesc        : array [0..219] of Char; // 24..243
    Dummy3         : Byte;     // 244
    ForExist       : Byte;     // 245
    KeyExist       : Byte;     // 246
    FirstNode      : Longint;  // 248..251   first node that contains data
    LastNode       : Longint;  // 252..255   last node that contains data
                               // MDX Header has here a 506 byte block reserved
                               // and then the FILTER expression, which obviously doesn't
                               // fit in a NDX page, so we'll skip it
  end;

  PMdxEntry = ^rMdxEntry;
  rMdxEntry = record
    RecBlockNo: Longint;       // 0..3   either recno or blockno
    KeyData   : Char;          // 4..    first byte of data, context => length
  end;

  PMdxPage = ^rMdxPage;
  rMdxPage = record
    NumEntries : Integer;
    PrevBlock  : Integer;
    FirstEntry : rMdxEntry;
  end;

  PNdxEntry  = ^rNdxEntry;
  rNdxEntry  = record
    LowerPageNo: Integer;      //  0..3 lower page
    RecNo      : Integer;      //  4..7 recno
    KeyData    : Char;
  end;

  PNdxPage  = ^rNdxPage;
  rNdxPage  = record
    NumEntries: Integer;       //  0..3
    FirstEntry: rNdxEntry;
  end;

//---------------------------------------------------------------------------
  TMdxPage = class(TIndexPage)
  protected
    function GetEntry(AEntryNo: Integer): Pointer; override;
    function GetLowerPageNo: Integer; override;
    function GetKeyData: PChar; override;
    function GetNumEntries: Integer; override;
    function GetKeyDataFromEntry(AEntry: Integer): PChar; override;
    function GetRecNo: Integer; override;
    function GetIsInnerNode: Boolean; override;
    procedure IncNumEntries; override;
    procedure SetNumEntries(NewNum: Integer); override;
    procedure SetRecLowerPageNo(NewRecNo, NewPageNo: Integer); override;
    procedure SetRecLowerPageNoOfEntry(AEntry, NewRecNo, NewPageNo: Integer); override;
{$ifdef TDBF_UPDATE_FIRST_LAST_NODE}
    procedure SetPrevBlock(NewBlock: Integer); override;
{$endif}
  end;
//---------------------------------------------------------------------------
  TNdxPage = class(TIndexPage)
  protected
    function GetEntry(AEntryNo: Integer): Pointer; override;
    function GetLowerPageNo: Integer; override;
    function GetKeyData: PChar; override;
    function GetNumEntries: Integer; override;
    function GetKeyDataFromEntry(AEntry: Integer): PChar; override;
    function GetRecNo: Integer; override;
    function GetIsInnerNode: Boolean; override;
    procedure IncNumEntries; override;
    procedure SetNumEntries(NewNum: Integer); override;
    procedure SetRecLowerPageNo(NewRecNo, NewPageNo: Integer); override;
    procedure SetRecLowerPageNoOfEntry(AEntry, NewRecNo, NewPageNo: Integer); override;
  end;
//---------------------------------------------------------------------------
  TMdx4Tag = class(TIndexTag)
  protected
    function  GetHeaderPageNo: Integer; override;
    function  GetTagName: string; override;
    function  GetKeyFormat: Byte; override;
    function  GetForwardTag1: Byte; override;
    function  GetForwardTag2: Byte; override;
    function  GetBackwardTag: Byte; override;
    function  GetReserved: Byte; override;
    function  GetKeyType: Char; override;
    procedure SetHeaderPageNo(NewPageNo: Integer); override;
    procedure SetTagName(NewName: string); override;
    procedure SetKeyFormat(NewFormat: Byte); override;
    procedure SetForwardTag1(NewTag: Byte); override;
    procedure SetForwardTag2(NewTag: Byte); override;
    procedure SetBackwardTag(NewTag: Byte); override;
    procedure SetReserved(NewReserved: Byte); override;
    procedure SetKeyType(NewType: Char); override;
  end;
//---------------------------------------------------------------------------
  TMdx7Tag = class(TIndexTag)
    function  GetHeaderPageNo: Integer; override;
    function  GetTagName: string; override;
    function  GetKeyFormat: Byte; override;
    function  GetForwardTag1: Byte; override;
    function  GetForwardTag2: Byte; override;
    function  GetBackwardTag: Byte; override;
    function  GetReserved: Byte; override;
    function  GetKeyType: Char; override;
    procedure SetHeaderPageNo(NewPageNo: Integer); override;
    procedure SetTagName(NewName: string); override;
    procedure SetKeyFormat(NewFormat: Byte); override;
    procedure SetForwardTag1(NewTag: Byte); override;
    procedure SetForwardTag2(NewTag: Byte); override;
    procedure SetBackwardTag(NewTag: Byte); override;
    procedure SetReserved(NewReserved: Byte); override;
    procedure SetKeyType(NewType: Char); override;
  end;

var
  Entry_Mdx_BOF: rMdxEntry;   //(RecBOF, #0);
  Entry_Mdx_EOF: rMdxEntry;   //(RecBOF, #0);
  Entry_Ndx_BOF: rNdxEntry;   //(0, RecBOF, #0);
  Entry_Ndx_EOF: rNdxEntry;   //(0, RecEOF, #0);

  LCIDList: TLCIDList;

//==========================================================
// Locale support for all versions of Delphi/C++Builder

function LocaleCallBack(LocaleString: PChar): Integer; stdcall;
begin
  LCIDList.Add(Pointer(StrToInt('$'+LocaleString)));
  Result := 1;
end;

constructor TLCIDList.Create;
begin
  inherited;
end;

procedure TLCIDList.Enumerate;
begin
  Clear;
  EnumSystemLocales(@LocaleCallBack, LCID_SUPPORTED);
end;

//==========================================================
//============ TIndexPage
//==========================================================
constructor TIndexPage.Create(Parent: TIndexFile);
begin
  FIndexFile := Parent;
  GetMem(FPageBuffer, FIndexFile.RecordSize);
  FLowerPage := nil;
  Clear;
end;

destructor TIndexPage.Destroy;
begin
  // no locks anymore?
  assert(FLockCount = 0);
  if (FLowerPage<>nil) then
    LowerPage.Free;
  WritePage;
  FreeMemAndNil(FPageBuffer);
  inherited Destroy;
end;

procedure TIndexPage.Clear;
begin
  FillChar(PChar(FPageBuffer)^, FIndexFile.RecordSize, 0);
  FreeAndNil(FLowerPage);
  FUpperPage := nil;
  FPageNo := -1;
  FEntryNo := -1;
  FWeight := 1;
  FModified := false;
  FEntry := FIndexFile.EntryBof;
  FLowPage := 0;
  FHighPage := 0;
  FLowIndex := 0;
  FHighIndex := -1;
  FLockCount := 0;
end;

procedure TIndexPage.GetNewPage;
begin
  FPageNo := FIndexFile.GetNewPageNo;
end;

procedure TIndexPage.Modified;
begin
  FModified := true;
end;

procedure TIndexPage.LockPage;
begin
  // already locked?
  if FLockCount = 0 then
    FIndexFile.LockPage(FPageNo, true);
  // increase count
  inc(FLockCount);
end;

procedure TIndexPage.UnlockPage;
begin
  // still in domain?
  assert(FLockCount > 0);
  dec(FLockCount);
  // unlock?
  if FLockCount = 0 then
  begin
    if FIndexFile.NeedLocks then
      WritePage;
    FIndexFile.UnlockPage(FPageNo);
  end;
end;

procedure TIndexPage.LocalInsert(RecNo: Integer; Buffer: PChar; LowerPageNo: Integer);
  // *) assumes there is at least one entry free
var
  source, dest: Pointer;
  size, lNumEntries, numKeysAvail: Integer;
begin
  // lock page if needed; wait if not available, anyone else updating?
  LockPage;
  // check assertions
  lNumEntries := GetNumEntries;
  // if this is inner node, we can only store one less than max entries
  numKeysAvail := PIndexHdr(FIndexFile.IndexHeader)^.NumKeys - lNumEntries;
  if FLowerPage <> nil then
    dec(numKeysAvail);
  // check if free space
  assert(numKeysAvail > 0);
  // first free up some space
  source := FEntry;
  dest := GetEntry(FEntryNo + 1);
  size := (lNumEntries - EntryNo) * PIndexHdr(FIndexFile.IndexHeader)^.KeyRecLen;
  // if 'rightmost' entry, copy pageno too
  if (FLowerPage <> nil) or (numKeysAvail > 1) then
    size := size + FIndexFile.EntryHeaderSize;
  Move(source^, dest^, size);
  // one entry added
  Inc(FHighIndex);
  IncNumEntries;
  // lNumEntries not valid from here
  SetEntry(RecNo, Buffer, LowerPageNo);
  // done!
  UnlockPage;
end;

procedure TIndexPage.LocalDelete;

  function IsOnlyEntry(Page: TIndexPage): boolean;
  begin
    Result := true;
    repeat
      if Page.HighIndex > 0 then
        Result := false;
      Page := Page.UpperPage;
    until not Result or (Page = nil);
  end;

var
  source, dest: Pointer;
  size, lNumEntries: Integer;
begin
  // get num entries
  lNumEntries := GetNumEntries;
  // is this last entry? if it's not move entries after current one
  if EntryNo < FHighIndex then
  begin
    source := GetEntry(EntryNo + 1);
    dest := FEntry;
    size := (FHighIndex - EntryNo) * PIndexHdr(FIndexFile.IndexHeader)^.KeyRecLen;
    Move(source^, dest^, size);
  end else
  // no need to update when we're about to remove the only entry
  if (UpperPage <> nil) and (FHighIndex > FLowIndex) then
  begin
    // we are about to remove the last on this page, so update search
    // key data of parent
    EntryNo := FHighIndex - 1;
    UpperPage.SetEntry(0, GetKeyData, FPageNo);
  end;
  // one entry less now
  dec(lNumEntries);
  dec(FHighIndex);
  SetNumEntries(lNumEntries);
  // zero last one out to not get confused about internal or leaf pages
  // note: need to decrease lNumEntries and HighIndex first, otherwise
  //   check on page key consistency will fail
  SetRecLowerPageNoOfEntry(FHighIndex+1, 0, 0);
  // update bracket indexes
  if FHighPage = FPageNo then
    dec(FHighBracket);
  // check if range violated
  if EntryNo > FHighIndex then
    EntryNo := FHighIndex;
  // check if still entries left, otherwise remove page from parent
  if FHighIndex = -1 then
  begin
    if UpperPage <> nil then
      if not IsOnlyEntry(UpperPage) then
        UpperPage.LocalDelete;
  end;
  // go to valid record in lowerpage
  if FLowerPage <> nil then
    SyncLowerPage;
  // flag modified page
  FModified := true;
  // success!
end;

function TIndexPage.MatchKey: Integer;
  // assumes Buffer <> nil
var
  keyData: PChar;
begin
  // get key data
  keyData := GetKeyData;
  // use locale dependant compare
  Result := FIndexFile.CompareKey(keyData);
end;

function TIndexPage.FindNearest(ARecNo: Integer): Integer;
  // pre:
  //  assumes Key <> nil
  //  assumes FLowIndex <= FHighIndex + 1
  //  ARecNo = -2 -> search first key matching Key
  //  ARecNo = -3 -> search first key greater than Key
  //  ARecNo >  0 -> search key matching Key and its recno = ARecNo
  // post:
  //  Result < 0  -> key,recno smaller than current entry
  //  Result = 0  -> key,recno found, FEntryNo = found key entryno
  //  Result > 0  -> key,recno larger than current entry
var
  low, high, current: Integer;
begin
  // implement binary search, keys are sorted
  low := FLowIndex;
  high := GetNumEntries;
  // always true: Entry(FEntryNo) = FEntry
  // FHighIndex >= 0 because no-entry cases in leaves have been filtered out
  // entry HighIndex may not be bigger than rest (in inner node)
  // ARecNo = -3 -> search last recno matching key
  // need to have: low <= high
  // define low - 1 = neg.inf.
  // define high = pos.inf
  // inv1: (ARecNo<>-3) -> Entry(low-1).Key <  Key <= Entry(high).Key
  // inv2: (ARecNo =-3) -> Entry(low-1).Key <= Key <  Entry(high).Key
  // vf: high + 1 - low
  while low < high do
  begin
    current := (low + high) div 2;
    FEntry := GetEntry(current);
    // calc diff
    Result := MatchKey;
    // test if we need to go lower or higher
    // result < 0 implies key smaller than tested entry
    // result = 0 implies key equal to tested entry
    // result > 0 implies key greater than tested entry
    if (Result < 0) or ((ARecNo<>-3) and (Result=0)) then
      high := current
    else
      low := current+1;
  end;
  // high will contain first greater-or-equal key
  // ARecNo <> -3 -> Entry(high).Key will contain first key that matches    -> go to high
  // ARecNo =  -3 -> Entry(high).Key will contain first key that is greater -> go to high
  FEntryNo := -1;
  EntryNo := high;
  // calc end result: can't inspect high if lowerpage <> nil
  // if this is a leaf, we need to find specific recno
  if (LowerPage = nil) then
  begin
    if high > FHighIndex then
    begin
      Result := 1;
    end else begin
      Result := MatchKey;
      // test if we need to find a specific recno
      // result < 0 -> current key greater -> nothing found -> don't search
      if (ARecNo > 0) then
      begin
        // BLS to RecNo
        high := FHighIndex + 1;
        low := FEntryNo;
        // inv: FLowIndex <= FEntryNo <= high <= FHighIndex + 1 /\
        // (Ai: FLowIndex <= i < FEntryNo: Entry(i).RecNo <> ARecNo)
        while FEntryNo <> high do
        begin
          // FEntryNo < high, get new entry
          if low <> FEntryNo then
          begin
            FEntry := GetEntry(FEntryNo);
            // check if entry key still ok
            Result := MatchKey;
          end;
          // test if out of range or found recno
          if (Result <> 0) or (GetRecNo = ARecNo) then
            high := FEntryNo
          else begin
            // default to EOF
            inc(FEntryNo);
            Result := 1;
          end;
        end;
      end;
    end;
  end else begin
    // FLowerPage <> nil -> high contains entry, can not have empty range
    Result := 0;
  end;
end;

procedure TIndexPage.GotoInsertEntry;
  // assures we really can insert here
begin
  if FEntry = FIndexFile.EntryEof then
    FEntry := GetEntry(FEntryNo);
end;

procedure TIndexPage.SetEntry(RecNo: Integer; AKey: PChar; LowerPageNo: Integer);
var
  keyData: PChar;
{$ifdef TDBF_INDEX_CHECK}
  prevKeyData, curKeyData, nextKeyData: PChar;
{$endif}
begin
  // get num entries
  keyData := GetKeyData;
  // check valid entryno: we should be able to insert entries!
  assert((EntryNo >= 0) and (EntryNo <= FHighIndex));
  if (UpperPage <> nil) and (FEntryNo = FHighIndex) then
    UpperPage.SetEntry(0, AKey, FPageNo);
{  if PIndexHdr(FIndexFile.IndexHeader).KeyType = 'C' then  }
    if AKey <> nil then
      Move(AKey^, keyData^, PIndexHdr(FIndexFile.IndexHeader)^.KeyLen)
    else
      PChar(keyData)^ := #0;
{
  else
    if AKey <> nil then
      PDouble(keyData)^ := PDouble(AKey)^
    else
      PDouble(keyData)^ := 0.0;
}
  // set entry info
  SetRecLowerPageNo(RecNo, LowerPageNo);
  // flag we modified the page
  FModified := true;

{$ifdef TDBF_INDEX_CHECK}

    // check sorted entry sequence
    prevKeyData := GetKeyDataFromEntry(FEntryNo-1);
    curKeyData  := GetKeyDataFromEntry(FEntryNo+0);
    nextKeyData := GetKeyDataFromEntry(FEntryNo+1);
    // check if prior entry not greater, 'rightmost' key does not have to match
    if (FEntryNo > 0) and ((FLowerPage = nil) or (FEntryNo < FHighIndex)) then
    begin
      if FIndexFile.CompareKeys(prevKeyData, curKeyData) > 0 then
        assert(false);
    end;
    // check if next entry not smaller
    if ((FLowerPage = nil) and (FEntryNo < FHighIndex)) or
        ((FLowerPage <> nil) and (FEntryNo < (FHighIndex - 1))) then
    begin
      if FIndexFile.CompareKeys(curKeyData, nextKeyData) > 0 then
        assert(false);
    end;

{$endif}

end;

{$ifdef TDBF_UPDATE_FIRST_LAST_NODE}

procedure TIndexPage.SetPrevBlock(NewBlock: Integer);
begin
end;

{$endif}

procedure TIndexPage.Split;
  // *) assumes this page is `nearly' full
var
  NewPage: TIndexPage;
  source, dest: Pointer;
  paKeyData: PChar;
  size, oldEntryNo: Integer;
  splitRight, lNumEntries, numEntriesNew: Integer;
  saveLow, saveHigh: Integer;
  newRoot: Boolean;
begin
  // assure parent exists, if not -> create & lock, else lock it
  newRoot := FUpperPage = nil;
  if newRoot then
    FIndexFile.AddNewLevel
  else
    FUpperPage.LockPage;

  // lock this page for updates
  LockPage;

  // get num entries
  lNumEntries := GetNumEntries;

  // calc split pos: split in half
  splitRight := lNumEntries div 2;
  if (FLowerPage <> nil) and (lNumEntries mod 2 = 1) then
    inc(splitRight);
  numEntriesNew := lNumEntries - splitRight;
  // check if place to insert has least entries
  if (numEntriesNew > splitRight) and (EntryNo > splitRight) then
  begin
    inc(splitRight);
    dec(numEntriesNew);
  end else if (numEntriesNew < splitRight) and (EntryNo < splitRight) then
  begin
    dec(splitRight);
    inc(numEntriesNew);
  end;
  // save current entryno
  oldEntryNo := EntryNo;
  // check if we need to save high / low bound
  if FLowPage = FPageNo then
    saveLow := FLowIndex
  else
    saveLow := -1;
  if FHighPage = FPageNo then
    saveHigh := FHighIndex
  else
    saveHigh := -1;

  // create new page
  NewPage := TIndexPageClass(ClassType).Create(FIndexFile);
  try
    // get page
    NewPage.GetNewPage;
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
    NewPage.SetPrevBlock(NewPage.PageNo - FIndexFile.PagesPerRecord);
{$endif}

    // set modified
    FModified := true;
    NewPage.FModified := true;

    // compute source, dest
    dest := NewPage.GetEntry(0);
    source := GetEntry(splitRight);
    size := numEntriesNew * PIndexHdr(FIndexFile.IndexHeader)^.KeyRecLen;
    // if inner node, copy rightmost entry too
    if FLowerPage <> nil then
      size := size + FIndexFile.EntryHeaderSize;
    // copy bytes
    Move(source^, dest^, size);
    // if not inner node, clear possible 'rightmost' entry
    if (FLowerPage = nil) then
      SetRecLowerPageNoOfEntry(splitRight, 0, 0);

    // calc new number of entries of this page
    lNumEntries := lNumEntries - numEntriesNew;
    // if lower level, then we need adjust for new 'rightmost' node
    if FLowerPage <> nil then
    begin
      // right split, so we need 'new' rightmost node
      dec(lNumEntries);
    end;
    // store new number of nodes
    // new page is right page, so update parent to point to new right page
    NewPage.SetNumEntries(numEntriesNew);
    SetNumEntries(lNumEntries);
    // update highindex
    FHighIndex := lNumEntries;
    if FLowerPage = nil then
      dec(FHighIndex);

    // get data of last entry on this page
    paKeyData := GetKeyDataFromEntry(splitRight - 1);

    // reinsert ourself into parent
//    FUpperPage.RecurInsert(0, paKeyData, FPageNo);
    // we can do this via a localinsert now: we know there is at least one entry
    // free in this page and higher up
    FUpperPage.LocalInsert(0, paKeyData, FPageNo);

    // new page is right page, so update parent to point to new right page
    // we can't do this earlier: we will get lost in tree!
    FUpperPage.SetRecLowerPageNoOfEntry(FUpperPage.EntryNo+1, 0, NewPage.PageNo);

    // NOTE: UpperPage.LowerPage = Self <= inserted FPageNo, not NewPage.PageNo
  finally
    NewPage.Free;
  end;

  // done updating: unlock page
  UnlockPage;
  // save changes to parent
  FUpperPage.UnlockPage;

  // unlock new root, unlock header too
  FIndexFile.UnlockHeader;

  // go to entry we left on
  if oldEntryNo >= splitRight then
  begin
    // sync upperpage with right page
    FUpperPage.EntryNo := FUpperPage.EntryNo + 1;
    FEntryNo := oldEntryNo - splitRight;
    FEntry := GetEntry(FEntryNo);
  end else begin
    // in left page = this page
    EntryNo := oldEntryNo;
  end;

  // check if we have to save high / low bound
  // seen the fact that FHighPage = FPageNo -> EntryNo <= FHighIndex, it can in
  // theory not happen that page is advanced to right page and high bound remains
  // on left page, but we won't check for that here
  if saveLow >= splitRight then
  begin
    FLowPage := FPageNo;
    FLowIndex := saveLow - splitRight;
  end;
  if saveHigh >= splitRight then
  begin
    FHighPage := FPageNo;
    FHighIndex := saveHigh - splitRight;
  end;
end;

procedure TIndexPage.Delete;
begin
  LocalDelete;
end;

procedure TIndexPage.WritePage;
begin
  // check if we modified current page
  if FModified and (FPageNo > 0) then
  begin
    FIndexFile.WriteRecord(FPageNo, FPageBuffer);
    FModified := false;
  end;
end;

procedure TIndexPage.Flush;
begin
  WritePage;
  if FLowerPage <> nil then
    FLowerPage.Flush;
end;

procedure TIndexPage.RecalcWeight;
begin
  if FLowerPage <> nil then
  begin
    FWeight := FLowerPage.Weight * PIndexHdr(FIndexFile.IndexHeader)^.NumKeys;
  end else begin
    FWeight := 1;
  end;
  if FUpperPage <> nil then
    FUpperPage.RecalcWeight;
end;

procedure TIndexPage.UpdateWeight;
begin
  if FLowerPage <> nil then
    FLowerPage.UpdateWeight
  else
    RecalcWeight;
end;

procedure TIndexPage.SetUpperPage(NewPage: TIndexPage);
begin
  if FUpperPage <> NewPage then
  begin
    // root height changed: update weights
    FUpperPage := NewPage;
    UpdateWeight;
  end;
end;

procedure TIndexPage.SetLowPage(NewPage: Integer);
begin
  if FLowPage <> NewPage then
  begin
    FLowPage := NewPage;
    UpdateBounds(FLowerPage <> nil);
  end;
end;

procedure TIndexPage.SetHighPage(NewPage: Integer);
begin
  if FHighPage <> NewPage then
  begin
    FHighPage := NewPage;
    UpdateBounds(FLowerPage <> nil);
  end;
end;

procedure TIndexPage.UpdateBounds(IsInnerNode: Boolean);
begin
  // update low / high index range
  if FPageNo = FLowPage then
    FLowIndex := FLowBracket
  else
    FLowIndex := 0;
  if FPageNo = FHighPage then
    FHighIndex := FHighBracket
  else begin
    FHighIndex := GetNumEntries;
    if not IsInnerNode then
      dec(FHighIndex);
  end;
end;

function TMdxPage.GetIsInnerNode: Boolean;
begin
  Result := PMdxPage(FPageBuffer)^.NumEntries < PIndexHdr(FIndexFile.IndexHeader)^.NumKeys;
  // if there is still an entry after the last one, this has to be an inner node
  if Result then
    Result := PMdxEntry(GetEntry(PMdxPage(FPageBuffer)^.NumEntries))^.RecBlockNo <> 0;
end;

function TNdxPage.GetIsInnerNode: Boolean;
begin
  Result := PNdxEntry(GetEntry(0))^.LowerPageNo <> 0;
end;

procedure TIndexPage.SetPageNo(NewPageNo: Integer);
var
  isInnerNode: Boolean;
begin
  if (NewPageNo <> FPageNo) or FIndexFile.NeedLocks then
  begin
    // save changes
    WritePage;
    // no locks
    assert(FLockCount = 0);

    // goto new page
    FPageNo := NewPageNo;
    // remind ourselves we need to load new entry when page loaded
    FEntryNo := -1;
    if (NewPageNo > 0) and (NewPageNo <= FIndexFile.RecordCount) then
    begin
      // read page from disk
      FIndexFile.ReadRecord(NewPageNo, FPageBuffer);

      // fixup descending tree
      isInnerNode := GetIsInnerNode;

      // update low / high index range
      UpdateBounds(isInnerNode);

      // read inner node if any
      if isInnerNode then
      begin
        if FLowerPage = nil then
        begin
          FLowerPage := TIndexPageClass(ClassType).Create(FIndexFile);
          FLowerPage.UpperPage := Self;
        end;
        // read first entry, don't do this sooner, not created lowerpage yet
        // don't recursively resync all lower pages
{$ifdef TDBF_INDEX_CHECK}
      end else if FLowerPage <> nil then
      begin
//        FLowerPage.Free;
//        FLowerPage := nil;
        assert(false);
{$endif}
      end else begin
        // we don't have to check autoresync here because we're already at lowest level
        EntryNo := FLowIndex;
      end;
    end;
  end;
end;

procedure TIndexPage.SyncLowerPage;
  // *) assumes FLowerPage <> nil!
begin
  FLowerPage.PageNo := GetLowerPageNo;
end;

procedure TIndexPage.SetEntryNo(value: Integer);
begin
  // do not bother if no change
  if value <> FEntryNo then
  begin
    // check if out of range
    if (value < FLowIndex) then
    begin
      if FLowerPage = nil then
        FEntryNo := FLowIndex - 1;
      FEntry := FIndexFile.EntryBof;
    end else if value > FHighIndex then begin
      FEntryNo := FHighIndex + 1;
      FEntry := FIndexFile.EntryEof;
    end else begin
      FEntryNo := value;
      FEntry := GetEntry(value);
      // sync lowerpage with entry
      if (FLowerPage <> nil) then
        SyncLowerPage;
    end;
  end;
end;

function TIndexPage.PhysicalRecNo: Integer;
var
  entryRec: Integer;
begin
  // get num entries
  entryRec := GetRecNo;
  // check if in range
  if (FEntryNo >= FLowIndex) and (FEntryNo <= FHighIndex) then
    Result := entryRec
  else
    Result := -1;
end;

function TIndexPage.RecurPrev: Boolean;
begin
  EntryNo := EntryNo - 1;
  Result := Entry <> FIndexFile.EntryBof;
  if Result then
  begin
    if FLowerPage <> nil then
    begin
      FLowerPage.RecurLast;
    end;
  end else begin
    if FUpperPage<>nil then
    begin
      Result := FUpperPage.RecurPrev;
    end;
  end;
end;

function TIndexPage.RecurNext: Boolean;
begin
  EntryNo := EntryNo + 1;
  Result := Entry <> FIndexFile.EntryEof;
  if Result then
  begin
    if FLowerPage <> nil then
    begin
      FLowerPage.RecurFirst;
    end;
  end else begin
    if FUpperPage<>nil then
    begin
      Result := FUpperPage.RecurNext;
    end;
  end;
end;

procedure TIndexPage.RecurFirst;
begin
  EntryNo := FLowIndex;
  if (FLowerPage<>nil) then
    FLowerPage.RecurFirst;
end;

procedure TIndexPage.RecurLast;
begin
  EntryNo := FHighIndex;
  if (FLowerPage<>nil) then
    FLowerPage.RecurLast;
end;

//==============================================================================
//============ Mdx specific access routines
//==============================================================================

function TMdxPage.GetEntry(AEntryNo: Integer): Pointer;
begin
  // get base + offset
  Result := PChar(@PMdxPage(PageBuffer)^.FirstEntry) + (PIndexHdr(
    IndexFile.IndexHeader)^.KeyRecLen * AEntryNo);
end;

function TMdxPage.GetLowerPageNo: Integer;
  // *) assumes LowerPage <> nil
begin
//  if LowerPage = nil then
//    Result := 0
//  else
    Result := PMdxEntry(Entry)^.RecBlockNo;
end;

function TMdxPage.GetKeyData: PChar;
begin
  Result := @PMdxEntry(Entry)^.KeyData;
end;

function TMdxPage.GetNumEntries: Integer;
begin
  Result := PMdxPage(PageBuffer)^.NumEntries;
end;

function TMdxPage.GetKeyDataFromEntry(AEntry: Integer): PChar;
begin
  Result := @PMdxEntry(GetEntry(AEntry))^.KeyData;
end;

function TMdxPage.GetRecNo: Integer;
begin
  Result := PMdxEntry(Entry)^.RecBlockNo;
end;

procedure TMdxPage.SetNumEntries(NewNum: Integer);
begin
  PMdxPage(PageBuffer)^.NumEntries := NewNum;
end;

procedure TMdxPage.IncNumEntries;
begin
  Inc(PMdxPage(PageBuffer)^.NumEntries);
end;

procedure TMdxPage.SetRecLowerPageNo(NewRecNo, NewPageNo: Integer);
begin
  if FLowerPage = nil then
    PMdxEntry(Entry)^.RecBlockNo := NewRecNo
  else
    PMdxEntry(Entry)^.RecBlockNo := NewPageNo;
end;

procedure TMdxPage.SetRecLowerPageNoOfEntry(AEntry, NewRecNo, NewPageNo: Integer);
begin
  if FLowerPage = nil then
    PMdxEntry(GetEntry(AEntry))^.RecBlockNo := NewRecNo
  else
    PMdxEntry(GetEntry(AEntry))^.RecBlockNo := NewPageNo;
end;

{$ifdef TDBF_UPDATE_FIRST_LAST_NODE}

procedure TMdxPage.SetPrevBlock(NewBlock: Integer);
begin
  PMdxPage(PageBuffer)^.PrevBlock := NewBlock;
end;

{$endif}

//==============================================================================
//============ Ndx specific access routines
//==============================================================================

function TNdxPage.GetEntry(AEntryNo: Integer): Pointer;
begin
  // get base + offset
  Result := PChar(@PNdxPage(PageBuffer)^.FirstEntry) + (PIndexHdr(FIndexFile.IndexHeader)^.KeyRecLen * AEntryNo);
end;

function TNdxPage.GetLowerPageNo: Integer;
  // *) assumes LowerPage <> nil
begin
//  if LowerPage = nil then
//    Result := 0
//  else
    Result := PNdxEntry(Entry)^.LowerPageNo
end;

function TNdxPage.GetRecNo: Integer;
begin
  Result := PNdxEntry(Entry)^.RecNo;
end;

function TNdxPage.GetKeyData: PChar;
begin
  Result := @PNdxEntry(Entry)^.KeyData;
end;

function TNdxPage.GetKeyDataFromEntry(AEntry: Integer): PChar;
begin
  Result := @PNdxEntry(GetEntry(AEntry))^.KeyData;
end;

function TNdxPage.GetNumEntries: Integer;
begin
  Result := PNdxPage(PageBuffer)^.NumEntries;
end;

procedure TNdxPage.IncNumEntries;
begin
  Inc(PNdxPage(PageBuffer)^.NumEntries);
end;

procedure TNdxPage.SetNumEntries(NewNum: Integer);
begin
  PNdxPage(PageBuffer)^.NumEntries := NewNum;
end;

procedure TNdxPage.SetRecLowerPageNo(NewRecNo, NewPageNo: Integer);
begin
  PNdxEntry(Entry)^.RecNo := NewRecNo;
  PNdxEntry(Entry)^.LowerPageNo := NewPageNo;
end;

procedure TNdxPage.SetRecLowerPageNoOfEntry(AEntry, NewRecNo, NewPageNo: Integer);
begin
  PNdxEntry(GetEntry(AEntry))^.RecNo := NewRecNo;
  PNdxEntry(GetEntry(AEntry))^.LowerPageNo := NewPageNo;
end;

//==============================================================================
//============ MDX version 4 header access routines
//==============================================================================

function TMdx4Tag.GetHeaderPageNo: Integer;
begin
  Result := PMdx4Tag(Tag)^.HeaderPageNo;
end;

function TMdx4Tag.GetTagName: string;
begin
  Result := PMdx4Tag(Tag)^.TagName;
end;

function TMdx4Tag.GetKeyFormat: Byte;
begin
  Result := PMdx4Tag(Tag)^.KeyFormat;
end;

function TMdx4Tag.GetForwardTag1: Byte;
begin
  Result := PMdx4Tag(Tag)^.ForwardTag1;
end;

function TMdx4Tag.GetForwardTag2: Byte;
begin
  Result := PMdx4Tag(Tag)^.ForwardTag2;
end;

function TMdx4Tag.GetBackwardTag: Byte;
begin
  Result := PMdx4Tag(Tag)^.BackwardTag;
end;

function TMdx4Tag.GetReserved: Byte;
begin
  Result := PMdx4Tag(Tag)^.Reserved;
end;

function TMdx4Tag.GetKeyType: Char;
begin
  Result := PMdx4Tag(Tag)^.KeyType;
end;

procedure TMdx4Tag.SetHeaderPageNo(NewPageNo: Integer);
begin
  PMdx4Tag(Tag)^.HeaderPageNo := NewPageNo;
end;

procedure TMdx4Tag.SetTagName(NewName: string);
begin
  StrPLCopy(PMdx4Tag(Tag)^.TagName, NewName, 10);
  PMdx4Tag(Tag)^.TagName[10] := #0;
end;

procedure TMdx4Tag.SetKeyFormat(NewFormat: Byte);
begin
  PMdx4Tag(Tag)^.KeyFormat := NewFormat;
end;

procedure TMdx4Tag.SetForwardTag1(NewTag: Byte);
begin
  PMdx4Tag(Tag)^.ForwardTag1 := NewTag;
end;

procedure TMdx4Tag.SetForwardTag2(NewTag: Byte);
begin
  PMdx4Tag(Tag)^.ForwardTag2 := NewTag;
end;

procedure TMdx4Tag.SetBackwardTag(NewTag: Byte);
begin
  PMdx4Tag(Tag)^.BackwardTag := NewTag;
end;

procedure TMdx4Tag.SetReserved(NewReserved: Byte);
begin
  PMdx4Tag(Tag)^.Reserved := NewReserved;
end;

procedure TMdx4Tag.SetKeyType(NewType: Char);
begin
  PMdx4Tag(Tag)^.KeyType := NewType;
end;

//==============================================================================
//============ MDX version 7 headertag access routines
//==============================================================================

function TMdx7Tag.GetHeaderPageNo: Integer;
begin
  Result := PMdx7Tag(Tag)^.HeaderPageNo;
end;

function TMdx7Tag.GetTagName: string;
begin
  Result := PMdx7Tag(Tag)^.TagName;
end;

function TMdx7Tag.GetKeyFormat: Byte;
begin
  Result := PMdx7Tag(Tag)^.KeyFormat;
end;

function TMdx7Tag.GetForwardTag1: Byte;
begin
  Result := PMdx7Tag(Tag)^.ForwardTag1;
end;

function TMdx7Tag.GetForwardTag2: Byte;
begin
  Result := PMdx7Tag(Tag)^.ForwardTag2;
end;

function TMdx7Tag.GetBackwardTag: Byte;
begin
  Result := PMdx7Tag(Tag)^.BackwardTag;
end;

function TMdx7Tag.GetReserved: Byte;
begin
  Result := PMdx7Tag(Tag)^.Reserved;
end;

function TMdx7Tag.GetKeyType: Char;
begin
  Result := PMdx7Tag(Tag)^.KeyType;
end;

procedure TMdx7Tag.SetHeaderPageNo(NewPageNo: Integer);
begin
  PMdx7Tag(Tag)^.HeaderPageNo := NewPageNo;
end;

procedure TMdx7Tag.SetTagName(NewName: string);
begin
  StrPLCopy(PMdx7Tag(Tag)^.TagName, NewName, 32);
  PMdx7Tag(Tag)^.TagName[32] := #0;
end;

procedure TMdx7Tag.SetKeyFormat(NewFormat: Byte);
begin
  PMdx7Tag(Tag)^.KeyFormat := NewFormat;
end;

procedure TMdx7Tag.SetForwardTag1(NewTag: Byte);
begin
  PMdx7Tag(Tag)^.ForwardTag1 := NewTag;
end;

procedure TMdx7Tag.SetForwardTag2(NewTag: Byte);
begin
  PMdx7Tag(Tag)^.ForwardTag2 := NewTag;
end;

procedure TMdx7Tag.SetBackwardTag(NewTag: Byte);
begin
  PMdx7Tag(Tag)^.BackwardTag := NewTag;
end;

procedure TMdx7Tag.SetReserved(NewReserved: Byte);
begin
  PMdx7Tag(Tag)^.Reserved := NewReserved;
end;

procedure TMdx7Tag.SetKeyType(NewType: Char);
begin
  PMdx7Tag(Tag)^.KeyType := NewType;
end;

//==============================================================================
//============ TIndexFile
//==============================================================================
constructor TIndexFile.Create(ADbfFile: Pointer);
var
  I: Integer;
begin
  inherited Create;

  // clear variables
  FOpened := false;
  FRangeActive := false;
  FUpdateMode := umCurrent;
  FModifyMode := mmNormal;
  FTempMode := TDbfFile(ADbfFile).TempMode;
  SelectIndexVars(-1);
  for I := 0 to MaxIndexes - 1 do
  begin
    FParsers[I] := nil;
    FRoots[I] := nil;
    FLeaves[I] := nil;
    FIndexHeaderModified[I] := false;
  end;

  // store pointer to `parent' dbf file
  FDbfFile := ADbfFile;
end;

destructor TIndexFile.Destroy;
begin
  // close file
  Close;

  // call ancestor
  inherited Destroy;
end;

procedure TIndexFile.Open;
var
  I: Integer;
  ext: string;
  localeError: TLocaleError;
  localeSolution: TLocaleSolution;
  DbfLangId: Byte;
begin
  if not FOpened then
  begin
    // open physical file
    OpenFile;

    // page offsets are not related to header length
    PageOffsetByHeader := false;
    // we need physical page locks
    VirtualLocks := false;

    // not selected index expression => can't edit yet
    FCanEdit := false;
    FUserKey := nil;
    FUserRecNo := -1;
    FHeaderLocked := -1;
    FHeaderPageNo := 0;
    FForceClose := false;
    FForceReadOnly := false;
    FMdxTag := nil;

    // get index type
    ext := UpperCase(ExtractFileExt(FileName));
    if (ext = '.MDX') then
    begin
      FEntryHeaderSize := 4;
      FPageHeaderSize := 8;
      FEntryBof := @Entry_Mdx_BOF;
      FEntryEof := @Entry_Mdx_EOF;
      HeaderSize := 2048;
      RecordSize := 1024;
      PageSize := 512;
      if FileCreated then
      begin
        FIndexVersion := TDbfFile(FDbfFile).DbfVersion;
        if FIndexVersion = xBaseIII then
          FIndexVersion := xBaseIV;
      end else begin
        case PMdxHdr(Header)^.MdxVersion of
          3: FIndexVersion := xBaseVII;
        else
          FIndexVersion := xBaseIV;
        end;
      end;
      case FIndexVersion of
        xBaseVII:
          begin
            FMdxTag := TMdx7Tag.Create;
            FTempMdxTag := TMdx7Tag.Create;
          end;
      else
        FMdxTag := TMdx4Tag.Create;
        FTempMdxTag := TMdx4Tag.Create;
      end;
      // get mem for all index headers..we're going to cache these
      for I := 0 to MaxIndexes - 1 do
      begin
        GetMem(FIndexHeaders[I], RecordSize);
        FillChar(FIndexHeaders[I]^, RecordSize, 0);
      end;
      // set pointers to first index
      FIndexHeader := FIndexHeaders[0];
    end else begin
      // don't waste memory on another header block: we can just use
      // the pagedfile one, there is only one index in this file
      FIndexVersion := xBaseIII;
      FEntryHeaderSize := 8;
      FPageHeaderSize := 4;
      FEntryBof := @Entry_Ndx_BOF;
      FEntryEof := @Entry_Ndx_EOF;
      HeaderSize := 512;
      RecordSize := 512;
      // have to read header first before we can assign following vars
      FIndexHeaders[0] := Header;
      FIndexHeader := Header;
      // create default root
      FParsers[0] := TDbfParser.Create(FDbfFile);
      FRoots[0] := TNdxPage.Create(Self);
      FCurrentParser := FParsers[0];
      FRoot := FRoots[0];
      FSelectedIndex := 0;
      // parse index expression
      FCurrentParser.ParseExpression(PIndexHdr(FIndexHeader)^.KeyDesc);
      // set index locale
      InternalLocaleID := LCID(lcidBinary);
    end;

    // determine how to open file
    if FileCreated then
    begin
      FillChar(Header^, HeaderSize, 0);
      Clear;
    end else begin
      // determine locale type
      localeError := leNone;
      if (FIndexVersion >= xBaseIV) then
      begin
        // get parent language id
        DbfLangId := GetDbfLanguageId;
        // no ID?
        if (DbfLangId = 0) { and (TDbfFile(FDbfFile).DbfVersion = xBaseIII)} then
        begin
          // if dbf is version 3, no language id, if no MDX language, use binary
          if PMdxHdr(Header)^.Language = 0 then
            InternalLocaleID := lcidBinary
          else
            InternalLocaleID := LangId_To_Locale[PMdxHdr(Header)^.Language];
        end else begin
          // check if MDX - DBF language id's match
          if (PMdxHdr(Header)^.Language = 0) or (PMdxHdr(Header)^.Language = DbfLangId) then
            InternalLocaleID := LangId_To_Locale[DbfLangId]
          else
            localeError := leTableIndexMismatch;
        end;
        // don't overwrite previous error
        if (FLocaleID = DbfLocale_NotFound) and (localeError = leNone) then
          localeError := leUnknown;
      end else begin
        // dbase III always binary?
        InternalLocaleID := lcidBinary;
      end;
      // check if selected locale is available, binary is always available...
      if (localeError <> leNone) and (FLocaleID <> LCID(lcidBinary)) then
      begin
        if LCIDList.IndexOf(Pointer(FLocaleID)) < 0 then
          localeError := leNotAvailable;
      end;
      // check if locale error detected
      if localeError <> leNone then
      begin
        // provide solution, well, solution...
        localeSolution := lsNotOpen;
        // call error handler
        if Assigned(FOnLocaleError) then
          FOnLocaleError(localeError, localeSolution);
        // act to solution
        case localeSolution of
          lsNotOpen: FForceClose := true;
          lsNoEdit: FForceReadOnly := true;
        else
          // `trust' user knows correct locale
          InternalLocaleID := LCID(localeSolution);
        end;
      end;
      // now read info
      if not ForceClose then
        ReadIndexes;
    end;
    // default to update all
    UpdateMode := umAll;
    // flag open
    FOpened := true;
  end;
end;

procedure TIndexFile.Close;
var
  I: Integer;
begin
  if FOpened then
  begin
    // save headers
    Flush;

    // remove parser reference
    FCurrentParser := nil;

    // free roots
    if FIndexVersion >= xBaseIV then
    begin
      for I := 0 to MaxIndexes - 1 do
      begin
        FreeMemAndNil(FIndexHeaders[I]);
        FreeAndNil(FParsers[I]);
        FreeAndNil(FRoots[I]);
      end;
    end else begin
      FreeAndNil(FRoot);
    end;

    // free mem
    FMdxTag.Free;
    FTempMdxTag.Free;

    // close physical file
    CloseFile;

    // not opened any more
    FOpened := false;
  end;
end;

procedure TIndexFile.ClearRoots;
  //
  // *) assumes FIndexVersion >= xBaseIV
  //
var
  I, prevIndex: Integer;
begin
  prevIndex := FSelectedIndex;
  for I := 0 to MaxIndexes - 1 do
  begin
    SelectIndexVars(I);
    if FRoot <> nil then
    begin
      // clear this entry
      ClearIndex;
      FLeaves[I] := FRoots[I];
    end;
  end;
  // reselect previously selected index
  SelectIndexVars(prevIndex);
  // deselect index
end;

procedure WriteDBFileName(Header: PMdxHdr; HdrFileName: string);
var
  HdrFileExt: string;
  lPos, lenFileName: integer;
begin
  HdrFileName := ExtractFileName(HdrFileName);
  HdrFileExt := ExtractFileExt(HdrFileName);
  if Length(HdrFileExt) > 0 then
  begin
    lPos := System.Pos(HdrFileExt, HdrFileName);
    if lPos > 0 then
      SetLength(HdrFileName, lPos - 1);
  end;
  if Length(HdrFileName) > 15 then
    SetLength(HdrFileName, 15);
  lenFileName := Length(HdrFileName);
  Move(PChar(HdrFileName)^, PMdxHdr(Header)^.FileName[0], lenFileName);
  FillChar(PMdxHdr(Header)^.FileName[lenFileName], 15-lenFileName, 0);
end;

procedure TIndexFile.Clear;
var
  year, month, day: Word;
  pos, prevSelIndex: Integer;
  DbfLangId: Byte;
begin
  // flush cache to prevent reading corrupted data
  Flush;
  // completely erase index
  if FIndexVersion >= xBaseIV then
  begin
    DecodeDate(Now, year, month, day);
    if FIndexVersion = xBaseVII then
      PMdxHdr(Header)^.MdxVersion := 3
    else  
      PMdxHdr(Header)^.MdxVersion := 2;
    PMdxHdr(Header)^.Year := year - 1900;
    PMdxHdr(Header)^.Month := month;
    PMdxHdr(Header)^.Day := day;
    WriteDBFileName(PMdxHdr(Header), FileName);
    PMdxHdr(Header)^.BlockSize := 2;
    PMdxHdr(Header)^.BlockAdder := 1024;
    PMdxHdr(Header)^.ProdFlag := 1;
    PMdxHdr(Header)^.NumTags := 48;
    PMdxHdr(Header)^.TagSize := 32;
//    PMdxHdr(Header)^.TagsUsed := 0;
    PMdxHdr(Header)^.Dummy2 := 0;
    PMdxHdr(Header)^.Language := GetDbfLanguageID;
    PMdxHdr(Header)^.NumPages := HeaderSize div PageSize;    // = 4
    TouchHeader(Header);
    PMdxHdr(Header)^.TagFlag := 1;
    // use locale id of parent
    DbfLangId := GetDbfLanguageId;
    if DbfLangId = 0 then
      InternalLocaleID := lcidBinary
    else
      InternalLocaleID := LangID_To_Locale[DbfLangId];
    // write index headers
    prevSelIndex := FSelectedIndex;
    for pos := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      SelectIndexVars(pos);
      FMdxTag.HeaderPageNo := GetNewPageNo;
      WriteRecord(FMdxTag.HeaderPageNo, FIndexHeader);
    end;
    // reselect previously selected index
    SelectIndexVars(prevSelIndex);
    // file header done (tags are included in file header)
    WriteFileHeader;
    // clear roots
    ClearRoots;
    // init vars
    FTagSize := 32;
    FTagOffset := 544;
    // clear entries
    RecordCount := PMdxHdr(Header)^.NumPages;
  end else begin
    // clear single index entry
    ClearIndex;
    RecordCount := PIndexHdr(FIndexHeader)^.NumPages;
  end;
end;

procedure TIndexFile.ClearIndex;
var
  prevHeaderLocked: Integer;
  needHeaderLock: Boolean;
begin
  // flush cache to prevent reading corrupted data
  Flush;
  // modifying header: lock page
  needHeaderLock := FHeaderLocked <> 0;
  prevHeaderLocked := FHeaderLocked;
  if needHeaderLock then
  begin
    LockPage(0, true);
    FHeaderLocked := 0;
  end;
  // initially, we have 1 page: header
  PIndexHdr(FIndexHeader)^.NumPages := HeaderSize div PageSize;
  // clear memory of root
  FRoot.Clear;
  // get new page for root
  FRoot.GetNewPage;
  // store new root page
  PIndexHdr(FIndexHeader)^.RootPage := FRoot.PageNo;
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
  PIndexHdr(FIndexHeader)^.FirstNode := FRoot.PageNo;
{$endif}
  // update leaf pointers
  FLeaves[FSelectedIndex] := FRoot;
  FLeaf := FRoot;
  // write new header
  WriteHeader;
  FRoot.Modified;
  FRoot.WritePage;
  // done updating: unlock header
  if needHeaderLock then
  begin
    UnlockPage(0);
    FHeaderLocked := prevHeaderLocked;
  end;
end;

procedure TIndexFile.CalcKeyProperties;
  // given KeyLen, this func calcs KeyRecLen and NumEntries
var
  remainder: Integer;
begin
  // now adjust keylen to align on DWORD boundaries
  PIndexHdr(FIndexHeader)^.KeyRecLen := PIndexHdr(FIndexHeader)^.KeyLen + FEntryHeaderSize;
  remainder := (PIndexHdr(FIndexHeader)^.KeyRecLen) mod 4;
  if (remainder > 0) then
    PIndexHdr(FIndexHeader)^.KeyRecLen := PIndexHdr(FIndexHeader)^.KeyRecLen + 4 - remainder;
  PIndexHdr(FIndexHeader)^.NumKeys := (RecordSize - FPageHeaderSize) div PIndexHdr(FIndexHeader)^.KeyRecLen;
end;

function TIndexFile.GetName: string;
begin
  // get suitable name of index: if tag name defined use that otherwise filename
  if FIndexVersion >= xBaseIV then
    Result := FIndexName
  else
    Result := FileName;
end;

procedure TIndexFile.CreateIndex(FieldDesc, TagName: string; Options: TIndexOptions);
var
  tagNo: Integer;
  fieldType: Char;
  TempParser: TDbfParser;
begin
  // check if we have exclusive access to table
  TDbfFile(FDbfFile).CheckExclusiveAccess;
  // parse index expression; if it cannot be parsed, why bother making index?
  TempParser := TDbfParser.Create(FDbfFile);
  try
    TempParser.ParseExpression(FieldDesc);
    // check if result type is correct
    fieldType := 'C';
    case TempParser.ResultType of
      etString: ; { default set above to suppress delphi warning }
      etInteger, etLargeInt, etFloat: fieldType := 'N';
    else
      raise EDbfError.Create(STRING_INVALID_INDEX_TYPE);
    end;
  finally
    TempParser.Free;
  end;
  // select empty index
  if FIndexVersion >= xBaseIV then
  begin
    // get next entry no
    tagNo := PMdxHdr(Header)^.TagsUsed;
    // check if too many indexes
    if tagNo = MaxIndexes then
      raise EDbfError.Create(STRING_TOO_MANY_INDEXES);
    // get memory for root
    if FRoots[tagNo] = nil then
    begin
      FParsers[tagNo] := TDbfParser.Create(FDbfFile);
      FRoots[tagNo] := TMdxPage.Create(Self)
    end else begin
      FreeAndNil(FRoots[tagNo].FLowerPage);
    end;
    // set leaves pointer
    FLeaves[tagNo] := FRoots[tagNo];
    // get pointer to index header
    FIndexHeader := FIndexHeaders[tagNo];
    // load root + leaf
    FCurrentParser := FParsers[tagNo];
    FRoot := FRoots[tagNo];
    FLeaf := FLeaves[tagNo];
    // create new tag
    FTempMdxTag.Tag := CalcTagOffset(tagNo);
    FTempMdxTag.TagName := UpperCase(TagName);
    // if expression then calculate
    FTempMdxTag.KeyFormat := KeyFormat_Data;
    if ixExpression in Options then
      FTempMdxTag.KeyFormat := KeyFormat_Expression;
    // what use have these reference tags?
    FTempMdxTag.ForwardTag1 := 0;
    FTempMdxTag.ForwardTag2 := 0;
    FTempMdxTag.BackwardTag := 0;
    FTempMdxTag.Reserved := 2;
    FTempMdxTag.KeyType := fieldType;
    // save this part of tag, need to save before GetNewPageNo,
    // it will reread header
    WriteFileHeader;
    // store selected index
    FSelectedIndex := tagNo;
    FIndexName := TagName;
    // store new headerno
    FHeaderPageNo := GetNewPageNo;
    FTempMdxTag.HeaderPageNo := FHeaderPageNo;
    // increase number of indexes active
    inc(PMdxHdr(Header)^.TagsUsed);
    // update updatemode
    UpdateMode := umAll;
    // index header updated
    WriteFileHeader;
  end;
  // clear index
  ClearIndex;

  // parse expression, we know it's parseable, we've checked that
  FCurrentParser.ParseExpression(FieldDesc);

  // looked up index expression: now we can edit
//  FIsExpression := ixExpression in Options;
  FCanEdit := not FForceReadOnly;

  // init key variables
  PIndexHdr(FIndexHeader)^.KeyFormat := 0;
  // descending
  if ixDescending in Options then
    PIndexHdr(FIndexHeader)^.KeyFormat := PIndexHdr(FIndexHeader)^.KeyFormat or KeyFormat_Descending;
  // key type
  if fieldType = 'C' then
    PIndexHdr(FIndexHeader)^.KeyFormat := PIndexHdr(FIndexHeader)^.KeyFormat or KeyFormat_String;
  PIndexHdr(FIndexHeader)^.KeyType := fieldType;
  // uniqueness
  PIndexHdr(FIndexHeader)^.Unique := Unique_None;
  if ixPrimary in Options then
  begin
    PIndexHdr(FIndexHeader)^.KeyFormat := PIndexHdr(FIndexHeader)^.KeyFormat or KeyFormat_Distinct or KeyFormat_Unique;
    PIndexHdr(FIndexHeader)^.Unique := Unique_Distinct;
  end else if ixUnique in Options then
  begin
    PIndexHdr(FIndexHeader)^.KeyFormat := PIndexHdr(FIndexHeader)^.KeyFormat or KeyFormat_Unique;
    PIndexHdr(FIndexHeader)^.Unique := Unique_Unique;
  end;
  // keylen is exact length of field
  if fieldType = 'C' then
    PIndexHdr(FIndexHeader)^.KeyLen := FCurrentParser.ResultLen
  else if FIndexVersion >= xBaseIV then
    PIndexHdr(FIndexHeader)^.KeyLen := 12
  else
    PIndexHdr(FIndexHeader)^.KeyLen := 8;
  CalcKeyProperties;
  // key desc
  StrPLCopy(PIndexHdr(FIndexHeader)^.KeyDesc, FieldDesc, 219);
  PIndexHdr(FIndexHeader)^.KeyDesc[219] := #0;

  // init various
  if FIndexVersion >= xBaseIV then
    PIndexHdr(FIndexHeader)^.Dummy := 0        // MDX -> language driver
  else
    PIndexHdr(FIndexHeader)^.Dummy := $5800;   // NDX -> same ???
  case fieldType of
    'C':
      PIndexHdr(FIndexHeader)^.sKeyType := 0;
    'D':
      PIndexHdr(FIndexHeader)^.sKeyType := 1;
    'N', 'F':
      if FIndexVersion >= xBaseIV then
        PIndexHdr(FIndexHeader)^.sKeyType := 0
      else
        PIndexHdr(FIndexHeader)^.sKeyType := 1;
  else
    PIndexHdr(FIndexHeader)^.sKeyType := 0;
  end;

  PIndexHdr(FIndexHeader)^.Version := 2;     // this is what DB4 writes into file
  PIndexHdr(FIndexHeader)^.Dummy2 := 0;
  PIndexHdr(FIndexHeader)^.Dummy3 := 0;
  PIndexHdr(FIndexHeader)^.ForExist := 0;    // false
  PIndexHdr(FIndexHeader)^.KeyExist := 1;    // true
{$ifndef TDBF_UPDATE_FIRSTLAST_NODE}
  // if not defined, init to zero
  PIndexHdr(FIndexHeader)^.FirstNode := 0;
  PIndexHdr(FIndexHeader)^.LastNode := 0;
{$endif}
  WriteHeader;

  // update internal properties
  UpdateIndexProperties;

  // for searches / inserts / deletes
  FKeyBuffer[PIndexHdr(FIndexHeader)^.KeyLen] := #0;
end;

procedure TIndexFile.ReadIndexes;
var
  I: Integer;

  procedure CheckHeaderIntegrity;
  begin
    if integer(PIndexHdr(FIndexHeader)^.NumKeys * PIndexHdr(FIndexHeader)^.KeyRecLen) > RecordSize then
    begin
      // adjust index header so that integrity is correct
      // WARNING: we can't be sure this gives a correct result, but at
      // least we won't AV (as easily). user will probably have to regenerate this index
      if PIndexHdr(FIndexHeader)^.KeyLen > 100 then
        PIndexHdr(FIndexHeader)^.KeyLen := 100;
      CalcKeyProperties;
    end;
  end;

begin
  // force header reread
  inherited ReadHeader;
  // examine all indexes
  if FIndexVersion >= xBaseIV then
  begin
    // clear all roots
    ClearRoots;
    // tags are extended at beginning?
    FTagSize := PMdxHdr(Header)^.TagSize;
    FTagOffset := 544 + FTagSize - 32;
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      // read page header
      FTempMdxTag.Tag := CalcTagOffset(I);
      ReadRecord(FTempMdxTag.HeaderPageNo, FIndexHeaders[I]);
      // select it
      FIndexHeader := FIndexHeaders[I];
      // create root if needed
      if FRoots[I] = nil then
      begin
        FParsers[I] := TDbfParser.Create(FDbfFile);
        FRoots[I] := TMdxPage.Create(Self);
      end;
      // check header integrity
      CheckHeaderIntegrity;
      // read tree
      FRoots[I].PageNo := PIndexHdr(FIndexHeader)^.RootPage;
      // go to first record
      FRoots[I].RecurFirst;
      // store leaf
      FLeaves[I] := FRoots[I];
      while FLeaves[I].LowerPage <> nil do
        FLeaves[I] := FLeaves[I].LowerPage;
      // parse expression
      FParsers[I].ParseExpression(PIndexHdr(FIndexHeader)^.KeyDesc);
    end;
  end else begin
    // clear root
    FRoot.Clear;
    // check recordsize constraint
    CheckHeaderIntegrity;
    // just one index: read tree
    FRoot.PageNo := PIndexHdr(FIndexHeader)^.RootPage;
    // go to first valid record
    FRoot.RecurFirst;
    // get leaf page
    FLeaf := FRoot;
    while FLeaf.LowerPage <> nil do
      FLeaf := FLeaf.LowerPage;
    // write leaf pointer to first index
    FLeaves[0] := FLeaf;
    // get index properties -> internal props
    UpdateIndexProperties;
  end;
end;

procedure TIndexFile.DeleteIndex(const AIndexName: string);
var
  I, found, numTags, moveItems: Integer;
  tempHeader: Pointer;
  tempRoot, tempLeaf: TIndexPage;
  tempParser: TDbfParser;
begin
  // check if we have exclusive access to table
  TDbfFile(FDbfFile).CheckExclusiveAccess;
  if FIndexVersion = xBaseIII then
  begin
    Close;
    DeleteFile;
  end else if FIndexVersion >= xBaseIV then
  begin
    // find index
    found := IndexOf(AIndexName);
    if found >= 0 then
    begin
      // just remove this tag by copying memory over it
      numTags := PMdxHdr(Header)^.TagsUsed;
      moveItems := numTags - found - 1;
      // anything to move?
      if moveItems > 0 then
      begin
        // move entries after found one
        Move((Header + FTagOffset + (found+1) * FTagSize)^,
          (Header + FTagOffset + found * FTagSize)^, moveItems * FTagSize);
        // nullify last entry
        FillChar((Header + FTagOffset + numTags * FTagSize)^, FTagSize, 0);
        // index headers, roots, leaves
        tempHeader := FIndexHeaders[found];
        tempParser := FParsers[found];
        tempRoot := FRoots[found];
        tempLeaf := FLeaves[found];
        for I := 0 to moveItems - 1 do
        begin
          FIndexHeaders[found + I] := FIndexHeaders[found + I + 1];
          FParsers[found + I] := FParsers[found + I + 1];
          FRoots[found + I] := FRoots[found + I + 1];
          FLeaves[found + I] := FLeaves[found + I + 1];
          FIndexHeaderModified[found + I] := true;
        end;
        FIndexHeaders[found + moveItems] := tempHeader;
        FParsers[found + moveItems] := tempParser;
        FRoots[found + moveItems] := tempRoot;
        FLeaves[found + moveItems] := tempLeaf;
        FIndexHeaderModified[found + moveItems] := false;    // non-existant header
      end;
      // one entry less left
      dec(PMdxHdr(Header)^.TagsUsed);
      // ---*** numTags not valid from here ***---
      // file header changed
      WriteFileHeader;
      // repage index to free space used by deleted index
//      RepageFile;
    end;
  end;
end;

procedure TIndexFile.TouchHeader(AHeader: Pointer);
var
  year, month, day: Word;
begin
  DecodeDate(Now, year, month, day);
  PMdxHdr(AHeader)^.UpdYear := year - 1900;
  PMdxHdr(AHeader)^.UpdMonth := month;
  PMdxHdr(AHeader)^.UpdDay := day;
end;

function TIndexFile.CreateTempFile(BaseName: string): TPagedFile;
var
  lModifier: Integer;
begin
  // create temporary in-memory index file
  lModifier := 0;
  FindNextName(BaseName, BaseName, lModifier);
  Result := TPagedFile.Create;
  Result.FileName := BaseName;
  Result.Mode := pfExclusiveCreate;
  Result.AutoCreate := true;
  Result.OpenFile;
  Result.HeaderSize := HeaderSize;
  Result.RecordSize := RecordSize;
  Result.PageSize := PageSize;
  Result.PageOffsetByHeader := false;
end;

procedure TIndexFile.RepageFile;
var
  TempFile: TPagedFile;
  TempIdxHeader: PIndexHdr;
  I, newPageNo: Integer;
  prevIndex: Integer;

  function  AllocNewPageNo: Integer;
  begin
    Result := newPageNo;
    Inc(newPageNo, PagesPerRecord);
    if FIndexVersion >= xBaseIV then
      Inc(PMdxHdr(TempFile.Header)^.NumPages, PagesPerRecord);
    Inc(TempIdxHeader^.NumPages, PagesPerRecord);
  end;

  function WriteTree(NewPage: TIndexPage): Integer;
  var
    J: Integer;
  begin
    // get us a page so that page no's are more logically ordered
    Result := AllocNewPageNo;
    // use postorder visiting, first do all children
    if NewPage.LowerPage <> nil then
    begin
      for J := 0 to NewPage.HighIndex do
      begin
        NewPage.EntryNo := J;
        WriteTree(NewPage.LowerPage);
      end;
    end;
    // now create new page for ourselves and write
    // update page pointer in parent
    if NewPage.UpperPage <> nil then
    begin
      if FIndexVersion >= xBaseIV then
      begin
        PMdxEntry(NewPage.UpperPage.Entry)^.RecBlockNo := Result;
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
        // write previous node
        if FRoot = NewPage then
          PMdxPage(NewPage.PageBuffer)^.PrevBlock := 0
        else
          PMdxPage(NewPage.PageBuffer)^.PrevBlock := Result - PagesPerRecord;
{$endif}
      end else begin
        PNdxEntry(NewPage.UpperPage.Entry)^.LowerPageNo := Result;
      end;
    end;
    // store page
    TempFile.WriteRecord(Result, NewPage.PageBuffer);
  end;

  procedure CopySelectedIndex;
  var
    hdrPageNo: Integer;
  begin
    // copy current index settings
    Move(FIndexHeader^, TempIdxHeader^, RecordSize);
    // clear number of pages
    TempIdxHeader^.NumPages := PagesPerRecord;
    // allocate a page no for header
    hdrPageNo := AllocNewPageNo;
    // use recursive function to write all pages
    TempIdxHeader^.RootPage := WriteTree(FRoot);
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
    TempIdxHeader^.FirstNode := TempIdxHeader^.RootPage;
{$endif}
    // write index header now we know the root page
    TempFile.WriteRecord(hdrPageNo, TempIdxHeader);
    if FIndexVersion >= xBaseIV then
    begin
      // calculate tag offset in tempfile header
      FTempMdxTag.Tag := PChar(TempFile.Header) + (PChar(CalcTagOffset(I)) - Header);
      FTempMdxTag.HeaderPageNo := hdrPageNo;
    end;
  end;

begin
  CheckExclusiveAccess;

  prevIndex := FSelectedIndex;
  newPageNo := HeaderSize div PageSize;
  TempFile := CreateTempFile(FileName);
  if FIndexVersion >= xBaseIV then
  begin
    // copy header
    Move(Header^, TempFile.Header^, HeaderSize);
    TouchHeader(TempFile.Header);
    // reset header
    PMdxHdr(TempFile.Header)^.NumPages := HeaderSize div PageSize;
    TempFile.WriteHeader;
    GetMem(TempIdxHeader, RecordSize);
    // now recreate indexes to that file
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      // select this index
      SelectIndexVars(I);
      CopySelectedIndex;
    end;
    FreeMem(TempIdxHeader);
  end else begin
    // indexversion = xBaseIII
    TempIdxHeader := PIndexHdr(TempFile.Header);
    CopySelectedIndex;
  end;
  TempFile.WriteHeader;
  TempFile.CloseFile;
  CloseFile;

  // rename temporary file if all went successfull
  if not TempFile.WriteError then
  begin
    SysUtils.DeleteFile(FileName);
    SysUtils.RenameFile(TempFile.FileName, FileName);
  end;

  TempFile.Free;
  DisableForceCreate;
  OpenFile;
  ReadIndexes;
  SelectIndexVars(prevIndex);
end;

procedure TIndexFile.CompactFile;
var
  TempFile: TPagedFile;
  TempIdxHeader: PIndexHdr;
  I, newPageNo: Integer;
  prevIndex: Integer;

  function  AllocNewPageNo: Integer;
  begin
    Result := newPageNo;
    Inc(newPageNo, PagesPerRecord);
    if FIndexVersion >= xBaseIV then
      Inc(PMdxHdr(TempFile.Header)^.NumPages, PagesPerRecord);
    Inc(TempIdxHeader^.NumPages, PagesPerRecord);
  end;

  function  CreateNewPage: TIndexPage;
  begin
    // create new page + space
    if FIndexVersion >= xBaseIV then
      Result := TMdxPage.Create(Self)
    else
      Result := TNdxPage.Create(Self);
    Result.FPageNo := AllocNewPageNo;

    // set new page properties
    Result.SetNumEntries(0);
  end;

  procedure GetNewEntry(APage: TIndexPage);
    // makes a new entry available and positions current 'pos' on it
    // NOTES: uses TIndexPage *very* carefully
    //  - may not read from self (tindexfile)
    //  - page.FLowerPage is assigned -> SyncLowerPage may *not* be called
    //  - do not set PageNo (= SetPageNo)
    //  - do not set EntryNo
  begin
    if APage.HighIndex >= PIndexHdr(FIndexHeader)^.NumKeys-1 then
    begin
      if APage.UpperPage = nil then
      begin
        // add new upperlevel to page
        APage.FUpperPage := CreateNewPage;
        APage.UpperPage.FLowerPage := APage;
        APage.UpperPage.FEntryNo := 0;
        APage.UpperPage.FEntry := EntryEof;
        APage.UpperPage.GotoInsertEntry;
        APage.UpperPage.LocalInsert(0, APage.Key, APage.PageNo);
        // non-leaf pages need 'rightmost' key; numentries = real# - 1
        APage.UpperPage.SetNumEntries(0);
      end;

      // page done, store
      TempFile.WriteRecord(APage.FPageNo, APage.PageBuffer);

      // allocate new page
      APage.FPageNo := AllocNewPageNo;
      // clear
      APage.SetNumEntries(0);
      APage.FHighIndex := -1;
      APage.FLowIndex := 0;
      // clear 'right-most' blockno
      APage.SetRecLowerPageNoOfEntry(0, 0, 0);

      // get new entry in upper page for current new apage
      GetNewEntry(APage.UpperPage);
      APage.UpperPage.LocalInsert(0, nil, 0);
      // non-leaf pages need 'rightmost' key; numentries = real# - 1
      if APage.UpperPage.EntryNo = 0 then
        APage.UpperPage.SetNumEntries(0);
    end;
    APage.FEntryNo := APage.HighIndex+1;
    APage.FEntry := EntryEof;
    APage.GotoInsertEntry;
  end;

  procedure CopySelectedIndex;
  var
    APage: TIndexPage;
    hdrPageNo: Integer;
  begin
    // copy current index settings
    Move(FIndexHeader^, TempIdxHeader^, RecordSize);
    // clear number of pages
    TempIdxHeader^.NumPages := PagesPerRecord;
    // allocate a page no for header
    hdrPageNo := AllocNewPageNo;

    // copy all records
    APage := CreateNewPage;
    FLeaf.RecurFirst;
    while not (FRoot.Entry = FEntryEof) do
    begin
      GetNewEntry(APage);
      APage.LocalInsert(FLeaf.PhysicalRecNo, FLeaf.Key, 0);
      FLeaf.RecurNext;
    end;

    // flush remaining (partially filled) pages
    repeat
      TempFile.WriteRecord(APage.FPageNo, APage.PageBuffer);
      if APage.UpperPage <> nil then
        APage := APage.UpperPage
      else break;
    until false;

    // copy index header + root page
    TempIdxHeader^.RootPage := APage.PageNo;
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
    TempIdxHeader^.FirstNode := APage.PageNo;
{$endif}
    // write index header now we know the root page
    TempFile.WriteRecord(hdrPageNo, TempIdxHeader);
    if FIndexVersion >= xBaseIV then
    begin
      // calculate tag offset in tempfile header
      FTempMdxTag.Tag := PChar(TempFile.Header) + (PChar(CalcTagOffset(I)) - Header);
      FTempMdxTag.HeaderPageNo := hdrPageNo;
    end;
  end;

begin
  CheckExclusiveAccess;

  prevIndex := FSelectedIndex;
  newPageNo := HeaderSize div PageSize;
  TempFile := CreateTempFile(FileName);
  if FIndexVersion >= xBaseIV then
  begin
    // copy header
    Move(Header^, TempFile.Header^, HeaderSize);
    TouchHeader(TempFile.Header);
    // reset header
    PMdxHdr(TempFile.Header)^.NumPages := HeaderSize div PageSize;
    TempFile.WriteHeader;
    GetMem(TempIdxHeader, RecordSize);
    // now recreate indexes to that file
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      // select this index
      SelectIndexVars(I);
      CopySelectedIndex;
    end;
    FreeMem(TempIdxHeader);
  end else begin
    // indexversion = xBaseIII
    TempIdxHeader := PIndexHdr(TempFile.Header);
    CopySelectedIndex;
  end;
  TempFile.WriteHeader;
  TempFile.CloseFile;
  CloseFile;

  // rename temporary file if all went successfull
  if not TempFile.WriteError then
  begin
    SysUtils.DeleteFile(FileName);
    SysUtils.RenameFile(TempFile.FileName, FileName);
  end;

  TempFile.Free;
  DisableForceCreate;
  OpenFile;
  ReadIndexes;
  SelectIndexVars(prevIndex);
end;

procedure TIndexFile.PrepareRename(NewFileName: string);
begin
  if FIndexVersion >= xBaseIV then
  begin
    WriteDBFileName(PMdxHdr(Header), NewFileName);
    WriteFileHeader;
  end;
end;

function TIndexFile.GetNewPageNo: Integer;
var
  needLockHeader: Boolean;
begin
  // update header -> lock it if not already locked
  needLockHeader := FHeaderLocked <> 0;
  if needLockHeader then
  begin
    // lock header page
    LockPage(0, true);
    // someone else could be inserting records at the same moment
    if NeedLocks then
      inherited ReadHeader;
  end;
  if FIndexVersion >= xBaseIV then
  begin
    Result := PMdxHdr(Header)^.NumPages;
    PMdxHdr(Header)^.NumPages := PMdxHdr(Header)^.NumPages + PagesPerRecord;
{$ifdef TDBF_UPDATE_FIRSTLAST_NODE}
    // adjust high page
    PIndexHdr(FIndexHeader)^.LastNode := Result;
{$endif}
    WriteFileHeader;
  end else begin
    Result := PIndexHdr(FIndexHeader)^.NumPages;
  end;
  PIndexHdr(FIndexHeader)^.NumPages := PIndexHdr(FIndexHeader)^.NumPages + PagesPerRecord;
  WriteHeader;
  // done updating header -> unlock if locked
  if needLockHeader then
    UnlockPage(0);
end;

procedure TIndexFile.Insert(RecNo: Integer; Buffer: PChar); {override;}
var
  I, curSel: Integer;
begin
  // check if updating all or only current
  FUserRecNo := RecNo;
  if (FUpdateMode = umAll) or (FSelectedIndex = -1) then
  begin
    // remember currently selected index
    curSel := FSelectedIndex;
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      SelectIndexVars(I);
      InsertKey(Buffer);
    end;
    // restore previous selected index
    SelectIndexVars(curSel);
  end else begin
    InsertKey(Buffer);
  end;

  // check range, disabled by insert
  ResyncRange(true);
end;

function TIndexFile.CheckKeyViolation(Buffer: PChar): Boolean;
var
  I, curSel: Integer;
begin
  Result := false;
  FUserRecNo := -2;
  if FIndexVersion = xBaseIV then
  begin
    curSel := FSelectedIndex;
    I := 0;
    while (I < PMdxHdr(Header)^.TagsUsed) and not Result do
    begin
      SelectIndexVars(I);
      if FUniqueMode = iuDistinct then
      begin
        FUserKey := ExtractKeyFromBuffer(Buffer);
        Result := FindKey(false) = 0;
      end;
      Inc(I);
    end;
    SelectIndexVars(curSel);
  end else begin
    if FUniqueMode = iuDistinct then
    begin
      FUserKey := ExtractKeyFromBuffer(Buffer);
      Result := FindKey(false) = 0;
    end;
  end;
end;

function TIndexFile.PrepareKey(Buffer: PChar; ResultType: TExpressionType): PChar;
var
  FloatRec: TFloatRec;
  I, IntSrc, NumDecimals: Integer;
  ExtValue: Extended;
  BCDdigit: Byte;
{$ifdef SUPPORT_INT64}
  Int64Src: Int64;
{$endif}

begin
  // need to convert numeric?
  Result := Buffer;
  if PIndexHdr(FIndexHeader)^.KeyType in ['N', 'F'] then
  begin
    if FIndexVersion = xBaseIII then
    begin
      // DB3 -> index always 8 byte float, if original integer, convert to double
      case ResultType of
        etInteger:
          begin
            FUserNumeric := PInteger(Result)^;
            Result := PChar(@FUserNumeric);
          end;
{$ifdef SUPPORT_INT64}
        etLargeInt:
          begin
            FUserNumeric := PLargeInt(Result)^;
            Result := PChar(@FUserNumeric);
          end;
{$endif}
      end;
    end else begin
      // DB4 MDX
      NumDecimals := 0;
      case ResultType of
        etInteger: 
          begin
            IntSrc := PInteger(Result)^;
            // handle zero differently: no decimals
            if IntSrc <> 0 then
              NumDecimals := GetStrFromInt(IntSrc, @FloatRec.Digits[0])
            else
              NumDecimals := 0;
            FloatRec.Negative := IntSrc < 0;
          end;
{$ifdef SUPPORT_INT64}
        etLargeInt:
          begin
            Int64Src := PLargeInt(Result)^;
            if Int64Src <> 0 then
              NumDecimals := GetStrFromInt64(Int64Src, @FloatRec.Digits[0])
            else
              NumDecimals := 0;
            FloatRec.Negative := Int64Src < 0;
          end;
{$endif}
        etFloat:
          begin
            ExtValue := PDouble(Result)^;
            FloatToDecimal(FloatRec, ExtValue, {$ifndef FPC_VERSION}fvExtended,{$endif} 9999, 15);
            if ExtValue <> 0.0 then
              NumDecimals := StrLen(@FloatRec.Digits[0])
            else
              NumDecimals := 0;
            // maximum number of decimals possible to encode in BCD is 16
            if NumDecimals > 16 then
              NumDecimals := 16;
          end;
      end;

      case ResultType of
        etInteger {$ifdef SUPPORT_INT64}, etLargeInt{$endif}:
          begin
            FloatRec.Exponent := NumDecimals;
            // MDX-BCD does not count ending zeroes as `data' space length
            while (NumDecimals > 0) and (FloatRec.Digits[NumDecimals-1] = '0') do
              Dec(NumDecimals);
            // null-terminate string
            FloatRec.Digits[NumDecimals] := #0;
          end;
      end;

      // write 'header', contains number of digits before decimal separator
      FUserBCD[0] := $34 + FloatRec.Exponent;
      // clear rest of BCD
      FillChar(FUserBCD[1], SizeOf(FUserBCD)-1, 0);
      // store number of bytes used (in number of bits + 1)
      FUserBCD[1] := (((NumDecimals+1) div 2) * 8) + 1;
      // where to store decimal dot position? now implicitly in first byte
      // store negative sign
      if FloatRec.Negative then
        FUserBCD[1] := FUserBCD[1] or $80;
      // convert string to BCD
      I := 0;
      while I < NumDecimals do
      begin
        // only one byte left?
        if FloatRec.Digits[I+1] = #0 then
          BCDdigit := 0
        else
          BCDdigit := Byte(FloatRec.Digits[I+1]) - Byte('0');
        // pack two bytes into bcd
        FUserBCD[2+(I div 2)] := ((Byte(FloatRec.Digits[I]) - Byte('0')) shl 4) or BCDdigit;
        // goto next 2 bytes
        Inc(I, 2);
      end;

      // set result pointer to BCD
      Result := PChar(@FUserBCD[0]);
    end;
  end;
end;

function TIndexFile.ExtractKeyFromBuffer(Buffer: PChar): PChar;
begin
  // execute expression to get key
  Result := PrepareKey(FCurrentParser.ExtractFromBuffer(Buffer), FCurrentParser.ResultType);
end;

procedure TIndexFile.InsertKey(Buffer: PChar);
begin
  // ignore deleted records
  if (FModifyMode = mmNormal) and (FUniqueMode = iuDistinct) and (Buffer^ = '*') then
    exit;
  // check proper index and modifiability
  if FCanEdit and (PIndexHdr(FIndexHeader)^.KeyLen <> 0) then
  begin
    // get key from buffer
    FUserKey := ExtractKeyFromBuffer(Buffer);
    // patch through
    InsertCurrent;
  end;
end;

procedure TIndexFile.InsertCurrent;
  // insert in current index
  // assumes: FUserKey is an OEM key
var
  lSearchKey: array[0..100] of Char;
  OemKey: PChar;
begin
  // only insert if not recalling or mode = distinct
  // modify = mmDeleteRecall /\ unique <> distinct -> key already present
  if (FModifyMode <> mmDeleteRecall) or (FUniqueMode = iuDistinct) then
  begin
    // translate OEM key to ANSI key for searching
    OemKey := FUserKey;
    if KeyType = 'C' then
    begin
      FUserKey := @lSearchKey[0];
      TranslateToANSI(OemKey, FUserKey);
    end;
    // temporarily remove range to find correct location of key
    ResetRange;
    // find this record as closely as possible
    // if result = 0 then key already exists
    // if unique index, then don't insert key if already present
    if (FindKey(true) <> 0) or (FUniqueMode = iuNormal) then
    begin
      // switch to oem key
      FUserKey := OemKey;
      // if we found eof, write to pagebuffer
      FLeaf.GotoInsertEntry;
      // insert requested entry, we know there is an entry available
      FLeaf.LocalInsert(FUserRecNo, FUserKey, 0);
    end else begin
      // key already exists -> test possible key violation
      if FUniqueMode = iuDistinct then
      begin
        // raising -> reset modify mode
        FModifyMode := mmNormal;
        InsertError;
      end;
    end;
  end;
end;

procedure TIndexFile.InsertError;
var
  InfoKey: string;
begin
  // prepare info for user
  InfoKey := FUserKey;
  SetLength(InfoKey, KeyLen);
  raise EDbfError.CreateFmt(STRING_KEY_VIOLATION, [GetName, PhysicalRecNo, TrimRight(InfoKey)]);
end;

procedure TIndexFile.Delete(RecNo: Integer; Buffer: PChar);
var
  I, curSel: Integer;
begin
  // check if updating all or only current
  FUserRecNo := RecNo;
  if (FUpdateMode = umAll) or (FSelectedIndex = -1) then
  begin
    // remember currently selected index
    curSel := FSelectedIndex;
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      SelectIndexVars(I);
      DeleteKey(Buffer);
    end;
    // restore previous selected index
    SelectIndexVars(curSel);
  end else begin
    DeleteKey(Buffer);
  end;
  // range may be changed
  ResyncRange(true);
end;

procedure TIndexFile.DeleteKey(Buffer: PChar);
begin
  if FCanEdit and (PIndexHdr(FIndexHeader)^.KeyLen <> 0) then
  begin
    // get key from record buffer
    FUserKey := ExtractKeyFromBuffer(Buffer);
    // call function
    DeleteCurrent;
  end;
end;

procedure TIndexFile.DeleteCurrent;
  // deletes from current index
var
  lSearchKey: array[0..100] of Char;
  OemKey: PChar;
begin
  // only delete if not delete record or mode = distinct
  // modify = mmDeleteRecall /\ unique = distinct -> key needs to be deleted from index
  if (FModifyMode <> mmDeleteRecall) or (FUniqueMode = iuDistinct) then
  begin
    // prevent "confined" view of index while deleting
    ResetRange;
    // search correct entry to delete
    if FLeaf.PhysicalRecNo <> FUserRecNo then
    begin
      // translate OEM key to ANSI key for searching
      OemKey := FUserKey;
      if KeyType = 'C' then
      begin
        FUserKey := @lSearchKey[0];
        TranslateToANSI(OemKey, FUserKey);
      end;
      FindKey(false);
    end;
    // delete selected entry
    FLeaf.Delete;
  end;
end;

procedure TIndexFile.Update(RecNo: Integer; PrevBuffer, NewBuffer: PChar);
var
  I, curSel: Integer;
begin
  // check if updating all or only current
  FUserRecNo := RecNo;
  if (FUpdateMode = umAll) or (FSelectedIndex = -1) then
  begin
    // remember currently selected index
    curSel := FSelectedIndex;
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      SelectIndexVars(I);
      UpdateCurrent(PrevBuffer, NewBuffer);
    end;
    // restore previous selected index
    SelectIndexVars(curSel);
  end else begin
    UpdateCurrent(PrevBuffer, NewBuffer);
  end;
  // check range, disabled by delete/insert
  if (FRoot.LowPage = 0) and (FRoot.HighPage = 0) then
    ResyncRange(true);
end;

procedure TIndexFile.UpdateCurrent(PrevBuffer, NewBuffer: PChar);
var
  TempBuffer: array [0..100] of Char;
begin
  if FCanEdit and (PIndexHdr(FIndexHeader)^.KeyLen <> 0) then
  begin
    // get key from newbuffer
    FUserKey := ExtractKeyFromBuffer(NewBuffer);
    Move(FUserKey^, TempBuffer, PIndexHdr(FIndexHeader)^.KeyLen);
    // get key from prevbuffer
    FUserKey := ExtractKeyFromBuffer(PrevBuffer);

    // compare to see if anything changed
    if CompareKeys(@TempBuffer[0], FUserKey) <> 0 then
    begin
      // first set userkey to key to delete
      // FUserKey = KeyFrom(PrevBuffer)
      DeleteCurrent;
      // now set userkey to key to insert
      FUserKey := @TempBuffer[0];
      InsertCurrent;
    end;
  end;
end;

procedure TIndexFile.AddNewLevel;
var
  lNewPage: TIndexPage;
  pKeyData: PChar;
begin
  // create new page + space
  if FIndexVersion >= xBaseIV then
    lNewPage := TMdxPage.Create(Self)
  else
    lNewPage := TNdxPage.Create(Self);
  lNewPage.GetNewPage;

  // lock this new page; will be unlocked by caller
  lNewPage.LockPage;
  // lock index header; will be unlocked by caller
  LockPage(FHeaderPageNo, true);
  FHeaderLocked := FHeaderPageNo;

  // modify header
  PIndexHdr(FIndexHeader)^.RootPage := lNewPage.PageNo;

  // set new page properties
  lNewPage.SetNumEntries(0);
  lNewPage.EntryNo := 0;
  lNewPage.GotoInsertEntry;
{$ifdef TDBF_UPDATE_FIRST_LAST_NODE}
  lNewPage.SetPrevBlock(lNewPage.PageNo - PagesPerRecord);
{$endif}
  pKeyData := FRoot.GetKeyDataFromEntry(0);
  lNewPage.FLowerPage := FRoot;
  lNewPage.FHighIndex := 0;
  lNewPage.SetEntry(0, pKeyData, FRoot.PageNo);

  // update root pointer
  FRoot.UpperPage := lNewPage;
  FRoots[FSelectedIndex] := lNewPage;
  FRoot := lNewPage;

  // write new header
  WriteRecord(FHeaderPageNo, FIndexHeader);
end;

procedure TIndexFile.UnlockHeader;
begin
  if FHeaderLocked <> -1 then
  begin
    UnlockPage(FHeaderLocked);
    FHeaderLocked := -1;
  end;
end;

procedure TIndexFile.ResyncRoot;
begin
  if FIndexVersion >= xBaseIV then
  begin
    // read header page
    inherited ReadRecord(FHeaderPageNo, FIndexHeader);
  end else
    inherited ReadHeader;
  // reread tree
  FRoot.PageNo := PIndexHdr(FIndexHeader)^.RootPage;
end;

function TIndexFile.SearchKey(Key: PChar; SearchType: TSearchKeyType): Boolean;
var
  findres, currRecNo: Integer;
begin
  // save current position
  currRecNo := SequentialRecNo;
  // search, these are always from the root: no need for first
  findres := Find(-2, Key);
  // test result
  case SearchType of
    stEqual:
      Result := findres = 0;
    stGreaterEqual:
      Result := findres <= 0;
    stGreater:
      begin
        if findres = 0 then
        begin
          // find next record that is greater
          // NOTE: MatchKey assumes key to search for is already specified
          //   in FUserKey, it is because we have called Find
          repeat
            Result := WalkNext;
          until not Result or (MatchKey(Key) <> 0);
        end else
          Result := findres < 0;
      end;
    else
      Result := false;
  end;
  // search failed -> restore previous position
  if not Result then
    SequentialRecNo := currRecNo;
end;

function TIndexFile.Find(RecNo: Integer; Buffer: PChar): Integer;
begin
  // execute find
  FUserRecNo := RecNo;
  FUserKey := Buffer;
  Result := FindKey(false);
end;

function TIndexFile.FindKey(AInsert: boolean): Integer;
//
// if you set Insert = true, you need to re-enable range after insert!!
//
var
  TempPage, NextPage: TIndexPage;
  numEntries, numKeysAvail, done, searchRecNo: Integer;
begin
  // reread index header (to discover whether root page changed)
  if NeedLocks then
    ResyncRoot;
  // if distinct or unique index -> every entry only occurs once ->
  // does not matter which recno we search -> search recno = -2 ->
  // extra info = recno
  if (FUniqueMode = iuNormal) then
  begin
    // if inserting, search last entry matching key
    if AInsert then
      searchRecNo := -3
    else
      searchRecNo := FUserRecNo
  end else begin
    searchRecNo := -2;
  end;
  // start from root
  TempPage := FRoot;
  repeat
    // find key
    done := 0;
    Result := TempPage.FindNearest(searchRecNo);
    if TempPage.LowerPage = nil then
    begin
      // if key greater than last, try next leaf
      if (Result > 0) and (searchRecNo > 0) then
      begin
        // find first parent in tree so we can advance to next item
        NextPage := TempPage;
        repeat
          NextPage := NextPage.UpperPage;
        until (NextPage = nil) or (NextPage.EntryNo < NextPage.HighIndex);
        // found page?
        if NextPage <> nil then
        begin
          // go to parent
          TempPage := NextPage;
          TempPage.EntryNo := TempPage.EntryNo + 1;
          // resync rest of tree
          TempPage.LowerPage.RecurFirst;
          // go to lower page to continue search
          TempPage := TempPage.LowerPage;
          // check if still more lowerpages
          if TempPage.LowerPage <> nil then
          begin
            // flag we need to traverse down further
            done := 2;
          end else begin
            // this is next child, we don't know if found
            done := 1;
          end;
        end;
      end;
    end else begin
      // need to traverse lower down
      done := 2;
    end;

    // check if we need to split page
    // done = 1 -> not found entry on insert path yet
    if AInsert and (done <> 1) then
    begin
      // now we are on our path to destination where entry is to be inserted
      // check if this page is full, then split it
      numEntries := TempPage.NumEntries;
      // if this is inner node, we can only store one less than max entries
      numKeysAvail := PIndexHdr(FIndexHeader)^.NumKeys - numEntries;
      if TempPage.LowerPage <> nil then
        dec(numKeysAvail);
      // too few available -> split
      if numKeysAvail = 0 then
        TempPage.Split;
    end;

    // do we need to go lower down?
    if done = 2 then
      TempPage := TempPage.LowerPage;
  until done = 0;
end;

function TIndexFile.MatchKey(UserKey: PChar): Integer;
begin
  // BOF and EOF always false
  if FLeaf.Entry = FEntryBof then
    Result := 1
  else
  if FLeaf.Entry = FEntryEof then
    Result := -1
  else begin
    FUserKey := UserKey;
    Result := FLeaf.MatchKey;
  end;
end;

procedure TIndexFile.SetRange(LowRange, HighRange: PChar);
begin
  Move(LowRange^, FLowBuffer[0], KeyLen);
  Move(HighRange^, FHighBuffer[0], KeyLen);
  FRangeActive := true;
  ResyncRange(true);
end;

procedure TIndexFile.RecordDeleted(RecNo: Integer; Buffer: PChar);
begin
  // are we distinct -> then delete record from index
  FModifyMode := mmDeleteRecall;
  Delete(RecNo, Buffer);
  FModifyMode := mmNormal;
end;

procedure TIndexFile.RecordRecalled(RecNo: Integer; Buffer: PChar);
begin
  // are we distinct -> then reinsert record in index
  FModifyMode := mmDeleteRecall;
  Insert(RecNo, Buffer);
  FModifyMode := mmNormal;
end;

procedure TIndexFile.SetLocaleID(const NewID: LCID);
{$ifdef WIN32}
var
  InfoStr: array[0..7] of Char;
{$endif}
begin
  FLocaleID := NewID;
  if NewID = lcidBinary then
  begin
    // no conversion on binary sort order
    FLocaleCP := FCodePage;
  end else begin
    // get default ansi codepage for comparestring
{$ifdef WIN32}
    GetLocaleInfo(NewID, LOCALE_IDEFAULTANSICODEPAGE, InfoStr, 8);
    FLocaleCP := StrToIntDef(InfoStr, GetACP);
{$else}
    FLocaleCP := GetACP;
{$endif}
  end;
end;

procedure TIndexFile.SetPhysicalRecNo(RecNo: Integer);
begin
  // check if already at specified recno
  if FLeaf.PhysicalRecNo = RecNo then
    exit;

  // check record actually exists
  if TDbfFile(FDbfFile).IsRecordPresent(RecNo) then
  begin
    // read buffer of this RecNo
    TDbfFile(FDbfFile).ReadRecord(RecNo, TDbfFile(FDbfFile).PrevBuffer);
    // extract key
    FUserKey := ExtractKeyFromBuffer(TDbfFile(FDbfFile).PrevBuffer);
    // translate to a search key
    if KeyType = 'C' then
      TranslateToANSI(FUserKey, FUserKey);
    // find this key
    FUserRecNo := RecNo;
    FindKey(false);
  end;
end;

procedure TIndexFile.SetUpdateMode(NewMode: TIndexUpdateMode);
begin
  // if there is only one index, don't waste time and just set single
  if (FIndexVersion = xBaseIII) or (PMdxHdr(Header)^.TagsUsed <= 1) then
    FUpdateMode := umCurrent
  else
    FUpdateMode := NewMode;
end;

procedure TIndexFile.WalkFirst;
begin
  // search first node
  FRoot.RecurFirst;
  // out of index - BOF
  FLeaf.EntryNo := FLeaf.EntryNo - 1;
end;

procedure TIndexFile.WalkLast;
begin
  // search last node
  FRoot.RecurLast;
  // out of index - EOF
  // we need to skip two entries to go out-of-bound
  FLeaf.EntryNo := FLeaf.EntryNo + 2;
end;

procedure TIndexFile.First;
begin
  // resync tree
  Resync(false);
  WalkFirst;
end;

procedure TIndexFile.Last;
begin
  // resync tree
  Resync(false);
  WalkLast;
end;

procedure TIndexFile.ResyncRange(KeepPosition: boolean);
var
  Result: Boolean;
  currRecNo: integer;
begin
  if not FRangeActive then
    exit;

  // disable current range if any
  //  init to 0 to suppress delphi warning
  currRecNo := 0;
  if KeepPosition then
    currRecNo := SequentialRecNo;
  ResetRange;
  // search lower bound
  Result := SearchKey(FLowBuffer, stGreaterEqual);
  if not Result then
  begin
    // not found? -> make empty range
    WalkLast;
  end;
  // set lower bound
  SetBracketLow;
  // search upper bound
  Result := SearchKey(FHighBuffer, stGreater);
  // if result true, then need to get previous item <=>
  //    last of equal/lower than key
  if Result then
  begin
    Result := WalkPrev;
    if not Result then
    begin
      // cannot go prev -> empty range
      WalkFirst;
    end;
  end else begin
    // not found -> EOF found, go EOF, then to last record
    WalkLast;
    WalkPrev;
  end;
  // set upper bound
  SetBracketHigh;
  if KeepPosition then
    SequentialRecNo := currRecNo;
end;

procedure TIndexFile.Resync(Relative: boolean);
begin
  if NeedLocks then
  begin
    if not Relative then
    begin
      ResyncRoot;
      ResyncRange(false);
    end else begin
      // resyncing tree implies resyncing range
      ResyncTree;
    end;
  end;
end;

procedure TIndexFile.ResyncTree;
var
  action, recno: integer;
begin
  // if at BOF or EOF, then we need to resync by first or last
  // remember where the cursor was
  //  init to 0 to suppress delphi warning
  recno := 0;
  if FLeaf.Entry = FEntryBof then
  begin
    action := 0;
  end else if FLeaf.Entry = FEntryEof then begin
    action := 1;
  end else begin
    // read current key into buffer
    Move(FLeaf.Key^, FKeyBuffer, PIndexHdr(FIndexHeader)^.KeyLen);
    // translate to searchable key
    if KeyType = 'C' then
      TranslateToANSI(FKeyBuffer, FKeyBuffer);
    recno := FLeaf.PhysicalRecNo;
    action := 2;
  end;

  // we now know cursor position, resync possible range
  ResyncRange(false);
  
  // go to cursor position
  case action of
    0: WalkFirst;
    1: WalkLast;
    2:
    begin
      // search current in-mem key on disk
      if (Find(recno, FKeyBuffer) <> 0) then
      begin
        // houston, we've got a problem!
        // our `current' record has gone. we need to find it
        // find it by using physical recno
        PhysicalRecNo := recno;
      end;
    end;
  end;
end;

function TIndexFile.WalkPrev: boolean;
var
  curRecNo: Integer;
begin
  // save current recno, find different next!
  curRecNo := FLeaf.PhysicalRecNo;
  repeat
    // return false if we are at first entry
    Result := FLeaf.RecurPrev;
  until not Result or (curRecNo <> FLeaf.PhysicalRecNo);
end;

function TIndexFile.WalkNext: boolean;
var
  curRecNo: Integer;
begin
  // save current recno, find different prev!
  curRecNo := FLeaf.PhysicalRecNo;
  repeat
    // return false if we are at last entry
    Result := FLeaf.RecurNext;
  until not Result or (curRecNo <> FLeaf.PhysicalRecNo);
end;

function TIndexFile.Prev: Boolean;
begin
  // resync in-mem tree with tree on disk
  Resync(true);
  Result := WalkPrev;
end;

function TIndexFile.Next: Boolean;
begin
  // resync in-mem tree with tree on disk
  Resync(true);
  Result := WalkNext;
end;

function TIndexFile.GetKeyLen: Integer;
begin
  Result := PIndexHdr(FIndexHeader)^.KeyLen;
end;

function TIndexFile.GetKeyType: Char;
begin
  Result := PIndexHdr(FIndexHeader)^.KeyType;
end;

function TIndexFile.GetPhysicalRecNo: Integer;
begin
  Result := FLeaf.PhysicalRecNo;
end;

function TIndexFile.GetSequentialRecordCount: Integer;
begin
  Result := FRoot.Weight * (FRoot.HighIndex + 1);
end;

function TIndexFile.GetSequentialRecNo: Integer;
var
  TempPage: TIndexPage;
begin
  // check if at BOF or EOF, special values
  if FLeaf.EntryNo < FLeaf.LowIndex then begin
    Result := RecBOF;
  end else if FLeaf.EntryNo > FLeaf.HighIndex then begin
    Result := RecEOF;
  end else begin
    // first record is record 1
    Result := 1;
    TempPage := FRoot;
    repeat
      inc(Result, TempPage.EntryNo * TempPage.Weight);
      TempPage := TempPage.LowerPage;
    until TempPage = nil;
  end;
end;

procedure TIndexFile.SetSequentialRecNo(RecNo: Integer);
var
  TempPage: TIndexPage;
  gotoEntry: Integer;
begin
  // use our weighting system to quickly go to a seq recno
  // recno starts at 1, entries at zero
  Dec(RecNo);
  TempPage := FRoot;
  repeat
    // don't div by zero
    assert(TempPage.Weight > 0);
    gotoEntry := RecNo div TempPage.Weight;
    RecNo := RecNo mod TempPage.Weight;
    // do we have this much entries?
    if (TempPage.HighIndex < gotoEntry) then
    begin
      // goto next entry in upper page if not
      // if recurnext fails, we have come at the end of the index
      if (TempPage.UpperPage <> nil) and TempPage.UpperPage.RecurNext then
      begin
        // lower recno to get because we skipped an entry
        TempPage.EntryNo := TempPage.LowIndex;
        RecNo := 0;
      end else begin
        // this can only happen if too big RecNo was entered, go to last
        TempPage.RecurLast;
        // terminate immediately
        TempPage := FLeaf;
      end;
    end else begin
      TempPage.EntryNo := gotoEntry;
    end;
    // get lower node
    TempPage := TempPage.LowerPage;
  until TempPage = nil;
end;

procedure TIndexFile.SetBracketLow;
var
  TempPage: TIndexPage;
begin
  // set current record as lower bound
  TempPage := FRoot;
  repeat
    TempPage.LowBracket := TempPage.EntryNo;
    TempPage.LowPage := TempPage.PageNo;
    TempPage := TempPage.LowerPage;
  until TempPage = nil;
end;

procedure TIndexFile.SetBracketHigh;
var
  TempPage: TIndexPage;
begin
  // set current record as lower bound
  TempPage := FRoot;
  repeat
    TempPage.HighBracket := TempPage.EntryNo;
    TempPage.HighPage := TempPage.PageNo;
    TempPage := TempPage.LowerPage;
  until TempPage = nil;
end;

procedure TIndexFile.CancelRange;
begin
  FRangeActive := false;
  ResetRange;
end;

procedure TIndexFile.ResetRange;
var
  TempPage: TIndexPage;
begin
  // disable lower + upper bound
  TempPage := FRoot;
  repeat
    // set a page the index should never reach
    TempPage.LowPage := 0;
    TempPage.HighPage := 0;
    TempPage := TempPage.LowerPage;
  until TempPage = nil;
end;

function MemComp(P1, P2: Pointer; const Length: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to Length - 1 do
  begin
    // still equal?
    if PByte(P1)^ <> PByte(P2)^ then
    begin
      Result := Integer(PByte(P1)^) - Integer(PByte(P2)^);
      exit;
    end;
    // go to next byte
    Inc(PChar(P1));
    Inc(PChar(P2));
  end;

  // memory equal
  Result := 0;
end;

function TIndexFile.CompareKeys(Key1, Key2: PChar): Integer;
begin
  // call compare routine
  Result := FCompareKeys(Key1, Key2);

  // if descending then reverse order
  if FIsDescending then
    Result := -Result;
end;

function TIndexFile.CompareKeysNumericNDX(Key1, Key2: PChar): Integer;
var
  v1,v2: Double;
begin
  v1 := PDouble(Key1)^;
  v2 := PDouble(Key2)^;
  if v1 > v2 then Result := 1
  else if v1 < v2 then Result := -1
  else Result := 0;
end;

function TIndexFile.CompareKeysNumericMDX(Key1, Key2: PChar): Integer;
var
  neg1, neg2: Boolean;
begin
  // first byte - $34 contains dot position
  neg1 := (Byte(Key1[1]) and $80) <> 0;
  neg2 := (Byte(Key2[1]) and $80) <> 0;
  // check if both negative or both positive
  if neg1 = neg2 then
  begin
    // check alignment
    if Key1[0] = Key2[0] then
    begin
      // no alignment needed -> have same alignment
      Result := MemComp(Key1+2, Key2+2, 10-2);
    end else begin
      // greater 10-power implies bigger number except for zero
      if (Byte(Key1[0]) = $01) and (Byte(Key1[1]) = $34) then
        Result := -1
      else
      if (Byte(Key2[0]) = $01) and (Byte(Key2[1]) = $34) then
        Result := 1
      else
        Result := Byte(Key1[0]) - Byte(Key2[0]);
    end;
    // negate result if both negative
    if neg1 and neg2 then
      Result := -Result;
  end else if neg1 {-> not neg2} then
    Result := -1
  else { not neg1 and neg2 }
    Result := 1;
end;

function TIndexFile.CompareKeysString(Key1, Key2: PChar): Integer;
var
  Key1T, Key2T: array [0..100] of Char;
  FromCP, ToCP: Integer;
begin
  if FLocaleID = LCID(lcidBinary) then
  begin
    Result := StrLComp(Key1, Key2, KeyLen)
  end else begin
    FromCP := FCodePage;
    ToCP := FLocaleCP;
    TranslateString(FromCP, ToCP, Key1, Key1T, KeyLen);
    TranslateString(FromCP, ToCP, Key2, Key2T, KeyLen);
    Result := CompareString(FLocaleID, 0, Key1T, KeyLen, Key2T, KeyLen);
    if Result > 0 then
      Dec(Result, 2);
  end
end;

function TIndexFile.CompareKey(Key: PChar): Integer;
begin
  // call compare routine
  Result := FCompareKey(Key);

  // if descending then reverse order
  if FIsDescending then
    Result := -Result;
end;

function TIndexFile.CompareKeyNumericNDX(Key: PChar): Integer;
begin
  Result := CompareKeysNumericNDX(FUserKey, Key);
end;

function TIndexFile.CompareKeyNumericMDX(Key: PChar): Integer;
begin
  Result := CompareKeysNumericMDX(FUserKey, Key);
end;

procedure TIndexFile.TranslateToANSI(Src, Dest: PChar);
begin
  { FromCP = FCodePage; }
  { ToCP = FLocaleCP;   }
  TranslateString(FCodePage, FLocaleCP, Src, Dest, KeyLen);
end;

function TIndexFile.CompareKeyString(Key: PChar): Integer;
var
  KeyT: array [0..100] of Char;
begin
  if FLocaleID = LCID(lcidBinary) then
  begin
    Result := StrLComp(FUserKey, Key, KeyLen)
  end else begin
    TranslateToANSI(Key, KeyT);
    Result := CompareString(FLocaleID, 0, FUserKey, KeyLen, KeyT, KeyLen);
    if Result > 0 then
      Dec(Result, 2);
  end
end;

function TIndexFile.IndexOf(const AIndexName: string): Integer;
  // *) assumes FIndexVersion >= xBaseIV
var
  I: Integer;
begin
  // get index of this index :-)
  Result := -1;
  I := 0;
  while (I < PMdxHdr(Header)^.TagsUsed) and (Result < 0) do
  begin
    FTempMdxTag.Tag := CalcTagOffset(I);
    if AnsiCompareText(AIndexName, FTempMdxTag.TagName) = 0 then
      Result := I;
    inc(I);
  end;
end;

procedure TIndexFile.SetIndexName(const AIndexName: string);
var
  found: Integer;
begin
  // we can only select a different index if we are MDX
  if FIndexVersion >= xBaseIV then
  begin
    // find index
    found := IndexOf(AIndexName);
  end else
    found := 0;
  // we can now select by index
  if found >= 0 then
    SelectIndexVars(found);
end;

function TIndexFile.CalcTagOffset(AIndex: Integer): Pointer;
begin
  Result := PChar(Header) + FTagOffset + AIndex * FTagSize;
end;

procedure TIndexFile.SelectIndexVars(AIndex: Integer);
  // *) assumes index is in range
begin
  if AIndex >= 0 then
  begin
    // get pointer to index header
    FIndexHeader := FIndexHeaders[AIndex];
    // load root + leaf
    FCurrentParser := FParsers[AIndex];
    FRoot := FRoots[AIndex];
    FLeaf := FLeaves[AIndex];
    // if xBaseIV then we need to store where pageno of current header
    if FIndexVersion >= xBaseIV then
    begin
      FMdxTag.Tag := CalcTagOffset(AIndex);
      FIndexName := FMdxTag.TagName;
      FHeaderPageNo := FMdxTag.HeaderPageNo;
      // does dBase actually use this flag?
//      FIsExpression := FMdxTag.KeyFormat = KeyFormat_Expression;
    end else begin
      // how does dBase III store whether it is expression?
//      FIsExpression := true;
    end;
    // retrieve properties
    UpdateIndexProperties;
  end else begin
    // not a valid index
    FIndexName := EmptyStr;
  end;
  // store selected index
  FSelectedIndex := AIndex;
  FCanEdit := not FForceReadOnly;
end;

procedure TIndexFile.UpdateIndexProperties;
begin
  // get properties
  FIsDescending := (PIndexHdr(FIndexHeader)^.KeyFormat and KeyFormat_Descending) <> 0;
  FUniqueMode := iuNormal;
  if (PIndexHdr(FIndexHeader)^.KeyFormat and KeyFormat_Unique) <> 0 then
    FUniqueMode := iuUnique;
  if (PIndexHdr(FIndexHeader)^.KeyFormat and KeyFormat_Distinct) <> 0 then
    FUniqueMode := iuDistinct;
  // select key compare routine
  if PIndexHdr(FIndexHeader)^.KeyType = 'C' then
  begin
    FCompareKeys := CompareKeysString;
    FCompareKey := CompareKeyString;
  end else
  if FIndexVersion >= xBaseIV then
  begin
    FCompareKeys := CompareKeysNumericMDX;
    FCompareKey := CompareKeyNumericMDX;
  end else begin
    FCompareKeys := CompareKeysNumericNDX;
    FCompareKey := CompareKeyNumericNDX;
  end;
end;

procedure TIndexFile.Flush;
var
  I: Integer;
begin
  // save changes to pages
  if FIndexVersion >= xBaseIV then
  begin
    for I := 0 to MaxIndexes - 1 do
    begin
      if FIndexHeaderModified[I] then
        WriteIndexHeader(I);
      if FRoots[I] <> nil then
        FRoots[I].Flush
    end;
  end else begin
    if FRoot <> nil then
      FRoot.Flush;
  end;

  // save changes to header
  FlushHeader;

  inherited;
end;

(*

function TIndexFile.GetIndexCount: Integer;
begin
  if FIndexVersion = xBaseIII then
    Result := 1
  else
  if FIndexVersion = xBaseIV then
    Result := PMdxHdr(Header).TagsUsed;
  else
    Result := 0;
end;

*)

procedure TIndexFile.GetIndexNames(const AList: TStrings);
var
  I: Integer;
begin
  // only applicable to MDX files
  if FIndexVersion >= xBaseIV then
  begin
    for I := 0 to PMdxHdr(Header)^.TagsUsed - 1 do
    begin
      FTempMdxTag.Tag := CalcTagOffset(I);
      AList.AddObject(FTempMdxTag.TagName, Self);
    end;
  end;
end;

procedure TIndexFile.GetIndexInfo(const AIndexName: string; IndexDef: TDbfIndexDef);
var
  SaveIndexName: string;
begin
  // remember current index
  SaveIndexName := IndexName;
  // select index
  IndexName := AIndexName;
  // copy properties
  IndexDef.IndexFile := AIndexName;
  IndexDef.Expression := PIndexHdr(FIndexHeader)^.KeyDesc;
  IndexDef.Options := [];
  IndexDef.Temporary := true;
  if FIsDescending then
    IndexDef.Options := IndexDef.Options + [ixDescending];
  IndexDef.Options := IndexDef.Options + [ixExpression];
  case FUniqueMode of
    iuUnique: IndexDef.Options := IndexDef.Options + [ixUnique];
    iuDistinct: IndexDef.Options := IndexDef.Options + [ixPrimary];
  end;
  // reselect previous index
  IndexName := SaveIndexName;
end;

function TIndexFile.GetExpression: string;
begin
  if FCurrentParser <> nil then
    Result := FCurrentParser.Expression
  else
    Result := EmptyStr;
end;

function TIndexFile.GetDbfLanguageId: Byte;
begin
  // check if parent DBF version 7, get language id
  if (TDbfFile(FDbfFile).DbfVersion = xBaseVII) then
  begin
    // get language id of parent dbf
    Result := GetLangId_From_LangName(TDbfFile(FDbfFile).LanguageStr);
  end else begin
    // dBase IV has language id in header
    Result := TDbfFile(FDbfFile).LanguageID;
  end;
end;

procedure TIndexFile.WriteHeader; {override;}
begin
  // if NDX, then this means file header
  if FIndexVersion >= xBaseIV then
    if NeedLocks then
      WriteIndexHeader(FSelectedIndex)
    else
      FIndexHeaderModified[FSelectedIndex] := true
  else
    WriteFileHeader;
end;

procedure TIndexFile.WriteFileHeader;
begin
  inherited WriteHeader;
end;

procedure TIndexFile.WriteIndexHeader(AIndex: Integer);
begin
  FTempMdxTag.Tag := CalcTagOffset(AIndex);
  WriteRecord(FTempMdxTag.HeaderPageNo, FIndexHeaders[AIndex]);
  FIndexHeaderModified[AIndex] := false;
end;

//==========================================================
//============ TDbfIndexDef
//==========================================================

constructor TDbfIndexDef.Create(ACollection: TCollection); {override;}
begin
  inherited Create(ACollection);
  FTemporary := false;
end;

destructor TDbfIndexDef.Destroy; {override;}
begin
  inherited Destroy;
end;

procedure TDbfIndexDef.Assign(Source: TPersistent);
begin
  // we can't do anything with it if not a TDbfIndexDef
  if Source is TDbfIndexDef then
  begin
    FIndexName := TDbfIndexDef(Source).IndexFile;
    FExpression := TDbfIndexDef(Source).Expression;
    FOptions := TDbfIndexDef(Source).Options;
  end else
    inherited;
end;

procedure TDbfIndexDef.SetIndexName(NewName: string);
begin
  FIndexName := AnsiUpperCase(Trim(NewName));
end;

procedure TDbfIndexDef.SetExpression(NewField: string);
begin
  FExpression := AnsiUpperCase(Trim(NewField));
end;

initialization

{
  Entry_Mdx_BOF.RecBlockNo := RecBOF;
  Entry_Mdx_BOF.KeyData := #0;

  Entry_Mdx_EOF.RecBlockNo := RecEOF;
  Entry_Mdx_EOF.KeyData := #0;

  Entry_Ndx_BOF.LowerPageNo := 0;
  Entry_Ndx_BOF.RecNo := RecBOF;
  Entry_Ndx_BOF.KeyData := #0;

  Entry_Ndx_EOF.LowerPageNo := 0;
  Entry_Ndx_EOF.RecNo := RecEOF;
  Entry_Ndx_EOF.KeyData := #0;
}

  LCIDList := TLCIDList.Create;
  LCIDList.Enumerate;

finalization

  LCIDList.Free;

end.

