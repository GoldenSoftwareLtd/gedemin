unit gsDBSqueeze_unit;

interface

uses
  IB, IBDatabase, IBSQL;

type
  TgsDBSqueeze = class(TObject)
  private
    FIBSQL: TIBSQL;

    FUserName: String;
    FPassword: String;
    FDatabaseName: String;
    FIBDatabase: TIBDatabase;
    function GetConnected: Boolean;

    procedure h_SaveAllConstraints;
    procedure h_DeleteAllConstraints;
    procedure h_RecreateAllConstraints;

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
end;

function TgsDBSqueeze.GetConnected: Boolean;
begin
  Result := FIBDatabase.Connected;
end;

procedure TgsDBSqueeze.h_SaveAllConstraints; //FK

    procedure execSQL(AQ: TIBSQL; const ASqlText: string);
    begin
      AQ.SQL.Text := ASqlText;
      AQ.ExecQuery;
      AQ.Close;
    end;

var
  q: TIBSQL;
  sql: String;
  Tr: TIBTransaction;
begin
  Assert(Connected);
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := FIBDatabase;
    Tr.StartTransaction;
    q.Transaction := Tr;

    sql := 'CREATE TABLE DBS_INDEX_SEGMENTS (' +
      'INDEX_NAME CHAR(31), ' +
      'FIELD_NAME CHAR(31)) ';
    execSQL(q, sql);

    sql := 'CREATE TABLE DBS_REF_CONSTRAINTS ( ' +
      'CONSTRAINT_NAME CHAR(31), ' +
      'CONST_NAME_UQ   CHAR(31), ' +
      'UPDATE_RULE     CHAR(11), ' +
      'DELETE_RULE     CHAR(11)) ';
    execSQL(q, sql);

    sql := 'CREATE TABLE DBS_RELATION_CONSTRAINTS ( '+
      'CONSTRAINT_NAME CHAR(31), ' +
      'CONSTRAINT_TYPE CHAR(11), ' +
      'RELATION_NAME   CHAR(31), ' +
      'INDEX_NAME      CHAR(31)) ';
    execSQL(q, sql);

    Tr.Commit;     //
    Tr.StartTransaction;
    //q.Transaction := Tr;

    ////////   мб не надо
    sql := 'DELETE FROM DBS_REF_CONSTRAINTS ';
    execSQL(q, sql);

    sql := 'DELETE FROM DBS_RELATION_CONSTRAINTS ';
    execSQL(q, sql);

    sql := 'DELETE FROM DBS_INDEX_SEGMENTS ';
    execSQL(q, sql);
    ////////
    Tr.Commit;    //
    Tr.StartTransaction;
    //q.Transaction := Tr;

    sql := 'INSERT INTO DBS_REF_CONSTRAINTS ' +
      ' (CONSTRAINT_NAME, CONST_NAME_UQ, UPDATE_RULE, DELETE_RULE) SELECT ' +
      ' RDB$CONSTRAINT_NAME, RDB$CONST_NAME_UQ, RDB$UPDATE_RULE, RDB$DELETE_RULE ' +
      'FROM RDB$REF_CONSTRAINTS ';
    execSQL(q, sql);

    sql := 'INSERT INTO DBS_RELATION_CONSTRAINTS ' +
      ' (CONSTRAINT_NAME, CONSTRAINT_TYPE, RELATION_NAME, INDEX_NAME) SELECT ' +
      ' RDB$CONSTRAINT_NAME, RDB$CONSTRAINT_TYPE, RDB$RELATION_NAME, RDB$INDEX_NAME ' +
      'FROM RDB$RELATION_CONSTRAINTS c' +
         'JOIN rdb$indices i ON i.rdb$index_name = c.rdb$index_name ' +
      'WHERE c.rdb$constraint_type = ''FOREIGN KEY'' and '+
         '(i.RDB$SYSTEM_FLAG IS NULL OR i.RDB$SYSTEM_FLAG = 0) ';
    execSQL(q, sql);

    sql := 'INSERT INTO DBS_INDEX_SEGMENTS ' +
      ' (INDEX_NAME, FIELD_NAME) SELECT ' +
      ' RDB$INDEX_NAME, RDB$FIELD_NAME ' +
      ' FROM RDB$INDEX_SEGMENTS ' +
      ' WHERE RDB$INDEX_NAME IN (SELECT INDEX_NAME FROM DBS_RELATION_CONSTRAINTS) ';
    execSQL(q, sql);

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;

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
      q2.Transaction.StartTransaction;
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



end.
