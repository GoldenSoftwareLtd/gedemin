// ShlTanya, 09.03.2019

unit gd_main_form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ToolWin, ComCtrls, IBDatabase, dmDatabase_unit, gd_security,
  IBSQL, ActnList, Menus, gsDesktopManager, StdCtrls, dmImages_unit,
  gd_security_OperationConst, gdNotifierThread_unit, AppEvnts, Db,
  IBCustomDataSet, IBServices, gdHelp_Body, gd_createable_form, TB2Item,
  TB2Dock, TB2Toolbar, gsIBLookupComboBox, TB2ExtItems, gd_messages_const;

type
  TCrackIBCustomDataset = class(TIBCustomDataset);

  TfrmGedeminMain = class(TCreateableForm, ICompanyChangeNotify,
      IConnectChangeNotify)
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
    tbiSettings: TTBItem;
    actSettings: TAction;
    tbsiAttributes: TTBSubmenuItem;
    tbiGenerators: TTBItem;
    tbiProcedures: TTBItem;
    tbiViews: TTBItem;
    tbiExceptions: TTBItem;
    tbiDomains: TTBItem;
    tbiTables: TTBItem;
    actGenerators: TAction;
    actDomains: TAction;
    actExceptions: TAction;
    actViews: TAction;
    actProcedures: TAction;
    actTables: TAction;
    TBSeparatorItem14: TTBSeparatorItem;
    tbiStorage: TTBItem;
    tbiDocumentType: TTBItem;
    actDocumentType: TAction;
    actStorage: TAction;
    actStreamSaverOptions: TAction;
    tbiStreamSaverOptions: TTBItem;
    actShowMonitoring: TAction;
    TBItem23: TTBItem;
    tbiSQLProcessWindow: TTBItem;
    actSQLProcess: TAction;
    tbsiAdministrator: TTBSubmenuItem;
    TBItem24: TTBItem;
    TBItem25: TTBItem;
    TBItem26: TTBItem;
    actUserGroups: TAction;
    actJournal: TAction;
    actUsers: TAction;
    TBItem27: TTBItem;
    actReconnect: TAction;
    TBSeparatorItem15: TTBSeparatorItem;
    actDBSqueeze: TAction;
    tbiSqueeze: TTBItem;
    tbiDatabasesList: TTBItem;
    actDatabasesList: TAction;
    TBSeparatorItem16: TTBSeparatorItem;
    TBItem28: TTBItem;
    TBItem29: TTBItem;
    TBSeparatorItem17: TTBSeparatorItem;
    actReload: TAction;
    tbiReload: TTBItem;
    actDBTriggers: TAction;
    TBItem30: TTBItem;
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
    procedure actSettingsExecute(Sender: TObject);
    procedure actGeneratorsExecute(Sender: TObject);
    procedure actDomainsExecute(Sender: TObject);
    procedure actExceptionsExecute(Sender: TObject);
    procedure actViewsExecute(Sender: TObject);
    procedure actProceduresExecute(Sender: TObject);
    procedure actTablesExecute(Sender: TObject);
    procedure actStorageExecute(Sender: TObject);
    procedure actDocumentTypeExecute(Sender: TObject);
    procedure actStreamSaverOptionsExecute(Sender: TObject);
    procedure actShowMonitoringExecute(Sender: TObject);
    procedure actShowMonitoringUpdate(Sender: TObject);
    procedure actSQLProcessExecute(Sender: TObject);
    procedure actStreamSaverOptionsUpdate(Sender: TObject);
    procedure actSettingsUpdate(Sender: TObject);
    procedure actStorageUpdate(Sender: TObject);
    procedure actDocumentTypeUpdate(Sender: TObject);
    procedure actGeneratorsUpdate(Sender: TObject);
    procedure actDomainsUpdate(Sender: TObject);
    procedure actExceptionsUpdate(Sender: TObject);
    procedure actViewsUpdate(Sender: TObject);
    procedure actProceduresUpdate(Sender: TObject);
    procedure actTablesUpdate(Sender: TObject);
    procedure actUserGroupsExecute(Sender: TObject);
    procedure actJournalExecute(Sender: TObject);
    procedure actUsersExecute(Sender: TObject);
    procedure actUserGroupsUpdate(Sender: TObject);
    procedure actJournalUpdate(Sender: TObject);
    procedure actUsersUpdate(Sender: TObject);
    procedure actReconnectUpdate(Sender: TObject);
    procedure actReconnectExecute(Sender: TObject);
    procedure actDBSqueezeUpdate(Sender: TObject);
    procedure actDBSqueezeExecute(Sender: TObject);
    procedure actDatabasesListExecute(Sender: TObject);
    procedure actDatabasesListUpdate(Sender: TObject);
    procedure actReloadExecute(Sender: TObject);
    //procedure actPrepareIBANExecute(Sender: TObject);
    //procedure actPrepareIBANUpdate(Sender: TObject);
    procedure actDBTriggersExecute(Sender: TObject);
    procedure actDBTriggersUpdate(Sender: TObject);

  private
    FCanClose: Boolean;
    FExitWindowsParam: Longint;
    FExitWindows: Boolean;
    FFirstTime: Boolean;
    FNotificationID: Integer;

    procedure OnFormToggleItemClick(Sender: TObject);

    procedure EnableCategory(Category: String; DoEnable: Boolean);

    procedure _DoOnCreateForm(Sender: TObject);
    procedure _DoOnDestroyForm(Sender: TObject);
    procedure _DoOnActivateForm(Sender: TObject);
    procedure _DoOnCaptionChange(Sender: TObject);

    procedure ApplicationEventsShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo);

    procedure WMRunOnLoginMacros(var Msg: TMessage);
      message WM_GD_RUNONLOGINMACROS;
    procedure WMRelogin(var Msg: TMessage);
      message WM_GD_RELOGIN;

    procedure WMUpdateNotification(var Msg: TMessage);
      message WM_GD_UPDATE_NOTIFICATION;

    procedure WMReload(var Msg: TMessage);
      message WM_GD_RELOAD;

    procedure WMUserFeedback(var Msg: TMessage);
      message WM_GD_USER_FEEDBACK;  

  protected
    procedure Loaded; override;

    procedure WMQueryEndSession(var Message: TWMQueryEndSession);
      message WM_QUERYENDSESSION;

    procedure DoBeforeChangeCompany;
    procedure DoAfterChangeCompany;

    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure DoDestroy; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddFormToggleItem(AForm: TForm);
    function GetFormToggleItemIndex(AForm: TForm): Integer;
  end;

