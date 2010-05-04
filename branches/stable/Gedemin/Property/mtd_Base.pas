
unit mtd_Base;

interface

uses
  evt_i_Base, mtd_i_Base, SysUtils, TypInfo, IBDatabase, Classes,
  Contnrs, rp_BaseReport_unit, scr_i_FunctionList, gdcBase, gd_DebugLog,
  gd_KeyAssoc, gdcBaseInterface, JclStrHashMap;

const
  strStartClass = 'SCS';
  strEndClass = 'ECS';
  strStartClassList = 'SCLS';
  strEndClassList = 'ECLS';

type
  TmtdClassType = (mtd_gdcBase, mtd_gdcForm);
  TCustomMethodClass = class;
  TMethodClass = class;
  TMethodClassList = class;

  // Информация о методе класса
  TMethodItem = class(TObject)
  private
    FMethodData: PTypeData;
    // указатель на MethodClass, кот. принадлежит данный метод
    FMethodClass: TCustomMethodClass;
    // указывает подключен метод или нет
    FDisable: Boolean;
    // ИД метода
    FMethodId: Integer;
    // ключ скрипт-функции данного метода
    FFunctionKey: Integer;
    // имя метода
    FCustomName: String;

    function GetDelphiParamString(const LocParamCount: Integer;
      const LocParams: array of Char; const AnLang: TFuncParamLang;
      out AnResultParam: String): String;
    //TipTop: Возвращает имя параметра
    function GetDelphiParamName(const Index: Integer;
      const LocParams: array of Char; const AnLang: TFuncParamLang;
      out AnResultParam: String): String;
    // Возращает тип результата - объект или нет
    function GetResultType(const Index: Integer;
      const LocParams: array of Char): String;
    procedure SetDisable(const Value: Boolean);
    procedure SetMethodId(const Value: Integer);
    procedure SetMethodClass(const Value: TCustomMethodClass);
    procedure Assign(ASource: TMethodItem);
    function  GetComplexParams(const AnLang: TFuncParamLang): String;
  public
    constructor Create;
    destructor  Destroy; override;

    // возращает имя скрипт-функции для данного метода и объетка
    function AutoFunctionName: String;

    // инф-ция о методе
    property MethodData: PTypeData read FMethodData write FMethodData;
    // указатель на MethodClass, кот. принадлежит данный метод
    property MethodClass: TCustomMethodClass read FMethodClass write SetMethodClass;
    // поле указывает используется скрипт-метод для метода или нет
    property Disable: Boolean read FDisable write SetDisable;
    // ИД метода
    property MethodId: Integer read FMethodId write SetMethodId;
    // имя метода
    property Name: String read FCustomName write FCustomName;
    // ключ скрипт-функции
    property FunctionKey: Integer read FFunctionKey write FFunctionKey default 0;
    // Возвращает шаблон пустой функции в зависимости от языка
    property ComplexParams[const AnLang: TFuncParamLang]: String read GetComplexParams;
  end;

  TMethodList = class;

  // Базовый класс для хранения инф-ции о классе и его методах
  TCustomMethodClass = class
  private
    FMethodList: TMethodList;
    FClass_Key: Integer;
    FName: string;
    FClass_Reference: TClass;

    FSpecMethodCount: Integer;
    FSpecDisableMethod: Integer;
    FSubType: String;
    FSubTypeComment: String;

    procedure SetSpecMethodCount(const Value: Integer);
    procedure SetSpecDisableMethod(const Value: Integer);
    procedure SetSubType(const Value: String);
    procedure SetSubTypeComment(const Value: String);
  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Assign(Source: TCustomMethodClass); virtual;

    // Список методов
    property MethodList: TMethodList read FMethodList write FMethodList;
    // Кол-во методов
    property SpecMethodCount: Integer read FSpecMethodCount write SetSpecMethodCount;
    // Кол-во отключенных методов
    property SpecDisableMethod: Integer read FSpecDisableMethod write setSpecDisableMethod;
    // Ключ класса в базе данных (табл. evt_object)
    property Class_Key: Integer read FClass_Key write FClass_Key;
    // Указатель на класс
    property Class_Reference: TClass read FClass_Reference write FClass_Reference;
    // Имя класса
    property Class_Name: string read FName write FName;
    // Подпит
    property SubType: String read FSubType write SetSubType;
    // Расшифровка подтипа
    property SubTypeComment: String read FSubTypeComment write SetSubTypeComment;
  end;

  // Класс хранит данные по одному классу
  TMethodClass = class(TCustomMethodClass)
  private
    FSubTypeMethodList: TStringList;

    function  GetSubTypeItemByIndex(const Index: Integer): TCustomMethodClass;
  public
    constructor Create; overload;
    constructor Create(AnClassKey: Integer; AnClass: TClass;
      SubType: string = ''); overload;
    destructor Destroy; override;

    // Добавляет инф-цию о подтипе
    function AddSubType(
      const AnClassKey: Integer; const AFullClassName: TgdcFullClassName;
      const AnClassReference: TClass): Integer;

    // Возвращает инф-цию о подтипе по имени
    function  GetSubTypeMethodItem(const SubType: String): TCustomMethodClass;
  end;

  // Класс для хранения списка методов
  TMethodList3 = class(TObjectList)
  private
    function GetMethodName(Index: Integer): String;
    function GetItem(Index: Integer): TMethodItem;
    procedure SetMethodName(Index: Integer; const Value: String);
    function GetNameItem(const AName: String): TMethodItem;
  public
    constructor Create; overload;
    destructor  Destroy; override;

    // Добавляет метод
    function Add(const ASource: TMethodItem): Integer; overload;
    function Add(
      const AName: String; const AFuncKey: Integer; const ADisable: Boolean;
      const AMethodClass: TCustomMethodClass): Integer; overload;
    function Last: TMethodItem;
    procedure Assign(ASource: TMethodList);
    function Find(const AName: String): TMethodItem;

    property Items[Index: Integer]: TMethodItem read GetItem;
    property ItemByName[const AName: String]: TMethodItem read GetNameItem;
    property Name[Index: Integer]: String read GetMethodName write SetMethodName;
  end;

  TMethodList = class(TObject)
  private
    FMethodList: TStrings;

    function GetMethodName(Index: Integer): String;
    function GetItem(Index: Integer): TMethodItem;
    procedure SetMethodName(Index: Integer; const Value: String);
    function GetNameItem(const AName: String): TMethodItem;
    function GetCount: Integer;
  public
    constructor Create; overload;
    destructor  Destroy; override;

    // Добавляет метод
    function Add(const ASource: TMethodItem): Integer; overload;
    function Add(
      const AName: String; const AFuncKey: Integer; const ADisable: Boolean;
      const AMethodClass: TCustomMethodClass): Integer; overload;
    function Find(const AName: String): TMethodItem;
    procedure Assign(ASource: TMethodList);
    procedure Clear;

    property Items[Index: Integer]: TMethodItem read GetItem;
    property ItemByName[const AName: String]: TMethodItem read GetNameItem;
    property Name[Index: Integer]: String read GetMethodName write SetMethodName;
    property Count: Integer read GetCount;
  end;

  //Список классов с подтипами
  TMethodClassList = class(TObject)
  private
    FHashMethodClassList: TStringHashMap;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    // Добавляет класс в список
    function AddClass(const AnClassKey: Integer; const AnFullClassName: TgdcFullClassName;
      const AnClassReference: TClass): TCustomMethodClass;
    // Считывает из базы
    procedure LoadFromDatabase(AnDatabase: TIBDatabase;
     AnTransaction: TIBTransaction; const AnParent: Variant);
    // Очищает список классов
    procedure MethodClassListClear;
    // Возращает TCustomMethodClass для класса
    function  FindClass(const AnFullClassName: TgdcFullClassName): TCustomMethodClass;
  end;

  // Класс используется для организации элемента кэша
  // поиска и вызова перекрытых методов
  TmtdCacheItem = class(TObject)
  private
    FOwnerItem: TmtdCacheItem;
    FMethodPresent: Boolean;
    FFullClassName: TgdcFullClassName;
    FIsRealize: Boolean;
    FDisable: Boolean;
    FScriptFunction: TrpCustomFunction;
    procedure SetOwnerItem(const Value: TmtdCacheItem);
    procedure SetMethodPresent(const Value: Boolean);
    procedure SetFullClassName(const Value: TgdcFullClassName);
    procedure SetDisable(const Value: Boolean);
    procedure SetScriptFunction(const Value: TrpCustomFunction);
  public
    destructor Destroy; override;

    // Указатель на объект TrpCustomFunction для данного класса
    property ScriptFunction: TrpCustomFunction read FScriptFunction write SetScriptFunction;
    // Полное имя класса
    property FullClassName: TgdcFullClassName read FFullClassName write SetFullClassName;
    // Указатель на элемент кэша родителя данного класса
    property OwnerItem: TmtdCacheItem read FOwnerItem write SetOwnerItem;
    // Истина, если для данного класса имеется метод в Делфи и нет скрипт-метода
    property MethodPresent: Boolean read FMethodPresent write SetMethodPresent default False;
    // Указывает отключен метод или нет
    property Disable: Boolean read FDisable write SetDisable;
  end;

  // Класс для организации кэша быстрого вызова перекрытых методов.
  // Хранит инф-цию для классов с подтипами для одного метода.
  TmtdCache = class(TObject)
  private
    FHashItemList: TStringHashMap;
    FMethodListName: String;

    function  GetCacheItem(const AFullClassName: TgdcFullClassName): TmtdCacheItem;
    function  FullClassNameToStr(const AFullClassName: TgdcFullClassName): String;
  public
    constructor Create(const AMethodName: String);
    destructor Destroy; override;

    // Добавляет информацию о классе в кэш
    // (AChildClassName - имя предыдущего класса в стеке вызавов объекта)
    function AddClass(const AFullClassName, AChildClassName: TgdcFullClassName;
      AScriptFuncion: TrpCustomFunction; const MethodPresent: Boolean): TmtdCacheItem;
    // Имя кэшировонного метода.
    property MethodListName: String read FMethodListName;
  end;

  TMethodControl = class(TComponent, IMethodControl)
  private
    // хранит список классов с методами
    FMethodClassList: TMethodClassList;         // Список -//-

    FDatabase: TIBDatabase;                     // Датабэйз. Задается из вне
    FTransaction: TIBTransaction;               // Транзакция. Создается внутри
    FLocState: Integer;
    FLocStateDB: Boolean;
    FLocStateTR: Boolean;
    // Хранит кэш для быстрого вызова перекрытых методов
    // Ключ - соответстует ключу метода,
    // объект списка - объект класса TmtdCache
    FmtdCacheList: TgdKeyObjectAssoc;

    // Методы для организации кэша быстрых вызавов перекрытых методов
    function  GetmtdCacheIndex(const AnMethodKey: Integer; const AMethodName: String): Integer;
    function  GetmtdCacheByIndex(const Index: Integer): TmtdCache;
    function  GetmtdCacheItem(const ACurrentFullName: TgdcFullClassName;
      const mtdCacheIndex: Integer): TmtdCacheItem;
    // Добавляет в кэш данные о классе и методе
    function AddClassInmtdCache(const AFullClassName, AFullChildName: TgdcFullClassName;
      const mtdCacheIndex: Integer; AScriptFunction: TrpCustomFunction; const MethodPresent: Boolean): TmtdCacheItem;

    procedure SetDatabase(const AnDatabase: TIBDatabase);

    // Возвращает тип объекта
    function  GetClassType(const AnObject: TObject): TmtdClassType;
    // Проверяет регистрацию класса, если класс не зарегистрирован
    // то False
    function  VerifyingClass(
      const FullClassName: TgdcFullClassName; const ClassType: TmtdClassType): Boolean;
    function GetSubType(
      const AnObject: TObject; const ClassType: TmtdClassType): String;
    function GetParentClassName(
      const FullClassName: TgdcFullClassName; const ClassType: TmtdClassType): String;
    // Функция для реализации Inherited Method
    // ALastCallClass - стек вызава методов; AgdcBase - бизнес-объект;
    // AClassName, AnMethodName - имя класса и метода, откуда вызван ExecuteMethod
    // AnParams, AnResult - массивы вариантных параметров для выполнения
    // макроса и результат
    function ExecuteMethodNew(AClassMethodAssoc: TgdKeyIntAndStrAssoc;
      AgdcBase: TObject; const AClassName, AMethodName: String; const AnMethodKey: Integer;
      var AnParams, AnResult: Variant): Boolean;

    function  FindCustomMethodClass(const AnFullClassName: TgdcFullClassName): TCustomMethodClass;

    procedure PrepareSourceDatabase;
    procedure UnPrepareSourceDatabase;
    procedure SaveDisableFlag(AMethodItem: TMethodItem); overload;
    procedure SaveDisableFlag(const ID: Integer; const DisableFlag: Boolean); overload;
  protected
    // Инициализация
    procedure LoadLists;
    function  FindMethodClass(const AnFullClassName: TgdcFullClassName): TObject;
    function AddClass(const AnClassKey: Integer; const AnFullClassName: TgdcFullClassName;
      const AnClassReference: TClass): TObject;// overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Drop;

    // Очищает кэш для данного метода
    // Должно вызываться при удалении и добавлении скрипт-методов
    procedure  ClearMacroCache;

    property MethodClassList: TMethodClassList read FMethodClassList
      write FMethodClassList;
  published
    property Database: TIBDatabase read FDatabase write SetDatabase;
  end;

