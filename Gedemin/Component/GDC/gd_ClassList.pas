
{++

  Copyright (c) 2001 - 2015 by Golden Software of Belarus

  Module

    gd_ClassList.pas

  Abstract

    Gedemin project.

  Author

    Mikhailenko Oleg

  Revisions history

    1.00   01.06.01  Andreik Kireev  Initial version.
    1.01   01.10.01  JKL     Class was separated from gdcBase.
    1.02   05.01.02  oleg_m  Fixed some errors
    1.03   08.01.02  oleg_m  Added stream I/O capabilities
    1.04   09.01.02  oleg_m  Added TTypeData field und accesories
    1.05   11.01.02  oleg_m  TTypeData field & Streaming
    1.10   24.01.02  oleg_m  Final version
--}

unit gd_ClassList;

interface

uses
  Contnrs,        Classes,   TypInfo,     Forms,        gd_KeyAssoc,
  gdcBase,        gdc_createable_form,    gdcBaseInterface,
  {$IFDEF VER130}
  gsStringHashList
  {$ELSE}
  IniFiles
  {$ENDIF}
  ;

// Ключи для перекрытия методов
const
  // для перекрытия метов TgdcBase (здесь, т.к. этот модуль везде подключен)
  keyCustomInsert          = 4;
  keyCustomModify          = 7;
  keyCustomDelete          = 10;
  keyDoAfterDelete         = 13;
  keyDoAfterInsert         = 16;
  keyDoAfterEdit           = 17;
  keyDoAfterOpen           = 19;
  keyDoAfterPost           = 22;
  keyDoAfterCancel         = 23;
  keyDoAfterScroll         = 24;
  keyDoBeforeClose         = 25;
  keyDoBeforeDelete        = 28;
  keyDoBeforeEdit          = 31;
  keyDoBeforeInsert        = 34;
  keyDoBeforePost          = 37;
  keyDoBeforeScroll        = 38;
  keyDoAfterTransactionEnd = 40;
  keyDoOnNewRecord         = 43;
  keyDoOnReportListClick   = 46;
  keyDoAfterExtraChanged   = 49;
  keyDoOnReportClick       = 52;
  keyDoBeforeOpen          = 55;
  key_DoOnNewRecord        = 58;
  keyCopyDialog            = 61;
  keyDoOnFilterChanged     = 64;
  keyDoAfterCustomProcess  = 67;
  keyDoBeforeShowDialog    = 70;
  keyDoAfterShowDialog     = 73;
  keyCreateDialogForm      = 76;
  keyEditDialog            = 79;
  keyCreateDialog          = 82;
  keyDoFieldChange         = 85;
  keyGetSelectClause       = 87;
  keyGetFromClause         = 91;
  keyGetWhereClause        = 93;
  keyGetOrderClause        = 97;
  keyGetGroupClause        = 101;
  keyValidateField         = 103;
  keyCheckTheSameStatement = 107;
  keyCreateFields          = 109;
  keyGetNotCopyField       = 111;
  keyBeforeDestruction     = 113;
  keyAfterConstruction     = 114;
  keyCheckSubSet           = 117;
  keyGetDialogDefaultsFields = 119;

  // для перекрытия метов TgdcCreateableForm (здесь, т.к. этот модуль везде подключен)
  keySaveSettings            = 203;
  keySetup                   = 205;
  keyLoadSettings            = 207;
  keyBeforePost              = 209;
  keyCancel                  = 210;
  keyPost                    = 211;
  keyTestCorrect             = 213;
  keySetChoose               = 217;
  keyLoadSettingsAfterCreate = 219;
  keySyncField               = 221;
  keyNeedVisibleTabSheet     = 223;
  keySaveAndShowTabSheet     = 227;
  keySetupRecord             = 229;
  keyGetgdcClass             = 231;
  keyGetChooseComponentName  = 233;
  keyGetChooseSubSet         = 237;
  keyGetChooseSubType        = 239;
  keyRemoveSubSetList        = 241;
  keySetupDialog             = 243;

const
  // Константы для организации хранения перекрытых классов с подтипами
  // Ставится в начале строки, если сохраняется класс и подтип
  SubtypeFlag = '*';
  // Разделяет класс и подтип в строке
  SubtypeDetach = '=';

