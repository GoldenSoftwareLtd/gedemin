// ShlTanya, 10.02.2019

unit gdcGeneralLedger;

interface

uses
  Classes, gdcBase, gdcBaseInterface, gd_createable_form, sysutils;

type
  TgdcGeneralLedger = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gdc_dlgAcctGeneralLedger_unit, gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcGeneralLedger]);
end;

class function TgdcGeneralLedger.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcGeneralLedger.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AC_GENERALLEDGER';
end;

initialization
  RegisterGdcClass(TgdcGeneralLedger);

finalization
  UnregisterGdcClass(TgdcGeneralLedger);
end.

