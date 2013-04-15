
{++

  Copyright (c) 2002-2013 by Golden Software of Belarus

  Module
    gsResizerInterface

  Abstract

    интерфейс к класу TgsResizerManager

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.

--}

unit gsResizerInterface;

interface

uses
  forms, controls, contnrs, classes, messages, dlg_gsResizer_Components_unit,
  sysutils, typinfo, ActnList;

const
  ATCOMPONENT_PREFIX = 'usrat_';

  USERCOMPONENT_PREFIX = 'usr_';
  GLOBALUSERCOMPONENT_PREFIX = 'usrg_';
  USERFORM_PREFIX = 'usrf_';
  MACROSCOMPONENT_PREFIX = 'usrl_';

  MESSAGE_SHIFT = WM_USER + $400;
  CM_NEWCONTROL = MESSAGE_SHIFT + 1;
  CM_RESIZECONTROL = MESSAGE_SHIFT + 2;
  CM_SHOWMENU = MESSAGE_SHIFT + 3;
  CM_ADDCONTROL = MESSAGE_SHIFT + 4;
  CM_INSERTNEW = MESSAGE_SHIFT + 5;
  CM_SHOWINSPECTOR = MESSAGE_SHIFT + 6;
  CM_SHOWPALETTE = MESSAGE_SHIFT + 7;
  CM_NEWCONTROLR = MESSAGE_SHIFT + 8;
  CM_PROPERTYCHANGED = MESSAGE_SHIFT + 9;
  WM_USER_MOUSEMOVE = MESSAGE_SHIFT + 10;
  WM_USER_LBUTTONUP = MESSAGE_SHIFT + 11;
  CM_INSERTNEW2 = MESSAGE_SHIFT + 12;
  CM_DELETECONTROL = MESSAGE_SHIFT + 13;
  CM_SHOWEVENTS = MESSAGE_SHIFT + 14;
  CM_SHOWEDITFORM = MESSAGE_SHIFT + 15;

  PropertyTypes = [tkInteger, tkChar, tkEnumeration, tkWChar, tkFloat, tkString,
                    tkSet, tkClass, tkLString, tkWString, tkVariant,
                    tkArray, tkRecord, {tkInterface,} tkInt64, tkDynArray];

type
  ESetProperty = Exception;

  TgsAction = class(TAction)
  private
    procedure DoOnExecute(Sender: TObject);
  public
    constructor Create (AOwner: TComponent); override;
  end;

  TComponentCracker = class(TComponent);
  TControlCracker = class(TControl);

  TDesignerType = (dtGlobal, dtUser);

  TPositionAlignment = (paLeft, paRight, paTop, paBottom, paCenterVert,
                        paCenterHoriz, paCenterFormHoriz, paCenterFormVert,
                        paSpaceEqualHoriz, paSpaceEqualVert);
  TSizeChanger = (scGrowHoriz, scGrowVert, scGrowBoth,
                  scShrinkHoriz, scShrinkVert, scShrinkBoth);
  TManagerState = (msDesign, msNewControl);

  TOnResiserActivate = procedure(var Activate: boolean) of object;


  TPropertyValue = class
  private
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); dynamic; abstract;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; dynamic; abstract;
  end;

  TPropertyValue_Ordinal = class(TPropertyValue)    {tkInteger, tkChar, tkEnumeration, tkSet}
  private
    FValue: Longint;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
  end;

  TPropertyValue_Float = class(TPropertyValue)    {tkFloat}
  private
    FValue: Extended;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
  end;

  TPropertyValue_String = class(TPropertyValue)    {tkString, tkLString, tkWString}
  private
    FValue: String;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
  end;

  TPropertyValue_Int64 = class(TPropertyValue)  {tkInt64}
  private
    FValue: Int64;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
  end;

  TPropertyValue_Class = class(TPropertyValue)  {tkClass}
  private
    FValue: String;
