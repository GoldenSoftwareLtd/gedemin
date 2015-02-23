
{
  1.01    27-Jul-96    andreik    Minor bug fixed.
  1.02    04-Sep-96    michael    Some change with Grid
  1.03    07-May-97    michael    Focus and change data source
  1.04    14-May-97    andreik    CreateWindowHandle added.
  1.05    14-aug-97    michael    Minor change.
  1.06    21-Oct-97    michael    Minor change.
  1.07    10-Nov-97    andreik    Minor change.
  1.08    23-Dec-97    michael    Minor change.
  1.09    04-Feb-98    michael    Add find dialog
  1.10    11-Aug-98    dennis     Addapted under Delphi 4. Minor Change.
}

unit xDBLookU;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBTables, DBGrids, StdCtrls, Menus,
  ExList, ExtCtrls, Buttons, dbsrch, dbctrls, mmDBGrid;

type
  TxDBLookupCombo = class;
  TOnChangeVisible = procedure(DataSet: TDataSet; isVisible: Boolean) of object;

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

  TxLookupGrid = class(TmmDBGrid)
  private
    FCurrentRecord: Longint;

    function GetCurrentField: String;
    function GetCurrentLookup: String;
    function SetQueryPos(const Field: String; var FullStr: String): Boolean;

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
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState);
      override;

  public
    isSqlSearch: Boolean;
    FirstValue: Integer;

    constructor Create(AnOwner: TComponent); override;

    function SetPosition(const Field: String; var FullStr: String): Boolean;

    property CurrentLookup: String read GetCurrentLookup;
  end;

  TxDBLookupCombo = class(TCustomEdit)
  private
    FDataLink: TFieldDataLink;
    FLookupLink: TFieldDataLink;
    FDisplayLink: TFieldDataLink;
    FOnChangeVisible: TOnChangeVisible;
    FOnlyFirstField: Boolean;
    FCheckValue: Boolean;
    FAppendNewValue: Boolean;
    FDrawButton: Boolean;
    FLookupGridWidth: Integer;
    FLookupGridHeight: Integer;
    FDBSearchField: TDBSearchField;
    FRangeField: String;
    FRangeValue: Integer;

    OldFieldIndex, OldValue: String;
    IsKeyDown: Boolean;

    FLookupGrid: TxLookupGrid;
    FBtnControl: TWinControl;
    FButton: TxComboButton;
    FNewName: Boolean;
    FLocalChange: Boolean;
    FPressButton: Boolean;
    FClearText: Boolean;
    OldLong: Longint;
    OldAfterOpen: TDataSetNotifyEvent;
    OldStateChange: TNotifyEvent;

    HEditDS: THandle;

    procedure SetDataSource(aValue: TDataSource);
    procedure SetDataField(aValue: String);
    procedure SetLookupSource(aValue: TDataSource);
    procedure SetLookupField(aValue: String);
    procedure SetDisplayField(aValue: String);
    procedure SetDrawButton(aValue: Boolean);
    procedure CreateButton;
    procedure MakeAfterOpen(DataSet: TDataSet);
    procedure MakeStateChange(Sender: TObject);
    procedure MakeOkFind(Sender: TObject);

    function GetDataSource: TDataSource;
    function GetDataField: String;
    function GetLookupSource: TDataSource;
    function GetLookupField: String;
    function GetDisplayField: String;
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

    procedure MoveGridWindow;
    procedure SetStateGrid;
    function SetQPos(Value: String): Boolean;

    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;

  protected
    procedure DoExit; override;
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;

  public
    FirstValue: Integer;
    FirstName: String;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property NewEnter: Boolean read FNewName;
    property Text;
    procedure SetText;
    procedure ClearNewEnter;
    procedure SetNewText(const Value: String);

    property LookupGrid: TxLookupGrid read FLookupGrid; 

  published
    property ClearText: Boolean read FClearText write FClearText default True;
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource
      write SetDataSource;
    property LookupSource: TDataSource read GetLookupSource
      write SetLookupSource;
    property LookupField: String read GetLookupField write SetLookupField;
    property LookupDisplay: String read GetDisplayField
      write SetDisplayField;
    property OnlyFirstField: Boolean read FOnlyFirstField
      write FOnlyFirstField default True;
    property CheckValue: Boolean read FCheckValue write FCheckValue
      default false;
    property DrawButton: Boolean read FDrawButton write SetDrawButton
      default true;
    property AppendNewValue: Boolean read FAppendNewValue
      write FAppendNewValue default false;
    property LookupGridWidth: Integer read FLookupGridWidth
      write FLookupGridWidth;
    property LookupGridHeight: Integer read FLookupGridHeight
      write FLookupGridHeight;
    property RangeField: String read FRangeField write FRangeField;
    property RangeValue: Integer read FRangeValue write FRangeValue; 
    property OnChangeVisible: TOnChangeVisible read FOnChangeVisible
      write FOnChangeVisible;
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
  TxDBLookupCombo(Parent.Parent).FPressButton:= true;
  inherited MouseDown(Button, Shift, X, Y);
  if not TxDBLookupCombo(Parent.Parent).Focused then
    TxDBLookupCombo(Parent.Parent).SetFocus;
  TxDBLookupCombo(Parent.Parent).SetStateGrid;
  TxDBLookupCombo(Parent.Parent).SetFocus;
  TxDBLookupCombo(Parent.Parent).FPressButton:= False;

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

    if (IsActive and not TxDBLookupCombo(Parent.Parent).FLookupGrid.Visible) or IsPressed then
      Canvas.Pen.Color := clWhite
    else
      Canvas.Pen.Color := clBlack;

    Canvas.MoveTo(6, Y + 1);
    Canvas.LineTo(11, Y + 1);

    Canvas.MoveTo(7, Y + 2);
    Canvas.LineTo(10, Y + 2);

    if (IsActive and not TxDBLookupCombo(Parent.Parent).FLookupGrid.Visible) or IsPressed then
      Canvas.Pixels[8, Y + 3] := clWhite
    else
      Canvas.Pixels[8, Y + 3] := clBlack;
  end else
    inherited Paint;
