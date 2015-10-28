unit gedemin_cc_DataModule_unit;

interface

uses
  Windows, Messages, SysUtils, FileCtrl, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, IBCustomDataSet, IBSQL;

const
  MaxBufferSize = 1024;

  CrGLog =
    'CREATE SEQUENCE gd_g_log;';

  CrPar =   
    'USER ''SYSDBA'''#13#10 +
    'PASSWORD ''masterkey'''#13#10 +
    'DEFAULT CHARACTER SET WIN1251';

  ConPar =
    'user_name="SYSDBA" '#13#10 +
    'password="masterkey" '#13#10 +
    'lc_ctype=WIN1251';


  CrTLogDB =
    'CREATE TABLE gd_log_db ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 + // Идентификатор базы данных. Заполняется генератором.
    '  db VARCHAR(256) NOT NULL UNIQUE, '#13#10 + // Полная строка подключения к базе данных.
    '  CONSTRAINT gd_pk_log_db PRIMARY KEY (id))';

  CrTLogSQL =
    'CREATE TABLE gd_log_sql ( '#13#10 +
    '  crc INTEGER NOT NULL, '#13#10 + // Хэш от текста запроса.
    '  sql BLOB SUB_TYPE 1, '#13#10 + // Текст запроса.
    '  CONSTRAINT gd_pk_log_sql PRIMARY KEY (crc))';

  CrTLog =
    'CREATE TABLE gd_log ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 + // Идентификатор записи. Заполняется генератором.
    '  ts TIMESTAMP NOT NULL, '#13#10 + // Дата и время события.
    '  user_name VARCHAR(20), '#13#10 + // Имя пользователя платформы Гедымин.
    '  os_name VARCHAR(20), '#13#10 + // Имя пользователя операционной системы.
    '  db INTEGER NOT NULL REFERENCES gd_log_db (id), '#13#10 + // Идентификатор БД. Ссылка на таблицу GD_LOG_DB.
    '  host_name VARCHAR(20), '#13#10 + // Имя компьютера.
    '  host_ip CHAR(15), '#13#10 + // IP адрес компьютера.
    '  obj_class VARCHAR(40), '#13#10 + // Класс объекта.
    '  obj_subtype VARCHAR(31), '#13#10 + // Подтип объекта.
    '  obj_name VARCHAR(40), '#13#10 + // Имя объекта.
    '  obj_id INTEGER, '#13#10 + // ИД объекта.
    '  op CHAR(8) NOT NULL, '#13#10 + // Идентификатор операции. Латинские символы в верхнем регистре.
    '  sql_crc INTEGER REFERENCES gd_log_sql (crc), '#13#10 + // Хэш запроса. Он же ссылка на таблицу GD_LOG_SQL.
    '  data BLOB SUB_TYPE 1, '#13#10 + // Текст сообщения и/или дополнительные данные. Например, текст SQL запроса.
    '  CONSTRAINT gd_pk_log PRIMARY KEY (id))';

  CrTSQLParam =
    'CREATE TABLE gd_sql_param ( '#13#10 +
    '  logkey INTEGER NOT NULL, '#13#10 + // Ссылка на GD_LOG.
    '  param VARCHAR(31) NOT NULL, '#13#10 + // Имя параметра.
    '  inti INTEGER, '#13#10 +
    '  str VARCHAR(1024), '#13#10 +
    '  dt TIMESTAMP, '#13#10 +
    '  curr NUMERIC(15,4), '#13#10 +
    '  floati DOUBLE PRECISION, '#13#10 +
    '  CONSTRAINT gd_pk_sql_param PRIMARY KEY (logkey, param))';

  CrTrLogDB =
    'CREATE TRIGGER gd_t_log_db FOR gd_log_db '#13#10 +
    'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_log, 1); '#13#10 +
    'END;';

  CrTrLog =
    'CREATE TRIGGER gd_t_log FOR gd_log '#13#10 +
    'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_log, 1); '#13#10 +
    'END;';

  CrTTest =
    'CREATE TABLE test ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 +
    '  ts TIMESTAMP NOT NULL, '#13#10 +
    '  host_name VARCHAR(20), '#13#10 +
    '  data BLOB SUB_TYPE 1, '#13#10 +
    '  CONSTRAINT pk_test PRIMARY KEY (id))';
  
  CrTrTest =
    'CREATE TRIGGER gd_t_test FOR test '#13#10 +
    'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_log, 1); '#13#10 +
    'END;';

  SelSQLTest =
    'SELECT ts, host_name, data FROM test';
  InsSQLTest =
    'INSERT INTO test(id, ts, host_name, data) ' +
    'VALUES (NEXT VALUE FOR gd_g_log, :ts, :host_name, :data)';

