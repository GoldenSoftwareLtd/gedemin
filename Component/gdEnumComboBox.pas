 {++

   Project COMPONENTS
   Copyright © 2002 by Golden Software

   Модуль

     gdEnumComboBox.pas

   Описание

     Компонент для перечислений

   Автор

     Julie

   История

     ver    date       who     what

     1.00   02.05.02   Julie   Первая версия
     1.01   15.05.02   JKL     Удалены лишие ссылки на at_Classes_body, gdcBase
     2.0    22.08.03   Julie   Исправлено ReadOnly, добавлен AutoComplete

 --}

unit gdEnumComboBox;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, dbctrls,
  ComCtrls, Contnrs, stdctrls, at_Classes, db, DbConsts;

type
  TgdEnumComboBox = class(TCustomComboBox)
  private
    FFieldSource: String;
    FEnumType: TatField;
    FEnumField: TatRelationField;
    FItemsList: TStringList;
    FFilter: String;

    FDataLink: TFieldDataLink;
    FPaintControl: TPaintControl;
    FAutoComplete: Boolean;
    FAutoDropDown: Boolean;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetComboText: string;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure SetComboText(const Value: string);
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetEditReadOnly;
    procedure SetItems(Value: TStrings);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetFieldSource(const Value: String);

  protected
    procedure Change; override;
    procedure Click; override;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
      ComboProc: Pointer); override;
    procedure CreateWnd; override;
    procedure DropDown; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure SetStyle(Value: TComboboxStyle); override;
    procedure WndProc(var Message: TMessage); override;

    procedure AddItems;
    procedure AssignEnumType;

    function GetCurrentValue: String; virtual;
    function GetCurrentCaption: String; virtual;

    function SelectItem(const AnItem: String): Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function UseRightToLeftAlignment: Boolean; override;
    property Field: TField read GetField;
    property Text;

    property CurrentValue: String read GetCurrentValue;

  published
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
    property Items write SetItems;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
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

    property FieldSource: String read FFieldSource write SetFieldSource;
    property AutoComplete: Boolean read FAutoComplete write FAutoComplete default True;
    property AutoDropDown: Boolean read FAutoDropDown write FAutoDropDown default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsNew', [TgdEnumComboBox]);
end;

{ TgdEnumComboBox }

procedure TgdEnumComboBox.AddItems;
var
  I: Integer;
  IsNullable: Boolean;
begin
  if not Assigned(FItemsList) then
  begin
    if FEnumType = nil then
      AssignEnumType;

    if FEnumField = nil then
      IsNullable := FEnumType.IsNullable
    else
      IsNullable := FEnumType.IsNullable and FEnumField.IsNullable;
    FItemsList := TStringlist.Create;
    FItemsList.Clear;
    if IsNullable then
      FItemsList.Add('');
    if FEnumType <> nil then
    begin
      for I := 0 to Length(FEnumType.Numerations) - 1 do
        FItemsList.Add(FEnumType.Numerations[I].Name);
    end;    
  end;
end;

procedure TgdEnumComboBox.AssignEnumType;

  function GetTableName(AField: TField): String;
  begin
    if AField = nil then
      Result := ''
    else
      Result := Copy(AField.Origin, 2, AnsiPos('.', AField.Origin) - 3)
  end;

  function GetFieldName(AField: TField): String;
  begin
    if AField = nil then
      Result := ''
    else
      Result := Copy(AField.Origin, AnsiPos('.', AField.Origin) + 2,
        Length(AField.Origin) - AnsiPos('.', AField.Origin) - 2);
  end;

begin
  Assert(atDataBase <> nil);
  if Assigned(FEnumType) then Exit;
  if (DataSource <> nil) and (DataField > '') then
  begin
    FEnumField := atDataBase.FindRelationField(GetTableName(Field),
      GetFieldName(Field));
    if FEnumField <> nil then
      FEnumType := FEnumField.Field;
  end
  else if FieldSource > '' then
    FEnumType := atDataBase.Fields.ByFieldName(FieldSource);
end;

procedure TgdEnumComboBox.DropDown;
begin
  if not (csDesigning in ComponentState) then
  begin
    inherited;
    AddItems;
    Items.Assign(FItemsList);
  end;
end;

