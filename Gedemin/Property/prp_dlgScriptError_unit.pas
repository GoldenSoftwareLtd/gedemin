// ShlTanya, 25.02.2019

unit prp_dlgScriptError_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgScriptError = class(TForm)
    btOk: TButton;
    btEdit: TButton;
    Label1: TLabel;
    stError: TStaticText;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgScriptError: TdlgScriptError;

implementation

uses
  gd_Security;

  

{$R *.DFM}

procedure TdlgScriptError.FormCreate(Sender: TObject);
begin
  if not IBLogin.IsUserAdmin then
  begin
    btOk.Left := Trunc((ClientWidth - btOk.ClientWidth)/2);
    btEdit.Visible := False;
  end;
end;

end.