//    FCollectionValue: TCollection;
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
  public  
    destructor Destroy; override;
  end;

  TPropertyValue_Unknown = class(TPropertyValue)  {Other}
  private
    function SameValue(AnObject: TObject; APropInfo: PPropInfo): boolean; override;
    constructor Create(AnObject: TObject; APropInfo: PPropInfo); override;
  end;

  {tkClass, tkMethod, tkWChar,
   tkVariant, tkArray, tkRecord, tkInterface, tkDynArray}

  {PropType := PPropInfo(PropInfo)^.PropType^;
    case PropType^.Kind of
      tkClass: WriteObjectProp;
      tkMethod: WriteMethodProp;
      tkVariant: WriteVariantProp;
    end;}

  TChangedProp = class
  private
    FOwner: TObject;
    FPropertyValue: TPropertyValue;
    FPropertyName: String;
    function SameValue(AnObject: TObject): boolean;
  public
    constructor Create(AnOwner: TObject; const APropertyName: String);
    destructor Destroy; override;
    property Owner: TObject read FOwner write FOwner;
  end;

  TChangedPropList = class(TStringList)
  public
    function SameValue(AnObject: TObject; APropertyName: String): Boolean;
    constructor Create; reintroduce;
    destructor Destroy; override;
    function IndexByName(AnOwner: TObject; const AName: String): Integer;
    function Add(AnOwner: TObject; const APropName: String): Integer; reintroduce;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
  end;

  TChangedEvent = class
  private
    FOldFunctionID: integer;
    FNewFunctionID: integer;
    FEventName: string;
    FComp: TComponent;
    FFunctionName: string;
  public
    property Comp: TComponent read FComp write FComp;
    property EventName: string read FEventName write FEventName;
    property FunctionName: string read FFunctionName write FFunctionName;
    property OldFunctionID: integer read FOldFunctionID write FOldFunctionID;
    property NewFunctionID: integer read FNewFunctionID write FNewFunctionID;
  end;

  TChangedEventList = class(TObjectList)
  private
    function GetItem(const Index: Integer): TChangedEvent;
  public
    function  Add(AComp: TComponent; AEvent: string; ANewID: integer; AName: string): Integer;
    function  FindByCompAndEvent(AComp: TComponent; AEvent: string): integer; overload;
    function  FindByCompAndEvent(AName: string; AEvent: string): integer; overload;
    property  Items[const Index: Integer]: TChangedEvent read GetItem; default;
  end;


  TControlList = class(TObjectList)
  private
    function GetItem(const Index: Integer): TControl;
    procedure SetItem(const Index: Integer; AControl: TControl);
  public
    destructor Destroy; override;
    function Add(AControl: TControl): Integer;
    function IndexOf(AControl: TControl): Integer;
    procedure DeleteControl(AControl: TControl);
    property Items[const Index: Integer]: TControl read GetItem write SetItem; default;
  end;

  IgsResizeManager = interface;

  IgsObjectInspectorForm = interface
  ['{58E36093-C3AE-445F-A4FB-4B5A545E4891}']
    function AddEditComponent(AComponent: TComponent; const AShiftState: Boolean): Boolean;
    function AddEditSubComponent(ASubComponent: TPersistent): Boolean;
    procedure RefreshList;
    procedure RefreshProperties;
    function GetManager: IgsResizeManager;
    property Manager: IgsResizeManager read GetManager;
    procedure FreeNotification(AComponent: TComponent);
    function GetSelf: TComponent;
    procedure EventSync(const AnObjectName, AnEventName: String);
  end;

  IgsResizeManager = interface
  ['{148ECE00-BBBB-4F35-B8AD-10206B699ADF}']
    function  Get_Self: TObject;
    procedure SetAlignment(const AnAlignment: TPositionAlignment);
    procedure SetControlSize(const ASizeType: TSizeChanger);
    procedure SetManagerState(const AManagerSatate: TManagerState);
    procedure SaveAndExit;
    procedure ExitWithoutSaving;
    procedure ExitAndLoadDefault;
    procedure FreeResizer;
    procedure InsertNewControl2;
    procedure ReloadComponent(const Attr: Boolean);

    procedure Reset;
    procedure Free;
    function GetOnActivate: TOnResiserActivate;
    procedure SetOnActivate(const Value: TOnResiserActivate);

    procedure SetShortCut(const Value: TShortCut);
    function GetShortCut: TShortCut;

    procedure PropertyChanged(AnObject: TObject);
    procedure AddPropertyNotification(AControl: TControl);
    procedure RemovePropertyNotification(AControl: TControl);

    function GetComponentsForm: Tdlg_gsResizer_Components;
    procedure SetComponentsForm(const Value: Tdlg_gsResizer_Components);

    function GetDesignerType: TDesignerType;
    function SetPropertyValue(AComponent: TObject; const PropertyName, PropertyValue: String): String;
    function AddResizer(AControl:  TControl; AShiftState: Boolean): boolean;
    function GetEditForm: TForm;
    function GetInvisibleList: TControlList;
    function GetInvisibleTabsList: TControlList;
    function AddComponent(AComponent: TComponent): TControl;
    function GetChangedPropList: TChangedPropList;
    function GetChangedEventList: TChangedEventList;
    function GetNewControlName(AClassName: String): String;
    function GetObjectInspectorForm: IgsObjectInspectorForm;
    function GetFormPosition: TPosition;
    procedure SetFormPosition(const Value: TPosition);

    function GetAlignmentAction: TAction;
    function GetSetSizeAction: TAction;
    function GetTabOrderAction: TAction;
    function GetCopyAction: TAction;
    function GetCutAction: TAction;
    function GetPasteAction: TAction;

    procedure AddNonVisibleComponent(AComponent: TComponent; const AShiftState: Boolean);
    procedure RefreshList;
    property EditForm: TForm read GetEditForm;
    property ObjectInspectorForm: IgsObjectInspectorForm read GetObjectInspectorForm;
    property InvisibleList: TControlList read GetInvisibleList;
    property InvisibleTabsList: TControlList read GetInvisibleTabsList;
    property ChangedPropList: TChangedPropList read GetChangedPropList;
    property ChangedEventList: TChangedEventList read GetChangedEventList;
    property ShortCut: TShortCut read GetShortCut write SetShortCut;
    property DesignerType: TDesignerType read GetDesignerType;
    property OnActivate: TOnResiserActivate read GetOnActivate write SetOnActivate;
    property ComponentsForm: Tdlg_gsResizer_Components read GetComponentsForm write SetComponentsForm;

    property FormPosition: TPosition read GetFormPosition write SetFormPosition;

    property AlignmentAction: TAction read GetAlignmentAction;
    property SetSizeAction: TAction read GetSetSizeAction;
    property TabOrderAction: TAction read GetTabOrderAction;
    property CopyActionI: TAction read GetCopyAction;
    property PasteActionI: TAction read GetPasteAction;
    property CutActionI: TAction read GetCutAction;

    function GetResizerList: TObjectList;

    property ResizersList: TObjectList read GetResizerList;
