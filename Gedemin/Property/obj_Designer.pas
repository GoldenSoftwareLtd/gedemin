// ShlTanya, 25.02.2019

unit obj_Designer;

interface

uses
  ComObj, Gedemin_TLB, Comserv, Contnrs, classes, gd_KeyAssoc, gdcOLEClassList;

type
  // Объект класса предназначен для ведения списка созданных и
  // уничтоженных дезайнером объектов.
  // При уничтожении компонента оунером объект удаляет его из списка.
  TobjDesignerFreeSpy = class(TComponent)
  private
    FObjectList: TObjectList;

    function GetCount: Integer;
    function GetObjectList(Index: Integer): TObject;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor  Destroy; override;

    function  Add(AObject: TObject): Integer;
    function  IndexOf(AObject: TObject): Integer;
    function  Remove(AObject: TObject): Integer;
    procedure Delete(Index: Integer);

    property  ObjectList[Index: Integer]: TObject read GetObjectList; default;
    property  Count: Integer read GetCount;
  end;

  TobjDesigner = class(TAutoObject, IgsDesigner, IAuxiliaryDesigner)
  private
    // список, созданных объектов
    FObjectList: TobjDesignerFreeSpy;

    function GetRegisterObject(const AObject: TObject): IgsObject;

    procedure FreeAllObject;
  protected
    function  CreateObject(Owner: OleVariant; const ClassName: WideString; const Name: WideString): IgsObject; safecall;
    // Служит для создания перечисленных классов, имеющих параметры в конструкторе
    function  CreateObjectWithParams(const ClassName: WideString; const Name: WideString;
                                     ParamsArray: OleVariant): IgsObject; safecall;
    function  CreateForm(Owner: OleVariant; const ClassName: WideString;
                         const Name: WideString): IgsObject; safecall;
    procedure DestroyObject(const AObject: IgsObject); safecall;
    function  FindObject(const Name: WideString): IgsObject; safecall;
  public
    destructor Destroy; override;

    procedure Initialize; override;

    procedure RemoveObject(const AnObject: TObject);
  end;

var
  Designer: TObjDesigner;

implementation

uses
  prp_Methods, controls, sysutils, gsResizerInterface, Windows,
  obj_WrapperDelphiClasses, gd_createable_form, Storages, gd_directories_const,
  gdc_createable_form, gd_DebugLog, Graphics, obj_WrapperIBXClasses
  {$IFDEF DEBUG}
    {$IFDEF WITH_INDY}
      , gdccClient_unit
    {$ENDIF}
  {$ENDIF}
  ;

var
  IDesigner: IgsDesigner;

{$IFDEF DEBUG}
  {$IFDEF WITH_INDY}
    ObjCnt: Integer;
  {$ENDIF}
{$ENDIF}

{ TwrpDesigner }

function TobjDesigner.CreateForm(
  Owner: OleVariant; const ClassName: WideString;
  const Name: WideString): IgsObject;
begin
  Result := CreateObject(Owner, ClassName, Name);
end;

function TobjDesigner.CreateObject
  (Owner: OleVariant; const ClassName: WideString; const Name: WideString): IgsObject;
var
  LObjectClass: TClass;
  LObject: TObject;
  LOwner: TComponent;
  LWrapClass: TWrapperAutoClass;
  LClassName: String;
  LUserForm: Boolean;

const
  dsStClassPref = 'T';

