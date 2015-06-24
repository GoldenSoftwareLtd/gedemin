
unit gdc_createable_form;

interface

uses
  Classes,      gd_createable_form,     gdcBase,
  mtd_i_Base,   gsIBGrid,               evt_i_Base,
  gd_KeyAssoc,  Forms,                  gdcBaseInterface,
  Messages,     DBGrids,                gsDBGrid;

type
  TgdcCreateableForm = class;
  CgdcCreateableForm = class of TgdcCreateableForm;
  TgdcCreateableForm = class(TCreateableForm)
  private
    // поля для перекрытия методов макросами
    FOnDesigner: Boolean;
    FVarParam: TVarParamEvent;
    FReturnVarParam: TVarParamEvent;
    FClassMethodAssoc: TgdKeyIntAndStrAssoc;

    function GetGdcMethodControl: IMethodControl;

    // Процедура для регистрации методов TgdcBase для перекрытия их из макросов
    class procedure RegisterMethod;

    //
    procedure CreateInherited;

    // заполнение списка ключей для перекрытия методов макросами
    procedure CreateKeyList;

    procedure SetCurrentForm(const OwnerForm: TCreateableForm);

  protected
    FgdcObject: TgdcBase;
    FSubType: String;

    function CreateSelectedArr(Obj: TgdcBase; BL: TBookmarkList): OleVariant;

    procedure WndProc(var Message: TMessage); override;

    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;

    // Методы для перегрузки методов макросами
    // Метод вызывается по Inherited в макросе
    // В методе осуществляется передача параметров из макроса и
    // вызов  метода Делфи. Дальнейшая обработка идет в перекрытом методе Делфи
    // Name - имя перекрываемого метода, AnParams - вариантный массив параметров метода
    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; virtual;
    // Метод очищает стек классов вызова перекрытого метода
    // AClass, AMethod - имя класса и метода, из которого вызывается процедура
    procedure ClearMacrosStack(const AClass, AMethod: String;
      const AMethodKey: Byte);
    // для перекрытия методов макросами
    function  GetGdcInterface(Source: TObject): IDispatch;
    // Метод устанавливает класс, из которого впервые вызван перекрытый метод
    // установка делается для того, чтобы знать, где очищатьстек
    procedure SetFirstMethodAssoc(const AClass: String;
      const AMethodKey: Byte);

    procedure SetGdcObject(const Value: TgdcBase); virtual;

    procedure Loaded; override;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    function GetFormCaption: String; override;

    {$IFDEF DUNIT_TEST}
    procedure DUnitDoTimer; virtual;
    procedure DUnitOnTimer(Sender: TObject);

    procedure WMActivate(var Message: TMessage);
      message WM_ACTIVATE;
    {$ENDIF}

  public
    constructor CreateSubType(AnOwner: TComponent; const ASubType: String);

    constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = ''); override;
    constructor CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); override;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // перад выкарыстаньнем акна яго трэба настроiць
    procedure Setup(AnObject: TObject); override;

    // Свойства для перекрытия методов:
    property gdcMethodControl: IMethodControl read GetGdcMethodControl;
    // Стек вызовов.
    // Число-строковый массив с ключами. Ключ - это ключ метода.
    // В строковое поле заносится класс при первом попадании в метод,
    // после использование метода строка удаляется.
    // В числовом поле хранится ссылка на стек классов метода (тип TStringы).
    // Стек создается при первом обращении, уничтожается вместе с объектом.
    property ClassMethodAssoc: TgdKeyIntAndStrAssoc read FClassMethodAssoc;

    class function GetSubTypeList(ASubTypeList: TStrings;
      const ASubType: String = ''; AnOnlyDirect: Boolean = False): Boolean; virtual;

    class function CheckSubType(ASubType: String): Boolean; virtual;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    class function FindForm(const AFormClass: CgdcCreateableForm;
      const ASubType: TgdcSubType; const AnInitialName: String = ''): TgdcCreateableForm;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;

    procedure SaveGrid(AGrid: TgsCustomDBGrid);
    procedure LoadGrid(AGrid: TgsCustomDBGrid);

    property SubType: String read FSubType;
    property gdcObject: TgdcBase read FgdcObject write SetGdcObject;
  end;

