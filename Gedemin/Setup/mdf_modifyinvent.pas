unit mdf_ModifyInvent;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure CreateNewException(IBDB: TIBDatabase; Log: TModifyLog);
procedure CreateNewInvTable(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddSemanticCategory(IBDB: TIBDatabase; Log: TModifyLog);
procedure ModifyMovementTrigger(IBDB: TIBDatabase; Log: TModifyLog);
procedure CorrectIntervalIDProcs(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  Exceptions: array[1..9] of TmdfException = (
    (ExceptionName: 'INV_E_CANNTCHANGEFEATURE'; Message: 'Ќельз€ измен€ть признаки, т.к. они вли€ют на дальнейшее движение'),
    (ExceptionName: 'INV_E_CANNTCHANGEGOODKEY'; Message: 'Ќельз€ измен€ть товар в позиции, т.к. по позиции было дальнейшее движение!'),
    (ExceptionName: 'INV_E_DONTCHANGEBENEFICIARY'; Message: 'Ќельз€ изменить получател€'),
    (ExceptionName: 'INV_E_DONTCHANGESOURCE'; Message: 'Ќельз€ изменить источник!'),
    (ExceptionName: 'INV_E_DONTREDUCEAMOUNT'; Message: 'Ќельз€ уменьшить количество по позиции'),
    (ExceptionName: 'INV_E_EARLIERMOVEMENT'; Message: 'Ќельз€ изменить дату, т.к. было более раннее движение товара!'),
    (ExceptionName: 'INV_E_INCORRECTQUANTITY'; Message: ' оличество по документу не соответсвует созданному движению!'),
    (ExceptionName: 'INV_E_INSUFFICIENTBALANCE'; Message: 'Ќедостаточно остатков на указанную дату'),
    (ExceptionName: 'INV_E_NOPRODUCT'; Message: 'Ќа указанную дату нет остатка товара!'));

const
  tbl: TmdfTable =
    (TableName: 'GD_CHANGEDDOC';
     Description:
          ' (' +
          '    ID             DINTKEY,' +
          '    SOURCEDOCKEY   INTEGER,' +
          '    DESTDOCKEY     INTEGER,' +
          '    EDITORKEY      INTEGER,' +
          '    EDITIONDATE    DTIMESTAMP,' +
          '    CHANGEDFIELDS  DTEXT1024, ' +
          '   CONSTRAINT PK_GD_CHANGEDDOC PRIMARY KEY (ID),' +
          '   CONSTRAINT FK_GD_CHANGEDDOC_1 FOREIGN KEY (SOURCEDOCKEY) REFERENCES GD_DOCUMENT (ID) ON DELETE CASCADE ON UPDATE CASCADE, ' +
          '   CONSTRAINT FK_GD_CHANGEDDOC_2 FOREIGN KEY (DESTDOCKEY) REFERENCES GD_DOCUMENT (ID) ON DELETE CASCADE ON UPDATE CASCADE) ');

procedure CreateNewException(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;
    q.Transaction := FTr;
    {
    for i := 1 to 9 do
      CreateException2(Exceptions[i].ExceptionName, Exceptions[i].Message, FTr);

    DropException2('INV_E_CANNTCHANGEFEATURCE', FTr);

    q.Transaction := FTr;
    q.SQL.Text :=
      'CREATE OR ALTER TRIGGER INV_BU_MOVEMENT FOR INV_MOVEMENT '#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 0 '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE balance NUMERIC(15, 4); '#13#10 +
      '  DECLARE VARIABLE controlremains INTEGER; '#13#10 +
      'BEGIN '#13#10 +
      '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'') IS NULL) THEN '#13#10 +
      '  BEGIN '#13#10 +
      '    IF (NEW.documentkey <> OLD.documentkey) THEN '#13#10 +
      '      EXCEPTION inv_e_movementchange; '#13#10 +
      ' '#13#10 +
      '    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN '#13#10 +
      '    BEGIN '#13#10 +
      '      IF (OLD.debit <> 0) THEN '#13#10 +
      '      BEGIN '#13#10 +
      '        SELECT balance FROM inv_balance '#13#10 +
      '        WHERE contactkey = OLD.contactkey '#13#10 +
      '          AND cardkey = OLD.cardkey '#13#10 +
      '        INTO :balance; '#13#10 +
      '        IF (COALESCE(:balance, 0) < OLD.debit) THEN '#13#10 +
      '          EXCEPTION INV_E_INVALIDMOVEMENT; '#13#10 +
      '      END '#13#10 +
      '    END ELSE '#13#10 +
      '    BEGIN '#13#10 +
      '      IF (OLD.debit > NEW.debit) THEN '#13#10 +
      '      BEGIN '#13#10 +
      '        SELECT balance FROM inv_balance '#13#10 +
      '        WHERE contactkey = OLD.contactkey '#13#10 +
      '          AND cardkey = OLD.cardkey '#13#10 +
      '        INTO :balance; '#13#10 +
      '        balance = COALESCE(:balance, 0); '#13#10 +
      '        IF ((:balance < OLD.debit - NEW.debit)) THEN '#13#10 +
      '          EXCEPTION INV_E_DONTREDUCEAMOUNT; '#13#10 +
      '      END ELSE '#13#10 +
      '      BEGIN '#13#10 +
      '        IF (NEW.credit > OLD.credit) THEN '#13#10 +
      '        BEGIN '#13#10 +
      '          SELECT balance FROM inv_balance '#13#10 +
      '          WHERE contactkey = OLD.contactkey '#13#10 +
      '            AND cardkey = OLD.cardkey '#13#10 +
      '          INTO :balance; '#13#10 +
      '          balance = COALESCE(:balance, 0); '#13#10 +
      '          controlremains = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''CONTROLREMAINS''); '#13#10 +
      '          IF (:controlremains IS NULL) THEN '#13#10 +
      '          BEGIN '#13#10 +
      '            IF ((:balance > 0) AND (:balance < NEW.credit - OLD.credit)) THEN '#13#10 +
      '              EXCEPTION INV_E_INSUFFICIENTBALANCE; '#13#10 +
      '          END '#13#10 +
      '          ELSE '#13#10 +
      '            IF ((:controlremains <> 0) and (:balance < NEW.credit - OLD.credit)) THEN '#13#10 +
      '              EXCEPTION INV_E_INSUFFICIENTBALANCE; '#13#10 +
      '        END '#13#10 +
      '      END '#13#10 +
      '    END '#13#10 +
      '  END '#13#10 +
      'END';
    q.ExecQuery;
    }

    q.SQL.Text :=
      'CREATE OR ALTER PROCEDURE INV_INSERT_CARD '#13#10 +
      '( '#13#10 +
      '  id INTEGER, '#13#10 +
      '  parent INTEGER '#13#10 +
      ') '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE sqltext VARCHAR(32000); '#13#10 +
      '  DECLARE VARIABLE fieldname VARCHAR(32000); '#13#10 +
      'BEGIN '#13#10 +
      '  SELECT LIST(fieldname, '','') '#13#10 +
      '  FROM AT_RELATION_FIELDS '#13#10 +
      '  WHERE '#13#10 +
      '    relationname = ''INV_CARD'' '#13#10 +
      '    AND fieldname <> ''ID'' '#13#10 +
      '    AND fieldname <> ''PARENT'' '#13#10 +
      '  INTO :fieldname; '#13#10 +
      ' '#13#10 +
      '  sqltext = '#13#10 +
      '    ''INSERT INTO inv_card (id, parent, '' || :fieldname || '')'' || '#13#10 +
      '    ''SELECT '' || :id || '','' || :parent || '','' || '#13#10 +
      '    :fieldname || '' '' || '#13#10 +
      '    ''FROM inv_card WHERE id ='' || :parent; '#13#10 +
      ' '#13#10 +
      '  EXECUTE STATEMENT :sqltext; '#13#10 +
      'END';
    q.ExecQuery;

    q.SQL.Text := 'alter table at_triggers alter  relationname type VARCHAR(31)';
    q.ExecQuery;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (268, ''0000.0001.0000.0299'', ''21.11.2017'', ''Add new exception for new inventory system'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (269, ''0000.0001.0000.0300'', ''22.11.2017'', ''relationname field in the at_triggers table fixed'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    Ftr.Commit;
  finally
    q.Free;
    Ftr.Free;
  end;
end;

procedure CreateNewInvTable(IBDB: TIBDatabase; Log: TModifyLog);
var
  Ftr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    CreateRelation(tbl, IBDB);

    q.Transaction := Ftr;

    q.SQL.Text :=
      'GRANT ALL ON gd_available_id TO administrator';
    q.ExecQuery;

    q.SQL.Text :=
      'CREATE OR ALTER PROCEDURE gd_p_find_dupl_id '#13#10 +
      '  RETURNS(id INTEGER, relationkey INTEGER) '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE rn VARCHAR(31); '#13#10 +
      '  DECLARE VARIABLE fn VARCHAR(31); '#13#10 +
      '  DECLARE VARIABLE rid INTEGER; '#13#10 +
      'BEGIN '#13#10 +
      '  FOR '#13#10 +
      '    SELECT '#13#10 +
      '      rf.rdb$relation_name, atr.id, LIST(TRIM(rf.rdb$field_name)) '#13#10 +
      '    FROM '#13#10 +
      '      rdb$relation_fields rf '#13#10 +
      '      JOIN rdb$relations r ON r.rdb$relation_name = rf.rdb$relation_name '#13#10 +
      '      JOIN rdb$index_segments idxs ON idxs.rdb$field_name = rf.rdb$field_name '#13#10 +
      '      JOIN rdb$indices idx ON idx.rdb$index_name = idxs.rdb$index_name '#13#10 +
      '      JOIN rdb$relation_constraints rc ON rc.rdb$index_name = idx.rdb$index_name '#13#10 +
      '        AND rc.rdb$relation_name = rf.rdb$relation_name '#13#10 +
      '      JOIN at_relations atr ON atr.relationname = r.rdb$relation_name '#13#10 +
      '    WHERE '#13#10 +
      '      rc.rdb$constraint_type = ''PRIMARY KEY'' '#13#10 +
      '      AND '#13#10 +
      '      rf.rdb$relation_name <> ''GD_RUID'' '#13#10 +
      '      /* '#13#10 +
      ' '#13#10 +
      '      “ут должно быть условие на таблицы, в которых не соблюдаетс€ '#13#10 +
      '      уникальность »ƒ. '#13#10 +
      ' '#13#10 +
      '      */ '#13#10 +
      '      AND '#13#10 +
      '      r.rdb$system_flag = 0 '#13#10 +
      '      AND '#13#10 +
      '      COALESCE(r.rdb$relation_type, 0) = 0 '#13#10 +
      '      AND '#13#10 +
      '      NOT EXISTS( '#13#10 +
      '        SELECT * '#13#10 +
      '        FROM '#13#10 +
      '          rdb$index_segments idxs_fk '#13#10 +
      '          JOIN rdb$indices idx_fk ON idxs_fk.rdb$index_name = idx_fk.rdb$index_name '#13#10 +
      '        WHERE '#13#10 +
      '          idxs_fk.rdb$field_name = rf.rdb$field_name '#13#10 +
      '          AND '#13#10 +
      '          idx_fk.rdb$relation_name = rf.rdb$relation_name '#13#10 +
      '          AND '#13#10 +
      '          idx_fk.rdb$index_name <> idx.rdb$index_name '#13#10 +
      '      ) '#13#10 +
      '    GROUP BY '#13#10 +
      '      1, 2 '#13#10 +
      '    HAVING '#13#10 +
      '      LIST(TRIM(rf.rdb$field_name)) = ''ID'' '#13#10 +
      '  INTO '#13#10 +
      '    :rn, :rid, :fn '#13#10 +
      '  DO BEGIN '#13#10 +
      '    relationkey = :rid; '#13#10 +
      '    FOR '#13#10 +
      '      EXECUTE STATEMENT ''SELECT id FROM '' || :rn || '' WHERE id >= 147000000'' '#13#10 +
      '      INTO :id '#13#10 +
      '    DO '#13#10 +
      '      SUSPEND; '#13#10 +
      '  END '#13#10 +
      'END';
    q.ExecQuery;

    q.SQL.Text := 'GRANT EXECUTE ON PROCEDURE gd_p_find_dupl_id TO ADMINISTRATOR';
    q.ExecQuery;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (271, ''0000.0001.0000.0302'', ''27.12.2017'', ''Add new table for new inventory system'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    q.Transaction := Ftr;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (272, ''0000.0001.0000.0303'', ''29.12.2017'', ''Added trigger to AC_AUTOENTRY'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    q.Transaction := Ftr;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (273, ''0000.0001.0000.0304'', ''10.01.2017'', ''Fixed rare situation with duplicated id'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    FTr.Commit;
  finally
    q.Free;
    Ftr.Free;
  end;
end;

procedure AddSemanticCategory(IBDB: TIBDatabase; Log: TModifyLog);
var
  Ftr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q.Transaction := Ftr;
    q.SQL.Text :=
      'ALTER TABLE gd_command ALTER cmd TYPE dtext40';
    q.ExecQuery;
    q.Close;

    AddField2('AT_RELATION_FIELDS', 'SEMCATEGORY', 'DTEXT60', FTr);
    AddField2('AT_RELATIONS', 'SEMCATEGORY', 'DTEXT60', FTr);

    q.SQL.Text :=
      'CREATE OR ALTER PROCEDURE GD_P_GETID(XID INTEGER, DBID INTEGER) '#13#10 +
      '  RETURNS (ID INTEGER) '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  IF (:XID < 147000000 OR :DBID = 17) THEN '#13#10 +
      '  BEGIN '#13#10 +
      '    ID = :XID; '#13#10 +
      '  END ELSE '#13#10 +
      '  BEGIN '#13#10 +
      '    ID = NULL; '#13#10 +
      ' '#13#10 +
      '    SELECT id '#13#10 +
      '    FROM gd_ruid '#13#10 +
      '    WHERE xid=:XID AND dbid=:DBID '#13#10 +
      '    INTO :ID; '#13#10 +
      ' '#13#10 +
      '    IF (ID IS NULL) THEN '#13#10 +
      '    BEGIN '#13#10 +
      '      EXCEPTION gd_e_invalid_ruid ''Invalid ruid. XID = '' || '#13#10 +
      '        :XID || '', DBID = '' || :DBID || ''.''; '#13#10 +
      '    END '#13#10 +
      '  END '#13#10 +
      ' '#13#10 +
      '  SUSPEND; '#13#10 +
      'END';
    q.ExecQuery;

    FTr.Commit;
    FTr.StartTransaction;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (274, ''0000.0001.0000.0305'', ''04.06.2018'', ''Added semantic category field to at_relation_fields'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (275, ''0000.0001.0000.0306'', ''05.06.2018'', ''Added semantic category field to at_relations'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    FTr.Commit;
  finally
    q.Free;
    Ftr.Free;
  end;
end;

procedure ModifyMovementTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTr: TIBTransaction;
  q, q1: TIBSQL;
  i: Integer;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q1 := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    for i := Low(Exceptions) to High(Exceptions) do
      CreateException2(Exceptions[i].ExceptionName, Exceptions[i].Message, FTr);

    DropException2('INV_E_CANNTCHANGEFEATURCE', FTr);

    q.Transaction := FTr;
    q.SQL.Text :=
      'CREATE OR ALTER TRIGGER INV_BU_MOVEMENT FOR INV_MOVEMENT '#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 0 '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE balance NUMERIC(15, 4); '#13#10 +
      '  DECLARE VARIABLE controlremains INTEGER; '#13#10 +
      'BEGIN '#13#10 +
      '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'') IS NULL) THEN '#13#10 +
      '  BEGIN '#13#10 +
      '    IF (NEW.documentkey <> OLD.documentkey) THEN '#13#10 +
      '      EXCEPTION inv_e_movementchange; '#13#10 +
      ' '#13#10 +
      '    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN '#13#10 +
      '    BEGIN '#13#10 +
      '      IF (OLD.debit <> 0) THEN '#13#10 +
      '      BEGIN '#13#10 +
      '        SELECT balance FROM inv_balance '#13#10 +
      '        WHERE contactkey = OLD.contactkey '#13#10 +
      '          AND cardkey = OLD.cardkey '#13#10 +
      '        INTO :balance; '#13#10 +
      '        IF (COALESCE(:balance, 0) < OLD.debit) THEN '#13#10 +
      '          EXCEPTION INV_E_INVALIDMOVEMENT; '#13#10 +
      '      END '#13#10 +
      '    END ELSE '#13#10 +
      '    BEGIN '#13#10 +
      '      IF (OLD.debit > NEW.debit) THEN '#13#10 +
      '      BEGIN '#13#10 +
      '        SELECT balance FROM inv_balance '#13#10 +
      '        WHERE contactkey = OLD.contactkey '#13#10 +
      '          AND cardkey = OLD.cardkey '#13#10 +
      '        INTO :balance; '#13#10 +
      '        balance = COALESCE(:balance, 0); '#13#10 +
      '        IF ((:balance > 0) AND (:balance < OLD.debit - NEW.debit)) THEN '#13#10 +
      '          EXCEPTION INV_E_DONTREDUCEAMOUNT; '#13#10 +
      '      END ELSE '#13#10 +
      '      BEGIN '#13#10 +
      '        IF (NEW.credit > OLD.credit) THEN '#13#10 +
      '        BEGIN '#13#10 +
      '          SELECT balance FROM inv_balance '#13#10 +
      '          WHERE contactkey = OLD.contactkey '#13#10 +
      '            AND cardkey = OLD.cardkey '#13#10 +
      '          INTO :balance; '#13#10 +
      '          balance = COALESCE(:balance, 0); '#13#10 +
      '          controlremains = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''CONTROLREMAINS''); '#13#10 +
      '          IF (:controlremains IS NULL) THEN '#13#10 +
      '          BEGIN '#13#10 +
      '            IF ((:balance < NEW.credit - OLD.credit)) THEN '#13#10 +
      '              EXCEPTION INV_E_INSUFFICIENTBALANCE; '#13#10 +
      '          END '#13#10 +
      '          ELSE '#13#10 +
      '            IF ((:controlremains <> 0) and (:balance < NEW.credit - OLD.credit)) THEN '#13#10 +
      '              EXCEPTION INV_E_INSUFFICIENTBALANCE; '#13#10 +
      '        END '#13#10 +
      '      END '#13#10 +
      '    END '#13#10 +
      '  END '#13#10 +
      'END';
    q.ExecQuery;

    Log('ƒобавление пол€ viewmovementpart в складские документы');

    if not DomainExist2('DVIEWMOVEMENTPART', Ftr) then
    begin
      q.Close;
      q.SQL.Text := 'CREATE DOMAIN DVIEWMOVEMENTPART AS VARCHAR(1) CHECK ((VALUE IN (''I'', ''E'') or VALUE is NULL))';
      q.ExecQuery;
    end;

    q1.Transaction := Ftr;
    q.Close;
    q.SQL.Text :=
      ' select r.relationname, dt.ruid from gd_documenttype dt join at_relations r ON dt.linerelkey = r.id where dt.classname = ''TgdcInvDocumentType''' +
      '   and EXISTS (select * from at_relation_fields f WHERE r.relationname = f.relationname and f.fieldname = ''INQUANTITY'') ';
    q.ExecQuery;
    while not q.EOF do
    begin
      AddField2(q.FieldByName('relationname').AsString, 'VIEWMOVEMENTPART', 'DVIEWMOVEMENTPART', Ftr);

      if TriggerExist2('USR$BU_' + q.FieldByName('ruid').AsString, Ftr) then
      begin
        q1.Close;
        q1.SQL.Text := 'ALTER TRIGGER USR$BU_' + q.FieldByName('ruid').AsString + ' INACTIVE ';
        q1.ExecQuery;
      end;

      q.Next;
    end;

    FTr.Commit;
    Ftr.StartTransaction;

    q.ExecQuery;
    while not q.EOF do
    begin
      q1.Close;
      q1.SQL.Text := 'UPDATE ' + q.FieldByName('relationname').AsString + ' SET VIEWMOVEMENTPART = case when inquantity <> 0 then ''I'' else ''E'' end ';
      q1.ExecQuery;

      if TriggerExist2('USR$BU_' + q.FieldByName('ruid').AsString, Ftr) then
      begin
        q1.Close;
        q1.SQL.Text := 'ALTER TRIGGER USR$BU_' + q.FieldByName('ruid').AsString + ' ACTIVE ';
        q1.ExecQuery;
      end;
      q.Next;
    end;
     FTr.Commit;
     FTr.StartTransaction;

     Log('ƒобавление пол€ checkremains в складские документы');

     q1.Close;
     q1.SQL.Text :=
       ' select r.relationname from gd_documenttype dt join at_relations r ON dt.linerelkey = r.id ' +
       ' where dt.classname = ''TgdcInvDocumentType'' ';
     q1.ExecQuery;
     while not q1.EOF do
     begin
       AddField2(q1.FieldByName('relationname').AsString, 'CHECKREMAINS', 'DBOOLEAN', Ftr);
       q1.Next;
     end;

    q.Close;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (278, ''0000.0001.0000.0310'', ''07.02.2019'', ''trigger inv_bu_movement changed'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    Ftr.Commit;
  finally
    q.Free;
    q1.Free;
    Ftr.Free;
  end;
end;

procedure CorrectIntervalIDProcs(IBDB: TIBDatabase; Log: TModifyLog);
var
  Ftr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

    q.Transaction := FTr;
    q.SQL.Text :=
      'CREATE OR ALTER PROCEDURE gd_p_getnextid_ex '#13#10 +
      '  RETURNS(id INTEGER) '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE id_from INTEGER; '#13#10 +
      '  DECLARE VARIABLE id_to INTEGER; '#13#10 +
      '  DECLARE VARIABLE limit_id INTEGER; '#13#10 +
      '  DECLARE VARIABLE rc INTEGER = 0; '#13#10 +
      '  DECLARE VARIABLE delta DFOREIGNKEY = 10; '#13#10 +
      'BEGIN '#13#10 +
      '  id = COALESCE(RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CURRENT_ID''), 0); '#13#10 +
      '  limit_id = COALESCE(RDB$GET_CONTEXT(''USER_SESSION'', ''GD_LIMIT_ID''), 0); '#13#10 +
      ' '#13#10 +
      '  IF (:id > 0 AND :id <= :limit_id) THEN '#13#10 +
      '    RDB$SET_CONTEXT(''USER_SESSION'', ''GD_CURRENT_ID'', :id + 1); '#13#10 +
      '  ELSE BEGIN '#13#10 +
      '    id = -1; '#13#10 +
      ' '#13#10 +
      '    FOR '#13#10 +
      '      SELECT id_from, id_to '#13#10 +
      '      FROM gd_available_id '#13#10 +
      '      INTO :id_from, :id_to '#13#10 +
      '    DO BEGIN '#13#10 +
      '      IF (:id_to - :id_from < :delta) THEN '#13#10 +
      '        IN AUTONOMOUS TRANSACTION DO '#13#10 +
      '        BEGIN '#13#10 +
      '          DELETE FROM gd_available_id WHERE id_from = :id_from AND id_to = :id_to; '#13#10 +
      '          rc = ROW_COUNT; '#13#10 +
      '        END '#13#10 +
      '      ELSE BEGIN '#13#10 +
      '        IN AUTONOMOUS TRANSACTION DO '#13#10 +
      '        BEGIN '#13#10 +
      '          UPDATE gd_available_id SET id_from = :id_from + :delta WHERE id_from = :id_from AND id_to = :id_to; '#13#10 +
      '          rc = ROW_COUNT; '#13#10 +
      '        END '#13#10 +
      '        id_to = :id_from + (:delta - 1); '#13#10 +
      '      END '#13#10 +
      ' '#13#10 +
      '      IF (:rc = 1) THEN '#13#10 +
      '      BEGIN '#13#10 +
      '        id = :id_from; '#13#10 +
      ' '#13#10 +
      '        RDB$SET_CONTEXT(''USER_SESSION'', ''GD_CURRENT_ID'', :id + 1); '#13#10 +
      '        RDB$SET_CONTEXT(''USER_SESSION'', ''GD_LIMIT_ID'', :id_to); '#13#10 +
      ' '#13#10 +
      '        LEAVE; '#13#10 +
      '      END '#13#10 +
      ' '#13#10 +
      '      WHEN ANY DO '#13#10 +
      '      BEGIN '#13#10 +
      '        id = -1; '#13#10 +
      '      END '#13#10 +
      '    END '#13#10 +
      ' '#13#10 +
      '    IF (id = -1) THEN '#13#10 +
      '    BEGIN '#13#10 +
      '      id_to = GEN_ID(gd_g_unique, 1); '#13#10 +
      '      /* '#13#10 +
      '      id = :id_to - 100 + 1; '#13#10 +
      '      RDB$SET_CONTEXT(''USER_SESSION'', ''GD_CURRENT_ID'', :id + 1); '#13#10 +
      '      RDB$SET_CONTEXT(''USER_SESSION'', ''GD_LIMIT_ID'', :id_to); '#13#10 +
      '      */ '#13#10 +
      '    END '#13#10 +
      '  END '#13#10 +
      'END';
    q.ExecQuery;

    q.SQL.Text :=
      'CREATE OR ALTER PROCEDURE gd_p_getnextid '#13#10 +
      '  RETURNS(id INTEGER) '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  EXECUTE PROCEDURE gd_p_getnextid_ex '#13#10 +
      '    RETURNING_VALUES :id; '#13#10 +
      ' '#13#10 +
      '  SUSPEND; '#13#10 +
      'END';
    q.ExecQuery;

    DropTrigger2('gd_db_disconnect_save_id', FTr);
    {
    q.SQL.Text :=
      'CREATE OR ALTER TRIGGER gd_db_disconnect_save_id '#13#10 +
      '  ACTIVE '#13#10 +
      '  ON DISCONNECT '#13#10 +
      '  POSITION 32000 '#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE id_from INTEGER; '#13#10 +
      '  DECLARE VARIABLE id_to INTEGER; '#13#10 +
      'BEGIN '#13#10 +
      '  id_from = COALESCE(RDB$GET_CONTEXT(''USER_SESSION'', ''GD_CURRENT_ID''), 0); '#13#10 +
      '  id_to = COALESCE(RDB$GET_CONTEXT(''USER_SESSION'', ''GD_LIMIT_ID''), 0); '#13#10 +
      ' '#13#10 +
      '  IF (:id_from > 0 AND :id_from <= :id_to) THEN '#13#10 +
      '    IN AUTONOMOUS TRANSACTION DO '#13#10 +
      '      INSERT INTO gd_available_id (id_from, id_to) VALUES (:id_from, :id_to); '#13#10 +
      'END';
    q.ExecQuery;
    }

    q.SQL.Text :=
      'CREATE OR ALTER TRIGGER ac_bi_autoentry FOR ac_autoentry '#13#10 +
      '  ACTIVE '#13#10 +
      '  BEFORE INSERT '#13#10 +
      '  POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  IF (NEW.id IS NULL) THEN '#13#10 +
      '    EXECUTE PROCEDURE gd_p_getnextid_ex '#13#10 +
      '      RETURNING_VALUES NEW.id; '#13#10 +
      'END';
    q.ExecQuery;

    q.SQL.Text := 'GRANT EXECUTE ON PROCEDURE  gd_p_getnextid TO ADMINISTRATOR';
    q.ExecQuery;

    q.SQL.Text := 'GRANT EXECUTE ON PROCEDURE  gd_p_getnextid_ex TO ADMINISTRATOR';
    q.ExecQuery;

    if not DomainExist2('DGENERATORNAME', FTr) then
    begin
      q.SQL.Text := 'CREATE DOMAIN DGENERATORNAME AS VARCHAR(31)';
      q.ExecQuery;
      FTr.Commit;
      FTr.StartTransaction;
    end;

    AddField2('AT_RELATIONS', 'GENERATORNAME', 'DGENERATORNAME', FTr);

    FTr.Commit;
    FTr.StartTransaction;

    q.SQL.Text :=
      'UPDATE OR INSERT INTO fin_versioninfo ' +
      '  VALUES (279, ''0000.0001.0000.0311'', ''14.03.2019'', ''Corrected procs for interval id table'') ' +
      '  MATCHING (id)';
    q.ExecQuery;

    FTr.Commit;
  finally
    q.Free;
    Ftr.Free;
  end;
end;

end.
