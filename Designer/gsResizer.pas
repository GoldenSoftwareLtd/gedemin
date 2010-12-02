{++
  Copyright (c) 2002 by Golden Software of Belarus

  Module

    gsResizer

  Abstract

    Компонент дизайнера форм.

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit gsResizer;

interface

uses controls, classes, windows, contnrs, forms, messages, menus, ActnList,
     Sysutils, TypInfo, db, ibsql, IBDatabase, dmImages_unit,
     gsResizerInterface, dlg_gsResizer_AlignmentPalette_unit,
     dlg_gsResizer_SetSize_unit, dlg_gsResizer_TabOrder_unit,
     dlg_gsResizer_Palette_unit, dlg_gsResizer_ObjectInspector_unit,
     gsCollectionEditor, dlgImageListEditor_unit, ExtCtrls,
     dlg_gsResizer_Components_unit;

resourcestring
  strCut = 'Вырезать';
  strPaste = 'Вставить';
  strCancel = 'Отменить';
  strBringToFront = 'На передний план';
  strSendToBack = 'На задний план';
  strAlignment = 'Выравнивание...';
  strSetSize = 'Размер...';
  strTabOrder = 'Табуляция...';
  strNewPage = 'Добавить страницу';
  strDeletePage = 'Удалить страницу';
  strNextPage = 'Следующая страница';
  strPrevPage = 'Предыдущая страница';
  strDeleteControl = 'Удалить компонент';
  strWantDelete = 'Вы хотите удалить компонент';
  strEdit = 'редактирование';
  strPageControlMenu = 'Страницы';
  strCopy = 'Копировать';
  strCopyName = 'Копировать название';
const
  cNameWithoutPrefix = 'Name without prefix';
const
  HalfRectSize = 2;
  RectSize = 5;
  GRID_SIZE = 8;
type
  TCursorPos = (cpNone, cpInside, cpTopLeft, cpTopRight, cpBottomLeft, cpBottomRight,
                cpMiddleTop, cpMiddleBottom, cpMiddleLeft, cpMiddleRight);
  TTabDirection = (tdNext, tdPrev, tdTop, tdDown, tdLeft, tdRight);
  TgsResizeManager = class;

  CControl = class of TControl;
  CComponent = class of TComponent;

  TMethodRec = class(TObject)
    Method: TMethod;
    Comp: TComponent;
    PropInfo: PPropInfo;
  end;


  TEventList = class(TObjectList)
  private
    function GetItem(const Index: Integer): TMethodRec;

  public
    function Add(AComp: TComponent; const APropInfo: PPropInfo; AMethod: TMethod): Integer;
    property Items[const Index: Integer]: TMethodRec read GetItem; default;
  end;

  TDesignState = (dsNone, dsMove, dsMultiSelect);

  TgsResizer  = class(TCustomControl)
  private
    FMovedControl: TControl;
    FMovedRect: TRect;
    FState: TDesignState;
    FResizeState: TCursorPos;
    FManager: TgsResizeManager;
    FCut: Boolean;
    FCollectionEditor: TFrmCollectionEditor;
    FImageListEditor: TdlgImageListEditor;
    FEndTimeMouseUp: DWord;
    FControlWindowProc: TWndMethod;

    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;

    function NormRect(const R: TRect): TRect;
    procedure SetMovedControl(AControl: TControl);

    procedure DrawRect;

    function GetMousePos(const X, Y: Integer): TCursorPos;
    function GetBusy: Boolean;

    procedure StartMove(const ResizeMode: TCursorPos);
    function Move(var dX, dY: Integer; const AnGridSize: Integer): Boolean;
    procedure EndMove;

    procedure StartMultiSelect;
    procedure EndMultiSelect;

    procedure UpdateControlAlignment;
    procedure SetCut(const Value: boolean);
    procedure SetNewParent(AParent: TWinControl);
    procedure Reset;
    function AlignPointToGrid(const AnValue: Integer; var AnOffSet: Integer; const AnGridSize: Integer): Integer;
    procedure DoResize(Sender: TObject);
    procedure ControlWindowProc(var Message: TMessage);
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DblClick; override;

    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;

    property Busy: Boolean read GetBusy;
    procedure CMPropertyChanged(var Message: TMessage);  message CM_PROPERTYCHANGED;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    property MovedControl: TControl read FMovedControl write SetMovedControl;
    property Cut: Boolean read FCut write SetCut;
  end;

  PresTwoPointer = ^TresTwoPointer;

  TresTwoPointer = Record
    ObjectPointer: TObject;
    EventPointer: TMessageEvent;
  end;

  TresTwoPointerList = class(TList)
  public
    function Add(AnSender: TObject; AnMessageEvent: TMessageEvent): Integer;
    procedure Delete(AnSender: TObject); overload;
    procedure Clear; override;
  end;

  TApplicationMessageProcessor = class
  private
    FEventList: TresTwoPointerList;
    FOldApplMessage: TMessageEvent;
    procedure ProcessApplMessage(var Msg: TMsg; var Handled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    class procedure RegisterOnMessage(const Sender: TObject; const AnMessageEvent: TMessageEvent);
    class procedure UnRegisterOnMessage(const Sender: TObject);
  end;

  TMessageHooker = class(TWinControl)
  private
    FManager: TgsResizeManager;
    procedure CMAddControl(var Message: TMessage); message CM_ADDCONTROL;
    procedure CMNewControl(var Message: TMessage); message CM_NEWCONTROL;
    procedure CMNewControlR(var Message: TMessage); message CM_NEWCONTROLR;
    procedure CMResizeControls(var Message: TMessage); message CM_RESIZECONTROL;
    procedure CMShowMenu(var Message: TMessage); message CM_SHOWMENU;
    procedure CMInsertNew(var Message: TMessage); message CM_INSERTNEW;
    procedure CMInsertNew2(var Message: TMessage); message CM_INSERTNEW2;
    procedure CMShowInspector(var Message: TMessage); message CM_SHOWINSPECTOR;
    procedure CMShowPalette(var Message: TMessage);  message CM_SHOWPALETTE;
    procedure CMDeleteControl(var Message: TMessage);  message CM_DELETECONTROL;
    procedure CMShowEvents(var Message: TMessage);  message CM_SHOWEVENTS;
    procedure CMShowEditForm(var Message: TMessage);  message CM_SHOWEDITFORM;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  PRemovalItem = ^TRemovalItem;
  TRemovalItem = record
    Obj: Pointer;
    Removal: Integer
  end;

  TRemovalList = Class(TList)
  private
    FCopyParent: TObject;

    procedure SetCopyParent(const Value: TObject);
  public
    procedure Clear; override;
    function GetRemoval(AnObject: TObject): Integer;
    property CopyParent: TObject read FCopyParent write SetCopyParent;
  end;

  TgsResizeManager = class(TComponent, IgsResizeManager)
  private
    FEditForm: TForm;
    FP: TPoint;
    FMessageHooker: TMessageHooker;
    FShowEcho: Boolean;
    FNewControl: TControl;
    FResizerList: TObjectList;
    FEnabled: Boolean;
    FGridSize: Integer;
    FUnEventMacro: Boolean;

    FPageControlMenu: TMenuItem;

    FFormPosition: TPosition;
    FFormPositionChanged: Boolean;
    FRemovalList: TRemovalList;
    FOldFormWindowProc: TWndMethod;
    FOldFormOnPaint: TNotifyEvent;
//    FOldFormOnCloseQuery: TCloseQueryEvent;
//    FOldFormOnCreate: TNotifyEvent;
    FOldEditFormResize: TNotifyEvent;
    FParentControl: TWinControl;
    FNewParent: TWinControl;
    FPasteAction: TAction;
    FCancelAction: TAction;
    FAddNewPage: TAction;
    FDeletePage: TAction;
    FNextPage: TAction;
    FPrevPage: TAction;
    FFormPopupMenu: TPopupMenu;
    FCut: Boolean;
    FPopupControl: TComponent;
    FAlignmentForm: Tdlg_gsResizer_AlignmentPalette;
    FComponentsForm: Tdlg_gsResizer_Components;
    FSetSizeForm: Tdlg_gsResizer_SetSize;
    FTabOrderForm: Tdlg_gsResizer_TabOrder;
    FPaletteForm: Tdlg_gsResizer_Palette;
    FObjectInspectorForm: Tdlg_gsResizer_ObjectInspector;
    FManagerState: TManagerState;
    FShortCut: TShortCut;
    FMacrosShortCut: TShortCut;

    FActionList: TActionList;
    FMacrosAction: TAction;
    FStartAction: TAction;
    FResourceName: String;

    FInvisibleList: TControlList;
    FInvisibleTabsList: TControlList;

    FOnActivate: TOnResiserActivate;
    FDelphiEventList: TEventList;
    FChangedEventList: TChangedEventList;
    FEventList: TEventList;
    FEventActionList: TEventList;
    FFormSubType: String;
    FDesignerType: TDesignerType;
    FEmulatorsList: TComponentList;

    FChangedPropList: TChangedPropList;

    FStartPropList: TChangedPropList;

    FGlobalLoading: Boolean;

    FDeleteAction: TAction;
    FCutAction: TAction;
    FCopyAction: TAction;
    FCopyNameAction: TAction;
    FBringToFrontAction: TAction;
    FSendToBackAction: TAction;

    FOldApplicationActivate: TNotifyEvent;
    FOldApplicationDeactivate: TNotifyEvent;
    FFormDeactivateState: Integer;

    FPropNotifyList: TList;
    FFirstLoad: boolean;

    FFormRecreate: Boolean;
    FCursor: Boolean;
    FMultiSelect: Boolean;
    FStartMultiPoint: TPoint;
    FOldMultiPoint: TPoint;

    FHintPoint: TPoint;
    FHintWindow: THintWindow;
    FHintTimer: TTimer;
    FAlignmentAction: TAction;
    FSetSizeAction: TAction;
    FTabOrderAction: TAction;

    FChangedNames: TStringList;
    FDeletedComponents: TStringList;

    procedure DeleteControl(Sender: TObject);
    procedure CutAction(Sender: TObject);
    procedure CopyAction(Sender: TObject);
    procedure CopyNameAction(Sender: TObject);
    procedure BringToFrontAction(Sender: TObject);
    procedure SendToBackAction(Sender: TObject);

    procedure SetGridSize(const Value: Integer);
    procedure SetEditForm(AForm: TForm);

    function IsInResize: Boolean;

//    procedure OnFormClose(Sender: TObject; var Action: TCloseAction);

    procedure FormWindowProc(var Msg : TMessage);
//    procedure FormOnCreate(Sender: TObject);
    procedure FormOnPaint(Sender: TObject);
    procedure FormOnCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OnStartAction(Sender: TObject);
    procedure OnMacrosAction(Sender: TObject);
    procedure ControlResize(Sender: TObject);
    procedure StorePropertyState;
    procedure ClearResizers;
    function GetBusy: Boolean;
    function ControlAtPos(AnOwner: TWinControl; const P: TPoint;
      const WithResizer: Boolean = False; const AOnlyWinControl: boolean = False): TControl;
    procedure SetEnabled(const Value: Boolean);
    procedure SetParentControl(Value: TWinControl);
    procedure StartMove(const P: TPoint; const ResizeMode: TCursorPos); overload;
    procedure StartMove(const ResizeMode: TCursorPos); overload;
    // Вызывается при изменении размера мышью
    procedure Move(P: TPoint); overload;
    // Вызывается при изменении размера клавиатурой
    procedure Move(var DX, DY: Integer; const AnGridSize: Integer = 1); overload;
    procedure EndMove;
    function GetRealRect(P1, P2: TPoint): TRect;

    procedure DrawMultiSelect;
    procedure StartMultiSelect(const P: TPoint);
    procedure MoveMultiSelect(const P: TPoint);
    procedure EndMultiSelect(const P: TPoint);

    procedure DeleteControls;
    procedure DoAlignmentAction(Sender: TObject);
    procedure DoSetSizeAction(Sender: TObject);
    procedure DoTabOrderAction(Sender: TObject);
    procedure Cut;
    procedure Paste(Sender: TObject);
    procedure CancelCut(Sender: TObject);
    procedure PageControl(Sender: TObject);

    procedure DoAlignment;
    procedure DoSetSize;
    function DoBeforeExit(const SaveState: Boolean = False): boolean;
    procedure DoAfterExit;
    function GetResizer(const Index: Integer): TgsResizer;

    function GetNextControl(AControl: TControl; const Direction: TTabDirection): TControl;
    procedure InsertNewControl(Const P: TPoint);
    procedure InsertNewControl2;
    //Сохранеи и востановление настроек
//    procedure SetDefaultValues(AComponent: TComponent);

    procedure CheckPosition(AnOwner: TComponent; Stream: TStream; const Attr: Boolean);
    procedure DisableEvents(AnOwner: TComponent);
    procedure EnableEvents;

    // Application Events
    procedure ApplicationActivate(Sender: TObject);
    procedure ApplicationDeactivate(Sender: TObject);
    function GetObjectInspectorForm: IgsObjectInspectorForm;
    procedure BroadcastResizer(var Message);
    procedure ShowHint;
    procedure DoHintTimer(Sender: TObject);
    function GetComponentsForm: Tdlg_gsResizer_Components;
    procedure SetComponentsForm(const Value: Tdlg_gsResizer_Components);
    procedure ShowEvents;
    procedure CheckPropertyState;
    function GetAlignmentAction: TAction;
    function GetSetSizeAction: TAction;

    function GetTabOrderAction: TAction;
    function GetCopyAction: TAction;
    function GetCutAction: TAction;
    function GetPasteAction: TAction;
  protected
    function Get_Self: TObject;

    function AddResizer(AControl: TControl; AShiftState: Boolean): boolean;
    function AddComponent(AComponent: TComponent): TControl;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure AddNonVisibleComponent(AComponent: TComponent; const AShiftState: Boolean);
    procedure RefreshList;

    property Busy: Boolean read GetBusy;
    property ParentControl: TWinControl read FParentControl write SetParentControl;
    property Resizers[const Index: Integer]: TgsResizer read GetResizer;
    function GetChangedPropList: TChangedPropList;
    function GetChangedEventList: TChangedEventList;

    function GetOnActivate: TOnResiserActivate;
    procedure SetOnActivate(const Value: TOnResiserActivate);
    procedure SetShortCut(const Value: TShortCut);
    function GetShortCut: TShortCut;

    procedure SetMacrosShortCut(const Value: TShortCut);
    function GetMacrosShortCut: TShortCut;


    function GetDesignerType: TDesignerType;

    procedure MenuPopup(Sender: TObject);

    function GetFormPosition: TPosition;
    procedure SetFormPosition(const Value: TPosition);

    procedure RestoreChangedComponents;
    function  GetControlOldName(ANewName: string): string;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetAlignment(const AnAlignment: TPositionAlignment);
    procedure SetControlSize(const ASizeType: TSizeChanger);
    procedure SetManagerState(const AManagerState: TManagerState);
    procedure Reset;
    function GetEditForm: TForm;
    function GetInvisibleList: TControlList;
    function GetInvisibleTabsList: TControlList;
    function GetNewControlName(AClassName: String): String;
    procedure SaveAndExit;
    procedure ExitWithoutSaving;
    procedure ExitAndLoadDefault;
    procedure FreeResizer;

    property AlignmentAction: TAction read GetAlignmentAction;
    property SetSizeAction: TAction read GetSetSizeAction;
    property TabOrderAction: TAction read GetTabOrderAction;
    property CopyActionI: TAction read GetCopyAction;
    property PasteActionI: TAction read GetPasteAction;
    property CutActionI: TAction read GetCutAction;

    property InvisibleList: TControlList read FInvisibleList;
    property InvisibleTabsList: TControlList read FInvisibleTabsList;
    property EditForm: TForm read GetEditForm write SetEditForm;
    procedure ReloadComponent(const Attr: Boolean);
    function SetPropertyValue(AComponent: TObject; const PropertyName, PropertyValue: String): String;
    property DesignerType: TDesignerType read FDesignerType;
    property GlobalLoading: Boolean read FGlobalLoading;
    property ObjectInspectorForm: IgsObjectInspectorForm
      read GetObjectInspectorForm;
    property  EmulatorsList: TComponentList read  FEmulatorsList;
    property ComponentsForm: Tdlg_gsResizer_Components read GetComponentsForm write SetComponentsForm;

    property RemovalList: TRemovalList read FRemovalList;

    function GetResizerList: TObjectList;

    procedure AddPropertyNotification(AControl: TControl);
    procedure RemovePropertyNotification(AControl: TControl);
    procedure PropertyChanged(AnObject: TObject);
    procedure SetSettings;

    property Enabled: Boolean read FEnabled write SetEnabled;
    property GridSize: Integer read FGridSize write SetGridSize;
    property ShortCut: TShortCut read GetShortCut write SetShortCut;
    property MacrosShortCut: TShortCut read GetMacrosShortCut write SetMacrosShortCut;

    property OnActivate: TOnResiserActivate read GetOnActivate write SetOnActivate;
    property ChangedPropList: TChangedPropList read GetChangedProplist;
    property FormPosition: TPosition read GetFormPosition write SetFormPosition;
    property FormPositionChanged: Boolean read FFormPositionChanged write FFormPositionChanged;
    procedure ApplicationOnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ComponentNameChanged(AComponent: TComponent; AOldValue, ANewValue: TComponentName);
    procedure EventFunctionChanged(AComp: TComponent; AEvent: string; ANewID: integer; AName: string);
    procedure CheckForEventChanged(AComp: TComponent; SL: TStringList);
    function  IsCut: boolean;
    function  GetParentControl: TWinControl;
    procedure SetNewParentControl(ANewPar: TWinControl);
  end;

var
  ActiveDesigner: TgsResizeManager;

implementation

uses
  Graphics, comctrls, Dialogs, Storages, gd_directories_const, gdcEvent,
  gsStorage, gsComponentEmulator, consts, gsDesignerRW, dmDatabase_unit,
  gdc_createable_form, gd_security, gd_createable_form, evt_i_Base, Clipbrd,
  TB2Item, imglist, gsPropertyEditor, prp_frmGedeminProperty_Unit, evt_Base,
  gdcDelphiObject, gdcConstants
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  ApplicationMessageProcessor: TApplicationMessageProcessor;

type
  TComponentCracker = class(TComponent);
  TControlCracker = class(TControl);
  TWinControlCracker = class(TWinControl);
{ TgsResizer }

constructor TgsResizer.Create(AnOwner: TComponent);
begin
  inherited;

  Assert(AnOwner is TgsResizeManager);

  FManager := TgsResizeManager(AnOwner);
  FManager.AddPropertyNotification(Self);
  FEndTimeMouseUp := 0;

  ParentWindow := FManager.FEditForm.Handle;

  SetBounds(0, 0, 0, 0);
  FMovedControl := Nil;
  FCut := False;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clBlack;
  Canvas.Pen.Style := psDash;
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  Visible := False;
{  FPopupMenu := TPopupMenu.Create(Self);
  FPopupMenu.OnPopup := OnPopup;}



 { Self.PopupMenu := FPopupMenu;}
end;

procedure TgsResizer.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT or WS_EX_TOPMOST;
end;


function TgsResizer.GetMousePos(const X, Y: Integer): TCursorPos;
begin
// Для выделения прямоугольником
{  if (X >= 0) and (X <= RectSize) and (Y >= 0) and (Y <= RectSize) then
    Result := cpTopLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y >= 0) and (Y <= RectSize) then
    Result := cpTopRight
  else if (X >= 0) and (X <= RectSize) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpBottomLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpBottomRight
  else if (X >= 0) and (X <= RectSize) and (Y > RectSize) and (Y < Height - RectSize) then
    Result := cpMiddleLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y > RectSize) and (Y < Height - RectSize) then
    Result := cpMiddleRight
  else if (X > RectSize) and (X < Width - RectSize) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpMiddleBottom
  else if (X > RectSize) and (X < Width - RectSize) and (Y >= 0) and (Y <= RectSize) then
    Result := cpMiddleTop
  else if (X >= RectSize) and (X <= Width - RectSize) and (Y >= RectSize) and (Y <= Height - RectSize) then
    Result := cpInside
  else
    Result := cpNone;}

  // Для выделения по углам
  if (X >= 0) and (X <= RectSize) and (Y >= 0) and (Y <= RectSize) then
    Result := cpTopLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y >= 0) and (Y <= RectSize) then
    Result := cpTopRight
  else if (X >= 0) and (X <= RectSize) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpBottomLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpBottomRight
  else if (X >= 0) and (X <= RectSize) and (Y >= ((Height + RectSize) div 2 - RectSize)) and (Y <= ((Height + RectSize) div 2 )) then
    Result := cpMiddleLeft
  else if (X >= Width - RectSize) and (X <= Width) and (Y >= ((Height + RectSize) div 2 - RectSize)) and (Y <= ((Height + RectSize) div 2)) then
    Result := cpMiddleRight
  else if (X >= ((Width + RectSize) div 2 - RectSize)) and (X <= ((Width + RectSize) div 2)) and (Y >= Height - RectSize) and (Y <= Height) then
    Result := cpMiddleBottom
  else if (X >= ((Width + RectSize) div 2 - RectSize)) and (X <= ((Width + RectSize) div 2)) and (Y >= 0) and (Y <= RectSize) then
    Result := cpMiddleTop
  else if (X >= RectSize) and (X <= Width - RectSize) and (Y >= RectSize) and (Y <= Height - RectSize) then
    Result := cpInside
  else
    Result := cpNone;
end;

