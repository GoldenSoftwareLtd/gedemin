
unit gdc_dlgAdminConstValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Mask, DBCtrls, Db, ActnList,
  gdc_dlgConstValue_unit, gsIBLookupComboBox, xDateEdits, Menus,
  IBDatabase, at_Container, ComCtrls;

type
  Tgdc_dlgAdminConstValue = class(Tgdc_dlgConstValue)
    Label3: TLabel;
    Label21: TLabel;
    gsibUser: TgsIBLookupComboBox;
    gsIBCompany: TgsIBLookupComboBox;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgAdminConstValue: Tgdc_dlgAdminConstValue;

implementation

{$R *.DFM}

uses
  gdcConst, gd_ClassList;

{ Tgdc_dlgAdminConstValue }

procedure Tgdc_dlgAdminConstValue.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGADMINCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGADMINCONSTVALUE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGADMINCONSTVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGADMINCONSTVALUE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGADMINCONSTVALUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(gdcObject) then
  begin
    with gdcObject as TgdcConstValue do
    begin
      gsibUser.Visible := IsUser;
      Label21.Visible := IsUser;
      gsibCompany.Visible := IsCompany;
      Label3.Visible := IsCompany;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGADMINCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGADMINCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAdminConstValue);

finalization
  UnRegisterFrmClass(Tgdc_dlgAdminConstValue);

end.
