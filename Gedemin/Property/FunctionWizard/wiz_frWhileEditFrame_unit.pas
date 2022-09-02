// ShlTanya, 09.03.2019

unit wiz_frWhileEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, BtnEdit, StdCtrls, ComCtrls, wiz_FunctionBlock_unit;

type
  TfrWhileEditFrame = class(TfrEditFrame)
    beCondition: TBtnEdit;
    Label3: TLabel;
    procedure beConditionBtnOnClick(Sender: TObject);
  protected  
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frWhileEditFrame: TfrWhileEditFrame;

implementation

{$R *.DFM}

{ TfrWhileEditFrame }

function TfrWhileEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(beCondition.Text) > '';
    if not Result then
    begin
      ShowCheckOkMessage('Пожалуйста, укажите условие выполнения цикла.');
    end;
  end;
end;

procedure TfrWhileEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TWhileCycleBlock do
  begin
    Condition := beCondition.Text;
  end;
end;

procedure TfrWhileEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TWhileCycleBlock do
  begin
    beCondition.Text := Condition;
  end;
end;

procedure TfrWhileEditFrame.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

end.
