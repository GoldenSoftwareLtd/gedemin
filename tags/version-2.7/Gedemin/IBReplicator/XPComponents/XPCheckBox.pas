unit XPCheckBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  DISABLED_BORDER = $00BFC8CF;
  ENABLED_BORDER = $0080501F;

type
  TXPCheckBoxState = (cbUnchecked, cbChecked, cbGrayed);

  TXPCheckBoxAlign = (taLeft, taRight);

  TXPCheckBox = class(TCustomControl)
  private
    { Private declarations }
    FUnPress: TBitmap;
    FPress: TBitmap;
    FBorder: TBitmap;
    FFlag: TBitmap;
    FGrayed: TBitmap;
    FDisabled: TBitmap;
    FDisFlag: TBitmap;
    FDisGrayed: TBitmap;
    FMouseIn: boolean;
    FMouseDown: boolean;
    FAlignment: TXPCheckBoxAlign;
    FAllowGrayed: Boolean;
    FState: TXPCheckBoxState;
    FMouseEnter: TNotifyEvent;
    FMouseLeave: TNotifyEvent;
    FFocused: boolean;
    FCanPaint: boolean;
    procedure SetAlignment(NewAlignment: TXPCheckBoxAlign);
    procedure SetState(NewState: TXPCheckBoxState);
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFocusChanged(var Message: TMessage); message CM_FOCUSCHANGED;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure DrawFlag(X, Y: Integer; CheckState: TXPCheckBoxState; CheckEnabled, CheckMouseIn, Press: boolean);
    procedure RedrawFlag;
    function GetFocusRect: TRect;
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Toggle; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    function GetChecked: Boolean;
    procedure SetChecked(NewChecked: Boolean);
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Alignment: TXPCheckBoxAlign read FAlignment write SetAlignment;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property Caption;
    property Checked: boolean read GetChecked write SetChecked;
    property Color;
    property Enabled;
    property Font;
    property Hint;
    property Height default 17;
    property PopupMenu;
    property ShowHint;
    property Visible;
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
    property State: TXPCheckBoxState read FState write SetState default cbUnchecked;
    property Width default 97;
  end;

procedure Register;

implementation

{$R *.res}

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPCheckBox]);
end;

constructor TXPCheckBox.Create(AOwner: TComponent);
var Bit: TBitmap;
begin
  inherited;
  Width := 97;
  Height := 17;
  ControlStyle := [csSetCaption, csDoubleClicks, csCaptureMouse];
  FAlignment := taLeft;
  FMouseIn := False;
  FMouseDown := False;
  FAllowGrayed := False;
  FState := cbUnchecked;
  FFocused := False;
  FCanPaint := True;
  TabStop := True;
  Bit := TBitmap.Create;
  FUnPress := TBitmap.Create;
  Bit.LoadFromResourceName(hInstance, 'CB_UNPRESS');
  FUnPress.Height := 13;
  FUnPress.Width := 13;
  FUnPress.Canvas.Draw(1, 1, Bit);
  FUnPress.Canvas.Brush.Color := ENABLED_BORDER;
  FUnPress.Canvas.FrameRect(Rect(0, 0, FUnPress.Width, FUnPress.Height));
  FPress := TBitmap.Create;
  Bit.LoadFromResourceName(hInstance, 'CB_PRESS');
  FPress.Height := 13;
  FPress.Width := 13;
  FPress.Canvas.Draw(1, 1, Bit);
  FPress.Canvas.Brush.Color := ENABLED_BORDER;
  FPress.Canvas.FrameRect(Rect(0, 0, FUnPress.Width, FUnPress.Height));
  FBorder := TBitmap.Create;
  FBorder.LoadFromResourceName(hInstance, 'CB_BORDER');
  FBorder.TransparentColor := clFuchsia;
  FBorder.Transparent := True;
  FFlag := TBitmap.Create;
  FFlag.LoadFromResourceName(hInstance, 'CB_FLAG');
  FFlag.Transparent := True;
  FGrayed := TBitmap.Create;
  FGrayed.LoadFromResourceName(hInstance, 'CB_GRAYED');
  FDisabled := TBitmap.Create;
  FDisabled.Height := 13;
  FDisabled.Width := 13;
  FDisabled.Canvas.Brush.Color := clWhite;
  FDisabled.Canvas.Pen.Color := DISABLED_BORDER;
  FDisabled.Canvas.Rectangle(0, 0, FDisabled.Width, FDisabled.Height);
  FDisFlag := TBitmap.Create;
  FDisFlag.LoadFromResourceName(hInstance, 'CB_DISFLAG');
  FDisFlag.Transparent := True;
  FDisGrayed := TBitmap.Create;
  FDisGrayed.LoadFromResourceName(hInstance, 'CB_DISGRAYED');
  Bit.Free;
end;

destructor TXPCheckBox.Destroy;
begin
  inherited;
  FUnPress.Free;
  FPress.Free;
  FBorder.Free;
  FFlag.Free;
  FGrayed.Free;
  FDisabled.Free;
  FDisFlag.Free;
  FDisGrayed.Free;
end;

procedure TXPCheckBox.Toggle;
begin
  case State of
    cbUnchecked:
      if AllowGrayed then State := cbGrayed else State := cbChecked;
    cbChecked: State := cbUnchecked;
    cbGrayed: State := cbChecked;
  end;
end;

function TXPCheckBox.GetChecked: Boolean;
begin
  Result := State = cbChecked;
end;

