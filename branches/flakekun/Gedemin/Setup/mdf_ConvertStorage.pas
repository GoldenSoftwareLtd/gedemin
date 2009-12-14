unit mdf_ConvertStorage;

interface

uses
  IBDatabase, gdModify;

procedure ConvertStorage(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit, gsStorage,
  gdcLBRBTreeMetaData, gdcStorage_Types;

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
    '  lb             dlb, '#13#10 +
    '  rb             drb, '#13#10 +
    '  parent         dparent, '#13#10 +
    '  name           dtext120 NOT NULL, '#13#10 +
    '  data_type      dstorage_data_type, '#13#10 +
    '  str_data       dtext120, '#13#10 +
    '  int_data       dinteger, '#13#10 +
    '  datetime_data  dtimestamp, '#13#10 +
    '  curr_data      dcurrency, '#13#10 +
    '  blob_data      dblob4096, '#13#10 +
    ' '#13#10 +
    '  CONSTRAINT gd_pk_storage_data_id PRIMARY KEY (id), '#13#10 +
    '  CONSTRAINT gd_fk_storage_data_parent FOREIGN KEY (parent) '#13#10 +
    '    REFERENCES gd_storage_data (id) '#13#10 +
    '    ON UPDATE CASCADE '#13#10 +
    '    ON DELETE CASCADE, '#13#10 +
    '  CONSTRAINT gd_u_storage_data_name UNIQUE(name, parent, int_data), '#13#10 +
    '  CHECK ((NOT parent IS NULL) OR (data_type IN (''G'', ''U'', ''O'', ''T''))) '#13#10 +
    ') ';

  cCreateTrigger =
    'CREATE TRIGGER gd_biu_storage_data FOR gd_storage_data'#13#10 +
    '  BEFORE INSERT OR UPDATE'#13#10 +
    '  POSITION 0'#13#10 +
    'AS'#13#10 +
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
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type IN (''I'', ''L'')) THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''C'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''D'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.blob_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '  END'#13#10 +
    ''#13#10 +
    '  IF (NEW.data_type = ''B'') THEN'#13#10 +
    '  BEGIN'#13#10 +
    '    NEW.str_data = NULL;'#13#10 +
    '    NEW.curr_data = NULL;'#13#10 +
    '    NEW.datetime_data = NULL;'#13#10 +
    '    NEW.int_data = NULL;'#13#10 +
    '  END'#13#10 +
    'END';

