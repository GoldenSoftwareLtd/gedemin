unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL, Classes, gd_ProgressNotifier_unit;

type
  TOnLogEvent = procedure(const S: String) of object;
  TActivateFlag = (aiActivate, aiDeactivate);

  TgsDBSqueeze = class(TObject)
  private
    FIBSQL: TIBSQL;

    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    FOnProgressWatch: TProgressWatchEvent;

    function GetConnected: Boolean;

    procedure h_Delete;

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
    property Connected: Boolean read GetConnected;
    property OnProgressWatch: TProgressWatchEvent read FOnProgressWatch
      write FOnProgressWatch;
  end;

implementation

uses
  mdf_MetaData_unit;

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
  FIBSQL := TIBSQL.Create(nil);
end;

destructor TgsDBSqueeze.Destroy;
begin
  if Connected then
    Disconnect;
  FIBDatabase.Free;

  FIBSQL.Free;

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

{ TODO  : SaveTypeTbls доделать Master }
{
procedure TgsDBSqueeze.h_SaveTypeTbls;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
//creating table
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';
    q.ParamByName('RN').AsString := 'DBS_TYPE_TABLES';
    q.ExecQuery;
    if q.EOF then
    begin
      q2.SQL.Text := ' CREATE TABLE DBS_TYPE_TABLES ( ' +
        ' TABLE_NAME  VARCHAR(31), ' +
        ' TYPE_NAME   VARCHAR(20), ' +
        ' PRIMARY KEY (TABLE_NAME)) ';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_TYPE_TABLES table has been created.');
    end
    else
    begin
      LogEvent('DBS_TYPE_TABLES table HASN''T been created.');
    end;
    q.Close;
    Tr.Commit;
//inserting to table
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
  //вставим имена всех таблиц
    q.SQL.Text := ' SELECT r.RDB$RELATION_NAME as Table_Name ' +
    ' FROM RDB$RELATIONS r ' +
    ' WHERE  RDB$VIEW_BLR IS NULL ';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' INSERT INTO DBS_TYPE_TABLES ' +
        ' (TABLE_NAME) VALUES (:tblName) ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.Close;

      q.Next;
    end;
    q.Close;
    Tr.Commit;

  //добавляем тип таблиц

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
  //системные
    q.SQL.Text := ' SELECT r.RDB$RELATION_NAME as Table_Name ' +
    ' FROM RDB$RELATIONS r ' +
    ' WHERE RDB$SYSTEM_FLAG = 1 AND RDB$VIEW_BLR IS NULL ';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
        ' TYPE_NAME = ''system'' ' +
        ' WHERE TABLE_NAME = :tblName ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.Close;
      q.Next;
    end;
    q.Close;
    Tr.Commit;


    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
  //gd_ruid
    q.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
      ' TYPE_NAME = ''gd_ruid'' ' +
      ' WHERE TABLE_NAME = ''GD_RUID'' ';
    q.Close;
    Tr.Commit;


    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
  //gd_document
    q.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
      ' TYPE_NAME = ''gd_document'' ' +
      ' WHERE TABLE_NAME = ''GD_DOCUMENT'' ';
    q.Close;
    Tr.Commit;


    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
  //имеют составной PK
    q.SQL.Text := ' SELECT t.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES t ' +
      'WHERE t.TYPE_NAME IS NULL ' +
      '  AND t.RELATION_NAME IN ( ' +
      '    SELECT ind.rdb$relation_name ' +
      '    FROM RDB$INDICES ind ' +
      '      JOIN RDB$RELATION_CONSTRAINTS rcon ON rcon.RDB$INDEX_NAME = ind.RDB$INDEX_NAME ' +
      '    WHERE ind.rdb$segment_count > 1 AND rcon.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
      '  ) ';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
        ' TYPE_NAME = ''composite PK'' ' +
        ' WHERE TABLE_NAME = :tblName ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.Close;
      q.Next;
    end;
    q.Close;
    Tr.Commit;


    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
  //не имеют PK
    q.SQL.Text := ' SELECT r.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES r ' +
      'WHERE TYPE_NAME IS NULL ' +
      '  AND r.RELATION_NAME NOT IN ( ' +
      '    SELECT RDB$RELATION_NAME FROM RDB$RELATION_CONSTRAINTS ' +
      '    WHERE RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
      '    )';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
        ' TYPE_NAME = ''without PK'' ' +
        ' WHERE TABLE_NAME = :tblName ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.Close;
      q.Next;
    end;
    q.Close;
    Tr.Commit;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
  //Детальные
    q.SQL.Text := ' SELECT r.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES r ' +
      'WHERE r.TYPE_NAME IS NULL ' +
      '  AND r.RELATION_NAME IN ( ' +
      '    SELECT RELATION_NAME ' +
      '    FROM DBS_FK_CONSTRAINTS ' +
      '    WHERE LIST_FIELD = ''MASTERKEY'' ' +
      '  )';
    q.ExecQuery;

    q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
      'TYPE_NAME = ''detail masterkey'' ' +
      'WHERE TABLE_NAME = :tblName ';
    q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
    q2.Close;
    q.Close;
    Tr.Commit;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text := ' SELECT r.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES r ' +
      'WHERE r.TYPE_NAME IS NULL ' +
      '  AND r.RELATION_NAME IN ( ' +
      '    SELECT RELATION_NAME ' +
      '    FROM DBS_FK_CONSTRAINTS ' +
      '    WHERE LIST_FIELD = ''MASTERDOCKEY'' ' +
      '  )';
    q.ExecQuery;

    q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
      'TYPE_NAME = ''detail masterdockey'' ' +
      'WHERE TABLE_NAME = :tblName ';
    q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
    q2.Close;
    q.Close;
    Tr.Commit;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
  //Cross
    q.SQL.Text := ' SELECT r.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES r ' +
      'WHERE r.TYPE_NAME IS NULL ' +
      '  AND r.RELATION_NAME IN ( ' +
      '    SELECT CROSSTABLE ' +
      '    FROM AT_RELATION_FIELDS ' +
      '    WHERE CROSSTABLE IS NOT NULL ' +
      '  )';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
        'TYPE_NAME = ''cross'' ' +
        'WHERE TABLE_NAME = :tblName ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;

      q2.Close;
      q.Next;
    end;
    q.Close;
    Tr.Commit;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
  //1-к-1
    q.SQL.Text := ' SELECT r.RELATION_NAME as Table_Name ' +
      'FROM DBS_TYPE_TABLES r ' +
      'WHERE TYPE_NAME IS NULL ' +
      '  AND r.RELATION_NAME IN ( ' +
      '    SELECT fk.RELATION_NAME ' +
      '    FROM DBS_FK_CONSTRAINTS fk ' +
      '      JOIN DBS_PK_CONSTRAINTS pk ON fk.RELATION_NAME = pk.RELATION_NAME ' +
      '    WHERE fk.LIST_FIELD = pk.LIST_FIELDS ' +
      '    )';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' UPDATE DBS_TYPE_TABLES SET' +
        'TYPE_NAME = ''1to1'' ' +
        'WHERE TABLE_NAME = :tblName ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;

      q2.Close;
      q.Next;
    end;
    q.Close;
    Tr.Commit;

  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;

end;
}