var
  frmGedeminMain: TfrmGedeminMain;

implementation

{$R *.DFM}

uses
  FastMM4,
  jclBase,
  jclFileUtils,
  jclStrings,
  IBXConst,
  IBIntf,
  ShellAPI,
  gd_frmShell_unit,
  gd_CmdLineParams_unit,
  scrMacrosGroup,
  gd_dlgInitialInfo_unit,

  at_frmIBUserList,
  at_SQL_Setup,
  at_classes,
  at_sql_metadata,
  at_frmSQLProcess,
  at_dlgLoadPackages_unit,

  gd_resourcestring,

  gd_frmWindowsList_unit,
  gd_directories_const,
  gd_frmBackup_unit,
  gd_frmRestore_unit,
  gd_dlgDeleteDesktop_unit,
  gd_dlgDesktopName_unit,
  gd_dlgAbout_unit,
  gd_DatabasesList_unit,
  gd_common_functions,

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

  // ��������� ��� �������
  gdc_frmExplorer_unit,

  {$IFDEF PROTECT}
  pr_dlgRegNumber_unit,
  pr_dlgLicence_unit,
  {$ENDIF}

{$IFDEF WITH_INDY}
  gd_WebServerControl_unit,
  gdccClient_unit,
  gdccConst,
  gdccGlobal,
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
  gdcFile,

  gsStorage_CompPath,
  //{$IFDEF DEBUG}
  //gdSQLMonitor,
  //{$ENDIF}

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

  evt_i_Base,

  gdcBugBase,
  gd_ClassList,

  Storages,
  gsStorage,

  rp_report_const,
  gd_SetDatabase,
  gd_i_ScriptFactory,
  ActiveX,
  rp_ReportMainForm_unit,
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
  dm_i_ClientReport_unit,
  gdcBaseInterface, dmLogin_unit,
  prp_frmGedeminProperty_Unit,
  cmp_frmDataBaseCompare,
  gd_frmMonitoring_unit,
  Clipbrd,
  {$IFDEF DUNIT_TEST}
  TestFramework,
  GUITestRunner,
  TestExtensions,
  GedeminTestList,
  gdDBSqueeze,
  {$ENDIF}
  Registry
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdcExplorer,
  gd_dlgStreamSaverOptions,
  gdc_frmStreamSaver,
  gd_frmFeedback_unit;

type
  TCrackPopupMenu = class(TPopupMenu);

procedure TfrmGedeminMain.FormCreate(Sender: TObject);
begin
  if gdNotifierThread <> nil then
    gdNotifierThread.NotifierWindow := Self.Handle;

  if Assigned(IBLogin) then
  begin
    // ��� ������� ��� ������ � ��������� � ����
    // �� ������� ����� -- ��� ����� �� ����� �����������
    // � ��������, ������� ������� ��������������� ������
    // �������
    tbsiDatabase.Enabled := False;
    tbsiMacro.Enabled := False;
    tbsiWindow.Enabled := False;
    try
      if IBLogin.LoggedIn then
      begin
        DoAfterSuccessfullConnection;
        DoAfterChangeCompany;
      end;
    finally
      tbsiDatabase.Enabled := True;
      tbsiMacro.Enabled := True;
      tbsiWindow.Enabled := True;
    end;

    IBLogin.AddConnectNotify(Self);
    IBLogin.AddCompanyNotify(Self);
  end;
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
  actExplorer.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn;
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
  I: Integer;