procedure Register;

const
  MSG_WRONG_SREAM_DATA = 'Wrong stream data';

{$IFDEF DEBUGMTD}
var
  MethodItemCount: Integer;
  CustomMethodClassCount: Integer;
  MethodClassCount, MethodListCount, MethodClassListCount: Integer;

{$ENDIF}


implementation

uses
  IBSQL, gd_SetDatabase, gdcOLEClassList,
  rp_ReportScriptControl, gd_i_ScriptFactory, gd_ClassList, prp_dlgScriptError_unit,
  Controls, gs_Exception, gdc_createable_form, Windows, {prp_dlgViewProperty_unit,}
  gd_Security, forms;

var
  LocalSubTypeList: TStrings;

{ TMethodItem }

procedure Register;
begin
  RegisterComponents('gsReport', [TMethodControl]);
end;

procedure TMethodItem.Assign(ASource: TMethodItem);
begin
  FCustomName := ASource.Name;
  FMethodData := ASource.MethodData;
  FFunctionKey := ASource.FunctionKey;
  FDisable := ASource.Disable;
  FMethodId := ASource.MethodId;
  FMethodClass := ASource.FMethodClass;
end;

function TMethodItem.AutoFunctionName: String;
begin
  if Assigned(FMethodClass) then
    Result := FMethodClass.Class_Name + FMethodClass.SubType;
  Result := Result + Name;
end;

constructor TMethodItem.Create;
begin
  inherited;

  FDisable := False;
  {$IFDEF DEBUGMTD}
  Inc(MethodItemCount);
  {$ENDIF}

end;

destructor TMethodItem.Destroy;
begin
  {$IFDEF DEBUGMTD}
  Dec(MethodItemCount);
  {$ENDIF}
  inherited;
end;

function TMethodItem.GetComplexParams(const AnLang: TFuncParamLang): String;
var
  LFN, LFR, LFB, LFE, LFP: String;
  LResultParam: String;
  InheritedDim, InheritedSender: String;
  InheritedParam, InheritedArray: String;
  CallInherited: String;
  Comment, EndComment: String;
  I: Integer;
  OptExplicit: string;
