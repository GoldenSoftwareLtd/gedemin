// ShlTanya, 11.02.2019

unit gsComboElements;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls;

type
  TOnDropDown = procedure(Sender: TObject) of object;
  TOnCloseUp = procedure(Sender: TObject; AnIndex: Integer) of object;
  TCloseUp = procedure(const AnResult: Boolean) of object;

type
  TgsPopupCustomBox = class(TCustomListBox)
  protected
    FCloseUp: TCloseUp;

    function GetDropedDown: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    property IsDropedDown: Boolean read GetDropedDown;
    property CloseUp: TCloseUp read FCloseUp write FCloseUp;

    constructor Create(AOwner: TComponent); override;
  end;

type
  TgsComboButton = class(TButton)
  private
    FComboList: TgsPopupCustomBox;
    FItemIndex: Integer;
    FOnDropDown: TOnDropDown;
    FOnCloseUp: TOnCloseUp;
    FDropDownCount: Integer;
    FDropDownWidth: Integer;

    procedure SetDropDownCount(const AnDropDownCount: Integer);
    function GetItems: TStrings;
    procedure SetItems(Source: TStrings);
    procedure DropDown;
    procedure CloseUp(const AnResult: Boolean);
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMKeyDown(var Message: TMessage); message WM_KEYDOWN;
  protected
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Click; override;
  published
    property OnDropDown: TOnDropDown read FOnDropDown write FOnDropDown;
    property OnCloseUp: TOnCloseUp read FOnCloseUp write FOnCloseUp;
    property Items: TStrings read GetItems write SetItems;
    property DropDownCount: Integer read FDropDownCount write SetDropDownCount default 8;
    property DropDownWidth: Integer read FDropDownWidth write FDropDownWidth default 0;
  end;

function gsThisThat(const Clause: Boolean; TrueVal, FalseVal: Integer): Integer;

procedure Register;

implementation

var
  gsCOMBOHOOK: HHOOK = 0;

function gsThisThat(const Clause: Boolean; TrueVal, FalseVal: Integer): Integer;
begin
  if Clause then result := TrueVal else Result := FalseVal;
end;

function gsComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  r1, r2: TRect;
begin
  result := CallNextHookEx(gsCOMBOHOOK, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN:
      begin
        if (Screen.ActiveControl <> nil) and (Screen.ActiveControl is TgsComboButton) then
          with (Screen.ActiveControl as TgsComboButton) do
            if FComboList.IsDropedDown then
            begin
              GetWindowRect(FComboList.Handle, r1);
              if (wParam = WM_LBUTTONDOWN) or (wParam = WM_NCLBUTTONDOWN) then
              begin
                GetWindowRect(Handle, r2);
                if (not PtInRect(r1, pt)) and (not PtInRect(r2, pt)) then
                  CloseUp(False);
              end;
            end;
      end;
      WM_MOUSEMOVE:;
    else
      r1 := r2;
    end;
  end;
end;

constructor TgsPopupCustomBox.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csNoDesignVisible, csReflector, csReplicatable];
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Height := 100;
end;

function TgsPopupCustomBox.GetDropedDown: Boolean;
begin
  Result := Visible;
end;

procedure TgsPopupCustomBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER or WS_VSCROLL;
    ExStyle := WS_EX_TOOLWINDOW;
    {$ifdef fcDelphi4up}
    AddBiDiModeExStyle(ExStyle);
    {$endif}
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TgsComboButton.CreateWnd;
begin
  inherited;

  FComboList.Parent := Self;
end;

procedure TgsComboButton.SetDropDownCount(const AnDropDownCount: Integer);
begin
  if AnDropDownCount < 1 then
    FDropDownCount := 1
  else
    FDropDownCount := AnDropDownCount;
end;

function TgsComboButton.GetItems: TStrings;
begin
  Result := FComboList.Items;
end;

procedure TgsComboButton.SetItems(Source: TStrings);
begin
  if Source <> nil then
    FComboList.Items.Assign(Source);
end;

