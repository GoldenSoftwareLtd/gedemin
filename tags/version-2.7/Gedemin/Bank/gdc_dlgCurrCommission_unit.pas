unit gdc_dlgCurrCommission_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, at_Container,
  xCalculatorEdit, DBCtrls, Mask, xDateEdits,
  gsIBLookupComboBox, ExtCtrls, ComCtrls, IBSQL, gd_security,
  gd_security_body, IBCustomDataSet, gdcBase, gdcClasses, gdcPayment,
  gdcCurrCommission, gdcBaseBank, gdc_dlgTR_unit, IBDatabase, Menus;

type
  Tgdc_dlgCurrCommission = class(Tgdc_dlgTR)
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    pnlMain: TPanel;
    Bevel1: TBevel;
    Label17: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label3: TLabel;
    Label18: TLabel;
    Label23: TLabel;
    Label5: TLabel;
    Label15: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    dbeCorrAccount: TgsIBLookupComboBox;
    dbePaymentDestination: TDBMemo;
    dbeNumber: TDBEdit;
    dbeDate: TxDateDBEdit;
    dbeQueue: TDBEdit;
    dbeDest: TgsIBLookupComboBox;
    dbeCorrCompany: TgsIBLookupComboBox;
    edBank: TEdit;
    dbeAdditional: TDBEdit;
    dbeAmount: TxDBCalculatorEdit;
    gsibluOwnAccount: TgsIBLookupComboBox;
    cmbKind: TComboBox;
    cmbExpense: TComboBox;
    dbeMidCorrBank: TDBEdit;
    tsAttribute: TTabSheet;
    atContainer: TatContainer;
    Label7: TLabel;
    edCurrency: TEdit;
    procedure dbeCorrAccountChange(Sender: TObject);
    procedure dbeCorrCompanyChange(Sender: TObject);
    procedure gsibluOwnAccountChange(Sender: TObject);

  private
    FShowingForm: boolean;

    procedure UpdateBankInfo;
    procedure UpdateCorrAccount;
    procedure UpdateAdditional;
    procedure UpdateCurrency;
    procedure UpdateCorrCompany;


  protected
    procedure BeforePost; override;

  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;


var
  gdc_dlgCurrCommission: Tgdc_dlgCurrCommission;

implementation

uses dmDataBase_unit, gd_ClassList;

{$R *.DFM}

{ Tgdc_dlgCurrCommission }

procedure Tgdc_dlgCurrCommission.dbeCorrAccountChange(Sender: TObject);
begin
  inherited;
  if FShowingForm then
  begin
    UpdateBankInfo;
    if dbeCorrCompany.CurrentKey = '' then
      UpdateCorrCompany;
  end;
end;

procedure Tgdc_dlgCurrCommission.UpdateBankInfo;
begin
  edBank.Text := TgdcBaseBank(gdcObject).GetBankInfo(dbeCorrAccount.CurrentKey);
end;

procedure Tgdc_dlgCurrCommission.UpdateCorrAccount;
begin
  if gdcObject.FieldByName('CORRCOMPANYKEY').AsString = '' then
    dbeCorrAccount.Condition := ''
  else
    dbeCorrAccount.Condition := 'Companykey = ' +
      gdcObject.FieldByName('CORRCOMPANYKEY').AsString;

  TgdcCurrCommission(gdcObject).UpdateCorrAccount;
end;

procedure Tgdc_dlgCurrCommission.UpdateAdditional;
begin
  TgdcCurrCommission(gdcObject).UpdateAdditional;
end;

procedure Tgdc_dlgCurrCommission.dbeCorrCompanyChange(Sender: TObject);
begin
  inherited;
  if (gdcObject = nil) or
     (not (gdcObject.State in [dsInsert, dsEdit])) then
    exit;
  if  FShowingForm and
    ((dbeCorrCompany.Text > '') and (dbeCorrCompany.CurrentKey > '')) or
    (dbeCorrCompany.Text = '') then
  begin
    UpdateAdditional;
    UpdateCorrAccount;
  end;
end;

procedure Tgdc_dlgCurrCommission.gsibluOwnAccountChange(Sender: TObject);
begin
  inherited;
  if FShowingForm then
    UpdateCurrency;
end;

procedure Tgdc_dlgCurrCommission.UpdateCurrency;
begin
  edCurrency.Text :=
    TgdcCurrCommission(gdcObject).GetCurrencyByAccount(gsibluOwnAccount.CurrentKeyInt);
end;

procedure Tgdc_dlgCurrCommission.UpdateCorrCompany;
begin
  TgdcBasePayment(gdcObject).UpdateCorrCompany;
end;

procedure Tgdc_dlgCurrCommission.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCURRCOMMISSION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCURRCOMMISSION', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCURRCOMMISSION',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with gdcObject do
  begin
    case cmbKind.ItemIndex of
      0: FieldByName('KIND').Value := 'C';
      1: FieldByName('KIND').Value := 'P';
    end;

    case cmbExpense.ItemIndex of
      0: FieldByName('EXPENSEACCOUNT').Value := 'P';
      1: FieldByName('EXPENSEACCOUNT').Value := 'B';
      2: FieldByName('EXPENSEACCOUNT').Value := 'O';
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCURRCOMMISSION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCURRCOMMISSION', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCurrCommission.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCURRCOMMISSION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCURRCOMMISSION', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCURRCOMMISSION',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FShowingForm := true;

  gsibluOwnAccount.Condition := 'COMPANYKEY = ' + IntToStr(IBLogin.CompanyKey);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCURRCOMMISSION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCURRCOMMISSION', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgCurrCommission.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCURRCOMMISSION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCURRCOMMISSION', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCURRCOMMISSION',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.State = dsInsert then
  begin
    edBank.Text := '';
    UpdateCurrency;
    dbeCorrAccount.Condition := '';
    dbeCorrAccount.CurrentKey := '';
  end else
  begin
    UpdateCorrAccount;
    UpdateAdditional;
    UpdateBankInfo;
    UpdateCurrency;
  end;


  if gdcObject.FieldByName('KIND').AsString = 'P' then
     cmbKind.ItemIndex := 1
  else
     cmbKind.ItemIndex := 0;

  if gdcObject.FieldByName('EXPENSEACCOUNT').AsString > '' then
  begin
    if gdcObject.FieldByName('EXPENSEACCOUNT').AsString = 'P' then
      cmbExpense.ItemIndex := 0
    else if gdcObject.FieldByName('EXPENSEACCOUNT').AsString = 'B' then
      cmbExpense.ItemIndex := 1
      else
        cmbExpense.ItemIndex := 2;
  end else
    cmbExpense.ItemIndex := 0;

  FShowingForm := false;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCURRCOMMISSION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCURRCOMMISSION', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgCurrCommission);

finalization
  UnRegisterFrmClass(Tgdc_dlgCurrCommission);

end.
