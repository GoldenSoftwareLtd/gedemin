unit mdf_AddBranchToBankAndIndex;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure AddBranchToBankAndIndex(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddBranchToBankStatement(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;


procedure AddBranchToBankAndIndex(IBDB: TIBDatabase; Log: TModifyLog);
var
  F: TmdfField;
  Index: TmdfIndex;
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  Log(Format('Добавление поля %s', ['bankbranch']));
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    q.Transaction := IBTr;

    try
      F.RelationName := 'gd_bank';
      F.FieldName := 'bankbranch';
      F.Description := 'DTEXT20';
      if not FieldExist(F, IBDB) then
        AddField(F, IBDB);

      Log(Format('Модификация индекса %s', ['bankbranch']));
      Index.RelationName := 'gd_bank';
      Index.IndexName := 'gd_x_bank_bankcode';
      Index.Columns := 'bankcode,bankbranch';
      Index.Unique := True;
      Index.Sort := stAsc;

      if IndexExist(Index, IBDB) then
        DropIndex(Index, IBDB);
      AddIndex(Index, IBDB);


      try
        q.SQL.Text := 'INSERT INTO fin_versioninfo ' +
          'VALUES (73, ''0000.0001.0000.0101'', ''17.04.2006'', ''Field bankbranch added to table gd_bank and changed index '') ';
        q.ExecQuery;
      except
        on E: Exception do
        begin
          Log('Ошибка: ' + E.Message);
        end;
      end;

      IBTr.Commit;
    finally
      q.Free;
      IBTr.Free;
    end;

  except
    on E: Exception do
      Log('Ошибка:' +  E.Message);
  end;

end;

procedure AddBranchToBankStatement(IBDB: TIBDatabase; Log: TModifyLog);
var
  F: TmdfField;
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  Log(Format('Добавление поля %s в выписку', ['bankbranch']));
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    q.Transaction := IBTr;

    try
      F.RelationName := 'bn_bankstatementline';
      F.FieldName := 'bankbranch';
      F.Description := 'dbankcode';
      if not FieldExist(F, IBDB) then
        AddField(F, IBDB);

      q.SQL.Text := 'UPDATE GD_RUID SET DBID=17 WHERE XID < 147000000 AND DBID <> 17 ';
      q.ExecQuery;

      try
        q.SQL.Text := 'INSERT INTO fin_versioninfo ' +
          'VALUES (74, ''0000.0001.0000.0102'', ''04.05.2006'', ''Field bankbranch added to table bn_bankstatementline '') ';
        q.ExecQuery;
      except
        on E: Exception do
        begin
          Log('Ошибка: ' + E.Message);
        end;
      end;

      IBTr.Commit;
    finally
      q.Free;
      IBTr.Free;
    end;

  except
    on E: Exception do
      Log('Ошибка:' +  E.Message);
  end;

end;

end.
