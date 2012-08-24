
{******************************************}
{                                          }
{             FastReport v2.53             }
{            Group band editor             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_GrpEd;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Class, FR_Ctrls, FR_Const, ExtCtrls;

type
  TfrGroupEditorForm = class(TForm)
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

uses FR_Utils;

{$R *.DFM}

procedure TfrGroupEditorForm.ShowEditor(t: TfrView);
begin
  Edit1.Text := (t as TfrBandView).GroupCondition;
  if ShowModal = mrOk then
  begin
    frDesigner.BeforeChange;
    (t as TfrBandView).GroupCondition := Edit1.Text;
  end;
end;

procedure TfrGroupEditorForm.frSpeedButton1Click(Sender: TObject);
var
  s: String;
begin
  s := frDesigner.InsertExpression;
  if s <> '' then
    Edit1.Text := s;
end;

procedure TfrGroupEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 490);
  GB1.Caption := frLoadStr(frRes + 491);
  Edit1.ButtonHint := frLoadStr(frRes + 492);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrGroupEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

