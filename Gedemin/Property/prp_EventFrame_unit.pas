unit prp_EventFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, Db, IBCustomDataSet, gdcBase, gdcFunction,
  ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit, StdCtrls, DBCtrls,
  Mask, ComCtrls, gdcEvent, Menus, prp_TreeItems, gdcTree, gdcDelphiObject,
  ActnList, SynCompletionProposal, SynHighlighterJScript,
  SynEditHighlighter, SynHighlighterVBScript, ImgList, SuperPageControl,
  IBQuery, prpDBComboBox, SynEditExport, SynExportRTF, gdcCustomFunction,
  StdActns, TB2Item, TB2Dock, TB2Toolbar, gdcBaseInterface;

type
  TEventFrame = class(TFunctionFrame)
    gdcEvent: TgdcEvent;
    dsEvent: TDataSource;
    actDisable: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    actNewFunction: TAction;
    actDeleteFunction: TAction;
    dbtEventName: TDBEdit;
    lEventName: TLabel;
    procedure gdcEventAfterDelete(DataSet: TDataSet);
    procedure dbeNameSelChange(Sender: TObject);
    procedure dbeNameNewRecord(Sender: TObject);
    procedure actDisableUpdate(Sender: TObject);
    procedure actDisableExecute(Sender: TObject);
    procedure actNewFunctionExecute(Sender: TObject);
    procedure actNewFunctionUpdate(Sender: TObject);
    procedure actDeleteFunctionUpdate(Sender: TObject);
    procedure actDeleteFunctionExecute(Sender: TObject);
    procedure dbeNameDropDown(Sender: TObject);
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actAddToSettingUpdate(Sender: TObject);
  private
    function GetEventTreeItem: TEventTreeItem;
    procedure SetEventTreeItem(const Value: TEventTreeItem);
    procedure ChangeEventHandler(const Index: Integer);
    procedure ChangeTreeItem(Sender: TObject; const ObjectID: Integer);
    function  FindEventTreeNode(AID: integer): TTreeNode;
  protected
    function GetMasterObject: TgdcBase;override;
    function GetDetailObject: TgdcBase; override;
    function GetModule: string; override;
    //Возвращает указатель на объект
    function GetComponent(const AEventTreeItem: TEventTreeItem = nil): TComponent;
    function GetOwnerForm(const Comp: TComponent): TCustomForm;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetDeleteMsg: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    procedure GetNamesList(const SL: TStrings); override;
    procedure SetEvents;
    procedure OversetEvents(const AETI: TEventTreeItem = nil);
    procedure ParserInit; override;
    procedure SetBaseScriptText(const NewFunctionName: String); override;
    function  NewNameUpdate: Boolean; override;
    function  GetUniqueNewName: string;

    class function GetNameFromDb(Id: Integer): string; override;
    class function GetTypeName: string; override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Post; override;
    procedure Setup(const FunctionName: String = ''); override;
    function Delete: Boolean; override;
    procedure AddTosetting; override;
    class function GetFunctionIdEx(Id: Integer): integer; override;

    property EventTreeItem: TEventTreeItem read GetEventTreeItem
      write SetEventTreeItem;
    procedure ChangeFunctionID(const ID: Integer);
  end;

var
  EventFrame: TEventFrame;

const
  cInfoHint = 'Событие %s'#13#10'Владелец %s'#13#10'Форма %s';
  cSaveMsg = 'Событие %s было изменёно. Сохранить изменения?';
  cDelMsg = 'Удалить событие %s объекта %s ?';
  cDelAllMsg = 'В базе данных найдено несколько объектов использующих данную скрипт-функцию для обработки событий.'#13'Удалить все события?';

implementation

uses
  gdcConstants, evt_i_Base, evt_Base, rp_report_const, prp_dfPropertyTree_Unit,
  IBSQL, dlg_gsResizer_ObjectInspector_unit, gd_i_ScriptFactory, mtd_i_Base,
  prp_MessageConst, gd_Createable_Form, IBDatabase, IB, obj_i_Debugger,
  prp_i_VBProposal, at_AddToSetting
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

{ TEventFrame }

