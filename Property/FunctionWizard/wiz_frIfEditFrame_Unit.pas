unit wiz_frIfEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, BtnEdit, StdCtrls, ComCtrls, wiz_FunctionBlock_unit,
  wiz_Strings_unit;

type
  TfrIfEditFrame = class(TfrEditFrame)
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
  frIfEditFrame: TfrIfEditFrame;

implementation
uses wiz_ExpressionEditorForm_unit;
{$R *.DFM}

procedure TfrIfEditFrame.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

function TfrIfEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(beCondition.Text) > '';
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INVALID_EXPRESSION)
    end;
  end;
end;

procedure TfrIfEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TIfBlock do
  begin
    Condition := beCondition.Text;
  end;
end;

procedure TfrIfEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TIfBlock do
  begin
    beCondition.Text := Condition;
  end;
end;

end.
