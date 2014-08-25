
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
  ClassesHashTableSize = 1024;

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

    TgdClassEntry = class(TObject)
  private
    FParent: TgdClassEntry;
    FClass: TClass;
    FClassMethods: TgdClassMethods;
    FSubType: TgdcSubType;
    FCaption: String;
    FSiblings: TObjectList;
    FInitialized: Boolean;

    function GetSiblings(Index: Integer): TgdClassEntry;
    function GetCount: Integer;

  public
    constructor Create(AParent: TgdClassEntry;
      const AClass: TClass; const ASubType: TgdcSubType = '');
    destructor Destroy; override;

    function Compare(const AClass: TClass; const ASubType: TgdcSubType = ''): Boolean;
    procedure AddSibling(ASibling: TgdClassEntry);
    function GetSubTypeList(ASubTypeList: TStrings; const AnOnlyDirect: Boolean): Boolean;

    property Parent: TgdClassEntry read FParent;
    property TheClass: TClass read FClass;
    property SubType: TgdcSubType read FSubType;
    property Caption: String read FCaption;
    property Count: Integer read GetCount;
    property Siblings[Index: Integer]: TgdClassEntry read GetSiblings;
    property Initialized: Boolean read FInitialized write FInitialized;
  end;

  TgdClassList = class(TObject)
  private
    FHashTable: array[0..ClassesHashTableSize - 1] of TObject;

    FClassList: THashedStringList;

    function GetHash(AClass: TClass; const ASubType: TgdcSubType): Cardinal;

    function GetClass(Index: Integer): TComponentClass;
    function GetClassMethods(Index: Integer): TgdClassMethods;
    function GetCount: Integer;
    function GetCustomClass(const AFullClassName: TgdcFullClassName): TComponentClass;

  public
    constructor Create;
    destructor Destroy; override;

    function Add(const AClass: TClass; const ASubType: TgdcSubType = '';
      const AParentSubType: TgdcSubType = ''): TgdClassEntry;
    function Find(const AClass: TClass; const ASubType: TgdcSubType = ''): TgdClassEntry;

    procedure Remove(const AClass: TClass; const ASubType: TgdcSubType = '');
    // Удаление всех подтипов
    procedure RemoveAll;
    function IndexOf(AClass: TClass): Integer;
    function IndexOfByName(AFullClassName: TgdcFullClassName): Integer;

    function AddClassMethods(AClassMethods: TgdClassMethods): Integer; overload;
    function AddClassMethods(AClass: TComponentClass;
      AMethods: array of TgdMethod): Integer; overload;

    procedure Clear;

    property gdcItems[Index: Integer]: TgdClassMethods read GetClassMethods;
    property Count: Integer read GetCount;
  end;

  // Класс для хранения классов наследников TgdcBase с описанием методов
  TgdcClassList = class(TgdClassList)
  private
    function GetItems(Index: Integer): CgdcBase;
  public
    // Возращает класс CgdcBase по имени класса
    // Если класс не зарегистрирован, то nill
    function GetGDCClass(const AFullClassName: TgdcFullClassName): CgdcBase;

    // Возращает класс CgdcBase по индексу
    property Items[Index: Integer] : CgdcBase read GetItems; default;
  end;

  // Класс для хранения классов наследников TgdcCreateableForm с описанием методов
  TfrmClassList = class(TgdClassList)
  private
    function GetItems(Index: Integer): CgdcCreateableForm;

  public
    // Возращает класс CgdcFullClassName по имени класса
    // Если класс не зарегистрирован, то nill
    function GetFrmClass(const AFullClassName: TgdcFullClassName): CgdcCreateableForm;

    // Возращает класс CgdcFullClassName по индексу
    property Items[Index: Integer] : CgdcCreateableForm read GetItems; default;
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

  // для GDC-классов
  gdcClassList: TgdcClassList;
  // для форм
  frmClassList: TfrmClassList;

// добавляет класс в список классов
{Регистрация класса в списке TgdcClassList}
procedure RegisterGdcClass(AClass: CgdcBase);
procedure UnRegisterGdcClass(AClass: CgdcBase);
{Регистрация массива классов}
procedure RegisterGdcClasses(AClasses: array of CgdcBase);
procedure UnRegisterGdcClasses(AClasses: array of CgdcBase);
// добавляет класс в список классов
{Регистрация класса в списке TgdcClassList}
procedure RegisterFrmClass(AClass: CgdcCreateableForm);
procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
procedure RegisterFrmClasses(AClasses: array of CgdcCreateableForm);
procedure UnRegisterFrmClasses(AClasses: array of CgdcCreateableForm);
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
  SysUtils, gs_Exception
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

