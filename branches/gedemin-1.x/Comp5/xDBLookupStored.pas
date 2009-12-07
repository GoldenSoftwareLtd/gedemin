
{++

  Copyright (c) 1998-2000 by Golden Software of Belarus

  Module

    xDBlookupStored.pas

  Abstract

    Component for choosing a value from database through
    lookup combo box.

  Author

    Michael Shoihet (01-03-96)

  Revisions history

  1.00    01-May-96    michael    Lookup in local ideology
  2.00    27-Feb-99    michael    Make lookup with StoredProc

}

{
  Отличительная особенность от старого Lookup, состоит в том что для
  поиска информации по первым символам должна быть создана и
  соответственно зарегистрирована StoredProc, которая и осуществляет
  поиск. Данная процедура должна иметь стандартные параметры:

    Входные параметры:
      ID   - для передачи ключа записи (может быть не задан)
      Text - для передачи набираемого текста
      Type - тип поиска по ключу или по тексту
    Выходные параметры:
      OUTID   - для возврата ключа найденной записи
      OUTTEXT - для возврата полной строки
      OK      - для возврата найдено ли какое-то значение

  Аналогично можно определить StoredProc для автоматического
  добавления новой записи.

  Для вывода таблицы к LookupSource должен быть подключен TQuery в котором
  должен быть параметр для передачи в него введенной строки.
  TQuery будет открываться только при выводе таблицы и туда будет
  передана введенная строка. Желательно, чтобы TQuery использовал введенную
  строку для ограничения выводимой информации.

  (При появлении выпадающего списка выбор только из списка)

  Определение поисковой процедуры:

    Параметры входящие:

      Direction: - направление
        1 - вперед
        2 - назад
        3 - с начала

      WholeFieldOnly: - поиск только целого значение или части поля
        1 - поиск целого поля
        0 - поиск части поля

      CaseSensitive: - значение регистра
        1 - регистр имеет значение
        0 - регистр не имеет значения

      Text - текст, поиск которого будет производиться

        ID - ключ начала поиска (позиции, с которой поиск будет производиться)
           ID может быть не задан, если поиск с начала.

    Параметры выходящие:
      FoundID - ключ позиции найденной записи
      TextField - текст поля найденной позиции
      IsFound: - найден ли текст вообще или нет
        1 - найдено
        0 - не найдено

}

unit xDBLookupStored;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBTables, DBGrids, StdCtrls, Menus,
  ExList, ExtCtrls, Buttons, dbsrch, dbctrls, mmDBGrid, mmDBSearch;

