unit mdf_Fix_GD_TAXTYPE;

interface

uses
  IBDatabase, gdModify;

procedure Fix_GD_TAXTYPE(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure Fix_GD_TAXTYPE(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin

  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    try
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := ' SELECT * FROM GD_TAXTYPE WHERE ID IN(100200, 200300, 300400) ';
        FIBSQL.ExecQuery;
        if not FIBSQL.EOF then
        begin
          FIBSQL.Transaction.Commit;
          
          try
            IBDB.Connected := False;
          finally
            IBDB.Connected := True;
          end;

          FIBSQL.Transaction.StartTransaction;
          FIBSQL.SQL.Text := ' ALTER TABLE GD_TAXACTUAL DROP CONSTRAINT FK_GD_TAXACTUAL_T ';
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;

          FIBSQL.Transaction.StartTransaction;
          FIBSQL.SQL.Text := ' alter table GD_TAXACTUAL add constraint FK_GD_TAXACTUAL_T ' +
            ' foreign key (TYPEKEY) references GD_TAXTYPE(ID) on update CASCADE ';

          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;

          FIBSQL.Transaction.StartTransaction;
          FIBSQL.SQL.Text := 'ALTER TRIGGER GD_BU_TAXTYPE ' +
            ' INACTIVE BEFORE UPDATE POSITION 0 ' +
            ' AS ' +
            '  BEGIN ' +
            '    EXCEPTION gd_e_taxtype; ' +
            '  END ';

          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;


          FIBSQL.Transaction.StartTransaction;
          FIBSQL.SQL.Text := ' UPDATE GD_TAXTYPE SET ID = 350001 WHERE ID = 100200 ';
          FIBSQL.ExecQuery;
          FIBSQL.SQL.Text := ' UPDATE GD_TAXTYPE SET ID = 350002 WHERE ID = 200300 ';
          FIBSQL.ExecQuery;
          FIBSQL.SQL.Text := ' UPDATE GD_TAXTYPE SET ID = 350003 WHERE ID = 300400 ';
          FIBSQL.ExecQuery;

          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          FIBSQL.Transaction.StartTransaction;
          FIBSQL.SQL.Text := 'ALTER TRIGGER GD_BU_TAXTYPE ' +
            ' ACTIVE BEFORE UPDATE POSITION 0 ' +
            ' AS ' +
            '  BEGIN ' +
            '    EXCEPTION gd_e_taxtype; ' +
            '  END ';

          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;

          Log('Таблица gd_taxtype скорректирована');
        end;

      except

        FTransaction.Rollback;
        Log('Ошибка корректировки таблицы GD_TAXTYPE');
      end;
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;

end;


end.