end;

{ TxLookupGrid ---------------------------------------- }

constructor TxLookupGrid.Create(AnOwner: TComponent);
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

function TxLookupGrid.SetPosition(const Field: String;
  var FullStr: String): Boolean;
var
  S: String;
//  Temp: array[0..255] of Char;
begin
  Result:= false;
  if (Field = '') or not DataSource.DataSet.Active then exit;
  S:= Field;
{  if DataSource.DataSet is TxTable then begin
    StrPCopy(Temp, S);
    ANSIToOEM(Temp, Temp);
    S:= StrPas(Temp);
  end;}
  if not isSQLSearch then
    TTable(DataSource.DataSet).FindNearest([S])
  else begin
    TTable(DataSource.DataSet).FindNearest([FirstValue, S])
  end;
  S:= copy(DataSource.DataSet.FieldByName(
      TxDbLookupCombo(Parent).LookupDisplay).Text, 1,  Length(Field));
  Result:= AnsiCompareText(S, Field) = 0;
  if Result then begin
    FullStr:= DataSource.DataSet.FieldByName(
       TxDbLookupCombo(Parent).LookupDisplay).Text;
  end;
end;

function TxLookupGrid.SetQueryPos(const Field: String;
  var FullStr: String): Boolean;
var
  S: String;
  i: Integer;
  Bookmark: TBookmark;
begin
  FullStr:= Field;
  Result:= False;

  if not DataSource.DataSet.Active then exit;
  DataSource.DataSet.DisableControls;
  Bookmark:= DataSource.DataSet.GetBookmark;
  with DataSource.DataSet do begin
    First;
    while not EOF do begin
      S:= copy(FieldByName(TxDbLookupCombo(Parent).LookupDisplay).Text, 1,
          Length(Field));
      i:= AnsiCompareText(S, Field);
      Result:= i = 0;
      if Result then begin
        FullStr:= FieldByName(TxDbLookupCombo(Parent).LookupDisplay).Text;
        Break;
      end
      else
        if i > 0 then Break;
      Next;
    end;
  end;
  if not Result then
    DataSource.DataSet.GotoBookmark(Bookmark);
  DataSource.DataSet.FreeBookmark(Bookmark);
  DataSource.DataSet.EnableControls;
end;

procedure TxLookupGrid.CreateWnd;
begin
  inherited CreateWnd;
  {WinProcs.SetParent(Handle, 0);}