type
  TxDBLookupCombo2 = class;
  TBeforeSearchEvent = procedure (Sender: TObject; SearchStored: TStoredProc) of object;
  TBeforeViewEvent = procedure (Sender: TObject; ViewQuery: TQuery) of object;

  TxComboButton = class(TSpeedButton)
  private
    IsActive, IsPressed: Boolean;
    Is3D: Boolean;

    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AnOwner: TComponent); override;
  end;

  TxLookupGridStored = class(TmmDBGrid)
  private
    FCurrentRecord: Longint;

    function GetCurrentField: String;

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMVScroll(var Message: TWMVScroll);
      message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMHScroll);
      message WM_HSCROLL;
    procedure WMShowWindow(var Message: TWMShowWindow);
      message WM_SHOWWINDOW;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState);
      override;

  public
    isSqlSearch: Boolean;
    FirstValue: Integer;

    constructor Create(AnOwner: TComponent); override;

    function SetPosition(const Field: String; var FullStr: String): Boolean;

  end;

  TxDBLookupCombo2 = class(TCustomEdit)
  private
    FDataLink: TFieldDataLink;

    FLookupSource: TDataSource;
    FLookupQuery: TQuery;
    FLocateProc: TStoredProc;
    FSearchProc: TStoredProc;

    FLookupField: String;
    FLookupDisplay: String;

    FLookupStoredProc: String;
    FLookupViewStoredProc: String;
    FLookupAppendProc: String;
    FLookupSearchProc: String;
    FDatabaseName: String;

    FBeforeSearchEvent: TBeforeSearchEvent;
    FBeforeViewEvent: TBeforeViewEvent;

    FCheckValue: Boolean;

    FDrawButton: Boolean;
    FLookupGridWidth: Integer;
    FLookupGridHeight: Integer;
    FDBSearchField: TmmDBSearch;

    OldValue: Integer;
    IsKeyDown: Boolean;

    FLookupGrid: TxLookupGridStored;
    FBtnControl: TWinControl;
    FButton: TxComboButton;

    FNewName: Boolean;

    FLocalChange: Boolean;
    FPressButton: Boolean;
    FClearText: Boolean;

    OldOnCustomSearch: TOnCustomSearchEvent;

    procedure SetDataSource(aValue: TDataSource);
    procedure SetDataField(aValue: String);
    procedure SetDrawButton(aValue: Boolean);
    procedure CreateButton;

    function GetDataSource: TDataSource;
    function GetDataField: String;
    function GetMinHeight: Integer;

    procedure wmSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMCancelMode(var Message: TCMCancelMode);
      message CM_CANCELMODE;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure WMNCLButtonDown(var Message: TMessage);
      message WM_NCLBUTTONDOWN;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;
    procedure CMVisibleChanged(var Message: TMessage);
      message CM_VisibleCHANGED;
    procedure CMCTL3DChanged(var Message: TMessage);
      message CM_CTL3DCHANGED;
    procedure CMEnter(var Message: TMessage);
      message CM_ENTER;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure DataChange(Sender: TObject);

    procedure CreateView;
    procedure MoveGridWindow;
    procedure SetStateGrid;
    function SearchText(const Value: String; TypeSearch: Integer;
      var aID: Integer): String;
    procedure SetLookupStoredProc(const Value: string);
    procedure SetLookupSearchProc(const Value: string);
    procedure SetLookupViewStoredProc(const Value: string);
    procedure DoOnCustomSearch(Sender: TObject; Text: String; var Custom, Found: Boolean);

  protected
    procedure DoExit; override;
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;

  public
    IDValue: Integer;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property NewEnter: Boolean read FNewName;
    property Text;
    procedure ClearNewEnter;
    procedure SetNewText(const Value: String);
    procedure SetNewID(aIDValue: Integer);
    procedure Refresh;

    property LookupGrid: TxLookupGridStored read FLookupGrid;
    property LookupQuery: TQuery read FLookupQuery;

  published
    property ClearText: Boolean read FClearText write FClearText default True;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource
      write SetDataSource;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property LookupField: string read FLookupField write FLookupField;
    property LookupDisplay: string read FLookupDisplay write FLookupDisplay;
    property LookupStoredProc: string read FLookupStoredProc
      write SetLookupStoredProc;
    property LookupSearchProc: string read FLookupSearchProc write SetLookupSearchProc;
    property LookupViewStoredProc: string read FLookupViewStoredProc
      write SetLookupViewStoredProc;
    property LookupAppendProc: string read FLookupAppendProc
      write FLookupAppendProc;
    property CheckValue: Boolean read FCheckValue write FCheckValue
      default false;
    property DrawButton: Boolean read FDrawButton write SetDrawButton
      default true;
    property LookupGridWidth: Integer read FLookupGridWidth
      write FLookupGridWidth;
    property LookupGridHeight: Integer read FLookupGridHeight
      write FLookupGridHeight;

    property BeforeSearchEvent: TBeforeSearchEvent read FBeforeSearchEvent
      write FBeforeSearchEvent;

    property BeforeViewEvent: TBeforeViewEvent read FBeforeViewEvent
      write FBeforeViewEvent;

    property Enabled;
    property TabOrder;
    property ReadOnly;
    property Ctl3D;
    property Visible;
    property Font;
    property Color;

    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  gsMultilingualSupport;

{ TxLookupGridStored ---------------------------------------- }

constructor TxLookupGridStored.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  isSQLSearch:= false;
  FCurrentRecord:= -1;
  Visible:= false;
  Options:= inherited Options - [dgEditing, dgIndicator, dgTabs] +
     [dgAlwaysShowSelection];
  TabStop:= false;
  FAcquireFocus := False;
  BorderStyle:= bsSingle;
end;

function TxLookupGridStored.SetPosition(const Field: String;
  var FullStr: String): Boolean;
var
  S: String;
  Bookmark: TBookmark;
begin
  FullStr:= Field;
  Result:= False;

  if not Assigned(DataSource) or not Assigned(DataSource.DataSet) or
    not DataSource.DataSet.Active
  then
    exit;

  DataSource.DataSet.DisableControls;
  Bookmark:= DataSource.DataSet.GetBookmark;
  DataSource.DataSet.Locate(TxDBLookupCombo2(Parent).LookupDisplay,
    Field, [loCaseInsensitive, loPartialKey]);
  S := DataSource.DataSet.FieldByName(TxDBLookupCombo2(Parent).LookupDisplay).Text;
  if ANSICompareText(Field, copy(S, 1, Length(Field))) = 0 then
  begin
    FullStr := S;
    Result := True;
  end
  else
    DataSource.DataSet.GotoBookmark(Bookmark);
  DataSource.DataSet.FreeBookmark(Bookmark);
  DataSource.DataSet.EnableControls;
end;

procedure TxLookupGridStored.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.Style := CS_SAVEBITS;
  Params.Style:= ws_Popup or ws_Border;
