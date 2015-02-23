unit tr_dlgEntrys_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, DBCGrids, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Db, DBClient, IBCustomDataSet, dmDatabase_unit, DBCtrls, IBSQL,
  ActnList, at_classes, ComCtrls, contnrs, tr_Type_unit, ExtCtrls,
  IBDatabase;

type
  TdlgEntrys = class(TForm)
    gsiblcTrType: TgsIBLookupComboBox;
    Label1: TLabel;
    cdsEntry: TClientDataSet;
    cdsEntryDebitSumNCU: TCurrencyField;
    cdsEntryDebitSumCurr: TCurrencyField;
    cdsEntryDebitSumEq: TCurrencyField;
    cdsEntryCreditSumNCU: TCurrencyField;
    cdsEntryCreditSumCurr: TCurrencyField;
    cdsEntryCreditSumEq: TCurrencyField;
    dsEntrys: TDataSource;
    ibdsAccount: TIBDataSet;
    cdsEntryDebitKey: TIntegerField;
    cdsEntryCreditKey: TIntegerField;
    cdsEntryDebit: TStringField;
    ibsql: TIBSQL;
    cdsEntryCredit: TStringField;
    ActionList1: TActionList;
    cdsEntryCurrKey: TIntegerField;
    ibdsCurr: TIBDataSet;
    cdsEntryCurrName: TStringField;
    gbEntry: TGroupBox;
    bOk: TButton;
    bCancel: TButton;
    cdsEntryEntryKey: TIntegerField;
    actNext: TAction;
    actPrev: TAction;
    pUserInfo: TPanel;
    Panel2: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    bNext: TButton;
    bPrev: TButton;
    Button3: TButton;
    Button4: TButton;
    stDebitNCU: TStaticText;
    stDebitCurr: TStaticText;
    stCreditCurr: TStaticText;
    stCreditNCU: TStaticText;
    Panel3: TPanel;
    gsdbgrEntry: TgsDBGrid;
    Label2: TLabel;
    Label3: TLabel;
    edNumberDoc: TEdit;
    Label4: TLabel;
    dtpDate: TDateTimePicker;
    Label5: TLabel;
    edDescription: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure cdsEntryDebitChange(Sender: TField);
    procedure cdsEntryCreditChange(Sender: TField);
    procedure gsdbgrEntryKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dsEntrysDataChange(Sender: TObject; Field: TField);
    procedure gsiblcTrTypeChange(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure cdsEntryAfterPost(DataSet: TDataSet);
    procedure cdsEntryAfterDelete(DataSet: TDataSet);
    procedure actNextUpdate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
  private

    { TODO 1 -oденис -cнедочет : Где префикс F }
    DocumentType: Integer;    // Код типа документа
    DocumentCode: Integer;    // Код документа
    PositionCode: Integer;    // Код позиции
    TransactionCode: Integer; // Код операции

    CurrentTransaction: Integer; // Текущая операция (если она выибирается в самом окне)
    CurrentEntry: Integer;       // Текущая проводка

    isLocal: Boolean;            // Внутренний флаг - означающий, что изменения данных
                                 //   производится программой и запрещающий всякие пересчеты

    // Установка счета в проводку
    procedure SetAccount(SenderAccountName, SenderAccountKey: TField);
    // Выбор счета (вызов соответствующего окна )
    function ChooseAccount(const aValue: String): String;
    // Расчет сумм по проводке
    procedure CalcSum;
    // Проверка правильности заполнения проводки
    function CheckData: Boolean;
    // Добавление полей в DataSet - связанные с аналитикой
    procedure CreateFields;
    // Обработка изменения в аналитических поля с выводом окна для выбора аналитики
    procedure AnalyzeChange(Sender: TField);
    // Сохранение текущей проводки в структуре
    procedure SaveCurrentEntry;
    // Загрука новой проводки из структуры
    procedure LoadNewEntry;
    function GetDocumentDate: TDateTime;
    function GetDocumentNumber: String;
    function GetAnalyze(const FieldName: String; const Value: Integer): String;
  public
    TrPosition: TPositionTransaction;    // Операция - вся информация

    procedure SetupDialog(const aDocumentType, aDocumentCode, aPositionCode,
      aTransactionCode: Integer;  aTrPosition: TPositionTransaction;
      const isUserDocument: Boolean);
    procedure SetTransaction(aIBTransaction: TIBTransaction);  
    property DocumentDate: TDateTime read GetDocumentDate;
    property DocumentNumber: String read GetDocumentNumber;  
  end;

var
  dlgEntrys: TdlgEntrys;

implementation

{$R *.DFM}

uses tr_dlgChooseAccount_unit, tr_dlgChooseAnalyze_unit;

{ TdlgEntrys }

procedure TdlgEntrys.CreateFields;
var
  F: TField;
  i: Integer;
  R: TatRelationField;
begin
  for i:= 0 to ibdsAccount.FieldCount - 1 do
  begin
    if (Pos(UserPrefix, ibdsAccount.Fields[i].FieldName) > 0)
    then
    begin
      R := atDatabase.FindRelationField('GD_CARDACCOUNT', ibdsAccount.Fields[i].FieldName);
      if Assigned(R) and Assigned(R.Field) and (R.Field.RefTableName > '') then
      begin
        F := TIntegerField.Create(Self);
        F.FieldName := ibdsAccount.Fields[i].FieldName;
        F.Visible := False;
        F.DisplayLabel := R.LName;
        F.DataSet := cdsEntry;

        F := TStringField.Create(Self);
        F.FieldName := ibdsAccount.Fields[i].FieldName + '_1';
        F.Visible := True;
        F.Size := 60;
        F.DisplayWidth := 20;
        F.DisplayLabel := R.LName;
        F.DataSet := cdsEntry;
        F.OnChange := AnalyzeChange;
      end;
    end;
  end;
  cdsEntry.CreateDataSet;
end;

procedure TdlgEntrys.FormCreate(Sender: TObject);
begin
  isLocal := False;
  CurrentTransaction := -1;
  TrPosition := TPositionTransaction.Create(-1, -1, -1, -1, '', '', 0);  
end;

procedure TdlgEntrys.cdsEntryDebitChange(Sender: TField);
begin
  { TODO 1 -oденис -cнедочет : SetAccount вызывает abort, но он не обрабатывается. }
  if not Sender.IsNull and (Sender.AsString > '') then
    SetAccount(Sender, cdsEntryDebitKey);
  cdsEntryCredit.ReadOnly := not Sender.IsNull and (Sender.AsString > '');
  cdsEntryCreditSumNCU.ReadOnly := cdsEntryCredit.ReadOnly;
  cdsEntryCreditSumCurr.ReadOnly := cdsEntryCredit.ReadOnly;
  cdsEntryCreditSumEq.ReadOnly := cdsEntryCredit.ReadOnly;
end;

procedure TdlgEntrys.cdsEntryCreditChange(Sender: TField);
begin
  { TODO 1 -oденис -cнедочет : SetAccount вызывает abort, но он не обрабатывается. }
  if not Sender.IsNull and (Sender.AsString > '') then
    SetAccount(Sender, cdsEntryCreditKey);
  cdsEntryDebit.ReadOnly := not Sender.IsNull and (Sender.AsString > '');
  cdsEntryDebitSumNCU.ReadOnly := cdsEntryDebit.ReadOnly;
  cdsEntryDebitSumCurr.ReadOnly := cdsEntryDebit.ReadOnly;
  cdsEntryDebitSumEq.ReadOnly := cdsEntryDebit.ReadOnly;
end;

procedure TdlgEntrys.gsdbgrEntryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  S: String;
begin
  if (Key = VK_F3) and ((gsdbgrEntry.SelectedField.FieldName = 'Debit') or
                        (gsdbgrEntry.SelectedField.FieldName = 'Credit'))
  then
  begin
    S := ChooseAccount(gsdbgrEntry.SelectedField.AsString);
    if S > '' then
    begin
      if not (cdsEntry.State in [dsEdit, dsInsert]) then
        cdsEntry.Edit;
      gsdbgrEntry.SelectedField.AsString := S;
    end;
  end;
end;

procedure TdlgEntrys.dsEntrysDataChange(Sender: TObject; Field: TField);
begin
  cdsEntryDebit.ReadOnly := not cdsEntryCredit.IsNull and (cdsEntryCredit.AsString > '');
  cdsEntryDebitSumNCU.ReadOnly := cdsEntryDebit.ReadOnly;
  cdsEntryDebitSumCurr.ReadOnly := cdsEntryDebit.ReadOnly;
  cdsEntryDebitSumEq.ReadOnly := cdsEntryDebit.ReadOnly;

  cdsEntryCredit.ReadOnly := not cdsEntryDebit.IsNull and (cdsEntryDebit.AsString > '');
  cdsEntryCreditSumNCU.ReadOnly := cdsEntryCredit.ReadOnly;
  cdsEntryCreditSumCurr.ReadOnly := cdsEntryCredit.ReadOnly;
  cdsEntryCreditSumEq.ReadOnly := cdsEntryCredit.ReadOnly;

end;

procedure TdlgEntrys.SetAccount(SenderAccountName,
  SenderAccountKey: TField);
var
  S: String;
  isOk: Boolean;
begin
  ibsql.ParamByName('Alias').AsString := SenderAccountName.Text;
  ibsql.ExecQuery;
    
  if ibsql.RecordCount = 1 then
  begin
    SenderAccountKey.AsInteger := ibsql.FieldByName('ID').AsInteger;
    if ibsql.FieldByName('multycurr').AsInteger = 1 then
    begin
      cdsEntryCurrKey.Visible := True;
      cdsEntryDebitSumCurr.Visible := True;
      cdsEntryDebitSumCurr.Visible := True;
    end;
    isOk := True;
  end
  else
    isOK := False;
  ibsql.Close;
  if not isOK then
  begin
    S := ChooseAccount(SenderAccountName.Text);
    if S > '' then
      SenderAccountName.AsString := S
    else
      abort;
  end;
end;

function TdlgEntrys.ChooseAccount(const aValue: String): String;
begin
  with TfrmChooseAccount.Create(Self) do
    try
      ibdsAccount.Locate('Alias', aValue, [loPartialKey]);
      gsibgrAccount.CheckBox.Visible := False;
      if ShowModal = mrOk then
        Result := ibdsAccount.FieldByName('Alias').AsString
      else
        Result := '';
    finally
      Free;
    end;
end;

procedure TdlgEntrys.gsiblcTrTypeChange(Sender: TObject);
begin
  gbEntry.Enabled := gsiblcTrType.CurrentKey > '';
end;

function TdlgEntrys.CheckData: Boolean;
var
  SumDebitNCU, SumDebitCurr: Double;
  SumCreditNCU, SumCreditCurr: Double;
  CountDebit, CountCredit: Integer;
begin
  isLocal := True;
  SumDebitNCU := 0;
  SumDebitCurr := 0;
  SumCreditNCU := 0;
  SumCreditCurr := 0;
  CountDebit := 0;
  CountCredit := 0;

  cdsEntry.DisableControls;
  try
    cdsEntry.First;
    while not cdsEntry.EOF do
    begin
      SumDebitNCU := SumDebitNCU + cdsEntryDebitSumNCU.Value;
      SumDebitCurr := SumDebitCurr + cdsEntryDebitSumCurr.Value;

      SumCreditNCU := SumCreditNCU + cdsEntryCreditSumNCU.Value;
      SumCreditCurr := SumCreditCurr + cdsEntryCreditSumCurr.Value;
      if (cdsEntryDebit.AsString > '') then
        Inc(CountDebit);
      if (cdsEntryCredit.AsString > '') then
        Inc(CountCredit);

      cdsEntry.Next;
    end;
    Result := (CountDebit = 1) or (CountCredit = 1);
    if Result then
    begin
      if (SumDebitNCU <> SumCreditNCU) or (SumDebitCurr <> SumCreditCurr) then
      begin
        cdsEntryDebit.ReadOnly := False;
        cdsEntryDebitSumNCU.ReadOnly := cdsEntryDebit.ReadOnly;
        cdsEntryDebitSumCurr.ReadOnly := cdsEntryDebit.ReadOnly;
        cdsEntryDebitSumEq.ReadOnly := cdsEntryDebit.ReadOnly;

        cdsEntryCredit.ReadOnly := False;
        cdsEntryCreditSumNCU.ReadOnly := cdsEntryCredit.ReadOnly;
        cdsEntryCreditSumCurr.ReadOnly := cdsEntryCredit.ReadOnly;
        cdsEntryCreditSumEq.ReadOnly := cdsEntryCredit.ReadOnly;
        cdsEntry.First;
        while not cdsEntry.EOF do
        begin
          if (CountDebit = 1) and (SumCreditNCU <> 0) and (cdsEntryDebit.AsString > '') then
          begin
            cdsEntry.Edit;
            cdsEntryDebitSumNCU.Value := SumCreditNCU;
            cdsEntryDebitSumCurr.Value := SumCreditCurr;
            cdsEntry.Post;
            Break;
          end
          else
            if (CountCredit = 1) and (SumDebitNCU <> 0) and (cdsEntryCredit.AsString > '') then
            begin
              cdsEntry.Edit;
              cdsEntryCreditSumNCU.Value := SumDebitNCU;
              cdsEntryCreditSumCurr.Value := SumDebitCurr;
              cdsEntry.Post;
              Break;
            end;
          cdsEntry.Next;
        end;
      end;
    end;
  finally
    cdsEntry.First;
    cdsEntry.EnableControls;
  end;
  isLocal := False;
end;

procedure TdlgEntrys.bOkClick(Sender: TObject);
begin
  if not CheckData then
    MessageBox(HANDLE, 'Проводка не корректна. Проверьте баланс по проводке и количество счетов',
      'Внимание', mb_OK or mb_IconExclamation)
  else
  begin
    SaveCurrentEntry;
    ModalResult := mrOk;
  end;
end;

procedure TdlgEntrys.cdsEntryAfterPost(DataSet: TDataSet);
begin
  CalcSum;
end;

procedure TdlgEntrys.cdsEntryAfterDelete(DataSet: TDataSet);
begin
  CalcSum;
end;

procedure TdlgEntrys.CalcSum;
var
  DebitNCU, CreditNCU, DebitCurr, CreditCurr: Double;
  Bookmark: TBookmark;
begin
  DebitNCU := 0;
  CreditNCU := 0;
  DebitCurr := 0;
  CreditCurr := 0;
  if isLocal then exit;
  Bookmark := cdsEntry.GetBookmark;
  cdsEntry.DisableControls;
  try
    cdsEntry.First;
    while not cdsEntry.EOF do
    begin
      DebitNCU := DebitNCU + cdsEntryDebitSumNCU.Value;
      CreditNCU := CreditNCU + cdsEntryCreditSumNCU.Value;
      DebitCurr := DebitCurr + cdsEntryDebitSumCurr.Value;
      CreditCurr := CreditCurr + cdsEntryCreditSumCurr.Value;

      cdsEntry.Next;
    end;
  finally
    stDebitNCU.Caption := FloatToStr(DebitNCU);
    stCreditNCU.Caption := FloatToStr(CreditNCU);
    stDebitCurr.Caption := FloatToStr(DebitCurr);
    stCreditCurr.Caption := FloatToStr(CreditCurr);
    
    cdsEntry.GotoBookmark(Bookmark);
    cdsEntry.FreeBookmark(Bookmark);
    cdsEntry.EnableControls;
  end;
end;

procedure TdlgEntrys.AnalyzeChange(Sender: TField);
var
  sql: TIBSQL;
  R: TatRelationField;
begin
  if Sender.Text > '' then
  begin
    sql := TIBSQL.Create(Self);
    try
      sql.Transaction := ibsql.Transaction;
      R := atDatabase.FindRelationField('GD_CARDACCOUNT', copy(Sender.FieldName, 1,
        Pos('_1', Sender.FieldName) - 1));
      if Assigned(R) and Assigned(R.Field) and (R.Field.RefTableName > '') then
      begin
        sql.SQL.Text :=
          Format('SELECT ID FROM %S WHERE %S = ''%S''',
            [R.Field.RefTableName, R.Field.RefListFieldName, Sender.Text]);
        sql.ExecQuery;
        if sql.RecordCount = 1 then
        begin
          if not (cdsEntry.State in [dsEdit, dsInsert]) then
            cdsEntry.Edit;
          cdsEntry.FieldByName(copy(Sender.FieldName, 1,
                Length(Sender.FieldName) - 2)).AsInteger := sql.FieldByName('ID').AsInteger;
        end
        else
        begin
          with TdlgChooseAnalyze.Create(Self) do
            try
              if SetupDialog(R.Field.RefTableName, R.Field.RefListFieldName) then
              begin
                if not (cdsEntry.State in [dsEdit, dsInsert]) then
                  cdsEntry.Edit;
                cdsEntry.FieldByName(Sender.FieldName).AsString :=
                  AnalyzeName;
              end;
            finally
              Free;
            end;
        end;
      end;
    finally
      sql.Free;
    end;
  end
  else
  begin
    if not (cdsEntry.State in [dsEdit, dsInsert]) then cdsEntry.Edit;
      cdsEntry.FieldByName(copy(Sender.FieldName, 1,
        Length(Sender.FieldName) - 2)).Clear;
  end;
end;

procedure TdlgEntrys.SetupDialog(const aDocumentType, aDocumentCode, aPositionCode,
      aTransactionCode: Integer;  aTrPosition: TPositionTransaction;
      const isUserDocument: Boolean);
var
  H: Integer;
begin
  ibdsAccount.Open;
  CreateFields;

  DocumentType := aDocumentType;
  DocumentCode := aDocumentCode;
  TransactionCode := aTransactionCode;
  PositionCode := aPositionCode;
  
  if TransactionCode <> -1 then
  begin
    gsiblcTrType.CurrentKey := IntToStr(TransactionCode);
    gsiblcTrType.Enabled := False;
  end  
  else
  begin
    gsiblcTrType.Condition := Format('DOCTYPE_KEY = %D', [DocumentType]);
  end;
  TrPosition.Assign(aTrPosition);

  if TrPosition.RealEntryCount = 0 then
  begin
    TrPosition.AddRealEntry(TEntry.Create(1, DocumentCode, PositionCode, TrPosition.TransactionDate));
    TrPosition.RealEntry[0].AddFromTypeEntry(TrPosition.TypeEntry[0], TrPosition.ValueList,
      TrPosition.AnalyzeList, -1);
  end;

  if not isUserDocument then
  begin
    H := pUserInfo.Height;
    pUserInfo.Height := 0;
    pUserInfo.Enabled := False;
    gbEntry.Height := gbEntry.Height - H;
    Height := Height - H;
  end;
  
  CurrentEntry := 0;
  LoadNewEntry;
end;

procedure TdlgEntrys.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := (TrPosition.RealEntryCount > 1) and (CurrentEntry < TrPosition.RealEntryCount - 1);
end;

procedure TdlgEntrys.actNextExecute(Sender: TObject);
begin
  if (CurrentEntry < TrPosition.RealEntryCount - 1) and CheckData then
  begin
    SaveCurrentEntry;
    Inc(CurrentEntry);
    LoadNewEntry;
  end;
end;

procedure TdlgEntrys.LoadNewEntry;
var
  j, k: Integer;
begin
  cdsEntry.DisableControls;
  try
    cdsEntry.First;
    while not cdsEntry.EOF do cdsEntry.Delete;

    for j:= 0 to TrPosition.RealEntry[CurrentEntry].DebitCount - 1 do
    begin
      cdsEntry.Insert;
      cdsEntryEntryKey.AsInteger := TrPosition.RealEntry[CurrentEntry].EntryKey;
      cdsEntryDebitKey.AsInteger := TrPosition.RealEntry[CurrentEntry].Debit[j].Code;
      cdsEntryDebit.AsString := TrPosition.RealEntry[CurrentEntry].Debit[j].Alias;
      cdsEntryDebitSumNCU.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).SumNCU;
      cdsEntryDebitSumCurr.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).SumCurr;
      cdsEntryDebitSumEq.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).SumEq;
      cdsEntryCurrKey.AsInteger := TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).CurrKey;
      for k:= 0 to TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).CountAnalyze - 1 do
      begin
        cdsEntry.FieldByName(
         TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].FieldName).AsInteger :=
           TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].ValueAnalyze;
        if TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].ValueAnalyze > 0
        then
        begin
          cdsEntry.FieldByName(
          TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].FieldName + '_1').AsString :=
              GetAnalyze(TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].FieldName,
              TRealAccount(TrPosition.RealEntry[CurrentEntry].Debit[j]).AnalyzeItem[k].ValueAnalyze);
        end;
      end;
      cdsEntry.Post;
    end;

    cdsEntryCredit.ReadOnly := False;
    cdsEntryCreditSumNCU.ReadOnly := cdsEntryCredit.ReadOnly;
    cdsEntryCreditSumCurr.ReadOnly := cdsEntryCredit.ReadOnly;
    cdsEntryCreditSumEq.ReadOnly := cdsEntryCredit.ReadOnly;

    for j:= 0 to TrPosition.RealEntry[CurrentEntry].CreditCount - 1 do
    begin
      cdsEntry.Insert;
      cdsEntryEntryKey.AsInteger := TrPosition.RealEntry[CurrentEntry].EntryKey;
      cdsEntryCreditKey.AsInteger := TrPosition.RealEntry[CurrentEntry].Credit[j].Code;
      cdsEntryCredit.AsString := TrPosition.RealEntry[CurrentEntry].Credit[j].Alias;
      cdsEntryCreditSumNCU.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).SumNCU;
      cdsEntryCreditSumCurr.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).SumCurr;
      cdsEntryCreditSumEq.AsFloat := TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).SumEq;
      cdsEntryCurrKey.AsInteger := TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).CurrKey;
      for k:= 0 to TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).CountAnalyze - 1 do
      begin
        cdsEntry.FieldByName(
         TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].FieldName).AsInteger :=
           TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].ValueAnalyze;
        if TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].ValueAnalyze > 0
        then
        begin
          cdsEntry.FieldByName(
          TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].FieldName + '_1').AsString :=
              GetAnalyze(TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].FieldName,
              TRealAccount(TrPosition.RealEntry[CurrentEntry].Credit[j]).AnalyzeItem[k].ValueAnalyze);
        end;
      end;
      cdsEntry.Post;
    end;
  finally
    cdsEntry.EnableControls;
  end;
