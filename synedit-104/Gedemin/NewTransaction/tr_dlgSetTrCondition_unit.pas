unit tr_dlgSetTrCondition_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Db, IBCustomDataSet, dmDatabase_unit, Grids, DBGrids,
  ActnList, IBSQL, gsIBLookupComboBox, at_classes;

type
  TdlgSetTrCondition = class(TForm)
    tvRelations: TTreeView;
    Button1: TButton;
    Button2: TButton;
    ibdsFields_old: TIBDataSet;
    dsFields: TDataSource;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNewValue: TAction;
    actEditValue: TAction;
    actDelValue: TAction;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label4: TLabel;
    gsiblcDocumentType: TgsIBLookupComboBox;
    ibdsFields: TIBDataSet;
    ibsqlCondition: TIBSQL;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actNewValueExecute(Sender: TObject);
    procedure actEditValueExecute(Sender: TObject);
    procedure actDelValueExecute(Sender: TObject);
    procedure actEditValueUpdate(Sender: TObject);
    procedure actDelValueUpdate(Sender: TObject);
    procedure actNewValueUpdate(Sender: TObject);
    procedure gsiblcDocumentTypeChange(Sender: TObject);
  private
    { Private declarations }
    FTransactionKey: Integer;
    FDocumentTypeKey: Integer;
    procedure MakeTree;
    function Save: Boolean;
  public
    { Public declarations }
    procedure SetupDialog(const aTransactionKey: Integer);
  end;

var
  dlgSetTrCondition: TdlgSetTrCondition;

implementation

{$R *.DFM}

{ TdlgSetTrCondition }

uses tr_TransactionType_unit, tr_dlgSetCondValue_unit;

procedure TdlgSetTrCondition.MakeTree;
var
  TRNode, ParentNode, FieldNode: TTreeNode;

  Condition: TCondition;
  FieldCondition: TFieldCondition;
  RelationCondition: TRelationCondition;
  R: TatRelation;
  i: Integer;
  ReferencyName, ReferencyListName: String;

function SearchNode(const aRelationName, aFieldName: String): TTreeNode;
var
  i: Integer;
begin
  Result := nil;
  for i:= 0 to tvRelations.Items.Count - 1 do
  begin
    if Assigned(tvRelations.Items[i].Data) and (TObject(tvRelations.Items[i].Data) is TFieldCondition)
    then
    begin
      if Assigned(tvRelations.Items[i].Parent) and Assigned(tvRelations.Items[i].Parent.Data) and
         (TObject(tvRelations.Items[i].Parent.Data) is TRelationCondition) and
         (TRelationCondition(tvRelations.Items[i].Parent.Data).RelationName = aRelationName) and
         (TFieldCondition(tvRelations.Items[i].Data).FieldName = aFieldName)
      then
      begin
        Result := tvRelations.Items[i];
        Break;
      end;
    end;
  end;
end;