end;

procedure TxLookupGrid.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.Style := CS_SAVEBITS;
  Params.Style:= ws_Popup or ws_Border;
end;

function TxLookupGrid.GetCurrentField: String;
var
  OldActive: Longint;
begin
  Result:= '';
  if not DataSource.DataSet.Active then exit;
  OldActive := DataLink.ActiveRecord;
  try
    DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
    Result:= DataSource.DataSet.FieldByName(
       TxDbLookupCombo(Parent).LookupDisplay).Text
  finally
    DataLink.ActiveRecord := OldActive;
  end;
end;

function TxLookupGrid.GetCurrentLookup: String;
var
  OldActive: Longint;
begin
  Result:= '';
  if not DataSource.DataSet.Active then exit;
  OldActive := DataLink.ActiveRecord;
  try
    DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
    Result:= DataSource.DataSet.FieldByName(
       TxDbLookupCombo(Parent).LookupField).Text
  finally
    DataLink.ActiveRecord := OldActive;
  end;
end;

procedure TxLookupGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
{  if Row <> FCurrentRecord then}
  TxDBLookupCombo(Parent).Text:= GetCurrentField;
  TxDBLookupCombo(Parent).FNewName:= false;
  FCurrentRecord:= Row;
{  WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
  TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
{  if Row <> FCurrentRecord then}
    TxDBLookupCombo(Parent).Text:= GetCurrentField;
  TxDBLookupCombo(Parent).FNewName:= false;
  FCurrentRecord:= Row;
{  WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
  TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if Visible then
    Visible:= false;
{  WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
  TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  if Row <> FCurrentRecord then
    TxDBLookupCombo(Parent).Text:= GetCurrentField;
  FCurrentRecord:= Row;
{  WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
  TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
{  WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
  TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMShowWindow(var Message: TWMShowWindow);
begin
  inherited;
  if Message.Show then
{    WinProcs.SetFocus(TWinControl(Owner).HANDLE);}
    TxDBLookupCombo(Owner).SetFocus;
end;

procedure TxLookupGrid.WMWindowPosChanging(var Message: TWMWindowPosChanging);
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

{ TxDBLookupCombo ------------------------------------- }

constructor TxDBLookupCombo.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FNewName:= false;
  FLocalChange:= false;
  isKeyDown:= false;
  FClearText:= True;

  FDataLink:= TFieldDataLink.Create;
//  FDataLink.Control:= Self;
  FDataLink.OnDataChange := DataChange;

  FOnlyFirstField:= True;
  FCheckValue:= False;
  FDrawButton:= True;
  FAppendNewValue:= False;

  FLookupLink:= TFieldDataLink.Create;
//  FLookupLink.Control:= Self;

  FDisplayLink:= TFieldDataLink.Create;
//  FDisplayLink.Control:= Self;
  FPressButton:= false;

  if not (csDesigning in ComponentState) then begin
    FLookupGrid:= TxLookupGrid.Create(Self);
    FLookupGrid.Parent:= Self;

    FDBSearchField:= TDBSearchField.Create(Self);
    FDBSearchField.OkFind:= MakeOkFind;
  end;

  FLookupGridWidth:= Width;
  FLookupGridHeight:= 168;
  OldFieldIndex:= '';
  FRangeField:= '';
  FRangeValue:= 0;

  OldStateChange:= nil;
  OldAfterOpen:= nil;

  CreateButton;
end;

procedure TxDBLookupCombo.SetText;
begin
  if LookupSource <> nil then
    Text:= LookupSource.DataSet.FieldByName(LookupDisplay).Text;
end;

destructor TxDBLookupCombo.Destroy;
begin
  if LookupSource <> nil then begin
    LookupSource.DataSet.AfterOpen:= OldAfterOpen;
    LookupSource.OnStateChange:= OldStateChange;
  end;  
  FDataLink.Free;
  FDataLink:= nil;
  FLookupLink.Free;
  FLookupLink:= nil;
  FDisplayLink.Free;
  FDisplayLink:= nil;
  FLookupGrid.Free;
  FLookupGrid:= nil;
  inherited Destroy;
end;

procedure TxDBLookupCombo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if (FDataLink <> nil) and (AComponent = DataSource) then begin
      DataSource := nil;
    end;
    if (FLookupLink <> nil) and (AComponent = LookupSource) then begin
      OldFieldIndex:= '';
      LookupSource := nil;
    end;
    if (AComponent = DataSource) or (AComponent = LookupSource) then
      Text:= '';
  end;
end;

procedure TxDBLookupCombo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style:= Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
  OldLong:= Params.Style;
end;

procedure TxDBLookupCombo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_LEFT, VK_RIGHT]) and FLookupGrid.Visible then begin
    FLookupGrid.KeyDown(Key, Shift);
    Key:= 0;
    exit;
  end;

  inherited KeyDown (Key, Shift);

  if Key = VK_F3 then
    FDBSearchField.Find;

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

procedure TxDBLookupCombo.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) and (LookupSource <> nil) and
     (LookupSource.DataSet <> nil)
  then begin
    OldAfterOpen:= LookupSource.DataSet.AfterOpen;
    LookupSource.DataSet.AfterOpen:= MakeAfterOpen;

    FDBSearchField.DataSource:= LookupSource;
    FDBSearchField.DBGrid:= FLookupGrid;
  end;

  if not (csDesigning in ComponentState) and (LookupSource <> nil) and
    (LookupSource.DataSet = nil)
  then begin
    OldStateChange:= LookupSource.OnStateChange;
    LookupSource.OnStateChange:= MakeStateChange;
  end;

  if FButton <> nil then FButton.Is3D := Ctl3d;
end;

procedure TxDBLookupCombo.WMChar(var Message: TWMChar);
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

procedure TxDBLookupCombo.CMFontChanged(var Message: TMessage);
begin
  inherited;
  GetMinHeight;  { set FTextMargin }
end;

procedure TxDBLookupCombo.SetDataSource(aValue: TDataSource);
begin
  FDataLink.DataSource:= aValue;
  if FClearText then
    Text:= '';
end;

procedure TxDBLookupCombo.SetDataField(aValue: String);
begin
  FDataLink.FieldName:= aValue;
end;

procedure TxDBLookupCombo.SetLookupSource(aValue: TDataSource);
begin
  FLookupLink.DataSource:= aValue;
  FDisplayLink.DataSource:= aValue;
  if not (csDesigning in ComponentState) and (FLookupGrid <> nil) then
    FLookupGrid.DataSource:= aValue;
  if FClearText then
    Text:= '';
end;

procedure TxDBLookupCombo.SetLookupField(aValue: String);
begin
  FLookupLink.FieldName:= aValue;
end;

procedure TxDBLookupCombo.SetDisplayField(aValue: String);
begin
  FDisplayLink.FieldName:= aValue;
end;

procedure TxDBLookupCombo.CreateButton;
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
//  FButton.Flat := True;
//  FButton.Transparent := False;
  FButton.Cursor:= crArrow;
  FButton.Parent := FBtnControl;
end;

procedure TxDBLookupCombo.MakeAfterOpen(DataSet: TDataSet);
begin
  if Assigned(OldAfterOpen) then OldAfterOpen(DataSet);
  DataChange(Self);
end;

procedure TxDBLookupCombo.MakeStateChange(Sender: TObject);
begin
  if Assigned(OldStateChange) then OldStateChange(Sender);
  DataChange(Sender);
end;

procedure TxDBLookupCombo.MakeOkFind(Sender: TObject);
begin
  SetText;
end;

procedure TxDBLookupCombo.SetDrawButton(aValue: Boolean);
begin
  if aValue <> FDrawButton then begin
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

function TxDBLookupCombo.GetDataSource: TDataSource;
begin
  if FDataLink <> nil then
    Result:= FDataLink.DataSource
  else
    Result:= nil;
end;

function TxDBLookupCombo.GetDataField: String;
begin
  if FDataLink <> nil then
    Result:= FDataLink.FieldName
  else
    Result:= '';
end;

function TxDBLookupCombo.GetLookupSource: TDataSource;
begin
  if FLookupLink <> nil then
    Result:= FLookupLink.DataSource
  else
    Result:= nil;
end;

function TxDBLookupCombo.GetLookupField: String;
begin
  if FLookupLink <> nil then
    Result:= FLookupLink.FieldName
  else
    Result:= '';
end;

function TxDBLookupCombo.GetDisplayField: String;
begin
  if FDisplayLink <> nil then
    Result:= FDisplayLink.FieldName
  else
    Result:= '';
end;

function TxDBLookupCombo.GetMinHeight: Integer;
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

procedure TxDBLookupCombo.wmSize(var Message: TWMSize);
begin
  inherited;
  if FDrawButton then begin
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

procedure TxDBLookupCombo.CMCancelMode(var Message: TCMCancelMode);
begin
  if (csDesigning in ComponentState) then exit;
  with Message do
    if (Sender <> Self) and (Sender <> FBtnControl) and
      (Sender <> FButton) and (Sender <> FLookupGrid) then begin
      FLookupGrid.Visible:= false;
      if Assigned(FOnChangeVisible) then FOnChangeVisible(LookupSource.DataSet,
        false);
    end;
end;

procedure TxDBLookupCombo.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if (csDesigning in ComponentState) then exit;
  if FLookupGrid.Visible and (Message.FocusedWND <> FLookupGrid.Handle) and not FPressButton
     and (Message.FocusedWND <> Handle)
  then begin
    FLookupGrid.Visible:= false;
    if Assigned(FOnChangeVisible) then
      FOnChangeVisible(LookupSource.DataSet, false);
  end;
  FPressButton:= false;
end;

procedure TxDBLookupCombo.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Enabled then
    SetFocus;
end;

procedure TxDBLookupCombo.DataChange(Sender: TObject);
var
  S: String;
//  Temp: array[0..255] of Char;
  OldIndex: String;
begin

  if (not Assigned(FDataLink)) or (LookupSource = nil) then
    {raise Exception.Create('DL and LS');} exit;
  if not Visible or not Enabled then exit;
  if (FDataLink.Field <> nil) and (LookupSource.DataSet <> nil) and
     LookupSource.DataSet.Active and not FDataLink.Field.isNull and not FLocalChange
  then begin
    S:= FDataLink.Field.Text;

    if (LookupSource.DataSet is TTable) then begin
      if TTable(LookupSource.DataSet).IndexFieldNames = '' then
        TTable(LookupSource.DataSet).IndexFieldNames:= LookupField;
      OldIndex:= TTable(LookupSource.DataSet).IndexFieldNames;
      if (OldFieldIndex <> '') then
        try
          TTable(LookupSource.DataSet).IndexFieldNames:= OldFieldIndex;
        except
        end;
    end;

    try
      if LookupSource.DataSet is TTable then begin
        TTable(LookupSource.DataSet).IndexFieldNames:= LookupField;
        if TTable(LookupSource.DataSet).FindKey([S]) then begin
          if LookupSource.DataSet is TTable then
            TTable(LookupSource.DataSet).IndexFieldNames:= OldIndex;
          Text:= LookupSource.DataSet.FieldByName(LookupDisplay).Text;
          FNewName:= False;
        end
      end
      else begin
        if SetQPos(FDataLink.Field.Text) then
          Text:= LookupSource.DataSet.FieldByName(LookupDisplay).Text;
      end;
    except
      if LookupSource.DataSet is TTable then
        TTable(LookupSource.DataSet).IndexFieldNames:= OldIndex;
      Text:= FDataLink.Field.Text;
    end;
  end
  else
    if not FLocalChange then
      Text:= '';
end;

procedure TxDBLookupCombo.CMCTL3DChanged(var Message: TMessage);
begin
  inherited;
  
  if FButton <> nil then
  begin
    FButton.Is3D := Ctl3d;
    FButton.Repaint;
  end;
end;

procedure TxDBLookupCombo.CMEnter(var Message: TMessage);
begin
  inherited;
  if (LookupSource = nil) or (LookupSource.DataSet = nil) then exit;
  
  FLookupGrid.isSQLSearch:= not FOnlyFirstField or (LookupSource.DataSet is TQuery) or
    (FRangeField <> '');
    
  if (DataSource = nil) or (DataSource.DataSet = nil) then exit;
  if not DataSource.DataSet.Active then exit;

  if LookupSource.DataSet is TTable then begin
    OldFieldIndex:= TTable(LookupSource.DataSet).IndexFieldNames;
    if FOnlyFirstField then begin
      if FRangeField <> '' then
        TTable(LookupSource.DataSet).IndexFieldNames:= FRangeField + ';' + LookupDisplay
      else
        TTable(LookupSource.DataSet).IndexFieldNames:= LookupDisplay;
    end
    else
      TTable(LookupSource.DataSet).IndexFieldNames:= FirstName + ';' + LookupDisplay;
  end;

  OldValue:= DataSource.DataSet.FieldByName(FDataLink.FieldName).AsString;
  if not (DataSource.State in [dsEdit, dsInsert]) then
    DataSource.DataSet.Edit;

end;

procedure TxDBLookupCombo.DoExit;
begin
  if (csDesigning in ComponentState) then exit;
  
  if (DataSource = nil) or (DataSource.DataSet = nil) then begin
    inherited DoExit;
    exit;
  end;  

  if FLookupGrid <> nil then begin

    if FCheckValue and FNewName and (Text <> '') then begin
      MessageBox(HANDLE, 'Значение поля введено не верно', 'Внимание',
        mb_Ok or MB_ICONASTERISK);
      SetFocus;
      abort;
    end;

    if FAppendNewValue and FNewName and (Text <> '') then begin
      LookupSource.DataSet.Append;
      if not FOnlyFirstField then
        LookupSource.DataSet.FieldByName(FirstName).AsInteger:= FirstValue;
      LookupSource.DataSet.FieldByName(LookupDisplay).Text:=
        Text;
      LookupSource.DataSet.Post;
      FNewName:= false;
    end;

    FLookupGrid.Visible:= false;
    if not FNewName and DataSource.DataSet.Active and
       LookupSource.DataSet.Active and (Text <> '') then begin
      if OldValue <> FLookupLink.Field.Text then begin
        if not (DataSource.State in [dsInsert, dsEdit]) then
          DataSource.DataSet.Edit;
        FLocalChange:= true;

        DataSource.DataSet.FieldByName(DataField).Text:=
          FLookupLink.Field.Text;
        FLocalChange:= false;
      end;
    end;

    if LookupSource.DataSet is TTable then
      TTable(LookupSource.DataSet).IndexFieldNames:= OldFieldIndex;

  end;

  inherited DoExit;

  FLocalChange:= false;
end;

procedure TxDBLookupCombo.Change;
var
  S: String;
  OldLen: Integer;
begin
  if not Focused or (csDesigning in ComponentState) or
     FLocalChange or isKeyDown or (Text = '') then begin
    inherited Change;
    exit;
  end;

  if LookupSource.DataSet is TTable then begin
    try
      if TTable(LookupSource.DataSet).IndexFieldNames <> LookupDisplay then
      begin
        if FRangeField <> '' then
          TTable(LookupSource.DataSet).IndexFieldNames:= FRangeField + ';' + LookupDisplay
        else
          TTable(LookupSource.DataSet).IndexFieldNames:= LookupDisplay;
      end;
    except
    end;
    FNewName:= not FLookupGrid.SetPosition(Text, S);
  end
  else
    FNewName:= not FLookupGrid.SetQueryPos(Text, S);
    
  if not FNewName then begin
    OldLen:= Length(Text);
    FLocalChange:= true;
    Text:= S;
    FLocalChange:= False;
    SendMessage(HANDLE, EM_SETSEL, OldLen, Length(Text));
  end;
  inherited Change;
end;

procedure TxDBLookupCombo.MoveGridWindow;
var
  P: Tpoint;
  List: TStringList;
  i, j: Integer;
  isFirstIndex, isFind: Boolean;
  R: TRect;
begin
  isFirstIndex := False;
  if (csDesigning in ComponentState) then exit;
  if (csDesigning in ComponentState) or (LookupSource = nil) or
     (LookupSource.DataSet = nil)
  then exit;

  if LookupSource.DataSet is TTable then begin
    List:= TStringList.Create;
    try
      if LookupSource.DataSet is TTable then
      begin
        TTable(LookupSource.DataSet).GetIndexNames(List);
        if CompareText( TTable(LookupSource.DataSet).IndexFieldNames, LookupDisplay ) <> 0 then
          OldFieldIndex:= TTable(LookupSource.DataSet).IndexFieldNames;

        if not FOnlyFirstField then begin

          for i:= 0 to List.Count - 1 do begin
            TTable(LookupSource.DataSet).IndexName:= List[i];
            isFirstIndex:= true;
            isFind:= false;
            for j:= 1 to TTable(LookupSource.DataSet).IndexFieldCount - 1 do
              if TTable(LookupSource.DataSet).IndexFields[j].FieldName =
                LookupDisplay
              then begin
                isFirstIndex:= j = 0;
                isFind:= true;
                Break;
              end;
            if isFind then Break;
          end;

        end
        else begin
          if FRangeField = '' then
            TTable(LookupSource.DataSet).IndexFieldNames:= LookupDisplay
          else begin
            TTable(LookupSource.DataSet).IndexFieldNames:= FRangeField + ';' + LookupDisplay;
            TTable(LookupSource.DataSet).SetRange([RangeValue], [RangeValue]);
          end;
          isFirstIndex:= true;
        end;
      end;
    finally
      List.Free;
    end;

  end;

  GetWindowRect(GetDesktopWindow, R);
  P:= Point(Left, Top + Height);
  MapWindowPoints(Parent.Handle, GetDesktopWindow, P, 1);
  if P.Y + FLookupGridHeight < R.Bottom then
    MoveWindow(FLookupGrid.HANDLE, P.X, P.Y, FLookupGridWidth,
       FLookupGridHeight, true)
  else
    MoveWindow(FLookupGrid.HANDLE, P.X, P.Y - Height - FLookupGridHeight,
      FLookupGridWidth,  FLookupGridHeight, true);

  FLookupGrid.isSQLSearch:= not isFirstIndex or (LookupSource.DataSet is TQuery)
    or (FRangeField <> '');
  if FRangeField = '' then
    FLookupGrid.FirstValue:= FirstValue
  else
    FLookupGrid.FirstValue:= FRangeValue;
  FLookupGrid.Visible:= true;
end;

procedure TxDBLookupCombo.SetStateGrid;
begin
  if csDesigning in ComponentState then exit;

  if FLookupGrid.Visible then begin
    FLookupGrid.Visible:= false;
  end
  else begin
    MoveGridWindow;

    if LookupSource = nil then
      raise Exception.Create('Lookup source is not assigned');

    Text:= LookupSource.DataSet.FieldByName(LookupDisplay).Text;
  end;

  if Assigned(FOnChangeVisible) then
    FOnChangeVisible(LookupSource.DataSet, FLookupGrid.Visible);
end;

function TxDBLookupCombo.SetQPos(Value: String): Boolean;
var
  Bookmark: TBookmark;
begin
  Result:= False;
  LookupSource.DataSet.DisableControls;
  Bookmark:= LookupSource.DataSet.GetBookmark;
  LookupSource.DataSet.First;
  while not LookupSource.DataSet.EOF do begin
    Result:= Value = LookupSource.DataSet.FieldByName(LookupField).Text;
    if Result then Break;
    LookupSource.DataSet.Next;
  end;
  if not Result then
    LookupSource.DataSet.GotoBookmark(Bookmark);
  LookupSource.DataSet.FreeBookmark(Bookmark);
  LookupSource.DataSet.EnableControls;
end;

procedure TxDBLookupCombo.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
  if HEditDS <> HInstance then
    GlobalFree(HEditDS);
end;

procedure TxDBLookupCombo.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FDrawButton then
    FButton.Enabled:= Enabled;
  if csDesigning in ComponentState then exit;
  if FLookupGrid.Visible then begin
    FLookupGrid.Visible:= false;
    if Assigned(FOnChangeVisible) then FOnChangeVisible(LookupSource.DataSet, false);
  end;
end;

procedure TxDBLookupCombo.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if csDesigning in ComponentState then exit;
  if FLookupGrid.Visible then begin
    FLookupGrid.Visible:= false;
    if Assigned(FOnChangeVisible) then FOnChangeVisible(LookupSource.DataSet, false);
  end;
end;

procedure TxDBLookupCombo.ClearNewEnter;
begin
  FNewName := False;
end;

procedure TxDBLookupCombo.SetNewText(const Value: String);
var
  S: String;
begin
  Text := Value;
  if LookupSource.DataSet is TTable then
    FLookupGrid.SetPosition(Text, S)
  else
    FLookupGrid.SetQueryPos(Text, S);
end;

end.
