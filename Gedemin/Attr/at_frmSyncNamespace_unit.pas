unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, DBClient,
  StdCtrls, ExtCtrls, Menus, dmDatabase_unit, IBCustomDataSet, gdcBase,
  gdcNamespace, IBDatabase, gsNSObjects;

type
  TIterateProc = procedure (AnObj: TObject; const Data: String) of object;

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
    actSaveToFile: TAction;
    TBItem3: TTBItem;
    pmSync: TPopupMenu;
    actEditNamespace: TAction;
    actEditNamespace1: TMenuItem;
    actEditFile: TAction;
    N1: TMenuItem;
    actCompareWithData: TAction;
    N2: TMenuItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    actSaveToFile1: TMenuItem;
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
    actLoadFromFile: TAction;
    N8: TMenuItem;
    TBItem7: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    actSync: TAction;
    TBItem11: TTBItem;
    actDeleteFile: TAction;
    N9: TMenuItem;
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
    cbInternal: TCheckBox;
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
    procedure actChooseDirExecute(Sender: TObject);
    procedure actCompareUpdate(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
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
    procedure actLoadFromFileUpdate(Sender: TObject);
    procedure actSyncUpdate(Sender: TObject);
    procedure actSyncExecute(Sender: TObject);
    procedure actDeleteFileUpdate(Sender: TObject);
    procedure actDeleteFileExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure cdsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure actFLTOnlyInDBExecute(Sender: TObject);
    procedure actFLTOnlyInDBUpdate(Sender: TObject);
    procedure actFLTInternalExecute(Sender: TObject);

  private
    FgdcNamespace: TgdcNamespace;
    FNSList: TgsNSList;
    FLoadFileList, FSaveFileList: TStringList;

    procedure ApplyFilter;
    procedure IterateSelected(Proc: TIterateProc; AnObj: TObject; const AData: String);
    procedure SetOperation(AnObj: TObject; const AData: String);
    procedure SaveID(AnObj: TObject; const AData: String);
    procedure DeleteFile(AnObj: TObject; const AData: String); 
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
  FileCtrl, gd_GlobalParams_unit, gd_ExternalEditor, jclStrings, at_dlgCheckOperation_unit;

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
  if chbxUpdate.Checked then
  begin
    Log('Начато обновление даты изменения объекта...');
    TgdcNamespace.UpdateCurrModified;
    Log('Окончено обновление даты изменения объекта...');
  end;  

  cds.DisableControls;
  try
    cds.EmptyDataSet;
    FNSList.Clear;
    FNSList.GetFilesForPath(tbedPath.Text);
    TgdcNamespace.ScanDirectory(cds, FNSList, Log);
    gr.SelectedRows.Clear;
    Log('Выполнено сравнение с каталогом ' + tbedPath.Text);
    ApplyFilter;
  finally
    cds.EnableControls;
  end;
end;

procedure Tat_frmSyncNamespace.LoadSettingsAfterCreate;
begin
  inherited;
  tbedPath.Text := gd_GlobalParams.NamespacePath;
end;

procedure Tat_frmSyncNamespace.SaveSettings;
begin
  gd_GlobalParams.NamespacePath := tbedPath.Text;
  inherited;
end;

procedure Tat_frmSyncNamespace.actSaveToFileUpdate(Sender: TObject);
begin
  actSaveToFile.Enabled := DirectoryExists(tbedPath.Text)
    and (not cds.IsEmpty)
    and (cds.FieldByName('namespacename').AsString > '');
end;

procedure Tat_frmSyncNamespace.actSaveToFileExecute(Sender: TObject);
begin
  IterateSelected(SaveID, nil, '');
end;

procedure Tat_frmSyncNamespace.actEditNamespaceUpdate(Sender: TObject);
begin
  actEditNamespace.Enabled := (not cds.IsEmpty)
    and (cds.FieldByName('namespacekey').AsInteger > 0);
end;

procedure Tat_frmSyncNamespace.actEditNamespaceExecute(Sender: TObject);
begin
  if FgdcNamespace.Active and (not FgdcNamespace.EOF) then
    FgdcNamespace.EditDialog;
end;

procedure Tat_frmSyncNamespace.actEditFileUpdate(Sender: TObject);
begin
  actEditFile.Enabled := (not cds.IsEmpty)
    and FileExists(cds.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.actEditFileExecute(Sender: TObject);
begin
  InvokeExternalEditor('yaml', cds.FieldByName('filename').AsString);
end;

procedure Tat_frmSyncNamespace.FormCreate(Sender: TObject);
begin
  FgdcNamespace.SubSet := 'ByID';
  FgdcNamespace.MasterSource := ds;
  FgdcNamespace.MasterField := 'namespacekey';
  FgdcNamespace.DetailField := 'id';
  FgdcNamespace.Open;
end;

procedure Tat_frmSyncNamespace.actCompareWithDataUpdate(Sender: TObject);
begin
  actCompareWithData.Enabled := (not cds.IsEmpty)
    and FileExists(cds.FieldByName('filename').AsString)
    and FgdcNamespace.Active;
end;

procedure Tat_frmSyncNamespace.actCompareWithDataExecute(Sender: TObject);
begin
  FgdcNamespace.CompareWithData(cds.FieldByName('filename').AsString);
end;

constructor Tat_frmSyncNamespace.Create(AnOwner: TComponent);
begin
  inherited;
  FgdcNamespace := TgdcNamespace.Create(nil);
  ShowSpeedButton := True;
  FNSList := TgsNSList.Create;
  FNSList.Sorted := False;
  FNSList.Log := Log;
  FLoadFileList := TStringList.Create;
  FLoadFileList.Sorted := False;
  FSaveFileList := TStringList.Create;
  FSaveFileList.Sorted := True;
  FSaveFileList.Duplicates := dupIgnore;
  cds.LogChanges := False;
end;

destructor Tat_frmSyncNamespace.Destroy;
begin
  FgdcNamespace.Free;
  FNSList.Free;
  FLoadFileList.Free;
  FSaveFileList.Free;
  inherited;
end;

procedure Tat_frmSyncNamespace.IterateSelected(Proc: TIterateProc;
  AnObj: TObject; const AData: String);
var
  I: Integer;
begin  
  if gr.SelectedRows.Count > 0 then
  begin
    for I := 0 to gr.SelectedRows.Count - 1 do
    begin
      cds.Bookmark := gr.SelectedRows[I];
      Proc(AnObj, AData);
      UpdateWindow(mMessages.Handle);
    end;
  end
  else if not cds.IsEmpty then
    Proc(AnObj, AData);
end;

procedure Tat_frmSyncNamespace.actSetForLoadingUpdate(Sender: TObject);
begin
  actSetForLoading.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, cds, '<<');
end;

procedure Tat_frmSyncNamespace.SetOperation(AnObj: TObject; const AData: String);

  procedure SetLoadState(Node: TgsNSTreeNode);
  var
    I: Integer;
  begin
    if Node <> nil then
    begin
      if cds.Locate('fileruid', Node.YamlNode.RUID, []) then
      begin
        (AnObj as TClientDataSet).Edit;
        (AnObj as TClientDataSet).FieldByName('operation').AsString := AData;
        (AnObj as TClientDataSet).Post;
      end;
      for I := 0 to Node.UsesObject.Count - 1 do
        SetLoadState(Node.UsesObject.Objects[I] as TgsNSTreeNode);
    end;
  end;
begin
  Assert(AnObj is TClientDataSet);
  if
    (
      (AData = '<<')
      and
      ((AnObj as TClientDataSet).FieldByName('fileversion').AsString > '')
    )
    or
    (
      (AData = '>>')
      and
      ((AnObj as TClientDataSet).FieldByName('namespacename').AsString > '')
    )
    or
    (
      AData = '  '
    ) then
  begin
    if AData = '<<' then
    begin
      (AnObj as TClientDataSet).DisableControls;
      try
        SetLoadState(FNSList.NSTree.GetTreeNodeByRUID((AnObj as TClientDataSet).FieldByName('fileruid').AsString))
      finally
        (AnObj as TClientDataSet).EnableControls;
      end;
    end else
    begin
      (AnObj as TClientDataSet).Edit;
      (AnObj as TClientDataSet).FieldByName('operation').AsString := AData;
      (AnObj as TClientDataSet).Post;
    end;
  end;
end;

procedure Tat_frmSyncNamespace.actSetForSavingUpdate(Sender: TObject);
begin
  actSetForSaving.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSetForSavingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, cds, '>>');
