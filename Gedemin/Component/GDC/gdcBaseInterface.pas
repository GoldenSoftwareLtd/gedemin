unit gdcBaseInterface;

interface

uses
  DB, IBDatabase, IBSQL, classes, zlib, gd_directories_const,
  SysUtils, dbclient;

const
  lblInt64Stream: array[0..5] of Char = 'TID64';
  cEmptyContext: string ='Empty';

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

  //значения ID папок -10..-1 prp_TreeItems
  {$IFDEF ID64}
  TID = -10..High(Int64);
  {$ELSE}
  TID = -10..MAXINT;
  {$ENDIF}
  PID = ^TID;

  PStream = ^TStream;

  TRUID = record
    XID: TID;
    DBID: Integer;
  end;

  TRUIDRec = record
    ID: TID;
    XID: TID;
    DBID: Integer;
    Modified: TDateTime;
    EditorKey: TID;
  end;

  {$IFDEF ID64}
  TRUIDString = String[30];
  {$ELSE}
  TRUIDString = String[21];
  {$ENDIF}


  IgdcBase = interface;
  IgdcBaseManager = interface
  ['{9539A2C1-52C1-11D5-B4CF-0060520A1991}']

    function GetDatabase: TIBDatabase;
    procedure SetDatabase(const Value: TIBDatabase);
    function GetReadTransaction: TIBTransaction;
    function GetIDByRUID(const XID: TID; const DBID: Integer; const Tr: TIBTransaction = nil): TID;
    function GetIDByRUIDString(const RUID: TRUIDString; const Tr: TIBTransaction = nil): TID;
    function GetRUIDStringByID(const ID: TID; const Tr: TIBTransaction = nil): TRUIDString;
    procedure GetRUIDByID(const ID: TID; out XID: TID; out DBID: Integer; const Tr: TIBTransaction = nil);
    function ProcessSQL(const S: String): String;
    function AdjustMetaName(const S: AnsiString; const MaxLength: Integer = cstMetaDataNameLength): AnsiString;
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
    function GetRUIDRecByXID(const XID: TID; const DBID: Integer; Transaction: TIBTransaction): TRUIDRec;
    function GetRUIDRecByID(const AnID: TID; Transaction: TIBTransaction): TRUIDRec;
    //Удаляет РУИД по XID и DBID
    procedure DeleteRUIDByXID(const XID: TID; const DBID: Integer; Transaction: TIBTransaction);
    //Обновляет РУИД по id
    procedure UpdateRUIDByXID(const AnID, AXID: TID; const ADBID: Integer; const AModified: TDateTime;
      const AnEditorKey: TID; Transaction: TIBTransaction);
    procedure InsertRUID(const AnID, AXID: TID; const ADBID: Integer; const AModified: TDateTime;
      const AnEditorKey: TID; Transaction: TIBTransaction);
    procedure DeleteRUIDByID(const AnID: TID; Transaction: TIBTransaction);
    //Обновляет РУИД по id
    procedure UpdateRUIDByID(const AnID, AXID: TID; const ADBID: Integer; const AModified: TDateTime;
      const AnEditorKey: TID; Transaction: TIBTransaction);

    procedure RemoveRUIDFromCache(const AXID: TID; const ADBID: Integer);

    // выполняет заданный СКЛ запрос
    // коммит не делает
    procedure ExecSingleQuery(const S: String; const Transaction: TIBTransaction = nil); overload;
    procedure ExecSingleQuery(const S: String; Param: Variant; const Transaction: TIBTransaction = nil); overload;
    function ExecSingleQueryResult(const S: String; Param: Variant;
      out Res: OleVariant; const Transaction: TIBTransaction = nil): Boolean;

    function Class_TestUserRights(C: TClass;
      const ASubType: TgdcSubType; const AnAccess: Integer): Boolean;
    procedure Class_GetSecDesc(C: TClass; const ASubType: TgdcSubType;
      out AView, AChag, AFull: Integer);
    procedure Class_SetSecDesc(C: TClass; const ASubType: TgdcSubType;
      const AView, AChag, AFull: Integer);

    procedure IDCacheFlush;

    procedure ChangeRUID(const AnOldXID: TID; const AnOldDBID: Integer;
      const ANewXID: TID; const ANewDBID: Integer;
      ATr: TIBTransaction; const AForceUpdateFunc: Boolean);
    procedure ProcessDelayedRUIDChanges(ATr: TIBTransaction);
    function HasDelayedRUIDChanges: Boolean;
  end;

  IgdcBase = interface
    ['{823AC601-4D13-11D5-B4C1-0060520A1991}']

    function GetClassName: String;
    function GetSubType: TgdcSubType;
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
  function RUIDToStr(const XID: TID; const DBID: Integer): String; overload;
  function StrToRUID(const AString: String): TRUID;
  function RUID(const XID: TID; const DBID: Integer): TRUID;

  // функции для получения ИД из запроса, строки, варианта
  function GetTID(f: TIBXSQLVAR): TID; overload;
  function GetTID(f: TField): TID; overload;
  function GetTID(f: TParam): TID; overload;
  function GetTID(s: String; def: TID): TID; overload;
  function GetTID(v: Variant): TID; overload;
  function GetTID(o: TObject; Context: String): TID; overload;
  function GetTID(p: Pointer; Context: String): TID; overload;
  function GetTID(tag: Integer; Context: String): TID; overload;
  function ReadTID(Reader: TReader): TID;

  // функции для присваивания и преобразования ИД
  function SetTID(f: TIBXSQLVAR; const ID: TID): TID; overload;
  function SetTID(f: TField; const ID: TID): TID; overload;
  function SetTID(f: TField; const S: String): TID; overload;
  function SetTID(f: TField; fld: TIBXSQLVAR): TID; overload;
  function SetTID(f: TField; fld: TField): TID; overload;
  function SetTID(f: TParam; const ID: TID): TID; overload;
  function SetTID(f: TParam; fld: TField): TID; overload;
  function SetTID(f: TIBXSQLVAR; fld: TField): TID; overload;
  function SetTID(f: TIBXSQLVAR; fld: TIBXSQLVAR): TID; overload;
  function TID2S(const ID: TID): String; overload;
  function TID2S(f: TIBXSQLVAR): String; overload;
  function TID2S(const f: TField): String; overload;
  function TID2V(const ID: TID): variant; overload;
  function TID2V(f: TField): variant; overload;
  function TID2V(f: TIBXSQLVAR): variant; overload;
  function TID264(const ID: TID): Int64; overload;
  function TID264(const f: TField): Int64; overload;
  function TID264(const f: TIBXSQLVAR): Int64; overload;

  function TID2Pointer(ID: TID; Context: String): Pointer;
  function TID2Tag(ID: TID; Context: String): Integer;
  function TID2TObject(ID: TID; Context: String): TObject;

  function GetFieldAsVar(f: TField): variant; overload;
  function GetFieldAsVar(f: TIBXSQLVAR): variant; overload;
  function SetVar2Field(f: TField; const v: variant): boolean; overload;
  function SetVar2Param(f: TIBXSQLVAR; const v: variant): boolean; overload;
  function SetVar2Param(f: TParam; const v: variant): boolean; overload;

  procedure AssignField64(f: TField; fld: TField); overload;

  // функции для определения размера идентификаторов в потоке
  function GetLenIDInStream(PS: PStream): Integer;
  function SetLenIDInStream(PS: PStream): Integer;

  // функции для проверки ИД в 32битном диапазоне
  function Is32TID(const ID: TID): boolean;
  procedure Check32TID(const ID: TID);

  // сравнение ИД
  function EqTID(const ID1, ID2: TID): boolean; overload;
  function EqTID(ID1: TField; const ID2: TID): boolean; overload;
  function EqTID(f: TIBXSQLVAR; const ID: TID): boolean; overload;

  function IsGedeminSystemID(const AnID: TID): Boolean;
  function IsGedeminNonSystemID(const AnID: TID): Boolean;

  function DatasetLocate(var Dataset: TDataset; const KeyFields: string; const KeyValues: Variant;
                        Options: TLocateOptions): Boolean;

  {$IFDEF ID64}
  procedure FreeConvertContext(Context: String);
  {$ENDIF}

