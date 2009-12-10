
unit gsStorage;

interface

uses
  Classes, Contnrs, SysUtils, Comctrls, Controls, Forms, IBDatabase, IBSQL,
  gd_security, extctrls;

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

  MaxCountCicle      = 50;
  TimerInterval      = 100;

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
    FModified: TDateTime;

    procedure SetName(const Value: String);

  protected
    function GetStorage: TgsStorage; virtual;

    // возвращает строку -- путь к элементу
    function GetPath: String; virtual;
    // возвращает размер элемента (вместе с данными)
    function GetDataSize: Integer; virtual;

    // проверяет имя элемента на допустимость
    procedure CheckForName(const AName: String); virtual; abstract;
    function GetFreeName: String;
    // очищает данные элемента
    procedure Clear; virtual; abstract;

    // считывают и сохраняют в форматированный поток
    // где все данные представлены в текстовом виде
    // формат потока близок к формату текстового
    // файла реестра Виндоуз
    procedure LoadFromStream2(S: TStringStream); virtual; abstract;
    procedure SaveToStream2(S: TStringStream); virtual; abstract;

     // считывают и сохраняют в двоичный неформатированный
    // поток
    procedure LoadFromStream(S: TStream); virtual;
    procedure SaveToStream(S: TStream); virtual;

    procedure LoadFromStream3(S: TStream); virtual;
    procedure SaveToStream3(S: TStream); virtual;

    //Пропускает объект в потоке
    class procedure SkipInStream(S: TStream); virtual;

  public
    constructor Create(AParent: TgsStorageItem); overload; virtual;
    constructor Create(AParent: TgsStorageItem; const AName: String); overload; virtual;

    destructor Destroy; override;

    procedure Assign(AnItem: TgsStorageItem); virtual;

    // ???
    procedure LoadFromFile(const AFileName: String; const FileFormat: TgsStorageFileFormat); virtual;
    // ???
    procedure SaveToFile(const AFileName: String; const FileFormat: TgsStorageFileFormat); virtual;

    // в функцию передается список, строка для поиска и параметры поиска
    // она осуществялет поиск в соответствии с введенной строкой
    // и параметрами и все найденные объекты добавляет в список
    // если что-то было найдено и добавлено в список, возвращается
    // истина, в противном случае -- ложь
    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions;
      const DateFrom: TDate = 0; const DateTo: TDate = 0): Boolean; virtual; abstract;

    function GetStorageName: String; virtual;
    property Name: String read FName write SetName;
    property Parent: TgsStorageItem read FParent;
    property Path: String read GetPath;
    property DataSize: Integer read GetDataSize;
    property Modified: TDateTime read FModified;

    property Storage: TgsStorage read GetStorage;
  end;

  TgsStorageFolder = class(TgsStorageItem)
  private
    function GetFoldersCount: Integer;
    function GetValuesCount: Integer;
    function GetFolders(Index: Integer): TgsStorageFolder;
    function GetValues(Index: Integer): TgsStorageValue;

  protected
    FFolders, FValues: TObjectList;

    function GetDataSize: Integer; override;

    procedure CheckForName(const AName: String); override;

    procedure LoadFromStream2(S: TStringStream); override;
    procedure SaveToStream2(S: TStringStream); override;

  public
    constructor Create(AParent: TgsStorageItem); override;
    destructor Destroy; override;

    procedure Clear; override;

    function OpenFolder(APath: String; const CanCreate: Boolean): TgsStorageFolder;

    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean; override;

    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

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
//    procedure RemoveFolder(F: TgsStorageFolder);
    procedure ExtractFolder(F: TgsStorageFolder);
    function AddFolder(F: TgsStorageFolder): Integer;
    function FolderByName(const AName: String): TgsStorageFolder;
    procedure DropFolder;
    function DeleteValue(const AValueName: String): Boolean;
    function FindFolder(F: TgsStorageFolder; const GoSubFolders: Boolean = True): Boolean;
    function MoveFolder(NewParent: TgsStorageFolder): Boolean;

    procedure ShowPropDialog;

    property Folders[Index: Integer]: TgsStorageFolder read GetFolders;
    property FoldersCount: Integer read GetFoldersCount;

    property Values[Index: Integer]: TgsStorageValue read GetValues;
    property ValuesCount: Integer read GetValuesCount;

    procedure AddValueFromStream(AValueName: String; S: TStream);
    class procedure SkipValueInStream(S: TStream);
  end;

  TgsRootFolder = class(TgsStorageFolder)
  private
    FStorage: TgsStorage;

  protected
    function GetPath: String; override;
    function GetStorage: TgsStorage; override;

  public
    constructor Create(AStorage: TgsStorage); reintroduce;
    function GetStorageName: String; override;

    property Storage: TgsStorage read FStorage;
  end;

  TgsStorageValue = class(TgsStorageItem)
  private
    class function CreateFromStream(AParent: TgsStorageFolder; S: TStream): TgsStorageValue;

  protected
    procedure CheckForName(const AName: String); override;

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
    class function GetTypeName: String; virtual; abstract;
    class function GetStorageValueClass: TgsStorageValueClass; virtual; abstract;
    class function CreateFromStream3(AParent: TgsStorageFolder; S: TStream): TgsStorageValue;

    class procedure SkipInStream(S: TStream); override;

    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean; override;

    function ShowEditValueDialog: TModalResult;
    procedure Assign(AnItem: TgsStorageItem); override;

    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsString: String read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;

    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;
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

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
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

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
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

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
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

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
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

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
  end;

  TgsStreamValue = class(TgsStorageValue)
  private
    FData: String;

  protected
    procedure Clear; override;

    function GetDataSize: Integer; override;

    function GetAsString: String; override;
    procedure SetAsString(const Value: String); override;

    procedure LoadFromStream2(S: TStringStream); override;
    procedure SaveToStream2(S: TStringStream); override;

  public
    procedure LoadFromStream(S: TStream); override;
    procedure SaveToStream(S: TStream); override;

    procedure LoadFromStream3(S: TStream); override;
    procedure SaveToStream3(S: TStream); override;

    class procedure SkipInStream(S: TStream); override;

    procedure LoadDataFromStream(S: TStream);
    procedure SaveDataToStream(S: TStream);

    class function GetTypeId: Integer; override;
    class function GetTypeName: String; override;
    class function GetStorageValueClass: TgsStorageValueClass; override;
  end;

  TgsStorage = class(TObject)
  private
    FRootFolder: TgsRootFolder;
    FDataCompression: TgsStorageDataCompression;
    {$IFDEF DEBUG}
    FOpenFolders: TStringList;
    {$ENDIF}
    FModified: Boolean;
    FLoading: Boolean;

    function GetDataString: String;
    procedure SetDataString(const Value: String);
    function GetName: String;

  protected
    procedure BeforeOpenFolder; virtual;
    procedure AfterCloseFolder; virtual;

  public
    constructor Create(const AName: String); reintroduce; virtual;
    destructor Destroy; override;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    procedure SaveToStream2(S: TStringStream);
    procedure LoadFromStream2(S: TStringStream);

    procedure LoadFromStream3(S: TStream);
    procedure SaveToStream3(S: TStream);

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

    procedure LoadFromDataBase; virtual; abstract;
    procedure SaveToDataBase; virtual; abstract;

    //
    function Find(AList: TStringList; const ASearchString: String;
      const ASearchOptions: TgstSearchOptions; const DateFrom:TDate = 0;
      const DateTo: TDate = 0): Boolean;

    property DataCompression: TgsStorageDataCompression read FDataCompression
      write FDataCompression default DefDataCompression;
    property DataString: String read GetDataString write SetDataString;
    property IsModified: Boolean read FModified write FModified;
    property Name: String read GetName;
    property Loading: Boolean read FLoading;
  end;

  TgsIBStorage = class(TgsStorage)
  private
    FExist: Boolean;
    FLastModified: TDateTime;
    FLastChecked: LongWord;
    FValid: Boolean;

  protected
    FLoadedFromCache: Boolean;

    function GetCacheFileName: String; virtual;

    function LoadFromCache: Boolean;
    procedure SaveToCache;

  public
    constructor Create(const AName: String); override;

    procedure SaveToDataBase; override;
    procedure LoadFromDataBase; override;
  end;

  TgsCompanyStorage = class(TgsIBStorage)
  private
    FCompanyKey: Integer;
    procedure SetCompanyKey(const Value: Integer);

  public
    constructor Create(const AName: String); override;

    procedure SaveToDataBase; override;
    procedure LoadFromDataBase; override;

  published

    property CompanyKey: Integer read FCompanyKey write SetCompanyKey;
  end;

  TgsUserStorage = class(TgsIBStorage)
  private
    {$IFDEF DEBUG } CountSave: Integer;{$ENDIF}
    FUserKey: Integer;
    procedure SetUserKey(const Value: Integer);

  protected
    function GetCacheFileName: String; override;
    procedure BeforeOpenFolder; override;
    procedure AfterCloseFolder; override;

  public
    constructor Create(const AName: String); override;

    procedure SaveToDataBase; override;
    procedure LoadFromDataBase; override;

  published
    property UserKey: Integer read FUserKey write SetUserKey;
  end;

  TgsGlobalStorage = class(TgsIBStorage)
  protected
    function GetCacheFileName: String; override;
    procedure BeforeOpenFolder; override;
    procedure AfterCloseFolder; override;

  public
    procedure SaveToDataBase; override;
    procedure LoadFromDataBase; override;
  end;

  EgsStorageError = class(Exception);
  EgsStorageFolderError = class(EgsStorageError);

  TgsStorageDragObject = class(TDragObject)
  public
    F: TgsStorageFolder;
    TN: TTreeNode;

    constructor Create(AF: TgsStorageFolder; ATN: TTreeNode);
  end;

  function GetScreenRes: Integer;

  function DateIntvlCheck(const CheckedDate, DateFrom, DateTo: TDate): Boolean;

