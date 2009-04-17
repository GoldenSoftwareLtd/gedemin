unit wiz_dlgEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_FunctionBlock_unit, StdCtrls, ExtCtrls, ActnList;

type
  TdlgEditForm = class(TdlgBaseEditForm)
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    pBottom: TPanel;
    bHelp: TButton;
    pnlRightButtons: TPanel;
    bOk: TButton;
    bCancel: TButton;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
  end;

var
  dlgEditForm: TdlgEditForm;

implementation

{$R *.DFM}

procedure TdlgEditForm.actOkExecute(Sender: TObject);
begin
  if CheckOk then
  begin
    SaveChanges;
    ModalResult := mrOk
  end;
end;

procedure TdlgEditForm.actOkUpdate(Sender: TObject);
begin
//  TAction(Sender).Enabled := CheckOk;
end;

procedure TdlgEditForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgEditForm.actHelpExecute(Sender: TObject);
begin
  if EditFrame <> nil then
    Application.HelpContext(EditFrame.HelpContext);
end;

procedure TdlgEditForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;
end;

end.
