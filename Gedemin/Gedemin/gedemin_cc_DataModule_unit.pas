unit gedemin_cc_DataModule_unit;

interface

uses
  Windows, Messages, SysUtils, FileCtrl, Classes, Graphics, Controls, Forms, Dialogs,
  SyncObjs, Db, IBDatabase, IBCustomDataSet, IBSQL, gedemin_cc_const,
  IBQuery;

const
  CrPar =
    'USER ''SYSDBA'''#13#10 +
    'PASSWORD ''masterkey'''#13#10 +
    'DEFAULT CHARACTER SET WIN1251';

  ConPar =
    'user_name="SYSDBA" '#13#10 +
    'password="masterkey" '#13#10 +
    'lc_ctype=WIN1251';

  SizeArr = 4;

  QueryArr: array[0..SizeArr] of String = (
    'CREATE SEQUENCE gd_g_log;',

    'CREATE TABLE gd_log_db ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 + // Идентификатор базы данных. Заполняется генератором.                        +
    '  db VARCHAR(256) NOT NULL UNIQUE, '#13#10 + // Полная строка подключения к базе данных.                       +
    '  CONSTRAINT gd_pk_log_db PRIMARY KEY (id))',

    'CREATE TABLE gd_log_sql ( '#13#10 +
    '  crc INTEGER NOT NULL, '#13#10 + // Хэш от текста запроса.
    '  sql BLOB SUB_TYPE 1, '#13#10 + // Текст запроса.
    '  CONSTRAINT gd_pk_log_sql PRIMARY KEY (crc))',

    'CREATE TABLE gd_log ( '#13#10 +
    '  id INTEGER NOT NULL, '#13#10 + // Идентификатор записи. Заполняется генератором.                             +
    '  ts TIMESTAMP NOT NULL, '#13#10 + // Дата и время события.                                                    +
    '  user_name VARCHAR(20), '#13#10 + // Имя пользователя платформы Гедымин.                                      +
    '  os_name VARCHAR(20), '#13#10 + // Имя пользователя операционной системы.                                     +
    '  db INTEGER NOT NULL REFERENCES gd_log_db (id), '#13#10 + // Идентификатор БД. Ссылка на таблицу GD_LOG_DB.   +
    '  host_name VARCHAR(20), '#13#10 + // Имя компьютера.                                                          +
    '  host_ip CHAR(15), '#13#10 + // IP адрес компьютера.                                                          +
    '  obj_class VARCHAR(40), '#13#10 + // Класс объекта.                                                           +
    '  obj_subtype VARCHAR(31), '#13#10 + // Подтип объекта.                                                        +
    '  obj_name VARCHAR(40), '#13#10 + // Имя объекта.
    '  obj_id INTEGER, '#13#10 + // ИД объекта.                                                                     +
    '  op CHAR(8) NOT NULL, '#13#10 + // Идентификатор операции. Латинские символы в верхнем регистре.
    '  sql_crc INTEGER REFERENCES gd_log_sql (crc), '#13#10 + // Хэш запроса. Он же ссылка на таблицу GD_LOG_SQL.
    '  data BLOB SUB_TYPE 1, '#13#10 + // Текст сообщения и/или дополнительные данные. Например, текст SQL запроса. +-
    '  CONSTRAINT gd_pk_log PRIMARY KEY (id))',

    'CREATE TABLE gd_sql_param ( '#13#10 +
    '  logkey INTEGER NOT NULL REFERENCES gd_log (id), '#13#10 + // Ссылка на GD_LOG.
    '  param VARCHAR(31) NOT NULL, '#13#10 + // Имя параметра.
    '  inti INTEGER, '#13#10 +
    '  str VARCHAR(1024), '#13#10 +
    '  dt TIMESTAMP, '#13#10 +
    '  curr NUMERIC(15,4), '#13#10 +
    '  floati DOUBLE PRECISION, '#13#10 +
    '  CONSTRAINT gd_pk_sql_param PRIMARY KEY (logkey, param))'
    );


  SelSQLLogDB =
    'SELECT id, db FROM gd_log_db';
  InsSQLLogDB =
    'INSERT INTO gd_log_db(id, db) ' +
    'VALUES (NEXT VALUE FOR gd_g_log, :db)';

  SelSQLLogSQL =
    'SELECT crc, sql FROM gd_log_sql';
  InsSQLLogSQL =
    'INSERT INTO gd_log_sql(crc, sql) ' +
    'VALUES (:crc, :sql)';

  SelSQLLog =
    'SELECT ts, user_name, os_name, db, host_name, host_ip, obj_class, obj_subtype, obj_name, obj_id, op, sql_crc, data FROM gd_log';
  SelSQLLogID =
    'SELECT id FROM gd_log';
  SelSQLLogFull =
    'SELECT gl.ts, gl.user_name, gl.os_name, gld.db, gl.host_name, gl.host_ip, gl.obj_class, gl.obj_subtype, gl.obj_name, gl.obj_id, gl.op, gls.sql, gl.data ' +
    'FROM gd_log gl ' +
    'INNER JOIN gd_log_db gld ON gl.db = gld.id ' +
    'INNER JOIN gd_log_sql gls ON gl.sql_crc = gls.crc ' +
    'ORDER BY gl.id';
  InsSQLLog =
    'INSERT INTO gd_log(id, ts, user_name, os_name, db, host_name, host_ip, obj_class, obj_subtype, obj_name, obj_id, op, sql_crc, data) ' +
    'VALUES (NEXT VALUE FOR gd_g_log, :ts, :user_name, :os_name, :db, :host_name, :host_ip, :obj_class, :obj_subtype, :obj_name, :obj_id, :op, :sql_crc, :data)';

  SelSQLParamSQL =
    'SELECT logkey, param, inti, str, dt, curr, floati FROM gd_sql_param';
  InsSQLParamSQL =
    'INSERT INTO gd_sql_param(logkey, param, inti, str, dt, curr, floati) ' +
    'VALUES (:logkey, :param, :inti, :str, :dt, :curr, :floati)';