implementation

uses
  JclSysUtils, ZLib, Windows, st_dlgfolderprop_unit, st_dlgeditvalue_unit,
  gsStorage_CompPath, DB, IB, IBErrorCodes, IBBlob, gdcBaseInterface, jclStrings
  {$IFDEF GEDEMIN}
  , gd_directories_const, Storages, gdc_frmG_unit
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$IFDEF DEBUG}
var
  StorageFolderSearchCounter: Integer;
{$ENDIF}

const
  CacheTime = 200;

  GLOBAL_STORAGE_FILE_NAME = 'g%s.gsc';
  USER_STORAGE_FILE_NAME = 'g%s_%s.usc';
  STORAGE_FILE_SIGN = $0caaf745;
  STORAGE_FILE_VER  = $00000001;
  
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

{ TgsStorageFolder }

procedure TgsStorageFolder.BuildTreeView(N: TTreeNode; const L: TList = nil);
var
  I: Integer;
  K: TTreeNode;
  P: Pointer;
  S: PString;
begin
  N.Text := FName + ' [' + IntToStr(GetDataSize) + ']';
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

procedure TgsStorageFolder.CheckForName(const AName: String);
var
  N: String;
begin
  N := Trim(AName);
  if (N = '') or (Assigned(FParent) and (FParent as TgsStorageFolder).FolderExists(N)) then
    raise EgsStorageError.Create('Invalid folder name');
end;

procedure TgsStorageFolder.Clear;
begin
  FreeAndNil(FFolders);
  FreeAndNil(FValues);
end;

constructor TgsStorageFolder.Create(AParent: TgsStorageItem);
begin
  inherited Create(APArent);
  FValues := nil;
  FFolders := nil;
end;

function TgsStorageFolder.CreateFolder(
  const AName: String): TgsStorageFolder;
