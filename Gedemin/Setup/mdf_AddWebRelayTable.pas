unit mdf_AddWebRelayTable;
 
interface

uses
  IBDatabase, gdModify;
 
procedure AddWebRelayTable(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddGDEmployeeTable(IBDB: TIBDatabase; Log: TModifyLog);

implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure AddWebRelayTable(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;
    try
      if RelationExist2('WEB_RELAY', Tr) and (not FieldExist2('WEB_RELAY', 'ID', Tr)) then
      begin
        DropRelation2('WEB_RELAY', Tr);
        Tr.Commit;
        Tr.StartTransaction;
      end;

      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;

        if not RelationExist2('WEB_RELAY', Tr) then
        begin
          q.SQL.Text :=
            'CREATE TABLE web_relay '#13#10 +
            '( '#13#10 +
            '  id            dintkey, '#13#10 +
            '  companyruid	druid, '#13#10 +
            '  alias         dname, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT web_pk_relay PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT web_uq_relay UNIQUE (companyruid, alias) '#13#10 +
            ')';
          q.ExecQuery;
        end;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER web_bi_relay FOR web_relay '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo                                                   ' + #13#10 +
          '  VALUES (247, ''0000.0001.0000.0278'', ''21.03.2016'', ''Added WEB_RELAY table.'')     ' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo                                                   ' + #13#10 +
          '  VALUES (248, ''0000.0001.0000.0279'', ''11.04.2016'', ''Fixed WEB_RELAY table.'')     ' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        Tr.Commit;
      finally
        q.Free;
      end;
    except
      on E: Exception do
      begin
        Tr.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    Tr.Free;
  end;
end;

procedure AddGDEmployeeTable(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;
    try
      q := TIBSQL.Create(nil);
      try
        q.Transaction := Tr;

        if not RelationExist2('GD_EMPLOYEE', Tr) then
        begin
          q.SQL.Text :=
            'CREATE TABLE gd_employee '#13#10 +
            '( '#13#10 +
            '  contactkey        dintkey, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT gd_pk_employee PRIMARY KEY (contactkey), '#13#10 +
            '  CONSTRAINT gd_fk_employee_contactkey FOREIGN KEY (contactkey) '#13#10 +
            '    REFERENCES gd_people (contactkey) '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            ')';
          q.ExecQuery;

          Tr.Commit;
          Tr.StartTransaction;
        end;

        q.SQL.Text :=
          'MERGE INTO gd_employee empl '#13#10 +
          'USING (SELECT e.id FROM gd_contact e JOIN gd_contact p ON p.id = e.parent ' +
          '  JOIN gd_people ppl ON ppl.contactkey = e.id ' +
          '  WHERE p.contacttype IN (3,4,5) AND e.contacttype = 2) co '#13#10 +
          '  ON co.id = empl.contactkey '#13#10 +
          'WHEN NOT MATCHED THEN '#13#10 +
          '  INSERT (contactkey) VALUES (co.id)';
        q.ExecQuery;

        q.SQL.Text :=
          'MERGE INTO gd_employee empl '#13#10 +
          'USING (SELECT c.id FROM gd_contact c '#13#10 +
          '    JOIN gd_people p ON p.contactkey = c.id '#13#10 +
          '    WHERE p.wcompanykey IS NOT NULL) co '#13#10 +
          '  ON co.id = empl.contactkey '#13#10 +
          'WHEN NOT MATCHED THEN '#13#10 +
          '  INSERT (contactkey) VALUES (co.id)';
        q.ExecQuery;

        q.SQL.Text := 'GRANT ALL ON GD_EMPLOYEE TO administrator';
        q.ExecQuery;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_aiu_namespace_link FOR at_namespace_link '#13#10 +
          '  ACTIVE '#13#10 +
          '  AFTER INSERT OR UPDATE '#13#10 +
          '  POSITION 20001 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (EXISTS( '#13#10 +
          '    WITH RECURSIVE tree AS '#13#10 +
          '    ( '#13#10 +
          '      SELECT '#13#10 +
          '        namespacekey AS initial, '#13#10 +
          '        0 AS dpth, '#13#10 +
          '        namespacekey, '#13#10 +
          '        useskey '#13#10 +
          '      FROM '#13#10 +
          '        at_namespace_link '#13#10 +
          '      WHERE '#13#10 +
          '        namespacekey = NEW.namespacekey AND useskey = NEW.useskey '#13#10 +
          ' '#13#10 +
          '      UNION ALL '#13#10 +
          ' '#13#10 +
          '      SELECT '#13#10 +
          '        IIF(tr.initial <> tt.namespacekey, tr.initial, -1) AS initial, '#13#10 +
          '        (tr.dpth + 1) AS dpth, '#13#10 +
          '        tt.namespacekey, '#13#10 +
          '        tt.useskey '#13#10 +
          '      FROM '#13#10 +
          '        at_namespace_link tt JOIN tree tr ON '#13#10 +
          '          tr.useskey = tt.namespacekey AND tr.initial > 0 '#13#10 +
          '          AND tr.dpth < 7 '#13#10 +
          ' '#13#10 +
          '    ) '#13#10 +
          '    SELECT * FROM tree WHERE initial = -1)) THEN '#13#10 +
          '  BEGIN '#13#10 +
          '    EXCEPTION gd_e_exception ''Обнаружена циклическая зависимость ПИ.''; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (249, ''0000.0001.0000.0280'', ''12.04.2016'', ''GD_EMPLOYEE table added.'')' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (250, ''0000.0001.0000.0281'', ''12.04.2016'', ''Correction.'')' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (251, ''0000.0001.0000.0282'', ''13.04.2016'', ''Rights for GD_EMPLOYEE.'')' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (252, ''0000.0001.0000.0283'', ''13.04.2016'', ''at_aiu_namespace_link fixed.'')' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (253, ''0000.0001.0000.0284'', ''13.04.2016'', ''at_aiu_namespace_link fixed #2.'')' + #13#10 +
          '  MATCHING (id)';
        q.ExecQuery;

        Tr.Commit;
      finally
        q.Free;
      end;
    except
      on E: Exception do
      begin
        Tr.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    Tr.Free;
  end;
end;

end.