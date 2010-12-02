
{******************************************}
{                                          }
{             FastReport v2.4              }
{          Insert fields dialog            }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_IFlds;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_DBRel, ExtCtrls;

type
  TfrInsertFieldsForm = class(TForm)
    FieldsL: TListBox;
    DatasetCB: TComboBox;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    HorzRB: TRadioButton;
    VertRB: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    GroupBox2: TGroupBox;
    HeaderCB: TCheckBox;
    BandCB: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    procedure DatasetCBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FieldsLDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure DatasetCBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    DataSet: TfrTDataSet;
  end;


implementation

uses FR_Class, FR_Const, FR_Utils;

{$R *.DFM}

procedure TfrInsertFieldsForm.FormShow(Sender: TObject);
begin
  DataSet := nil;
  CurReport.Dictionary.GetDatasetList(DatasetCB.Items);
  if DatasetCB.Items.Count > 0 then
    DatasetCB.ItemIndex := 0;
  DatasetCBChange(nil);
end;

procedure TfrInsertFieldsForm.DatasetCBChange(Sender: TObject);
var
  DSName: String;
begin
  DSName := DatasetCB.Items[DatasetCB.ItemIndex];
  {jkl}{!!!} // ѕришлось исправить т.к. самый простой способ
  DataSet := CurReport.Dictionary.gsGetDataSet(CurReport.Dictionary.RealDataSetName[DSName]);{!!!}
  // frGetDataSet(CurReport.Dictionary.RealDataSetName[DSName]);
  CurReport.Dictionary.GetFieldList(DSName, FieldsL.Items);
end;

procedure TfrInsertFieldsForm.Localize;
begin
  Caption := frLoadStr(frRes + 630);
  Label1.Caption := frLoadStr(frRes + 631);
  GroupBox1.Caption := frLoadStr(frRes + 632);
  HorzRB.Caption := frLoadStr(frRes + 633);
  VertRB.Caption := frLoadStr(frRes + 634);
  HeaderCB.Caption := frLoadStr(frRes + 635);
  BandCB.Caption := frLoadStr(frRes + 636);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrInsertFieldsForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrInsertFieldsForm.DatasetCBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with DatasetCB.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clGreen);
    TextOut(ARect.Left + 20, ARect.Top + 1, DatasetCB.Items[Index]);
  end;
end;

procedure TfrInsertFieldsForm.FieldsLDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with FieldsL.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image2.Picture.Bitmap, Rect(0, 0, 18, 16), clGreen);
    TextOut(ARect.Left + 20, ARect.Top + 1, FieldsL.Items[Index]);
  end;
end;

end.

