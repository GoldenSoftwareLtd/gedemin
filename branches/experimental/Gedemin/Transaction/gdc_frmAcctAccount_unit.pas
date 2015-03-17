
unit gdc_frmAcctAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcAcctAccount, IBCustomDataSet, gdcBase, IBDatabase, gdcTree,
  gd_MacrosMenu, StdCtrls, Contnrs;

type
  Tgdc_frmAcctAccount = class(Tgdc_frmMDVTree)
    gdcAcctAccount: TgdcAcctAccount;
    IBTransaction: TIBTransaction;
    actAddAnalize: TAction;
    TBItem6: TTBItem;
    gdcAcctChart: TgdcAcctBase;
    tbiAn: TTBItem;
    tbsepAn: TTBSeparatorItem;
    NSepAddAn: TMenuItem;
    NAddAn: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actAddAnalizeExecute(Sender: TObject);
    procedure actAddAnalizeUpdate(Sender: TObject);
    procedure actDetailNewUpdate(Sender: TObject);

  public
    procedure SetChoose(AnObject: TgdcBase); override;
  end;

var
  gdc_frmAcctAccount: Tgdc_frmAcctAccount;

implementation

{$R *.DFM}

uses
  gdc_acct_dlgAnalysis_unit, gd_ClassList, gd_security;

procedure Tgdc_frmAcctAccount.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAcctChart;
  gdcDetailObject := gdcAcctAccount;
  inherited;

  if gdcObject.Active and gdcObject.IsEmpty then
  begin
    MessageBox(Handle,
      'ƒл€ текущей организации не выбран активный план счетов.'#13#10 +
      '¬оспользуйтесь диалоговым окном редактировани€ свойств'#13#10 +
      'организации дл€ его установки.',
      '¬нимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

procedure Tgdc_frmAcctAccount.actAddAnalizeExecute(Sender: TObject);
begin
  with Tgdc_acct_dlgAnalysis.Create(Self) do
    try
      Setup(gdcDetailObject);
      ShowModal;
    finally
      Free;
    end;

end;

procedure Tgdc_frmAcctAccount.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMACCTACCOUNT', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMACCTACCOUNT', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMACCTACCOUNT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMACCTACCOUNT',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMACCTACCOUNT' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  gdcAcctChart.SubSet := 'All';
  gdcAcctChart.Open;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMACCTACCOUNT', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMACCTACCOUNT', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmAcctAccount.actAddAnalizeUpdate(Sender: TObject);
begin
  actAddAnalize.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin;
end;

procedure Tgdc_frmAcctAccount.actDetailNewUpdate(Sender: TObject);
begin
  inherited;

  if actDetailNew.Enabled then
    actDetailNew.Enabled := gdcObject.Active
      and (not gdcObject.IsEmpty)
      and (gdcObject.FieldByName('accounttype').AsString = 'F');
end;

initialization
  RegisterFRMClass(Tgdc_frmAcctAccount);

finalization
  UnRegisterFRMClass(Tgdc_frmAcctAccount);

end.