implementation

uses
  SysUtils,             Storages,       gd_directories_const,
  gdcOLEClassList,      gd_ClassList,   mtd_i_Inherited,
  gsStorage,            prp_Methods,    DB,
  Windows,              Controls,       gd_strings

  {$IFDEF DUNIT_TEST}
    , extctrls, Test_Global_unit
  {$ENDIF}

  , gdcClasses;

type
  TCrackGdcBase = class(TgdcBase);

{ TgdcCreateableForm }

constructor TgdcCreateableForm.CreateSubType(AnOwner: TComponent;
  const ASubType: String);
begin
  FSubType := ASubType;
  Create(AnOwner);
end;

constructor TgdcCreateableForm.CreateNewUser(AnOwner: TComponent;
  const Dummy: Integer; const ASubType: String = '');
begin
  Include(FCreateableFormState, cfsDesigning);

  if ASubType > '' then
    FSubType := ASubType;

  if SameText(Self.ClassName, 'TgdcCreateableForm') then
  begin
    inherited CreateNewUser(AnOwner, Dummy, ASubType);
  end
  else
  begin
    Include(FCreateableFormState, cfsUserCreated);
    Include(FCreateableFormState, cfsCreating);
    CreateSubtype(AnOwner, ASubtype);
    FInitialName := '';
  end;
  FOnDesigner := True;
end;

procedure TgdcCreateableForm.SetGdcObject(const Value: TgdcBase);
begin
  if FgdcObject <> Value then
  begin
    if Assigned(FgdcObject) then
      FgdcObject.RemoveFreeNotification(Self);
    FgdcObject := Value;
    if (FSubType > '') and (FgdcObject <> nil) and (FgdcObject.CheckSubType(FSubType))then
      FgdcObject.SubType := FSubType;
    if Active then
      SetCurrentForm(Self);
    if Assigned(FgdcObject) then
    begin
      if (FgdcObject.Owner <> Self) and (Self.Owner <> FgdcObject) then
        FgdcObject.FreeNotification(Self);
      FgdcObject.GetClassImage(Icon.Width, Icon.Height, Icon);
    end;
  end;
end;

destructor TgdcCreateableForm.Destroy;
var
  I: Integer;
begin
  if Assigned(gdcObject) then
  begin
    if (TCrackGdcBase(FgdcObject).FCurrentForm = Self) then
      SetCurrentForm(nil);
    for I := 0 to TCrackGdcBase(FgdcObject).DetailLinksCount - 1 do
      if TCrackGdcBase(FgdcObject.DetailLinks[I]).FCurrentForm = self then
        TCrackGdcBase(FgdcObject.DetailLinks[I]).FCurrentForm := nil;
  end;

  if Assigned(FClassMethodAssoc) then
  begin
    for I := 0 to FClassMethodAssoc.Count - 1 do
    begin
      if FClassMethodAssoc.IntByIndex[I] <> 0 then
        TObject(FClassMethodAssoc.IntByIndex[I]).Free;
    end;

    FClassMethodAssoc.Free;
    FClassMethodAssoc := nil;
  end;

  if Assigned(InheritedMethodInvoker) then
    InheritedMethodInvoker.UnRegisterMethodInvoker(Self);

  inherited;
end;

constructor TgdcCreateableForm.Create(AnOwner: TComponent);
begin
  // При изменении этого метода измените еще и
  //  constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = '');
  //  constructor CreateUser(AnOwner: TComponent;

  inherited;

  CreateInherited;
  FOnDesigner := False;
  if Assigned(EventControl) then
  begin
    FVarParam := EventControl.OnVarParamEvent;
    FReturnVarParam := EventControl.OnReturnVarParam;
  end;
end;

constructor TgdcCreateableForm.CreateUser(AnOwner: TComponent;
  const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False);
begin
  FSubType := ASubType;

  inherited CreateUser(AnOwner, AFormName, ASubType, AForEdit);

  CreateInherited;
  FOnDesigner := True;
end;