const
  IDCacheRegKey = ClientRootRegistrySubKey + 'IDCache\';
  IDCacheStep: Integer = 100; // will be set to 1 if in terminal session
  IDCacheCurrentName = 'IDCurrent';
  IDCacheLimitName = 'IDLimit';
  IDCacheTestName = 'IDTest';
  IDCacheExpDateName = 'IDExp';

  IDGeneratorMaxThreshold = 1600000000;
  MinIDInterval = 100;

var
  gdcBaseManager: IgdcBaseManager;
  Global_LoadingNamespace: Boolean;
  Global_DisableQueryFilter: Boolean;

implementation

uses
  Dialogs, IBHeader;

function SetVar2Field(f: TField; const v: variant): boolean; overload;
begin
  Result := True;
  if not VarIsNull(v) then
  begin
    if f.DataType = ftLargeint then
      f.AsFloat := v
    else
      f.Value := v;
  end
  else
    f.Value := null;
end;

function SetVar2Param(f: TIBXSQLVAR; const v: variant): boolean;
begin
  Result := True;
  if not VarIsNull(v) then
  begin
    if (f.SQLType = sql_int64) and ((f.data.sqlscale = 0) or (f.data.sqlscale < (-4))) then
      f.asDouble := v
    else
      f.asVariant := v;
  end
  else
    f.Value := null;
