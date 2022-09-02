// ShlTanya, 30.01.2019

unit gdc_frmAdviceOfCollection_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, flt_sqlFilter,
  Menus, ActnList, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcClasses, gdcPayment, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body, gsTransaction,
  gdc_frmSGRAccount_unit, TB2Dock, TB2Item, TB2Toolbar, gdcTree,
  gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmAdviceOfCollection = class(Tgdc_frmSGRAccount)
    gdcAdviceOfCollection: TgdcAdviceOfCollection;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmAdviceOfCollection: Tgdc_frmAdviceOfCollection;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

{ Tgdc_frmAdviceOfCollection }

class function Tgdc_frmAdviceOfCollection.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmAdviceOfCollection) then
    gdc_frmAdviceOfCollection := Tgdc_frmAdviceOfCollection.Create(AnOwner);

  Result := gdc_frmAdviceOfCollection;
end;

procedure Tgdc_frmAdviceOfCollection.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAdviceOfCollection;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmAdviceOfCollection);
  //RegisterClass(Tgdc_frmAdviceOfCollection);

finalization
  UnRegisterFrmClass(Tgdc_frmAdviceOfCollection);

end.
