unit rpl_frmRestore_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, XPEdit, TB2Item, TB2Dock, TB2Toolbar, StdCtrls,
  XPButton, ExtCtrls, DB, IBDatabase, IBSQL, ActnList, DBClient,
  XPCheckBox, XPComboBox, IBServices;

type
  TfrmRestore = class(TForm)
    cdsBackupFiles: TClientDataSet;
    fldFileName: TStringField;
    fldFileSize: TIntegerField;
    dsBackupFiles: TDataSource;
    ActionList: TActionList;
    actDoIt: TAction;
    actClose: TAction;
    actHelp: TAction;
    actSelectArchive: TAction;
    q: TIBSQL;
    ibtr: TIBTransaction;
    ibdb: TIBDatabase;
    Panel1: TPanel;
    Bevel1: TBevel;
    XPButton1: TXPButton;
    XPButton3: TXPButton;
    Panel3: TPanel;
    Label1: TLabel;
    Bevel2: TBevel;
    mProgress: TXPMemo;
    pnlOptions: TPanel;
    Label2: TLabel;
    Label6: TLabel;
    Bevel3: TBevel;
    edDatabase: TXPEdit;
    edServer: TXPEdit;
    Panel4: TPanel;
    Label3: TLabel;
    Bevel4: TBevel;
    Panel5: TPanel;
    dbgrBackupFiles: TDBGrid;
    actSelectDataBase: TAction;
    Label5: TLabel;
    edPageSize: TXPComboBox;
    Label4: TLabel;
    Label7: TLabel;
    edPageBuffers: TXPEdit;
    chbxOneRelationAtATime: TXPCheckBox;
    chbxOverwrite: TXPCheckBox;
    XPButton2: TXPButton;
    XPButton4: TXPButton;
    XPButton5: TXPButton;
    sd: TSaveDialog;
    od: TOpenDialog;
    chbxVerbose: TXPCheckBox;
    IBRestoreService: TIBRestoreService;
    chbxRecreateAllUsers: TXPCheckBox;
    procedure actCloseExecute(Sender: TObject);
    procedure actDoItUpdate(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actDoItExecute(Sender: TObject);
    procedure actSelectArchiveExecute(Sender: TObject);
    procedure actSelectDataBaseExecute(Sender: TObject);
  private
  public
  end;

  TRestoreThread = class(TThread)
  protected
    FNextLine: String;

    procedure ShowStartInfo;
    procedure ShowNextLine;
    procedure ShowFinishInfo;

  public
    Form: TfrmRestore;

    procedure Execute; override;
  end;

var
  frmRestore: TfrmRestore;

implementation

uses rpl_BaseTypes_unit, rpl_ResourceString_unit, rpl_ReplicationManager_unit,
     Types, rpl_ManagerRegisterDB_unit, main_frmIBReplicator_unit;

{$R *.dfm}

procedure TfrmRestore.FormCreate(Sender: TObject);
begin
{$IFDEF GEDEMIN}
  pnlOptions.Height:= 139;
{$ELSE}
  pnlOptions.Height:= 122;
{$ENDIF}
end;

procedure TfrmRestore.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmRestore.actDoItUpdate(Sender: TObject);
begin
  actDoIt.Enabled:= not IBRestoreService.Active;
end;

procedure TfrmRestore.actCloseUpdate(Sender: TObject);
begin
  actClose.Enabled:= not IBRestoreService.Active;
end;

procedure TfrmRestore.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not IBRestoreService.Active;
end;

procedure TfrmRestore.actDoItExecute(Sender: TObject);
begin
  if cdsBackupFiles.State = dsInsert then
    cdsBackupFiles.Post;
  if cdsBackupFiles.RecordCount = 0 then begin
      MessageBox(Self.Handle, 'Введите имя файла.', 'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Exit;
  end;

  mProgress.Clear;

  IBRestoreService.ServerName := edServer.Text;

  case mainIBReplicator.cbProtocol.ItemIndex of
    0: IBRestoreService.Protocol:= TCP;
    2: IBRestoreService.Protocol:= SPX;
    else
      IBRestoreService.Protocol:= Local;
  end;

{  if Trim(ReplDataBase.Protocol) = 'TCP/IP' then
    IBRestoreService.Protocol := TCP
  else if Trim(ReplDataBase.Protocol) = 'SPX' then
    IBRestoreService.Protocol := SPX
  else
    IBRestoreService.Protocol := Local;}

  IBRestoreService.LoginPrompt := False;
  IBRestoreService.Params.Clear;
  IBRestoreService.Params.Add('user_name=' + mainIBReplicator.eUser.Text);
  IBRestoreService.Params.Add('password=' + mainIBReplicator.ePassword.Text);

  try
    IBRestoreService.Active := True;
    if not IBRestoreService.Active then
      MessageBox(Handle,
        'Невозможно запустить сервис восстановления данных.',
        'Внимание',
        MB_OK or MB_ICONHAND);
  except
    IBRestoreService.Active := False;
    raise;
  end;

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
    IBRestoreService.PageSize := StrToIntDef(edPageSize.Text, 0);
    IBRestoreService.PageBuffers := StrToIntDef(edPageBuffers.Text, 0);

    IBRestoreService.BackupFile.Clear;
    cdsBackupFiles.First;
    while not cdsBackupFiles.EOF do begin
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

procedure TfrmRestore.actSelectArchiveExecute(Sender: TObject);
begin
  if cdsBackupFiles.IsEmpty then
    od.FileName := ''
  else
    od.FileName := cdsBackupFiles.Fields[0].AsString;

  if od.Execute then begin
    if cdsBackupFiles.IsEmpty then
      cdsBackupFiles.AppendRecord([od.FileName, ''])
    else begin
      cdsBackupFiles.Edit;
      cdsBackupFiles.Fields[0].AsString := od.FileName;
      cdsBackupFiles.Post;
    end;
  end;
end;

procedure TfrmRestore.actSelectDataBaseExecute(Sender: TObject);
begin
  sd.FileName := edDatabase.Text;
  if sd.Execute then begin
    edDatabase.Text := sd.FileName;
  end;
end;

{ TRestoreThread }

procedure TRestoreThread.Execute;
begin
  try
    Synchronize(ShowStartInfo);

    try
      frmRestore.IBRestoreService.ServiceStart;
      while (not frmRestore.IBRestoreService.Eof)
        and (not Terminated)
        and (frmRestore.IBRestoreService.IsServiceRunning) do
      begin
        FNextLine:= frmRestore.IBRestoreService.GetNextLine;
        Synchronize(ShowNextLine);
      end;
    except
      on E: Exception do
      begin
        if E is EAbort then
          raise
        else begin
          FNextLine:= 'Проверьте, достаточно ли на диске свободного места.';
          Synchronize(ShowNextLine);
          FNextLine:= E.Message;
          Synchronize(ShowNextLine);
          FNextLine:= 'В процессе разархивирования произошла ошибка.';
          Synchronize(ShowNextLine);
          FNextLine:= '';
          Synchronize(ShowNextLine);
        end;
      end;
    end;

    Synchronize(ShowFinishInfo);
  finally
    frmRestore.IBRestoreService.Active:= False;
  end;
end;

procedure TRestoreThread.ShowFinishInfo;
begin
  try
    frmRestore.mProgress.Lines.Insert(0, 'Закончен процесс восстановления базы данных: ' +
      FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
  except
    // под Windows98 ограничение на размер мемо в 64К
  end;
end;

procedure TRestoreThread.ShowNextLine;
begin
  try
    frmRestore.mProgress.Lines.Insert(0, FNextLine);
  except
    // под Windows98 ограничение на размер мемо в 64К
    frmRestore.mProgress.Lines.Clear;
  end;
end;

procedure TRestoreThread.ShowStartInfo;
begin
  frmRestore.mProgress.Lines.Insert(0, 'Начат процесс восстановления базы данных: ' +
    FormatDateTime('hh:nn:ss, dd mmmm yyyy', Now));
end;

end.
