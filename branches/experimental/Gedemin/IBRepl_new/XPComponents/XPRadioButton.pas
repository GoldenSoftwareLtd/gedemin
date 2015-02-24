unit XPRadioButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TXPRadioButtonAlign = (taLeft, taRight);

  TXPRadioButton = class(TCustomControl)
  private
    { Private declarations }
    FUnPress: TBitmap;
    FPress: TBitmap;
    FBorder: TBitmap;
    FFlag: TBitmap;
    FDisabled: TBitmap;
    FDisFlag: TBitmap;
    FMouseIn: boolean;
    FMouseDown: boolean;
    FAlignment: TXPRadioButtonAlign;
    FMouseEnter: TNotifyEvent;
    FMouseLeave: TNotifyEvent;
    FFocused: boolean;
    FCanPaint: boolean;
    FChecked: boolean;
    procedure SetAlignment(NewAlignment: TXPRadioButtonAlign);
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFocusChanged(var Message: TMessage); message CM_FOCUSCHANGED;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure DrawFlag(X, Y: Integer; IsChecked, CheckEnabled, CheckMouseIn, Press: boolean);
    procedure RedrawFlag;
    function GetFocusRect: TRect;
    procedure UnCheck;
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure SetChecked(NewChecked: Boolean);
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Alignment: TXPRadioButtonAlign read FAlignment write SetAlignment;
    property Caption;
    property Checked: boolean read FChecked write SetChecked;
    property Color;
    property Enabled;
    property Font;
    property Hint;
    property Height default 17;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property TabOrder;
    property TabStop default True;
    property OnClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter: TNotifyEvent read FMouseEnter write FMouseEnter;
    property OnMouseLeave: TNotifyEvent read FMouseLeave write FMouseLeave;
    property Width default 113;
  end;

procedure Register;

implementation

{$R *.res}

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPRadioButton]);
end;

constructor TXPRadioButton.Create(AOwner: TComponent);
begin
  inherited;
  Width := 113;
  Height := 17;
  ControlStyle := [csSetCaption, csDoubleClicks, csCaptureMouse];
  FAlignment := taLeft;
  FMouseIn := False;
  FMouseDown := False;
  FChecked := False;
  FFocused := False;
  FCanPaint := True;
  TabStop := True;
  FUnPress := TBitmap.Create;
  FUnPress.LoadFromResourceName(hInstance, 'RD_UNPRESS');
  FUnPress.Transparent := True;
  FPress := TBitmap.Create;
  FPress.LoadFromResourceName(hInstance, 'RD_PRESS');
  FPress.Transparent := True;
  FBorder := TBitmap.Create;
  FBorder.LoadFromResourceName(hInstance, 'RD_BORDER');
  FBorder.Transparent := True;
  FFlag := TBitmap.Create;
  FFlag.LoadFromResourceName(hInstance, 'RD_FLAG');
  FFlag.Transparent := True;
  FDisabled := TBitmap.Create;
  FDisabled.LoadFromResourceName(hInstance, 'RD_DISABLED');
  FDisabled.Transparent := True;
  FDisFlag := TBitmap.Create;
  FDisFlag.LoadFromResourceName(hInstance, 'RD_DISFLAG');
  FDisFlag.Transparent := True;
end;

destructor TXPRadioButton.Destroy;
begin
  inherited;
  FUnPress.Free;
  FPress.Free;
  FBorder.Free;
  FFlag.Free;
  FDisabled.Free;
  FDisFlag.Free;
end;

procedure TXPRadioButton.SetAlignment(NewAlignment: TXPRadioButtonAlign);
begin
  if FAlignment <> NewAlignment then
  begin
    FAlignment := NewAlignment;
    Invalidate;
  end;
end;

procedure TXPRadioButton.SetChecked(NewChecked: Boolean);
begin
  if NewChecked <> FChecked then
    begin
      UnCheck;
      FChecked := NewChecked;
      RedrawFlag;
      if Assigned(OnClick) then
        OnClick(Self);
    end;
