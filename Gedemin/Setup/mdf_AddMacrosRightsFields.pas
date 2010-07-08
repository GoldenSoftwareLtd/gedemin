unit mdf_AddMacrosRightsFields;

interface

uses
  IBDatabase, gdModify;

procedure AddMacrosrightsFields(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure AddMacrosrightsFields(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, s: TIBSQL;

const
  afull = 'AFULL';
  achag = 'ACHAG';
  aview = 'AVIEW';
  macroslist = 'EVT_MACROSLIST';
  reportlist = 'RP_REPORTLIST';
  AddField = 'alter table %s add %s DSECURITY not null';

begin
  Log('Добавление полей afull, achag, aview в табл. evt_macros, rp_report');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text := 'select * from rdb$relation_fields where ' +
          ' rdb$relation_name = :relationname AND rdb$field_name ' +
          ' = :fieldname ';
        FIBSQL.Prepare;
        s := TIBSQL.Create(nil);
        try
          S.Transaction := FTransaction;
          FIBSQL.ParamByName('relationname').AsString := macroslist;
          FIBSQL.ParamByName('fieldname').AsString := afull;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, afull]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;
          FIBSQL.ParamByName('fieldname').AsString := achag;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, achag]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;
          FIBSQL.ParamByName('fieldname').AsString := aview;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, aview]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;

          FIBSQL.ParamByName('relationname').AsString := reportlist;
          FIBSQL.ParamByName('fieldname').AsString := afull;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, afull]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;
          FIBSQL.ParamByName('fieldname').AsString := achag;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, achag]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;
          FIBSQL.ParamByName('fieldname').AsString := aview;
          FIBSQL.ExecQuery;
          if FIBSQl.Eof then
          begin
            S.SQL.Text := Format(AddField, [macroslist, aview]);
            S.ExecQuery;
            S.Close;
          end;
          FIBSQL.Close;
          Log('Добавление полей прошло успешно');
        finally
          S.Free;
        end;
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
