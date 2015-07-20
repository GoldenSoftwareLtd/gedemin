unit mdf_AddDomain_dtext25;
 
interface
 
uses
  IBDatabase, gdModify;
 
procedure AddDomain_dtext25(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure AddDomain_dtext25(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Начато добавление домена dtext25');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        
        FIBSQL.SQL.Text :=
          'CREATE DOMAIN dtext25 '#13#10 +
          '  AS VARCHAR(25) CHARACTER SET WIN1251 COLLATE PXW_CYRL';
		  
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_people ALTER COLUMN nickname TYPE dtext25';
		  
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (223, ''0000.0001.0000.0254'', ''20.07.2015'', ''Added domain dtext25.'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

        FTransaction.Commit;
        Log('Добавление домена dtext25 успешно завершено');
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