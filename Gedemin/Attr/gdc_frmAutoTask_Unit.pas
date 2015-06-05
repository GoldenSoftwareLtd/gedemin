unit gdc_frmAutoTask_unit;

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
    actReRead: TAction;
    TBItem1: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actReReadExecute(Sender: TObject);
    procedure actReReadUpdate(Sender: TObject);
  end;

var
  gdc_frmAutoTask: Tgdc_frmAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList, gd_AutoTaskThread;

procedure Tgdc_frmAutoTask.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAutoTask;
  gdcDetailObject := gdcAutoTaskLog;

  inherited;
end;

procedure Tgdc_frmAutoTask.actReReadExecute(Sender: TObject);
begin
  gdAutoTaskThread.ReLoadTaskList;
end;

procedure Tgdc_frmAutoTask.actReReadUpdate(Sender: TObject);
begin
  actReRead.Enabled := gdAutoTaskThread <> nil;
end;

initialization
  RegisterFrmClass(Tgdc_frmAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_frmAutoTask);
end.
