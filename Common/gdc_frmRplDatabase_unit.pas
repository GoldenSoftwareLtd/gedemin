unit gdc_frmRplDatabase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcReplication;

type
  Tgdc_frmRplDatabase = class(Tgdc_frmSGR)
    gdcRplDatabase: TgdcRplDatabase;
    TBControlItem1: TTBControlItem;
    lblMainBase: TLabel;
    actSetMainBase: TAction;
    Button1: TButton;
    TBControlItem2: TTBControlItem;
    TBSeparatorItem1: TTBSeparatorItem;
    procedure FormCreate(Sender: TObject);
    procedure actSetMainBaseUpdate(Sender: TObject);
    procedure actSetMainBaseExecute(Sender: TObject);

  private
    FMainBaseID: Integer;

    procedure UpdateMainBase;

  public
    { Public declarations }
  end;

var
  gdc_frmRplDatabase: Tgdc_frmRplDatabase;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface;

procedure Tgdc_frmRplDatabase.FormCreate(Sender: TObject);
begin
  FMainBaseID := -1;
  gdcObject := gdcRplDatabase;

  inherited;

  UpdateMainBase;
end;

procedure Tgdc_frmRplDatabase.UpdateMainBase;
var
  R: OLEVariant;
begin
  gdcBaseManager.ExecSingleQueryResult(
    'SELECT b.id, b.name FROM rp2_base b JOIN rp2_main_base m ON m.id = b.id', 0, R);
  if VarIsEmpty(R) then
  begin
    lblMainBase.Caption := 'Главная база не назначена.';
    FMainBaseID := -1;
  end else
  begin
    lblMainBase.Caption := 'Главная база: ' + R[1, 0];
    FMainBaseID := R[0, 0];
  end;
end;

procedure Tgdc_frmRplDatabase.actSetMainBaseUpdate(Sender: TObject);
begin
  actSetMainBase.Enabled := (not gdcObject.IsEmpty)
    and (FMainBaseID <> gdcObject.ID);
end;

procedure Tgdc_frmRplDatabase.actSetMainBaseExecute(Sender: TObject);
begin
  gdcBaseManager.ExecSingleQuery('DELETE FROM rp2_main_base');
  gdcBaseManager.ExecSingleQuery('INSERT INTO rp2_main_base (id) VALUES (' +
    gdcObject.FieldByName('id').AsString + ')');
  UpdateMainBase;
end;

initialization
  RegisterFrmClass(Tgdc_frmRplDatabase);

finalization
  UnRegisterFrmClass(Tgdc_frmRplDatabase);
end.
