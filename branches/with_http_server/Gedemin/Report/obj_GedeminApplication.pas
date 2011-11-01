
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    obj_GedeminApplication.pas

  Abstract

    Gedemin project. COM-object "GedeminApplication". It is used for used Gedemin
    as COM-server.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    08.04.02    JKL        Initial version.

--}

unit obj_GedeminApplication;

interface

uses
  ComObj, Gedemin_TLB, dmDatabase_unit, dmLogin_unit,  obj_Designer,
  evt_Base, evt_i_Base, ibsql, TypInfo, gd_WebServerControl_unit;

type
  TgsGedeminApplication = class(TAutoObject, IGedeminApplication)
  private
    FBaseQueryList: IgsQueryList;
    FGedemin: IGedemin;
    FTextConverter: IgsTextConverter;
    FscrPublicVariables: IscrPublicVariables;
    FgdcClassList: IgsGDCClassList;
//    FgdcBaseList: IgdcBaseList;
//    FDesignerInterface: IgsDesigner;
//    FDesigner: TobjDesigner;
//    FDesigner: TobjDesigner;
    FException: IgsException;
    FWinAPI: IgsWinAPI;
    FApplication: IgsApplication;
    FScreen: IgsScreen;
    FMouse: IgsMouse;
    FGlobalStorage: IgsGsGlobalStorage;
    FCompanyStorage: IgsGsCompanyStorage;
    FUserStorage: IgsGsUserStorage;
    FIBLogin: IgsBoLogin;
    FgdcBaseManager: IgsGdcBaseManager;
    FatDatabase: IgsAtDatabase;
    FgdWebServerControl: IgdWebServerControl;

    // Указывает можно ли подключаться к базе,
    // т.е. созданы ли главные модули
    // Если нет, то происходит их создание и подключение к базе
    function IsConnectable(const AnLoginType: TLoginType; const AnUser, AnPassword: String; const DBPath: string = ''): Boolean;
    // Здесь должны создаваться все объекты
    procedure CreateOLEObjects;
  protected
    // IGedeminApplication
    function  LoginSilent(const User: WideString; const Password: WideString;
                          const DBPath: WideString): WordBool; safecall;
    function  Logoff: WordBool; safecall;
    function  Login: WordBool; safecall;
    function  LoginSingle: WordBool; safecall;
    function  LoginMulti: WordBool; safecall;
    function  LoginSingleSilent(const User: WideString; const Password: WideString): WordBool; safecall;
    function  LoginMultiSilent(const User: WideString; const Password: WideString): WordBool; safecall;
    function  GetObjectByClass(const ClassName: WideString): IgsObject; safecall;
    function  GetViewFormByClass(const ClassName: WideString; const SubType: WideString): IgsObject; safecall;
    function  Addr(const AnObject: IgsObject): Integer; safecall;

    function  Get_BaseQueryList: IgsQueryList; safecall;
    function  Get_System_: IGedemin; safecall;
    function  Get_gdcBaseList: IgdcBaseList; safecall;
    function  Get_gdcClassList: IgsGDCClassList; safecall;
    function  Get_scrPublicVariables: IscrPublicVariables; safecall;
    function  Get_Converter: IgsTextConverter; safecall;
    function  Get_Designer: IgsDesigner; safecall;
    function  Get_CurrencyString: WideString; safecall;
    function  Get_CurrencyFormat: Byte; safecall;
    function  Get_NegCurrFormat: Byte; safecall;
    function  Get_ThousandSeparator: WideString; safecall;
    function  Get_DecimalSeparator: WideString; safecall;
    function  Get_CurrencyDecimals: Byte; safecall;
    function  Get_DateSeparator: WideString; safecall;
    function  Get_ShortDateFormat: WideString; safecall;
    function  Get_LongDateFormat: WideString; safecall;
    function  Get_TimeSeparator: WideString; safecall;
    function  Get_TimeAMString: WideString; safecall;
    function  Get_TimePMString: WideString; safecall;
    function  Get_ShortTimeFormat: WideString; safecall;
    function  Get_LongTimeFormat: WideString; safecall;
    function  Get_Assigned(AnObject: OleVariant): WordBool; safecall;
    function  Get_WinAPI: IgsWinAPI; safecall;
    function  Get_Application: IgsApplication; safecall;
    function  Get_Screen: IgsScreen; safecall;
    function  Get_Mouse: IgsMouse; safecall;
    function  Get_GlobalStorage: IgsGsGlobalStorage; safecall;
    function  Get_CompanyStorage: IgsGsCompanyStorage; safecall;
    function  Get_UserStorage: IgsGsUserStorage; safecall;
    function  Get_IBLogin: IgsBoLogin; safecall;
    function  Get_gdcBaseManager: IgsGdcBaseManager; safecall;
    function  Get_GS: IgsGSFunction; safecall;
    function  Get_atDatabase: IgsAtDatabase; safecall;
    function  Get_FinallyObject: IFinallyObject; safecall;

    function  Get_Exception: IgsException; safecall;
    function  Get_nil_: IgsObject; safecall;
    function  Get_WebServerControl: IgdWebServerControl; safecall;

    function  NewObject(const VBClassName: WideString): IDispatch; safecall;
    function  GlobalConst(const ConstName: WideString): OleVariant; safecall;
{    function  CreateObject(const Owner: IgsObject; const AClass: WideString; const AName: WideString): IgsObject; safecall;
    procedure DestroyObject(const AObject: IgsObject); safecall;}

    // IComponent
    function  Get_Name: WideString; safecall;
    function  Get_Tag: Integer; safecall;
    procedure Set_Tag(Value: Integer); safecall;
    function  Get_ComponentCount: Integer; safecall;
    function  Get_ComponentIndex: Integer; safecall;
    function  Get_ComponentState: WideString; safecall;
    function  Get_Components(Index: Integer): IgsComponent; safecall;
    function  Get_DesignInfo: Integer; safecall;
    procedure Set_DesignInfo(Value: Integer); safecall;
    function  FindComponent(const ComponentName: WideString): IgsComponent; safecall;
    {Если компонент не найден, выдает эксепшн}
    function  GetComponent(const ComponentName: WideString): IgsComponent; safecall;
    function  Get_Owner: IgsComponent; safecall;
    function  Get_OwnerForm: IgsForm; safecall;

    // IObject
    function ClassName: WideString; safecall;
    function ClassParent: WideString; safecall;
    function InheritsFrom(const AClass: WideString): WordBool; safecall;
    function Get_Self: Integer; safecall;
    function Get_DelphiObject: Integer; safecall;

    // IPersistent
    procedure Assign_(const Source: IgsPersistent); safecall;

  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize; override;
    procedure DestroyObject; safecall;

    function GetBaseQueryList: IgsQueryList;
    function GetSystem: IGedemin;
    function GetgdcBaseList: IgdcBaseList;

    function GetgdcClassList: IgsGDCClassList;
    function GetscrPublicVariables: IscrPublicVariables;
    function GetConverter: IgsTextConverter;
    function GetDesigner: IgsDesigner;
    function GetException: IgsException;
    function GetWinAPI: IgsWinAPI;
    function GetApplication: IgsApplication;
    function GetScreen: IgsScreen;
    function GetMouse: IgsMouse;
    function GetGlobalStorage: IgsGsGlobalStorage;
    function GetCompanyStorage: IgsGsCompanyStorage;
    function GetUserStorage: IgsGsUserStorage;
    function GetIBLogin: IgsBoLogin;
    function GetgdcBaseManager: IgsGdcBaseManager;
    function GetGSFunction: IgsGSFunction;
    function GetatDatabase: IgsAtDatabase;
    function GetFinallyObject: IFinallyObject;
    function GetWebServerControl: IgdWebServerControl;

