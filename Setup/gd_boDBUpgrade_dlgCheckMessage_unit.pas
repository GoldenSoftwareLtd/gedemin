unit gd_boDBUpgrade_dlgCheckMessage_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgCheckMessage = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    chbNoMore: TCheckBox;
    Panel1: TPanel;
    lbMessage: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }

  end;
  function ShowCheckMessage(Const AMessage, ACheckStr: String; Var CheckState: Boolean): Integer;

var
  dlgCheckMessage: TdlgCheckMessage;

implementation
{$R *.DFM}

function ShowCheckMessage(Const AMessage, ACheckStr: String; Var CheckState: Boolean): Integer;
begin
  with TdlgCheckMessage.Create(nil) do
  try
    lbMessage.Caption := AMessage;
    if ACheckStr = '' then
      chbNoMore.Caption := 'Не выводить больше сообщение об ошибке'
    else
      chbNoMore.Caption := ACheckStr;
    Result := ShowModal;

    CheckState := not chbNoMore.Checked;
  finally
    Free;
  end;
end;
end.
