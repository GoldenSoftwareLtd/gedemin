unit mdf_ConvertBNStatementCommentToBlob;

interface

uses
  IBDatabase, gdModify;

procedure ConvertBNStatementCommentToBlob(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit;

procedure ConvertBNStatementCommentToBlob(IBDB: TIBDatabase; Log: TModifyLog);
const
  STATEMENT_RELATION_NAME = 'BN_BANKSTATEMENTLINE';
  COMMENT_FIELD_NAME      = 'COMMENT';
  NEW_DOMAIN_NAME         = 'DBLOBTEXT80_1251';
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  I: Integer;
  TempCommentFieldName: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  FIBSQL := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;
      FIBSQL.Transaction := FTransaction;
      FIBSQL.ParamCheck := False;

      // Ищем подходящее имя временного поля
      for I := 0 to 999 do
      begin
        TempCommentFieldName := COMMENT_FIELD_NAME + IntToStr(I);
        if FieldExist2(STATEMENT_RELATION_NAME, TempCommentFieldName, FTransaction) then
          TempCommentFieldName := ''
        else
          Break;
      end;

      if TempCommentFieldName = '' then
        raise Exception.Create('Невозможно переименовать поле в ' + STATEMENT_RELATION_NAME);

      FIBSQL.SQL.Text := 'ALTER TABLE ' + STATEMENT_RELATION_NAME  +
        ' ALTER ' + COMMENT_FIELD_NAME + ' TO ' + TempCommentFieldName;
      FIBSQL.ExecQuery;

      FTransaction.Commit;
      FTransaction.StartTransaction;

      // Добавим поле с новым типом данных
      AddField2(STATEMENT_RELATION_NAME, COMMENT_FIELD_NAME, NEW_DOMAIN_NAME, FTransaction);

      FTransaction.Commit;
      FTransaction.StartTransaction;

      FIBSQL.SQL.Text := 'UPDATE ' + STATEMENT_RELATION_NAME + ' SET ' +
        COMMENT_FIELD_NAME + '=' + TempCommentFieldName;
      FIBSQL.ExecQuery;

      // Удалим временное поле
      DropField2(STATEMENT_RELATION_NAME, TempCommentFieldName, FTransaction);

      FIBSQL.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        '  VALUES (126, ''0000.0001.0000.0157'', ''05.11.2010'', ''Relation field BN_BANKSTATEMENTLINE.COMMENT has been extended'') ' +
        '  MATCHING (id)';
      FIBSQL.ExecQuery;
      FIBSQL.Close;

      FTransaction.Commit;
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
    FIBSQL.Free;
    FTransaction.Free;
  end;
end;

end.
