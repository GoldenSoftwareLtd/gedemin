// ShlTanya, 03.02.2019

unit gdc_attr_frmRelationField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData;

type
  Tgdc_attr_frmRelationField = class(Tgdc_frmSGR)
    gdcTableField: TgdcTableField;
    procedure FormCreate(Sender: TObject);
    procedure actChooseOkUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_attr_frmRelationField: Tgdc_attr_frmRelationField;

implementation

{$R *.DFM}

uses gd_ClassList;

procedure Tgdc_attr_frmRelationField.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcTableField;
end;

procedure Tgdc_attr_frmRelationField.actChooseOkUpdate(Sender: TObject);
begin
//  inherited;

end;

initialization
  RegisterFrmClass(Tgdc_attr_frmRelationField);

finalization
  UnRegisterFrmClass(Tgdc_attr_frmRelationField);

end.
