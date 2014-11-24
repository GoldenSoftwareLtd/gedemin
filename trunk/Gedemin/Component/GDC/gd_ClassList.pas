
{++

  Copyright (c) 2001 - 2014 by Golden Software of Belarus

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
  keyGetCurrRecordSubType  = 112;
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

  //Классы пользовательских таблиц
  UserDefinedClasses: array[0..7] of String = (
  'TgdcAttrUserDefined',
  'Tgdc_frmAttrUserDefined',
  'Tgdc_dlgAttrUserDefined',
  'TgdcAttrUserDefinedTree',
  'Tgdc_frmAttrUserDefinedTree',
  'Tgdc_dlgAttrUserDefinedTree',
  'TgdcAttrUserDefinedLBRBTree',
  'Tgdc_frmAttrUserDefinedLBRBTree');

  //Классы докуменотов пользователя
  UserDocumentClasses: array[0..6] of String = (
    //'TgdcUserBaseDocument',
    'TgdcUserDocument',
    'TgdcUserDocumentLine',
    'Tgdc_dlgUserComplexDocument',
    'Tgdc_dlgUserDocumentLine',
    'Tgdc_dlgUserSimpleDocument',
    'Tgdc_frmUserComplexDocument',
    'Tgdc_frmUserSimpleDocument');

  //Классы складских документов
  InvDocumentClasses: array[0..14] of String = (
    'TgdcSelectedGood',
    //'TgdcInvBaseRemains',
    'TgdcInvGoodRemains',
    'TgdcInvRemains',
    'TgdcInvMovement',
    //'TgdcInvBaseDocument',
    'TgdcInvDocument',
    'TgdcInvDocumentLine',
    'TdlgInvDocument',
    'TdlgInvDocumentLine',
    'Tgdc_frmInvBaseRemains',
    'Tgdc_frmInvBaseSelectRemains',
    'Tgdc_frmInvSelectGoodRemains',
    'Tgdc_frmInvSelectRemains',
    'Tgdc_frmInvViewRemains',
    'Tgdc_frmInvSelectedGoods',
    'Tgdc_frmInvDocument');

  //Классы прайс листов
  InvPriceListClasses: array[0..4] of String = (
    //'TgdcInvBasePriceList',
    'TgdcInvPriceList',
    'TgdcInvPriceListLine',
    'TdlgInvPriceLine',
    'TdlgInvPriceList',
    'Tgdc_frmInvPriceList');

  //Классы остатков
  RemainsClasses: array[0..6] of String = (
    //'TgdcInvBaseRemains',
    'TgdcInvGoodRemains',
    'TgdcInvRemains',
    'Tgdc_frmInvBaseRemains',
    'Tgdc_frmInvBaseSelectRemains',
    'Tgdc_frmInvSelectGoodRemains',
    'Tgdc_frmInvSelectRemains',
    'Tgdc_frmInvViewRemains');

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
//    FComment: String;
    FCaption: String;
    FSiblings: TObjectList;
    FInitialized: Boolean;

    function GetSiblings(Index: Integer): TgdClassEntry;
    function GetCount: Integer;
    function GetCaption: String;
    function GetGdcClass: CgdcBase;
    function GetFrmClass: CgdcCreateableForm;
    procedure CheckInitialized;
    procedure ReadFromRelation;
    procedure ReadFromDocumentType;
    procedure ReadFromStorage;

  protected
    function Traverse(ACallback: TgdClassEntryCallback; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function Traverse(ACallback2: TgdClassEntryCallback2; AData1: Pointer; AData2: Pointer;
      const AnIncludeRoot: Boolean = True;
      const AnOnlyDirect: Boolean = False): Boolean; overload;
    function GetSubTypeList(ASubTypeList: TStrings; const AnOnlyDirect: Boolean): Boolean;

    function RemoveFromParent: Boolean;

    procedure RegisterClassHierarchy;
    function Find(const AClassName: AnsiString;
      const ASubType: TgdcSubType = ''): TgdClassEntry;

    procedure SetReadOnly(AReadOnly: Boolean);
    function Add(const AClass: TClass; const ASubType: TgdcSubType = '';
      const ACaption: String = ''; const AParentSubType: TgdcSubType = '';
      AnInitialize: Boolean = False): TgdClassEntry;

  public
    constructor Create(AParent: TgdClassEntry;
      const AClass: TClass; const ASubType: TgdcSubType = ''; const ACaption: String = '');
    destructor Destroy; override;

    function Compare(const AClass: TClass; const ASubType: TgdcSubType = ''): Integer; overload;
    function Compare(const AClassName: AnsiString; const ASubType: TgdcSubType = ''): Integer; overload;
    procedure AddSibling(ASibling: TgdClassEntry);

    property Parent: TgdClassEntry read FParent;
    property TheClass: TClass read FClass;
    property SubType: TgdcSubType read FSubType;
    property gdcClass: CgdcBase read GetGdcClass;
    property frmClass: CgdcCreateableForm read GetFrmClass;
//    property Comment: String read FComment;
    property Caption: String read GetCaption;
    property Count: Integer read GetCount;
    property Siblings[Index: Integer]: TgdClassEntry read GetSiblings;
    property Initialized: Boolean read FInitialized write FInitialized;
    property ClassMethods: TgdClassMethods read FClassMethods;
  end;

  TgdClassList = class(TObject)
  private
    FClasses: array of TgdClassEntry;
    FCount: Integer;

    FReadOnly: Boolean;

    function _Find(const AClassName: AnsiString; const ASubType: TgdcSubType;
      out Index: Integer): Boolean;
    procedure _Insert(const Index: Integer; ACE: TgdClassEntry);
    procedure _Grow;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AClass: TClass; const ASubType: TgdcSubType = ''; const ACaption: String = '';
      const AParentSubType: TgdcSubType = ''): TgdClassEntry;
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

    procedure Remove(const AClass: TClass; const ASubType: TgdcSubType = '');
    // Удаление всех подтипов
    procedure RemoveAllSubTypes;

    procedure AddClassMethods(AClassMethods: TgdClassMethods); overload;
    procedure AddClassMethods(AClass: TComponentClass;
      AMethods: array of TgdMethod); overload;

    function GetGDCClass(const AClassName: String): CgdcBase;
    function GetFrmClass(const AClassName: String): CgdcCreateableForm;

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

procedure RegisterGdClass(AClass: TClass; ASubType: TgdcSubType = '';
  ACaption: String = ''; AParentSubType: TgdcSubType = ''; AnInitialize: Boolean = False);

procedure UnRegisterGdClass(AClass: TClass; ASubType: TgdcSubType = '');


// добавляет класс в список классов
{Регистрация класса в списке TgdcClassList}
procedure RegisterGdcClass(AClass: CgdcBase; ACaption: String = '');
procedure UnRegisterGdcClass(AClass: CgdcBase);
{Регистрация массива классов}
//procedure RegisterGdcClasses(AClasses: array of CgdcBase);
//procedure UnRegisterGdcClasses(AClasses: array of CgdcBase);
// добавляет класс в список классов
{Регистрация класса в списке TgdcClassList}
procedure RegisterFrmClass(AClass: CgdcCreateableForm);
procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
//procedure RegisterFrmClasses(AClasses: array of CgdcCreateableForm);
//procedure UnRegisterFrmClasses(AClasses: array of CgdcCreateableForm);
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

procedure RegisterGdClass(AClass: TClass; ASubType: TgdcSubType = '';
  ACaption: String = ''; AParentSubType: TgdcSubType = ''; AnInitialize: Boolean = False);
var
  CurrCE: TgdClassEntry;
  CEBase: TgdClassEntry;
begin
  if AClass = nil then
    exit;

  if ASubType > '' then
  begin
    CEBase := gdClassList.Find(AClass.ClassName);

    if (CEBase = nil) or (not CEBase.Initialized) then
      exit;
  end;

  if AClass.InheritsFrom(TgdcBase) then
  begin
    Classes.RegisterClass(CgdcBase(AClass));
    CurrCE := gdClassList.Add(CgdcBase(AClass), ASubType, ACaption, AParentSubType);
  end
  else
    if AClass.InheritsFrom(TgdcCreateableForm) then
    begin
      Classes.RegisterClass(CgdcCreateableForm(AClass));
      CurrCE := gdClassList.Add(CgdcCreateableForm(AClass), ASubType, ACaption, AParentSubType);
    end
    else
      raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcBase или TgdcCreateableForm');

  if (CurrCE <> nil) and (AnInitialize) then
    CurrCE.Initialized := True;
end;

procedure UnRegisterGdClass(AClass: TClass; ASubType: TgdcSubType = '');
begin
  if AClass = nil then
    exit;

  if AClass.InheritsFrom(TgdcBase) then
  begin
    if ASubType = '' then
      Classes.UnRegisterClass(CgdcBase(AClass));
    //if Assigned(gdClassList) then
      gdClassList.Remove(CgdcBase(AClass), ASubType);
  end
  else
    if AClass.InheritsFrom(TgdcCreateableForm) then
    begin
      if ASubType = '' then
        Classes.UnRegisterClass(CgdcCreateableForm(AClass));
      //if Assigned(gdClassList) then
        gdClassList.Remove(CgdcCreateableForm(AClass), ASubType);
    end
    else
      raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcBase или TgdcCreateableForm');
end;


procedure RegisterGdcClass(AClass: CgdcBase; ACaption: String = '');
begin
  Assert(AClass <> nil);
  Assert(gdClassList <> nil, AClass.ClassName);

  if not AClass.InheritsFrom(TgdcBase) then
  begin
    raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcBase');
  end;

  Classes.RegisterClass(AClass);
  gdClassList.Add(AClass, '', ACaption);
end;

procedure UnRegisterGdcClass(AClass: CgdcBase);
begin
  UnRegisterClass(AClass);
  //if Assigned(gdClassList) then
    gdClassList.Remove(AClass);
end;

{procedure RegisterGdcClasses(AClasses: array of CgdcBase);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    RegisterGdcClass(AClasses[I]);
end;}

{procedure UnRegisterGdcClasses(AClasses: array of CgdcBase);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    UnRegisterGdcClass(AClasses[I]);
end;}

procedure RegisterFrmClass(AClass: CgdcCreateableForm);
begin
  if not AClass.InheritsFrom(TgdcCreateableForm) then
    raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcCreateableForm');

  Classes.RegisterClass(AClass);
  //if Assigned(gdClassList) then
    gdClassList.Add(AClass);
end;

procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
begin
  UnRegisterClass(AClass);
  //if Assigned(gdClassList) then
    gdClassList.Remove(AClass);
end;

{procedure RegisterFrmClasses(AClasses: array of CgdcCreateableForm);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    RegisterFrmClass(AClasses[I]);
end;}

{procedure UnRegisterFrmClasses(AClasses: array of CgdcCreateableForm);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    UnRegisterFrmClass(AClasses[I]);
end;}

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
//    while Pos(Str[BeginPos - 1], Letters) > 0 do
//      Dec(BeginPos);
    while EndPos + 1 <= L do
    begin
      if Str[EndPos + 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
        Inc(EndPos)
      else
        Break;
    end;

//    while Pos(Str[EndPos], Letters) > 0 do
//      Inc(EndPos);
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
//    CR: Integer;
  begin
    TrimSpace;
//    CR := CursorPos;

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
//        CursorPos := CR;
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
    //if Assigned(gdClassList) then
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

//  CE := nil;
//  if Assigned(gdClassList) then
  CE := gdClassList.Find(FgdcClass.ClassParent);

  if (CE <> nil) and (CE.ClassMethods <> nil) then
    Result := CE.ClassMethods
end;

{TgdClassEntry}

procedure TgdClassEntry.AddSibling(ASibling: TgdClassEntry);
begin
  Assert(ASibling <> nil);
  Assert(ASibling.Parent = Self);
  if FSiblings = nil then
    FSiblings := TObjectList.Create(False);
  FSiblings.Add(ASibling);
end;

function TgdClassEntry.Compare(const AClass: TClass;
  const ASubType: TgdcSubType): Integer;
begin
  Assert(AClass <> nil);
  Result := Compare(AClass.ClassName, ASubType);
end;

constructor TgdClassEntry.Create(AParent: TgdClassEntry;
  const AClass: TClass; const ASubType: TgdcSubType = ''; const ACaption: String = '');
begin
  FParent := AParent;
  FClass := AClass;
  FSubType := ASubType;
  FCaption := ACaption;
  FSiblings := nil;
  FClassMethods := TgdClassMethods.Create(TComponentClass(FClass));
end;

destructor TgdClassEntry.Destroy;
begin
  FSiblings.Free;
  FClassMethods.Free;
  inherited;
end;

function TgdClassEntry.GetCaption: String;
begin
  Result := FCaption;
  if (Result = '') and (Parent <> nil) then
  begin
    Result := Parent.Caption;
  end;
end;

function TgdClassEntry.GetCount: Integer;
begin
  if FSiblings = nil then
    Result := 0
  else
    Result := FSiblings.Count;
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

procedure TgdClassEntry.CheckInitialized;
begin
  if not FInitialized then
    if (FClass.InheritsFrom(TgdcBase))
      or (FClass.InheritsFrom(TgdcCreateableForm)) then
    begin
      RegisterClassHierarchy;
    end
    else
      raise Exception.Create('Not a business or form class.');
end;

procedure TgdClassEntry.ReadFromRelation;
var
  CurrCE: TgdClassEntry;
  CE: TgdClassEntry;
  SL: TStringList;
  I: Integer;
  J: Integer;
  ClassList: TClassList;
begin
  if Initialized then
    exit;

  if (not Assigned(atDatabase)) and (not Assigned(atDatabase.Relations)) then
    exit;

  ClassList := TClassList.Create;
  try
    if SubType > '' then
    begin
      ClassList.Add(TheClass);
      Initialized := True;
    end
    else
      if (TheClass.ClassName =  'TgdcAttrUserDefined')
        or (TheClass.ClassName =  'Tgdc_frmAttrUserDefined')
        or (TheClass.ClassName =  'Tgdc_dlgAttrUserDefined') then
      begin
        CE := Find('TgdcAttrUserDefined', '');
        if (CE <> nil) and (not CE.Initialized) then
        begin
          ClassList.Add(CE.TheClass);
          CE.Initialized := True;
        end;

        CE := Find('Tgdc_frmAttrUserDefined', '');
        if (CE <> nil) and (not CE.Initialized) then
        begin
          ClassList.Add(CE.TheClass);
          CE.Initialized := True;
        end;

        CE := Find('Tgdc_dlgAttrUserDefined', '');
        if (CE <> nil) and (not CE.Initialized) then
        begin
          ClassList.Add(CE.TheClass);
          CE.Initialized := True;
        end;
      end
      else
        if (TheClass.ClassName =  'TgdcAttrUserDefinedTree')
          or (TheClass.ClassName =  'Tgdc_frmAttrUserDefinedTree') then
        begin
          CE := Find('TgdcAttrUserDefinedTree', '');
          if (CE <> nil) and (not CE.Initialized) then
          begin
            ClassList.Add(CE.TheClass);
            CE.Initialized := True;
          end;

          CE := Find('Tgdc_frmAttrUserDefinedTree', '');
          if (CE <> nil) and (not CE.Initialized) then
          begin
            ClassList.Add(CE.TheClass);
            CE.Initialized := True;
          end;
        end
        else
          if (TheClass.ClassName =  'TgdcAttrUserDefinedLBRBTree')
            or (TheClass.ClassName =  'Tgdc_frmAttrUserDefinedLBRBTree') then
          begin
            CE := Find('TgdcAttrUserDefinedLBRBTree', '');
            if (CE <> nil) and (not CE.Initialized) then
            begin
              ClassList.Add(CE.TheClass);
              CE.Initialized := True;
            end;

            CE := Find('Tgdc_frmAttrUserDefinedLBRBTree', '');
            if (CE <> nil) and (not CE.Initialized) then
            begin
              ClassList.Add(CE.TheClass);
              CE.Initialized := True;
            end;
          end
          else
            if TheClass.ClassName =  'Tgdc_dlgAttrUserDefinedTree' then
            begin
              CE := Find('Tgdc_dlgAttrUserDefinedTree', '');
              if (CE <> nil) and (not CE.Initialized) then
              begin
                ClassList.Add(CE.TheClass);
                CE.Initialized := True;
              end;
            end;

    SL := TStringList.Create;
    try
      if SubType > '' then
      begin
        with atDatabase.Relations do
        for I := 0 to Count - 1 do
        if Items[I].IsUserDefined
          and Assigned(Items[I].PrimaryKey)
          and Assigned(Items[I].PrimaryKey.ConstraintFields)
          and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
          and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'INHERITEDKEY') = 0)
          and (AnsiCompareText(Items[I].RelationFields.ByFieldName('INHERITEDKEY').ForeignKey.ReferencesRelation.RelationName,
            SubType) = 0) then
        begin
          SL.Add(Items[I].LName + '=' + Items[I].RelationName);
        end;
      end
      else
        if (TheClass.ClassName =  'TgdcAttrUserDefined')
          or (TheClass.ClassName =  'Tgdc_frmAttrUserDefined')
          or (TheClass.ClassName =  'Tgdc_dlgAttrUserDefined') then
        begin
          with atDatabase.Relations do
            for I := 0 to Count - 1 do
              if Items[I].IsUserDefined
                and Assigned(Items[I].PrimaryKey)
                and Assigned(Items[I].PrimaryKey.ConstraintFields)
                and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                and not Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
              begin
                SL.Add(Items[I].LName + '=' + Items[I].RelationName);
              end;
        end
        else
          if (TheClass.ClassName =  'TgdcAttrUserDefinedTree')
            or (TheClass.ClassName =  'Tgdc_frmAttrUserDefinedTree') then
          begin
            with atDatabase.Relations do
              for I := 0 to Count - 1 do
                if Items[I].IsUserDefined
                  and Assigned(Items[I].PrimaryKey)
                  and Assigned(Items[I].PrimaryKey.ConstraintFields)
                  and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                  and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                  and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                  and not Assigned(Items[I].RelationFields.ByFieldName('LB'))
                  and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
                begin
                  SL.Add(Items[I].LName + '=' + Items[I].RelationName);
                end;
          end
          else
            if (TheClass.ClassName =  'TgdcAttrUserDefinedLBRBTree')
              or (TheClass.ClassName =  'Tgdc_frmAttrUserDefinedLBRBTree') then
            begin
              with atDatabase.Relations do
                for I := 0 to Count - 1 do
                  if Items[I].IsUserDefined
                    and Assigned(Items[I].PrimaryKey)
                    and Assigned(Items[I].PrimaryKey.ConstraintFields)
                    and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                    and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                    and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                    and Assigned(Items[I].RelationFields.ByFieldName('LB'))
                    and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
                  begin
                    SL.Add(Items[I].LName + '=' + Items[I].RelationName);
                  end;
            end
            else
              if TheClass.ClassName =  'Tgdc_dlgAttrUserDefinedTree' then
              begin
                with atDatabase.Relations do
                  for I := 0 to Count - 1 do
                    if Items[I].IsUserDefined
                      and Assigned(Items[I].PrimaryKey)
                      and Assigned(Items[I].PrimaryKey.ConstraintFields)
                      and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
                      and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
                      and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
                      and not Assigned(Items[I].RelationFields.ByFieldName('INHERITEDKEY'))then
                    begin
                      SL.Add(Items[I].LName + '=' + Items[I].RelationName);
                    end;
              end
              else
                raise Exception.Create('Not a relation class.');

      for I := 0 to SL.Count - 1 do
        for J := 0 to ClassList.Count - 1 do
        begin
          CurrCE := Add(ClassList[J], SL.Values[SL.Names[I]], SL.Names[I], SubType);
          if CurrCE <> nil then
            CurrCE.ReadFromRelation;
        end;

    finally
      SL.Free;
    end;
  finally
    ClassList.Free;
  end;
