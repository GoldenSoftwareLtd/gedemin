
/*

  гэта€ працэдура с_нхран_зуе змесц_ва табл_цаҐ at_fields, at_relations, at_relation_fields
  з рэальнай структурай базы дадзеных.

  1. выдал€е ҐсЄ, што Ґжо не _снуе
  2. дадае новае
  3. актуал_зуе _нфармацыю

*/
SET TERM ^ ;

CREATE PROCEDURE AT_P_SYNC 
AS
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE ID1 INTEGER;
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE FS VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE NFS VARCHAR(31);
  DECLARE VARIABLE VS BLOB SUB_TYPE 0 SEGMENT SIZE 80;
  DECLARE VARIABLE EN VARCHAR(31);
  DECLARE VARIABLE DELRULE VARCHAR(20);
  DECLARE VARIABLE WASERROR SMALLINT;
  DECLARE VARIABLE GN VARCHAR(64);
BEGIN 
 /* пакольк_ каскады не выкарыстоҐваюцца мус_м */ 
 /* п_льнавацца пэҐнага парадку                */ 
  
 /* выдал_м не _снуючы€ Ґжо пал_ табл_цаҐ      */ 
   FOR 
     SELECT fieldname, relationname 
     FROM at_relation_fields LEFT JOIN rdb$relation_fields 
       ON fieldname=rdb$field_name AND relationname=rdb$relation_name 
     WHERE 
       rdb$field_name IS NULL 
     INTO :FN, :RN 
   DO BEGIN 
     DELETE FROM at_relation_fields WHERE fieldname=:FN AND relationname=:RN; 
   END 
  
 /* дададз_м новы€ дамены */ 
   INSERT INTO AT_FIELDS (fieldname, lname, description)
   SELECT trim(rdb$field_name), trim(rdb$field_name),
     trim(rdb$field_name)
   FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname
     WHERE fieldname IS NULL;
  
 /* дл€ _снуючых палЄҐ аднав_м _нфармацыю аб тыпе */ 
   FOR 
     SELECT fieldsource, fieldname, relationname 
     FROM at_relation_fields 
     INTO :FS, :FN, :RN 
   DO BEGIN 
     SELECT rf.rdb$field_source, f.id 
     FROM rdb$relation_fields rf JOIN at_fields f ON rf.rdb$field_source = f.fieldname 
     WHERE rdb$relation_name=:RN AND rdb$field_name = :FN 
     INTO :NFS, :ID; 
  
     IF (:NFS <> :FS AND (NOT (:NFS IS NULL))) THEN 
     UPDATE at_relation_fields SET fieldsource = :NFS, fieldsourcekey = :ID 
     WHERE fieldname = :FN AND relationname = :RN; 
   END 
  
 /* выдал_м з табл_цы даменаҐ не _снуючы€ дамены */ 
   DELETE FROM at_fields f WHERE
   NOT EXISTS (SELECT rdb$field_name FROM rdb$fields
     WHERE rdb$field_name = f.fieldname);

  
 /*“еперь будем аккуратно провер€ть на несуществующие уже таблицы и существующие 
 домены, которые ссылаютс€ на эти таблицы. “ака€ ситуаци€ может возникнуть из-за 
 ошибки при создании мета-данных*/ 
  
   WASERROR = 0; 
  
   FOR 
 /*¬ыберем все пол€ и удалим*/ 
     SELECT rf.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.reftablekey 
     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_relation_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*¬ыберем все домены и удалим*/ 
     SELECT f.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.reftablekey 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*¬ыберем все пол€ и удалим*/ 
     SELECT rf.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.settablekey 
     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_relation_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*¬ыберем все домены и удалим*/ 
     SELECT f.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.settablekey 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_fields WHERE id = :ID; 
   END 
  
   FOR 
/*выберем все документы, у которых шапка ссылаетс€ на несуществующие таблицы и удалим*/ 
     SELECT dt.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN gd_documenttype dt ON dt.headerrelkey =r.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     DELETE FROM gd_documenttype WHERE id = :ID; 
   END 
 
   FOR 
