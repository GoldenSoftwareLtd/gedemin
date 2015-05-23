
unit gd_frmBackup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GD_FRMBACKUPRESTORE_UNIT, ActnList, Db, DBClient, StdCtrls, Grids,
  DBGrids, IBServices, IBSQL, IBDatabase;

type
  Tgd_frmBackup = class(Tgd_frmBackupRestore)
    IBBackupService: TIBBackupService;
    chbxGarbage: TCheckBox;
    chbxCheck: TCheckBox;
    chbxSetToZero: TCheckBox;
    procedure actDoItExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  protected
    function CheckDatabase: Boolean;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

  TBackupThread = class(TThread)
  protected
    FNextLine: String;
    FNotificationContext: Integer;

    procedure ShowStartInfo;
    procedure ShowNextLine;
    procedure ShowFinishInfo;

  public
    procedure Execute; override;
  end;

var
  gd_frmBackup: Tgd_frmBackup;

implementation

{$R *.DFM}

uses
  gd_security, gd_directories_const,
  gdNotifierThread_unit,
  Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgd_frmBackup }


procedure Tgd_frmBackup.actDoItExecute(Sender: TObject);
begin
  mProgress.Clear;

  if Assigned(IBLogin) and Assigned(IBLogin.Database)
    and IBLogin.Database.Connected then
  begin
    GlobalStorage.SaveToDatabase;
    UserStorage.SaveToDatabase;
    CompanyStorage.SaveToDatabase;
  end;  

  if chbxCheck.Checked then
  begin
    if not CheckDatabase then
    begin
      if MessageBox(Handle,
        '���������� ��������� ����������� ������.'#13#10'���������� �������� �����������?',
        '��������',
        MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
      begin
        mProgress.Lines.Insert(0, '�������� ����������� �������� �������������.');
        exit;
      end;
    end;
  end;

  DeleteTemp;

  if chbxSetToZero.Checked then
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
        q.SQL.Text := 'SET GENERATOR gd_g_dbid TO 0';
        q.ExecQuery;
        mProgress.Lines.Insert(0, '������������� ���� ������ ���������� � 0');
      except
        mProgress.Lines.Insert(0, '������ ��� ��������� �������������� ���� ������');
      end;
      ibtr.Commit;
      ibdb.Connected := False;
    except
      FSysDBAPassword := '';
      FAskPassword := True;
      raise;
    end;
  end;

  InternalActive;

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

function Tgd_frmBackup.CheckDatabase: Boolean;
var
  q2: TIBSQL;
  OldCursor: TCursor;
  S: String;
begin
  Result := True;

  try
    mProgress.Lines.Insert(0, '������� ������� ESC.');
    mProgress.Lines.Insert(0, '��� ������������� �������� ��������');
    mProgress.Lines.Insert(0, '');
    mProgress.Lines.Insert(0, '������ �������� ����������� ���� ������.');

    IBDB.DatabaseName := GetDatabaseName;
    IBDB.LoginPrompt := False;
    IBDB.Params.Clear;
    IBDB.Params.Add('user_name=' + SysDBAUserName);
    IBDB.Params.Add('password=' + GetSysDBAPassword);

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

            S := Format('� ������� "%s" ������� "%s" ������������ ������������ NULL ��������.',
              [q.Fields[1].AsTrimString, q.Fields[0].AsTrimString]);
            mProgress.Lines.Insert(0, S);

            if MessageBox(Handle,
              PChar(S + #13#10#13#10'���������� ��������?'),
              '��������� ��������� ���� ������',
              MB_YESNO or MB_ICONEXCLAMATION) = IDNO then
            begin
              break;
            end;
          end;

          mProgress.Lines.Insert(0, Format('��������� ���� "%s" � ������� "%s"',
            [q.Fields[1].AsTrimString, q.Fields[0].AsTrimString]));

          q.Next;
        end;

        if q.EOF then
          mProgress.Lines.Insert(0, '��������� �������� ����������� ���� ������.')
        else
          mProgress.Lines.Insert(0, '�������� ����������� ���� �������� �������������.');
        mProgress.Lines.Insert(0, '');
      except
        mProgress.Lines.Insert(0, '������ ��� �������� ����������� ���� ������.');
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
    FSysDBAPassword := '';
    FAskPassword := True;
    raise;
  end;
end;

constructor Tgd_frmBackup.Create(AnOwner: TComponent);
begin
  inherited;
  if not Assigned(gd_frmBackup) then
    gd_frmBackup := Self;
end;


class function Tgd_frmBackup.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gd_frmBackup) then
    gd_frmBackup := Tgd_frmBackup.Create(AnOwner);
  Result := gd_frmBackup;
end;

destructor Tgd_frmBackup.Destroy;
begin
  inherited;
  gd_frmBackup := nil;
end;

procedure Tgd_frmBackup.FormCreate(Sender: TObject);
var
  S: String;
begin
  inherited;

  // ��������� ��� ��������� ����� �� �����
  // ����� ���� ������
  S := ChangeFileExt(edDatabase.Text, '.bk');
  Insert(FormatDateTime('yyyymmdd', Now), S, Length(S) - 2);
  cdsBackupFiles.AppendRecord([
    S,
    '']);

  FIBService := IBBackupService;
end;

{ TBackupThread }

procedure TBackupThread.Execute;
begin
  with gd_frmBackup do
  try
    FServiceActive := True;

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
          FNextLine := '� �������� ������������� ��������� ������.';
          Synchronize(ShowNextLine);
          FNextLine := E.Message;
          Synchronize(ShowNextLine);
        end;
      end;
    end;

    Synchronize(ShowFinishInfo);
  finally
    FServiceActive := False;
    IBBackupService.Active := False;
  end;

  gd_frmBackup.ShutDown;
end;

procedure TBackupThread.ShowFinishInfo;
var
  S: String;
begin
  S := '�������� ������� ������������� ���� ������: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now);

  try
    gd_frmBackup.mProgress.Lines.Insert(0, S);
  except
  end;

  gdNotifierThread.DeleteContext(FNotificationContext);
  gdNotifierThread.Add(S, 0, 4000);
end;

procedure TBackupThread.ShowNextLine;
begin
  try
    gd_frmBackup.mProgress.Lines.Insert(0, FNextLine);
  except
    // ��� Windows98 ����������� �� ������ ���� � 64�
    gd_frmBackup.mProgress.Lines.Clear;
  end;
end;

procedure TBackupThread.ShowStartInfo;
begin
  gd_frmBackup.mProgress.Lines.Insert(0, '����� ������� ������������� ���� ������: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));

  FNotificationContext := gdNotifierThread.GetNextContext;
  gdNotifierThread.Add('������������� ���� ' + gd_frmBackup.edDatabase.Text + '... <tmr>',
    FNotificationContext);
end;

procedure Tgd_frmBackup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  chbxCheck.Checked := True;
end;

initialization
  RegisterClass(Tgd_frmBackup);
end.
