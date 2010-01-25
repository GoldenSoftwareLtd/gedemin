unit gdc_frmDelphiObject_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcTree, gdcDelphiObject,
  gd_ClassList;

type
  Tgdc_frmDelphiObject = class(Tgdc_frmSGR)
    gdcDelphiObject: TgdcDelphiObject;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmDelphiObject: Tgdc_frmDelphiObject;

implementation

{$R *.DFM}

procedure Tgdc_frmDelphiObject.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcDelphiObject;
  gdcObject.Open;
end;
initialization
  RegisterFrmClass(Tgdc_frmDelphiObject);

finalization
  UnRegisterFrmClass(Tgdc_frmDelphiObject);

end.