procedure TgsResizer.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and (GetMousePos(X, Y) <> cpNone) and
   (not (ssDouble in Shift)) and not (ssCtrl in Shift) then
  begin
    FManager.FShowEcho := True;
    FManager.StartMove(Self.ClientToScreen(Point(X, Y)), GetMousePos(X, Y));
  end else
  if (Button = mbLeft) and (ssCtrl in Shift) and not FManager.FCut then
  begin
    FManager.FShowEcho := True;
    FManager.StartMultiSelect(Self.ClientToScreen(Point(X, Y)));
  end;
end;

procedure TgsResizer.DrawRect;
var
  dc: hDC;
  p: TPoint;
  ExclRect: TRect;
begin
  if FManager.FShowEcho and (FManager.FObjectInspectorForm <> nil) then
  begin
    dc := GetDC(0);
    try
      if FManager.FObjectInspectorForm.FormStyle = fsStayOnTop then
        ExcludeClipRect(dc, FManager.FObjectInspectorForm.Left, FManager.FObjectInspectorForm.Top,
         FManager.FObjectInspectorForm.Left + FManager.FObjectInspectorForm.Width, FManager.FObjectInspectorForm.Top + FManager.FObjectInspectorForm.Height);
      if FManager.FPaletteForm.FormStyle = fsStayOnTop then
        ExcludeClipRect(dc, FManager.FPaletteForm.Left, FManager.FPaletteForm.Top,
         FManager.FPaletteForm.Left + FManager.FPaletteForm.Width, FManager.FPaletteForm.Top + FManager.FPaletteForm.Height);

      FMovedRect:= NormRect(FMovedRect);
      if Assigned(FMovedControl.Parent) then begin
        ExclRect:= FMovedRect;

        p:= FMovedControl.Parent.ClientToScreen(Point(0, 0));
        if p.x > FMovedRect.Left then begin
          ExclRect.Right:= p.x;
          ExcludeClipRect(dc, ExclRect.Left, ExclRect.Top, ExclRect.Right, ExclRect.Bottom);
          ExclRect:= FMovedRect;
        end;
        if p.y > FMovedRect.Top then begin
          ExclRect.Bottom:= p.y;
          ExcludeClipRect(dc, ExclRect.Left, ExclRect.Top, ExclRect.Right, ExclRect.Bottom);
          ExclRect:= FMovedRect;
        end;

        p:= FMovedControl.Parent.ClientToScreen(Point(FMovedControl.Parent.Width - 1, FMovedControl.Parent.Height - 1));
        if p.x < FMovedRect.Right then begin
          ExclRect.Left:= p.x;
          ExcludeClipRect(dc, ExclRect.Left, ExclRect.Top, ExclRect.Right, ExclRect.Bottom);
          ExclRect:= FMovedRect;
        end;
        if p.y < FMovedRect.Bottom then begin
          ExclRect.Top:= p.y;
          ExcludeClipRect(dc, ExclRect.Left, ExclRect.Top, ExclRect.Right, ExclRect.Bottom);
        end;
      end;

      DrawFocusRect(dc, NormRect(FMovedRect));
    finally
      ReleaseDC(0, dc);
    end;
  end;
end;

procedure TgsResizer.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FManager.FCursor := False;
  if (ssLeft in Shift) then
  begin
    case FState of
      dsMove: FManager.Move(Self.ClientToScreen(Point(X, Y)));
      dsMultiSelect: FManager.MoveMultiSelect(Self.ClientToScreen(Point(X, Y)));
    end;
  end else
  begin
    FManager.FCursor := True;
    case GetMousePos(X, Y) of
      cpTopLeft, cpBottomRight:
        Cursor := crSizeNWSE;
      cpBottomLeft, cpTopRight:
        Cursor := crSizeNESW;
      cpMiddleTop, cpMiddleBottom:
        Cursor := crSizeNS;
      cpMiddleLeft, cpMiddleRight:
        Cursor := crSizeWE;
      else
        begin
          Cursor := crDefault;
          FManager.FCursor := False;
        end;
      end;
    end;
end;

procedure TgsResizer.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  P: TPoint;
  RealTime: DWord;
begin
  if Button = mbRight then
  begin
    inherited;
    P := Self.ClientToScreen(Point(X, Y));
    PostMessage(FManager.FMessageHooker.Handle, CM_SHOWMENU, P.X, P.Y);
    Exit;
  end;

  RealTime := GetTickCount;

  ReleaseCapture;

  case FState of
    dsMove: FManager.EndMove;
    dsMultiSelect: FManager.EndMultiSelect(Self.ClientToScreen(Point(X, Y)));
  end;

  // эта проверка сделана, чтобы по первому DblClick вызывалось событие DblClick,
  // без нее первый раз на объект нужно кликнуть три раза, чтобы сгерерировать DblClick
  try
    if (RealTime - FEndTimeMouseUp) <= GetDoubleClickTime then
      DblClick;

  except
  end;

  FEndTimeMouseUp := RealTime;
end;

procedure TgsResizer.Paint;
begin
//  FMovedControl.Repaint;

  inherited;

  if FCut then
  begin
    Canvas.Brush.Style := bsBDiagonal;
    Canvas.Rectangle(Rect(HalfRectSize, HalfRectSize, Width - HalfRectSize, Height - HalfRectSize));
    Canvas.Brush.Style := bsSolid;
  end
  else
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Rect(0, 0, RectSize, RectSize)); // лев Верх
    Canvas.FillRect(Rect(((Width + RectSize) div 2) - RectSize, 0, ((Width + RectSize) div 2), RectSize)); //центр верх
    Canvas.FillRect(Rect(Width - RectSize, 0, Width, RectSize)); // прав верх
    Canvas.FillRect(Rect(0, Height - RectSize, RectSize, Height)); // лев низ
    Canvas.FillRect(Rect(((Width + RectSize) div 2) - RectSize , Height - RectSize, ((Width + RectSize) div 2) , Height)); // центр низ
    Canvas.FillRect(Rect(Width - RectSize, Height - RectSize, Width, Height)); //прав низ

    Canvas.FillRect(Rect(0, ((Height + RectSize) div 2) - RectSize, RectSize, (Height + RectSize) div 2)); //лев центр
    Canvas.FillRect(Rect(Width - RectSize, ((Height + RectSize) div 2) - RectSize, Width, (Height + RectSize) div 2)); //прав центр
  end;

end;

procedure TgsResizer.SetMovedControl(AControl: TControl);
begin
  if AControl <> FMovedControl then
  begin
    if Assigned(FMovedControl) then
    begin
      TControlCracker(FMovedControl).OnResize := nil;
      FMovedControl.WindowProc := FControlWindowProc;
      FControlWindowProc := nil;
    end;

    FMovedControl := AControl;
    Visible := False;
    if FMovedControl <> nil then
    begin
//      Self.Constraints.Assign(FMovedControl.Constraints);
      Parent := nil; //FMovedControl.Parent;
      ParentWindow := FMovedControl.Parent.Handle;
      self.setbounds(FMovedControl.Left - HalfRectSize,
                     FMovedControl.Top - HalfRectSize,
                     FMovedControl.Width + HalfRectSize * 2,
                     FMovedControl.Height + HalfRectSize * 2);
      if (FMovedControl is TWinControl) and (TWinControl(FMovedControl).CanFocus) then
        TWinControl(FMovedControl).SetFocus;
      Visible := True;
      BringToFront;
      SetWindowPos(Handle,HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE {+ SWP_NOREDRAW});
      SetFocus;
      invalidate;
      // Сохранять старый обработчик не надо т.к. он должен быть удален
      TControlCracker(FMovedControl).OnResize := DoResize;
      FControlWindowProc := FMovedControl.WindowProc;
      FMovedControl.WindowProc := ControlWindowProc;
    end
  end;
end;

function TgsResizer.GetBusy: Boolean;
begin
  Result := FState <> dsNone;
end;

procedure TgsResizer.StartMove(const ResizeMode: TCursorPos);
begin
 // if FCut then Exit;
  FState := dsMove;
  FResizeState := ResizeMode;

  FMovedRect.TopLeft := Self.ClientToScreen(Point(HalfRectSize , HalfRectSize ));
  FMovedRect.BottomRight := Self.ClientToScreen(Point(Width - HalfRectSize, Height - HalfRectSize));

  if FManager.FShowEcho then
    DrawRect;
end;

function TgsResizer.Move(var DX, DY: Integer; const AnGridSize: Integer): Boolean;
begin
  Result := False;
  if FState = dsMove then
  begin
    Result := True;
    if FManager.FShowEcho then
      DrawRect;

    case FResizeState of
      cpInside:
        OffsetRect(FMovedRect,
         AlignPointToGrid(FMovedRect.Left, DX, AnGridSize) - FMovedRect.Left,
         AlignPointToGrid(FMovedRect.Top, DY, AnGridSize) - FMovedRect.Top);
      cpMiddleBottom:
        FMovedRect.Bottom := AlignPointToGrid(FMovedRect.Bottom, DY, AnGridSize);
      cpMiddleTop:
        FMovedRect.Top := AlignPointToGrid(FMovedRect.Top, DY, AnGridSize);
      cpMiddleLeft:
        FMovedRect.Left := AlignPointToGrid(FMovedRect.Left, DX, AnGridSize);
      cpMiddleRight:
        FMovedRect.Right := AlignPointToGrid(FMovedRect.Right, DX, AnGridSize);
      cpTopLeft:
      begin
        FMovedRect.Top := AlignPointToGrid(FMovedRect.Top, DY, AnGridSize);
        FMovedRect.Left := AlignPointToGrid(FMovedRect.Left, DX, AnGridSize);
      end;
      cpTopRight:
      begin
        FMovedRect.Top := AlignPointToGrid(FMovedRect.Top, DY, AnGridSize);
        FMovedRect.Right := AlignPointToGrid(FMovedRect.Right, DX, AnGridSize);
      end;
      cpBottomLeft:
      begin
        FMovedRect.Bottom := AlignPointToGrid(FMovedRect.Bottom, DY, AnGridSize);
        FMovedRect.Left := AlignPointToGrid(FMovedRect.Left, DX, AnGridSize);
      end;
      cpBottomRight:
      begin
        FMovedRect.Bottom := AlignPointToGrid(FMovedRect.Bottom, DY, AnGridSize);
        FMovedRect.Right := AlignPointToGrid(FMovedRect.Right, DX, AnGridSize);
      end;
    end;

    if FManager.FShowEcho then
      DrawRect;
  end;
end;

procedure TgsResizer.EndMove;
var
  R, RComp: TRect;
  TmpLong: LongInt;
begin
  if FState = dsMove then
  begin
    if FManager.FShowEcho then
      DrawRect;

    Invalidate;
    R.TopLeft := FMovedControl.Parent.ScreenToClient(FMovedRect.TopLeft);
    R.BottomRight := FMovedControl.Parent.ScreenToClient(FMovedRect.BottomRight);
    RComp := NormRect(R);
    if (FMovedControl.BoundsRect.Left <> RComp.Left)
      or (FMovedControl.BoundsRect.Top <> RComp.Top)
      or (FMovedControl.BoundsRect.Right <> RComp.Right)
      or (FMovedControl.BoundsRect.Bottom <> RComp.Bottom) then
    begin
      try
        FMovedControl.BoundsRect := RComp;
      except
        on E: Exception do
        begin
          Application.ShowException(E);
        end;
      end;
    end;

    RComp.Left := RComp.Left - HalfRectSize;
    RComp.Top := RComp.Top - HalfRectSize;
    RComp.Right := RComp.Right + HalfRectSize;
    RComp.Bottom := RComp.Bottom + HalfRectSize;
    if (Self.BoundsRect.Left <> RComp.Left)
      or (Self.BoundsRect.Top <> RComp.Top)
      or (Self.BoundsRect.Right <> RComp.Right)
      or (Self.BoundsRect.Bottom <> RComp.Bottom) then
    begin
      Self.BoundsRect := RComp;
    end;

    if FMovedControl is TgsComponentEmulator then
    begin
      LongRec(TmpLong).Hi := FMovedControl.Top;
      LongRec(TmpLong).Lo := FMovedControl.Left;
      TgsComponentEmulator(FMovedControl).RelatedComponent.DesignInfo := TmpLong;
    end;
    FResizeState := cpNone;
    FState := dsNone;
    UpdateControlAlignment;
  end;
end;

procedure TgsResizer.KeyDown(var Key: Word; Shift: TShiftState);
var
  I, O, I_: Integer;
begin
  I := 1;
  O := 0;
  I_ := -1;
  FManager.FShowEcho := False;
  if ssShift in Shift then
    case Key of
      VK_DOWN, VK_UP:
      begin
        FManager.StartMove(cpMiddleBottom);
        case Key of
          VK_DOWN: FManager.Move(O, I);
          VK_UP: FManager.Move(O, I_);
        end;
        FManager.EndMove;
      end;
      VK_LEFT, VK_RIGHT:
        begin
          FManager.StartMove(cpMiddleRight);
          case Key of
            VK_LEFT: FManager.Move(I_, O);
            VK_RIGHT: FManager.Move(I, O);
          end;
          FManager.EndMove;
        end;
    end
  else if ssCtrl in Shift then
    case Key of
      VK_DOWN, VK_UP, VK_LEFT, VK_RIGHT:
        begin
          FManager.StartMove(cpInside);
          case Key of
            VK_DOWN: FManager.Move(O, I);
            VK_UP: FManager.Move(O, I_);
            VK_LEFT: FManager.Move(I_, O);
            VK_RIGHT: FManager.Move(I, O);
          end;
          FManager.EndMove;
        end;
    end
  else
    case Key of
      VK_DOWN:;
      VK_UP:;
      VK_LEFT:;
      VK_RIGHT:;
      VK_ESCAPE:
        begin
          FManager.FNewControl := FMovedControl.Parent;
          PostMessage(FManager.FMessageHooker.Handle, CM_ADDCONTROL, 0, 0);
        end;
      VK_TAB:
        begin
          if ssShift in Shift then
            FManager.FNewControl := FManager.GetNextControl(FMovedControl, tdPrev)
          else
            FManager.FNewControl := FManager.GetNextControl(FMovedControl, tdNext);
          PostMessage(FManager.FMessageHooker.Handle, CM_ADDCONTROL, 0, 0);
        end;
      VK_DELETE:
        PostMessage(FManager.FMessageHooker.Handle, CM_DELETECONTROL, 0, 0);
    end;

  inherited;
end;

{ TgsResizerManager }

function TgsResizeManager.AddResizer(AControl:  TControl; AShiftState: Boolean): boolean;
var
  I: Integer;
  CurPnt: TPoint;
  Resizer: TgsResizer;
begin
  Result := False;
  while Assigned(AControl) and (AControl.Name = '') do
    AControl := AControl.Parent;
  if AControl is TgsComponentEmulator then

  else
  begin
    if (not Assigned(AControl)) or (AControl = FEditForm) or
      (AControl.Name = '') or (AControl.Owner = nil) then
    begin
      ClearResizers;
      GetAsyncKeyState(VK_CONTROL);
      if (AControl = FEditForm) and not FMultiSelect and (GetAsyncKeyState(VK_CONTROL) <> 0) then
        { TODO -oJKL : Возможно стоит переделать структуру вызова,
        чтобы избавиться от непосредственного определения координат }
        if GetCursorPos(CurPnt) then
          StartMultiSelect(CurPnt);
      if Assigned(FObjectInspectorForm) then
        FObjectInspectorForm.AddEditComponent(FEditForm, False);
      Exit;
    end;
  end;

  if Assigned(AControl) then
  begin
    if (ParentControl = AControl) and (FResizerList.Count > 1) and AShiftState then Exit;
    ParentControl := AControl.Parent;

    for I := 0 to FResizerList.Count - 1 do
    begin
      if Resizers[I].MovedControl  = AControl then
      begin
        if AShiftState then
        begin
          ReleaseCapture;
          EndMove;
          FResizerList.Delete(I);
          if Assigned(FObjectInspectorForm) then
            FObjectInspectorForm.AddEditComponent(AControl, True);
        end
        else
          if FResizerList.Count = 0 then
            FObjectInspectorForm.AddEditComponent(AControl, False);
        Exit;
      end;
    end;

    if (not AShiftState) then
      ClearResizers;

    Resizer := TgsResizer.Create(Self);
    Resizer.Anchors := AControl.Anchors;
    Resizer.MovedControl := AControl;
    FResizerList.Add(Resizer);
    Result := True;
    if FResizerList.Count <= 1 then
      AShiftState := False;
    if Assigned(FObjectInspectorForm) then
    begin
      if Resizer.MovedControl is TgsComponentEmulator then
        FObjectInspectorForm.AddEditComponent(TgsComponentEmulator(Resizer.MovedControl).RelatedComponent, AShiftState)
      else
        FObjectInspectorForm.AddEditComponent(Resizer.MovedControl, AShiftState);
    end;
  end;
end;

procedure TgsResizeManager.ClearResizers;
var
  I: Integer;
begin
  if (not FCut) or (not FEnabled) then
  begin
    FResizerList.Clear;
    FCut := False;
  end
  else
  begin
    for I := FResizerList.Count - 1 downto 0 do
      if not Resizers[I].Cut then
        FResizerList.Delete(I);
  end;
end;

function TgsResizeManager.ControlAtPos(AnOwner: TWinControl; const P: TPoint;
    const WithResizer: Boolean; const AOnlyWinControl: boolean): TControl;
  function ScreenRec(AControl: TControl): TRect;

    procedure TestParentRect(PC: TControl; var R: TRect);
    var
      PR: TRect;
    begin
      if PC <> nil then
      begin
        PR := PC.ClientRect;
        offsetrect(PR , PC.ClientOrigin.X, PC.ClientOrigin.Y);
        if PR.Left > R.Left then
          R.Left := PR.Left;
        if PR.Top > R.Top then
          R.Top := PR.Top;
        if PR.Right < R.Right then
          R.Right := PR.Right;
        if PR.Bottom < R.Bottom then
          R.Bottom := PR.Bottom;
        TestParentRect(PC.Parent, R);
      end;
    end;

  begin
    Result := AControl.ClientRect;
//    Result := AControl.BoundsRect;
    offsetrect(Result , AControl.ClientOrigin.X, AControl.ClientOrigin.Y);
    TestParentRect(AControl.Parent, Result);
  end;
{  function TestResizers: TControl;
  var
    I: Integer;
  begin
    Result :=  nil;
    for I := 0 to  FResizerList.Count - 1 do
      if PtInRect(ScreenRec(Resizers[I]), P) then
      begin
        Result := Resizers[I].MovedControl;
        Break;
      end;
  end;}
var
  I: Integer;
begin
  Result := nil;
{  Result := TestResizers;}

  if Result = nil then
    for I := AnOwner.ControlCount - 1  downto 0  do
    begin
      if ((not (AnOwner.Controls[I] is TgsResizer)) or WithResizer) and AnOwner.Controls[I].Visible then
      begin
        if (AnOwner.Controls[I] is TWinControl) {and (csAcceptsControls in AnOwner.Controls[I].ControlStyle))} then
          Result := ControlAtPos((AnOwner.Controls[I] as TWinControl), P, False, AOnlyWinControl)
        else if PtInRect(ScreenRec(AnOwner.Controls[I]), P) then
          if not AOnlyWinControl or (AnOwner.Controls[I] is TWinControl) then
            Result := AnOwner.Controls[I];
        if Assigned(Result) then Break;
      end;
    end;

  if (not Assigned(Result)) and PtInRect(ScreenRec(AnOwner), P) then
    Result := AnOwner
end;

constructor TgsResizeManager.Create(AnOwner: TComponent);
var
  Menu: TMenuItem;