//    procedure FreeAllDesignerObject;

    function  CmdLine: WideString; safecall;
    function  ParamStr(Index: Integer): WideString; safecall;
    function  ParamCount: Integer; safecall;
    function  FindCmdLineSwitch(const Switch: WideString): WordBool; safecall;
    procedure SetEventHandler(const AnComponent: IgsComponent; const EventName: WideString;
                              const FunctionName: WideString); safecall;
    procedure ResetEventHandler(const AnComponent: IgsComponent; const EventName: WideString); safecall;
    function  GDCClasses(Index: Integer): WideString; safecall;
    function  GDCClassesCount: Integer; safecall;
  end;

var
  GedeminApplication: TgsGedeminApplication;

implementation

uses
  ComServ, Dialogs, dmClientReport_unit, dmImages_unit,
  gd_main_form, gd_security, Forms, SysUtils, gd_frmOLEMainForm_unit,
  gdcOLEClassList, gdcExplorer, obj_QueryList, obj_Gedemin,
  gsTextTemplate_unit, scrOpenSaveDialog_unit, gd_CmdLineParams_unit,
  Classes, gsResizerInterface, Windows, prp_Methods,
  controls,{ obj_Designer, } gd_ClassList, obj_GSFunction,
  gd_i_ScriptFactory, gsWinAPI_unit, Storages, gsIBLogin, gsGdcBaseManager_unit,
  gdcTaxFunction, {obj_AtDatabase, }at_classes, obj_FinallyObject, gdcBaseInterface;

