unit mdf_wageUpdateFields;

interface

uses
  IBDatabase, gdModify;

procedure ModifyWageFields(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyBankRuid(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyWageFields1(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ModifyWageFields(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    FIBSQL.Transaction := FTransaction;
    try
      try
        // проверяем необходимость модификации
        FIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relation_fields '#13#10 +
          'WHERE RDB$RELATION_NAME = ''USR$WG_CHILDCAT'' '#13#10 +
          '  AND rdb$field_name = ''USR$AGELIMIT'' '#13#10 +
          '  AND RDB$FIELD_SOURCE = ''DSMALLINT'' ';
        FIBSQL.ExecQuery;
        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          // проверяем наличие домена
          FIBSQL.SQL.Text :=
            'SELECT * FROM rdb$fields '#13#10 +
            'WHERE rdb$field_name = ''USR$WG_D_CHILDCAT'' ';
          FIBSQL.ExecQuery;
          if FIBSQL.Eof then
          begin
            FIBSQL.Close;
            //создадим домен
            try
              FIBSQL.SQL.Text :=
                'CREATE DOMAIN USR$WG_D_CHILDCAT AS '#13#10 +
                'NUMERIC(4,1) '#13#10 +
                'CHECK (VALUE >= 0 AND VALUE <= 120) ';
              FIBSQL.ExecQuery;
              FIBSQL.Transaction.Commit;
              Log('Создан домен USR$WG_D_CHILDCAT');
            except
              FIBSQL.Transaction.Rollback;
            end;
          end;

          //Обновим таблицу
          try
            FIBSQL.Close;
            if not FTransaction.Active then
              FTransaction.StartTransaction;
            FIBSQL.SQL.Text :=
              'ALTER TABLE usr$wg_childcat '#13#10 +
              'ALTER COLUMN usr$agelimit TYPE usr$wg_d_childcat';
            FIBSQL.ExecQuery;
            FIBSQL.Transaction.Commit;
            Log('Изменено поле USR$AGELIMIT в таблице USR$WG_CHILDCAT');
          except
            FIBSQL.Transaction.Rollback;
            Log('Ошибка при измененении поля USR$AGELIMIT в таблице USR$WG_CHILDCAT');
          end;
        end;

        //если была очень старая настройка
        //проверяем необходимость модификации
        if not FTransaction.Active then
          FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT * FROM RDB$RELATION_FIELDS '#13#10 +
          'WHERE RDB$RELATION_NAME = ''USR$WG_BRIGADEORDER'' '#13#10 +
          '  AND RDB$FIELD_NAME = ''USR$DISTRIBTYPE'' '#13#10 +
          '  AND RDB$FIELD_SOURCE = ''USR$WG_D_DISTRIBTYPE'' ';
        FIBSQL.ExecQuery;
        if not FIBSQL.Eof then
        begin
          // обновим таблицу
          try
            //т.к. со старым доменов вообще не работает, просто удалим его и создадим поле заново
            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'ALTER TABLE USR$WG_BRIGADEORDER '#13#10 +
              'DROP USR$DISTRIBTYPE ';
            FIBSQL.ExecQuery;
            FIBSQL.Transaction.Commit;

            FTransaction.StartTransaction;
            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'ALTER TABLE USR$WG_BRIGADEORDER '#13#10 +
              'ADD USR$DISTRIBTYPE DSMALLINT ';
            FIBSQL.ExecQuery;
            FIBSQL.Transaction.Commit;

            Log('Изменено поле USR$DISTRIBTYPE в таблице USR$WG_BRIGADEORDER');
          except
            FIBSQL.Transaction.Rollback;
            Log('Ошибка при изменении поля USR$DISTRIBTYPE в таблице USR$WG_BRIGADEORDER');
          end;
        end;

        if not FTransaction.Active then
          FTransaction.StartTransaction;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT gen_id(GD_G_ATTR_VERSION, 1) FROM rdb$database';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (91, ''0000.0001.0000.0119'', ''26.02.2007'', ''Some internal changes'')';
        try
          FIBSQL.ExecQuery;
        except
        end;
        FIBSQL.Close;
        FIBSQL.Transaction.Commit;

        FIBSQL.Transaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'ALTER PROCEDURE GD_P_GETRUID(ID INTEGER) '#13#10 +
          '  RETURNS (XID INTEGER, DBID INTEGER) '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  XID = NULL; '#13#10 +
          '  DBID = NULL; '#13#10 +
          ' '#13#10 +
          '  IF (NOT :ID IS NULL) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    SELECT xid, dbid '#13#10 +
          '    FROM gd_ruid '#13#10 +
          '    WHERE id=:ID '#13#10 +
          '    INTO :XID, :DBID; '#13#10 +
          ' '#13#10 +
          '    IF (XID IS NULL) THEN '#13#10 +
          '    BEGIN '#13#10 +
          '      XID = ID; '#13#10 +
          '      DBID = GEN_ID(gd_g_dbid, 0); '#13#10 +
          ' '#13#10 +
          '      INSERT INTO gd_ruid(id, xid, dbid, modified, editorkey) '#13#10 +
          '        VALUES(:ID, :XID, :DBID, CURRENT_TIMESTAMP, NULL); '#13#10 +
          '    END '#13#10 +
          '  END '#13#10 +
          ' '#13#10 +
          '  SUSPEND; '#13#10 +
          'END ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (92, ''0000.0001.0000.0120'', ''22.04.2007'', ''GD_P_GETRUID changed'')';
        try
          FIBSQL.ExecQuery;
        except
        end;
        FIBSQL.Close;
        FIBSQL.Transaction.Commit;

      except
        FTransaction.Rollback;
      end;

    finally
      FIBSQL.Free;
    end;

  finally
    FTransaction.Free;
  end;
end;

procedure ModifyBankRuid(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    FIBSQL.Transaction := FTransaction;
    try
      try

        FIBSQL.SQL.Text :=
          'update gd_ruid set XID = 1020002, DBID = 17 where ID = 1020002';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (93, ''0000.0001.0000.0121'', ''02.05.2007'', ''RUID changed'')';
        try
          FIBSQL.ExecQuery;
        except
        end;
        FIBSQL.Close;
        FIBSQL.Transaction.Commit;

      except
        FTransaction.Rollback;
      end;

    finally
      FIBSQL.Free;
    end;

  finally
    FTransaction.Free;
  end;
end;

procedure ModifyWageFields1(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    FIBSQL := TIBSQL.Create(nil);
    FIBSQL.Transaction := FTransaction;
    try
      try
        FIBSQL.Close;
        // проверяем наличие домена
        FIBSQL.SQL.Text :=
          'SELECT * FROM rdb$fields '#13#10 +
          'WHERE rdb$field_name = ''USR$WG_D_CHILDCAT'' ';
        FIBSQL.ExecQuery;
        if not FIBSQL.Eof then
        begin
          try
            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'ALTER DOMAIN USR$WG_D_CHILDCAT DROP CONSTRAINT';
            FIBSQL.ExecQuery;

            FIBSQL.Close;
            FIBSQL.SQL.Text :=
              'ALTER DOMAIN USR$WG_D_CHILDCAT ADD CHECK (VALUE IS NULL OR (VALUE >= 0 AND VALUE <= 120))';

            FIBSQL.Transaction.Commit;
            Log('Изменен домен USR$WG_D_CHILDCAT');
          except
            FIBSQL.Transaction.Rollback;
          end;

        end;

        if not FTransaction.Active then
          FTransaction.StartTransaction;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (94, ''0000.0001.0000.0122'', ''07.05.2007'', ''Some internal changes'')';
        try
          FIBSQL.ExecQuery;
        except
        end;
        FIBSQL.Close;
        FIBSQL.Transaction.Commit;

      except
        FTransaction.Rollback;
      end;

    finally
      FIBSQL.Free;
    end;

  finally
    FTransaction.Free;
  end;
end;

end.
