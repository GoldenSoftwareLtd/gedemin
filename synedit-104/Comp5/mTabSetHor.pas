
{

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    mTabSetHor.pas

  Abstract

    visual Component - Horizontal TabSet with flat interface (like Microsoft Money's component)

  Author

    Alex Tsobkalo (December-1998)

  Revisions history

    __-Dec-98  Alex               Initial Version.
    02-Iul-98  Alex               Added abillity to use Accel Chars.
    09-Aug-99  andreik            Russian only version!!! Problem with charsets!!!
}


unit mTabSetHor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

const
  defUnActiveColor       = $009C6331;
  defActiveColor         = $00E7F7F7;
  defFrameColor          = $00848284;
  defActiveFontColor     = $00000000;
  defUnActiveFontColor   = $00FFFFFF;

type
  TmTabSetHor = class(TCustomControl)
  private
    FTabs: TStringList;
    FActiveIndex: Integer;
    FHighlightIndex: Integer;
    FOnChange: TNotifyEvent;
    FActiveColor: TColor;
    FUnActiveColor: TColor;
    FActiveFontColor: TColor;
    FUnActiveFontColor: TColor;
    FFrameColor: TColor;
    FNotebook: TNotebook;

    procedure SetActiveIndex(const Value: Integer);
    procedure SetTabs(const Value: TStringList);
    procedure SetHighlightIndex(const Value: Integer);
    function GetCount: Integer;
    function GetActiveTab: String;
    procedure SetFrameColor(const Value: TColor);
    procedure SetActiveColor(const Value: TColor);
    procedure SetActiveFontColor(const Value: TColor);
    procedure SetUnActiveColor(const Value: TColor);
    procedure SetUnActiveFontColor(const Value: TColor);

  protected
    procedure Paint; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure DoOnChange;

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMDialogChar(var Message: TCMDialogChar);
      message CM_DIALOGCHAR;

    property Count: Integer read GetCount;
    property HighlightIndex: Integer read FHighlightIndex write SetHighlightIndex;

    function DeleteAccelChar(TabName: String): String;


  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    { standart properties and events }
    property Align;
    property Anchors;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor default True;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
//    property TabOrder;
//    property TabStop default True;
    property Visible;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    { my properties }
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex;
    property ActiveTab: String read GetActiveTab;
    property Tabs: TStringList read FTabs write SetTabs;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Notebook: TNotebook read FNotebook write FNotebook;

    property ActiveColor: TColor read FActiveColor write SetActiveColor
      default defActiveColor;
    property UnActiveColor: TColor read FUnActiveColor write SetUnActiveColor
      default defUnActiveColor;
    property ActiveFontColor: TColor read FActiveFontColor write SetActiveFontColor
      default defActiveFontColor;
    property UnActiveFontColor: TColor read FUnActiveFontColor write SetUnActiveFontColor
      default defUnActiveFontColor;
    property FrameColor: TColor read FFrameColor write SetFrameColor
      default defFrameColor;
  end;

implementation


//   CONSTRUCTOR
constructor TmTabSetHor.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ParentColor := True;
  Height := 20;
  Width := 140;

  FActiveIndex := 0;
  FHighlightIndex := -1;
  FUnActiveColor := defUnActiveColor;
  FActiveColor := defActiveColor;
  FActiveFontColor := defActiveFontColor;
  FUnActiveFontColor := defUnActiveFontColor;
  FFrameColor := defFrameColor;

  Font.CharSet := RUSSIAN_CHARSET;

  FTabs := TStringList.Create;
  Tabs.Add('First');
  Tabs.Add('Second');
end;


//   DESTRUCTOR
destructor TmTabSetHor.Destroy;
begin
  inherited Destroy;

  FTabs.Free;
end;


//   GET_ACTIVE_TAB
function TmTabSetHor.GetActiveTab: String;
begin
  Result := DeleteAccelChar(FTabs[ActiveIndex]);
end;


//   SET_ACTIVE_INDEX
procedure TmTabSetHor.SetActiveIndex(const Value: Integer);
begin
  if FActiveIndex <> Value then
  begin
    FActiveIndex := Value;
    DoOnChange;
    Invalidate;
  end;
end;


//   SET_TABS
procedure TmTabSetHor.SetTabs(const Value: TStringList);
begin
  FTabs.Assign(Value);
  FActiveIndex := 0;
  Invalidate;
end;


//   SET_HIGHLIGHT_INDEX
procedure TmTabSetHor.SetHighlightIndex(const Value: Integer);
begin
  if FHighlightIndex <> Value then
  begin
    FHighLightIndex := Value;
    Invalidate;
  end;
end;


//   GET_COUNT
function TmTabSetHor.GetCount: Integer;
begin
  Result := FTabs.Count;
end;


//   WM_L_BUTTON_DOWN
procedure TmTabSetHor.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  with Message do
    if (YPos >= 0) or (XPos >= 0) or (YPos <= Height) or (XPos <= Width) then
    begin
      ActiveIndex := Trunc(XPos / (Width / GetCount));
    end;
end;


//   PAINT
procedure TmTabSetHor.Paint;
var
  R: TRect;
  W: Integer;
  Ch: array[0..255] of Char;
  I: Integer;
begin
  with Canvas do begin
    Brush.Color := Color;
    Brush.Style := bsSolid;
    FillRect(ClientRect);

    if GetCount < 1 then Exit;

    W := Trunc(Width / GetCount);
    for I := 0 to GetCount - 1 do
    begin
      R.Left := W * I;
      R.Top := 5;
      R.Right := R.Left + W - 5;
      R.Bottom := Height;

      if I = FActiveIndex then
      begin
        Brush.Color := ActiveColor;
        FillRect(R);
        Font.Color := ActiveFontColor;

        Pen.Color := FFrameColor;
        Pen.Width := 1;
        MoveTo(R.Left, R.Bottom);
        LineTo(R.Left, R.Top);
        LineTo(R.Right, R.Top);
        LineTo(R.Right, R.Bottom);
      end
      else
      begin
        Brush.Color := FUnActiveColor;
        Font.Color := UnActiveFontColor;
        FillRect(R);
      end;

      Inc(R.Left, 8);
      Dec(R.Right, 3);
      // Font.CharSet := RUSSIAN_CHARSET; //!!!
      DrawText(Canvas.Handle, StrPCopy(Ch, FTabs[I]), Length(FTabs[I]), R,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    end;
  end;
end;


//   SET_FRAME_COLOR
procedure TmTabSetHor.SetFrameColor(const Value: TColor);
begin
  if FFrameColor <> Value then
  begin
    FFrameColor := Value;
    Invalidate;
  end;
end;


//   SET_ACTIVE_COLOR
procedure TmTabSetHor.SetActiveColor(const Value: TColor);
begin
  if FActiveColor <> Value then
  begin
    FActiveColor := Value;
    Invalidate;
  end;
end;


//   SET_ACTIVE_FONT_COLOR
procedure TmTabSetHor.SetActiveFontColor(const Value: TColor);
begin
  if FActiveFontColor <> Value then
  begin
    FActiveFontColor := Value;
    Invalidate;
  end;
end;


//   SET_UN_ACTIVE_COLOR
procedure TmTabSetHor.SetUnActiveColor(const Value: TColor);
begin
  if FUnActiveColor <> Value then
  begin
    FUnActiveColor := Value;
    Invalidate;
  end;
end;


//   SET_UN_ACTIVE_FONT_COLOR
procedure TmTabSetHor.SetUnActiveFontColor(const Value: TColor);
begin
  if FUnActiveFontColor <> Value then
  begin
    FUnActiveFontColor := Value;
    Invalidate;
  end;
end;


//   DO_ON_CHANGE
procedure TmTabSetHor.DoOnChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);

  if Assigned(FNotebook) then
    FNotebook.ActivePage := DeleteAccelChar(ActiveTab);
end;


//   NOTIFICATION
procedure TmTabSetHor.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FNotebook) then
    FNotebook := nil;
end;

//  CM_DIALOG_CHAR
procedure TmTabSetHor.CMDialogChar(var Message: TCMDialogChar);
var
  I: Integer;
  ThereIsAccel: Boolean;
begin
  ThereIsAccel := False;

  with Message do
    for I := 0 to FTabs.Count - 1 do
      if IsAccel(CharCode, FTabs[I]) and CanFocus then
    begin
      ActiveIndex := I;
      ThereIsAccel := True;
      Result := 1;
      break;
    end;

  if not ThereIsAccel then
    inherited;
end;


//   WM_SIZE
procedure TmTabSetHor.WMSize(var Message: TWMSize);
begin
  inherited;

  Invalidate;
end;


//   DLETE_ACCEL_CHAR
function TmTabSetHor.DeleteAccelChar(TabName: String): String;
var
  I, Len: Integer;
begin
  I := 1;
  Len := Length(TabName);
  
  while I <= Len do
  begin
    if TabName[I] = '&' then
    begin
      Delete(TabName, I, 1);
      Dec(Len);
    end;  
    Inc(I);
  end;

  Result := TabName;
end;

end.
