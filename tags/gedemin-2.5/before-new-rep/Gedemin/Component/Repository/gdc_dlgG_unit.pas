
{

  ��� ������� �� ������ �� � ���������� ���� ������������������
  �������� ������:

  0. �������� ����� ������� ����������, � ������� �����
     ��������� ���� ������ ������� � ����������� ��
     �������� ������ (��������, �� �� ���������).
  1. ����������� ���� �� �������� ������ (DlgModified).
  2. ���� ����, ����������� ������ �� ������������ (TestCorrect).
  3. ���� ��� ��������� ���������� ����� Post � ����������� ����.
  4. ���� �����������.

  ����� ������� ������ ���, ������� �������� ���� � ������ ����
  �������� ����� �� ������ ���������. �� ���� ���� ����� ������
  �� �����, ���� DlgModified ������ ����.

  ����� ���������� ����� ���������� ��������� � ����������.

  ������ �������: ��������� DlgModified ��� ����� �� ��������� ������,
  ���� �������� ����� ��������� ���������� � �� �������� ����������� ��
  � �����.

  �� ����������� ���� DlgModified ���������:

  1. �������� DSModified � �������� ������-�������.
  2. �������� DSModified � ��������� ��������.
  3. �������� DSModified � ���� ������ ������-��������,
     ������� ��������� �� �����.

  �� ������ �.3. ��� ������.
}

unit gdc_dlgG_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_createable_form, gdcBase, StdCtrls, ActnList, DB, dmDataBase_unit,
  IBDatabase, Menus;

type
  TOnSyncFieldEvent = procedure(Sender: TObject; Field: TField; SyncList: TList) of object;
  TOnTestCorrect = function(Sender: TObject): Boolean of object;
  TOnSetupRecord = procedure(Sender: TObject) of object;
  TOnSetupDialog = procedure(Sender: TObject) of object;

  TFieldsCallList = class;
  TObjectMethod = procedure of object;

  Tgdc_dlgG = class(TgdcCreateableForm)
    btnAccess: TButton;
    btnNew: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    alBase: TActionList;
    actNew: TAction;
    actHelp: TAction;
    btnHelp: TButton;
    actSecurity: TAction;
    actOk: TAction;
    actCancel: TAction;
    dsgdcBase: TDataSource;
    actNextRecord: TAction;
    actPrevRecord: TAction;
    pm_dlgG: TPopupMenu;
    actNextRecord1: TMenuItem;
    actPrevRecord1: TMenuItem;
    actSecurity1: TMenuItem;
    sepFirst: TMenuItem;
    actApply: TAction;
    sepSecond: TMenuItem;
    actApply1: TMenuItem;
    actFirstRecord: TAction;
    actLastRecord: TAction;
    actFirstRecord1: TMenuItem;
    actLastRecord1: TMenuItem;
    actProperty: TAction;
    sepThird: TMenuItem;
    actProperty1: TMenuItem;
    actCopySettingsFromUser: TAction;
    actCopySettings1: TMenuItem;
    actAddToSetting: TAction;
    nAddToSetting1: TMenuItem;
    actDocumentType: TAction;
    N1: TMenuItem;
    actHistory: TAction;
    actHistory1: TMenuItem;

    procedure actNewExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actSecurityExecute(Sender: TObject);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure actSecurityUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actNextRecordUpdate(Sender: TObject);
    procedure actNextRecordExecute(Sender: TObject);
    procedure actPrevRecordUpdate(Sender: TObject);
    procedure actPrevRecordExecute(Sender: TObject);
    procedure btnAccessClick(Sender: TObject);
    procedure actApplyUpdate(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure actFirstRecordUpdate(Sender: TObject);
    procedure actFirstRecordExecute(Sender: TObject);
    procedure actLastRecordUpdate(Sender: TObject);
    procedure actLastRecordExecute(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
    procedure actCopySettingsFromUserExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actHelpUpdate(Sender: TObject);
    procedure actCopySettingsFromUserUpdate(Sender: TObject);
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actAddToSettingUpdate(Sender: TObject);
    procedure actDocumentTypeUpdate(Sender: TObject);
    procedure actDocumentTypeExecute(Sender: TObject);
    procedure actDistributeUserSettingsExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure actHistoryExecute(Sender: TObject);
    procedure actHistoryUpdate(Sender: TObject);

  private
    FRecordLocked: Boolean;
    FErrorAction: Boolean;
    FMultipleID: TList;
    FOnSyncField: TOnSyncFieldEvent;
    FOnTestCorrect: TOnTestCorrect;
    FOnSetupRecord: TOnSetupRecord;
    FOnSetupDialog: TOnSetupDialog;
    FFieldsCallOnSync: TFieldsCallList;
    FIntermediate: Boolean;
    FAlreadyRestory: Boolean;
    FAppliedID: Integer;
    FOldPostCount: Integer;

    procedure DoIntermediate(Mtd, Mtd2: TObjectMethod);
    function GetMultipleCreated: Boolean;

    class procedure RegisterMethod;
    function GetFieldsCallOnSync: TFieldsCallList;

    procedure RestoryTr(O: TgdcBase);
    procedure ReOpenDetails(O: TgdcBase);

  protected
    // ���� � ���������� ���� ������������ ���
    // ������-�������, ��������� �-�� ����� ������
    // ������-������ (��������, ���������: ����� ���������
    // � ������� �� ���������)
    // ������ ����� ����� ������� ��������� ������� ������
    // �.�. � ���� ������ �� ����� �������� ������ ������ --
    // ������ ����� �������� ���������
    // � ���� ������ ����� ���������� ���� ������ ��� �������� ����
    // � ����� ������ ��� �������� �� ������ �� (�� ������
    // Cancel -- ������)
    //
    // ��� ����� ������ ������������ ����� ActivateTransaction
    // ��� ���� �������� � Setup ��������� ���� ����������
    // ������ ������� (� ������ ������-������ ������������ ����
    // ���������� ��� ������� � �������)
    FSharedTransaction: TIBTransaction;

    // ������ ���������� ���� �� ������ ��������� ����������� ����
    // ��������� � ��� ������-������ ���� �������� ����������
    FIsTransaction: Boolean;

    // 0 -- ������������ ��������� ����������
    // 1 -- ������ ��
    // 2 -- ������ ���
    FEnterAsTab: Integer;

    procedure ActivateTransaction(ATransaction: TIBTransaction);

    // ������������� ���� ��������� ���� ������-������� �� ���������
    // �������� ���������, �� ��������� ������ ������ � ����������������
    // ������
    // ��������! ��������� ���������� ����� ���������� ���� ��� �������
    // ����� �� ������ ��������� ������� ���������, �.�. ����������� ����
    // �� �� ������ ��������� ���� ��� ������!
    procedure BeforePost; virtual;
    procedure CallBeforePost;

    // ����� TestCorrect ������������ ��� �������� ������������
    // ���������� ����� ����������� ����.
    // ������ ��������! ������������ ���������� ����� ������ �������
    // ������ �������������� � ����� ������-�������, � ������
    // ValidateField. ����� ����������� ������������ � ���������
    // �������:
    //   1) � ���������� ���� ������������ ����, �� ������������
    //      � ��������, ������������ ���������� ������� ����������
    //      ���������.
    //   2) � ���������� ���� ������������ ���� ������������ � ��������,
    //      �� ����������� ������-��������.
    //   3) �� ����, ������������ � ������-�������, �������������
    //      �������������� �������, ������������ ������ �����
    //      ����������� ����.
    // ������� ���� ��������, ����� �������� ������������ ���������� �
    // ������ ����������� ������������� �� ������.
    function TestCorrect: Boolean; virtual;

    // ����� ���� �������� ���� � ������-�������. ���� ����� �����������
    // ������ ���������� ��������� �������������� ���������, ��
    // ����� ������ ���� ��������. ��������, � ������ ������ ����� �������
    // ����� ����������.
    procedure Post; virtual;
    procedure Cancel; virtual;

    // setup transaction
    procedure SetupTransaction; virtual;

    // ����� ���������� ������, ���� ������ � ���������� ���� ����
    // �������� � ���� � ��������� ������.
    function DlgModified: Boolean; virtual;

    //
    procedure ResizerOnActivate(var Activate: Boolean); override;

    //
    procedure CMDialogKey(var Message: TWMKeyDown); message CM_DIALOGKEY;

    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; override;

    //
    procedure SetupDialog; virtual;

    // ������ ����� ������������ ��� ��������� ���� � ��������� �������
    // ������. ������ � ��� ��� �������� ����� �����: � �������������� ���������
    // ���� � ��������� ���� ��� ������. ����� ��������� ���� ��� ������
    // ������������ ��� ��� �� ������� �� ������ ����� ���������
    // ����� ������, � ����� ����� ��� �� ����������.
    procedure SetupRecord; virtual;

  public
    constructor Create(AnOwner: TComponent); override;

    constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = ''); override;
    constructor CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); override;

    destructor Destroy; override;

    //
    procedure Setup(AnObject: TObject); override;

    // ��������� �������������� ��������� ���������� ���������
    // � ������������ � ������� �������. ��������, ���� ���� �
    // ����� �������� 1, �� ���� ������ �������� ��� ����� ������ �����
    // � � �, ���� 0 -- �� ��������. ����� ���������� �� ���������
    // ����� ��� �������������� ���������. ����������� ������ ����������
    // ����� ������� ������ � ����� �� ������� �� ��������� ��� �����
    // ������ ������� ����� ������ �� ��������� ���������� ���������
    // �����.
    procedure SyncControls; virtual;

    procedure SaveSettings; override;
    procedure LoadSettings; override;

    procedure SyncField(Field: TField; SyncList: TList); virtual;
    //
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; virtual;
    procedure LockDocument;
    property MultipleCreated: Boolean read GetMultipleCreated;
    property ErrorAction: Boolean read FErrorAction write FErrorAction;
    property MultipleID: TList read FMultipleID;
    property FieldsCallOnSync: TFieldsCallList read GetFieldsCallOnSync;
    property RecordLocked: Boolean read FRecordLocked;

    function Get_SelectedKey: OleVariant; override; safecall;

  published
    property OnSyncField: TOnSyncFieldEvent read FOnSyncField write FOnSyncField;
    property OnTestCorrect: TOnTestCorrect read FOnTestCorrect write FOnTestCorrect;
    property OnSetupRecord: TOnSetupRecord read FOnSetupRecord write FOnSetupRecord;
    property OnSetupDialog: TOnSetupDialog read FOnSetupDialog write FOnSetupDialog;
  end;

  TFieldsCallList = class(TObject)
  private
    FDatasetList: TStringList;

    function  GetFieldList(const Index: Integer): TStringList;

  public
    constructor Create;
    destructor  Destroy; override;

    function  AddFieldList(const Name: String): Integer;
    function  CheckField(const DatasetName, FieldName: String): Boolean;

    procedure ClearList;
    procedure RemoveFieldList(const Name: String);

    function IndexOf(const Name: string): Integer;

    property FieldList[const Index: Integer]: TStringList read GetFieldList; default;
  end;

