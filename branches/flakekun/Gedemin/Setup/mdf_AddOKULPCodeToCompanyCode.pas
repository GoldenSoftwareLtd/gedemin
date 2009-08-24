unit mdf_AddOKULPCodeToCompanyCode;

interface

uses
  IBDatabase, gdModify;

procedure AddOKULPCodeToCompanyCode(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, gdcMetaData;

const
  GD_V_COMPANY_NAME = 'GD_V_COMPANY';
  GD_V_COMPANY_TEMP_NAME = 'GD_V_COMPANY_TEMP';
  GD_V_COMPANY_TEXT =
    ' CREATE VIEW GD_V_COMPANY_TEMP( '#13#10 +
    '     ID, '#13#10 +
    '     COMPNAME, '#13#10 +
    '     COMPFULLNAME, '#13#10 +
    '     COMPANYTYPE, '#13#10 +
    '     COMPLB, '#13#10 +
    '     COMPRB, '#13#10 +
    '     AFULL, '#13#10 +
    '     ACHAG, '#13#10 +
    '     AVIEW, '#13#10 +
    '     ADDRESS, '#13#10 +
    '     CITY, '#13#10 +
    '     COUNTRY, '#13#10 +
    '     PHONE, '#13#10 +
    '     FAX, '#13#10 +
    '     ACCOUNT, '#13#10 +
    '     BANKCODE, '#13#10 +
    '     BANKMFO, '#13#10 +
    '     BANKNAME, '#13#10 +
    '     BANKADDRESS, '#13#10 +
    '     BANKCITY, '#13#10 +
    '     BANKCOUNTRY, '#13#10 +
    '     TAXID, '#13#10 +
    '     OKPO, '#13#10 +
    '     LICENCE, '#13#10 +
    '     OKNH, '#13#10 +
    '     SOATO, '#13#10 +
    '     SOOU, '#13#10 +
    '     OKULP) '#13#10 +
    ' AS '#13#10 +
    ' SELECT '#13#10 +
    '   C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE,  '#13#10 +
    '   C.LB, C.RB, C.AFULL, C.ACHAG, C.AVIEW, '#13#10 +
    '   C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX, '#13#10 +
    '   AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO, '#13#10 +
    '   BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY, '#13#10 +
    '   CC.TAXID, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU, CC.OKULP '#13#10 +
    '  '#13#10 +
    ' FROM '#13#10 +
    '     GD_CONTACT C '#13#10 +
    '     JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = C.ID) '#13#10 +
    '     LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID '#13#10 +
    '     LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY '#13#10 +
    '     LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY '#13#10 +
    '    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID ';

  GD_V_OURCOMPANY_NAME = 'GD_V_OURCOMPANY';
  GD_V_OURCOMPANY_TEMP_NAME = 'GD_V_OURCOMPANY_TEMP';
  GD_V_OURCOMPANY_TEXT =
    ' CREATE VIEW GD_V_OURCOMPANY_TEMP '#13#10 +
    ' ( '#13#10 +
    '   ID, COMPNAME, COMPFULLNAME, COMPANYTYPE, COMPLB, COMPRB, '#13#10 +
    '   AFULL, ACHAG, AVIEW, ADDRESS, CITY, COUNTRY, '#13#10 +
    '   ACCOUNT, BANKCODE, BANKMFO, BANKNAME, BANKADDRESS, BANKCITY, '#13#10 +
    '   BANKCOUNTRY, TAXID, OKPO, LICENCE, OKNH, SOATO, SOOU, OKULP '#13#10 +
    ' ) '#13#10 +
    ' AS '#13#10 +
    ' SELECT '#13#10 +
    '   C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE,  '#13#10 +
    '   C.LB, C.RB, O.AFULL, O.ACHAG, O.AVIEW, '#13#10 +
    '   C.ADDRESS, C.CITY, C.COUNTRY, '#13#10 +
    '   AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO, '#13#10 +
    '   BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY, '#13#10 +
    '   CC.TAXID, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU, CC.OKULP '#13#10 +
    '  '#13#10 +
    ' FROM '#13#10 +
    '   GD_OURCOMPANY O '#13#10 +
    '     JOIN GD_CONTACT C ON (O.COMPANYKEY = C.ID) '#13#10 +
    '     JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = O.COMPANYKEY) '#13#10 +
    '     LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID '#13#10 +
    '     LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY '#13#10 +
    '     LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY '#13#10 +
    '    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID ';

procedure AddOKULPCodeToCompanyCode(IBDB: TIBDatabase; Log: TModifyLog);
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
        FIBSQL.Transaction := FTransaction;

        FTransaction.StartTransaction;
        FIBSQL.SQL.Text :=
          ' SELECT * ' +
          ' FROM rdb$relation_fields ' +
          ' WHERE rdb$field_name = ''OKULP'' AND rdb$relation_name = ''GD_COMPANYCODE''';
        FIBSQL.ExecQuery;
        if FIBSQL.RecordCount = 0 then
        begin
          FIBSQL.Close;
          FIBSQL.SQL.Text :=
           'ALTER TABLE gd_companycode ADD okulp dtext20';
          try
            FIBSQL.ExecQuery;
            Log('Добавление поля OKULP в таблицу GD_COMPANYCODE прошло успешно');
            FTransaction.Commit;
          except
            on E: Exception do
            begin
              Log(E.Message);
              FTransaction.Rollback;
            end;
          end;

          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
            ' INSERT INTO RDB$RELATION_FIELDS ' +
            '  (rdb$field_name, rdb$relation_name, rdb$field_source, rdb$base_field, ' +
            '   rdb$field_position, rdb$update_flag, rdb$field_id, rdb$view_context, rdb$system_flag) ' +
            ' VALUES ' +
            '  (''OKULP'', ''GD_V_COMPANY'', ''DTEXT20'', ''OKULP'', ' +
            '   27, 0, 27, 5, 0) ';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
            ' INSERT INTO RDB$RELATION_FIELDS ' +
            '  (rdb$field_name, rdb$relation_name, rdb$field_source, rdb$base_field, ' +
            '   rdb$field_position, rdb$update_flag, rdb$field_id, rdb$view_context, rdb$system_flag) ' +
            ' VALUES ' +
            '  (''OKULP'', ''GD_V_OURCOMPANY'', ''DTEXT20'', ''OKULP'', ' +
            '   25, 0, 25, 6, 0) ';
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;
        end
        else
        begin
          FIBSQL.Close;
        end;

        // Добавление в представление GD_V_COMPANY поля OKULP
        if not FTransaction.InTransaction then
          FTransaction.StartTransaction;
        FIBSQL.SQL.Text := GD_V_COMPANY_TEXT;
        try
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          //Перенесём blr
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
            'UPDATE RDB$RELATIONS R ' +
            'SET R.RDB$VIEW_BLR = ' +
            '  (SELECT R1.RDB$VIEW_BLR FROM RDB$RELATIONS R1 ' +
            '   WHERE R1.RDB$RELATION_NAME = :temp_v), ' +
            ' R.RDB$VIEW_SOURCE = ' +
            '  (SELECT R1.RDB$VIEW_SOURCE FROM RDB$RELATIONS R1 ' +
            '   WHERE R1.RDB$RELATION_NAME = :temp_v) ' +
            'WHERE R.RDB$RELATION_NAME = :rn ';
          FIBSQL.ParamByName('TEMP_V').AsString := GD_V_COMPANY_TEMP_NAME;
          FIBSQL.ParamByName('RN').AsString := GD_V_COMPANY_NAME;
          try
            FIBSQL.ExecQuery;
          except
            FTransaction.Rollback;
          end;
          FIBSQL.Close;
          if FTransaction.InTransaction then
            FTransaction.Commit;

          FTransaction.StartTransaction;
          FIBSQL.SQL.Text := 'DROP VIEW ' + GD_V_COMPANY_TEMP_NAME;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          Log('Добавление в представление GD_V_COMPANY поля OKULP прошло успешно');
        except
          on E: Exception do
          begin
            Log(E.Message);
            FTransaction.Rollback;
          end;
        end;

        // Добавление в представление GD_V_OURCOMPANY поля OKULP
        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := GD_V_OURCOMPANY_TEXT;
        try
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          //Перенесём blr
          FTransaction.StartTransaction;
          FIBSQL.SQL.Text :=
            'UPDATE RDB$RELATIONS R ' +
            'SET R.RDB$VIEW_BLR = ' +
            '  (SELECT R1.RDB$VIEW_BLR FROM RDB$RELATIONS R1 ' +
            '   WHERE R1.RDB$RELATION_NAME = :temp_v), ' +
            ' R.RDB$VIEW_SOURCE = ' +
            '  (SELECT R1.RDB$VIEW_SOURCE FROM RDB$RELATIONS R1 ' +
            '   WHERE R1.RDB$RELATION_NAME = :temp_v) ' +
            'WHERE R.RDB$RELATION_NAME = :rn ';
          FIBSQL.ParamByName('TEMP_V').AsString := GD_V_OURCOMPANY_TEMP_NAME;
          FIBSQL.ParamByName('RN').AsString := GD_V_OURCOMPANY_NAME;
          try
            FIBSQL.ExecQuery;
          except
            FTransaction.Rollback;
          end;
          FIBSQL.Close;
          if FTransaction.InTransaction then
            FTransaction.Commit;

          FTransaction.StartTransaction;
          FIBSQL.SQL.Text := 'DROP VIEW ' + GD_V_OURCOMPANY_TEMP_NAME;
          FIBSQL.ExecQuery;
          FIBSQL.Close;
          FTransaction.Commit;

          Log('Добавление в представление GD_V_OURCOMPANY поля OKULP прошло успешно');
        except
          on E: Exception do
          begin
            Log(E.Message);
            FTransaction.Rollback;
          end;
        end;

        Log('Выполнение процедуры at_p_sync');
        FTransaction.StartTransaction;
        FIBSQL.SQL.Text := 'EXECUTE PROCEDURE at_p_sync ';
        FIBSQL.ExecQuery;
        FIBSQL.Close;
        FTransaction.Commit;

        if not FTransaction.InTransaction then
          FTransaction.StartTransaction;
        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo ' +
          '  VALUES (104, ''0000.0001.0000.0131'', ''19.12.2008'', ''Добавлено поле OKULP в таблицу GD_COMPANYCODE'')';
        try
          FIBSQL.ExecQuery;
          FTransaction.Commit;
        except
        end;
        
      finally
        FIBSQL.Free;
      end;
      if FTransaction.InTransaction then
        FTransaction.Commit;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка при добавлении поля OKULP в таблицу GD_COMPANYCODE!' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;


end.
