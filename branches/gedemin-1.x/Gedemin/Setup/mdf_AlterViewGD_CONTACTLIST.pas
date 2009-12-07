unit mdf_AlterViewGD_CONTACTLIST;

interface

uses
  IBDatabase, gdModify;

procedure AlterViewContactList(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AlterViewContactList(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;

const
  txt_DEL_View =
    'DROP VIEW gd_v_contactlist ';
  txt_CREATE_GD_CONTACTLIST =
'CREATE VIEW GD_V_CONTACTLIST '#13#10 +
'( '#13#10 +
'  ID, CONTACTNAME, CONTACTTYPE, '#13#10 +
'  GROUPNAME, GROUPID, GROUPLB, GROUPRB, GROUPTYPE '#13#10 +
') AS '#13#10 +
'SELECT '#13#10 +
'  P.ID, P.NAME, P.CONTACTTYPE, C.NAME, C.ID, C.LB, C.RB, C.CONTACTTYPE '#13#10 +
' '#13#10 +
'FROM '#13#10 +
'  GD_CONTACT C '#13#10 +
'    JOIN GD_CONTACTLIST CL ON (C.ID = CL.GROUPKEY) '#13#10 +
'    JOIN GD_CONTACT P ON (CL.CONTACTKEY = P.ID) '#13#10 +
' '#13#10 +
'GROUP BY '#13#10 +
'  P.ID, P.NAME, P.CONTACTTYPE, C.NAME, C.ID, C.LB, C.RB, C.CONTACTTYPE '#13#10;

begin
  Log('Корректировка представления GD_V_CONTACTLIST');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := txt_DEL_View;
        FIBSQL.ParamCheck := False;
        try
          FIBSQL.ExecQuery;
          Log('Удаление GD_V_CONTACTLIST прошло успешно');
          FIBSQL.Close;

          FIBSQL.SQL.Text := txt_CREATE_GD_CONTACTLIST;
          try
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FIBSQL.SQL.Text := 'GRANT ALL ON GD_V_CONTACTLIST TO administrator';
            FIBSQL.ExecQuery;
            Log('Добавление GD_V_CONTACTLIST прошло успешно');
            FIBSQL.Close;
            FTransaction.Commit;

            IBDB.Connected := False;
            IBDB.Connected := True;

            FTransaction.StartTransaction;
            FIBSQL.SQL.Text := 'ALTER TABLE GD_CONTACTLIST DROP CONSTRAINT gd_pk_contactlist';
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FTransaction.Commit;

            IBDB.Connected := False;
            IBDB.Connected := True;

            FTransaction.StartTransaction;
            FIBSQL.SQL.Text := 'ALTER TABLE gd_contactlist ADD CONSTRAINT gd_pk_contactlist PRIMARY KEY (groupkey, contactkey)';
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FTransaction.Commit;

            Log('Обновление PRIMARY KEY прошло успешно');

            IBDB.Connected := False;
            IBDB.Connected := True;

            FTransaction.StartTransaction;
            FIBSQL.SQL.Text := 'ALTER TABLE gd_contactlist ADD TEMPKEY DINTEGER';
            try
              FIBSQL.ExecQuery;
              FTransaction.Commit;
              FTransaction.StartTransaction;
            except
            end;
            FIBSQL.Close;

            FIBSQL.SQL.Text := 'delete from gd_contactlist l where EXISTS ' +
            ' (select * from gd_contactlist l1 WHERE l.contactkey = l1.groupkey AND l.groupkey = l1.contactkey)';
            FIBSQL.ExecQuery;
            FIBSQL.Close;

            FIBSQL.SQL.Text := 'update gd_contactlist l set TEMPKEY = groupkey where ' +
              ' EXISTS(SELECT * FROM gd_contact c WHERE l.groupkey = c.id AND c.contacttype = 2)';
            FIBSQL.ExecQuery;
            FIBSQL.Close;


            FIBSQL.SQL.Text := 'update gd_contactlist l set groupkey = contactkey, contactkey = tempkey where ' +
              ' EXISTS(SELECT * FROM gd_contact c WHERE l.groupkey = c.id AND c.contacttype = 2)';
            FIBSQL.ExecQuery;
            FIBSQL.Close;
            FTransaction.Commit;

            FTransaction.StartTransaction;
            FIBSQL.SQL.Text := 'ALTER TABLE gd_contactlist DROP TEMPKEY ';
            try
              FIBSQL.ExecQuery;
            except
            end;
            FIBSQL.Close;

            FTransaction.Commit;
            Log('Обновление GD_CONTACTLIST прошло успешно');
          except
            on E: Exception do
            begin
              Log(E.Message);
              FTransaction.Rollback;
            end;
          end;

        except
          on E: Exception do
          begin
            Log(E.Message);
            FTransaction.Rollback;
          end;

        end;

        FIBSQL.Close;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
