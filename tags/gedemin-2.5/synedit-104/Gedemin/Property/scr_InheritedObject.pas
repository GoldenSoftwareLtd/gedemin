unit scr_InheritedObject;

interface

uses
  Gedemin_TLB, obj_ObjectEvent, ActiveX, Classes, Dialogs,
  obj_Inherited, evt_Base, evt_i_Inherited, evt_i_Base,
  obj_WrapperDelphiClasses;

type
  TOnMethod = procedure (Sender: TObject; const Name: WideString;
    var Params, Result: OleVariant);

type
  PExecuteFunction = ^TExecuteFunction;
  TExecuteFunction = record
    Id: Integer;
    Executed: Boolean;
    Sender: TClass;
  end;


type
  TInheritedObject = class(TwrpObject, IgsInheritedObject)
  private
    FEventControl: TEventControl;
    FExecuteFunction: TList;
    FFunctionListFilled: Boolean;
    FClassName: String;
    FMethodName: String;
  protected
    procedure Event(const Sender: IgsObject; const Name: WideString; var Parameters: OleVariant); safecall;
    procedure Method(const Sender: IgsObject; const Name: WideString;
      var Parameters, Results: OleVariant); safecall;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReloadMethodsList; safecall;
  end;

implementation

uses
  comobj,               SysUtils,                       Windows,
  TypInfo,              Controls,                       ComServ,
  gdcOLEClassList,      forms,                          menus,
  stdctrls,             Actnlist,                       grids,
  gsDBGrid,             DB,                             IBCustomDataSet,
  gdcBase,              gsIBLookupComboBox,             flt_sqlfilter_condition_type,
  gdcObject,            mtd_i_Base,                     IBDataBase,
  gdcBaseInterface,     gdcConstants;


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

{ TEvtInherited }

constructor TInheritedObject.Create;
//var
//  I: Integer;
begin
  inherited Create(nil);

  FEventControl :=  EventControl.Get_Self as TEventControl;
  FExecuteFunction := TList.Create;
end;

destructor TInheritedObject.Destroy;
begin
  while FExecuteFunction.Count > 0 do
  begin
    FreeMem(FExecuteFunction.Last, SizeOf(TExecuteFunction));
    FExecuteFunction.Delete(FExecuteFunction.Count - 1);
  end;
  FExecuteFunction.Free;
  inherited;
end;

procedure TInheritedObject.Event(const Sender: IgsObject;
  const Name: WideString; var Parameters: OleVariant);
var
//  LDisp: IDispatch;
  LObj: TObject;
  LEventObject: TEventObject;
  LCodeOldMetod: Pointer;
  PNotifyEvent: ^TNotifyEvent;
  TempPropList: TPropList;
  LCloseAction: TCloseAction;
  LDragDockObject: TDragDockObject;
  LDragObject: TDragObject;
  LPoint: TPoint;
  I, J: Integer;
  LBool: Boolean;
  p1, p2, p3, p4: integer;
  LStr: String;
  LVar: Variant;
  LChar: Char;
  LDataAction: TDataAction;
  LIBUpdateAction: TIBUpdateAction;
  Params: Variant;
begin
//  Assert((Length(Params) = 3) and (VarType(Params[0]) = varDispatch)
//    and (VarType(Params[1]) = varOleStr) and (VarType(Params[2]) = $200C), 'Wrong parametrs count');
  try
//    LDisp := Params[0];
//    case DispID of
//      1:

      Params := VarArrayOf([Sender, Name, Parameters]);
      begin
        LObj := TObject(Sender.Get_Self);
        LEventObject := FEventControl.EventObjectList.FindAllObject(LObj as TComponent);
        if not Assigned(LEventObject) then
          raise Exception.Create(Format('Класс %s не найден в списке EventControl', [LObj.ClassName]));

        // сохранение адреса Delphi обработчика события
        try
          LCodeOldMetod := LEventObject.EventList.Find(String(Params[1])).OldEvent.Code;
        except
          LCodeOldMetod := nil;
        end;
        if not Assigned(LCodeOldMetod) then
          raise Exception.Create(Format('Для класса %s и события %s старый обрабатчик не найден', [LObj.ClassName, String(Params[1])]));

        // поиск события для данного класса по имени
        j := GetPropList(LObj.ClassInfo, [tkMethod], @TempPropList);
        for i := 0 to j do
          if AnsiUpperCase(TempPropList[I]^.Name) = AnsiUpperCase(String(Params[1])) then
            Break;
        if i = (j+1) then
          raise Exception.Create(Format('Для класса %s событие %s не определено', [LObj.ClassName, String(Params[1])]));

        // передается старый адрес обработчика события
        PNotifyEvent := @LCodeOldMetod;

        // проверка типа события
        // To TNotifyEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiNotifyEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 0) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          if VarType(LVar[0]) = VarDispatch then
            PNotifyEvent^(InterfaceToObject(IDispatch(LVar[0])))
          else
            raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
          exit;
        end;

        // проверка типа события
        // To TKeyPressEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiKeyPressEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LChar := Chr(Byte(LVar[1]));
              TKeyPressEvent(PNotifyEvent^)(InterfaceToObject(IDispatch(LVar[0])), LChar);
              LVar[1] := Ord(LChar);
              Parameters := OleVariant(LVar);
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
        // To TCanResizeEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCanResizeEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if (VarType(LVar[0]) = VarDispatch) then
            begin
              p1 := Integer(LVar[1]);
              p2 := Integer(LVar[2]);
              LBool := Boolean(LVar[3]);
              TCanResizeEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), p1, p2, LBool);
              LVar[3] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        // To TConstrainedResizeEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiConstrainedResizeEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 4) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              p1 := Integer(LVar[1]);
              p2 := Integer(LVar[2]);
              p3 := Integer(LVar[3]);
              p4 := Integer(LVar[4]);
