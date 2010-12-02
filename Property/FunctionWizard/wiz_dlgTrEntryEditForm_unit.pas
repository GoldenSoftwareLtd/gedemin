unit wiz_dlgTrEntryEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_DLGEDITFROM_UNIT, ActnList, StdCtrls, ComCtrls, ExtCtrls, BtnEdit, IBSQL,
  gsIBLookupComboBox, wiz_FunctionBlock_unit, Menus, gdcBase, gdcBaseInterface,
  gdcConstants, gdcClasses, wiz_Strings_unit, contnrs, at_Classes, Math,
  wiz_DocumentInfo_unit, AcctUtils, wiz_frAnalyticLine_unit, TB2Dock,
  TB2Toolbar, TB2Item, gdc_frmAnalyticsSel_unit, wiz_dlgQunatyForm_unit;

type
  TdlgTrEntryEditForm = class(TBlockEditForm)
    lblAccountTypeTitle: TLabel;
    lblNCUSumm: TLabel;
    lAccount: TLabel;
    lblCurrTitle: TLabel;
    lblCURRSum: TLabel;
    tsAnalytics: TTabSheet;
    tsQuantity: TTabSheet;
    rbDebit: TRadioButton;
    rbCredit: TRadioButton;
    beSum: TBtnEdit;
    beSumCurr: TBtnEdit;
    beAccount: TBtnEdit;
    pmAccount: TPopupMenu;
    sbAnalytics: TScrollBox;
    actAddQuantity: TAction;
    actDeleteQuantity: TAction;
    actEditQuantity: TAction;
    lvQuantity: TListView;
    beCurr: TBtnEdit;
    pmCurr: TPopupMenu;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    procedure beAccountBtnOnClick(Sender: TObject);
    procedure pmAccountPopup(Sender: TObject);
    procedure beSumBtnOnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure beAccountExit(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure pmCurrPopup(Sender: TObject);
    procedure beCurrBtnOnClick(Sender: TObject);
    procedure beAccountChange(Sender: TObject);
    procedure actAddQuantityExecute(Sender: TObject);
    procedure actEditQuantityExecute(Sender: TObject);
    procedure actEditQuantityUpdate(Sender: TObject);
    procedure actDeleteQuantityExecute(Sender: TObject);
    procedure lvQuantityDblClick(Sender: TObject);
    procedure beCurrChange(Sender: TObject);
  private
    { Private declarations }
    FDocumentHead: TDocumentInfo;
    FDocumentLine: TDocumentLineInfo;
    FAccountKey: Integer;
    FAvailAnalyticFields: TList;
    FAccountAnalyticFields: TList;
    FAnalyticLines: TObjectList;

    FCurrKey: Integer;

    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);
    procedure ClickDocumentAccount(Sender: TObject);

    procedure ClickCurrency(Sender: TObject);
    procedure ClickDocumentCurrency(Sender: TObject);

    procedure CheckDocumentInfo;
    function CheckAccount: boolean;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    procedure UpdateControls;
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  dlgTrEntryEditForm: TdlgTrEntryEditForm;

implementation
uses gdc_frmAccountSel_unit;
const
  DefaultDocumentTypeIndex = 0;
{$R *.DFM}

{ TdlgTrEntryEditForm }

function TdlgTrEntryEditForm.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
    Result := beAccount.Text > '';

  if Result  then
    Result := (Trim(beSum.Text) > '') or ((Trim(beSumCurr.Text) > '') and
      (beCurr.Text > ''));
end;

procedure TdlgTrEntryEditForm.SaveChanges;
var
  I: Integer;
  S: TStrings;
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

      Analytics := '';
      if FAnalyticLines.Count > 0 then
      begin
        S := TStringList.Create;
        try
          for I := 0 to FAnalyticLines.Count - 1 do
          begin
            if TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text > '' then
            begin
              if (TfrAnalyticLine(FAnalyticLines[I]).Field.ReferencesField <> nil) and
                (TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey > 0) then
              begin
                S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
                  '=' + gdcBaseManager.GetRUIDStringById(TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey))
              end else
                S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
                  '=' + TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text);
            end;
          end;
          Analytics := S.Text;
        finally
          S.Free;
        end;
      end;

      Quantity := '';
      if lvQuantity.Items.Count > 0 then
      begin
        S := TStringList.Create;
        try
          for I := 0 to lvQuantity.Items.Count - 1 do
          begin
            S.Add(lvQuantity.Items[I].SubItems[1] + '=' +
              lvQuantity.Items[I].SubItems[0]);
          end;
          Quantity := S.Text;
        finally
          S.Free;
        end;
      end;
    end;
  end;