end;

procedure Tat_frmSyncNamespace.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actClearExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, cds, '  ');
end;

procedure Tat_frmSyncNamespace.SaveID(AnObj: TObject; const AData: String);
begin
  if cds.FieldByName('namespacekey').AsInteger > 0 then
  begin
    if not FgdcNamespace.EOF then
    begin
      if cds.FieldByName('filename').AsString > '' then
        FgdcNamespace.SaveNamespaceToFile(cds.FieldByName('filename').AsString)
      else
        FgdcNamespace.SaveNamespaceToFile(tbedPath.Text);
      Log('Пространство имен "' + FgdcNamespace.ObjectName + '" записано в файл.');
    end;
  end;
end; 

procedure Tat_frmSyncNamespace.actLoadFromFileUpdate(Sender: TObject);
begin
  actLoadFromFile.Enabled := (not cds.IsEmpty)
    and (cds.FieldByName('fileversion').AsString > '');
end;

procedure Tat_frmSyncNamespace.actSyncUpdate(Sender: TObject);
begin
  actSync.Enabled := not cds.IsEmpty;
end;

procedure Tat_frmSyncNamespace.actSyncExecute(Sender: TObject);
var
  Error: String;
  AlwaysOverwrite, DontRemove, IncVersion: Boolean;
  Sync: Boolean;
  I: Integer;
