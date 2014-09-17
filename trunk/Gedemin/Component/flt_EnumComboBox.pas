{++

  Project COMPONENTS
  Copyright © 2002 by Golden Software

  Модуль

   flt_EnumComboBox.pas

  Описание

   Компонента для перечислений используется в фильтрах

  Автор

   JKL

  История

   ver    date       who     what

   1.00   26.07.02   JKL     Initial version

--}

unit flt_EnumComboBox;

interface

uses
  Classes, StdCtrls, CheckLst, Controls, IBDatabase, Windows, Messages,
  flt_EnumComboBoxList_unit;

type
  PEnumValue = ^TEnumValue;
  TEnumValue = Char;

  TPopupCheckList = class(TCheckListBox)
  private
    FTopNodeEnabled: Boolean;
//    FCloseUp: TCloseUp;

    function GetDropedDown: Boolean;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
  protected
    // Задание параметров окна
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;

    property IsDroppedDown: Boolean read GetDropedDown;
//    property CloseUp: TCloseUp read FCloseUp write FCloseUp;
    property TopNodeEnabled: Boolean read FTopNodeEnabled write FTopNodeEnabled;
  end;

type
  TfltEnumSetComboBox = class(TComboBox)
  private
    // Выпадающий список
    FPopupView: TEnumComboBoxList;
    // Выделеная запись
    FSelected: TStrings;
    // Флаг автоматической установки ширины выпадающего списка
    FAutoPopupWidth: Boolean;

    // Отлавливаем DROPDOWN
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    // При потере фокуса закрываем выпадающий список если он открыт
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
    procedure CNKeyDown(var Message: TMessage); message CN_KEYDOWN;
    function GetDroppedDown: Boolean;
    function GetEnumName(Index: Integer): String;
    function GetEnumValue(Index: Integer): TEnumValue;
    procedure QuickSort(L, R: Integer);
    procedure ExchangeItems(Index1, Index2: Integer);
    function GetSelected: String;
    procedure SetSelected(const Value: String);
    function GetSelectedName: String;
    function GetCount: Integer;
    function GetQuoteSelected: String;
    procedure SetQuoteSelected(const Value: String);
  protected
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure DropDown; override;
    procedure CloseUp(const AnResult: Boolean);
    procedure SelectedToString;
    procedure StringToSelected;
    procedure Sort;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddEnum(AnEnumValue: TEnumValue; AnEnumName: String): Integer;
    procedure Clear;
    procedure ChangeParams; virtual;

    property DroppedDown: Boolean read GetDroppedDown;
    property Count: Integer read GetCount;
    property EnumValue[Index: Integer]: TEnumValue read GetEnumValue;
    property EnumName[Index: Integer]: String read GetEnumName;
    property Selected: String read GetSelected write SetSelected;
    property QuoteSelected: String read GetQuoteSelected write SetQuoteSelected;
  published
    property AutoPopupWidth: Boolean read FAutoPopupWidth write FAutoPopupWidth;
  end;

  TfltDBEnumSetComboBox = class(TfltEnumSetComboBox)
  private
    FTransaction: TIBTransaction;
    FDatabase: TIBDatabase;
    FFieldName: String;
    FTableName: String;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetFieldName(const Value: String);
    procedure SetTableName(const Value: String);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ChangeParams; override;
  published
    property TableName: String read FTableName write SetTableName;
    property FieldName: String read FFieldName write SetFieldName;
    property Database: TIBDatabase read FDatabase write SetDatabase;
  end;