procedure TgsDBSqueeze.h_Delete;
var
  q, q2, q3: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);

  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;

    q.SQL.Text := ' SELECT r.RDB$RELATION_NAME as Table_Name ' +
    ' FROM RDB$RELATIONS r ' +
    ' WHERE r.RDB$SYSTEM_FLAG = 0 AND r.RDB$VIEW_BLR IS NULL ';
    q.ExecQuery;

    while not q.EOF  do
    begin
      q2.SQL.Text := 'SELECT LIST_FIELDS as PK' +
        'FROM DBS_PK_UNIQUE_CONSTRAINTS ' +
        'WHERE CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
        '  AND RELATION_NAME = :RELAT_NAME ';
      q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('Table_Name').AsString;
      q2.ExecQuery;

      if not q2.EOF then
      begin
        q3.SQL.Text := ' DELETE FROM ' + q.FieldByName('Table_Name').AsString +
          ' WHERE g_his_has(0, ' + q3.FieldByName('PK').AsString + ') = 0';
        q3.ExecQuery;
        q3.Close;
      end;
      q2.Close;
      q.Next;
    end;

    q.Close;
    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    q3.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.Delete;     { TODO : Delete доделать }
var
  q, q2, q3, q4: TIBSQL;
  Tr: TIBTransaction;
  StrListFields: TStringList;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  StrListFields := TStringList.Create;
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;
    q4.Transaction := Tr;

   //сохраним все ID, на которые есть ссылки
    q.Close;
    q.SQL.Text := 'SELECT g_his_create(0, 0) FROM RDB$DATABASE ';               //создание M
    q.ExecQuery;

    q.Close;
    q.SQL.Text := ' SELECT RELATION_NAME, LIST_FIELDS ' +
      ' FROM DBS_FK_CONSTRAINTS ';
    q.ExecQuery;

    while not q.Eof do
    begin
     {                              //распарсим список полей FK                  ///не пригодится! тогда берем только первое

      StrListFields.CommaText := q.FieldByName('LIST_FIELDS').AsString;
                                   //добавим fk в М
      q2.SQL.Text := ' SELECT g_his_include(0, ' + StrListFields[0] +  ') FROM ' + q.FieldByName('RELATION_NAME').AsString;
      }

      q2.SQL.Text := ' SELECT g_his_include(0, ' + q.FieldByName('LIST_FIELDS').AsString +  ') FROM ' + q.FieldByName('RELATION_NAME').AsString;
      q2.ExecQuery;

      q.Next;
    end;

   // cоздание M2 - множество для удаления
    q.Close;
    q.SQL.Text := ' SELECT g_his_create(1, 0) FROM RDB$DATABASE';
    q.ExecQuery;
      //...заполнение добавить


   // обработка всех ID в базе
    q.Close;
    q.SQL.Text := ' SELECT r.RDB$RELATION_NAME as Table_Name ' +
    ' FROM RDB$RELATIONS r ' +
    ' WHERE r.RDB$SYSTEM_FLAG = 0 AND r.RDB$VIEW_BLR IS NULL ';
    q.ExecQuery;

    q2.Close;
    q2.SQL.Text := 'SELECT LIST_FIELDS ' +
      'FROM DBS_PK_UNIQUE_CONSTRAINTS ' +
      'WHERE CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
      '  AND RELATION_NAME = :RELAT_NAME ';
    q2.ParamByName('RELAT_NAME').AsString := q.FieldByName('Table_Name').AsString;
    q2.ExecQuery;

  {
                               //распарсим список полей PK                      ///не пригодится! тогда берем только первое
    StrListFields.Clear;
    StrListFields.CommaText := q2.FieldByName('LIST_FIELDS').AsString;
                               //получаем набор ID
    q3.SQL.Text :=  'SELECT ' + StrListFields[0] + ' AS _ID, ' +
      ' g_his_has(0, ' + StrListFields[0]  + ') AS HAS_IN_M ' +
      ' g_his_has(1, ' + StrListFields[0]  + ') AS HAS_IN_M2 ' +
      ' FROM ' + q.FieldByName('Table_Name').AsString;
    q3.ExecQuery;
  }

    if not q2.EOF then
    begin
      q3.SQL.Text :=  'SELECT ' + q2.FieldByName('LIST_FIELDS').AsString + ' AS _ID, ' +
        ' g_his_has(0, ' + q2.FieldByName('LIST_FIELDS').AsString  + ') AS HAS_IN_M, ' +
        ' g_his_has(1, ' + q2.FieldByName('LIST_FIELDS').AsString  + ') AS HAS_IN_M2 ' +
        ' FROM ' + q.FieldByName('Table_Name').AsString;
      q3.ExecQuery;

      while not q3.EOF do
      begin
                                 //обрабатываем запись
        if (q.FieldByName('HAS_IN_M2').AsInteger = 0) then    //если нет в множестве для удаления
        begin
          if(q.FieldByName('HAS_IN_M').AsInteger = 0) then
          begin                                              //добавим в M
            q4.SQL.Text := 'SELECT g_his_include(0, ' + q3.FieldByName('_ID').AsString + ') FROM RDB$DATABASE ';
            q4.ExecQuery;
          end;
        end
        else begin                                        //если есть ссылки на нее
          if(q.FieldByName('HAS_IN_M').AsInteger = 1) then
          begin                                           //ислючим из M2
            q4.SQL.Text := 'SELECT g_his_exclude(1, ' + q3.FieldByName('_ID').AsString + ') FROM RDB$DATABASE ';
            q4.ExecQuery;
          end;
        end;

        q3.Next;
      end;

      Tr.Commit;

      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q2.Transaction := Tr;

      ///...удаление
      h_Delete;
    end;

    q.Close;
    q.SQL.Text := 'SELECT g_his_destroy(0) FROM RDB$DATABASE ';
    q.ExecQuery;

   
    q.Close;
    q.SQL.Text := 'SELECT g_his_destroy(1) FROM RDB$DATABASE ';
    q.ExecQuery;

    q.Close;
    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
    StrListFields.Free;
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
	  q.SQL.Text := 'CREATE TABLE DBS_PK_UNIQUE_CONSTRAINTS ( ' +
	    ' RELATION_NAME     CHAR(31), ' +
	    ' CONSTRAINT_NAME   CHAR(31), ' +
	    ' CONSTRAINT_TYPE   CHAR(11), ' +
	    ' LIST_FIELDS       VARCHAR(310), ' +
	    ' PRIMARY KEY (CONSTRAINT_NAME)) ';
	  q.ExecQuery;
	  q.Close;
	  LogEvent('Table DBS_PK_UNIQUE_CONSTRAINTS table has been created.');
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
      '      AND RDB$SYSTEM_FLAG = 0 ' +
      '    INTO :N ' +
      '  DO ' +
      '    EXECUTE STATEMENT ''ALTER INDEX '' || :N || '' INACTIVE ''; ' +
      'END';
    q.ExecQuery;
    LogEvent('Indices deactivated.');
  end;

  procedure PreparePkUniqueConstraints;
  begin
    q.SQL.Text := 'INSERT INTO DBS_PK_UNIQUE_CONSTRAINTS ( ' +
      ' RELATION_NAME, ' +
      ' CONSTRAINT_NAME, ' +
      ' CONSTRAINT_TYPE, ' +
      ' LIST_FIELDS ) ' +
      'SELECT ' +
      '  c.RDB$RELATION_NAME, ' +
      '  c.RDB$CONSTRAINT_NAME, ' +
      '  c.RDB$CONSTRAINT_TYPE, ' +
      '  i.List_Fields ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN (SELECT inx.rdb$INDEX_NAME, ' +
      '    list(inx.RDB$FIELD_NAME) as List_Fields ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '    GROUP BY inx.rdb$INDEX_NAME ' +
      '  ) i ON c.rdb$INDEX_NAME = i.rdb$INDEX_NAME ' +
      'WHERE (c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'') ' +
      '  AND NOT (c.rdb$constraint_name LIKE ''RDB$%'') ';
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
    LogEvent('PKs&UNIQ dropped.');
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
      '  LIST(iseg.rdb$field_name, '','') AS Fields, ' +
      '  LIST(ref_iseg.rdb$field_name, '','') AS Ref_Fields ' +
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
      '  NOT (c.rdb$constraint_name LIKE ''RDB$%'' ' +
      '    OR c.rdb$constraint_name LIKE ''INTEG_%'') ' +
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
    PrepareIndices;
    PrepareTriggers;

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

    LogEvent('PKs&UNIQUE restored.');
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