procedure TXPCheckBox.SetAlignment(NewAlignment: TXPCheckBoxAlign);
begin
  if FAlignment <> NewAlignment then
  begin
    FAlignment := NewAlignment;
    Invalidate;
  end;
end;

procedure TXPCheckBox.SetChecked(NewChecked: Boolean);
begin
  if NewChecked then State := cbChecked else State := cbUnchecked;
end;

procedure TXPCheckBox.SetState(NewState: TXPCheckBoxState);
begin
  if FState <> NewState then
  begin
    FState := NewState;
    RedrawFlag;
    if Assigned(OnClick) then
      OnClick(Self);
  end;
end;

procedure TXPCheckBox.WMSize(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TXPCheckBox.CMEnabledChanged(var Message: TMessage);
begin
  Inherited;
  RedrawFlag;
end;

procedure TXPCheckBox.CMTextChanged(var Message: TMessage);
begin
  Inherited;
  Invalidate;
end;

procedure TXPCheckBox.CMFocusChanged(var Message: TMessage);
begin
  Inherited;
  Invalidate;
end;

procedure TXPCheckBox.MouseEnter(var Message: TMessage);
begin
  FMouseIn := True;
  RedrawFlag;
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
end;

procedure TXPCheckBox.MouseLeave(var Message: TMessage);
begin
  FMouseIn := False;
  RedrawFlag;
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
end;

procedure TXPCheckBox.KeyDown(var Key: Word; Shift: TShiftState);
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

procedure TXPCheckBox.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FCanPaint := False;
  Inherited;
  if FMouseDown = True then
    begin
      FMouseDown := False;
      Toggle;
      RedrawFlag;
    end;
  if Assigned(OnKeyUp) then
    OnKeyUp(Self, Key, Shift);
  if Assigned(OnClick) then
    OnClick(Self);
  FCanPaint := True;
end;

procedure TXPCheckBox.DrawFlag(X, Y: Integer; CheckState: TXPCheckBoxState; CheckEnabled, CheckMouseIn, Press: boolean);
begin
  Canvas.Lock;
  Case CheckState of
    cbUnchecked:
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
    cbChecked:
      begin
        if CheckEnabled = True then
          begin
            if Press = False then
              Canvas.Draw(X, Y, FUnPress);
            if Press = True then
              Canvas.Draw(X, Y, FPress);
            if (CheckMouseIn = True) and (Press = False) then
              Canvas.Draw(X+1, Y+1, FBorder);
            Canvas.Draw(X+3, Y+3, FFlag);
          end;
        if CheckEnabled = False then
          begin
            Canvas.Draw(X, Y, FDisabled);
            Canvas.Draw(X+3, Y+3, FDisFlag);
          end;
      end;
    cbGrayed:
      begin
        if CheckEnabled = True then
          begin
            if Press = False then
              Canvas.Draw(X, Y, FUnPress);
            if Press = True then
              Canvas.Draw(X, Y, FPress);
            if (CheckMouseIn = True) and (Press = False) then
              Canvas.Draw(X+1, Y+1, FBorder);
            Canvas.Draw(X+3, Y+3, FGrayed);
          end;
        if CheckEnabled = False then
          begin
            Canvas.Draw(X, Y, FDisabled);
            Canvas.Draw(X+3, Y+3, FDisGrayed);
          end;
      end;
  end;
  Canvas.Unlock;
end;

procedure TXPCheckBox.RedrawFlag;
begin
Canvas.Lock;
  if Alignment = taLeft then
    DrawFlag(0, (Height div 2) - (FUnPress.Height div 2), State,
      Enabled, FMouseIn, FMouseDown);
  if Alignment = taRight then
    DrawFlag(Width - FUnPress.Width,
      (Height div 2) - (FUnPress.Height div 2), State,
      Enabled, FMouseIn, FMouseDown);
Canvas.Unlock;
end;

function TXPCheckBox.GetFocusRect: TRect;
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

procedure TXPCheckBox.Paint;
var R: TRect;
begin
  Canvas.Lock;
  if FCanPaint = False then
    Exit;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(GetClientRect);
  Canvas.Font := Font;
  if Alignment = taLeft then
  begin
    DrawFlag(0, (Height div 2) - (FUnPress.Height div 2), State, Enabled, FMouseIn, FMouseDown);
    R := Rect(FUnPress.Width + 5, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Width,
      (Height div 2) + (Canvas.TextHeight('W') div 2));
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), R, DT_LEFT);
  end;
  if Alignment = taRight then
  begin
    DrawFlag(Width - FUnPress.Width, (Height div 2) - (FUnPress.Height div 2), State, Enabled, FMouseIn, FMouseDown);
    R := Rect(2, ((Height div 2) - (Canvas.TextHeight('W') div 2))-1, Width - (FUnPress.Width + 5),
      (Height div 2) + (Canvas.TextHeight('W') div 2));
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), R, DT_LEFT);
  end;
  if Focused then
    Canvas.DrawFocusRect(GetFocusRect);
  Canvas.Unlock;
end;

procedure TXPCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FMouseDown = False) then
    begin
      FMouseDown := True;
        if not Focused then
          SetFocus
        else RedrawFlag;
    end;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TXPCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FMouseDown = True) then
    begin
      FMouseDown := False;
      Toggle;
      RedrawFlag;
    end;
  if Assigned(OnMouseUp) then
    OnMouseUp(Self, Button, Shift, X, Y);
  if Assigned(OnClick) then
    OnClick(Self);
end;

end.