type
  TfltEnumComboBox = class(TComboBox)
  private
    function GetEnumName(Index: Integer): String;
    function GetEnumValue(Index: Integer): TEnumValue;
    function GetSelected: TEnumValue;
    procedure SetSelected(const Value: TEnumValue);
    procedure WMDropDown(var Message: TMessage); message CBN_DROPDOWN;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    function GetQuoteSelected: String;
    procedure SetQuoteSelected(const Value: String);
  protected
    procedure DestroyWindowHandle; override;
  public
    function AddEnum(AnEnumValue: TEnumValue; AnEnumName: String): Integer;
    procedure Clear;
    procedure ChangeParams; virtual;

    property EnumValue[Index: Integer]: TEnumValue read GetEnumValue;
    property EnumName[Index: Integer]: String read GetEnumName;
    property Selected: TEnumValue read GetSelected write SetSelected;
    property QuoteSelected: String read GetQuoteSelected write SetQuoteSelected;
  end;

  TfltDBEnumComboBox = class(TfltEnumComboBox)
  private
    FTransaction: TIBTransaction;
    FDatabase: TIBDatabase;
    FFieldName: String;
    FTableName: String;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetFieldName(const Value: String);
    procedure SetTableName(const Value: String);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ChangeParams; override;

  published
    property TableName: String read FTableName write SetTableName;
    property FieldName: String read FFieldName write SetFieldName;
    property Database: TIBDatabase read FDatabase write SetDatabase;
  end;

procedure Register;

implementation

uses
  Forms, SysUtils, at_Classes, IBSQL, ComCtrls;

{!! Менять знак разделения селектед НЕЛЬЗЯ. Используется в фильтрах. !!}
const
  cSpr = ',';

var
  gsCOMBOHOOK: HHOOK = 0;

procedure Register;
begin
  RegisterComponents('gsNew', [TfltEnumSetComboBox, TfltDBEnumSetComboBox,
   TfltEnumComboBox, TfltDBEnumComboBox]);
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
        if (Screen.ActiveControl <> nil) and (Screen.ActiveControl is TfltEnumSetComboBox) then
          with (Screen.ActiveControl as TfltEnumSetComboBox) do
            if FPopupView.IsDroppedDown then
            begin
              GetWindowRect(FPopupView.Handle, r1);
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
                with FPopupView.ScreenToClient(Point(pt.x, pt.y)) do
                  PostMessage(FPopupView.Handle, wParam, 0, MakeLParam(x, y));
            end;
      end;
    else
      r1 := r2;
    end;
  end;
end;

function SortEnumList(List: TListItems; Index1, Index2: Integer): Integer;
begin
  Result := AnsiCompareText(PEnumValue(List[Index1].Data)^,
                            PEnumValue(List[Index2].Data)^);
end;

{ TfltEnumSetComboBox }

