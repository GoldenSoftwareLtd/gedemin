unit gedemin_cc_DataModule_unit;

interface

uses
  Windows, Messages, SysUtils, FileCtrl, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, IBCustomDataSet, IBSQL;

const
  CrPar = 'USER ''SYSDBA'''#13#10 +
          'PASSWORD ''masterkey'''#13#10 +
          'DEFAULT CHARACTER SET WIN1251';

  CrTLogDB = 'CREATE TABLE gd_log_db ( '#13#10 +
             '  id INTEGER NOT NULL PRIMARY KEY, '#13#10 +
             '  db VARCHAR(256) NOT NULL);';

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
    '  data BLOB SUB_TYPE 1, '#13#10 +
    '  CONSTRAINT gd_pk_log PRIMARY KEY (id))';

  CrGLog = 'CREATE SEQUENCE gd_g_log;';

  CrTrLog = 'CREATE TRIGGER gd_t_log FOR gd_log '#13#10 +
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

    IBDB.DatabaseName := DBFile;
    IBDB.CreateDatabase;

    IBTr.StartTransaction;
    try
      q.SQL.Text := CrTLogDB;
      q.ExecQuery;

      q.SQL.Text := CrTLog;
      q.ExecQuery;

      q.SQL.Text := CrGLog;
      q.ExecQuery;

      q.SQL.Text := CrTrLog;
      q.ExecQuery;

      IBTr.Commit;
    finally
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
