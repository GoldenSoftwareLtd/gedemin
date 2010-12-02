unit ColorComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;
                    
const
  NoColorSelected = TColor($FF000000);
  StandardColorsCount = 16;
  ExtendedColorsCount = 4;
  SRColorBoxCustomCaption = 'Другой...';
  SEColorBoxCustomCaption = 'Other...';

type
  TColorComboBoxStyles = (cbStandardColors, // first sixteen RGBI colors
                     cbExtendedColors, // four additional reserved colors
                     cbSystemColors,   // system managed/defined colors
                     cbIncludeNone,    // include clNone color, must be used with cbSystemColors
                     cbIncludeDefault, // include clDefault color, must be used with cbSystemColors
                     cbCustomColor,    // first color is customizable
                     cbRussianColorNames,
                     cbPrettyNames);   // instead of 'clColorNames' you get 'Color Names'
  TColorComboBoxStyle = set of TColorComboBoxStyles;

type
  TCustomColorComboBox = class(TCustomComboBox)
  private
    FStyle: TColorComboBoxStyle;
    FNeedToPopulate: Boolean;
    FListSelected: Boolean;
    FDefaultColor: TColor;
    FNoneColor: TColor;
    FSelectedColor: TColor;
    FOnCloseUp: TNotifyEvent;
    FOnSelect: TNotifyEvent;
    function GetColor(Index: Integer): TColor;
    function GetColorName(Index: Integer): string;
    function GetSelected: TColor;
    procedure SetSelected(const AColor: TColor);
    procedure ColorCallBack(const AName: string);
    procedure SetDefaultColor(const Value: TColor);
    procedure SetNoneColor(const Value: TColor);
    procedure SetOnCloseUp(const Value: TNotifyEvent);
    procedure SetOnSelect(const Value: TNotifyEvent);

    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure CloseUp;
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function PickCustomColor: Boolean; virtual;
    procedure PopulateList;
    procedure Select;
    procedure SetStyle(AStyle: TColorComboBoxStyle); reintroduce;

    property OnCloseUp: TNotifyEvent read FOnCloseUp write SetOnCloseUp;
    property OnSelect: TNotifyEvent read FOnSelect write SetOnSelect;
  public
    constructor Create(AOwner: TComponent); override;
    property Style: TColorComboBoxStyle read FStyle write SetStyle
      default [cbStandardColors, cbCustomColor, cbRussianColorNames];
    property Colors[Index: Integer]: TColor read GetColor;
    property ColorNames[Index: Integer]: string read GetColorName;
    property Selected: TColor read GetSelected write SetSelected default clBlack;
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor default clBlack;
    property NoneColor: TColor read FNoneColor write SetNoneColor default clBlack;
  end;

  TgsColorComboBox = class(TCustomColorComboBox)
  published
//    property AutoComplete;
//    property AutoDropDown;
    property DefaultColor;
    property NoneColor;
    property Selected;
    property Style;

    property Anchors;
//    property BevelEdges;
//    property BevelInner;
//    property BevelKind;
//    property BevelOuter;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
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
    property OnChange;
    property OnCloseUp;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

const
  _Colors: array[0..15] of TIdentMapEntry = (
    (Value: clBlack; Name: 'Четный'),
    (Value: clMaroon; Name: 'Красно-малиновый'),
    (Value: clGreen; Name: 'Зеленый'),
    (Value: clOlive; Name: 'Желтовато-зеленый'),
    (Value: clNavy; Name: 'Темно-синий'),
    (Value: clPurple; Name: 'Фиолетовый'),
    (Value: clTeal; Name: 'Голубовато-зеленый'),
    (Value: clGray; Name: 'Серый'),
    (Value: clSilver; Name: 'Серебрянный'),
    (Value: clRed; Name: 'Красный'),
    (Value: clLime; Name: 'Светло-зеленый'),
    (Value: clYellow; Name: 'Желтый'),
    (Value: clBlue; Name: 'Синий'),
    (Value: clFuchsia; Name: 'Светло-фиолетовый'),
    (Value: clAqua; Name: 'Морская волна'),
    (Value: clWhite; Name: 'Белый'));

procedure Register;
begin
  RegisterComponents('Standard', [TgsColorComboBox]);
end;

