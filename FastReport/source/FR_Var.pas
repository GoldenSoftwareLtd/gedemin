
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Variables form               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Var;

interface

{$I FR.inc}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, FR_Const, ExtCtrls;

type
  TfrVarForm = class(TForm)
    VarLB: TListBox;
    CategoryLB: TListBox;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Image2: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure CategoryLBClick(Sender: TObject);
    procedure VarLBDblClick(Sender: TObject);
    procedure CategoryLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    function CurVal: String;
    function CurDataSet: String;
    procedure GetVariables;
    procedure GetSpecValues;
    procedure FillCategoryLB;
    procedure Localize;
  public
    { Public declarations }
    SelectedItem: String;
  end;

var
  frVarForm: TfrVarForm;

implementation

{$R *.DFM}

uses FR_Class, FR_Utils;

var
  LastCategory: String;
  

function TfrVarForm.CurVal: String;
begin
  Result := '';
  with VarLB do
  if ItemIndex <> -1 then
    Result := Items[ItemIndex];
end;

function TfrVarForm.CurDataSet: String;
begin
  Result := '';
  with CategoryLB do
    if ItemIndex <> -1 then
      Result := Items[ItemIndex];
end;

procedure TfrVarForm.FillCategoryLB;
var
  s: TStringList;
begin
  s := TStringList.Create;
  CurReport.Dictionary.GetCategoryList(s);
  s.Add(frLoadStr(SSystemVariables));
  CategoryLB.Items.Assign(s);
  s.Free;
end;

procedure TfrVarForm.CategoryLBClick(Sender: TObject);
begin
  if CurDataSet = frLoadStr(SSystemVariables) then
    GetSpecValues else
    GetVariables;
end;

procedure TfrVarForm.GetVariables;
begin
  CurReport.Dictionary.GetVariablesList(CategoryLB.Items[CategoryLB.ItemIndex],
    VarLB.Items);
end;

procedure TfrVarForm.GetSpecValues;
var
  i: Integer;
begin
  with VarLB.Items do
  begin
    Clear;
    for i := 0 to frSpecCount - 1 do
      if i <> 1 then
        Add(frLoadStr(SVar1 + i));
  end;
end;

procedure TfrVarForm.Localize;
begin
  Caption := frLoadStr(frRes + 440);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrVarForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrVarForm.FormActivate(Sender: TObject);
begin
  FillCategoryLB;
  with CategoryLB do
    if Items.IndexOf(LastCategory) <> -1 then
      ItemIndex := Items.IndexOf(LastCategory) else
      ItemIndex := 0;
  CategoryLBClick(nil);
end;

procedure TfrVarForm.FormDeactivate(Sender: TObject);
begin
  if ModalResult = mrOk then
    if CurDataSet <> frLoadStr(SSystemVariables) then
      SelectedItem := CurVal
    else
      if VarLB.ItemIndex > 0 then
        SelectedItem := frSpecFuncs[VarLB.ItemIndex + 1] else
        SelectedItem := frSpecFuncs[0];
  LastCategory := CategoryLB.Items[CategoryLB.ItemIndex];
end;

procedure TfrVarForm.VarLBDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrVarForm.CategoryLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Image: TImage;
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TListBox(Control) do
  begin
    Canvas.FillRect(ARect);
    if Control = CategoryLB then
      Image := Image1 else
      Image := Image2;
    Canvas.BrushCopy(r, Image.Picture.Bitmap, Rect(0, 0, 18, 16),
      Image.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

end.

