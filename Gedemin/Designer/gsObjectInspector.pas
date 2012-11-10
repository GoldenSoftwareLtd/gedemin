{++
  Copyright (c) 2002 by Golden Software of Belarus

  Module

    gsObjectInspector

  Abstract

    Панель ObjectInspector для gsResizer
    пока работают только свойства

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit gsObjectInspector;

interface

uses
  stdctrls, classes, gsResizerInterface, extctrls, messages,
  forms, buttons, graphics, Controls, windows, Typinfo, contnrs,
  sysutils, gsPropertyEditor, ibsql;

const
  LEVEL_WIDTH = 12;

  ReadonlyProperties: array[0..0] of String = ('NAME');

type
  TPropertyType = (ptProperty, ptEvent);
  TInspPanel = class(TPanel)
  protected
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure Paint; override;
  end;

  TPropertyList = class;
  TgsObjectInspector = class;

  TProp = class(TObject)
  private
    FName: String;
    FDataType: TTypeKind;
    FEnumList: TStringList;
    FValue: String;
    FParent: TProp;
    FExpanded: Boolean;
    FHaveChildren: Boolean;
    FVisible: Boolean;
    FLevel: Integer;
    FReadOnly: Boolean;
    FClass: TClass;
    FPropertyEditor: TgsPropertyEditor;
    FTypeName: String;
    FButtonType: TButtonType;
    function SetPropertyValue(const AValue: String): boolean;
    function GetEnumList: TStringList;
    procedure SetExpanded(const Value: Boolean);
    function GetIsDefValue: boolean;
  protected
    FList: TPropertyList;

    constructor Create(AnOwner: TPropertyList; const AName: String; const AValue: Variant; const APropType: TTypeKind;
      APropEnum: TStringList; const ATypeName: String; AParent: TProp; const AReadOnly: Boolean; AClass: TClass); virtual;

    property Name: String read FName;
    property DataType: TTypeKind read FDataType;
    property EnumList: TStringList read GetEnumList;
    property Value: String read FValue; //write SetValue;
    property IsDefaultValue: boolean read GetIsDefValue;
    property Expanded: Boolean read FExpanded write SetExpanded;
    property PropertyEditor: TgsPropertyEditor read FPropertyEditor;
  public
    destructor Destroy; override;
  end;

  TPropertyList = class(TObjectList)
  private
    FInspector: TgsObjectInspector;

    function GetPropItem(const Index: Integer): TProp;
    function GetName(const Index: Integer): String;
    function GetValue(const Index: Integer): String;
    function GetVisibleCount: Integer;
  protected
  public
    function AbsoluteIndex(const Index: Integer): Integer;
    function VisibleIndex(const Index: Integer): Integer;
    function Add(const Name: String; const Value: Variant; const PropType: TTypeKind;
      PropEnum: TStringList; const TypeName: String; AParent: TProp; const AReadOnly: Boolean;
      AClass: TClass = nil): Integer; overload;

    function IndexByName(Value: TProp): Integer;

    constructor Create(AnOwner: TComponent);
    property VisibleCount: Integer read GetVisibleCount;
    property PropItem[const Index: Integer]: TProp read GetPropItem;
    property Name[const Index: Integer]: String read GetName;
    property Value[const Index: Integer]: String read GetValue;

  end;

  TInsPopupListbox = class(TListBox)
  private
    FSearchText: String;
    FSearchTickCount: Longint;
    FObjectInspector: TgsObjectInspector;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    property ObjectInspector: TgsObjectInspector read FObjectInspector write FObjectInspector;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TgsObjectInspector = class(TScrollBox)
  private
    { Private declarations }
    FEditor: TEdit;
    FSpliter: TPaintBox;
    FButtonDown: TSpeedButton;
    FButtonMore: TSpeedButton;
    FListBox: TInsPopupListBox;
    FInspectorPanel: TInspPanel;
    FBitmap: graphics.TBitmap;
    FBmpPlus: graphics.TBitmap;
    FBmpMinus: graphics.TBitmap;
    FRightSideColor: TColor;
    FLeftSideColor: TColor;
    FClassColor: TColor;
    FPropertyType: TPropertyType;
//    FCurrentComponent: TComponent;
//    FCurrentComponents: TComponentList;
    FCurrentComponents: TObjectList;
    FLeftSideWidth: Integer;
    FManager: IgsResizeManager;
    FSpliterWidth: Integer;

    FItemIndex: Integer;
    FItemList: TPropertyList;
    FRowHeight: Integer;
    FMouseDown: Boolean;
    FListVisible: Boolean;
    FClickTime: DWord;

//    FHintWindow: THintWindow;
    FHintTimer: TTimer;
    FLastIndex: Integer;
    FIsName: Boolean;

    procedure DoHintTimer(Sender: TObject);

    procedure SetRightSideColor(const Value: TColor);
    procedure SetLeftSideColor(const Value: TColor);
    procedure SetPropertyType(const Value: TPropertyType);
//    procedure SetCurrentComponent(Value: TComponent);
    procedure SetLeftSideWidth(const Value: Integer);
    procedure SetManager(Value: IgsResizeManager);

    procedure SpliterPaint(Sender: TObject);
    procedure SpliterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpliterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SpliterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpliterDoubleClick(Sender: TObject);
    procedure DrawOneLine(const Index: Integer; const A: Boolean);
    function GetTextRect(const Index: Integer): TRect;

    procedure GetComponentProperties;
    procedure GetComponentEvents;

    procedure SetItemIndex(Value: Integer);
    function SetItemValue(Value: Variant): boolean;

    procedure btnButtonDownOnClick(Sender: TObject);
    procedure btnButtonMoreOnClick(Sender: TObject);

    procedure EditorDblClick(Sender: TObject);
    procedure EditorClick(Sender: TObject);
    procedure EditorOnExit(Sender: TObject);

    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;

    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetManager: IgsResizeManager;
    procedure GetEventFunctions(ASL: TStrings; AIndex: integer);

  protected
    { Protected declarations }
    procedure Resize; override;

    procedure SetParent(AParent: TWinControl); override;

    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;

  public
    { Public declarations }
    constructor Create(Owner: TComponent);override;
    destructor Destroy; override;
    procedure CloseUp(const Save: Boolean);
    procedure RefreshProperties;
    procedure HidePopUp;
    procedure EventSync(const AnObjectName, AnEventName: String);
    procedure ShowHintWindow;

    function AddComponent(AComponent: TPersistent; const AShiftState: Boolean): Boolean;
    property Manager: IgsResizeManager read GetManager write SetManager;
    procedure UpdateProperty;
  published
    { Published declarations }
    property RightSideColor: TColor read FRightSideColor write SetRightSideColor;
    property LeftSideColor: TColor read FLeftSideColor write SetLeftSideColor;
    property ProperiesType: TPropertyType read FPropertyType write SetPropertyType;
    property LeftSideWidth: Integer read FLeftSideWidth write SetLeftSideWidth;
  end;

implementation

uses
  gsResizer, Dialogs, evt_i_Base, gdcBaseInterface, prp_frmGedeminProperty_Unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R gsObjectInspector.RES}

var
  FHintWindow: THintWindow;
  FHintCount: Integer;

type
  TComponentCracker = class(TComponent);
  
procedure QueryHintWindow;
begin
  if not Assigned(FHintWindow) then
  begin
    FHintWindow := THintWindow.Create(nil);
    FHintWindow.Canvas.Brush.Color := clInfoBk;
    FHintWindow.Color := clInfoBk;
  end;
  Inc(FHintCount);
end;

procedure ReleaseHintWindow;
begin
  Dec(FHintCount);
  if FHintCount = 0 then
    FreeAndNil(FHintWindow);
end;

function StringInArray(const S: String; A: Array of String): boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(A) to High(A) do
    if  UpperCase(A[I]) = UpperCase(S) then
    begin
      Result := True;
      Break;
    end;
end;

{ TgsObjectInspector }
function TgsObjectInspector.AddComponent(AComponent: TPersistent;
  const AShiftState: Boolean): Boolean;
var
  I, AIndex: Integer;
  OldProperty, S: String;
  P: TProp;