{ TCustomColorComboBox }

procedure TCustomColorComboBox.CloseUp;
begin
  if Assigned(FOnCloseUp) then
    FOnCloseUp(Self);
  FListSelected := True;
end;

procedure TCustomColorComboBox.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    CBN_CLOSEUP:
      CloseUp;
    CBN_SELCHANGE:
      begin
        Text := Items[ItemIndex];
        Click;
        Select;
      end;
  end;
end;

procedure TCustomColorComboBox.ColorCallBack(const AName: string);
var
  I, LStart: Integer;
  LColor: TColor;
  LName: string;

  function GetRussianName(const AName: String): string;
  var
    C: LongInt;
    I: Integer;
  begin
    Result := AName;
    if IdentToColor(AName, C) then
    begin
      for I := Low(_Colors) to High(_Colors) do
      begin
        if _Colors[i].Value = C then
          Result := _Colors[I].Name;
      end;
    end;
  end;

begin
  LColor := StringToColor(AName);
  if (cbPrettyNames in Style) or (cbRussianColorNames in Style) then
  begin
    if cbPrettyNames in Style then
    begin
      if Copy(AName, 1, 2) = 'cl' then
        LStart := 3
      else
        LStart := 1;
      LName := '';
      for I := LStart to Length(AName) do
      begin
        case AName[I] of
          'A'..'Z':
            if LName <> '' then
              LName := LName + ' ';
        end;
        LName := LName + AName[I];
      end;
    end else
    begin
      LName := GetRussianName(AName);
    end;
  end
  else
    LName := AName;
  Items.AddObject(LName, TObject(LColor));
end;

constructor TCustomColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited Style := csOwnerDrawFixed;
  FStyle := [cbStandardColors, cbCustomColor, cbRussianColorNames];
  FSelectedColor := clBlack;
  FDefaultColor := clBlack;
  FNoneColor := clBlack;
  PopulateList;
end;

procedure TCustomColorComboBox.CreateWnd;
begin
  inherited CreateWnd;
  if FNeedToPopulate then
    PopulateList;
end;

procedure TCustomColorComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
  function ColorToBorderColor(AColor: TColor): TColor;
  type
    TColorQuad = record
      Red,
      Green,
      Blue,
      Alpha: Byte;
    end;
  begin
    if (TColorQuad(AColor).Red > 192) or
       (TColorQuad(AColor).Green > 192) or
       (TColorQuad(AColor).Blue > 192) then
      Result := clBlack
    else if odSelected in State then
      Result := clWhite
    else
      Result := AColor;
  end;

var
  LRect: TRect;
  LBackground: TColor;
begin
  with Canvas do
  begin
    FillRect(Rect);
    LBackground := Brush.Color;

    LRect := Rect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left;
    InflateRect(LRect, -1, -1);
    Brush.Color := Colors[Index];
    if Brush.Color = clDefault then
      Brush.Color := DefaultColor
    else if Brush.Color = clNone then
      Brush.Color := NoneColor;
    FillRect(LRect);
    Brush.Color := ColorToBorderColor(ColorToRGB(Brush.Color));
    FrameRect(LRect);

    Brush.Color := LBackground;
    Rect.Left := LRect.Right + 5;

    TextRect(Rect, Rect.Left,
      Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(Items[Index])) div 2,
      Items[Index]);
  end;
end;

function TCustomColorComboBox.GetColor(Index: Integer): TColor;
begin
  Result := TColor(Items.Objects[Index]);
end;

function TCustomColorComboBox.GetColorName(Index: Integer): string;
begin
  Result := Items[Index];
end;

function TCustomColorComboBox.GetSelected: TColor;
begin
  if HandleAllocated then
    if ItemIndex <> -1 then
      Result := Colors[ItemIndex]
    else
      Result := NoColorSelected
  else
    Result := FSelectedColor;
end;

procedure TCustomColorComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FListSelected := False;
  inherited KeyDown(Key, Shift);
end;

