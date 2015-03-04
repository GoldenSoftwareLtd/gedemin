unit rpl_frmBackUp_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IBServices, Grids, DBGrids, IBSQL, IBDatabase, DB, ActnList,
  DBClient, StdCtrls, TB2Item, TB2Dock, TB2Toolbar, ExtCtrls, XPEdit,
  XPButton, XPCheckBox;

type
  TfrmBackup = class(TForm)
    dsBackupFiles: TDataSource;
    cdsBackupFiles: TClientDataSet;
    fldFileName: TStringField;
    fldFileSize: TIntegerField;
    ActionList: TActionList;
    actDoIt: TAction;
    actClose: TAction;
    actHelp: TAction;
    actSelectArchive: TAction;
    ibdb: TIBDatabase;
    ibtr: TIBTransaction;
    q: TIBSQL;
    sd: TSaveDialog;
    IBBackupService: TIBBackupService;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    tbiChoosFile: TTBItem;
    tbiDoIt: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    tbiGarbage: TTBItem;
    tbiCheck: TTBItem;
    tbiDeleteTemp: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    tbiVerbose: TTBItem;
    Panel2: TPanel;
    Label2: TLabel;
    Label6: TLabel;
    edDatabase: TXPEdit;
    edServer: TXPEdit;
    Bevel3: TBevel;
    Panel1: TPanel;
    Bevel1: TBevel;
    XPButton1: TXPButton;
    XPButton3: TXPButton;
    Panel3: TPanel;
    Label1: TLabel;
    mProgress: TXPMemo;
    Bevel2: TBevel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label3: TLabel;
    Bevel4: TBevel;
    dbgrBackupFiles: TDBGrid;
    XPButton2: TXPButton;
    XPButton4: TXPButton;
    actSelectDataBase: TAction;
    od: TOpenDialog;
    chbxVerbose: TXPCheckBox;
    chbxCheck: TXPCheckBox;
    chbxGarbage: TXPCheckBox;
    chbxDeleteTemp: TXPCheckBox;
    XPButton5: TXPButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCloseExecute(Sender: TObject);
    procedure actDoItUpdate(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure dbgrBackupFilesExit(Sender: TObject);
    procedure actDoItExecute(Sender: TObject);
    procedure actSelectArchiveExecute(Sender: TObject);
    procedure actSelectArchiveUpdate(Sender: TObject);
    procedure actSelectDataBaseExecute(Sender: TObject);
  private
    procedure DeleteTemp;
    function  CheckDataBase: boolean;
  public
    { Public declarations }
  end;

  TBackupThread = class(TThread)
  protected
    FNextLine: String;

    procedure ShowStartInfo;
    procedure ShowNextLine;
    procedure ShowFinishInfo;

  public
    procedure Execute; override;
  end;

var
  frmBackup: TfrmBackup;

implementation

uses rpl_BaseTypes_unit, rpl_ResourceString_unit, rpl_ReplicationManager_unit,
     Types, rpl_ManagerRegisterDB_unit, main_frmIBReplicator_unit;

{$R *.dfm}

procedure TfrmBackup.FormCreate(Sender: TObject);
var
  S: string;
begin
  edServer.Text := ReplDataBase.ServerName;
  edDatabase.Text := ReplDataBase.FileName;

  S := ChangeFileExt(edDatabase.Text, '.bk');
  Insert(FormatDateTime('yyyymmdd', Now) + '_rpl', S, Length(S) - 2);
  cdsBackupFiles.AppendRecord([S, '']);
  {$IFNDEF GEDEMIN}
    chbxDeleteTemp.Visible:= False;
    chbxDeleteTemp.Checked:= False;
  {$ENDIF}
end;

procedure TfrmBackup.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not IBBackupService.Active;
end;

procedure TfrmBackup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mProgress.Clear;
end;

procedure TfrmBackup.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackup.actCloseUpdate(Sender: TObject);
begin
  actClose.Enabled:= not IBBackupService.Active;
end;

procedure TfrmBackup.actDoItUpdate(Sender: TObject);
begin
  actDoIt.Enabled:= not IBBackupService.Active;
end;

procedure TfrmBackup.dbgrBackupFilesExit(Sender: TObject);
begin
  if cdsBackupFiles.State in dsEditModes then begin
    cdsBackupFiles.Post;
  end;
end;

procedure TfrmBackup.actDoItExecute(Sender: TObject);
begin
  mProgress.Clear;

  if chbxCheck.Checked then begin
    if not CheckDatabase then begin
      if MessageBox(Handle,
          'Обнаружены нарушения целостности данных.'#13#10'Продолжать архивное копирование?',
          'Внимание', MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then begin
        mProgress.Lines.Insert(0, 'Архивное копирование прервано пользователем.');
        Exit;
      end;
    end;
  end;

  DeleteTemp;

  IBBackupService.ServerName := ReplDataBase.ServerName;
  IBBackupService.DataBaseName := ReplDataBase.DatabaseName;

  if Trim(ReplDataBase.Protocol) = 'TCP/IP' then
    IBBackupService.Protocol := TCP
  else if Trim(ReplDataBase.Protocol) = 'SPX' then
    IBBackupService.Protocol := SPX
  else
    IBBackupService.Protocol := Local;

  IBBackupService.LoginPrompt := False;
  IBBackupService.Params.Clear;
  IBBackupService.Params.Add('user_name=' + mainIBReplicator.eUser.Text);
  IBBackupService.Params.Add('password=' + mainIBReplicator.ePassword.Text);

  try
    IBBackupService.Active := True;
    if not IBBackupService.Active then
      MessageBox(Handle,
        'Невозможно запустить сервис архивного копирования данных.',
        'Внимание',
        MB_OK or MB_ICONHAND);
  except
    IBBackupService.Active := False;
    raise;
  end;

  if IBBackupService.Active then
  begin
    IBBackupService.Verbose := chbxVerbose.Checked;
    if chbxGarbage.Checked then
      IBBackupService.Options := []
    else
      IBBackupService.Options := [NoGarbageCollection];
    IBBackupService.DatabaseName := edDatabase.Text;

    IBBackupService.BackupFile.Clear;
    cdsBackupFiles.First;
    while not cdsBackupFiles.EOF do
    begin
      if (cdsBackupFiles.RecordCount = 1) or cdsBackupFiles.Fields[1].IsNull then
        IBBackupService.BackupFile.Add(cdsBackupFiles.Fields[0].AsString)
      else
        IBBackupService.BackupFile.Add(cdsBackupFiles.Fields[0].AsString + '=' + cdsBackupFiles.Fields[1].AsString);
      cdsBackupFiles.Next;
    end;

    with TBackupThread.Create(True) do
    begin
      FreeOnTerminate := True;
      Priority := tpLower;
      Resume;
    end;
  end;
end;

{ TBackupThread }

procedure TBackupThread.Execute;
begin
  with frmBackup do
  try
    Synchronize(ShowStartInfo);

    try
      IBBackupService.ServiceStart;
      while (not IBBackupService.Eof)
        and (not Terminated)
        and (IBBackupService.IsServiceRunning) do
      begin
        FNextLine := IBBackupService.GetNextLine;
        Synchronize(ShowNextLine);
      end;
    except
      on E: Exception do
      begin
        if E is EAbort then
          raise
        else begin
          FNextLine := 'В процессе архивирования произошла ошибка.';
          Synchronize(ShowNextLine);
          FNextLine := E.Message;
          Synchronize(ShowNextLine);
          FNextLine := 'Проверьте, достаточно ли на диске свободного места.';
          Synchronize(ShowNextLine);
        end;
      end;
    end;

    Synchronize(ShowFinishInfo);
  finally
    IBBackupService.Active := False;
  end;
end;

procedure TBackupThread.ShowFinishInfo;
begin
  try
    frmBackup.mProgress.Lines.Insert(0, 'Закончен процесс архивирования базы данных: ' +
      FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
  except
  end;
end;

procedure TBackupThread.ShowNextLine;
begin
  try
    frmBackup.mProgress.Lines.Insert(0, FNextLine);
  except
    // под Windows98 ограничение на размер мемо в 64К
    frmBackup.mProgress.Lines.Clear;
  end;
end;

procedure TBackupThread.ShowStartInfo;
begin
  frmBackup.mProgress.Lines.Insert(0, 'Начат процесс архивирования базы данных: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
end;

procedure TfrmBackup.actSelectArchiveExecute(Sender: TObject);
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

procedure TfrmBackup.actSelectArchiveUpdate(Sender: TObject);
begin
  actSelectArchive.Enabled:= not IBBackupService.Active;
end;

procedure TfrmBackup.DeleteTemp;
begin
  if chbxDeleteTemp.Checked then
  begin
    try
      IBDB.DatabaseName := edServer.Text + ':' + edDatabase.Text;
      IBDB.LoginPrompt := False;
      IBDB.Params.Text:= mainIBReplicator.ConnectParams;
//      IBDB.Params.Assign(ReplDataBase.Params);
{      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);}

      ibdb.Connected := True;
      ibtr.StartTransaction;
      try
        q.SQL.Text := 'DELETE FROM rp_reportresult';
        q.ExecQuery;
        mProgress.Lines.Insert(0,
          Format('Удалены результаты отчетов (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении результатов отчетов');
      end;
      try
        q.SQL.Text := 'DELETE FROM gd_journal';
        q.ExecQuery;
        mProgress.Lines.Insert(0,
          Format('Удалены записи из журнала (записей: %d)', [q.RowsAffected]));
      except
        mProgress.Lines.Insert(0, 'Ошибка при удалении записей из журнала');
      end;
      ibtr.Commit;
      ibdb.Connected := False;
    except
      raise;
    end;
  end;
end;

function TfrmBackup.CheckDataBase: boolean;
var
  q2: TIBSQL;
  OldCursor: TCursor;
  S: String;
begin
  Result := True;
  try
    mProgress.Lines.Insert(0, 'нажмите клавишу ESC.');
    mProgress.Lines.Insert(0, 'При необходимости прервать проверку');
    mProgress.Lines.Insert(0, '');
    mProgress.Lines.Insert(0, 'Начата проверка целостности базы данных.');

    IBDB.DatabaseName := edServer.Text + ':' + edDatabase.Text;
    IBDB.LoginPrompt := False;
    IBDB.Params.Assign(ReplDataBase.Params);

    q2 := TIBSQL.Create(nil);
    q2.Transaction := ibtr;

    ibdb.Connected := True;
    ibtr.StartTransaction;

    OldCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    try
      try
        q.SQL.Text := 'SELECT r.rdb$relation_name rn, r.rdb$field_name rf ' +
          'FROM rdb$relation_fields r JOIN rdb$fields f ON r.rdb$field_source = f.rdb$field_name ' +
          'WHERE ((r.rdb$null_flag = 1) OR (f.rdb$null_flag = 1)) AND (r.rdb$view_context IS NULL) ' +
          '';
        q.ExecQuery;

        while not q.EOF do
        begin
          if GetAsyncKeyState(VK_ESCAPE) shr 1 > 0 then
            break;

          q2.Close;
          q2.SQL.Text := Format('SELECT * FROM %s WHERE %s IS NULL',
            [q.Fields[0].AsTrimString, q.Fields[1].AsTrimString]);
          q2.ExecQuery;

          if not q2.EOF then
          begin
            Result := False;

            S := Format('В колонке "%s" таблицы "%s" присутствуют недопустимые NULL значения.',
              [q.Fields[1].AsTrimString, q.Fields[0].AsTrimString]);
            mProgress.Lines.Insert(0, S);

            if MessageBox(Handle,
              PChar(S + #13#10#13#10'Продолжать проверку?'),
              'Нарушение структуры базы данных',
              MB_YESNO or MB_ICONEXCLAMATION) = IDNO then
            begin
              break;
            end;
          end;

          mProgress.Lines.Insert(0, Format('Проверено поле "%s" в таблице "%s"',
            [q.Fields[1].AsTrimString, q.Fields[0].AsTrimString]));

          q.Next;
        end;

        if q.EOF then
          mProgress.Lines.Insert(0, 'Закончена проверка целостности базы данных.')
        else
          mProgress.Lines.Insert(0, 'Проверка целостности была прервана пользователем.');
        mProgress.Lines.Insert(0, '');
      except
        mProgress.Lines.Insert(0, 'Ошибка при проверки целостности базы данных.');
        raise;
      end;
    finally
      Screen.Cursor := OldCursor;
      q2.Free;
      q.Close;
      ibtr.Commit;
      ibdb.Connected := False;
    end;
  except
    raise;
  end;
end;

procedure TfrmBackup.actSelectDataBaseExecute(Sender: TObject);
begin
  od.FileName := edDatabase.Text;
  if od.Execute then begin
    edDatabase.Text := od.FileName;
  end;
end;

end.