begin
  Result := True;

  if (FItemIndex <> -1) and FEditor.Modified then
  begin
    Result := SetItemValue(FEditor.Text);
  end;

  FEditor.Modified := False;
  if (FItemIndex <> -1) then
  begin
    AIndex := FItemList.AbsoluteIndex(FItemIndex);
    if not(Aindex < 0) then
    begin
      P := FItemList.PropItem[AIndex];
      OldProperty := FItemList.PropItem[AIndex].FName;
      while P.FParent <> nil do
      begin
        OldProperty := P.FParent.FName + '.' + OldProperty;
        P := P.FParent;
      end;
    end
  end
  else
    OldProperty := '';

  if not AShiftState then
    FCurrentComponents.Clear;

  FButtonDown.Visible := False;
  FButtonMore.Visible := False;
  FEditor.Modified := False;

  if AComponent = nil then Exit;

  I := FCurrentComponents.IndexOf(AComponent);

  if I > -1 then
    FCurrentComponents.Delete(I)
  else
    FCurrentComponents.Add(AComponent);


  if FCurrentComponents.Count > 0 then
  begin
    if FPropertyType = ptProperty then
      GetComponentProperties
    else
      GetComponentEvents;
    end
  else
    FItemList.Clear;

  if OldProperty <> '' then
  begin
    P := nil;
    repeat
      if Pos('.', OldProperty) > 0 then
      begin
        S := Copy(OldProperty, 0, Pos('.', OldProperty) - 1);
        OldProperty := Copy(OldProperty, Pos('.', OldProperty) + 1, Length(OldProperty));
      end
      else
        S := OldProperty;
        for I := 0 to FItemList.Count - 1 do
        begin
          if ((P = nil) and (FItemList.PropItem[I].Name = S))
            or ((P <> nil) and (FItemList.PropItem[I].FParent = P) and (FItemList.PropItem[I].Name = S)) then
          begin
            P := FItemList.PropItem[I];
            if S <> OldProperty then
              P.Expanded := True;
            Break;
          end;
        end;
    until S = OldProperty;
    if (P <> nil) and (P.Name = S) then
      FItemIndex := FItemList.VisibleIndex(I);
  end;
  Resize;
end;

procedure TgsObjectInspector.btnButtonDownOnClick(Sender: TObject);
var
  P: TPoint;
  AIndex, I: Integer;
  SL: TStringList;
begin
  AIndex := FItemList.AbsoluteIndex(FItemIndex);

  if FListVisible then
  begin
    CloseUp(False);
    FEditor.SetFocus;
  end
  else with FListBox do
  begin
    Items.Clear;
    Sorted := False;
    if Assigned(FItemlist.PropItem[Aindex].PropertyEditor) then
    begin
      if FCurrentComponents[0] is TComponent then
        FItemlist.PropItem[Aindex].PropertyEditor.CurrentComponent := TComponent(FCurrentComponents[0]);
      FItemlist.PropItem[Aindex].PropertyEditor.ObjectInspector := FManager.ObjectInspectorForm;
      if FItemlist.PropItem[Aindex].PropertyEditor.OwnerDrawCombo then
      begin
        FListBox.Style := lbOwnerDrawFixed;
        FListBox.OnDrawItem := FItemlist.PropItem[Aindex].PropertyEditor.OnComboDrawItem;
      end
      else
      begin
        FListBox.Style := lbStandard;
        FListBox.OnDrawItem := nil;
      end;
      FListBox.ItemHeight := FItemlist.PropItem[Aindex].PropertyEditor.ItemHeight;
    end
    else
    begin
      FListBox.Style := lbStandard;
      FListBox.OnDrawItem := nil;
      FListBox.ItemHeight := 11;
    end;

    SL := FItemList.PropItem[AIndex].EnumList;

    if Assigned(SL) then
      FListBox.Items.Assign(SL)
    else if FItemlist.PropItem[AIndex].DataType = tkMethod then
      GetEventFunctions(FListBox.Items, AIndex)
    else if (FItemList.PropItem[AIndex].DataType = tkClass) and
      (not FItemList.PropItem[AIndex].FHaveChildren) then
    begin
      for I := 0 to FManager.EditForm.ComponentCount - 1 do
        if (FManager.EditForm.Components[I] is FItemList.PropItem[AIndex].FClass) and
          (FManager.EditForm.Components[I] <> FCurrentComponents[0]) then
          FListBox.Items.Add(FManager.EditForm.Components[I].Name);
    end;
//    Sorted := True;

    if Items.Count > 0 then
    begin
      ItemIndex := Items.IndexOf(FEditor.Text);

      p := FEditor.ClientToScreen(Point(0, FEditor.Height));
      if Items.Count > 14 then
        Height :=  14 * (ItemHeight + 1) + 2
      else
        Height :=  Items.Count * (ItemHeight + 1) + 2;
      Width := FSpliter.Width - FLeftSideWidth - 2;

      SetWindowPos(Handle, HWND_TOP, P.X, P.Y, 0, 0,
        SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);

      FListVisible := True;
//1      Invalidate;
      Windows.SetFocus(FEditor.Handle);

    end;
  end;
end;
                      
procedure TgsObjectInspector.btnButtonMoreOnClick(Sender: TObject);
var
  AIndex, I: Integer;
  S: String;
  O, O1: TPersistent;
  CP: TProp;
  CC: TObject;
  Stack: TStack;
  CEL: TChangedEventList;

begin

  AIndex := FItemList.AbsoluteIndex(FItemIndex);

  if FItemlist.PropItem[Aindex].DataType = tkMethod then
  begin
    CEL:= FManager.ChangedEventList;
    i:= 0;
    if Assigned(CEL) then begin
      i:= CEL.FindByCompAndEvent(TComponent(FCurrentComponents[0]), FItemlist.PropItem[Aindex].Name);
      if i > -1 then
        i:= CEL[i].NewFunctionID
      else
        i:= 0;
    end;
    if Assigned(EventControl) and (FCurrentComponents[0] is TComponent) then
      EventControl.EditObject(TComponent(FCurrentComponents[0]), emEvent,
        FItemlist.PropItem[Aindex].Name, i);
  end
  else
    if Assigned(FItemlist.PropItem[Aindex].PropertyEditor) then
    begin

      if FItemlist.PropItem[Aindex].DataType = tkClass then
      begin
        CC := FCurrentComponents[0];
        CP := FItemlist.PropItem[Aindex];

        if FItemlist.PropItem[Aindex].FParent <> nil then
        begin
          Stack := TStack.Create;
          try
            while CP.FParent <> nil do
            begin
              Stack.Push(CP);
              CP := CP.FParent;
            end;

            while Stack.Count > 0 do
            begin
              if CP.FDataType = tkClass then
                CC := TPersistent(GetObjectProp(CC, CP.Name, TPersistent))
              else
                exit;
              CP := Stack.Pop;
            end;
          finally
            Stack.Free;
          end
        end;

        O := TPersistent(GetObjectProp(CC, CP.Name, TPersistent));

        if O = nil then
          Exit;
        if FCurrentComponents[0] is TComponent then
          FItemlist.PropItem[Aindex].PropertyEditor.CurrentComponent := TComponent(FCurrentComponents[0]);
        FItemlist.PropItem[Aindex].PropertyEditor.ObjectInspector := FManager.ObjectInspectorForm;
        if FItemlist.PropItem[Aindex].PropertyEditor.ShowExternalEditor(O) then
        begin
          if FItemlist.PropItem[Aindex].FHaveChildren then
//          FItemlist.FInspector.FManager.ChangedPropList.Add(FCurrentComponents[0], FItemlist.PropItem[Aindex].Name);
          for I := 1 to  FCurrentComponents.Count - 1 do
          begin
            O1 := TPersistent(GetObjectProp(FCurrentComponents[I], FItemlist.PropItem[Aindex].Name, TPersistent));
            O1.Assign(O);

//            FItemlist.FInspector.FManager.ChangedPropList.Add(FCurrentComponents[I], FItemlist.PropItem[Aindex].Name);
          end;
          RefreshProperties;
        end
      end
      else
      begin
        S := FItemlist.PropItem[Aindex].Value;
        if FItemlist.PropItem[Aindex].PropertyEditor.ShowExternalEditor(S) then
        begin
          FItemlist.PropItem[Aindex].SetPropertyValue(S);
        end;
      end;

    end;
end;


procedure TgsObjectInspector.CloseUp(const Save: Boolean);
var
  i, iIndex: integer;
