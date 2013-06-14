
unit mdf_DeleteInvCardParams;

interface

uses
  IBDatabase, gdModify, IBSQL, SysUtils;

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

implementation

uses
  Windows, mdf_metadata_unit;

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
        Log('��������� ������: ' + E.Message);
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
        '  (741108,740400,''������������ ����'',''gdcNamespace'',0,NULL,80,NULL,''TgdcNamespace'',NULL,1,1,1,0,NULL)'#13#10 +
        'MATCHING(id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)'#13#10 +
        '  VALUES ('#13#10 +
        '    741109,'#13#10 +
        '    740400,'#13#10 +
        '    ''������������� ��'','#13#10 +
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
        Log('��������� ������: ' + E.Message);
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
        '      EXCEPTION gd_e_good ''������ ���������/�������� ����� � ����������� ������.'';'#13#10 +
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
        Log('��������� ������: ' + E.Message);
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
        '        EXCEPTION ac_e_duplicateaccount ''����������� ������������ '' || NEW.alias;'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''A'' AND (POSITION(''.'' IN NEW.alias) <> 0)) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''����� ����� �� ����� ��������� �����. ����: '' || NEW.alias;'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''S'') THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      IF (COALESCE(NEW.disabled, 0) = 0) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        SELECT alias FROM ac_account WHERE id = NEW.parent INTO :A;'#13#10 +
        ''#13#10 +
        '        IF (POSITION(:A IN NEW.alias) <> 1) THEN'#13#10 +
        '          EXCEPTION ac_e_invalidaccount ''����� �������� ������ ���������� � ������ ������������ �����/��������. �������: '' || NEW.alias;'#13#10 +
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
        '      EXCEPTION ac_e_invalidaccount ''���� ������ �� ����� ������� � ������ ���� ������ ��� ������.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''F'' AND NOT (:P IN (''C'', ''F''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''������ ������ ������� � ���� ������ ��� ������ ������.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''A'' AND NOT (:P IN (''C'', ''F''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''���� ������ ������� � ���� ������ ��� ������.'';'#13#10 +
        ''#13#10 +
        '    IF (NEW.accounttype = ''S'' AND NOT (:P IN (''A'', ''S''))) THEN'#13#10 +
        '      EXCEPTION ac_e_invalidaccount ''������� ������ ������� � ���� ��� �������.'';'#13#10 +
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
          '����� �������� ������ ���������� � ������ �����.'#13#10 +
          '������� ���������������� ��������� ��������:'#13#10 +
          q.Fields[0].AsString;
        MessageBox(0, PChar(S), '��������', MB_ICONEXCLAMATION or MB_TASKMODAL or MB_OK);
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
        Log('��������� ������: ' + E.Message);
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

      q.SQL.Text :=
        'execute block ' +
        'as ' +
        '  declare variable id integer; ' +
        'begin ' +
        '  for ' +
        '    select ' +
        '      r1.id ' +
        '    from ' +
        '      gd_ruid r1 join gd_ruid r2 ' +
        '        on r1.xid=r2.xid and r1.dbid=r2.dbid and r1.id<r2.id ' +
        '    into :id ' +
        '  do ' +
        '    delete from gd_ruid where id = :id; ' +
        'end';
      q.ExecQuery;

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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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

      q.SQL.Text := 'UPDATE ' + ATableName + ' SET editiondate = ''01.01.2000'' ' +
        'WHERE editiondate IS NULL';
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
        Log('��������� ������: ' + E.Message);
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
        '  (741115,740400,''�������'',''gdcIndex'',0,NULL,206,NULL,''TgdcIndex'',NULL,1,1,1,0,NULL) ' +
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

      q.SQL.Text :=
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
      q.ExecQuery;

      q.SQL.Text :=
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
      q.ExecQuery;

      q.SQL.Text :=
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
        '        EXCEPTION gd_e_exception ''������ ���������� ����������� ������.'';'#13#10 +
        '      END'#13#10 +
        '    END  '#13#10 +
        '  END'#13#10 +
        'END';
      q.ExecQuery;

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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
        Log('��������� ������: ' + E.Message);
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
