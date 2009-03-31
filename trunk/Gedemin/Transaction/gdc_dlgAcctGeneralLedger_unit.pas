unit gdc_dlgAcctGeneralLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgBaseAcctConfig, IBDatabase, Menus, Db, ActnList,
  gdv_frameAnalyticValue_unit, DBCtrls, gsIBLookupComboBox, StdCtrls, Mask,
  gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gdv_frameSum_unit,
  ComCtrls, gdv_AcctConfig_unit, gd_ClassList;

type
  TdlgAcctGeneralLedger = class(TdlgBaseAcctConfig)
    cbShowDebit: TCheckBox;
    cbShowCorrSubAccounts: TCheckBox;
    cbShowCredit: TCheckBox;
  private
  protected
    class function ConfigClassName: string; override;
    class function DefImageIndex: Integer; override;
    class function DefFolderKey: Integer; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig); override;
    procedure DoSaveConfig(Config: TBaseAcctConfig); override;
  public
    { Public declarations }
  end;

var
  dlgAcctGeneralLedger: TdlgAcctGeneralLedger;

implementation

{$R *.DFM}
{ TdlgAcctGeneralLedger }

class function TdlgAcctGeneralLedger.ConfigClassName: string;
begin
  Result := 'TAccGeneralLedgerConfig'
end;

class function TdlgAcctGeneralLedger.DefFolderKey: Integer;
begin
  Result := inherited DefFolderKey;
end;

class function TdlgAcctGeneralLedger.DefImageIndex: Integer;
begin
  Result := inherited DefImageIndex
end;

procedure TdlgAcctGeneralLedger.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  if Config is TAccGeneralLedgerConfig then
  begin
    C := Config as TAccGeneralLedgerConfig;
    cbShowDebit.Checked := C.ShowDebit;
    cbShowCredit.Checked := C.ShowCredit;
    cbShowCorrSubAccounts.Checked := C.ShowCorrSubAccounts;
  end;
end;

procedure TdlgAcctGeneralLedger.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  if Config is TAccGeneralLedgerConfig then
  begin
    C := Config as TAccGeneralLedgerConfig;
    C.ShowDebit := cbShowDebit.Checked;
    C.ShowCredit := cbShowCredit.Checked;
    C.ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
  end;
end;

initialization
  RegisterFrmClass(TdlgAcctGeneralLedger);
finalization
  UnRegisterFrmClass(TdlgAcctGeneralLedger);

end.
