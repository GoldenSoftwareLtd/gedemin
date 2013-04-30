unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL, Classes, gd_ProgressNotifier_unit;

type
  TOnLogEvent = procedure(const S: String) of object;
  TActivateFlag = (aiActivate, aiDeactivate);

  TgsDBSqueeze = class(TObject)
  private
    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    FOnProgressWatch: TProgressWatchEvent;

    FDelCondition: String;

    function GetConnected: Boolean;

    procedure LogEvent(const AMsg: String);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    procedure TestAndCreateMetadata;
    procedure PrepareDB;
    procedure RestoreDB;

    procedure Delete;

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property DelCondition: String read FDelCondition write FDelCondition;
    property Connected: Boolean read GetConnected;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch
      write FOnProgressWatch;
  end;

implementation

uses
  SysUtils, mdf_MetaData_unit;

{ TgsDBSqueeze }

procedure TgsDBSqueeze.Connect;
begin
  FIBDatabase.DatabaseName := FDatabaseName;
  FIBDatabase.LoginPrompt := False;
  FIBDatabase.Params.Text :=
    'user_name=' + FUserName + #13#10 +
    'password=' + FPassword + #13#10 +
    'lc_ctype=win1251';
  FIBDatabase.Connected := True;
  LogEvent('Connecting to DB... OK');
end;

constructor TgsDBSqueeze.Create;
begin
  inherited;
  FIBDatabase := TIBDatabase.Create(nil);
end;

destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;
  inherited;
end;

procedure TgsDBSqueeze.Disconnect;
begin
  FIBDatabase.Connected := False;
  LogEvent('Disconnecting from DB... OK');
end;

function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;

