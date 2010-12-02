
unit gdcBaseInterface;

interface

uses
  DB, IBDatabase, classes, zlib, gd_directories_const;

type
  //////////////////////////////////////////////////////////
  // ïîäìíîæåñòâî
  TgdcSubSet = ShortString;

  //////////////////////////////////////////////////////////
  // èìÿ äåëôîâñêîãî êëàññà
  TgdcClassName = ShortString;

  //////////////////////////////////////////////////////////
  // ïîäòèï
  TgdcSubType = ShortString;

  //////////////////////////////////////////////////////////
  // ïîëíîå èìÿ áèçíåñ-êëàññà
  TgdcFullClassName = record
    gdClassName: TgdcClassName;
    SubType: TgdcSubType;
  end;

  TID = -1..MAXINT;

  TRUID = record
    XID: TID;
    DBID: TID;
  end;

  TRUIDRec = record
    ID: TID;
    XID: TID;
    DBID: TID;
    Modified: TDateTime;
    EditorKey: Integer;
  end;

  TRUIDString = String[21];

  IgdcBase = interface;
  IgdcBaseManager = interface
  ['{9539A2C1-52C1-11D5-B4CF-0060520A1991}']

    function GetDatabase: TIBDatabase;
    procedure SetDatabase(const Value: TIBDatabase);
    function GetReadTransaction: TIBTransaction;
    function GetIDByRUID(const XID, DBID: TID; const Tr: TIBTransaction = nil): TID;
    function GetIDByRUIDString(const RUID: TRUIDString; const Tr: TIBTransaction = nil): TID;
    function GetRUIDStringByID(const ID: TID; const Tr: TIBTransaction = nil): TRUIDString;
    procedure GetRUIDByID(const ID: TID; out XID, DBID: TID; const Tr: TIBTransaction = nil);
    procedure GetFullRUIDByID(const ID: TID; out XID, DBID: TID);
    function ProcessSQL(const S: String): String;
    function AdjustMetaName(const S: String): String;
    function GetExplorer: IgdcBase;
    procedure SetExplorer(const Value: IgdcBase);
    function GenerateNewDBID: Integer;
    function GetNextID(const ResetCache: Boolean = False): TID;
    procedure ClearSecDescArr;
    procedure PackStream(SourceStream, DestStream: TStream; CompressionLevel: TZCompressionLevel);
    procedure UnPackStream(SourceStream, DestStream: TStream);
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property ReadTransaction: TIBTransaction read GetReadTransaction;
    property Explorer: IgdcBase read GetExplorer write SetExplorer;
    //Ïğîâåğÿåò ğóèä íà êîğğåêòíîñòü
    //Âîçâğàùàåò id èëè -1 â ñëó÷àå, åñëè ĞÓÈÄ íå ñóùåñòâóåò
    function GetRUIDRecByXID(const XID, DBID: TID; Transaction: TIBTransaction): TRUIDRec;
    function GetRUIDRecByID(const AnID: TID; Transaction: TIBTransaction): TRUIDRec;
    //Óäàëÿåò ĞÓÈÄ ïî XID è DBID
    procedure DeleteRUIDByXID(const XID, DBID: TID; Transaction: TIBTransaction);
    //Îáíîâëÿåò ĞÓÈÄ ïî id
    procedure UpdateRUIDByXID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    procedure InsertRUID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    procedure DeleteRUIDByID(const AnID: TID; Transaction: TIBTransaction);
    //Îáíîâëÿåò ĞÓÈÄ ïî id
    procedure UpdateRUIDByID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    // âûïîëíÿåò çàäàííûé ÑÊË çàïğîñ
    // êîììèò íå äåëàåò
    procedure ExecSingleQuery(const S: String; const Transaction: TIBTransaction = nil); overload;
    procedure ExecSingleQuery(const S: String; Param: Variant; const Transaction: TIBTransaction = nil); overload;
    procedure ExecSingleQueryResult(const S: String; Param: Variant;
      out Res: OleVariant; const Transaction: TIBTransaction = nil);

    function Class_TestUserRights(C: TClass;
      const ASubType: TgdcSubType; const AnAccess: Integer): Boolean;
    procedure Class_GetSecDesc(C: TClass; const ASubType: TgdcSubType;
      out AView, AChag, AFull: Integer);
    procedure Class_SetSecDesc(C: TClass; const ASubType: TgdcSubType;
      const AView, AChag, AFull: Integer);

    procedure IDCacheFlush;
  end;

  IgdcBase = interface
    ['{823AC601-4D13-11D5-B4C1-0060520A1991}']

    function GetClassName: String;
    function GetSubType: String;
    function GetObject: TObject;
    function GetFieldByNameValue(const AField: String): Variant;
    function FindField(const AFieldName: String): TField;
  end;

  //////////////////////////////////////////////////////////
  // èíôîğìàöèÿ î ñòğóêòóğå ãëàâíîé òàáëèöû îáúåêòà
  TgdcTableInfo = (
    tiID,              // ¸ñöü ³äıíòûô³êàòàğ
    tiParent,          // ¸ñöü ñïàñûëêà íà áàöüêî¢ñê³ çàï³ñ (äğàâàâ³äíàÿ ñòğóêòóğà)
    tiLBRB,            // ¸ñöü ïàë³ ç ìåæàì³ (³íòığâàëüíàå äğıâà)
    tiCreationInfo,    // ³íôàğìàöûÿ àá òûì, õòî ³ êàë³ ñòâàğû¢ àá'åêò
    tiEditionInfo,     // ³íôàğìàöûÿ àá òûì, õòî ³ êàë³ âûïğàâ³¢ àá'åêò
    tiDisabled,
    tiXID,
    tiDBID,
    tiAFull,           // ¸ñöü äıñêğûïòàğû áÿñïåê³
    tiAChag,           // --//--
    tiAView            // --//--
  );
  TgdcTableInfos = set of TgdcTableInfo;

  //Ïğîâåğÿåò, ÿâëÿåòñÿ ëè ïåğåäàííàÿ ñòğîêà ğóèäîì
  function CheckRuid(RUIDString: string): boolean;

const
  IDCacheRegKey = ClientRootRegistrySubKey + 'IDCache\';
  IDCacheStep = 100;
  IDCacheCurrentName = 'IDCurrent';
  IDCacheLimitName = 'IDLimit';
  IDCacheTestName = 'IDTest';
  IDCacheExpDateName = 'IDExp';

var
  gdcBaseManager: IgdcBaseManager;

implementation

uses
  SysUtils;

function CheckRuid(RUIDString: string): boolean;
const
  RuidSet = ['0'..'9', '_'];
  NumericSet = ['0'..'9'];
var
  I: Integer;
begin
  if (Length(RUIDString) = 0) or not(RUIDString[1] in NumericSet) then
  begin
    Result := False;
    Exit;
  end;

  for I := 2 to Length(RUIDString) do
  begin
    if not(RUIDString[I] in RuidSet) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := AnsiPos('_', RuidString) > 0;
end;

end.