{ TgsGedeminApplication }

function TgsGedeminApplication.FindComponent(
  const ComponentName: WideString): IgsComponent;
var
  LComponent: TComponent;
begin
  LComponent := Application.FindComponent(ComponentName);
  if Assigned(LComponent) then
    Result := GetGdcOLEObject(LComponent) as IgsComponent
  else
    Result := nil;
end;

function TgsGedeminApplication.GetObjectByClass(
  const ClassName: WideString): IgsObject;
begin

end;

function TgsGedeminApplication.Get_BaseQueryList: IgsQueryList;
begin
  Result := GedeminApplication.GetBaseQueryList;
end;

function TgsGedeminApplication.GetViewFormByClass(const ClassName,
  SubType: WideString): IgsObject;
begin
  { TODO : изменилась спецификация! }
  //Result := GetGdcOLEObject(ViewFormByClass(ClassName, SubType)) as IgsObject;
  Result := nil;
end;

function TgsGedeminApplication.Get_ComponentCount: Integer;
begin
  Result := Application.ComponentCount;
end;

function TgsGedeminApplication.Get_ComponentIndex: Integer;
begin
  Result := Application.ComponentIndex;
end;

function TgsGedeminApplication.Get_Components(
  Index: Integer): IgsComponent;
begin
  Result := GetGdcOLEObject(Application.Components[Index]) as IgsComponent;
end;

function TgsGedeminApplication.Get_Converter: IgsTextConverter;
begin
  Result :=  GedeminApplication.GetConverter;
end;

function TgsGedeminApplication.Get_DesignInfo: Integer;
begin
  Result := Application.DesignInfo;
end;

function TgsGedeminApplication.Get_gdcBaseList: IgdcBaseList;
begin
  Result := GedeminApplication.GetgdcBaseList;
end;

function TgsGedeminApplication.Get_gdcClassList: IgsGDCClassList;
begin
  Result :=  GedeminApplication.GetgdcClassList;
end;

function TgsGedeminApplication.Get_Name: WideString;
begin
  Result := Application.Name;
end;

function TgsGedeminApplication.Get_Owner: IgsComponent;
begin
  Result := nil;
end;

function TgsGedeminApplication.Get_scrPublicVariables: IscrPublicVariables;
begin
  Result :=  GedeminApplication.GetscrPublicVariables;
end;

function TgsGedeminApplication.Get_Self: Integer;
begin
  Result := Integer(Application);
end;

function TgsGedeminApplication.Get_System_: IGedemin;
begin
  Result := GedeminApplication.GetSystem;
end;

function TgsGedeminApplication.Get_Tag: Integer;
begin
  Result := Application.Tag;
end;

procedure TgsGedeminApplication.Initialize;
begin
//  MessageDlg('BeforeOLEInitialize', mtInformation, [MBOK], 0);
  inherited;
//  MessageDlg('AfterOLEInitialize', mtInformation, [MBOK], 0);
end;

function TgsGedeminApplication.IsConnectable(
  const AnLoginType: TLoginType; const AnUser, AnPassword: String; const DBPath: string = ''): Boolean;
begin
  Result := False;
  // Проверяем создан ли dmDatabase
  // Если приложение запущено в ручную, он должен быть обязательно создан
  // Если приложение запущено как COM-server, он не создан только при первом подключении
  if not Assigned(dmLogin) then
  begin
    // Создаем dmDatabase и подключаемся к базе данных
    // Присвоение глобальной переменной происходит внутри
    // по-другому не получается
    Application.CreateForm(TdmDatabase, dmDatabase);
    try
      Application.CreateForm(TdmClientReport, dmClientReport);
    except
    end;
    TdmLogin.CreateAndConnect(Application, AnLoginType, AnUser, AnPassword, DBPath);
    if (IBLogin = nil) or (not IBLogin.LoggedIn) then
    begin
      FreeAndNil(dmLogin);
      exit;
    end;

    // Подключение должно произойти до этого места
    // На OnCreate повешены действия работающие с базой
    // Создаем остальные модули
    Application.CreateForm(TdmImages, dmImages);
    try
      CreateOLEObjects;
    except
    end;

    if not gd_CmdLineParams.Embedding then
    begin
    // Освобождаем главную форму, созданую для COM-server
      FreeAndNil(frmOLEMainForm);

    // Создаем главную форму приложения
      Application.ShowMainForm := True;
      Application.CreateForm(TfrmGedeminMain, frmGedeminMain);
    end;
  end else
    Result := True;