type
  TDM = class(TDataModule)
    IBDB: TIBDatabase;
    IBTr: TIBTransaction;
    IBDS: TIBDataSet;
    q: TIBSQL;
    DSrc: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure InsertDB;
    procedure IBDSGetText (Sender: TField; var Text: String; DisplayText: Boolean);
  public
    procedure CheckDB;
    procedure UpdateGrid;
  end;

var
  DM: TDM;

implementation

{$R *.DFM}

uses
  gedemin_cc_frmMain_unit, gedemin_cc_TCPServer_unit;

procedure TDM.CheckDB;
var
  ExeDir, DBDir, DBFile: String;
begin
  ExeDir := IncludeTrailingBackSlash(ExtractFilePath(Application.ExeName));
  DBDir := ExeDir + 'Database';
  DBFile := DBDir + '\gedemin_log.fdb';

  if not FileExists(DBFile) then
  begin
    if not ForceDirectories(DBDir) then
      raise Exception.Create('Can not create DB directory');

    IBDB.Params.Text := CrPar;

    IBDB.DatabaseName := DBFile;
    IBDB.CreateDatabase;

    if IBDB.Connected then
      IBDB.Close;
    IBDB.Params.Text := ConPar;
    IBDB.Open;
    IBDB.Connected := True;

    if not IBTr.Active then
      IBTr.StartTransaction;

    try
      q.SQL.Text := CrGLog;
      q.ExecQuery;

      q.SQL.Text := CrTLogDB;
      q.ExecQuery;

      q.SQL.Text := CrTLogSQL;
      q.ExecQuery;

      q.SQL.Text := CrTLog;
      q.ExecQuery;

      q.SQL.Text := CrTSQLParam;  // int -> inti, float -> floati, иначе ошибка SQL
      q.ExecQuery;

      //q.SQL.Text := CrTrLogDB;
      //q.ExecQuery;

      //q.SQL.Text := CrTrLog;
      //q.ExecQuery;

      q.SQL.Text := CrTTest;
      q.ExecQuery;

      //q.SQL.Text := CrTrTest;
      //q.ExecQuery;

      IBTr.Commit;
    except
      IBTr.Rollback;
    end;
  end else
  begin
    IBDB.DatabaseName := DBFile;
    IBDB.Connected := True;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  CheckDB;
end;

procedure TDM.InsertDB;
begin
  while ccTCPServer.FStart <> ccTCPServer.FEnd do
  begin
    if IBDS.Active then
      IBDS.Close;

    if not IBTr.Active then
      IBTr.StartTransaction;

    try
      IBDS.SelectSQL.Text := SelSQLTest;
      IBDS.InsertSQL.Text := InsSQLTest;

      IBDS.Open;
      IBDS.Insert;

      IBDS.FieldByName('ts').AsDateTime := ccTCPServer.FBuffer[ccTCPServer.FStart].DT;
      IBDS.FieldByName('host_name').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].ClientName;
      IBDS.FieldByName('data').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].Msg;

      IBDS.Post;

      IBTr.Commit;

      if ccTCPServer.FStart = MaxBufferSize - 1 then
        ccTCPServer.FStart := 0
      else
        Inc(ccTCPServer.FStart);
    except
      IBTr.Rollback;
      raise Exception.Create('Запись не добавлена');
    end;
  end;
end;

procedure TDM.UpdateGrid;
begin
  if IBDS.Active then
    IBDS.Close;
  IBDS.Open;
  {IBDS.FieldByName('data').OnGetText := IBDSGetText;
  IBDS.Last;
  
  frm_gedemin_cc_main.DBGr.Refresh;
  frm_gedemin_cc_main.DBGrWidth();
  frm_gedemin_cc_main.DBGr.SetFocus;}
end;

procedure TDM.IBDSGetText (Sender: TField;
var Text: String; DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

end.
