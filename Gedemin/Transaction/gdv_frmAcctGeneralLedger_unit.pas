// ShlTanya, 09.03.2019, #4135

unit gdv_frmAcctGeneralLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmG_unit, flt_sqlFilter, gd_ReportMenu, Menus, gd_MacrosMenu,
  ActnList, Db, StdCtrls, Mask, xDateEdits, Buttons, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls,
  gsDBTreeView, IBCustomDataSet, gdcBase, gdcContacts, gd_ClassList,
  gdcTree, gdcAcctAccount, gd_security, contnrs, gdv_AcctConfig_unit,
  IBSQL, gdcBaseInterface, at_classes, gsIBLookupComboBox, IBDatabase,
  Storages, gsStorage, DBClient, AcctUtils,
  gdv_frAcctTreeAnalytic_unit, gdv_frAcctBaseAnalyticGroup,
  gdv_frAcctAnalyticsGroup_unit, gdvParamPanel, gdv_frAcctCompany_unit,
  gdv_frAcctAnalytics_unit, gdv_frAcctSum_unit, gdv_frAcctQuantity_unit,
  gdcConstants, AcctStrings, gdv_frmAcctBaseForm_unit, DsgnIntf, gdvAcctBase,
  gdvAcctGeneralLedger, gdvAcctLedger, gsPeriodEdit;

type
  Tgdv_frmGeneralLedger = class(Tgdv_frmAcctBaseForm)
    cbShowDebit: TCheckBox;
    cbShowCredit: TCheckBox;
    cbShowCorrSubAccount: TCheckBox;
    cbEnchancedSaldo: TCheckBox;
    
    pCardOfAccount: TPanel;
    lCardOfaccount: TLabel;
    ptvGroup: TPanel;
    tvGroup: TgsDBTreeView;
    gdcAcctChart: TgdcAcctBase;
    dsAcctChart: TDataSource;
    cbAutoBuildReport: TCheckBox;
    chkBuildGroup: TCheckBox;
    ibdsMain: TgdvAcctGeneralLedger;
    N1: TMenuItem;
    actGotoLedger: TAction;
    procedure FormCreate(Sender: TObject);
    procedure tvGroupChange(Sender: TObject; Node: TTreeNode);
    procedure frAcctCompanyiblCompanyChange(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure iblConfiguratiorChange(Sender: TObject);
    procedure chkBuildGroupClick(Sender: TObject);
    procedure actGotoLedgerExecute(Sender: TObject);
    procedure actGotoLedgerUpdate(Sender: TObject);
  protected
    function GetGdvObject: TgdvAcctBase; override;
    procedure SetParams; override;

    procedure InitColumns; override;
    procedure UpdateControls; override;
    procedure SetAcctChartExtraConditions;
    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
    procedure Go_to(NewWindow: Boolean = false); override;
    function CompareParams(WithDate: Boolean = True): boolean; override;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
    procedure BuildAcctReport; override;
  end;

var
  gdv_frmGeneralLedger: Tgdv_frmGeneralLedger;

implementation

uses
  gsStorage_CompPath, gdv_frmAcctAccCard_unit, gd_createable_form,
  gd_KeyAssoc, gd_common_functions, gdv_frmAcctLedger_unit, JclDateTime;
  
const
  cAutoBuildReport = 'AutoBuildReport';

{$R *.DFM}

procedure Tgdv_frmGeneralLedger.FormCreate(Sender: TObject);
begin
  gdcAcctChart.SubSet := 'All';
  SetAcctChartExtraConditions;
  gdcAcctChart.Open;

  inherited;
end;

procedure Tgdv_frmGeneralLedger.tvGroupChange(Sender: TObject;
  Node: TTreeNode);
begin
  UpdateControls;
  if cbAutoBuildReport.Checked then
    actRun.Execute;
end;

const
  cLastLedger = 'LastConfiguration';

procedure Tgdv_frmGeneralLedger.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS()}
{M}var
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMGENERALLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMGENERALLEDGER', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMGENERALLEDGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMGENERALLEDGER',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMGENERALLEDGER' then
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
    cbAutoBuildReport.Checked := UserStorage.ReadBoolean(ComponentPath, cAutoBuildReport, False);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMGENERALLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMGENERALLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmGeneralLedger.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS()}
{M}var
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMGENERALLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMGENERALLEDGER', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMGENERALLEDGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMGENERALLEDGER',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMGENERALLEDGER' then
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
    UserStorage.WriteBoolean(ComponentPath, cAutoBuildReport, cbAutoBuildReport.Checked);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMGENERALLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMGENERALLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmGeneralLedger.BuildAcctReport;
