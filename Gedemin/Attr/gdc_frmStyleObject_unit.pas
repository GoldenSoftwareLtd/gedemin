unit gdc_frmStyleObject_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcStyle, IBCustomDataSet, gdcBase;

type
  Tgdc_frmStyleObject = class(Tgdc_frmMDHGR)
    gdcStyleObject: TgdcStyleObject;
    gdcStyle: TgdcStyle;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmStyleObject: Tgdc_frmStyleObject;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmStyleObject.FormCreate(Sender: TObject);
begin
  gdcObject := gdcStyleObject;
  gdcDetailObject := gdcStyle;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmStyleObject, 'Стили');

finalization
  UnRegisterFrmClass(Tgdc_frmStyleObject);

end.