const
  InheritedComment = '%s*** Данный код необходим для вызова кода определенного в gdc-классе.***'#13#10 +
                     '%s*** При его удаления  возможно нарушение  правильной работы системы.***';
  InheritedEndComment =
                     '%s***               Конец кода поддержки gdc-класса.                  ***';
begin
  Result := '';
  if not Assigned(FMethodData) then
    Exit;

  LFR := '';
  LFP := GetDelphiParamString(FMethodData^.ParamCount, FMethodData^.ParamList,
   AnLang, LResultParam);
  case FMethodData^.MethodKind of
    mkSafeFunction, mkFunction:
    begin
      LFN := 'function';
      case AnLang of
        fplDelphi: LFR := ': ' + LResultParam + ';';
        fplJScript, fplVBScript: LFR := '';
      else
        raise Exception.Create(GetGsException(Self, 'Unknown language type.'));
      end;
    end;
    mkSafeProcedure, mkProcedure:
      case AnLang of
        fplDelphi:
        begin
          LFN := 'procedure';
          LFR := ';';
        end;
        fplJScript: LFN := 'function';
        fplVBScript: LFN := 'sub';
      else
        raise Exception.Create(GetGsException(Self, 'Unknown language type.'));
      end;
  else
    raise Exception.Create(GetGsException(Self, 'This kind of method isn''t supported.'));
  end;
  InheritedDim := '';
  InheritedSender := '';
  InheritedParam := '';
  InheritedDim := '';
  CallInherited := '';
  Comment := '';
  EndComment := '';
  OptExplicit := '';

  case AnLang of
    fplDelphi:
    begin
      LFB := 'begin';
      LFE := 'end;';
    end;
    fplJScript:
    begin
      LFB := '{'#13#10;
      LFE := '}';
      InheritedArray := 'Array(' +
        GetDelphiParamName(0, FMethodData^.ParamList, AnLang, LResultParam);

      for I := 1 to FMethodData^.ParamCount - 1 do
      begin
        InheritedArray := InheritedArray + ', ' +
          GetDelphiParamName(i, FMethodData^.ParamList, AnLang, LResultParam);
      end;
      InheritedArray := InheritedArray + ')';

      case FMethodData^.MethodKind of
        mkSafeFunction, mkFunction:
          CallInherited := '  ' + AutoFunctionName + ' = _'#13#10 + '    ';
        mkSafeProcedure, mkProcedure:
          CallInherited := '  ';
      end;

      CallInherited := CallInherited + 'Inherited(' + GetDelphiParamName(0, FMethodData^.ParamList,
        AnLang, LResultParam) + ', ' + '"' + Name + '", ' + InheritedArray + ')';
      Comment := Format(InheritedComment, ['//', '//', '//']);
      EndComment := Format(InheritedEndComment, ['//']);
    end;
    fplVBScript:
    begin
      OptExplicit := 'option explicit'#13#10;
      LFB := '';
      LFE := 'end ' + LFN;
      InheritedArray := 'Array(' +
        GetDelphiParamName(0, FMethodData^.ParamList, AnLang, LResultParam);

      for I := 1 to FMethodData^.ParamCount - 1 do
      begin
        InheritedArray := InheritedArray + ', ' +
          GetDelphiParamName(i, FMethodData^.ParamList, AnLang, LResultParam);
      end;
      InheritedArray := InheritedArray + ')';

      case FMethodData^.MethodKind of
        mkSafeFunction, mkFunction:
        begin
          if AnsiUpperCase(GetResultType(FMethodData^.ParamCount,
            FMethodData^.ParamList)) = 'OBJECT' then
              CallInherited := '  set ' + AutoFunctionName + ' = _'#13#10 + '    '
          else
            CallInherited := '  ' + AutoFunctionName + ' = _'#13#10 + '    ';
        end;
        mkSafeProcedure, mkProcedure:
          CallInherited := '  call ';
      end;
      CallInherited := CallInherited + 'Inherited(' + GetDelphiParamName(0, FMethodData^.ParamList,
        AnLang, LResultParam) + ', ' + '"' + Name + '", ' + InheritedArray + ')';

      Comment := Format(InheritedComment, ['''', '''', '''']);
      EndComment := Format(InheritedEndComment, ['''']);
    end;
  else
    raise Exception.Create(GetGsException(Self, 'Unknown language type.'));
  end;
  Result := OptExplicit + LFN + ' ' + AutoFunctionName + '(' + LFP +
    ')' + LFR + #13#10 + LFB + Comment + #13#10 + InheritedDim +
    InheritedSender + InheritedParam + CallInherited + #13#10 +
    EndComment + #13#10 + LFE;
end;

function TMethodItem.GetDelphiParamName(const Index: Integer;
  const LocParams: array of Char; const AnLang: TFuncParamLang;
  out AnResultParam: String): String;
var
  L: Integer;
  I: Integer;
begin
  Result := '';
  L := 1;
  for I := 0 to Index - 1 do
  begin
    L := L + Byte(LocParams[L]) + 1;
    L := L + Byte(LocParams[L]) + 1;
    Inc(L);
  end;
  Result := Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));
end;

function TMethodItem.GetDelphiParamString(const LocParamCount: Integer;
 const LocParams: array of Char; const AnLang: TFuncParamLang;
 out AnResultParam: String): String;
var
  K, L: Integer;
begin
  Result := '';
  K := 0;
  L := 0;
  while K < LocParamCount do
  begin
    case Byte(LocParams[L]) and 39 of
      1:
      case AnLang of
        fplDelphi:
          Result := Result + 'var ';
        fplVBScript:
          Result := Result + 'ByRef ';
      end;
      2:
      case AnLang of
        fplDelphi:
          Result := Result + 'const ';
      end;
      4:
      case AnLang of
        fplDelphi:
          Result := Result + 'array of ';
      end;
      32:
      case AnLang of
        fplDelphi:
          Result := Result + 'out ';
        fplVBScript:
          Result := Result + 'ByRef ';
      end;
    else
      case AnLang of
        fplVBScript:
          Result := Result + 'ByVal ';
      end;
    end;

    // Copy Param Name
    Inc(L);
    Result := Result + Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));

    // Copy Param Type
    L := L + Byte(LocParams[L]) + 1;
    if AnLang = fplDelphi then
      Result := Result + ': ' + Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));

    // Add ';' if needed
    if K < LocParamCount - 1 then
      case AnLang of
        fplDelphi:
          begin
            Result := Result + '; ';
          end;
        fplVBScript, fplJScript:
          begin
            Result := Result + ', ';
          end;
      end;

    // Set position
    L := L + Byte(LocParams[L]) + 1;

    Inc(K);
  end;
  AnResultParam := Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));
end;

{function TMethodItem.GetObjectName: String;
begin
  Result := '';
  if Assigned(FMethodClass) then
    Result := FMethodClass.Class_Name + FMethodClass.SubType;
end;}

{function TMethodItem.GetParamCount: Integer;
begin
  Result := FMethodData^.ParamCount;
end;

function TMethodItem.GetParams(const AnLang: TFuncParamLang): String;
var
  LResultParam: String;
begin
  Result := GetDelphiParamString(FMethodData^.ParamCount, FMethodData^.ParamList,
   AnLang, LResultParam);
end;}

function TMethodItem.GetResultType(const Index: Integer;
  const LocParams: array of Char): String;
var
  L: Integer;
  I: Integer;
begin
  Result := '';
  L := 1;
  for I := 0 to Index - 1 do
  begin
    L := L + Byte(LocParams[L]) + 1;
    L := L + Byte(LocParams[L]) + 1;
    Inc(L);
  end;
  Result := PChar(@LocParams[L]);