procedure TgsDBSqueeze.Delete;

  procedure DoCascade(const ATableName: String; ATr: TIBTransaction);
  var
    q, q2, q3: TIBSQL;
    Count: Integer; ///test
    Tr2: TIBTransaction;
  begin
    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    q3 := TIBSQL.Create(nil);
    Tr2 := TIBTransaction.Create(nil);
    try
      Tr2.DefaultDatabase := FIBDatabase;
      Tr2.StartTransaction;
      q3.Transaction := Tr2;

      q2.Transaction := ATr;
      q.Transaction := ATr;

      LogEvent('DoCascade...   --test');

      q.SQL.Text :=
        'SELECT ' +
        '  fc.relation_name, ' +
        '  fc.list_fields, ' +
        '  pc.list_fields AS pk_fields ' +
        'FROM dbs_fk_constraints fc ' +
        '  JOIN dbs_pk_unique_constraints pc ' +
        '    ON pc.relation_name = fc.relation_name ' +
        '  AND pc.constraint_type = ''PRIMARY KEY'' ' +
        'WHERE fc.update_rule = ''CASCADE'' ' +
        '  AND UPPER(fc.ref_relation_name) = :rln ';
      q.ParamByName('rln').AsString := UpperCase(ATableName);
      q.ExecQuery;

      while not q.EOF do
      begin
        q2.SQL.Text :=
          'SELECT COUNT(fc.RELATION_NAME) as Kolvo ' +
          'FROM DBS_FK_CONSTRAINTS fc ' +
          'WHERE UPPER(fc.ref_relation_name) = :rln ' +
          '  AND fc.update_rule IN (''RESTRICT'', ''NO ACTION'') ';
        q2.ParamByName('rln').AsString := UpperCase(q.FieldByName('relation_name').AsString);
        q2.ExecQuery;

        if(q2.FieldByName('Kolvo').AsInteger = 0) then
        begin
          q2.Close;

          if(Pos(',', q.FieldByName('pk_fields').AsString) = 0) then
          begin
            q2.SQL.Text :=
              'SELECT ' +                                                       //�������� ���� ���� ��
              '  CASE F.RDB$FIELD_TYPE ' +
              '    WHEN 8 THEN ''INTEGER'' ' +
              '    ELSE ''NOT INTEGER'' ' +
              '  END FIELD_TYPE ' +
              'FROM RDB$RELATION_FIELDS RF ' +
              'JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
              'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
            q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('relation_name').AsString;
            q2.ParamByName('FIELD').AsString := q.FieldByName('pk_fields').AsString;
            q2.ExecQuery;

            if q2.FieldByName('FIELD_TYPE').AsString = 'INTEGER' then
            begin
              q2.Close;
              q2.SQL.Text :=
              'SELECT ' +                                                       //�������� ���� ����
              '  CASE F.RDB$FIELD_TYPE ' +
              '    WHEN 8 THEN ' +
              '      CASE F.RDB$FIELD_SUB_TYPE ' +
              '        WHEN 0 THEN ''INTEGER'' ' +
              '        ELSE ''NOT INTEGER'' ' +
              '    END ' +
              '    ELSE ''NOT INTEGER'' ' +
              '  END FIELD_TYPE ' +
              'FROM RDB$RELATION_FIELDS RF ' +
              '  JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
              'WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ';
              q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('relation_name').AsString;

              q2.ParamByName('FIELD').AsString := q.FieldByName('list_fields').AsString;
              q2.ExecQuery;

              if q2.FieldByName('FIELD_TYPE').AsString = 'INTEGER' then
              begin
                q2.Close;
                q3.SQL.Text :=
                  'SELECT COUNT(g_his_include(0, ' + q.FieldByName('pk_fields').AsString + ')) AS Kolvo ' +
                  'FROM ' +
                  '  ' + q.FieldByName('relation_name').AsString + ' ' +
                  'WHERE ' +
                  '  g_his_has(0, ' + q.FieldByName('list_fields').AsString + ') = 1 AND ' +
                     q.FieldByName('pk_fields').AsString + ' > 147000000 ';
                q3.ExecQuery;

                //LogEvent('test--COUNT HIS now: ' + q3.FieldByName('Kolvo').AsString);

                Count := Count + q3.FieldByName('Kolvo').AsInteger;                             { TODO :  Count ������ }


                q3.Close;

                Tr2.Commit;                                                     ///?    ATr
                Tr2.DefaultDatabase := FIBDatabase;
                Tr2.StartTransaction;

                DoCascade(q.FieldByName('relation_name').AsString, ATr);
              end
              else
                q2.Close;
            end
            else
              q2.Close;
          end;
        end;
        q2.Close;
        q.Next;
      end;
      q.Close;
      LogEvent('test--COUNT in HIS: ' + IntToStr(Count));
      LogEvent('DoCascade...OK   --test');
    finally
      q2.Free;
      q3.Free;
      q.Free;
    end;
  end;

  procedure ExcludeFKs(ATr: TIBTransaction);
  var
    q: TIBSQL;
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      LogEvent('ExcludeFKs...   --test');

 {     ///--for test
      if RelationExist2('DBS_EXCLUDED_FIELDS', ATr) then
      begin
        q.SQL.Text := ' DELETE FROM DBS_EXCLUDED_FIELDS ';
        q.ExecQuery;
        LogEvent('Table DBS_EXCLUDED_FIELDS exists. --for test');
      end else
      begin
        q.SQL.Text :=
          'CREATE TABLE DBS_EXCLUDED_FK_FIELDS ( ' +
          '  TABLE_NAME    CHAR(31) NOT NULL, ' +
          '  FK_FIELD_NAME CHAR(31) NOT NULL, ' +
          '  PRIMARY KEY (FK_FIELD_NAME, TABLE_NAME)) ';
        q.ExecQuery;
        LogEvent('Table DBS_EXCLUDED_FIELDS has been created. --for test');
      end;
      q.Close;
      ATr.Commit;
      ATr.DefaultDatabase := FIBDatabase;
      ATr.StartTransaction;
 }

      q.SQL.Text :=
      {
        'EXECUTE BLOCK ' +
        'AS ' +
        '  DECLARE VARIABLE RN CHAR(31); ' +
        '  DECLARE VARIABLE FN CHAR(31); ' +
        '  DECLARE VARIABLE S  VARCHAR(8192); ' +
        'BEGIN ' +
        '  FOR ' +
        '    SELECT ' +
        '      DISTINCT c.relation_name ' +
        '    FROM ' +
        '      dbs_fk_constraints c ' +
        '    INTO :RN ' +
        '  DO BEGIN ' +
        '    S = ''''; ' +
        '    FOR ' +
        '      SELECT ' +
        '        c.list_fields  ' +
        '      FROM ' +
        '        dbs_fk_constraints c ' +
        '        JOIN rdb$relation_fields rf ON rf.rdb$field_name = c.list_fields ' +
        '          AND rf.rdb$relation_name = c.relation_name ' +
        '        JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
        '      WHERE ' +
        '        c.update_rule IN (''RESTRICT'', ''NO ACTION'') ' +
        '        AND f.rdb$field_type = 8 ' +
        '        AND c.relation_name = :RN ' +
        '      INTO :FN ' +
        '    DO BEGIN ' +
        '      S = IIF(:S = '''', :S, :S || '','') || ' +
        '        '' SUM(g_his_exclude(0, '' || :FN || ''))''; ' +
        '    END ' +
        '    EXECUTE STATEMENT ''SELECT '' || :S || '' FROM '' || :RN; ' +
        '  END ' +
        'END; ';
       }
                        ///���������� ������
        'EXECUTE BLOCK ' +
        'AS ' +
        'DECLARE VARIABLE NOT_EOF INTEGER; ' +                                  ///for test
        'DECLARE VARIABLE iid INTEGER; ' +
        'DECLARE VARIABLE type_field VARCHAR(20); ' +
        'DECLARE VARIABLE RELAT_NAME VARCHAR(31); ' +
        'DECLARE VARIABLE FIELD VARCHAR(31); ' +
        'BEGIN ' +
        '  FOR ' +
        '    SELECT RELATION_NAME, LIST_FIELDS ' +
        '    FROM DBS_FK_CONSTRAINTS ' +
        '    WHERE update_rule IN (''RESTRICT'', ''NO ACTION'') ' +
        '    INTO :RELAT_NAME, :FIELD ' +
        '  DO BEGIN ' +
        '    SELECT ' +
        '    CASE F.RDB$FIELD_TYPE ' +
        '      WHEN 8 THEN ' +
        '        ''INTEGER'' ' +
        '      ELSE ''NOT INTEGER'' ' +
        '    END FIELD_TYPE ' +
        '    FROM RDB$RELATION_FIELDS RF ' +
        '      JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) ' +
        '    WHERE (RF.RDB$RELATION_NAME = :RELAT_NAME) AND (RF.RDB$FIELD_NAME = :FIELD) ' +
        '    INTO :type_field ; ' +
        '    if (:type_field = ''INTEGER'') then ' +
        '    begin ' +
        '      FOR ' +
        '        EXECUTE STATEMENT ''SELECT '' || :FIELD || '' FROM '' || :RELAT_NAME ' +
        '      INTO :iid ' +
        '      DO BEGIN ' +
        '        if (g_his_has(0, :iid) = 1) then ' +
        '        begin ' +
      { '          SELECT COUNT(FK_FIELD_NAME) FROM DBS_EXCLUDED_FK_FIELDS ' +          ///
        '            WHERE (TABLE_NAME = :RELAT_NAME) AND (FK_FIELD_NAME = :FIELD) ' +  ///
        '          INTO :NOT_EOF; ' +                                                   ///
        '          if (:NOT_EOF = 0) then ' +                                           ///
        '          begin ' +                                                            ///
        '            INSERT INTO DBS_EXCLUDED_FK_FIELDS (TABLE_NAME, FK_FIELD_NAME) ' + ///test
        '              VALUES (:RELAT_NAME, :FIELD); ' +                                ///
        '          end ' +   }
        '          g_his_exclude(0, :iid); ' +
        '        end ' +
        '      END ' +
        '    end ' +
        '  END ' +
        'END ';
      q.ExecQuery;
      ATr.Commit;
      ATr.DefaultDatabase := FIBDatabase;
      ATr.StartTransaction;

      LogEvent('ExcludeFKs... OK  --test');
    finally
      q.Free;
    end;
  end;
