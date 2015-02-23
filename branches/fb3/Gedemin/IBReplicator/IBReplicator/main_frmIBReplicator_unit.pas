unit main_frmIBReplicator_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, StdCtrls, ComCtrls, rpl_BaseTypes_unit,
  ImgList, rpl_DBRegistrar_unit, TB2Dock, TB2Toolbar, TB2Item, db,
  CheckTreeView, rpl_const, rpl_mnRelations_unit, Menus, rpl_GlobalVars_unit,
  Grids, rpl_DropDownForm_unit, rpl_ProgressState_Unit, XPCheckBox, XPEdit,
  XPButton, XPRadioButton, XPComboBox, XPTreeView, XPListView, IBSQL,
  rpl_ReplicationServer_unit, DateUtils, MySpin, SpacePanel, IBDatabaseInfo,
  rpl_dmImages_unit, Registry, ZLib, ZLibConst, IBCustomDataSet, IBServices, Contnrs,
  Buttons, IBScript, jpeg;

type
  TIBReplicatorState = (rsNone, rsUpdateDBList, rsEditScheme);

  TmainIBReplicator = class(TForm)
    pBottom: TPanel;
    ActionList: TActionList;
    actExit: TAction;
    actNext: TAction;
    actPrev: TAction;
    actService: TAction;
    bHelp: TXPButton;
    bNext: TXPButton;
    bExit: TXPButton;
    actTestConect: TAction;
    OpenDialog: TOpenDialog;
    actSaveRelations: TAction;
    actLoadRelations: TAction;
    actAutoPrepareRelations: TAction;
    actSetPrimeKey: TAction;
    pmRelations: TTBPopupMenu;
    actWhatWrong: TAction;
    TBItem5: TTBItem;
    actSelectAllFields: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    TBItem8: TTBItem;
    pmService: TTBPopupMenu;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    TBItem11: TTBItem;
    actAddBase: TAction;
    actDeleteBase: TAction;
    bPrev: TXPButton;
    actDBOpen: TAction;
    actExportFile: TAction;
    actImportFile: TAction;
    actRollback: TAction;
    actConfirm: TAction;
    actAddDb: TAction;
    actEditScheme: TAction;
    actDeleteMetaData: TAction;
    actGetExportFileName: TAction;
    actGetImportFileName: TAction;
    pCaption: TSpacePanel;
    lCaption: TLabel;
    PageControl: TPageControl;
    tsConnect: TTabSheet;
    Bevel5: TBevel;
    Label10: TLabel;
    Bevel3: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel2: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label28: TLabel;
    Bevel1: TBevel;
    Label7: TLabel;
    cbDBRegisterList: TXPComboBox;
    cbServerName: TXPComboBox;
    cbProtocol: TXPComboBox;
    eDBDescription: TXPEdit;
    eUser: TXPEdit;
    ePassword: TXPEdit;
    eRole: TXPEdit;
    cbCharSet: TXPComboBox;
    mAddiditionParam: TXPMemo;
    Button5: TXPButton;
    cePath: TXPEdit;
    XPButton1: TXPButton;
    tsDBNotPrepared: TTabSheet;
    Bevel6: TBevel;
    mDbNotPrepared: TMemo;
    rbCreateMetadata: TXPRadioButton;
    rbDeleteMetadata: TXPRadioButton;
    tsReplMainInfo: TTabSheet;
    Bevel7: TBevel;
    lKeyDivider: TLabel;
    lSettelment: TLabel;
    gbPrimeKey: TGroupBox;
    lGeneratorName: TLabel;
    rbNatural: TXPRadioButton;
    rbDBUnique: TXPRadioButton;
    cbGeneratorName: TXPComboBox;
    rbRelationUnique: TXPRadioButton;
    gbReplType: TGroupBox;
    lDirection: TLabel;
    rbDualDirection: TXPRadioButton;
    rbUnoDirection: TXPRadioButton;
    cbDirection: TXPComboBox;
    eKeyDivider: TXPEdit;
    cbErrorDecision: TXPComboBox;
    tsRelations: TTabSheet;
    Bevel9: TBevel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    tvRelations: TXPTreeView;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem2: TTBItem;
    TBItem1: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem4: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem14: TTBItem;
    mState: TXPMemo;
    tsBases: TTabSheet;
    Bevel10: TBevel;
    pBaseCopy: TPanel;
    TBDock2: TTBDock;
    tbtBaseCopy: TTBToolbar;
    TBItem13: TTBItem;
    TBItem12: TTBItem;
    Panel2: TPanel;
    sgBases: TStringGrid;
    tsBeforeCreateMetaData: TTabSheet;
    Bevel11: TBevel;
    Memo1: TMemo;
    tsCreateMetaDate: TTabSheet;
    Bevel4: TBevel;
    lAction: TLabel;
    lProgress: TLabel;
    lvScript: TXPListView;
    pbCreateMetaData: TProgressBar;
    tsReport: TTabSheet;
    Bevel12: TBevel;
    mReportHead: TMemo;
    mReport: TMemo;
    tsReplCenter: TTabSheet;
    Bevel8: TBevel;
    lDBInfo: TLabel;
    mDbInfo: TXPMemo;
    btnSave: TXPButton;
    btnLoad: TXPButton;
    XPButton4: TXPButton;
    XPButton7: TXPButton;
    XPButton8: TXPButton;
    XPButton9: TXPButton;
    XPButton6: TXPButton;
    tsRplProgress: TTabSheet;
    Bevel14: TBevel;
    lLog: TLabel;
    Label11: TLabel;
    lSpeed1: TLabel;
    lSpeed: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    mLog: TXPMemo;
    pbRPLProgress: TProgressBar;
    tsExport: TTabSheet;
    Bevel13: TBevel;
    lExportDBAlias: TLabel;
    cbExportDBAlias: TXPComboBox;
    cbEnchancedExportLog: TXPCheckBox;
    tsImport: TTabSheet;
    Bevel15: TBevel;
    lblImportFileName: TLabel;
    Label16: TLabel;
    eImportFileName: TXPEdit;
    mImportFileInfo: TXPMemo;
    XPButton11: TXPButton;
    tsRollBack: TTabSheet;
    Bevel16: TBevel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    cbRollBack: TXPComboBox;
    mRollBack: TXPMemo;
    seRollback: TXPSpinEdit;
    imgWall: TImage;
    tsUserList: TTabSheet;
    Bevel18: TBevel;
    lvUser: TXPListView;
    DatabaseInfo: TIBDatabaseInfo;
    Timer: TTimer;
    tOpenReplFile: TTimer;
    XPCheckBox1: TXPCheckBox;
    actConflictResolution: TAction;
    tsConflictResolution: TTabSheet;
    Label1: TLabel;
    cbConflictResolution: TXPComboBox;
    Label20: TLabel;
    mConflictResoluion: TXPMemo;
    Bevel17: TBevel;
    mUserList: TMemo;
    XPButton12: TXPButton;
    actDBRegisterManager: TAction;
    SaveDialog: TSaveDialog;
    actRemoveField: TAction;
    actAddField: TAction;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem15: TTBItem;
    TBItem16: TTBItem;
    cbFields: TXPComboBox;
    TBControlItem1: TTBControlItem;
    lvImportFileNames: TXPListView;
    btnAddImportFile: TXPButton;
    btnDelImportFile: TXPButton;
    actAddImportFileName: TAction;
    actDelImportFileName: TAction;
    actNextError: TAction;
    actPrevError: TAction;
    TBItem17: TTBItem;
    TBItem18: TTBItem;
    actBackup: TAction;
    actRestore: TAction;
    XPButton13: TXPButton;
    XPButton14: TXPButton;
    actRecreateAllUsers: TAction;
    btnRecreateUsers: TXPButton;
    XPButton5: TXPButton;
    actExportPackage: TAction;
    tvExportDBList: TXPTreeView;
    pnlExportFileInfo: TPanel;
    Label14: TLabel;
    mDBInfo1: TXPMemo;
    lExportFileName: TLabel;
    eExportFileName: TXPEdit;
    XPButton10: TXPButton;
    btnViewLog: TXPButton;
    actViewRPLLog: TAction;
    actShowViewLogBtn: TAction;
    actViewRPLFile: TAction;
    btnViewRPLFile: TXPButton;
    SpeedButton1: TSpeedButton;
    btnSQLEditor: TXPButton;
    actSQLEditor: TAction;
    tsSQLEditor: TTabSheet;
    Bevel19: TBevel;
    Panel3: TPanel;
    TBDock3: TTBDock;
    TBToolbar2: TTBToolbar;
    TBItem19: TTBItem;
    TBItem20: TTBItem;
    memSQL: TXPMemo;
    actLoadSQL: TAction;
    actSaveSQL: TAction;
    actRunSQL: TAction;
    actCommitSQL: TAction;
    actRollBackSQL: TAction;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem21: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem22: TTBItem;
    TBItem23: TTBItem;
    IBSQL: TIBSQL;
    actEditTrigger: TAction;
    tsTriggers: TTabSheet;
    Panel4: TPanel;
    Splitter2: TSplitter;
    tvTriggers: TXPTreeView;
    Bevel20: TBevel;
    actSaveTriggerCreateDLL: TAction;
    actLoadTrigger: TAction;
    actRestoreTrigger: TAction;
    Panel5: TPanel;
    TBDock4: TTBDock;
    tbTrigger: TTBToolbar;
    tbiSaveTriggerCreateDLL: TTBItem;
    TBItem26: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem27: TTBItem;
    memTriggerBody: TXPMemo;
    actSetTrigger: TAction;
    TBSeparatorItem8: TTBSeparatorItem;
    TBItem28: TTBItem;
    actInsertRelationID: TAction;
    TBItem29: TTBItem;
    tbsiSaveTrigger: TTBSubmenuItem;
    tbiSaveTriggerAlterDLL: TTBItem;
    tbiSaveTriggerBody: TTBItem;
    actSaveTriggerAlterDLL: TAction;
    actSaveTriggerBody: TAction;
    actLoadConfirm: TAction;
    pnlPackageExport: TPanel;
    cbxPackageExport: TXPCheckBox;
    cbRelGen: TXPComboBox;
    lblDefGeneratorName: TLabel;
    cbDefGeneratorName: TXPComboBox;
    lblGeneratorMask: TLabel;
    edtGeneratorMask: TXPEdit;
    lblMaskComment: TLabel;
    procedure cePathButtonClick(Sender: TObject);
    procedure cbDBRegisterListDropDown(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure cbServerNameDropDown(Sender: TObject);
    procedure cbDBRegisterListChange(Sender: TObject);
    procedure rbUnoDirectionClick(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure rbDBUniqueClick(Sender: TObject);
    procedure cbGeneratorNameDropDown(Sender: TObject);
    procedure tvRelationsGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tvRelationsCheck(Sender: TObject; Node: TTreeNode);
    procedure actSetPrimeKeyUpdate(Sender: TObject);
    procedure actSetPrimeKeyExecute(Sender: TObject);
    procedure actWhatWrongUpdate(Sender: TObject);
    procedure actWhatWrongExecute(Sender: TObject);
    procedure actSelectAllFieldsUpdate(Sender: TObject);
    procedure actSelectAllFieldsExecute(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure tvRelationsExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure actAutoPrepareRelationsExecute(Sender: TObject);
    procedure sgBasesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgBasesGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure sgBasesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgBasesSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure actAddBaseExecute(Sender: TObject);
    procedure actDeleteBaseUpdate(Sender: TObject);
    procedure actDeleteBaseExecute(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure sgBasesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgBasesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actDeleteMetaDataExecute(Sender: TObject);
    procedure actEditSchemeExecute(Sender: TObject);
    procedure actExportFileExecute(Sender: TObject);
    procedure actGetExportFileNameExecute(Sender: TObject);
    procedure cbExportDBAliasChange(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actGetImportFileNameExecute(Sender: TObject);
    procedure actImportFileExecute(Sender: TObject);
    procedure actRollbackExecute(Sender: TObject);
    procedure cbRollBackChange(Sender: TObject);
    procedure tOpenReplFileTimer(Sender: TObject);
    procedure eImportFileNameChange(Sender: TObject);
    procedure actConflictResolutionExecute(Sender: TObject);
    procedure cbConflictResolutionChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure actDBRegisterManagerExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure actSaveRelationsExecute(Sender: TObject);
    procedure actLoadRelationsExecute(Sender: TObject);
    procedure actRemoveFieldExecute(Sender: TObject);
    procedure actAddFieldExecute(Sender: TObject);
    procedure actAddFieldUpdate(Sender: TObject);
    procedure actRemoveFieldUpdate(Sender: TObject);
    procedure actAddDbExecute(Sender: TObject);
    procedure actTestConectExecute(Sender: TObject);
    procedure lvImportFileNamesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure actDelImportFileNameExecute(Sender: TObject);
    procedure actAddImportFileNameExecute(Sender: TObject);
    procedure actDelImportFileNameUpdate(Sender: TObject);
    procedure actNextErrorExecute(Sender: TObject);
    procedure actPrevErrorExecute(Sender: TObject);
    procedure actPrevErrorUpdate(Sender: TObject);
    procedure actNextErrorUpdate(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure actBackupExecute(Sender: TObject);
    procedure actRecreateAllUsersExecute(Sender: TObject);
    procedure actAddDbUpdate(Sender: TObject);
    procedure actEditSchemeUpdate(Sender: TObject);
    procedure actExportPackageExecute(Sender: TObject);
    procedure cbxPackageExportClick(Sender: TObject);
    procedure tvExportDBListCheck(Sender: TObject; Node: TTreeNode);
    procedure eExportFileNameChange(Sender: TObject);
    procedure tvExportDBListChange(Sender: TObject; Node: TTreeNode);
    procedure actViewRPLLogExecute(Sender: TObject);
    procedure actShowViewLogBtnExecute(Sender: TObject);
    procedure actViewRPLFileExecute(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actLoadSQLExecute(Sender: TObject);
    procedure actSaveSQLExecute(Sender: TObject);
    procedure actCommitSQLUpdate(Sender: TObject);
    procedure actRollBackSQLExecute(Sender: TObject);
    procedure actCommitSQLExecute(Sender: TObject);
    procedure actRunSQLExecute(Sender: TObject);
    procedure actSQLEditorUpdate(Sender: TObject);
    procedure tvRelationsCompare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure PageControlChange(Sender: TObject);
    procedure actSaveRelationsUpdate(Sender: TObject);
    procedure actEditTriggerUpdate(Sender: TObject);
    procedure actEditTriggerExecute(Sender: TObject);
    procedure tvRelationsDblClick(Sender: TObject);
    procedure tvTriggersCheck(Sender: TObject; Node: TTreeNode);
    procedure tvTriggersCompare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure tvTriggersExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvTriggersChange(Sender: TObject; Node: TTreeNode);
    procedure actRestoreTriggerExecute(Sender: TObject);
    procedure actSetTriggerExecute(Sender: TObject);
    procedure actSetTriggerUpdate(Sender: TObject);
    procedure tvTriggersChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure actRestoreTriggerUpdate(Sender: TObject);
    procedure actInsertRelationIDExecute(Sender: TObject);
    procedure actInsertRelationIDUpdate(Sender: TObject);
    procedure actSaveTriggerExecute(Sender: TObject);
    procedure actLoadTriggerExecute(Sender: TObject);
    procedure actLoadTriggerUpdate(Sender: TObject);
    procedure cbFieldsDropDown(Sender: TObject);
    procedure tvRelationsChange(Sender: TObject; Node: TTreeNode);
    procedure tvRelationsChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
  private
    { Private declarations }
    FDBRegistrar: TDBRegistrar;

    FIBReplState: TIBReplicatorState;

    FImportFileList: TStringList;
    FExportFileList: TObjectList;

    FCanImport: Boolean;

    procedure SaveDbRegistrar;
    function  Connect: Boolean;
    function  ShutDown: boolean;
    procedure BringOnLine;

    function  PrimeKeyType: TPrimeKeyType;
    function  Direction: TReplDirection;
    function  KeyDivider: string;
    procedure UpdateScript;

    procedure LoadTree;
    procedure LoadTreeTrigger;

    procedure AssignImportFileList(slFiles: TStrings);
    procedure RefreshImportFileList;

    function  GetReplDBListItemText(ACol, ARow: Integer): string;
    procedure DropDown(Col, Row: Integer);
    procedure OnDBregistrarLoad(Sender: TObject);
    procedure DropAllMetaData;
    procedure BuildUserList;
    procedure CheckShcemaError;
    function  CheckUserCount: boolean;
    procedure SetSavePath(sName: string);
    procedure SetLoadPath(sName: string);
    function  GetSavePath: string;
    procedure SetLastConnect(sName: string);
    function  GetLastConnect: string;
    function  CreateReplFileName: string;
    {$IFDEF GEDEMIN}
    function  GetRandomString: string;
    {$ENDIF}
    function  GetExportFileIndex(Key: integer): integer;
  protected
  public
    function  GetLoadPath: string;
    procedure ReCreateAllUsers;
    function ConnectParams: string;
    function TestConnect(sSrv, sProt, sDBName, sUser, sPass, sCharSet, sRole, sPar: string): boolean;
  end;

  TCreateMetaDataProgress = class(TCustomProgressState)
  protected
    procedure SetMaxMinor(const Value: Integer); override;
  public
    procedure MajorProgress(Sender: TObject; ProgressAction: TProgressAction); override;
    procedure MinorProgress(Sender: TObject); override;
  end;

  TFileProcess = class(TCustomProgressState)
  protected
    FTimer: TTimer;
    FCount: Integer;
    FTime: TTime;
    procedure SetMaxMinor(const Value: Integer); override;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure MajorProgress(Sender: TObject; ProgressAction: TProgressAction); override;
    procedure MinorProgress(Sender: TObject); override;
    procedure Log(S: string); override;
  end;

  TCompressFileHeader = record
    Str: array[1..5] of char;
    Size: integer;
  end;

  TExportFile = class(TObject)
  private
  protected
    FDBKey: integer;
    FFileName: string;
    FDBName: string;
  public
    class function Create(ADBKey: integer): TExportFile;
    class function CreateAndAssign(ADBKey: integer; ADBName, AFileName: string): TExportFile;
    property DBKey: integer read FDBKey write FDBKey;
    property DBName: string read FDBName write FDBName;
    property FileName: string read FFileName write FFileName;
  end;

const
  ZStr: array[1..5] of char = ('Z', 'R', 'e', 'p', 'l');

var
  mainIBReplicator: TmainIBReplicator;

implementation

uses IBDataBase, rpl_ResourceString_unit, rpl_ReplicationManager_unit,
     Types, rpl_ManagerRegisterDB_unit, rpl_frmBackUp_unit,
     rpl_frmRestore_unit, rpl_ViewRPLLog_unit, rpl_ViewRPLFile_unit;

{$R *.dfm}

type
  TColIndices = (ciState, ciDBName, ciPriority);

procedure TmainIBReplicator.FormCreate(Sender: TObject);
var
  s: string;
begin
  FDBRegistrar := TDBRegistrar.Create;
  FDBRegistrar.OnLoad := OnDBregistrarLoad;

  dmImages.il16x16.Overlay(ICN_ATTENTION, OVR_ATTENTION);
  Caption := MSG_CAPTION;
  {$IFDEF GEDEMIN}
  Caption := MSG_CAPTION + GedeminEdition;
  rbDBUnique.Checked := True;
  gbPrimeKey.Enabled := False;
  cbGeneratorName.Style:= csDropDown;
  cbGeneratorName.Text:= 'GD_G_UNIQUE';
  btnRecreateUsers.Visible:= True;
  {$ENDIF}
  PageControl.ActivePage := tsConnect;
  lCaption.Caption := PageControl.ActivePage.Caption;
  FIBReplState:= rsNone;
  cbDBRegisterListDropDown(cbDBRegisterList);
  if cbDBRegisterList.Items.Count > 0 then begin
    s:= GetLastConnect;
    if (s = '') or (cbDBRegisterList.Items.IndexOf(s) < 0) then begin
      cbDBRegisterList.ItemIndex:= 0;
    end
    else begin
      cbDBRegisterList.ItemIndex:= cbDBRegisterList.Items.IndexOf(s);
    end;
    cbDBRegisterListChange(cbDBRegisterList);
  end;
end;

procedure TmainIBReplicator.FormDestroy(Sender: TObject);
begin
  FDBRegistrar.Free;
  if Assigned(FExportFileList) then
    FExportFileList.Free;
  if Assigned(FImportFileList) then
    FImportFileList.Free;
end;

procedure TmainIBReplicator.cePathButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    cePath.Text := OpenDialog.FileName;
  end;
end;
           
procedure TmainIBReplicator.cbDBRegisterListDropDown(Sender: TObject);
begin
  TXPComboBox(Sender).Items.Assign(FDBRegistrar.DBAliasList);
end;

procedure TmainIBReplicator.OnDBregistrarLoad(Sender: TObject);
begin
  with FDBRegistrar do
  begin
    cbServerName.Text := ServerName;
    cbProtocol.ItemIndex := cbProtocol.Items.IndexOf(Protocol);
    cePath.Text := FileName;
    eDBDescription.Text := Description;
    eUser.Text := User;
    ePassword.Text := Password;
    eRole.Text := Role;
    cbCharSet.ItemIndex := cbCharSet.Items.IndexOf(CharSet);
    mAddiditionParam.Lines.Text := Additional;
  end;
end;

procedure TmainIBReplicator.SaveDbRegistrar;
begin
  with FDBRegistrar do
  begin
    ServerName := cbServerName.Text;
    Protocol := cbProtocol.Text;
    FileName := cePath.Text;
    Description := eDBDescription.Text;
    User := eUser.Text;
    Password := ePassword.Text;
    Role := eRole.Text;
    CharSet := cbCharSet.Text;
    Additional := mAddiditionParam.Lines.Text;
  end;
end;

procedure TmainIBReplicator.actNextExecute(Sender: TObject);
var
  P: TCustomProgressState;
  Stream: TStream;
  ZStream: TCustomZLibStream;
  C: TCursor;
  i: integer;
  MC: TrplMakeCopy;
  bTemp: boolean;
  FileHeader: TrplStreamHeader;
  EF: TExportFile;
begin
  C := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if PageControl.ActivePage = tsConnect then
    begin
      if Connect then
      begin
        if not CheckUserCount then
          Exit;
        if not ShutDown then
          Exit;
        if not Connect then
          Exit;
        SetLastConnect(cbDBRegisterList.Text);
        if not ReplDataBase.CheckReplicationSchema then
          PageControl.ActivePage := tsDBNotPrepared
        else
        begin
          //Восстановление в.к. и триггеров.
          { TODO :
          Нужно добавить проверку необходимости восстановления
          метаданных }
          PageControl.ActivePage := tsRplProgress;
          PageControl.ActivePage.Caption := MSG_RESTOREDB_CAPTION;
          lLog.Caption := MSG_LOG_RESTORING_METADATA;
          mLog.Lines.Clear;
          P := TFileProcess.Create;
          try
            ProgressState := P;

            if not ReplicationServer.RestoreDB then begin
              Application.MessageBox(PChar(ERR_CANT_RESTORE_DB),
                PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
              PageControl.ActivePage := tsConnect;
              ReplDataBase.Connected:= False;
              Exit;
            end;
          finally
            ProgressState := nil;
            P.Free;
          end;

          PageControl.ActivePage := tsReplCenter;
          mDbInfo.Lines.Clear;
          mDbInfo.Lines.Add(MSG_REPORT_READING_DBINFO);
          Application.ProcessMessages;

          mDbInfo.Lines.BeginUpDate;
          try
            mDbInfo.Lines.Clear;
            ReplDataBase.GetDBReport(mDbInfo.Lines);
          finally
            mDbInfo.Lines.EndUpdate;
          end;

          case ReplDataBase.DataBaseInfo.Direction of
            rdToServer: begin
                if ReplDataBase.DataBaseInfo.DBState = dbsMain then begin
                  btnSave.Action:= actConfirm;
                  btnLoad.Action:= actImportFile;
                end
                else begin
                  btnSave.Action:= actExportFile;
                  btnLoad.Action:= actLoadConfirm;
                end;
              end;
            rdFromServer: begin
                if ReplDataBase.DataBaseInfo.DBState = dbsMain then begin
                  btnSave.Action:= actExportFile;
                  btnLoad.Action:= actLoadConfirm;
                end
                else begin
                  btnSave.Action:= actConfirm;
                  btnLoad.Action:= actImportFile;
                end;
              end;
            rdDual: begin
                btnSave.Action:= actExportFile;
                btnLoad.Action:= actImportFile;
              end;
          end;
        end;
      end;
    end else
    if PageControl.ActivePage = tsDBNotPrepared then
    begin
      if not CheckUserCount then Exit;
      if rbCreateMetadata.Checked then begin
        {$IFDEF INTKEY }
          {$IFNDEF GEDEMIN}
            rbRelationUnique.Checked:= True;
          {$ENDIF}
        {$ENDIF}
        PageControl.ActivePage := tsReplMainInfo;
      end
      else
        DropAllMetaData;
    end else
    if PageControl.ActivePage = tsReplMainInfo then
    begin
      ReplicationManager.PrimeKeyType := PrimeKeyType;
      if ReplicationManager.PrimeKeyType = ptUniqueInDb then begin
        if cbGeneratorName.Text = '' then begin
          Application.MessageBox(PChar(ERR_GENERATOR_DB_NOT_SELECT),
            PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
          Exit;
        end;
        ReplicationManager.GeneratorName := cbGeneratorName.Text;
      end
      else if ReplicationManager.PrimeKeyType = ptUniqueInRelation then begin
        if cbDefGeneratorName.Text = '' then begin
          Application.MessageBox(PChar(ERR_GENERATOR_DEF_NOT_SELECT),
            PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
          Exit;
        end;
        ReplicationManager.GeneratorName := cbDefGeneratorName.Text;
        ReplicationManager.GeneratorMask := edtGeneratorMask.Text;
      end;

      ReplicationManager.Direction := Direction;

      ReplicationManager.KeyDivider := KeyDivider;

      ReplicationManager.ErrorDecision := TErrorDecision(cbErrorDecision.ItemIndex);

      LoadTree;

      PageControl.ActivePage := tsRelations;
    end else
    if PageControl.ActivePage = tsRelations then
    begin
      if ReplicationManager.Relations.ErrorCount = 0 then
      begin
        LoadTreeTrigger;
        ReplicationManager.Relations.Prepare;
        PageControl.ActivePage := tsTriggers;
      end;
    end else
    if PageControl.ActivePage = tsTriggers then
    begin
      if ReplicationManager.Relations.ErrorCount = 0 then
      begin
        if ReplicationManager.ErrorDecision = edPriority then
          sgBases.ColCount := 3
        else
          sgBases.ColCount := 2;

        sgBases.RowCount := ReplicationManager.DBList.Count + 1;

        PageControl.ActivePage := tsBases;
      end;
    end else
    if PageControl.ActivePage = tsBases then
    begin
      PageControl.ActivePage := tsBeforeCreateMetaData;
    end else
    if PageControl.ActivePage = tsBeforeCreateMetaData then
    begin
      if not CheckUserCount then Exit;
      PageControl.ActivePage := tsCreateMetaDate;
      lCaption.Caption := PageControl.ActivePage.Caption;

      if FIBReplState = rsUpdateDBList then begin
        with ReplicationManager do begin
          Script.Clear;
          Script.AddClause(TrplUpdateReplDBList.Create);
          for i := 0 to DBList.Count - 1 do begin
            if (DBList.ItemsByIndex[i].DBState <> dbsMain) and
                (DBListOld.IndexOf(IntToStr(DBList.ItemsByIndex[i].DBKey)) < 0) then begin
              MC := TrplMakeCopy.Create;
              MC.Destination := DBList.ItemsByIndex[i].DBName;
              Script.AddClause(MC);
            end;
          end;
        end;
      end
      else begin
        ReplicationManager.CreateMetaData;
      end;

      UpdateScript;

      P := TCreateMetaDataProgress.Create;
      try
        ProgressState := P;
        ReplicationManager.Script.Execute;
      finally
        P.Free;
        ProgressState := nil;
      end;

      PageControl.ActivePage := tsReport;

      if Errors.Count = 0 then
      begin
        mReport.Lines.BeginUpdate;
        try
          ReplicationManager.GetReport(mReport.Lines);
        finally
          mReport.Lines.EndUpdate;
        end;
      end else
      begin
        tsReport.Caption := MSG_REPORT_CAPTION_ERROR;
        lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
        mReportHead.Lines.Text := MSG_CREATE_METADATA_ERROR;
        mReport.Lines.Assign(Errors);
      end;
      FIBReplState:= rsNone;
    end else
    if PageControl.ActivePage = tsExport then
    begin
      if (not cbxPackageExport.Checked and (cbExportDBAlias.ItemIndex > - 1) and (eExportFileName.Text > '')) or
         (cbxPackageExport.Checked and (FExportFileList.Count > 0)) then
      begin
        mLog.Lines.Clear;
        PageControl.ActivePage := tsRplProgress;
        lCaption.Caption := MSG_EXPORT_DATA_CAPTION;
        lLog.Caption := MSG_LOG_REPLICATION;
        P := TFileProcess.Create;
        if not cbxPackageExport.Checked then begin
          if not Assigned(FExportFileList) then
            FExportFileList:= TObjectList.Create
          else
            FExportFileList.Clear;
          EF:= TExportFile.CreateAndAssign(Integer(cbExportDBAlias.Items.Objects[cbExportDBAlias.ItemIndex]),
            cbExportDBAlias.Text, eExportFileName.Text);
          FExportFileList.Add(EF);
        end;
        try
          ProgressState := P;
          bTemp:= False;
          for i:= 0 to FExportFileList.Count - 1 do begin
            ProgressState.Log(Format(MSG_START_EXPORT_DB, [TExportFile(FExportFileList[i]).DBName]));
            Stream := TFileStream.Create(TExportFile(FExportFileList[i]).FFileName, fmOpenReadWrite or fmCreate);
            ZStream := TCompressionStream.Create(clMax, Stream);
            try
              if btnSave.Action = actExportFile then
                bTemp:= ReplicationServer.ExportData(ZStream, TExportFile(FExportFileList[i]).DBKey)
              else
                bTemp:= ReplicationServer.ExportConfirm(ZStream, TExportFile(FExportFileList[i]).DBKey)
            finally
              ZStream.Free;
              Stream.Free;
            end;
            if not bTemp then
              Break;
            ProgressState.Log(Format(MSG_END_EXPORT_DB, [TExportFile(FExportFileList[i]).FFileName]));
          end;
          if bTemp then begin
            lCaption.Caption := MSG_REPORT_CAPTION_SUCCES;
            if btnSave.Action = actExportFile then
              mReportHead.Lines.Text := MSG_REPORT_EXPORT_SUCCES
            else
              mReportHead.Lines.Text := MSG_REPORT_EXPORT_CONFIRM_SUCCES;
            mReport.Lines.Clear;
          end
          else begin
            lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
            if btnSave.Action = actExportFile then
              mReportHead.Lines.Text := MSG_REPORT_EXPORT_UNSUCCES
            else
              mReportHead.Lines.Text := MSG_REPORT_EXPORT_CONFIRM_UNSUCCES;
            mReport.Lines.Assign(Errors);
          end;
          PageControl.ActivePage := tsReport;
        finally
          P.Free;
          ProgressState := nil;
        end;
      end;
    end else
    if PageControl.ActivePage = tsImport then
    begin
      if FCanImport then begin
        if not CheckUserCount then Exit;
        if AskQuestion(QuestionBackupDatabase) then begin
          ReplDataBase.Connected:= False;
          try
            Application.CreateForm(TfrmBackup, frmBackup);
            frmBackup.ShowModal;
            frmBackup.Free;
          finally
            Connect;
          end;
        end;
        mLog.Lines.Clear;
        PageControl.ActivePage := tsRplProgress;
        lCaption.Caption := MSG_IMPORT_DATA_CAPTION;
        lLog.Caption := MSG_LOG_REPLICATION;
        P := TFileProcess.Create;
        try
          ProgressState := P;
          bTemp:= False;
          for i:= 0 to FImportFileList.Count - 1 do begin
            ProgressState.Log(Format(MSG_START_REPL_FILE, [FImportFileList[i]]));
            Stream:= TFileStream.Create(FImportFileList[i], fmOpenRead);
            ZStream:= TDecompressionStream.Create(Stream);
            try
              if btnLoad.Action = actImportFile then
                bTemp:= ReplicationServer.ImportData(ZStream)
              else
                bTemp:= ReplicationServer.ImportConfirm(ZStream)
            finally
              ZStream.Free;
              Stream.Free;
            end;
            if bTemp then begin
              FileHeader:= (FImportFileList.Objects[i] as TrplStreamHeader);
              if ReplDatabase.ReplKey(FileHeader.DBKey) < FileHeader.LastProcessReplKey + 1 then
                  ReplDatabase.SetReplKey(FileHeader.DBKey, FileHeader.LastProcessReplKey + 1);
            end
            else
              Break;
            ProgressState.Log(Format(MSG_END_REPL_FILE, [FImportFileList[i]]));
          end;
          if bTemp then
          begin
            lCaption.Caption := MSG_REPORT_CAPTION_SUCCES;
            if btnLoad.Action = actImportFile then
              mReportHead.Lines.Text := MSG_REPORT_IMPORT_SUCCES
            else
              mReportHead.Lines.Text := MSG_REPORT_IMPORT_CONFIRM_SUCCES;
            mReport.Lines.Clear;
          end else
          begin
            lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
            if btnLoad.Action = actImportFile then
              mReportHead.Lines.Text := MSG_REPORT_IMPORT_UNSUCCES
            else
              mReportHead.Lines.Text := MSG_REPORT_IMPORT_CONFIRM_UNSUCCES;
            mReport.Lines.Assign(Errors);
          end;
          PageControl.ActivePage := tsReport;
        finally
          P.Free;
          ProgressState := nil;
        end;
      end;
    end else
    if PageControl.ActivePage = tsRollBack then
    begin
      if ReplicationServer.RollBack(Integer(cbRollBack.Items.Objects[cbRollBack.ItemIndex]),
        seRollback.Value) then
      begin
        PageControl.ActivePage := tsReport;
        lCaption.Caption := MSG_REPORT_CAPTION_SUCCES;
        mReportHead.Lines.Text := MSG_ROLLBACK_TRANSACTION_SUCCES;
        mReport.Lines.Clear;
      end else
      begin
        PageControl.ActivePage := tsReport;
        lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
        mReportHead.Lines.Text := MSG_ROLLBACK_TRANSACTION_ERROR;
        mReport.Lines.Clear;
        mReport.Lines.Assign(Errors);
      end;
    end else
    if PageControl.ActivePage = tsConflictResolution then
    begin
      if cbConflictResolution.ItemIndex > -1 then
      begin
        if not CheckUserCount then Exit;
        if ReplDatabase.ConflictCount(Integer(cbConflictResolution.Items.Objects[cbConflictResolution.ItemIndex])) = 0 then Exit;
        mLog.Lines.Clear;
        PageControl.ActivePage := tsRplProgress;
        lCaption.Caption := MSG_IMPORT_DATA_CAPTION;
        lLog.Caption := MSG_LOG_REPLICATION;
        P := TFileProcess.Create;
        try
          ProgressState := P;
          if ReplicationServer.ConflictResolution(Integer(cbConflictResolution.Items.Objects[cbConflictResolution.ItemIndex])) then
          begin
            lCaption.Caption := MSG_REPORT_CAPTION_SUCCES;
            mReportHead.Lines.Text := MSG_REPORT_IMPORT_SUCCES;
            mReport.Lines.Clear;
          end else
          begin
            lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
            mReportHead.Lines.Text := MSG_REPORT_IMPORT_UNSUCCES;
            mReport.Lines.Assign(Errors);
          end;
          PageControl.ActivePage := tsReport;
        finally                                      
          P.Free;
          ProgressState := nil;
        end;
      end;
    end;

    lCaption.Caption := PageControl.ActivePage.Caption;
  finally
    Screen.Cursor := C;
  end;
end;

function TmainIBReplicator.ConnectParams: string;
begin
  Result := '';
  Result := 'user_name=' + Trim(eUser.Text) + #10#13'password=' +
    Trim(ePassword.Text) + #10#13'lc_ctype=' + Trim(cbCharSet.Text);
  if Length(Trim(eRole.Text)) > 0 then
    Result := Result + #10#13'sql_role_name=' + Trim(eRole.Text);
  if Length(Trim(mAddiditionParam.Lines.Text)) > 0 then
    Result := Result + #10#13 + Trim(mAddiditionParam.Lines.Text);
end;

function TmainIBReplicator.TestConnect(sSrv, sProt, sDBName, sUser, sPass, sCharSet, sRole, sPar: string): boolean;
var
  Db: TIBDataBase;
  sParams, sError: string;
begin
  Result:= False;
  sError:= '';
  if (Trim(sSrv) = '') and (Trim(sProt) <> prLocal)   then
    sError := EnterServerName
  else
  if Trim(sProt) = '' then
    sError := EnterProtocol
  else
  if Trim(sDBName) = '' then
    sError := EnterDataBaseFileName
  else
  if Trim(sUser) = '' then
    sError := EnterUserName
  else
  if Trim(sPass) = '' then
    sError := EnterPassword
  else
  if Trim(sCharSet) = '' then
    sError := EnterCharset;

  if (sError <> '') and gvAskQuestion then begin
    Application.MessageBox(PChar(sError),
      PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
    Exit;
  end;

  Db:= TIBDataBase.Create(nil);
  DB.LoginPrompt := False;
  DB.DatabaseName := GetDataBaseName(sSrv, sDBName, sProt);;
  sParams:= 'user_name=' + sUser + #10#13'password=' + sPass  + #10#13'lc_ctype=' + sCharSet;
  if sRole <> '' then
    sParams:= sParams + #10#13'sql_role_name=' + sRole;
  if sPar <> '' then
    sParams:= sParams + #10#13 + sPar;
  DB.Params.Text := sParams;
  try
    DB.Connected := True;
  except
    on E: Exception do
      if gvAskQuestion then
        Application.MessageBox(PChar(E.Message),
          PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
  end;
  Result := DB.Connected;
  DB.Free;
end;

function TmainIBReplicator.Connect: Boolean;
var
  Db: TIBDataBase;
begin
  Result := False;
  SaveDbRegistrar;
  if FDBRegistrar.CheckRegisterInfo then
  begin
    DB:= ReplDataBase;
    DB.Connected:= False;
    DB.Params.Text := ConnectParams;
    DB.LoginPrompt := False;
    DB.DatabaseName := FDBRegistrar.DataBaseName;
    try
      DB.Connected := True;
      FDBRegistrar.SaveToRegister;
    except
      on E: Exception do
        Application.MessageBox(PChar(E.Message),
          PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
    end;
    Result := DB.Connected;
    if Result then
    begin
      ReplDataBase.ServerName := cbServerName.Text;
      ReplDataBase.FileName := cePath.Text;
      ReplDataBase.Protocol := cbProtocol.Text;

      DataBaseInfo.Database :=ReplDataBase;
    end;
  end else
    Application.MessageBox(PChar(FDBRegistrar.CheckRegisterInfoErrorMessage),
      PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
end;

procedure TmainIBReplicator.cbServerNameDropDown(Sender: TObject);
begin
  TCustomComboBox(Sender).Items.Assign(FDBRegistrar.ServerList);
end;

procedure TmainIBReplicator.cbDBRegisterListChange(Sender: TObject);
begin
  FDBRegistrar.Alias := cbDBRegisterList.Text;
end;

procedure TmainIBReplicator.rbUnoDirectionClick(Sender: TObject);
begin
  lDirection.Enabled := rbUnoDirection.Checked;
  cbDirection.Enabled := rbUnoDirection.Checked;
  if rbUnoDirection.Checked then
    cbDirection.ItemIndex:= 0
  else
    cbDirection.ItemIndex:= -1
end;

procedure TmainIBReplicator.actExitExecute(Sender: TObject);
begin
  BringOnLine;
  Application.Terminate;
end;

procedure TmainIBReplicator.rbDBUniqueClick(Sender: TObject);
begin
  lGeneratorName.Enabled:= rbDBUnique.Checked;
  cbGeneratorName.Enabled:= rbDBUnique.Checked;
  lblDefGeneratorName.Enabled:= rbRelationUnique.Checked;
  cbDefGeneratorName.Enabled:= rbRelationUnique.Checked;
  lblGeneratorMask.Enabled:= rbRelationUnique.Checked;
  edtGeneratorMask.Enabled:= rbRelationUnique.Checked;
  lblMaskComment.Enabled:= rbRelationUnique.Checked;
  if edtGeneratorMask.Enabled then
    edtGeneratorMask.Font.Color:= clBlack
  else
    edtGeneratorMask.Font.Color:= clSilver;
end;

procedure TmainIBReplicator.cbGeneratorNameDropDown(Sender: TObject);
var
  CB: TXPComboBox;
begin
  CB := Sender as TXPComboBox;
  ReplDataBase.GetGeneratorList(CB.Items);
end;

function TmainIBReplicator.PrimeKeyType: TPrimeKeyType;
begin
  if rbNatural.Checked then
    Result := ptNatural
  else
  if rbRelationUnique.Checked then
    Result := ptUniqueInRelation
  else
    Result := ptUniqueInDb      
end;

function TmainIBReplicator.Direction: TReplDirection;
begin
  if rbDualDirection.Checked then
    Result:= rdDual
  else
    Result:= TReplDirection(cbDirection.ItemIndex)
end;

function TmainIBReplicator.KeyDivider: string;
begin
  { TODO : Реализовать }
  Result := #5;
end;

procedure TmainIBReplicator.UpdateScript;
var
  LI: TListItem;
  Strings: TStrings;
  I: Integer;
begin
  lvScript.Items.BeginUpdate;
  try
    lvScript.Items.Clear;

    Strings := TStringList.Create;
    try
      ReplicationManager.Script.Register(Strings);
      for I := 0 to Strings.Count - 1 do
      begin
        LI := lvScript.Items.Add;
        LI.Caption := Strings[I];
        LI.Data := Strings.Objects[I];
        LI.ImageIndex := - 1;
      end;
    finally
      Strings.Free;
    end;
  finally
    lvScript.Items.EndUpdate;
  end;
end;

procedure TmainIBReplicator.LoadTree;
var
  I: Integer;
  R:  TTreeNode;
  Wrap: TmnCustomRelationWrap;
  s: string;
begin
  tvRelations.Items.BeginUpdate;
  try
    tvRelations.Items.Clear;
    for I := 0 to ReplicationManager.Relations.Count - 1 do
    begin
      s:= '';
      {$IFDEF GEDEMIN}
        if ReplicationManager.Relations[I].RelationName <>
            ReplicationManager.Relations[I].RelationLocalName then
          s:= ' (' + ReplicationManager.Relations[I].RelationLocalName + ')';
      {$ENDIF}
      s:= ReplicationManager.Relations[I].RelationName + s;
      R := tvRelations.Items.AddObject(nil, s, ReplicationManager.Relations[I]);
      R.HasChildren := True;

      Wrap := TmnRelationWrap.Create;
      Wrap.WrappedObject := ReplicationManager.Relations[I];
      Wrap.Node := TCheckTreeNode(R);
    end;
  finally
    tvRelations.Items.EndUpdate;
  end;
end;

procedure TmainIBReplicator.tvRelationsGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Data <> nil then
  begin
    Node.ImageIndex := TmnCustomRelationWrap(Node.Data).ImageIndex;
    Node.SelectedIndex := TmnCustomRelationWrap(Node.Data).SelectImageIndex;
    Node.OverlayIndex := TmnCustomRelationWrap(Node.Data).OverlayIndex;
  end;
end;

procedure TmainIBReplicator.tvRelationsCheck(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Data <> nil then
  begin
    TmnCustomRelationWrap(Node.Data).OnNodeClick(Sender, Node);
    tvRelations.Invalidate;
  end;
  CheckShcemaError;
end;

procedure TmainIBReplicator.actSetPrimeKeyUpdate(Sender: TObject);
var
  A: TAction;
  B: Boolean;
begin
  A := TAction(Sender);
  B := (tvRelations.Selected <> nil) and
    (tvRelations.Selected.Data <> nil) and
    (TObject(tvRelations.Selected.Data) is TmnFieldWrap) {and
    (TmnFieldWrap(tvRelations.Selected.Data).Field.Unique)};
  A.Enabled := B;
  A.Checked := B and TmnFieldWrap(tvRelations.Selected.Data).Field.IsKey;
end;

procedure TmainIBReplicator.actSetPrimeKeyExecute(Sender: TObject);
var
  R: TmnRelation;
  F: TmnField;
  I, Index: Integer;
  B: Boolean;
  U: TrpUniqueIndex;
begin
  F := TmnFieldWrap(tvRelations.Selected.Data).Field;
  R := TmnRelation(F.Relation);

  B := F.IsKey;

{  for I := 0 to R.Fields.Count - 1 do
  begin
    if TmnField(R.Fields[I]).IsKey then
      TmnField(R.Fields[I]).IsKey := False;
  end;}

  Index := R.UniqueIndices.IndexOfByField(F.FieldName);
  if Index > - 1 then
  begin
    U := R.UniqueIndices[Index];
    if U.Fields.Count > 1 then
    begin
    end;
    for I := 0 to U.Fields.Count - 1 do
    begin
      TmnField(U.Fields[I]).IsKey := not B;
    end;
  end else
    F.IsKey := not B;

  CheckShcemaError;
  tvRelations.Invalidate;
end;

procedure TmainIBReplicator.actWhatWrongUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (tvRelations.Selected <> nil) and
    (tvRelations.Selected.Data <> nil);
end;

procedure TmainIBReplicator.actWhatWrongExecute(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvRelations.Selected;
  if not Assigned(tn) then
    Exit;
  while Assigned(tn.Parent) do
    tn:= tn.Parent;
  ShowMessage(TmnCustomRelationWrap(tn.Data).ErrorMessage);
end;

procedure TmainIBReplicator.actSelectAllFieldsUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (tvRelations.Selected <> nil) and
    (tvRelations.Selected.Data <> nil) and
    (TmnCustomRelationWrap(tvRelations.Selected.Data) is TmnRelationWrap);
end;

procedure TmainIBReplicator.actSelectAllFieldsExecute(Sender: TObject);
var
  R: TmnRelation;
  I: Integer;
begin
  R := TmnRelation((TmnCustomRelationWrap(tvRelations.Selected.Data) as TmnRelationWrap).WrappedObject);
  for I := 0 to R.Fields.Count - 1 do
  begin
    TmnField(R.Fields[i]).Checked := True;
  end;
end;

procedure TmainIBReplicator.bHelpClick(Sender: TObject);
var
  P: TPoint;
begin
  P := pBottom.ClientToScreen(Point(bHelp.Left, bHelp.Top + bHelp.Height));
  pmService.Popup(P.X, p.Y)
end;

procedure TmainIBReplicator.tvRelationsExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  J: Integer;
  N, F: TTreeNode;
  Wrap: TmnCustomRelationWrap;
  Relation: TmnRelation;
{$IFNDEF GEDEMIN}
  R, G: TTreeNode;
  Gen: TGenerator;
{$ENDIF}
begin
  if (Node.Data <> nil) and (TObject(Node.Data) is TmnRelationWrap) and
    (Node.Count = 0) then
  begin
    tvRelations.Items.BeginUpdate;
    try
      Relation := TmnRelation(TmnRelationWrap(Node.Data).WrappedObject);

      {$IFDEF GEDEMIN}
        F:= Node;
      {$ELSE}
        R := Node;
        if cbRelGen.Items.Count = 0 then
          cbGeneratorNameDropDown(cbRelGen);

        G:= tvRelations.Items.AddChild(R, RelationGenerator);
        G.Data:= Relation.Generator;

        Wrap:= TmnGeneratorWrap.Create;
        Wrap.WrappedObject := Relation.Generator;
        Wrap.Node:= TCheckTreeNode(G);
        Wrap.Node.ShowChecked:= False;
        TmnGeneratorWrap(Wrap).GeneratorList:= cbRelGen;

        F := tvRelations.Items.AddChild(R, RelationFields);
      {$ENDIF}

      for J := 0 to Relation.Fields.Count - 1 do
      begin
        N := tvRelations.Items.AddChild(F,
          TmnField(Relation.Fields[J]).Caption);

        N.Data := Relation.Fields[J];

        Wrap := TmnFieldWrap.Create;
        Wrap.WrappedObject := Relation.Fields[J];
        Wrap.Node := TCheckTreeNode(N);

        {$IFNDEF GEDEMIN}
          if Relation.Fields[J].IsPrimeKey then begin
            case ReplicationManager.PrimeKeyType of
              ptUniqueInDb: begin
                  Relation.GeneratorName:= ReplicationManager.GeneratorName;
                  G.Text:= RelationGenerator + ReplicationManager.GeneratorName;
                end;
              ptUniqueInRelation: begin
                  Gen.Name:= Copy(Format(ReplicationManager.GeneratorMask,
                    [Relation.RelationName, Relation.Fields[J].FieldName]), 1, 31);
                  if ReplDataBase.GeneratorExist(Gen) then begin
                    Relation.GeneratorName:= Gen.Name;
                    G.Text:= RelationGenerator + Gen.Name;
                  end
                  else begin
                    Relation.GeneratorName:= ReplicationManager.GeneratorName;
                    G.Text:= RelationGenerator + ReplicationManager.GeneratorName;
                  end
                end;
              ptNatural:;
            end;
            if (Relation.Fields[J].FieldType <> tfInteger) then
              G.Text:= RelationGeneratorCant;
          end;
        {$ENDIF}


        { TODO :
        Установка соответствия для полей вход. в первичный ключ
        должна происходить автоматически, если в качестве ключа
        выбран альтернативный ключ }
(*        if (Relation.Fields[J].IsForeign){ or (Relation.Fields[J].IsPrimeKey) }and
          (Relation.Fields[J].FieldType = tfInteger) then
        begin
          N := tvRelations.Items.AddChild(N, SetConformity);
          N.Data := Relation.Fields[J];

          Wrap := TmnFieldConformityWrap.Create;
          Wrap.WrappedObject := Relation.Fields[J];
          Wrap.Node := TCheckTreeNode(N);
        end;*)
      end;

{      F := tvRelations.Items.AddChild(R, RelationTriggers);

      N := tvRelations.Items.AddChild(F, TmnTrigger(Relation.TriggerAI).TriggerName);
      N.Data := Relation.TriggerAI;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAI;
      Wrap.Node := TCheckTreeNode(N);

      N := tvRelations.Items.AddChild(F, TmnTrigger(Relation.TriggerAU).TriggerName);
      N.Data := Relation.TriggerAU;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAU;
      Wrap.Node := TCheckTreeNode(N);

      N := tvRelations.Items.AddChild(F, TmnTrigger(Relation.TriggerAD).TriggerName);
      N.Data := Relation.TriggerAD;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAD;
      Wrap.Node := TCheckTreeNode(N);}
    finally
      tvRelations.Items.EndUpdate;
    end;
  end;
end;

procedure TmainIBReplicator.actAutoPrepareRelationsExecute(
  Sender: TObject);
var
  I, J: Integer;
  B: Boolean;
  R: TmnRelation;
  F: TmnField;
begin
  B := gvAskQuestion;
  mState.Lines.BeginUpdate;
  try
    gvAskQuestion := False;
    try
      for I := 0 to ReplicationManager.Relations.Count - 1 do
      begin
        R := TmnRelation(ReplicationManager.Relations[I]);
        {$IFDEF GEDEMIN}
          if Pos(';' + R.RelationName + ';', ExcludedRelations) > 0 then Continue;
        {$ENDIF}
        R.Checked := True;
        for J := 0 to R.Fields.Count - 1 do
        begin
          F := TmnField(R.Fields[J]);
          {$IFDEF GEDEMIN}
            if F.IsForeign then
              if Pos(';' + F.ReferenceField.Relation.RelationName + ';', ExcludedRelations) > 0 then Continue;
          {$ENDIF}
          F.Checked := True;
        end;
      end;
    finally
      gvAskQuestion := B;
    end;
  finally
    mState.Lines.EndUpdate;
  end;

  CheckShcemaError;
end;

procedure TmainIBReplicator.sgBasesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Text: string;
  R: TRect;
  Color, FontColor: TColor;
  C: TCanvas;
begin
  Text := '';
  R := Rect;
  C := TStringGrid(Sender).Canvas;
  if ARow = 0 then
  begin
    case TColIndices(ACol) of
      ciState: Text := cap_DBState;
      ciDBName: Text := cap_DBName;
      ciPriority: Text := cap_DBPriority;
    end;
  end else
  begin
    Text := GetReplDBListItemText(ACol, ARow);
  end;

  if TColIndices(ACol) = ciPriority then
  begin
    if State * [gdFocused, gdSelected]  <> [] then
    begin
      R.Left := R.Right - (R.Bottom - R.Top);
      DrawFrameControl(C.Handle, R, DFC_SCROLL, DFCS_SCROLLDOWN + DFCS_FLAT);
      R := Rect;
      R.Right := R.Right - (R.Bottom - R.Top);
    end;
  end;

  if State * [gdFocused] <> [] then
  begin
    C.DrawFocusRect(R);
    InflateRect(R, -1, -1);
  end;

  Color := C.Brush.Color;
  FontColor := C.Font.Color;
  C.Brush.Style := bsSolid;
  C.Brush.Color := TStringGrid(Sender).Color;
  C.FillRect(R);
  if State * [gdFixed] <> [] then
  begin
    C.Brush.Color := TStringGrid(Sender).FixedColor;
  end else
  begin
    if (State * [gdSelected] <> []) and (sgBases.Focused) then
    begin
      C.Brush.Color := clHighlight;
      C.Font.Color := clHighlightText;
    end else
    begin
      C.Brush.Color := clWindow;
      C.Font.Color := clWindowText
    end;
  end;

  C.TextRect(R, R.Left + 1, R.Top + 1, Text);
  C.Brush.Color := Color;
  C.Font.Color := FontColor;
end;

function TmainIBReplicator.GetReplDBListItemText(ACol,
  ARow: Integer): string;
var
  DB: TreplicationDB;
  Text: string;
begin
  Text := '';
  if ARow - 1 < ReplicationManager.DBList.Count then
  begin
    DB := ReplicationManager.DBList.ItemsByIndex[ARow - 1];
    case TColIndices(ACol) of
      ciState:
      begin
        case DB.DBState of
          dbsMain: Text := dbs_Main;
          dbsSecondary: Text := dbs_Secondary;
        end;
      end;
      ciDBName:
      begin
        Text := DB.DBName;
      end;
      ciPriority:
      begin
        case TrplPriority(DB.Priority) of
          prHighest: Text := dbp_Highest;
          prHigh: Text := dbp_High;
          prNormal: Text := dbp_Normal;
          prLow: Text := dbp_Low;
          prLowest: Text := dbp_Lowest;
        end;
      end;
    end;
  end;
  Result := Text;
end;

procedure TmainIBReplicator.sgBasesGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  Value := GetReplDBListItemText(ACol, ARow);
end;

procedure TmainIBReplicator.sgBasesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if TColIndices(ACol) = ciPriority then
    TStringGrid(Sender).Options := TStringGrid(Sender).Options - [goEditing]
  else
    TStringGrid(Sender).Options := TStringGrid(Sender).Options + [goEditing];
end;

procedure TmainIBReplicator.sgBasesSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  DB: PReplicationDB;
begin
  if ARow - 1 < ReplicationManager.DBList.Count then
  begin
    DB := ReplicationManager.DBList.Items[ARow - 1];
    case TColIndices(ACol) of
      ciDBName: DB^.DBName := Value;
    end;
  end;
end;

procedure TmainIBReplicator.actAddBaseExecute(Sender: TObject);
var
  DB: PReplicationDB;
  MainDBName: string;
begin
  sgBases.RowCount := sgBases.RowCount + 1;
  New(DB);
  with DB^ do
  begin
    DBState := dbsSecondary;
    DBKey := GetNewDBID;

    MainDbName := ReplicationManager.DBList.MainDb.DBName;
    DBName := ReplicationManager.DBList.GetUniqueDBName(Format('Copy_%s', [MainDBName]));

    Priority := Integer(prLow);

    ReplKey := DefaultReplKey;
    LastProcessReplKey := DefaultLastProcessReplKey;
  end;

  sgBases.Row := ReplicationManager.DBList.Add(DB) + 1;
  sgBases.Col := Integer(ciDBName);
  if not sgBases.Focused then sgBases.SetFocus;
end;

procedure TmainIBReplicator.actDeleteBaseUpdate(Sender: TObject);
var
  Row: Integer;
  DB: TReplicationDB;
  A: TAction;
begin
  A := TAction(Sender);
  Row := sgBases.Row;
  if Row - 1 < ReplicationManager.DBList.Count then
  begin
    DB := ReplicationManager.DBList.ItemsByIndex[Row - 1];
    A.Enabled := DB.DBState = dbsSecondary;
  end else
    A.Enabled := False;
end;

type
  TCrackGrid = class(TCustomGrid);

procedure TmainIBReplicator.actDeleteBaseExecute(Sender: TObject);
var
  Row: Integer;
begin
  Row := sgBases.Row;
  if AskQuestion(Question_On_Delete_Base) then
  begin
    TCrackGrid(sgBases).DeleteRow(Row);
    if Row - 1 < ReplicationManager.DBList.Count then
      ReplicationManager.DBList.Delete(Row - 1);
  end;
end;

procedure TmainIBReplicator.actPrevExecute(Sender: TObject);
var
  tv: TXPTreeView;
  i: integer;
begin
  if PageControl.ActivePage = tsRelations then begin
    cbRelGen.Visible:= False;
    tv:= tvRelations;
  end
  else if PageControl.ActivePage = tsTriggers then
    tv:= tvTriggers
  else
    tv:= nil;
  if Assigned(tv) then
    for i:= 0 to tv.Items.Count - 1 do
      if Assigned(tv.Items[i].Data) and
          (TObject(tv.Items[i].Data) is TmnCustomRelationWrap)  and
          not (TObject(tv.Items[i].Data) is TmnRelationWrap) then
//      ShowMessage(IntToStr(i + 1) + ' из ' + IntToStr(tv.Items.Count) + #13#10 + tv.Items[i].Text);
        TmnCustomRelationWrap(tv.Items[i].Data).Free;

  if PageControl.ActivePage = tsReport then
  begin
    PageControl.ActivePage := tsConnect;
  end else
  if PageControl.ActivePage = tsReplCenter then
  begin
    PageControl.ActivePage := tsConnect
  end else
  if PageControl.ActivePage = tsExport then
  begin
    PageControl.ActivePage := tsReplCenter;
  end else
  if PageControl.ActivePage = tsImport then
  begin
    PageControl.ActivePage := tsReplCenter;
  end else
  if PageControl.ActivePage = tsRollBack then
  begin
    PageControl.ActivePage := tsReplCenter
  end else
  if PageControl.ActivePage = tsUserList then
  begin
    PageControl.ActivePage := tsConnect
  end else
  if PageControl.ActivePage = tsConflictResolution then
  begin
    PageControl.ActivePage := tsReplCenter;
  end else
  if PageControl.ActivePage = tsBases then
  begin
    if FIBReplState = rsUpdateDBList then begin
      FIBReplState:= rsNone;
      PageControl.ActivePage := tsReplCenter;
    end
    else
      PageControl.ActivePage:= tsTriggers;
  end else
  if (PageControl.ActivePage = tsReplMainInfo) and (FIBReplState = rsEditScheme) then
  begin
    FIBReplState:= rsNone;
    PageControl.ActivePage := tsReplCenter;
  end else
  if PageControl.ActivePage = tsSQLEditor then begin
    PageControl.ActivePage:= tsConnect;
  end else
  if PageControl.ActivePage = tsTriggers then begin
    PageControl.ActivePage:= tsRelations;
  end
  else
    PageControl.ActivePageIndex := PageControl.ActivePageIndex - 1;

  if PageControl.ActivePage = tsConnect then
  begin
    PageControl.Invalidate;
    BringOnLine;
    ReplDataBase.Connected := False;
  end;
  lCaption.Caption := PageControl.ActivePage.Caption;
end;

procedure TmainIBReplicator.sgBasesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Row, Col: Integer;
begin
  sgBases.MouseToCell(X, Y, Col, Row);
  if (Row - 1 < ReplicationManager.DBList.Count) and
    (TColIndices(Col) = ciPriority) and (Button = mbLeft) and (Row > 0) then
  begin
    DropDown(Col, Row);
  end;
end;

procedure TmainIBReplicator.DropDown(Col, Row: Integer);
var
  R: TRect;
  F: TDropDownForm;
  DB: PReplicationDb;
const
  DropDownCount = 5;
begin
  R := sgBases.CellRect(Col, Row);
  R.TopLeft := sgBases.ClientToScreen(R.TopLeft);
  R.BottomRight := sgBases.ClientToScreen(R.BottomRight);
  DB := ReplicationManager.DBList.Items[Row - 1];
  F := TDropDownForm.Create(Self);
  try
    F.Top := R.Bottom;
    F.Left := R.Left;
    F.Width := R.Right - R.Left;
    F.DropDownCount := DropDownCount;

    with F.ListBox do
    begin
      AddItem(dbp_Highest, Pointer(Integer(prHighest)));
      AddItem(dbp_High, Pointer(Integer(prHigh)));
      AddItem(dbp_Normal, Pointer(Integer(prNormal)));
      AddItem(dbp_Low, Pointer(Integer(prLow)));
      AddItem(dbp_Lowest, Pointer(Integer(prLowest)));
      ItemIndex := Items.IndexOfObject(Pointer(DB^.Priority));
    end;

    if F.ShowModal = mrOk then
    begin
      DB^.Priority := Integer(F.ListBox.Items.Objects[F.ListBox.ItemIndex])
    end;
  finally
    F.Free;
  end;
end;

procedure TmainIBReplicator.sgBasesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Col, Row: Integer;
begin
  if Key = VK_F4 then
  begin
    Row := sgBases.Row;
    Col := sgBases.Col;
    if (Row - 1 < ReplicationManager.DBList.Count) and
    (TColIndices(Col) = ciPriority) and (Row > 0) then
    begin
      DropDown(Col, Row);
    end;
  end;
end;

{ TCreateMetaDataProgress }

procedure TCreateMetaDataProgress.MajorProgress(Sender: TObject; ProgressAction: TProgressAction);
var
  S: TrplBaseScriptClause;
begin
  S := TrplBaseScriptClause(Sender);
  case ProgressAction of
    paBefore:
    begin
      mainIBReplicator.lvScript.Items[S.Index].ImageIndex := 187;
      Application.ProcessMessages;
    end;
    paSucces:
    begin
      mainIBReplicator.lvScript.Items[S.Index].ImageIndex := 214;
      Application.ProcessMessages;
    end;
    paError:
    begin
      mainIBReplicator.lvScript.Items[S.Index].ImageIndex := 117;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TCreateMetaDataProgress.MinorProgress(Sender: TObject);
begin
  mainIBReplicator.pbCreateMetaData.Position :=
    mainIBReplicator.pbCreateMetaData.Position + 1; 
end;

procedure TCreateMetaDataProgress.SetMaxMinor(const Value: Integer);
begin
  mainIBReplicator.pbCreateMetaData.Min := 0;
  mainIBReplicator.pbCreateMetaData.Max := Value;
  mainIBReplicator.pbCreateMetaData.Position := 0;
  inherited;
end;

procedure TmainIBReplicator.actDeleteMetaDataExecute(Sender: TObject);
begin
  if AskQuestion(MSG_WANT_DROP_METADATA) then
  begin
    DropAllMetaData;
  end;
end;

procedure TmainIBReplicator.DropAllMetaData;
var
  P: TCreateMetaDataProgress;
begin
  if CheckUserCount then
  begin
    ReplicationManager.DropAllMetaData;
    UpdateScript;

    PageControl.ActivePage := tsCreateMetaDate;
    lCaption.Caption := MSG_DROP_METADATA_CAPTION;

    P := TCreateMetaDataProgress.Create;
    try
      ProgressState := P;
      ReplicationManager.Script.Execute;
    finally
      P.Free;
      ProgressState := nil;
    end;

    PageControl.ActivePage := tsReport;

    if Errors.Count =  0 then
    begin
      tsReport.Caption := MSG_REPORT_CAPTION_SUCCES;
      lCaption.Caption := MSG_REPORT_CAPTION_SUCCES;
      mReportHead.Lines.Text := MSG_METADATA_DELETE_SUCCES;
      mReport.Lines.Text := Format(MSG_REPORT_DATE, [DateTimeToStr(Now)]);
    end else
    begin
      tsReport.Caption := MSG_REPORT_CAPTION_ERROR;
      lCaption.Caption := MSG_REPORT_CAPTION_ERROR;
      mReportHead.Lines.Text := MSG_METADATA_DELETE_ERROR;
      mReport.Lines.Assign(Errors);
    end;
  end;  
end;

procedure TmainIBReplicator.actEditSchemeExecute(Sender: TObject);
var
  I: Integer;
  DB: PReplicationDB;
begin
  if AskQuestion(MSG_WANT_EDIT_METADATA) then
  begin
    PageControl.ActivePage := tsReplMainInfo;
    for I := 0 to ReplicationManager.DBList.Count - 1 do
    begin
      Db := PReplicationDB(ReplicationManager.DBList.Items[I]);
      DB^.LastProcessReplKey := DefaultLastProcessReplKey;
      DB^.ReplKey := DefaultReplKey;
    end;
    FIBReplState:= rsEditScheme
  end;
end;

procedure TmainIBReplicator.actExportFileExecute(Sender: TObject);
var
  I: Integer;
  DB: TReplicationDB;
begin
  cbxPackageExport.Checked:= False;
  actExportPackage.Execute;
  PageControl.ActivePage := tsExport;
  lCaption.Caption := btnSave.Caption;

  if btnSave.Action = actExportFile then begin
    lExportDBAlias.Caption:= CAPTION_DBALIAS_EXPORT;
    lExportFileName.Caption:= CAPTION_FILENAME_EXPORT;
  end
  else begin
    lExportDBAlias.Caption:= CAPTION_DBALIAS_CONFIRM;
    lExportFileName.Caption:= CAPTION_FILENAME_EXPORT_CONFIRM;
  end;

  eExportFileName.Text := '';
  mDBInfo1.Lines.Clear;

  pnlPackageExport.Visible:=
    (ReplDataBase.DataBaseInfo.DBState = dbsMain) and (ReplDataBase.DBList.Count > 2);

  cbExportDBAlias.Items.BeginUpdate;
  try
    cbExportDBAlias.Items.Clear;
    for I := 0 to ReplDataBase.DBList.Count - 1 do
    begin
      if ReplDataBase.DBList.ItemsByIndex[i].DBKey <>
        ReplDataBase.DataBaseInfo.DBID then
      begin
        DB := ReplDataBase.DBList.ItemsByIndex[I];
        cbExportDBAlias.Items.AddObject(DB.DBName, Pointer(DB.DBKey));
      end;
    end;
  finally
    cbExportDBAlias.Items.EndUpdate;
  end;

  if cbExportDBAlias.Items.Count = 1 then
  begin
    cbExportDBAlias.ItemIndex := 0;
    cbExportDBAliasChange(cbExportDBAlias);
  end else
    cbExportDBAlias.ItemIndex:= -1;

end;

procedure TmainIBReplicator.actGetExportFileNameExecute(Sender: TObject);
var
  S: TSaveDialog;
begin
  S := TSaveDialog.Create(Application);
  try
    S.Filter := ReplFileFilter;
    S.FilterIndex := 0;
    S.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    S.DefaultExt := '*.rpl';
    S.InitialDir:= GetSavePath;
    S.FileName:= eExportFileName.Text;
    if S.Execute then begin
      eExportFileName.Text := S.FileName;
      SetSavePath(S.FileName);
    end;
  finally
    S.Free;
  end;
end;

{ TFileProcess }

constructor TFileProcess.Create;
begin
  inherited;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := True;
  FTimer.Interval := 1000;
end;

destructor TFileProcess.Destroy;
begin
  FTimer.Free;
end;

procedure TFileProcess.Log(S: string);
begin
  mainIBReplicator.mLog.Lines.Add(S);
end;

procedure TFileProcess.MajorProgress(Sender: TObject;
  ProgressAction: TProgressAction);
begin
  inherited;
end;

procedure TFileProcess.MinorProgress(Sender: TObject);
var
  Msg: TMsg;
begin
  mainIBReplicator.pbRPLProgress.Position :=
    mainIBReplicator.pbRPLProgress.Position + 1;
  Inc(FCount);
  if PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE) then
  begin
    Application.ProcessMessages;
  end;
end;

procedure TFileProcess.OnTimer(Sender: TObject);
begin
  mainIBReplicator.lSpeed.Caption := IntToStr(FCount);
  case FCount of
    0..100: mainIBReplicator.lSpeed.Font.Color := clRed;
    101..300: mainIBReplicator.lSpeed.Font.Color := clYellow;
  else
    mainIBReplicator.lSpeed.Font.Color := clGreen;
  end;
  FCount := 0;
  FTime := IncMilliSecond(FTime, FTimer.Interval);
  mainIBReplicator.Label13.Caption := TimeToStr(FTime);
  Application.ProcessMessages;
end;

procedure TFileProcess.SetMaxMinor(const Value: Integer);
begin
  mainIBReplicator.pbRPLProgress.Min := 0;
  mainIBReplicator.pbRPLProgress.Max := Value;
  mainIBReplicator.pbRPLProgress.Position := 0;
  FCount := 0;
  inherited;
end;

procedure TmainIBReplicator.cbExportDBAliasChange(Sender: TObject);
var
  DBKey: Integer;
begin
  if cbxPackageExport.Checked then Exit;
  mDbInfo1.Lines.Clear;
  mDbInfo1.Lines.Add(MSG_REPORT_READING_DBINFO);
  Application.ProcessMessages;
  mDBInfo1.Lines.BeginUpdate;
  try
    if cbExportDBAlias.ItemIndex > - 1 then begin
      eExportFileName.Text:= CreateReplFileName;
      DBKey := Integer(cbExportDBAlias.Items.Objects[cbExportDBAlias.ItemIndex]);
      mDbInfo1.Lines.Clear;
      ReplDataBase.GetShortDbReport(mDbInfo1.Lines, DBKey);
    end;
  finally
    mDBInfo1.Lines.EndUpdate;
  end;
end;

procedure TmainIBReplicator.actNextUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ((PageControl.ActivePage <> tsReplCenter) and
    (PageControl.ActivePage <> tsSQLEditor) and
    (PageControl.ActivePage <> tsReport) and (PageControl.ActivePage <> tsUserList))
    or ((PageControl.ActivePage = tsUserList) and (lvUser.Items.Count <= 1));
  {$IFDEF INTKEY}
    TAction(Sender).Enabled:= TAction(Sender).Enabled and
      not (rbNatural.Checked and (PageControl.ActivePage = tsReplMainInfo));
  {$ENDIF}
end;

procedure TmainIBReplicator.actGetImportFileNameExecute(Sender: TObject);
var
  O: TOpenDialog;
begin
  O := TOpenDialog.Create(nil);
  try
    O.Filter := ReplFileFilter;
    O.FilterIndex := 0;
    O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing, ofAllowMultiSelect];
    O.InitialDir:= GetLoadPath;
    if O.Execute then
    begin
      AssignImportFileList(O.Files);
      SetLoadPath(O.FileName);
    end;
  finally
    O.Free;
  end;
end;

procedure TmainIBReplicator.actImportFileExecute(Sender: TObject);
begin
  PageControl.ActivePage := tsImport;
  lCaption.Caption := btnLoad.Caption;
  if btnLoad.Action = actImportFile then
    lblImportFileName.Caption:= CAPTION_FILENAME_IMPORT
  else
    lblImportFileName.Caption:= CAPTION_FILENAME_IMPORT_CONFIRM;
  eImportFileName.Text := '';
  mImportFileInfo.Lines.Clear;
  FCanImport := False;
  RefreshImportFileList;
end;

procedure TmainIBReplicator.actRollbackExecute(Sender: TObject);
var
  I: Integer;
  DB: TReplicationDB;
begin
  PageControl.ActivePage := tsRollBack;
  lCaption.Caption := tsRollBack.Caption;
  mRollBack.Lines.Clear;

  cbRollBack.Items.BeginUpdate;
  try
    cbRollBack.Items.Clear;
    for I := 0 to ReplDataBase.DBList.Count - 1 do
    begin
      if ReplDataBase.DBList.ItemsByIndex[i].DBKey <>
        ReplDataBase.DataBaseInfo.DBID then
      begin
        DB := ReplDataBase.DBList.ItemsByIndex[I];
        cbRollBack.Items.AddObject(DB.DBName, Pointer(DB.DBKey));
      end;
    end;
  finally
    cbRollBack.Items.EndUpdate;
  end;

  if cbRollBack.Items.Count = 1 then
  begin
    cbRollBack.ItemIndex := 0;
    cbRollBackChange(cbRollBack);
  end else
    cbRollBack.ItemIndex:= -1;

end;

procedure TmainIBReplicator.cbRollBackChange(Sender: TObject);
var
  DBKey: Integer;
begin
  mRollBack.Lines.Clear;
  mRollBack.Lines.Add(MSG_REPORT_READING_DBINFO);
  Application.ProcessMessages;
  mRollBack.Lines.BeginUpdate;
  try
    if cbRollBack.ItemIndex > - 1 then
    begin
      DBKey := Integer(cbRollBack.Items.Objects[cbRollBack.ItemIndex]);
      mRollBack.Lines.Clear;
      ReplDataBase.GetShortDbReport(mRollBack.Lines, DBKey);
      seRollback.MaxValue := ReplDataBase.NotCommitedTransaction(DBKey);
      if seRollback.MaxValue > 0 then
      begin
        seRollback.MinValue := 1;
        seRollback.Value := 1;
      end;
    end;
    seRollback.Enabled := (cbRollBack.ItemIndex > - 1) and
      (seRollback.MaxValue > 0);
  finally
    mRollBack.Lines.EndUpdate;
  end;
end;

procedure TmainIBReplicator.BuildUserList;
var
  List: TStringList;
  I, K: Integer;
  ListItem: TListItem;
  {$IFDEF GEDEMIN}
  SQL: TIBSQL;
  {$ENDIF}
begin
  if (lvUser.Items.Count > 0) and Assigned(lvUser.Selected) then
    K := lvUser.Selected.Index
  else
    K := -1;
  {$IFDEF GEDEMIN}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.ReadTransaction;
    SQL.SQl.Text := 'SELECT NAME, FULLNAME FROM GD_USER WHERE IBNAME = :IBNAME ';
  {$ENDIF}
    with lvUser.Items do
    begin
      BeginUpdate;
      Clear;
      Timer.Enabled := False;
      List := TStringList.Create;

      try
        List.Assign(DatabaseInfo.UserNames);

        for I := 0 to List.Count - 1 do
        begin
          {$IFDEF GEDEMIN}
          SQL.ParamByName('IBNAME').AsString := List[I];
          SQL.ExecQuery;
          {$ENDIF}
          ListItem := Add;
          ListItem.Caption := List[I];
          {$IFDEF GEDEMIN}
          if SQL.RecordCount > 0  then
            ListItem.SubItems.Add(SQL.FieldByName('NAME').AsString)
          else
            ListItem.SubItems.Add('Неизвестный пользователь!');

          SQL.Close;
          {$ENDIF}
        end;
      finally
        Timer.Enabled := True;
        EndUpdate;
        List.Free;
      end;
    end;

    if K > 0 then
    begin

      if lvUser.Items.Count > K then
        lvUser.Selected := lvUser.Items[K]
      else
        lvUser.Selected := lvUser.Items[lvUser.Items.Count - 1];

      if Assigned(lvUser.Selected) then
        lvUser.Selected.Focused := True;
    end;
  {$IFDEF GEDEMIN}
  finally
    SQL.Free;
  end;
  {$ENDIF}
end;

procedure TmainIBReplicator.tOpenReplFileTimer(Sender: TObject);
begin
  mImportFileInfo.Lines.BeginUpdate;
  try
    mImportFileInfo.Lines.Clear;
    TTimer(Sender).Enabled := False;
    FCanImport := ReplDataBase.GetreplFileInfo(mImportFileInfo.Lines, eImportFileName.Text);
  finally
    mImportFileInfo.Lines.EndUpdate;
  end;
end;

procedure TmainIBReplicator.eImportFileNameChange(Sender: TObject);
begin
  if Assigned(FImportFileList) then
    tOpenReplFile.Enabled:= not (FImportFileList.Count > 1)
  else begin
    tOpenReplFile.Enabled:= True;
    FCanImport := False;
  end;
end;

procedure TmainIBReplicator.CheckShcemaError;
var
  I: Integer;
  R: TmnRelation;
begin
  mState.Lines.BeginUpdate;
  try
    mState.Lines.Clear;

    if ReplicationManager.Relations.ErrorCount = 0 then
      mState.Lines.Add(ERR_OK)
    else
    begin
      mState.Lines.Add(ERR_THERE_ARE_ERRORS);
      for I := 0 to ReplicationManager.Relations.Count - 1 do
      begin
        R := TmnRelation(ReplicationManager.Relations[I]);
        if R.ErrorCode <> ERR_CODE_OK then
        begin
          mState.Lines.Add(Format(MSG_RELATION + ':', [R.RelationName]));
          mState.Lines.Add(ShiftString(R.ErrorMessage, 4));
        end;
      end;
    end;
  finally
    mState.Lines.EndUpdate;
  end;
end;

procedure TmainIBReplicator.actConflictResolutionExecute(Sender: TObject);
var
  I: Integer;
  DB: TReplicationDB;
begin
  PageControl.ActivePage := tsConflictResolution;
  lCaption.Caption := tsConflictResolution.Caption;
  mConflictResoluion.Lines.Clear;

  cbConflictResolution.Items.BeginUpdate;
  try
    cbConflictResolution.Items.Clear;
    for I := 0 to ReplDataBase.DBList.Count - 1 do
    begin
      if ReplDataBase.DBList.ItemsByIndex[i].DBKey <>
        ReplDataBase.DataBaseInfo.DBID then
      begin
        DB := ReplDataBase.DBList.ItemsByIndex[I];
        cbConflictResolution.Items.AddObject(DB.DBName, Pointer(DB.DBKey));
      end;
    end;
  finally
    cbConflictResolution.Items.EndUpdate;
  end;

  if cbConflictResolution.Items.Count = 1 then
  begin
    cbConflictResolution.ItemIndex := 0;
    cbConflictResolutionChange(cbConflictResolution);
  end else
    cbConflictResolution.ItemIndex:= -1;
end;

procedure TmainIBReplicator.cbConflictResolutionChange(Sender: TObject);
var
  DBKey: Integer;
begin
  mConflictResoluion.Lines.Clear;
  mConflictResoluion.Lines.Add(MSG_REPORT_READING_DBINFO);
  Application.ProcessMessages;
  mConflictResoluion.Lines.BeginUpdate;
  try
    if cbConflictResolution.ItemIndex > - 1 then
    begin
      DBKey := Integer(cbConflictResolution.Items.Objects[cbConflictResolution.ItemIndex]);
      mConflictResoluion.Lines.Clear;
      ReplDataBase.GetShortDbReport(mConflictResoluion.Lines, DBKey);
    end;
  finally
    mConflictResoluion.Lines.EndUpdate;
  end;
end;

function TmainIBReplicator.CheckUserCount: Boolean;
var
  C: TCursor;
begin
  Result := True;
  BuildUserList;
  if lvUser.Items.Count > 1 then
  begin
    C := Screen.Cursor;
    try
      Screen.Cursor := crDefault;
      PageControl.ActivePage := tsUserList;
      repeat
        try
          Application.HandleMessage;
        except
          Application.HandleException(Application);
        end;
      until (lvUser.Items.Count <= 1) or (Application.Terminated) or
        (PageControl.ActivePage <> tsUserList);
      Result := (lvUser.Items.Count <= 1) and not Application.Terminated and
        (PageControl.ActivePage = tsUserList);
    finally
      Screen.Cursor := C;
    end;
  end;
end;

procedure TmainIBReplicator.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := PageControl.ActivePage = tsUserList;
  if Timer.Enabled then
  begin
    BuildUserList;
  end;
end;

procedure TmainIBReplicator.actDBRegisterManagerExecute(Sender: TObject);
var
  F: TfrmManagerRegisterDB;
begin
  F := TfrmManagerRegisterDB.Create(nil);
  try
    if F.ShowModal = mrOk then begin
      cbDBRegisterListDropDown(cbDBRegisterList);
      cbDBRegisterList.ItemIndex:= cbDBRegisterList.Items.IndexOf(F.eDBDescription.Text);
      cbDBRegisterListChange(cbDBRegisterList);
    end;
  finally
    F.Free;
  end;
end;

procedure TmainIBReplicator.actPrevUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := PageControl.ActivePage <> tsConnect;
end;

procedure TmainIBReplicator.actSaveRelationsExecute(Sender: TObject);
var
  tnNode: TTreeNode;
  Rel: TmnRelation;
  slData: TStringList;
  s: string;
  i: integer;
  SD: TSaveDialog;
begin
  slData:= TStringList.Create;
  SD:= TSaveDialog.Create(nil);
  try
    SD.Filter := ReplSchemaFileFilter;
    SD.FilterIndex := 0;
    SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    if SD.Execute then begin
      tnNode:= tvRelations.Items.GetFirstNode;
      while Assigned(tnNode) do begin
        Rel:= TmnRelation(TmnRelationWrap(tnNode.Data).WrappedObject);
        if Rel.Checked then begin
          s:= '';
          slData.Add(Rel.RelationName);
          for i:= 0 to Rel.Fields.Count - 1 do begin
            if TmnField(Rel.Fields[i]).Checked then begin
              s:= s + TmnField(Rel.Fields[i]).Caption + ',';
            end;
          end;
          slData.Add(s);
        end;
        tnNode:= tnNode.GetNextSibling;
      end;
      slData.SaveToFile(SD.FileName);
    end;
  finally
    slData.Free;
    SD.Free;
  end;
end;

procedure TmainIBReplicator.actSaveRelationsUpdate(Sender: TObject);
var
  tnNode: TTreeNode;
begin
  tnNode:= tvRelations.Items.GetFirstNode;
  while Assigned(tnNode) do begin
    if Assigned(tnNode.Data) and (TmnRelationWrap(tnNode.Data).WrappedObject is TmnRelation) and
        TmnRelation(TmnRelationWrap(tnNode.Data).WrappedObject).Checked then begin
      (Sender as TAction).Enabled:= True;
      Exit;
    end;
    tnNode:= tnNode.GetNextSibling;
  end;
  (Sender as TAction).Enabled:= False;
end;

procedure TmainIBReplicator.actLoadRelationsExecute(Sender: TObject);
var
  Rel: TmnRelation;
  slData: TStringList;
  i, iPos, j: integer;
  O: TOpenDialog;
  bAQ: boolean;
begin
  O := TOpenDialog.Create(nil);
  slData:= TStringList.Create;
  bAQ:= gvAskQuestion;
  gvAskQuestion:= False;
  try
    O.Filter := ReplSchemaFileFilter;
    O.FilterIndex := 0;
    O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    if O.Execute then begin
      slData.LoadFromFile(O.FileName);
      for i:= 0 to ReplicationManager.Relations.Count - 1 do begin
        Rel:= ReplicationManager.Relations[i];
        iPos:= slData.IndexOf(Rel.RelationName) + 1;
        Rel.Checked:= (iPos > 0);
        for j:= 0 to Rel.Fields.Count - 1 do begin
          TmnField(Rel.Fields[j]).Checked:= (Pos(TmnField(Rel.Fields[j]).Caption, slData[iPos]) > 0)
        end;
      end;
    end;
  finally
    slData.Free;
    O.Free;
    gvAskQuestion:= bAQ;
  end;
end;

procedure TmainIBReplicator.actAddFieldUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (cbFields.Text <> '');
end;

procedure TmainIBReplicator.actRemoveFieldUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (cbFields.Text <> '');
end;

procedure TmainIBReplicator.actRemoveFieldExecute(Sender: TObject);
var
  i, j: integer;
  Rel: TmnRelation;
begin
  for i:= 0 to ReplicationManager.Relations.Count - 1 do begin
    Rel:= ReplicationManager.Relations[i];
    for j:= 0 to Rel.Fields.Count - 1 do begin
      if TmnField(Rel.Fields[j]).Caption = cbFields.Text then
        TmnField(Rel.Fields[j]).Checked:= False;
    end;
  end;
end;

procedure TmainIBReplicator.actAddFieldExecute(Sender: TObject);
var
  i, j: integer;
  Rel: TmnRelation;
begin
  for i:= 0 to ReplicationManager.Relations.Count - 1 do begin
    Rel:= ReplicationManager.Relations[i];
    for j:= 0 to Rel.Fields.Count - 1 do begin
      if TmnField(Rel.Fields[j]).FieldName = cbFields.Text then
        TmnField(Rel.Fields[j]).Checked:= True;
    end;
  end;
end;

function TmainIBReplicator.GetLoadPath: string;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        Result:= R.ReadString(cLoadPath);
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

function TmainIBReplicator.GetSavePath: string;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        Result:= R.ReadString(cSavePath);
        if Result = '' then begin
          Result:= ExtractFilePath(ReplDataBase.FileName);
          R.WriteString(cSavePath, Result);
        end;
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TmainIBReplicator.SetLoadPath(sName: string);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        R.WriteString(cLoadPath, ExtractFilePath(sName));
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TmainIBReplicator.SetSavePath(sName: string);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        R.WriteString(cSavePath, ExtractFilePath(sName));
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TmainIBReplicator.actAddDbExecute(Sender: TObject);
var
  i: integer;
begin
  ReplicationManager.DBList.LoadAll;
  sgBases.RowCount := ReplicationManager.DBList.Count + 1;
  for i:= 0 to ReplicationManager.DBList.Count - 1 do begin
    ReplicationManager.DBListOld.Add(IntToStr(ReplicationManager.DBList.ItemsByIndex[i].DBKey));
  end;
  FIBReplState:= rsUpdateDBList;
  PageControl.ActivePage := tsBases;
end;

procedure TmainIBReplicator.actTestConectExecute(Sender: TObject);
begin
  if TestConnect(cbServerName.Text, cbProtocol.Text, cePath.Text, eUser.Text,
      ePassword.Text, cbCharSet.Text, eRole.Text, mAddiditionParam.Lines.Text) then
    Application.MessageBox(PChar(DataBaseTestConnectSucces),
      PChar(ConnectionTest), MB_OK + MB_APPLMODAL + MB_ICONASTERISK);
end;

procedure TmainIBReplicator.AssignImportFileList(slFiles: TStrings);
var
  F, ZF: TStream;
  Header: TrplStreamHeader;
  i, j: Integer;
  bNeed: boolean;
begin
  if not Assigned(FImportFileList) then
    FImportFileList:= TStringList.Create;
  while FImportFileList.Count > 0 do begin
    if Assigned(FImportFileList.Objects[0]) then
      FImportFileList.Objects[0].Free;
    FImportFileList.Delete(0);
  end;

  for i:= 0 to slFiles.Count - 1 do begin
    F := TFileStream.Create(slFiles[i], fmOpenRead);
    ZF:= TDecompressionStream.Create(F);
    try
      if SysUtils.FileExists(slFiles[i]) then begin
        Header := TrplStreamHeader.Create;
        try
          try
            try
              Header.LoadFromStream(ZF);
            except
              raise Exception.Create(Format(ERR_ON_READING_FILE, [slFiles[i]]));
            end;

            bNeed:= True;
            for j:= 0 to FImportFileList.Count - 1 do begin
              if Assigned(FImportFileList.Objects[j]) then begin
                if (FImportFileList.Objects[j] as TrplStreamHeader).ReplKey >= Header.ReplKey then begin
                  FImportFileList.InsertObject(j, slFiles[i], Header);
                  bNeed:= False;
                  Break;
                end;
              end;
            end;
            if bNeed then
              FImportFileList.AddObject(slFiles[i], Header);
          except
            on E: Exception do begin
            end;
          end;
        finally
//          Header.Free;
        end;
      end;
    finally
      ZF.Free;
      F.Free;
    end;
  end;
  RefreshImportFileList;
end;

procedure TmainIBReplicator.lvImportFileNamesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  sl: TStringList;
begin
  if lvImportFileNames.Tag = 0 then begin
    eImportFileName.Text := Item.Caption;
    if lvImportFileNames.ItemIndex > -1 then begin
      sl:= TStringList(lvImportFileNames.Items[lvImportFileNames.ItemIndex].Data);
      if Assigned(sl) then
        mImportFileInfo.Lines.Assign(sl);
    end
  end;
end;

procedure TmainIBReplicator.actDelImportFileNameExecute(Sender: TObject);
begin
  (FImportFileList.Objects[lvImportFileNames.ItemIndex] as TrplStreamHeader).Free;
  FImportFileList.Delete(lvImportFileNames.ItemIndex);
  RefreshImportFileList;
end;

procedure TmainIBReplicator.actAddImportFileNameExecute(Sender: TObject);
begin
  ;
end;

procedure TmainIBReplicator.actDelImportFileNameUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= lvImportFileNames.ItemIndex > -1
end;

procedure TmainIBReplicator.RefreshImportFileList;
var
  i, LastReplKey: Integer;
  LI: TListItem;
  FileHeader: TrplStreamHeader;
begin
  if not Assigned(FImportFileList) or (FImportFileList.Count = 0) then Exit;
  lvImportFileNames.Tag:= 1;
  eImportFileName.Visible:= not (FImportFileList.Count > 1);
  lvImportFileNames.Visible:= (FImportFileList.Count > 1);
  btnAddImportFile.Visible:= (FImportFileList.Count > 1);
  btnDelImportFile.Visible:= (FImportFileList.Count > 1);
  tOpenReplFile.Enabled:= not (FImportFileList.Count > 1);
  if FImportFileList.Count > 1 then begin
    if btnLoad.Action = actImportFile then
      lblImportFileName.Caption:= CAPTION_FILENAMES_IMPORT
    else
      lblImportFileName.Caption:= CAPTION_FILENAMES_IMPORT_CONFIRM;
    Label16.Top:= 103;
    mImportFileInfo.Top:= 119;
  end
  else begin
    if btnLoad.Action = actImportFile then
      lblImportFileName.Caption:= CAPTION_FILENAME_IMPORT
    else
      lblImportFileName.Caption:= CAPTION_FILENAME_IMPORT_CONFIRM;
    Label16.Top:= 47;
    mImportFileInfo.Top:= 63;
    eImportFileName.Text := FImportFileList[0];
    tOpenReplFileTimer(tOpenReplFile);
  end;
  lvImportFileNames.Items.Clear;
  LastReplKey:= ReplDataBase.LastProcessReplKey[(FImportFileList.Objects[0] as TrplStreamHeader).DBKey];
  FCanImport:= True;
  for i:= 0 to FImportFileList.Count - 1 do begin
    LI:= lvImportFileNames.Items.Add;
    LI.Caption := FImportFileList[i];
    LI.Data := TStringList.Create;
    ReplDataBase.GetreplFileInfo(TStringList(LI.Data), FImportFileList[i], LastReplKey);
    FileHeader:= (FImportFileList.Objects[i] as TrplStreamHeader);

    {$IFDEF CHECKSTREAM}
    if FileHeader.StreamInfo.Version <> StreamVersion then
      LI.ImageIndex:= 129;
    {$ENDIF}
    if not ReplDataBase.CanRepl(FileHeader.DBKey, FileHeader.ToDBKey) or
      (FileHeader.Schema <> ReplDataBase.DataBaseInfo.Schema) or
      (FileHeader.ReplKey < LastReplKey + 1) or (FileHeader.ReplKey > LastReplKey + 1) or
      (ReplDataBase.ReplKey(FileHeader.DBKey) - 1 > FileHeader.LastProcessReplKey) then
      LI.ImageIndex:= 129
    else
      LastReplKey:= (FImportFileList.Objects[i] as TrplStreamHeader).ReplKey;
    if LI.ImageIndex <> 129 then
      LI.ImageIndex:= 128;
    FCanImport:= FCanImport and (LI.ImageIndex = 128)
  end;
  lvImportFileNames.Tag:= 0;
  lvImportFileNames.ItemIndex:= 0;
end;

procedure TmainIBReplicator.actNextErrorExecute(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvRelations.Selected;
  if not Assigned(tn) then
    Exit;
  while Assigned(tn.Parent) do
    tn:= tn.Parent;
  tn:= tn.GetNextSibling;
  while Assigned(tn) do begin
    if Assigned(tn.Data) and (TObject(tn.Data) is TmnRelationWrap) then
      if TmnRelation(TmnRelationWrap(tn.Data).WrappedObject).ErrorCode <> ERR_CODE_OK then begin
        tvRelations.Selected:= tn;
        tvRelations.TopItem:= tn;
        Exit;
      end;
    tn:= tn.GetNextSibling;
  end;
end;

procedure TmainIBReplicator.actPrevErrorExecute(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvRelations.Selected;
  if not Assigned(tn) then
    Exit;
  while Assigned(tn.Parent) do
    tn:= tn.Parent;
  if Assigned(tn.Data) and (TObject(tn.Data) is TmnRelationWrap) and (tvRelations.Selected <> tn) and
      (TmnRelation(TmnRelationWrap(tn.Data).WrappedObject).ErrorCode <> ERR_CODE_OK) then begin
    tvRelations.Selected:= tn;
    tvRelations.TopItem:= tn;
    Exit;
  end;
  tn:= tn.GetPrevSibling;
  while Assigned(tn) do begin
    if Assigned(tn.Data) and (TObject(tn.Data) is TmnRelationWrap) then
      if TmnRelation(TmnRelationWrap(tn.Data).WrappedObject).ErrorCode <> ERR_CODE_OK then begin
        tvRelations.Selected:= tn;
        tvRelations.TopItem:= tn;
        Exit;
      end;
    tn:= tn.GetPrevSibling;
  end;
end;

procedure TmainIBReplicator.actNextErrorUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= ReplicationManager.Relations.ErrorCount > 0;
end;

procedure TmainIBReplicator.actPrevErrorUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= ReplicationManager.Relations.ErrorCount > 0;
end;

procedure TmainIBReplicator.actRestoreExecute(Sender: TObject);
begin
  Application.CreateForm(TfrmRestore, frmRestore);
  frmRestore.od.InitialDir:= GetLoadPath;
  frmRestore.sd.InitialDir:= GetSavePath;
  frmRestore.edServer.Text:= cbServerName.Text;
  frmRestore.edDatabase.Text:= cePath.Text;
  frmRestore.ShowModal;
  frmRestore.Free;
end;

procedure TmainIBReplicator.actBackupExecute(Sender: TObject);
begin
  if not Connect then
    Exit;
  ReplDataBase.Connected:= False;
  Application.CreateForm(TfrmBackup, frmBackup);
  frmBackup.od.InitialDir:= GetLoadPath;
  frmBackup.sd.InitialDir:= GetSavePath;
  frmBackup.edServer.ReadOnly:= False;
  frmBackup.edDatabase.ReadOnly:= False;
  frmBackup.edServer.Text:= cbServerName.Text;
  frmBackup.edDatabase.Text:= cePath.Text;
  frmBackup.ShowModal;
  frmBackup.Free;
end;

procedure TmainIBReplicator.ReCreateAllUsers;
{$IFDEF GEDEMIN}
var
  U, P: String;
  ibds: TIBDataSet;
  ibdb: TIBDatabase;
  tr: TIBTransaction;
  IBSS: TIBSecurityService;
  q: TIBSQL;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if not TestConnect(cbServerName.Text, cbProtocol.Text, cePath.Text, eUser.Text,
      ePassword.Text, cbCharSet.Text, eRole.Text, mAddiditionParam.Lines.Text) then
    Exit;
  q:= TIBSQL.Create(Self);
  ibdb := TIBDatabase.Create(Self);
  tr := TIBTransaction.Create(Self);
  ibds := TIBDataSet.Create(Self);
  IBSS := TIBSecurityService.Create(Self);
  try
    IBSS.ServerName:= cbServerName.Text;
    IBSS.Protocol:= TCP;
    IBSS.LoginPrompt:= False;
    IBSS.Params.Add('user_name=' + eUser.Text);
    IBSS.Params.Add('password=' + ePassword.Text);
    IBSS.Active:= True;

    ibdb.LoginPrompt:= False;
    ibdb.DatabaseName:= GetDataBaseName(cbServerName.Text, cePath.Text, cbProtocol.Text);;
    ibdb.Params.Clear;
    ibdb.Params.Add('user_name=' + eUser.Text);
    ibdb.Params.Add('password=' + ePassword.Text);
    ibdb.Connected := True;

    tr.DefaultDatabase := ibdb;
    tr.StartTransaction;

    q.Database := ibdb;
    q.Transaction := tr;

    ibds.Database := ibdb;
    ibds.Transaction := tr;
    ibds.SelectSQL.Text:= 'SELECT id, ibname, ibpassword FROM gd_user';
    ibds.Open;
    while not ibds.EOF do begin
      if ibds.FieldByName('ibname').AsString <> AnsiUpperCase(eUser.Text) then begin
        try
          IBSS.UserName:= ibds.FieldByName('ibname').AsString;
          IBSS.DisplayUser(IBSS.UserName);
          if IBSS.UserInfoCount > 0 then begin
            IBSS.DeleteUser;
            while IBSS.IsServiceRunning do begin
              Sleep(100);
            end;
          end;
        except
        end;
        Randomize;
        repeat
          U := GetRandomString;
          P := GetRandomString;
          IBSS.UserName:= U;
          IBSS.DisplayUser(IBSS.UserName);
        until not (IBSS.UserInfoCount > 0);
        try
        q.Close;
        q.SQL.Text := 'UPDATE gd_user SET ibname=' + QuotedStr(U) + ', ibpassword=' + QuotedStr(P) +
                      ' WHERE id=' + IntToStr(ibds.FieldByName('id').AsInteger);
        q.ExecQuery;
        IBSS.UserName:= U;
        IBSS.FirstName:= '';
        IBSS.MiddleName:= '';
        IBSS.LastName:= '';
        IBSS.UserID:= ibds.FieldByName('id').AsInteger;
        IBSS.GroupID:= 0;
        IBSS.Password:= P;
        IBSS.AddUser;
        while IBSS.IsServiceRunning do begin
          Sleep(100);
        end;

        q.Close;
        q.SQL.Text := 'GRANT administrator TO ' + U + ' WITH ADMIN OPTION ';
        q.ExecQuery;

        tr.CommitRetaining;
        except
          on E: Exception do
            ShowMessage(E.Message);
        end
      end;
      ibds.Next;
    end;

    ibdb.Connected := False;
  finally
    q.Free;
    ibds.Free;
    tr.Free;
    ibdb.Free;
    ibss.Free;
  end;
{$ENDIF}
end;

{$IFDEF GEDEMIN}
function TmainIBReplicator.GetRandomString: string;
var
  I, Pr, C: Integer;
  q: TIBSQL;
  ibdb: TIBDatabase;
  tr: TIBTransaction;
begin
  q := TIBSQL.Create(Self);
  ibdb := TIBDatabase.Create(Self);
  tr := TIBTransaction.Create(Self);
  try
    ibdb.LoginPrompt:= False;
    ibdb.DatabaseName:= GetDataBaseName(cbServerName.Text, cePath.Text, cbProtocol.Text);;
    ibdb.Params.Clear;
    ibdb.Params.Add('user_name=' + eUser.Text);
    ibdb.Params.Add('password=' + ePassword.Text);
    ibdb.Connected := True;

    tr.DefaultDatabase := ibdb;
    tr.StartTransaction;

    q.Database := ibdb;
    q.Transaction := tr;

    SetLength(Result, 8);
    repeat
      Pr := -1;
      for I := 1 to 8 do begin
        repeat
          C := Random(36);
        until (C <> Pr) and ((I > 1) or (C < 26));
        Pr := C;
        if C > 25 then
          Result[I] := Chr(Ord('0') + C - 26)
        else
          Result[I] := Chr(Ord('A') + C);
      end;

      q.Close;
      q.SQL.Text := 'SELECT id FROM gd_user WHERE ibname=''' + Result + '''' +
        ' OR ibpassword=''' + Result + '''';
      q.ExecQuery;
    until q.EOF;
  finally
    q.Free;
  end;
end;
{$ENDIF}

procedure TmainIBReplicator.actRecreateAllUsersExecute(Sender: TObject);
begin
  ReCreateAllUsers;
end;

procedure TmainIBReplicator.actAddDbUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (ReplDataBase.DataBaseInfo.DBState = dbsMain)
end;

procedure TmainIBReplicator.actEditSchemeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (ReplDataBase.DataBaseInfo.DBState = dbsMain)
end;

function TmainIBReplicator.CreateReplFileName: string;
var
  sAlias, sExport: string;
begin
  if FDBRegistrar.DBAlias > '' then
    sAlias:= FDBRegistrar.DBAlias
  else
    sAlias:= FDBRegistrar.Alias;

  sAlias:= ExtractFileName(sAlias);
  if FileCreate(sAlias) > 0 then
    DeleteFile(sAlias)
  else
    sAlias:= ExtractFileName(FDBRegistrar.FileName);

  if cbxPackageExport.Checked then
    sExport:= ExtractFileName(tvExportDBList.Selected.Text)
  else
    sExport:= ExtractFileName(cbExportDBAlias.Text);
  if FileCreate(sAlias + '-' + sExport) > 0 then begin
    DeleteFile(sExport);
    sExport:= '-' + sExport;
  end
  else
    sExport:= '';

  Result:= GetSavePath + sAlias + sExport;

  if btnSave.Action = actExportFile then
    Result:= Result + FormatDateTime('_dd-mm-yyyy_hh-nn', Now) + '.rpl'
  else
    Result:= Result + '_confirm.rpl';
end;

procedure TmainIBReplicator.cbxPackageExportClick(Sender: TObject);
begin
  actExportPackage.Execute
end;

procedure TmainIBReplicator.actExportPackageExecute(Sender: TObject);
var
  I: integer;
  DB: TReplicationDB;
  ctn: TCheckTreeNode;
begin
  eExportFileName.Text:= '';
  mDBInfo1.Lines.Clear;
  tvExportDBList.Visible:= cbxPackageExport.Checked;
  if cbxPackageExport.Checked then begin
    pnlExportFileInfo.Top:= 95;
    if btnSave.Action = actExportFile then
      lExportDBAlias.Caption:= CAPTION_DBALIASES_EXPORT
    else
      lExportDBAlias.Caption:= CAPTION_DBALIASES_CONFIRM;
    if not Assigned(FExportFileList) then
      FExportFileList:= TObjectList.Create;
    tvExportDBList.Items.BeginUpdate;
    try
      tvExportDBList.Items.Clear;
      for I := 0 to ReplDataBase.DBList.Count - 1 do begin
        if ReplDataBase.DBList.ItemsByIndex[I].DBKey <> ReplDataBase.DataBaseInfo.DBID then begin
          DB := ReplDataBase.DBList.ItemsByIndex[I];
          ctn:= TCheckTreeNode(tvExportDBList.Items.AddObject(nil, DB.DBName, Pointer(DB.DBKey)));
          ctn.ShowChecked:= True;
        end;
      end;
    finally
      tvExportDBList.Items.EndUpdate;
    end;
  end
  else begin
    pnlExportFileInfo.Top:= 47;
    lExportDBAlias.Caption:= 'База на которую передаются данные:';
  end;
end;

{ TExportFile }

class function TExportFile.Create(ADBKey: integer): TExportFile;
begin
  Result:= inherited Create;
  Result.FDBKey:= ADBKey;
end;

class function TExportFile.CreateAndAssign(ADBKey: integer; ADBName,
  AFileName: string): TExportFile;
begin
  Result:= Create(ADBKey);
  Result.FDBName:= ADBName;
  Result.FFileName:= AFileName;
end;

procedure TmainIBReplicator.tvExportDBListCheck(Sender: TObject;
  Node: TTreeNode);
var
  EF: TExportFile;
  I: integer;
  Ev: TNotifyEvent;
begin
  Ev:= eExportFileName.OnChange;
  try
    eExportFileName.OnChange:= nil;
    if TCheckTreeNode(Node).Checked then begin
      EF:= TExportFile.CreateAndAssign(Integer(Node.Data), Node.Text, CreateReplFileName);
      FExportFileList.Add(EF);
      eExportFileName.Text:= EF.FileName;
    end
    else begin
      I:= GetExportFileIndex(Integer(Node.Data));
      if I > -1 then
        FExportFileList.Delete(I);
    end;
  finally
    eExportFileName.OnChange:= Ev;
  end;
end;

function TmainIBReplicator.GetExportFileIndex(Key: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to FExportFileList.Count - 1 do begin
    if TExportFile(FExportFileList[i]).FDBKey = Key then begin
      Result:= i;
      Exit;
    end;
  end;
end;

procedure TmainIBReplicator.eExportFileNameChange(Sender: TObject);
var
  EF: TExportFile;
  I: integer;
begin
  if cbxPackageExport.Checked then begin
    if tvExportDBList.Items.Count = 0 then Exit;
    I:= GetExportFileIndex(Integer(tvExportDBList.Selected.Data));
    if I = -1 then begin
      EF:= TExportFile.CreateAndAssign(Integer(tvExportDBList.Selected.Data), tvExportDBList.Selected.Text, eExportFileName.Text);
      FExportFileList.Add(EF);
    end
    else begin
      TExportFile(FExportFileList[i]).FileName:= eExportFileName.Text;
    end;
  end;
end;

procedure TmainIBReplicator.tvExportDBListChange(Sender: TObject;
  Node: TTreeNode);
var
  I: integer;
  DBKey: Integer;
  Ev: TNotifyEvent;
begin
  mDbInfo1.Lines.Clear;
  mDbInfo1.Lines.Add(MSG_REPORT_READING_DBINFO);
  Application.ProcessMessages;
  mDBInfo1.Lines.BeginUpdate;
  Ev:= eExportFileName.OnChange;
  try
    DBKey:= Integer(Node.Data);
    if DBKey > - 1 then begin
      mDbInfo1.Lines.Clear;
      ReplDataBase.GetShortDbReport(mDbInfo1.Lines, DBKey);
      I:= GetExportFileIndex(DBKey);
      eExportFileName.OnChange:= nil;
      if I > -1 then begin
        eExportFileName.Text:= TExportFile(FExportFileList[i]).FileName;
      end
      else
        eExportFileName.Text:= '';
    end;
  finally
    mDBInfo1.Lines.EndUpdate;
    eExportFileName.OnChange:= Ev;
  end;
end;

procedure TmainIBReplicator.actViewRPLLogExecute(Sender: TObject);
begin
  Application.CreateForm(TfrmRPLLog, frmRPLLog);
  frmRPLLog.ShowModal;
  frmRPLLog.Free;
end;

procedure TmainIBReplicator.actShowViewLogBtnExecute(Sender: TObject);
begin
  actViewRPLLog.Visible:= not actViewRPLLog.Visible;
  actViewRPLFile.Visible:= actViewRPLLog.Visible;
end;

procedure TmainIBReplicator.actViewRPLFileExecute(Sender: TObject);
begin
  Application.CreateForm(TfrmViewRPLFile, frmViewRPLFile);
  frmViewRPLFile.ShowModal;
  frmViewRPLFile.Free;
end;

procedure TmainIBReplicator.SpeedButton1Click(Sender: TObject);
var
  Keys: TrpForeignKeys;
  i: integer;
  sl: TStringList;
begin
  Keys:= TrpForeignKeys.Create;
  sl:= TStringList.Create;
  try
    Keys.ReadKeys;
    for i:= 0 to Keys.Count - 1 do begin
      sl.Add(Keys.ForeignKeys[i].ConstraintName);
      sl.Add(Keys.ForeignKeys[i].TableName);
      sl.Add(Keys.ForeignKeys[i].FieldName);
      sl.Add(Keys.ForeignKeys[i].OnTableName);
      sl.Add(Keys.ForeignKeys[i].OnFieldName);
      sl.Add(Keys.ForeignKeys[i].DeleteRule);
      sl.Add(Keys.ForeignKeys[i].UpdateRule);
      sl.Add('');
    end;
    sl.SaveToFile('ForeignKeys.Txt');
  finally
    sl.Free;
    Keys.Free;
  end;
end;

procedure TmainIBReplicator.actSQLEditorExecute(Sender: TObject);
begin
  if Connect then begin
    PageControl.ActivePage:= tsSQLEditor;
  end;
end;

procedure TmainIBReplicator.actLoadSQLExecute(Sender: TObject);
var
  O: TOpenDialog;
begin
  O := TOpenDialog.Create(nil);
  try
    O.Filter := SQLFileFilter;
    O.FilterIndex:= 0;
    O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing, ofAllowMultiSelect];
    O.InitialDir:= GetLoadPath;
    O.DefaultExt := '*.sql';
    if O.Execute then
    begin
      memSQL.Lines.LoadFromFile(O.FileName);
      SetLoadPath(O.FileName);
    end;
  finally
    O.Free;
  end;
end;

procedure TmainIBReplicator.actSaveSQLExecute(Sender: TObject);
var
  S: TSaveDialog;
begin
  S := TSaveDialog.Create(Application);
  try
    S.Filter := SQLFileFilter;
    S.FilterIndex := 0;
    S.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton, ofEnableSizing];
    S.DefaultExt := '*.sql';
    S.InitialDir:= GetSavePath;
    if S.Execute then begin
      memSQL.Lines.SaveToFile(S.FileName);
      SetSavePath(S.FileName);
    end;
  finally
    S.Free;
  end;
end;

procedure TmainIBReplicator.actCommitSQLUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:= ReplDataBase.Transaction.InTransaction;
end;

procedure TmainIBReplicator.actRollBackSQLExecute(Sender: TObject);
begin
  ReplDataBase.Transaction.RollBack;
end;

procedure TmainIBReplicator.actCommitSQLExecute(Sender: TObject);
begin
  ReplDataBase.Transaction.Commit;
end;

procedure TmainIBReplicator.actRunSQLExecute(Sender: TObject);
var
  cTerm: char;
  slScriptList: TStringList;
  i: integer;

  procedure PrepareSQLScript;
  var
    sSQL, sTmp: string;
  begin
    sTmp:= AnsiUpperCase(Trim(memSQL.Lines.Text));
    if Pos(cTerm, sTmp) > 0 then begin
      while Pos(cTerm, sTmp) > 0 do begin
        sSQL:= Trim(Copy(sTmp, 1, Pos(cTerm, sTmp) - 1));
        Delete(sTmp, 1, Pos(cTerm, sTmp));
        sTmp:= Trim(sTmp);
        if sSQL = '' then Continue;
        if Pos('SET', sSQL) = 1 then begin
          Delete(sSQL, 1, 3);
          sSQL:= Trim(sSQL);
          if Pos('TERM', sSQL) = 1 then begin
            Delete(sSQL, 1, 4);
            sSQL:= Trim(sSQL);
            if Length(sSQL) = 1 then
              cTerm:= sSQL[1];
          end;
        end
        else
          slScriptList.Add(sSQL);
      end;
    end
    else
      slScriptList.Add(Trim(memSQL.Lines.Text));
  end;

begin
  IBSQL.Transaction:= ReplDataBase.Transaction;
  cTerm:= ';';
  slScriptList:= TStringList.Create;
  try
    PrepareSQLScript;
    if slScriptList.Count > 0 then begin
      for i:= 0 to slScriptList.Count - 1 do begin
        if not ReplDataBase.Transaction.InTransaction then
          ReplDataBase.Transaction.StartTransaction;
        if slScriptList[i] = 'COMMIT' then begin
          try
            ReplDataBase.Transaction.Commit;
          except
            on E: Exception do begin
              Application.MessageBox(PChar('При выполнении скрипта возникла следующая ошибка:'#13#10 +
                E.Message), PChar('Внимание!'), MB_OK + MB_APPLMODAL + MB_ICONERROR);
              Exit;
            end;
          end;
        end
        else begin
          IBSQL.Close;
          IBSQL.SQL.Text:= slScriptList[i];
          try
            IBSQL.ExecQuery
          except
            on E: Exception do begin
              Application.MessageBox(PChar('При выполнении скрипта возникла следующая ошибка:'#13#10 +
                E.Message), PChar('Внимание!'), MB_OK + MB_APPLMODAL + MB_ICONERROR);
              Exit;
            end;
          end;
        end;
      end;
      ShowMessage('Скрипт выполнен успешно.');
    end;
  finally
    slScriptList.Free;
  end;
end;

procedure TmainIBReplicator.actSQLEditorUpdate(Sender: TObject);
begin
  actSQLEditor.Enabled:= PageControl.ActivePage = tsConnect;
end;

function TmainIBReplicator.GetLastConnect: string;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        Result:= R.ReadString(cLastConnect);
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TmainIBReplicator.SetLastConnect(sName: string);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        R.WriteString(cLastConnect, sName);
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TmainIBReplicator.tvRelationsCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
  F1, F2: TmnField;
begin
  try
    if Assigned(Node1) and Assigned(Node2) and (TObject(Node1.Data) is TmnFieldWrap)
        and (TObject(Node1.Data) is TmnFieldWrap) and Assigned(TmnFieldWrap(Node1.Data).Node)
        and Assigned(TmnFieldWrap(Node2.Data).Node) then begin
      F1:= TmnFieldWrap(Node1.Data).Field;
      F2:= TmnFieldWrap(Node2.Data).Field;
      if F1.IsPrimeKey and not F2.IsPrimeKey then
        Compare:= -1
      else if not F1.IsPrimeKey and F2.IsPrimeKey then
        Compare:= 1
      else if F1.IsForeign and not F2.IsForeign then
        Compare:= -1
      else if not F1.IsForeign and F2.IsForeign then
        Compare:= 1
      else
        Compare:= CompareStr(Node1.Text, Node2.Text)
    end
    else
      Compare:= CompareStr(Node1.Text, Node2.Text)
  except
    if Assigned(Node1) and Assigned(Node2) then
      Compare:= CompareStr(Node1.Text, Node2.Text)
  end;
end;

function TmainIBReplicator.ShutDown: boolean;
var
  iCount: integer;
  IBConfig: TIBConfigService;
begin
  ReplDataBase.Connected:= False;
  Result:= False;
  IBConfig:= TIBConfigService.Create(self);
  try
    IBConfig.ServerName:= cbServerName.Text;
    IBConfig.DatabaseName:= cePath.Text;
    IBConfig.Protocol:= TCP;
    IBConfig.Params.Add('user_name=' + eUser.Text);
    IBConfig.Params.Add('password=' + ePassword.Text);
    IBConfig.LoginPrompt := False;
    IBConfig.Active := True;
    try
      IBConfig.ShutdownDatabase(Forced, 0);
      iCount:= 0;
      while IBConfig.IsServiceRunning do begin
        Inc(iCount);
        Sleep(100);
        if iCount > 50 then
          raise Exception.Create(ERR_SHUTDOWN);
      end;
      Result:= True;
    except
    end;
  finally
    IBConfig.Free;
  end;
end;

procedure TmainIBReplicator.BringOnLine;
var
  iCount: integer;
  IBConfig: TIBConfigService;
  b: boolean;
begin
  b:= gvAskQuestion;
  gvAskQuestion:= False;
  try
  if not TestConnect(cbServerName.Text, cbProtocol.Text, cePath.Text, eUser.Text,
      ePassword.Text, cbCharSet.Text, eRole.Text, mAddiditionParam.Lines.Text) then
    Exit;
  finally
    gvAskQuestion:= b;
  end;

  IBConfig:= TIBConfigService.Create(self);
  try
    IBConfig.ServerName:= cbServerName.Text;
    IBConfig.DatabaseName:= cePath.Text;
    IBConfig.Protocol:= TCP;
    IBConfig.Params.Add('user_name=' + eUser.Text);
    IBConfig.Params.Add('password=' + ePassword.Text);
    IBConfig.LoginPrompt := False;
    IBConfig.Active := True;
    try
      IBConfig.BringDatabaseOnline;
      iCount:= 0;
      while IBConfig.IsServiceRunning do begin
        Inc(iCount);
        Sleep(100);
        if iCount > 50 then
          raise Exception.Create(ERR_BRINGONLINE);
      end;
    except
    end;
  finally
    IBConfig.Free;
  end;
end;

procedure TmainIBReplicator.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = tsReport then
    BringOnLine;
end;

procedure TmainIBReplicator.actEditTriggerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (tvRelations.Selected <> nil) and
    (tvRelations.Selected.Data <> nil) and
    (TObject(tvRelations.Selected.Data) is TmnTriggerWrap);
end;

procedure TmainIBReplicator.actEditTriggerExecute(Sender: TObject);
begin
  ((TObject(tvRelations.Selected.Data) as TmnTriggerWrap).WrappedObject as TmnTrigger).Edit;
end;

procedure TmainIBReplicator.tvRelationsDblClick(Sender: TObject);
begin
  if (tvRelations.Selected <> nil) and (tvRelations.Selected.Data <> nil) and
      (TObject(tvRelations.Selected.Data) is TmnTriggerWrap) then
    actEditTrigger.Execute;
end;

procedure TmainIBReplicator.LoadTreeTrigger;
var
  I: Integer;
  R:  TTreeNode;
  Wrap: TmnCustomRelationWrap;
  s: string;
begin
  tvTriggers.Items.BeginUpdate;
  try
    tvTriggers.Items.Clear;
    for I := 0 to ReplicationManager.Relations.Count - 1 do begin
      if not ReplicationManager.Relations[I].Checked then Continue;
      s:= '';
      {$IFDEF GEDEMIN}
        if ReplicationManager.Relations[I].RelationName <>
            ReplicationManager.Relations[I].RelationLocalName then
          s:= ' (' + ReplicationManager.Relations[I].RelationLocalName + ')';
      {$ENDIF}
      s:= ReplicationManager.Relations[I].RelationName + s;
      R := tvTriggers.Items.AddObject(nil, s, ReplicationManager.Relations[I]);
      R.HasChildren := True;

      Wrap := TmnRelationWrap.Create;
      Wrap.WrappedObject := ReplicationManager.Relations[I];
      Wrap.Node := TCheckTreeNode(R);
    end;
  finally
    tvTriggers.Items.EndUpdate;
  end;
end;

procedure TmainIBReplicator.tvTriggersCheck(Sender: TObject;
  Node: TTreeNode);
begin
//  if Assigned(Node.Data) and (TObject(Node.Data) is TmnTriggerWrap) then
  if Assigned(Node.Data) then
  begin
    TmnCustomRelationWrap(Node.Data).OnNodeClick(Sender, Node);
    tvRelations.Invalidate;
  end;
end;

procedure TmainIBReplicator.tvTriggersCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  if Assigned(Node1) and Assigned(Node2) then
    Compare:= CompareStr(Node1.Text, Node2.Text);
end;

procedure TmainIBReplicator.tvTriggersExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  N, F: TTreeNode;
  Wrap: TmnCustomRelationWrap;
  Relation: TmnRelation;
begin
  if (Node.Data <> nil) and (TObject(Node.Data) is TmnRelationWrap) and
    (Node.Count = 0) then
  begin
    tvTriggers.Items.BeginUpdate;
    try
      Relation := TmnRelation(TmnRelationWrap(Node.Data).WrappedObject);

      F := Node;

      N := tvTriggers.Items.AddChild(F, TmnTrigger(Relation.TriggerAI).TriggerCaption);
      N.Data := Relation.TriggerAI;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAI;
      Wrap.Node := TCheckTreeNode(N);

      N := tvTriggers.Items.AddChild(F, TmnTrigger(Relation.TriggerAU).TriggerCaption);
      N.Data := Relation.TriggerAU;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAU;
      Wrap.Node := TCheckTreeNode(N);

      N := tvTriggers.Items.AddChild(F, TmnTrigger(Relation.TriggerAD).TriggerCaption);
      N.Data := Relation.TriggerAD;
      Wrap := TmnTriggerWrap.Create;
      Wrap.WrappedObject := Relation.TriggerAD;
      Wrap.Node := TCheckTreeNode(N);
    finally
      tvTriggers.Items.EndUpdate;
    end;
  end;
end;

procedure TmainIBReplicator.tvTriggersChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) and (TObject(Node.Data) is TmnTriggerWrap) then begin
    memTriggerBody.Text:= TmnTrigger(TmnTriggerWrap(Node.Data).WrappedObject).Body;
  end;
end;

procedure TmainIBReplicator.actRestoreTriggerExecute(Sender: TObject);
begin
  if AskQuestion(MSG_WANT_RESET_TRIGGER) then begin
    TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).Body:= '';
    memTriggerBody.Text:= TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).Body;
  end;
end;

procedure TmainIBReplicator.actRestoreTriggerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= Assigned(tvTriggers.Selected) and Assigned(tvTriggers.Selected.Data) and
    (TObject(tvTriggers.Selected.Data) is TmnTriggerWrap) and
    (TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).DefBody <> memTriggerBody.Text)
end;

procedure TmainIBReplicator.actSetTriggerExecute(Sender: TObject);
begin
  TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).Body:=
    memTriggerBody.Text;
end;

procedure TmainIBReplicator.actSetTriggerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= Assigned(tvTriggers.Selected) and Assigned(tvTriggers.Selected.Data) and
    (TObject(tvTriggers.Selected.Data) is TmnTriggerWrap) and (Trim(memTriggerBody.Text) <> '') and
    (TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).Body <> memTriggerBody.Text);
end;

procedure TmainIBReplicator.tvTriggersChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
var
  T: TmnTrigger;
begin
  if Assigned(tvTriggers.Selected) and Assigned(tvTriggers.Selected.Data) and
      (TObject(tvTriggers.Selected.Data) is TmnTriggerWrap) then begin
    t:= TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject);
    if t.Body <> memTriggerBody.Text then
      if AskQuestion(MSG_SET_TRIGGER) then begin
        actSetTrigger.Execute;
      end;
    memTriggerBody.Text:= '';
  end;
end;

procedure TmainIBReplicator.actInsertRelationIDExecute(Sender: TObject);
begin
  memTriggerBody.SelText:=
    IntToStr(TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject).Relation.RelationKey);
end;

procedure TmainIBReplicator.actInsertRelationIDUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= Assigned(tvTriggers.Selected) and Assigned(tvTriggers.Selected.Data) and
    (TObject(tvTriggers.Selected.Data) is TmnTriggerWrap);
end;

procedure TmainIBReplicator.actSaveTriggerExecute(Sender: TObject);
var
  T: TmnTrigger;
  slData: TStringList;
  SD: TSaveDialog;
  s: string;
begin
  slData:= TStringList.Create;
  T:= TmnTrigger(TmnTriggerWrap(tvTriggers.Selected.Data).WrappedObject);
  s:= T.Body;
  SD:= TSaveDialog.Create(nil);
  try
    T.Body:= memTriggerBody.Text;
    SD.Filter := ReplTriggersFileFilter;
    SD.FilterIndex := 0;
    SD.DefaultExt:= 'txt';
    SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    SD.FileName:= T.RelationName + '-' + T.TriggerCaption + ' (' + T.TriggerName + ')';
    if SD.Execute then begin
      if TAction(Sender).Name = 'actSaveTriggerCreateDLL' then
        slData.Text:= T.CreateDll
      else if TAction(Sender).Name = 'actSaveTriggerAlterDLL' then
        slData.Text:= T.AlterDll
      else if TAction(Sender).Name = 'actSaveTriggerBody' then
        slData.Text:= T.Body;

      slData.SaveToFile(SD.FileName);
    end;
  finally
    slData.Free;
    SD.Free;
    T.Body:= s;
  end;
end;

procedure TmainIBReplicator.actLoadTriggerExecute(Sender: TObject);
var
  O: TOpenDialog;
begin
  O := TOpenDialog.Create(nil);
  try
    O.Filter := ReplTriggersFileFilter;
    O.FilterIndex := 0;
    O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    if O.Execute then begin
      memTriggerBody.Lines.LoadFromFile(O.FileName);
    end;
  finally
    O.Free;
  end;
end;

procedure TmainIBReplicator.actLoadTriggerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= Assigned(tvTriggers.Selected) and Assigned(tvTriggers.Selected.Data) and
    (TObject(tvTriggers.Selected.Data) is TmnTriggerWrap);
  tbsiSaveTrigger.Enabled:= TAction(Sender).Enabled;
end;

procedure TmainIBReplicator.cbFieldsDropDown(Sender: TObject);
var
  i, j: integer;
  Rel: TmnRelation;
begin
  if cbFields.Items.Count = 0 then
    for i:= 0 to ReplicationManager.Relations.Count - 1 do begin
      Rel:= ReplicationManager.Relations[i];
      for j:= 0 to Rel.Fields.Count - 1 do begin
        if cbFields.Items.IndexOf(TmnField(Rel.Fields[j]).Caption) < 0 then
          cbFields.Items.Add(TmnField(Rel.Fields[j]).Caption);
      end;
    end;
end;

procedure TmainIBReplicator.tvRelationsChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) and (TmnCustomRelationWrap(Node.Data) is TmnGeneratorWrap) then
  begin
    TmnGeneratorWrap(Node.Data).SetSelected(True);
    tvRelations.Invalidate;
  end;
  CheckShcemaError;
end;

procedure TmainIBReplicator.tvRelationsChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  if Assigned(tvRelations.Selected) and Assigned(tvRelations.Selected.Data) and
    (TmnCustomRelationWrap(tvRelations.Selected.Data) is TmnGeneratorWrap) then
  begin
    TmnGeneratorWrap(tvRelations.Selected.Data).SetSelected(False);
    tvRelations.Invalidate;
  end;
  CheckShcemaError;
end;

end.