begin
  inherited;
  FFormPositionChanged := False;
  FComponentsForm := nil;
  FEnabled := False;
  FFormRecreate := False;
  Assert(AnOwner is TCreateableForm, 'Редактирование не возможно');
  FDelphiEventList := TEventList.Create;
  FChangedEventList:= TChangedEventList.Create;
  FEventList := TEventList.Create;
  FEventActionList := TEventList.Create;

  FChangedNames:= TStringList.Create;
  FDeletedComponents:= TStringList.Create;

  FMultiSelect := False;

  FEditForm := TForm(AnOwner);

  FFirstLoad := True;

  FResourceName := st_ds_DFMPath + '\' + AnOwner.ClassName;

  if AnOwner is TgdcCreateableForm then
    FFormSubType := (AnOwner as TgdcCreateableForm).SubType
  else
    FFormSubType := '';

  if FFormSubType= '' then
    FFormSubType := SubtypeDefaultName;

  FGridSize := GRID_SIZE;

  FNewParent := nil;

  if not (csDesigning in Self.ComponentState) then
  begin
    FPropNotifyList := TList.Create;
    FRemovalList := TRemovalList.Create;

    FChangedPropList := TChangedPropList.Create;
    FStartPropList := TChangedPropList.Create;

    FEmulatorsList := TComponentList.Create;
    FResizerList := TObjectList.Create;

    FFormPopupMenu := TPopupMenu.Create(Self);
    FFormPopupMenu.OnPopup := MenuPopup;

    // Меню для PageControl
      FPageControlMenu := TMenuItem.Create(FFormPopupMenu);
      FPageControlMenu.Caption := strPageControlMenu;

      FAddNewPage := TAction.Create(Self);
      FAddNewPage.Caption := strNewPage;
      FAddNewPage.OnExecute := PageControl;

      Menu := TMenuItem.Create(FFormPopupMenu);
      Menu.Action := FAddNewPage;
      FPageControlMenu.{Items.}Add(Menu);

      FDeletePage := TAction.Create(Self);
      FDeletePage.Caption := strDeletePage;
      FDeletePage.OnExecute := PageControl;

      Menu := TMenuItem.Create(FFormPopupMenu);
      Menu.Action := FDeletePage;
      FPageControlMenu.{Items.}Add(Menu);

      FNextPage := TAction.Create(Self);
      FNextPage.Caption := strNextPage;
      FNextPage.OnExecute := PageControl;

      Menu := TMenuItem.Create(FFormPopupMenu);
      Menu.Action := FNextPage;
      FPageControlMenu.{Items.}Add(Menu);

      FPrevPage := TAction.Create(Self);
      FPrevPage.Caption := strPrevPage;
      FPrevPage.OnExecute := PageControl;

      Menu := TMenuItem.Create(FFormPopupMenu);
      Menu.Action := FPrevPage;
      FPageControlMenu.{Items.}Add(Menu);
      FFormPopUpMenu.Items.Add(FPageControlMenu);
    // Меню

    FPasteAction := TAction.Create(Self);
    FPasteAction.Caption := strPaste;
    FPasteAction.ImageIndex:= 12;
    FPasteAction.OnExecute := Paste;
    FPasteAction.Enabled := False;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FPasteAction;
    FFormPopupMenu.Items.Add(Menu);

    FCopyAction := TAction.Create(Self);
    FCopyAction.Caption := strCopy;
    FCopyAction.ImageIndex:= 11;
    FCopyAction.OnExecute := CopyAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FCopyAction;
    FFormPopupMenu.Items.Add(Menu);


    FCopyNameAction := TAction.Create(Self);
    FCopyNameAction.Caption := strCopyName;
    FCopyNameAction.OnExecute := CopyNameAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FCopyNameAction;
    FFormPopupMenu.Items.Add(Menu);

    FCutAction := TAction.Create(Self);
    FCutAction.Caption := strCut;
    FCutAction.ImageIndex:= 10;
    FCutAction.OnExecute := CutAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FCutAction;
    FFormPopupMenu.Items.Add(Menu);

    FCancelAction := TAction.Create(Self);
    FCancelAction.Caption := strCancel;
    FCancelAction.OnExecute := CancelCut;
    FCancelAction.Enabled := False;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FCancelAction;
    FFormPopupMenu.Items.Add(Menu);

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Caption := '-';
    FFormPopupMenu.Items.Add(Menu);

    FBringToFrontAction := TAction.Create(Self);
    FBringToFrontAction.Caption := strBringToFront;
    FBringToFrontAction.ImageIndex:= 13;
    FBringToFrontAction.OnExecute := BringToFrontAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FBringToFrontAction;
    FFormPopupMenu.Items.Add(Menu);

    FSendToBackAction := TAction.Create(Self);
    FSendToBackAction.Caption := strSendToBack;
    FSendToBackAction.ImageIndex:= 14;
    FSendToBackAction.OnExecute := SendToBackAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FSendToBackAction;
    FFormPopupMenu.Items.Add(Menu);

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Caption := '-';
    FFormPopupMenu.Items.Add(Menu);

    FTabOrderAction := TAction.Create(Self);
    FTabOrderAction.Caption := strTabOrder;
    FTabOrderAction.ImageIndex:= 8;
    FTabOrderAction.OnExecute := DoTabOrderAction;
    FTabOrderAction.Enabled := False;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FTabOrderAction;
    FFormPopupMenu.Items.Add(Menu);

    FAlignmentAction := TAction.Create(Self);
    FAlignmentAction.Caption := strAlignment;
    FAlignmentAction.ImageIndex:= 7;
    FAlignmentAction.OnExecute := DoAlignmentAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FAlignmentAction;
    FFormPopupMenu.Items.Add(Menu);

    FSetSizeAction := TAction.Create(Self);
    FSetSizeAction.Caption := strSetSize;
    FSetSizeAction.ImageIndex:= 9;
    FSetSizeAction.OnExecute := DoSetSizeAction;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FSetSizeAction;
    FFormPopupMenu.Items.Add(Menu);

    FDeleteAction := TAction.Create(Self);
    FDeleteAction.Caption := strDeleteControl;
    FDeleteAction.OnExecute := DeleteControl;
    FDeleteAction.Enabled := False;

    Menu := TMenuItem.Create(FFormPopupMenu);
    Menu.Action := FDeleteAction;
    FFormPopupMenu.Items.Add(Menu);

    TApplicationMessageProcessor.RegisterOnMessage(Self, ApplicationOnMessage);

    FDesignerType := dtUser;
    if Assigned(IBLogin) then
      if IBLogin.IsIBUserAdmin then
        FDesignerType := dtGlobal;
  end;
end;

destructor TgsResizeManager.Destroy;
begin
  if not (csDesigning in Self.ComponentState) then
  begin
    TApplicationMessageProcessor.UnRegisterOnMessage(Self);
    Enabled := False;
    ClearResizers;

    FreeAndNil(FEmulatorsList);
    FreeAndNil(FResizerList);
    FreeAndNil(FAlignmentForm);
    FreeAndNil(FComponentsForm);
    FreeAndNil(FAlignmentAction);
    FreeAndNil(FSetSizeAction);
    FreeAndNil(FPasteAction);
    FreeAndNil(FCutAction);
    FreeAndNil(FCopyAction);
    FreeAndNil(FCopyNameAction);
    FreeAndNil(FDeleteAction);
    FreeAndNil(FFormPopupMenu);

    FreeAndNil(FAddNewPage);
    FreeAndNil(FDeletePage);
    FreeAndNil(FNextPage);
    FreeAndNil(FPrevPage);
//    FPageControlMenu.Free;

    FreeAndNil(FSetSizeForm);
    FreeAndNil(FTabOrderForm);
//    FPaletteForm.Free;
//    FObjectInspectorForm.Free;
    if ActiveDesigner = Self then
      ActiveDesigner := nil;

    FreeAndNil(FChangedPropList);
    FreeAndNil(FStartPropList);

    FreeAndNil(FPropNotifyList);
    if Assigned(FHintTimer) then
      FreeAndNil(FHintTimer);
    if Assigned(FHintWindow) then
      FreeAndNil(FHintWindow);

    FRemovalList.Clear;
    FreeAndNil(FRemovalList);
    if Assigned(FInvisibleList) then
      FreeAndNil(FInvisibleList);
    if Assigned(FInvisibleTabsList) then
      FreeAndNil(FInvisibleTabsList);
  end;
  SetEditForm(nil);
  FreeAndNil(FEventList);
  FreeAndNil(FEventActionList);
  FreeAndNil(FChangedEventList);
  FreeAndNil(FDelphiEventList);
  FreeAndNil(FChangedNames);
  FreeAndNil(FDeletedComponents);

  inherited;
end;

procedure TgsResizeManager.StartMove(const ResizeMode: TCursorPos);
begin
  StartMove(Point(0,0), ResizeMode);
end;

procedure TgsResizeManager.StartMove(const P: TPoint;
  const ResizeMode: TCursorPos);
var
  I: Integer;
  R: TRect;
  Flag: Boolean;
begin
  Flag := False;
  if ResizeMode <> cpNone then
  begin
    for I := 0 to FResizerList.Count - 1 do
    begin
      if not Resizers[I].Cut then
      begin
        Resizers[I].StartMove(ResizeMode);
        FP := P;
        Flag := True;
      end;
    end;
    //Ограничиваем перемещение курсора
    if Flag then
    begin
      R := FParentControl.ClientRect;
      offsetrect(R, FParentControl.ClientOrigin.X, FParentControl.ClientOrigin.Y);
      ClipCursor(@R);
    end;
  end;
end;

procedure TgsResizeManager.Move(var DX, DY: Integer; const AnGridSize: Integer = 1);
var
  I: Integer;
  GS: Integer;
begin
  GS := AnGridSize;
  for I := 0 to FResizerList.Count - 1 do
  begin
    if Resizers[I].Move(DX, DY, GS) then
      GS := 1;
  end;
end;

procedure TgsResizeManager.Move(P: TPoint);
var
  DX, DY: Integer;
begin
  DX := P.X - FP.X;
  DY := P.Y - FP.Y;

  if (Abs(DX) >= GridSize) or (Abs(DY) >= GridSize) then
  begin
    Move(DX, DY, GridSize);
    FP.X := FP.X + DX;
    FP.Y := FP.Y + DY;
  end
end;

procedure TgsResizeManager.EndMove;
var
  I: Integer;
begin
  for I := 0 to FResizerList.Count - 1 do
  begin
    Resizers[I].EndMove;
  end;
  ClipCursor(nil);
end;

procedure TgsResizeManager.FormWindowProc(var Msg: TMessage);
  procedure CheckNewControl(Msg: TWMParentNotify; const ALeft: Boolean);
  var
    P: TPoint;
    M: TMessage;
  begin
    FNewControl := ControlAtPos(FEditForm, FEditForm.ClientToScreen(Point(TWMPARENTNOTIFY(Msg).XPos, TWMPARENTNOTIFY(Msg).YPos)));
    if ALeft then
    begin
      PostMessage(FMessageHooker.Handle, CM_NEWCONTROL, TWMPARENTNOTIFY(Msg).XPos, TWMPARENTNOTIFY(Msg).YPos);
      if FNewControl is TPageControl then
      begin
        M := TMessage(Msg);
        P.x := TWMPARENTNOTIFY(Msg).XPos;
        P.y := TWMPARENTNOTIFY(Msg).YPos;
        P := FNewControl.ScreenToClient(FEditForm.ClientToScreen(P));
        M.LParamLo := P.x;
        M.LParamHi := P.y;
        SendMessage(TPageControl(FNewControl).handle, WM_LBUTTONDOWN, M.WParam, M.LParam);
      end
    end
    else
      PostMessage(FMessageHooker.Handle, CM_NEWCONTROLR, TWMPARENTNOTIFY(Msg).XPos, TWMPARENTNOTIFY(Msg).YPos);
  end;

  procedure ShowMenu(Msg: TWMParentNotify);
  var
    P: TPoint;
  begin
    P := FEditForm.ClientToScreen(Point(TWMPARENTNOTIFY(Msg).XPos, TWMPARENTNOTIFY(Msg).YPos));
    PostMessage(FMessageHooker.Handle, CM_SHOWMENU, P.X, P.Y);
  end;

  procedure InsertNewControl(Msg: TWMParentNotify);
  begin
    PostMessage(FMessageHooker.Handle, CM_INSERTNEW, TWMPARENTNOTIFY(Msg).XPos, TWMPARENTNOTIFY(Msg).YPos);
  end;
var
  KillMessage: Boolean;
  CurPnt: TPoint;

