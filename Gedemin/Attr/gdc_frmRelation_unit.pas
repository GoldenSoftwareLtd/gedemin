// ShlTanya, 03.02.2019

{++


  Copyright (c) 2001-2015 by Golden Software of Belarus, Ltd

  Module

    gdc_frmRelation_unit.pas

  Abstract

    Form for relations and relation fields.

  Author

    Denis Romanovski

  Revisions history

    1.0    06.12.2001    dennis    Initial version.


--}

unit gdc_frmRelation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  gdcMetaData, IBCustomDataSet, gdcBase, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmRelation = class(Tgdc_frmMDHGR)
    gdcView: TgdcView;
    gdcViewField: TgdcViewField;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmRelation: Tgdc_frmRelation;

implementation

{$R *.DFM}

uses
  gdcBaseInterface, at_classes,  gd_ClassList, gd_security,
  at_dlgToSetting_unit;

procedure Tgdc_frmRelation.FormCreate(Sender: TObject);
begin
  gdcObject := gdcView;
  gdcDetailObject := gdcViewField;

  inherited;
end;

class function Tgdc_frmRelation.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmRelation) then
    gdc_frmRelation := Tgdc_frmRelation.Create(AnOwner);

  Result := gdc_frmRelation;
end;

initialization
  RegisterFrmClass(Tgdc_frmRelation);

finalization
  UnRegisterFrmClass(Tgdc_frmRelation);
end.
