unit mdf_AddFieldToAC_TRRECORD;

interface
 
uses
  IBDatabase, gdModify;

procedure AddFieldPeriodToAC_TRRECORD(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;
 
procedure AddFieldPeriodToAC_TRRECORD(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;

        Log('Начато добавление полей в таблицу AC_TRRECORD');

        AddField2('AC_TRRECORD', 'dbegin', 'ddate', FTransaction);
        AddField2('AC_TRRECORD', 'dend', 'ddate', FTransaction);

        if not ConstraintExist2('ac_trrecord', 'ac_chk_trrecord_date', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_chk_trrecord_date ' +
            'CHECK ((dbegin IS NULL) OR (dend IS NULL) OR (dbegin <= dend))';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (258, ''0000.0001.0000.0289'', ''15.01.2017'', ''Added period fields to AC_TRRECORD'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        Log('Добавление полей в таблицу AC_TRRECORD успешно завершено');
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTransaction.InTransaction then
            FTransaction.Rollback;
          raise;
        end;
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.