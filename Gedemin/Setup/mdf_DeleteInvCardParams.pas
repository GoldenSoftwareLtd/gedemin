
unit mdf_DeleteInvCardParams;

interface

uses
  Classes, IBDatabase, gdModify, IBSQL, SysUtils;

procedure DeleteCardParamsItem(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddNSMetadata(IBDB: TIBDatabase; Log: TModifyLog);
procedure Issue2846(IBDB: TIBDatabase; Log: TModifyLog);
procedure Issue2688(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddUqConstraintToGD_RUID(IBDB: TIBDatabase; Log: TModifyLog);
procedure DropConstraintFromAT_OBJECT(IBDB: TIBDatabase; Log: TModifyLog);
procedure MoveSubObjects(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddUqConstraintToGD_RUID2(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddCurrModified(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddEditionDate(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectNSTriggers(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddEditionDate2(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddADAtObjectTrigger(IBDB: TIBDatabase; Log: TModifyLog);
procedure SetDefaultForAccountType(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddGdObjectDependencies(IBDB: TIBDatabase; Log: TModifyLog);
procedure Issue1041(IBDB: TIBDatabase; Log: TModifyLog);
procedure Issue3218(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddNSSyncTables(IBDB: TIBDatabase; Log: TModifyLog);
procedure ChangeAcLedgerAccounts(IBDB: TIBDatabase; Log: TModifyLog);
procedure RUIDsForGdStorageData(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddAtNamespaceChanged(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectDocumentType(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectEntryTriggers(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectAutoEntryScript(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Windows, mdf_metadata_unit, mdf_ConvertStorage;

procedure AddAtNamespaceChanged(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;

      if not FieldExist2('at_namespace', 'changed', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE at_namespace ADD changed dboolean_notnull DEFAULT 1';
        q.ExecQuery;

        Tr.Commit;
        Tr.StartTransaction;

        q.SQL.Text := 'UPDATE at_namespace SET changed = 0';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_aiud_object FOR at_object '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER INSERT OR UPDATE OR DELETE '#13#10 +
        '  POSITION 20000 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (INSERTING OR UPDATING) THEN '#13#10 +
        '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
        '      AND n.id = NEW.namespacekey; '#13#10 +
        ' '#13#10 +
        '  IF (UPDATING OR DELETING) THEN '#13#10 +
        '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
        '      AND n.id = OLD.namespacekey; '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_aiud_namespace_link FOR at_namespace_link '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER INSERT OR UPDATE OR DELETE '#13#10 +
        '  POSITION 20000 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (INSERTING) THEN '#13#10 +
        '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
        '      AND n.id = NEW.namespacekey; '#13#10 +
        ' '#13#10 +
        '  IF (UPDATING) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (NEW.namespacekey <> OLD.namespacekey OR NEW.useskey <> OLD.useskey) THEN '#13#10 +
        '      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
        '        AND (n.id = NEW.namespacekey OR n.id = OLD.namespacekey); '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  IF (DELETING) THEN '#13#10 +
        '    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0 '#13#10 +
        '      AND n.id = OLD.namespacekey; '#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (196, ''0000.0001.0000.0227'', ''29.11.2013'', ''Field changed added to at_namespace.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_file '#13#10 +
        '  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate) '#13#10 +
        'VALUES '#13#10 +
        '  (4000001, NULL, ''D'', ''_Справка'', 650002, ''01.01.2000'', 650002, ''01.01.2000'')'#13#10 +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_file '#13#10 +
        '  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate) '#13#10 +
        'VALUES '#13#10 +
        '  (4000002, 4000001, ''D'', ''_Классы'', 650002, ''01.01.2000'', 650002, ''01.01.2000'')'#13#10 +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_file '#13#10 +
        '  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate) '#13#10 +
        'VALUES '#13#10 +
        '  (4000003, 4000002, ''D'', ''_Система'', 650002, ''01.01.2000'', 650002, ''01.01.2000'')'#13#10 +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_file '#13#10 +
        '  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate) '#13#10 +
        'VALUES '#13#10 +
        '  (4000004, 4000002, ''D'', ''_Пользователь'', 650002, ''01.01.2000'', 650002, ''01.01.2000'')'#13#10 +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (197, ''0000.0001.0000.0228'', ''13.12.2013'', ''Help folders added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure CorrectDocumentType(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  RA: Integer;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;

      q.SQL.Text :=
        'UPDATE rp_reportgroup r SET r.name = SUBSTRING(r.name FROM 1 FOR 50) || r.id ' +
        'WHERE EXISTS (SELECT r2.* FROM rp_reportgroup r2 ' +
        '  WHERE r2.id > r.id AND r2.parent IS NOT DISTINCT FROM r.parent ' +
        '  AND UPPER(r2.name) = UPPER(r.name))';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE rdb$fields SET rdb$field_sub_type = 0 ' +
        'WHERE rdb$field_name = ''DBMP'' AND rdb$field_sub_type <> 0';
      try
        q.ExecQuery;
      except
        // на FB 3 не пройдет
      end;

      q.SQL.Text :=
        'UPDATE rdb$fields SET rdb$field_sub_type = 0 ' +
        'WHERE rdb$field_name = ''DRTF'' AND rdb$field_sub_type <> 0';
      try
        q.ExecQuery;
      except
        // на FB 3 не пройдет
      end;

      if TriggerExist2('gd_au_documenttype', Tr) then
      begin
        q.SQL.Text := 'ALTER TRIGGER gd_au_documenttype INACTIVE';
        q.ExecQuery;
      end;

      q.SQL.Text := 'ALTER TRIGGER gd_au_goodgroup_protect INACTIVE';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      q.SQL.Text :=
        'UPDATE gd_goodgroup ' +
        'SET parent = COALESCE((SELECT g.id FROM gd_goodgroup g JOIN gd_ruid r ' +
        '  ON r.id = g.id WHERE r.xid=147005904 AND r.dbid=63934951), parent) ' +
        'WHERE id = (SELECT id FROM gd_ruid WHERE xid=147006033 AND dbid=63934951)';
      q.ExecQuery;

      RA := 0;

      q.SQL.Text := 'UPDATE gd_documenttype SET classname = '''', parent=806000 WHERE id=806001';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE gd_documenttype SET parent=804000 ' +
        'WHERE lb > (SELECT lb FROM gd_documenttype WHERE id = 805000) ' +
        '  AND rb <= (SELECT rb FROM gd_documenttype WHERE id = 805000) AND documenttype = ''D'' ' +
        '  AND classname <> ''TgdcInvPriceListType'' ';
      q.ExecQuery;
      Inc(RA, q.RowsAffected);

      q.SQL.Text :=
        'UPDATE gd_documenttype SET parent=804000 ' +
        'WHERE (lb < (SELECT lb FROM gd_documenttype WHERE id = 804000) ' +
        '  OR lb > (SELECT rb FROM gd_documenttype WHERE id = 804000)) AND documenttype = ''D'' ' +
        '  AND classname = ''TgdcInvDocumentType'' ';
      q.ExecQuery;
      Inc(RA, q.RowsAffected);

      q.SQL.Text :=
        'UPDATE gd_documenttype SET parent=801000 ' +
        'WHERE lb > (SELECT lb FROM gd_documenttype WHERE id = 804000) ' +
        '  AND rb <= (SELECT rb FROM gd_documenttype WHERE id = 804000) AND documenttype = ''D'' ' +
        '  AND classname <> ''TgdcInvDocumentType'' ';
      q.ExecQuery;
      Inc(RA, q.RowsAffected);

      if RA > 0 then
        Log('Перемещено типов документов: ' + IntToStr(RA));

      if TriggerExist2('gd_au_documenttype', Tr) then
      begin
        q.SQL.Text := 'ALTER TRIGGER gd_au_documenttype ACTIVE';
        q.ExecQuery;
      end;

      q.SQL.Text := 'ALTER TRIGGER gd_au_goodgroup_protect ACTIVE';
      q.ExecQuery;

      q.SQL.Text :=
        'DELETE FROM evt_objectevent WHERE id = (SELECT id FROM gd_ruid WHERE xid = 147045713 AND dbid = 129678112)';
      q.ExecQuery;

      q.SQL.Text :=
        'DELETE FROM gd_function WHERE id = (SELECT id FROM gd_ruid WHERE xid = 147045715 AND dbid = 129678112)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (198, ''0000.0001.0000.0229'', ''12.01.2014'', ''Correct old gd_documenttype structure.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure CorrectAutoEntryScript(IBDB: TIBDatabase; Log: TModifyLog);
const
  S1 =
    'SQL.SQL.Text = "DELETE FROM ac_record WHERE id IN(" + _'#13#10 +
    '"SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae..entrykey " + _'#13#10 +
    '"  WHERE ae.trrecordkey = :trrecordkey AND " + _'#13#10 +
    '"  ae.begindate = :begindate AND ae.enddate = :enddate) AND " + _'#13#10 +
    '"companykey IN (" + IbLogin.HoldingList + ")"';

  S1a =
    'SQL.SQL.Text = "DELETE FROM ac_record WHERE id IN(" & _'#13#10 +
    '  "SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey " & _'#13#10 +
    '  "  WHERE ae.trrecordkey = :trrecordkey AND " & _'#13#10 +
    '  "  ae.begindate = :begindate AND ae.enddate = :enddate) AND " & _'#13#10 +
    '  "companykey IN (" & IbLogin.HoldingList & ")"';

  S2 =
    '  SQL.SQL.Text = "EXECUTE BLOCK (begindate DATE = :begindate, enddate DATE = :enddate, trrecordkey DINTKEY = :trrecordkey)" & vbCrLf & _'#13#10 +
    '    "AS " & vbCrLf & _'#13#10 +
    '    "  DECLARE id DINTKEY;" & vbCrLf & _'#13#10 +
    '    "BEGIN" & vbCrLf & _'#13#10 +
    '    "  FOR" & vbCrLf & _'#13#10 +
    '    "    SELECT e.documentkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey" & vbCrLf & _'#13#10 +
    '    "    WHERE ae.trrecordkey = :trrecordkey AND" & vbCrLf & _'#13#10 +
    '    "     ae.begindate >= :begindate AND ae.enddate <= :enddate AND" & vbCrLf & _'#13#10 +
    '    "      e.companykey IN (" & IbLogin.HoldingList & ")" & vbCrLf & _'#13#10 +
    '    "    INTO :id" & vbCrLf & _'#13#10 +
    '    "  DO" & vbCrLf & _'#13#10 +
    '    "   DELETE FROM gd_document WHERE id = :id;" & vbCrLf & _'#13#10 +
    '    "END"';

  S3 =
    'SQL.SQL.Text = "UPDATE ac_record SET delayed = 0 WHERE id IN(" + _'#13#10 +
    '  "SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey " + _'#13#10 +
    '  "  JOIN ac_record r ON r.id = e.recordkey WHERE ae.trrecordkey = :trrecordkey AND " + _'#13#10 +
    '  "  ae.begindate = :begindate AND ae.enddate = :enddate AND r.delayed = 1) AND " + _'#13#10 +
    '  "companykey IN (" + IbLogin.HoldingList + ")"';

  S3a =
    'SQL.SQL.Text = "UPDATE ac_record SET delayed = 0 WHERE id IN(" & _'#13#10 +
    '  "SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey " & _'#13#10 +
    '  "  JOIN ac_record r ON r.id = e.recordkey WHERE ae.trrecordkey = :trrecordkey AND " & _'#13#10 +
    '  "  ae.begindate = :begindate AND ae.enddate = :enddate AND r.delayed = 1) AND " & _'#13#10 +
    '  "companykey IN (" & IbLogin.HoldingList & ")"';

  S4 =
    '  SQL.SQL.Text = "EXECUTE BLOCK (trrecordkey DINTKEY = :trrecordkey, begindate DATE = :begindate, enddate DATE = :enddate) " & _'#13#10 +
    '    "AS " & _'#13#10 +
    '    "  DECLARE id DINTKEY; " & _'#13#10 +
    '    "BEGIN " & _'#13#10 +
    '    "  FOR " & _'#13#10 +
    '    "    SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey " & _'#13#10 +
    '    "      JOIN ac_record r ON r.id = e.recordkey WHERE ae.trrecordkey = :trrecordkey AND " & _'#13#10 +
    '    "        ae.begindate = :begindate AND ae.enddate = :enddate AND r.delayed = 1 AND " & _'#13#10 +
    '    "        r.companykey IN (" & IbLogin.HoldingList & ")" & _'#13#10 +
    '    "    INTO :id " & _'#13#10 +
    '    "  DO " & _'#13#10 +
    '    "    UPDATE ac_record SET delayed = 0 WHERE id = :id; " & _'#13#10 +
    '    "END "';

  function ReplaceText(AFind, AReplace, AScript: TStringList): Boolean;
  var
    I, J: Integer;
    F: Boolean;
  begin
    Result := False;

    if (AFind.Count = 0) or (AReplace.Count = 0) or (AScript.Count = 0) then
      exit;

    I := 0;
    while I < AScript.Count do
    begin
      F := True;

      for J := 0 to AFind.Count - 1 do
      begin
        if ((I + J) >= AScript.Count)
          or (UpperCase(Trim(AScript[I + J])) <> UpperCase(Trim(AFind[J]))) then
        begin
          F := False;
          break;
        end;
      end;

      if F then
      begin
        for J := 0 to AFind.Count - 1 do
          AScript.Delete(I);
        for J := 0 to AReplace.Count - 1 do
        begin
          AScript.Insert(I, AReplace[J]);
          Inc(I);
        end;
        Result := True;
      end else
        Inc(I);
    end;
  end;

var
  q, q2: TIBSQL;
  Tr: TIBTransaction;
  SL, SL1, SL1a, SL2, SL3, SL3a, SL4: TStringList;
  A, B, C, D: Boolean;
  Cnt: Integer;
begin
  SL := TStringList.Create;
  SL1 := TStringList.Create;
  SL1a := TStringList.Create;
  SL2 := TStringList.Create;
  SL3 := TStringList.Create;
  SL3a := TStringList.Create;
  SL4 := TStringList.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q2 := TIBSQL.Create(nil);
  Cnt := 0;
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    SL1.Text := S1;
    SL1a.Text := S1a;
    SL2.Text := S2;
    SL3.Text := S3;
    SL3a.Text := S3a;
    SL4.Text := S4;

    try
      q.Transaction := Tr;
      q2.Transaction := Tr;

      q2.SQL.Text := 'UPDATE gd_function SET script = :s WHERE id = :id';

      q.SQL.Text := 'SELECT * FROM gd_function';
      q.ExecQuery;
      while not q.EOF do
      begin
        SL.Text := q.FieldByName('script').AsString;
        A := ReplaceText(SL1, SL2, SL);
        B := ReplaceText(SL1a, SL2, SL);
        C := ReplaceText(SL3, SL4, SL);
        D := ReplaceText(SL3a, SL4, SL);

        if A or B or C or D then
        begin
          q2.ParamByName('s').AsString := SL.Text;
          q2.ParamByName('id').AsInteger := q.FieldByName('id').AsInteger;
          q2.ExecQuery;
          Inc(Cnt);
        end;

        q.Next;
      end;

      if Cnt > 0 then
        Log('Исправлено скриптов формирования проводок: ' + IntToStr(Cnt));

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (201, ''0000.0001.0000.0232'', ''24.02.2014'', ''Some entry queries have been corrected.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    SL.Free;
    SL1.Free;
    SL1a.Free;
    SL2.Free;
    SL3.Free;
    SL3a.Free;
    SL4.Free;
    q.Free;
    q2.Free;
    Tr.Free;
  end;
end;

procedure CorrectEntryTriggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;

      DropTrigger2('AC_BI_ENTRY_ISSIMPLE', Tr);
      DropTrigger2('AC_BI_ENTRY_ENTRYDATE', Tr);
      DropTrigger2('AC_BI_ENTRY_RECORD', Tr);
      DropTrigger2('AC_BU_ENTRY_ISSIMPLE', Tr);
      DropTrigger2('AC_BU_ENTRY_RECORD', Tr);
      DropTrigger2('AC_AD_ENTRY_DELETERECORD', Tr);
      DropTrigger2('AC_AD_ENTRY_ISSIMPLE', Tr);

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (199, ''0000.0001.0000.0230'', ''10.02.2014'', ''New triggers for AC_ENTRY, AC_RECORD.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (200, ''0000.0001.0000.0231'', ''11.02.2014'', ''Restrictions for document date.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure DeleteCardParamsItem(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'DELETE FROM gd_storage_data sd WHERE sd.id IN( ' +
        '  SELECT g2.id ' +
        '  FROM gd_storage_data g ' +
        '    JOIN gd_storage_data g2 on g2.parent = g.id ' +
        '  WHERE g.data_type = ''U'' ' +
        '    AND UPPER(g2.name) = UPPER(''gdv_dlgInvCardParams(Tgdv_dlgInvCardParams)''))';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (159, ''0000.0001.0000.0190'', ''17.10.2012'', ''Delete InvCardForm params from userstorage.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddNSMetadata(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      DropIndex2('gd_x_user_ibname', Tr);

      q.ParamCheck := False;
      q.Transaction := Tr;

      if not RelationExist2('at_namespace', Tr) then
      begin
        q.SQL.Text :=
          'CREATE TABLE at_namespace ('#13#10 +
          '  id            dintkey,'#13#10 +
          '  name          dtext255 NOT NULL UNIQUE,'#13#10 +
          '  caption       dtext255,'#13#10 +
          '  filename      dtext255,'#13#10 +
          '  filetimestamp TIMESTAMP,'#13#10 +
          '  version       dtext20 DEFAULT ''1.0.0.0'' NOT NULL,'#13#10 +
          '  dbversion     dtext20,'#13#10 +
          '  optional      dboolean_notnull DEFAULT 0,'#13#10 +
          '  internal      dboolean_notnull DEFAULT 1,'#13#10 +
          '  comment       dblobtext80_1251,'#13#10 +
          '  settingruid   VARCHAR(21),'#13#10 +
          ''#13#10 +
          '  CONSTRAINT at_pk_namespace PRIMARY KEY (id)'#13#10 +
          ')';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_biu_namespace FOR at_namespace'#13#10 +
        '  ACTIVE'#13#10 +
        '  BEFORE INSERT OR UPDATE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  IF (NEW.id IS NULL) THEN'#13#10 +
        '    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);'#13#10 +
        ''#13#10 +
        '  IF (TRIM(COALESCE(NEW.caption, '''')) = '''') THEN'#13#10 +
        '    NEW.caption = NEW.name;'#13#10 +
        'END';
      q.ExecQuery;

      if not RelationExist2('at_object', Tr) then
      begin
        q.SQL.Text :=
          'CREATE TABLE at_object ('#13#10 +
          '  id              dintkey,'#13#10 +
          '  namespacekey    dintkey,'#13#10 +
          '  objectname      dname,'#13#10 +
          '  objectclass     dclassname NOT NULL,'#13#10 +
          '  subtype         dtext60,'#13#10 +
          '  xid             dinteger_notnull,'#13#10 +
          '  dbid            dinteger_notnull,'#13#10 +
          '  objectpos       dinteger,'#13#10 +
          '  alwaysoverwrite dboolean_notnull DEFAULT 0,'#13#10 +
          '  dontremove      dboolean_notnull DEFAULT 0,'#13#10 +
          '  includesiblings dboolean_notnull DEFAULT 0,'#13#10 +
          '  headobjectkey   dforeignkey,'#13#10 +
          '  modified        TIMESTAMP,'#13#10 +
          '  curr_modified   TIMESTAMP,'#13#10 +
          ''#13#10 +
          '  CONSTRAINT at_pk_object PRIMARY KEY (id),'#13#10 +
          '  CONSTRAINT at_uk_object UNIQUE (xid, dbid, namespacekey),'#13#10 +
          '  CONSTRAINT at_fk_object_namespacekey FOREIGN KEY (namespacekey)'#13#10 +
          '    REFERENCES at_namespace (id)'#13#10 +
          '    ON DELETE CASCADE'#13#10 +
          '    ON UPDATE CASCADE,'#13#10 +
          '  CONSTRAINT at_fk_object_headobjectkey FOREIGN KEY (headobjectkey)'#13#10 +
          '    REFERENCES at_object (id)'#13#10 +
          '    ON DELETE CASCADE'#13#10 +
          '    ON UPDATE CASCADE,'#13#10 +
          '  CONSTRAINT at_chk_object_hk CHECK (headobjectkey IS DISTINCT FROM id) '#13#10 +
          ')';
        q.ExecQuery;
      end;

      if not RelationExist2('at_namespace_link', Tr) then
      begin
        q.SQL.Text :=
          'CREATE TABLE at_namespace_link ('#13#10 +
          '  namespacekey   dintkey,'#13#10 +
          '  useskey        dintkey,'#13#10 +
          ''#13#10 +
          '  CONSTRAINT at_pk_namespace_link PRIMARY KEY (namespacekey, useskey),'#13#10 +
          '  CONSTRAINT at_fk_namespace_link_nsk FOREIGN KEY (namespacekey)'#13#10 +
          '    REFERENCES at_namespace (id)'#13#10 +
          '    ON UPDATE CASCADE'#13#10 +
          '    ON DELETE CASCADE,'#13#10 +
          '  CONSTRAINT at_fk_namespace_link_usk FOREIGN KEY (useskey)'#13#10 +
          '    REFERENCES at_namespace (id)'#13#10 +
          '    ON UPDATE CASCADE'#13#10 +
          '    ON DELETE NO ACTION,'#13#10 +
          '  CONSTRAINT at_chk_namespace_link CHECK (namespacekey <> useskey)'#13#10 +
          ')';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'CREATE OR ALTER PROCEDURE at_p_findnsrec (InPath VARCHAR(32000),'#13#10 +
        '  InFirstID INTEGER, InID INTEGER)'#13#10 +
        '  RETURNS (OutPath VARCHAR(32000), OutFirstID INTEGER, OutID INTEGER)'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE ID INTEGER;'#13#10 +
        '  DECLARE VARIABLE NAME VARCHAR(255);'#13#10 +
        'BEGIN'#13#10 +
        '  FOR'#13#10 +
        '    SELECT l.useskey, n.name'#13#10 +
        '    FROM at_namespace_link l JOIN at_namespace n'#13#10 +
        '      ON n.id = l.useskey'#13#10 +
        '    WHERE l.namespacekey = :InID'#13#10 +
        '    INTO :ID, :NAME'#13#10 +
        '  DO BEGIN'#13#10 +
        '    IF (POSITION(:ID || ''='' || :NAME || '','' IN :InPath) > 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      OutPath = :InPath || :ID || ''='' || :NAME;'#13#10 +
        '      OutID = :ID;'#13#10 +
        '      OutFirstID = :InFirstID;'#13#10 +
        '      SUSPEND;'#13#10 +
        '    END ELSE'#13#10 +
        '    BEGIN'#13#10 +
        '      FOR'#13#10 +
        '        SELECT OutPath, OutFirstID, OutID'#13#10 +
        '        FROM at_p_findnsrec(:InPath || :ID || ''='' || :NAME || '','', :InFirstID, :ID)'#13#10 +
        '        INTO :OutPath, :OutFirstID, :OutID'#13#10 +
        '      DO BEGIN'#13#10 +
        '        IF (:OutPath > '''') THEN'#13#10 +
        '          SUSPEND;'#13#10 +
        '      END'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER PROCEDURE at_p_del_duplicates ('#13#10 +
        '  DeleteFromID INTEGER,'#13#10 +
        '  CurrentID INTEGER,'#13#10 +
        '  Stack VARCHAR(32000))'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE id INTEGER;'#13#10 +
        '  DECLARE VARIABLE nsid INTEGER;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (:DeleteFromID <> :CurrentID) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    FOR'#13#10 +
        '      SELECT o1.id'#13#10 +
        '      FROM at_object o1 JOIN at_object o2'#13#10 +
        '        ON o1.xid = o2.xid AND o1.dbid = o2.dbid'#13#10 +
        '      WHERE o1.NAMESPACEKEY = :DeleteFromID'#13#10 +
        '        AND o2.NAMESPACEKEY = :CurrentID'#13#10 +
        '        AND o1.headobjectkey IS NULL'#13#10 +
        '        AND o2.headobjectkey IS NULL'#13#10 +
        '      INTO :id'#13#10 +
        '    DO BEGIN'#13#10 +
        '      DELETE FROM at_object WHERE id = :id;'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        ''#13#10 +
        '  FOR'#13#10 +
        '    SELECT l.useskey'#13#10 +
        '    FROM at_namespace_link l'#13#10 +
        '    WHERE l.namespacekey = :CurrentID'#13#10 +
        '      AND POSITION((''('' || l.useskey || '')'') IN :Stack) = 0'#13#10 +
        '    INTO :nsid'#13#10 +
        '  DO BEGIN'#13#10 +
        '    EXECUTE PROCEDURE at_p_del_duplicates (:DeleteFromID, :nsid,'#13#10 +
        '      :Stack || ''('' || :nsid || '')'');'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      q.SQL.Text :=
        'GRANT ALL     ON at_namespace             TO administrator';
      q.ExecQuery;

      q.SQL.Text :=
        'GRANT ALL     ON at_object                TO administrator';
      q.ExecQuery;

      q.SQL.Text :=
        'GRANT ALL     ON at_namespace_link        TO administrator';
      q.ExecQuery;

      q.SQL.Text :=
        'GRANT EXECUTE ON PROCEDURE at_p_findnsrec TO administrator';
      q.ExecQuery;

      q.SQL.Text :=
        'GRANT EXECUTE ON PROCEDURE at_p_del_duplicates TO administrator';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command'#13#10 +
        '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)'#13#10 +
        'VALUES'#13#10 +
        '  (741108,740400,''Пространства имен'',''gdcNamespace'',0,NULL,80,NULL,''TgdcNamespace'',NULL,1,1,1,0,NULL)'#13#10 +
        'MATCHING(id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)'#13#10 +
        '  VALUES ('#13#10 +
        '    741109,'#13#10 +
        '    740400,'#13#10 +
        '    ''Синхронизация ПИ'','#13#10 +
        '    '''','#13#10 +
        '    ''Tat_frmSyncNamespace'','#13#10 +
        '    NULL,'#13#10 +
        '    0'#13#10 +
        '  )'#13#10 +
        'MATCHING(id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (163, ''0000.0001.0000.0194'', ''11.04.2013'', ''Namespace tables added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure Issue2846(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      CreateException2('gd_e_good', 'Error', Tr);

      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_aiu_good FOR gd_good'#13#10 +
        '  AFTER INSERT OR UPDATE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  IF (INSERTING OR (UPDATING AND NEW.groupkey <> OLD.groupkey)) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    IF (EXISTS(SELECT * FROM gd_goodgroup WHERE id = NEW.groupkey AND COALESCE(disabled, 0) <> 0)) THEN'#13#10 +
        '      EXCEPTION gd_e_good ''Нельзя добавлять/изменять товар в отключенной группе.'';'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (164, ''0000.0001.0000.0195'', ''06.05.2013'', ''Issue 2846.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure Issue2688(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  S: String;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'UPDATE ac_account SET parent = 367300 WHERE id IN (367301, 367302, 367303)';
      q.ExecQuery;

      if not DomainExist2('daccountalias', Tr) then
      begin
        q.SQL.Text :=
          'CREATE DOMAIN daccountalias ' +
          '  AS VARCHAR(40) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL';
        q.ExecQuery;  
      end;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_AIU_ACCOUNT_CHECKALIAS FOR AC_ACCOUNT'#13#10 +
        '  ACTIVE'#13#10 +
        '  AFTER INSERT OR UPDATE'#13#10 +
        '  POSITION 32000'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE P VARCHAR(1) = NULL;'#13#10 +
        '  DECLARE VARIABLE A daccountalias;'#13#10 +
        'BEGIN'#13#10 +
        '  IF (INSERTING OR (NEW.alias <> OLD.alias)) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    IF (EXISTS'#13#10 +
        '        (SELECT'#13#10 +
        '           root.id, UPPER(TRIM(allacc.alias)), COUNT(*)'#13#10 +
        '         FROM ac_account root'#13#10 +
        '           JOIN ac_account allacc ON allacc.lb > root.lb AND allacc.rb <= root.rb'#13#10 +
        '         WHERE'#13#10 +
        '           root.parent IS NULL'#13#10 +
        '         GROUP BY'#13#10 +
        '           1, 2'#13#10 +
        '         HAVING'#13#10 +
        '           COUNT(*) > 1)'#13#10 +
        '        )'#13#10 +
        '      THEN'#13#10 +
        '        EXCEPTION ac_e_duplicateaccount ''Дублируется наименование '' || NEW.alias;'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''A'' AND (POSITION(''.'' IN NEW.alias) <> 0)) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''Номер счета не может содержать точку. Счет: '' || NEW.alias;'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''S'') THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (COALESCE(NEW.disabled, 0) = 0) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT alias FROM ac_account WHERE id = NEW.parent INTO :A;'#13#10 +
        ''#13#10 +
        '        IF (POSITION(:A IN NEW.alias) <> 1) THEN'#13#10 +
        '          EXCEPTION ac_e_invalidaccount ''Номер субсчета должен начинаться с номера вышележащего счета/субсчета. Субсчет: '' || NEW.alias;'#13#10 +
        '      END '#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        ''#13#10 +
        '  IF (INSERTING OR (NEW.parent IS DISTINCT FROM OLD.parent)'#13#10 +
        '    OR (NEW.accounttype <> OLD.accounttype)) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT accounttype FROM ac_account WHERE id = NEW.parent INTO :P;'#13#10 +
        '    P = COALESCE(:P, ''Z'');'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''C'' AND NOT (NEW.parent IS NULL)) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''План счетов не может входить в другой план счетов или раздел.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''F'' AND NOT (:P IN (''C'', ''F''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''Раздел должен входить в план счетов или другой раздел.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''A'' AND NOT (:P IN (''C'', ''F''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''Счет должен входить в план счетов или раздел.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''S'' AND NOT (:P IN (''A'', ''S''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''Субсчет должен входить в счет или субсчет.'';'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'select '#13#10 +
        '  LIST(s.alias, '', '') '#13#10 +
        'from '#13#10 +
        '  ac_account s left join '#13#10 +
        '    ac_account a on s.parent = a.id and position(a.alias in s.alias) = 1 '#13#10 +
        'where '#13#10 +
        '  a.alias is null '#13#10 +
        '  and '#13#10 +
        '  s.accounttype=''S'' ';
      q.ExecQuery;
      if (not q.EOF) and (q.Fields[0].AsString > '') then
      begin
        S :=
          'Номер субсчета должен начинаться с номера счета.'#13#10 +
          'Следует откорректировать следующие субсчета:'#13#10 +
          q.Fields[0].AsString;
        MessageBox(0, PChar(S), 'Внимание', MB_ICONEXCLAMATION or MB_TASKMODAL or MB_OK);
        Log(S);
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (165, ''0000.0001.0000.0196'', ''08.05.2013'', ''Issue 2688.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddUqConstraintToGD_RUID(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      if not IndexExist2('gd_x_ruid_xid', Tr) then
      begin
        q.SQL.Text := 'CREATE INDEX gd_x_ruid_xid ON gd_ruid (xid, dbid)';
        q.ExecQuery;

        Tr.Commit;
        Tr.StartTransaction;
      end;

      q.SQL.Text := 'SELECT COUNT(*) FROM gd_ruid';
      q.ExecQuery;

      if (q.Fields[0].AsInteger < 20000000) or
        (MessageBox(0,
          PChar('Таблица GD_RUID содержит ' + q.Fields[0].AsString + ' записей.'#13#10 +
          'Поиск дубликатов может занять несколько десятков минут.'#13#10#13#10 +
          'Продолжить?'),
          'Внимание',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES) then
      begin
        q.Close;
        q.SQL.Text :=
          'execute block ' +
          'as ' +
          '  declare variable id integer; ' +
          '  declare variable xid integer; ' +
          '  declare variable dbid integer; ' +
          '  declare variable c integer; ' +
          'begin ' +
          '  for ' +
          '    select xid, dbid, count(*) from gd_ruid ' +
          '    group by xid, dbid ' +
          '    having count(*) > 1 ' +
          '    into :xid, :dbid, :c ' +
          '  do begin ' +
          '    for ' +
          '      select skip 1 id from gd_ruid ' +
          '      where xid = :xid and dbid = :dbid ' +
          '      into :id ' +
          '    do ' +
          '      delete from gd_ruid where id = :id; ' +
          '  end ' +
          'end';
        q.ExecQuery;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (166, ''0000.0001.0000.0197'', ''11.05.2013'', ''Added unique constraint on xid, dbid fields to gd_ruid table.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure DropConstraintFromAT_OBJECT(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      DropConstraint2('at_object', 'at_fk_object_ruid', Tr);

      q.Transaction := Tr;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (167, ''0000.0001.0000.0198'', ''14.05.2013'', ''Drop FK to gd_ruid in at_object.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure MoveSubObjects(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      if not FieldExist2('at_object', 'modified', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE at_object ADD modified TIMESTAMP';
        q.ExecQuery;
      end;

      DropConstraint2('at_object', 'at_uk_object', Tr);

      Tr.Commit;
      Tr.StartTransaction;

      q.SQL.Text :=
        'ALTER TABLE at_object ADD CONSTRAINT at_uk_object UNIQUE (xid, dbid, namespacekey)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (168, ''0000.0001.0000.0199'', ''16.05.2013'', ''Move subobjects along with a head object.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (169, ''0000.0001.0000.0200'', ''17.05.2013'', ''Added MODIFIED field to AT_OBJECT.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (170, ''0000.0001.0000.0201'', ''17.05.2013'', ''Constraint on at_object changed.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddUqConstraintToGD_RUID2(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      DropIndex2('gd_x_ruid_xid', Tr);

      Tr.Commit;
      Tr.StartTransaction;

      if not ConstraintExist2('gd_ruid', 'gd_uniq_ruid', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE gd_ruid ADD CONSTRAINT gd_uniq_ruid ' +
          '  UNIQUE (xid, dbid)';
        q.ExecQuery;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (171, ''0000.0001.0000.0202'', ''18.05.2013'', ''Added unique constraint on xid, dbid fields to gd_ruid table. Attempt #2.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddCurrModified(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      if not FieldExist2('at_object', 'curr_modified', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE at_object ADD curr_modified TIMESTAMP';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'ALTER TABLE at_object ALTER COLUMN alwaysoverwrite SET DEFAULT 0';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (172, ''0000.0001.0000.0203'', ''19.05.2013'', ''Curr_modified field added to at_object.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddEditionDate(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (173, ''0000.0001.0000.0204'', ''20.05.2013'', ''Missed editiondate fields added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddEditionDate2(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;

  procedure AddEditionDateField(const ATableName: String);
  begin
    if RelationExist2(ATableName, Tr) then
    begin
      if not FieldExist2(ATableName, 'editiondate', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE ' + ATableName + ' ADD editiondate deditiondate';
        q.ExecQuery;

        Tr.Commit;
        Tr.StartTransaction;
      end;

      q.SQL.Text :=
        'MERGE INTO at_object o '#13#10 +
        '   USING (SELECT r.xid, r.dbid FROM gd_ruid r JOIN ' + ATableName + ' t ON t.id = r.id '#13#10 +
        '     WHERE t.editiondate IS NULL) s '#13#10 +
        '   ON o.xid = s.xid AND o.dbid = s.dbid '#13#10 +
        '   WHEN MATCHED THEN '#13#10 +
        '     UPDATE SET modified = ''25.03.1918'', curr_modified = ''25.03.1918''';
      q.ExecQuery;

      q.SQL.Text := 'UPDATE ' + ATableName + ' SET editiondate = ''25.03.1918'' ' +
        'WHERE editiondate IS NULL';
      q.ExecQuery;
    end;  
  end;

  procedure AddCreationDateField(const ATableName: String);
  begin
    if RelationExist2(ATableName, Tr) then
    begin
      if not FieldExist2(ATableName, 'creationdate', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE ' + ATableName + ' ADD creationdate dcreationdate';
        q.ExecQuery;

        Tr.Commit;
        Tr.StartTransaction;
      end;

      q.SQL.Text := 'UPDATE ' + ATableName + ' SET creationdate = ''25.03.1918'' ' +
        'WHERE creationdate IS NULL';
      q.ExecQuery;
    end;
  end;

begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      DropConstraint2('at_object', 'at_uk_object', Tr);

      if not IndexExist2('at_x_object', Tr) then
      begin
        q.SQL.Text :=
          'CREATE UNIQUE INDEX at_x_object ' +
          '  ON at_object (xid, dbid, namespacekey)';
        q.ExecQuery;
      end;

      q.SQL.Text := 'ALTER TRIGGER GD_BU_TAXTYPE INACTIVE';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_TRANSACTION_BU0 FOR AC_TRANSACTION '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE UPDATE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        '  DECLARE a SMALLINT = NULL; '#13#10 +
        'begin '#13#10 +
        '  IF ((NOT NEW.parent IS NULL) '#13#10 +
        '    AND (NEW.autotransaction IS DISTINCT FROM OLD.autotransaction)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT autotransaction '#13#10 +
        '    FROM ac_transaction '#13#10 +
        '    WHERE id = new.parent '#13#10 +
        '    INTO :a; '#13#10 +
        ' '#13#10 +
        '    a = COALESCE(:a, 0); '#13#10 +
        '    NEW.autotransaction = COALESCE(NEW.autotransaction, 0); '#13#10 +
        ' '#13#10 +
        '    IF (NEW.autotransaction <> a) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (a = 1) THEN '#13#10 +
        '        EXCEPTION ac_e_autotrcantcontaintr; '#13#10 +
        '      ELSE '#13#10 +
        '        EXCEPTION ac_e_trcantcontainautotr; '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_TRANSACTION_BI0 FOR AC_TRANSACTION '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        '  DECLARE a SMALLINT; '#13#10 +
        'begin '#13#10 +
        '  if (not new.parent is null) then '#13#10 +
        '  begin '#13#10 +
        '    select autotransaction '#13#10 +
        '    from ac_transaction '#13#10 +
        '    where id = new.parent '#13#10 +
        '    into :a; '#13#10 +
        '    new.autotransaction = COALESCE(:a, 0); '#13#10 +
        '  end '#13#10 +
        'end';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      AddEditionDateField('AT_CHECK_CONSTRAINTS');
      AddEditionDateField('GD_COMMAND');
      AddEditionDateField('rp_reportgroup');
      AddEditionDateField('gd_documenttype');
      AddEditionDateField('ac_account');
      AddEditionDateField('ac_transaction');
      AddEditionDateField('ac_trrecord');

      AddEditionDateField('AC_ACCT_CONFIG');
      AddEditionDateField('AC_AUTOENTRY');
      AddEditionDateField('AC_GENERALLEDGER');
      AddEditionDateField('FLT_COMPONENTFILTER');
      AddEditionDateField('GD_BLOCK_RULE');
      AddEditionDateField('GD_COMPACCTYPE');
      AddEditionDateField('GD_COMPANYACCOUNT');
      AddEditionDateField('GD_CURR');
      AddEditionDateField('GD_CURRRATE');
      AddEditionDateField('GD_PLACE');
      AddEditionDateField('GD_PRECIOUSEMETAL');
      AddEditionDateField('GD_SQL_STATEMENT');
      AddEditionDateField('GD_TAX');
      AddEditionDateField('GD_TAXACTUAL');
      AddEditionDateField('GD_TAXNAME');
      AddEditionDateField('GD_TAXTYPE');
      AddEditionDateField('GD_TNVD');
      AddEditionDateField('GD_VALUE');
      AddEditionDateField('WG_HOLIDAY');
      AddEditionDateField('WG_POSITION');
      AddEditionDateField('WG_TBLCAL');
      AddEditionDateField('WG_TBLCALDAY');

      AddEditionDateField('GD_CONTACT');
      AddEditionDateField('GD_GOOD');
      AddEditionDateField('GD_GOODGROUP');
      AddCreationDateField('GD_CONTACT');
      AddCreationDateField('GD_GOOD');
      AddCreationDateField('GD_GOODGROUP');

      if not FieldExist2('GD_CONTACT', 'CREATORKEY', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_contact ADD creatorkey dforeignkey';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contact_creatorkey ' +
          '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not FieldExist2('GD_GOOD', 'CREATORKEY', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE gd_good ADD creatorkey dforeignkey';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_creatorkey ' +
          '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not FieldExist2('GD_GOODGROUP', 'CREATORKEY', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE gd_goodgroup ADD creatorkey dforeignkey';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_creatorkey ' +
          '  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id) ' +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not FieldExist2('GD_GOODGROUP', 'EDITORKEY', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE gd_goodgroup ADD editorkey dforeignkey';
        q.ExecQuery;

        q.SQL.Text :=
          'ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_editorkey ' +
          '  FOREIGN KEY (editorkey) REFERENCES gd_contact(id) ' +
          '  ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not IndexExist2('GD_X_FUNCTION_MODULE', Tr) then
      begin
        q.SQL.Text := 'CREATE INDEX gd_x_function_module ON gd_function (module) ';
        q.ExecQuery;
      end;

      q.SQL.Text := 'ALTER TRIGGER GD_BU_TAXTYPE ACTIVE';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (175, ''0000.0001.0000.0206'', ''08.06.2013'', ''Add missing edition date fields #2.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure CorrectNSTriggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command ' +
        '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) ' +
        'VALUES ' +
        '  (741115,740400,''Индексы'',''gdcIndex'',0,NULL,206,NULL,''TgdcIndex'',NULL,1,1,1,0,NULL) ' +
        'MATCHING (id) ';
      q.ExecQuery;

      CreateException2('gd_e_exception', 'General exception', Tr);

      DropTrigger2('at_biu_object', Tr);
      DropTrigger2('at_aiu_object', Tr);

      if not ConstraintExist2('at_object', 'at_chk_object_hk', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE at_object ADD CONSTRAINT at_chk_object_hk CHECK (headobjectkey IS DISTINCT FROM id)';
        q.ExecQuery;
      end;

      {q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_bi_object FOR at_object'#13#10 +
        '  ACTIVE'#13#10 +
        '  BEFORE INSERT'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  IF (NEW.id IS NULL) THEN '#13#10 +
        '    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);'#13#10 +
        ''#13#10 +
        '  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR'#13#10 +
        '    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    EXCEPTION gd_e_invalid_ruid ''Invalid ruid. XID = '' ||'#13#10 +
        '      NEW.xid || '', DBID = '' || NEW.dbid || ''.'';'#13#10 +
        '  END'#13#10 +
        ''#13#10 +
        '  IF (NEW.objectpos IS NULL) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT MAX(objectpos)'#13#10 +
        '    FROM at_object'#13#10 +
        '    WHERE namespacekey = NEW.namespacekey'#13#10 +
        '    INTO NEW.objectpos;'#13#10 +
        '    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;'#13#10 +
        '  END ELSE'#13#10 +
        '  BEGIN'#13#10 +
        '    UPDATE at_object SET objectpos = objectpos + 1'#13#10 +
        '    WHERE objectpos >= NEW.objectpos AND namespacekey = NEW.namespacekey;'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;}

      {q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_bu_object FOR at_object'#13#10 +
        '  ACTIVE'#13#10 +
        '  BEFORE UPDATE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE depend_id dintkey;'#13#10 +
        'BEGIN'#13#10 +
        '  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR'#13#10 +
        '    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    EXCEPTION gd_e_invalid_ruid ''Invalid ruid. XID = '' ||'#13#10 +
        '      NEW.xid || '', DBID = '' || NEW.dbid || ''.'';'#13#10 +
        '  END'#13#10 +
        ''#13#10 +
        '  IF (NEW.namespacekey <> OLD.namespacekey) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'','#13#10 +
        '      COALESCE(CAST(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'') AS INTEGER), 0) + 1);'#13#10 +
        ''#13#10 +
        '    FOR'#13#10 +
        '      SELECT id'#13#10 +
        '      FROM at_object'#13#10 +
        '      WHERE headobjectkey = NEW.id AND objectpos <= OLD.objectpos'#13#10 +
        '      ORDER BY objectpos'#13#10 +
        '      INTO :depend_id'#13#10 +
        '    DO BEGIN'#13#10 +
        '      UPDATE at_object SET namespacekey = NEW.namespacekey'#13#10 +
        '        WHERE id = :depend_id;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    SELECT MAX(objectpos)'#13#10 +
        '    FROM at_object'#13#10 +
        '    WHERE namespacekey = NEW.namespacekey'#13#10 +
        '    INTO NEW.objectpos;'#13#10 +
        '    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;'#13#10 +
        ''#13#10 +
        '    FOR'#13#10 +
        '      SELECT id'#13#10 +
        '      FROM at_object'#13#10 +
        '      WHERE headobjectkey = NEW.id AND objectpos > OLD.objectpos'#13#10 +
        '      ORDER BY objectpos'#13#10 +
        '      INTO :depend_id'#13#10 +
        '    DO BEGIN'#13#10 +
        '      UPDATE at_object SET namespacekey = NEW.namespacekey'#13#10 +
        '        WHERE id = :depend_id;'#13#10 +
        '    END'#13#10 +
        ''#13#10 +
        '    RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'','#13#10 +
        '      CAST(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK'') AS INTEGER) - 1);'#13#10 +
        '  END'#13#10 +
        '  ELSE IF (NEW.objectpos IS NULL) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    SELECT MAX(objectpos)'#13#10 +
        '    FROM at_object'#13#10 +
        '    WHERE namespacekey = NEW.namespacekey'#13#10 +
        '    INTO NEW.objectpos;'#13#10 +
        '    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;'#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;}

      {q.SQL.Text :=
        'CREATE OR ALTER TRIGGER at_au_object FOR at_object'#13#10 +
        '  ACTIVE'#13#10 +
        '  AFTER UPDATE'#13#10 +
        '  POSITION 0'#13#10 +
        'AS'#13#10 +
        'BEGIN'#13#10 +
        '  IF (NEW.namespacekey <> OLD.namespacekey) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    IF (COALESCE(RDB$GET_CONTEXT(''USER_TRANSACTION'', ''AT_OBJECT_LOCK''), 0) = 0) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (EXISTS(SELECT * FROM at_object WHERE id = NEW.headobjectkey'#13#10 +
        '        AND namespacekey <> NEW.namespacekey)) THEN'#13#10 +
        '      BEGIN'#13#10 +
        '        EXCEPTION gd_e_exception ''Нельзя перемещать подчиненный объект.'';'#13#10 +
        '      END'#13#10 +
        '    END  '#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;}

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (174, ''0000.0001.0000.0205'', ''05.06.2013'', ''Corrections for NS triggers.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddADAtObjectTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      DropTrigger2('at_ad_object', Tr);

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (176, ''0000.0001.0000.0207'', ''13.06.2013'', ''Added trigger to at_object.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (177, ''0000.0001.0000.0208'', ''14.06.2013'', ''Revert last changes.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure ChangeEntryTriggers(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (173, ''0000.0001.0000.0204'', ''20.05.2013'', ''Missed editiondate fields added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure SetDefaultForAccountType(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'UPDATE ac_account SET activity = ''A'' ' +
        'WHERE activity IS NULL AND accounttype IN (''A'', ''S'') ';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE ac_account SET activity = NULL ' +
        'WHERE activity IS NOT NULL AND accounttype IN (''C'', ''F'') ';
      q.ExecQuery;

      if not ConstraintExist2('AC_ACCOUNT', 'AC_CHK_ACCOUNT_ACTIVITY', Tr) then
      begin
        q.SQL.Text :=
          'ALTER TABLE ac_account ADD CONSTRAINT ac_chk_account_activity CHECK( ' +
          '  (activity IS NULL AND accounttype IN (''C'', ''F'')) OR (activity IS NOT NULL) ' +
          ')';
        q.ExecQuery;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (178, ''0000.0001.0000.0209'', ''10.08.2013'', ''Added check for account activity.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (179, ''0000.0001.0000.0210'', ''11.08.2013'', ''Added check for account activity #2.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddGdObjectDependencies(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;
    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (180, ''0000.0001.0000.0211'', ''19.08.2013'', ''gd_object_dependencies table added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure Issue1041(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_ad_documenttype FOR gd_documenttype '#13#10 +
        '  ACTIVE '#13#10 +
        '  AFTER DELETE '#13#10 +
        '  POSITION 20000 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF (NOT EXISTS( '#13#10 +
        '    SELECT * '#13#10 +
        '    FROM gd_documenttype '#13#10 +
        '    WHERE id <> OLD.id '#13#10 +
        '      AND reportgroupkey = OLD.reportgroupkey)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    IF (EXISTS( '#13#10 +
        '      SELECT * '#13#10 +
        '      FROM rp_reportlist l '#13#10 +
        '        JOIN rp_reportgroup g ON l.reportgroupkey = g.id '#13#10 +
        '        JOIN rp_reportgroup g_up ON g.lb >= g_up.lb AND g.rb <= g_up.rb '#13#10 +
        '      WHERE '#13#10 +
        '        g_up.id = OLD.reportgroupkey)) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      EXCEPTION gd_e_exception ''Перед удалением типа документа следует '' || '#13#10 +
        '        ''удалить или переместить в другую группу связанные с ним отчеты.''; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    DELETE FROM rp_reportgroup WHERE id = OLD.reportgroupkey; '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (181, ''0000.0001.0000.0212'', ''20.08.2013'', ''Issue 1041.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure Issue3218(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      q.SQL.Text :=
        'ALTER VIEW GD_V_OURCOMPANY '#13#10 +
        '( '#13#10 +
        '  ID, '#13#10 +
        '  COMPNAME, '#13#10 +
        '  COMPFULLNAME, '#13#10 +
        '  COMPANYTYPE, '#13#10 +
        '  COMPLB, '#13#10 +
        '  COMPRB, '#13#10 +
        '  AFULL, '#13#10 +
        '  ACHAG, '#13#10 +
        '  AVIEW, '#13#10 +
        '  ADDRESS, '#13#10 +
        '  CITY, '#13#10 +
        '  COUNTRY, '#13#10 +
        '  PHONE, '#13#10 +
        '  FAX, '#13#10 +
        '  ACCOUNT, '#13#10 +
        '  BANKCODE, '#13#10 +
        '  BANKMFO, '#13#10 +
        '  BANKNAME, '#13#10 +
        '  BANKADDRESS, '#13#10 +
        '  BANKCITY, '#13#10 +
        '  BANKCOUNTRY, '#13#10 +
        '  TAXID, '#13#10 +
        '  OKULP, '#13#10 +
        '  OKPO, '#13#10 +
        '  LICENCE, '#13#10 +
        '  OKNH, '#13#10 +
        '  SOATO, '#13#10 +
        '  SOOU '#13#10 +
        ') '#13#10 +
        'AS '#13#10 +
        'SELECT '#13#10 +
        '  C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE, '#13#10 +
        '  C.LB, C.RB, O.AFULL, O.ACHAG, O.AVIEW, '#13#10 +
        '  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX, '#13#10 +
        '  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO, '#13#10 +
        '  BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY, '#13#10 +
        '  CC.TAXID, CC.OKULP, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU '#13#10 +
        ' '#13#10 +
        'FROM '#13#10 +
        '  GD_OURCOMPANY O '#13#10 +
        '    JOIN GD_CONTACT C ON (O.COMPANYKEY = C.ID) '#13#10 +
        '    JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = O.COMPANYKEY) '#13#10 +
        '    LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID '#13#10 +
        '    LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY '#13#10 +
        '    LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY '#13#10 +
        '    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID;';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (182, ''0000.0001.0000.0213'', ''22.08.2013'', ''Issue 3218.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure AddNSSyncTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      if not GeneratorExist2('AT_G_FILE_TREE', Tr) then
      begin
        q.SQL.Text := 'CREATE GENERATOR at_g_file_tree';
        q.ExecQuery;
      end;

      if not RelationExist2('AT_NAMESPACE_FILE', Tr) then
      begin
        q.SQL.Text :=
          'CREATE GLOBAL TEMPORARY TABLE at_namespace_file ( '#13#10 +
          '  filename      dtext255, '#13#10 +
          '  filetimestamp TIMESTAMP, '#13#10 +
          '  filesize      dinteger, '#13#10 +
          '  name          dtext255 NOT NULL UNIQUE, '#13#10 +
          '  caption       dtext255, '#13#10 +
          '  version       dtext20, '#13#10 +
          '  dbversion     dtext20, '#13#10 +
          '  optional      dboolean_notnull DEFAULT 0, '#13#10 +
          '  internal      dboolean_notnull DEFAULT 1, '#13#10 +
          '  comment       dblobtext80_1251, '#13#10 +
          '  xid           dinteger, '#13#10 +
          '  dbid          dinteger, '#13#10 +
          ' '#13#10 +
          '  CONSTRAINT at_pk_namespace_file PRIMARY KEY (filename)'#13#10 +
          ') '#13#10 +
          '  ON COMMIT DELETE ROWS;';
        q.ExecQuery;
      end;

      if not RelationExist2('AT_NAMESPACE_FILE_LINK', Tr) then
      begin
        q.SQL.Text :=
          'CREATE GLOBAL TEMPORARY TABLE at_namespace_file_link ( '#13#10 +
          '  filename      dtext255 NOT NULL, '#13#10 +
          '  uses_xid      dintkey, '#13#10 +
          '  uses_dbid     dintkey, '#13#10 +
          '  uses_name     dtext255 NOT NULL, '#13#10 +
          ' '#13#10 +
          '  CONSTRAINT at_pk_namespace_file_link '#13#10 +
          '    PRIMARY KEY (filename, uses_xid, uses_dbid), '#13#10 +
          '  CONSTRAINT at_fk_namespace_file_link_fn '#13#10 +
          '    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename) '#13#10 +
          '      ON UPDATE CASCADE '#13#10 +
          '      ON DELETE CASCADE '#13#10 +
          ') '#13#10 +
          '  ON COMMIT DELETE ROWS;';
        q.ExecQuery;
      end;

      if not RelationExist2('AT_NAMESPACE_SYNC', Tr) then
      begin
        q.SQL.Text :=
          'CREATE GLOBAL TEMPORARY TABLE at_namespace_sync ( '#13#10 +
          '  namespacekey  dforeignkey, '#13#10 +
          '  filename      dtext255, '#13#10 +
          '  operation     CHAR(2) DEFAULT ''  '' NOT NULL, '#13#10 +
          ' '#13#10 +
          '  CONSTRAINT at_fk_namespace_sync_fn '#13#10 +
          '    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename) '#13#10 +
          '      ON UPDATE CASCADE '#13#10 +
          '      ON DELETE CASCADE, '#13#10 +
          '  CONSTRAINT at_chk_namespace_sync_op '#13#10 +
          '    CHECK (operation IN (''  '', ''< '', ''> '', ''>>'', ''<<'', ''=='', ''=>'', ''<='', ''! '',  '#13#10 +'''? '')) '#13#10 +
          ') '#13#10 +
          '  ON COMMIT DELETE ROWS;';
       q.ExecQuery;
      end;

      if ConstraintExist2('AT_NAMESPACE_SYNC', 'AT_FK_NAMESPACE_SYNC_NSK', Tr) then
      begin
        q.Close;

        q.SQL.Text := 'SELECT * FROM at_namespace';
        q.ExecQuery;
        q.Close;

        q.SQL.Text := 'SELECT * FROM at_namespace_sync';
        q.ExecQuery;
        q.Close;

        DropConstraint2('AT_NAMESPACE_SYNC', 'AT_FK_NAMESPACE_SYNC_NSK', Tr);
      end;

      q.SQL.Text := 'GRANT ALL ON at_namespace_file TO administrator';
      q.SQL.Text := 'GRANT ALL ON at_namespace_file_link TO administrator';
      q.SQL.Text := 'GRANT ALL ON at_namespace_sync TO administrator';
      q.ExecQuery;

      if ConstraintExist2('GD_RUID', 'GD_CHK_RUID_ETALON', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_ruid DROP CONSTRAINT gd_chk_ruid_etalon';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'ALTER TABLE gd_ruid ADD CONSTRAINT gd_chk_ruid_etalon ' +
        '  CHECK( ' +
        '    (id >= 147000000 AND xid >= 147000000) ' +
        '    OR ' +
        '    (id < 147000000 AND dbid = 17 AND id = xid) ' +
        '  )';
      q.ExecQuery;

      if not IndexExist2('AT_X_NAMESPACE_FILE_RUID', Tr) then
      begin
        q.Close;
        q.SQL.Text :=
          'CREATE INDEX at_x_namespace_file_ruid ON at_namespace_file ' +
          '  (xid, dbid)';
        q.ExecQuery;
      end;

      if not IndexExist2('AT_X_NAMESPACE_FILE_LINK_UR', Tr) then
      begin
        q.Close;
        q.SQL.Text :=
          'CREATE INDEX at_x_namespace_file_link_ur ON at_namespace_file_link ' +
          '  (uses_xid, uses_dbid)';
        q.ExecQuery;
      end;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (183, ''0000.0001.0000.0214'', ''31.08.2013'', ''Added NS sync tables.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (184, ''0000.0001.0000.0215'', ''02.09.2013'', ''Generator added.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (185, ''0000.0001.0000.0216'', ''08.09.2013'', ''Drop constraint AT_FK_NAMESPACE_SYNC_NSK.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (186, ''0000.0001.0000.0217'', ''10.09.2013'', ''Drop constraint AT_FK_NAMESPACE_SYNC_NSK. Attempt #2.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (187, ''0000.0001.0000.0218'', ''12.09.2013'', ''Modified check constraint on GD_RUID.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (188, ''0000.0001.0000.0219'', ''14.09.2013'', ''Second attempt to drop constraint AT_FK_NAMESPACE_SYNC_NSK.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (189, ''0000.0001.0000.0220'', ''16.09.2013'', ''Change PK on gd_object_dependencies.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (190, ''0000.0001.0000.0221'', ''23.09.2013'', ''Added missed indices to at_namespace tables.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure ChangeAcLedgerAccounts(IBDB: TIBDatabase; Log: TModifyLog);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.ParamCheck := False;
      q.Transaction := Tr;

      DropConstraint2('AC_LEDGER_ACCOUNTS', 'FK_AC_LEDGER_ACCOUNTS', Tr);

      q.SQL.Text :=
        'ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT FK_AC_LEDGER_ACCOUNTS ' +
        '  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID) ' +
        '  ON UPDATE CASCADE ' +
        '  ON DELETE CASCADE';
      q.ExecQuery;

      if not FieldExist2('AT_NAMESPACE', 'FILEDATA', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE AT_NAMESPACE ADD filedata dscript ';
        q.ExecQuery;
      end;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER evt_bi_object1 FOR evt_object '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT OR UPDATE'#13#10 +
        '  POSITION 1 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  IF ((NOT NEW.name IS NULL) AND '#13#10 +
        '     (NEW.objectname IS NULL) AND '#13#10 +
        '     (NEW.classname IS NULL) AND '#13#10 +
        '     (NEW.subtype IS NULL)) '#13#10 +
        '  THEN '#13#10 +
        '    EXCEPTION  EVT_E_INCORRECTVERSION; '#13#10 +
        ' '#13#10 +
        '  NEW.objectname = COALESCE(NEW.objectname, ''''); '#13#10 +
        '  NEW.classname = COALESCE(NEW.classname, ''''); '#13#10 +
        '  NEW.subtype = COALESCE(NEW.subtype, ''''); '#13#10 +
        ' '#13#10 +
        '  IF '#13#10 +
        '    ( '#13#10 +
        '    ((NEW.objectname = '''') AND (NEW.classname = '''')) OR '#13#10 +
        '    ((NEW.subtype <> '''') AND ((NEW.objectname <> '''') OR '#13#10 +
        '     (NEW.classname = ''''))) '#13#10 +
        '    ) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    EXCEPTION EVT_E_RECORDINCORRECT; '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER evt_bi_object2 FOR evt_object '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT OR UPDATE '#13#10 +
        '  POSITION 2 '#13#10 +
        'AS '#13#10 +
        'BEGIN '#13#10 +
        '  /* Проверяет уникальность объекта или класса с подтипом*/ '#13#10 +
        '  IF '#13#10 +
        '    (EXISTS(SELECT * FROM evt_object '#13#10 +
        '    WHERE '#13#10 +
        '    (UPPER(objectname) = UPPER(NEW.objectname))  AND '#13#10 +
        '    (UPPER(classname) = UPPER(NEW.classname)) AND '#13#10 +
        '    (parent IS NOT DISTINCT FROM NEW.parent) AND '#13#10 +
        '    (UPPER(subtype) = UPPER(NEW.subtype)) AND '#13#10 +
        '    (id <> NEW.id))) '#13#10 +
        '  THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    EXCEPTION EVT_E_RECORDFOUND; '#13#10 +
        '  END '#13#10 +
        ' '#13#10 +
        '  /* Заполняет поля name, objecttype для поддержки */ '#13#10 +
        '  /* старой версии Гедемина */ '#13#10 +
        '  IF (NEW.classname = '''') THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    NEW.objecttype = 0; '#13#10 +
        '    NEW.name = NEW.objectname; '#13#10 +
        '  END ELSE '#13#10 +
        '    BEGIN '#13#10 +
        '      NEW.objecttype = 1; '#13#10 +
        '      IF (NEW.subtype = '''') THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        NEW.name = NEW.classname; '#13#10 +
        '      END ELSE '#13#10 +
        '        NEW.name = NEW.classname || NEW.subtype; '#13#10 +
        '    END '#13#10 +
        'END';
      q.ExecQuery;

      DropTrigger2('EVT_BU_OBJECT1', Tr);
      DropTrigger2('EVT_BU_OBJECT2', Tr);

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_TRANSACTION_BU0 FOR AC_TRANSACTION '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE UPDATE '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        '  DECLARE a SMALLINT = NULL; '#13#10 +
        'begin '#13#10 +
        '  IF ((NOT NEW.parent IS NULL) '#13#10 +
        '    AND (NEW.autotransaction IS DISTINCT FROM OLD.autotransaction)) THEN '#13#10 +
        '  BEGIN '#13#10 +
        '    SELECT autotransaction '#13#10 +
        '    FROM ac_transaction '#13#10 +
        '    WHERE id = new.parent '#13#10 +
        '    INTO :a; '#13#10 +
        ' '#13#10 +
        '    a = COALESCE(:a, 0); '#13#10 +
        '    NEW.autotransaction = COALESCE(NEW.autotransaction, 0); '#13#10 +
        ' '#13#10 +
        '    IF (NEW.autotransaction <> a) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (a = 1) THEN '#13#10 +
        '        EXCEPTION ac_e_autotrcantcontaintr; '#13#10 +
        '      ELSE '#13#10 +
        '        EXCEPTION ac_e_trcantcontainautotr; '#13#10 +
        '    END '#13#10 +
        '  END '#13#10 +
        'END';
      q.ExecQuery;

      q.SQL.Text :=
        'CREATE OR ALTER TRIGGER AC_TRANSACTION_BI0 FOR AC_TRANSACTION '#13#10 +
        '  ACTIVE '#13#10 +
        '  BEFORE INSERT '#13#10 +
        '  POSITION 0 '#13#10 +
        'AS '#13#10 +
        '  DECLARE a SMALLINT; '#13#10 +
        'begin '#13#10 +
        '  if (not new.parent is null) then '#13#10 +
        '  begin '#13#10 +
        '    select autotransaction '#13#10 +
        '    from ac_transaction '#13#10 +
        '    where id = new.parent '#13#10 +
        '    into :a; '#13#10 +
        '    new.autotransaction = COALESCE(:a, 0); '#13#10 +
        '  end '#13#10 +
        'end';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (192, ''0000.0001.0000.0223'', ''11.11.2013'', ''Change FK for AC_LEDGER_ACCOUNTS.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (193, ''0000.0001.0000.0224'', ''12.11.2013'', ''Corrected triggers for EVT_OBJECT.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

procedure RUIDsForGdStorageData(IBDB: TIBDatabase; Log: TModifyLog);

  procedure ChangeID(AQ: TIBSQL; const ASearch: String; const AnInsert: String;
    const ANewID: String; const AName: String);
  var
    XID, DBID, ID: String;
  begin
    AQ.Close;
    AQ.SQL.Text := ASearch;
    AQ.ExecQuery;

    if AQ.EOF then
    begin
      Log('Не найден элемент хранилища ' + AName);
      AQ.Close;
      AQ.SQL.Text := AnInsert;
      AQ.ExecQuery;
      ID := ANewID;
    end else
      ID := AQ.Fields[0].AsString;

    if ID = ANewID then
      exit;  

    AQ.Close;
    AQ.SQL.Text := 'SELECT xid, dbid FROM gd_ruid WHERE id = ' + ID;
    AQ.ExecQuery;

    if not AQ.EOF then
    begin
      XID := AQ.Fields[0].AsString;
      DBID := AQ.Fields[1].AsString;
    end else
    begin
      XID := '';
      DBID := '';
    end;

    AQ.Close;
    AQ.SQL.Text := 'UPDATE gd_storage_data SET id = ' + ANewID + ', ' +
      'name = ''' + AName + ''', ' +
      'editiondate = ''01.01.2000'', editorkey = 650002 ' +
      'WHERE id = ' + ID;
    AQ.ExecQuery;

    if XID > '' then
    begin
      AQ.Close;
      AQ.SQL.Text := 'UPDATE at_object SET xid = ' + ANewID + ', dbid = 17 ' +
        'WHERE xid = ' + XID + ' AND dbid = ' + DBID;
      AQ.ExecQuery;

      AQ.Close;
      AQ.SQL.Text := 'UPDATE at_settingpos SET xid = ' + ANewID + ', dbid = 17 ' +
        'WHERE xid = ' + XID + ' AND dbid = ' + DBID;
      AQ.ExecQuery;

      AQ.Close;
      AQ.SQL.Text := 'DELETE FROM gd_ruid ' +
        'WHERE xid = ' + XID + ' AND dbid = ' + DBID;
      AQ.ExecQuery;
    end;
  end;

var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  ConvertStorage(IBDB, Log);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    try
      q.Transaction := Tr;

      q.SQL.Text := 'ALTER TRIGGER gd_biu_storage_data INACTIVE';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      ChangeID(q,
        'SELECT id FROM gd_storage_data WHERE data_type = ''G'' AND parent IS NULL',
        'INSERT INTO gd_storage_data (id, name, data_type, editiondate, editorkey) ' +
          'VALUES (990000, ''GLOBAL'', ''G'', ''01.01.2000'', 650002) ',
        '990000', 'GLOBAL');

      ChangeID(q,
        'SELECT id FROM gd_storage_data WHERE data_type = ''U'' AND int_data = 150001',
        'INSERT INTO gd_storage_data (id, name, data_type, int_data, editiondate, editorkey) ' +
          'VALUES (990010, ''USER - Administrator'', ''U'', 150001, ''01.01.2000'', 650002) ',
        '990010', 'USER - Administrator');

      ChangeID(q,
        'SELECT id FROM gd_storage_data WHERE data_type = ''O'' AND int_data = 650010',
        'INSERT INTO gd_storage_data (id, name, data_type, int_data, editiondate, editorkey) ' +
          'VALUES (990020, ''COMPANY - <Ввести наименование организации>'', ''O'', 650010, ''01.01.2000'', 650002) ',
        '990020', 'COMPANY - <Ввести наименование организации>');

      q.Close;  
      q.SQL.Text := 'ALTER TRIGGER gd_biu_storage_data ACTIVE';
      q.ExecQuery;

      q.Close;
      q.SQL.Text := 'DELETE FROM at_object WHERE xid=990000 OR xid=990010 OR xid=990020';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (194, ''0000.0001.0000.0225'', ''26.11.2013'', ''RUIDs for gd_storage_data objects.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command '#13#10 +
        '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) '#13#10 +
        'VALUES '#13#10 +
        '  (741117,740400,''Триггеры'',''gdcTrigger'',0,NULL,253,NULL,''TgdcTrigger'',NULL,1,1,1,0,NULL)'#13#10 +
        'MATCHING (id)';
      q.ExecQuery;

      q.Close;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (195, ''0000.0001.0000.0226'', ''27.11.2013'', ''Add Triggers command into the Explorer tree.'') ' +
        '  MATCHING (id)';
      q.ExecQuery;

      Tr.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if Tr.InTransaction then
          Tr.Rollback;
        raise;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
