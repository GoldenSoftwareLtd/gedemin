unit mdf_AddFieldToAC_TRRECORD;

interface
 
uses
  IBDatabase, gdModify;

procedure AddFieldPeriodToAC_TRRECORD(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddFieldsToGD_CURRRATE(IBDB: TIBDatabase; Log: TModifyLog);
procedure UpgradeAT_P_SYNC(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_MetaData_unit;

procedure AddFieldsToGD_CURRRATE(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      Log('Начато изменение таблицы GD_CURRRATE');

      try
        q.Close;
        q.SQL.Text := 'ALTER DOMAIN dcurrrate DROP CONSTRAINT';
        q.ExecQuery;

        q.SQL.Text := 'ALTER DOMAIN dcurrrate ADD CONSTRAINT CHECK(VALUE >= 0)';
        q.ExecQuery;

        if IBDB.ServerMajorVersion >= 3 then
        begin
          q.SQL.Text := 'ALTER DOMAIN dcurrrate DROP NOT NULL';
          q.ExecQuery;
        end;

        if not DomainExist2('dcurrrate_null', FTr) then
        begin
          q.SQL.Text :=
            'CREATE DOMAIN dcurrrate_null AS ' +
            'DECIMAL(15, 10) ' +
            'CHECK(VALUE >= 0)';
          q.ExecQuery;
        end else
        begin
          q.SQL.Text := 'ALTER DOMAIN dcurrrate_null DROP CONSTRAINT';
          q.ExecQuery;

          q.SQL.Text := 'ALTER DOMAIN dcurrrate_null ADD CONSTRAINT CHECK(VALUE >= 0)';
          q.ExecQuery;
        end;

        if not DomainExist2('dcurrrate_amount', FTr) then
        begin
          q.SQL.Text :=
            'CREATE DOMAIN dcurrrate_amount AS '#13#10 +
            '  SMALLINT '#13#10 +
            '  DEFAULT 1 '#13#10 +
            '  CHECK (VALUE > 0) '#13#10 +
            '  NOT NULL';
          q.ExecQuery;
        end;

        DropConstraint2('gd_currrate', 'gd_uk_currrate', FTr);
        DropConstraint2('gd_currrate', 'gd_fk3_currrate', FTr);

        FTr.Commit;
        FTr.StartTransaction;

        q.SQL.Text := 'ALTER TABLE gd_currrate ALTER fordate TYPE dtimestamp_notnull';
        q.ExecQuery;

        AddField2('gd_currrate', 'regulatorkey', 'dforeignkey', FTr);
        AddField2('gd_currrate', 'amount', 'dcurrrate_amount', FTr);
        AddField2('gd_currrate', 'val', 'dcurrrate', FTr);

        FTr.Commit;
        FTr.StartTransaction;

        q.SQL.Text :=
          'CREATE OR ALTER TRIGGER gd_biu_currrate FOR gd_currrate '#13#10 +
          '  ACTIVE '#13#10 +
          '  BEFORE INSERT OR UPDATE '#13#10 +
          '  POSITION 32000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.amount IS NULL) THEN '#13#10 +
          '    NEW.amount = 1; '#13#10 +
          '  IF (NEW.val IS NULL) THEN '#13#10 +
          '    NEW.val = NEW.amount * NEW.coeff; '#13#10 +
          '  ELSE '#13#10 +
          '    NEW.coeff = NEW.val / NEW.amount; '#13#10 +
          'END';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_currrate ADD CONSTRAINT gd_uk_currrate ' +
          'UNIQUE (fromcurr, tocurr, fordate, regulatorkey)';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_currrate ADD CONSTRAINT gd_fk3_currrate ' +
          '  FOREIGN KEY (regulatorkey) REFERENCES gd_company (contactkey) ON UPDATE CASCADE';
        q.ExecQuery;

        FTr.Commit;
        FTr.StartTransaction;

        q.SQL.Text :=
          'UPDATE gd_currrate SET id = id ';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE gd_currrate SET amount = 1000, val = val * 1000 ' +
          'WHERE val < 0.01 AND amount = 1';
        q.ExecQuery;

        q.SQL.Text :=
          'UPDATE gd_currrate SET amount = 100, val = val * 100 ' +
          'WHERE val < 0.1 AND amount = 1';
        q.ExecQuery;

        FTr.Commit;
        FTr.StartTransaction;

        if IBDB.ServerMajorVersion >= 3 then
        begin
          q.SQL.Text := 'ALTER DOMAIN dcurrrate SET NOT NULL';
          q.ExecQuery;
        end;

        FTr.Commit;
        FTr.StartTransaction;

        q.Close;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (259, ''0000.0001.0000.0290'', ''19.01.2017'', ''Upgrade of GD_CURRRATE table'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
        Log('Успешно завершено изменение таблицы GD_CURRRATE');
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

procedure AddFieldPeriodToAC_TRRECORD(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      Log('Начато добавление полей в таблицу AC_TRRECORD');

      try
        AddField2('AC_TRRECORD', 'dbegin', 'ddate', FTr);
        AddField2('AC_TRRECORD', 'dend', 'ddate', FTr);

        if not ConstraintExist2('ac_trrecord', 'ac_chk_trrecord_date', FTr) then
        begin
          q.SQL.Text :=
            'ALTER TABLE ac_trrecord ADD CONSTRAINT ac_chk_trrecord_date ' +
            'CHECK ((dbegin IS NULL) OR (dend IS NULL) OR (dbegin <= dend))';
          q.ExecQuery;
        end;

        q.Close;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (258, ''0000.0001.0000.0289'', ''15.01.2017'', ''Added period fields to AC_TRRECORD'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
        Log('Добавление полей в таблицу AC_TRRECORD успешно завершено');
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

procedure UpgradeAT_P_SYNC(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := FTr;
      try
        q.SQL.Text :=
          'CREATE OR ALTER PROCEDURE AT_P_SYNC '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE ID INTEGER; '#13#10 +
          '  DECLARE VARIABLE ID1 INTEGER; '#13#10 +
          '  DECLARE VARIABLE FN VARCHAR(31); '#13#10 +
          '  DECLARE VARIABLE FS VARCHAR(31); '#13#10 +
          '  DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
          '  DECLARE VARIABLE NFS VARCHAR(31); '#13#10 +
          '  DECLARE VARIABLE VS BLOB SUB_TYPE 0 SEGMENT SIZE 80; '#13#10 +
          '  DECLARE VARIABLE EN VARCHAR(31); '#13#10 +
          '  DECLARE VARIABLE DELRULE VARCHAR(20); '#13#10 +
          '  DECLARE VARIABLE WASERROR SMALLINT; '#13#10 +
          '  DECLARE VARIABLE GN VARCHAR(64); '#13#10 +
          'BEGIN '#13#10 +
          '   FOR '#13#10 +
          '     SELECT fieldname, relationname '#13#10 +
          '     FROM at_relation_fields LEFT JOIN rdb$relation_fields '#13#10 +
          '       ON fieldname=rdb$field_name AND relationname=rdb$relation_name '#13#10 +
          '     WHERE '#13#10 +
          '       rdb$field_name IS NULL '#13#10 +
          '     INTO :FN, :RN '#13#10 +
          '   DO BEGIN '#13#10 +
          '     DELETE FROM at_relation_fields WHERE fieldname=:FN AND relationname=:RN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   MERGE INTO at_fields trgt '#13#10 +
          '     USING rdb$fields src '#13#10 +
          '     ON trgt.fieldname = src.rdb$field_name '#13#10 +
          '     WHEN NOT MATCHED THEN '#13#10 +
          '       INSERT (fieldname, lname, description) '#13#10 +
          '       VALUES (TRIM(src.rdb$field_name), TRIM(src.rdb$field_name), TRIM(src.rdb$field_name)); '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT fieldsource, fieldname, relationname '#13#10 +
          '     FROM at_relation_fields '#13#10 +
          '     INTO :FS, :FN, :RN '#13#10 +
          '   DO BEGIN '#13#10 +
          '     SELECT rf.rdb$field_source, f.id '#13#10 +
          '     FROM rdb$relation_fields rf JOIN at_fields f ON rf.rdb$field_source = f.fieldname '#13#10 +
          '     WHERE rdb$relation_name=:RN AND rdb$field_name = :FN '#13#10 +
          '     INTO :NFS, :ID; '#13#10 +
          ' '#13#10 +
          '     IF (:NFS <> :FS AND (NOT (:NFS IS NULL))) THEN '#13#10 +
          '     UPDATE at_relation_fields SET fieldsource = :NFS, fieldsourcekey = :ID '#13#10 +
          '     WHERE fieldname = :FN AND relationname = :RN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   DELETE FROM at_fields f WHERE '#13#10 +
          '   NOT EXISTS (SELECT rdb$field_name FROM rdb$fields '#13#10 +
          '     WHERE rdb$field_name = f.fieldname); '#13#10 +
          ' '#13#10 +
          ' '#13#10 +
          '   WASERROR = 0; '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT rf.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN at_fields f ON r.id = f.reftablekey '#13#10 +
          '     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     WASERROR = 1; '#13#10 +
          '     DELETE FROM at_relation_fields WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT f.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN at_fields f ON r.id = f.reftablekey '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     WASERROR = 1; '#13#10 +
          '     DELETE FROM at_fields WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT rf.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN at_fields f ON r.id = f.settablekey '#13#10 +
          '     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     WASERROR = 1; '#13#10 +
          '     DELETE FROM at_relation_fields WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT f.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN at_fields f ON r.id = f.settablekey '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     WASERROR = 1; '#13#10 +
          '     DELETE FROM at_fields WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT dt.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN gd_documenttype dt ON dt.headerrelkey =r.id '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     DELETE FROM gd_documenttype WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT dt.id '#13#10 +
          '     FROM at_relations r '#13#10 +
          '     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname '#13#10 +
          '     LEFT JOIN gd_documenttype dt ON dt.linerelkey =r.id '#13#10 +
          '     WHERE rdb.rdb$relation_name IS NULL '#13#10 +
          '     INTO :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     DELETE FROM gd_documenttype WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          '   IF (WASERROR = 1) THEN '#13#10 +
          '   BEGIN '#13#10 +
          '     INSERT INTO AT_FIELDS (fieldname, lname, description) '#13#10 +
          '     SELECT TRIM(rdb$field_name), TRIM(rdb$field_name), '#13#10 +
          '       TRIM(rdb$field_name) '#13#10 +
          '     FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
          '       WHERE fieldname IS NULL; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   DELETE FROM at_relations r WHERE '#13#10 +
          '   NOT EXISTS (SELECT rdb$relation_name FROM rdb$relations '#13#10 +
          '     WHERE rdb$relation_name = r.relationname ); '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT rdb$relation_name, rdb$view_source '#13#10 +
          '     FROM rdb$relations LEFT JOIN at_relations ON relationname=rdb$relation_name '#13#10 +
          '     WHERE (relationname IS NULL) AND (NOT rdb$relation_name CONTAINING ''RDB$'') '#13#10 +
          '     INTO :RN, :VS '#13#10 +
          '   DO BEGIN '#13#10 +
          '     RN = TRIM(RN); '#13#10 +
          '     IF (:VS IS NULL) THEN '#13#10 +
          '       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) '#13#10 +
          '       VALUES (:RN, ''T'', :RN, :RN, :RN); '#13#10 +
          '     ELSE '#13#10 +
          '       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) '#13#10 +
          '       VALUES (:RN, ''V'', :RN, :RN, :RN); '#13#10 +
          '     END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT '#13#10 +
          '       rr.rdb$field_name, rr.rdb$field_source, rr.rdb$relation_name, r.id, f.id '#13#10 +
          '     FROM '#13#10 +
          '       rdb$relation_fields rr JOIN at_relations r ON rdb$relation_name = r.relationname '#13#10 +
          '     JOIN at_fields f ON rr.rdb$field_source = f.fieldname '#13#10 +
          '     LEFT JOIN at_relation_fields rf ON rr.rdb$field_name = rf.fieldname '#13#10 +
          '     AND rr.rdb$relation_name = rf.relationname '#13#10 +
          '     WHERE '#13#10 +
          '       (rf.fieldname IS NULL) AND (NOT rr.rdb$field_name CONTAINING ''RDB$'') '#13#10 +
          '     INTO '#13#10 +
          '       :FN, :FS, :RN, :ID, :ID1 '#13#10 +
          '   DO BEGIN '#13#10 +
          '     FN = TRIM(FN); '#13#10 +
          '     FS = TRIM(FS); '#13#10 +
          '     RN = TRIM(RN); '#13#10 +
          '     INSERT INTO at_relation_fields (fieldname, relationname, fieldsource, lname, description, '#13#10 +
          '       relationkey, fieldsourcekey, colwidth, visible) '#13#10 +
          '     VALUES(:FN, :RN, :FS, :FN, :FN, :ID, :ID1, 20, 1); '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT rf.rdb$delete_rule, f.id '#13#10 +
          '     FROM rdb$relation_constraints rc '#13#10 +
          '     LEFT JOIN rdb$index_segments rs ON rc.rdb$index_name = rs.rdb$index_name '#13#10 +
          '     LEFT JOIN at_relation_fields f ON rc.rdb$relation_name = f.relationname '#13#10 +
          '     AND  rs.rdb$field_name = f.fieldname '#13#10 +
          '     LEFT JOIN rdb$ref_constraints rf ON rf.rdb$constraint_name = rc.rdb$constraint_name '#13#10 +
          '     WHERE '#13#10 +
          '     rc.rdb$constraint_type = ''FOREIGN KEY'' '#13#10 +
          '     AND ((f.deleterule <> rf.rdb$delete_rule) '#13#10 +
          '     OR ((f.deleterule IS NULL) AND (rf.rdb$delete_rule IS NOT NULL)) '#13#10 +
          '     OR ((f.deleterule IS NOT NULL) AND (rf.rdb$delete_rule IS NULL))) '#13#10 +
          '     INTO :DELRULE, :ID '#13#10 +
          '   DO BEGIN '#13#10 +
          '     UPDATE at_relation_fields SET deleterule = :DELRULE WHERE id = :ID; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT exceptionname '#13#10 +
          '     FROM at_exceptions LEFT JOIN rdb$exceptions '#13#10 +
          '     ON exceptionname=rdb$exception_name '#13#10 +
          '     WHERE '#13#10 +
          '       rdb$exception_name IS NULL '#13#10 +
          '     INTO :EN '#13#10 +
          '   DO BEGIN '#13#10 +
          '     DELETE FROM at_exceptions WHERE exceptionname=:EN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   INSERT INTO at_exceptions(exceptionname) '#13#10 +
          '   SELECT TRIM(rdb$exception_name) '#13#10 +
          '   FROM rdb$exceptions '#13#10 +
          '   LEFT JOIN at_exceptions e ON e.exceptionname=rdb$exception_name '#13#10 +
          '   WHERE e.exceptionname IS NULL; '#13#10 +
          ' '#13#10 +
          '   FOR '#13#10 +
          '     SELECT procedurename '#13#10 +
          '     FROM at_procedures LEFT JOIN rdb$procedures '#13#10 +
          '       ON procedurename=rdb$procedure_name '#13#10 +
          '     WHERE '#13#10 +
          '       rdb$procedure_name IS NULL '#13#10 +
          '     INTO :EN '#13#10 +
          '   DO BEGIN '#13#10 +
          '     DELETE FROM at_procedures WHERE procedurename=:EN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   INSERT INTO at_procedures(procedurename) '#13#10 +
          '   SELECT TRIM(rdb$procedure_name) '#13#10 +
          '   FROM rdb$procedures '#13#10 +
          '   LEFT JOIN at_procedures e ON e.procedurename = rdb$procedure_name '#13#10 +
          '   WHERE e.procedurename IS NULL; '#13#10 +
          ' '#13#10 +
          '   GN = NULL; '#13#10 +
          '   FOR '#13#10 +
          '     SELECT generatorname '#13#10 +
          '     FROM at_generators '#13#10 +
          '     LEFT JOIN rdb$generators ON generatorname=rdb$generator_name '#13#10 +
          '     WHERE rdb$generator_name IS NULL '#13#10 +
          '     INTO :GN '#13#10 +
          '   DO '#13#10 +
          '   BEGIN '#13#10 +
          '     DELETE FROM at_generators WHERE generatorname=:GN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   INSERT INTO at_generators(generatorname) '#13#10 +
          '   SELECT TRIM(rdb$generator_name) '#13#10 +
          '   FROM rdb$generators '#13#10 +
          '   LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name '#13#10 +
          '   WHERE t.generatorname IS NULL; '#13#10 +
          ' '#13#10 +
          '   EN = NULL; '#13#10 +
          '   FOR '#13#10 +
          '     SELECT T.CHECKNAME '#13#10 +
          '     FROM AT_CHECK_CONSTRAINTS T '#13#10 +
          '     LEFT JOIN RDB$CHECK_CONSTRAINTS C ON T.CHECKNAME = C.RDB$CONSTRAINT_NAME '#13#10 +
          '     WHERE C.RDB$CONSTRAINT_NAME IS NULL '#13#10 +
          '     INTO :EN '#13#10 +
          '   DO '#13#10 +
          '   BEGIN '#13#10 +
          '     DELETE FROM AT_CHECK_CONSTRAINTS WHERE CHECKNAME = :EN; '#13#10 +
          '   END '#13#10 +
          ' '#13#10 +
          '   MERGE INTO at_check_constraints cc '#13#10 +
          '   USING '#13#10 +
          '     ( '#13#10 +
          '       SELECT DISTINCT TRIM(c.rdb$constraint_name) AS c_name '#13#10 +
          '       FROM rdb$triggers t '#13#10 +
          '         JOIN rdb$check_constraints c ON c.rdb$trigger_name = t.rdb$trigger_name '#13#10 +
          '       WHERE '#13#10 +
          '         t.rdb$trigger_source LIKE ''CHECK%'' '#13#10 +
          '     ) AS new_constraints '#13#10 +
          '   ON (cc.checkname = new_constraints.c_name) '#13#10 +
          '   WHEN NOT MATCHED THEN INSERT (checkname) VALUES (new_constraints.c_name); '#13#10 +
          'END';
        q.ExecQuery;

        q.Close;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (260, ''0000.0001.0000.0291'', ''03.02.2017'', ''Upgrade AT_P_SYNC'') ' +
          '  MATCHING (id)';
        q.ExecQuery;

        FTr.Commit;
      except
        on E: Exception do
        begin
      	  Log('Произошла ошибка: ' + E.Message);
          if FTr.InTransaction then
            FTr.Rollback;
          raise;
        end;
      end;
    finally
      q.Free;
    end;
  finally
    FTr.Free;
  end;
end;

end.