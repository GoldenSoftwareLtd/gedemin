
{Добавляет поля editiondate и editorkey в таблицы настроек(фильтры, функции, атрибуты...)}
unit mdf_AddEditionDate;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure AddEditionDate(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

const
  //Список таблиц, в которые необходимо добавить поля
  cstTableArray: array[0..14] of String =
  ('AT_FIELDS',
   'AT_RELATION_FIELDS',
   'AT_EXCEPTIONS',
   'AT_INDICES',
   'AT_PROCEDURES',
   'AT_RELATIONS',
   'AT_TRIGGERS',
   'EVT_MACROSLIST',
   'EVT_MACROSGROUP',
   'EVT_OBJECT',
   'EVT_OBJECTEVENT',
   'GD_FUNCTION',
   'FLT_SAVEDFILTER',
   'RP_REPORTLIST',
   'RP_REPORTTEMPLATE');

   //id контакта Администратор
   cstAdminKey = 650002;
   //Префикс таблицы пользователя
   UserPrefix = 'USR$';

   //Максимальный размер названия форейн ключа
   FKeyNameLength = 31;

   //Позиция создаваемых триггеров
   cstTriggerPos = 5;

//Функция возвращает название форейн ключа по названию таблицы и поля
function GetForeignName(const ATableName, ForeignField: String): String;
begin
  if AnsiPos(UserPrefix, ATableName) = 1 then
  begin
    Result := 'USR$FK_' + Copy(ATableName, 5, Length(ATableName) - 4) + '_' + ForeignField;
  end else
  begin
    Result := Copy(ATableName, 1, AnsiPos('_', ATableName)) + 'FK_' +
      Copy(ATableName, AnsiPos('_', ATableName) + 1, Length(ATableName) - AnsiPos('_', ATableName)) +
      '_' + ForeignField;
  end;

  if Length(Result) > FKeyNameLength then
    Result := Copy(Result, 1, FKeyNameLength);
end;

//Функция возвращает название триггера по названию таблицы и позиции
function GetTriggerName(const ATableName, APosition: String; PosNumber: Integer): String;
begin
  if AnsiPos(UserPrefix, ATableName) = 1 then
  begin
    Result := 'USR$' + APosition + '_' + Copy(ATableName, 5, Length(ATableName) - 4) + IntToStr(PosNumber);
  end else
  begin
    Result := Copy(ATableName, 1, AnsiPos('_', ATableName)) + APosition + '_'  +
      Copy(ATableName, AnsiPos('_', ATableName) + 1, Length(ATableName) - AnsiPos('_', ATableName)) +
      IntToStr(PosNumber);
  end;

  if Length(Result) > FKeyNameLength then
    Result := Copy(Result, 1, FKeyNameLength - Length(IntToStr(PosNumber))) + IntToStr(PosNumber);
end;

procedure AddEditionDate(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
  I: Integer;
  FForeignName: String;
  FTriggerName: String;
begin
  ibsql := TIBSQL.Create(nil);
  ibsql.ParamCheck := False;
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      //Проведем синхронизацию триггеров и индексов
      ibsql.Close;
      ibsql.SQL.Text := 'EXECUTE PROCEDURE at_p_sync_indexes_all ';
      Log('Синхронизация индексов');
      ibsql.ExecQuery;
      ibsql.Close;
      ibsql.SQL.Text := 'EXECUTE PROCEDURE at_p_sync_triggers_all ';
      Log('Синхронизация триггеров');      
      ibsql.ExecQuery;
      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      for I := 0 to Length(cstTableArray) - 1 do
      begin
        //проверим, есть ли уже поле
        ibsql.Close;
        ibsql.SQL.Text := Format('SELECT * FROM rdb$relation_fields WHERE ' +
          ' rdb$field_name = ''EDITIONDATE'' AND rdb$relation_name = ''%s'' ',
          [cstTableArray[I]]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 0 then
        begin
          ibsql.Close;
          ibsql.SQL.Text := Format('ALTER TABLE %s ADD editiondate deditiondate',
            [cstTableArray[I]]);
          Log(Format('%s: Добавление поля editiondate', [cstTableArray[I]]));
          ibsql.ExecQuery;
          FIBTransaction.Commit;
          FIBTransaction.StartTransaction;
        end;

        ibsql.Close;
        ibsql.SQL.Text := Format('SELECT * FROM rdb$relation_fields WHERE ' +
          ' rdb$field_name = ''EDITORKEY'' AND rdb$relation_name = ''%s'' ',
          [cstTableArray[I]]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 0 then
        begin
          ibsql.Close;
          ibsql.SQL.Text := Format('ALTER TABLE %s ADD editorkey dintkey',
            [cstTableArray[I]]);
          Log(Format('%s: Добавление поля editorkey', [cstTableArray[I]]));
          ibsql.ExecQuery;
          FIBTransaction.Commit;
          FIBTransaction.StartTransaction;
          ibsql.Close;
          ibsql.SQL.Text := Format('UPDATE %s SET editorkey = %s WHERE editorkey IS NULL',
            [cstTableArray[I], IntToStr(cstAdminKey)]);
          Log(Format('%s: Заполнение поля editorkey ссылкой на Администратора', [cstTableArray[I]]));
          ibsql.ExecQuery;
        end;

        ibsql.Close;
        FForeignName := GetForeignName(cstTableArray[I], 'EDITORKEY');
        ibsql.SQL.Text := Format('SELECT * FROM rdb$relation_constraints WHERE ' +
          ' rdb$constraint_name = ''%s''', [FForeignName]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 0 then
        begin
          //Сейчас пойдет создание форейн кей. Лучше переподключится к базе
          FIBTransaction.Commit;
          FIBTransaction.DefaultDatabase.Connected := False;
          FIBTransaction.DefaultDatabase.Connected := True;
          FIBTransaction.StartTransaction;
          ibsql.Close;
          ibsql.SQL.Text := Format('ALTER TABLE %s ADD CONSTRAINT %s ' +
            ' FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey) ' +
            ' ON UPDATE CASCADE', [cstTableArray[I], FForeignName]);
          Log(Format('%s: Добавление форейн кей %s на поле editorkey', [cstTableArray[I], FForeignName]));
          ibsql.ExecQuery;
          FIBTransaction.Commit;
          FIBTransaction.StartTransaction;
        end;

        ibsql.Close;
        FTriggerName := GetTriggerName(cstTableArray[I], 'BI', cstTriggerPos);
        ibsql.SQL.Text := Format('SELECT * FROM rdb$triggers WHERE ' +
          ' rdb$trigger_name = ''%s''', [FTriggerName]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 0 then
        begin
          ibsql.Close;
          ibsql.SQL.Text := Format(
          ' CREATE TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
          ' BEFORE INSERT POSITION %3:s '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
          '     NEW.editorkey = %2:s; '#13#10 +
          '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
          '     NEW.editiondate = ''NOW'';'#13#10 +
          ' END ', [cstTableArray[I], FTriggerName, IntToStr(cstAdminKey), IntToStr(cstTriggerPos)]);
          Log(Format('%s: Добавление триггера %s', [cstTableArray[I], FTriggerName]));
          ibsql.ExecQuery;
          FIBTransaction.Commit;
          FIBTransaction.StartTransaction;
        end;

        ibsql.Close;
        FTriggerName := GetTriggerName(cstTableArray[I], 'BU', cstTriggerPos);
        ibsql.SQL.Text := Format('SELECT * FROM rdb$triggers WHERE ' +
          ' rdb$trigger_name = ''%s''', [FTriggerName]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 0 then
        begin
          ibsql.Close;
          ibsql.SQL.Text := Format(
          ' CREATE TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
          ' BEFORE UPDATE POSITION %3:s '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (NEW.editorkey IS NULL) THEN '#13#10 +
          '     NEW.editorkey = %2:s; '#13#10 +
          '   IF (NEW.editiondate IS NULL) THEN '#13#10 +
          '     NEW.editiondate = ''NOW'';'#13#10 +
          ' END ', [cstTableArray[I], FTriggerName, IntToStr(cstAdminKey), IntToStr(cstTriggerPos)]);
          Log(Format('%s: Добавление триггера %s', [cstTableArray[I], FTriggerName]));
          ibsql.ExecQuery;
          FIBTransaction.Commit;
          FIBTransaction.StartTransaction;
        end;

      end;
      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