procedure CheckGdcClassListAssigned;
begin
  if not Assigned(gdcClassList) then
  begin
    {$IFDEF DEBUG}
    if UseLog then
      Log.LogLn('gdcClassList был создан');
    {$ENDIF}
    gdcClassList := TgdcClassList.Create;
  end;
end;

procedure RegisterGdcClass(AClass: CgdcBase);
begin
  if not AClass.InheritsFrom(TgdcBase) then
  begin
    raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcBase');
  end;

  CheckGdcClassListAssigned;

  Classes.RegisterClass(AClass);

  gdcClassList.Add(AClass);
end;

procedure UnRegisterGdcClass(AClass: CgdcBase);
begin
  UnRegisterClass(AClass);
  if not Assigned(gdcClassList) then
    Exit;
  gdcClassList.Remove(AClass);
end;

procedure RegisterGdcClasses(AClasses: array of CgdcBase);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    RegisterGdcClass(AClasses[I]);
end;

procedure UnRegisterGdcClasses(AClasses: array of CgdcBase);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    UnRegisterGdcClass(AClasses[I]);
end;

procedure CheckFrmClassListAssigned;
begin
  if not Assigned(frmClassList) then
  begin
    {$IFDEF DEBUG}
    if UseLog then
      Log.LogLn('frmClassList был создан');
    {$ENDIF}
    frmClassList := TfrmClassList.Create;
  end;
end;

procedure RegisterFrmClass(AClass: CgdcCreateableForm);
begin
  if not AClass.InheritsFrom(TgdcCreateableForm) then
    raise Exception.Create('Класс ' + AClass.ClassName +
      ' не наследован от TgdcCreateableForm');

  Classes.RegisterClass(AClass);

  CheckFrmClassListAssigned;

  frmClassList.Add(AClass);
end;

procedure UnRegisterFrmClass(AClass: CgdcCreateableForm);
begin
  UnRegisterClass(AClass);
  if Not Assigned(frmClassList) then
    exit;

  frmClassList.Remove(AClass);
end;

procedure RegisterFrmClasses(AClasses: array of CgdcCreateableForm);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    RegisterFrmClass(AClasses[I]);
end;

procedure UnRegisterFrmClasses(AClasses: array of CgdcCreateableForm);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    UnRegisterFrmClass(AClasses[I]);
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
    begin
      WorkParam;
    end;

    case ATypeList of
      FRM:
        begin
          CheckFrmClassListAssigned;
          frmClassList.AddClassMethods(AnClass, Method)
        end;
      GDC:
        begin
          CheckGdcClassListAssigned;
          gdcClassList.AddClassMethods(AnClass, Method)
        end;
    end;
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
  Result := AnsiUpperCase(FParamName) = AnsiUpperCase(AParamName);
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
    if AnsiUpperCase(Methods[I].Name) = AnsiUpperCase(AName) then
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

{TgdcClassList}

function TgdcClassList.GetGDCClass(const AFullClassName: TgdcFullClassName): CgdcBase;
var
  LComponentClass: TComponentClass;
begin
  Result := nil;
  LComponentClass := GetCustomClass(AFullClassName);
  if Assigned(LComponentClass) then
    Result := CgdcBase(LComponentClass);
end;

function TgdcClassList.GetItems(Index: Integer): CgdcBase;
begin
  Result := CgdcBase(GetClass(Index));
end;

{TfrmClassList}

function TfrmClassList.GetFrmClass(
  const AFullClassName: TgdcFullClassName): CgdcCreateableForm;
var
  LComponentClass: TComponentClass;
begin
  Result := nil;
  LComponentClass := GetCustomClass(AFullClassName);
  if Assigned(LComponentClass) then
    Result := CgdcCreateableForm(LComponentClass);
end;

function TfrmClassList.GetItems(Index: Integer): CgdcCreateableForm;
begin
  Result := CgdcCreateableForm(GetClass(Index));
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
  FN: TgdcFullClassName;
  I: Integer;
begin
  Result := nil;
  FN.gdClassName := FgdcClass.ClassParent.ClassName;
  FN.SubType := '';
  if FgdcClass.InheritsFrom(TgdcBase) then
  begin
    I := gdcClassList.IndexOfByName(FN);
    Result := gdcClassList.gdcItems[I];
  end else
    if FgdcClass.InheritsFrom(TgdcCreateableForm) then
    begin
      I := frmClassList.IndexOfByName(FN);
      Result := frmClassList.gdcItems[I];
    end;
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
  const ASubType: TgdcSubType): Boolean;
