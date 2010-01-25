unit flt_dlgCreateProcedure_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IBSQL, IBDatabase, IBExtract, IBDatabaseInfo, IBHeader,
  gd_security;

const
  msgAdminOnly = 'Вы не являетесь Администратором системы.';

type
  TdlgCreateProcedure = class(TForm)
    mmProcedureText: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    ibsqlCreate: TIBSQL;
    ibtrCreateProcedure: TIBTransaction; // Все это дело отдельная логическая функция.
    btnAbout: TButton;                   // Поэтому на отдельной транзанкции.
    btnRigth: TButton;
    Panel3: TPanel;
    Label1: TLabel;
    edDescription: TEdit;
    ibeText: TIBExtract;
    procedure btnOkClick(Sender: TObject);
  private
    LocView: Integer;
    procedure GetProcedureArgs(const Proc: String; const AnMetaData: TStrings);
    function GetUserKey: Integer;
  public
    function AddProcedure(const AnSQLText: String; const AnComponentKey: Integer): Boolean;
    function EditProcedure(const AnProcedureName: String): Boolean;
    function DeleteProcedure(const AnProcedureName: String): Boolean;
  end;

var
  dlgCreateProcedure: TdlgCreateProcedure;

implementation

uses
  flt_sql_parser, gd_directories_const, flt_sqlfilter_condition_type
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

function TdlgCreateProcedure.GetUserKey: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.UserKey
  else
    Result := ADMIN_KEY;
end;

// Процедура для получения текста аргументов. Скопировано из IBExpert
procedure TdlgCreateProcedure.GetProcedureArgs(const Proc: String; const AnMetaData: TStrings);
const
{ query to retrieve the input parameters. }
  NEWLINE = #13#10;
  ProcHeaderSQL =
    'SELECT * ' +
    ' FROM RDB$PROCEDURE_PARAMETERS PRM JOIN RDB$FIELDS FLD ON ' +
    ' PRM.RDB$FIELD_SOURCE = FLD.RDB$FIELD_NAME ' +
    'WHERE ' +
    '    PRM.RDB$PROCEDURE_NAME = :PROCNAME AND ' +
    '    PRM.RDB$PARAMETER_TYPE = :Input ' +
    'ORDER BY PRM.RDB$PARAMETER_NUMBER';

var
  FirstTime, PrecisionKnown : Boolean;
  Line : String;
  qryHeader : TIBSQL;

  function FormatParamStr : String;
  var
    i, CollationID, CharSetID : Integer;
  begin
    Result := Format('  %s ', [qryHeader.FieldByName('RDB$PARAMETER_NAME').AsTrimString]);
    for i := Low(ColumnTypes) to High(ColumnTypes) do
      if qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger = ColumnTypes[i].SQLType then
      begin
        PrecisionKnown := FALSE;
        if ibeText.DatabaseInfo.ODSMajorVersion >= ODS_VERSION10 then
        begin
          if qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger in [blr_short, blr_long, blr_int64] then
          begin
            { We are ODS >= 10 and could be any Dialect }
            if (ibeText.DatabaseInfo.DBSQLDialect >= 3) and
               (not qryHeader.FieldByName('RDB$FIELD_PRECISION').IsNull) and
               (qryHeader.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger > 0) and
               (qryHeader.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger <= MAX_INTSUBTYPES) then
            begin
              Result := Result + Format('%s(%d, %d)', [
                IntegralSubtypes [qryHeader.FieldByName('RDB$FIELD_SUB_TYPE').AsInteger],
                qryHeader.FieldByName('RDB$FIELD_PRECISION').AsInteger,
                -1 * qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger]);
              PrecisionKnown := true;
            end;
          end;
        end;
        if PrecisionKnown = false then
        begin
          { Take a stab at numerics and decimals }
          if (qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger = blr_short) and
              (qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger < 0) then
            Result := Result + Format('NUMERIC(4, %d)',
              [-qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger] )
          else
            if (qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger = blr_long) and
                (qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger < 0) then
              Result := Result + Format('NUMERIC(9, %d)',
                [-qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger] )
            else
              if (qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger = blr_double) and
                  (qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger  < 0) then
                Result := Result + Format('NUMERIC(15, %d)',
                  [-qryHeader.FieldByName('RDB$FIELD_SCALE').AsInteger] )
              else
                Result := Result + ColumnTypes[i].TypeName;
        end;
        break;
      end;
    if (qryHeader.FieldByName('RDB$FIELD_TYPE').AsInteger in [blr_text, blr_varying]) and
       (not qryHeader.FieldByName('RDB$CHARACTER_LENGTH').IsNull) then
      Result := Result + Format('(%d)', [qryHeader.FieldByName('RDB$FIELD_LENGTH').AsInteger]);

    { Show international character sets and collations }

    if (not qryHeader.FieldByName('RDB$COLLATION_ID').IsNull) or
       (not qryHeader.FieldByName('RDB$CHARACTER_SET_ID').IsNull) then
    begin
      if qryHeader.FieldByName('RDB$COLLATION_ID').IsNull then
        CollationId := 0
      else
        CollationId := qryHeader.FieldByName('RDB$COLLATION_ID').AsInteger;

      if qryHeader.FieldByName('RDB$CHARACTER_SET_ID').IsNull then
        CharSetId := 0
      else
        CharSetId := qryHeader.FieldByName('RDB$CHARACTER_SET_ID').AsInteger;

      Result := Result + ibeText.GetCharacterSets(CharSetId, CollationId, false);
    end;
  end;

