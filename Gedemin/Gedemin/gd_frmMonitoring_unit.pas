// ShlTanya, 09.03.2019

unit gd_frmMonitoring_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, StdCtrls, DBCtrls, SuperPageControl, IBDatabase, Db,
  IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls, gd_security;

type
  Tgd_frmMonitoring = class(TCreateableForm)
    pnlMain: TPanel;
    pnlTop: TPanel;
    Splitter1: TSplitter;
    pnlBottom: TPanel;
    pnlMenu: TPanel;
    ibgrAttachments: TgsIBGrid;
    dsAttachments: TDataSource;
    ibdsAttachments: TIBDataSet;
    trAttachments: TIBTransaction;
    cbxHideCurrentConnection: TCheckBox;
    btnRefresh: TButton;
    SuperPageControl1: TSuperPageControl;
    SuperTabSheet1: TSuperTabSheet;
    SuperTabSheet2: TSuperTabSheet;
    Panel1: TPanel;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    btnKillStatement: TButton;
    ibrgTransactions: TgsIBGrid;
    ibgrTransactionsStatements: TgsIBGrid;
    DBMemo1: TDBMemo;
    dsTransactions: TDataSource;
    ibdsTransactions: TIBDataSet;
    ibdsTransactionsStatements: TIBDataSet;
    dsTransactionsStatements: TDataSource;
    ibgrStatements: TgsIBGrid;
    DBMemo2: TDBMemo;
    dsStatements: TDataSource;
    ibdsStatements: TIBDataSet;
    procedure ibdsAttachmentsAfterScroll(DataSet: TDataSet);
    procedure ibdsAttachmentsBeforeClose(DataSet: TDataSet);
    procedure btnRefreshClick(Sender: TObject);
    procedure ibdsTransactionsAfterScroll(DataSet: TDataSet);
    procedure ibdsTransactionsBeforeClose(DataSet: TDataSet);
    procedure btnKillStatementClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure RefreshAttachments;
    procedure RefreshTransactions(const AttachmentId : String);
    procedure RefreshStatements(const AttachmentId : String);
    procedure RefreshTransactionsStatements(const AttachmentId, TransactionId : String);
    procedure KillStatement(const StatementId:string);
  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;
  end;

var
  gd_frmMonitoring: Tgd_frmMonitoring;

implementation

uses
  gdcBaseInterface, Storages, IBSQL;

{$R *.DFM}

{ Tgd_frmMonitoring }

procedure Tgd_frmMonitoring.RefreshAttachments;
begin
  if trAttachments.InTransaction then
    trAttachments.Commit;
  trAttachments.StartTransaction;
  ibdsAttachments.SelectSQL.Text :=
    'SELECT MA.MON$ATTACHMENT_ID, MA.MON$SERVER_PID, MA.MON$STATE, '+#13#10+
    '       (SELECT FIRST 1 T.RDB$TYPE_NAME FROM RDB$TYPES T '+#13#10+
    '        WHERE (T.RDB$FIELD_NAME = ''MON$STATE'') '+#13#10+
    '          AND (T.RDB$TYPE       = MA.MON$STATE)) AS MON$STATE_TYPE_NAME, '+#13#10+
    '       MA.MON$ATTACHMENT_NAME, MA.MON$USER, MA.MON$ROLE, MA.MON$REMOTE_PROTOCOL, '+#13#10+
    '       MA.MON$REMOTE_ADDRESS, MA.MON$REMOTE_PID, MA.MON$CHARACTER_SET_ID, '+#13#10+
    '       (SELECT FIRST 1 CH.RDB$CHARACTER_SET_NAME FROM RDB$CHARACTER_SETS CH '+#13#10+
    '        WHERE (CH.RDB$CHARACTER_SET_ID = MA.MON$CHARACTER_SET_ID)) AS CHARACTER_SET_NAME, '+#13#10+
    '       MA.MON$TIMESTAMP, MA.MON$GARBAGE_COLLECTION, '+#13#10+
    '        (SELECT FIRST 1 u.name FROM gd_user u WHERE u.ibname = MA.mon$user) AS gd_user '+#13#10+
    'FROM MON$ATTACHMENTS MA '+#13#10;
  if cbxHideCurrentConnection.Checked then
    ibdsAttachments.SelectSQL.Text := ibdsAttachments.SelectSQL.Text + 'WHERE (MA.MON$ATTACHMENT_ID <> CURRENT_CONNECTION) ';
  try
    ibdsAttachments.Open;
  except
  end;
