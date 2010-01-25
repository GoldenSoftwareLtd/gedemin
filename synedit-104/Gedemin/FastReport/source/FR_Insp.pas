
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Object Inspector             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Insp;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, FR_Class, FR_Ctrls, FR_Pars, FR_PopupLB;

type
  TModifyEvent = procedure(Item: Integer) of object;
  TGetObjectsEvent = procedure(List: TStrings) of object;
  TSelectionChangedEvent = procedure(ObjName: String) of object;
  TfrInspForm = class;

  TProp = class(TObject)
  private
    procedure SetValue(Value: Variant);
    function GetValue: Variant;
    function IsEnumNull: Boolean;
  public
    Text: String;
    DataType: TfrDataTypes;
    Editor: TNotifyEvent;
    Enum: TStringList;
    EnumValues: Variant;
    constructor Create(PropValue: Variant; PropType: TfrDataTypes;
      PropEnum: TStringList; PropEnumValues: Variant; PropEditor: TNotifyEvent); virtual;
    destructor Destroy; override;
    property Value: Variant read GetValue write SetValue;
  end;

  TfrInspForm = class(TForm)
    CB1: TComboBox;
    Box: TScrollBox;
    PaintBox1: TPaintBox;
    Edit1: TEdit;
    EditPanel: TPanel;
    EditBtn: TfrSpeedButton;
    ComboPanel: TPanel;
    ComboBtn: TfrSpeedButton;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditBtnClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CB1DropDown(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure CB1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboBtnClick(Sender: TObject);
    procedure LB1Click(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FItems: TStringList;
    FItemIndex: Integer;
    FOnModify: TModifyEvent;
    FRowHeight: Integer;
    w, w1: Integer;
    b: TBitmap;
    BusyFlag, BusyFlag1: Boolean;
    DefHeight: Integer;
    LB1: TfrPopupListBox;
    FTickCount: Integer;
    Panel1: TPanel;
    FOnHeightChanged: TNotifyEvent;
    FOnGetObjects: TGetObjectsEvent;
    FOnSelectionChanged: TSelectionChangedEvent;
    FDown: Boolean;
    LastProp: String;
    FPropAliases: TfrVariables;
    procedure SetItems(Value: TStringList);
    procedure SetItemIndex(Value: Integer);
    function GetCount: Integer;
    procedure DrawOneLine(i: Integer; a: Boolean);
    procedure SetItemValue(Value: String);
    function GetItemValue(i: Integer): String;
    function CurItem: TProp;
    procedure WMNCLButtonDblClk(var Message: TMessage); message WM_NCLBUTTONDBLCLK;
    function GetPropValue(Index: Integer): Variant;
    procedure SetPropValue(Index: Integer; Value: Variant);
    function GetClassName(ObjName: String): String;
    procedure FillPropAliases;
    procedure Localize;
  public
    { Public declarations }
    CurObject: TObject;
    ObjectName: String;
    HideProperties: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ClearProperties;
    procedure AddProperty(PropName: String; PropValue: Variant;
     PropType: TfrDataTypes; PropEnum: TStringList; PropEnumValues: Variant;
     PropEditor: TNotifyEvent);
    procedure ItemsChanged;
    procedure Grow;
    property PropValue[Index: Integer]: Variant read GetPropValue write SetPropValue;
    property Items: TStringList read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property Count: Integer read GetCount;
    property SplitterPos: Integer read w1 write w1;
    property OnModify: TModifyEvent read FOnModify write FOnModify;
    property OnHeightChanged: TNotifyEvent read FOnHeightChanged write FOnHeightChanged;
    property OnGetObjects: TGetObjectsEvent read FOnGetObjects write FOnGetObjects;
    property OnSelectionChanged: TSelectionChangedEvent
      read FOnSelectionChanged write FOnSelectionChanged;
  end;


implementation

{$R *.DFM}
{$R FR_Lng5.RES}

uses FR_Const, FR_Utils
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TInspPanel = class(TPanel)
  protected
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure Paint; override;
  end;


procedure TInspPanel.WMEraseBackground(var Message: TMessage);
begin
end;

procedure TInspPanel.Paint;
begin
end;

{----------------------------------------------------------------------------}
constructor TProp.Create(PropValue: Variant; PropType: TfrDataTypes;
  PropEnum: TStringList; PropEnumValues: Variant; PropEditor: TNotifyEvent);
begin
  inherited Create;
  DataType := PropType;
  Editor := PropEditor;
  Enum := PropEnum;
  EnumValues := PropEnumValues;
  Value := PropValue;
end;

destructor TProp.Destroy;
begin
  EnumValues := 0;
  inherited Destroy;
end;

function TProp.IsEnumNull: Boolean;
begin
  Result := TVarData(EnumValues).VType < varArray;
end;

procedure TProp.SetValue(Value: Variant);

  function ConvertToFloat(s: String): String;
  var
    v: Double;
  begin
    v := StrToFloat(s);
    Result := FloatToStrF(v, ffFixed, 4, 2);
  end;

  function ConvertToColor(s: String): String;
  var
    i, v: Integer;
  begin
    v := StrToInt(s);
    Result := '$' + IntToHex(v, 6);
    for i := 0 to 41 do
      if v = frColors[i] then
      begin
        Result := frColorNames[i];
        break;
      end;
  end;

  function ConvertToBoolean(s: String): String;
  var
    v: Integer;
  begin
    if AnsiCompareText(s, 'True') = 0 then
      v := 1
    else if AnsiCompareText(s, 'False') = 0 then
      v := 0
    else
      v := StrToInt(s);
    if v <> 0 then
      Result := 'True' else
      Result := 'False';
  end;

  function ConvertFromEnum(s: String): String;
  var
    i: Integer;
  begin
    Result := s;
    for i := 0 to VarArrayHighBound(EnumValues, 1) do
      if EnumValues[i] = StrToInt(s) then
        Result := Enum[i];
  end;

begin
  Text := Value;
  if Text <> '' then
    if frdtFloat in DataType then
      Text := ConvertToFloat(Text)
    else if frdtBoolean in DataType then
      Text := ConvertToBoolean(Text)
    else if frdtColor in DataType then
      Text := ConvertToColor(Text)
    else if (frdtEnum in DataType) and not IsEnumNull then
      Text := ConvertFromEnum(Text);
end;

function TProp.GetValue: Variant;
var
  n: Integer;

  function ConvertFromColor(s: String): Integer;
  var
    i: Integer;
  begin
    for i := 0 to 41 do
      if AnsiCompareText(s, frColorNames[i]) = 0 then
      begin
        Result := frColors[i];
        Exit;
      end;
    Result := StrToInt(s);
  end;

  function ConvertFromBoolean(s: String): Boolean;
  begin
    s := AnsiUpperCase(s);
    Result := False;
    if s = 'TRUE' then
      Result := True
    else if s = 'FALSE' then
      Result := False
    else if (s <> '') and (s <> '0') then
      Result := True;
  end;

begin
  Result := Null;
  if (frdtString in DataType) or ((frdtEnum in DataType) and IsEnumNull) then
    Result := Text
  else if frdtInteger in DataType then
    Result := StrToInt(Text)
  else if frdtFloat in DataType then
    Result := frStrToFloat(Text)
  else if frdtBoolean in DataType then
    Result := ConvertFromBoolean(Text)
  else if frdtColor in DataType then
    Result := ConvertFromColor(Text)
  else if frdtEnum in DataType then
  begin
    n := Enum.IndexOf(Text);
    if n <> -1 then
      Result := EnumValues[n] else
      Result := StrToInt(Text);
  end;
end;

{----------------------------------------------------------------------------}
procedure TfrInspForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := frDesigner.Handle;
end;

function TfrInspForm.GetPropValue(Index: Integer): Variant;
begin
  Result := TProp(FItems.Objects[Index]).Value;
end;

procedure TfrInspForm.SetPropValue(Index: Integer; Value: Variant);
begin
  TProp(FItems.Objects[Index]).Value := Value;
end;

procedure TfrInspForm.ClearProperties;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    TProp(FItems.Objects[i]).Free;
  FItems.Clear;
end;

procedure TfrInspForm.AddProperty(PropName: String; PropValue: Variant;
  PropType: TfrDataTypes; PropEnum: TStringList; PropEnumValues: Variant;
  PropEditor: TNotifyEvent);
begin
  FItems.AddObject(PropName, TProp.Create(PropValue, PropType, PropEnum,
    PropEnumValues, PropEditor));
end;

function TfrInspForm.CurItem: TProp;
begin
  Result := nil;
  if (FItemIndex <> -1) and (Count > 0) then
    Result := TProp(FItems.Objects[FItemIndex]);
end;

procedure TfrInspForm.SetItems(Value: TStringList);
begin
  FItems.Assign(Value);
  FItemIndex := -1;
  PaintBox1.Repaint;
  ItemIndex := 0;
end;

procedure TfrInspForm.SetItemValue(Value: String);
var
  p: TProp;
  n: Integer;
begin
  if HideProperties then Exit;
  p := TProp(FItems.Objects[FItemIndex]);
  if FItems[FItemIndex]<>'Name' then
    p.Text := Value
  else
  if Value <> '' then
    p.Text := Value;
  n := FItemIndex;
  try
    BusyFlag1 := True;
    if Assigned(FOnModify) then FOnModify(FItemIndex);
    if n >= FItems.Count then
      n := 0;
  finally
    BusyFlag1 := False;
    SetItemIndex(n);
  end;
end;

function TfrInspForm.GetItemValue(i: Integer): String;
var
  p: TProp;
begin
  Result := '';
  p := TProp(FItems.Objects[i]);
  if p = nil then Exit;
  Result := p.Text;
end;

procedure TfrInspForm.SetItemIndex(Value: Integer);
var
  ww, y: Integer;
  b1, b2: Boolean;
begin
  if BusyFlag1 then Exit;
  if Value > Count - 1 then
    Value := Count - 1;
  Edit1.Visible := (Count > 0) and not HideProperties;
  if Count = 0 then Exit;
  if FItemIndex <> -1 then
    if Edit1.Modified then
      SetItemValue(Edit1.Text);
  FItemIndex := Value;
  EditPanel.Visible := Assigned(CurItem.Editor) and not HideProperties;
  ComboPanel.Visible :=
    ([frdtBoolean, frdtColor, frdtEnum] * CurItem.DataType <> []) and
    not HideProperties;
  LB1.Visible := False;
  b1 := frdtHasEditor in CurItem.DataType;
  b2 := frdtString in CurItem.DataType;
  Edit1.ReadOnly := b1 and not b2;
  ww := w - w1 - 2;
  y := FItemIndex * FRowHeight + 1;
  if EditPanel.Visible then
  begin
    EditPanel.SetBounds(w - 14, y, 14, FRowHeight - 2);
    EditBtn.SetBounds(0, 0, EditPanel.Width, EditPanel.Height);
    Dec(ww, 15);
  end;
  Edit1.Text := GetItemValue(FItemIndex);
  if ComboPanel.Visible then
  begin
    ComboPanel.SetBounds(w - 14, y, 14, FRowHeight - 2);
    ComboBtn.SetBounds(0, 0, ComboPanel.Width, ComboPanel.Height);
    Dec(ww, 15);
  end;
  Edit1.SetBounds(w1 + 2, y, ww, FRowHeight - 2);
  Edit1.SelectAll;
  Edit1.Modified := False;

  if y + FRowHeight > Box.VertScrollBar.Position + Box.ClientHeight then
    Box.VertScrollBar.Position := y - Box.ClientHeight + FRowHeight;
  if y < Box.VertScrollBar.Position then
    Box.VertScrollBar.Position := y - 1;

  LastProp := FItems[FItemIndex];
  PaintBox1Paint(nil);
end;

function TfrInspForm.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TfrInspForm.ItemsChanged;
var
  LastIndex: Integer;
begin
  FItemIndex := -1;
  BusyFlag := True;
  Panel1.Height := Items.Count * FRowHeight;
  Panel1.Width := Box.ClientWidth;
  w := PaintBox1.Width;
  BusyFlag := False;

  LastIndex := FItems.IndexOf(LastProp);
  if LastIndex = -1 then
    LastIndex := 0;
  ItemIndex := LastIndex;
  if not HideProperties then
  begin
    if not ((CB1.ItemIndex <> -1) and (CB1.Items[CB1.ItemIndex] = ObjectName)) then
    begin
      CB1DropDown(nil);
      CB1.ItemIndex := CB1.Items.IndexOf(ObjectName);
    end;
  end
  else
    CB1.ItemIndex := -1;
end;

procedure TfrInspForm.DrawOneLine(i: Integer; a: Boolean);
var
  R: TRect;

  procedure Line(x, y, dx, dy: Integer);
  begin
    b.Canvas.MoveTo(x, y);
    b.Canvas.LineTo(x + dx, y + dy);
  end;

  function GetPropName(Index: Integer): String;
  var
    i: Integer;
  begin
    i := FPropAliases.IndexOf(FItems[Index]);
    if (i <> -1) and frLocale.LocalizedPropertyNames then
      Result := FPropAliases.Value[i] else
      Result := FItems[Index];
  end;

begin
  if Count > 0 then
  with b.Canvas do
  begin
    Brush.Color := clBtnFace;
    Pen.Color := clBtnShadow;
    Font.Name := 'MS Sans Serif';
    Font.Size := 8;
    Font.Style := [];
    Font.Color := clBlack;
    R := Rect(5, i * FRowHeight + 1, w1 - 2, i * FRowHeight + FRowHeight - 1);
    if a then
    begin
      Pen.Color := clBtnShadow;
      Line(0, -2 + i * FRowHeight, w, 0);
      Line(w1 - 1, 0 + i * FRowHeight, 0, FRowHeight);
      Pen.Color := clBlack;
      Line(0, -1 + i * FRowHeight, w, 0);
      Line(0, -1 + i * FRowHeight, 0, FRowHeight + 1);
      Pen.Color := clBtnHighlight;
      Line(1, FRowHeight + -1 + i * FRowHeight, w - 1, 0);
      Line(Edit1.Left, 0 + i * FRowHeight, Edit1.Width, 0);
      Line(w1, 0 + i * FRowHeight, 0, FRowHeight);
      Line(w1 + 1, 0 + i * FRowHeight, 0, FRowHeight);
      TextRect(R, 5, 1 + i * FRowHeight, GetPropName(i));
    end
    else
    begin
      Line(0, FRowHeight + -1 + i * FRowHeight, w, 0);
      Line(w1 - 1, 0 + i * FRowHeight, 0, FRowHeight);
      Pen.Color := clBtnHighlight;
      Line(w1, 0 + i * FRowHeight, 0, FRowHeight);
      TextRect(R, 5, 1 + i * FRowHeight, GetPropName(i));
      Font.Color := clNavy;
      TextOut(w1 + 2, 1 + i * FRowHeight, GetItemValue(i));
    end;
  end;
end;

procedure TfrInspForm.PaintBox1Paint(Sender: TObject);
var
  i: Integer;
  r: TRect;
begin
  if BusyFlag then Exit;
//  LB1.Hide;
  r := PaintBox1.BoundsRect;
  b.Width := PaintBox1.Width;
  b.Height := PaintBox1.Height;
  b.Canvas.Brush.Color := clBtnFace;
  b.Canvas.FillRect(r);
  if not HideProperties then
  begin
    for i := 0 to Count - 1 do
      if i <> FItemIndex then
        DrawOneLine(i, False);
    if FItemIndex <> -1 then DrawOneLine(FItemIndex, True);
  end;
  PaintBox1.Canvas.Draw(0, 0, b);
end;

procedure TfrInspForm.FillPropAliases;
var
  i: Integer;
  s: String;
begin
  for i := frRes + 5001 to 65535 do
  begin
    s := frLoadStr(i);
    if s = '' then break;
    if (Pos('=', s) = 0) or (Pos('=', s) = Length(s)) then continue;
    FPropAliases[Copy(s, 1, Pos('=', s) - 1)] := Copy(s, Pos('=', s) + 1, 255);
  end;
end;

procedure TfrInspForm.Localize;
begin
  Caption := frLoadStr(frRes + 059);
end;

procedure TfrInspForm.FormCreate(Sender: TObject);
begin
//  Parent := Owner as TWinControl;
  Localize;
  FPropAliases := TfrVariables.Create;
  FillPropAliases;
  Panel1 := TInspPanel.Create(Self);
  Panel1.Parent := Box;
  Panel1.BevelInner := bvNone;
  Panel1.BevelOuter := bvNone;
  PaintBox1.Parent := Panel1;
  ComboPanel.Parent := Panel1;
  EditPanel.Parent := Panel1;
  Edit1.Parent := Panel1;
  w := PaintBox1.Width;
  b := TBitmap.Create;
  FItemIndex := -1;
  FItems := TStringList.Create;
  FRowHeight := Canvas.TextHeight('Wg') + 3;//-Font.Height + 5;
  Box.VertScrollBar.Increment := FRowHeight;
  Box.VertScrollBar.Tracking := True;
  LB1 := TfrPopupListBox.Create(nil);
  LB1.ListBox.OnClick := LB1Click;
  DefHeight := Height;
  FormResize(nil);
end;

procedure TfrInspForm.FormDestroy(Sender: TObject);
begin
  FPropAliases.Free;
  b.Free;
  LB1.Free;
  ClearProperties;
  FItems.Free;
end;

procedure TfrInspForm.FormActivate(Sender: TObject);
begin
  if Edit1.Enabled and Edit1.Visible then
    Edit1.SetFocus;
end;

procedure TfrInspForm.FormDeactivate(Sender: TObject);
begin
  if BusyFlag then Exit;
  LB1.Hide;
  if CurItem = nil then Exit;
  if [frdtHasEditor, frdtColor, frdtBoolean, frdtEnum] * CurItem.DataType = [] then
    if Edit1.Modified then SetItemValue(Edit1.Text);
end;

procedure TfrInspForm.FormShow(Sender: TObject);
begin
  if ClientHeight < 20 then
    CB1.Hide;
end;

procedure TfrInspForm.WMNCLButtonDblClk(var Message: TMessage);
begin
  if Height > 30 then
  begin
    ClientHeight := 0;
    CB1.Hide;
  end
  else
  begin
    Height := DefHeight;
    CB1.Show;
    ItemsChanged;
    Edit1.SelText := Edit1.Text;
    Edit1.Modified := False;
  end;
  if Assigned(FOnHeightChanged) then
    FOnHeightChanged(Self);
end;

procedure TfrInspForm.FormResize(Sender: TObject);
begin
  Box.Width := ClientWidth;
  Box.Height := ClientHeight - CB1.Height - 7;
  CB1.Width := ClientWidth;

  Panel1.Height := Items.Count * FRowHeight;
  Panel1.Width := Box.ClientWidth;

  w := PaintBox1.Width;
  SetItemIndex(FItemIndex);
end;

procedure TfrInspForm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if HideProperties then Exit;
  if PaintBox1.Cursor = crHSplit then
    FDown := True
  else
  begin
    ItemIndex := y div FRowHeight;
    Edit1.SetFocus;
    FTickCount := GetTickCount;
  end;
end;

procedure TfrInspForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if HideProperties then Exit;
  if Key = vk_Escape then
  begin
    Edit1.Perform(EM_UNDO, 0, 0);
    Edit1.Modified := False;
  end;
  if Key = vk_Up then
  begin
    if ItemIndex > 0 then
      ItemIndex := ItemIndex - 1;
    Key := 0;
  end
  else if Key = vk_Down then
  begin
    if ItemIndex < Count - 1 then
      ItemIndex := ItemIndex + 1;
    Key := 0;
  end;
end;

procedure TfrInspForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if frdtHasEditor in CurItem.DataType then
      EditBtnClick(nil)
    else
    begin
      if Edit1.Modified then SetItemValue(Edit1.Text);
      Edit1.Modified := False;
    end;
    Edit1.SelectAll;
    Key := #0;
  end;
end;

procedure TfrInspForm.EditBtnClick(Sender: TObject);
begin
  if HideProperties then Exit;
  CurItem.Editor(CurObject);
  Edit1.SelectAll;
end;

procedure TfrInspForm.Edit1DblClick(Sender: TObject);
var
  p: TProp;

  function IndexOf(arr: Variant; val: Variant): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to varArrayHighBound(arr, 1) do
      if arr[i] = val then
      begin
        Result := i;
        break;
      end;
  end;

begin
  p := CurItem;
  if frdtHasEditor in p.DataType then
    EditBtnClick(nil)
  else if frdtColor in p.DataType then
  begin
    with TColorDialog.Create(nil) do
    begin
      Color := p.Value;
      if Execute then
      begin
        p.Value := Color;
        SetItemValue(p.Text);
        Edit1.Modified := False;
        Edit1.SelectAll;
      end;
      Free;
    end;
  end
  else if frdtBoolean in p.DataType then
  begin
    p.Value := not p.Value;
    SetItemValue(p.Text);
    Edit1.Modified := False;
    Edit1.SelectAll;
  end
  else if frdtEnum in p.DataType then
  begin
    if p.IsEnumNull then
    begin
      if p.Enum.Count > 0 then
        if p.Enum.IndexOf(p.Value) >= p.Enum.Count - 1 then
          p.Value := p.Enum[0] else
          p.Value := p.Enum[p.Enum.IndexOf(p.Value) + 1];
    end
    else
{      if p.Value >= p.Enum.Count - 1 then
        p.Value := 0 else
        p.Value := p.Value + 1;}
      if IndexOf(p.EnumValues, p.Value) > varArrayHighBound(p.EnumValues, 1) - 1 then
        p.Value := p.EnumValues[0] else
        p.Value := p.EnumValues[IndexOf(p.EnumValues, p.Value) + 1];
    SetItemValue(p.Text);
    Edit1.Modified := False;
    Edit1.SelectAll;
  end
end;

procedure TfrInspForm.CB1DropDown(Sender: TObject);
var
  s: String;
begin
  if CB1.ItemIndex <> -1 then
    s := CB1.Items[CB1.ItemIndex] else
    s := '';
  if Assigned(FOnGetObjects) then
    FOnGetObjects(CB1.Items);
  CB1.ItemIndex := CB1.Items.IndexOf(s);
end;

procedure TfrInspForm.CB1Click(Sender: TObject);
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(CB1.Items[CB1.ItemIndex]);
  Edit1.SetFocus;
end;

function TfrInspForm.GetClassName(ObjName: String): String;
begin
  if CurObject <> nil then
    Result := CurObject.ClassName else
    Result := '';
end;

procedure TfrInspForm.CB1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with CB1.Canvas do
  begin
    FillRect(Rect);
    if CB1.DroppedDown then
      TextOut(Rect.Left + 2, Rect.Top + 1, CB1.Items[Index]) else
      TextOut(Rect.Left + 2, Rect.Top + 1, CB1.Items[Index] + ': ' +
        GetClassName(CB1.Items[Index]));
  end;
end;

procedure TfrInspForm.ComboBtnClick(Sender: TObject);
var
  i, wItems, nItems: Integer;
  p: TPoint;
begin
  BusyFlag := True;
  if LB1.Visible then
  begin
    LB1.Hide;
    Edit1.SetFocus;
  end
  else with LB1.ListBox do
  begin
    Items.Clear;
    Sorted := False;
    if frdtBoolean in CurItem.DataType then
    begin
      Items.Add('False');
      Items.Add('True');
    end
    else if frdtColor in CurItem.DataType then
      for i := 0 to 41 do
        Items.Add(frColorNames[i])
    else if frdtEnum in CurItem.DataType then
      for i := 0 to CurItem.Enum.Count - 1 do
        Items.Add(CurItem.Enum[i]);

    if Items.Count > 0 then
    begin
      ItemIndex := Items.IndexOf(CurItem.Text);
      wItems := 0;
      for i := 0 to Items.Count - 1 do
      begin
        if Canvas.TextWidth(Items[i]) > wItems then
          wItems := Canvas.TextWidth(Items[i]);
      end;

      Inc(wItems, 8);
      nItems := Items.Count;
      if nItems > 8 then
      begin
        nItems := 8;
        Inc(wItems, 16);
      end;

      p := Edit1.ClientToScreen(Point(0, Edit1.Height));

      if wItems < (w - w1) then
        LB1.SetBounds(w1 + 1, p.Y,
                  w - w1 + 1, nItems * (ItemHeight + 1) + 2)
      else
        LB1.SetBounds(w - wItems + 2, p.Y,
                  wItems, nItems * (ItemHeight + 1) + 2);

      Width := LB1.ClientWidth;
      Height := LB1.ClientHeight;
      LB1.Height := Height;
      p := Self.ClientToScreen(Point(0, 0));
      Inc(p.X, LB1.Left);
      if p.X < 0 then p.X := 0;
      LB1.Left := p.X;
      LB1.Show;
    end;
  end;
  BusyFlag := False;
end;

procedure TfrInspForm.LB1Click(Sender: TObject);
begin
  Edit1.Text := LB1.ListBox.Items[LB1.ListBox.ItemIndex];
  LB1.Hide;
  Edit1.SetFocus;
  SetItemValue(Edit1.Text);
end;

{$WARNINGS OFF}
procedure TfrInspForm.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GetTickCount - FTickCount < GetDoubleClickTime then
    Edit1DblClick(nil);
end;
{$WARNINGS ON}

procedure TfrInspForm.Grow;
begin
  Show;
  if ClientHeight < 20 then
  begin
    Height := DefHeight;
    CB1.Show;
    ItemsChanged;
    Edit1.SelText := Edit1.Text;
    Edit1.Modified := False;
    if Assigned(FOnHeightChanged) then
      FOnHeightChanged(Self);
  end;
end;


procedure TfrInspForm.PaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not FDown then
    if (X > w1 - 2) and (X < w1 + 2) then
      PaintBox1.Cursor := crHSplit else
      PaintBox1.Cursor := crDefault
  else
  begin
    if x > 5 then
      w1 := X;
    FormResize(nil);
  end;
end;

procedure TfrInspForm.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := False;
end;


end.

