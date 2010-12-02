
unit mdf_AddFKManagerMetadata;

interface

uses
  IBDatabase, gdModify;

procedure AddFKManagerMetadata(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  Classes, DB, IBSQL, IBBlob, SysUtils, mdf_MetaData_unit;

const
  c_exception = 'CREATE EXCEPTION gd_e_fkmanager ''Exception in FK manager code''';
  c_domain    = 'CREATE DOMAIN d_fk_metaname AS CHAR(31) CHARACTER SET unicode_fss';

  c_gd_ref_constraints =
    'CREATE TABLE gd_ref_constraints ( '#13#10 +
    '  id               dintkey, '#13#10 +
    '  constraint_name  d_fk_metaname UNIQUE, '#13#10 +
    '  const_name_uq    d_fk_metaname, '#13#10 +
    '  match_option     char(7)  character set none, '#13#10 +
    '  update_rule      char(11) character set none, '#13#10 +
    '  delete_rule      char(11) character set none, '#13#10 +
    ' '#13#10 +
    '  constraint_rel   d_fk_metaname, '#13#10 +
    '  constraint_field d_fk_metaname, '#13#10 +
    '  ref_rel          d_fk_metaname, '#13#10 +
    '  ref_field        d_fk_metaname, '#13#10 +
    ' '#13#10 +
    '  ref_state        char(8) character set none, '#13#10 +
    '  ref_next_state   char(8) character set none, '#13#10 +
    ' '#13#10 +
    '  constraint_rec_count COMPUTED BY ('#13#10 +
    '    (SELECT iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5)) FROM rdb$indices i'#13#10 +
    '      JOIN rdb$relation_constraints rc ON rc.rdb$index_name = i.rdb$index_name'#13#10 +
    '      WHERE rc.rdb$relation_name = constraint_rel AND rc.rdb$constraint_type = ''PRIMARY KEY'')),'#13#10 +
    ''#13#10 +
    '  constraint_uq_count COMPUTED BY ('#13#10 +
    '    (SELECT iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5)) FROM rdb$indices i'#13#10 +
    '      JOIN rdb$index_segments iseg ON iseg.rdb$index_name = i.rdb$index_name'#13#10 +
    '        AND iseg.rdb$field_name = constraint_field'#13#10 +
    '      JOIN rdb$relation_constraints rc ON rc.rdb$index_name = i.rdb$index_name'#13#10 +
    '      WHERE i.rdb$relation_name = constraint_rel AND i.rdb$segment_count = 1 AND rc.rdb$constraint_type = ''FOREIGN KEY'')),'#13#10 +
    ''#13#10 +
    '  ref_rec_count COMPUTED BY ('#13#10 +
    '    (SELECT iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5)) FROM rdb$indices i'#13#10 +
    '      JOIN rdb$relation_constraints rc ON rc.rdb$index_name = i.rdb$index_name'#13#10 +
    '      WHERE rc.rdb$relation_name = ref_rel AND rc.rdb$constraint_type = ''PRIMARY KEY'')),'#13#10 +
    ' '#13#10 +
    '  CONSTRAINT gd_pk_ref_constraint PRIMARY KEY (id), '#13#10 +
    '  CONSTRAINT gd_chk1_ref_contraint CHECK (ref_state IN (''ORIGINAL'', ''TRIGGER'')), '#13#10 +
    '  CONSTRAINT gd_chk2_ref_contraint CHECK (ref_next_state IN (''ORIGINAL'', ''TRIGGER'')) '#13#10 +
    ') ';

  c_gd_bi_ref_constraints =
    'CREATE OR ALTER TRIGGER gd_bi_ref_constraints FOR gd_ref_constraints '#13#10 +
    '  BEFORE INSERT '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.ID IS NULL) THEN '#13#10 +
    '    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
    'END ';

  c_bd_ref_constraints =
    'CREATE OR ALTER TRIGGER gd_bd_ref_constraints FOR gd_ref_constraints '#13#10 +
    '  BEFORE DELETE '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (OLD.ref_state <> ''ORIGINAL'') THEN '#13#10 +
    '    EXCEPTION gd_e_fkmanager ''Ref constraint is not in ORIGINAL state''; '#13#10 +
    'END ';

  c_gd_ref_constraint_data =
    'CREATE TABLE gd_ref_constraint_data ( '#13#10 +
    '  constraintkey    dintkey, '#13#10 +
    '  value_data       INTEGER, '#13#10 +
    ' '#13#10 +
    '  CONSTRAINT gd_pk_ref_constraint_data PRIMARY KEY (value_data, constraintkey), '#13#10 +
    '  CONSTRAINT gd_fk_ref_constraint_data FOREIGN KEY (constraintkey) '#13#10 +
    '    REFERENCES gd_ref_constraints (id) '#13#10 +
    '    ON UPDATE CASCADE '#13#10 +
    '    ON DELETE CASCADE '#13#10 +
    ') ';

  {c_gd_ref_x_constraint_data =
    'CREATE UNIQUE INDEX gd_ref_x_constraint_data ON gd_ref_constraint_data '#13#10 +
    '  (value_data, constraintkey) ';}

  c_gd_biu_ref_constraint_data =
    'CREATE OR ALTER TRIGGER gd_biu_ref_constraint_data FOR gd_ref_constraint_data '#13#10 +
    '  BEFORE INSERT OR UPDATE '#13#10 +
    '  POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (RDB$GET_CONTEXT(''USER_TRANSACTION'', ''REF_CONSTRAINT_UNLOCK'') IS DISTINCT FROM ''1'') THEN '#13#10 +
    '    EXCEPTION gd_e_fkmanager ''Constraint data is locked''; '#13#10 +
    'END ';

  c_command =
    'INSERT INTO gd_command '#13#10 +
    '  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED) '#13#10 +
    'VALUES '#13#10 +
    '  (741120,740400,''Внешние ключи'',''gdcFKManager'',0,NULL,228,NULL,''TgdcFKManager'',NULL,1,1,1,0,NULL)';