//              LEventConstrainedResize^(InterfaceToObject(LVar[0]), p1, p2, p3, p4);
              TConstrainedResizeEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), p1, p2, p3, p4);
              LVar[1] := p1;
              LVar[2] := p2;
              LVar[3] := p3;
              LVar[4] := p4;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        // To TContextPopupEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiContextPopupEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((LVar[0] = VarDispatch) and (LVar[1] = VarDispatch)) then
            begin
              LPoint.x := (IDispatch(LVar[1]) as IgsPoint).x;
              LPoint.y := (IDispatch(LVar[1]) as IgsPoint).y;
              LBool := Boolean(LVar[2]);
//              LEventContextPopup^(InterfaceToObject(LVar[0]), LPoint, LBool);
              TContextPopupEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), LPoint, LBool);
              LVar[2] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        // To TDragDropEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDragDropEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              p2 := Integer(LVar[2]);
              p3 := Integer(LVar[3]);
              TDragDropEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]), p2, p3);
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //!!!To TDragOverEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDragOverEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 5) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
//              LDragState := TDragState(LVar[4]);
              LBool := Boolean(LVar[5]);
              TDragOverEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]), Integer(LVar[2]), Integer(LVar[3]),
                TDragState(LVar[5]), LBool);
              LVar[5] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TEndDragEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiEndDragEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              TEndDragEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]), Integer(LVar[2]), Integer(LVar[3]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

       //To TStartDockEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiStartDockEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              LDragDockObject := InterfaceToObject(LVar[1]) as TDragDockObject;
              TStartDockEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), LDragDockObject);
              LVar[1] := GetGdcOLEObject(LDragDockObject) as IDispatch;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        // To TStartDragEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiStartDragEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              LDragObject := InterfaceToObject(LVar[1]) as TDragObject;
              TStartDragEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), LDragObject);
              LVar[1] := GetGdcOLEObject(LDragObject) as IDispatch;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TDockDropEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDockDropEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              TDockDropEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TDragDockObject, Integer(LVar[2]), Integer(LVar[3]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TDockOverEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDockOverEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 5) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch)) then
            begin
              LBool := Boolean(LVar[5]);
              TDockOverEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TDragDockObject, Integer(LVar[2]),
                Integer(LVar[3]), TDragState(LVar[4]), LBool);
              LVar[5] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TUnDockEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiUnDockEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if ((VarType(LVar[0]) = VarDispatch) and (VarType(LVar[1]) = VarDispatch) and
              (VarType(LVar[2]) = VarDispatch)) then
            begin
              LBool := Boolean(LVar[3]);
              TUnDockEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TControl, InterfaceToObject(LVar[2]) as TWinControl,
                LBool);
              LVar[3] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TCloseEvent;
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCloseEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LCloseAction := TCloseAction(LVar[1]);
              TCloseEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), LCloseAction);
              LVar[1] := LCloseAction;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TCloseQueryEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCloseQueryEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LBool := Boolean(LVar[1]);
              TCloseQueryEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), LBool);
              LVar[1] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TMenuChangeEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMenuChangeEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TMenuChangeEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TMenuItem, Boolean(LVar[2]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TMeasureItemEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMeasureItemEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              p2 := LVar[2];
              TMeasureItemEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TWinControl,
                Integer(LVar[1]), p2);
              LVar[2] := p2;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TScrollEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiScrollEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              p2 := LVar[2];
              TScrollEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]), TScrollCode(LVar[1]), p2);
              LVar[2] := p2;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TActionEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiActionEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LBool := LVar[1];
              TActionEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TBasicAction, LBool);
              LVar[1] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TMovedEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiMovedEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TMovedEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                Integer(LVar[1]), Integer(LVar[2]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TCheckBoxEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiCheckBoxEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LBool := Boolean(LVar[2]);
              TCheckBoxEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                String(LVar[1]), LBool);
              LVar[2] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TAfterCheckEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiAfterCheckEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TAfterCheckEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                String(LVar[1]), Boolean(LVar[2]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TDataSetNotifyEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDataSetNotifyEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 0) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TDataSetNotifyEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TDataSet);
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TDataSetErrorEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiDataSetErrorEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LDataAction := TDataAction(LVar[2]);
              TDataSetErrorEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TDataSet,
                InterfaceToObject(LVar[0]) as EDatabaseError, LDataAction);
              LVar[2] := LDataAction;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TFilterRecordEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiFilterRecordEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LBool := Boolean(LVar[1]);
              TFilterRecordEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TDataSet, LBool);
              LVar[1] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TIBUpdateErrorEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiIBUpdateErrorEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 3) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LIBUpdateAction := TIBUpdateAction(LVar[3]);
              TIBUpdateErrorEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TDataSet,
                InterfaceToObject(LVar[1]) as EDatabaseError, TUpdateKind(LVar[2]), LIBUpdateAction);
              LVar[3] := LIBUpdateAction;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TIBUpdateRecordEvent
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiIBUpdateRecordEvent) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LIBUpdateAction := TIBUpdateAction(LVar[2]);
              TIBUpdateRecordEvent(PNotifyEvent^)(InterfaceToObject(LVar[0]) as TDataSet,
                TUpdateKind(LVar[1]), LIBUpdateAction);
              LVar[2] := LIBUpdateAction;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

    //eigdcAfterInitSQL = 'TgdcAfterInitSQL';
    //(Sender: TObject; var SQLText: String; var isReplaceSQL: Boolean);
        //To TgdcAfterInitSQL
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcAfterInitSQL) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              LStr := String(LVar[1]);
              LBool := Boolean(LVar[2]);
              TgdcAfterInitSQL(PNotifyEvent^)(InterfaceToObject(LVar[0]), LStr, LBool);
              LVar[1] := LStr;
              LVar[2] := LBool;
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TgdcDoBeforeShowDialog
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcDoBeforeShowDialog) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TgdcDoBeforeShowDialog(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TCustomForm);
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TgdcDoAfterShowDialog
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eigdcDoAfterShowDialog) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 2) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TgdcDoAfterShowDialog(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TCustomForm, Boolean(LVar[2]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TOnCreateNewObject
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiOnCreateNewObject) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TOnCreateNewObject(PNotifyEvent^)(InterfaceToObject(LVar[0]),
                InterfaceToObject(LVar[1]) as TgdcBase);
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TConditionChanged
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiConditionChanged) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 0) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TConditionChanged(PNotifyEvent^)(InterfaceToObject(LVar[0]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;

        //To TFilterChanged
        if AnsiUpperCase(TempPropList[I]^.PropType^^.Name) = AnsiUpperCase(eiFilterChanged) then
        begin
          // проверка количества параметров, переданных для события
          if not (VarArrayHighBound(Params[2], 1) = 1) then
            raise Exception.Create(Format('Для класса %s и события %s неверное количество параметров', [LObj.ClassName, String(Params[1])]));
          // передаются параметры из EventInherited и вызывается обработчик Delphi
          LVar := Params[2];
          try
            if VarType(LVar[0]) = VarDispatch then
            begin
              TFilterChanged(PNotifyEvent^)(InterfaceToObject(LVar[0]), Integer(LVar[1]));
            end else
              raise Exception.Create(Format('Для класса %s и события %s не переданы объекты', [LObj.ClassName, String(Params[1])]));
            exit;
          except
            raise Exception.Create(Format('Для класса %s и события %s ошибка передачи параметров', [LObj.ClassName, String(Params[1])]));
          end;
        end;




(*
    eiMouseEvent = 'TMouseEvent';
    //(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    eiMouseMoveEvent = 'TMouseMoveEvent';
    //(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    //eiGetSiteInfoEvent = 'TGetSiteInfoEvent';
    //(Sender: TObject; DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    eiKeyEvent = 'TKeyEvent';
    //(Sender: TObject; var Key: Word; Shift: TShiftState);
    eiMouseWheelEvent = 'TMouseWheelEvent';
    //(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    eiMouseWheelUpDownEvent = 'TMouseWheelUpDownEvent';
    //(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    eiDrawItemEvent = 'TDrawItemEvent';
    //(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    eiDrawColumnCellEvent = 'TDrawColumnCellEvent';
    //(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    eiDrawDataCellEvent = 'TDrawDataCellEvent';
    //(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
*)

        // !!!обработка типа событие и вызов его по адресу
      end;
//    else
//      raise Exception.Create(Format('Event interface method %d not supported', [DispID]));
//    end;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TInheritedObject.Method(const Sender: IgsObject;
  const Name: WideString; var Parameters, Results: OleVariant);
var
  DataSet: TgdcObject;
  dsObjectEvent: TIBDataSet;
  Transaction: TIBTransaction;
  TmpClass: TClass;
  TmpExecuteFunction: PExecuteFunction;
  I, J: Integer;
  LParams: Variant;
  Root: Boolean;
begin
  Root := False;
  if (not FFunctionListFilled) or (FClassName <> TObject(Sender.Get_Self).ClassName) or
    (FMethodName <> Name) then
  begin
    Root := True;
    FClassName := TObject(Sender.Get_Self).ClassName;
    FMethodName := Name;

    while FExecuteFunction.Count > 0 do
    begin
      FreeMem(FExecuteFunction.Last, SizeOf(TExecuteFunction));
      FExecuteFunction.Delete(FExecuteFunction.Count - 1);
    end;

    TmpClass := TObject(Sender.Get_Self).ClassParent;
    Transaction := TIBTransaction.Create(nil);
    try
      DataSet := TgdcObject.Create(nil);
      try
        dsObjectEvent := TIBDataSet.Create(nil);
        try
          if gdcBaseManager <> nil then
          begin
            Transaction.DefaultDataBase := gdcBaseManager.Database;
          end else
            raise Exception.Create('Database is not assigned');

          DataSet.Transaction := Transaction;
          dsObjectEvent.Transaction := Transaction;
          dsObjectEvent.SelectSQL.Text := 'SELECT * FROM evt_objectevent WHERE (objectkey = :objectkey) AND (UPPER(eventname) = UPPER(:name))';

          DataSet.SubSet := ssByUpperName;
          repeat
            if DataSet.Active then
              DataSet.Close;
            DataSet.ParamByName('name').AsString := TmpClass.ClassName;
            DataSet.Open;
            if not DataSet.IsEmpty then
            begin
              if dsObjectEvent.Active then
                dsObjectEvent.Close;
              dsObjectEvent.ParamByName('objectkey').AsInteger :=
                DataSet.FieldByName(fnId).AsInteger;
              dsObjectEvent.ParamByName('name').AsString := Name;
              dsObjectEvent.Open;
              if  not dsObjectEvent.IsEmpty then
              begin
                New(TmpExecuteFunction);
                TmpExecuteFunction^.Executed := False;
                TmpExecuteFunction^.Id := dsObjectEvent.FieldByName(fnFunctionKey).AsInteger;
                TmpExecuteFunction^.Sender := TmpClass;
                FExecuteFunction.Add(TmpExecuteFunction);
                dsObjectEvent.Next
              end;
            end;
            TmpClass := TmpClass.ClassParent;
          until DataSet.IsEmpty;
        finally
          dsObjectEvent.Free;
        end;
      finally
        DataSet.Free;
      end;
    finally
      Transaction.Free;
    end;
    FFunctionListFilled := True;
  end;

  for I := 0 to FExecuteFunction.Count - 1 do
  begin
    if not TExecuteFunction(FExecuteFunction[I]^).Executed then
      Break;
  end;

  if I < FExecuteFunction.Count then
  begin
    TExecuteFunction(FExecuteFunction[I]^).Executed := True;
    LParams := VarArrayOf([Sender as IDispatch]);
    VarArrayRedim(LParams, VarArrayHighBound(Parameters, 1) + 1);
    for J := 0 to VarArrayHighBound(Parameters, 1) do
      LParams[J + 1] := Parameters[J];
    try
      MethodControl.ExecuteMethod(
        TExecuteFunction(FExecuteFunction[I]^).Sender.ClassName,
        Name, LParams, variant(Results));

      for J := 0 to VarArrayHighBound(Parameters, 1) do
        Parameters[J] := LParams[J + 1];
    except
      FFunctionListFilled := False;
    end;
  end
  else
  begin
    TOnMethod(TObject(Sender.Get_Self).MethodAddress(ShortString('OnMethod')))(TObject(Sender.Get_Self),
      Name, Parameters, Results);
    FFunctionListFilled := False;
  end;
  if Root then
    FFunctionListFilled := False;
end;

procedure TInheritedObject.ReloadMethodsList;
var
  I: Integer;
begin
  for I := 0 to FExecuteFunction.Count - 1 do
  begin
    TExecuteFunction(FExecuteFunction[I]^).Executed := False;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TInheritedObject, CLASS_gs_InheritedObject,
    ciMultiInstance, tmApartment);

end.
