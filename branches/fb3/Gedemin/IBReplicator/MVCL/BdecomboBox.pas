unit BDEComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, db, dbctrls, Buttons;

type
  TBDEPopup = class(TForm)
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

type
  TCustomBDEComboBox = class(TCustomComboBox)
  private
    { Private declarations }
    FDataLink: TFieldDataLink;
    function GetDataSource:TDataSource;
    function GetDataField:string;
    function GetField: TField;
    procedure SetDataSource(Value:TDataSource);
    procedure SetDataField(Value:string);
    procedure SetComboText(const Value: string);
    function GetComboText: string;
  protected
    { Protected declarations }
    procedure Change;override;
    procedure DropDown; override;
    procedure Loaded;override;
    procedure Notification(AComponent: TComponent;Operation: TOperation);override;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer);override;
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure KeyPress(var Key: Char);override;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
  public
    { Public declarations }
    property Field: TField read GetField;
    property Text;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    function  UpdateAction(Action: TBasicAction): Boolean;override;
  published
    { Published declarations }
    property Style; {Must be published before Items}
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property Items; {write SetItem}
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

type TBDEComboBox=class(TWinControl)
    private
      FCombo:TCustomBDEComboBox;
      FButton:TSpeedButton;
      FEditForm:TForm;
      function GetDataSource:TDataSource;
      function GetDataField:string;
      function GetDropDownCount:Integer;
      procedure SetDataSource(Value:TDataSource);
      procedure SetDataField(Value:string);
      procedure SetDropDownCount(Value:integer);
      function  GetFlat:boolean;
      procedure SetFlat(Value:boolean);
      function GetComboWidth:integer;

    protected

    public
      constructor Create(aOwner: TComponent);override;
      procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
      procedure ButtonClick(Sender: TObject);
    published
      property Anchors;
      property BiDiMode;
      property Color;
      property Constraints;
      {property Ctl3D;}
      property DataField: string read GetDataField write SetDataField;
      property DataSource: TDataSource read GetDataSource write SetDataSource;
      property DragCursor;
      property DragKind;
      property DragMode;
      property DropDownCount: integer read GetDropDownCount write SetDropDownCount;
      property Enabled;
      property Font;
      property Flat:boolean read GetFlat write SetFlat;
      {property ImeMode;
      property ImeName;
      property ItemHeight;
      property Items;}
      property ParentBiDiMode;
      property ParentColor;
      {property ParentCtl3D;}
      property ParentFont;
      property ParentShowHint;
      property PopupMenu;
      property ShowHint;
      {property Sorted;}
      {property TabOrder;}
      {property TabStop;}
      property Visible;
      property EditForm:TForm read FEditForm write FEditForm;
  end;

procedure Register;

implementation
{$R 'uBDEPopup.DFM'}

type
  TSelection = record
    StartPos, EndPos: Integer;
  end;

procedure TBDEPopup.CreateParams(var Params: TCreateParams);
begin
end;

procedure TBDEComboBox.ButtonClick(Sender:TObject);
begin
if FEditForm<>nil then
  begin
  FEditForm.ShowModal;
  end;
end;

procedure TBDEComboBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
inherited SetBounds(aLeft,aTop,aWidth,aHeight);
if FCombo<>nil then FCombo.SetBounds(0,0,GetComboWidth,aHeight);
if FButton<>nil then FButton.SetBounds(GetComboWidth+1,0,aHeight,aHeight);
end;

function TBDEComboBox.GetComboWidth:integer;
begin
Result:=Width-Height-1;
end;

function TBDEComboBox.GetFlat:boolean;
begin
if FButton<>nil then
  begin
  Result:=FButton.Flat;
  end
else Result:=false;
end;

procedure TBDEComboBox.setFlat(Value:Boolean);
begin
if FButton<>nil then
  if FButton.Flat<>Value then
    FButton.Flat:=Value;
end;

function TBDEComboBox.GetDropDownCount:integer;
begin
if FCombo<>nil then
  Result:=FCombo.DropDownCount
else Result:=-1;
end;

procedure TBDEComboBox.SetDropDownCount(Value:integer);
begin
if FCombo<>nil then
  begin
  FCombo.DropDownCount:=Value;
  end;
end;

function TBDEComboBox.GetDataSource:TDataSource;
begin
if FCombo<>nil then
  Result:=FCombo.DataSource
else Result:=nil;
end;

function TBDEComboBox.GetDataField:string;
begin
if FCombo<>nil then
  Result:=FCombo.DataField
else Result:='';
end;

procedure TBDEComboBox.SetDataSource(Value:TDataSource);
begin
if FCombo<>nil then
  begin
  FCombo.DataSource:=Value;
  end;
end;

procedure TBDEComboBox.SetDataField(Value:string);
begin
if FCombo<>nil then
  begin
  FCombo.DataField:=Value;
  end;
end;

constructor TBDEComboBox.Create(aOwner:TComponent);
begin
inherited Create(AOwner);
Width:=150;
Height:=21;
FCombo:=TCustomBDEComboBox.Create(self);
FCombo.Parent:=self;
with FCombo do
  begin
  SetBounds(0,0,GetComboWidth,Self.Height);
  Anchors:= [akLeft,akTop,akBottom,akRight];
  ParentFont:=true;
  end;
