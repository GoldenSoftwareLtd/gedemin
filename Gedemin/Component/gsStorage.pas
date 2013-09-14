
unit gsStorage;

interface

uses
  Classes, Contnrs, SysUtils, Comctrls, Controls, Forms,
  IBHeader, IBDatabase, IBSQL, gd_security, extctrls;

const
                                  // sh -- storage header
  shSignature       = $00002001;  // подпіс
  shVersion         = $00000001;  // вэрсія

  shNoCompression   = $00000000;  // дадзеныя не запакованыя
  shZLibCompression = $00000001;  // дадзеныя запакованыя

  StreamSignature   = $00001234;  // подпіс плыні

type
  // сохраняя данные хранилища в поток мы предворим их
  // заголовком, чтобы правильно считать потом
  TgsStorageHeader = record
    Signature: Integer;         { must be $2001                }
    Version: Integer;           { now 0001                     }
    CompressionType: Integer;   { 0 - no compression, 1 - zlib }
  end;

  TgsStorageDataCompression = (sdcNone, sdcZLib);

  TgsStorageFileFormat = (sffBinary, sffText);

const
  DefDataCompression = sdcZLib;

                                 // svt -- storage value type
  svtUnknown         = $0000;    // невядомы
  svtInteger         = $0001;    // цэлы лік
  svtString          = $0002;    // страка
  svtStream          = $0003;    // плынь
  svtBoolean         = $0004;    // булеўскі тып
  svtDateTime        = $0005;    // дата, час
  svtCurrency        = $0006;    // валюта

type
  TSaveToStreamMethod = procedure(S: TStream) of object;
  TLoadFromStreamMethod = procedure(S: TStream) of object;

type
  // опции поиска:
  // gstsoSubFolder -- искать в подпапках
  // gstsoValue     -- искать в именах переменных
  // gstsoFolder    -- искать в именах папок
  // gstsoData      -- искать в значениях переменных
  TgstSearchOption = (gstsoValue, gstsoFolder, gstsoData);
  TgstSearchOptions = set of TgstSearchOption;

  TgsStorageItem = class;
  TgsStorageValue = class;
  TgsStorageFolder = class;
  TgsStorage = class;

  TgsStorageValueClass = class of TgsStorageValue;

  TgsStorageItem = class(TObject)
  private
    FName: String;
    FParent: TgsStorageItem;
    FChanged: Boolean;

    procedure SetName(const Value: String);

  protected
    FID: Integer;
    FModified: TDateTime;

    function GetStorage: TgsStorage; virtual;

    // возвращает строку -- путь к элементу
    function GetPath: String; virtual;
    // возвращает размер элемента (вместе с данными)
    function GetDataSize: Integer; virtual;

    // проверяет имя элемента на допустимость
    function CheckForName(const AName: String): String; virtual;
    function GetFreeName: String;
    // очищает данные элемента
    procedure Clear; virtual;

    // считывают и сохраняют в форматированный поток
    // где все данные представлены в текстовом виде
    // формат потока близок к формату текстового
    // файла реестра Виндоуз
    procedure LoadFromStream2(S: TStringStream); virtual;
    procedure SaveToStream2(S: TStringStream); virtual;

    // считывают и сохраняют в двоичный неформатированный
    // поток
    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;

    procedure AddChildren(SI: TgsStorageItem); virtual;
    procedure RemoveChildren(SI: TgsStorageItem); virtual;

    //Пропускает объект в потоке
    class procedure SkipInStream(S: TStream); virtual;

  public
    constructor Create(AParent: TgsStorageItem; const AName: String = '';
      const AnID: Integer = -1); virtual;

    destructor Destroy; override;

    class function GetTypeName: Char; virtual; abstract;

    procedure LoadFromFile(const AFileName: String; const FileFormat: TgsStorageFileFormat); virtual;
    procedure SaveToFile(const AFileName: String; const FileFormat: TgsStorageFileFormat); virtual;

    procedure Drop; virtual;

    // в функцию передается список, строка для поиска и параметры поиска
    // она осуществялет поиск в соответствии с введенной строкой
    // и параметрами и все найденные объекты добавляет в список
    // если что-то было найдено и добавлено в список, возвращается
    // истина, в противном случае -- ложь
    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions;
      const DateFrom: TDate = 0; const DateTo: TDate = 0): Boolean; virtual; abstract;

    property ID: Integer read FID;
    property Name: String read FName write SetName;
    property Parent: TgsStorageItem read FParent;
    property Path: String read GetPath;
    property DataSize: Integer read GetDataSize;
    property Modified: TDateTime read FModified;
    property Changed: Boolean read FChanged;

    property Storage: TgsStorage read GetStorage;
  end;

  TgsStorageFolder = class(TgsStorageItem)
  private
    FDestroying: Boolean;

    function GetFoldersCount: Integer;
    function GetValuesCount: Integer;
    function GetFolders(Index: Integer): TgsStorageFolder;
    function GetValues(Index: Integer): TgsStorageValue;

  protected
    FFolders, FValues: TObjectList;

    function GetDataSize: Integer; override;

    function CheckForName(const AName: String): String; override;

    procedure LoadFromStream2(S: TStringStream); override;
    procedure SaveToStream2(S: TStringStream); override;

  public
    destructor Destroy; override;

    procedure Clear; override;

    function OpenFolder(APath: String; const CanCreate: Boolean): TgsStorageFolder;

    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean; override;

    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    procedure AddChildren(SI: TgsStorageItem); override;
    procedure RemoveChildren(SI: TgsStorageItem); override;

    class function GetTypeName: Char; override;
    class procedure SkipInStream(S: TStream); override;

    function ReadString(const AValueName: String; const Default: String = ''): String;
    procedure WriteString(const AValueName: String; const AValue: String = '');

    function ReadInteger(const AValueName: String; const Default: Integer = 0): Integer;
    procedure WriteInteger(const AValueName: String; const AValue: Integer = 0);

    function ReadCurrency(const AValueName: String; const Default: Currency = 0): Currency;
    procedure WriteCurrency(const AValueName: String; const AValue: Currency = 0);

    function ReadDateTime(const AValueName: String; const Default: TDateTime): TDateTime;
    procedure WriteDateTime(const AValueName: String; const AValue: TDateTime);

    function ReadBoolean(const AValueName: String; const Default: Boolean = True): Boolean;
    procedure WriteBoolean(const AValueName: String; const AValue: Boolean = True);

    procedure ReadStream(const AValueName: String; S: TStream);
    procedure WriteStream(const AValueName: String; S: TStream);

    procedure WriteValue(AValue: TgsStorageValue);

    procedure BuildTreeView(N: TTreeNode; const L: TList = nil);

    function CreateFolder(const AName: String): TgsStorageFolder;
    function ValueExists(const AValueName: String): Boolean;
    function FolderExists(const AFolderName: String): Boolean;
    function ValueByName(const AValueName: String): TgsStorageValue;
    function DeleteFolder(const AName: String): Boolean;
    procedure ExtractFolder(F: TgsStorageFolder);
    procedure AddFolder(F: TgsStorageFolder);
    function FolderByName(const AName: String): TgsStorageFolder;
    function DeleteValue(const AValueName: String): Boolean;
    function FindFolder(F: TgsStorageFolder; const GoSubFolders: Boolean = True): Boolean;
    //function MoveFolder(NewParent: TgsStorageFolder): Boolean;

    procedure ShowPropDialog;

    property Folders[Index: Integer]: TgsStorageFolder read GetFolders;
    property FoldersCount: Integer read GetFoldersCount;

    property Values[Index: Integer]: TgsStorageValue read GetValues;
    property ValuesCount: Integer read GetValuesCount;

    procedure AddValueFromStream(AValueName: String; S: TStream);
    class procedure SkipValueInStream(S: TStream);
  end;

  TgsRootFolder = class(TgsStorageFolder)
  protected
    FStorage: TgsStorage;

    function GetStorage: TgsStorage; override;

  public
    procedure Drop; override;
  end;

  TgsStorageValue = class(TgsStorageItem)
  private
    class function CreateFromStream(AParent: TgsStorageFolder; S: TStream): TgsStorageValue;

  protected
    function CheckForName(const AName: String): String; override;

    function GetAsCurrency: Currency; virtual;
    procedure SetAsCurrency(const Value: Currency); virtual;
    function GetAsInteger: Integer; virtual;
    procedure SetAsInteger(const Value: Integer); virtual;
    function GetAsString: String; virtual;
    procedure SetAsString(const Value: String); virtual;
    function GetAsBoolean: Boolean; virtual;
    procedure SetAsBoolean(const Value: Boolean); virtual;
    function GetAsDateTime: TDateTime; virtual;
    procedure SetAsDateTime(const Value: TDateTime); virtual;

    procedure LoadFromStream2(S: TStringStream); override;
    procedure SaveToStream2(S: TStringStream); override;

  public
    class function GetTypeId: Integer; virtual; abstract;

    class procedure SkipInStream(S: TStream); override;

    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean; override;

    function ShowEditValueDialog: TModalResult;

    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsString: String read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;

    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;
  end;

  TgsIntegerValue = class(TgsStorageValue)
  private
    FData: Integer;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsCurrencyValue = class(TgsStorageValue)
  private
    FData: Currency;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsCurrency: Currency; override;
    procedure SetAsCurrency(const Value: Currency); override;
    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsStringValue = class(TgsStorageValue)
  private
    FData: String;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;
    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    function GetAsCurrency: Currency; override;
    procedure SetAsCurrency(const Value: Currency); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsDateTimeValue = class(TgsStorageValue)
  private
    FData: TDateTime;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const Value: TDateTime); override;
    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsBooleanValue = class(TgsStorageValue)
  private
    FData: Boolean;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const Value: Integer); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const Value: Boolean); override;
    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;
    function GetAsCurrency: Currency; override;
    procedure SetAsCurrency(const Value: Currency); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsStreamValue = class(TgsStorageValue)
  private
    FData: String;
    FQUAD: TISC_QUAD;
    FLoaded: Boolean;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;

    procedure LoadFromStream2(S: TStringStream); override;
    procedure SaveToStream2(S: TStringStream); override;

    procedure SaveBLOB(Tr: TIBTransaction);

    property AsQUAD: TISC_QUAD read FQUAD write FQUAD;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    procedure LoadDataFromStream(S: TStream);
    procedure SaveDataToStream(S: TStream);

    class function GetTypeId: Integer; override;
    class function GetTypeName: Char; override;
  end;

  TgsStorage = class(TObject)
  private
    FRootFolder: TgsRootFolder;
    {$IFDEF DEBUG}
    FOpenFolders: TStringList;
    {$ENDIF}

    function GetDataString: String;
    procedure SetDataString(const Value: String);
    function GetName: String;
    function GetModified: Boolean;

  protected
    procedure BeforeOpenFolder; virtual;
    procedure AfterCloseFolder; virtual;

    procedure DeleteStorageItem(const AnID: Integer); virtual;
    function UpdateName(const Tr: TIBTransaction = nil): String; virtual;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream); virtual;

    procedure SaveToStream2(S: TStringStream);
    procedure LoadFromStream2(S: TStringStream);

    procedure LoadFromFile(const AFileName: String; const AFileFormat: TgsStorageFileFormat);
    procedure SaveToFile(const AFileName: String; const AFileFormat: TgsStorageFileFormat);

    procedure BuildTreeView(N: TTreeNode; const L: TList = nil);
    procedure Clear;

    function OpenFolder(const APath: String; const CanCreate: Boolean = False;
      const SyncWithDatabase: Boolean = True): TgsStorageFolder;
    procedure CloseFolder(gsStorageFolder: TgsStorageFolder; const SyncWithDatabase: Boolean = True); overload;
    function FolderExists(const APath: String;
      const SyncWithDatabase: Boolean = True): Boolean;
    function ValueExists(const APath, AValue: String;
      const SyncWithDatabase: Boolean = True): Boolean;
    procedure DeleteFolder(const APath: String; const SyncWithDatabase: Boolean = True);
    procedure DeleteValue(const APath: String; const AValueName: String;
      const SyncWithDatabase: Boolean = True);

    function ReadCurrency(const APath, AValue: String;
      const Default: Currency = 0; const Sync: Boolean = True): Currency;
    function ReadInteger(const APath, AValue: String;
      const Default: Integer = 0; const Sync: Boolean = True): Integer;
    function ReadDateTime(const APath, AValue: String;
      const Default: TDateTime; const Sync: Boolean = True): TDateTime;
    function ReadBoolean(const APath, AValue: String;
      const Default: Boolean = True; const Sync: Boolean = True): Boolean;
    function ReadString(const APath, AValue: String;
      const Default: String = ''; const Sync: Boolean = True): String;
    function ReadStream(const APath, AValue: String; S: TStream;
      const ASync: Boolean = True): Boolean;

    procedure WriteString(const APath, AValueName, AValue: String; const Sync: Boolean = True);
    procedure WriteInteger(const APath, AValueName: String; const AValue: Integer);
    procedure WriteCurrency(const APath, AValueName: String; const AValue: Currency);
    procedure WriteBoolean(const APath, AValueName: String; const AValue: Boolean; const Sync: Boolean = True);
    procedure WriteDateTime(const APath, AValueName: String; const AValue: TDateTime);
    procedure WriteStream(const APath, AValueName: String; AValue: TStream);

    function SaveComponent(C: TComponent; M: TSaveToStreamMethod; const Context: String = ''): String;
    procedure LoadComponent(C: TComponent; M: TLoadFromStreamMethod; const Context: String = '';
      const ALoadAdmin: Boolean = True);

    //
    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean;

    function FindID(const AnID: Integer; out SI: TgsStorageItem): Boolean;

    property Name: String read GetName;
    property IsModified: Boolean read GetModified;
    property DataString: String read GetDataString write SetDataString;
  end;

  TgsIBStorage = class(TgsStorage)
  private
    FObjectKey: Integer;
    FDataType: Char;

    procedure SetObjectKey(const Value: Integer);

  protected
    procedure DeleteStorageItem(const AnID: Integer); override;
    function UpdateName(const Tr: TIBTransaction = nil): String; override;

    property DataType: Char read FDataType write FDataType;

  public
    constructor Create; override;

    procedure SaveToStream(S: TStream); override;

    procedure SaveToDataBase(const ATr: TIBTransaction = nil); virtual;
    procedure LoadFromDataBase(const ATr: TIBTransaction = nil); virtual;

    property ObjectKey: Integer read FObjectKey write SetObjectKey;
  end;

  TgsCompanyStorage = class(TgsIBStorage)
  protected
    function UpdateName(const Tr: TIBTransaction = nil): String; override;

  public
    constructor Create; override;
  end;

  TgsUserStorage = class(TgsIBStorage)
  protected
    function UpdateName(const Tr: TIBTransaction = nil): String; override;

  public
    constructor Create; override;
  end;

  TgsDesktopStorage = class(TgsStorage)
  end;

  TgsGlobalStorage = class(TgsIBStorage);

  EgsStorageError = class(Exception);
  EgsStorageTypeCastError = class(EgsStorageError);
  EgsStorageFolderError = class(EgsStorageError);

  //см. комментарии к TgdcDragObject
  TgsStorageDragObject = class(TDragObject)
  protected
    procedure Finished(Target: TObject; X, Y: Integer; Accepted: Boolean); override;
  public
    F: TgsStorageFolder;
    TN: TTreeNode;

    constructor Create(AF: TgsStorageFolder; ATN: TTreeNode);
  end;

  function GetScreenRes: Integer;

  function DateIntvlCheck(const CheckedDate, DateFrom, DateTo: TDate): Boolean;

  procedure LockStorage(const ALock: Boolean);

