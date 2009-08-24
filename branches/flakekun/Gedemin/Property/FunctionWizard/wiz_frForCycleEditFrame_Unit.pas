unit wiz_frForCycleEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, BtnEdit, wiz_FunctionBlock_unit;

type
  TfrForCycleEditFrame = class(TfrEditFrame)
    beCondition: TBtnEdit;
    Label3: TLabel;
    beConditionTo: TBtnEdit;
    Label4: TLabel;
    Label5: TLabel;
    beStep: TBtnEdit;
    procedure beConditionBtnOnClick(Sender: TObject);
  private
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frForCycleEditFrame: TfrForCycleEditFrame;

implementation

{$R *.DFM}

{ TfrForCycleEditFrame }

function TfrForCycleEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(beCondition.Text) > '';
    if not Result then
    begin
      ShowCheckOkMessage('Пожалуйста, заполние поле "От"');
    end;
  end;

  if Result then
  begin
    Result := (Trim(beConditionTo.Text) > '');
    if not Result then
    begin
      ShowCheckOkMessage('Пожалуйста, заполните поле "До"')
    end;
  end;
end;

procedure TfrForCycleEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TForCycleBlock do
  begin
    Condition := beCondition.Text;
    ConditionTo := beConditionTo.Text;
    Step := beStep.Text;
  end;
end;

procedure TfrForCycleEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TForCycleBlock do
  begin
    beCondition.Text := Condition;
    beConditionTo.Text := ConditionTo;
    beStep.Text := Step;
  end;
end;

procedure TfrForCycleEditFrame.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

end.
