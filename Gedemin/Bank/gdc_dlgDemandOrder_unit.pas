// ShlTanya, 30.01.2019

unit gdc_dlgDemandOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, xCalculatorEdit, DBCtrls, Mask,
  xDateEdits, gsIBLookupComboBox, ExtCtrls, ComCtrls, IBSQL, gd_security_operationconst,
  gdcBase, gd_security, gd_security_body, gdcPayment,
  gdc_dlgCustomPayment_unit, at_Container, gsTransactionComboBox,
  IBCustomDataSet, gdcContacts, gdcTree, IBDatabase, Menus;

type
  Tgdc_dlgDemandOrder = class(Tgdc_dlgCustomPayment)
    lblAccept: TLabel;
    Label9: TLabel;
    cmbAccept: TComboBox;
    Bevel2: TBevel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    dbeContract: TDBEdit;
    dbePaper: TDBEdit;
    dbeCargoSendDate: TxDateDBEdit;
    dbePaperSendDate: TxDateDBEdit;
    cbCargoSender: TDBComboBox;
    cbCargoReceiver: TDBComboBox;
    btnChooseSender: TButton;
    btnChooseReceiver: TButton;
    Label24: TLabel;
    dbePercent: TDBEdit;
    gdcCompany: TgdcCompany;
    procedure dbeCorrCompanyChange(Sender: TObject);

  private
    procedure UpdateCargoSender;
    procedure UpdateCargoReceiver;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgDemandOrder: Tgdc_dlgDemandOrder;

implementation

uses dmDataBase_unit,  gd_ClassList, gdcBaseInterface;

{$R *.DFM}

procedure Tgdc_dlgDemandOrder.dbeCorrCompanyChange(Sender: TObject);
begin
  inherited;
  if (gdcObject = nil) or (not (gdcObject.State in [dsInsert, dsEdit])) then exit;

  if  FShowingForm then
    UpdateCargoReceiver;
end;

procedure Tgdc_dlgDemandOrder.UpdateCargoSender;
var
  CName: String;
begin
  CName := gdcCompany.GetListNameByID(IBLogin.CompanyKey);

  with cbCargoSender.Items do
  begin
    if Count > 1 then
      Strings[Count - 1] := CName
    else
      Add(CName);
  end;
end;

procedure Tgdc_dlgDemandOrder.UpdateCargoReceiver;
var
  CName: String;
begin
  CName := gdcCompany.GetListNameByID(GetTID(gdcObject.FieldByName('CORRCOMPANYKEY')));

  with cbCargoSender.Items do
  begin
    if Count > 1 then
      Strings[Count - 1] := CName
    else
      Add(CName);
  end;
end;

procedure Tgdc_dlgDemandOrder.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEMANDORDER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEMANDORDER', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEMANDORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEMANDORDER',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEMANDORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with gdcObject do
    if cmbAccept.Visible then
      case cmbAccept.ItemIndex of
        -1: FieldByName('WITHACCEPT').Clear;
        else FieldByName('WITHACCEPT').AsInteger :=
          cmbAccept.ItemIndex;
      end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEMANDORDER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEMANDORDER', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDemandOrder.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEMANDORDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEMANDORDER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEMANDORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEMANDORDER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEMANDORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  with gdcObject do
  begin
    if FieldByName('WITHACCEPT').IsNull then
      cmbAccept.ItemIndex := -1
    else
      cmbAccept.ItemIndex :=
        FieldByName('WITHACCEPT').AsInteger;
  end;

  if gdcObject.State <> dsInsert then
    UpdateCargoReceiver;

  UpdateCargoSender;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEMANDORDER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEMANDORDER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgDemandOrder);

finalization
  UnRegisterFrmClass(Tgdc_dlgDemandOrder);

end.