begin
  AnMetaData.Text := 'alter procedure ' + Proc;
  FirstTime := true;
  qryHeader := TIBSQL.Create(ibeText.Database);
  try
    qryHeader.SQL.Text := ProcHeaderSQL;
    qryHeader.Params.ByName('procname').AsString := Proc;
    qryHeader.Params.ByName('Input').AsInteger := 0;
    qryHeader.ExecQuery;
    while not qryHeader.Eof do
    begin
      if FirstTime then
      begin
        FirstTime := false;
        AnMetaData.Add('(');
      end;

      Line := FormatParamStr;

      qryHeader.Next;
      if not qryHeader.Eof then
        Line := Line + ',';
      AnMetaData.Add(Line);
    end;

    { If there was at least one param, close parens }
    if not FirstTime then
    begin
      AnMetaData.Add( ')');
    end;

    FirstTime := true;
    qryHeader.Close;
    qryHeader.Params.ByName('Input').AsInteger := 1;
    qryHeader.ExecQuery;

    while not qryHeader.Eof do
    begin
      if FirstTime then
      begin
        FirstTime := false;
        AnMetaData.Add('returns' + NEWLINE + '(');
      end;

      Line := FormatParamStr;

      qryHeader.Next;
      if not qryHeader.Eof then
        Line := Line + ',';
      AnMetaData.Add(Line);
    end;

    { If there was at least one param, close parens }
    if not FirstTime then
    begin
      AnMetaData.Add( ')');
    end;

  finally
    qryHeader.Free;
  end;
end;

// Процедура для создания новой процедуры
function TdlgCreateProcedure.AddProcedure(const AnSQLText: String; const AnComponentKey: Integer): Boolean;
var
  LocProcedureName: String;
  LocTableList: TfltStringList;
