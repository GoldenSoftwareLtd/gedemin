unit mdf_EntryQuantitySupport;
interface

uses
  IBDatabase, gdModify;

procedure AddQuantityMetaData(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddQuantityMetaData(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBSQL: TIBSQL;
  IBTransaction: TIBTransaction;
begin
  IBTransaction := TIBTransaction.Create(nil);
  try
    IBTransaction.DefaultDatabase := IBDB;
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Transaction := IBTransaction;
      IBTransaction.StartTransaction;
      try
        IBSQL.SQL.Text :=
          'SELECT * FROM rdb$relations ' +
          'WHERE rdb$relation_name = ''AC_ACCVALUE''';
        IBSQL.ExecQuery;
        if IBSQL.Eof then
        begin
          Log('Количественные показатели проводки: добавление справочника ед.изм. по счету');
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'CREATE TABLE ac_accvalue ' +
            '( ' +
            '  id          dintkey  PRIMARY KEY, ' +
            '  accountkey  dmasterkey, ' +
            '  valuekey    dintkey ' +
            ' )';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'CREATE UNIQUE INDEX ac_idx_accvalue ' +
            '  ON ac_accvalue (accountkey, valuekey)';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'ALTER TABLE ac_accvalue ' +
            'ADD CONSTRAINT fk_ac_accvalue_account ' +
            'FOREIGN KEY (accountkey) ' +
            'REFERENCES ac_account(id) ' +
            '  ON UPDATE CASCADE ' +
            '  ON DELETE CASCADE ';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'ALTER TABLE ac_accvalue ' +
            'ADD CONSTRAINT fk_ac_accvalue_value ' +
            'FOREIGN KEY (valuekey) ' +
            'REFERENCES gd_value(id) ' +
            '  ON UPDATE CASCADE ' +
            '  ON DELETE CASCADE';
          IBSQL.Close;
        end;

        if IBSQL.Open then
          IBSQL.Close;
        IBSQL.SQL.Text :=
          'SELECT * FROM rdb$relations ' +
          'WHERE rdb$relation_name = ''AC_QUANTITY''';
        IBSQL.ExecQuery;
        if IBSQL.Eof then
        begin
          Log('Количественные показатели проводки: добавление таблицы количества проводки.');
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'CREATE TABLE ac_quantity ' +
            '( ' +
            '  id          dintkey  PRIMARY KEY, ' +
            '  entrykey    dmasterkey, ' +
            '  valuekey    dintkey, ' +
            '  quantity    dcurrency ' +
            ' )';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'CREATE UNIQUE INDEX ac_idx_quantity ' +
            '  ON ac_quantity (entrykey, valuekey)';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'ALTER TABLE ac_quantity ' +
            'ADD CONSTRAINT fk_ac_quantity_entry ' +
            'FOREIGN KEY (entrykey) ' +
            'REFERENCES ac_entry(id) ' +
            '  ON UPDATE CASCADE ' +
            '  ON DELETE CASCADE';
          IBSQL.ExecQuery;
          IBSQL.Close;
          IBSQL.SQL.Text :=
            'ALTER TABLE ac_quantity ' +
            'ADD CONSTRAINT fk_ac_quantity_accvalue ' +
            'FOREIGN KEY (valuekey) ' +
            'REFERENCES gd_value(id) ' +
            '  ON UPDATE CASCADE ' +
            '  ON DELETE CASCADE';
          IBSQL.Close;
        end;
        if IBSQL.Open then
          IBSQL.Close;   
        IBSQL.SQL.Text :=
          'GRANT ALL ON ac_quantity TO administrator';
        IBSQL.ExecQuery;

        IBTransaction.Commit;     
      except
        Log('Ошибка! Ошибка добавления поддержки количественных показателей проводки.');
        IBTransaction.Rollback;
      end;
    finally
      IBSQL.Free;
    end;
  finally
    IBTransaction.Free;
  end;
end;

end.