begin
  if (not ibdsMain.MakeEmpty)
    and ((FAccountIDs = nil) or (FAccountIDs.Count = 0)) then
  begin
    MessageBox(Handle,
      '�������� ����',
      '��������',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end else
    inherited;
end;

procedure Tgdv_frmGeneralLedger.UpdateControls;
var
  SQL: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  if tvGroup.Selected <> nil then
  begin
    //��������� � ������ ����� � �������� ���������� �����
    if FAccountIDs = nil then
      FAccountIDs := TList.Create;

    FAccountIDs.Clear;
    if (iblConfiguratior.CurrentKey > '') and (cbAccounts.Text > '') then
    begin
      SetAccountIDs(cbAccounts, FAccountIDs, cbShowCorrSubAccount.Checked, Name, False);
      if FAccountIDs.Count > 1 then
      begin
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := gdcBaseManager.ReadTransaction;
          SQL.SQL.Text := Format(
            ' SELECT a.id, a.parent, a.accounttype FROM ac_account a WHERE a.id in(%s) and ' +
            ' a.accounttype in (''A'', ''S'') ORDER BY a.accounttype',
            [IDList(FAccountIDs, Name)]);
          SQL.ExecQuery;
          if not SQL.Eof then
          begin
            FAccountIDs.Clear;
            if SQL.FieldByName('accounttype').AsString = 'A' then
              FAccountIDs.Add(TID2Pointer(GetTID(SQL.FieldByName('id')), Name))
            else
              FAccountIDs.Add(TID2Pointer(GetTID(SQL.FieldByName('parent')), Name));
          end; 
        finally
          SQL.Free;
        end;  
      end;
    end else
    begin
      if (gdcAcctChart.FieldByName('accounttype').AsString = 'A')
        or (gdcAcctChart.FieldByName('accounttype').AsString = 'S')
        or chkBuildGroup.Checked then
      begin
        FAccountIDs.Add(TID2Pointer(GetTID(gdcAcctChart.FieldByName('id')), Name));
        cbAccounts.Text := gdcAcctChart.FieldByName('alias').AsString;
      end;
    end;

    //��������� �������������� ����������
    frAcctQuantity.UpdateQuantityList(FAccountIDs);
    // ����������� �������� �������������� ����
    frAcctSum.SetQuantityVisible(frAcctQuantity.ValueCount > 0);

    ScrollBox.Realign;
  end;
end;

procedure Tgdv_frmGeneralLedger.frAcctCompanyiblCompanyChange(
  Sender: TObject);
begin
  inherited;
  gdcAcctChart.Close;
  SetAcctChartExtraConditions;
  gdcAcctChart.Open;
end;

procedure Tgdv_frmGeneralLedger.SetAcctChartExtraConditions;
var
  s: string;
  q: TIBSQL;
begin
  gdcAcctChart.ExtraConditions.Text :=
    Format(' exists (SELECT lb FROM ac_account c1 JOIN ac_companyaccount cc ' +
    '  ON c1.ID = cc.accountkey  ' +
    '  WHERE z.LB >= c1.lb AND z.rb <= c1.rb AND cc.companykey IN (%s) AND z.id <> 300003 ) ',
    [frAcctCompany.CompanyList]);
  if cbAccounts.Text <> '' then
    SetAccountIDs(cbAccounts, FAccountIDs, cbShowCorrSubAccount.Checked, Name, False);
  if Assigned(FAccountIDs) and (FAccountIDs.Count > 0) then begin
    Delete(s, 1, 2);
    q:= TIBSQL.Create(nil);
    try
      q.Transaction:= gdcBaseManager.ReadTransaction;
      q.SQL.Text:= 'SELECT lb, rb FROM ac_account WHERE id IN ' +
        '(' + IDList(FAccountIDs, Name) + ')';
      q.ExecQuery;
      s:= '';
      while not q.Eof do
      begin
        s:= s + ' OR (z.lb <= ' + q.FieldByName('lb').AsString + ' AND z.rb >= ' + q.FieldByName('rb').AsString + ')';
        q.Next;
      end;
    finally
      q.Free;
    end;
    Delete(s, 1, 3);

    gdcAcctChart.ExtraConditions.Add(s);
  end;
end;

procedure Tgdv_frmGeneralLedger.actRunUpdate(Sender: TObject);
begin
  inherited;

  TAction(Sender).Enabled := True;
  FMakeEmpty := (FAccountIDs = nil) or (FAccountIDs.Count = 0)
end;

class function Tgdv_frmGeneralLedger.ConfigClassName: string;
begin
  Result := 'TAccGeneralLedgerConfig'
end;

procedure Tgdv_frmGeneralLedger.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  //if Config is TAccGeneralLedgerConfig then
  //begin
    C := Config as TAccGeneralLedgerConfig;
    cbShowDebit.Checked := C.ShowDebit;
    cbShowCredit.Checked := C.ShowCredit;
    cbShowCorrSubAccount.Checked := C.ShowCorrSubAccounts;
    gdcAcctChart.Close;
    SetAcctChartExtraConditions;
    gdcAcctChart.Open;
  //end;
end;

procedure Tgdv_frmGeneralLedger.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccGeneralLedgerConfig;
begin
  inherited;
  if Config is TAccGeneralLedgerConfig then
  begin
    C := Config as TAccGeneralLedgerConfig;
    C.ShowDebit := cbShowDebit.Checked;
    C.ShowCredit := cbShowCredit.Checked;
    C.ShowCorrSubAccounts := cbShowCorrSubAccount.Checked;
  end;
end;

procedure Tgdv_frmGeneralLedger.Go_to(NewWindow: Boolean);
var
  F: TField;
  C: TAccCardConfig;
  FI: TgdvFieldInfo;
  Form: TCreateableForm;
begin
  Form := gd_createable_form.FindForm(Tgdv_frmAcctAccCard);

  F := ibgrMain.SelectedField;
  if F <> nil then
  begin
    C := TAccCardConfig.Create;
    try
      DoSaveConfig(C);
      if (iblConfiguratior.CurrentKeyInt > -1) and (cbAccounts.Text > '') then
        C.Accounts := cbAccounts.Text
      else
        C.Accounts := gdcAcctChart.FieldByName('alias').AsString;

      C.CompanyKey := frAcctCompany.iblCompany.CurrentKeyInt;
      C.AllHoldingCompanies := frAcctCompany.cbAllCompanies.Checked;

      C.IncCorrSubAccounts := False;
      C.CorrAccounts := '';

      C.IncSubAccounts := (tvGroup.Selected <> nil)
        and (tvGroup.Selected.getFirstChild <> nil);

      FI := FFieldInfos.FindInfo(F.FieldName);
      if (FI <> nil) and (FI is TgdvLedgerFieldInfo) then
      begin
        C.CorrAccounts := GetAlias(TgdvLedgerFieldInfo(FI).AccountKey);
        C.AccountPart := TgdvLedgerFieldInfo(FI).AccountPart;
      end;

      C.Analytics := '';

      if not NewWindow or (Form = nil) then
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.CreateAndAssign(Application)) do
        begin
          gsPeriodEdit.Text := Self.gsPeriodEdit.Text;
          ActiveControl := ibgrMain;

          Show;
          Execute(C);
        end;
      end else
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.Create(Application)) do
        begin
          gsPeriodEdit.Text := Self.gsPeriodEdit.Text;
          ActiveControl := ibgrMain;
          
          Show;
          Execute(C);
        end;
      end;
    finally
      C.Free;
    end;
  end;
