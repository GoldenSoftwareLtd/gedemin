unit mdf_AddGoodkeyFK_Inv_PriceLine;

interface

uses
  IBDatabase, gdModify;

procedure AddGoodkeyFK_Inv_PriceLine(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;


procedure AddGoodkeyFK_Inv_PriceLine(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      with FIBSQL do
      try
        Transaction := FTransaction;
        SQL.Text :=
         'SELECT * FROM rdb$relation_constraints i WHERE UPPER(i.rdb$constraint_name) = ''INV_FK_PRICELINE_GK''';
        ExecQuery;
        if Eof then
        begin
          Log('Добавление ссылки на товар в inv_priceline');
          Close;
          SQL.Text :=
            ' ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_gk ' +
            '  FOREIGN KEY(goodkey) REFERENCES gd_good(id) ' +
            '  ON UPDATE CASCADE ';
          ExecQuery;
          Close;
          FTransaction.Commit;
          FTransaction.StartTransaction;
          Log('Добавление ссылки прошло успешно');
        end;
        Close;
        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
        Log('Ошибка при добавлении ссылки');
    end;
  finally
    FTransaction.Free;
  end;

end;

end.
