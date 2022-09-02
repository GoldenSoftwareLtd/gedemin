// ShlTanya, 09.03.2019

unit wiz_frSelectEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_FREDITFRAME_UNIT, BtnEdit, StdCtrls, ComCtrls, wiz_FunctionBlock_unit,
  wiz_Strings_unit;

type
  TfrSelectEditFrame = class(TfrEditFrame)
    Label3: TLabel;
    beCondition: TBtnEdit;
    procedure beConditionBtnOnClick(Sender: TObject);
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frSelectEditFrame: TfrSelectEditFrame;

implementation

{$R *.DFM}

procedure TfrSelectEditFrame.beConditionBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

function TfrSelectEditFrame.CheckOk: Boolean;
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

procedure TfrSelectEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TSelectBlock do
  begin
    Condition := beCondition.Text
  end;
end;

procedure TfrSelectEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TSelectBlock do
  begin
    beCondition.Text := Condition
  end;
end;

end.