begin
  ibdsFields.Params.ByName('trtypekey').AsInteger := FTransactionKey;
  ibdsFields.Params.ByName('documenttype').AsInteger := FDocumentTypeKey;
  ibdsFields.Open;

  ParentNode := nil;
  ibdsFields.First;
  while not ibdsFields.EOF do
  begin
    R := atDatabase.Relations.ByRelationName(ibdsFields.FieldByName('relationname').AsString);
    if Assigned(R) then
    begin
      ParentNode := tvRelations.Items.Add(ParentNode, R.LName);
      RelationCondition := TRelationCondition.Create(R.RelationName, R.LShortName);
      ParentNode.Data := RelationCondition;

      for i:= 0 to R.RelationFields.Count - 1 do
      begin
        FieldNode := tvRelations.Items.AddChild(ParentNode,
           R.RelationFields[i].LName);

        if Assigned(R.RelationFields[i].References) then
          ReferencyName := R.RelationFields[i].References.RelationName
        else
          ReferencyName := '';

        if Assigned(R.RelationFields[i].ReferenceListField) then
          ReferencyListName := R.RelationFields[i].ReferenceListField.FieldName
        else
          ReferencyListName := '';

        FieldCondition := TFieldCondition.Create(R.RelationFields[i].FieldName,
          R.RelationFields[i].Field.FieldName,
          ReferencyName, ReferencyListName);
        FieldNode.Data := FieldCondition;
      end;
    end;
    ibdsFields.Next;
  end;
  ibdsFields.Close;

  ibsqlCondition.ParamByName('tk').AsInteger := FTransactionKey;
  ibsqlCondition.ParamByName('dk').AsInteger := FDocumentTypeKey;
  ibsqlCondition.ExecQuery;
  while not ibsqlCondition.EOF do
  begin
    FieldNode := SearchNode(ibsqlCondition.FieldByName('relationname').AsString,
      ibsqlCondition.FieldByName('fieldname').AsString);
    if Assigned(FieldNode) then
    begin
      TRNode := tvRelations.Items.AddChild(FieldNode,
         ibsqlCondition.FieldByName('valuetext').AsString);
      Condition := TCondition.Create(ibsqlCondition.FieldByName('valuetext').AsString, '');
      TRNode.Data := Condition;
    end;
    ibsqlCondition.Next;
  end;
  ibsqlCondition.Close;
end;

procedure TdlgSetTrCondition.SetupDialog(const aTransactionKey: Integer);
begin
  FTransactionKey := aTransactionKey;
  FDocumentTypeKey := -1;
  gsiblcDocumentType.Condition := Format('TRTYPE_KEY = %d', [FTransactionKey]);
  MakeTree;
end;

procedure TdlgSetTrCondition.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

function TdlgSetTrCondition.Save: Boolean;
var
  i: Integer;
  ibsql: TIBSQL;
begin
  Result := True;
  if gsiblcDocumentType.CurrentKey > '' then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ibdsFields.Transaction;
      ibsql.SQL.Text := Format('DELETE FROM GD_LISTTRTYPECOND WHERE listtrtypekey = %d',
        [FTransactionKey]);
      try
        ibsql.ExecQuery;
      except
        Result := False;
        exit;
      end;

      for i:= 0 to tvRelations.Items.Count - 1 do
      begin
        if tvRelations.Items[i].Level = 2 then
        begin
          ibsql.SQL.Text := Format(
            'INSERT INTO GD_LISTTRTYPECOND (listtrtypekey, documenttypekey, relationname, ' +
            'fieldname, valuetext) VALUES(%d, %d, ''%s'', ''%s'', ''%s'')',
            [FTransactionKey,
             StrToInt(gsiblcDocumentType.CurrentKey),
             TRelationCondition(tvRelations.Items[i].Parent.Parent.Data).RelationName,
             TFieldCondition(tvRelations.Items[i].Parent.Data).FieldName,
             TCondition(tvRelations.Items[i].Data).Value]);
          ibsql.ExecQuery;
        end;
      end;

      ibsql.Transaction.CommitRetaining;

    finally
      ibsql.Free;
    end;
  end;
end;


procedure TdlgSetTrCondition.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgSetTrCondition.actNewValueExecute(Sender: TObject);
var
  TreeNode: TTreeNode;
  ibsqlFieldInfo: TIBSQL;