end;

function SetVar2Param(f: TParam; const v: variant): boolean;
begin
  Result := True;
  if not VarIsNull(v) then
  begin
    if f.DataType = ftLargeint then
      f.asFloat := v
    else
      f.Value := v;
  end
  else
    f.Value := null;
end;


function GetFieldAsVar(f: TIBXSQLVAR): variant; overload;
begin
  if f.IsNull then
  begin
    Result := null;
  end else
  begin
    if (f.Data.SQLType and (not 1)) = SQL_BLOB then
    begin
      Result := f.AsString;
    end else
    begin
      if (f.Data.SQLType and (not 1)) <> SQL_INT64 then
        Result := f.AsVariant
      else
        if (f.data.sqlscale = 0) or (f.data.sqlscale < (-4)) then
          Result := f.AsDouble
        else
          Result := f.AsCurrency;
    end;
  end;
end;

function GetFieldAsVar(f: TField): variant; overload;
begin
  Result := null;
  if not f.IsNull then
    if f.DataType = ftLargeint then
      Result := f.AsFloat
    else
      Result := f.AsVariant;

end;

// функции для получения ИД из запроса, строки, варианта
function GetTID(s: String; def: TID): TID; overload;
begin
  {$IFDEF ID64}
  Result := StrToInt64Def(s, def);
  {$ELSE}
  Result := StrToIntDef(s, def);
  {$ENDIF}
end;

function GetTID(f: TIBXSQLVAR): TID; overload;
begin
  {$IFDEF ID64}
  Result := f.AsInt64;
  {$ELSE}
  Result := f.AsInteger;
  {$ENDIF}
end;

function GetTID(f: TField): TID; overload;
begin
  {$IFDEF ID64}
  Result := 0;
  if f.AsString <> '' then
    Result := GetTID(f.AsString, 0);
  {$ELSE}
    Result := f.AsInteger;
  {$ENDIF}

end;

function GetTID(f: TParam): TID; overload;
begin
  {$IFDEF ID64}
  Result := 0;
  if f.AsString <> '' then
    Result := GetTID(f.AsString, 0);
  {$ELSE}
    Result := f.AsInteger;
  {$ENDIF}
