unit gdc_frmAutoTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, gd_ClassList, gdcAutoTransaction, IBCustomDataSet,
  gdcBase, gdcTree, gdcAcctTransaction;

type
  Tgdc_frmAutoTransaction = class(Tgdc_frmMDVTree)
    gdcAutoTransaction: TgdcAutoTransaction;
    gdcAutoTrRecord: TgdcAutoTrRecord;
    TBItem1: TTBItem;
    actExecOperation: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem2: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actExecOperationUpdate(Sender: TObject);
    procedure actExecOperationExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure RemoveSubSetList(S: TStrings); override;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmAutoTransaction: Tgdc_frmAutoTransaction;


implementation
uses gd_i_ScriptFactory;
{$R *.DFM}
procedure Tgdc_frmAutoTransaction.FormCreate(Sender: TObject);
begin
  inherited;

  gdcObject := gdcAutoTransaction;
  gdcDetailObject := gdcAutoTrRecord;
end;

procedure Tgdc_frmAutoTransaction.actExecOperationUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (gdcAutoTrRecord.Active) and
    (gdcAutoTrRecord.FieldByName('functionkey').AsInteger > 0)
end;

procedure Tgdc_frmAutoTransaction.actExecOperationExecute(Sender: TObject);
var
  Params, Result: Variant;
begin
  if ScriptFactory <> nil then
  begin
    Params := VarArrayOf([]);
    Result := VarArrayOf([]);
    try
      if  ScriptFactory.InputParams(gdcAutoTrRecord.FieldByName('functionkey').AsInteger,
        Params)  then
        ScriptFactory.ExecuteFunction(gdcAutoTrRecord.FieldByName('functionkey').AsInteger,
          Params, Result);
    except
    end;
  end;
end;

class function Tgdc_frmAutoTransaction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmAutoTransaction) then
    gdc_frmAutoTransaction := Tgdc_frmAutoTransaction.Create(AnOwner);
  Result := gdc_frmAutoTransaction;
end;


procedure Tgdc_frmAutoTransaction.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMAUTOTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMAUTOTRANSACTION', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMAUTOTRANSACTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMAUTOTRANSACTION',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMAUTOTRANSACTION' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  S.Add('ByTransaction');

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMAUTOTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMAUTOTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_frmAutoTransaction);

finalization
  UnRegisterFrmClass(Tgdc_frmAutoTransaction);

end.
