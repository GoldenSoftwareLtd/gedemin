
unit Test_AcEntry_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, IBSQL;

type
  Tgs_AcEntryTest = class(TgsDBTestCase)
  private
    // проверяет правильность установки флага issimple
    // для позиций сложных и простых проводок
    procedure TestIsSimpleField(q: TIBSQL);

    // метод проверяет соответствие сумм в шапке проводки и
    // позициях, равенство сумм в шапке для
    // корректных проводок, а также правильность заполнения
    // дебетовых сумм для кредлитов и наоборот
    procedure TestEqualOfDebitAndCreditSum(q: TIBSQL);

    // проверяет наличие в базе проводок, помеченных как incorrect
    procedure TestIncorrectRecords(q: TIBSQL);

    // проверяет соответствие полей в шапке и позиции
    // проводки
    procedure TestEntryConsistency(q: TIBSQL);

    // проверяет отсутствие флагов разблокировки изменения записи
    procedure TestUnlockFlags(q: TIBSQL);

    // проверяет количество дебетов и кредитов в сложной проводке
    procedure TestEntryCount(q: TIBSQL);

    // все вышеперечисленные проверки, вместе взятые
    procedure TestConsistentState(q: TIBSQL);

  published
    procedure Test_AcEntry;
    procedure Test_gdcAcctEntryRegister;
  end;

implementation

uses
  DB, SysUtils, gdcBaseInterface, gd_security, gdcAcctEntryRegister, jclStrings;

{ Tgs_AcEntry }

procedure Tgs_AcEntryTest.TestConsistentState(q: TIBSQL);
begin
  TestIsSimpleField(q);
  TestEqualOfDebitAndCreditSum(q);
  TestIncorrectRecords(q);
  TestEntryConsistency(q);
  TestUnlockFlags(q);
  TestEntryCount(q);
end;

