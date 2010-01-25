
{******************************************}
{                                          }
{             FastReport v2.53             }
{     Select Band datasource dialog        }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_VBnd;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FR_Class, FR_Pars;

type
  TfrVBandEditorForm = class(TfrObjEditorForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    CB1: TComboBox;
    Edit1: TEdit;
    LB1: TListBox;
    Image1: TImage;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure LB1Click(Sender: TObject);
    procedure CB1Exit(Sender: TObject);
    procedure CB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure LB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    Band: TfrBandView;
    List: TfrVariables;
    procedure FillCombo;
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TfrView): TModalResult; override;
  end;


implementation

{$R *.DFM}

uses FR_DSet, FR_Const, FR_Utils;

function TfrVBandEditorForm.ShowEditor(View: TfrView): TModalResult;
var
  i, j, n: Integer;
  s: String;
  t1: TfrView;
  b: Boolean;
begin
  Band := View as TfrBandView;
  List := TfrVariables.Create;

  s := Band.Dataset;
  b := False;
  if Pos(';', s) = 0 then
    b := True;

  with frDesigner.Page do
  for i := 0 to Objects.Count - 1 do
  begin
    t1 := Objects[i];
    if (t1.Typ = gtBand) and not (TfrBandView(t1).BandType in
      [btReportTitle..btPageFooter, btOverlay, btCrossHeader..btCrossFooter]) then
    begin
      LB1.Items.Add(t1.Name + ': ' + frBandNames[t1.FrameTyp]);
      n := Pos(AnsiUpperCase(t1.Name) + '=', AnsiUpperCase(s));
      if n <> 0 then
      begin
        n := n + Length(t1.Name) + 1;
        j := n;
        while s[j] <> ';' do Inc(j);
        List[t1.Name] := Copy(s, n, j - n);
      end
      else
        if b then
          List[t1.Name] := s else
          List[t1.Name] := '0';
    end;
  end;
  if LB1.Items.Count = 0 then
  begin
    List.Free;
    Result := mrCancel;
    Exit;
  end;
  FillCombo;
  LB1.ItemIndex := 0;
  LB1Click(nil);

  Result := ShowModal;
  if Result = mrOk then
  begin
    CB1Exit(nil);
    frDesigner.BeforeChange;
    s := '';
    for i := 0 to List.Count - 1 do
      s := s + List.Name[i] + '=' + List.Value[i] + ';';
    Band.DataSet := s;
  end;
  List.Free;
end;

procedure TfrVBandEditorForm.FillCombo;
begin
  CurReport.Dictionary.GetBandDatasourceList(CB1.Items);
  CB1.Items.Insert(0, frLoadStr(SVirtualDataset));
  CB1.Items.Insert(0, frLoadStr(SNotAssigned));
end;

procedure TfrVBandEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 485);
  GroupBox1.Caption := frLoadStr(frRes + 486);
  GroupBox2.Caption := frLoadStr(frRes + 487);
  Label1.Caption := frLoadStr(frRes + 488);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrVBandEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrVBandEditorForm.CB1Click(Sender: TObject);
begin
  frEnableControls([Label1, Edit1], CB1.ItemIndex = 1);
end;

procedure TfrVBandEditorForm.LB1Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  s := LB1.Items[LB1.ItemIndex];
  s := Copy(s, 1, Pos(':', s) - 1);
  s := List[s];
  if (s <> '') and (s[1] in ['1'..'9']) then
  begin
    i := 1;
    Edit1.Text := s;
  end
  else
  begin
    i := CB1.Items.IndexOf(CurReport.Dictionary.AliasName[s]);
    if i = -1 then
      i := CB1.Items.IndexOf(frLoadStr(SNotAssigned));
  end;
  CB1.ItemIndex := i;
  CB1Click(nil);
end;

procedure TfrVBandEditorForm.CB1Exit(Sender: TObject);
var
  s: String;
begin
  s := LB1.Items[LB1.ItemIndex];
  s := Copy(s, 1, Pos(':', s) - 1);
  if CB1.ItemIndex = 1 then
    List[s] := Edit1.Text else
    List[s] := CurReport.Dictionary.RealDataSourceName[CB1.Items[CB1.ItemIndex]];
end;

procedure TfrVBandEditorForm.CB1DrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TComboBox(Control) do
  begin
    Canvas.FillRect(ARect);
    if Index <> 0 then
      Canvas.BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16),
        Image1.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

procedure TfrVBandEditorForm.LB1DrawItem(Control: TWinControl;
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
    Canvas.BrushCopy(r, Image2.Picture.Bitmap, Rect(0, 0, 18, 16),
      Image2.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

end.

