unit gdc_frmFKManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVGr_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcFKManager, IBCustomDataSet, gdcBase;

type
  Tgdc_frmFKManager = class(Tgdc_frmMDVGr)
    gdcFKManager: TgdcFKManager;
    gdcFKManagerData: TgdcFKManagerData;
    actUpdateStats: TAction;
    tbiUpdateStats: TTBItem;
    actCancelUpdateStats: TAction;
    TBItem1: TTBItem;
    pbUpdateStats: TProgressBar;
    TBControlItem1: TTBControlItem;
    tbsiUpdateStats: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem2: TTBItem;
    actConvertFK: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actUpdateStatsExecute(Sender: TObject);
    procedure actUpdateStatsUpdate(Sender: TObject);
    procedure actCancelUpdateStatsUpdate(Sender: TObject);
    procedure actCancelUpdateStatsExecute(Sender: TObject);
    procedure actConvertFKExecute(Sender: TObject);
    procedure actConvertFKUpdate(Sender: TObject);

  private
    procedure WM_UpdateStats(var Msg: TMessage); message WM_UPDATESTATS;

  public
    { Public declarations }
  end;

var
  gdc_frmFKManager: Tgdc_frmFKManager;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmFKManager.FormCreate(Sender: TObject);
begin
  gdcFKManager.SyncWithSystemMetadata;

  gdcObject := gdcFKManager;
  gdcDetailObject := gdcFKManagerData;

  inherited;
end;

procedure Tgdc_frmFKManager.actUpdateStatsExecute(Sender: TObject);
begin
  gdcFKManager.UpdateStats(Handle);
end;

procedure Tgdc_frmFKManager.actUpdateStatsUpdate(Sender: TObject);
begin
  actUpdateStats.Enabled := not gdcFKManager.IsUpdateStatsRunning;
end;

procedure Tgdc_frmFKManager.actCancelUpdateStatsUpdate(Sender: TObject);
begin
  actCancelUpdateStats.Enabled := gdcFKManager.IsUpdateStatsRunning;
end;

procedure Tgdc_frmFKManager.actCancelUpdateStatsExecute(Sender: TObject);
begin
  gdcFKManager.CancelUpdateStats;
end;

procedure Tgdc_frmFKManager.WM_UpdateStats(var Msg: TMessage);
begin
  case Msg.WParam of
    CMD_INIT:
    begin
      pbUpdateStats.Min := 0;
      pbUpdateStats.Max := Msg.LParam;
      pbUpdateStats.Position := 0;
    end;

    CMD_UPDATE:
    begin
      pbUpdateStats.Position := Msg.LParam;
    end;

    CMD_CLEAR:
    begin
      pbUpdateStats.Min := 0;
      pbUpdateStats.Max := 0;
      pbUpdateStats.Position := 0;
    end;
  end;
end;

procedure Tgdc_frmFKManager.actConvertFKExecute(Sender: TObject);
begin
  if gdcFKManager.ConvertFK then
  begin
  end;
end;

procedure Tgdc_frmFKManager.actConvertFKUpdate(Sender: TObject);
begin
  actConvertFK.Enabled := not gdcFKManager.IsUpdateStatsRunning;
end;

initialization
  RegisterFrmClass(Tgdc_frmFKManager);

finalization
  UnRegisterFrmClass(Tgdc_frmFKManager);

end.