FButton:=TSpeedButton.Create(self);
FButton.Parent:=self;
with FButton do
  begin
  SetBounds(GetComboWidth+1,0,Self.Height,Self.Height);
  Anchors:= [akTop,akBottom,akRight];
  end;
end;

function TCustomBDEComboBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and
    FDataLink.UpdateAction(Action);
end;

function TCustomBDEComboBox.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TCustomBDEComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key in [VK_BACK, VK_DELETE, VK_UP, VK_DOWN, 32..255] then
  begin
    if not FDataLink.Edit and (Key in [VK_UP, VK_DOWN]) then
      Key := 0;
  end;
end;

procedure TCustomBDEComboBox.KeyPress(var Key: Char);
var TmpStr:string;
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
    not FDataLink.Field.IsValidChar(Key) then
  begin
    MessageBeep(0);
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, #32..#255:
      begin
      if SelLength<>0 then
        begin
        TmpStr:=Text;
        Delete(TmpStr,SelStart+1,SelLength);
        Text:=TmpStr;
        SelStart:=Length(text);
        end;
      end;
    #27:
      begin
        SelectAll;
      end;
  end;
end;

function TCustomBDEComboBox.GetComboText: string;
var
  I: Integer;
begin
  if Style in [csDropDown, csSimple] then Result := Text else
  begin
    I := ItemIndex;
    if I < 0 then Result := '' else Result := Items[I];
  end;
end;

procedure TCustomBDEComboBox.SetComboText(const Value: string);
var
  I: Integer;
  Redraw: Boolean;
begin
  if Value <> GetComboText then
  begin
    if Style <> csDropDown then
    begin
      Redraw := (Style <> csSimple) and HandleAllocated;
      if Redraw then SendMessage(Handle, WM_SETREDRAW, 0, 0);
      try
        if Value = '' then I := -1 else I := Items.IndexOf(Value);
        ItemIndex := I;
      finally
        if Redraw then
        begin
          SendMessage(Handle, WM_SETREDRAW, 1, 0);
          Invalidate;
        end;
      end;
      if I >= 0 then Exit;
    end;
    if Style in [csDropDown, csSimple] then Text := Value;
  end;
end;

procedure TCustomBDEComboBox.DataChange(Sender: TObject);
begin
  if not (Style = csSimple) and DroppedDown then Exit;
  if FDataLink.Field <> nil then
    {SetComboText(FDataLink.Field.Text)}
  else
    if csDesigning in ComponentState then
      SetComboText(Name)
    else
      SetComboText('');
end;

procedure TCustomBDEComboBox.UpdateData(Sender: TObject);
begin
  FDataLink.Field.Text := GetComboText;
end;

procedure TCustomBDEComboBox.EditingChange(Sender: TObject);
begin
  {SetEditReadOnly;}
end;

constructor TCustomBDEComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.Width:=100;
  ControlStyle := ControlStyle + [csReplicatable];
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FDataLink.OnEditingChange := EditingChange;
end;

destructor TCustomBDEComboBox.Destroy;
begin
{  FPaintControl.Free;}
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TCustomBDEComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
begin
  if not (csDesigning in ComponentState) then
    case Message.Msg of
      WM_LBUTTONDOWN:
        if (Style = csSimple) and (ComboWnd <> EditHandle) then
          if not FDataLink.Edit then Exit;
    end;
  inherited ComboWndProc(Message, ComboWnd, ComboProc);
end;

procedure TCustomBDEComboBox.Notification(AComponent: TComponent;Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TCustomBDEComboBox.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TCustomBDEComboBox.Change;
var TextLength:integer;
    Selection: TSelection;
begin
if (FDataLink.DataSet<>nil)and(FDataLink.FieldName<>'') then
  begin
  FDataLink.DataSet.Filter:='['+FDataLink.FieldName+']='+''''+Text+'*''';
  FDataLink.DataSet.Filtered:=true;
  if (Text<>'')and(not FDataLink.DataSet.IsEmpty) then
    begin
    TextLength:=Length(Text);
    Text:=FDataLink.Field.AsString;
    Selection.StartPos := TextLength;
    Selection.EndPos := Length(Text);
    SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Selection.StartPos,
      Selection.EndPos));
    end;
  FDataLink.DataSet.Filtered:=false;
  end;
inherited Change;
end;

function TCustomBDEComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TCustomBDEComboBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TCustomBDEComboBox.SetDataSource(Value:TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TCustomBDEComboBox.SetDataField(Value:string);
begin
  FDataLink.FieldName := Value;
end;

procedure TCustomBDEComboBox.DropDown;
begin
  if Assigned(OnDropDown) then
    OnDropDown(Self)
  else
    if Assigned(FDataLink.DataSource)and(FDataLink.Active)and(FDataLink.FieldName<>'') then
      begin
      Self.Items.Clear;
      FDataLink.DataSet.First;
      While not FDataLink.DataSet.Eof do
        begin
        Self.Items.Add(FDataLink.Field.AsString);
        FDataLink.DataSet.Next;
        end;
      end;
end;

procedure Register;
begin
  RegisterComponents('Standard', [TBDEComboBox]);
end;

end.
