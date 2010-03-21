//

{ generic form }

unit gdc_frmG_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_createable_form, ComCtrls,  dmImages_unit, ActnList,
  ToolWin, ExtCtrls, StdCtrls, Menus, flt_sqlFilter, Db, dmDatabase_unit,
  IBDatabase, gdcBaseInterface, gdcBase, DBGrids, gdcLink, 
  IBCustomDataSet, gdcConst, TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu,
  Grids, gsDBGrid, gsIBGrid, Mask, xDateEdits, gd_KeyAssoc;

const
  scNew         = 'Ins';
  scEdit        = 'Ctrl+Enter';
  scDelete      = 'Ctrl+Del';
  scDuplicate   = 'Ctrl+D';
  scPrint       = 'Ctrl+P';
  //scCut         = 'Shift+Del';
  //scCopy        = 'Ctrl+Ins';
  //scPaste       = 'Shift+Ins';
  scReduction   = 'Ctrl+R';

  //Название категории в акшенлисте для операций выбора
  cst_st_cat_Choose  = 'Choose';

type
  Tgdc_frmG = class(TgdcCreateableForm)
    sbMain: TStatusBar;
    alMain: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actDuplicate: TAction;
    actHlp: TAction;
    actPrint: TAction;
    pmMain: TPopupMenu;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actCopy1_OLD: TMenuItem;
    actCut1_OLD: TMenuItem;
    actPaste1_OLD: TMenuItem;
    actCommit: TAction;
    dsMain: TDataSource;
    actRollback: TAction;
    actMacros: TAction;
    nNew_OLD: TMenuItem;
    nEdit_OLD: TMenuItem;
    nDel_OLD: TMenuItem;
    nSeparator1_OLD: TMenuItem;
    actFind: TAction;
    nSepartor2_OLD: TMenuItem;
    nFind_OLD: TMenuItem;
    actMainReduction: TAction;
    nReduction_OLD: TMenuItem;
    actFilter: TAction;
    TBDockTop: TTBDock;
    TBDockLeft: TTBDock;
    TBDockRight: TTBDock;
    TBDockBottom: TTBDock;
    tbMainToolbar: TTBToolbar;
    tbiNew: TTBItem;
    tbiEdit: TTBItem;
    tbiDelete: TTBItem;
    tbiDuplicate: TTBItem;
    tbsiMainOne: TTBSeparatorItem;
    tbiCopy: TTBItem;
    tbiCut: TTBItem;
    tbiPaste: TTBItem;
    tbsiMainTwo: TTBSeparatorItem;
    tbiFind: TTBItem;
    tbiFilter: TTBItem;
    tbiPrint: TTBItem;
    tbiHelp: TTBItem;
    tbiReduction: TTBItem;
    pnlWorkArea: TPanel;
    pnlMain: TPanel;
    tbMainCustom: TTBToolbar;
    tbMainMenu: TTBToolbar;
    tbsiMainMenuHelp: TTBSubmenuItem;
    tbiMainMenuHelp: TTBItem;
    actProperties: TAction;
    nProperties_OLD: TMenuItem;
    actSaveToFile: TAction;
    actLoadFromFile: TAction;
    tbiLoadFromFile: TTBItem;
    tbiSaveToFile: TTBItem;
    nSeparator3_OLD: TMenuItem;
    tbsiMainOneAndHalf: TTBSeparatorItem;
    actSearchMain: TAction;
    actSearchMainClose: TAction;
    actOnlySelected: TAction;
    tbiOnlySelected: TTBItem;
    actAddToSelected: TAction;
    actRemoveFromSelected: TAction;
    actAddToSelected1: TMenuItem;
    actRemoveFromSelected1: TMenuItem;
    pnlSearchMain: TPanel;
    sbSearchMain: TScrollBox;
    pnlSearchMainButton: TPanel;
    btnSearchMain: TButton;
    btnSearchMainClose: TButton;
    gdMacrosMenu: TgdMacrosMenu;
    tbsiMainThreeAndAHalf: TTBSeparatorItem;
    tbsiMainMenuObject: TTBSubmenuItem;
    tbi_mm_New: TTBItem;
    tbi_mm_Edit: TTBItem;
    tbi_mm_Delete: TTBItem;
    tbi_mm_Duplicate: TTBItem;
    tbi_mm_Reduction: TTBItem;
    tbi_mm_sep1_1: TTBSeparatorItem;
    tbi_mm_Copy: TTBItem;
    tbi_mm_Cut: TTBItem;
    tbi_mm_Paste: TTBItem;
    tbi_mm_sep2_1: TTBSeparatorItem;
    tbi_mm_Load: TTBItem;
    tbi_mm_Save: TTBItem;
    tbi_mm_sep3_1: TTBSeparatorItem;
    tbi_mm_Commit: TTBItem;
    tbi_mm_Rollback: TTBItem;
    tbi_mm_sep4_1: TTBSeparatorItem;
    tbi_mm_Find: TTBItem;
    tbi_mm_Filter: TTBItem;
    tbi_mm_Print: TTBItem;
    tbi_mm_Macro: TTBItem;
    tbi_mm_OnlySelected: TTBItem;
    tbMainInvariant: TTBToolbar;
    tbiCommit: TTBItem;
    tbiRollback: TTBItem;
    tbsiMainThree: TTBSeparatorItem;
    tbiMacros: TTBItem;
    spChoose: TSplitter;
    pnChoose: TPanel;
    pnButtonChoose: TPanel;
    btnCancelChoose: TButton;
    btnOkChoose: TButton;
    tbChooseMain: TTBToolbar;
    ibgrChoose: TgsIBGrid;
    dsChoose: TDataSource;
    actQExport: TAction;
    nQExport_OLD: TMenuItem;
    nDublicate_OLD: TMenuItem;
    actMainToSetting: TAction;
    sprSetting: TMenuItem;
    miMainToSetting: TMenuItem;
    actChooseOk: TAction;
    btnDeleteChoose: TButton;
    actDeleteChoose: TAction;
    actCopySettingsFromUser: TAction;
    tbi_mm_sep5_1: TTBSeparatorItem;
    tbi_mm_CopySettings: TTBItem;
    chbxFuzzyMatch: TCheckBox;
    actSelectAll: TAction;
    actUnSelectAll: TAction;
    actClearSelection: TAction;
    tbiClearSelection: TTBItem;
    tbiUnSelectAll: TTBItem;
    tbiSelectAll: TTBItem;
    actEditInGrid: TAction;
    tbiEditInGrid: TTBItem;
    pnlChooseCaption: TPanel;
    tbiLinkObject: TTBItem;
    actLinkObject: TAction;
    tbi_mm_LinkObject: TTBItem;
    tbi_mm_MainToSetting: TTBItem;
    tbi_mm_sep5_2_: TTBSeparatorItem;
    tbi_mm_sep2_2_: TTBSeparatorItem;
    tbi_mm_RemoveFromSelected: TTBItem;
    tbi_mm_AddToSelected: TTBItem;
    actDistributeSettings: TAction;
    tbiDistributeSettings: TTBItem;
    actDontSaveSettings: TAction;
    tbiDontSaveSettings: TTBItem;

    procedure actFilterExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDuplicateUpdate(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure actRollbackUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actRollbackExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actMacrosExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actFindExecute(Sender: TObject);
    procedure actMainReductionExecute(Sender: TObject);
    procedure actPrintUpdate(Sender: TObject);
    procedure actMainReductionUpdate(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actFilterUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actPropertiesUpdate(Sender: TObject);
    procedure actPropertiesExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actSearchMainCloseExecute(Sender: TObject);
    procedure actSearchMainExecute(Sender: TObject);
    procedure actOnlySelectedUpdate(Sender: TObject);
    procedure actOnlySelectedExecute(Sender: TObject);
    procedure actAddToSelectedUpdate(Sender: TObject);
    procedure actAddToSelectedExecute(Sender: TObject);
    procedure actRemoveFromSelectedExecute(Sender: TObject);
    procedure actOldReportExecute(Sender: TObject);
    procedure actQExportExecute(Sender: TObject);
    procedure actQExportUpdate(Sender: TObject);
    procedure actChooseOkExecute(Sender: TObject);
    procedure actChooseOkUpdate(Sender: TObject);
    procedure actMainToSettingExecute(Sender: TObject);
    procedure actMainToSettingUpdate(Sender: TObject);
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure actDeleteChooseUpdate(Sender: TObject);
    procedure actCopySettingsFromUserExecute(Sender: TObject);
    procedure actMacrosUpdate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actUnSelectAllExecute(Sender: TObject);
    procedure actUnSelectAllUpdate(Sender: TObject);
    procedure actClearSelectionExecute(Sender: TObject);
    procedure actClearSelectionUpdate(Sender: TObject);
    procedure actSearchMainUpdate(Sender: TObject);
    procedure actHlpExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actCopySettingsFromUserUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure tbMainInvariantVisibleChanged(Sender: TObject);
    procedure actLinkObjectUpdate(Sender: TObject);
    procedure actLinkObjectExecute(Sender: TObject);
    procedure pnlSearchMainEnter(Sender: TObject);
    procedure pnlSearchMainExit(Sender: TObject);
    procedure actDistributeSettingsUpdate(Sender: TObject);
    procedure actDistributeSettingsExecute(Sender: TObject);
    procedure actDontSaveSettingsUpdate(Sender: TObject);
    procedure actDontSaveSettingsExecute(Sender: TObject);
    procedure actHlpUpdate(Sender: TObject);

  private
    FFieldOrigin: TStringList;
    FMainPreservedConditions: String;

    //Контрол, который отображает датасет, из которого идет выбор
    FChooseControl: TComponent;
    FChosenIDInOrder: TStringList;

    class procedure RegisterMethod;
    function GetChosenIDInOrder: OleVariant;

  protected
    FgdcChooseObject: TgdcBase; // объект, который хранит выбранные записи
    FInChoose: Boolean;  //указывает если форма в Choose-режиме
    gdcLinkObject: TgdcBase; // связанный объект, из которого произошел вызов окна
    FgdcLinkChoose: TgdcBase; //указывает на объект из которого идет выбор
                              //для форм с несколькими gdc-объектами
    PreviousSelectedID: TgdKeyArray; //первоначально выбранные записи. Только для чуз
    LocalizeListName: TStringList; //Список для хранения локализованных имен объекта

    FgdcLink: TgdcLink;

    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; override;

    procedure DoOnFilterChanged(Sender: TObject); virtual;

    //
    procedure SetupSearchPanel(Obj: TgdcBase;
      PN: TPanel;
      SB: TScrollBox;
      SP: TSplitter;
      var FO: TStringList;
      out PreservedConditions: String;
      const ShowAllFields: Boolean = False);

    //
    procedure SearchExecute(Obj: TgdcBase;
      SB: TPanel;
      var FO: TStringList; PreservedConditions: String;
      const AFuzzy: Boolean = False);

    procedure SetGdcObject(const Value: TgdcBase); override;

    procedure DoCreate; override;

    //Локализация имен полей из колонок грида
    procedure SetLocalizeListName(AGrid: TgsIBGrid);

    //Добавляет в selectedid объекта для выбранных записей
    procedure AddToChooseObject(AnID: Integer);
    //Удаляет из selectedid объекта для выбранных записей
    procedure DeleteFromChooseObject(AnID: Integer);

    //Удаляет из выбранных записей
    procedure DeleteChoose(AnID: Integer); virtual;

    //
    function CanStartDrag(Obj: TgdcBase): Boolean; virtual;
    procedure GdcDragOver(Obj: TgdcBase; Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); virtual;

    //
    procedure SetShortCut(const Master: Boolean); virtual;

    //
    procedure DoShowAllFields(Sender: TObject); virtual;

  public
    constructor Create(AnOwner: TComponent); override;

    constructor CreateUser(AnOwner: TComponent; const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); override;
    destructor Destroy; override;

    //
    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;

    //
    function GetMainBookmarkList: TBookmarkList; virtual;

    //настройки формы в Choose режиме
    procedure SetChoose(AnObject: TgdcBase); virtual;

    property gdcChooseObject: TgdcBase read FgdcChooseObject;
    property gdcLinkChoose: TgdcBase read FgdcLinkChoose write FgdcLinkChoose;
    property InChoose: Boolean read FInChoose;

    //Список, содержащий выбранные id в том порядке, в котором их выбрали
    property ChosenIDInOrder: OleVariant read GetChosenIDInOrder;
  end;

var
  gdc_frmG: Tgdc_frmG;

implementation

{$R *.DFM}

uses
  gd_directories_const, gd_security,
  {$IFDEF QEXPORT}
  VExportDlg,
  {$ENDIF}
  at_sql_setup, gd_createable_form, gd_ClassList,
  at_dlgToSetting_unit, Storages, gsStorage_CompPath,
  gdcUser, gsStorage, prp_methods, gsDBTreeView,
  gsDesktopManager, IBSQL, jclSelected, gdHelp_Interface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdc_frmStreamSaver;

{
var
  GDC_FRMG_HOOK: HHOOK = 0;
}  

{
function gdc_frmG_Hook_Proc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(GDC_FRMG_HOOK, nCode, wParam, lParam);

  if nCode = HC_ACTION then
  begin
    with PMouseHookStruct(lParam)^ do
    begin
      case wParam of
        WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
        begin
          if (Screen.ActiveForm is Tgdc_frmG)
            and (GetForegroundWindow = Screen.ActiveForm.Handle) then
          with (Screen.ActiveForm as Tgdc_frmG) do
          begin
//            if (pt.x = 0) and (pt.y = 0) then
            P := ScreenToClient(pt);
            if (P.X < -4) or (P.X > Width + 4) or
              (P.Y < -20) or (P.Y > Height + 4) then
            begin
              ModalResult := mrCancel;
              Result := 1;
            end else
            begin
              Result := 0;
            end;
          end
        end;
      end;
    end;
  end;
end;
}

procedure Tgdc_frmG.SetShortCut(const Master: Boolean);
begin
  actNew.ShortCut := TextToShortCut(scNew);
  actEdit.ShortCut := TextToShortCut(scEdit);
  actDelete.ShortCut := TextToShortCut(scDelete);
  actDuplicate.ShortCut := TextToShortCut(scDuplicate);
  actPrint.ShortCut := TextToShortCut(scPrint);
  //actCut.ShortCut := TextToShortCut(scCut);
  //actCopy.ShortCut := TextToShortCut(scCopy);
  //actPaste.ShortCut := TextToShortCut(scPaste);
  actMainReduction.ShortCut := TextToShortCut(scReduction);
end;

procedure Tgdc_frmG.actFilterExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbMainToolbar do
  begin
    R := View.Find(tbiFilter).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcObject.PopupFilterMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmG.actPrintExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbMainToolbar do
  begin
    R := View.Find(tbiPrint).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcObject.PopupReportMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmG.actNewUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and gdcObject.CanCreate;
end;

procedure Tgdc_frmG.actEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil)
    and (gdcObject.RecordCount > 0)
    and (gdcObject.State = dsBrowse)
    and gdcObject.CanView;
end;

procedure Tgdc_frmG.actDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil) and (gdcObject.RecordCount > 0) and
    (gdcObject.State = dsBrowse)
    and gdcObject.CanDelete;