end;

function TxLookupGridStored.GetCurrentField: String;
var
  OldActive: Longint;
begin
  Result:= '';

  if not Assigned(DataSource) or not Assigned(DataSource.DataSet) or
    not DataSource.DataSet.Active
  then
    exit;

  OldActive := DataLink.ActiveRecord;
  try
    DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
    Result:= DataSource.DataSet.FieldByName(
       TxDBLookupCombo2(Parent).LookupDisplay).Text
  finally
    DataLink.ActiveRecord := OldActive;
  end;
end;

procedure TxLookupGridStored.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  TxDBLookupCombo2(Parent).Text:= GetCurrentField;
  TxDBLookupCombo2(Parent).FNewName:= false;
  TxDBLookupCombo2(Parent).IDValue :=
    DataSource.DataSet.FieldByName(
       TxDBLookupCombo2(Parent).LookupField).AsInteger;
  FCurrentRecord:= Row;
  WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  TxDBLookupCombo2(Parent).Text:= GetCurrentField;
  TxDBLookupCombo2(Parent).FNewName:= false;
  TxDBLookupCombo2(Parent).IDValue :=
    DataSource.DataSet.FieldByName(
       TxDBLookupCombo2(Parent).LookupField).AsInteger;
  FCurrentRecord:= Row;
  WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if Visible then
    Visible:= false;
  WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  if Row <> FCurrentRecord then
    TxDBLookupCombo2(Parent).Text:= GetCurrentField;
  FCurrentRecord:= Row;
  WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
  WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMShowWindow(var Message: TWMShowWindow);
begin
  inherited;
  if Message.Show then
    WinProcs.SetFocus(TWinControl(Owner).HANDLE);
end;

procedure TxLookupGridStored.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  P: TPoint;
begin
  with Message do
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);

    if (WindowPos.flags = SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE) and (WindowPos.x = 0) and
      (WindowPos.y = 0) and (WindowPos.cx = 0) and (WindowPos.cy = 0) and Visible and
      ((P.X < 0) or (P.X > Width) or (P.Y < 0) or (P.Y > Height))
    then
      Visible := False;
  end;

  inherited;
end;

{ TxDBLookupCombo2 ------------------------------------- }

constructor TxDBLookupCombo2.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FNewName:= false;
  FLocalChange:= false;
  isKeyDown:= false;
  FClearText:= True;

  FDataLink:= TFieldDataLink.Create;
  FDataLink.OnDataChange := DataChange;

  FCheckValue:= False;
  FDrawButton:= True;

  FLookupSource := nil;
  FLookupQuery := nil;
  FLocateProc := nil;
  FSearchProc := nil;


  FBeforeSearchEvent := nil;
  FBeforeViewEvent := nil;

  OldOnCustomSearch := nil;

  FLookupField := '';
  FLookupDisplay := '';

  FLookupStoredProc := '';
  FLookupViewStoredProc := '';
  FLookupAppendProc := '';
  FLookupSearchProc := '';

  FPressButton:= false;

  if not (csDesigning in ComponentState) then
  begin
    FLookupGrid:= TxLookupGridStored.Create(Self);
    FLookupGrid.Parent:= Self;

    FDBSearchField:= TmmDBSearch.Create(Self);

    FLookupQuery := TQuery.Create(Self);

    FLocateProc := TStoredProc.Create(Self);

    FSearchProc := TStoredProc.Create(Self);
  end;

  FLookupGridWidth:= Width;
  FLookupGridHeight:= 168;

  IDValue := -1;


  CreateButton;
end;

destructor TxDBLookupCombo2.Destroy;
begin
  if FDBSearchField <> nil then
    FDBSearchField.OnCustomSearch := OldOnCustomSearch;

  if FLookupSource <> nil then
    FLookupSource.Free;
  if FLookupQuery <> nil then
    FLookupQuery.Free;
  if FLocateProc <> nil then
    FLocateProc.Free;
  if FSearchProc <> nil then
    FSearchProc.Free;  

  FDataLink.Free;
  FDataLink:= nil;

  FLookupGrid.Free;
  FLookupGrid:= nil;

  inherited Destroy;
end;

procedure TxDBLookupCombo2.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if (FDataLink <> nil) and (AComponent = DataSource) then
    begin
      DataField := '';
      DataSource := nil;
    end;
  end;
end;

