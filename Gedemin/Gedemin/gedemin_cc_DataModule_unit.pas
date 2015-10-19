unit gedemin_cc_DataModule_unit;

interface

uses
  Windows, Messages, SysUtils, FileCtrl, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, IBCustomDataSet, IBSQL;

const
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
    '  id INTEGER NOT NULL, '#13#10 +
    '  db VARCHAR(256) NOT NULL UNIQUE, '#13#10 +
    '  CONSTRAINT gd_pk_log_db PRIMARY KEY (id))';

  CrTLogSQL =
    'CREATE TABLE gd_log_sql ( '#13#10 +
    '  crc INTEGER NOT NULL, '#13#10 +
    '  sql BLOB SUB_TYPE 1, '#13#10 +
    '  CONSTRAINT gd_pk_log_sql PRIMARY KEY (crc))';

  CrTLog =
    'CREATE TABLE gd_log ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 +
    '  ts TIMESTAMP NOT NULL, '#13#10 +
    '  user_name VARCHAR(20), '#13#10 +
    '  os_name VARCHAR(20), '#13#10 +
    '  db INTEGER NOT NULL REFERENCES gd_log_db (id), '#13#10 +
    '  host_name VARCHAR(20), '#13#10 +
    '  host_ip CHAR(15), '#13#10 +
    '  obj_class VARCHAR(40), '#13#10 +
    '  obj_subtype VARCHAR(31), '#13#10 +
    '  obj_name VARCHAR(40), '#13#10 +
    '  obj_id INTEGER, '#13#10 +
    '  op CHAR(8) NOT NULL, '#13#10 +
    '  sql_crc INTEGER REFERENCES gd_log_sql (crc), '#13#10 +
    '  data BLOB SUB_TYPE 1, '#13#10 +
    '  CONSTRAINT gd_pk_log PRIMARY KEY (id))';

  CrTSQLParam =
    'CREATE TABLE gd_sql_param ( '#13#10 +
    '  logkey INTEGER NOT NULL, '#13#10 +
    '  param VARCHAR(31) NOT NULL, '#13#10 +
    '  inti INTEGER, '#13#10 +
    '  str VARCHAR(1024), '#13#10 +
    '  dt TIMESTAMP, '#13#10 +
    '  curr NUMERIC(15,4), '#13#10 +
    '  floati DOUBLE PRECISION, '#13#10 +
    '  CONSTRAINT gd_pk_sql_param PRIMARY KEY (logkey, param))';

  CrTrLog =
    'CREATE TRIGGER gd_t_log FOR gd_log '#13#10 +
    'ACTIVE BEFORE INSERT POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.id IS NULL) THEN '#13#10 +
    '    NEW.id = GEN_ID(gd_g_log, 1); '#13#10 +
    'END;';

type
  TDM = class(TDataModule)
    IBDB: TIBDatabase;
    IBTr: TIBTransaction;
    IBDS: TIBDataSet;
    q: TIBSQL;
    DSrc: TDataSource;
    procedure DataModuleCreate(Sender: TObject);

  public
    procedure CheckDB;
  end;

var
  DM: TDM;

implementation

{$R *.DFM}

uses
  gedemin_cc_frmMain_unit;

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

      //q.SQL.Text := CrTrLog;
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



end.