end;

procedure Tgdc_frmG.actDuplicateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil)
    and (gdcObject.RecordCount > 0)
    and (gdcObject.CanEdit)
    and (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmG.actCutUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil) and
    (gdcObject.RecordCount > 0) and
    (gdcObject.CanDelete) and
    (gdcObject.State = dsBrowse)
    and gdcObject.CanDelete;
end;

procedure Tgdc_frmG.actCopyUpdate(Sender: TObject);
begin
  actCopy.Enabled := (gdcObject <> nil) and
    (gdcObject.RecordCount > 0) and
    (gdcObject.CanEdit)
    and (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmG.actPasteUpdate(Sender: TObject);
begin
  actPaste.Enabled := (gdcObject <> nil)
    and (gdcObject.CanPasteFromClipboard)
    and (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmG.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := (gdcObject <> nil)
    //and (gdcObject.State = dsBrowse)
    and gdcObject.CanCreate
    and gdcObject.CanEdit
    and gdcObject.CanView;
end;

procedure Tgdc_frmG.actRollbackUpdate(Sender: TObject);
begin
  actRollback.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
{    and gdcObject.CanCreate
    and gdcObject.CanEdit
    and gdcObject.CanView}
    and (gdcObject.Transaction.InTransaction);
end;

procedure Tgdc_frmG.actNewExecute(Sender: TObject);
begin
  gdcObject.CreateDescendant;
end;

procedure Tgdc_frmG.actEditExecute(Sender: TObject);
begin
  //gdcObject.EditMultiple(GetMainBookmarkList);
  gdcObject.EditMultiple2(Get_SelectedKey);
end;

procedure Tgdc_frmG.actDeleteExecute(Sender: TObject);
begin
  //gdcObject.DeleteMultiple(GetMainBookmarkList);
  gdcObject.DeleteMultiple2(Get_SelectedKey);
end;

procedure Tgdc_frmG.actDuplicateExecute(Sender: TObject);
begin
  gdcObject.CopyDialog;
end;

procedure Tgdc_frmG.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FInChoose or (fsModal in FormState) then
  begin
    if FInChoose and (ModalResult <> mrOk) and Assigned(gdcChooseObject) and
      (gdcChooseObject.SelectedID.CommaText <> PreviousSelectedID.CommaText) then
    begin
      if MessageBox(Handle, 'Вы сделали изменения. Сохранить?',
        'Внимание', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES
      then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end;

    CanClose := True;
  end else
  begin
    if Assigned(GlobalStorage)
      and Assigned(IBLogin)
      and (not IBLogin.LoggingOff)
      and Assigned(DesktopManager)
      and (DesktopManager.DesktopItems.Find(Self) <> nil)
      and (not DesktopManager.LoadingDesktop)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) = 0) then
    begin
      MessageBox(Handle,
        'Изменять конфигурацию рабочего стола запрещено текущими настройками политики безопасности.',
        'Отказано в доступе',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);

      CanClose := False;
    end else
    begin
      CanClose := True;
    end;
  end;
end;

procedure Tgdc_frmG.actRollbackExecute(Sender: TObject);
begin
  if gdcObject.Transaction.InTransaction then
    gdcObject.Transaction.Rollback;
  gdcObject.CloseOpen;
end;

procedure Tgdc_frmG.actCommitExecute(Sender: TObject);
begin
  if gdcObject.State in dsEditModes then
    gdcObject.Post;
  if gdcObject.Transaction.InTransaction and
    (gdcObject.Transaction <> gdcObject.ReadTransaction) then
  begin
    gdcObject.Transaction.Commit;
  end;
  gdcObject.CloseOpen;
end;

function Tgdc_frmG.GetMainBookmarkList: TBookmarkList;
begin
  Result := nil;
end;

procedure Tgdc_frmG.actCutExecute(Sender: TObject);
begin
  gdcObject.CopyToClipboard(GetMainBookmarkList, cCut);
end;

procedure Tgdc_frmG.actCopyExecute(Sender: TObject);
begin
  gdcObject.CopyToClipboard(GetMainBookmarkList, cCopy);
end;

procedure Tgdc_frmG.actPasteExecute(Sender: TObject);
begin
  gdcObject.PasteFromClipboard;
end;

procedure Tgdc_frmG.actMacrosExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbMainInvariant do
  begin
    R := View.Find(tbiMacros).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdMacrosMenu.Popup(R.Left, R.Bottom);
end;

procedure Tgdc_frmG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Action = caHide) and (FShiftDown and not FInChoose) and (not(fsModal in FormState)) then
    Action := caFree;

  if (gdcObject <> nil)
    and (gdcObject.Transaction <> nil)
    and gdcObject.Transaction.InTransaction
    and (Action = caFree)
  then
  begin
    if MessageBox(Handle,
      'Сохранить (commit) изменения данных?',
      'Внимание',
      MB_YESNO or MB_ICONQUESTION) = IDYES then
    begin
      gdcObject.Transaction.Commit;
    end else
      gdcObject.Transaction.Rollback;
  end;