procedure TxDBLookupCombo2.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TxDBLookupCombo2.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_LEFT, VK_RIGHT]) and FLookupGrid.Visible then
  begin
    FLookupGrid.KeyDown(Key, Shift);
    Key:= 0;
    exit;
  end;

  if (Key = VK_F3) and (FLookupSource = nil) then
  begin
    CreateView;
    if not FLookupSource.DataSet.Active then
    begin
      (FLookupSource.DataSet as TQuery).ParamByName('Text').AsString := Text;
      FLookupSource.DataSet.Open;
    end;
  end;

  if (Key = VK_F3) and (FLookupGrid <> nil) and (FLookupSource <> nil) then
  begin
    FDBSearchField.CustomSearch := True;

    if (FDBSearchField.DataSource <> FLookupSource) or
      (FDBSearchField.Grid <> FLookupGrid) or
      (FDBSearchField.DataField = '') then
    begin
      FDBSearchField.Grid := FLookupGrid;
      FDBSearchField.DataSource:= FLookupSource;
      FDBSearchField.DataField := LookupDisplay;
    end;

    FDBSearchField.ExecuteDialog;
    Key := 0; 
    exit;
  end;

  inherited KeyDown (Key, Shift);

  if (Key in [VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR] ) then
  begin
    if not FLookupGrid.Visible then begin
      SetStateGrid;
      SetFocus;
    end
    else
    begin
      isKeyDown:= true;
      FLookupGrid.KeyDown(Key, Shift);
      isKeyDown:= false;
    end;

    Key := 0;
  end;
end;

procedure TxDBLookupCombo2.Loaded;
begin
  inherited Loaded;
  
  if not (csDesigning in ComponentState) then
  begin
    if FLookupStoredProc <> '' then
    begin
      FLocateProc.DatabaseName := FDatabaseName;
    end;

    if FLookupSearchProc <> '' then
    begin
      FSearchProc.DatabaseName := FDatabaseName;
    end;
  end;

  if FButton <> nil then FButton.Is3D := Ctl3d;
end;

procedure TxDBLookupCombo2.WMChar(var Message: TWMChar);
var
  Key: Word;
begin
  Key:= Message.CharCode;
  if Message.CharCode = VK_BACK then begin
    if SelLength > 0 then
      Text:= copy(Text, 1, SelStart - 1)
    else
      inherited;
    exit;
  end
  else
    if SelLength > 0 then begin
      FLocalChange:= True;
      Text:= copy(Text, 1, SelStart);
      SelStart:= Length(Text);
      SelLength:= 0;
      FLocalChange:= False;
    end;

  if ((Key = vk_Return) or (Key = vk_Escape)) and FLookupGrid.Visible then
    SetStateGrid
  else
    if Key = VK_RETURN then
      SendMessage(PARENT.HANDLE, WM_CHAR, Message.CharCode, Message.KeyData)
    else
      inherited;
end;

procedure TxDBLookupCombo2.CMFontChanged(var Message: TMessage);
begin
  inherited;
  GetMinHeight;  { set FTextMargin }
end;

procedure TxDBLookupCombo2.SetDataSource(aValue: TDataSource);
begin
  if Assigned(FDataLink) then
  begin
    FDataLink.DataSource:= aValue;
    if FClearText then Text:= '';
  end;
end;

procedure TxDBLookupCombo2.SetDataField(aValue: String);
begin
  if Assigned(FDataLink) then
    FDataLink.FieldName:= aValue;
end;

procedure TxDBLookupCombo2.CreateButton;
begin
  FBtnControl := TWinControl.Create(Self);
  FBtnControl.Width := 19;
  FBtnControl.Height := 17;
  FBtnControl.Visible := True;
  FBtnControl.Parent := Self;

  FButton := TxComboButton.Create(Self);
  FButton.SetBounds(0, 0, FBtnControl.Width - 2, FBtnControl.Height);
  FButton.Glyph.Handle := LoadBitmap(0, PChar(32738));
  FButton.Visible := True;
  FButton.Cursor:= crArrow;
  FButton.Parent := FBtnControl;
end;

procedure TxDBLookupCombo2.SetDrawButton(aValue: Boolean);
begin
  if aValue <> FDrawButton then
  begin
    FDrawButton:= aValue;

    if aValue then
      CreateButton
    else begin
      FButton.Free;
      FBtnControl.Free;
      if not (csDesigning in ComponentState) then
        FLookupGrid.ScrollBars:= ssNone;
    end;
  end;
end;

function TxDBLookupCombo2.GetDataSource: TDataSource;
begin
  if FDataLink <> nil then
    Result:= FDataLink.DataSource
  else
    Result:= nil;
end;

function TxDBLookupCombo2.GetDataField: String;
begin
  if FDataLink <> nil then
    Result:= FDataLink.FieldName
  else
    Result:= '';
end;

function TxDBLookupCombo2.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I, FTextMargin: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    GetTextMetrics(DC, SysMetrics);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  FTextMargin := I div 4;
  Result := Metrics.tmHeight + FTextMargin + GetSystemMetrics(SM_CYBORDER) * 4 + 1;
