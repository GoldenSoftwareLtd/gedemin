
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmRadioButtonEx.pas

  Abstract

    Original Radio Button without nasty Ctl3d.

  Author

    Romanovski Denis (25-04-99)

  Revisions history

    Initial  25-04-99  Dennis  Initial version.

--}

unit mmRadioButtonEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, DB;

type
  TmmRadioButtonEx = class(TRadioButton)
  private
    IsActive: Boolean;
    IsPressed: Boolean;
    BMP: TBitmap;
    
    procedure WMPaint(var Message: TWMPaint);
      message WM_PAINT;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;

    procedure DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);  
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
  end;

  TmmRadioGroup = class(TCustomGroupBox)
  private
    FButtons: TList;
    FItems: TStrings;
    FItemIndex: Integer;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FlipChildren(AllLevels: Boolean); override;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Columns: Integer read FColumns write SetColumns default 1;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Items: TStrings read FItems write SetItems;
    property Constraints;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
  end;
  
  TmmDBRadioGroup = class(TmmRadioGroup)
  private
    FDataLink: TFieldDataLink;
    FValue: string;
    FValues: TStrings;
    FInSetValue: Boolean;
    FOnChange: TNotifyEvent;
    procedure DataChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    function GetButtonValue(Index: Integer): string;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure SetValue(const Value: string);
    procedure SetItems(Value: TStrings);
    procedure SetValues(Value: TStrings);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    procedure Change; dynamic;
    procedure Click; override;
    procedure KeyPress(var Key: Char); override;
    function CanModify: Boolean; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    property DataLink: TFieldDataLink read FDataLink;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function UseRightToLeftAlignment: Boolean; override;
    property Field: TField read GetField;
    property ItemIndex;
    property Value: string read FValue write SetValue;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Columns;
    property Constraints;
    property Ctl3D;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Items write SetItems;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Values: TStrings read FValues write SetValues;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
  end;
  
implementation

{
  ----------------------------------
  ---   TmmRadioButtonEx Class   ---
  ----------------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmRadioButtonEx.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  IsActive := False;
  isPressed := False;

  BMP := TBitmap.Create;
  BMP.Width := 13;
  BMP.Height := 13;
end;

{
  Высвобождаем память.
}

destructor TmmRadioButtonEx.Destroy;
begin
  BMP.Free;
  inherited Destroy;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Обрабатываем все необходимые сообщения.
}

procedure TmmRadioButtonEx.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);

  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK: IsPressed := True;
    WM_LBUTTONUP: IsPressed := False;
    WM_KEYFIRST..WM_KEYLAST: if Focused then DrawBody;
    BM_SETCHECK, WM_SETTEXT, WM_ENABLE: DrawBody;
  end;

  if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then DrawBody;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производим перерисовку.
}

procedure TmmRadioButtonEx.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawBody;
end;

{
  По входу мыши в контрол производим его перерисовку.
}

procedure TmmRadioButtonEx.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  IsActive := True;
  DrawBody;
end;

{
  По выходу мыши из контрола производим его перерисовку.
}

procedure TmmRadioButtonEx.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  IsActive := False;
  DrawBody;
end;

{
  Производим прорисовку контрола самостоятельно.
}