end;

procedure Tgdc_frmG.actFindExecute(Sender: TObject);
begin
  if pnlSearchMain.Visible then
    actSearchMainClose.Execute
  else begin
    {$IFDEF NEW_GRID}
    if (gdcObject is TIBCustomDataSet) and TIBCustomDataSet(gdcObject).GroupSortExist then
      MessageBox(Handle,
        'В режиме группировки записей панель поиска недоступна.',
        'Внимание',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL)
    else
    {$ENDIF}
    SetupSearchPanel(gdcObject,
      pnlSearchMain,
      sbSearchMain,
      nil{sSearchMain},
      FFieldOrigin,
      FMainPreservedConditions);
  end;
end;

procedure Tgdc_frmG.actMainReductionExecute(Sender: TObject);
begin
  gdcObject.Reduction(nil);
end;

procedure Tgdc_frmG.actPrintUpdate(Sender: TObject);
begin
  actPrint.Enabled := (gdcObject <> nil)
    and gdcObject.CanPrint
    and (gdcObject.State = dsBrowse);
end;

constructor Tgdc_frmG.Create(AnOwner: TComponent);
begin
  inherited;

  ShowSpeedButton := True;
  FInChoose := False;
  FChooseControl := nil;
  FChosenIDInOrder := nil;
  PreviousSelectedID := TgdKeyArray.Create;
end;

procedure Tgdc_frmG.actMainReductionUpdate(Sender: TObject);
begin
  actMainReduction.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and gdcObject.CanDelete
    and gdcObject.CanEdit;
end;

procedure Tgdc_frmG.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled := (gdcObject <> nil) and (gdcObject.State = dsBrowse);
  actFind.Checked := pnlSearchMain.Visible;
end;