begin
  FLoadFileList.Clear;
  FSaveFileList.Clear;
  Sync := False;
  AlwaysOverwrite := False;
  DontRemove := False;
  IncVersion := False;
  cds.DisableControls;
  try
    cds.First;
    while not cds.Eof do
    begin
      if Pos('>', cds.FieldByName('operation').AsString) = 1 then
      begin
        if cds.FieldByName('namespacekey').AsInteger > 0 then
          FSaveFileList.Add(cds.FieldByName('namespacekey').AsString);
      end else if Pos('<', cds.FieldByName('operation').AsString) = 1 then
      begin
        if FNSList.NSTree.CheckNSCorrect(cds.FieldByName('fileruid').AsString, Error) then
        begin
          FNSList.NSTree.SetNSFileName(cds.FieldByName('fileruid').AsString, FLoadFileList);
        end else
          Application.MessageBox(
            PChar(Error + #13#10 +
            'Пространство имен ''' + cds.FieldByName('FileNamespaceName').AsString + ''' не будет загружен.'),
            'Внимание',
            MB_ICONERROR or MB_OK or MB_TASKMODAL);
      end;
      cds.Next;
    end;
  finally
    cds.First;
    cds.EnableControls;
  end;

  with TdlgCheckOperation.Create(nil) do
  begin
    lLoadRecords.Caption := 'Помечено для загрузки из файла ' + IntToStr(FLoadFileList.Count) + ' ПИ.';
    lSaveRecords.Caption := 'Помечено для сохранения в файл ' + IntToStr(FSaveFileList.Count) + ' ПИ.';
    if ShowModal = mrOk then
    begin
      Sync := True;
      AlwaysOverwrite := cbAlwaysOverwrite.Checked;
      DontRemove := cbDontRemove.Checked;
      IncVersion := cbIncVersion.Checked;
    end;
  end;

  if Sync then
  begin
    FgdcNamespace.IncBuildVersion := IncVersion;
    for I := 0 to FSaveFileList.Count - 1 do
    begin
      if cds.Locate('namespacekey', FSaveFileList[I], []) then
        SaveID(nil, '');
    end;  
    FgdcNamespace.InstallPackages(FLoadFileList, AlwaysOverwrite, DontRemove);
    actCompare.Execute;
  end;
end;

procedure Tat_frmSyncNamespace.actDeleteFileUpdate(Sender: TObject);
begin
  actDeleteFile.Enabled := (not cds.IsEmpty)
    and (cds.FieldByName('fileversion').AsString > '');
end;

procedure Tat_frmSyncNamespace.DeleteFile(AnObj: TObject;
  const AData: String);
begin
  if SysUtils.DeleteFile(cds.FieldByName('filename').AsString) then
  begin
    Log('Файл ' + cds.FieldByName('filename').AsString + ' был удален.');
    cds.Edit;
    cds.FieldByName('filename').Clear;
    cds.FieldByName('filenamespacename').Clear;
    cds.FieldByName('fileversion').Clear;
    cds.FieldByName('filetimestamp').Clear;
    cds.FieldByName('filesize').Clear;
    cds.FieldByName('operation').Clear;
    cds.Post;
  end;
end;

procedure Tat_frmSyncNamespace.actDeleteFileExecute(Sender: TObject);
begin
  IterateSelected(DeleteFile, nil, '');
end;

procedure Tat_frmSyncNamespace.Log(const S: String);
begin
  mMessages.Lines.Add(FormatDateTime('hh:nn:ss ', Now) + S);
end;

procedure Tat_frmSyncNamespace.actLoadFromFileExecute(Sender: TObject);
var
  Error: String;
begin
  FLoadFileList.Clear;
  if FNSList.NSTree.CheckNSCorrect(cds.FieldByName('fileruid').AsString, Error) then
  begin
    FNSList.NSTree.SetNSFileName(cds.FieldByName('fileruid').AsString, FLoadFileList);
  end else
    Application.MessageBox(
      PChar(Error + #13#10 +
      'Пространство имен ''' + cds.FieldByName('FileNamespaceName').AsString + ''' не будет загружен.'),
      'Внимание',
      MB_ICONERROR or MB_OK or MB_TASKMODAL);
end;

procedure Tat_frmSyncNamespace.ApplyFilter;
begin
  cds.Filtered := False;
  cds.Filtered := (edFilter.Text > '')
    or actFLTOnlyInDB.Checked
    or actFLTOlder.Checked
    or actFLTEqual.Checked
    or actFLTOnlyInFile.Checked
    or actFLTNewer.Checked
    or actFLTNone.Checked
    or actFLTEqualOlder.Checked
    or actFLTEqualNewer.Checked
    or actFLTInUses.Checked
    or cbInternal.Checked;
end;

procedure Tat_frmSyncNamespace.edFilterChange(Sender: TObject);
begin
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.cdsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin  
  Accept :=
    (cds.FieldByName('operation').AsString = '')
    or
    (
      cbInternal.Checked
      and
      (
        (
          (cds.FieldByName('filename').AsString > '')
          and
          (cds.FieldByName('fileinternal').AsInteger = 0)
        )
        or
        (
          (cds.FieldByName('namespacekey').AsInteger > 0)
          and
          (cds.FieldByName('namespaceinternal').AsInteger = 0)
        )
      )
    )
    or
    (
      not cbInternal.Checked
      and
      (
        (edFilter.Text = '')
        or
        (
          StrIPos(edFilter.Text, cds.FieldByName('namespacename').AsString +
          cds.FieldByName('NamespaceVersion').AsString +
          cds.FieldByName('NamespaceTimeStamp').AsString +
          cds.FieldByName('FileNamespaceName').AsString +
          cds.FieldByName('FileVersion').AsString +
          cds.FieldByName('FileTimeStamp').AsString +
          cds.FieldByName('FileSize').AsString) > 0
        )
      )
      and
      (
        (
          (not actFLTOnlyInDB.Checked)
          and
          (not actFLTOlder.Checked)
          and
          (not actFLTEqual.Checked)
          and
          (not actFLTOnlyInFile.Checked)
          and
          (not actFLTNewer.Checked)
          and
          (not actFLTNone.Checked)
          and
          (not actFLTEqualOlder.Checked)
          and
          (not actFLTEqualNewer.Checked)
          and
          (not actFLTInUses.Checked)
        )
        or
        (actFLTOnlyInDB.Checked and (cds.FieldByName('operation').AsString = actFLTOnlyInDB.Caption))
        or
        (actFLTOlder.Checked and (cds.FieldByName('operation').AsString = actFLTOlder.Caption))
        or
        (actFLTEqual.Checked and (cds.FieldByName('operation').AsString = actFLTEqual.Caption))
        or
        (actFLTOnlyInFile.Checked and (cds.FieldByName('operation').AsString = actFLTOnlyInFile.Caption))
        or
        (actFLTNewer.Checked and (cds.FieldByName('operation').AsString = actFLTNewer.Caption))
        or
        (actFLTNone.Checked and (cds.FieldByName('operation').AsString = actFLTNone.Caption))
        or
        (actFLTEqualOlder.Checked and (cds.FieldByName('operation').AsString = actFLTEqualOlder.Caption))
        or
        (actFLTEqualNewer.Checked and (cds.FieldByName('operation').AsString = actFLTEqualNewer.Caption))
        or
        (actFLTInUses.Checked and (cds.FieldByName('operation').AsString = actFLTInUses.Caption))
      )
    );
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBExecute(Sender: TObject);
begin
  (Sender as TAction).Checked := not (Sender as TAction).Checked;
  ApplyFilter;
end;

procedure Tat_frmSyncNamespace.actFLTOnlyInDBUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := cds.Filtered or (not cds.IsEmpty);
end;

procedure Tat_frmSyncNamespace.actFLTInternalExecute(Sender: TObject);
begin
  ApplyFilter;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