//    property Resizers[const Index: Integer]: TCustomControl read GetResizer;

    procedure ComponentNameChanged(AComponent: TComponent; AOldValue, ANewValue: TComponentName);
    procedure EventFunctionChanged(AComp: TComponent; AEvent: string; ANewID: integer; AName: string);
    procedure CheckForEventChanged(AComp: TComponent; SL: TStringList);

  end;

  function GlobalFindComponent(AComponentName: TComponentName; AnOwner: TComponent): TComponent;

implementation

uses
  evt_base, evt_i_base;

function GlobalFindComponent(AComponentName: TComponentName; AnOwner: TComponent): TComponent;

  function FindAppComponent(ACName: TComponentName; AnOwn: TComponent): TComponent;
  var
    S, S1: String;
  begin
    Result := AnOwn;
    S1 := ACName;

    while Pos('.', S1) <> 0 do
    begin
      S := Copy(ACName, 1, Pos('.', ACName) - 1);
      S1 := Copy(ACName, Pos('.', ACName) + 1, Length(ACName));
      Result := GlobalFindComponent(S, Result);
      if Result = nil then
        Exit;
    end;

    Result := GlobalFindComponent(S1, Result);

  end;

var
  I: Integer;

begin
  Result := nil;
  if AComponentName = AnOwner.Name then
  begin
    Result := AnOwner;
  end
  else
  begin
    if Pos('.', AComponentName) <> 0 then
    begin
      Result := FindAppComponent(AComponentName, Application);
    end
    else
    begin
      I := 0;
      while (I < AnOwner.ComponentCount) and (Result = nil) do
      begin
        if AnsiUpperCase(AComponentName) = AnsiUpperCase(AnOwner.Components[I].Name) then
           Result := AnOwner.Components[I];
        Inc(I);
      end;
    end;
  end;