procedure TfltEnumSetComboBox.CloseUp(const AnResult: Boolean);
begin
  // Если выбрали запись, то денлаем ее выделеной
  if AnResult then
  begin
    SelectedToString;
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
  if FPopupView.IsDroppedDown then
  begin
    SetWindowPos(FPopupView.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
     SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FPopupView.Visible := False;
//    Self.SetFocus;
  end;
end;

procedure TfltEnumSetComboBox.CNCommand(var Message: TWMCommand);
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

constructor TfltEnumSetComboBox.Create(AOwner: TComponent);
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    FPopupView := TEnumComboBoxList.Create(Self);
    FPopupView.Parent := Self;
    FPopupView.Visible := False;
    FPopupView.Height := 20;
    FPopupView.CloseUp := CloseUp;
    FSelected := TStringList.Create;
  end;
end;

procedure TfltEnumSetComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (ES_AUTOVSCROLL or ES_WANTRETURN) or
      WS_CLIPCHILDREN or ES_MULTILINE;
end;

procedure TfltEnumSetComboBox.CreateWnd;
begin
  inherited;

  if Assigned(FPopupView) then
    SetWindowPos(FPopupView.Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE);
end;

destructor TfltEnumSetComboBox.Destroy;
begin
  if Assigned(FSelected) then
    FreeAndNil(FSelected);

  inherited;

//  FPopupView освобождается автоматически
end;

procedure TfltEnumSetComboBox.DropDown;
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
      if FPopupView.clbView.Items.Count > 0 then
      begin
        for I := 0 to FPopupView.clbView.Items.Count - 1 do
        begin
          LTW := FPopupView.clbView.Canvas.TextWidth(
            FPopupView.clbView.Items[I].Caption);
          if LTempWidth < LTW then
            LTempWidth := LTW;
        end;
        LTempWidth := LTempWidth + GetSystemMetrics(SM_CXVSCROLL) + 6 + 20;
      end else
        LTempWidth := Width;
    end;

    // Нормируем ширину выпадающего списка, если она меньше ширины комбобокса
    if LTempWidth < Width then
      LTempWidth := Width;

    // Высота выпадающего списка
    if FPopupView.clbView.Items.Count > 0 then
      LTempCount := DropDownCount
    else
      LTempCount := 1;

    // Присваиваем выходящие значения
    Result.x := LTempWidth;
    Result.y := LTempCount * FPopupView.clbView.Canvas.TextExtent(' ').cy;
  end;
begin
  inherited;

  // Присваиваем хук на сообщения мыши
  if gsCOMBOHOOK = 0 then
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE , @gsComboHookProc, HINSTANCE, GetCurrentThreadID);
  // Присваиваем выделенную запись
  StringToSelected;
  // Присваиваем размеры выпадающего списка
  TempP := GetItemRect;
  FPopupView.Width := TempP.x;
  FPopupView.Height := TempP.y;
  // Координаты отображения выпадающего списка
  P := Point(0, Self.Height);
  P := ClientToScreen(P);
  if P.y + FPopupView.Height > GetSystemMetrics(SM_CYFULLSCREEN) then
    P.y := P.y - Self.Height - FPopupView.Height;
  // Активизируем выпадающий список
  SetWindowPos(FPopupView.Handle, {HWND_TOP} HWND_NOTOPMOST, P.x, P.y, TempP.x, TempP.y,
   SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FPopupView.Visible := True;
end;

function TfltEnumSetComboBox.GetDroppedDown: Boolean;
begin
  Result := FPopupView.Visible;
end;

procedure TfltEnumSetComboBox.SelectedToString;
var
  I: Integer;
begin
  FSelected.Clear;
  for I := 0 to FPopupView.clbView.Items.Count - 1 do
    if FPopupView.clbView.Items[I].Checked then
      FSelected.Add(TEnumValue(Pointer(FPopupView.clbView.Items[I].Data)^) +
       '=' + FPopupView.clbView.Items[I].Caption);

  Items.Clear;
  Items.Add(GetSelectedName);
  ItemIndex := 0;
end;

procedure TfltEnumSetComboBox.StringToSelected;
var
  I, J, J1: Integer;
  EV: TEnumValue;
  Flag: Boolean;
begin
  // !!! Сортировка должна быть сохранена
  J := 0;
  (FSelected as TStringList).Sort;
  for I := 0 to FSelected.Count - 1 do
  begin
    if FSelected.Names[I] = '' then
      if FSelected.Strings[I] = '' then
        EV := #0
      else
        EV := FSelected.Strings[I][1]
    else
      EV := FSelected.Names[I][1];
    Flag := False;
    J1 := J;
    while (J < FPopupView.clbView.Items.Count) and not Flag do
    begin
      if PEnumValue(FPopupView.clbView.Items[J].Data)^ = EV then
      begin
        FPopupView.clbView.Items[J].Checked := True;
        Flag := True;
      end else
        FPopupView.clbView.Items[J].Checked := False;

      Inc(J);
    end;
    if not Flag then J := J1;
  end;

  FPopupView.clbView.HandleNeeded;
  if FSelected.Count = 0 then
    for I := 0 to FPopupView.clbView.Items.Count - 1 do
      FPopupView.clbView.Items[I].Checked := False;
end;

procedure TfltEnumSetComboBox.WMKillFocus(var Message: TMessage);
begin
  inherited;
  // При потере фокуса закрываем выпадающий список если он открыт
  if DroppedDown then
    CloseUp(False);
end;

function TfltEnumSetComboBox.AddEnum(AnEnumValue: TEnumValue;
  AnEnumName: String): Integer;
var
  TP: ^TEnumValue;
  LI: TListItem;
begin
  New(TP);
  TP^ := AnEnumValue;
  LI := FPopupView.clbView.Items.Add;
  LI.Caption := AnEnumName;
  LI.Data := Pointer(TP);
  Sort;
  Result := -1;
end;

function TfltEnumSetComboBox.GetEnumName(Index: Integer): String;
begin
  Result := FPopupView.clbView.Items[Index].Caption;
end;

function TfltEnumSetComboBox.GetEnumValue(Index: Integer): TEnumValue;
begin
  Result := TEnumValue(Pointer(FPopupView.clbView.Items[Index].Data)^);
end;

procedure TfltEnumSetComboBox.Clear;
var
  TP: ^TEnumValue;
begin
  while FPopupView.clbView.Items.Count > 0 do
  begin
    TP := Pointer(FPopupView.clbView.Items[0].Data);
    Dispose(TP);
    FPopupView.clbView.Items.Delete(0);
  end;
end;

procedure TfltEnumSetComboBox.ExchangeItems(Index1, Index2: Integer);
var
  TempP: Pointer;
  TempS: String;
begin
  TempS := FPopupView.clbView.Items[Index1].Caption;
  FPopupView.clbView.Items[Index1].Caption := FPopupView.clbView.Items[Index2].Caption;
  FPopupView.clbView.Items[Index2].Caption := TempS;

  TempP := FPopupView.clbView.Items[Index1].Data;
  FPopupView.clbView.Items[Index1].Data := FPopupView.clbView.Items[Index2].Data;
  FPopupView.clbView.Items[Index2].Data := TempP;
end;

procedure TfltEnumSetComboBox.QuickSort(L, R: Integer);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SortEnumList(FPopupView.clbView.Items, I, P) < 0 do Inc(I);
      while SortEnumList(FPopupView.clbView.Items, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J);
    L := I;
  until I >= R;
end;

procedure TfltEnumSetComboBox.Sort;
begin
  if (FPopupView.clbView.Items.Count > 1) then
    QuickSort(0, FPopupView.clbView.Items.Count - 1);
end;

function TfltEnumSetComboBox.GetSelectedName: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FSelected.Count - 1 do
    Result := Result + FSelected.Values[FSelected.Names[I]] + ';';
end;

procedure TfltEnumSetComboBox.SetSelected(const Value: String);
const
  cSubst = '|';
var
  I: Integer;
  LVal: String;
begin
  if not Assigned(FSelected) then Exit;
  FSelected.Clear;
  LVal := Value;
  repeat
    I := Pos(cSpr, LVal);
    if (I = 0) and (Length(LVal) > 0) and (LVal[Length(LVal)] <> cSubst) then
      FSelected.Add(Value[Length(LVal)])
    else
      if (I = 1) or ((I > 0) and (LVal[I - 1] = cSubst)) then
        FSelected.Add('')
      else
        if I > 0 then
          FSelected.Add(LVal[I - 1]);
    if I > 0 then
      LVal[I] := cSubst;
  until I = 0;

  ChangeParams;
end;

function TfltEnumSetComboBox.GetSelected: String;
var
  I: Integer;
begin
  {!! Алгоритм менять нельзя }
  Result := '';
  for I := 0 to FSelected.Count - 1 do
    Result := Result + FSelected.Names[I] + cSpr;
  if Length(Result) > 0 then
    Delete(Result, Length(Result), 1);
end;

procedure TfltEnumSetComboBox.ChangeParams;
begin

end;

procedure TfltEnumSetComboBox.CNKeyDown(var Message: TMessage);
begin
  if DroppedDown then
  begin
    case TWMKeyDown(Message).CharCode of
      VK_TAB:;
      VK_UP, VK_DOWN, VK_SPACE:
        SendMessage(FPopupView.clbView.Handle, WM_KEYDOWN, TWMKeyDown(Message).CharCode, 0);
      VK_RETURN:
        CloseUp(True);
      VK_ESCAPE:
        CloseUp(False);
    end;
    TWMKeyDown(Message).Result := 1;
  end else
    inherited;
end;

function TfltEnumSetComboBox.GetCount: Integer;
begin
  Result := FPopupView.clbView.Items.Count;
end;

function TfltEnumSetComboBox.GetQuoteSelected: String;
var
  I: Integer;
begin
  {!! Алгоритм менять нельзя }
  Result := '';
  for I := 0 to FSelected.Count - 1 do
    Result := Result + '''' + FSelected.Names[I] + '''' + cSpr;
  if Length(Result) > 0 then
    Delete(Result, Length(Result), 1);
end;

procedure TfltEnumSetComboBox.SetQuoteSelected(const Value: String);
var
  I: Integer;
  TS: String;
begin
  TS := Value;
  I := Pos('''', TS);
  while I > 0 do
  begin
    Delete(TS, I, 1);
    I := Pos('''', TS);
  end;
  Selected := TS;
end;

procedure TfltEnumSetComboBox.DestroyWindowHandle;
begin
  if Assigned(FPopupView) and (csDestroying in ComponentState) then
    Clear;

  inherited;
end;

{ TPopupCheckList }

constructor TPopupCheckList.Create(AOwner: TComponent);
begin
  inherited;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Height := 100;
end;

procedure TPopupCheckList.CreateParams(var Params: TCreateParams);
begin
  inherited;

  with Params do
  begin
    Style := WS_POPUPWINDOW or WS_BORDER or WS_VSCROLL;
    ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

function TPopupCheckList.GetDropedDown: Boolean;
begin
  Result := Visible;
end;

procedure TPopupCheckList.WMMouseActivate(var Message: TWMMouseActivate);
begin
  // Если нажимаем на скролбокс, то не обрубаем дальнейшую обработку сообщения
  // в противном случае обрубаем
  if Message.HitTestCode in [HTHSCROLL, HTVSCROLL] then
    Message.Result := MA_NOACTIVATE
  else
    Message.Result := MA_NOACTIVATEANDEAT;
end;

procedure TPopupCheckList.WMMouseMove(var Message: TWMMouseMove);
var
  I: Integer;
begin
  I := ItemAtPos(Point(Message.XPos, Message.YPos), False);
  // Верхний уровень для выделения не доступен при соответствующем флаге
  if I > -1 then
 //   Selected[I] := True;
end;

{ TfltDBEnumSetComboBox }

procedure TfltDBEnumSetComboBox.ChangeParams;
var
  LIBSQL: TIBSQL;
  LField: TatField;
  LRelationField: TatRelationField;
  I: Integer;
begin
  if not ((FDatabase <> nil) and FDatabase.Connected) or (csDesigning in ComponentState) then Exit;
  if (Trim(FTableName) <> '') and (Trim(FFieldName) <> '') then
  begin
    Clear;
    if Assigned(atDatabase) then
    begin
      LRelationField := atDataBase.FindRelationField(FTableName, FFieldName);
      if Assigned(LRelationField) then
      begin
        LField := LRelationField.Field;
        if LField <> nil then
          for I := 0 to Length(LField.Numerations) - 1 do
            AddEnum(LField.Numerations[I].Value[1], LField.Numerations[I].Name);
      end;
    end;
    if Count = 0 then
    begin
      LIBSQL := TIBSQL.Create(nil);
      try
        if not FTransaction.InTransaction then
          FTransaction.StartTransaction;
        LIBSQL.Database := FDatabase;
        LIBSQL.Transaction := FTransaction;
        LIBSQL.SQL.Text := Format('SELECT DISTINCT %s FROM %s ORDER BY 1',
         [FFieldName, FTableName]);
        LIBSQL.ExecQuery;
        while not LIBSQL.Eof do
        begin
          AddEnum(LIBSQL.Fields[0].AsString[1], LIBSQL.Fields[0].AsString);

          LIBSQL.Next;
        end;

        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        LIBSQL.Free;
      end;
    end;

    StringToSelected;
    SelectedToString;
  end;
end;

constructor TfltDBEnumSetComboBox.Create(AOwner: TComponent);
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    FTransaction := TIBTransaction.Create(nil);
  end;
end;

destructor TfltDBEnumSetComboBox.Destroy;
begin
  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);

  inherited;
end;

procedure TfltDBEnumSetComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FDatabase) then
    FDatabase := nil;