function TEventFrame.GetComponent(const AEventTreeItem: TEventTreeItem): TComponent;
var
  I: Integer;
  OTI: TObjectTreeItem;
  NameList: TStrings;
  ETI: TEventTreeItem;

  function GetChildComponent(C: TComponent; Name: string): TComponent;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to C.ComponentCount - 1 do
    begin
      if UpperCase(C.Components[I].Name) = Name then
      begin
        Result := C.Components[I];
        Exit;
      end;
    end;
  end;

begin
  Result := nil;
  if Assigned(AEventTreeItem) then
    ETI:= AEventTreeItem
  else if Assigned(EventTreeItem) then
    ETI:= EventTreeItem
  else
    Exit;

  NameList := TStringList.Create;
  try
    OTI := ETI.ObjectItem;
    while Assigned(OTI) do
    begin
      I := NameList.Add(UpperCase(OTI.Name));
      NameList.Objects[I] := OTI;
      OTI := TObjectTreeItem(OTI.Parent);
    end;

    Result := GetForm(NameList[NameList.Count - 1]);
    for I := NameList.Count - 2 downto 0 do
    begin
      if Assigned(Result) then
        Result := GetChildComponent(Result, NameList[I]);
    end;
  finally
    NameList.Free;
  end;
end;

function TEventFrame.GetDetailObject: TgdcBase;
begin
  Result := gdcFunction;
end;

function TEventFrame.GetEventTreeItem: TEventTreeItem;
begin
  Result := TEventTreeItem(CustomTreeItem);
end;

function TEventFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcEvent;
end;

function TEventFrame.GetModule: string;
begin
  Result := scrEventModuleName;
end;


procedure TEventFrame.Post;
var
  B: boolean;
begin
  if not Modify and (gdcFunction.State = dsInsert) then
    Exit;
  B := (gdcFunction.State = dsInsert) or (TEventTreeItem(CustomTreeItem).EventItem.FunctionKey <> gdcFunction.ID);
  inherited;
  TEventTreeItem(CustomTreeItem).Id := gdcEvent.ID;
  //TEventTreeItem(CustomTreeItem).EventItem.EventID := gdcEvent.ID;
  TEventTreeItem(CustomTreeItem).EventItem.FunctionKey := gdcFunction.ID;
  if B then
    PropertyTreeForm.UpdateEventOverload(CustomTreeItem.Node.Parent, 1);

  SetEvents;

  if Assigned(dlg_gsResizer_ObjectInspector) then
    dlg_gsResizer_ObjectInspector.EventSync(TEventTreeItem(CustomTreeItem).EventItem.EventObject.ObjectName,
    TEventTreeItem(CustomTreeItem).EventItem.Name);
end;

procedure TEventFrame.SetEventTreeItem(const Value: TEventTreeItem);
begin
  CustomTreeItem := Value;
end;

procedure TEventFrame.Setup(const FunctionName: String = '');
var
  LFunctionName: String;
begin
  if Assigned(CustomTreeItem) then
  begin
    gdcEvent.FieldByName(fnFunctionKey).AsInteger := gdcEvent.GetNextID(True);
    gdcFunction.FieldByName(fnId).AsInteger := gdcEvent.FieldByName(fnFunctionKey).AsInteger;
    gdcEvent.FieldByName(fnEventName).AsString := UpperCase(TEventTreeItem(CustomTreeItem).Name);
    gdcEvent.FieldByName(fnObjectKey).AsInteger := TEventTreeItem(CustomTreeItem).OwnerId;
  end;
  //!!! перенесено из prp_FunctionFrame_unit т.к. там к CustomTreeItem.Name добавляется руид
  //а для событий этого не надо
  if (gdcFunction.State = dsInsert) and Assigned(CustomTreeItem) then
  begin
    with gdcFunction do
    begin
      FieldByName(fnModule).AsString := GetModule;
      FieldByName(fnLanguage).AsString := dbcbLang.Items[1];
    end;
  end;

  if Assigned(CustomTreeItem) then
  begin
    if FunctionName = '' then
      LFunctionName := TEventTreeItem(CustomTreeItem).EventItem.AutoFunctionName
    else
      LFunctionName := FunctionName;

    gdcFunction.FieldByName(fnName).AsString := LFunctionName;

    gdcFunction.FieldByName(fnScript).AsString :=
      TEventTreeItem(CustomTreeItem).EventItem.ComplexParams(fplVBScript, LFunctionName);

    gdcFunction.FieldByName(fnEvent).AsString :=
      UpperCase(TEventTreeItem(CustomTreeItem).Name);
    gdcFunction.FieldByName(fnModuleCode).AsInteger :=
      TEventTreeItem(CustomTreeItem).ObjectItem.OwnerId;
  end;