begin
  KillMessage := True;

  if (not FEnabled) or (Busy and (not (Msg.Msg = WM_CONTEXTMENU))) then
  begin

    try
      FOldFormWindowProc(Msg);
    except
      on E: Exception do
      begin
        Application.ShowException(E);
      end;
    end;
    Exit;
  end;

  case Msg.Msg of
    WM_KEYDOWN, WM_KEYUP, WM_IME_KEYDOWN:
      SendMessage(FMessageHooker.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
    WM_LBUTTONDOWN:
      if (FManagerState = msDesign) and (not IsInResize) then
        CheckNewControl(TWMParentNotify(Msg), True)
      else
        InsertNewControl(TWMParentNotify(Msg));
    WM_LBUTTONUP:
      if FMultiSelect then
        EndMultiSelect(FEditForm.ClientToScreen(Point(TWMMouseMove(Msg).xPos, TWMMouseMove(Msg).yPos)));
    WM_RBUTTONDOWN:
      if (FManagerState = msDesign) and (not IsInResize) then
        CheckNewControl(TWMParentNotify(Msg), False);
    WM_RBUTTONUP:
      ShowMenu(TWMParentNotify(Msg));

    WM_PARENTNOTIFY:
      case TWMParentNotify(Msg).Event of
        WM_LBUTTONDOWN:
          if (FManagerState = msDesign) and not IsInResize then
            CheckNewControl(TWMParentNotify(Msg), True)
          else
            InsertNewControl(TWMParentNotify(Msg));
        WM_RBUTTONDOWN:
          if (FManagerState = msDesign) and (not IsInResize) then
            CheckNewControl(TWMParentNotify(Msg), False);
        WM_RBUTTONUP:
          ShowMenu(TWMParentNotify(Msg))
        else
          KillMessage := False;
      end;
    CM_DIALOGKEY:
      SendMessage(FMessageHooker.Handle, Msg.Msg, Msg.WParam, Msg.LParam);
    WM_USER_LBUTTONUP:
      if FMultiSelect and GetCursorPos(CurPnt) then
          EndMultiSelect(CurPnt);
    WM_USER_MOUSEMOVE:
      if FMultiSelect then
      begin
        if GetCursorPos(CurPnt) then
        begin
          if (TWMMouseMove(Msg).Keys and Integer(ssLeft)) <> 0 then
            MoveMultiSelect(CurPnt)
          else
            EndMultiSelect(CurPnt);
        end;
      end else
        ShowHint;
    WM_NCMOUSEMOVE,
    WM_MOUSEMOVE:
    begin
      FCursor := False;
      KillMessage := False;
    end;
    WM_CONTEXTMENU, WM_ACTIVATE:
      KillMessage := True;
      //ShowMenu(TWMParentNotify(Msg))
    CM_INSERTNEW2:
      SendMessage(FMessageHooker.Handle, Msg.Msg, Msg.WParam, Msg.LParam)
    else
      KillMessage := False;

  end;

  if not KillMessage then
    FOldFormWindowProc(Msg);
//  else
  //  Msg.Result := True;


{  if (Msg.Msg = WM_PAINT) and (FGridSize > 0) then
  begin
  with FEditForm do
    for I := 0 to ClientWidth div FGridSize do
      for J := 0 to ClientHeight div FGridSize do
        Canvas.Pixels[I * FGridSize, J * FGridSize] := clBlack;
  end;}

  if (Msg.Msg = WM_SIZE) then
    PostMessage(FMessageHooker.handle, CM_RESIZECONTROL, 0, 0);


end;

function TgsResizeManager.GetBusy: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FResizerList.Count - 1 do
  begin
    Result := TgsResizer(FResizerList[I]).Busy;
    if Result then Break;
  end;
end;

procedure TgsResizeManager.SetEditForm(AForm: TForm);
begin
  if FFirstLoad then
  begin
    FEditForm := nil;
    FFirstLoad := False;
  end;
  if FEditForm <> AForm then
  begin
    if not (csDesigning in ComponentState) then
      if FEditForm <> nil then
      begin
        FActionList.Free;
        if Assigned(FMessageHooker) then
          FMessageHooker.Free;
        FEditForm.WindowProc := FOldFormWindowProc;
      end;

    FEditForm := AForm;
    //
    if not (csDesigning in ComponentState) then
      if FEditForm <> nil then
      begin
        FActionList := TActionList.Create(FEditForm);
        FStartAction := TAction.Create(FActionList);
        FStartAction.OnExecute := OnStartAction;
        FStartAction.ShortCut := FShortCut;
        FStartAction.ActionList := FActionList;
        FMacrosAction := TAction.Create(FActionList);
        FMacrosAction.OnExecute := OnMacrosAction;
        FMacrosAction.ShortCut := FMacrosShortCut;
        FMacrosAction.ActionList := FActionList;
        FMessageHooker := TMessageHooker.Create(Self);
        FMessageHooker.Enabled := False;
        FOldFormWindowProc := FEditForm.WindowProc;
        FEditForm.WindowProc := FormWindowProc;

        if Assigned(FObjectInspectorForm) then
          FObjectInspectorForm.SetEditForm;
      end;
  end;
end;

procedure TgsResizeManager.SetEnabled(const Value: Boolean);
  procedure GetAllControls(AnOwner: TWinControl);
  var
    I: Integer;
    T: TgsComponentEmulator;
  begin
    for I := 0 to AnOwner.ComponentCount - 1 do
    begin
      if ((AnOwner.Components[I] is TControl) and (not TControl(AnOwner.Components[I]).Visible)) or
          ((AnOwner.Components[I] is TTabSheet) and not TTabSheet(AnOwner.Components[I]).TabVisible) then
      begin
        if (AnOwner.Components[I] is TTabSheet) and not TTabSheet(AnOwner.Components[I]).TabVisible then
        begin
          FInvisibleTabsList.Add(TControl(AnOwner.Components[I]));
          TTabSheet(AnOwner.Components[I]).TabVisible:= True
        end;
        FInvisibleList.Add(TControl(AnOwner.Components[I]));
        TControl(AnOwner.Components[I]).Show;
        TControl(AnOwner.Components[I]).Visible := True;
      end else
      begin
        if not (AnOwner.Components[I] is TControl) and (AnOwner.Components[I] is TComponent) and
          (AnOwner.Components[I].Name <> '') and (not AnOwner.Components[I].InheritsFrom(TBasicAction)) and
          (not AnOwner.Components[I].InheritsFrom(TTBCustomItem))
          and (not AnOwner.Components[I].InheritsFrom(TMenuItem)) then
        begin
          T := TgsComponentEmulator.Create(AnOwner, AnOwner.Components[I]);
          try
            T.Name := GetNewControlName(T.ClassName);
            T.Caption := '';
            FEmulatorsList.Add(T);
            if AnOwner is TForm then
            begin
              if TForm(AnOwner).ClientHeight < T.Top then
                T.Top := 0;
              if TForm(AnOwner).ClientWidth < T.Left then
                T.Left := 0;
            end
          except
            T.Free;
          end
        end;
      end;

      if (not AnOwner.Components[I].InheritsFrom(TgsResizer)) and
         (not AnOwner.Components[I].InheritsFrom(TgsResizeManager)) and
         (not AnOwner.Components[I].InheritsFrom(TBasicAction)) then
      begin
        TComponentCracker(AnOwner.Components[I]).SetDesigning(True, False);
      end;
    end;
  end;
var
  I: Integer;
  B: Boolean;
  TLP, TLI: TList;

begin
  if Value and Assigned(ActiveDesigner) and ActiveDesigner.Enabled then
    Exit;

  if  Value and Assigned(FonActivate) then
  begin
    B := Value;
    FonActivate(B);
    if not B then
      Exit;
  end;

  if Value <> FEnabled then
  begin
    if not Assigned(FEditForm) then
    begin
      Application.MessageBox('Edit form is not assigned', nil, 0);
    end
    else
    begin
      FEnabled := Value;
      if not (csDesigning in ComponentState) then
      begin

        ClearResizers;
        FEditForm.Invalidate;
        if FEditForm.InheritsFrom(TCreateableForm) then
        begin
          if Value then
            TCreateableForm(FEditForm).CreateableFormState :=
              TCreateableForm(FEditForm).CreateableFormState + [cfsDesigning]
          else
            TCreateableForm(FEditForm).CreateableFormState :=
              TCreateableForm(FEditForm).CreateableFormState - [cfsDesigning]
        end;
        if FEnabled then
        begin
          // запоминаем состояние UnEventMacro
          FMessageHooker.Enabled := True;
          if not FFormPositionChanged then
            FFormPosition := FEditForm.Position;

          FUnEventMacro := UnEventMacro;
          UnEventMacro := True;
          StorePropertyState;
          FOldApplicationActivate := Application.OnActivate;
          Application.OnActivate := ApplicationActivate;
          FOldApplicationDeactivate := Application.OnDeactivate;
          Application.OnDeactivate := ApplicationDeactivate;


          FOldFormOnPaint := FEditForm.OnPaint;
          FOldEditFormResize := FEditForm.OnResize;


          DisableEvents(FEditForm);

          FEditForm.OnCloseQuery := FormOnCloseQuery;
          FEditForm.OnResize := ControlResize;
          FEditForm.OnPaint := FormOnPaint;

          if not Assigned(FInvisibleList) then
            FInvisibleList:= TControlList.Create(False)
          else
            FInvisibleList.Clear;
          if not Assigned(FInvisibleTabsList) then
            FInvisibleTabsList:= TControlList.Create(False)
          else
            FInvisibleTabsList.Clear;

          TLP := TList.Create;
          TLI := TList.Create;
          try
            for I := 0 to FEditForm.ComponentCount - 1 do
            begin
              if FEditForm.Components[I] is TPageControl then
              begin
                TLP.Add(FEditForm.Components[I]);
                TLI.Add(Pointer(TPageControl(FEditForm.Components[I]).ActivePageIndex));
              end;
            end;

            GetAllControls(FEditForm);

            for I := TLI.Count - 1 downto 0 do
              TPageControl(TLP[I]).ActivePageIndex := Integer(TLI[I]);

          finally
            TLP.Free;
            TLI.Free;
          end;

          ActiveDesigner := Self;

          if not Assigned(FPaletteForm) then begin
            FPaletteForm := Tdlg_gsResizer_Palette.Create(Self);
            FFormPopupMenu.Images:= FPaletteForm.ilPalette;
          end;

          FPaletteForm.Caption := FEditForm.Caption + ' (' + strEdit + ')';

          if not Assigned(FObjectInspectorForm) then
            FObjectInspectorForm := Tdlg_gsResizer_ObjectInspector.Create(Self);

          if Assigned(FEditForm) then
          begin
            FObjectInspectorForm.Reset;
            FObjectInspectorForm.SetEditForm;
          end;

          FPaletteForm.Show;
          FObjectInspectorForm.Show;

          FEditForm.Invalidate;
        end
        else
        begin
          FEmulatorsList.Clear;

          FFormPopupMenu.Images:= nil;

          FreeAndNil(FPaletteForm);
          FreeAndNil(FComponentsForm);

          if Assigned(FObjectInspectorForm) then
            FObjectInspectorForm.SaveState;
          FreeAndNil(FObjectInspectorForm);
          if Assigned(FAlignmentForm) then
            FAlignmentForm.Hide;
          if Assigned(FSetSizeForm) then
            FSetSizeForm.Hide;
          if Assigned(FTabOrderForm) then
            FTabOrderForm.Hide;
          if FEditForm.Position <> FFormPosition then
          begin
            TComponentCracker(FEditForm).SetDesigning(True, False);
            FEditForm.Position := FFormPosition;
            TComponentCracker(FEditForm).SetDesigning(False, False);
          end;

          TComponentCracker(FEditForm).SetDesigning(False, True);


          if Assigned(FInvisibleList) then begin
            for I := 0 to FInvisibleList.Count - 1 do
              FInvisibleList[I].Visible := False;
            FreeAndNil(FInvisibleList);
          end;
          if Assigned(FInvisibleTabsList) then begin
            for I := 0 to FInvisibleTabsList.Count - 1 do
              TTabSheet(FInvisibleTabsList[I]).TabVisible := False;
            FreeAndNil(FInvisibleTabsList);
          end;

          FEditForm.OnCloseQuery := nil;

          EnableEvents;

          FEditForm.OnPaint := FOldFormOnPaint;
          FEditForm.OnResize := FOldEditFormResize;

          // Восстанавливаем UnEventMacro
          UnEventMacro := FUnEventMacro;
          if Assigned(EventControl) then
          begin
            if (cfsCloseAfterDesign in TCreateableForm(FEditForm).CreateableFormState) then
              EventControl.ResetEvents(FEditForm)
            else
              EventControl.RebootEvents(FEditForm);
          end;
          FEditForm.Invalidate;

          Application.OnActivate := FOldApplicationActivate;
          Application.OnDeactivate := FOldApplicationDeactivate;
          CheckPropertyState;
          FMessageHooker.Enabled := False;
        end;
      end;
    end;
  end

end;

procedure TgsResizeManager.SetParentControl(Value: TWinControl);
begin
  if FParentControl <> Value then
  begin
//    if (not FCut) and (FParentControl <> nil) then
    if (not FCut) and (Value <> nil) then
    begin
      ClearResizers;
      FParentControl := Value;
    end;
  end;
end;


procedure TgsResizer.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTTAB or DLGC_WANTARROWS;
end;

destructor TgsResizer.Destroy;
begin
  MovedControl := nil;
  ClipCursor(nil);
  inherited;
end;

procedure TgsResizer.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

function TgsResizer.NormRect(const R: TRect): TRect;
begin
  if R.Left > R.Right then
  begin
    Result.Left := R.Right;
    Result.Right := R.Left;
  end
  else
  begin
    Result.Left := R.Left;
    Result.Right := R.Right;
  end;
  if R.Top > R.Bottom then
  begin
    Result.Top := R.Bottom;
    Result.Bottom := R.Top;
  end
  else
  begin
    Result.Top := R.Top;
    Result.Bottom := R.Bottom;
  end;
end;

procedure TgsResizer.UpdateControlAlignment;
begin
//  if (FMovedControl.Align = alNone) then exit;
  Visible := False;
  SetBounds(FMovedControl.Left - HalfRectSize ,FMovedControl.Top - HalfRectSize ,FMovedControl.Width + HalfRectSize * 2, FMovedControl.Height + HalfRectSize * 2);  Visible := True;
  SetFocus;
end;

procedure TgsResizer.SetCut(const Value: boolean);
begin
  if Value <> FCut then
  begin
    FCut := Value;
    FMovedControl.Invalidate;
    Invalidate;
  end;
end;

procedure TgsResizer.SetNewParent(AParent: TWinControl);
begin
  if FCut then
  begin
    Visible := False;

    if Assigned(EventControl) then
      EventControl.PropertyNotification(FMovedControl, poRemove);

    FMovedControl.Parent := AParent;

    if Assigned(EventControl) then
      EventControl.PropertyNotification(FMovedControl, poInsert);

    if FMovedControl.Left > FMovedControl.Parent.Width then
      FMovedControl.Left := FMovedControl.Parent.Width - FMovedControl.Width;
    if FMovedControl.Top > FMovedControl.Parent.Height then
      FMovedControl.Top := FMovedControl.Parent.Height - FMovedControl.Height;

    Reset;
    Visible := True;
  end;
end;

procedure TgsResizeManager.CutAction(Sender: TObject);
begin
  Cut;
end;

procedure TgsResizeManager.DoAlignmentAction(Sender: TObject);
begin
  DoAlignment;
end;

procedure TgsResizer.Reset;
var
  C: TControl;
begin
  if Assigned(FMovedControl) then
  begin
    C := MovedControl;
    MovedControl := nil;
    MovedControl := C;
  end
end;



procedure TgsResizer.DblClick;
var
  PropertyEditor: TgsPropertyEditor;
  O, O1: TPersistent;
  PrName: String;
  PrClass: TClass;
begin
  if MovedControl is TgsComponentEmulator then
  begin
    if TgsComponentEmulator(MovedControl).RelatedComponent is TActionList then
    begin
      ReleaseCapture;
      inherited;
      FManager.EndMove;

      // проверяется на наличие окна, если окно существует,
      // то его активизация, иначе создаем окно
      if not Assigned(FCollectionEditor) then
      begin
        FCollectionEditor := TFrmCollectionEditor.Create(Self);
        try
          FCollectionEditor.ShowCollectionEditor(FManager,
            TgsComponentEmulator(MovedControl).RelatedComponent as TActionList);
        finally
        end;
      end else
        FCollectionEditor.Show;
    end
    else if TgsComponentEmulator(MovedControl).RelatedComponent is TCustomImageList then
    begin
      ReleaseCapture;
      inherited;
      FManager.EndMove;
      // проверяется на наличие окна, если окно существует,
      // то его активизация, иначе создаем окно
      if not Assigned(FImageListEditor) then
        FImageListEditor := TdlgImageListEditor.Create(Self);

      try
        FImageListEditor.Edit(TgsComponentEmulator(MovedControl).RelatedComponent as TCustomImageList);
      finally
      end;

    end
    else if (TgsComponentEmulator(MovedControl).RelatedComponent is TMenu) or
            (TgsComponentEmulator(MovedControl).RelatedComponent is TImage) then
    begin
      ReleaseCapture;
      inherited;
      FManager.EndMove;

      if TgsComponentEmulator(MovedControl).RelatedComponent is TMenu then
      begin
        PrName := 'Items';
        PrClass := TMenuItem;
      end else if TgsComponentEmulator(MovedControl).RelatedComponent is TMenu then
      begin
        PrName := 'Picture';
        PrClass := TPicture;
      end
      else
        Exit;



      O := TPersistent(GetObjectProp(TgsComponentEmulator(MovedControl).RelatedComponent, PrName, TPersistent));
      if O = nil then
        Exit;

      PropertyEditor := GetGsPropertyEditor(PrClass.ClassName, '', PrClass, FManager.FObjectInspectorForm);
      // проверяется на наличие окна, если окно существует,
      // то его активизация, иначе создаем окно
      if Assigned(PropertyEditor) then
      begin
        PropertyEditor.CurrentComponent := TgsComponentEmulator(MovedControl).RelatedComponent;
        if PropertyEditor.ShowExternalEditor(O) then
        begin
          O1 := TPersistent(GetObjectProp(TgsComponentEmulator(MovedControl).RelatedComponent, PrName, TPersistent));
          O1.Assign(O);
        end;
      end;
    end;
  end;
end;


procedure TgsResizer.CMPropertyChanged(var Message: TMessage);
begin
  if (FMovedControl = Pointer(Message.WParam)) or
     ((FMovedControl is TgsComponentEmulator) and (TgsComponentEmulator(FMovedControl).RelatedComponent = Pointer(Message.WParam))) then
  begin
    self.setbounds(FMovedControl.Left - HalfRectSize,
                   FMovedControl.Top - HalfRectSize,
                   FMovedControl.Width + HalfRectSize * 2,
                   FMovedControl.Height + HalfRectSize * 2);
    invalidate;
  end;
end;

function TgsResizer.AlignPointToGrid(const AnValue: Integer; var AnOffSet: Integer; const AnGridSize: Integer): Integer;
begin
//!!! Для полной привязки к гриду !!!//
//  Result := ((AnValue + AnOffSet) div AnGridSize) * AnGridSize;

  Result := (AnValue + AnOffSet - (AnOffSet mod AnGridSize));
  AnOffSet := Result - AnValue;
end;

procedure TgsResizer.WndProc(var Message: TMessage);
var
  P: TPoint;
begin
  case Message.Msg of
    WM_USER_MOUSEMOVE:
    begin
      if Assigned(FMovedControl) and ((TWMMouseMove(Message).Keys and Integer(ssLeft)) = 0) then
      begin
        P := FMovedControl.ScreenToClient(Point(TWMMouseMove(Message).XPos, TWMMouseMove(Message).YPos));
        FManager.FCursor := not (GetMousePos(P.x, P.y) in [cpNone, cpInside]);
      end
    end;
    WM_USER_LBUTTONUP:;
  else
    inherited;
  end;
end;

procedure TgsResizer.EndMultiSelect;
begin
  FState := dsNone;
end;

procedure TgsResizer.StartMultiSelect;
begin
  
  FState := dsMultiSelect;
end;

procedure TgsResizer.DoResize(Sender: TObject);
begin
//  if FManager.FShowEcho then
//    DrawRect;
//  FMovedRect.TopLeft := Self.ClientToScreen(Point(0,0));
//  FMovedRect.BottomRight := Self.ClientToScreen(Point(Width, Height));
  SendToBack;
  SetBounds((Sender as TControl).Left, (Sender as TControl).Top,
   (Sender as TControl).Width, (Sender as TControl).Height);
  BringToFront;
//  Invalidate;
//  Repaint;
end;

procedure TgsResizer.ControlWindowProc(var Message: TMessage);
var
  KillMessage: Boolean;
begin
  KillMessage := False;

  case Message.Msg of
    WM_SETFOCUS:
    begin
//      Message.Result := MA_NOACTIVATEANDEAT;
      KillMessage := True;
      SetFocus;
      BringToFront;
    end
  end;

  if (not KillMessage) and Assigned(FControlWindowProc) then
    FControlWindowProc(Message);
end;

{ TMessageHooker }

procedure TMessageHooker.CMAddControl(var Message: TMessage);
begin
  try
    FManager.AddResizer(FManager.FNewControl, False);
  except
  end;
  FManager.FNewControl := nil;
end;

procedure TMessageHooker.CMDeleteControl(var Message: TMessage);
begin
  FManager.DeleteControls;
end;

procedure TMessageHooker.CMInsertNew(var Message: TMessage);
begin
  FManager.InsertNewControl(Point(Message.WParam, Message.LParam));
end;

procedure TMessageHooker.CMInsertNew2(var Message: TMessage);
begin
  FManager.InsertNewControl2;
end;

procedure TMessageHooker.CMNewControl(var Message: TMessage);
begin

  GetAsyncKeyState(VK_SHIFT);
  try
    if FManager.AddResizer(FManager.FNewControl, GetAsyncKeyState(VK_SHIFT) <> 0) then
    begin
      Windows.SetCursor(Screen.Cursors[crDefault]);
      FManager.FShowEcho := True;
      FManager.StartMove(FManager.FEditForm.ClientToScreen(Point(Message.WParam, Message.LParam)), cpInside);
      SetCapture(FManager.Resizers[FManager.FResizerList.Count -1].Handle);
    end;
  except
  end;
  FManager.FNewControl := nil;
end;

procedure TMessageHooker.CMNewControlR(var Message: TMessage);
begin
  GetAsyncKeyState(VK_SHIFT);
  try
    FManager.AddResizer(FManager.FNewControl, GetAsyncKeyState(VK_SHIFT) <> 0);
  except
  end;
  FManager.FNewControl := nil;
end;


procedure TMessageHooker.CMResizeControls(var Message: TMessage);
var
  I: Integer;
begin
  for I := 0 to FManager.FResizerList.Count - 1 do
  begin
    FManager.Resizers[I].UpdateControlAlignment;
  end;
end;

procedure TMessageHooker.CMShowEditForm(var Message: TMessage);
begin
  FManager.FEditForm.BringToFront;
end;

procedure TMessageHooker.CMShowEvents(var Message: TMessage);
begin
  FManager.ShowEvents;
end;

procedure TMessageHooker.CMShowInspector(var Message: TMessage);
begin
  if Assigned(FManager.FObjectInspectorForm) then
    FManager.FObjectInspectorForm.Show;
end;

procedure TMessageHooker.CMShowMenu(var Message: TMessage);
var
  C, CW: TControl;
  P: TPoint;
  AP: TTabSheet;
begin
//  P := FManager.FEditForm.ClientToScreen(Point(Message.WParam, Message.LParam));
  if FManager.Busy then
    Exit;
  P := Point(Message.WParam, Message.LParam);
  C := FManager.ControlAtPos(FManager.FEditForm, P, True);
  CW:= FManager.ControlAtPos(FManager.FEditForm, P, False, True);

  if C is TgsResizer then
    C := TgsResizer(C).FMovedControl;

  while Assigned(C) and (C.Name = '') do
    C := C.Parent;


  FManager.FTabOrderAction.Enabled := False;

  if Assigned(C) and (C is TControl) then
  begin
    FManager.FPopupControl := C;
    FManager.FTabOrderAction.Enabled := True;
  end;

  if Assigned(C) and (((not (C is TgsComponentEmulator)) and ((Pos(USERCOMPONENT_PREFIX, C.Name) = 1) or
                 ((FManager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, C.name) = 1)))) or
      ((C is TgsComponentEmulator) and ((Pos(USERCOMPONENT_PREFIX, TgsComponentEmulator(C).RelatedComponent.Name) = 1) or
                 ((FManager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, TgsComponentEmulator(C).RelatedComponent.Name) = 1))))) then
    FManager.FDeleteAction.Enabled := True
  else
    FManager.FDeleteAction.Enabled := False;

  if FManager.FResizerList.Count > 0 then
    FManager.FCopyAction.Enabled := True
  else
    FManager.FCopyAction.Enabled := False;

  if Assigned(C) and (not ((C is TTabSheet) or (C is TToolButton) or (C is TgsComponentEmulator))) then begin
    FManager.FCutAction.Enabled := True;
    FManager.FBringToFrontAction.Enabled:= C is TControl;
    FManager.FSendToBackAction.Enabled:= C is TControl;
  end
  else begin
    FManager.FCutAction.Enabled := False;
    FManager.FBringToFrontAction.Enabled:= False;
    FManager.FSendToBackAction.Enabled:= False;
  end;

  if FManager.FResizerList.Count > 0 then
    FManager.FAlignmentAction.Enabled := True
  else
    FManager.FAlignmentAction.Enabled := False;

  if FManager.FResizerList.Count <= 1 then
    FManager.FSetSizeAction.Enabled := False
  else
    FManager.FSetSizeAction.Enabled := True;

  if FManager.FCut then
    FManager.FCancelAction.Enabled := True
  else
    FManager.FCancelAction.Enabled := False;

{  if Assigned(C) and (C is TWinControl) and ((((FManager.FCut) and (C.InheritsFrom(TWinControl)) and
     (csAcceptsControls in C.ControlStyle) and (C <> FManager.FParentControl)))
     or (not FManager.FCut) and Clipboard.HasFormat(CF_TEXT) and (Pos('object', Clipboard.AsText) = 1)) then}
  if Assigned(CW) and (CW is TWinControl) and ((((FManager.FCut) and (CW.InheritsFrom(TWinControl)) and
     (csAcceptsControls in CW.ControlStyle) and (CW <> FManager.FParentControl)))
     or (not FManager.FCut) and Clipboard.HasFormat(CF_TEXT) and (Pos('object', Clipboard.AsText) = 1)) then
  begin
    FManager.FNewParent := (CW as TWinControl);
    FManager.FPasteAction.Enabled := True;
  end
  else
    FManager.FPasteAction.Enabled := False;

  if Assigned(C) and ((C is TPageControl) or (C is TTabSheet)) then
  begin
    if (C is TPageControl) then
      FManager.FParentControl := TWinControl(C);
    FManager.FPageControlMenu.Visible := True;
    AP := nil;
    if (C is TPageControl) and
      (TPageControl(FManager.FParentControl).PageCount > 0) and
      (TPageControl(FManager.FParentControl).ActivePage <> nil) then
      AP := TPageControl(FManager.FParentControl).ActivePage
    else if (C is TTabSheet) then
      AP := TTabSheet(C);
    if Assigned(AP) and ((Pos(USERCOMPONENT_PREFIX, AP.Name) = 1) or
     ((FManager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, AP.Name) = 1))) then
      FManager.FDeletePage.Enabled := True
    else
      FManager.FDeletePage.Enabled := False;
  end
  else
    FManager.FPageControlMenu.Visible := False;

  FManager.FFormPopupMenu.Popup(P.X, P.Y);
end;

procedure TMessageHooker.CMShowPalette(var Message: TMessage);
begin
  if Assigned(FManager.FPaletteForm) then
    FManager.FPaletteForm.Show;
end;

constructor TMessageHooker.Create(AnOwner: TComponent);
begin
  inherited;
  Assert(AnOwner is TgsResizeManager);
  FManager := AnOwner as TgsResizeManager;
end;

procedure TMessageHooker.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT;
end;

procedure TgsResizeManager.SetGridSize(const Value: Integer);
begin
  if Value <> FGridSize then
  begin
    FGridSize := Value;
    if (not (csDesigning in ComponentState)) and Assigned(FEditForm) then
      FEditForm.Repaint;
  end;
end;

procedure TgsResizeManager.Cut;
var
  I: Integer;
begin
  Clipboard.Open;
  Clipboard.AsText := '';
  Clipboard.Close;

  FCut := True;
  for I := 0 to FResizerList.Count - 1 do
  begin
    Resizers[I].Cut := True;
  end;
end;

procedure TgsResizeManager.Paste(Sender: TObject);
var
  I: Integer;
  S1: TStringStream;
  S2: TMemoryStream;
  R: TDesignReader;
  L: TList;
  T: TgsComponentEmulator;
  Par: TControl;
begin
  if FNewParent is TgsComponentEmulator then
    FNewParent := FEditForm;

  if FCut then
  begin
    Par:= FNewParent;
    while Assigned(Par) and (Par <> FEditForm) do begin
      for I := 0 to FResizerList.Count - 1 do
        if (Par = (FResizerList[i] as TgsResizer).FMovedControl) and (FResizerList[i] as TgsResizer).FCut then begin
          FNewParent:= FEditForm;
          Break;
        end;
      Par:= Par.Parent;
    end;

    FCut := False;

    for I := 0 to FResizerList.Count - 1 do
    begin
      if (FNewParent <> FParentControl) and Assigned(FNewParent) then
        Resizers[I].SetNewParent(FNewParent);
      Resizers[I].Cut := False;
    end;

    if (FNewParent <> FParentControl) and Assigned(FNewParent) then
      FParentControl := FNewParent;
    FNewParent := nil;

    for I := FResizerList.Count - 1 downto 0 do
    begin
      if Resizers[I].FMovedControl.Parent <> FParentControl then
        FResizerList.Delete(I);
    end;

    for I := 0 to FResizerList.Count - 1 do
      if Assigned(FObjectInspectorForm) and (Resizers[I].FMovedControl.Parent = FParentControl) then
        FObjectInspectorForm.AddEditComponent(Resizers[I].FMovedControl, I > 0);

  end
  else
  begin
    if not Clipboard.HasFormat(CF_Text) then
      Exit;
    if (FNewParent <> FParentControl) and Assigned(FNewParent) then
    begin
      FParentControl := FNewParent;
    end;

    FNewParent := nil;

    Clipboard.Open;
    try
      S1 := TStringStream.Create(Clipboard.AsText);
      S2 := TMemoryStream.Create;

      try
        try
          ClipboardTextToBinary(S1, S2);
          S2.Seek(0, soFromBeginning);
          R := TDesignReader.Create(S2, 4096);
          R.Designer := Self;
          AddResizer(FEditForm, False);
          try
            L := TList.Create;
            try
              R.ReadBufComponents(FEditForm, FParentControl, L);

              for I := 0 to L.Count - 1 do
              begin
                if (TObject(L[I]) is TControl) then
                  AddResizer(TControl(L[I]), True);
                if Assigned(EventControl) and (TObject(L[I]) is TComponent) then
                  EventControl.PropertyNotification(TComponent(L[I]), poInsert);

                if not (TObject(L[I]) is TControl) and (TObject(L[I]) is TComponent) and
                  (TComponent(L[I]).Name <> '') and (not TComponent(L[I]).InheritsFrom(TBasicAction)) and
                  (not TComponent(L[I]).InheritsFrom(TTBCustomItem))
                  and (not TComponent(L[I]).InheritsFrom(TMenuItem)) then
                begin
                  T := TgsComponentEmulator.Create(FEditForm, TComponent(L[I]));
                  try
                    T.Name := GetNewControlName(T.ClassName);
                    T.Caption := '';
                    FEmulatorsList.Add(T);
                    if FEditForm.ClientHeight < T.Top then
                      T.Top := 0;
                    if FEditForm.ClientWidth < T.Left then
                      T.Top := 0;
                    AddResizer(T, True);
                  except
                    T.Free;
                  end
                end;
              end;
              if Assigned(FObjectInspectorForm) then
                FObjectInspectorForm.RefreshList;

            finally
              L.free;
            end;
          finally
            R.Free;
          end;
        except
          on E: Exception do
            ShowMessage('Ошибка: ' + E.Message);
        end;
      finally
        S1.Free;
        S2.Free;
      end
    finally
      Clipboard.Close;
    end;
  end;

