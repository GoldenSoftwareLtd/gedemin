unit rpl_ResourceString_unit;

interface
resourcestring
  //����� ��������� �� ���������
  {$IFNDEF RP_ENG}
    InvalidDataBaseName = '�������� ��� ����� ���� ������ ''%s''';
    ReplicationSchemaNotFound =  '���� ������ �� ������������ � ����������';
    DataBaseIsNotConnected = '���� ������ �� ����������';
    DataBaseTestConnectSucces = '�������� �����������';
    InvalidDataBaseKey = //'�������� ���� ���� ������';
        '��������� ������ �� ����� ����� ���������� (�������� ���� ����������).'#13#10 +
        #13#10 +
        '�������� ��������� ������� :'#13#10 +
        #13#10 +
        '1. �� ���������� ������� ���� ���� ������ ("���������") � �������� ������ ����� ���� ������ ("���������").'#13#10 +
        '2. �� �������� ���� ��������������� ��� ������ �������  �� � ����� ����� ������ (��� ������� � ����� ������ ������� ������ ���� ����������).'#13#10 +
        '3. ���� �������� ����� ������ �������. ��������� � ��������������� ������ �������.';

    DataBaseNotAssigned = '���� ������ �� ���������';
    InvalidFieldIndex = '�������� ������ ����';
    InvalidParamIndex = '�������� ������ ���������';
    RelationNotAssigned = '������� �� ���������';
    InvalidRelationKey = '��������� ���� �������';
    InvalidProtocol = '�������������� ��������';
    InvalidFieldName = '������������ ��� ����';
    InvalidRelationName = '������������ ��� ������� ''%s''';
    CantReturnBlobValue = '���������� ������� �������� ���� ���� BLOB';
    CantSaveRigistryInfo = '���������� ��������� ���������� � �����������';
    CantLoadRegistryInfo = '���������� ��������� ���������� � �����������';
    InvalidStreamData = '����� �������� ��������� ������';
    InvalidSchema = //'��������� ����� ����������';
        '��������� ������ �� ����� ����� ���������� (�������� ���� ����������).'#13#10 +
        #13#10 +
        '�������� ��������� ������� :'#13#10 +
        #13#10 +
        '1. �� ���������� ������� ���� ���� ������ ("���������") � �������� ������ ����� ���� ������ ("���������").'#13#10 +
        '2. �� �������� ���� ��������������� ��� ������ �������  �� � ����� ����� ������ (��� ������� � ����� ������ ������� ������ ���� ����������).'#13#10 +
        '3. ���� �������� ����� ������ �������. ��������� � ��������������� ������ �������.';
    InvalidStreamversion = '��������� ������ ������';
    MissingFiles = '��������� %d ������ �������';
    OneNotConfirmedTransaction = //'� ���� ������ ������� ���� �� �������������� �������� ������.';
      '��������� ������ �� ����� ����� ���������� (�� �������������� �������� ������).'#13#10 +
      #13#10 +
      '�������� ��������� ������� :'#13#10 +
      #13#10 +
      '1. �� ��������� ������� ���� ������� ����������� �� ���� ������ ("���������") ' +
      '��� ��������� ������ ����� ������������� ���� �� "��������" �����. ' +
      '��������� � ��������������� ������ �������. ' +
      '������ �����, �� ������������ � ��������������� ������ ������� ��� ���������� ����� ����������������� ������ ��� ���������� ����� :'#13#10 +
      '	1) ���������� ������ �������� ������;'#13#10 +
      '	2) ���������� �������� � "���������" ����;'#13#10 +
      '	3) ������������ ����� ���� ������ � �������� ��� �� "��������"'#13#10 +
      '2. � �������� ������-�������� ��������� ������ ����� ������ �������. ���������� ������� ������������������ ������. ��� ����������� �������� ��������� � ��������������� ������ �������.';

    ManyNotConfirmedTransaction = //'� ���� ������ %d �� �������������� ������� ������.';
      '��������� ������ �� ����� ����� ���������� (%d �� �������������� ������� ������).'#13#10 +
      #13#10 +
      '�������� ��������� ������� :'#13#10 +
      #13#10 +
      '1. �� ��������� ������� ���� ������� ����������� �� ���� ������ ("���������") ��� ��������� ' +
      '������ ����� ������������� ���� �� "��������" �����. ��������� � ��������������� ������ �������. ' +
      '������ �����, �� ������������ � ��������������� ������ ������� ��� ���������� ����� ����������������� ������ ��� ���������� ����� :'#13#10 +
      '	1) ���������� ������ �������� ������;'#13#10 +
      '	2) ���������� �������� � "���������" ����;'#13#10 +
      '	3) ������������ ����� ���� ������ � �������� ��� �� "��������"'#13#10 +
      '2. � �������� ������-�������� ��������� ������ ����� ������ �������. ���������� ������� ������������������ ������. ��� ����������� �������� ��������� � ��������������� ������ �������.';

    FieldNotFound = '���� "%s" �� ������� � ������� "%s"'; //???
    SeqnoNotFound = 'Seqno not found'; //????
    Question_On_Delete_Base =
      '�� ������������� ������ ������� ��������� ���� ��'#13#10 +
      '����� ����������?';
    QuestionBackupDatabase =
      '������ ������� �������� ������ ���� ������?';

    AlreadyReplicated = //'���� ��� �������������';
      '��������� ������ �� ����� ����� ���������� (���� ��� �������������).'#13#10 +
      #13#10 +
      '�������� ��������� ������� :'#13#10 +
      #13#10 +
      '1. �� ��������� ������� ���� ������� ��� ��� ����� ���� ���������.';

    EnterServerName = '������� ��� �������';
    EnterProtocol = '�������� ��������';
    EnterDataBaseFileName = '������� ��� ���� ������';
    EnterUserName = '������� ��� ������������';
    EnterPassword = '������� ������';
    EnterCharset = '������� ���������';
    ConnectionError = '������ ���������� � ����� ������';
    ConnectionTest = '�������� �����������';

    BeginExport = '����� ������� �������� ������...';
    BeginExportConfirm = '�������� ����� �������������...';
    PrepareLog = '���������� ������� ���������';
    PrepareGDRUID = '���������� ������� GD_RUID';
    DeletedFromGDRUID = '�� ������� GD_RUID ������� %d �������';
    PreparedForExport = '������������ %d ������� ��� ��������';
    NRecordPassed = '��������� %d �������';
    ReplicationStarting = '����� ������� ���������� ...';

    CountChanges = '%d ��������� � ���� ������';
    FileExists =  '���� "%s" ��� ����������.'#13#10 +
            '�� ������ ��� ����������?';

    OpenDBFilter = '���� ������|*.gdb;*.fdb|��� �����|*.*';
    ReplFileFilter = '����� �������|*.rpl|��� �����|*.*';
    SQLFileFilter = 'SQL-������|*.sql|��������� �����|*.txt|All files|*.*';
    ReplSchemaFileFilter = '����� ���� �������|*.rpd|��� �����|*.*';
    ReplTriggersFileFilter = '��������� �����|*.txt|��� �����|*.*';
    NotEnoughDiskSpace =
      '�� ����� ������������ ���������� �����.'#13#10 +
       '������� ������ ����.';
    DoYouWantExstractDBFromRepl = '�� ������������� ������ ������� %s �� ����� ����������?';
    CannotDetermineFilePath = 'Can`t determine path to source data base.';//????
    TerminatedByUser = '�������� �������������';//????
    EnterReplicationFileName = '������� ��� ����� �������';
    EnterDBName = '������� ��� ���� ������';

    ServerList = '\ServerList';

    DropTriggers = '�������� ���������';
    DropTriggersMainDB = '�������� ��������� �� ������� ���� ������';
    DropOldTriggers = '�������� ������ ���������';
    CreateTriggers = '�������� ���������';

    DropTables = '�������� ������';
    DropOldTables = '�������� ������ ������';
    CreateTables = '�������� ������';

    DropDomanes = '�������� �������';
    DropOldDomanes = '�������� ������ �������';
    CreateDomanes = '�������� �������';

    DropGenerators = '�������� �����������';
    DropOldGenerators = '�������� ������ �����������';
    CreateGenerators = '�������� �����������';

    CreateRuid = '�������� ������ ��� ������������ �������';

    MakeCopy = '�������� ����� ''%s''';
    FillTables = '���������� ������ ����������';
    Activization = '�����������';
    Deactivization = '�������������';
    CreateRole = '�������� ���� ������������';
    DropRole = '�������� ���� ������������';
    UpdateReplDBList = '���������� ������ ������������� ���';

    RelationFields = '����';
    RelationTriggers = '��������';
    RelationGenerator = '���������: ';
    RelationGeneratorCant = '��������� ���� �����������';
    SetConformity = 'Set conformity';//????

    RelationTriggerBI = '����� ��������';
    RelationTriggerBU = '����� ����������';
    RelationTriggerBD = '����� ���������';
    RelationTriggerAI = '����� �������';
    RelationTriggerAU = '����� ���������';
    RelationTriggerAD = '����� ��������';

    ErrorOnAction = '������ ��� %s � ������� %s';
    rtInsert = '������� ������';
    rtUpdate = '���������� ������';
    rtDelete = '�������� ������';

    //��������� �� ������ � ���������� � ����������
    ERR_OK = '������ ���.';
    ERR_NOONE_FIELD_SELECTED =
      '��������� �� ������ ����.'#13#10 +
      '�� ������ �������� ������ ���� ���� � ����� ����������'#13#10 +
      '��� ������� ������� �� ����� ����������.';

    ERR_PK_NOT_SELECT =
      '���������� ������� ���� �� ���������� �������� ��� ������ ������';
    ERR_PK_NOT_MARK =
      '���������� ������� ���� �� ���������� �������� ��� ������ ������';
    ERR_NOTNULL_NOT_SELECTED =
      '� ����� ���������� ������ ������� ��� NOT NULL ���� ��������� �������.';
    ERR_GENERATOR_DEF_NOT_SELECT = '���������� ������� ��������� �� ���������.';
    ERR_GENERATOR_DB_NOT_SELECT = '���������� ������� ���������.';
    ERR_GENERATOR_NAME_MISSING =
      '��������� ��� ����������';
    ERR_THERE_ARE_ERRORS = '������� ������';

    ERR_MAKE_DB_COPY = '�� ������� ������� ����� ���� ������.'#13#10 +
      '�������� ��� ������� � ����� � ������� ���������� ���� ���� ������.';

    MSG_SET_ALT_KEY_AS_PRIME_KEY =
      '������� %s �������� ���� �������������� ����.'#13#10 +
      '������������� ������� ��� ��� ������ �������.'#13#10 +
      '�� ������ �����?';

    MSG_SELECT_REFERENCE_FIELD =
      '���� %s � ������� %s ���������'#13#10 +
      '�� ���� %s. ���� %s ��� ������� %s �� ������'#13#10 +
      '� ����� ����������. �� ������ �������� ���� � �������'#13#10 +
      '� ����� ����������?';

    MSG_DESELECT_REFERENCE_FIELD =
      '������� ����, ����������� �� ���� %s.'#13#10 +
      '�� ������ ��������� ��� ����'#13#10 +
      '�� ����� ����������?';

    MSG_SELECT_REFERENCE_FIELDS =
      '������� ������� ������ �� ������� %s.'#13#10 +
      '�� ������ ������� �� ����� ���������� ���� �'#13#10 +
      '�������, ����������� �� ������ ����?';

    MSG_INFORMATION = '����������';
    MSG_WARNING = '��������������';
    MSG_QUESTION = '������';

    dbs_Main = 'Main';
    dbs_Secondary = '��������������';
    dbp_Highest = '���������';
    dbp_High = '�������';
    dbp_Normal = '����������';
    dbp_Low = '������';
    dbp_Lowest = '��������';

    cap_DBState = '������';
    cap_DBPriority = '���������';
    cap_DBName = '���';

  //����� ����� ���������� � ����������
    MSG_REPORT_READING_DBINFO = '������ ���������� � ���� ������...';
    MSG_REPORT_DATE = '����: %s';
    MSG_REPORT_LAST_PROCESS_REPL_DATE = '  ���� ��������� ��������� �������: %s';
    MSG_REPORT_LAST_REPL_DATE = '  ���� ��������� �������� ������: %s';
    MSG_REPORT_REPLTYPE = '��� ����� ����������: %s';
    MSG_REPORT_ERROR_DECISION = '���������� ����������� ��������: %s';
    MSG_REPORT_REPL_KEY = '���� ����� ����������: %d';
    MSG_REPORT_DB = '���� ������:';
    MSG_REPORT_DB_ALIAS = '  ��� ����: %s';
    MSG_REPORT_DB_FILE_NAME = '  ��� �����: %s';
    MSG_REPORT_DB_STATE = '  ������: %s';
    MSG_REPORT_DB_PRIORITY = '  ���������: %s';
    MSG_REPORT_DB_KEY = '  ���� ���� ������: %d';
    MSG_REPORT_NOT_COMMIT = '  ���������� ���������������� ������� ������: %d';
    MSG_REPORT_REGISTRED_CHANGES_COUNT = '  ���������� ���������: %d';
    MSG_REPORT_REPL_COUNT = '  ���������� ������� ������: %d';
    MSG_REPORT_PROCESS_REPL_COUNT = '  ���������� ������������ ������: %d';
    MSG_REPORT_CONFLICT_COUNT = '  ���������� ������������� ����������: %d';
    MSG_REPORT_DUAL = '���������������';
    MSG_REPORT_FROMSERVER = '��������������� �� �������';
    MSG_REPORT_TOSERVER = '��������������� � �������';
    MSG_REPORT_CURRENT_DB_ALIAS = '������� ���� ������: %s';
    MSG_REPORT_TRANSFER_DATA_TO = '�������� �������� ������:';

    MSG_REPORT_ERR_DECISION_SERVER = '��������� �� ���� ����� ���������';
    MSG_REPORT_ERR_DECISION_PRIORITY = '�� ����������';
    MSG_REPORT_ERR_DECISION_TIME = '����� ��������� ����� ���������';

    MSG_METADATA_DELETE_SUCCES = '��� ���������� ���������� ���� ������� �������.';//????
    { TODO : �������� ������� ��������� }
    MSG_METADATA_DELETE_ERROR = '��� �������� ���������� �������� ������:';
    MSG_CREATE_METADATA_ERROR = '�� ����� �������� ���������� �������� ������:';

  {    '���� ���������� � ����������: %s'#13#10 +
      '��� ����� ����������: %s'#13#10 +
      '������ ���������� ���������� ��������: %s'#13#10 +
      '���� ����� ����������: %d'#13#10 +
      '���� ������, ����������� � ����������:'#13#10 +
      '%s'#13#10;}

  //��������� �������� ������ ���������� �������
    MSG_REPORT_CAPTION_SUCCES = '�������� ����������';
    MSG_REPORT_CAPTION_ERROR = '������';

    MSG_REPORT_EXPORT_SUCCES = '�������� �������� ������.';
    MSG_REPORT_EXPORT_UNSUCCES = '�� ����� �������� ������ �������� ������.';
    MSG_REPORT_EXPORT_CONFIRM_SUCCES = '������ ���� ������������� �������� ������.';
    MSG_REPORT_EXPORT_CONFIRM_UNSUCCES = '�� ����� �������� ����� ������������� �������� ������ �������� ������.';

    MSG_REPORT_IMPORT_SUCCES = '�������� ��������� ������.';
    MSG_REPORT_IMPORT_UNSUCCES = '�� ����� ��������� ����� ������� �������� ������.';
    MSG_REPORT_IMPORT_CONFIRM_SUCCES = '�������� ������ ������������.';
    MSG_REPORT_IMPORT_CONFIRM_UNSUCCES = '�� ����� ��������� ����� ������������� �������� ������.';

    MSG_DROP_METADATA_CAPTION = '�������� ����������.';
    MSG_WANT_DROP_METADATA = '�� ������������� ������ ������� ���'#13#10 +
     '���������� ����������?';
    MSG_WANT_EDIT_METADATA = '�� ������������� ������ ��������'#13#10 +
      '����� ����������?';
    MSG_EXPORT_DATA_CAPTION = '�������� ������.';
    MSG_IMPORT_DATA_CAPTION = '��������� ������.';
    MSG_ROLLBACK_TRANSACTION_SUCCES = '������� ������ �������� ������';
    MSG_ROLLBACK_TRANSACTION_ERROR = '�� ����� ������ �������� ������ �������� ������';
    MSG_DROP_FK = '���������� ������� ������ %s �� ������� %s';
    MSG_DROPING_FK = '�������� ������� ������...';
    MSG_RESTORE_FKs = '�������������� ������� ������...';
    MSG_RESTORE_FK = '�������������� ������� ������ %s �� ������� %s';
    MSG_FIND_NOT_RESTORE_FK = '����������� %d ����������������� ������� ������. ��������������...';
    MSG_FOUND_NOT_RESTORED_TRIGGERS = '���������� %d ����������������� ���������. ��������������...';
    MSG_INACTIVATE_TRIGGERS = '���������� ���������...';
    MSG_ACTIVATE_TRIGGERS = '����������� ���������...';
    MSG_RESTOREDB_CAPTION = '�������������� ���� ������';
    MSG_RING_FKS_UPDATE = '���������� ����� ������� ������';
    MSG_THERE_ARE_CONTENTION = '������� %d ������������� ����������� ��������';
    MSG_CONFLICT_RESOLUTION = '����� ������� ���������� ����������� ��������';
    MSG_LOG_RESTORING_METADATA = '��� �������������� ����������';
    MSG_LOG_REPLICATION = '��� ����������';
    MSG_START_REPL_FILE = '������ ��������� �����: %s';
    MSG_END_REPL_FILE = '��������� ��������� �����: %s';
    MSG_START_EXPORT_DB = '���� ������: %s';
    MSG_END_EXPORT_DB = '������� ���� �������: %s'#13#10;
    MSG_WANT_RESET_TRIGGER = '�� ������������� ������ �������� ��� ��������� � ���� ��������?';
    MSG_SET_TRIGGER = '��������� ��������� � ���� ��������?';
    MSG_RESTRUCT = '����������� ������������ ��������';
    MSG_MAKE_REST = '�������������� ��������';

    ERR_SHUTDOWN = '������ ��� �������� ���� ������ � �������������������� �����.'#13#10;
    ERR_BRINGONLINE = '������ ��� �������� ���� ������ � ���������� �����.'#13#10;
    ERR_CREATE_TRIGGER = '������ ��� �������� �������� %s:'#13#10;
    ERR_DROP_TRIGGER = '������ ��� �������� �������� %s:'#13#10;
    ERR_CREATE_TABLE = '������ ��� �������� ������� %s:'#13#10;
    ERR_CREATE_GRAND = 'Error on create grand'#13#10;//????
    ERR_DROP_TABLE = '������ ��� �������� ������� %s:'#13#10;
    ERR_CREATE_DOMANE = '������ ��� �������� ������ %s:'#13#10;
    ERR_DROP_DOMANE = '������ ��� �������� ������ %s:'#13#10;
    ERR_CREATE_EXCEPTION = '������ ��� �������� ���������� %s:'#13#10;
    ERR_DROP_EXCEPTION = '������ ��� �������� ���������� %s:'#13#10;
    ERR_CREATE_GENERATOR = '������ ��� �������� ���������� %s:'#13#10;
    ERR_DROP_GENERATOR = '������ ��� �������� ���������� %s:'#13#10;
    ERR_CREATE_ROLE = '������ ��� �������� ���� ������������ %s:'#13#10;
    ERR_DROP_ROLE = '������ ��� �������� ���� ������������ %s:'#13#10;
    ERR_ROLLBACK_TRANSACTION = '�������� %d  ������� ������';
    ERR_DROP_FK = '������ ��� �������� �������� ����� %s � ������� %s: %s';
    ERR_RESTORE_FK = '������ ��� ������������� �������� ����� %s �� ������� %s: %s';
    ERR_INACTIVATE_TRIGGERS = '������ ��� ���������� ���������: %s';
    ERR_ACTIVATE_TRIGGERS = '������ ��� ����������� ��������: %s';
    ERR_CANT_ROLLBACK_TRANSACTION = '������ ��� ������ �������� ������: %s';
    ERR_ON_READING_FILE = '������ ��� ������ ����� %s';

    CAPTION_DEPEND_ON = ' �������, �� ������� ������� %s';
    CAPTION_DEPENDS_ON = '�������, ��������� �� %s';

    ALL_CONFLICT_RESOLUTION = '��� ��������� ���������';
    CANT_REPL = '���������� �� ��������.';
    MSG_STREAM_DO_NOT_INIT = '����� �����������������';
    MSG_FILE_NOT_FOUND = '���� ''%s'' �� ������';

    MSG_UPDATE_INSERT_RECORDS = ' ������� � ��������� �������';
    MSG_DELETE_RECORDS = ' �������� �������';

    ERR_CANT_RESTORE_DB = '������ ��� ������� �������������� ���� ������.'#13#10 +
                          '  ���������� ��������� ��������� �������������� ������'#13#10' (IBRRestoreFK.exe).';
    ERR_CANT_ADD_DIRECTION_FIELD = '������ ��� ���������� ���������� � ����������� ����������.';


    CAPTION_DBALIAS_EXPORT = '���� �� ������� ���������� ������:';
    CAPTION_DBALIASES_EXPORT = '���� �� ������� ���������� ������:';
    CAPTION_DBALIAS_CONFIRM = '���� ��� ������� ��������� ���� �������������';
    CAPTION_DBALIASES_CONFIRM = '���� ��� ������� ��������� ����� �������������';
    CAPTION_FILENAME_EXPORT = '��� ����� �������:';
    CAPTION_FILENAME_EXPORT_CONFIRM = '��� ����� �������������:';

    CAPTION_FILENAME_IMPORT = '��� ����� �������:';
    CAPTION_FILENAMES_IMPORT = '����� ������ �������:';
    CAPTION_FILENAME_IMPORT_CONFIRM = '��� ����� �������������:';
    CAPTION_FILENAMES_IMPORT_CONFIRM = '����� ������ �������������:';


    MSG_RELATION = '������� %s';

    MSG_CAPTION = '�� ����������';

    {$ELSE}

    InvalidDataBaseName = 'Invalid data base name ''%s''';
    ReplicationSchemaNotFound =  'Database is not prepared for replication';
    DataBaseIsNotConnected = 'Database is not connected';
    DataBaseTestConnectSucces = 'Succeseful connection test';
    InvalidDataBaseKey = 'Invalid database key';
    DataBaseNotAssigned = 'Database not assigned';
    InvalidFieldIndex = 'Invalid field index';
    InvalidParamIndex = 'Invalid param index';
    RelationNotAssigned = 'Relation not assigned';
    InvalidRelationKey = 'Invalid relation key';
    InvalidProtocol = 'Invalid protocol';
    SeqnoNotFound = 'Seqno not found';
    InvalidFieldName = 'Invalid field name';
    InvalidRelationName = 'Invalid relation name ''%s''';
    CantReturnBlobValue = 'Can`t return blob`s value';
    CantSaveRigistryInfo = 'Can`t save registry info';
    CantLoadRegistryInfo = 'Can`t load registry info';
    InvalidStreamData = 'Invalid stream data';
    InvalidSchema = 'Invalid schema';
    InvalidStreamversion = 'Invalid stream version';
    MissingFiles = 'Missing %d files';
    OneNotConfirmedTransaction = 'DataBase have one not confirmed transaction.'#13#10 +
      'Server rollback her';
    ManyNotConfirmedTransaction = 'DataBase have %d not confirmed transactions.'#13#10 +
      'Server rollback them';
    FieldNotFound = 'Field "%s" not found in table "%s"';
    Question_On_Delete_Base =
      'Do you realy want to delete selected base from'#13#10 +
      'replication scheme?';
    QuestionBackupDatabase =
      'Do you want make an archive copy of database?';

    AlreadyReplicated = 'Already replicated';

    EnterServerName = 'Enter server name';
    EnterProtocol = 'Enter protocol';
    EnterDataBaseFileName = 'Enter database file name';
    EnterUserName = 'Enter user name';
    EnterPassword = 'Enter password';
    EnterCharset = 'Enter charset';
    ConnectionError = 'Connection error';
    ConnectionTest = 'Connection test';

    BeginExport = 'Begin export data...';
    PrepareLog = 'Prepare log';
    PrepareGDRUID = 'Prepare table GD_RUID';
    PreparedForExport = 'Prepared for export %d records';
    NRecordPassed = '%d record passed';
    ReplicationStarting = 'Replication starting ...';

  {  CompressingFile = 'Compressing output file ...';
    CopressSucces = 'Succeseful. Output file: %s';
    CopressError = 'Compresiing error.';}

    CountChanges = '%d changes in data base';
    FileExists = 'File ''%s'' alredy exist.'#13#10 +
      'Do you want replace him?';

    OpenDBFilter = 'Interbase data base|*.gdb;*.fdb|All files|*.*';
    ReplFileFilter = 'RPL files|*.rpl|Compressed RPL files|*.z|All files|*.*';
    SQLFileFilter = 'SQL-script|*.sql|Text files|*.txt|All files|*.*';
    ReplSchemaFileFilter = 'RPD files|*.rpd|All files|*.*';
    NotEnoughDiskSpace =
      'Do not enough disk space.'#13#10 +
      'Please select other file path.';
    DoYouWantExstractDBFromRepl = 'Do you want extract %s from replication scheme?';
    CannotDetermineFilePath = 'Can`t determine path to source data base.';
    TerminatedByUser = 'Terminated by user';
    EnterReplicationFileName = 'Enter replication`s file name';
    EnterDBName = 'Enter data base name';

    ServerList = '\ServerList';

    DropTriggers = 'Drop triggers';
    DropTriggersMainDB = 'Drop triggers from main database';
    DropOldTriggers = 'Drop old triggers';
    CreateTriggers = 'Create triggers';

    DropTables = 'Drop tables';
    DropOldTables = 'Drop old tables';
    CreateTables = 'Create tables';

    DropDomanes = 'Drop domains';
    DropOldDomanes = 'Drop old domains';
    CreateDomanes = 'Create domains';

    DropGenerators = 'Drop generators';
    DropOldGenerators = 'Drop old generators';
    CreateGenerators = 'Create generators';

    CreateRuid = 'Create RUID for existing records';

    MakeCopy = 'Make copy ''%s''';
    FillTables = 'Fill replication tables';
    Activization = 'Activization';
    Deactivization = 'Deactivization';
    CreateRole = 'Create role';
    DropRole = 'Drop role';
    UpdateReplDBList = 'Update replication DB list';

    RelationFields = 'Fields';
    RelationTriggers = 'Triggers';
    RelationGenerator = 'Genarator: ';
    SetConformity = 'Set conformity';

    RelationTriggerBI = 'Before insert';
    RelationTriggerBU = 'Before update';
    RelationTriggerBD = 'Before delete';
    RelationTriggerAI = 'After insert';
    RelationTriggerAU = 'After update';
    RelationTriggerAD = 'After delete';

    ErrorOnAction = 'Error on %s in table %s';
    rtInsert = 'insert record';
    rtUpdate = 'update record';
    rtDelete = 'delete record';

    //��������� �� ������ � ���������� � ����������
    ERR_OK = 'No one error was found.';
    ERR_NOONE_FIELD_SELECTED =
      'No one field selected.'#13#10 +
      'You must select field'#13#10 +
      'or deselect relation.';
    ERR_PK_NOT_SELECT =
      'No one PRIMARY KEY field selected';
    ERR_PK_NOT_MARK =
      'No one field mark as PRIMARY KEY'#13#10 +
      'Please mark one or more UNIQUE fields as'#13#10 +
      'PRIMARY KEY and select it';
    ERR_NOTNULL_NOT_SELECTED =
      'One or more NOT NULL field not selected.'#13#10 +
      'You must select all NOT NULL fields or'#13#10 +
      'deselect relation.';
    ERR_GENERATOR_NAME_MISSING =
      'Generator name is missing';
    ERR_THERE_ARE_ERRORS = 'There are errors';

    MSG_SET_ALT_KEY_AS_PRIME_KEY =
      'The relation %s have one alternative key.'#13#10 +
      'Recommend select him as PRIME KEY.'#13#10 +
      'Do you want do it?';

    MSG_SELECT_REFERENCE_FIELD =
      'There is FOREIGN KEY on field %s in relation %s'#13#10 +
      'for field %s. The field %s or relation %s is not'#13#10 +
      'include in replication scheme. Do you want include this'#13#10 +
      'field and relation in scheme?';
    MSG_DESELECT_REFERENCE_FIELD =
      'There is referencies on field %s.'#13#10 +
      'Do you want remove this '#13#10 +
      'fields and relations from scheme?';
    MSG_SELECT_REFERENCE_FIELDS =
      'There is referencies on relation %s.'#13#10 +
      'Do you want remove reference fields and'#13#10 +
      'relations from replication scheme?';

    MSG_INFORMATION = 'Information';
    MSG_WARNING = 'Warning';
    MSG_QUESTION = 'Question';

    dbs_Main = 'Main';
    dbs_Secondary = 'Secondary';
    dbp_Highest = 'Highest';
    dbp_High = 'High';
    dbp_Normal = 'Normal';
    dbp_Low = 'Low';
    dbp_Lowest = 'Lowest';

    cap_DBState = 'State';
    cap_DBPriority = 'Priority';
    cap_DBName = 'Name';

  //����� ����� ���������� � ����������
    MSG_REPORT_READING_DBINFO = 'Reading database info...';
    MSG_REPORT_DATE = 'Date: %s';
    MSG_REPORT_REPLTYPE = 'Replication scheme type: %s';
    MSG_REPORT_ERROR_DECISION = 'Error decision: %s';
    MSG_REPORT_REPL_KEY = 'Replication scheme key: %d';
    MSG_REPORT_DB = 'Data bases:';
    MSG_REPORT_DB_ALIAS = '  Alias: %s';
    MSG_REPORT_DB_FILE_NAME = '  File name: %s';
    MSG_REPORT_DB_STATE = '  State: %s';
    MSG_REPORT_DB_PRIORITY = '  Priority: %s';
    MSG_REPORT_DB_KEY = '  Database key: %d';
    MSG_REPORT_NOT_COMMIT = '  Not commited transaction: %d';
    MSG_REPORT_REGISTRED_CHANGES_COUNT = '  Registred changes: %d';
    MSG_REPORT_CONFLICT_COUNT = '  Conflict count: %d';
    MSG_REPORT_DUAL = 'Dual';
    MSG_REPORT_FROMSERVER = 'From server';
    MSG_REPORT_TOSERVER = 'To server';
    MSG_REPORT_CURRENT_DB_ALIAS = 'Current database: %s';
    MSG_REPORT_TRANSFER_DATA_TO = 'Can transfer data to:';

    MSG_REPORT_ERR_DECISION_SERVER = 'Server changes have priority';
    MSG_REPORT_ERR_DECISION_PRIORITY = 'By priority';
    MSG_REPORT_ERR_DECISION_TIME = 'Newest changes have priority';

    MSG_METADATA_DELETE_SUCCES = 'All replication metadate have been succeseful deleted.';
    { TODO : �������� ������� ��������� }
    MSG_METADATA_DELETE_ERROR = 'There are errors:';
    MSG_CREATE_METADATA_ERROR = 'There are errors:';

  {    '���� ���������� � ����������: %s'#13#10 +
      '��� ����� ����������: %s'#13#10 +
      '������ ���������� ���������� ��������: %s'#13#10 +
      '���� ����� ����������: %d'#13#10 +
      '���� ������, ����������� � ����������:'#13#10 +
      '%s'#13#10;}

  //��������� �������� ������ ���������� �������
    MSG_REPORT_CAPTION_SUCCES = 'Succes';
    MSG_REPORT_CAPTION_ERROR = 'Error';

    MSG_REPORT_EXPORT_SUCCES = 'Successful export.';
    MSG_REPORT_EXPORT_UNSUCCES = 'Unuccessful export.';

    MSG_REPORT_IMPORT_SUCCES = 'Successful import.';
    MSG_REPORT_IMPORT_UNSUCCES = 'Unuccessful import.';

    MSG_DROP_METADATA_CAPTION = 'Drop metadata.';
    MSG_WANT_DROP_METADATA = 'Do you realy want to delete all'#13#10 +
     'replication metadata?';
    MSG_WANT_EDIT_METADATA = 'Do you realy want to edit'#13#10 +
      'replication scheme?';
    MSG_EXPORT_DATA_CAPTION = 'Export data.';
    MSG_IMPORT_DATA_CAPTION = 'Import data.';
    MSG_ROLLBACK_TRANSACTION_SUCCES = 'Successful rollback transaction';
    MSG_ROLLBACK_TRANSACTION_ERROR = 'Unuccessful rollback transaction';
    MSG_DROP_FK = 'Drop foreign key %s on table %s';
    MSG_DROPING_FK = 'Dropping foreign keys...';
    MSG_RESTORE_FKs = 'Restore foreign keys...';
    MSG_RESTORE_FK = 'Restore foreign key %s on table %s';
    MSG_FIND_NOT_RESTORE_FK = 'Found %d not restored foreign keys. Restoring...';
    MSG_FOUND_NOT_RESTORED_TRIGGERS = 'Found %d not restored triggers. Restoring...';
    MSG_INACTIVATE_TRIGGERS = 'Inactivate triggers...';
    MSG_ACTIVATE_TRIGGERS = 'Activate triggers...';
    MSG_RESTOREDB_CAPTION = 'Restore data base';
    MSG_THERE_ARE_CONTENTION = 'There are %d contention';
    MSG_CONFLICT_RESOLUTION = 'Start conflict resolution';
    MSG_LOG_RESTORING_METADATA = 'Metadata restoring log';
    MSG_LOG_REPLICATION = 'Replication log';
    MSG_START_REPL_FILE = 'Begin process file: %s';
    MSG_END_REPL_FILE = 'End process file: %s';
    MSG_WANT_RESET_TRIGGER = 'You really want to cancel all changes in a body of the trigger?';
    MSG_SET_TRIGGER = 'Save changes in a body of the trigger?';

    ERR_CREATE_TRIGGER = 'Error on create trigger %s:'#13#10;
    ERR_DROP_TRIGGER = 'Error on drop trigger %s:'#13#10;
    ERR_CREATE_TABLE = 'Error on create table %s:'#13#10;
    ERR_CREATE_GRAND = 'Error on create grand'#13#10;
    ERR_DROP_TABLE = 'Error on drop table %s:'#13#10;
    ERR_CREATE_DOMANE = 'Error on create domane %s:'#13#10;
    ERR_DROP_DOMANE = 'Error on drop domane %s:'#13#10;
    ERR_CREATE_EXCEPTION = 'Error on create exception %s:'#13#10;
    ERR_DROP_EXCEPTION = 'Error on drop exception %s:'#13#10;
    ERR_CREATE_GENERATOR = 'Error on create generator %s:'#13#10;
    ERR_DROP_GENERATOR = 'Error on drop generator %s:'#13#10;
    ERR_CREATE_ROLE = 'Error on create role %s:'#13#10;
    ERR_DROP_ROLE = 'Error on drop role %s:'#13#10;
    ERR_ROLLBACK_TRANSACTION = '%d transaction was rollbacked';
    ERR_DROP_FK = 'Error on drop foreign key %s on table %s: %s';
    ERR_RESTORE_FK = 'Error on restore foreign key %s on table %s: %s';
    ERR_INACTIVATE_TRIGGERS = 'Error on inactivate triggers: %s';
    ERR_ACTIVATE_TRIGGERS = 'Error on activate triggers: %s';
    ERR_CANT_ROLLBACK_TRANSACTION = 'Can`t rollback transaction: %s';
    ERR_ON_READING_FILE = 'Error on reading file %s';

    CAPTION_DEPEND_ON = ' Objects, that depend on %s';
    CAPTION_DEPENDS_ON = ' Objects, that %s depends on';

    ALL_CONFLICT_RESOLUTION = 'All conflict resolutioned';
    CANT_REPL = 'Replication impossible.';
    MSG_STREAM_DO_NOT_INIT = 'Stream do not init';
    MSG_FILE_NOT_FOUND = 'File ''%s'' not found';

    MSG_UPDATE_INSERT_RECORDS = ' Inserting and updating records';
    MSG_DELETE_RECORDS = ' Deleting records';

    ERR_CANT_ADD_DIRECTION_FIELD = 'Error while trying adding information about replication direction.';

    MSG_RELATION = 'Relation %s';

    MSG_CAPTION = 'IBReplicator';

    {$ENDIF}

implementation

end.
