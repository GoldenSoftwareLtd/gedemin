
{******************************************}
{                                          }
{             FastReport v2.53             }
{     Select Band datasource dialog        }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_BndEd;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FR_Class;

type
  TfrBandEditorForm = class(TfrObjEditorForm)
    Button1: TButton;
    Button2: TButton;
    GB1: TGroupBox;
    Label2: TLabel;
    Edit1: TEdit;
    LB1: TListBox;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LB1Click(Sender: TObject);
    procedure LB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure LB1DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure FillCombo;
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TfrView): TModalResult; override;
  end;


implementation

{$R *.DFM}

uses FR_DSet, FR_Const, FR_Utils;

function TfrBandEditorForm.ShowEditor(View: TfrView): TModalResult;
var
  i: Integer;
  s: String;
begin
  FillCombo;
  s := (View as TfrBandView).DataSet;
  if (s <> '') and (s[1] in ['1'..'9']) then
  begin
    i := 1;
    Edit1.Text := s;
  end
  else
  begin
    i := LB1.Items.IndexOf(CurReport.Dictionary.AliasName[s]);
    if i = -1 then
      i := LB1.Items.IndexOf(frLoadStr(SNotAssigned));
  end;
  LB1.ItemIndex := i;
  LB1Click(nil);
  Result := ShowModal;
  if Result = mrOk then
  begin
    frDesigner.BeforeChange;
    if LB1.ItemIndex = 1 then
      (View as TfrBandView).DataSet := Edit1.Text else
      (View as TfrBandView).DataSet :=
        CurReport.Dictionary.RealDataSourceName[LB1.Items[LB1.ItemIndex]];
  end;
end;

procedure TfrBandEditorForm.FillCombo;
begin
  CurReport.Dictionary.GetBandDatasourceList(LB1.Items);
  LB1.Items.Insert(0, frLoadStr(SVirtualDataset));
  LB1.Items.Insert(0, frLoadStr(SNotAssigned));
end;

procedure TfrBandEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 480);
  Label2.Caption := frLoadStr(frRes + 482);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrBandEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrBandEditorForm.LB1Click(Sender: TObject);
begin
  frEnableControls([Label2, Edit1], LB1.ItemIndex = 1);
end;

procedure TfrBandEditorForm.LB1DrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TListBox(Control) do
  begin
    Canvas.FillRect(ARect);
    if Index <> 0 then
      Canvas.BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16),
        Image1.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

procedure TfrBandEditorForm.LB1DblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

