// ShlTanya, 03.02.2019

unit gdc_attr_frmDBTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData;

type
  Tgdc_frmDBTrigger = class(Tgdc_frmSGR)
    gdcDBTrigger: TgdcDBTrigger;
    actSync: TAction;
    TBItem1: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actSyncExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmDBTrigger: Tgdc_frmDBTrigger;

implementation

{$R *.DFM}
uses
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_frmDBTrigger }

procedure Tgdc_frmDBTrigger.actSyncExecute(Sender: TObject);
begin
  (gdcObject as TgdcDBTrigger).SyncAllTriggers;
end;

procedure Tgdc_frmDBTrigger.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDBTrigger;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmDBTrigger);

finalization
  UnRegisterFrmClass(Tgdc_frmDBTrigger);
end.
