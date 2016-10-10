unit wiz_TrPosEntryEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ActnList, Menus, BtnEdit, wiz_FunctionBlock_unit, gdcBase, gdcBaseInterface,
  gdcConstants, gdcClasses, wiz_Strings_unit, contnrs,
  at_Classes, wiz_frAnalyticLine_unit, Math,
  wiz_DocumentInfo_unit, AcctUtils, IBSQL,
  gdc_frmAnalyticsSel_unit, wiz_dlgQunatyForm_unit, ExtCtrls,
  wiz_frAnalytics_unit, wiz_frQuantity_unit;

type
  TfrTrPosEntryEditFrame = class(TfrEditFrame)
    lAccount: TLabel;
    beAccount: TBtnEdit;
    lblAccountTypeTitle: TLabel;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
    lblNCUSumm: TLabel;
    beSum: TBtnEdit;
    lblCurrTitle: TLabel;
    beCurr: TBtnEdit;
    lblCURRSum: TLabel;
    beSumCurr: TBtnEdit;
    tsAnalytics: TTabSheet;
    tsQuantity: TTabSheet;
    pmCurr: TPopupMenu;
    pmAccount: TPopupMenu;
    frAnalytics: TfrAnalytics;
    frQuantity: TfrQuantity;
    Label3: TLabel;
    beSumEQ: TBtnEdit;
    procedure beAccountBtnOnClick(Sender: TObject);
    procedure beAccountChange(Sender: TObject);
    procedure beAccountExit(Sender: TObject);
    procedure beSumBtnOnClick(Sender: TObject);
    procedure beCurrBtnOnClick(Sender: TObject);
    procedure beCurrChange(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure pmCurrPopup(Sender: TObject);
    procedure pmAccountPopup(Sender: TObject);
    procedure rbDebitClick(Sender: TObject);
    procedure rbCreditClick(Sender: TObject);
    procedure beAccountKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FDocumentHead: TDocumentInfo;
    FDocumentLine: TDocumentLineInfo;
    FAccountKey: Integer;
    FAvailAnalyticFields: TList;
    FAccountAnalyticFields: TList;
    FAnalyticLines: TObjectList;
    FLoadBlock: Boolean;
    FCurrKey: Integer;
  protected
    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);
    procedure ClickDocumentAccount(Sender: TObject);
    procedure ClickExpression(Sender: TObject);

    procedure ClickCurrency(Sender: TObject);
    procedure ClickDocumentCurrency(Sender: TObject);

    procedure CheckDocumentInfo;
    function CheckAccount: boolean;

    procedure SetBlock(const Value: TVisualBlock); override;
    procedure UpdateControls;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frTrPosEntryEditFrame: TfrTrPosEntryEditFrame;

implementation
uses gdc_frmAccountSel_unit;
{$R *.DFM}

{ TfrTrEntryEditFrame }

constructor TfrTrPosEntryEditFrame.Create(AOwner: TComponent);
begin
  inherited;
  FLoadBlock := False;
end;

function TfrTrPosEntryEditFrame.CheckAccount: boolean;
begin
  Result := MainFunction.CheckAccount(beAccount.Text, FAccountKey);
end;

procedure TfrTrPosEntryEditFrame.CheckDocumentInfo;
begin
  Assert((MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock), 'Ошибочный тип основной функции');

  FDocumentHead := TTrEntryFunctionBlock(MainFunction).DocumentHead;

  FDocumentLine := TTrEntryFunctionBlock(MainFunction).DocumentLine
end;

function TfrTrPosEntryEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := beAccount.Text > '';
    if not Result then
    begin
      ShowCheckOkMessage(Format('Неуказан счет для %s', [BlockCaption]))
    end;
  end;

  if Result  then
  begin
    Result := (Trim(beSum.Text) > '') or ((Trim(beSumCurr.Text) > '') and
      (beCurr.Text > '')) or (Trim(beSumEQ.Text) > '');
    if not Result then
    begin
      ShowCheckOkMessage(Format('Неуказана сумма для %s', [BlockCaption]));
    end;
  end;
end;