end;

procedure TEventFrame.gdcEventAfterDelete(DataSet: TDataSet);
begin
  inherited;
  if Assigned(EventTreeItem) then
  begin
    EventTreeItem.Id := 0;
    EventTreeItem.EventItem.FunctionKey := 0;
    EventTreeItem.EventItem.EventID := 0;
    PropertyTreeForm.UpdateEventOverload(Node.Parent, - 1);

    if (PropertyTreeForm <> nil) and (CustomTreeItem.Node <> nil) then
    begin
      PropertyTreeForm.UpdateEventOverload(CustomTreeItem.Node.Parent, -1);
      if EventTreeItem.EventItem.Disable then
        PropertyTreeForm.UpdateEventDesabled(CustomTreeItem.Node.Parent, -1);
    end;
    OverSetEvents;

    if (dlg_gsResizer_ObjectInspector <> nil) then
      dlg_gsResizer_ObjectInspector.EventSync(EventTreeItem.EventItem.EventObject.ObjectName,
        EventTreeItem.EventItem.Name);

  end;
end;

function TEventFrame.GetInfoHint: String;
begin
  if Assigned(EventTreeItem) then
    Result := Format(cInfoHint, [EventTreeItem.Name, EventTreeItem.EventItem.ObjectName,
      EventTreeItem.MainOwnerName])
  else
    Result :=  '';
end;


function TEventFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TEventFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TEventFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TEventFrame.GetNamesList(const SL: TStrings);
var
  SQL: TIBSQL;
  I: Integer;
begin
  if SL = nil then Exit;
  if not Assigned(EventTreeItem) then Exit;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT DISTINCT g.name, g.id FROM gd_function g, ' +
      '  evt_object o1, evt_object o2 WHERE o2.id = g.modulecode AND ' +
      '  UPPER(g.event) = Upper(:eventname) AND ' +
      '  UPPER(o1.Name) = UPPER(:formname) AND o1.lb <= o2.lb AND ' +
      '  o1.rb >= o2.rb';
    SQL.Params[0].AsString := gdcEvent.FieldByName(fnEventName).AsString;
    SQL.Params[1].AsString := EventTreeItem.MainOwnerName;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      I := SL.Add(SQL.Fields[0].AsString);
      Sl.Objects[I] := Pointer(SQL.Fields[1].AsInteger);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TEventFrame.dbeNameSelChange(Sender: TObject);
begin
  if dbeName.ItemIndex > - 1 then
    ChangeEventHandler(dbeName.ItemIndex);
end;

procedure TEventFrame.dbeNameNewRecord(Sender: TObject);
begin
  gdcFunction.Close;
  gdcEvent.FieldByName(fnFunctionKey).Clear;
  gdcFunction.Open;
  gdcFunction.Insert;
  GetNamesList(dbeName.Items);
  Setup(GetUniqueNewName);
  Modify := True;
end;

procedure TEventFrame.actDisableUpdate(Sender: TObject);
const
  cDisable = 'Отключить событие';
  cEnable = 'Подключить событие';
begin
  actDisable.Enabled := (EventTreeItem <> nil) and
    (EventTreeItem.EventItem.FunctionKey > 0);
  if actDisable.Enabled then
  begin
    if not EventTreeItem.EventItem.Disable then
    begin
      if actDisable.ImageIndex <> 50 then
      begin
        actDisable.ImageIndex := 50;
        actDisable.Hint := cDisable;
      end;
    end else
    begin
      if actDisable.ImageIndex <> 49 then
      begin
        actDisable.ImageIndex := 49;
        actDisable.Hint := cEnable;
      end;
    end;
  end;
