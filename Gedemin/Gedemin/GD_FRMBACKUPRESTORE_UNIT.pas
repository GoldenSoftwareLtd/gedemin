// ShlTanya, 09.03.2019

unit gd_frmBackupRestore_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, StdCtrls, Grids, DBGrids, ActnList, IBServices,
  gd_createable_form, IBSQL, IBDatabase;

type
  Tgd_frmBackupRestore = class(TCreateableForm)
    dbgrBackupFiles: TDBGrid;
    Label3: TLabel;
    mProgress: TMemo;
    btnDoIt: TButton;
    dsBackupFiles: TDataSource;
    cdsBackupFiles: TClientDataSet;
    fldFileName: TStringField;
    fldFileSize: TIntegerField;
    ActionList: TActionList;
    actDoIt: TAction;
    Label1: TLabel;
    btnClose: TButton;
    btnHelp: TButton;
    actClose: TAction;
    actHelp: TAction;
    chbxVerbose: TCheckBox;
    lblServer: TLabel;
    edServer: TEdit;
    Label4: TLabel;
    edDatabase: TEdit;
    chbxDeleteTemp: TCheckBox;
    ibdb: TIBDatabase;
    ibtr: TIBTransaction;
    q: TIBSQL;
    btnSelectDatabase: TButton;
    actSelectDatabase: TAction;
    od: TOpenDialog;
    btnSelectArchive: TButton;
    actSelectArchive: TAction;
    sd: TSaveDialog;
    chbxShutDown: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actDoItUpdate(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure actSelectDatabaseUpdate(Sender: TObject);
    procedure actSelectDatabaseExecute(Sender: TObject);
    procedure actSelectArchiveUpdate(Sender: TObject);
    procedure actSelectArchiveExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actHelpExecute(Sender: TObject);
    procedure dbgrBackupFilesExit(Sender: TObject);

  protected
    FIBService: TIBBackupRestoreService;
    FSysDBAPassword: String;
    FAskPassword: Boolean;
    FServiceActive: Boolean;

    function GetSYSDBAPassword: String;
    procedure InternalActive;
    procedure DeleteTemp;
    procedure ShutDown;
    function GetDatabaseName: String;

    property IBService: TIBBackupRestoreService read FIBService;

  public
    destructor Destroy; override;

    property ServiceActive: Boolean read FServiceActive;
  end;

implementation

{$R *.DFM}

uses
  DBLogDlg, gd_security, gd_directories_const, gdcBaseInterface, jclStrings,
  gd_common_functions
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgd_frmBackupRestore.FormCreate(Sender: TObject);
var
  Res: OleVariant;
  Server, FileName: String;
  Port: Integer;
begin
  edServer.Text := IBLogin.ServerName;
  edDatabase.Text := '';

  if IBLogin.LoggedIn then
  begin
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT mon$database_name FROM mon$database',
      Null,
      Res);
    if (not VarIsEmpty(Res)) and (Res[0, 0] > '') then
      edDatabase.Text := Res[0, 0];
  end;

  if edDatabase.Text = '' then
  begin
    ParseDatabaseName(IBLogin.DatabaseName, Server, Port, FileName);
    edDatabase.Text := FileName;
  end;
end;

procedure Tgd_frmBackupRestore.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure Tgd_frmBackupRestore.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FServiceActive;
end;

procedure Tgd_frmBackupRestore.actDoItUpdate(Sender: TObject);
begin
  actDoIt.Enabled :=
    (Trim(edDatabase.Text) > '')
    and (cdsBackupFiles.RecordCount > 0)
    and (Trim(cdsBackupFiles.Fields[0].AsString) > '')
    and ((not IBLogin.LoggedIn) or IBLogin.IsUserAdmin
      or ((IBLogin.InGroup and GD_UG_ARCHIVEOPERATORS) <> 0))
    and (IBService <> nil)
    and (not FServiceActive);
end;

procedure Tgd_frmBackupRestore.actCloseUpdate(Sender: TObject);
begin
  actClose.Enabled := not FServiceActive;
end;

destructor Tgd_frmBackupRestore.Destroy;
begin
  FIBService := nil; // поскольку это сслыка на компонент обнулим ее
  inherited;
end;

function Tgd_frmBackupRestore.GetSYSDBAPassword: String;
var
  UserName: String;
  R: OleVariant;
begin
  if (not edServer.Visible) or (edServer.Text = '') then
    FSysDBAPassword := 'masterkey'
  else
  begin
    if FSysDBAPassword = '' then
    begin
      UserName := SysDBAUserName;

      if (not FAskPassword)
        and Assigned(gdcBaseManager)
        and gdcBaseManager.Database.Connected then
      begin
        if (not edServer.Visible) or
          (edServer.Visible and (StrIPos(edServer.Text + ':', gdcBaseManager.Database.DatabaseName) = 1)) then
        begin
          gdcBaseManager.ExecSingleQueryResult(
            'SELECT ibpassword FROM gd_user WHERE UPPER(ibname)=:U',
            AnsiUpperCase(UserName), R);
          if not VarIsEmpty(R) then
          begin
            FSysDBAPassword := R[0, 0];
          end;
        end;
      end;

      if FSysDBAPassword = '' then
      begin
        if not LoginDialogEx(edServer.Text, UserName, FSysDBAPassword, True) then
          FSysDBAPassword := '';
      end;
    end;
  end;
  Result := FSysDBAPassword;