function TgdEnumComboBox.GetCurrentValue: String;
begin
  if FEnumType = nil then
    Result := ''
  else
    Result := FEnumType.GetNumerationValue(Text);
end;

function TgdEnumComboBox.GetCurrentCaption: String;
begin
  if FEnumType = nil then
    Result := ''
  else
    Result := FEnumType.GetNumerationName(Field.AsString);
end;

constructor TgdEnumComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  FDataLink.OnEditingChange := EditingChange;
  FPaintControl := TPaintControl.Create(Self, 'COMBOBOX');
  FEnumType := nil;
  FEnumField := nil;
  FAutoComplete := True;
  FAutoDropDown := True;
//  FItemsList := TStringList.Create;
end;

destructor TgdEnumComboBox.Destroy;
begin
  FItemsList.Free;
  FPaintControl.Free;
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TgdEnumComboBox.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TgdEnumComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
  begin
    FDataLink.DataSource := nil;
  end;
end;

procedure TgdEnumComboBox.CreateWnd;
begin
  inherited CreateWnd;
  SetEditReadOnly;
end;

procedure TgdEnumComboBox.DataChange(Sender: TObject);
begin
  if not (Style = csSimple) and DroppedDown then Exit;
  if not (csDesigning in ComponentState) then
    AddItems;
  if FDataLink.Field <> nil then
    SetComboText(GetCurrentCaption)
  else
    if csDesigning in ComponentState then
      SetComboText(Name)
    else
      SetComboText('');
end;

procedure TgdEnumComboBox.UpdateData(Sender: TObject);
var
  Pt: TPoint;
  W: TWinControl;
begin
  FDataLink.Field.Text := GetCurrentValue;
  if (FDataLink.Field.Text = '') and ((Text > '')
    or (FDataLink.Field.Required)) then
  begin
    GetCursorPos(Pt);
    W := FindVCLWindow(Pt);
    if not((W <> nil) and (W is TButton) and TButton(W).Cancel) then
    begin
      raise Exception.Create('Неправильно указано значение поля!');
    end;
  end;
end;

procedure TgdEnumComboBox.SetComboText(const Value: string);
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

function TgdEnumComboBox.GetComboText: string;
var
  I: Integer;
begin
  if Style in [csDropDown, csSimple] then Result := Text else
  begin
    I := ItemIndex;
    if I < 0 then Result := '' else Result := Items[I];
  end;
end;

procedure TgdEnumComboBox.Change;
begin
  FDataLink.Edit;
  inherited Change;
  FDataLink.Modified;
end;

procedure TgdEnumComboBox.Click;
begin
  FDataLink.Edit;
  inherited Click;
  FDataLink.Modified;
end;

function TgdEnumComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgdEnumComboBox.SetDataSource(Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
  begin
    if FDataLink.DataSource <> Value then
    begin
      if Assigned(FDataLink.DataSource) then
        FDataLink.DataSource.RemoveFreeNotification(Self);
      FDataLink.DataSource := Value;
      if Value <> nil then
        Value.FreeNotification(Self);
    end;
  end;
end;

function TgdEnumComboBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TgdEnumComboBox.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TgdEnumComboBox.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TgdEnumComboBox.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
  if (Style in [csDropDown, csSimple]) and HandleAllocated then
    SendMessage(EditHandle, EM_SETREADONLY, Ord(not FDataLink.CanModify), 0);
end;

function TgdEnumComboBox.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TgdEnumComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Assigned(Field) then
    if Key in [VK_BACK, VK_DELETE, VK_UP, VK_DOWN, 32..255] then
    begin
      if not FDataLink.Edit and (Key in [VK_UP, VK_DOWN]) then
        Key := 0;
    end;
end;

procedure TgdEnumComboBox.KeyPress(var Key: Char);
{begin
  inherited KeyPress(Key);
  if Assigned(Field) then
  begin
    if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
      not FDataLink.Field.IsValidChar(Key) then
    begin
      MessageBeep(0);
      Key := #0;
    end;
    case Key of
      ^H, ^V, ^X, #32..#255:
        FDataLink.Edit;
      #27:
        begin
          FDataLink.Reset;
          SelectAll;
        end;
    end;
  end;}
  function HasSelectedText(var StartPos, EndPos: DWORD): Boolean;
  begin
    SendMessage(Handle, CB_GETEDITSEL, Integer(@StartPos), Integer(@EndPos));
    Result := EndPos > StartPos;
  end;

  procedure DeleteSelectedText;
  var
    StartPos, EndPos: DWORD;
    OldText: String;
  begin
    OldText := Text;
    SendMessage(Handle, CB_GETEDITSEL, Integer(@StartPos), Integer(@EndPos));
    Delete(OldText, StartPos + 1, EndPos - StartPos);
    SendMessage(Handle, CB_SETCURSEL, -1, 0);
    Text := OldText;
    SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(StartPos, StartPos));
  end;

