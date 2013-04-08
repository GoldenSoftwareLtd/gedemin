unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL;

type
  TOnLogEvent = procedure(const S: String) of object;
  TActivateIndexFlag = (aiActivate, aiDeactivate);

  TgsDBSqueeze = class(TObject)
  private
    FIBSQL: TIBSQL;

    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    FOnLogEvent: TOnLogEvent;

    function GetConnected: Boolean;

    procedure h_SaveTypeTbls;

    function h_CreateTblForSaveInactivTrig: Boolean;
    procedure h_SaveInactivTrig;
    function h_CreateTblForSaveInactivIndices: Boolean;
    procedure h_SaveInactivIndices;
    procedure h_SwitchActivityIndices(const AnActivateIndexFlag: TActivateIndexFlag);
    procedure h_SwitchActivityTriggers(const AnActivateIndexFlag: TActivateIndexFlag);

    function h_CreateTblForSaveFK: Boolean;
    function h_CreateTblForSavePkUnique: Boolean;
    procedure h_InsertTblForSaveFK;
    procedure h_InsertTblForSavePkUnique;
    procedure h_SaveFKConstr;
    procedure h_SavePkUniqueConstr;

    procedure h_SaveAllConstr;

    procedure h_DeleteFKConstr;
    procedure h_DeletePkUniqueConstr;

    procedure h_DeleteAllConstr;

    procedure h_RecreateFKConstr;
    procedure h_RecreatePkUniqueConstr;

    procedure h_RecreateAllConstr;

    procedure LogEvent(const AMsg: String);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    procedure BeforeMigrationPrepareDB;
    procedure AfterMigrationPrepareDB;

    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property Connected: Boolean read GetConnected;
    property OnLogEvent: TOnLogEvent read FOnLogEvent write FOnLogEvent;

  end;

implementation

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
  LogEvent('Connecting to DB ... OK');
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
  LogEvent('Disconnecting to DB ... OK');
end;

function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;


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
  //имеют составной PK
    q.SQL.Text := ' SELECT r.RDB$RELATION_NAME as Table_Name ' +
    ' FROM RDB$RELATIONS r ' +
    ' WHERE RDB$SYSTEM_FLAG = 0 AND RDB$VIEW_BLR IS NULL ' +
    '   AND RDB$RELATION_NAME NOT IN ( ' +
    '     SELECT ind.rdb$relation_name, rcon.RDB$CONSTRAINT_TYPE ' +
    '     FROM RDB$INDICES ind ' +
    '     JOIN RDB$RELATION_CONSTRAINTS rcon ON rcon.RDB$INDEX_NAME = ind.RDB$INDEX_NAME ' +
    '     WHERE ind.rdb$segment_count > 1 AND rcon.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
    '       AND r.RDB$RELATION_NAME NOT IN (SELECT TABLE_NAME FROM DBS_TYPE_TABLES) ' +
    '   )';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' INSERT INTO DBS_TYPE_TABLES ' +
        ' ( TABLE_NAME, ' +
        ' TYPE_NAME ) VALUES ( ' +
        ' :tblName, ' +
        ' :typeName ) ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.ParamByName('typeName').AsString := 'composite PK';
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
    q.SQL.Text := ' SELECT RELATION_NAME as Table_Name ' +
    ' FROM DBS_FK_CONSTRAINTS ' +
    ' WHERE LIST_FIELD = ''MASTERKEY'' OR LIST_FIELD = ''MASTERDOCKEY'' ' +
    '   AND RELATION_NAME NOT IN (SELECT TABLE_NAME FROM DBS_TYPE_TABLES) ';
    q.ExecQuery;

    q2.SQL.Text := ' INSERT INTO DBS_TYPE_TABLES ' +
      ' ( TABLE_NAME, ' +
      ' TYPE_NAME ) VALUES ( ' +
      ' :tblName, ' +
      ' :typeName ) ';
    q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
    q2.ParamByName('typeName').AsString := 'detail';
    q2.Close;
    q.Close;
    Tr.Commit;

    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q2.Transaction := Tr;
  //Cross
    q.SQL.Text := ' SELECT CROSSTABLE as Table_Name' +
      ' FROM AT_RELATION_FIELDS ' +
      ' WHERE CROSSTABLE IS NOT NULL ' +
      '   AND RELATION_NAME NOT IN (SELECT TABLE_NAME FROM DBS_TYPE_TABLES) ';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' INSERT INTO DBS_TYPE_TABLES ' +
        ' ( TABLE_NAME, ' +
        ' TYPE_NAME ) VALUES ( ' +
        ' :tblName, ' +
        ' :typeName ) ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.ParamByName('typeName').AsString := 'cross';
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
    q.SQL.Text := ' SELECT f.RELATION_NAME as Table_Name ' +
      ' FROM DBS_FK_CONSTRAINTS f' +
      ' JOIN DBS_PK_CONSTRAINTS p ON f.RELATION_NAME = p.RELATION_NAME ' +
      ' WHERE f.LIST_FIELD = p.LIST_FIELDS ' +
      '   AND f.RELATION_NAME NOT IN (SELECT TABLE_NAME FROM DBS_TYPE_TABLES) ';
    q.ExecQuery;

    while (not q.EOF) do
    begin
      q2.SQL.Text := ' INSERT INTO DBS_TYPE_TABLES ' +
        ' ( TABLE_NAME, ' +
        ' TYPE_NAME ) VALUES ( ' +
        ' :tblName, ' +
        ' :typeName ) ';
      q2.ParamByName('tblName').AsString := q.FieldByName('Table_Name').AsString;
      q2.ParamByName('typeName').AsString := '1to1';
      q2.Close;
      q.Next;
    end;
    q.Close;


  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;

