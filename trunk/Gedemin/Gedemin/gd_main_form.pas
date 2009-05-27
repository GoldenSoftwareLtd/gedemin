
unit gd_main_form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ToolWin, ComCtrls, IBDatabase, dmDatabase_unit, gd_security,
  IBSQL, ActnList, Menus, gsDesktopManager,  StdCtrls,
  dmImages_unit, gd_security_OperationConst, {gsTrayIcon,}
  AppEvnts, Db, IBCustomDataSet, IBServices, gdHelp_Body,
  gd_createable_form, TB2Item, TB2Dock, TB2Toolbar, IBQuery,
  gsIBLookupComboBox;

const
  WM_ACTIVATESETTING = WM_USER + 30000;


type
  TCrackIBCustomDataset = class(TIBCustomDataset);

  TfrmGedeminMain = class(TCreateableForm, ICompanyChangeNotify, IConnectChangeNotify)
    ActionList: TActionList;
    actExit: TAction;
    actAbout: TAction;
    actExplorer: TAction;
    actSaveDesktop: TAction;
    actDeleteDesktop: TAction;
    actShow: TAction;
    actActiveFormList: TAction;
    actClear: TAction;
    actLogIn: TAction;
    actLogOff: TAction;
    actLoginSingle: TAction;
    actBringOnline: TAction;
    actBackup: TAction;
    actRestore: TAction;
    actShowUsers: TAction;
    TBDockMain: TTBDock;
    tbMainMenu: TTBToolbar;
    tbsiHelp: TTBSubmenuItem;
    tbsiDatabase: TTBSubmenuItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem7: TTBItem;
    TBItem8: TTBItem;
    N25: TTBItem;
    N26: TTBItem;
    N24: TTBSeparatorItem;
    N14: TTBItem;
    MenuItem1: TTBItem;
    N15: TTBItem;
    N23: TTBSeparatorItem;
    N18: TTBItem;
    N19: TTBItem;
    N20: TTBSeparatorItem;
    actBackup1: TTBItem;
    N22: TTBItem;
    N2: TTBItem;
    Property1: TTBItem;
    TBDockForms: TTBDock;
    tbForms: TTBToolbar;
    TBControlItem2: TTBControlItem;
    tcForms: TTabControl;
    actEditForm: TAction;
    TBSeparatorItem6: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    cbDesktop: TComboBox;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem14: TTBItem;
    TBItem15: TTBItem;
    TBItem2: TTBItem;
    actShowSQLObjects: TAction;
    TBItem9: TTBItem;
    actProperty: TAction;
    actOptions: TAction;
    tbiOptions: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    tbiScanTemplate: TTBItem;
    actScanTemplate: TAction;
    TBControlItem3: TTBControlItem;
    Label1: TLabel;
    TBSeparatorItem4: TTBSeparatorItem;
    gsiblkupCompany: TgsIBLookupComboBox;
    TBControlItem4: TTBControlItem;
    IBTransaction: TIBTransaction;
    TBControlItem5: TTBControlItem;
    Label2: TLabel;
    tbsiWindow: TTBSubmenuItem;
    tbsiMacro: TTBSubmenuItem;
    TBItem10: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem5: TTBItem;
    TBItem11: TTBItem;
    TBItem12: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem13: TTBItem;
    TBItem16: TTBItem;
    TBItem18: TTBItem;
    TBItem19: TTBItem;
    TBSeparatorItem10: TTBSeparatorItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBItem21: TTBItem;
    actSQLEditor: TAction;
    pmForms: TPopupMenu;
    actCloseForm: TAction;
    actHideForm: TAction;
    actHideAll: TAction;
    actCloseForm1: TMenuItem;
    N1: TMenuItem;
    N3: TMenuItem;
    actCloseAll: TAction;
    N4: TMenuItem;
    N5: TMenuItem;
    tbiWorkingCompaniesBtn: TTBItem;
    actWorkingCompanies: TAction;
    actHelp: TAction;
    actLoadPackage: TAction;
    TBItem22: TTBItem;
    TBSeparatorItem12: TTBSeparatorItem;
    tbiCloseAll: TTBItem;
    actRegistration: TAction;
    tbiRegistration: TTBItem;
    actRecompileStatistics: TAction;
    tbiRecompile: TTBItem;
    TBSeparatorItem8888: TTBSeparatorItem;
    actSQLMonitor: TAction;
    TBItem1: TTBItem;
    TBControlItem6: TTBControlItem;
    lblDatabase: TLabel;
    TBSeparatorItem8: TTBSeparatorItem;
    pmlblDataBase: TPopupMenu;
    actCopy: TAction;
    N6: TMenuItem;
    actCompareDataBases: TAction;
    TBItem17: TTBItem;
    TBSeparatorItem13: TTBSeparatorItem;
    actShell: TAction;
    TBItem20: TTBItem;
    actStreamSaverOptions: TAction;
    tbiStreamSaverOptions: TTBItem;
    actShowMonitoring: TAction;
    TBItem23: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actExplorerExecute(Sender: TObject);
    procedure actExplorerUpdate(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actSaveDesktopExecute(Sender: TObject);
    procedure cbDesktopChange(Sender: TObject);
    procedure actDeleteDesktopExecute(Sender: TObject);
    function gsDesktopManagerDesktopItemCreate(Sender: TObject;
      const AnItemClass, AnItemName: String): TComponent;
    procedure actShowExecute(Sender: TObject);
    procedure actShowUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actExitUpdate(Sender: TObject);
    procedure actActiveFormListExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actLogInExecute(Sender: TObject);
    procedure actLogOffExecute(Sender: TObject);
    procedure actLogInUpdate(Sender: TObject);
    procedure actLogOffUpdate(Sender: TObject);
    procedure actLoginSingleExecute(Sender: TObject);
    procedure actBringOnlineExecute(Sender: TObject);
    procedure actLoginSingleUpdate(Sender: TObject);
    procedure actBringOnlineUpdate(Sender: TObject);
    procedure actBackupExecute(Sender: TObject);
    procedure actBackupUpdate(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure actRestoreUpdate(Sender: TObject);
    procedure actShowUsersExecute(Sender: TObject);
    procedure actShowUsersUpdate(Sender: TObject);
    procedure TBItem3Click(Sender: TObject);
    procedure TBItem4Click(Sender: TObject);
    procedure tcFormsChange(Sender: TObject);
    procedure tbFormsResize(Sender: TObject);
    procedure actEditFormExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure actShowSQLObjectsUpdate(Sender: TObject);
    procedure actShowSQLObjectsExecute(Sender: TObject);
    procedure actEditFormUpdate(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actOptionsUpdate(Sender: TObject);
    procedure actSaveDesktopUpdate(Sender: TObject);
    procedure actDeleteDesktopUpdate(Sender: TObject);
    procedure actScanTemplateExecute(Sender: TObject);
    procedure gsiblkupCompanyChange(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure TBItem13Click(Sender: TObject);
    procedure TBItem16Click(Sender: TObject);
    procedure TBItem12Click(Sender: TObject);
    procedure TBItem11Click(Sender: TObject);
    procedure TBItem18Click(Sender: TObject);
    procedure TBItem19Click(Sender: TObject);
    procedure TBItem5Click(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actSQLEditorUpdate(Sender: TObject);
    procedure actCloseFormExecute(Sender: TObject);
    procedure actHideFormExecute(Sender: TObject);
    procedure actHideAllExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure tcFormsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actWorkingCompaniesExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actLoadPackageExecute(Sender: TObject);
    procedure actWorkingCompaniesUpdate(Sender: TObject);
    procedure actLoadPackageUpdate(Sender: TObject);
    procedure actCloseAllUpdate(Sender: TObject);
    procedure actScanTemplateUpdate(Sender: TObject);
    procedure actActiveFormListUpdate(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actHideFormUpdate(Sender: TObject);
    procedure actHideAllUpdate(Sender: TObject);
    procedure actCloseFormUpdate(Sender: TObject);
    procedure actRegistrationExecute(Sender: TObject);
    procedure actRegistrationUpdate(Sender: TObject);
    procedure actRecompileStatisticsExecute(Sender: TObject);
    procedure actRecompileStatisticsUpdate(Sender: TObject);
    procedure actSQLMonitorUpdate(Sender: TObject);
    procedure actSQLMonitorExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCompareDataBasesExecute(Sender: TObject);
    procedure actCompareDataBasesUpdate(Sender: TObject);
    procedure actShellExecute(Sender: TObject);
    procedure actShellUpdate(Sender: TObject);
    procedure actStreamSaverOptionsExecute(Sender: TObject);
    procedure actShowMonitoringExecute(Sender: TObject);
    procedure actShowMonitoringUpdate(Sender: TObject);
    procedure actStreamSaverOptionsUpdate(Sender: TObject);

  private
    FCanClose: Boolean;
    FExitWindowsParam: Longint;
    FExitWindows: Boolean;
    //FIconShown: Boolean;
    FFirstTime: Boolean;

    procedure EnableCategory(Category: String; DoEnable: Boolean);
    {procedure WMSysCommand(var Message: TWMSysCommand);
      message WM_SYSCOMMAND;}

    procedure _DoOnCreateForm(Sender: TObject);
    procedure _DoOnDestroyForm(Sender: TObject);
    procedure _DoOnActivateForm(Sender: TObject);
    procedure _DoOnCaptionChange(Sender: TObject);

    procedure ApplicationEventsShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo);

  protected
    procedure Loaded; override;

    procedure WMQueryEndSession(var Message: TWMQueryEndSession);
      message WM_QUERYENDSESSION;

    procedure DoBeforeChangeCompany;
    procedure DoAfterChangeCompany;

    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;

    procedure Activate; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure DoDestroy; override;

  public
    SettingKey: Integer;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;

  end;


var
  frmGedeminMain: TfrmGedeminMain;

implementation

{$R *.DFM}

uses
  jclBase,
  jclFileUtils,
  jclStrings,
  IBXConst,
  IBIntf,
  ShellAPI,
  gd_frmShell_unit,
  {ZLib,}

  at_frmIBUserList,
  at_SQL_Setup,
  at_classes,
  at_sql_metadata,
  at_frmSQLProcess,
  at_dlgLoadPackages_unit,
//  at_dlgChoosePackage_unit, // delete

  flt_dlgShowFilter_unit,
  gd_resourcestring,

  gd_frmWindowsList_unit,
  gd_directories_const,
  gd_frmBackup_unit,
  gd_frmRestore_unit,
  gd_dlgDeleteDesktop_unit,
  gd_dlgDesktopName_unit,
  gd_dlgAbout_unit,

  gdHelp_Interface,

  {$IFDEF REALIZATION}
  gp_frmContractSelll_unit,
  gp_frmMakeDemand_unit,
  gp_frmReturnBill_unit,
  gp_frmBills_unit,

  tr_frmEntrys_unit,
  tr_frmAccount_unit,
  tr_frmAnalyze_unit,
  tr_frmTransaction_unit,
  {$ENDIF}

  {$IFDEF CURRSELLCONTRACT}
  gdcCurrSellContract,
  {$ENDIF}

  {$IFDEF CATTLE}
  ctl_frmCattlePurchasing_unit,
  ctl_frmClient_unit,
  ctl_frmCattleReceipt_unit,
  ctl_frmReferences_unit,
  ctl_frmCattle_unit,
  ctl_frmTransportCoeff_unit,
  gdcCheckList,
  gdcPayment,
  gdcCurrCommission,
  gp_frmPrice_unit,
  {$ENDIF}

  {$IFDEF PROTECT}
  jclStrings,
  {$ENDIF}

  // Перенести под команды
  gdc_frmExplorer_unit,

  {$IFDEF PROTECT}
  pr_dlgRegNumber_unit,
  pr_dlgLicence_unit,
  {$ENDIF}

{$IFDEF GEDEMIN_LOCK}
  gd_dlgReg_unit,
  gd_registration,
  IBDatabaseInfo,
{$ENDIF}

  gdcGood,
  gdcBase,
  gdcCurr,
  gdcConst,
  gdcAcctEntryRegister,
  gdcJournal,
  gdcStorage,
  gdcFile,

  gdv_frmAcctCirculationList_unit,

  gsStorage_CompPath,
  {$IFDEF DEBUG}
  gdSQLMonitor,
  {$ENDIF}

  {$IFDEF DEPARTMENT}
  gdcDepartament,
  {$ENDIF}

  gdcMetaData,
  gdcSetting,
  gdcAcctAccount,
  gdcAcctTransaction,
  gdcInvDocument_unit,
  gdcInvPriceList_unit,
  gdcInvMovement,
  gdcAttrUserDefined,
  gdcPlace,
  gdcContacts,

  gdcReport,

  gdcUser,

  gdcClasses,

  {Скрипт-функции}
  {prp_dlgViewProperty_unit,} evt_i_Base,

  gdcBugBase,

  gd_ClassList,

  Storages,
  gsStorage,

  rp_report_const,
  gd_SetDatabase,
  gd_i_ScriptFactory,
  ActiveX,
  rp_ReportMainForm_unit,
  {Создание новых форм}
  dlg_NewForm_Wzrd_unit,
  dlg_EditNewForm_unit,

  flt_sqlFilter,

  gd_splash,

  {$IFDEF DEBUG}
  gd_frmShowSQLObjects_unit,
  {$ENDIF}

  flt_frmSQLEditorSyn_unit,

  st_frmMain_unit,

  gd_dlgOptions_unit,

  contnrs,
  gdUpdateIndiceStat,
  IB,
  IBSQLCache,
  tmp_ScanTemplate_unit,
  gd_KeyAssoc,
  mtd_i_Base,
  dm_i_ClientReport_unit,
  gdcBaseInterface, dmLogin_unit,
  {$IFDEF DEBUG}
  gd_frmSQLMonitor_unit,
  {$ENDIF}
  gd_dlgAutoBackup_unit,
  prp_frmGedeminProperty_Unit,
  cmp_frmDataBaseCompare,
  gd_frmMonitoring_unit,
  Clipbrd,
  Registry
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  {$IFDEF NEW_STREAM}
  , gd_dlgStreamSaverOptions
  {$ENDIF}
  ;

type
  TCrackPopupMenu = class(TPopupMenu);

procedure TfrmGedeminMain.FormCreate(Sender: TObject);
{var
  RemotePath, FileName, RemoteFileName, TempFileName: String;
  TempPath: array[0..256] of char;
  SearchR: TSearchRec;}
begin
  if Assigned(IBLogin) then
  begin
    // раз иблогин был создан и подключен к базе
    // до главной формы -- они никак не могла участвовать
    // в подписке, поэтому вызовем соответствующие методы
    // вручную
    if IBLogin.LoggedIn then
    begin
      DoAfterSuccessfullConnection;
      DoAfterChangeCompany;
    end;  

    IBLogin.AddConnectNotify(Self);
    IBLogin.AddCompanyNotify(Self);
  end;
                                               
  /////////////////////////////////////////////////////////////////////////////
  // live updates
  // пры кожнай загрузцы мы глядзім у сховішча і, калі жывыя аднаўленьні
  // ўключаны і вэрсія файла на сэрвере большая за нашую, тады капіруем
  // файл сабе на кампутар і пры наступнай перазагрузцы замяняем яго.
  //
  {if GlobalStorage.ReadBoolean(st_lu_OptionsPath, st_lu_Enabled, True) then
  begin
    FileName := ExtractFileName(Application.EXEName);
    RemotePath := GlobalStorage.ReadString(st_lu_OptionsPath, st_lu_Server);
    RemoteFileName := IncludeTrailingBackslash(RemotePath) + FileName;

    if (RemotePath > '') and FileExists(RemoteFileName)
      and (VersionResourceAvailable(Application.EXEName)) and () then
    begin
    end;


    if VersionResourceAvailable(Application.EXEName) then
      with TjclFileVersionInfo.Create(Application.EXEName) do
      try
        if FileVersion < GlobalStorage.ReadString(st_lu_OptionsPath, st_lu_Version) then
        begin
          FileName := ExtractFileName(Application.EXEName);
          RemotePath := GlobalStorage.ReadString(st_lu_OptionsPath, st_lu_Server);
          RemoteFileName := IncludeTrailingBackslash(RemotePath) + FileName;
          if (RemotePath > '') and FileExists(RemoteFileName) and
            (MessageBox(0,
              'Обнаружена новая версия файла. Произвести обновление?',
              'Внимание',
              MB_ICONQUESTION or MB_YESNO) = IDYES)
            then
          begin
            TempFileName := Application.EXEName + '.TMP';
            if CopyFile(PChar(RemoteFileName), PChar(TempFileName), False) then
            begin
              MoveFileEx(PChar(TempFileName), PChar(Application.EXEName), MOVEFILE_DELAY_UNTIL_REBOOT or MOVEFILE_REPLACE_EXISTING);
              MessageBox(0,
                'Обновление произойдет при следующей перезагрузке компьютера.',
                'Информация',
                MB_ICONINFORMATION or MB_OK);
            end;
          end;
        end;
      finally
        Free;
      end;
  end;}
end;

procedure TfrmGedeminMain.actExplorerExecute(Sender: TObject);
begin
  Tgdc_frmExplorer.CreateAndAssign(Application);

  if (not gdc_frmExplorer.Visible) and (not (fsShowing in gdc_frmExplorer.FormState)) then
    gdc_frmExplorer.Show;

  if gdc_frmExplorer.Visible then
    gdc_frmExplorer.SetFocus;
end;

procedure TfrmGedeminMain.actExplorerUpdate(Sender: TObject);
begin
  actExplorer.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn
    {and gdcBaseManager.Class_TestUserRights(TgdcExplorer, '', 0)};
  actExplorer.Checked := FormAssigned(gdc_frmExplorer) and (gdc_frmExplorer.Visible);
end;

procedure TfrmGedeminMain.actExitExecute(Sender: TObject);
begin
  FCanClose := True;
  Close;
  if FExitWindows then
    ExitWindowsEx(FExitWindowsParam, 0);
end;

procedure TfrmGedeminMain.actSaveDesktopExecute(Sender: TObject);
begin
  if Assigned(DesktopManager) then
    with Tgd_dlgDesktopName.Create(Self) do
    try
      if ShowModal = mrOk then
      begin
        DesktopManager.WriteDesktopData(cb.Text, True);
        DesktopManager.InitComboBox(cbDesktop);
      end;
    finally
      Free;
    end;
end;

procedure TfrmGedeminMain.cbDesktopChange(Sender: TObject);
begin
  {if cbDesktop.Text = DesktopManager.CurrentDesktopName then
    DesktopManager.LoadDesktop
  else}

  {
  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    raise Exception.Create('Изменение рабочего стола запрещено текущими настройками политики безопасности.');
  end;
  }

  if DesktopManager.ReadDesktopData(cbDesktop.Text) then
  begin
    DesktopManager.LoadDesktop;
    DesktopManager.SetDefaultDesktop(cbDesktop.Text);
  end;
end;

procedure TfrmGedeminMain.actDeleteDesktopExecute(Sender: TObject);
begin
  with Tgd_dlgDeleteDesktop.Create(Self) do
  try
    ShowModal;
    DesktopManager.InitComboBox(cbDesktop);
  finally
    Free;
  end;
end;

function TfrmGedeminMain.gsDesktopManagerDesktopItemCreate(Sender: TObject;
  const AnItemClass, AnItemName: String): TComponent;
begin
  Result := nil;

  if (AnItemClass = 'Tgdc_frmExplorer') and (AnItemName = 'gdc_frmExplorer') then
  begin
    Result := Tgdc_frmExplorer.CreateAndAssign(Application);
    (Result as TForm).Show;
  end;
end;

procedure TfrmGedeminMain.actShowExecute(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_RESTORE);
  SetForegroundWindow(Application.Handle);
end;

procedure TfrmGedeminMain.actShowUpdate(Sender: TObject);
begin
  actShow.Enabled :=
    (not IsWindowVisible(Application.Handle)) and
    ((not Assigned(Screen.ActiveForm)) or (([fsModal] * Screen.ActiveForm.FormState) = []));
end;

procedure TfrmGedeminMain.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i: Integer;  
begin
  if Assigned(IBLogin) and (IBLogin.Database <> nil)
    and (not IBLogin.Database.TestConnected) then
  begin
    CanClose := True;
    exit;
  end;

  // если архивирование или восстановление базы в самом
  // разгаре, то выходить из программы нельзя
  if (FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
    (FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive) then
  begin
    CanClose := False;
    exit;
  end;

  //Если открыто окно свойств и в нем произведено изменение скриптов то
  //производим запрос на сохранение изменений
  if (EventControl <> nil) and (EventControl.GetProperty <> nil) then
  begin
    CanClose := EventControl.GetProperty.CloseQuery;
    if not CanClose then
      exit;
  end;

  if Assigned(UserStorage) and
    UserStorage.ReadBoolean('Options', 'SaveDesktop', False, False) then
  begin
    DesktopManager.WriteDesktopData(cbDesktop.Text, True);
  end;

  //Уничтожаем все окна, кроме главной, у кот. Owner = Application
  I := 0;
  while I < Screen.FormCount do
  begin
    if (Screen.Forms[I] <> Self) and
      (Screen.Forms[I].Owner = Application) and
      (Screen.Forms[I].InheritsFrom(TCreateableForm)) then
    begin
      Screen.Forms[I].Free;
    end else
      Inc(I);
  end;

//  if Assigned(ScriptFactory) then
//    ScriptFactory.Reset;
  OleUninitialize;
end;

constructor TfrmGedeminMain.Create(AnOwner: TComponent);
begin
  inherited;
  FCanClose := False;
  FExitWindows := False;
  SettingKey := -1;
  FFirstTime := True;

  _OnCreateForm := _DoOnCreateForm;
  _OnDestroyForm := _DoOnDestroyForm;
  _OnActivateForm := _DoOnActivateForm;
  _OnCaptionChange := _DoOnCaptionChange;

  gsStorage_CompPath.MainForm := Self;

  Application.OnShowHint := ApplicationEventsShowHint;
  {$IFNDEF PROTECT}
  TBItem4.Visible := False;
  TBItem3.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  gsStorage_CompPath.MainForm := nil;
  FExitWindows := True;
  FExitWindowsParam := Message.Unused;
  actExit.Execute;
  inherited;
end;

procedure TfrmGedeminMain.actExitUpdate(Sender: TObject);
begin
  actExit.Enabled :=
    (not Assigned(Screen.ActiveForm)) or ([fsModal] * Screen.ActiveForm.FormState = []);
end;

(*
procedure TfrmGedeminMain.IBEventsEventAlert(Sender: TObject;
  EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
begin
  CancelAlerts := True;
  if EventName = 'CloseGedemin' then
  begin
    Application.Terminate;
  end;
end;
*)

procedure TfrmGedeminMain.DoAfterChangeCompany;
begin
  //
  //  Загружаем рабочий стол

  EnableCategory('Tray', True);
  EnableCategory('Документ', True);
  EnableCategory('Просмотр', True);

  if gdc_frmExplorer = nil then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sLoadingExplorer);

    Tgdc_frmExplorer.CreateAndAssign(Application);
  end;

  //cbDesktop.Enabled := True;

  DesktopManager.OnDesktopItemCreate := gsDesktopManagerDesktopItemCreate;
  DesktopManager.ReadDesktopNames;
  if Assigned(UserStorage) and
    UserStorage.ReadBoolean(st_dt_DesktopOptionsPath, st_dt_LoadDesktopOnStartup, True) then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sLoadingDesktop);
    DesktopManager.ReadDesktopData(UserStorage.ReadString(st_dt_DesktopOptionsPath, st_dt_LoadOnStartup, ''));
    DesktopManager.LoadDesktop;
  end;
  DesktopManager.InitComboBox(cbDesktop);

  // кожны раз, як карыстальнік мяняе кампанію
  // трэба сфарміраваць новы кэпшэн

  if Assigned(frmGedeminMain) then
  begin
    {$IFNDEF BMKK}
    Caption := 'Гедымин - ' + IBLogin.CompanyName + ' - ' + IBLogin.UserName;
    {$ENDIF}

    {$IFDEF NOGEDEMIN}
    Caption := IBLogin.CompanyName + ' - ' + IBLogin.UserName;
    tbsiHelp.Enabled:= False;
    tbsiHelp.Visible:= False;
    {$ENDIF}

    {$IFDEF DEBUG}
    Caption := Format('%s, IBX: %s, JCL: %d.%d, ZLIB: %s, Started: %s',
      [Caption, FloatToStr(IBX_Version), JclVersionMajor, JclVersionMinor, {ZLIB_Version}'xxx',
       FormatDateTime('hh:nn', Now)]);
    Caption := Caption + ', ' + 'DEBUG MODE';
    {$ENDIF}

    Application.Title := Caption;

    if (gsiblkupCompany.CurrentKeyInt <> IBLogin.CompanyKey)
      or (gsiblkupCompany.Text <> IBLogin.CompanyName) then
    begin
      gsiblkupCompany.CurrentKeyInt := IBLogin.CompanyKey;
    end;
  end;

  _IBSQLCache.Enabled := True;
end;

procedure TfrmGedeminMain.DoBeforeChangeCompany;
begin
  //
  //  Сварачиваем рабочий стол

  cbDesktop.Items.Clear;
  cbDesktop.Enabled := False;

  if FormAssigned(gdc_frmExplorer) then
    gdc_frmExplorer.Hide;

  EnableCategory('Tray', False);
  EnableCategory('Документ', False);
  EnableCategory('Просмотр', False);
end;

procedure TfrmGedeminMain.DoAfterConnectionLost;
begin
  if FormAssigned(gdc_frmExplorer) then
    FreeAndNil(gdc_frmExplorer);

  EnableCategory('Tray', False);
  EnableCategory('Документ', False);
  EnableCategory('Просмотр', False);

  cbDesktop.Items.Clear;
  cbDesktop.Enabled := False;

  _IBSQLCache.Enabled := False;
end;

procedure TfrmGedeminMain.DoAfterSuccessfullConnection;
var
  TempPath: array[0..256] of char;
  SearchR: TSearchRec;
  S, FN, FE: String;
  Res: OleVariant;
  IBService: TIBBackupService;
  J: DWORD;
begin
  ClearFltComponentCache;

  {Удаляет временные файлы отчетов, которые могли сохраниться на диске
   при неправильном выходе из gedemin-a}

  GetTempPath(sizeof(TempPath), TempPath);
  while FindFirst(StrPas(TempPath) + rpTempPrefix + '*.tmp', faArchive, SearchR) = 0 do
    if not DeleteFile(StrPas(TempPath) + SearchR.Name) then Break;

  // считываем режим отображения наименования полей в выпадающих
  // списках, в фильтрах
  if Assigned(UserStorage) then
  begin
    fltFieldNameMode := TFieldNameMode(
      UserStorage.ReadInteger('Filter', 'FieldNameMode',
        Integer(fnmDuplex), False));
  end;

  {$IFNDEF DEBUG}
  if Assigned(GlobalStorage) and
    GlobalStorage.ReadBoolean('Options', 'AllowAudit', False, False) then
  begin
  {$ENDIF}
    S := 'Application: ' + Application.ExeName + #13#10;
    if VersionResourceAvailable(Application.ExeName) then
      with TjclFileVersionInfo.Create(Application.ExeName) do
      try
        S := S + 'Version: ' + FileVersion + #13#10;
      finally
        Free;
      end;

    GetModuleFileName(GetIBLibraryHandle, TempPath, SizeOf(TempPath));
    if VersionResourceAvailable(TempPath) then
      with TjclFileVersionInfo.Create(TempPath) do
      try
        S := S +
          'Client library: ' + TempPath + #13#10 +
          'CL name: ' + FileDescription + #13#10 +
          'CL version: ' + FileVersion + #13#10;
      finally
        Free;
      end;

    J := MAX_COMPUTERNAME_LENGTH + 1;
    if GetComputerName(@TempPath, J) then
      S := S + 'Computer: ' + StrPas(TempPath) + #13#10;

    J := SizeOf(TempPath);
    if GetUserName(@TempPath, J) then
      S := S + 'User: ' + StrPas(TempPath);

    TgdcJournal.AddEvent(S, 'Log on');
  {$IFNDEF DEBUG}
  end;
  {$ENDIF}

  {$IFDEF DEBUG}
  if Assigned(GlobalStorage)
    and GlobalStorage.ReadBoolean('Options', 'MSQL', False, False) then
  begin
    gdcBaseManager.Database.TraceFlags := IntegerToTraceFlags(
      GlobalStorage.ReadInteger('Options', 'MSQLF', 0, False));
    if gdcBaseManager.Database.TraceFlags <> [] then
    begin
      if SQLMonitor = nil then
        SQLMonitor := TgdSQLMonitor.Create(nil);
    end else
      FreeAndNil(SQLMonitor);
  end;
  {$ELSE}
  gdcBaseManager.Database.TraceFlags := [];
  {$ENDIF}

  if Assigned(GlobalStorage)
    and GlobalStorage.ReadBoolean('Options\Arch', 'Enabled', False, False)
    and (GlobalStorage.ReadInteger('Options\Arch', 'Interval', 7, False) > 0)
    and (GlobalStorage.ReadBoolean('Options\Arch', 'AnyAccount', True, False)
      or (AnsiCompareText(
        GlobalStorage.ReadString('Options\Arch', 'Account', '', False),
        IBLogin.UserName) = 0))
    and ((GlobalStorage.ReadInteger('Options\Arch', 'Interval', 7, False) +
      GlobalStorage.ReadDateTime('Options\Arch', 'Last', 0, False) < Now)
        or (GlobalStorage.ReadDateTime('Options\Arch', 'Last', 0, False) > Now))
    and (GlobalStorage.ReadString('Options\Arch', 'Path', '', False) > '')
    and (GlobalStorage.ReadString('Options\Arch', 'FileName', '', False) > '') then
  begin
    if Assigned(gdSplash) then
      gdSplash.FreeSplash(True);

    GlobalStorage.WriteDateTime('Options\Arch', 'Last', Now);

    gd_dlgAutoBackup := Tgd_dlgAutoBackup.Create(Application);
    try
      try
        gd_dlgAutoBackup.Show;
        Application.ProcessMessages;

        gdcBaseManager.ExecSingleQueryResult(
          'SELECT ibpassword FROM gd_user WHERE ibname=''SYSDBA'' ',
          Unassigned, Res);

        if not VarIsEmpty(Res) then
        begin
          IBService := TIBBackupService.Create(Application);
          try
            IBService.ServerName := IBLogin.ServerName;

            if IBService.ServerName > '' then
              IBService.Protocol := TCP
            else
              IBService.Protocol := Local;

            IBService.LoginPrompt := False;
            IBService.Params.Clear;
            IBService.Params.Add('user_name=' + SysDBAUserName);
            IBService.Params.Add('password=' + Res[0, 0]);
            try
              IBService.Active := True;
              if not IBService.Active then
                MessageBox(gd_dlgAutoBAckup.Handle,
                  'Невозможно запустить сервис архивного копирования/восстановления данных.',
                  'Внимание',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
            except
              IBService.Active := False;
              exit;
            end;

            IBService.Verbose := False;
            IBService.Options := [NoGarbageCollection];
            if IBservice.ServerName > '' then
              IBService.DatabaseName := StringReplace(IBLogin.DatabaseName,
                IBLogin.ServerName + ':', '', [rfIgnoreCase])
            else
              IBService.DatabaseName := IBLogin.DatabaseName;

            FN := GlobalStorage.ReadString('Options\Arch', 'FileName', '', False);
            if not GlobalStorage.ReadBoolean('Options\Arch', 'OneFile', True, False) then
            begin
              FE := ExtractFileExt(FN);
              SetLength(FN, Length(FN) - Length(FE));
              FN := FN + FormatDateTime('yyyymmdd', Now);
              if FE > '.' then
                FN := FN + FE;
            end;

            IBService.BackupFile.Clear;
            IBService.BackupFile.Add(
              IncludeTrailingBackSlash(GlobalStorage.ReadString(
                'Options\Arch', 'Path', '', False)) + FN);

            try
              IBService.ServiceStart;
              while (not IBService.Eof)
                and (IBService.IsServiceRunning) do
              begin
                IBService.GetNextLine;
              end;

              IBService.Active := False;

              MessageBox(gd_dlgAutoBAckup.Handle,
                'Архивное копирование успешно завершено.',
                'Внимание',
                MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

              if GlobalStorage.ReadBoolean('Options\Arch', 'Copy', True, False) then
              begin
                MessageBox(gd_dlgAutoBAckup.Handle,
                  PChar(
                  'Не забудьте скопировать архивный файл на съемный носитель'#13#10 +
                  'данных и хранить его в надежном месте. Сделайте это прямо сейчас.'#13#10 +
                  'Архивный файл находится на компьютере: ' + IBLogin.ServerName + '.'#13#10 +
                  'Имя файла: ' + IBService.BackupFile[0]),
                  'Внимание',
                  MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
              end;
            except
              on E: Exception do
              begin
                MessageBox(gd_dlgAutoBAckup.Handle,
                  PChar('В процессе архивного копирования возникли ошибки.'#13#10#13#10 +
                  E.Message),
                  'Внимание',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
              end;
            end;

          finally
            IBService.Free;
          end;
        end;
      except
        on E: Exception do
        begin
          MessageBox(gd_dlgAutoBAckup.Handle,
            PChar('В процессе архивного копирования возникли ошибки.'#13#10#13#10 +
            E.Message),
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
        end;
      end;
    finally
      gd_dlgAutoBackup.Free;
    end;
  end;

{$IFDEF GEDEMIN_LOCK}
  if IsRegisteredCopy and
    (RegParams.UserCount > 0) then
  begin
    with TIBDatabaseInfo.Create(Application) do
    try
      Database := IBLogin.Database;
      if UserNames.Count > RegParams.UserCount then
      begin
        MessageBox(0,
          'Количество подключенных к базе данных пользователей превышает лимит, установленный Вашей лицензией!' + #13#10 +
          'Обратитесь в компанию ''Золотые программы'' по тел. 292-13-33, 331-35-46!',
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
        Application.Terminate;
      end;
    finally
      Free;
    end
  end;
{$ENDIF}

  if IBLogin.IsUserAdmin then
    lblDatabase.Caption := '  ' + IBLogin.Database.DatabaseName;
end;

procedure TfrmGedeminMain.DoBeforeDisconnect;
var
  I: Integer;
begin
  {$IFNDEF BMKK}
  Caption := 'Гедымин';
  {$ENDIF}

  {$IFDEF NOGEDEMIN}
  Caption := '';
  {$ENDIF}

  {$IFDEF DEPARTMENT}
  Caption := 'Департамент';
  {$ENDIF}

  FFirstTime := True;

  tcForms.Tabs.Clear;

  _IBSQLCache.Enabled := False;

  {$IFDEF DEBUG}
  if SQLMonitor <> nil then
  begin
    SQLMonitor.Flush;
    FreeAndNil(SQLMonitor);
  end;
  {$ENDIF}

  gdcBaseManager.IDCacheFlush;
  ClearLookupCache;

  lblDatabase.Caption := '';

  if Assigned(GlobalStorage) and
    GlobalStorage.ReadBoolean('Options', 'AllowAudit', False, False) then
  begin
    TgdcJournal.AddEvent('', 'Log off');
  end;

  for I := System.ParamCount downto 1 do
  begin
    if AnsiCompareText(System.ParamStr(I), '/rd') = 0 then
    begin
      gdcBaseManager.ExecSingleQuery('SET GENERATOR gd_g_dbid TO 0');
    end;
  end;
end;

procedure TfrmGedeminMain.actActiveFormListExecute(Sender: TObject);
begin
  Tgd_frmWindowsList.CreateAndAssign(Application).Show;
end;

procedure TfrmGedeminMain.actClearExecute(Sender: TObject);
begin
  FreeAllForms(True);
end;

procedure TfrmGedeminMain.EnableCategory(Category: String;
  DoEnable: Boolean);
var
  I: Integer;
  CurrAction: TContainedAction;
begin
  for I := 0 to ActionList.ActionCount - 1 do
  begin
    CurrAction := ActionList.Actions[I];

    if AnsiCompareText(CurrAction.Category, Category) = 0 then
      (CurrAction as TAction).Enabled := DoEnable;
  end;
end;

{
procedure TfrmGedeminMain.actCloseAllGedeminsExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := dmDatabase.ibdbGAdmin;
    q.Transaction := Tr;
    Tr.StartTransaction;
    q.SQL.Text := 'EXECUTE PROCEDURE gd_p_close_gedemin';
    q.ExecQuery;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;
}

procedure TfrmGedeminMain.actLogInExecute(Sender: TObject);
begin
  if not IBLogin.LoggedIn then
    IBLogin.Login(False);
end;

procedure TfrmGedeminMain.actLogOffExecute(Sender: TObject);
begin
  if IBLogin.LoggedIn then
  begin
    Clear_atSQLSetupCache;
    IBLogin.Logoff;
  end;
end;

procedure TfrmGedeminMain.actLogInUpdate(Sender: TObject);
begin
  actLogIn.Enabled := not IBLogin.LoggedIn and not IBLogin.ShutDown;
end;

procedure TfrmGedeminMain.actLogOffUpdate(Sender: TObject);
begin
  actLogOff.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn
    and ((not Assigned(Screen.ActiveForm)) or ([fsModal] * Screen.ActiveForm.FormState = []))
    and (not ((FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
      (FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive)));
end;

procedure TfrmGedeminMain.actLoginSingleExecute(Sender: TObject);
begin
  IBLogin.LoginSingle;
end;

procedure TfrmGedeminMain.actBringOnlineExecute(Sender: TObject);
begin
  IBLogin.BringOnLine;
end;

procedure TfrmGedeminMain.actLoginSingleUpdate(Sender: TObject);
begin
  actLoginSingle.Enabled := (not IBLogin.LoggedIn);
  {$IFDEF DEPARTMENT}
  if not IBLogin.IsUserAdmin then
    actLoginSingle.Visible := False
  else
    actLoginSingle.Visible := True;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actBringOnlineUpdate(Sender: TObject);
begin
  actBringOnline.Enabled := not IBLogin.LoggedIn and IBLogin.ShutDown;
  {$IFDEF DEPARTMENT}
  if not IBLogin.IsUserAdmin then
    actBringOnline.Visible := False
  else
    actBringOnline.Visible := True;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actBackupExecute(Sender: TObject);
begin
  Tgd_frmBackup.CreateAndAssign(Application).Show;
end;

procedure TfrmGedeminMain.actBackupUpdate(Sender: TObject);
begin
  actBackup.Enabled := (not IBLogin.LoggedIn)
    or IBLogin.IsUserAdmin
    or ((IBLogin.InGroup and GD_UG_ARCHIVEOPERATORS) <> 0);
  {$IFDEF DEPARTMENT}
  if not IBLogin.IsUserAdmin then
    actBackup.Visible := False
  else
    actBackup.Visible := True;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actRestoreExecute(Sender: TObject);
begin
  Tgd_frmRestore.CreateAndAssign(Application).Show;
end;

procedure TfrmGedeminMain.actRestoreUpdate(Sender: TObject);
begin
  actRestore.Enabled := (not IBLogin.LoggedIn)
    or IBLogin.IsUserAdmin
    or ((IBLogin.InGroup and GD_UG_ARCHIVEOPERATORS) <> 0);

  {$IFDEF DEPARTMENT}
  if not IBLogin.IsUserAdmin then
    actRestore.Visible := False
  else
    actRestore.Visible := True;
  {$ENDIF}
end;

procedure TfrmGedeminMain.Loaded;
begin
  inherited;

  if Position = poDesigned then
  begin
    Left := Screen.DeskTopLeft - 1;
    Top := Screen.DesktopTop - 1;
    Width := Screen.DesktopWidth + 2;
  end;

  tcForms.Tabs.Clear;
end;

procedure TfrmGedeminMain.actShowUsersExecute(Sender: TObject);
begin
  with TfrmIBUserList.Create(Self) do
  try
    ShowUsers;
  finally
    Free;
  end;
end;

procedure TfrmGedeminMain.actShowUsersUpdate(Sender: TObject);
begin
  actShowUsers.Enabled := (IBLogin <> nil)
    and (IBLogin.Database <> nil)
    and (IBLogin.Database.Connected)
    and (IBLogin.IsUserAdmin);
end;

procedure TfrmGedeminMain.TBItem3Click(Sender: TObject);
begin
  {$IFDEF PROTECT}
  with Tpr_dlgRegNumber.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
  {$ENDIF}
end;

procedure TfrmGedeminMain.TBItem4Click(Sender: TObject);
begin
  {$IFDEF PROTECT}

  if (IBLogin.CompanyKey = 146866007) or 
    (IBLogin.CompanyKey = 153408611) or
    (IBLogin.CompanyKey = 153583337) then
  begin

    with Tpr_dlgLicence.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;

  end;  
  {$ENDIF}
end;

procedure TfrmGedeminMain.LoadSettings;
begin
  inherited;
  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TfrmGedeminMain.SaveSettings;
begin
  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
  inherited;
end;

procedure TfrmGedeminMain._DoOnCreateForm(Sender: TObject);
var
  S: String;
  Old: Integer;
begin
  if (Sender is TForm) and (Sender <> Self)
    {and (not (fsModal in TForm(Sender).FormState))} then
  begin
    S := (Sender as TForm).Caption;
    if Length(S) > 20 then
      S := Copy(S, 1, 17) + '...';
    if tcForms.Tabs.IndexOfObject(Sender) = -1 then
    begin
      Old := tcForms.TabIndex;
      tcForms.Tabs.AddObject(S, Sender);
      tcForms.TabIndex := Old;
    end;
  end;
end;

procedure TfrmGedeminMain._DoOnDestroyForm(Sender: TObject);
var
  I: Integer;
begin
  for I := tcForms.Tabs.Count - 1 downto 0 do
    if Sender = tcForms.Tabs.Objects[I] then
      tcForms.Tabs.Delete(I);
end;

destructor TfrmGedeminMain.Destroy;
begin
  _OnCreateForm := nil;
  _OnDestroyForm := nil;
  _OnActivateForm := nil;

  inherited;
end;

procedure TfrmGedeminMain.tcFormsChange(Sender: TObject);
var
  frm: TForm;
begin
  if tcForms.TabIndex >= 0 then
  try
    frm := tcForms.Tabs.Objects[tcForms.TabIndex] as TForm;

    if FormsList.IndexOf(frm) = -1 then
      tcForms.Tabs.Delete(tcForms.TabIndex)
    else
    begin
      frm.Show;
      if frm.Left >= Screen.Width then
        frm.Left := Screen.Width div 2;
      if frm.Top >= Screen.Height then
        frm.Top := Screen.Height div 2;
    end;

  except
    //oops!
    tcForms.Tabs.Delete(tcForms.TabIndex);
  end;
end;

procedure TfrmGedeminMain.tbFormsResize(Sender: TObject);
begin
  {tcForms.Left := 0;
  tcForms.Top := 0;
  tcForms.Height := 21;}
  tcForms.Width := tbForms.Width - 10;
end;

procedure TfrmGedeminMain._DoOnActivateForm(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  if (Sender is TForm) and (Sender <> Self)
    and (not (csDestroying in TForm(Sender).ComponentState)) then
  begin
    S := (Sender as TForm).Caption;
    if Length(S) > 20 then
      S := Copy(S, 1, 17) + '...';
    if tcForms.Tabs.IndexOfObject(Sender) = -1 then
      tcForms.Tabs.AddObject(S, Sender);

    for I := 0 to tcForms.Tabs.Count - 1 do
      if Sender = tcForms.Tabs.Objects[I] then
        tcForms.TabIndex := I;
  end;
end;

procedure TfrmGedeminMain.Activate;
begin
  inherited;
  tcForms.TabIndex := -1;
end;

procedure TfrmGedeminMain.actEditFormExecute(Sender: TObject);
begin
  with Tdlg_EditNewForm.CreateAndAssign(Application) as Tdlg_EditNewForm do
  begin
    Prepare;
    Show;
  end
end;

procedure TfrmGedeminMain.FormActivate(Sender: TObject);
var
  S: String[8];
  Msg: String;
begin
  { TODO :
а после подключения к другой базе уже не будет
формактивэйт вызываться }
  if FFirstTime and Assigned(UserStorage) then
  begin
    if UserStorage.ReadInteger('Options', 'KbLanguage', 0) <> 0 then
    begin
      S := IntToHex(UserStorage.ReadInteger('Options', 'KbLanguage', 0), 8);
      LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
    end;

    if UserStorage.ReadBoolean('Options\Confirmations', 'Other', True) then
    begin
      if UnEventMacro then
        Msg := 'событий'
      else
        Msg := '';

      if UnMethodMacro then
      begin
        if Msg > '' then
          Msg := Msg + ' и ';
        Msg := Msg + 'перекрытых методов классов';
      end;

      if Msg > '' then
      begin
        MessageBox(0,
          PChar('Система запущена в режиме с отключенными обработчиками ' + Msg + '.'#13#10#13#10 +
          'Для запуска в нормальном режиме удалите параметры /unmethod, /unevent из командной строки.'#13#10#13#10 +
          'Отключить данное сообщение вы можете в окне "Опции" раздела "Сервис" главного меню программы.'),
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;

    FFirstTime := False;
  end;

  // если нет десктопа, то эксплорер всегда открываем
  if ((gdc_frmExplorer = nil) or (not gdc_frmExplorer.Visible))
    and (DesktopManager.CurrentDesktopName = '') then
  begin
    if (IBLogin <> nil) and (not IBLogin.LoggingOff) then
      actExplorer.Execute;
  end;

  if Assigned(gdSplash) then
    gdSplash.FreeSplash;
end;

procedure TfrmGedeminMain.actShowSQLObjectsUpdate(Sender: TObject);
begin
  {$IFNDEF DEBUG}
  actShowSQLObjects.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actShowSQLObjectsExecute(Sender: TObject);
begin
  {$IFDEF DEBUG}
  with Tgd_frmShowSQLObjects.Create(Self) do
    Show;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actEditFormUpdate(Sender: TObject);
begin
  actEditForm.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsIBUserAdmin;

  {$IFDEF DEPARTMENT}
    if IBLogin.IsUserAdmin then
      actEditForm.Visible := True
    else
      actEditForm.Visible := False;  
  {$ENDIF}
end;

procedure TfrmGedeminMain.actPropertyExecute(Sender: TObject);
begin
  Assert(EventControl <> nil);
  EventControl.EditObject(Application, emNone);
end;

procedure TfrmGedeminMain.actPropertyUpdate(Sender: TObject);
begin
  actProperty.Enabled := (IBLogin <> nil)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actOptionsExecute(Sender: TObject);
begin
  with Tgd_dlgOptions.Create(Self) do
  try      
    ShowModal;
  finally
    Free;
  end;
end;

(*
procedure TfrmGedeminMain.actCloseAllGedeminsUpdate(Sender: TObject);
begin
  actCloseAllGedemins.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;

  {$IFDEF DEPARTMENT}
    if not IBLogin.IsUserAdmin then
      actCloseAllGedemins.Visible := False
    else
      actCloseAllGedemins.Visible := True;
  {$ENDIF}
end;
*)

procedure TfrmGedeminMain.actOptionsUpdate(Sender: TObject);
begin
  actOptions.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actSaveDesktopUpdate(Sender: TObject);
begin
  actSaveDesktop.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);

  cbDesktop.Enabled := actSaveDesktop.Enabled;    
end;

procedure TfrmGedeminMain.actDeleteDesktopUpdate(Sender: TObject);
begin
  actDeleteDesktop.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actScanTemplateExecute(Sender: TObject);
begin
//Если вы хотите это убрать с главной формы, то придумайте куда его можно впихнуть
//Это просмотр для докуметов, которые считываются в клиент датасет шаблоном (например, считывание выписки).

  Ttmp_ScanTemplate.Create(Self).Show;
end;

procedure TfrmGedeminMain.gsiblkupCompanyChange(Sender: TObject);
{const
  SavedDesktop: String = '';}
begin
  if gsiblkupCompany.CurrentKeyInt <> IBLogin.CompanyKey then
  begin
    if Assigned(UserStorage) then
    begin
      if (cbDesktop.Text > '') and
        (
          (UserStorage.ReadInteger('Options', 'SaveDT', 1) = 0) or
          (
            (UserStorage.ReadInteger('Options', 'SaveDT', 1) = 2)
            and
            (MessageBox(Handle, 'Сохранить текущий рабочий стол?', 'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES)
          )
        ) then
      begin
        DesktopManager.WriteDesktopData(cbDesktop.Text, True);
      end;
    end;

    IBLogin.OpenCompany(False, gsiblkupCompany.CurrentKeyInt,
      gsiblkupCompany.Text);
  end;
end;

procedure TfrmGedeminMain.actAboutExecute(Sender: TObject);
begin
  with Tgd_dlgAbout.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmGedeminMain._DoOnCaptionChange(Sender: TObject);
var
  I: Integer;
  Index: Integer;
  S: string;
begin
  Index := -1;
  for I := 0 to tcForms.Tabs.Count - 1 do
    if Sender = tcForms.Tabs.Objects[I] then
      Index := I;
  if Index > -1 then
  begin
    S := (Sender as TForm).Caption;
    if Length(S) > 20 then
      S := Copy(S, 1, 17) + '...';
    tcForms.Tabs[Index] := S;
  end;
end;

procedure TfrmGedeminMain.TBItem13Click(Sender: TObject);
begin
  ShowHelp('VBS55.CHM');
end;

procedure TfrmGedeminMain.TBItem16Click(Sender: TObject);
begin
  ShowHelp('FR24RUS.CHM');
end;

procedure TfrmGedeminMain.TBItem12Click(Sender: TObject);
begin
  ShowHelp('GEDYMINUG.CHM');
end;

procedure TfrmGedeminMain.TBItem11Click(Sender: TObject);
begin
  ShowHelp('GEDYMINDG.CHM');
end;

procedure TfrmGedeminMain.TBItem18Click(Sender: TObject);
begin
  ShowHelp('GEDYMINGS.CHM');
end;

procedure TfrmGedeminMain.TBItem19Click(Sender: TObject);
begin
  ShowHelp('GEDYMINPG.CHM');
end;

procedure TfrmGedeminMain.TBItem5Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://www.gsbelarus.com',
    nil,
    nil,
    SW_SHOW);
end;

procedure TfrmGedeminMain.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    RemoveComponentFromList(AComponent);
  end;
end;

procedure TfrmGedeminMain.actSQLEditorExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(Application) do
  begin
    FDatabase := gdcBaseManager.Database;
    ShowSQL('', nil, False);
  end;
end;

procedure TfrmGedeminMain.actSQLEditorUpdate(Sender: TObject);
begin
  actSQLEditor.Enabled := (IBLogin <> nil)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actCloseFormExecute(Sender: TObject);
var
  TabPos: TPoint;
  I: Integer;
begin
  TabPos := TCrackPopupMenu(pmForms).PopupPoint;
  TabPos := tcForms.ScreenToClient(TabPos);
  I := tcForms.IndexOfTabAt(TabPos.x, TabPos.y);
  if I > -1 then
  try
    if tcForms.Tabs.Objects[I] is TfrmGedeminProperty then
    begin
      if (tcForms.Tabs.Objects[I] as TfrmGedeminProperty).Restored then
       (tcForms.Tabs.Objects[I] as TForm).Free;
    end else
      (tcForms.Tabs.Objects[I] as TForm).Free;
  except
    //oops!
    tcForms.Tabs.Delete(I);
  end;
end;

procedure TfrmGedeminMain.actHideFormExecute(Sender: TObject);
var
  TabPos: TPoint;
  I: Integer;
begin
  TabPos := TCrackPopupMenu(pmForms).PopupPoint;
  TabPos := tcForms.ScreenToClient(TabPos);
  I := tcForms.IndexOfTabAt(TabPos.x, TabPos.y);
  if I > -1 then
  try
    (tcForms.Tabs.Objects[I] as TForm).Close;
  except
    //oops!
    tcForms.Tabs.Delete(I);
  end;
end;

procedure TfrmGedeminMain.actHideAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to tcForms.Tabs.Count - 1 do
  try
    (tcForms.Tabs.Objects[I] as TForm).Close;
  except
    //oops!
    tcForms.Tabs.Delete(I);
  end;
end;

procedure TfrmGedeminMain.actCloseAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := tcForms.Tabs.Count - 1 downto 0 do
  try
    try
      if gdc_frmExplorer <> tcForms.Tabs.Objects[I] then
      begin
        if tcForms.Tabs.Objects[I] is TForm then
        begin
          if tcForms.Tabs.Objects[I] is TfrmGedeminProperty then
          begin
            if (tcForms.Tabs.Objects[I] as TfrmGedeminProperty).Restored then
              (tcForms.Tabs.Objects[I] as TForm).Free;
          end else
            (tcForms.Tabs.Objects[I] as TForm).Free;
        end;
      end;
    except
      //oops!
      tcForms.Tabs.Delete(I);
    end;
  except
  end;  
end;

procedure TfrmGedeminMain.tcFormsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if tcForms.IndexOfTabAt(X, Y) <> -1 then
  begin
    tcForms.Hint := tcForms.Tabs[tcForms.IndexOfTabAt(X, Y)];
  end;
end;

procedure TfrmGedeminMain.actWorkingCompaniesExecute(Sender: TObject);
begin
  TgdcOurCompany.CreateViewForm(Application).Show;
end;

procedure TfrmGedeminMain.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

// установка настроек
procedure TfrmGedeminMain.actLoadPackageExecute(Sender: TObject);
begin
  with Tat_dlgLoadPackages.Create(Self) do
  try 
    ShowModal;
  finally
    Free;
  end; 
end;


procedure TfrmGedeminMain.actWorkingCompaniesUpdate(Sender: TObject);
begin
  actWorkingCompanies.Enabled := Assigned(gdcBaseManager)
    and Assigned(gdcBaseManager.Database)
    and gdcBaseManager.Database.Connected
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_CHANGE_WO_ID, GD_POL_CHANGE_WO_MASK, False) and IBLogin.InGroup) <> 0);
  gsiblkupCompany.Enabled := actWorkingCompanies.Enabled;
end;
    
procedure TfrmGedeminMain.actLoadPackageUpdate(Sender: TObject);
begin
  actLoadPackage.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsIBUserAdmin;
end;

procedure TfrmGedeminMain.ApplicationEventsShowHint(var HintStr: String;
  var CanShow: Boolean; var HintInfo: THintInfo);
begin
  if Length(HintStr) > 80 then
    HintInfo.HideTimeout := 9000;
end;

procedure TfrmGedeminMain.actCloseAllUpdate(Sender: TObject);
begin
  actCloseAll.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actScanTemplateUpdate(Sender: TObject);
begin
  actScanTemplate.Enabled := Assigned(IBLogin) and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actActiveFormListUpdate(Sender: TObject);
begin
  actActiveFormList.Enabled := Assigned(IBLogin) and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := Assigned(IBLogin) and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actHideFormUpdate(Sender: TObject);
begin
  actHideForm.Enabled := Assigned(GlobalStorage)
      and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actHideAllUpdate(Sender: TObject);
begin
  actHideAll.Enabled := Assigned(GlobalStorage)
      and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actCloseFormUpdate(Sender: TObject);
begin
  actCloseForm.Enabled := Assigned(GlobalStorage)
      and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure TfrmGedeminMain.actRegistrationExecute(Sender: TObject);
begin
{$IFDEF GEDEMIN_LOCK}
  with Tgd_dlgReg.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
{$ENDIF}

end;

procedure TfrmGedeminMain.actRegistrationUpdate(Sender: TObject);
begin                                    
{$IFNDEF GEDEMIN_LOCK}
  actRegistration.Visible := False;
{$ENDIF}
  if (IBLogin <> nil) and IBLogin.Database.Connected then
  begin
    actRegistration.Enabled := IBLogin.IsUserAdmin;
  end;
end;

procedure TfrmGedeminMain.actRecompileStatisticsExecute(Sender: TObject);
var
  Cr: TCursor;
begin
  with TfrmIBUserList.Create(nil) do
  try
    if not CheckUsers then
    begin
      MessageBox(Handle,
        'К базе данных подключены другие пользователи. Обновление'#13#10 +
        'статистики индексов возможно только в однопользовательском режиме.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      exit;
    end;
  finally
    Free;
  end;

  if MessageBox(Handle,
    'Обновление статистики индексов может занять несколько минут. Продолжить?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    Cr := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;
      UpdateIndicesStat(gdcBaseManager.Database);
      RecompileProcedures(gdcBaseManager.Database);
      RecompileTriggers(gdcBaseManager.Database);
      ReCreateComputedFields(gdcBaseManager.Database);
      ReCreateView(gdcBaseManager.Database);
    finally  
      Screen.Cursor := Cr;
    end;

    MessageBox(Handle,
      'Обновление статистики индексов завершено успешно.',
      'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end;
end;

procedure TfrmGedeminMain.actRecompileStatisticsUpdate(Sender: TObject);
begin
  actRecompileStatistics.Enabled := Assigned(IBLogin)
    and (IBLogin.IsIBUserAdmin)
    and Assigned(gdcBaseManager)
    and (gdcBaseManager.Database <> nil)
    and (gdcBaseManager.Database.Connected);
end;

procedure TfrmGedeminMain.actSQLMonitorUpdate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  actSQLMonitor.Enabled := Assigned(IBLogin) and
    (IBLogin.IsUserAdmin or ((IBLogin.InGroup and GD_UG_POWERUSERS) <> 0));
  {$ELSE}
  actSQLMonitor.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actSQLMonitorExecute(Sender: TObject);
{$IFDEF DEBUG}
var
  F: TCustomForm;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  F := FindForm(Tgd_frmSQLMonitor);
  if F = nil then
    F := Tgd_frmSQLMonitor.Create(Application);
  F.Show;
  {$ENDIF}
end;

procedure TfrmGedeminMain.DoDestroy;
begin
  inherited;

  if ExitCode = 0 then
  try
    // сохраняем режим отображения наименований полей в фильтрах
    if Assigned(UserStorage) then
      UserStorage.WriteInteger('Filter', 'FieldNameMode', Integer(fltFieldNameMode));

    if Assigned(IBLogin) then
    begin
      if IBLogin.Loggedin then
        IBLogin.LogOff;

      IBLogin.RemoveCompanyNotify(Self);
      IBLogin.RemoveConnectNotify(Self);
    end;
  except
    Application.HandleException(Self);
  end;
end;

procedure TfrmGedeminMain.actCopyUpdate(Sender: TObject);
begin
  actCopy.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actCopyExecute(Sender: TObject);
begin
  Clipboard.AsText := IBLogin.Database.DatabaseName;
end;

procedure TfrmGedeminMain.actCompareDataBasesExecute(Sender: TObject);
begin
  with TDataBaseCompare.Create(Application) do
    Show;
end;

procedure TfrmGedeminMain.actCompareDataBasesUpdate(Sender: TObject);
begin
  actCompareDataBases.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actShellExecute(Sender: TObject);
const
  RegKeyName = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';
var
  Reg: TRegistry;
  S: String;
  I: Integer;
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKey(RegKeyName, True) then
    begin
      MessageBox(Handle,
        'Текущая учетная запись Windows не обладает правами для записи в реестр.'#13#10 +
        'Зайдите на компьютер под учетной записью с правами Администратора.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end else
    begin
      with Tgd_frmShell.Create(Self) do
      try
        chbxUseShell.Checked := Reg.ValueExists('Shell') and
          (StrIPos('gedemin', Reg.ReadString('Shell')) <> 0);
        edPath.Text := Application.EXEName;
        edDatabase.Text := IBLogin.DatabaseName;

        if ShowModal = mrOk then
        begin
          if chbxUseShell.Checked then
          begin
            S := edPath.Text;

            if chbxAuto.Checked then
              S := S + ' /sn ' + edDatabase.Text;

            if Trim(edUser.Text) > '' then
              S := S + ' /user ' + edUser.Text;

            if Trim(edPassword.Text) > '' then
              S := S + ' /password ' + edPassword.Text;

            for I := 1 to Length(S) do
            begin
              if S[I] in ['А'..'Я', 'а'..'я', 'Ё', 'ё', 'Ў', 'ў'] then
              begin
                MessageBox(Handle,
                  'Имя файла содержит недопустимые символы!',
                  'Ошибка',
                  MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                exit;
              end;
            end;

            Reg.WriteString('Shell', S);
          end else
          begin
            Reg.WriteString('Shell', 'Explorer.exe');
          end;
        end;
      finally
        Free;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfrmGedeminMain.actShellUpdate(Sender: TObject);
begin
  actShell.Enabled := (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;


procedure TfrmGedeminMain.actStreamSaverOptionsExecute(Sender: TObject);
begin
  {$IFDEF NEW_STREAM}
  with TdlgStreamSaverOptions.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
  {$ENDIF}
end;


procedure TfrmGedeminMain.actShowMonitoringExecute(Sender: TObject);
begin
  with Tgd_frmMonitoring.Create(Application) do
    Show;
end;

procedure TfrmGedeminMain.actShowMonitoringUpdate(Sender: TObject);
begin
  actShowMonitoring.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actStreamSaverOptionsUpdate(Sender: TObject);
begin
  {$IFNDEF NEW_STREAM}
  actStreamSaverOptions.Enabled := False;  
  {$ENDIF}
end;

end.
