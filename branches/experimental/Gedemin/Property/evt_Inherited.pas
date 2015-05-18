unit evt_Inherited;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, StdVcl, Gedemin_TLB, evt_Base, SysUtils;

type
  EParams = class(EAbort)
  end;

  EIncorrectParams = class(EParams)
  end;

  ECountParams = class(EParams)
  end;

  TEventInherited = class
  private
    FInheritedObject: IgsInherited;
    FEventControl: TEventControl;

    function InvokeEvent(const AnObject: IgsObject; const AnName: WideString;
      var AnParams: OleVariant): OleVariant;
  protected
    function Get_Self: TObject;
  public
    constructor Create;
    destructor Destroy; override;

    property InheritedObject: IgsInherited read FInheritedObject;
  end;

implementation

uses
  obj_Inherited,        evt_i_Base,                     Windows,
  TypInfo,              Controls,
  gdcOLEClassList,      forms,                          menus,
  stdctrls,             Actnlist,                       grids,
  gsDBGrid,             DB,                             IBCustomDataSet,
  gdcBase,              gsIBLookupComboBox,             flt_sqlfilter_condition_type,
  gdcDelphiObject,      mtd_i_Base,                     IBDataBase,
  gdcBaseInterface,     gdcConstants,                   gdc_dlgG_unit,
  dbgrids,              prp_Methods,                    gs_Exception,
  gd_ScrException,      comctrls, 			gsSupportClasses,
  ibsql;

