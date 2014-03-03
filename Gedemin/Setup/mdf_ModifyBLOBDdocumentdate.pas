 unit mdf_ModifyBLOBDdocumentdate;
 
  interface
 
  uses
    IBDatabase, gdModify;
 
  procedure ModifyBLOB(IBDB: TIBDatabase; Log: TModifyLog);
 
  implementation
 
  uses
    IBSQL, SysUtils;
 
  procedure ModifyBLOB(IBDB: TIBDatabase; Log: TModifyLog);
  var
    FTransaction: TIBTransaction;
    FIBSQL: TIBSQL;
  begin
    Log('Начато изменение BLOB DDOCUMENTDATE');
    FTransaction := TIBTransaction.Create(nil);
    try
      FTransaction.DefaultDatabase := IBDB;
      FTransaction.StartTransaction;
      try
        FIBSQL := TIBSQL.Create(nil);
        try
          FIBSQL.Transaction := FTransaction;
          
          FIBSQL.Close;
          FIBSQL.SQL.Text := 
            'ALTER DOMAIN ddocumentdate DROP CONSTRAINT';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 
            'ALTER DOMAIN ddocumentdate add' + #13#10 +
            '  CHECK (VALUE BETWEEN ''27.01.1990'' AND ''27.01.2094'')';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'UPDATE OR INSERT INTO fin_versioninfo ' +
            '  VALUES (202, ''0000.0001.0000.0233'', ''03.03.2014'', ''Issue 3323'') ' +
            '  MATCHING (id)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
 
          FTransaction.Commit;
          Log('Изменение BLOB DDOCUMENTDATE успешно завершено');
 
        finally
          FIBSQL.Free;
        end;
      except
        on E: Exception do
        begin
          FTransaction.Rollback;
          Log(E.Message);
        end;
      end;
    finally
      FTransaction.Free;
    end;
  end;  
 
  end.