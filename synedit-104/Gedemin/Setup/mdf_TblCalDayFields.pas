unit mdf_TblCalDayFields;

interface

uses
  IBDatabase, gdModify;

procedure ModifyTblCalFields(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyTblCalDayFields(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure ModifyTblCalFields;
var
  i: Byte;
  FName: String;

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
        // проверяем необходимость модификации (есть ли поле w4_offset)
        if not FTransaction.Active then
          FTransaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relation_fields '#13#10 +
          'WHERE RDB$RELATION_NAME = ''WG_TBLCAL'' '#13#10 +
          'AND rdb$field_name = ''W4_OFFSET''';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          // добавляем поля
          for i := 1 to 8 do
          begin
            FName := 'w'+IntToStr(i)+'_offset';
            try
              if not FTransaction.Active then
                FTransaction.StartTransaction;
              FIBSQL.SQL.Text := 
                 ' ALTER TABLE WG_TBLCAL ' +
                 ' ADD ' + FName + ' dinteger DEFAULT 0';
              FIBSQL.ExecQuery;
              FIBSQL.Transaction.Commit;                 
              Log('Добавлено поле ' + FName + ' в таблицу WG_TBLCAL');
            except
              FTransaction.Rollback;
            end;
          end;         // for
        end;

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

procedure ModifyTblCalDayFields;
var
  i: Byte;
  FName: String;

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
        if not FTransaction.Active then
          FTransaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relation_fields '#13#10 +
          'WHERE RDB$RELATION_NAME = ''WG_TBLCALDAY'' '#13#10 +
          'AND rdb$field_name = ''WEND4''';

        FIBSQL.ExecQuery;
        if not FIBSQL.EOF then
        begin
          if Trim(FIBSQL.FieldByName('RDB$FIELD_SOURCE').AsString) = 'DTIMESTAMP_NOTNULL' then
          begin
            FTransaction.Rollback;
            Exit;
          end;
        end;
        FIBSQL.Close;
      except
        FTransaction.Rollback;
      end;

      // удаляем constraints
      for i := 1 to 7 do
      begin
        FName := 'WG_CHK_TBLCALDAY_' + IntToStr(i);
        try
          if not FTransaction.Active then
            FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' DROP CONSTRAINT ' + FName ;
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          Log('Удалено ограничение ' + FName + ' в таблице WG_TBLCALDAY');
        except
          FIBSQL.Transaction.Rollback;
        end;
      end;
  
      // удаляем поле wduration
      try
        if not FTransaction.Active then
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' DROP wduration ';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit; 
        Log('Удалено поле wduration в таблице WG_TBLCALDAY');
      except
        FTransaction.Rollback;
      end;

      // удаляем поля
      for i := 1 to 8 do
      begin
        if i > 4 then
          FName := 'wend' + IntToStr(i-4)
        else
          FName := 'wstart' + IntToStr(i);

        try
          if not FTransaction.Active then
            FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' DROP ' + FName ;
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          Log('Удалено поле ' + FName + ' в таблице WG_TBLCALDAY');
        except
          FTransaction.Rollback;
        end;
      end;         // for

      // добавляем поля
      for i := 1 to 8 do
      begin
        if i > 4 then
          FName := 'wend' + IntToStr(i-4)
        else
          FName := 'wstart' + IntToStr(i);

        try
          if not FTransaction.Active then
            FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' ADD ' + FName + ' dtimestamp_notnull DEFAULT ''1900-01-01 00:00:00''';
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          Log('Обновлено поле ' + FName + ' в таблице WG_TBLCALDAY');
        except         
          FTransaction.Rollback;
        end;

      end;         // for
                  
      // wduration
      try
        if not FTransaction.Active then
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' ADD WDURATION COMPUTED BY (G_M_ROUNDNN(((wend1 - wstart1) + (wend2 - wstart2) + (wend3 - wstart3) + (wend4 - wstart4))*24, 0.01)) ';
        FIBSQL.ExecQuery;
        FIBSQL.Transaction.Commit;   
        Log('Добавлено поле WDURATION в таблице WG_TBLCALDAY');
      except
        FTransaction.Rollback;
      end;

      // добавляем constraints
      for i := 1 to 4 do
      begin
        FName := 'wg_chk_tblcalday_'+IntToStr(i);
        try
          if not FTransaction.Active then
            FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' ADD CONSTRAINT ' + FName + ' CHECK (wend'+IntToStr(i)+' >= wstart'+IntToStr(i)+')';
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          Log('Обновлено ограничение ' + FName + ' в таблице WG_TBLCALDAY');
        except
          FTransaction.Rollback;
        end;
      end;         // for

      // добавляем constraints
      for i := 1 to 3 do
      begin
        FName := 'wg_chk_tblcalday_'+IntToStr(i+4);
        try
          if not FTransaction.Active then
            FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
             ' ALTER TABLE WG_TBLCALDAY ' +
             ' ADD CONSTRAINT ' + FName + ' CHECK ((wstart'+IntToStr(i+1)+' = ''1900-01-01 00:00:00'') OR (wstart'+IntToStr(i+1)+' >= wend'+IntToStr(i)+'))';
          FIBSQL.ExecQuery;
          FIBSQL.Transaction.Commit;
          Log('Обновлено ограничение ' + FName + ' в таблице WG_TBLCALDAY');
        except
          FTransaction.Rollback;
        end;
      end;         // for

    finally
      FIBSQL.Free;
    end;

  finally
    FTransaction.Free;
  end;

end;


end.
