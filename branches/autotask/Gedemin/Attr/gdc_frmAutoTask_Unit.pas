unit gdc_frmAutoTask_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcAutoTask, IBCustomDataSet, gdcBase;

type
  Tgdc_frmAutoTask = class(Tgdc_frmMDHGR)
    gdcAutoTaskLog: TgdcAutoTaskLog;
    gdcAutoTask: TgdcAutoTask;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAutoTask: Tgdc_frmAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmAutoTask.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAutoTask;
  gdcDetailObject := gdcAutoTaskLog;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_frmAutoTask);

end.