begin
  if Pos('\', AName) > 0 then
    raise EgsStorageError.Create('Invalid folder name');
  if FolderExists(AName) then
    raise EgsStorageError.Create('Duplicate folder name');
  Result := TgsStorageFolder.Create(Self, AName);
  if FFolders = nil then
    FFolders := TObjectList.Create;
  FFolders.Add(Result);
end;

function TgsStorageFolder.DeleteFolder(const AName: String): Boolean;
begin
  if FFolders = nil then
    Result := False
  else begin
    Result := FFolders.Remove(FolderByName(AName)) >= 0;
    if Result then
    begin
      if not Storage.Loading then
        Storage.IsModified := True;
    end;
  end;
end;

destructor TgsStorageFolder.Destroy;
begin
  FValues.Free;
  FFolders.Free;
  inherited;
end;

procedure TgsStorageFolder.DropFolder;
begin
  if Storage <> nil then
    Storage.IsModified := True;
  if Assigned(FParent) and (FParent is TgsStorageFolder) then
    with (FParent as TgsStorageFolder) do
    begin
      if FFolders <> nil then
        FFolders.Remove(Self);
    end
  else
    Free;
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
    end else
    begin
      if FFolders = nil then
        FFolders := TObjectList.Create;
      FFolders.Add(F);
    end;
  end;
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    V := TgsStorageValue.CreateFromStream(Self, S);
    if V = nil then
      raise EgsStorageFolderError.Create(
        'Ошибка при считывании значения #' + IntToStr(I) + ' в папке ' + Path)
    else
    begin
      if FValues = nil then
        FValues := TObjectList.Create;
      FValues.Add(V);
    end;
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
    V := TgsIntegerValue.Create(Self);
    V.Name := AValueName;
    V.AsInteger := AValue;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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
    V := TgsCurrencyValue.Create(Self);
    V.Name := AValueName;
    V.AsCurrency := AValue;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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
    V := TgsBooleanValue.Create(Self);
    V.Name := AValueName;
    V.AsBoolean := AValue;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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
    V := TgsDateTimeValue.Create(Self);
    V.Name := AValueName;
    V.AsDateTime := AValue;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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
    V := TgsStringValue.Create(Self);
    V.Name := AValueName;
    V.AsString := AValue;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
  end;
end;

procedure TgsStorageFolder.ShowPropDialog;
var
  C: Double;
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
    lFolders.Caption := IntToStr(FoldersCount);
    lValues.Caption := IntToStr(ValuesCount);
    C := DataSize;
    lSize.Caption := FloatToStrF(C, ffNumber, 10, 0) + ' байт';
    lModified.Caption := FormatDateTime('dd.mm.yyyy hh:nn:ss', FModified); 
  end;

  st_dlgfolderprop.ShowModal;
end;

function TgsStorageFolder.DeleteValue(const AValueName: String): Boolean;
begin
  if FValues = nil then
    Result := False
  else begin
    Result := FValues.Remove(ValueByName(AValueName)) >= 0;
    if Result then
    begin
      if not Storage.Loading then
        Storage.IsModified := True;
    end;
  end;
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
    V := TgsStreamValue.Create(Self);
    V.Name := AValueName;
    (V as TgsStreamValue).LoadDataFromStream(S);
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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

function TgsStorageFolder.MoveFolder(NewParent: TgsStorageFolder): Boolean;
begin
  Result := (NewParent is TgsStorageFolder) and (not FindFolder(NewParent));
  if Result then
    NewParent.AddFolder(Self);
end;

procedure TgsStorageFolder.ExtractFolder(F: TgsStorageFolder);
begin
  if FFolders <> nil then
    FFolders.Extract(F);
end;

function TgsStorageFolder.AddFolder(F: TgsStorageFolder): Integer;
begin
  if not (F is TgsStorageFolder) then
    raise EgsStorageError.Create('Invalid folder specified');
  if FindFolder(F) then
    raise EgsStorageError.Create('Duplicate folder');
  if FFolders = nil then
    FFolders := TObjectList.Create;

  if F.Parent is TgsStorageFolder then
    (F.Parent as TgsStorageFolder).ExtractFolder(F);
  F.FParent := Self;
  Result := FFolders.Add(F);

  Storage.IsModified := True;
end;

procedure TgsStorageFolder.WriteValue(AValue: TgsStorageValue);
var
  V: TgsStorageValue;
begin
  if Assigned(AValue) then
  begin
    if ValueByName(AValue.Name) <> nil then
      raise EgsStorageError.Create('Duplicate value name');
    V := AValue.GetStorageValueClass.Create(Self);
    V.Assign(AValue);
    V.Name := AValue.Name;
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
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

      if V <> nil then
      begin
        if FValues = nil then
          FValues := TObjectList.Create;
        FValues.Add(V);
      end;
    end;

    if V <> nil then
      V.LoadFromStream2(S);
  end;
end;

{ TgsRootFolder ------------------------------------------}

function TgsRootFolder.GetStorageName: String;
begin
  Result := Name;
end;

constructor TgsRootFolder.Create(AStorage: TgsStorage);
begin
  FStorage := AStorage;
  inherited Create(nil);
end;

function TgsRootFolder.GetPath: String;
begin
  Result := '';
end;

procedure TgsStorageFolder.AddValueFromStream(AValueName: String; S: TStream);
begin
  DeleteValue(AValueName);
  if FValues = nil then
    FValues := TObjectList.Create;
  FValues.Add(TgsStorageValue.CreateFromStream(Self, S));
  if not Storage.Loading then
    Storage.IsModified := True;
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

procedure TgsStorageFolder.LoadFromStream3(S: TStream);
var
  L, I: SmallInt;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  inherited LoadFromStream3(S);
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    F := TgsStorageFolder.Create(Self);
    try
      F.LoadFromStream3(S);
    except
      F.Free;
      raise;
    end;
    if FFolders = nil then
      FFolders := TObjectList.Create;
    FFolders.Add(F);
  end;
  S.ReadBuffer(L, SizeOf(L));
  for I := 1 to L do
  begin
    V := TgsStorageValue.CreateFromStream3(Self, S);
    if FValues = nil then
      FValues := TObjectList.Create;
    FValues.Add(V);
  end;
end;

procedure TgsStorageFolder.SaveToStream3(S: TStream);
var
  L, I: SmallInt;
begin
  inherited SaveToStream3(S);
  L := FoldersCount;
  S.WriteBuffer(L, SizeOf(L));
  for I := 0 to L - 1 do
    Folders[I].SaveToStream3(S);
  L := ValuesCount;
  S.WriteBuffer(L, SizeOf(L));
  for I := 0 to L - 1 do
    Values[I].SaveToStream3(S);
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
  Assert(AName > '');
  inherited Create;
  FRootFolder := TgsRootFolder.Create(Self);
  FRootFolder.Name := AName;
  FDataCompression := DefDataCompression;
  FLoading := False;

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
      if (Self = UserStorage) and (UserStorage.UserKey <> ADMIN_KEY) then
      begin
        if AdminStorage = nil then
        begin
          AdminStorage := TgsUserStorage.Create('US');
          AdminStorage.UserKey := ADMIN_KEY;
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
  FModified := True;
end;

procedure TgsStorage.LoadFromStream(S: TStream);
var
  H: TgsStorageHeader;
  DS: TZDecompressionStream;
  {$IFDEF DEBUG}
  T: Cardinal;
  {$ENDIF}
begin
  FLoading := True;
  try
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
      {$IFDEF DEBUG}
      T := GetTickCount;
      {$ENDIF}
      DS := TZDecompressionStream.Create(S);
      try
        FRootFolder.LoadFromStream(DS);
      finally
        DS.Free;
      end;
      {$IFDEF DEBUG}
      T := GetTickCount - T;
      if T > 0 then
        OutputDebugString(PChar('Decompress storage ' + Self.ClassName + ': ' + IntToStr(T)));
      {$ENDIF}
    end;
  finally
    FLoading := False;
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

  if FDataCompression = sdcNone then
  begin
    H.CompressionType := 0;
    S.WriteBuffer(H, SizeOf(H));
    FRootFolder.SaveToStream(S);
  end
  else if FDataCompression = sdcZLib then
  begin
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
  end;
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
    F.DropFolder;
  if SyncWithDatabase then
    AfterCloseFolder;
end;

procedure TgsStorage.LoadFromStream3(S: TStream);
var
  H: TgsStorageHeader;
  DS: TZDecompressionStream;
  {$IFDEF DEBUG}
  T: Cardinal;
  {$ENDIF}
begin
  FLoading := True;
  try
    Clear;

    if not Assigned(S) then
      exit;

    S.ReadBuffer(H, SizeOf(H));

    if (H.Signature <> shSignature) or (H.Version <> shVersion) then
      raise EgsStorageFolderError.Create('Invalid stream format');

    if H.CompressionType = shNoCompression then
    begin
      FRootFolder.LoadFromStream3(S);
    end
    else if H.CompressionType = shZLibCompression then
    begin
      {$IFDEF DEBUG}
      T := GetTickCount;
      {$ENDIF}
      DS := TZDecompressionStream.Create(S);
      try
        FRootFolder.LoadFromStream3(DS);
      finally
        DS.Free;
      end;
      {$IFDEF DEBUG}
      T := GetTickCount - T;
      if T > 0 then
        OutputDebugString(PChar('Decompress storage ' + Self.ClassName + ': ' + IntToStr(T)));
      {$ENDIF}
    end;
  finally
    FLoading := False;
  end;
end;

procedure TgsStorage.SaveToStream3(S: TStream);
var
  H: TgsStorageHeader;
  //CS: TZCompressionStream;
begin
  H.Signature := shSignature;
  H.Version := shVersion;

  {if FDataCompression = sdcNone then
  begin}
    H.CompressionType := 0;
    S.WriteBuffer(H, SizeOf(H));
    FRootFolder.SaveToStream3(S);
  {end
  else if FDataCompression = sdcZLib then
  begin
    H.CompressionType := 1;
    S.WriteBuffer(H, SizeOf(H));
    CS := TZCompressionStream.Create(S);
    try
      FRootFolder.SaveToStream3(CS);
    finally
      CS.Free;
    end;
  end;}
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

{ TgsIBStorage }

constructor TgsIBStorage.Create(const AName: String);
begin
  inherited Create(AName);
  FExist := False;
  FLastModified := 0;
  FLastChecked := 0;
  FValid := False;
end;

procedure TgsIBStorage.SaveToDataBase;
begin
  Assert(IBLogin.DataBase <> nil, 'Не подключен DataBase');
  FLastChecked := GetTickCount;
end;

procedure TgsIBStorage.LoadFromDataBase;
begin
  Assert(IBLogin.DataBase <> nil, 'Не подключен DataBase');
  FLastChecked := GetTickCount;
end;

function TgsIBStorage.GetCacheFileName: String;
begin
  Result := '';
end;

{ TgsUserStorage }

constructor TgsUserStorage.Create(const AName: String);
begin
  inherited Create(AName);
  FUserKey := -1;
  {$IFDEF DEBUG } CountSave := 0;{$ENDIF}
end;

procedure TgsUserStorage.SaveToDataBase;
var
  Transaction: TIBTransaction;
  q: TIBSQL;
  F: Integer;
begin
  if FUserKey = -1 then
    exit;

  inherited SaveToDatabase;

  if not FValid then
    exit;

  if IsModified then
  begin
    F := 5;
    repeat
      q := TIBSQL.Create(nil);
      Transaction := TIBTransaction.Create(nil);
      try
        Transaction.DefaultDatabase := IBLogin.Database;
        q.Transaction := Transaction;
        Transaction.StartTransaction;

        q.SQL.Text := 'SELECT userkey FROM gd_userstorage WHERE userkey = :userkey';
        q.ParamByName('userkey').AsInteger := FUserKey;
        q.ExecQuery;

        if not q.EOF then
        begin
          q.Close;
          q.SQL.Text :=
            'UPDATE gd_userstorage SET data = :data, modified = ''NOW'' WHERE userkey = :userkey';
        end else
        begin
          q.Close;
          q.SQL.Text :=
            'INSERT INTO gd_userstorage (userkey, data, modified) VALUES(:userkey, :data, ''NOW'')';
        end;

        try
          q.ParamByName('userkey').AsInteger := FUserKey;
          q.ParamByName('data').AsString := DataString;

          try
            q.ExecQuery;
            Transaction.Commit;

            Transaction.StartTransaction;
            q.SQL.Text :=
              'SELECT modified FROM gd_userstorage WHERE userkey = :userkey';
            q.ParamByName('userkey').AsInteger := FUserKey;
            q.ExecQuery;

            FLastModified := q.Fields[0].AsDateTime;
            FModified := False;
            FExist := True;

            q.Close;
            Transaction.Commit;
            F := 0;

            SaveToCache;
          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_deadlock) or (E.IBErrorCode = isc_lock_conflict) then
              begin
                if Transaction.InTransaction then
                  Transaction.Rollback;
                Dec(F);
                Sleep(1000);
              end else
                raise;
            end else
              raise;
          end;
        except
          on E: Exception do
          begin
            MessageBox(0,
              PCHar('Произошла ошибка при сохранении пользовательского хранилища для UserKey=' + IntToStr(FUserKey) + '.' +
              #13#10 + #13#10 +
              'Сообщение об ошибке: ' + E.Message),
              'Внимание',
              MB_TASKMODAL or MB_OK or MB_ICONHAND);
            // иначе получим бесконечный цикл
            F := 0;
          end;
        end;

      finally
        q.Free;
        Transaction.Free;
      end;
    until F = 0;

    if FModified then
      FLastChecked := 0;
  end else
  begin
    if not FLoadedFromCache then
      SaveToCache;
  end;
