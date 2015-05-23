unit gdc_frmInvSelectGoodRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmInvSelectRemains_unit, gdcInvMovement, Db, IBCustomDataSet,
  gdcBase, gdcTree, gdcGood, gd_MacrosMenu, Menus, ActnList, Grids,
  DBGrids, gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls,
  TB2Item, TB2Dock, TB2Toolbar, gdc_frmInvBaseSelectRemains_unit;

type
  Tgdc_frmInvSelectGoodRemains = class(Tgdc_frmInvBaseSelectRemains)
    gdcInvRemains: TgdcInvGoodRemains;
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure gdcInvGoodRemainsAfterPost(DataSet: TDataSet);
    procedure ibgrDetailClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);
    procedure FormCreate(Sender: TObject);

  public
     procedure Setup(anObject: TObject); override;
  end;

var
  gdc_frmInvSelectGoodRemains: Tgdc_frmInvSelectGoodRemains;

implementation

{$R *.DFM}

uses
  Storages,  gd_ClassList;

procedure Tgdc_frmInvSelectGoodRemains.Setup(anObject: TObject);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMINVSELECTGOODREMAINS', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMINVSELECTGOODREMAINS', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVSELECTGOODREMAINS') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVSELECTGOODREMAINS',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVSELECTGOODREMAINS' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited Setup(gdcInvRemains);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVSELECTGOODREMAINS', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVSELECTGOODREMAINS', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvSelectGoodRemains.actDeleteChooseExecute(Sender: TObject);
begin
  FgdcChooseObject.DeleteMultiple(ibgrChoose.SelectedRows)
end;

procedure Tgdc_frmInvSelectGoodRemains.ibgrDetailClickedCheck(Sender: TObject;
  CheckID: String; Checked: Boolean);
begin
  inherited;
  if Checked and (gdcObject.FieldByName('ChooseQuantity').AsCurrency = 0) then
  begin
    gdcObject.Edit;
    gdcObject.FieldByName('ChooseQuantity').AsCurrency :=
      gdcObject.FieldByName('Remains').AsCurrency;
    gdcObject.Post;
  end;
end;

procedure Tgdc_frmInvSelectGoodRemains.gdcInvGoodRemainsAfterPost(
  DataSet: TDataSet);
begin
  inherited;
  if gdcObject.FieldByName('ChooseQuantity').AsCurrency > 0 then
    ibgrDetail.AddCheck;
end;

procedure Tgdc_frmInvSelectGoodRemains.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcInvRemains;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvSelectGoodRemains);

finalization
  UnRegisterFrmClass(Tgdc_frmInvSelectGoodRemains);
end.