end;

function TgsGedeminApplication.Login: WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltQuery, '', '') then
    // Иначе подключаемся
    Result := IBLogin.Login(False)
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.LoginMulti: WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltMulti, '', '') then
    // Иначе подключаемся
    Result := IBLogin.BringOnLine
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.LoginMultiSilent(const User,
  Password: WideString): WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltMultiSilent, User, Password) then
    // Иначе подключаемся
    // Пока не реализовано
    Result := False
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.LoginSilent(const User, Password: WideString; const DBPath: WideString): WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltSilent, User, Password, DBPath) then
    // Иначе подключаемся
    Result := IBLogin.LoginSilent(User, Password, DBPath)
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.LoginSingle: WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltSingle, '', '') then
    // Иначе подключаемся
    Result := IBLogin.LoginSingle
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.LoginSingleSilent(const User,
  Password: WideString): WordBool;
begin
  // Проверяем созданы ли главные формы
  // Если нет, то должно произойти внутри процедуры
  if IsConnectable(ltSingleSilent, User, Password) then
    // Иначе подключаемся
    // Пока не реализовано
    Result := False
  else
    // Проверяем произошло ли подключение
    // Если возникает ошибка при подключении в первый раз, то dmDatabase освобождается
    Result := Assigned(IBLogin);
end;

function TgsGedeminApplication.Logoff: WordBool;
begin
  if Assigned(dmDatabase) then
    IBLogin.Logoff;
end;

procedure TgsGedeminApplication.Set_DesignInfo(Value: Integer);
begin

end;

procedure TgsGedeminApplication.Assign_(const Source: IgsPersistent);
begin
  Application.Assign(TPersistent(Source.Self));
end;

constructor TgsGedeminApplication.Create;
begin
  Assert(GedeminApplication = nil, 'GedeminApplication уже присвоен');

  inherited Create;

  GedeminApplication := Self;
  CreateOLEObjects;
end;

destructor TgsGedeminApplication.Destroy;
//var
//  i: Integer;
begin
  FBaseQueryList := nil;
  FGedemin := nil;
//  InterfaceToObject(FDesigner);
//  for i := 1 to (InterfaceToObject(FDesigner) as TComObject).RefCount do
//    FDesigner._Release;
//  FDesignerInterface := nil;
//  FDesigner := nil;
  FWinAPI := nil;
  FgdcClassList := nil;
  FscrPublicVariables := nil;
  FTextConverter := nil;
  FException := nil;
  FApplication := nil;
  FScreen := nil;
  FMouse := nil;
  FGlobalStorage := nil;
  FCompanyStorage := nil;
  FUserStorage := nil;
  FIBLogin := nil;
  FgdcBaseManager := nil;
  FatDatabase := nil;
  FgdWebServerControl := nil;
//  IGSFunction := nil;


  if GedeminApplication = Self then
    GedeminApplication := nil;

  inherited Destroy;
end;

procedure TgsGedeminApplication.CreateOLEObjects;
begin
  // Здесь должны создаваться все объекты
  FBaseQueryList := TgsQueryList.Create(IBLogin.Database, dmClientReport.IBTransaction1);
  FGedemin := TgsGedemin.Create(IBLogin.Database, dmClientReport.IBTransaction1);
//  FgdcBaseList := TgdcBaseList.Create(IBLogin.Database, dmClientReport.IBTransaction1);
//  FDesigner := TobjDesigner.Create;
//  FDesignerInterface := FDesigner;
  FWinAPI := TgsWinAPI.Create;
  FApplication := GetGdcOLEObject(Application) as IgsApplication;
  FScreen := GetGdcOLEObject(Screen) as IgsScreen;
  FMouse := GetGdcOLEObject(Mouse) as IgsMouse;
//  FgdcClassList := TwrpGDCClassList.Create(nil);
  FgdcClassList := GetGdcOLEObject(gdcClassList) as IgsGDCClassList;
  FgdcBaseManager := TgsGdcBaseManager.Create as IgsGdcBaseManager;

  FatDatabase := GetGdcOLEObject(atDatabase) as IgsAtDatabase;