procedure TgdcCreateableForm.ClearMacrosStack(const AClass,
  AMethod: String; const AMethodKey: Byte);
var
  Index: Integer;
begin
  if Assigned(FClassMethodAssoc) then
  begin
    if FClassMethodAssoc.StrByKey[AMethodKey] = AClass then
    begin
      Index := FClassMethodAssoc.IndexOf(AMethodKey);
      FClassMethodAssoc.StrByIndex[Index] := '';
      if FClassMethodAssoc.IntByIndex[Index] > 0 then
        TStackStrings(FClassMethodAssoc.IntByIndex[Index]).Clear;
    end;
  end;  
end;

function TgdcCreateableForm.GetGdcInterface(Source: TObject): IDispatch;
begin
  Result := GetGdcOLEObject(Source) as IDispatch;
end;

function TgdcCreateableForm.GetGdcMethodControl: IMethodControl;
begin
  if Assigned(MethodControl) and (not FOnDesigner) and
    (not UnMethodMacro) and Self.InheritsFrom(TgdcCreateableForm) then
    Result := MethodControl
  else
    Result := nil;
end;

function TgdcCreateableForm.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  // проверка имени метода
  if  AnsiUpperCase(Name) = 'SAVESETTINGS' then
  begin
   {преобразование параметров для метода Делфи:
    параметры по значению:
    Param := приведение_к_типу(AnParams[...]);
    параметры по ссылке
    Param := приведение_к_типу(getVarParam(AnParams[...]));}

    // вызов метода Делфи с актуальными параметрами
    // если это фунция, то вызов: Result  := Метод_Делфи, если нет, то Метод_Делфи
    SaveSettings;
    // если есть var-параметры обратное передача параметров из метода в вариантнвй массив AnParams
    { EventControl.GetParamInInterface(IDispatch(AnParams[...]), Param);
      ....
    }
  end else
{  if  AnsiUpperCase(Name) = 'BEFOREPOST' then
  begin
    BeforePost
  end else
  if  AnsiUpperCase(Name) = 'POST' then
  begin
    Post
  end else
  if  AnsiUpperCase(Name) = 'CANCEL' then
  begin
    Cancel
  end else
  if  AnsiUpperCase(Name) = 'TESTCORRECT' then
  begin
    Result := TestCorrect;
  end else}
  if  AnsiUpperCase(Name) = 'LOADSETTINGS' then
  begin
    LoadSettings
  end else
  if  AnsiUpperCase(Name) = 'SETUP' then
  begin
    Setup(InterfaceToObject(AnParams[1]));
  end else
  if  AnsiUpperCase(Name) = 'LOADSETTINGSAFTERCREATE' then
  begin
    LoadSettingsAfterCreate
  end else
  ;
end;

class procedure TgdcCreateableForm.RegisterMethod;
begin
  RegisterFrmClassMethod(TgdcCreateableForm, 'SaveSettings', 'Self: Object', '');
  RegisterFrmClassMethod(TgdcCreateableForm, 'LoadSettingsAfterCreate', 'Self: Object', '');
//  RegisterFrmClassMethod(TgdcCreateableForm, 'BeforePost', 'Self: Object', '');
//  RegisterFrmClassMethod(TgdcCreateableForm, 'Post', 'Self: Object', '');
//  RegisterFrmClassMethod(TgdcCreateableForm, 'Cancel', 'Self: Object', '');
//  RegisterFrmClassMethod(TgdcCreateableForm, 'TestCorrect', 'Self: Object', 'Variable');
  RegisterFrmClassMethod(TgdcCreateableForm, 'LoadSettings', 'Self: Object', '');
  RegisterFrmClassMethod(TgdcCreateableForm, 'Setup', 'Self: Object; AnObject: Object', '');
end;

procedure TgdcCreateableForm.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDCCREATEABLEFORM', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCREATEABLEFORM', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCREATEABLEFORM') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCREATEABLEFORM',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCREATEABLEFORM' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDCCREATEABLEFORM', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDCCREATEABLEFORM', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

class function TgdcCreateableForm.GetSubTypeList(ASubTypeList: TStrings;
  const ASubType: String = ''; AnOnlyDirect: Boolean = False): Boolean;