end;

procedure TxDBLookupCombo2.wmSize(var Message: TWMSize);
begin
  inherited;

  if FDrawButton then
  begin
    FBtnControl.SetBounds(ClientWidth - FButton.Width, 0, FButton.Width,
      ClientHeight);
    FButton.Height:= FBtnControl.Height;
  end;

  if csDesigning in ComponentState then
    FLookupGridWidth:= Width;
  if Height < GetMinHeight then
    Height:= GetMinHeight;
  if FLookupGridWidth < Width then FLookupGridWidth:= Width;
end;

procedure TxDBLookupCombo2.CMCancelMode(var Message: TCMCancelMode);
begin
  if (csDesigning in ComponentState) then exit;

  with Message do
    if (Sender <> Self) and (Sender <> FBtnControl) and
      (Sender <> FButton) and (Sender <> FLookupGrid) then begin
      FLookupGrid.Visible:= false;
    end;
end;

procedure TxDBLookupCombo2.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;

  if (csDesigning in ComponentState) then exit;

  if FLookupGrid.Visible and (Message.FocusedWND <> FLookupGrid.Handle) and not FPressButton
     and (Message.FocusedWND <> Handle)
  then begin
    FLookupGrid.Visible:= false;
  end;
  FPressButton:= false;
end;

procedure TxDBLookupCombo2.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  if Enabled then SetFocus;
end;

procedure TxDBLookupCombo2.DataChange(Sender: TObject);
var
  S: String;
begin
  if not Assigned(FDataLink) or not Visible or not Enabled then exit;

  if (FDataLink.Field <> nil) and not FDataLink.Field.isNull
    and not FLocalChange
  then begin
    S:= FDataLink.Field.Text;
    IDValue := FDataLink.Field.AsInteger;
    Text := SearchText(Text, 1, IDValue);
  end
  else
    if not FLocalChange then
      Text:= '';
end;

procedure TxDBLookupCombo2.CMCTL3DChanged(var Message: TMessage);
begin
  inherited;

  if FButton <> nil then
  begin
    FButton.Is3D := Ctl3d;
    FButton.Repaint;
  end;
end;

procedure TxDBLookupCombo2.CMEnter(var Message: TMessage);
begin
  inherited;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
  begin
    OldValue:= DataSource.DataSet.FieldByName(FDataLink.FieldName).AsInteger;
    if not (DataSource.State in [dsEdit, dsInsert]) then
      DataSource.DataSet.Edit;
  end;

  if not FLookupGrid.Visible then
  begin
    FDBSearchField.CustomSearch := True;
    FDBSearchField.DataField := '';
    FDBSearchField.Grid := FLookupGrid;
    FDBSearchField.DataSource:= FLookupSource;
  end;

end;

procedure TxDBLookupCombo2.DoExit;
begin
  if (csDesigning in ComponentState) then exit;

  if (DataSource = nil) or (DataSource.DataSet = nil) then
  begin
    inherited DoExit;
    exit;
  end;

  if FLookupGrid <> nil then
  begin

    if FCheckValue and FNewName and (Text <> '') then
    begin
      MessageBox(HANDLE, 'Значение поля введено не верно', 'Внимание',
        mb_Ok or MB_ICONASTERISK);
      SetFocus;
      abort;
    end;

    FLookupGrid.Visible:= false;
    if Text = '' then FNewName := False;
    if not FNewName and DataSource.DataSet.Active then
    begin
      if OldValue <> IDValue then begin
        if not (DataSource.State in [dsInsert, dsEdit]) then
          DataSource.DataSet.Edit;
        FLocalChange:= true;

        DataSource.DataSet.FieldByName(DataField).AsInteger := IDValue;
        FLocalChange:= false;
      end;
    end;

  end;

  inherited DoExit;

  FLocalChange:= false;
end;

procedure TxDBLookupCombo2.Change;
var
  S: String;
  OldLen: Integer;
begin
  if not Focused or (csDesigning in ComponentState) or
     FLocalChange or isKeyDown or (Text = '') then
  begin
    inherited Change;
    exit;
  end;

  S := SearchText(Text, 0, IDValue);

  if not FNewName then
  begin
    OldLen:= Length(Text);
    FLocalChange:= true;
    Text:= S;
    FLocalChange:= False;
    SendMessage(HANDLE, EM_SETSEL, OldLen, Length(Text));
  end;

  inherited Change;
end;

procedure TxDBLookupCombo2.CreateView;
var
  S, Params: String;
  FViewStored: TStoredProc;
  i: Integer;
  MS: TgsMultilingualSupport;