end;

function TgsDBSqueeze.h_CreateTblForSaveFK: Boolean;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';
    q.ParamByName('RN').AsString := 'DBS_FK_CONSTRAINTS';
    q.ExecQuery;
    if q.EOF then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_FK_CONSTRAINTS ( ' +
        ' RELATION_NAME     CHAR(31), ' +
        ' CONSTRAINT_NAME   CHAR(31), ' +
        ' LIST_FIELDS       VARCHAR(310), ' +
        ' REF_RELATION_NAME CHAR(31), ' +
        ' LIST_REF_FIELDS   VARCHAR(310), ' +
        ' UPDATE_RULE       CHAR(11), ' +
        ' DELETE_RULE       CHAR(11), ' +
        'PRIMARY KEY (CONSTRAINT_NAME)) ';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_FK_CONSTRAINTS table has been created.');
      Result := True;
    end
    else
    begin
      LogEvent('DBS_FK_CONSTRAINTS table HASN''T been created.');
      Result := False;
    end;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

function TgsDBSqueeze.h_CreateTblForSavePkUnique: Boolean;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';
    q.ParamByName('RN').AsString := 'DBS_PK_UNIQUE_CONSTRAINTS';
    q.ExecQuery;
    if q.EOF then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_PK_UNIQUE_CONSTRAINTS ( ' +
        ' RELATION_NAME     CHAR(31), ' +
        ' CONSTRAINT_NAME   CHAR(31), ' +
        ' CONSTRAINT_TYPE   CHAR(11), ' +
        ' LIST_FIELDS       VARCHAR(310), ' +
        ' PRIMARY KEY (CONSTRAINT_NAME)) ';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_PK_UNIQUE_CONSTRAINTS table has been created.');
      Result := True;
    end
    else
    begin
      LogEvent('DBS_PK_UNIQUE_CONSTRAINTS table HASN''T been created.');
      Result := False;
    end;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;


procedure TgsDBSqueeze.h_InsertTblForSaveFK;
var
  q, q2, q3, q4: TIBSQL;
  Tr, Tr4: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  q3 := TIBSQL.Create(nil);
  q4 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  Tr4 := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    Tr4.DefaultDatabase := FIBDatabase;

    q.Transaction := Tr;
    q2.Transaction := Tr;
    q3.Transaction := Tr;
    q4.Transaction := Tr4;
  {  q.SQL.Text :='INSERT INTO DBS_FK_CONSTRAINTS ( ' +
      ' RELATION_NAME, ' +
      ' CONSTRAINT_NAME, ' +
      ' LIST_FIELDS, ' +
      ' REF_RELATION_NAME, ' +
      ' LIST_REF_FIELDS, ' +
      ' UPDATE_RULE, ' +
      ' DELETE_RULE ) ' +
      'SELECT ' +
      '  c.RDB$RELATION_NAME, ' +
      '  c.RDB$CONSTRAINT_NAME, ' +
      '  i.List_Fields, ' +
      '  c2.RDB$RELATION_NAME, ' +
      ' i2.List_Fields2, ' +
      ' refc.RDB$UPDATE_RULE, ' +
      ' refc.RDB$DELETE_RULE ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN (SELECT inx.rdb$INDEX_NAME, ' +
      '    list(inx.RDB$FIELD_NAME) as List_Fields ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '    GROUP BY inx.rdb$INDEX_NAME ' +
      '  ) i ON c.rdb$INDEX_NAME = i.rdb$INDEX_NAME ' +
      '  JOIN RDB$REF_CONSTRAINTS refc ON c.RDB$CONSTRAINT_NAME = refc.RDB$CONSTRAINT_NAME ' +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ON refc.RDB$CONST_NAME_UQ = c2.RDB$CONSTRAINT_NAME ' +
      '  JOIN (SELECT inx.rdb$INDEX_NAME, ' +
      '    list(inx.RDB$FIELD_NAME) as List_Fields2 ' +
      '    FROM RDB$INDEX_SEGMENTS inx ' +
      '  GROUP BY inx.rdb$INDEX_NAME' +
      '  ) i2 ON c2.rdb$INDEX_NAME = i2.rdb$INDEX_NAME ' +
      'WHERE c.rdb$constraint_type = ''FOREIGN KEY'' ' +
      '  AND NOT c.rdb$relation_name LIKE ''RDB$%'' ';                           //
    q.ExecQuery;
    q.Close;
 }

    q.SQL.Text := 'SELECT ' +
      ' c.RDB$INDEX_NAME as Index_Name, ' +
      ' c.RDB$RELATION_NAME as Relation_Name, ' +
      ' c.RDB$CONSTRAINT_NAME as Constraint_Name, ' +
      ' c2.RDB$INDEX_NAME as Index_Name2, ' +
      ' c2.RDB$RELATION_NAME as Relation_Name2, ' +
      ' refc.RDB$UPDATE_RULE as Update_Rule, ' +
      ' refc.RDB$DELETE_RULE as Delete_Rule ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN RDB$REF_CONSTRAINTS refc ON c.RDB$CONSTRAINT_NAME = refc.RDB$CONSTRAINT_NAME ' +
      '  JOIN RDB$RELATION_CONSTRAINTS c2 ON refc.RDB$CONST_NAME_UQ = c2.RDB$CONSTRAINT_NAME ' +
      'WHERE c.rdb$constraint_type = ''FOREIGN KEY'' ' +
      '  AND NOT c.rdb$relation_name LIKE ''RDB$%'' ';                                          // ??
    q.ExecQuery;

    while not q.EOF  do
    begin
      q2.SQL.Text := ' SELECT list(inx.RDB$FIELD_NAME) as List_Fields ' +
        ' FROM RDB$INDEX_SEGMENTS inx ' +
        ' WHERE inx.RDB$INDEX_NAME = :c_index_name ';
      q2.ParamByName('c_index_name').AsString := q.FieldByName('Index_Name').AsString;
      q2.ExecQuery;

      q3.SQL.Text := ' SELECT list(inx.RDB$FIELD_NAME) as List_Fields2 ' +
        ' FROM RDB$INDEX_SEGMENTS inx ' +
        ' WHERE inx.RDB$INDEX_NAME = :c2_index_name ';
      q3.ParamByName('c2_index_name').AsString := q.FieldByName('Index_Name2').AsString;
      q3.ExecQuery;

      Tr4.StartTransaction;
      q4.SQL.Text := 'INSERT INTO DBS_FK_CONSTRAINTS ( ' +
        ' RELATION_NAME, ' +
        ' CONSTRAINT_NAME, ' +
        ' LIST_FIELDS, ' +
        ' REF_RELATION_NAME, ' +
        ' LIST_REF_FIELDS, ' +
        ' UPDATE_RULE, ' +
        ' DELETE_RULE ) ' +
        'VALUES ( ' +
        ':relation_name, ' +
        ':constraint_name, ' +
        ':list_fields, ' +
        ':ref_relation_name, ' +
        ':list_ref_fields, ' +
        ':update_rule, ' +
        ':delete_rule ) ';
      q4.ParamByName('relation_name').AsString := q.FieldByName('Relation_Name').AsString;
      q4.ParamByName('constraint_name').AsString := q.FieldByName('Constraint_Name').AsString;
      q4.ParamByName('list_fields').AsString := q2.FieldByName('List_Fields').AsString;
      q4.ParamByName('ref_relation_name').AsString := q.FieldByName('Relation_Name2').AsString;
      q4.ParamByName('list_ref_fields').AsString := q3.FieldByName('List_Fields2').AsString;
      q4.ParamByName('update_rule').AsString := q.FieldByName('Update_Rule').AsString;
      q4.ParamByName('delete_rule').AsString := q.FieldByName('Delete_Rule').AsString;
      q4.ExecQuery;
      q4.Close;
      Tr4.Commit;

      q3.Close;
      q2.Close;

      q.Next;
    end;

    q.Close;
    Tr.Commit;
    LogEvent('Inserting in tables for saving FK constraints ... OK');

  finally
    q.Free;
    q2.Free;
    q3.Free;
    q4.Free;
    Tr.Free;
    Tr4.Free;
  end;
end;

procedure TgsDBSqueeze.h_InsertTblForSavePkUnique;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

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
      '  AND NOT c.rdb$relation_name LIKE ''RDB$%'' ';                           //
    q.ExecQuery;
    q.Close;

    Tr.Commit;
    LogEvent('Inserting in tables for saving PK and UNIQUE constraints ... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.h_SaveFKConstr;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  LogEvent('[1]Saving FK constraints ... ');
  if not h_CreateTblForSaveFK then
  begin
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;

      q.SQL.Text := 'DELETE FROM DBS_FK_CONSTRAINTS ';
      q.ExecQuery;
      q.Close;


      Tr.Commit;
      LogEvent('Deleting data from DBS_FK_CONSTRAINTS ... OK');
    finally
      q.Free;
      Tr.Free;
    end;
  end;

  h_InsertTblForSaveFK;

//==================================== TEST
   try
     q := TIBSQL.Create(nil);
     Tr := TIBTransaction.Create(nil);
     Tr.DefaultDatabase := FIBDatabase;
     Tr.StartTransaction;

     q.Transaction := Tr;
     q.SQL.Text := 'SELECT count(c.CONSTRAINT_NAME) as Kolvo FROM DBS_FK_CONSTRAINTS c ';
     q.ExecQuery;
     LogEvent('======== COUNT FK before DROP: ' + q.FieldByName('Kolvo').AsString );
     q.Close;

     Tr.Commit;
   finally
      q.Free;
      Tr.Free;
   end;
//==================================== end
  LogEvent('[1]Saving FK constraints ... OK');
end;

procedure TgsDBSqueeze.h_SavePkUniqueConstr;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  LogEvent('[2]Saving PK and UNIQUE constraints ... ');

  Assert(Connected);
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);

  if not h_CreateTblForSavePkUnique then
  begin
    try
      Tr.DefaultDatabase := FIBDatabase;
      Tr.StartTransaction;

      q.Transaction := Tr;

      q.SQL.Text := 'DELETE FROM DBS_PK_UNIQUE_CONSTRAINTS ';
      q.ExecQuery;
      q.Close;

      Tr.Commit;
      LogEvent('Deleting data from DBS_PK_UNIQUE_CONSTRAINTS ... OK');
    finally
      q.Free;
      Tr.Free;
    end;
  end;

  h_InsertTblForSavePkUnique;
//==================================== TEST
  try
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT count(c.CONSTRAINT_NAME) as Kolvo FROM DBS_PK_UNIQUE_CONSTRAINTS c ';
    q.ExecQuery;
    LogEvent('======== COUNT PK and UNIQUE before DROP: ' + q.FieldByName('Kolvo').AsString );
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
//==================================== end

  LogEvent('[2]Saving PK and UNIQUE constraints ... OK');
end;

procedure TgsDBSqueeze.h_SaveAllConstr;
begin

  LogEvent('Saving All constraints ...');

  h_SaveFKConstr;
  h_SavePkUniqueConstr;
  //...

  LogEvent('Saving All constraints ... OK');
end;

procedure TgsDBSqueeze.h_DeleteFKConstr;
var
  textSql: String;
  q, q2:  TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT c.RDB$RELATION_NAME as Relation_Name, ' +
      '  c.RDB$CONSTRAINT_NAME as Constraint_Name ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN RDB$INDICES i ON i.RDB$INDEX_NAME = c.RDB$INDEX_NAME ' +
      'WHERE c.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' AND '+
      '  (i.RDB$SYSTEM_FLAG IS NULL OR i.RDB$SYSTEM_FLAG = 0) ';                 //
    q.ExecQuery;
    while not q.Eof do
    begin
      textSql := 'ALTER TABLE ' + q.FieldByName('Relation_Name').AsString +
        ' DROP CONSTRAINT ' + q.FieldByName('Constraint_Name').AsString;

      q2.SQL.Text := textSql;
      q2.ExecQuery;
      q2.Close;

      q.Next;
    end;
    Tr.Commit;
    LogEvent('[1]Deleting FK constraints ... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;

//==================================== TEST
  try
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT count(c.RDB$CONSTRAINT_NAME) as Kolvo ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      'WHERE c.rdb$constraint_type = ''FOREIGN KEY'' '; //test
    q.ExecQuery;
    LogEvent('======== COUNT FK after DROP: ' + q.FieldByName('Kolvo').AsString );
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
//==================================== end
end;

procedure TgsDBSqueeze.h_DeletePkUniqueConstr;
var
  textSql: String;
  q, q2:  TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT c.RDB$RELATION_NAME as Relation_Name, ' +
      '  c.RDB$CONSTRAINT_NAME as Constraint_Name ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      '  JOIN RDB$INDICES i ON i.RDB$INDEX_NAME = c.RDB$INDEX_NAME ' +
      'WHERE (c.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' OR c.RDB$CONSTRAINT_TYPE = ''UNIQUE'') AND '+
      '  (i.RDB$SYSTEM_FLAG IS NULL OR i.RDB$SYSTEM_FLAG = 0) ';                 //
    q.ExecQuery;
    while not q.Eof do
    begin
      textSql := 'ALTER TABLE ' + q.FieldByName('Relation_Name').AsString +
        ' DROP CONSTRAINT ' + q.FieldByName('Constraint_Name').AsString;

      q2.SQL.Text := textSql;
      q2.ExecQuery;
      q2.Close;

      q.Next;
    end;
    Tr.Commit;
    LogEvent('[2]Deleting PK and UNIQUE constraints ... OK');
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;

//==================================== TEST
  try
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT count(c.RDB$CONSTRAINT_NAME) as Kolvo FROM RDB$RELATION_CONSTRAINTS c ' +
      'WHERE c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'' '; //test
    q.ExecQuery;
    LogEvent('======== COUNT PK and UNIQUE after DROP: ' + q.FieldByName('Kolvo').AsString );
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
//==================================== end
end;

procedure TgsDBSqueeze.h_DeleteAllConstr;
begin
  LogEvent('Deleting All constraints ...');
  h_DeleteFKConstr;
  h_DeletePkUniqueConstr;
  //...
  LogEvent('Deleting All constraints ... OK');
end;


procedure TgsDBSqueeze.h_RecreateFKConstr;
var
  OnDelete, OnUpdate, textSql: String;
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q2.Transaction := Tr;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT ' +
      ' RELATION_NAME as Relation_Name, ' +
      ' CONSTRAINT_NAME as Constraint_Name, ' +
      ' LIST_FIELDS as List_Fields, ' +
      ' REF_RELATION_NAME as Ref_Relation_Name, ' +
      ' LIST_REF_FIELDS as List_Ref_Fields, ' +
      ' UPDATE_RULE as Update_Rule, ' +
      ' DELETE_RULE as Delete_Rule ' +
      'FROM DBS_FK_CONSTRAINTS ';
    q.ExecQuery;
    while not q.EOF do
    begin
      if (Pos('RESTRICT', q.FieldByName('Delete_Rule').AsString) = 0) then
        OnDelete := ' ON DELETE ' + q.FieldByName('Delete_Rule').AsString
      else OnDelete := ' ON DELETE NO ACTION ';//OnDelete := ' ';
      if (Pos('RESTRICT', q.FieldByName('Update_Rule').AsString) = 0) then
        OnUpdate := ' ON UPDATE ' + q.FieldByName('Update_Rule').AsString
      else OnUpdate := ' ON UPDATE NO ACTION '; //OnUpdate := ' ';

      textSql :=
        'ALTER TABLE ' + q.FieldByName('Relation_Name').AsString + ' ADD CONSTRAINT ' +
        q.FieldByName('Constraint_Name').AsString + ' FOREIGN KEY (' +
        q.FieldByName('List_Fields').AsString +  ') ' + ' REFERENCES ' +
        q.FieldByName('Ref_Relation_Name').AsString + ' (' +
        q.FieldByName('List_Ref_Fields').AsString +') ' + OnDelete + OnUpdate;
      q2.SQL.Text := textSql;
      q2.ExecQuery;
      q2.Close;
      q.Next;
    end;
    Tr.Commit;
    LogEvent('[2]Recreating FK constraints ... OK');

    //удаление  DBS_FK_CONSTRAINTS за ненадобностью
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
//==================================== TEST
  try
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT count(c.RDB$CONSTRAINT_NAME) as Kolvo FROM RDB$RELATION_CONSTRAINTS c WHERE c.rdb$constraint_type = ''FOREIGN KEY'' '; //test
    q.ExecQuery;
    LogEvent('======== COUNT FK after ADD: ' + q.FieldByName('Kolvo').AsString );
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
//==================================== end

end;

procedure TgsDBSqueeze.h_RecreatePkUniqueConstr;
var
  textSql: String;
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q2.Transaction := Tr;

    q.Transaction := Tr;
    q.SQL.Text := 'SELECT ' +
      ' RELATION_NAME as Relation_Name, ' +
      ' CONSTRAINT_NAME as Constraint_Name, ' +
      ' CONSTRAINT_TYPE as Constraint_Type, ' +
      ' LIST_FIELDS as List_Fields ' +
      'FROM  DBS_PK_UNIQUE_CONSTRAINTS ';
    q.ExecQuery;
    while not q.EOF do
    begin
      textSql :=
        'ALTER TABLE ' + q.FieldByName('Relation_Name').AsString + ' ADD CONSTRAINT ' +
        q.FieldByName('Constraint_Name').AsString +  q.FieldByName('Constraint_Type').AsString +
        ' (' + q.FieldByName('List_Fields').AsString +  ') ';
      q2.SQL.Text := textSql;
      q2.ExecQuery;

      q.Next;
    end;
    Tr.Commit;
    LogEvent('[1]Recreating PK and UNIQUE constraints ... OK');

    //удаление DBS_PK_UNIQUE_CONSTRAINTS за ненадобностью
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
//==================================== TEST
  try
     q := TIBSQL.Create(nil);
     Tr := TIBTransaction.Create(nil);
     Tr.DefaultDatabase := FIBDatabase;
     Tr.StartTransaction;

     q.Transaction := Tr;
     q.SQL.Text := 'SELECT count(c.RDB$CONSTRAINT_NAME) as Kolvo FROM RDB$RELATION_CONSTRAINTS c ' +
       'WHERE c.rdb$constraint_type = ''PRIMARY KEY'' OR c.rdb$constraint_type = ''UNIQUE'' ';

     q.ExecQuery;
     LogEvent('======== COUNT PK and UNIQUE after ADD: ' + q.FieldByName('Kolvo').AsString );
     q.Close;

     Tr.Commit;
  finally
      q.Free;
      Tr.Free;
  end;
//==================================== end

end;


procedure TgsDBSqueeze.h_RecreateAllConstr;
begin
  LogEvent('Recreating All constraints ...');
  h_RecreatePkUniqueConstr;
  h_RecreateFKConstr;
  //...
  LogEvent('Recreating All constraints ... OK');
end;


function TgsDBSqueeze.h_CreateTblForSaveInactivTrig: Boolean;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';
    q.ParamByName('RN').AsString := 'DBS_INACTIV_TRIGGERS';
    q.ExecQuery;
    if q.EOF then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_INACTIV_TRIGGERS ( ' +
        ' TRIGGER_NAME     CHAR(31), ' +
        'PRIMARY KEY (TRIGGER_NAME)) ';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_INACTIV_TRIGGERS table has been created.');
      Result := True;
    end
    else
    begin
      LogEvent('DBS_INACTIV_TRIGGERS table HASN''T been created.');
      Result := False;
    end;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.h_SaveInactivTrig;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  
  h_CreateTblForSaveInactivTrig;
  
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q2.Transaction := Tr;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS ' +
      'WHERE RDB$TRIGGER_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG IS DISTINCT FROM 1';
    
    while not q.EOF do
    begin
      q2.SQL.Text := 'INSERT INTO DBS_INACTIV_TRIGGERS ( ' +
        ' TRIGGER_NAME ) ' +
        'VALUES ( ' +
        ':trig_name ) ';
      q2.ParamByName('trig_name').AsString := q.FieldByName('RDB$TRIGGER_NAME').AsString;
      q2.ExecQuery;
	  
      q.Next;
    end;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;


function TgsDBSqueeze.h_CreateTblForSaveInactivIndices: Boolean;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);

  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q2.Transaction := Tr;

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';
    q.ParamByName('RN').AsString := 'DBS_INACTIV_INDICES';
    q.ExecQuery;
    if q.EOF then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_INACTIV_INDICES ( ' +
        ' INDEX_NAME     CHAR(31), ' +
        'PRIMARY KEY (INDEX_NAME)) ';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_INACTIV_INDICES table has been created.');
      Result := True;
    end
    else
    begin
      LogEvent('DBS_INACTIV_INDICES table HASN''T been created.');
      Result := False;
    end;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.h_SaveInactivIndices;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Connected);

  h_CreateTblForSaveInactivIndices;
  
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;

    q2.Transaction := Tr;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ' +
      'WHERE RDB$INDEX_INACTIVE = 1 ' +
      '  AND RDB$SYSTEM_FLAG IS DISTINCT FROM 1';
    
    while not q.EOF do
    begin
      q2.SQL.Text := 'INSERT INTO DBS_INACTIV_INDICES ( ' +
        ' INDEX_NAME ) ' +
        'VALUES ( ' +
        ':index_name ) ';
      q2.ParamByName('index_name').AsString := q.FieldByName('RDB$INDEX_NAME').AsString;
      q2.ExecQuery;
	  
      q.Next;
    end;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;


procedure TgsDBSqueeze.h_SwitchActivityIndices(const AnActivateIndexFlag: TActivateIndexFlag);
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

    q2.Transaction := Tr;
	q3.Transaction := Tr;
    
    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT i.RDB$INDEX_NAME ' +
      'FROM RDB$INDICES i ' +
      'WHERE i.RDB$INDEX_INACTIVE = :index_inactive ' +
      '  AND i.RDB$SYSTEM_FLAG IS DISTINCT FROM 1';
    if AnActivateIndexFlag = aiActivate then
      q.ParamByName('index_inactive').AsInteger := 1
    else
      q.ParamByName('index_inactive').AsInteger := 0;
    q.ExecQuery;

    while not q.EOF do
    begin	
      q2.SQL.Text := 'ALTER INDEX ' + q.FieldByName('RDB$INDEX_NAME').AsString;
      
      q3.SQL.Text :=
        'SELECT INDEX_NAME ' +
        'FROM DBS_INACTIV_INDICES ' +
        'WHERE INDEX_NAME = :inx_name';
      q3.ParamByName('inx_name').AsString := q.FieldByName('RDB$INDEX_NAME').AsString;
      q3.ExecQuery;
	  
      if (AnActivateIndexFlag = aiActivate) and (q3.EOF) then
        q2.SQL.Add('ACTIVE')
      else
        q2.SQL.Add('INACTIVE');
      q2.ExecQuery;
      
      if AnActivateIndexFlag = aiActivate then
        LogEvent('Index ' + q.FieldByName('RDB$INDEX_NAME').AsString + ' activated.')
      else
        LogEvent('Index ' + q.FieldByName('RDB$INDEX_NAME').AsString + ' deactivated.');
      q.Next;
    end;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
	q3.Free;
    Tr.Free;
  end;
end;



procedure TgsDBSqueeze.h_SwitchActivityTriggers(const AnActivateIndexFlag: TActivateIndexFlag);
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

    q2.Transaction := Tr;
	q3.Transaction := Tr;
    
    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT i.RDB$TRIGGER_NAME ' +
      'FROM RDB$TRIGGERS i ' +
      'WHERE i.RDB$TRIGGER_INACTIVE = :trig_inactive ' +
	  '  AND((t.RDB$SYSTEM_FLAG = 0) or (t.RDB$SYSTEM_FLAG is NULL)) ' +                                                            //
      '  AND t.RDB$TRIGGER_NAME NOT IN (SELECT RDB$TRIGGER_NAME FROM RDB$CHECK_CONSTRAINTS) ';
    if AnActivateIndexFlag = aiActivate then
      q.ParamByName('trig_inactive').AsInteger := 1
    else
      q.ParamByName('trig_inactive').AsInteger := 0;
    q.ExecQuery;

    while not q.EOF do
    begin	
      q2.SQL.Text := 'ALTER TRIGGER ' + q.FieldByName('RDB$TRIGGER_NAME').AsString;
      
      q3.SQL.Text :=
        'SELECT TRIGGER_NAME ' +
        'FROM DBS_INACTIV_TRIGGERS ' +
        'WHERE TRIGGER_NAME = :trig_name';
      q3.ParamByName('trig_name').AsString := q.FieldByName('RDB$TRIGGER_NAME').AsString;
      q3.ExecQuery;
	  
      if (AnActivateIndexFlag = aiActivate) and (q3.EOF) then
        q2.SQL.Add('ACTIVE')
      else
        q2.SQL.Add('INACTIVE');
      q2.ExecQuery;
      if AnActivateIndexFlag = aiActivate then
        LogEvent('Trigger ' + q.FieldByName('RDB$TRIGGER_NAME').AsString + ' activated.')
      else
        LogEvent('Trigger ' + q.FieldByName('RDB$TRIGGER_NAME').AsString + ' deactivated.');
      q.Next;
    end;

    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    q3.Free;
    Tr.Free;
  end;
end;




procedure  TgsDBSqueeze.BeforeMigrationPrepareDB;
var
  DeactivateIndexFlag: TActivateIndexFlag;
begin
  DeactivateIndexFlag := aiDeactivate;
  h_SaveInactivTrig;
  h_SaveInactivIndices;
  h_SaveTypeTbls;
  h_SaveAllConstr;
  h_DeleteAllConstr;
  h_SwitchActivityIndices(DeactivateIndexFlag);
  h_SwitchActivityTriggers(DeactivateIndexFlag);
  //...
end;

procedure TgsDBSqueeze.AfterMigrationPrepareDB;
var
  ActivateIndexFlag: TActivateIndexFlag;
begin
  ActivateIndexFlag := aiActivate;
  h_SwitchActivityIndices(ActivateIndexFlag);
  h_SwitchActivityTriggers(ActivateIndexFlag);
  h_RecreateAllConstr;
  //...
end;

procedure TgsDBSqueeze.LogEvent(const AMsg: String);
begin
  if Assigned(FOnLogEvent) then
    FOnLogEvent(AMsg);
end;




end.