var
  StartPos: DWORD;
  EndPos: DWORD;
  OldText: String;
  SaveText: String;
  Msg : TMSG;
  LastByte: Integer;
begin
  if ReadOnly then
  begin
    inherited KeyPress(Key);
    Exit;
  end;
  inherited KeyPress(Key);
  if not AutoComplete then exit;
  if Style in [csDropDown, csSimple] then
    FFilter := Text
  else
  begin
    FFilter := '';
  end;
  case Ord(Key) of
    VK_ESCAPE: exit;
    VK_TAB:
      if FAutoDropDown and DroppedDown then
        DroppedDown := False;
    VK_BACK:
      begin
        if HasSelectedText(StartPos, EndPos) then
          DeleteSelectedText
        else
          if (Style in [csDropDown, csSimple]) and (Length(Text) > 0) then
          begin
            SaveText := Text;
            LastByte := StartPos;
            while ByteType(SaveText, LastByte) = mbTrailByte do Dec(LastByte);
            OldText := Copy(SaveText, 1, LastByte - 1);
            SendMessage(Handle, CB_SETCURSEL, -1, 0);
            Text := OldText + Copy(SaveText, EndPos + 1, MaxInt);
            SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(LastByte - 1, LastByte - 1));
            FFilter := Text;
          end
          else
          begin
            while ByteType(FFilter, Length(FFilter)) = mbTrailByte do
              Delete(FFilter, Length(FFilter), 1);
            Delete(FFilter, Length(FFilter), 1);
          end;
        Key := #0;
        Change;
      end;
  else // case
    if FAutoDropDown and not DroppedDown then
      DroppedDown := True;
    if HasSelectedText(StartPos, EndPos) then
      SaveText := Copy(FFilter, 1, StartPos) + Key
    else
      SaveText := FFilter + Key;

    if Key in LeadBytes then
    begin
      if PeekMessage(Msg, Handle, 0, 0, PM_NOREMOVE) and (Msg.Message = WM_CHAR) then
      begin
        if SelectItem(SaveText + Char(Msg.wParam)) then
        begin
          PeekMessage(Msg, Handle, 0, 0, PM_REMOVE);
          Key := #0
        end;
      end;
    end
    else
      if SelectItem(SaveText) then
        Key := #0
  end; // case
end;

procedure TgdEnumComboBox.EditingChange(Sender: TObject);
begin
  SetEditReadOnly;
end;

procedure TgdEnumComboBox.SetEditReadOnly;
begin
  if (Style in [csDropDown, csSimple]) and HandleAllocated and (FDataLink.Field <> nil)then
    SendMessage(EditHandle, EM_SETREADONLY, Ord(not FDataLink.Editing), 0);
end;

procedure TgdEnumComboBox.WndProc(var Message: TMessage);
begin
  if not (csDesigning in ComponentState) then
    if Assigned(FDataLink) and Assigned(Field) then
      case Message.Msg of
        WM_COMMAND:
          if TWMCommand(Message).NotifyCode = CBN_SELCHANGE then
            if not FDataLink.Edit then
            begin
              if Style <> csSimple then
                PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
              Exit;
            end;
        CB_SHOWDROPDOWN:
          if Message.WParam <> 0 then FDataLink.Edit else
            if not FDataLink.Editing then DataChange(Self); {Restore text}
        WM_CREATE,
        WM_WINDOWPOSCHANGED,
        CM_FONTCHANGED:
          FPaintControl.DestroyHandle;
      end;
  inherited WndProc(Message);
end;

procedure TgdEnumComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
begin
  if not (csDesigning in ComponentState) then
    if (FDataLink <> nil) and (FDataLink.Field <> nil) then
    case Message.Msg of
      WM_LBUTTONDOWN:
        if (Style = csSimple) and (ComboWnd <> EditHandle) then
          if not FDataLink.Edit then Exit;
    end;
  inherited ComboWndProc(Message, ComboWnd, ComboProc);
