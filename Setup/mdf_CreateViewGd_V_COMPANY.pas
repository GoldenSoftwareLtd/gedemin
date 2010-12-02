unit mdf_CreateViewGd_V_COMPANY;

interface

uses
  IBDatabase, gdModify;

procedure CreateViewGd_V_COMPANY(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure CreateViewGd_V_COMPANY(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;

const
  txt_CREATE_GD_CONTACTLIST =
'CREATE VIEW GD_V_COMPANY( '#13#10 +
'    ID, '#13#10 +
'    COMPNAME, '#13#10 +
'    COMPFULLNAME, '#13#10 +
'    COMPANYTYPE, '#13#10 +
'    COMPLB, '#13#10 +
'    COMPRB, '#13#10 +
'    AFULL, '#13#10 +
'    ACHAG, '#13#10 +
'    AVIEW, '#13#10 +
'    ADDRESS, '#13#10 +
'    CITY, '#13#10 +
'    COUNTRY, '#13#10 +
'    PHONE, '#13#10 +
'    FAX, '#13#10 +
'    ACCOUNT, '#13#10 +
'    BANKCODE, '#13#10 +
'    BANKMFO, '#13#10 +
'    BANKNAME, '#13#10 +
'    BANKADDRESS, '#13#10 +
'    BANKCITY, '#13#10 +
'    BANKCOUNTRY, '#13#10 +
'    TAXID, '#13#10 +
'    OKPO, '#13#10 +
'    LICENCE, '#13#10 +
'    OKNH, '#13#10 +
'    SOATO, '#13#10 +
'    SOOU) '#13#10 +
'AS '#13#10 +
'SELECT '#13#10 +
'  C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE,  '#13#10 +
'  C.LB, C.RB, C.AFULL, C.ACHAG, C.AVIEW, '#13#10 +
'  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX, '#13#10 +
'  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO, '#13#10 +
'  BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY, '#13#10 +
'  CC.TAXID, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU '#13#10 +
' '#13#10 +
'FROM '#13#10 +
'    GD_CONTACT C '#13#10 +
'    JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = C.ID) '#13#10 +
'    LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID '#13#10 +
'    LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY '#13#10 +
'    LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY '#13#10 +
'    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID; ';


begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := txt_CREATE_GD_CONTACTLIST;
        FIBSQL.ParamCheck := False;
        try
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
          Log('Добавление представления GD_V_COMPANY прошло успешно');
        except
          FTransaction.Rollback;
        end;

        FTransaction.StartTransaction;
        FIBSQL.Close;
        FIBSQL.SQL.Text := 'GRANT ALL ON GD_V_COMPANY TO administrator';
        FIBSQL.ExecQuery;
        FTransaction.Commit;


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
  end;
end;

end.
