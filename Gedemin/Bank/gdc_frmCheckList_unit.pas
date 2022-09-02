// ShlTanya, 30.01.2019

unit gdc_frmCheckList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, flt_sqlFilter, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  gdcCheckList, IBCustomDataSet, gdcBase, gdcClasses, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body,
  gdc_frmMDHGRAccount_unit, gdcConst, TB2Dock, TB2Item, TB2Toolbar,
  gdcTree, gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmCheckList = class(Tgdc_frmMDHGRAccount)
    gdcCheckList: TgdcCheckList;
    gdcCheckListLine: TgdcCheckListLine;
    procedure FormCreate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmCheckList: Tgdc_frmCheckList;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}

class function Tgdc_frmCheckList.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmCheckList) then
    gdc_frmCheckList := Tgdc_frmCheckList.Create(AnOwner);

  Result := gdc_frmCheckList;
end;

procedure Tgdc_frmCheckList.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCheckList;
  gdcDetailObject := gdcCheckListLine;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmCheckList);
  //RegisterClass(Tgdc_frmCheckList);

finalization
  UnRegisterFrmClass(Tgdc_frmCheckList);

end.
