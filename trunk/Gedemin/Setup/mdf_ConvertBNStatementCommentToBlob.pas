unit mdf_ConvertBNStatementCommentToBlob;

interface

uses
  IBDatabase, gdModify;

procedure ConvertBNStatementCommentToBlob(IBDB: TIBDatabase; Log: TModifyLog);
procedure ConvertDatePeriodComponent(IBDB: TIBDatabase; Log: TModifyLog);
procedure UpdateGDRefConstraints(IBDB: TIBDatabase; Log: TModifyLog);
procedure AlterUserStorageTrigger(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddGDRUIDCheck(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyRUIDProcedure(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyGDRUIDCheck(IBDB: TIBDatabase; Log: TModifyLog);
procedure DeleteLBRBFromSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
procedure RefineTriggersForEntry(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit, jclStrings,
  gdcLBRBTreeMetadata;

procedure ModifyRUIDProcedure(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER PROCEDURE GD_P_GETRUID(ID INTEGER) '#13#10 +
        '  RETURNS (XID INTEGER, DBID INTEGER) '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  XID = NULL; '#13#10 +
        '  DBID = NULL; '#13#10 +
        ' '#13#10 +
        '  IF (NOT :ID IS NULL) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (:ID < 147000000) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      XID = :ID; '#13#10 +
        '      DBID = 17; '#13#10 +
        '    END ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      SELECT xid, dbid '#13#10 +
        '      FROM gd_ruid '#13#10 +
        '      WHERE id=:ID '#13#10 +
        '      INTO :XID, :DBID; '#13#10 +
        ' '#13#10 +
        '      IF (XID IS NULL) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        XID = ID; '#13#10 +
        '        DBID = GEN_ID(gd_g_dbid, 0); '#13#10 +
        ' '#13#10 +
        '        INSERT INTO gd_ruid(id, xid, dbid, modified, editorkey) '#13#10 +
        '          VALUES(:ID, :XID, :DBID, CURRENT_TIMESTAMP, NULL); '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  SUSPEND; '#13#10 +
        'END ';

      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (132, ''0000.0001.0000.0163'', ''28.03.2011'', ''Modify GD_P_GETRUID procedure.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure AddGDRUIDCheck(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (131, ''0000.0001.0000.0162'', ''24.03.2011'', ''Check to GD_RUID table added.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure DeleteLBRBFromSettingPos(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  SL: TStringList;
  I, K: Integer;
  Names: TLBRBTreeMetaNames;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  SL := TStringList.Create;
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;

      FIBSQL.SQL.Text := 'DELETE FROM at_settingpos WHERE objectname = :obj';
      FIBSQL.Prepare;

      GetLBRBTreeList('', FTransaction, SL);

      K := 0;
      for I := 0 to SL.Count - 1 do
      begin
        GetLBRBTreeDependentNames(SL[I], FTransaction, Names);

        FIBSQL.ParamByName('obj').AsString := Names.ChldCtName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.ExLimName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.RestrName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.BITriggerName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.BUTriggerName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.LBIndexName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.RBIndexName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;

        FIBSQL.ParamByName('obj').AsString := Names.ChkName;
        FIBSQL.ExecQuery;
        K := K + FIBSQL.RowsAffected;
      end;

      if K > 0 then
        Log('Удалено метаданных инт. деревьев из at_settingpos: ' + IntToStr(K));

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (134, ''0000.0001.0000.0165'', ''10.05.2011'', ''Delete lbrb tree elements from at_settingpos.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    SL.Free;
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure RefineTriggersForEntry(IBDB: TIBDatabase; Log: TModifyLog);
const
  c_ac_bi_record =
    'CREATE OR ALTER TRIGGER ac_bi_record FOR ac_record'#13#10 +
    '  BEFORE INSERT'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE S VARCHAR(255);'#13#10 +
    'BEGIN'#13#10 +
    '  IF (NEW.ID IS NULL) THEN'#13#10 +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);'#13#10 +
    ''#13#10 +
    '  NEW.debitncu = 0;'#13#10 +
    '  NEW.debitcurr = 0;'#13#10 +
    '  NEW.creditncu = 0;'#13#10 +
    '  NEW.creditcurr = 0;'#13#10 +
    ''#13#10 +
    '  NEW.incorrect = 1;'#13#10 +
    '  S = COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT''), '''');'#13#10 +
    '  IF (CHAR_LENGTH(:S) >= 240 OR :S = ''TM'') THEN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', ''TM'');'#13#10 +
    '  ELSE'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', :S || '','' || NEW.id);'#13#10 +
    'END';

  c_ac_bu_record =
    'CREATE OR ALTER TRIGGER ac_bu_record FOR ac_record'#13#10 +
    '  BEFORE UPDATE'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE WasUnlock INTEGER;'#13#10 +
    '  DECLARE VARIABLE S VARCHAR(255);'#13#10 +
    'BEGIN'#13#10 +
    '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'') IS NULL) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.debitncu = OLD.debitncu;'#13#10 +
    '    NEW.creditncu = OLD.creditncu;'#13#10 +
    '    NEW.debitcurr = OLD.debitcurr;'#13#10 +
    '    NEW.creditcurr = OLD.creditcurr;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.debitncu IS DISTINCT FROM OLD.debitncu OR'#13#10 +
    '    NEW.creditncu IS DISTINCT FROM OLD.creditncu OR'#13#10 +
    '    NEW.debitcurr IS DISTINCT FROM OLD.debitcurr OR'#13#10 +
    '    NEW.creditcurr IS DISTINCT FROM OLD.creditcurr) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.incorrect = IIF((NEW.debitncu IS DISTINCT FROM NEW.creditncu)'#13#10 +
    '      OR (NEW.debitcurr IS DISTINCT FROM NEW.creditcurr), 1, 0);'#13#10 +
    '  END ELSE'#13#10 +
    '    NEW.incorrect = OLD.incorrect;'#13#10 +
    ''#13#10 +
    '  IF (NEW.incorrect = 1 AND OLD.incorrect = 0) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    S = COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT''), '''');'#13#10 +
    '    IF (CHAR_LENGTH(:S) >= 240 OR :S = ''TM'') THEN'#13#10 +
    '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', ''TM'');'#13#10 +
    '    ELSE'#13#10 +
    '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', :S || '','' || NEW.id);'#13#10 +
    '  END'#13#10 +
    '  ELSE IF (NEW.incorrect = 0 AND OLD.incorrect = 1) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    S = COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT''), '''');'#13#10 +
    '    S = REPLACE(:S, '','' || NEW.id, '''');'#13#10 +
    '    IF (:S = '''') THEN'#13#10 +
    '      S = NULL;'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', :S);'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.recorddate <> OLD.recorddate'#13#10 +
    '    OR NEW.transactionkey <> OLD.transactionkey'#13#10 +
    '    OR NEW.documentkey <> OLD.documentkey'#13#10 +
    '    OR NEW.masterdockey <> OLD.masterdockey'#13#10 +
    '    OR NEW.companykey <> OLD.companykey) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    WasUnlock = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'');'#13#10 +
    '    IF (:WasUnlock IS NULL) THEN'#13#10 +
    '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', 1);'#13#10 +
    '    UPDATE ac_entry e'#13#10 +
    '    SET e.entrydate = NEW.recorddate,'#13#10 +
    '      e.transactionkey = NEW.transactionkey,'#13#10 +
    '      e.documentkey = NEW.documentkey,'#13#10 +
    '      e.masterdockey = NEW.masterdockey,'#13#10 +
    '      e.companykey = NEW.companykey'#13#10 +
    '    WHERE'#13#10 +
    '      e.recordkey = NEW.id;'#13#10 +
    '    IF (:WasUnlock IS NULL) THEN'#13#10 +
    '      RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', NULL);'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  WHEN ANY DO'#13#10 +
    '  BEGIN'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_ENTRY_UNLOCK'', NULL);'#13#10 +
    '    EXCEPTION;'#13#10 +
    '  END'#13#10 +
    'END';

  c_ac_ad_record =
    'CREATE OR ALTER TRIGGER ac_ad_record FOR ac_record'#13#10 +
    '  AFTER DELETE'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE S VARCHAR(255);'#13#10 +
    'BEGIN'#13#10 +
    '  IF (OLD.incorrect = 1) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    S = COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT''), '''');'#13#10 +
    '    S = REPLACE(:S, '','' || OLD.id, '''');'#13#10 +
    '    IF (:S = '''') THEN'#13#10 +
    '      S = NULL;'#13#10 +
    '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_INCORRECT'', :S);'#13#10 +
    '  END'#13#10 +
    'END';

  c_ac_bi_entry = '';

  c_ac_ai_entry = '';

  c_ac_bu_entry = '';

  c_ac_au_entry = '';

  c_ac_ad_entry = '';

var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      FIBSQL.SQL.Text :=
        'UPDATE rdb$functions SET rdb$module_name = ''gudf'' WHERE UPPER(rdb$module_name) = ''GUDF.DLL'' ';
      FIBSQL.ExecQuery;  

      DropTrigger2('AC_BI_ENTRY', FTransaction);
      DropTrigger2('AC_BI_ENTRY_ENTRYDATE', FTransaction);
      DropTrigger2('AC_BI_ENTRY_ISSIMPLE', FTransaction);
      DropTrigger2('AC_BI_ENTRY_RECORD', FTransaction);

      DropTrigger2('AC_AI_ENTRY', FTransaction);

      DropTrigger2('AC_BU_ENTRY', FTransaction);
      DropTrigger2('AC_BU_ENTRY_ISSIMPLE', FTransaction);
      DropTrigger2('AC_BU_ENTRY_RECORD', FTransaction);

      DropTrigger2('AC_AU_ENTRY', FTransaction);
      
      DropTrigger2('AC_AD_ENTRY', FTransaction);
      DropTrigger2('AC_AD_ENTRY_ISSIMPLE', FTransaction);
      DropTrigger2('AC_AD_ENTRY_DELETERECORD', FTransaction);

      DropTrigger2('AC_BI_RECORD', FTransaction);
      DropTrigger2('AC_BU_RECORD', FTransaction);

      DropException2('AC_E_ENTRYBEFOREDOCUMENT', FTransaction);

      FIBSQL.SQL.Text := c_ac_bi_record;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_bu_record;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_bi_entry;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_ai_entry;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_bu_entry;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_au_entry;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text := c_ac_ad_entry;
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (135, ''0000.0001.0000.0166'', ''11.05.2011'', ''Refined triggers for AC_ENTRY, AC_RECORD.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure ModifyGDRUIDCheck(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      {FIBSQL.SQL.Text := 'UPDATE gd_ruid r SET dbid = 17 WHERE xid < 147000000 AND dbid <> 17 and NOT EXISTS (SELECT * FROM gd_ruid r1 WHERE r1.xid = r.xid and r1.dbid = 17) ';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'DELETE FROM gd_ruid r WHERE xid < 147000000 AND dbid <> 17 ';
      FIBSQL.ExecQuery;}


      if ConstraintExist2('GD_RUID', 'GD_CHK_RUID_ETALON', FTransaction) then
      begin
        FIBSQL.SQL.Text := 'ALTER TABLE gd_ruid DROP CONSTRAINT gd_chk_ruid_etalon ';
        FIBSQL.ExecQuery;
      end;

      FIBSQL.SQL.Text := 'ALTER TABLE gd_ruid ADD CONSTRAINT gd_chk_ruid_etalon ' +
        'CHECK((xid >= 147000000) OR ((dbid = 17) AND (id = xid)))';
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (133, ''0000.0001.0000.0164'', ''02.04.2011'', ''Check for GD_RUID table modified.'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure ConvertBNStatementCommentToBlob(IBDB: TIBDatabase; Log: TModifyLog);
const
  STATEMENT_RELATION_NAME = 'BN_BANKSTATEMENTLINE';
  COMMENT_FIELD_NAME      = 'COMMENT';
  NEW_DOMAIN_NAME         = 'DBLOBTEXT80_1251';
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  I: Integer;
  TempCommentFieldName: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      // Ищем подходящее имя временного поля
      for I := 0 to 999 do
      begin
        TempCommentFieldName := COMMENT_FIELD_NAME + IntToStr(I);
        if FieldExist2(STATEMENT_RELATION_NAME, TempCommentFieldName, FTransaction) then
          TempCommentFieldName := ''
        else
          Break;
      end;

      if TempCommentFieldName = '' then
        raise Exception.Create('Невозможно переименовать поле в ' + STATEMENT_RELATION_NAME);

      FIBSQL.SQL.Text := 'ALTER TABLE ' + STATEMENT_RELATION_NAME  +
        ' ALTER ' + COMMENT_FIELD_NAME + ' TO ' + TempCommentFieldName;
      FIBSQL.ExecQuery;

      FTransaction.Commit;
      FTransaction.StartTransaction;

      // Добавим поле с новым типом данных
      AddField2(STATEMENT_RELATION_NAME, COMMENT_FIELD_NAME, NEW_DOMAIN_NAME, FTransaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      FIBSQL.SQL.Text := 'UPDATE ' + STATEMENT_RELATION_NAME + ' SET ' +
        COMMENT_FIELD_NAME + '=' + TempCommentFieldName;
      FIBSQL.ExecQuery;

      // Удалим временное поле
      DropField2(STATEMENT_RELATION_NAME, TempCommentFieldName, FTransaction);

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (126, ''0000.0001.0000.0157'', ''05.11.2010'', ''Relation field BN_BANKSTATEMENTLINE.COMMENT has been extended'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure ConvertDatePeriodComponent(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, qUpdate: TIBSQL;
  SL: TStringList;
  S: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  qUpdate := TIBSQL.Create(nil);
  SL := TStringList.Create;
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      qUpdate.Transaction := FTransaction;

      qUpdate.SQL.Text := 'UPDATE gd_function SET script = :s WHERE id = :id';

      FIBSQL.SQL.Text := 'SELECT id, script FROM gd_function';
      FIBSQL.ExecQuery;

      while not FIBSQL.EOF do
      begin
        S := FIBSQL.FieldByName('script').AsString;

        S := StringReplace(S, 'F.FindComponent("xdeStart").Text = Params(0)', 'F.DateBegin = Params(0)',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'F.FindComponent("xdeFinish").Text = Params(1)', 'F.DateEnd = Params(1)',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'F.FindComponent("xdeStart").Date = BeginDate', 'F.DateBegin = BeginDate',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'F.FindComponent("xdeFinish").Date = EndDate', 'F.DateEnd = EndDate',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'OwnerForm.FindComponent("xdeStart").Text +', 'OwnerForm.DateBegin &',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'OwnerForm.FindComponent("xdeFinish").Text +', 'OwnerForm.DateEnd &',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'OwnerForm.GetComponent("xdeStart").Text +', 'OwnerForm.DateBegin &',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'OwnerForm.GetComponent("xdeFinish").Text +', 'OwnerForm.DateEnd &',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, '+ OwnerForm.GetComponent("xdeFinish").Text', '& OwnerForm.DateEnd',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, '+ OwnerForm.FindComponent("xdeFinish").Text', '& OwnerForm.DateEnd',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'AccountForm.GetComponent("xdeStart").Date =', 'AccountForm.DateBegin =',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'AccountForm.GetComponent("xdeFinish").Date =', 'AccountForm.DateEnd =',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'a(1) = OwnerForm.FindComponent("xdeStart").Text', 'a(1) = OwnerForm.DateBegin',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'a(2) = OwnerForm.FindComponent("xdeFinish").Text', 'a(2) = OwnerForm.DateEnd',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'DateBegin = OwnerForm.FindComponent("xdeStart").date', 'DateBegin = OwnerForm.DateBegin',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'DateEnd = OwnerForm.FindComponent("xdeFinish").date', 'DateEnd = OwnerForm.DateEnd',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S, 'F.FindComponent("xdeStart").Date = "01/01/2000"', 'F.DateBegin = DateSerial(2000, 1, 1)',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'F.FindComponent("xdeFinish").Date = Date', 'F.DateEnd = Date',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, 'F.FindComponent("xdeStart").Date = Date', 'F.DateBegin = Date',
          [rfReplaceAll, rfIgnoreCase]);

        S := StringReplace(S,
          'AdditionalInfo.FieldByName("DateBegin").AsString = OwnerForm.FindComponent("xdeStart").Text',
          'AdditionalInfo.FieldByName("DateBegin").AsDateTime = OwnerForm.DateBegin',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S,
          'AdditionalInfo.FieldByName("DateEnd").AsString = OwnerForm.FindComponent("xdeFinish").Text',
          'AdditionalInfo.FieldByName("DateEnd").AsDateTime = OwnerForm.DateEnd',
          [rfReplaceAll, rfIgnoreCase]);

        if StrIPos('DateBegin = DateSerial(Year, Month, 1)', S) > 0 then
        begin
          S := StringReplace(S, 'OwnerForm.FindComponent("xdeStart").date = DateBegin', 'OwnerForm.DateBegin = DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'OwnerForm.FindComponent("xdeFinish").date = DateEnd', 'OwnerForm.DateEnd = DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        if StrIPos('a(2) = xdeStart.Text + " - " + xdeFinish.Text', S) > 0 then
        begin
          S := StringReplace(S, 'set xdeStart = OwnerForm.FindComponent("xdeStart")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'set xdeFinish = OwnerForm.FindComponent("xdeFinish")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'a(2) = xdeStart.Text + " - " + xdeFinish.Text', 'a(2) = OwnerForm.DateBegin & " - " & OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        if StrIPos('IBDataSet.ParamByName("begindate").AsDateTime = xdeStart.Date', S) > 0 then
        begin
          S := StringReplace(S, 'set xdeStart = Sender.OwnerForm.FindComponent("xdeStart")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'set xdeFinish = Sender.OwnerForm.FindComponent("xdeFinish")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'IBDataSet.ParamByName("begindate").AsDateTime = xdeStart.Date',
            'IBDataSet.ParamByName("begindate").AsDateTime = Sender.OwnerForm.DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'IBDataSet.ParamByName("enddate").AsDateTime = xdeFinish.Date',
            'IBDataSet.ParamByName("enddate").AsDateTime = Sender.OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        if StrIPos('DataSet.ParamByName("begindate").AsDateTime = xdeStart.Date', S) > 0 then
        begin
          S := StringReplace(S, 'set xdeStart = Sender.OwnerForm.FindComponent("xdeStart")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'set xdeFinish = Sender.OwnerForm.FindComponent("xdeFinish")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'DataSet.ParamByName("begindate").AsDateTime = xdeStart.Date',
            'DataSet.ParamByName("begindate").AsDateTime = Sender.OwnerForm.DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'DataSet.ParamByName("enddate").AsDateTime = xdeFinish.Date',
            'DataSet.ParamByName("enddate").AsDateTime = Sender.OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        if StrIPos('SQL.ParamByName("datebegin").AsDateTime = xdeStart.DateTime', S) > 0 then
        begin
          S := StringReplace(S, 'set xdeStart = OwnerForm.FindComponent("xdeStart")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'set xdeFinish = OwnerForm.FindComponent("xdeFinish")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'SQL.ParamByName("datebegin").AsDateTime = xdeStart.DateTime',
            'SQL.ParamByName("datebegin").AsDateTime = OwnerForm.DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'SQL.ParamByName("dateend").AsDateTime = xdeFinish.DateTime',
            'SQL.ParamByName("dateend").AsDateTime = OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        if StrIPos('q.ParamByName("begindate").AsDateTime = xdeStart.Date', S) > 0 then
        begin
          S := StringReplace(S, 'set xdeStart = OwnerForm.FindComponent("xdeStart")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'set xdeFinish = OwnerForm.FindComponent("xdeFinish")', '',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'q.ParamByName("begindate").AsDateTime = xdeStart.Date',
            'q.ParamByName("begindate").AsDateTime = OwnerForm.DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'q.ParamByName("enddate").AsDateTime = xdeFinish.Date',
            'q.ParamByName("enddate").AsDateTime = OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'Addition.FieldByName("datebegin").AsDateTime = xdeStart.Date',
            'Addition.FieldByName("datebegin").AsDateTime = OwnerForm.DateBegin',
            [rfReplaceAll, rfIgnoreCase]);
          S := StringReplace(S, 'Addition.FieldByName("dateend").AsDateTime = xdeFinish.Date',
            'Addition.FieldByName("dateend").AsDateTime = OwnerForm.DateEnd',
            [rfReplaceAll, rfIgnoreCase]);
        end;

        S := StringReplace(S, '"за период с " +', '"за период с " &',
          [rfReplaceAll, rfIgnoreCase]);
        S := StringReplace(S, '" по " +', '" по " &',
          [rfReplaceAll, rfIgnoreCase]);

        if (FIBSQL.FieldByName('script').AsString <> S) then
        begin
          qUpdate.ParamByName('id').AsInteger := FIBSQL.FieldByName('id').AsInteger;
          qUpdate.ParamByName('s').AsString := S;
          qUpdate.ExecQuery;
        end;

        FIBSQL.Next;
      end;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'delete from gd_storage_data where name containing ''xdeStart(TxDateEdit)'' ';
      FIBSQL.ExecQuery;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'delete from gd_storage_data where name containing ''xdeFinish(TxDateEdit)'' ';
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (127, ''0000.0001.0000.0158'', ''08.11.2010'', ''Replacing references to xdeStart, xdeFinish components across macros'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (128, ''0000.0001.0000.0159'', ''16.11.2010'', ''Replacing references to xdeStart, xdeFinish components across macros #2'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    SL.Free;
    qUpdate.Free;
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure UpdateGDRefConstraints(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;

      FIBSQL.SQL.Text := 'ALTER TABLE gd_ref_constraints ALTER ' +
        '  constraint_uq_count COMPUTED BY (( '#13#10 +
        '    SELECT '#13#10 +
        '      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5)) '#13#10 +
        '    FROM '#13#10 +
        '      rdb$indices i '#13#10 +
        '      JOIN rdb$index_segments iseg '#13#10 +
        '        ON iseg.rdb$index_name = i.rdb$index_name '#13#10 +
        '      JOIN rdb$relation_constraints rc '#13#10 +
        '        ON rc.rdb$index_name = i.rdb$index_name '#13#10 +
        '    WHERE '#13#10 +
        '      iseg.rdb$field_name = constraint_field '#13#10 +
        '      AND i.rdb$segment_count = 1 '#13#10 +
        '      AND rc.rdb$constraint_name = constraint_name '#13#10 +
        '      AND rc.rdb$constraint_type = ''FOREIGN KEY'' '#13#10 +
        '  ))';
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (129, ''0000.0001.0000.0160'', ''17.11.2010'', ''Fixed field constraint_uq_count in GD_REF_CONSTRAINTS'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

procedure AlterUserStorageTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;

      if not ExceptionExist2('gd_e_block_old_storage', FTransaction) then
      begin
        FIBSQL.SQL.Text :=
          'CREATE EXCEPTION gd_e_block_old_storage ''Изменение старых данных пользовательского хранилища заблокировано'' ';
        FIBSQL.ExecQuery;
      end;

      DropTrigger2('gd_biud_userstorage', FTransaction);

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_biu_userstorage FOR gd_userstorage '#13#10 +
        '  BEFORE INSERT OR UPDATE /* OR DELETE */ '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  EXCEPTION gd_e_block_old_storage ''Изменение старых данных пользовательского хранилища заблокировано''; '#13#10 +
        'END ';
      FIBSQL.ExecQuery;

      DropTrigger2('gd_biud_companystorage', FTransaction);

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_biu_companystorage FOR gd_companystorage '#13#10 +
        '  BEFORE INSERT OR UPDATE /* OR DELETE */ '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  EXCEPTION gd_e_block_old_storage ''Изменение старых данных хранилища компании заблокировано''; '#13#10 +
        'END ';
      FIBSQL.ExecQuery;

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (130, ''0000.0001.0000.0161'', ''19.11.2010'', ''Change gd_user_storage trigger'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

end.