const
    eiNotifyEvent = 'TNotifyEvent';
    //(Sender: TObject);
    eiCanResizeEvent = 'TCanResizeEvent';
    //(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    eiConstrainedResizeEvent = 'TConstrainedResizeEvent';
    //(Sender: TObject; var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
    eiContextPopupEvent = 'TContextPopupEvent';
    //(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    eiDragDropEvent = 'TDragDropEvent';
    //(Sender, Source: TObject; X, Y: Integer);
    eiDragOverEvent = 'TDragOverEvent';
    //(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    eiEndDragEvent = 'TEndDragEvent';
    //(Sender, Target: TObject; X, Y: Integer);
    eiMouseEvent = 'TMouseEvent';
    //(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    eiMouseMoveEvent = 'TMouseMoveEvent';
    //(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    eiStartDockEvent = 'TStartDockEvent';
    //(Sender: TObject; var DragObject: TDragDockObject);
    eiStartDragEvent = 'TStartDragEvent';
    //(Sender: TObject; var DragObject: TDragObject);

    eiDockDropEvent = 'TDockDropEvent';
    //(Sender: TObject; Source: TDragDockObject;  X, Y: Integer);
    eiDockOverEvent = 'TDockOverEvent';
    //(Sender: TObject; Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    eiGetSiteInfoEvent = 'TGetSiteInfoEvent';
    //(Sender: TObject; DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    eiKeyEvent = 'TKeyEvent';
    //(Sender: TObject; var Key: Word; Shift: TShiftState);
    eiKeyPressEvent = 'TKeyPressEvent';
    //(Sender: TObject; var Key: Char);
    eiMouseWheelEvent = 'TMouseWheelEvent';
    //(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    eiMouseWheelUpDownEvent = 'TMouseWheelUpDownEvent';
    //(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    eiUnDockEvent = 'TUnDockEvent';
    //(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
    eiCloseEvent = 'TCloseEvent';
    //(Sender: TObject; var Action: TCloseAction);
    eiCloseQueryEvent = 'TCloseQueryEvent';
    //(Sender: TObject; var CanClose: Boolean);
    eiMenuChangeEvent = 'TMenuChangeEvent';
    //(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    eiDrawItemEvent = 'TDrawItemEvent';
    //(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    eiMeasureItemEvent = 'TMeasureItemEvent';
    //(Control: TWinControl; Index: Integer; var Height: Integer);
    eiScrollEvent = 'TScrollEvent';
    //(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    eiActionEvent = 'TActionEvent';
    //(Action: TBasicAction; var Handled: Boolean);
    eiMovedEvent = 'TMovedEvent';
    //(Sender: TObject; FromIndex, ToIndex: Longint);
    eiDrawColumnCellEvent = 'TDrawColumnCellEvent';
    //(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    eiDrawDataCellEvent = 'TDrawDataCellEvent';
    //(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    eiCheckBoxEvent = 'TCheckBoxEvent';
    //(Sender: TObject; CheckID: String; var Checked: Boolean);
    eiAfterCheckEvent = 'TAfterCheckEvent';
    //(Sender: TObject; CheckID: String; Checked: Boolean);
    eiDataSetNotifyEvent = 'TDataSetNotifyEvent';
    //(DataSet: TDataSet);
    eiDataSetErrorEvent = 'TDataSetErrorEvent';
    //(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    eiFilterRecordEvent = 'TFilterRecordEvent';
    //(DataSet: TDataSet; var Accept: Boolean);
    eiIBUpdateErrorEvent = 'TIBUpdateErrorEvent';
    //(DataSet: TDataSet; E: EDatabaseError; UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
    eiIBUpdateRecordEvent = 'TIBUpdateRecordEvent';
    //(DataSet: TDataSet; UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
    eigdcAfterInitSQL = 'TgdcAfterInitSQL';
    //(Sender: TObject; var SQLText: String; var isReplaceSQL: Boolean);
    eigdcDoBeforeShowDialog = 'TgdcDoBeforeShowDialog';
    //(Sender: TObject; DlgForm: TCustomForm);
    eigdcDoAfterShowDialog = 'TgdcDoAfterShowDialog';
    //(Sender: TObject; DlgForm: TCustomForm; IsOk: Boolean);
    eiOnCreateNewObject = 'TOnCreateNewObject';
    //(Sender: TObject; ANewObject: TgdcBase);
    eiConditionChanged = 'TConditionChanged';
    //(Sender: TObject);
    eiFilterChanged = 'TFilterChanged';
    //(Sender: TObject; const AnCurrentFilter: Integer);
    ieOnGetFooter = 'TOnGetFooter';
    //TOnGetFooter = function (Sender: TObject; const FieldName: String; const AggregatesObsolete: Boolean): String of Object;
    ieDataChangeEvent = 'TDataChangeEvent';
    //TDataChangeEvent = procedure(Sender: TObject; Field: TField) of object;
    ieSyncFieldEvent = 'TOnSyncFieldEvent';
    //TOnSyncFieldEvent = procedure((Sender: TObject; Field: TField; SyncList: TList)) of object;

    ieFieldGetTextEvent = 'TFieldGetTextEvent';
    //TFieldGetTextEvent = procedure(Sender: TField; var Text: String; DisplayText: Boolean) of object;
    ieFieldSetTextEvent = 'TFieldSetTextEvent';
    //TFieldSetTextEvent = procedure(Sender: TField; const Text: String) of object;
    ieFieldNotifyEvent = 'TFieldNotifyEvent';
    //TFieldNotifyEvent = procedure(Sender: TField) of object;
    ieOnTestCorrect     = 'TOnTestCorrect';
    //TOnTestCorrect = function(Sender: TObject): Boolean of object;

    ieOnGetSQLClause = 'TgdcOnGetSQLClause';
    //TgdcOnGetSQLClause = procedure(Sender: TObject; var Clause: String) of Object;

    ieTabChangingEvent = 'TTabChangingEvent';
    //TTabChangingEvent = procedure (Sender: TObject; var AllowChange: Boolean) of object;


{ TEventInherited }

constructor TEventInherited.Create;
var
  Loc: TgsInherited;
begin
  inherited;

  if Assigned(EventControl) then
    FEventControl :=  EventControl.Get_Self as TEventControl
  else
    raise Exception.Create(GetGsException(Self, 'Не создан EventControl'));

  Loc := TgsInherited.Create;
  Loc.CustomInvoker := InvokeEvent;
  FInheritedObject := Loc;
