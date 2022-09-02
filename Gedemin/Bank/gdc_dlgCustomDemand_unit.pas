// ShlTanya, 30.01.2019

{
             01-11-2001  sai     Переделаны методы выбоки
}

unit gdc_dlgCustomDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, xCalculatorEdit, DBCtrls, Mask,
  xDateEdits, gsIBLookupComboBox, ExtCtrls, ComCtrls, IBSQL, gd_security_operationconst,
  gdcBase, gd_security, gd_security_body, gdcPayment,
  gdc_dlgCustomPayment_unit, at_Container, gsTransactionComboBox,
  IBCustomDataSet, gdcContacts, IBDatabase, gdcTree, Menus;

type
  Tgdc_dlgCustomDemand = class(Tgdc_dlgCustomPayment)
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
    procedure btnChooseSenderClick(Sender: TObject);
    procedure btnChooseReceiverClick(Sender: TObject);

  private
    procedure UpdateCargoSender;
    procedure UpdateCargoReceiver;

  protected
    procedure BeforePost; override;

  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgCustomDemand: Tgdc_dlgCustomDemand;

implementation

uses dmDataBase_unit,  gd_ClassList, gdcBaseInterface;

{$R *.DFM}
procedure Tgdc_dlgCustomDemand.dbeCorrCompanyChange(Sender: TObject);
begin
  inherited;
  if (gdcObject = nil) or (not (gdcObject.State in [dsInsert, dsEdit])) then exit;

  if  FShowingForm then
    UpdateCargoReceiver;
end;

procedure Tgdc_dlgCustomDemand.btnChooseSenderClick(Sender: TObject);
var
  OldSubSet: String;
  WasActive: Boolean;
  V: OleVariant;
begin
  if gdcCompany.ChooseItems(V, 'gdcContacts') then
  begin
    OldSubSet := gdcCompany.SubSet;
    WasActive := gdcCompany.Active;
    gdcCompany.SubSet := 'OnlySelected';
    gdcCompany.Open;
    gdcObject.FieldByName('CARGOSENDER').AsString :=
      gdcCompany.FieldByName(gdcCompany.GetListField(gdcCompany.SubType)).AsString;
    gdcCompany.SubSet := OldSubSet;
    gdcCompany.Active := WasActive;
  end;
end;

procedure Tgdc_dlgCustomDemand.btnChooseReceiverClick(Sender: TObject);
var
  OldSubSet: String;
  WasActive: Boolean;
  V: OleVariant;
begin
  if gdcCompany.ChooseItems(V, 'gdcContacts') then
  begin
    OldSubSet := gdcCompany.SubSet;
    WasActive := gdcCompany.Active;
    gdcCompany.SubSet := 'OnlySelected';
    gdcCompany.Open;
    gdcObject.FieldByName('CARGORECIEVER').AsString :=
      gdcCompany.FieldByName(gdcCompany.GetListField(gdcCompany.SubType)).AsString;
    gdcCompany.SubSet := OldSubSet;
    gdcCompany.Active := WasActive;
  end;
end;

procedure Tgdc_dlgCustomDemand.UpdateCargoSender;
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

procedure Tgdc_dlgCustomDemand.UpdateCargoReceiver;
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

procedure Tgdc_dlgCustomDemand.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMDEMAND', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMDEMAND', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMDEMAND') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMDEMAND',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMDEMAND' then
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
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMDEMAND', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMDEMAND', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomDemand.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMDEMAND', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMDEMAND', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMDEMAND') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMDEMAND',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMDEMAND' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UpdateCargoSender;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMDEMAND', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMDEMAND', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomDemand.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMDEMAND', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMDEMAND', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMDEMAND') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMDEMAND',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMDEMAND' then
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

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMDEMAND', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMDEMAND', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgCustomDemand);

finalization
  UnRegisterFrmClass(Tgdc_dlgCustomDemand);

end.