end;

function Tgdv_frmGeneralLedger.CompareParams(WithDate: Boolean = True): boolean;
begin
  Result := inherited CompareParams(WithDate)
    and ((FConfig as TAccGeneralLedgerConfig).ShowDebit = cbShowDebit.Checked)
    and ((FConfig as TAccGeneralLedgerConfig).ShowCredit = cbShowCredit.Checked)
    and ((FConfig as TAccGeneralLedgerConfig).ShowCorrSubAccounts = cbShowCorrSubAccount.Checked); 
end;

procedure Tgdv_frmGeneralLedger.iblConfiguratiorChange(Sender: TObject);
begin
  tvGroup.FullCollapse;
  if iblConfiguratior.CurrentKeyInt > -1 then
    inherited
  else begin
    gdcAcctChart.Close;
    gdcAcctChart.SubSet := 'All';
    cbAccounts.Text:= '';
    if Assigned(FAccountIDs) then
      FAccountIDs.Clear;
    SetAcctChartExtraConditions;
    gdcAcctChart.Open;
    UpdateControls;
  end;
end;

procedure Tgdv_frmGeneralLedger.chkBuildGroupClick(Sender: TObject);
begin
  UpdateControls;
end;

function Tgdv_frmGeneralLedger.GetGdvObject: TgdvAcctBase;
begin
  Result := ibdsMain;
