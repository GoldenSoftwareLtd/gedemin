unit gdc_dlgAcctCirculationList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgBaseAcctConfig, IBDatabase, Menus, Db, ActnList,
  gdv_frameAnalyticValue_unit, DBCtrls, gsIBLookupComboBox, StdCtrls, Mask,
  gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gdv_frameSum_unit,
  ComCtrls, gdv_AcctConfig_unit;

type
  TdlgAcctCirculationList = class(TdlgBaseAcctConfig)
    cbShowCredit: TCheckBox;
    cbShowDebit: TCheckBox;
    cbShowCorrSubAccounts: TCheckBox;
    cbSubAccountsInMain: TCheckBox;
    cbDisplaceSaldo: TCheckBox;
    cbOnlyAccounts: TCheckBox;
    procedure cbSubAccountsInMainClick(Sender: TObject);
  private
    { Private declarations }
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
  dlgAcctCirculationList: TdlgAcctCirculationList;

implementation
uses gd_ClassList;
{$R *.DFM}

{ TdlgAcctCirculationList }

class function TdlgAcctCirculationList.ConfigClassName: string;
begin
  Result := 'TAccCirculationListConfig'
end;

class function TdlgAcctCirculationList.DefFolderKey: Integer;
begin
  Result := inherited DefFolderKey;
end;

class function TdlgAcctCirculationList.DefImageIndex: Integer;
begin
  Result := inherited DefImageIndex
end;

procedure TdlgAcctCirculationList.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;
  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    cbShowDebit.Checked := C.ShowDebit;
    cbShowCredit.Checked := C.ShowCredit;
    cbShowCorrSubAccounts.Checked := C.ShowCorrSubAccounts;
    cbDisplaceSaldo.Checked := C.DisplaceSaldo;
    cbSubAccountsInMain.Checked := C.SubAccountsInMain;
    cbOnlyAccounts.Checked := C.OnlyAccounts;
  end;
end;

procedure TdlgAcctCirculationList.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;
  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    C.ShowDebit := cbShowDebit.Checked;
    C.ShowCredit := cbShowCredit.Checked;
    C.ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
    C.SubAccountsInMain := cbSubAccountsInMain.Checked;
    C.DisplaceSaldo := cbDisplaceSaldo.Checked;
    C.OnlyAccounts := cbOnlyAccounts.Checked;
  end;
end;

procedure TdlgAcctCirculationList.cbSubAccountsInMainClick(
  Sender: TObject);
begin
  cbDisplaceSaldo.Enabled:= cbSubAccountsInMain.Checked;
end;

initialization
  RegisterFrmClass(TdlgAcctCirculationList);
finalization
  UnRegisterFrmClass(TdlgAcctCirculationList);
end.