end;


procedure TgsResizeManager.CancelCut(Sender: TObject);
var
  I: Integer;
begin
  FCut := False;
  for I := 0 to FResizerList.Count - 1 do
    Resizers[I].Cut := False;
end;

procedure TgsResizeManager.SetAlignment(
  const AnAlignment: TPositionAlignment);
var
  I, J, K, L: Integer;
  A: Array of TPoint;
  procedure SortArray;
  var
    X, Y: Integer;
    P: TPoint;
  begin
    for X := 0 to High(A) - 1 do
      for Y := X + 1 to High(A) do
      begin
        if A[X].x > A[Y].x then
        begin
          P := A[X];
          A[X] := A[Y];
          A[Y] := P;
        end
      end;
  end;
begin
  if FResizerList.Count = 0 then
    exit;
  case AnAlignment of
    paLeft, paRight, paTop, paBottom, paCenterVert, paCenterHoriz, paSpaceEqualHoriz, paSpaceEqualVert:
      begin
        if FResizerList.Count <= 1 then
          Exit;
         case  AnAlignment of
           paLeft:
             begin
               J := Resizers[0].FMovedControl.Left;
               for I := 1 to FResizerList.Count - 1 do
               begin
                 if J > Resizers[I].FMovedControl.Left then
                   J := Resizers[I].FMovedControl.Left;
               end;
               for I := 0 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Left := J;
                 Resizers[I].Reset;
               end;
             end;
           paRight:
             begin
               J := Resizers[0].FMovedControl.Left + Resizers[0].FMovedControl.Width;
               for I := 1 to FResizerList.Count - 1 do
               begin
                 if J < (Resizers[I].FMovedControl.Left + Resizers[I].FMovedControl.Width) then
                   J := Resizers[I].FMovedControl.Left + Resizers[I].FMovedControl.Width;
               end;
               for I := 0 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Left := J - Resizers[I].FMovedControl.Width;
                 Resizers[I].Reset;
               end;
             end;
           paTop:
             begin
               J := Resizers[0].FMovedControl.Top;
               for I := 1 to FResizerList.Count - 1 do
               begin
                 if J > Resizers[I].FMovedControl.Top then
                   J := Resizers[I].FMovedControl.Top;
               end;
               for I := 0 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Top := J;
                 Resizers[I].Reset;
               end;
             end;
           paBottom:
             begin
               J := Resizers[0].FMovedControl.Top + Resizers[0].FMovedControl.Height;
               for I := 1 to FResizerList.Count - 1 do
               begin
                 if J < (Resizers[I].FMovedControl.Top + Resizers[I].FMovedControl.Height) then
                   J := Resizers[I].FMovedControl.Top + Resizers[I].FMovedControl.Height;
               end;
               for I := 0 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Top := J - Resizers[I].FMovedControl.Height;
                 Resizers[I].Reset;
               end;
             end;
           paCenterVert:
             begin
                J := Resizers[0].FMovedControl.Top + (Resizers[0].FMovedControl.Height div 2);
               for I := 1 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Top := J - (Resizers[I].FMovedControl.Height div 2);
                 Resizers[I].Reset;
               end;
             end;
           paCenterHoriz:
             begin
               J := Resizers[0].FMovedControl.Left + (Resizers[0].FMovedControl.Width div 2);
               for I := 1 to FResizerList.Count - 1 do
               begin
                 Resizers[I].FMovedControl.Left := J - (Resizers[I].FMovedControl.Width div 2);
                 Resizers[I].Reset;
               end;
             end;
           paSpaceEqualHoriz:
             begin
               SetLength(A, FResizerList.Count);
               try
                 J := Resizers[0].FMovedControl.Left;
                 K := Resizers[0].FMovedControl.Left;
                 A[0].X := Resizers[0].FMovedControl.Left;
                 A[0].Y := 0;
                 for I := 1 to FResizerList.Count - 1 do
                 begin
                   if J > Resizers[I].FMovedControl.Left then
                     J := Resizers[I].FMovedControl.Left;
                   if K < Resizers[I].FMovedControl.Left then
                     K := Resizers[I].FMovedControl.Left;
                   A[I].X := Resizers[I].FMovedControl.Left;
                   A[I].Y := I;
                 end;
                 L := (K - J) div (FResizerList.Count - 1);
                 SortArray;
                 for I := 0 to High(A) - 1 do
                 begin
                   Resizers[A[I].y].FMovedControl.Left := J + L * I;
                   Resizers[A[I].y].Reset;
                 end;
               finally
                 SetLength(A, 0);
               end;
             end;
           paSpaceEqualVert:
             begin
               SetLength(A, FResizerList.Count);
               try
                 J := Resizers[0].FMovedControl.Top;
                 K := Resizers[0].FMovedControl.Top;
                 A[0].X := Resizers[0].FMovedControl.Top;
                 A[0].Y := 0;
                 for I := 1 to FResizerList.Count - 1 do
                 begin
                   if J > Resizers[I].FMovedControl.Top then
                     J := Resizers[I].FMovedControl.Top;
                   if K < Resizers[I].FMovedControl.Top then
                     K := Resizers[I].FMovedControl.Top;
                   A[I].X := Resizers[I].FMovedControl.Top;
                   A[I].Y := I;
                 end;
                 L := (K - J) div (FResizerList.Count - 1);
                 SortArray;
                 for I := 0 to High(A) - 1 do
                 begin
                   Resizers[A[I].y].FMovedControl.Top := J + L * I;
                   Resizers[A[I].y].Reset;
                 end;
               finally
                 SetLength(A, 0);
               end;
             end;
         end;
      end;
    paCenterFormHoriz:
      begin
        J := Resizers[0].FMovedControl.Left;
        K := Resizers[0].FMovedControl.Left + Resizers[0].FMovedControl.Width;
        for I := 1 to FResizerList.Count - 1 do
        begin
          if J > Resizers[I].FMovedControl.Left then
            J := Resizers[I].FMovedControl.Left;
          if K < Resizers[I].FMovedControl.Left + Resizers[I].FMovedControl.Width then
            K := Resizers[I].FMovedControl.Left + Resizers[I].FMovedControl.Width;
        end;
        L := (FParentControl.Width div 2) - (J + ((K - J) div 2));
        for I := 0 to FResizerList.Count - 1 do
        begin
          Resizers[I].FMovedControl.Left := Resizers[I].FMovedControl.Left + L;
          Resizers[I].Reset;
        end
      end;
    paCenterFormVert:
      begin
        J := Resizers[0].FMovedControl.Top;
        K := Resizers[0].FMovedControl.Top + Resizers[0].FMovedControl.Height;
        for I := 1 to FResizerList.Count - 1 do
        begin
          if J > Resizers[I].FMovedControl.Top then
            J := Resizers[I].FMovedControl.Top;
          if K < Resizers[I].FMovedControl.Top + Resizers[I].FMovedControl.Height then
            K := Resizers[I].FMovedControl.Top + Resizers[I].FMovedControl.Height;
        end;

        L := (FParentControl.Height div 2) - (J + ((K - J) div 2));
        for I := 0 to FResizerList.Count - 1 do
        begin
          Resizers[I].FMovedControl.Top := Resizers[I].FMovedControl.Top + L;
          Resizers[I].Reset;
        end
      end;
  end;
end;

procedure TgsResizeManager.DoAlignment;
begin
  if not Assigned(FAlignmentForm) then
    FAlignmentForm := Tdlg_gsResizer_AlignmentPalette.Create(Self);
  FAlignmentForm.Show;
end;

function TgsResizeManager.GetResizer(const Index: Integer): TgsResizer;
begin
  Result := FResizerList[Index] as TgsResizer;
end;

procedure TgsResizeManager.SetControlSize(const ASizeType: TSizeChanger);
var
  H, W, I: Integer;
begin
  if FResizerList.Count = 0 then
    Exit;
  H := Resizers[0].FMovedControl.Height;
  W := Resizers[0].FMovedControl.Width;

  case ASizeType of
    scGrowHoriz, scGrowVert, scGrowBoth:
      for I := 1 to FResizerList.Count - 1 do
      begin
        if H < Resizers[I].FMovedControl.Height then
          H := Resizers[I].FMovedControl.Height;
        if W < Resizers[I].FMovedControl.Width then
          W := Resizers[I].FMovedControl.Width;
      end;
    scShrinkHoriz, scShrinkVert, scShrinkBoth:
      for I := 1 to FResizerList.Count - 1 do
      begin
        if H > Resizers[I].FMovedControl.Height then
          H := Resizers[I].FMovedControl.Height;
        if W > Resizers[I].FMovedControl.Width then
          W := Resizers[I].FMovedControl.Width;
      end;
  end;
  for I := 0 to FResizerList.Count - 1 do
  begin
    if ASizeType in [scGrowHoriz, scGrowBoth, scShrinkHoriz, scShrinkBoth] then
      Resizers[I].FMovedControl.Width := W;
    if ASizeType in [scGrowVert, scGrowBoth, scShrinkVert, scShrinkBoth] then
      Resizers[I].FMovedControl.Height := H;

    Resizers[I].Reset;

  end;
end;

procedure TgsResizeManager.DoSetSize;
begin
  if not Assigned(FSetSizeForm) then
    FSetSizeForm := Tdlg_gsResizer_SetSize.Create(Self);
  FSetSizeForm.Show;
end;

procedure TgsResizeManager.DoSetSizeAction(Sender: TObject);
begin
  DoSetSize;
end;

procedure TgsResizeManager.DoTabOrderAction(Sender: TObject);
begin
  if not Assigned(FTabOrderForm) then
    FTabOrderForm := Tdlg_gsResizer_TabOrder.Create(Self);

    if FResizerList.Count > 0 then
    begin
      if not (Resizers[0].FMovedControl is TgsComponentEmulator) then
        FPopupControl := Resizers[0].FMovedControl
      else
        FPopupControl :=  FEditForm;;
    end
    else
      FPopupControl := FEditForm;

   while  not ((FPopupControl is TWinControl) and (TWinControl(FPopupControl).ControlCount > 0)) do
     if (FPopupControl <> FEditForm) then
        FPopupControl := TControl(FPopupControl).Parent
     else
       Break;

  FTabOrderForm.ShowTabOrder(TWinControl(FPopupControl));
end;

destructor TMessageHooker.Destroy;
begin
  inherited;
end;

procedure TgsResizeManager.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  Index: Integer;
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent is TControl then
      RemovePropertyNotification(TControl(AComponent));
    if AComponent = FMessageHooker then
      FMessageHooker := nil
    else if AComponent = FActionList then
      FActionList := nil
    else if AComponent = FStartAction then
      FStartAction := nil
    else if AComponent = FMacrosAction then
      FMacrosAction := nil
    else
    begin
      if FEnabled and Assigned(FInvisibleList) and (AComponent is TControl) then
      begin
        Index := FInvisibleList.IndexOf(TControl(AComponent));
        if Index >= 0 then
        begin
          FInvisibleList[Index].Visible := False;
          FInvisibleList.Delete(Index);
        end;
      end;
    end;
  end;
end;


function TgsResizeManager.GetNextControl(AControl: TControl;  const Direction: TTabDirection): TControl;
  procedure GetControlsList(StartControl: TWinControl; AList: Tlist);
  var
    I: Integer;
  begin
    if AList = nil then
      Exit;
    for I := 0 to StartControl.ControlCount - 1 do
    begin
      if StartControl.Controls[I].Visible and (not (StartControl.Controls[I] is TWinControl)) then
        AList.Add(StartControl.Controls[I]);
      if StartControl.Controls[I] is TWinControl then
        GetControlsList(TWinControl(StartControl.Controls[I]), AList);
    end;
  end;
var
  LWC, LC : TList;
  CurrentIndex, NextIndex: Integer;
begin

  LWC := TList.Create;
  try
    FEditForm.GetTabOrderList(LWC);
    CurrentIndex := LWC.IndexOf(AControl);

    if (CurrentIndex <> -1) and (AControl is TWinControl) then
    begin
      NextIndex := CurrentIndex + 1;
      while (NextIndex <> LWC.Count) and
            ((not TControl(LWC[NextIndex]).Visible) or
            (TControl(LWC[NextIndex]).ClassType = TMessageHooker) or
            (TControl(LWC[NextIndex]).ClassType = TgsResizer)) do
        inc(NextIndex);

      if NextIndex <> LWC.Count then
      begin
        Result := TControl(LWC[NextIndex]);
        Exit;
      end;
    end;

    LC := TList.Create;

    try
      GetControlsList(FEditForm, LC);

      if (AControl is TWinControl) then
        if LC.Count > 0 then
          Result := TControl(LC[0])
        else
          Result := TControl(LWC[0])
      else
      begin
        CurrentIndex := LC.IndexOf(AControl);
        NextIndex := CurrentIndex + 1;
        if NextIndex = LC.Count then
          if LWC.Count <> 0 then
            Result := TControl(LWC[0])
          else
            Result := TControl(LC[0])
        else
          Result := TControl(LC[NextIndex]);
      end;
     finally
       LC.Free;
     end;
  finally
    LWC.Free;
  end;
end;

procedure TMessageHooker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FManager.FResizerList.Count > 0 then
    Exit;

  FManager.FNewControl := FManager.FEditForm.ActiveControl;
  PostMessage(Handle, CM_ADDCONTROL, 0, 0);
end;

procedure TgsResizeManager.BroadcastResizer(var Message);
var
  I: Integer;
begin
  if not Assigned(FResizerList) then
    Exit;
  if FCursor then
    for I := 0 to FResizerList.Count - 1 do
    begin
      Resizers[I].WindowProc(TMessage(Message));
      if TMessage(Message).Result <> 0 then Exit;
    end;
  if Assigned(FEditForm) then
    FEditForm.WindowProc(TMessage(Message));
end;

procedure TgsResizeManager.ApplicationOnMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  Mes: TMessage;
begin
  if FEnabled then
  begin
    if (Msg.Message = WM_MOUSEMOVE) or (Msg.Message = WM_LBUTTONUP) and Assigned(FEditForm) then
    begin
      Mes.LParam := Msg.lParam;
      Mes.WParam := Msg.wParam;
      case Msg.Message of
        WM_MOUSEMOVE: Mes.Msg := WM_USER_MOUSEMOVE;
        WM_LBUTTONUP: Mes.Msg := WM_USER_LBUTTONUP;
      end;
      Mes.Result := 0;
      BroadcastResizer(Mes);
    end;
    if (Msg.message = WM_LBUTTONDOWN) and (Screen.ActiveForm = FEditForm) and (not (FindControl(Msg.HWND) is TgsResizer))
       and (Msg.hwnd <> FEditForm.Handle) then
    begin
      Handled := True;
    end;
    if (Msg.message = WM_KEYDOWN) or (Msg.message = WM_SYSKEYDOWN) then
    begin
      Handled := True;
      case Msg.wParam of
        VK_F10:
          PostMessage(FMessageHooker.Handle, CM_SHOWPALETTE, 0, 0);
        VK_F11:
          PostMessage(FMessageHooker.Handle, CM_SHOWINSPECTOR, 0, 0);
        Ord('M'):
          begin
            Handled := False;
            if (GetAsyncKeyState(VK_CONTROL) shr 1 > 0) and
              (GetAsyncKeyState(VK_MENU) shr 1 > 0) then
            begin
              if Screen.ActiveForm is TfrmGedeminProperty then
                PostMessage(FMessageHooker.Handle, CM_SHOWEDITFORM, 0, 0)
              else
                PostMessage(FMessageHooker.Handle, CM_SHOWEVENTS, 0, 0);
              Handled := True;
            end;
          end;
        VK_F12:
          begin
            if Screen.ActiveForm is TfrmGedeminProperty then
              PostMessage(FMessageHooker.Handle, CM_SHOWEDITFORM, 0, 0)
            else
              PostMessage(FMessageHooker.Handle, CM_SHOWEVENTS, 0, 0)
          end
        else begin
          Handled := False;
        end;
      end;
      if  GetActiveWindow = FEditForm.Handle then
        if FResizerList.Count = 0 then
          Handled := True;
    end;
  end
end;

procedure TgsResizeManager.SetManagerState(
  const AManagerState: TManagerState);
begin
  if FManagerState <> AManagerState then
    FManagerState := AManagerState;
end;


procedure TgsResizeManager.InsertNewControl(const P: TPoint);
var
  C: TPersistentClass;
  AControl: TControl;
  AComponent: TComponent;
  ParentControl: TControl;
  PN: TPoint;
  T: TgsComponentEmulator;
  L: Longint;
  i: integer;
begin

  C := FPaletteForm.NewControlClass;
  FPaletteForm.BreakState;

  if Assigned(C) then
  begin
    if C.InheritsFrom(TControl) then
    begin
      AControl := CControl(C).Create(FEditForm);
      AControl.Name :=  GetNewControlName(AControl.ClassName);
      PN := FEditForm.ClientToScreen(P);
      ParentControl := ControlAtPos(FEditForm, PN);

      if not assigned(ParentControl) then
      begin
        AControl.Free;
        Exit;
      end;

      while ParentControl.name = '' do
        ParentControl := ParentControl.Parent;

      if ParentControl is TgsComponentEmulator then
        ParentControl := FEditForm;

      while (ParentControl is TFrame) or (ParentControl.Owner is TFrame)do
        ParentControl := ParentControl.Parent;

      TComponentCracker(AControl).SetDesigning(True, False);
      if not (((ParentControl.InheritsFrom(TWinControl)) and  (not (ParentControl is TgsResizer))
        and (csAcceptsControls in ParentControl.ControlStyle))) then
      begin
        ParentControl := ParentControl.Parent;
      end;

      if (ParentControl is TgsResizer) then
      begin
        if (TgsResizer(ParentControl).FMovedControl is TWinControl) and
           (csAcceptsControls in TgsResizer(ParentControl).FMovedControl.ControlStyle) then
          ParentControl := TgsResizer(ParentControl).FMovedControl
        else
          ParentControl := TgsResizer(ParentControl).FMovedControl.Parent;
      end;

      if FCut then begin
        for i:= 0 to FResizerList.Count - 1 do
          if ParentControl = TgsResizer(FResizerList[i]).FMovedControl then begin
            ParentControl:= TgsResizer(FResizerList[i]).FMovedControl.Parent;
            Break;
          end;
      end;

      PN := ParentControl.ScreenToClient(PN);

      AControl.Left := PN.X;
      AControl.Top := PN.Y;
      AControl.Parent := TWinControl(ParentControl);
      FObjectInspectorForm.RefreshList;
      try
        AddResizer(AControl, False);
      except
      end;
      if Assigned(EventControl) then
        EventControl.PropertyNotification(AControl, poInsert)
    end
    else
    begin
      AComponent := CComponent(C).Create(FEditForm);
      AComponent.Name :=  GetNewControlName(AComponent.ClassName);
      TComponentCracker(AComponent).SetDesigning(True, False);
      LongRec(L).Hi := P.Y;
      LongRec(L).Lo := P.X;;
      AComponent.DesignInfo := L;
      T := TgsComponentEmulator.Create(FEditForm, AComponent);
      try
        T.Name := GetNewControlName(T.ClassName);
        T.Caption := '';
        FEmulatorsList.Add(T);
        if FEditForm.ClientHeight < T.Top then
          T.Top := 0;
        if FEditForm.ClientWidth < T.Left then
          T.Top := 0;

      except
        T.Free;
      end;
      FObjectInspectorForm.RefreshList;
      try
        AddResizer(T, False);
      except
      end;
      if Assigned(EventControl) then
        EventControl.PropertyNotification(AComponent, poInsert)
    end;
  end;
end;

function TgsResizeManager.GetNewControlName(AClassName: String): String;

  procedure GetComponentName(Control: TWinControl; var Count: Integer; const Prefix: String);
  var
    J: Integer;
  begin
    for J := 0 to Control.ComponentCount - 1 do
    begin
      if UpperCase(Control.Components[J].Name) = UpperCase(Prefix + IntToStr(Count)) then
      begin
        Inc(Count);
        GetComponentName(Control, Count, Prefix);
        Exit;
      end;
    end;
  end;
var
  Count: Integer;
begin
  if FDesignerType = dtGlobal then
    Result := GLOBALUSERCOMPONENT_PREFIX
  else if FDesignerType = dtUser then
    Result := USERCOMPONENT_PREFIX;

  Result := Result + Copy(AClassName, 2, Length(AClassName));
  if FDesignerType = dtUser then
    Result := Result + '_' + IBLogin.UserName;

  Count := 1;
  GetComponentName(FEditForm, Count, Result);
  Result := Result + IntToStr(Count);

end;

procedure TgsResizeManager.SetShortCut(const Value: TShortCut);
begin
  if Value <> FShortCut then
  begin
    FShortCut := Value;
    if Assigned(FStartAction) then
      FStartAction.ShortCut := FShortCut;
  end;
end;


procedure TgsResizeManager.OnStartAction(Sender: TObject);
begin
//  if not FEnabled then
    Enabled := True;
end;

// old version for saving to the File
{procedure TgsResizeManager.ExitAndLoadDefault;
begin
  Enabled := False;
  if FileExists(FResourceName) then
    DeleteFile(FResourceName);
end;}

procedure TgsResizeManager.ExitAndLoadDefault;
var
  F: TgsStorageFolder;