procedure Tgdc_frmG.actFilterUpdate(Sender: TObject);
begin
  actFilter.Enabled := (gdcObject <> nil) and (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmG.FormCreate(Sender: TObject);
begin
  SetShortCut(True);

  // переодически "слетают" картинки при перестройке проекта
  // что ж, будем жестко их присваивать
  if dmImages <> nil then
  begin
    tbMainToolbar.Images := dmImages.il16x16;
    tbMainCustom.Images := dmImages.il16x16;
    tbMainInvariant.Images := dmImages.il16x16;
    tbChooseMain.Images := dmImages.il16x16;
    pmMain.Images := dmImages.il16x16;
    alMain.Images := dmImages.il16x16;
    tbMainMenu.Images := dmImages.il16x16;
  end;

  if (dsMain.DataSet <> nil) and (not dsMain.DataSet.Active) then
    dsMain.DataSet.Open;

  // калі праграміст не прысвоіў загаловак формы, альбо
  // пакінуў яго пустым, возьмем назоў бізнэс аб'екту
  if gdcObject <> nil then
  begin
    if ((Caption = Name) or (Caption = '')) then
      Caption := gdcObject.GetDisplayName(FSubType)
    else if Pos(Caption, Name) = 1 then
      Caption := StringReplace(Name, Caption, gdcObject.GetDisplayName(FSubType), []);
  end;

  gdMacrosMenu.ReloadGroup;
  if Assigned(actDontSaveSettings) then
    actDontSaveSettings.Checked := (GlobalStorage <> nil) and
      GlobalStorage.ValueExists('Options\DNSS', BuildComponentPath(Self), False);
end;

procedure Tgdc_frmG.FormResize(Sender: TObject);
begin
  sbMain.Panels[0].Width := sbMain.Width - 160;
end;

procedure Tgdc_frmG.DoOnFilterChanged(Sender: TObject);
begin
  if Assigned(gdcObject) then
  begin
    if gdcObject.HasSubSet('OnlySelected') then
    begin
      sbMain.Panels[0].Text := 'Только отмеченные записи';
      sbMain.Hint := '';
    end;

    if Assigned(gdcObject.Filter) then
    begin
      if gdcObject.Filter.FilterName > '' then
      begin
        if gdcObject.HasSubSet('OnlySelected') then
          actFilter.Hint := gdcObject.Filter.FilterString
        else
        begin
          sbMain.Panels[0].Text := 'Фильтр: ' + gdcObject.Filter.FilterName;
          sbMain.Hint := sbMain.Panels[0].Text + #13#10#13#10 + gdcObject.Filter.FilterString;
          actFilter.Hint := sbMain.Hint;
        end;
        actFilter.ImageIndex := 257;
      end else
      begin
        if gdcObject.HasSubSet('OnlySelected') then
          actFilter.Hint := ''
        else
        begin
          sbMain.Panels[0].Text := 'Нет фильтрации';
          sbMain.Hint := 'Нет фильтрации';
          actFilter.Hint := 'Фильтр';
        end;
        actFilter.ImageIndex := 20;
      end;
    end;
  end;
end;

procedure Tgdc_frmG.SetGdcObject(const Value: TgdcBase);
begin
  if FgdcObject <> Value then
  begin
    inherited;
    if dsMain.DataSet <> Value then
      dsMain.DataSet := Value;
    if FgdcObject <> nil then
    begin
      FgdcObject.OnFilterChanged := DoOnFilterChanged;
      DoOnFilterChanged(nil);
    end;
  end;
end;

procedure Tgdc_frmG.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmG.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  inherited;

  if Assigned(gdcObject) and Assigned(UserStorage) and (not FInChoose) then
  begin
    Path := BuildComponentPath(gdcObject, 'Selected');

    if (not gdcObject.HasSubSet('OnlySelected'))
      and (gdcObject.SelectedID.Count = 0) then
    begin
      UserStorage.DeleteFolder(Path);
    end else
    begin
      if (gdcObject.SelectedID.WasModified) then
        UserStorage.SaveComponent(gdcObject, gdcObject.SaveSelectedToStream, 'Selected');
      UserStorage.WriteBoolean(Path, 'OnlySelected',
        gdcObject.HasSubSet('OnlySelected'))
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmG.actPropertiesUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil) and (gdcObject.RecordCount > 0)
    and (gdcObject.State = dsBrowse)
    and gdcObject.CanView;
end;

procedure Tgdc_frmG.actPropertiesExecute(Sender: TObject);
begin
  //gdcObject.EditMultiple(GetMainBookmarkList, 'Tgdc_dlgObjectProperties');
  gdcObject.EditMultiple2(Get_SelectedKey, 'Tgdc_dlgObjectProperties');
end;

procedure Tgdc_frmG.actSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  if gdcObject <> nil then
  begin
    //gdcObject.SaveToFile;
    frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject);
    (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
  end;
end;

procedure Tgdc_frmG.actLoadFromFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  if gdcObject <> nil then
  begin
    //gdcObject.LoadFromFile;
    frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject);
    (frmStreamSaver as Tgdc_frmStreamSaver).ShowLoadForm;
    gdcObject.CloseOpen;
  end;
end;

procedure Tgdc_frmG.actSaveToFileUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil)
    and (gdcObject.RecordCount > 0)
    and (gdcObject.State = dsBrowse)
    and gdcObject.CanEdit;
end;

destructor Tgdc_frmG.Destroy;
begin
  {
  if GDC_FRMG_HOOK <> 0 then
  begin
    UnhookWindowsHookEx(GDC_FRMG_HOOK);
    GDC_FRMG_HOOK := 0;
  end;
  }

//т.к. для Choose у нас форма создается, а потом уничтожается
//будем уничтожать объект в Destroy
//  FgdcChooseObject.Free;
  if FInChoose then
    FgdcChooseObject.Free;

  if Assigned(FChosenIDInOrder) then
    FreeAndNil(FChosenIDInOrder);

  if Assigned(FgdcObject) then
    FgdcObject.OnFilterChanged := nil;

  FFieldOrigin.Free;
  LocalizeListName.Free;
  PreviousSelectedID.Free;
  FgdcLink.Free;
  inherited;
end;

procedure Tgdc_frmG.actSearchMainCloseExecute(Sender: TObject);
var
  I: Integer;
begin
  if pnlSearchMain.Visible then
  begin
    gdcObject.ExtraConditions.Text := FMainPreservedConditions;

    FreeAndNil(FFieldOrigin);

    for I := sbSearchMain.ControlCount - 1 downto 0 do
    begin
      sbSearchMain.Controls[I].Free;
    end;

    pnlSearchMain.Visible := False;
  end;  
end;

procedure Tgdc_frmG.SetupSearchPanel(Obj: TgdcBase;
  PN: TPanel;
  SB: TScrollBox;
  SP: TSplitter;
  var FO: TStringList;
  out PreservedConditions: String;
  const ShowAllFields: Boolean = False);
const
  RowHeight = 36;
var
  W, I, J, Pass: Integer;
  L: TLabel;
  E: TCustomEdit;
  F: TWinControl;
  SL: TStringList;
  TempS, S: String;
  KIA: TgdKeyIntAssoc;
  Flag: Boolean;
  St: TMemoryStream;
  Btn: TButton;
  Fld: TField;