end;

function GetTID(v: Variant): TID; overload;
begin
  if VarType(v) = varDouble then
    Result := Trunc(v)
  else
    Result := GetTID(VarToStr(v), 0);
end;

function ReadTID(Reader: TReader): TID;
begin
  {$IFDEF ID64}
  Result := Reader.ReadInt64;
  {$ELSE}
  Result := Reader.ReadInteger;
  {$ENDIF}
end;

// функции для присваивания и преобразования ИД
function SetTID(f: TIBXSQLVAR; const ID: TID): TID; overload;
begin
  {$IFDEF ID64}
  f.AsDouble := ID;
  {$ELSE}
  f.AsInteger := ID;
  {$ENDIF}
  Result := ID;
end;

function SetTID(f: TField; const ID: TID): TID; overload;
begin
  {$IFDEF ID64}
  f.AsString := TID2S(ID);
  {$ELSE}
  f.AsInteger := ID;
  {$ENDIF}
  Result := ID;
end;

function SetTID(f: TParam; const ID: TID): TID; overload;
begin
  {$IFDEF ID64}
  f.AsString := TID2S(ID);
  {$ELSE}
  f.AsInteger := ID;
  {$ENDIF}
  Result := ID;
end;

function SetTID(f: TParam; fld: TField): TID; overload;
begin
  Result := GetTID(fld);
  {$IFDEF ID64}
  if not fld.IsNull then
    SetTID(f, Result)
  else
    f.Value := null;
  {$ELSE}
  f.Value := fld.Value;
  {$ENDIF}

end;

function SetTID(f: TIBXSQLVAR; fld: TField): TID; overload;
begin
  Result := GetTID(fld);
  {$IFDEF ID64}
  if not fld.IsNull then
    SetTID(f, Result)
  else
    f.Value := null;
  {$ELSE}
  f.Value := fld.Value;
  {$ENDIF}
end;

function SetTID(f: TIBXSQLVAR; fld: TIBXSQLVAR): TID; overload;
begin
  Result := GetTID(fld);
  {$IFDEF ID64}
  if not fld.IsNull then
    SetTID(f, Result)
  else
    f.Value := null;
  {$ELSE}
  f.Value := fld.Value;
  {$ENDIF}
end;

function SetTID(f: TField; fld: TIBXSQLVAR): TID; overload;
begin
  Result := GetTID(fld);
  {$IFDEF ID64}
  if not fld.IsNull then
    SetTID(f, Result)
  else
    f.Value := null;
  {$ELSE}
  f.Value := fld.Value;
  {$ENDIF}
end;

function SetTID(f: TField; fld: TField): TID; overload;
begin
  Result := GetTID(fld);
  {$IFDEF ID64}
  if not fld.IsNull then
    SetTID(f, Result)
  else
    f.Value := null;
  {$ELSE}
  f.Value := fld.Value;
  {$ENDIF}
end;

function SetTID(f: TField; const S: string): TID; overload;
begin
  Result := GetTID(S);
  f.AsString := S;
end;

function TID264(const ID: TID): Int64; overload;
begin
  Result := ID;
end;

function TID264(const f: TIBXSQLVAR): Int64; overload;
begin
  Result := TID264(GetTID(f));
end;

function TID264(const f: TField): Int64; overload;
begin
  Result := TID264(GetTID(f));
end;

function TID2S(const ID: TID): string; overload;
begin
  {$IFDEF ID64}
  Result := IntToStr(ID);
  {$ELSE}
  Result := IntToStr(ID);
  {$ENDIF}

end;

function TID2S(f: TIBXSQLVAR): string; overload;
begin
  Result := TID2S(GetTID(f));
end;

function TID2S(const f: TField): String; overload;
begin
  Result := TID2S(GetTID(f));
end;