/*выберем все документы, у которых позици€ ссылаетс€ на несуществующие таблицы и удалим*/ 
     SELECT dt.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN gd_documenttype dt ON dt.linerelkey =r.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     DELETE FROM gd_documenttype WHERE id = :ID; 
   END 
   IF (WASERROR = 1) THEN 
   BEGIN 
 /* ѕеречитаем домены. “еперь те домены, которые были проблемными добав€тс€ без ошибок */ 
     INSERT INTO AT_FIELDS (fieldname, lname, description)
     SELECT g_s_trim(rdb$field_name, ' '), g_s_trim(rdb$field_name, ' '),
       g_s_trim(rdb$field_name, ' ')
     FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname
       WHERE fieldname IS NULL;
   END 
  
 /* выдал_м табл_цы, €к_х ужо н€ма */ 
   DELETE FROM at_relations r WHERE
   NOT EXISTS (SELECT rdb$relation_name FROM rdb$relations
     WHERE rdb$relation_name = r.relationname );
  
 /* дададз_м новы€ табл_цы */ 
 /* акрам€ с_стэмных  */ 
   FOR 
     SELECT rdb$relation_name, rdb$view_source 
     FROM rdb$relations LEFT JOIN at_relations ON relationname=rdb$relation_name 
     WHERE (relationname IS NULL) AND (NOT rdb$relation_name CONTAINING 'RDB$') 
     INTO :RN, :VS 
   DO BEGIN 
     RN = g_s_trim(RN, ' '); 
     IF (:VS IS NULL) THEN 
       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) 
       VALUES (:RN, 'T', :RN, :RN, :RN); 
     ELSE 
       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) 
       VALUES (:RN, 'V', :RN, :RN, :RN); 
     END 
  
 /* дадаем новы€ пал_ */ 
   FOR 
     SELECT 
       rr.rdb$field_name, rr.rdb$field_source, rr.rdb$relation_name, r.id, f.id 
     FROM 
       rdb$relation_fields rr JOIN at_relations r ON rdb$relation_name = r.relationname 
     JOIN at_fields f ON rr.rdb$field_source = f.fieldname 
     LEFT JOIN at_relation_fields rf ON rr.rdb$field_name = rf.fieldname 
     AND rr.rdb$relation_name = rf.relationname 
     WHERE 
       (rf.fieldname IS NULL) AND (NOT rr.rdb$field_name CONTAINING 'RDB$') 
     INTO 
       :FN, :FS, :RN, :ID, :ID1 
   DO BEGIN 
     FN = g_s_trim(FN, ' '); 
     FS = g_s_trim(FS, ' '); 
     RN = g_s_trim(RN, ' '); 
     INSERT INTO at_relation_fields (fieldname, relationname, fieldsource, lname, description, 
       relationkey, fieldsourcekey, colwidth, visible) 
     VALUES(:FN, :RN, :FS, :FN, :FN, :ID, :ID1, 20, 1); 
   END 
  
 /* обновим информацию о правиле удалени€ дл€ полей ссылок */ 
   FOR 
     SELECT rf.rdb$delete_rule, f.id 
     FROM rdb$relation_constraints rc 
     LEFT JOIN rdb$index_segments rs ON rc.rdb$index_name = rs.rdb$index_name 
     LEFT JOIN at_relation_fields f ON rc.rdb$relation_name = f.relationname 
     AND  rs.rdb$field_name = f.fieldname 
     LEFT JOIN rdb$ref_constraints rf ON rf.rdb$constraint_name = rc.rdb$constraint_name 
     WHERE 
     rc.rdb$constraint_type = 'FOREIGN KEY' 
     AND ((f.deleterule <> rf.rdb$delete_rule) 
     OR ((f.deleterule IS NULL) AND (rf.rdb$delete_rule IS NOT NULL)) 
     OR ((f.deleterule IS NOT NULL) AND (rf.rdb$delete_rule IS NULL))) 
     INTO :DELRULE, :ID 
   DO BEGIN 
     UPDATE at_relation_fields SET deleterule = :DELRULE WHERE id = :ID; 
   END 
  
 /* выдал_м не _снуючы€ Ґжо выключэннi */ 
   FOR 
     SELECT exceptionname 
     FROM at_exceptions LEFT JOIN rdb$exceptions 
     ON exceptionname=rdb$exception_name 
     WHERE 
       rdb$exception_name IS NULL 
     INTO :EN 
   DO BEGIN 
     DELETE FROM at_exceptions WHERE exceptionname=:EN; 
   END 
  
 /* дадаем новы€ выключэннi */ 
   INSERT INTO at_exceptions(exceptionname)
   SELECT g_s_trim(rdb$exception_name, ' ')
   FROM rdb$exceptions
   LEFT JOIN at_exceptions e ON e.exceptionname=rdb$exception_name
   WHERE e.exceptionname IS NULL;

 /* выдал_м не _снуючы€ Ґжо працэдуры */ 
   FOR 
     SELECT procedurename 
     FROM at_procedures LEFT JOIN rdb$procedures 
       ON procedurename=rdb$procedure_name 
     WHERE 
       rdb$procedure_name IS NULL 
     INTO :EN 
   DO BEGIN 
     DELETE FROM at_procedures WHERE procedurename=:EN; 
   END 
  
 /* дадаем новы€ працэдуры */ 
   INSERT INTO at_procedures(procedurename)
   SELECT g_s_trim(rdb$procedure_name, ' ')
   FROM rdb$procedures
   LEFT JOIN at_procedures e ON e.procedurename = rdb$procedure_name
   WHERE e.procedurename IS NULL;
       
 /* удалим не существующие уже генераторы */ 
   GN = NULL; 
   FOR  
     SELECT generatorname 
     FROM at_generators 
     LEFT JOIN rdb$generators ON generatorname=rdb$generator_name 
     WHERE rdb$generator_name IS NULL 
     INTO :GN  
   DO  
   BEGIN 
     DELETE FROM at_generators WHERE generatorname=:GN;  
   END 
       
 /* добавим новые генераторы */  
   INSERT INTO at_generators(generatorname)
   SELECT G_S_TRIM(rdb$generator_name, ' ')
   FROM rdb$generators
   LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name
   WHERE t.generatorname IS NULL;
       
 /* удалим не существующие уже чеки */ 
   EN = NULL; 
   FOR 
     SELECT T.CHECKNAME 
     FROM AT_CHECK_CONSTRAINTS T 
     LEFT JOIN RDB$CHECK_CONSTRAINTS C ON T.CHECKNAME = C.RDB$CONSTRAINT_NAME 
     WHERE C.RDB$CONSTRAINT_NAME IS NULL 
     INTO :EN 
   DO 
   BEGIN 
     DELETE FROM AT_CHECK_CONSTRAINTS WHERE CHECKNAME = :EN; 
   END 
       
 /* добавим новые чеки */ 
   INSERT INTO AT_CHECK_CONSTRAINTS(CHECKNAME)
   SELECT G_S_TRIM(C.RDB$CONSTRAINT_NAME,  ' ')
   FROM RDB$TRIGGERS T
   LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME
   LEFT JOIN AT_CHECK_CONSTRAINTS CON ON CON.CHECKNAME = C.RDB$CONSTRAINT_NAME
   WHERE T.RDB$TRIGGER_SOURCE LIKE 'CHECK%'
     AND CON.CHECKNAME IS NULL;