end;

procedure TEventFrame.actDisableExecute(Sender: TObject);
begin
  if EventTreeItem <> nil then
  begin
    if EventTreeItem.EventItem.Disable then
    begin
      EventTreeItem.EventItem.Disable := False;
      gdcEvent.FieldByName(fnDisable).AsInteger := 0;
      PropertyTreeForm.UpdateEventDesabled(CustomTreeItem.Node.Parent, -1);
    end else
    begin
      EventTreeItem.EventItem.Disable := True;
      gdcEvent.FieldByName(fnDisable).AsInteger := 1;
      PropertyTreeForm.UpdateEventDesabled(CustomTreeItem.Node.Parent, 1);
    end;
  end;
  OversetEvents;
  FNeedSave := True;
end;

function TEventFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [EventTreeItem.Name,
      EventTreeItem.EventItem.ObjectName])
  else
    Result := inherited GetSaveMsg;
end;

procedure TEventFrame.SetEvents;
var
  C: TComponent;
begin
  if Assigned(EventControl) then
  begin
    C := GetComponent;
    if (C <> nil) then
    begin
      if(GetOwnerForm(C).InheritsFrom(TCreateableForm) and
        (cfsDesigning in TCreateableForm(GetOwnerForm(C)).CreateableFormState)) then
        Exit;

      EventControl.RebootEvents(GetOwnerForm(C));
    end;
  end;
end;

function TEventFrame.Delete: Boolean;
var
  q: TIBSQL;
  iResult: integer;
  gdcDelEvent: TgdcEvent;
  TN: TTreeNode;
  ETI: TEventTreeItem;
begin
  Result := False;

  if FShowDeleteQuestion then
    if MessageBox(Application.Handle, PChar(GetDeleteMsg),
      MSG_WARNING, MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) <> IDYES then
      Exit;

  q:= TIBSQL.Create(nil);
  try
    q.Transaction:= gdcBaseManager.ReadTransaction;
    q.SQL.Text:= 'SELECT id FROM evt_objectevent WHERE functionkey=:fkey and id<>:eid';
    q.ParamByName('fkey').AsInteger:= gdcEvent.FieldByName('functionkey').AsInteger;
    q.ParamByName('eid').AsInteger:= gdcEvent.ID;
    q.ExecQuery;
    if not q.Eof then begin
      if FShowDeleteQuestion then begin
        iResult:= MessageBox(Application.Handle, PChar(cDelAllMsg),
          MSG_WARNING, MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL);
      end
      else
        iResult:= IDNO;
      case iResult of
        IDYES:begin
            FShowDeleteQuestion:= False;
            gdcDelEvent:= TgdcEvent.Create(self);
            try
              gdcDelEvent.Transaction:= gdcEvent.Transaction;
              gdcDelEvent.SubSet:= 'ByID';
              while not q.Eof do begin
                gdcDelEvent.Close;
                gdcDelEvent.Params[0].AsInteger := q.Fields[0].AsInteger;
                gdcDelEvent.Open;
                if not gdcDelEvent.Eof then begin
                  try
                    gdcDelEvent.Delete;
                    TN:= FindEventTreeNode(q.Fields[0].AsInteger);
                    if Assigned(TN) and Assigned(TN.Data) then begin
                      ETI:= TN.Data;
                      if Assigned(ETI.EditorFrame) then
                        TEventFrame(ETI.EditorFrame).Close;
                      ETI.ID:= 0;
                      ETI.EventItem.FunctionKey := 0;
                      ETI.EventItem.EventID := 0;
                      if Assigned(PropertyTreeForm) then begin
                        PropertyTreeForm.UpdateEventOverload(TN.Parent, -1);
                        if ETI.EventItem.Disable then
                          PropertyTreeForm.UpdateEventDesabled(TN.Parent, -1);
                      end;

                      OverSetEvents(ETI);

                      if (dlg_gsResizer_ObjectInspector <> nil) then
                        dlg_gsResizer_ObjectInspector.EventSync(ETI.EventItem.EventObject.ObjectName,
                          ETI.EventItem.Name);
                    end;
                  except
                  end;
                end;
                q.Next;
              end;

            finally
              gdcDelEvent.Free;
            end;
          end;
        IDNO:begin
            FShowDeleteQuestion:= False;
            FNeedDeleteDetail:= False;
          end;
        IDCANCEL:begin
            Exit;
          end;
      end;
    end
    else begin
      FNeedDeleteDetail:= True;
      FShowDeleteQuestion:= False;
    end;

    Result := inherited Delete;

  finally
    q.Free;
  end;

