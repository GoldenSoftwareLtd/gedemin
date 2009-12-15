
{******************************************}
{                                          }
{             FastReport v2.4              }
{               Fields list                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Flds;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrFieldsForm = class(TForm)
    FieldsLB: TListBox;
    DatasetsLB: TListBox;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FieldsLBDblClick(Sender: TObject);
    procedure DatasetsLBClick(Sender: TObject);
    procedure DatasetsLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    procedure FillDatasetsLB;
    procedure GetFieldName;
    procedure Localize;
  public
    { Public declarations }
    DBField: String;
  end;



implementation

{$R *.DFM}

uses FR_Class, FR_Const, FR_Utils, FR_DBRel;

var
  LastDB: String;


procedure TfrFieldsForm.FillDatasetsLB;
var
  i: Integer;
  sl: TStringList;
begin
  sl := TStringList.Create;
  DatasetsLB.Items.BeginUpdate;
  CurReport.Dictionary.GetDatasetList(DatasetsLB.Items);
  if CurReport.MixVariablesAndDBFields then
  begin
    CurReport.Dictionary.GetCategoryList(sl);
    for i := 0 to sl.Count - 1 do
      DatasetsLB.Items.AddObject(sl[i], TObject(1));
  end;
  DatasetsLB.Items.EndUpdate;
  sl.Free;
end;

procedure TfrFieldsForm.DatasetsLBClick(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
begin
  if Integer(DatasetsLB.Items.Objects[DatasetsLB.ItemIndex]) = 1 then
  begin
    sl := TStringList.Create;
    CurReport.Dictionary.GetVariablesList(DatasetsLB.Items[DatasetsLB.ItemIndex], sl);
    FieldsLB.Items.Clear;
    for i := 0 to sl.Count - 1 do
      FieldsLB.Items.AddObject(sl[i], TObject(1));
    sl.Free;
  end
  else
    CurReport.Dictionary.GetFieldList(DatasetsLB.Items[DatasetsLB.ItemIndex],
      FieldsLB.Items)
end;

procedure TfrFieldsForm.GetFieldName;
begin
  if DatasetsLB.Items.Count > 0 then
    LastDB := DatasetsLB.Items[DatasetsLB.ItemIndex];
  if FieldsLB.ItemIndex <> -1 then
    if Integer(FieldsLB.Items.Objects[FieldsLB.ItemIndex]) = 1 then
      DBField := FieldsLB.Items[FieldsLB.ItemIndex] else
      DBField := LastDB + '."' + FieldsLB.Items[FieldsLB.ItemIndex] + '"';
end;

procedure TfrFieldsForm.Localize;
begin
  Caption := frLoadStr(frRes + 450);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrFieldsForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrFieldsForm.FormShow(Sender: TObject);
begin
  FillDatasetsLB;
  with DatasetsLB do
    if Items.Count > 0 then
    begin
      if Items.IndexOf(LastDB) <> -1 then
        ItemIndex := Items.IndexOf(LastDB) else
        ItemIndex := 0;
      DatasetsLBClick(nil);
    end;
end;

procedure TfrFieldsForm.FormHide(Sender: TObject);
begin
  GetFieldName;
  if frDesigner.Visible then
    frDesigner.SetFocus;
end;

procedure TfrFieldsForm.FieldsLBDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrFieldsForm.DatasetsLBDrawItem(Control: TWinControl;
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
    if Control = DatasetsLB then
      if Integer(Items.Objects[Index]) = 1 then
        Image := Image3 else
        Image := Image1
    else if Integer(Items.Objects[Index]) = 1 then
      Image := Image4 else
      Image := Image2;
    Canvas.BrushCopy(r, Image.Picture.Bitmap, Rect(0, 0, 18, 16),
      Image.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

end.