procedure Tgs_AcEntryTest.TestEntryConsistency(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text :=
    'SELECT * FROM ac_record r JOIN ac_entry e ON e.recordkey = r.id ' +
    'WHERE r.recorddate <> e.entrydate OR r.companykey <> e.companykey ' +
    '  OR r.documentkey <> e.documentkey OR r.masterdockey <> e.masterdockey ' +
    '  OR r.transactionkey <> e.transactionkey';
  q.ExecQuery;
  Check(q.EOF);
end;

procedure Tgs_AcEntryTest.TestEntryCount(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text :=
    'SELECT e.recordkey, SUM(IIF(e.accountpart = ''D'', 1, 0)), SUM(IIF(e.accountpart = ''C'', 1, 0)) ' +
    'FROM ac_entry e ' +
    'GROUP BY 1 ' +
    'HAVING SUM(IIF(e.accountpart = ''D'', 1, 0)) > 1 AND SUM(IIF(e.accountpart = ''C'', 1, 0)) > 1 ';
  q.ExecQuery;
  Check(q.EOF, 'Сложные проводки с множественными дебетами и кредитами');
end;

procedure Tgs_AcEntryTest.TestEqualOfDebitAndCreditSum(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text :=
    'select * from ac_record where ((creditncu <> debitncu and creditncu <> 0 and debitncu <> 0) ' +
    '  or (creditcurr <> debitcurr and creditcurr <> 0 and debitcurr <> 0)) and incorrect=0 ';
  q.ExecQuery;
  Check(q.EOF, 'Проверка дебетовой и кредитовой части в шапке проводки');

  q.Close;
  q.SQL.Text :=
    'SELECT * FROM ac_record r ' +
    'WHERE ' +
    '  r.debitncu <> COALESCE((SELECT SUM(e.debitncu) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.creditncu <> COALESCE((SELECT SUM(e.creditncu) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.debitcurr <> COALESCE((SELECT SUM(e.debitcurr) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) OR ' +
    '  r.creditcurr <> COALESCE((SELECT SUM(e.creditcurr) FROM AC_ENTRY e WHERE e.recordkey = r.id), 0) ';
  q.ExecQuery;
  Check(q.EOF, 'Проверка соответствия сумм в шапке и позициях проводки');

  q.Close;
  q.SQL.Text :=
    'SELECT SUM(ABS(COALESCE(debitncu, 0)) + ABS(COALESCE(debitcurr, 0)) + ABS(COALESCE(debiteq, 0))) ' +
    'FROM ac_entry WHERE accountpart = ''C'' ';
  q.ExecQuery;
  Check(q.Fields[0].AsCurrency = 0, 'Ненулевые суммы по дебету для кредитовых частей');

  q.Close;
  q.SQL.Text :=
    'SELECT SUM(ABS(COALESCE(creditncu, 0)) + ABS(COALESCE(creditcurr, 0)) + ABS(COALESCE(crediteq, 0))) ' +
    'FROM ac_entry WHERE accountpart = ''D'' ';
  q.ExecQuery;
  Check(q.Fields[0].AsCurrency = 0, 'Ненулевые суммы по кредиту для дебетовых частей');
end;

procedure Tgs_AcEntryTest.TestIncorrectRecords(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text := 'SELECT * FROM ac_record WHERE incorrect <> 0';
  q.ExecQuery;
  Check(q.EOF, 'Записи в AC_RECORD с incorrect = 1');
end;

procedure Tgs_AcEntryTest.TestIsSimpleField(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text :=
    'SELECT recordkey, accountpart, COUNT(*), SUM(issimple) ' +
    'FROM ac_entry ' +
    'GROUP BY 1,2 ' +
    'HAVING (COUNT(*) > 1 AND SUM(issimple) <> 0) ' +
    '  OR (COUNT(*) = 1 AND SUM(issimple) = 0)';
  q.ExecQuery;
  Check(q.EOF, 'Проверка поля issimple');
end;

procedure Tgs_AcEntryTest.TestUnlockFlags(q: TIBSQL);
begin
  q.Close;
  q.SQL.Text :=
    'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'') FROM rdb$database';
  q.ExecQuery;
  Check(q.Fields[0].IsNull);

  q.Close;
  q.SQL.Text :=
    'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'') FROM rdb$database';
  q.ExecQuery;
  Check(q.Fields[0].IsNull);
end;

procedure Tgs_AcEntryTest.Test_AcEntry;
const
  DocTypeID = 806000;
  TrID      = 807001;
  //CompanyID = 650010;
  TrRecordID= 807100;
  Acc00     = 300003;
  Acc01     = 300100;
  Acc08     = 300800;
  Acc25     = 322500;
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
    q.Close;
    q.SQL.Text :=
      'INSERT INTO gd_document ' +
      '  (id, documenttypekey, transactionkey, number, documentdate, companykey, creatorkey, editorkey) ' +
      'VALUES (:id, :dt, :tk, :n, CURRENT_DATE, :ck, :uk, :uk)';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('dt').AsInteger := DocTypeID;
    q.ParamByName('tk').AsInteger := TrID;
    q.ParamByName('n').AsString := N;
    q.ParamByName('ck').AsInteger := IBLogin.CompanyKey;
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
    FQ.SQL.Text :=
      'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'') FROM rdb$database';
    FQ.ExecQuery;
    Check(FQ.Fields[0].IsNull);

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

    FQ.Close;
    FQ.SQL.Text :=
      'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'') FROM rdb$database';
    FQ.ExecQuery;
    Check(FQ.Fields[0].AsString > '');

    FTr.Commit;
    FTr.StartTransaction;

    FQ.Close;
    FQ.SQL.Text := 'SELECT COUNT(*) FROM ac_record WHERE id > :id';
    FQ.ParamByName('id').AsInteger := MaxID;
    FQ.ExecQuery;
    Check(FQ.Fields[0].AsInteger = 0);

    FQ.Close;
    FQ.SQL.Text :=
      'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'') FROM rdb$database';
    FQ.ExecQuery;
    Check(FQ.Fields[0].IsNull);

    TestIncorrectRecords(FQ);
  end;

var
  DocID, DocID2: TID;
  RecID: TID;
  EntryID, EntryID2, EntryID3: TID;
begin
  //
  TestConsistentState(FQ);

  DocID := InsertDoc(FQ, gdcBaseManager.GetNextID, '1');
  DocID2 := InsertDoc(FQ, gdcBaseManager.GetNextID, '2');

  // у голой шапки проводки incorrect = 1
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, IBLogin.CompanyKey);
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

  // проверяем очистку переменной AC_RECORD_INCORRECT
  // без закрытия транзакции
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'') FROM rdb$database';
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsString > '');
  FQ2.Close;
  FQ2.SQL.Text := 'DELETE FROM ac_record WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := RecID;
  FQ2.ExecQuery;
  FQ.Close;
  FQ.ExecQuery;
  Check(FQ.Fields[0].IsNull);

  // проверим работу списка некорректных проводок, когда
  // их ИД умещаются в строку
  TestIncorrectList(10, DocID, IBLogin.CompanyKey);

  // проверим работу списка некорректных проводок, когда
  // их ИД не умещаются в строку
  TestIncorrectList(1000, DocID, IBLogin.CompanyKey);

  // шапка должна удалиться, после удаления последней
  // записи в ac_entry
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, IBLogin.CompanyKey);
  EntryID := InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc01, 'D',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    IBLogin.CompanyKey, DocID, DocID, TrID);
  FQ.Close;
  FQ.SQL.Text := 'DELETE FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;

  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.EOF);

  // тестируем позиции проводки
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, IBLogin.CompanyKey);

  EntryID := InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc01, 'D',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    IBLogin.CompanyKey, DocID, DocID, TrID);

  // у шапки неполной проводки incorrect = 1
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 1);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);

  EntryID2 := InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc08, 'C',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    IBLogin.CompanyKey, DocID, DocID, TrID);

  // теперь incorrect = 0
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 0);

  // issimple = 1
  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID2;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);

  EntryID3:= InsertAcEntry(FQ, gdcBaseManager.GetNextID, RecID, Acc25, 'C',
    100, 100, 100, 100, 100, 100, BelRubID,
    EncodeDate(2000, 01, 01),
    IBLogin.CompanyKey, DocID, DocID, TrID);

  // incorrect = 1
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 1);

  // issimple
  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID2;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID3;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);

  FQ.Close;
  FQ.SQL.Text := 'UPDATE ac_entry SET debitncu=200, debitcurr=200, debiteq=200 WHERE id=' + IntToStr(EntryID);
  FQ.ExecQuery;

  // incorrect = 0
  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_record WHERE id = :id';
  FQ.ParamByName('id').AsInteger := RecID;
  FQ.ExecQuery;
  Check(FQ.FieldByName('incorrect').AsInteger = 0);

  // issimple
  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID2;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);

  FQ.Close;
  FQ.SQL.Text := 'SELECT issimple FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID3;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);

  // нельзя менять док ид у проводки
  FQ.Close;
  FQ.SQL.Text := 'UPDATE ac_entry SET documentkey = :DK WHERE id = :ID';
  FQ.ParamByName('DK').AsInteger := DocID2;
  FQ.ParamByName('ID').AsInteger := EntryID;
  FQ.ExecQuery;

  FQ.Close;
  FQ.SQL.Text := 'SELECT documentkey FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = DocID);

  // меняем док ид у напки
  FQ.Close;
  FQ.SQL.Text := 'UPDATE ac_record SET documentkey = :DK WHERE id = :ID';
  FQ.ParamByName('DK').AsInteger := DocID2;
  FQ.ParamByName('ID').AsInteger := RecID;
  FQ.ExecQuery;

  FQ.Close;
  FQ.SQL.Text := 'SELECT documentkey FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = DocID2);

  FQ.Close;
  FQ.SQL.Text := 'SELECT documentkey FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID2;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = DocID2);

  FQ.Close;
  FQ.SQL.Text := 'SELECT documentkey FROM ac_entry WHERE id = :id';
  FQ.ParamByName('id').AsInteger := EntryID3;
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = DocID2);

  //
  TestConsistentState(FQ);
end;

procedure Tgs_AcEntryTest.Test_gdcAcctEntryRegister;
var
  Obj: TgdcAcctEntryRegister;
begin
  Obj := TgdcAcctEntryRegister.Create(nil);
  try
    Obj.Open;
    Check(StrIPos('DOC.USR$SORTNUMBER', Obj.SelectSQL.Text) = 0);
    Check(StrIPos('C.USR$GS_CUSTOMER', Obj.SelectSQL.Text) = 0);
    Check(Obj.FieldByName('USR$GS_CUSTOMER').DataType = ftInteger);
  finally
    Obj.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_AcEntryTest.Suite);
end.