end;

procedure TEventFrame.ParserInit;
var
  C: TComponent;
begin
  inherited;
  FVBParser.IsEvent := True;
  if (EventTreeItem <> nil) and (VBProposal <> nil) then
  begin
    C := GetForm(CustomTreeItem.MainOwnerName);
    if C <> nil then
    begin
      C := C.FindComponent(EventTreeItem.EventItem.ObjectName);
      if C <> nil then
        VBProposal.AddFKObject('Sender', C);
    end;
  end;
end;

procedure TEventFrame.SetBaseScriptText(const NewFunctionName: String);
begin
  if Assigned(CustomTreeItem) then
  begin
    gdcFunction.Close;
    gdcEvent.FieldByName(fnFunctionKey).Clear;
    gdcFunction.Open;
    gdcFunction.Insert;
    Setup(NewFunctionName);
    Modify := True;
  end;
  inherited;
end;

function TEventFrame.NewNameUpdate: Boolean;
var
  I: Integer;
  WMess: String;
begin
  Result := inherited NewNameUpdate;

  if AnsiUpperCase(Trim(dbeName.Text)) <> CurrentFunctionName then
  begin
    GetNamesList(dbeName.Items);
    I := dbeName.Items.IndexOf(Trim(dbeName.Text));
    if I > -1 then
      ChangeEventHandler(I)
    else
      begin
        WMess := 'Для события ' + EventTreeItem.Name +
          ' объекта ' + EventTreeItem.EventItem.ObjectName + #13#10 +
          'изменено имя обработчика.'#13#10#13#10 + 'Создать новый обработчик?';
        case MessageBox(0, PChar(WMess), PChar('Внимание'),
          MB_YESNOCANCEL or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL) of
          IDYES:
            begin
              CurrentFunctionName := AnsiUpperCase(Trim(dbeName.Text));
              SetBaseScriptText(Trim(dbeName.Text));
              PageControl.ActivePage := tsScript;
              Result := False;
            end;
          IDNO:
            begin
              CurrentFunctionName := AnsiUpperCase(Trim(dbeName.Text));
              Result := True;
            end;
          IDCANCEL:
            begin
              SpeedButton.Click;
              dbeName.SetFocus;
            end;
        end;
      end;
  end;
end;

procedure TEventFrame.ChangeEventHandler(const Index: Integer);
begin
  gdcFunction.Close;
  gdcEvent.FieldByName(fnFunctionKey).AsInteger :=
    Integer(dbeName.Items.Objects[Index]);
  gdcFunction.Open;
  gdcFunction.Edit;
  Modify := True;
  CurrentFunctionName :=
    AnsiUpperCase(Trim(dbeName.Items[Index]));
end;

procedure TEventFrame.ChangeFunctionID(const ID: Integer);
var
  i: integer;
begin
  if ID = gdcFunction.ID then Exit;
  if Modify then begin
   case MessageBox(Application.Handle, 'Данные были изменены.'#13#10'Сохранить изменения?',
       MSG_WARNING, MB_YESNO or MB_TASKMODAL or MB_ICONWARNING) of
     IDYES:
       try
         inherited Post;
       except
         on E: Exception do
         begin
           if MessageBox(Application.Handle, PChar('При сохранении возникла ошибка: '#13#10 +
             E.Message + #13#10 + 'Продолжить создание новой функции с'#13#10+
             'потерей изменений?'),  MSG_WARNING, MB_YESNO or MB_TASKMODAL +
             MB_ICONWARNING) = IDYES then
             Cancel
           else
             Exit;
         end;
       end;
     IDNO: Cancel;
   end;
  end;
  if ID = -1 then begin
    actNewFunction.Execute;
    Exit;
  end;
  GetNamesList(dbeName.Items);
  for i:= 0 to dbeName.Items.Count - 1 do
    if Integer(dbeName.Items.Objects[i]) = ID then begin
      Break;
    end;
  if dbeName.ItemIndex <> i then begin
    dbeName.ItemIndex:= i;
    ChangeEventHandler(i);
    Modify:= False;
  end;
