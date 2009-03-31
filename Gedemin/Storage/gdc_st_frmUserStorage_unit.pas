unit gdc_st_frmUserStorage_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcStorage;

type
  Tgdc_st_frmUserStorage = class(Tgdc_frmSGR)
    gdcUserStorage: TgdcUserStorage;
    procedure FormCreate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_st_frmUserStorage: Tgdc_st_frmUserStorage;

implementation
uses
  gd_ClassList;

{$R *.DFM}

class function Tgdc_st_frmUserStorage.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_st_frmUserStorage) then
    gdc_st_frmUserStorage := Tgdc_st_frmUserStorage.Create(AnOwner);
  Result := gdc_st_frmUserStorage;
end;

procedure Tgdc_st_frmUserStorage.FormCreate(Sender: TObject);
begin
  gdcObject := gdcUserStorage;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_st_frmUserStorage);

finalization
  UnRegisterFrmClass(Tgdc_st_frmUserStorage);

end.
