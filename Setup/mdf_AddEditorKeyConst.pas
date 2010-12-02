unit mdf_AddEditorKeyConst;

interface

uses
  IBDatabase, gdModify;

procedure AddEditorKeyConst(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddEditorKeyConst(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('Добавление EditorKey и EDITIONDATE в константы');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        try
          FIBSQL.SQL.Text := 'SELECT editorkey FROM gd_constvalue';
          FIBSQL.Prepare;
        except
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE gd_constvalue ADD editorkey dforeignkey ';
          try
            FIBSQL.ExecQuery;
          except
          end;
          FIBSQL.Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.ParamCheck := False;
          FIBSQL.SQL.Text :=
              'ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_ek_constvalue '#13#10 +
              '  FOREIGN KEY (editorkey) REFERENCES gd_contact(id) '#13#10 +
              '  ON DELETE SET NULL '#13#10 +
              '  ON UPDATE CASCADE ';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          Log('Добавление EDITORKEY в константы прошло успешно');

          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_constvalue ADD editiondate deditiondate';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          Log('Добавление EDITIONDATE в константы прошло успешно');
        end;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;



  Log('Дезактивация некоторых триггеров');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_contact_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_contact_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_command_bu INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_au_command INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_goodgroup_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bi_good_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_good_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'ALTER TRIGGER gd_bu_goodgroup_2 INACTIVE';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
          FTransaction.Rollback;
        end;


      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;


end;

end.
