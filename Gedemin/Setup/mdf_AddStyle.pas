unit mdf_AddStyle;
 
interface
 
uses
  IBDatabase, gdModify;
 
procedure AddStyleTables(IBDB: TIBDatabase; Log: TModifyLog);
 
implementation
 
uses
  IBSQL, SysUtils, mdf_metadata_unit;
 
procedure AddStyleTables(IBDB: TIBDatabase; Log: TModifyLog);
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
      try
        FIBSQL.Transaction := FTransaction;

        if not RelationExist2('AT_THEME', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE at_theme ( '#13#10 +
            '  id       dintkey, '#13#10 +
            '  name     dname, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT at_pk_theme PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT at_chk_theme CHECK(name > '''') '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end;
		
        if not IndexExist2('AT_X_THEME_NAME', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE UNIQUE INDEX at_x_theme_name '#13#10 +
            '  ON at_theme COMPUTED BY (UPPER(name))';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_bi_theme FOR at_theme '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;
		
        if not RelationExist2('AT_STYLE_OBJECT', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE at_style_object ( '#13#10 +
            '  id              dintkey, '#13#10 +
            '  objtype         dinteger_notnull, '#13#10 +
            '  objname         dtext255 NOT NULL, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT at_pk_style_object PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT at_chk_style_object CHECK(objname > '''') '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end;
		
        if not IndexExist2('AT_X_STYLE_OBJECT', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE UNIQUE INDEX at_x_style_object '#13#10 +
            '  ON at_style_object COMPUTED BY (UPPER(objname))';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_bi_style_object FOR at_style_object '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;
		
        if not RelationExist2('AT_STYLE', FTransaction) then
        begin
          FIBSQL.SQL.Text :=
            'CREATE TABLE at_style ( '#13#10 +
            '  id              dintkey, '#13#10 +
            '  objectkey       dintkey, '#13#10 +
            '  propid          dinteger_notnull, '#13#10 +
            '  intvalue        dinteger, '#13#10 +
            '  strvalue        dtext60, '#13#10 +
            '  userkey         dforeignkey, '#13#10 +
            '  themekey        dforeignkey, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT at_pk_style PRIMARY KEY (id), '#13#10 +
            '  CONSTRAINT at_fk_style_uk FOREIGN KEY (userkey) '#13#10 +
            '    REFERENCES gd_user (id) '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            '    ON DELETE CASCADE, '#13#10 +
            '  CONSTRAINT at_fk_style_tk FOREIGN KEY (themekey) '#13#10 +
            '    REFERENCES at_theme (id) '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            '    ON DELETE CASCADE, '#13#10 +
            '  CONSTRAINT at_fk_style_ok FOREIGN KEY (objectkey) '#13#10 +
            '    REFERENCES at_style_object (id) '#13#10 +
            '    ON UPDATE CASCADE '#13#10 +
            '    ON DELETE CASCADE '#13#10 +
            ')';
          FIBSQL.ExecQuery;
        end;

        FIBSQL.SQL.Text :=
          'CREATE OR ALTER TRIGGER at_bi_style FOR at_style '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          'AS '#13#10 +
          'BEGIN '#13#10 +
          '  IF (NEW.id IS NULL) THEN '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
          'END';
        FIBSQL.ExecQuery;

        FIBSQL.SQL.Text :=
          'INSERT INTO fin_versioninfo '#13#10 +
          '  VALUES (246, ''0000.0001.0000.0277'', ''23.02.2016'', ''Added Style Tables.'') ';
        FIBSQL.ExecQuery;
      finally
        FIBSQL.Free;
      end;

      FTransaction.Commit;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;  
 
end.