var
  gdc_dlgG: Tgdc_dlgG;

implementation

{$R *.DFM}

uses
  IB, IBSQL, IBErrorCodes, gdcBaseInterface,{ gdcLink,}
  IBCustomDataSet, TypInfo, gd_directories_const,
  Storages, gd_ClassList, dmImages_unit, evt_i_Base,
  jclStrings, at_frmSQLProcess, gsStorage_CompPath,
  gd_security, prp_methods, Gedemin_TLB, gsStorage,
  gdcUser, at_classes, DBCtrls, at_dlgToSetting_unit,
  gdcClasses, DBGrids, gdcJournal, gdHelp_Interface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TDataSourceCrack = class(TDataSource)
  end;

{ Tgdc_dlgG }


procedure Tgdc_dlgG.Setup(AnObject: TObject);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_DLGG', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGG', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Assert(AnObject is TgdcBase);
  Assert(TgdcBase(AnObject).Active);

  gdcObject := AnObject as TgdcBase;

  FIsTransaction := gdcObject.Transaction.InTransaction;

  SetupDialog;
  if Assigned(FOnSetupDialog) then
    FOnSetupDialog(Self);

  SetupRecord;
  if Assigned(FOnSetupRecord) then
    FOnSetupRecord(Self);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.actNewExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.CreateNext, nil);
end;

procedure Tgdc_dlgG.actNewUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(gdcObject) and
    {(gdcObject.State in [dsInsert]) and}
    (not (sSubDialog in gdcObject.BaseState)) and
    (not FRecordLocked) and
    {(not gdcObject.HasSubSet('ByID')) and}
    (not ResizerActivated)
    and gdcObject.CanCreate;
end;

procedure Tgdc_dlgG.actOkExecute(Sender: TObject);
var
  C: TWinControl;
begin
  // ����� ��������� ���� ������ ������ � �����
  // ����� ��������� ��������� � ����
  C := ActiveControl;
  try
    if Assigned(C) and Assigned(C.Parent) then
    begin
      SetFocusedControl(C.Parent);
    end else
    begin
      SetFocusedControl(btnOk);
    end;
  finally
    if C <> nil then
      SetFocusedControl(C);
  end;

  ModalResult := mrOk;
end;

procedure Tgdc_dlgG.actCancelExecute(Sender: TObject);
var
  C: TWinControl;
begin
  // ����� ��������� ���� ������ ������ � �����
  // ����� ��������� ��������� � ����
  C := ActiveControl;
  try
    try
      if Assigned(C) and Assigned(C.Parent) then
      begin
        SetFocusedControl(C.Parent);
      end else
      begin
        SetFocusedControl(btnCancel);
      end;
    except
    end;
  finally
    if C <> nil then
      SetFocusedControl(C);
  end;

  ModalResult := mrCancel;
end;

procedure Tgdc_dlgG.actSecurityExecute(Sender: TObject);
begin
  gdcObject.EditDialog('Tgdc_dlgObjectProperties');
