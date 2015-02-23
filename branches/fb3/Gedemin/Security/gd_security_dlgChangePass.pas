unit gd_security_dlgChangePass;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  TdlgChangePass = class(TForm)
    edPassword: TEdit;
    lblUse: TLabel;
    lblMsg: TLabel;
    edPasswordDouble: TEdit;
    Label2: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ActionList: TActionList;
    actOk: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  private
    procedure SetUserName(const Value: String);

  public
    property UserName: String write SetUserName;
  end;

var
  dlgChangePass: TdlgChangePass;

implementation

{$R *.DFM}

{$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub, gd_localization
  ;
{$ENDIF}

procedure TdlgChangePass.FormCreate(Sender: TObject);
begin
  edPassword.Text := '';
  edPasswordDouble.Text := '';

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TdlgChangePass.SetUserName(const Value: String);
begin
  lblMsg.Caption := StringReplace(lblMsg.Caption, '%user%', Value, []);
end;

procedure TdlgChangePass.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgChangePass.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (edPassword.Text > '')
    and (edPassword.Text = edPasswordDouble.Text);
end;

end.