end;

constructor TEventFrame.Create(AOwner: TComponent);
begin
  inherited;

  OnChangeTreeItem := ChangeTreeItem;
end;

function TEventFrame.GetUniqueNewName: String;
var
  UI, UIndex: Integer;
  UStr: String;
begin
  UStr := TEventTreeItem(CustomTreeItem).EventItem.AutoFunctionName;
  Result := UStr;
  UI := 1;
  while True do
  begin
    UIndex := dbeName.Items.IndexOf(Result);
    if UIndex = -1 then
      Break;
    Result := UStr + '_' + IntToStr(UI);
    Inc(UI);
  end;
end;

procedure TEventFrame.ChangeTreeItem(Sender: TObject; const ObjectID: Integer);
var
  I: Integer;
  WMess: String;

begin
  if ObjectID = 0 then
  begin
    GetNamesList(dbeName.Items);
    I := dbeName.Items.IndexOf(TEventTreeItem(CustomTreeItem).EventItem.AutoFunctionName);
    if I > -1 then
    begin
      WMess := 'Для события ' + EventTreeItem.Name +
        ' объекта ' + EventTreeItem.EventItem.ObjectName + #13#10 +
        'обнаружен обработчик с именем по умолчанию.'#13#10#13#10 +
        'Подключить его?';
      if MessageBox(0, PChar(WMess), PChar('Внимание'),
        MB_YESNO or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL) = IDYES then
      begin
        ChangeEventHandler(I);
        Post;
//        Modify := True;
      end else
        Setup(GetUniqueNewName);
    end;
  end;
//
end;

procedure TEventFrame.OversetEvents(const AETI: TEventTreeItem);
var
  C: TComponent;
begin
  if Assigned(EventControl) then
  begin
    C := GetComponent(AETI);
    if C <> nil then
    begin
      if(GetOwnerForm(C).InheritsFrom(TCreateableForm) and
        (cfsDesigning in TCreateableForm(GetOwnerForm(C)).CreateableFormState)) then
        Exit;

      EventControl.RebootEvents(GetOwnerForm(C));
    end;
//      EventControl.OversetEvents(C);
  end;
end;

