
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
    '  IF (NEW.CONTACTTYPE = 0 OR NEW.CONTACTTYPE = 3) THEN '#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''1000''); '#13#10 +
    '  ELSE '#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''10''); '#13#10 +
    'END ';

  c_reportgroup_trigger =
    'RECREATE TRIGGER rp_before_insert_reportgroup FOR rp_reportgroup '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    '  IF (NEW.usergroupname IS NULL) THEN '#13#10 +
    '    NEW.usergroupname = CAST(NEW.id AS varchar(60)); '#13#10 +
    ' '#13#10 +
    '  RDB$SET_CONTEXT(''USER_TRANSACTION'', ''LBRB_DELTA'', ''1000''); '#13#10 +
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

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''RP_P_CHECKGROUPTREE'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP PROCEDURE RP_P_CHECKGROUPTREE ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''RP_BEFORE_UPDATE_REPORTGROUP'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP TRIGGER RP_BEFORE_UPDATE_REPORTGROUP ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''RP_BEFORE_INSERT10_REPORTGROUP'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP TRIGGER RP_BEFORE_INSERT10_REPORTGROUP ';
          FIBSQL.ExecQuery;
        end;

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