end;

procedure TMethodItem.SetDisable(const Value: Boolean);
begin
  FDisable := Value;
end;

procedure TMethodItem.SetMethodClass(const Value: TCustomMethodClass);
begin
  FMethodClass := Value;
end;

procedure TMethodItem.SetMethodId(const Value: Integer);
begin
  FMethodId := Value
end;

{ TMethodClass }

constructor TMethodClass.Create;
begin
  inherited;

  {$IFDEF DEBUGMTD}
  Inc(MethodClassCount);
  {$ENDIF}
  FSubTypeMethodList := TStringList.Create;
  FSubTypeMethodList.Sorted := True;
  FClass_Key := 0;
  FSubType := '';
  FSpecDisableMethod := 0;
end;

destructor TMethodClass.Destroy;
var
  i: integer;
begin
  if Assigned(FSubTypeMethodList) then
  begin
    for i := 0 to FSubTypeMethodList.Count - 1 do
      FSubTypeMethodList.Objects[i].Free;
    FSubTypeMethodList.Free;
  end;

  {$IFDEF DEBUGMTD}
  Dec(MethodClassCount);
  {$ENDIF}
  inherited;
end;

constructor TMethodClass.Create(AnClassKey: Integer; AnClass: TClass;
  SubType: string = '');
begin
  Create;

  FClass_Key := AnClassKey;
  Class_Name := AnClass.ClassName;
  FClass_Reference := AnClass;
  FSubType := SubType;
end;

function TMethodClass.GetSubTypeMethodItem(
  const SubType: String): TCustomMethodClass;
var
  i: Integer;
  LSubType: String;
begin
  Result := nil;
  LSubType := ChangeIncorrectSymbol(SubType);
  i := FSubTypeMethodList.IndexOf(LSubType);
  if i > -1 then
    Result := GetSubTypeItemByIndex(i);
end;

function TMethodClass.GetSubTypeItemByIndex(
  const Index: Integer): TCustomMethodClass;
begin
  Result := TCustomMethodClass(FSubTypeMethodList.Objects[Index]);
end;

{ TMethodList }

function TMethodList3.Add(const ASource: TMethodItem): Integer;
begin
  Result := inherited Add(TMethodItem.Create);
  if Assigned(ASource) then
    Last.Assign(ASource);
end;

function TMethodList3.Add(
  const AName: String; const AFuncKey: Integer;
  const ADisable: Boolean; const AMethodClass: TCustomMethodClass): Integer;
begin
  Result := Add(nil);
  Last.Name := AName;
  Last.FunctionKey := AFuncKey;
  Last.Disable := ADisable;
  Last.MethodClass := AMethodClass;
end;

procedure TMethodList3.Assign(ASource: TMethodList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    Add(ASource.Items[I]);
end;

function TMethodList3.Find(const AName: String): TMethodItem;
begin
  Result := ItemByName[AName];
end;

function TMethodList3.GetMethodName(Index: Integer): String;
begin
  Result := Items[Index].Name;
end;

function TMethodList3.GetItem(Index: Integer): TMethodItem;
begin
  Result := TMethodItem(inherited Items[Index]);
end;

function TMethodList3.GetNameItem(const AName: String): TMethodItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiUpperCase(Name[I]) = AnsiUpperCase(AName) then
    begin
      Result := Items[I];
      Break;
    end;
end;

function TMethodList3.Last: TMethodItem;
begin
  Result := TMethodItem(inherited Last);
end;

procedure TMethodList3.SetMethodName(Index: Integer; const Value: String);
begin
  Items[Index].Name := Value;
end;

constructor TMethodControl.Create(AOwner: TComponent);
begin
  Assert(MethodControl = nil, 'This component can be only one.');

  inherited Create(AOwner);

  FMethodClassList := nil;
  FTransaction := nil;
  FLocState := 0;

  if not (csDesigning in ComponentState) then
  begin
    FmtdCacheList := TgdKeyObjectAssoc.Create(True);

    FTransaction := TIBTransaction.Create(Self);
    FTransaction.Params.Add('read_committed');
    FTransaction.Params.Add('rec_version');
    FTransaction.Params.Add('nowait');

    FMethodClassList := TMethodClassList.Create;
  end;

  MethodControl := Self;
end;

destructor TMethodControl.Destroy;
begin
  FmtdCacheList.Free;
  FreeAndNil(FMethodClassList);
  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);

  MethodControl := nil;

  inherited Destroy;
end;

procedure TMethodControl.LoadLists;
begin
  FMethodClassList.LoadFromDatabase(FDatabase, FTransaction, NULL);
end;

procedure TMethodControl.SetDatabase(const AnDatabase: TIBDatabase);
begin
  if AnDatabase <> FDatabase then
  begin
    FDatabase := AnDatabase;
    if Assigned(FTransaction) then
      FTransaction.DefaultDatabase := FDatabase;
  end;
end;

{TMethodClassList}

function TMethodClassList.AddClass(
  const AnClassKey: Integer; const AnFullClassName: TgdcFullClassName;
  const AnClassReference: TClass): TCustomMethodClass;
var
  i: Integer;
  LMethodClass: TMethodClass;
begin
  // если класс не найден, то добавляем его
  if not FHashMethodClassList.Find(AnFullClassName.gdClassName, LMethodClass) then
  begin
    LMethodClass := TMethodClass.Create;
    FHashMethodClassList.Add(AnFullClassName.gdClassName, LMethodClass);
  end;

  if LMethodClass.Class_Name = '' then
    LMethodClass.Class_Name := AnFullClassName.gdClassName;
  if LMethodClass.Class_Reference = nil then
    LMethodClass.Class_Reference := AnClassReference;

  // если если подтип, то добавляем подтип
  // если нет подтипа, то добавляется класс, следовательно заполняем ключ класса
  if Trim(AnFullClassName.SubType) <> '' then
  begin
    i := LMethodClass.AddSubType(AnClassKey, AnFullClassName, AnClassReference);
    Result := LMethodClass.GetSubTypeItemByIndex(i);
  end else
    begin
      LMethodClass.Class_Key := AnClassKey;
      Result := LMethodClass;
    end;
end;

procedure TMethodClassList.Clear;
begin
  MethodClassListClear;
end;

constructor TMethodClassList.Create;
begin
  inherited;
  {$IFDEF DEBUGMTD}
  Inc(MethodClassListCount);
  {$ENDIF}

  FHashMethodClassList := TStringHashMap.Create(CaseInSensitiveTraits, 512);
end;

destructor TMethodClassList.Destroy;
begin
  Clear;
  FHashMethodClassList.Free;

  {$IFDEF DEBUGMTD}
  Dec(MethodClassListCount);
  {$ENDIF}

  inherited;
end;

function TMethodClassList.FindClass(const AnFullClassName: TgdcFullClassName): TCustomMethodClass;
var
  LMethodClass: TMethodClass;
begin
  if FHashMethodClassList.Find(AnFullClassName.gdClassName, LMethodClass) then
  begin

    if Trim(AnFullClassName.SubType) <> '' then
    begin
      Result := LMethodClass.GetSubTypeMethodItem(AnFullClassName.SubType);
    end else
      Result := LMethodClass;
  end else
    Result := nil;

end;

procedure TMethodClassList.LoadFromDatabase(AnDatabase: TIBDatabase;
  AnTransaction: TIBTransaction; const AnParent: Variant);
var
  ibsqlClass: TIBSQL;
  LMethodClass: TCustomMethodClass;
  LFullClassName: TgdcFullClassName;
  LMethodItem: TMethodItem;
  i: Integer;
