// ShlTanya, 17.02.2019

unit gsComboTreeBox;

interface

uses
  StdCtrls, gsComboTreeBoxList_unit, Windows, Messages, Controls, Classes,
  ComCtrls, extctrls, ImgList;

type
  TComboTreeBox = class(TCustomComboBox)
  private
    // Выпадающий список
    FPopupTreeView: TgsComboTreeBoxList;
    // Выделеная запись
    FItemIndex: TTreeNode;
    // Количество отображаемых записей в выпадающем списке
    FDropDownCount: Integer;
    // Флаг автоматической установки ширины выпадающего списка
    FAutoPopupWidth: Boolean;

    FGraphicControl: TPaintBox;

    // Отлавливаем DROPDOWN
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    // При потере фокуса закрываем выпадающий список если он открыт
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    // Прорисовка
//    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;

    // Отображаем выпадающий список
    procedure AdjustDropDown;
    function GetDroppedDown: Boolean;
    function GetTreeNodes: TTreeNodes;
    function GetTopEnabled: Boolean;
    procedure SetTopEnabled(const Value: Boolean);
    procedure SetDropDownCount(const Value: Integer);
    function GetImages: TCustomImageList;
    procedure SetImages(const Value: TCustomImageList);
    function GetTreeView: TTreeView;
    procedure SetSelectedNode(const Value: TTreeNode);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure DropDown; override;
    procedure CloseUp(const AnResult: Boolean);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint(AnHandle: HWnd);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DroppedDown: Boolean read GetDroppedDown;
    property TreePopup: TTreeView read GetTreeView;
    property SelectedNode: TTreeNode read FItemIndex write SetSelectedNode;
    property Images: TCustomImageList read GetImages write SetImages;

    property Nodes: TTreeNodes read GetTreeNodes;
  published
    property DropDownCount: Integer read FDropDownCount write SetDropDownCount;
    property TopNodeEnabled: Boolean read GetTopEnabled write SetTopEnabled;
    property AutoPopupWidth: Boolean read FAutoPopupWidth write FAutoPopupWidth;

    property Style; {Must be published before Items}
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

uses
  SysUtils, Forms, Graphics;

var
  gsCOMBOHOOK: HHOOK = 0;

procedure Register;
begin
  RegisterComponents('gsNew', [TComboTreeBox]);
end;

function gsComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  r1, r2, r3: TRect;
begin
  result := CallNextHookEx(gsCOMBOHOOK, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      // Есди нажата кнопка
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_MOUSEMOVE, WM_LBUTTONUP:
      begin
        if (Screen.ActiveControl <> nil) and (Screen.ActiveControl is TComboTreeBox) then
          with (Screen.ActiveControl as TComboTreeBox) do
            if FPopupTreeView.IsDroppedDown then
            begin
              GetWindowRect(FPopupTreeView.Handle, r1);
              if {not}((wParam = WM_LBUTTONDOWN) or (wParam = WM_NCLBUTTONDOWN)) then
              begin
                GetWindowRect(Handle, r2);
                GetWindowRect(EditHandle, r3);
                if (not PtInRect(r1, pt)) and not (not PtInRect(r3, pt) and PtInRect(r2, pt)) then
                begin
                  CloseUp(False);
                  Exit;
                end;
              end; //else
              //if wParam = WM_MOUSEMOVE then
              if (PtInRect(r1, pt)) then
                with FPopupTreeView.ScreenToClient(Point(pt.x, pt.y)) do
                  PostMessage(FPopupTreeView.Handle, wParam, 0, MakeLParam(x, y));
            end;
      end;
//      WM_MOUSEMOVE:;
    else
      r1 := r2;
    end;
  end;
end;

{ TComboTreeBox }

procedure TComboTreeBox.AdjustDropDown;
var
  P: TPoint;
  TempP: TPoint;

  function GetItemRect: TPoint;
  var
    LTempCount, LTempWidth, I: Integer;
    LTW: Integer;
  begin
    LTempWidth := 0;
    // Если стаит автоматическая установка ширины, то вычисляем максимум
    // для отображаемых тринодов
    if FAutoPopupWidth then
    begin
      if TreePopup.Items.Count > 0 then
      begin
        for I := 0 to TreePopup.Items.Count - 1 do
        begin
          if TreePopup.Items[I].IsVisible then
          begin
            LTW := TreePopup.Canvas.TextWidth(
              TreePopup.Items[I].Text) +
              (TreePopup.Items[I].Level + 1) * TreePopup.Indent;
            if LTempWidth < LTW then
              LTempWidth := LTW;
          end;
        end;
        LTempWidth := LTempWidth + GetSystemMetrics(SM_CXVSCROLL) + 6 + 20;
      end else
        LTempWidth := Width;
    end;

    // Нормируем ширину выпадающего списка, если она меньше ширины комбобокса
    if LTempWidth < Width then
      LTempWidth := Width;

    // Высота выпадающего списка
    if TreePopup.Items.Count > 0 then
      LTempCount := FDropDownCount
    else
      LTempCount := 1;

    // Присваиваем выходящие значения
    Result.x := LTempWidth;
    Result.y := LTempCount * TreePopup.Canvas.TextExtent(' ').cy;
  end;
begin
  // Присваиваем хук на сообщения мыши
  if gsCOMBOHOOK = 0 then
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE , @gsComboHookProc, HINSTANCE, GetCurrentThreadID);
  // Присваиваем выделенную запись
  FPopupTreeView.tvTree.Selected := SelectedNode;
  // Присваиваем размеры выпадающего списка
  TempP := GetItemRect;
  FPopupTreeView.Width := TempP.x;
  FPopupTreeView.Height := TempP.y;
  // Координаты отображения выпадающего списка
  P := Point(0, Self.Height);
  P := ClientToScreen(P);
  if P.y + FPopupTreeView.Height > GetSystemMetrics(SM_CYFULLSCREEN) then
    P.y := P.y - Self.Height - FPopupTreeView.Height;
  // Активизируем выпадающий список
  SetWindowPos(FPopupTreeView.Handle, {HWND_TOP} HWND_NOTOPMOST, P.x, P.y, TempP.x, TempP.y,
   SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FPopupTreeView.Visible := True;
end;

procedure TComboTreeBox.CloseUp(const AnResult: Boolean);
begin
  // Если выбрали запись, то денлаем ее выделеной
  if AnResult then
  begin
    SelectedNode := FPopupTreeView.tvTree.Selected;
    // Теоретически здесь должен идти вызов события
//    if Assigned(FOnCloseUp) then
//      FOnCloseUp(Self, SelectedNode);
  end;
  // Освобождаем хук
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
  // Деактивизируем выпадающее окно
  if FPopupTreeView.IsDroppedDown then
  begin
    SetWindowPos(FPopupTreeView.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
     SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FPopupTreeView.Visible := False;
//    Self.SetFocus;
  end;
end;

procedure TComboTreeBox.CNCommand(var Message: TWMCommand);
begin
  case Message.NotifyCode of
    CBN_DROPDOWN:
    begin
      // При нажатиии кнопки в нашем случае всегда возникает событие DROPDOWN
      // В этом случае мы проверяем необходимое действие по свойству DroppedDown
      if DroppedDown then
        CloseUp(False)
      else
        DropDown;
      // Закрываем стандартный комбобокс
      PostMessage(Handle, WM_CANCELMODE, 0, 0);
    end;
  else
    inherited;
  end;
end;

constructor TComboTreeBox.Create(AOwner: TComponent);
begin
  inherited;

//  ControlStyle :=  ControlStyle - [csSetCaption] + [csOpaque];

  FPopupTreeView := TgsComboTreeBoxList.Create(nil{Self});
  FPopupTreeView.Visible := False;
  FPopupTreeView.CloseUp := CloseUp;
  FPopupTreeView.Parent := Self;

  SelectedNode := nil;
  FDropDownCount := 8;

//  FGraphicControl := TPaintBox.Create(Self);
//  FGraphicControl.Parent := Self;
end;

procedure TComboTreeBox.CreateWnd;
begin
  inherited;

  SetWindowPos(FPopupTreeView.Handle, {HWND_TOP} HWND_NOTOPMOST, 0, 0, 0, 0,
   SWP_NOACTIVATE);

//  Canvas.Handle := GetDC(Handle);
end;

procedure TComboTreeBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (ES_AUTOVSCROLL or ES_WANTRETURN) or
      WS_CLIPCHILDREN or ES_MULTILINE;
end;

destructor TComboTreeBox.Destroy;
begin
  // Освобождаем хук
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
  // Освобождаем выпадающий список
  FreeAndNil(FPopupTreeView);

  inherited;
end;

procedure TComboTreeBox.DestroyWindowHandle;
begin
//  ReleaseDC(Handle, Canvas.Handle);
//  Canvas.Handle := 0;

  inherited;
end;

procedure TComboTreeBox.DropDown;
begin
  // Вызов события OnDropDown
  inherited;

  // Отображаем выпадающий список
  AdjustDropDown;
end;

function TComboTreeBox.GetDroppedDown: Boolean;
begin
  Result := FPopupTreeView.IsDroppedDown;
end;

function TComboTreeBox.GetImages: TCustomImageList;
begin
  if Assigned(TreePopup) then
    Result := TreePopup.Images
  else
    REsult := nil;
end;

function TComboTreeBox.GetTopEnabled: Boolean;
begin
  Result := FPopupTreeView.TopNodeEnabled;
end;

function TComboTreeBox.GetTreeNodes: TTreeNodes;
begin
  if Assigned(FPopupTreeView) then
    Result := FPopupTreeView.tvTree.Items
  else
    Result := nil;
end;

function TComboTreeBox.GetTreeView: TTreeView;
begin
  if Assigned(FPopupTreeView) then
    Result := FPopupTreeView.tvTree
  else
    Result := nil;
end;

procedure TComboTreeBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  if (ssAlt in Shift) then
  begin
    if Key in [VK_UP, VK_DOWN] then
      if FPopupTreeView.IsDroppedDown then
        CloseUp(True);
  end else
    case Key of
      VK_RETURN:
      begin
        CloseUp(True);
      end;
      VK_ESCAPE:
        if FPopupTreeView.IsDroppedDown then
          CloseUp(False);
      VK_UP, VK_DOWN:
        if FPopupTreeView.IsDroppedDown then
        begin
          SendMessage(FPopupTreeView.tvTree.Handle, WM_KEYDOWN, Key, 0);
        end;
    end;
end;

procedure TComboTreeBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and Assigned(TreePopup) and (TreePopup.Images <> nil)
    and (AComponent = TreePopup.Images) then TreePopup.Images := nil;
end;

procedure TComboTreeBox.Paint(AnHandle: HWnd);
//var
//  PS: TPaintStruct;
//  LR: TRect;
begin
  FGraphicControl.Left := 0;
  FGraphicControl.Top := Height div 2;
  FGraphicControl.Width := Width;
  FGraphicControl.Height := Height;

  if AnHandle = 0 then
    Canvas.Handle := GetDC(Handle)
  else
    Canvas.Handle := AnHandle;
  try
    PaintWindow(FGraphicControl.Canvas.Handle);      //wm_erasebkgnd
         FGraphicControl.Canvas.TextOut(2, 2, 'HHHHH');
  finally
    if AnHandle = 0 then
    begin
      ReleaseDC(Handle, Canvas.Handle);
    end;
    Canvas.Handle := 0;
  end;

     Windows.Beep(1000, 10);
end;

procedure TComboTreeBox.SetDropDownCount(const Value: Integer);
begin
  if Value > 0 then
    FDropDownCount := Value
  else
    FDropDownCount := 1;
end;

procedure TComboTreeBox.SetImages(const Value: TCustomImageList);
begin
  if Assigned(TreePopup) then
    TreePopup.Images := Value;
end;

procedure TComboTreeBox.SetSelectedNode(const Value: TTreeNode);
begin
  FItemIndex := Value;
  Items.Clear;
  if Assigned(FItemIndex) then
  begin
    Items.Add(FItemIndex.Text);
    ItemIndex := 0;
  end else
    ItemIndex := -1;
  Change;
end;

procedure TComboTreeBox.SetTopEnabled(const Value: Boolean);
begin
  FPopupTreeView.TopNodeEnabled := Value;
end;

procedure TComboTreeBox.WMKillFocus(var Message: TMessage);
begin
  inherited;
  // При потере фокуса закрываем выпадающий список если он открыт
  if DroppedDown then
    CloseUp(False);
end;

//procedure TComboTreeBox.WMPaint(var Message: TWMPaint);
//var
{  LRect: TRect;
  DC: HDC;
  PS: TPaintStruct;
  r: TRect;}

//begin
(*  if (csPaintCopy in ControlState) then
  begin
     // 6/28/99 - Support unbound csPaintCopy }
      { if not editable with focus, need to do drawing to show proper focus }
      try
         if Canvas = nil then
         begin
//            Canvas := TControlCanvas.Create;
//            Canvas.Control := Self;
         end;

         if Message.DC = 0 then DC := BeginPaint(Handle, PS)
         else DC:= Message.DC;
         Canvas.Handle := DC;

        LRect.Left := 0;
        LRect.Right := 16;
        LRect.Top := 0;
        LRect.Bottom := 16;
        Canvas.FillRect(LRect);
        Canvas.TextOut(LRect.Right + 2, LRect.Top, Text);
{         if FDataLink.Field=nil then
            PaintToCanvas(FPaintCanvas, GetClientEditRect, True, False,
               Text)
         else
            PaintToCanvas(FPaintCanvas, GetClientEditRect, True, False,
               FDataLink.Field.asString);}

      finally
         Canvas.Handle := 0;
         if Message.DC = 0 then EndPaint(Handle, PS);
      end;                            wm_ctlcoloredit
  end
  else begin*)
//      SetRectRgn(Handle, 10, 2, 50, 15);
//      inherited;

//      if TForm(Parent).Icon.Handle = 0 then TForm(Parent).Icon.Handle := LoadIcon(0, IDI_APPLICATION);

//      SendMessage(Handle, WM_SETICON, 0, LoadIcon(0, IDI_APPLICATION));
//     TextOut(Canvas.Handle, 0, 0, 'HHH', 3);
//     if Canvas.Handle = 0 then
//     SetWindowText(Handle, 'd');
//     Paint(Message.DC);
(*     if Message.DC = 0 then
//       Canvas.Handle := BeginPaint(Handle, PS);
       Canvas.Handle := GetDC(Handle);
     try
//       PaintWindow(Canvas.Handle);
//       Canvas.TextOut(2, 2, 'HHHHH');
       TextOut(Canvas.Handle, 0, 0, 'HHH', 3);
     finally
       if Message.DC = 0 then
//         EndPaint(Handle, PS);
       ReleaseDC(Handle, Canvas.Handle);
       Canvas.Handle := 0;
     end;*)
//     Windows.Beep(1000, 1);

//     SetWindowText(Handle, 'HHH');
{      try
         if Message.DC = 0 then DC := BeginPaint(Handle, PS)
         else DC:= Message.DC;
         Canvas.Handle := DC;

        Canvas.Brush.Color := clgreen;
        LRect.Left := 0;
        LRect.Right := 16;
        LRect.Top := 0;
        LRect.Bottom := 16;
        Canvas.FillRect(LRect);
      finally
         Canvas.Handle := 0;
         if Message.DC = 0 then EndPaint(Handle, PS);
      end;}
//     Paint;
//  end;
//  r := FBtnParent.ClientRect;
//  InvalidateRect(FBtnParent.Handle, @r, False);
//end;

procedure TComboTreeBox.CNKeyDown(var Message: TWMKeyDown);
begin
  if (Message.CharCode <> VK_TAB) or not DroppedDown then
    inherited;
end;

end.
