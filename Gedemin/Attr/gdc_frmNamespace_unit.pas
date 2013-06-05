unit gdc_frmNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcNamespace;

type
  Tgdc_frmNamespace = class(Tgdc_frmMDHGR)
    gdcNamespace: TgdcNamespace;
    gdcNamespaceObject: TgdcNamespaceObject;
    actSetObjectPos: TAction;
    TBItem1: TTBItem;
    actCompareWithData: TAction;
    TBItem2: TTBItem;
    actShowDuplicates: TAction;
    TBItem3: TTBItem;
    actShowRecursion: TAction;
    TBItem4: TTBItem;
    actLoadPack: TAction;
    TBItem5: TTBItem;
    actNSObjects: TAction;
    TBItem6: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actSetObjectPosExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCompareWithDataExecute(Sender: TObject);
    procedure actCompareWithDataUpdate(Sender: TObject);
    procedure actSetObjectPosUpdate(Sender: TObject);
    procedure actShowDuplicatesExecute(Sender: TObject);
    procedure actShowRecursionExecute(Sender: TObject);
    procedure actShowRecursionUpdate(Sender: TObject);
    procedure actShowDuplicatesUpdate(Sender: TObject);
    procedure actLoadPackExecute(Sender: TObject);
    procedure actNSObjectsExecute(Sender: TObject);
    procedure actNSObjectsUpdate(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses
  gd_ClassList, at_frmDuplicates_unit, at_frmNSRecursion_unit,
  at_frmNSObjects_unit, at_frmSyncNamespace_unit;

procedure Tgdc_frmNamespace.FormCreate(Sender: TObject);
begin
  gdcObject := gdcNamespace;
  gdcDetailObject := gdcNamespaceObject;
  inherited;
end;

procedure Tgdc_frmNamespace.actSetObjectPosExecute(Sender: TObject);
begin
  if (gdcObject as TgdcNamespace).MakePos then
    gdcDetailObject.CloseOpen; 
end;

procedure Tgdc_frmNamespace.actSaveToFileExecute(Sender: TObject);
begin
  (gdcObject as TgdcNamespace).SaveNamespaceToFile;
end;

procedure Tgdc_frmNamespace.actCompareWithDataExecute(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.Filter := 'װאיכû YAML (*.yml)|*.YML';
    OD.DefaultExt := 'yml';
    OD.Options := [ofFileMustExist, ofEnableSizing];
    if OD.Execute then
      (gdcObject as TgdcNamespace).CompareWithData(OD.FileName);
  finally
    OD.Free;
  end;
end;

procedure Tgdc_frmNamespace.actCompareWithDataUpdate(Sender: TObject);
begin
  actCompareWithData.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and (not gdcObject.EOF);
end;

procedure Tgdc_frmNamespace.actSetObjectPosUpdate(Sender: TObject);
begin
  actSetObjectPos.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and (not gdcObject.EOF);
end;

procedure Tgdc_frmNamespace.actShowDuplicatesExecute(Sender: TObject);
begin
  with Tat_frmDuplicates.Create(nil) do
    Show;
end;

procedure Tgdc_frmNamespace.actShowRecursionExecute(Sender: TObject);
begin
  with Tat_frmNSRecursion.Create(nil) do
    Show;
end;

procedure Tgdc_frmNamespace.actShowRecursionUpdate(Sender: TObject);
begin
  actShowRecursion.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and (not gdcObject.EOF);
end;

procedure Tgdc_frmNamespace.actShowDuplicatesUpdate(Sender: TObject);
begin
  actShowDuplicates.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and (not gdcObject.EOF);
end;

procedure Tgdc_frmNamespace.actLoadPackExecute(Sender: TObject);
begin
  (gdcObject as TgdcNamespace).InstallPackages(nil);
end;

procedure Tgdc_frmNamespace.actNSObjectsExecute(Sender: TObject);
begin
  with Tat_frmNSObjects.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tgdc_frmNamespace.actNSObjectsUpdate(Sender: TObject);
begin
  actNSObjects.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse);
end;

procedure Tgdc_frmNamespace.actLoadFromFileExecute(Sender: TObject);
begin
  with Tat_frmSyncNamespace.Create(nil) do
    ShowModal;
 // (gdcObject as TgdcNamespace).LoadFromFile;
end;

initialization
  RegisterFRMClass(Tgdc_frmNamespace);

finalization
  UnRegisterFRMClass(Tgdc_frmNamespace);
end.
