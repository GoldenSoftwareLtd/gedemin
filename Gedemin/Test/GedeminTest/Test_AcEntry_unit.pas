
unit Test_AcEntry_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  Tgs_AcEntryTest = class(TgsDBTestCase)
  published
    procedure Test_AcEntry;
  end;

implementation

uses
  SysUtils, IBSQL, gdcBaseInterface, gd_security;

{ Tgs_AcEntry }

procedure Tgs_AcEntryTest.Test_AcEntry;
const
  DocTypeID = 806000;
  TrID      = 807001;
  CompanyID = 650010;
  TrRecordID= 807100;
  Acc00     = 300003;
  Acc01     = 300100;
  Acc08     = 300800;
  BelRubID  = 200010;

  function InsertAcRecord(q: TIBSQL; const AnID, ADocID, ACompanyKey: TID): TID;
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO ac_record (id, trrecordkey, transactionkey, recorddate, description, ' +
      '  documentkey, masterdockey, companykey, debitncu, debitcurr, creditncu, creditcurr, ' +
      '  delayed, incorrect, afull, achag, aview, disabled, reserved) ' +
      'VALUES (:id, 807100, 807001, CURRENT_DATE, NULL, :docid, :docid, :ck, NULL, NULL, NULL, NULL, ' +
      '  0, 0, -1, -1, -1, 0, 0)';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('docid').AsInteger := ADocID;
    q.ParamByName('ck').AsInteger := ACompanyKey;
    q.ExecQuery;
    Result := AnID;
  end;

  function InsertAcEntry(q: TIBSQL; const AnID, ARecID, AnAccID: TID; const AnAccPart: Char;
    const DNCU, DCurr, DEq, CNCU, CCurr, CEq: Currency; const ACurrKey: TID;
    const AnEntryDate: TDateTime;
    const ACompanyID, ADocID, AMasterDocID, ATransactionID: TID): TID;
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO ac_entry (id, recordkey, accountkey, accountpart, ' +
      '  debitncu, debitcurr, debiteq, creditncu, creditcurr, crediteq, ' +
      '  currkey, entrydate, companykey, ' +
      '  documentkey, masterdockey, transactionkey) ' +
      'VALUES (:id, :rk, :ak, :ap, :dncu, :dcurr, :deq, ' +
      '  :cncu, :ccurr, :ceq, :currkey, :ed, :ck, ' +
      '  :dock, :mdock, :trk)';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('rk').AsInteger := ARecID;
    q.ParamByName('ak').AsInteger := AnAccID;
    q.ParamByName('ap').AsString := AnAccPart;
    q.ParamByName('dncu').AsCurrency := DNCU;
    q.ParamByName('dcurr').AsCurrency := DCurr;
    q.ParamByName('deq').AsCurrency := DEq;
    q.ParamByName('cncu').AsCurrency := CNCU;
    q.ParamByName('ccurr').AsCurrency := CCurr;
    q.ParamByName('ceq').AsCurrency := CEq;
    q.ParamByName('currkey').AsInteger := ACurrKey;
    q.ParamByName('ed').AsDateTime := AnEntryDate;
    q.ParamByName('ck').AsInteger := ACompanyID;
    q.ParamByName('dock').AsInteger := ADocID;
    q.ParamByName('mdock').AsInteger := AMasterDocID;
    q.ParamByName('trk').AsInteger := ATransactionID;
    q.ExecQuery;
    Result := AnID;
  end;

  function InsertDoc(q: TIBSQL; const AnID: TID; const N: String): TID;
  begin
    q.SQL.Text :=
      'INSERT INTO gd_document ' +
      '  (id, documenttypekey, transactionkey, number, documentdate, companykey, creatorkey, editorkey) ' +
      'VALUES (:id, :dt, :tk, :n, CURRENT_DATE, :ck, :uk, :uk)';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('dt').AsInteger := DocTypeID;
    q.ParamByName('tk').AsInteger := TrID;
    q.ParamByName('n').AsString := N;
    q.ParamByName('ck').AsInteger := CompanyID;
    q.ParamByName('uk').AsInteger := IBLogin.ContactKey;
    q.ExecQuery;
    Result := AnID;
  end;

  procedure TestIncorrectList(const ACount: Integer; const ADocID, ACompanyID: TID);
  var
    MaxID: TID;
    I: Integer;
  begin
    FQ.Close;
    FQ.SQL.Text := 'SELECT MAX(id) FROM ac_record';
    FQ.ExecQuery;
    if FQ.Fields[0].IsNull then
      MaxID := 0
    else
      MaxID := FQ.Fields[0].AsInteger;
    for I := 1 to ACount do
      InsertAcRecord(FQ, gdcBaseManager.GetNextID, ADocID, ACompanyID);
    FQ.Close;
    FQ.SQL.Text := 'SELECT COUNT(*) FROM ac_record WHERE id > :id';
    FQ.ParamByName('id').AsInteger := MaxID;
    FQ.ExecQuery;
    Check(FQ.Fields[0].AsInteger = ACount);
    FTr.Commit;
    FTr.StartTransaction;
    FQ.ParamByName('id').AsInteger := MaxID;
    FQ.ExecQuery;
    Check(FQ.Fields[0].AsInteger = 0);
  end;

var
  DocID, DocID2: TID;
  RecID: TID;
  EntryID, EntryID2: TID;
begin
  DocID := InsertDoc(FQ, gdcBaseManager.GetNextID, '1');
  DocID2 := InsertDoc(FQ, gdcBaseManager.GetNextID, '2');

  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, CompanyID);

  // у голой шапки проводки incorrect = 1
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 1);

  // поле incorrect нельзя изменить вручную
  FQ2.SQL.Text := 'UPDATE ac_record SET incorrect = 0 WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := RecID;
  FQ2.ExecQuery;
  FQ.Close;
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 1);

  // при комите транзакции неверные проводки удаляются из БД
  FTr.Commit;
  FTr.StartTransaction;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.EOF);

  // проверим работу списка некорректных проводок, когда
  // их ИД умещаются в строку
  TestIncorrectList(10, DocID, CompanyID);

  // проверим работу списка некорректных проводок, когда
  // их ИД не умещаются в строку
  TestIncorrectList(1000, DocID, CompanyID);

  // проверяем очистку переменной AC_RECORD_INCORRECT
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, CompanyID);
  FQ.Close;
  FQ.SQL.Text := 'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'') FROM rdb$database';
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsString > '');
  FQ2.Close;
  FQ2.SQL.Text := 'DELETE FROM ac_record WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := RecID;
  FQ2.ExecQuery;
  FQ.Close;
  FQ.ExecQuery;
  Check(FQ.Fields[0].IsNull);

  // тестируем позиции проводки
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, CompanyID);

  EntryID := InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc01, 'D',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    CompanyID, DocID, DocID, TrID);

  // у дебетовой части проводки должны быть нулевые суммы по кредиту
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT ABS(creditncu) + ABS(creditcurr) + ABS(crediteq) FROM ac_entry WHERE id=:ID';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsCurrency = 0);

  // у шапки неполной проводки incorrect = 1
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 1);

  EntryID2 := InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc08, 'C',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    CompanyID, DocID, DocID, TrID);

  // у кредитовой проводки должны быть нулевые суммы по дебету
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_entry WHERE id=:ID';
  FQ.ParamByName('id').AsInteger := EntryID2;
  FQ.ExecQuery;
  Check(FQ.FieldByName('debitncu').AsCurrency = 0);
  Check(FQ.FieldByName('debitcurr').AsCurrency = 0);
  Check(FQ.FieldByName('debiteq').AsCurrency = 0);

  // теперь incorrect = 0
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 0);

  // всегда должны совпадать данные в шапке и позиции проводки
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT * FROM ac_record r JOIN ac_entry e ON e.recordkey = r.id ' +
    'WHERE r.recorddate <> e.entrydate OR r.companykey <> e.companykey ' +
    '  OR r.documentkey <> e.documentkey OR r.masterdockey <> e.masterdockey ' +
    '  OR r.transactionkey <> e.transactionkey';
  FQ.ExecQuery;
  Check(FQ.EOF);

  //
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT * FROM ac_record r ' +
    'WHERE ' +
    '  r.debitncu <> COALESCE((SELECT SUM(e.debitncu) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.creditncu <> COALESCE((SELECT SUM(e.creditncu) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.debitcurr <> COALESCE((SELECT SUM(e.debitcurr) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.creditcurr <> COALESCE((SELECT SUM(e.creditcurr) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) ';
  FQ.ExecQuery;
  Check(FQ.EOF);

  // после действий с позициями проводок проверяем удален ли флаг
  FQ.Close;
  FQ.SQL.Text := 'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'') FROM rdb$database';
  FQ.ExecQuery;
  Check(FQ.Fields[0].IsNull);

  // после действий с позициями проводок проверяем удален ли флаг
  FQ.Close;
  FQ.SQL.Text := 'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'') FROM rdb$database';
  FQ.ExecQuery;
  Check(FQ.Fields[0].IsNull);
end;

initialization
  RegisterTest('DB', Tgs_AcEntryTest.Suite);
end.