begin
  // Присваиваем результат
  Result := False;
  // Доступ к созданию процедур должен быть только у Administrator
  if GetUserKey <> ADMIN_KEY then
  begin
    MessageBox(Self.Handle, msgAdminOnly, 'Внимание', MB_OK or MB_ICONSTOP);
    Exit;
  end;
  // Стартуем транзакцию
  if not ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.StartTransaction;
  // Создаем начальный текст запроса
  mmProcedureText.Lines.Text := 'create procedure New_Procedure ';
  mmProcedureText.Lines.Add('returns (id INTEGER)');
  mmProcedureText.Lines.Add('as');
  mmProcedureText.Lines.Add('begin');
  mmProcedureText.Lines.Add('  FOR');
  LocTableList := TfltStringList.Create;
  try
    // Вытягиваем список таблиц из запроса
    ExtractTablesList(AnSQLText, LocTableList);
    // Если таблиц в запросе не используется, что мало верлоятно
    // то просто присваиваем текст
    if LocTableList.Count = 0 then
      mmProcedureText.Lines.Add(AnSQLText)
    else
    begin
      // Иначе вытягиваем только id (обоснование смотри в документации) первой таблицы (т.к. главную определить сложно)
      mmProcedureText.Lines.Add('SELECT ' + LocTableList.ValuesOfIndex[0] + 'id');
      mmProcedureText.Lines.Add(ExtractSQLFrom(AnSQLText));
      mmProcedureText.Lines.Add(ExtractSQLWhere(AnSQLText));
      mmProcedureText.Lines.Add(ExtractSQLOther(AnSQLText));
      mmProcedureText.Lines.Add(ExtractSQLOrderBy(AnSQLText));
    end;
  finally
    LocTableList.Free;
  end;
  // Остальное добавляем
  mmProcedureText.Lines.Add('  INTO :id DO');
  mmProcedureText.Lines.Add('    suspend;');
  mmProcedureText.Lines.Add('end;');
  // Присваиваем права доступа. Вообще необходимость этого поля под вопросом {gs}
  LocView := -1;
  // Показываем окно
  if ShowModal = mrOk then
  try
    // Присвоение текста процедуры компоненте TIBSQL происходит по нажатию на кнопку "Сохранить"
    // Создаем процедуру
    ibsqlCreate.ExecQuery;
    // Вытягиваем имя процедуры
    LocProcedureName := ExtractProcedureName(ibsqlCreate.SQL.Text);
    // Регистрируем ее в нашей таблице
    ibsqlCreate.Close;
    ibsqlCreate.SQL.Text := 'INSERT INTO flt_procedurefilter (name, componentkey, description, aview) ' +
     'VALUES(''' + AnsiUpperCase(LocProcedureName) + ''', ' + IntToStr(AnComponentKey) +
     ', ''' + edDescription.Text + ''',' + IntToStr(LocView) + ')';
    try
      ibsqlCreate.ExecQuery;
      // Присваиваем права на использование "administrator"
      ibsqlCreate.Close;
      ibsqlCreate.SQL.Text := 'GRANT EXECUTE ON PROCEDURE ' + LocProcedureName +
       ' TO administrator';
      try
        ibsqlCreate.ExecQuery;
        // Присваиваем результат
        Result := True;
      except
        // Обработка ошибки
        on E: Exception do
        begin
          MessageBox(Self.Handle, PChar('Произошла ошибка при присвоении прав процедуре:'#13#10 +
           E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
          if ibtrCreateProcedure.InTransaction then
            ibtrCreateProcedure.Rollback;
        end;
      end;
    except
      // Обработка ошибки
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка при регистрации процедуры:'#13#10 +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
        if ibtrCreateProcedure.InTransaction then
          ibtrCreateProcedure.Rollback;
      end;
    end;
  except
    // Обработка ошибки
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка при создании процедуры:'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      if ibtrCreateProcedure.InTransaction then
        ibtrCreateProcedure.Rollback;
    end;
  end;
  // Закрываем транзакцию
  if ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.Commit;
end;

function TdlgCreateProcedure.EditProcedure(const AnProcedureName: String): Boolean;
var
  LocProcedureName: String;
  OldProcBody: String;
begin
  // Присваиваем результат
  Result := False;
  if GetUserKey <> ADMIN_KEY then
  begin
    MessageBox(Self.Handle, msgAdminOnly, 'Внимание', MB_OK or MB_ICONSTOP);
    Exit;
  end;
  LocProcedureName := AnsiUpperCase(AnProcedureName);
  // Стартуем транзакцию
  if not ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.StartTransaction;
  // Ищем процедуру в нашей таблице
  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := 'SELECT * FROM flt_procedurefilter WHERE UPPER(name) = ''' + LocProcedureName + '''';
  ibsqlCreate.ExecQuery;
  // Если не нашли, то выходим
  if ibsqlCreate.Eof then
  begin
    MessageBox(Self.Handle, 'Данная процедура не зарегистрирована.', 'Внимание', MB_OK or MB_ICONSTOP);
    Exit;
  end;
  LocView := ibsqlCreate.FieldByName('aview').AsInteger;
  edDescription.Text := ibsqlCreate.FieldByName('description').AsString;
  // Ищем процедуру в системных таблицах (в базе)
  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''' + LocProcedureName + '''';
  ibsqlCreate.ExecQuery;
  // Если не находим, значит ее кто-то удалил. Удаляем ее из нашей таблицы и выходим.
  if ibsqlCreate.Eof then
  begin
    MessageBox(Self.Handle, 'Данная процедура не обнаружена.', 'Внимание', MB_OK or MB_ICONSTOP);
    ibsqlCreate.Close;
    ibsqlCreate.SQL.Text := 'DELETE FROM rdb$procedures WHERE rdb$procedure_name = ''' + LocProcedureName + '''';
    ibsqlCreate.ExecQuery;
    Result := True;
    Exit;
  end;
  ibeText.Database := ibsqlCreate.Database;
  GetProcedureArgs(LocProcedureName, mmProcedureText.Lines);

  // Добавляем тело
  mmProcedureText.Lines.Add('as ' + ibsqlCreate.FieldByName('rdb$procedure_source').AsTrimString);

  OldProcBody := mmProcedureText.Lines.Text;
  // Показываем окно
  if ShowModal = mrOk then
  try
    if OldProcBody <> mmProcedureText.Lines.Text then
      // Присвоение текста процедуры компоненте TIBSQL происходит по нажатию на кнопку "Сохранить"
      // Производим изменения
      ibsqlCreate.ExecQuery;
    ibsqlCreate.Close;
    ibsqlCreate.SQL.Text := 'UPDATE flt_procedurefilter SET description = ''' +
     edDescription.Text + ''', aview = ' + IntToStr(LocView) + ' WHERE name = ''' +
     LocProcedureName + '''';
    try
      ibsqlCreate.ExecQuery;
      Result := True;
    except
      // Обработка ошибки
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка при редактировании процедуры:'#13#10 +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
        if ibtrCreateProcedure.InTransaction then
          ibtrCreateProcedure.Rollback;
      end;
    end;
  except
    // Обработка ошибки
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка при редактировании процедуры:'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      if ibtrCreateProcedure.InTransaction then
        ibtrCreateProcedure.Rollback;
    end;
  end;
  // Закрываем транзакцию
  if ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.Commit;
end;

function TdlgCreateProcedure.DeleteProcedure(const AnProcedureName: String): Boolean;
var
  LocProcedureName: String;
begin
  // Присваиваем результат
  Result := False;
  if GetUserKey <> ADMIN_KEY then
  begin
    MessageBox(Self.Handle, msgAdminOnly, 'Внимание', MB_OK or MB_ICONSTOP);
    Exit;
  end;
  LocProcedureName := AnsiUpperCase(AnProcedureName);
  // Стартуем транзакцию
  if not ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.StartTransaction;
  // Ищем процедуру в нашей таблице
  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := 'SELECT * FROM flt_procedurefilter WHERE UPPER(name) = ''' + LocProcedureName + '''';
  ibsqlCreate.ExecQuery;
  // Если не нашли, то выходим
  if ibsqlCreate.Eof then
  begin
    MessageBox(Self.Handle, 'Данная процедура не зарегистрирована.', 'Внимание', MB_OK or MB_ICONSTOP);
    Exit;
  end;
  // Ищем процедуру в системных таблицах (в базе)
  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''' + LocProcedureName + '''';
  ibsqlCreate.ExecQuery;
  // Если не находим, значит ее кто-то удалил. Удаляем ее из нашей таблицы и выходим.
  if ibsqlCreate.Eof then
  begin
    MessageBox(Self.Handle, 'Данная процедура не обнаружена.', 'Внимание', MB_OK or MB_ICONSTOP);
    ibsqlCreate.Close;
    ibsqlCreate.SQL.Text := 'DELETE FROM rdb$procedures WHERE rdb$procedure_name = ''' + LocProcedureName + '''';
    ibsqlCreate.ExecQuery;
    Exit;
  end;

  if (MessageBox(Self.Handle, 'Процедура может использоваться другими пользователями.'#10#13 +
   'Вы все еще хотите её?', 'Внимание', MB_YESNO or MB_ICONQUESTION) = ID_NO) or
   (MessageBox(Self.Handle, 'А вы хорошо подумали?', 'Внимание', MB_YESNO or MB_ICONQUESTION) = ID_NO) then
    Exit;

  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := 'DROP PROCEDURE ' + LocProcedureName;
  try
    ibsqlCreate.ExecQuery;
    ibsqlCreate.Close;
    ibsqlCreate.SQL.Text := 'DELETE FROM flt_procedurefilter WHERE UPPER(name) = ''' + LocProcedureName + '''';
    try
      ibsqlCreate.ExecQuery;
      ibsqlCreate.Close;
      ibsqlCreate.SQL.Text := 'REVOKE EXECUTE ON PROCEDURE ' + LocProcedureName + ' FROM administrator';
      try
        ibsqlCreate.ExecQuery;
        Result := True;
      except
        // Обработка ошибки
        on E: Exception do
        begin
          MessageBox(Self.Handle, PChar('Произошла ошибка при удалении прав на процедуру:'#13#10 +
           E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
          if ibtrCreateProcedure.InTransaction then
            ibtrCreateProcedure.Rollback;
        end;
      end;
    except
      // Обработка ошибки
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка при удалении регистрации:'#13#10 +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
        if ibtrCreateProcedure.InTransaction then
          ibtrCreateProcedure.Rollback;
      end;
    end;
  except
    // Обработка ошибки
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка при удалении процедуры:'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      if ibtrCreateProcedure.InTransaction then
        ibtrCreateProcedure.Rollback;
    end;
  end;
  // Закрываем транзакцию
  if ibtrCreateProcedure.InTransaction then
    ibtrCreateProcedure.Commit;
end;

procedure TdlgCreateProcedure.btnOkClick(Sender: TObject);
begin
  // Присваиваем запрос
  ibsqlCreate.Close;
  ibsqlCreate.SQL.Text := mmProcedureText.Text;
  try
    // Проверяем на правильность
    ibsqlCreate.Prepare;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка при создании/ редактировании процедуры:'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      ModalResult := mrNone;
    end;
  end;
end;

end.