begin
  Assert(ASubTypeList <> nil);
  Result := gdClassList.GetSubTypeList(Self, ASubType, ASubTypeList, AnOnlyDirect, True)
end;

class function TgdcCreateableForm.CheckSubType(ASubType: String): Boolean;
var
  CE: TgdClassEntry;
begin
  Result := False;

  CE := gdClassList.Find(Self, ASubType);

  if CE <> nil then
    Result := True;
end;

procedure TgdcCreateableForm.CreateInherited;
begin
  if not Assigned(FClassMethodAssoc) then
    FClassMethodAssoc := TgdKeyIntAndStrAssoc.Create;
  if Assigned(InheritedMethodInvoker) and (not UnMethodMacro) then
      InheritedMethodInvoker.RegisterMethodInvoker(Self, OnInvoker);
  CreateKeyList;
end;

procedure TgdcCreateableForm.SaveGrid(AGrid: TgsCustomDBGrid);
var
  gdcBase: TgdcBase;
  F: TgsStorageFolder;
  FolderName, Path: String;
begin
  if Assigned(UserStorage) and Assigned(AGrid) then
  begin
    if AGrid.SettingsModified or (cfsDistributeSettings in CreateableFormState) then
      Path := UserStorage.SaveComponent(AGrid, AGrid.SaveToStream);

    //Сохраняем настройки грида для б.о.
    if (AGrid.DataSource <> nil) and (AGrid.DataSource.DataSet is TgdcDocument) then
    begin
      gdcBase := AGrid.DataSource.DataSet as TgdcBase;
      FolderName := 'GDC\' + gdcBase.ClassName + gdcBase.SubType;
      if (not UserStorage.FolderExists(FolderName)) or
        AGrid.SettingsModified or (cfsDistributeSettings in CreateableFormState) then
      begin
        F := UserStorage.OpenFolder(FolderName, True, False);
        try
          if F <> nil then
          begin
            if not (F.ValueByName('GrSet') is TgsStringValue) then
              F.DeleteValue('GrSet');
            F.WriteString('GrSet', Path);
          end;
        finally
          UserStorage.CloseFolder(F, False);
        end;
      end;
    end;
  end;
end;

procedure TgdcCreateableForm.LoadGrid(AGrid: TgsCustomDBGrid);
begin
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(AGrid, AGrid.LoadFromStream);
end;

procedure TgdcCreateableForm.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDCCREATEABLEFORM', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCREATEABLEFORM', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCREATEABLEFORM') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCREATEABLEFORM',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCREATEABLEFORM' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDCCREATEABLEFORM', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDCCREATEABLEFORM', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TgdcCreateableForm.LoadSettingsAfterCreate;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDCCREATEABLEFORM', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCREATEABLEFORM', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCREATEABLEFORM') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCREATEABLEFORM',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCREATEABLEFORM' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDCCREATEABLEFORM', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDCCREATEABLEFORM', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

function TgdcCreateableForm.GetVarInterface(
  const AnValue: Variant): OleVariant;
begin
  if Assigned(FVarParam) then
    Result := FVarParam(AnValue)
  else
    Result := AnValue;
end;

function TgdcCreateableForm.GetVarParam(
  const AnValue: Variant): OleVariant;
begin
  if Assigned(FReturnVarParam) then
    Result := FReturnVarParam(AnValue)
  else
    Result := AnValue;
end;

procedure TgdcCreateableForm.SetFirstMethodAssoc(const AClass: String;
  const AMethodKey: Byte);
begin
  Assert(Assigned(FClassMethodAssoc));
  if Length(FClassMethodAssoc.StrByKey[AMethodKey]) = 0 then
    FClassMethodAssoc.StrByKey[AMethodKey] := AClass;
end;

