unit mdf_AddFieldReportlistModalPreview;

interface

uses
  IBDatabase, gdModify;

procedure AddFieldReportlistModalPreview(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddFieldMacrosListRunLogIn(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit; 

procedure AddFieldReportlistModalPreview(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FIBSQL := TIBSQL.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL.Transaction := FTransaction;
      FTransaction.StartTransaction;

      DropField2('RP_REPORTLIST', 'MODALPREVIEW', FTRansaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      AddField2('RP_REPORTLIST', 'MODALPREVIEW', 'dboolean_notnull DEFAULT 0', FTransaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'UPDATE rp_reportlist SET modalpreview = 0';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (136, ''0000.0001.0000.0167'', ''12.01.2012'', ''Add field modalpreview to the table rp_reportlist'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
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
    FTransaction.Free;
  end;
end;

procedure AddFieldMacrosListRunLogIn(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FIBSQL := TIBSQL.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL.Transaction := FTransaction;
      FTransaction.StartTransaction;

      AddField2('evt_macroslist', 'runonlogin', 'dboolean_notnull DEFAULT 0', FTransaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'UPDATE evt_macroslist SET runonlogin = 0';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'CREATE INDEX evt_x_macrosgroup_isglobal ON evt_macrosgroup (isglobal)';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (138, ''0000.0001.0000.0169'', ''07.03.2012'', ''Add runonlogin field to evt_macroslist table.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (139, ''0000.0001.0000.0170'', ''09.03.2012'', ''Add runonlogin field to evt_macroslist table. Part #2.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
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
    FTransaction.Free;
  end;
end;

end.