begin
  { Добавление нового условия }
  if Assigned(tvRelations.Selected) and Assigned(tvRelations.Selected.Data)
  then
  begin
    ibsqlFieldInfo := TIBSQL.Create(Self);
    with TdlgSetCondValue.Create(Self) do
      try
        ibsqlFieldInfo.Transaction := ibdsFields.Transaction;
        ibsqlFieldInfo.SQL.Text :=
            Format('SELECT * FROM RDB$FIELDS RF WHERE RF.RDB$field_name = ''%s''',
              [TFieldCondition(tvRelations.Selected.Data).FieldSource]);

        ibsqlFieldInfo.ExecQuery;

        SetupDialog(
          ibsqlFieldInfo.FieldByName('RDB$FIELD_TYPE').AsInteger,
          TFieldCondition(tvRelations.Selected.Data).ReferencyName,
          TFieldCondition(tvRelations.Selected.Data).ReferencyField, '');
        if ShowModal = mrOK
        then
        begin
          TreeNode := tvRelations.Items.AddChild(tvRelations.Selected, TextValue);
          TreeNode.Data := TCondition.Create(Value, TextValue);
          tvRelations.Selected := TreeNode;
        end;
      finally
        ibsqlFieldInfo.Close;
        ibsqlFieldInfo.Free;
        Free;
      end;
  end;
end;

procedure TdlgSetTrCondition.actEditValueExecute(Sender: TObject);
var
  ibsqlFieldInfo: TIBSQL;
begin
  { Изменение существующего условия }
  if Assigned(tvRelations.Selected) and Assigned(tvRelations.Selected.Data) and
     Assigned(tvRelations.Selected.Parent) and Assigned(tvRelations.Selected.Parent.Data)
  then
  begin
    ibsqlFieldInfo := TIBSQL.Create(Self);
    with TdlgSetCondValue.Create(Self) do
      try
        ibsqlFieldInfo.Transaction := ibdsFields.Transaction;
        ibsqlFieldInfo.SQL.Text :=
          Format('SELECT * FROM RDB$FIELDS RF WHERE RF.RDB$field_name = ''%s''',
            [TFieldCondition(tvRelations.Selected.Parent.Data).FieldSource]);

        ibsqlFieldInfo.ExecQuery;
        SetupDialog(
          ibsqlFieldInfo.FieldByName('RDB$FIELD_TYPE').AsInteger,
          TFieldCondition(tvRelations.Selected.Parent.Data).ReferencyName,
          TFieldCondition(tvRelations.Selected.Parent.Data).ReferencyField,
          TCondition(tvRelations.Selected.Data).Value);
        if ShowModal = mrOK
        then
        begin
          tvRelations.Selected.Text := TextValue;
          TCondition(tvRelations.Selected.Data).Value := Value;
        end;
      finally
        ibsqlFieldInfo.Close;
        ibsqlFieldInfo.Free;
        Free;
      end;
  end;
end;

procedure TdlgSetTrCondition.actDelValueExecute(Sender: TObject);
begin
  { Удаление условия }
  if Assigned(tvRelations.Selected) and (tvRelations.Selected.Level >= 2)
  then
  begin
    if MessageBox(HANDLE, PChar(Format('Удалить условие ''%s''?', [tvRelations.Selected.Text])),
      'Внимание', mb_YesNo or
        mb_IconQuestion) = idYes
    then
      tvRelations.Selected.Delete;
  end;
end;

procedure TdlgSetTrCondition.actEditValueUpdate(Sender: TObject);
begin
  actEditValue.Enabled := Assigned(tvRelations.Selected) and (tvRelations.Selected.Level >= 2);
end;

procedure TdlgSetTrCondition.actDelValueUpdate(Sender: TObject);
begin
  actDelValue.Enabled := Assigned(tvRelations.Selected) and (tvRelations.Selected.Level >= 2);
end;

procedure TdlgSetTrCondition.actNewValueUpdate(Sender: TObject);
begin
  actNewValue.Enabled := Assigned(tvRelations.Selected) and (tvRelations.Selected.Level = 1);
end;

procedure TdlgSetTrCondition.gsiblcDocumentTypeChange(Sender: TObject);
begin
  if (gsiblcDocumentType.CurrentKey > '') and
     (StrToInt(gsiblcDocumentType.CurrentKey) <> FDocumentTypeKey)
  then
  begin
    FDocumentTypeKey := StrToInt(gsiblcDocumentType.CurrentKey);
    MakeTree;
  end;
end;

end.

