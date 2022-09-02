// ShlTanya, 24.02.2019

unit gdc_frmJournal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcJournal, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ToolWin, ComCtrls,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmJournal = class(Tgdc_frmSGR)
    gdcJournal: TgdcJournal;
    tbiCreateTrig: TTBItem;
    actCreateTriggers: TAction;
    actDropTriggers: TAction;
    tbiDelTrig: TTBItem;
    nTriggerSeparator: TMenuItem;
    nTriggersCreate: TMenuItem;
    nTriggersDrop: TMenuItem;
    actOpenObject: TAction;
    tbsepBefOpenObject: TTBSeparatorItem;
    tbiOpenObject: TTBItem;
    tbi_mm_sep5_2: TTBSeparatorItem;
    tbiOpenObj: TTBItem;
    tbiDelTrig2: TTBItem;
    tbiCreateTrig2: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actCreateTriggersUpdate(Sender: TObject);
    procedure actCreateTriggersExecute(Sender: TObject);
    procedure actDropTriggersUpdate(Sender: TObject);
    procedure actDropTriggersExecute(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actDuplicateUpdate(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
  end;

var
  gdc_frmJournal: Tgdc_frmJournal;

implementation

{$R *.DFM}

{ Tgdc_frmJournal }

uses
  gd_ClassList, gd_security, gdcBaseInterface;

procedure Tgdc_frmJournal.FormCreate(Sender: TObject);
begin
  gdcObject := gdcJournal;
  inherited;
end;

procedure Tgdc_frmJournal.actCreateTriggersUpdate(Sender: TObject);
begin
  actCreateTriggers.Enabled := Assigned(IBLogin) and (IBLogin.IsIBUserAdmin);
end;

procedure Tgdc_frmJournal.actCreateTriggersExecute(Sender: TObject);
begin
  gdcJournal.CreateTriggers;
end;

procedure Tgdc_frmJournal.actDropTriggersUpdate(Sender: TObject);
begin
  actDropTriggers.Enabled := Assigned(IBLogin) and (IBLogin.IsIBUserAdmin);
end;

procedure Tgdc_frmJournal.actDropTriggersExecute(Sender: TObject);
begin
  gdcJournal.DropTriggers;
end;

procedure Tgdc_frmJournal.actOpenObjectExecute(Sender: TObject);
begin
  gdcJournal.OpenObject;
end;

procedure Tgdc_frmJournal.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := gdcObject.Active
    and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('source').AsString > '')
    and (GetTID(gdcObject.FieldByName('objectid')) > 0);
end;

procedure Tgdc_frmJournal.actDuplicateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := False;
end;

procedure Tgdc_frmJournal.actNewUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := False;
end;

procedure Tgdc_frmJournal.actDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := False;
end;

initialization
  RegisterFrmClass(Tgdc_frmJournal);

finalization
  UnRegisterFrmClass(Tgdc_frmJournal);
end.
