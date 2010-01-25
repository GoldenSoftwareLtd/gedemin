
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Insert Fields dialog           }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Flds1;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrInsFieldsForm = class(TForm)
    FieldsLB: TListBox;
    DatasetsLB: TListBox;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Splitter: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FieldsLBDblClick(Sender: TObject);
    procedure DatasetsLBClick(Sender: TObject);
    procedure DatasetsLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FieldsLBStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure SplitterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SplitterMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FHeightChanged: TNotifyEvent;
    FDown: Boolean;
    FLastY: Integer;
    procedure FillDatasetsLB;
    procedure GetFieldName;
    procedure WMNCLButtonDblClk(var Message: TMessage); message WM_NCLBUTTONDBLCLK;
    procedure Localize;
  public
    { Public declarations }
    DBField: String;
    DefHeight: Integer;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Grow;
    procedure RefreshData;
    property OnHeightChanged: TNotifyEvent read FHeightChanged write FHeightChanged;
  end;


var
  frFieldsDialog: TfrInsFieldsForm;


implementation

{$R *.DFM}

uses FR_Class, FR_Const, FR_Utils, FR_DBRel, FR_Dock, Registry;

var
  LastDB: String;


procedure TfrInsFieldsForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := TWinControl(Owner).Handle;
end;

procedure TfrInsFieldsForm.FillDatasetsLB;
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

procedure TfrInsFieldsForm.DatasetsLBClick(Sender: TObject);
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

procedure TfrInsFieldsForm.GetFieldName;
begin
  if DatasetsLB.Items.Count > 0 then
    LastDB := DatasetsLB.Items[DatasetsLB.ItemIndex];

  if (FieldsLB.ItemIndex <> -1) and (FieldsLB.Items.Count <> 0) then
    if Integer(FieldsLB.Items.Objects[FieldsLB.ItemIndex]) = 1 then
      DBField := FieldsLB.Items[FieldsLB.ItemIndex] else
      DBField := LastDB + '."' + FieldsLB.Items[FieldsLB.ItemIndex] + '"';
end;

procedure TfrInsFieldsForm.RefreshData;
begin
  if DatasetsLB.Items.Count > 0 then
    LastDB := DatasetsLB.Items[DatasetsLB.ItemIndex];
  FormShow(nil);
end;

procedure TfrInsFieldsForm.Localize;
begin
  Caption := frLoadStr(frRes + 450);
end;

procedure TfrInsFieldsForm.FormCreate(Sender: TObject);
var
  Ini: TRegIniFile;
begin
  Localize;
  RestoreFormPosition(Self);
  Ini := TRegIniFile.Create(RegRootKey);
  DatasetsLB.Height := Ini.ReadInteger(rsForm + ClassName, 'SplitterPos', 120);
  Ini.Free;
  DefHeight := Height;
  if DefHeight < 30 then
    DefHeight := 300;
  if ClientHeight < 20 then
    DatasetsLB.Hide;
end;

procedure TfrInsFieldsForm.FormShow(Sender: TObject);
begin
  FillDatasetsLB;
  with DatasetsLB do
    if Items.Count > 0 then
    begin
      if Items.IndexOf(LastDB) <> -1 then
        ItemIndex := Items.IndexOf(LastDB) else
        ItemIndex := 0;
      DatasetsLBClick(nil);
    end
    else
      FieldsLB.Items.Clear;
end;

procedure TfrInsFieldsForm.FormHide(Sender: TObject);
var
  Ini: TRegIniFile;
begin
  frFieldsDialog := nil;
  SaveFormPosition(Self);
  Ini := TRegIniFile.Create(RegRootKey);
  Ini.WriteInteger(rsForm + ClassName, 'SplitterPos', DatasetsLB.Height);
  Ini.Free;
  GetFieldName;
  if frDesigner.Visible then
    frDesigner.SetFocus;
end;

procedure TfrInsFieldsForm.FieldsLBDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrInsFieldsForm.DatasetsLBDrawItem(Control: TWinControl;
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

procedure TfrInsFieldsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrInsFieldsForm.FieldsLBStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  GetFieldName;
end;

procedure TfrInsFieldsForm.Grow;
begin
  Height := DefHeight;
  DatasetsLB.Show;
  if Assigned(FHeightChanged) then
    FHeightChanged(Self);
end;

procedure TfrInsFieldsForm.WMNCLButtonDblClk(var Message: TMessage);
begin
  if Height > 30 then
  begin
    ClientHeight := 0;
    DatasetsLB.Hide;
  end
  else
  begin
    Height := DefHeight;
    DatasetsLB.Show;
  end;
  if Assigned(FHeightChanged) then
    FHeightChanged(Self);
end;


procedure TfrInsFieldsForm.SplitterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := True;
  FLastY := Y;
end;

procedure TfrInsFieldsForm.SplitterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDown then
  begin
    DatasetsLB.Height := DatasetsLB.Height + (Y - FLastY);
    Splitter.Top := Splitter.Top + Y - FLastY;
  end;
end;

procedure TfrInsFieldsForm.SplitterMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := False;
end;

end.
