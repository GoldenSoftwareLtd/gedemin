// ShlTanya, 03.02.2019

unit gdc_frmException_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcBaseInterface, gdcMetaData;

type
  Tgdc_frmException = class(Tgdc_frmSGR)
    gdcException: TgdcException;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmException: Tgdc_frmException;

implementation
uses
  at_classes,  gd_ClassList, gd_security;

{$R *.DFM}

{ Tgdc_frmException }

class function Tgdc_frmException.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmException) then
    gdc_frmException := Tgdc_frmException.Create(AnOwner);

  Result := gdc_frmException;
end;

procedure Tgdc_frmException.FormCreate(Sender: TObject);
begin
  gdcObject :=  gdcException;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmException);

finalization
  UnRegisterFrmClass(Tgdc_frmException);

end.