begin
  if VariantIsArray(Owner) then
  begin
    Result := CreateObjectWithParams(ClassName, Name, Owner);
    Exit;
  end;

  Result := nil;
  LOwner := nil;
  LObject := nil;
  LObjectClass := nil;
  LUserForm := False;

  LClassName := AnsiUpperCase(Trim(ClassName));

  if LClassName = '' then
    raise Exception.Create('Invalid class name');

  //Если класс не начинается с T, то это пользовательская форма
  { TODO : может проверять на наличие префикса usrf_?? }
  if (LClassName[1] <> dsStClassPref) then
  begin
    LClassName := AnsiUpperCase(GlobalStorage.ReadString(
      st_ds_NewFormPath + '\' + ClassName, st_ds_FormClass));
    LUserForm  := True;
  end;

  //Ищем среди зарегистированных в OleClassList
  LWrapClass := OleClassList.GetWrapClass(LClassName, LObjectClass);

  //Если класс не найден, то ищем через GetClass
  if LObjectClass = nil then
    LObjectClass := GetClass(LClassName);

  //Если найден врап-класс и реал-класс и он не компонента, то пытаемся получить объект из врап-класса
  if (LWrapClass <> nil) and (LObjectClass <> nil) and (not LObjectClass.InheritsFrom(TComponent)) then
    LObject := LWrapClass.CreateObject(LObjectClass, Owner);

  if LObjectClass <> nil then
  begin
    try
      //Если объект не создан врап-классом, то пытаемся создать его стандартным способом
      if LObject = nil then
      begin
        //Создание компонента
        if LObjectClass.InheritsFrom(TComponent) then
        begin
          // Получаем овнер компонента
          if (VarType(Owner) = varDispatch) and (IDispatch(Owner) <> nil) and
            (InterfaceToObject(Owner) is TComponent) then
          begin
            LOwner := InterfaceToObject(Owner) as TComponent;
          end;

          // Создаем экземпляр. Если это форма, то форму иначе компонент
          if LObjectClass.InheritsFrom(TCreateableForm) and LUserForm then
            LObject := CCreateableForm(LObjectClass).CreateUser(LOwner, ClassName)
          else
            LObject := TComponentClass(LObjectClass).Create(LOwner);

          // Присваиваем имя компонента
          if Length(Trim(Name)) > 0 then
            TComponent(LObject).Name := Trim(Name);

          // Если надо присваиваем парент
          if (LObject is TControl) and (not LObjectClass.InheritsFrom(TCreateableForm))
             and (LOwner is TWinControl) then
          begin
            TWinControl(LObject).Parent := LOwner as TWinControl;
          end;
        end else
          LObject := LObjectClass.Create;
      end;
      Result := GetRegisterObject(LObject);

      {$IFDEF DEBUG}
        {$IFDEF WITH_INDY}
          Inc(ObjCnt);
          if gdccClient <> nil then
            gdccClient.AddLogRecord('dsgn', 'Created ' + ClassName + Name + ', total: ' + IntToStr(ObjCnt));
        {$ENDIF}
      {$ENDIF}
    except
      on E: Exception do
      begin
        // В случае возникновения ошибки освобождаем объект
        LObject.Free;
        raise Exception.Create(Format('%s: Ошибка создания объекта %s: %s',
         [ClassName, Name, E.Message]));
      end;
    end;
  end else
    raise Exception.Create(Format(
      'Невозможно создать объект класса %s.'#13#10 +
      'Класс "%s" не зарегистрирован!', [ClassName, ClassName]));
end;

function TobjDesigner.CreateObjectWithParams(const ClassName,
  Name: WideString; ParamsArray: OleVariant): IgsObject;
var
  LObject: TObject;
  LObjectClass: TClass;
  LWrapClass: TWrapperAutoClass;
  LClassName: String;

const
  dsStClassPref = 'T';
begin
  // Поддерживает классы: TFileStream
  LObject := nil;
  Result := nil;
  LObjectClass := nil;
  LClassName := AnsiUpperCase(Trim(ClassName));
  try
    //Ищем среди зарегистированных в OleClassList
    LWrapClass := OleClassList.GetWrapClass(LClassName, LObjectClass);
    if LObjectClass <> nil then
    begin
      //Если класс найден и он не компонента, то пытаемся получить объект из врап-класса
      if LWrapClass <> nil then
      begin
        LObject := LWrapClass.CreateObject(LObjectClass, ParamsArray);
      end;
    end;

    if LObject <> nil then
    begin
      if LObject.InheritsFrom(TComponent) then
        TComponent(LObject).Name := Name;
      Result := GetRegisterObject(LObject);

      {$IFDEF DEBUG}
        {$IFDEF WITH_INDY}
          Inc(ObjCnt);
          if gdccClient <> nil then
            gdccClient.AddLogRecord('dsgn', 'Created ' + ClassName + Name + ', total: ' + IntToStr(ObjCnt));
        {$ENDIF}
      {$ENDIF}
    end else
      raise Exception.Create('Метод не поддерживает класс "' + ClassName + '".');
  except
    LObject.Free;
    raise;
  end;
end;

destructor TobjDesigner.Destroy;
begin
  {$IFDEF DEBUG}
  if FObjectList.Count > 0 then
  begin
    Log.LogLn(Format('Не освобождено %d объектов созданные в Designer', [FObjectList.Count]));
  end;
  {$ENDIF}

  FreeAllObject;
  FreeAndNil(FObjectList);
  inherited;
end;

procedure TobjDesigner.DestroyObject(const AObject: IgsObject);
begin
  if Assigned(AObject) then
  begin
    {$IFDEF DEBUG}
      {$IFDEF WITH_INDY}
        Dec(ObjCnt);
        if gdccClient <> nil then
          gdccClient.AddLogRecord('dsgn', 'Destroyed ' + AObject.ClassName + ', total: ' + IntToStr(ObjCnt));
      {$ENDIF}
    {$ENDIF}

    AObject.DestroyObject;
  end;
end;

function TobjDesigner.FindObject(const Name: WideString): IgsObject;
var
  I: Integer;
begin
  for I := 0 to FObjectList.Count - 1 do
  begin
    if FObjectList[I] is TComponent and
      (AnsiUpperCase(TComponent(FObjectList[I]).Name) = AnsiUpperCase(Name)) then
    begin
      Result := GetGdcOLEObject(FObjectList[I]) as IgsObject;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TobjDesigner.FreeAllObject;
var
  I: Integer;
  LObject: TObject;
  WrapObject: TWrapperAutoObject;
begin
  for I := FObjectList.Count - 1 downto 0 do
  begin
    LObject := FObjectList[I];
    FObjectList.Delete(I);
    WrapObject := GetGdcOLEObject(LObject);
    if WrapObject <> nil then
      WrapObject.DestroyDelphiObject
    else
      LObject.Free;
  end;
end;

function TobjDesigner.GetRegisterObject(const AObject: TObject): IgsObject;
var
  LWrapper: TWrapperAutoObject;
begin
  LWrapper := GetGdcOLEObject(AObject);
  // Если оболочка для класса не найдена
  if not Assigned(LWrapper) then
    raise Exception.Create(Format('Не удалось найти оболочку для класса %s',
     [ClassName]));
  // Сохраняем объект в список
  FObjectList.Add(AObject);
  // Присваиваем результат
  Result := LWrapper as IgsObject;
end;

procedure TobjDesigner.Initialize;
begin
  inherited;

  FObjectList := TobjDesignerFreeSpy.Create(nil);
end;

{ TobjDesignerFreeSpy }

function TobjDesignerFreeSpy.Add(AObject: TObject): Integer;
begin
  Result := FObjectList.Add(AObject);
  if AObject is TComponent then
    FreeNotification(TComponent(AObject));
end;

constructor TobjDesignerFreeSpy.Create(Owner: TComponent);
begin
  inherited;
  FObjectList := TObjectList.Create(False);
end;

procedure TobjDesignerFreeSpy.Delete(Index: Integer);
begin
  FObjectList.Delete(Index);
end;

destructor TobjDesignerFreeSpy.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TobjDesignerFreeSpy.GetCount: Integer;
begin
  Result := FObjectList.Count;
end;

function TobjDesignerFreeSpy.GetObjectList(Index: Integer): TObject;
begin
  Result := FObjectList[Index];
end;

function TobjDesignerFreeSpy.IndexOf(AObject: TObject): Integer;
begin
  Result := FObjectList.IndexOf(AObject);
end;

procedure TobjDesignerFreeSpy.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
    Remove(AComponent);

  inherited;
end;

function TobjDesignerFreeSpy.Remove(AObject: TObject): Integer;
begin
  Result := FObjectList.Count - 1;
  while (Result > -1) and (FObjectList[Result] <> AObject) do
    Dec(Result);

  if Result > -1 then FObjectList.Delete(Result);
end;

procedure TobjDesigner.RemoveObject(const AnObject: TObject);
begin
  FObjectList.Remove(AnObject);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TobjDesigner, CLASS_gs_Designer,
    ciMultiInstance, tmApartment);

  Designer := TobjDesigner.Create;
  IDesigner := Designer;
  AuxiliaryDesigner := Designer;

  {$IFDEF DEBUG}
    {$IFDEF WITH_INDY}
      ObjCnt := 0;
    {$ENDIF}
  {$ENDIF}

finalization
  IDesigner := nil;
  Designer := nil;
end.