procedure TfrTrPosEntryEditFrame.ClickAccount(Sender: TObject);
var
 S: string;
 RUID: String;
begin
  if FActiveEdit <> nil then
  begin
    S := FActiveEdit.Text;

    if FAccountKey > 0 then
      RUID := gdcBaseManager.GetRUIDStringById(FAccountKey)
    else
      RUID := '';

    if MainFunction.OnClickAccount(S, RUID) then
    begin
      FActiveEdit.Text := S;
      try
        if CheckRuid(RUID) then
        begin
          FAccountKey := gdcBaseManager.GetIdByRUIDString(RUID)
        end else
        begin
          FActiveEdit.Text := RUID;
          FAccountKey := 0;
        end;
      except
        FActiveEdit.Text := RUID;
        FAccountKey := 0;
      end;
      UpdateControls;
    end;
  end;
end;

procedure TfrTrPosEntryEditFrame.ClickAccountCicle(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TAccountCycleBlock(TMenuItem(Sender).Tag).BlockName + '.Account';
    FAccountKey := 0;
    UpdateControls;
  end;
end;

procedure TfrTrPosEntryEditFrame.ClickCurrency(Sender: TObject);
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

procedure TfrTrPosEntryEditFrame.ClickDocumentAccount(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
    FAccountKey := 0;
    UpdateControls;
  end;
end;

procedure TfrTrPosEntryEditFrame.ClickDocumentCurrency(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
    FCurrKey := 0;
  end;
end;

destructor TfrTrPosEntryEditFrame.Destroy;
begin
  FAvailAnalyticFields.Free;
  FAnalyticLines.Free;
  FAccountAnalyticFields.Free;

  inherited;
end;

procedure TfrTrPosEntryEditFrame.SaveChanges;
begin
  inherited;
  if FBlock is TTrEntryPositionBlock then
  begin
    with FBlock as TTrEntryPositionBlock do
    begin
      Account := GetAccount(beAccount.Text, FAccountKey);

      if rbDebit.Checked then AccountPart := 'D';
      if rbCredit.Checked then AccountPart := 'C';
      SumNCU := beSum.Text;
      if FCurrKey > 0 then
        CurrRUID := gdcBaseManager.GetRUIDStringById(FCurrKey)
      else
        CurrRUID := beCurr.Text;
      SumCurr := beSumCurr.Text;
      SumEQ := beSumEQ.Text;
      Analytics := frAnalytics.Analytics;

      Quantity := frQuantity.Quantity;
    end;
  end;
end;

procedure TfrTrPosEntryEditFrame.SetBlock(const Value: TVisualBlock);
var
  ID: Integer;
  LocalName: string;
  A: string;
begin
  LocalName := Value.LocalName;
  frAnalytics.Block := Value;
  inherited;
  if FBlock is TTrEntryPositionBlock then
  begin
    with Value as TTrEntryPositionBlock do
    begin
      FLoadBlock := True;
      try
        frAnalytics.ReadAnalytics := Analytics;
        A := SetAccount(Account, FAccountKey);
        Id := FAccountKey;
        beAccount.Text := A;
        FAccountKey := Id;

        rbDebit.Checked :=  AccountPart = 'D';
        rbCredit.Checked := not rbDebit.Checked;
        beSum.Text := SumNCU;

        FCurrKey := 0;
        if CheckRUID(CurrRUID) then
        begin
          Id := gdcBaseManager.GetIDByRUIDString(CurrRUID);
          beCurr.Text := GetCurrNameById(ID);
          FCurrKey := Id
        end else
          beCurr.Text := CurrRUID;

        beSumCurr.Text := SumCurr;
        beSumEQ.Text := SumEQ;
        UpdateControls;
        frAnalytics.Analytics := Analytics;

        frQuantity.Quantity := Quantity;
        frQuantity.Block := Value;
      finally
        FLoadBlock := False;
      end;
    end;
  end;
  eLocalName.Text := LocalName;
end;

procedure TfrTrPosEntryEditFrame.UpdateControls;
begin
  frAnalytics.AccountKey := FAccountKey;
  frAnalytics.UpdateAnalytics;

  //Изменяем локльное наименование
  if rbDebit.Checked then
    eLocalName.Text := 'Дебет ' + beAccount.Text
  else
    eLocalName.Text := 'Кредит ' + beAccount.Text;

  frQuantity.AccountKey := FAccountKey;  
end;

procedure TfrTrPosEntryEditFrame.beAccountBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmAccount);
end;

procedure TfrTrPosEntryEditFrame.beAccountChange(Sender: TObject);
begin
  FAccountKey := 0;
  if not FLoadBlock then
    frAnalytics.ReadAnalytics := '';
end;                  

procedure TfrTrPosEntryEditFrame.beAccountExit(Sender: TObject);
begin
  if CheckAccount then
    UpdateControls
  else
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(beAccount.Handle);
  end;
end;

procedure TfrTrPosEntryEditFrame.beSumBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TfrTrPosEntryEditFrame.beCurrBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmCurr);

end;

procedure TfrTrPosEntryEditFrame.beCurrChange(Sender: TObject);
begin
  FCurrKey := 0;
end;

procedure TfrTrPosEntryEditFrame.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := PageControl.ActivePage <> tsGeneral;

  if not AllowChange then
  begin
    AllowChange := CheckAccount;
    if not AllowChange then
    begin
      ShowMessage(RUS_INVALIDACCOUNT);
      Windows.SetFocus(beAccount.Handle);
    end;
  end;
end;

procedure TfrTrPosEntryEditFrame.pmCurrPopup(Sender: TObject);
var
  I: Integer;
  List: TList;
  DF: TDocumentField;
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

  MI := TMenuItem.Create(pmCurr);
  MI.Caption := '-';
  pmCurr.Items.Add(MI);

  CheckDocumentInfo;
  List := TList.Create;
  try
    if FDocumentHead <> nil then
      FDocumentHead.ForeignFields(GD_CURR, List);
    if FDocumentLine <> nil then
      FDocumentLine.ForeignFields(GD_CURR, List);
    for I := 0 to List.Count - 1 do
    begin
      DF := TDocumentField(List[I]);

      MI := TMenuItem.Create(pmCurr);
      MI.Caption := DF.DisplayName;
      MI.Tag := Integer(Pointer(DF));
      MI.OnClick := ClickDocumentCurrency;
      pmCurr.Items.Add(MI);
    end;
  finally
    List.Free;
  end;
end;

procedure TfrTrPosEntryEditFrame.pmAccountPopup(Sender: TObject);
var
  I: Integer;
  List: TList;
  DF: TDocumentField;
  MI: TMenuItem;
begin
  FillAccountMenuItem(pmAccount, pmAccount.Items, ClickAccount, ClickAccountCicle, ClickExpression);
  CheckDocumentInfo;
  List := TList.Create;
  try
    if FDocumentHead <> nil then
      FDocumentHead.ForeignFields(AC_ACCOUNT, List);
    if FDocumentLine <> nil then
      FDocumentLine.ForeignFields(AC_ACCOUNT, List);
    for I := 0 to List.Count - 1 do
    begin
      DF := TDocumentField(List[I]);

      MI := TMenuItem.Create(pmAccount);
      MI.Caption := DF.DisplayName;
      MI.Tag := Integer(Pointer(DF));
      MI.OnClick := ClickDocumentAccount;
      pmAccount.Items.Add(MI);
    end;
  finally
    List.Free;
  end;
end;

procedure TfrTrPosEntryEditFrame.rbDebitClick(Sender: TObject);
begin
  inherited;
  UpdateControls
end;

procedure TfrTrPosEntryEditFrame.rbCreditClick(Sender: TObject);
begin
  inherited;
  UpdateControls
end;

procedure TfrTrPosEntryEditFrame.ClickExpression(Sender: TObject);
begin
  FActiveEdit.Text :=  FBlock.EditExpression(FActiveEdit.Text, FBlock);
end;

procedure TfrTrPosEntryEditFrame.beAccountKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key in [#13, #38, #40] then
    Key := #0;
  inherited; 
end;

end.