begin
  Result := (AClass = FClass) and AnsiSameText(FSubType, ASubType);
end;

constructor TgdClassEntry.Create(AParent: TgdClassEntry;
  const AClass: TClass; const ASubType: TgdcSubType = '');
begin
  FParent := AParent;
  FClass := AClass;
  FSubType := ASubType;
  FCaption := AClass.ClassName + ASubType;
  FSiblings := nil;
  FClassMethods := TgdClassMethods.Create(TComponentClass(FClass));
end;

destructor TgdClassEntry.Destroy;
begin
  FSiblings.Free;
  FClassMethods.Free;
  inherited;
end;

function TgdClassEntry.GetCount: Integer;
begin
  if FSiblings = nil then
    Result := 0
  else
    Result := FSiblings.Count;  
end;

function TgdClassEntry.GetSiblings(Index: Integer): TgdClassEntry;
begin
  Result := FSiblings[Index] as TgdClassEntry;
end;

function TgdClassEntry.GetSubTypeList(ASubTypeList: TStrings;
  const AnOnlyDirect: Boolean): Boolean;
var
  I: Integer;
begin
  Assert(ASubTypeList <> nil);

  Result := False;

  if FSiblings <> nil then
  begin
    for I := 0 to Count - 1 do
    begin
      if Siblings[I].SubType > '' then
      begin
        ASubTypeList.Add(Siblings[I].SubType + '=' + Siblings[I].SubType);
        Result := True;
      end;

      if not AnOnlyDirect then
        Result := Result or Siblings[I].GetSubTypeList(ASubTypeList, False);
    end;
  end;
end;

{TgdClassList}

function TgdClassList.Add(const AClass: TClass;
  const ASubType: TgdcSubType; const AParentSubType: TgdcSubType): TgdClassEntry;
var
  K: Integer;
  OL: TObjectList;
  Prnt: TgdClassEntry;
begin
  if AClass = nil then
  begin
    Result := nil;
    exit;
  end;

  Result := Find(AClass, ASubType);

  if Result <> nil then
    exit;

  if ASubType = '' then
    if (AClass <> TgdcBase) and (AClass <> TgdcCreateableForm) then
      Prnt := Add(AClass.ClassParent)
    else
      Prnt := nil
  else
    if AParentSubType > '' then
      Prnt := Add(AClass, AParentSubType)
    else
      Prnt := Add(AClass);

  Result := TgdClassEntry.Create(Prnt, AClass, ASubType);

  if (Result <> nil) and (not (ASubType > '')) then
    FClassList.AddObject(AClass.ClassName, Result);

  if Prnt <> nil then
    Prnt.AddSibling(Result);

  K := GetHash(AClass, ASubType) mod ClassesHashTableSize;
  if FHashTable[K] = nil then
    FHashTable[K] := Result
  else if FHashTable[K] is TObjectList then
    TObjectList(FHashTable[K]).Add(Result)
  else begin
    OL := TObjectList.Create(True);
    OL.Add(FHashTable[K]);
    OL.Add(Result);
    FHashTable[K] := OL;
  end;
end;

constructor TgdClassList.Create;
begin
  inherited;

  FillChar(FHashTable, SizeOf(FHashTable), 0);

  FClassList := THashedStringList.Create;
  FClassList.CaseSensitive := False;

  {$IFDEF DEBUG}
  Inc(glbClassListCount);
  {$ENDIF}
end;

destructor TgdClassList.Destroy;
var
  I: Integer;
begin
  for I := 0 to ClassesHashTableSize - 1 do
    FHashTable[I].Free;

  Clear;

  FClassList.Free;

  inherited;

{$IFDEF DEBUG}
  Dec(glbClassListCount);
{$ENDIF}
end;

function TgdClassList.Find(const AClass: TClass;
  const ASubType: TgdcSubType): TgdClassEntry;
var
  K, J: Integer;
  FCE: TgdClassEntry;
begin
  Assert(AClass <> nil);
  K := GetHash(AClass, ASubType) mod ClassesHashTableSize;
  if FHashTable[K] is TgdClassEntry then
  begin
    if TgdClassEntry(FHashTable[K]).Compare(AClass, ASubType) then
      Result := FHashTable[K] as TgdClassEntry
    else
      Result := nil;
  end
  else if FHashTable[K] is TObjectList then
  begin
    Result := nil;
    for J := 0 to TObjectList(FHashTable[K]).Count - 1 do
    begin
      FCE := TObjectList(FHashTable[K])[J] as TgdClassEntry;
      if FCE.Compare(AClass, ASubType) then
      begin
        Result := FCE;
        break;
      end;
    end;
  end else
    Result := nil;
