unit mdf_MetaData_unit;

interface

uses
  IBSQL, IBDataBase, IBScript, gdcBaseInterface;

type
  TmdfField = record
    RelationName: string;
    FieldName: string;
    Description: string;
  end;

  TSortType = (stAsc, stDesc);

  TmdfIndex = record
    RelationName: string;
    IndexName: string;
    Columns: string; // Список полей через запятую
    Unique: boolean;
    Sort: TSortType;
  end;

  TmdfStoredProcedure = record
    ProcedureName: string;
    Description: string;
  end;

  TmdfTrigger = record
    TriggerName: string;
    Description: string;
  end;

  TmdfTable = record
    TableName: string;
    Description: string;
  end;

  TmdfConstraint = record
    TableName: string;
    ConstraintName: string;
    Description: string;
  end;

  TmdfView = record
    ViewName: string;
  end;

  TmdfException = record
    ExceptionName: string;
    Message: string;
  end;

function FieldExist(Field: TmdfField; DB: TIBDataBase): Boolean;
procedure AddField(Field: TmdfField; DB: TIBDataBase);
procedure DropField(Field: TmdfField; DB: TIBDataBase);
procedure AlterField(Field: TmdfField; Db: TIBDataBase);

function FieldExist2(const ARelName, AFieldName: String; ATr: TIBTransaction): Boolean;
procedure AddField2(const ARelName, AFieldName, AFieldType: String; ATr: TIBTransaction);
procedure DropField2(const ARelName, AFieldName: String; ATr: TIBTransaction);

function ViewExist(View: TmdfView; Db: TIBDataBase): boolean;
procedure DropView(View: TmdfView; Db: TIBDataBase);

function ConstraintExist(Constraint: TmdfConstraint; Db: TIBDataBase): Boolean;
function ConstraintExist2(const ATableName, AConstraintName: String; ATr: TIBTransaction): Boolean;
procedure DropConstraint(Constraint: TmdfConstraint; Db: TIBDataBase);
procedure AddConstraint(Constraint: TmdfConstraint; Db: TIBDataBase);

function IndexExist2(const AnIndexName: String; ATr: TIBTransaction): boolean;
procedure DropIndex2(const AnIndexName: String; ATr: TIBTransaction);

function IndexExist(Index: TmdfIndex; DB: TIBDataBase): boolean;
procedure AddIndex(Index: TmdfIndex; DB: TIBDataBase);
procedure DropIndex(Index: TmdfIndex; DB: TIBDataBase);

procedure AlterProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);
procedure CreateProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);
function ProcedureExist(SP: TmdfStoredProcedure; DB: TIBDataBase):boolean;
procedure ExecuteProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);

function ProcedureExist2(const AProcName: String; ATr: TIBTransaction): Boolean;
procedure DropProcedure2(const AProcName: String; ATr: TIBTransaction);

function RelationExist(Table: TmdfTable; Db: TIbdataBase): boolean;
procedure CreateRelation(Table: TmdfTable; Db: TIBdatabase);
procedure DropRelation(Table: TmdfTable; Db: TIBdatabase);
procedure AlterRelation(Table: TmdfTable; Db: TIBdatabase);

function TriggerExist(Trigger: TmdfTrigger; Db: TIBDataBase): Boolean;
procedure CreateTrigger(Trigger: TmdfTrigger; Db: TIBDataBase);
procedure AlterTrigger(Trigger: TmdfTrigger; Db: TIBDataBase);

function TriggerExist2(const ATriggerName: String; ATr: TIBTransaction): Boolean;
procedure DropTrigger2(const ATriggerName: String; ATr: TIBTransaction);

function ExceptionExists(Ex: TmdfException; Db: TIBDataBase): boolean;
procedure CreateException(Ex: TmdfException; Db: TIBDataBase);

function ExceptionExist2(const AnExceptionName: String; ATr: TIBTransaction): Boolean;

function GenId(Db: TIBdatabase): integer;
function GetRUIDRecByID(const AnID: Integer; Transaction: TIBTransaction): TRUIDRec;
function GetRUIDStringByID(const ID: Integer; const Tr: TIBTransaction): TRUIDString;
procedure AddFinVersion(const ID: Integer; const NumVersion, Comment, DateOper: String;
  const Tr: TIBTransaction);