end;

procedure TgdClassEntry.ReadFromDocumentType;
var
  UserDocumentClassList: TClassList;
  InvDocumentClassList: TClassList;
  InvPriceClassList: TClassList;
  RemainsClassList: TClassList;
  CurrClassList: TClassList;
  CE: TgdClassEntry;
  ibsql: TIBSQL;
  LSubType: string;
  LCaption: String;
  LParentSubType: string;
  LClassName: String;
  DidActivate: Boolean;
  I: Integer;
  J: Integer;
begin
  if Initialized then
    exit;

  if (IBLogin = nil) or (not IBLogin.LoggedIn) then
    exit;

  if (not Assigned(gdcBaseManager))
    or (not Assigned(gdcBaseManager.ReadTransaction)) then
  begin
    exit;
  end;

  UserDocumentClassList := TClassList.Create;
  InvDocumentClassList := TClassList.Create;
  InvPriceClassList := TClassList.Create;
  RemainsClassList := TClassList.Create;
  try
    for I := Low(UserDocumentClasses) to High(UserDocumentClasses) do
    begin
      CE := Find(UserDocumentClasses[I], '');

      if (CE <> nil) and (not CE.Initialized) then
      begin
        UserDocumentClassList.Add(CE.TheClass);
        CE.Initialized := True;
      end;
    end;

    for I := Low(InvDocumentClasses) to High(InvDocumentClasses) do
    begin
      CE := Find(InvDocumentClasses[I], '');

      if (CE <> nil) then
        for J := Low(RemainsClasses) to High(RemainsClasses) do
          if InvDocumentClasses[I] = RemainsClasses[J] then
          begin
            RemainsClassList.Add(CE.TheClass);
            break;
          end;

      if (CE <> nil) and (not CE.Initialized) then
      begin
        InvDocumentClassList.Add(CE.TheClass);
        CE.Initialized := True;
      end;
    end;

    for I := Low(InvPriceListClasses) to High(InvPriceListClasses) do
    begin
      CE := Find(InvPriceListClasses[I], '');

      if (CE <> nil) and (not CE.Initialized) then
      begin
        InvPriceClassList.Add(CE.TheClass);
        CE.Initialized := True;
      end;
    end;

    if (UserDocumentClassList.Count > 0)
      or (InvDocumentClassList.Count > 0)
      or (InvDocumentClassList.Count > 0) then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        DidActivate := not ibsql.Transaction.Active;
        if DidActivate then
          ibsql.Transaction.StartTransaction;
        ibsql.SQL.Text :=
          'SELECT '#13#10 +
          '  dt.name AS caption, '#13#10 +
          '  dt.classname AS classname, '#13#10 +
          '  dt.ruid AS subtype, '#13#10 +
          '  dt1.ruid AS parentsubtype '#13#10 +
          'FROM gd_documenttype dt '#13#10 +
          'LEFT JOIN gd_documenttype dt1 '#13#10 +
          '  ON dt1.id = dt.parent '#13#10 +
          '  AND dt1.documenttype = ''D'' '#13#10 +
          'WHERE '#13#10 +
          '  dt.documenttype = ''D'' '#13#10 +
          '  and (dt.classname = ''TgdcUserDocumentType'' '#13#10 +
          '  or dt.classname = ''TgdcInvDocumentType'' '#13#10 +
          '  or dt.classname = ''TgdcInvPriceListType'') '#13#10 +
          'ORDER BY dt.parent';

        ibsql.ExecQuery;

        while not ibsql.EOF do
        begin
          LSubType := ibsql.FieldByName('subtype').AsString;
          LCaption := ibsql.FieldByName('caption').AsString;
          LParentSubType := ibsql.FieldByName('parentsubtype').AsString;
          LClassName := ibsql.FieldByName('classname').AsString;

          if LClassName = 'TgdcUserDocumentType' then
          begin
            CurrClassList := UserDocumentClassList;
          end
          else
            if LClassName = 'TgdcInvDocumentType' then
            begin
              CurrClassList := InvDocumentClassList;
            end
            else
              CurrClassList := InvPriceClassList;

          for I := 0 to CurrClassList.Count - 1 do
            Add(CurrClassList[I], LSubType, LCaption, LParentSubType, True);

          ibsql.Next;
        end;


        ibsql.Close;

        if RemainsClassList.Count > 0 then
        begin

          ibsql.SQL.Text :=
            'SELECT NAME, RUID FROM INV_BALANCEOPTION ';

          ibsql.ExecQuery;

          while not ibsql.EOF do
          begin
            LSubType := ibsql.FieldByName('RUID').AsString;
            LCaption := ibsql.FieldByName('NAME').AsString;

            for I := 0 to RemainsClassList.Count - 1 do
              Add(RemainsClassList[I], LSubType, LCaption, '', True);

            ibsql.Next;
          end;
        end;

        if DidActivate then
          ibsql.Transaction.Commit;
      finally
        ibsql.Free;
      end;
    end;
  finally
    UserDocumentClassList.Free;
    InvDocumentClassList.Free;
    InvPriceClassList.Free;
    RemainsClassList.Free;
  end;