end;

procedure TdlgEntrys.SaveCurrentEntry;
var
  AccountKey: Integer;
  AccountName: String;
  AccountType: String;
  SumNCU: Double;
  SumCurr: Double;
  SumEq: Double;
  CurrKey: Integer;
  Account: TAccount;
  R: TatRelationField;
  i: Integer;
begin
  if CurrentEntry < TrPosition.RealEntryCount then
    TrPosition.RealEntry[CurrentEntry].Clear
  else
    TrPosition.CreateRealEntry(nil, nil, -1);

  cdsEntry.DisableControls;
  try
    AccountKey := -1;
    CurrKey := -1;
    AccountName := '';
    AccountType := '';
    SumNCU := 0;
    SumCurr := 0;
    SumEq := 0;

    cdsEntry.First;
    while not cdsEntry.EOF do
    begin
      if cdsEntry.FieldByName('DebitKey').AsInteger > 0 then
      begin
        AccountKey := cdsEntry.FieldByName('DebitKey').AsInteger;
        AccountName := cdsEntry.FieldByName('Debit').AsString;
        AccountType := 'D';
        SumNCU := cdsEntry.FieldByName('DebitSumNCU').AsFloat;
        SumCurr := cdsEntry.FieldByName('DebitSumCurr').AsFloat;
        SumEq := cdsEntry.FieldByName('DebitSumEq').AsFloat;
        CurrKey := cdsEntry.FieldByName('CurrKey').AsInteger;
      end
      else
        if cdsEntry.FieldByName('CreditKey').AsInteger > 0 then
        begin
          AccountKey := cdsEntry.FieldByName('CreditKey').AsInteger;
          AccountName := cdsEntry.FieldByName('Credit').AsString;
          AccountType := 'K';
          SumNCU := cdsEntry.FieldByName('CreditSumNCU').AsFloat;
          SumCurr := cdsEntry.FieldByName('CreditSumCurr').AsFloat;
          SumEq := cdsEntry.FieldByName('CreditSumEq').AsFloat;
          CurrKey := cdsEntry.FieldByName('CurrKey').AsInteger;
        end
        else
        begin
          cdsEntry.Next;
          Continue;
        end;

      if AccountKey <> -1 then
      begin
        Account := TRealAccount.Create(AccountKey,
          AccountName, '', SumNCU, SumCurr, SumEq, CurrKey);
        for i:= 0 to cdsEntry.FieldCount - 1 do
          if Pos(UserPrefix, UpperCase(cdsEntry.Fields[i].FieldName)) > 0 then
          begin
            R := atDatabase.FindRelationField('GD_CARDACCOUNT', cdsEntry.Fields[i].FieldName);
            if Assigned(R) and Assigned(R.Field) and (R.Field.RefTableName > '') then
              Account.AddAnalyze(
                '', '',
                R.Field.RefTableName, cdsEntry.Fields[i].FieldName,
                cdsEntry.Fields[i].AsInteger);
          end;

        if pUserInfo.Enabled then
          TrPosition.RealEntry[CurrentEntry].EntryDate := dtpDate.Date;

        TrPosition.RealEntry[CurrentEntry].AddEntryLine(Account, AccountType = 'D',
          edDescription.Text);
      end;

      cdsEntry.Next;
    end;
  finally
    cdsEntry.First;
    cdsEntry.EnableControls;
  end;
