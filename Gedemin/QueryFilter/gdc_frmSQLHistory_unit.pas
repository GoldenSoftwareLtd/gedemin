// ShlTanya, 10.03.2019

unit gdc_frmSQLHistory_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcSQLHistory;

type
  Tgdc_frmSQLHistory = class(Tgdc_frmSGR)
    gdcSQLHistory: TgdcSQLHistory;
    actEnableTrace: TAction;
    chbxTrace: TCheckBox;
    tbiTrace: TTBControlItem;
    actDeleteTraceLog: TAction;
    tbiDeleteTraceLog: TTBItem;
    tbsTrace: TTBSeparatorItem;
    actDeleteHistory: TAction;
    tbiDeleteHistory: TTBItem;
    actRefr: TAction;
    tbiRefr: TTBItem;
    tbsRefr: TTBSeparatorItem;
    procedure FormCreate(Sender: TObject);
    procedure actEnableTraceExecute(Sender: TObject);
    procedure actDeleteTraceLogExecute(Sender: TObject);
    procedure actDeleteHistoryExecute(Sender: TObject);
    procedure actRefrExecute(Sender: TObject);
    procedure actRefrUpdate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmSQLHistory: Tgdc_frmSQLHistory;

implementation

{$R *.DFM}

uses
  gd_ClassList, IBSQLMonitor_Gedemin;

class function Tgdc_frmSQLHistory.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmSQLHistory) then
    gdc_frmSQLHistory := Tgdc_frmSQLHistory.Create(AnOwner);
  Result := gdc_frmSQLHistory;
end;

procedure Tgdc_frmSQLHistory.FormCreate(Sender: TObject);
begin
  gdcObject := gdcSQLHistory;
  inherited;
end;

procedure Tgdc_frmSQLHistory.actEnableTraceExecute(Sender: TObject);
begin
  MonitorHook.Enabled := chbxTrace.Checked;
end;

procedure Tgdc_frmSQLHistory.actDeleteTraceLogExecute(Sender: TObject);
begin
  (gdcObject as TgdcSQLHistory).DeleteTraceLog;
end;

procedure Tgdc_frmSQLHistory.actDeleteHistoryExecute(Sender: TObject);
begin
  (gdcObject as TgdcSQLHistory).DeleteHistory;
end;

procedure Tgdc_frmSQLHistory.actRefrExecute(Sender: TObject);
var
  OldEnabled: Boolean;
begin
  OldEnabled := MonitorHook.Enabled;
  try
    MonitorHook.Enabled := False;
    gdcObject.CloseOpen;
  finally
    MonitorHook.Enabled := OldEnabled;
  end;
end;

procedure Tgdc_frmSQLHistory.actRefrUpdate(Sender: TObject);
begin
  actRefr.Enabled := (gdcObject <> nil) and gdcObject.Active;
end;

initialization
  RegisterFrmClass(Tgdc_frmSQLHistory);

finalization
  UnRegisterFrmClass(Tgdc_frmSQLHistory);

end.
