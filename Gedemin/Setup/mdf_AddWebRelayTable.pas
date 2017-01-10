unit mdf_AddWebRelayTable;

interface

uses
  IBDatabase, gdModify;

procedure AddWebRelayTable(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddGDEmployeeTable(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectSubAccounts(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectClientAddress(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddGEOCoords(IBDB: TIBDatabase; Log: TModifyLog);

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
          'UPDATE OR INSERT INTO gd_curr '#13#10 +
          '  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits, '#13#10 +
          '     fullcentname, shortcentname, centbase, icon, reserved, ISO, name_0, name_1, centname_0, centname_1) '#13#10 +
          '  VALUES (200010, 0, 1, ''BYN'', ''Белорусский рубль'', ''руб.'', ''Br'', '#13#10 +
          '     1, 2, ''копейка'', ''коп.'', 1, NULL, NULL, ''933'', ''белорусских рублей'', ''белорусских рубля'', ''копеек'', ''копейки'') '#13#10 +
          '  MATCHING (id)';
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

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (254, ''0000.0001.0000.0285'', ''01.07.2016'', ''BYN'')' + #13#10 +
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

procedure CorrectSubAccounts(IBDB: TIBDatabase; Log: TModifyLog);
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

        {
        q.SQL.Text :=
          'EXECUTE BLOCK '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE PID INTEGER; '#13#10 +
          '  DECLARE VARIABLE AID INTEGER; '#13#10 +
          '  DECLARE VARIABLE C INTEGER = 10; '#13#10 +
          'BEGIN '#13#10 +
          '  WHILE (:C > 0) DO '#13#10 +
          '  BEGIN '#13#10 +
          '    FOR '#13#10 +
          '      SELECT '#13#10 +
          '        p.id, a.id '#13#10 +
          '      FROM '#13#10 +
          '        ac_account p JOIN ac_account a '#13#10 +
          '          ON a.alias LIKE p.alias || ''._%'' '#13#10 +
          '            AND NOT a.alias LIKE p.alias || ''.%._%'' '#13#10 +
          '        JOIN ac_account a_root '#13#10 +
          '          ON a_root.lb < a.lb AND a_root.rb >= a.rb '#13#10 +
          '            AND a_root.parent IS NULL '#13#10 +
          '        JOIN ac_account p_root '#13#10 +
          '          ON p_root.lb < p.lb AND p_root.rb >= p.rb '#13#10 +
          '            AND p_root.parent IS NULL '#13#10 +
          '      WHERE '#13#10 +
          '        (a.ID <> p.id) '#13#10 +
          '        AND '#13#10 +
          '        (a_root.id = p_root.id) '#13#10 +
          '        AND '#13#10 +
          '        ( '#13#10 +
          '          a.parent <> p.id '#13#10 +
          '          OR '#13#10 +
          '          a.accounttype <> ''S'' '#13#10 +
          '         ) '#13#10 +
          '      INTO :PID, :AID '#13#10 +
          '    DO BEGIN '#13#10 +
          '      UPDATE ac_account SET parent = :PID, accounttype = ''S'' '#13#10 +
          '      WHERE id = :AID; '#13#10 +
          '       '#13#10 +
          '      WHEN ANY DO '#13#10 +
          '      BEGIN '#13#10 +
          '      END '#13#10 +
          '    END '#13#10 +
          '     '#13#10 +
          '    C = :C - 1; '#13#10 +
          '  END '#13#10 +
          'END';
        q.ExecQuery;
        }

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (255, ''0000.0001.0000.0286'', ''03.07.2016'', ''Correct sub accounts'')' + #13#10 +
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

procedure CorrectClientAddress(IBDB: TIBDatabase; Log: TModifyLog);
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

        q.SQL.Text :=
          'ALTER TABLE GD_JOURNAL ALTER CLIENTADDRESS TYPE dtext40';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (256, ''0000.0001.0000.0287'', ''06.08.2016'', ''Correct client address of GD_JOURNAL'')' + #13#10 +
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

procedure AddGEOCoords(IBDB: TIBDatabase; Log: TModifyLog);
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

        if not DomainExist2('dlat', Tr) then
        begin
          q.SQL.Text :=
            'CREATE DOMAIN dlat ' +
            '  AS NUMERIC(10, 8) ' +
            '  CHECK (VALUE BETWEEN -90.0 AND +90.0)';
          q.ExecQuery;
        end;

        if not DomainExist2('dlon', Tr) then
        begin
          q.SQL.Text :=
            'CREATE DOMAIN dlon ' +
            '  AS NUMERIC(11, 8) ' +
            '  CHECK (VALUE BETWEEN -180.0 AND +180.0)';
          q.ExecQuery;
        end;

        AddField2('GD_PLACE', 'lat', 'dlat', Tr);
        AddField2('GD_PLACE', 'lon', 'dlon', Tr);

        AddField2('GD_CONTACT', 'lat', 'dlat', Tr);
        AddField2('GD_CONTACT', 'lon', 'dlon', Tr);

        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo' + #13#10 +
          '  VALUES (257, ''0000.0001.0000.0288'', ''09.01.2017'', ''Add GEO coords'')' + #13#10 +
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