function TID2V(const ID: TID): variant; overload;
begin
  {$IFDEF ID64}
  if ID > MAXINT then
    Result := TID2S(ID)
  else
    Result :=  StrtoInt(TID2S(ID));
  {$ELSE}
  Result := ID;
  {$ENDIF}
end;

function TID2V(f: TField): variant; overload;
begin
  {$IFDEF ID64}
  if f.IsNull then
    Result := null
  else
    Result := TID2S(GetTID(f));
  {$ELSE}
  Result := f.value;
  {$ENDIF}
end;

function TID2V(f: TIBXSQLVAR): variant; overload;
begin
  {$IFDEF ID64}
  if f.IsNull then
    Result := null
  else
    Result := TID2S(GetTID(f));
  {$ELSE}
  Result := f.value;
  {$ENDIF}
end;

function TID2P(const f: TField): PID; overload;
var Value: TID;
begin
  Value := GetTID(f);
  Result := @Value;
end;

function TID2P(const ID: TID): PID; overload;
begin
  Result := @ID;
end;

{$IFDEF ID64}
type
  TIDArray = array of TID;
  PIDArray = ^TIDArray;

var
  ConvertList: TStringList;

procedure FreeConvertContext(Context: String);
var
  CtxIdx: Integer;
  Obj: TObject;
  IDArray: PIDArray;
begin
  if Assigned(ConvertList) then
  begin
    CtxIdx := ConvertList.IndexOf(UpperCase(Context));
    if CtxIdx > -1 then
    begin
      Obj := ConvertList.Objects[CtxIdx];
      IDArray := PIDArray(Obj);
      Dispose(IDArray);
      ConvertList.Delete(CtxIdx);
    end;
  end;
end;
{$ENDIF}

function TID2Pointer(ID: TID; Context: String): Pointer;
{$IFDEF ID64}
var
  CtxIdx, I: Integer;
  IDArray: PIDArray;
  Obj: TObject;
{$ENDIF}
begin
  {$IFDEF ID64}
  if not Assigned(ConvertList) then
    ConvertList := TStringList.Create;

  CtxIdx := ConvertList.IndexOf(UpperCase(Context));
  if CtxIdx = -1 then
  begin
    New(IDArray);
    // т.к. Pointer(0) = nil, вставляем нулевую запись,
    // которую не будем использовать
    SetLength(IDArray^,  1);
    IDArray^[0] := -1;
    CtxIdx := ConvertList.AddObject(UpperCase(Context), TObject(IDArray));
    //CtxIdx := ConvertList.IndexOf(Context);
  end;
  Obj := ConvertList.Objects[CtxIdx];
  IDArray := PIDArray(Obj);

  for I := 1 to High(IDArray^) do
  begin
    if IDArray^[I] = ID then
    begin
      Result := Pointer(I);
      exit;
    end;
  end;
  SetLength(IDArray^, Length(IDArray^) + 1);
  I := High(IDArray^);
  IDArray^[I] := ID;
  Result := Pointer(I);
  {$ELSE}

  Result := Pointer(ID);
  {$ENDIF}
end;

function TID2Tag(ID: TID; Context: String): Integer;
begin
  {$IFDEF ID64}
  Result := Integer(TID2Pointer(ID, Context));
  {$ELSE}
  Result := ID;
  {$ENDIF}
end;

function TID2TObject(ID: TID; Context: String): TObject;
begin
  {$IFDEF ID64}
  Result := TObject(TID2Pointer(ID, Context));
  {$ELSE}
  Result := TObject(ID);
  {$ENDIF}
end;

function GetTID(o: TObject; Context: String): TID; overload;
begin
  {$IFDEF ID64}
  Result := GetTID(Pointer(o), Context);
  {$ELSE}
  Result := TID(o);
  {$ENDIF}
end;

function GetTID(tag: Integer; Context: String): TID;
begin
  {$IFDEF ID64}
  Result := GetTID(Pointer(tag), Context);
  {$ELSE}
  Result := tag;
  {$ENDIF}
end;

