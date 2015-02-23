unit SizePanel;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Types, Windows, Graphics, Forms,
  Messages;

type
  TSizePanelType = (ptRight, ptLeft);
  TButtonState = (bsFlat, bsMouseOver, bsPushed);
  TButtonStates = set of TButtonState;

  TSizePanel = class(TCustomPanel)
  private
    FPanelType: TSizePanelType;
    FButtonStates: TButtonStates;
    FOnButtonClick: TNotifyEvent;
    FShowCloseButton: Boolean;
    procedure SetPanelType(const Value: TSizePanelType);
    procedure SetOnButtonClick(const Value: TNotifyEvent);
    procedure SetShowCloseButton(const Value: Boolean);
    { Private declarations }
  protected
    { Protected declarations }

    function GetButtonRect: TRect;
    function GetSizeGrepRect: TRect;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property PanelType: TSizePanelType read FPanelType write SetPanelType;
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property UseDockManager default True;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Font;
    property Locked;
    property ParentBiDiMode;
    property ParentBackground;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write SetOnButtonClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Register;

implementation
var
  COMBOHOOK: HHOOK = 0;
  _PanelList: TList;
  _LBPressed: Boolean;
  _LastMousePos: TPoint;
  _Cursor: TCursor;
  _CursorChanged: Boolean;

function ComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  F: TCustomForm;
  I: Integer;
  Panel: TSizePanel;
  DeltaX, DeltaY: Integer;
  R: TRect;
begin
  Result := CallNextHookEx(COMBOHOOK, nCode, wParam, lParam);

  if nCode = HC_ACTION then
  begin
    with PMouseHookStruct(lParam)^ do
    begin
      case wParam of
        WM_LBUTTONDOWN:
        begin
          if _PanelList <> nil then
          begin
            for I := 0 to _PanelList.Count - 1 do
            begin
              Panel := TSizePanel(_PanelList[i]);
              F := GetParentForm(Panel);
              if (F <> nil) and (F = Screen.ActiveForm) and
                (GetForegroundWindow = F.Handle) then
              begin
                R := Panel.GetSizeGrepRect;
                R.TopLeft := Panel.ClientToScreen(R.TopLeft);
                R.BottomRight := Panel.ClientToScreen(R.BottomRight);
                if PtInRect(R, pt) then
                begin
                  _LBPressed := True;
                  _LastMousePos := pt;
                end;
                Result := 1;
                Exit;
              end;
            end;
          end;
        end;

        WM_LBUTTONUP:
        begin
          _LBPressed := False;
        end;

        WM_MOUSEMOVE:
        begin
          if _PanelList <> nil then
          begin
            if _LBPressed then
            begin
              for I := 0 to _PanelList.Count - 1 do
              begin
                Panel := TSizePanel(_PanelList[i]);
                F := GetParentForm(Panel);
                if (F <> nil) and (F = Screen.ActiveForm) and
                  (GetForegroundWindow = F.Handle) then
                begin
                  deltaX := pt.X - _LastMousePos.X;
                  DeltaY := pt.Y - _LastMousePos.Y;
                  if (DeltaX <> 0) or (DeltaY <> 0) then
                  begin
                    case Panel.PanelType of
                      ptRight:
                      begin
                        F.SetBounds(F.Left, F.Top, F.Width + DeltaX,
                          F.Height + DeltaY);
                      end;
                      ptLeft:
                      begin
                        F.SetBounds(F.Left + DeltaX, F.Top, F.Width - DeltaX,
                          F.Height + DeltaY);
                      end;
                    end;
                    Result := 1;
                  end;
                  _LastMousePos := pt;
                  Exit;
                end;
              end;
            end else
            begin
              for I := 0 to _PanelList.Count - 1 do
              begin
                Panel := TSizePanel(_PanelList[i]);
                F := GetParentForm(Panel);
                if (F <> nil) and (F = Screen.ActiveForm) and
                  (GetForegroundWindow = F.Handle) then
                begin
                  R := Panel.GetSizeGrepRect;
                  R.TopLeft := Panel.ClientToScreen(R.TopLeft);
                  R.BottomRight := Panel.ClientToScreen(R.BottomRight);

                  if PtInRect(R, pt) then
                  begin
                    if not _CursorChanged then
                    begin
                      _Cursor := Screen.Cursor;
                      case Panel.PanelType of
                        ptRight: Screen.Cursor := crSizeNWSE;
                        ptLeft: Screen.Cursor := crSizeNESW;
                      end;
                      _CursorChanged := True;
                    end;
                    Exit;
                  end;
                end;
                //
                if _CursorChanged then
                begin
                  Screen.Cursor := _Cursor;
                  _CursorChanged := False;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;


procedure Register;
begin
  RegisterComponents('XP Data Control', [TSizePanel]);
end;

{ TSizePanel }

constructor TSizePanel.Create(AOwner: TComponent);
begin
  inherited;
  FullRepaint := True;
  if _PanelList = nil then
    _PanelList := TList.Create;

  _PanelList.Add(Self);
  if _PanelList.Count = 1 then
  begin
    if COMBOHOOK = 0 then
      COMBOHOOK := SetWindowsHookEx(WH_MOUSE, @ComboHookProc, HINSTANCE, GetCurrentThreadID);
  end;
  FShowCloseButton := True;
end;

