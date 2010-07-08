
unit mdf_RegenerateLBRBTree;

interface

uses
  IBDatabase, gdModify;

procedure RegenerateLBRBTree(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit, gdcLBRBTreeMetaData;

const
  c_trigger =
    'ALTER TRIGGER gd_bi_contact'#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    ' '#13#10 +
    '  IF (NEW.name IS NULL) THEN '#13#10 +
    '    NEW.name = ''''; '#13#10 +
    ' '#13#10 +
    '  IF (NEW.CONTACTTYPE = 0) THEN '#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''100''); '#13#10 +
    '  ELSE '#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''1''); '#13#10 +
    'END ';

  c_reportgroup_trigger =
    'RECREATE TRIGGER rp_before_insert_reportgroup FOR rp_reportgroup '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    ' '#13#10 +
    '  IF (NEW.usergroupname IS NULL) THEN '#13#10 +
    '    NEW.usergroupname = CAST(NEW.id AS varchar(60)); '#13#10 +
    ' '#13#10 +
    '  RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''100''); '#13#10 +
    'END ';

var
  _Log: TModifyLog;

procedure _Writeln(const S: String);
begin
  Assert(Assigned(_Log));
  _Log(S);
end;

procedure RegenerateLBRBTree(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_trigger;
        FIBSQL.ExecQuery;

        DropTrigger2('RP_BEFORE_UPDATE_REPORTGROUP', FTransaction);
        DropTrigger2('RP_BEFORE_UPDATE10_REPORTGROUP', FTransaction);
        DropTrigger2('RP_BEFORE_INSERT10_REPORTGROUP', FTransaction);
        DropProcedure2('RP_P_CHECKGROUPTREE', FTransaction);

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_reportgroup_trigger;
        FIBSQL.ExecQuery;

        _Log := Log;
        UpdateLBRBTreeBase(FTransaction, True, _Writeln);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (120, ''0000.0001.0000.0151'', ''22.06.2010'', ''Added locking into LBRB tree'')';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
      FTransaction.StartTransaction;

      RestrLBRBTree('', FTransaction);
      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