begin
  F := nil;
  Flag := False;

  PreservedConditions := Obj.ExtraConditions.Text;

  if FO = nil then
  begin
    FO := TStringList.Create;
    J := 0;
    SL := TStringList.Create;
    KIA := TgdKeyIntAssoc.Create;
    try
      St := TMemoryStream.Create;
      try
        UserStorage.ReadStream('Options\Search', 'Rcnt', St, False);
        KIA.LoadFromStream(St);
      finally
        St.Free;
      end;

      Pass := 0;
      GetTableAlias(Obj.SelectSQL.Text, SL);
      while Pass < 2 do
      begin
        J := 0;
        for I := 0 to SL.Count - 1 do
        begin
          Fld := Obj.FieldByName(copy(SL.Names[I], 1, 31));
          if ((Fld is TNumericField) or (Fld is TStringField) or (Fld is TDateTimeField)) and
            (Fld.Visible or (copy(SL.Names[I], 1, 31) = 'ID')) then
          begin
            if (Fld.DataType = ftInteger)
              and (copy(SL.Names[I], 1, 31) <> 'ID') then
            begin
              continue;
            end;

            TempS := Obj.FieldNameByAliasName(Fld.FieldName);
            if TempS = '' then continue;

            if Pass = 0 then
            begin
              if not ShowAllFields then
              begin
                S := SL.Values[SL.Names[I]] + '.' + TempS;
                if KIA.IndexOf(Integer(Crc32_P(@S[1], Length(S), 0))) = -1 then
                  continue;
              end;
              Flag := True;
            end;

            if Fld is TDateTimeField then
            begin
              E := TxDateEdit.Create(PN);
              if Fld.DataType = ftDate then
               (E as TxDateEdit).Kind := kDate
              else if Fld.DataType = ftTime then
               (E as TxDateEdit).Kind := kTime
              else
               (E as TxDateEdit).Kind := kDateTime;
            end else
            begin
              E := TEdit.Create(PN);
            end;

            E.Parent := SB;
            E.Top := J * RowHeight + 22;
            E.Left := 4;
            E.Width := SB.Width - 8 - 14;
            E.Tag := FO.Add(SL.Values[SL.Names[I]] + '.' + TempS + '=' + IntToStr(Integer(Fld.DataType)));
            E.Visible := True;

            { TODO : не знаю, нужен ли этот хинт? }
            if (IBLogin <> nil) and IBLogin.IsUserAdmin then
            begin
              E.Hint := Obj.FieldByName(copy(SL.Names[I], 1, 31)).Origin;
              E.ShowHint := True;
            end;

            E.Text := '';

            if J = 0 then
              F := E;

            L := TLabel.Create(PN);
            L.Parent := SB;
            L.Top := J * RowHeight + 8;
            L.Left := 4;
            L.AutoSize := True;
            if LocalizeListName.Values[copy(SL.Names[I], 1, 31)] = '' then
              L.Caption := Fld.DisplayName + ':'
            else
              L.Caption := LocalizeListName.Values[copy(SL.Names[I], 1, 31)] + ':';
            L.FocusControl := E;
            L.Visible := True;

            Inc(J);
          end;
        end;

        if Flag then
          break;

        Inc(Pass);
      end;

      if (Pass = 0) and (not ShowAllFields) then
      begin
        Btn := TButton.Create(PN);
        Btn.Parent := SB;
        Btn.Top := J * RowHeight + 8 + 4;
        Btn.Left := 4;
        Btn.Width := 64;
        Btn.Height := 18;
        Btn.Visible := True;
        Btn.Caption := 'Все поля';
        Btn.OnClick := DoShowAllFields;
      end;
    finally
      SL.Free;
      KIA.Free;
    end;
  end;

  if ShowAllFields then
  begin
    if SP <> nil then
      SP.Visible := True;

    PN.Visible := True;
  end else
  begin
    W := PN.Width;
    PN.Width := 0;

    if SP <> nil then
      SP.Visible := True;

    PN.Visible := True;

    while PN.Width < (W - 32) do
    begin
      Application.ProcessMessages;
      PN.Width := PN.Width + 32;
    end;

    PN.Width := W;
  end;

  if Assigned(F) and F.CanFocus and (GetParentForm(F) = Self) then
    ActiveControl := F;
end;

procedure Tgdc_frmG.SearchExecute(Obj: TgdcBase; SB: TPanel;
  var FO: TStringList; PreservedConditions: String;
  const AFuzzy: Boolean = False);
var
  I, J, Crc32: Integer;
  OldCursor: TCursor;
  S, SV: String;
  KIA: TgdKeyIntAssoc;
  St: TMemoryStream;
begin
  KIA := TgdKeyIntAssoc.Create;
  try
    St := TMemoryStream.Create;
    try
      UserStorage.ReadStream('Options\Search', 'Rcnt', St, False);
      KIA.LoadFromStream(St);
    finally
      St.Free;
    end;

    Obj.DisableControls;
    try
      Obj.Close;
      Obj.ExtraConditions.Text := PreservedConditions;
      for I := 0 to SB.ComponentCount - 1 do
        if SB.Components[I] is TCustomEdit then
        begin

          S := FO.Names[SB.Components[I].Tag];
          Crc32 := Integer(Crc32_P(@S[1], Length(S), 0));
          J := KIA.IndexOf(Crc32);

          if TCustomEdit(SB.Components[I]).Text = '' then
          begin
            if J <> -1 then
            begin
              if KIA.ValuesByIndex[J] <= 0 then
                KIA.Delete(J)
              else
                KIA.ValuesByIndex[J] := KIA.ValuesByIndex[J] - 1;
            end;
          end else
          begin
            if J = -1 then
              KIA.Add(Crc32);
            KIA.ValuesByKey[Crc32] := 100;

            case StrToInt(FO.Values[FO.Names[SB.Components[I].Tag]]) of
              Integer(ftString):
              begin
                if TCustomEdit(SB.Components[I]).Text > '' then
                begin
                  Obj.ExtraConditions.Add(
                    Format('UPPER(%s) LIKE ''%%%s%%''', [
                      FO.Names[SB.Components[I].Tag],
                      _AnsiUpperCase(TCustomEdit(SB.Components[I]).Text)]));
                end;
              end;

              Integer(ftDate):
              begin
                if TxDateEdit(SB.Components[I]).Date > 0 then
                begin
                  Obj.ExtraConditions.Add(
                    Format('%s = ''%s''', [
                      FO.Names[SB.Components[I].Tag],
                      FormatDateTime('dd.mm.yyyy', TxDateEdit(SB.Components[I]).Date)]));
                end;
              end;

              Integer(ftTime):
              begin
                if TxDateEdit(SB.Components[I]).Time > 0 then
                begin
                  Obj.ExtraConditions.Add(
                    Format('%s = ''%s''', [
                      FO.Names[SB.Components[I].Tag],
                      FormatDateTime('hh:nn:ss', TxDateEdit(SB.Components[I]).Time)]));
                end;
              end;

              Integer(ftDateTime):
              begin
                if TxDateEdit(SB.Components[I]).DateTime > 0 then
                begin
                  if TxDateEdit(SB.Components[I]).Time > 0 then
                  begin
                    Obj.ExtraConditions.Add(
                      Format('%s = ''%s''', [
                        FO.Names[SB.Components[I].Tag],
                        FormatDateTime('dd.mm.yyyy hh:nn:ss', TxDateEdit(SB.Components[I]).DateTime)]));
                  end else
                    Obj.ExtraConditions.Add(
                      Format('CAST(%s AS DATE) = ''%s''', [
                        FO.Names[SB.Components[I].Tag],
                        FormatDateTime('dd.mm.yyyy', TxDateEdit(SB.Components[I]).Date)]));
                end;
              end;
            else
              if Trim(TCustomEdit(SB.Components[I]).Text) > '' then
              begin
                try
                  SV := StringReplace(TCustomEdit(SB.Components[I]).Text,
                    ' ', '', [rfReplaceAll]);
                  StrToFloat(SV);
                  Obj.ExtraConditions.Add(
                    Format('%s = ''%s''', [
                      FO.Names[SB.Components[I].Tag],
                      StringReplace(SV, ',', '.', [])]));
                except
                  MessageBox(Handle,
                    'Введено некорректное значение для поиска по числовому полю!',
                    'Внимание',
                    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
                end;
              end;
            end;
          end;
        end;
      try
        OldCursor := Screen.Cursor;
        try
          Screen.Cursor := crHourGlass;
          Obj.Open;
        finally
          Screen.Cursor := OldCursor;
        end;
      except
        MessageBox(Self.Handle,
          'Условия поиска не могут быть применены.',
          'Внимание',
          MB_OK or MB_ICONHAND);
        Obj.ExtraConditions.Text := PreservedConditions;
        Obj.Open;
      end;
    finally
      if not Obj.Active then
      begin
        Obj.ExtraConditions.Text := PreservedConditions;
        Obj.Open;
      end;
      Obj.EnableControls;
    end;
  finally
    St := TMemoryStream.Create;
    try
      KIA.SaveToStream(St);
      if St.Size > 0 then
        UserStorage.WriteStream('Options\Search', 'Rcnt', St);
    finally
      St.Free;
    end;

    KIA.Free;
  end;
end;

procedure Tgdc_frmG.actSearchMainExecute(Sender: TObject);
begin
  SearchExecute(gdcObject, pnlSearchMain, FFieldOrigin,
    FMainPreservedConditions, chbxFuzzyMatch.Checked);
end;

procedure Tgdc_frmG.actOnlySelectedUpdate(Sender: TObject);
begin
  actOnlySelected.Enabled :=
    (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_APPL_FILTERS_ID, GD_POL_APPL_FILTERS_MASK, False) and IBLogin.InGroup) <> 0);

  actOnlySelected.Checked := Assigned(gdcObject)
    and gdcObject.HasSubSet('OnlySelected');