begin
  if FLookupSource = nil then
    FLookupSource := TDataSource.Create(Self);
  if FLookupViewStoredProc <> '' then begin
    FViewStored := TStoredProc.Create(Self);
    try
      FViewStored.DatabaseName := FDatabaseName;
      FViewStored.StoredProcName := FLookupViewStoredProc;
      FViewStored.Prepare;
      Params := '';
      for i:= 0 to FViewStored.ParamCount - 1 do
      begin
        if FViewStored.Params[i].ParamType = ptInput then
        begin
          Params := Params + ':' + FViewStored.Params[i].Name;
          if i <> FViewStored.ParamCount - 1 then
            Params := Params + ',';
        end;    
      end;
    finally
      FViewStored.Free;
    end;

    if copy(Params, Length(Params), 1) = ',' then
      Params := copy(Params, 1, Length(Params) - 1);

    // Производим поиск компоненты-переводчика  
    MS := nil;
    if GetParentForm(Self) <> nil then
    begin
      for I := 0 to GetParentForm(Self).ComponentCount - 1 do
        if GetParentForm(Self).Components[I] is TgsMultilingualSupport then
        begin
          MS := GetParentForm(Self).Components[I] as TgsMultilingualSupport;
          Break;
        end;
    end;

    FLookupQuery.DatabaseName := FDatabaseName;

    if MS <> nil then
      S := Format('SELECT * FROM %S(%S) ORDER BY %S COLLATE %s',
        [FLookupViewStoredProc, Params, FLookupDisplay, MS.IBCollation])
    else
      S := Format('SELECT * FROM %S(%S) ORDER BY %S COLLATE %s',
        [FLookupViewStoredProc, Params, FLookupDisplay, 'PXW_CYRL']);

    FLookupQuery.SQL.Clear;
    FLookupQuery.SQL.Add(S);
    FLookupSource.DataSet := FLookupQuery;
  end;

  FLookupGrid.DataSource := FLookupSource;

  FDBSearchField.CustomSearch := True;
  FDBSearchField.DataField := '';
  FDBSearchField.Grid := FLookupGrid;
  FDBSearchField.DataSource:= FLookupSource;

  OldOnCustomSearch := FDBSearchField.OnCustomSearch;
  FDBSearchField.OnCustomSearch := DoOnCustomSearch;
end;

procedure TxDBLookupCombo2.MoveGridWindow;
var
  P: Tpoint;
  R: TRect;
begin
  if (csDesigning in ComponentState) or
     (FLookupViewStoredProc = '')
  then exit;

  FDBSearchField.CustomSearch := True;
  FDBSearchField.DataField := '';
  FDBSearchField.Grid := FLookupGrid;
  FDBSearchField.DataSource:= FLookupSource;

  GetWindowRect(GetDesktopWindow, R);
  P := Point(Left, Top + Height);
  MapWindowPoints(Parent.Handle, GetDesktopWindow, P, 1);
  if P.Y + FLookupGridHeight < R.Bottom then
    MoveWindow(FLookupGrid.HANDLE, P.X, P.Y, FLookupGridWidth,
       FLookupGridHeight, true)
  else
    MoveWindow(FLookupGrid.HANDLE, P.X, P.Y - Height - FLookupGridHeight,
      FLookupGridWidth, FLookupGridHeight, true);

  if FLookupSource = nil then
    CreateView;

  FLookupSource.DataSet.Close;

  try
    if SelLength > 0 then
      (FLookupSource.DataSet as TQuery).ParamByName('Text').AsString :=
        copy(Text, 1, SelStart)
    else
      (FLookupSource.DataSet as TQuery).ParamByName('Text').AsString :=
         Text;
  except
  end;
  if Assigned(FBeforeViewEvent) then
    FBeforeViewEvent(Self, FLookupQuery);
  FLookupSource.DataSet.Open;

  FLookupGrid.Visible := true;
end;

procedure TxDBLookupCombo2.SetStateGrid;
begin
  if csDesigning in ComponentState then exit;

  if FLookupGrid.Visible then begin
    FLookupGrid.Visible := false;
  end
  else begin
    MoveGridWindow;
    Text := FLookupSource.DataSet.FieldByName(FLookupDisplay).Text;
  end;

end;

procedure TxDBLookupCombo2.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FDrawButton then
    FButton.Enabled:= Enabled;

  if csDesigning in ComponentState then exit;

  if FLookupGrid.Visible then
  begin
    FLookupGrid.Visible:= false;
  end;
end;

procedure TxDBLookupCombo2.CMVisibleChanged(var Message: TMessage);
begin
  inherited;

  if csDesigning in ComponentState then exit;

  if FLookupGrid.Visible then
  begin
    FLookupGrid.Visible:= false;
  end;
end;

procedure TxDBLookupCombo2.ClearNewEnter;
begin
  FNewName := False;
