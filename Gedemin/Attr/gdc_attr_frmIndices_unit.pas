// ShlTanya, 03.02.2019

unit gdc_attr_frmIndices_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData, gdc_frmMDHGR_unit;

type
  Tgdc_frmIndices = class(Tgdc_frmMDHGR)
    gdcIndex: TgdcIndex;
    actSync: TAction;
    tbiSync: TTBItem;
    gdcTable: TgdcTable;
    procedure FormCreate(Sender: TObject);
    procedure actSyncExecute(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmIndices: Tgdc_frmIndices;

implementation

{$R *.DFM}

uses
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function Tgdc_frmIndices.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmIndices) then
    gdc_frmIndices := Tgdc_frmIndices.Create(AnOwner);
  Result := gdc_frmIndices;
end;

procedure Tgdc_frmIndices.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTable;
  gdcDetailObject := gdcIndex;
  inherited;
  actSync.Execute;
end;


procedure Tgdc_frmIndices.actSyncExecute(Sender: TObject);
begin
  (gdcDetailObject as TgdcIndex).SyncAllIndices;
end;

initialization
  RegisterFrmClass(Tgdc_frmIndices);

finalization
  UnRegisterFrmClass(Tgdc_frmIndices);

end.
