
unit tr_dlgRemainder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBCtrls, StdCtrls, Mask, xDateEdits, gsIBLookupComboBox, ActnList,
  IBDatabase, Db, IBCustomDataSet, dmDatabase_unit, IBSQL,
  at_sql_setup;

type
  TdlgRemainder = class(TForm)
    Label1: TLabel;
    gsiblcAccount: TgsIBLookupComboBox;
    Label6: TLabel;
    xddeEntryDate: TxDateDBEdit;
    gbDebit: TGroupBox;
    Label2: TLabel;
    dbedDebitSumNCU: TDBEdit;
    Label3: TLabel;
    Label4: TLabel;
    gsiblcCurr: TgsIBLookupComboBox;
    dbedDebitSumCurr: TDBEdit;
    gbCredit: TGroupBox;
    Label5: TLabel;
    Label7: TLabel;
    dbedCreditSumNCU: TDBEdit;
    dbedCreditSumCurr: TDBEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    sbAnalyze: TScrollBox;
    Label8: TLabel;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    ibdsEntrys: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsEntrys: TDataSource;
    bChangeDate: TButton;
    actChangeDate: TAction;
    ibsqlAccount: TIBSQL;
    atSQLSetup: TatSQLSetup;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actChangeDateExecute(Sender: TObject);
    procedure gsiblcAccountExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dbedDebitSumNCUChange(Sender: TObject);
    procedure dbedCreditSumNCUChange(Sender: TObject);
  private
    FID: Integer;
    FDocumentKey: Integer;
    FAccountKey: Integer;
    FDate: TDateTime;
    { Private declarations }
    procedure AppendNewEntryLine;
    procedure EditCurrentEntryLine;
    procedure ChangeDate;
    procedure AnalyzeControls;
    function AppendNewDocument: Boolean;
    function Save: Boolean;
  public
    { Public declarations }
    procedure SetupDialog(const aID, aDocumentKey: Integer; aDate: TDateTime);
    property ID: Integer read FID;
  end;

var
  dlgRemainder: TdlgRemainder;

implementation

{$R *.DFM}

uses
  at_classes, tr_type_unit, gd_security;

procedure TdlgRemainder.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgRemainder.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgRemainder.actNextExecute(Sender: TObject);
begin
  if Save then
    SetupDialog(-1, FDocumentKey, FDate);
end;

function TdlgRemainder.Save: Boolean;
begin
  Result := True;
  try
    if (FDate <> 0) and (FDate <> ibdsEntrys.FieldByName('EntryDate').AsDateTime)
    then
      ChangeDate;

    if FDocumentKey <= 0 then
      Result := AppendNewDocument;

    if Result then
    begin
      if not (ibdsEntrys.State in [dsEdit, dsInsert]) then ibdsEntrys.Edit;
      ibdsEntrys.FieldByName('documentkey').AsInteger := FDocumentKey;
      if (ibdsEntrys.FieldByName('debitsumncu').IsNull or
          (ibdsEntrys.FieldByName('debitsumncu').AsFloat = 0))
       and
         (ibdsEntrys.FieldByName('debitsumcurr').IsNull or
          (ibdsEntrys.FieldByName('debitsumcurr').AsFloat = 0))
      then
        ibdsEntrys.FieldByName('accounttype').AsString := 'K'
      else
        ibdsEntrys.FieldByName('accounttype').AsString := 'D';
      ibdsEntrys.Post;
      FDate := ibdsEntrys.FieldByName('EntryDate').AsDateTime;
      FAccountKey := ibdsEntrys.FieldByName('AccountKey').AsInteger;
      if IBTransaction.InTransaction then
        IBTransaction.Commit;
    end;

  except
    on E: Exception do
    begin
      MessageBox(HANDLE,
        PChar(Format('Во время сохранения возникла следующая ошибка: %s', [E.Message])),
        'Внимание', mb_OK or mb_IconInformation);
      Result := False;
    end;
  end;
end;

procedure TdlgRemainder.SetupDialog(const aID, aDocumentKey: Integer; aDate: TDateTime);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
    
  FID := aID;
  FDocumentKey := aDocumentKey;
  FDate := aDate;

  if (FDate = 0) or (FDocumentKey = -1) then
  begin
    xddeEntryDate.Enabled := False;
    actChangeDate.Visible := True;
  end;  

  if FID = -1 then
    AppendNewEntryLine
  else
  begin
    actNext.Enabled := False;
    EditCurrentEntryLine;
  end;

  if Visible then
    gsiblcAccount.SetFocus;

