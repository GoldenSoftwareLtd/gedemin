// ShlTanya, 24.02.2019

unit gdc_dlgConst_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, Db, ActnList, Menus,
  gdc_dlgG_unit, IBDatabase, at_Container, ComCtrls, ExtCtrls;

type
  Tgdc_dlgConst = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    Label2: TLabel;
    dbeName: TDBEdit;
    dbeComment: TDBEdit;
    cbisPeriod: TCheckBox;
    cbisUser: TCheckBox;
    cbisCompany: TCheckBox;
    rgDataType: TRadioGroup;
    Label3: TLabel;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgConst: Tgdc_dlgConst;

implementation

{$R *.DFM}

uses
  gdcConst, gd_ClassList;

procedure Tgdc_dlgConst.BeforePost;

  function GetB(Ch: TCheckBox): Integer;
  begin
    case Ch.Checked of
      True: Result := 1;
    else Result := 0;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCONST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCONST', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCONST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCONST',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCONST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcObject.FieldByName('consttype').AsInteger :=
    GetB(cbisPeriod) or (GetB(cbisUser) shl 1) or (GetB(cbisCompany) shl 2);

  if rgDataType.Enabled then
  begin
    with gdcObject.FieldByName('datatype') do
    case rgDataType.ItemIndex of
      1: AsString := 'N';
      2: AsString := 'D';
    else
      AsString := 'S';
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCONST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCONST', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgConst.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCONST', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCONST', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCONST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCONST',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCONST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(gdcObject) then
  begin
    with gdcObject as TgdcConst do
    begin
      cbisPeriod.Checked := IsPeriod;
      cbisUser.Checked := IsUser;
      cbisCompany.Checked := IsCompany;
    end;

    if gdcObject.State = dsEdit then
    begin
      cbisPeriod.Enabled := False;
      cbisUser.Enabled := False;
      cbisCompany.Enabled := False;
    end
    else
    begin
      cbisPeriod.Enabled := True;
      cbisUser.Enabled := True;
      cbisCompany.Enabled := True;
    end;

    if (gdcObject.State <> dsEdit)
      and (gdcObject.FindField('datatype') <> nil) then
    begin
      rgDataType.Enabled := True;
    end else
      rgDataType.Enabled := False;
      
    if gdcObject.FieldByName('datatype').AsString = 'N' then
      rgDataType.ItemIndex := 1
    else if gdcObject.FieldByName('datatype').AsString = 'D' then
      rgDataType.ItemIndex := 2
    else
      rgDataType.ItemIndex := 0;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCONST', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCONST', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgConst);

finalization
  UnRegisterFrmClass(Tgdc_dlgConst);
end.
