unit mdf_AddFBUDFSupport;

interface

uses
  IBDatabase, gdModify;

procedure AddFBUdfSupport(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddFBUdfSupport(IBDB: TIBDatabase; Log: TModifyLog);
{var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
  I: Integer;
const
  AddSQLArray: Array[0..25] of String = (
    'declare external function invl int by descriptor, int by descriptor returns int by descriptor entry_point ''idNvl'' module_name ''fbudf''',
    'declare external function i64nvl numeric(18,0) by descriptor, numeric(18,0) by descriptor returns numeric(18,0) by descriptor entry_point ''idNvl'' module_name ''fbudf''',
    'declare external function dnvl double precision by descriptor, double precision by descriptor returns double precision by descriptor entry_point ''idNvl'' module_name ''fbudf''',
    'declare external function snvl varchar(100) by descriptor, varchar(100) by descriptor, varchar(100) by descriptor returns parameter 3 entry_point ''sNvl'' module_name ''fbudf''',
    'declare external function inullif int by descriptor, int by descriptor returns int by descriptor entry_point ''iNullIf'' module_name ''fbudf''',
    'declare external function dnullif double precision by descriptor, double precision by descriptor returns double precision by descriptor entry_point ''dNullIf'' module_name ''fbudf''',
    'declare external function i64nullif numeric(18,4) by descriptor, numeric(18,4) by descriptor returns numeric(18,4) by descriptor entry_point ''iNullIf'' module_name ''fbudf''',
    'declare external function snullif varchar(100) by descriptor, varchar(100) by descriptor, varchar(100) by descriptor returns parameter 3 entry_point ''sNullIf'' module_name ''fbudf''',
    'declare external function dow timestamp, varchar(15) returns parameter 2 entry_point ''DOW'' module_name ''fbudf''',
    'declare external function sdow timestamp, varchar(5) returns parameter 2 entry_point ''SDOW'' module_name ''fbudf''',
    'declare external function sright varchar(100) by descriptor, smallint, varchar(100) by descriptor returns parameter 3 entry_point ''right'' module_name ''fbudf''',
    'declare external function addDay timestamp, int returns timestamp entry_point ''addDay'' module_name ''fbudf''',
    'declare external function addWeek timestamp, int returns timestamp entry_point ''addWeek'' module_name ''fbudf''',
    'declare external function addMonth timestamp, int returns timestamp entry_point ''addMonth'' module_name ''fbudf''',
    'declare external function addYear timestamp, int returns timestamp entry_point ''addYear'' module_name ''fbudf''',
    'declare external function addMilliSecond timestamp, int returns timestamp entry_point ''addMilliSecond'' module_name ''fbudf''',
    'declare external function addSecond timestamp, int returns timestamp entry_point ''addSecond'' module_name ''fbudf''',
    'declare external function addMinute timestamp, int returns timestamp entry_point ''addMinute'' module_name ''fbudf''',
    'declare external function addHour timestamp, int returns timestamp entry_point ''addHour'' module_name ''fbudf''',
    'declare external function getExactTimestamp timestamp returns parameter 1 entry_point ''getExactTimestamp'' module_name ''fbudf''',
    'declare external function Truncate int by descriptor, int by descriptor returns parameter 2 entry_point ''truncate'' module_name ''fbudf''',
    'declare external function i64Truncate numeric(18) by descriptor, numeric(18) by descriptor returns parameter 2 entry_point ''truncate'' module_name ''fbudf''',
    'declare external function Round int by descriptor, int by descriptor returns parameter 2 entry_point ''round'' module_name ''fbudf''',
    'declare external function i64Round numeric(18, 4) by descriptor, numeric(18, 4) by descriptor returns parameter 2 entry_point ''round'' module_name ''fbudf''',
    'declare external function dPower double precision by descriptor, double precision by descriptor, double precision by descriptor returns parameter 3 entry_point ''power'' module_name ''fbudf''',
    'declare external function string2blob varchar(300) by descriptor, blob returns parameter 2 entry_point ''string2blob'' module_name ''fbudf''');}
begin
{  Log('Добавление поддержки FBUdf');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;
        for I := Low(AddSQLArray) to High(AddSQlArray) do
        begin
          FIBSQL.SQL.Text := AddSQLArray[I];
          try
            FTransaction.StartTransaction;
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FTransaction.Commit;
          except
            on E: Exception do
            begin
             //Log('Ошибка: ' + E.Message);
              FTransaction.Rollback;
            end;
          end;
        end;
        Log('Завершено добавление поддержки FBUdf');
        FIBSQL.Close;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('Ошибка: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;}
end;

end.