implementation

uses
  SysUtils, gdcBase;

function FieldExist(Field: TmdfField; DB: TIBDataBase): Boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add('SELECT rdb$field_name FROM rdb$relation_fields WHERE ' +
        ' rdb$field_name = :fieldname AND  rdb$relation_name = :relationname');
      SQL.ParamByName('fieldname').AsString := UpperCase(Field.FieldName);
      SQl.ParamByName('relationname').AsString := Uppercase(Field.RelationName);
      SQL.ExecQuery;
      Result := SQl.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure AddField(Field: TmdfField; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('ALTER TABLE %s ADD %s %s', [Field.RelationName,
        Field.FieldName, Field.Description]));
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure DropField(Field: TmdfField; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if FieldExist(Field, Db) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Add(Format('ALTER TABLE %s DROP %s', [Field.RelationName,
          Field.FieldName]));
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure AlterField(Field: TmdfField; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if FieldExist(Field, Db) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Text := Format('ALTER TABLE %s ALTER %s %s', [Field.RelationName,
          Field.FieldName, Field.Description]);
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function FieldExist2(const ARelName, AFieldName: String; ATr: TIBTransaction): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT rdb$field_name FROM rdb$relation_fields WHERE ' +
      ' rdb$field_name = :fieldname AND rdb$relation_name = :relationname';
    SQL.ParamByName('fieldname').AsString := UpperCase(AFieldName);
    SQl.ParamByName('relationname').AsString := Uppercase(ARelName);
    SQL.ExecQuery;
    Result := not SQl.EOF;
  finally
    SQl.Free;
  end;
end;

procedure AddField2(const ARelName, AFieldName, AFieldType: String; ATr: TIBTransaction);
var
  SQL: TIBSQl;
begin
  if not FieldExist2(ARelName, AFieldName, ATr) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ATr;
      SQL.SQL.Text := Format('ALTER TABLE %s ADD %s %s', [ARelName, AFieldName, AFieldType]);
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
  end;
end;

procedure DropField2(const ARelName, AFieldName: String; ATr: TIBTransaction);
var
  SQL: TIBSQl;
begin
  if FieldExist2(ARelName, AFieldName, ATr) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ATr;
      SQL.SQL.Text := 'ALTER TABLE ' + ARelName + ' DROP ' + AFieldName;
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
  end;
end;

function ViewExist(View: TmdfView; Db: TIBDataBase): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add('SELECT * FROM rdb$view_relations WHERE rdb$view_name = ' +
        ':viewname');
      SQL.ParamByName('viewname').AsString := UpperCase(View.ViewName);
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure DropView(View: TmdfView; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if ViewExist(View, Db) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Add(Format('DROP VIEW %s ', [View.ViewName]));
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function ConstraintExist(Constraint: TmdfConstraint; Db: TIBDataBase): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add('SELECT * FROM rdb$relation_constraints WHERE rdb$relation_name = ' +
        ':relationname AND rdb$constraint_name = :name');
      SQL.ParamByName('relationname').AsString := UpperCase(Constraint.TableName);
      SQL.ParamByName('name').AsString := UpperCase(Constraint.ConstraintName);
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

function ConstraintExist2(const ATableName, AConstraintName: String; ATr: TIBTransaction): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text := 'SELECT * FROM rdb$check_constraints c JOIN rdb$triggers t ' +
      ' ON t.rdb$trigger_name = c.rdb$trigger_name WHERE t.rdb$relation_name = :RN AND c.rdb$constraint_name = :CN ';
    SQL.ParamByName('RN').AsString := AnsiUpperCase(ATableName);
    SQL.ParamByName('CN').AsString := AnsiUpperCase(AConstraintName);
    SQL.ExecQuery;
    Result := not SQL.EOF;
  finally
    SQL.Free;
  end;
end;

procedure DropConstraint(Constraint: TmdfConstraint; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if ConstraintExist(Constraint, Db) then
  begin
    DB.Connected := False;
    DB.Connected := True;

    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Add(Format('ALTER TABLE %s DROP CONSTRAINT %s ', [Constraint.TableName,
          Constraint.ConstraintName]));
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure AddConstraint(Constraint: TmdfConstraint; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if not ConstraintExist(Constraint, Db) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Add(Format('ALTER TABLE %s ADD CONSTRAINT %s %s', [Constraint.TableName,
          Constraint.ConstraintName, Constraint.Description]));
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function IndexExist2(const AnIndexName: String; ATr: TIBTransaction): boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT rdb$index_name FROM rdb$indices WHERE ' +
      ' rdb$index_name = :indexname';
    SQl.ParamByName('indexname').AsString := Uppercase(AnIndexName);
    SQL.ExecQuery;
    Result := not SQl.EOF;
  finally
    SQl.Free;
  end;
end;

procedure DropIndex2(const AnIndexName: String; ATr: TIBTransaction);
var
  SQL: TIBSQL;
begin
  if IndexExist2(AnIndexName, ATr) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ATr;
      SQL.SQL.Text := 'DROP INDEX ' + AnIndexName;
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
  end;  
end;

function IndexExist(Index: TmdfIndex; DB: TIBDataBase): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('SELECT * FROM rdb$indices WHERE rdb$relation_name  = ''%s'' AND ' +
        '  rdb$index_name = ''%s''', [UpperCase(Index.RelationName),
        UpperCase(Index.IndexName)]));
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure AddIndex(Index: TmdfIndex; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
  Sort: string;
  Unique: string;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      if Index.Sort = stAsc then
        Sort := 'ASC'
      else
        Sort := 'DESC';

      if Index.Unique then
        Unique := 'UNIQUE'
      else
        Unique := '';

      SQL.SQL.Add(Format('CREATE %s %s INDEX %s ON %s (%s)', [Unique, Sort,
         UpperCase(Index.IndexName), UpperCase(Index.RelationName),
         Index.Columns]));
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure DropIndex(Index: TmdfIndex; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  if IndexExist(Index, Db) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Add(Format('DROP INDEX %s ', [Index.IndexName]));
        SQL.ExecQuery;
      finally
        SQl.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure AlterProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  Script: TIBScript;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    Script := TIBScript.Create(nil);
    try
      Script.Database := DB;
      Script.Transaction := Transaction;
      Script.Script.Text :=
        'SET TERM ^ ;'#13#10 +
        Format('ALTER PROCEDURE %s %s ^', [SP.ProcedureName,
        SP.Description]) + #13#10' SET TERM ; ^'#13#10 +
          Format('GRANT EXECUTE ON PROCEDURE %s TO ADMINISTRATOR; ', [SP.ProcedureName]);
      Script.ExecuteScript;
    finally
      Script.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure CreateProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  Script: TIBScript;
begin
  if not ProcedureExist(SP, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBScript.Create(nil);
      try
        Script.Database := DB;
        Script.Transaction := Transaction;
        Script.Script.Text :=
          'SET TERM ^ ;'#13#10 +
          Format('CREATE PROCEDURE %s %s ^', [SP.ProcedureName,
          SP.Description]) + #13#10' SET TERM ; ^ '#13#10 +
          Format('GRANT EXECUTE ON PROCEDURE %s TO ADMINISTRATOR; ', [SP.ProcedureName]);
        Script.ExecuteScript;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end else
    AlterProcedure(Sp, DB);
end;

function ProcedureExist(SP: TmdfStoredProcedure; DB: TIBDataBase): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('SELECT * FROM rdb$procedures WHERE rdb$procedure_name  = ''%s''',
        [UpperCase(SP.ProcedureName)]));
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure ExecuteProcedure(SP: TmdfStoredProcedure; DB: TIBDataBase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('EXECUTE PROCEDURE %s',
        [UpperCase(SP.ProcedureName)]));
      SQL.ExecQuery;
    finally
      SQL.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

function ProcedureExist2(const AProcName: String; ATr: TIBTransaction): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT rdb$procedure_name FROM rdb$procedures WHERE ' +
      ' rdb$procedure_name = :procedurename ';
    SQL.ParamByName('procedurename').AsString := UpperCase(AProcName);
    SQL.ExecQuery;
    Result := not SQL.EOF;
  finally
    SQl.Free;
  end;
end;

procedure DropProcedure2(const AProcName: String; ATr: TIBTransaction);
var
  SQL: TIBSQL;
begin
  if ProcedureExist2(AProcName, ATr) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ATr;
      SQL.SQL.Text := 'DROP PROCEDURE ' + AProcName;
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
  end;
end;

function RelationExist(Table: TmdfTable; Db: TIbdataBase): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('SELECT * FROM rdb$relations WHERE rdb$relation_name  = ''%s''',
        [UpperCase(Table.TableName)]));
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure CreateRelation(Table: TmdfTable; Db: TIBdatabase);
var
  Transaction: TIBTransaction;
  Script: TIBScript;
begin
  if not RelationExist(Table, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBScript.Create(nil);
      try
        Script.Database := DB;
        Script.Transaction := Transaction;
        Script.Script.Text :=
          Format('CREATE TABLE %s %s ;', [Table.TableName,
          Table.Description]) +
          Format('GRANT ALL ON %s TO ADMINISTRATOR; ', [Table.TableName]);
        Script.ExecuteScript;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure DropRelation(Table: TmdfTable; Db: TIBdatabase);
var
  Transaction: TIBTransaction;
  SQL: TIBSQL;
begin
  if not RelationExist(Table, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Database := DB;
        SQL.Transaction := Transaction;
        SQL.SQL.Text :=
          Format('DROP TABLE %s ', [Table.TableName]);
        SQL.ExecQuery;
      finally
        SQL.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure AlterRelation(Table: TmdfTable; Db: TIBdatabase);
var
  Transaction: TIBTransaction;
  Script: TIBScript;
begin
  if RelationExist(Table, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBScript.Create(nil);
      try
        Script.Database := DB;
        Script.Transaction := Transaction;
        Script.Script.Text :=
          Format('ALTER TABLE %s %s ;', [Table.TableName,
          Table.Description]) +
          Format('GRANT ALL ON %s TO ADMINISTRATOR; ', [Table.TableName]);
        Script.ExecuteScript;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function TriggerExist(Trigger: TmdfTrigger; Db: TIBDataBase): Boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('SELECT * FROM rdb$triggers WHERE rdb$trigger_name  = ''%s''',
        [UpperCase(Trigger.TriggerName)]));
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure CreateTrigger(Trigger: TmdfTrigger; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  Script: TIBSQL;
begin
  if not TriggerExist(Trigger, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBSQL.Create(nil);
      try
        Script.Transaction := Transaction;
        Script.SQL.Text :=
          Format('CREATE TRIGGER %s %s ', [Trigger.TriggerName,
          Trigger.Description]) {+
          Format('GRANT ALL ON %s TO ADMINISTRATOR; ', [Table.TableName])};
        Script.ParamCheck := False;
        Script.ExecQuery;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

procedure AlterTrigger(Trigger: TmdfTrigger; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  Script: TIBSQL;
begin
  if TriggerExist(Trigger, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBSQL.Create(nil);
      try
        Script.Transaction := Transaction;
        Script.SQL.Text :=
          Format('ALTER TRIGGER %s %s ', [Trigger.TriggerName,
          Trigger.Description]) {+
          Format('GRANT ALL ON %s TO ADMINISTRATOR; ', [Table.TableName])};
        Script.ParamCheck := False;
        Script.ExecQuery;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function TriggerExist2(const ATriggerName: String; ATr: TIBTransaction): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT rdb$trigger_name FROM rdb$triggers WHERE ' +
      ' rdb$trigger_name = :triggername ';
    SQL.ParamByName('triggername').AsString := UpperCase(ATriggerName);
    SQL.ExecQuery;
    Result := not SQL.EOF;
  finally
    SQl.Free;
  end;
end;

procedure DropTrigger2(const ATriggerName: String; ATr: TIBTransaction);
var
  SQL: TIBSQL;
begin
  if TriggerExist2(ATriggerName, ATr) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ATr;
      SQL.SQL.Text := 'DROP TRIGGER ' + ATriggerName;
      SQL.ExecQuery;
    finally
      SQl.Free;
    end;
  end;
end;

function ExceptionExist2(const AnExceptionName: String; ATr: TIBTransaction): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ATr;
    SQL.SQL.Text :=
      'SELECT rdb$exception_name FROM rdb$exceptions WHERE ' +
      ' rdb$exception_name = :name ';
    SQL.ParamByName('name').AsString := UpperCase(AnExceptionName);
    SQL.ExecQuery;
    Result := not SQL.EOF;
  finally
    SQl.Free;
  end;
end;

function ExceptionExists(Ex: TmdfException; Db: TIBDataBase ): boolean;
var
  Transaction: TIBTransaction;
  SQL: TIBSQl;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Add(Format('SELECT * FROM rdb$exceptions WHERE rdb$exception_name  = ''%s''',
        [UpperCase(Ex.ExceptionName)]));
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
    finally
      SQl.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

procedure CreateException(Ex: TmdfException; Db: TIBDataBase);
var
  Transaction: TIBTransaction;
  Script: TIBSQL;
begin
  if not ExceptionExists(Ex, DB) then
  begin
    Transaction := TIBTransaction.Create(nil);
    try
      Transaction.DefaultDatabase := DB;
      Transaction.StartTransaction;
      Script := TIBSQL.Create(nil);
      try
        Script.Transaction := Transaction;
        Script.SQL.Text :=
          Format('CREATE EXCEPTION %s ''%s'' ', [Ex.ExceptionName,
          Ex.Message]);
        Script.ParamCheck := False;
        Script.ExecQuery;
      finally
        Script.Free;
      end;
      Transaction.Commit;
    finally
      Transaction.Free;
    end;
  end;
end;

function GenId(Db: TIBdatabase): integer;
var
  Transaction: TIBTransaction;
  SQL: TIBSQL;
begin
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDatabase := DB;
    Transaction.StartTransaction;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Database := DB;
      SQL.Transaction := Transaction;
      SQL.SQL.Text :=
        'SELECT gen_id(gd_g_unique, 1) FROM rdb$database';
      SQL.ExecQuery;
      Result := SQL.Fields[0].AsInteger;
    finally
      SQL.Free;
    end;
    Transaction.Commit;
  finally
    Transaction.Free;
  end;
end;

function GetRUIDRecByID(const AnID: Integer; Transaction: TIBTransaction): TRUIDRec;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;

    SQL.SQL.Text := 'SELECT * FROM gd_ruid WHERE id=:id';
    SQL.ParamByName('ID').AsInteger := AnID;
    SQL.ExecQuery;

    if SQL.EOF then
    begin
      SQL.Close;
      SQL.SQL.Text := 'INSERT INTO gd_ruid (id, xid, dbid, modified) VALUES (:id, :xid, (SELECT gen_id(GD_G_DBID, 0) FROM rdb$database), :modified)';
      SQL.ParamByName('id').AsInteger := AnId;
      SQL.ParamByName('xid').AsInteger := AnId;
      SQl.ParamByName('modified').AsDateTime := Date;
      SQl.ExecQuery;
      Transaction.CommitRetaining;
      Result := GetRUIDRecById(AnID, Transaction);
    end else
    begin
      Result.ID := SQL.FieldByName('id').AsInteger;
      Result.Modified := SQL.FieldByName('modified').AsDateTime;
      Result.EditorKey := SQL.FieldByName('editorkey').AsInteger;
      Result.XID := SQL.FieldByName('xid').AsInteger;
      Result.DBID := SQL.FieldByName('dbid').AsInteger;
    end;

  finally
    SQL.Free;
  end;
end;

function  GetRUIDStringByID(const ID: Integer; const Tr: TIBTransaction): TRUIDString;
var
  RUID: TRUID;
  RUIDRec: TRUIDRec;
begin
  RUIDRec := GetRUIDRecByID(ID, Tr);
  RUID.XID := RUIDRec.XID;
  RUID.DBID := RUIDRec.DBID;
  Result := RUIDToStr(RUID);
end;

procedure AddFinVersion(const ID: Integer; const NumVersion, Comment, DateOper: String;
  const Tr: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Tr;
    ibsql.SQL.Text := Format('UPDATE OR INSERT INTO fin_versioninfo ' +
      'VALUES (%d, ''%s'', ''%s'', ''%s'') MATCHING (id) ',
      [ID, NumVersion, DateOper, Comment]);
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;


end.