begin
  MethodClassListClear;
  ibsqlClass := TIBSQL.Create(nil);
  try
    ibsqlClass.Transaction := gdcBaseManager.ReadTransaction;
    {Сволочь такая не работает с NULL параметром} {gs}

    ibsqlClass.SQL.Text :=
      ' SELECT e.*, oe.id AS methodid, oe.eventname as methodname, ' +
      ' oe.functionkey, oe.disable ' +
      ' FROM evt_object e LEFT JOIN evt_objectevent oe ON e.id = ' +
      ' oe.objectkey WHERE classname > '''' ORDER BY e.lb, e.classname, oe.eventname';
    ibsqlClass.ExecQuery;

    while not ibsqlClass.Eof do
    begin
      LFullClassName.gdClassName :=
        ibsqlClass.FieldByName('classname').AsString;
      LFullClassName.SubType :=
        ibsqlClass.FieldByName('subtype').AsString;
      LMethodClass := FindClass(LFullClassName);

      if LMethodClass = nil then
      begin
        LMethodClass := Self.AddClass(
          ibsqlClass.FieldByName('id').AsInteger,
          LFullClassName, nil);
      end;

      i := LMethodClass.MethodList.Add(
        ibsqlClass.FieldByName('methodname').AsString,
        ibsqlClass.FieldByName('FunctionKey').AsInteger,
        (ibsqlClass.FieldByName('Disable').AsInteger <> 0), LMethodClass);
      LMethodItem := LMethodClass.MethodList.Items[i];
      LMethodItem.MethodClass := LMethodClass;
      LMethodItem.MethodId :=
        ibsqlClass.FieldByName('methodid').AsInteger;

      ibsqlClass.Next;
    end;
  finally
    ibsqlClass.Free;
  end;
end;

{procedure TMethodClassList.LoadFromStream(AnStream: TStream);
var
  I, J: Integer;
  strTemp: array[0..SizeOf(strStartClassList)] of Char;
begin
  MethodClassListClear;
  AnStream.ReadBuffer(strTemp, SizeOf(strStartObjList));
  if strTemp <> strStartClassList then
    raise Exception.Create(GetGsException(Self, MSG_WRONG_SREAM_DATA));

  AnStream.ReadBuffer(J, SizeOf(J));
  for I := 0 to J - 1 do
    MethodClass[AddClass(TMethodClass.Create)].LoadFromStream(AnStream);

  AnStream.ReadBuffer(strTemp, SizeOf(strStartClassList));
  if strTemp <> strEndClassList then
    raise Exception.Create(GetGsException(Self, MSG_WRONG_SREAM_DATA));
end;}

procedure TMethodClassList.MethodClassListClear;
begin
  FHashMethodClassList.Iterate(nil, Iterate_FreeObjects);
  FHashMethodClassList.Clear;
end;

function TMethodControl.ExecuteMethodNew(
  AClassMethodAssoc: TgdKeyIntAndStrAssoc; AgdcBase: TObject;
  const AClassName, AMethodName: String; const AnMethodKey: Integer; var AnParams,
  AnResult: Variant): Boolean;
var
  LMethodClass: TCustomMethodClass;
  LMethodItem: TMethodItem;
  LFunction: TrpCustomFunction;
  AnObjectClassName: string;
  Index, k, mtdCacheIndex: Integer;
  //SubTypeList: TStrings;
  tmpStackStrings: TStackStrings;
  ObjectSubType: String;
  SubTypePresent{, IsGdcBase}: Boolean;
  LClassName: String;
  LmtdCacheItem: TmtdCacheItem;
  LFullClassName_: TgdcFullClassName;
  TmpFullClassName_: TgdcFullClassName;
  // указывает, что информации для данного класса нет в
  // кэше и надо сделать поиск скрипт-методов.
  FullFindFlag: Boolean;
  LCurrentFullClass, LFullChildName: TgdcFullClassName;
  LClassType: TmtdClassType;
  LgdcCreateableFormClass: CgdcCreateableForm;
  LgdcBaseClass: CgdcBase;
const
  LMsgMethodUserError =
                  'Метод %s для класса %s вызвал ошибку.'#13#10 +
                  'Ключ скрипт-функции - %d.'#13#10 +
                  'Обратитесь к администратору.';
  LMsgMethodOffAdmin =
                  'Метод %s для класса %s, вызвавший ошибку, не исправлен.'#13#10 +
                  'Ключ скрипт-функции - %d.'#13#10 +
                  'Отключить метод?';

  function GetSubTypeFromStr(const FullSubTypeStr: String): String;
  begin
    Result := Trim(Copy(FullSubTypeStr, Pos('=', FullSubTypeStr) + 1,
      Length(FullSubTypeStr)));
  end;

begin
  Result := False;
  LFunction := nil;
  LClassName := UpperCase(Trim(AClassName));

  mtdCacheIndex := GetmtdCacheIndex(AnMethodKey, AMethodName);

  LClassType := GetClassType(AgdcBase);
  LCurrentFullClass.gdClassName := '';
  LCurrentFullClass.SubType := '';
  AnObjectClassName := UpperCase(AgdcBase.ClassName);
  // стек есть всегда, но он может быть пустой
  Index := AClassMethodAssoc.IndexOf(AnMethodKey);
  if AClassMethodAssoc.IntByKey[AnMethodKey] = 0 then
  begin
    LFullClassName_.gdClassName := AnObjectClassName;
    if not VerifyingClass(LFullClassName_, LClassType) then
    begin
      {$IFDEF DEBUG}
      raise Exception.Create('Класс ' + AnObjectClassName + ' не зарегистрирован в gdcClassList!!!');
      {$ENDIF}
      exit;
    end;

    AClassMethodAssoc.IntByIndex[Index] := Integer(TStackStrings.Create);
    // добавляем список для классов (удаляться он будет вместе объектом)
    tmpStackStrings := TStackStrings(AClassMethodAssoc.IntByIndex[Index]);
  end else
    begin
      tmpStackStrings := TStackStrings(AClassMethodAssoc.IntByIndex[Index]);
      if not tmpStackStrings.IsEmpty then
        LCurrentFullClass := tmpStackStrings.LastClass;
    end;

  LMethodItem := nil;

  ObjectSubType := GetSubType(AgdcBase, LClassType);
  // в цикле поиск скрипт-метода, согласно принципу Inherited, или, если макрос
  // не найден, возврат в метод Делфи
  // если класс без подтипа, то и ищем без подтипа и наоборот

  FullFindFlag := True;
  // проверяем наличие кэша быстрого вызова для данного класса
  if LCurrentFullClass.gdClassName = '' then
  begin
    TmpFullClassName_.gdClassName := AgdcBase.ClassName;
    TmpFullClassName_.SubType := ObjectSubType;
    LmtdCacheItem := GetmtdCacheItem(TmpFullClassName_, mtdCacheIndex)
  end else
    begin
      LmtdCacheItem := TmtdCacheItem(tmpStackStrings.LastObject);
      if Assigned(LmtdCacheItem) then
        LmtdCacheItem := LmtdCacheItem.OwnerItem;
    end;

  // если есть кэш, то поиск не осуществяем
  if Assigned(LmtdCacheItem) then
  begin
    FullFindFlag := False;
    LFunction := nil;
    repeat
      // добавляем инфомацию о полном классе и методе в стек
      LCurrentFullClass := LmtdCacheItem.FullClassName;
      tmpStackStrings.AddObject(LCurrentFullClass, LmtdCacheItem);
      if Assigned(LmtdCacheItem.ScriptFunction) and (not LmtdCacheItem.Disable) then
      begin
        // если для полного класса определена скрипт-функция и она не отключена,
        // то идем на выполнение скрипт-метода
        LFunction := LmtdCacheItem.ScriptFunction;
        Break;
      end else
        // если скрипт-метод не определен, проверяем определен ли для класса
        // метод в Делфи, если да, то идем на выход.
        if LmtdCacheItem.MethodPresent then
        begin
          Break;
        end;
      // получаем следующий элемент кэша для данного объекта в иерархии класс
      LmtdCacheItem := LmtdCacheItem.OwnerItem;
    until (LmtdCacheItem = nil);
  end;

  if (LmtdCacheItem = nil) and
    (LCurrentFullClass.gdClassName <> LClassName) then
  begin
    FullFindFlag := True;
  end;

  if FullFindFlag then
  begin
      // поиск скрипт-метода для объекта без подтипа
    repeat
      LFullChildName.gdClassName := '';
      LFullChildName.SubType := '';
      if ObjectSubType = '' then
      begin
        // получаем текущее полное имя класса для объекта без подтипа
        // Если LCurrentClass = '', то текущей класс - это класс объекта,
        // иначе это родительский класс последнего класса в стеку вызовов.
        if LCurrentFullClass.gdClassName = '' then
        begin
          LCurrentFullClass.gdClassName := AnObjectClassName;
        end else
          begin
            LFullChildName := LCurrentFullClass;
            LCurrentFullClass.gdClassName :=
              AnsiUpperCase(GetParentClassName(LCurrentFullClass, LClassType));
          end;
      end else
        begin
          // получаем текущее полное имя класса для объекта с подтипом
          if LCurrentFullClass.gdClassName = '' then
          begin
            // полное имя класса
            LCurrentFullClass.gdClassName := AnObjectClassName;
            LCurrentFullClass.SubType := ObjectSubType;
          end else
            begin
              if LCurrentFullClass.SubType <> '' then
              begin
                LFullChildName := LCurrentFullClass;
                // Если в последнем в стеке полном имени класса есть подтип, то
                // текущий полный класс - это тот-же полный класс без подтипа
                LCurrentFullClass.SubType := '';
              end else
                begin
                  // Если последний обработанный класс без подтипа, то получаем
                  // класс родителя, проверяем для него наличия подтипа объект.
                  // Если подтип для класса родителя определен, то текущий
                  // полный класс - класс родителя + подтип, иначе только класс
                  // родителя
                  LFullChildName := LCurrentFullClass;
                  LCurrentFullClass.gdClassName :=
                    AnsiUpperCase(GetParentClassName(LCurrentFullClass, LClassType));
                  {SubTypeList := TStringList.Create;
                  try}
                    if AgdcBase.InheritsFrom(TgdcBase) then
                    begin
                      LgdcBaseClass := gdcClassList.GetGDCClass(LCurrentFullClass);
                      if LgdcBaseClass = nil then
                        raise Exception.Create('Ошибка перекрытия метода. Обратитесь к разработчикам.');
                      SubTypePresent := LgdcBaseClass.GetSubTypeList(LocalSubTypeList);
                    end else
                      begin
                        LgdcCreateableFormClass := frmClassList.GetFRMClass(LCurrentFullClass);
                        if LgdcCreateableFormClass = nil then
                          raise Exception.Create('Ошибка перекрытия метода. Обратитесь к разработчикам.');
                        SubTypePresent := LgdcCreateableFormClass.GetSubTypeList(LocalSubTypeList);
                      end;


                    if SubTypePresent then
                    begin
                      for k := 0 to LocalSubTypeList.Count - 1 do
                        if ObjectSubType =
                          AnsiUpperCase(GetSubTypeFromStr(LocalSubTypeList[k])) then
                        begin
                          LCurrentFullClass.SubType := ObjectSubType;
                          break;
                        end;
                    end;
                  {finally
                    SubTypeList.Free;
                  end;}
                end;
            end;
        end;

      try
        // Получаем элемент кэша быстрого вывова для полного класса.
        // Далее по мере поступления информации для данного полного класса
        // заносим ее в этот элемент.
        LmtdCacheItem := AddClassInmtdCache(LCurrentFullClass, LFullChildName,
          mtdCacheIndex, nil, False);
        // Добавляем информацию об обработке в срек вызовов объекта.
        tmpStackStrings.AddObject(LCurrentFullClass, LmtdCacheItem);
      except
        {$IFDEF DEBUG}
        Beep(1000, 100);
        {$ELSE}
        raise;
        {$ENDIF}
      end;

      // Получаем объек, хранящий информацию о скрипт-методах, объявленных для
      // данного полного класса
      LMethodClass := FindCustomMethodClass(LCurrentFullClass);

      // Если данная проверка истина, то для данного класса определен
      // метод в Делфи. Прекращаем поиск.
      if (Length(LCurrentFullClass.SubType) = 0) and
        (LCurrentFullClass.gdClassName = LClassName) then
      begin
        LmtdCacheItem.MethodPresent := True;
      end;

      if not Assigned(LMethodClass) then
      begin
        if LmtdCacheItem.MethodPresent then
          Exit
        else
          Continue;
      end;

      // Получаем объект, хранящий инф-цию для данного метода
      LMethodItem := LMethodClass.MethodList.Find(AMethodName);
      if Assigned(LMethodItem) then
      begin
        LmtdCacheItem.ScriptFunction := glbFunctionList.FindFunction(LMethodItem.FunctionKey);
        LmtdCacheItem.Disable := LMethodItem.Disable;
      end;

      // Если нет инф-ции для данного метода и ключ скрипт-метода = 0 или
      // скрипт-метод отключен, а для данного класса метод определен в Делфи,
      // то прекращаем поиск.
      if ((not Assigned(LMethodItem)) or (LMethodItem.FunctionKey = 0) or
        (LMethodItem.Disable)) and LmtdCacheItem.MethodPresent then
        begin
          Exit;
        end;
    until Assigned(LMethodItem) and (LMethodItem.FunctionKey <> 0) and (not LMethodItem.Disable);
  end;

  // выполнение скрипт-метода, если он обнаружен
  if (Assigned(LMethodItem)) or (Assigned(LFunction)) then
    if Assigned(ScriptFactory) then
    begin
      if LFunction = nil then
        LFunction := glbFunctionList.FindFunction(LMethodItem.FunctionKey);
      if Assigned(LFunction) then
      try
        {$IFDEF DEBUG}
        if UseLog then
          Log.LogLn(DateTimeToStr(Now) + ': Запущен метод ' + LFunction.Name +
            '  ИД функции ' + IntToStr(LFunction.FunctionKey));
        try
        {$ENDIF}
          ScriptFactory.ExecuteFunction(LFunction, AnParams, AnResult);
        {$IFDEF DEBUG}
        except
(*          on E: EErrorScript do
          begin
            // Если возникла ошибка
            // админу возможность отключения, другому пользователю только сообщение об ошибке
            if Not IBLogin.IsIBUserAdmin then
            begin
              MessageBox(0, PChar(Format(LMsgMethodUserError, [AMethodName,
                LCurrentFullClass.gdClassName + LCurrentFullClass.SubType,
                LFunction.FunctionKey])),
                'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
            end else
              if (MessageBox(0, PChar(Format(LMsgMethodOffAdmin, [AMethodName,
                LCurrentFullClass.gdClassName + LCurrentFullClass.SubType,
                LFunction.FunctionKey])),
                'Внимание', MB_YESNO or MB_ICONWARNING or MB_TOPMOST) = IDYES) then
              begin
                LMethodItem.Disable := True;
                SaveDisableFlag(LMethodItem);
//                if Assigned(dlgViewProperty) then
//                  dlgViewProperty.SetMethodView(LMethodItem);
              end;
            Log.LogLn(DateTimeToStr(Now) + ': Ошибка во время выполнения метода ' + LFunction.Name +
              '  ИД функции ' + IntToStr(LFunction.FunctionKey));
            raise EAbort.Create('Ошибка в перекрытом методе ' + LFunction.Name);
          end
        else
          begin*)
          Log.LogLn(DateTimeToStr(Now) + ': Ошибка во время выполнения метода ' + LFunction.Name +
            '  ИД функции ' + IntToStr(LFunction.FunctionKey));
          raise;
//          end;
        end;
        {$ENDIF}
        Result := True;
      finally
        glbFunctionList.ReleaseFunction(LFunction);
      end
      else
        Result := False;
    end
    else
      raise Exception.Create(GetGsException(Self, 'Класс ScriptFactory не создан'));
end;

procedure TMethodControl.SaveDisableFlag(AMethodItem: TMethodItem);
var
  LIBSQL: TIBSQL;
begin
  LIBSQL := TIBSQL.Create(nil);
  try
    LIBSQL.Database := FDatabase;
    LIBSQL.Transaction := FTransaction;
    PrepareSourceDatabase;
    try
      LIBSQL.SQL.Text := 'UPDATE evt_objectevent ' +
        'SET disable = :disable WHERE ' +
        'objectkey = :objectkey AND UPPER(eventname) = :eventname';
      if AMethodItem.Disable then
        LIBSQL.Params[0].AsInteger := 1
      else
        LIBSQL.Params[0].AsInteger := 0;
      LIBSQL.Params[1].AsInteger := AMethodItem.MethodClass.FClass_Key;
      LIBSQL.Params[2].AsString := AnsiUpperCase(AMethodItem.Name);
      LIBSQL.ExecQuery;
    finally
      UnPrepareSourceDatabase;
    end;
  finally
    LIBSQL.Free;
  end;
end;

procedure TMethodControl.PrepareSourceDatabase;
begin
  if FLocState = 0 then
  begin
    FLocStateDB := FDatabase.Connected;
    FLocStateTR := FTransaction.InTransaction;
    if not FLocStateDB then
      FDatabase.Connected := True;
    if not FLocStateTR then
      FTransaction.StartTransaction;
  end;
  Inc(FLocState);
end;

procedure TMethodControl.UnPrepareSourceDatabase;
begin
  Dec(FLocState);
  if FLocState = 0 then
  begin
    if not FLocStateTR then
      FTransaction.Commit;
    if not FLocStateDB then
      FDatabase.Connected := False;
  end;
end;

constructor TMethodList3.Create;
begin
  inherited;
  OwnsObjects := True;
  {$IFDEF DEBUGMTD}
  Inc(MethodListCount);
  {$ENDIF}
end;

destructor TMethodList3.Destroy;
begin
  {$IFDEF DEBUGMTD}
  Dec(MethodListCount);
  {$ENDIF}
  inherited;
end;

{ TmtdCacheItem }

destructor TmtdCacheItem.Destroy;
begin
  if Assigned(FScriptFunction) and Assigned(glbFunctionList) then
    glbFunctionList.ReleaseFunction(FScriptFunction);
  inherited;                                         
end;

procedure TmtdCacheItem.SetDisable(const Value: Boolean);
begin
  FDisable := Value;
end;

procedure TmtdCacheItem.SetFullClassName(const Value: TgdcFullClassName);
begin
  FFullClassName := Value;
end;

procedure TmtdCacheItem.SetMethodPresent(const Value: Boolean);
begin
  FMethodPresent := Value;
end;

procedure TmtdCacheItem.SetOwnerItem(const Value: TmtdCacheItem);
begin
  FOwnerItem := Value;
end;

function TMethodControl.AddClassInmtdCache(const AFullClassName,
  AFullChildName: TgdcFullClassName;const mtdCacheIndex: Integer; AScriptFunction: TrpCustomFunction;
  const MethodPresent: Boolean): TmtdCacheItem;
var
  LmtdCache: TmtdCache;
begin
  LmtdCache := GetmtdCacheByIndex(mtdCacheIndex);
  Result := LmtdCache.AddClass(AFullClassName, AFullChildName, AScriptFunction, MethodPresent);
end;

function TMethodControl.GetmtdCacheByIndex(const Index: Integer): TmtdCache;
begin
  Result := TmtdCache(FmtdCacheList.ObjectByIndex[Index]);
end;

procedure TmtdCacheItem.SetScriptFunction(const Value: TrpCustomFunction);
begin
  FScriptFunction := Value;
end;

{ TmtdCache }

function TmtdCache.AddClass(const AFullClassName,
  AChildClassName: TgdcFullClassName; AScriptFuncion: TrpCustomFunction;
  const MethodPresent: Boolean): TmtdCacheItem;

  procedure AddOwnerItem(const LOwnerItem: TmtdCacheItem);
  var
    LChildItem: TmtdCacheItem;
  begin
    LChildItem := GetCacheItem(AChildClassName);
    if Assigned(LChildItem) then
      LChildItem.OwnerItem := LOwnerItem;
  end;

begin
  if FHashItemList.Find(FullClassNameToStr(AFullClassName), Result) then
  begin
    AddOwnerItem(Result);
    Result.FIsRealize := True;
  end else
  begin
    Result := TmtdCacheItem.Create;
    Result.FullClassName := AFullClassName;
    Result.ScriptFunction := AScriptFuncion;
    Result.MethodPresent := MethodPresent;
    Result.OwnerItem := nil;
    AddOwnerItem(Result);
    FHashItemList.Add(FullClassNameToStr(AFullClassName), Result);
  end;
end;

constructor TmtdCache.Create(const AMethodName: String);
begin
  Inherited Create;

  FHashItemList := TStringHashMap.Create(CaseInSensitiveTraits, 256);

  FMethodListName := AMethodName;
end;

destructor TmtdCache.Destroy;
begin
  FHashItemList.Iterate(nil, Iterate_FreeObjects);
  FHashItemList.Free;

  inherited;
end;

function TmtdCache.FullClassNameToStr(
  const AFullClassName: TgdcFullClassName): String;
begin
  Result := AFullClassName.gdClassName + AFullClassName.SubType;
end;

function TmtdCache.GetCacheItem(const AFullClassName: TgdcFullClassName): TmtdCacheItem;
begin
  if not FHashItemList.Find(FullClassNameToStr(AFullClassName), Result) then
    Result := nil;
end;

function TMethodControl.GetmtdCacheIndex(
  const AnMethodKey: Integer; const AMethodName: String): Integer;
begin
  Result := FmtdCacheList.IndexOf(AnMethodKey);
  if Result = -1 then
  begin
    Result := FmtdCacheList.Add(AnMethodKey);
    FmtdCacheList.ObjectByIndex[Result] := TmtdCache.Create(AMethodName);
  end;
end;

function TMethodControl.GetmtdCacheItem(const ACurrentFullName: TgdcFullClassName;
  const mtdCacheIndex: Integer): TmtdCacheItem;
var
  LmtdCache: TmtdCache;
begin
  Result := nil;
  LmtdCache := GetmtdCacheByIndex(mtdCacheIndex);
  if not Assigned(LmtdCache) then
    Exit;

  Result := LmtdCache.GetCacheItem(ACurrentFullName);
end;

procedure TMethodControl.ClearMacroCache;
begin
  FmtdCacheList.Clear;
end;

function TMethodControl.FindMethodClass(
  const AnFullClassName: TgdcFullClassName): TObject;
begin
  Result := FindCustomMethodClass(AnFullClassName);
end;

function TMethodControl.AddClass(
  const AnClassKey: Integer; const AnFullClassName: TgdcFullClassName;
  const AnClassReference: TClass): TObject;
begin
  Result := FMethodClassList.AddClass(AnClassKey, AnFullClassName,
    AnClassReference);
end;

{ TCustomMethodClass }

procedure TCustomMethodClass.Assign(Source: TCustomMethodClass);
begin
  FClass_Key := Source.Class_Key;
  FName := Source.Class_Name;
  FClass_Reference := Source.Class_Reference;

  FMethodList.Assign(Source.MethodList);
end;

constructor TCustomMethodClass.Create;
begin
  inherited;

  {$IFDEF DEBUGMTD}
  Inc(CustomMethodClassCount);
  {$ENDIF}
  FMethodList := TMethodList.Create;
//  FMethodList.OwnsObjects := True;
  FClass_Key := 0;
  FName := '';
  FSpecDisableMethod := 0;
  FSpecMethodCount := 0;
end;

destructor TCustomMethodClass.Destroy;
begin
  FMethodList.Free;

  {$IFDEF DEBUGMTD}
  Dec(CustomMethodClassCount);
  {$ENDIF}
  inherited;
end;

procedure TCustomMethodClass.SetSpecDisableMethod(const Value: Integer);
begin
  FSpecDisableMethod := Value;
end;

procedure TCustomMethodClass.SetSpecMethodCount(const Value: Integer);
begin
  FSpecMethodCount := Value;
end;

procedure TCustomMethodClass.SetSubType(const Value: String);
begin
  FSubType := Value;
end;

function TMethodClass.AddSubType(const AnClassKey: Integer;
  const AFullClassName: TgdcFullClassName; const AnClassReference: TClass): Integer;
var
  LCustomMethodClass: TCustomMethodClass;
begin
  Result := FSubTypeMethodList.AddObject(AFullClassName.SubType, TCustomMethodClass.Create);
  LCustomMethodClass := GetSubTypeItemByIndex(Result);
  LCustomMethodClass.Class_Key := AnClassKey;
  LCustomMethodClass.FSubType := AFullClassName.SubType;
  LCustomMethodClass.Class_Name := AFullClassName.gdClassName;
  LCustomMethodClass.FClass_Reference := AnClassReference;
end;

procedure TCustomMethodClass.SetSubTypeComment(const Value: String);
begin
  FSubTypeComment := Value;
end;

function TMethodControl.FindCustomMethodClass(
  const AnFullClassName: TgdcFullClassName): TCustomMethodClass;
begin
  Result := FMethodClassList.FindClass(AnFullClassName);
end;

{ TMethodList2 }

function TMethodList.Add(const ASource: TMethodItem): Integer;
begin
  {$IFDEF DEBUG}
//  Assert(FMethodList.IndexOf(ASource.Name) = -1);
  {$ENDIF}
  Result := FMethodList.AddObject(ASource.Name, ASource);
end;

function TMethodList.Add(const AName: String; const AFuncKey: Integer;
  const ADisable: Boolean;
  const AMethodClass: TCustomMethodClass): Integer;
var
  LMethodItem: TMethodItem;
begin
  {$IFDEF DEBUG}
//  Assert(FMethodList.IndexOf(AName) = -1);
  {$ENDIF}
  LMethodItem := TMethodItem.Create;
  LMethodItem.Name := AName;
  LMethodItem.FunctionKey := AFuncKey;
  LMethodItem.Disable := ADisable;
  LMethodItem.MethodClass := AMethodClass;
  Result := Add(LMethodItem);
end;

procedure TMethodList.Assign(ASource: TMethodList);
var
  I: Integer;
begin
   Clear;
  for I := 0 to ASource.Count - 1 do
    Add(ASource.Items[I]);
end;

procedure TMethodList.Clear;
begin
  while FMethodList.Count > 0 do
  begin
    FMethodList.Objects[Count - 1].Free;
    FMethodList.Delete(Count - 1);
  end;
end;

constructor TMethodList.Create;
begin
  inherited;

  FMethodList := TStringList.Create;
  TStringList(FMethodList).Sorted := True;
end;

destructor TMethodList.Destroy;
begin
  Clear;
  FMethodList.Free;
  
  inherited;
end;

function TMethodList.Find(const AName: String): TMethodItem;
var
  i: Integer;
begin
  Result := nil;
  i := FMethodList.IndexOf(AName);
  if i > -1 then
    Result := Items[i];
end;

function TMethodList.GetCount: Integer;
begin
  Result := FMethodList.Count;
end;

function TMethodList.GetItem(Index: Integer): TMethodItem;
begin
  Result := TMethodItem(FMethodList.Objects[Index]);
end;

function TMethodList.GetMethodName(Index: Integer): String;
begin
  Result := FMethodList[Index];
end;

function TMethodList.GetNameItem(const AName: String): TMethodItem;
begin
  Result := Find(AName);
end;

procedure TMethodList.SetMethodName(Index: Integer; const Value: String);
begin
  FMethodList[Index] := Value;
end;

function TMethodControl.GetClassType(
  const AnObject: TObject): TmtdClassType;
begin
  if AnObject.InheritsFrom(TgdcBase) then
  begin
    Result := mtd_gdcBase;
  end else
    if AnObject.InheritsFrom(TgdcCreateableForm) then
    begin
      Result := mtd_gdcForm;
    end else
      raise Exception.Create(
        'MethodControl: Передан некоррестный класс ' + AnObject.ClassName);
end;

function TMethodControl.VerifyingClass(
  const FullClassName: TgdcFullClassName; const ClassType: TmtdClassType): Boolean;
begin
  Result := False;
  case ClassType of
    mtd_gdcBase:
    begin
      if (gdcClassList <> nil) and (gdcClassList.IndexOfByName(FullClassName) > -1) then
        Result := True;
    end;
    mtd_gdcForm:
    begin
      if (frmClassList <> nil) and (frmClassList.IndexOfByName(FullClassName) > -1) then
        Result := True;
    end;
  end;
end;

function TMethodControl.GetSubType(
  const AnObject: TObject; const ClassType: TmtdClassType): String;
begin
  Result := '';
  case ClassType of
    mtd_gdcBase:
      Result := TgdcBase(AnObject).SubType;
    mtd_gdcForm:
      Result := TgdcCreateableForm(AnObject).SubType;
  end;
end;

function TMethodControl.GetParentClassName(
  const FullClassName: TgdcFullClassName; const ClassType: TmtdClassType): String;
var
  LClass: TComponentClass;
begin
  LClass := nil;
  case ClassType of
    mtd_gdcBase:
      LClass := gdcClassList.GetGDCClass(FullClassName);
    mtd_gdcForm:
      LClass := frmClassList.GetFRMClass(FullClassName);
  end;
  if LClass = nil then raise Exception.Create('Ошибка перекрытия метода. Обратитесь к разработчикам.');
  Result :=
    LClass.ClassParent.ClassName;
end;

procedure TMethodControl.SaveDisableFlag(
  const ID: Integer; const DisableFlag: Boolean);
var
  LIBSQL: TIBSQL;
begin
  LIBSQL := TIBSQL.Create(nil);
  try
    LIBSQL.Database := FDatabase;
    LIBSQL.Transaction := FTransaction;
    PrepareSourceDatabase;
    try
      LIBSQL.SQL.Text := 'UPDATE evt_objectevent ' +
        'SET disable = :disable WHERE ' +
        'id = :id';
      if DisableFlag then
        LIBSQL.Params[0].AsInteger := 1
      else
        LIBSQL.Params[0].AsInteger := 0;
      LIBSQL.Params[1].AsInteger := ID;
      LIBSQL.ExecQuery;
    finally
      UnPrepareSourceDatabase;
    end;
  finally
    LIBSQL.Free;
  end;
end;

procedure TMethodControl.Drop;
begin
  FmtdCacheList.Clear;
  FMethodClassList.Clear;
end;

initialization
  LocalSubTypeList := TStringList.Create;

finalization
{$IFDEF DEBUGMTD}
  if
    (MethodItemCount <> 0) or
    (CustomMethodClassCount <> 0) or
    (MethodClassCount <> 0) or
    (MethodListCount <> 0) or
    (MethodClassListCount <> 0) then
    MessageBox(0, 'sdf', 'df', mb_Ok);
    ;
{$ENDIF}

  FreeAndNil(LocalSubTypeList);
end.