begin
  if not DoBeforeExit then
    Exit;

  if MessageBox(0,
    PChar('Вы уверены, что хотите выйти и удалить все настройки?'#13#10 +
    'Это может привести к неработоспособности пользовательских событий и макросов.'),
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_TOPMOST) = IDNO then
  begin
    exit;
  end;

  RestoreChangedComponents;

  Enabled := False;
  if Assigned(UserStorage) and Assigned(GlobalStorage) then
  begin
    case FDesignerType of
      dtUser: F := UserStorage.OpenFolder(FResourceName, False);
      dtGlobal: F := GlobalStorage.OpenFolder(FResourceName, False);
      else
        F := nil;
    end;

    if Assigned (F) then
    begin
      try
        F.DeleteValue(FFormSubType);
      finally
        case FDesignerType of
          dtUser: UserStorage.CloseFolder(F);
          dtGlobal: GlobalStorage.CloseFolder(F);
        end;
      end;
    end
  end;
  DoAfterExit;
end;

procedure TgsResizeManager.ExitWithoutSaving;
begin
  RestoreChangedComponents;
  if not FEnabled then
    Exit;
  if not FFormRecreate then
  begin
    if not DoBeforeExit then
      Exit;
    Enabled := False;
    DoAfterExit;
  end;
end;

procedure TgsResizeManager.SaveAndExit;
var
  F: TMemoryStream;
  OldActive: TWinControl;
  OldVisible: Boolean;
  Writer: TDesignWriter;
  S: String;
  MacroFlag: Boolean;
  EvtObj, EO: TEventObject;
  EvtCtrl: TEventControl;
  EvtItem: TEventItem;
  i, iID, iTmp: integer;
  Comp: TComponent;
  q: TIBSQL;
  tr: TIBTransaction;
  gdcEvt: TgdcEvent;
  gdcDO: TgdcDelphiObject;
  St: TgsIBStorage;