end;

procedure Tgdc_frmG.actOnlySelectedExecute(Sender: TObject);
begin
  if gdcObject.HasSubSet('OnlySelected') then
  begin
    gdcObject.RemoveSubSet('OnlySelected');
  end else if gdcObject.SelectedID.Count > 0 then
  begin
    gdcObject.AddSubSet('OnlySelected');
  end;  
end;

procedure Tgdc_frmG.actAddToSelectedUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gdcObject <> nil)
    and (gdcObject.Active)
    and (not gdcObject.IsEmpty)
    and gdcObject.CanView
    and Assigned(GlobalStorage)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False) and IBLogin.InGroup) <> 0);
end;

procedure Tgdc_frmG.actAddToSelectedExecute(Sender: TObject);
begin
  gdcObject.AddToSelectedID;
end;

procedure Tgdc_frmG.actRemoveFromSelectedExecute(Sender: TObject);
begin
  gdcObject.RemoveFromSelectedID;
end;

procedure Tgdc_frmG.actOldReportExecute(Sender: TObject);
begin
  gdcObject.PopupReportMenu(-1, -1);
end;

procedure Tgdc_frmG.SetChoose(AnObject: TgdcBase);
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMG', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMG', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMG',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMG' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  FInChoose := True;

  //Список для выбранных ид в том порядке, в котором их выбрали
  FChosenIDInOrder := TStringList.Create;
  FChosenIDInOrder.Duplicates := dupIgnore;

  S := ' (режим выбора)';
  if Copy(Caption, Length(Caption) - Length(S) + 1, Length(S)) <> S then
    Caption := Caption + S;
  if FgdcLinkChoose = nil then
    FgdcLinkChoose := FgdcObject;

  Assert(FgdcLinkChoose <> nil);

  if Assigned(AnObject) then
  begin
    FgdcLinkChoose.SelectedID.Assign(AnObject.SelectedID);
    PreviousSelectedID.Assign(AnObject.SelectedID);
    FChosenIDInOrder.CommaText := AnObject.SelectedID.CommaText;
  end else
  begin
    FgdcLinkChoose.SelectedID.Clear;
    PreviousSelectedID.Clear;
  end;

//создаем объект для Choose
  FgdcChooseObject := CgdcBase(FgdcLinkChoose.ClassType).CreateSubType(Self,
    FgdcLinkChoose.SubType, 'OnlySelected');
  FgdcChooseObject.ReadTransaction := FgdcLinkChoose.ReadTransaction;
  FgdcChooseObject.SelectedID.Assign(FgdcLinkChoose.SelectedID);
  FgdcChooseObject.Open;

  inherited;

  //настройки формы при режиме Choose
  ibgrChoose.Visible := True;
  pnChoose.Visible := True;
  tbChooseMain.Visible := True;
  spChoose.Visible := True;

  dsChoose.Dataset := FgdcChooseObject;

  FChooseControl := nil;
  for I := 0 to ComponentCount - 1 do
  if (Components[I] is TgsIBGrid) and Assigned((Components[I] as TgsIBGrid).DataSource)
    and ((Components[I] as TgsIBGrid).DataSource.DataSet is TgdcBase)
    and (((Components[I] as TgsIBGrid).DataSource.DataSet as TgdcBase) = FgdcLinkChoose)
    or (Components[I] is TgsDBTreeView) and Assigned((Components[I] as TgsDBTreeView).DataSource)
    and ((Components[I] as TgsDBTreeView).DataSource.DataSet is TgdcBase)
    and (((Components[I] as TgsDBTreeView).DataSource.DataSet as TgdcBase) = FgdcLinkChoose)
  then
  begin
    FChooseControl := Components[I];
    Break;
  end;

  for I := 0 to alMain.ActionCount - 1 do
  begin
    if (alMain.Actions[I].Category = cst_st_cat_Choose) and
      (alMain.Actions[I] is TAction) then
      (alMain.Actions[I] as TAction).Visible := True;
  end;

  if Assigned(FChooseControl) and (FChooseControl is TgsIBGrid) then
  begin
    UserStorage.LoadComponent(FChooseControl, ibgrChoose.LoadFromStream);

    with (FChooseControl as TgsIBGrid) do
    begin
      CheckBox.FirstColumn := True;
      CheckBox.FieldName := gdcLinkChoose.GetKeyField(gdcLinkChoose.SubType);
      CheckBox.Visible := True;
      Options := Options - [dgMultiSelect];
      CheckBox.CheckList.CommaText := gdcLinkChoose.SelectedID.CommaText;
    end;
  end
  else
    UserStorage.LoadComponent(ibgrChoose, ibgrChoose.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMG', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMG', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmG.DoCreate;
begin
  inherited;

  LocalizeListName := TStringList.Create;

  // идея такая, что пользователь не может скрыть тулбар,
  // если на нем есть кнопки
  tbMainCustom.Visible := tbMainCustom.Items.Count > 0;
end;

procedure Tgdc_frmG.SetLocalizeListName(AGrid: TgsIBGrid);
var
  I: Integer;
begin
  LocalizeListName.Clear;
  for I := 0 to AGrid.Columns.Count - 1 do
    LocalizeListName.Add(AGrid.Columns[I].FieldName + '=' +
      AGrid.Columns[I].Title.Caption);
end;


procedure Tgdc_frmG.actQExportExecute(Sender: TObject);
{$IFDEF QEXPORT}
var
  ed: TVExportDialog;
{$ENDIF}
begin
  {$IFDEF QEXPORT}
  ed := TVExportDialog.Create(Self);
  try
    ed.DataSet := gdcObject;
    ed.Execute;
  finally
    ed.free;
  end;
  {$ENDIF}
end;

procedure Tgdc_frmG.actQExportUpdate(Sender: TObject);
begin
  {$IFDEF QEXPORT}
  actQExport.Enabled := Assigned(gdcObject) and (gdcObject.State = dsBrowse);
  {$ELSE}
  actQExport.Visible := False;
  {$ENDIF}
end;

procedure Tgdc_frmG.actChooseOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdc_frmG.actChooseOkUpdate(Sender: TObject);
begin
  actChooseOk.Enabled := (ibgrChoose.DataSource <> nil) and
    (ibgrChoose.DataSource.DataSet <> nil);
    { Choose иногда используется для указания к-л зависимостей!!!}
    {and
    (ibgrChoose.DataSource.Dataset.RecordCount > 0)}
end;

procedure Tgdc_frmG.actMainToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcObject, GetMainBookmarkList);
end;

procedure Tgdc_frmG.actMainToSettingUpdate(Sender: TObject);
begin
  actMainToSetting.Enabled := (gdcObject <> nil)
    and (gdcObject.RecordCount > 0)
    and (gdcObject.CanEdit)
    and (gdcObject.State = dsBrowse)
    and (IBLogin <> nil)
    and (IBLogin.IsUserAdmin);
end;

