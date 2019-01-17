unit mdf_AddRestrFieldToInv_BalanceOption;

interface
 
uses
  IBDatabase, gdModify;

procedure AddRestrFieldToInv_BalanceOption(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddIBAN(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

procedure AddIBAN(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      try
        if not RelationExist2('GD_AVAILABLE_ID', FTr) then
        begin
          q.SQL.Text :=
            'CREATE TABLE gd_available_id ( '#13#10 +
            '  id_from       dintkey, '#13#10 +
            '  id_to         dintkey, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT gd_pk_available_id PRIMARY KEY (id_from, id_to), '#13#10 +
            '  CONSTRAINT gd_chk_available_id CHECK (id_from <= id_to) '#13#10 +
            ')';
          q.ExecQuery;

          AddField2('GD_BANK', 'OLDBANKCODE', 'DTEXT20', FTr);
          AddField2('GD_BANK', 'OLDBANKMFO', 'DTEXT20', FTr);

          DropIndex2('GD_X_BANK_BANKCODE', FTr);

          FTr.Commit;
          FTr.StartTransaction;

          q.Close;
          q.SQL.Text := 'CREATE INDEX gd_x_bank_bankcode ON gd_bank (bankcode)';
          q.ExecQuery;

          AddField2('GD_COMPANYACCOUNT', 'OLDACCOUNT', 'DBANKACCOUNT', FTr);
          AddField2('GD_COMPANYACCOUNT', 'IBAN', 'DBANKACCOUNT', FTr);

          DropTrigger2('gd_aiu_companyaccount', FTr);

          FTr.Commit;
          FTr.StartTransaction;
        end;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (263, ''0000.0001.0000.0294'', ''15.06.2017'', ''Preparing for IBAN and BIC'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (264, ''0000.0001.0000.0295'', ''18.06.2017'', ''Preparing for IBAN and BIC #2'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (265, ''0000.0001.0000.0296'', ''04.07.2017'', ''Preparing for IBAN and BIC #3'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (266, ''0000.0001.0000.0297'', ''13.07.2017'', ''Preparing for IBAN and BIC #4'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

procedure AddRestrFieldToInv_BalanceOption(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      try
        AddField2('INV_BALANCEOPTION', 'RESTRICTREMAINSBY', 'DTEXT32', FTr);

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (262, ''0000.0001.0000.0293'', ''31.03.2017'', ''Added restrict remains field to INV_BALANCEOPTION'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

end.