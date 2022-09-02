// ShlTanya, 30.01.2019

unit gdc_dlgCustomPayment_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, Db, ActnList, StdCtrls, at_Container,
  gsTransactionComboBox, xCalculatorEdit, DBCtrls, Mask, xDateEdits,
  gsIBLookupComboBox, ExtCtrls, ComCtrls, gsDocNumerator, IBSQL, gd_security,
  gd_security_body, gsTransaction, gdcClasses, gdcBaseBank, gdcPayment, FrmPlSvr,
  IBDatabase, Menus;

type
  Tgdc_dlgCustomPayment = class(Tgdc_dlgTR)
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    pnlMain: TPanel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Label17: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    Label10: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label3: TLabel;
    Label11: TLabel;
    Label18: TLabel;
    Label23: TLabel;
    Label5: TLabel;
    Label20: TLabel;
    dbeCorrAccount: TgsIBLookupComboBox;
    dbePaymentDestination: TDBMemo;
    dbeNumber: TDBEdit;
    dbeDate: TxDateDBEdit;
    dbeOper: TDBEdit;
    dbeQueue: TDBEdit;
    dbeDest: TgsIBLookupComboBox;
    dbeTerm: TxDateDBEdit;
    dbeOperKind: TDBEdit;
    dbeCorrCompany: TgsIBLookupComboBox;
    edBank: TEdit;
    dbeAdditional: TDBEdit;
    dbeAmount: TxDBCalculatorEdit;
    gsibluOwnAccount: TgsIBLookupComboBox;
    cmbExpense: TComboBox;
    tsAttribute: TTabSheet;
    atContainer: TatContainer;
    gsTransactionComboBox: TgsTransactionComboBox;
    Label8: TLabel;
    procedure dbeCorrAccountChange(Sender: TObject);
    procedure dbeCorrCompanyChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FgsTransaction: TgsTransaction;

    procedure UpdateBankInfo;
    procedure UpdateCorrAccount;
    procedure UpdateAdditional;
    procedure UpdateCorrCompany;

  protected
    FShowingForm: boolean;

    procedure Post; override;
    procedure BeforePost; override;

  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;


var
  gdc_dlgCustomPayment: Tgdc_dlgCustomPayment;

implementation

uses
  Storages, gd_ClassList, gdcBaseInterface;

{$R *.DFM}

{ Tgdc_dlgPaymentOrder }

procedure Tgdc_dlgCustomPayment.dbeCorrAccountChange(Sender: TObject);
begin
  inherited;
  if FShowingForm then
  begin
    UpdateBankInfo;
    if dbeCorrCompany.CurrentKey = '' then
      UpdateCorrCompany;
  end;
end;

procedure Tgdc_dlgCustomPayment.UpdateBankInfo;
begin
  edBank.Text := TgdcBasePayment(gdcObject).GetBankInfo(dbeCorrAccount.CurrentKey);
end;

procedure Tgdc_dlgCustomPayment.UpdateCorrAccount;
begin
  if gdcObject.FieldByName('CORRCOMPANYKEY').AsString = '' then
    dbeCorrAccount.Condition := ''
  else
    dbeCorrAccount.Condition := 'Companykey = ' +
      gdcObject.FieldByName('CORRCOMPANYKEY').AsString;

  TgdcBasePayment(gdcObject).UpdateCorrAccount;
end;

procedure Tgdc_dlgCustomPayment.UpdateAdditional;
begin
  TgdcBasePayment(gdcObject).UpdateAdditional;
end;

procedure Tgdc_dlgCustomPayment.UpdateCorrCompany;
begin
  TgdcBasePayment(gdcObject).UpdateCorrCompany;
end;

procedure Tgdc_dlgCustomPayment.dbeCorrCompanyChange(Sender: TObject);
begin
  inherited;

  if (gdcObject = nil) or
     (not (gdcObject.State in [dsInsert, dsEdit])) then
    exit;
  if  (FShowingForm) and
    (((dbeCorrCompany.Text > '') and (dbeCorrCompany.CurrentKey > '')) or
    (dbeCorrCompany.Text = '')) then
  begin
    UpdateAdditional;
    UpdateCorrAccount;
  end;
end;

