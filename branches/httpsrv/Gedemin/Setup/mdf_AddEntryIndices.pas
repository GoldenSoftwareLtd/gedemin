unit mdf_AddEntryIndices;

interface

uses
  IBDatabase, gdModify;

procedure AddEntryIndices(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript;

procedure AddEntryIndices(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;

  procedure AddIndex(RelationName, IndexName, Fields: string);
  var
    FIBSQL: TIBSQL;
  begin
    FIBSQL := TIBSQL.Create(nil);
    try
      FIBSQL.Transaction := FTransaction;
      FIBSQL.SQL.Text := Format('SELECT * FROM rdb$indices WHERE rdb$relation_name = ''%s'' AND rdb$index_name = ''%s''', [RelationName, IndexName]);
      FIBSQL.ExecQuery;
      if FIBSQL.RecordCount = 0 then
      begin
        Log(Format('Добавление индекса %s в таблицу %s', [IndexName, RelationName]));
        FIBSQL.Close;
        FIBSQL.SQL.Text := Format('CREATE INDEX %s ON %s (%s)', [IndexName, RelationName, Fields]);
        FIBSQL.ExecQuery;
        Log('Добавление прошло успешно');
      end;
     finally
       FIBSQL.Free;
     end;
  end;

begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      AddIndex('AC_ENTRY', 'AC_ENTRY_ENTRYDATE', 'ENTRYDATE');
      AddIndex('AC_ENTRY', 'AC_ENTRY_RECKEY_ACPART', 'RECORDKEY, ACCOUNTPART');
      AddIndex('AC_ENTRY', 'AC_ENTRY_ACKEY_ENTRYDATE', 'ACCOUNTKEY, ENTRYDATE');

      AddIndex('AC_RECORD', 'AC_RECORD_ID_COMKEY_AVIEW', 'ID, COMPANYKEY, AVIEW');
      FTransaction.Commit;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