end;

procedure TgdClassEntry.ReadFromStorage;
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  ValueName: String;
  I: Integer;
  CurrCE: TgdClassEntry;
  SL: TStringList;
begin
  if not Assigned(GlobalStorage) then
    exit;

  if Initialized then
    exit;

  Initialized := True;

  SL := TStringList.Create;
  try
    F := GlobalStorage.OpenFolder('SubTypes', False, False);
    try
      if F <> nil then
      begin
        if SubType > '' then
          ValueName := TheClass.ClassName + SubType
        else
          ValueName := TheClass.ClassName;
        V := F.ValueByName(ValueName);
        if V is TgsStringValue then
          SL.CommaText := V.AsString
        else if V <> nil then
          F.DeleteValue(ValueName);
      end;
    finally
      GlobalStorage.CloseFolder(F, False);
    end;

    for I := 0 to SL.Count - 1 do
    begin
      CurrCE := Add(TheClass, SL.Values[SL.Names[I]], SL.Names[I], SubType);

      if CurrCE <> nil then
        CurrCE.ReadFromStorage;
    end;
  finally
    SL.Free;
  end;
end;

function TgdClassEntry.GetSiblings(Index: Integer): TgdClassEntry;
begin
  Assert(FSiblings[Index] <> nil);
  Result := FSiblings[Index] as TgdClassEntry;