end;

procedure TdlgTrEntryEditForm.SetBlock(const Value: TVisualBlock);
var
  S: TStrings;
  I, J: Integer;
  FieldName: String;
  ID: Integer;
  SQL: TIBSQL;
  QName, Q, QScript: string;
  LI: TListItem;
begin
  inherited;
  if FBlock is TTrEntryPositionBlock then
  begin
    with Value as TTrEntryPositionBlock do
    begin
      beAccount.Text := SetAccount(Account, FAccountKey);

      rbDebit.Checked :=  AccountPart = 'D';
      rbCredit.Checked := not rbDebit.Checked;
      beSum.Text := SumNCU;

      FCurrKey := 0;
      if CheckRUID(CurrRUID) then
      begin
        FCurrKey := gdcBaseManager.GetIDByRUIDString(CurrRUID);
        beCurr.Text := GetCurrNameById(FCurrKey);
      end else
        beCurr.Text := CurrRUID;
        
      beSumCurr.Text := SumCurr;
      UpdateControls;
      if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
      begin
        SQL := TIBSQL.Create(nil);
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        S := TStringList.Create;
        try
          S.Text := Analytics;
          for I := 0 to S.Count - 1 do
          begin
            FieldName := S.Names[I];
            for J := 0 to FAnalyticLines.Count - 1 do
            begin
              if TfrAnalyticLine(FAnalyticLines[J]).Field.FieldName = FieldName then
              begin
                id := 0;
                if TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField <> nil then
                begin
                  try
                    id := gdcBaseManager.GetIDByRUIDString(S.Values[FieldName]);
                  except
                    Id := 0;
                  end;
                end;

                if id > 0 then
                begin
                  SQL.SQl.Text := Format('SELECT %s FROM %s WHERE %s = %d',
                    [TfrAnalyticLine(FAnalyticLines[J]).Field.References.ListField.FieldName,
                    TfrAnalyticLine(FAnalyticLines[J]).Field.References.RelationName,
                    TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField.FieldName,
                    id]);
                  SQL.ExecQuery;
                  try
                    TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := SQL.Fields[0].AsString;
                    TfrAnalyticLine(FAnalyticLines[J]).AnalyticKey := Id;
                  finally
                    SQL.Close;
                  end;
                end else
                  TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := S.Values[FieldName];
              end;
            end;
          end;
        finally
          S.Free;
          SQL.Free;
        end;
      end;

      lvQuantity.Items.BeginUpdate;
      try
        lvQuantity.Items.Clear;
        S := TStringList.Create;
        try
          S.Text := Quantity;
          for I := 0 to S.Count - 1 do
          begin
            QScript := S.Names[i];
            QName := QScript;
            Q := S.Values[QName];
            try
              id := gdcBaseManager.GetIdByRUIDString(QScript);
            except
              id := 0;
            end;

            if id > 0 then
            begin
              SQL := TIBSQl.Create(nil);
              try
                SQL.Transaction := gdcBaseManager.ReadTransaction;
                SQL.SQl.Text := 'SELECT name FROM gd_value WHERE id = :id';
                SQL.ParamByName(fnId).AsInteger := id;
                SQL.ExecQuery;
                if SQl.RecordCount > 0 then
                  QName := SQL.FieldByName(fnNAme).AsString;
              finally
                SQL.Free;
              end;
            end;

            LI := lvQuantity.Items.Add;
            Li.Caption := QName;
            LI.SubItems.Add(Q);
            LI.SubItems.Add(QScript);
          end;
        finally
          S.Free;
        end;
      finally
        lvQuantity.Items.EndUpdate;
      end;
    end;
  end;
end;

procedure TdlgTrEntryEditForm.beAccountBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmAccount);
end;

procedure TdlgTrEntryEditForm.ClickAccount(Sender: TObject);
var
 S: string;
 RUID: string;