var
  q2: TIBSQL; //for test
  Count: Integer;  //for test
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    LogEvent('Deleting from DB...   --test');

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_create(0, 0); END';
    q.ExecQuery;

    q.SQL.Text :=
      'SELECT COUNT(g_his_include(0, id)) as Kolvo FROM gd_document WHERE documentdate < :D';
    q.ParamByName('D').AsString := DelCondition;
    q.ExecQuery;

    Tr.Commit;
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    LogEvent('test--COUNT doc records for delete: ' + q.FieldByName('Kolvo').AsString);

    DoCascade('gd_document', Tr);   ///without FKs22
    //ExcludeFKs(Tr);
    ///--test
    q.Close;
    q.SQL.Text :=
      'SELECT COUNT(id) as Kolvo FROM gd_document WHERE documentdate < :D AND g_his_has(0, id) = 1 ';
    q.ParamByName('D').AsString := DelCondition;
    q.ExecQuery;
    Tr.Commit;
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    LogEvent('--COUNT doc records for delete AFTER ExcludeFKs: ' + q.FieldByName('Kolvo').AsString + '  --test');

    ///--test
    q2 := TIBSQL.Create(nil);
    q2.Transaction := Tr;
    q.Close;
    q.SQL.Text := ' SELECT relation_name as RN, list_fields as LF ' +
      ' FROM dbs_pk_unique_constraints ' +
      ' WHERE constraint_type = ''PRIMARY KEY'' ' ;
    q.ExecQuery;
    while not q.EOF do
    begin
      q2.SQL.Text := 'SELECT count(' + q.FieldByName('LF').AsString + ') as Kolvo FROM ' + q.FieldByName('RN').AsString + ' WHERE g_his_has(0, ' + q.FieldByName('LF').AsString + ') = 1';
      q2.ExecQuery;
      Count := Count + q2.FieldByName('Kolvo').AsInteger;
      q2.Close;
    end;
    LogEvent('COUNT FOR DELETE: ' + IntToStr(Count));
    q.Close;
    q2.Free;
    //---

    q.Close;
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      '  DECLARE VARIABLE FN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT relation_name, list_fields ' +
      '    FROM dbs_pk_unique_constraints ' +
      '    WHERE constraint_type = ''PRIMARY KEY'' ' +
      '    INTO :RN, :FN ' +
      '  DO BEGIN ' +
      '    EXECUTE STATEMENT ''DELETE FROM '' || :RN || '' WHERE ' +
      '      g_his_has(0, '' || :FN || '') = 1 AND '' || :FN || '' > 147000000''; ' +
      '  END ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    ///--test
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.SQL.Text :=
      'SELECT COUNT (id) as Kolvo FROM gd_document WHERE documentdate < :D';
    q.ParamByName('D').AsString := DelCondition; //ADate;
    q.ExecQuery;
    LogEvent('test--COUNT doc records for delete AFTER deleting: ' + q.FieldByName('Kolvo').AsString);

    q.Close;
    q.SQL.Text := ' SELECT relation_name as RN, list_fields as LF ' +
      'FROM dbs_pk_unique_constraints ' +
      'WHERE constraint_type = ''PRIMARY KEY'' ' ;
    q.ExecQuery;
    q2 := TIBSQL.Create(nil);
    q2.Transaction := Tr;
    Count := 0;
    while not q.EOF do
    begin
      q2.SQL.Text := 'SELECT count( ' + q.FieldByName('LF').AsString + ' ) as Kolvo FROM ' + q.FieldByName('RN').AsString + ' WHERE g_his_has(0, ' + q.FieldByName('LF').AsString + ') = 1';
      q2.ExecQuery;
      Count := Count + q2.FieldByName('Kolvo').AsInteger;
      q2.Close;
    end;
    LogEvent('test--COUNT AFTER DELETE: ' + IntToStr(Count));
    q.Close;
    q2.Free;
    //---

    q.SQL.Text :=
      'EXECUTE BLOCK AS BEGIN g_his_destroy(0); END';
    q.ExecQuery;
    Tr.Commit;
    LogEvent('Deleting from DB... OK  --test');
  finally
    q.Free;
    Tr.Free;
  end;