end;

function TgdClassEntry.GetSubTypeList(ASubTypeList: TStrings;
  const AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(ASubTypeList <> nil);

  Result := False;

  CheckInitialized;

  for I := 0 to Count - 1 do
  begin
    if Siblings[I].SubType > '' then
    begin
      ASubTypeList.Add(Siblings[I].Caption + '=' + Siblings[I].SubType);
      Result := True;

      if not AnOnlyDirect then
        Result := Siblings[I].GetSubTypeList(ASubTypeList, False) or Result;
    end;
  end;
end;

function TgdClassEntry.RemoveFromParent: Boolean;
var
  I: Integer;
begin
  Result := False;
  if (Parent <> nil) and (Parent.FSiblings <> nil) then
    for I := Parent.Count - 1 downto 0 do
      if Parent.Siblings[I] = Self then
      begin
        Parent.FSiblings.Delete(I);
        Result := True;
        break;
      end;
end;

procedure TgdClassEntry.RegisterClassHierarchy;
var
  Flag: Boolean;
  I: Integer;
begin
  Flag := False;

  for I := Low(UserDefinedClasses) to High(UserDefinedClasses) do
  begin
    if TheClass.ClassName = UserDefinedClasses[I] then
    begin
      Flag := True;
      break;
    end
  end;

  if Flag then
  begin
    ReadFromRelation;
    exit;
  end
  else
    for I := Low(UserDocumentClasses) to High(UserDocumentClasses) do
    begin
      if TheClass.ClassName = UserDocumentClasses[I] then
      begin
        Flag := True;
        break;
      end
    end;

  if Flag then
  begin
    ReadFromDocumentType;
    exit;
  end
  else
    for I := Low(InvDocumentClasses) to High(InvDocumentClasses) do
    begin
      if TheClass.ClassName = InvDocumentClasses[I] then
      begin
        Flag := True;
        break;
      end
    end;

  if Flag then
  begin
    ReadFromDocumentType;
    exit;
  end
  else
    for I := Low(InvPriceListClasses) to High(InvPriceListClasses) do
    begin
      if TheClass.ClassName = InvPriceListClasses[I] then
      begin
        Flag := True;
        break;
      end
    end;

  if Flag then
  begin
    ReadFromDocumentType;
    exit;
  end
  else
    if TheClass.InheritsFrom(TgdcBase)
      or TheClass.InheritsFrom(TgdcCreateableForm) then
    begin
      ReadFromStorage;
      exit;
    end
    else
      raise Exception.Create('unknown class.');
end;

function TgdClassEntry.Find(const AClassName: AnsiString;
  const ASubType: TgdcSubType = ''): TgdClassEntry;
begin
  Assert(AClassName <> '');
  Result := gdClassList.Find(AClassName, ASubType);
end;

procedure TgdClassEntry.SetReadOnly(AReadOnly: Boolean);
begin
  gdClassList.FReadOnly := AReadOnly
end;

function TgdClassEntry.Add(const AClass: TClass; const ASubType: TgdcSubType = '';
  const ACaption: String = ''; const AParentSubType: TgdcSubType = '';
  AnInitialize: Boolean = False): TgdClassEntry;
begin
  Result := gdClassList.Add(AClass, ASubType, ACaption, AParentSubType);
  if Result <> nil then
    Result.Initialized := AnInitialize;
end;

function TgdClassEntry.Traverse(ACallback: TgdClassEntryCallback;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback));

  SetReadOnly(False);

  CheckInitialized;

  SetReadOnly(True);
  try
    if AnIncludeRoot then
      Result := ACallback(Self, AData1, AData2)
    else
      Result := True;

    I := 0;
    while Result and (I < Count) do
    begin
      if AnOnlyDirect then
        Result := Result and ACallback(Siblings[I], AData1, AData2)
      else
        Result := Result and Siblings[I].Traverse(ACallback, AData1, AData2, True, False);
      Inc(I);
    end;
  finally
    SetReadOnly(False);
  end;
