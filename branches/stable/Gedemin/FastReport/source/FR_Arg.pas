
{******************************************}
{                                          }
{             FastReport v2.53             }
{            Function arguments            }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Arg;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FR_Ctrls, ExtCtrls, StdCtrls, Buttons;

type
  TfrFuncArgForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ArgEdit1: TfrComboEdit;
    Bevel2: TBevel;
    ArgEdit2: TfrComboEdit;
    ArgEdit3: TfrComboEdit;
    Bevel1: TBevel;
    DescrLabel: TLabel;
    FuncLabel: TLabel;
    procedure ExprBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    Func: String;
  end;


implementation

uses FR_Expr, FR_Utils, FR_Const;

{$R *.DFM}

procedure TfrFuncArgForm.ExprBtn1Click(Sender: TObject);
begin
  with TfrExprForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      TEdit(Sender).Text := ExprMemo.Text;
    Free;
  end;
end;

procedure TfrFuncArgForm.Localize;
begin
  Caption := frLoadStr(frRes + 730);
  Label1.Caption := frLoadStr(frRes + 731) + ' &1';
  Label2.Caption := frLoadStr(frRes + 731) + ' &2';
  Label3.Caption := frLoadStr(frRes + 731) + ' &3';
  ArgEdit1.ButtonHint := frLoadStr(frRes + 575);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrFuncArgForm.FormShow(Sender: TObject);
var
  i: Integer;
  sSyntax: String;

  procedure EnableControls(ATag: Integer; AEnabled: Boolean);
  begin
    case ATag of
      2: frEnableControls([Label2, ArgEdit2], AEnabled);
      3: frEnableControls([Label3, ArgEdit3], AEnabled);
    end;
  end;

begin
  Localize;
  EnableControls(2, False);
  EnableControls(3, False);
  sSyntax := FuncLabel.Caption;
  i := 2;
  while Pos(',', sSyntax) <> 0 do
  begin
    sSyntax[Pos(',', sSyntax)] := ' ';
    EnableControls(i, True);
    Inc(i);
  end;
end;

procedure TfrFuncArgForm.FormHide(Sender: TObject);
begin
  Func := Func + '(' + ArgEdit1.Text;
  if ArgEdit2.Text <> '' then
    Func := Func + ', ' + ArgEdit2.Text;
  if ArgEdit3.Text <> '' then
    Func := Func + ', ' + ArgEdit3.Text;
  Func := Func + ')';
end;

end.
