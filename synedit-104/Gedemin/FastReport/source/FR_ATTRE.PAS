
{******************************************}
{                                          }
{             FastReport v2.53             }
{               Tag editor                 }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_AttrE;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Class, FR_Ctrls, FR_Const;

type
  TfrAttrEditorForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GB1: TGroupBox;
    Edit1: TfrComboEdit;
    procedure frSpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    procedure ShowEditor(t: TfrView);
  end;


implementation

{$R *.DFM}

uses FR_Expr, FR_Utils;


procedure TfrAttrEditorForm.ShowEditor(t: TfrView);
begin
  Edit1.Text := t.Tag;
  if ShowModal = mrOk then
  begin
    frDesigner.BeforeChange;
    t.Tag := Edit1.Text;
  end;
end;

procedure TfrAttrEditorForm.frSpeedButton1Click(Sender: TObject);
begin
  with TfrExprForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      Edit1.SelText := ExprMemo.Text;
    Free;
  end;
end;

procedure TfrAttrEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 740);
  Edit1.ButtonHint := frLoadStr(frRes + 575);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrAttrEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

