unit gdc_frmBlockRule_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdcBaseInterface, gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase,
  gdcBlockRule, gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls,
  gd_ClassList, gdc_frmG_unit;

type
  Tgdc_frmBlockRule = class(Tgdc_frmSGR)
    DataSource1: TDataSource;
    tbBlokRupePriorUp: TTBItem;
    tbBlokRupePriorDown: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    actBlockRulePriorUp: TAction;
    actBlockRulePriorDown: TAction;
    gdcBlockRule: TgdcBlockRule;
    procedure FormCreate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actBlockRulePriorUpExecute(Sender: TObject);
    procedure actBlockRulePriorDownExecute(Sender: TObject);
    procedure gdcBlockRuleGetOrderClause(Sender: TObject;
      var Clause: String);
    procedure gdcBlockRuleBeforeDelete(DataSet: TDataSet);
    procedure actBlockRulePriorUpUpdate(Sender: TObject);
    procedure actBlockRulePriorDownUpdate(Sender: TObject);
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

procedure Tgdc_frmBlockRule.actEditExecute(Sender: TObject);
begin
  if not gdcBlockRule.Eof then
    gdcBlockRule.ReadDocTypes(gdcBlockRule.FieldByName('id').AsInteger); 
  inherited;
end;

procedure Tgdc_frmBlockRule.actDuplicateExecute(Sender: TObject);
begin
  if not gdcBlockRule.Eof then
    gdcBlockRule.ReadDocTypes(gdcBlockRule.FieldByName('id').AsInteger);
  inherited;
end;

procedure Tgdc_frmBlockRule.actBlockRulePriorUpExecute(Sender: TObject);
begin
  inherited;
  gdcBlockRule.ChangeBlockRulePrior(cpUp);
end;

procedure Tgdc_frmBlockRule.actBlockRulePriorDownExecute(Sender: TObject);
begin
  inherited;
  gdcBlockRule.ChangeBlockRulePrior(cpDown);
end;

procedure Tgdc_frmBlockRule.gdcBlockRuleGetOrderClause(Sender: TObject;
  var Clause: String);
begin
  Clause := 'ORDER BY ordr';
end;

procedure Tgdc_frmBlockRule.gdcBlockRuleBeforeDelete(DataSet: TDataSet);
begin
  inherited;
  gdcBlockRule.CheckBlockTrigger;
end;

procedure Tgdc_frmBlockRule.actBlockRulePriorUpUpdate(Sender: TObject);
begin
  actBlockRulePriorUp.Enabled := not gdcObject.IsEmpty;
end;

procedure Tgdc_frmBlockRule.actBlockRulePriorDownUpdate(Sender: TObject);
begin
  actBlockRulePriorDown.Enabled := not gdcObject.IsEmpty;
end;

initialization
  RegisterFrmClass(Tgdc_frmBlockRule);

finalization
  UnRegisterFrmClass(Tgdc_frmBlockRule);

end.