end;

procedure TgsUserStorage.LoadFromDataBase;
var
  IBSQL: TIBSQL;
  Transaction: TIBTransaction;
  bs: TIBBlobStream;
begin
  if FUserKey = -1 then
    exit;

  inherited LoadFromDatabase;

  FValid := False;
  IBSQL := TIBSQL.Create(nil);
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := IBLogin.DataBase;
    IBSQL.Transaction := Transaction;

    Transaction.StartTransaction;

    IBSQL.SQL.Text :=
      'SELECT data, modified FROM gd_userstorage WHERE userkey = :UserKey';
    IBSQL.ParamByName('userkey').AsInteger := FUserKey;
    IBSQL.ExecQuery;

    FExist := IBSQL.RecordCount > 0;
    if FExist then
    begin
      FLastModified := IBSQL.FieldByName('modified').AsDateTime;
      FLoadedFromCache := LoadFromCache;

      if not FValid then
      begin
        bs := TIBBlobStream.Create;
        try
          bs.Mode := bmRead;
          bs.Database := IBSQL.Database;
          bs.Transaction := IBSQL.Transaction;
          bs.BlobID := IBSQL.FieldByName('data').AsQuad;
          try
            LoadFromStream(bs);
            FValid := True;
          except
            on E:Exception do
            begin
              MessageBox(0,
                PCHar('Произошла ошибка при загрузке пользовательского хранилища для UserKey=' + IntToStr(FUserKey) + '.' +
                #13#10 + #13#10 +
                'Сообщение об ошибке: ' + E.Message),
                'Внимание',
                MB_TASKMODAL or MB_OK or MB_ICONHAND);

              FValid := True;
            end;
          end;
        finally
          bs.Free;
        end;
      end;
    end else
    begin
      Clear;
      FExist := True;
      FValid := True;
    end;

    if Assigned(IBLogin) and (IBLogin.UserKey = FUserKey) then
    else
      FRootFolder.Name := 'USER(' + IBLogin.UserName + ')';
    begin
      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT name FROM gd_user WHERE id=' + IntToStr(FUserKey);
      IBSQL.ExecQuery;
      FRootFolder.Name := 'USER(' + IBSQL.FieldByName('NAME').AsString + ')';
    end;
  finally
    IBSQL.Free;
    if Transaction.InTransaction then
      Transaction.Commit;
    Transaction.Free;
  end;

  FModified := False;
