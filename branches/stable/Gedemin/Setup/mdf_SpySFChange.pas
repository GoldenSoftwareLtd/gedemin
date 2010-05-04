unit mdf_SpySFChange;

interface

uses
  IBDatabase, gdModify;

procedure SpySFChange(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

const
  CreateTaxSQL: array[0..4] of String =
    (
      'CREATE GENERATOR gd_g_functionch',

      'SET GENERATOR gd_g_functionch TO 1',

      'COMMIT',

      'CREATE TRIGGER gd_function_au_ch FOR gd_function ' +
      'AFTER UPDATE POSITION 32000 ' +
      'AS ' +
      '  DECLARE VARIABLE I INTEGER; ' +
      'BEGIN ' +
      '  I = GEN_ID(gd_g_functionch, 1); ' +
      'END ',

      'CREATE TRIGGER gd_function_ad_ch FOR gd_function ' +
      'AFTER DELETE POSITION 32000 ' +
      'AS ' +
      '  DECLARE VARIABLE I INTEGER; ' +
      'BEGIN ' +
      '  I = GEN_ID(gd_g_functionch, 1); ' +
      'END '
    );

procedure SpySFChange(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
//  TablesFound: String;
//  I: Integer;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Transaction := FTransaction;
        Transaction.StartTransaction;

        Log('Файл-кэш СФ: Добавление метаданных.');

        SQL.Text :=
          'SELECT * FROM rdb$generators gr ' +
          'WHERE ' +
          '  gr.rdb$generator_name = ''GD_G_FUNCTIONCH'' ';
        ExecQuery;

        if Eof then
        begin
          Close;
          SQL.Text :=
            'CREATE GENERATOR gd_g_functionch';
          ExecQuery;
          Close;
          SQL.Text :=
            'SET GENERATOR gd_g_functionch TO 1';
          ExecQuery;
          Transaction.Commit;
          Log('Файл-кэш СФ: Добавлен генератор gd_g_functionch.');
        end;

        if not Transaction.Active then
          Transaction.StartTransaction;

        if Open then
          Close;
        SQL.Text :=
          'SELECT * FROM rdb$triggers tr ' +
          'WHERE ' +
          '  tr.rdb$relation_name = ''GD_FUNCTION'' and ' +
          '  tr.rdb$trigger_name = ''GD_FUNCTION_AU_CH'' ';

        ExecQuery;
        if Eof then
        begin
          if Open then
            Close;
          SQL.Text :=
            'CREATE TRIGGER gd_function_au_ch FOR gd_function ' +
            'AFTER UPDATE POSITION 32000 ' +
            'AS ' +
            '  DECLARE VARIABLE I INTEGER; ' +
            'BEGIN ' +
            '  I = GEN_ID(gd_g_functionch, 1); ' +
            'END ';

          ExecQuery;
          Transaction.Commit;
          Log('Файл-кэш СФ: Добавлен триггер gd_function_au_ch.');
        end;

        if not Transaction.Active then
          Transaction.StartTransaction;

        if Open then
          Close;
        SQL.Text :=
          'SELECT * FROM rdb$triggers tr ' +
          'WHERE ' +
          '  tr.rdb$relation_name = ''GD_FUNCTION'' and ' +
          '  tr.rdb$trigger_name = ''GD_FUNCTION_AD_CH'' ';

        ExecQuery;
        if Eof then
        begin
          if Open then
            Close;
          SQL.Text :=
            'CREATE TRIGGER gd_function_ad_ch FOR gd_function ' +
            'AFTER DELETE POSITION 32000 ' +
            'AS ' +
            '  DECLARE VARIABLE I INTEGER; ' +
            'BEGIN ' +
            '  I = GEN_ID(gd_g_functionch, 1); ' +
            'END ';

          ExecQuery;
          Transaction.Commit;
          Log('Файл-кэш СФ: Добавлен триггер gd_function_ad_ch.');
        end;

        Log('Файл-кэш СФ: Метаданные успешно добавлены.');

        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
        Log('Файл-кэш СФ: Ошибка при добавление метаданных.');
    end;
  finally
    FTransaction.Free;
  end;
end;

end.

