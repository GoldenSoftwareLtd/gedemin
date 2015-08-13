
unit gd_frmRestore_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GD_FRMBACKUPRESTORE_UNIT, ActnList, Db, DBClient, StdCtrls, Grids,
  DBGrids, IBServices, IBSQL, IBDatabase, gdUpdateIndiceStat;

type
  Tgd_frmRestore = class(Tgd_frmBackupRestore)
    IBRestoreService: TIBRestoreService;
    Label5: TLabel;
    Label6: TLabel;
    edPageBuffers: TEdit;
    chbxOneRelationAtATime: TCheckBox;
    Label7: TLabel;
    chbxGenDBID: TCheckBox;
    chbxOverwrite: TCheckBox;
    edPageSize: TComboBox;
    chbxForcedWrites: TCheckBox;
    IBConfigService: TIBConfigService;
    chbxRestrTree: TCheckBox;
    chbxUseAllSpace: TCheckBox;
    chbxRecompileProcedures: TCheckBox;

    procedure actDoItExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actSelectArchiveExecute(Sender: TObject);

  private
    FRestored: boolean;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    property Restored: Boolean read FRestored;
  end;

  TRestoreThread = class(TThread)
  protected
    FNextLine: String;
    FCancel: Boolean;
    FNotificationContext: Integer;

    procedure ShowStartInfo;
    procedure ShowNextLine;
    procedure ShowFinishInfo;
    procedure ShowWarning;

  public
    Form: Tgd_frmRestore;

    procedure Execute; override;
  end;

var
  gd_frmRestore: Tgd_frmRestore;

implementation

{$R *.DFM}