end;

(*procedure DesignerSetDefaultValues(AComponent, ARoot: TComponent);
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
          DesignerSetPropertyValue(AComponent, PropList[i]^.Name, '0', ARoot)
        else
          DesignerSetPropertyValue(AComponent, PropList[i]^.Name, IntToStr(PropList[i]^.Default), ARoot);
      end;
  //          AStrings.Add(Format('%s: %s', [, PropList[i]^.PropType^.Name]));

    finally
      FreeMem(PropList, SizeOf(PPropInfo) * ClassTypeData.PropCount);
    end;
  end;
end;*)

{ TControlList }

function TControlList.Add(AControl: TControl): Integer;
var
  I: Integer;
begin
  I := IndexOf(AControl);
  if I > -1 then
    Result := I
  else
    Result := inherited Add(AControl);
end;

procedure TControlList.DeleteControl(AControl: TControl);
var
  I: Integer;
begin
  I := IndexOf(AControl);
  if I > -1 then
    Delete(I);
end;

destructor TControlList.Destroy;
begin
  inherited;
end;

function TControlList.GetItem(const Index: Integer): TControl;
begin
  Result := TControl(inherited Items[Index]);
end;

function TControlList.IndexOf(AControl: TControl): Integer;
begin
  Result := inherited IndexOf(AControl);
end;

procedure TControlList.SetItem(const Index: Integer; AControl: TControl);
begin
  inherited Items[Index] := AControl;
end;

{ TChangedPropList }

function TChangedPropList.Add(AnOwner: TObject; const APropName: String): Integer;
var
  ChangedProp: TChangedProp;
begin
  Result := -1;

  if Sorted then
    Result := IndexByName(AnOwner, APropName);

  if Result = -1 then
  begin
    ChangedProp := TChangedProp.Create(AnOwner, APropName);
    if ChangedProp.FPropertyValue is TPropertyValue_Unknown then
      ChangedProp.Free
    else
      Result := inherited AddObject(APropName, ChangedProp);
  end;
end;


procedure TChangedPropList.Clear;
var
  I: Integer;
  P: TChangedProp;
begin
  for I := 0 to Count - 1 do
  begin
    P := TChangedProp(Objects[I]);
    P.Free;
  end;
  inherited;
end;

constructor TChangedPropList.Create;
begin
  inherited;
  Duplicates := dupAccept;
  Sorted := True;
end;

procedure TChangedPropList.Delete(Index: Integer);
var
  P: TChangedProp;
begin
  P := TChangedProp(Objects[Index]);
  P.Free;
  inherited Delete(Index);
end;

destructor TChangedPropList.Destroy;
begin
  Clear;
  inherited;
end;