procedure Tgdc_dlgCustomPayment.FormActivate(Sender: TObject);
begin
  inherited;
  FShowingForm := true;

  if gdcObject.State = dsInsert then
  begin
    edBank.Text := '';
    dbeCorrAccount.Condition := '';
    dbeCorrAccount.CurrentKey := '';

    dbeOper.Text := UserStorage.ReadString(Name, 'Oper', '');
    dbeOperKind.Text := UserStorage.ReadString(Name, 'OperKind', '');
    dbeQueue.Text := UserStorage.ReadString(Name, 'Queue', '');
    dbeTerm.Text := UserStorage.ReadString(Name, 'Term', '');
    dbeDest.CurrentKey := UserStorage.ReadString(Name, 'Dest', '');
  end
  else
  begin
    UpdateCorrAccount;
    UpdateAdditional;
    UpdateBankInfo;
  end;
end;

procedure Tgdc_dlgCustomPayment.FormShow(Sender: TObject);
begin
  inherited;
  if gdcObject.State = dsEdit then
    FgsTransaction.ReadTransactionOnPosition(GetTID(gdcObject.FieldByName('ID')),
     GetTID(gdcObject.FieldByName('ID')), -1);

end;

procedure Tgdc_dlgCustomPayment.FormCreate(Sender: TObject);
begin
  inherited;
  {$IFDEF DEPARTMENT}
    dbeCorrCompany.Condition := 'contacttype in (3, 5, 100, 101, 102, 103)';
  {$ENDIF}
end;

procedure Tgdc_dlgCustomPayment.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMPAYMENT', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMPAYMENT', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMPAYMENT',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FgsTransaction.DocumentOnly := True;
  FgsTransaction.CreateTransactionOnDataSet(-1,
    gdcObject.FieldByName('DOCUMENTDATE').AsDateTime, nil, nil, False, True);
  FgsTransaction.DocumentOnly := False;

  if Assigned(UserStorage) then
  begin
    UserStorage.WriteString(Name, 'Oper', dbeOper.Text);
    UserStorage.WriteString(Name, 'OperKind', dbeOperKind.Text);
    UserStorage.WriteString(Name, 'Queue', dbeQueue.Text);
    UserStorage.WriteString(Name, 'Term', dbeTerm.Text);
    UserStorage.WriteString(Name, 'Dest', dbeDest.CurrentKey);
  end;  
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMPAYMENT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMPAYMENT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomPayment.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMPAYMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMPAYMENT', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMPAYMENT',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with gdcObject do
  begin
    if cmbExpense.Visible then
      case cmbExpense.ItemIndex of
        0: FieldByName('EXPENSEACCOUNT').Value := 'P';
        1: FieldByName('EXPENSEACCOUNT').Value := 'B';
        2: FieldByName('EXPENSEACCOUNT').Value := 'O';
        else FieldByName('EXPENSEACCOUNT').Clear;
      end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMPAYMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMPAYMENT', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomPayment.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMPAYMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMPAYMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMPAYMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  gsTransactionComboBox.GTransaction := (gdcObject as TgdcBaseBank).gsTransaction;
  FgsTransaction := (gdcObject as TgdcBaseBank).gsTransaction;
  if Assigned(FgsTransaction) then
  begin
    FgsTransaction.AddConditionDataSet([(gdcObject as TgdcBaseBank)]);
    FgsTransaction.ReadTransactionOnPosition(GetTID((gdcObject as TgdcBaseBank).FieldByName('id')),
      -1, -1);
  end;

  inherited;

  gsibluOwnAccount.Condition := 'COMPANYKEY = ' + TID2S(IBLogin.CompanyKey);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMPAYMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMPAYMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomPayment.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMPAYMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMPAYMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMPAYMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if gdcObject.FieldByName('EXPENSEACCOUNT').AsString = 'P' then
    cmbExpense.ItemIndex := 0
  else
    if gdcObject.FieldByName('EXPENSEACCOUNT').AsString = 'B' then
      cmbExpense.ItemIndex := 1
    else
      if gdcObject.FieldByName('EXPENSEACCOUNT').AsString = 'O' then
        cmbExpense.ItemIndex := 2
      else
        cmbExpense.ItemIndex := -1;

  {$IFDEF DEPARTMENT}
    dbeCorrCompany.Condition := 'contacttype in (3, 5, 100, 101, 102, 103)';
  {$ENDIF}

  FShowingForm := True;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMPAYMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMPAYMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgCustomPayment);

finalization
  UnRegisterFrmClass(Tgdc_dlgCustomPayment);

end.