procedure TCustomColorComboBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (cbCustomColor in Style) and (Key = #13) and (ItemIndex = 0) then
  begin
    PickCustomColor;
    Key := #0;
  end;
end;

function TCustomColorComboBox.PickCustomColor: Boolean;
var
  LColor: TColor;
begin
  with TColorDialog.Create(nil) do
    try
      LColor := ColorToRGB(TColor(Items.Objects[0]));
      Color := LColor;
      CustomColors.Text := Format('ColorA=%.8x', [LColor]);
      Result := Execute;
      if Result then
      begin
        Items.Objects[0] := TObject(Color);
        Self.Invalidate;
      end;
    finally
      Free;
    end;
end;

procedure TCustomColorComboBox.PopulateList;
  procedure DeleteRange(const AMin, AMax: Integer);
  var
    I: Integer;
  begin
    for I := AMax downto AMin do
      Items.Delete(I);
  end;
  procedure DeleteColor(const AColor: TColor);
  var
    I: Integer;
  begin
    I := Items.IndexOfObject(TObject(AColor));
    if I <> -1 then
      Items.Delete(I);
  end;
var
  LSelectedColor, LCustomColor: TColor;
begin
  if HandleAllocated then
  begin
    Items.BeginUpdate;
    try
      LCustomColor := clBlack;
      if (cbCustomColor in Style) and (Items.Count > 0) then
        LCustomColor := TColor(Items.Objects[0]);
      LSelectedColor := FSelectedColor;
      Items.Clear;
      GetColorValues(ColorCallBack);
      if not (cbIncludeNone in Style) then
        DeleteColor(clNone);
      if not (cbIncludeDefault in Style) then
        DeleteColor(clDefault);
      if not (cbSystemColors in Style) then
        DeleteRange(StandardColorsCount + ExtendedColorsCount, Items.Count - 1);
      if not (cbExtendedColors in Style) then
        DeleteRange(StandardColorsCount, StandardColorsCount + ExtendedColorsCount - 1);
      if not (cbStandardColors in Style) then
        DeleteRange(0, StandardColorsCount - 1);
      if cbCustomColor in Style then
      begin
        if cbRussianColorNames in Style then
          Items.InsertObject(0, SRColorBoxCustomCaption, TObject(LCustomColor))
        else
          Items.InsertObject(0, SEColorBoxCustomCaption, TObject(LCustomColor))
      end;
      Selected := LSelectedColor;
    finally
      Items.EndUpdate;
      FNeedToPopulate := False;
    end;
  end
  else
    FNeedToPopulate := True;
end;

procedure TCustomColorComboBox.Select;
begin
  if FListSelected then
  begin
    FListSelected := False;
    if (cbCustomColor in Style) and
       (ItemIndex = 0) and
       not PickCustomColor then
      Exit;
  end;
  if Assigned(FOnSelect) then
    FOnSelect(Self);
end;

procedure TCustomColorComboBox.SetDefaultColor(const Value: TColor);
begin
  if Value <> FDefaultColor then
  begin
    FDefaultColor := Value;
    Invalidate;
  end;
end;

procedure TCustomColorComboBox.SetNoneColor(const Value: TColor);
begin
  if Value <> FNoneColor then
  begin
    FNoneColor := Value;
    Invalidate;
  end;
end;

procedure TCustomColorComboBox.SetOnCloseUp(const Value: TNotifyEvent);
begin
  FOnCloseUp := Value;
end;

procedure TCustomColorComboBox.SetOnSelect(const Value: TNotifyEvent);
begin
  FOnSelect := Value;
end;

procedure TCustomColorComboBox.SetSelected(const AColor: TColor);
var
  I: Integer;
begin
  if HandleAllocated then
  begin
    I := Items.IndexOfObject(TObject(AColor));
    if (I = -1) and (cbCustomColor in Style) and (AColor <> NoColorSelected) then
    begin
      Items.Objects[0] := TObject(AColor);
      I := 0;
    end;
    ItemIndex := I;
  end;
  FSelectedColor := AColor;
end;

procedure TCustomColorComboBox.SetStyle(AStyle: TColorComboBoxStyle);
begin
  if AStyle <> Style then
  begin
    FStyle := AStyle;
    Enabled := ([cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor] * FStyle) <> [];
    if (cbExtendedColors in FStyle) or (cbSystemColors in FStyle) then
      Exclude(FStyle, cbRussianColorNames);
    PopulateList;
    if (Items.Count > 0) and (ItemIndex = -1) then
      ItemIndex := 0;
  end;
end;

end.