end;

procedure Tgdc_dlgG.Cancel;
var
  I: Integer;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'CANCEL', KEYCANCEL)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'CANCEL', KEYCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  try
    if Assigned(gdcObject) then
    begin
      if (ModalResult = mrCancel) and (not gdcObject.IsEmpty)
        and (FAppliedID = gdcObject.ID) then
      begin
        MessageBox(Handle,
          '������ ��� ���� ��������� � ���� ������.'#13#10 +
          '���� �� ������ �� ������ �������� ��������� ���������,'#13#10 +
          '�� � ������� ������, �� ��������� ������� �������'#13#10 +
          '����� �������� ����������� ���� ��������������.',
          '��������',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;

      for I := 0 to gdcObject.DetailLinksCount - 1 do
      begin
        if gdcObject.DetailLinks[I].State in dsEditModes then
          gdcObject.DetailLinks[I].Cancel;

        if gdcObject.DetailLinks[I].CachedUpdates and gdcObject.DetailLinks[I].UpdatesPending then
          gdcObject.DetailLinks[I].CancelUpdates;

        if not FIntermediate then
        begin
          if (gdcObject.DetailLinks[I].Owner = Self) then
            gdcObject.DetailLinks[I].Close;
        end;
      end;

      if gdcObject.State in dsEditModes then
      begin
        if sSubDialog in gdcObject.BaseState then
        begin
          gdcObject.RevertRecord
        end else
        begin
          gdcObject.Cancel;
        end;
      end;
    end;
  finally
    if Assigned(FSharedTransaction)
      and FSharedTransaction.InTransaction
      and (not FIsTransaction) then
    begin
// ��� ��������� �����������: ���� � ���, ��� ����� ��������� ������
// ����� ����������� � �������� � �� �� ����� ���������� ���-�� ��� ���
// ������������ ��� �� ����� �������, ��� ���� ��������� � ����, �� ���
// ��������� �� ����� ����������. ������� ��� ������ ������ ���� ������ ������
      if FIntermediate then
        FSharedTransaction.RollbackRetaining
      else
        FSharedTransaction.Rollback;
    end;

    if Assigned(gdcObject) and (gdcObject.PostCount <> FOldPostCount) then
    begin
      if not (sSubDialog in gdcObject.BaseState) then
      begin
        gdcObject.Refresh;
      end;
    end;
  end;

  if Assigned(gdcObject) and Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('���� �������������� �������: ������',
      gdcObject.ClassName + ' ' + gdcObject.SubType,
      gdcObject.ID);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'CANCEL', KEYCANCEL)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'CANCEL', KEYCANCEL);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.Post;
var
  I: Integer;
  WasCached, isError: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  WasCached := False;
  isError := False;
  try
    try
      if Assigned(gdcObject) and (not (sSubDialog in gdcObject.BaseState)) then
      begin

        if gdcObject.State in dsEditModes then
          gdcObject.Post;

        for I := 0 to gdcObject.DetailLinksCount - 1 do
        begin
          if gdcObject.DetailLinks[I].State in dsEditModes then
            gdcObject.DetailLinks[I].Post;
        end;

        for I := 0 to gdcObject.DetailLinksCount - 1 do
        begin
          if gdcObject.DetailLinks[I].CachedUpdates and gdcObject.DetailLinks[I].UpdatesPending then
          begin
            WasCached := True;
            gdcObject.DetailLinks[I].ApplyUpdates;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        if WasCached then
        begin
          if Assigned(FSharedTransaction)
            and FSharedTransaction.InTransaction
            and (not FIsTransaction) then
          begin
            if FIntermediate then
              FSharedTransaction.RollbackRetaining
            else
              FSharedTransaction.Rollback;
          end;
{          if not FIntermediate then
            ModalResult := mrCancel; }
        end;
        isError := True;
        raise;
      end;
    end;
  finally
    if (not isError)
      and Assigned(FSharedTransaction)
      and FSharedTransaction.InTransaction
      and (not FIsTransaction) then
    begin
      if FIntermediate then
        FSharedTransaction.CommitRetaining
      else
        FSharedTransaction.Commit;
    end;
  end;

  if Assigned(gdcObject) and Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('���� �������������� �������: ��',
      gdcObject.ClassName + ' ' + gdcObject.SubType,
      gdcObject.ID);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.SyncControls;
var
  I, P, J: Integer;
  PropInfo: PPropInfo;
  F: TField;
  S, RN, FN: String;
  L: TDataLink;
  RF: TatRelationField;
begin
  if gdcObject <> nil then
  begin
    // ������� ������ ��������, ������� ������� �������������
    // ����������.
    // �� �� ����� ������ ����� �� ������
    {if Screen.Width >= 640 then
    begin}
      for I := 0 to ComponentCount - 1 do
      begin
        PropInfo := GetPropInfo(Components[I].ClassInfo, 'DataSource');
        if (PropInfo <> nil)
          and (PropInfo^.PropType^.Kind = tkClass)
          and (GetTypeData(PropInfo^.PropType^).ClassType.InheritsFrom(TDataSource)) then
        begin
          PropInfo := GetPropInfo(Components[I].ClassInfo, 'DataField');
          if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkLString) then
          begin
            F := gdcObject.FindField(GetStrProp(Components[I], PropInfo));
            if (F <> nil) and F.Required {and F.IsNull} then
            begin
              PropInfo := GetPropInfo(Components[I].ClassInfo, 'ParentColor');
              if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkEnumeration) then
              begin
                if GetEnumProp(Components[I], PropInfo) = 'True' then
                  continue;
              end;

              PropInfo := GetPropInfo(Components[I].ClassInfo, 'Color');
              if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkInteger) then
              begin
                S := Components[I].ClassName;
                if StrIPos('TDBTEXT', Components[I].ClassName) = 0 then
                begin
                  SetOrdProp(Components[I], PropInfo, Integer($A9FFFF));
                end;
              end;
            end;
          end;
        end;
      end;
    {end;}

    if not IBLogin.IsUserAdmin then
    begin
      for I := 0 to TDataSourceCrack(dsgdcBase).DataLinks.Count - 1 do
      begin
        L := TDataSourceCrack(dsgdcBase).DataLinks[I];
        if (L is TFieldDataLink) and (TFieldDataLink(L).Field <> nil) then
        begin
          RN := TFieldDataLink(L).Field.Origin;
          P := Pos('.', RN);
          if P > 0 then
          begin
            FN := Copy(RN, P + 1, 1024);
            SetLength(RN, P - 1);
            if (Length(FN) > 2) and (FN[1] = '"') then
              FN := Copy(FN, 2, Length(FN) - 2);
            if (Length(RN) > 2) and (RN[1] = '"') then
              RN := Copy(RN, 2, Length(RN) - 2);
            RF := atDatabase.FindRelationField(RN, FN);
            if RF <> nil then
            begin
              if (RF.aView and IBLogin.Ingroup) = 0 then
              begin
                if TFieldDataLink(L).Control is TWinControl then
                begin
                  TWinControl(TFieldDataLink(L).Control).Visible := False;

                  for J := 0 to ComponentCount - 1 do
                  begin
                    if Components[J] is TLabel then
                    begin
                      if TLabel(Components[J]).FocusControl = TFieldDataLink(L).Control then
                      begin
                        TLabel(Components[J]).Visible := False;
                        break;
                      end;
                    end;
                  end;
                end;
              end
              else if (RF.aChag and IBLogin.Ingroup) = 0 then
              begin
                TFieldDataLink(L).ReadOnly := True;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_dlgG.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Sender <> (Source as TgdcDragObject).SourceControl then
    gdcObject.PasteFromClipboard;
