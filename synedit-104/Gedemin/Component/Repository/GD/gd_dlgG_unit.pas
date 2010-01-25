
unit gd_dlgG_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gd_createable_form;

type
  Tgd_dlgG = class(TCreateableForm)
    ActionList: TActionList;
    btnOk: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  end;

var
  gd_dlgG: Tgd_dlgG;

implementation

{$R *.DFM}

{ Tgd_dlgG }

procedure Tgd_dlgG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrNone then actCancel.Execute;
end;

procedure Tgd_dlgG.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_dlgG.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
