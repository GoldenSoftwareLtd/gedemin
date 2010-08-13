
unit mdf_AddDefaultToBoolean;

interface

uses
  IBDatabase, gdModify;

procedure AddDefaultToBoolean(IBDB: TIBDatabase; Log: TModifyLog);
procedure ChangeIsCheckNumberType(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit;

procedure AddDefaultToBoolean(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.SQL.Text := 'ALTER DOMAIN dboolean SET DEFAULT 0';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER DOMAIN dboolean_notnull SET DEFAULT 0';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (121, ''0000.0001.0000.0152'', ''27.07.2010'', ''Added DEFAULT 0 to boolean domains'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
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
    FTransaction.Free;
  end;
end;

procedure ChangeIsCheckNumberType(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.SQL.Text := 'ALTER TABLE gd_documenttype ALTER ischecknumber TYPE SMALLINT';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TABLE gd_documenttype ALTER ischecknumber SET DEFAULT 0';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER TABLE gd_documenttype ADD CONSTRAINT gd_chck_icn_documenttype CHECK (ischecknumber BETWEEN 0 AND 3)';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (122, ''0000.0001.0000.0153'', ''12.08.2010'', ''IsCheckNumber now allows 4 possible values'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
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
    FTransaction.Free;
  end;
end;

end.