end;

procedure Tgdc_dlgG.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TgdcDragObject) and gdcObject.CanPasteFromClipboard;
end;

procedure Tgdc_dlgG.actSecurityUpdate(Sender: TObject);
begin
  actSecurity.Enabled := Assigned(gdcObject)
    and (Assigned(gdcObject.Database))
    and (gdcObject.Database.Connected)
    //and gdcObject.CanChangeRights
    and (not (sSubDialog in gdcObject.BaseState))
    and (not FRecordLocked)
    and (not ResizerActivated);
end;

procedure Tgdc_dlgG.SetupTransaction;
{var
  I: Integer;}
begin
  // � ������ �������������� ����� � � ������
  // ���������� ����� ���� ������ ��������, ����
  // � ����������
  {for I := 0 to ComponentCount - 1 do
    if (Components[I] is TIBCustomDataSet) then
    begin
      (Components[I] as TIBCustomDataSet).Active := False;

      (Components[I] as TIBCustomDataSet).DataBase := gdcObject.DataBase;
      (Components[I] as TIBCustomDataSet).Transaction := gdcObject.Transaction;
    end;}
end;

procedure Tgdc_dlgG.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  R: TRect;
  D: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if (Owner is Tgdc_dlgG) and (Owner.ClassType = Self.ClassType) then
  begin
    // ���� �����. ���� �� ���� ���������� ���� ������-�� ������,
    // �� �������� ��� ���������� ������������ ���������� ����.
    // ������: � ���� �����/�������������� ����� (��������) ����
    // ���������� ������ -- ����� ����� ���� ����� ������� ��������
    // �����. ���� � ���� ������ ������ �2 (���� ����� ������), ��
    // ����������� ���� ������� ��� �������������� �� ������ � ������������
    // ����� �� ������� ��� �� � ��� ������ ������.
    // ��������, ��� ��� ����� �������� ������, ���� � ����� ���������
    // ��������� �����.
    Self.Position := Forms.poDesigned;
    Top := (Owner as Tgdc_dlgG).Top + 24;
    Left := (Owner as Tgdc_dlgG).Left + 24;
  end;

  if WindowState = Forms.wsNormal then
  begin
    SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
    if Height > (R.Bottom - R.Top) then
    begin
      Height := R.Bottom - R.Top;
      if Position in [Forms.poScreenCenter, Forms.poDesktopCenter] then
      begin
        D := Screen.Height - Height;
        if (D > 0) and (D < Height) then
          Height := Height - D;
      end;
    end;
    if Width > (R.Right - R.Left) then
    begin
      Width := R.Right - R.Left;
      if Position in [Forms.poScreenCenter, Forms.poDesktopCenter] then
      begin
        D := Screen.Width - Width;
        if (D > 0) and (D < Width) then
          Width := Width - D;
      end;
    end;
    if Left < 0 then
      Left := 0;
    if Top < 0 then
      Top := 0;  
    if Left + Width > R.Right then
    begin
      Left := R.Right - Width + R.Left;
    end;
    if Top + Height > R.Bottom then
    begin
      Top := R.Bottom - Height + R.Top;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  // ������� � ���������� ����������� ������ ��� ����,
  // ������� �� ������������� �����, �.�. ������� �������
  // ����� �������� ������������ (������� � gdc_createable_form)

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := Assigned(gdcObject)
    and (Assigned(gdcObject.Database))
    and (gdcObject.Database.Connected)
    and (gdcObject.CanEdit or (gdcObject.State <> dsEdit))
    and (not ErrorAction)
    and (not FRecordLocked)
    and (not ResizerActivated);
end;

function Tgdc_dlgG.DlgModified: Boolean;
var
  I: Integer;
begin
  Result := False;

  if (gdcObject = nil) or (gdcObject.Transaction = nil) then
    exit;

  // �������� ������� ������ � ��������� � ���
  // �� ������, ���� ��� ���� ������-������
  //
  // ��� ��������� ��������. �������� �� ������ ��� ����,
  // �����, ���� ������������ ������ ���� ������ ����������
  // � ������ � ��� �� �����, �� ��� ������� �� ������ ��
  // ���� ����������� ��� �� ������. �������������� ���� ��
  // ����������, � ���� ������ �� ������� � ���������� ��
  // ���������, �������������� �������� �� ���������������.
  // ������ �� ��� ��� ������. ������ ������� ���: ���������
  // �������� Modified � �������� ������� � ��������� � ����.
  // ������, ���� � ���������� ����, ��� ��������� ����������
  // ������� ������������ ����, �� ������������ �����
  // �������� ���� ������ � ����������� ������ �� ������.
  // �������� ����� ����. ����� ������ ��� �������� ��
  // �������� � ������� ����� ���� ��������, ������� ����������
  // ��� �� ������� ���� ������� (�� ������ ������� ������).
  //
  //
  // ��������� �������� �� ������:
  // 1) ����� �������� ���� �� ���������� ����� �������
  //    � ���� ������ ������ ����������� ���, ���� ������������
  //    ����� ������ ���������� ��� ����� ���� ����� �������
  //    ��� ������� �������. ����, ���� ������ � ���� ��� ��
  //    �� �������.
  // 2) ���������� �� ����� �������, � ����� ���������� ����������.
  //    ��������. � ���� ������ ������ ������ �� ����� � ���, ���
  //    ���������� ���������. � ��� ��� ������� ���� ����������.
  Result := gdcObject.DSModified;

  if not Result then
    for I := 0 to gdcObject.DetailLinksCount - 1 do
    begin
      if gdcObject.DetailLinks[I].DSModified then
      begin
        Result := True;
        break;
      end;
    end;

  if not Result then
  begin
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TgdcBase then
      begin
        if (Components[I] as TgdcBase).DSModified then
        begin
          Result := True;
          break;
        end;
      end;
    end;  
  end;

  // ����� ����� �������� �������, ������� �� ����� ������ ���
  // �� ����� �� ���� ����� � ��� ���������� ����������
  // ������ �������
  if not Result then
  begin
    for I := 0 to gdcObject.Transaction.SQLObjectCount - 1 do
    begin
      if (gdcObject.Transaction.SQLObjects[I] <> nil) and
         (gdcObject.Transaction.SQLObjects[I].Owner <> nil) and
         (gdcObject.Transaction.SQLObjects[I].Owner is TgdcBase) then
      begin
        if (gdcObject.Transaction.SQLObjects[I].Owner
          as TgdcBase).DSModified then
        begin
          Result := True;
          break;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_dlgG.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  procedure _Ok;
  begin
    // ����� ��������� ���� ������ ������ � �����
    // ����� ��������� ��������� � ����
    if ModalResult = mrCancel then
      SetFocusedControl(btnCancel)
    else
      SetFocusedControl(btnOk);

    if TestCorrect then
    begin
      if DlgModified then
      begin
        Post;
        ModalResult := MrOk;
      end else
      begin
        Cancel;
        ModalResult := MrCancel;
      end;
    end else
    begin
      ModalResult := mrNone;

      if sSubDialog in gdcObject.BaseState then
      begin
        MessageBox(Handle,
          '��������, ����, ������� ���������� ��������� ���������'#13#10 +
          '� ����������� ���������� ����. � ���� ������, �������� ������� ����'#13#10 +
          '� ������� ������ ������ � ������� ���������� ����������.',
          '��������',
          MB_OK or MB_ICONINFORMATION);
      end;
    end;
  end;