type
  TDM = class(TDataModule)
    IBDB: TIBDatabase;
    IBTr: TIBTransaction;
    IBDS: TIBDataSet;
    q: TIBSQL;
    DSrc: TDataSource;
    IBQ: TIBQuery;
    DS: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure IBQGetText (Sender: TField; var Text: String; DisplayText: Boolean);
  private
    FHWnd: HWND;
    FCriticalSection: TCriticalSection;
    procedure CheckDB;
    procedure InsertDB;
    procedure UpdateDS;
  protected
    procedure WndProcMsg(var Msg: TMessage); virtual;
  end;

var
  DM: TDM;

implementation

{$R *.DFM}

uses
  gedemin_cc_TCPServer_unit;

procedure TDM.CheckDB;
var
  i: Integer;
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
      for i := 0 to SizeArr do
      begin
        q.SQL.Text := QueryArr[i]; // int -> inti, float -> floati, иначе ошибка SQL
        q.ExecQuery;
      end;

      IBTr.Commit;
    except
      IBTr.Rollback;
      raise Exception.Create('Ошибка при создании БД');
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
  FCriticalSection := TCriticalSection.Create;
  FHWnd := AllocateHWnd(WndProcMsg);
  ccTCPServer.InsDBHandle := FHWnd;
  ccTCPServer.UpdDSHandle := FHWnd;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  ccTCPServer.InsDBHandle := 0;
  ccTCPServer.UpdDSHandle := 0;
  DeallocateHWnd(FHWnd);
  FCriticalSection.Free;
end;