begin
  if not (csDesigning in Self.ComponentState) then
  begin
    if FListVisible then
    begin
      if Save then
      begin
        if FListBox.ItemIndex > -1 then
        begin
          FEditor.Text:= FListBox.Items[FListBox.ItemIndex];
          iIndex := FItemList.AbsoluteIndex(FItemIndex);
          if FItemlist.PropItem[iIndex].DataType = tkMethod then begin
            FItemlist.PropItem[iIndex].FValue:= FEditor.Text;
            for i:= 0 to FCurrentComponents.Count - 1 do
              if FCurrentComponents[i] is TComponent then begin
                FManager.EventFunctionChanged(FCurrentComponents[i] as TComponent,
                  FItemlist.PropItem[iIndex].FName, integer(FListBox.Items.Objects[FListBox.ItemIndex]),
                  FEditor.Text);
              end;
          end
          else
            SetItemValue(FEditor.Text);
        end;
      end;
      SetWindowPos(FListBox.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
      FListVisible := False;
    end;
  end;
end;

procedure TgsObjectInspector.CMCancelMode(var Message: TCMCancelMode);
begin
  CloseUp(False);
end;

constructor TgsObjectInspector.Create(Owner: TComponent);
begin
  inherited Create(Owner);

  FLeftSideWidth := 70;
  HorzScrollBar.Visible := False;
  VertScrollBar.Visible := True;
  FItemIndex := -1;
  FListVisible := False;
  ShowHint := True;
  VertScrollBar.Tracking := True;
  AutoScroll := True;
  FRightSideColor := clNavy;
  FLeftSideColor := clBlack;
  FClassColor := clMaroon;

  FSpliterWidth := 3;
  FPropertyType := ptProperty;
//  FCurrentComponent := nil;

  FInspectorPanel := TInspPanel.Create(Self);
  FInspectorPanel.Parent := Self;
  FInspectorPanel.BevelInner := bvNone;
  FInspectorPanel.BevelOuter := bvNone;

  // FInspectorPanel.Align := alClient;
  if not (csDesigning in Self.ComponentState) then
  begin
    FItemList := TPropertyList.Create(Self);
    FBitmap := graphics.TBitmap.Create;

//**    FCurrentComponents := TComponentList.Create(False);
    FCurrentComponents := TObjectList.Create(False);

    FSpliter := TPaintBox.Create(FInspectorPanel);
    FSpliter.Parent := FInspectorPanel;
    FSpliter.Align := alClient;
    FSpliter.OnPaint := SpliterPaint;
    FSpliter.OnMouseDown := SpliterMouseDown;
    FSpliter.OnMouseMove := SpliterMouseMove;
    FSpliter.OnMouseUp := SpliterMouseUp;
    FSpliter.OnDblClick := SpliterDoubleClick;

    FSpliter.Font.Assign(Self.Font);

    FEditor := TEdit.Create(FInspectorPanel);
    FEditor.OnDblClick := EditorDblClick;
    FEditor.OnClick := EditorClick;
    FEditor.OnExit := EditorOnExit;

    FEditor.OnKeyDown := EditorKeyDown;
    FEditor.Parent := FInspectorPanel;
    FEditor.BorderStyle := bsNone;

    FEditor.Visible := False;

    FButtonDown := TSpeedButton.Create(FInspectorPanel);
    FButtonDown.Visible := False;
    FButtonDown.Parent := FInspectorPanel;
    FButtonDown.OnClick := btnButtonDownOnClick;
    FButtonDown.Glyph.LoadFromResourceName(hInstance, 'BTNDROPDOWN');

    FButtonMore := TSpeedButton.Create(FInspectorPanel);
    FButtonMore.Visible := False;
    FButtonMore.Parent := FInspectorPanel;
    FButtonMore.OnClick := btnButtonMoreOnClick;
    FButtonMore.Glyph.LoadFromResourceName(hInstance, 'BTNMORE');

    FBmpPlus := graphics.TBitmap.Create;
    FBmpPlus.LoadFromResourceName(hInstance, 'TREEPLUS');
    FBmpMinus := graphics.TBitmap.Create;
    FBmpMinus.LoadFromResourceName(hInstance, 'TREEMINUS');

    FListBox := TInsPopupListBox.Create(FInspectorPanel);
    FListBox.Parent := FInspectorPanel;

    FListBox.ObjectInspector := Self;

    QueryHintWindow;
{    FHintWindow := THintWindow.Create(Self);
    FHintWindow.Canvas.Brush.Color := clInfoBk;
    FHintWindow.Color := clInfoBk;}
    FHintTimer := TTimer.Create(Self);
    FHintTimer.Enabled := False;
    FHintTimer.Interval := 300;
    FHintTimer.OnTimer := DoHintTimer;
  end;

end;

destructor TgsObjectInspector.Destroy;
begin
  if not (csDesigning in Self.ComponentState) then
  begin
    if FPropertyType = ptProperty then
      KillEditors;
    FEditor.Free;
    FItemList.Free;
    FSpliter.Free;
    FBitmap.Free;
    FButtonDown.Free;
    FButtonMore.Free;
    FListBox.Free;
    FBmpPlus.Free;
    FBmpMinus.Free;
    FCurrentComponents.Free;
    FreeAndNil(FHintTimer);
    ReleaseHintWindow;
//    FreeAndNil(FHintWindow);
  end;

  FInspectorPanel.Free;
  inherited;
end;

procedure TgsObjectInspector.DoHintTimer(Sender: TObject);
var
  P: TPoint;
  HintStr: String;
  Rct: TRect;
begin
  (Sender as TTimer).Enabled := False;
  if Screen.ActiveForm <> Owner then
  begin
    FHintWindow.ReleaseHandle;
    Exit;
  end;
//  GetCursorPos(P);
  if (FLastIndex > -1) and (FLastIndex < FItemList.Count) then
  begin
//    FHintWindow.Canvas.Font.Size := FBitmap.Canvas.Font.Size;
    FHintWindow.Canvas.Font.Assign(FBitmap.Canvas.Font);
    if FIsName then
    begin
      HintStr := FItemList.PropItem[FLastIndex].Name;
      Rct := GetTextRect(FItemList.VisibleIndex(FLastIndex));
      P.x := Rct.Left;
      P.y := Rct.Top;
      if (Rct.Right - Rct.Left) > FHintWindow.Canvas.TextWidth(HintStr) then
        Exit;
    end else
    begin
      HintStr := FItemList.PropItem[FLastIndex].Value;
      Rct := GetTextRect(FItemList.VisibleIndex(FLastIndex));
      P.x := FLeftSideWidth;
      P.y := Rct.Top;
      if (FSpliter.Width - FLeftSideWidth) > FHintWindow.Canvas.TextWidth(HintStr) then
        Exit;
    end;
    if (Trim(HintStr) = '') then
      Exit;
    P := FSpliter.ClientToScreen(P);
    Rct := FHintWindow.CalcHintRect(640, HintStr, nil);
    OffsetRect(Rct, P.x, P.y);
    FHintWindow.ActivateHint(Rct, HintStr);
  end;

end;

function TgsObjectInspector.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
//  if FListVisible then Exit;
  if FListVisible then begin
    FListBox.DoMouseWheelDown(Shift, MousePos);
    Exit
  end;
  Self.VertScrollBar.Position:= Self.VertScrollBar.Position + FRowHeight;
  Invalidate;
  Result := True;
end;

function TgsObjectInspector.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
//  if FListVisible then Exit;
  if FListVisible then begin
    FListBox.DoMouseWheelUp(Shift, MousePos);
    Exit
  end;
  Self.VertScrollBar.Position := Self.VertScrollBar.Position - FRowHeight;
  Invalidate;
  Result := True;
end;

procedure TgsObjectInspector.DrawOneLine(const Index: Integer; const A: Boolean);
var
  R: TRect;
  AIndex: Integer;

  procedure Line(x, y, dx, dy: Integer);
  begin
    FBitmap.Canvas.MoveTo(x, y);
    FBitmap.Canvas.LineTo(x + dx, y + dy);
  end;

begin
  AIndex := FItemList.AbsoluteIndex(Index);

  if FItemList.Count > 0 then
  with FBitmap.Canvas do
  begin
    Brush.Color := clBtnFace;
    Pen.Color := clBtnShadow;
    Font.Name := 'MS Sans Serif';
    Font.Size := 8;
    if FItemList.PropItem[AIndex].IsDefaultValue then
      Font.Style := []
    else
      Font.Style := [fsBold];

    if (FItemList.PropItem[AIndex].FDataType = tkClass) and not Assigned(FItemList.PropItem[AIndex].FPropertyEditor)
        and (FItemList.PropItem[AIndex].FButtonType = btDown) then
      Font.Color := FClassColor
    else
      Font.Color := FLeftSideColor;
    R := GetTextRect(Index);
    if a then
    begin
      Pen.Color := clBtnShadow;
      Line(0, -2 + Index * FRowHeight, FSpliter.Width, 0);
      Line(FLeftSideWidth - 1, 0 + Index * FRowHeight, 0, FRowHeight);
      Pen.Color := clBlack;
      Line(0, -1 + Index * FRowHeight, FSpliter.Width, 0);
      Line(0, -1 + Index * FRowHeight, 0, FRowHeight + 1);
      Pen.Color := clBtnHighlight;
      Line(1, FRowHeight + -1 + Index * FRowHeight, FSpliter.Width{w} - 1, 0);
      Line(FEditor.Left, 0 + Index * FRowHeight, FEditor.Width, 0);
      Line(FLeftSideWidth, 0 + Index * FRowHeight, 0, FRowHeight);
      Line(FLeftSideWidth + 1, 0 + Index * FRowHeight, 0, FRowHeight);
      TextRect(R, 2 + LEVEL_WIDTH * FItemList.PropItem[AIndex].FLevel , 1 + Index * FRowHeight, FItemList.Name[AIndex]);
    end
    else
    begin
      Line(0, FRowHeight + -1 + Index * FRowHeight, FSpliter.Width, 0);
      Line(FLeftSideWidth - 1, 0 + Index * FRowHeight, 0, FRowHeight);
      Pen.Color := clBtnHighlight;
      Line(FLeftSideWidth, 0 + Index * FRowHeight, 0, FRowHeight);
      TextRect(R, 2 + LEVEL_WIDTH * FItemList.PropItem[AIndex].FLevel, 1 + Index * FRowHeight, FItemList.Name[AIndex]);
      Font.Color := FRightSideColor;
      TextOut(FLeftSideWidth + 2, 1 + Index * FRowHeight, FItemList.Value[AIndex]);
    end;

    if (FItemList.PropItem[AIndex].FHaveChildren) then
    begin
      if FItemList.PropItem[AIndex].FExpanded then
        Draw(2 + LEVEL_WIDTH * (FItemList.PropItem[AIndex].FLevel - 1), Index * FRowHeight + (FRowHeight div 2) - 5, FBmpMinus)
      else
        Draw(2 + LEVEL_WIDTH * (FItemList.PropItem[AIndex].FLevel - 1), Index * FRowHeight + (FRowHeight div 2) - 5, FBmpPlus);
    end;
  end;
end;

procedure TgsObjectInspector.EditorClick(Sender: TObject);
begin
  if GetTickCount - FClickTime < GetDoubleClickTime then
    EditorDblClick(nil);
end;

procedure TgsObjectInspector.EditorDblClick(Sender: TObject);
var
  AIndex, I: Integer;
  ObjName: String;
  Comp: TComponent;
begin
  if FPropertyType = ptEvent then
  begin
    if Assigned(FButtonMore) and FButtonMore.Visible then
      btnButtonMoreOnClick(FButtonMore);
  end
  else
  begin
    AIndex := FItemList.AbsoluteIndex(FItemIndex);
    case FItemList.PropItem[AIndex].DataType of
      tkEnumeration:
      begin
        Assert(Assigned(FItemList.PropItem[AIndex].EnumList));

        I := FItemList.PropItem[AIndex].EnumList.IndexOf(FEditor.Text) + 1;
        if I >= FItemList.PropItem[AIndex].EnumList.Count then
          I := 0;
        FEditor.Text := FItemList.PropItem[AIndex].EnumList[I];
        FEditor.SelectAll;
        FEditor.Modified := True;
        SetItemValue(FEditor.Text);
      end;
      tkClass:
      begin
        if GetKeyState(VK_CONTROL) < 0 then
        begin
          ObjName := FItemList.PropItem[AIndex].FValue;
          Comp := FManager.EditForm.FindComponent(ObjName);
          if Comp <> nil then
            FManager.ObjectInspectorForm.AddEditComponent(Comp, False);
        end
        else begin
          btnButtonMoreOnClick(nil);
        end;
      end;
      else begin
        if Assigned(FItemList.PropItem[AIndex].FPropertyEditor) then begin
          btnButtonMoreOnClick(nil);
          FEditor.Text:= ConvertGsPropertyToString(FItemList.PropItem[AIndex].FValue,
              FItemList.PropItem[AIndex].FPropertyEditor);
          FEditor.SelectAll;
          FEditor.Modified := True;
        end;
      end;
    end;
  end;
end;

procedure TgsObjectInspector.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{var
  CEL: TChangedEventList;
  i, iTmp: integer;}
begin
  if FListVisible then
  begin
    SendMessage(FListBox.Handle, WM_KEYDOWN, Key, 0);
    Key := 0;
    Exit;
  end;
  case Key of
    VK_RETURN: begin
      FItemList.PropItem[FItemList.AbsoluteIndex(FItemIndex)].SetPropertyValue(FEditor.Text);
    end;
    VK_UP:
      begin
        Key := 0;
        if FItemIndex <> 0 then SetItemIndex(FItemIndex - 1);
      end;
    VK_DOWN:
      if (ssAlt in Shift) and FButtonDown.Visible then
        btnButtonDownOnClick(nil)
      else
      begin
        Key := 0;
        SetItemIndex(FItemIndex + 1);
      end;
    VK_DELETE:
      begin
        if (FPropertyType = ptEvent) and (Length(FEditor.Text) = FEditor.SelLength) and (FCurrentComponents[0] is TComponent) then
        begin
{          CEL:= FManager.ChangedEventList;
          if Assigned(CEL) then begin
            for i:= 0 to FCurrentComponents.Count - 1 do begin
              iTmp:= CEL.FindByCompAndEvent(TComponent(FCurrentComponents[i]),
                FItemList.Name[FItemList.AbsoluteIndex(FItemIndex)]);
              if iTmp = -1 then
                CEL.Add(TComponent(FCurrentComponents[i]),
                  FItemList.Name[FItemList.AbsoluteIndex(FItemIndex)], -1, '')
              else begin
                CEL[iTmp].NewFunctionID:= -1;
                CEL[iTmp].FunctionName:= '';
                GetComponentEvents;
              end;
              FItemList.PropItem[FItemList.AbsoluteIndex(FItemIndex)].FValue:= '';
            end;
          end
          else if Assigned(EventControl) then }
            EventControl.DeleteEvent(FManager.EditForm.Name, TComponent(FCurrentComponents[0]).Name, FItemList.Name[FItemList.AbsoluteIndex(FItemIndex)]);
          FEditor.Text := '';
        end else
        if FButtonDown.Visible and (Length(FEditor.Text) = FEditor.SelLength) then
        begin
          FEditor.Text := '';
          FEditor.Modified := True;
        end;
      end;
  end;
end;

procedure TgsObjectInspector.EditorOnExit(Sender: TObject);
begin
  if (FItemIndex <> -1) and (FEditor.Modified) then
    SetItemValue(FEditor.Text);
end;

procedure TgsObjectInspector.EventSync(const AnObjectName,
  AnEventName: String);
var
  i: integer;
  CEL: TChangedEventList;
  Comp: TComponent;
begin
  Comp:= FManager.EditForm.FindComponent(AnObjectName);
  if Assigned(Comp) then begin
    CEL:= FManager.ChangedEventList;
    if Assigned(CEL) then begin
      i:= CEL.FindByCompAndEvent(Comp, AnEventName);
      if i > -1 then
        CEL.Delete(i);
    end;
  end;
  RefreshProperties;
  Resize;
end;

procedure TgsObjectInspector.GetComponentEvents;
var
  SL: TStringList;
  I, J, K: Integer;
  TempEvtList: TPropertyList;
begin
  FItemList.Clear;
  TempEvtList:= nil;
  SL:= TStringList.Create;

  try
    for i:= 0 to FCurrentComponents.Count - 1 do begin
      case i of
        0: TempEvtList:= FItemList;
        1: TempEvtList:= TPropertyList.Create(Self);
        else TempEvtList.Clear;
      end;
      if FCurrentComponents[i] is TComponent then begin
        EventControl.ObjectEventList(TComponent(FCurrentComponents[i]), SL);
        FManager.CheckForEventChanged(TComponent(FCurrentComponents[i]), SL);
      end
      else
        SL.Clear;
      if i = 0 then begin
        for j:= 0 to SL.Count - 1 do
          FItemList.Add(SL.Names[j], SL.Values[SL.Names[j]], tkMethod, nil, '', nil, True);
      end
      else begin
        for j:= 0 to SL.Count - 1 do
          TempEvtList.Add(SL.Names[j], SL.Values[SL.Names[j]], tkMethod, nil, '', nil, True);
        for j:= FItemList.Count - 1 downto 0 do
        begin
          k:= TempEvtList.IndexByName(FItemList.PropItem[j]);
          if k = -1 then
            FItemList.Delete(j)
          else if TempEvtList.PropItem[k].Value <> FItemList.PropItem[j].Value then
            FItemList.PropItem[j].FValue:= '';
        end;
      end;
    end
  finally
    SL.Free;
    if (TempEvtList <> FItemList) and Assigned(TempEvtList)then
      TempEvtList.Free;
  end

{  if (FCurrentComponents.Count = 1) and (FCurrentComponents[0] is TComponent) then
  begin
    if Assigned(EventControl) then
    begin
      SL := TStringList.Create;
      try
        EventControl.ObjectEventList(TComponent(FCurrentComponents[0]), SL);
        for I := 0 to SL.Count - 1 do
        begin
          FItemList.Add(SL.Names[I], SL.Values[SL.Names[I]], tkMethod, nil, '', nil, True);
        end;
      finally
        SL.Free;
      end;
    end;
  end;}


end;

procedure TgsObjectInspector.GetComponentProperties;
var
  TempPropList: TPropertyList;

  procedure GetObjTypeData(ClassTypeInfo: PTypeInfo; AnObject: TObject; AParent: TProp);
  var
    ClassTypeData: PTypeData;
    PropList: PPropList;
    TypeData: PTypeData;
    TypeInfo: PTypeInfo;
    I, J, Ind: Integer;
    ObjProp: TObject;

    NumProps: Integer;
    Value: Variant;
    MinValue, MaxValue, OrdMin, OrdMax: Int64;
    EnumList: TStringList;
    ROnly: Boolean;
    PropClass: TClass;

    function CheckEnumBoolValue(const Value, St: String): String;
    var
      S: String;
      I: Integer;
    begin
      Result := 'False';
      S := St;

      while True do
      begin
        I := Pos(Value, S);
        if I = 0 then Exit;
        if ((I + Length(Value)) > Length(S)) or (S[I + Length(Value)] = ',') or
            (S[I + Length(Value)] = ']')then
        begin
          Result := 'True';
          Break;
        end
        else
          S := Copy(S, I + Length(Value), Length(S));
      end
    end;
  begin
    ObjProp := nil;
    ClassTypeData := GetTypeData(ClassTypeInfo);

    if ClassTypeData.PropCount <> 0 then
    begin
      GetMem(PropList, SizeOf(PPropInfo) * ClassTypeData.PropCount);
      try

        NumProps := GetPropList(ClassTypeInfo, PropertyTypes, PropList);
        for I := 0 to NumProps - 1 do
        begin
          try
            PropClass := nil;
            EnumList := TStringList.Create;
            try
              if (AnObject = FManager.EditForm) and (PropList[I]^.Name = 'Position') then
                Value := GetEnumName(PropList[I]^.PropType^, Integer(FManager.FormPosition))
              else
                Value := GetPropValue(AnObject, PropList[I]^.Name, True);
            except
              EnumList.Free;
              continue;
            end;
            ROnly := PropList[I]^.SetProc = nil;
            TypeData := GetTypeData(PropList[I]^.PropType^);
            if not ROnly then
              ROnly := PropList[I]^.PropType^.Kind in [tkSet, {tkClass,} tkEnumeration];

            case PropList[I]^.PropType^.Kind of
              tkInteger, tkChar, tkWChar, tkEnumeration, tkSet:
                begin
                  MinValue := TypeData.MinValue;
                  MaxValue := TypeData.MaxValue;

                  if PropList[I]^.PropType^.Kind = tkEnumeration then
                  begin
                    if TypeData.BaseType^.Name = 'WordBool' then
                    begin
                      MinValue := 0;
                      MaxValue := 1;
                    end;

                    if (MaxValue - MinValue) <= 255 then
                      for J := MinValue To MaxValue do
                        EnumList.Add(GetEnumName(PropList[I]^.PropType^, J));
                    if AnObject is TControl then
                      if PropList[I]^.Name = 'Visible' then
                      begin
                        if FManager.InvisibleList.IndexOf(TControl(AnObject)) > -1 then
                          Value := 'False';
                      end;
                      if PropList[I]^.Name = 'TabVisible' then
                      begin
                        if FManager.InvisibleTabsList.IndexOf(TControl(AnObject)) > -1 then
                          Value := 'False';
                      end;
                  end;
                  if PropList[I]^.PropType^.Kind = tkSet then
                  begin
                    Value := '[' + Value + ']';
                  end;
                end;
              tkInt64: ;
              tkString: ;
              tkLString, tkWString, tkVariant: ; {Empty}
              tkClass:
                begin
                  ObjProp := GetObjectProp(AnObject, PropList[I]^.Name, TObject);
                  PropClass := TypeData.ClassType;
                  if ObjProp = nil then
                    Value := ''
                  else
                  begin
                    if ObjProp.InheritsFrom(TComponent) then
                      Value := TComponent(ObjProp).Name
                    else
                    begin
                      Value := '(' + TypeData.ClassType.ClassName + ')';
                      ROnly := True;
                    end
                  end;
                end;
                {, tkMethod, tkRecord, tkArray, tkFloat, , ,
        , , tkInterface, tkDynArray}
            end;

            if EnumList.Count = 0 then
            begin
              EnumList.Free;
              EnumList := nil;
            end;

            Ind := TempPropList.Add(PropList[I]^.Name , Value, PropList[I]^.PropType^.Kind , EnumList, PropList[I]^.PropType^.Name , AParent, ROnly, PropClass);
            if AnsiUpperCase(String(PropList[I]^.Name)) = 'NAME' then
            begin
              if (varType(Value) = varString) and (copy(String(Value), 1, 5) = GLOBALUSERCOMPONENT_PREFIX) then
                TempPropList.Add(cNameWithoutPrefix ,
                  Trim(copy(String(Value), 6, Length(String(Value)))),
                  tkString , nil, '' , nil, False);
            end;

            if PropList[I]^.PropType^.Kind = tkSet then
            begin
              if TypeData^.CompType^.Kind = tkEnumeration then
              begin
                TypeInfo := TypeData^.CompType^;
                TypeData := GetTypeData(TypeInfo);
                OrdMin := TypeData.MinValue;
                OrdMax := TypeData.MaxValue;

                for J := OrdMin To OrdMax do
                begin
                  EnumList := TStringList.Create;
                  EnumList.Add('False');
                  EnumList.Add('True');

                  TempPropList.Add(GetEnumName(TypeInfo, J), CheckEnumBoolValue(GetEnumName(TypeInfo, J), Value), tkEnumeration , EnumList, 'Boolean', TempPropList.PropItem[Ind], ROnly);
                end;
              end;
            end;
            if (PropList[I]^.PropType^.Kind = tkClass) then
            begin
              if (ObjProp <> nil) and (not ObjProp.InheritsFrom(TComponent)) then
                GetObjTypeData(TypeData.ClassType.ClassInfo, ObjProp, TempPropList.PropItem[Ind]);
              TempPropList.PropItem[Ind].FClass := TypeData.ClassType;
            end;

          except
            if Assigned(EnumList) and (EnumList.Count = 0) then
              FreeAndNil(EnumList);
          end;
        end;

      finally
        FreeMem(PropList, SizeOf(PPropInfo) * ClassTypeData.PropCount);
      end;
    end;
  end;
var
  I, J, K: Integer;
//  sl: TStringList;
begin
  TempPropList := nil;
  FItemList.Clear;
  try
    for I := 0 to FCurrentComponents.Count - 1 do
    begin
      case I of
        0: TempPropList := FItemList;
        1: TempPropList := TPropertyList.Create(Self);
        else TempPropList.Clear;
      end;
      GetObjTypeData(FCurrentComponents[I].ClassInfo, FCurrentComponents[I], nil);
      if I > 0 then
      begin
        for J := FItemList.Count - 1 downto 0 do
        begin
          K := TempPropList.IndexByName(FItemList.PropItem[J]);
          if K = -1 then
            FItemList.Delete(J)
          else
            if TempPropList.PropItem[K].Value <> FItemList.PropItem[J].Value then
              FItemList.PropItem[J].FValue := '';
        end;
      end;
    end
  finally
    if TempPropList <> FItemList then
      TempPropList.Free;
    TempPropList := nil;
  end
end;

procedure TgsObjectInspector.GetEventFunctions(ASL: TStrings; AIndex: integer);
var
  SQL: TIBSQL;
  I: Integer;
begin
  if ASL = nil then Exit;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction:= gdcBaseManager.ReadTransaction;
    SQL.SQL.Text:=
      'SELECT DISTINCT g.name, g.id FROM gd_function g, ' +
      '  evt_object o1, evt_object o2 WHERE o2.id = g.modulecode AND ' +
      '  UPPER(g.event) = UPPER(:eventname) AND ' +
      '  UPPER(o1.Name) = UPPER(:formname) AND o1.lb <= o2.lb AND ' +
      '  o1.rb >= o2.rb';
    SQL.Params[0].AsString:= FItemList.PropItem[AIndex].FName;
    SQL.Params[1].AsString:= FManager.EditForm.Name;
    SQL.ExecQuery;
    while not SQL.Eof do begin
      I:= ASL.Add(SQL.Fields[0].AsString);
      ASL.Objects[I]:= Pointer(SQL.Fields[1].AsInteger);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

function TgsObjectInspector.GetManager: IgsResizeManager;
begin
  Result := FManager;
end;

function TgsObjectInspector.GetTextRect(const Index: Integer): TRect;
var
  AIndex: Integer;
begin
  AIndex := FItemList.AbsoluteIndex(Index);
  Result := Rect(2 + LEVEL_WIDTH * FItemList.PropItem[AIndex].FLevel, Index * FRowHeight + 1, FLeftSideWidth{w1} - 2, Index * FRowHeight + FRowHeight - 1);
end;

procedure TgsObjectInspector.HidePopUp;
begin
  //
end;

procedure TgsObjectInspector.RefreshProperties;
var
  I, AIndex: Integer;
  OldProperty, S, SS: String;
  P: TProp;

begin
  if (FItemIndex <> -1) then
  begin
    AIndex := FItemList.AbsoluteIndex(FItemIndex);
    if AIndex < 0 then
      Exit;
    P := FItemList.PropItem[AIndex];
    OldProperty := FItemList.PropItem[AIndex].FName;
    while P.FParent <> nil do
    begin
      OldProperty := P.FParent.FName + '.' + OldProperty;
      P := P.FParent;
    end;
  end
  else
    OldProperty := '';
  SS := OldProperty;
  if FPropertyType = ptProperty then
    GetComponentProperties
  else
    GetComponentEvents;

  if OldProperty <> '' then
  begin
    P := nil;
    repeat
      if Pos('.', OldProperty) > 0 then
      begin
        S := Copy(OldProperty, 0, Pos('.', OldProperty) - 1);
        OldProperty := Copy(OldProperty, Pos('.', OldProperty) + 1, Length(OldProperty));
      end
      else
        S := OldProperty;
      for I := 0 to FItemList.Count - 1 do
      begin
        if (P = nil) and (FItemList.PropItem[I].FParent = nil) and (FItemList.PropItem[I].Name = S) then
        begin
          P := FItemList.PropItem[I];
          if (S = OldProperty) then
            Break;
          if S <> OldProperty then
             P.Expanded := True;
        end
        else
        begin
          if (P <> nil) and (FItemList.PropItem[I].FParent = P) and (FItemList.PropItem[I].Name = S) then
          begin
            P := FItemList.PropItem[I];
            if (S = OldProperty) then
              Break;
            if S <> OldProperty then
              P.Expanded := True;
          end;
        end;
      end;
    until S = OldProperty;
    if (P <> nil) and (P.Name = S) then
      //FItemIndex := FItemList.VisibleIndex(I);
      SetItemIndex(FItemList.VisibleIndex(I))
  end;
end;

procedure TgsObjectInspector.Resize;
begin
  inherited;
  if not (csDesigning in Self.ComponentState) then
  begin
    if FListVisible then
      CloseUp(False);

    FInspectorPanel.Height := FItemList.VisibleCount * FRowHeight;
    FInspectorPanel.Width := ClientWidth;
    FInspectorPanel.Realign;
    SetItemIndex(FItemIndex);
  end;
end;

{procedure TgsObjectInspector.SetCurrentComponent(Value: TComponent);
begin
  if Value <> FCurrentComponent then
  begin
    if (FItemIndex <> -1) and FEditor.Modified and
       (not SetItemValue(FEditor.Text)) then
      Exit;

    FButtonDown.Visible := False;
    FButtonMore.Visible := False;
    FEditor.Modified := False;
    FCurrentComponent := Value;
    if Value <> nil then
    begin
      if FPropertyType = ptProperty then
        GetComponentProperties
      else
        GetComponentEvents;
    end
    else
      FItemList.Clear;
    Resize;
  end;
end;}

procedure TgsObjectInspector.SetItemIndex(Value: Integer);
var
  ww, y: Integer;
  AIndex: Integer;
begin
//  if BusyFlag1 then Exit;
  if FListVisible then CloseUp(False);
  if Value > FItemList.VisibleCount - 1 then
    Value := FItemList.VisibleCount - 1;

  FEditor.Visible := (FItemList.VisibleCount > 0) and (Value > -1);

  AIndex := FItemList.AbsoluteIndex(Value);

  if (FItemIndex <> -1) and (FEditor.Modified) then
  begin
    if (not SetItemValue(FEditor.Text)) then
      Exit;
    FItemIndex := FItemList.VisibleIndex(AIndex)
  end
  else
    FItemIndex := Value;

  FEditor.Modified := False;

  FSpliter.Invalidate;
  if FItemIndex = -1 then Exit;

  ww := FSpliter.Width {w} - FLeftSideWidth {w1} - 2;
  y := FItemIndex * FRowHeight;// + 1;

  FButtonDown.Visible := False;
  FButtonMore.Visible := False;
  FButtonMore.Enabled:= True;

  //Button more
  if (FItemList.PropItem[AIndex].FButtonType = btMore) then
  begin
    FButtonMore.Top := Y;
    FButtonMore.Left := FLeftSideWidth + 2 + ww - FRowHeight;
    ww := ww - FRowHeight;
    FButtonMore.Visible := True;
  end
  else if FItemList.PropItem[AIndex].FButtonType = btDown {or   // Button Down
       ((FItemList.PropItem[AIndex].DataType = tkClass) and
        (not FItemList.PropItem[AIndex].FHaveChildren)) }then
  begin
    FButtonDown.Top := Y;
    FButtonDown.Left := FLeftSideWidth + 2 + ww - FRowHeight;
    ww := ww - FRowHeight;
    FButtonDown.Visible := True;
  end
  else if FItemList.PropItem[AIndex].FButtonType = btBoth then
  begin
    FButtonDown.Top := Y;
    FButtonDown.Left := FLeftSideWidth + 3 + ww - FRowHeight - FButtonDown.Width;
    FButtonDown.Visible := True;
    FButtonMore.Top := Y;
    FButtonMore.Left := FLeftSideWidth + 3 + ww - FRowHeight;
    ww := ww - FRowHeight * 2;
    FButtonMore.Visible := True;
    FButtonMore.Enabled:= (FCurrentComponents.Count = 1) or
      ((FCurrentComponents.Count > 1) and (FEditor.Text <> ''));
  end;

  FEditor.Text := FItemList.Value[AIndex];

  FEditor.SetBounds(FLeftSideWidth + 2, y, ww + 1, FRowHeight - 1);
  FEditor.SelectAll;
  FEditor.Modified := False;
 { if (FItemList.PropItem[Aindex].FDataType = tkClass) and FButtonDown.Visible then
    FEditor.ReadOnly := False
  else}
  FEditor.ReadOnly := FItemList.PropItem[Aindex].FReadOnly;

  if y + FRowHeight > VertScrollBar.Position + ClientHeight then
    VertScrollBar.Position := y - ClientHeight + FRowHeight;
  if y < VertScrollBar.Position then
    VertScrollBar.Position := y - 1;


{  if Assigned(FButtonDown) then
    FButtonDown.Invalidate;
  if Assigned(FButtonMore) then
    FButtonMore.Invalidate;}
end;

function TgsObjectInspector.SetItemValue(Value: Variant): boolean;
var
  Prop: TProp;
  AName: String;

begin
  Prop := FItemList.PropItem[FItemList.AbsoluteIndex(FItemIndex)];
  AName := Prop.FName;
  Result := Prop.SetPropertyValue(Value);
  FItemList.FInspector.RefreshProperties;
  if Result then
    if AName = 'Name without prefix' then
      FItemList.FInspector.Manager.ObjectInspectorForm.RefreshList;
end;

procedure TgsObjectInspector.SetLeftSideColor(const Value: TColor);
begin
  if Value <> FLeftSideColor then
  begin
    FLeftSideColor := Value;
    Resize;
  end;
end;

procedure TgsObjectInspector.SetLeftSideWidth(const Value: Integer);
begin
  if Value <> FLeftSideWidth then
  begin
    FLeftSideWidth := Value;
    Resize;
  end;
end;

procedure TgsObjectInspector.SetManager(Value: IgsResizeManager);
begin
  FManager := Value
end;

procedure TgsObjectInspector.SetParent(AParent: TWinControl);
begin
  inherited;
  if Assigned(AParent) then
  begin
    if not (csDesigning in Self.ComponentState) then
    begin
      FRowHeight := FSpliter.Canvas.TextHeight('Wg') + 3;
      SetWindowPos(FListBox.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);

      FEditor.Height := FRowHeight;
      FButtonDown.Height := FRowHeight - 1;
      FButtonDown.Width := FRowHeight - 1;
      FButtonMore.Height := FRowHeight - 1;
      FButtonMore.Width := FRowHeight - 1;
      VertScrollBar.Increment := FRowHeight;

      Resize;
    end;
  end;
end;

procedure TgsObjectInspector.SetPropertyType(const Value: TPropertyType);
begin
  if Value <> FPropertyType then
  begin
    FPropertyType := Value;
    Resize;
  end;
end;

procedure TgsObjectInspector.SetRightSideColor(const Value: TColor);
begin
  if Value <> FRightSideColor then
  begin
    FRightSideColor := Value;
    Resize;
  end;
end;

procedure TgsObjectInspector.ShowHintWindow;
var
  P: TPoint;
  LIndex: Integer;
  LIsName: Boolean;
begin
  GetCursorPos(P);
  P := FSpliter.ScreenToClient(P);
  if P.y < 0 then
    LIndex := -1
  else
    LIndex := P.y div FRowHeight;
  LIsName := P.x <= FLeftSideWidth;

  if (Screen.ActiveForm <> Owner) or (FItemIndex = LIndex)
    {(Assigned(Screen.ActiveForm) and (Screen.ActiveForm.ActiveControl <> Self)) }then
  begin
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    Exit;
  end;

  if LIndex > FItemList.Count - 1 then
  begin
    FHintTimer.Enabled := False;
    FLastIndex := -1;
    Exit;
  end;
  LIndex := FItemList.AbsoluteIndex(LIndex);

  if (FLastIndex <> LIndex) or (LIsName <> FIsName) then
  begin
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    FHintTimer.Enabled := True;
  end;
  FLastIndex := LIndex;
  FIsName := LIsName;
end;

procedure TgsObjectInspector.SpliterDoubleClick(Sender: TObject);
var
  AIndex: Integer;
begin
  if FItemIndex <> -1 then
  begin
    AIndex := FItemList.AbsoluteIndex(FItemIndex);
    if FItemList.PropItem[AIndex].FHaveChildren then
      FItemList.PropItem[AIndex].Expanded :=  not FItemList.PropItem[AIndex].FExpanded;
    Resize;
  end;
end;

procedure TgsObjectInspector.SpliterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  NewIndex: Integer;

begin
  if Button = mbLeft then
  begin
    FClickTime := GetTickCount;
    if FListVisible then CloseUp(False);

    if FSpliter.Cursor = crHSplit then
      FMouseDown := True
    else
    begin
      NewIndex := Y div FRowHeight;

      if NewIndex > FItemList.Count - 1 then
        NewIndex := FItemList.Count - 1;

      SetItemIndex(NewIndex);
      if FEditor.Visible then
        FEditor.SetFocus;
    end;
  end;
end;

procedure TgsObjectInspector.SpliterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not FMouseDown then
  begin
    ShowHintWindow;
    if (X > FLeftSideWidth - 2) and (X < FLeftSideWidth + 2) then
      FSpliter.Cursor := crHSplit else
      FSpliter.Cursor := crDefault
  end else
  begin
    if (x > FRowHeight) and (X < (FSpliter.Width - FRowHeight - GetSystemMetrics(SM_CXVSCROLL))) then
    begin
      FLeftSideWidth := X;
      Resize;
    end;  
  end;
end;

procedure TgsObjectInspector.SpliterMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := False;
end;


procedure TgsObjectInspector.SpliterPaint(Sender: TObject);
var
  I: Integer;
  R: TRect;
begin
  R := FSpliter.BoundsRect;
  FBitmap.Width := FSpliter.Width;
  FBitmap.Height := FSpliter.Height;
  FBitmap.Canvas.Brush.Color := clBtnFace;
  FBitmap.Canvas.FillRect(R);

  for I := 0 to FItemList.VisibleCount - 1 do
    DrawOneLine(I, False);

  if FItemIndex <> -1 then DrawOneLine(FItemIndex, True);

  FSpliter.Canvas.Draw(0, 0, FBitmap);
end;

procedure TgsObjectInspector.UpdateProperty;
begin
  if Assigned(FEditor) then
    EditorOnExit(FEditor);
end;

procedure TgsObjectInspector.WMKillFocus(var Message: TMessage);
begin
  inherited;
  CloseUp(False);
end;

{ TInspPanel }

procedure TInspPanel.Paint;
begin
  if csDesigning in Self.ComponentState then
    inherited;
end;

procedure TInspPanel.WMEraseBackground(var Message: TMessage);
begin
//
  if csDesigning in Self.ComponentState then
    inherited;
end;

{ TProp }

constructor TProp.Create(AnOwner: TPropertyList; const AName: String; const AValue: Variant;
  const APropType: TTypeKind; APropEnum: TStringList; const ATypeName: String;
  AParent: TProp; const AReadOnly: Boolean; AClass: TClass);
var
  FV: TStringList;

begin

  inherited Create;
  FList := AnOwner;
  FName := AName;
  FValue := AValue;
  FDataType := APropType;
  FEnumList := APropEnum;
  FTypeName := ATypeName;
  FParent := AParent;
  FExpanded := False;
  FReadOnly := AReadOnly;

{or ((FDataType = tkClass) and
     (not FItemList.PropItem[AIndex].FHaveChildren) and
     (FItemList.PropItem[AIndex].FSelfObject <> nil) and
     (not FItemList.PropItem[AIndex].FSelfObject.InheritsFrom(TComponent)))}

  if (FDataType = tkMethod) then
  begin
//    FButtonType := btMore;
    FButtonType := btBoth;
    FPropertyEditor := nil;
  end
  else
  begin
    FPropertyEditor := GetGsPropertyEditor(FTypeName, FName, AClass, FList.FInspector.FManager.ObjectInspectorForm);
    FValue := ConvertGsPropertyToString(FValue, FPropertyEditor);
    if (FDataType = tkEnumeration) or (FDataType = tkClass) then
      FButtonType := btDown
    else
      FButtonType := btNone;
  end;

  if Assigned(FPropertyEditor) then
  begin
    if (FList.FInspector.FCurrentComponents.Count > 0) and
      (FList.FInspector.FCurrentComponents[0] is TComponent) then
    FPropertyEditor.CurrentComponent := TComponent(FList.FInspector.FCurrentComponents[0]);


    if FPropertyEditor.ButtonType <> btDefault then
      FButtonType := FPropertyEditor.ButtonType;

    FV := FPropertyEditor.Values;
    if (Assigned(FV)) then
    begin
      if Assigned(FEnumList) then
        FEnumList.Clear
      else
        FEnumList := TStringList.Create;
      FEnumList.Assign(FV);
    end;
  end;

  if FParent = nil then
  begin
    FVisible := True;
    FLevel := 1;
    if not FReadOnly then
      FReadOnly := StringInArray(FName, ReadonlyProperties);
  end
  else
  begin
    FVisible := False;
    FLevel := FParent.FLevel + 1;
    FParent.FHaveChildren := True;
    if FParent.FButtonType <> btMore then
       FParent.FButtonType := btNone;
  end;
end;

destructor TProp.Destroy;
begin
  FEnumList.Free;
end;

function TProp.GetEnumList: TStringList;
begin
  if Assigned(FPropertyEditor) and (FPropertyEditor.ButtonType = btDown) and
    (not FPropertyEditor.Static) then
    Result := FPropertyEditor.Values
  else
    Result := FEnumList;

end;

function TProp.GetIsDefValue: boolean;

  function IsDefValue(Instance: TPersistent; Prop: TProp): boolean;
  var
    PropInfo: PPropInfo;
    iValue, iVal, iDefVal, i: Longint;
    Obj: TObject;
  begin
    Result:= False;
    PropInfo:= GetPropInfo(Instance, Prop.FName, tkAny);
    if not Assigned(PropInfo) then begin
      if Assigned(Prop.FParent) then begin
        case FParent.FDataType of
          tkSet: begin
            PropInfo:= GetPropInfo(Instance, Prop.FParent.FName, tkAny);
            if not Assigned(PropInfo) then Exit;
            iVal:= GetEnumValue(GetTypeData(PropInfo^.PropType^)^.CompType^, Prop.FName);
            iValue:= GetOrdProp(Instance, PropInfo);
            iDefVal:= PPropInfo(PropInfo)^.Default;
            Result:= ((iVal in TIntegerSet(iDefVal)) and (iVal in TIntegerSet(iValue)))
              or (not (iVal in TIntegerSet(iDefVal)) and not (iVal in TIntegerSet(iValue)));
            if Result then Exit;
          end;
          tkClass: begin
            PropInfo:= GetPropInfo(Instance, Prop.FParent.FName, tkAny);
            if not Assigned(PropInfo) then Exit;
            Obj:= TObject(GetOrdProp(Instance, PropInfo));
            if not Assigned(Obj) then
              Result:= True
            else if Obj is TPersistent then begin
              Result:= IsDefValue(TPersistent(Obj), Prop)
            end;
          end;
        end;
      end
      else
        Exit;
    end
    else begin
      case PPropInfo(PropInfo)^.PropType^^.Kind of
        tkInteger, tkChar, tkEnumeration, tkSet: begin
          iValue:= GetOrdProp(Instance, PropInfo);
          Result:= iValue = PPropInfo(PropInfo)^.Default;
        end;
        tkClass: begin
          Obj:= TObject(GetOrdProp(Instance, PropInfo));
          if not Assigned(Obj) and not Prop.FHaveChildren then
            Result:= Prop.FValue = ''
          else if Prop.FHaveChildren then begin
            for i:= 0 to FList.Count - 1 do begin
              Result:= True;
              if (FList.PropItem[I].FParent = Prop) and not IsDefValue(TPersistent(Obj), FList.PropItem[I]) then begin
                Result:= False;
                Exit;
              end
            end;
          end
          else
              Result:=
                ((Obj is TPicture) and (not Assigned(TPicture(Obj).Graphic) or TPicture(Obj).Graphic.Empty)) or
                ((Obj is TGraphic) and TGraphic(Obj).Empty) or
                ((Obj is TList) and (TList(Obj).Count = 0)) or
                ((Obj is TCollection) and (TCollection(Obj).Count = 0)) or
                ((Obj is TStrings) and (TStrings(Obj).Count = 0));
        end;
        tkString, tkLString, tkWString: begin
          Result:= Prop.FValue = '';
        end;
      end;
    end;
  end;

begin
  Result:= False;

  if FDataType = tkMethod then begin
    Result:= FValue = ''; 
  end
  else if (FList.FInspector.FCurrentComponents.Count > 0)
    and (FList.FInspector.FCurrentComponents[0] is TPersistent) then
  begin
    try
      Result:= IsDefValue(TPersistent(FList.FInspector.FCurrentComponents[0]), Self);
    except
    end;
  end;
end;

procedure TProp.SetExpanded(const Value: Boolean);
var
  I: Integer;
begin
  FExpanded := Value;
  for I := 0 to FList.Count - 1 do
  begin
    if FList.PropItem[I].FParent = Self then
    begin
      FList.PropItem[I].FVisible := FExpanded;
      if (not FExpanded) and FList.PropItem[I].FHaveChildren then
        FList.PropItem[I].Expanded := False;
    end;

  end;
end;


function TProp.SetPropertyValue(const AValue: String): boolean;
  function GetSetValue(SetProp: TProp): String;
  var
    I: Integer;
  begin
    Result := '[';
    for I := 0 to FList.Count - 1 do
    begin
      if (FList.PropItem[I].FParent = SetProp) and (FList.PropItem[I].FValue = 'True') then
      begin
        if Result <> '[' then
          Result := Result + ',';
        Result := Result + FList.PropItem[I].FName;
      end;
    end;
    Result := Result + ']';
  end;
var
  AName, OldValue: String;
  P: TProp;
  Res: String;
  I: Integer;
begin

  Result := True;
  OldValue:= GLOBALUSERCOMPONENT_PREFIX + FValue;
  FValue := ConvertGsStringToProperty(AValue, FPropertyEditor);
  AName := FName;

  if FParent <> nil then
  begin
    if FParent.FDataType = tkSet then
    begin
      Result := FParent.SetPropertyValue(GetSetValue(FParent));
      Exit;
    end else
    begin
      P := Self;
      while P.FParent <> nil do
      begin
        P := P.FParent;
        AName := P.FName + '.' + AName;
      end;
    end;
  end;

{  if FList.FInspector.FCurrentComponents[0] is TCollectionItem then
  begin
     TCollectionItem(FList.FInspector.FCurrentComponents[0]).
  end;}
  if FList.FInspector.FCurrentComponents.Count = 0 then
    Exit; 
  if FList.FInspector.FCurrentComponents[0] is TCustomForm then
  begin
    if AName = 'BorderStyle' then
    begin
      if (FValue = 'bsSizeable') or (FValue = 'bsSizeToolWin') then
      begin
        FList.FInspector.FManager.ChangedPropList.Add(FList.FInspector.FCurrentComponents[0], 'Height');
        FList.FInspector.FManager.ChangedPropList.Add(FList.FInspector.FCurrentComponents[0], 'Width');
      end
      else
      begin
        FList.FInspector.FManager.ChangedPropList.Add(FList.FInspector.FCurrentComponents[0], 'ClientHeight');
        FList.FInspector.FManager.ChangedPropList.Add(FList.FInspector.FCurrentComponents[0], 'ClientWidth');
      end;
    end;
  end;

  if (AName = 'Visible') and (FList.FInspector.FCurrentComponents[0] is TControl) then
  begin
    for I := 0 to FList.FInspector.FCurrentComponents.Count - 1 do
    begin
      if FValue = 'True' then
        FList.FInspector.FManager.InvisibleList.DeleteControl(FList.FInspector.FCurrentComponents[I] As TControl)
      else
        FList.FInspector.FManager.InvisibleList.Add(FList.FInspector.FCurrentComponents[I] As TControl);
//      FList.FInspector.FManager.ChangedPropList.Add(FList.FInspector.FCurrentComponents[I], 'Visible')
    end;
  end
  else if (AName = 'TabVisible') and (FList.FInspector.FCurrentComponents[0] is TControl) then
  begin
    for I := 0 to FList.FInspector.FCurrentComponents.Count - 1 do
    begin
      if FValue = 'True' then
        FList.FInspector.FManager.InvisibleTabsList.DeleteControl(FList.FInspector.FCurrentComponents[I] As TControl)
      else
        FList.FInspector.FManager.InvisibleTabsList.Add(FList.FInspector.FCurrentComponents[I] As TControl);
    end;
  end
  else if FList.FInspector.FPropertyType = ptProperty then
  begin
    for I := 0 to FList.FInspector.FCurrentComponents.Count - 1 do
    begin
      if FList.FInspector.FManager.EditForm = FList.FInspector.FCurrentComponents[I] then
      begin
        TComponentCracker(FList.FInspector.FManager.EditForm).SetDesigning(True, False);
      end;

      Res := FList.FInspector.FManager.SetPropertyValue(FList.FInspector.FCurrentComponents[I], AName, FValue);

      if FList.FInspector.FManager.EditForm = FList.FInspector.FCurrentComponents[I] then
      begin
        TComponentCracker(FList.FInspector.FManager.EditForm).SetDesigning(False, False);
        if AName = 'Position' then
          FList.FInspector.FManager.FormPosition := FList.FInspector.FManager.EditForm.Position;
      end;
      if Res > '' then
      begin
        MessageBox(0,
          PChar(Res),
          'Ошибка',
          MB_OK or MB_ICONHAND or MB_TASKMODAL or MB_TOPMOST);
        Result := False;
      end;
    end;
  end;

  if Result and (AName = cNameWithoutPrefix) and (FList.FInspector.FCurrentComponents.Count = 1) then begin
    FList.FInspector.FManager.ComponentNameChanged(TComponent(FList.FInspector.FCurrentComponents[0]), OldValue, GLOBALUSERCOMPONENT_PREFIX + FValue);
  end;

//  { TODO : Изменить чтобы контрол не активизировался }
//  FList.FInspector.FManager.Reset;
 // TControl(FList.FInspector.Owner).BringToFront;
  if FList.FInspector.FPropertyType = ptProperty then
  begin
    for I := 0 to FList.FInspector.FCurrentComponents.Count - 1 do
      FList.FInspector.FManager.PropertyChanged(FList.FInspector.FCurrentComponents[I]);
  end;
  FList.FInspector.FEditor.Modified := False;
end;


{ TPropertyList }

function TPropertyList.AbsoluteIndex(const Index: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Index < 0) or (Index >= Count) then Exit;

  for I := 0 to Count - 1 do
  begin
    if PropItem[I].FVisible then
      Inc(Result);
    if Result = Index then
      Break;
  end;
  Result := I;
end;

function TPropertyList.Add(const Name: String; const Value: Variant;
  const PropType: TTypeKind; PropEnum: TStringList;  const TypeName: String;
   AParent: TProp; const AReadOnly: Boolean; AClass: TClass = nil): Integer;
var
  Prop : TProp;
begin
  Prop := TProp.Create(Self, Name, Value, PropType, PropEnum, TypeName, AParent, AReadOnly, AClass);

  Result := inherited Add(Prop);
end;


constructor TPropertyList.Create(AnOwner: TComponent);
begin
  inherited Create;
  if AnOwner is TgsObjectInspector then
    FInspector := TgsObjectInspector(AnOwner);
end;



function TPropertyList.GetName(const Index: Integer): String;
begin
  Result := TProp(Items[Index]).Name;
end;

function TPropertyList.GetPropItem(const Index: Integer): TProp;
begin
  Result := TProp(Items[Index]);
end;


function TPropertyList.GetValue(const Index: Integer): String;
begin
  Result := TProp(Items[Index]).Value;
end;

function TPropertyList.GetVisibleCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if PropItem[I].FVisible then
      Inc(Result);
end;

function TPropertyList.IndexByName(Value: TProp): Integer;
var
  V, P: TProp;
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Name[I] = Value.Name then
    begin
      P := PropItem[I];
      V := Value;
      while (V.FParent <> nil) and (P.FParent <> nil) do
      begin
        if V.FParent.Name <> P.FParent.Name then
          Break;
         V := V.FParent;
         P := P.FParent;
      end;
      if V.FParent <> P.FParent then
        Continue;
      Result := I;
      Break;
    end;
end;

function TPropertyList.VisibleIndex(const Index: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (Index < 0) or (Index >= Count) then Exit;
  for I := 0 to Count - 1 do
  begin
    if PropItem[I].FVisible then
      Inc(Result);
    if I = Index then
      Break;
  end;
end;

{ TPopupListbox }

constructor TInsPopupListbox.Create(AnOwner: TComponent);
begin
  inherited;
  Visible := False;
  IntegralHeight := False;
  ItemHeight := 11;
end;

procedure TInsPopupListbox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TInsPopupListbox.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

destructor TInsPopupListbox.Destroy;
begin
  inherited;
end;

function TInsPopupListbox.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
  try
    TopIndex:= TopIndex + 1;
    Invalidate;
    Result := True;
  except
  end;
end;

function TInsPopupListbox.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := False;
  try
    TopIndex:= TopIndex - 1;
    Invalidate;
    Result := True;
  except
  end;
end;

procedure TInsPopupListbox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_RETURN:
      FObjectInspector.CloseUp(True);
    VK_ESCAPE:
      FObjectInspector.CloseUp(False);
  end;
end;

procedure TInsPopupListbox.KeyPress(var Key: Char);
var
  TickCount: Integer;
begin
  case Key of
    #8, #27: FSearchText := '';
    #32..#255:
      begin
        TickCount := GetTickCount;
        if TickCount - FSearchTickCount > 2000 then FSearchText := '';
        FSearchTickCount := TickCount;
        if Length(FSearchText) < 32 then FSearchText := FSearchText + Key;
        SendMessage(Handle, LB_SelectString, WORD(-1), Longint(PChar(FSearchText)));
        Key := #0;
      end;
  end;
end;

procedure TInsPopupListbox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and (X >= 0) and (Y >= 0) and (X < Width) and (Y < Height) then
    ItemIndex := ItemAtPos(Point(X, Y), True);
end;

procedure TInsPopupListbox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and (X >= 0) and (Y >= 0) and (X < Width) and (Y < Height) then
    ItemIndex := ItemAtPos(Point(X, Y), True);
end;

procedure TInsPopupListbox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    if (X >= 0) and (Y >= 0) and (X < Width) and (Y < Height) then
    begin
      ItemIndex := ItemAtPos(Point(X, Y), True);
      FObjectInspector.CloseUp(True);
    end
    else
      FObjectInspector.CloseUp(False);
  end;
end;


end.