end;

procedure Tgd_frmMonitoring.ibdsAttachmentsAfterScroll(DataSet: TDataSet);
begin
  RefreshTransactions(DataSet.FieldByName('MON$ATTACHMENT_ID').AsString);
  RefreshStatements(DataSet.FieldByName('MON$ATTACHMENT_ID').AsString);
end;

procedure Tgd_frmMonitoring.ibdsAttachmentsBeforeClose(DataSet: TDataSet);
begin
  if ibdsTransactions.Active then
    ibdsTransactions.Close;
  if ibdsStatements.Active then
    ibdsStatements.Close;
end;

procedure Tgd_frmMonitoring.RefreshStatements(const AttachmentId: String);
begin
  if ibdsStatements.Active then
    ibdsStatements.Close;
  ibdsStatements.SelectSQL.Text :=
    'SELECT ST.MON$STATEMENT_ID, ST.MON$ATTACHMENT_ID, ST.MON$TRANSACTION_ID, '+#13#10+
    '       ST.MON$STATE, ST.MON$TIMESTAMP, ST.MON$SQL_TEXT, '+#13#10+
    '       (SELECT FIRST 1 T.RDB$TYPE_NAME FROM RDB$TYPES T '+#13#10+
    '        WHERE (T.RDB$FIELD_NAME = ''MON$STATE'') '+#13#10+
    '          AND (T.RDB$TYPE       = ST.MON$STATE)) AS MON$STATE_TYPE_NAME '+#13#10+
    'FROM   MON$STATEMENTS ST '+#13#10+
    'WHERE  (ST.MON$ATTACHMENT_ID = '''+AttachmentId+''') '+#13#10+
    '  AND  (ST.MON$TRANSACTION_ID IS NULL)';
  try
    ibdsStatements.Open;
  except
  end;
end;

procedure Tgd_frmMonitoring.RefreshTransactions(
  const AttachmentId: String);
begin
  if ibdsTransactions.Active
    then ibdsTransactions.Close;
  ibdsTransactions.SelectSQL.Text :=
    'SELECT TR.MON$TRANSACTION_ID, TR.MON$ATTACHMENT_ID, TR.MON$STATE, '+#13#10+
    '       (SELECT FIRST 1 T.RDB$TYPE_NAME FROM RDB$TYPES T '+#13#10+
    '        WHERE (T.RDB$FIELD_NAME = ''MON$STATE'') '+#13#10+
    '          AND (T.RDB$TYPE       = tr.MON$STATE)) AS MON$STATE_TYPE_NAME, '+#13#10+
    '       TR.MON$TIMESTAMP, TR.MON$TOP_TRANSACTION, TR.MON$OLDEST_TRANSACTION, '+#13#10+
    '       TR.MON$OLDEST_ACTIVE, TR.MON$ISOLATION_MODE, '+#13#10+
    '       (SELECT FIRST 1 T.RDB$TYPE_NAME FROM RDB$TYPES T '+#13#10+
    '        WHERE (T.RDB$FIELD_NAME = ''MON$ISOLATION_MODE'') '+#13#10+
    '          AND (T.RDB$TYPE       = tr.MON$ISOLATION_MODE)) AS MON$ISOLATION_MODE_NAME, '+#13#10+
    '       TR.MON$LOCK_TIMEOUT, TR.MON$READ_ONLY, TR.MON$AUTO_COMMIT, TR.MON$AUTO_UNDO '+#13#10+
    'FROM   MON$TRANSACTIONS TR '+#13#10+
    'WHERE  (TR.MON$ATTACHMENT_ID = '''+AttachmentId+''') '+#13#10{+
    '  AND  (TR.MON$TRANSACTION_ID <> CURRENT_TRANSACTION)'};
  try
    ibdsTransactions.Open;
  except
  end;
end;

procedure Tgd_frmMonitoring.btnRefreshClick(Sender: TObject);
begin
  RefreshAttachments;
end;

procedure Tgd_frmMonitoring.ibdsTransactionsAfterScroll(DataSet: TDataSet);
begin
  RefreshTransactionsStatements(DataSet.FieldByName('MON$ATTACHMENT_ID').AsString,
    DataSet.FieldByName('MON$TRANSACTION_ID').AsString);
end;

procedure Tgd_frmMonitoring.ibdsTransactionsBeforeClose(DataSet: TDataSet);
begin
  if ibdsTransactionsStatements.Active then
    ibdsTransactionsStatements.Close;
end;

procedure Tgd_frmMonitoring.RefreshTransactionsStatements(
  const AttachmentId, TransactionId: String);
begin
  if ibdsTransactionsStatements.Active then
    ibdsTransactionsStatements.Close;
  ibdsTransactionsStatements.SelectSQL.Text :=
    'SELECT ST.MON$STATEMENT_ID, ST.MON$ATTACHMENT_ID, ST.MON$TRANSACTION_ID, '+#13#10+
    '       ST.MON$STATE, ST.MON$TIMESTAMP, ST.MON$SQL_TEXT, '+#13#10+
    '       (SELECT FIRST 1 T.RDB$TYPE_NAME FROM RDB$TYPES T '+#13#10+
    '        WHERE (T.RDB$FIELD_NAME = ''MON$STATE'') '+#13#10+
    '          AND (T.RDB$TYPE       = ST.MON$STATE)) AS MON$STATE_TYPE_NAME '+#13#10+
    'FROM   MON$STATEMENTS ST '+#13#10+
    'WHERE  (ST.MON$ATTACHMENT_ID = '''+AttachmentId+''') '+#13#10+
    '  AND  (ST.MON$TRANSACTION_ID = '''+TransactionId+''')';
  try
    ibdsTransactionsStatements.Open;
  except
  end;
end;

procedure Tgd_frmMonitoring.btnKillStatementClick(Sender: TObject);
begin
  KillStatement(ibdsTransactionsStatements.FieldByName('MON$STATEMENT_ID').AsString);
end;

procedure Tgd_frmMonitoring.KillStatement(const StatementId: string);
var
  Tr :TIBTransaction;
  FSQL :TIBSQL;
begin
  Tr := TIBTransaction.Create(nil);
  Tr.DefaultDatabase := IBLogin.DataBase;
  Tr.StartTransaction;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := Tr;
  FSQL.SQL.Text := 'DELETE FROM MON$STATEMENTS MS WHERE (MS.MON$STATEMENT_ID = '+StatementId+')';

  try
    try
      FSQL.ExecQuery;
      FSQL.Close;
      Tr.Commit;
    except
      on E: Exception do
        raise Exception.Create('При удалении запроса возникла ошибка: ' +
          E.Message);
    end;
  finally
    FSQL.Free;
    Tr.Free;
  end;
  RefreshAttachments;
end;

procedure Tgd_frmMonitoring.FormCreate(Sender: TObject);
var
  SL: TStringList;
  MonExists: Boolean;
begin
  SL := TStringList.Create;
  try
    gdcBaseManager.Database.GetTableNames(SL, True);
    MonExists := SL.IndexOf('MON$STATEMENTS') <> -1;
  finally
    SL.Free;
  end;

  if not MonExists then
  begin
    MessageBox(Handle,
      'Данная база данных не является базой данных сервера FireBird 2.1!',
      'Ошибка',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Close;
  end else
  begin
    ShowSpeedButton := True;

    trAttachments.DefaultDatabase := IBLogin.Database;
    trAttachments.StartTransaction;

    RefreshAttachments;
  end;
end;

procedure Tgd_frmMonitoring.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (Action = caHide) then
    Action := caFree;
end;

procedure Tgd_frmMonitoring.LoadSettings;
begin
  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrAttachments, ibgrAttachments.LoadFromStream);
    UserStorage.LoadComponent(ibrgTransactions, ibrgTransactions.LoadFromStream);
    UserStorage.LoadComponent(ibgrTransactionsStatements , ibgrTransactionsStatements.LoadFromStream);
    UserStorage.LoadComponent(ibgrStatements , ibgrStatements.LoadFromStream);
  end;
end;

procedure Tgd_frmMonitoring.SaveSettings;
begin
  inherited;

  if Assigned(UserStorage) then
  begin
    if ibgrAttachments.SettingsModified then
      UserStorage.SaveComponent(ibgrAttachments, ibgrAttachments.SaveToStream);
    if ibrgTransactions.SettingsModified then
      UserStorage.SaveComponent(ibrgTransactions, ibrgTransactions.SaveToStream);
    if ibgrTransactionsStatements.SettingsModified then
      UserStorage.SaveComponent(ibgrTransactionsStatements, ibgrTransactionsStatements.SaveToStream);
    if ibgrStatements.SettingsModified then
      UserStorage.SaveComponent(ibgrStatements, ibgrStatements.SaveToStream);
  end;
end;

initialization
  RegisterClass(Tgd_frmMonitoring);

finalization
  UnRegisterClass(Tgd_frmMonitoring);

end.
