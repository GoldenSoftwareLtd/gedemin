unit mdf_AddTaxTables;

interface

uses
  IBDatabase, gdModify;

procedure AddTaxTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  CreateTaxSQL: array[0..35] of String =
    (
      'CREATE TABLE gd_taxtype '#13#10 +
      '( '#13#10 +
      '  id       dintkey  PRIMARY KEY, '#13#10 +
      '  name     dname '#13#10 +
      ' ) ',

      'CREATE UNIQUE INDEX gd_idx_taxtype '#13#10 +
      '  ON gd_taxtype (name) ',

      'INSERT INTO gd_taxtype(id, name) '#13#10 +
      '  VALUES (350001, ''За месяц'') ',

      'INSERT INTO gd_taxtype(id, name) '#13#10 +
      '  VALUES (350002, ''За квартал'') ',

      'INSERT INTO gd_taxtype(id, name) '#13#10 +
      '  VALUES (350003, ''За период'') ',

      'CREATE EXCEPTION gd_e_taxtype ''Can not change data in GD_TAXTYPE table'' ',

      'CREATE TRIGGER gd_bi_taxtype FOR gd_taxtype '#13#10 +
      '  BEFORE INSERT '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  EXCEPTION gd_e_taxtype; '#13#10 +
      'END',

      'CREATE TRIGGER gd_bd_taxtype FOR gd_taxtype '#13#10 +
      '  BEFORE DELETE '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  EXCEPTION gd_e_taxtype; '#13#10 +
      'END ',

      'CREATE TRIGGER gd_bu_taxtype FOR gd_taxtype '#13#10 +
      '  BEFORE UPDATE '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  EXCEPTION gd_e_taxtype; '#13#10 +
      'END ',

      'CREATE TABLE gd_taxname '#13#10 +
      '( '#13#10 +
      '  id             dintkey   PRIMARY KEY, '#13#10 +
      '  name           dname '#13#10 +
      ') ',

      'CREATE UNIQUE INDEX gd_idx_taxname '#13#10 +
      '  ON gd_taxname (name) ',

      'CREATE TABLE gd_taxactual '#13#10 +
      '( '#13#10 +
      '  id             dintkey   PRIMARY KEY, '#13#10 +
      '  taxnamekey     dintkey, '#13#10 +
      '  actualdate     ddate     NOT NULL, '#13#10 +
      '  reportgroupkey dintkey, '#13#10 +
      '  reportday      dsmallint NOT NULL, '#13#10 +
      '  typekey        dintkey, '#13#10 +
      '  description    dtext120 '#13#10 +
      ') ',

      'ALTER TABLE gd_taxactual '#13#10 +
      'ADD CONSTRAINT chk_gd_taxactual_rd '#13#10 +
      'CHECK (0 < reportday AND reportday < 32) ',

      'ALTER TABLE gd_taxactual '#13#10 +
      'ADD CONSTRAINT fk_gd_taxactual '#13#10 +
      'FOREIGN KEY (taxnamekey) '#13#10 +
      'REFERENCES gd_taxname(id) on update cascade' ,

      'ALTER TABLE gd_taxactual '#13#10 +
      'ADD CONSTRAINT fk_gd_taxactual_t '#13#10 +
      'FOREIGN KEY (typekey) '#13#10 +
      'REFERENCES gd_taxtype(id) on update cascade ',

      'ALTER TABLE gd_taxactual '#13#10 +
      'ADD CONSTRAINT fk_gd_taxactual_trg '#13#10 +
      'FOREIGN KEY (reportgroupkey) '#13#10 +
      'REFERENCES rp_reportgroup(id) on update cascade ',

      'CREATE UNIQUE INDEX gd_idx_taxactual '#13#10 +
      '  ON gd_taxactual (taxnamekey, actualdate) ',

      'CREATE TABLE gd_taxfunction '#13#10 +
      '( '#13#10 +
      '  id            dintkey  PRIMARY KEY, '#13#10 +
      '  name          dname, '#13#10 +
      '  taxfunction   dscript, '#13#10 +
      '  taxactualkey  dintkey, '#13#10 +
      '  description    dtext120 '#13#10 +
      ') ',

      'CREATE UNIQUE INDEX gd_idx_taxfunction '#13#10 +
      '  ON gd_taxfunction (name, taxactualkey) ',

      'ALTER TABLE gd_taxfunction '#13#10 +
      'ADD CONSTRAINT fk_gd_taxfunction '#13#10 +
      'FOREIGN KEY (taxactualkey) '#13#10 +
      'REFERENCES gd_taxactual(id) ',

      'CREATE TABLE gd_taxdesigndate '#13#10 +
      '( '#13#10 +
      '  documentkey    dintkey  PRIMARY KEY, '#13#10 +
      '  taxnamekey     dintkey, '#13#10 +
      '  taxactualkey   dintkey '#13#10 +
      ') ',

      'ALTER TABLE gd_taxdesigndate '#13#10 +
      'ADD CONSTRAINT fk_gd_taxdesigndate '#13#10 +
      'FOREIGN KEY (taxnamekey) '#13#10 +
      'REFERENCES gd_taxname(id) ',

      'ALTER TABLE gd_taxdesigndate '#13#10 +
      'ADD CONSTRAINT fk_gd_taxdesigndate_addd '#13#10 +
      'FOREIGN KEY (taxactualkey) '#13#10 +
      'REFERENCES gd_taxactual(id) ',

      'ALTER TABLE gd_taxdesigndate '#13#10 +
      'ADD CONSTRAINT fk_gd_taxdesigndate_ddd '#13#10 +
      'FOREIGN KEY (documentkey) '#13#10 +
      'REFERENCES gd_document(id) '#13#10 +
      'ON DELETE CASCADE'#13#10 +
      'ON UPDATE CASCADE',

      'CREATE TABLE gd_taxresult '#13#10 +
      '( '#13#10 +
      '  documentkey      dintkey  PRIMARY KEY, '#13#10 +
      '  taxfunctionkey   dintkey, '#13#10 +
      '  taxdesigndatekey dintkey, '#13#10 +
      '  result           dtext255, '#13#10 +
      '  resulttype       dinteger '#13#10 +
      ') ',

      'CREATE UNIQUE INDEX gd_idx_taxresult '#13#10 +
      '  ON gd_taxresult (taxfunctionkey, taxdesigndatekey) ',

      'ALTER TABLE gd_taxresult '#13#10 +
      'ADD CONSTRAINT fk_gd_TAXRESULT_F '#13#10 +
      'FOREIGN KEY (taxfunctionkey) '#13#10 +
      'REFERENCES gd_taxfunction(id) ',

      'ALTER TABLE gd_taxresult '#13#10 +
      'ADD CONSTRAINT fk_gd_taxresult_d '#13#10 +
      'FOREIGN KEY (documentkey) '#13#10 +
      'REFERENCES gd_document(id)'#13#10 +
      'ON DELETE CASCADE'#13#10 +
      'ON UPDATE CASCADE',

      'ALTER TABLE gd_taxresult '#13#10 +
      'ADD CONSTRAINT fk_gd_TAXRESULT_DD '#13#10 +
      'FOREIGN KEY (taxdesigndatekey) '#13#10 +
      'REFERENCES gd_taxdesigndate(documentkey) ',

      'GRANT ALL ON gd_taxtype       TO administrator ',

      'GRANT ALL ON gd_taxname       TO administrator ',

      'GRANT ALL ON gd_taxactual     TO administrator ',

      'GRANT ALL ON gd_taxfunction   TO administrator ',

      'GRANT ALL ON gd_taxdesigndate TO administrator ',

      'GRANT ALL ON gd_taxresult     TO administrator ',

      'INSERT INTO gd_documenttype(id, parent, ruid, name, description, documenttype) ' +
      '  VALUES (807005, 806000, ''807005_17'', ''Отчеты бухгалтерии'', ' +
      '  ''Документы для расчета налогов отчетов бухгалтерии'', ''D'')'
    );