begin
  if not CanClose then
    exit;
  if not (
      Assigned(gdcObject)
      and (Assigned(gdcObject.Database))
      and (gdcObject.Database.Connected)
      and (gdcObject.CanEdit or (gdcObject.State <> dsEdit))
      and (not ErrorAction)
      and (not FRecordLocked)
      and (not ResizerActivated)
    ) then
  begin
    Cancel;
    ModalResult := mrCancel;
    CanClose := True;
  end else
  begin
    if (not ResizerActivated) and (ModalResult = mrOk) and (not ErrorAction) then
      CallBeforePost;

    if (ModalResult = mrOk)
      and (not ResizerActivated)
      and (not ErrorAction) then
    begin
      _Ok;
    end
    else if not ErrorAction
        and actOk.Enabled
        and DlgModified
        and (not (sSubDialog in gdcObject.BaseState))
        and (not ResizerActivated)
        and ((UserStorage = nil) or UserStorage.ReadBoolean(st_OptionsPath, st_AskDialogCancel, True)) then
      case MessageBox(Handle, '������ ���� ��������. ���������?', '��������', MB_YESNOCANCEL or MB_ICONQUESTION) of
        IDYES:
          begin
            CallBeforePost;
            _Ok;
          end;
        IDNO: Cancel;
        IDCANCEL: ModalResult := mrNone;
      end
    else if not (sSubDialog in gdcObject.BaseState) then
      Cancel;

    CanClose := ModalResult <> mrNone;
  end;

  if Assigned(gdcObject)
    and CanClose
    and (not (sSubDialog in gdcObject.BaseState)) then
  begin
    try
      RestoryTr(gdcObject);
      ReOpenDetails(gdcObject);
    except
      on E: Exception do
        Application.HandleException(E);
    end;
    FAlreadyRestory := True;
  end;
end;

procedure Tgdc_dlgG.ActivateTransaction(ATransaction: TIBTransaction);

  procedure SetupTr(O: TgdcBase);
  var
    I: Integer;
    WasActive: Boolean;
  begin
    for I := 0 to O.DetailLinksCount - 1 do
    begin
      {if O.DetailLinks[I].ReadTransaction <> O.ReadTransaction then
        raise Exception.Create('Read transaction of a detail object doesn''t match read transaction of master object.');}

      if O.DetailLinks[I].ReadTransaction <> FSharedTransaction then
      begin
        WasActive := O.DetailLinks[I].Active;
        O.DetailLinks[I].Close;
        O.DetailLinks[I].ReadTransaction := FSharedTransaction;
        O.DetailLinks[I].Active := WasActive;
      end;
 
      SetupTr(O.DetailLinks[I]);
    end;
  end;

var
  q: TIBSQL;
begin
  FSharedTransaction := ATransaction;

  if not FSharedTransaction.InTransaction then
  begin
    FSharedTransaction.StartTransaction;

    if GlobalStorage.ReadBoolean('Options', 'BlockRec', False, False)
      and (gdcObject <> nil)
      and (gdcObject.State = dsEdit)
      and gdcObject.CanEdit then
    with gdcObject do
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := FSharedTransaction;
        q.SQL.Text := Format('UPDATE %s SET %s=%d WHERE %s=%d',
          [GetListTable(SubType), GetKeyField(SubType), ID, GetKeyField(SubType), ID]);
        try
          q.ExecQuery;
        except
          on E: EIBError do
          begin
            if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
            begin
              FRecordLocked := True;
              MessageBox(gdcObject.ParentHandle,
                '������ ������������ ��� ������������� �/��� �������� ������ ������.'#13#10 +
                '�� ������� ������ ������������� ������ � �� ������� �� ��������.',
                '������ �������������',
                MB_OK or MB_ICONEXCLAMATION);
            end
            else if (E.IBErrorCode = isc_except) and (Pos('Period', E.Message) > 0) then
            begin
              FRecordLocked := True;
              MessageBox(gdcObject.ParentHandle,
                '������ ������������ ��� ���������.'#13#10 +
                '�� ������� ������ ������������� ������ � �� ������� �� ��������.'#13#10#13#10 +
                '�������� ���������� ����� � ���� �����, ���� ������.',
                '������ ������������',
                MB_OK or MB_ICONEXCLAMATION);
            end else
              raise;
          end else
            raise;
        end;
      finally
        q.Free;
      end;
    end;
    SetupTr(gdcObject);
  end;
end;

procedure Tgdc_dlgG.ResizerOnActivate(var Activate: Boolean);
begin
  inherited;

{  if Activate then
  begin
    btnOk.Default := False;
    btnOk.Enabled := False;
    btnNew.Enabled := False;
    btnAccess.Enabled := False;
    btnCancel.Default := True;
  end;}
end;

procedure Tgdc_dlgG.actNextRecordUpdate(Sender: TObject);
begin
  actNextRecord.Enabled := (gdcObject <> nil)
    and (gdcObject.State in [dsEdit, dsBrowse])
    and (sView in gdcObject.BaseState)
    and (not ResizerActivated)
    and (not (sSubDialog in gdcObject.BaseState))
    and (not gdcObject.Eof) and (not gdcObject.HasSubSet('ByID'))
    and (not gdcObject.HasSubSet('ByName'));
end;

procedure Tgdc_dlgG.actNextRecordExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.Next, gdcObject.Edit);
end;

procedure Tgdc_dlgG.actPrevRecordUpdate(Sender: TObject);
begin
  actPrevRecord.Enabled := (gdcObject <> nil) and (gdcObject.State in [dsEdit, dsBrowse])
    and (sView in gdcObject.BaseState) and (not ResizerActivated)
    and (not (sSubDialog in gdcObject.BaseState))
    and (not gdcObject.Bof) and (not gdcObject.HasSubSet('ByID'))
    and (not gdcObject.HasSubSet('ByName'));
end;

procedure Tgdc_dlgG.actPrevRecordExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.Prior, gdcObject.Edit);
end;

