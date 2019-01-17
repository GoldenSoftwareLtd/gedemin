// andreik, 15.01.2019

unit gdc_frmAccountType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcClasses, gdcBaseBank, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ToolWin, ComCtrls,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmAccountType = class(Tgdc_frmSGR)
    gdcCompanyAccountType: TgdcCompanyAccountType;
    procedure FormCreate(Sender: TObject);
  private
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmAccountType: Tgdc_frmAccountType;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmAccountType.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmAccountType) then
    gdc_frmAccountType := Tgdc_frmAccountType.Create(AnOwner);
  Result := gdc_frmAccountType;
end;

procedure Tgdc_frmAccountType.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCompanyAccountType;

  inherited;

  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmAccountType);

finalization
  UnRegisterFrmClass(Tgdc_frmAccountType);
end.