end;

procedure TdlgRemainder.AppendNewEntryLine;
begin
  FID := GenUniqueID;
  ibdsEntrys.Open;
  ibdsEntrys.Insert;
  ibdsEntrys.FieldByName('ID').AsInteger := FID;
  ibdsEntrys.FieldByName('EntryKey').AsInteger := RemainderEntryKey;
  if FAccountKey <> -1 then
    ibdsEntrys.FieldByName('AccountKey').AsInteger := FAccountKey;
  ibdsEntrys.FieldByName('TrTypeKey').AsInteger := RemainderTransactionKey;
  if FDate <> 0 then
    ibdsEntrys.FieldByName('EntryDate').AsDateTime := FDate
  else
    ibdsEntrys.FieldByName('EntryDate').AsDateTime := Date;
  ibdsEntrys.FieldByName('companykey').AsInteger := IBLogin.CompanyKey;
  ibdsEntrys.FieldByName('aFull').AsInteger := -1;
  ibdsEntrys.FieldByName('aChag').AsInteger := -1;
  ibdsEntrys.FieldByName('aView').AsInteger := -1;
end;

procedure TdlgRemainder.EditCurrentEntryLine;
begin
  ibdsEntrys.ParamByName('ek').AsInteger := FID;
  ibdsEntrys.Open;
  ibdsEntrys.Edit;

  AnalyzeControls;
end;

procedure TdlgRemainder.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsEntrys.State in [dsEdit, dsInsert] then
      ibdsEntrys.Cancel;

    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;
end;

function TdlgRemainder.AppendNewDocument: Boolean;
var
  ibsql: TIBSQL;
begin
  Result := True;
  try
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      FDocumentKey := GenUniqueID;
      ibsql.SQL.Text := 'INSERT INTO gd_document (' +
        'id, documenttypekey, trtypekey, number, documentdate, ' +
        'afull, achag, aview, companykey, creatorkey, creationdate, editorkey, editiondate, ' +
        'disabled, reserved) ' +
        'VALUES (' +
        ':id, :documenttypekey, :trtypekey, :number, :documentdate, ' +
        ':afull, :achag, :aview, :companykey, :creatorkey, :creationdate, :editorkey, :editiondate, ' +
        ':disabled, :reserved) ';
      ibsql.Prepare;
      ibsql.Params.ByName('id').AsInteger := FDocumentKey;
      ibsql.Params.ByName('documenttypekey').AsInteger := 801000;
      ibsql.Params.ByName('trtypekey').AsInteger := RemainderTransactionKey;
      ibsql.Params.ByName('number').AsString := '';
      ibsql.Params.ByName('documentdate').AsDateTime := ibdsEntrys.FieldByName('EntryDate').AsDateTime;
      ibsql.Params.ByName('afull').AsInteger := ibdsEntrys.FieldByName('aFull').AsInteger;
      ibsql.Params.ByName('achag').AsInteger := ibdsEntrys.FieldByName('aChag').AsInteger;
      ibsql.Params.ByName('aview').AsInteger := ibdsEntrys.FieldByName('aView').AsInteger;
      ibsql.Params.ByName('companykey').AsInteger := IBLogin.CompanyKey;
      ibsql.Params.ByName('creatorkey').AsInteger := IBLogin.ContactKey;
      ibsql.Params.ByName('creationdate').AsDateTime := Now;
      ibsql.Params.ByName('editorkey').AsInteger := IBLogin.ContactKey;
      ibsql.Params.ByName('editiondate').AsDateTime := Now;
      ibsql.Params.ByName('disabled').AsInteger := 0;
      ibsql.Params.ByName('reserved').Clear;
      ibsql.ExecQuery;

    finally
      ibsql.Free;
    end;
  except
    on E: Exception do
    begin
      MessageBox(HANDLE,
        PChar(Format('Во время создания документа возникла следующая ошибка: %s ', [E.Message])),
        'Внимание', mb_Ok or mb_IconInformation);
      Result := False;
    end;
  end;
end;

procedure TdlgRemainder.actChangeDateExecute(Sender: TObject);
begin
  if MessageBox(HANDLE, 'Изменение даты повлечет изменение даты для всех остатков! Продолжить?',
     'Внимание', mb_YesNo or mb_IconQuestion) = idYes then
  begin
    actChangeDate.Visible := False;
    xddeEntryDate.Enabled := True;
  end;