procedure AddFKManagerMetadata(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    try
      FTransaction.StartTransaction;

      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.ParamCheck := False;

        {FIBSQL.SQL.Text :=
          'select '#13#10 +
          '  c.rdb$constraint_name '#13#10 +
          'from '#13#10 +
          '  rdb$check_constraints c join rdb$triggers t '#13#10 +
          '    on c.rdb$trigger_name = t.rdb$trigger_name '#13#10 +
          'where '#13#10 +
          '  exists ( '#13#10 +
          '    select * '#13#10 +
          '    from rdb$check_constraints c2 join rdb$triggers t2 '#13#10 +
          '      on c2.rdb$trigger_name = t2.rdb$trigger_name '#13#10 +
          '    where '#13#10 +
          '      c2.rdb$constraint_name <> c.rdb$constraint_name '#13#10 +
          '      and c2.rdb$trigger_name = c.rdb$trigger_name) ';
        FIBSQL.ExecQuery;

        if not FIBSQL.Eof then
        begin
          raise Exception.Create(
            'Структура БД повреждена! Обратитесь к системному администратору.'#13#10#13#10 +
            'Два разных CHECK на разных таблицах ссылаются на один и тот же системный триггер.');
        end;}

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''GD_REF_CONSTRAINTS'' ';
        FIBSQL.ExecQuery;

        if not FIBSQL.EOF then
          exit;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_exception;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_domain;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_gd_ref_constraints;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_gd_bi_ref_constraints;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_bd_ref_constraints;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_gd_ref_constraint_data;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_gd_biu_ref_constraint_data;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'GRANT ALL ON gd_ref_constraints TO administrator';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := 'GRANT ALL ON gd_ref_constraint_data TO administrator';
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text := c_command;
        FIBSQL.ExecQuery;

        FIBSQL.Close;
        FIBSQL.SQL.Text :=
          'UPDATE OR INSERT INTO fin_versioninfo ' +
          '  VALUES (119, ''0000.0001.0000.0150'', ''06.06.2010'', ''Add FK manager metadata'') ' +
          '  MATCHING (id)';
        FIBSQL.ExecQuery;

        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        Log('Произошла ошибка: ' + E.Message);
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
