unit mdf_AddUdfDelChar;

interface
uses
  IBDatabase, gdModify;

procedure AddUdfDelChar(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddUdfDelChar(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
//  I: Integer;
begin
  Log('���������� ��������� g_s_delchar');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;
        FIBSQL.SQL.Text := 'DECLARE EXTERNAL FUNCTION G_S_DELCHAR CSTRING(2000) ' +
         ' RETURNS INTEGER BY VALUE ENTRY_POINT ''g_s_delchar'' MODULE_NAME ''GUDF.dll''';
        try
          FTransaction.StartTransaction;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
        except
          on E: Exception do
          begin
           //Log('������: ' + E.Message);
            FTransaction.Rollback;
          end;
        end;
        Log('��������� ���������� ��������� g_s_delchar');
        FIBSQL.Close;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log('������: ' + E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
 