procedure TgsComboButton.DropDown;
var
  P: TPoint;
  TempP: TPoint;

  function GetItemRect: TPoint;
  var
    Temp, I, J: Integer;
  begin
    J := gsThisThat(FDropDownCount < FComboList.Items.Count, FDropDownCount,
     FComboList.Items.Count);
    Temp := 0;
    if FComboList.Items.Count > 0 then
    begin
      for I := 0 to J - 1 do
        if Temp < FComboList.Canvas.TextWidth(FComboList.Items[I]) then
          Temp := FComboList.Canvas.TextWidth(FComboList.Items[I]);
      Temp := Temp + 20;
    end else
      Temp := Width;
    Result.x := gsThisThat(FDropDownWidth > 0, FDropDownWidth,
     gsThisThat(Temp > Width, Temp, Width));
    Result.y := gsThisThat(FDropDownCount < FComboList.Items.Count,
     FDropDownCount * FComboList.ItemHeight,
     gsThisThat(FComboList.Items.Count > 0,
      FComboList.ItemHeight * FComboList.Items.Count, FComboList.ItemHeight)) + FComboList.ItemHeight;
  end;
begin
  if gsCOMBOHOOK = 0 then
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE, @gsComboHookProc, HINSTANCE, GetCurrentThreadID);
  TempP := GetItemRect;
  FComboList.Width := TempP.x;
  FComboList.Height := TempP.y;
  P := Point(Self.Width - FComboList.Width, Self.Height);
  P := ClientToScreen(P);
  SetWindowPos(FComboList.Handle, HWND_TOP, P.x, P.y, TempP.x, TempP.y,
   SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FComboList.ItemIndex := FItemIndex;
  FComboList.Visible := True;
  if Assigned(FOnDropDown) then
    FOnDropDown(Self);
end;

procedure TgsComboButton.CloseUp(const AnResult: Boolean);
begin
  if AnResult then
  begin
    FItemIndex := FComboList.ItemIndex;
    if Assigned(FOnCloseUp) then
      FOnCloseUp(Self, FItemIndex);
  end;
  if FComboList.IsDropedDown then
  begin
    SetWindowPos(FComboList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
     SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FComboList.Visible := False;
    //Self.SetFocus;
  end;
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
end;

procedure TgsComboButton.Click;
begin
  inherited;

  if FComboList.IsDropedDown then
    CloseUp(False)
  else
    DropDown;
end;

procedure TgsComboButton.WMKillFocus(var Message: TWMKillFocus);
begin
  CloseUp(False);
end;

procedure TgsComboButton.WMKeyDown(var Message: TMessage);
begin
  if Message.WParam in [VK_UP, VK_DOWN, VK_RETURN, VK_ESCAPE] then
    PostMessage(FComboList.Handle, Message.Msg, Message.WParam, Message.LParam)
  else
    inherited;
end;

constructor TgsComboButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FComboList := TgsPopupCustomBox.Create(Self);
  FComboList.Visible := False;
  FComboList.CloseUp := CloseUp;
  FItemIndex := -1;
end;

destructor TgsComboButton.Destroy;
begin
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;

  FComboList.Free;

  inherited Destroy;
end;

procedure TgsPopupCustomBox.WMMouseActivate(var Message: TMessage);
begin
  inherited;

  Message.Result := MA_NOACTIVATE;
end;

procedure TgsPopupCustomBox.WMLButtonDown(var Message: TWMLButtonDown);
var
  I: Integer;
begin
  if Assigned(FCloseUp) then
  begin
    I := ItemAtPos(Point(Message.XPos, Message.YPos), True);
    if I > -1 then
      ItemIndex := I;
    FCloseUp(True);
  end;
end;

procedure TgsPopupCustomBox.WMMouseMove(var Message: TWMMouseMove);
var
  I: Integer;
begin
  I := ItemAtPos(Point(Message.XPos, Message.YPos), True);
  if I > -1 then
    ItemIndex := I;
end;

procedure TgsPopupCustomBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  if (ssAlt in Shift) then
  begin
    if Key in [VK_UP, VK_DOWN] then
      if IsDropedDown then
        FCloseUp(True);
  end else
    case Key of
      VK_RETURN:
      begin
        FCloseUp(True);
      end;
      VK_ESCAPE:
        if IsDropedDown then
          FCloseUp(False);
      VK_UP, VK_DOWN:
        if not IsDropedDown then
        begin
          FCloseUp(True);
        end;
    end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsComboButton]);
end;

end.
