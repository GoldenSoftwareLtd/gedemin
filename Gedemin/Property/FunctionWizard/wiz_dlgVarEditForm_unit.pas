// ShlTanya, 09.03.2019
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
unit wiz_dlgVarEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_dlgEditFrom_unit, ActnList, StdCtrls, ExtCtrls, BtnEdit,
  wiz_ExpressionEditorForm_unit, wiz_FunctionBlock_unit, ComCtrls;

type
  TdlgVarEditForm = class(TBlockEditForm)
    actEditExpression: TAction;
    Label3: TLabel;
    BtnEdit1: TBtnEdit;
    CheckBox1: TCheckBox;
    procedure actEditExpressionExecute(Sender: TObject);
    procedure cbNameDropDown(Sender: TObject);
    procedure cbNameClick(Sender: TObject);
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
  dlgVarEditForm: TdlgVarEditForm;

implementation
{$R *.DFM}

procedure TdlgVarEditForm.actEditExpressionExecute(Sender: TObject);
begin
  BtnEdit1.Text := FBlock.EditExpression(BtnEdit1.Text, FBlock)
end;

function TdlgVarEditForm.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := Trim(BtnEdit1.Text) <> '';
  end;
end;

procedure TdlgVarEditForm.SaveChanges;
begin
  inherited;
  with FBlock as TVarBlock do
  begin
    Expression := BtnEdit1.Text;
    Isobject := CheckBox1.Checked;
  end;
end;

procedure TdlgVarEditForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TVarBlock do
  begin
    CheckBox1.Checked := Isobject;
    BtnEdit1.Text := Expression;
  end;
end;

procedure TdlgVarEditForm.cbNameDropDown(Sender: TObject);
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

procedure TdlgVarEditForm.cbNameClick(Sender: TObject);
begin
  with cbName.Items.Objects[cbName.ItemIndex] as TVarBlock do
  begin
    mDescription.Lines.Text := Description;
    CheckBox1.Checked := Isobject;
  end;
end;

end.