end;

procedure TgsUserStorage.SetUserKey(const Value: Integer);
{var
  Tr: TIBTransaction;
  q: TIBSQL;}
begin
  if FUserKey <> Value then
  begin
    {if Value <> -1 then
    begin
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := IBLogin.Database;
        q.Transaction := Tr;
        Tr.StartTransaction;
        q.SQL.Text := 'SELECT id FROM gd_user WHERE id = :ID';
        q.ParamByName('ID').AsInteger := Value;
        q.ExecQuery;
        if q.EOF then
          raise EgsStorageError.Create('Invalid user key specified.');
        q.Close;
        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    end;}

    if FUserKey <> -1 then
      SaveToDatabase;

    FUserKey := Value;

    if FUserKey <> -1 then
      LoadFromDatabase
    else
      Clear;
  end;
end;

procedure TgsUserStorage.AfterCloseFolder;
begin
  if Assigned(IBLogin) and IBLogin.LoggedIn
    and ((FUserKey <> IBLogin.UserKey) or (IBLogin.IsIBUserAdmin))
    and IsModified then
  begin
    SaveToDatabase;
  end;  
end;

procedure TgsUserStorage.BeforeOpenFolder;
var
  IBSQL: TIBSQL;
begin
  if FUserKey = -1 then
    exit;

  if Assigned(IBLogin) and (IBLogin.LoggedIn)
    and ((FUserKey <> IBLogin.UserKey) or (IBLogin.IsIBUserAdmin)) then
  begin
    if not FExist then
      LoadFromDatabase
    else if (GetTickCount - FLastChecked > CacheTime)
      or (GetTickCount < FLastChecked) then
    begin
      IBSQL := TIBSQl.Create(nil);
      try
        IBSQL.Transaction := gdcBaseManager.ReadTransaction;
        IBSQL.SQL.Text := 'SELECT modified FROM gd_userstorage WHERE userkey = :userkey';
        IBSQL.ParamByName('userkey').AsInteger := FUserKey;
        IBSQL.ExecQuery;
        if IBSQL.RecordCount > 0 then
        begin
          if IBSQL.FieldByName('modified').AsDateTime <> FLastModified then
            LoadFromDataBase;
        end;
        FLastChecked := GetTickCount;
      finally
        IBSQL.Free;
      end;
    end;
  end;
end;

function TgsUserStorage.GetCacheFileName: String;
var
  Path: array[0..255] of Char;
begin
  Assert(Assigned(IBLogin));
  GetTempPath(SizeOf(Path), Path);
  Result := IncludeTrailingBackslash(Path)
    + Format(USER_STORAGE_FILE_NAME, [IntToStr(IBLogin.DBVersionID),
      IntToStr(UserKey)])
end;

{ TgsGlobalStorage }

procedure TgsGlobalStorage.BeforeOpenFolder;
var
  IBSQL: TIBSQL;
begin
  if Assigned(IBLogin) and IBLogin.LoggedIn then
  begin
    if not FExist then
      LoadFromDatabase
    else if (GetTickCount - FLastChecked > CacheTime)
      or (GetTickCount < FLastChecked) then
    begin
      IBSQL := TIBSQl.Create(nil);
      try
        IBSQL.Transaction := gdcBaseManager.ReadTransaction;
        IBSQL.SQL.Text := 'SELECT modified FROM gd_globalstorage';
        IBSQL.ExecQuery;
        if IBSQL.RecordCount > 0 then
          if IBSQL.FieldByName('modified').AsDateTime <> FLastModified then
            LoadFromDataBase;
        FLastChecked := GetTickCount;
      finally
        IBSQL.Free;
      end;
    end;
  end;  
end;

procedure TgsGlobalStorage.AfterCloseFolder;
begin
  if Assigned(IBLogin) and IBLogin.LoggedIn and IsModified then
    SaveToDatabase;
end;

procedure TgsGlobalStorage.SaveToDataBase;
var
  IBSQL: TIBSQL;
  Transaction: TIBTransaction;
  F: Integer;
  TempLastModified: TDateTime;
  bs: TIBBlobStream;
begin
  inherited SaveToDatabase;

  if not FValid then
    exit;

  if (FRootFolder.FoldersCount = 0) and (FRootFolder.ValuesCount = 0) then
    exit;  

  if IsModified then
  begin
    F := 5;
    repeat
      IBSQL := TIBSQL.Create(nil);
      Transaction := TIBTransaction.Create(nil);
      try
        Transaction.DefaultDatabase := IBLogin.DataBase;
        IBSQL.Transaction := Transaction;
        Transaction.StartTransaction;

        IBSQL.SQL.Text := 'SELECT modified FROM gd_globalstorage';
        IBSQL.ExecQuery;
        FExist := IBSQL.RecordCount > 0;

        try
          try
            IBSQL.Close;
            if FExist then
              IBSQL.SQL.Text := 'UPDATE gd_globalstorage SET data=:D, modified=''NOW'''
            else
              IBSQL.SQL.Text := 'INSERT INTO gd_globalstorage (data, modified) VALUES(:D, ''NOW'')';
            IBSQL.Prepare;

            bs := TIBBlobStream.Create;
            try
              bs.Mode := bmWrite;
              bs.Database := IBSQL.Database;
              bs.Transaction := IBSQL.Transaction;
              SaveToStream(bs);
              bs.Finalize;
              IBSQL.ParamByName('D').AsQuad := bs.BlobID;
              IBSQL.ExecQuery;
            finally
              bs.Free;
            end;

            IBSQL.Close;
            IBSQL.SQL.Text := 'SELECT modified FROM gd_globalstorage';
            IBSQL.ExecQuery;
            TempLastModified := IBSQL.Fields[0].AsDateTime;
            IBSQL.Close;

            Transaction.Commit;
            FExist := True;
            FModified := False;
            FLastModified := TempLastModified;
            F := 0;

            SaveToCache;
          except
            on E: EIBError do
            begin
              if (E.IBErrorCode = isc_deadlock) or (E.IBErrorCode = isc_lock_conflict) then
              begin
                if Transaction.InTransaction then
                  Transaction.Rollback;
                Dec(F);
                Sleep(1000);
              end else
                raise;
            end else
              raise;
          end;
        except
          on E: Exception do
          begin
            MessageBox(0,
              PCHar('Произошла ошибка при сохранении глобального хранилища.' +
              #13#10 + #13#10 +
              'Сообщение об ошибке: ' + E.Message),
              'Внимание',
              MB_TASKMODAL or MB_OK or MB_ICONHAND);
            //иначе получим бесконечный цикл
            F := 0;
          end;
        end;
      finally
        if Transaction.InTransaction then
          Transaction.Commit;
        IBSQL.Free;
        Transaction.Free;
      end;
    until F = 0;

    if FModified then
      FLastChecked := 0;
  end else
  begin
    if not FLoadedFromCache then
      SaveToCache;
  end;
