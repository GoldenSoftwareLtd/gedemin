
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{            Params editor                 }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_parm;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, FRD_Wrap, FR_Const, FR_Ctrls, ExtCtrls
  {$IFDEF Delphi2} , DBTables {$ENDIF}
  {$IFDEF Delphi3} , DBTables {$ENDIF};

type
  TfrParamsForm = class(TForm)
    GroupBox1: TGroupBox;
    Label2: TLabel;
    ParamsLB: TListBox;
    TypeCB: TComboBox;
    ValueE: TEdit;
    ValueRB: TRadioButton;
    AskRB: TRadioButton;
    AssignRB: TRadioButton;
    Button1: TButton;
    Label1: TLabel;
    VariableRB: TRadioButton;
    VariableE: TfrComboEdit;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ParamsLBClick(Sender: TObject);
    procedure ValueEExit(Sender: TObject);
    procedure TypeCBChange(Sender: TObject);
    procedure ValueRBClick(Sender: TObject);
    procedure AskRBClick(Sender: TObject);
    procedure AssignRBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VariableRBClick(Sender: TObject);
    procedure VariableEExit(Sender: TObject);
    procedure VarSBClick(Sender: TObject);
  private
    { Private declarations }
    FBusy: Boolean;
    function CurParam: Integer;
  public
    { Public declarations }
    Query: TfrQuery;
  end;

implementation

uses FRD_Mngr, FR_Expr, FR_Utils;

{$R *.DFM}

function TfrParamsForm.CurParam: Integer;
begin
  Result := Query.frParams.ParamIndex(ParamsLB.Items[ParamsLB.ItemIndex]);
end;

procedure TfrParamsForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Query.frParams.Count - 1 do
    if ParamsLB.Items.IndexOf(Query.frParams.ParamName[i]) = -1 then
      ParamsLB.Items.Add(Query.frParams.ParamName[i]);
  for i := 0 to 10 do
    TypeCB.Items.Add(frLoadStr(SParamType1 + i));
  ParamsLB.ItemIndex := 0;
  ParamsLBClick(nil);
end;

procedure TfrParamsForm.FormHide(Sender: TObject);
begin
  if ValueE.Enabled then ValueEExit(nil);
  if VariableE.Enabled then VariableEExit(nil);
end;

procedure TfrParamsForm.ParamsLBClick(Sender: TObject);
var
  i: Integer;
begin
  TypeCB.ItemIndex := -1;
  for i := 0 to 10 do
    if Query.frParams.ParamType[CurParam] = ParamTypes[i] then
    begin
      TypeCB.ItemIndex := i;
      break;
    end;
  ValueE.Text := '';
  ValueE.Enabled := False;
  VariableE.Text := '';
  VariableE.Enabled := False;
  FBusy := True;
  case Query.frParams.ParamKind[CurParam] of
    pkValue:
      begin
        ValueE.Enabled := True;
        ValueE.Text := Query.frParams.ParamValue[CurParam];
        ValueRB.Checked := True;
      end;
    pkVariable:
      begin
        VariableE.Enabled := True;
        VariableE.Text := Query.frParams.ParamVariable[CurParam];
        VariableRB.Checked := True;
      end;
    pkAsk:
      AskRB.Checked := True;
    pkAssignFromMaster:
      AssignRB.Checked := True;
  end;
  FBusy := False;
end;

procedure TfrParamsForm.ValueEExit(Sender: TObject);
begin
  Query.frParams.ParamText[CurParam] := ValueE.Text;
end;

procedure TfrParamsForm.VariableEExit(Sender: TObject);
begin
  Query.frParams.ParamVariable[CurParam] := VariableE.Text;
end;

procedure TfrParamsForm.TypeCBChange(Sender: TObject);
begin
  Query.frParams.ParamType[CurParam] := ParamTypes[TypeCB.ItemIndex];
  if ValueE.Enabled then
    ValueEExit(nil);
end;

procedure TfrParamsForm.ValueRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  ValueE.Enabled := True;
  VariableE.Text := '';
  VariableE.Enabled := False;
  Query.frParams.ParamKind[CurParam] := pkValue;
end;

procedure TfrParamsForm.VariableRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  VariableE.Enabled := True;
  ValueE.Text := '';
  ValueE.Enabled := False;
  Query.frParams.ParamKind[CurParam] := pkVariable;
end;

procedure TfrParamsForm.AskRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  ValueE.Text := '';
  ValueE.Enabled := False;
  VariableE.Text := '';
  VariableE.Enabled := False;
  Query.frParams.ParamKind[CurParam] := pkAsk;
end;

procedure TfrParamsForm.AssignRBClick(Sender: TObject);
begin
  if FBusy then Exit;
  ValueE.Text := '';
  ValueE.Enabled := False;
  VariableE.Text := '';
  VariableE.Enabled := False;
  Query.frParams.ParamKind[CurParam] := pkAssignFromMaster;
end;

procedure TfrParamsForm.FormCreate(Sender: TObject);
begin
  GroupBox1.Caption := frLoadStr(frRes + 3110);
  Label2.Caption := frLoadStr(frRes + 3111);
  Label1.Caption := frLoadStr(frRes + 3112);
  ValueRB.Caption := frLoadStr(frRes + 3113);
  AskRB.Caption := frLoadStr(frRes + 3114);
  AssignRB.Caption := frLoadStr(frRes + 3115);
  VariableRB.Caption := frLoadStr(frRes + 3116);
  VariableE.ButtonHint := frLoadStr(frRes + 575);
  Button1.Caption := frLoadStr(SOk);
end;

procedure TfrParamsForm.VarSBClick(Sender: TObject);
begin
  with TfrExprForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      VariableE.Text := ExprMemo.Text;
    Free;
  end;
end;

end.

