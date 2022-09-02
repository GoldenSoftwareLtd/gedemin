// ShlTanya, 29.01.2019

unit gdc_frmMainGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Menus, StdCtrls, ExtCtrls, ActnList, ComCtrls, Db,
  IBCustomDataSet, IBQuery, ImgList, Grids, DBGrids, IBUpdateSQL,
  ToolWin, flt_sqlFilter, gsDBGrid, gsIBGrid, IBDatabase,
  gsDBTreeView, IBSQL,  gd_Createable_Form,
  at_sql_setup, gsReportRegistry, dmDatabase_unit, gsDBReduction,
  gsReportManager, gdc_frmMDVTree_unit, gdcGood, gdcBase,
  gdcConst, TB2Item, TB2Dock, TB2Toolbar, gdcTree, gd_MacrosMenu;

type
  Tgdc_frmMainGood = class(Tgdc_frmMDVTree)
    gdcGoodGroup: TgdcGoodGroup;
    gdcGood: TgdcGood;
    tbsiNew: TTBSubmenuItem;
    tbiSubNew: TTBItem;
    actNewSub: TAction;
    tblMenuNew: TTBItem;
    actViewAllCard: TAction;
    tbiViewAllCard: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actNewSubExecute(Sender: TObject);
    procedure actViewAllCardUpdate(Sender: TObject);
    procedure actViewAllCardExecute(Sender: TObject);

  protected
    procedure RemoveSubSetList(S:TStrings); override;
    procedure SetGdcObject(const Value: TgdcBase); override;

  public
    class function CreateAndAssign(
      AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmMainGood: Tgdc_frmMainGood;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdc_frmInvCard_unit, gdcBaseInterface;

class function Tgdc_frmMainGood.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmMainGood) then
    gdc_frmMainGood := Tgdc_frmMainGood.Create(AnOwner);
  Result := gdc_frmMainGood
end;

procedure Tgdc_frmMainGood.FormCreate(Sender: TObject);
begin
  gdcObject := gdcGoodGroup;
  gdcDetailObject := gdcGood;

  inherited;
end;

procedure Tgdc_frmMainGood.SetGdcObject(const Value: TgdcBase);
begin
  inherited;

  tbsiNew.Visible := False;
  tbiNew.Visible := True;
end;

procedure Tgdc_frmMainGood.actNewSubExecute(Sender: TObject);
begin
  // не удалять
  //gdcGoodGroup.CreateChildrenDialog;
end;

procedure Tgdc_frmMainGood.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMMAINGOOD', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMAINGOOD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMAINGOOD',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMAINGOOD' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  S.Add('byGroup');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMainGood.actViewAllCardUpdate(Sender: TObject);
begin
  actViewAllCard.Enabled := not gdcDetailObject.IsEmpty;
end;

procedure Tgdc_frmMainGood.actViewAllCardExecute(Sender: TObject);
begin
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    gdcObject := gdcInvCard;
    gdcObject.SubSet := 'ByHolding,ByGoodOnly';
    SetTID(gdcObject.ParamByName('goodkey'), gdcDetailObject.ID);
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmMainGood);

finalization
  UnRegisterFrmClass(Tgdc_frmMainGood);

end.