end;

procedure TgsGlobalStorage.LoadFromDataBase;
var
  IBSQL: TIBSQL;
  Transaction: TIBTransaction;
  bs: TIBBlobStream;
begin
  FValid := False;
  inherited LoadFromDatabase;
  IBSQL := TIBSQL.Create(nil);
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := IBLogin.DataBase;
    IBSQL.Transaction := Transaction;
    Transaction.StartTransaction;

    IBSQL.SQL.Text := 'SELECT data, modified FROM gd_globalstorage';
    IBSQL.ExecQuery;
    FExist := IBSQL.RecordCount > 0;
    FLastModified := IBSQL.FieldByName('modified').AsDateTime;

    if FExist then
    begin
      FLoadedFromCache := LoadFromCache;
      if not FValid then
      begin
        bs := TIBBlobStream.Create;
        try
          bs.Mode := bmRead;
          bs.Database := IBSQL.Database;
          bs.Transaction := IBSQL.Transaction;
          bs.BlobID := IBSQL.FieldByName('data').AsQuad;
          try
            LoadFromStream(bs);
            FValid := True;
          except
            on E:Exception do
            begin
              MessageBox(0,
                PCHar('Произошла ошибка при загрузке глобального хранилища.' +
                #13#10 + #13#10 +
                'Сообщение об ошибке: ' + E.Message),
                'Внимание',
                MB_TASKMODAL or MB_OK or MB_ICONHAND);

              FValid := True;
            end;
          end;
        finally
          bs.Free;
        end;
      end;
    end else
    begin
      Clear;
      FExist := True;
      FValid := True;
    end;

  finally
    IBSQL.Free;
    if Transaction.InTransaction then
      Transaction.Commit;
    Transaction.Free;
  end;

  FModified := False;
end;

function TgsIBStorage.LoadFromCache: Boolean;
var
  FFileName: String;
  S: TFileStream;
  I: Integer;
  DT: TDateTime;
begin
  Result := False;

  if IBLogin.ServerName > '' then
  begin
    FFileName := GetCacheFileName;
    if FileExists(FFileName) then
    begin
      if FindCmdLineSwitch('NC', ['/', '-'], True) then
        SysUtils.DeleteFile(FFileName)
      else
        try
          S := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
          try
            if (S.Read(I, SizeOf(I)) = SizeOf(I))
              and (I = STORAGE_FILE_SIGN) then
            begin
              if (S.Read(I, SizeOf(I)) = SizeOf(I))
                and (I = STORAGE_FILE_VER) then
              begin
                if (S.Read(DT, SizeOf(DT)) = SizeOf(DT))
                  and (DT = FLastModified) then
                begin
                  LoadFromStream3(S);
                  FValid := (FRootFolder.FoldersCount > 0)
                    or (FRootFolder.ValuesCount > 0);
                  Result := True;
                end;
              end;
            end;
          finally
            S.Free;
          end;
        except
          Clear;
          FValid := False;

          // не будем делать трагедии из-за какого-то кэша
          SysUtils.DeleteFile(FFileName);
        end;
    end;
  end;
end;

procedure TgsIBStorage.SaveToCache;
var
  I: Integer;
  FFileName: String;
  S: TFileStream;
begin
  if (IBLogin.ServerName > '') and
    (not FindCmdLineSwitch('NC', ['/', '-'], True)) then
  begin
    FFileName := GetCacheFileName;
    try
      if (FRootFolder.FoldersCount > 0) or (FRootFolder.ValuesCount > 0) then
      begin
        S := TFileStream.Create(FFileName, fmCreate);
        try
          I := STORAGE_FILE_SIGN;
          S.Write(I, SizeOf(I));
          I := STORAGE_FILE_VER;
          S.Write(I, SizeOf(I));
          S.Write(FLastModified, SizeOf(FLastModified));
          SaveToStream3(S);
        finally
          S.Free;
        end;
      end else
        SysUtils.DeleteFile(FFileName);
    except
      SysUtils.DeleteFile(FFileName);
    end;
  end;
end;

function TgsGlobalStorage.GetCacheFileName: String;
var
  Path: array[0..255] of Char;
begin
  Assert(Assigned(IBLogin));
  GetTempPath(SizeOf(Path), Path);
  Result := IncludeTrailingBackslash(Path)
    + Format(GLOBAL_STORAGE_FILE_NAME, [IntToStr(IBLogin.DBVersionID)])
end;

{ TgsCompanyStorage }

constructor TgsCompanyStorage.Create(const AName: String);
begin
  inherited Create(AName);
  FCompanyKey := -1;
end;

procedure TgsCompanyStorage.SaveToDataBase;
var
  IBSQL: TIBSQL;
  ibsqlExists: TIBSQL;
  Transaction: TIBTransaction;
begin
  if FCompanyKey = -1 then
    exit; // нечего сохранять

  inherited SaveToDatabase;

  if not FValid then
    exit;

  if IsModified then
  begin
    IBSQL := TIBSQL.Create(nil);
    ibsqlExists := TIBSQL.Create(nil);
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := IBLogin.DataBase;
      IBSQL.Transaction := Transaction;
      ibsqlExists.Transaction := Transaction;
      Transaction.StartTransaction;

      ibsqlExists.SQL.Text := 'SELECT companykey FROM gd_ourcompany WHERE companykey = :id';
      ibsqlExists.ParamByName('id').AsInteger := FCompanyKey;
      ibsqlExists.ExecQuery;

      if ibsqlExists.RecordCount > 0 then
      begin
        if FExist then
          IBSQL.SQL.Text := 'UPDATE gd_companystorage SET data=:D, modified=''NOW'' WHERE companykey=:U'
        else
          IBSQL.SQL.Text := 'INSERT INTO gd_companystorage (companykey, data, modified) VALUES(:U, :D, ''NOW'')';
        IBSQL.ParamByName('U').AsInteger := FCompanyKey;
        IBSQL.ParamByName('D').AsString := DataString;
        IBSQL.ExecQuery;
        FExist := True;
      end
      else begin
        if FExist then
        begin
          IBSQL.SQL.Text := 'DELETE FROM gd_companystorage WHERE companykey=:U';
          IBSQL.ParamByName('U').AsInteger := FCompanyKey;
          IBSQL.ExecQuery;
        end;
      end;

    finally
      IBSQL.Free;
      ibsqlExists.Free;
      if Transaction.InTransaction then
        Transaction.Commit;
      Transaction.Free;
    end;

    FModified := False;
  end;
end;

procedure TgsCompanyStorage.LoadFromDataBase;
var
  IBSQL: TIBSQL;
