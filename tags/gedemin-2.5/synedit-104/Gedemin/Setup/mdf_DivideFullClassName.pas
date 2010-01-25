unit mdf_DivideFullClassName;

interface

uses
  IBDatabase, gdModify;

procedure DivideFullClassName(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, Windows;

{$HINTS OFF}
procedure DivideFullClassName(IBDB: TIBDatabase; Log: TModifyLog);
var
  LTransaction: TIBTransaction;
  LIBSQL, LModifyIBSQL: TIBSQL;
  LClassName, LSubType: String;
  N, E: Integer;

  procedure AddDomains;
  var
    DomainIBSQL: TIBSQL;
  begin
    DomainIBSQL := TIBSQL.Create(nil);
    try
      DomainIBSQL.Transaction := LTransaction;
      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        DomainIBSQL.SQL.Text :=
          'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DSUBTYPE''';
        DomainIBSQL.ExecQuery;
        if DomainIBSQL.Eof then
        begin
          DomainIBSQL.Close;
          DomainIBSQL.SQL.Text :=
            'CREATE DOMAIN dsubtype AS '#13#10 +
            'VARCHAR(31) CHARACTER SET WIN1251 '#13#10 +
            'COLLATE PXW_CYRL';
          try
            DomainIBSQL.ExecQuery;
            Log('Добавлен домен DSUBTYPE.');
          except
            Log('Не удалось добавить домен DSUBTYPE.');
            raise;
          end;
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;

      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        DomainIBSQL.SQL.Text :=
          'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DGDCNAME''';
        DomainIBSQL.ExecQuery;
        if DomainIBSQL.Eof then
        begin
          DomainIBSQL.Close;
          DomainIBSQL.SQL.Text :=
            'CREATE DOMAIN DGDCNAME AS '#13#10 +
            'VARCHAR(64) CHARACTER SET WIN1251 '#13#10 +
            'COLLATE PXW_CYRL';
          try
            DomainIBSQL.ExecQuery;
            Log('Добавлен домен DGDCCLASSNAME.');
          except
            Log('Не удалось добавить домен DCLASSNAME.');
            raise;
          end;
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;

    finally
      DomainIBSQL.Free;
    end;
  end;

  procedure Modify_Evt_Object;
  var
    TableIBSQL: TIBSQL;
  begin
    TableIBSQL := TIBSQL.Create(nil);
    Log('Модификация таблицы Evt_Object');
    try
      TableIBSQL.Transaction := LTransaction;

      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        TableIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relation_fields '#13#10 +
          'WHERE RDB$RELATION_NAME = ''EVT_OBJECT'' '#13#10 +
          'AND rdb$field_name = ''OBJECTNAME''';

        TableIBSQL.ExecQuery;
        if TableIBSQL.Eof then
        begin
          TableIBSQL.Close;
          TableIBSQL.SQL.Text :=
            'ALTER TABLE evt_object ADD ObjectName DGDCNAME';
//            'ALTER TABLE evt_object ADD ObjectName DNAME DEFAULT '''' NOT NULL'#13#10 +
//            'COLLATE PXW_CYRL';
          try
            TableIBSQL.ExecQuery;
            Log('Добавлено поле OBJECTNAME в таблицу Evt_Object.');
          except
            Log('Не удалось добавить поля OBJECTNAME в таблицу Evt_Object.');
            raise;
          end;
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;


      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        TableIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relation_fields '#13#10 +
          'WHERE RDB$RELATION_NAME = ''EVT_OBJECT'' '#13#10 +
          'AND rdb$field_name = ''SUBTYPE''';

        TableIBSQL.ExecQuery;
        if TableIBSQL.Eof then
        begin
          TableIBSQL.Close;
          TableIBSQL.SQL.Text :=
            'ALTER TABLE evt_object ADD SubType DSUBTYPE';
//            'ALTER TABLE evt_object ADD SubType DSUBTYPE DEFAULT '''' NOT NULL'#13#10 +
//            'COLLATE PXW_CYRL';
          try
            TableIBSQL.ExecQuery;
            Log('Добавлено поле SUBTYPE в таблицу Evt_Object.');
          except
            Log('Не удалось добавить поля SUBTYPE в таблицу Evt_Object.');
            raise;
          end;
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;

      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        TableIBSQL.SQL.Text :=
          'select * from rdb$relation_fields '#13#10 +
          'where RDB$RELATION_NAME = ''EVT_OBJECT'' '#13#10 +
          'and rdb$field_name = ''CLASSNAME''';

        TableIBSQL.ExecQuery;
        if TableIBSQL.Eof then
        begin
          TableIBSQL.Close;
          TableIBSQL.SQL.Text :=
            'ALTER TABLE evt_object ADD ClassName DGDCNAME';
//            'ALTER TABLE evt_object ADD ClassName DNAME DEFAULT '''' NOT NULL'#13#10 +
//            'COLLATE PXW_CYRL';
          try
            TableIBSQL.ExecQuery;
            Log('Добавлено поле GDCCLASSNAME в таблицу Evt_Object.');
          except
            Log('Не удалось добавить поля CLASSNAME в таблицу Evt_Object.');
            raise;
          end;
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;

    finally
      TableIBSQL.Free;
    end;
  end;

  procedure DeleteIndex;
  var
    IndexIBSQL: TIBSQL;
  begin
    IndexIBSQL := TIBSQL.Create(nil);
    try
      IndexIBSQL.Transaction := LTransaction;
      try
        if not LTransaction.Active then
          LTransaction.StartTransaction;
        IndexIBSQL.SQL.Text :=
          'SELECT * FROM rdb$index_segments WHERE rdb$index_name = ''EVT_X_OBJECT_UNIQUE''';
        IndexIBSQL.ExecQuery;

        if not IndexIBSQL.Eof then
        begin
          IndexIBSQL.Close;
          IndexIBSQL.SQL.Text :=
            'ALTER INDEX evt_x_object_unique INACTIVE';
          IndexIBSQL.ExecQuery;
          IndexIBSQL.Close;
          if LTransaction.InTransaction then
            LTransaction.Commit;

          if not LTransaction.Active then
            LTransaction.StartTransaction;
          IndexIBSQL.SQL.Text :=
            'DROP INDEX evt_x_object_unique';
          IndexIBSQL.ExecQuery;
          Log('Удален индекс EVT_X_OBJECT_UNIQUE');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;
    finally
      IndexIBSQL.Free;
    end;
  end;

  procedure  CreateTriggers;
  var
    TriggerIBSQL: TIBSQL;
  begin
    TriggerIBSQL := TIBSQL.Create(nil);
    try
      TriggerIBSQL.Transaction := LTransaction;
      try
        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''EVT_E_RECORDFOUND''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.SQL.Text :=
            'CREATE EXCEPTION EVT_E_RECORDFOUND ''Object or Class with such a parameters is already exist''';
          TriggerIBSQL.ExecQuery;
          Log('Добавлено исключение EVT_E_RECORDFOUND');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;

        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''EVT_E_RECORDINCORRECT''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.SQL.Text :=
            'CREATE EXCEPTION EVT_E_RECORDINCORRECT ''Do not insert or update this data.''';
          TriggerIBSQL.ExecQuery;
          Log('Добавлено исключение EVT_E_RECORDFOUND');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;

        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''EVT_E_INCORRECTVERSION''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.SQL.Text :=
            'CREATE EXCEPTION EVT_E_INCORRECTVERSION ''Incorrect version Gedemin for insert in evt_object Table.''';
          TriggerIBSQL.ExecQuery;
          Log('Добавлено исключение EVT_E_RECORDFOUND');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;


        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''EVT_BI_OBJECT1''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.ParamCheck := False;
          TriggerIBSQL.SQL.Text :=
            'CREATE TRIGGER EVT_BI_OBJECT1 FOR EVT_OBJECT'#13#10 +
            'ACTIVE BEFORE INSERT POSITION 1'#13#10 +
            'AS'#13#10 +
            'BEGIN'#13#10 +
            '  /* Если старая версия Гедемина, то возвращаем ошибку*/'#13#10 +
            '  IF ((NOT NEW.name is NULL) AND'#13#10 +
            '     (NEW.objectname is NULL) AND'#13#10 +
            '     (NEW.classname is NULL) AND'#13#10 +
            '     (NEW.subtype is NULL))'#13#10 +
            '  THEN'#13#10 +
            '    EXCEPTION  EVT_E_INCORRECTVERSION;'#13#10 +
            ''#13#10 +
            '  /* Проверяет корректность вводимых данных */'#13#10 +
            ''#13#10 +
            '  IF (NEW.objectname is NULL) THEN'#13#10 +
            '    NEW.objectname = '''';'#13#10 +
            '  IF (NEW.classname is NULL) THEN'#13#10 +
            '    NEW.classname = '''';'#13#10 +
            '  IF (NEW.subtype is NULL) THEN'#13#10 +
            '    NEW.subtype = '''';'#13#10 +
            ''#13#10 +
            '  /* Проверяет корректность вводимых данных */'#13#10 +
            '  IF'#13#10 +
            '    ('#13#10 +
            '    ((NEW.objectname = '''') and (NEW.classname = '''')) or'#13#10 +
            '    ((NEW.subtype <> '''') and ((NEW.objectname <> '''') or'#13#10 +
            '     (NEW.classname = '''')))'#13#10 +
            '    ) then'#13#10 +
            '  BEGIN'#13#10 +
            '    EXCEPTION EVT_E_RECORDINCORRECT;'#13#10 +
            '  END'#13#10 +
            'END';

          TriggerIBSQL.ExecQuery;
          TriggerIBSQL.ParamCheck := True;
          Log('Добавлен триггер EVT_BI_OBJECT1');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;


        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''EVT_BI_OBJECT2''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.ParamCheck := False;
          TriggerIBSQL.SQL.Text :=
            'CREATE TRIGGER EVT_BI_OBJECT2 FOR EVT_OBJECT'#13#10 +
            'ACTIVE BEFORE INSERT POSITION 2'#13#10 +
            'AS'#13#10 +
            'BEGIN'#13#10 +
            '  /* Проверяет уникальность объекта или класса с подтипом*/'#13#10 +
            '  IF'#13#10 +
            '    (EXISTS(SELECT * FROM evt_object'#13#10 +
            '    WHERE'#13#10 +
            '    (UPPER(objectname) = UPPER(NEW.objectname))  AND'#13#10 +
            '    (UPPER(classname) = UPPER(NEW.classname)) AND'#13#10 +
            '    (parentindex = NEW.parentindex) AND'#13#10 +
            '    (UPPER(subtype) = UPPER(NEW.subtype)) AND'#13#10 +
            '    (id <> NEW.id)))'#13#10 +
            '  THEN'#13#10 +
            '  BEGIN'#13#10 +
            '    EXCEPTION EVT_E_RECORDFOUND;'#13#10 +
            '  END'#13#10 +
            ''#13#10 +
            '  /* Заполняет поля name, objecttype для поддержки */'#13#10 +
            '  /* старой версии Гедемина */'#13#10 +
            '  IF (NEW.classname = '''') THEN'#13#10 +
            '  BEGIN'#13#10 +
            '    NEW.objecttype = 0;'#13#10 +
            '    NEW.name = NEW.objectname;'#13#10 +
            '  END ELSE'#13#10 +
            '    BEGIN'#13#10 +
            '      NEW.objecttype = 1;'#13#10 +
            '      IF (NEW.subtype = '''') THEN'#13#10 +
            '      BEGIN'#13#10 +
            '        NEW.name = NEW.classname;'#13#10 +
            '      END ELSE'#13#10 +
            '        NEW.name = NEW.classname || NEW.subtype;'#13#10 +
            '    END'#13#10 +
            'END';
          TriggerIBSQL.ExecQuery;
          TriggerIBSQL.ParamCheck := True;
          Log('Добавлен триггер EVT_BI_OBJECT2');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;

        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''EVT_BU_OBJECT1''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.ParamCheck := False;
          TriggerIBSQL.SQL.Text :=
            'CREATE TRIGGER EVT_BU_OBJECT1 FOR EVT_OBJECT'#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 1'#13#10 +
            'AS'#13#10 +
            'BEGIN'#13#10 +
            '  /* Если старая версия Гедемина, то возвращаем ошибку*/'#13#10 +
            '  IF ((NOT NEW.name is NULL) AND'#13#10 +
            '     (NEW.objectname is NULL) AND'#13#10 +
            '     (NEW.classname is NULL) AND'#13#10 +
            '     (NEW.subtype is NULL))'#13#10 +
            '  THEN'#13#10 +
            '    EXCEPTION  EVT_E_INCORRECTVERSION;'#13#10 +
            ''#13#10 +
            '  /* Проверяет корректность вводимых данных */'#13#10 +
            ''#13#10 +
            '  IF (NEW.objectname is NULL) THEN'#13#10 +
            '    NEW.objectname = '''';'#13#10 +
            '  IF (NEW.classname is NULL) THEN'#13#10 +
            '    NEW.classname = '''';'#13#10 +
            '  IF (NEW.subtype is NULL) THEN'#13#10 +
            '    NEW.subtype = '''';'#13#10 +
            ''#13#10 +
            '  /* Проверяет корректность вводимых данных */'#13#10 +
            '  IF'#13#10 +
            '    ('#13#10 +
            '    ((NEW.objectname = '''') and (NEW.classname = '''')) or'#13#10 +
            '    ((NEW.subtype <> '''') and ((NEW.objectname <> '''') or'#13#10 +
            '     (NEW.classname = '''')))'#13#10 +
            '    ) then'#13#10 +
            '  BEGIN'#13#10 +
            '    EXCEPTION EVT_E_RECORDINCORRECT;'#13#10 +
            '  END'#13#10 +
            'END';
          TriggerIBSQL.ExecQuery;
          TriggerIBSQL.ParamCheck := True;
          Log('Добавлен триггер EVT_BU_OBJECT1');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;

        if not LTransaction.Active then
          LTransaction.StartTransaction;
        TriggerIBSQL.Close;
        TriggerIBSQL.SQL.Text :=
          'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''EVT_BU_OBJECT2''';
        TriggerIBSQL.ExecQuery;
        if TriggerIBSQL.Eof then
        begin
          TriggerIBSQL.Close;
          TriggerIBSQL.ParamCheck := False;
          TriggerIBSQL.SQL.Text :=
            'CREATE TRIGGER EVT_BU_OBJECT2 FOR EVT_OBJECT'#13#10 +
            'ACTIVE BEFORE UPDATE POSITION 2'#13#10 +
            'AS'#13#10 +
            'BEGIN'#13#10 +
            '  /* Проверяет уникальность объекта или класса с подтипом*/'#13#10 +
            '  IF'#13#10 +
            '    (EXISTS(SELECT * FROM evt_object'#13#10 +
            '    WHERE'#13#10 +
            '    (UPPER(objectname) = UPPER(NEW.objectname))  AND'#13#10 +
            '    (UPPER(classname) = UPPER(NEW.classname)) AND'#13#10 +
            '    (parentindex = NEW.parentindex) AND'#13#10 +
            '    (UPPER(subtype) = UPPER(NEW.subtype)) AND'#13#10 +
            '    (id <> NEW.id)))'#13#10 +
            '  THEN'#13#10 +
            '  BEGIN'#13#10 +
            '    EXCEPTION EVT_E_RECORDFOUND;'#13#10 +
            '  END'#13#10 +
            ''#13#10 +
            '  /* Заполняет поля name, objecttype для поддержки */'#13#10 +
            '  /* старой версии Гедемина */'#13#10 +
            '  IF (NEW.classname = '''') THEN'#13#10 +
            '  BEGIN'#13#10 +
            '    NEW.objecttype = 0;'#13#10 +
            '    NEW.name = NEW.objectname;'#13#10 +
            '  END ELSE'#13#10 +
            '    BEGIN'#13#10 +
            '      NEW.objecttype = 1;'#13#10 +
            '      IF (NEW.subtype = '''') THEN'#13#10 +
            '      BEGIN'#13#10 +
            '        NEW.name = NEW.classname;'#13#10 +
            '      END ELSE'#13#10 +
            '        NEW.name = NEW.classname || NEW.subtype;'#13#10 +
            '    END'#13#10 +
            'END';
          TriggerIBSQL.ExecQuery;
          TriggerIBSQL.ParamCheck := True;
          Log('Добавлен триггер EVT_BU_OBJECT2');
        end;
        if LTransaction.InTransaction then
          LTransaction.Commit;
      except
        on E: Exception do
        begin
          if LTransaction.InTransaction then
            LTransaction.Rollback;
          Log(E.Message);
          raise;
        end;
      end;
    finally
      TriggerIBSQL.Free;
    end;
  end;

begin
  LTransaction := TIBTransaction.Create(nil);
  try
    LTransaction.DefaultDatabase := IBDB;
    try
      if not LTransaction.Active then
        LTransaction.StartTransaction;
      try
        LIBSQL := TIBSQL.Create(nil);
        try
          LIBSQL.Transaction := LTransaction;
          // если поля OBJECTTYPE нет в таблице EVT_OBJECT, то
          // разделение уже сделано
          LIBSQL.SQL.Text :=
            'select * from rdb$relation_fields'#13#10 +
              'where RDB$RELATION_NAME = ''EVT_OBJECT'' AND'#13#10 +
              '(rdb$field_name in (''OBJECTNAME'', ''CLASSNAME'', ''SUBTYPE''))';

          Log('Разделение "полного" имени класса на имя класса и подтип.');
          LIBSQL.ExecQuery;
          if LIBSQL.Eof  then
          begin
            LIBSQL.Close;

            AddDomains;
            Modify_Evt_Object;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object ADD tmpobjecttype DSMALLINT';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'UPDATE evt_object SET objectname = name, tmpobjecttype = objecttype';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            DeleteIndex;
            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object DROP name';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object ADD name DGDCNAME COLLATE PXW_CYRL';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object DROP objecttype';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object ADD objecttype DSMALLINT';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'UPDATE evt_object SET name = objectname, objecttype = tmpobjecttype,'#13#10 +
              '  classname = '''', subtype =''''';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            if not LTransaction.Active then
              LTransaction.StartTransaction;
            LIBSQL.SQL.Text :=
              'ALTER TABLE evt_object DROP tmpobjecttype';
            LIBSQL.ExecQuery;
            LIBSQL.Close;
            if LTransaction.InTransaction then
              LTransaction.Commit;

            CreateTriggers;

            Log('"Полное" имя класса разделено на имя класса и подтип');
            LIBSQL.Close;
          end;

          if not LTransaction.Active then
            LTransaction.StartTransaction;

          if LIBSQL.Open then
            LIBSQL.Close;
          // удаление лишних классов
          if not LTransaction.Active then
            LTransaction.StartTransaction;
          if LIBSQL.Open then
            LIBSQL.Close;
          LIBSQL.SQL.Text :=
            'DELETE FROM evt_object WHERE id IN'#13#10 +
            ' (SELECT obj.id FROM evt_object obj'#13#10 +
            '  WHERE  (obj.objecttype = 1 AND'#13#10 +
            '    (NOT obj.id in (SELECT objectkey FROM evt_objectevent)) AND'#13#10 +
            '    (NOT EXISTS(SELECT parent FROM evt_object WHERE parent = obj.id)) AND'#13#10 +
            '    (NOT EXISTS(SELECT modulecode FROM gd_function WHERE modulecode = obj.id))))';
          LIBSQL.ExecQuery;
          LIBSQL.Close;
          Log('Удалены лишние классы');

          LIBSQL.SQL.Text :=
            'SELECT obj.name, obj.id, prnt.name as owner FROM evt_object obj LEFT JOIN '#13#10 +
            'evt_object prnt ON '#13#10 +
            'obj.parent = prnt.id WHERE obj.objecttype = 1 AND obj.name <> '''' ORDER BY obj.id DESC';
          LIBSQL.ExecQuery;


          LModifyIBSQL := TIBSQL.Create(nil);
          try
            LModifyIBSQL.Transaction := LTransaction;
            while not LIBSQL.Eof do
            begin
              LClassName := LIBSQL.FieldByName('name').AsString;
              if Length(LClassName) > 0 then
              begin
                LSubType := '';
                Val(LClassName[Length(LClassName)], N, E);
                if ((E = 0) or (Pos('USR_', AnsiUpperCase(LClassName)) > 0)) and
                  (Pos(AnsiUpperCase(LIBSQL.FieldByName('owner').AsString),
                  AnsiUpperCase(LClassName)) = 1) then
                begin
                  LSubType := Copy(LClassName,
                    Length(LIBSQL.FieldByName('owner').AsString) + 1, Length(LClassName));
                  LClassName := Copy(LClassName, 1,
                    Length(LIBSQL.FieldByName('owner').AsString));
                end;
                if LSubType <> '' then
                begin
                  LModifyIBSQL.SQL.Text :=
                    'UPDATE Evt_Object SET objectname = NULL, '#13#10 +
                    '  classname = :classname, subtype = :subtype'#13#10 +
                    '  WHERE id = :id AND classname = ''''';

                  LModifyIBSQL.Params[0].AsString := LClassName;
                  LModifyIBSQL.Params[1].AsString := LSubType;
                  LModifyIBSQL.Params[2].AsInteger := LIBSQL.FieldByName('id').AsInteger;
                end else
                  begin
                    LModifyIBSQL.SQL.Text :=
                      'UPDATE Evt_Object SET objectname = NULL, '#13#10 +
                      '  classname = :classname, subtype = null'#13#10 +
                      '  WHERE id = :id AND classname = ''''';
                    LModifyIBSQL.Params[0].AsString := LClassName;
                    LModifyIBSQL.Params[1].AsInteger := LIBSQL.FieldByName('id').AsInteger;
                  end;
                LModifyIBSQL.ExecQuery;
                LModifyIBSQL.Close;
              end;
              LIBSQL.Next;
            end;
          finally
            if LTransaction.InTransaction then
              LTransaction.Commit;
            LModifyIBSQL.Free;
          end;

          LIBSQL.Close;
          if LTransaction.InTransaction then
            LTransaction.Commit;

        finally
          LIBSQL.Free;
        end;
      finally
        if LTransaction.InTransaction then
          LTransaction.Commit;
      end;
    except
      Log('Ошибка: Разделение "полного" имени класса не удалось.');
    end;
  finally
    LTransaction.Free;
  end;
  Log('Разделение "полного" имени класса закончено.');
end;
{$HINTS ON}

end.
