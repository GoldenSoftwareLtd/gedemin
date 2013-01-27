unit at_frmSyncNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, gd_createable_form, TB2ExtItems, TB2Item, ActnList, Db,
  Grids, DBGrids, gsDBGrid, TB2Dock, TB2Toolbar, ComCtrls, DBClient,
  StdCtrls, ExtCtrls, Menus, dmDatabase_unit, IBCustomDataSet, gdcBase,
  gdcNamespace;

type
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
    tbedPath: TTBEditItem;
    actCompare: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    cdsFileName2: TStringField;
    tbedName: TTBEditItem;
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    mMessages: TMemo;
    splMessages: TSplitter;
    TBSeparatorItem3: TTBSeparatorItem;
    actSetFilter: TAction;
    tbiFilter: TTBItem;
    actSaveToFile: TAction;
    TBItem3: TTBItem;
    pmSync: TPopupMenu;
    actEditNamespace: TAction;
    actEditNamespace1: TMenuItem;
    actEditFile: TAction;
    N1: TMenuItem;
    actCompareWithData: TAction;
    N2: TMenuItem;
    procedure actChooseDirExecute(Sender: TObject);
    procedure actCompareUpdate(Sender: TObject);
    procedure actCompareExecute(Sender: TObject);
    procedure cdsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure actSetFilterExecute(Sender: TObject);
    procedure actSetFilterUpdate(Sender: TObject);
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

  private
    FSaving: Boolean;
    FgdcNamespace: TgdcNamespace;

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
    cds.Filtered := False;
    mMessages.Lines.Clear;
    TgdcNamespace.ScanDirectory(cds, tbedPath.Text, mMessages.Lines);
  finally
    cds.EnableControls;
  end;
end;

procedure Tat_frmSyncNamespace.cdsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept := True;
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

procedure Tat_frmSyncNamespace.actSetFilterExecute(Sender: TObject);
begin
  cds.Filtered := not cds.Filtered;
end;

procedure Tat_frmSyncNamespace.actSetFilterUpdate(Sender: TObject);
begin
  actSetFilter.Checked := cds.Filtered;
end;

procedure Tat_frmSyncNamespace.actSaveToFileUpdate(Sender: TObject);
begin
  actSaveToFile.Enabled := DirectoryExists(tbedPath.Text)
    and (cds.RecordCount > 0);
end;

procedure Tat_frmSyncNamespace.actSaveToFileExecute(Sender: TObject);
var
  I: Integer;
  Obj: TgdcNamespace;

  procedure SaveID;
  begin
    if cds.FieldByName('namespacekey').AsInteger > 0 then
    begin
      Obj.ID := cds.FieldByName('namespacekey').AsInteger;
      Obj.Open;
      if not Obj.EOF then
      begin
        if cds.FieldByName('filename').AsString > '' then
          Obj.SaveNamespaceToFile(cds.FieldByName('filename').AsString)
        else
          Obj.SaveNamespaceToFile(tbedPath.Text);
        mMessages.Lines.Add('Пространство имен "' + Obj.ObjectName + '" записано в файл.');
      end;
      Obj.Close;
    end;
  end;

begin
  mMessages.Lines.Clear;
  FSaving := True;
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByID';

    if gr.SelectedRows.Count > 0 then
    begin
      cds.DisableControls;
      try
        for I := 0 to gr.SelectedRows.Count - 1 do
        begin
          Application.ProcessMessages;
          if Application.Terminated then
            break;
          cds.Bookmark := gr.SelectedRows[I];
          SaveID;
        end;
      finally
        cds.EnableControls;
      end;
    end else
      SaveID;
  finally
    Obj.Free;
    FSaving := False;
  end;
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
end;

destructor Tat_frmSyncNamespace.Destroy;
begin
  FgdcNamespace.Free;
  inherited;
end;

initialization
  RegisterClass(Tat_frmSyncNamespace);

finalization
  UnRegisterClass(Tat_frmSyncNamespace);
end.