end;

procedure TXPRadioButton.WMSize(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TXPRadioButton.CMEnabledChanged(var Message: TMessage);
begin
  Inherited;
  RedrawFlag;
end;

procedure TXPRadioButton.CMTextChanged(var Message: TMessage);
begin
  Inherited;
  Invalidate;
end;

procedure TXPRadioButton.CMFocusChanged(var Message: TMessage);
begin
  Inherited;
  if Focused then
    begin
      Checked := True;
      UnCheck;
      if Assigned(OnClick) then
        OnClick(Self);
    end;
  Invalidate;
end;

procedure TXPRadioButton.MouseEnter(var Message: TMessage);
begin
  FMouseIn := True;
  RedrawFlag;
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
end;

procedure TXPRadioButton.MouseLeave(var Message: TMessage);
begin
  FMouseIn := False;
  RedrawFlag;
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
end;

procedure TXPRadioButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FCanPaint := False;
  Inherited;
  if (Shift = []) and (Key = VK_SPACE) and (FMouseDown = False) then
    begin
      FMouseDown := True;
      RedrawFlag;
    end;
  if Assigned(OnKeyDown) then
    OnKeyDown(Self, Key, Shift);
  FCanPaint := True;
end;

procedure TXPRadioButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FCanPaint := False;
  Inherited;
  if FMouseDown = True then
    begin
      FMouseDown := False;
      Checked := True;
      RedrawFlag;
      UnCheck;
      if Assigned(OnClick) then
        OnClick(Self);
    end;
  if Assigned(OnKeyUp) then
    OnKeyUp(Self, Key, Shift);
  FCanPaint := True;
end;

procedure TXPRadioButton.DrawFlag(X, Y: Integer; IsChecked, CheckEnabled, CheckMouseIn, Press: boolean);
begin
  Canvas.Lock;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(X, Y, X+FUnPress.Width, Y+FUnPress.Height));
  if IsChecked = True then
    begin
        if CheckEnabled = True then
          begin
            if Press = False then
              Canvas.Draw(X, Y, FUnPress);
            if Press = True then
              Canvas.Draw(X, Y, FPress);
            if (CheckMouseIn = True) and (Press = False) then
              Canvas.Draw(X+1, Y+1, FBorder);
            Canvas.Draw(X+4, Y+4, FFlag);
          end;
        if CheckEnabled = False then
          begin
            Canvas.Draw(X, Y, FDisabled);
            Canvas.Draw(X+4, Y+4, FDisFlag);
          end;
      end;
  if IsChecked = False then
      begin
        if CheckEnabled = True then
          begin
            if Press = False then
              Canvas.Draw(X, Y, FUnPress);
            if Press = True then
              Canvas.Draw(X, Y, FPress);
            if (CheckMouseIn = True) and (Press = False) then
              Canvas.Draw(X+1, Y+1, FBorder);
          end;
      if CheckEnabled = False then
        Canvas.Draw(X, Y, FDisabled);
      end;
  Canvas.Unlock;
end;

procedure TXPRadioButton.RedrawFlag;
begin
Canvas.Lock;
  if Alignment = taLeft then
    DrawFlag(0, (Height div 2) - (FUnPress.Height div 2), Checked,
      Enabled, FMouseIn, FMouseDown);
  if Alignment = taRight then
    DrawFlag(Width - FUnPress.Width,
      (Height div 2) - (FUnPress.Height div 2), Checked,
      Enabled, FMouseIn, FMouseDown);
Canvas.Unlock;
end;