implementation

uses
  JclSysUtils, ZLib, Windows, st_dlgfolderprop_unit, gd_common_functions,
  st_dlgeditvalue_unit, gsStorage_CompPath, DB, IB, IBErrorCodes,
  IBBlob, gdcBaseInterface, jclStrings, gdcStorage_Types
  {$IFDEF GEDEMIN}
  , gd_directories_const, Storages, gdc_frmG_unit
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  StorageLoading: Boolean;
{$IFDEF DEBUG}
  StorageFolderSearchCounter: Integer;
  LogSL: TStringList;
{$ENDIF}

const
  CacheTime                = 200;

function GetScreenRes: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC, HORZRES) * GetDeviceCaps(DC, VERTRES);
  finally
    ReleaseDC(0, DC);
  end;
end;

function DateIntvlCheck(const CheckedDate, DateFrom, DateTo: TDate): Boolean;
begin
  Result := ((DateFrom = 0) and (DateTo = 0)) or
   ((DateFrom = 0) and (CheckedDate <= DateTo)) or
   ((DateTo = 0) and (CheckedDate >= DateFrom)) or
   ((CheckedDate >= DateFrom) and (CheckedDate <= DateTo));
end;

procedure LockStorage(const ALock: Boolean);
begin
  if StorageLoading = ALock then
    raise EgsStorageError.Create('Invalid lock status');
  StorageLoading := ALock;
end;

{ TgsStorageFolder }

procedure TgsStorageFolder.BuildTreeView(N: TTreeNode; const L: TList = nil);
var
  I: Integer;
  K: TTreeNode;
  P: Pointer;
  S: PString;
begin
  if GetDataSize > 0 then
    N.Text := FName + ' [' + IntToStr(GetDataSize) + ']'
  else
    N.Text := FName;
  N.ImageIndex := 0;
  for I := 0 to FoldersCount - 1 do
  begin
    if L = nil then
      P := Folders[I]
    else begin
      New(S);
      S^ := Folders[I].Path;
      P := S;
      L.Add(P);
    end;

    K := (N.TreeView as TTreeView).Items.AddChildObject(N, Folders[I].Name, P);
    Folders[I].BuildTreeView(K, L);
  end;
end;

function TgsStorageFolder.CheckForName(const AName: String): String;
begin
  Result := inherited CheckForName(AName);
  if Assigned(FParent) and (FParent as TgsStorageFolder).FolderExists(AName) then
    raise EgsStorageError.Create('Duplicate folder name');
end;

procedure TgsStorageFolder.Clear;
begin
  FDestroying := True;
  try
    FreeAndNil(FFolders);
    FreeAndNil(FValues);
    inherited Clear;
  finally
    FDestroying := False;
  end;
end;

function TgsStorageFolder.CreateFolder(
  const AName: String): TgsStorageFolder;
begin
  Result := TgsStorageFolder.Create(Self, AName);
end;

function TgsStorageFolder.DeleteFolder(const AName: String): Boolean;
var
  F: TgsStorageFolder;
begin
  F := FolderByName(AName);
  if F <> nil then
  begin
    F.Drop;
    Result := True;
  end else
    Result := False;
end;

destructor TgsStorageFolder.Destroy;
begin
  FDestroying := True;
  FValues.Free;
  FFolders.Free;
  inherited;
end;

function TgsStorageFolder.FolderByName(
  const AName: String): TgsStorageFolder;

  function Cmp(const S1, S2: String): Boolean;
  var
    L, J: Integer;
  begin
    L := Length(S1);
    if L <> Length(S2) then
      Result := False
    else begin
      for J := L downto 1 do
      begin
        if S2[J] <> S1[J] then
        begin
          if UpCase(S2[J]) <> UpCase(S1[J]) then
          begin
            Result := False;
            exit;
          end;
        end;
      end;
      Result := True;
    end;
  end;

var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FoldersCount - 1 do
  begin
    if Cmp(Folders[I].Name, AName) then
    begin
      {$IFDEF DEBUG}
      Inc(StorageFolderSearchCounter);
      {$ENDIF}
      Result := Folders[I];

      { TODO :
опасный момент. по идее должно переместить наиболее часто
используемые папки вверх, но с другой стороны
если кто-то полагается не на имя папки, а на ее индекс, то...
плюс время на сдвиг памяти...
}
      if I > 10 then
      begin
        FFolders.Move(I, 0);
      end;
      break;
    end;
  end;
end;

function TgsStorageFolder.GetDataSize: Integer;
var
  I: Integer;
begin
  Result := inherited GetDataSize;
  for I := 0 to ValuesCount - 1 do
    Result := Result + Values[I].DataSize;
  for I := 0 to FoldersCount - 1 do
    Result := Result + Folders[I].DataSize;
end;

function TgsStorageFolder.OpenFolder(APath: String; const CanCreate: Boolean): TgsStorageFolder;
var
  S: String;
  F: TgsStorageFolder;
  L, P: Integer;
