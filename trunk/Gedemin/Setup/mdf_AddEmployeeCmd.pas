
unit mdf_AddEmployeeCmd;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, mdf_dlgDefaultCardOfAccount_unit, Forms,
  Windows, Controls;

procedure AddEmployeeCmd(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes;

procedure AddEmployeeCmd(IBDB: TIBDatabase; Log: TModifyLog);
var
  IBTr: TIBTransaction;
  q: TIBSQL;
begin
  Log('Добавление команды Сотрудники в Исследователь');
  IBTr := TIBTransaction.Create(nil);
  try
    IBTr.DefaultDatabase := IBDB;
    IBTr.StartTransaction;

    q := TIBSQL.Create(nil);
    q.Transaction := IBTr;

    try
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) ' +
        '  VALUES ( ' +
        '    730110, ' +
        '    730100, ' +
        '    ''Организации'', ' +
        '    '''', ' +
        '    ''TgdcCompany'', ' +
        '    NULL, ' +
        '    0 ' +
        '  ) ' +
        'MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) ' +
        '  VALUES ( ' +
        '    730902, ' +
        '    730110, ' +
        '    ''Сотрудники'', ' +
        '    ''ref_employee'', ' +
        '    ''TgdcEmployee'', ' +
        '    NULL, ' +
        '    0 ' +
        '  ) ' +
        'MATCHING (id)';
      q.ExecQuery;

      q.SQL.Text :=
        'UPDATE OR INSERT INTO fin_versioninfo ' +
        'VALUES (75, ''0000.0001.0000.0103'', ''30.05.2006'', ''Employee branch added into Explorer'') ' +
        'MATCHING (id)';
      q.ExecQuery;

      IBTr.Commit;
    finally
      q.Free;
      IBTr.Free;
    end;
  except
    on E: Exception do
    begin
      Log('Ошибка:' +  E.Message);
      raise;
    end;
  end;
end;

end.
