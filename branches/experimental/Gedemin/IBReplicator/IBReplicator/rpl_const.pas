unit rpl_const;

interface
//uses gd_directories_const;
type
  TMetaDateAction = (mdaCreate, mdaDrop, mdaAlter);

  TRole = string;
  
  TDomane = record
    Name: string;
    Description: string;
  end;

  TGenerator = record
    Name: string;
    Value: Integer;
  end;

  TTable = record
    Name: string;
    Body: String;
  end;

  TExcept = record
    Name: string;
    Message: String;
  end;

  TTriggerState = (tsActive, tsInactive);
  TTriggerActionPosition = (tapBefore, tapAfter);
  TTriggerAction = (taInsert, taDelete, taUpdate);

  PTrigger = ^TTrigger;
  TTrigger = record
    TriggerName: string;
    RelationName: string;
    Body: string;
    State: TTriggerState;
    ActionPosition: TTriggerActionPosition;
    Action: TTriggerAction;
    Position: Integer;
  end;

const
  Role: TRole = 'REPLICATOR';

  DomaneCount = 6;
  Domanes: array [0..DomaneCount -1] of TDomane = (
    (Name: 'DRPLINTEGER_NOT_NULL'; Description: 'INTEGER NOT NULL'),
    (Name: 'DRPLBLOB'; Description: 'BLOB'),
    (Name: 'DRPLNAME'; Description: 'VARCHAR(31) NOT NULL'),
    (Name: 'DRPLKEYSET'; Description: 'VARCHAR(255) NOT NULL'),
    (Name: 'DRPLDESCRIPTION'; Description: 'VARCHAR(255) NOT NULL'),
    (Name: 'DRPLINTEGER'; Description: 'INTEGER'));

  GeneratorCount = 1;
  Generators: array [0..GeneratorCount - 1] of TGenerator = (
    (Name: 'RPL$G_SEQ'; Value: 1));
  GD_G_DBID: TGenerator = (Name: 'GD_G_DBID'; Value: 0);

  TableCount = 8;
  RPL_REPLICATIONDB_INDEX = 0;
  RPL_DBSTATE_INDEX = 1;
  RPL_RELATION_INDEX = 2;
  RPL_FIELDS_INDEX = 3;
  RPL_KEYS_INDEX = 4;
  RPL_LOG_INDEX = 5;

  Tables: array [0..TableCount - 1] of TTable = (
    (Name: 'RPL$REPLICATIONDB'; Body:
      ' CREATE TABLE RPL$REPLICATIONDB ( ' +
      ' DBKEY                DRPLINTEGER_NOT_NULL, ' +
      ' DBSTATE              DRPLINTEGER_NOT_NULL, ' +
      ' PRIORITY             DRPLINTEGER_NOT_NULL, ' +
      ' DBNAME               DRPLNAME, ' +
      ' RUIDCONFORMITY       DRPLBLOB, ' +
      ' LASTPROCESSREPLKEY   DRPLINTEGER_NOT_NULL, ' +
      ' LASTPROCESSREPLDATE  TIMESTAMP, ' +
      ' REPLKEY              DRPLINTEGER_NOT_NULL, ' +
      ' REPLDATE             TIMESTAMP ); '#13#10 +
      ' ALTER TABLE RPL$REPLICATIONDB ADD PRIMARY KEY (DBKEY); '),
    (Name: 'RPL$DBSTATE'; Body:
      ' CREATE TABLE RPL$DBSTATE ( ' +
      ' DBKEY                DRPLINTEGER_NOT_NULL, ' +
      ' REPLICATIONID        DRPLINTEGER_NOT_NULL, ' +
      ' ERRORDECISION        DRPLINTEGER_NOT_NULL, ' +
      ' FK                   DRPLBLOB, ' +
      ' FKETALON             DRPLBLOB, ' +
      ' TRIGGERS             DRPLBLOB, ' +
      ' PRIMEKEYTYPE         DRPLINTEGER_NOT_NULL, ' +
      ' GENERATORNAME        DRPLNAME, ' +
      ' KEYDIVIDER           VARCHAR(5), ' +
      ' PREPARED             DRPLINTEGER_NOT_NULL CHECK (PREPARED IN (0, 1)), ' +
      ' DIRECTION            DRPLINTEGER_NOT_NULL DEFAULT 2); '#13#10 +
      ' ALTER TABLE RPL$DBSTATE ADD FOREIGN KEY (DBKEY) ' +
      ' REFERENCES RPL$REPLICATIONDB (DBKEY) ON DELETE NO ACTION ON UPDATE CASCADE'),
    (Name: 'RPL$RELATIONS'; Body:
      ' CREATE TABLE RPL$RELATIONS ( ' +
      ' ID                   DRPLINTEGER_NOT_NULL, ' +
      ' RELATION             DRPLNAME, ' +
      ' GENERATORNAME        DRPLNAME); '#13#10 +
      ' ALTER TABLE RPL$RELATIONS ADD PRIMARY KEY (ID); '{#13#10 +
      ' ALTER TABLE RPL$RELATIONS ADD FOREIGN KEY (ID) ' +
      ' REFERENCES RDB$RELATIONS (RDB$RELATION_ID) '#13#10 +
      ' ON DELETE CASCADE'}),
    (Name: 'RPL$FIELDS'; Body:
      ' CREATE TABLE RPL$FIELDS ( ' +
      ' RELATIONKEY          DRPLINTEGER_NOT_NULL, ' +
      ' FIELDNAME            DRPLNAME); '#13#10 +
      ' ALTER TABLE RPL$FIELDS ADD PRIMARY KEY (RELATIONKEY, FIELDNAME);'#13#10 +
      ' ALTER TABLE RPL$FIELDS ADD FOREIGN KEY (RELATIONKEY) ' +
      ' REFERENCES RPL$RELATIONS (ID) ON DELETE CASCADE; '),
    (Name: 'RPL$KEYS'; Body:
      ' CREATE TABLE RPL$KEYS ( ' +
      ' RELATIONKEY          DRPLINTEGER_NOT_NULL, ' +
      ' KEYNAME              DRPLNAME); '+
      ' ALTER TABLE RPL$KEYS ADD PRIMARY KEY (RELATIONKEY, KEYNAME); '#13#10 +
      ' ALTER TABLE RPL$KEYS  ADD FOREIGN KEY (RELATIONKEY) ' +
      ' REFERENCES RPL$RELATIONS (ID) ON DELETE CASCADE; '),
    (Name: 'RPL$LOG'; Body:
      ' CREATE TABLE RPL$LOG ( '#13#10 +
      ' SEQNO                DRPLINTEGER_NOT_NULL, '#13#10 +
      ' RELATIONKEY          DRPLINTEGER_NOT_NULL, '#13#10 +
      ' REPLTYPE             CHAR(1) CHECK (REPLTYPE IN (''I'', ''U'', ''D'')), '#13#10 +
      ' OLDKEY               DRPLKEYSET, '#13#10 +
      ' NEWKEY               DRPLKEYSET, '#13#10 +
      ' ACTIONTIME           TIMESTAMP, '#13#10 +
      ' DBKEY                DRPLINTEGER '#13#10 +
      ' ); '#13#10 +
      ' ALTER TABLE RPL$LOG ADD PRIMARY KEY (SEQNO); '#13#10 +
      ' ALTER TABLE RPL$LOG ADD FOREIGN KEY (RELATIONKEY) '#13#10 +
      ' REFERENCES RPL$RELATIONS ON DELETE CASCADE; '#13#10 +
      ' ALTER TABLE RPL$LOG ADD FOREIGN KEY (DBKEY) '#13#10 +
      ' REFERENCES RPL$REPLICATIONDB ON DELETE CASCADE; '#13#10 +
      ' GRANT INSERT ON RPL$LOG TO PUBLIC'),
    (Name: 'RPL$LOGHIST'; Body:
      ' CREATE TABLE RPL$LOGHIST ( ' +
      ' SEQNO                DRPLINTEGER_NOT_NULL, ' +
      ' DBKEY                DRPLINTEGER_NOT_NULL, ' +
      ' REPLKEY              DRPLINTEGER_NOT_NULL,' +
      ' TR_COMMIT            DRPLINTEGER_NOT_NULL,' +
      ' CHECK (TR_COMMIT IN (-1, 0, 1))); '#13#10 +
      ' ALTER TABLE RPL$LOGHIST ADD PRIMARY KEY (SEQNO, DBKEY); '#13#10 +
      ' ALTER TABLE RPL$LOGHIST ADD FOREIGN KEY (DBKEY) ' +
      ' REFERENCES RPL$REPLICATIONDB ON DELETE CASCADE; '#13#10 +
      ' ALTER TABLE RPL$LOGHIST ADD FOREIGN KEY (SEQNO) ' +
      ' REFERENCES RPL$LOG ON DELETE CASCADE'),
    (Name: 'RPL$MANUAL_LOG'; Body:
      ' CREATE TABLE RPL$MANUAL_LOG ( ' +
      ' SEQNO                DRPLINTEGER_NOT_NULL, ' +
      ' DBKEY                DRPLINTEGER_NOT_NULL, ' +
      ' REPLKEY              DRPLINTEGER_NOT_NULL, ' +
      ' RELATIONKEY          DRPLINTEGER_NOT_NULL, ' +
      ' REPLTYPE             CHAR(1) CHECK (REPLTYPE IN (''I'', ''U'', ''D'')), ' +
      ' OLDKEY               DRPLKEYSET, ' +
      ' NEWKEY               DRPLKEYSET, ' +
      ' ACTIONTIME           TIMESTAMP, ' +
      ' CORTEGE              DRPLBLOB, ' +
      ' ERRORCODE            DRPLINTEGER, ' +
      ' ERRORDESCRIPTION     DRPLDESCRIPTION' +
      ' ); '#13#10 +
      ' ALTER TABLE RPL$MANUAL_LOG ADD PRIMARY KEY (SEQNO, DBKEY); '#13#10 +
      ' ALTER TABLE RPL$MANUAL_LOG ADD FOREIGN KEY (DBKEY) ' +
      ' REFERENCES RPL$REPLICATIONDB ON DELETE CASCADE; '#13#10 +
      ' ALTER TABLE RPL$MANUAL_LOG ADD FOREIGN KEY (RELATIONKEY) ' +
      ' REFERENCES RPL$RELATIONS ON DELETE CASCADE; ')
  );
  //Таблица GD_RUID для случая если ключ уникален в пределах таблицы
  GD_RUID_RU: TTable = (
    Name: 'GD_RUID';
    Body: 'CREATE TABLE GD_RUID ( '#13#10 +
      'ID         DRPLINTEGER_NOT_NULL, '#13#10 +
      'RELATIONID DRPLINTEGER_NOT_NULL, '#13#10 +
      'XID        DRPLINTEGER_NOT_NULL, '#13#10 +
      'DBID       DRPLINTEGER_NOT_NULL);');

  //Таблица GD_RUID для случая если ключ уникален в пределах базы
  GD_RUID_DBU: TTable = (
    Name: 'GD_RUID';
    Body: 'CREATE TABLE GD_RUID ( '#13#10 +
      'ID         DRPLINTEGER_NOT_NULL, '#13#10 +
      'XID        DRPLINTEGER_NOT_NULL, '#13#10 +
      'DBID       DRPLINTEGER_NOT_NULL);');

  ExceptionCount = 1;
  Exceptions: array[0..ExceptionCount - 1] of TExcept = (
    (Name: 'RPL$E_CANTCHANGE'; Message: 'Data in this table can''''t be modified.'));

  {$IFDEF GEDEMIN}
  ReplTriggerCount = 20;
  {$ELSE}
  ReplTriggerCount = 19;
  {$ENDIF}
  ReplTriggerBody = '  IF (USER <> ''SYSDBA'') THEN '#13#10 +
      '    EXCEPTION RPL$E_CANTCHANGE; ';

  ReplTriggers: array[0..ReplTriggerCount - 1] of TTrigger = (
    (TriggerName: 'RPL$BI_LOG'; RelationName: 'RPL$LOG';
    Body:
      '  IF (NEW.SEQNO IS NULL) THEN ' +
      '    NEW.SEQNO = GEN_ID(RPL$G_SEQ, 1); '#13#10 +
      '  IF (NEW.ACTIONTIME IS NULL) THEN '#13#10 +
      '    NEW.ACTIONTIME = CURRENT_TIMESTAMP;';
    State: tsActive; ActionPosition: tapBefore; Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BI_REPLICATIONDB'; RelationName: 'RPL$REPLICATIONDB';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_REPLICATIONDB'; RelationName: 'RPL$REPLICATIONDB';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BI_REPLICATIONDB'; RelationName: 'RPL$REPLICATIONDB';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RPL$BI_DBSTATE'; RelationName: 'RPL$DBSTATE';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_DBSTATE'; RelationName: 'RPL$DBSTATE';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BD_DBSTATE'; RelationName: 'RPL$DBSTATE';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RPL$BI_RELATIONS'; RelationName: 'RPL$RELATIONS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_RELATIONS'; RelationName: 'RPL$RELATIONS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BD_RELATIONS'; RelationName: 'RPL$RELATIONS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RPL$BI_FIELDS'; RelationName: 'RPL$FIELDS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_FIELDS'; RelationName: 'RPL$FIELDS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BD_FIELDS'; RelationName: 'RPL$FIELDS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RPL$BI_KEYS'; RelationName: 'RPL$KEYS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_KEYS'; RelationName: 'RPL$KEYS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BD_KEYS'; RelationName: 'RPL$KEYS';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RPL$BI_LOGHIST'; RelationName: 'RPL$LOGHIST';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RPL$BU_LOGHIST'; RelationName: 'RPL$LOGHIST';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RPL$BD_LOGHIST'; RelationName: 'RPL$LOGHIST';
      Body: ReplTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1)
    {$IFDEF GEDEMIN},
    (TriggerName: 'RPL$BI_GD_RUID'; RelationName: 'GD_RUID';
      Body:
      '  IF (NEW.MODIFIED IS NULL) THEN '#13#10 +
      '    NEW.MODIFIED = CURRENT_TIMESTAMP;'; State: tsActive;
      ActionPosition: tapBefore; Action: taInsert; Position: 1)
    {$ENDIF}
    );

  { TODO :
  Необходимо прибумать способ запретить изменения метаданных.
  Просто повесить триггеры нельзя т.к. их потом нельзя удалить,
  вовсяком случае на гедеминовской базе. }
   {$IFDEF RDBTRIGGERS}
   RdbTriggerCount = 6;
   RdbTriggerBody = ReplTriggerBody;
   //перед удалением триггеров их необходимо деактивизировать
   RdbTriggers: array[0..RdbTriggerCount - 1] of TTrigger = (
    (TriggerName: 'RDB$BI_RELATION_FIELDS'; RelationName: 'RDB$RELATION_FIELDS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RDB$BU_RELATION_FIELDS'; RelationName: 'RDB$RELATION_FIELDS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RDB$BD_RELATION_FIELDS'; RelationName: 'RDB$RELATION_FIELDS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1),
    (TriggerName: 'RDB$BI_RELATIONS'; RelationName: 'RDB$RELATIONS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taInsert; Position: 1),
    (TriggerName: 'RDB$BU_RELATIONS'; RelationName: 'RDB$RELATIONS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taUpdate; Position: 1),
    (TriggerName: 'RDB$BD_RELATIONS'; RelationName: 'RDB$RELATIONS';
      Body: RdbTriggerBody; State: tsActive; ActionPosition: tapBefore;
      Action: taDelete; Position: 1));
    {$ENDIF}
const
  cIndexCreateTables = 0;
  cIndexDeleteTables = 1;

  cExceptionsCount = 1;
  cGeneratorsCount = 3;
  cTriggerPos = 32767;

  DefaultReplKey = 1;
  DefaultLastProcessReplKey = 0;

const
  prTCP     = 'TCP/IP';
  prNetBEUI = 'NETBEUI';
  prSPX     = 'SPX';
  prLocal = 'Local';

const
  cTriggerBody =  '    INSERT INTO RPL$LOG(RELATIONKEY, REPLTYPE, OLDKEY, NEWKEY)'#13#10 +
                  '      VALUES(%d, %s, %s, %s);';
    
  cForeignUpdate =
     '   IF (NOT new.%s IS NULL) THEN '#13#10 +
     '     UPDATE %s SET %s = %s WHERE %s;'#13#10;

  // Проверка количества системных таблиц
  cCheckTableExist = 'SELECT COUNT(*) FROM rdb$relations ' +
    'WHERE rdb$relation_name in (''RPL$DBSTATE'', ''RPL$FIELDS'', ''RPL$KEYS''' +
    ', ''RPL$LOG'', ''RPL$LOGHIST'', ''RPL$RELATIONS''' +
    ', ''RPL$REPLICATIONDB'', ''RPL$MANUAL_LOG'')';

  //Вытягивает имена таблиц и полей которые ссылаются
  //на заданную таблицу и у которых условие удаления не равно CASCADE
  cRefTableSQL =
    'SELECT ' +
    '  i_s.rdb$field_name as onfieldname, ' +
    '  i_s1.rdb$field_name as fieldname, ' +
    '  rc1.rdb$relation_name as relationname ' +
    'FROM ' +
    '  RDB$RELATION_CONSTRAINTS RC ' +
    '  JOIN rdb$ref_constraints ref_c ON ref_c.rdb$const_name_uq = rc.rdb$constraint_name and ' +
    '    ref_c.rdb$delete_rule <> ''CASCADE'' ' +
    '  JOIN rdb$relation_constraints rc1 ON rc1.rdb$constraint_name = ref_c.rdb$constraint_name AND ' +
    '    rc1.rdb$constraint_type = ''FOREIGN KEY'' ' +
    '  JOIN rdb$index_segments i_s ON i_s.rdb$index_name = rc.rdb$index_name ' +
    '  JOIN rdb$index_segments i_s1 On i_s1.rdb$index_name = rc1.rdb$index_name ' +
    'WHERE ' +
    '  RC.RDB$RELATION_NAME = :relationname ';

  cRefTableSQLNoCascade =
    'SELECT ' +
    '  i_s.rdb$field_name as onfieldname, ' +
    '  i_s1.rdb$field_name as fieldname, ' +
    '  rc1.rdb$relation_name as relationname ' +
    'FROM ' +
    '  RDB$RELATION_CONSTRAINTS RC ' +
    '  JOIN rdb$ref_constraints ref_c ON ref_c.rdb$const_name_uq = rc.rdb$constraint_name ' +
    '  JOIN rdb$relation_constraints rc1 ON rc1.rdb$constraint_name = ref_c.rdb$constraint_name AND ' +
    '    rc1.rdb$constraint_type = ''FOREIGN KEY'' ' +
    '  JOIN rdb$index_segments i_s ON i_s.rdb$index_name = rc.rdb$index_name ' +
    '  JOIN rdb$index_segments i_s1 On i_s1.rdb$index_name = rc1.rdb$index_name ' +
    'WHERE ' +
    '  RC.RDB$RELATION_NAME = :relationname ';

  cCheckFKForInsert =
    'SELECT %s FROM %s WHERE %s = %s';

  cLogForFKDeleted =
    'SELECT seqno FROM rpl$log WHERE relationkey = :rel AND repltype = ''D'' AND oldkey LIKE ';

type
  TErrorDecision = (edServer, edPriority, edTime{, edManual});
  TrplPriority = (prHighest, prHigh, prNormal, prLow, prLowest);
  TrplDBType = (dbtSource, dbtTarget);

const
  {Список констант типов действий}
  atInsert = 'I';
  atUpdate = 'U';
  atDelete = 'D';
  atEmpty = 'E';
  atReplication = 'R'; //запись была реплецирована из другой базы
const
  fnId = 'id';
  {Список констант полей таблиц хранящих инф. по репликации}
  fnSeqNo = 'seqno';
  fnRelationKey = 'relationkey';
  fnRelationName = 'relationname';
  fnRepltype = 'repltype';
  fnOldKey = 'oldkey';
  fnReplKey = 'replkey';
  fnNewKey = 'newkey';
  fnRelation = 'relation';
  fnRelationLName = 'relationlname';
  fnTriggerName = 'triggername';
  fnActionTime = 'actiontime';
  {Список констант полей таблицы RPL_LOGHIST}
  fnDBKey = 'dbkey';
  fnTrCommit = 'tr_commit';
  {Список констант полей таблицы gd_RUID}
  fnXId = 'xid';
  fnDBID = 'dbid';
  fnModified = 'modified';
  {Список констант полей таблицы RPL_REPLICATIONDB }
  fnPriority = 'priority';
  {Список констант полей таблицы RPL_KEYS }
  fnKeyName = 'keyname';
  {Список констант полей таблицы RPL_DBState }
  fnDBState = 'dbstate';
  fnReplicationId = 'replicationid';
  fnErrorDecision = 'errordecision';
  fnDBName = 'dbname';
  fnLastProcessReplKey = 'lastprocessreplkey';
  fnPrimeKeyType = 'primekeytype';
  fnGeneratorName = 'generatorname';
  fnKeyDivider = 'keydivider';
  fnDirection = 'direction';
  fnFieldName = 'fieldname';
  fnIsPrimeKey = 'isprimekey';
  fnRefRelationName = 'refrelationname';
  fnFieldType = 'fieldtype';
  fnRefFieldName = 'REFFIELDNAME';
  fnName = 'name';
  fnFieldSubType = 'FieldSubType';
  fnIndexname = 'Indexname';
  fnFK = 'fk';
  fnFKEtalon = 'fketalon';
  fnTriggers = 'triggers';
  fnPrepared = 'prepared';
  fnReplDate = 'repldate';
  fnLastProcessReplDate = 'lastprocessrepldate';
  fnTableName = 'TableName';
  fnConstraintName = 'ConstraintName';
  fnOnTableName = 'OnTableName';
  fnOnFieldName = 'OnFieldName';
  fnOnDelete = 'OnDelete';
  fnOnUpdate = 'OnUpdate';
  fnNewValue = 'NewValue';
  fnOldValue = 'oldvalue';
  fnFieldType_Calc = 'Fieldtype_calc';
  fnFieldSubType_Calc = 'Fieldsubtype_calc';
  fnDomaneNullFlag = 'Domanenullflag';
  fnFieldNullFlag = 'Fieldnullflag';
  fnNotNull = 'Notnull';
  fnComputedSource_Calc = 'Computedsource_calc';
  fnComputedSource = 'Computedsource';
  fnFieldDefaultSource = 'Fielddefaultsource';
  fnDefaultSource_Calc = 'Defaultsource_calc';
  fnDomaneDefaultSource = 'Domanedefaultsource';
  fnDescription_Calc = 'Description_calc';
  fnDescription = 'Description';
  fnPk = 'pk';
  fnDomaneName = 'DomaneName';
  fnTR_Commit = 'tr_commit';
  fnCortege = 'Cortege';
  fnErrorCode = 'ErrorCode';
  fnErrorDescription = 'ErrorDescription';
const
  RELATION_LABEL = 'RELb';
  FIELD_NAME_LABEL = 'FNLb';
  FIELD_DATA_LABEL = 'FDLb';
  ROLLBACK = 'RLBK';
  REPL_LOG_LIST = 'RLLT';
  REPL_EVENT = 'RLEV';
  REPL_KEY = 'RLKY';
  REPL_TUNE = 'TUNE';

//Типы полей
const
  tfInteger = 8;
  tfInt64 = 16;
  tfSmallInt = 7;
  tfQuard = 9;

  tfChar = 14;
  tfCString = 40;
  tfVarChar = 37;

  tfD_Float = 11;
  tfDouble = 27;
  tfFloat = 10;


  tfDate = 12;
  tfTime = 13;
  tfTimeStamp = 35;

  tfBlob = 261;

//Подтипы полей
  istFieldType = 0;
  istNumeric = 1;
  istDecimal = 2;

  bstText = 1;
  bstBLR = 2;

//Имена ключей в реестре
const
  RegisterInfo = 'RegisterInfo';

const
  SELECT_FOREIGN_KEYS_BY_RELATIONKEY = 'SELECT ' +
    '  rplr.id AS ID, ' +
    '  RC.RDB$RELATION_NAME AS RELATIONNAME, ' +
    '  INDSEG.RDB$FIELD_NAME AS FIELDNAME, ' +
    '  rplr2.id AS REFID, ' +
    '  RC2.RDB$RELATION_NAME AS REFRELATIONNAME, ' +
    '  INDSEG2.RDB$FIELD_NAME AS REFFIELDNAME ' +
    'FROM ' +
    '  rpl$relations rplr ' +
    '  JOIN RDB$RELATION_CONSTRAINTS RC ON RC.RDB$RELATION_NAME = rplr.relation ' +
    '  JOIN RDB$INDEX_SEGMENTS INDSEG ON RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME ' +
    '  JOIN RDB$REF_CONSTRAINTS REFC ON REFC.RDB$CONSTRAINT_NAME = RC.RDB$CONSTRAINT_NAME, ' +
    '  RDB$RELATION_CONSTRAINTS RC2 ' +
    '  JOIN RDB$INDEX_SEGMENTS INDSEG2  ON RC2.RDB$INDEX_NAME = INDSEG2.RDB$INDEX_NAME ' +
    '  JOIN rpl$relations rplr2 ON RC2.RDB$RELATION_NAME = rplr2.relation ' +
    'WHERE ' +
    '  RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ  AND ' +
    '  INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION AND ' +
    '  rplr.id = :relationkey';

  SELECT_FOREIGN_KEYS_BY_RELATIONNAME =
    'SELECT'#13#10 +
    '  RC.RDB$RELATION_NAME AS RELATIONNAME,'#13#10 +
    '  INDSEG.RDB$FIELD_NAME AS FIELDNAME,'#13#10 +
    '  RC2.RDB$RELATION_NAME AS REFRELATIONNAME,'#13#10 +
    '  INDSEG2.RDB$FIELD_NAME AS REFFIELDNAME'#13#10 +
    'FROM'#13#10 +
    '  RDB$RELATION_CONSTRAINTS RC'#13#10 +
    '  JOIN RDB$INDEX_SEGMENTS INDSEG ON RC.RDB$INDEX_NAME = INDSEG.RDB$INDEX_NAME'#13#10 +
    '  LEFT JOIN RDB$REF_CONSTRAINTS REFC ON REFC.RDB$CONSTRAINT_NAME = RC.RDB$CONSTRAINT_NAME,'#13#10 +
    '  RDB$RELATION_CONSTRAINTS RC2'#13#10 +
    '  JOIN RDB$INDEX_SEGMENTS INDSEG2  ON RC2.RDB$INDEX_NAME = INDSEG2.RDB$INDEX_NAME'#13#10 +
    'WHERE'#13#10 +
    '  RC.RDB$RELATION_NAME = :relationname AND'#13#10 +
    '  RC2.RDB$CONSTRAINT_NAME = REFC.RDB$CONST_NAME_UQ  AND'#13#10 +
    '  INDSEG.RDB$FIELD_POSITION = INDSEG2.RDB$FIELD_POSITION';

  SELECT_COMPUTED_FIED = 'SELECT rf.rdb$field_name  AS fieldname ' +
    'FROM rdb$relation_fields rf JOIN rdb$fields f ON rf.rdb$field_source = f.rdb$field_name ' +
    'WHERE rf.rdb$relation_name = :relationname AND ' +
    'f.rdb$computed_source is NOT NULL ';

  SELECT_RELATION_FIELDS = 'SELECT rf.rdb$field_name as fieldname, rf.rdb$field_position as fieldposition,' +
    ' rf.rdb$description as description, rf.rdb$default_value as defaultvalue, rf.rdb$system_flag as systemflag, ' +
    ' f.rdb$null_flag as domanenullflag, rf.rdb$default_source as fielddefaultsource, ' +
    ' f.rdb$computed_source as computedsource, f.rdb$field_length as fieldlength, ' +
    ' f.rdb$field_name as domanename,  f.rdb$field_length as fieldlength, ' +
    ' f.rdb$field_precision as fieldprecision, f.rdb$field_type as fieldtype, ' +
    ' f.rdb$field_sub_type as fieldsubtype, cs.rdb$character_set_name as charset, ' +
    ' c.rdb$collation_name as collatename, rf.rdb$null_flag as fieldnullflag, ' +
    ' f.rdb$default_source as domanedefaultsource' +
    ' FROM rdb$relation_fields rf LEFT JOIN rdb$fields f ON rf.rdb$field_source = ' +
    ' f.rdb$field_name LEFT JOIN rdb$character_sets cs ON f.rdb$character_set_id = ' +
    ' cs.rdb$character_set_id LEFT JOIN rdb$collations c ON c.rdb$collation_id = ' +
    ' f.rdb$collation_id and c.rdb$character_set_id = f.rdb$character_set_id ' +
    ' WHERE rf.rdb$relation_name = :relationname ORDER BY rf.rdb$field_position';

  SELECT_UNIQUE_INDICES =
    'SELECT'#13#10 +
    '   i_s.rdb$field_name AS name,'#13#10 +
    '   i.rdb$unique_flag AS u,'#13#10 +
    '   i.rdb$index_name AS indexname '#13#10 +
    'FROM'#13#10 +
    '  rdb$indices i'#13#10 +
    '  LEFT JOIN rdb$index_segments i_s ON i_s.rdb$index_name = i.rdb$index_name'#13#10 +
    'WHERE'#13#10 +
    '  i.rdb$relation_name = :relationname AND'#13#10 +
    '  i.rdb$unique_flag = 1';

  SELECT_DBSTATE_FKFIELD =
    'SELECT * FROM RDB$RELATION_FIELDS ' +
    'WHERE RDB$RELATION_NAME = ''RPL$DBSTATE'' AND RDB$FIELD_NAME = ''FKETALON''';

  SELECT_DBSTATE_DIRECTION_FIELD =
    'SELECT * FROM RDB$RELATION_FIELDS ' +
    'WHERE RDB$RELATION_NAME = ''RPL$DBSTATE'' AND RDB$FIELD_NAME = ''DIRECTION''';

  ADD_DBSTATE_DIRECTION_FIELD =
    'ALTER TABLE RPL$DBSTATE ADD DIRECTION DRPLINTEGER_NOT_NULL DEFAULT 2';

//Константы индексов иконок
const
  ICN_RELATION = 210;
  ICN_TRIGGER = 172;
  ICN_TRIGGER_CUSTOM = 122;
  ICN_FIELDS = 0;
  ICN_GENERATOR = 79;
  ICN_PRIMEKEY = 231;
  ICN_FKEY = 243;
  ICN_KEY = 155;
  ICN_ALTERKEY = 145;
  ICN_DATA = 245;
  ICN_ATTENTION = 244;

  OVR_NONE = - 1;
  OVR_ATTENTION = 0;

//Коды ошибок при подготовке к репликации
  ERR_CODE_NOT_INIT = -1;
  ERR_CODE_OK = 0;
  ERR_CODE_NOONE_FIELD_SELECTED = 1;
  ERR_CODE_PK_NOT_SELECT = 2;
  ERR_CODE_NOTNULL_NOT_SELECTED = 3;
  ERR_CODE_PK_NOT_MARK = 4;
  ERR_CODE_GENERATOR_NAME_MISSING = 5;

// Количество рекурсивных вызовов при удалении записи и всех зависящих от нее
  MAX_DELETE_REFERENCE_COUNT = 100000;

  RootPath = 'Software\Golden Software\IBReplicator';
  cLoadPath = 'LoadPathForRPLFiles';
  cSavePath = 'SavePathForRPLFiles';
  cLastConnect = 'LastConnect';

  {$IFDEF GEDEMIN}
  GedeminEdition = ' [Gedemin edition]';
  ExcludedRelations =
    ';AC_ACCT_CONFIG;AC_ACCVALUE;AC_AUTOENTRYAC_AUTOTRRECORD;AC_ENTRY;AC_GENERALLEDGER;' +
    'AC_G_LEDGERACCOUNT;AC_LEDGER_ACCOUNTS;AC_LEDGER_ENTRIES;AC_QUANTITY;AC_RECORD;' +
    'AC_TRANSACTION;AC_TRRECORD;EVT_MACROSGROUP;EVT_MACROSLIST;EVT_OBJECT;EVT_OBJECTEVENT;' +
    'FIN_VERSIONINFO;GD_COMPANYSTORAGE;GD_GLOBALSTORAGE;GD_USERSTORAGE;' +
    'AT_EXCEPTIONS;AT_FIELDS;AT_INDICES;AT_PROCEDURES;AT_RELATIONS;AT_RELATION_FIELDS;' +
    'AT_SETTING;AT_SETTINGPOS;AT_SETTING_STORAGE;AT_TRANSACTION;AT_TRIGGERS;';
  {$ENDIF}

implementation

end.
