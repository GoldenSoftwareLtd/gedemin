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
    procedure FormCreate(Sender: TObject);
    procedure actSetObjectPosExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCompareWithDataExecute(Sender: TObject);
    procedure actCompareWithDataUpdate(Sender: TObject);
    procedure actSetObjectPosUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses
  gd_ClassList;

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
begin
  (gdcObject as TgdcNamespace).CompareWithData;
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

initialization
  RegisterFRMClass(Tgdc_frmNamespace);

finalization
  UnRegisterFRMClass(Tgdc_frmNamespace);
end.
