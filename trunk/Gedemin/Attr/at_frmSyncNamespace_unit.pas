unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, DBClient,
  StdCtrls, ExtCtrls, Menus, dmDatabase_unit, IBCustomDataSet, gdcBase,
  gdcNamespace, IBDatabase, gsNSObjects, gdcNamespaceSyncController;

type
  TIterateProc = procedure (const AData: String) of object;
  
  Tat_frmSyncNamespace = class(TCreateableForm)
    cds: TClientDataSet;
    ds: TDataSource;
    sb: TStatusBar;
    TBDock: TTBDock;
    TBToolbar: TTBToolbar;
    gr: TgsDBGrid;
    cdsNamespacekey: TIntegerField;
    cdsNamespaceName: TStringField;
    cdsNamespaceVersion: TStringField;
    cdsNamespaceTimeStamp: TDateTimeField;
    cdsOperation: TStringField;
    cdsFileName: TStringField;
    cdsFileTimeStamp: TDateTimeField;
    cdsFileVersion: TStringField;
    cdsFileSize: TIntegerField;
    ActionList: TActionList;
    actChooseDir: TAction;
    TBItem1: TTBItem;
    actCompare: TAction;
    TBItem2: TTBItem;   
    mMessages: TMemo;
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
    cdsFileRUID: TStringField;
    cdsFileInternal: TIntegerField;
    cbPackets: TCheckBox;
    TBControlItem4: TTBControlItem;
    actFLTInternal: TAction;
    cdsNamespaceInternal: TIntegerField;
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
    cdsHiddenRow: TIntegerField;
    Panel1: TPanel;
    N8: TMenuItem;
    N9: TMenuItem;
    N11: TMenuItem;
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

  private
    FNSList: TgsNSList;
    FgdcNamespaceSyncController: TgdcNamespaceSyncController;

    procedure ApplyFilter;
    procedure IterateSelected(Proc: TIterateProc; const AData: String = '');
    procedure SetOperation(const AData: String);
    procedure DeleteFile(const AData: String);
    procedure Log(const S: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;
  end;

var
  at_frmSyncNamespace: Tat_frmSyncNamespace;

implementation

{$R *.DFM}

uses
  FileCtrl, gd_GlobalParams_unit, gd_ExternalEditor, jclStrings,
  at_dlgCheckOperation_unit, gdcNamespaceLoader;

procedure Tat_frmSyncNamespace.actChooseDirExecute(Sender: TObject);
var
  Dir: String;
begin
  if SelectDirectory('Корневая папка с файлами пространств имен:', '', Dir) then
  begin
    tbedPath.Text := Dir;
    actCompare.Execute;
  end;
end;

procedure Tat_frmSyncNamespace.actCompareUpdate(Sender: TObject);
begin
  actCompare.Enabled := DirectoryExists(tbedPath.Text);
end;

procedure Tat_frmSyncNamespace.actCompareExecute(Sender: TObject);
begin
  FgdcNamespaceSyncController.UpdateCurrModified := chbxUpdate.Checked;
  FgdcNamespaceSyncController.Directory := tbedPath.Text;
  FgdcNamespaceSyncController.Scan;

  cds.DisableControls;
  try
    cds.EmptyDataSet;
    FNSList.Clear;
    FNSList.GetFilesForPath(tbedPath.Text);
    TgdcNamespace.ScanDirectory(cds, FNSList, Log);
    gr.SelectedRows.Clear;
  finally
    cds.EnableControls;
  end;
end;

procedure Tat_frmSyncNamespace.LoadSettingsAfterCreate;
begin
  inherited;
  tbedPath.Text := FgdcNamespaceSyncController.Directory;
end;

procedure Tat_frmSyncNamespace.SaveSettings;
begin
  inherited;
end;

procedure Tat_frmSyncNamespace.actEditNamespaceUpdate(Sender: TObject);
begin
  actEditNamespace.Enabled := (not FgdcNamespaceSyncController.DataSet.IsEmpty)
    and (FgdcNamespaceSyncController.DataSet.FieldByName('namespacekey').AsInteger > 0);
end;

procedure Tat_frmSyncNamespace.actEditNamespaceExecute(Sender: TObject);
begin
  FgdcNamespaceSyncController.EditNamespace;
end;

procedure Tat_frmSyncNamespace.actEditFileUpdate(Sender: TObject);
begin
  actEditFile.Enabled := (not FgdcNamespaceSyncController.DataSet.IsEmpty)
    and FileExists(FgdcNamespaceSyncController.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actEditFileExecute(Sender: TObject);
begin
  InvokeExternalEditor('yaml',
    FgdcNamespaceSyncController.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.FormCreate(Sender: TObject);
begin
  ds.DataSet := FgdcNamespaceSyncController.DataSet;
end;

procedure Tat_frmSyncNamespace.actCompareWithDataUpdate(Sender: TObject);
begin
  actCompareWithData.Enabled := (not FgdcNamespaceSyncController.DataSet.IsEmpty)
    and FileExists(FgdcNamespaceSyncController.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actCompareWithDataExecute(Sender: TObject);
begin
  FgdcNamespaceSyncController.CompareWithData(
    FgdcNamespaceSyncController.DataSet.FieldByName('filename').AsString);
end;

constructor Tat_frmSyncNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
  FNSList := TgsNSList.Create;
  FNSList.Sorted := False;
  FNSList.Log := Log;
  FgdcNamespaceSyncController := TgdcNamespaceSyncController.Create;
  FgdcNamespaceSyncController.OnLogMessage := Log;
end;

destructor Tat_frmSyncNamespace.Destroy;
begin
  FgdcNamespaceSyncController.Free;
  FNSList.Free;
  inherited;
end;

procedure Tat_frmSyncNamespace.IterateSelected(Proc: TIterateProc;
  const AData: String = '');
var
  I: Integer;
  Bm: String;
begin
  gr.SelectedRows.Refresh;
  if gr.SelectedRows.Count > 0 then
  begin
    Bm := FgdcNamespaceSyncController.DataSet.Bookmark;
    FgdcNamespaceSyncController.DataSet.DisableControls;
    try
      for I := 0 to gr.SelectedRows.Count - 1 do
      begin
        FgdcNamespaceSyncController.DataSet.Bookmark := gr.SelectedRows[I];
        Proc(AData);
        UpdateWindow(mMessages.Handle);
      end;
      if FgdcNamespaceSyncController.DataSet.BookmarkValid(Pointer(Bm)) then
        FgdcNamespaceSyncController.DataSet.Bookmark := Bm;
    finally
      FgdcNamespaceSyncController.DataSet.EnableControls;
    end;
  end
  else if not FgdcNamespaceSyncController.DataSet.IsEmpty then
    Proc(AData);
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingUpdate(Sender: TObject);
begin
  actSetForLoading.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '<<');
  if (FgdcNamespaceSyncController.FilterText > '') and (not actFLTNewer.Checked) then
    actFLTNewer.Execute;
end;

procedure Tat_frmSyncNamespace.SetOperation(const AData: String);
begin
  FgdcNamespaceSyncController.SetOperation(AData);
end;

procedure Tat_frmSyncNamespace.actSetForSavingUpdate(Sender: TObject);
begin
  actSetForSaving.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForSavingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '>>');
  if (FgdcNamespaceSyncController.FilterText > '') and (not actFLTOlder.Checked) then
    actFLTOlder.Execute;
end;

procedure Tat_frmSyncNamespace.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := not FgdcNamespaceSyncController.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actClearExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, '  ');
end;

procedure Tat_frmSyncNamespace.actSyncUpdate(Sender: TObject);
begin
  actSync.Enabled := not FgdcNamespaceSyncController.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSyncExecute(Sender: TObject);
begin
  FgdcNamespaceSyncController.Sync;
end;

procedure Tat_frmSyncNamespace.actDeleteFileUpdate(Sender: TObject);
begin
  actDeleteFile.Enabled := (not FgdcNamespaceSyncController.DataSet.IsEmpty)
    and (not FgdcNamespaceSyncController.DataSet.FieldByName('filetimestamp').IsNull);
end;

procedure Tat_frmSyncNamespace.DeleteFile(const AData: String);
begin
  FgdcNamespaceSyncController.DeleteFile(
    FgdcNamespaceSyncController.DataSet.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actDeleteFileExecute(Sender: TObject);
begin
  IterateSelected(DeleteFile);
end;

procedure Tat_frmSyncNamespace.Log(const S: String);
begin
  mMessages.Lines.Add(FormatDateTime('hh:nn:ss ', Now) + S);
end;

procedure Tat_frmSyncNamespace.ApplyFilter;
begin
  gr.SelectedRows.Clear;
  FgdcNamespaceSyncController.ApplyFilter;
  if FgdcNamespaceSyncController.Filtered then
  begin
    sb.SimpleText := 'К данным применен фильтр.';
    if FgdcNamespaceSyncController.FilterOnlyPackages then
      sb.SimpleText := sb.SimpleText + ' Отображаются только пакеты.';
  end else
    sb.SimpleText := '';
end;

procedure Tat_frmSyncNamespace.edFilterChange(Sender: TObject);
begin
  FgdcNamespaceSyncController.FilterText := edFilter.Text;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBExecute(Sender: TObject);
begin
  if (Sender as TAction).Checked  then
  begin
    (Sender as TAction).Checked := False;
    FgdcNamespaceSyncController.FilterOperation :=
      StringReplace(FgdcNamespaceSyncController.FilterOperation,
        (Sender as TAction).Caption, '', [rfReplaceAll]);
  end else
  begin
    (Sender as TAction).Checked := True;
    FgdcNamespaceSyncController.FilterOperation :=
      FgdcNamespaceSyncController.FilterOperation +
      (Sender as TAction).Caption;
  end;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not FgdcNamespaceSyncController.DataSet.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actFLTInternalExecute(Sender: TObject);
begin
  FgdcNamespaceSyncController.FilterOnlyPackages := cbPackets.Checked;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actSelectAllExecute(Sender: TObject);
var
  Bm, FirstBm: String;
  FirstSet, InGroup: Boolean;
begin
  FirstSet := False;
  InGroup := False;
  Bm := FgdcNamespaceSyncController.DataSet.Bookmark;
  FgdcNamespaceSyncController.DataSet.DisableControls;
  try
    gr.SelectedRows.Clear;
    FgdcNamespaceSyncController.DataSet.First;
    while not FgdcNamespaceSyncController.DataSet.Eof do
    begin
      if (not FgdcNamespaceSyncController.DataSet.FieldByName('namespacename').IsNull)
        or (not FgdcNamespaceSyncController.DataSet.FieldByName('fileruid').IsNull) then
      begin
        if not FirstSet then
        begin
          FirstSet := True;
          FirstBm := FgdcNamespaceSyncController.DataSet.Bookmark;
        end;

        if FgdcNamespaceSyncController.DataSet.Bookmark = Bm then
          InGroup := True;

        gr.SelectedRows.CurrentRowSelected := True;
      end;
      FgdcNamespaceSyncController.DataSet.Next;
    end;

    if (not InGroup) and FirstSet then
      FgdcNamespaceSyncController.DataSet.Bookmark := FirstBm
    else
      FgdcNamespaceSyncController.DataSet.Bookmark := Bm;
  finally
    FgdcNamespaceSyncController.DataSet.EnableControls;
  end;
end;

procedure Tat_frmSyncNamespace.actSelectAllUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not FgdcNamespaceSyncController.DataSet.IsEmpty;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