//  FatDatabase := TobjAtDatabase.Create as IgsAtDatabase;
//  IGSFunction := TobjGSFunction.Create as IDispatch;

  FException := GetGdcOLEObject(ScriptFactory.scrException) as IgsException;

  FscrPublicVariables := TscrPublicVariables.Create;
  FTextConverter := TgsTextConverter.Create;

  FCompanyStorage := GetGdcOLEObject(CompanyStorage) as IgsGsCompanyStorage;
  FGlobalStorage := GetGdcOLEObject(GlobalStorage) as IgsGsGlobalStorage;
  FUserStorage := GetGdcOLEObject(UserStorage) as IgsGsUserStorage;
  FIBLogin := TgsIBLogin.Create;

  FgdWebServerControl := GetGdcOLEObject(TgdWebServerControl.GetInstance) as IgdWebServerControl;
end;

{function TgsGedeminApplication.CreateObject(const Owner: IgsObject;
  const AClass, AName: WideString): IgsObject;
var
  LObjectClass: TPersistentClass;
  LObject: TPersistent;
  LOwner, LiveObject : TComponent;
  str: String;

begin
  Result := nil;

  if Pos(AnsiUpperCase(MACROSCOMPONENT_PREFIX), AnsiUpperCase(AName)) <> 1 then
  begin
    str := 'Объект с именем ' + AName + 'не создан.'#10#13 + 'Имя объекта должно содержать префикс usrL_'#10#13 +
      'Например: usrL_' + AName;
    Windows.MessageBox(0, PChar(str), PChar('Ошибка создания объекта!'),
      MB_OK or MB_ICONERROR or MB_TOPMOST);
    exit;
  end;

  LObjectClass := GetClass(AClass);
  if Assigned(LObjectClass) then
  begin
    try
      LOwner := InterfaceToObject(Owner) as TComponent;
      LiveObject := LOwner.FindComponent(AName);
      if Assigned(LiveObject) then
      begin
        Result := GetGdcOLEObject(LiveObject) as IgsObject;
        exit;
      end;
      LObject := TComponentClass(LObjectClass).Create(LOwner);
      TComponent(LObject).Name := AName;
      if LObject is TWinControl then
        TWinControl(LObject).Parent := LOwner as TWinControl;
      Result := GetGdcOLEObject(LObject) as IgsObject;
    except
      begin
        FreeAndNil(LObject);
        Result := nil;
        raise Exception.Create('Ошибка создания объекта ' + AName);
      end;
    end;
  end else
    raise Exception.Create('Класс для переданного имени класса не найден!');
end;

procedure TgsGedeminApplication.DestroyObject(const AObject: IgsObject);
var
  LObject: TObject;
begin
  if not Assigned(AObject) then
    exit;
  LObject := InterfaceToObject(AObject);
  if LObject is TComponent then
    if Pos(AnsiUpperCase(MACROSCOMPONENT_PREFIX), AnsiUpperCase(TComponent(LObject).Name)) = 1 then
      FreeAndNil(LObject)
    else
      Windows.MessageBox(0, PChar('Объект ' + TComponent(LObject).Name +' невозможно удалить из макроса'), PChar('Ошибка удаления объекта!'), MB_OK or MB_ICONERROR or MB_TOPMOST);
end;}

function TgsGedeminApplication.GetBaseQueryList: IgsQueryList;
begin
  Result := FBaseQueryList;
end;

function TgsGedeminApplication.GetSystem: IGedemin;
begin
  Result := FGedemin;
end;

function TgsGedeminApplication.GetgdcBaseList: IgdcBaseList;
begin
  raise Exception.Create('Объект gdcBaseList не поддерживается.');
//  Result := FgdcBaseList;
end;

function TgsGedeminApplication.Get_Designer: IgsDesigner;
begin
  Result :=  GedeminApplication.GetDesigner;
end;

function TgsGedeminApplication.Get_CurrencyString: WideString;
begin
  Result := CurrencyString;
end;

function TgsGedeminApplication.Get_CurrencyDecimals: Byte;
begin
  Result := CurrencyDecimals;
end;

function TgsGedeminApplication.Get_CurrencyFormat: Byte;
begin
  Result := CurrencyFormat;
end;

function TgsGedeminApplication.Get_DateSeparator: WideString;
begin
  Result := DateSeparator;
end;

function TgsGedeminApplication.Get_DecimalSeparator: WideString;
begin
  Result := DecimalSeparator;
end;

function TgsGedeminApplication.Get_LongDateFormat: WideString;
begin
  Result := LongDateFormat;
end;

function TgsGedeminApplication.Get_LongTimeFormat: WideString;
begin
  Result := LongTimeFormat;
end;

function TgsGedeminApplication.Get_NegCurrFormat: Byte;
begin
  Result := NegCurrFormat;
end;

