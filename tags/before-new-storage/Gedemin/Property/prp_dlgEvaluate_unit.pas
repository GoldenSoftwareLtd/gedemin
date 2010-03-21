unit prp_dlgEvaluate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, obj_i_Debugger;

type
  TdlgEvaluate = class(TForm)
    lbExpression: TLabel;
    cbExpression: TComboBox;
    lbResult: TLabel;
    mResult: TMemo;
    procedure cbExpressionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mResultKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    //��������� ��������� � ������ � ��������� ���������
    procedure AddAndExecute(Expression: string);
    //��������� ���� �� ��������� � ������ � ���� ��� �� ��������� ��� � ������
    procedure AddToExpressionList(Expression: string);
    //��������� ���������
    procedure ExecExpression(Script: string);
  public
    { Public declarations }
    procedure Eval(Expression: string);
  end;


var
  dlgEvaluate: TdlgEvaluate;

implementation
uses
  rp_report_const, gd_i_ScriptFactory, rp_ReportScriptControl;
{$R *.DFM}

procedure TdlgEvaluate.ExecExpression(Script: string);
var
  EvalResult: Variant;
begin
  if not Assigned(Debugger) then
    Exit;

  EvalResult := Debugger.Eval(Script);

  if mResult <> nil then
    mResult.Lines.Text := EvalResult;
end;

procedure TdlgEvaluate.cbExpressionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    AddAndExecute(cbExpression.Text)
  end else
  if Key = VK_ESCAPE then
    ModalResult := mrOk;
end;

procedure TdlgEvaluate.FormShow(Sender: TObject);
begin
  mResult.Lines.Clear;
  AddAndExecute(cbExpression.Text);
  cbExpression.SetFocus;
end;

procedure TdlgEvaluate.AddAndExecute(Expression: string);
begin
  if cbExpression.Text <> '' then
  begin
    AddToExpressionList(Expression);
    ExecExpression(Expression);
    cbExpression.Text := Expression;
  end;
end;

procedure TdlgEvaluate.AddToExpressionList(Expression: string);
var
  I: Integer;
begin
  if Expression <> '' then
  begin
    for I := 0 to cbExpression.Items.Count - 1 do
    begin
      if (Expression = cbExpression.Items[I]) then
      begin
        cbExpression.Items.Delete(I);
        Break;
      end;
    end;
    cbExpression.Items.Insert(0, Expression);
  end;
end;

procedure TdlgEvaluate.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TdlgEvaluate.mResultKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TdlgEvaluate.Eval(Expression: string);
begin
  AddAndExecute(Expression);
end;

end.