end;

destructor TEventInherited.Destroy;
begin
  FEventControl := nil;

  inherited;
end;

function TEventInherited.Get_Self: TObject;
begin
  Result := Self;
end;

function TEventInherited.InvokeEvent(const AnObject: IgsObject;
  const AnName: WideString; var AnParams: OleVariant): OleVariant;
var
  LObj: TObject;
  LEventObject: TEventObject;
  LNotifyEvent: ^TNotifyEvent;
  TempPropList: TPropList;
  LCloseAction: TCloseAction;
  LDragDockObject: TDragDockObject;
  LDragObject: TDragObject;
  LPoint: TPoint;
  I, J: Integer;
  LBool: Boolean;
  p1, p2, p3, p4: integer;
  LStr: String;
  LChar: Char;
  LDataAction: TDataAction;
  LIBUpdateAction: TIBUpdateAction;
  LShiftState: TShiftState;
  LWord: Word;
  LSender, LSender_2: TObject;
  LControl: TControl;
  LWinControl: TWinControl;
  LMenuItem: TMenuItem;
  LBasicAction: TBasicAction;
  LDataSet: TDataSet;
  LEDatabaseError: EDatabaseError;
  LCustomForm: TCustomForm;
  LgdcBase: TgdcBase;
  LField: TField;
  LList: TList;
  LRect: TRect;
  EI: TEventItem;
  M: TMethod;
begin
  try
    LObj := TObject(AnObject.Get_Self);
    LEventObject := FEventControl.EventObjectList.FindAllObject(LObj as TComponent);
    if not Assigned(LEventObject) then
      raise Exception.Create(Format('Класс %s не найден в списке EventControl', [LObj.ClassName]));

    // поиск обработчика события родителя
    if LEventObject.CurrIndexParentObject < (LEventObject.ParentObjectsBySubType.Count - 1) then
    begin
      LEventObject.CurrIndexParentObject := LEventObject.CurrIndexParentObject + 1;
      EI := LEventObject.FindRightEvent(AnName);
    end
    else
      EI := nil;

    // поиск события для данного класса по имени
    j := 1 + GetPropList(LObj.ClassInfo, [tkMethod], @TempPropList);
    i := 0;
    while i < j do
    begin
      if AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase(AnName) then
        Break;
      Inc(i);
    end;

    if not (i < j) then
      raise Exception.Create(Format('Для класса %s событие %s не определено', [LObj.ClassName, AnName]));

    if Assigned(gdScrException) then
      FreeAndNil(gdScrException)
    else
      gdScrException := nil;

    if EI <> nil then
    begin
      M := GetMethodProp(LObj, TempPropList[I]^.Name);
      LNotifyEvent := @M.Code;
    end
    else
      // сохранение адреса Delphi обработчика события
      LNotifyEvent := @LEventObject.EventList.Find(AnName).OldEvent.Code;

    if (not (Assigned(LNotifyEvent))) or (not Assigned(LNotifyEvent^)) then
    begin
      //raise Exception.Create(Format('Для класса %s и события %s старый обрабатчик не найден', [LObj.ClassName, AnName]));
      Exit;
    end;

        // проверка типа события
    // To TNotifyEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiNotifyEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
      begin
        LSender := InterfaceToObject(IDispatch(AnParams[0]));
      end else
        raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      try
        LNotifyEvent^(LSender);
      except
