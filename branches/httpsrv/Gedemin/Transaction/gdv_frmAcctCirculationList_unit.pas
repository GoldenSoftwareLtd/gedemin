
unit gdv_frmAcctCirculationList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmG_unit, gd_ReportMenu, Menus, gd_MacrosMenu, ActnList, Db,
  StdCtrls, Mask, xDateEdits, Buttons, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, ComCtrls, gsDBTreeView, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gdcBase, gdcTree, gdcAcctAccount, IBCustomDataSet, IBSQL, gdcBaseInterface,
  at_classes, flt_sqlFilter, AcctUtils, gdv_AcctConfig_unit, gd_common_functions,
  gd_createable_form, IBDatabase, gdv_frmAcctBaseForm_unit,
  gdv_frAcctBaseAnalyticGroup, gdv_frAcctAnalyticsGroup_unit, AcctStrings,
  gdvParamPanel, gdv_frAcctCompany_unit, gdv_frAcctAnalytics_unit,
  gdv_frAcctSum_unit, gdv_frAcctQuantity_unit, gsIBLookupComboBox,
  gdv_frAcctTreeAnalytic_unit, gdvAcctBase, gdvAcctCirculationList,
  gdvAcctLedger, DBClient, gsPeriodEdit;

type
  Tgdv_frmAcctCirculationList = class(Tgdv_frmAcctBaseForm)
    dsAcctChart: TDataSource;
    gdcAcctChart: TgdcAcctChart;
    actAccountCard: TAction;
    actAnalizeRevolution: TAction;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    pCardOfAccount: TPanel;
    lCardOfaccount: TLabel;
    ptvGroup: TPanel;
    tvGroup: TgsDBTreeView;
    cbAutoBuildReport: TCheckBox;
    actGotoLedger: TAction;
    N3: TMenuItem;
    cbDisplaceSaldo: TCheckBox;
    ibdsMain: TgdvAcctCirculationList;
    cdsTotal: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure tvGroupChange(Sender: TObject; Node: TTreeNode);
    procedure actRunUpdate(Sender: TObject);
    procedure actAnalizeRevolutionUpdate(Sender: TObject);
    procedure actGotoLedgerExecute(Sender: TObject);
    procedure ibgrMainGetTotal(Sender: TObject; const FieldName: String;
      const AggregatesObsolete: Boolean; var DisplayString: String);
    procedure cbSubAccountClick(Sender: TObject);
    procedure ibdsMainAfterOpen(DataSet: TDataSet);
    procedure actGotoLedgerUpdate(Sender: TObject);
  private 
  protected
    function GetGdvObject: TgdvAcctBase; override;
    procedure SetParams; override;

    procedure UpdateControls; override;
    procedure Go_to(NewWindow: Boolean = false); override;
    function CompareParams(WithDate: Boolean = True): boolean; override;
    class function ConfigClassName: string; override;
    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdv_frmAcctCirculationList: Tgdv_frmAcctCirculationList;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gd_security,
  gsStorage_CompPath, gd_directories_const,
  gdv_frmAcctAccCard_Unit, gdv_frmAcctLedger_unit,
  gdcConstants, jclStrings;

const
  cAutoBuildReport = 'AutoBuildReport';

  FIELD_COUNT = 18;
  FIELD_ARRAY: array [0..(FIELD_COUNT - 1)] of String =
    ('ncu_begin_debit', 'ncu_begin_credit', 'ncu_debit', 'ncu_credit', 'ncu_end_debit', 'ncu_end_credit',
     'curr_begin_debit', 'curr_begin_credit', 'curr_debit', 'curr_credit', 'curr_end_debit', 'curr_end_credit',
     'eq_begin_debit', 'eq_begin_credit', 'eq_debit', 'eq_credit', 'eq_end_debit', 'eq_end_credit');

{ Tgdv_frmAcctCirculationList }

procedure Tgdv_frmAcctCirculationList.FormCreate(Sender: TObject);
var
  FieldCounter: Integer;
