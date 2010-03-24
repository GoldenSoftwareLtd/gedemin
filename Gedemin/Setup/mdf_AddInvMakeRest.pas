
unit mdf_AddInvMakeRest;

interface

uses
  sysutils, IBDatabase, gdModify, mdf_MetaData_unit;

procedure Add_INV_GETCARDMOVEMENT(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Windows, IBSQL;

procedure Add_INV_GETCARDMOVEMENT(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    FIBTransaction.StartTransaction;

    ibsql.Transaction := FIBTransaction;
    ibsql.ParamCheck := False;
    try
      ibsql.SQl.Text:=
        'RECREATE PROCEDURE INV_GETCARDMOVEMENT(' + #13#10 +
        '    CARDKEY INTEGER,' + #13#10 +
        '    CONTACTKEY INTEGER,' + #13#10 +
        '    DATEEND DATE)' + #13#10 +
        'RETURNS (' + #13#10 +
        '    REMAINS NUMERIC(15,4))' + #13#10 +
        'AS' + #13#10 +
        'BEGIN' + #13#10 +
        '  REMAINS = 0;' + #13#10 +
        '  SELECT SUM(m.debit - m.credit)' + #13#10 +
        '  FROM inv_movement m' + #13#10 +
        '  WHERE m.cardkey = :CARDKEY AND m.contactkey = :CONTACTKEY and m.movementdate > :DATEEND' + #13#10 +
        '  INTO :REMAINS;' + #13#10 +
        '  IF (REMAINS IS NULL) THEN' + #13#10 +
        '    REMAINS = 0;' + #13#10 +
        '  SUSPEND;' + #13#10 +
        'END';
      Log('Добавление процедуры INV_GETCARDMOVEMENT ');
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text := 'GRANT EXECUTE ON PROCEDURE INV_GETCARDMOVEMENT TO administrator';
      ibsql.ExecQuery;

      AddFinVersion(81, '0000.0001.0000.0109', 'Добавлена процедура INV_GETCARDMOVEMENT для ускорения вывода остатков на дату', '12.11.2006', FIBTransaction);

      try
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT COUNT(*) FROM gd_document';
        ibsql.ExecQuery;

        if (ibsql.Fields[0].AsInteger < 100000)
          or (MessageBox(0,
            'Рекомендуется выполнить проверку складских остатков.'#13#10 +
            'Проверка может занять длительное время.'#13#10 +
            'Не выключайте компьютер и не снимайте задачу!'#13#10#13#10 +
            'Выполнить проверку?',
            'Внимание',
            MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDYES) then
        begin
          ibsql.Close;
          ibsql.SQL.Text :=
            'EXECUTE PROCEDURE inv_makerest';
          ibsql.ExecQuery;
        end;

        ibsql.Close;
      except
        on E: Exception do
          Log('error:' +  E.Message);
      end;

      AddFinVersion(82, '0000.0001.0000.0110', 'Пересчитываем складские остатки после восстановления складских триггеров', '24.11.2006', FIBTransaction);

      FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log(E.Message);
        raise;
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
