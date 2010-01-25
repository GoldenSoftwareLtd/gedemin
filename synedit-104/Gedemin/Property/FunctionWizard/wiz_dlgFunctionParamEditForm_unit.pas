{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgFunctionParamEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls;

type
  TdlgFunctionParamEditForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    Panel2: TPanel;
    Label1: TLabel;
    eName: TEdit;
    Label2: TLabel;
    cbReferenceType: TComboBox;
    Bevel1: TBevel;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgFunctionParamEditForm: TdlgFunctionParamEditForm;

implementation
uses wiz_FunctionBlock_unit;
{$R *.DFM}

procedure TdlgFunctionParamEditForm.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgFunctionParamEditForm.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (Trim(eName.Text) > '') and CheckValidName(Trim(eName.Text));
end;

procedure TdlgFunctionParamEditForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
