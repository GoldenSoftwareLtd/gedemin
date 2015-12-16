unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, StdCtrls, ExtCtrls,
  Menus, gdcBase, IBDatabase, gdcNamespaceSyncController;

type
  TIterateProc = procedure (const AData: String) of object;
  
  Tat_frmSyncNamespace = class(TCreateableForm)
    ds: TDataSource;
    sb: TStatusBar;
    TBDock: TTBDock;
    TBToolbar: TTBToolbar;
    gr: TgsDBGrid;
    ActionList: TActionList;
    actChooseDir: TAction;
    TBItem1: TTBItem;
    actCompare: TAction;
    TBItem2: TTBItem;
    splMessages: TSplitter;
    pmSync: TPopupMenu;
    actEditNamespace: TAction;
    actEditNamespace1: TMenuItem;
    actEditFile: TAction;
    N1: TMenuItem;
    actCompareWithData: TAction;
    N2: TMenuItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    actSetForSaving: TAction;
    actSetForLoading: TAction;
    actClear: TAction;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    tbedPath: TEdit;
    TBControlItem2: TTBControlItem;
    N7: TMenuItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    actSync: TAction;
    TBItem11: TTBItem;
    actDeleteFile: TAction;
    N10: TMenuItem;
    TBSeparatorItem5: TTBSeparatorItem;
    tbiFLTOnlyInFile: TTBItem;
    tbiFLTOnlyInDB: TTBItem;
    tbiFLTEqual: TTBItem;
    tbiFLTOlder: TTBItem;
    tbiFLTNewer: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    lSearch: TLabel;
    edFilter: TEdit;
    TBControlItem3: TTBControlItem;
    actFLTOnlyInDB: TAction;
    actFLTEqual: TAction;
    actFLTOlder: TAction;
    actFLTNewer: TAction;
    tbiFLTNone: TTBItem;
    actFLTNone: TAction;
    actFLTOnlyInFile: TAction;
    cbPackets: TCheckBox;
    TBControlItem4: TTBControlItem;
    actFLTInternal: TAction;
    TBItem12: TTBItem;
    actFLTEqualOlder: TAction;
    actFLTEqualNewer: TAction;
    actFLTInUses: TAction;
    TBItem13: TTBItem;
    TBItem14: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    chbxUpdate: TCheckBox;
    TBControlItem5: TTBControlItem;
    TBSeparatorItem8: TTBSeparatorItem;
    actSelectAll: TAction;
    actSelectAll1: TMenuItem;
    pnlHeader: TPanel;
    N8: TMenuItem;
    N9: TMenuItem;
    N11: TMenuItem;
    TBItem3: TTBItem;
    actFLTSave: TAction;
    TBItem7: TTBItem;
    actFLTLoad: TAction;
    TBItem15: TTBItem;
    mMessages: TRichEdit;
    TBSeparatorItem2: TTBSeparatorItem;
    tbsiSetForLoading: TTBSubmenuItem;
    actSetForLoadingOne: TAction;
    TBItem16: TTBItem;
    tbsiClear: TTBSubmenuItem;
    actClearAll: TAction;
    TBItem17: TTBItem;
    tbsiCompare: TTBSubmenuItem;
    actOnlyCompare: TAction;
    TBItem18: TTBItem;
    TBControlItem6: TTBControlItem;
    chbxExisted: TCheckBox;
    N12: TMenuItem;
    actShowChanged: TAction;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem19: TTBItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    procedure actChooseDirExecute(Sender: TObject);
    procedure actCompareUpdate(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure actEditNamespaceUpdate(Sender: TObject);
    procedure actEditNamespaceExecute(Sender: TObject);
    procedure actEditFileUpdate(Sender: TObject);
    procedure actEditFileExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCompareWithDataUpdate(Sender: TObject);
    procedure actCompareWithDataExecute(Sender: TObject);
    procedure actSetForLoadingUpdate(Sender: TObject);
    procedure actSetForLoadingExecute(Sender: TObject);
    procedure actSetForSavingUpdate(Sender: TObject);
    procedure actSetForSavingExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actSyncUpdate(Sender: TObject);
    procedure actSyncExecute(Sender: TObject);
    procedure actDeleteFileUpdate(Sender: TObject);
    procedure actDeleteFileExecute(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure actFLTOnlyInDBExecute(Sender: TObject);
    procedure actFLTOnlyInDBUpdate(Sender: TObject);
    procedure actFLTInternalExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actFLTSaveExecute(Sender: TObject);
    procedure actFLTLoadExecute(Sender: TObject);
    procedure actFLTSaveUpdate(Sender: TObject);
    procedure actFLTLoadUpdate(Sender: TObject);
    procedure actFLTInternalUpdate(Sender: TObject);
    procedure actSetForLoadingOneUpdate(Sender: TObject);
    procedure actSetForLoadingOneExecute(Sender: TObject);
    procedure actClearAllExecute(Sender: TObject);
    procedure actOnlyCompareExecute(Sender: TObject);
    procedure actOnlyCompareUpdate(Sender: TObject);
    procedure actClearAllUpdate(Sender: TObject);
    procedure actShowChangedExecute(Sender: TObject);
    procedure actShowChangedUpdate(Sender: TObject);

  private
    FNSC: TgdcNamespaceSyncController;

    procedure ApplyFilter;
    procedure IterateSelected(Proc: TIterateProc; const AData: String = '');
    procedure SetOperation(const AData: String);
    procedure DeleteFile(const AData: String);
    procedure Log(const AMessageType: TLogMessageType; const S: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  at_frmSyncNamespace: Tat_frmSyncNamespace;

implementation

{$R *.DFM}

uses
  FileCtrl, gd_GlobalParams_unit, gd_ExternalEditor, jclStrings, Storages,
  gdcNamespaceLoader;

procedure Tat_frmSyncNamespace.actChooseDirExecute(Sender: TObject);
var
  Dir: String;
begin
  if SelectDirectory('Корневая папка с файлами пространств имен:', '', Dir) then
    tbedPath.Text := Dir;
end;

procedure Tat_frmSyncNamespace.actCompareUpdate(Sender: TObject);
begin
  actCompare.Enabled := DirectoryExists(tbedPath.Text);
end;

procedure Tat_frmSyncNamespace.actCompareExecute(Sender: TObject);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    FNSC.UpdateCurrModified := chbxUpdate.Checked;
    FNSC.Directory := tbedPath.Text;
    FNSC.Scan(True, chbxExisted.Checked, True);
    ApplyFilter;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure Tat_frmSyncNamespace.actEditNamespaceUpdate(Sender: TObject);
begin
  actEditNamespace.Enabled := (not FNSC.DataSet.IsEmpty)
    and (FNSC.DataSet.FieldByName('namespacekey').AsInteger > 0);
end;

procedure Tat_frmSyncNamespace.actEditNamespaceExecute(Sender: TObject);
begin
  FNSC.EditNamespace(FNSC.DataSet.FieldByName('namespacekey').AsInteger);
end;

procedure Tat_frmSyncNamespace.actEditFileUpdate(Sender: TObject);
begin
  actEditFile.Enabled := (not FNSC.DataSet.IsEmpty)
    and FileExists(FNSC.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actEditFileExecute(Sender: TObject);
begin
  InvokeExternalEditor('yaml',
    FNSC.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.FormCreate(Sender: TObject);
begin
  ds.DataSet := FNSC.DataSet;
  tbedPath.Text := FNSC.Directory;
end;

procedure Tat_frmSyncNamespace.actCompareWithDataUpdate(Sender: TObject);
begin
  actCompareWithData.Enabled := (not FNSC.DataSet.IsEmpty)
    and FileExists(FNSC.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actCompareWithDataExecute(Sender: TObject);
begin
  FNSC.CompareWithData(
    FNSC.DataSet.FieldByName('namespacekey').AsInteger,
    FNSC.DataSet.FieldByName('filename').AsString,
    True);
end;

constructor Tat_frmSyncNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
  FNSC := TgdcNamespaceSyncController.Create;
  FNSC.OnLogMessage := Log;
end;

destructor Tat_frmSyncNamespace.Destroy;
begin
  FNSC.Free;
  inherited;
end;

procedure Tat_frmSyncNamespace.IterateSelected(Proc: TIterateProc;
  const AData: String = '');
var
  I: Integer;
  Bm: String;
begin
  gr.SelectedRows.Refresh;
  if gr.SelectedRows.Count > 1 then
  begin
    Bm := FNSC.DataSet.Bookmark;
    FNSC.DataSet.DisableControls;
    try
      for I := 0 to gr.SelectedRows.Count - 1 do
      begin
        FNSC.DataSet.Bookmark := gr.SelectedRows[I];
        Proc(AData);
        UpdateWindow(mMessages.Handle);
      end;
      if FNSC.DataSet.BookmarkValid(Pointer(Bm)) then
        FNSC.DataSet.Bookmark := Bm;
    finally
      FNSC.DataSet.EnableControls;
    end;
  end
  else if not FNSC.DataSet.IsEmpty then
    Proc(AData);
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingUpdate(Sender: TObject);
begin
  actSetForLoading.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '<<');
  if (FNSC.FilterOperation > '') and (not actFLTLoad.Checked) then
    actFLTLoad.Execute;
end;

procedure Tat_frmSyncNamespace.SetOperation(const AData: String);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    FNSC.SetOperation(AData);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure Tat_frmSyncNamespace.actSetForSavingUpdate(Sender: TObject);
begin
  actSetForSaving.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForSavingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '>>');
  if (FNSC.FilterText > '') and (not actFLTOlder.Checked) then
    actFLTOlder.Execute;
end;

procedure Tat_frmSyncNamespace.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actClearExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '  ');
end;

procedure Tat_frmSyncNamespace.actSyncUpdate(Sender: TObject);
begin
  actSync.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSyncExecute(Sender: TObject);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    FNSC.Sync;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure Tat_frmSyncNamespace.actDeleteFileUpdate(Sender: TObject);
begin
  actDeleteFile.Enabled := (not FNSC.DataSet.IsEmpty)
    and (not FNSC.DataSet.FieldByName('filetimestamp').IsNull);
end;

procedure Tat_frmSyncNamespace.DeleteFile(const AData: String);
begin
  FNSC.DeleteFile(
    FNSC.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actDeleteFileExecute(Sender: TObject);
begin
  IterateSelected(DeleteFile);
end;

procedure Tat_frmSyncNamespace.Log(const AMessageType: TLogMessageType; const S: String);
var
  OldColor: TColor;
begin
  OldColor := mMessages.SelAttributes.Color;
  mMessages.SelStart := mMessages.GetTextLen;
  case AMessageType of
    lmtInfo: mMessages.SelAttributes.Color := clBlack;
    lmtWarning: mMessages.SelAttributes.Color := clMaroon;
    lmtError: mMessages.SelAttributes.Color := clRed;
  end;
  mMessages.SelText := FormatDateTime('hh:nn:ss ', Now) + S + #13#10;
  mMessages.SelAttributes.Color := OldColor;
end;

procedure Tat_frmSyncNamespace.ApplyFilter;
begin
  gr.SelectedRows.Clear;
  FNSC.ApplyFilter;
  if FNSC.Filtered then
  begin
    sb.SimpleText := 'К данным применен фильтр.';
    if FNSC.FilterOnlyPackages then
      sb.SimpleText := sb.SimpleText + ' Отображаются только пакеты.';
  end else
    sb.SimpleText := '';
end;

procedure Tat_frmSyncNamespace.edFilterChange(Sender: TObject);
begin
  FNSC.FilterText := edFilter.Text;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBExecute(Sender: TObject);
begin
  if (Sender as TAction).Checked  then
  begin
    FNSC.FilterOperation :=
      StringReplace(FNSC.FilterOperation,
        (Sender as TAction).Caption, '', [rfReplaceAll]);
  end else
  begin
    FNSC.FilterOperation :=
      FNSC.FilterOperation +
      (Sender as TAction).Caption;
  end;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked := Pos((Sender as TAction).Caption, FNSC.FilterOperation) > 0;
  (Sender as TAction).Enabled := FNSC.DataSet.Active;
end;

procedure Tat_frmSyncNamespace.actFLTInternalExecute(Sender: TObject);
begin
  FNSC.FilterOnlyPackages := cbPackets.Checked;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actSelectAllExecute(Sender: TObject);
var
  Bm, FirstBm: String;
  FirstSet, InGroup: Boolean;
begin
  FirstSet := False;
  InGroup := False;
  Bm := FNSC.DataSet.Bookmark;
  FNSC.DataSet.DisableControls;
  try
    gr.SelectedRows.Clear;
    FNSC.DataSet.First;
    while not FNSC.DataSet.Eof do
    begin
      if (not FNSC.DataSet.FieldByName('namespacename').IsNull)
        or (not FNSC.DataSet.FieldByName('fileruid').IsNull) then
      begin
        if not FirstSet then
        begin
          FirstSet := True;
          FirstBm := FNSC.DataSet.Bookmark;
        end;

        if FNSC.DataSet.Bookmark = Bm then
          InGroup := True;

        gr.SelectedRows.CurrentRowSelected := True;
      end;
      FNSC.DataSet.Next;
    end;

    if (not InGroup) and FirstSet then
      FNSC.DataSet.Bookmark := FirstBm
    else
      FNSC.DataSet.Bookmark := Bm;
  finally
    FNSC.DataSet.EnableControls;
  end;
end;

procedure Tat_frmSyncNamespace.actSelectAllUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actFLTSaveExecute(Sender: TObject);
begin
  if actFLTSave.Checked then
  begin
    actFLTOnlyInDB.Execute;
    actFLTOlder.Execute;
    actFLTEqualOlder.Execute;
  end else
  begin
    if not actFLTOnlyInDB.Checked then
      actFLTOnlyInDB.Execute;
    if not actFLTOlder.Checked then
      actFLTOlder.Execute;
    if not actFLTEqualOlder.Checked then
      actFLTEqualOlder.Execute;
  end;
end;

procedure Tat_frmSyncNamespace.actFLTLoadExecute(Sender: TObject);
begin
  if actFLTLoad.Checked then
  begin
    actFLTOnlyInFile.Execute;
    actFLTNewer.Execute;
    actFLTEqualNewer.Execute;
  end else
  begin
    if not actFLTOnlyInFile.Checked then
      actFLTOnlyInFile.Execute;
    if not actFLTNewer.Checked then
      actFLTNewer.Execute;
    if not actFLTEqualNewer.Checked then
      actFLTEqualNewer.Execute;
  end;
end;

procedure Tat_frmSyncNamespace.actFLTSaveUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FNSC.DataSet.Active;
  (Sender as TAction).Checked := actFLTOnlyInDB.Checked
    and actFLTOlder.Checked and actFLTEqualOlder.Checked;
end;

procedure Tat_frmSyncNamespace.actFLTLoadUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FNSC.DataSet.Active;
  (Sender as TAction).Checked := actFLTOnlyInFile.Checked
    and actFLTNewer.Checked and actFLTEqualNewer.Checked;
end;

procedure Tat_frmSyncNamespace.actFLTInternalUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := FNSC.DataSet.Active;
  edFilter.Enabled := FNSC.DataSet.Active;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingOneUpdate(Sender: TObject);
begin
  actSetForLoadingOne.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingOneExecute(Sender: TObject);
begin
  FNSC.SetOperation('<<', False);
  ApplyFilter;
  if (FNSC.FilterOperation > '') and (not actFLTLoad.Checked) then
    actFLTLoad.Execute;
end;

procedure Tat_frmSyncNamespace.actClearAllExecute(Sender: TObject);
begin
  FNSC.ClearAll;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actOnlyCompareExecute(Sender: TObject);
begin
  FNSC.CompareWithData(
    FNSC.DataSet.FieldByName('namespacekey').AsInteger,
    FNSC.DataSet.FieldByName('filename').AsString,
    False);
end;

procedure Tat_frmSyncNamespace.actOnlyCompareUpdate(Sender: TObject);
begin
  actOnlyCompare.Enabled := (not FNSC.DataSet.IsEmpty)
    and FileExists(FNSC.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actClearAllUpdate(Sender: TObject);
begin
  actClearAll.Enabled := not FNSC.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actShowChangedExecute(Sender: TObject);
begin
  FNSC.ShowChanged;
end;

procedure Tat_frmSyncNamespace.actShowChangedUpdate(Sender: TObject);
begin
  actShowChanged.Enabled := (not FNSC.DataSet.IsEmpty)
    and (not FNSC.DataSet.FieldByName('namespacekey').IsNull);
end;

procedure Tat_frmSyncNamespace.LoadSettings;
begin
  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(gr, gr.LoadFromStream);
end;

procedure Tat_frmSyncNamespace.SaveSettings;
begin
  if Assigned(UserStorage) and (gr.SettingsModified or (cfsDistributeSettings in CreateableFormState)) then
    UserStorage.SaveComponent(gr, gr.SaveToStream);

  inherited;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
