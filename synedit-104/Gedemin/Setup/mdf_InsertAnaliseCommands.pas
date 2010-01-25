unit mdf_InsertAnaliseCommands;

interface

uses
  IBDatabase, gdModify;

procedure InsertAnaliseCommands(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure InsertAnaliseCommands(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Добавление команд в таблицу GD_COMMAND для аналитики');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714030';
        FIBSQL.ExecQuery;
        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714030, 714000, ''Оборотка по аналитике'', ' +
            ' ''714030_17'', ''TfrmProcessingAnalitics'', NULL, 0)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
        end else
          FIBSQL.Close;

        FIBSQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 714040';
        FIBSQL.ExecQuery;
        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := ' INSERT INTO gd_command (id, parent, name, cmd, ' +
            ' classname, hotkey, imgindex) VALUES (714040, 714000, ''Карта по аналитике'', ' +
            ' ''714040_17'', ''Tgdv_frmMapOfAnalitic'', NULL, 0)';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
        end else
          FIBSQL.Close;

        Log('Добавление прошло успешно');
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
