unit wiz_frEntryEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, gsIBLookupComboBox, BtnEdit,
  wiz_FunctionBlock_unit, wiz_ExpressionEditorForm_unit, gdcConstants,
  Menus, AcctUtils, wiz_Strings_unit, gdcBaseInterface, at_classes,
  wiz_frAnalytics_unit, TB2Item, TB2Dock, TB2Toolbar, ActnList,
  wiz_frQuantity_unit, gdc_frmAnalyticsSel_unit ;

type
  TfrEntryEditFrame = class(TfrEditFrame)
    Label3: TLabel;
    beDebit: TBtnEdit;
    Label4: TLabel;
    beCredit: TBtnEdit;
    Label7: TLabel;
    beSum: TBtnEdit;
    Label8: TLabel;
    Label9: TLabel;
    beSumCurr: TBtnEdit;
    tsAddiditional: TTabSheet;
    Label10: TLabel;
    beBeginDate: TBtnEdit;
    beEndDate: TBtnEdit;
    Label11: TLabel;
    Label12: TLabel;
    beEntryDate: TBtnEdit;
    cbSaveEmpty: TCheckBox;
    tsDAnalytics: TTabSheet;
    frDAnalytics: TfrAnalytics;
    tsCAnalytics: TTabSheet;
    frCAnalytics: TfrAnalytics;
    Label5: TLabel;
    beEntryDescription: TBtnEdit;
    tsCreditQuantity: TTabSheet;
    ActionList: TActionList;
    actAddQuantityD: TAction;
    actDeleteQuantityD: TAction;
    actEditQuantityD: TAction;
    tsDebitQuantity: TTabSheet;
    frQuantityDebit: TfrQuantity;
    frQuantityCredit: TfrQuantity;
    beCurr: TBtnEdit;
    pmCurr: TPopupMenu;
    procedure beDebitBtnOnClick(Sender: TObject);
    procedure beDebitChange(Sender: TObject);
    procedure beDebitExit(Sender: TObject);
    procedure beCreditChange(Sender: TObject);
    procedure beCreditExit(Sender: TObject);
    procedure beAnalDebitBtnOnClick(Sender: TObject);
    procedure beSumBtnOnClick(Sender: TObject);
    procedure beCurrBtnOnClick(Sender: TObject);
    procedure beCurrChange(Sender: TObject);
    procedure pmCurrPopup(Sender: TObject);
  private
    { Private declarations }
    FAccountPopupMenu: TAccountPopupMenu;
    FAnalPopupMenu: TAnalPopupMenu;

    FDebit, FCredit: Integer;
    FCurrKey: Integer;
    procedure ClickCurrency(Sender: TObject);
    procedure ClickExpression(Sender: TObject);
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);

    procedure ClickAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
    procedure ClickExpr(Sender: TObject);
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frEntryEditFrame: TfrEntryEditFrame;

implementation
uses tax_frmAnalytics_unit, gdc_frmAccountSel_unit;
{$R *.DFM}

{ TfrEntryEditFrame }

function TfrEntryEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(beDebit.Text) > '';
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INPUT_DEBIT_ACCOUNT)
    end;
  end;
  if Result then
  begin
    Result := Trim(beCredit.Text) > '';
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INPUT_CREDIT_ACCOUNT);
    end;
  end;
  if Result  then
  begin
    Result := (Trim(beSum.Text) > '') or ((Trim(beSumCurr.Text) > '') and
      (beCurr.Text > '')) ;
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INPUT_SUM);
    end;
  end;
  if Result then
  begin
    Result := (beBeginDate.Text > '') and
      (beEndDate.Text > '') and (beEntryDate.Text > '');
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INPUT_ENTRYDATE)
    end;
  end;
end;

procedure TfrEntryEditFrame.ClickAccount(Sender: TObject);
var
  S: string;
  RUID: String;