procedure TgdcCreateableForm.CreateKeyList;
begin
  Assert(Assigned(FClassMethodAssoc));
  FClassMethodAssoc.Add(keySaveSettings);
  FClassMethodAssoc.Add(keySetup);
  FClassMethodAssoc.Add(keyLoadSettings);
  FClassMethodAssoc.Add(keyLoadSettingsAfterCreate);
  FClassMethodAssoc.Add(keyBeforePost);
  FClassMethodAssoc.Add(keyCancel);
  FClassMethodAssoc.Add(keyPost);
  FClassMethodAssoc.Add(keyTestCorrect);
  FClassMethodAssoc.Add(keySetChoose);
  FClassMethodAssoc.Add(keySyncField);
  FClassMethodAssoc.Add(keyNeedVisibleTabSheet);
  FClassMethodAssoc.Add(keySaveAndShowTabSheet);
  FClassMethodAssoc.Add(keySetupRecord);
  FClassMethodAssoc.Add(keyGetgdcClass);
  FClassMethodAssoc.Add(keyGetChooseComponentName);
  FClassMethodAssoc.Add(keyGetChooseSubSet);
  FClassMethodAssoc.Add(keyGetChooseSubType);
  FClassMethodAssoc.Add(keyRemoveSubSetList);
  FClassMethodAssoc.Add(keySetupDialog);
end;

class function TgdcCreateableForm.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := Self.Create(AnOwner);
end;

procedure TgdcCreateableForm.Loaded;
var
  NewName: String;
  Z, J: Integer;
begin
  if (FSubType > '') and not (cfsUserCreated in CreateableFormState) then
  begin
    NewName := Copy(ClassName, 2, 255) + RemoveProhibitedSymbols(FSubType);

    // Присваивается начальное имя формы
    FInitialName := NewName;

    // Далее должен идти поиск уникального имени формы
    Z := 0;
    J := 0;
    while Z < Screen.CustomFormCount do
    begin
      if (Screen.CustomForms[Z] <> Self) and
        (AnsiCompareText(Screen.CustomForms[Z].Name, NewName) = 0) then
      begin
        if J > 0 then
        begin
          if J = 9 then
          begin
            Screen.CustomForms[Z].Show;
            Abort;
          end else
            SetLength(NewName, Length(NewName) - 2);
        end;
        Inc(J);
        NewName := NewName + '_' + IntToStr(J);
        Z := 0;
      end else
        Inc(Z);
    end;

    Name := NewName;
  end;

  inherited;
end;

class function TgdcCreateableForm.FindForm(
  const AFormClass: CgdcCreateableForm;
  const ASubType: TgdcSubType;
  const AnInitialName: String = ''): TgdcCreateableForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FormsList.Count - 1 do
  begin
    if (FormsList[I].ClassName = AFormClass.ClassName)
      and ((FormsList[I] as TgdcCreateableForm).SubType = ASubType)
      and ((FormsList[I] as TgdcCreateableForm).Parent = nil)
      and ((AnInitialName = '') or ((FormsList[I] as TgdcCreateableForm).InitialName = AnInitialName)) then
    begin
      Result := FormsList[I] as TgdcCreateableForm;
      break;
    end;
  end;
end;

procedure TgdcCreateableForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FgdcObject) then
    FgdcObject := nil;
end;

procedure TgdcCreateableForm.WndProc(var Message: TMessage);
begin
  if Assigned(FgdcObject) then
    try
      case Message.Msg of
        WM_ACTIVATE:
        begin
          if (Message.WParam = WA_ACTIVE) or (Message.WParam = WA_CLICKACTIVE) then
            SetCurrentForm(Self)
          else
            if Message.WParam = WA_INACTIVE then
              SetCurrentForm(nil);
        end;
        CM_ACTIVATE:
        begin
          SetCurrentForm(Self);
        end;
        CM_DEACTIVATE:
          SetCurrentForm(nil);
      end;
    except
    end;
  inherited;
end;

procedure TgdcCreateableForm.SetCurrentForm(
  const OwnerForm: TCreateableForm);
var
  I: Integer;
begin
  if Assigned(FgdcObject) then
  begin
    TCrackGdcBase(FgdcObject).FCurrentForm := OwnerForm;
    for I := 0 to TCrackGdcBase(FgdcObject).DetailLinksCount - 1 do
      if Assigned(FgdcObject.DetailLinks[I]) then
        TCrackGdcBase(FgdcObject.DetailLinks[I]).FCurrentForm := OwnerForm;
  end;