end;

procedure TdlgEntrys.actPrevExecute(Sender: TObject);
begin
  if (CurrentEntry > 0) and CheckData then
  begin
    SaveCurrentEntry;
    Dec(CurrentEntry);
    LoadNewEntry;
  end;
end;

procedure TdlgEntrys.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := CurrentEntry > 0;
end;

function TdlgEntrys.GetDocumentDate: TDateTime;
begin
  Result := dtpDate.DateTime;
end;

function TdlgEntrys.GetDocumentNumber: String;
begin
  Result := edNumberDoc.Text;
end;

function TdlgEntrys.GetAnalyze(const FieldName: String;
  const Value: Integer): String;
var
  R: TatRelationField;
  sql: TIBSQL;
begin
  R := atDatabase.FindRelationField('GD_ENTRYS', FieldName);
  if Assigned(R) and Assigned(R.Field) and (R.Field.RefTableName > '') then
  begin
    sql := TIBSQL.Create(Self);
    try
      sql.Transaction := ibsql.Transaction;
      sql.SQL.Text := Format(
        'SELECT %S FROM %S WHERE ID = %d', [R.Field.RefListFieldName, R.Field.RefTableName,
          Value]);
      sql.ExecQuery;
      Result := sql.Fields[0].AsString;
      sql.Close;    
    finally
      sql.Free;
    end;
  end;
end;

procedure TdlgEntrys.SetTransaction(aIBTransaction: TIBTransaction);
begin
  ibdsAccount.Transaction := aIBTransaction;
  ibdsCurr.Transaction := aIBTransaction;
  ibsql.Transaction := aIBTransaction;
end;

end.