function GetTID(p: Pointer; Context: String): TID; overload;
{$IFDEF ID64}
var
  CtxIdx, I: Integer;
  IDArray: PIDArray;
  Obj: TObject;
{$ENDIF}
begin
  if P = nil then
    raise Exception.Create('Pointer = nil (Context - ' + Context + ')');

  {$IFDEF ID64}
  if not Assigned(ConvertList) then
    raise Exception.Create('ConvertList isn''t assigned');

  CtxIdx := ConvertList.IndexOf(UpperCase(Context));
  if CtxIdx = -1 then
    raise Exception.Create('Unknown convertation context - ' + Context);

  Obj := ConvertList.Objects[CtxIdx];
  IDArray := PIDArray(Obj);

  I := Integer(p);

  if (I < Low(IDArray^)) or (I > High(IDArray^)) then
    raise Exception.Create('Invalid TID conversion. Index is out of range.');

  Result := IDArray^[I];

  {$ELSE}
  Result := TID(p);
  {$ENDIF}
end;

// функции для проверки ИД в 32битном диапазоне
function Is32TID(const ID: TID): boolean;
begin
  {$IFDEF ID64}
  Result := True
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

procedure Check32TID(const ID: TID);
begin
  {if ID > MAXINT then
    raise Exception.Create('Invalid 32bit TID');}
end;

function EqTID(const ID1, ID2: TID): boolean; overload;
begin
  Result := ID1 = ID2;
end;

function EqTID(ID1: TField; const ID2: TID): boolean; overload;
begin
  Result := GetTID(ID1) = ID2;
end;

function EqTID(f: TIBXSQLVAR; const ID: TID): boolean; overload;
begin
  Result := GetTID(f) = ID;
end;

procedure AssignField64(f: TField; fld: TField); overload;
begin
  if f.DataType = ftLargeInt then
    SetTID(f, fld)
  else
    f.Assign(fld);
end;

//функция определяет длину Идентификаторов в потоке по
//наличию метки
function GetLenIDInStream(PS: PStream): Integer; overload;
{$IFDEF ID64}
var
  p: Integer;
  lbl: array[0..SizeOf(lblInt64Stream) - 1] of Char;
{$ENDIF}
begin
  {$IFDEF ID64}
  Assert(PS <> nil);
  p := PS^.Position;
  if (PS^.Read(lbl, SizeOf(lblInt64Stream)) = SizeOf(lblInt64Stream)) and (lbl = lblInt64Stream) then
    Result := SizeOf(TID)
  else
  begin
    PS^.Position := p;
    Result := SizeOf(Integer);
  end;
  {$ELSE}
    Result := SizeOf(TID);
  {$ENDIF}
end;

//функция определяет длину Идентификаторов в потоке
//и устанавливает метку для Int64
function SetLenIDinStream(PS: PStream): Integer; overload;
begin
  {$IFDEF ID64}
  Assert(PS <> nil);
  PS^.WriteBuffer(lblInt64Stream, SizeOf(lblInt64Stream));
  Result := SizeOf(TID);
  {$ELSE}
  Result := SizeOf(Integer);
  {$ENDIF}
end;

function CheckRuid(const RUIDString: String): Boolean;
var
  I: Integer;
begin
  I := Pos('_', RUIDString);
  Result := (I > 0)
    and (GetTID(Copy(RUIDString, 1, I - 1), -1) >= 0)
    and (StrToIntDef(Copy(RUIDString, I + 1, 1024), -1) >= 0);
end;

function RUIDToStr(const ARUID: TRUID): String; overload;
begin
  Result := RUIDToStr(ARUID.XID, ARUID.DBID);
end;

function RUIDToStr(const XID: TID; const DBID: Integer): String; overload;
begin
  if (XID = -1) or (DBID = -1) then
    Result := ''
  else
    Result := TID2S(XID) + '_' + IntToStr(DBID);
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
        XID := GetTID(Copy(AString, 1, P - 1), -1);
        DBID := StrToIntDef(Copy(AString, P + 1, 255), -1);
        if (XID <= 0) or (DBID <= 0) then
          raise Exception.Create('Invalid RUID string')
      end;
    end;
