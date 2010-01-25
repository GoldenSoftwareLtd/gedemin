unit mdf_AutoTransactionTables;

interface

uses
  IBDatabase, gdModify;

procedure AddAutoTransactionTables(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  CreateAutoTransactionTablesSQL: array[0..16] of String =
    (
      'CREATE TABLE AC_AUTOTRRECORD ( '#13#10 +
      '    ID                DINTKEY,'#13#10 +
      '    DISABLED          DDISABLED,'#13#10 +
      '    EDITIONDATE       DEDITIONDATE,'#13#10 +
      '    EDITORKEY         DINTKEY,'#13#10 +
      '    AFULL             DSECURITY NOT NULL,'#13#10 +
      '    ACHAG             DSECURITY NOT NULL,'#13#10 +
      '    AVIEW             DSECURITY NOT NULL,'#13#10 +
      '    TRANSACTIONKEY    DINTKEY,'#13#10 +
      '    DESCRIPTION       DTEXT180 NOT NULL,'#13#10 +
      '    FUNCTIONKEY       DINTKEY NOT NULL,'#13#10 +
      '    SHOWINEXPLORER    DBOOLEAN,'#13#10 +
      '    FUNCTIONTEMPLATE  DBLOB80'#13#10 +
      ')'#13#10,

      'ALTER TABLE AC_AUTOTRRECORD ADD PRIMARY KEY (ID)',

      'ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FKAC_AUTOTRRECORD148 FOREIGN KEY (TRANSACTIONKEY) REFERENCES AC_TRANSACTION (ID) ON UPDATE CASCADE',
      'ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD FOREIGN KEY (FUNCTIONKEY) REFERENCES GD_FUNCTION (ID)',
      'ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD748231740 FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE',

      '/* Trigger: BI_AC_AUTOTRRECORD */'#13#10 +
      'CREATE TRIGGER BI_AC_AUTOTRRECORD FOR AC_AUTOTRRECORD'#13#10 +
      'ACTIVE BEFORE INSERT POSITION 0'#13#10 +
      'AS'#13#10 +
      'BEGIN      '#13#10 +
      '  IF (NEW.id IS NULL) THEN'#13#10 +
      '    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);'#13#10 +
      'END'#13#10,

      '/* Trigger: BI_AC_AUTOTRRECORD5 */'#13#10 +
      'CREATE TRIGGER BI_AC_AUTOTRRECORD5 FOR AC_AUTOTRRECORD'#13#10 +
      'ACTIVE BEFORE INSERT POSITION 5'#13#10 +
      'AS'#13#10 +
      ' BEGIN'#13#10 +
      '   IF (NEW.editorkey IS NULL) THEN'#13#10 +
      '     NEW.editorkey = 650002;'#13#10 +
      '   IF (NEW.editiondate IS NULL) THEN'#13#10 +
      '     NEW.editiondate = CURRENT_TIMESTAMP;'#13#10 +
      ' END'#13#10,


      '/* Trigger: BU_AC_AUTOTRRECORD5 */'#13#10 +
      'CREATE TRIGGER BU_AC_AUTOTRRECORD5 FOR AC_AUTOTRRECORD'#13#10 +
      'ACTIVE BEFORE UPDATE POSITION 5'#13#10 +
      'AS'#13#10 +
      ' BEGIN'#13#10 +
      '   IF (NEW.editorkey IS NULL) THEN'#13#10 +
      '     NEW.editorkey = 650002;'#13#10 +
      '   IF (NEW.editiondate IS NULL) THEN'#13#10 +
      '     NEW.editiondate = CURRENT_TIMESTAMP;'#13#10 +
      ' END'#13#10,

     ' /* Privileges of roles */'#13#10 +
     ' GRANT ALL ON AC_AUTOTRRECORD TO ADMINISTRATOR'#13#10,

     'CREATE TABLE AC_AUTOENTRY ( '#13#10 +
     '     ID             DINTKEY NOT NULL, '#13#10 +
     '     ENTRYKEY       DINTKEY NOT NULL, '#13#10 +
     '     TRRECORDKEY    DINTKEY NOT NULL, '#13#10 +
     '     BEGINDATE      DDATE_NOTNULL NOT NULL, '#13#10 +
     '     ENDDATE        DDATE_NOTNULL NOT NULL, '#13#10 +
     '     CREDITACCOUNT  DINTKEY NOT NULL, '#13#10 +
     '     DEBITACCOUNT   DINTKEY NOT NULL '#13#10 +
     ' ) ',

     ' ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT PK_AC_AUTOENTRY PRIMARY KEY (ID) ',

     ' ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_CREDIT FOREIGN KEY (CREDITACCOUNT) REFERENCES AC_ACCOUNT (ID)',
     ' ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_DEBIT FOREIGN KEY (DEBITACCOUNT) REFERENCES AC_ACCOUNT (ID)',
     ' ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_ENTRYKEY FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID) ON DELETE CASCADE',
     ' ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_TRRECORDKEY FOREIGN KEY (TRRECORDKEY) REFERENCES AC_AUTOTRRECORD (ID) ON DELETE CASCADE',

     ' ALTER TABLE AC_TRANSACTION ADD AUTOTRANSACTION  DBOOLEAN',
     
     'INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) VALUES ( ' +
     '714050, 714000, ''Автоматические хоз. операции'', null, ''Tgdc_frmAutoTransaction'', NULL, 17 )'
    );

procedure AddAutoTransactionTables(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  TablesFound: String;
  I: Integer;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Log('Автоматические операции: Добавление таблиц');
        Transaction := FTransaction;
        SQL.Text :=
          'SELECT * FROM rdb$relations ' +
          'WHERE ' +
          '  rdb$relation_name = ''AC_AUTOENTRY'' OR' +
          '  rdb$relation_name = ''AC_AUTOTRRECORD''';
        ExecQuery;
        TablesFound := '';
        if not Eof then
        begin
          while not Eof do
          begin
            if TablesFound > '' then
              TablesFound := TablesFound +  ', ' +
                Trim(FieldByName('rdb$relation_name').AsString)
            else
              TablesFound := Trim(FieldByName('rdb$relation_name').AsString);
            Next;
          end;
          Log('Автоматические операции: Обнаружены следующие таблицы ' + TablesFound + '.');
          Log('Автоматические операции: Метаданные не добавлены.');
          Exit;
        end;

        for I := 0 to Length(CreateAutoTransactionTablesSQL) - 1 do
        begin
          Close;
          if not Transaction.Active then
            Transaction.StartTransaction;
          SQL.Text := CreateAutoTransactionTablesSQL[I];
          ExecQuery;
          Transaction.Commit;
        end;


        Log('Автоматические операции: Добавление успешно завершено.');

        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
        Log('Автоматические операции: Ошибка при добавление метаданных');
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
 