
unit gsDatabaseShutdown_dlgShowUsers_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, gsDatabaseShutdown;

type
  TgsDatabaseShutdown_dlgShowUsers = class(TForm)
    mUsers: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    btnOk: TButton;
    edDatabaseName: TEdit;
    btnCancel: TButton;
    btnHelp: TButton;
    Timer: TTimer;

    procedure TimerTimer(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);

  private
    FDatabaseShutdown: TgsDatabaseShutdown;

  public
    property DatabaseShutdown: TgsDatabaseShutdown read FDatabaseShutdown write FDatabaseShutdown;
  end;

var
  gsDatabaseShutdown_dlgShowUsers: TgsDatabaseShutdown_dlgShowUsers;

implementation

{$R *.DFM}

procedure TgsDatabaseShutdown_dlgShowUsers.TimerTimer(Sender: TObject);
begin
  if Assigned(FDatabaseShutdown) then
    if FDatabaseShutdown.UserNames <> mUsers.Lines then
      mUsers.Lines := FDatabaseShutdown.UserNames;
end;

procedure TgsDatabaseShutdown_dlgShowUsers.btnOkClick(Sender: TObject);
begin
  Timer.Enabled := False;
  ModalResult := mrOk;
end;

procedure TgsDatabaseShutdown_dlgShowUsers.btnCancelClick(Sender: TObject);
begin
  Timer.Enabled := False;
  ModalResult := mrCancel;
end;

end.
