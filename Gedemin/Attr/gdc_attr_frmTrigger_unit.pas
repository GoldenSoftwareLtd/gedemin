// ShlTanya, 03.02.2019

unit gdc_attr_frmTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData, gdc_frmMDHGR_unit;

type
  Tgdc_frmTrigger = class(Tgdc_frmMDHGR)
    gdcTrigger: TgdcTrigger;
    actSync: TAction;
    tbiSync: TTBItem;
    gdcTable: TgdcTable;
    procedure FormCreate(Sender: TObject);
    procedure actSyncExecute(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmTrigger: Tgdc_frmTrigger;

implementation

{$R *.DFM}

uses
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function Tgdc_frmTrigger.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTrigger) then
    gdc_frmTrigger := Tgdc_frmTrigger.Create(AnOwner);
  Result := gdc_frmTrigger;
end;

procedure Tgdc_frmTrigger.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTable;
  gdcDetailObject := gdcTrigger;
  inherited;
  actSync.Execute;
end;

procedure Tgdc_frmTrigger.actSyncExecute(Sender: TObject);
begin
  (gdcDetailObject as TgdcTrigger).SyncAllTriggers;
end;

initialization
  RegisterFrmClass(Tgdc_frmTrigger);

finalization
  UnRegisterFrmClass(Tgdc_frmTrigger);
end.