function TChangedPropList.IndexByName(AnOwner: TObject;
  const AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := IndexOf(AName);
  if I > -1 then
  begin
    while (I < Count) and (Strings[I] = AName) do
    begin
      if (TChangedProp(Objects[I]).Owner = AnOwner) then
      begin
        Result := I;
        Exit;
      end;
      Inc(I);
    end;
  end;
end;

function TChangedPropList.SameValue(AnObject: TObject;
  APropertyName: String): Boolean;
var
  I: Integer;
begin
  I := IndexByName(AnObject, APropertyName);
  if I > -1 then
  begin
    Result := TChangedProp(Objects[I]).SameValue(AnObject);
  end
  else
    Result := False;
end;

{ TChangedProp }

constructor TChangedProp.Create(AnOwner: TObject; const APropertyName: String);
var
  PropInfo: PPropInfo;

  I: Integer;
  S, PropName: String;
  Instance, O: TObject;

begin
  inherited Create;
  FOwner := AnOwner;
  FPropertyName := APropertyName;

  PropName := FPropertyName;

  Instance := AnOwner;
  I := Pos('.', PropName);
  while I > 0 do
  begin
    S := Copy(PropName, 1, I - 1);
    PropName := Copy(PropName, I + 1, Length(PropName));

    PropInfo := GetPropInfo(Instance.ClassInfo, S);

    O := GetObjectProp(Instance, PropInfo);
    Instance := O;
    I := Pos('.', PropName);
  end;

  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);

  if (PropInfo = nil) or (PropInfo^.SetProc = nil) then
  begin
    FPropertyValue := TPropertyValue_Unknown.Create(Instance, PropInfo);
    Exit
  end;
  try
    case PropInfo^.PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet:
        FPropertyValue := TPropertyValue_Ordinal.Create(Instance, PropInfo);
      tkFloat:
        FPropertyValue := TPropertyValue_Float.Create(Instance, PropInfo);
      tkString, tkLString, tkWString:
        FPropertyValue := TPropertyValue_String.Create(Instance, PropInfo);
      tkInt64:
        FPropertyValue := TPropertyValue_Int64.Create(Instance, PropInfo);
      tkClass:
        FPropertyValue := TPropertyValue_Class.Create(Instance, PropInfo);
      else
        FPropertyValue := TPropertyValue_Unknown.Create(Instance, PropInfo);
    end;
  except
    FPropertyValue.Free;
    FPropertyValue := TPropertyValue_Unknown.Create(Instance, PropInfo);
  end;
end;

destructor TChangedProp.Destroy;
begin
  FPropertyValue.Free;
end;

function TChangedProp.SameValue(AnObject: TObject): boolean;
 var
  PropInfo: PPropInfo;

  I: Integer;
  S, PropName: String;
  Instance, O: TObject;
begin
  Result := False;

  PropName := FPropertyName;

  Instance := AnObject;
  I := Pos('.', PropName);

  while I > 0 do
  begin
    S := Copy(PropName, 1, I - 1);
    PropName := Copy(PropName, I + 1, Length(PropName));

    PropInfo := GetPropInfo(Instance.ClassInfo, S);

    O := GetObjectProp(Instance, PropInfo);
    Instance := O;
    I := Pos('.', PropName);
  end;

  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);

  if (PropInfo = nil) or (PropInfo^.SetProc = nil) then
    Exit;

  Result := FPropertyValue.SameValue(Instance, PropInfo);
end;

{ TPropertyValue_Ordinal }

constructor TPropertyValue_Ordinal.Create(AnObject: TObject;
  APropInfo: PPropInfo);
begin
  FValue := GetOrdProp(AnObject, APropInfo);
end;

function TPropertyValue_Ordinal.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
begin
  Result := FValue = GetOrdProp(AnObject, APropInfo);
end;

{ TPropertyValue_Float }

constructor TPropertyValue_Float.Create(AnObject: TObject;
  APropInfo: PPropInfo);
begin
  FValue := GetFloatProp(AnObject, APropInfo);
end;

function TPropertyValue_Float.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
begin
  Result :=  FloatToStr(FValue) = FloatToStr(GetFloatProp(AnObject, APropInfo));
end;

{ TPropertyValue_String }