end;

procedure Tgdv_frmGeneralLedger.SetParams;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    // ��������� ��� � �����
    TgdvAcctGeneralLedger(gdvObject).AddGroupBy('MONTH');
    TgdvAcctGeneralLedger(gdvObject).AddGroupBy('YEAR');

    TgdvAcctGeneralLedger(gdvObject).ShowDebit := cbShowDebit.Checked;
    TgdvAcctGeneralLedger(gdvObject).ShowCredit := cbShowCredit.Checked;
    TgdvAcctGeneralLedger(gdvObject).ShowCorrSubAccounts := cbShowCorrSubAccount.Checked;
    TgdvAcctGeneralLedger(gdvObject).EnchancedSaldo := cbEnchancedSaldo.Checked;
    gdvObject.AllHolding := frAcctCompany.cbAllCompanies.Checked;
  end;
end;

procedure Tgdv_frmGeneralLedger.InitColumns;
var
  I, J: Integer;
  FI: TgdvFieldInfo;
  DisplayFields: string;
  FIndex, DIndex: Integer;
  C: TgsColumn;
  P: Integer;
begin
  inherited;
  if (FFieldInfos <> nil) and (ibgrMain.Conditions.Count > 0) then
  begin
    for I := 0 to ibgrMain.Conditions.Count - 1 do
    begin
      C := FindColumn(UpperCase(ibgrMain.Conditions[I].FieldName));
      if (C <> nil) and (C.Field <> nil) then
      begin
        FIndex := C.Field.Index;

        DisplayFields := ibgrMain.Conditions[I].DisplayFields;
        for J := 0 to FFieldInfos.Count - 1 do
        begin
          FI := FFieldInfos[J];
          if FI.Condition then
          begin
            P := Pos(FI.FieldName + ';', DisplayFields);
            if P > 0 then
              Delete(DisplayFields, P, Length(FI.FieldName + ';'));
            C := FindColumn(FI.FieldName);
            if (C <> nil) and (C.Field <> nil) then
            begin
              DIndex := C.Field.Index;
              if DIndex >= FIndex then
              begin
                if (DisplayFields > '') and (DisplayFields[Length(DisplayFields)] <> ';') then
                  DisplayFields := DisplayFields + ';';
                DisplayFields := DisplayFields + FI.FieldName + ';';
              end;
            end;
          end;
        end;
      end;
      ibgrMain.Conditions[I].DisplayFields := DisplayFields;
    end;
  end;
