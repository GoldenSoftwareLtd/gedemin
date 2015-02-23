unit mdf_AddSupportFB3;
 
  interface
 
  uses
    IBDatabase, gdModify;
 
  procedure AddSupportFB3(IBDB: TIBDatabase; Log: TModifyLog);
 
  implementation
 
  uses
    IBSQL, SysUtils;
 
  procedure AddSupportFB3(IBDB: TIBDatabase; Log: TModifyLog);
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
        try
          FIBSQL.Transaction := FTransaction;
 
          FIBSQL.SQL.Text := 
		    'GRANT ALTER ANY SEQUENCE TO STARTUSER';
          FIBSQL.ExecQuery;
		  
          FIBSQL.SQL.Text :=
            'GRANT USAGE ON SEQUENCE gd_g_dbid TO STARTUSER';
          FIBSQL.ExecQuery;
 
          FIBSQL.SQL.Text := 
            'GRANT USAGE ON SEQUENCE gd_g_session_id TO STARTUSER';
          FIBSQL.ExecQuery;
 
          FIBSQL.SQL.Text := 
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
            ' /* пакольк_ каскады не выкарыстоўваюцца мус_м */ '#13#10 +
            ' /* п_льнавацца пэўнага парадку                */ '#13#10 +
            ' '#13#10 +
            ' /* выдал_м не _снуючыя ўжо пал_ табл_цаў      */ '#13#10 +
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
            ' /* дададз_м новыя дамены */ '#13#10 +
            '   MERGE INTO at_fields trgt '#13#10 +
            '     USING rdb$fields src '#13#10 +
            '     ON trgt.fieldname = src.rdb$field_name '#13#10 +
            '     WHEN NOT MATCHED THEN '#13#10 +
            '       INSERT (fieldname, lname, description) '#13#10 +
            '       VALUES (TRIM(src.rdb$field_name), TRIM(src.rdb$field_name), TRIM(src.rdb$field_name)); '#13#10 +
            ' '#13#10 +
            '   /* '#13#10 +
            '   INSERT INTO AT_FIELDS (fieldname, lname, description) '#13#10 +
            '   SELECT trim(rdb$field_name), trim(rdb$field_name), '#13#10 +
            '     trim(rdb$field_name) '#13#10 +
            '   FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
            '     WHERE fieldname IS NULL; '#13#10 +
            '   */ '#13#10 +
            ' '#13#10 +
            ' /* для _снуючых палёў аднав_м _нфармацыю аб тыпе */ '#13#10 +
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
            ' /* выдал_м з табл_цы даменаў не _снуючыя дамены */ '#13#10 +
            '   DELETE FROM at_fields f WHERE '#13#10 +
            '   NOT EXISTS (SELECT rdb$field_name FROM rdb$fields '#13#10 +
            '     WHERE rdb$field_name = f.fieldname); '#13#10 +
            ' '#13#10 +
            ' '#13#10 +
            ' /*Теперь будем аккуратно проверять на несуществующие уже таблицы и существующие '#13#10 +
            ' домены, которые ссылаются на эти таблицы. Такая ситуация может возникнуть из-за '#13#10 +
            ' ошибки при создании мета-данных*/ '#13#10 +
            ' '#13#10 +
            '   WASERROR = 0; '#13#10 +
            ' '#13#10 +
            '   FOR '#13#10 +
            ' /*Выберем все поля и удалим*/ '#13#10 +
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
            ' /*Выберем все домены и удалим*/ '#13#10 +
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
            ' /*Выберем все поля и удалим*/ '#13#10 +
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
            ' /*Выберем все домены и удалим*/ '#13#10 +
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
            '/*выберем все документы, у которых шапка ссылается на несуществующие таблицы и удалим*/ '#13#10 +
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
            '/*выберем все документы, у которых позиция ссылается на несуществующие таблицы и удалим*/ '#13#10 +
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
            ' /* Перечитаем домены. Теперь те домены, которые были проблемными добавятся без ошибок */ '#13#10 +
            '     INSERT INTO AT_FIELDS (fieldname, lname, description) '#13#10 +
            '     SELECT g_s_trim(rdb$field_name, '' ''), g_s_trim(rdb$field_name, '' ''), '#13#10 +
            '       g_s_trim(rdb$field_name, '' '') '#13#10 +
            '     FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
            '       WHERE fieldname IS NULL; '#13#10 +
            '   END '#13#10 +
            ' '#13#10 +
            ' /* выдал_м табл_цы, як_х ужо няма */ '#13#10 +
            '   DELETE FROM at_relations r WHERE '#13#10 +
            '   NOT EXISTS (SELECT rdb$relation_name FROM rdb$relations '#13#10 +
            '     WHERE rdb$relation_name = r.relationname ); '#13#10 +
            ' '#13#10 +
            ' /* дададз_м новыя табл_цы */ '#13#10 +
            ' /* акрамя с_стэмных  */ '#13#10 +
            '   FOR '#13#10 +
            '     SELECT rdb$relation_name, rdb$view_source '#13#10 +
            '     FROM rdb$relations LEFT JOIN at_relations ON relationname=rdb$relation_name '#13#10 +
            '     WHERE (relationname IS NULL) AND (NOT rdb$relation_name CONTAINING ''RDB$'') '#13#10 +
            '     INTO :RN, :VS '#13#10 +
            '   DO BEGIN '#13#10 +
            '     RN = g_s_trim(RN, '' ''); '#13#10 +
            '     IF (:VS IS NULL) THEN '#13#10 +
            '       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) '#13#10 +
            '       VALUES (:RN, ''T'', :RN, :RN, :RN); '#13#10 +
            '     ELSE '#13#10 +
            '       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) '#13#10 +
            '       VALUES (:RN, ''V'', :RN, :RN, :RN); '#13#10 +
            '     END '#13#10 +
            ' '#13#10 +
            ' /* дадаем новыя пал_ */ '#13#10 +
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
            '     FN = g_s_trim(FN, '' ''); '#13#10 +
            '     FS = g_s_trim(FS, '' ''); '#13#10 +
            '     RN = g_s_trim(RN, '' ''); '#13#10 +
            '     INSERT INTO at_relation_fields (fieldname, relationname, fieldsource, lname, description, '#13#10 +
            '       relationkey, fieldsourcekey, colwidth, visible) '#13#10 +
            '     VALUES(:FN, :RN, :FS, :FN, :FN, :ID, :ID1, 20, 1); '#13#10 +
            '   END '#13#10 +
            ' '#13#10 +
            ' /* обновим информацию о правиле удаления для полей ссылок */ '#13#10 +
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
            ' /* выдал_м не _снуючыя ўжо выключэннi */ '#13#10 +
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
            ' /* дадаем новыя выключэннi */ '#13#10 +
            '   INSERT INTO at_exceptions(exceptionname) '#13#10 +
            '   SELECT g_s_trim(rdb$exception_name, '' '') '#13#10 +
            '   FROM rdb$exceptions '#13#10 +
            '   LEFT JOIN at_exceptions e ON e.exceptionname=rdb$exception_name '#13#10 +
            '   WHERE e.exceptionname IS NULL; '#13#10 +
            ' '#13#10 +
            ' /* выдал_м не _снуючыя ўжо працэдуры */ '#13#10 +
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
            ' /* дадаем новыя працэдуры */ '#13#10 +
            '   INSERT INTO at_procedures(procedurename) '#13#10 +
            '   SELECT g_s_trim(rdb$procedure_name, '' '') '#13#10 +
            '   FROM rdb$procedures '#13#10 +
            '   LEFT JOIN at_procedures e ON e.procedurename = rdb$procedure_name '#13#10 +
            '   WHERE e.procedurename IS NULL; '#13#10 +
            ' '#13#10 +
            ' /* удалим не существующие уже генераторы */ '#13#10 +
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
            ' /* добавим новые генераторы */ '#13#10 +
            '   INSERT INTO at_generators(generatorname) '#13#10 +
            '   SELECT G_S_TRIM(rdb$generator_name, '' '') '#13#10 +
            '   FROM rdb$generators '#13#10 +
            '   LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name '#13#10 +
            '   WHERE t.generatorname IS NULL; '#13#10 +
            ' '#13#10 +
            ' /* удалим не существующие уже чеки */ '#13#10 +
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
            ' /* добавим новые чеки */ '#13#10 +
            ' /* '#13#10 +
            '   INSERT INTO AT_CHECK_CONSTRAINTS(CHECKNAME) '#13#10 +
            '   SELECT TRIM(C.RDB$CONSTRAINT_NAME) '#13#10 +
            '   FROM RDB$TRIGGERS T '#13#10 +
            '   LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME '#13#10 +
            '   LEFT JOIN AT_CHECK_CONSTRAINTS CON ON CON.CHECKNAME = C.RDB$CONSTRAINT_NAME '#13#10 +
            '   WHERE T.RDB$TRIGGER_SOURCE LIKE ''CHECK%'' '#13#10 +
            '     AND CON.CHECKNAME IS NULL; '#13#10 +
            ' */ '#13#10 +
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
          FIBSQL.ExecQuery;
 
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'INSERT INTO fin_versioninfo VALUES (218, ''0000.0001.0000.0249'', ''19.02.2015'', ''Support FireBird 3 added.'')';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
 
          FTransaction.Commit;
 
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