end;

procedure TxDBLookupCombo2.SetNewText(const Value: String);
begin
  Text := Value;
  SearchText(Text, 1, IDValue);
end;

function TxDBLookupCombo2.SearchText(const Value: String;
  TypeSearch: Integer; var aID: Integer): String;
begin
  Result := Value;
  if not FLookupGrid.Visible then
  begin
    if (FLookupStoredProc <> '') then
    begin
      if FLocateProc.StoredProcName = '' then begin
        FLocateProc.DatabaseName := FDatabaseName;
        FLocateProc.StoredProcName := FLookupStoredProc;
        FLocateProc.Unprepare;
        FLocateProc.Prepare;
      end;
      Assert(FLocateProc.DescriptionsAvailable);
      FLocateProc.ParamByName('ID').AsInteger := aID;
      FLocateProc.ParamByName('Text').AsString := Value;
      FLocateProc.ParamByName('Type').AsInteger := TypeSearch;
      if Assigned (FBeforeSearchEvent) then
        FBeforeSearchEvent(Self, FLocateProc);
      try
        FLocateProc.ExecProc;
      except
        FLocateProc.UnPrepare;
        FLocateProc.Prepare;
        FLocateProc.ParamByName('ID').AsInteger := aID;
        FLocateProc.ParamByName('Text').AsString := Value;
        FLocateProc.ParamByName('Type').AsInteger := TypeSearch;
        if Assigned (FBeforeSearchEvent) then
          FBeforeSearchEvent(Self, FLocateProc);
        FLocateProc.ExecProc;
      end;
      Result := FLocateProc.ParamByName('OUTText').AsString;
      FNewName := FLocateProc.ParamByName('OK').AsInteger = 0;
      if not FNewName then
        aID := FLocateProc.ParamByName('OUTID').AsInteger
      else
        aID := -1;
    end;
  end
  else begin
    if (FLookupSource <> nil) and FLookupGrid.SetPosition(Text, Result) then
    begin
      FNewName := False;
      aID := FLookupSource.DataSet.FieldByName(LookupField).AsInteger;
    end;
  end;
end;

procedure TxDBLookupCombo2.WMNCLButtonDown(var Message: TMessage);
begin
  inherited;
  if FLookupGrid <> nil then
    FLookupGrid.Visible:= false;
end;

procedure TxDBLookupCombo2.Refresh;
begin
  IDValue := FDataLink.Field.AsInteger;
  Text := SearchText(Text, 1, IDValue);
end;

procedure TxDBLookupCombo2.SetLookupStoredProc(const Value: string);
begin
  FLookupStoredProc := Value;
  if (FLocateProc <> nil) and (FLocateProc.DatabaseName <> '') and (Value <> '') then
  begin
    FLocateProc.StoredProcName := FLookupStoredProc;
    FLocateProc.Unprepare;
    FLocateProc.Prepare;
  end;
end;

procedure TxDBLookupCombo2.SetLookupSearchProc(const Value: string);
begin
  FLookupSearchProc := Value;

  if (FSearchProc <> nil) and (FSearchProc.DatabaseName <> '') and (Value <> '') then
  begin
    FSearchProc.StoredProcName := FLookupSearchProc;
    FSearchProc.Unprepare;
    FSearchProc.Prepare;
  end;
end;

procedure TxDBLookupCombo2.SetLookupViewStoredProc(const Value: string);
begin
  FLookupViewStoredProc := Value;
  
  if FLookupSource <> nil then
  begin
    FLookupSource.Free;
    FLookupSource := nil;
  end;

end;

