unit gdc_frmInvSelectRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmInvBaseRemains_unit, Db, IBCustomDataSet, gdcBase, gdcGood, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView,
  ToolWin, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gdcInvMovement, gdcTree,
  gd_MacrosMenu, StdCtrls, gdc_frmInvBaseSelectRemains_unit;

type
  Tgdc_frmInvSelectRemains = class(Tgdc_frmInvBaseSelectRemains)
    gdcInvRemains: TgdcInvRemains;
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure ibgrDetailClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);
    procedure gdcInvRemainsAfterPost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);

  public
    procedure Setup(anObject: TObject); override;
  end;

var
  gdc_frmInvSelectRemains: Tgdc_frmInvSelectRemains;

implementation

{$R *.DFM}

uses
  Storages,  gd_ClassList;

{ Tgdc_frmInvSelectRemains }

procedure Tgdc_frmInvSelectRemains.Setup(anObject: TObject);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMINVSELECTREMAINS', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMINVSELECTREMAINS', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVSELECTREMAINS') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVSELECTREMAINS',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVSELECTREMAINS' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited Setup(gdcInvRemains);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVSELECTREMAINS', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVSELECTREMAINS', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvSelectRemains.actDeleteChooseExecute(Sender: TObject);
begin
  FgdcChooseObject.DeleteMultiple(ibgrChoose.SelectedRows);
  SetFocus;
end;

procedure Tgdc_frmInvSelectRemains.ibgrDetailClickedCheck(Sender: TObject;
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

procedure Tgdc_frmInvSelectRemains.gdcInvRemainsAfterPost(
  DataSet: TDataSet);
begin
  inherited;
  if gdcObject.FieldByName('ChooseQuantity').AsCurrency > 0 then
    ibgrDetail.AddCheck;
end;

procedure Tgdc_frmInvSelectRemains.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcInvRemains;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvSelectRemains, 'Форма выбора товарных остатков');

finalization
  UnRegisterFrmClass(Tgdc_frmInvSelectRemains);
end.
