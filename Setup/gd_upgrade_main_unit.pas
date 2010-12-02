unit gd_upgrade_main_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, gd_boDBUpgrade, ExtCtrls;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actUpgade: TAction;
    actExit: TAction;
    edSourceArchive: TEdit;
    edTargetDatabase: TEdit;
    Memo: TMemo;
    boUpgrade: TboDBUpgrade;
    edUserName: TEdit;
    edPassword: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edServerName: TEdit;
    Label6: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    chbReplication: TCheckBox;
    edSQLDialect: TEdit;
    Label7: TLabel;
    CheckBox1: TCheckBox;
    MemoErr: TMemo;
    Label8: TLabel;
    procedure actExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actUpgadeExecute(Sender: TObject);
    procedure boUpgradeLogRecord(ASender: TObject; const AString: String);
    procedure FormDestroy(Sender: TObject);

  private
    FComputerName: String;

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

uses
  Registry, gd_directories_const;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
{ TODO 1 -oандрэй -cпамылка : Калі была памылка тады не заўсёды psError }
  if (boUpgrade.ProcessState in [psIdle, psError, psSuccess]) then
    Close
  else
    boUpgrade.StopUpgrade;  
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  ComputerName: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  ComputerNameSize: DWord;
  Reg: TRegistry;
begin

  edServerName.Text := '';
  //
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;
    Reg.OpenKeyReadOnly(ClientRootRegistrySubKey + DBUpgradeRegistrySubKey);
    edSourceArchive.Text := Reg.ReadString(DBUpgradeBackupFileNameValue);
    edTargetDatabase.Text := Reg.ReadString(DBUpgradeTargetDatabaseNameValue);
    edServerName.Text := Reg.ReadString(DBUpgradeServerName);
  finally
    Reg.Free;
  end;
  /////////////////////////////////////////////////////////
  // атрымоўваем імя кампутара
  //

  chbReplication.Checked := boUpgrade.TransferReplication;

  if edServerName.Text = '' then
  begin
    ComputerNameSize := SizeOf(ComputerName);
    if GetComputerName(ComputerName, ComputerNameSize) = BOOL(0) then
    begin
      MessageBox(frmMain.Handle,
        'Ошибка в программе, невозможно получить имя компьютера.',
        'Ошибка', MB_OK or MB_ICONSTOP);
      Close;
    end else
    begin
      FComputerName := ComputerName;
      edServerName.Text := ComputerName; //'IBSERVER';
    end;
  end;

end;

procedure TfrmMain.actUpgadeExecute(Sender: TObject);
begin
  try
    (Sender as TAction).Enabled := False;
    boUpgrade.ServerName := edServerName.Text;
    boUpgrade.UserName := edUserName.Text;
    boUpgrade.Password := edPassword.Text;
    boUpgrade.BackupFile := edSourceArchive.Text;
    boUpgrade.SourceDatabase := edTargetDatabase.Text;
    boUpgrade.TransferReplication := chbReplication.Checked;
    boUpgrade.SQLDialect := StrToIntDef(edSQLDialect.Text, 3);
    boUpgrade.ThisComputerName := FComputerName;
    boUpgrade.ReconnectToDatabase := CheckBox1.Checked;
    boUpgrade.ExecuteUpgrade;
  finally
    (Sender as TAction).Enabled := True;
  end;
end;

procedure TfrmMain.boUpgradeLogRecord(ASender: TObject;
  const AString: String);
begin
  Memo.Lines.Add(AString);
  if Pos('ОШИБКА', AnsiUpperCase(AString)) > 0 then
    MemoErr.Lines.Add(AString);
  Application.ProcessMessages;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  Reg: TRegistry;
begin
  //
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;
    Reg.OpenKey(ClientRootRegistrySubKey + DBUpgradeRegistrySubKey, True);
    Reg.WriteString(DBUpgradeBackupFileNameValue, edSourceArchive.Text);
    Reg.WriteString(DBUpgradeTargetDatabaseNameValue, edTargetDatabase.Text);
    Reg.WriteString(DBUpgradeServerName, edServerName.Text);
  finally
    Reg.Free;
  end;
end;

end.
