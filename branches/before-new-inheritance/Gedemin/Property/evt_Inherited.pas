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
//  LCodeOldMetod: Pointer;
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
  LParentEventObject: TEventObject;
  LParentEventOfObject: TEventItem;
  ResetCurIndex: boolean;
begin
  try
    ResetCurIndex := False;
    LParentEventObject := nil;

    LObj := TObject(AnObject.Get_Self);
    LEventObject := FEventControl.EventObjectList.FindAllObject(LObj as TComponent);
    if not Assigned(LEventObject) then
      raise Exception.Create(Format('Класс %s не найден в списке EventControl', [LObj.ClassName]));

    try
      // поиск обработчика события родителя
      if Assigned(LEventObject) then
      begin
        if LEventObject.ParentObjectsBySubType.Count > 0 then
        begin
          if LEventObject.CurIndexParentObject = -1 then
            ResetCurIndex := True;
          LParentEventOfObject := nil;
          repeat
            if (LEventObject.CurIndexParentObject < LEventObject.ParentObjectsBySubType.Count - 1) then
            begin
              LEventObject.CurIndexParentObject := LEventObject.CurIndexParentObject + 1;
              LParentEventObject :=
                LEventObject.ParentObjectsBySubType.EventObject[LEventObject.CurIndexParentObject];
              LParentEventOfObject :=
                LParentEventObject.EventList.Find(AnName);
            end
            else
            begin
              LEventObject.CurIndexParentObject := -1;
              LParentEventObject := nil;
            end;
          until (LEventObject.CurIndexParentObject = -1)
            or ((LParentEventOfObject <> nil)
                 and (LParentEventOfObject.FunctionKey <> 0)
                 and (not LParentEventOfObject.Disable)
                 and (not LParentEventOfObject.IsParental));
        end;
      end;

      // сохранение адреса Delphi обработчика события
      LNotifyEvent := nil;
      try
        LNotifyEvent := @LEventObject.EventList.Find(AnName).OldEvent.Code;
      except
  //        LCodeOldMetod := nil;
      end;
      if (not (Assigned(LNotifyEvent))) or (not Assigned(LNotifyEvent^)) then
      begin
  //        raise Exception.Create(Format('Для класса %s и события %s старый обрабатчик не найден', [LObj.ClassName, AnName]));
        if (not Assigned(LParentEventObject)) then
          Exit;
      end;

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
        // вызов события родителя, если оно существует
          if LParentEventObject <> nil then
          begin
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClick') then
            begin
              FEventControl.OnClick(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnPopup') then
            begin
              FEventControl.OnPopup(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCreate') then
            begin
              FEventControl.OnCreate(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDblClick') then
            begin
              FEventControl.OnDblClick(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnResize') then
            begin
              FEventControl.OnResize(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnEnter') then
            begin
              FEventControl.OnEnter(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnExit') then
            begin
              FEventControl.OnExit(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnActivate') then
            begin
              FEventControl.OnActivate(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClose') then
            begin
              FEventControl.OnCloseNotify(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDeactivate') then
            begin
              FEventControl.OnDeactivate(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDestroy') then
            begin
              FEventControl.OnDestroy(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnHide') then
            begin
              FEventControl.OnHide(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnPaint') then
            begin
              FEventControl.OnPaint(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnShow') then
            begin
              FEventControl.OnShow(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnChange') then
            begin
              FEventControl.OnChangeEdit(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClickCheck') then
            begin
              FEventControl.OnClickCheckListBox(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDropDown') then
            begin
              FEventControl.OnDropDown(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnExecute') then
            begin
              FEventControl.OnExecuteAction(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUpdate') then
            begin
              FEventControl.OnUpdateAction(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMove') then
            begin
              FEventControl.OnMove(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnRecreated') then
            begin
              FEventControl.OnRecreated(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnRecreating') then
            begin
              FEventControl.OnRecreating(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDockChanged') then
            begin
              FEventControl.OnDockChanged(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDockChanging') then
            begin
              FEventControl.OnDockChanging(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDockChangingHidden') then
            begin
              FEventControl.OnDockChangingHidden(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnVisibleChanged') then
            begin
              FEventControl.OnVisibleChanged(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnColEnter') then
            begin
              FEventControl.OnColEnter(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnColExit') then
            begin
              FEventControl.OnColExit(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnEditButtonClick') then
            begin
              FEventControl.OnEditButtonClick(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnAggregateChanged') then
            begin
              FEventControl.OnAggregateChanged(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterDatabaseDisconnect') then
            begin
              FEventControl.AfterDatabaseDisconnect(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterTransactionEnd') then
            begin
              FEventControl.AfterTransactionEnd(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeDatabaseDisconnect') then
            begin
              FEventControl.BeforeDatabaseDisconnect(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeTransactionEnd') then
            begin
              FEventControl.BeforeTransactionEnd(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('DatabaseFree') then
            begin
              FEventControl.DatabaseFree(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('TransactionFree') then
            begin
              FEventControl.TransactionFree(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('DatabaseDisconnected') then
            begin
              FEventControl.DatabaseDisconnected(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('DatabaseDisconnecting') then
            begin
              FEventControl.DatabaseDisconnecting(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnFilterChanged') then
            begin
              FEventControl.OnFilterChanged(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnStateChange') then
            begin
              FEventControl.OnStateChange(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUpdateData') then
            begin
              FEventControl.OnUpdateData(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnTimer') then
            begin
              FEventControl.OnTimer(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnSaveSettings') then
            begin
              FEventControl.OnSaveSettings(LSender);
//              exit;
            end;
            if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnLoadSettingsAfterCreate') then
            begin
              FEventControl.OnLoadSettingsAfterCreate(LSender);
//              exit;
            end;
          end;
          if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
          begin
            LNotifyEvent^(LSender);
          end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnKeyPress') then
          begin
            FEventControl.OnKeyPress(LSender, LChar);
            AnParams[1] := Ord(LChar);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TKeyPressEvent(LNotifyEvent^)(LSender, LChar);
          AnParams[1] := Ord(LChar);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCanResize') then
          begin
            FEventControl.OnCanResize(LSender, p1, p2, LBool);
            AnParams[3] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TCanResizeEvent(LNotifyEvent^)(LSender, p1, p2, LBool);
          AnParams[3] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnConstrainedResize') then
          begin
            FEventControl.OnConstrainedResize(LSender, p1, p2, p3, p4);
            AnParams[1] := p1;
            AnParams[2] := p2;
            AnParams[3] := p3;
            AnParams[4] := p4;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TConstrainedResizeEvent(LNotifyEvent^)(LSender, p1, p2, p3, p4);
          AnParams[1] := p1;
          AnParams[2] := p2;
          AnParams[3] := p3;
          AnParams[4] := p4;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnContextPopup') then
          begin
            FEventControl.OnContextPopup(LSender, LPoint, LBool);
            AnParams[2] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TContextPopupEvent(LNotifyEvent^)(LSender, LPoint, LBool);
          AnParams[2] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDragDrop') then
          begin
            FEventControl.OnDragDrop(LSender, LSender_2, p2, p3);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDragDropEvent(LNotifyEvent^)(LSender, LSender_2, p2, p3);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDragOver') then
          begin
            FEventControl.OnDragOver(LSender, LSender_2, Integer(AnParams[2]),
              Integer(AnParams[3]), TDragState(AnParams[5]), LBool);
            AnParams[5] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDragOverEvent(LNotifyEvent^)(LSender, LSender_2, Integer(AnParams[2]),
            Integer(AnParams[3]), TDragState(AnParams[5]), LBool);
          AnParams[5] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnEndDock') then
          begin
            FEventControl.OnEndDock(LSender, LSender_2, Integer(AnParams[2]), Integer(AnParams[3]));
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnEndDrag') then
          begin
            FEventControl.OnEndDrag(LSender, LSender_2, Integer(AnParams[2]), Integer(AnParams[3]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TEndDragEvent(LNotifyEvent^)(LSender, LSender_2, Integer(AnParams[2]), Integer(AnParams[3]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnStartDock') then
          begin
            FEventControl.OnStartDock(LSender, LDragDockObject);
            AnParams[1] := GetGdcOLEObject(LDragDockObject) as IDispatch;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TStartDockEvent(LNotifyEvent^)(LSender, LDragDockObject);
          AnParams[1] := GetGdcOLEObject(LDragDockObject) as IDispatch;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnStartDrag') then
          begin
            FEventControl.OnStartDrag(LSender, LDragObject);
            AnParams[1] := GetGdcOLEObject(LDragObject) as IDispatch;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TStartDragEvent(LNotifyEvent^)(LSender, LDragObject);
          AnParams[1] := GetGdcOLEObject(LDragObject) as IDispatch;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDockDrop') then
          begin
            FEventControl.OnDockDrop(LSender,
              InterfaceToObject(AnParams[1]) as TDragDockObject, Integer(AnParams[2]), Integer(AnParams[3]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDockDropEvent(LNotifyEvent^)(LSender,
            InterfaceToObject(AnParams[1]) as TDragDockObject, Integer(AnParams[2]), Integer(AnParams[3]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDockOver') then
          begin
            FEventControl.OnDockOver(LSender, LDragDockObject, Integer(AnParams[2]),
              Integer(AnParams[3]), TDragState(AnParams[4]), LBool);
            AnParams[5] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDockOverEvent(LNotifyEvent^)(LSender, LDragDockObject, Integer(AnParams[2]),
            Integer(AnParams[3]), TDragState(AnParams[4]), LBool);
          AnParams[5] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUnDock') then
          begin
            FEventControl.OnUnDock(LSender, LControl, LWinControl, LBool);
            AnParams[3] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TUnDockEvent(LNotifyEvent^)(LSender, LControl, LWinControl, LBool);
          AnParams[3] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClose') then
          begin
            FEventControl.OnClose(LSender, LCloseAction);
            AnParams[1] := LCloseAction;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TCloseEvent(LNotifyEvent^)(LSender, LCloseAction);
          AnParams[1] := LCloseAction;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCloseQuery') then
          begin
            FEventControl.OnCloseQuery(InterfaceToObject(AnParams[0]), LBool);
            AnParams[1] := LCloseAction;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TCloseQueryEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LBool);
          AnParams[1] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnChange') then
          begin
            FEventControl.OnChange(LSender, LMenuItem, Boolean(AnParams[2]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMenuChangeEvent(LNotifyEvent^)(LSender, LMenuItem, Boolean(AnParams[2]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMeasureItem') then
          begin
            FEventControl.OnMeasureItem(LWinControl,
              Integer(AnParams[1]), p2);
            AnParams[2] := p2;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMeasureItemEvent(LNotifyEvent^)(LWinControl,
            Integer(AnParams[1]), p2);
          AnParams[2] := p2;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnScroll') then
          begin
            FEventControl.OnScroll(LSender, TScrollCode(AnParams[1]), p2);
            AnParams[2] := p2;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TScrollEvent(LNotifyEvent^)(LSender, TScrollCode(AnParams[1]), p2);
          AnParams[2] := p2;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnExecute') then
          begin
            FEventControl.OnExecute(LBasicAction, LBool);
            AnParams[1] := LBool;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUpdate') then
          begin
            FEventControl.OnUpdate(LBasicAction, LBool);
            AnParams[1] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TActionEvent(LNotifyEvent^)(LBasicAction, LBool);
          AnParams[1] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnColumnMoved') then
          begin
            FEventControl.OnColumnMoved(LSender,
              Integer(AnParams[1]), Integer(AnParams[2]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMovedEvent(LNotifyEvent^)(LSender,
            Integer(AnParams[1]), Integer(AnParams[2]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClickCheck') then
          begin
            FEventControl.OnClickCheck(LSender, String(AnParams[1]), LBool);
              AnParams[2] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TCheckBoxEvent(LNotifyEvent^)(LSender, String(AnParams[1]), LBool);
          AnParams[2] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnClickedCheck') then
          begin
            FEventControl.OnClickedCheck(LSender, String(AnParams[1]), Boolean(AnParams[2]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TAfterCheckEvent(LNotifyEvent^)(LSender, String(AnParams[1]), Boolean(AnParams[2]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterCancel') then
          begin
            FEventControl.AfterCancel(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterClose') then
          begin
            FEventControl.AfterClose(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterDelete') then
          begin
            FEventControl.AfterDelete(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterEdit') then
          begin
            FEventControl.AfterEdit(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterInsert') then
          begin
            FEventControl.AfterInsert(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterOpen') then
          begin
            FEventControl.AfterOpen(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterPost') then
          begin
            FEventControl.AfterPost(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterRefresh') then
          begin
            FEventControl.AfterRefresh(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterScroll') then
          begin
            FEventControl.AfterScroll(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeCancel') then
          begin
            FEventControl.BeforeCancel(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeClose') then
          begin
            FEventControl.BeforeClose(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeDelete') then
          begin
            FEventControl.BeforeDelete(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeEdit') then
          begin
            FEventControl.BeforeEdit(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeInsert') then
          begin
            FEventControl.BeforeInsert(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeOpen') then
          begin
            FEventControl.BeforeOpen(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforePost') then
          begin
            FEventControl.BeforePost(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeScroll') then
          begin
            FEventControl.BeforeScroll(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCalcFields') then
          begin
            FEventControl.OnCalcFields(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnNewRecord') then
          begin
            FEventControl.OnNewRecord(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterInternalPostRecord') then
          begin
            FEventControl.AfterInternalPostRecord(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeInternalPostRecord') then
          begin
            FEventControl.BeforeInternalPostRecord(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterInternalDeleteRecord') then
          begin
            FEventControl.AfterInternalDeleteRecord(LDataSet);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeInternalDeleteRecord') then
          begin
            FEventControl.BeforeInternalDeleteRecord(LDataSet);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDataSetNotifyEvent(LNotifyEvent^)(LDataSet);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDeleteError') then
          begin
            FEventControl.OnDeleteError(LDataSet, LEDatabaseError, LDataAction);
              AnParams[2] := LDataAction;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnEditError') then
          begin
            FEventControl.OnEditError(LDataSet, LEDatabaseError, LDataAction);
              AnParams[2] := LDataAction;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnPostError') then
          begin
            FEventControl.OnPostError(LDataSet, LEDatabaseError, LDataAction);
              AnParams[2] := LDataAction;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDataSetErrorEvent(LNotifyEvent^)(LDataSet, LEDatabaseError, LDataAction);
          AnParams[2] := LDataAction;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnFilterRecord') then
          begin
            FEventControl.OnFilterRecord(LDataSet, LBool);
            AnParams[1] := LBool;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCalcAggregates') then
          begin
            FEventControl.OnCalcAggregates(LDataSet, LBool);
            AnParams[1] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TFilterRecordEvent(LNotifyEvent^)(LDataSet, LBool);
          AnParams[1] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUpdateError') then
          begin
            FEventControl.OnUpdateError(LDataSet, LEDatabaseError, TUpdateKind(AnParams[2]), LIBUpdateAction);
            AnParams[3] := LIBUpdateAction;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TIBUpdateErrorEvent(LNotifyEvent^)(LDataSet, LEDatabaseError, TUpdateKind(AnParams[2]), LIBUpdateAction);
          AnParams[3] := LIBUpdateAction;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnUpdateRecord') then
          begin
            FEventControl.OnUpdateRecord(LDataSet,
              TUpdateKind(AnParams[1]), LIBUpdateAction);
            AnParams[2] := LIBUpdateAction;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TIBUpdateRecordEvent(LNotifyEvent^)(LDataSet,
            TUpdateKind(AnParams[1]), LIBUpdateAction);
          AnParams[2] := LIBUpdateAction;
        end;
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
            if LParentEventObject <> nil then
            begin
              if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnAfterInitSQL') then
              begin
                FEventControl.OnAfterInitSQL(LSender, LStr, LBool);
                AnParams[1] := LStr;
                AnParams[2] := LBool;
//                exit;
              end;
            end;
            if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
            begin
              TgdcAfterInitSQL(LNotifyEvent^)(LSender, LStr, LBool);
            end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('BeforeShowDialog') then
          begin
            FEventControl.BeforeShowDialog(LSender, LCustomForm);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TgdcDoBeforeShowDialog(LNotifyEvent^)(LSender, LCustomForm);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('AfterShowDialog') then
          begin
            FEventControl.AfterShowDialog(LSender, LCustomForm, Boolean(AnParams[2]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TgdcDoAfterShowDialog(LNotifyEvent^)(LSender, LCustomForm, Boolean(AnParams[2]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnCreateNewObject') then
          begin
            FEventControl.OnCreateNewObject(LSender, LgdcBase);
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnAfterCreateDialog') then
          begin
            FEventControl.OnAfterCreateDialog(LSender, LgdcBase);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TOnCreateNewObject(LNotifyEvent^)(LSender, LgdcBase);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnConditionChanged') then
          begin
            FEventControl.OnConditionChanged(LSender);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TConditionChanged(LNotifyEvent^)(LSender);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnFilterChanged') then
          begin
            FEventControl.OnFilterChangedSQLFilter(LSender, Integer(AnParams[1]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TFilterChanged(LNotifyEvent^)(LSender, Integer(AnParams[1]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseDown') then
          begin
            FEventControl.OnMouseDown(LSender,
              TMouseButton(AnParams[1]), StrToShiftState(AnParams[2]),
              Integer(AnParams[3]), Integer(AnParams[4]));
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseUp') then
          begin
            FEventControl.OnMouseUp(LSender,
              TMouseButton(AnParams[1]), StrToShiftState(AnParams[2]),
              Integer(AnParams[3]), Integer(AnParams[4]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMouseEvent(LNotifyEvent^)(LSender,
            TMouseButton(AnParams[1]), StrToShiftState(AnParams[2]),
            Integer(AnParams[3]), Integer(AnParams[4]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseMove') then
          begin
            FEventControl.OnMouseMove(LSender,
              StrToShiftState(AnParams[1]), Integer(AnParams[2]), Integer(AnParams[3]));
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMouseMoveEvent(LNotifyEvent^)(LSender,
            StrToShiftState(AnParams[1]), Integer(AnParams[2]), Integer(AnParams[3]));
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnKeyDown') then
          begin
            FEventControl.OnKeyDown(LSender, LWord, LShiftState);
            AnParams[2] := TShiftStateToStr(LShiftState);
            AnParams[1] := LWord;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnKeyUp') then
          begin
            FEventControl.OnKeyUp(LSender, LWord, LShiftState);
            AnParams[2] := TShiftStateToStr(LShiftState);
            AnParams[1] := LWord;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TKeyEvent(LNotifyEvent^)(LSender, LWord, LShiftState);
          AnParams[2] := TShiftStateToStr(LShiftState);
          AnParams[1] := LWord;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseWheel') then
          begin
            FEventControl.OnMouseWheel(LSender, StrToShiftState(String(AnParams[1])),
              Integer(AnParams[2]) ,LPoint, LBool);
            AnParams[4] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TMouseWheelEvent(LNotifyEvent^)(LSender, StrToShiftState(String(AnParams[1])),
            Integer(AnParams[2]) ,LPoint, LBool);
          AnParams[4] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseWheelDown') then
          begin
            FEventControl.OnMouseWheelDown(LSender,
              StrToShiftState(String(AnParams[1])), LPoint, LBool);
            AnParams[3] := LBool;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnMouseWheelUp') then
          begin
            FEventControl.OnMouseWheelUp(LSender,
              StrToShiftState(String(AnParams[1])), LPoint, LBool);
            AnParams[3] := LBool;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
        TMouseWheelUpDownEvent(LNotifyEvent^)(LSender,
          StrToShiftState(String(AnParams[1])), LPoint, LBool);
        AnParams[3] := LBool;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetFooter') then
          begin
            FEventControl.OnGetFooter(LSender,
              String(AnParams[1]), Boolean(AnParams[2]), LStr);
            AnParams[3] := LStr;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TOnGetFooter(LNotifyEvent^)(LSender,
            String(AnParams[1]), Boolean(AnParams[2]), LStr);
          AnParams[3] := LStr;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDataChange') then
          begin
            FEventControl.OnDataChange(LSender, LField);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TDataChangeEvent(LNotifyEvent^)(LSender, LField);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnSyncField') then
          begin
            FEventControl.OnSyncField(LSender, LField, LList);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TOnSyncFieldEvent(LNotifyEvent^)(LSender, LField, LList);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetText') then
          begin
            FEventControl.OnGetText(LField, LStr, LBool);
            AnParams[1] := LStr;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TFieldGetTextEvent(LNotifyEvent^)(LField, LStr, LBool);
          AnParams[1] := LStr;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnSetText') then
          begin
            FEventControl.OnSetText(LField, LStr);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TFieldSetTextEvent(LNotifyEvent^)(LField, LStr);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnValidate') then
          begin
            FEventControl.OnValidate(LField);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TFieldNotifyEvent(LNotifyEvent^)(LField);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnTestCorrect') then
          begin
            Result := FEventControl.OnTestCorrect(LObj);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          Result := TOnTestCorrect(LNotifyEvent^)(LObj);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnSetupRecord') then
          begin
            FEventControl.OnSetupRecord(LObj);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TOnSetupRecord(LNotifyEvent^)(LObj);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnSetupDialog') then
          begin
            FEventControl.OnSetupDialog(LObj);
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TOnSetupDialog(LNotifyEvent^)(LObj);
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetSelectClause') then
          begin
            FEventControl.OnGetSelectClause(LObj, LStr);
            AnParams[0] := LStr;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetFromClause') then
          begin
            FEventControl.OnGetFromClause(LObj, LStr);
            AnParams[0] := LStr;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetWhereClause') then
          begin
            FEventControl.OnGetWhereClause(LObj, LStr);
            AnParams[0] := LStr;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetGroupClause') then
          begin
            FEventControl.OnGetGroupClause(LObj, LStr);
            AnParams[0] := LStr;
//            exit;
          end;
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnGetOrderClause') then
          begin
            FEventControl.OnGetOrderClause(LObj, LStr);
            AnParams[0] := LStr;
//            exit;
          end;
        end;
        if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
        begin
          TgdcOnGetSQLClause(LNotifyEvent^)(LObj, LStr);
          AnParams[0] := LStr;
        end;
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
        if LParentEventObject <> nil then
        begin
          if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnChanging') then
          begin
            FEventControl.OnChanging(LObj, LBool);
            AnParams[1] := LBool;
            exit;
          end;
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
            if LParentEventObject <> nil then
            begin
              if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDrawItem') then
              begin
                FEventControl.OnDrawItem(InterfaceToObject(AnParams[0]) as TWinControl,
                  Integer(AnParams[1]), LRect, StrToTOwnerDrawState(String(AnParams[3])));
//                exit;
              end;
            end;
            if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
            begin
              TDrawItemEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]) as TWinControl,
                Integer(AnParams[1]), LRect, StrToTOwnerDrawState(String(AnParams[3])));
            end;
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
            if LParentEventObject <> nil then
            begin
              if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDrawDataCell') then
              begin
                FEventControl.OnDrawDataCell(InterfaceToObject(AnParams[0]), LRect,
                  InterfaceToObject(AnParams[2]) as TField, StrToTGridDrawState(String(AnParams[3])));
//                exit;
              end;
            end;
            if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
            begin
              TDrawDataCellEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LRect,
                InterfaceToObject(AnParams[2]) as TField, StrToTGridDrawState(String(AnParams[3])));
            end;
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
            if LParentEventObject <> nil then
            begin
              if  AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase('OnDrawColumnCell') then
              begin
                FEventControl.OnDrawColumnCell(InterfaceToObject(AnParams[0]), LRect,
                  Integer(AnParams[2]), InterfaceToObject(AnParams[3]) as TColumn, StrToTGridDrawState(String(AnParams[4])));
//                exit;
              end;
            end;
            if (Assigned(LNotifyEvent)) and (Assigned(LNotifyEvent^)) then
            begin
              TDrawColumnCellEvent(LNotifyEvent^)(InterfaceToObject(AnParams[0]), LRect,
                Integer(AnParams[2]), InterfaceToObject(AnParams[3]) as TColumn, StrToTGridDrawState(String(AnParams[4])));
            end;
          end else
            raise EIncorrectParams.Create(Format('Для класса %s и события %s не переданы объекты'
            , [LObj.ClassName, AnName]));
          exit;
        except
          raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, AnName]));
        end;
      end;
    finally
      if ResetCurIndex then
        LEventObject.CurIndexParentObject := -1
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
