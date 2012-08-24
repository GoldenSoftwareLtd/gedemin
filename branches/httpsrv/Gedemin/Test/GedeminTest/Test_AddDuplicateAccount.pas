unit Test_AddDuplicateAccount;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, IBSQL;

type
  Tgs_DuplicateAccountsTest = class(TgsDBTestCase)
  published
    procedure Test_DuplicateAccounts;
  end;

implementation

uses
  SysUtils, gd_security, IB, gdcBaseInterface;

procedure Tgs_DuplicateAccountsTest.Test_DuplicateAccounts;

  function InsertAcAccount(q: TIBSQL; const AnID, AParent: TID; const AName, AnAlias, AnAccounttype: String): TID;
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO ac_account (id, parent, name, alias, accounttype, activity)' +
      'VALUES (:id, :parent, :name, :alias, :accounttype, ''A'')';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('parent').AsInteger := AParent;
    q.ParamByName('name').AsString := AName;
    q.ParamByName('alias').AsString := AnAlias;
    q.ParamByname('accounttype').AsString := AnAccounttype;
    q.ExecQuery;
    Result := AnID;
  end;

  function InsertAcAccountParent(q: TIBSQL; const AnID: TID; const AName, AnAlias: String): TID;
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO ac_account (id, parent, name, alias, accounttype, activity)' +
      'VALUES (:id, NULL, :name, :alias, ''C'', ''A'')';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('name').AsString := AName;
    q.ParamByName('alias').AsString := AnAlias;
    q.ExecQuery;
    Result := AnID;
  end;

var
  Plan1, Plan2: TID;
  Account1, account2: TID;
  SubAccount1, SubAccount2: TID;
  AccountF: TID;
begin
  Plan1 := InsertAcAccountParent(FQ, gdcBaseManager.GetNextID, 'ѕлан1', 'ѕлан1');
  Plan2 := InsertAcAccountParent(FQ, gdcBaseManager.GetNextID, 'ѕлан2', 'ѕлан2');
  AccountF := InsertAcAccount(FQ, gdcBaseManager.GetNextID, Plan1, '«абалансовые счета', '«абалансовые счета', 'F');

  Account1 := InsertAcAccount(FQ, gdcBaseManager.GetNextID, AccountF, '—чет1', '1', 'A');
  Account2 := InsertAcAccount(FQ, gdcBaseManager.GetNextID, Plan2, '—чет1', '1', 'A');

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_account WHERE id = :id';
  FQ.ParamByName('id').AsInteger := Account2;
  FQ.ExecQuery;
  Check(not FQ.EOF);

  SubAccount1 := InsertAcAccount(FQ, gdcBaseManager.GetNextID, Account1, '—уб—чет1', '1.1', 'S');
  SubAccount2 := InsertAcAccount(FQ, gdcBaseManager.GetNextID, Account2, '—уб—чет2', '1.1', 'S');

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM ac_account WHERE id = :id';
  FQ.ParamByName('id').AsInteger := SubAccount2;
  FQ.ExecQuery;
  Check(not FQ.EOF);

  StartExpectingException(EIBInterBaseError);
  InsertAcAccount(FQ, gdcBaseManager.GetNextID, Account1, '—уб—чет2', '1.1', 'S');
  StopExpectingException('');

  StartExpectingException(EIBInterBaseError);
  InsertAcAccount(FQ, gdcBaseManager.GetNextID, AccountF, '—уб—чет2', '1.2', 'S');
  StopExpectingException('');

  StartExpectingException(EIBInterBaseError);
  InsertAcAccount(FQ, gdcBaseManager.GetNextID, AccountF, '—чет2', '1', 'A');
  StopExpectingException('');

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE ac_account SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := SubAccount1;
  FQ2.ParamByName('parent').AsInteger := AccountF;
  StartExpectingException(EIBInterBaseError);
  FQ2.ExecQuery;
  StopExpectingException('');
end;

initialization
  RegisterTest('DB', Tgs_DuplicateAccountsTest.Suite);
end.