end;

function TgdClassEntry.Traverse(ACallback2: TgdClassEntryCallback2;
  AData1: Pointer; AData2: Pointer; const AnIncludeRoot, AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(Assigned(ACallback2));

  SetReadOnly(False);

  CheckInitialized;

  SetReadOnly(True);
  try
    if AnIncludeRoot then
      Result := ACallback2(Self, AData1, AData2)
    else
      Result := True;

    I := 0;
    while Result and (I < Count) do
    begin
      if AnOnlyDirect then
        Result := Result and ACallback2(Siblings[I], AData1, AData2)
      else
        Result := Result and Siblings[I].Traverse(ACallback2, AData1, AData2, True, False);
      Inc(I);
    end;
  finally
    SetReadOnly(False);
  end;
end;

function TgdClassEntry.Compare(const AClassName: AnsiString;
  const ASubType: TgdcSubType): Integer;
begin
  Result := AnsiCompareText(FClass.ClassName, AClassName);
  if Result = 0 then
    Result := AnsiCompareText(FSubType, ASubType);
end;

{TgdClassList}

{function TgdClassList.GetGDCClass(const AFullClassName: TgdcFullClassName): CgdcBase;
var
  CE: TgdClassEntry;
begin
  CE := Find(AFullClassName.gdClassName, AFullClassName.SubType);

  if CE <> nil then
    Result := CE.gdcClass
  else
    Result := nil;
end;}

{function TgdClassList.GetFrmClass(const AFullClassName: TgdcFullClassName): CgdcCreateableForm;
var
  CE: TgdClassEntry;
begin
  CE := Find(AFullClassName.gdClassName, AFullClassName.SubType);

  if CE <> nil then
    Result := CE.frmClass
  else
    Result := nil;
end;}

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

function TgdClassList.Add(const AClass: TClass; const ASubType: TgdcSubType;
  const ACaption: String; const AParentSubType: TgdcSubType): TgdClassEntry;
var
  Index: Integer;
  Prnt: TgdClassEntry;
begin
  if FReadOnly then
    raise Exception.Create('The gdClassList is in a read-only mode.');

  if AClass = nil then
  begin
    Result := nil;
    exit;
  end;

  Result := Find(AClass, ASubType);

  if Result <> nil then
  begin
    if (Result.SubType = '')
      and (ACaption > '')
      and (Result.FCaption <> ACaption) then
    begin
      Result.FCaption := ACaption;
    end;
    exit;
  end;

  if ASubType > '' then
    Prnt := Add(AClass, AParentSubType)
  else
    if (AClass = TgdcBase) or (AClass = TgdcCreateableForm) then
      Prnt := nil
    else
      Prnt := Add(AClass.ClassParent);

  Result := TgdClassEntry.Create(Prnt, AClass, ASubType, ACaption);

  if Prnt <> nil then
    Prnt.AddSibling(Result);

  if not _Find(AClass.ClassName, ASubType, Index) then
    _Insert(Index, Result)
  else
    raise Exception.Create('Internal consistency check');
end;

constructor TgdClassList.Create;
begin
  inherited;
  FReadOnly := False;
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
var
  Index: Integer;
  SL: TStringList;
  I: Integer;
begin
  if FReadOnly then
    raise Exception.Create('removal of class can not be. gdClassList is read-only');

  if AClass = nil then
    exit;

  if _Find(AClass.ClassName, ASubType, Index) then
  begin
    (FClasses[Index] as TgdClassEntry).RemoveFromParent;
    SL := TStringList.Create;
    try
      Traverse(AClass, ASubType, GetRemoveList, @SL, nil, True, False);
      for I := SL.Count - 1 downto 0 do
      begin
        if _Find(SL.Names[I], ValueFromString(SL[I]), Index) then
        begin
          FClasses[Index].Free;
          System.Move(FClasses[Index + 1], FClasses[Index],
            (FCount - Index - 1) * SizeOf(FClasses[0]));
          Dec(FCount);
        end
        else
          raise Exception.Create('Класс не найден');
      end;
    finally
      SL.Free;
    end;
  end;
end;

function GetAllSubTypes(ACE: TgdClassEntry; AData1: Pointer; AData2: Pointer): Boolean;
begin
  if ACE.SubType <> '' then
    TStringList(AData1^).Add(ACE.TheClass.ClassName + '=' + ACE.SubType);

  Result := True;
end;

procedure ResetIntialize(ACE: TgdClassEntry);
var
  I: Integer;
begin
  if ACE.SubType <> '' then
    raise Exception.Create('Класс с подтипом');

  ACE.Initialized := False;

  if ACE.FSiblings <> nil then
    for I := 0 to ACE.Count - 1 do
    begin
      ResetIntialize(ACE.Siblings[I]);
    end;
end;

procedure TgdClassList.RemoveAllSubTypes;
var
  Index: Integer;
  SL: TStringList;
  I: Integer;
  CE: TgdClassEntry;
begin
  if FReadOnly then
    raise Exception.Create('removal of classes can not be. gdClassList is read-only');

  if _Find('TgdcBase', '', Index) then
  begin
    SL := TStringList.Create;
    try
      Traverse(TgdcBase, '', GetAllSubTypes, @SL, nil, True, False);
      for I := SL.Count - 1 downto 0 do
      begin
        if _Find(SL.Names[I], ValueFromString(SL[I]), Index) then
        begin
          if (FClasses[Index] as TgdClassEntry).Parent <> nil then
            (FClasses[Index] as TgdClassEntry).RemoveFromParent;

          FClasses[Index].Free;
          System.Move(FClasses[Index + 1], FClasses[Index],
            (FCount - Index - 1) * SizeOf(FClasses[0]));
          Dec(FCount);
        end
        else
          raise Exception.Create('Класс не найден');
      end;
    finally
      SL.Free;
    end;
  end
  else
    raise Exception.Create('Класс не найден');

  CE := Find(TgdcBase, '');

  if CE = nil then
    raise Exception.Create('Класс не найден');

  ResetIntialize(CE);

  if _Find('TgdcCreateableForm', '', Index) then
  begin
    SL := TStringList.Create;
    try
      Traverse(TgdcCreateableForm, '', GetAllSubTypes, @SL, nil, True, False);
      for I := SL.Count - 1 downto 0 do
      begin
        if _Find(SL.Names[I], ValueFromString(SL[I]), Index) then
        begin
          if (FClasses[Index] as TgdClassEntry).Parent <> nil then
            (FClasses[Index] as TgdClassEntry).RemoveFromParent;
          FClasses[Index].Free;
          System.Move(FClasses[Index + 1], FClasses[Index],
            (FCount - Index - 1) * SizeOf(FClasses[0]));
          Dec(FCount);
        end
        else
          raise Exception.Create('Класс не найден');
      end;
    finally
      SL.Free;
    end;
  end
  else
    raise Exception.Create('Класс не найден');

  CE := Find(TgdcCreateableForm, '');

  if CE = nil then
    raise Exception.Create('Класс не найден');
    
  ResetIntialize(CE);

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

function TgdClassList.Find(const AClassName: AnsiString;
  const ASubType: TgdcSubType): TgdClassEntry;
var
  Index: Integer;
begin
  if _Find(AClassName, ASubType, Index) then
    Result := FClasses[Index]
  else
    Result := nil;

  if (Result = nil) and (ASubType <> '') then
  begin
    if _Find(AClassName, '', Index) then
      Result := FClasses[Index]
    else
      Result := nil;   

    if (Result <> nil) and (not Result.Initialized) then
    begin
      Result.CheckInitialized;

      if _Find(AClassName, ASubType, Index) then
        Result := FClasses[Index]
      else
        Result := nil;
    end
    else
      Result := nil;
  end;
end;

function TgdClassList.Find(const AFullClassName: TgdcFullClassName): TgdClassEntry;
begin
  Result := Find(AFullClassName.gdClassName, AFullClassName.SubType);
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