constructor TPropertyValue_String.Create(AnObject: TObject;
  APropInfo: PPropInfo);
begin
  FValue := GetStrProp(AnObject, APropInfo);
end;

function TPropertyValue_String.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
begin
  Result := FValue = GetStrProp(AnObject, APropInfo);
end;

{ TPropertyValue_Int64 }

constructor TPropertyValue_Int64.Create(AnObject: TObject;
  APropInfo: PPropInfo);
begin
  FValue := GetInt64Prop(AnObject, APropInfo);
end;

function TPropertyValue_Int64.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
begin
  Result := FValue = GetInt64Prop(AnObject, APropInfo);
end;

{ TPropertyValue_Unknown }

constructor TPropertyValue_Unknown.Create(AnObject: TObject;
  APropInfo: PPropInfo);
begin
end;

function TPropertyValue_Unknown.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
begin
  Result := True;
end;

{ TPropertyValue_Class }

constructor TPropertyValue_Class.Create(AnObject: TObject;
  APropInfo: PPropInfo);
var
  V: TObject;
begin
  V := TObject(GetOrdProp(AnObject, APropInfo));

  FValue := '';
  if (V <> nil) then
  begin
    if (V is TComponent) then
      FValue := TComponent(V).Name
  end;
end;

destructor TPropertyValue_Class.Destroy;
begin
  inherited;
end;

function TPropertyValue_Class.SameValue(AnObject: TObject;
  APropInfo: PPropInfo): boolean;
var
  V: TObject;
begin
  V := TObject(GetOrdProp(AnObject, APropInfo));

  Result := False;
  if (V <> nil) then
  begin
    if (V is TComponent) then
      Result := SameText(TComponent(V).Name, FValue)
  end
  else if (V = nil) and (FValue = '') then
    Result := True;
end;

{ TgsAction }

constructor TgsAction.Create(AOwner: TComponent);
begin
  inherited;
  OnExecute := DoOnExecute;
end;

procedure TgsAction.DoOnExecute(Sender: TObject);
begin
 //
end;

{ TChangedEventList }

function TChangedEventList.Add(AComp: TComponent; AEvent: string; ANewID: integer; AName: string): Integer;
var
  ceEvent: TChangedEvent;
  EvtItem: TEventItem;
  EvtObj: TEventObject;
  EvtCtrl: TEventControl;
begin
  ceEvent:= TChangedEvent.Create;
  ceEvent.Comp := AComp;
  if Assigned(EventControl) then begin
    EvtCtrl:= EventControl.Get_Self as TEventControl;
    EvtObj:= EvtCtrl.FindRealEventObject(AComp);
    if Assigned(EvtObj) then begin
      EvtItem:= EvtObj.EventList.Find(AEvent);
      if Assigned(EvtItem) then
        ceEvent.OldFunctionID:= EvtItem.FunctionKey;
    end;
  end;
  ceEvent.NewFunctionID:= ANewID;
  ceEvent.EventName:= AnsiUpperCase(AEvent);
  ceEvent.FunctionName:= AName;
  Result := inherited Add(ceEvent);
end;

function TChangedEventList.FindByCompAndEvent(AComp: TComponent; AEvent: string): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count - 1 do begin
    if (AComp = TChangedEvent(Items[i]).Comp) and (AnsiUpperCase(AEvent) = TChangedEvent(Items[i]).EventName) then begin
      Result:= i;
      Exit;
    end;
  end;
end;

function TChangedEventList.FindByCompAndEvent(AName,
  AEvent: string): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count - 1 do begin
    if (AnsiUpperCase(AName) = AnsiUpperCase(TChangedEvent(Items[i]).Comp.Name)) and
        (AnsiUpperCase(AEvent) = TChangedEvent(Items[i]).EventName) then begin
      Result:= i;
      Exit;
    end;
  end;
end;

function TChangedEventList.GetItem(const Index: Integer): TChangedEvent;
begin
  Result := TChangedEvent(inherited Items[Index]);
end;

end.
