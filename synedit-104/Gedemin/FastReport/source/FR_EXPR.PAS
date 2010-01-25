
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Expression builder             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Expr;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FR_Ctrls, StdCtrls;

type
  TfrExprForm = class(TForm)
    GroupBox1: TGroupBox;
    ExprMemo: TMemo;
    GroupBox2: TGroupBox;
    frSpeedButton1: TfrSpeedButton;
    frSpeedButton2: TfrSpeedButton;
    frSpeedButton3: TfrSpeedButton;
    frSpeedButton4: TfrSpeedButton;
    frSpeedButton5: TfrSpeedButton;
    frSpeedButton6: TfrSpeedButton;
    frSpeedButton7: TfrSpeedButton;
    frSpeedButton8: TfrSpeedButton;
    frSpeedButton9: TfrSpeedButton;
    frSpeedButton10: TfrSpeedButton;
    frSpeedButton11: TfrSpeedButton;
    frSpeedButton12: TfrSpeedButton;
    frSpeedButton13: TfrSpeedButton;
    InsDBBtn: TfrSpeedButton;
    InsVarBtn: TfrSpeedButton;
    InsFuncBtn: TfrSpeedButton;
    Button1: TButton;
    Button2: TButton;
    procedure InsFuncBtnClick(Sender: TObject);
    procedure InsDBBtnClick(Sender: TObject);
    procedure InsVarBtnClick(Sender: TObject);
    procedure frSpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExprMemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Funcs, FR_Arg, FR_Class, FR_Const, FR_Var, FR_Flds, FR_Utils;

{$R *.DFM}

function AddBrackets(s: String): String;
var
  i: Integer;
begin
  Result := s;
  s := AnsiUpperCase(s);
  for i := 1 to Length(s) do
    if not (s[i] in ['0'..'9', '_', '.', 'A'..'Z']) then
    begin
      Result := '[' + Result + ']';
      break;
    end;
end;

procedure TfrExprForm.InsFuncBtnClick(Sender: TObject);
var
  sFunc, sSyntax: String;
  frFuncArgForm: TfrFuncArgForm;
begin
  with TfrFuncForm.Create(nil) do
  begin
    if ShowModal = mrOk then
    begin
      sFunc := FuncLB.Items[FuncLB.ItemIndex];
      sSyntax := FuncLabel.Caption;
      if Pos('(', sSyntax) <> 0 then
      begin
        frFuncArgForm := TfrFuncArgForm.Create(nil);
        frFuncArgForm.FuncLabel.Caption := FuncLabel.Caption;
        frFuncArgForm.DescrLabel.Caption := DescrLabel.Caption;
        frFuncArgForm.Func := sFunc;
        if frFuncArgForm.ShowModal = mrOk then
          ExprMemo.SelText := frFuncArgForm.Func;
        frFuncArgForm.Free;
      end
      else
        ExprMemo.SelText := AddBrackets(sFunc);
    end;
    Free;
  end;
end;

procedure TfrExprForm.InsDBBtnClick(Sender: TObject);
begin
  with TfrFieldsForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      if DBField <> '' then
        ExprMemo.SelText := AddBrackets(DBField);
    Free;
  end;
end;

procedure TfrExprForm.InsVarBtnClick(Sender: TObject);
begin
  with TfrVarForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      if SelectedItem <> '' then
        ExprMemo.SelText := AddBrackets(SelectedItem);
    Free;
  end;
end;

procedure TfrExprForm.frSpeedButton1Click(Sender: TObject);
begin
  ExprMemo.SelText := TfrSpeedButton(Sender).Caption + ' ';
end;

procedure TfrExprForm.Localize;
begin
  Caption := frLoadStr(frRes + 700);
  GroupBox1.Caption := frLoadStr(frRes + 701);
  GroupBox2.Caption := frLoadStr(frRes + 702);
  InsDBBtn.Caption := frLoadStr(frRes + 703);
  InsVarBtn.Caption := frLoadStr(frRes + 704);
  InsFuncBtn.Caption := frLoadStr(frRes + 705);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrExprForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrExprForm.ExprMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Escape then
    ModalResult := mrCancel;
end;

end.