end;

procedure TfltDBEnumSetComboBox.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
    if Assigned(FTransaction) then
      FTransaction.DefaultDatabase := FDatabase;
    ChangeParams;
  end;
end;

procedure TfltDBEnumSetComboBox.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;
    ChangeParams;
  end;
end;

procedure TfltDBEnumSetComboBox.SetTableName(const Value: String);
begin
  if FTableName <> Value then
  begin
    FTableName := Value;
    ChangeParams;
  end;
end;

{ TfltEnumComboBox }

function TfltEnumComboBox.AddEnum(AnEnumValue: TEnumValue;
  AnEnumName: String): Integer;
var
  TP: ^TEnumValue;
begin
  New(TP);
  TP^ := AnEnumValue;
  Result := Items.AddObject(AnEnumName, Pointer(TP));
end;

procedure TfltEnumComboBox.ChangeParams;
begin

end;

procedure TfltEnumComboBox.Clear;
var
  TP: ^TEnumValue;
begin
  while Items.Count > 0 do
  begin
    TP := Pointer(Items.Objects[0]);
    Dispose(TP);
    Items.Delete(0);
  end;
end;

procedure TfltEnumComboBox.CNCommand(var Message: TWMCommand);
//var
//  fRect: TRect;
//  ItemCount: Integer;
begin
(*  case Message.NotifyCode of
    CBN_DROPDOWN:
    begin
      begin
//        FFocusChanged := False;
//        DropDown;
//        AdjustDropDown;
//        if FFocusChanged then
        begin
//          PostMessage(Handle, WM_CANCELMODE, 0, 0);
//          if not FIsFocused then
//            PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        end;
      end;
//      inherited;
  ItemCount := Items.Count;
  if ItemCount > DropDownCount then ItemCount := DropDownCount;
  if ItemCount < 1 then ItemCount := 1;
//  DroppingDown := True;
  try
    SetWindowPos(Handle, 0, 0, 0, Width + 100, ItemHeight * ItemCount +
      Height + 2, SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_NOREDRAW +
      SWP_HIDEWINDOW);
  finally
//    FDroppingDown := False;
  end;
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE +
    SWP_NOZORDER + SWP_NOACTIVATE + SWP_NOREDRAW + SWP_SHOWWINDOW);

  Width := Width - 100;
