
unit Test_gdcContact_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, gdcContacts;

type
  Tgs_gdcContactTest = class(TgsDBTestCase)
  published
    procedure Test_gdcContact;
  end;

  Tgs_AcEntryTest = class(TgsDBTestCase)
  published
    procedure Test_AcEntry;
  end;

implementation

uses
  SysUtils, IBSQL, gdcBaseInterface, gd_security;

{ Tgs_gdcContactTest }

procedure Tgs_gdcContactTest.Test_gdcContact;
var
  C: TgdcContact;
  F: TgdcFolder;
  ID: TID;
begin
  F := TgdcFolder.Create(nil);
  C := TgdcContact.Create(nil);
  try
    F.Open;
    Check(not F.IsEmpty);

    C.Open;
    C.Insert;
    C.FieldByName('name').AsString := 'Test Name';
    C.FieldByName('surname').AsString := 'Test Surname';
    C.FieldByName('parent').AsInteger := F.ID;
    C.Post;

    ID := C.ID;

    C.Close;
    C.SubSet := 'ByID';
    C.ID := ID;
    C.Open;
    C.Next;

    Check(C.RecordCount = 1);

    C.Delete;
  finally
    C.Free;
    F.Free;
  end;
end;

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
    const DNCU, DCurr, DEq, CNCU, CCurr, CEq: Currency;
    const AnEntryDate: TDateTime;
    const ACompanyID, ADocID, AMasterDocID, ATransactionID: TID): TID;
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO ac_entry (id, recordkey, accountkey, accountpart, ' +
      '  debitncu, debitcurr, debiteq, creditncu, creditcurr, crediteq, ' +
      '  currkey, disabled, reserved, entrydate, issimple, companykey, ' +
      '  documentkey, masterdockey, transactionkey) ' +
      'VALUES (:id, :rk, :ak, :ap, :dncu, :dcurr, :deq, ' +
      '  :cncu, :ccurr, :ceq, :currkey, :disabled, :reserved, :ed, :iss, :ck, ' +
      '  :dock, :mdock, :trk)';
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
  EntryID: TID;
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

  // 
  RecID := InsertAcRecord(FQ, gdcBaseManager.GetNextID, DocID, CompanyID);

end;

initialization
  RegisterTest('DB', Tgs_gdcContactTest.Suite);
  RegisterTest('DB', Tgs_AcEntryTest.Suite);
end.
