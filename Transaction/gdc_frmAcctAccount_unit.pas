
unit gdc_frmAcctAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcAcctAccount, IBCustomDataSet, gdcBase, IBDatabase, gdcTree,
  gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmAcctAccount = class(Tgdc_frmMDVTree)
    gdcAcctAccount: TgdcAcctAccount;
    IBTransaction: TIBTransaction;
    actNewChart: TAction;
    actNewFolder: TAction;
    actNewAccount: TAction;
    actNewSubAccount: TAction;
    TBSubmenuItem1: TTBSubmenuItem;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    actAddAnalize: TAction;
    TBItem6: TTBItem;
    gdcAcctChart: TgdcAcctBase;
    tbiAn: TTBItem;
    tbsepAn: TTBSeparatorItem;
    NSepAddAn: TMenuItem;
    NAddAn: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure actNewChartExecute(Sender: TObject);
    procedure actNewFolderExecute(Sender: TObject);
    procedure actNewAccountExecute(Sender: TObject);
    procedure actNewSubAccountExecute(Sender: TObject);
    procedure actNewSubAccountUpdate(Sender: TObject);
    procedure actAddAnalizeExecute(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actNewFolderUpdate(Sender: TObject);
    procedure actNewAccountUpdate(Sender: TObject);
    procedure actAddAnalizeUpdate(Sender: TObject);

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

procedure Tgdc_frmAcctAccount.actNewChartExecute(Sender: TObject);
begin
  gdcObject.CreateDialog(MakeFullClass(TgdcAcctChart, ''));
end;

procedure Tgdc_frmAcctAccount.actNewFolderExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  Obj := TgdcAcctFolder.Create(Self);
  try
    Obj.SubSet := 'ByID';
    Obj.Open;
    Obj.Insert;
    Obj.FieldByName('parent').AsInteger := gdcObject.ID;
    if Obj.CreateDialog then
    begin
      gdcObject.Close;
      gdcObject.Open;
      gdcObject.Locate('ID', Obj.ID, []);
    end;
    Obj.Close;
  finally
    Obj.Free;
  end;
end;

procedure Tgdc_frmAcctAccount.actNewAccountExecute(Sender: TObject);
begin
  gdcAcctAccount.Parent := gdcObject.ID;
  gdcDetailObject.CreateDialog(MakeFullClass(TgdcAcctAccount, ''));
end;

procedure Tgdc_frmAcctAccount.actNewSubAccountExecute(Sender: TObject);
begin
  gdcAcctAccount.Parent := gdcDetailObject.ID;
  gdcDetailObject.CreateDialog(TgdcAcctSubAccount);
end;

procedure Tgdc_frmAcctAccount.actNewSubAccountUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcDetailObject.Active
    and (not gdcDetailObject.IsEmpty)
    and gdcObject.Active
    and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('accounttype').AsString = 'F');
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

procedure Tgdc_frmAcctAccount.actDetailNewExecute(Sender: TObject);
begin
//  inherited;

end;

procedure Tgdc_frmAcctAccount.actNewFolderUpdate(Sender: TObject);
begin
  actNewFolder.Enabled := Assigned(gdcObject)
    and (not gdcObject.IsEmpty);
end;

procedure Tgdc_frmAcctAccount.actNewAccountUpdate(Sender: TObject);
begin
  actNewAccount.Enabled := gdcObject.Active
    and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('accounttype').AsString = 'F');
end;

procedure Tgdc_frmAcctAccount.actAddAnalizeUpdate(Sender: TObject);
begin
  actAddAnalize.Enabled := Assigned(IBLogin)
    and IBLogin.IsUserAdmin;
end;

initialization
  RegisterFRMClass(Tgdc_frmAcctAccount);

finalization
  UnRegisterFRMClass(Tgdc_frmAcctAccount);

end.