procedure ConvertStorage(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, qID, q: TIBSQL;

  procedure ScanStorage(AFolder: TgsStorageFolder; AParentID: Integer;
    ARootName: String; ARootType: Char; ARootKey: Integer; qInsert: TIBSQL);
  var
    I, ThisID: Integer;
  begin
    if (AFolder.Parent <> nil) and (AFolder.FoldersCount = 0) and (AFolder.ValuesCount = 0) then
      exit;

    qID.Close;
    qID.ExecQuery;
    ThisID := qID.Fields[0].AsInteger;

    qInsert.Close;
    qInsert.ParamByName('ID').AsInteger := ThisID;
    qInsert.ParamByName('INT_DATA').Clear;
    qInsert.ParamByName('STR_DATA').Clear;
    qInsert.ParamByName('CURR_DATA').Clear;
    qInsert.ParamByName('DATETIME_DATA').Clear;
    qInsert.ParamByName('BLOB_DATA').Clear;
    if AFolder.Parent = nil then
    begin
      qInsert.ParamByName('PARENT').Clear;
      qInsert.ParamByName('NAME').AsString := ARootName;
      qInsert.ParamByName('DATA_TYPE').AsString := ARootType;
      if ARootKey <> -1 then
        qInsert.ParamByName('INT_DATA').AsInteger := ARootKey;
    end else
    begin
      qInsert.ParamByName('PARENT').AsInteger := AParentID;
      qInsert.ParamByName('NAME').AsString := AFolder.Name;
      qInsert.ParamByName('DATA_TYPE').AsString := cStorageFolder;
    end;
    qInsert.ExecQuery;

    for I := 0 to AFolder.FoldersCount - 1 do
    begin
      ScanStorage(AFolder.Folders[I], ThisID, '', #0, -1, qInsert);
    end;

    for I := 0 to AFolder.ValuesCount - 1 do
    begin
      qInsert.Close;
      qInsert.ParamByName('ID').Clear;
      qInsert.ParamByName('PARENT').AsInteger := ThisID;
      qInsert.ParamByName('NAME').AsString := AFolder.Values[I].Name;
      qInsert.ParamByName('INT_DATA').Clear;
      qInsert.ParamByName('STR_DATA').Clear;
      qInsert.ParamByName('CURR_DATA').Clear;
      qInsert.ParamByName('DATETIME_DATA').Clear;
      qInsert.ParamByName('BLOB_DATA').Clear;
      case AFolder.Values[I].GetTypeID of
        svtInteger:
          begin
            qInsert.ParamByName('DATA_TYPE').AsString := cStorageInteger;
            qInsert.ParamByName('INT_DATA').AsInteger := AFolder.Values[I].AsInteger;
          end;

        svtString:
          begin
            if Length(AFolder.Values[I].AsString) <= 120 then
            begin
              qInsert.ParamByName('DATA_TYPE').AsString := cStorageString;
              qInsert.ParamByName('STR_DATA').AsString := AFolder.Values[I].AsString;
            end else
            begin
              qInsert.ParamByName('DATA_TYPE').AsString := cStorageBLOB;
              qInsert.ParamByName('BLOB_DATA').AsString := AFolder.Values[I].AsString;
            end;
          end;

        svtStream:
          begin
            qInsert.ParamByName('DATA_TYPE').AsString := cStorageBLOB;
            qInsert.ParamByName('BLOB_DATA').AsString := AFolder.Values[I].AsString;
          end;

        svtBoolean:
          begin
            qInsert.ParamByName('DATA_TYPE').AsString := cStorageBoolean;
            qInsert.ParamByName('INT_DATA').AsInteger := AFolder.Values[I].AsInteger;
          end;

        svtDateTime:
          begin
            qInsert.ParamByName('DATA_TYPE').AsString := cStorageDateTime;
            qInsert.ParamByName('DATETIME_DATA').AsDateTime := AFolder.Values[I].AsDateTime;
          end;

        svtCurrency:
          begin
            qInsert.ParamByName('DATA_TYPE').AsString := cStorageCurrency;
            qInsert.ParamByName('CURR_DATA').AsCurrency := AFolder.Values[I].AsCurrency;
          end;
      else
        raise Exception.Create('Invalid storage item type');
      end;
      qInsert.ExecQuery;
    end;
  end;

  procedure ConvertStorage(const AnSQL: String; const ARootType: Char);
  var
    S: TgsStorage;
    F: TgsStorageFolder;
    bs: TIBBlobStream;
  begin
    S := TgsIBStorage.Create('S');
    try
      FIBSQL.Close;
      FIBSQL.SQL.Text := AnSQL;
      FIBSQL.ExecQuery;

      while not FIBSQL.EOF do
      begin
        bs := TIBBlobStream.Create;
        try
          bs.Mode := bmRead;
          bs.Database := IBDB;
          bs.Transaction := FTransaction;
          bs.BlobID := FIBSQL.FieldByName('data').AsQuad;
          S.LoadFromStream(bs);
        finally
          bs.Free;
        end;

        F := S.OpenFolder('\', False, False);
        try
          if F <> nil then
          begin
            ScanStorage(F, -1, FIBSQL.FieldByName('name').AsString,
              ARootType, FIBSQL.FieldByName('akey').AsInteger, q);
          end;    
        finally
          S.CloseFolder(F, False);
        end;

        FIBSQL.Next;
      end;
    finally
      S.Free;
    end;
  end;

var
  SL: TStringList;
  I: Integer;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      qID := TIBSQL.Create(nil);
      q := TIBSQL.Create(nil);
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
        FIBSQL.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''GD_STORAGE_DATA'' ';
        FIBSQL.ExecQuery;
        if FIBSQL.EOF then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateTable;
          FIBSQL.ExecQuery;

          FIBSQL.Close;
          FIBSQL.SQL.Text := cCreateTrigger;
          FIBSQL.ExecQuery;

          SL := TStringList.Create;
          try
            CreateLBRBTreeMetaDataScript(SL, 'GD', 'STORAGE_DATA', 'GD_STORAGE_DATA');
            for I := 0 to SL.Count - 1 do
            begin
              FIBSQL.Close;
              FIBSQL.SQL.Text := SL[I];
              FIBSQL.ExecQuery;
            end;
          finally
            SL.Free;
          end;
        end;

        FTransaction.Commit;
        FTransaction.StartTransaction;

        qID.Transaction := FTransaction;
        qID.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) FROM rdb$database';

        q.Transaction := FTransaction;
        q.SQL.Text :=
          'INSERT INTO gd_storage_data (ID, PARENT, NAME, DATA_TYPE, STR_DATA, INT_DATA, DATETIME_DATA, CURR_DATA, BLOB_DATA) ' +
          'VALUES (:ID, :PARENT, :NAME, :DATA_TYPE, :STR_DATA, :INT_DATA, :DATETIME_DATA, :CURR_DATA, :BLOB_DATA) ';

        ConvertStorage(
          'SELECT -1           AS AKey,     data, ''GLOBAL'' AS Name FROM gd_globalstorage', 'G');
        ConvertStorage(
          'SELECT s.userkey    AS AKey,   s.data,             u.name FROM gd_userstorage s JOIN gd_user u ON u.id = s.userkey', 'U');
        ConvertStorage(
          'SELECT s.companykey AS AKey,   s.data,             c.name FROM gd_companystorage s JOIN gd_contact c ON c.id = s.companykey', 'O');
        ConvertStorage(
          'SELECT d.id         AS AKey, d.dtdata AS data, d.name || '' ('' || u.name || '')'' AS name FROM gd_desktop d JOIN gd_user u ON u.id = d.userkey', 'T');

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (114, ''0000.0001.0000.0145'', ''25.09.2009'', ''Storage being converted into new data structures'')';
        try
          FIBSQL.ExecQuery;
        except
        end;

        FTransaction.Commit;
      finally
        q.Free;
        qID.Free;
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
