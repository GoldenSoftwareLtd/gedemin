unit gdc_dlgAcctAccCard_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgBaseAcctConfig, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask,
  DBCtrls, gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gd_ClassList,
  gdv_frameSum_unit, ComCtrls, gdv_frameAnalyticValue_unit, AcctUtils,
  gdv_AcctConfig_unit, gsIBLookupComboBox, Storages, gsStorage_CompPath;

type
  TdlgAcctAccCardConfig = class(TdlgBaseAcctConfig)
    cbGroup: TCheckBox;
    gbCorrAccounts: TGroupBox;
    Label1: TLabel;
    cbCorrAccounts: TComboBox;
    Button2: TButton;
    cbCorrSubAccounts: TCheckBox;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
    actCorrAccounts: TAction;
    procedure actCorrAccountsExecute(Sender: TObject);
    procedure FormDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure cbCorrAccountsChange(Sender: TObject);
    procedure cbCorrSubAccountsClick(Sender: TObject);
  private
    { Private declarations }
    FCorrAccountIDs: TList;
  protected
    procedure UpdateControls; override;
    class function ConfigClassName: string; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
  public
    { Public declarations }
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  dlgAcctAccCardConfig: TdlgAcctAccCardConfig;

implementation

{$R *.DFM}
procedure TdlgAcctAccCardConfig.actCorrAccountsExecute(Sender: TObject);
begin
  if AccountDialog(cbCorrAccounts, 0) then
  begin
    if FCorrAccountIDs <> nil then
      FCorrAccountIDs.Clear;
    UpdateControls;
  end;
end;

procedure TdlgAcctAccCardConfig.FormDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  inherited;
  FCorrAccountIDs.Free;
end;

procedure TdlgAcctAccCardConfig.cbCorrAccountsChange(Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear

end;

procedure TdlgAcctAccCardConfig.cbCorrSubAccountsClick(Sender: TObject);
begin
  if FCorrAccountIDs <> nil then
    FCorrAccountIDs.Clear
end;

procedure TdlgAcctAccCardConfig.UpdateControls;
begin
  if FCorrAccountIDs = nil then
    FCorrAccountIDs := TList.Create;
  inherited;
  SetAccountIDs(cbCorrAccounts, FCorrAccountIDs, cbCorrSubAccounts.Checked);
end;

class function TdlgAcctAccCardConfig.ConfigClassName: string;
begin
  Result := 'TAccCardConfig';
end;

procedure TdlgAcctAccCardConfig.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
    with C do
    begin
      cbGroup.Checked := Group;
      cbCorrAccounts.Text := CorrAccounts;
      rbDebit.Checked := AccountPart = 'D';
      rbCredit.Checked := AccountPart <> 'D';
      cbCorrSubAccounts.Checked := IncCorrSubAccounts;
    end;
  end;
end;

procedure TdlgAcctAccCardConfig.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCardConfig;
begin
  inherited;
  if Config is TAccCardConfig then
  begin
    C := Config as TAccCardConfig;
    with C do
    begin
      Group := cbGroup.Checked;
      CorrAccounts := cbCorrAccounts.Text;
      if rbDebit.Checked then
        AccountPart := 'D'
      else
        AccountPart := 'C';
      IncCorrSubAccounts := cbCorrSubAccounts.Checked;
    end;
  end;
end;

procedure TdlgAcctAccCardConfig.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGACCTACCCARDCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGACCTACCCARDCONFIG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGACCTACCCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGACCTACCCARDCONFIG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGACCTACCCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    cbCorrAccounts.Items.Text := UserStorage.ReadString(ComponentPath, 'CorrAccountHistory', '');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGACCTACCCARDCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGACCTACCCARDCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgAcctAccCardConfig.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGACCTACCCARDCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGACCTACCCARDCONFIG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGACCTACCCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGACCTACCCARDCONFIG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGACCTACCCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    SaveHistory(cbCorrAccounts);
    UserStorage.WriteString(ComponentPath, 'CorrAccountHistory', cbCorrAccounts.Items.Text);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGACCTACCCARDCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGACCTACCCARDCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(TdlgAcctAccCardConfig);

finalization
  UnRegisterFrmClass(TdlgAcctAccCardConfig);

end.
