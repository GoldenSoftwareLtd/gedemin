unit mdf_AddNewInventTable;

interface

uses
  IBDatabase, gdModify;

procedure AddNewInventTable(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils;

const
  CreateTableSQL =
    'CREATE TABLE inv_balanceoption( '#13#10 +
    '  id                      DINTKEY, '#13#10 +
    '  name                    DNAME, '#13#10 +
    '  viewfields              DBLOBTEXT80, '#13#10 +
    '  sumfields               DBLOBTEXT80, '#13#10 +
    '  branchkey               dforeignkey,               /* Ветка в исследователе */ '#13#10 +
    '  ruid                    DRUID '#13#10 +
    ') ';
  CreatePrimryKey =
    'ALTER TABLE inv_balanceoption ADD CONSTRAINT inv_pk_balanceoption '#13#10 +
    '  PRIMARY KEY (id) ';
  CreateBranchKey =
    'ALTER TABLE inv_balanceoption ADD CONSTRAINT gd_fk_balanceoption_branchkey '#13#10 +
    '  FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE ';

  CreateGenerator = 'CREATE GENERATOR inv_g_balancenum';
  SetGenerator = 'SET GENERATOR inv_g_balancenum TO 0';

  CreateTriggerSQL =
    'CREATE TRIGGER inv_bi_balanceoption FOR inv_balanceoption '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    '  DECLARE VARIABLE id INTEGER; '#13#10 +
    'BEGIN '#13#10 +
    '  /* Если ключ не присвоен, присваиваем */ '#13#10 +
    '  IF (NEW.ID IS NULL) THEN '#13#10 +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    'END ';

  TaxIndexSQL = 'CREATE UNIQUE INDEX gd_x_tax_name ON gd_tax(name)';



procedure AddNewInventTable(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.ParamCheck := False;
        FIBSQL.SQL.Text := 'CREATE DOMAIN druid AS VARCHAR(21) NOT NULL';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;
        FIBSQL.Close;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := CreateTableSQL;
        try
          FIBSQL.ExecQuery;
          Log('Таблица для настройки остатков добавлена успешно');
          FTransaction.Commit;
        except
          on E: Exception do
          begin
            Log(E.Message);
            FTransaction.Rollback;
          end;
        end;
        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := CreatePrimryKey;
        try
          FIBSQL.ExecQuery;
          Log('Добавление первичного ключа прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;
        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := 'GRANT ALL ON inv_balanceoption TO administrator';
        FIBSQL.ExecQuery;
        FTransaction.Commit;

        IBDB.Connected := False;
        IBDB.Connected := True;

        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := CreateBranchKey;
        try
          FIBSQL.ExecQuery;
          Log('Добавление ссылки прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := CreateGenerator;
        try
          FIBSQL.ExecQuery;
          Log('Добавление генератора INV_G_BALANCENUM прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := SetGenerator;
        try
          FIBSQL.ExecQuery;
          Log('Установка генератора INV_G_BALANCENUM прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;
        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := CreateTriggerSQL;
        try
          FIBSQL.ExecQuery;
          Log('Добавление триггера прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := TaxIndexSQL;
        try
          FIBSQL.ExecQuery;
          Log('Добавление индекса GD_X_TAX_NAME прошло успешно');
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;

        FIBSQL.SQL.Text := 'INSERT INTO GD_COMMAND (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) VALUES (740510,740000,''Настройка складских остатков'',''remainsoption'',0,NULL,17,NULL,''TgdcInvRemainsOption'',NULL,-1,-1,-1,0,NULL)';
        try
          FIBSQL.ExecQuery;
          Log('Добавление команды настройки остатков прошло успешно');
        except
        end;

        FIBSQL.SQL.Text := 'DELETE FROM GD_COMMAND WHERE UPPER(classname) = ''TGDCINVREMAINS'' AND UPPER(SubType) = ''ALLREMAINS''';
        try
          FIBSQL.ExecQuery;
          Log('Удаление старой команды просмотра остатков прошло успешно');
        except
        end;

        FTransaction.Commit;

      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка при добавлении таблицы остатков.' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