procedure Tgdc_dlgG.SetupRecord;
const
  cReadOnlyWarn = ' [������ ��������]';
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ctrl, pctrl: TWinControl;
  L: TList;
  I, P: Integer;
  IsNewCtrl: Boolean;

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  P := Pos(cReadOnlyWarn, Caption);
  if (gdcObject.State = dsEdit) and (not gdcObject.CanEdit)
    and (not (sSubDialog in gdcObject.BaseState)) then
  begin
    if P = 0 then
      Caption := Caption + cReadOnlyWarn;

    {if UserStorage.ReadBoolean('Options', 'EditWarn', True) then
    begin
      MessageBox(0,
        '� ��� ��� ���� �� �������������� ��� ������ ������ ������ ��������.'#13#10 +
        '���������� ���� ����� ������� � ������ ���������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;}
  end else
  begin
    if P > 0 then
      Caption := StringReplace(Caption, cReadOnlyWarn, '', []);
  end;

  //��������� ����� �� ������ �������
  L := TList.Create;
  try
    ctrl := Self;
    pctrl := Self;
    ctrl.GetTabOrderList(L);
    while L.Count > 0 do
    begin
      IsNewCtrl := False;
      for I := 0 to L.Count - 1 do
      begin
        if TWinControl(L[I]).Visible and TWinControl(L[I]).Enabled and
          (TWinControl(L[I]).parent = pctrl) then
        begin
          ctrl := L[I];
          IsNewCtrl := True;
          Break;
        end;
      end;
      L.Clear;
      if IsNewCtrl and ctrl.Visible then
      begin
        pctrl := ctrl;
        ctrl.GetTabOrderList(L);
      end;
    end;
  finally
    L.Free;
  end;

  if ctrl.CanFocus and Assigned(ctrl.parent) and ctrl.parent.Visible then
    ActiveControl := ctrl;

  if Assigned(gdcObject) and Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('������ ������� � ���� ��� ���������',
      gdcObject.ClassName + ' ' + gdcObject.SubType,
      gdcObject.ID);
  end;

  FOldPostCount := gdcObject.PostCount;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.btnAccessClick(Sender: TObject);
begin
  with btnAccess.Parent.ClientToScreen(Point(btnAccess.Left, btnAccess.Top + btnAccess.Height)) do
    pm_dlgG.Popup(X, Y);
end;

procedure Tgdc_dlgG.actApplyUpdate(Sender: TObject);
begin
  actApply.Enabled := Assigned(gdcObject)
    and (Assigned(gdcObject.Database))
    and (gdcObject.Database.Connected)
    and (gdcObject.CanEdit or (gdcObject.State <> dsEdit))
    and (not ErrorAction)
    and (not FRecordLocked)
    and (not ResizerActivated)
    and (not (sSubDialog in gdcObject.BaseState));
end;

procedure Tgdc_dlgG.actApplyExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.Edit, nil);
end;

procedure Tgdc_dlgG.actFirstRecordUpdate(Sender: TObject);
begin
  actFirstRecord.Enabled := (gdcObject <> nil) and (gdcObject.State in [dsEdit, dsBrowse])
    and (sView in gdcObject.BaseState) and (not ResizerActivated)
    and (not (sSubDialog in gdcObject.BaseState))
    and (not gdcObject.Bof) and (not gdcObject.HasSubSet('ByID'))
    and (not gdcObject.HasSubSet('ByName'));
end;

procedure Tgdc_dlgG.actFirstRecordExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.First, gdcObject.Edit);
end;

procedure Tgdc_dlgG.actLastRecordUpdate(Sender: TObject);
begin
  actLastRecord.Enabled := (gdcObject <> nil) and (gdcObject.State in [dsEdit, dsBrowse])
    and (sView in gdcObject.BaseState) and (not ResizerActivated)
    and (not (sSubDialog in gdcObject.BaseState))
    and (not gdcObject.Eof) and (not gdcObject.HasSubSet('ByID'))
    and (not gdcObject.HasSubSet('ByName'));
end;

procedure Tgdc_dlgG.actLastRecordExecute(Sender: TObject);
begin
  DoIntermediate(gdcObject.Last, gdcObject.Edit);
end;