procedure Tgdc_frmG.LoadSettingsAfterCreate;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
  B: Boolean;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMG', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMG', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMG',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(gdcObject) and Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(gdcObject, gdcObject.LoadSelectedFromStream, 'Selected', False);
    Path := BuildComponentPath(gdcObject, 'Selected');
    B := UserStorage.ReadBoolean(Path, 'OnlySelected', False);
    if B xor gdcObject.HasSubSet('OnlySelected') then
    begin
      if B then
        gdcObject.AddSubSet('OnlySelected')
      else
        gdcObject.RemoveSubSet('OnlySelected');
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMG', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMG', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmG.AddToChooseObject(AnID: Integer);
begin
  FgdcChooseObject.AddToSelectedID(AnID);
  if FgdcChooseObject.Active then
    FgdcChooseObject.CloseOpen;

  FChosenIDInOrder.Add(IntToStr(AnID));
end;

procedure Tgdc_frmG.DeleteFromChooseObject(AnID: Integer);
begin
  FgdcChooseObject.RemoveFromSelectedID(AnID);
  if FgdcChooseObject.Active then
    FgdcChooseObject.CloseOpen;

  FChosenIDInOrder.Delete(FChosenIDInOrder.IndexOf(IntToStr(AnID)));
end;

procedure Tgdc_frmG.actDeleteChooseExecute(Sender: TObject);
var
  I: Integer;
  slID: TStringList;
begin
  slID := TStringList.Create;
  try
    FgdcChooseObject.DisableControls;
    if ibgrChoose.SelectedRows.Count > 1 then
      for I := 0 to ibgrChoose.SelectedRows.Count - 1 do
      begin
        FgdcChooseObject.Bookmark := ibgrChoose.SelectedRows[I];
        slID.Add(IntToStr(FgdcChooseObject.ID));
      end
    else
      slID.Add(IntToStr(FgdcChooseObject.ID));

    FgdcChooseObject.Close;

    for I := 0 to slID.Count - 1 do
      DeleteChoose(StrToInt(slID[I]));

    FgdcChooseObject.Open;
    FgdcChooseObject.EnableControls;
  finally
    slID.Free;
  end;
end;

procedure Tgdc_frmG.actDeleteChooseUpdate(Sender: TObject);
begin
  actDeleteChoose.Enabled := (FgdcChooseObject <> nil) and
    (FgdcChooseObject.RecordCount > 0);
end;

procedure Tgdc_frmG.DeleteChoose(AnID: Integer);
begin

end;

function Tgdc_frmG.CanStartDrag(Obj: TgdcBase): Boolean;
begin
  Result := Assigned(Obj)
    and (not Obj.IsEmpty)
    and (Obj.State = dsBrowse)
    and Obj.CanCreate
    and Obj.CanEdit
    and Obj.CanDelete;
end;

procedure Tgdc_frmG.GdcDragOver(Obj: TgdcBase; Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TgdcDragObject)
    and Obj.CanPasteFromClipboard;
end;

procedure Tgdc_frmG.actCopySettingsFromUserExecute(Sender: TObject);
{$INCLUDE copy_user_settings.pas}

procedure Tgdc_frmG.actMacrosUpdate(Sender: TObject);
begin
  actMacros.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and Assigned(GlobalStorage)
    and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK, False) and IBLogin.InGroup) <> 0);
end;

function Tgdc_frmG.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  if  UpperCase(Name) = 'SETCHOOSE' then
  begin
    SetChoose(InterfaceToObject(AnParams[1]) as TgdcBase);
  end else
    Result := Inherited OnInvoker(Name, AnParams);
end;

class procedure Tgdc_frmG.RegisterMethod;
begin
  RegisterFrmClassMethod(Tgdc_frmG, 'SetChoose', 'Self: Object; AnObject: Object', '');
end;

constructor Tgdc_frmG.CreateUser(AnOwner: TComponent; const AFormName,
  ASubType: String; const AForEdit: Boolean);
begin
  inherited;
  ShowSpeedButton := True;
  FInChoose := False;
  FChooseControl := nil;
  PreviousSelectedID := TgdKeyArray.Create;

end;

procedure Tgdc_frmG.actSelectAllExecute(Sender: TObject);
var
  I: Integer;
  IsTree: Boolean;
begin
  IsTree := False;
  if Assigned(FChooseControl) then
    if (FChooseControl is TgsDBTreeView) then
      IsTree := True
    else
      IsTree := False;


  gdcLinkChoose.DisableControls;
  gdcChooseObject.DisableControls;
  gdcChooseObject.Close;
  gdcLinkChoose.First;
  I := 0;
  while not gdcLinkChoose.Eof do
  begin
    Inc(I);
    if (I mod 1000) = 0 then
      if MessageBox(Handle, 'Записей слишком много! Продолжить выделение?',
        'Внимание!', MB_ICONEXCLAMATION or MB_YESNO) = IDNO
      then
        Break;

    if Assigned(FChooseControl) then
    begin
      if IsTree then
        (FChooseControl as TgsDBTreeView).AddCheck(gdcLinkChoose.ID)
      else
        (FChooseControl as TgsIBGrid).CheckBox.AddCheck(gdcLinkChoose.ID);
    end;

    gdcLinkChoose.AddToSelectedID;
    gdcLinkChoose.Next;
  end;
  gdcLinkChoose.First;
  gdcLinkChoose.EnableControls;
  gdcChooseObject.Open;
  gdcChooseObject.EnableControls;
end;

procedure Tgdc_frmG.actSelectAllUpdate(Sender: TObject);
begin
  actSelectAll.Enabled := (gdcLinkChoose <> nil) and (gdcLinkChoose.RecordCount > 0);
end;

procedure Tgdc_frmG.actUnSelectAllExecute(Sender: TObject);
var
  I: Integer;
  IsTree: Boolean;
begin
  IsTree := False;
  if Assigned(FChooseControl) then
    if (FChooseControl is TgsDBTreeView) then
      IsTree := True
    else
      IsTree := False;


  gdcLinkChoose.DisableControls;
  gdcChooseObject.DisableControls;
  gdcChooseObject.Close;
  gdcLinkChoose.First;
  I := 0;
  while not gdcLinkChoose.Eof do
  begin
    Inc(I);
    if (I mod 1000) = 0 then
      if MessageBox(Handle, 'Записей слишком много! Продолжить выделение?',
        'Внимание!', MB_ICONEXCLAMATION or MB_YESNO) = IDNO
      then
        Break;

    if Assigned(FChooseControl) then
    begin
      if IsTree then
        (FChooseControl as TgsDBTreeView).DeleteCheck(gdcLinkChoose.ID)
      else
        (FChooseControl as TgsIBGrid).CheckBox.DeleteCheck(gdcLinkChoose.ID);
    end;

    gdcLinkChoose.RemoveFromSelectedID;
    gdcLinkChoose.Next;
  end;
  gdcLinkChoose.First;
  gdcLinkChoose.EnableControls;
  gdcChooseObject.Open;
  gdcChooseObject.EnableControls;
end;

procedure Tgdc_frmG.actUnSelectAllUpdate(Sender: TObject);
begin
  if Assigned(FChooseControl) then
  begin
    if FChooseControl is TgsIBGrid then
      actUnSelectAll.Enabled := (FChooseControl as TgsIBGrid).CheckBox.CheckCount > 0
    else
      actUnSelectAll.Enabled := (FChooseControl as TgsDBTreeView).TVState.Checked.Count > 0
  end else
    actUnSelectAll.Enabled := False;
end;

