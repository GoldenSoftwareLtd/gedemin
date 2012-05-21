
unit gd_createable_form;

interface

uses
  Classes, Forms, Gedemin_TLB, Windows, Messages, Controls, ContNrs,
  gsResizer;

type
  TCreateableForm = class;
  CCreateableForm = class of TCreateableForm;
  TgdVariables = class;
  TgdObjects = class;

  /////////////////////////////////////////////////////////
  //cfsDesignig - форма в режиме редактирования
  //cfsUserCreated - форма созданная пользователем
  //cfsAdmin - Текущий пользователь администратор
  //cfsCreating - Форма созданна впервые для редактирования
  //cfsSetting -- идет загрузка или сохранение настроек
  //cfsDistributeSettings -- распространение настроек формы всем польз.
  TCreateableFormState = (
    cfsDesigning,
    cfsUserCreated,
    cfsCreating,
    cfsCloseAfterDesign,
    cfsLoading,
    cfsSetting,
    cfsDistributeSettings);

  TCreateableFormStates = set of TCreateableFormState;

  TCreateableForm = class(TForm)
  private
    FResizer: TgsResizeManager;
    FInitializedCarefully: Boolean;
    FCreatedCarefully: Boolean;
    FUseDesigner: Boolean;
    FResizerActivated: Boolean;
    FVariables: TgdVariables;
    FObjects: TgdObjects;
    //FAUTimerInitialized: Boolean;
    //FOldTickCount: DWORD;

    FShowSpeedButton: Boolean;
    FOnSaveSettings: TNotifyEvent;
    FOnLoadSettingsAfterCreate: TNotifyEvent;

    procedure LoadSettingsAfterCreateEvent(Sender: TObject);
    procedure SaveSettingsEvent(Sender: TObject);

    function GetVariables(Name: String): OleVariant;
    procedure SetVariables(Name: String; const Value: OleVariant);
    function GetObjects(Name: String): IDispatch;
    procedure SetObjects(Name: String; const Value: IDispatch);
    function GetShowSpeedButton: Boolean;
    procedure SetShowSpeedButton(const Value: Boolean);
    function GetText: TCaption;
    function IsCaptionStored: Boolean;
    procedure SetText(const Value: TCaption);
  protected
    FCreateableFormState: TCreateableFormStates;
    FShiftDown: Boolean;
    FInitialName: String;       // Если новая форма, то содержит ее
                                // наименование введенное пользователем

    procedure SetName(const NewName: TComponentName); override;
    function Get_WindowQuery: IgsQueryList; virtual; safecall;
    function Get_SelectedKey: OleVariant; virtual; safecall;

    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure Activate; override;
    procedure DoHide; override;
    procedure DoShow; override;

    procedure Loaded; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure ResizerOnActivate(var Activate: Boolean); virtual;
    procedure DoClose(var Action: TCloseAction); override;

    procedure SetInitialName;

    procedure WMMoving(var Message: TMessage);
      message WM_MOVING;

    procedure WMSizing(var Message: TMessage);
      message WM_SIZING;

    procedure WMSysCommand(var Message: TMessage);
      message WM_SYSCOMMAND;

    // Процедуры только для использования в скрипт-функциях
    // Добавляют итем для хранения Variables
    function  ObjectExists(const Name: String): Boolean;
    function  VariableExists(const Name: String): Boolean;
    procedure AddVariableItem(const Name: String);
    // Добавляют итем для хранения Objects
    procedure AddObjectItem(const Name: String);

    //
    procedure UpdateActions; override;

    // До закрытия формы могут выполняться какие-то действия,
    // и когда дойдет непосредственно до закрытия, Shift может быть
    // отпущен => сохраняем его значение в FShiftDown
    procedure WMClose(var Message: TMessage);
      message WM_Close;

    // Свойства только для использования в скрипт-функциях
    // В СФ являются аналогами свойств формы
    // Список переменных привязанных к форме
    property Variables[Name: String]: OleVariant read GetVariables write SetVariables;
    // Список объектов привязанных к форме
    property Objects[Name: String]: IDispatch read GetObjects write SetObjects;

  public
    constructor Create(AnOwner: TComponent); override;

    constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = '');  overload; virtual;
    constructor CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); overload; virtual;

    destructor Destroy; override;

    procedure AfterConstruction; override;

    // Функция возвращает начальное Имя формы, до модификации приложением
    // Используется для привязки событий
    function InitialName: String; virtual;

    // перад выкарыстаньнем акна яго трэба настроiць
    procedure Setup(AnObject: TObject); dynamic;

    // сохранить настройки формы, вызывается при сохранении десктопа
    procedure SaveDesktopSettings; virtual;
    // загрузить настройки формы, вызывается при загрузке (смене) десктопа
    procedure LoadDesktopSettings; virtual;

    // сохранить настройки формы, вызывается при удалении формы
    // в вызове ОнДестрой
    procedure SaveSettings; virtual;
    // считать настройки формы, вызывается при создании формы
    // еще в вызове метода ОнКреэйт
    procedure LoadSettings; virtual;
    // считать настройки формы, вызывается при создании формы
    // уже после вызова метода ОнКреэйт
    procedure LoadSettingsAfterCreate; virtual;
    // устанавливает фокус на сомпонент по его имени
    procedure SetFocusOnComponent(const AComponentName: String);
    //Обратите внимание на функцию FormAssigned она необходима, так как
    //Assigned проверяет равен указатель НИЛ или не равен, и если переменной
    //был присвоен объект, а потом удален, то Assigned(переменная) вернет
    //Истина, хотя объекта нет!
    //
    //в креэтэблформ есть метод
    //
    //    class function FormAssigned(F: TCreateableForm): Boolean;
    //
    //который надо использовать вместо проверки на Assigned()
    //
    //в программе ведется список указателей на создаваемые
    //формы. Когда форма создается в этот список добавляется ссылка
    //на нее. Когда удаляется -- ссылка изымается. Таким образом
    //функция вернет правильный результат, даже если проверяемая
    //переменная не равна нил. Например, форма была создана, использована,
    //а потом удалена. В этом случае проверка на Assigned ничего не даст,
    //а наша функция вернет корректный результат.
    //
    //Очевидно, что данная функция нам понадобилась всвязи с тем, что
    //часть форм могут удаляться в автоматическом режиме (см. выше)
    //и естественно, что переменная ссылка обнуляться не будет.
    //
    class function FormAssigned(F: TCreateableForm): Boolean;
    class function CreateAndAssign(AnOwner: TComponent): TForm; virtual;

    function ShowModal: Integer; override;


    property Resizer: TgsResizeManager read FResizer;
    property CreateableFormState: TCreateableFormStates read FCreateableFormState write FCreateableFormState;
    property UseDesigner: Boolean read FUseDesigner write FUseDesigner;
    property ResizerActivated: Boolean read FResizerActivated;
    property CreatedCarefully: Boolean read FCreatedCarefully;

    // используется для локализации исключений в safecall ф-циях
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer):
      HResult; override;
  published
    property ShowSpeedButton: Boolean read GetShowSpeedButton write SetShowSpeedButton;
    property Caption: TCaption read GetText write SetText stored IsCaptionStored;

    property OnLoadSettingsAfterCreate: TNotifyEvent read FOnLoadSettingsAfterCreate write FOnLoadSettingsAfterCreate;
    property OnSaveSettings: TNotifyEvent read FOnSaveSettings write FOnSaveSettings;
  end;

  TgdCustomVariables = class(TObject)
  private
    FStrings: TStringList;

  protected
    procedure Clear; safecall;

    function  Exists(Name: String): Boolean;
    function  GetVariables(Name: String): OleVariant;
    procedure SetVariables(Name: String; const Value: OleVariant);
    procedure AddVariable(const Name: String);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TgdVariables = class(TgdCustomVariables)
  private
    function GetVariables(Name: String): OleVariant;
    procedure SetVariables(Name: String; const Value: OleVariant);

  public
    function  VariableExists(Name: String): Boolean;
    procedure AddVariable(const Name: String);
    property Variables[Name: String]: OleVariant read GetVariables write SetVariables; default;
  end;

  TgdObjects = class(TgdCustomVariables)
  private

    function GetObjects(Name: String): IDispatch;
    procedure SetObjects(Name: String; const Value: IDispatch);
  public

    function  ObjectExists(const Name: String): Boolean;
    procedure AddObject(const Name: String);
    property Objects[Name: String]: IDispatch read GetObjects write SetObjects; default;
  end;