end;

procedure Tgdv_frmGeneralLedger.actGotoLedgerExecute(Sender: TObject);
var
  ibsql: TIBSQL;
  I: Integer;
  C: TAccLedgerConfig;
  S, AnalizeFields: TStrings;
  F: TField;
begin
  F := ibgrMain.SelectedField;
  if (F <> nil) and (gdvObject.Accounts.Count > 0) then
  begin
    AnalizeFields := TStringList.Create;
    try
      ibsql := TIBSQL.Create(nil);

      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT * FROM ac_account a WHERE a.id = :id';
        SetTID(ibsql.ParamByName('id'), gdvObject.Accounts[0]);
        ibsql.ExecQuery;
        if not ibsql.Eof
          and ((ibsql.FieldByName('accounttype').AsString = 'A')
            or (ibsql.FieldByName('accounttype').AsString = 'S')) then
        begin
          for I:= 0 to ibsql.Current.Count - 1 do
            if ((Pos(UserPrefix, ibsql.Fields[I].Name) = 1) and (ibsql.Fields[I].AsInteger = 1)) then
            begin
              AnalizeFields.Add(ibsql.Fields[I].Name);
              Break;
            end;
        end;
        ibsql.close;

        ibsql.SQL.Text := 'SELECT * FROM ac_accanalyticsext aa JOIN at_relation_fields rf ' +
          ' ON aa.valuekey = rf.id and aa.accountkey = :id';
        SetTID(ibsql.ParamByName('id'), gdvObject.Accounts[0]);
        ibsql.ExecQuery;

        if not ibsql.Eof then
        begin
          AnalizeFields.Clear;
          while not ibsql.eof do
          begin
            AnalizeFields.Add(ibsql.FieldByName('fieldname').AsString);
            ibsql.Next;
          end;
        end;

      finally
        ibsql.Free;
      end;

      if AnalizeFields.Count > 0 then
      begin
        C := TAccLedgerConfig.Create;
        try
          DoSaveConfig(C);
          C.Accounts := GetAlias(gdvObject.Accounts[0]);
          S := TStringList.Create;
          try
            S.Assign(AnalizeFields);
            SaveIntegerToStream(S.Count, C.AnalyticsGroup);
            for I := 0 to S.Count - 1 do
            begin
              SaveStringToStream(S[I], C.AnalyticsGroup);
              SaveBooleanToStream(True, C.AnalyticsGroup);
            end;
          finally
            S.Free;
          end;
          C.IncSubAccounts := True;

          C.ShowDebit := Self.cbShowDebit.Checked;
          C.ShowCredit := Self.cbShowCredit.Checked;
          C.ShowCorrSubAccounts := Self.cbShowCorrSubAccount.Checked;

          with Tgdv_frmAcctLedger.CreateAndAssign(Application) as Tgdv_frmAcctLedger do
          begin
            gsPeriodEdit.Text := Self.gsPeriodEdit.Text;

            Show;
            Execute(C);
          end;

        finally
          C.Free;
        end;
      end
    else
      MessageDlg('�� ������� ����� ��� �������� �������������� �����', mtWarning,
        [mbOk], -1);

    finally
      AnalizeFields.free;
    end;
  end;
end;

procedure Tgdv_frmGeneralLedger.actGotoLedgerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdvObject.Active and (gdvObject.Accounts.Count > 0) and
    not gdvObject.IsEmpty
end;

initialization
  RegisterFrmClass(Tgdv_frmGeneralLedger);

finalization
  UnRegisterFrmClass(Tgdv_frmGeneralLedger);
end.