begin
  if FCompanyKey = -1 then
    exit;

  inherited LoadFromDatabase;

  FValid := False;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := gdcBaseManager.ReadTransaction;
    IBSQL.SQL.Text :=
      'SELECT data, modified FROM gd_companystorage WHERE companykey=' + IntToStr(FCompanyKey);
    IBSQL.ExecQuery;
    FExist := IBSQL.RecordCount > 0;

    if FExist then
    begin
      DataString := IBSQL.FieldByName('data').AsString;
      FLastModified := IBSQL.FieldByName('modified').AsDateTime;
      FValid := True;
    end else
    begin
      Clear;
      FValid := True; 
    end;

    if Assigned(IBLogin) and (IBLogin.CompanyKey = FCompanyKey) then
    begin
      FRootFolder.Name := 'COMPANY(' + IBLogin.CompanyName + ')';
    end else
    begin
      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT name FROM gd_contact WHERE id=' + IntToStr(FCompanyKey);
      IBSQL.ExecQuery;
      FRootFolder.Name := 'COMPANY(' + IBSQL.FieldByName('NAME').AsString + ')';
    end;

    IBSQL.Close;
  finally
    IBSQL.Free;
  end;

  FModified := False;
end;

procedure TgsCompanyStorage.SetCompanyKey(const Value: Integer);
{var
  Tr: TIBTransaction;
  q: TIBSQL;}
begin
  if FCompanyKey <> Value then
  begin
    {if Value <> -1 then
    begin
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := IBLogin.Database;
        q.Transaction := Tr;
        Tr.StartTransaction;
        q.SQL.Text := 'SELECT id FROM gd_contact WHERE id = :ID';
        q.ParamByName('ID').AsInteger := Value;
        q.ExecQuery;
        if q.EOF then
          raise EgsStorageError.Create('Invalid company key specified.');
        q.Close;
        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    end;}

    if FCompanyKey <> -1 then SaveToDatabase;
    FCompanyKey := Value;
    if FCompanyKey <> -1 then LoadFromDatabase else Clear;
  end;
end;

{ TgsStorageItem }

procedure TgsStorageItem.Assign(AnItem: TgsStorageItem);
begin
  if AnItem <> Self then
  begin
    if (FParent <> AnItem.Parent) or (FParent = nil) then
      FName := AnItem.Name;
    if not Storage.Loading then
      Storage.IsModified := True;
  end;
end;

constructor TgsStorageItem.Create(AParent: TgsStorageItem);
begin
  inherited Create;
  FParent := AParent;
  FName := GetFreeName;
  if not Storage.Loading then
  begin
    Storage.IsModified := True;
    FModified := Now;
  end;  
end;

constructor TgsStorageItem.Create(AParent: TgsStorageItem; const AName: String);
begin
  Create(AParent);
  Name := AName;
end;

destructor TgsStorageItem.Destroy;
begin
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
    Result := '\' + FName;
end;

function TgsStorageItem.GetStorage: TgsStorage;
begin
  if Parent <> nil then Result := Parent.Storage
    else Result := nil;
end;

procedure TgsStorageItem.LoadFromFile(const AFileName: String;
  const FileFormat: TgsStorageFileFormat);
begin

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
  Storage.IsModified := False;
{ TODO :
ради совместимости мы делаем это
позже, когда будет сделано сохранение в текст
надо будет сохранить, выкинуть этот код (старые потоки
перестанут считываться) и загрузить их из текста }
  S.ReadBuffer(FModified, Sizeof(FModified));
  S.ReadBuffer(Dummy, SizeOf(Dummy));
  S.ReadBuffer(Dummy, SizeOf(Dummy));
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

function TgsStorageItem.GetStorageName: String;
begin
  if FParent <> nil then
    Result := FParent.GetStorageName
  else
    Result := '';  
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
end;

procedure TgsStorageItem.SetName(const Value: String);
var
  S: String;
begin
  S := Trim(Value);

  if Length(S) > 255 then
    raise EgsStorageError.Create('Name is too long.');

  CheckForName(S);
  if FName <> S then
  begin
    FName := S;
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;  
  end;
end;

procedure TgsStorageItem.LoadFromStream3(S: TStream);
var
  L: Byte;
begin
  Clear;
  S.ReadBuffer(L, SizeOf(L));
  SetLength(FName, L);
  if L > 0 then
    S.ReadBuffer(FName[1], L)
  else
    FName := GetFreeName;  
  Storage.IsModified := False;
  S.ReadBuffer(FModified, Sizeof(FModified));
end;

procedure TgsStorageItem.SaveToStream3(S: TStream);
var
  L: Byte;
begin
  L := Length(FName);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(FName[1], L);
  S.WriteBuffer(FModified, Sizeof(FModified));
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

class function TgsIntegerValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := tgsIntegerValue;
end;

class function TgsIntegerValue.GetTypeId: Integer;
begin
  Result := svtInteger;
end;

class function TgsIntegerValue.GetTypeName: String;
begin
  Result := 'I';
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
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;
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