procedure FreeAllForms(const OnlyInvisible: Boolean);
function FindForm(FormClass: CCreateableForm): TCreateableForm;

var
  _OnCreateForm: TNotifyEvent;
  _OnDestroyForm: TNotifyEvent;
  _OnActivateForm: TNotifyEvent;
  _OnCaptionChange: TNotifyEvent;

  FormsList: TObjectList;

implementation

uses
  SysUtils, SyncObjs, gsDesktopManager, Menus//, Controls
  {$IFDEF DEBUG}
  , gd_debug
  {$ENDIF}
  , evt_i_Base, PasswordDialog, gd_security, Storages, gsStorage_CompPath,
  gd_Directories_const, Dialogs, gdc_frmG_unit, gdc_frmExplorer_unit, ComObj,
  {$IFDEF LOCALIZATION}
  gd_localization,
  {$ENDIF}
  gd_strings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  Treshold = 10;

type
  TCrackControlActionLink = class(TControlActionLink)
  end;

procedure FreeAllForms(const OnlyInvisible: Boolean);
var
  I: Integer;
  F: TForm;
begin
  Assert(Assigned(FormsList));

  I := FormsList.Count - 1;

  while I >= 0 do
  begin
    if (I < FormsList.Count) and Assigned(FormsList[I]) then
    begin
      F := FormsList[I] as TForm;

      if not (csDestroying in F.ComponentState)
        and (Application.MainForm <> F)
        and ((not F.Visible) or (not OnlyInvisible))
        and ((F.Owner = nil) or (F.Owner = Application))
        {and (FormsList.IndexOf(F.Owner) = -1)}
      then begin
        //Т.к. данный на форме могли быть изменены то просто вызов метода Relase
        //некорректен.
        //!!! добавлено 21.03.2003. TipTop
        if F.CloseQuery then
        begin
          FormsList.Extract(F);

          {$IFDEF DEBUG}
          LogRecord('Выдалена чысцільнікам: ' + F.Name + ' (' + F.ClassName + ')');
          {$ENDIF}

          //F.Free;
          F.Release;
        end else
          Abort;
      end;
    end;

    Dec(I);
  end;
end;

function FindForm(FormClass: CCreateableForm): TCreateableForm;
var
  I: Integer;
begin
  Result := nil;
  if FormsList <> nil then
  begin
    for I := 0 to FormsList.Count - 1 do
    begin
      if TCreateableForm(FormsList[I]).ClassType = FormClass then
      begin
        Result := TCreateableForm(FormsList[I]);
        Exit;
      end;
    end;
  end;
end;

{ TCreateableForm }

{
  Если идет отключение от базы данных и какая-либо
  форма хочет оставаться на экране, она
  должна перекрыть этот метод и присвоить False.

  Это необходимо для создания атрибутов-ссылок.
}

constructor TCreateableForm.Create(AnOwner: TComponent);
begin
// !!!!! Если меняете этот метод то измените еще и CreateUser и CreateNewUser

  FShowSpeedButton := False;
  FUseDesigner := True;
  Assert(Assigned(FormsList));
  FInitializedCarefully := False;
  FCreatedCarefully := False;
  FResizerActivated := False;

  if (IBLogin <> nil) and IBLogin.LoggedIn then
  begin
    FResizer := TgsResizeManager.Create(Self);
    if (not (cfsCreating in FCreateableFormState)) or
       IBLogin.IsIBUserAdmin then
    begin
      FResizer.OnActivate := ResizerOnActivate;
      FResizer.ShortCut := ShortCut(Word('E'), [ssCtrl, ssAlt]);
      FResizer.MacrosShortCut := ShortCut(Word('M'), [ssCtrl, ssAlt])
    end;
  end;

  SetInitialName;
  inherited Create(AnOwner);

  if Assigned(FResizer) then
  begin
    FResizer.EditForm := Self;
    FResizer.SetSettings;
  end;

  FormsList.Add(Self);

  // !!!!! Если меняете этот метод то измените еще и CreateUser и CreateNewUser
end;

class function TCreateableForm.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  Result := Self.Create(AnOwner);
end;

