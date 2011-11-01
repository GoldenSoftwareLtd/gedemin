
{

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    mTabSetVer.pas

  Abstract

    visual Component - Vertical TabSet with flat interface (like Microsoft Money's component)

  Author

    Alex Tsobkalo (December-1998)

  Revisions history

    __-Dec-98  Alex               Initial Version.
    25-Dec-98  Dennis             OnChange должен вызываться по каждому изменению ActiveIndex!
    02-Iul-98  Alex               Added Focus property and abillity to use Accel Chars.
    09-Aug-99  andreik            Russian only version!!! Problem with charsets
}

unit mTabSetVer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

const
  defHighlightColor    = $009CDFF7;
  defFontColor         = $00D6E7E7;
  defFrameColor        = $008C969C;
  defFocusRectColor    = $00737173;
  defColor             = $00000000;

type
  TmTabSetVer = class(TCustomControl)
  private
    FTabs: TStringList;
    FActiveIndex: Integer;
    FHighlightIndex: Integer;
    FHighlightColor: TColor;
    FFrameColor: TColor;
    FOnChange: TNotifyEvent;
    FNotebook: TNotebook;
    FFocusRectColor: TColor;

    procedure SetActiveIndex(const Value: Integer);
    procedure SetTabs(const Value: TStringList);
    procedure SetHighlightIndex(const Value: Integer);
    function GetCount: Integer;
    function GetActiveTab: String;
    procedure SetHighlightColor(const Value: TColor);
    procedure SetFrameColor(const Value: TColor);
    procedure SetActiveTab(const Value: String);
    procedure SetFocusRectColor(const Value: TColor);

  protected
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMRButtonUP(var Message: TWMRButtonUp);
      message WM_RBUTTONUP;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
      message CM_FOCUSCHANGED;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMDialogChar(var Message: TCMDialogChar);
      message CM_DIALOGCHAR;

    procedure Paint; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure WndProc(var Message: TMessage); override;

    property Count: Integer read GetCount;
    property HighlightIndex: Integer read FHighlightIndex write SetHighlightIndex;

    procedure DoOnChange;
    procedure DrawActiveFrame(R: TRect);
    procedure DrawFocusRect(R: TRect);
    procedure DoOnArrowKeyDown(WParam: Integer);
    function DeleteAccelChar(TabName: String): String;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    { standart properties and events }
    property Align;
    property Anchors;
    property Color default defColor;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    { my properties }
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex
      default 0;
    property ActiveTab: String read GetActiveTab write SetActiveTab;
    property Tabs: TStringList read FTabs write SetTabs;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Notebook: TNotebook read FNotebook write FNotebook;

    property BevelOuter default bvNone;
    property BevelInner default bvNone;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor
      default defHighlightColor;
    property FrameColor: TColor read FFrameColor write SetFrameColor
      default defFrameColor;
    property FocusRectColor: TColor read FFocusRectColor write SetFocusRectColor
      default defFocusRectColor;
  end;

implementation

//   CREATE
constructor TmTabSetVer.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ParentColor := False;
  Color := defColor;
  TabStop := True;
  Height := 70;
  Width := 50;

  
  FActiveIndex := 0;
  FHighlightIndex := -1;
  Font.Color := defFontColor;
  Font.CharSet := RUSSIAN_CHARSET;
  FHighlightColor := defHighlightColor;
  FFrameColor := defFrameColor;
  FFocusRectColor := defFocusRectColor;

  FTabs := TStringList.Create;
  FTabs.Add('First');
  FTabs.Add('Second');
end;


//   DESTROY
destructor TmTabSetVer.Destroy;
begin
  inherited Destroy;

  FTabs.Free;
end;


//   GET_ACTIVE_TAB
function TmTabSetVer.GetActiveTab: String;
begin
  Result := DeleteAccelChar(FTabs[FActiveIndex]);
end;


//   SET_ACTIVE_TAB
procedure TmTabSetVer.SetActiveTab(const Value: String);
begin
  { empty procedure }
end;


//   GET_COUNT
function TmTabSetVer.GetCount: Integer;
begin
  Result := FTabs.Count;
end;


//   PAINT
procedure TmTabSetVer.Paint;
var
  I, H: Integer;
  R, Rt, Rf: TRect;
  Ch: array[0..255] of Char;
  OldMode: Integer;
begin
  // закрашиваем фон
  {Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);}

  if FTabs.Count < 1 then
    exit;

  // подготавливаем переменные
  H := Trunc(Height / FTabs.Count);
  R := Rect(0, 0, Width, H);

  for I := 0 to FTabs.Count - 1 do
  begin
    Canvas.Font := Font;
    //Canvas.Font.Charset := RUSSIAN_CHARSET; //!!!

    if FHighlightIndex = I then
      Canvas.Font.Color := HighlightColor;

    // пишем название закладки  
    Rt := R;
    Rt.Left := 16;

    OldMode := SetBkMode(Canvas.Handle, TRANSPARENT);

    DrawText(Canvas.Handle, StrPCopy(Ch, FTabs[I]), Length(FTabs[I]), Rt,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE);

    SetBkMode(Canvas.Handle, OldMode);

    // прорисовываем рамку активному элементу
    if I = FActiveIndex then
    begin
      DrawActiveFrame(R);
      Rf := R;
    end;

    R.Top := R.Bottom;
    R.Bottom := R.Top + H;
  end;

  // рисуем фокус
  if TabStop and Focused then
    DrawFocusRect(Rf);
end;


//   SET_ACTIVE_INDEX
procedure TmTabSetVer.SetActiveIndex(const Value: Integer);
begin
  if FActiveIndex <> Value then
  begin
    FActiveIndex := Value;
    DoOnChange;
    {Invalidate;}
    Repaint;
  end;