procedure TgsIntegerValue.LoadFromStream3(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsIntegerValue.SaveToStream3(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
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

class function TgsCurrencyValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := TgsCurrencyValue;
end;

class function TgsCurrencyValue.GetTypeId: Integer;
begin
  Result := svtCurrency;
end;

class function TgsCurrencyValue.GetTypeName: String;
begin
  Result := 'C';
end;

procedure TgsCurrencyValue.LoadFromStream(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.LoadFromStream3(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.SaveToStream(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.SaveToStream3(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
end;

procedure TgsCurrencyValue.SetAsCurrency(const Value: Currency);
begin
  if Value <> AsCurrency then
  begin
    FData := Value;
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;
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
  if FData > '' then
  begin
    try
      Result := ZDecompressStr(FData)
    except
      FData := '';
      Result := '';
    end;
  end else
    Result := '';
end;

function TgsStringValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + Length(FData);
end;

class function TgsStringValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := TgsStringValue;
end;

class function TgsStringValue.GetTypeId: Integer;
begin
  Result := svtString;
end;

class function TgsStringValue.GetTypeName: String;
begin
  Result := 'S';
end;

procedure TgsStringValue.LoadFromStream(S: TStream);
var
  L: Integer;
  T: String;
begin
  inherited;

  S.ReadBuffer(L, SizeOf(L));

  {if L > 0 then
  begin
    SetLength(FData, L);
    S.ReadBuffer(FData[1], L);
  end;}

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


{  L := Length(FData);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(FData[1], L); }

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
var
  T: String;
begin
  if Value > '' then
  begin
    T := ZCompressStr(Value, zcDefault);
  end else
    T := '';

  if T <> FData then
  begin
    FData := T;
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;
  end;
end;

function TgsStringValue.GetAsBoolean: Boolean;
begin
  if (AsString <> '0') and (AsString <> '1') then
    raise EgsStorageError.Create('Invalid typecast');
  Result := AsString = '1';
end;

procedure TgsStringValue.SetAsBoolean(const Value: Boolean);
begin
  if Value then
    AsString := '1'
  else
    AsString := '0';  
end;

procedure TgsStringValue.LoadFromStream3(S: TStream);
var
  L: Integer;
begin
  inherited;

  S.ReadBuffer(L, SizeOf(L));

  if L > 0 then
  begin
    SetLength(FData, L);
    S.ReadBuffer(FData[1], L);
  end;
end;

procedure TgsStringValue.SaveToStream3(S: TStream);
var
  L: Integer;
begin
  inherited;

  L := Length(FData);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(FData[1], L);
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
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;  
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

class function TgsDateTimeValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := TgsDateTimeValue;
end;

class function TgsDateTimeValue.GetTypeId: Integer;
begin
  Result := svtDateTime;
end;

class function TgsDateTimeValue.GetTypeName: String;
begin
  Result := 'D';
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

procedure TgsDateTimeValue.LoadFromStream3(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsDateTimeValue.SaveToStream3(S: TStream);
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

class function TgsBooleanValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := TgsBooleanValue;
end;

class function TgsBooleanValue.GetTypeId: Integer;
begin
  Result := svtBoolean;
end;

class function TgsBooleanValue.GetTypeName: String;
begin
  Result := 'B';
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
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;  
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

procedure TgsBooleanValue.LoadFromStream3(S: TStream);
begin
  inherited;
  S.ReadBuffer(FData, SizeOf(FData));
end;

procedure TgsBooleanValue.SaveToStream3(S: TStream);
begin
  inherited;
  S.WriteBuffer(FData, SizeOf(FData));
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

procedure TgsStorageValue.Assign(AnItem: TgsStorageItem);
begin
  inherited;
  AsString := (AnItem as TgsStorageValue).AsString;
end;

procedure TgsStorageValue.CheckForName(const AName: String);
var
  N: String;
begin
  N := Trim(AName);
  if (N = '') or (Assigned(FParent) and (FParent as TgsStorageFolder).ValueExists(N)) then
    raise EgsStorageError.Create('Invalid value name');
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
  raise EgsStorageError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsInteger: Integer;
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsCurrency: Currency;
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsDateTime: TDateTime;
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsCurrency(const Value: Currency);
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

function TgsStorageValue.GetAsString: String;
begin
  raise EgsStorageError.Create('Invalid typecast');
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
  raise EgsStorageError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsDateTime(const Value: TDateTime);
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsInteger(const Value: Integer);
begin
  raise EgsStorageError.Create('Invalid typecast');
end;

procedure TgsStorageValue.SetAsString(const Value: String);
begin
  raise EgsStorageError.Create('Invalid typecast');
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
    //SetupDialog;

    OldName := Self.Name;
     edName.Text := OldName;
    edValue.Text := AsString;

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

procedure TgsStorageValue.LoadFromStream3(S: TStream);
begin
  inherited;
end;

procedure TgsStorageValue.SaveToStream3(S: TStream);
var
  L: Byte;
begin
  L := GetTypeID;
  S.WriteBuffer(L, SizeOf(L));
  inherited;
end;

class function TgsStorageValue.CreateFromStream3(AParent: TgsStorageFolder;
  S: TStream): TgsStorageValue;
var
  L: Byte;
begin
  S.ReadBuffer(L, SizeOf(L));
  case L of
    svtInteger: Result := TgsIntegerValue.Create(AParent);
    svtString: Result := TgsStringValue.Create(AParent);
    svtStream: Result := TgsStreamValue.Create(AParent);
    svtBoolean: Result := TgsBooleanValue.Create(AParent);
    svtDateTime: Result := TgsDateTimeValue.Create(AParent);
    svtCurrency: Result := TgsCurrencyValue.Create(AParent);
  else
    raise EgsStorageError.Create('Invalid value type');
  end;
  Result.LoadFromStream3(S);
end;

{ TgsStreamValue }

procedure TgsStreamValue.Clear;
begin
  FData := '';
end;

function TgsStreamValue.GetAsString: String;
begin
  if FData > '' then
    Result := ZDecompressStr(FData)
  else
    Result := '';  
end;

function TgsStreamValue.GetDataSize: Integer;
begin
  Result := inherited GetDataSize + Length(FData);
end;

class function TgsStreamValue.GetStorageValueClass: TgsStorageValueClass;
begin
  Result := TgsStreamValue;
end;

class function TgsStreamValue.GetTypeId: Integer;
begin
  Result := svtStream;
end;

class function TgsStreamValue.GetTypeName: String;
begin
  Result := 'St';
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

  function HexToByte(const St: String): Byte;
  const
    HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  begin
    Result := (Pos(St[1], HexDigits) - 1) * 16 + (Pos(St[2], HexDigits) - 1);
  end;

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

    {Result := '';
    while (TempStr <> #13) and (TempStr <> #10) do
    begin
      Result := Result + TempStr;
      TempStr := S.ReadString(1);
    end;
    TempStr := S.ReadString(1);
    if (TempStr <> #13) and (TempStr <> #10) then
      S.Position := S.Position - 1;}
  end;

  procedure AddData(const Str: String);
  var
    ByteStr: String;
    I: Integer;
    B: Byte;
  begin
    ByteStr := '';
    for I := 1 to Length(Str) do
      if Str[I] <> ' ' then
      begin
        ByteStr := ByteStr + Str[I];
        if Length(ByteStr) = 2 then
        begin
          B := HexToByte(ByteStr);
          TempBuffer := TempBuffer + Char(B);
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
  try
    T := AsString;
  except
    T := '';
    //raise;
  end;
  L := Length(T);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(T[1], L);
end;

procedure TgsStreamValue.SaveToStream2(S: TStringStream);

  function ByteToHex(const B: Byte): String;
  const
    HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  begin
    Result := HexDigits[B div 16] + HexDigits[B mod 16];
  end;

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
      C := StrCat(C, PChar(ByteToHex(Byte(T[I])) + ' ')) + StrLen(C);
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
var
  S: String;
begin
  if Value > '' then
    S := ZCompressStr(Value, zcDefault)
  else
    S := '';
  if S <> FData then
  begin
    FData := S;
    if not Storage.Loading then
    begin
      Storage.IsModified := True;
      FModified := Now;
    end;
  end;
end;

procedure TgsStreamValue.LoadFromStream3(S: TStream);
var
  L: Integer;
begin
  inherited;
  S.ReadBuffer(L, SizeOf(L));
  if L > 0 then
  begin
    SetLength(FData, L);
    S.ReadBuffer(FData[1], L);
  end;
end;

procedure TgsStreamValue.SaveToStream3(S: TStream);
var
  L: Integer;
begin
  inherited;
  L := Length(FData);
  S.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    S.WriteBuffer(FData[1], L);
end;

{ TgsStorageDragObject }

constructor TgsStorageDragObject.Create;
begin
  inherited Create;
  F := AF;
  TN := ATN;
end;

function TgsRootFolder.GetStorage: TgsStorage;
begin
  Result := FStorage;
end;

{$IFDEF DEBUG}
initialization
  StorageFolderSearchCounter := 0;

finalization
  OutputDebugString(PChar('SSC: ' + IntToStr(StorageFolderSearchCounter)));
{$ENDIF}
end.
