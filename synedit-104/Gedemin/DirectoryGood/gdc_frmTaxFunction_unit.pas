unit gdc_frmTaxFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcTaxFunction, IBCustomDataSet, gdcBase, gdcGood,
  gdc_frmMDH_unit;

type
  Tgdc_frmTaxFunction = class(Tgdc_frmMDHGR)
    TBItem1: TTBItem;
    actTaxFunction: TAction;
    gdcTaxFunction: TgdcTaxFunction;
    procedure FormCreate(Sender: TObject);
    procedure actTaxFunctionExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmTaxFunction: Tgdc_frmTaxFunction;

implementation

uses
  gd_ClassList;

{$R *.DFM}

procedure Tgdc_frmTaxFunction.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTaxFunction;
  inherited;
  gdcObject.Open;
end;

procedure Tgdc_frmTaxFunction.actTaxFunctionExecute(Sender: TObject);
begin
//  gdcTaxFunction.Open;
//  gdcTaxFunction.EditDialog;
//  gdcTaxFunction.Close;
end;

initialization
  RegisterFrmClass(Tgdc_frmTaxFunction);

finalization
  UnRegisterFrmClass(Tgdc_frmTaxFunction);

end.