procedure Tgdc_dlgG.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  // ��� ����� ��������� ���� �� ������ ������
  if Screen.Width < 640 then
  begin
    pm_dlgG.AutoPopup := False;
  end;

  SetupTransaction; // ������ ���� ����� ������������� ��������
  dsgdcBase.DataSet := gdcObject;
  SyncControls;

  // ��� ��������� �� ����� ��������� �����, �����
  // ����� ��� ������, ������� ���� ����� ��'����
  if ((Caption = Name) or (Caption = '')) and (gdcObject <> nil) then
    Caption := gdcObject.GetDisplayName(FSubType);

  {$IFDEF DEBUG}
  if FIsTransaction then
    Caption := Caption + ' <InTransaction>';
  {$ENDIF}

  if Assigned(FMultipleID) then
    FMultipleID.Clear;

  {if (gdcObject.State = dsEdit) and (not gdcObject.CanEdit)
    and (not (sSubDialog in gdcObject.BaseState)) then
  begin
    if UserStorage.ReadBoolean('Options', 'EditWarn', True) then
    begin
      MessageBox(0,
        '� ��� ��� ���� �� �������������� ��� ������ ������ ������ ��������.'#13#10 +
        '���������� ���� ����� ������� � ������ ���������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;
  end;}

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.actPropertyExecute(Sender: TObject);
begin
  if Assigned(EventControl) then
    EventControl.EditObject(Self, emNone);
end;

procedure Tgdc_dlgG.actPropertyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(EventControl)
    and Assigned(IBLogin)
    and IBLogin.Database.Connected
    and IBLogin.IsUserAdmin; 
end;

function Tgdc_dlgG.GetMultipleCreated: Boolean;
begin
  Result := Assigned(FMultipleID) and (FMultipleID.Count > 1);
end;

destructor Tgdc_dlgG.Destroy;
begin
  if (not FAlreadyRestory) and Assigned(gdcObject)
    and (not (sSubDialog in gdcObject.BaseState)) then
  begin
    RestoryTr(gdcObject);
    ReOpenDetails(gdcObject);
  end;

  FreeAndNil(FMultipleID);
  FFieldsCallOnSync.Free;
  inherited;
end;

procedure Tgdc_dlgG.CMDialogKey(var Message: TWMKeyDown);
{$IFDEF DEBUG}
var
  T: LongWord;
{$ENDIF}
begin
  { TODO : �� �������� �� ���? }

  {$IFDEF DEBUG}
  T := GetTickCount;
  {$ENDIF}

  if ((FEnterAsTab = 0) and (Assigned(UserStorage) and
    UserStorage.ReadBoolean('Options', 'EnterAsTab', False, False)))
    or (FEnterAsTab = 1) then
  begin
    if Message.CharCode = VK_RETURN then
      Message.CharCode := VK_TAB;
  end;

  {$IFDEF DEBUG}
  OutputDebugString(PChar('���������� Options\EnterAsTab - ' + IntToStr(GetTickCount - T) + ' ��'));
  {$ENDIF}

  inherited;
end;

procedure Tgdc_dlgG.SyncField(Field: TField; SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGG', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGG', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if Assigned(FOnSyncField) then
    FOnSyncField(Self, Field, SyncList);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgG.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  if  AnsiUpperCase(Name) = 'SYNCFIELD' then
  begin
    SyncField(InterfaceToObject(AnParams[1]) as TField,
      InterfaceToObject(AnParams[2]) as TList);
  end else
  if  AnsiUpperCase(Name) = 'SETUPRECORD' then
  begin
    SetupRecord;
  end else
  if  AnsiUpperCase(Name) = 'BEFOREPOST' then
  begin
    BeforePost { TODO : ���� �� ��� �������� CallBeforePost? }
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
  end else
  if  AnsiUpperCase(Name) = 'SETUPDIALOG' then
  begin
    SetupDialog;
  end else
    Result := inherited OnInvoker(Name, AnParams);
end;

class procedure Tgdc_dlgG.RegisterMethod;
begin
  RegisterFrmClassMethod(Tgdc_dlgG, 'SyncField', 'Self: Object; Field: Object; SyncList: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgG, 'SetupRecord', 'Self: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgG, 'BeforePost', 'Self: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgG, 'Post', 'Self: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgG, 'Cancel', 'Self: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgG, 'TestCorrect', 'Self: Object', 'Variable');
  RegisterFrmClassMethod(Tgdc_dlgG, 'SetupDialog', 'Self: Object', '');
end;

procedure Tgdc_dlgG.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGG', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgG.CallBeforePost;
begin
  if (gdcObject <> nil) and (gdcObject.State in dsEditModes) then
  begin
    BeforePost;
    if not (gdcObject.State in dsEditModes) then
    begin
      MessageBox(Handle,
        '�������� ��������� ������-������� � ������ BeforePost,'#13#10 +
        '��� ������������ ��������� ������ ����������� ����.'#13#10 +
        '����� BeforePost ������ ���� �������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;
  end else
    BeforePost;
end;

function Tgdc_dlgG.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I, J: Integer;
  C, C2: TWinControl;
  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGG', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGG',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGG' then
  {M}      begin
  {M}        Result := False;//Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  // ����� ��������� ���� ������ ������ � �����
  // ����� ��������� ��������� � ����
  C := ActiveControl;
  try
    if Assigned(C) and Assigned(C.Parent) then
    begin
      SetFocusedControl(C.Parent);
    end else
    begin
      SetFocusedControl(btnOk);
    end;
    C2 := ActiveControl;
  finally
    if C <> nil then
      SetFocusedControl(C);
  end;

  if Assigned(gdcObject) then
  begin
    for I := 0 to gdcObject.Fields.Count - 1 do
      with gdcObject.Fields[I] do
        if Required and not ReadOnly and (FieldKind = db.fkData) and IsNull then
        begin
          S := DisplayName;
          FocusControl;
          if C2 <> ActiveControl then
          begin
            for J := 0 to Self.ComponentCount - 1 do
            begin
              if (Self.Components[J] is TLabel)
                and (TLabel(Self.Components[J]).FocusControl = ActiveControl) then
              begin
                S := Trim((Self.Components[J] as TLabel).Caption);
                if Copy(S, Length(S), 1) = ':' then
                  SetLength(S, Length(S) - 1);
                break;
              end;
            end;
          end;

          MessageBox(Handle,
            PChar(Format('���������� ��������� ����: %s!', [S])),
            '������',
            MB_OK or MB_ICONERROR);

          Result := False;
          exit;
        end;
  end;

  if Assigned(FOnTestCorrect) then
    Result := FOnTestCorrect(Self)
  else
    Result := True;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGG', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgG.GetFieldsCallOnSync: TFieldsCallList;
begin
  Result := FFieldsCallOnSync;
end;


constructor Tgdc_dlgG.Create(AnOwner: TComponent);
begin
  inherited;
  ErrorAction := False;
  FFieldsCallOnSync := TFieldsCallList.Create;
  FAlreadyRestory := False;
  FAppliedID := -1;
end;

constructor Tgdc_dlgG.CreateNewUser(AnOwner: TComponent;
  const Dummy: Integer; const ASubType: String);
begin
  inherited;
  ErrorAction := False;
  FFieldsCallOnSync := TFieldsCallList.Create;
  FAlreadyRestory := False;
  FAppliedID := -1;
end;

constructor Tgdc_dlgG.CreateUser(AnOwner: TComponent; const AFormName,
  ASubType: String; const AForEdit: Boolean);
begin
  inherited;
  ErrorAction := False;
  FFieldsCallOnSync := TFieldsCallList.Create;
  FAlreadyRestory := False;
  FAppliedID := -1;
end;

procedure Tgdc_dlgG.DoIntermediate(Mtd, Mtd2: TObjectMethod);
var
  C: TWinControl;
  isActiveTransaction: Boolean;
  WasInsert: Boolean;
begin
  FIntermediate := True;
  try
    if gdcObject.CanEdit then
    begin
      // ����� ��������� ���� ������ ������ � �����
      // ����� ��������� ��������� � ����
      C := ActiveControl;
      try
        if Assigned(C) and Assigned(C.Parent) then
        begin
          SetFocusedControl(C.Parent);
        end else
          SetFocusedControl(btnNew);
      finally
        if C <> nil then
          SetFocusedControl(C);
      end;

      WasInsert := gdcObject.State = dsInsert;

      CallBeforePost;

      if TestCorrect then
      begin

        isActiveTransaction := Assigned(FSharedTransaction)
          and FSharedTransaction.InTransaction;

        if DlgModified then
        begin
          Post;

          if not Assigned(FMultipleID) then
            FMultipleID := TList.Create;
          if FMultipleID.IndexOf(Pointer(gdcObject.ID)) = -1 then
            FMultipleID.Add(Pointer(gdcObject.ID));
        end else
          Cancel;

        if isActiveTransaction then
          ActivateTransaction(FSharedTransaction);

        if WasInsert and (not gdcObject.IsEmpty) then
          FAppliedID := gdcObject.ID;

        Mtd;
        if Assigned(Mtd2) then
          Mtd2;

        SetupRecord;

        if Assigned(FOnSetupRecord) then
          FOnSetupRecord(Self);
      end;
    end else
    begin
      isActiveTransaction := Assigned(FSharedTransaction)
        and FSharedTransaction.InTransaction;

      if DlgModified then
        Cancel;

      if isActiveTransaction then
        ActivateTransaction(FSharedTransaction);

      FAppliedID := -1;

      Mtd;
      if Assigned(Mtd2) then
        Mtd2;

      SetupRecord;

      if Assigned(FOnSetupRecord) then
        FOnSetupRecord(Self);
    end;

    if Assigned(frmSQLProcess) and frmSQLProcess.Visible then
    begin
      frmSQLProcess.Hide;
      frmSQLProcess.ShowModal;
    end;
  finally
    FIntermediate := False;
  end;
end;

function Tgdc_dlgG.Get_SelectedKey: OleVariant;
begin
  Result := VarArrayOf([gdcObject.ID])
end;

function Tgdc_dlgG.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := (gdcObject <> nil) and
            ( ((Field.FieldName = 'COMPANYKEY') and ibLogin.IsHolding ) or
              FFieldsCallOnSync.CheckField(Field.DataSet.Name, Field.FieldName) );
end;

procedure Tgdc_dlgG.RestoryTr(O: TgdcBase);
var
  I: Integer;
begin
  for I := 0 to O.DetailLinksCount - 1 do
  begin
    if O.DetailLinks[I].ReadTransaction <> O.ReadTransaction then
    begin
      O.DetailLinks[I].Close;
      O.DetailLinks[I].ReadTransaction := O.ReadTransaction;
    end;

    RestoryTr(O.DetailLinks[I]);
  end;
end;

procedure Tgdc_dlgG.ReOpenDetails(O: TgdcBase);
var
  I: Integer;
begin
  for I := 0 to O.DetailLinksCount - 1 do
  begin
    {
      ���� ������ �����: ������� ������������ �������, ��
      ���������� �� ����� �������, ��� �� (������)
      ����� ��������
    }
    if (O.DetailLinks[I].ReadTransaction = O.ReadTransaction)
      and (O.DetailLinks[I].Owner <> Self) then
    begin
      O.DetailLinks[I].Active := True;
    end;

    ReOpenDetails(O.DetailLinks[I]);
  end;
end;

procedure Tgdc_dlgG.LockDocument;
begin
  FRecordLocked := True;
end;

{ TFieldsCallList }

function TFieldsCallList.AddFieldList(const Name: String): Integer;
var
  FieldList: TStringList;
begin
  Result := FDatasetList.IndexOf(Name);
  if Result = -1 then
  begin
    Result := FDatasetList.Add(Name);
    FieldList := TStringList.Create;
    FieldList.Sorted := True;
    FieldList.Duplicates := dupIgnore;
    FDatasetList.Objects[Result] := FieldList;
  end;
end;

function TFieldsCallList.CheckField(const DatasetName,
  FieldName: String): Boolean;
var
  I: Integer;
begin
  if (FDatasetList.Count = 0) then
    Result := True
  else
  begin
    I := FDatasetList.IndexOf(DatasetName);
    if (I = -1) or ((I > -1) and (FieldList[I].IndexOf(FieldName) > -1)) then
      Result := True
    else
      Result := False;
  end;
end;

procedure TFieldsCallList.ClearList;
begin
  with FDatasetList do
  begin
    while Count > 0 do
    begin
      Objects[Count - 1].Free;
      Delete(Count - 1);
    end;
  end;
end;

constructor TFieldsCallList.Create;
begin
  FDatasetList := TStringList.Create;
//  FDatasetList.Sorted := True;
//  FDatasetList.Duplicates := dupError;
end;

destructor TFieldsCallList.Destroy;
begin
  ClearList;
  FDatasetList.Free;
end;

function TFieldsCallList.GetFieldList(const Index: Integer): TStringList;
begin
  Result := TStringList(FDatasetList.Objects[Index]);
end;

function TFieldsCallList.IndexOf(const Name: string): Integer;
begin
  Result := FDatasetList.IndexOf(Name);
end;

procedure TFieldsCallList.RemoveFieldList(const Name: String);
var
  I: Integer;
begin
  I := FDatasetList.IndexOf(Name);
  if I > -1 then
  begin
    FDatasetList.Objects[I].Free;
    FDatasetList.Delete(I);
  end;
end;

procedure Tgdc_dlgG.actCancelUpdate(Sender: TObject);
begin
  btnCancel.Cancel := True;
  if ActiveControl is TCustomDBGrid then
  begin
    with ActiveControl as TCustomDBGrid do
    begin
      if (DataSource <> nil) and (DataSource.DataSet <> nil)
        and (DataSource.DataSet.State in dsEditModes) then
      begin
        btnCancel.Cancel := False;
      end;
    end;
  end;
end;

procedure Tgdc_dlgG.actHelpExecute(Sender: TObject);
var
  HelpID: String;
begin
  HelpID := gdcObject.GetDisplayName(gdcObject.SubType);
  if gdcObject is TgdcDocument then
    HelpID := HelpID + ' ' + TgdcDocument(gdcObject).DocumentName[False];
  ShowHelp(HelpID + ' (������)');
end;

procedure Tgdc_dlgG.actHelpUpdate(Sender: TObject);
begin
  actHelp.Enabled := gdcObject <> nil; //HelpContext <> 0;
end;

procedure Tgdc_dlgG.actCopySettingsFromUserUpdate(Sender: TObject);
begin
  actCopySettingsFromUser.Enabled := Assigned(GlobalStorage)
    and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure Tgdc_dlgG.actAddToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcObject, nil);
end;

procedure Tgdc_dlgG.actAddToSettingUpdate(Sender: TObject);
begin
  actAddToSetting.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin
    and Assigned(gdcObject) and (gdcObject.State in [dsBrowse, dsEdit]);
end;

procedure Tgdc_dlgG.actDocumentTypeUpdate(Sender: TObject);
begin
  actDocumentType.Visible := (gdcObject is TgdcDocument);
  actDocumentType.Enabled := (gdcObject is TgdcDocument)
    and Assigned(IBLogin) and IBLogin.IsUserAdmin;
end;

procedure Tgdc_dlgG.actDocumentTypeExecute(Sender: TObject);
begin
  with TgdcDocumentType.Create(Self) do
  try
    SubSet := 'ByID';
    ID := (gdcObject as TgdcDocument).DocumentTypeKey;
    Open;
    if not EOF then
      EditDialog;
  finally
    Free;
  end;
end;

procedure Tgdc_dlgG.actHistoryExecute(Sender: TObject);
var
  F: TgdcCreateableForm;
begin
  F := TgdcJournal.CreateViewForm(Self, '', '', True) as TgdcCreateableForm;
  try
    F.gdcObject.Close;
    F.gdcObject.SubSet := 'ByObjectID';
    F.gdcObject.ParamByName('ObjectID').AsInteger := gdcObject.ID;
    F.gdcObject.Open;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure Tgdc_dlgG.actHistoryUpdate(Sender: TObject);
begin
  actHistory.Enabled := (gdcObject <> nil) and (gdcObject.ID >= 0)
    and (IBLogin <> nil) and (IBLogin.IsUserAdmin);
end;

procedure Tgdc_dlgG.actCopySettingsFromUserExecute(Sender: TObject);
{$INCLUDE copy_user_settings.pas}


procedure Tgdc_dlgG.actDistributeUserSettingsExecute(Sender: TObject);
{$INCLUDE distribute_user_settings.pas}


initialization
  RegisterFrmClass(Tgdc_dlgG);
  Tgdc_dlgG.RegisterMethod;

finalization
  UnRegisterFrmClass(Tgdc_dlgG);

{@DECLARE MACRO Inh_dlgG_SyncField(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf(
        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
         GetGdcInterface(SyncList) as IgsList]);
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

end.


