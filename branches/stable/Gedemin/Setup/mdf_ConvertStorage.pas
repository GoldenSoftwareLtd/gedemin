unit mdf_ConvertStorage;

interface

uses
  IBDatabase, gdModify;

procedure ConvertStorage(IBDB: TIBDatabase; Log: TModifyLog);
procedure AddEdtiorKeyEditionDate2Storage(IBDB: TIBDatabase; Log: TModifyLog);
procedure DropLBRBStorageTree(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit, gsStorage,
  {gdcLBRBTreeMetaData,} gdcStorage_Types;

const
  cCreateDomain =
    'CREATE DOMAIN dstorage_data_type AS CHAR(1) NOT NULL                                 '#13#10 +
    '  CHECK(VALUE IN (                                                                   '#13#10 +
    '    ''G'',   /* корень глобального хранилища                                      */ '#13#10 +
    '    ''U'',   /* корень пользовательского хранилища, int_data -- ключ пользователя */ '#13#10 +
    '    ''O'',   /* корень хранилища компании, int_data -- ключ компании              */ '#13#10 +
    '    ''T'',   /* корень хранилища р.стола, int_data -- ключ р.стола                */ '#13#10 +
    '    ''F'',   /* папка                                                             */ '#13#10 +
    '    ''S'',   /* строка                                                            */ '#13#10 +
    '    ''I'',   /* целое число                                                       */ '#13#10 +
    '    ''C'',   /* дробное число                                                     */ '#13#10 +
    '    ''L'',   /* булевский тип                                                     */ '#13#10 +
    '    ''D'',   /* дата и время                                                      */ '#13#10 +
    '    ''B''    /* двоичный объект                                                   */ '#13#10 +
    '  )) ';

  cCreateTable =
    'CREATE TABLE gd_storage_data ( '#13#10 +
    '  id             dintkey, '#13#10 +
    '  /*lb             dlb,*/ '#13#10 +
    '  /*rb             drb,*/ '#13#10 +
    '  parent         dparent, '#13#10 +
    '  name           dtext120 NOT NULL, '#13#10 +
    '  data_type      dstorage_data_type, '#13#10 +
    '  str_data       dtext120, '#13#10 +
    '  int_data       dinteger, '#13#10 +
    '  datetime_data  dtimestamp, '#13#10 +
    '  curr_data      dcurrency, '#13#10 +
    '  blob_data      dblob4096, '#13#10 +
    '  editiondate    deditiondate, '#13#10 +
    '  editorkey      dintkey, '#13#10 +
    ' '#13#10 +
    '  CONSTRAINT gd_pk_storage_data_id PRIMARY KEY (id), '#13#10 +
    '  CONSTRAINT gd_fk_storage_data_parent FOREIGN KEY (parent) '#13#10 +
    '    REFERENCES gd_storage_data (id) '#13#10 +
    '    ON UPDATE CASCADE '#13#10 +
    '    ON DELETE CASCADE, '#13#10 +
    '  CHECK ((NOT parent IS NULL) OR (data_type IN (''G'', ''U'', ''O'', ''T''))) '#13#10 +
    ') ';

  cCreateException =
    'CREATE EXCEPTION gd_e_storage_data ''''';

  cCreateTrigger =
    'CREATE TRIGGER gd_biu_storage_data FOR gd_storage_data'#13#10 +
    '  BEFORE INSERT OR UPDATE'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE FID INTEGER = -1;'#13#10 +
    'BEGIN'#13#10 +
    '  IF (NEW.ID IS NULL) THEN'#13#10 +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type IN (''G'', ''U'', ''O'', ''T'')) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.parent = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type IN (''G'', ''F'')) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type IN (''G'', ''U'', ''O'', ''T'', ''F'')) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''S'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '    NEW.str_data = COALESCE(NEW.str_data, '''');'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type IN (''I'', ''L'')) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = COALESCE(NEW.int_data, 0);'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''C'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '    NEW.curr_data = COALESCE(NEW.curr_data, 0);'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''D'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '    NEW.datetime_data = COALESCE(NEW.datetime_data, CURRENT_TIMESTAMP);'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''B'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.parent IS NULL) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    FOR'#13#10 +
    '      SELECT id FROM gd_storage_data WHERE parent IS NULL'#13#10 +
    '        AND data_type = NEW.data_type AND int_data IS NOT DISTINCT FROM NEW.int_data'#13#10 +
    '        AND id <> NEW.id'#13#10 +
    '      INTO :FID'#13#10 +
    '    DO'#13#10 +
    '      EXCEPTION gd_e_storage_data ''Root already exists. ID='' || :FID;'#13#10 +
    '  END ELSE'#13#10 +
    '  BEGIN'#13#10 +
    '    FOR'#13#10 +
    '      SELECT id FROM gd_storage_data WHERE parent = NEW.parent'#13#10 +
    '        AND UPPER(name) = UPPER(NEW.name) AND id <> NEW.id'#13#10 +
    '      INTO :FID'#13#10 +
    '    DO'#13#10 +
    '      EXCEPTION gd_e_storage_data ''Duplicate name. ID='' || :FID;'#13#10 +
    '  END'#13#10 +
    'END';

  cBlockException =
    'CREATE EXCEPTION gd_e_block_old_storage ''Изменение старых данных хранилища заблокировано'' ';

  cBlockTrigger =
    'CREATE TRIGGER gd_biud_%s FOR gd_%s'#13#10 +
    '  BEFORE INSERT OR UPDATE OR DELETE'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
    'BEGIN'#13#10 +
    '  EXCEPTION gd_e_block_old_storage ''%s'';'#13#10 +
    'END';

  cAddEditorKey =
    'ALTER TABLE gd_storage_data ADD editorkey dintkey';

  cAddEditionDate =
    'ALTER TABLE gd_storage_data ADD editiondate deditiondate';

  cFillEditorInfo =
    'UPDATE gd_storage_data SET editiondate = CURRENT_TIMESTAMP, editorkey = 650002 ' +
    '  WHERE editiondate IS NULL AND editorkey IS NULL';

