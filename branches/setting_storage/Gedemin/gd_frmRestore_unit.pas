
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
  Registry, gd_dlgRestoreWarning_unit, gdcLBRBTreeMetaData
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
      '������� ��� �����.',
      '��������',
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
          FNextLine := '� �������� ���������������� ��������� ������.';
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
              FNextLine := '������: ' + E.Message;
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
              FNextLine := '��� ��������������� �� ��� ������.';
              Synchronize(ShowNextLine);
            end;
        finally
          Reg.Free;
        end;
      except
        on E: Exception do
        begin
          FNextLine := '������ ��� ������� ���� ���������������';
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
          FNextLine := Format('���������� ��������� ����� ������������� ���� ������ ��� ��� ��������� ����� ����������', []);
          Synchronize(ShowNextLine);
        end else
        begin
          q.Close;
          q.SQL.Text := 'SET GENERATOR gd_g_dbid TO ' + IntToStr(gdcBaseManager.GenerateNewDBID);
          q.ExecQuery;
          FNextLine := Format('�������� ����� ������������� ���� ������', []);
          Synchronize(ShowNextLine);
        end;
      except
        FNextLine := '������ ��� ���������� ������ �������������� ���� ������';
        Synchronize(ShowNextLine);
      end;
      q.Close;
      ibtr.Commit;

      // �������� ������ ��������� ����
      // ��� ����, ����� ��� ���� ������������
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
              '���������� ��������� ������ ���������������� ���� ������.',
              '��������',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FNextLine := Format('���������� ��������� ������ ���������������� ���� ������', []);
            Synchronize(ShowNextLine);
          end;
        except
          on E: Exception do
          begin
            FSysDBAPassword := '';
            FAskPassword := True;

            MessageBox(Handle,
              PChar('���������� ��������� ������ ���������������� ���� ������.'#13#10 +
              '������: ' + E.Message),
              '��������',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);
            FNextLine := Format('���������� ��������� ������ ���������������� ���� ������', []);
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

      FNextLine := '������ ������������ ������������ ��������';
      Synchronize(ShowNextLine);

      try
        RestrLBRBTree('', ibtr);
      except
        on E: Exception do
        begin
          FNextLine := '������ ��� ������������ ���. ������: ' + E.Message;
          Synchronize(ShowNextLine);
        end;
      end;

      FNextLine := '�������� ������������ ������������ ��������';
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
        FNextLine := '����������������� ���������';
        Synchronize(ShowNextLine);
        RecompileTriggers(ibdb);
        FNextLine := '����������������� ��������';
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
begin
  try
    gd_frmRestore.mProgress.Lines.Insert(0, '�������� ������� �������������� ���� ������: ' +
      FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
  except
    // ��� Windows98 ����������� �� ������ ���� � 64�
  end;
end;

procedure TRestoreThread.ShowNextLine;
begin
  try
    gd_frmRestore.mProgress.Lines.Insert(0, FNextLine);
  except
    // ��� Windows98 ����������� �� ������ ���� � 64�
    gd_frmRestore.mProgress.Lines.Clear;
  end;
end;

procedure TRestoreThread.ShowStartInfo;
begin
  gd_frmRestore.mProgress.Lines.Insert(0, '����� ������� �������������� ���� ������: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
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
  // ������ ��������� SaveDialog �� ������������� ������
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