//      if DroppedDown then
//      GetWindowRect(Handle, fRect);
//      SetWindowPos(Handle, 0, fRect.Left, fRect.Top, fRect.Right - fRect.Left + 50, fRect.Bottom - fRect.Top + 50,
//        SWP_NOMOVE + SWP_NOZORDER + SWP_NOACTIVATE + SWP_NOREDRAW +
//        SWP_HIDEWINDOW);
 //   SetWindowPos(ListHandle, {HWND_TOP} HWND_NOTOPMOST, fRect.Left, fRect.Top,
  //   fRect.Right - fRect.Left + 50, fRect.Bottom - fRect.Top + 50, SWP_NOACTIVATE or SWP_SHOWWINDOW);
    end;
  else *)
    inherited;
//  end;
end;

procedure TfltEnumComboBox.DestroyWindowHandle;
begin
  if (csDestroying in ComponentState) then
    Clear;

  inherited;
end;

function TfltEnumComboBox.GetEnumName(Index: Integer): String;
begin
  Result := Items[Index];
end;

function TfltEnumComboBox.GetEnumValue(Index: Integer): TEnumValue;
begin
  Result := PEnumValue(Items.Objects[Index])^;
end;

function TfltEnumComboBox.GetQuoteSelected: String;
begin
  if ItemIndex > -1 then
    Result := '''' + PEnumValue(Items.Objects[ItemIndex])^ + ''''
  else
    Result := '';
