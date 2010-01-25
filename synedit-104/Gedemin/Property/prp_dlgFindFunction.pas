unit prp_dlgFindFunction;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, prp_MessageConst, XPBevel;

type
  TdlgFindFunction = class(TForm)
    Bevel1: TxpBevel;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Label1: TLabel;
    eId: TEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

implementation

{$R *.DFM}

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}


procedure TdlgFindFunction.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ModalResult = mrCancel;
  if ModalResult = mrOk then
  try
    StrToInt(eId.Text);
    CanClose := True;
  except
    on E: Exception do
      MessageBox(Handle, 'Введите правильное значение ИД', MSG_ERROR, MB_OK);
  end;
end;

end.