begin
  {$IFDEF WITH_INDY}
  if (gdWebServerControl <> nil) and gdWebServerControl.InProcess then
  begin
    CanClose := False;
    exit;
  end;
  {$ENDIF}

  if Assigned(IBLogin) and (IBLogin.Database <> nil)
    and (not IBLogin.Database.TestConnected) then
  begin
    CanClose := True;
    exit;
  end;

  // ���� ������������� ��� �������������� ���� � �����
  // �������, �� �������� �� ��������� ������
  if (FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
    (FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive) then
  begin
    CanClose := False;
    exit;
  end;

  //���� ������� ���� ������� � � ��� ����������� ��������� �������� ��
  //���������� ������ �� ���������� ���������
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

  //���������� ��� ����, ����� �������, � ���. Owner = Application
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

  OleUninitialize;
end;

constructor TfrmGedeminMain.Create(AnOwner: TComponent);
begin
  inherited;
  FCanClose := False;
  FExitWindows := False;
  FFirstTime := True;
  FNotificationID := -1;

  _OnCreateForm := _DoOnCreateForm;
  _OnDestroyForm := _DoOnDestroyForm;
  _OnActivateForm := _DoOnActivateForm;
  _OnCaptionChange := _DoOnCaptionChange;

  Application.OnShowHint := ApplicationEventsShowHint;

  {$IFNDEF PROTECT}
  TBItem4.Visible := False;
  TBItem3.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  //gsStorage_CompPath.MainForm := nil;
  FExitWindows := True;
  FExitWindowsParam := Message.Unused;
  actExit.Execute;
  inherited;
end;

procedure TfrmGedeminMain.actExitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled :=
    (not Assigned(Screen.ActiveForm)) or ([fsModal] * Screen.ActiveForm.FormState = [])
    and (not ((FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
      (FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive)));
end;

procedure TfrmGedeminMain.DoAfterChangeCompany;
var
  ShouldShowExplorer: Boolean;
  q: TIBSQL;
begin
  if (IBLogin <> nil)
    and IBLogin.IsIBUserAdmin
    and (IBLogin.CompanyKey < cstUserIDStart)
    and (System.Copy(IBLogin.CompanyName, 1, 1) = '<')
    and (not gd_CmdLineParams.QuietMode)
    and (not gd_CmdLineParams.Embedding)
    and (gd_CmdLineParams.LoadSettingFileName = '') then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT COUNT(*) FROM gd_ourcompany';
      q.ExecQuery;

      if q.EOF or (q.Fields[0].AsInteger <= 1) then
      begin
        if Assigned(gdSplash) then
          gdSplash.FreeSplash;

        with Tgd_dlgInitialInfo.Create(nil) do
        try
          if ShowModal = mrOk then
          begin
            PostMessage(Self.Handle, WM_GD_RELOGIN, 0, 0);
            exit;
          end;
        finally
          Free;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  //
  //  ��������� ������� ����
  EnableCategory('Tray', True);
  EnableCategory('��������', True);
  EnableCategory('��������', True);

  if gdc_frmExplorer = nil then
  begin
    if Assigned(gdSplash) then
      gdSplash.ShowText(sLoadingExplorer);
    Tgdc_frmExplorer.CreateAndAssign(Application);
  end;

  ShouldShowExplorer := True;

  DesktopManager.OnDesktopItemCreate := gsDesktopManagerDesktopItemCreate;
  DesktopManager.ReadDesktopNames;
  {$IFNDEF DUNIT_TEST}
  if GetAsyncKeyState(VK_SHIFT) shr 1 = 0 then
  begin
    if Assigned(UserStorage) and
      UserStorage.ReadBoolean(st_dt_DesktopOptionsPath, st_dt_LoadDesktopOnStartup, True) then
    begin
      if Assigned(gdSplash) then
        gdSplash.ShowText(sLoadingDesktop);
      DesktopManager.ReadDesktopData(UserStorage.ReadString(st_dt_DesktopOptionsPath, st_dt_LoadOnStartup, ''));
      DesktopManager.LoadDesktop;
      if DesktopManager.DesktopItems.Count > 0 then
        ShouldShowExplorer := False;
    end;
  end;
  {$ENDIF}
  DesktopManager.InitComboBox(cbDesktop);

  if Assigned(frmStreamSaver) and frmStreamSaver.Visible then
    SetWindowPos(frmStreamSaver.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);

  // ����� ���, �� ������������ ����� ��������
  // ����� ����������� ���� ������

  if Assigned(frmGedeminMain) then
  begin
    Caption := IBLogin.GetMainWindowCaption;
    Application.Title := Caption;

    {$IFDEF NOGEDEMIN}
    tbsiHelp.Enabled:= False;
    tbsiHelp.Visible:= False;
    {$ENDIF}

    if (gsiblkupCompany.CurrentKeyInt <> IBLogin.CompanyKey)
      or (gsiblkupCompany.Text <> IBLogin.CompanyName) then
    begin
      gsiblkupCompany.CurrentKeyInt := IBLogin.CompanyKey;
    end;
  end;

  if ShouldShowExplorer
    and (gdc_frmExplorer <> nil)
    and (not gdc_frmExplorer.Visible)
    and Self.Visible then
  begin
    gdc_frmExplorer.Show;
  end;

  _IBSQLCache.Enabled := True;

  {
  if (not IBLogin.Relogining)
    and (not gd_CmdLineParams.QuietMode)
    and (not gd_CmdLineParams.Embedding)
    and (gd_CmdLineParams.LoadSettingFileName = '') then
  begin
    PostMessage(Handle, WM_GD_USER_FEEDBACK, 0, 0);
  end;
  }  
end;

procedure TfrmGedeminMain.DoBeforeChangeCompany;
begin
  //
  //  ����������� ������� ����
  cbDesktop.Items.Clear;
  cbDesktop.Enabled := False;

  if FormAssigned(gdc_frmExplorer) then
    gdc_frmExplorer.Hide;

  EnableCategory('Tray', False);
  EnableCategory('��������', False);
  EnableCategory('��������', False);
end;

procedure TfrmGedeminMain.DoAfterConnectionLost;
begin
  if FormAssigned(gdc_frmExplorer) then
    FreeAndNil(gdc_frmExplorer);

  EnableCategory('Tray', False);
  EnableCategory('��������', False);
  EnableCategory('��������', False);

  cbDesktop.Items.Clear;
  cbDesktop.Enabled := False;

  _IBSQLCache.Enabled := False;
end;

procedure TfrmGedeminMain.DoAfterSuccessfullConnection;
var
  TempPath: array[0..256] of char;
  SearchR: TSearchRec;
  S: String;
  J: DWORD;
  DI: Tgd_DatabaseItem;
begin
  ClearFltComponentCache;

  {������� ��������� ����� �������, ������� ����� ����������� �� �����
   ��� ������������ ������ �� gedemin-a}

  GetTempPath(sizeof(TempPath), TempPath);
  while FindFirst(StrPas(TempPath) + rpTempPrefix + '*.tmp', faArchive, SearchR) = 0 do
    if not DeleteFile(StrPas(TempPath) + SearchR.Name) then Break;

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

  gdcBaseManager.Database.TraceFlags := [];

  if (not IBLogin.Relogining)
    and (not gd_CmdLineParams.QuietMode)
    and (not gd_CmdLineParams.Embedding)
    and (gd_CmdLineParams.LoadSettingFileName = '')
    and Assigned(GlobalStorage)
    and GlobalStorage.FolderExists('Options\Arch') then
  begin
    MessageBox(0,
      '�������������� �������� ����������� ������ ������������� ����� �������������/������/�������������/����������.',
      '��������',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    GlobalStorage.DeleteFolder('Options\Arch');  
  end;

  (*
  if (not IBLogin.Relogining)
    and (gd_CmdLineParams.LoadSettingFileName = '')
    and Assigned(GlobalStorage)
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
        gdcBaseManager.ExecSingleQueryResult(
          'SELECT ibpassword FROM gd_user WHERE ibname=''SYSDBA'' ',
          Unassigned, Res);

        gd_dlgAutoBackup.Show;
        Application.ProcessMessages;

        if (not VarIsEmpty(Res)) and (not Application.Terminated) then
        begin
          ParseDatabaseName(IBLogin.DatabaseName, Server, Port, FileName);

          IBService := TIBBackupService.Create(nil);
          try
            IBService.ServerName := Server;

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
                  '���������� ��������� ������ ��������� �����������/�������������� ������.',
                  '��������',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
            except
              IBService.Active := False;
              exit;
            end;

            IBService.Verbose := False;
            IBService.Options := [NoGarbageCollection];
            IBService.DatabaseName := FileName;

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
                '�������� ����������� ������� ���������.',
                '��������',
                MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

              if GlobalStorage.ReadBoolean('Options\Arch', 'Copy', True, False) then
              begin
                if Server > '' then
                  ArcS := '�������� ���� ��������� �� ����������: ' + Server + #13#10
                else
                  ArcS := '';

                MessageBox(gd_dlgAutoBAckup.Handle,
                  PChar(
                  '�� �������� ����������� �������� ���� �� �������'#13#10 +
                  '�������� ������ � ������� ��� � �������� �����.'#13#10#13#10 +
                  '�������� ��� ����� ������!'#13#10#13#10 +
                  ArcS +
                  '��� �����: ' + IBService.BackupFile[0]),
                  '��������',
                  MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
              end;
            except
              on E: Exception do
              begin
                MessageBox(gd_dlgAutoBAckup.Handle,
                  PChar('� �������� ��������� ����������� �������� ������.'#13#10#13#10 +
                  E.Message),
                  '��������',
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
            PChar('� �������� ��������� ����������� �������� ������.'#13#10#13#10 +
            E.Message),
            '��������',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
        end;
      end;
    finally
      gd_dlgAutoBackup.Free;
    end;
  end;
  *)

  {$IFDEF GEDEMIN_LOCK}
  RegParams.CheckRegistration(True);
  {$ENDIF}

  if IBLogin.IsUserAdmin and (gdNotifierThread <> nil) then
    FNotificationID := gdNotifierThread.Add(IBLogin.Database.DatabaseName)
  else begin
    DI := gd_DatabasesList.FindSelected;
    if (DI <> nil) and (DI.Name > '') then
      FNotificationID := gdNotifierThread.Add(DI.Name)
    else
      FNotificationID := -1;
  end;

  // Issue 1992
  if FormAssigned(gdc_frmExplorer) then
  begin
    if (gdc_frmExplorer.gdcObject <> nil) and (not gdc_frmExplorer.gdcObject.Active) then
      gdc_frmExplorer.gdcObject.Open;
  end;
end;

procedure TfrmGedeminMain.DoBeforeDisconnect;
begin
  {$IFDEF NOGEDEMIN}
  Caption := '';
  {$ELSE}
  Caption := '�������';
  {$ENDIF}

  FFirstTime := True;

  tbForms.Items.Clear;

  _IBSQLCache.Enabled := False;

  gdcBaseManager.IDCacheFlush;
  ClearLookupCache;

  if FNotificationID >= 0 then
  begin
    if gdNotifierThread <> nil then
      gdNotifierThread.DeleteNotification(FNotificationID);
    FNotificationID := -1;
  end;

  if Assigned(GlobalStorage) and
    GlobalStorage.ReadBoolean('Options', 'AllowAudit', False, False) then
  begin
    TgdcJournal.AddEvent('', 'Log off');
  end;

  if gd_CmdLineParams.ClearDBID and (not IBLogin.Relogining) then
    gdcBaseManager.ExecSingleQuery('SET GENERATOR gd_g_dbid TO 0');
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

procedure TfrmGedeminMain.actLogInExecute(Sender: TObject);
begin
  if not IBLogin.LoggedIn then
    IBLogin.Login;
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
  //IBLogin.LoginSingle;
end;

procedure TfrmGedeminMain.actBringOnlineExecute(Sender: TObject);
begin
  actReconnect.Execute;
end;

procedure TfrmGedeminMain.actLoginSingleUpdate(Sender: TObject);
begin
  actLoginSingle.Visible := False;
  //actLoginSingle.Enabled := (not IBLogin.LoggedIn);
end;

procedure TfrmGedeminMain.actBringOnlineUpdate(Sender: TObject);
begin
  actBringOnline.Enabled := (IBLogin <> nil)
    and IBLogin.LoggedIn
    and IBLogin.IsIBUserAdmin
    and IBLogin.ShutDown;
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
end;

procedure TfrmGedeminMain.Loaded;
begin
  inherited;

  PostMessage(Self.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  {if Position = poDesigned then
  begin
    Left := Self.Monitor.Left - 1;
    Top := Self.Monitor.Top - 1;
    // ������� �� ������ ��������, �� ������� ��������� �����
    Width := Self.Monitor.Width + 2;
  end;}

  tbForms.Items.Clear;
end;

procedure TfrmGedeminMain.actShowUsersExecute(Sender: TObject);
begin
  with TfrmIBUserList.Create(nil) do
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
    and (IBLogin.IsIBUserAdmin);
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

procedure TfrmGedeminMain._DoOnCreateForm(Sender: TObject);
begin
  if (Sender is TForm) and (Sender <> Self) then
  begin
    if GetFormToggleItemIndex(Sender as TForm) = -1 then
      AddFormToggleItem(Sender as TForm);
  end;
end;

procedure TfrmGedeminMain._DoOnDestroyForm(Sender: TObject);
var
  I: Integer;
begin
  for I := tbForms.Items.Count - 1 downto 0 do
  begin
    if Integer(Sender) = tbForms.Items[I].Tag then
      tbForms.Items[I].Free;
  end;
end;

destructor TfrmGedeminMain.Destroy;
begin
  _OnCreateForm := nil;
  _OnDestroyForm := nil;
  _OnActivateForm := nil;

  inherited;
end;

procedure TfrmGedeminMain._DoOnActivateForm(Sender: TObject);
var
  I: Integer;
  Form: TForm;
begin
  if (Sender is TForm) and (Sender <> Self)
    and (not (csDestroying in TForm(Sender).ComponentState)) then
  begin
    Form := Sender as TForm;

    I := GetFormToggleItemIndex(Form);
    // ���� ������� ����� �� ������������� �� ����� ������, �� ������� ��
    if GetFormToggleItemIndex(Form) = -1 then
    begin
      AddFormToggleItem(Form);
      I := GetFormToggleItemIndex(Form);
    end;
    // ������ ��������������� ����� ������
    tbForms.Items[I].Checked := True;
  end;
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
  {$IFDEF DUNIT_TEST}I: Integer;{$ENDIF}
begin
  if FFirstTime then
  begin
    if Assigned(UserStorage) then
    begin
      if UserStorage.ReadInteger('Options', 'KbLanguage', 0) <> 0 then
      begin
        S := IntToHex(UserStorage.ReadInteger('Options', 'KbLanguage', 0), 8);
        LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
      end;

      if (not gd_CmdLineParams.QuietMode)
        and UserStorage.ReadBoolean('Options\Confirmations', 'Other', True) then
      begin
        if gd_CmdLineParams.UnEventMacro then
          Msg := '�������'
        else
          Msg := '';

        if gd_CmdLineParams.UnMethodMacro then
        begin
          if Msg > '' then
            Msg := Msg + ' � ';
          Msg := Msg + '���������� ������� �������';
        end;

        if Msg > '' then
        begin
          MessageBox(0,
            PChar('������� �������� � ������ � ������������ ������������� ' + Msg + '.'#13#10#13#10 +
            '��� ������� � ���������� ������ ������� ��������� /unmethod, /unevent �� ��������� ������.'#13#10#13#10 +
            '��������� ������ ��������� �� ������ � ���� "�����" ������� "������" �������� ���� ���������.'),
            '��������',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
        end;
      end;
    end;

    {$IFDEF DUNIT_TEST}
    for I := Screen.FormCount - 1 downto 0 do
    begin
      if Screen.Forms[I] is TGUITestRunner then
        break;
      if I = 0 then
        GUITestRunner.RunRegisteredTestsModeless;
    end;
    {$ENDIF}
  end;

  // ���� ��� ��������, �� ��������� ������ ���������
  if ((gdc_frmExplorer = nil) or (not gdc_frmExplorer.Visible))
    and (DesktopManager.CurrentDesktopName = '') then
  begin
    if (IBLogin <> nil) and (not IBLogin.LoggingOff) then
      actExplorer.Execute;
  end;

  if Assigned(gdSplash) then
    gdSplash.FreeSplash;

  if FFirstTime then
  begin
    FFirstTime := False;
    //if Assigned(IBLogin) and IBLogin.LoggedIn then
    //  PostMessage(Handle, WM_GD_RUNONLOGINMACROS, 0, 0);
  end;

  if Assigned(tbMainMenu) then
    tbMainMenu.SetFocus;
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
//���� �� ������ ��� ������ � ������� �����, �� ���������� ���� ��� ����� ��������
//��� �������� ��� ���������, ������� ����������� � ������ ������� �������� (��������, ���������� �������).

  Ttmp_ScanTemplate.Create(Self).Show;
end;

procedure TfrmGedeminMain.gsiblkupCompanyChange(Sender: TObject);
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
            (MessageBox(Handle, '��������� ������� ������� ����?', '��������', MB_YESNO or MB_ICONQUESTION) = IDYES)
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
  Index: Integer;
  CuttedCaption: String;
  Form: TForm;
begin
  Form := Sender as TForm;

  Index := GetFormToggleItemIndex(Form);
  if Index > -1 then
  begin
    if Length(Form.Caption) > 20 then
      CuttedCaption := Copy(Form.Caption, 1, 17) + '...'
    else
      CuttedCaption := Form.Caption;

    tbForms.Items[Index].Caption := CuttedCaption;
    tbForms.Items[Index].Hint := Form.Caption;
  end;
end;

procedure TfrmGedeminMain.TBItem13Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://gsbelarus.com/gs/wiki/index.php/����_����������������_VBScript',
    nil,
    nil,
    SW_SHOW);
end;

procedure TfrmGedeminMain.TBItem16Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://www.fast-report.com/ru/download/fast-report-4-download.html',
    nil,
    nil,
    SW_SHOW);
end;

procedure TfrmGedeminMain.TBItem12Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://gsbelarus.com/wiki',
    nil,
    nil,
    SW_SHOW);
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
    'http://gsbelarus.com',
    nil,
    nil,
    SW_SHOW);
end;

procedure TfrmGedeminMain.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
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
  P: Pointer;
  Form: TObject;
  ToggleItem: TTBCustomItem;
begin
  TabPos := TCrackPopupMenu(pmForms).PopupPoint;
  TabPos := tbForms.ScreenToClient(TabPos);

  if (tbForms.View <> nil) and (tbForms.View.ViewerFromPoint(TabPos) is TTBItemViewer) then
    ToggleItem := tbForms.View.ViewerFromPoint(TabPos).Item
  else
    ToggleItem := nil;

  if ToggleItem is TTBItem then
  begin
    P := Pointer(ToggleItem.Tag);

    if DetectClassInstance(P) <> nil then
    begin
      Form := TObject(P);

      if Form is TfrmGedeminProperty then
      begin
        if (Form as TfrmGedeminProperty).Restored then
          Form.Free;
      end
      else if Form is TForm then
      begin
        (Form as TForm).Close;
        Form.Free;
      end;
    end else
      tbForms.Items.Delete(tbForms.Items.IndexOf(ToggleItem));
  end;
end;

procedure TfrmGedeminMain.actHideFormExecute(Sender: TObject);
var
  TabPos: TPoint;
  F: TObject;
  P: Pointer;
  ToggleItem: TTBCustomItem;
begin
  TabPos := tbForms.ScreenToClient(TCrackPopupMenu(pmForms).PopupPoint);

  if tbForms.View.ViewerFromPoint(TabPos) <> nil then
    ToggleItem := tbForms.View.ViewerFromPoint(TabPos).Item
  else
    ToggleItem := nil;

  if ToggleItem is TTBItem then
  begin
    P := Pointer(ToggleItem.Tag);

    if DetectClassInstance(P) <> nil then
    begin
      F := TObject(P);
      if F is TForm then
        (F as TForm).Close;
    end else
      tbForms.Items.Delete(tbForms.Items.IndexOf(ToggleItem));
  end;
end;

procedure TfrmGedeminMain.actHideAllExecute(Sender: TObject);
var
  I: Integer;
  P: Pointer;
  F: TObject;
begin
  for I := 0 to tbForms.Items.Count - 1 do
  begin
    if tbForms.Items[I] is TTBItem then
    begin
      P := Pointer(tbForms.Items[I].Tag);
      if DetectClassInstance(P) <> nil then
      begin
        F := TObject(P);
        if F is TForm then
          (F as TForm).Close;
      end else
        tbForms.Items.Delete(I);
    end;
  end;
end;

procedure TfrmGedeminMain.actCloseAllExecute(Sender: TObject);
var
  I: Integer;
  Form: TObject;
  P: Pointer;
  Asked: Boolean;
begin
  Asked := False;
  for I := tbForms.Items.Count - 1 downto 0 do
  begin
    if tbForms.Items[I] is TTBItem then
    begin
      P := Pointer(tbForms.Items[I].Tag);

      if DetectClassInstance(P) = nil then
      begin
        tbForms.Items.Delete(I);
        continue;
      end;

      Form := TObject(P);

      if gdc_frmExplorer = Form then
        continue;

      if not Asked then
      begin
        if MessageBox(Handle,
          '������� ��� ����� ���������?',
          '��������',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
        begin
          Asked := True;
        end else
          break;
      end;

      if Form is TForm then
      begin
        if Form is TfrmGedeminProperty then
        begin
          if (Form as TfrmGedeminProperty).Restored then
            Form.Free;
        end else
          Form.Free;
      end;
    end;
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

procedure TfrmGedeminMain.actLoadPackageExecute(Sender: TObject);
begin
  if (GetAsyncKeyState(VK_SHIFT) shr 1) = 0 then
    ViewFormByClass('Tat_frmSyncNamespace', '', False)
  else
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
  {$IFDEF GEDEMIN_LOCK}
  if (IBLogin <> nil) and IBLogin.LoggedIn then
  begin
    actRegistration.Enabled := IBLogin.IsUserAdmin;
  end;
  {$ELSE}
  actRegistration.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actRecompileStatisticsExecute(Sender: TObject);
var
  Cr: TCursor;
  {$IFDEF WITH_INDY}
  Progress: TgdccProgress;
  {$ENDIF}
begin
  with TfrmIBUserList.Create(nil) do
  try
    if not CheckUsers then
    begin
      MessageBox(Handle,
        '���������� �������� ������ � �������������������� ������.',
        '��������',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      exit;
    end;
  finally
    Free;
  end;
  try
    {$IFDEF WITH_INDY}
    Progress := TgdccProgress.Create;
    {$ENDIF}
    try
      Cr := Screen.Cursor;
      try
        Screen.Cursor := crHourGlass;

        {$IFDEF WITH_INDY}
        Progress.StartWork('����������', '���������� ���������� �������� � �������������� ��������', 117, True, False);
        Progress.StartStep('���������� ���������� ��������', 100);
        if Progress.Canceled then
          exit;
        {$ENDIF}
        UpdateIndicesStat(gdcBaseManager.Database);

        {$IFDEF WITH_INDY}
        Progress.StartStep('�������������� ��������', 5);
        if Progress.Canceled then
          exit;
        {$ENDIF}
        RecompileProcedures(gdcBaseManager.Database);

        {$IFDEF WITH_INDY}
        Progress.StartStep('�������������� ���������', 10);
        if Progress.Canceled then
          exit;
        {$ENDIF}
        RecompileTriggers(gdcBaseManager.Database);

        {$IFDEF WITH_INDY}
        Progress.StartStep('�������������� �����', 1);
        if Progress.Canceled then
          exit;
        {$ENDIF}
        ReCreateComputedFields(gdcBaseManager.Database);

        {$IFDEF WITH_INDY}
        Progress.StartStep('�������������� �������������', 1);
        if Progress.Canceled then
          exit;
        {$ENDIF}
        ReCreateView(gdcBaseManager.Database);

        AddText('������� �������� �������');

        {$IFDEF WITH_INDY}
        Progress.EndWork;
        {$ENDIF}
      finally
        Screen.Cursor := Cr;
      end;
    finally
      {$IFDEF WITH_INDY}
      Progress.Free;
      {$ENDIF}
    end;
  except
    on E: Exception do
    begin
      AddMistake('������ � �������� ����������:');
      AddMistake(E.Message);
    end;
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
  //{$IFDEF DEBUG}
  //actSQLMonitor.Enabled := Assigned(IBLogin) and
  //  (IBLogin.IsUserAdmin or ((IBLogin.InGroup and GD_UG_POWERUSERS) <> 0));
  //{$ELSE}
  actSQLMonitor.Visible := False;
  //{$ENDIF}
end;

procedure TfrmGedeminMain.actSQLMonitorExecute(Sender: TObject);
begin
  //{$IFDEF DEBUG}
  //F := FindForm(Tgd_frmSQLMonitor);
  //if F = nil then
  //  F := Tgd_frmSQLMonitor.Create(Application);
  //F.Show;
  //{$ENDIF}
end;

procedure TfrmGedeminMain.DoDestroy;
begin
  if gdNotifierThread <> nil then
    gdNotifierThread.NotifierWindow := 0;

  inherited;

  if ExitCode = 0 then
  try
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
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKey(RegKeyName, True) then
    begin
      MessageBox(Handle,
        '������� ������� ������ Windows �� �������� ������� ��� ������ � ������.'#13#10 +
        '������� �� ��������� ��� ������� ������� � ������� ��������������.',
        '��������',
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
              S := S + ' /sn "' + edDatabase.Text + '"';

            if Trim(edUser.Text) > '' then
              S := S + ' /user "' + edUser.Text + '"';

            if Trim(edPassword.Text) > '' then
              S := S + ' /password "' + edPassword.Text + '"';

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

procedure TfrmGedeminMain.actSettingsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcNamespace', '', False);
end;

procedure TfrmGedeminMain.actSettingsUpdate(Sender: TObject);
begin
  actSettings.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actGeneratorsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcGenerator', '', False);
end;

procedure TfrmGedeminMain.actGeneratorsUpdate(Sender: TObject);
begin
  actGenerators.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actDomainsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcField', '', False);
end;

procedure TfrmGedeminMain.actDomainsUpdate(Sender: TObject);
begin
  actDomains.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actExceptionsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcException', '', False);
end;

procedure TfrmGedeminMain.actExceptionsUpdate(Sender: TObject);
begin
  actExceptions.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actViewsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcView', '', False);
end;

procedure TfrmGedeminMain.actViewsUpdate(Sender: TObject);
begin
  actViews.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actProceduresExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcStoredProc', '', False);
end;

procedure TfrmGedeminMain.actProceduresUpdate(Sender: TObject);
begin
  actProcedures.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actTablesExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcTable', '', False);
end;

procedure TfrmGedeminMain.actTablesUpdate(Sender: TObject);
begin
  actTables.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actStorageExecute(Sender: TObject);
begin
  ViewFormByClass('Tst_frmMain', '', False);
end;

procedure TfrmGedeminMain.actStorageUpdate(Sender: TObject);
begin
  actStorage.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actDocumentTypeExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcDocumentType', '', False);
end;

procedure TfrmGedeminMain.actDocumentTypeUpdate(Sender: TObject);
begin
  actDocumentType.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.actStreamSaverOptionsExecute(Sender: TObject);
begin
  with TdlgStreamSaverOptions.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmGedeminMain.actStreamSaverOptionsUpdate(Sender: TObject);
begin
  actStreamSaverOptions.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn;
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

procedure TfrmGedeminMain.actSQLProcessExecute(Sender: TObject);
begin
  {$IFDEF WITH_INDY}
  gdccClient.SendCommand(gdcc_cmd_UserShowLog);
  {$ELSE}
  if not Assigned(frmSQLProcess) then
  begin
    frmSQLProcess := TfrmSQLProcess.Create(Owner);
  end;
  frmSQLProcess.Show;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actUserGroupsExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcUserGroup', '', False);
end;

procedure TfrmGedeminMain.actUserGroupsUpdate(Sender: TObject);
begin
  actUserGroups.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actJournalExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcJournal', '', False);
end;

procedure TfrmGedeminMain.actJournalUpdate(Sender: TObject);
begin
  actJournal.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

procedure TfrmGedeminMain.actUsersExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcUser', '', False);
end;

procedure TfrmGedeminMain.actUsersUpdate(Sender: TObject);
begin
  actUsers.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and IBLogin.LoggedIn;
end;

function TfrmGedeminMain.GetFormToggleItemIndex(AForm: TForm): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := tbForms.Items.Count - 1 downto 0 do
    // �.�. ��� ����������� � � ������������, �� �������� ������ �� ���
    if (Integer(AForm) = tbForms.Items[I].Tag) and (tbForms.Items[I] is TTBItem) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TfrmGedeminMain.AddFormToggleItem(AForm: TForm);
var
  ToggleItem: TTBCustomItem;
  CutCaption: String;
begin
  if Length(AForm.Caption) > 20 then
    CutCaption := Copy(AForm.Caption, 1, 17) + '...'
  else
    CutCaption := AForm.Caption;

  // ������ �� �������
  ToggleItem := TTBItem.Create(tbForms);
  ToggleItem.Caption := CutCaption;
  //ToggleItem.ImageIndex := ImageIndex;
  ToggleItem.GroupIndex := 1;
  ToggleItem.Hint := AForm.Caption;
  ToggleItem.Tag := Integer(AForm);
  ToggleItem.AutoCheck := True;
  ToggleItem.OnClick := OnFormToggleItemClick;
  tbForms.Items.Add(ToggleItem);

  // �����������
  ToggleItem := TTBSeparatorItem.Create(tbForms);
  // �������� ���, ����� ����� ��������� ������� �����������
  ToggleItem.Tag := Integer(AForm);
  tbForms.Items.Add(ToggleItem);
end;

procedure TfrmGedeminMain.OnFormToggleItemClick(Sender: TObject);
var
  P: Pointer;
  frm: TForm;
  ToggleItem: TTBItem;
begin
  ToggleItem := Sender as TTBItem;

  P := Pointer(ToggleItem.Tag);

  if DetectClassInstance(P) <> nil then
  begin
    frm := TObject(P) as TForm;

    if FormsList.IndexOf(frm) = -1 then
      tbForms.Items.Delete(tbForms.Items.IndexOf(ToggleItem))
    else begin
      if not frm.Visible then
        frm.Show;
      frm.BringToFront;
      // ���� ����� ������� ����-�� �� ������� ������, �������� �� � �����
      if frm.Left >= (frm.Monitor.Left + frm.Monitor.Width) then
        frm.Left := frm.Monitor.Left + frm.Monitor.Width div 2;
      if frm.Top >= (frm.Monitor.Top + frm.Monitor.Height) then
        frm.Top := frm.Monitor.Top + frm.Monitor.Height div 2;

      ToggleItem.Checked := True;
    end;
  end else
    tbForms.Items.Delete(tbForms.Items.IndexOf(ToggleItem));
end;

procedure TfrmGedeminMain.actReconnectUpdate(Sender: TObject);
begin
  actReconnect.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and ((not Assigned(Screen.ActiveForm)) or ([fsModal] * Screen.ActiveForm.FormState = []))
    and (not ((FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
      (FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive)));
end;

procedure TfrmGedeminMain.actReconnectExecute(Sender: TObject);
var
  T: TDateTime;
begin
  T := Now;
  IBLogin.Relogin;
  gdNotifierThread.Add('��������������� ��������� �� ' + FormatDateTime('s.z', Now - T) + ' ���', 0, 2000);
end;

procedure TfrmGedeminMain.actDBSqueezeUpdate(Sender: TObject);
begin
  {$IFDEF DUNIT_TEST}
  actDBSqueeze.Enabled := Assigned(IBLogin)
    and Assigned(gdcBaseManager)
    and (gdcBaseManager.Database <> nil)
    and (gdcBaseManager.Database.Connected)
    and IBLogin.IsIBUserAdmin;
  {$ELSE}
  actDBSqueeze.Enabled := False;
  actDBSqueeze.Visible := False;
  {$ENDIF}
end;

procedure TfrmGedeminMain.actDBSqueezeExecute(Sender: TObject);
begin
  {$IFDEF DUNIT_TEST}
  with TgdDBSqueeze.Create do
  try
    Squeeze;
  finally
    Free;
  end;
  {$ENDIF}
end;

procedure TfrmGedeminMain.WMRunOnLoginMacros(var Msg: TMessage);
var
  TempMacros: TscrMacrosItem;
  OwnerForm: IDispatch;
begin
  Assert(Assigned(IBLogin) and IBLogin.LoggedIn);
  Assert(gdcBaseManager <> nil);

  if Assigned(ScriptFactory) and (gd_CmdLineParams.Run > '')
    and (gdcBaseManager.GetIDByRUIDString(gd_CmdLineParams.Run) > 0) then
  begin
    TempMacros := TscrMacrosItem.Create;
    try
      OwnerForm := nil;
      TempMacros.FunctionKey := gdcBaseManager.GetIDByRUIDString(gd_CmdLineParams.Run);
      ScriptFactory.ExecuteMacros(OwnerForm, TempMacros);
    finally
      TempMacros.Free;
    end;
  end;

  if gd_CmdLineParams._Exit then
    actExit.Execute;
end;

procedure TfrmGedeminMain.actDatabasesListExecute(Sender: TObject);
begin
  gd_DatabasesList.ShowViewForm(False);
end;

procedure TfrmGedeminMain.actDatabasesListUpdate(Sender: TObject);
begin
  actDatabasesList.Enabled := (gd_DatabasesList <> nil)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TfrmGedeminMain.WMRelogin(var Msg: TMessage);
begin
  actReconnect.Execute;
end;

procedure TfrmGedeminMain.WMUpdateNotification(var Msg: TMessage);
begin
  if Visible and (gdNotifierThread <> nil) then
    lblDatabase.Caption := StringReplace(gdNotifierThread.Notification, #13#10, ' ', [rfReplaceAll]);
end;

procedure TfrmGedeminMain.actReloadExecute(Sender: TObject);
begin
  PostMessage(Handle, WM_GD_RELOAD, 0, 0);
end;

procedure TfrmGedeminMain.WMReload(var Msg: TMessage);
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  FName: String;
begin
  if (Screen.ActiveCustomForm <> nil) and ((Screen.ActiveCustomForm.FormState *
    [fsModal, fsCreating, fsShowing]) <> []) then
    exit;

  FName := ExtractFilePath(Application.EXEName) + Gedemin_Updater;
  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  if CreateProcess(PChar(FName),
    PChar('"' + FName + '" ' + IntToStr(GetCurrentProcessID) +
      ' /R "' + ExtractFileName(Application.ExeName) + '" "' +
      IBLogin.UserName + '" "' + IBLogin.UserPassword + '" "' +
      IBLogin.DatabaseName + '"'),
    nil, nil, False, NORMAL_PRIORITY_CLASS or CREATE_NO_WINDOW, nil, nil,
    StartupInfo, ProcessInfo) then
  begin
    FCanClose := True;
    Close;
  end else
    MessageBox(Handle,
      PChar(SysErrorMessage(GetLastError)),
      '������',
      MB_OK or MB_ICONHAND);
end;

procedure TfrmGedeminMain.WMUserFeedback(var Msg: TMessage);
begin
  with Tgd_frmFeedback.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

(*
procedure TfrmGedeminMain.actPrepareIBANExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBLogin.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text := 'UPDATE gd_bank SET oldbankcode = bankcode WHERE oldbankcode IS NULL';
    q.ExecQuery;
    q.SQL.Text := 'UPDATE gd_bank SET oldbankMFO = bankMFO WHERE oldbankMFO IS NULL';
    q.ExecQuery;
    q.SQL.Text := 'UPDATE gd_bank SET bankcode = SWIFT, bankMFO = SWIFT WHERE SWIFT SIMILAR TO ''[A-Z]{6}([A-Z0-9]{2}|[A-Z0-9]{5})'' ' +
      'AND (NOT bankcode SIMILAR TO ''[A-Z]{6}([A-Z0-9]{2}|[A-Z0-9]{5})'')';
    q.ExecQuery;

    q.SQL.Text := 'UPDATE gd_companyaccount SET oldaccount = account WHERE oldaccount IS NULL';
    q.ExecQuery;
    q.SQL.Text := 'UPDATE gd_companyaccount SET account = iban WHERE iban SIMILAR TO ''[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{4}[A-Z0-9]{16}'' ' +
      'AND NOT (account SIMILAR TO ''[A-Z]{2}[0-9]{2}[A-Z0-9]{4}[0-9]{4}[A-Z0-9]{16}'')';
    q.ExecQuery;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;

  MessageBox(Handle,
    '����������� ������ � ������ ������� ���������� �� IBAN. �������� gedemin.exe � ����� �������� gsbelarus.com',
    '��������',
    MB_OK or MB_ICONINFORMATION);
end;

procedure TfrmGedeminMain.actPrepareIBANUpdate(Sender: TObject);
begin
  actPrepareIBAN.Enabled := (Date >= EncodeDate(2017, 07, 04))
    and (IBLogin <> nil)
    and (IBLogin.Database <> nil)
    and (IBLogin.Database.Connected)
    and (IBLogin.IsIBUserAdmin);
end;
*)

procedure TfrmGedeminMain.actDBTriggersExecute(Sender: TObject);
begin
  ViewFormByClass('TgdcDBTrigger', '', False);
end;

procedure TfrmGedeminMain.actDBTriggersUpdate(Sender: TObject);
begin
  actDBTriggers.Enabled := Assigned(IBLogin)
    and IBLogin.LoggedIn
    and IBLogin.IsUserAdmin;
end;

end.