function TXPRadioButton.GetFocusRect: TRect;
begin
if Alignment = taLeft then
  begin
  if not ((FUnPress.Width+4)+(Canvas.TextWidth(Caption)) > Width) and
     not ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+1 > Height) then
       begin
         Result := Rect(FUnPress.Width+4, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Canvas.TextWidth(Caption)+FUnPress.Width+6,
           (Height div 2) - (Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption));
         Exit;
       end;
  if (((FUnPress.Width+4)+(Canvas.TextWidth(Caption)+FUnPress.Width+6)) > Width) and
     ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+2 > Height) then
    begin
      Result := Rect(FUnPress.Width+4, 0, Width, Height);
      Exit;
    end;
  if (FUnPress.Width+4)+(Canvas.TextWidth(Caption)) > Width then
    begin
      Result := Rect(FUnPress.Width+4, (Height div 2) - (Canvas.TextHeight('W') div 2), Width,
        (Height div 2) - (Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption));
      Exit;
    end;
  if ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+2) > Height then
    begin
      Result := Rect(FUnPress.Width+4, 0, Canvas.TextWidth(Caption)+FUnPress.Width+6, Height);
      Exit;
    end;
end;
if Alignment = taRight then
  begin
  if not ((FUnPress.Width+4)+(Canvas.TextWidth(Caption)) > Width) and
     not ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+1 > Height) then
       begin
         Result := Rect(0, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Canvas.TextWidth(Caption)+4,
           (Height div 2) - (Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption));
         Exit;
       end;
  if (((FUnPress.Width+3)+(Canvas.TextWidth(Caption)+FUnPress.Width+6)) > Width) and
     ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+2 > Height) then
    begin
      Result := Rect(0, 0, Width - (FUnPress.Width + 4), Height);
      Exit;
    end;
  if (FUnPress.Width+3)+(Canvas.TextWidth(Caption)) > Width then
    begin
      Result := Rect(0, (Height div 2) - (Canvas.TextHeight('W') div 2), Width - (FUnPress.Width + 4),
        (Height div 2) - (Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption));
      Exit;
    end;
  if ((Height div 2)-(Canvas.TextHeight('W') div 2)+Canvas.TextHeight(Caption)+2) > Height then
    begin
      Result := Rect(0, 0, Canvas.TextWidth(Caption)+6, Height);
      Exit;
    end;
end;
end;

procedure TXPRadioButton.UnCheck;
var
  I: Integer;
  Sibling: TControl;
begin
  if Parent <> nil then
    with Parent do
      for I := 0 to ControlCount - 1 do
        begin
          Sibling := Controls[I];
          if (Sibling <> Self) and (Sibling is TXPRadioButton) then
            TXPRadioButton(Sibling).SetChecked(False);
        end;
end;

procedure TXPRadioButton.Paint;
var R: TRect;
begin
Canvas.Lock;
  if FCanPaint = False then
    Exit;
  inherited;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(GetClientRect);
  Canvas.Font := Font;
  if Alignment = taLeft then
    begin
      DrawFlag(0, (Height div 2) - (FUnPress.Height div 2), Checked, Enabled, FMouseIn, FMouseDown);
      R := Rect(FUnPress.Width + 5, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Width,
        (Height div 2) + (Canvas.TextHeight('W') div 2));
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), R, DT_LEFT);
    end;
  if Alignment = taRight then
    begin
      DrawFlag(Width - FUnPress.Width, (Height div 2) - (FUnPress.Height div 2), Checked, Enabled, FMouseIn, FMouseDown);
      R := Rect(2, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Width - (FUnPress.Width + 5),
        (Height div 2) + (Canvas.TextHeight('W') div 2));
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), R, DT_LEFT);
    end;
  if Focused then
  Canvas.DrawFocusRect(GetFocusRect);
Canvas.Unlock;
end;

procedure TXPRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FMouseDown = False) then
    begin
      SetFocus;
      FMouseDown := True;
      RedrawFlag;
    end;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TXPRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FMouseDown = True) then
    begin
      FMouseDown := False;
      Checked := True;
      RedrawFlag;
      UnCheck;
    end;
  if Assigned(OnMouseUp) then
    OnMouseUp(Self, Button, Shift, X, Y);
  if Assigned(OnClick) then
    OnClick(Self);
end;

end.
