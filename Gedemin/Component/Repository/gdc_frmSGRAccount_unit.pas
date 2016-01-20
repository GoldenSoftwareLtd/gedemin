//

unit gdc_frmSGRAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, StdCtrls, gsIBLookupComboBox, Db, Menus, ActnList,
  Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, gdcBase,
  gsTransaction, IBDatabase, gdcClasses, FrmPlSvr, TB2Item, TB2Dock,
  TB2Toolbar, gdcBaseBank, gd_MacrosMenu;

type
  Tgdc_frmSGRAccount = class(Tgdc_frmSGR)
    gsTransaction: TgsTransaction;
    IBTransaction: TIBTransaction;
    nOptionsPrint: TMenuItem;
    TBControlItem1: TTBControlItem;
    ibcmbAccount: TgsIBLookupComboBox;
    procedure ibcmbAccountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ibcmbAccountCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmSGRAccount: Tgdc_frmSGRAccount;

implementation

{$R *.DFM}

uses
  Storages, gd_security, gd_ClassList;

procedure Tgdc_frmSGRAccount.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSGRACCOUNT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSGRACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSGRACCOUNT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSGRACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CompanyStorage.LoadComponent(ibcmbAccount, ibcmbAccount.LoadFromStream);
  ibcmbAccount.CurrentKeyInt := CompanyStorage.ReadInteger('Bank', 'CurrentAccount', -1);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmSGRAccount.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSGRACCOUNT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSGRACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSGRACCOUNT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSGRACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CompanyStorage.SaveComponent(ibcmbAccount, ibcmbAccount.SaveToStream);
  CompanyStorage.WriteInteger('Bank', 'CurrentAccount', ibcmbAccount.CurrentKeyInt);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmSGRAccount.ibcmbAccountChange(Sender: TObject);
begin
  inherited;
  if gdcObject <> nil then
  begin
    gdcObject.Close;
    if ibcmbAccount.CurrentKeyInt > 0 then
    begin
      if not gdcObject.HasSubSet('ByAccount') then
        gdcObject.AddSubSet('ByAccount');
      gdcObject.ParamByName('AccountKey').AsInteger := ibcmbAccount.CurrentKeyInt;
    end
    else begin
      if gdcObject.HasSubSet('ByAccount') then
        gdcObject.RemoveSubSet('ByAccount');
    end;
    gdcObject.Open;
  end;
end;

procedure Tgdc_frmSGRAccount.FormCreate(Sender: TObject);
begin
  inherited;

  if ibcmbAccount.Condition > '' then
    ibcmbAccount.Condition := ibcmbAccount.Condition + ' AND ';

  ibcmbAccount.Condition := ibcmbAccount.Condition + ' gd_companyaccount.companykey in (' + IBLogin.HoldingList + ')';

  gdcObject.Close;

  (gdcObject as TgdcBaseBank).gsTransaction := gsTransaction;

  gsTransaction.AddConditionDataSet([gdcObject]);
  gsTransaction.SetStartTransactionInfo(False);
  ibcmbAccountChange(ibcmbAccount);
end;

procedure Tgdc_frmSGRAccount.ibcmbAccountCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  ANewObject.FieldByName('companykey').AsInteger := IBLogin.CompanyKey;
end;

initialization
  with RegisterFrmClass(Tgdc_frmSGRAccount, 'Форма просмотра с таблицей и выбором р/с') do
  begin
    AbstractBaseForm := True;
    ShowInFormEditor := True;
  end;

finalization
  UnRegisterFrmClass(Tgdc_frmSGRAccount);
end.