//        on E: Exception do ShowMessage('Error');
      end;
      exit;
    end;

    // проверка типа события
    // To TKeyPressEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiKeyPressEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          if VarType(AnParams[1]) = varSmallint then
            LChar := Chr(Byte(AnParams[1]))
          else
            if VarType(AnParams[1]) = varOleStr then
              LChar := String(AnParams[1])[1]
            else begin
              raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
            end;
          LSender := InterfaceToObject(IDispatch(AnParams[0]));
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TKeyPressEvent(LNotifyEvent^)(LSender, LChar);
      AnParams[1] := Ord(LChar);
      exit;
    end;

    // To TCanResizeEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCanResizeEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          p1 := Integer(AnParams[1]);
          p2 := Integer(AnParams[2]);
          LBool := Boolean(AnParams[3]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TCanResizeEvent(LNotifyEvent^)(LSender, p1, p2, LBool);
      AnParams[3] := LBool;
      exit;
    end;

    // To TConstrainedResizeEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiConstrainedResizeEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 4) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          p1 := Integer(AnParams[1]);
          p2 := Integer(AnParams[2]);
          p3 := Integer(AnParams[3]);
          p4 := Integer(AnParams[4]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TConstrainedResizeEvent(LNotifyEvent^)(LSender, p1, p2, p3, p4);
      AnParams[1] := p1;
      AnParams[2] := p2;
      AnParams[3] := p3;
      AnParams[4] := p4;
      exit;
    end;

    // To TContextPopupEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiContextPopupEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch))
          and ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          //LPoint.x := (IDispatch(AnParams[1]) as IgsGsPoint).x;
          //LPoint.y := (IDispatch(AnParams[1]) as IgsGsPoint).y;
          LBool := Boolean(AnParams[2]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TContextPopupEvent(LNotifyEvent^)(LSender, LPoint, LBool);
      AnParams[2] := LBool;
      exit;
    end;

    // To TDragDropEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDragDropEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          p2 := Integer(AnParams[2]);
          p3 := Integer(AnParams[3]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
        LSender := InterfaceToObject(AnParams[0]);
        LSender_2 := InterfaceToObject(AnParams[1]);
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDragDropEvent(LNotifyEvent^)(LSender, LSender_2, p2, p3);
      exit;
    end;

    //!!!To TDragOverEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDragOverEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 5) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LBool := Boolean(AnParams[5]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
        LSender := InterfaceToObject(AnParams[0]);
        LSender_2 := InterfaceToObject(AnParams[1]);
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDragOverEvent(LNotifyEvent^)(LSender, LSender_2, Integer(AnParams[2]),
        Integer(AnParams[3]), TDragState(AnParams[5]), LBool);
      AnParams[5] := LBool;
      exit;
    end;

    //To TEndDragEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiEndDragEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LSender_2 := InterfaceToObject(AnParams[1]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TEndDragEvent(LNotifyEvent^)(LSender, LSender_2, Integer(AnParams[2]), Integer(AnParams[3]));
      exit;
    end;

   //To TStartDockEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiStartDockEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      LDragDockObject := InterfaceToObject(AnParams[1]) as TDragDockObject;
      TStartDockEvent(LNotifyEvent^)(LSender, LDragDockObject);
      AnParams[1] := GetGdcOLEObject(LDragDockObject) as IDispatch;
      exit;
    end;

    // To TStartDragEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiStartDragEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LDragObject := InterfaceToObject(AnParams[1]) as TDragObject;
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TStartDragEvent(LNotifyEvent^)(LSender, LDragObject);
      AnParams[1] := GetGdcOLEObject(LDragObject) as IDispatch;
      exit;
    end;

    //To TDockDropEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDockDropEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDockDropEvent(LNotifyEvent^)(LSender,
        InterfaceToObject(AnParams[1]) as TDragDockObject, Integer(AnParams[2]), Integer(AnParams[3]));
      exit;
    end;

    //To TDockOverEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDockOverEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 5) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          LBool := Boolean(AnParams[5]);
          LSender := InterfaceToObject(AnParams[0]);
          LDragDockObject := InterfaceToObject(AnParams[1]) as TDragDockObject;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;

      TDockOverEvent(LNotifyEvent^)(LSender, LDragDockObject, Integer(AnParams[2]),
        Integer(AnParams[3]), TDragState(AnParams[4]), LBool);
      AnParams[5] := LBool;
      exit;
    end;

    //To TUnDockEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiUnDockEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch) and
          (VarType(AnParams[2]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil) and
          (IDispatch(AnParams[2]) <> nil)) then
        begin
          LBool := Boolean(AnParams[3]);
          LSender := InterfaceToObject(AnParams[0]);
          LControl := InterfaceToObject(AnParams[1]) as TControl;
          LWinControl := InterfaceToObject(AnParams[2]) as TWinControl;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TUnDockEvent(LNotifyEvent^)(LSender, LControl, LWinControl, LBool);
      AnParams[3] := LBool;
      exit;
    end;

    //To TCloseEvent;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCloseEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LCloseAction := TCloseAction(AnParams[1]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
        LSender := InterfaceToObject(AnParams[0]);
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TCloseEvent(LNotifyEvent^)(LSender, LCloseAction);
      AnParams[1] := LCloseAction;
      exit;
    end;

    //To TCloseQueryEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCloseQueryEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if not ((VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil)) then
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
        LBool := Boolean(AnParams[1]);
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
        TCloseQueryEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LBool);
        AnParams[1] := LBool;
        exit;
    end;

    //To TMenuChangeEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMenuChangeEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LMenuItem := InterfaceToObject(AnParams[1]) as TMenuItem;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMenuChangeEvent(LNotifyEvent^)(LSender, LMenuItem, Boolean(AnParams[2]));
      exit;
    end;

    //To TMeasureItemEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMeasureItemEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          p2 := AnParams[2];
          LWinControl := InterfaceToObject(AnParams[0]) as TWinControl;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMeasureItemEvent(LNotifyEvent^)(LWinControl,
        Integer(AnParams[1]), p2);
      AnParams[2] := p2;
      exit;
    end;

    //To TScrollEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiScrollEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          p2 := AnParams[2];
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TScrollEvent(LNotifyEvent^)(LSender, TScrollCode(AnParams[1]), p2);
      AnParams[2] := p2;
      exit;
    end;

    //To TActionEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiActionEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LBool := AnParams[1];
          LBasicAction := InterfaceToObject(AnParams[0]) as TBasicAction;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TActionEvent(LNotifyEvent^)(LBasicAction, LBool);
      AnParams[1] := LBool;
      exit;
    end;

    //To TMovedEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMovedEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMovedEvent(LNotifyEvent^)(LSender,
        Integer(AnParams[1]), Integer(AnParams[2]));
      exit;
    end;

    //To TCheckBoxEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCheckBoxEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LBool := Boolean(AnParams[2]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TCheckBoxEvent(LNotifyEvent^)(LSender, String(AnParams[1]), LBool);
      AnParams[2] := LBool;
      exit;
    end;

    //To TAfterCheckEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiAfterCheckEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender :=  InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TAfterCheckEvent(LNotifyEvent^)(LSender, String(AnParams[1]), Boolean(AnParams[2]));
      exit;
    end;

    //To TDataSetNotifyEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDataSetNotifyEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LDataSet := InterfaceToObject(AnParams[0]) as TDataSet;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDataSetNotifyEvent(LNotifyEvent^)(LDataSet);
      exit;
    end;

    //To TDataSetErrorEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDataSetErrorEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LDataAction := TDataAction(AnParams[2]);
          LDataSet :=  InterfaceToObject(AnParams[0]) as TDataSet;
          LEDatabaseError := InterfaceToObject(AnParams[0]) as EDatabaseError;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDataSetErrorEvent(LNotifyEvent^)(LDataSet, LEDatabaseError, LDataAction);
      AnParams[2] := LDataAction;
      exit;
    end;

    //To TFilterRecordEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiFilterRecordEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LBool := Boolean(AnParams[1]);
          LDataSet := InterfaceToObject(AnParams[0]) as TDataSet;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TFilterRecordEvent(LNotifyEvent^)(LDataSet, LBool);
      AnParams[1] := LBool;
      exit;
    end;

    //To TIBUpdateErrorEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiIBUpdateErrorEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LIBUpdateAction := TIBUpdateAction(AnParams[3]);
          LDataSet := InterfaceToObject(AnParams[0]) as TDataSet;
          LEDatabaseError := InterfaceToObject(AnParams[1]) as EDatabaseError;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TIBUpdateErrorEvent(LNotifyEvent^)(LDataSet, LEDatabaseError, TUpdateKind(AnParams[2]), LIBUpdateAction);
      AnParams[3] := LIBUpdateAction;
      exit;
    end;

    //To TIBUpdateRecordEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiIBUpdateRecordEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LIBUpdateAction := TIBUpdateAction(AnParams[2]);
          LDataSet :=  InterfaceToObject(AnParams[0]) as TDataSet;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TIBUpdateRecordEvent(LNotifyEvent^)(LDataSet,
        TUpdateKind(AnParams[1]), LIBUpdateAction);
      AnParams[2] := LIBUpdateAction;
      exit;
    end;

    //To TgdcAfterInitSQL
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcAfterInitSQL) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LStr := String(AnParams[1]);
          LBool := Boolean(AnParams[2]);
          LSender := InterfaceToObject(AnParams[0]);
          TgdcAfterInitSQL(LNotifyEvent^)(LSender, LStr, LBool);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      AnParams[1] := LStr;
      AnParams[2] := LBool;
      exit;
    end;

    //To TgdcDoBeforeShowDialog
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcDoBeforeShowDialog) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LCustomForm := InterfaceToObject(AnParams[1]) as TCustomForm;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TgdcDoBeforeShowDialog(LNotifyEvent^)(LSender, LCustomForm);
      exit;
    end;

    //To TgdcDoAfterShowDialog
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcDoAfterShowDialog) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender :=  InterfaceToObject(AnParams[0]);
          LCustomForm :=  InterfaceToObject(AnParams[1]) as TCustomForm;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TgdcDoAfterShowDialog(LNotifyEvent^)(LSender, LCustomForm, Boolean(AnParams[2]));
      exit;
    end;

    //To TOnCreateNewObject
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiOnCreateNewObject) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LgdcBase := InterfaceToObject(AnParams[1]) as TgdcBase;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TOnCreateNewObject(LNotifyEvent^)(LSender, LgdcBase);
      exit;
    end;

    //To TConditionChanged
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiConditionChanged) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TConditionChanged(LNotifyEvent^)(LSender);
      exit;
    end;

    //To TFilterChanged
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiFilterChanged) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TFilterChanged(LNotifyEvent^)(LSender, Integer(AnParams[1]));
      exit;
    end;

    //To TMouseEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMouseEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 4) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMouseEvent(LNotifyEvent^)(LSender,
        TMouseButton(AnParams[1]), StrToShiftState(AnParams[2]),
        Integer(AnParams[3]), Integer(AnParams[4]));
      exit;
    end;

    //To TMouseMoveEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMouseMoveEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMouseMoveEvent(LNotifyEvent^)(LSender,
        StrToShiftState(AnParams[1]), Integer(AnParams[2]), Integer(AnParams[3]));
      exit;
    end;

    //To TKeyEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiKeyEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LWord := AnParams[1];
          LShiftState := StrToShiftState(AnParams[2]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TKeyEvent(LNotifyEvent^)(LSender, LWord, LShiftState);
      AnParams[2] := TShiftStateToStr(LShiftState);
      AnParams[1] := LWord;
      exit;
    end;

    // To TMouseWheelEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMouseWheelEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 4) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil)) then
        begin
          //LPoint.x := (IDispatch(AnParams[3]) as IgsGsPoint).x;
          //LPoint.y := (IDispatch(AnParams[3]) as IgsGsPoint).y;
          LBool := Boolean(AnParams[4]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMouseWheelEvent(LNotifyEvent^)(LSender, StrToShiftState(String(AnParams[1])),
        Integer(AnParams[2]) ,LPoint, LBool);
      AnParams[4] := LBool;
      exit;
    end;

    // To TMouseWheelUpDownEvent
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMouseWheelUpDownEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[2]) = VarDispatch) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[2]) <> nil)) then
        begin
          //LPoint.x := (IDispatch(AnParams[2]) as IgsGsPoint).x;
          //LPoint.y := (IDispatch(AnParams[2]) as IgsGsPoint).y;
          LBool := Boolean(AnParams[3]);
          LSender := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TMouseWheelUpDownEvent(LNotifyEvent^)(LSender,
        StrToShiftState(String(AnParams[1])), LPoint, LBool);
      AnParams[3] := LBool;
      exit;
    end;

    //ieOnGetFooter = 'TOnGetFooter';
    //TOnGetFooter = function (Sender: TObject; const FieldName: String; const AggregatesObsolete: Boolean): String of Object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnGetFooter) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and
          (IDispatch(AnParams[0]) <> nil) then
        begin
          LStr := String(AnParams[3]);
          LSender :=  InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TOnGetFooter(LNotifyEvent^)(LSender,
        String(AnParams[1]), Boolean(AnParams[2]), LStr);
      AnParams[3] := LStr;
      exit;
    end;

    //ieDataChangeEvent = 'TDataChangeEvent';
    //TDataChangeEvent = procedure(Sender: TObject; Field: TField) of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieDataChangeEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch) and
          (IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LField := InterfaceToObject(AnParams[1]) as TField;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TDataChangeEvent(LNotifyEvent^)(LSender, LField);
      exit;
    end;

    // TOnSyncFieldEvent = procedure((Sender: TObject; Field: TField; SyncList: TList)) of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieSyncFieldEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch) and
          (VarType(AnParams[2]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) and
          (IDispatch(AnParams[1]) <> nil) and (IDispatch(AnParams[2]) <> nil) then
        begin
          LSender := InterfaceToObject(AnParams[0]);
          LField := InterfaceToObject(AnParams[1]) as TField;
          LList := InterfaceToObject(AnParams[2]) as TList;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TOnSyncFieldEvent(LNotifyEvent^)(LSender, LField, LList);
      exit;
    end;

    //TFieldGetTextEvent = procedure(Sender: TField; var Text: String; DisplayText: Boolean)
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieFieldGetTextEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 2) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LField := InterfaceToObject(AnParams[0]) as TField;
          LStr := String(AnParams[1]);
          LBool := Boolean(AnParams[2]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TFieldGetTextEvent(LNotifyEvent^)(LField, LStr, LBool);
      AnParams[1] := LStr;
      exit;
    end;

    //TFieldSetTextEvent = procedure(Sender: TField; const Text: String)
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieFieldSetTextEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 1) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LField := InterfaceToObject(AnParams[0]) as TField;
          LStr := String(AnParams[1]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TFieldSetTextEvent(LNotifyEvent^)(LField, LStr);
      exit;
    end;

    //TFieldNotifyEvent = procedure(Sender: TField) of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieFieldNotifyEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LField := InterfaceToObject(AnParams[0]) as TField;
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TFieldNotifyEvent(LNotifyEvent^)(LField);
      exit;
    end;

    //TOnTestCorrect = function(Sender: TObject): Boolean of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnTestCorrect) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LObj := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      Result := TOnTestCorrect(LNotifyEvent^)(LObj);
      exit;
    end;

    //TOnSetupRecord = procedure function(Sender: TObject): of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnTestCorrect) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LObj := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TOnSetupRecord(LNotifyEvent^)(LObj);
      exit;
    end;

    //TOnSetupDialog = procedure function(Sender: TObject): of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnTestCorrect) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LObj := InterfaceToObject(AnParams[0]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TOnSetupDialog(LNotifyEvent^)(LObj);
      exit;
    end;

    //TgdcOnGetSQLClause = procedure(Sender: TObject; var Clause: String) of Object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnTestCorrect) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LObj := InterfaceToObject(AnParams[0]);
          LStr := String(AnParams[1]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TgdcOnGetSQLClause(LNotifyEvent^)(LObj, LStr);
      AnParams[0] := LStr;
      exit;
    end;

    //TTabChangingEvent = procedure (Sender: TObject; var AllowChange: Boolean) of object;
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(ieOnTestCorrect) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 0) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and (IDispatch(AnParams[0]) <> nil) then
        begin
          LObj := InterfaceToObject(AnParams[0]);
          LBool := Boolean(AnParams[1]);
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
      except
        on EIncorrectParams do raise;
        else
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
      TTabChangingEvent(LNotifyEvent^)(LObj, LBool);
      AnParams[1] := LBool;
      exit;
    end;

    //TDrawItemEvent = procedure(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDrawItemEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if (VarType(AnParams[0]) = VarDispatch) and
          (IDispatch(AnParams[0]) <> nil) then
        begin
          LRect.Left := (IDispatch(AnParams[2]) as IgsGsRect).Left;
          LRect.Right := (IDispatch(AnParams[2]) as IgsGsRect).Right;
          LRect.Top := (IDispatch(AnParams[2]) as IgsGsRect).Top;
          LRect.Bottom := (IDispatch(AnParams[2]) as IgsGsRect).Bottom;
          TDrawItemEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]) as TWinControl,
            Integer(AnParams[1]), LRect, StrToTOwnerDrawState(String(AnParams[3])));
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, AnName]));
        exit;
      except
        raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
    end;

    //'TDrawDataCellEvent' = procedure(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDrawDataCellEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch) and (VarType(AnParams[2]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil) and (IDispatch(AnParams[2]) <> nil)) then
        begin
          LRect.Left := (IDispatch(AnParams[1]) as IgsGsRect).Left;
          LRect.Right := (IDispatch(AnParams[1]) as IgsGsRect).Right;
          LRect.Top := (IDispatch(AnParams[1]) as IgsGsRect).Top;
          LRect.Bottom := (IDispatch(AnParams[1]) as IgsGsRect).Bottom;
          TDrawDataCellEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LRect,
            InterfaceToObject(AnParams[2]) as TField, StrToTGridDrawState(String(AnParams[3])));
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты'
          , [LObj.ClassName, AnName]));
        exit;
      except
        raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
    end;

    //'TDrawColumnCellEvent' = procedure(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDrawColumnCellEvent) then
    begin
      // проверка количества параметров, переданных для события
      if not (VarArrayHighBound(AnParams, 1) = 3) then
        raise ECountParams.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, AnName]));
      // передаются параметры из EventInherited и вызывается обработчик Delphi
      try
        if ((VarType(AnParams[0]) = VarDispatch) and (VarType(AnParams[1]) = VarDispatch) and (VarType(AnParams[3]) = VarDispatch)) and
          ((IDispatch(AnParams[0]) <> nil) and (IDispatch(AnParams[1]) <> nil) and (IDispatch(AnParams[3]) <> nil)) then
        begin
          LRect.Left := (IDispatch(AnParams[1]) as IgsGsRect).Left;
          LRect.Right := (IDispatch(AnParams[1]) as IgsGsRect).Right;
          LRect.Top := (IDispatch(AnParams[1]) as IgsGsRect).Top;
          LRect.Bottom := (IDispatch(AnParams[1]) as IgsGsRect).Bottom;
          TDrawColumnCellEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LRect,
            Integer(AnParams[2]), InterfaceToObject(AnParams[3]) as TColumn, StrToTGridDrawState(String(AnParams[4])));
        end else
          raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты'
          , [LObj.ClassName, AnName]));
        exit;
      except
        raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
      end;
    end;

  except
    on E: Exception do
    begin
      // При возврате ошибки из Делфи
      // создается объект-исключение gdScrException и исключение передается дальше
      if not Assigned(gdScrException) then
        gdScrException := ExceptionCopier(E);
      raise;
    end;
  end;
end;

end.
