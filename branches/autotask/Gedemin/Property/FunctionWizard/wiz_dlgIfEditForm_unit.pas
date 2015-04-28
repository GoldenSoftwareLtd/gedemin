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
unit wiz_dlgIfEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_DLGEDITFROM_UNIT, ActnList, StdCtrls, ComCtrls, ExtCtrls, BtnEdit,
  wiz_FunctionBlock_unit;

type
  TdlgIfEditForm = class(TBlockEditForm)
    Label3: TLabel;
    beCondition: TBtnEdit;
    procedure beConditionBtnOnClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  dlgIfEditForm: TdlgIfEditForm;

implementation
uses wiz_ExpressionEditorForm_unit;
{$R *.DFM}

{ TdlgIfEditForm }

function TdlgIfEditForm.CheckOk: Boolean;
begin
  Result := inherited CheckOk and (beCondition.Text > '');
end;

procedure TdlgIfEditForm.SaveChanges;
begin
  inherited;
  with FBlock as TIfBlock do
  begin
    Condition := beCondition.Text;
  end;
end;

procedure TdlgIfEditForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TIfBlock do
  begin
    beCondition.Text := Condition;
  end;
end;

procedure TdlgIfEditForm.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

end.
