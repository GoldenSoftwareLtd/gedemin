
{******************************************}
{                                          }
{     FastReport v2.4 - XXX components     }
{           Query params editor            }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_XXXQueryParam;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Ctrls, ExtCtrls, DB, UXXXQuery, FR_XXXQuery;

type
  TfrXXXParamsForm = class(TForm)
    GroupBox1: TGroupBox;
    Label2: TLabel;
    ParamsLB: TListBox;
    TypeCB: TComboBox;
    ValueRB: TRadioButton;
    AssignRB: TRadioButton;
    Label1: TLabel;
    ValueE: TfrComboEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ParamsLBClick(Sender: TObject);
    procedure ValueEExit(Sender: TObject);
    procedure TypeCBChange(Sender: TObject);
    procedure ValueRBClick(Sender: TObject);
    procedure AssignRBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VarSBClick(Sender: TObject);
  private
    { Private declarations }
    FBusy: Boolean;
    function CurParam: Integer;
    procedure Localize;
  public
    { Public declarations }
    Query: TXXXQuery;
    QueryComp: TfrXXXQuery;
  end;


implementation

uses FR_Const, FR_Class, FR_DBUtils, FR_Utils;

{$R *.DFM}


function TfrXXXParamsForm.CurParam: Integer;
var
  i: Integer;
  s: String;
begin
  Result := 0;
  s := ParamsLB.Items[ParamsLB.ItemIndex];
  for i := 0 to Query.Params.Count - 1 do
    if Query.Params[i].Name = s then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrXXXParamsForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  with Query.Params do
  for i := 0 to Count - 1 do
    if ParamsLB.Items.IndexOf(Items[i].Name) = -1 then
      ParamsLB.Items.Add(Items[i].Name);
  for i := 0 to 10 do
    TypeCB.Items.Add(frLoadStr(SParamType1 + i));
  ParamsLB.ItemIndex := 0;
  ParamsLBClick(nil);
end;

procedure TfrXXXParamsForm.FormHide(Sender: TObject);
begin
  if ValueE.Enabled then ValueEExit(nil);
end;

procedure TfrXXXParamsForm.ParamsLBClick(Sender: TObject);
var
  i: Integer;
begin
  TypeCB.ItemIndex := -1;
  for i := 0 to 10 do
    if Query.Params[CurParam].DataType = ParamTypes[i] then
    begin
      TypeCB.ItemIndex := i;
      break;
    end;
  FBusy := True;
  ValueE.Text := '';
  ValueE.Enabled := False;
  if QueryComp.ParamKind[CurParam] = pkValue then
  begin
    ValueE.Text := QueryComp.ParamText[CurParam];
    ValueE.Enabled := True;
    ValueRB.Checked := True;
  end
  else
    AssignRB.Checked := True;
  FBusy := False;
end;

procedure TfrXXXParamsForm.ValueEExit(Sender: TObject);
begin
  QueryComp.ParamText[CurParam] := ValueE.Text;
end;

procedure TfrXXXParamsForm.TypeCBChange(Sender: TObject);
begin
  Query.Params[CurParam].DataType := ParamTypes[TypeCB.ItemIndex];
  if ValueE.Enabled then
    ValueEExit(nil);
end;

procedure TfrXXXParamsForm.ValueRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  ValueE.Enabled := True;
  QueryComp.ParamKind[CurParam] := pkValue;
end;

procedure TfrXXXParamsForm.AssignRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  ValueE.Text := '';
  ValueE.Enabled := False;
  QueryComp.ParamKind[CurParam] := pkAssignFromMaster;
end;

procedure TfrXXXParamsForm.Localize;
begin
  GroupBox1.Caption := frLoadStr(frRes + 3110);
  Label2.Caption := frLoadStr(frRes + 3111);
  Label1.Caption := frLoadStr(frRes + 3112);
  ValueRB.Caption := frLoadStr(frRes + 3113);
  AssignRB.Caption := frLoadStr(frRes + 3115);
  ValueE.ButtonHint := frLoadStr(frRes + 575);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrXXXParamsForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrXXXParamsForm.VarSBClick(Sender: TObject);
begin
  ValueE.Text := frDesigner.InsertExpression;
end;

end.