procedure AddTaxTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  TablesFound: String;
  I: Integer;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Log('Бух.отчеты: Добавление поддержки бух.отчетов.');
        Transaction := FTransaction;
        SQL.Text :=
          'SELECT * FROM rdb$relations ' +
          'WHERE ' +
          '  rdb$relation_name = ''GD_TAXACTUAL'' OR' +
          '  rdb$relation_name = ''GD_TAXDESIGNDATE'' OR' +
          '  rdb$relation_name = ''GD_TAXFUNCTION'' OR' +
          '  rdb$relation_name = ''GD_TAXNAME'' OR' +
          '  rdb$relation_name = ''GD_TAXRESULT'' OR' +
          '  rdb$relation_name = ''GD_TAXTYPE''';
        ExecQuery;
        TablesFound := '';
        if not Eof then
        begin
          while not Eof do
          begin
            if Length(TablesFound) > 0 then
              TablesFound := TablesFound +  ', ' +
                Trim(FieldByName('rdb$relation_name').AsString)
            else
              TablesFound := Trim(FieldByName('rdb$relation_name').AsString);
            Next;
          end;
          Log('Бух.отчеты: Обнаружены следующие таблицы ' + TablesFound + '.');
          Exit;
        end;

        for I := 0 to Length(CreateTaxSQL) - 1 do
        begin
          Close;
          if not Transaction.Active then
            Transaction.StartTransaction;
          SQL.Text := CreateTaxSQL[I];
          ExecQuery;
          Transaction.Commit;
        end;


        Log('Бух.отчеты: Добавление успешно завершено.');

        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
        Log('Бух.отчеты: Ошибка при добавление метаданных поддержки бух.отчетов.');
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
 