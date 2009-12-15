unit mdf_AddUseCompanyKey_Balance;

interface

uses
  IBDatabase, gdModify;

procedure AddUseCompanyKey_Balance(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyRpTemplateTrigger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddUseCompanyKey_Balance(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Добавление поле UseCompanyKey в таблицу INV_BALANCEOPTION');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        try
          FIBSQL.SQL.Text := 'SELECT usecompanykey FROM inv_balanceoption';
          FIBSQL.Prepare;
        except
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE inv_balanceoption ADD usecompanykey  DBOOLEAN';
          try
            FIBSQL.ExecQuery;
          except
          end;
          FIBSQL.Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text := 'UPDATE inv_balanceoption SET usecompanykey = 1';
          FIBSQL.ExecQuery;
          FIBSQL.Close;

          Log('Добавление поля - успешно завершено ');
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (100, ''0000.0001.0000.0127'', ''16.01.2008'', ''inv_balanceoption'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;

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

procedure ModifyRpTemplateTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Изменение триггера RP_BI_REPORTTEMPLATE');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'CREATE OR ALTER TRIGGER RP_BI_REPORTTEMPLATE FOR RP_REPORTTEMPLATE '#13#10 +
          'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          '  NEW.templatetype = UPPER(NEW.templatetype); '#13#10 +
          '  IF ((NEW.templatetype <> ''RTF'') AND (NEW.templatetype <> ''FR'') AND '#13#10 +
          '   (NEW.templatetype <> ''XFR'') AND (NEW.templatetype <> ''GRD'') AND (NEW.templatetype <> ''FR4'')) THEN '#13#10 +
          '    EXCEPTION rp_e_invalidreporttemplate; '#13#10 +
          'END';
        FIBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (101, ''0000.0001.0000.0128'', ''10.06.2008'', ''FastReport4'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
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