end;

function RUID(const XID: TID; const DBID: Integer): TRUID;
begin
  Result.XID := XID;
  Result.DBID := DBID;
end;

function IsGedeminSystemID(const AnID: TID): Boolean;
begin
  Result := AnID < cstUserIDStart;
end;

function IsGedeminNonSystemID(const AnID: TID): Boolean;
begin
  Result := AnID >= cstUserIDStart;
end;

function DatasetLocate(var Dataset: TDataset; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
{$IFDEF ID64}
var CurBookmark: string;
    fl: TList;
    val : Array of Variant;
    i, fld_cnt: Integer;
    fld_str : String;
{$ENDIF}
begin
  {$IFDEF ID64}
  with Dataset do
  begin

    Result := False;
    CurBookmark := Bookmark;
    DataSet.DisableControls;
    First;

    fl := TList.Create;
    try
      GetFieldList(fl, KeyFields);
      fld_cnt := fl.Count;
      if fld_cnt = 0 then
        exit;

      SetLength(val, fld_cnt);
      for i := 0 to fld_cnt - 1 do
      begin
        if VarIsArray(KeyValues) then
        begin
          if i <= VarArrayHighBound(KeyValues, 1) then
            val[i] := KeyValues[i]
          else
            val[i] := varNull;
        end else
          val[i] := KeyValues;
        if (VarType(val[i]) = varString) and (loCaseInsensitive in Options) then
          val[i] := AnsiUpperCase(val[i]);
      end;

      while (not Result) and (not EOF) do
      begin
        i := 0;
        Result := True;
        while Result and (i < fld_cnt) do
        begin
          if TField(fl[i]).IsNull then
            Result := Result and VarIsNull(val[i])
          else begin
            Result := Result and not VarIsNull(val[i]);
            if Result then
            begin
              case VarType(val[i]) of
                varString:
                begin
                  fld_str := TField(fl[i]).AsString;

                  if (loCaseInsensitive in Options) then
                    fld_str := AnsiUpperCase(fld_str);
                  if (loPartialKey in Options) then
                    Result := Result and (AnsiPos(val[i], fld_str) = 1)
                  else
                    Result := Result and (fld_str = val[i]);
                end;

                varDate:
                begin
                  Result := Result and (TField(fl[i]).AsDateTime = val[i]);
                end;

                varDouble:
                begin
                  Result := Result and (TField(fl[i]).AsFloat = val[i]);
                end;
              else
                if TField(fl[i]).DataType <> ftLargeint then
                  Result := Result and (TField(fl[i]).Value = val[i])
                else
                  Result := Result and (TField(fl[i]).AsFloat = val[i]);
              end;
            end;
          end;
          Inc(i);
        end;

        if not Result then
          Next;

      end;
    finally
      fl.Free;
      DataSet.EnableControls;
      val := nil;
    end;

    if not Result then
      Bookmark := CurBookmark;
  end;
  {$ELSE}
  if Dataset is TClientDataset then
    Result := TClientDataset(Dataset).Locate(KeyFields, KeyValues, Options)
  else
    Result := Dataset.Locate(KeyFields, KeyValues, Options);
  {$ENDIF}
end;


{$IFDEF ID64}
var
  I: Integer;
  IDArray: PIDArray;
{$ENDIF}

initialization
  Global_LoadingNamespace := False;
  Global_DisableQueryFilter := False;

finalization
  {$IFDEF ID64}
  if Assigned(ConvertList) then
  begin
    for I := 0 to ConvertList.Count - 1 do
    begin
      IDArray := PIDArray(ConvertList.Objects[I]);
      Dispose(IDArray);
    end;
    ConvertList.Free;
  end;
  {$ENDIF}
end.