end;

function TgdcCreateableForm.CreateSelectedArr(Obj: TgdcBase;
  BL: TBookmarkList): OleVariant;
begin
  Result := gdcBase.CreateSelectedArr(Obj, BL);
end;

procedure TgdcCreateableForm.Setup(AnObject: TObject);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDCCREATEABLEFORM', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDCCREATEABLEFORM', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCREATEABLEFORM') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCREATEABLEFORM',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDCCREATEABLEFORM' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited Setup(AnObject);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDCCREATEABLEFORM', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDCCREATEABLEFORM', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

{$IFDEF DUNIT_TEST}

procedure TgdcCreateableForm.DUnitDoTimer;
begin
  if fsModal in FormState then
    ModalResult := mrCancel
  else
    Close;   
end;

procedure TgdcCreateableForm.DUnitOnTimer(Sender: TObject);
begin
  (Sender as TTimer).Enabled := False;
  DUnitDoTimer;
end;

procedure TgdcCreateableForm.WMActivate(var Message: TMessage);
begin
  inherited;

  if (Message.WParam <> WA_INACTIVE) and DUnit_Process_Form_Flag then
  begin
    with TTimer.Create(Self) do
      OnTimer := DUnitOnTimer;
    DUnit_Process_Form_Flag := False;
  end;
end;

{$ENDIF}

function TgdcCreateableForm.GetFormCaption: String;
var
  CE: TgdClassEntry;
  Pref, Postf: String;
begin
  Result := Caption;
  Pref := '';
  Postf := '';

  if gdcObject <> nil then
  begin
    CE := gdClassList.Get(TgdClassEntry, gdcObject.ClassName, gdcObject.SubType);

    if (CE.Caption <> '') and (CE.Caption <> gdcObject.ClassName) then
      Result := CE.Caption
    else begin
      CE := gdClassList.Get(TgdFormEntry, Self.ClassName, '');
      if (CE.Caption <> '') and (CE.Caption <> Self.ClassName) then
        Result := CE.Caption
    end;

    if BorderStyle = bsDialog then
    begin
      if gdcObject.State = dsInsert then
        Pref := 'Добавление: '
      else if gdcObject.State = dsEdit then
        Pref := 'Редактирование: '
      else
        Pref := 'Просмотр: ';
    end;

    if (gdcObject.State = dsEdit) and (not gdcObject.CanEdit)
      and (not (sSubDialog in gdcObject.BaseState)) then
    begin
      Postf := ' [Только просмотр]';
    end;
  end;

  Result := Pref + Result + Postf;
end;

initialization
  RegisterFrmClass(TgdcCreateableForm);
  TgdcCreateableForm.RegisterMethod;

finalization
  UnRegisterFrmClass(TgdcCreateableForm);

{@DECLARE MACRO Inh_CrForm_Params(%Var%)
%Var%
  Params, LResult: Variant;
  tmpStrings: TStackStrings;
END MACRO}

{@DECLARE MACRO Inh_CrForm_WithoutParams(%ClassName%, %MethodName%, %MethodKey%)
  try
    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
    begin
      SetFirstMethodAssoc(%ClassName%, %MethodKey%);
      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
      if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
      begin
        Params := VarArrayOf([GetGdcInterface(Self)]);
        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
          %MethodName%, %MethodKey%, Params, LResult) then exit;
      end else
        if tmpStrings.LastClass.gdClassName <> %ClassName% then
        begin
          Inherited;
          Exit;
        end;
    end;
END MACRO}

{@DECLARE MACRO Inh_CrForm_TestCorrect(%ClassName%, %MethodName%, %MethodKey%)
Result := True;
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self)]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if VarType(LResult) = $000B then
          Result := LResult;
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited TestCorrect;
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_CrForm_Setup(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then exit;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Inherited;
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_CrForm_Finally(%ClassName%, %MethodName%, %MethodKey%)
finally
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
    ClearMacrosStack(%ClassName%, %MethodName%, %MethodKey%);
end;
END MACRO}

end.
