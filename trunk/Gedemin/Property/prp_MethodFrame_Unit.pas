unit prp_MethodFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, ImgList, ExtCtrls, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  gdcTree, gdcDelphiObject, Db, IBCustomDataSet, gdcBase, gdcFunction,
  ActnList, Menus, SynEdit, SynDBEdit, gsFunctionSyncEdit, StdCtrls,
  DBCtrls, ComCtrls, gdcEvent, prp_TreeItems, SuperPageControl, Mask,
  prpDBComboBox, SynEditExport, SynExportRTF, gdcCustomFunction, StdActns,
  TB2Item, TB2Dock, TB2Toolbar, IBSQL, gdcBaseInterface;

type
  TMethodFrame = class(TFunctionFrame)
    dsEvent: TDataSource;
    gdcEvent: TgdcEvent;
    actDisable: TAction;
    TBItem2: TTBItem;
    DBEdit1: TDBEdit;
    TBSeparatorItem1: TTBSeparatorItem;
    lMethodName: TLabel;
    procedure gdcEventAfterDelete(DataSet: TDataSet);
    procedure actDisableExecute(Sender: TObject);
    procedure actDisableUpdate(Sender: TObject);
  private
    function GetMethodTreeItem: TMethodTreeItem;
    procedure SetMethodTreeItem(const Value: TMethodTreeItem);
    { Private declarations }
  protected
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetDeleteMsg: string; override;
    function GetMasterObject: TgdcBase;override;
    function GetDetailObject: TgdcBase; override;
    function GetModule: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;

    class function GetNameFromDb(Id: Integer): string; override;
    class function GetTypeName: string; override;
  public
    { Public declarations }
    procedure Post; override;
    procedure Setup(const FunctionName: String = ''); override;
    function Delete: Boolean; override;
    procedure AddTosetting; override;
    class function GetFunctionIdEx(Id: Integer): integer; override;
    property MethodTreeItem: TMethodTreeItem read GetMethodTreeItem
      write SetMethodTreeItem;
  end;

var
  MethodFrame: TMethodFrame;
const
  cInfoHint = 'Метод %s'#13#10'Класс владелец: %s'#13#10'Коментарий: %s';
  cSaveMsg = 'Метод %s был изменён. Сохранить изменения?';
  cDelMsg = 'Удалить %s метод класса %s?';

implementation

uses
  gdcConstants, rp_report_const, evt_i_base, gd_i_ScriptFactory, mtd_i_Base,
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

{ TFunctionFrame1 }

function TMethodFrame.GetInfoHint: String;
begin
  if Assigned(MethodTreeItem) then
    Result := Format(cInfoHint, [MethodTreeItem.Name,
      MethodTreeItem.TheMethod.MethodClass.Class_Name,
      MethodTreeItem.TheMethod.MethodClass.SubTypeComment])
  else
    Result := '';
end;

function TMethodFrame.GetMethodTreeItem: TMethodTreeItem;
begin
  Result := TMethodTreeItem(CustomTreeItem)
end;

procedure TMethodFrame.Post;
var
  B: Boolean;
begin
  if not Modify and (gdcFunction.State = dsInsert) then
    Exit;
  B := gdcFunction.State = dsInsert;
  inherited;
  MethodTreeItem.Id := gdcEvent.ID;
  MethodTreeItem.TheMethod.MethodId := gdcEvent.ID;
  MethodTreeItem.TheMethod.FunctionKey := gdcFunction.ID;
  if B then
    PropertyTreeForm.UpdateMethodOverload(CustomTreeItem.Node.Parent, 1);
end;

procedure TMethodFrame.SetMethodTreeItem(const Value: TMethodTreeItem);
begin
  CustomTreeItem := TCustomTreeItem(Value);
end;

procedure TMethodFrame.Setup(const FunctionName: String = '');
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
      FieldByName(fnModuleCode).AsInteger := CustomTreeItem.OwnerId;
      FieldByName(fnModule).AsString := GetModule;
      FieldByName(fnLanguage).AsString := dbcbLang.Items[1];
    end;
  end;

  if Assigned(CustomTreeItem) then
  begin
    gdcFunction.FieldByName(fnName).AsString :=
      MethodTreeItem.TheMethod.AutoFunctionName;
    gdcFunction.FieldByName(fnScript).AsString :=
      MethodTreeItem.TheMethod.ComplexParams[fplVBScript];
  end;
