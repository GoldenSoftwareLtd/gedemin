unit gd_modify_main_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, ActnList, StdCtrls, ExtCtrls, gdModify;

type
  Tgd_modify_main = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnExecute: TButton;
    OpenDialog1: TOpenDialog;
    ActionList1: TActionList;
    actModify: TAction;
    IBDatabase1: TIBDatabase;
    Panel4: TPanel;
    Panel5: TPanel;
    mmLog: TMemo;
    Panel6: TPanel;
    Button1: TButton;
    edDatabaseName: TEdit;
    Timer1: TTimer;
    // В этом методе вызываются все методы модификации
    procedure actModifyExecute(Sender: TObject);
    procedure actModifyUpdate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    procedure ClearLog;
    procedure MemoLog(const AnLogText: String);
  protected
    FAutoStartFlag: Boolean;

    function ShutDown: Boolean;
    function BringOnLine: Boolean;

  public
    procedure Modify;
  end;

var
  gd_modify_main: Tgd_modify_main;

implementation

uses
  gsDatabaseShutdown, DbLogDlg, Registry;

{$R *.DFM}

{Tgd_modify_main}

// !!! В этом методе вызываются все методы модификации
procedure Tgd_modify_main.actModifyExecute(Sender: TObject);
begin
  Modify;
end;

function Tgd_modify_main.BringOnLine: Boolean;
begin
  with TgsDatabaseShutdown.Create(Self) do
  try
    Database := IBDatabase1;
    ShowUserDisconnectDialog := False;
    Result := BringOnline;
  finally
    Free;
  end;
end;

procedure Tgd_modify_main.ClearLog;
begin
  mmLog.Lines.Clear;
end;

function Tgd_modify_main.ShutDown: Boolean;
begin
  with TgsDatabaseShutdown.Create(Self) do
  try
    Database := IBDatabase1;
    ShowUserDisconnectDialog := False;
    Result := Shutdown;
  finally
    Free;
  end;
end;

procedure Tgd_modify_main.actModifyUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not IBDatabase1.Connected;
end;

procedure Tgd_modify_main.Modify;
begin
  // Все процедуры для модификации должны добавляться в файл mdf_proclist
  // Процедура должна быть следующего типа procedure(IBDB: TIBDatabase; Log: TModifyLog)
  // IBDB - база данных в которой происходит модификация
  // Log - Процедура обратной связи для событий типа procedure(AnLogText: String)
  // Транзакция и все необходимые компоненты должны создаваться внутри процедуры.
  if IBDatabase1.Connected then Exit;
  ClearLog;
  IBDatabase1.DatabaseName := edDatabaseName.Text;

  with TgdModify.Create(nil) do
  try
    IBUser := IBDatabase1.Params.Values['user_name'];
    IBPassword := IBDatabase1.Params.Values['password'];
    Database := IBDatabase1;
    ShutDownNeeded := True;
    OnLog := MemoLog;
    Execute;
  finally
    Free;
  end;
end;

procedure Tgd_modify_main.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edDatabaseName.Text := OpenDialog1.FileName;
end;

procedure Tgd_modify_main.MemoLog(const AnLogText: String);
begin
  mmLog.Lines.Add(TimeToStr(Now) + ': ' + AnLogText);
end;

procedure Tgd_modify_main.FormCreate(Sender: TObject);
var
  I: Integer;
  S: String;
  Reg: TRegistry;
begin
  IBDatabase1.LoginPrompt := True;
  FAutoStartFlag := False;

  try
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey('SOFTWARE\Golden Software\Gedemin\Client\CurrentVersion', False) then
      begin
        if Reg.ValueExists('ServerName') then
        begin
          edDatabaseName.Text := Reg.ReadString('ServerName');
        end;  
      end;
    finally
      Reg.Free;
    end;
  except
  end;

  IBDatabase1.Params.Values['user_name'] := 'SYSDBA';
  IBDatabase1.Params.Values['password'] := 'masterkey';

  if ParamCount > 0 then
    for I := 1 to ParamCount do
    begin
      if CompareText('/SN', ParamStr(I)) = 0 then
      begin
        S := ParamStr(I + 1);
        if (Length(S) > 1) and (S[1] = '"')
          and (S[Length(S)] = '"') then
        begin
          S := Copy(S, 2, Length(S) - 2);
        end;
        edDatabaseName.Text := S;
        FAutoStartFlag := True;
      end;
      if CompareText('/USER', ParamStr(I)) = 0 then
        IBDatabase1.Params.Values['user_name'] := ParamStr(I + 1);
      if CompareText('/PASSWORD', ParamStr(I)) = 0 then
      begin
        IBDatabase1.Params.Values['password'] := ParamStr(I + 1);
        IBDatabase1.LoginPrompt := False;
      end;
    end;
end;

procedure Tgd_modify_main.FormActivate(Sender: TObject);
begin
  if FAutoStartFlag then
    Timer1.Enabled := True;
end;

procedure Tgd_modify_main.Timer1Timer(Sender: TObject);
begin
  if FAutoStartFlag then
  begin
    FAutoStartFlag := False;
    Timer1.Enabled := False;
    Modify;
    Close;
  end;
end;

end.