procedure Tgdc_frmG.actClearSelectionExecute(Sender: TObject);
begin
  gdcChooseObject.DisableControls;
  gdcChooseObject.Close;

  if Assigned(FChooseControl) then
  begin
    if (FChooseControl is TgsIBGrid) then
    begin
      with (FChooseControl as TgsIBGrid).CheckBox do
        while CheckList.Count > 0 do
          DeleteCheck(CheckList[CheckList.Count - 1]);
    end else
    begin
      with (FChooseControl as TgsDBTreeView) do
        while TVState.Checked.Count > 0 do
          DeleteCheck(TVState.Checked[TVState.Checked.Count - 1]);
    end;
  end;
  gdcLinkChoose.SelectedID.Clear;

  gdcChooseObject.Open;
  gdcChooseObject.EnableControls;
end;

procedure Tgdc_frmG.actClearSelectionUpdate(Sender: TObject);
begin
  if Assigned(FChooseControl) then
  begin
    if FChooseControl is TgsIBGrid then
      actClearSelection.Enabled := (FChooseControl as TgsIBGrid).CheckBox.CheckCount > 0
    else
      actClearSelection.Enabled := (FChooseControl as TgsDBTreeView).TVState.Checked.Count > 0
  end else
    actClearSelection.Enabled := False;
end;

procedure Tgdc_frmG.actSearchMainUpdate(Sender: TObject);
begin
  actSearchMain.Enabled := pnlSearchMain.Visible;
end;

{procedure Tgdc_frmG.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (fsModal in Self.FormState) and
    ((X < 0) or (Y < 0) or (X > Width) or (Y > Height)) then
  begin
    MessageBox(Handle,
      'Закройте текущее окно, чтобы иметь возможность работать с другими окнами.',
      'Внимание',
      MB_OK or MB_ICONINFORMATION);
  end;
end;}

procedure Tgdc_frmG.actHlpExecute(Sender: TObject);
var
  HelpID: String;
begin
  HelpID := gdcObject.GetDisplayName(gdcObject.SubType);
  {if gdcObject is TgdcDocument then
    HelpID := HelpID + ' ' + TgdcDocument(gdcObject).DocumentName(False);}
  ShowHelp(HelpID + ' (форма)');
end;

procedure Tgdc_frmG.FormDestroy(Sender: TObject);
begin
//Пришлось вернуть, из-за того, что ссылка могла прописаться в наших ДФМ
end;

procedure Tgdc_frmG.actCopySettingsFromUserUpdate(Sender: TObject);
begin
  actCopySettingsFromUser.Enabled := Assigned(GlobalStorage)
    and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False) and IBLogin.InGroup) <> 0);
end;

(*
procedure Tgdc_frmG.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if Assigned(GlobalStorage)
    and Assigned(IBLogin)
    and Assigned(DesktopManager)
    and (DesktopManager.DesktopItems.Find(Self) <> nil)
    and (not DesktopManager.LoadingDesktop)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_DESK_ID, GD_POL_DESK_MASK, False) and IBLogin.InGroup) = 0) then
  begin
  {  MessageBox(Handle,
      'Изменять конфигурацию рабочего стола запрещено текущими настройками политики безопасности.',
      'Отказано в доступе',
      MB_OK or MB_ICONHAND or MB_TASKMODAL); }
    Resize := False;
  end;
end;
*)

procedure Tgdc_frmG.FormShow(Sender: TObject);
begin
  {
  if (fsModal in FormState) and (BorderStyle = bsSizeable) then
  begin
    if GDC_FRMG_HOOK = 0 then
      GDC_FRMG_HOOK := SetWindowsHookEx(WH_MOUSE, @gdc_frmG_Hook_Proc, HINSTANCE, GetCurrentThreadID);
  end;
  }
end;

procedure Tgdc_frmG.FormHide(Sender: TObject);
begin
  {
  if GDC_FRMG_HOOK <> 0 then
  begin
    UnhookWindowsHookEx(GDC_FRMG_HOOK);
    GDC_FRMG_HOOK := 0;
  end;
  }
end;

function Tgdc_frmG.GetChosenIDInOrder: OleVariant;
var
  V: OleVariant;
  I: Integer;
begin
  if not FInChoose then
    raise Exception.Create('Форма не в режиме выбора!');

  if Assigned(FChosenIDInOrder) then
  begin
    V := VarArrayCreate([0, FChosenIDInOrder.Count - 1], varVariant);
    for I := 0 to FChosenIDInOrder.Count - 1 do
    begin
      V[I] := StrToInt(FChosenIDInOrder[I]);
    end;
  end else
    V := VarArrayOf([]);

  Result := V;
end;

procedure Tgdc_frmG.tbMainInvariantVisibleChanged(Sender: TObject);
begin
  {Это что за фигня????? Кажется отладочную информацию нужно помещать в условную компиляциую}
// ShowMessage('1');
end;

procedure Tgdc_frmG.actLinkObjectUpdate(Sender: TObject);
begin
  actLinkObject.Enabled := Assigned(gdcObject)
    and (gdcObject.State in [dsBrowse, dsEdit])
    and (not gdcObject.IsEmpty)
    and gdcObject.CanView;
end;

procedure Tgdc_frmG.actLinkObjectExecute(Sender: TObject);
var
  R: TRect;
begin
  if FgdcLink = nil then
  begin
    FgdcLink := TgdcLink.Create(nil);
  end;

  with tbMainToolbar do
  begin
    R := View.Find(tbiLinkObject).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;

  FgdcLink.ObjectKey := gdcObject.ID;
  FgdcLink.PopupMenu(R.Left, R.Bottom);
end;

procedure Tgdc_frmG.pnlSearchMainEnter(Sender: TObject);
begin
  btnOkChoose.Default := False;
end;

procedure Tgdc_frmG.pnlSearchMainExit(Sender: TObject);
begin
  btnOkChoose.Default := True;
end;

procedure Tgdc_frmG.actDistributeSettingsUpdate(Sender: TObject);
begin
  actDistributeSettings.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin;
end;

procedure Tgdc_frmG.DoShowAllFields(Sender: TObject);
var
  I: Integer;
begin
  if pnlSearchMain.Visible then
  begin
    gdcObject.ExtraConditions.Text := FMainPreservedConditions;
    FreeAndNil(FFieldOrigin);

    for I := sbSearchMain.ControlCount - 1 downto 0 do
    begin
      sbSearchMain.Controls[I].Free;
    end;

    SetupSearchPanel(gdcObject,
      pnlSearchMain,
      sbSearchMain,
      nil{sSearchMain},
      FFieldOrigin,
      FMainPreservedConditions,
      True);
  end;
end;

procedure Tgdc_frmG.actDontSaveSettingsUpdate(Sender: TObject);
begin
  actDontSaveSettings.Enabled := (IBLogin <> nil) and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_frmG.actDontSaveSettingsExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if GlobalStorage <> nil then
  begin
    if actDontSaveSettings.Checked then
    begin
      GlobalStorage.DeleteValue('Options\DNSS', BuildComponentPath(Self), False);
      F := GlobalStorage.OpenFolder('Options\DNSS', False, False);
      if (F <> nil) and (F.ValuesCount = 0) then
        F.DropFolder
      else
        GlobalStorage.CloseFolder(F, False);
    end else
      GlobalStorage.WriteBoolean('Options\DNSS', BuildComponentPath(Self), True);
    actDontSaveSettings.Checked := not actDontSaveSettings.Checked;
  end;
end;

procedure Tgdc_frmG.actDistributeSettingsExecute(Sender: TObject);
{$INCLUDE distribute_user_settings.pas}

procedure Tgdc_frmG.actHlpUpdate(Sender: TObject);
begin
  actHlp.Enabled := gdcObject <> nil;
end;

initialization
  RegisterFrmClass(Tgdc_frmG);
  Tgdc_frmG.RegisterMethod;

finalization
  UnRegisterFrmClass(Tgdc_frmG);

end.