function TgsGedeminApplication.Get_ShortDateFormat: WideString;
begin
  Result := ShortDateFormat;
end;

function TgsGedeminApplication.Get_ShortTimeFormat: WideString;
begin
  Result := ShortTimeFormat;
end;

function TgsGedeminApplication.Get_ThousandSeparator: WideString;
begin
  Result := ThousandSeparator;
end;

function TgsGedeminApplication.Get_TimeAMString: WideString;
begin
  Result := TimeAMString;
end;

function TgsGedeminApplication.Get_TimePMString: WideString;
begin
  Result := TimePMString;
end;

function TgsGedeminApplication.Get_TimeSeparator: WideString;
begin
  Result := TimeSeparator;
end;

function TgsGedeminApplication.GetConverter: IgsTextConverter;
begin
  Result := FTextConverter;
end;

function TgsGedeminApplication.GetDesigner: IgsDesigner;
begin
//  Result := FDesignerInterface;
  Result := Designer;
end;

function TgsGedeminApplication.GetgdcClassList: IgsGDCClassList;
begin
  Result := FgdcClassList;
end;

function TgsGedeminApplication.GetscrPublicVariables: IscrPublicVariables;
begin
  Result := FscrPublicVariables;
end;

function TgsGedeminApplication.Get_Exception: IgsException;
begin
  Result :=  GedeminApplication.GetException;
end;

function TgsGedeminApplication.GetException: IgsException;
begin
  Result := FException;
end;

function TgsGedeminApplication.ClassName: WideString;
begin
  Result := Application.ClassName;
end;

function TgsGedeminApplication.ClassParent: WideString;
begin
  Result := Application.ClassParent.ClassName;
end;

function TgsGedeminApplication.InheritsFrom(
  const AClass: WideString): WordBool;
begin
  Result := Application.InheritsFrom(GetClass(AClass));
end;

function TgsGedeminApplication.Get_Assigned(AnObject: OleVariant): WordBool;
var
  FIgsObject: IgsObject;
begin
  Result := False;
  if VarType(AnObject) = VarDispatch then
  begin
    if IDispatch(AnObject) <> nil then
    begin
      if Supports(IDispatch(AnObject), IgsObject, FIgsObject) then
        Result := FIgsObject.DelphiObject <> 0
      else
        Result := True;
    end;
  end;
end;

function TgsGedeminApplication.Get_WinAPI: IgsWinAPI;
begin
  Result :=  GedeminApplication.GetWinAPI;
end;

function TgsGedeminApplication.GetWinAPI: IgsWinAPI;
begin
  Result := FWinAPI;
end;

function TgsGedeminApplication.Get_Application: IgsApplication;
begin
  Result := GetApplication;
end;

function TgsGedeminApplication.GetApplication: IgsApplication;
begin
  Result := FApplication;
end;

function TgsGedeminApplication.Get_ComponentState: WideString;
begin
  Result := '';
end;

function TgsGedeminApplication.NewObject(const VBClassName: WideString): IDispatch;
begin
  Result := dmClientReport.GlobalRS.Eval('New ' + VBClassName);
end;

function TgsGedeminApplication.GlobalConst(
  const ConstName: WideString): OleVariant;
begin
  Result := dmClientReport.GlobalRS.Eval(ConstName);
end;

function TgsGedeminApplication.Get_OwnerForm: IgsForm;
begin
  Result := nil;
end;

{procedure TgsGedeminApplication.FreeAllDesignerObject;
begin
  FDesigner.FreeAllObject;
end;}

function TgsGedeminApplication.GetScreen: IgsScreen;
begin
  Result := FScreen;
end;

function TgsGedeminApplication.Get_Screen: IgsScreen;
begin
  Result := GetScreen;
end;

function TgsGedeminApplication.Get_CompanyStorage: IgsGsCompanyStorage;
begin
  Result := GetCompanyStorage;
end;

function TgsGedeminApplication.Get_GlobalStorage: IgsGsGlobalStorage;
begin
  Result := GetGlobalStorage;
end;

function TgsGedeminApplication.Get_UserStorage: IgsGsUserStorage;
begin
  Result := GetUserStorage;
end;

function TgsGedeminApplication.GetCompanyStorage: IgsGsCompanyStorage;
begin
  Result := FCompanyStorage;
end;

function TgsGedeminApplication.GetGlobalStorage: IgsGsGlobalStorage;
begin
  Result := FGlobalStorage;
end;

function TgsGedeminApplication.GetUserStorage: IgsGsUserStorage;
begin
  Result := FUserStorage;
end;

