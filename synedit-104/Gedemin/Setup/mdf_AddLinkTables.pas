unit mdf_AddLinkTables;

interface

uses
  IBDatabase, gdModify;

procedure AddLinkTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure AddLinkTables(IBDB: TIBDatabase; Log: TModifyLog);
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
          'SELECT * FROM rdb$relation_fields ' +
          'WHERE ' +
          '  rdb$relation_name = ''GD_LINK'' AND rdb$field_name = ''LINKEDORDER''';
        ExecQuery;
        if Eof then
        begin
          Log('Добавление поддержки прикрепления');
          Close;
          SQL.Text :=
            'RECREATE TABLE gd_link '#13#10 +
            '( '#13#10 +
            '  id            dintkey, '#13#10 +
            '  objectkey     dintkey, '#13#10 +
            '  linkedkey     dintkey, '#13#10 +
            '  linkedclass   dclassname NOT NULL, '#13#10 +
            '  linkedsubtype dclassname, '#13#10 +
            '  linkedname    dname, '#13#10 +
            '  linkedusertype dtext20, '#13#10 +
            '  linkedorder   INTEGER, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT gd_pk_link_id PRIMARY KEY (id) '#13#10 +
            ') ';
          ExecQuery;
          Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;
          Log('Добавление поддержки прикрепления прошло успешно');
        end;
        Close;
        SQL.Text := 'GRANT ALL ON gd_link TO administrator';
        ExecQuery;
        FTransaction.Commit;

      finally
        FIBSQL.Free;
      end;
    except
        Log('Ошибка при добавлении поддержки прикрепления');
    end;
  finally
    FTransaction.Free;
  end;


end;

end.