end;


//   SET_FRAME_ COLOR
procedure TmTabSetVer.SetFrameColor(const Value: TColor);
begin
  if FFrameColor <> Value then
  begin
    FFrameColor := Value;
    Invalidate;
  end;
end;


//   SET_HIGHLIGHT_COLOR
procedure TmTabSetVer.SetHighlightColor(const Value: TColor);
begin
  if FHighlightColor <> Value then
  begin
    FHighlightColor := Value;
    Invalidate;
  end;
end;


//   SET_HIGHLIGHT_INDEX
procedure TmTabSetVer.SetHighlightIndex(const Value: Integer);
begin
  if FHighlightIndex <> Value then
  begin
    FHighlightIndex := Value;
    Repaint;
    {Invalidate;}
  end;
end;


//   SET_TABS
procedure TmTabSetVer.SetTabs(const Value: TStringList);
begin
  FTabs.Assign(Value);
  FActiveIndex := 0;
  Invalidate;
end;


//   WM_L_BUTTON_DOWN
procedure TmTabSetVer.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  with Message do
    if (YPos >= 0) and (YPos < Height) and (XPos >= 0) and (XPos <= Width) then
    begin
      ActiveIndex := Trunc(Message.YPos / (Height / FTabs.Count));
    end;

  SetFocus;
end;


//   WM_R_BUTTON_UP
procedure TmTabSetVer.WMRButtonUp(var Message: TWMRButtonDown);
begin
  inherited;

  if Assigned(PopupMenu) then
  begin
    FHighLightIndex := -1;
    Invalidate;
  end;
end;


//   WM_MOUSE_MOVE
procedure TmTabSetVer.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;

  with Message do
    HighlightIndex := Trunc(Message.YPos / (Height / FTabs.Count));
end;


//   NOTIFICATION
procedure TmTabSetVer.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FNotebook) then
    FNotebook := nil;

  inherited;
end;


//   DO_ON_CHANGE
procedure TmTabSetVer.DoOnChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);

  if Assigned(FNotebook) then
    FNotebook.ActivePage := DeleteAccelChar(ActiveTab);
end;


//   SET_FOCUS_RECT_COLOR
procedure TmTabSetVer.SetFocusRectColor(const Value: TColor);
begin
  if FFocusRectColor <> Value then
  begin
    FFocusRectColor := Value;
    Invalidate
  end;
end;


//   DRAW_ACTIVE_FRAME
procedure TmTabSetVer.DrawActiveFrame(R: TRect);
begin
  Canvas.Pen.Color := FrameColor;
  Canvas.Pen.Style := psSolid;

  Canvas.MoveTo(R.Right - 5, R.Top);
  Canvas.LineTo(R.Right - 5, R.Top + 2);
  Canvas.LineTo(R.Left + 8, R.Top + 2);
  Canvas.LineTo(R.Left + 8, R.Bottom - 4);
  Canvas.LineTo(R.Right - 5, R.Bottom - 4);
  Canvas.LineTo(R.Right - 5, R.Bottom);
end;


//   DRAW_FOCUS_RECT
procedure TmTabSetVer.DrawFocusRect(R: TRect);
var
  X1, X2, Y1, Y2: Integer;
  VerCenter, TextHeight: Integer;
begin
  Canvas.Pen.Color := FFocusRectColor;
  Canvas.Brush.Style := bsClear;
  
  VerCenter := (R.Bottom - R.Top) div 2;
  TextHeight := Canvas.TextHeight(FTabs[FActiveIndex]);
  
  X1 := 13;
  X2 := X1 + Canvas.TextWidth(FTabs[FActiveIndex]) + 7;
  Y1 := R.Top + VerCenter - TextHeight div 2 - 1;
  Y2 := R.Top + VerCenter + TextHeight div 2 + 1;

  Canvas.Rectangle(X1, Y1, X2, Y2);
end;


//   WND_PROC
procedure TmTabSetVer.WndProc(var Message: TMessage);
begin
  if (Message.Msg = CN_KEYDOWN) and
    ((Message.WParam = VK_LEFT) or (Message.WParam = VK_RIGHT) or
     (Message.WParam = VK_DOWN) or (Message.WParam = VK_UP))
  then
    DoOnArrowKeyDown(Message.WParam)
  else
    inherited WndProc(Message);
end;


//   DO_ON_ARROW_KEY_DOWN
procedure TmTabSetVer.DoOnArrowKeyDown(WParam: Integer);
begin
  if not Focused then
    exit;

  case WParam of
    VK_DOWN, VK_RIGHT:
      begin
        if FActiveIndex = FTabs.Count - 1 then
          FActiveIndex := 0
        else
          Inc(FActiveIndex);
      end;

     VK_UP, VK_LEFT:
      begin
        if FActiveIndex = 0 then
          FActiveIndex := FTabs.Count - 1
        else
          Dec(FActiveIndex);
      end;
  end;

  DoOnChange;
  Repaint;
  {Invalidate;}
end;


//   CM_FOCUS_CHANGED
procedure TmTabSetVer.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  Invalidate;
end;


//   CM_MOUSE_LEAVE
procedure TmTabSetVer.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  HighlightIndex := -1;
end;


//   WM_SIZE
procedure TmTabSetVer.WMSize(var Message: TWMSize);
begin
  inherited;

  Invalidate;
end;


//  CM_DIALOG_CHAR
procedure TmTabSetVer.CMDialogChar(var Message: TCMDialogChar);
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
      if TabStop then SetFocus;
      Invalidate;
      break;
    end;

  if not ThereIsAccel then
    inherited;
end;


//   DELETE_ACCEL_CHAR
function TmTabSetVer.DeleteAccelChar(TabName: String): String;
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