end;

procedure TMethodFrame.gdcEventAfterDelete(DataSet: TDataSet);
begin
  inherited;
  if Assigned(MethodTreeItem) then
  begin
    MethodTreeItem.Id := 0;
    MethodTreeItem.TheMethod.FunctionKey := 0;
    MethodTreeItem.TheMethod.MethodId := 0;
    PropertyTreeForm.UpdateMethodOverload(Node.Parent, - 1);
  end;
end;

function TMethodFrame.GetDetailObject: TgdcBase;
begin
  Result := gdcFunction;
end;

function TMethodFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcEvent;
end;

function TMethodFrame.GetModule: string;
begin
  Result := scrMethodModuleName;
end;

function TMethodFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TMethodFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TMethodFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TMethodFrame.actDisableExecute(Sender: TObject);
var
  P: TTreeNode;
begin
  P := nil;
  if Node <> nil then P := Node.Parent;
  if MethodTreeItem <> nil then
  begin
    if MethodTreeItem.TheMethod.Disable then
    begin
      MethodTreeItem.TheMethod.Disable := False;
      gdcEvent.FieldByName(fnDisable).AsInteger := 0;
      PropertyTreeForm.UpdateMethodDisabled(CustomTreeItem.Node.Parent, -1);
      if P <> nil then
      begin
        TGDCClassTreeItem(P.Data).TheClass.SpecDisableMethod :=
          TGDCClassTreeItem(P.Data).TheClass.SpecDisableMethod - 1;
      end;
    end else
    begin
      MethodTreeItem.TheMethod.Disable := True;
      gdcEvent.FieldByName(fnDisable).AsInteger := 1;
      PropertyTreeForm.UpdateMethodDisabled(CustomTreeItem.Node.Parent, 1);
      if P <> nil then
      begin
        TGDCClassTreeItem(P.Data).TheClass.SpecDisableMethod :=
          TGDCClassTreeItem(P.Data).TheClass.SpecDisableMethod + 1;
      end;
    end;
    MethodControl.ClearMacroCache;
  end;
//  PropertyTreeForm.InvalidateTree;
  FNeedSave := True;
end;

procedure TMethodFrame.actDisableUpdate(Sender: TObject);
const
  cDisable = 'Отключить метод';
  cEnable = 'Подключить метод';
begin
  actDisable.Enabled := (MethodTreeItem <> nil) and
    (MethodTreeItem.TheMethod.FunctionKey > 0);
  if actDisable.Enabled then
  begin
    if not MethodTreeItem.TheMethod.Disable then
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

function TMethodFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [MethodTreeItem.Name,
      MethodTreeItem.TheMethod.MethodClass.Class_Name])
  else
    Result := inherited GetSaveMsg;
end;

function TMethodFrame.Delete: Boolean;
begin
  Result := inherited Delete;
  if Result and (MethodTreeItem <> nil) then
  begin
    MethodTreeItem.TheMethod.FunctionKey := 0;
    MethodTreeItem.TheMethod.MethodId := 0;
    if (PropertyTreeForm <> nil) and (CustomTreeItem.Node <> nil) then
    begin
      PropertyTreeForm.UpdateMethodOverload(CustomTreeItem.Node.Parent, -1);
      if MethodTreeItem.TheMethod.Disable then
        PropertyTreeForm.UpdateMethodDisabled(CustomTreeItem.Node.Parent, -1);
    end;    
  end;
end;

procedure TMethodFrame.AddTosetting;
begin
  if gdcEvent.State = dsEdit then
    inherited
  else
    MessageBox(Application.Handle, 'Перед добавлением в пространство имен метод необходимо сохранить.',
      MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
end;
class function TMethodFrame.GetNameFromDb(Id: Integer): string;
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

class function TMethodFrame.GetTypeName: string;
begin
  Result := 'Метод '
end;

class function TMethodFrame.GetFunctionIdEx(Id: Integer): integer;
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

initialization
  RegisterClass(TMethodFrame);
finalization
  UnRegisterClass(TMethodFrame);

end.