function TgsGedeminApplication.Get_IBLogin: IgsBoLogin;
begin
  Assert(IBLogin <> nil);
  Result := GetIBLogin;
end;

function TgsGedeminApplication.GetIBLogin: IgsBoLogin;
begin
  Result := FIBLogin;
end;

function TgsGedeminApplication.Get_gdcBaseManager: IgsGdcBaseManager;
begin
  Result := GetgdcBaseManager;
end;

function TgsGedeminApplication.GetgdcBaseManager: IgsGdcBaseManager;
begin
  Result := FgdcBaseManager;
end;

function TgsGedeminApplication.Addr(const AnObject: IgsObject): Integer;
begin
  Result := Integer(InterfaceToObject(AnObject));
end;

function TgsGedeminApplication.Get_nil_: IgsObject;
begin
  Result := nil;
end;

procedure TgsGedeminApplication.Set_Tag(Value: Integer);
begin
  Application.Tag := Value;
end;

function TgsGedeminApplication.Get_GS: IgsGSFunction;
begin
  Result := GetGSFunction;
end;

function TgsGedeminApplication.GetGSFunction: IgsGSFunction;
begin
  Result := gsFunction as IgsGSFunction;
end;

function TgsGedeminApplication.Get_atDatabase: IgsAtDatabase;
begin
  Result := GetatDatabase;
end;

function TgsGedeminApplication.GetatDatabase: IgsAtDatabase;
begin
  Result := FatDatabase;
end;

function TgsGedeminApplication.Get_FinallyObject: IFinallyObject;
begin
  Result := GetFinallyObject;
end;

function TgsGedeminApplication.GetFinallyObject: IFinallyObject;
begin
  Result := FinallyObject;
end;

function TgsGedeminApplication.GetComponent(
  const ComponentName: WideString): IgsComponent;
begin
  if not Assigned(FindComponent(ComponentName)) then
    raise Exception.Create(Format('Компонент %s не найден!', [ComponentName]));
end;

function TgsGedeminApplication.Get_Mouse: IgsMouse;
begin
  Result := GetMouse;
end;

function TgsGedeminApplication.GetMouse: IgsMouse;
begin
  Result := FMouse;
end;

function TgsGedeminApplication.CmdLine: WideString;
begin
  Result := System.CmdLine;
end;

function TgsGedeminApplication.FindCmdLineSwitch(
  const Switch: WideString): WordBool;
begin
  Result := SysUtils.FindCmdLineSwitch(Switch, ['-', '/'], True);
end;

function TgsGedeminApplication.ParamCount: Integer;
begin
  Result := System.ParamCount;
end;

function TgsGedeminApplication.ParamStr(Index: Integer): WideString;
begin
  Result := System.ParamStr(Index);
end;

procedure TgsGedeminApplication.DestroyObject;
begin
// Don't support
end;

function TgsGedeminApplication.Get_DelphiObject: Integer;
begin
  Result := Get_Self;
end;

function TgsGedeminApplication.GetWebServerControl: IgdWebServerControl;
begin
  Result := FgdWebServerControl;
end;

function TgsGedeminApplication.Get_WebServerControl: IgdWebServerControl;
begin
  Result := GetWebServerControl;
end;

procedure TgsGedeminApplication.SetEventHandler(
  const AnComponent: IgsComponent; const EventName,
  FunctionName: WideString);
var
  sl: TStringList;
  comp: TComponent;
  Index: integer;
  EvtObj: TEventObject;
  EvtCtrl: TEventControl;
  EvtItem: TEventItem;
  q: TIBSQL;
  TempPropInfo: PPropInfo;

  function GetEvtObj(AComp: TComponent): TEventObject;
  var
    ParEvtObj: TEventObject;
    Ind: integer;
  begin
    Result:= EvtCtrl.EventObjectList.FindAllObject(AComp);
    if Assigned(Result) then
      Exit;
    if Assigned(AComp.Owner) and (AComp.Owner <> Application) then begin
      ParEvtObj:= GetEvtObj(AComp.Owner);
      if Assigned(ParEvtObj) then begin
        Ind:= ParEvtObj.ChildObjects.AddObject(nil);
        Result:= ParEvtObj.ChildObjects[Ind] as TEventObject;
        Result.ObjectName:= AComp.Name;
        Result.ObjectRef:= AComp;
      end;
    end
    else begin
      Ind:= EventControl.AddDynamicCreatedEventObject(AComp);
      Result:= TEventObject(EvtCtrl.EventObjectList[Ind]);
    end;
  end;

