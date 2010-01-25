unit wiz_frVarEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, BtnEdit, ComCtrls, wiz_FunctionBlock_unit,
  wiz_ExpressionEditorForm_unit, wiz_strings_unit;

type
  TfrVarEditFrame = class(TfrEditFrame)
    Label3: TLabel;
    BtnEdit1: TBtnEdit;
    CheckBox1: TCheckBox;
    procedure cbNameClick(Sender: TObject);
    procedure cbNameDropDown(Sender: TObject);
    procedure BtnEdit1BtnOnClick(Sender: TObject);
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
  frVarEditFrame: TfrVarEditFrame;

implementation

{$R *.DFM}

procedure TfrVarEditFrame.cbNameClick(Sender: TObject);
begin
  with cbName.Items.Objects[cbName.ItemIndex] as TVarBlock do
  begin
    mDescription.Lines.Text := Description;
    CheckBox1.Checked := Isobject;
  end;
end;

procedure TfrVarEditFrame.cbNameDropDown(Sender: TObject);
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    FBlock.GetNamesList(S);
    cbName.Items := S;
  finally
    S.Free;
  end;
end;

procedure TfrVarEditFrame.BtnEdit1BtnOnClick(Sender: TObject);
begin
  BtnEdit1.Text := FBlock.EditExpression(BtnEdit1.Text, FBlock)
end;

procedure TfrVarEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TVarBlock do
  begin
    CheckBox1.Checked := Isobject;
    BtnEdit1.Text := Expression;
  end;
end;

function TfrVarEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(BtnEdit1.Text) <> '';
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INPUT_EVAL)
    end;
  end;
end;

procedure TfrVarEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TVarBlock do
  begin
    Expression := BtnEdit1.Text;
    Isobject := CheckBox1.Checked;
  end;
end;

end.