begin
  if not DoBeforeExit(True) then
    Exit;

  Enabled := False;

  EvtCtrl:= nil;
  if Assigned(EventControl) then
    EvtCtrl:= EventControl.Get_Self as TEventControl;

  F := TMemoryStream.Create;
  try
    if Assigned(UserStorage) and Assigned(GlobalStorage) then
    begin
      MacroFlag := UnEventMacro;
      UnEventMacro := True;

      if (FChangedNames.Count > 0) and Assigned(EventControl) then begin
        q:= TIBSQL.Create(self);
        tr:= TIBTransaction.Create(self);
        try
          tr.DefaultDatabase:= dmDatabase.ibdbGAdmin;
          tr.StartTransaction;
          q.Transaction:= tr;
          q.SQL.Text:= 'UPDATE evt_object SET name=:name, objectname=:objname WHERE id=:objkey';
          for i:= FChangedNames.Count - 1 downto 0 do begin
            try
              Comp:= FEditForm.FindComponent(FChangedNames.Values[FChangedNames.Names[i]]);
              EvtObj:= EvtCtrl.FindRealEventObject(Comp, FChangedNames.Names[i]);
              if Assigned(EvtObj) then begin
                EvtObj.ObjectName:= FChangedNames.Values[FChangedNames.Names[i]];
                q.Close;
                q.ParamByName('name').AsString:= EvtObj.ObjectName;
                q.ParamByName('objname').AsString:= EvtObj.ObjectName;
                q.ParamByName('objkey').AsInteger:= EvtObj.ObjectKey;
                q.ExecQuery;
              end;
            finally
              FChangedNames.Delete(i);
            end;
          end;
          tr.Commit;
        finally
          tr.Free;
          q.Free;
        end;
      end;

      if FDeletedComponents.Count > 0 then begin
        gdcEvt:= TgdcEvent.Create(self);
        gdcDO:= TgdcDelphiObject.Create(self);
        try
          gdcEvt.SubSet:= cByObjectKey;
          gdcDO.SubSet:= ssByID;
          for i:= FDeletedComponents.Count - 1 downto 0 do begin
            try
              gdcEvt.ParamByName(fnObjectKey).AsInteger:= StrToInt(FDeletedComponents[i]);
              gdcEvt.Open;
              gdcEvt.First;
              while not gdcEvt.Eof do begin
                gdcEvt.Delete;
              end;
              gdcEvt.Close;

              gdcDO.CLose;
              gdcDO.ID:= StrToInt(FDeletedComponents[i]);
              gdcDO.Open;
              if not gdcDO.Eof then
                gdcDO.Delete;
            finally
              FDeletedComponents.Delete(i);
            end;
          end;
        finally
          gdcEvt.Free;
          gdcDO.Free
        end;
      end;

      OldActive := FEditForm.ActiveControl;
      FEditForm.ActiveControl := nil;
      OldVisible := FEditForm.Visible;
      FEditForm.Visible := False;

      try
        if (cfsUserCreated in TCreateableForm(FEditForm).CreateableFormState) and
          Assigned(EventControl) then
            EventControl.ResetEvents(FEditForm);
        if Assigned(EvtCtrl) then begin
          for i:= FDelphiEventList.Count - 1 downto 0 do begin
            EvtObj:= EvtCtrl.FindRealEventObject(FDelphiEventList[i].Comp);
            try
              if Assigned(EvtObj) then begin
                EvtItem:= EvtObj.EventList.Find(FDelphiEventList[i].PropInfo^.name);
                if Assigned(EvtItem) and (EvtItem.OldEvent.Code <> FDelphiEventList[i].Method.Code) then begin
                  EvtItem.OldEvent:= FDelphiEventList[i].Method;
                end;
              end;
            finally
              FDelphiEventList.Delete(i);
            end;
          end;

          for i:= FChangedEventList.Count - 1 downto 0 do begin
            if FChangedEventList[i].NewFunctionID = -1 then begin
              EventControl.DeleteEvent(FEditForm.Name, FChangedEventList[i].Comp.Name,
                FChangedEventList[i].EventName);
            end
            else begin
              EvtObj:= EvtCtrl.FindRealEventObject(FChangedEventList[i].Comp);
              gdcEvt:= TgdcEvent.Create(self);
              iID:= -1;
              try
                gdcEvt.SubSet:= cByObjectKey;
                if not Assigned(EvtObj) then begin
                  gdcDO:= TgdcDelphiObject.Create(self);
                  try
                    if Assigned(FChangedEventList[i].Comp.Owner) then
                      EvtObj:= EvtCtrl.FindRealEventObject(FChangedEventList[i].Comp.Owner);
                    if Assigned(EvtObj) then begin
                      gdcDO.SubSet:= ssByID;
                      gdcDO.Open;
                      gdcDO.Insert;
                      gdcDO.FieldByName(fnParent).AsInteger:= EvtObj.ObjectKey;
                      gdcDO.FieldByName(fnName).AsString:= FChangedEventList[i].Comp.Name;
                      gdcDO.FieldByName(fnObjectName).AsString:= FChangedEventList[i].Comp.Name;
                      gdcDO.Post;
                      iID:= gdcDO.ID;
                      EO:= TEventObject.Create;
                      EvtObj.ChildObjects.Add(EO);
                      EO.ObjectName:= FChangedEventList[i].Comp.Name;
                      EO.ObjectKey:= iID;
                    end;
                  finally
                    gdcDO.Free;
                  end;
                end;
                EvtObj:= EvtCtrl.FindRealEventObject(FChangedEventList[i].Comp);
                if Assigned(EvtObj) then begin
                  if EvtObj.ObjectKey > 0 then
                    iID:= EvtObj.ObjectKey;
                  EvtItem:= EvtObj.EventList.Find(FChangedEventList[i].EventName);
                  if Assigned(EvtItem) then
                    EvtItem.FunctionKey:= FChangedEventList[i].NewFunctionID
                  else begin
                    iTmp:= EvtObj.EventList.Add(FChangedEventList[i].EventName, FChangedEventList[i].NewFunctionID);
                    EvtItem:= EvtObj.EventList[iTmp];
                    EvtItem.EventData := GetTypeData(GetPropInfo(FChangedEventList[i].Comp,
                      FChangedEventList[i].EventName)^.PropType^);
                  end;
                end;
                if iID > 0 then begin
                  gdcEvt.ParamByName(fnObjectKey).AsInteger:= iID;
                  gdcEvt.Open;
                  if gdcEvt.Locate(fnEventName, AnsiUpperCase(FChangedEventList[i].EventName), []) then
                    gdcEvt.Edit
                  else begin
                    gdcEvt.Insert;
                    gdcEvt.FieldByName(fnObjectKey).AsInteger:= iID;
                    gdcEvt.FieldByName(fnEventName).AsString:= AnsiUpperCase(FChangedEventList[i].EventName);
                  end;
                  gdcEvt.FieldByName(fnFunctionKey).AsInteger:= FChangedEventList[i].NewFunctionID;
                  gdcEvt.Post;
                end;
              finally
                gdcEvt.Free;
                FChangedEventList.Delete(i);
              end;
            end;
          end;
        end;

        Writer := TDesignWriter.Create(F, 4096);
        try
          Writer.Designer := Self;
          Writer.WriteDescendent(FEditForm, nil);
        finally
          Writer.Free;
        end;
      finally
        try
          FEditForm.ActiveControl := OldActive;
        except
        end;

        FEditForm.Visible := OldVisible;

        UnEventMacro := MacroFlag;
        if (cfsUserCreated in TCreateableForm(FEditForm).CreateableFormState) and
          Assigned(EventControl) and
          (not (cfsCloseAfterDesign in TCreateableForm(FEditForm).CreateableFormState)) then
            EventControl.RebootEvents(FEditForm);

      end;

      St := GlobalStorage;
      F.Seek(0, soFromBeginning);
      if cfsUserCreated in TCreateableForm(FEditForm).CreateableFormState then
      begin
        S := TCreateableForm(FEditForm).InitialName;

        GlobalStorage.WriteStream(st_ds_NewFormPath + '\' + S, st_ds_UserFormDFM, F);
        GlobalStorage.WriteString(st_ds_NewFormPath + '\' + S, st_ds_FormClass, FEditForm.ClassName);
        if not SameText(FEditForm.ClassName, 'TgdcCreateableForm') then
        begin
          GlobalStorage.WriteInteger(st_ds_NewFormPath + '\' + S, st_ds_InternalType, st_ds_GDCForm);
          if Assigned(TgdcCreateableForm(FEditForm).gdcObject) then
            GlobalStorage.WriteString(st_ds_NewFormPath + '\' + S, st_ds_FormGDCObjectClass, TgdcCreateableForm(FEditForm).gdcObject.ClassName);
          GlobalStorage.WriteString(st_ds_NewFormPath + '\' + S, st_ds_FormGDCSubtype, TgdcCreateableForm(FEditForm).SubType);
        end
        else
          GlobalStorage.WriteInteger(st_ds_NewFormPath + '\' + S, st_ds_InternalType, st_ds_SimplyForm);
      end
      else begin
        if FDesignerType <> dtGlobal then
          St := UserStorage;

        St.WriteStream(FResourceName, FFormSubtype, F);
      end;
      St.SaveToDatabase;
    end;
  finally
    F.Free;
  end;
  DoAfterExit;
end;

procedure TgsResizeManager.EventFunctionChanged(AComp: TComponent;
  AEvent: string; ANewID: integer; AName: string);
var
  iIndex: integer;
begin
  iIndex:= FChangedEventList.FindByCompAndEvent(AComp, AEvent);
  if iIndex > -1 then
    TChangedEvent(FChangedEventList[iIndex]).NewFunctionID:= ANewID
  else
    FChangedEventList.Add(AComp, AEvent, ANewID, AName);
end;

(*procedure TgsResizeManager.SetDefaultValues(AComponent: TComponent);
var
  PropList: PPropList;
  ClassTypeInfo: PTypeInfo;
  ClassTypeData: PTypeData;
  i: integer;
  NumProps: Integer;
const
  OrdinalTypes = [tkInteger, tkChar, tkEnumeration, tkWChar];
  //
   {tkFloat, tkString, tkSet, tkClass, tkMethod, tkLString, tkWString,
   tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray}

begin
  ////////////////////////
  // Устанавливаем значения по умолчанию для полей
  // типа OrdinalTypes

  ClassTypeInfo := AComponent.ClassInfo;
  ClassTypeData := GetTypeData(ClassTypeInfo);

  if ClassTypeData.PropCount <> 0 then
  begin
    // allocate the memory needed to hold the references to the TPropInfo
    // structures on the number of properties.
    GetMem(PropList, SizeOf(PPropInfo) * ClassTypeData.PropCount);
    try
      NumProps := GetPropList(AComponent.ClassInfo, OrdinalTypes, PropList);
      // Fill the AStrings with the events.
      for i := 0 to NumProps - 1 do
      begin
        if (PropList[I]^.Name = 'Align') or (PropList[I]^.Name = 'Left') or
           (PropList[I]^.Name = 'Top') or (PropList[I]^.Name = 'Width') or
           (PropList[I]^.Name = 'Height') or (PropList[I]^.Name = 'PageIndex') then
          Continue;
        if PropList[I]^.Default = Low(PropList[i]^.Default) then
          SetPropertyValue(AComponent, PropList[i]^.Name, '0')
        else
          SetPropertyValue(AComponent, PropList[i]^.Name, IntToStr(PropList[i]^.Default));
      end;
  //          AStrings.Add(Format('%s: %s', [, PropList[i]^.PropType^.Name]));

    finally
      FreeMem(PropList, SizeOf(PPropInfo) * ClassTypeData.PropCount);
    end;
  end;
end;
  *)


function TgsResizeManager.GetEditForm: TForm;
begin
  Result := FEditForm;
end;


procedure TgsResizeManager.PageControl(Sender: TObject);
var
  TS : TTabSheet;
  PC: TPageControl;
begin
  PC := nil;
  if FParentControl is TPageControl then
    PC := TPageControl(FParentControl)
  else if FParentControl is TTabSheet then
    PC := TTabSheet(FParentControl).PageControl;

  if Assigned(PC) then
  begin
    if Sender = FAddNewPage then
    begin
      FPaletteForm.BreakState;
      TS := TTabSheet.Create(FEditForm);
      TS.Name := GetNewControlName(TS.ClassName);
      TS.PageControl := PC;
      FObjectInspectorForm.RefreshList;
    end else if Sender = FDeletePage then
    begin
      PC.ActivePage.Free;
      FObjectInspectorForm.RefreshList;
    end
    else if Sender = FNextPage then
    begin
      TS := PC.FindNextPage(PC.ActivePage, True, False);
      PC.ActivePage := TS;
    end
    else if Sender = FPrevPage then
    begin
      TS := PC.FindNextPage(PC.ActivePage, False, False);
      PC.ActivePage := TS;
    end;
  end;
end;

procedure TgsResizeManager.DeleteControls;
  function CanDelete(AControl: TControl): Boolean;
  var
    I: Integer;
  begin
    if (Pos(USERCOMPONENT_PREFIX, AControl.Name) = 1) or
        ((FDesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, AControl.Name) = 1)) then
      Result := True
    else
      Result := False;

    if Result and (AControl is TWinControl) then
    begin
      for I := 0 to TWinControl(AControl).ControlCount - 1 do
      begin
        if TWinControl(AControl).Controls[I].Name > '' then
          Result := CanDelete(TWinControl(AControl).Controls[I])
        else
          Result := True;
        if not Result then
          Exit;
      end;
    end;
  end;
var
  I, j: Integer;
  WasDeleted: Boolean;
  EvtObj: TEventObject;
  sName: string;
begin
  WasDeleted := False;
  for I := FResizerList.Count - 1 downto 0 do
  begin
    if Resizers[I].FCut then
      FResizerList.Delete(I);
  end;
  FCut := False;
  for I := FResizerList.Count - 1 downto 0 do
  begin
    if (Resizers[I].MovedControl is TgsComponentEmulator) then
    begin
      if (Pos(USERCOMPONENT_PREFIX, TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent.Name) = 1) or
         ((FDesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent.Name) = 1)) then
      begin
        for j:= FChangedEventList.Count - 1 downto 0 do begin
          if FChangedEventList[j].Comp = TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent then
            FChangedEventList.Delete(j);
        end;
        if Assigned(EventControl) then
          EventControl.PropertyNotification(TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent, poRemove);
        sName:= GetControlOldName(TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent.Name);
        EvtObj:= TEventControl(EventControl.Get_self).FindRealEventObject(TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent, sName);
        if Assigned(EvtObj) then
          FDeletedComponents.Add(IntToStr(EvtObj.ObjectKey));
        TgsComponentEmulator(Resizers[I].MovedControl).RelatedComponent.Free;
        FEmulatorsList.Delete(FEmulatorsList.IndexOf(Resizers[I].MovedControl));
        FResizerList.Delete(I);
        WasDeleted:= True;
      end;
      Continue;
    end;

    if CanDelete(Resizers[I].MovedControl) then
    begin
      for j:= FChangedEventList.Count - 1 downto 0 do begin
        if FChangedEventList[j].Comp = Resizers[I].MovedControl then
          FChangedEventList.Delete(j);
      end;
      if Assigned(EventControl) then begin
        EventControl.PropertyNotification(Resizers[I].MovedControl, poRemove);
        sName:= GetControlOldName(Resizers[I].MovedControl.Name);
        EvtObj:= TEventControl(EventControl.Get_self).FindRealEventObject(Resizers[I].MovedControl, sName);
        if Assigned(EvtObj) then
          FDeletedComponents.Add(IntToStr(EvtObj.ObjectKey));
      end;
      Resizers[I].MovedControl.Free;
      FResizerList.Delete(I);
        WasDeleted := True;
    end;
  end;

  if WasDeleted then
  begin
    FObjectInspectorForm.RefreshList;
    FObjectInspectorForm.AddEditComponent(FEditForm, False);
  end;
end;

function TgsResizeManager.GetInvisibleList: TControlList;
begin
  Result := FInvisibleList;
end;

function TgsResizeManager.GetInvisibleTabsList: TControlList;
begin
  Result := FInvisibleTabsList;
end;

procedure TgsResizeManager.CheckPosition(AnOwner: TComponent;
  Stream: TStream; const Attr: Boolean);
var
  Reader: TDesignReader;
begin

  Reader := TDesignReader.Create(Stream, 4096);
  try
    Reader.Designer := Self;
    Reader.Attributes := Attr;
    Reader.ProcessComponents(AnOwner, FFormSubType);
  finally
    Reader.Free;
  end;
end;

{ TgsReader }


function TgsResizeManager.GetShortCut: TShortCut;
begin
  Result := FShortCut;
end;

procedure TgsResizeManager.FreeResizer;
begin
  Free;
end;

procedure TgsResizeManager.DisableEvents(AnOwner: TComponent);
var
  I, J: Integer;
  TypeData: PTypeData;
  TypeInfo: PTypeInfo;
  PropList: PPropList;
  NumProps: Integer;
  M: TMethod;
  CurrComponent: TComponent;
  EvtObj: TEventObject;
  EvtCtrl: TEventControl;
  EvtItem: TEventItem;
begin
  Assert(Assigned(EventControl));
  Assert(FEventList.Count = 0);
  Assert(FEventActionList.Count = 0);
  EvtCtrl:= EventControl.Get_Self as TEventControl;
  if FDelphiEventList.Count > 0 then
    FDelphiEventList.Clear;
  if FChangedEventList.Count > 0 then
    FChangedEventList.Clear;
  if FChangedNames.Count > 0 then
    FChangedNames.Clear;
  if FDeletedComponents.Count > 0 then
    FDeletedComponents.Clear;

  I := -1;
  repeat
    if I = -1 then
      CurrComponent := AnOwner
    else
      CurrComponent := AnOwner.Components[I];
    if (not CurrComponent.InheritsFrom(TgsResizer)) and
       (not CurrComponent.InheritsFrom(TgsResizeManager)) and
       (not CurrComponent.InheritsFrom(TBasicAction)) then
    begin
      TypeInfo := CurrComponent.ClassInfo;
      TypeData := GetTypeData(TypeInfo);
      GetMem(PropList, SizeOf(PPropInfo) * TypeData.PropCount);
      try
        NumProps := GetPropList(TypeInfo, [tkMethod], PropList);
        if NumProps > 0 then
        begin
          for J := 0 to NumProps - 1 do
          begin

            if Assigned(EvtCtrl) then begin
              EvtObj:= EvtCtrl.EventObjectList.FindAllObject(CurrComponent);
              if Assigned(EvtObj) then begin
                EvtItem:= EvtObj.EventList.Find(PropList[J].Name);
                if Assigned(EvtItem) and ((EvtItem.OldEvent.Code <> nil) and (EvtItem.OldEvent.Data <> nil)) then begin
                  FDelphiEventList.Add(CurrComponent, PropList[J], EvtItem.OldEvent);
                end;
              end;
            end;

            M := GetMethodProp(CurrComponent, PropList[J]);
            if (M.Code <> nil) and (M.Data <> nil) then
            begin
              FEventList.Add(CurrComponent, PropList[J], M);
              M.Code := nil;
              M.Data := nil;
              SetMethodProp(CurrComponent, PropList[J], M);
            end;
          end;
        end;
      finally
        FreeMem(PropList, SizeOf(PPropInfo) * TypeData.PropCount);
      end;
    end;
    Inc(I);
  until AnOwner.ComponentCount = I;

  I := -1;
  repeat
    if I = -1 then
      CurrComponent := AnOwner
    else
      CurrComponent := AnOwner.Components[I];
    if CurrComponent.InheritsFrom(TBasicAction) then
    begin
      TypeInfo := CurrComponent.ClassInfo;
      TypeData := GetTypeData(TypeInfo);
      GetMem(PropList, SizeOf(PPropInfo) * TypeData.PropCount);
      try
        NumProps := GetPropList(TypeInfo, [tkMethod], PropList);
        if NumProps > 0 then
        begin
          for J := 0 to NumProps - 1 do
          begin

            if Assigned(EvtCtrl) then begin
              EvtObj:= EvtCtrl.EventObjectList.FindAllObject(CurrComponent);
              if Assigned(EvtObj) then begin
                EvtItem:= EvtObj.EventList.Find(PropList[J].Name);
                if Assigned(EvtItem) and ((EvtItem.OldEvent.Code <> nil) and (EvtItem.OldEvent.Data <> nil)) then begin
                  FDelphiEventList.Add(CurrComponent, PropList[J], EvtItem.OldEvent);
                end;
              end;
            end;

            if PropList[J]^.Name <> 'OnExecute' then
            begin
              M := GetMethodProp(CurrComponent, PropList[J]);
              if (M.Code <> nil) and (M.Data <> nil) then
              begin
                FEventActionList.Add(CurrComponent, PropList[J], M);
                M.Code := nil;
                M.Data := nil;
                SetMethodProp(CurrComponent, PropList[J], M);
              end;
            end;
          end;
        end;
      finally
        FreeMem(PropList, SizeOf(PPropInfo) * TypeData.PropCount);
      end;
    end;
    Inc(I);
  until AnOwner.ComponentCount = I;
end;

procedure TgsResizeManager.EnableEvents;
var
  I: Integer;
begin
  for I := FEventActionList.Count - 1 downto 0 do
  begin
    SetMethodProp(FEventActionList[I].Comp, FEventActionList[I].PropInfo, FEventActionList[I].Method);
    FEventActionList.Delete(I);
  end;
  for I := FEventList.Count - 1 downto 0 do
  begin
    SetMethodProp(FEventList[I].Comp, FEventList[I].PropInfo, FEventList[I].Method);
    FEventList.Delete(I);
  end;
end;

procedure TgsResizeManager.ReloadComponent(const Attr: Boolean);
var
  F: TMemoryStream;
  OldVisible, bLoadedFromStorage: Boolean;
  OldControl: TWinControl;
  Flag: Integer;
  SF: TgsStorageFolder;
  H: THandle;

const
  ErrorMsg =
    'При загрузке настроек произошла ошибка: %s'#10#13 +
    'Хотите удалить настройки?';

begin
  H := GETDC(FEditForm.Handle);
  try
    Flag := 0;
    FGlobalLoading := False;
    F := TMemoryStream.Create;
    try
      try
        TCreateableForm(FEditForm).CreateableFormState :=
          TCreateableForm(FEditForm).CreateableFormState + [cfsLoading];
        try
          if Assigned(UserStorage) and Assigned(GlobalStorage) then
          begin
            bLoadedFromStorage:= GlobalStorage.ReadStream(FResourceName, FFormSubType, F, IBLogin.IsIBUserAdmin);
            if not bLoadedFromStorage then
              bLoadedFromStorage:= GlobalStorage.ReadStream(FResourceName, SubtypeDefaultName, F, IBLogin.IsIBUserAdmin);
            if bLoadedFromStorage then
            begin
              Flag := 1;
              FGlobalLoading := True;
            end;

            if (FDesignerType = dtUser) and (Flag = 0) then
            begin
              if UserStorage.ReadStream(FResourceName, FFormSubType, F) then
                Flag := 2;
            end;

            if Flag <> 0 then
            begin
              F.Seek(0, soFromBeginning);
              DisableEvents(FEditForm);
              try
                OldVisible := FEditForm.Visible;
                OldControl := FEditForm.ActiveControl;
                try
                  CheckPosition(FEditForm, F, Attr);

                  FGlobalLoading := False;


                  if (FDesignerType = dtUser) and (Flag = 1) then
                  begin
                    Flag := 0;
                    F.Clear;
                    if UserStorage.ReadStream(FResourceName, FFormSubType, F) then
                    begin
                      F.Seek(0, soFromBeginning);
                      CheckPosition(FEditForm, F, Attr);
                    end;
                  end
                finally
                  FEditForm.Visible := OldVisible;
                  try
                    FEditForm.ActiveControl := OldControl;
                    if OldVisible then
                    begin
                      if Assigned(FEditForm.ActiveControl) then
                        FEditForm.ActiveControl.SetFocus;
                    end;
                  except
                  end;
               end;
              finally
                EnableEvents;
              end;
            end;
          end;
        finally
          TCreateableForm(FEditForm).CreateableFormState :=
            TCreateableForm(FEditForm).CreateableFormState - [cfsLoading];
        end;
      except
        on E: Exception do
        begin
  //        if IBLogin.IsUserAdmin
  //          and IBLogin.Database.Connected
  //          and (MessageDlg('При загрузке настроек произошла ошибка: ' + E.Message + #10#13 +  'Хотите удалить настройки?',
  //                    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
          if IBLogin.IsUserAdmin
            and IBLogin.Database.Connected
            and (MessageBox(0,
              PChar(Format(ErrorMsg, [E.Message])),
              'Внимание',
              MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2 or MB_TASKMODAL) = IDYES) then
          begin
            if Assigned(UserStorage) and Assigned(GlobalStorage) then
            begin
              if (Flag = 0) or (Flag = 2) then
                SF := UserStorage.OpenFolder(FResourceName, False)
              else
                SF := GlobalStorage.OpenFolder(FResourceName, IBLogin.IsIBUserAdmin);
              try
                SF.DeleteValue(FFormSubType);
              finally
                if (Flag = 0) or (Flag = 2) then
                  UserStorage.CloseFolder(SF)
                else
                  GlobalStorage.CloseFolder(SF);
              end;
            end;
          end;
        end;
      end;
    finally
      F.Free;
    end;
  finally
    ReleaseDC(FEditForm.Handle, H);
  end;
end;

function TgsResizeManager.DoBeforeExit(const SaveState: Boolean = False): Boolean;
begin
//  Result := False;

//  if Assigned(EventControl) and (EventControl.PropertyIsLoaded) and
//    FEnabled then
//  begin
//    if not EventControl.PropertyClose then
//      Exit;
//  end;
  if Assigned(FHintTimer) then
    FHintTimer.Enabled := False;
  if Assigned(FHintWindow) then
    FHintWindow.ReleaseHandle;
  if Assigned(EventControl) then
  begin
    if SaveState then
      EventControl.PropertyNotification(nil, poPost)
    else
      EventControl.PropertyNotification(nil, poCancel);
  end;
  Result := True;
end;


function TgsResizeManager.AddComponent(AComponent: TComponent): TControl;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FEmulatorsList.Count - 1 do
  begin
    if TgsComponentEmulator(FEmulatorsList[I]).RelatedComponent = AComponent then
    begin
      if AddResizer(TgsComponentEmulator(FEmulatorsList[I]), False) then
        Result := TgsComponentEmulator(FEmulatorsList[I]);
      Break;
    end;
  end
end;

function TgsResizeManager.SetPropertyValue(AComponent: TObject;
  const PropertyName, PropertyValue: String): String;
  procedure SetIntIdent(Instance: TObject; PropInfo: Pointer;
    const Ident: string);
  var
    V: Longint;
    IdentToInt: TIdentToInt;
  begin
    IdentToInt := FindIdentToInt(PPropInfo(PropInfo)^.PropType^);
    if Assigned(IdentToInt) and IdentToInt(Ident, V) then
      SetOrdProp(Instance, PropInfo, V)
  end;

  function RangedValue(const AValue, AMin, AMax: Int64): Int64;
  begin
    Result := AValue;

    if Result < AMin then
      Result := AMin
    else if AMax < AMin then
    begin
      if Cardinal(Result) > Cardinal(AMax) then
        Result := Cardinal(AMax)
    end
    else if Result > AMax then
        Result := AMax;


  end;


var
  PropInfo: PPropInfo;
  TypeData: PTypeData;

  Code: Integer;
  IntValue: Int64;
  O: TObject;

  Instance: TObject;
  PropName: String;
  PropValue: String;
  SelfClass: TClass;

  procedure ProcessPropertyName;
  var
    I: Integer;
    S: String;
    O: TObject;
  begin
    I := Pos('.', PropName);
    while I > 0 do
    begin
      S := Copy(PropName, 1, I - 1);
      PropName := Copy(PropName, I + 1, Length(PropName));

      PropInfo := GetPropInfo(Instance.ClassInfo, S);
      TypeData := GetTypeData(PropInfo^.PropType^);
      SelfClass := TypeData.ClassType;

      O := GetObjectProp(Instance, PropInfo);
      Instance := O;
      I := Pos('.', PropName);
    end;
  end;

begin
  try
    Result := '';
    Instance := AComponent;
    SelfClass := Instance.ClassType;

    if cNameWithoutPrefix = PropertyName then
    begin
      PropName := 'Name';
      PropValue := GLOBALUSERCOMPONENT_PREFIX + PropertyValue;
    end else
      begin
        PropName := PropertyName;
        PropValue := PropertyValue;
      end;

    ProcessPropertyName;

    if Instance = nil then
      Exit;

    if Instance.InheritsFrom(TStrings) and (PropName = 'Strings') then
    begin
      TStrings(Instance).Text := PropValue;
      Exit;
    end;
    PropInfo := GetPropInfo(SelfClass, PropName);

    if (PropInfo = nil) or (PropInfo^.SetProc = nil) then
      Exit;
    TypeData := GetTypeData(PropInfo^.PropType^);

    if PropInfo <> nil then
    begin
      case PropInfo^.PropType^.Kind of
        tkInteger:
          begin
            try
              IntValue := StrToInt64(PropValue);
              SetOrdProp(Instance, PropInfo, RangedValue(IntValue, TypeData^.MinValue, TypeData^.MaxValue));
            except
              SetIntIdent(Instance, PropInfo, PropValue)
            end
          end;
        tkFloat:
          SetFloatProp(Instance, PropInfo, StrToFloat(PropValue));
//        tkChar, tkWChar:;

        tkString, tkLString, tkWString:
          SetStrProp(Instance, PropInfo, PropValue);
        tkVariant:
          SetVariantProp(Instance, PropInfo, PropValue);
        tkInt64:
          SetInt64Prop(Instance, PropInfo, RangedValue(StrToInt64(PropValue), TypeData^.MinValue, TypeData^.MaxValue));
        tkEnumeration:  //Boolean
          begin
            Val(PropValue, IntValue, Code);
            if Code <> 0 then
              SetEnumProp(Instance, PropInfo, PropValue)
            else
              SetOrdProp(Instance, PropInfo, RangedValue(IntValue, TypeData^.MinValue, TypeData^.MaxValue));
          end;
        tkSet:
          begin
            Val(PropValue, IntValue, Code);
            if Code <> 0 then
              SetSetProp(Instance, PropInfo, PropValue)
            else
              SetOrdProp(Instance, PropInfo, RangedValue(IntValue, TypeData^.MinValue, TypeData^.MaxValue));
          end;
        tkClass:
          begin
            if PropValue <> '' then
            begin
              O := GlobalFindComponent(PropValue, FEditForm);
              if O <> nil then
                SetObjectProp(Instance, PropInfo, O)
              else
                Result := Format('Объект "%s" не доступен.', [PropValue]);
            end
            else
              SetObjectProp(Instance, PropInfo, nil);
          end;
        tkUnknown, tkMethod, tkArray, tkRecord,
        tkInterface, tkDynArray:;
      end;
    end;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function TgsResizeManager.GetChangedPropList: TChangedPropList;
begin
  Result := FChangedPropList;
end;

function TgsResizeManager.GetChangedEventList: TChangedEventList;
begin
  Result := FChangedEventList;
end;

procedure TgsResizeManager.Reset;
var
  I: Integer;
begin
  for I := 0 to FResizerList.Count - 1 do
    Resizers[I].Reset;
end;

procedure TgsResizeManager.ControlResize(Sender: TObject);
var
  I: Integer;
begin
//  FEditForm.Repaint;
  for I := 0 to FResizerList.Count - 1 do
    Resizers[I].DoResize(Resizers[I].MovedControl);
end;

function TgsResizeManager.GetOnActivate: TOnResiserActivate;
begin
  Result := FOnActivate;
end;

procedure TgsResizeManager.SetOnActivate(const Value: TOnResiserActivate);
begin
  FonActivate := Value;
end;

procedure TgsResizeManager.AddNonVisibleComponent(AComponent: TComponent;
  const AShiftState: Boolean);
begin
  try
    FObjectInspectorForm.AddEditComponent(AComponent, AShiftState);
  except
  end;
end;

procedure TgsResizeManager.RefreshList;
begin
  FObjectInspectorForm.RefreshList;
end;

function TgsResizeManager.GetDesignerType: TDesignerType;
begin
  Result := FDesignerType;
end;

procedure TgsResizeManager.DoAfterExit;
begin
  if cfsCloseAfterDesign in TCreateableForm(FEditForm).CreateableFormState then
    FEditForm.Release;
end;

procedure TgsResizeManager.DeleteControl(Sender: TObject);
begin
  DeleteControls;
end;

procedure TgsResizeManager.ApplicationActivate(Sender: TObject);
begin
  if Assigned(FOldApplicationActivate) then
    FoldApplicationActivate(Sender);
  if Assigned(FSetSizeForm) and ((FFormDeactivateState and 1) > 0) then
    FSetSizeForm.Visible := True;
  if Assigned(FAlignmentForm) and ((FFormDeactivateState and 2) > 0) then
    FAlignmentForm.Visible := True;
end;

procedure TgsResizeManager.ApplicationDeactivate(Sender: TObject);
begin
  FFormDeactivateState := 0;
  if Assigned(FSetSizeForm) and FSetSizeForm.Visible then
  begin
    FFormDeactivateState := 1;
    FSetSizeForm.Hide;
  end;
  if Assigned(FAlignmentForm) and FAlignmentForm.Visible then
  begin
    FFormDeactivateState := FFormDeactivateState or 2;
    FAlignmentForm.Hide;
  end;
  if Assigned(FOldApplicationDeactivate) then
    FoldApplicationDeactivate(Sender);
end;

function TgsResizeManager.GetObjectInspectorForm: IgsObjectInspectorForm;
begin
  Result := FObjectInspectorForm;
end;

procedure TgsResizeManager.CopyAction(Sender: TObject);
var
  S1: TMemoryStream;
  S2: TStringStream;
  W: TWriter;
  C: TComponent;
  I, J: Integer;
  L: TList;
  function GetIndex(P: TComponent): Integer;
  begin
    Result := -1;
    if (P is TWinControl) and not (P is TgsComponentEmulator) then
      Result := TWinControl(P).TabOrder;
  end;
begin
  CancelCut(nil);
  if FResizerList.Count > 0 then
  begin
    S1 := TMemoryStream.Create;
    try
      S2 := TStringStream.Create('');
      try
        Clipboard.Open;
        try
          Clipboard.AsText := '';

          L := TList.Create;
          try
            for I := 0 to FResizerList.Count - 1 do
            begin
              L.Add(Resizers[I]);
            end;
            for I := 0 to L.Count - 1 do
              for J := 1 to L.Count - 1 do
              begin
                if (GetIndex(TgsResizer(L[J]).MovedControl) < GetIndex(TgsResizer(L[J - 1]).MovedControl))
                   and (GetIndex(TgsResizer(L[J - 1]).MovedControl) <> -1) then
                 L.Move(J, J - 1);
              end;

            for I := 0 to L.Count - 1 do
            begin
              S1.Clear;
              S2.Size := 0;

              if (TgsResizer(L[I]).MovedControl is TgsComponentEmulator) then
                C := TgsComponentEmulator(TgsResizer(L[I]).MovedControl).RelatedComponent
              else
                C := TgsResizer(L[I]).MovedControl;

              W := TWriter.Create(S1, 4096);
              try
                W.RootAncestor := Nil;
                W.Ancestor := Nil;
                W.Root := FEditForm;
                W.WriteSignature;
                W.WriteComponent(C);
              finally
                W.Destroy;
              end;
              if C is TControl then
                FRemovalList.CopyParent := TControl(C).Parent
              else
                FRemovalList.CopyParent := FEditForm;

              S1.Seek(0, soFromBeginning);
              try
                ObjectBinaryToText(S1, S2);
              except
                on E:Exception do
                ShowMessage('Ошибка копирования: ' + E.Message);
              end;

              Clipboard.AsText := Clipboard.AsText + S2.DataString;
            end;
          finally
            L.Free;
          end;
        finally
          Clipboard.Close;
        end;
      finally
        S2.Free;
      end;
    finally
      S1.Free
    end;
  end;
end;

procedure TgsResizeManager.FormOnPaint(Sender: TObject);
var
  I, J, L, W: Integer;
begin
  if (FGridSize > 0) then
  begin
    with FEditForm do
    begin
//      Canvas.Brush.Color := Color;
//      Canvas.Brush.Style := bsSolid;
//      Canvas.FillRect(ClientRect);
//      Canvas.ClipRect := FEditForm.ClientRect;
  // Canvas.ClipRect.Left
      L := HorzScrollBar.ScrollPos - (HorzScrollBar.ScrollPos div FGridSize) * FGridSize;
      W := VertScrollBar.ScrollPos - (VertScrollBar.ScrollPos div FGridSize) * FGridSize;
      for I := 0 to ClientWidth div FGridSize do
        for J := 0 to ClientHeight div FGridSize do
          Canvas.Pixels[(I * FGridSize) + L, (J * FGridSize) + W] := clBlack;
    end;
  end;
end;

procedure TgsResizeManager.AddPropertyNotification(AControl: TControl);
begin
  if not Assigned(FPropNotifyList) then
    Exit;
  if FPropNotifyList.IndexOf(AControl) = -1 then
  begin
    FPropNotifyList.Add(AControl);
    AControl.FreeNotification(Self);
  end;
end;

procedure TgsResizeManager.RemovePropertyNotification(AControl: TControl);
var
  I: Integer;
begin
  if not Assigned(FPropNotifyList) then
    Exit;
  I := FPropNotifyList.IndexOf(AControl);
  if I <> -1 then
    FPropNotifyList.Delete(I);
end;

procedure TgsResizeManager.PropertyChanged(AnObject: TObject);
var
  I: Integer;
begin
  if not Assigned(FPropNotifyList) then
    Exit;
  for I := 0 to FPropNotifyList.Count - 1 do
    TControl(FPropNotifyList[I]).Perform(CM_PROPERTYCHANGED, Integer(AnObject), 0)
end;

procedure TgsResizeManager.SetSettings;
begin

  FMessageHooker.Parent := FEditForm;
  FMessageHooker.SetBounds(0, 0, 0, 0);

  if ([cfsUserCreated, cfsCreating] * (FEditForm as TCreateableForm).CreateableFormState = [cfsUserCreated, cfsCreating]) then
  begin
    Enabled := True;
  end;
end;

{procedure TgsResizeManager.OnFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;}

function TgsResizeManager.IsInResize: Boolean;
begin
  Result := FCursor;
end;

procedure TgsResizeManager.EndMultiSelect(const P: TPoint);
var
  I: Integer;
  Rc: TRect;
  LMovedControl: TWinControl;
begin
  DrawMultiSelect;
  FOldMultiPoint := P;
  FMultiSelect := False;
  ClipCursor(nil);
  Assert(FResizerList.Count < 2);
  if FResizerList.Count > 0 then
  begin
    Resizers[0].EndMultiSelect;
    LMovedControl := Resizers[0].MovedControl as TWinControl;
  end else
    LMovedControl := FEditForm;
  Rc := GetRealRect(LMovedControl.ScreenToClient(FStartMultiPoint),
   LMovedControl.ScreenToClient(FOldMultiPoint));
  for I := 0 to LMovedControl.ControlCount - 1 do
    if (LMovedControl.Controls[I].Top < Rc.Bottom) and
     (LMovedControl.Controls[I].Top + LMovedControl.Controls[I].Height > Rc.Top) and
     (LMovedControl.Controls[I].Left < Rc.Right) and
     (LMovedControl.Controls[I].Left + LMovedControl.Controls[I].Width > Rc.Left) then
      AddResizer(LMovedControl.Controls[I], True);
end;

procedure TgsResizeManager.MoveMultiSelect(const P: TPoint);
begin
  DrawMultiSelect;
  FOldMultiPoint := P;
  DrawMultiSelect;
end;

procedure TgsResizeManager.StartMultiSelect(const P: TPoint);
var
  R: TRect;
  Cntrl: TControl;
begin
  if FMultiselect then
    EndMultiselect(P);
  Cntrl := ControlAtPos(FEditForm, P);
  if not ((Cntrl is TWinControl) and (csAcceptsControls in Cntrl.ControlStyle)) then
    Exit;
  FMultiSelect := True;
  FStartMultiPoint := P;
  FOldMultiPoint := FStartMultiPoint;
  DrawMultiSelect;
  try
    ClearResizers;
    AddResizer(Cntrl, False);
  except
  end;
  Assert(FResizerList.Count < 2);
  if FResizerList.Count > 0 then
  begin
    Resizers[0].StartMultiSelect;
    R := Resizers[0].MovedControl.ClientRect;
    OffsetRect(R, Resizers[0].MovedControl.ClientOrigin.X, Resizers[0].MovedControl.ClientOrigin.Y);
  end else
  begin
    R := FEditForm.ClientRect;
    OffsetRect(R, FEditForm.ClientOrigin.X, FEditForm.ClientOrigin.Y);
  end;

  //Ограничиваем перемещение курсора
  ClipCursor(@R);
end;

procedure TgsResizeManager.DrawMultiSelect;
var
  dc: hDC;
begin
  dc := GetDC(0);
  try
    if FObjectInspectorForm.FormStyle = fsStayOnTop then
      ExcludeClipRect(dc, FObjectInspectorForm.Left, FObjectInspectorForm.Top,
       FObjectInspectorForm.Left + FObjectInspectorForm.Width, FObjectInspectorForm.Top + FObjectInspectorForm.Height);
    if FPaletteForm.FormStyle = fsStayOnTop then
      ExcludeClipRect(dc, FPaletteForm.Left, FPaletteForm.Top,
       FPaletteForm.Left + FPaletteForm.Width, FPaletteForm.Top + FPaletteForm.Height);
    DrawFocusRect(dc, GetRealRect(FStartMultiPoint, FOldMultiPoint));
  finally
    ReleaseDC(0, dc);
  end;
end;

function TgsResizeManager.GetRealRect(P1, P2: TPoint): TRect;
begin
  if P1.x < P2.x then
  begin
    Result.Left := P1.x;
    Result.Right := P2.x;
  end else
  begin
    Result.Left := P2.x;
    Result.Right := P1.x;
  end;
  if P1.y < P2.y then
  begin
    Result.Top := P1.y;
    Result.Bottom := P2.y;
  end else
  begin
    Result.Top := P2.y;
    Result.Bottom := P1.y;
  end;
end;

procedure TgsResizeManager.DoHintTimer(Sender: TObject);
var
  P: TPoint;
  HintStr: String;
  LComponent: TComponent;
  LControl: TControl;
  Rct: TRect;
begin
  (Sender as TTimer).Enabled := False;
  if FEditForm <> Screen.ActiveForm then
  begin
    FHintWindow.ReleaseHandle;
    Exit;
  end;
  GetCursorPos(P);
  if (FHintPoint.x <> P.x) or (FHintPoint.y <> P.y) then
    Exit;
  LControl := ControlAtPos(FEditForm, P);
  while Assigned(LControl) and (LControl.Name = '') do
    LControl := LControl.Parent;
  LComponent := LControl;
  if Assigned(LComponent) then
  begin
    if LComponent is TgsComponentEmulator then
      LComponent := TgsComponentEmulator(LComponent).RelatedComponent;
    HintStr := LComponent.Name + ': ' + LComponent.ClassName;
    if LComponent is TControl then
      HintStr := HintStr +
        #13#10 +
        'Origin: ' + IntToStr(TControl(LComponent).Left) + ', ' +
        IntToStr(TControl(LComponent).Top) + '; ' +
        'Size: ' + IntToStr(TControl(LComponent).Width) + ' x ' +
        IntToStr(TControl(LComponent).Height);
    Rct := FHintWindow.CalcHintRect(640, HintStr, nil);
    OffsetRect(Rct, P.x, P.y + GetSystemMetrics(SM_CYCURSOR) div 2);
    FHintWindow.ActivateHint(Rct, HintStr);
  end;

end;

procedure TgsResizeManager.ShowHint;
var
  P: TPoint;
begin
  if not Assigned(FHintWindow) then
  begin
    FHintWindow := THintWindow.Create(Self);
    FHintWindow.Canvas.Brush.Color := clInfoBk;
    FHintWindow.Color := clInfoBk;
  end;
  if not Assigned(FHintTimer) then
  begin
    FHintTimer := TTimer.Create(Self);
    FHintTimer.Enabled := False;
    FHintTimer.Interval := 300;
    FHintTimer.OnTimer := DoHintTimer;
  end;
  if FEditForm <> Screen.ActiveForm then
  begin
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    Exit;
  end;
  GetCursorPos(P);
  if (FHintPoint.x <> P.x) or (FHintPoint.y <> P.y) then
  begin
    FHintWindow.ReleaseHandle;
    FHintTimer.Enabled := False;
    FHintTimer.Enabled := True;
  end;
  FHintPoint := P;
end;

procedure TgsResizeManager.FormOnCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

{ TApplicationMessageProcessor }

constructor TApplicationMessageProcessor.Create;
begin
  Assert(not Assigned(ApplicationMessageProcessor));

  inherited;

  FEventList := TresTwoPointerList.Create;
  FOldApplMessage := Application.OnMessage;
  Application.OnMessage := ProcessApplMessage;
  ApplicationMessageProcessor := Self;
end;

destructor TApplicationMessageProcessor.Destroy;
begin
  if ApplicationMessageProcessor = Self then
    ApplicationMessageProcessor := nil;
  Application.OnMessage := FOldApplMessage;
  FreeAndNil(FEventList);

  inherited;
end;

procedure TApplicationMessageProcessor.ProcessApplMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  I: Integer;
begin
  for I := 0 to FEventList.Count - 1 do
  begin
    PresTwoPointer(FEventList.Items[I])^.EventPointer(Msg, Handled);
    if Handled then
      Exit;
  end;
  if Assigned(FOldApplMessage) then
    FOldApplMessage(Msg, Handled);
end;

class procedure TApplicationMessageProcessor.RegisterOnMessage(
  const Sender: TObject; const AnMessageEvent: TMessageEvent);
begin
  if not Assigned(ApplicationMessageProcessor) then
    TApplicationMessageProcessor.Create;
  ApplicationMessageProcessor.FEventList.Add(Sender, AnMessageEvent);
end;

class procedure TApplicationMessageProcessor.UnRegisterOnMessage(
  const Sender: TObject);
begin
  if not Assigned(ApplicationMessageProcessor) then
    raise Exception.Create('ApplicationMessageProcessor не создан');
  ApplicationMessageProcessor.FEventList.Delete(Sender);
  if ApplicationMessageProcessor.FEventList.Count = 0 then
    ApplicationMessageProcessor.Free;
end;

{ TresTwoPointerList }

function TresTwoPointerList.Add(AnSender: TObject;
  AnMessageEvent: TMessageEvent): Integer;
var
  P: ^TresTwoPointer;
begin
  New(P);
  P^.ObjectPointer := AnSender;
  P^.EventPointer := AnMessageEvent;
  Result := inherited Add(P);
end;

procedure TresTwoPointerList.Clear;
begin
  inherited;

end;

procedure TresTwoPointerList.Delete(AnSender: TObject);
var
  I: Integer;
  P: ^TresTwoPointer;
begin
  for I := 0 to Count - 1 do
    if PresTwoPointer(Items[I])^.ObjectPointer = AnSender then
    begin
      P := Pointer(Items[I]);
      inherited Delete(I);
      Dispose(P);
      Break;
    end;
end;

procedure TgsResizeManager.CopyNameAction(Sender: TObject);
var
  S: String;
//  I: Integer;
begin
  Clipboard.Open;
  try
    if Assigned(FPopupControl) then
    begin
      if FPopupControl is TgsComponentEmulator then
        S := TgsComponentEmulator(FPopupControl).RelatedComponent.Name
      else
        S := FPopupControl.Name;
    end
    else
      S := FEditForm.Name;
    Clipboard.AsText := S;
  finally
    Clipboard.Close;
  end;
end;

function TgsResizeManager.GetComponentsForm: Tdlg_gsResizer_Components;
begin
  Result := FComponentsForm;
end;

procedure TgsResizeManager.SetComponentsForm(
  const Value: Tdlg_gsResizer_Components);
begin
  FComponentsForm := Value;
end;

procedure TgsResizeManager.InsertNewControl2;
var
  C: TPersistentClass;
  AControl: TControl;
  AComponent: TComponent;
  ParentControl: TControl;
  T: TgsComponentEmulator;
  L: Longint;
begin

  C := FComponentsForm.NewControlClass;

  if Assigned(C) then
  begin
    if C.InheritsFrom(TControl) then
    begin
      AControl := CControl(C).Create(FEditForm);
      AControl.Name :=  GetNewControlName(AControl.ClassName);

      if FResizerList.Count > 0 then
      begin
        if Resizers[0].FMovedControl is TgsComponentEmulator then
          ParentControl := FEditForm
        else
          ParentControl := Resizers[0].FMovedControl;
      end
      else
        ParentControl := FEditForm;

      if not (((ParentControl.InheritsFrom(TWinControl)) and  (not (ParentControl is TgsResizer))
        and (csAcceptsControls in ParentControl.ControlStyle))) then
      begin
        ParentControl := ParentControl.Parent;
      end;

      if (ParentControl is TgsResizer) then
      begin
        if (TgsResizer(ParentControl).FMovedControl is TWinControl) and
           (csAcceptsControls in TgsResizer(ParentControl).FMovedControl.ControlStyle) then
          ParentControl := TgsResizer(ParentControl).FMovedControl
        else
          ParentControl := TgsResizer(ParentControl).FMovedControl.Parent;
      end;

      TComponentCracker(AControl).SetDesigning(True, False);

      AControl.Left := (ParentControl.Width div 2) - (AControl.Width div 2);
      AControl.Top := (ParentControl.Height div 2) - (AControl.Height div 2);;
      AControl.Parent := TWinControl(ParentControl);
      FObjectInspectorForm.RefreshList;
      try
        AddResizer(AControl, False);
      except
      end;
      if Assigned(EventControl) then
        EventControl.PropertyNotification(AControl, poInsert)

    end
    else
    begin
      ParentControl := FEditForm;
      AComponent := CComponent(C).Create(FEditForm);
      AComponent.Name :=  GetNewControlName(AComponent.ClassName);
      TComponentCracker(AComponent).SetDesigning(True, False);
      LongRec(L).Hi := (ParentControl.Height div 2) ;
      LongRec(L).Lo := (ParentControl.Width div 2);;
      AComponent.DesignInfo := L;
      T := TgsComponentEmulator.Create(FEditForm, AComponent);
      try
        T.Name := GetNewControlName(T.ClassName);
        T.Caption := '';
        FEmulatorsList.Add(T);
        if FEditForm.ClientHeight < T.Top then
          T.Top := 0;
        if FEditForm.ClientWidth < T.Left then
          T.Top := 0;
      except
        T.Free;
      end;
      FObjectInspectorForm.RefreshList;
      try
        AddResizer(T, False);
      except
      end;
      if Assigned(EventControl) then
        EventControl.PropertyNotification(AComponent, poInsert)
    end;
  end;

end;

procedure TgsResizeManager.MenuPopup(Sender: TObject);
begin
  if Assigned(FHintWindow) and Assigned(FHintTimer) then
  begin
    FHintTimer.Enabled := False;
    FHintWindow.ReleaseHandle;
  end;
end;

procedure TgsResizeManager.ShowEvents;
begin
  if Assigned(EventControl) then
  begin
    if (EditForm is TCreateableForm)
      and Assigned(IBLogin)
      and (not IBLogin.IsIBUserAdmin) then
    begin
      if cfsUserCreated in TCreateableForm(EditForm).CreateableFormState then
      begin
        MessageBox(0,
          'Для пользовательских форм просмотр и изменение обработчиков событий возможно только под учетной записью Administrator.',
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;

    if FResizerList.Count > 0 then
    begin
      if Resizers[0].FMovedControl is TgsComponentEmulator then
        EventControl.EditObject(TgsComponentEmulator(Resizers[0].FMovedControl).RelatedComponent , emEvent, '')
      else
        EventControl.EditObject(Resizers[0].FMovedControl, emEvent, '');
    end
    else
      EventControl.EditObject(FEditForm, emEvent, '');
  end
end;

procedure TgsResizeManager.StorePropertyState;
var
  I: Integer;
  procedure ReadProperties(Root, Instance: TObject; PathPrefix: String);
  var
    J, NumProps: Integer;
    PropList: PPropList;
    ClassTypeInfo: PTypeInfo;
    ClassTypeData: PTypeData;
    O: TObject;
  begin
    ClassTypeInfo := Instance.ClassInfo;
    ClassTypeData := GetTypeData(ClassTypeInfo);
    if ClassTypeData.PropCount > 0 then
    begin
      GetMem(PropList, SizeOF(PPropInfo) * ClassTypeData.PropCount);
      try
        NumProps := GetPropList(ClassTypeInfo, PropertyTypes, PropList);
        for J := 0 to NumProps - 1 do
        begin
          if PropList[J]^.PropType^.Kind = tkClass then
          begin
            O := GetObjectProp(Instance, PropList[J]^.Name, TObject);
            if (O <> nil) and (not O.InheritsFrom(TComponent)) then
              ReadProperties(Root, O, PathPrefix + PropList[J]^.Name + '.')
            else
              FStartPropList.Add(Root, PathPrefix + PropList[J]^.Name);
          end
          else
            FStartPropList.Add(Root, PathPrefix + PropList[J]^.Name);
        end;
      finally
        FreeMem(PropList, SizeOF(PPropInfo) * ClassTypeData.PropCount);
      end;
    end;
  end;

begin
  FStartPropList.Clear;
  FStartPropList.Sorted := False;
  try
    ReadProperties(FEditForm, FEditForm, '');
    for I := 0 to FEditForm.ComponentCount - 1 do
      ReadProperties(FEditForm.Components[I], FEditForm.Components[I], '');

  finally
    FStartPropList.Sorted := True;
  end;
end;

procedure TgsResizeManager.CheckPropertyState;
  procedure ReadProperties(Root, Instance: TObject; PathPrefix: String);
  var
    J, NumProps: Integer;
    PropList: PPropList;
    ClassTypeInfo: PTypeInfo;
    ClassTypeData: PTypeData;
    O: TObject;
  begin
    ClassTypeInfo := Instance.ClassInfo;
    ClassTypeData := GetTypeData(ClassTypeInfo);
    if ClassTypeData.PropCount > 0 then
    begin
      GetMem(PropList, SizeOF(PPropInfo) * ClassTypeData.PropCount);
      try
        NumProps := GetPropList(ClassTypeInfo, PropertyTypes, PropList);
        for J := 0 to NumProps - 1 do
        begin
          if PropList[J]^.PropType^.Kind = tkClass then
          begin
            O := GetObjectProp(Instance, PropList[J]^.Name, TObject);
            if (O <> nil) and (not O.InheritsFrom(TComponent)) then
              ReadProperties(Root, O, PathPrefix + PropList[J]^.Name + '.')
            else
            if not FStartPropList.SameValue(Root, PathPrefix + PropList[J]^.Name) then
              FChangedPropList.Add(Root, PathPrefix + PropList[J]^.Name);

          end
          else
            if not FStartPropList.SameValue(Root, PathPrefix + PropList[J]^.Name) then
              FChangedPropList.Add(Root, PathPrefix + PropList[J]^.Name);
        end;
      finally
        FreeMem(PropList, SizeOF(PPropInfo) * ClassTypeData.PropCount);
      end;
    end;
  end;

var
  I: Integer;
begin
  ReadProperties(FEditForm, FEditForm, '');
  for I := 0 to FEditForm.ComponentCount - 1 do
    ReadProperties(FEditForm.Components[I], FEditForm.Components[I], '');
end;


function TgsResizeManager.GetFormPosition: TPosition;
begin
  Result := FFormPosition;
end;

procedure TgsResizeManager.SetFormPosition(const Value: TPosition);
begin
  FFormPosition := Value;
end;

{ TRemovalList }

procedure TRemovalList.Clear;
var
  I: Integer;
  P: PRemovalItem;
begin
  for I := 0 to Count - 1 do
  begin
    P := Items[I];
    Dispose(P);
  end;
  inherited;
end;

function TRemovalList.GetRemoval(AnObject: TObject): Integer;
var
  I: Integer;
  P: PRemovalItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if TRemovalItem(Items[I]^).Obj = AnObject then
    begin
      TRemovalItem(Items[I]^).Removal := TRemovalItem(Items[I]^).Removal + GRID_SIZE;
      Result := TRemovalItem(Items[I]^).Removal;
      Exit;
    end;
  end;

  New(P);
  P^.Obj := AnObject;
  P^.Removal := 0;
  Add(P);
end;

procedure TRemovalList.SetCopyParent(const Value: TObject);
var
  P: PRemovalItem;
begin
  Clear;
  FCopyParent := Value;
  New(P);
  P^.Obj := FCopyParent;
  P^.Removal := 0;
  Add(P);
end;

function TgsResizeManager.GetMacrosShortCut: TShortCut;
begin
  Result := FMacrosShortCut;
end;

procedure TgsResizeManager.SetMacrosShortCut(const Value: TShortCut);
begin
  if Value <> FMacrosShortCut then
  begin
    FMacrosShortCut := Value;
    if Assigned(FMacrosAction) then
      FMacrosAction.ShortCut := FMacrosShortCut;
  end
end;

procedure TgsResizeManager.OnMacrosAction(Sender: TObject);
begin
  ShowEvents;
end;

function TgsResizeManager.GetAlignmentAction: TAction;
begin
  Result := FAlignmentAction;
end;

function TgsResizeManager.GetSetSizeAction: TAction;
begin
  Result := FSetSizeAction;
end;

function TgsResizeManager.GetTabOrderAction: TAction;
begin
  Result := FTabOrderAction;
end;

{ TEventList }

function TEventList.Add(AComp: TComponent;
  const APropInfo: PPropInfo; AMethod: TMethod): Integer;
var
  P: TMethodRec;
begin
  P := TMethodRec.Create;
  P.Method := AMethod;
  P.Comp := AComp;
  P.PropInfo := APropInfo;
  Result := inherited Add(P);
end;

function TEventList.GetItem(const Index: Integer): TMethodRec;
begin
  Result := (inherited Items[Index]) as TMethodRec;
end;

procedure TgsResizeManager.ComponentNameChanged(AComponent: TComponent;
  AOldValue, ANewValue: TComponentName);
var
  EvtObj: TEventObject;
  sName: string;
begin
  if not Assigned(EventControl) or (AOldValue = ANewValue) then Exit;

  sName:= GetControlOldName(AOldValue);

  if sName <> '' then
    EvtObj:= (EventControl.Get_Self as TEventControl).FindRealEventObject(AComponent, sName)
  else
    EvtObj:= (EventControl.Get_Self as TEventControl).FindRealEventObject(AComponent, AOldValue);
  if not Assigned(EvtObj) then Exit;
  if EvtObj.EventList.Count > 0 then begin
    if sName <> '' then
      FChangedNames.Values[sName]:= ANewValue
    else
      FChangedNames.Add(AOldValue + '=' +  ANewValue);
  end;
  if Assigned(EventControl) then
    EventControl.PropertyNotification(AComponent, poRename, AOldValue);
end;

procedure TgsResizeManager.RestoreChangedComponents;
var
  i: integer;
  Comp: TComponent;
begin
  if not (cfsCloseAfterDesign in TCreateableForm(FEditForm).CreateableFormState) then begin
    for i:= FChangedNames.Count - 1 downto 0 do begin
      try
        Comp:= FEditForm.FindComponent(FChangedNames.Values[FChangedNames.Names[i]]);
        if Assigned(Comp) then begin
          if Assigned(EventControl) then
            EventControl.PropertyNotification(Comp, poRename, FChangedNames.Names[i]);
          Comp.Name:= FChangedNames.Names[i];
        end;
      finally
        FChangedNames.Delete(i);
      end;
    end;
  end;
end;

function TgsResizeManager.GetControlOldName(ANewName: string): string;
var
  iPos, i: integer;
begin
  iPos:= -1;
  Result:= '';
  for i:= 0 to FChangedNames.Count - 1 do
    if FChangedNames.Values[FChangedNames.Names[i]] = ANewName then begin
      iPos:= i;
      Break;
    end;
  if iPos > -1 then
    Result:= FChangedNames.Names[iPos]
end;

function TgsResizeManager.GetCopyAction: TAction;
begin
  Result := FCopyAction;
end;

function TgsResizeManager.GetCutAction: TAction;
begin
  Result := FCutAction;
end;

function TgsResizeManager.GetPasteAction: TAction;
begin
  Result := FPasteAction;
end;

function TgsResizeManager.GetResizerList: TObjectList;
begin
  Result:= FResizerList as TObjectList;
end;

function TgsResizeManager.Get_Self: TObject;
begin
  Result := Self;
end;

function TgsResizeManager.IsCut: boolean;
begin
  Result:= FCut;
end;

function TgsResizeManager.GetParentControl: TWinControl;
begin
  Result:= FParentControl;
end;

procedure TgsResizeManager.SetNewParentControl(ANewPar: TWinControl);
begin
  if not Assigned(ANewPar) then
    FNewParent:= FEditForm
  else
    FNewParent:= ANewPar;
end;

procedure TgsResizeManager.CheckForEventChanged(AComp: TComponent;
  SL: TStringList);
var
  i: integer;
begin
  for i:= 0 to FChangedEventList.Count - 1 do begin
    if FChangedEventList[i].Comp <> AComp then Continue;
    SL.Values[FChangedEventList[i].EventName]:= FChangedEventList[i].FunctionName;
  end;
end;

procedure TgsResizeManager.BringToFrontAction(Sender: TObject);
var
  i: integer;
begin
  for i:= 0 to FResizerList.Count - 1 do begin
    if TgsResizer(Resizers[I]).MovedControl is TControl then
      TgsResizer(Resizers[I]).MovedControl.BringToFront;
  end;
end;

procedure TgsResizeManager.SendToBackAction(Sender: TObject);
var
  i: integer;
begin
  for i:= 0 to FResizerList.Count - 1 do begin
    if TgsResizer(Resizers[I]).MovedControl is TControl then
      TgsResizer(Resizers[I]).MovedControl.SendToBack;
  end;
end;

end.