procedure TDM.WndProcMsg(var Msg: TMessage);
begin
  case Msg.Msg of
    WM_CC_INSERT_DB:
      InsertDB;
    WM_CC_UPDATE_DS:
      UpdateDS
  else
    Msg.Result := DefWindowProc(FHWnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

procedure TDM.InsertDB;
var
  DBPath, Param: String;
  DBID, CRCID, LogID, LogKey: Integer;
  f: Boolean;
begin
  DBID := 0;
  CRCID := 0;
  LogID := 0;
  LogKey := 0;
  FCriticalSection.Enter;
  try
    while ccTCPServer.FStart <> ccTCPServer.FEnd do
    begin
      try
        try
          if not IBTr.Active then
            IBTr.StartTransaction;
          f := false;
          q.SQL.Text := SelSQLLogDB;
          q.ExecQuery;
          while not q.Eof do
          begin
            DBPath := q.Current.ByName('db').AsString;
            if (DBPath = ccTCPServer.FBuffer[ccTCPServer.FStart].DBFileName) then
            begin
              DBID := q.Current.ByName('id').AsInteger;
              f := true;
              break;
            end
            else
              q.Next;
          end;
          IBTr.Commit;
          if not f then
          begin
            if not IBTr.Active then
              IBTr.StartTransaction;
            q.SQL.Text := InsSQLLogDB;
            q.ParamByName('db').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].DBFileName;
            q.ExecQuery;
            IBTr.Commit;
            if not IBTr.Active then
              IBTr.StartTransaction;
            q.SQL.Text := SelSQLLogDB;
            q.ExecQuery;
            while not q.Eof do
            begin
              DBPath := q.Current.ByName('db').AsString;
              DBID := q.Current.ByName('id').AsInteger;
              q.Next;
            end;
            IBTr.Commit;
          end;
        except
          IBTr.Rollback;
          raise Exception.Create('DB');
        end;

        try
          if not IBTr.Active then
            IBTr.StartTransaction;
          f := false;
          q.SQL.Text := SelSQLLogSQL;
          q.ExecQuery;
          while not q.Eof do
          begin
            CRCID := q.Current.ByName('crc').AsInteger;
            if (CRCID = ccTCPServer.FBuffer[ccTCPServer.FStart].CRC) then
            begin
              f := true;
              break;
            end
            else
              q.Next;
          end;
          IBTr.Commit;
          if not f then
          begin
            if not IBTr.Active then
              IBTr.StartTransaction;
            q.SQL.Text := InsSQLLogSQL;
            q.ParamByName('crc').AsInteger := ccTCPServer.FBuffer[ccTCPServer.FStart].CRC;
            q.ParamByName('sql').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].SQL;
            q.ExecQuery;
            IBTr.Commit;
            if not IBTr.Active then
              IBTr.StartTransaction;
            q.SQL.Text := SelSQLLogSQL;
            q.ExecQuery;
            while not q.Eof do
            begin
              CRCID := q.Current.ByName('crc').AsInteger;
              q.Next;
            end;
            IBTr.Commit;
          end;
        except
          IBTr.Rollback;
          raise Exception.Create('CRC');
        end;

        try
          if IBDS.Active then
            IBDS.Close;
          if not IBTr.Active then
            IBTr.StartTransaction;
          IBDS.SelectSQL.Text := SelSQLLog;
          IBDS.InsertSQL.Text := InsSQLLog;
          IBDS.Open;
          IBDS.Insert;
          IBDS.FieldByName('ts').AsDateTime := ccTCPServer.FBuffer[ccTCPServer.FStart].DTAct;
          IBDS.FieldByName('user_name').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].UserName;
          IBDS.FieldByName('os_name').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].OSName;
          IBDS.FieldByName('db').AsInteger := DBID;
          IBDS.FieldByName('host_name').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].Host;
          IBDS.FieldByName('host_ip').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].IP;
          IBDS.FieldByName('obj_class').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].ObjClass;
          IBDS.FieldByName('obj_subtype').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].ObjSubType;
          IBDS.FieldByName('obj_name').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].ObjName;
          IBDS.FieldByName('obj_id').AsInteger := ccTCPServer.FBuffer[ccTCPServer.FStart].ObjID;
          IBDS.FieldByName('op').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].OP;
          IBDS.FieldByName('sql_crc').AsInteger := CRCID;
          IBDS.FieldByName('data').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].Msg;
          IBDS.Post;
          IBTr.Commit;

          if not IBTr.Active then
            IBTr.StartTransaction;
          q.SQL.Text := SelSQLLogID;
          q.ExecQuery;
          while not q.Eof do
            begin
              LogID := q.Current.ByName('id').AsInteger;
              q.Next;
            end;
            IBTr.Commit;
        except
          IBTr.Rollback;
          raise Exception.Create('LOG');
        end;

        try
          if not IBTr.Active then
            IBTr.StartTransaction;
          f := false;
          q.SQL.Text := SelSQLParamSQL;
          q.ExecQuery;
          while not q.Eof do
          begin
            LogKey := q.Current.ByName('logkey').AsInteger;
            Param := q.Current.ByName('param').AsString;
            if (LogKey = LogID) then
            begin
              if (Param = ccTCPServer.FBuffer[ccTCPServer.FStart].Param) then
              begin
                f := true;
                break;
              end
              else
                q.Next;
            end
            else
              q.Next;
          end;
          IBTr.Commit;
          if not f then
          begin
            if not IBTr.Active then
              IBTr.StartTransaction;
            q.SQL.Text := InsSQLParamSQL;
            q.ParamByName('logkey').AsInteger := LogID;
            q.ParamByName('param').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].Param;
            q.ParamByName('inti').AsInteger := ccTCPServer.FBuffer[ccTCPServer.FStart].Inti;
            q.ParamByName('str').AsString := ccTCPServer.FBuffer[ccTCPServer.FStart].Str;
            q.ParamByName('dt').AsDateTime := ccTCPServer.FBuffer[ccTCPServer.FStart].Dt;
            q.ParamByName('curr').AsCurrency := ccTCPServer.FBuffer[ccTCPServer.FStart].Curr;
            q.ParamByName('floati').AsDouble := ccTCPServer.FBuffer[ccTCPServer.FStart].Floati;
            q.ExecQuery;
            IBTr.Commit;
          end;
        except
          IBTr.Rollback;
          raise Exception.Create('PARAM');
        end;

      finally
        if (ccTCPServer.FStart = MaxBufferSize - 1) then
          ccTCPServer.FStart := 0
        else
          Inc(ccTCPServer.FStart);
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TDM.UpdateDS;
begin
  if IBQ.Active then
    IBQ.Close;
  IBQ.SQL.Text := SelSQLLogFull;
  IBQ.Open;
  IBQ.FieldByName('sql').OnGetText := IBQGetText;
  IBQ.FieldByName('data').OnGetText := IBQGetText;
  IBQ.Last;
end;

procedure TDM.IBQGetText(Sender: TField;
var Text: String; DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

end.
