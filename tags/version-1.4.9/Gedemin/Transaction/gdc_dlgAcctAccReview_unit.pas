unit gdc_dlgAcctAccReview_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgBaseAcctConfig, StdCtrls, IBDatabase, Menus, Db, ActnList,
  gdv_frameAnalyticValue_unit, DBCtrls, gsIBLookupComboBox, Mask,
  gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gdv_frameSum_unit,
  ComCtrls, AcctUtils, gdv_AcctConfig_unit, Storages, gsStorage_CompPath, gd_ClassList;

type
  TdlgAcctAccReviewConfig = class(TdlgBaseAcctConfig)
    cbShowCorrSubAccounts: TCheckBox;
    gbCorrAccounts: TGroupBox;
    Label1: TLabel;
    cbCorrAccounts: TComboBox;
    btnCorrAccounts: TButton;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
    procedure btnCorrAccountsClick(Sender: TObject);
    procedure FormDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure cbCorrAccountsChange(Sender: TObject);
  private
    FCorrAccountIDs: TList;
  protected
    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
    procedure UpdateControls; override;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  dlgAcctAccReviewConfig: TdlgAcctAccReviewConfig;

implementation

{$R *.DFM}

{ TdlgAcctAccReciewConfig }

class function TdlgAcctAccReviewConfig.ConfigClassName: string;
begin
  Result := 'TAccReviewConfig';
end;

procedure TdlgAcctAccReviewConfig.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGACCTACCREVIEWCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGACCTACCREVIEWCONFIG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGACCTACCREVIEWCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGACCTACCREVIEWCONFIG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGACCTACCREVIEWCONFIG' then
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
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGACCTACCREVIEWCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGACCTACCREVIEWCONFIG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgAcctAccReviewConfig.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGACCTACCREVIEWCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGACCTACCREVIEWCONFIG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGACCTACCREVIEWCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGACCTACCREVIEWCONFIG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGACCTACCREVIEWCONFIG' then
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

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGACCTACCREVIEWCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGACCTACCREVIEWCONFIG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgAcctAccReviewConfig.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    with C do
    begin
      cbShowCorrSubAccounts.Checked := ShowCorrSubAccounts;
      cbCorrAccounts.Text := CorrAccounts;
      rbDebit.Checked := AccountPart = 'D';
      rbCredit.Checked := AccountPart <> 'D';
    end;
  end;
end;

procedure TdlgAcctAccReviewConfig.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccReviewConfig;
begin
  inherited;
  if Config is TAccReviewConfig then
  begin
    C := Config as TAccReviewConfig;
    with C do
    begin
      ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
      CorrAccounts := cbCorrAccounts.Text;
      if rbDebit.Checked then
        AccountPart := 'D'
      else
        AccountPart := 'C';
    end;
  end;
end;

procedure TdlgAcctAccReviewConfig.UpdateControls;
begin
  if not Assigned(FCorrAccountIDs) then
    FCorrAccountIDs := TList.Create;
  inherited;
  SetAccountIDs(cbCorrAccounts, FCorrAccountIDs, cbShowCorrSubAccounts.Checked);
end;

procedure TdlgAcctAccReviewConfig.btnCorrAccountsClick(Sender: TObject);
begin
  if AccountDialog(cbCorrAccounts, 0) then
  begin
    if Assigned(FCorrAccountIDs) then
      FCorrAccountIDs.Clear;
    UpdateControls;
  end;
end;

procedure TdlgAcctAccReviewConfig.FormDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  if Assigned(FCorrAccountIDs) then
    FCorrAccountIDs.Clear;
end;

procedure TdlgAcctAccReviewConfig.cbCorrAccountsChange(Sender: TObject);
begin
  if Assigned(FCorrAccountIDs) then
    FCorrAccountIDs.Clear;
  UpdateControls;
end;

initialization
  RegisterFrmClass(TdlgAcctAccReviewConfig);

finalization
  UnRegisterFrmClass(TdlgAcctAccReviewConfig);

end.