procedure TEventFrame.AddTosetting;
begin
  if gdcEvent.State = dsEdit then
    inherited
  else
    MessageBox(Application.Handle, 'Перед добавлением в пространство имен событие необходимо сохранить.',
      MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
end;

function TEventFrame.GetOwnerForm(const Comp: TComponent): TCustomForm;
var
  TmpComp: TComponent;
begin
  Result := nil;
  TmpComp := Comp;
  while (TmpComp is TComponent) and (TmpComp <> nil) do
  begin
    if TmpComp is TCustomForm then
    begin
      Result := TCustomForm(TmpComp);
      Exit;
    end;
    TmpComp := TmpComp.Owner;
  end;
end;

procedure TEventFrame.actNewFunctionExecute(Sender: TObject);
var
  R: Integer;
begin
  if Modify then
  begin
     R := MessageBox(Application.Handle, 'Данные были изменены.'#13#10'Сохранить изменения?',
       MSG_WARNING, MB_YESNOCANCEL or MB_TASKMODAL or MB_ICONWARNING);
     case R of
       IDYES:
         try
           Post;
         except
           on E: Exception do
           begin
             if MessageBox(Application.Handle, PChar('При сохранении возникла ошибка: '#13#10 +
               E.Message + #13#10 + 'Продолжить создание новой функции с'#13#10+
               'потерей изменений?'),  MSG_WARNING, MB_YESNO or MB_TASKMODAL +
               MB_ICONWARNING) = IDYES then
               Cancel
             else
               Exit;
           end;
         end;
       IDNO: Cancel;
       IDCANCEL: Exit;
     end;
  end;
  dbeNameNewRecord(nil);
end;

procedure TEventFrame.actNewFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcEvent.State = dsEdit;
end;

procedure TEventFrame.actDeleteFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcEvent.State = dsEdit;
end;

procedure TEventFrame.actDeleteFunctionExecute(Sender: TObject);
var
  F: TgdcFunction;
  Id: Integer;
begin
  Id := gdcEvent.FieldByName(fnFunctionKey).AsInteger;
  F := TgdcFunction.Create(nil);
  try
    F.Subset := 'ByID';
    F.Id := id;
    try
      if MessageBox(Application.Handle, 'Удалить функцию?', MSG_QUESTION,
        MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES then
      begin
        gdcEvent.FieldByName(fnFunctionKey).Clear;
        gdcEvent.Post;
        gdcEvent.Edit;
        F.Open;
        F.Delete;
        dbeNameNewRecord(nil);
      end;
    except
      on E: Exception do
      begin
        if gdcEvent.State <> dsEdit then
          gdcEvent.Edit;
        gdcFunction.Close;
        gdcEvent.FieldByName(fnFunctionKey).AsInteger := Id;
        gdcFunction.Open;
      end;
    end;
  finally
    F.Free;
  end;
end;

class function TEventFrame.GetNameFromDb(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQl.SQL.Text := 'SELECT f.name FROM evt_objectevent e JOIN gd_function f ON f.id = e.functionkey WHERE e.id = :id';
    SQL.ParamByName('id').AsInteger := id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('name').AsString;
  finally
    SQL.Free;
  end;
end;

class function TEventFrame.GetTypeName: string;
begin
  Result := 'Событие '
end;

class function TEventFrame.GetFunctionIdEx(Id: Integer): integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQl.Create(nil);
  try
    SQl.Transaction := gdcBaseManager.ReadTransaction;
    SQl.SQl.Text := 'SELECT functionkey FROM evt_objectevent WHERE id = :id';
    SQL.ParamByName('id').AsInteger := Id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('functionkey').AsInteger;
  finally
    SQl.Free;
  end;
end;

function TEventFrame.FindEventTreeNode(AID: integer): TTreeNode;
var
  tnRoot, tnObj, tnEvt: TTreeNode;
  ETI: TEventTreeItem;
begin
  Result:= nil;
  if not (Assigned(Node) and Assigned(Node.Parent) and Assigned(Node.Parent.Parent)) then Exit;
  tnRoot:= Node.Parent.Parent;
  tnObj:= tnRoot.GetFirstChild;
  while Assigned(tnObj) do begin
    tnEvt:= tnObj.GetFirstChild;
    while Assigned(tnEvt) do begin
      ETI:= tnEvt.Data;
      if Assigned(ETI) and (ETI.EventItem.EventID = AID) then begin
        Result:= tnEvt;
        Exit;
      end;
      tnEvt:= tnObj.GetNextChild(tnEvt);
    end;
    tnObj:= tnRoot.GetNextChild(tnObj);
  end;
end;

procedure TEventFrame.dbeNameDropDown(Sender: TObject);
begin
  if (Debugger <> nil) and Debugger.IsPaused and
    IsExecuteScript then
  begin
    if MessageBox(Application.Handle, PChar(
        'Перед сменой функции обработчика события'#13#10 +
        'необходимо закончить выполнение скрипта.'),
        MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING + MB_APPLMODAL) = ID_OK then
      Debugger.Run;
    Exit;
  end;
  inherited;
end;

procedure TEventFrame.actAddToSettingExecute(Sender: TObject);
begin
  if PageControl.ActivePage = tsScript then
    at_AddToSetting.AddToSetting(False, '', '', gdcFunction, nil)
  else
    inherited;
end;

procedure TEventFrame.actAddToSettingUpdate(Sender: TObject);
begin
  if PageControl.ActivePage = tsScript then
    actAddToSetting.Enabled := (gdcFunction <> nil)
      and (not gdcFunction.IsEmpty)
  else
    inherited;
end;

initialization
  RegisterClass(TEventFrame);
finalization
  UnRegisterClass(TEventFrame);
end.
