unit mfd_Create_gd_File;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure Create_gd_File(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure Create_gd_File(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      //���������, ������ �� �����
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$fields WHERE rdb$field_name = ''DFILETYPE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE DOMAIN dfiletype AS CHAR(1) NOT NULL CHECK (VALUE IN (''D'', ''F''));';
        Log('�������� ������ DFILETYPE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������, ������� �� �������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name = ''GD_FILE''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TABLE gd_file ' +
          ' ( ' +
          '   id              dintkey, ' +
          '   /* ����� (�������) �������. ������������ ����� �������������� */ ' +
          '   /* ��� ������ ���������� ������, ���� ������ � ������ */ ' +
          '   /* ��������� � ������ �������� */ ' +
          '   lb              dlb, ' +
          '   rb              drb,          /* ������ (������) ������� */ ' +
          ' ' +
          '   parent          dparent, ' +
          '   filetype        dfiletype,    /* D - ����������, F - ����  */ ' +
          '   name            dfilename NOT NULL,             /* _�� ����� ��� ���i     */ ' +
          '   datasize        dinteger,          /* ������ ����� */ ' +
          '   data            dblob4096,         /* ������ ������ */ ' +
          ' ' +
          '   afull           dsecurity,           /* ����� �������                   */ ' +
          '   achag           dsecurity, ' +
          '   aview           dsecurity, ' +
          ' ' +
          '   creatorkey      dintkey,             /* ��� ������� ��������            */ ' +
          '   creationdate    dcreationdate,       /* ���� _ ��� ����������           */ ' +
          '   editorkey       dintkey,             /* ��� ���������                  */ ' +
          '   editiondate     deditiondate,        /* ���� _ ��� �������������        */ ' +
          '   reserved        dreserved ) ';
        Log('�������� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
        ibsql.Close;
        ibsql.SQL.Text := 'GRANT ALL ON gd_file TO administrator';
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;

      end;

      //����� �������� ����������� ������������

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = :cn';
      ibsql.ParamByName('cn').AsString := 'GD_PK_FILE';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_file ADD CONSTRAINT gd_pk_file ' +
          ' PRIMARY KEY (id)';
        Log('�������� ����������� GD_PK_FILE �� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = :cn';
      ibsql.ParamByName('cn').AsString := 'GD_FK_FILE_PARENT';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_parent ' +
          ' FOREIGN KEY (parent) REFERENCES gd_file(id) ON DELETE CASCADE ON UPDATE CASCADE';
        Log('�������� ����������� GD_FK_FILE_PARENT �� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = :cn';
      ibsql.ParamByName('cn').AsString := 'GD_FK_FILE_EDITORKEY';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_editorkey ' +
          ' FOREIGN KEY (editorkey) REFERENCES gd_people(contactkey) ON UPDATE CASCADE';
        Log('�������� ����������� GD_FK_FILE_EDITORKEY �� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = :cn';
      ibsql.ParamByName('cn').AsString := 'GD_FK_FILE_CREATORKEY';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_creatorkey ' +
          ' FOREIGN KEY (creatorkey) REFERENCES gd_people(contactkey) ON UPDATE CASCADE';
        Log('�������� ����������� GD_FK_FILE_CREATORKEY �� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ����������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''GD_E_INVALIDFILENAME''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE EXCEPTION gd_e_invalidfilename ''You entered invalid filename!'';';
        Log('�������� ���������� GD_E_INVALIDFILENAME');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ����������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''GD_E_INVALIDTREEFILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE EXCEPTION GD_E_INVALIDTREEFILE ''You made an attempt to cycle branch''';
        Log('�������� ���������� GD_E_INVALIDTREEFILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ��������
      ibsql.Close;
      ibsql.ParamCheck := False;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''GD_BI_FILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' CREATE TRIGGER gd_bi_file FOR gd_file '#13#10 +
          '  BEFORE INSERT '#13#10 +
          '  POSITION 0 '#13#10 +
          '          AS  '#13#10 +
          '  DECLARE VARIABLE id INTEGER;  '#13#10 +
          '  BEGIN  '#13#10 +
          '  IF (NEW.id IS NULL) THEN  '#13#10 +
          '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);  '#13#10 +
          '  '#13#10 +
          '  IF (NEW.creatorkey IS NULL) THEN  '#13#10 +
          '    NEW.creatorkey = 650002;  '#13#10 +
          '  IF (NEW.creationdate IS NULL) THEN  '#13#10 +
          '    NEW.creationdate = CURRENT_TIMESTAMP;  '#13#10 +
          '  '#13#10 +
          '  IF (NEW.editorkey IS NULL) THEN  '#13#10 +
          '    NEW.editorkey = 650002;  '#13#10 +
          '  IF (NEW.editiondate IS NULL) THEN  '#13#10 +
          '    NEW.editiondate = CURRENT_TIMESTAMP;  '#13#10 +
          '  '#13#10 +
          '  IF (NEW.parent IS NULL) THEN  '#13#10 +
          '  BEGIN  '#13#10 +
          '    SELECT id FROM gd_file  '#13#10 +
          '    WHERE parent = NEW.parent AND UPPER(name) = g_s_ansiuppercase(NEW.name)  '#13#10 +
          '    AND id <> NEW.id  '#13#10 +
          '    INTO :id;  '#13#10 +
          '  END  '#13#10 +
          '  ELSE  '#13#10 +
          '  BEGIN  '#13#10 +
          '    SELECT id FROM gd_file  '#13#10 +
          '    WHERE parent = NEW.parent AND UPPER(name) = g_s_ansiuppercase(NEW.name)  '#13#10 +
          '    AND id <> NEW.id  '#13#10 +
          '    INTO :id;  '#13#10 +
          '  END  '#13#10 +
          '  '#13#10 +
          '  IF (:id IS NOT NULL) THEN  '#13#10 +
          '    EXCEPTION gd_e_InvalidFileName;  '#13#10 +
          '  END  ';

        Log('�������� �������� GD_BI_FILE ��� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ��������
      ibsql.Close;
      ibsql.ParamCheck := False;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''GD_BU_FILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' CREATE TRIGGER gd_bu_file FOR gd_file '#13#10 +
          '  BEFORE UPDATE '#13#10 +
          '  POSITION 0 '#13#10 +
          '  AS  '#13#10 +
          '    DECLARE VARIABLE id INTEGER;  '#13#10 +
          '  BEGIN  '#13#10 +
          '  IF (NEW.parent IS NULL) THEN  '#13#10 +
          '  BEGIN  '#13#10 +
          '    SELECT id FROM gd_file  '#13#10 +
          '    WHERE parent = NEW.parent AND UPPER(name) = g_s_ansiuppercase(NEW.name)  '#13#10 +
          '    AND id <> NEW.id  '#13#10 +
          '    INTO :id;  '#13#10 +
          '  END  '#13#10 +
          '  ELSE  '#13#10 +
          '  BEGIN  '#13#10 +
          '    SELECT id FROM gd_file  '#13#10 +
          '    WHERE parent = NEW.parent AND UPPER(name) = g_s_ansiuppercase(NEW.name)  '#13#10 +
          '    AND id <> NEW.id  '#13#10 +
          '    INTO :id;  '#13#10 +
          '  END  '#13#10 +
          '  '#13#10 +
          '  IF (:id IS NOT NULL) THEN  '#13#10 +
          '    EXCEPTION gd_e_InvalidFileName;  '#13#10 +
          '  END  ';

        Log('�������� �������� GD_BU_FILE ��� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �������  LB
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''GD_X_FILE_LB''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE INDEX gd_x_file_lb ON gd_file(lb)';
        Log('�������� ������� GD_X_FILE_LB');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �������  RB
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''GD_X_FILE_RB''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE DESCENDING INDEX gd_x_file_rb ON gd_file(rb)';
        Log('�������� ������� GD_X_FILE_LB');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �����������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = ''GD_CHK_FILE_TR_LMT''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE GD_FILE ADD CONSTRAINT GD_CHK_FILE_TR_LMT CHECK ((lb <= rb) or ((rb is NULL) and (lb is NULL)));';
        Log('�������� ����������� GD_CHK_FILE_TR_LMT');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �������� ��� ������  � LB, RB
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''GD_P_GCHC_FILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := ' CREATE PROCEDURE GD_P_GCHC_FILE ( '#13#10 +
        '      PARENT INTEGER, '#13#10 +
        '      FIRSTINDEX INTEGER) '#13#10 +
        '  RETURNS ( '#13#10 +
        '      LASTINDEX INTEGER) '#13#10 +
        '  AS '#13#10 +
        '    DECLARE VARIABLE ChildKey INTEGER; '#13#10 +
        '  BEGIN '#13#10 +
        '    /* ����������� ��������� �������� */ '#13#10 +
        '    LastIndex = :FirstIndex + 1; '#13#10 +
        ' '#13#10 +
        '    /* ���������� ����� �� ������� */ '#13#10 +
        '    FOR '#13#10 +
        '      SELECT id '#13#10 +
        '      FROM gd_file '#13#10 +
        '      WHERE parent = :Parent '#13#10 +
        '      INTO :ChildKey '#13#10 +
        '    DO '#13#10 +
        '    BEGIN '#13#10 +
        '      /* �������� ������� ����� */ '#13#10 +
        '      EXECUTE PROCEDURE gd_p_gchc_file (:ChildKey, :LastIndex) '#13#10 +
        '        RETURNING_VALUES :LastIndex; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    LastIndex = :LastIndex + 9; '#13#10 +
        ' '#13#10 +
        '    /* �������� ������� �������� */ '#13#10 +
        '    UPDATE gd_file '#13#10 +
        '      SET lb = :FirstIndex + 1, rb = :LastIndex '#13#10 +
        '      WHERE id = :Parent; '#13#10 +
        '  END ';

        Log('�������� ��������� GD_P_GCHC_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �������� ��� ������  � LB, RB
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''GD_P_RESTRUCT_FILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := ' CREATE PROCEDURE GD_P_RESTRUCT_FILE '#13#10 +
        '  AS '#13#10 +
        '    DECLARE VARIABLE CurrentIndex INTEGER; '#13#10 +
        '    DECLARE VARIABLE ChildKey INTEGER; '#13#10 +
        '  BEGIN '#13#10 +
        '    /* ������������� ������ ���������� ������������ */ '#13#10 +
        '    /* �� �� ���� ���������� ������������, �� ������� */ '#13#10 +
        '    /* �� ������������ �������� ��� LB, RB. */ '#13#10 +
        ' '#13#10 +
        '    CurrentIndex = 1; '#13#10 +
        ' '#13#10 +
        '    /* ��� ���� ��������� ��������� ������ ... */ '#13#10 +
        '    FOR '#13#10 +
        '      SELECT id '#13#10 +
        '      FROM gd_file '#13#10 +
        '      WHERE parent IS NULL '#13#10 +
        '      INTO :ChildKey '#13#10 +
        '    DO '#13#10 +
        '    BEGIN '#13#10 +
        '      /* ... ������ ������� ��� ����� */ '#13#10 +
        '      EXECUTE PROCEDURE gd_p_gchc_file (:ChildKey, :CurrentIndex) '#13#10 +
        '        RETURNING_VALUES :CurrentIndex; '#13#10 +
        '    END '#13#10 +
        '  END ';

        Log('�������� ��������� GD_P_RESTRUCT_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� �������� ��� ������  � LB, RB
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''GD_P_EL_FILE''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := ' CREATE PROCEDURE GD_P_EL_FILE ( '#13#10 +
        '      PARENT INTEGER, '#13#10 +
        '      DELTA INTEGER, '#13#10 +
        '      LB2 INTEGER, '#13#10 +
        '      RB2 INTEGER) '#13#10 +
        '  RETURNS ( '#13#10 +
        '      LEFTBORDER INTEGER) '#13#10 +
        '  AS '#13#10 +
        '    DECLARE VARIABLE R INTEGER; '#13#10 +
        '    DECLARE VARIABLE L INTEGER; '#13#10 +
        '    DECLARE VARIABLE R2 INTEGER; '#13#10 +
        '    DECLARE VARIABLE MKey INTEGER; '#13#10 +
        '    DECLARE VARIABLE MultiDelta INTEGER; '#13#10 +
        '  BEGIN '#13#10 +
        '    /* �������� ������� �������� */ '#13#10 +
        '    SELECT rb, lb '#13#10 +
        '    FROM gd_file '#13#10 +
        '    WHERE id = :Parent '#13#10 +
        '    INTO :R, :L; '#13#10 +
        ' '#13#10 +
        '    /* �������� ������� ������ ������� ����� */ '#13#10 +
        '    SELECT MAX(rb) '#13#10 +
        '    FROM gd_file '#13#10 +
        '    WHERE lb > :L AND lb <= :R '#13#10 +
        '    INTO :R2; '#13#10 +
        ' '#13#10 +
        '    /* ���� ��� ����� ������������� ����� ������� */ '#13#10 +
        '    IF (:R2 IS NULL) THEN '#13#10 +
        '      R2 = :L; '#13#10 +
        '                         '#13#10 +
        '    IF (:R - :R2 < :Delta) THEN    '#13#10 +
        '    BEGIN '#13#10 +
        '      /* ���� ����� ��� ���������� */ '#13#10 +
        '      /* �������� ������������� � 10 ��� */     '#13#10 +
        '      MultiDelta = (:R - :L + 1) * 9; '#13#10 +
        ' '#13#10 +
        '      /* ��������� ������������� �� ��� ����� �������� */ '#13#10 +
        '      IF (:Delta > :MultiDelta) THEN '#13#10 +
        '        MultiDelta = :Delta; '#13#10 +
        ' '#13#10 +
        '      /* �������� ������ ������� ��������� */ '#13#10 +
        '      UPDATE gd_file                         SET rb = rb + :MultiDelta '#13#10 +
        '        WHERE lb <= :L AND rb >= :R AND NOT (lb >= :LB2 AND rb <= :RB2); '#13#10 +
        ' '#13#10 +
        '      /* �������� ��� ������� ������ ������ */ '#13#10 +
        '      FOR '#13#10 +
        '        SELECT id   '#13#10 +
        '        FROM gd_file '#13#10 +
        '        WHERE lb > :R AND NOT (lb >= :LB2 AND rb <= :RB2) '#13#10 +
        '        ORDER BY lb DESC '#13#10 +
        '        INTO :MKey '#13#10 +
        '      DO '#13#10 +
        '        UPDATE gd_file '#13#10 +
        '          SET lb = lb + :MultiDelta, rb = rb + :MultiDelta '#13#10 +
        '          WHERE id = :MKey; '#13#10 +
        '    END '#13#10 +
        ' '#13#10 +
        '    /* ����������� ���������, ������ ��������������� ������� */ '#13#10 +
        '    LeftBorder = :R2 + 1; '#13#10 +
        '  END ';

        Log('�������� ��������� GD_P_EL_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ��������
      ibsql.Close;
      ibsql.ParamCheck := False;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''GD_BI_FILE10''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'CREATE TRIGGER GD_BI_FILE10 FOR GD_FILE ACTIVE '#13#10 +
        '    BEFORE INSERT POSITION 10 '#13#10 +
        '    AS '#13#10 +
        '      DECLARE VARIABLE R INTEGER; '#13#10 +
        '      DECLARE VARIABLE L INTEGER; '#13#10 +
        '      DECLARE VARIABLE R2 INTEGER; '#13#10 +
        '      DECLARE VARIABLE MULTIDELTA INTEGER; '#13#10 +
        '    BEGIN '#13#10 +
        '      IF (NEW.parent IS NULL) THEN '#13#10 +
        '      BEGIN '#13#10 +
        '        /* ���� ���������� ���������� � ������ */ '#13#10 +
        '        /* ������������� ����� ������� ��������� */ '#13#10 +
        '        SELECT MAX(rb) '#13#10 +
        '        FROM gd_file '#13#10 +
        '        INTO NEW.lb; '#13#10 +
        ' '#13#10 +
        '        /* ��������� ��������� �� �������� ���� */ '#13#10 +
        '        IF (NEW.lb IS NULL) THEN '#13#10 +
        '          /* ����� ����, ������ ����, ����� */ '#13#10 +
        '          NEW.lb = 1; '#13#10 +
        '        ELSE '#13#10 +
        '          /* ���� ���� ������ */ '#13#10 +
        '          NEW.lb = NEW.lb + 1; '#13#10 +
        ' '#13#10 +
        '        NEW.rb = NEW.lb; '#13#10 +
        '      END ELSE '#13#10 +
        '      BEGIN '#13#10 +
        '        /* ���� ��������� � ���������� */ '#13#10 +
        '        /* ������ �����������                    */ '#13#10 +
        '        /* �������� ���� ���������, ���� ������  */ '#13#10 +
        ' '#13#10 +
        '        EXECUTE PROCEDURE gd_p_el_file (NEW.parent, 1, -1, -1) '#13#10 +
        '          RETURNING_VALUES NEW.lb; '#13#10 +
        ' '#13#10 +
        '        NEW.rb = NEW.lb; '#13#10 +
        ' '#13#10 +
        '        IF ((NEW.rb IS NULL) OR (NEW.lb IS NULL)) THEN '#13#10 +
        '        BEGIN '#13#10 +
        '          EXCEPTION tree_e_invalid_parent; '#13#10 +
        '        END '#13#10 +
        '      END '#13#10 +
        '    END ';

        Log('�������� �������� GD_BI_FILE10 ��� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      //���������� ��������
      ibsql.Close;
      ibsql.ParamCheck := False;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''GD_BU_FILE10''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := ' CREATE TRIGGER GD_BU_FILE10 FOR GD_FILE ACTIVE '#13#10 +
        '  BEFORE UPDATE POSITION 10 '#13#10 +
        '  AS '#13#10 +
        '    DECLARE VARIABLE OldDelta INTEGER; '#13#10 +
        '    DECLARE VARIABLE L INTEGER; '#13#10 +
        '    DECLARE VARIABLE R INTEGER; '#13#10 +
        '    DECLARE VARIABLE NewL INTEGER; '#13#10 +
        '    DECLARE VARIABLE A INTEGER; '#13#10 +
        '  BEGIN '#13#10 +
        '    /* ��������� ���� ��������� PARENT */ '#13#10 +
        '    IF ((NEW.parent <> OLD.parent) OR '#13#10 +
        '       ((OLD.parent IS NULL) AND NOT (NEW.parent IS NULL)) OR '#13#10 +
        '       ((NEW.parent IS NULL) AND NOT (OLD.parent IS NULL))) THEN '#13#10 +
        '    BEGIN '#13#10 +
        '      /* ������ �������� �� ������������ */ '#13#10 +
        '      IF (EXISTS (SELECT * FROM gd_file '#13#10 +
        '            WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN '#13#10 +
        '        EXCEPTION gd_e_invalidtreefile; '#13#10 +
        '      ELSE '#13#10 +
        '      BEGIN '#13#10 +
        '        IF (NEW.parent IS NULL) THEN '#13#10 +
        '        BEGIN '#13#10 +
        '          /* �������� ������� ������ ������� */ '#13#10 +
        '          SELECT MAX(rb) '#13#10 +
        '          FROM gd_file '#13#10 +
        '          WHERE parent IS NULL   '#13#10 +
        '          INTO :NewL; '#13#10 +
        '          /* �������������� ��� ���������� ���� �� ���� ������� � ���� �������� */ '#13#10 +
        '          /* ������� �� UPDATE, ������� ������� ������ ����������� �� ��������� */ '#13#10 +
        '          NewL = :NewL + 1; '#13#10 +
        '        END ELSE '#13#10 +
        '        BEGIN '#13#10 +
        '          /* �������� �������� ����� ����� ������� */ '#13#10 +
        '          A = OLD.rb - OLD.lb + 1; '#13#10 +
        '          EXECUTE PROCEDURE gd_p_el_file (NEW.parent, A, OLD.lb, OLD.rb) '#13#10 +
        '            RETURNING_VALUES :NewL; '#13#10 +
        '        END '#13#10 +
        ' '#13#10 +
        '        /* ���������� �������� ������. +1 ����������� � ��������� */ '#13#10 +
        '        OldDelta = :NewL - OLD.lb; '#13#10 +
        '        /* �������� ������� �������� ����� */ '#13#10 +
        '        NEW.lb = OLD.lb + :OldDelta; '#13#10 +
        '        NEW.rb = OLD.rb + :OldDelta; '#13#10 +
        '        /* �������� ������� ����� */ '#13#10 +
        '        UPDATE gd_file                         SET lb = lb + :OldDelta, rb = rb + :OldDelta '#13#10 +
        '          WHERE lb > OLD.lb AND rb <= OLD.rb; '#13#10 +
        '      END '#13#10 +
        '    END '#13#10 +
        '  END ';

        Log('�������� �������� GD_BU_FILE10 ��� ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
        ' WHERE rdb$relation_name = ''GD_FILE'' AND rdb$field_name = ''CRC''';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_file ADD CRC DINTEGER';
        Log('���������� ���� CRC � ������� GD_FILE');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM gd_command WHERE id = 740910';
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) ' +
          ' VALUES (740910, 740000, ''�����'', ''Files'', ''TgdcFile'', NULL, 0 );';
        Log('���������� � ������������� ������� �����');
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'grant execute on procedure gd_p_restruct_file to administrator';
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text := 'grant execute on procedure gd_p_el_file to administrator';
      ibsql.ExecQuery;

      ibsql.Close;
      ibsql.SQL.Text := 'grant execute on procedure gd_p_gchc_file to administrator';
      ibsql.ExecQuery;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('������: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;

end;

end.
