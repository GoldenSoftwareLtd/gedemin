// ShlTanya, 12.03.2019

{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgTaxName_unit.pas

  Abstract

    Dialog form of TgdcTaxName business class.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit gdc_dlgTaxName_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Mask, DBCtrls, Menus, Db, ActnList, ExtCtrls,
  IBDatabase, gsIBLookupComboBox, dmDataBase_unit, tax_Strings_unit;

type
  Tgdc_dlgTaxName = class(Tgdc_dlgG)
    Panel1: TPanel;
    lblTaxName: TLabel;
    dbeTaxName: TDBEdit;
    Bevel1: TBevel;
    lAutoTransaction: TLabel;
    iblAutoTransaction: TgsIBLookupComboBox;
    IBTransaction: TIBTransaction;
    Label3: TLabel;
    iblcAccountChart: TgsIBLookupComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  protected  
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  public
    { Public declarations }
  end;

var
  gdc_dlgTaxName: Tgdc_dlgTaxName;

implementation

uses
  gd_ClassList, gd_security, gdcConstants, gdcBaseInterface;

{$R *.DFM}

procedure Tgdc_dlgTaxName.FormCreate(Sender: TObject);
begin
  inherited;
  IBTransaction.DefaultDatabase := dmDataBase.ibdbGAdmin
end;

procedure Tgdc_dlgTaxName.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXNAME', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXNAME', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXNAME') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXNAME',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXNAME' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if (gdcObject.State = dsInsert) then
  begin
    SetTID(gdcObject.FieldByName(fnAccountKey), ibLogin.ActiveAccount);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXNAME', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXNAME', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTaxName.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGTAXNAME', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTAXNAME', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXNAME') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXNAME',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXNAME' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result then
  begin
    if GetTID(gdcObject.FieldByName(fnAccountKey)) = 0 then
    begin
      Result := False;
      ShowMessage(MSG_INDICATE_ACCOUNTCARD);
      Exit;
    end;

    if GetTID(gdcObject.FieldByName(fnTransactionKey)) = 0 then
    begin
      Result := False;
      ShowMessage(MSG_INDICATE_TRANSACTION);
      Exit;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXNAME', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXNAME', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgTaxName);

finalization
  UnRegisterFrmClass(Tgdc_dlgTaxName);

end.