begin
  if FActiveEdit <> nil then
  begin
    S := FActiveEdit.Text;
    if FActiveEdit = beDebit then
    begin
      try
        RUID := gdcBaseManager.GetRUIDStringById(FDebit);
      except
        RUID := '';
      end;
      MainFunction.OnClickAccount(S, RUID);
      FActiveEdit.Text := S;
      try
        FDebit := gdcBaseManager.GetIdByRUIDString(RUID);
      except
        FActiveEdit.Text := RUID;
        FDebit := 0;
      end;
    end else
    begin
      try
        RUID := gdcBaseManager.GetRUIDStringById(FCredit);
      except
        RUID := '';
      end;
      MainFunction.OnClickAccount(S, RUID);
      FActiveEdit.Text := S;
      try
        FCredit := gdcBaseManager.GetIdByRUIDString(RUID);
      except
        FActiveEdit.Text := RUID;
        FCredit := 0;
      end;
    end;
  end;
end;

procedure TfrEntryEditFrame.ClickAccountCicle(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TAccountCycleBlock(TMenuItem(Sender).Tag).BlockName + '.Account';
  end;
end;

procedure TfrEntryEditFrame.ClickAnal(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  if FActiveEdit <> nil then
  begin
    D := TfrmAnalytics.Create(nil);
    try
      D.Block := Self.Block;
      if D.ShowModal = idOk then
        AddAnal(FActiveEdit, D.Analytics);
    finally
      D.Free
    end;
  end;
end;

procedure TfrEntryEditFrame.ClickAnalCycle(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    AddAnal(FActiveEdit, Format('%s.%s',
      [TVisualBlock(TMenuItem(Sender).Tag).BlockName, TMenuItem(Sender).Caption]));
  end;
end;

procedure TfrEntryEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TEntryBlock do
  begin
    Debit := GetAccount(beDebit.Text, FDebit);
    Credit := GetAccount(beCredit.Text, FCredit);

    AnalDebit := frDAnalytics.Analytics;
    AnalCredit := frCAnalytics.Analytics;

    Sum := beSum.Text;
//    CurrRUID := gdcBaseManager.GetRUIDStringById(gsiblCurr.CurrentKeyInt);
    if FCurrKey > 0 then
      CurrRUID := gdcBaseManager.GetRUIDStringById(FCurrKey)
    else
      CurrRUID := beCurr.Text;
    SumCurr := beSumCurr.Text;

    BeginDate := beBeginDate.Text;
    EndDate := beEndDate.Text;
    EntryDate := beEntryDate.Text;
    SaveEmpty := cbSaveEmpty.Checked;

    EntryDescription := beEntryDescription.Text;
    QuantityDebit := frQuantityDebit.Quantity;
    QuantityCredit := frQuantityCredit.Quantity;
  end;
end;

procedure TfrEntryEditFrame.SetBlock(const Value: TVisualBlock);
var
  Id: Integer;
begin
  inherited;
  with FBlock as TEntryBlock do
  begin
    beDebit.Text := SetAccount(Debit, id);
    FDebit := id;
    beCredit.Text := SetAccount(Credit, id);
    FCredit := id;

    frDAnalytics.Block := Value;
    frDAnalytics.AccountKey := FDebit;
    frDAnalytics.UpdateAnalytics;
    frCAnalytics.Block := Value;
    frCAnalytics.AccountKey := FCredit;
    frCAnalytics.UpdateAnalytics;
    frDAnalytics.Analytics := AnalDebit;
    frCAnalytics.Analytics := AnalCredit;

    beSum.Text := Sum;
    FCurrKey := 0;
    if CheckRUID(CurrRUID) then
    begin
      Id := gdcBaseManager.GetIDByRUIDString(CurrRUID);
      beCurr.Text := GetCurrNameById(ID);
      FCurrKey := Id
    end else
      beCurr.Text := CurrRUID;

//    gsiblCurr.CurrentKeyInt := gdcBaseManager.GetIdByRUIDString(CurrRUID);
    beSumCurr.Text := SumCurr;

    beBeginDate.Text := BeginDate;
    beEndDate.Text := EndDate;
    beEntryDate.Text := EntryDate;
    cbSaveEmpty.Checked := SaveEmpty;

    beEntryDescription.Text := EntryDescription;

    frQuantityDebit.Block := Value;
    frQuantityDebit.Quantity := QuantityDebit;
    frQuantityCredit.Block := Value;
    frQuantityCredit.Quantity := QuantityCredit;
  end;
end;

procedure TfrEntryEditFrame.beDebitBtnOnClick(Sender: TObject);
begin
  if FAccountPopupMenu = nil then
  begin
    FAccountPopupMenu := TAccountPopupMenu.Create(self);
    FAccountPopupMenu.OnClickAccount := ClickAccount;
    FAccountPopupMenu.OnClickAccountCycle := ClickAccountCicle;
    FAccountPopupMenu.OnClickExpr := ClickExpr;
  end;

  beClick(Sender, FAccountPopupMenu);
end;

procedure TfrEntryEditFrame.beDebitChange(Sender: TObject);
begin
  FDebit := 0;
end;

procedure TfrEntryEditFrame.beDebitExit(Sender: TObject);
begin
  if not MainFunction.CheckAccount(TBtnEdit(Sender).Text, FDebit) then
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(TWinControl(Sender).Handle);
  end else
  begin
    frDAnalytics.AccountKey := FDebit;
    frDAnalytics.UpdateAnalytics;
  end;
end;

procedure TfrEntryEditFrame.beCreditChange(Sender: TObject);
begin
  FCredit := 0;
end;

procedure TfrEntryEditFrame.beCreditExit(Sender: TObject);
begin
  if not MainFunction.CheckAccount(TBtnEdit(Sender).Text, FCredit) then
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(TWinControl(Sender).Handle);
  end else
  begin
    frCAnalytics.AccountKey := FCredit;
    frCAnalytics.UpdateAnalytics;
  end;
end;

procedure TfrEntryEditFrame.beAnalDebitBtnOnClick(Sender: TObject);
begin
  if FAnalPopupMenu = nil then
  begin
    FAnalPopupMenu := TAnalPopupMenu.Create(self);
    FAnalPopupMenu.OnClickAnal := ClickAnal;
    FAnalPopupMenu.OnClickAnalCycle := ClickAnalCycle;
    FAnalPopupMenu.OnExpr := ClickExpr 
  end;
  beClick(Sender, FAnalPopupMenu);
end;

procedure TfrEntryEditFrame.beSumBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TfrEntryEditFrame.ClickExpr(Sender: TObject);
begin
  FActiveEdit.Text := FBlock.EditExpression(FActiveEdit.Text, FBlock);
end;

procedure TfrEntryEditFrame.beCurrBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmCurr);
end;

procedure TfrEntryEditFrame.beCurrChange(Sender: TObject);
begin
  FCurrKey := 0;
end;

procedure TfrEntryEditFrame.pmCurrPopup(Sender: TObject);
var
  MI: TMenuItem;
begin
  pmCurr.Items.Clear;
  MI := TMenuItem.Create(pmCurr);
  MI.Caption := RUS_CURR;
  MI.OnClick := ClickCurrency;
  pmCurr.Items.Add(MI);

  MI := TMenuItem.Create(pmCurr);
  MI.Caption := RUS_EXPRESSION;
  MI.OnClick := ClickExpression;
  pmCurr.Items.Add(MI);
end;

procedure TfrEntryEditFrame.ClickCurrency(Sender: TObject);
var
  F: TatRelationField;
  D: TfrmAnalyticSel;
begin
  if FActiveEdit <> nil then
  begin
    F := atDatabase.FindRelationField(AC_ENTRY, fnCurrKey);
    if F <> nil then
    begin
      D := TfrmAnalyticSel.Create(nil);
      try
        D.DataField := F;
        if FCurrKey > 0 then
          D.AnalyticsKey := FCurrKey;
          
        if D.ShowModal = mrOk then
        begin
          FActiveEdit.Text := D.AnalyticAlias;
          FCurrKey := D.AnalyticsKey;
        end;
      finally
        D.Free;
      end;
    end;
  end;
end;

procedure TfrEntryEditFrame.ClickExpression(Sender: TObject);
begin
  FActiveEdit.Text :=  FBlock.EditExpression(FActiveEdit.Text, FBlock);
end;

end.