type
  // Класс для организации стыка классов перекрытых методов
  TStackStrings = class(TObject)
  private
    FStackString: TStrings;
    function GetFullClassName(const Str: string): TgdcFullClassName;

  public
    destructor Destroy; override;

    function  Add(const FullClassName: TgdcFullClassName): Integer;
    function  AddObject(const FullClassName: TgdcFullClassName;  AObject: TObject): Integer;
    function  IndexOf(const ClassName: String): Integer;
    function  IsEmpty: Boolean;
    function  LastClass: TgdcFullClassName;
    function  LastObject: TObject;
    procedure Clear;
  end;

  // Класс предназначен для хранения признаков параметра метода
  TgdMethodParam = class
  private
    {Наименование параметра}
    FParamName: String;
    {Класс параметра}
    FParamClass: TComponentClass;
    {Тип параметра в строковом виде.}
    FParamTypeName: String;
    {Флаг (см. TypInfo.pas) }
    FParamFlag: TParamFlag;

    function GetIsParamClass: Boolean;
    procedure SetParamName(const Value: String);
  protected
    {Проверка на рав-во имен параметров}
    function EqualsByName(const AParamName: String): Boolean;
    {Полная проверка на рав-во пар-ров: проверяются все поля}
    function EqualsFull(const AParam: TgdMethodParam): Boolean;

  public
    constructor Create; overload;
    destructor Destroy; override;

    procedure Assign(ASource: TgdMethodParam);

    property ParamName: String read FParamName write SetParamName;
    property ParamClass: TComponentClass read FParamClass;
    property ParamTypeName: String read FParamTypeName;
    property IsParamClass: Boolean read GetIsParamClass;
    property ParamFlag: TParamFlag read FParamFlag;
  end;

  // Класс, хранящий информацию о методе, включая его параметры
  TgdMethod = class
  private
    {Наименование метода}
    FName: String;
    {Параметры в форме списка}
    FParams: TList;
    {Параметры в формате структуры типа TTypeData}
    FParamsData: TTypeData;
    {Тип результата в строковом виде}
    FFuncResType: String;

    procedure FreeFParams;

    function GetParamCount: Integer;
    function GetMethodParam(Index: Integer): TgdMethodParam;
    function AddParamToList(const AParam: TgdMethodParam): Integer; overload;
    function AddParamToList(AParamName, ATypeName: String;
      AParamFlag: TParamFlag): Integer; overload;
    procedure CustomDelete(Index: Integer);
    procedure StoreResultInTD(APosition: Integer);
    procedure AddParamToParamsData(AParamName, AParamType: String;
      AParamFlag: TParamFlag);
    function IsMethodFunction: Boolean;
    function ReadStrFromTD(ATD: TTypeData; var APosition: Integer): String;
    procedure WriteStrToTD(var ATD: TTypeData; var APosition: Integer;
      const S: String);

  protected
    {Проверка на существование параметра с данным именем в списке пар-ров}
    function ParamByNameExists(const AParamName: String): Boolean;
    {Проверка на существование параметра в списке пар-ров}
    function ParamExists(const AParam: TgdMethodParam): Boolean;
    {Проверка методов на рав-во: методы считаются равными если равны их поля и
     список параметров}
    function Equals(const AMethod: TgdMethod): Boolean;

  public
    constructor Create(AName: String; AKind: TMethodKind; AFuncResType: String = ''); overload;
    destructor Destroy; override;

    function AddParam(AParamName, ATypeName: String;
      AParamFlag: TParamFlag): Integer; overload;
    procedure Clear;
    procedure Assign(ASource: TgdMethod);

    property Name: String read FName write FName;
    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: TgdMethodParam read GetMethodParam;
    property ParamsData: TTypeData read FParamsData write FParamsData;
  end;

  TgdMethodList = class(TList)
  private
    function GetMethod(Index: Integer): TgdMethod;

  protected
    function MethodExists(const AMethod: TgdMethod): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    {Возвращает метод по имени}
    function MethodByName(const AName: String) : TgdMethod;
    {Добавление метода}
    function AddMethod(const AMethod: TgdMethod): Integer;
    {Посл. метод в списке}
    function Last: TgdMethod;
    {Удаление метода}
    procedure Delete(Index: Integer);
    {Очистка списка}
    procedure Clear; override;
    {Присвоение}
    procedure Assign(ASource: TgdMethodList);

    property Methods[Index: Integer]: TgdMethod read GetMethod {write SetMethod}; default;
  end;

  TgdClassMethods = class
  private
    FgdcClass: TComponentClass;
    FgdMethods: TgdMethodList;

  public
    constructor Create; overload; {! НУЖЕН !}
    constructor Create(AClass: TComponentClass); overload;
    destructor Destroy; override;

    function  GetgdClassMethodsParent: TgdClassMethods;
    procedure Assign(ASource: TgdClassMethods);

    property gdcClass: TComponentClass read FgdcClass write FgdcClass;
    property gdMethods: TgdMethodList read FgdMethods;
  end;

  TgdClassEntry = class;

  TgdClassEntryCallback = function(ACE: TgdClassEntry; AData1: Pointer;
    AData2: Pointer): Boolean of object;
  TgdClassEntryCallback2 = function(ACE: TgdClassEntry; AData1: Pointer;
    AData2: Pointer): Boolean;

  TgdClassEntry = class(TObject)
  private
    FParent: TgdClassEntry;
    FClass: TClass;
    FSubType: TgdcSubType;
    FClassMethods: TgdClassMethods;
    FCaption: String;
    FChildren: TObjectList;

    function GetChildren(Index: Integer): TgdClassEntry;
    function GetCount: Integer;
    function GetGdcClass: CgdcBase;
    function GetFrmClass: CgdcCreateableForm;
    function ListCallback(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;

  protected
    function Traverse(ACallback: TgdClassEntryCallback; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function Traverse(ACallback2: TgdClassEntryCallback2; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function Traverse(AList: TObjectList;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function GetSubTypeList(ASubTypeList: TStrings; const AnOnlyDirect: Boolean): Boolean;

  public
    constructor Create(AParent: TgdClassEntry; const AClass: TClass;
      const ASubType: TgdcSubType = '';
      const ACaption: String = ''); overload; virtual;

    destructor Destroy; override;

    function Compare(const AClass: TClass; const ASubType: TgdcSubType = ''): Integer; overload;
    function Compare(const AClassName: AnsiString; const ASubType: TgdcSubType = ''): Integer; overload;
    procedure AddChild(AChild: TgdClassEntry);
    procedure RemoveChild(AChild: TgdClassEntry);
    function FindChild(const AClassName: AnsiString): TgdClassEntry;

    property Parent: TgdClassEntry read FParent;
    property TheClass: TClass read FClass;
    property SubType: TgdcSubType read FSubType;
    property gdcClass: CgdcBase read GetGdcClass;
    property frmClass: CgdcCreateableForm read GetFrmClass;
    property Caption: String read FCaption write FCaption;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TgdClassEntry read GetChildren;
    property ClassMethods: TgdClassMethods read FClassMethods;
  end;
  CgdClassEntry = class of TgdClassEntry;

  TgdStorageEntry = class(TgdClassEntry)
  end;

  TgdClassList = class(TObject)
  private
    FClasses: array of TgdClassEntry;
    FCount: Integer;

    function _Find(const AClassName: AnsiString; const ASubType: TgdcSubType;
      out Index: Integer): Boolean;
    procedure _Insert(const Index: Integer; ACE: TgdClassEntry);
    procedure _Grow;
    procedure _Compact;
    function _Create(APrnt: TgdClassEntry; AClass: CgdClassEntry;
      ASubType: TgdcSubType; ACaption: String): TgdClassEntry;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AClass: TClass; const ASubType: TgdcSubType;
      const AParentSubType: TgdcSubType; const ACaption: String): TgdClassEntry; overload;
    function Add(const AClassName: AnsiString; const ASubType: TgdcSubType;
      const AParentSubType: TgdcSubType; const ACaption: String): TgdClassEntry; overload;

    function Find(const AClass: TClass; const ASubType: TgdcSubType = ''): TgdClassEntry; overload;
    function Find(const AClassName: AnsiString; const ASubType: TgdcSubType = ''): TgdClassEntry; overload;
    function Find(const AFullClassName: TgdcFullClassName): TgdClassEntry; overload;

    function Traverse(const AClass: TClass; const ASubType: TgdcSubType;
      ACallback: TgdClassEntryCallback; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;

    function Traverse(const AClass: TClass; const ASubType: TgdcSubType;
      ACallback: TgdClassEntryCallback2; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;

    function GetSubTypeList(AClass: TClass; const ASubType: TgdcSubType;
      ASubTypeList: TStrings; const AnOnlyDirect: Boolean): Boolean;

    procedure Remove(const AClass: TClass; const ASubType: TgdcSubType = ''); overload;
    procedure Remove(const AClassName: String; const ASubType: TgdcSubType = ''); overload;
    procedure RemoveAllSubTypes;

    procedure AddClassMethods(AClassMethods: TgdClassMethods); overload;
    procedure AddClassMethods(AClass: TComponentClass;
      AMethods: array of TgdMethod); overload;

    function GetGDCClass(const AClassName: String): CgdcBase;
    function GetFrmClass(const AClassName: String): CgdcCreateableForm;

    procedure LoadUserDefinedClasses;

    property Count: Integer read FCount;
  end;

var
  // при создании каждый объект регистрирует себя в этом списке
  // при удалении удаляет. Данный список необходим нам, чтобы
  // при вставке из кармана знать, нам передали правильную ссылку
  // на объект или такого объекта уже нет в памяти компьютера
  gdcObjectList: TObjectList;

  // список классов. каждый класс должен быть зарегистрирован здесь,
  // тогда мы сможем определить, например, список детальных объектов
  // для мастер объекта (точнее, нам мы сможем определить класс объекта
  // по заданному имени главной таблицы (пока, у нас, ListTable)

  // для GDC-классов и форм
  _gdClassList: TgdClassList;

function gdClassList: TgdClassList;

{Регистрация класса в списке TgdcClassList}
procedure RegisterGdcClass(const AClass: CgdcBase; const ACaption: String = '');
procedure UnRegisterGdcClass(AClass: CgdcBase);

// добавляет класс в список классов
{Регистрация класса в списке TgdcClassList}
procedure RegisterFrmClass(AClass: CgdcCreateableForm);
procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);

{Регистрация метода для класса.}
procedure RegisterFrmClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
procedure RegisterGDCClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
//Заменяет символ $ на _
function Replace(const Str: string): string;

{$IFDEF DEBUG}
var
  glbParamCount, glbMethodCount, glbMethodListCount,
  glbClassMethodCount, glbClassListCount: Integer;
{$ENDIF}

implementation

uses
  SysUtils, gs_Exception, at_classes, IBSQL, gd_security, gsStorage, Storages
  {$IFDEF DEBUG}
  , gd_DebugLog
  {$ENDIF}
  ;

type
  TPrefixType = array [0..3] of Char;
  TClassTypeList = (GDC, FRM);

const
  PARAM_PREFIX         : TPrefixType = '^PAR';
  METHOD_PREFIX        : TPrefixType = '^MTD';
  METHOD_LIST_PREFIX   : TPrefixType = '^M_L';
  CLASS_METHODS_PREFIX : TPrefixType = '^C_M';
  CLASS_LIST_PREFIX    : TPrefixType = '^C_L';

{$IFDEF METHODSCHECK}
var
  dbgMethodList: TStrings;

const
  mcString = '%s;%s';
{$ENDIF}

//Заменяет символ $ на _
function Replace(const Str: string): string;
var
  I: Integer;
begin
  Result := Str;
  for I := 1 to Length(Str) do
  begin
    if Result[I] = '$' then
      Result[I] := '_';
  end;
end;

function gdClassList: TgdClassList;
begin
  if _gdClassList = nil then
    _gdClassList := TgdClassList.Create;
  Result := _gdClassList;
end;

procedure RegisterGdcClass(const AClass: CgdcBase; const ACaption: String = '');
begin
  Assert(AClass <> nil);
  Assert(gdClassList <> nil);

  Classes.RegisterClass(AClass);
  gdClassList.Add(AClass, '', '', ACaption);
end;

procedure UnRegisterGdcClass(AClass: CgdcBase);
begin
  gdClassList.Remove(AClass);
  UnRegisterClass(AClass);
end;

procedure RegisterFrmClass(AClass: CgdcCreateableForm);
begin
  Classes.RegisterClass(AClass);
  gdClassList.Add(AClass, '', '', '');
end;

procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
begin
  UnRegisterClass(AClass);
  gdClassList.Remove(AClass);
end;

procedure CustomRegisterClassMethod(ATypeList: TClassTypeList; const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
var
  Method: TgdMethod;
  CursorPos: Integer;
  Str: String;
  L: Integer;
const
  Letters = '1234567890_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';

  procedure TrimSpace;
  begin
    while (CursorPos > 0) and (CursorPos < L) and (Str[CursorPos] = ' ') do
    begin
      Inc(CursorPos);
    end;
  end;

  function GetCurrentWord: String;
  var
    BeginPos, EndPos: Integer;
  begin
    BeginPos := CursorPos;
    EndPos := CursorPos;
    while BeginPos > 1 do
    begin
      if Str[BeginPos - 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
        Dec(BeginPos)
      else
        Break;
    end;
    while EndPos + 1 <= L do
    begin
      if Str[EndPos + 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
        Inc(EndPos)
      else
        Break;
    end;

    if EndPos >= BeginPos then
      Result := System.Copy(Str, BeginPos, EndPos - BeginPos + 1)
    else
      Result := '';
    CursorPos := EndPos + 1;
  end;

  procedure WorkParam;
  var
    ParamType: String;
    ParamName: String;
    ParamFlag: String;
    PF: TParamFlag;
  begin
    TrimSpace;

    ParamName := '';
    ParamFlag := GetCurrentWord;
    // Если флага нет, то в ParamFlag будет имя
    if UpperCase(ParamFlag) = 'VAR' then
      PF := pfVar
    else if UpperCase(ParamFlag) = 'CONST' then
      PF := pfConst
    else  if UpperCase(ParamFlag) = 'ARRAY' then
      PF := pfArray
    else if UpperCase(ParamFlag) = 'ADDRESS' then
      PF := pfAddress
    else if UpperCase(ParamFlag) = 'REFERENCE' then
      PF := pfReference
    else if UpperCase(ParamFlag) = 'OUT' then
      PF := pfOut
    else
      begin
        ParamName := ParamFlag;
        ParamFlag := 'REFERENCE';
        PF := pfReference;
      end;

    if Length(ParamName) = 0 then
    begin
      TrimSpace;
      ParamName := GetCurrentWord;
    end;
    TrimSpace;

    if Str[CursorPos] = ':' then
      Inc(CursorPos)
    else
      raise Exception.Create('gd_ClassList: Ошибка формата. Позиция:' + IntToStr(CursorPos) + #13#10 +
        'Нужно двоеточие');
    TrimSpace;

    ParamType := GetCurrentWord;
    TrimSpace;

    if CursorPos <= L then
    begin
      if Str[CursorPos] = ';' then
      begin
        Inc(CursorPos);
        TrimSpace;
      end else
        if not (CursorPos > L) then
          raise Exception.Create('gd_ClassList: Ошибка формата. Позиция:' + IntToStr(CursorPos) + #13#10 +
            'Нужна точка с запятой');
    end;

    if Assigned(Method) then
      Method.AddParam(ParamName, ParamType, PF);
  end;

begin
  Str:= Trim(InputParams);
  CursorPos := 1;
  L := Length(Str);

  if OutputParam = '' then
    Method := TgdMethod.Create(AnMethod, mkProcedure)
  else
    Method := TgdMethod.Create(AnMethod, mkFunction, OutputParam);
  try
    while CursorPos < Length(Str) do
      WorkParam;
      gdClassList.AddClassMethods(AnClass, Method);
  finally
    Method.Free;
  end;
end;

procedure RegisterGDCClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
begin
  CustomRegisterClassMethod(GDC, AnClass, AnMethod, InputParams, OutputParam);
end;

procedure RegisterFrmClassMethod(const AnClass: TComponentClass; AnMethod: String;
  InputParams: String; OutputParam: String = '');
begin
  CustomRegisterClassMethod(FRM, AnClass, AnMethod, InputParams, OutputParam);
end;

{TgdMethodParam}
constructor TgdMethodParam.Create;
begin
  inherited;

  {$IFDEF DEBUG}
  Inc(glbParamCount);
  {$ENDIF}
end;


destructor TgdMethodParam.Destroy;
begin
  inherited;

  {$IFDEF DEBUG}
  Dec(glbParamCount);
  {$ENDIF}
end;

function TgdMethodParam.EqualsByName(const AParamName: String): Boolean;
begin
  Result := AnsiSameText(FParamName, AParamName);
end;

function TgdMethodParam.EqualsFull(const AParam: TgdMethodParam): Boolean;
begin
  Result := (FParamName = AParam.FParamName) and
   (FParamClass = AParam.FParamClass) and
   (FParamTypeName = AParam.FParamTypeName) and
   (FParamName = AParam.FParamName) and
   (FParamFlag = AParam.FParamFlag);
end;

procedure TgdMethodParam.Assign(ASource: TgdMethodParam);
begin
  FParamName := ASource.ParamName;
  FParamClass := ASource.ParamClass;
  FParamTypeName := ASource.ParamTypeName;
  FParamFlag := ASource.FParamFlag;
end;

{TgdMethod}
constructor TgdMethod.Create(AName: String; AKind: TMethodKind;
  AFuncResType: String = '');
begin
  inherited Create;

  if (AKind in [mkFunction, mkClassFunction, mkSafeFunction]) and
    (AFuncResType = '') then
    raise Exception.Create(GetGsException(Self, 'For function you must specify result type !'));

  FName := AName;
  FParams := TList.Create;
  FParamsData.MethodKind := AKind;
  FParamsData.ParamCount := 0;
  FFuncResType := AFuncResType;

  StoreResultInTD(0);

  //only for testing
{$IFDEF DEBUG}
  Inc(glbMethodCount);
{$ENDIF}
end;

procedure TgdMethod.StoreResultInTD(APosition: Integer);
begin
  if IsMethodFunction then
    WriteStrToTD(FParamsData, APosition, FFuncResType);
end;

function TgdMethod.AddParamToList(const AParam: TgdMethodParam): Integer;
begin
  Result := FParams.Add(TgdMethodParam.Create);
  if Assigned(AParam) then
    Params[Result].Assign(AParam);
end;

function TgdMethod.AddParamToList(AParamName, ATypeName: String;
  AParamFlag: TParamFlag): Integer;
begin
  Result := AddParamToList(nil);
  Params[Result].FParamName := AParamName;
  Params[Result].FParamClass := nil;
  Params[Result].FParamTypeName := ATypeName;
  Params[Result].FParamFlag := AParamFlag;
end;

function TgdMethod.AddParam(AParamName, ATypeName: String;
  AParamFlag: TParamFlag): Integer;
begin
  if ParamByNameExists(AParamName) then
    raise Exception.Create(GetGsException(Self, Format('Parameter %s already found for this method !', [AParamName])));

  Result := AddParamToList(AParamName, ATypeName, AParamFlag);
  AddParamToParamsData(AParamName, ATypeName, AParamFlag);
end;

procedure TgdMethod.AddParamToParamsData(AParamName, AParamType: String;
  AParamFlag: TParamFlag);
var
  I, Pos: Integer;
begin
  // Skips existing parameters
  Pos := 0;
  for I := 0 to FParamsData.ParamCount - 1 do
  begin
    Inc(Pos); //Skip flag
    ReadStrFromTD(FParamsData, Pos);
    ReadStrFromTD(FParamsData, Pos);
  end;
  // Writes parameter info erasing func res. type
  FParamsData.ParamList[Pos] := Chr(Ord(AParamFlag));
  Inc(Pos);
  WriteStrToTD(FParamsData, Pos, AParamName);
  WriteStrToTD(FParamsData, Pos, AParamType);
  Inc(FParamsData.ParamCount);
  // Writes func res. type
  StoreResultInTD(Pos);
end;

function TgdMethod.IsMethodFunction: Boolean;
begin
  Result := FParamsData.MethodKind in [mkFunction, mkClassFunction, mkSafeFunction];
end;

function TgdMethod.ParamByNameExists(const AParamName: String): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to FParams.Count - 1 do
    if Params[I].EqualsByName(AParamName) then
    begin
      Result := True;
      Break
    end;
end;

function TgdMethod.ParamExists(const AParam: TgdMethodParam): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to FParams.Count - 1 do
    if Params[I].EqualsFull(AParam) then
    begin
      Result := True;
      Break
    end;
end;

function TgdMethod.Equals(const AMethod: TgdMethod): Boolean;
var
  I: Integer;
begin
  Result := True;

  if (Name <> AMethod.Name) or
   (ParamCount <> AMethod.ParamCount) then
  begin
    Result := False;
    Exit
  end;

  for I := 0 to ParamCount - 1 do
    if not ParamExists(Params[I]) then
    begin
      Result := False;
      Exit
    end;
end;

procedure TgdMethod.CustomDelete(Index: Integer);
begin
  Params[Index].Free;
  FParams.Delete(Index);
end;

procedure TgdMethod.Clear;
begin
  FreeFParams;
  FName := '';
  FFuncResType := '';
  FParamsData.ParamCount := 0;
  while ParamCount > 0 do
    CustomDelete(0);
end;

procedure TgdMethod.Assign(ASource: TgdMethod);
var
  I: Integer;
begin
  Clear;
  FName := ASource.Name;
  FFuncResType := ASource.FFuncResType;
  FParamsData := ASource.ParamsData;
  for I := 0 to ASource.ParamCount - 1 do
    AddParamToList(ASource.Params[I]);
end;

function TgdMethod.GetParamCount: Integer;
begin
  Result := FParams.Count;
end;

destructor TgdMethod.Destroy;
begin
  Clear;
  FreeAndNil(FParams);
  inherited Destroy;

  {$IFDEF DEBUG}
  Dec(glbMethodCount);
  {$ENDIF}
end;

function TgdMethod.GetMethodParam(Index: Integer): TgdMethodParam;
begin
  Assert((Index >= 0) and (Index < ParamCount), 'Index out of range');
  Result := TgdMethodParam(FParams[Index]);
end;

function TgdMethod.ReadStrFromTD(ATD: TTypeData; var APosition: Integer): String;
var
  CharCount:Byte;
begin
  Result := '';
  CharCount := Ord(ATD.ParamList[APosition]);
  Result := Copy(ShortString((@ATD.ParamList[APosition])^), 1, CharCount);
  Inc(APosition, CharCount + 1);
end;

procedure TgdMethod.WriteStrToTD(var ATD: TTypeData; var APosition: Integer;
  const S: String);
begin
  ShortString((@ATD.ParamList[APosition])^) := ShortString(S);
  Inc(APosition, Length(S) + 1);
end;

{TgdMethodList}
constructor TgdMethodList.Create;
begin
  inherited Create;

  //test
{$IFDEF DEBUG}
  Inc(glbMethodListCount);
{$ENDIF}
end;

destructor TgdMethodList.Destroy;
begin
  Clear;

  inherited Destroy;
  //test
{$IFDEF DEBUG}
  Dec(glbMethodListCount);
{$ENDIF}
end;

function TgdMethodList.GetMethod(Index: Integer): TgdMethod;
begin
  Assert((Index >= 0) and (Index < Count), 'Index out of range');
  Result := TgdMethod(inherited Items[Index]);
end;

function TgdMethodList.MethodExists(const AMethod: TgdMethod): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Methods[I].Equals(AMethod) then
    begin
      Result := True;
      Exit;
    end;
end;

function TgdMethodList.MethodByName(const AName: String) : TgdMethod;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiSameText(Methods[I].Name, AName) then
    begin
      Result := Methods[I];
      Break;
    end;
end;

function TgdMethodList.AddMethod(const AMethod: TgdMethod): Integer;
begin
  if AMethod.Name = '' then
    raise Exception.Create(GetGsException(Self, 'Method must have a name'));
  if MethodExists(AMethod) then
    raise Exception.Create(GetGsException(Self, 'Method ' + AMethod.Name + ' already found in list'));

  Result := Add(TgdMethod.Create('', mkProcedure{не сущ-но}, ''));
  if Assigned(AMethod) then
    Last.Assign(AMethod);
end;

function TgdMethodList.Last: TgdMethod;
begin
  Result := TgdMethod(inherited Last);
end;

procedure TgdMethodList.Delete(Index: Integer);
begin
  Methods[Index].Free;

  inherited Delete(Index);
end;

procedure TgdMethodList.Clear;
begin
  while Count > 0 do
    Delete(0);

  inherited Clear;
end;

procedure TgdMethodList.Assign(ASource: TgdMethodList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    AddMethod(ASource.Methods[I]);
end;

{TgdClassMethods}

constructor TgdClassMethods.Create;
begin
  inherited Create;

  FgdcClass := nil;
  FgdMethods := TgdMethodList.Create;

  // for testing purpose
{$IFDEF DEBUG}
  Inc(glbClassMethodCount);
{$ENDIF}
end;

constructor TgdClassMethods.Create(AClass: TComponentClass);
begin
  Create;
  FgdcClass := AClass;
end;

procedure TgdClassMethods.Assign(ASource: TgdClassMethods);
begin
  gdcClass := ASource.gdcClass;
  gdMethods.Assign(ASource.gdMethods);
end;

destructor TgdClassMethods.Destroy;
begin
  FgdMethods.Free;

  inherited;

  // for testing purpose
{$IFDEF DEBUG}
  Dec(glbClassMethodCount);
{$ENDIF}
end;

procedure TgdMethod.FreeFParams;
var
  i: Integer;
begin
  for i := 0 to FParams.Count - 1 do
    TgdMethodParam(FParams[i]).Free;
  FParams.Clear;
end;

function TgdMethodParam.GetIsParamClass: Boolean;
begin
  Result := FParamClass <> nil;
end;

procedure TgdMethodParam.SetParamName(const Value: String);
begin
  FParamName := Value;
end;

{TStackStrings}

function TStackStrings.Add(const FullClassName: TgdcFullClassName): Integer;
begin
  if FStackString = nil then
    FStackString := TStringList.Create;

  if Length(Trim(FullClassName.SubType)) = 0 then
    Result := FStackString.Add(FullClassName.gdClassName)
  else
    Result := FStackString.Add(SubtypeFlag + FullClassName.gdClassName +
      SubtypeDetach + FullClassName.SubType);
end;

function TStackStrings.AddObject(const FullClassName: TgdcFullClassName;
  AObject: TObject): Integer;
begin
  Result := Add(FullClassName);
  FStackString.Objects[Result] := AObject;
end;

procedure TStackStrings.Clear;
begin
  FreeAndNil(FStackString);
end;

destructor TStackStrings.Destroy;
begin
  FStackString.Free;
  inherited;
end;

function TStackStrings.GetFullClassName(
  const Str: string): TgdcFullClassName;
var
  SeparPos: Integer;
begin
  if Str[1] = '*' then
  begin
    SeparPos := Pos('=', Str);
    Result.gdClassName := Copy(Str, 2, SeparPos - 2);
    Result.SubType := Copy(Str, SeparPos + 1, Length(Str));
  end else
    Result.gdClassName := Str;
end;

function TStackStrings.IndexOf(const ClassName: String): Integer;
begin
  if FStackString = nil then
    Result := -1
  else
    Result := FStackString.IndexOf(ClassName);
end;

function TStackStrings.IsEmpty: Boolean;
begin
  Result := (FStackString = nil) or (FStackString.Count = 0);
end;

function TStackStrings.LastClass: TgdcFullClassName;
begin
  if FStackString <> nil then
    Result := GetFullClassName(FStackString[FStackString.Count - 1])
  else begin
    Result.gdClassName := '';
    Result.SubType := '';
  end;
end;

function TStackStrings.LastObject: TObject;
begin
  if FStackString <> nil then
    Result := FStackString.Objects[FStackString.Count - 1]
  else
    Result := nil;
end;

function TgdClassMethods.GetgdClassMethodsParent: TgdClassMethods;
var
  CE: TgdClassEntry;
begin
  Result := nil;

  CE := gdClassList.Find(FgdcClass.ClassParent);

  if (CE <> nil) and (CE.ClassMethods <> nil) then
    Result := CE.ClassMethods
end;

{TgdClassEntry}

procedure TgdClassEntry.AddChild(AChild: TgdClassEntry);
begin
  Assert(AChild <> nil);
  Assert(AChild.Parent = Self);
  if FChildren = nil then
    FChildren := TObjectList.Create(False);
  FChildren.Add(AChild);
end;

function TgdClassEntry.Compare(const AClass: TClass;
  const ASubType: TgdcSubType): Integer;
begin
  Assert(AClass <> nil);
  Result := Compare(AClass.ClassName, ASubType);
end;

constructor TgdClassEntry.Create(AParent: TgdClassEntry; const AClass: TClass;
  const ASubType: TgdcSubType = ''; const ACaption: String = '');
begin
  FParent := AParent;
  FClass := AClass;
  FCaption := ACaption;
  FSubType := ASubType;
  FChildren := nil;
  FClassMethods := TgdClassMethods.Create(TComponentClass(FClass));
end;

destructor TgdClassEntry.Destroy;
begin
  FChildren.Free;
  FClassMethods.Free;
  inherited;
end;

function TgdClassEntry.GetCount: Integer;
begin
  if FChildren = nil then
    Result := 0
  else
    Result := FChildren.Count;
end;

function TgdClassEntry.GetGdcClass: CgdcBase;
begin
  if (FClass <> nil) and FClass.InheritsFrom(TgdcBase) then
    Result := CgdcBase(FClass)
  else
    Result := nil;
end;

function TgdClassEntry.GetFrmClass: CgdcCreateableForm;
begin
  if (FClass <> nil) and FClass.InheritsFrom(TgdcCreateableForm) then
    Result := CgdcCreateableForm(FClass)
  else
    Result := nil;
end;

function TgdClassEntry.GetChildren(Index: Integer): TgdClassEntry;
begin
  Result := FChildren[Index] as TgdClassEntry;
end;

function TgdClassEntry.GetSubTypeList(ASubTypeList: TStrings;
  const AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(ASubTypeList <> nil);

  Result := False;

  for I := 0 to Count - 1 do
  begin
    if Children[I].SubType > '' then
    begin
      ASubTypeList.Add(Children[I].Caption + '=' + Children[I].SubType);
      Result := True;

      if not AnOnlyDirect then
        Result := Children[I].GetSubTypeList(ASubTypeList, False) or Result;
    end;
  end;
end;

function TgdClassEntry.Traverse(ACallback: TgdClassEntryCallback;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback));

  if AnIncludeRoot then
    Result := ACallback(Self, AData1, AData2)
  else
    Result := True;

  I := 0;
  while Result and (I < Count) do
  begin
    if AnOnlyDirect then
      Result := Result and ACallback(Children[I], AData1, AData2)
    else
      Result := Result and Children[I].Traverse(ACallback, AData1, AData2, True, False);
    Inc(I);
  end;
end;

function TgdClassEntry.Traverse(ACallback2: TgdClassEntryCallback2;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback2));

  if AnIncludeRoot then
    Result := ACallback2(Self, AData1, AData2)
  else
    Result := True;

  I := 0;
  while Result and (I < Count) do
  begin
    if AnOnlyDirect then
      Result := Result and ACallback2(Children[I], AData1, AData2)
    else
      Result := Result and Children[I].Traverse(ACallback2, AData1, AData2, True, False);
    Inc(I);
  end;
end;

function TgdClassEntry.Compare(const AClassName: AnsiString;
  const ASubType: TgdcSubType): Integer;
begin
  Result := AnsiCompareText(FSubType, ASubType);
  if Result = 0 then
    Result := AnsiCompareText(FClass.ClassName, AClassName);
end;

procedure TgdClassEntry.RemoveChild(AChild: TgdClassEntry);
begin
  if FChildren <> nil then
    FChildren.Remove(AChild);
end;

function TgdClassEntry.Traverse(AList: TObjectList; const AnIncludeRoot,
  AnOnlyDirect: Boolean): Boolean;
begin
  Assert(AList <> nil);
  Result := Traverse(ListCallBack, AList, nil, AnIncludeRoot, AnOnlyDirect);
end;

function TgdClassEntry.ListCallback(ACE: TgdClassEntry; AData1,
  AData2: Pointer): Boolean;
begin
  TObjectList(AData1).Add(ACE);
  Result := True;
end;

function TgdClassEntry.FindChild(const AClassName: AnsiString): TgdClassEntry;
var
  I: Integer;
begin
  for I := 0 to Self.Count - 1 do
  begin
    Result := FChildren[I] as TgdClassEntry;
    if (CompareText(Result.TheClass.ClassName, AClassName) = 0)
      or (CompareText(Result.SubType, AClassName) = 0) then
    begin
      exit;
    end;
  end;
  Result := nil;
end;

{TgdClassList}

function TgdClassList.GetGDCClass(const AClassName: String): CgdcBase;
var
  CE: TgdClassEntry;
begin
  CE := Find(AClassName, '');

  if CE <> nil then
    Result := CE.gdcClass
  else
    Result := nil;
end;

function TgdClassList.GetFrmClass(const AClassName: String): CgdcCreateableForm;
var
  CE: TgdClassEntry;
begin
  CE := Find(AClassName, '');

  if CE <> nil then
    Result := CE.frmClass
  else
    Result := nil;
end;

function TgdClassList.Add(const AClass: TClass;
  const ASubType: TgdcSubType;
  const AParentSubType: TgdcSubType;
  const ACaption: String): TgdClassEntry;
begin
  Result := Add(AClass.ClassName, ASubType, AParentSubType, ACaption);
end;

constructor TgdClassList.Create;
begin
  inherited;
  {$IFDEF DEBUG}
  Inc(glbClassListCount);
  {$ENDIF}
end;

destructor TgdClassList.Destroy;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    FClasses[I].Free;

  inherited;

{$IFDEF DEBUG}
  Dec(glbClassListCount);
{$ENDIF}
end;

function TgdClassList.Find(const AClass: TClass;
  const ASubType: TgdcSubType): TgdClassEntry;
begin
  Assert(AClass <> nil);
  Result := Find(AClass.ClassName, ASubType);
end;

function GetRemoveList(ACE: TgdClassEntry; AData1: Pointer; AData2: Pointer): Boolean;
begin
  TStringList(AData1^).Add(ACE.TheClass.ClassName + '=' + ACE.SubType);
  Result := True;
end;

function ValueFromString(const Str: String): string;
var
  P: Integer;
begin
  Result := '';
  P := AnsiPos('=', Str);
  if (P <> 0) and (P <> Length(Str)) then
    Result := Copy(Str, P + 1, Length(Str) - P);
end;

procedure TgdClassList.Remove(const AClass: TClass;
  const ASubType: TgdcSubType);
begin
  Assert(AClass <> nil);
  Remove(AClass.ClassName, ASubType);
end;

function GetAllSubTypes(ACE: TgdClassEntry; AData1: Pointer; AData2: Pointer): Boolean;
begin
  if ACE.SubType <> '' then
    TStringList(AData1^).Add(ACE.TheClass.ClassName + '=' + ACE.SubType);

  Result := True;
end;

procedure TgdClassList.RemoveAllSubTypes;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if FClasses[I].SubType > '' then
    begin
      if FClasses[I].Parent <> nil then
        FClasses[I].Parent.RemoveChild(FClasses[I]);
      FreeAndNil(FClasses[I]);
    end;
  end;

  _Compact;
end;

procedure TgdClassList.AddClassMethods(AClass: TComponentClass;
  AMethods: array of TgdMethod);
var
  VgdMethodList : TgdMethodList;
  VgdClassMethods : TgdClassMethods;
  I : Integer;
begin
  VgdClassMethods := TgdClassMethods.Create;
  try
    VgdMethodList := TgdMethodList.Create;
    try
      for I := Low(AMethods) to High(AMethods) do
      begin
        VgdMethodList.AddMethod(AMethods[I]);
        {$IFDEF METHODSCHECK}
        if dbgMethodList = nil then
          dbgMethodList := TStringList.Create;
        dbgMethodList.Add(Format(mcString, [AClass.ClassName, AMethods[I].Name]));
        {$ENDIF}
      end;

      VgdClassMethods.gdMethods.Assign(VgdMethodList);
      VgdClassMethods.gdcClass := AClass;
      AddClassMethods(VgdClassMethods);
    finally
      VgdMethodList.Free;
    end;
  finally
    VgdClassMethods.Free;
  end;
end;

procedure TgdClassList.AddClassMethods(
  AClassMethods: TgdClassMethods);
var
  I: Integer;
  CE: TgdClassEntry;
begin
  CE := Find(AClassMethods.gdcClass);

  Assert(CE <> nil);
  
  for I := 0 to AClassMethods.gdMethods.Count - 1 do
    CE.ClassMethods.gdMethods.AddMethod(AClassMethods.gdMethods.Items[I]);
end;

function TgdClassList.Traverse(const AClass: TClass;
  const ASubType: TgdcSubType; ACallback: TgdClassEntryCallback;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(Assigned(ACallback));

  CE := Find(AClass, ASubType);
  if CE <> nil then
    Result := CE.Traverse(ACallback, AData1, AData2, AnIncludeRoot, AnOnlyDirect)
  else
    Result := False;
end;

function TgdClassList.Traverse(const AClass: TClass;
  const ASubType: TgdcSubType; ACallback: TgdClassEntryCallback2;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(Assigned(ACallback));

  CE := Find(AClass, ASubType);
  if CE <> nil then
    Result := CE.Traverse(ACallback, AData1, AData2, AnIncludeRoot, AnOnlyDirect)
  else
    Result := False;
end;

function TgdClassList.GetSubTypeList(AClass: TClass; const ASubType: TgdcSubType;
  ASubTypeList: TStrings; const AnOnlyDirect: Boolean): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(AClass <> nil);

  CE := Find(AClass, ASubType);

  if CE = nil then
    raise Exception.Create('Unregistered class.');

  Result := CE.GetSubTypeList(ASubTypeList, AnOnlyDirect);
end;

function TgdClassList._Find(const AClassName: AnsiString; const ASubType: TgdcSubType;
  out Index: Integer): Boolean;
var
  L, H: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    Index := (L + H) shr 1;
    case FClasses[Index].Compare(AClassName, ASubType) of
      -1: L := Index + 1;
      +1: H := Index - 1;
    else
      Result := True;
      exit;
    end;
  end;
  Index := L;
end;

procedure TgdClassList._Grow;
begin
  if High(FClasses) = -1 then
    SetLength(FClasses, 2048)
  else
    SetLength(FClasses, High(FClasses) + 1 + 1024);
end;

procedure TgdClassList._Insert(const Index: Integer; ACE: TgdClassEntry);
begin
  if FCount > High(FClasses) then _Grow;
  if Index < FCount then
  begin
    System.Move(FClasses[Index], FClasses[Index + 1],
      (FCount - Index) * SizeOf(FClasses[0]));
  end;
  FClasses[Index] := ACE;
  Inc(FCount);
end;

function GetClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
begin
  Assert(ACE <> nil);
  Assert(AData1 <> nil);
  Assert(AData2 <> nil);
  Assert(TClassList(AData1^) <> nil);

  if ACE.SubType = '' then
    TClassList(AData1^).Add(ACE.TheClass);
  Result := True;
end;

function TgdClassList.Find(const AClassName: AnsiString;
  const ASubType: TgdcSubType): TgdClassEntry;
var
  Index: Integer;
begin
  if _Find(AClassName, ASubType, Index) then
    Result := FClasses[Index]
  else
    Result := nil;
end;

function TgdClassList.Find(const AFullClassName: TgdcFullClassName): TgdClassEntry;
begin
  Result := Find(AFullClassName.gdClassName, AFullClassName.SubType);
end;

procedure TgdClassList.LoadUserDefinedClasses;

  function LoadRelation(Prnt: TgdClassEntry; R: TatRelation): TgdClassEntry;
  var
    F: TatRelationField;
  begin
    F := R.RelationFields.ByFieldName('INHERITEDKEY');

    if (F <> nil) and (F.References <> nil) then
      Prnt := LoadRelation(Prnt, F.References);

    Result := _Create(Prnt, TgdClassEntry, R.RelationName, R.LName);
  end;

  function LoadDocument(Prnt: TgdClassEntry; q: TIBSQL): TgdClassEntry;
  var
    PrevRB: Integer;
  begin
    Result := _Create(Prnt, TgdClassEntry, q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);

    PrevRB := q.FieldByName('rb').AsInteger;
    q.Next;

    while (not q.EOF) and (q.FieldByName('lb').AsInteger < PrevRB) do
      LoadDocument(Result, q);
  end;

  procedure CopySubTree(Src, Dst: TgdClassEntry);
  var
    I: Integer;
    CE: TgdClassEntry;
  begin
    for I := 0 to Src.Count - 1 do
    begin
      CE := _Create(Dst, TgdClassEntry, Src.Children[I].SubType, Src.Children[I].Caption);
      if Src.Children[I].Count > 0 then
        CopySubTree(Src.Children[I], CE);
    end;
  end;

  procedure IterateStorage(F: TgsStorageFolder; APrnt: TgdClassEntry);
  var
    I: Integer;
    Prnt: TgdClassEntry;
  begin
    if APrnt = nil then
      Prnt := Find(F.Name)
    else
    begin
      Prnt := APrnt.FindChild(F.Name);
      if Prnt = nil then
        Prnt := _Create(APrnt, TgdStorageEntry, F.Name, F.ReadString('Caption'));
    end;

    for I := 0 to F.FoldersCount - 1 do
      IterateStorage(F.Folders[I], Prnt);
  end;

var
  I, J, Index: Integer;
  R: TatRelation;
  CEAttrUserDefined,
  CEAttrUserDefinedLBRBTree,
  CEAttrUserDefinedTree,
  CEUserDocument,
  CEUserDocumentLine,
  CEInvDocument,
  CEInvDocumentLine,
  CEInvPriceList,
  CEInvPriceListLine,
  CEInvRemains,
  CEInvGoodRemains,
  CE, CEStorage: TgdClassEntry;
  q: TIBSQL;
  FSubTypes: TgsStorageFolder;
  SL: TStringList;
begin
  CEAttrUserDefined := Find('TgdcAttrUserDefined');
  CEAttrUserDefinedTree := Find('TgdcAttrUserDefinedTree');
  CEAttrUserDefinedLBRBTree := Find('TgdcAttrUserDefinedLBRBTree');

  for I := 0 to atDatabase.Relations.Count - 1 do
  begin
    R := atDatabase.Relations[I];

    if R.IsUserDefined then
    begin
      if R.IsStandartRelation then
        LoadRelation(CEAttrUserDefined, R)
      else if R.IsLBRBTreeRelation then
        LoadRelation(CEAttrUserDefinedLBRBTree, R)
      else if R.IsStandartTreeRelation then
        LoadRelation(CEAttrUserDefinedTree, R);
    end;
  end;

  CEUserDocument := Find('TgdcUserDocument');
  CEUserDocumentLine := Find('TgdcUserDocumentLine');
  CEInvDocument := Find('TgdcInvDocument');
  CEInvDocumentLine := Find('TgdcInvDocumentLine');
  CEInvPriceList := Find('TgdcInvPriceList');
  CEInvPriceListLine := Find('TgdcInvPriceListLine');

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT dt.* FROM gd_documenttype dt ' +
      'WHERE dt.classname > '''' AND dt.documenttype = ''D'' ORDER BY lb';
    q.ExecQuery;
    while not q.EOF do
    begin
      if CompareText(q.FieldbyName('classname').AsString, 'TgdcUserDocumentType') = 0 then
        LoadDocument(CEUserDocument, q)
      else if CompareText(q.FieldbyName('classname').AsString, 'TgdcInvDocumentType') = 0 then
        LoadDocument(CEInvDocument, q)
      else if CompareText(q.FieldbyName('classname').AsString, 'TgdcInvPriceListType') = 0 then
        LoadDocument(CEInvPriceList, q)
      else
        q.Next;
    end;

    CEInvRemains := Find('TgdcInvRemains');
    CEInvGoodRemains := Find('TgdcInvGoodRemains');

    q.Close;
    q.SQL.Text := 'SELECT name, ruid FROM inv_balanceoption';
    q.ExecQuery;
    while not q.EOF do
    begin
      _Create(CEInvRemains, TgdClassEntry,
        q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);
      _Create(CEInvGoodRemains, TgdClassEntry,
        q.FieldByName('ruid').AsString, q.FieldByName('name').AsString);
      q.Next;
    end;

    CopySubTree(CEInvDocument, CEInvRemains);
    CopySubTree(CEInvDocument, CEInvGoodRemains);
    CopySubTree(CEInvDocument, Find('TgdcSelectedGood'));
  finally
    q.Free;
  end;

  CopySubTree(CEUserDocument, CEUserDocumentLine);
  CopySubTree(CEInvDocument, CEInvDocumentLine);
  CopySubTree(CEInvPriceList, CEInvPriceListLine);

  FSubTypes := GlobalStorage.OpenFolder('\SubTypes', False, False);
  try
    if FSubTypes <> nil then
    begin
      // support old format
      if FSubTypes.ValuesCount > 0 then
      begin
        SL := TStringList.Create;
        try
          for I := 0 to FSubTypes.ValuesCount - 1 do
          begin
            CEStorage := Find(FSubTypes.Values[I].Name);
            if CEStorage <> nil then
            begin
              SL.CommaText := FSubTypes.Values[I].AsString;
              for J := 0 to SL.Count - 1 do
              begin
                if CEStorage.FindChild(SL.Values[SL.Names[J]]) = nil then
                  _Create(CEStorage, TgdStorageEntry, SL.Values[SL.Names[J]], SL.Names[J]);
              end;
            end;
          end;
        finally
          SL.Free;
        end;
      end;

      IterateStorage(FSubTypes, nil);
    end;
  finally
    GlobalStorage.CloseFolder(FSubTypes);
  end;
end;

function TgdClassList.Add(const AClassName: AnsiString; const ASubType,
  AParentSubType: TgdcSubType; const ACaption: String): TgdClassEntry;
var
  Index: Integer;
  Prnt: TgdClassEntry;
  AClass: TClass;
begin
  Result := Find(AClassName, ASubType);

  if Result <> nil then
  begin
    if Result.FCaption = '' then
      Result.FCaption := ACaption;
  end else
  begin
    if AParentSubType > '' then
    begin
      Prnt := Find(AClassName, AParentSubType);
      if Prnt = nil then
        raise Exception.Create('Invalid parent subtype');
      AClass := Prnt.TheClass;
    end else
    begin
      if ASubType > '' then
      begin
        Prnt := Find(AClassName);
        if Prnt = nil then
          raise Exception.Create('Invalid class name');
        AClass := Prnt.TheClass;
      end else
      begin
        AClass := GetClass(AClassName);
        if (AClass = TgdcBase) or (AClass = TgdcCreateableForm) then
          Prnt := nil
        else if AClass = nil then
          raise Exception.Create('Invalid class name')
        else
          Prnt := Add(AClass.ClassParent, '', '', '');
      end;    
    end;

    Result := _Create(Prnt, TgdClassEntry, ASubType, ACaption);
  end;
end;

procedure TgdClassList._Compact;
var
  B, E: Integer;
begin
  B := 0;
  while B < FCount do
  begin
    E := B;
    while (E < FCount) and (FClasses[E] = nil) do
      Inc(E);
    if E = FCount then
    begin
      FCount := B;
      break;
    end;
    if E > B then
    begin
      System.Move(FClasses[E], FClasses[B], (FCount - E) * SizeOf(FClasses[0]));
      Dec(FCount, E - B);
    end;
    Inc(B);
  end;
end;

function TgdClassList._Create(APrnt: TgdClassEntry; AClass: CgdClassEntry;
  ASubType: TgdcSubType; ACaption: String): TgdClassEntry;
var
  Index: Integer;
begin
  Result := AClass.Create(APrnt, APrnt.TheClass, ASubType, ACaption);
  APrnt.AddChild(Result);

  if not _Find(Result.TheClass.ClassName, Result.SubType, Index) then
    _Insert(Index, Result)
  else
    raise Exception.Create('Internal consistency check');
end;

procedure TgdClassList.Remove(const AClassName: String;
  const ASubType: TgdcSubType);
var
  Index: Integer;
  OL: TObjectList;
  I: Integer;
begin
  if _Find(AClassName, ASubType, Index) then
  begin
    if FClasses[Index].Parent <> nil then
      FClasses[Index].Parent.RemoveChild(FClasses[Index]);
    OL := TObjectList.Create(False);
    try
      FClasses[Index].Traverse(OL, False);
      FClasses[Index].Free;
      System.Move(FClasses[Index + 1], FClasses[Index],
        (FCount - Index - 1) * SizeOf(FClasses[0]));
      Dec(FCount);
      for I := OL.Count - 1 downto 0 do
      begin
        if _Find(TgdClassEntry(OL[I]).TheClass.ClassName, TgdClassEntry(OL[I]).SubType, Index) then
        begin
          FClasses[Index].Free;
          System.Move(FClasses[Index + 1], FClasses[Index],
            (FCount - Index - 1) * SizeOf(FClasses[0]));
          Dec(FCount);
        end;
      end;
    finally
      OL.Free;
    end;
  end;
end;

initialization
  _gdClassList := nil;
  gdcObjectList := TObjectList.Create(False);

finalization
  FreeAndNil(gdcObjectList);
  FreeAndNil(_gdClassList);

{$IFDEF METHODSCHECK}
  if dbgMethodList <> nil then
  begin
    try
      dbgMethodList.SaveToFile(ExtractFilePath(Application.ExeName) + 'MethodList.txt');
    except
    end;
    dbgMethodList.Free;
  end;
{$ENDIF}

{$IFDEF DEBUG}
  Assert(glbParamCount = 0, 'Удалены не все параметры');
  Assert(glbMethodCount = 0, 'Удалены не все методы');
  Assert(glbMethodListCount = 0, 'Удалены не все m-list');
  Assert(glbClassMethodCount = 0, 'Удалены не все CM');
  Assert(glbClassListCount = 0, 'Удалены не все CL');
{$ENDIF}
end.