constructor TCreateableForm.CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = '');
begin
  FShowSpeedButton := False;
  FUseDesigner := True;

  Assert(Assigned(FormsList));

  Include(FCreateableFormState, cfsUserCreated);
  Include(FCreateableFormState, cfsCreating);
  Include(FCreateableFormState, cfsDesigning);

  if (IBLogin <> nil) and IBLogin.LoggedIn then
  begin
    FResizer := TgsResizeManager.Create(Self);
    if (not (cfsCreating in FCreateableFormState)) or
       IBLogin.IsIBUserAdmin then
    begin
      FResizer.OnActivate := ResizerOnActivate;
      FResizer.ShortCut := ShortCut(Word('E'), [ssCtrl, ssAlt]);
      FResizer.MacrosShortCut := ShortCut(Word('M'), [ssCtrl, ssAlt])
    end;
  end;

  CreateNew(AnOwner);

  FResizer.EditForm := Self;
  FResizer.SetSettings;

  FormsList.Add(Self);
end;

function gdInternalReadComponentRes(const ResName, FormName: string; var Instance: TComponent): Boolean;
var
  F: TMemoryStream;
begin
  if Assigned(GlobalStorage) then
  begin
    F := TMemoryStream.Create;
    try
      GlobalStorage.ReadStream(ResName + '\' + FormName, st_ds_UserFormDFM, F);
      Instance := F.ReadComponent(Instance);
    finally
      F.Free;
    end;
    Result := True;
  end
  else
    Result := False
end;

function gdInitInheritedComponent(Instance: TComponent; RootAncestor: TClass; const AFormName: String): Boolean;
  function InitComponent(ClassType: TClass): Boolean;
  const
    Signature = 'TPF';
  var
    F, R: TMemoryStream;
    S: String;
  begin
    if Assigned(GlobalStorage) then
    begin
      F := TMemoryStream.Create;
      try
        GlobalStorage.ReadStream(st_ds_NewFormPath + '\' + AFormName, st_ds_UserFormDFM, F);
        SetLength(S, 3);
        if (F.Read(S[1], 3) = 3) and (S = Signature) then
        begin
          F.Position := 0;
          Instance := F.ReadComponent(Instance);
        end else
        begin
          R := TMemoryStream.Create;
          try
            F.Position := 0;
            ObjectTextToBinary(F, R);
            R.Position := 0;
            Instance := R.ReadComponent(Instance)
          finally
            R.Free;
          end;
        end;
      finally
        F.Free;
      end;
      Result := True;
    end else
      Result := False
  end;
var
  LocalizeLoading: Boolean;
begin
  GlobalNameSpace.BeginWrite;  // hold lock across all ancestor loads (performance)
  try
    LocalizeLoading := (Instance.ComponentState * [csInline, csLoading]) = [];
    try
      if LocalizeLoading then BeginGlobalLoading;  // push new loadlist onto stack
      Result := InitComponent(Instance.ClassType);
      if Result and LocalizeLoading then NotifyGlobalLoading;  // call Loaded
    finally
      if LocalizeLoading then EndGlobalLoading;  // pop loadlist off stack
    end;
  finally
    GlobalNameSpace.EndWrite;
  end;
end;

constructor TCreateableForm.CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False);
begin
  FShowSpeedButton := False;

  Assert(Assigned(FormsList));

  FInitialName := AFormName;

  FInitializedCarefully := False;
  FCreatedCarefully := False;
  FResizerActivated := False;

  Include(FCreateableFormState, cfsUserCreated);
  if AForEdit then
    Include(FCreateableFormState, cfsDesigning);
  if (IBLogin <> nil) and IBLogin.LoggedIn then
  begin
    FResizer := TgsResizeManager.Create(Self);
    if (not (cfsCreating in FCreateableFormState)) or
       IBLogin.IsIBUserAdmin then
    begin
      FResizer.OnActivate := ResizerOnActivate;
      FResizer.ShortCut := ShortCut(Word('E'), [ssCtrl, ssAlt]);
      FResizer.MacrosShortCut := ShortCut(Word('M'), [ssCtrl, ssAlt])
    end;
  end;

  GlobalNameSpace.BeginWrite;

  try
    CreateNew(AnOwner);
    Include(FFormState, fsCreating);
    try
      gdInitInheritedComponent(Self, TCreateableForm, AFormName)
    finally
      Exclude(FFormState, fsCreating);
    end;
    if OldCreateOrder then DoCreate;
  finally
    GlobalNameSpace.EndWrite;
  end;
  if (IBLogin <> nil) and IBLogin.LoggedIn and IBLogin.IsIBUserAdmin then
    FUseDesigner := True
  else
    FUseDesigner := False;

  FResizer.EditForm := Self;
  FResizer.SetSettings;

  FormsList.Add(Self);
end;

destructor TCreateableForm.Destroy;
begin
  FVariables.Free;
  FObjects.Free;

  if Assigned(FormsList) then
    FormsList.Extract(Self);

  if Assigned(EventControl) then
  begin
    EventControl.ResetEvents(Self);
  end;

  if Assigned(DesktopManager) then
  begin
    DesktopManager.DesktopItems.Remove(Self);
  end;

  inherited;
end;

procedure TCreateableForm.DoCreate;
var
  WasException: Boolean;
begin
  WasException := False;
  Include(FCreateableFormState, cfsSetting);
  try
    try
      try
        LoadDesktopSettings;
      except
        WasException := True;
        Application.HandleException(Self);
      end;

      try
        if (GetAsyncKeyState(VK_SHIFT) shr 1) = 0 then
        begin
          LoadSettings;
        end else
          WasException := True;
      except
        WasException := True;
        Application.HandleException(Self);
      end;

      // EventControl присваивает свой обработчик на форму
      if Assigned(EventControl) then
      begin
        EventControl.SetEvents(Self);
      end;

      // Вызывается обработчик OnCreate для EventControl,
      // при этом делфовский обработчик вызываться не будет,
      // т.к. он был обнулен.
      if Assigned(OnCreate) and (not (cfsDesigning in CreateableFormState)) then
        try
          OnCreate(Self);
          FCreatedCarefully := True;
        except
          Application.HandleException(Self);
        end
      else
        FCreatedCarefully := True;

      if fsVisible in FormState then Visible := True;

      // EventControl присваевает обработчики на все дочерние компоненты
      if Assigned(EventControl) then
        EventControl.SafeCallSetEvents(Self);

      // Resizer выполняет установку ізмененных настроек
      try
        if not WasException then
        begin
          if Assigned(FOnLoadSettingsAfterCreate) then
            FOnLoadSettingsAfterCreate(Self);
        end;
      except
        WasException := True;
        Application.HandleException(Self);
      end;

      FInitializedCarefully := (not WasException) and FCreatedCarefully;
    except
      Application.HandleException(Self);
    end;
  finally
    Exclude(FCreateableFormState, cfsSetting);
  end;
{  if Assigned(_OnCreateForm) and FShowSpeedButton then
    _OnCreateForm(Self);}
  FShiftDown := False;
end;

procedure TCreateableForm.DoDestroy;
begin
  if Assigned(_OnDestroyForm) and FShowSpeedButton then
    _OnDestroyForm(Self);

  if FInitializedCarefully then
  begin
    if (not (cfsDesigning in CreateableFormState))
      and (not (cfsCloseAfterDesign in CreateableFormState)) then
    begin
      try
        if Assigned(FOnSaveSettings) then
        begin
          if (IBLogin <> nil) and (IBLogin.Database <> nil)
            and IBLogin.Database.Connected then
          begin
            FOnSaveSettings(Self);
          end;  
        end;
      except
        on E: Exception do
        begin
          Application.ShowException(E);
        end;
      end;
    end;
  end else begin
    if FShiftDown then
    begin
      if MessageBox(Handle,
        'При загрузке настроек возникали ошибки '#13#10 +
        'или форма была открыта в режиме "без настроек".'#13#10#13#10 +
        'Сохранение настроек может привести к потере'#13#10 +
        'прежних настроек.'#13#10#13#10 +
        'Сохранять?',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
      begin
        if Assigned(FOnSaveSettings) then
          FOnSaveSettings(Self);
      end;
    end;
  end;

  inherited;
end;

procedure TCreateableForm.DoHide;
begin
  inherited;
  if Assigned(FResizer) then
    FResizer.ExitWithoutSaving;
end;

procedure TCreateableForm.DoShow;
begin
  //Делаем доступным окно перед вызовом inherited чтобы
  //редактор был доступен в обработчике OnShow
  if (fsModal in FormState) and Assigned(EventControl) and
    (Self <> EventControl.GetProperty) then
    EventControl.EnableProperty;

  inherited;
end;

class function TCreateableForm.FormAssigned(F: TCreateableForm): Boolean;
begin
  Result := (F <> nil) and (FormsList <> nil) and (FormsList.IndexOf(F) > -1);
end;

procedure TCreateableForm.SetInitialName;
var
  HRsrc: THandle;
  Reader: TReader;
  Flags: TFilerFlags;
  RS: TResourceStream;
  HInst: THandle;
  I: Integer;
  CN: String;
begin
  HInst := FindResourceHInstance(FindClassHInstance(ClassType));
  if HInst = 0 then HInst := HInstance;
  CN := ClassName;
  HRsrc := FindResource(HInst, PChar(CN), RT_RCDATA);
  if HRsrc = 0 then Exit;
  RS := TResourceStream.Create(HInst, CN, RT_RCDATA);
  try
    Reader := TReader.Create(RS, 4096);
    try
      Reader.ReadSignature;
      Reader.ReadPrefix(Flags, I);
      Reader.ReadStr; { Ignore class name }
      FInitialName := Reader.ReadStr;
    finally
      Reader.Free;
    end;
  finally
    RS.Free;
  end;
end;

function TCreateableForm.Get_SelectedKey: OleVariant;
begin
  Result := VarArrayOf([]);
end;

function TCreateableForm.Get_WindowQuery: IgsQueryList;
begin
  Result := nil;
end;

function TCreateableForm.InitialName: String;
begin
  Result := FInitialName;
end;

procedure TCreateableForm.LoadDesktopSettings;
begin
  if Assigned(DesktopManager) then
    DesktopManager.LoadDesktopItem(Self);
end;

procedure TCreateableForm.Loaded;
var
  FDC: THandle;
  L, MaxHeight, MinTop, MinLeft, DRight: Integer;
  ShellTrayWND: HWND;
  TrayWNDRect: TRect;
begin

  if not ([cfsUserCreated] * Self.CreateableFormState = [cfsUserCreated]) then
  begin
    if Assigned(FResizer) and Assigned(IBLogin) and IBLogin.LoggedIn then
      FResizer.ReloadComponent(False);
  end;

  FDC := GETDC(Self.Handle);
  try
    inherited;
    OldCreateOrder := False;
  finally
    ReleaseDC(Self.Handle, FDC);
  end;

  if Assigned(Application.MainForm)
    and (Position = Forms.poDesigned)
    and (BorderStyle = Forms.bsSizeable)
    and (Self.ClassName <> 'Tgdc_frmExplorer')
    and (not(cfsDesigning in CreateableFormState)) then
  begin
    if Assigned(UserStorage)
      and UserStorage.ReadBoolean('Options', 'Magic', True, False)
      and (GetAsyncKeyState(VK_CONTROL) shr 1 = 0) then
    begin
      PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    end else begin
      ShellTrayWND := FindWindow('Shell_TrayWnd', nil);
      MinTop := 50;
      MinLeft := 50;
      DRight := Screen.DesktopWidth - 50;
      if ShellTrayWND <> 0 then
      begin
        GetWindowRect(ShellTrayWND, TrayWNDRect);
        if (TrayWNDRect.Left < 10) and (TrayWNDRect.Top < 10) then
        begin
          if TrayWNDRect.Right < TrayWNDRect.Bottom then
          begin
            MinTop := 50;
            MinLeft := TrayWNDRect.Right + 50;
          end else
            begin
              MinTop := TrayWNDRect.Bottom + 50;
              MinLeft := 50;
            end;

        end;
        if TrayWNDRect.Left > 10 then
          DRight := TrayWNDRect.Left - 50;
      end;

      if FormAssigned(gdc_frmExplorer) and (gdc_frmExplorer.Left < MinLeft) then
        L := gdc_frmExplorer.Left + gdc_frmExplorer.Width
      else
        L := 0;

      if L > (Screen.DesktopWidth / 2) then
        Left := 0
      else
        Left := L;

      if Application.MainForm.Top < MinTop then
        Top := Application.MainForm.Top + Application.MainForm.Height
      else
        Top := 0;

      if ShellTrayWND <> 0 then
      begin
        if (TrayWNDRect.Left < 10) and (TrayWNDRect.Top > 10) then
        begin
          Height := TrayWNDRect.Top - Top;
          Width := Screen.DesktopWidth - Left;
        end else
          if (TrayWNDRect.Left > 10) and (TrayWNDRect.Top < 10) then
          begin
            Width := TrayWNDRect.Left - Left;
            Height := Screen.DesktopHeight - Top;
          end else
            if (TrayWNDRect.Left < 10) and (TrayWNDRect.Top < 10) then
            begin
              if TrayWNDRect.Right < TrayWNDRect.Bottom then
              begin
                if Left < TrayWNDRect.Right then Left := TrayWNDRect.Right;
              end else
                begin
                  if Top < TrayWNDRect.Bottom then Top := TrayWNDRect.Bottom;
                end;
              Width := Screen.DesktopWidth - Left;
              Height := Screen.DesktopHeight - Top;
            end;
      end else
        begin
          MaxHeight := Screen.DesktopHeight - Top - 26;
          if FormAssigned(gdc_frmExplorer) then
          begin
            Height := gdc_frmExplorer.Top + gdc_frmExplorer.Height - Top;
            if Height > MaxHeight then
              Height := MaxHeight;
          end else
            Height := MaxHeight;
          Width := Screen.DesktopWidth - Left;
        end;
      if FormAssigned(gdc_frmExplorer) and
        ((gdc_frmExplorer.Left + gdc_frmExplorer.Width) > DRight) and
        ((gdc_frmExplorer.Left + gdc_frmExplorer.Width) < Left)
//        ((gdc_frmExplorer.Left + gdc_frmExplorer.Width) > (Screen.DesktopWidth - DRight))
      then
        Width := gdc_frmExplorer.Left - Left;
    end;
  end;
end;

procedure TCreateableForm.LoadSettings;
var
  S: String;
begin
  if Assigned(UserStorage) and (BorderStyle = bsSizeable) then
  begin
    S := BuildComponentPath(Self);

    Height := UserStorage.ReadInteger(S, 'Height', Height, False);
    Top := UserStorage.ReadInteger(S, 'Top', Top, False);
    Left := UserStorage.ReadInteger(S, 'Left', Left, False);
    Width := UserStorage.ReadInteger(S, 'Width', Width, False);
    WindowState :=
      TWindowState(UserStorage.ReadInteger(S, 'WS', Integer(WindowState), False));
  end;
end;

procedure TCreateableForm.LoadSettingsAfterCreate;
begin
  //
end;

procedure TCreateableForm.ResizerOnActivate(var Activate: Boolean);
{$IFDEF DEPARTMENT}
var
  S: String;
{$ENDIF}
begin
  if FUseDesigner and Assigned(IBLogin) and IBlogin.Database.Connected then
  begin
    if Assigned(GlobalStorage) then
    begin
      Activate := (GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False) and IBLogin.InGroup) <> 0;

      if not Activate then
      begin
        MessageBox(Handle,
          'Изменение формы запрещено текущими настройками политики безопасности.',
          'Отказано в доступе',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
      end;
    end;

    {$IFDEF DEPARTMENT}
    if Activate then
    begin
      Activate := False;
      if InputPassword('', 'Введите пароль для редактирования формы', S) then
      begin
        if S = 'masterkey' then
          Activate := True
        else
          MessageBox(Self.Handle ,'Неверный пароль', 'Ошибка', MB_OK);
      end;
    end;
    {$ENDIF}
  end
  else
    Activate := False;

  if Activate
    and (not IBLogin.IsIBUserAdmin)
    and Assigned(UserStorage)
    and UserStorage.ReadBoolean('Options\Confirmations', 'Form', True) then
  begin
    UserStorage.WriteBoolean('Options\Confirmations', 'Form',
      (MessageBox(Handle,
        'Изменения формы будут сохранены для текущего пользователя.'#13#10 +
        'Если Вы хотите, чтобы изменения были видны всем пользователям,'#13#10 +
        'то необходимо войти в систему под учетной записью Администратора.'#13#10#13#10 +
        'Показывать это предупреждение в дальнейшем?'#13#10, 
        'Внимание',
        MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDYES));
  end;

  FResizerActivated := Activate;

  if Activate then
  begin
    if Assigned(DesktopManager) then
      DesktopManager.RemoveDeskTopItem(Self);
  end;
end;

procedure TCreateableForm.SaveDesktopSettings;
begin
  if Assigned(DesktopManager) then
  begin
    if ResizerActivated then
      DesktopManager.RemoveDesktopItem(Self)
    else if FInitializedCarefully then
      DesktopManager.SaveDesktopItem(Self);
  end;
end;

procedure TCreateableForm.SaveSettings;
var
  S: String;
begin
  if Assigned(UserStorage) and (BorderStyle = bsSizeable) then
  begin
    S := BuildComponentPath(Self);
    UserStorage.WriteInteger(S, 'Height', Height);
    UserStorage.WriteInteger(S, 'Top', Top);
    UserStorage.WriteInteger(S, 'Left', Left);
    UserStorage.WriteInteger(S, 'Width', Width);
    UserStorage.WriteInteger(S, 'WS', Integer(WindowState));
  end;
end;                                                                

procedure TCreateableForm.SetName(const NewName: TComponentName);
begin
  Assert(NewName <> '');
//  Assert(FInitialName = '');

  { TODO : зачем вторая проверка?? }
  if (cfsUserCreated in CreateableFormState) and (FInitialName = '') then
    FInitialName := NewName;

  inherited;
end;

procedure TCreateableForm.Setup(AnObject: TObject);
begin
  //
end;

// Внимание! Этот метод взят из борландовских исходников
// Единственное, что мы исправили, это поставили установку
// флага, если вызов ивента прошел удачно.
// Возможно в следующих версиях метод будет выглядеть по
// другому.
{$IFNDEF VER130}
...
{$ENDIF}


function TCreateableForm.ShowModal: Integer;
begin
  if Assigned(EventControl) and
    (Self <> EventControl.GetProperty) then
    EventControl.DisableProperty;

  Result := inherited ShowModal;
end;


procedure TCreateableForm.WMSizing(var Message: TMessage);
var
  I: Integer;
  RCurr, R, RAbove: TRect;
  RNew: PRect;
  WndCurr, WndAbove: THandle;
begin
  if (not (cfsDesigning in FCreateableFormState))
    and (not (fsModal in FormState))
    and (not (fsCreating in FormState))
    and (BorderStyle = bsSizeable)
    and (Self <> Application.MainForm)
    and Assigned(UserStorage)
    and UserStorage.ReadBoolean('Options', 'Magic', True, False)
    and (GetAsyncKeyState(VK_CONTROL) shr 1 = 0) then
  begin
    GetWindowRect(Self.Handle, RCurr);
    RNew := PRect(Message.LParam);

    with Screen do
    begin
      for I := 0 to FormCount do
        if (I = FormCount) or ((Forms[I] <> Self)
          and (Forms[I].Visible) and Forms[I].Floating) then
        begin
          if I = FormCount then
            SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0)
          else begin
            GetWindowRect(Forms[I].Handle, R);

            WndCurr := Forms[I].Handle;
            WndAbove := GetNextWindow(WndCurr, GW_HWNDPREV);
            while (WndAbove <> 0) and (WndAbove <> Self.Handle) do
            begin
              GetWindowRect(WndAbove, RAbove);
              if (RAbove.Left < R.Right)
                and (RAbove.Right > R.Left)
                and (RAbove.Top < R.Bottom)
                and (RAbove.Bottom > R.Top) then
              begin
                WndCurr := 0;
                break;
              end;
              WndAbove := GetNextWindow(WndAbove, GW_HWNDPREV);
            end;

            if WndCurr = 0 then
              continue;
          end;

          if (RCurr.Right <> RNew.Right) then
          begin
            if (Abs(RNew.Right - R.Left) < Treshold) then
            begin
              RNew.Right := R.Left;
              break;
            end
            else if (Abs(RNew.Right - R.Right) < Treshold) then
            begin
              RNew.Right := R.Right;
              break;
            end;
          end;

          if (RCurr.Left <> RNew.Left) then
          begin
            if (Abs(RNew.Left - R.Right) < Treshold) then
            begin
              RNew.Left := R.Right;
              break;
            end
            else if (Abs(RNew.Left - R.Left) < Treshold) then
            begin
              RNew.Left := R.Left;
              break;
            end;
          end;

          if (RCurr.Top <> RNew.Top) then
          begin
            if (Abs(RNew.Top - R.Bottom) < Treshold) then
            begin
              RNew.Top := R.Bottom;
              break;
            end
            else if (Abs(RNew.Top - R.Top) < Treshold) then
            begin
              RNew.Top := R.Top;
              break;
            end;
          end;

          if (RCurr.Bottom <> RNew.Bottom) then
          begin
            if (Abs(RNew.Bottom - R.Top) < Treshold) then
            begin
              RNew.Bottom := R.Top;
              break;
            end
            else if (Abs(RNew.Bottom - R.Bottom) < Treshold) then
            begin
              RNew.Bottom := R.Bottom;
              break;
            end;
          end;
        end;
    end;
  end;
  inherited;
end;

procedure TCreateableForm.WMMoving(var Message: TMessage);

  procedure MoveCursor(DX, DY: Integer);
  var
    Pt: TPoint;
  begin
    GetCursorPos(Pt);
    SetCursorPos(Pt.X + DX, Pt.Y + DY);
  end;

const
  TC: LongWord = 0;
  RCurr: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
  Pt: TPoint = (X: 0; Y: 0);
  TC1: LongWord = 0;
  TC2: LongWord = 0;
  TC3: LongWord = 0;
  TC4: LongWord = 0;
var
  I, W, H: Integer;
  R, RDesk, RAbove: TRect;
  RNew: PRect;
  WndCurr, WndAbove: THandle;
begin
  if (not (cfsDesigning in FCreateableFormState))
    and (not (fsModal in FormState))
    and (not (fsCreating in FormState))
    and (BorderStyle = bsSizeable)
    and (Self <> Application.MainForm)
    and Assigned(UserStorage)
    and UserStorage.ReadBoolean('Options', 'Magic', True, False)
    and (GetAsyncKeyState(VK_CONTROL) shr 1 = 0) then
  begin
    RNew := PRect(Message.LParam);

    if (GetTickCount - TC) < 400 then
    begin
      Move(RCurr, RNew^, SizeOf(RCurr));
      SetCursorPos(Pt.X, Pt.Y);
      Message.Result := 1;
      exit;
    end;

    GetWindowRect(Self.Handle, RCurr);
    W := RCurr.Right - RCurr.Left;
    H := RCurr.Bottom - RCurr.Top;
    SystemParametersInfo(SPI_GETWORKAREA, 0, @RDesk, 0);

    with Screen do
    begin
      for I := 0 to FormCount do
        if (I = FormCount) or ((Forms[I] <> Self)
          and Forms[I].Visible and Forms[I].Floating) then
        begin
          if I = FormCount then
          begin
            SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
          end else begin
            WndCurr := Forms[I].Handle;
            GetWindowRect(WndCurr, R);

            WndAbove := GetNextWindow(WndCurr, GW_HWNDPREV);
            while (WndAbove <> 0) and (WndAbove <> Self.Handle) do
            begin
              GetWindowRect(WndAbove, RAbove);
              if (RAbove.Left < R.Right)
                and (RAbove.Right > R.Left)
                and (RAbove.Top < R.Bottom)
                and (RAbove.Bottom > R.Top) then
              begin
                WndCurr := 0;
                break;
              end;
              WndAbove := GetNextWindow(WndAbove, GW_HWNDPREV);
            end;

            if WndCurr = 0 then
              continue;
          end;

          if (RCurr.Right < RNew.Right) then
          begin
            if ((RNew.Right - R.Left) > -Treshold)
              and ((RNew.Right - R.Left) <= 0) then
            begin
              MoveCursor(R.Left - RNew.Right, 0);
              RNew.Right := R.Left;
              RNew.Left := RNew.Right - W;
              TC := GetTickCount;
              break;
            end
            else if ((RNew.Right - R.Right) > -Treshold)
              and ((RNew.Right - R.Right) <= 0) then
            begin
              MoveCursor(R.Right - RNew.Right, 0);
              RNew.Right := R.Right;
              RNew.Left := RNew.Right - W;
              TC := GetTickCount;
              break;
            end;
          end;

          if (RCurr.Left > RNew.Left) then
          begin
            if ((RNew.Left - R.Right) < Treshold)
              and ((RNew.Left - R.Right) > 0) then
            begin
              MoveCursor(-(RNew.Left - R.Right), 0);
              RNew.Left := R.Right;
              RNew.Right := RNew.Left + W;
              TC := GetTickCount;
              break;
            end
            else if ((RNew.Left - R.Left) < Treshold)
              and ((RNew.Left - R.Left) > 0) then
            begin
              MoveCursor(-(RNew.Left - R.Left), 0);
              RNew.Left := R.Left;
              RNew.Right := RNew.Left + W;
              TC := GetTickCount;
              break;
            end
          end;

          if (RCurr.Top > RNew.Top) then
          begin
            if ((RNew.Top - R.Bottom) < Treshold)
              and ((RNew.Top - R.Bottom) > 0) then
            begin
              MoveCursor(0, - (RNew.Top - R.Bottom));
              RNew.Top := R.Bottom;
              RNew.Bottom := RNew.Top + H;
              TC := GetTickCount;
              break;
            end
            else if ((RNew.Top - R.Top) < Treshold)
              and ((RNew.Top - R.Top) > 0) then
            begin
              MoveCursor(0, - (RNew.Top - R.Top));
              RNew.Top := R.Top;
              RNew.Bottom := RNew.Top + H;
              TC := GetTickCount;
              break;
            end
          end;

          if (RCurr.Bottom < RNew.Bottom) then
          begin
            if (RNew.Bottom - R.Top > -Treshold)
              and (RNew.Bottom - R.Top <= 0) then
            begin
              MoveCursor(0, - (RNew.Bottom - R.Top));
              RNew.Bottom := R.Top;
              RNew.Top := RNew.Bottom - H;
              TC := GetTickCount;
              break;
            end
            else if (RNew.Bottom - R.Bottom > -Treshold)
              and (RNew.Bottom - R.Bottom <= 0) then
            begin
              MoveCursor(0, - (RNew.Bottom - R.Bottom));
              RNew.Bottom := R.Bottom;
              RNew.Top := RNew.Bottom - H;
              TC := GetTickCount;
              break;
            end;
          end;
        end;
    end;

    Move(RNew^, RCurr, SizeOf(RCurr));
    GetCursorPos(Pt);
  end;

  inherited;
end;

procedure TCreateableForm.WMSysCommand(var Message: TMessage);
var
  RCurr, RDesk, RMain, R: TRect;
  I: Integer;
begin
  case Message.WParam and $FFF0 of
    SC_MINIMIZE:
      begin
        if (Self <> Application.MainForm)
          and (not (cfsDesigning in FCreateableFormState)) then
        begin
          Message.WParam := (Message.WParam and $000F) or (SC_CLOSE and $FFF0);
        end;
      end;

    SC_MAXIMIZE:
      begin
        if (Self <> Application.MainForm)
          and (not (cfsDesigning in FCreateableFormState))
          {and (Self.ClassName <> 'Tgdc_frmExplorer')}
          and (not (fsModal in Self.FormState))
          and (Self.BorderStyle = bsSizeable)
          and Assigned(UserStorage)
          and UserStorage.ReadBoolean('Options', 'Magic', True, False)
          and (GetAsyncKeyState(VK_CONTROL) shr 1 = 0) then
        begin
          SystemParametersInfo(SPI_GETWORKAREA, 0, @RDesk, 0);
          SystemParametersInfo(SPI_GETWORKAREA, 0, @RCurr, 0);

          if Application.MainForm <> nil then
          begin
            GetWindowRect(Application.MainForm.Handle, RMain);
            if RMain.Top < (RDesk.Bottom div 2) then
            begin
              RCurr.Top := RMain.Bottom;
            end else
            begin
              RCurr.Bottom := RMain.Top;
            end;
          end;

          with Screen do
            for I := 0 to FormCount - 1 do
            begin
              if (Forms[I].Visible) and (Forms[I].ClassName = 'Tgdc_frmExplorer') then
              begin
                GetWindowRect(Forms[I].Handle, R);

                if R.Left < (RDesk.Right div 2) then
                begin
                  RCurr.Left := R.Right;
                end else
                begin
                  RCurr.Right := R.Left
                end;

                if (Application.MainForm <> nil) and (RMain.Bottom < R.Bottom) then
                begin
                  if R.Bottom < RDesk.Bottom then
                    RCurr.Bottom := R.Bottom;
                end;

                break;
              end;
            end;  

           SetBounds(RCurr.Left, RCurr.Top, RCurr.Right - RCurr.Left + 1,
             RCurr.Bottom - RCurr.Top);

          exit;
        end
        {else if (fsModal in Self.FormState)
          and (Self is Tgdc_frmG) then
        begin
          exit;
        end};
      end;
  end;

  inherited;
end;

procedure TCreateableForm.ActionChange(Sender: TObject;
  CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, (csLoading in ComponentState) or CheckDefaults);
end;

procedure TCreateableForm.SetFocusOnComponent(
  const AComponentName: String);
var
  I: Integer;
begin

  for I := 0 to ComponentCount - 1 do
  begin
    if UpperCase(Components[I].Name) = UpperCase(AComponentName) then
    begin
      if Components[I] is TWinControl then
      begin
        TWinControl(Components[I]).Show;
        TWinControl(Components[I]).SetFocus;
        Exit;
      end
    end
  end;
end;

procedure TCreateableForm.Activate;
begin
  if Assigned(_OnActivateForm) and FShowSpeedButton then
    _OnActivateForm(Self);

  inherited;
end;
{ TgdVariables }

procedure TgdVariables.AddVariable(const Name: String);
begin
  inherited AddVariable(Name);
end;

function TgdVariables.GetVariables(Name: String): OleVariant;
begin
  Result := inherited GetVariables(Name);
end;

procedure TgdVariables.SetVariables(Name: String; const Value: OleVariant);
begin
  if VarType(Value) = varDispatch then
    raise Exception.Create('Свойству нельзя присвоить объект.')
  else
    inherited SetVariables(Name, Value);
end;

function TCreateableForm.GetVariables(Name: String): OleVariant;
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  Result := FVariables[Name];
end;

procedure TCreateableForm.SetVariables(Name: String;
  const Value: OleVariant);
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  FVariables[Name] := Value;
end;

procedure TCreateableForm.AddVariableItem(const Name: String);
begin
  if FVariables = nil then
    FVariables := TgdVariables.Create;
  FVariables.AddVariable(Name)
end;

function TCreateableForm.GetObjects(Name: String): IDispatch;
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  Result := FObjects.Objects[Name];
end;

procedure TCreateableForm.SetObjects(Name: String;
  const Value: IDispatch);
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  FObjects.Objects[Name] := Value;
end;

procedure TCreateableForm.AddObjectItem(const Name: String);
begin
  if FObjects = nil then
    FObjects := TgdObjects.Create;
  FObjects.AddObject(Name);
end;

function TgdVariables.VariableExists(Name: String): Boolean;
begin
  Result := Exists(name);
end;

{ TgdObjects }

procedure TgdObjects.AddObject(const Name: String);
begin
  AddVariable(Name);
end;

function TgdObjects.GetObjects(Name: String): IDispatch;
var
  LV: OleVariant;
begin
  Result := nil;
  LV := GetVariables(Name);
  if (VarType(LV) = varDispatch) and (Assigned(IDispatch(LV))) then
    Result := IDispatch(LV);
end;

function TgdObjects.ObjectExists(const Name: String): Boolean;
begin
  Result := Exists(name);
end;

procedure TgdObjects.SetObjects(Name: String; const Value: IDispatch);
begin
  SetVariables(Name, Value);
end;

{ TgdCustomVariables }

procedure TgdCustomVariables.AddVariable(const Name: String);
begin
  if FStrings.IndexOf(Name) = -1 then
    FStrings.Add(Name)
  else
    raise Exception.Create('В списке уже существует элемент с именем "' + Name + '"');
end;

procedure TgdCustomVariables.Clear;
var
  I: Integer;
  P: POleVariant;
begin
  for I := FStrings.Count - 1 downto 0 do
  begin
    P := POleVariant(FStrings.Objects[I]);
    FStrings.Delete(I);
    if P <> nil then
      Dispose(P);
  end;
  FStrings.Clear;
end;

constructor TgdCustomVariables.Create;
begin
  FStrings := TStringList.Create;
  FStrings.Sorted := True;
  FStrings.Duplicates := dupError;
end;

destructor TgdCustomVariables.Destroy;
begin
  Clear;
  FStrings.Free;
  inherited;
end;

function TgdCustomVariables.GetVariables(Name: String): OleVariant;
var
  P: POleVariant;
  I: Integer;
begin
  Result := Unassigned;
  I := FStrings.IndexOf(Name);
  if I <> -1 then
  begin
    P := POleVariant(FStrings.Objects[I]);
    if P <> nil then
      Result := P^;
  end else
    raise Exception.Create('В списке не найден элемент с именем ' + Name);
end;

procedure TgdCustomVariables.SetVariables(Name: String;
  const Value: OleVariant);
var
  I: Integer;
  P: POleVariant;
begin
  I := FStrings.IndexOf(Name);

  if I = -1 then
    raise Exception.Create('В списке не найден элемент с именем ' + Name)
  else
    begin
      P := POleVariant(FStrings.Objects[I]);
      if P <> nil then
        Dispose(P);
    end;

  New(P);
  P^ := Value;
  FStrings.Objects[I] := TObject(P);
end;

function TCreateableForm.GetShowSpeedButton: Boolean;
begin
  Result := FShowSpeedButton;
end;

procedure TCreateableForm.SetShowSpeedButton(const Value: Boolean);
begin
  if FShowSpeedButton <> Value then
  begin
    FShowSpeedButton := Value;
    if Assigned(_OnCreateForm) and FShowSpeedButton then
      _OnCreateForm(Self)
    else if Assigned(_OnDestroyForm) and (not FShowSpeedButton) then
      _OnDestroyForm(Self)
  end;
end;

function TCreateableForm.GetText: TCaption;
begin
  Result := inherited Caption;
end;

function TCreateableForm.IsCaptionStored: Boolean;
begin
  Result := (ActionLink = nil) or not TCrackControlActionLink(ActionLink).IsCaptionLinked;
end;

procedure TCreateableForm.SetText(const Value: TCaption);
begin
  inherited Caption := Value;
  if Assigned(_OnCaptionChange) then
    _OnCaptionChange(Self);
end;

procedure TCreateableForm.WMClose(var Message: TMessage);
begin
  FShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  inherited;
end;

procedure TCreateableForm.DoClose(var Action: TCloseAction);
begin
  inherited;
  { TODO -oЮлия : Зачем здесь такая проверка? }
  if not Assigned(OnClose) then
  begin
    if (Action = caHide) and FShiftDown and (not(fsModal in FormState)) then
      Action := caFree;
  end;
end;

function TgdCustomVariables.Exists(Name: String): Boolean;
begin
  if FStrings.IndexOf(Name) > -1 then
    Result := True
  else
    Result := False;
end;

function TCreateableForm.ObjectExists(const Name: String): Boolean;
begin
  Result := (FObjects <> nil) and FObjects.ObjectExists(Name);
end;

function TCreateableForm.VariableExists(const Name: String): Boolean;
begin
  Result := (FVariables <> nil) and FVariables.VariableExists(Name);
end;

procedure TCreateableForm.SaveSettingsEvent(Sender: TObject);
begin
  SaveSettings;
end;

procedure TCreateableForm.LoadSettingsAfterCreateEvent(Sender: TObject);
begin
  LoadSettingsAfterCreate;
end;

procedure TCreateableForm.AfterConstruction;
begin
  FOnSaveSettings := SaveSettingsEvent;
  FOnLoadSettingsAfterCreate := LoadSettingsAfterCreateEvent;
  inherited;

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TCreateableForm.UpdateActions;
{var
  T: DWORD;}
begin
  {if Active and (IBLogin <> nil) and (IBLogin.IsIBUserAdmin) then
  begin
    T := GetTickCount;
    inherited;
    if GetTickCount - T > 16 then
    begin
      if not FAUTimerInitialized then
        FAUTimerInitialized := True
      else
        if GetTickCount - FOldTickCount > 60000 then
        begin
          MessageBox(Handle,
            PChar('Слишком длительное выполнение (' + IntToStr(GetTickCount - T) + ' ms) ' +
            'обработчиков событий'#13#10 +
            'OnUpdate у компонентов TAction на форме ' + Name + '.'#13#10#13#10 +
            'Убедитесь, что внутри обработчиков нет обращений к базе данных,'#13#10 +
            'файлам и/или громоздких вычислений.'),
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          FOldTickCount := GetTickCount;
        end;
    end;
  end else}
    inherited;
end;

function TCreateableForm.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
const
  TCreateableFormGUID: TGUID = '{F76E3058-A481-4966-9DAC-337F25CD2E97}';
begin
  Result := HandleSafeCallException(ExceptObject, ExceptAddr, TCreateableFormGUID,
    String(ExceptObject.ClassName), '');
end;

initialization
  FormsList := TObjectList.Create(False);

  _OnCreateForm := nil;
  _OnDestroyForm := nil;
  _OnActivateForm := nil;
  _OnCaptionChange := nil;

finalization
  FreeAndNil(FormsList);
end.