end;

procedure TdlgRemainder.ChangeDate;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'UPDATE gd_entrys SET entrydate = :ed WHERE entrykey = :ek';
    ibsql.Prepare;
    ibsql.ParamByName('ed').AsDate := ibdsEntrys.FieldByName('EntryDate').AsDateTime;
    ibsql.ParamByName('ek').AsInteger := ibdsEntrys.FieldByName('EntryKey').AsInteger;
    ibsql.ExecQuery;
    ibsql.Close;

    ibsql.SQL.Text := 'UPDATE gd_document SET documentdate = :ed WHERE id = :id';
    ibsql.Prepare;
    ibsql.ParamByName('ed').AsDate := ibdsEntrys.FieldByName('EntryDate').AsDateTime;
    ibsql.ParamByName('id').AsInteger := FDocumentKey;
    ibsql.ExecQuery;
    ibsql.Close

  finally
    ibsql.Free;
  end;
end;

procedure TdlgRemainder.AnalyzeControls;
var
  i: Integer;
  A: TatRelation;
  F: TatRelationField;
  lab: TLabel;
  gsiblc: TgsIBLookupComboBox;
  H: Integer;
 
begin
  if not ibsqlAccount.Prepared then
    ibsqlAccount.Prepare;
  ibsqlAccount.ParamByName('id').AsInteger := ibdsEntrys.FieldByName('accountkey').AsInteger;
  ibsqlAccount.ExecQuery;
  try
    if ibsqlAccount.RecordCount = 1 then
    begin
      for i:= 0 to sbAnalyze.ControlCount - 1 do
        sbAnalyze.Controls[0].Free;
      
      H := 2;  
      A := atDatabase.Relations.ByRelationName('GD_CARDACCOUNT');
      for i:= 0 to A.RelationFields.Count - 1 do
      begin
        if A.RelationFields[i].IsUserDefined and
          (ibsqlAccount.FieldByName(A.RelationFields[i].FieldName).AsInteger = 1) then
        begin
          F := atDatabase.FindRelationField('GD_ENTRYS', A.RelationFields[i].FieldName);
          if Assigned(F) then
          begin
            lab := TLabel.Create(Owner);
            lab.Name := Format('USRLabel%d', [i]);
            sbAnalyze.InsertControl(lab);
            lab.Left := 5;
            lab.Top := H + 4;
            lab.Caption := F.References.LName;

            gsiblc := TgsIBLookupComboBox.Create(Owner);
            gsiblc.Name := Format('USRgsIBLookupComboBox%d', [i]);
            gsiblc.Text := '';
            gsiblc.Transaction := IBTransaction;
            sbAnalyze.InsertControl(gsiblc);
            gsiblc.Left := 10 + lab.Canvas.TextWidth(lab.Caption);
            gsiblc.Top := H;
            gsiblc.Width := sbAnalyze.Width - gsiblc.Left - 10;
            gsiblc.ListTable := F.References.RelationName;
            if UpperCase(Trim(F.References.RelationName)) = 'GD_CONTACT' then
              gsiblc.gdClassName := 'TgdcBaseContact'
            else
              if UpperCase(Trim(F.References.RelationName)) = 'GD_COMPANY' then
                gsiblc.gdClassName := 'TgdcCompany';

            gsiblc.KeyField := F.References.PrimaryKey.ConstraintFields[0].FieldName;
            gsiblc.ListField := F.References.ListField.FieldName;
            gsiblc.DataSource := dsEntrys;
            gsiblc.DataField := F.FieldName;

            H := H + gsiblc.Height + 5;
          end;
        end;
      end;
    end;
  finally
    ibsqlAccount.Close;
  end;
end;

procedure TdlgRemainder.gsiblcAccountExit(Sender: TObject);
begin
  AnalyzeControls;
end;

procedure TdlgRemainder.FormCreate(Sender: TObject);
begin
  FAccountKey := -1;
end;

procedure TdlgRemainder.dbedDebitSumNCUChange(Sender: TObject);
begin
  gbCredit.Enabled := dbedDebitSumNCU.Text = '';
end;

procedure TdlgRemainder.dbedCreditSumNCUChange(Sender: TObject);
begin
  gbDebit.Enabled := dbedCreditSumNCU.Text = '';
end;

end.