begin
  // Датасет с суммами по основному датасету
  cdsTotal.Close;
  for FieldCounter := 0 to FIELD_COUNT - 1 do
    cdsTotal.FieldDefs.Add(FIELD_ARRAY[FieldCounter], ftCurrency, 0, False);
  cdsTotal.CreateDataSet;
  cdsTotal.Open;

  inherited;

  gdcAcctChart.SubSet := 'All';
  gdcAcctChart.Open;
    
  UpdateControls;
end;

procedure Tgdv_frmAcctCirculationList.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTCIRCULATIONLIST', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTCIRCULATIONLIST', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTCIRCULATIONLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTCIRCULATIONLIST',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTCIRCULATIONLIST' then
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
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTCIRCULATIONLIST', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTCIRCULATIONLIST', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctCirculationList.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTCIRCULATIONLIST', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTCIRCULATIONLIST', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTCIRCULATIONLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTCIRCULATIONLIST',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTCIRCULATIONLIST' then
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
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTCIRCULATIONLIST', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTCIRCULATIONLIST', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctCirculationList.UpdateControls;
var
  SQL: TIBSQL;
begin
  if tvGroup.Selected <> nil then
  begin
    //Добавляем в список счета и субсчета выбранного счета
    FAccountIDs.Clear;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := Format(' SELECT a2.id FROM ac_account a1, ac_account a2 WHERE a1.id IN ' +
        '(SELECT accountkey FROM ac_companyaccount WHERE companykey IN (%s)) and ' +
        ' a2.lb >= a1.lb and a2.rb <= a1.rb and a2.ACCOUNTTYPE in (''A'', ''S'')', [IBlogin.HoldingList]);
      SQL.ExecQuery;
      while not SQl.Eof do
      begin
        if FAccountIDs.IndexOf(Pointer(SQL.FieldByName(fnId).AsInteger)) = -1 then
          FAccountIDs.Add(Pointer(SQL.FieldByName(fnId).AsInteger));
        SQL.Next;  
      end;
    finally
      SQL.Free;
    end;

    //Обновляем количественные показатели
    //frAcctQuantity.UpdateQuantityList(FAccountIDs);
    frAcctQuantity.Visible := False;
    ScrollBox.Realign;
  end;
end;

procedure Tgdv_frmAcctCirculationList.tvGroupChange(Sender: TObject;
  Node: TTreeNode);
begin
  UpdateControls;
  if cbAutoBuildReport.Checked then
    BuildAcctReport; 
end;

procedure Tgdv_frmAcctCirculationList.actRunUpdate(Sender: TObject);
begin
  // Уберем наследованный обработчик
end;


procedure Tgdv_frmAcctCirculationList.Go_to(NewWindow: Boolean);
var
  F: TField;
  C: TAccCardConfig;
  FI: TgdvFieldInfo;
  A: String;
  Form: TCreateableForm;
begin
  Form := gd_createable_form.FindForm(Tgdv_frmAcctAccCard);

  F := ibgrMain.SelectedField;
  if F <> nil then
  begin
    C := TAccCardConfig.Create;
    try
      DoSaveConfig(C);
      C.Accounts := gdvObject.FieldByName('alias').AsString;

      C.IncCorrSubAccounts := False;
      C.CorrAccounts := '';
      C.CompanyKey := frAcctCompany.iblCompany.CurrentKeyInt;
      C.AllHoldingCompanies := frAcctCompany.cbAllCompanies.Checked and frAcctCompany.cbAllCompanies.Enabled;

      FI := FFieldInfos.FindInfo(F.FieldName);
      if (FI <> nil) and (FI is TgdvLedgerFieldInfo) then
      begin
        C.CorrAccounts := GetAlias(TgdvLedgerFieldInfo(FI).AccountKey);
        C.AccountPart := TgdvLedgerFieldInfo(FI).AccountPart;
      end;

      A := '';
{      for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
      begin
        if (frAcctAnalyticsGroup.Selected[I].Field <> nil) and
          (frAcctAnalyticsGroup.Selected[I].FieldName <> ENTRYDATE) then
        begin
          FieldName := Format('c%d', [I]);
          F := gdvObject.FindField(FieldName);
          if (F <> nil) and not F.IsNull then
          begin
            if A > '' then A := A + #13#10;

            A := A + frAcctAnalyticsGroup.Selected[I].FieldName + '=' + Trim(F.AsString);
          end;
        end;
      end;}

      if A > '' then
        C.Analytics := A;

      if not NewWindow or (Form = nil) then
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.CreateAndAssign(Application)) do
        begin
          DateBegin := Self.DateBegin;
          DateEnd := Self.DateEnd;

          Show;
          Execute(C);
        end;
      end else
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.Create(Application)) do
        begin
          DateBegin := Self.DateBegin;
          DateEnd := Self.DateEnd;

          Show;
          Execute(C);
        end;
      end;
    finally
      C.Free;
    end;
  end;
