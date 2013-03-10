unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, DBClient,
  StdCtrls, ExtCtrls, Menus, dmDatabase_unit, IBCustomDataSet, gdcBase,
  gdcNamespace;

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
    cdsFileName2: TStringField;
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
    procedure actChooseDirExecute(Sender: TObject);
    procedure actCompareUpdate(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
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

  private
    FSaving: Boolean;
    FgdcNamespace: TgdcNamespace;

    procedure IterateSelected(Proc: TIterateProc; AnObj: TObject; const AData: String);
    procedure SetOperation(AnObj: TObject; const AData: String);
    procedure SaveID(AnObj: TObject; const AData: String);

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
  FileCtrl, gd_GlobalParams_unit, gd_ExternalEditor;

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
  cds.DisableControls;
  try
    cds.EmptyDataSet;
    mMessages.Lines.Clear;
    TgdcNamespace.ScanDirectory(cds, tbedPath.Text, mMessages.Lines);
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
    and (not cds.EOF)
    and (cds.FieldByName('namespacename').AsString > '');
end;

procedure Tat_frmSyncNamespace.actSaveToFileExecute(Sender: TObject);
begin
  mMessages.Lines.Clear;
  IterateSelected(SaveID, nil, '');
end;

procedure Tat_frmSyncNamespace.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FSaving;
end;

procedure Tat_frmSyncNamespace.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if FSaving and (Action is TCustomAction) then
  begin
    TCustomAction(Action).Enabled := False;
    Handled := True;
  end;
end;

procedure Tat_frmSyncNamespace.actEditNamespaceUpdate(Sender: TObject);
begin
  actEditNamespace.Enabled := (not cds.EOF)
    and (cds.FieldByName('namespacekey').AsInteger > 0);
end;

procedure Tat_frmSyncNamespace.actEditNamespaceExecute(Sender: TObject);
begin
  if FgdcNamespace.Active and (not FgdcNamespace.EOF) then
    FgdcNamespace.EditDialog;
end;

procedure Tat_frmSyncNamespace.actEditFileUpdate(Sender: TObject);
begin
  actEditFile.Enabled := (not cds.EOF)
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
  actCompareWithData.Enabled := (not cds.EOF)
    and FileExists(cds.FieldByName('filename').AsString)
    and FgdcNamespace.Active
    and (not FgdcNamespace.EOF);
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
end;

destructor Tat_frmSyncNamespace.Destroy;
begin
  FgdcNamespace.Free;
  inherited;
end;

procedure Tat_frmSyncNamespace.IterateSelected(Proc: TIterateProc;
  AnObj: TObject; const AData: String);
var
  I: Integer;
begin
  Assert(not FSaving);

  FSaving := True;
  try
    if gr.SelectedRows.Count > 0 then
    begin
      for I := 0 to gr.SelectedRows.Count - 1 do
      begin
        Application.ProcessMessages;
        if Application.Terminated then
          break;
        cds.Bookmark := gr.SelectedRows[I];
        Proc(AnObj, AData);
      end;
    end
    else if not cds.EOF then
      Proc(AnObj, AData);
  finally
    FSaving := False;
  end;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingUpdate(Sender: TObject);
begin
  actSetForLoading.Enabled := not cds.EOF;
end;

procedure Tat_frmSyncNamespace.actSetForLoadingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, cds, '<<');
end;

procedure Tat_frmSyncNamespace.SetOperation(AnObj: TObject; const AData: String);
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
    (AnObj as TClientDataSet).Edit;
    (AnObj as TClientDataSet).FieldByName('operation').AsString := AData;
    (AnObj as TClientDataSet).Post;
  end;
end;

procedure Tat_frmSyncNamespace.actSetForSavingUpdate(Sender: TObject);
begin
  actSetForSaving.Enabled := not cds.EOF;
end;

procedure Tat_frmSyncNamespace.actSetForSavingExecute(Sender: TObject);
begin
  IterateSelected(SetOperation, cds, '>>');
end;

procedure Tat_frmSyncNamespace.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := not cds.EOF;
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
      mMessages.Lines.Add('Пространство имен "' + FgdcNamespace.ObjectName + '" записано в файл.');
    end;
  end;
end;

procedure Tat_frmSyncNamespace.actLoadFromFileUpdate(Sender: TObject);
begin
  actLoadFromFile.Enabled := (not cds.EOF)
    and (cds.FieldByName('fileversion').AsString > '');
end;

procedure Tat_frmSyncNamespace.actSyncUpdate(Sender: TObject);
begin
  actSync.Enabled := not cds.EOF;
end;

procedure Tat_frmSyncNamespace.actSyncExecute(Sender: TObject);
begin
  cds.First;
  while not cds.EOF do
  begin
    cds.Next;
  end;
  actCompare.Execute;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