begin
  if FActiveEdit <> nil then
  begin
    S := FActiveEdit.Text;
    try
      Ruid := gdcBaseManager.GetRUIDStringById(FAccountKey);
    except
      Ruid := '';
    end;
    if MainFunction.OnClickAccount(S, RUID) then
    begin
      FActiveEdit.Text := S;
      try
        FAccountKey := gdcBaseManager.GetIdByRUIDString(RUID);
      except
        FAccountKey := 0;
      end;
      UpdateControls;
    end;
  end;
end;

procedure TdlgTrEntryEditForm.ClickAccountCicle(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TAccountCycleBlock(TMenuItem(Sender).Tag).BlockName + '.Account';
    FAccountKey := 0;
    UpdateControls;
  end;
end;

procedure TdlgTrEntryEditForm.ClickDocumentAccount(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
    FAccountKey := 0;
    UpdateControls;
  end;
end;

procedure TdlgTrEntryEditForm.CheckDocumentInfo;
begin
  Assert((MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock), 'Ошибочный тип основной функции');

  FDocumentHead := TTrEntryFunctionBlock(MainFunction).DocumentHead;

  FDocumentLine := TTrEntryFunctionBlock(MainFunction).DocumentLine
end;

procedure TdlgTrEntryEditForm.pmAccountPopup(Sender: TObject);
var
  I: Integer;
  List: TList;
  DF: TDocumentField;
  MI: TMenuItem;
begin
  FillAccountMenuItem(pmAccount, pmAccount.Items, ClickAccount, ClickAccountCicle);
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

procedure TdlgTrEntryEditForm.beSumBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TdlgTrEntryEditForm.UpdateControls;
var
  I, J: Integer;
  SQL: TIBSQL;
  SelectClause: string;
  Line: TfrAnalyticLine;
  W, T: Integer;
  Lines: TObjectList;
begin
  if FAvailAnalyticFields = nil then
  begin
    FAvailAnalyticFields := TList.Create;
    GetAnalyticsFields(FAvailAnalyticFields);
  end;

  if FAccountAnalyticFields = nil then
    FAccountAnalyticFields := TList.Create;

  FAccountAnalyticFields.Clear;

  FAccountKey := GetAccountKeyByAlias(beAccount.Text,
    gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID));

  if FAccountKey = 0 then
  begin
    for I := 0 to FAvailAnalyticFields.Count - 1 do
    begin
      FAccountAnalyticFields.Add(FAvailAnalyticFields[i]);
    end;
  end else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      SelectClause := '';
      for I := 0 to FAvailAnalyticFields.Count - 1 do
      begin
        if SelectClause > '' then
          SelectClause := SelectClause + ',';
        SelectClause := SelectClause + Format('Sum(a.%s) AS %s',
          [TatRelationField(FAvailAnalyticFields[I]).FieldName,
          TatRelationField(FAvailAnalyticFields[I]).FieldName]);
      end;

      if SelectClause > '' then
      begin
        { TODO : Нужно подумать с планом счетов }
        SQL.SQL.Text := Format('SELECT %s FROM ac_account a JOIN ac_account c ' +
          ' ON c.lb <= a.lb AND c.rb >= c.rb AND c.accounttype = ''C'' WHERE a.id = %d '+
          ' AND c.id = %d', [SelectClause, FAccountKey,
          gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID)]);
        SQL.ExecQuery;
        if SQL.RecordCount > 0 then
        begin
          for I := 0 to SQL.Current.Count - 1 do
          begin
            if SQL.Current[I].AsInteger > 0 then
            begin
              for J := 0 to FAvailAnalyticFields.Count - 1 do
              begin
                if TatRelationField(FAvailAnalyticFields[J]).FieldName = SQL.Current[I].Name then
                begin
                  FAccountAnalyticFields.Add(FAvailAnalyticFields[J]);
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      SQL.Free;
    end;
  end;

  if FAnalyticLines = nil then
    FAnalyticLines := TObjectList.Create;

  Lines := TobjectList.Create;
  try
    for i := FAnalyticLines.Count - 1 downto 0 do
    begin
      Line := TfrAnalyticLine(FAnalyticLines[i]);
      FAnalyticLines.Extract(Line);
      Lines.Add(Line);
      Line.Parent := nil;
    end;
    FAnalyticLines.Clear;

    W := 0;
    for I := 0 to FAccountAnalyticFields.Count - 1 do
    begin
      Line := nil;
      for J := Lines.Count - 1 downto 0 do
      begin
        if TfrAnalyticLine(Lines[J]).Field = TatRelationField(FAccountAnalyticFields[I]) then
        begin
          Line := TfrAnalyticLine(Lines[J]);
          Lines.Extract(Line);
          FAnalyticLines.Add(Line);
        end;
      end;

      if Line = nil then
      begin
        Line := TfrAnalyticLine.Create(nil);
        FAnalyticLines.Add(Line);
        Line.Field := TatRelationField(FAccountAnalyticFields[I]);
        Line.Block := FBlock;
      end;
      Line.Parent := sbAnalytics;
      W := Max(W, Line.lName.Width + Line.lName.Left);
    end;

    T := 0;
    for i := 0 to FAnalyticLines.Count - 1 do
    begin
      Line := TfrAnalyticLine(FAnalyticLines[i]);
      Line.Top := T;
      Line.TabOrder := i;
      Line.eAnalytic.Left := W + 3;
      Line.eAnalytic.Width := Line.Width - Line.eAnalytic.Left - 3;
      T := Line.Height + T;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TdlgTrEntryEditForm.FormDestroy(Sender: TObject);