uses
  IB, IBErrorCodes, gd_security, gd_directories_const, gdcBaseInterface,
  Registry, gd_dlgRestoreWarning_unit, gdNotifierThread_unit, gdcLBRBTreeMetaData
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgd_frmRestore.actDoItExecute(Sender: TObject);
begin
  if cdsBackupFiles.RecordCount = 0 then
  begin
    MessageBox(Self.Handle,
      'Введите имя файла.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    exit;
  end;

  mProgress.Clear;
  InternalActive;

  if IBRestoreService.Active then
  begin
    IBRestoreService.Verbose := chbxVerbose.Checked;
    IBRestoreService.Options := [];
    if chbxOneRelationAtATime.Checked then
      IBRestoreService.Options := IBRestoreService.Options + [OneRelationAtATime];
    if chbxOverwrite.Checked then
      IBRestoreService.Options := IBRestoreService.Options + [Replace]
    else
      IBRestoreService.Options := IBRestoreService.Options + [CreateNewDB];
    if chbxUseAllSpace.Checked then
      IBRestoreService.Options := IBRestoreService.Options + [UseAllSpace];
    IBRestoreService.PageSize := StrToIntDef(edPageSize.Text, 0);
    IBRestoreService.PageBuffers := StrToIntDef(edPageBuffers.Text, 0);

    IBRestoreService.BackupFile.Clear;
    cdsBackupFiles.First;
    while not cdsBackupFiles.EOF do
    begin
      IBRestoreService.BackupFile.Add(cdsBackupFiles.Fields[0].AsString);
      cdsBackupFiles.Next;
    end;

    IBRestoreService.DatabaseName.Clear;
    IBRestoreService.DatabaseName.Add(edDatabase.Text);

    with TRestoreThread.Create(True) do
    begin
      Form := Self;
      FreeOnTerminate := True;
      Priority := tpLower;
      Resume;
    end;
  end;
end;

procedure Tgd_frmRestore.FormCreate(Sender: TObject);
begin
  inherited;
  FIBService := IBRestoreService;
end;

{ TRestoreThread }

procedure TRestoreThread.Execute;
var
  Reg: TRegistry;
begin
  try
    gd_frmRestore.FServiceActive := True;

    Synchronize(ShowStartInfo);
    gd_frmRestore.FRestored := False;

    try
      gd_frmRestore.IBRestoreService.ServiceStart;
      while (not gd_frmRestore.IBRestoreService.Eof)
        and (not Terminated)
        and (gd_frmRestore.IBRestoreService.IsServiceRunning) do
      begin
        FNextLine := gd_frmRestore.IBRestoreService.GetNextLine;
        Synchronize(ShowNextLine);
      end;
    except
      on E: Exception do
      begin
        if E is EAbort then
          raise
        else begin
          FNextLine := 'В процессе разархивирования произошла ошибка.';
          Synchronize(ShowNextLine);
          FNextLine := E.Message;
          Synchronize(ShowNextLine);
          Synchronize(ShowFinishInfo);
          gd_frmRestore.FServiceActive := False;
          Exit;
        end;
      end;
    end;
  finally
    gd_frmRestore.IBRestoreService.Active := False;
  end;

  try
    if Assigned(Form) then
    with Form do
    begin
      IBDB.DatabaseName := GetDatabaseName;
      IBDB.LoginPrompt := False;
      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);

      repeat
        try
          ibdb.Connected := True;
          break;
        except
          on E: EIBError do
          begin
            if E.IBErrorCode = isc_lock_conflict then
            begin
              Synchronize(ShowWarning);
              if FCancel then
                exit;
            end else
            begin
              FNextLine := 'Ошибка: ' + E.Message;
              Synchronize(ShowNextLine);
              exit;
            end;
          end;
        end;
      until False;

      ibtr.StartTransaction;
      try
        q.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database ';
        q.ExecQuery;

        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_CURRENT_USER;
          if Reg.KeyExists(IDCacheRegKey + q.Fields[0].AsString) then
            if not Reg.DeleteKey(IDCacheRegKey + q.Fields[0].AsString) then
            begin
              FNextLine := 'Кэш идентификаторов не был очищен.';
              Synchronize(ShowNextLine);
            end;
        finally
          Reg.Free;
        end;
      except
        on E: Exception do
        begin
          FNextLine := 'Ошибка при очистке кэша идентификаторов';
          Synchronize(ShowNextLine);
          FNextLine := E.Message;
          Synchronize(ShowNextLine);
        end;
      end;
      q.Close;
      ibtr.Commit;

      ibdb.Connected := False;
    end;

    if Assigned(Form) and Form.chbxGenDBID.Checked then
    with Form do
    begin
      IBDB.DatabaseName := GetDatabaseName;
      IBDB.LoginPrompt := False;
      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);

      ibdb.Connected := True;
      ibtr.StartTransaction;
      try
        q.SQL.Text := 'SELECT * FROM rdb$relations WHERE rdb$relation_name LIKE ''RPL$%'' ';
        q.ExecQuery;

        if not q.EOF then
        begin
          q.Close;
          FNextLine := Format('Невозможно присвоить новый идентификатор базы данных так как настроена схема репликации', []);
          Synchronize(ShowNextLine);
        end else
        begin
          q.Close;
          q.SQL.Text := 'SET GENERATOR gd_g_dbid TO ' + IntToStr(gdcBaseManager.GenerateNewDBID);
          q.ExecQuery;
          FNextLine := Format('Присвоен новый идентификатор базы данных', []);
          Synchronize(ShowNextLine);
        end;
      except
        FNextLine := 'Ошибка при присвоении нового идентификатора базы данных';
        Synchronize(ShowNextLine);
      end;
      q.Close;
      ibtr.Commit;

      // увеличим версию атрибутов базы
      // для того, чтобы все кэши перечитались
      ibtr.StartTransaction;
      try
        q.Close;
        q.SQL.Text := 'SELECT GEN_ID(gd_g_attr_version, 1) FROM rdb$database';
        q.ExecQuery;
      except
      end;
      q.Close;
      ibtr.Commit;

      ibdb.Connected := False;
    end;

    if Assigned(Form) then
    with Form do
    try
      IBConfigService.ServerName := edServer.Text;

      if IBConfigService.ServerName > '' then
        IBConfigService.Protocol := TCP
      else
        IBConfigService.Protocol := Local;

      IBConfigService.LoginPrompt := False;
      IBConfigService.Params.Clear;
      IBConfigService.Params.Add('user_name=' + SysDBAUserName);
      IBConfigService.Params.Add('password=' + GetSysDBAPassword);

      IBConfigService.DatabaseName := edDatabase.Text;

      if FSysDBAPassword > '' then
      begin
        try
          IBConfigService.Active := True;
          if not IBConfigService.Active then
          begin
            MessageBox(Handle,
              'Невозможно запустить сервис конфигурирования базы данных.',
              'Внимание',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FNextLine := Format('Невозможно запустить сервис конфигурирования базы данных', []);
            Synchronize(ShowNextLine);
          end;
        except
          on E: Exception do
          begin
            FSysDBAPassword := '';
            FAskPassword := True;

            MessageBox(Handle,
              PChar('Невозможно запустить сервис конфигурирования базы данных.'#13#10 +
              'Ошибка: ' + E.Message),
              'Внимание',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FNextLine := Format('Невозможно запустить сервис конфигурирования базы данных', []);
            Synchronize(ShowNextLine);
          end;
        end;

        if IBConfigService.Active then
        begin
          IBConfigService.SetAsyncMode(not Form.chbxForcedWrites.Checked);
          while IBConfigService.IsServiceRunning do Sleep(50);
        end;
      end;
    finally
      if IBConfigService.Active then
        IBConfigService.Active := False;
    end;

    if Assigned(Form) and Form.chbxRestrTree.Checked then
    with Form do
    begin
      IBDB.DatabaseName := GetDatabaseName;
      IBDB.LoginPrompt := False;
      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);

      ibdb.Connected := True;
      ibtr.StartTransaction;

      FNextLine := 'Начато перестроение интервальных деревьев';
      Synchronize(ShowNextLine);

      try
        RestrLBRBTree('', ibtr);
      except
        on E: Exception do
        begin
          FNextLine := 'Ошибка при перестроении инт. дерева: ' + E.Message;
          Synchronize(ShowNextLine);
        end;
      end;

      FNextLine := 'Окончено перестроение интервальных деревьев';
      Synchronize(ShowNextLine);

      ibtr.Commit;
      ibdb.Connected := False;
    end;

    if Assigned(Form) and Form.chbxRecompileProcedures.Checked then
    with Form do
    begin
      IBDB.DatabaseName := GetDatabaseName;
      IBDB.LoginPrompt := False;
      IBDB.Params.Clear;
      IBDB.Params.Add('user_name=' + SysDBAUserName);
      IBDB.Params.Add('password=' + GetSysDBAPassword);

      ibdb.Connected := True;
      try
        RecompileProcedures(ibdb);
        FNextLine := 'Перекомпилированы процедуры';
        Synchronize(ShowNextLine);
        RecompileTriggers(ibdb);
        FNextLine := 'Перекомпилированы триггеры';
        Synchronize(ShowNextLine);

      except
        on E: Exception do
        begin
          FNextLine := E.Message;
          Synchronize(ShowNextLine);
        end;
      end;

      ibdb.Connected := False;
    end;

  finally
    Synchronize(ShowFinishInfo);
    gd_frmRestore.FRestored := True;
    gd_frmRestore.FServiceActive := False;
    if Assigned(Form) then
      Form.ShutDown;
  end;
end;

procedure TRestoreThread.ShowFinishInfo;
var
  S: String;
begin
  S := 'Закончен процесс восстановления базы данных: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now);
  try
    gd_frmRestore.mProgress.Lines.Insert(0, S);
  except
    // под Windows98 ограничение на размер мемо в 64К
  end;

  if gdNotifierThread <> nil then
  begin
    gdNotifierThread.DeleteContext(FNotificationContext);
    gdNotifierThread.Add(S, 0, 4000);
  end;
end;

procedure TRestoreThread.ShowNextLine;
begin
  try
    gd_frmRestore.mProgress.Lines.Insert(0, FNextLine);
  except
    // под Windows98 ограничение на размер мемо в 64К
    gd_frmRestore.mProgress.Lines.Clear;
  end;
end;

procedure TRestoreThread.ShowStartInfo;
begin
  gd_frmRestore.mProgress.Lines.Insert(0, 'Начат процесс восстановления базы данных: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));

  if gdNotifierThread <> nil then
  begin
    FNotificationContext := gdNotifierThread.GetNextContext;
    gdNotifierThread.Add('Восстановление базы ' + gd_frmRestore.edDatabase.Text + '... <tmr>',
      FNotificationContext);
  end;
end;

constructor Tgd_frmRestore.Create(AnOwner: TComponent);
begin
  inherited;
  if not Assigned(gd_frmRestore) then
    gd_frmRestore := Self;
end;

destructor Tgd_frmRestore.Destroy;
begin
  inherited;
  gd_frmRestore := nil;
end;

class function Tgd_frmRestore.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gd_frmRestore) then
    gd_frmRestore := Tgd_frmRestore.Create(AnOwner);
  Result := gd_frmRestore;
end;

procedure TRestoreThread.ShowWarning;
begin
  FCancel := False;
  with Tgd_dlgRestoreWarning.Create(Form) do
  try
    if ShowModal = mrCancel then
      FCancel := True;
  finally
    Free;
  end;
end;

procedure Tgd_frmRestore.actSelectArchiveExecute(Sender: TObject);
var
  OldDefaultExt, OldFilter, OldTitle: String;
begin
  //inherited;
  // Раньше вызывался SaveDialog из родительского метода
  OldDefaultExt := od.DefaultExt;
  OldFilter := od.Filter;
  OldTitle := od.Title;
  try
    od.DefaultExt := sd.DefaultExt;
    od.Filter := sd.Filter;
    od.Title := sd.Title;

    if cdsBackupFiles.IsEmpty then
      od.FileName := ''
    else
      od.FileName := cdsBackupFiles.Fields[0].AsString;

    if od.Execute then
    begin
      if cdsBackupFiles.IsEmpty then
        cdsBackupFiles.AppendRecord([
          od.FileName,
          ''])
      else
      begin
        cdsBackupFiles.Edit;
        cdsBackupFiles.Fields[0].AsString := od.FileName;
        cdsBackupFiles.Post;
      end;
    end;
  finally
    od.DefaultExt := OldDefaultExt;
    od.Filter := OldFilter;
    od.Title := OldTitle;
  end;
end;

initialization
  RegisterClass(Tgd_frmRestore);
end.
