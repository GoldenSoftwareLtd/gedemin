// ShlTanya, 24.02.2019

unit gdc_frmFile_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, gdcFile, IBCustomDataSet, gdcBase, gdcTree;

type
  Tgdc_frmFile = class(Tgdc_frmMDVTree)
    gdcFileFolder: TgdcFileFolder;
    gdcFile: TgdcFile;
    actViewFile: TAction;
    tbiViewFile: TTBItem;
    pnlRootDirectory: TPanel;
    lblRootDirectory: TLabel;
    actRootDirectory: TAction;
    tbsmService: TTBSubmenuItem;
    tbiRootDirectory: TTBItem;
    actFolderSyncronize: TAction;
    actFileSyncronize: TAction;
    actSyncronize: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure actViewFileExecute(Sender: TObject);
    procedure actViewFileUpdate(Sender: TObject);
    procedure actRootDirectoryExecute(Sender: TObject);
    procedure actSyncronizeExecute(Sender: TObject);
    procedure actSyncronizeUpdate(Sender: TObject);
    procedure actFolderSyncronizeExecute(Sender: TObject);
    procedure actFolderSyncronizeUpdate(Sender: TObject);
    procedure actFileSyncronizeExecute(Sender: TObject);
    procedure actFileSyncronizeUpdate(Sender: TObject);
    procedure ibgrDetailDblClick(Sender: TObject);
  end;

var
  gdc_frmFile: Tgdc_frmFile;

implementation

uses
  gd_classlist, FileCtrl, gdc_dlgPath_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgdc_frmFile.FormCreate(Sender: TObject);
begin
  gdcObject := gdcFileFolder;
  gdcDetailObject := gdcFile;
  inherited;
  lblRootDirectory.Caption := (gdcObject as TgdcBaseFile).RootDirectory;
end;

procedure Tgdc_frmFile.actViewFileExecute(Sender: TObject);
begin
  (gdcDetailObject as TgdcFile).ViewFile(True, True);
end;

procedure Tgdc_frmFile.actViewFileUpdate(Sender: TObject);
begin
  actViewFile.Enabled := Assigned(gdcDetailObject) and (gdcDetailObject.RecordCount > 0)
    and (gdcDetailObject.State = dsBrowse) and (gdcDetailObject.CanView);
end;

procedure Tgdc_frmFile.actRootDirectoryExecute(Sender: TObject);
var
  S: String;
begin
  if not DirectoryExists(S) then
    S := GetCurrentDir;
  if SelectDirectory(S, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
  begin
    lblRootDirectory.Caption := S;
    (gdcObject as TgdcBaseFile).RootDirectory := S;
  end;
end;

procedure Tgdc_frmFile.actSyncronizeExecute(Sender: TObject);
begin
  if (gdcObject as TgdcBaseFile).Synchronize(-1, True) then
    MessageBox(Handle, 'Процесс синхронизации закончен!', 'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure Tgdc_frmFile.actSyncronizeUpdate(Sender: TObject);
begin
  actSyncronize.Enabled := Assigned(gdcObject) and Assigned(gdcDetailObject) and
    gdcObject.CanView and
    gdcDetailObject.CanView and (gdcObject.State = dsBrowse) and
    (gdcDetailObject.State = dsBrowse) and (gdcObject.RecordCount > 0);
end;

procedure Tgdc_frmFile.actFolderSyncronizeExecute(Sender: TObject);
begin
  if (gdcObject as TgdcBaseFile).Synchronize(gdcObject.ID, True) then
    MessageBox(Handle, 'Процесс синхронизации закончен!', 'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure Tgdc_frmFile.actFolderSyncronizeUpdate(Sender: TObject);
begin
  actFolderSyncronize.Enabled := Assigned(gdcObject) and gdcObject.CanView and
    (gdcObject.State = dsBrowse) and (gdcObject.RecordCount > 0);
end;

procedure Tgdc_frmFile.actFileSyncronizeExecute(Sender: TObject);
begin
  if (gdcDetailObject as TgdcBaseFile).Synchronize(gdcDetailObject.ID, True) then
    MessageBox(Handle, 'Процесс синхронизации закончен!', 'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure Tgdc_frmFile.actFileSyncronizeUpdate(Sender: TObject);
begin
  actFileSyncronize.Enabled := Assigned(gdcDetailObject) and gdcDetailObject.CanView and
    (gdcDetailObject.State = dsBrowse) and (gdcDetailObject.RecordCount > 0);
end;

procedure Tgdc_frmFile.ibgrDetailDblClick(Sender: TObject);
begin
  if actViewFile.Enabled then
    actViewFile.Execute
  else
    inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmFile);

finalization
  UnRegisterFrmClass(Tgdc_frmFile);
end.