end;

procedure TgsDBSqueeze.LogEvent(const AMsg: String);
var
  PI: TgdProgressInfo;
begin
  if Assigned(FOnProgressWatch) then
  begin
    PI.State := psMessage;
    PI.Message := AMsg;
    FOnProgressWatch(Self, PI);
  end;
end;

procedure TgsDBSqueeze.TestAndCreateMetadata;
var
  q: TIBSQL;
  Tr: TIBTransaction;

  procedure CreateDBSInactiveTriggers;
  begin
    if RelationExist2('DBS_INACTIVE_TRIGGERS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_INACTIVE_TRIGGERS';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_TRIGGERS exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_TRIGGERS ( ' +
        '  TRIGGER_NAME     CHAR(31) NOT NULL, ' +
        '  PRIMARY KEY (TRIGGER_NAME))';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_TRIGGERS has been created.');
    end;
  end;

  procedure CreateDBSInactiveIndices;
  begin
    if RelationExist2('DBS_INACTIVE_INDICES', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_INACTIVE_INDICES';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_INDICES exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_INACTIVE_INDICES ( ' +
        '  INDEX_NAME     CHAR(31) NOT NULL, ' +
        '  PRIMARY KEY (INDEX_NAME))';
      q.ExecQuery;
      LogEvent('Table DBS_INACTIVE_INDICES has been created.');
    end;
  end;

  procedure CreateDBSPkUniqueConstraints;
  begin
    if RelationExist2('DBS_PK_UNIQUE_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_PK_UNIQUE_CONSTRAINTS';
      q.ExecQuery;
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS exist.');
    end
    else begin
      q.SQL.Text :=
        'CREATE TABLE DBS_PK_UNIQUE_CONSTRAINTS ( ' +
	'  CONSTRAINT_NAME   CHAR(31), ' +
	'  RELATION_NAME     CHAR(31), ' +
	'  CONSTRAINT_TYPE   CHAR(11), ' +
	'  LIST_FIELDS       VARCHAR(310), ' +
	'  PRIMARY KEY (CONSTRAINT_NAME)) ';
      q.ExecQuery;
      q.Close;
      LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateDBSFKConstraints;
  begin
    if RelationExist2('DBS_FK_CONSTRAINTS', Tr) then
    begin
      q.SQL.Text := 'DELETE FROM DBS_FK_CONSTRAINTS';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS exists.');
    end else
    begin
      q.SQL.Text :=
        'CREATE TABLE DBS_FK_CONSTRAINTS ( ' +
        '  CONSTRAINT_NAME   CHAR(31), ' +
        '  RELATION_NAME     CHAR(31), ' +
        '  LIST_FIELDS       VARCHAR(8192), ' +
        '  REF_RELATION_NAME CHAR(31), ' +
        '  LIST_REF_FIELDS   VARCHAR(8192), ' +
        '  UPDATE_RULE       CHAR(11), ' +
        '  DELETE_RULE       CHAR(11), ' +
        '  PRIMARY KEY (CONSTRAINT_NAME)) ';
      q.ExecQuery;
      LogEvent('Table DBS_FK_CONSTRAINTS has been created.');
    end;
  end;

  procedure CreateUDFs;
  begin
    if FunctionExist2('G_HIS_CREATE', Tr) then
      LogEvent('Function g_his_create exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_CREATE ' +
        '  INTEGER, ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_create'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_create has been declared.');
    end;

    if FunctionExist2('G_HIS_DESTROY', Tr) then
      LogEvent('Function g_his_destroy exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_DESTROY ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_destroy'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_destroy has been declared.');
    end;

    if FunctionExist2('G_HIS_EXCLUDE', Tr) then
      LogEvent('Function g_his_exclude exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_EXCLUDE ' +
        '  INTEGER, ' +
        '  INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_exclude'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_exclude has been declared.');
    end;

    if FunctionExist2('G_HIS_HAS', Tr) then
      LogEvent('Function g_his_has exists.')
    else begin
      q.SQL.Text :=
        'DECLARE EXTERNAL FUNCTION G_HIS_HAS ' +
        ' INTEGER, ' +
        ' INTEGER  ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_has'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_has has been declared.');
    end;

    if FunctionExist2('G_HIS_INCLUDE', Tr) then
      LogEvent('Function g_his_include exists.')
    else begin
      q.SQL.Text :=  'DECLARE EXTERNAL FUNCTION G_HIS_INCLUDE ' +
        ' INTEGER, ' +
        ' INTEGER ' +
        'RETURNS INTEGER BY VALUE ' +
        'ENTRY_POINT ''g_his_include'' MODULE_NAME ''gudf'' ';
      q.ExecQuery;
      LogEvent('Function g_his_include has been declared.');
    end;
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    CreateDBSInactiveTriggers;
    CreateDBSInactiveIndices;
    CreateDBSPkUniqueConstraints;
    CreateDBSFKConstraints;
    CreateUDFs;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.PrepareDB;
var
  Tr: TIBTransaction;
  q: TIBSQL;

  procedure PrepareTriggers;
  begin
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_TRIGGERS (TRIGGER_NAME) ' +
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE RDB$TRIGGER_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG = 0';
    q.ExecQuery;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$trigger_name ' +
      '    FROM rdb$triggers ' +
      '    WHERE rdb$trigger_inactive = 0 ' +
      '      AND RDB$SYSTEM_FLAG = 0 ' +
      '      AND RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ' +
      '    INTO :TN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
    LogEvent('Triggers deactivated.');
  end;

  procedure PrepareIndices;
  begin
    q.SQL.Text :=
      'INSERT INTO DBS_INACTIVE_INDICES (INDEX_NAME) ' +
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE RDB$INDEX_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG = 0';
    q.ExecQuery;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT rdb$index_name ' +
      '    FROM rdb$indices ' +
      '    WHERE rdb$index_inactive = 0 ' +
     // '      AND RDB$SYSTEM_FLAG = 0 ' +
      '      AND (NOT rdb$index_name LIKE ''RDB$%'') ' +
      '      AND (NOT rdb$index_name LIKE ''INTEG_$%'') ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
    LogEvent('Indices deactivated.');
  end;

  procedure PreparePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'INSERT INTO DBS_PK_UNIQUE_CONSTRAINTS ( ' +
      '  RELATION_NAME, ' +
      '  CONSTRAINT_NAME, ' +
      '  CONSTRAINT_TYPE, ' +
      '  LIST_FIELDS ) ' +
      'SELECT ' +
      '  c.RDB$RELATION_NAME, ' +
      '  c.RDB$CONSTRAINT_NAME, ' +
      '  c.RDB$CONSTRAINT_TYPE, ' +
      '  i.List_Fields ' +
      'FROM ' +
      '  RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN (SELECT inx.RDB$INDEX_NAME, ' +
      '    list(inx.RDB$FIELD_NAME) as List_Fields ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '    GROUP BY inx.RDB$INDEX_NAME ' +
      '  ) i ON c.RDB$INDEX_NAME = i.RDB$INDEX_NAME ' +
      'WHERE ' +
      '  (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' +
      '   AND (NOT c.RDB$INDEX_NAME LIKE ''RDB$%'') ' +
      '   AND (NOT c.RDB$INDEX_NAME LIKE ''INTEG_%'') '; //' NOT (c.rdb$constraint_name LIKE ''RDB$%'') '
    q.ExecQuery;
    
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
     '    SELECT constraint_name, relation_name ' +
      '    FROM DBS_PK_UNIQUE_CONSTRAINTS ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;
    LogEvent('PKs&UNIQs dropped.');
  end;

  procedure PrepareFKConstraints;
  begin
    q.SQL.Text :=
      'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      '  CONSTRAINT_NAME, RELATION_NAME, REF_RELATION_NAME, ' +
      '  UPDATE_RULE, DELETE_RULE, LIST_FIELDS, LIST_REF_FIELDS) ' +
      'SELECT ' +
      '  c.RDB$CONSTRAINT_NAME AS Constraint_Name, ' +
      '  c.RDB$RELATION_NAME AS Relation_Name, ' +
      '  c2.RDB$RELATION_NAME AS Ref_Relation_Name, ' +
      '  refc.RDB$UPDATE_RULE AS Update_Rule, ' +
      '  refc.RDB$DELETE_RULE AS Delete_Rule, ' +
      '  LIST(iseg.rdb$field_name) AS Fields, ' +
      '  LIST(ref_iseg.rdb$field_name) AS Ref_Fields ' +
      'FROM ' +
      '  RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN RDB$REF_CONSTRAINTS refc ' +
      '    ON c.RDB$CONSTRAINT_NAME = refc.RDB$CONSTRAINT_NAME ' +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ' +
      '    ON refc.RDB$CONST_NAME_UQ = c2.RDB$CONSTRAINT_NAME ' +
      '  JOIN rdb$index_segments iseg ' +
      '    ON iseg.rdb$index_name = c.rdb$index_name ' +
      '  JOIN rdb$index_segments ref_iseg ' +
      '    ON ref_iseg.rdb$index_name = c2.rdb$index_name ' +
      'WHERE ' +
      '  (NOT c.rdb$constraint_name LIKE ''RDB$%'') ' +
      '    AND NOT c.rdb$index_name LIKE ''INTEG_%'' ' + // NOT  c.rdb$constraint_name LIKE ''INTEG_%'' ' +
      'GROUP BY ' +
      '  1, 2, 3, 4, 5';
    q.ExecQuery;

    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE CN CHAR(31); ' +
      '  DECLARE VARIABLE RN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT constraint_name, relation_name ' +
      '    FROM dbs_fk_constraints ' +
      '    INTO :CN, :RN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TABLE '' || :RN || '' DROP CONSTRAINT '' || :CN; ' +
      'END';
    q.ExecQuery;
    LogEvent('FKs dropped.');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.ParamCheck := False;
    q.Transaction := Tr;

    PrepareFKConstraints;
    PreparePkUniqueConstraints;
    PrepareTriggers;
    PrepareIndices;
    
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.RestoreDB;
var
  Tr: TIBTransaction;
  q: TIBSQL;

  procedure RestoreTriggers;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE TN CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT t.rdb$trigger_name ' +
      '    FROM rdb$triggers t ' +
      '      LEFT JOIN dbs_inactive_triggers it ON it.trigger_name = t.rdb$trigger_name ' +
      '    WHERE t.rdb$trigger_inactive = 0 ' +
      '      AND t.rdb$system_flag = 0 ' +
      '      AND it.trigger_name IS NULL ' +
      '    INTO :TN ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER TRIGGER '' || :TN || '' ACTIVE ''; ' +
      '  DELETE FROM dbs_inactive_triggers; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Triggers reactivated.');
  end;

  procedure RestoreIndices;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE N CHAR(31); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT i.rdb$index_name ' +
      '    FROM rdb$indices i ' +
      '      LEFT JOIN dbs_inactive_indices ii ON ii.index_name = i.rdb$index_name ' +
      '    WHERE i.rdb$index_inactive = 0 ' +
      '      AND i.rdb$system_flag = 0 ' +
      '      AND ii.index_name IS NULL ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' ACTIVE ''; ' +
      '  DELETE FROM dbs_inactive_indices; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('Indices reactivated.');
  end;


  procedure RestorePkUniqueConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE S CHAR(16384); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' '' || constraint_type ||'' ('' || list_fields || '') '' ' +
      '    FROM dbs_pk_unique_constraints ' +
      '    INTO :S ' +
      '  DO ' +
      '    EXECUTE STATEMENT :S; ' +
      '  DELETE FROM dbs_pk_unique_constraints; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('PKs&UNIQs restored.');
  end;

  procedure RestoreFKConstraints;
  begin
    q.SQL.Text :=
      'EXECUTE BLOCK ' +
      'AS ' +
      '  DECLARE VARIABLE S CHAR(16384); ' +
      'BEGIN ' +
      '  FOR ' +
      '    SELECT ''ALTER TABLE '' || relation_name || '' ADD CONSTRAINT '' || ' +
      '      constraint_name || '' FOREIGN KEY ('' || list_fields || '') REFERENCES '' || ' +
      '      ref_relation_name || ''('' || list_ref_fields || '') '' || ' +
      '      IIF(update_rule = ''RESTRICT'', '''', '' ON UPDATE '' || update_rule) || ' +
      '      IIF(delete_rule = ''RESTRICT'', '''', '' ON DELETE '' || delete_rule) ' +
      '    FROM dbs_fk_constraints ' +
      '    INTO :S ' +
      '  DO ' +
      '    EXECUTE STATEMENT :S; ' +
      '  DELETE FROM dbs_fk_constraints; ' +
      'END';
    q.ExecQuery;

    Tr.Commit;
    Tr.StartTransaction;

    LogEvent('FKs restored.');
  end;

begin
  Assert(Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.ParamCheck := False;
    q.Transaction := Tr;

    RestoreIndices;
    RestoreTriggers;
    RestorePkUniqueConstraints;
    RestoreFKConstraints;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.