begin
  L := Length(APath);
  if (L > 0) and (APath[1] = '\') then
  begin
    Delete(APath, 1, 1);
    Dec(L);
  end;
  if L = 0 then
    Result := Self
  else
  begin
    Result := nil;

    P := Pos('\', APath);
    if P > 0 then
      S := Copy(APath, 1, P - 1)
    else
      S := APath;

    F := FolderByName(S);
    if F <> nil then
    begin
      if P = 0 then
        Result := F
      else
        Result := F.OpenFolder(Copy(APath, Length(S) + 1, Length(APath)), CanCreate);
    end;

    if (Result = nil) and CanCreate then
    begin
      F := CreateFolder(S);
      Result := F.OpenFolder(
        iff(Pos('\', APath) > 0,
            Copy(APath, Pos('\', APath) + 1, Length(APath)),
            ''), CanCreate);
    end;
  end;
end;

function TgsStorageFolder.GetFolders(Index: Integer): TgsStorageFolder;
begin
  Assert(FFolders <> nil);
  Result := FFolders[Index] as TgsStorageFolder;
end;

function TgsStorageFolder.GetFoldersCount: Integer;
begin
  if FFolders = nil then
    Result := 0
  else
    Result := FFolders.Count;
end;

function TgsStorageFolder.GetValues(Index: Integer): TgsStorageValue;
begin
  Assert(FValues <> nil);
  Result := FValues[Index] as TgsStorageValue;
end;

function TgsStorageFolder.GetValuesCount: Integer;
begin
  if FValues = nil then
    Result := 0
  else
    Result := FValues.Count;
end;

procedure TgsStorageFolder.LoadFromStream(S: TStream);
var
  L, I: Integer;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  inherited LoadFromStream(S);
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    F := TgsStorageFolder.Create(Self);
    try
      F.LoadFromStream(S);
    except
      F.Free;
      raise;
    end;

    if (StrIPos('noname', F.Name) = 1) and
      (F.FoldersCount = 0) and (F.ValuesCount = 0) then
    begin
      F.Free;
    end;
  end;
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    V := TgsStorageValue.CreateFromStream(Self, S);
    if V = nil then
      raise EgsStorageFolderError.Create(
        'Ошибка при считывании значения #' + IntToStr(I) + ' в папке ' + Path);
  end;
end;

class procedure TgsStorageFolder.SkipInStream(S: TStream);
var
  L, I: Integer;
begin
  inherited SkipInStream(S);
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    SkipInStream(S);
  end;
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    SkipValueInStream(S);
  end;
end;

function TgsStorageFolder.ReadCurrency(const AValueName: String;
  const Default: Currency): Currency;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    Result := V.AsCurrency
  else
    Result := Default;
end;

function TgsStorageFolder.ReadDateTime(const AValueName: String;
  const Default: TDateTime): TDateTime;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    Result := V.AsDateTime
  else
    Result := Default;
end;

function TgsStorageFolder.ReadBoolean(const AValueName: String;
  const Default: Boolean): Boolean;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    Result := V.AsBoolean
  else
    Result := Default;
end;

function TgsStorageFolder.ReadInteger(const AValueName: String;
  const Default: Integer): Integer;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    Result := V.AsInteger
  else
    Result := Default;
end;

function TgsStorageFolder.ReadString(const AValueName,
  Default: String): String;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    Result := V.AsString
  else
    Result := Default;
end;

procedure TgsStorageFolder.SaveToStream(S: TStream);
var
  L, I: Integer;
begin
  inherited SaveToStream(S);
  L := FoldersCount;
  S.WriteBuffer(L, SizeOf(L));
  for I := 0 to L - 1 do
    Folders[I].SaveToStream(S);
  L := ValuesCount;
  S.WriteBuffer(L, SizeOf(L));
  for I := 0 to L - 1 do
    Values[I].SaveToStream(S);
end;

function TgsStorageFolder.ValueByName(
  const AValueName: String): TgsStorageValue;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ValuesCount - 1 do
    if AnsiCompareText(Values[I].Name, AValueName) = 0 then
    begin
      Result := Values[I];
      break;
    end;
end;

function TgsStorageFolder.ValueExists(const AValueName: String): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to ValuesCount - 1 do
    if AnsiCompareText(Values[I].Name, AValueName) = 0 then
    begin
      Result := True;
      break;
    end;
end;

procedure TgsStorageFolder.WriteInteger(const AValueName: String;
  const AValue: Integer = 0);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    V.AsInteger := AValue
  else
  begin
    V := TgsIntegerValue.Create(Self, AValueName);
    V.AsInteger := AValue;
  end;
end;

procedure TgsStorageFolder.WriteCurrency(const AValueName: String;
  const AValue: Currency = 0);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    V.AsCurrency := AValue
  else
  begin
    V := TgsCurrencyValue.Create(Self, AValueName);
    V.AsCurrency := AValue;
  end;
end;

procedure TgsStorageFolder.WriteBoolean(const AValueName: String;
  const AValue: Boolean = True);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    V.AsBoolean := AValue
  else
  begin
    V := TgsBooleanValue.Create(Self, AValueName);
    V.AsBoolean := AValue;
  end;
end;

procedure TgsStorageFolder.WriteDateTime(const AValueName: String;
  const AValue: TDateTime);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    V.AsDateTime := AValue
  else
  begin
    V := TgsDateTimeValue.Create(Self, AValueName);
    V.AsDateTime := AValue;
  end;
end;

procedure TgsStorageFolder.WriteString(const AValueName: String; const AValue: String = '');
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
    V.AsString := AValue
  else
  begin
    V := TgsStringValue.Create(Self, AValueName);
    V.AsString := AValue;
  end;
end;

procedure TgsStorageFolder.ShowPropDialog;
var
  C: Double;
  FC, VC, ChFC, ChVC: Integer;

  procedure CountItems(F: TgsStorageFolder; var AFC, AVC, AChFC, AChVC: Integer);
  var
    I: Integer;
  begin
    Inc(AFC);
    if F.Changed then Inc(AChFC);
    Inc(AVC, F.ValuesCount);
    for I := 0 to F.ValuesCount - 1 do
      if F.Values[I].Changed then Inc(AChVC);
    for I := 0 to F.FoldersCount - 1 do
      CountItems(F.Folders[I], AFC, AVC, AChFC, AChVC);
  end;

begin
  if not Assigned(st_dlgfolderprop) then
    st_dlgfolderprop := Tst_dlgfolderprop.Create(Application);

  with st_dlgfolderprop do
  begin
    lName.Caption := FName;
    if FParent <> nil then
      eLocation.Text := Copy(Path, 1, Length(Path) - Length(FName))
    else
      eLocation.Text := '';
    FC := 0;
    VC := 0;
    CountItems(Self, FC, VC, ChFC, ChVC);
    lFolders.Caption := IntToStr(FC) + ' (' + IntToStr(ChFC) + ')';
    lValues.Caption := IntToStr(VC) + ' (' + IntToStr(ChVC) + ')';
    C := DataSize;
    lSize.Caption := FloatToStrF(C, ffNumber, 10, 0) + ' байт';
    lModified.Caption := FormatDateTime('dd.mm.yy hh:nn:ss', Modified);;
  end;

  st_dlgfolderprop.ShowModal;
end;

function TgsStorageFolder.DeleteValue(const AValueName: String): Boolean;
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
  begin
    V.Drop;
    Result := True;
  end else
    Result := False;
end;

function TgsStorageFolder.FolderExists(const AFolderName: String): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FoldersCount - 1 downto 0 do
    if AnsiCompareText(Folders[I].Name, AFolderName) = 0 then
    begin
      Result := True;
      break;
    end;
end;

procedure TgsStorageFolder.ReadStream(const AValueName: String; S: TStream);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V is TgsStreamValue then
  begin
    (V as TgsStreamValue).SaveDataToStream(S);
  end;
end;

procedure TgsStorageFolder.WriteStream(const AValueName: String;
  S: TStream);
var
  V: TgsStorageValue;
begin
  V := ValueByName(AValueName);
  if V <> nil then
  begin
    if V is TgsStreamValue then
    begin
      (V as TgsStreamValue).LoadDataFromStream(S);
    end;
  end else
  begin
    V := TgsStreamValue.Create(Self, AValueName);
    (V as TgsStreamValue).LoadDataFromStream(S);
  end;
end;

function TgsStorageFolder.FindFolder(F: TgsStorageFolder;
  const GoSubFolders: Boolean = True): Boolean;
var
  I: Integer;
begin
  Result := F = Self;

  if Result then
    exit;

  for I := 0 to FoldersCount - 1 do
    if GoSubFolders then
    begin
      if Folders[I].FindFolder(F) then
      begin
        Result := True;
        exit;
      end;
    end else
    if Folders[I] = F then
    begin
      Result := True;
      exit;
    end
end;

{function TgsStorageFolder.MoveFolder(NewParent: TgsStorageFolder): Boolean;
begin
  Result := (NewParent is TgsStorageFolder) and (not FindFolder(NewParent));
  if Result then
    NewParent.AddFolder(Self);
end;}

procedure TgsStorageFolder.ExtractFolder(F: TgsStorageFolder);
begin
  RemoveChildren(F);
end;

procedure TgsStorageFolder.AddFolder(F: TgsStorageFolder);
begin
  if not (F is TgsStorageFolder) then
    raise EgsStorageError.Create('Invalid folder specified');
  if FindFolder(F) then
    raise EgsStorageError.Create('Duplicate folder');
  if F.Parent <> nil then
    F.Parent.RemoveChildren(F);
  F.FParent := Self;
  AddChildren(F);
end;

procedure TgsStorageFolder.WriteValue(AValue: TgsStorageValue);
var
  V: TgsStorageValue;
begin
  if Assigned(AValue) then
  begin
    if ValueByName(AValue.Name) <> nil then
      raise EgsStorageError.Create('Duplicate value name');
    V := TgsStorageValueClass(AValue.ClassType).Create(Self, AValue.Name, AValue.ID);
    V.AsString := AValue.AsString;
  end;
end;

procedure TgsStorageFolder.SaveToStream2(S: TStringStream);
var
  I: Integer;
begin
  S.WriteString(#13#10);
  S.WriteString('[' + Path + ']'#13#10);

  for I := 0 to ValuesCount - 1 do
    if Values[I] <> nil then
      Values[I].SaveToStream2(S);

  for I := 0 to FoldersCount - 1 do
    if Folders[I] <> nil then
      Folders[I].SaveToStream2(S);
end;

function TgsStorageFolder.Find(AList: TStringList; const ASearchString: String;
  const ASearchOptions: TgstSearchOptions; const DateFrom: TDate = 0;
  const DateTo: TDate = 0): Boolean;
var
  I, C: Integer;

  procedure AddElement;
  begin
    if AList.IndexOF(Path) = -1 then
      AList.AddObject(Path, Self);
  end;

begin
  C := AList.Count;

  if (gstsoFolder in ASearchOptions) and
    DateIntvlCheck(Modified, DateFrom, DateTo) and
    (((ASearchString = '') and ((DateFrom + DateTo) <> 0)) or
      ((ASearchString > '')
        and (Pos(AnsiUpperCase(ASearchString), AnsiUpperCase(Name)) > 0))) then
  begin
    AddElement;
  end;

  for I := 0 to FoldersCount - 1 do
    Folders[I].Find(AList, ASearchString, ASearchOptions, DateFrom, DateTo);

  if (gstsoValue in ASearchOptions) or (gstsoData in ASearchOptions) then
  begin
    for I := 0 to ValuesCount - 1 do
      Values[I].Find(AList, ASearchString, ASearchOptions, DateFrom, DateTo);
  end;

  Result := AList.Count > C;
end;

procedure TgsStorageFolder.LoadFromStream2(S: TStringStream);
var
  ValueName, ValueType: String;
  V: TgsStorageValue;
  A, P: PChar;
  L: Integer;
  Ch: Char;
begin
  while S.Position < S.Size do
  begin
    repeat
      L := S.Read(Ch, 1);
    until (L = 0) or (not (Ch in [#13, #10]));

    if (L = 1) and (Ch = '[') then
    begin
      // дошли до начала следующей папки
      S.Seek(-1, soFromCurrent);
      break;
    end;

    ValueName := '';
    while (Ch <> '=') and (L > 0) do
    begin
      ValueName := ValueName + Ch;
      L := S.Read(Ch, 1);
    end;

    ValueType := '';
    L := S.Read(Ch, 1);
    while (Ch <> ':') and (L > 0) do
    begin
      ValueType := ValueType + Ch;
      L := S.Read(Ch, 1);
    end;

    A := StrNew(PChar(ValueName));
    P := A;
    try
      ValueName := AnsiExtractQuotedStr(A, '"');
    finally
      StrDispose(P);
    end;

    V := ValueByName(ValueName);

    if V = nil then
    begin
      if ValueType = 'I' then
        V := TgsIntegerValue.Create(Self, ValueName)
      else if ValueType = 'S' then
        V := TgsStringValue.Create(Self, ValueName)
      else if ValueType = 'D' then
        V := TgsDateTimeValue.Create(Self, ValueName)
      else if ValueType = 'B' then
        V := TgsBooleanValue.Create(Self, ValueName)
      else if ValueType = 'C' then
        V := TgsCurrencyValue.Create(Self, ValueName)
      else if ValueType = 'St' then
        V := TgsStreamValue.Create(Self, ValueName);
    end;

    if V <> nil then
      V.LoadFromStream2(S);
  end;
end;

procedure TgsStorageFolder.AddValueFromStream(AValueName: String; S: TStream);
begin
  DeleteValue(AValueName);
  TgsStorageValue.CreateFromStream(Self, S);
end;

class procedure TgsStorageFolder.SkipValueInStream(S: TStream);
var
  K: Integer;
begin
  S.ReadBuffer(K, SizeOf(K));
  case K of
    svtInteger: TgsIntegerValue.SkipInStream(S);
    svtString: TgsStringValue.SkipInStream(S);
    svtStream: TgsStreamValue.SkipInStream(S);
    svtBoolean: TgsBooleanValue.SkipInStream(S);
    svtDateTime: TgsDateTimeValue.SkipInStream(S);
    svtCurrency: TgsCurrencyValue.SkipInStream(S);
  else
    raise EgsStorageError.Create('Invalid value type');
  end;
end;

procedure TgsStorageFolder.AddChildren(SI: TgsStorageItem);
begin
  if SI is TgsStorageFolder then
  begin
    if FFolders = nil then
      FFolders := TObjectList.Create;
    FFolders.Add(SI);
    SI.FParent := Self;
  end
  else if SI is TgsStorageValue then
  begin
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(SI);
    SI.FParent := Self;
  end;
end;

procedure TgsStorageFolder.RemoveChildren(SI: TgsStorageItem);
begin
  if not FDestroying then
  begin
    if (SI is TgsStorageFolder) and (SI.FParent = Self) then
    begin
      if FFolders <> nil then
        FFolders.Extract(SI);
      SI.FParent := nil;
    end else if (SI is TgsStorageValue) and (SI.Parent = Self) then
    begin
      if FValues <> nil then
        FValues.Extract(SI);
      SI.FParent := nil;
    end;
  end;
end;

class function TgsStorageFolder.GetTypeName: Char;
begin
  Result := cStorageFolder;
end;

{ TgsStorage }

procedure TgsStorage.BuildTreeView(N: TTreeNode; const L: TList = nil);
var
  S: PString;
begin
  if L = nil then
    N.Data := FRootFolder
  else begin
    New(S);
    S^ := '\';
    L.Add(S);
    N.Data := S;
  end;
  N.ImageIndex := 0;
  FRootFolder.BuildTreeView(N, L);
end;

procedure TgsStorage.Clear;
begin
  FRootFolder.Clear;
end;

constructor TgsStorage.Create;
begin
  inherited Create;

  FRootFolder := TgsRootFolder.Create(nil, UpdateName);
  FRootFolder.FStorage := Self;

  {$IFDEF DEBUG}
  FOpenFolders := TStringList.Create;
  {$ENDIF}
end;

destructor TgsStorage.Destroy;
begin
  FreeAndNil(FRootFolder);
  {$IFDEF DEBUG}
  if FOpenFolders.Count > 0 then
    MessageBox(0,
      PChar('Сховішча: ' + ClassName + #13#10#13#10 +
      'Не зачынена папак: ' + IntToStr(FOpenFolders.Count) + #13#10#13#10 +
      FOpenFolders.CommaText),
      'Увага!',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  FOpenFolders.Free;
  {$ENDIF}
  inherited;
end;

procedure TgsStorage.BeforeOpenFolder;
begin
  //
end;

procedure TgsStorage.AfterCloseFolder;
begin
  //
end;

function TgsStorage.FolderExists(const APath: String;
  const SyncWithDatabase: Boolean = True): Boolean;
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, False, SyncWithDatabase);
  if F <> nil then
  begin
    CloseFolder(F, SyncWithDatabase);
    Result := True;
  end else
    Result := False;
end;

function TgsStorage.GetDataString: String;
var
  SS: TStringStream;
begin
  SS := TStringStream.Create('');
  try
    SaveToStream(SS);
    Result := SS.DataString;
  finally
    SS.Free;
  end;
end;

procedure TgsStorage.LoadComponent(C: TComponent;
  M: TLoadFromStreamMethod; const Context: String = '';
  const ALoadAdmin: Boolean = True);

  procedure Internal(F: TgsStorageFolder);
  var
    V: TgsStorageValue;
    S: TStream;
  begin
    V := F.ValueByName('data');
    if Assigned(V) and (V is TgsStreamValue) then
    begin
      S := TMemoryStream.Create;
      try
        (V as TgsStreamValue).SaveDataToStream(S);
        M(S);
      finally
        S.Free;
      end;
    end;
  end;

var
  F: TgsStorageFolder;
  Path: String;
  {$IFDEF GEDEMIN}
  OwnerForm: TComponent;
  {$ENDIF}
begin
  if Assigned(C) and Assigned(M) then
  begin
    Path := BuildComponentPath(C, Context);
    F := OpenFolder(Path, False);

    {$IFDEF GEDEMIN}
    if ALoadAdmin then
    begin
      OwnerForm := C.Owner;
      while (OwnerForm <> nil)
        and (not (OwnerForm is Tgdc_frmG)) do
      begin
        OwnerForm := OwnerForm.Owner;
      end;

      if OwnerForm is Tgdc_frmG then
      begin
        if (GlobalStorage <> nil) and
          GlobalStorage.ValueExists('Options\DNSS', BuildComponentPath(OwnerForm), False) then
        begin
          CloseFolder(F, False);
          F := nil;
        end;
      end;
    end;  
    {$ENDIF}

    if Assigned(F) then
    begin
      try
        Internal(F);
      finally
        CloseFolder(F, False);
      end
    end
    {$IFDEF GEDEMIN}
    else if ALoadAdmin then
    begin
      if (Self = UserStorage) and (UserStorage.ObjectKey <> ADMIN_KEY) then
      begin
        if AdminStorage = nil then
        begin
          AdminStorage := TgsUserStorage.Create;
          AdminStorage.ObjectKey := ADMIN_KEY;
        end;

        F := AdminStorage.OpenFolder(Path, False, False);
        if Assigned(F) then
        begin
          try
            Internal(F);
          finally
            AdminStorage.CloseFolder(F, False);
          end;
        end;
      end;
    end;
    {$ENDIF}
  end;
end;

procedure TgsStorage.LoadFromFile(const AFileName: String;
  const AFileFormat: TgsStorageFileFormat);
var
  FS: TFileStream;
  SS: TStringStream;
begin
  if AFileFormat = sffText then
  begin
    SS := TStringStream.Create('');
    try
      FS := TFileStream.Create(AFileName, fmOpenRead);
      try
        SS.CopyFrom(FS, 0);
        SS.Position := 0;
        LoadFromStream2(SS);
      finally
        FS.Free;
      end;
    finally
      SS.Free;
    end;
  end
  else
  begin
    FS := TFileStream.Create(AFileName, fmOpenRead);
    try
      LoadFromStream(FS);
    finally
      FS.Free;
    end;
  end;
end;

procedure TgsStorage.LoadFromStream(S: TStream);
var
  H: TgsStorageHeader;
  DS: TZDecompressionStream;
begin
  Clear;

  if not Assigned(S) then
    exit;

  S.ReadBuffer(H, SizeOf(H));

  if (H.Signature <> shSignature) or (H.Version <> shVersion) then
    raise EgsStorageFolderError.Create('Invalid stream format');

  if H.CompressionType = shNoCompression then
  begin
    FRootFolder.LoadFromStream(S);
  end
  else if H.CompressionType = shZLibCompression then
  begin
    DS := TZDecompressionStream.Create(S);
    try
      FRootFolder.LoadFromStream(DS);
    finally
      DS.Free;
    end;
  end;
end;

procedure TgsStorage.CloseFolder(gsStorageFolder: TgsStorageFolder; const SyncWithDatabase: Boolean = True);
begin
  if SyncWithDatabase then
    AfterCloseFolder;

  {$IFDEF DEBUG}
  if gsStorageFolder <> nil then
    FOpenFolders.Delete(FOpenFolders.IndexOfObject(gsStorageFolder));
  {$ENDIF}
end;

function TgsStorage.OpenFolder(const APath: String; const CanCreate: Boolean = False;
  const SyncWithDatabase: Boolean = True): TgsStorageFolder;
begin
  if SyncWithDatabase then
    BeforeOpenFolder;
  Result := FRootFolder.OpenFolder(APath, CanCreate);

  {$IFDEF DEBUG}
  if Result <> nil then
    FOpenFolders.AddObject(Result.Path, Result);
  {$ENDIF}
end;

function TgsStorage.ReadBoolean(const APath, AValue: String;
  const Default: Boolean = True; const Sync: Boolean = True): Boolean;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Result := Default;
  F := OpenFolder(APath, False, Sync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if Assigned(V) then
        Result := V.AsBoolean;
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

function TgsStorage.ReadDateTime(const APath, AValue: String;
  const Default: TDateTime; const Sync: Boolean = True): TDateTime;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Result := Default;
  F := OpenFolder(APath, False, Sync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if Assigned(V) then
        Result := V.AsDateTime;
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

function TgsStorage.ReadInteger(const APath, AValue: String;
  const Default: Integer = 0; const Sync: Boolean = True): Integer;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Result := Default;
  F := OpenFolder(APath, False, Sync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if Assigned(V) then
        Result := V.AsInteger;
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

function TgsStorage.ReadCurrency(const APath, AValue: String;
  const Default: Currency = 0; const Sync: Boolean = True): Currency;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Result := Default;
  F := OpenFolder(APath, False, Sync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if Assigned(V) then
        Result := V.AsCurrency;
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

function TgsStorage.ReadString(const APath, AValue: String;
  const Default: String = ''; const Sync: Boolean = True): String;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Result := Default;
  F := OpenFolder(APath, False, Sync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if Assigned(V) then
        Result := V.AsString;
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

function TgsStorage.SaveComponent(C: TComponent; M: TSaveToStreamMethod; const Context: String = ''): String;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  SNew: TStringStream;
begin
  if Assigned(C) and Assigned(M) then
  begin
    Result := BuildComponentPath(C, Context);
    SNew := TStringStream.Create('');
    try
      M(SNew);

      F := OpenFolder(Result, True, False);
      if Assigned(F) then
      try
        V := F.ValueByName('data');
        if V is TgsStreamValue then
        begin
          if V.AsString = SNew.DataString then
            exit;
        end;
      finally
        CloseFolder(F, False);
      end;

      F := OpenFolder(Result, True);
      if Assigned(F) then
      try
        if not F.ValueExists('data') then
          F.WriteStream('data', nil);
        V := F.ValueByName('data');
        if V is TgsStreamValue then
          V.AsString := SNew.DataString;
      finally
        CloseFolder(F);
      end;
    finally
      SNew.Free;
    end;
  end else
    Result := '';
end;

procedure TgsStorage.SaveToFile(const AFileName: String;
  const AFileFormat: TgsStorageFileFormat);
var
  FS: TFileStream;
  SS: TStringStream;
begin
  if AFileFormat = sffText then
  begin
    SS := TStringStream.Create('');
    try
      SaveToStream2(SS);
      FS := TFileStream.Create(AFileName, fmCreate);
      try
        FS.CopyFrom(SS, 0);
      finally
        FS.Free;
      end;
    finally
      SS.Free;
    end;
  end else
  begin
    FS := TFileStream.Create(AFileName, fmCreate);
    try
      SaveToStream(FS);
    finally
      FS.Free;
    end;
  end;
end;

procedure TgsStorage.SaveToStream(S: TStream);
var
  H: TgsStorageHeader;
  CS: TZCompressionStream;
  {$IFDEF DEBUG}
  T: Cardinal;
  {$ENDIF}
begin
  H.Signature := shSignature;
  H.Version := shVersion;

  {if FDataCompression = sdcNone then
  begin
    H.CompressionType := 0;
    S.WriteBuffer(H, SizeOf(H));
    FRootFolder.SaveToStream(S);
  end
  else if FDataCompression = sdcZLib then
  begin}
    H.CompressionType := 1;
    S.WriteBuffer(H, SizeOf(H));
    {$IFDEF DEBUG}
    T := GetTickCount;
    {$ENDIF}
    CS := TZCompressionStream.Create(S);
    try
      FRootFolder.SaveToStream(CS);
    finally
      CS.Free;
    end;
    {$IFDEF DEBUG}
    T := GetTickCount - T;
    if T > 0 then
      OutputDebugString(PChar('Compress storage ' + Self.ClassName + ': ' + IntToStr(T)));
    {$ENDIF}
  {end;}
end;

procedure TgsStorage.SaveToStream2(S: TStringStream);
begin
  S.WriteString('Gedemin Storage v.1.0'#13#10);
  FRootFolder.SaveToStream2(S);
end;

procedure TgsStorage.SetDataString(const Value: String);
var
  SS: TStringStream;
begin
  SS := TStringStream.Create(Value);
  try
    try
      LoadFromStream(SS);
    except
      Clear;
    end;
  finally
    SS.Free;
  end;
end;

procedure TgsStorage.WriteInteger(const APath, AValueName: String;
  const AValue: Integer);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, True);
  try
    if Assigned(F) then
      F.WriteInteger(AValueName, AValue);
  finally
    CloseFolder(F);
  end;
end;

procedure TgsStorage.WriteString(const APath, AValueName, AValue: String;
  const Sync: Boolean = True);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, Sync);
  try
    if Assigned(F) then
      F.WriteString(AValueName, AValue);
  finally
    CloseFolder(F, Sync);
  end;
end;

procedure TgsStorage.LoadFromStream2(S: TStringStream);
var
  FolderPath: String;
  F: TgsStorageFolder;
  Ch: Char;
  L: Integer;
begin
  while S.Position < S.Size do
  begin
    repeat
      L := S.Read(Ch, 1);
    until (L = 0) or (Ch = '[');

    if L = 0 then
      exit;

    FolderPath := '';
    L := S.Read(Ch, 1);
    while (Ch <> ']') and (L > 0) do
    begin
      FolderPath := FolderPath + Ch;
      L := S.Read(Ch, 1);
    end;

    try
      F := OpenFolder(FolderPath, True, False);
      try
        if F <> nil then
        begin
          F.LoadFromStream2(S);
        end;
      finally
        CloseFolder(F, False);
      end;

    except
      // если была ошибка -- пропускаем, но не сообщаем пользователю
    end;
  end;
end;

procedure TgsStorage.WriteBoolean(const APath, AValueName: String;
  const AValue: Boolean; const Sync: Boolean = True);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, Sync);
  try
    if Assigned(F) then
    begin
      F.WriteBoolean(AValueName, AValue);
    end;
  finally
    CloseFolder(F, Sync);
  end;
end;

procedure TgsStorage.WriteCurrency(const APath, AValueName: String;
  const AValue: Currency);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, True);
  try
    if Assigned(F) then
    begin
      F.WriteCurrency(AValueName, AValue);
    end;
  finally
    CloseFolder(F);
  end;
end;

procedure TgsStorage.WriteDateTime(const APath, AValueName: String;
  const AValue: TDateTime);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, True);
  try
    if Assigned(F) then
    begin
      F.WriteDateTime(AValueName, AValue);
    end;
  finally
    CloseFolder(F);
  end;
end;

function TgsStorage.ReadStream(const APath, AValue: String;
  S: TStream; const ASync: Boolean = True): Boolean;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Assert(S <> nil, 'Stream is not assigned');
  Result := False;
  F := OpenFolder(APath, False, ASync);
  try
    if Assigned(F) then
    begin
      V := F.ValueByName(AValue);
      if V is TgsStreamValue then
      try
        (V as TgsStreamValue).SaveDataToStream(S);
        Result := True;
      except
      end;
    end;
  finally
    CloseFolder(F, False);
  end;
end;

procedure TgsStorage.WriteStream(const APath, AValueName: String; AValue: TStream);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, AValue <> nil);
  try
    if Assigned(F) then
    begin
      if AValue <> nil then
        F.WriteStream(AValueName, AValue)
      else
        F.DeleteValue(AValueName);  
    end;
  finally
    CloseFolder(F);
  end;
end;

function TgsStorage.ValueExists(const APath, AValue: String;
  const SyncWithDatabase: Boolean = True): Boolean;
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, False, SyncWithDatabase);
  if Assigned(F) then
  begin
    Result := F.ValueByName(AValue) <> nil;
    CloseFolder(F, SyncWithDatabase);
  end else
    Result := False;
end;

function TgsStorage.GetName: String;
begin
  Result := FRootFolder.Name;
end;

function TgsStorage.Find(AList: TStringList; const ASearchString: String;
  const ASearchOptions: TgstSearchOptions; const DateFrom: TDate = 0;
  const DateTo: TDate = 0): Boolean;
begin
  Result := FRootFolder.Find(AList, ASearchString, ASearchOptions, DateFrom, DateTo);
end;

procedure TgsStorage.DeleteFolder(const APath: String;
  const SyncWithDatabase: Boolean);
var
  F: TgsStorageFolder;
begin
  if SyncWithDatabase then
    BeforeOpenFolder;
  F := FRootFolder.OpenFolder(APath, False);
  if F = FRootFolder then
    raise EgsStorageFolderError.Create('Can not delete root folder!');
  if F <> nil then
    F.Drop;
  if SyncWithDatabase then
    AfterCloseFolder;
end;

procedure TgsStorage.DeleteValue(const APath, AValueName: String;
  const SyncWithDatabase: Boolean = True);
var
  F: TgsStorageFolder;
begin
  F := OpenFolder(APath, False, SyncWithDatabase);
  try
    if F <> nil then
      F.DeleteValue(AValueName);
  finally
    CloseFolder(F, SyncWithDatabase);
  end;
end;

function TgsStorage.GetModified: Boolean;

  function Scan(F: TgsStorageFolder): Boolean;
  var
    I: Integer;
  begin
    Result := F.Changed;
    if not Result then
    begin
      for I := 0 to F.FoldersCount - 1 do
      begin
        Result := Scan(F.Folders[I]);
        if Result then exit;
      end;
      for I := 0 to F.ValuesCount - 1 do
      begin
        Result := F.Values[I].Changed;
        if Result then exit;
      end;
    end;
  end;

begin
  Result := Scan(FRootFolder);
end;

function TgsStorage.FindID(const AnID: Integer;
  out SI: TgsStorageItem): Boolean;

  function DoRecurse(F: TgsStorageFolder): Boolean;
  var
    I: Integer;
  begin
    if F.ID = AnID then
    begin
      SI := F;
      Result := True;
    end else
    begin
      for I := 0 to F.FoldersCount - 1 do
      begin
        if DoRecurse(F.Folders[I]) then
        begin
          Result := True;
          exit;
        end;
      end;

      for I := 0 to F.ValuesCount - 1 do
      begin
        if F.Values[I].ID = AnID then
        begin
          SI := F.Values[I];
          Result := True;
          exit;
        end;
      end;

      Result := False;
    end;
  end;

begin
  Result := DoRecurse(FRootFolder);
end;

procedure TgsStorage.DeleteStorageItem(const AnID: Integer);
begin
  //
end;

function TgsStorage.UpdateName(const Tr: TIBTransaction = nil): String;
begin
  Result := 'RootFolder';
end;

{ TgsIBStorage }

procedure TgsIBStorage.SaveToDataBase(const ATr: TIBTransaction = nil);
var
  q, qID: TIBSQL;
  Tr: TIBTransaction;
  CurrID, LimitID, CutOff: Integer;
  Failed: Boolean;

  {$IFDEF DEBUG}
  procedure LogQuery;
  var
    S: String;
  begin
    if q.ParamByName('parent').IsNull then
      exit;

    S := Format(
      'UPDATE OR INSERT INTO gd_storage_data (id, parent, name, data_type, ' +
      ' editorkey) ' +
      'VALUES (%d, %d, ''%s'', ''F'', ' +
      ' %d) ' +
      'MATCHING (id); ', [
        q.ParamByName('id').AsInteger,
        q.ParamByName('parent').AsInteger,
        q.ParamByName('name').AsString,
        IBLogin.ContactKey
      ]);

    LogSL.Add(S);
  end;
  {$ENDIF}


  function GetNextID: Integer;
  begin
    if ATr = nil then
      Result := gdcBaseManager.GetNextID
    else
    begin
      if CurrID < LimitID then
        Inc(CurrID)
      else begin
        if qID = nil then
        begin
          qID := TIBSQL.Create(nil);
          qID.Transaction := Tr;
          qID.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1000) FROM rdb$database';
        end;
        qID.ExecQuery;
        LimitID := qID.Fields[0].AsInteger;
        CurrID := LimitID - 1000 + 1;
        qID.Close;
      end;
      Result := CurrID;
    end;
  end;

  procedure ClearParams;
  begin
    q.ParamByName('str_data').Clear;
    q.ParamByName('int_data').Clear;
    q.ParamByName('datetime_data').Clear;
    q.ParamByName('curr_data').Clear;
    q.ParamByName('blob_data').Clear;
    q.ParamByName('editorkey').AsInteger := IBLogin.ContactKey;
  end;

  procedure DoRecurse(F: TgsStorageFolder);
  var
    I, P, J, FoundID, FoundCount: Integer;
    V: TgsStorageValue;
  begin
    if F.Changed then
    begin
      if F.ID = -1 then
        F.FID := GetNextID;

      q.ParamByName('id').AsInteger := F.ID;
      q.ParamByName('name').AsString := F.Name;
      q.ParamByName('editiondate').AsDateTime := F.Modified;

      if F.Parent <> nil then
      begin
        q.ParamByName('parent').AsInteger := F.Parent.ID;
        q.ParamByName('data_type').AsString := cStorageFolder;
        ClearParams;
      end else
        q.ParamByName('parent').Clear;

      Failed := False;
      CutOff := 5;
      repeat
        try
          {$IFDEF DEBUG}LogQuery;{$ENDIF}
          q.ExecQuery;
          CutOff := 0;
        except
          on E: EIBError do
          begin
            if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
            begin
              if CutOff > 1 then
              begin
                Sleep(500);
                Dec(CutOff);
              end else
              begin
                Failed := True;
                CutOff := 0;
              end;
            end else
            begin
              P := Pos('. ID=', E.Message);
              if P > 0 then
              begin
                J := P + 5;
                while (J <= Length(E.Message)) and (E.Message[J] in ['0'..'9']) do
                  Inc(J);
                FoundID := StrToIntDef(Copy(E.Message, P + 5, J - P - 5), -1);
              end else
                FoundID := -1;
              if FoundID > 0 then
              begin
                F.FID := FoundID;
                q.ParamByName('id').AsInteger := F.ID;
                CutOff := 5;
              end else
              begin
                MessageBox(0,
                  PChar('Ошибка при сохранении папки: ' + F.Path),
                  'Внимание',
                  MB_OK or MB_TASKMODAL or MB_ICONHAND);
                raise;
              end;
            end;
          end;
        end;
      until CutOff = 0;

      if not Failed then
        F.FChanged := False;
    end;

    for I := 0 to F.FoldersCount - 1 do
      DoRecurse(F.Folders[I]);

    for I := 0 to F.ValuesCount - 1 do
    begin
      V := F.Values[I];
      if V.Changed then
      begin
        if V.ID = -1 then
          V.FID := GetNextID;
        ClearParams;
        q.ParamByName('id').AsInteger := V.ID;
        q.ParamByName('parent').AsInteger := F.ID;
        q.ParamByName('name').AsString := V.Name;
        q.ParamByName('editiondate').AsDateTime := V.Modified;
        if V is TgsStringValue then
        begin
          if Length(V.AsString) <= cStorageMaxStrLen then
          begin
            q.ParamByName('data_type').AsString := cStorageString;
            q.ParamByName('str_data').AsString := V.AsString;
          end else
          begin
            q.ParamByName('data_type').AsString := cStorageBLOB;
            q.ParamByName('blob_data').AsString := V.AsString;
          end;
        end
        else if V is TgsIntegerValue then
        begin
          q.ParamByName('data_type').AsString := cStorageInteger;
          q.ParamByName('int_data').AsInteger := V.AsInteger;
        end
        else if V is TgsBooleanValue then
        begin
          q.ParamByName('data_type').AsString := cStorageBoolean;
          q.ParamByName('int_data').AsInteger := V.AsInteger;
        end
        else if V is TgsDateTimeValue then
        begin
          q.ParamByName('data_type').AsString := cStorageDateTime;
          q.ParamByName('datetime_data').AsDateTime := V.AsDateTime;
        end
        else if V is TgsCurrencyValue then
        begin
          q.ParamByName('data_type').AsString := cStorageCurrency;
          q.ParamByName('curr_data').AsCurrency := V.AsCurrency;
        end
        else if V is TgsStreamValue then
        begin
          q.ParamByName('data_type').AsString := cStorageBlob;
          if V.AsString > '' then //!!! Надо по другому делать проверку на пустой БЛОБ
          begin
            TgsStreamValue(V).SaveBLOB(q.Transaction);
            q.ParamByName('blob_data').AsQuad := TgsStreamValue(V).AsQuad;
          end else
            q.ParamByName('blob_data').Clear;
        end;

        Failed := False;
        CutOff := 5;
        FoundCount := 0;
        repeat
          if FoundCount > 1 then
          begin
            raise EgsStorageError.Create('Дублируются наименования элементов хранилища в рамках одного родителя!'#13#10 +
              'Обратитесь к системному администратору!');
          end;

          try
            {$IFDEF DEBUG}LogQuery;{$ENDIF}
            q.ExecQuery;
            CutOff := 0;
          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
              begin
                if CutOff > 1 then
                begin
                  Sleep(500);
                  Dec(CutOff);
                end else
                begin
                  Failed := True;
                  CutOff := 0;
                end;
              end else
              begin
                P := Pos('. ID=', E.Message);
                if P > 0 then
                begin
                  J := P + 5;
                  while (J <= Length(E.Message)) and (E.Message[J] in ['0'..'9']) do
                    Inc(J);
                  FoundID := StrToIntDef(Copy(E.Message, P + 5, J - P - 5), -1);
                end else
                  FoundID := -1;
                if FoundID > 0 then
                begin
                  V.FID := FoundID;
                  q.ParamByName('id').AsInteger := V.ID;

                  if V is TgsStreamValue then
                  begin
                    if V.AsString > '' then
                    begin
                      TgsStreamValue(V).SaveBLOB(q.Transaction);
                      q.ParamByName('blob_data').AsQuad := TgsStreamValue(V).AsQuad;
                    end else
                      q.ParamByName('blob_data').Clear;
                  end;

                  Inc(FoundCount);
                  CutOff := 5;
                end else
                begin
                  raise;
                end;
              end;
            end else
              raise;
          end;
        until CutOff = 0;

        if not Failed then
          V.FChanged := False;
      end;
    end;
  end;

begin
  Assert(IBLogin <> nil);
  Assert(IBLogin.Database <> nil);
  Assert(gdcBaseManager <> nil);

  if (FObjectKey = -1) and (FDataType <> cStorageGlobal) then
    exit;

  if (ATr = nil) and (not IBLogin.Database.Connected) then
    exit;

  if not IsModified then
    exit;  

  if ATr = nil then
    Tr := TIBTransaction.Create(nil)
  else
    Tr := ATr;
  q := TIBSQL.Create(nil);
  qID := nil;
  CurrID := -1;
  LimitID := -1;
  try
    if ATr = nil then
    begin
      Tr.DefaultAction := taRollback;
      Tr.DefaultDatabase := IBLogin.Database;
      Tr.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
      Tr.StartTransaction;
    end;

    FRootFolder.Name := UpdateName(Tr);

    q.Transaction := Tr;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO gd_storage_data (id, parent, name, data_type, ' +
      '  str_data, int_data, datetime_data, curr_data, blob_data, editorkey, editiondate) ' +
      'VALUES (:id, :parent, :name, :data_type, ' +
      '  :str_data, :int_data, :datetime_data, :curr_data, :blob_data, :editorkey, :editiondate) ' +
      'MATCHING (id) ';
    q.Prepare;
    ClearParams;

    q.ParamByName('data_type').AsString := FDataType;
    if FDataType <> cStorageGlobal then
      q.ParamByName('int_data').AsInteger := FObjectKey;

    try
      DoRecurse(FRootFolder);
    except
      on E: Exception do
        Application.ShowException(E);
    end;

    if ATr = nil then
      Tr.Commit;
  finally
    qID.Free;
    q.Free;
    if ATr = nil then
      Tr.Free;
  end;
end;

procedure TgsIBStorage.LoadFromDataBase(const ATr: TIBTransaction = nil);
var
  q: TIBSQL;

  procedure DoRecurse(F: TgsStorageFolder);
  var
    V: TgsStorageValue;
    //RB: Integer;
    Prnt: Integer;
  begin
    F.FID := q.FieldByName('id').AsInteger;
    F.FModified := q.FieldByName('editiondate').AsDateTime;
    //RB := q.FieldByName('rb').AsInteger;
    Prnt := q.FieldByName('id').AsInteger;
    q.Next;

    //while (not q.EOF) and (q.FieldByName('rb').AsInteger <= RB) do
    while (not q.EOF) and (q.FieldByName('parent').AsInteger = Prnt) do
    begin
      if q.FieldByName('data_type').AsString = 'F' then
      begin
        DoRecurse(F.CreateFolder(q.FieldByName('name').AsString));
      end else
      begin
        V := nil;
        case q.FieldByName('data_type').AsString[1] of
        cStorageString:
          begin
            V := TgsStringValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            V.AsString := q.FieldByName('str_data').AsString;
          end;

        cStorageInteger:
          begin
            V := TgsIntegerValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            V.AsInteger := q.FieldByName('int_data').AsInteger;
          end;

        cStorageCurrency:
          begin
            V := TgsCurrencyValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            V.AsCurrency := q.FieldByName('curr_data').AsCurrency;
          end;

        cStorageBoolean:
          begin
            V := TgsBooleanValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            V.AsInteger := q.FieldByName('int_data').AsInteger;
          end;

        cStorageDateTime:
          begin
            V := TgsDateTimeValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            V.AsDateTime := q.FieldByName('datetime_data').AsDateTime;
          end;

        cStorageBlob:
          begin
            V := TgsStreamValue.Create(F, q.FieldByName('name').AsString, q.FieldByName('id').AsInteger);
            if not q.FieldByName('blob_data').IsNull then
              TgsStreamValue(V).AsQUAD := q.FieldByName('blob_data').AsQUAD;
          end;
        end;

        if V <> nil then
          V.FModified := q.FieldByName('editiondate').AsDateTime;

        q.Next;

        if (V <> nil) and (not q.EOF) and (q.FieldByName('parent').AsInteger = V.ID) then
        begin
          MessageBox(0,
            PChar('Ошибка данных хранилища. Обратитесь к системному администратору. ID элемента = ' + q.FieldByName('id').AsString),
            'Ошибка',
            MB_ICONEXCLAMATION or MB_OK or MB_TASKMODAL);
          while (not q.EOF) and (q.FieldByName('parent').AsInteger <> Prnt) do
            q.Next;
        end;
      end;
    end;
  end;

var
  SQL: String;

begin
  Assert(IBLogin <> nil);
  Assert(IBLogin.DataBase <> nil, 'Не подключен DataBase');

  Clear;

  if (FObjectKey = -1) and (FDataType <> cStorageGlobal) then
    exit;

  if (ATr = nil) and (not IBLogin.Database.Connected) then
    exit;

  LockStorage(True);
  q := TIBSQL.Create(nil);
  try
    if FDataType <> cStorageGlobal then
      SQL := 'AND r.int_data = :ID '
    else
      SQL := '';
    if ATr = nil then
      q.Transaction := gdcBaseManager.ReadTransaction
    else
      q.Transaction := ATr;
    q.SQL.Text :=
      'WITH RECURSIVE storage_tree AS ( ' +
      '  SELECT r.* FROM gd_storage_data r ' +
      '    WHERE r.data_type = :DT AND r.parent IS NULL ' + SQL +
      '  UNION ALL ' +
      '  SELECT d.* FROM gd_storage_data d ' +
      '    JOIN storage_tree t ON d.parent = t.id ' +
      ') ' +
      'SELECT * FROM storage_tree ';
      {'SELECT d.id, d.lb, d.rb, d.parent, d.name, d.data_type, d.str_data, ' +
      '  d.int_data, d.datetime_data, d.curr_data, d.blob_data, d.editiondate ' +
      'FROM gd_storage_data d JOIN gd_storage_data r ' +
      '  ON d.lb BETWEEN r.lb AND r.rb AND r.data_type = :DT AND r.parent IS NULL ' + SQL +
      'ORDER BY d.lb';}
    q.ParamByName('DT').AsString := FDataType;
    if FDataType <> cStorageGlobal then
      q.ParamByName('ID').AsInteger := FObjectKey;
    q.ExecQuery;
    FRootFolder.Name := UpdateName(ATr);
    if not q.EOF then
    begin
      FRootFolder.FChanged := False;
      DoRecurse(FRootFolder);
    end;
  finally
    q.Free;
    LockStorage(False);
  end;
end;

procedure TgsIBStorage.DeleteStorageItem(const AnID: Integer);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  CutOff: Integer;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;

    CutOff := 5;
    repeat
      try
        q.SQL.Text := 'DELETE FROM gd_storage_data WHERE id = :ID';
        q.Params[0].AsInteger := AnID;
        q.ExecQuery;
        CutOff := 0;
      except
        on E: EIBError do
        begin
          if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
          begin
            if (CutOff > 1) and Tr.InTransaction then
            begin
              Tr.Rollback;
              Sleep(500);
              Dec(CutOff);
              Tr.StartTransaction;
            end else
              raise;
          end else
            raise;
        end else
          raise;
      end;
    until CutOff = 0;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsIBStorage.SetObjectKey(const Value: Integer);
begin
  if FDataType <> cStorageGlobal then
  begin
    if FObjectKey <> Value then
    try
      SaveToDatabase;
      FObjectKey := Value;
      LoadFromDatabase;
    except
      on E: Exception do
      begin
        MessageBox(0,
          PChar('Ошибка при сохранении/загрузке хранилища: ' + E.Message),
          'Ошибка',
          MB_OK or MB_TASKMODAL or MB_ICONHAND);
        FObjectKey := -1;  
      end;
    end;
  end else
    raise EgsStorageError.Create('Can not set id for global storage');  
end;

constructor TgsIBStorage.Create;
begin
  FDataType := cStorageGlobal;
  FObjectKey := -1;
  inherited;
end;

function TgsIBStorage.UpdateName(const Tr: TIBTransaction = nil): String;
begin
  Result := 'GLOBAL';
end;

procedure TgsIBStorage.SaveToStream(S: TStream);
begin
  SaveToDatabase;
  inherited;
end;

{ TgsUserStorage }

constructor TgsUserStorage.Create;
begin
  inherited;
  DataType := cStorageUser;
end;

function TgsUserStorage.UpdateName(const Tr: TIBTransaction = nil): String;
var
  q: TIBSQL;
begin
  Result := 'USER';

  if (FObjectKey > -1) and (IBLogin <> nil) then
  begin
     if FObjectKey = IBLogin.UserKey then
     begin
       Result := Result + ' - ' + IBLogin.UserName;
     end else
     begin
       q := TIBSQL.Create(nil);
       try
         if Tr = nil then
           q.Transaction := gdcBaseManager.ReadTransaction
         else
           q.Transaction := Tr;
         q.SQL.Text := 'SELECT name FROM gd_user WHERE id = :ID';
         q.ParamByName('ID').AsInteger := FObjectKey;
         q.ExecQuery;
         if not q.EOF then
           Result := Result + ' - ' + q.Fields[0].AsTrimString;
       finally
         q.Free;
       end;
     end;
  end;
end;

{ TgsCompanyStorage }

constructor TgsCompanyStorage.Create;
begin
  inherited;
  DataType := cStorageCompany;
end;

function TgsCompanyStorage.UpdateName(const Tr: TIBTransaction = nil): String;
var
  q: TIBSQL;
begin
  Result := 'COMPANY';

  if (FObjectKey > -1) and (IBLogin <> nil) then
  begin
     if FObjectKey = IBLogin.CompanyKey then
     begin
       Result := Result + ' - ' + IBLogin.CompanyName;
     end else
     begin
       q := TIBSQL.Create(nil);
       try
         if Tr = nil then
           q.Transaction := gdcBaseManager.ReadTransaction
         else
           q.Transaction := Tr;
         q.SQL.Text := 'SELECT name FROM gd_contact WHERE id = :ID';
         q.ParamByName('ID').AsInteger := FObjectKey;
         q.ExecQuery;
         if not q.EOF then
           Result := Result + ' - ' + q.Fields[0].AsTrimString;
       finally
         q.Free;
       end;
     end;
  end;
end;

{ TgsStorageItem }

constructor TgsStorageItem.Create(AParent: TgsStorageItem; const AName: String = '';
  const AnID: Integer = -1);
begin
  inherited Create;
  FID := AnID;
  FParent := AParent;
  if AName = '' then
    FName := GetFreeName
  else begin
    if StorageLoading then
      FName := AName
    else
      FName := CheckForName(AName);
  end;

  // код должен быть синхронизирован с кодом
  // инициализации в методе Clear!
  FChanged := not StorageLoading;
  FModified := Now;
  if FParent <> nil then
    FParent.AddChildren(Self);
end;

destructor TgsStorageItem.Destroy;
begin
  if FParent <> nil then
    FParent.RemoveChildren(Self);
  inherited;
end;

function TgsStorageItem.GetDataSize: Integer;
begin
  Result := 0;
end;

function TgsStorageItem.GetPath: String;
begin
  if Assigned(FParent) then
    Result := FParent.Path + '\' + FName
  else
    Result := '';
end;

function TgsStorageItem.GetStorage: TgsStorage;
begin
  if Parent <> nil then Result := Parent.Storage
    else Result := nil;
end;

procedure TgsStorageItem.LoadFromFile(const AFileName: String;
  const FileFormat: TgsStorageFileFormat);
begin
  //Abstract;
end;

procedure TgsStorageItem.LoadFromStream(S: TStream);
var
  L: Integer;
  Dummy: TDateTime;
begin
  Clear;
  S.ReadBuffer(L, SizeOf(L));
  if L <> StreamSignature then
    raise EgsStorageError.Create('Invalidstream format');
  S.ReadBuffer(L, SizeOf(L));
  SetLength(FName, L);
  if L > 0 then
    S.ReadBuffer(FName[1], L)
  else
    FName := GetFreeName;  
{ TODO :
ради совместимости мы делаем это
позже, когда будет сделано сохранение в текст
надо будет сохранить, выкинуть этот код (старые потоки
перестанут считываться) и загрузить их из текста }
  S.ReadBuffer(FModified, Sizeof(FModified));
  S.ReadBuffer(Dummy, SizeOf(Dummy));
  S.ReadBuffer(Dummy, SizeOf(Dummy));

  FChanged := True;
end;

class procedure TgsStorageItem.SkipInStream(S: TStream);
var
  L: Integer;
  Dummy: TDateTime;
  St: String;
begin
  S.ReadBuffer(L, SizeOf(L));
  if L <> StreamSignature then
    raise EgsStorageError.Create('Invalidstream format');
  S.ReadBuffer(L, SizeOf(L));
  SetLength(St, L);
  if L > 0 then
    S.ReadBuffer(St[1], L);

{ TODO :
ради совместимости мы делаем это
позже, когда будет сделано сохранение в текст
надо будет сохранить, выкинуть этот код (старые потоки
перестанут считываться) и загрузить их из текста }
  S.ReadBuffer(Dummy, Sizeof(Dummy));
  S.ReadBuffer(Dummy, SizeOf(Dummy));
  S.ReadBuffer(Dummy, SizeOf(Dummy));
end;

procedure TgsStorageItem.SaveToFile(const AFileName: String;
  const FileFormat: TgsStorageFileFormat);
var
  S: TStream;
  FS: TFileStream;
begin
  S := nil;
  try
    if FileFormat = sffBinary then
    begin
      S := TMemoryStream.Create;
      SaveToStream(S);
    end else
    begin
      S := TStringStream.Create('');
      SaveToStream2(S as TStringStream);
    end;

    FS := TFileStream.Create(AFileName, fmCreate);
    try
      FS.CopyFrom(S, 0);
    finally
      FS.Free;
    end;
  finally
    if S <> nil then
      S.Free;
  end;
end;

procedure TgsStorageItem.SaveToStream(S: TStream);
var
  L: Integer;
  Dummy: TDateTime;
begin
  L := StreamSignature;
  S.WriteBuffer(L, SizeOf(L));
  L := Length(FName);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(FName[1], L);

{ TODO :
ради совместимости мы делаем это
позже, когда будет сделано сохранение в текст
надо будет сохранить, выкинуть этот код (старые потоки
перестанут считываться) и загрузить их из текста }
  Dummy := 0;
  S.WriteBuffer(FModified, Sizeof(FModified));
  S.WriteBuffer(Dummy, SizeOf(Dummy));
  S.WriteBuffer(Dummy, SizeOf(Dummy));
  (*
  S.WriteBuffer(FCreated, Sizeof(FCreated));
  S.WriteBuffer(FAccessed, SizeOf(FAccessed));
  S.WriteBuffer(FChanged, SizeOf(FChanged));
  *)

  FChanged := False;
end;

procedure TgsStorageItem.SetName(const Value: String);
var
  S: String;
begin
  if Value = '' then
    S := GetFreeName
  else begin
    if StorageLoading then
      S := Value
    else
      S := CheckForName(Value);
  end;
  if FName <> S then
  begin
    FName := S;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
  end;
end;

function TgsStorageItem.GetFreeName: String;
var
  I: Integer;
begin
  I := 0;
  Result := 'noname';
  while (Parent is TgsStorageFolder) and (I < 1000) and
    (TgsStorageFolder(Parent).FolderExists(Result) or TgsStorageFolder(Parent).ValueExists(Result)) do
  begin
    Inc(I);
    Result := 'noname' + IntToStr(I);
  end;
end;

function TgsStorageItem.CheckForName(const AName: String): String;
begin
  Result := Trim(AName);
  if (Result = '') or (Length(Result) > cStorageMaxNameLen) or (Pos('\', Result) > 0) then
    raise EgsStorageError.Create('Invalid name ' + Result);
end;

procedure TgsStorageItem.Drop;
begin
  if (Storage <> nil) and (FID > 0) then
    try
      Storage.DeleteStorageItem(FID);
    except
      on E: Exception do
      begin
        MessageBox(0,
          PChar('Возникла ошибка при попытке удалить элемент хранилища'#13#10'"' +
            Storage.Name + '\' + Path + '" из базы данных: '#13#10#13#10 +
          E.Message),
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      end;
    end;
  Free;  
end;

procedure TgsStorageItem.LoadFromStream2(S: TStringStream);
begin
  raise EAbstractError.Create('TgsStorageItem.LoadFromStream2');
end;

procedure TgsStorageItem.SaveToStream2(S: TStringStream);
begin
  raise EAbstractError.Create('TgsStorageItem.SaveToStream2');
end;

procedure TgsStorageItem.AddChildren(SI: TgsStorageItem);
begin
  raise EAbstractError.Create('TgsStorageItem.AddChildren');
end;

procedure TgsStorageItem.RemoveChildren(SI: TgsStorageItem);
begin
  raise EAbstractError.Create('TgsStorageItem.RemoveChildren');
end;

procedure TgsStorageItem.Clear;
begin
  // код должен быть синхронизирован с кодом
  // инициализации в конструкторе!
  FID := -1;
  FName := GetFreeName;
  FChanged := not StorageLoading;
  FModified := Now;
end;

{ TgsIntegerValue }

procedure TgsIntegerValue.Clear;
begin
  FData := 0;
end;

function TgsIntegerValue.GetAsBoolean: Boolean;
begin
  Result := Boolean(FData);
end;

function TgsIntegerValue.GetAsInteger: Integer;
begin
  Result := FData;
end;

function TgsIntegerValue.GetAsString: String;
begin
  Result := IntToStr(FData);
end;

function TgsIntegerValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + SizeOf(FData);
end;

class function TgsIntegerValue.GetTypeId: Integer;
begin
  Result := svtInteger;
end;

class function TgsIntegerValue.GetTypeName: Char;
begin
  Result := cStorageInteger;
end;

procedure TgsIntegerValue.LoadFromStream(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

class procedure TgsIntegerValue.SkipInStream(S: TStream);
var
  I: Integer;
begin
  inherited;
  S.ReadBuffer(I, SizeOf(I));
end;

procedure TgsIntegerValue.SaveToStream(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

procedure TgsIntegerValue.SetAsBoolean(const Value: Boolean);
begin
  SetAsInteger(iff(Value, 1, 0));
end;

procedure TgsIntegerValue.SetAsInteger(const Value: Integer);
begin
  if Value <> AsInteger then
  begin
    FData := Value;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
  end;
end;

procedure TgsIntegerValue.SetAsString(const Value: String);
begin
  try
    SetAsInteger(StrToInt(Value));
  except
    on E: EConvertError do
      raise EgsStorageError.Create('Invalid typecast');
  end;
end;

{ TgsCurrencyValue }

procedure TgsCurrencyValue.Clear;
begin
  FData := 0;
end;

function TgsCurrencyValue.GetAsCurrency: Currency;
begin
  Result := FData;
end;

function TgsCurrencyValue.GetAsString: String;
begin
  Result := CurrToStr(FData);
end;

function TgsCurrencyValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + SizeOf(FData);
end;

class function TgsCurrencyValue.GetTypeId: Integer;
begin
  Result := svtCurrency;
end;

class function TgsCurrencyValue.GetTypeName: Char;
begin
  Result := cStorageCurrency;
end;

procedure TgsCurrencyValue.LoadFromStream(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.SaveToStream(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.SetAsCurrency(const Value: Currency);
begin
  if Value <> AsCurrency then
  begin
    FData := Value;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
 end;
end;

procedure TgsCurrencyValue.SetAsString(const Value: String);
begin
  try
    SetAsCurrency(StrToCurr(Value));
  except
    on E: EConvertError do
      raise EgsStorageError.Create('Invalid typecast');
  end;
end;

class procedure TgsCurrencyValue.SkipInStream(S: TStream);
var
  C: Currency;
begin
  inherited;
  S.ReadBuffer(C, SizeOf(C));
end;

{ TgsStringValue }

procedure TgsStringValue.Clear;
begin
  FData := '';
end;

function TgsStringValue.GetAsInteger: Integer;
begin
  Result := StrToInt(AsString);
end;

function TgsStringValue.GetAsString: String;
begin
  Result := FData;
end;

function TgsStringValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + Length(FData);
end;

class function TgsStringValue.GetTypeId: Integer;
begin
  Result := svtString;
end;

class function TgsStringValue.GetTypeName: Char;
begin
  Result := cStorageString;
end;

procedure TgsStringValue.LoadFromStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;

  S.ReadBuffer(L, SizeOf(L));

  if L > 0 then
  begin
    SetLength(T, L);
    S.ReadBuffer(T[1], L);
  end else
    T := '';
  AsString := T;
end;

class procedure TgsStringValue.SkipInStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;
  S.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(T, L);
    S.ReadBuffer(T[1], L);
  end;
end;

procedure TgsStringValue.SaveToStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;

  T := AsString;
  L := Length(T);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(T[1], L);
end;

procedure TgsStringValue.SetAsInteger(const Value: Integer);
begin
  AsString := IntToStr(Value);
end;

procedure TgsStringValue.SetAsString(const Value: String);
begin
  if Value <> FData then
  begin
    FData := Value;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
  end;
end;

function TgsStringValue.GetAsBoolean: Boolean;
begin
  Result := AsString <> '0';
end;

procedure TgsStringValue.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    AsString := '1'
  else
    AsString := '0';  
end;

function TgsStringValue.GetAsDateTime: TDateTime;
begin
  Result := StrToDateTime(AsString);
end;

procedure TgsStringValue.SetAsDateTime(const Value: TDateTime);
begin
  AsString := DateTimeToStr(Value);
end;

procedure TgsStringValue.SetAsCurrency(const Value: Currency);
begin
  AsString := CurrToStr(Value);
end;

function TgsStringValue.GetAsCurrency: Currency;
begin
  Result := StrToCurr(AsString);
end;

{ TgsDateTimeValue }

procedure TgsDateTimeValue.Clear;
begin
  //
end;

function TgsDateTimeValue.GetAsDateTime: TDateTime;
begin
  Result := FData;
end;

procedure TgsDateTimeValue.SetAsDateTime(const Value: TDateTime);
begin
  if AsDateTime <> Value then
  begin
    FData := Value;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
  end;
end;

function TgsDateTimeValue.GetAsString: String;
begin
  Result := DateTimeToStr(FData);
end;

procedure TgsDateTimeValue.SetAsString(const Value: String);
begin
  try
    SetAsDateTime(StrToDateTime(Value));
  except
    on E: EConvertError do
      raise EgsStorageError.Create('Invalid typecast');
  end;
end;

function TgsDateTimeValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + SizeOf(FData);
end;

class function TgsDateTimeValue.GetTypeId: Integer;
begin
  Result := svtDateTime;
end;

class function TgsDateTimeValue.GetTypeName: Char;
begin
  Result := cStorageDateTime;
end;

procedure TgsDateTimeValue.LoadFromStream(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

class procedure TgsDateTimeValue.SkipInStream(S: TStream);
var
  D: TDateTime;
begin
  inherited;
  S.ReadBuffer(D, SizeOf(D));
end;

procedure TgsDateTimeValue.SaveToStream(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

{ TgsBooleanValue }

procedure TgsBooleanValue.Clear;
begin
  //
end;

function TgsBooleanValue.GetAsBoolean: Boolean;
begin
  Result := FData;
end;

function TgsBooleanValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + SizeOf(FData);
end;

class function TgsBooleanValue.GetTypeId: Integer;
begin
  Result := svtBoolean;
end;

class function TgsBooleanValue.GetTypeName: Char;
begin
  Result := cStorageBoolean;
end;

procedure TgsBooleanValue.LoadFromStream(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

class procedure TgsBooleanValue.SkipInStream(S: TStream);
var
  B: Boolean;
begin
  inherited;
  S.ReadBuffer(B, SizeOf(B));
end;

procedure TgsBooleanValue.SaveToStream(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

procedure TgsBooleanValue.SetAsBoolean(const Value: Boolean);
begin
  if AsBoolean <> Value then
  begin
    FData := Value;
    FChanged := FChanged or (not StorageLoading);
    FModified := Now;
  end;
end;

function TgsBooleanValue.GetAsString: String;
begin
  if FData then
    Result := '1'
  else
    Result := '0';
end;

procedure TgsBooleanValue.SetAsString(const Value: String);
begin
  SetAsBoolean(Value = '1');
end;

function TgsBooleanValue.GetAsInteger: Integer;
begin
  if FData then Result := 1 else Result := 0;
end;

procedure TgsBooleanValue.SetAsInteger(const Value: Integer);
begin
  SetAsBoolean(Boolean(Value));
end;

function TgsBooleanValue.GetAsCurrency: Currency;
begin
  Result := AsInteger;
end;

procedure TgsBooleanValue.SetAsCurrency(const Value: Currency);
begin
  AsBoolean := Value <> 0;
end;

{ TgsStorageValue }

function TgsStorageValue.CheckForName(const AName: String): String;
begin
  Result := inherited CheckForName(AName);
  while Assigned(FParent) and (FParent as TgsStorageFolder).ValueExists(Result) do
  begin
    if StorageLoading then
      Result := inherited CheckForName(Result + '_')
    else
      raise EgsStorageError.Create('Duplicate value name ' + Result +
        ' in folder ' + FParent.Path);
  end;
end;

class function TgsStorageValue.CreateFromStream(AParent: TgsStorageFolder;
  S: TStream): TgsStorageValue;
var
  L: Integer;
begin
  Result := nil;
  S.ReadBuffer(L, SizeOf(L));
  case L of
    svtInteger: Result := TgsIntegerValue.Create(AParent);
    svtString: Result := TgsStringValue.Create(AParent);
    svtStream: Result := TgsStreamValue.Create(AParent);
    svtBoolean: Result := TgsBooleanValue.Create(AParent);
    svtDateTime: Result := TgsDateTimeValue.Create(AParent);
    svtCurrency: Result := TgsCurrencyValue.Create(AParent);
  else
    exit;
  end;
  Result.LoadFromStream(S);
end;

function TgsStorageValue.GetAsBoolean: Boolean;
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsInteger: Integer;
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsCurrency: Currency;
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsDateTime: TDateTime;
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsCurrency(const Value: Currency);
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsString: String;
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

procedure TgsStorageValue.LoadFromStream;
begin
  //...
  inherited;
end;

procedure TgsStorageValue.LoadFromStream2(S: TStringStream);
var
  Value: String;
  A, P: PChar;
  Ch: Char;
  L: Integer;
  InQuote: Boolean;
begin
  InQuote := False;
  Value := '';
  L := S.Read(Ch, 1);
  while (L > 0) and (InQuote or (Ch = '"')) do
  begin
    if Ch = '"' then
      InQuote := not InQuote;
    Value := Value + Ch;
    L := S.Read(Ch, 1);
  end;

  A := StrNew(PChar(Value));
  P := A;
  try
    AsString := AnsiExtractQuotedStr(A, '"');
  finally
    StrDispose(P);
  end;
end;

procedure TgsStorageValue.SaveToStream(S: TStream);
var
  L: Integer;
begin
  L := GetTypeID;
  S.WriteBuffer(L, SizeOf(L));
  inherited;
end;

procedure TgsStorageValue.SaveToStream2(S: TStringStream);
begin
  S.WriteString(Format('%s=%s:%s'#13#10, [AnsiQuotedStr(Name, '"'),
    GetTypeName, AnsiQuotedStr(AsString, '"')]));
end;

procedure TgsStorageValue.SetAsBoolean(const Value: Boolean);
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsDateTime(const Value: TDateTime);
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsInteger(const Value: Integer);
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsString(const Value: String);
begin
  raise EgsStorageTypeCastError.Create('Invalid typecast');
end;

function TgsStorageValue.Find(AList: TStringList; const ASearchString: String;
  const ASearchOptions: TgstSearchOptions; const DateFrom: TDate = 0;
  const DateTo: TDate = 0): Boolean;

  procedure AddElement;
  begin
    if AList.IndexOF(Path) = -1 then
      AList.AddObject(Path, Self);
    Result := True;
  end;

begin
  Result := False;

  if (gstsoValue in ASearchOptions) and
     DateIntvlCheck(Modified, DateFrom, DateTo) and
     (((ASearchString = '') and ((DateFrom + DateTo) <> 0)) or
       ((ASearchString > '')
         and (Pos(AnsiUpperCase(ASearchString), AnsiUpperCase(Name)) > 0))) then
    AddElement
  else
  begin
    if (gstsoData in ASearchOptions) and
      DateIntvlCheck(Modified, DateFrom, DateTo) and
     (((ASearchString = '') and ((DateFrom + DateTo) <> 0)) or
       ((ASearchString > '')
         and (Pos(AnsiUpperCase(ASearchString), AnsiUpperCase(AsString)) > 0))) then
      AddElement;
  end;
end;

function TgsStorageValue.ShowEditValueDialog: TModalResult;
var
  F: Boolean;
  OldName: String;
begin
  if not Assigned(st_dlgeditvalue) then
    st_dlgeditvalue := Tst_dlgeditvalue.Create(Application);

  with st_dlgeditvalue do
  begin
    OldName := Self.Name;
     edName.Text := OldName;
    edValue.Text := AsString;
    edID.Text := IntToStr(ID);

    F := False;
    repeat
      Result := st_dlgeditvalue.ShowModal;

      if Result = mrOk then
      try
        if OldName <> edName.Text then
        begin
          if (FParent as TgsStorageFolder).ValueExists(edName.Text) then
          begin
            MessageBox(0,
              'Переменная с таким именем уже существует.',
              'Внимание',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
            continue;
          end else
          begin
            Self.Name := edName.Text;
            OldName := Self.Name;
          end;
        end;

        F := True;
        AsString := edValue.Text;
      except
        on E: EgsStorageError do
        begin
          F := False;
          MessageBox(0,
            'Неверно введено значение переменной. Повторите ввод.',
            'Ошибка!',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end;
      end else
        F := True;
    until F;
  end;
end;

class procedure TgsStorageValue.SkipInStream(S: TStream);
begin
  inherited;
end;

{ TgsStreamValue }

procedure TgsStreamValue.Clear;
begin
  FData := '';
end;

function TgsStreamValue.GetAsString: String;
var
  bs: TIBBlobStream;
  Qry: TIBSQL;

  procedure ReadBLOB;
  begin
    SetLength(FData, bs.Size);
    if bs.Size > 0 then
      bs.ReadBuffer(FData[1], bs.Size);
  end;

begin
  if (not FLoaded) and (Int64(FQUAD) <> 0) then
  begin
    bs := TIBBlobStream.Create;
    try
      bs.Mode := bmRead;
      bs.Database := gdcBaseManager.Database;
      bs.Transaction := gdcBaseManager.ReadTransaction;
      bs.BlobID := FQUAD;
      try
        ReadBLOB;
      except
        on E: EIBError do
        begin
          if E.IBErrorCode <> isc_random then
            raise;

          {
            Если данный БЛОБ обновили из другого конекта, то мы должны перечитать с
            сервера его ИД.
          }

          Qry := TIBSQL.Create(nil);
          Qry.Transaction := gdcBaseManager.ReadTransaction;
          Qry.SQL.Text := 'SELECT blob_data FROM gd_storage_data WHERE id = :ID';
          Qry.ParamByName('id').AsInteger := FID;
          Qry.ExecQuery;

          if Qry.EOF then
          begin
            Qry.Free;
            raise;
          end;

          FQUAD := Qry.Fields[0].AsQUAD;
          bs.BlobID := FQUAD;

          Qry.Free;

          ReadBLOB;
        end;
      end;
      FLoaded := True;
    finally
      bs.Free;
    end;
  end;

  Result := FData;
end;

function TgsStreamValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + Length(FData);
end;

class function TgsStreamValue.GetTypeId: Integer;
begin
  Result := svtStream;
end;

class function TgsStreamValue.GetTypeName: Char;
begin
  Result := cStorageBlob;
end;

procedure TgsStreamValue.LoadDataFromStream(S: TStream);
var
  T: String;
begin
  if Assigned(S) and (S.Size > 0) then
  begin
    S.Position := 0;
    SetLength(T, S.Size);
    S.ReadBuffer(T[1], S.Size);
    AsString := T;
  end else
    AsString := '';
end;

procedure TgsStreamValue.LoadFromStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;
  S.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(T, L);
    S.ReadBuffer(T[1], L);
    AsString := T;
  end;
end;

class procedure TgsStreamValue.SkipInStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;
  S.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(T, L);
    S.ReadBuffer(T[1], L);
  end;
end;

procedure TgsStreamValue.LoadFromStream2(S: TStringStream);
var
  TempBuffer: String;

  function ReadUntilEOL(S: TStringStream): String;
  var
    Ch: Char;
    P, L: Integer;
  begin
    P := S.Position;

    while S.Position < S.Size do
    begin
      S.ReadBuffer(Ch, 1);
      if Ch in [#13, #10] then
      begin
        S.Position := S.Position - 1;
        break;
      end;
    end;

    L := S.Position - P;

    if L = 0 then
      Result := ''
    else begin
      S.Position := P;
      Result := S.ReadString(L);

      if Result[1] <> ' ' then
      begin
        S.Position := P;
        Result := '';
        exit;
      end;
    end;

    while S.Position < S.Size do
    begin
      S.ReadBuffer(Ch, 1);
      if not (Ch in [#13, #10]) then
      begin
        S.Position := S.Position - 1;
        break;
      end;
    end;
  end;

  procedure AddData(const Str: String);
  var
    ByteStr: String;
    I: Integer;
  begin
    ByteStr := '';
    for I := 1 to Length(Str) do
      if Str[I] <> ' ' then
      begin
        ByteStr := ByteStr + Str[I];
        if Length(ByteStr) = 2 then
        begin
          TempBuffer := TempBuffer + HexToAnsiChar(ByteStr);
          ByteStr := '';
        end;
      end;
  end;

var
  Str: String;

begin
  FData := '';
  TempBuffer := '';
  Str := ReadUntilEOL(S);
  repeat
    Str := ReadUntilEOL(S);
    AddData(Str);
  until (Str = '');
  AsString := TempBuffer;
end;

procedure TgsStreamValue.SaveDataToStream(S: TStream);
var
  T: String;
begin
  if Assigned(S) then
  begin
    S.Size := 0;
    T := AsString;
    if Length(T) > 0 then
    begin
      S.WriteBuffer(T[1], Length(T));
      S.Position := 0;
    end;  
  end;
end;

procedure TgsStreamValue.SaveToStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;
  T := AsString;
  L := Length(T);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(T[1], L);
end;

procedure TgsStreamValue.SaveToStream2(S: TStringStream);
const
  HexInRow = 16;
var
  I: Integer;
  T: String;
  B, C: PChar;
  Size: Integer;
begin
  S.WriteString(Format('%s=%s:'#13#10, [AnsiQuotedStr(Name, '"'),
    GetTypeName]));

  T := AsString;
  Size := Length(T);
  Size := Size * 3 + ((Size div HexInRow) + 1) * (2 + 4) + 32;
  GetMem(B, Size);
  try
    C := B;
    C[0] := #0;
    for I := 1 to Length(T) do
    begin
      if I mod HexInRow = 1 then
        C := StrCat(C, '    ') + StrLen(C);
      C := StrCat(C, PChar(AnsiCharToHex(T[I]) + ' ')) + StrLen(C);
      if I mod HexInRow = 0 then
        C := StrCat(C, #13#10) + StrLen(C);
    end;
    StrCat(C, #13#10);
    S.WriteString(B);
  finally
    FreeMem(B, Size);
  end;
end;

procedure TgsStreamValue.SetAsString(const Value: String);
begin
  FData := Value;
  FLoaded := True;
  FChanged := FChanged or (not StorageLoading);
  FModified := Now;
end;

{ TgsRootFolder ------------------------------------------}

procedure TgsRootFolder.Drop;
begin
  raise EgsStorageError.Create('Can not drop a root folder');
end;

function TgsRootFolder.GetStorage: TgsStorage;
begin
  Result := FStorage;
end;

procedure TgsStreamValue.SaveBLOB(Tr: TIBTransaction);
var
  bs: TIBBlobStream;
  //Qry: TIBSQL;

  procedure WriteBLOB;
  begin
    if Length(FData) > 0 then
      bs.WriteBuffer(FData[1], Length(FData))
    else
      bs.Truncate;
    bs.Finalize;
    FQuad := bs.BlobID;
  end;

begin
  if FChanged then
  begin
    bs := TIBBlobStream.Create;
    try
      bs.Mode := bmWrite;
      bs.Database := Tr.DefaultDatabase;
      bs.Transaction := Tr;
      {if Int64(FQUAD) <> 0 then
        bs.BlobID := FQUAD;}
      try
        WriteBLOB;
      except
        on E: EIBError do
        begin
          raise;
          (*if (E.IBErrorCode <> isc_random) or (Int64(FQUAD) = 0) or (FID <= 0) then
            raise;

          {
            Если данный БЛОБ обновили из другого конекта, то мы должны перечитать с
            сервера его ИД.
          }

          Qry := TIBSQL.Create(nil);
          Qry.Transaction := Tr;
          Qry.SQL.Text := 'SELECT blob_data FROM gd_storage_data WHERE id = :ID';
          Qry.ParamByName('id').AsInteger := FID;
          Qry.ExecQuery;

          if Qry.EOF then
          begin
            Qry.Free;
            raise;
          end;

          bs.BlobID := Qry.Fields[0].AsQUAD;

          Qry.Free;

          WriteBLOB;*)
        end;
      end;

      FLoaded := True;
    finally
      bs.Free;
    end;
  end;
end;

{ TgsStorageDragObject }

constructor TgsStorageDragObject.Create;
begin
  inherited Create;
  F := AF;
  TN := ATN;
end;

procedure TgsStorageDragObject.Finished(Target: TObject; X, Y: Integer;
  Accepted: Boolean);
begin
  inherited;
  Free;
end;

{ TgsDesktopStorage }

{constructor TgsDesktopStorage.Create;
begin
  inherited;
  DataType := cStorageDesktop;
end;}

{function TgsDesktopStorage.UpdateName(const Tr: TIBTransaction = nil): String;
var
  q: TIBSQL;
begin
  Result := 'DESKTOP';

  if (FObjectKey > -1) and (IBLogin <> nil) then
  begin
     q := TIBSQL.Create(nil);
     try
       if Tr = nil then
         q.Transaction := gdcBaseManager.ReadTransaction
       else
         q.Transaction := Tr;
       q.SQL.Text :=
         'SELECT d.name || '' ('' || u.name || '')'' AS name ' +
         'FROM gd_desktop d JOIN gd_user u ON u.id = d.userkey AND d.id = :ID';
       q.ParamByName('ID').AsInteger := FObjectKey;
       q.ExecQuery;
       if not q.EOF then
         Result := Result + ' - ' + q.Fields[0].AsTrimString;
     finally
       q.Free;
     end;
  end;
end;}

initialization
  StorageLoading := False;
  {$IFDEF DEBUG}
  StorageFolderSearchCounter := 0;
  LogSL := TStringList.Create;
  {$ENDIF}

finalization
  {$IFDEF DEBUG}
  OutputDebugString(PChar('SSC: ' + IntToStr(StorageFolderSearchCounter)));
  LogSL.Free;
  {$ENDIF}
end.
