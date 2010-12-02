{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmTaxActual_unit.pas

  Abstract

    Dialog form of TgdcTaxActual business class.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit gdc_frmTaxActual_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gdcTaxFunction, Db, IBCustomDataSet, gdcBase,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls,
  gsIBLookupComboBox, gdcTree, gdcClasses;

type
  Tgdc_frmTaxActual = class(Tgdc_frmMDHGR)
    gdcTaxActual: TgdcTaxActual;
    actActualPrint: TAction;
    gdcTaxName: TgdcTaxName;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmTaxActual: Tgdc_frmTaxActual;

implementation

uses
  gd_ClassList, tax_frmAnalytics_unit;

{$R *.DFM}

procedure Tgdc_frmTaxActual.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTaxName;
  gdcDetailObject := gdcTaxActual;
//  gdcDetailObject := gdcTaxFunction;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmTaxActual);

finalization
  UnRegisterFrmClass(Tgdc_frmTaxActual);

end.
