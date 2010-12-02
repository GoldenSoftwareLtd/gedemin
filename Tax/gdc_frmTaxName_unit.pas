{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmTaxName_unit.pas

  Abstract

    Dialog form of TgdcTaxName business class.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit gdc_frmTaxName_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcTaxFunction;

type
  Tgdc_frmTaxName = class(Tgdc_frmSGR)
    gdcTaxName: TgdcTaxName;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmTaxName: Tgdc_frmTaxName;

implementation

{$R *.DFM}

uses
  gd_ClassList;

{ Tgdc_frmTaxName }

class function Tgdc_frmTaxName.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTaxName) then
    gdc_frmTaxName := Tgdc_frmTaxName.Create(AnOwner);
  Result := gdc_frmTaxName;
end;

procedure Tgdc_frmTaxName.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTaxName;

  inherited;

  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmTaxName);

finalization
  UnRegisterFrmClass(Tgdc_frmTaxName);

end.