end;

function TfltEnumComboBox.GetSelected: TEnumValue;
begin
  if ItemIndex > -1 then
    Result := PEnumValue(Items.Objects[ItemIndex])^
  else
    Result := #0;
end;

procedure TfltEnumComboBox.SetQuoteSelected(const Value: String);
var
  I: Integer;
  TS: String;
begin
  TS := Value;
  I := Pos('''', TS);
  while I > 0 do
  begin
    Delete(TS, I, 1);
    I := Pos('''', TS);
  end;
  if TS > '' then
    Selected := TS[1];
end;

procedure TfltEnumComboBox.SetSelected(const Value: TEnumValue);
var
  I: Integer;
begin
  ChangeParams;
  
  for I := 0 to Items.Count - 1 do
    if PEnumValue(Items.Objects[I])^ = Value then
    begin
      ItemIndex := I;
      Break;
    end;
end;

procedure TfltEnumComboBox.WMDropDown(var Message: TMessage);
//var
//  fRect: TRect;
begin
  inherited;

//  if DroppedDown then
(*  begin
    GetWindowRect(ListHandle, fRect);
    SetWindowPos(ListHandle, {HWND_TOP} HWND_NOTOPMOST, fRect.Left, fRect.Top,
     fRect.Right - fRect.Left + 50, fRect.Bottom - fRect.Top + 50, SWP_NOACTIVATE or SWP_SHOWWINDOW);
  end;*)
end;

{ TfltDBEnumComboBox }

procedure TfltDBEnumComboBox.ChangeParams;
var
  LIBSQL: TIBSQL;
  LField: TatField;
  LRelationField: TatRelationField;
  I: Integer;
  S: String;
begin
  if not ((FDatabase <> nil) and FDatabase.Connected) or (csDesigning in ComponentState) then Exit;
  if (Trim(FTableName) <> '') and (Trim(FFieldName) <> '') then
  begin
    Clear;
    if Assigned(atDatabase) then
    begin
      LRelationField := atDataBase.FindRelationField(FTableName, FFieldName);
      if Assigned(LRelationField) then
      begin
        LField := LRelationField.Field;
        if LField <> nil then
          for I := 0 to Length(LField.Numerations) - 1 do
            AddEnum(LField.Numerations[I].Value[1], LField.Numerations[I].Name);
      end;
    end;
    if Items.Count = 0 then
    begin
      LIBSQL := TIBSQL.Create(nil);
      try
        if not FTransaction.InTransaction then
          FTransaction.StartTransaction;
        LIBSQL.Database := FDatabase;
        LIBSQL.Transaction := FTransaction;
        LIBSQL.SQL.Text := Format('SELECT DISTINCT %s FROM %s ORDER BY 1',
         [FFieldName, FTableName]);
        LIBSQL.ExecQuery;
        while not LIBSQL.Eof do
        begin
          if LIBSQL.Fields[0].AsString > '' then
            S := Copy(LIBSQL.Fields[0].AsString, 1, 1);
          if S > '' then
            AddEnum(S[1], LIBSQL.Fields[0].AsString);

          LIBSQL.Next;
        end;

        if FTransaction.InTransaction then
          FTransaction.Commit;
      finally
        LIBSQL.Free;
      end;
    end;
  end;
end;

constructor TfltDBEnumComboBox.Create(AOwner: TComponent);
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    FTransaction := TIBTransaction.Create(nil);
  end;
end;

destructor TfltDBEnumComboBox.Destroy;
begin
  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);

  inherited;
end;

procedure TfltDBEnumComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if (Operation = opRemove) and (AComponent = FDatabase) then
    FDatabase := nil;
end;

procedure TfltDBEnumComboBox.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
    if Assigned(FTransaction) then
      FTransaction.DefaultDatabase := FDatabase;
    ChangeParams;
  end;
end;

procedure TfltDBEnumComboBox.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;
    ChangeParams;
  end;
end;

procedure TfltDBEnumComboBox.SetTableName(const Value: String);
begin
  if FTableName <> Value then
  begin
    FTableName := Value;
    ChangeParams;
  end;
end;

end.