end;

function TgdClassList.GetHash(AClass: TClass; const ASubType: TgdcSubType): Cardinal;
var
  I: Integer;
begin
  Result := 5381 * 33 + Cardinal(AClass);

  for I := 1 to Length(ASubType) do
    Result := (Result shl 5) + Result + Byte(ASubType[I]);
end;

function TgdClassList.GetClass(Index: Integer): TComponentClass;
begin
  Assert((Index >= 0) and (Index < FClassList.Count), 'Index out of range');
  Result := gdcItems[Index].FgdcClass;
end;

function TgdClassList.GetClassMethods(Index: Integer): TgdClassMethods;
begin
  Assert((Index >= 0) and (Index < FClassList.Count), 'Index out of range');
  Result := TgdClassEntry(FClassList.Objects[Index]).FClassMethods;
end;

function TgdClassList.GetCount: Integer;
begin
  Result := FClassList.Count;
end;

function TgdClassList.GetCustomClass(
  const AFullClassName: TgdcFullClassName): TComponentClass;
var
  i: Integer;
begin
  Result := nil;

  i := FClassList.IndexOf(AFullClassName.gdClassName);
  if i > -1 then
    Result := GetClass(i);
end;

procedure TgdClassList.Remove(const AClass: TClass;
  const ASubType: TgdcSubType);
var
  K, J: Integer;
  FCE: TgdClassEntry;
begin
  K := GetHash(AClass, ASubType) mod ClassesHashTableSize;
  if FHashTable[K] is TgdClassEntry then
  begin
    if TgdClassEntry(FHashTable[K]).Compare(AClass, ASubType) then
      FreeAndNil(FHashTable[K]);
  end
  else if FHashTable[K] is TObjectList then
  begin
    for J := 0 to TObjectList(FHashTable[K]).Count - 1 do
    begin
      FCE := TObjectList(FHashTable[K])[J] as TgdClassEntry;
      if FCE.Compare(AClass, ASubType) then
      begin
        TObjectList(FHashTable[K]).Delete(J);
        break;
      end;
    end;
  end;

  if (not (ASubType > '')) and (AClass <> nil) then
  begin
    K := FClassList.IndexOf(AClass.ClassName);
    if K > -1 then
      FClassList.Delete(K);
  end;
end;

procedure TgdClassList.RemoveAll;
var
  I: Integer;
  CE: TgdClassEntry;
begin
  for I := 0 to FClassList.Count - 1 do
  begin
    CE := FClassList.Objects[I] as TgdClassEntry;
    if CE <> nil then
    begin
      FreeAndNil(CE.FSiblings);
      CE.Initialized := False;
    end;
  end;
end;

function TgdClassList.IndexOf(AClass: TClass): Integer;
begin
  Result := FClassList.IndexOf(AClass.ClassName);
end;

function TgdClassList.IndexOfByName(AFullClassName: TgdcFullClassName): Integer;
begin
  Result := FClassList.IndexOf(AFullClassName.gdClassName);
end;

function TgdClassList.AddClassMethods(AClass: TComponentClass;
  AMethods: array of TgdMethod): Integer;
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
      Result := AddClassMethods(VgdClassMethods);
    finally
      VgdMethodList.Free;
    end;
  finally
    VgdClassMethods.Free;
  end;
end;

function TgdClassList.AddClassMethods(
  AClassMethods: TgdClassMethods): Integer;
var
  I: Integer;
begin
  Result := FClassList.IndexOf(AClassMethods.gdcClass.ClassName);

  if Result = -1 then
     Assert(Result <> -1)
   else
     for I := 0 to AClassMethods.gdMethods.Count - 1 do
       gdcItems[Result].gdMethods.AddMethod(AClassMethods.gdMethods.Items[I]);
end;

procedure TgdClassList.Clear;
var
  i: Integer;
begin
  for i := 0 to FClassList.Count - 1 do
    FClassList.Objects[i] := nil;
  FClassList.Clear;
end;


initialization
  gdcObjectList := TObjectList.Create(False);

finalization
  FreeAndNil(gdcObjectList);
  FreeAndNil(gdcClassList);
  FreeAndNil(frmClassList);

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