destructor TSizePanel.Destroy;
begin
  _PanelList.Extract(Self);
  if _PanelList.Count = 0 then
  begin
    if COMBOHOOK <> 0 then
    begin
      UnhookWindowsHookEx(COMBOHOOK);
      COMBOHOOK := 0;
    end;

    FreeAndNil(_PanelList);
  end;

  inherited;
end;

function TSizePanel.GetButtonRect: TRect;
const
  Size = 10;
var
  Delta: Integer;
begin
  Delta := (Height - Size) div 2;
  case FPanelType of
    ptRight: Result := Rect(Delta, Delta, Delta + size, Delta + Size);
    ptLeft: Result := Rect(Width - Delta - Size, Delta, Width - Delta,
      Delta + Size);
  end;
end;

function TSizePanel.GetSizeGrepRect: TRect;
const
  Size = 12;
  Delta = 2;
begin
  case FPanelType of
    ptRight: Result := Rect(Width - Size - Delta , Height - Size - Delta,
      Width - Delta, Height - Delta);
    ptLeft: Result := Rect(Delta, Height - Size - Delta, Size + Delta, Height - Delta);
  end;
end;

procedure TSizePanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  R: TRect;

begin
  if FShowCloseButton then
  begin
    R := GetButtonRect;
    if PtInRect(R, Point(X, Y)) then
    begin
      Include(FButtonStates, bsPushed);
    end;
    InvalidateRect(Handle, @R, False);
  end;  
end;

procedure TSizePanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
begin
  if FShowCloseButton then
  begin
    R := GetButtonRect;
    if PtInRect(R, Point(X, Y)) then
    begin
      if not (bsMouseOver in FButtonStates) then
      begin
        Include(FButtonStates, bsMouseOver);
        InvalidateRect(Handle, @R, False);
      end;
    end else
    begin
      if bsMouseOver in FButtonStates then
      begin
        Exclude(FButtonStates, bsMouseOver);
        InvalidateRect(Handle, @R, False);
      end;
    end;
  end;
end;

procedure TSizePanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  R: TRect;
begin
  if FShowCloseButton then
  begin
    Exclude(FButtonStates, bsPushed);

    R := GetButtonRect;
    if PtInRect(R, Point(X, Y)) then
    begin
      if Assigned(FOnButtonClick) then
        FOnButtonClick(Self);
      FButtonStates := [bsFlat];
    end;
  end;  
end;

procedure TSizePanel.Paint;
var
  R: TRect;
  Position: Integer;
const
  cDelta = 4;
  cSize = 12;
begin
  inherited;
  if FShowCloseButton then
  begin
    R := GetButtonRect;
    if bsMouseOver in FButtonStates then
    begin
      if bsPushed in FButtonStates then
      begin
        DrawFrameControl(Canvas.Handle, R, DFC_CAPTION, DFCS_PUSHED or DFCS_CAPTIONCLOSE);
      end else
      begin
        DrawFrameControl(Canvas.Handle, R, DFC_CAPTION, DFCS_CAPTIONCLOSE);
      end;
    end else
      DrawFrameControl(Canvas.Handle, R, DFC_CAPTION, DFCS_FLAT or DFCS_CAPTIONCLOSE);
  end;    

  R := GetSizeGrepRect;
  Position := cSize;
  case FPanelType of
  ptRight:
    begin
      repeat
        Canvas.Pen.Color := clBtnHighlight;
        Canvas.MoveTo(R.Left, R.Bottom);
        Canvas.LineTo(R.Right, R.Top);

        R.Left := R.Left + 1;
        R.Top := R.Top + 1;
        Canvas.Pen.Color := clBtnShadow;
        Canvas.MoveTo(R.Left, R.Bottom);
        Canvas.LineTo(R.Right, R.Top);

        R.Left := R.Left + 1;
        R.Top := R.Top + 1;
        Canvas.MoveTo(R.Left, R.Bottom);
        Canvas.LineTo(R.Right, R.Top);

        R.Left := R.Left + 2;
        R.Top := R.Top + 2;

        Dec(Position, cDelta);
      until Position <= 0;
    end;
  ptLeft:
    begin
      repeat
        Canvas.Pen.Color := clBtnHighlight;
        Canvas.MoveTo(R.Left, R.Top);
        Canvas.LineTo(R.Right, R.Bottom);

        R.Right := R.Right - 1;
        R.Top := R.Top + 1;
        Canvas.Pen.Color := clBtnShadow;
        Canvas.MoveTo(R.Left, R.Top);
        Canvas.LineTo(R.Right, R.Bottom);

        R.Right := R.Right - 1;
        R.Top := R.Top + 1;
        Canvas.MoveTo(R.Left, R.Top);
        Canvas.LineTo(R.Right, R.Bottom);

        R.Right := R.Right - 2;
        R.Top := R.Top + 2;

        Dec(Position, cDelta);
      until Position <= 0;
    end;
  end;
end;

procedure TSizePanel.SetOnButtonClick(const Value: TNotifyEvent);
begin
  FOnButtonClick := Value;
end;

procedure TSizePanel.SetPanelType(const Value: TSizePanelType);
begin
  if FPanelType <> Value then
  begin
    FPanelType := Value;
    Invalidate;
  end;  
end;

procedure TSizePanel.SetShowCloseButton(const Value: Boolean);
begin
  FShowCloseButton := Value;
end;

initialization
finalization
  FreeAndNil(_PanelList);
end.
