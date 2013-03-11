unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL;

type
  TOnLogEvent = procedure(const S: String) of object;

  TgsDBSqueeze = class(TObject)
  private
    FIBSQL: TIBSQL;

    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    FOnLogEvent: TOnLogEvent;

    function GetConnected: Boolean;


    function  h_CreateTblsForSaveConstr: Boolean;
    procedure h_InsertTblsForSaveConstr;
    procedure h_TblsForSaveConstr;

    procedure h_SaveAllConstraints;
    procedure h_DeleteAllConstraints;
    procedure h_RecreateAllConstraints;
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


function TgsDBSqueeze.h_CreateTblsForSaveConstr: Boolean;
var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  bTable1, bTable2, bTable3: Boolean;
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

    LogEvent('Creating tables for saving FK constraints ...');

    q.SQL.Text :=
      'SELECT * FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = :RN ';

    q.ParamByName('RN').AsString := 'DBS_INDEX_SEGMENTS';
    q.ExecQuery;
    bTable1 := q.EOF;

    q.ParamByName('RN').AsString := 'DBS_REF_CONSTRAINTS';
    q.ExecQuery;
    bTable2 := q.EOF;

    q.ParamByName('RN').AsString := 'DBS_RELATION_CONSTRAINTS';
    q.ExecQuery;
    bTable3 := q.EOF;

    Result := (bTable1 and bTable2) and bTable3;          ///false если хоть одна таблица уже имеется

    if bTable1 then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_INDEX_SEGMENTS (' +
        '  INDEX_NAME CHAR(31), ' +
        '  FIELD_NAME CHAR(31), ' +
        '  PRIMARY KEY (INDEX_NAME, FIELD_NAME) )';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_INDEX_SEGMENTS table has been created.');
    end
    else
      LogEvent('DBS_INDEX_SEGMENTS table HASN''T been created.');

    if bTable2 then
    begin
      q2.SQL.Text := 'CREATE TABLE DBS_REF_CONSTRAINTS ( ' +
        ' CONSTRAINT_NAME CHAR(31), ' +
        ' CONST_NAME_UQ   CHAR(31), ' +
        ' UPDATE_RULE     CHAR(11), ' +
        ' DELETE_RULE     CHAR(11), ' +
        ' PRIMARY KEY (CONSTRAINT_NAME, CONST_NAME_UQ, UPDATE_RULE, DELETE_RULE) )';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_REF_CONSTRAINTS table has been created.');
    end
    else
      LogEvent('DBS_REF_CONSTRAINTS table HASN''T been created.');

    if bTable3 then
    begin
      q2.SQL.Text :=  'CREATE TABLE DBS_RELATION_CONSTRAINTS ( '+
        ' CONSTRAINT_NAME CHAR(31), ' +
        ' CONSTRAINT_TYPE CHAR(11), ' +
        ' RELATION_NAME   CHAR(31), ' +
        ' INDEX_NAME      CHAR(31), ' +
        ' PRIMARY KEY (CONSTRAINT_NAME, CONSTRAINT_TYPE, RELATION_NAME, INDEX_NAME) )';
      q2.ExecQuery;
      q2.Close;
      LogEvent('DBS_RELATION_CONSTRAINTS table has been created.');
    end
    else
      LogEvent('DBS_RELATION_CONSTRAINTS table HASN''T been created.');

    q.Close;
    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
  LogEvent('Creating tables for saving FK constraints ... OK');
end;


procedure TgsDBSqueeze.h_InsertTblsForSaveConstr;
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

    q.SQL.Text :=
      'INSERT INTO DBS_REF_CONSTRAINTS ' +
      ' (CONSTRAINT_NAME,     CONST_NAME_UQ,     UPDATE_RULE,     DELETE_RULE) ' +
      'SELECT ' +
      '  RDB$CONSTRAINT_NAME, RDB$CONST_NAME_UQ, RDB$UPDATE_RULE, RDB$DELETE_RULE ' +
      'FROM RDB$REF_CONSTRAINTS ';
    q.ExecQuery;
    q.Close;

    q.SQL.Text :=
      'INSERT INTO DBS_RELATION_CONSTRAINTS ' +
      '  (CONSTRAINT_NAME,          CONSTRAINT_TYPE,     RELATION_NAME,      INDEX_NAME) ' +
      'SELECT ' +
      '  c.RDB$CONSTRAINT_NAME, c.RDB$CONSTRAINT_TYPE, c.RDB$RELATION_NAME, c.RDB$INDEX_NAME ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
      'WHERE c.rdb$constraint_type = ''FOREIGN KEY'' ' +
      '  AND NOT c.rdb$relation_name LIKE ''RDB$%'' ';
    q.ExecQuery;
    q.Close;

    q.SQL.Text :=
      'INSERT INTO DBS_INDEX_SEGMENTS ' +
      ' (INDEX_NAME,     FIELD_NAME) ' +
      'SELECT ' +
      '  RDB$INDEX_NAME, RDB$FIELD_NAME ' +
      'FROM RDB$INDEX_SEGMENTS ' +
      '  WHERE RDB$INDEX_NAME IN (SELECT INDEX_NAME FROM DBS_RELATION_CONSTRAINTS) ';
    q.ExecQuery;
    q.Close;

    Tr.Commit;
    LogEvent('Inserting in tables for saving FK constraints ... OK');
  finally
    q.Free;
    Tr.Free;
  end;
end;


procedure TgsDBSqueeze.h_TblsForSaveConstr;
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

    if not h_CreateTblsForSaveConstr then
    begin
      q.SQL.Text := 'DELETE FROM DBS_REF_CONSTRAINTS ';
      q.ExecQuery;
      q.Close;
      q.SQL.Text := 'DELETE FROM DBS_RELATION_CONSTRAINTS ';
      q.ExecQuery;
      q.Close;
      q.SQL.Text := 'DELETE FROM DBS_INDEX_SEGMENTS ';
      q.ExecQuery;
      q.Close;

      Tr.Commit;
      LogEvent('Deleting data from tables for saving FK constraints ... OK');
    end;

    h_InsertTblsForSaveConstr;

  finally
    q.Free;
    Tr.Free;
  end;
end;


procedure TgsDBSqueeze.h_SaveAllConstraints;
begin
  LogEvent('Saving FK constraints ...');
  h_TblsForSaveConstr;                                                          //save FK
  LogEvent('Saving FK constraints ... OK');
end;


procedure TgsDBSqueeze.h_DeleteAllConstraints;
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
        'c.RDB$CONSTRAINT_NAME as Constraint_Name ' +
      'FROM RDB$RELATION_CONSTRAINTS c ' +
        'JOIN RDB$INDICES i ON i.RDB$INDEX_NAME = c.RDB$INDEX_NAME ' +
      'WHERE c.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' AND '+
        '(i.RDB$SYSTEM_FLAG IS NULL OR i.RDB$SYSTEM_FLAG = 0) ';
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
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure TgsDBSqueeze.h_RecreateAllConstraints;
var
  textSql: String;
  q, q2: TIBSQL;
  list, list2: String;
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
    q.SQL.Text :=
      'SELECT c.RELATION_NAME as Relation_Name, ' +
       'c.CONSTRAINT_NAME  as Constrant_Name, c.INDEX_NAME as Index_Name, ' +
       'uqc.RELATION_NAME as Relation_Name2, uqc.index_name as Index_Name2, ' +
       'rc.UPDATE_RULE as Update_Rule, rc.DELETE_RULE as Delete_Rule ' +
      'FROM DBS_RELATION_CONSTRAINTS c ' +
      'JOIN DBS_REF_CONSTRAINTS rc ' +
       'ON rc.CONSTRAINT_NAME = c.CONSTRAINT_NAME ' +
      'JOIN DBS_RELATION_CONSTRAINTS uqc ' +
       'ON uqc.CONSTRAINT_NAME = rc.CONST_NAME_UQ ';
    q.ExecQuery;
    while not q.EOF do
    begin
      q2.SQL.text :=
        'SELECT LIST(imast.FIELD_NAME) as Fields ' +
        'FROM DBS_INDEX_SEGMENTS imast ' +
        'WHERE imast.INDEX_NAME = :indexName ';    //c.index_name
      q2.ParamByName('indexName').AsString := q.FieldByName('Index_Name').AsString;
      q2.ExecQuery;
      list := q2.FieldByName('Fields').AsString;
      q2.Close;

      q2.SQL.text :=
        'SELECT LIST(idet.field_name) AS Fields2 ' +
        'FROM DBS_INDEX_SEGMENTS idet ' +
        'WHERE idet.INDEX_NAME = :indexName ';  //uqc.index_name
      q2.ParamByName('indexName').AsString := q.FieldByName('Index_Name2').AsString;
      list2 := q2.FieldByName('Fields2').AsString;
      q2.Close;

      textSql :=
        'ALTER TABLE ' + q.FieldByName('Relation_Name').AsString + ' ADD CONSTRAINT ' +
        q.FieldByName('Constrant_Name').AsTrimString + ' FOREIGN KEY (' + list + ') REFERENCES ' +
        q.FieldByName('Relation_Name2').AsString + ' (' +  list2 + ') ON DELETE ' +
        q.FieldByName('Delete_Rule').AsString + ' ON UPDATE ' +
        q.FieldByName('Update_Rule').AsString;

      q2.SQL.Text := textSql;
      q2.ExecQuery;

      q.Next;
    end;
    Tr.Commit;
  finally
    q.Free;
    q2.Free;
    Tr.Free;
  end;




{
 select 'alter table '||c.relation_name
       ||' add constraint '||c.constraint_name
       ||' foreign key ('
       ||(select list(trim(imast.field_name)) from DBS_INDEX_SEGMENTS imast where imast.index_name = c.index_name)
       ||') references '||trim(uqc.relation_name)
       ||' ('
       ||(select list(trim(idet.field_name)) from DBS_INDEX_SEGMENTS idet where idet.index_name = uqc.index_name)
       ||');'
  from DBS_RELATION_CONSTRAINTS c
       inner join DBS_REF_CONSTRAINTS rc
          on rc.constraint_name = c.constraint_name
       inner join DBS_RELATION_CONSTRAINTS uqc
          on uqc.constraint_name = rc.const_name_uq;    }
end;

procedure  TgsDBSqueeze.BeforeMigrationPrepareDB;
begin
  h_SaveAllConstraints;
  h_DeleteAllConstraints;
  //...
end;

procedure TgsDBSqueeze.AfterMigrationPrepareDB;
begin
  h_RecreateAllConstraints;
  //...
end;

procedure TgsDBSqueeze.LogEvent(const AMsg: String);
begin
  if Assigned(FOnLogEvent) then
    FOnLogEvent(AMsg);
end;

end.

