
unit gdcBaseInterface;

interface

uses
  DB, IBDatabase, classes, zlib, gd_directories_const;

type
  //////////////////////////////////////////////////////////
  // подмножество
  TgdcSubSet = ShortString;

  //////////////////////////////////////////////////////////
  // имя делфовского класса
  TgdcClassName = ShortString;

  //////////////////////////////////////////////////////////
  // подтип
  TgdcSubType = ShortString;

  //////////////////////////////////////////////////////////
  // полное имя бизнес-класса
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
    //Проверяет руид на корректность
    //Возвращает id или -1 в случае, если РУИД не существует
    function GetRUIDRecByXID(const XID, DBID: TID; Transaction: TIBTransaction): TRUIDRec;
    function GetRUIDRecByID(const AnID: TID; Transaction: TIBTransaction): TRUIDRec;
    //Удаляет РУИД по XID и DBID
    procedure DeleteRUIDByXID(const XID, DBID: TID; Transaction: TIBTransaction);
    //Обновляет РУИД по id
    procedure UpdateRUIDByXID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    procedure InsertRUID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    procedure DeleteRUIDByID(const AnID: TID; Transaction: TIBTransaction);
    //Обновляет РУИД по id
    procedure UpdateRUIDByID(const AnID, AXID, ADBID: TID; const AModified: TDateTime;
      const AnEditorKey: Integer; Transaction: TIBTransaction);
    // выполняет заданный СКЛ запрос
    // коммит не делает
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
  // информация о структуре главной таблицы объекта
  TgdcTableInfo = (
    tiID,              // ёсць ідэнтыфікатар
    tiParent,          // ёсць спасылка на бацькоўскі запіс (дрававідная структура)
    tiLBRB,            // ёсць палі з межамі (інтэрвальнае дрэва)
    tiCreationDate,
    tiCreatorKey,
    tiEditionDate,
    tiEditorKey,
    tiDisabled,
    tiXID,
    tiDBID,
    tiAFull,           // ёсць дэскрыптары бяспекі
    tiAChag,           // --//--
    tiAView            // --//--
  );
  TgdcTableInfos = set of TgdcTableInfo;

  //Проверяет, является ли переданная строка руидом
  function CheckRuid(const RUIDString: String): Boolean;
  function RUIDToStr(const ARUID: TRUID): String; overload;
  function RUIDToStr(const XID, DBID: TID): String; overload;
  function StrToRUID(const AString: String): TRUID;
  function RUID(const XID, DBID: TID): TRUID;

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

function CheckRuid(const RUIDString: String): Boolean;
var
  I: Integer;
begin
  I := Pos('_', RUIDString);
  Result := (I > 0)
    and (StrToIntDef(Copy(RUIDString, 1, I - 1), -1) >= 0)
    and (StrToIntDef(Copy(RUIDString, I + 1, 1024), -1) >= 0);
end;

function RUIDToStr(const ARUID: TRUID): String; overload;
begin
  Result := RUIDToStr(ARUID.XID, ARUID.DBID);
end;

function RUIDToStr(const XID, DBID: TID): String; overload;
begin
  if (XID = -1) or (DBID = -1) then
    Result := ''
  else
    Result := IntToStr(XID) + '_' + IntToStr(DBID);
end;

function StrToRUID(const AString: String): TRUID;
var
  P: Integer;
begin
  with Result do
    if AString = '' then
    begin
      XID := -1;
      DBID := -1;
    end else begin
      P := Pos('_', AString);
      if P = 0 then
        raise Exception.Create('Invalid RUID string')
      else begin
        XID := StrToIntDef(Copy(AString, 1, P - 1), -1);
        DBID := StrToIntDef(Copy(AString, P + 1, 255), -1);
        if (XID <= 0) or (DBID <= 0) then
          raise Exception.Create('Invalid RUID string')
      end;
    end;
end;

function RUID(const XID, DBID: TID): TRUID;
begin
  Result.XID := XID;
  Result.DBID := DBID;
end;

end.