procedure ConvertStorage(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;

  procedure ConvertStorage(const AnSQL: String; const ARootType: Char);
  var
    S: TgsIBStorage;
    bs: TIBBlobStream;
    F: TgsStorageFolder;
    EmptyStorage: Boolean;
  begin
    FIBSQL.Close;
    FIBSQL.SQL.Text := AnSQL;
    FIBSQL.ExecQuery;

    while not FIBSQL.EOF do
    begin
      case ARootType of
        cStorageGlobal: S := TgsGlobalStorage.Create;
        cStorageUser: S := TgsUserStorage.Create;
        cStorageCompany: S := TgsCompanyStorage.Create;
        {cStorageDesktop: S := TgsDesktopStorage.Create;}
      else
        raise Exception.Create('Invalid storage root');
      end;

      try
        if FIBSQL.FieldByName('akey').AsInteger > -1 then
          S.ObjectKey := FIBSQL.FieldByName('akey').AsInteger;
        S.LoadFromDatabase(FTransaction);

        F := S.OpenFolder('', False, False);
        try
          EmptyStorage := (F.FoldersCount = 0) and (F.ValuesCount = 0);
        finally
          S.CloseFolder(F, False);
        end;

        if not EmptyStorage then
        begin
          Log('Хранилище ' + FIBSQL.FieldByName('name').AsString +
            ' уже было сконвертировано и/или содержит данные.'#13#10 +
            'Повторная конвертация производиться не будет!');
        end else
        begin
          bs := TIBBlobStream.Create;
          try
            bs.Mode := bmRead;
            bs.Database := IBDB;
            bs.Transaction := FTransaction;
            bs.BlobID := FIBSQL.FieldByName('data').AsQuad;
            try
              S.LoadFromStream(bs);
            except
              on E: Exception do
              begin
                Log('Ошибка при считывании из потока хранилища ' + FIBSQL.FieldByName('name').AsString +
                  '.'#13#10'Сообщение: ' + E.Message);
                FreeAndNil(S);
              end;
            end;
          finally
            bs.Free;
          end;

          if S <> nil then
          begin
            Log('Конвертация хранилища ' + FIBSQL.FieldByName('name').AsString + '...');
            S.SaveToDatabase(FTransaction);
          end;
        end;
      finally
        S.Free;
      end;

      FIBSQL.Next;
    end;
  end;

var
  //SL: TStringList;
  //I: Integer;
  FNeedToCreateMeta: Boolean;
begin
  FNeedToCreateMeta := False;
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FTransaction.StartTransaction;

        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.SQL.Text := 'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DSTORAGE_DATA_TYPE'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateDomain;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''GD_E_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateException;
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''GD_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateTable;
          FIBSQL.ExecQuery;

          FNeedToCreateMeta := True;
        end;

        FIBSQL.Close;
        FTransaction.Commit;
        FTransaction.StartTransaction;

        ConvertStorage(
          'SELECT -1           AS AKey,     data, ''GLOBAL'' AS Name FROM gd_globalstorage', 'G');
        ConvertStorage(
          'SELECT s.userkey    AS AKey,   s.data,             u.name FROM gd_userstorage s JOIN gd_user u ON u.id = s.userkey', 'U');
        ConvertStorage(
          'SELECT s.companykey AS AKey,   s.data,             c.name FROM gd_companystorage s JOIN gd_contact c ON c.id = s.companykey', 'O');
        {ConvertStorage(
          'SELECT d.id         AS AKey, d.dtdata AS data, d.name || '' ('' || u.name || '')'' AS name FROM gd_desktop d JOIN gd_user u ON u.id = d.userkey', 'T');}

        if FNeedToCreateMeta then
        begin
          FIBSQL.Close;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          {SL := TStringList.Create;
          try
            CreateLBRBTreeMetaDataScript(SL, 'GD', 'STORAGE_DATA', 'GD_STORAGE_DATA');
            for I := 0 to 2 do
            begin
              FIBSQL.Close;
              FIBSQL.SQL.Text := SL[I];
              FIBSQL.ExecQuery;
            end;

            FIBSQL.Close;

            FTransaction.Commit;
            FTransaction.StartTransaction;

            FIBSQL.SQL.Text := 'EXECUTE PROCEDURE GD_P_RESTRUCT_STORAGE_DATA';
            FIBSQL.ExecQuery;

            for I := 3 to SL.Count - 1 do
            begin
              FIBSQL.Close;
              FIBSQL.SQL.Text := SL[I];
              FIBSQL.ExecQuery;
            end;
          finally
            SL.Free;
          end;}

          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateTrigger;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cBlockException;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := Format(cBlockTrigger, ['GLOBALSTORAGE', 'GLOBALSTORAGE',
            'Изменение старых данных глобального хранилища заблокировано']);
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := Format(cBlockTrigger, ['USERSTORAGE', 'USERSTORAGE',
            'Изменение старых данных пользовательского хранилища заблокировано']);
          FIBSQL.ExecQuery;

          // не будем блокировать хранилище компании, т.к. потом будут
          // проблемы с исключением компании из списка раб. организаций
          {FIBSQL.Close;
          FIBSQL.SQL.Text := Format(cBlockTrigger, ['COMPANYSTORAGE', 'COMPANYSTORAGE',
            'Изменение старых данных хранилища компании заблокировано']);
          FIBSQL.ExecQuery;}
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview) '#13#10 +
          '  VALUES ( '#13#10 +
          '    740302, '#13#10 +
          '    740300, '#13#10 +
          '    ''Хранилище (б/о)'', '#13#10 +
          '    ''srv_storage_new'', '#13#10 +
          '    ''TgdcStorage'', '#13#10 +
          '    NULL, '#13#10 +
          '    255, '#13#10 +
          '    1 '#13#10 +
          '  ) ';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview) '#13#10 +
          '  VALUES ( '#13#10 +
          '    730805, '#13#10 +
          '    730800, '#13#10 +
          '    ''Группы ТМЦ'', '#13#10 +
          '    '''', '#13#10 +
          '    ''TgdcGoodGroup'', '#13#10 +
          '    NULL, '#13#10 +
          '    142, '#13#10 +
          '    1 '#13#10 +
          '  ) ';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'GRANT ALL ON gd_storage_data TO Administrator ';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (114, ''0000.0001.0000.0145'', ''25.09.2009'', ''Storage being converted into new data structures'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (115, ''0000.0001.0000.0146'', ''08.03.2010'', ''Editorkey and editiondate fields were added to storage table'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (116, ''0000.0001.0000.0147'', ''26.04.2010'', ''Storage tree is not a lb-rb tree any more'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
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
    FTransaction.Free;
  end;
end;

procedure AddEdtiorKeyEditionDate2Storage(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FTransaction.StartTransaction;

        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$field_name FROM rdb$relation_fields ' +
          'WHERE rdb$relation_name = ''GD_STORAGE_DATA'' AND rdb$field_name = ''EDITIONDATE'' ';
        FIBSQL.ExecQuery;

        if FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cAddEditorKey;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cAddEditionDate;
          FIBSQL.ExecQuery;

          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cFillEditorInfo;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text :=
            'INSERT INTO fin_versioninfo ' +
            '  VALUES (115, ''0000.0001.0000.0146'', ''08.03.2010'', ''Editorkey and editiondate fields were added to storage table'')';
          try
            FIBSQL.ExecQuery;
          except
          end;
        end;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
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
    FTransaction.Free;
  end;
end;

procedure DropLBRBStorageTree(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FTransaction.StartTransaction;

        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers ' +
          'WHERE rdb$trigger_name = ''GD_BI_STORAGE_DATA10'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP TRIGGER GD_BI_STORAGE_DATA10 ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers ' +
          'WHERE rdb$trigger_name = ''GD_BU_STORAGE_DATA10'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP TRIGGER GD_BU_STORAGE_DATA10 ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$procedure_name FROM rdb$procedures ' +
          'WHERE rdb$procedure_name = ''GD_P_EL_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP PROCEDURE GD_P_EL_STORAGE_DATA ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$procedure_name FROM rdb$procedures ' +
          'WHERE rdb$procedure_name = ''GD_P_RESTRUCT_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP PROCEDURE GD_P_RESTRUCT_STORAGE_DATA ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$procedure_name FROM rdb$procedures ' +
          'WHERE rdb$procedure_name = ''GD_P_GCHC_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP PROCEDURE GD_P_GCHC_STORAGE_DATA ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$exception_name FROM rdb$exceptions ' +
          'WHERE rdb$exception_name = ''GD_E_INVALIDTREESTORAGE_DATA'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP EXCEPTION GD_E_INVALIDTREESTORAGE_DATA ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$field_name FROM rdb$relation_fields ' +
          'WHERE rdb$relation_name = ''GD_STORAGE_DATA'' AND rdb$field_name = ''LB'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE GD_STORAGE_DATA DROP CONSTRAINT GD_CHK_STORAGE_DATA_TR_LMT ';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP INDEX GD_X_STORAGE_DATA_LB ';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE GD_STORAGE_DATA DROP LB ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'SELECT rdb$field_name FROM rdb$relation_fields ' +
          'WHERE rdb$relation_name = ''GD_STORAGE_DATA'' AND rdb$field_name = ''RB'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := 'DROP INDEX GD_X_STORAGE_DATA_RB ';
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := 'ALTER TABLE GD_STORAGE_DATA DROP RB ';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (116, ''0000.0001.0000.0147'', ''26.04.2010'', ''Storage tree is not a lb-rb tree any more'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
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
    FTransaction.Free;
  end;
end;

end.