end;

procedure Tgd_frmBackupRestore.InternalActive;
begin
  IBService.ServerName := edServer.Text;

  if IBService.ServerName > '' then
    IBService.Protocol := TCP
  else
    IBService.Protocol := Local;

  IBService.LoginPrompt := False;
  IBService.Params.Clear;
  IBService.Params.Add('user_name=' + SysDBAUserName);
  IBService.Params.Add('password=' + GetSysDBAPassword);

  if FSysDBAPassword = '' then
    Abort;

  try
    IBService.Active := True;
    if not IBService.Active then
      MessageBox(Handle,
        'Невозможно запустить сервис архивного копирования/восстановления данных.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
  except
    FSysDBAPassword := '';
    FAskPassword := True;
    IBService.Active := False;
    raise;
  end;
end;

procedure Tgd_frmBackupRestore.DeleteTemp;
begin
  if chbxDeleteTemp.Checked then
  begin
    try
      IBDB.DatabaseName := GetDatabaseName;
      IBDB.LoginPrompt := False;
      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);

      ibdb.Connected := True;
      ibtr.StartTransaction;
      try
        q.SQL.Text := 'DELETE FROM rp_reportresult';
        q.ExecQuery;
        if q.RowsAffected > 0 then
          mProgress.Lines.Insert(0,
            Format('Удалены результаты отчетов (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении результатов отчетов');
      end;
      try
        q.SQL.Text := 'DELETE FROM gd_journal';
        q.ExecQuery;
        if q.RowsAffected > 0 then
          mProgress.Lines.Insert(0,
            Format('Удалены записи из журнала (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении записей из журнала');
      end;
      try
        q.SQL.Text := 'DELETE FROM gd_sql_statement';
        q.ExecQuery;
        if q.RowsAffected > 0 then
          mProgress.Lines.Insert(0,
            Format('Удалены записи из старого журнала SQL (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении записей из старого журнала SQL');
      end;
      try
        q.SQL.Text := 'DELETE FROM gd_sql_history WHERE bookmark = ''M'' ';
        q.ExecQuery;
        if q.RowsAffected > 0 then
          mProgress.Lines.Insert(0,
            Format('Удалены записи из журнала SQL (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении записей из журнала SQL');
      end;
      ibtr.Commit;
      ibdb.Connected := False;
    except
      FSysDBAPassword := '';
      FAskPassword := True;
      raise;
    end;
  end;
end;

procedure Tgd_frmBackupRestore.actSelectDatabaseUpdate(Sender: TObject);
begin
  actSelectDatabase.Enabled := not FServiceActive;
end;

procedure Tgd_frmBackupRestore.actSelectDatabaseExecute(Sender: TObject);
begin
  od.FileName := edDatabase.Text;
  if od.Execute then
  begin
    edDatabase.Text := od.FileName;
  end;
end;

procedure Tgd_frmBackupRestore.actSelectArchiveUpdate(Sender: TObject);
begin
  actSelectArchive.Enabled := not FServiceActive;
end;

procedure Tgd_frmBackupRestore.actSelectArchiveExecute(Sender: TObject);
begin
  if cdsBackupFiles.IsEmpty then
    sd.FileName := ''
  else
    sd.FileName := cdsBackupFiles.Fields[0].AsString;

  if sd.Execute then
  begin
    if cdsBackupFiles.IsEmpty then
      cdsBackupFiles.AppendRecord([
        sd.FileName,
        ''])
    else
    begin
      cdsBackupFiles.Edit;
      cdsBackupFiles.Fields[0].AsString := sd.FileName;
      cdsBackupFiles.Post;
    end;
  end;
end;

procedure Tgd_frmBackupRestore.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FSysDBAPassword := '';
  mProgress.Clear;
  //Action := caFree;
end;

procedure Tgd_frmBackupRestore.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure Tgd_frmBackupRestore.dbgrBackupFilesExit(Sender: TObject);
begin
  if cdsBackupFiles.State in dsEditModes then
  begin
    cdsBackupFiles.Post;
  end;
end;

procedure Tgd_frmBackupRestore.ShutDown;
var
  rl: Cardinal;
  hToken: Cardinal;
  tkp: TOKEN_PRIVILEGES;
begin
  if chbxShutDown.Checked then
  begin
    if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    begin
      if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].Luid) then
      begin
        tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        tkp.PrivilegeCount := 1;
        AdjustTokenPrivileges(hToken, False, tkp, 0, nil, rl);
      end;
    end;

    InitiateSystemShutdown(nil, nil, 0, False, False);
  end;
end;

function Tgd_frmBackupRestore.GetDatabaseName: String;
begin
  Result := Trim(edDatabase.Text);
  if Trim(edServer.Text) > '' then
    Result := Trim(edServer.Text) + ':' + Result;
end;

end.
