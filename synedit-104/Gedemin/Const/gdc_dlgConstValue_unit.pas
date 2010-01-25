
unit gdc_dlgConstValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, Db, ActnList, xDateEdits, Menus,
  gdc_dlgG_unit, IBDatabase, at_Container, ComCtrls;

type
  Tgdc_dlgConstValue = class(Tgdc_dlgTRPC)
    Label2: TLabel;
    xdbConstDate: TxDateDBEdit;
    Label1: TLabel;
    dbeValue: TDBEdit;
    Memo1: TMemo;
    Label4: TLabel;
    DBText1: TDBText;

  public
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgConstValue: Tgdc_dlgConstValue;

implementation

uses
  gd_ClassList, gdcConst;

{$R *.DFM}

{ Tgdc_dlgConstValue }

procedure Tgdc_dlgConstValue.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCONSTVALUE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCONSTVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCONSTVALUE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCONSTVALUE' then
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
      xdbConstDate.Visible := IsPeriod;
      Label2.Visible := IsPeriod;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCONSTVALUE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgConstValue.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGCONSTVALUE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGCONSTVALUE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCONSTVALUE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCONSTVALUE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCONSTVALUE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result and (gdcObject.FieldByName('constvalue').AsString > '') then
  begin
    if gdcObject.FieldByName('datatype').AsString = 'D' then
    begin
      S := Trim(gdcObject.FieldByName('constvalue').AsString);
      for I := 1 to Length(S) do
      begin
        if not (S[I] in ['0'..'9', '.']) then
          S[I] := '.';
      end;
      if gdcObject.FieldByName('constvalue').AsString <> S then
        gdcObject.FieldByName('constvalue').AsString := S;
      TgdcConst.StringToDate(gdcObject.FieldByName('constvalue').AsString);
    end
    else if gdcObject.FieldByName('datatype').AsString = 'N' then
    begin
      S := Trim(gdcObject.FieldByName('constvalue').AsString);
      for I := 1 to Length(S) do
      begin
        if not (S[I] in ['0'..'9', '-', '+', 'e', 'E', '.']) then
          S[I] := '.';
      end;
      if gdcObject.FieldByName('constvalue').AsString <> S then
        gdcObject.FieldByName('constvalue').AsString := S;
      TgdcConst.StringToFloat(gdcObject.FieldByName('constvalue').AsString);
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCONSTVALUE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCONSTVALUE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgConstValue);

finalization
  UnRegisterFrmClass(Tgdc_dlgConstValue);

end.