END
^

COMMIT^


CREATE PROCEDURE AT_P_SYNC_INDEXES (
    RELATION_NAME VARCHAR (31))
AS
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE I_N VARCHAR(31);
  DECLARE VARIABLE FP SMALLINT;
  DEClARE VARIABLE FLIST VARCHAR(255);
  DEClARE VARIABLE FL VARCHAR(255);
  DEClARE VARIABLE INDEXNAME VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE UF SMALLINT;
  DECLARE VARIABLE II SMALLINT;
BEGIN

  /* выдал_м не _снуючы€ Ґжо iндэксы */
  FOR
    SELECT indexname
    FROM at_indices LEFT JOIN rdb$indices
      ON indexname=rdb$index_name
    WHERE
      rdb$index_name IS NULL AND relationname = :RELATION_NAME
    INTO :I_N
  DO BEGIN
    DELETE FROM at_indices WHERE indexname=:I_N;
  END


 /* дадаем новы€ iндэксы */
  FOR
    SELECT rdb$relation_name, rdb$index_name,
      rdb$index_inactive, rdb$unique_flag, r.id
    FROM rdb$indices LEFT JOIN at_indices i
      ON i.indexname=rdb$index_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     i.indexname IS NULL AND rdb$relation_name = :RELATION_NAME
    INTO :RN, :I_N, :II, :UF, :ID
  DO BEGIN
    IF (II IS NULL) THEN
      II = 0;
    IF (UF IS NULL) THEN
      UF = 0;
    IF (II > 1) THEN
      II = 1;
    IF (UF > 1) THEN
      UF = 1;
    RN = g_s_trim(RN, ' ');
    I_N = g_s_trim(I_N, ' ');
    INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive)
    VALUES (:RN, :I_N, :ID, :UF, :II);
  END

  /* провер€ем индексы на активность и уникальность*/
  FOR
    SELECT ri.rdb$index_inactive, ri.rdb$unique_flag, ri.rdb$index_name
    FROM rdb$indices ri
    LEFT JOIN at_indices i ON ri.rdb$index_name = i.indexname
    WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR
    (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR
    (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR
    (i.index_inactive <> ri.rdb$index_inactive) OR
    (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1)) AND
    (ri.rdb$relation_name = :RELATION_NAME)
    INTO :II, :UF, :I_N
  DO BEGIN
    IF (II IS NULL) THEN
      II = 0;
    IF (UF IS NULL) THEN
      UF = 0;
    IF (II > 1) THEN
      II = 1;
    IF (UF > 1) THEN
      UF = 1;
    UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N;
  END



  /* провер€ем не изменилс€ ли пор€док полей в индексе*/

  FLIST = ' ';
  INDEXNAME = ' ';
  FOR
    SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position
    FROM rdb$index_segments isg LEFT JOIN rdb$indices ri
      ON isg.rdb$index_name = ri.rdb$index_name
    WHERE ri.rdb$relation_name = :RELATION_NAME
    ORDER BY isg.rdb$index_name, isg.rdb$field_position
    INTO :I_N, :FN, :FP
  DO BEGIN
    IF (INDEXNAME <> I_N) THEN
    BEGIN
      IF (INDEXNAME <> ' ') THEN
      BEGIN
        SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
        IF ((FL <> FLIST) OR (FL IS NULL)) THEN
          UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
      END
      FLIST = g_s_trim(FN, ' ');
      INDEXNAME = I_N;
    END
    ELSE
      FLIST = FLIST || ',' || g_s_trim(FN, ' ');
  END
  IF (INDEXNAME <> ' ') THEN
    BEGIN
      SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
      IF ((FL <> FLIST) OR (FL IS NULL)) THEN
        UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
  END

END
^

CREATE PROCEDURE AT_P_SYNC_TRIGGERS (
    RELATION_NAME VARCHAR (31))
AS
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE TN VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE TI SMALLINT;
BEGIN

  /* удалим не существующие уже триггеры */
  FOR
    SELECT triggername
    FROM at_triggers
      LEFT JOIN rdb$triggers
        ON triggername=rdb$trigger_name
          AND relationname=rdb$relation_name
    WHERE
      rdb$trigger_name IS NULL AND relationname = :RELATION_NAME
    INTO :TN
  DO BEGIN
    DELETE FROM at_triggers WHERE triggername=:TN;
  END


 /* добавим новые триггеры */
  FOR
    SELECT rdb$relation_name, rdb$trigger_name,
      rdb$trigger_inactive, r.id
    FROM rdb$triggers LEFT JOIN at_triggers t
      ON t.triggername=rdb$trigger_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     t.triggername IS NULL AND rdb$relation_name = :RELATION_NAME
    INTO :RN, :TN, :TI, :ID
  DO BEGIN
    RN = G_S_TRIM(RN, ' ');
    TN = G_S_TRIM(TN, ' ');
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    INSERT INTO at_triggers(
      relationname, triggername, relationkey, trigger_inactive)
    VALUES (
      :RN, :TN, :ID, :TI);
  END

  /* провер€ем триггеры на активность*/
  FOR
    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name
    FROM rdb$triggers ri
    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername
    WHERE ((t.trigger_inactive IS NULL) OR
    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR
    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) AND
    (ri.rdb$relation_name = :RELATION_NAME)
    INTO :TI, :TN
  DO BEGIN
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN;
  END

END
^


CREATE PROCEDURE AT_P_SYNC_INDEXES_ALL
AS
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE I_ID INTEGER;
  DECLARE VARIABLE I_N VARCHAR(31);
  DECLARE VARIABLE FP SMALLINT;
  DEClARE VARIABLE FLIST VARCHAR(255);
  DEClARE VARIABLE FL VARCHAR(255);
  DEClARE VARIABLE INDEXNAME VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE UF SMALLINT;
  DECLARE VARIABLE II SMALLINT;
BEGIN

  /* выдал_м не _снуючы€ Ґжо iндэксы */
  FOR
    SELECT id
    FROM at_indices LEFT JOIN rdb$indices
      ON indexname=rdb$index_name
    WHERE
      rdb$index_name IS NULL
    INTO :I_ID
  DO BEGIN
    DELETE FROM at_indices WHERE id=:I_ID;
  END


 /* дадаем новы€ iндэксы */
  FOR
    SELECT rdb$relation_name, rdb$index_name,
      COALESCE(rdb$index_inactive, 0), COALESCE(rdb$unique_flag, 0), r.id
    FROM rdb$indices LEFT JOIN at_indices i
      ON i.indexname=rdb$index_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
      (i.indexname IS NULL) AND (r.id IS NOT NULL)
    INTO :RN, :I_N, :II, :UF, :ID
  DO BEGIN
    RN = trim(RN);
    I_N = trim(I_N);
    IF (II <> 0) THEN
      II = 1;
    IF (UF <> 0) THEN
      UF = 1;
    INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive)
    VALUES (:RN, :I_N, :ID, :UF, :II);
  END

  /* провер€ем индексы на активность и уникальность*/
  FOR
    SELECT COALESCE(ri.rdb$index_inactive, 0), COALESCE(ri.rdb$unique_flag, 0), ri.rdb$index_name
    FROM at_indices i
    LEFT JOIN rdb$indices ri ON ri.rdb$index_name = i.indexname
    WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR
    (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR
    (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR
    (i.index_inactive <> ri.rdb$index_inactive) OR
    (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1))
    INTO :II, :UF, :I_N
  DO BEGIN
    IF (II <> 0) THEN
      II = 1;
    IF (UF <> 0) THEN
      UF = 1;
    UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N;
  END



  /* провер€ем не изменилс€ ли пор€док полей в индексе*/

  FLIST = ' ';
  INDEXNAME = ' ';
  FOR
    SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position
    FROM rdb$index_segments isg LEFT JOIN rdb$indices ri
      ON isg.rdb$index_name = ri.rdb$index_name
    ORDER BY isg.rdb$index_name, isg.rdb$field_position
    INTO :I_N, :FN, :FP
  DO BEGIN
    IF (INDEXNAME <> I_N) THEN
    BEGIN
      IF (INDEXNAME <> ' ') THEN
      BEGIN
        SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
        IF ((FL <> FLIST) OR (FL IS NULL)) THEN
          UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
      END
      FLIST = UPPER(trim(FN));
      INDEXNAME = I_N;
    END
    ELSE
      FLIST = FLIST || ',' || UPPER(trim(FN));
  END
  IF (INDEXNAME <> ' ') THEN
    BEGIN
      SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
      IF ((FL <> FLIST) OR (FL IS NULL)) THEN
        UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
  END

END
^

CREATE PROCEDURE AT_P_SYNC_TRIGGERS_ALL
AS
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE TN VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE TI SMALLINT;
BEGIN

  /* удалим не существующие уже триггеры */
  FOR
    SELECT triggername
    FROM at_triggers LEFT JOIN rdb$triggers
      ON triggername=rdb$trigger_name
        AND relationname=rdb$relation_name
    WHERE
      rdb$trigger_name IS NULL
    INTO :TN
  DO BEGIN
    DELETE FROM at_triggers WHERE triggername=:TN;
  END


 /* добавим новые триггеры */
  FOR
    SELECT rdb$relation_name, rdb$trigger_name,
      rdb$trigger_inactive, r.id
    FROM rdb$triggers LEFT JOIN at_triggers t
      ON t.triggername=rdb$trigger_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     (t.triggername IS NULL) and (r.id IS NOT NULL)
    INTO :RN, :TN, :TI, :ID
  DO BEGIN
    RN = G_S_TRIM(RN, ' ');
    TN = G_S_TRIM(TN, ' ');
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    INSERT INTO at_triggers(relationname, triggername, relationkey, trigger_inactive)
    VALUES (:RN, :TN, :ID, :TI);
  END

  /* провер€ем триггеры на активность*/
  FOR
    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name
    FROM rdb$triggers ri
    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername
    WHERE ((t.trigger_inactive IS NULL) OR
    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR
    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1))
    INTO :TI, :TN
  DO BEGIN
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN;
  END

END
^
SET TERM ; ^
COMMIT;
