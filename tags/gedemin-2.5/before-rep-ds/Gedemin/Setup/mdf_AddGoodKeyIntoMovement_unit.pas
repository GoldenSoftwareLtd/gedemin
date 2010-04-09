unit mdf_AddGoodKeyIntoMovement_unit;


interface

uses
  IBDatabase, gdModify;

procedure AddGoodKeyIntoMovement(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, Controls, Dialogs;


procedure AddGoodKeyIntoMovement(IBDB: TIBDatabase; Log: TModifyLog);
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
      with FIBSQL do
      try
        Transaction := FTransaction;
        SQL.Text :=
         'SELECT * FROM rdb$relation_fields i WHERE UPPER(i.rdb$field_name) = ''GOODKEY'' AND UPPER(i.rdb$relation_name) = ''INV_MOVEMENT''';
        ExecQuery;
        if Eof then
        begin
          if MessageDlg('Добавить поле GOODKEY в таблицы INV_MOVEMENT и INV_BALANCE?', mtConfirmation, [mbYes, mbNo], 0) = mrYes	then
          begin
            Log('Добавление ссылки на товар в inv_movement и inv_balance');
            Log('Внимание данная процедура может выплняться достаточно долго не снимайте задачу, дождитесь ее выполнения');
            Log('-------------------------------------------------------------------------------------------------------');
            Log('Добавление ссылки на товар в inv_movement');
            Close;
            SQL.Text :=
              ' ALTER TABLE inv_movement ADD goodkey dintkey ';
            ExecQuery;
            Close;

            Log('Добавление ссылки на товар в inv_balance');
            Close;
            SQL.Text :=
              ' ALTER TABLE inv_balance ADD goodkey dintkey ';
            ExecQuery;
            Close;

            Log('Добавление триггера для заполнения GOODKEY в inv_balance');
            Close;
            ParamCheck := False;
            SQL.Text :=
            'CREATE TRIGGER INV_BI_BALANCE_GOODKEY FOR INV_BALANCE '#13#10 +
            'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  SELECT goodkey FROM inv_card '#13#10 +
            '  WHERE id = NEW.cardkey '#13#10 +
            '  INTO NEW.goodkey; '#13#10 +
            'END ';
            ExecQuery;
            Close;

            SQL.Text :=
            'CREATE TRIGGER INV_BU_BALANCE_GOODKEY FOR INV_BALANCE '#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 10 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN '#13#10 +
            '    SELECT goodkey FROM inv_card '#13#10 +
            '    WHERE id = NEW.cardkey '#13#10 +
            '    INTO NEW.goodkey; '#13#10 +
            'END ';
            ExecQuery;
            Close;

            Log('Добавление триггера для заполнения GOODKEY в inv_movement');
            Close;
            ParamCheck := False;
            SQL.Text :=
            'CREATE TRIGGER INV_BI_MOVEMENT_GOODKEY FOR INV_MOVEMENT '#13#10 +
            'ACTIVE BEFORE INSERT POSITION 10 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  SELECT goodkey FROM inv_card '#13#10 +
            '  WHERE id = NEW.cardkey '#13#10 +
            '  INTO NEW.goodkey; '#13#10 +
            'END ';
            ExecQuery;
            Close;

            SQL.Text :=
            'CREATE TRIGGER INV_BU_MOVEMENT_GOODKEY FOR INV_MOVEMENT '#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 10 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN '#13#10 +
            '    SELECT goodkey FROM inv_card '#13#10 +
            '    WHERE id = NEW.cardkey '#13#10 +
            '    INTO NEW.goodkey; '#13#10 +
            'END ';
            ExecQuery;
            Close;

            FTransaction.Commit;
            FTransaction.StartTransaction;

            Log('Добавление триггера для обновления GOODKEY в inv_card');

            SQL.Text :=
              'CREATE TRIGGER inv_bu_card_goodkey FOR inv_card '#13#10 +
              '  BEFORE UPDATE '#13#10 +
              '  POSITION 1 '#13#10 +
              'AS '#13#10 +
              'BEGIN '#13#10 +
              '  IF (NEW.GOODKEY <> OLD.GOODKEY) THEN '#13#10 +
              '  BEGIN '#13#10 +
              '    UPDATE inv_movement SET goodkey = NEW.goodkey '#13#10 +
              '    WHERE cardkey = NEW.id; '#13#10 +
              ' '#13#10 +
              '    UPDATE inv_balance SET goodkey = NEW.goodkey '#13#10 +
              '    WHERE cardkey = NEW.id; '#13#10 +
              '  END '#13#10 +
              'END ';
            ExecQuery;
            Close;

            FTransaction.Commit;
            FTransaction.StartTransaction;

            Log('Заполнение поля GOODKEY  в INV_MOVEMENT');

            SQL.Text := 'UPDATE inv_movement SET id = id';
            ExecQuery;
            Close;

            Log('Заполнение поля GOODKEY  в INV_BALANCE');

            SQL.Text := 'UPDATE inv_balance SET cardkey = cardkey ';
            ExecQuery;
            Close;

            FTransaction.Commit;

            IBDB.Connected := False;
            IBDB.Connected := True;
            FTransaction.StartTransaction;

            Log('Добавление индекса в INV_MOVEMENT');

            SQL.Text := 'ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_goodk ' +
                        'FOREIGN KEY (goodkey) REFERENCES gd_good (id) ' +
                        'ON UPDATE CASCADE ';
            ExecQuery;
            Close;

            FTransaction.Commit;

            IBDB.Connected := False;
            IBDB.Connected := True;
            FTransaction.StartTransaction;

            Log('Добавление индекса в INV_BALANCE');

            SQL.Text := 'ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_gk ' +
                        'FOREIGN KEY (goodkey) REFERENCES gd_good (id) ' +
                        'ON DELETE CASCADE ' +
                        'ON UPDATE CASCADE ';
            ExecQuery;
            Close;

            FTransaction.Commit;

            Log('Добавление поля GOODKEY и сопутствующих триггеров и индексов прошло успешно');
          end;
        end;
        if not FTransaction.InTransaction then FTransaction.StartTransaction;
        try
          FIBSQL.Close;
          FIBSQL.ParamCheck := False;
          FIBSQL.SQL.Text :=
            'ALTER PROCEDURE INV_MAKEREST  '#13#10 +
            'AS '#13#10 +
            'DECLARE VARIABLE CONTACTKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE CARDKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE GOODKEY INTEGER; '#13#10 +
            'DECLARE VARIABLE BALANCE NUMERIC(15,4); '#13#10 +
            'BEGIN '#13#10 +
            '  DELETE FROM INV_BALANCE; '#13#10 +
            '  FOR '#13#10 +
            '    SELECT m.contactkey, m.goodkey, m.cardkey, SUM(m.debit - m.credit) '#13#10 +
            '      FROM '#13#10 +
            '        inv_movement m '#13#10 +
            '      WHERE disabled = 0 '#13#10 +
            '    GROUP BY m.contactkey, m.goodkey, m.cardkey '#13#10 +
            '    INTO :contactkey, :goodkey, :cardkey, :balance '#13#10 +
            '  DO '#13#10 +
            '    INSERT INTO inv_balance (contactkey, goodkey, cardkey, balance) '#13#10 +
            '      VALUES (:contactkey, :goodkey, :cardkey, :balance); '#13#10 +
            'END ';

          FIBSQL.ExecQuery;
        except
          FTransaction.Rollback;
        end;

        if FTransaction.InTransaction then
          FTransaction.Commit;

        FTransaction.StartTransaction;
        try
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'INSERT INTO fin_versioninfo ' +
            'VALUES (70, ''0000.0001.0000.0098'', ''10.01.2006'', ''Minor changes'') ';
          FIBSQL.ExecQuery;
        finally
          FTransaction.Commit;
        end;
      finally
        FIBSQL.Free;
      end;
    except
        Log('Ошибка при добавлении поля GOODKEY');
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
