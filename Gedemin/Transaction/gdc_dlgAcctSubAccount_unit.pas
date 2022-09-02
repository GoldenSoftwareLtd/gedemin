// ShlTanya, 09.03.2019

unit gdc_dlgAcctSubAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgAcctBaseAccount_unit, Db, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, StdCtrls, gsIBLookupComboBox, ExtCtrls, DBCtrls, Mask,
  at_Container, IBDatabase, Menus, ComCtrls, Buttons;

type
  Tgdc_dlgAcctSubAccount = class(Tgdc_dlgAcctBaseAccount)
    lblHint: TLabel;
    procedure dbedAliasChange(Sender: TObject);

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount;

implementation

{$R *.DFM}

uses
  gd_ClassList, jclStrings, gdc_frmAcctAccount_unit, gdcBaseInterface;

procedure Tgdc_dlgAcctSubAccount.dbedAliasChange(Sender: TObject);
begin
  lblHint.Visible := StrIPos(gsiblcGroupAccount.Text, dbedAlias.Text) <> 1;
end;

procedure Tgdc_dlgAcctSubAccount.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTSUBACCOUNT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTSUBACCOUNT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTSUBACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTSUBACCOUNT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTSUBACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.State = dsInsert then
  begin
    if Owner is Tgdc_frmAcctAccount then
    begin
      if (Owner as Tgdc_frmAcctAccount).gdcDetailObject.FieldByName('accounttype').AsString = 'S' then
        SetTID(gdcObject.FieldByName('parent'), (Owner as Tgdc_frmAcctAccount).gdcDetailObject.FieldByName('parent'))
      else
        SetTID(gdcObject.FieldByName('parent'), (Owner as Tgdc_frmAcctAccount).gdcDetailObject.FieldByName('id'));
    end
    else
      gdcObject.FieldByName('parent').Clear;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTSUBACCOUNT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTSUBACCOUNT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctSubAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctSubAccount);

end.