end;

procedure TgdEnumComboBox.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if SysLocale.FarEast and (FDataLink.Field <> nil) and FDataLink.CanModify then
    SendMessage(EditHandle, EM_SETREADONLY, Ord(False), 0);
end;

procedure TgdEnumComboBox.CMExit(var Message: TCMExit);
begin
  try
    if FDataLink.Field <> nil then
      FDataLink.UpdateRecord
    else
      if (Text > '') and (GetCurrentValue = '') then
        raise Exception.Create('Неправильно указано значение поля!');
  except
    SelectAll;
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TgdEnumComboBox.WMPaint(var Message: TWMPaint);
var
  S: string;
  R: TRect;
  P: TPoint;
  Child: HWND;
begin
  if csPaintCopy in ControlState then
  begin
    if FDataLink.Field <> nil then S := FDataLink.Field.Text else S := '';
    if Style = csDropDown then
    begin
      SendMessage(FPaintControl.Handle, WM_SETTEXT, 0, Longint(PChar(S)));
      SendMessage(FPaintControl.Handle, WM_PAINT, Message.DC, 0);
      Child := GetWindow(FPaintControl.Handle, GW_CHILD);
      if Child <> 0 then
      begin
        Windows.GetClientRect(Child, R);
        Windows.MapWindowPoints(Child, FPaintControl.Handle, R.TopLeft, 2);
        GetWindowOrgEx(Message.DC, P);
        SetWindowOrgEx(Message.DC, P.X - R.Left, P.Y - R.Top, nil);
        IntersectClipRect(Message.DC, 0, 0, R.Right - R.Left, R.Bottom - R.Top);
        SendMessage(Child, WM_PAINT, Message.DC, 0);
      end;
    end else
    begin
      SendMessage(FPaintControl.Handle, CB_RESETCONTENT, 0, 0);
      if Items.IndexOf(S) <> -1 then
      begin
        SendMessage(FPaintControl.Handle, CB_ADDSTRING, 0, Longint(PChar(S)));
        SendMessage(FPaintControl.Handle, CB_SETCURSEL, 0, 0);
      end;
      SendMessage(FPaintControl.Handle, WM_PAINT, Message.DC, 0);
    end;
  end else
    inherited;
end;

procedure TgdEnumComboBox.SetItems(Value: TStrings);
begin
  Items.Assign(Value);
  DataChange(Self);
end;

procedure TgdEnumComboBox.SetStyle(Value: TComboboxStyle);
begin
  if (Value = csSimple) and Assigned(FDatalink) and FDatalink.DatasourceFixed then
    DatabaseError(SNotReplicatable);
  inherited SetStyle(Value);
end;

function TgdEnumComboBox.UseRightToLeftAlignment: Boolean;
begin
  Result := DBUseRightToLeftAlignment(Self, Field);
end;

procedure TgdEnumComboBox.CMGetDatalink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

function TgdEnumComboBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or (FDataLink <> nil) and
    FDataLink.ExecuteAction(Action);
end;

function TgdEnumComboBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and
    FDataLink.UpdateAction(Action);
end;

procedure TgdEnumComboBox.SetFieldSource(const Value: String);
begin
  FFieldSource := Value;
end;

function TgdEnumComboBox.SelectItem(const AnItem: String): Boolean;
var
  Idx: Integer;
  ValueChange: Boolean;
begin
  if Length(AnItem) = 0 then
  begin
    Result := False;
    ItemIndex := -1;
    Change;
    exit;
  end;
  Idx := SendMessage(Handle, CB_FINDSTRING, -1, LongInt(PChar(AnItem)));
  Result := (Idx <> CB_ERR);
  if not Result then exit;
  ValueChange := Idx <> ItemIndex;
  SendMessage(Handle, CB_SETCURSEL, Idx, 0);
  if (Style in [csDropDown, csSimple]) then
  begin
    Text := AnItem + Copy(Items[Idx], Length(AnItem) + 1, MaxInt);
    SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Length(AnItem), Length(Text)));
  end
  else
  begin
    ItemIndex := Idx;
    FFilter := AnItem;
  end;
  if ValueChange then
  begin
    Click;
    Change;
  end;
end;

end.