procedure TmmRadioButtonEx.DrawBody(const PaintDC: hDC = 0; WithDC: Boolean = False);  
var
  DC: hDC;
  Wnd: hWnd;
  X, Y: Integer;
  BackBrsh: hBrush;
  LB: LOGBRUSH;

  // Производит рисоваине CheckBox-а
  procedure DrawCheckRect(DrawDC: hDC);
  var
    CheckBackBrsh, OldBrsh: hBrush;
    OldPen: hPen;
  begin
    if ((IsActive and not IsPressed) or (not IsActive and IsPressed)) and not
      (csDesigning in ComponentState)
    then
      CheckBackBrsh := GetStockObject(LTGRAY_BRUSH)
    else
      CheckBackBrsh := GetStockObject(WHITE_BRUSH);

    FillRect(DrawDC, Rect(0, 0, 13, 13), BackBrsh);

    OldPen := SelectObject(DrawDC, GetStockObject(BLACK_PEN));
    OldBrsh := SelectObject(DrawDC, CheckBackBrsh);

    RoundRect(DrawDC, 1, 1, 11, 11, 8, 8);

    SetPixel(DrawDC, 2, 2, ColorToRGB(Color));
    SetPixel(DrawDC, 2, 9, ColorToRGB(Color));
    SetPixel(DrawDC, 9, 2, ColorToRGB(Color));
    SetPixel(DrawDC, 9, 9, ColorToRGB(Color));

    SelectObject(DrawDC, OldPen);
    SelectObject(DrawDC, OldBrsh);

    if (Checked and not IsPressed) or (not Checked and IsPressed and IsActive) or
      (Checked and IsPressed and not IsActive) then
    begin
      OldBrsh := SelectObject(DrawDC, GetStockObject(BLACK_BRUSH));

      Ellipse(DrawDC, 4, 4, 8, 8);

      SelectObject(DrawDC, OldBrsh);
    end;
  end;

