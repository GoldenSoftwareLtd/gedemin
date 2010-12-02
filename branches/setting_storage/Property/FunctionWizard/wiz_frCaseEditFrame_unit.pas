unit wiz_frCaseEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_FREDITFRAME_UNIT, StdCtrls, ComCtrls, BtnEdit, wiz_FunctionBlock_unit,
  wiz_Strings_unit;

type
  TfrCaseEditFrame = class(TfrEditFrame)
    Label3: TLabel;
    beCondition: TBtnEdit;
    procedure beConditionBtnOnClick(Sender: TObject);
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frCaseEditFrame: TfrCaseEditFrame;

implementation

{$R *.DFM}

procedure TfrCaseEditFrame.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

function TfrCaseEditFrame.CheckOk: Boolean;
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

procedure TfrCaseEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TCaseBlock do
  begin
    Condition := beCondition.Text
  end;
end;

procedure TfrCaseEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TCaseBlock do
  begin
    beCondition.Text := Condition; 
  end;
end;

end.