procedure TxDBLookupCombo2.DoOnCustomSearch(Sender: TObject; Text: String; var Custom, Found: Boolean);
begin
  if Assigned(FDBSearchField) and (FDBSearchField.DataSource = FLookupSource) and
    (FDBSearchField.Grid = FLookupGrid) and
    (FLookupSearchProc <> '') then
  begin
    Custom := True;

    try
      if not FSearchProc.Prepared then
      begin
        if FSearchProc.DatabaseName = '' then
          FSearchProc.DatabaseName := FDatabaseName;
        if FSearchProc.StoredProcName = '' then
          FSearchProc.StoredProcName := FLookupSearchProc;
        FSearchProc.Prepare;
      end;

      // Направление поиска
      if FDBSearchField.SearchDirection = sdDown then
        FSearchProc.Params[0].AsInteger := 1
      else if FDBSearchField.SearchDirection = sdUp then
        FSearchProc.Params[0].AsInteger := 2
      else if FDBSearchField.SearchDirection = sdAll then
        FSearchProc.Params[0].AsInteger := 3;

      // Целое поле или нет
      if soWholeFieldOnly in FDBSearchField.SearchOptions then
        FSearchProc.Params[1].AsInteger := 1
      else
        FSearchProc.Params[1].AsInteger := 0;

      // Регистр имеет значение или нет
      if soCaseSensitive in FDBSearchField.SearchOptions then
        FSearchProc.Params[2].AsInteger := 1
      else
        FSearchProc.Params[2].AsInteger := 0;

      // Текст поиска
      FSearchProc.Params[3].AsString := Text;

      // Начало поиска
      FSearchProc.Params[4].AsInteger := IDValue;

      FSearchProc.ExecProc;

      // Найдено ли значение поиска или нет
      if FSearchProc.Params[7].AsInteger = 1 then
      begin
        Found := True;
        IdValue := FSearchProc.Params[5].AsInteger;
        Self.Text := FSearchProc.Params[6].AsString;
      end;
    except
      FSearchProc.UnPrepare;
      FSearchProc.Prepare;

      // Направление поиска
      if FDBSearchField.SearchDirection = sdDown then
        FSearchProc.Params[0].AsInteger := 1
      else if FDBSearchField.SearchDirection = sdUp then
        FSearchProc.Params[0].AsInteger := 2
      else if FDBSearchField.SearchDirection = sdAll then
        FSearchProc.Params[0].AsInteger := 3;

      // Целое поле или нет
      if soWholeFieldOnly in FDBSearchField.SearchOptions then
        FSearchProc.Params[1].AsInteger := 1
      else
        FSearchProc.Params[1].AsInteger := 0;

      // Регистр имеет значение или нет
      if soCaseSensitive in FDBSearchField.SearchOptions then
        FSearchProc.Params[2].AsInteger := 1
      else
        FSearchProc.Params[2].AsInteger := 0;

      // Текст поиска
      FSearchProc.Params[3].AsString := Text;

      // Начало поиска
      FSearchProc.Params[4].AsInteger := IDValue;

      FSearchProc.ExecProc;

      // Найдено ли значение поиска или нет
      if FSearchProc.Params[7].AsInteger = 1 then
      begin
        Found := True;
        IdValue := FSearchProc.Params[5].AsInteger;
        Self.Text := FSearchProc.Params[6].AsString;
      end;
    end;
  end else
    if Assigned(OldOnCustomSearch) then
      OldOnCustomSearch(Sender, Text, Custom, Found);
end;

procedure TxDBLookupCombo2.SetNewID(aIDValue: Integer);
begin
  IDValue := aIDValue;
  Text := SearchText(Text, 1, IDValue);
end;

{ TxComboButton ------------------------------------------}

constructor TxComboButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  IsActive := False;
  IsPressed := False;
  Is3D := True;
end;

procedure TxComboButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  IsActive := True;
  Paint;
end;

procedure TxComboButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  IsActive := False;
  Paint;
end;

procedure TxComboButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TxDBLookupCombo2(Parent.Parent).FPressButton:= true;
  inherited MouseDown(Button, Shift, X, Y);
  if not TxDBLookupCombo2(Parent.Parent).Focused then
    TxDBLookupCombo2(Parent.Parent).SetFocus;
  TxDBLookupCombo2(Parent.Parent).SetStateGrid;
  TxDBLookupCombo2(Parent.Parent).SetFocus;
  TxDBLookupCombo2(Parent.Parent).FPressButton:= False;

  IsPressed := True;
  Paint;
end;

procedure TxComboButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
end;

procedure TxComboButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);

  IsPressed := False;
  Paint;
end;

procedure TxComboButton.Paint;
var
  Y: Integer;
begin
  if not Is3D then
  begin
    if not IsPressed then
      Canvas.Brush.Color := $0094A2A5
    else
      Canvas.Brush.Color := clBlack;

    Canvas.FillRect(Rect(0, 0, Width, Height));

    Canvas.Brush.Color := clBlack;
    Canvas.FrameRect(Rect(0, 0, Width, Height));

    Y := Height div 2 - 1;

    if (IsActive and not TxDBLookupCombo2(Parent.Parent).FLookupGrid.Visible) or IsPressed then
      Canvas.Pen.Color := clWhite
    else
      Canvas.Pen.Color := clBlack;

    Canvas.MoveTo(6, Y + 1);
    Canvas.LineTo(11, Y + 1);

    Canvas.MoveTo(7, Y + 2);
    Canvas.LineTo(10, Y + 2);

    if (IsActive and not TxDBLookupCombo2(Parent.Parent).FLookupGrid.Visible) or IsPressed then
      Canvas.Pixels[8, Y + 3] := clWhite
    else
      Canvas.Pixels[8, Y + 3] := clBlack;
  end else
    inherited Paint;
end;

end.