begin
  FAvailAnalyticFields.Free;
  FAnalyticLines.Free;
  FAccountAnalyticFields.Free;
  
  inherited;
end;

procedure TdlgTrEntryEditForm.beAccountExit(Sender: TObject);
begin
  if CheckAccount then
    UpdateControls
  else
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(beAccount.Handle);
  end;
end;

procedure TdlgTrEntryEditForm.PageControlChanging(Sender: TObject;
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

function TdlgTrEntryEditForm.CheckAccount: boolean;
begin
  Result := MainFunction.CheckAccount(beAccount.Text, FAccountKey);
end;

procedure TdlgTrEntryEditForm.ClickCurrency(Sender: TObject);
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

procedure TdlgTrEntryEditForm.ClickDocumentCurrency(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
    FCurrKey := 0;
  end;
end;

procedure TdlgTrEntryEditForm.pmCurrPopup(Sender: TObject);
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

procedure TdlgTrEntryEditForm.beCurrBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmCurr);
end;

procedure TdlgTrEntryEditForm.beAccountChange(Sender: TObject);
begin
  FAccountKey := 0;
end;

procedure TdlgTrEntryEditForm.actAddQuantityExecute(Sender: TObject);
var
  D: TdlgQuantiyForm;
  LI: TListItem;
begin
  D := TdlgQuantiyForm.Create(nil);
  try
    D.QUnit := '';
    D.Quantity := '';
    D.Block := FBlock;
    if D.ShowModal = mrOk then
    begin
      LI := lvQuantity.Items.Add;
      LI.Caption := D.UnitName;
      LI.SubItems.Add(D.Quantity);
      LI.SubItems.Add(D.QUnit);
    end;
  finally
    D.Free;
  end;
end;

procedure TdlgTrEntryEditForm.actEditQuantityExecute(Sender: TObject);
var
  D: TdlgQuantiyForm;
  LI: TListItem;
begin
  if lvQuantity.Selected <> nil then
  begin
    Li := lvQuantity.Selected;
    D := TdlgQuantiyForm.Create(nil);
    try
      D.QUnit := LI.SubItems[1];
      D.Quantity := LI.SubItems[0];
      D.Block := FBlock;
      if D.ShowModal = mrOk then
      begin
        LI.Caption := D.UnitName;
        LI.SubItems[0] := D.Quantity;
        LI.SubItems[1] := D.QUnit;
      end;
    finally
      D.Free;
    end;
  end;
end;

procedure TdlgTrEntryEditForm.actEditQuantityUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvQuantity.Selected <> nil;
end;

procedure TdlgTrEntryEditForm.actDeleteQuantityExecute(Sender: TObject);
var
  Index: Integer;
begin
  if lvQuantity.Selected <> nil then
  begin
    Index := lvQuantity.Selected.Index;
    lvQuantity.Selected.Delete;
    if Index > lvQuantity.Items.Count then
      lvQuantity.Selected := lvQuantity.Items[lvQuantity.Items.Count - 1]
    else
      lvQuantity.Selected := lvQuantity.Items[Index]
  end;
end;

procedure TdlgTrEntryEditForm.lvQuantityDblClick(Sender: TObject);
begin
  actEditQuantity.Execute;
end;

procedure TdlgTrEntryEditForm.beCurrChange(Sender: TObject);
begin
  FCurrKey := 0;
end;

end.
