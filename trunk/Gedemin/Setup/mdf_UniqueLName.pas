
unit mdf_UniqueLName;

interface

uses
  IBDatabase, gdModify;

procedure UniqueLName(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  SysUtils, IBSQL, mdf_metadata_unit;

procedure UniqueLName(IBDB: TIBDatabase; Log: TModifyLog);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Log('Проверка уникальности локализованных имен');
  try
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := IBDB;
      q.Transaction := Tr;

      Tr.StartTransaction;

      q.SQL.Text := 'update at_relations a ' +
          'set a.lname=a.lname || cast(a.id as varchar(20)) ' +
          'where (select count(*) from at_relations a2 where UPPER(a2.lname)=UPPER(a.lname)) > 1 ';
      q.ExecQuery;

      q.SQL.Text := 'update at_relations a ' +
          'set a.lshortname=a.lshortname || cast(a.id as varchar(20)) ' +
          'where (select count(*) from at_relations a2 where UPPER(a2.lshortname)=UPPER(a.lshortname)) > 1 ';
      q.ExecQuery;

      q.SQL.Text := 'update gd_documenttype a ' +
          'set a.name=a.name || cast(a.id as varchar(20)) ' +
          'where (select count(*) from gd_documenttype a2 where UPPER(a2.name)=UPPER(a.name)) > 1 ';
      q.ExecQuery;

      Tr.Commit;
      Log('Проверка прошла успешно');
    finally
      q.Free;
      Tr.free;
    end;
  except
    Log('Ошибка при проверки уникальности');
  end;

  Log('Adding fields into gd_company');
  try
    tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := IBDB;
      q.Transaction := Tr;

      Tr.StartTransaction;

      if not FieldExist2('GD_COMPANY', 'DIRECTORKEY', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_company ADD directorkey dforeignkey ';
        q.ExecQuery;
      end;

      if not ConstraintExist2('GD_COMPANY', 'GD_FK_COMPANY_DIRECTORKEY', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_directorkey ' +
          'FOREIGN KEY (directorkey) REFERENCES gd_people(contactkey) ' +
          'ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not FieldExist2('GD_COMPANY', 'CHIEFACCOUNTANTKEY', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_company ADD chiefaccountantkey dforeignkey ';
        q.ExecQuery;
      end;

      if ConstraintExist2('GD_COMPANY', 'GD_FK_COMPANY_CHIEFACCOUNTANTKE', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_company DROP CONSTRAINT gd_fk_company_chiefaccountantke';
        q.ExecQuery;
      end;

      if not ConstraintExist2('GD_COMPANY', 'GD_FK_COMPANY_CHIEFACCKEY', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_chiefacckey ' +
          'FOREIGN KEY (chiefaccountantkey) REFERENCES gd_people(contactkey) ' +
          'ON UPDATE CASCADE ';
        q.ExecQuery;
      end;

      if not FieldExist2('AC_ACCOUNT', 'DESCRIPTION', Tr) then
      begin
        q.SQL.Text := 'ALTER TABLE ac_account ADD description      dblobtext80_1251';
        q.ExecQuery;
      end;

      Tr.Commit;
    finally
      q.Free;
      Tr.free;
    end;
  except
    Log('Error while adding fields into gd_company');
  end;
end;

end.
