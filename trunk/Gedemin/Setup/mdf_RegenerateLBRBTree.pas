
unit mdf_RegenerateLBRBTree;

interface

uses
  IBDatabase, gdModify;

procedure RegenerateLBRBTree(IBDB: TIBDatabase; Log: TModifyLog);
procedure DropRGIndex(IBDB: TIBDatabase; Log: TModifyLog);
procedure CreateRGIndex(IBDB: TIBDatabase; Log: TModifyLog);

procedure RegenerateLBRBTree2(IBDB: TIBDatabase; Log: TModifyLog);

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
    '    NEW.name = ''<'' || NEW.id || ''>''; '#13#10 +
    ' '#13#10 +
    '  IF (NEW.CONTACTTYPE = 0 OR NEW.contacttype = 4) THEN '#13#10 +
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

        FIBSQL.SQL.Text := c_trigger;
        FIBSQL.ExecQuery;

        DropTrigger2('RP_BEFORE_UPDATE_REPORTGROUP', FTransaction);
        DropTrigger2('RP_BEFORE_UPDATE10_REPORTGROUP', FTransaction);
        DropTrigger2('RP_BEFORE_INSERT10_REPORTGROUP', FTransaction);
        DropTrigger2('RP_BI_REPORTGROUP10', FTransaction);
        DropTrigger2('RP_BU_REPORTGROUP10', FTransaction);

        DropProcedure2('RP_P_RESTRUCT_REPORTGROUP', FTransaction);
        DropProcedure2('RP_P_GCHC_REPORTGROUP', FTransaction);
        DropProcedure2('RP_P_EL_REPORTGROUP', FTransaction);
        DropProcedure2('RP_P_CHECKGROUPTREE', FTransaction);

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_reportgroup_trigger;
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        _Log := Log;
        UpdateLBRBTreeBase(FTransaction, True, _Writeln);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (120, ''0000.0001.0000.0151'', ''22.06.2010'', ''Added locking into LBRB tree'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE rp_reportgroup r SET r.name = SUBSTRING(r.name FROM 1 FOR 50) || r.id ' +
          'WHERE EXISTS (SELECT r2.* FROM rp_reportgroup r2 ' +
          '  WHERE r2.id > r.id AND r2.parent IS NOT DISTINCT FROM r.parent ' +
          '  AND UPPER(r2.name) = UPPER(r.name))';
        FIBSQL.ExecQuery;

        if FIBSQL.RowsAffected > 0 then
          Log('Исправлено дублирующихся имен групп отчетов: ' + IntToStr(FIBSQL.RowsAffected));
      finally
        FIBSQL.Free;
      end;

      RestrLBRBTree('', FTransaction);
      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure RegenerateLBRBTree2(IBDB: TIBDatabase; Log: TModifyLog);
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

        FIBSQL.SQL.Text := c_trigger;
        FIBSQL.ExecQuery;

        _Log := Log;
        UpdateLBRBTreeBase(FTransaction, True, _Writeln);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (125, ''0000.0001.0000.0156'', ''29.09.2010'', ''Strategy for LB-RB tree widening has been changed'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure DropRGIndex(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text := 'SELECT rdb$index_name FROM rdb$index_segments ' +
          'WHERE rdb$index_name = ''RP_X_REPORTGROUP_LRN'' AND rdb$field_name = ''LB'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
          DropIndex2('RP_X_REPORTGROUP_LRN', FTransaction);

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (123, ''0000.0001.0000.0154'', ''23.08.2010'', ''Correct rp_x_reportgroup_lrn index'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure CreateRGIndex(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.SQL.Text :=
          'UPDATE rp_reportgroup r SET r.name = SUBSTRING(r.name FROM 1 FOR 50) || r.id ' +
          'WHERE EXISTS (SELECT r2.* FROM rp_reportgroup r2 ' +
          '  WHERE r2.id > r.id AND r2.parent IS NOT DISTINCT FROM r.parent ' +
          '  AND UPPER(r2.name) = UPPER(r.name))';
        FIBSQL.ExecQuery;

        if FIBSQL.RowsAffected > 0 then
          Log('Исправлено дублирующихся имен групп отчетов: ' + IntToStr(FIBSQL.RowsAffected));

        FTransaction.Commit;
        FTransaction.StartTransaction;

        if not IndexExist2('RP_X_REPORTGROUP_LRN', FTransaction) then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'CREATE UNIQUE INDEX rp_x_reportgroup_lrn ON rp_reportgroup (name, parent)';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (124, ''0000.0001.0000.0155'', ''23.08.2010'', ''Correct rp_x_reportgroup_lrn index #2'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message);
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
