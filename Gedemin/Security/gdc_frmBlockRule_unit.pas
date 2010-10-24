unit gdc_frmBlockRule_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdcBaseInterface, gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcBlockRule,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls, gd_ClassList;

type
  Tgdc_frmBlockRule = class(Tgdc_frmSGR)
    gdcBlockRule: TgdcBlockRule;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmBlockRule: Tgdc_frmBlockRule;

implementation

{$R *.DFM}

procedure Tgdc_frmBlockRule.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBlockRule;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmBlockRule);

finalization
  UnRegisterFrmClass(Tgdc_frmBlockRule);

end.
