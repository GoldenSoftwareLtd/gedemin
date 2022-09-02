// ShlTanya, 26.02.2019

unit gd_frmErrorInScript;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList;

type
  TfrmErrorInScript = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Button1: TButton;
    ActionList1: TActionList;
    actEditFunction: TAction;
    mmErrorMessage: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure actEditFunctionUpdate(Sender: TObject);
    procedure actEditFunctionExecute(Sender: TObject);
  private
    { Private declarations }
  public
    // Устанавливает текст mmErrorMessage и корректирует размеры
    procedure SetErrMessage(const ErrMessage: String);
  end;

var
  frmErrorInScript: TfrmErrorInScript;

const
  mrEditFunction = 1000;

implementation

uses
  gd_security, obj_i_debugger;

{$R *.DFM}

procedure TfrmErrorInScript.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmErrorInScript.SetErrMessage(const ErrMessage: String);
begin
  mmErrorMessage.Lines.Text := ErrMessage;
end;

procedure TfrmErrorInScript.actEditFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(IbLogin) and IBLogin.IsUserAdmin and
    (Debugger <> nil);
end;

procedure TfrmErrorInScript.actEditFunctionExecute(Sender: TObject);
begin
  ModalResult := mrEditFunction;
end;

end.