end;

function Tgdv_frmAcctCirculationList.CompareParams(WithDate: Boolean = True): boolean;
begin
  Result := inherited CompareParams(WithDate)
    and ((FConfig as TAccCirculationListConfig).SubAccountsInMain = cbSubAccount.Checked)
    and ((FConfig as TAccCirculationListConfig).DisplaceSaldo = cbDisplaceSaldo.Checked);
end;

class function Tgdv_frmAcctCirculationList.ConfigClassName: string;
begin
  Result := 'TAccCirculationListConfig'
end;

procedure Tgdv_frmAcctCirculationList.DoLoadConfig(
  const Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;
  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    cbSubAccount.Checked := C.SubAccountsInMain;
    cbDisplaceSaldo.Checked := C.DisplaceSaldo;
  end;
end;

procedure Tgdv_frmAcctCirculationList.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccCirculationListConfig;
begin
  inherited;
  if Config is TAccCirculationListConfig then
  begin
    C := Config as TAccCirculationListConfig;
    C.ShowDebit := False;
    C.ShowCredit := False;
    C.ShowCorrSubAccounts := False;
    C.SubAccountsInMain:= cbSubAccount.Checked;
    C.DisplaceSaldo:= cbDisplaceSaldo.Checked;
  end;
end;

procedure Tgdv_frmAcctCirculationList.actAnalizeRevolutionUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := gdvObject.Active and (gdvObject.FindField('id') <> nil) and
     not gdvObject.IsEmpty
end;

procedure Tgdv_frmAcctCirculationList.actGotoLedgerExecute(
  Sender: TObject);
var
  ibsql: TIBSQL;
  AnalizeField: String;
  i: Integer;
  C: TAccLedgerConfig;
  S: TStrings;
begin
  AnalizeField := '';
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM ac_account a LEFT JOIN at_relation_fields atr ' +
      ' ON a.analyticalfield = atr.id WHERE a.id = :id';
    ibsql.ParamByName('id').AsInteger := gdvObject.FieldByName('id').AsInteger;
    ibsql.ExecQuery;
    if ibsql.FieldByName('analyticalfield').AsInteger > 0 then
      AnalizeField := ibsql.FieldByName('fieldname').asString
    else
    begin
      for i:= 0 to ibsql.Current.Count - 1 do
        if ((Pos(UserPrefix, ibsql.Fields[i].Name) = 1) and (ibsql.Fields[i].AsInteger = 1)) then
        begin
          AnalizeField := ibsql.Fields[i].Name;
          Break;
        end;
    end;
  finally
    ibsql.Free;
  end;

  if AnalizeField <> '' then
  begin
    C := TAccLedgerConfig.Create;
    try
      DoSaveConfig(C);
      C.Accounts := GetAlias(gdvObject.FieldByName('id').AsInteger);
      S := TStringList.Create;
      try
        S.Text := AnalizeField;
        SaveIntegerToStream(S.Count, C.AnalyticsGroup);
        for I := 0 to S.Count - 1 do
        begin
          SaveStringToStream(S[I], C.AnalyticsGroup);
          SaveBooleanToStream(True, C.AnalyticsGroup);
        end;
      finally
        S.Free;
      end;
      C.IncSubAccounts := False;

      with Tgdv_frmAcctLedger.CreateAndAssign(Application) as Tgdv_frmAcctLedger do
      begin
        DateBegin := Self.DateBegin;
        DateEnd := Self.DateEnd;

        Show;
        Execute(C);
      end;
    finally
      C.Free;
    end;
  end
  else
    MessageDlg('По данному счету нет объектов аналитического учета', mtWarning,
      [mbOk], -1);
end;

procedure Tgdv_frmAcctCirculationList.ibgrMainGetTotal(Sender: TObject;
  const FieldName: String; const AggregatesObsolete: Boolean;
  var DisplayString: String);
var
  FormatString: String;
begin
  if not cbSubAccount.Checked or not AggregatesObsolete or
     (ibgrMain.SelectedRows.Count > 1) then Exit;

  // Если выбран режим "Включать субсчета в главный", то берем итоговую сумму из датасета с итоговыми суммами
  if Assigned(cdsTotal.FindField(FieldName)) then
  begin
    FormatString := '#,##0';
    if frAcctSum.NcuDecDigits > 0 then
      FormatString := FormatString + '.' + StrFillChar('0', frAcctSum.NcuDecDigits);
    DisplayString := FormatFloat(FormatString, cdsTotal.FieldByName(FieldName).AsCurrency)
  end else
    DisplayString := '';
end;

procedure Tgdv_frmAcctCirculationList.cbSubAccountClick(Sender: TObject);
begin
  inherited;
  cbDisplaceSaldo.Enabled := cbSubAccount.Checked;
end;

function Tgdv_frmAcctCirculationList.GetGdvObject: TgdvAcctBase;
begin
  Result := ibdsMain;
end;

procedure Tgdv_frmAcctCirculationList.SetParams;
begin
  inherited;
  // Очистим переданные в Tgdv_frmAcctBaseForm счета
  if not gdvObject.MakeEmpty then
  begin
    gdvObject.Accounts.Clear;
    if Assigned(tvGroup.Selected) then
      gdvObject.AddAccount(Integer(tvGroup.Selected.Data));
    gdvObject.AllHolding := frAcctCompany.cbAllCompanies.Checked and frAcctCompany.cbAllCompanies.Enabled;
    gdvObject.WithSubAccounts := False;
  end; 
end;

procedure Tgdv_frmAcctCirculationList.ibdsMainAfterOpen(DataSet: TDataSet);
var
  q: TIBSQL;
  sl, slFields: TStringList;
  sTmp, sName: String;
  i, j: integer;
  curValue, curNBC, curNBD, curCBC, curCBD, curEBC, curEBD, curNEC, curNED, curCEC, curCED, curEEC, curEED: Currency;

  procedure SetDebitCredit(var ACredit: currency; var ADebit: currency);
  begin
    if ADebit - ACredit > 0 then begin
      ADebit:= ADebit - ACredit;
      ACredit:= 0;
    end
    else begin
      ACredit:= ACredit - ADebit;
      ADebit:= 0;
    end;
  end;

begin
  inherited;

  gdvObject.DisableControls;
  try
    // Сложим значения по строкам и занесем в отдельный датасет
    gdvObject.First;
    cdsTotal.Edit;
    // Обнулим данные
    for i := 0 to cdsTotal.Fields.Count - 1 do
      cdsTotal.Fields[i].AsCurrency := 0;
    // Сложим значения по строкам
    while not gdvObject.Eof do
    begin
      for I := 0 to FIELD_COUNT - 1 do
        cdsTotal.FieldByName(FIELD_ARRAY[I]).AsCurrency :=
          cdsTotal.FieldByName(FIELD_ARRAY[I]).AsCurrency + gdvObject.FieldByName(FIELD_ARRAY[I]).AsCurrency;
      gdvObject.Next;
    end;
    cdsTotal.Post;
  finally
    gdvObject.First;
    gdvObject.EnableControls;
  end;

  if not FMakeEmpty and cbSubAccount.Checked then
  begin
    gdvObject.DisableControls;
    try
      gdvObject.First;

      q := TIBSQL.Create(self);
      sl := TStringList.Create;
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        // Запрос для нахождения родительского счета
        q.SQL.Text :=
          'SELECT a.id, a.alias, a.name ' +
          'FROM ac_account a JOIN ac_account a_up ' +
          '  ON a.lb < a_up.lb AND a.rb > a_up.rb ' +
          'WHERE a.accounttype in (''A'', ''S'') AND a_up.id = :id';
        while not gdvObject.Eof do
        begin
          q.Close;
          q.ParamByName('id').AsInteger:= gdvObject.FieldByName('id').AsInteger;
          q.ExecQuery;
          while not q.Eof do
          begin
            sTmp := IntToStr(q.FieldByName('id').AsInteger);
            i := sl.IndexOfName(sTmp);
            if i = -1 then
            begin
              slFields:= TStringList.Create;
              for i := 0 to gdvObject.Fields.Count - 1 do
              begin
                sName:= gdvObject.Fields[i].FieldName;
                case gdvObject.Fields[i].DataType of
                  ftInteger, ftLargeInt:
                  begin
                    if (sName = 'ID') then
                      slFields.Add(sName + '=' + q.FieldByName('id').AsString)
                    else
                      slFields.Add(sName + '=' + gdvObject.FieldByName(sName).AsString)
                  end;

                  ftString:
                  begin
                    if (sName = 'ALIAS') or (sName = 'NAME') then
                      slFields.Add(sName + '=' + q.FieldByName(sName).AsString)
                    else
                      slFields.Add(sName + '=' + gdvObject.FieldByName(sName).AsString);
                  end;

                  ftBCD:
                  begin
                    if (Pos('CREDIT', sName) > 0) or (Pos('DEBIT', sName) > 0) then
                      slFields.Add(sName + '=' + gdvObject.FieldByName(sName).AsString);
                  end

                  else
                  begin
                    sTmp := sTmp;
                  end;
                end;
              end;
              sl.AddObject(sTmp + '=' + gdvObject.FieldByName('id').AsString, slFields);
            end
            else
            begin
              slFields := sl.Objects[i] as TStringList;
              for i := 0 to gdvObject.Fields.Count - 1 do
              begin
                sName := gdvObject.Fields[i].FieldName;
                case gdvObject.Fields[i].DataType of
                  ftBCD, ftInteger, ftLargeInt:
                  begin
                    if (Pos('CREDIT', sName) > 0) or (Pos('DEBIT', sName) > 0) then
                    begin
                      try
                        curValue := StrToCurr(slFields.Values[sName]);
                      except
                        curValue := 0;
                      end;
                      curValue := curValue + gdvObject.FieldByName(sName).AsCurrency;
                      slFields.Values[sName] := CurrToStr(curValue);
                    end;
                  end
                end;
              end;
            end;
            q.Next;
          end;
          gdvObject.Next;
        end;

        for i := 0 to sl.Count - 1 do
        begin
          sTmp := sl.Names[i];
          if gdvObject.Locate('id', StrToInt(sTmp), []) then
          begin
            gdvObject.Edit;
          end
          else
          begin
            sTmp := sl.Values[sl.Names[i]];
            gdvObject.Locate('id', StrToInt(sTmp), []);
            gdvObject.Insert;
          end;
          if cbDisplaceSaldo.Checked then
          begin
            curNBC := 0; curNBD := 0; curNEC := 0; curNED := 0;
            curCBC := 0; curCBD := 0; curCEC := 0; curCED := 0;
            curEBC := 0; curEBD := 0; curEEC := 0; curEED := 0;
            for j := 0 to (sl.Objects[i] as TStringList).Count - 1 do
            begin
              sName := AnsiUpperCase((sl.Objects[i] as TStringList).Names[j]);
              if (Pos('_BEGIN_', sName) < 1) and (Pos('_END_', sName) < 1) then
                Continue;
              try
                curValue := StrToCurr((sl.Objects[i] as TStringList).Values[(sl.Objects[i] as TStringList).Names[j]]);
              except
                curValue := 0;
              end;
              if sName = 'NCU_BEGIN_DEBIT' then
                curNBD := curNBD + curValue
              else if sName = 'NCU_BEGIN_CREDIT' then
                curNBC := curNBC + curValue
              else if sName = 'NCU_END_DEBIT' then
                curNED := curNED + curValue
              else if sName = 'NCU_END_CREDIT' then
                curNEC := curNEC + curValue
              else if sName = 'CURR_BEGIN_DEBIT' then
                curCBD := curCBD + curValue
              else if sName = 'CURR_BEGIN_CREDIT' then
                curCBC := curCBC + curValue
              else if sName = 'CURR_END_DEBIT' then
                curCED := curCED + curValue
              else if sName = 'CURR_END_CREDIT' then
                curCEC := curCEC + curValue
              else if sName = 'EQ_BEGIN_DEBIT' then
                curEBD := curEBD + curValue
              else if sName = 'EQ_BEGIN_CREDIT' then
                curEBC := curEBC + curValue
              else if sName = 'EQ_END_DEBIT' then
                curEED := curEED + curValue
              else if sName = 'EQ_END_CREDIT' then
                curEEC := curEEC + curValue;
            end;
            SetDebitCredit(curNBC, curNBD);
            SetDebitCredit(curNEC, curNED);
            SetDebitCredit(curCBC, curCBD);
            SetDebitCredit(curCEC, curCED);
            SetDebitCredit(curEBC, curEBD);
            SetDebitCredit(curEEC, curEED);
            for j:= 0 to (sl.Objects[i] as TStringList).Count - 1 do
            begin
              sName := AnsiUpperCase((sl.Objects[i] as TStringList).Names[j]);

              if sName = 'NCU_BEGIN_DEBIT' then
                sTmp := CurrToStr(curNBD)
              else if sName = 'NCU_BEGIN_CREDIT' then
                sTmp := CurrToStr(curNBC)
              else if sName = 'NCU_END_DEBIT' then
                sTmp := CurrToStr(curNED)
              else if sName = 'NCU_END_CREDIT' then
                sTmp := CurrToStr(curNEC)
              else if sName = 'CURR_BEGIN_DEBIT' then
                sTmp := CurrToStr(curCBD)
              else if sName = 'CURR_BEGIN_CREDIT' then
                sTmp := CurrToStr(curCBC)
              else if sName = 'CURR_END_DEBIT' then
                sTmp := CurrToStr(curCED)
              else if sName = 'CURR_END_CREDIT' then
                sTmp := CurrToStr(curCEC)
              else if sName = 'EQ_BEGIN_DEBIT' then
                sTmp := CurrToStr(curEBD)
              else if sName = 'EQ_BEGIN_CREDIT' then
                sTmp := CurrToStr(curEBC)
              else if sName = 'EQ_END_DEBIT' then
                sTmp := CurrToStr(curEED)
              else if sName = 'EQ_END_CREDIT' then
                sTmp := CurrToStr(curEEC)
              else
                sTmp := (sl.Objects[i] as TStringList).Values[(sl.Objects[i] as TStringList).Names[j]];
              if (Pos('_BEGIN_', sName) > 0) or (Pos('_END_', sName) > 0) then
                (sl.Objects[i] as TStringList).Values[(sl.Objects[i] as TStringList).Names[j]] := sTmp;
              gdvObject.FieldByName(sName).AsString:= sTmp;
            end;
          end
          else
          begin
            for j:= 0 to (sl.Objects[i] as TStringList).Count - 1 do begin
              gdvObject.FieldByName((sl.Objects[i] as TStringList).Names[j]).AsString :=
                (sl.Objects[i] as TStringList).Values[(sl.Objects[i] as TStringList).Names[j]]
            end;
          end;
          gdvObject.Post;
        end;
      finally
        for I := 0 to sl.Count - 1 do
          sl.Objects[I].Free;
        sl.Free;  
        q.Free;
      end;
      ibgrMain.OnGetTotal := ibgrMainGetTotal;
    finally
      gdvObject.First;
      gdvObject.EnableControls;
    end;
  end;
end;

procedure Tgdv_frmAcctCirculationList.actGotoLedgerUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdvObject.Active and (gdvObject.FindField('id') <> nil) and
    not gdvObject.IsEmpty
end;

initialization
  RegisterFrmClasses([Tgdv_frmAcctCirculationList]);

finalization
  UnRegisterFrmClasses([Tgdv_frmAcctCirculationList]);
end.
