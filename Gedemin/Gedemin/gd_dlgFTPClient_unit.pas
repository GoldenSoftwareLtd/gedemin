unit gd_dlgFTPClient_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  Tgd_dlgFTPClient = class(TForm)
    cbParamsConnect: TGroupBox;
    eServerName: TEdit;
    lServerName: TLabel;
    lPort: TLabel;
    lUserName: TLabel;
    eUserName: TEdit;
    ePassword: TEdit;
    lPassword: TLabel;
    GroupBox1: TGroupBox;
    eLocalPath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    eRemotePath: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    chbxOn: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    sePort: TSpinEdit;
    seTimeOut: TSpinEdit;
    seInterval: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgFTPClient: Tgd_dlgFTPClient;

implementation

{$R *.DFM}

uses
  Storages;

procedure Tgd_dlgFTPClient.Button1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_dlgFTPClient.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (ModalResult = mrOk) then
  begin
    if Assigned(UserStorage) then
      with UserStorage do
      begin
        WriteString('FTPClient', 'ServerName', Trim(eServerName.Text));
        WriteInteger('FTPClient', 'ServerPort', sePort.Value);
        WriteString('FTPClient', 'UserName', eUserName.Text);
        WriteString('FTPClient', 'Password', ePassword.Text);
        WriteInteger('FTPClient', 'TimeOut', seTimeOut.Value);
        WriteString('FTPClient', 'LocalPath', eLocalPath.Text);
        WriteString('FTPClient', 'RemotePath', eRemotePath.Text);
        WriteInteger('FTPClient', 'Interval', seInterval.Value);
        WriteBoolean('FTPClient', 'On', chbxOn.Checked);
      end;
  end;
end;

procedure Tgd_dlgFTPClient.FormCreate(Sender: TObject);
begin
  if Assigned(UserStorage) then
    with UserStorage do
    begin
      eServerName.Text := ReadString('FTPClient', 'ServerName', '');
      sePort.Value := ReadInteger('FTPClient', 'ServerPort', 21);
      eUserName.Text := ReadString('FTPClient', 'UserName', 'anonymous');
      ePassword.Text := ReadString('FTPClient', 'Password', 'guest');
      seTimeOut.Value := ReadInteger('FTPClient', 'TimeOut', 1000);
      eLocalPath.Text := ReadString('FTPClient', 'LocalPath', 'C:\Temp');
      eRemotePath.Text := ReadString('FTPClient', 'RemotePath', '\BACKUP');
      seInterval.Value := ReadInteger('FTPClient', 'Interval', 7000);
      chbxOn.Checked := ReadBoolean('FTPClient', 'On', False);
    end;
end;

procedure Tgd_dlgFTPClient.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
