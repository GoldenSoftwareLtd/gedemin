unit mdf_ModifyInvent;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit;

procedure CreateNewException(IBDB: TIBDatabase; Log: TModifyLog);

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

procedure CreateNewException(IBDB: TIBDatabase; Log: TModifyLog);
var
  i: Integer;
  FTr: TIBTransaction;
  q: TIBSQL;
begin
  FTr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTr.DefaultDatabase := IBDB;
    FTr.StartTransaction;

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

end.
