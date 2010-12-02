unit gdc_dlgAutoTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, StdCtrls, DBCtrls, Mask, IBDatabase, Menus, Db, ActnList,
  ExtCtrls, gd_ClassList, gsIBLookupComboBox;

type
  Tgdc_dlgAutoTransaction = class(Tgdc_dlgTR)
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbmDescription: TDBMemo;
    Bevel1: TBevel;
    iblcParent: TgsIBLookupComboBox;
    Label3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgAutoTransaction = class(Exception);
var
  gdc_dlgAutoTransaction: Tgdc_dlgAutoTransaction;

implementation

{$R *.DFM}

{ Tgdc_dlgAutoTransaction }

function Tgdc_dlgAutoTransaction.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGAUTOTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGAUTOTRANSACTION', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTRANSACTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTRANSACTION',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTRANSACTION' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;

  if gdcObject.FieldByName('NAME').AsString = '' then
  begin
    ModalResult := mrNone;
    gdcObject.FieldByName('NAME').FocusControl;
    raise Egdc_dlgAutoTransaction.Create('”кажите наименование автоматической операции!');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTransaction);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTransaction);

end.
