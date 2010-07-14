unit mdf_UpdateHolidays;

interface

uses
  sysutils, IBDatabase, gdModify;

procedure UpdateHolidays(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL;

procedure UpdateHolidays(IBDB: TIBDatabase; Log: TModifyLog);
const
  CheckArray: array [1..3] of String =
    ('WG_UNQ_HOLIDAY_THEDAY_THEMONTH',
     'WG_CHK_HOLIDAY_THEDAY',
     'WG_CHK_HOLIDAY_THEMONTH');
  FieldArray: array [1..2] of String =
    ('THEDAY', 'THEMONTH');
var
  FIBTransaction: TIBTransaction;
  ibsql, ibsqlDrop: TIBSQL;
  I: Integer;
begin
  ibsql := TIBSQL.Create(nil);
  ibsqlDrop := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    ibsqlDrop.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE ' +
        ' rdb$constraint_name = :cn';

      for I := 1 to Length(CheckArray) do
      begin
        ibsql.Close;
        ibsql.ParamByName('cn').AsString := CheckArray[I];
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          FIBTransaction.Commit;
          IBDB.Connected := False;
          IBDB.Connected := True;
          FIBTransaction.StartTransaction;
          ibsqlDrop.Close;
          ibsqlDrop.SQL.Text := ' ALTER TABLE wg_holiday DROP CONSTRAINT ' + CheckArray[I];
          Log('WG_HOLIDAY: Удаление ограничения ' + CheckArray[I]);
          ibsqlDrop.ExecQuery;
        end;
      end;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$relation_name = ''WG_HOLIDAY'' AND rdb$field_name = :fn';
      ibsql.ParamByName('fn').AsString := 'HOLIDAYDATE';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE wg_holiday ADD holidaydate DDATE NOT NULL';
        Log('WG_HOLIDAY: Добавление поля holidaydate DDATE');
        ibsql.ExecQuery;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE wg_holiday SET holidaydate = ' +
          'CAST(CAST(themonth AS VARCHAR(2))||''-''|| CAST(theday AS VARCHAR(2))||''-2002'' AS DATE)';
        Log('WG_HOLIDAY: Обновление поля holidaydate');
        try
          ibsql.ExecQuery;
        except
        end;  
      end;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$relation_name = ''WG_HOLIDAY'' AND rdb$field_name = :fn';

      for I := 1 to Length(FieldArray) do
      begin
        ibsql.Close;
        ibsql.ParamByName('fn').AsString := FieldArray[I];
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          FIBTransaction.Commit;
          IBDB.Connected := False;
          IBDB.Connected := True;
          FIBTransaction.StartTransaction;
          ibsqlDrop.Close;
          ibsqlDrop.SQL.Text := ' ALTER TABLE wg_holiday DROP ' + FieldArray[I];
          Log('WG_HOLIDAY: Удаление поля ' + FieldArray[I]);
          ibsqlDrop.ExecQuery;
        end;
      end;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices ' +
        ' WHERE rdb$index_name = ''WG_X_HOLIDAY_HOLIDAYDATE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' CREATE UNIQUE INDEX wg_x_holiday_holidaydate ON wg_holiday(holidaydate)';
        Log('WG_HOLIDAY: Создание уникального индекса на поле holidaydate');
        ibsql.ExecQuery;
      end;

      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$relation_name = ''WG_TBLCAL'' AND rdb$field_name = :fn';
      ibsql.ParamByName('fn').AsString := 'HOLIDAYISWORK';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE wg_tblcal ADD holidayiswork dboolean_notnull DEFAULT 0';
        Log('WG_TBLCAL: Добавление поля holidayiswork dboolean_notnull DEFAULT 0');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE wg_tblcal SET holidayiswork = 0';
        Log('WG_TBLCAL: Заполнение поля holidayiswork');        
        ibsql.ExecQuery;
      end;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    ibsqlDrop.Free;
    FIBTransaction.Free;
  end;
end;

end.