begin
  if Ctl3d or not HandleAllocated then Exit;

  if WithDC then
    DC := PaintDC
  else
    DC := GetDeviceContext(Wnd);

  try
    LB.lbStyle := BS_SOLID;
    LB.lbColor := ColorToRGB(Color);
    BackBrsh := CreateBrushIndirect(LB);

    if Alignment = taLeftJustify then
      X := Width - 13
    else
      X := 0;
      
    Y := Height div 2 - 7;

    // При рисовании используем Bitmap для избавления от мигания
    DrawCheckRect(BMP.Canvas.Handle);
    BitBlt(DC, X, Y, 13, 13, BMP.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    DeleteObject(BackBrsh);
    if not WithDC then ReleaseDC(Wnd, DC);
  end;  
end;

{
  ------------------------------
  ---   TGroupButton Class   ---
  ------------------------------
}


type
  TGroupButton = class(TmmRadioButtonEx)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(RadioGroup: TmmRadioGroup);
    destructor Destroy; override;
  end;

constructor TGroupButton.InternalCreate(RadioGroup: TmmRadioGroup);
begin
  inherited Create(RadioGroup);
  RadioGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := RadioGroup.Enabled;
  ParentShowHint := False;
  OnClick := RadioGroup.ButtonClick;
  Parent := RadioGroup;
end;

destructor TGroupButton.Destroy;
begin
  TmmRadioGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TGroupButton.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TmmRadioGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;
    FInClick := False;
  end;
end;

procedure TGroupButton.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TmmRadioGroup(Parent).KeyPress(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TmmRadioGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TGroupButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TmmRadioGroup(Parent).KeyDown(Key, Shift);
end;

{
  --------------------------------
  ---   TmmRadioGroup  Class   ---
  --------------------------------
}

constructor TmmRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FItemIndex := -1;
  FColumns := 1;
end;

destructor TmmRadioGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TmmRadioGroup.FlipChildren(AllLevels: Boolean); 
begin
  { The radio buttons are flipped using BiDiMode }
end;

procedure TmmRadioGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
begin
  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;
    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TGroupButton(FButtons[I]) do
        begin
          BiDiMode := Self.BiDiMode;
          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);
          Visible := True;
        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TmmRadioGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    FItemIndex := FButtons.IndexOf(Sender);
    Changed;
    Click;
  end;
end;

procedure TmmRadioGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    if FItemIndex >= FItems.Count then FItemIndex := FItems.Count - 1;
    UpdateButtons;
  end;
end;

procedure TmmRadioGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TmmRadioGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do TGroupButton.InternalCreate(Self);
  while FButtons.Count > Value do TGroupButton(FButtons.Last).Free;
end;

procedure TmmRadioGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TmmRadioGroup.SetItemIndex(Value: Integer);
begin
  if FReading then FItemIndex := Value else
  begin
    if Value < -1 then Value := -1;
    if Value >= FButtons.Count then Value := FButtons.Count - 1;
    if FItemIndex <> Value then
    begin
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := False;
      FItemIndex := Value;
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := True;
    end;
  end;
end;

procedure TmmRadioGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TmmRadioGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Caption := FItems[I];
  if FItemIndex >= 0 then
  begin
    FUpdating := True;
    TGroupButton(FButtons[FItemIndex]).Checked := True;
    FUpdating := False;
  end;
  ArrangeButtons;
  Invalidate;
end;

procedure TmmRadioGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Enabled := Enabled;
end;

procedure TmmRadioGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TmmRadioGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TmmRadioGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TmmRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

{
  ---------------------------------
  ---   TmmDBRadioGroup Class   ---
  ---------------------------------
}

constructor TmmDBRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FValues := TStringList.Create;
end;

destructor TmmDBRadioGroup.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  FValues.Free;
  inherited Destroy;
end;

procedure TmmDBRadioGroup.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

function TmmDBRadioGroup.UseRightToLeftAlignment: Boolean;
begin
  Result := DBUseRightToLeftAlignment(Self, Field);
end;

procedure TmmDBRadioGroup.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Value := FDataLink.Field.Text else
    Value := '';
end;

procedure TmmDBRadioGroup.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then FDataLink.Field.Text := Value;
end;

function TmmDBRadioGroup.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TmmDBRadioGroup.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TmmDBRadioGroup.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TmmDBRadioGroup.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TmmDBRadioGroup.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TmmDBRadioGroup.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TmmDBRadioGroup.GetField: TField;
begin
  Result := FDataLink.Field;
end;

function TmmDBRadioGroup.GetButtonValue(Index: Integer): string;
begin
  if (Index < FValues.Count) and (FValues[Index] <> '') then
    Result := FValues[Index]
  else if Index < Items.Count then
    Result := Items[Index]
  else
    Result := '';
end;

procedure TmmDBRadioGroup.SetValue(const Value: string);
var
  I, Index: Integer;
begin
  if FValue <> Value then
  begin
    FInSetValue := True;
    try
      Index := -1;
      for I := 0 to Items.Count - 1 do
        if Value = GetButtonValue(I) then
        begin
          Index := I;
          Break;
        end;
      ItemIndex := Index;
    finally
      FInSetValue := False;
    end;
    FValue := Value;
    Change;
  end;
end;

procedure TmmDBRadioGroup.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    if ItemIndex >= 0 then
      TRadioButton(Controls[ItemIndex]).SetFocus else
      TRadioButton(Controls[0]).SetFocus;
    raise;
  end;
  inherited;
end;

procedure TmmDBRadioGroup.Click;
begin
  if not FInSetValue then
  begin
    inherited Click;
    if ItemIndex >= 0 then Value := GetButtonValue(ItemIndex);
    if FDataLink.Editing then FDataLink.Modified;
  end;
end;

procedure TmmDBRadioGroup.SetItems(Value: TStrings);
begin
  Items.Assign(Value);
  DataChange(Self);
end;

procedure TmmDBRadioGroup.SetValues(Value: TStrings);
begin
  FValues.Assign(Value);
  DataChange(Self);
end;

procedure TmmDBRadioGroup.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TmmDBRadioGroup.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  case Key of
    #8, ' ': FDataLink.Edit;
    #27: FDataLink.Reset;
  end;
end;

function TmmDBRadioGroup.CanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

function TmmDBRadioGroup.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or (DataLink <> nil) and
    DataLink.ExecuteAction(Action);
end;

function TmmDBRadioGroup.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (DataLink <> nil) and
    DataLink.UpdateAction(Action);
end;

end.

