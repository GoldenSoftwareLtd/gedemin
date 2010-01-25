unit mdf_ChangeSyncProcedures;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeSyncProcedures(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeSyncProcedures(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;
      ibsql.ParamCheck := False;

      ibsql.SQL.Text := 'SELECT * FROM rdb$indices ' +
        ' WHERE rdb$index_name = ''AT_X_INDICES_IN''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE UNIQUE INDEX at_x_indices_in ON at_indices (indexname)';
        Log('AT_INDICES: Добавление уникального индекса на поле indexname');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'ALTER PROCEDURE AT_P_SYNC_INDEXES_ALL '#13#10 +
        ' AS '#13#10 +
        '   DECLARE VARIABLE FN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE I_N VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE FP SMALLINT; '#13#10 +
        '   DEClARE VARIABLE FLIST VARCHAR(255);  '#13#10 +
        '   DEClARE VARIABLE FL VARCHAR(255); '#13#10 +
        '   DEClARE VARIABLE INDEXNAME VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE ID INTEGER; '#13#10 +
        '   DECLARE VARIABLE UF SMALLINT; '#13#10 +
        '   DECLARE VARIABLE II SMALLINT; '#13#10 +
        ' BEGIN '#13#10 +
        '   /* выдал_м не _снуючыя ўжо iндэксы */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT indexname '#13#10 +
        '     FROM at_indices LEFT JOIN rdb$indices '#13#10 +
        '       ON indexname=rdb$index_name '#13#10 +
        '     WHERE '#13#10 +
        '       rdb$index_name IS NULL '#13#10 +
        '     INTO :I_N  '#13#10 +
        '   DO BEGIN '#13#10 +
        '     DELETE FROM at_indices WHERE indexname=:I_N; '#13#10 +
        '   END '#13#10 +
        '  /* дадаем новыя iндэксы */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT rdb$relation_name, rdb$index_name, '#13#10 +
        '       rdb$index_inactive, rdb$unique_flag, r.id '#13#10 +
        '     FROM rdb$indices LEFT JOIN at_indices i '#13#10 +
        '       ON i.indexname=rdb$index_name '#13#10 +
        '     LEFT JOIN at_relations r ON rdb$relation_name = r.relationname '#13#10 +
        '     WHERE '#13#10 +
        '       (i.indexname IS NULL) AND (r.id IS NOT NULL) '#13#10 +
        '     INTO :RN, :I_N, :II, :UF, :ID '#13#10 +
        '   DO BEGIN '#13#10 +
        '     IF (II IS NULL) THEN '#13#10 +
        '       II = 0; '#13#10 +
        '     IF (UF IS NULL) THEN '#13#10 +
        '       UF = 0; '#13#10 +
        '     IF (II > 1) THEN '#13#10 +
        '       II = 1; '#13#10 +
        '     IF (UF > 1) THEN '#13#10 +
        '       UF = 1; '#13#10 +
        '     INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive) '#13#10 +
        '     VALUES (:RN, :I_N, :ID, :UF, :II); '#13#10 +
        '   END '#13#10 +
        '    /* проверяем индексы на активность и уникальность*/ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT ri.rdb$index_inactive, ri.rdb$unique_flag, ri.rdb$index_name '#13#10 +
        '     FROM at_indices i '#13#10 +
        '     LEFT JOIN rdb$indices ri ON ri.rdb$index_name = i.indexname '#13#10 +
        '     WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR '#13#10 +
        '     (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR '#13#10 +
        '     (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR '#13#10 +
        '     (i.index_inactive <> ri.rdb$index_inactive) OR '#13#10 +
        '     (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1)) '#13#10 +
        '     INTO :II, :UF, :I_N '#13#10 +
        '   DO BEGIN '#13#10 +
        '     IF (II IS NULL) THEN '#13#10 +
        '       II = 0; '#13#10 +
        '     IF (UF IS NULL) THEN '#13#10 +
        '       UF = 0; '#13#10 +
        '     IF (II > 1) THEN '#13#10 +
        '       II = 1; '#13#10 +
        '     IF (UF > 1) THEN '#13#10 +
        '       UF = 1; '#13#10 +
        '     UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N; '#13#10 +
        '   END '#13#10 +
        '   /* проверяем не изменился ли порядок полей в индексе*/ '#13#10 +
        '   FLIST = '' ''; '#13#10 +
        '   INDEXNAME = '' ''; '#13#10 +
        '   FOR '#13#10 +
        '     SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position '#13#10 +
        '     FROM rdb$index_segments isg LEFT JOIN rdb$indices ri '#13#10 +
        '       ON isg.rdb$index_name = ri.rdb$index_name '#13#10 +
        '     ORDER BY isg.rdb$index_name, isg.rdb$field_position '#13#10 +
        '     INTO :I_N, :FN, :FP '#13#10 +
        '   DO BEGIN '#13#10 +
        '     IF (INDEXNAME <> I_N) THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       IF (INDEXNAME <> '' '') THEN '#13#10 +
        '       BEGIN '#13#10 +
        '         SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL; '#13#10 +
        '         IF ((FL <> FLIST) OR (FL IS NULL)) THEN '#13#10 +
        '           UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME; '#13#10 +
        '       END '#13#10 +
        '       FLIST = UPPER(g_s_trim(FN, '' '')); '#13#10 +
        '       INDEXNAME = I_N; '#13#10 +
        '     END '#13#10 +
        '     ELSE '#13#10 +
        '       FLIST = FLIST || '','' || UPPER(g_s_trim(FN, '' '')); '#13#10 +
        '   END'#13#10 +
        '   IF (INDEXNAME <> '' '') THEN '#13#10 +
        '     BEGIN '#13#10 +
        '       SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL; '#13#10 +
        '       IF ((FL <> FLIST) OR (FL IS NULL)) THEN '#13#10 +
        '         UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME; '#13#10 +
        '   END '#13#10 +
        '  END ';
      Log('Изменение процедуры AT_P_SYNC_INDEXES_ALL');
      ibsql.ExecQuery;
      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'ALTER PROCEDURE AT_P_SYNC_TRIGGERS_ALL '#13#10 +
        ' AS '#13#10 +
        '   DECLARE VARIABLE RN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE TN VARCHAR(31); '#13#10 +
        '   DECLARE VARIABLE ID INTEGER; '#13#10 +
        '   DECLARE VARIABLE TI SMALLINT; '#13#10 +
        ' BEGIN '#13#10 +
        '   /* удалим не существующие уже триггеры */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT triggername '#13#10 +
        '     FROM at_triggers LEFT JOIN rdb$triggers '#13#10 +
        '       ON triggername=rdb$trigger_name '#13#10 +
        '     WHERE '#13#10 +
        '       rdb$trigger_name IS NULL '#13#10 +
        '     INTO :TN   '#13#10 +
        '   DO BEGIN '#13#10 +
        '     DELETE FROM at_triggers WHERE triggername=:TN; '#13#10 +
        '   END '#13#10 +
        '  /* добавим новые триггеры */ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT rdb$relation_name, rdb$trigger_name, '#13#10 +
        '       rdb$trigger_inactive, r.id '#13#10 +
        '     FROM rdb$triggers LEFT JOIN at_triggers t '#13#10 +
        '       ON t.triggername=rdb$trigger_name '#13#10 +
        '     LEFT JOIN at_relations r ON rdb$relation_name = r.relationname '#13#10 +
        '     WHERE '#13#10 +
        '      (t.triggername IS NULL) and (r.id IS NOT NULL) '#13#10 +
        '     INTO :RN, :TN, :TI, :ID '#13#10 +
        '   DO BEGIN '#13#10 +
        '     IF (TI IS NULL) THEN '#13#10 +
        '       TI = 0; '#13#10 +
        '     IF (TI > 1) THEN '#13#10 +
        '       TI = 1; '#13#10 +
        '     INSERT INTO at_triggers(relationname, triggername, relationkey, trigger_inactive) '#13#10 +
        '     VALUES (:RN, :TN, :ID, :TI); '#13#10 +
        '   END '#13#10 +
        '   /* проверяем триггеры на активность*/ '#13#10 +
        '   FOR '#13#10 +
        '     SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name '#13#10 +
        '     FROM rdb$triggers ri '#13#10 +
        '     LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername '#13#10 +
        '     WHERE ((t.trigger_inactive IS NULL) OR '#13#10 +
        '     (t.trigger_inactive <> ri.rdb$trigger_inactive) OR '#13#10 +
        '     (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) '#13#10 +
        '     INTO :TI, :TN '#13#10 +
        '   DO BEGIN '#13#10 +
        '     IF (TI IS NULL) THEN '#13#10 +
        '       TI = 0; '#13#10 +
        '     IF (TI > 1) THEN '#13#10 +
        '       TI = 1; '#13#10 +
        '     UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN;  '#13#10 +
        '   END '#13#10 +
        ' END ';

      Log('Изменение процедуры AT_P_SYNC_TRIGGERS_ALL');
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text :=  ' ALTER PROCEDURE AT_P_SYNC_INDEXES ( ' + #13#10 +
       '      RELATION_NAME VARCHAR (31)) ' + #13#10 +
       ' AS ' + #13#10 +
       '   DECLARE VARIABLE FN VARCHAR(31); ' + #13#10 +
       '   DECLARE VARIABLE RN VARCHAR(31); ' + #13#10 +
       '   DECLARE VARIABLE I_N VARCHAR(31); ' + #13#10 +
       '   DECLARE VARIABLE FP SMALLINT; ' + #13#10 +
       '   DEClARE VARIABLE FLIST VARCHAR(255); ' + #13#10 +
       '   DEClARE VARIABLE FL VARCHAR(255); ' + #13#10 +
       '   DEClARE VARIABLE INDEXNAME VARCHAR(31); ' + #13#10 +
       '   DECLARE VARIABLE ID INTEGER; ' + #13#10 +
       '   DECLARE VARIABLE UF SMALLINT; ' + #13#10 +
       '   DECLARE VARIABLE II SMALLINT; ' + #13#10 +
       ' BEGIN ' + #13#10 +
       ' ' + #13#10 +
       '   /* выдал_м не _снуючыя ўжо iндэксы */ ' + #13#10 +
       '   FOR ' + #13#10 +
       '     SELECT indexname ' + #13#10 +
       '     FROM at_indices LEFT JOIN rdb$indices ' + #13#10 +
       '       ON indexname=rdb$index_name ' + #13#10 +
       '     WHERE ' + #13#10 +
       '       rdb$index_name IS NULL AND rdb$relation_name = :RELATION_NAME ' + #13#10 +
       '     INTO :I_N ' + #13#10 +
       '   DO BEGIN ' + #13#10 +
       '     DELETE FROM at_indices WHERE indexname=:I_N; ' + #13#10 +
       '   END ' + #13#10 +
       ' ' + #13#10 +
       '  /* дадаем новыя iндэксы */ ' + #13#10 +
       '   FOR ' + #13#10 +
       '     SELECT rdb$relation_name, rdb$index_name, ' + #13#10 +
       '       rdb$index_inactive, rdb$unique_flag, r.id ' + #13#10 +
       '     FROM rdb$indices LEFT JOIN at_indices i ' + #13#10 +
       '       ON i.indexname=rdb$index_name  ' + #13#10 +
       '     LEFT JOIN at_relations r ON rdb$relation_name = r.relationname ' + #13#10 +
       '     WHERE ' + #13#10 +
       '      i.indexname IS NULL AND rdb$relation_name = :RELATION_NAME ' + #13#10 +
       '     INTO :RN, :I_N, :II, :UF, :ID ' + #13#10 +
       '   DO BEGIN ' + #13#10 +
       '     IF (II IS NULL) THEN ' + #13#10 +
       '       II = 0; ' + #13#10 +
       '     IF (UF IS NULL) THEN   ' + #13#10 +
       '       UF = 0; ' + #13#10 +
       '     IF (II > 1) THEN ' + #13#10 +
       '       II = 1; ' + #13#10 +
       '     IF (UF > 1) THEN   ' + #13#10 +
       '       UF = 1; ' + #13#10 +
       '     RN = g_s_trim(RN, '' ''); ' + #13#10 +
       '     I_N = g_s_trim(I_N, '' ''); ' + #13#10 +
       '     INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive) ' + #13#10 +
       '     VALUES (:RN, :I_N, :ID, :UF, :II); ' + #13#10 +
       '   END ' + #13#10 +
       ' ' + #13#10 +
       '   /* проверяем индексы на активность и уникальность*/ ' + #13#10 +
       '   FOR ' + #13#10 +
       '     SELECT ri.rdb$index_inactive, ri.rdb$unique_flag, ri.rdb$index_name ' + #13#10 +
       '     FROM rdb$indices ri ' + #13#10 +
       '     LEFT JOIN at_indices i ON ri.rdb$index_name = i.indexname ' + #13#10 +
       '     WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR ' + #13#10 +
       '     (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR ' + #13#10 +
       '     (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR ' + #13#10 +
       '     (i.index_inactive <> ri.rdb$index_inactive) OR ' + #13#10 +
       '     (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1)) AND ' + #13#10 +
       '     (ri.rdb$relation_name = :RELATION_NAME) ' + #13#10 +
       '     INTO :II, :UF, :I_N ' + #13#10 +
       '   DO BEGIN ' + #13#10 +
       '     IF (II IS NULL) THEN ' + #13#10 +
       '       II = 0; ' + #13#10 +
       '     IF (UF IS NULL) THEN  ' + #13#10 +
       '       UF = 0; ' + #13#10 +
       '     IF (II > 1) THEN ' + #13#10 +
       '       II = 1; ' + #13#10 +
       '     IF (UF > 1) THEN   ' + #13#10 +
       '       UF = 1; ' + #13#10 +
       '     UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N; ' + #13#10 +
       '   END ' + #13#10 +
       ' ' + #13#10 +
       '   /* проверяем не изменился ли порядок полей в индексе*/ ' + #13#10 +
       ' ' + #13#10 +
       '   FLIST = '' ''; ' + #13#10 +
       '   INDEXNAME = '' ''; ' + #13#10 +
       '   FOR ' + #13#10 +
       '     SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position ' + #13#10 +
       '     FROM rdb$index_segments isg LEFT JOIN rdb$indices ri ' + #13#10 +
       '       ON isg.rdb$index_name = ri.rdb$index_name ' + #13#10 +
       '     WHERE ri.rdb$relation_name = :RELATION_NAME ' + #13#10 +
       '     ORDER BY isg.rdb$index_name, isg.rdb$field_position ' + #13#10 +
       '     INTO :I_N, :FN, :FP ' + #13#10 +
       '   DO BEGIN ' + #13#10 +
       '     IF (INDEXNAME <> I_N) THEN ' + #13#10 +
       '     BEGIN ' + #13#10 +
       '       IF (INDEXNAME <> '' '') THEN ' + #13#10 +
       '       BEGIN ' + #13#10 +
       '         SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL; ' + #13#10 +
       '         IF ((FL <> FLIST) OR (FL IS NULL)) THEN ' + #13#10 +
       '           UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME; ' + #13#10 +
       '       END ' + #13#10 +
       '       FLIST = g_s_trim(FN, '' ''); ' + #13#10 +
       '       INDEXNAME = I_N; ' + #13#10 +
       '     END ' + #13#10 +
       '     ELSE ' + #13#10 +
       '       FLIST = FLIST || '','' || g_s_trim(FN, '' ''); ' + #13#10 +
       '   END ' + #13#10 +
       '   IF (INDEXNAME <> '' '') THEN ' + #13#10 +
       '     BEGIN ' + #13#10 +
       '       SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL; ' + #13#10 +
       '       IF ((FL <> FLIST) OR (FL IS NULL)) THEN ' + #13#10 +
       '         UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME; ' + #13#10 +
       '   END ' + #13#10 +
       '       ' + #13#10 +
       ' END ';
      Log('Изменение процедуры AT_P_SYNC_INDEXES');
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text :=  'ALTER PROCEDURE AT_P_SYNC_TRIGGERS ( ' + #13#10 +
      '    RELATION_NAME VARCHAR (31)) ' + #13#10 +
      ' AS ' + #13#10 +
      '   DECLARE VARIABLE RN VARCHAR(31); ' + #13#10 +
      '   DECLARE VARIABLE TN VARCHAR(31); ' + #13#10 +
      '   DECLARE VARIABLE ID INTEGER; ' + #13#10 +
      '   DECLARE VARIABLE TI SMALLINT; ' + #13#10 +
      ' BEGIN ' + #13#10 +
      '  ' + #13#10 +
      '  /* удалим не существующие уже триггеры */ ' + #13#10 +
      '  FOR ' + #13#10 +
      '    SELECT triggername ' + #13#10 +
      '    FROM at_triggers LEFT JOIN rdb$triggers ' + #13#10 +
      '      ON triggername=rdb$trigger_name ' + #13#10 +
      '    WHERE ' + #13#10 +
      '      rdb$trigger_name IS NULL AND rdb$relation_name = :RELATION_NAME ' + #13#10 +
      '    INTO :TN ' + #13#10 +
      '  DO BEGIN ' + #13#10 +
      '    DELETE FROM at_triggers WHERE triggername=:TN; ' + #13#10 +
      '  END ' + #13#10 +
      ' ' + #13#10 +
      '  /* добавим новые триггеры */ ' + #13#10 +
      '  FOR ' + #13#10 +
      '    SELECT rdb$relation_name, rdb$trigger_name, ' + #13#10 +
      '      rdb$trigger_inactive, r.id ' + #13#10 +
      '    FROM rdb$triggers LEFT JOIN at_triggers t ' + #13#10 +
      '      ON t.triggername=rdb$trigger_name ' + #13#10 +
      '    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname ' + #13#10 +
      '    WHERE ' + #13#10 +
      '     t.triggername IS NULL AND rdb$relation_name = :RELATION_NAME ' + #13#10 +
      '    INTO :RN, :TN, :TI, :ID ' + #13#10 +
      '  DO BEGIN ' + #13#10 +
      '    RN = g_s_trim(RN, '' ''); ' + #13#10 +
      '    TN = g_s_trim(TN, '' ''); ' + #13#10 +
      '    IF (TI IS NULL) THEN ' + #13#10 +
      '      TI = 0; ' + #13#10 +
      '    IF (TI > 1) THEN ' + #13#10 +
      '      TI = 1; ' + #13#10 +
      '    INSERT INTO at_triggers(relationname, triggername, relationkey, trigger_inactive) ' + #13#10 +
      '    VALUES (:RN, :TN, :ID, :TI); ' + #13#10 +
      '  END ' + #13#10 +
      ' ' + #13#10 +
      '  /* проверяем триггеры на активность*/ ' + #13#10 +
      '  FOR ' + #13#10 +
      '    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name ' + #13#10 +
      '    FROM rdb$triggers ri ' + #13#10 +
      '    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername ' + #13#10 +
      '    WHERE ((t.trigger_inactive IS NULL) OR ' + #13#10 +
      '    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR  ' + #13#10 +
      '    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) AND ' + #13#10 +
      '    (ri.rdb$relation_name = :RELATION_NAME) ' + #13#10 +
      '    INTO :TI, :TN ' + #13#10 +
      '  DO BEGIN ' + #13#10 +
      '    IF (TI IS NULL) THEN ' + #13#10 +
      '      TI = 0; ' + #13#10 +
      '    IF (TI > 1) THEN ' + #13#10 +
      '      TI = 1; ' + #13#10 +
      '    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN; ' + #13#10 +
      '  END ' + #13#10 +
      ' ' + #13#10 +
      'END ';

      Log('Изменение процедуры AT_P_SYNC_TRIGGERS');
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text :=  ' ALTER PROCEDURE AT_P_SYNC '#13#10 +
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
        ' END ';
      Log('Изменение процедуры AT_P_SYNC');
      ibsql.ExecQuery;


      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
