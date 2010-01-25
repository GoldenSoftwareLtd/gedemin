unit mdf_AddCheckConstraints;

interface

uses
  IBDatabase, gdModify;

  procedure AddCheckConstraints(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddCheckConstraints(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  IBSQL: TIBSQL;
begin
  IBSQL := TIBSQL.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    IBSQL.Transaction := FTransaction;
    try
      IBSQL.ParamCheck := False;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relations ' +
        ' WHERE rdb$relation_name = ''GD_FUNCTION_LOG''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text :=
          'CREATE TABLE GD_FUNCTION_LOG ( '#13#10 +
          '    ID           DINTKEY, '#13#10 +
          '    FUNCTIONKEY  DINTKEY, '#13#10 +
          '    REVISION     INTEGER, '#13#10 +
          '    SCRIPT       DSCRIPT, '#13#10 +
          '    EDITORKEY    DINTKEY, '#13#10 +
          '    EDITIONDATE  DEDITIONDATE '#13#10 +
          ')';
        Log('GD_FUNCTION_LOG: Добавление таблицы GD_FUNCTION_LOG');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;

        IBSQL.Close;
        IBSQL.SQL.Text := 'GRANT ALL ON GD_FUNCTION_LOG TO administrator';
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_PK_FUNCTION_LOG_ID''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE GD_FUNCTION_LOG ADD CONSTRAINT GD_PK_FUNCTION_LOG_ID PRIMARY KEY (ID)';
        Log('GD_FUNCTION_LOG: Добавление первичного ключа');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_FK_FUNCTION_LOG_EK''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE GD_FUNCTION_LOG ADD CONSTRAINT GD_FK_FUNCTION_LOG_EK ' +
          'FOREIGN KEY (EDITORKEY) REFERENCES GD_CONTACT (ID) ON UPDATE CASCADE';
        Log('GD_FUNCTION_LOG: Создание ограничения GD_FK_FUNCTION_LOG_EK');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''GD_FK_FUNCTION_LOG_FK''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE GD_FUNCTION_LOG ADD CONSTRAINT GD_FK_FUNCTION_LOG_FK ' +
          'FOREIGN KEY (FUNCTIONKEY) REFERENCES GD_FUNCTION (ID) ON DELETE CASCADE ON UPDATE CASCADE';
        Log('GD_FUNCTION_LOG: Создание ограничения GD_FK_FUNCTION_LOG_FK');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''GD_BI_FUNCTION_LOG'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER GD_BI_FUNCTION_LOG FOR GD_FUNCTION_LOG '#13#10 +
          'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE R INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.ID IS NULL) THEN '#13#10 +
          '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          ' '#13#10 +
          '  R = 0; '#13#10 +
          '  SELECT MAX(revision) FROM gd_function_log WHERE functionkey = NEW.functionkey '#13#10 +
          '    INTO :R; '#13#10 +
          '  NEW.revision = COALESCE(:R, 0) + 1; '#13#10 +
          'END ';
        Log('GD_FUNCTION_LOG: Добавление триггера GD_BI_FUNCTION_LOG');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers ' +
        ' WHERE rdb$trigger_name = ''GD_BU_FUNCTION_LOG'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER GD_BU_FUNCTION_LOG FOR GD_FUNCTION_LOG '#13#10 +
          'ACTIVE BEFORE UPDATE POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (OLD.revision <> COALESCE(NEW.revision, 0)) THEN '#13#10 +
          '    NEW.revision = OLD.revision; '#13#10 +
          'END ';
        Log('GD_FUNCTION_LOG: Добавление триггера GD_BU_FUNCTION_LOG');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'ALTER TRIGGER gd_function_au_ch '#13#10 +
        'AFTER UPDATE POSITION 32000 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE I INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  I = GEN_ID(gd_g_functionch, 1); '#13#10 +
        ' '#13#10 +
        '  IF ((OLD.EDITIONDATE <> NEW.EDITIONDATE) AND (OLD.SCRIPT <> NEW.SCRIPT)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NOT EXISTS (SELECT L.ID FROM GD_FUNCTION_LOG L WHERE L.FUNCTIONKEY = OLD.ID)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate) '#13#10 +
        '        VALUES (OLD.ID, OLD.SCRIPT, OLD.EDITORKEY, OLD.EDITIONDATE); '#13#10 +
        ' '#13#10 +
        '      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate) '#13#10 +
        '        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE); '#13#10 +
        '    END ELSE '#13#10 +
        '      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate) '#13#10 +
        '        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE); '#13#10 +
        '  END '#13#10 +
        'END';
      Log('GD_FUNCTION: Изменение триггера gd_function_au_ch');
      IBSQL.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      //добавление таблицы AT_CHECK_CONSTRAINTS
      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relations ' +
        ' WHERE rdb$relation_name = ''AT_CHECK_CONSTRAINTS''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text :=
          'CREATE TABLE AT_CHECK_CONSTRAINTS ( '#13#10 +
          '    ID                DINTKEY, '#13#10 +
          '    CHECKNAME         DTABLENAME NOT NULL, '#13#10 +
          '    MSG               DTEXT80 COLLATE PXW_CYRL '#13#10 +
          ')';
        Log('AT_CHECK_CONSTRAINTS: Добавление таблицы AT_CHECK_CONSTRAINTS');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;

        IBSQL.Close;
        IBSQL.SQL.Text := 'GRANT ALL ON AT_CHECK_CONSTRAINTS TO administrator';
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''AT_PK_CHECK_CONSTRAINTS''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE AT_CHECK_CONSTRAINTS ADD CONSTRAINT AT_PK_CHECK_CONSTRAINTS PRIMARY KEY (ID)';
        Log('AT_CHECK_CONSTRAINTS: Добавление первичного ключа');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'SELECT * FROM rdb$indices WHERE rdb$relation_name = ''AT_CHECK_CONSTRAINTS'' AND ' +
        'rdb$index_name = ''AT_X_CONSTRAINTS_IN'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE UNIQUE INDEX AT_X_CONSTRAINTS_IN ON AT_CHECK_CONSTRAINTS (CHECKNAME)';
        Log('AT_CHECK_CONSTRAINTS: Добавление уникального индекса');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''AT_AIUD_CHECK_CONSTRAINTS'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER AT_AIUD_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS '#13#10 +
          'ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE VERSION INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  VERSION = GEN_ID(gd_g_attr_version, 1); '#13#10 +
          'END';
        Log('AT_CHECK_CONSTRAINTS: Добавление триггера AT_AIUD_CHECK_CONSTRAINTS');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers '+
        ' WHERE rdb$trigger_name = ''AT_BI_CHECK_CONSTRAINTS'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER AT_BI_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS '#13#10 +
          'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1); '#13#10 +
          'END';
        Log('AT_CHECK_CONSTRAINTS: Добавление триггера AT_BI_CHECK_CONSTRAINTS');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := ' ALTER PROCEDURE AT_P_SYNC '#13#10 +
        ' AS '#13#10 +
        '   DECLARE VARIABLE ID INTEGER; '#13#10 +
        '   DECLARE VARIABLE ID1 INTEGER; '#13#10 +
        '   DECLARE VARIABLE FN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE FS VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE NFS VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE VS BLOB; '#13#10 +
        '   DECLARE VARIABLE EN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE DELRULE VARCHAR(20); '#13#10 +
        '   DECLARE VARIABLE WASERROR SMALLINT; '#13#10 +
        '   DECLARE VARIABLE GN VARCHAR(64); '#13#10 +
        ' BEGIN '#13#10 +
        ' /* пакольк_ каскады не выкарыстоўваюцца мус_м */ '#13#10 +
        ' /* п_льнавацца пэўнага парадку                */ '#13#10 +
        '  '#13#10 +
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
        '  '#13#10 +
        ' /* дададз_м новыя дамены */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT rdb$field_name '#13#10 +
        '     FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
        '     WHERE fieldname IS NULL '#13#10 +
        '     INTO :FN '#13#10 +
        '   DO BEGIN '#13#10 +
        '     FN = g_s_trim(FN, '' ''); '#13#10 +
        '     INSERT INTO at_fields (fieldname, lname, description) '#13#10 +
        '       VALUES (:FN, :FN, :FN); '#13#10 +
        '   END '#13#10 +
        '  '#13#10 +
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
        '  '#13#10 +
        '     IF (:NFS <> :FS AND (NOT (:NFS IS NULL))) THEN '#13#10 +
        '     UPDATE at_relation_fields SET fieldsource = :NFS, fieldsourcekey = :ID '#13#10 +
        '     WHERE fieldname = :FN AND relationname = :RN; '#13#10 +
        '   END '#13#10 +
        '  '#13#10 +
        ' /* выдал_м з табл_цы даменаў не _снуючыя дамены */ '#13#10 +
        '   DELETE FROM at_fields f WHERE f.fieldname '#13#10 +
        '     NOT IN (SELECT rdb$field_name FROM rdb$fields); '#13#10 +
        '  '#13#10 +
        ' /*Теперь будем аккуратно проверять на несуществующие уже таблицы и существующие '#13#10 +
        ' домены, которые ссылаются на эти таблицы. Такая ситуация может возникнуть из-за '#13#10 +
        ' ошибки при создании мета-данных*/ '#13#10 +
        '  '#13#10 +
        '   WASERROR = 0; '#13#10 +
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
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
        '     FOR '#13#10 +
        '       SELECT rdb$field_name '#13#10 +
        '       FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname '#13#10 +
        '       WHERE fieldname IS NULL '#13#10 +
        '       INTO :FN '#13#10 +
        '     DO BEGIN '#13#10 +
        '       FN = g_s_trim(FN, '' ''); '#13#10 +
        '       INSERT INTO at_fields (fieldname, lname, description) '#13#10 +
        '       VALUES (:FN, :FN, :FN); '#13#10 +
        '     END '#13#10 +
        '   END '#13#10 +
        '  '#13#10 +
        ' /* выдал_м табл_цы, як_х ужо няма */ '#13#10 +
        '   DELETE FROM at_relations r WHERE  r.relationname '#13#10 +
        '     NOT IN (SELECT rdb$relation_name FROM rdb$relations); '#13#10 +
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
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
        '  '#13#10 +
        ' /* дадаем новыя выключэннi */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT rdb$exception_name '#13#10 +
        '     FROM rdb$exceptions LEFT JOIN at_exceptions e '#13#10 +
        '     ON e.exceptionname=rdb$exception_name '#13#10 +
        '     WHERE '#13#10 +
        '       e.exceptionname IS NULL '#13#10 +
        '     INTO :EN '#13#10 +
        '   DO BEGIN '#13#10 +
        '     EN = g_s_trim(EN, '' ''); '#13#10 +
        '     INSERT INTO at_exceptions(exceptionname) '#13#10 +
        '     VALUES (:EN); '#13#10 +
        '   END '#13#10 +
        '  '#13#10 +
        '  '#13#10 +
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
        '  '#13#10 +
        ' /* дадаем новыя працэдуры */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT rdb$procedure_name '#13#10 +
        '     FROM rdb$procedures LEFT JOIN at_procedures e '#13#10 +
        '       ON e.procedurename=rdb$procedure_name '#13#10 +
        '     WHERE '#13#10 +
        '       e.procedurename IS NULL '#13#10 +
        '     INTO :EN '#13#10 +
        '   DO BEGIN '#13#10 +
        '     EN = g_s_trim(EN, '' ''); '#13#10 +
        '     INSERT INTO at_procedures(procedurename) '#13#10 +
        '       VALUES (:EN); '#13#10 +
        '   END '#13#10 +
        '       '#13#10 +
        ' /* удалим не существующие уже генераторы */ '#13#10 +
        '   GN = NULL; '#13#10 +
        '   FOR  '#13#10 +
        '     SELECT generatorname '#13#10 +
        '     FROM at_generators '#13#10 +
        '     LEFT JOIN rdb$generators ON generatorname=rdb$generator_name '#13#10 +
        '     WHERE rdb$generator_name IS NULL '#13#10 +
        '     INTO :GN  '#13#10 +
        '   DO  '#13#10 +
        '   BEGIN '#13#10 +
        '     DELETE FROM at_generators WHERE generatorname=:GN;  '#13#10 +
        '   END '#13#10 +
        '       '#13#10 +
        ' /* добавим новые генераторы */  '#13#10 +
        '       '#13#10 +
        '   GN = NULL; '#13#10 +
        '   FOR  '#13#10 +
        '     SELECT  '#13#10 +
        '       rdb$generator_name '#13#10 +
        '     FROM rdb$generators  '#13#10 +
        '     LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name '#13#10 +
        '     WHERE  '#13#10 +
        '      t.generatorname IS NULL '#13#10 +
        '     INTO :GN '#13#10 +
        '   DO  '#13#10 +
        '   BEGIN '#13#10 +
        '     GN = G_S_TRIM(GN, '' ''); '#13#10 +
        '     INSERT INTO at_generators(generatorname) '#13#10 +
        '       VALUES(:GN); '#13#10 +
        '   END '#13#10 +
        '       '#13#10 +
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
        '       '#13#10 +
        ' /* добавим новые чеки */ '#13#10 +
        '   EN = NULL; '#13#10 +
        '   FOR '#13#10 +
        '     SELECT C.RDB$CONSTRAINT_NAME FROM RDB$TRIGGERS T '#13#10 +
        '     LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME '#13#10 +
        '     LEFT JOIN AT_CHECK_CONSTRAINTS CON ON CON.CHECKNAME = C.RDB$CONSTRAINT_NAME '#13#10 +
        '     WHERE T.RDB$TRIGGER_SOURCE LIKE ''CHECK%'' '#13#10 +
        '       AND CON.CHECKNAME IS NULL '#13#10 +
        '     INTO :EN '#13#10 +
        '   DO '#13#10 +
        '   BEGIN '#13#10 +
        '     EN = G_S_TRIM(EN,  '' ''); '#13#10 +
        '     INSERT INTO AT_CHECK_CONSTRAINTS(CHECKNAME) '#13#10 +
        '     VALUES(:EN); '#13#10 +
        '   END '#13#10 +
        ' END ';
      Log('AT_CHECK_CONSTRAINTS: Изменение процедуры AT_P_SYNC');
      IBSQL.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      // Забыли сделать внешний ключ
      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''AT_FK_GENERATORS_EDITORKEY''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE AT_GENERATORS ADD CONSTRAINT AT_FK_GENERATORS_EDITORKEY ' +
          'FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE';
        Log('AT_GENERATORS: Создание ограничения AT_FK_GENERATORS_EDITORKEY');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'ALTER TRIGGER GD_AU_DOCUMENT  '#13#10 +
        '  AFTER UPDATE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (NEW.PARENT IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF ((OLD.documentdate <> NEW.documentdate) OR (OLD.number <> NEW.number) '#13#10 +
        '      OR (OLD.companykey <> NEW.companykey)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN '#13#10 +
        '        UPDATE gd_document SET documentdate = NEW.documentdate, '#13#10 +
        '          number = NEW.number, companykey = NEW.companykey '#13#10 +
        '        WHERE (parent = NEW.ID) '#13#10 +
        '          AND ((documentdate <> NEW.documentdate) '#13#10 +
        '           OR (number <> NEW.number) OR (companykey <> NEW.companykey)); '#13#10 +
        '      ELSE '#13#10 +
        '        UPDATE gd_document SET documentdate = NEW.documentdate, '#13#10 +
        '          companykey = NEW.companykey '#13#10 +
        '        WHERE (parent = NEW.ID) '#13#10 +
        '          AND ((documentdate <> NEW.documentdate) '#13#10 +
        '          OR  (companykey <> NEW.companykey)); '#13#10 +
        '    END '#13#10 +
        '  END ELSE '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NEW.editiondate <> OLD.editiondate) THEN '#13#10 +
        '      UPDATE gd_document SET editiondate = NEW.editiondate, '#13#10 +
        '        editorkey = NEW.editorkey '#13#10 +
        '      WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate); '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* просто игнорируем все ошибки */ '#13#10 +
        '  WHEN ANY DO '#13#10 +
        '  BEGIN '#13#10 +
        '  END '#13#10 +
        'END ';
      Log('GD_DOCUMENT: Изменение тригера GD_AU_DOCUMENT');
      IBSQL.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'INSERT INTO fin_versioninfo ' +
        '  VALUES (97, ''0000.0001.0000.0125'', ''4.10.2007'', ''Add check constraints'')';
      try
        IBSQL.ExecQuery;
      except
      end;
      IBSQL.Close;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'INSERT INTO fin_versioninfo ' +
        '  VALUES (98, ''0000.0001.0000.0126'', ''22.10.2007'', ''GD_AU_DOCUMENT'')';
      try
        IBSQL.ExecQuery;
      except
      end;
      IBSQL.Close;
      FTransaction.Commit;

    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    IBSQL.Free;
    FTransaction.Free;
  end;
end;

end.
