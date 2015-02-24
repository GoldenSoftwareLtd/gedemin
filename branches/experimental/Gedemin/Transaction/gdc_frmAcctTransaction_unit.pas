unit gdc_frmAcctTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcAcctTransaction, IBCustomDataSet, gdcBaseInterface, gdcBase,
  gdcTree, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmAcctTransaction = class(Tgdc_frmMDVTree)
    gdcAcctTransaction: TgdcAcctTransaction;
    gdcAcctTransactionEntry: TgdcAcctTransactionEntry;
    procedure FormCreate(Sender: TObject);
  private

  protected
    procedure RemoveSubSetList(S: TStrings); override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  gdc_frmAcctTransaction: Tgdc_frmAcctTransaction;

implementation

{$R *.DFM}

{ Tgdc_frmAcctTransaction }

uses
  gd_ClassList;

class function Tgdc_frmAcctTransaction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmAcctTransaction) then
    gdc_frmAcctTransaction := Tgdc_frmAcctTransaction.Create(AnOwner);
  Result := gdc_frmAcctTransaction;
end;

procedure Tgdc_frmAcctTransaction.FormCreate(Sender: TObject);
begin
  inherited;

  gdcObject := gdcAcctTransaction;
  gdcDetailObject := gdcAcctTransactionEntry;
end;

procedure Tgdc_frmAcctTransaction.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMACCTTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMACCTTRANSACTION', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMACCTTRANSACTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMACCTTRANSACTION',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMACCTTRANSACTION' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  S.Add('ByTransaction');

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMACCTTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMACCTTRANSACTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_frmAcctTransaction);

finalization
  UnRegisterFrmClass(Tgdc_frmAcctTransaction);

end.

