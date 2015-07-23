unit mdf_NewDepot;

interface

uses
  IBDatabase, gdModify;

procedure UpdateInventDocument(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, mdf_metadata_unit, gdcInvDocument_unit;

procedure UpdateInventDocument(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
//  gdcInvDocumentType: TgdcInvDocumentType;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;

    FIBSQL := TIBSQL.Create(nil);
    try

      FIBSQL.Transaction := FTransaction;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_NOPRODUCT ''На указанную дату нет остатка товара!''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_DONTCHANGESOURCE ''Нельзя изменить источник!''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'ALTER EXCEPTION INV_E_INVALIDMOVEMENT ''Складское движение создано не корректно!''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_EARLIERMOVEMENT ''Нельзя изменить дату, т.к. было более раннее движение товара!''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_INSUFFICIENTBALANCE ''Недостаточно остатков на указанную дату''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_INCORRECTQUANTITY ''Количество по документу не соответсвует созданному движению!''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_DONTREDUCEAMOUNT ''Нельзя уменьшить количество по позиции''';
      try
        FIBSQL.ExecQuery;
      except
      end;

      FIBSQL.Close;
      FIBSQL.SQL.Text := 'CREATE EXCEPTION INV_E_DONTCHANGEBENEFICIARY ''Нельзя изменить получателя''';
      try
        FIBSQL.ExecQuery;
      except
      end;
      FIBSQL.Close;

      FTransaction.Commit;

      Log('Добавление новых исключений - успешно завершено');

      FTransaction.StartTransaction;

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER GD_AU_DOCUMENT_DATE FOR GD_DOCUMENT ' + #13#10 +
        'ACTIVE AFTER UPDATE POSITION 11 ' + #13#10 +
        'AS ' + #13#10 +
        '  DECLARE VARIABLE UPDATESQL VARCHAR(1024); ' + #13#10 +
        '  DECLARE VARIABLE NAMETABLE VARCHAR(31); ' + #13#10 +
        'BEGIN ' + #13#10 +
        '  IF (((OLD.DOCUMENTDATE <> NEW.DOCUMENTDATE) OR (COALESCE(NEW.DELAYED, 0) <> COALESCE(OLD.DELAYED, 0))) AND NEW.PARENT IS NOT NULL) THEN ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    SELECT R.RELATIONNAME FROM ' + #13#10 +
        '      GD_DOCUMENTTYPE DT ' + #13#10 +
        '        JOIN AT_RELATIONS R ON DT.LINERELKEY = R.ID ' + #13#10 +
        '    WHERE UPPER(DT.CLASSNAME) = ''TGDCINVDOCUMENTTYPE'' AND DT.ID = OLD.DOCUMENTTYPEKEY ' + #13#10 +
        '    INTO :NAMETABLE; ' + #13#10 +
        ' ' + #13#10 +
        '    IF (NAMETABLE IS NOT NULL) THEN ' + #13#10 +
        '    BEGIN ' + #13#10 +
        '      UPDATESQL = ''UPDATE '' || NAMETABLE || '' SET DOCUMENTKEY = DOCUMENTKEY WHERE DOCUMENTKEY = '' || CAST(OLD.ID AS VARCHAR(10)); ' + #13#10 +
        '      EXECUTE STATEMENT :UPDATESQL; ' + #13#10 +
        '    END ' + #13#10 +
        '  END ' + #13#10 +
        'END ';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER GD_AU_DOCUMENT FOR GD_DOCUMENT ' + #13#10 +
        '  AFTER UPDATE ' + #13#10 +
        '  POSITION 0 ' + #13#10 +
        'AS ' + #13#10 +
        'BEGIN ' + #13#10 +
        '  IF (NEW.PARENT IS NULL) THEN ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    IF ((OLD.documentdate <> NEW.documentdate) OR (OLD.number <> NEW.number)  ' + #13#10 +
        '      OR (OLD.companykey <> NEW.companykey) OR (coalesce(OLD.delayed, 0) <> coalesce(NEW.delayed, 0))) THEN ' + #13#10 +
        '    BEGIN ' + #13#10 +
        '      IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN ' + #13#10 +
        '        UPDATE gd_document SET documentdate = NEW.documentdate, ' + #13#10 +
        '          number = NEW.number, companykey = NEW.companykey, delayed = NEW.delayed ' + #13#10 +
        '        WHERE (parent = NEW.ID) ' + #13#10 +
        '          AND ((documentdate <> NEW.documentdate) ' + #13#10 +
        '           OR (number <> NEW.number) OR (companykey <> NEW.companykey) OR (coalesce(delayed, 0) <> coalesce(NEW.delayed, 0))); ' + #13#10 +
        '      ELSE                                                                   ' + #13#10 +
        '        UPDATE gd_document SET documentdate = NEW.documentdate, ' + #13#10 +
        '          companykey = NEW.companykey, delayed = NEW.delayed ' + #13#10 +
        '        WHERE (parent = NEW.ID) ' + #13#10 +
        '          AND ((documentdate <> NEW.documentdate) ' + #13#10 +
        '          OR  (companykey <> NEW.companykey) OR (coalesce(delayed, 0) <> coalesce(NEW.delayed, 0))); ' + #13#10 +
        '    END ' + #13#10 +
        '  END ELSE ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    IF (NEW.editiondate <> OLD.editiondate) THEN ' + #13#10 +
        '      UPDATE gd_document SET editiondate = NEW.editiondate, ' + #13#10 +
        '        editorkey = NEW.editorkey ' + #13#10 +
        '      WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate); ' + #13#10 +
        '  END ' + #13#10 +
        ' ' + #13#10 +
        'END ' + #13#10;
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER gd_bi_document FOR gd_document ' + #13#10 +
        '  BEFORE INSERT ' + #13#10 +
        '  POSITION 0 ' + #13#10 +
        'AS ' + #13#10 +
        'BEGIN ' + #13#10 +
        '  IF (NEW.id IS NULL) THEN ' + #13#10 +
        '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); ' + #13#10 +
        ' ' + #13#10 +
        '  IF (NEW.parent IS NOT NULL) THEN ' + #13#10 +
        '    SELECT DELAYED FROM GD_DOCUMENT WHERE ID = NEW.parent ' + #13#10 +
        '    INTO NEW.delayed; ' + #13#10 +
        ' ' + #13#10 +
        '  /* ' + #13#10 +
        '  теперь эти поля заполняются в бизнес-объекте ' + #13#10 +
        ' ' + #13#10 +
        '  IF (NEW.creationdate IS NULL) THEN ' + #13#10 +
        '    NEW.creationdate = CURRENT_TIMESTAMP; ' + #13#10 +
        ' ' + #13#10 +
        '  IF (NEW.editiondate IS NULL) THEN ' + #13#10 +
        '    NEW.editiondate = CURRENT_TIMESTAMP; ' + #13#10 +
        '  */ ' + #13#10 +
        'END ';
      FIBSQL.ExecQuery;
      FIBSQL.Close;


      FIBSQL.SQL.Text :=
        'CREATE OR ALTER TRIGGER INV_BU_MOVEMENT FOR INV_MOVEMENT ' + #13#10 +
        'active before update position 0 ' + #13#10 +
        'AS ' + #13#10 +
        '  DECLARE VARIABLE balance NUMERIC(15, 4); ' + #13#10 +
        '  DECLARE VARIABLE controlremains INTEGER; ' + #13#10 +
        'BEGIN ' + #13#10 +
        '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'') IS NULL) THEN ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    IF (NEW.documentkey <> OLD.documentkey) THEN ' + #13#10 +
        '      EXCEPTION inv_e_movementchange; ' + #13#10 +
        ' ' + #13#10 +
        '    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN ' + #13#10 +
        '    BEGIN ' + #13#10 +
        '      IF (OLD.debit <> 0) THEN ' + #13#10 +
        '      BEGIN ' + #13#10 +
        '        SELECT balance FROM inv_balance ' + #13#10 +
        '        WHERE contactkey = OLD.contactkey ' + #13#10 +
        '          AND cardkey = OLD.cardkey ' + #13#10 +
        '        INTO :balance; ' + #13#10 +
        '        IF (COALESCE(:balance, 0) < OLD.debit) THEN ' + #13#10 +
        '          EXCEPTION INV_E_INVALIDMOVEMENT; ' + #13#10 +
        '      END ' + #13#10 +
        '    END ELSE ' + #13#10 +
        '    BEGIN ' + #13#10 +
        '      IF (OLD.debit > NEW.debit) THEN ' + #13#10 +
        '      BEGIN ' + #13#10 +
        '        SELECT balance FROM inv_balance ' + #13#10 +
        '        WHERE contactkey = OLD.contactkey ' + #13#10 +
        '          AND cardkey = OLD.cardkey ' + #13#10 +
        '        INTO :balance; ' + #13#10 +
        '        balance = COALESCE(:balance, 0); ' + #13#10 +
        '        IF ((:balance > 0) AND (:balance < OLD.debit - NEW.debit)) THEN ' + #13#10 +
        '          EXCEPTION INV_E_DONTREDUCEAMOUNT; ' + #13#10 +
        '      END ELSE ' + #13#10 +
        '      BEGIN ' + #13#10 +
        '        IF (NEW.credit > OLD.credit) THEN ' + #13#10 +
        '        BEGIN ' + #13#10 +
        '          SELECT balance FROM inv_balance ' + #13#10 +
        '          WHERE contactkey = OLD.contactkey ' + #13#10 +
        '            AND cardkey = OLD.cardkey ' + #13#10 +
        '          INTO :balance; ' + #13#10 +
        '          balance = COALESCE(:balance, 0); ' + #13#10 +
        '          controlremains = RDB$GET_CONTEXT(''USER_TRANSACTION'', ''CONTROLREMAINS''); ' + #13#10 +
        '          IF (:controlremains IS NULL) THEN ' + #13#10 +
        '          BEGIN ' + #13#10 +
        '            IF ((:balance > 0) AND (:balance < NEW.credit - OLD.credit)) THEN ' + #13#10 +
        '              EXCEPTION INV_E_INSUFFICIENTBALANCE; ' + #13#10 +
        '          END ' + #13#10 +
        '          ELSE ' + #13#10 +
        '            IF ((:controlremains <> 0) and (:balance < NEW.credit - OLD.credit)) THEN ' + #13#10 +
        '              EXCEPTION INV_E_INSUFFICIENTBALANCE; ' + #13#10 +
        '        END ' + #13#10 +
        '      END ' + #13#10 +
        '    END ' + #13#10 +
        '  END ' + #13#10 +
        'END ' + #13#10;

      FIBSQL.ExecQuery;
      FIBSQL.Close;

      Log('Изменены триггера на gd_document и inv_movement');

      FIBSQL.SQL.Text :=
        'CREATE OR ALTER PROCEDURE inv_insert_card (id INTEGER, parent INTEGER) ' + #13#10 +
        'AS ' + #13#10 +
        '  declare variable sqltext varchar(32000); ' + #13#10 +
        '  declare variable fieldname varchar(31); ' + #13#10 +
        'BEGIN ' + #13#10 +
        '  sqltext = ''''; ' + #13#10 +
        '  FOR ' + #13#10 +
        '    select fieldname from AT_RELATION_FIELDS ' + #13#10 +
        '    where relationname = ''INV_CARD'' and fieldname <> ''ID'' and fieldname <> ''PARENT'' ' + #13#10 +
        '    into :fieldname ' + #13#10 +
        '  DO ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    if (sqltext <> '''') then ' + #13#10 +
        '      sqltext = sqltext || '',''; ' + #13#10 +
        '    sqltext = sqltext || fieldname; ' + #13#10 +
        '  END ' + #13#10 +
        ' ' + #13#10 +
        '  sqltext = ''INSERT INTO inv_card (id, parent, '' || sqltext || '')'' || ' + #13#10 +
        '    '' select '' || CAST(ID as VARCHAR(10)) || '','' || CAST(PARENT as VARCHAR(10)) || '','' || ' + #13#10 +
        '    sqltext || '' from inv_card where id = '' || CAST(parent as VARCHAR(10));  ' + #13#10 +
        ' ' + #13#10 +
        '  execute statement sqltext; ' + #13#10 +
        'END ' + #13#10;
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FIBSQL.SQL.Text := 'GRANT EXECUTE ON PROCEDURE INV_INSERT_CARD TO ADMINISTRATOR';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      Log('Создана процедура INV_INSERT_CARD ');


        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (222, ''0000.0001.0000.0254'', ''22.07.2015'', ''Modified invenotry document'') '#13#10 +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;
        FIBSQL.Close;

      FTransaction.Commit;

  {    gdcInvDocumentType := TgdcInvDocumentType.Create(nil);
      try
        gdcInvDocumentType.ExtraConditions.Add('classname = ''TgdcInvDocumentType''');
        gdcInvDocumentType.Open;
        while not gdcInvDocumentType.EOF do
        begin
          gdcInvDocumentType.Edit;
          gdcInvDocumentType.Post;
          gdcInvDocumentType.Next;
        end;
      finally
        gdcInvDocumentType.Free;
      end;
    }
    finally
      FIBSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
