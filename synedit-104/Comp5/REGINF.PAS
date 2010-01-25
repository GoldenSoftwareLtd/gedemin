{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    Reginf.pas

  Abstract

    Сообщение о незарегистрированости программы.

--}

unit Reginf;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, xYellabl, xBulbBtn, ExtCtrls;

type
  TfrmInformation = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    xylInformation: TLabel;
    xBulbButton1: TxBulbButton;
    procedure xBulbButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  public
    CodeMessage: Integer;
  end;

var
  frmInformation: TfrmInformation;

implementation

{$R *.DFM}

procedure TfrmInformation.xBulbButton1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmInformation.FormActivate(Sender: TObject);
begin
  if CodeMessage = 0 then
    xylInformation.Caption := 'Внимание !!! ' + #13 +
                            'У Вас незарегистрированная '+ #13 +
                            'копия программы.' + #13 +
                            'Скоро программа будет работать,'  + #13 +
                            'как демо-версия.'  + #13 +
                            'Для регистрации позвоните в'  + #13 +
                            'фирму Golden Software по'  + #13 +
                            'тел. (017) 263-89-71'
  else
    xylInformation.Caption := 'Внимание !!! ' + #13 +
                            'У Вас незарегистрированная '+ #13 +
                            'копия программы.' + #13 +
                            'Программа работает,'  + #13 +
                            'как демо-версия.'  + #13 +
                            'Для регистрации позвоните в'  + #13 +
                            'фирму Golden Software по'  + #13 +
                            'тел. (017) 263-89-71'

end;

end.
