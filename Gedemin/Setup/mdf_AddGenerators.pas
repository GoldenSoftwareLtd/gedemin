unit mdf_AddGenerators;

interface

uses
  IBDatabase, gdModify;

  procedure AddGenerators(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddGenerators(IBDB: TIBDatabase; Log: TModifyLog);
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
      //Проверим наличие домена

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relations ' +
        ' WHERE rdb$relation_name = ''AT_GENERATORS''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text :=
          'CREATE TABLE at_generators ( '#13#10 +
          '  id               dintkey,'#13#10 +
          '  generatorname    dtablename NOT NULL,'#13#10 +
          '  editiondate      deditiondate,'#13#10 +
          '  editorkey        dintkey '#13#10 +
          ')';
        Log('AT_GENERATORS: Добавление таблицы at_generators');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'GRANT ALL ON at_generators TO administrator';
      IBSQL.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints ' +
        ' WHERE rdb$constraint_name = ''AT_PK_GENERATORS''';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'ALTER TABLE at_generators ADD CONSTRAINT at_pk_generators PRIMARY KEY(id)';
        Log('AT_GENERATORS: Добавление первичного ключа');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'SELECT * FROM rdb$indices WHERE rdb$relation_name = ''AT_GENERATORS'' AND ' +
        'rdb$index_name = ''AT_X_GENERATORS_EN'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE UNIQUE INDEX at_x_generators_en ON at_generators' +
          '(generatorname)';
        Log('AT_GENERATORS: Добавление уникального индекса');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''AT_AIUD_GENERATORS'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER at_aiud_generators FOR at_generators '#13#10 +
          'ACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 0 '#13#10 +
          'AS '#13#10 +
          '  DECLARE VARIABLE VERSION INTEGER; '#13#10 +
          'BEGIN '#13#10 +
          '  VERSION = GEN_ID(gd_g_attr_version, 1); '#13#10 +
          'END ';
        Log('AT_GENERATORS: Добавление триггера at_aiud_generators');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''AT_BI_GENERATORS'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER at_bi_generators FOR at_generators '#13#10 +
          'BEFORE INSERT POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1); '#13#10 +
          '  IF (NEW.editorkey IS NULL) THEN '#13#10 +
          '    NEW.editorkey = 650002; '#13#10 +
          ' IF (NEW.editiondate IS NULL) THEN '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP; '#13#10 +
          'END ';
        Log('AT_GENERATORS: Добавление триггера at_bi_generators');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM rdb$triggers  '+
        ' WHERE rdb$trigger_name = ''AT_BU_GENERATORS'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE TRIGGER at_bu_generators FOR at_generators '#13#10 +
          'BEFORE UPDATE POSITION 27000 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.editorkey IS NULL) THEN '#13#10 +
          '    NEW.editorkey = 650002; '#13#10 +
          ' IF (NEW.editiondate IS NULL) THEN '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP; '#13#10 +
          'END ';
        Log('AT_GENERATORS: Добавление триггера at_bu_generators5');
        IBSQL.ExecQuery;
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text :=  ' ALTER PROCEDURE AT_P_SYNC '#13#10 +
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
        ' END ';
      Log('AT_GENERATORS: Изменение процедуры AT_P_SYNC');
      IBSQL.ExecQuery;
      FTransaction.Commit;
      FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text := 'SELECT * FROM gd_command WHERE id = 741107';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text :=
          'INSERT INTO gd_command ' +
          '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) ' +
          'VALUES ' +
          '  (741107,740400,''Генераторы'',''gdcGenerator'',0,NULL,236,NULL,''TgdcGenerator'',NULL,1,1,1,0,NULL)';
        Log('AT_GENERATORS: Добавление ветки в исследователе');
        IBSQL.ExecQuery;
        FTransaction.Commit;
      end;

      if not FTransaction.Active then
        FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'INSERT INTO fin_versioninfo ' +
        '  VALUES (95, ''0000.0001.0000.0123'', ''30.06.2007'', ''Add generators'')';
      try
        IBSQL.ExecQuery;
      except
      end;
      IBSQL.Close;
      IBSQL.Transaction.Commit;

      FTransaction.StartTransaction;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'SELECT * FROM rdb$indices WHERE rdb$relation_name = ''GD_GOOD'' AND ' +
        'rdb$index_name = ''GD_X_GOOD_BARCODE'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE ASC INDEX gd_x_good_barcode ON gd_good' +
          '(barcode)';
        IBSQL.ExecQuery;
        IBSQL.SQL.Text := 'ALTER INDEX gd_x_good_barcode INACTIVE';
        IBSQL.ExecQuery;
        Log('GD_GOOD: Добавление индекса по штрих-коду');
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'SELECT * FROM rdb$indices WHERE rdb$relation_name = ''GD_GOODBARCODE'' AND ' +
        'rdb$index_name = ''GD_X_GOODBARCODE_BARCODE'' ';
      IBSQL.ExecQuery;
      if IBSQL.RecordCount = 0 then
      begin
        IBSQL.Close;
        IBSQL.SQL.Text := 'CREATE ASC INDEX gd_x_goodbarcode_barcode ON gd_goodbarcode' +
          '(barcode)';
        IBSQL.ExecQuery;
        IBSQL.SQL.Text := 'ALTER INDEX gd_x_goodbarcode_barcode INACTIVE';
        IBSQL.ExecQuery;
        Log('GD_GOODBARCODE: Добавление индекса по штрих-коду');
        FTransaction.Commit;
        FTransaction.StartTransaction;
      end;

      IBSQL.Close;
      IBSQL.SQL.Text :=
        'INSERT INTO fin_versioninfo ' +
        '  VALUES (96, ''0000.0001.0000.0124'', ''3.08.2007'', ''Add barcode indices'')';
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
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    IBSQL.Free;
    FTransaction.Free;
  end;
end;

end.
