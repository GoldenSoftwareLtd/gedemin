unit tr_dlgSetRelAnalyzeAndDocField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gsIBCtrlGrid, IBDatabase, dmDatabase_unit, ActnList, IBSQL, tr_Type_unit;

type
  TdlgSetRelAnalyzeAndDocField = class(TForm)
    Button1: TButton;
    ibdsEntryAnalyzeRel: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsEntryAnalyzeRel: TDataSource;
    Label1: TLabel;
    cbAnalyze: TComboBox;
    Label2: TLabel;
    cbDocumentField: TComboBox;
    Button2: TButton;
    ActionList1: TActionList;
    actNew: TAction;
    actReplace: TAction;
    actDelete: TAction;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    actOk: TAction;
    actCancel: TAction;
    gsibgrEntryAnalyzeRel: TgsIBGrid;
    Label3: TLabel;
    cbDocumentType: TComboBox;
    procedure cbAnalyzeChange(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNewUpdate(Sender: TObject);
    procedure actReplaceUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
  private
    { Private declarations }
    FEntryKey: Integer;
    FAccountKey: Integer;
    FTransactionKey: Integer;
    InTransaction: Boolean;
    procedure SetBeginInfo;
  public
    { Public declarations }
    procedure SetupDialog(const aEntryKey, aTransactionKey, aAccountKey: Integer;
      aTransaction: TIBTransaction);
  end;

var
  dlgSetRelAnalyzeAndDocField: TdlgSetRelAnalyzeAndDocField;

implementation

{$R *.DFM}

uses at_classes;

type
  TLongint = class
    Value: Integer;
    constructor Create(const aValue: Integer);
  end;

constructor TLongint.Create(const aValue: Integer);
begin
  Value := aValue;
end;

{var
  R: TatRelation;
  F: TatRelationField;}
{begin}
{  R := atDatabase.Relations.ByRelationName(ibdsEntryAnalyzeRel.FieldByName('docrealname').AsString);
  if Assigned(R) then
  begin
    ibdsEntryAnalyzeRel.FieldByName('tablename').AsString := R.LName;
    F := R.RelationFields.ByFieldName(ibdsEntryAnalyzeRel.FieldByName('fieldname').AsString);
    if Assigned(F) then
      ibdsEntryAnalyzeRel.FieldByName('fieldname').AsString := F.LName;
  end;}
{  F := atDatabase.FindRelationField('GD_ENTRY',
    ibdsEntryAnalyzeRel.FieldByName('analyzefield').AsString);
  if Assigned(F) then
    ibdsEntryAnalyzeRel.FieldByName('analyzeName').AsString := F.LName;}


procedure TdlgSetRelAnalyzeAndDocField.SetupDialog(const aEntryKey,
  aTransactionKey, aAccountKey: Integer; aTransaction: TIBTransaction);
begin
  FTransactionKey := aTransactionKey;
  FEntryKey := aEntryKey;
  FAccountKey := aAccountKey;
  if Assigned(aTransaction) then
    ibdsEntryAnalyzeRel.Transaction := aTransaction;

  InTransaction := False;
  if not ibdsEntryAnalyzeRel.Transaction.InTransaction then
    ibdsEntryAnalyzeRel.Transaction.StartTransaction
  else
    InTransaction := True;

  SetBeginInfo;
  ibdsEntryAnalyzeRel.Prepare;
  ibdsEntryAnalyzeRel.ParamByName('elk').AsInteger := FEntryKey;
  ibdsEntryAnalyzeRel.Open;
end;

procedure TdlgSetRelAnalyzeAndDocField.SetBeginInfo;
var
  ibsql: TIBSQL;
  i: Integer;
  F: TatRelationField;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := ibdsEntryAnalyzeRel.Transaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_cardaccount WHERE id = :id';
    ibsql.Prepare;
    ibsql.ParamByName('id').AsInteger := FAccountKey;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      for i:= 0 to ibsql.Current.Count - 1 do
      begin
        if (Pos(UserPrefix, ibsql.Fields[i].Name) > 0) and
           (ibsql.Fields[i].AsInteger = 1)
        then
        begin
          F := atDatabase.FindRelationField('GD_ENTRY', ibsql.Fields[i].Name);
          if Assigned(F) and Assigned(F.References) then
            cbAnalyze.Items.AddObject(F.LName, F);
        end;
        ibsql.Next;
      end;
    end;
    ibsql.Close;
    ibsql.SQL.Text := 'SELECT * FROM gd_documenttrtype dt JOIN gd_documenttype d ON ' +
      'dt.documenttypekey = d.id and dt.trtypekey = :tk';
    ibsql.Prepare;
    ibsql.ParamByName('tk').AsInteger := FTransactionKey;
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      cbDocumentType.Items.AddObject(ibsql.FieldByName('Name').AsString,
        TLongint.Create(ibsql.FieldByName('id').AsInteger));
      ibsql.Next;
    end;
    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure TdlgSetRelAnalyzeAndDocField.cbAnalyzeChange(Sender: TObject);
var
  ibsql: TIBSQL;
  R: TatRelation;
  i: Integer;

  function SearchInRel(const aFirst, aSecond: String): Boolean;
  var
    k: Integer;
  begin
    Result := False;
    if Trim(aFirst) = Trim(aSecond) then
    begin
      Result := True;
    end
    else
      for k:= 1 to CountRelationAnalyzeName do
        if (RelationAnalyzeNames[k].FirstName = Trim(aFirst)) and
           (RelationAnalyzeNames[k].SecondName = Trim(aSecond))
        then
        begin
          Result := True;
          Break;
        end;
end;


begin
  if (cbAnalyze.ItemIndex >= 0) and (cbDocumentType.ItemIndex >= 0) then
  begin
    cbDocumentField.Items.Clear;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ibdsEntryAnalyzeRel.Transaction;
      ibsql.SQL.Text := 'SELECT rd.relationname FROM gd_relationtypedoc rd '+
        ' WHERE rd.doctypekey = :dt';
      ibsql.Prepare;
      ibsql.ParamByName('dt').AsInteger :=
        TLongint(cbDocumentType.Items.Objects[cbDocumentType.ItemIndex]).Value;
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        R := atDatabase.Relations.ByRelationName(ibsql.FieldByName('relationname').AsString);
        if Assigned(R) then
        begin
          for i:= 0 to R.RelationFields.Count - 1 do
          begin
            if Assigned(R.RelationFields[i].References) and
               {((R.RelationFields[i].References.RelationName =
               TatRelationField(cbAnalyze.Items.Objects[cbAnalyze.ItemIndex]).References.RelationName) or}
               (SearchInRel(TatRelationField(cbAnalyze.Items.Objects[cbAnalyze.ItemIndex]).References.RelationName,
                R.RelationFields[i].References.RelationName)){)}
            then
              cbDocumentField.Items.AddObject(R.LName + ' - ' + R.RelationFields[i].LName,
                R.RelationFields[i]);
          end;
        end;
        ibsql.Next;
      end;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure TdlgSetRelAnalyzeAndDocField.actNewExecute(Sender: TObject);
begin
  ibdsEntryAnalyzeRel.Insert;
  ibdsEntryAnalyzeRel.FieldByName('entrylinekey').AsInteger := FEntryKey;
  ibdsEntryAnalyzeRel.FieldByName('doctypekey').AsInteger :=
    TLongint(cbDocumentType.Items.Objects[cbDocumentType.ItemIndex]).Value;
  ibdsEntryAnalyzeRel.FieldByName('analyzefield').AsString :=
    TatRelationField(cbAnalyze.Items.Objects[cbAnalyze.ItemIndex]).FieldName;
  ibdsEntryAnalyzeRel.FieldByName('docrelname').AsString :=
    TatRelationField(cbDocumentField.Items.Objects[cbDocumentField.ItemIndex]).Relation.RelationName;
  ibdsEntryAnalyzeRel.FieldByName('docfieldname').AsString :=
    TatRelationField(cbDocumentField.Items.Objects[cbDocumentField.ItemIndex]).FieldName;
  try
    ibdsEntryAnalyzeRel.Post;
  except
    MessageBox(HANDLE, 'Такая запись уже существует!', 'Внимание', mb_OK or mb_IconInformation);
    ibdsEntryAnalyzeRel.Cancel;
  end;
end;

procedure TdlgSetRelAnalyzeAndDocField.actReplaceExecute(Sender: TObject);
begin
  ibdsEntryAnalyzeRel.Edit;
  ibdsEntryAnalyzeRel.FieldByName('entrylinekey').AsInteger := FEntryKey;
  ibdsEntryAnalyzeRel.FieldByName('doctypekey').AsInteger :=
    TLongint(cbDocumentType.Items.Objects[cbDocumentType.ItemIndex]).Value;
  ibdsEntryAnalyzeRel.FieldByName('analyzefield').AsString :=
    TatRelationField(cbAnalyze.Items.Objects[cbAnalyze.ItemIndex]).FieldName;
  ibdsEntryAnalyzeRel.FieldByName('docrelname').AsString :=
    TatRelationField(cbDocumentField.Items.Objects[cbDocumentField.ItemIndex]).Relation.RelationName;
  ibdsEntryAnalyzeRel.FieldByName('docfieldname').AsString :=
    TatRelationField(cbDocumentField.Items.Objects[cbDocumentField.ItemIndex]).FieldName;
  try
    ibdsEntryAnalyzeRel.Post;
  except
    MessageBox(HANDLE, 'Такая запись уже существует!', 'Внимание', mb_OK or mb_IconInformation);
    ibdsEntryAnalyzeRel.Cancel;
  end;
end;

procedure TdlgSetRelAnalyzeAndDocField.actDeleteExecute(Sender: TObject);
begin
  ibdsEntryAnalyzeRel.Delete;
end;

procedure TdlgSetRelAnalyzeAndDocField.actOkExecute(Sender: TObject);
begin
  if not inTransaction then
    ibdsEntryAnalyzeRel.Transaction.Commit;
  ModalResult := mrOk;
end;

procedure TdlgSetRelAnalyzeAndDocField.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgSetRelAnalyzeAndDocField.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not inTransaction then
    ibdsEntryAnalyzeRel.Transaction.RollBack;
end;

procedure TdlgSetRelAnalyzeAndDocField.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled := (cbAnalyze.ItemIndex >= 0) and
    (cbDocumentType.ItemIndex >= 0) and (cbDocumentField.ItemIndex >= 0);
end;

procedure TdlgSetRelAnalyzeAndDocField.actReplaceUpdate(Sender: TObject);
begin
  actReplace.Enabled := (cbAnalyze.ItemIndex >= 0) and
    (cbDocumentType.ItemIndex >= 0) and (cbDocumentField.ItemIndex >= 0) and
    (ibdsEntryAnalyzeRel.FieldByName('EntryLineKey').AsInteger > 0);

end;

procedure TdlgSetRelAnalyzeAndDocField.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := (ibdsEntryAnalyzeRel.FieldByName('EntryLineKey').AsInteger > 0);
end;

end.