begin
  sl:= TStringList.Create;
  q:= TIBSQL.Create(nil);
  try
    q.Transaction:= gdcBaseManager.ReadTransaction;
    if Assigned(AnComponent.OwnerForm) then
      q.SQL.Text:=
        ' SELECT f.id ' +
        ' FROM gd_function f ' +
        '   JOIN evt_object o ON o.id = f.modulecode AND o.name = ' + QuotedStr(AnComponent.OwnerForm.Name) +
        ' WHERE f.name = ' + QuotedStr(FunctionName)
    else
      q.SQL.Text:= 'SELECT id FROM gd_function WHERE name = ' + QuotedStr(FunctionName);
    q.ExecQuery;
    if q.Eof then begin
      if Assigned(AnComponent.OwnerForm) then begin
        q.Close;
        q.SQL.Text:= 'SELECT id FROM gd_function WHERE name = ' + QuotedStr(FunctionName);
        q.ExecQuery;
        if q.Eof then
          raise Exception.Create('Фунция "' + FunctionName + '" не найдена.');
      end
      else
        raise Exception.Create('Фунция "' + FunctionName + '" не найдена.');
    end;
    comp:= InterfaceToObject(AnComponent) as TComponent;
    EventControl.ObjectEventList(comp, sl);
    sl.Text:= AnsiUpperCase(sl.Text);
    if sl.IndexOfName(AnsiUpperCase(EventName)) = -1 then
      raise Exception.Create('Передано имя несуществующего события.');
    EvtCtrl:= EventControl.Get_Self as TEventControl;
    EvtObj:= GetEvtObj(comp);
    if Assigned(EvtObj) then begin
      EvtItem:= EvtObj.EventList.Find(EventName);
      if Assigned(EvtItem) then begin
        if EvtItem.OldFunctionKey = 0 then
          EvtItem.OldFunctionKey:= EvtItem.FunctionKey;
        EvtItem.FunctionKey:= q.FieldByName('id').AsInteger;
      end
      else begin
        Index:= EvtObj.EventList.Add(EventName, q.FieldByName('id').AsInteger);
        EvtItem:= EvtObj.EventList[Index];
        TempPropInfo := GetPropInfo(comp, EventName);
        EvtItem.OldEvent := GetMethodProp(comp, TempPropInfo);
        EvtItem.EventData:= GetTypeData(TempPropInfo^.PropType^);
        EvtItem.EventObject:= EvtObj;
      end;
      EventControl.RebootEvents(comp);
    end;
  finally
    sl.Free;
    q.Free;
  end;
end;

procedure TgsGedeminApplication.ResetEventHandler(
  const AnComponent: IgsComponent; const EventName: WideString);
var
  sl: TStringList;
  comp: TComponent;
  EvtObj: TEventObject;
  EvtCtrl: TEventControl;
  EvtItem: TEventItem;
  TempPropInfo: PPropInfo;
begin
  sl:= TStringList.Create;
  try
    comp:= InterfaceToObject(AnComponent) as TComponent;
    EventControl.ObjectEventList(comp, sl);
    sl.Text:= AnsiUpperCase(sl.Text);
    if sl.IndexOfName(AnsiUpperCase(EventName)) = -1 then
      raise Exception.Create('Передано имя несуществующего события.');

    EvtCtrl:= EventControl.Get_Self as TEventControl;
    EvtObj:= EvtCtrl.EventObjectList.FindAllObject(comp);
    if Assigned(EvtObj) then begin
      EvtItem:= EvtObj.EventList.Find(EventName);
      if Assigned(EvtItem) then begin
        if EvtItem.OldFunctionKey <> 0 then
          EvtItem.FunctionKey:= EvtItem.OldFunctionKey
        else begin
          if EvtItem.OldEvent.Data <> nil then begin
            TempPropInfo := GetPropInfo(comp, EventName);
            SetMethodProp(comp, TempPropInfo, EvtItem.OldEvent);
          end;
          EvtObj.EventList.DeleteForName(EventName);
        end;
      end;
    end;
    EventControl.RebootEvents(comp);
  finally
    sl.Free;
  end;
end;

function TgsGedeminApplication.GDCClasses(Index: Integer): WideString;
begin
  Result := gdcClassList[Index].ClassName;
end;

function TgsGedeminApplication.GDCClassesCount: Integer;
begin
  Result := gdcClassList.Count;
end;

initialization
  GedeminApplication := nil;
  TAutoObjectFactory.Create(ComServer, TgsGedeminApplication, CLASS_gsGedeminApplication,
    ciSingleInstance, tmApartment);

finalization                         
  GedeminApplication := nil;

end.
