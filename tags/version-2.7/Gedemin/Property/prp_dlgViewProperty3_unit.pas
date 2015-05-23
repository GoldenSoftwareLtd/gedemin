unit prp_dlgViewProperty3_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_dlgViewProperty_unit, gdcBase, gdcMacros, Menus, IBQuery, IBSQL,
  ActnList, Db, IBCustomDataSet, IBDatabase, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  ImgList, StdCtrls, ComCtrls, SynEdit, SynDBEdit, DBCtrls, Mask, ExtCtrls,
  TB2Item, TB2Dock, TB2Toolbar, scrReportGroup, scrMacrosGroup,
  evt_i_Base, gdcEvent, gdcFunction, gdcReport, DBClient, rp_BaseReport_unit,
  gsIBLookupComboBox, gdcTemplate;

type
  TdlgViewProperty3 = class(TdlgViewProperty)
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBSeparatorItem12: TTBSeparatorItem;
    procedure actAddMacrosExecute(Sender: TObject);
    procedure actAddFolderExecute(Sender: TObject);
    procedure actAddFolderUpdate(Sender: TObject);
    procedure actAddMacrosUpdate(Sender: TObject);
    procedure actDeleteFolderExecute(Sender: TObject);
    procedure actDeleteFolderUpdate(Sender: TObject);
    procedure actDeleteMacrosExecute(Sender: TObject);
    procedure actDeleteMacrosUpdate(Sender: TObject);
    procedure actRenameExecute(Sender: TObject);
    procedure actRenameUpdate(Sender: TObject);
    procedure tvClassesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure actAddReportExecute(Sender: TObject);
    procedure actAddReportUpdate(Sender: TObject);
    procedure tvClassesChange(Sender: TObject; Node: TTreeNode); override;
    procedure tvClassesChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean); override;
    procedure tvClassesEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure tvClassesEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure tvClassesGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tvClassesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvClassesEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure tvClassesStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure actCutTreeItemExecute(Sender: TObject);
    procedure actCutTreeItemUpdate(Sender: TObject);
    procedure actPasteFromClipBoardExecute(Sender: TObject);
    procedure actPasteFromClipBoardUpdate(Sender: TObject);
    procedure actCopyTreeItemExecute(Sender: TObject);
    procedure actCopyTreeItemUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDeleteReportUpdate(Sender: TObject);
    procedure actDeleteReportExecute(Sender: TObject);
    procedure FuncControlChanged(Sender: TObject);
    procedure ControlChange(Sender: TObject);
    procedure tvClassesDeletion(Sender: TObject; Node: TTreeNode);
    procedure dbcbReportServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pcFuncParamChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actFuncCommitExecute(Sender: TObject);
    procedure dbmDescriptionChange(Sender: TObject);
    procedure actEditTemplateExecute(Sender: TObject);
    procedure actEditTemplateUpdate(Sender: TObject);
    procedure dblcbTemplateChange(Sender: TObject);
    procedure dblcbTemplateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBLookupComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  protected
    //Процедура вывода корней дерева макросов
    procedure ShowMacrosTreeRoot(AComponent: TComponent);
    // Процедура вывода ветри дерева
    procedure ShowMacrosGroup(Parent: TTreeNode);
    // Добавить node
    function AddItemNode(const Item: TscrCustomItem;
     const Parent: TTreeNode; Save: Boolean = True): TTreeNode;
    //Сохраняем макрос
    function PostMacros(const AMacrosNode: TTreeNode): Boolean;
    // Сохраняем группу
    function PostMacrosGroup(const ANode: TTreeNode): Boolean;
    // Удаляем группу
    function DeleteMacrosGroupItem(const ANode: TTreeNode): Boolean;
    // Удаляем макрос
    function DeleteMacros(const ANode: TTreeNode): Boolean;
//    procedure ViewEvent;
//    procedure ViewMacros;
//    procedure ViewParam(const AnParam: Variant);

    //
    function DeleteReportGroupItem(const ANode: TTreeNode): Boolean;
    //
    function DeleteReportItem(const ANode: TTreeNode): Boolean;
    //Добавить новую рапорт
    function AddReportItem(const AItem: TscrReportItem;
       const AParent: TTreeNode; Save: Boolean = True): TTreeNode;
    //Процедура вывода корней дерева рапортов
    procedure ShowReportTreeRoot(AComponent: TComponent);
    //Процедура вывода ветвей дерева рапортов
//    procedure ShowReportGroup(Parent: TTreeNode);
    //
    function PostReportFunction(const AReportFunctionNode: TTreeNode): Boolean;
    //Сохраняем отчёт
    function PostReport(const AReportNode: TTreeNode): Boolean;
     //Сохраняем отчёт
    function PostReportTemplate(const ANode: TTreeNode): Boolean;
    // Сохраняем группу отчётов
    function PostReportGroup(const ANode: TTreeNode): Boolean;

    // Делаем Канселы
    procedure CancelReportFunction;
    procedure CancelTemplate;
    procedure CancelReport;
    procedure CancelMacros;
    procedure CancelMacrosGroup;
    procedure CancelReportGroup;
    // Возвращает парент группу
    function GetParentFolder(ANode: TTreeNode): TTreeNode;
    // Переносит нод из соурса в таргет
    procedure NodeCopy(SourceNode, TargetNode: TTreeNode);
    // Возвращает тип нода
    function GetNodeType(Node: TTreeNode): TFunctionPages; override;
    //Возвращает тру если это редактируемая папка
    function IsEditFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это редактируемый макрос
    function IsEditMacros(ANode: TTreeNode): Boolean;
    //Возвращает тру если это папка с макросами
    function IsMacrosFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это папка с отчётами
    function IsReportFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это макрос
    function IsMacros(ANode: TTreeNode): Boolean;
    //Возвращает тру если это отчёт
    function IsReport(ANode: TTreeNode): Boolean;
    //Возвращает тру если это
    function IsReportTemplate(ANode: TTreeNode): Boolean;
    //
    procedure Copy(Node: TTreeNode; ACut: Boolean);
    //вырезает в буффер обмена
    procedure Cut(Node: TTreeNode);
    //Встасляет из буффера обмена
    procedure Paste(TargetNode: TTreeNode);
    //Возвращает тру если восможна вставка из буфера
    function CanPaste(Source, Target: TTReeNode): Boolean;

  protected
    // Нод скопированный в буффер обмена
    FCopyNode: TTreeNode;
    FCopiedID: Integer;
    FCut: Boolean;
    FReportCreated: Boolean;
    FReportChanged: Boolean;
    FCanSaveLoad: Boolean;
    FTestReportResult: TReportResult;
    
    procedure LoadFunction(const AnModule: String; const AnFunctionKey: Integer;
      const AnFunctionName: String = ''; const AnParams: String = ''); override;
    procedure LoadReport(const Node: TTreeNode);
    procedure LoadReportFunction(const Node: TTreeNode);
    procedure LoadReportTemplate(const Node: TTreeNode);
    procedure LoadReportGroup(const Node: TTreeNode);
    procedure LoadMacrosGroup(const Node: TTreeNode);
    procedure LoadMacros(const Node: TTreeNode);
    function PostFunction(out AnFunctionKey: Integer): Boolean; override;
    procedure SetChanged; override;
    procedure NoChanges;
    function OverallCommit: Boolean; override;
    procedure OverallRollback; override;
    function CommitTrans: Boolean; override;
    function GetObjectId(ANode: TTreeNode): Integer; override;
  public
    procedure Execute(const AnComponent: TComponent;
     const AnShowMode: TShowModeSet = smAll; const AnName: String = '');
  end;

var
  dlgViewProperty3: TdlgViewProperty3;

const
  MSG_NO_DATA_IN_TABLE = 'Нет данных в таблицe %s';
  MSG_PASTE_ERROR = 'Ошибка при вcтавке';
  ROOT_LOCAL_MACROS = 'Локальные макросы';
  MSG_REPORT_GROUP = 'Группа отчетов';
  MSG_INVALID_DATA = 'Invalid data';

  MACROS_TEMPLATE = 'Sub %s '#13#10'End Sub';
  PARAMFUNCTION_TEMPLATE = 'Function %s'#13#10'  Dim a(0)'#13#10'  %s = a'#13#10'End Function';
  MAINFUNCTION_TEMPLATE = 'Function %s'#13#10'  Set %s = BaseQuery'#13#10'End Function';
  EVENTFUNCTION_TEMPLATE = 'Function %s(Params, Value, Name)'#13#10'  %s = 1'#13#10'End Function';

  fnHasChildren = 'haschildren';

implementation

uses
  gd_SetDatabase, rp_report_const, gd_security_operationconst,
  rp_dlgEnterParam_unit, rp_frmParamLineSE_unit, gdcConstants,
  rp_StreamFR, rtf_TemplateBuilder, xfr_TemplateBuilder;

{$R *.DFM}

{TdlgViewProperty3}

function TdlgViewProperty3.DeleteReportGroupItem(
  const ANode: TTreeNode): Boolean;
var
  DS: TIBDataSet;
begin
  Result := False;
  DisableControls;
  DisableChanges;
  {здесь не пользуемся gdcReportGroup т.к. он может быть открыт с
  использованием прав доступа и поэтому поле HasChildren может иметь
  значение 0 хотя группа имеет Children.}

  DS := TIBDataSet.Create(nil);
  DS.Transaction := ibtrFunction;
  try
    try
      DS.SelectSQL.Text:= 'SELECT t1.*, (SELECT 1 FROM RDB$DATABASE WHERE ' +
        'EXISTS (SELECT t3.id FROM rp_reportgroup t3 WHERE t3.parent = t1.id) ' +
        'OR EXISTS (SELECT t4.id FROM rp_reportlist t4 WHERE ' +
        't4.ReportGroupKey = t1.id)) AS HASCHILDREN ' +
        ' FROM rp_reportgroup t1  ' + ' WHERE t1.id = :ID ';
      DS.ParamByName('id').AsInteger :=
        gdcReportGroup.FieldByName(fnId).AsInteger;
      DS.Open;
      if DS.FieldByName('haschildren').AsInteger = 0 then
      begin
        if gdcReportGroup.State = dsInsert then
          CancelReportGroup
        else
        begin
          gdcReportGroup.Delete;
          tvClasses.Selected.Delete;
        end;

        CommitTrans;
        Result := True;
        NoChanges;
      end else
        MessageBox(Handle, MSG_CAN_NOT_DELETE_FOULDER,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR);
        RollbackTrans;
      end;
    end;
  finally
    DS.Free;
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty3.PostReport(
  const AReportNode: TTreeNode): Boolean;
var
  ReportItem: TscrReportItem;
begin
  Result := False;
  if not IsReport(AReportNode) then
    Exit;

  if TscrReportItem(AReportNode.Data).MainFormulaKey = 0 then
  begin
    //Основная функция неопределена. Выходим
    MessageBox(Handle, MSG_NEED_MAIN_FORMULA_KEY, MSG_ERROR, MB_OK or MB_ICONERROR);
    Exit;
  end;

  try
    DisableControls;
    try
      ReportItem := TscrReportItem(AReportNode.Data);
      if gdcReport.FieldByName(fnId).IsNull then
      begin
        //Отчет новый. Генерируем ИД
        gdcReport.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcReport.Database, gdcReport.Transaction);
      end;

      if ReportItem.EventFormulaKey > 0 then
        gdcReport.FieldByName(fnEventFormulaKey).AsInteger :=
          ReportItem.EventFormulaKey
      else
        gdcReport.FieldByName(fnEventFormulaKey).Clear;

      gdcReport.FieldByName(fnMainFormulaKey).AsInteger :=
        ReportItem.MainFormulaKey;

      if ReportItem.ParamFormulaKey > 0 then
        gdcReport.FieldByName(fnParamFormulaKey).AsInteger :=
          ReportItem.ParamFormulaKey
      else
        gdcReport.FieldByName(fnParamFormulaKey).Clear;

      {if ReportItem.TemplateKey > 0 then
        gdcReport.FieldByName(fnTemplateKey).AsInteger :=
          ReportItem.TemplateKey
      else
        gdcReport.FieldByName(fnTemplateKey).Clear;}

      gdcReport.FieldByName(fnName).AsString := AReportNode.Text;

      gdcReport.FieldByName(fnReportGroupKey).AsInteger :=
        TscrReportGroupItem(AReportNode.Parent.Data).Id;

      gdcReport.Post;
      ReportItem.Id := gdcReport.FieldByName(fnId).AsInteger;

      FReportChanged := False;

      FReportCreated := False;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(MSG_ERROR_SAVE_REPORT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR);
      end;
  end;
  finally
    EnableControls;
  end;
end;

function TdlgViewProperty3.PostReportGroup(
  const ANode: TTreeNode): Boolean;
var
  ReportGroup: TscrReportGroupItem;
begin
  Result := False;
  if not IsReportFolder(ANode) then
    Exit;
  try
    DisableControls;
    try
      ReportGroup := TscrReportGroupItem(ANode.Data);
      if gdcReportGroup.FieldByName(fnId).IsNull then
      begin
        gdcReportGroup.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcReportGroup.Database, gdcReportGroup.Transaction);
      end;

      if ReportGroup.Parent > 0 then
        gdcReportGroup.FieldByName(fnParent).AsInteger := ReportGroup.Parent
      else
        gdcReportGroup.FieldByName(fnParent).Clear;

      gdcReportGroup.FieldByName(fnName).AsString := ANode.Text;
      gdcReportGroup.FieldByName(fnUserGroupName).AsString :=
        IntToStr(gdcReportGroup.FieldByName(fnId).AsInteger);

      gdcReportGroup.Post;

      ReportGroup.Id := gdcReportGroup.FieldByName(fnId).AsInteger;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR);
      end;
    end;
  finally
    EnableControls;
  end
end;

function TdlgViewProperty3.AddReportItem(const AItem: TscrReportItem;
  const AParent: TTreeNode; Save: Boolean = True): TTreeNode;
var
  TmpFnc: TscrReportFunction;
  Tmptempl: TscrReportTemplate;
  I: Integer;
  TN: TTreeNode;
const
  //Массив с именами функций
  Names: array[0..2] of String = (PARAM_FUNCTION,MAIN_FUNCTION,EVENT_FUNCTION) ;
  //Массив с типами функций
  Types: array[0..2] of TscrReportFncType = (rfParamFnc, rfMainFnc, rfEventFnc);
begin
  Result := tvClasses.Items.AddChild(AParent, AItem.Name);
  Result.Data := AItem;
  Result.ImageIndex := 10;
  Result.SelectedIndex := Result.ImageIndex;
  if Save then
   FObjectList.Add(AItem);

  //добавляем ноды функций отчёта
  for I := 0 to 2 do
  begin
    TmpFnc := TscrReportFunction.Create;
    TmpFnc.Name := Names[I];
    TmpFnc.FncType := Types[I];
    case TmpFnc.FncType of
      rfParamFnc: TmpFnc.Id := AItem.ParamFormulaKey;
      rfMainFnc: TmpFnc.Id := AItem.MainFormulaKey;
      rfEventFnc: TmpFnc.Id := AItem.EventFormulaKey;
    end;
    TN := tvClasses.Items.AddChild(Result, TmpFnc.Name);
    TN.Data := TmpFnc;
    if Save then
      FObjectList.Add(TmpFnc);
  end;

  //Добавляем нод шаблона
  TmpTempl := TscrReportTemplate.Create;
  TmpTempl.Id := AItem.TemplateKey;
  TN := tvClasses.Items.AddChild(Result, TEMPLATE);
  TN.Data := TmpTempl;
  if Save then
    FObjectList.Add(TmpTempl);
end;

{procedure TdlgViewProperty3.ShowReportGroup(Parent: TTreeNode);
var
  TN: TTreeNode;
  TmpGrp: TscrReportGroupItem;
  TmpItm: TscrReportItem;
  gdcRG: TgdcReportGroup;
  gdcR: TgdcReport;
begin
  if not IsReportFolder(Parent) then
    Exit;

  DisableControls;

  gdcRG := TgdcReportGroup.Create(nil);
  try
    gdcr := TgdcReport.Create(nil);
    try
      StartTrans;

      if TscrReportGroupItem(Parent.Data).Id > 0 then
      begin
        gdcRG.SubSet := ssReportGroup;
        gdcRG.ParamByName('Parent').AsInteger :=
          TscrReportGroupItem(Parent.Data).Id;
      end else
        gdcRG.SubSet := ssNullReportGroup;

      gdcRG.Open;
      if not gdcRG.IsEmpty then
      begin
        gdcRG.First;
        while not gdcRG.Eof do
        begin
          TmpGrp := TscrReportGroupItem.Create;
          TmpGrp.ReadFromDataSet(gdcRG);
          if FCopiedID <> TmpGrp.ID then
          begin  //проверка нужна для переносов и копирования
            TN := AddItemNode(TmpGrp, Parent);
            TN.HasChildren := Boolean(gdcRG.FieldByName(fnHasChildren).AsInteger);
            TmpGrp.ChildIsRead := not TN.HasChildren;
          end else
            TmpGrp.Free;
          gdcRG.Next;
        end;
      end;

      if TscrReportGroupItem(Parent.Data).Id > 0 then
      begin
        gdcR.SubSet := ssReportGroup;
        gdcR.ParamByName('reportgroupkey').AsInteger :=
          TscrReportGroupItem(Parent.Data).Id;
        gdcR.Open;

        if not gdcR.IsEmpty then
        begin
          gdcR.First;
          while not gdcR.Eof do
          begin
            TmpItm := TscrReportItem.Create;
            TmpItm.ReadFromDataSet(gdcR);
            if FCopiedID <> TmpItm.ID then
            begin  //проверка нужна для переносов и копирования
              AddReportItem(TmpItm, Parent);
            end else
              TmpItm.Free;
            gdcR.Next;
          end;
        end;
      end;
      TscrReportGroupItem(Parent.Data).ChildIsRead := True;
    finally
      gdcR.Free;
    end;
  finally
    gdcRG.Free;
    EnableControls;
  end;
end;
 }
procedure TdlgViewProperty3.ShowReportTreeRoot(AComponent: TComponent);
var
  TmpGrp: TscrReportGroupItem;
  TN: TTreeNode;
begin
  if (AComponent is TForm) or (AComponent = Application) then
  begin
    DisableControls;
    try
      StartTrans;
      TmpGrp := TscrReportGroupItem.Create;
      TmpGrp.Name := REPORTS;
      TmpGrp.Id := 0;
      TN := AddItemNode(TmpGrp, nil);
      gdcReportGroup.Close;
      if (AComponent = Application) then
      begin
{        gdcReportGroup.SubSet := ssNullReportGroup;
        gdcReportGroup.Open;

        TN.HasChildren := not gdcReportGroup.IsEmpty;
        }
        //При загрузке групп будем отличать главную группу
        TmpGrp.Id := - 1;
      end else if (AComponent is TForm) then
      begin
        gdcObject.Close;
        gdcObject.SubSet := ssById;
        gdcObject.Id := FObjectKey;
        gdcObject.Open;

        gdcReportGroup.SubSet := ssByID;
        gdcReportGroup.ParamByName(fnId).AsInteger :=
            gdcObject.FieldByName(fnReportGroupKey).AsInteger;
        gdcReportGroup.Open;

        if gdcReportGroup.IsEmpty then
        begin
          LoadReportGroup(TN);
          PostReportGroup(TN);
          gdcObject.Edit;
          gdcObject.FieldByName(fnReportGroupKey).AsInteger := TmpGrp.Id;
          gdcObject.Post;
          if not gdcReportGroup.Active then
            gdcReportGroup.Open;
        end;

        TmpGrp.Id := gdcReportGroup.FieldByName(fnId).AsInteger;
        TN.HasChildren :=
          Boolean(gdcReportGroup.FieldByName(fnHasChildren).AsInteger);
      end;

      TmpGrp.ChildIsRead := not TN.HasChildren;
    finally
      CommitTrans;
      EnableControls;
    end;
  end;
end;

{procedure TdlgViewProperty3.ViewEvent;
begin

end;

procedure TdlgViewProperty3.ViewMacros;
begin

end;

procedure TdlgViewProperty3.ViewParam(const AnParam: Variant);
begin
  if VarIsArray(AnParam) then
  begin
    with TdlgEnterParam.Create(Self) do
    try
      ViewParam(AnParam);
    finally
      Free;
    end;
  end else
    MessageBox(Self.Handle, 'Результат функции должен быть массивом.',
      MSG_ERROR, MB_OK or MB_ICONERROR);
end;}

function TdlgViewProperty3.PostMacrosGroup(const ANode: TTreeNode): Boolean;
var
  TmpGrp:  TscrMacrosGroupItem;
begin
  Result := False;

  if not IsMacrosFolder(ANode) then
    Exit;

  TmpGrp := TscrMacrosGroupItem(ANode.Data);
  try
    DisableControls;

    {!!!} // Комментрарий обязательно
    if gdcMacrosGroup.FieldByName(fnId).IsNull then
    begin
      gdcMacrosGroup.FieldByName(fnId).AsInteger :=
        GetUniqueKey(gdcMacrosGroup.Database, gdcMacrosGroup.Transaction);
    end;

    if TmpGrp.Parent = 0 then
      gdcMacrosGroup.FieldByName(fnParent).Clear
    else
      gdcMacrosGroup.FieldByName(fnParent).AsInteger := TmpGrp.Parent;

    gdcMacrosGroup.FieldByName(fnName).AsString := ANode.Text;
    gdcMacrosGroup.FieldByName(fnIsGlobal).AsInteger := Integer(TmpGrp.IsGlobal);

    gdcMacrosGroup.Post;

    TmpGrp.Id := gdcMacrosGroup.FieldByName(fnId).AsInteger;

    Result := True;
    EnableControls;
  except
    on E: Exception do
    begin
      EnableControls;
      MessageBox(Handle, PChar(MSG_ERROR_SAVE + E.Message),
        MSG_ERROR, MB_OK or MB_ICONERROR);
    end;
  end;
end;

function TdlgViewProperty3.DeleteMacrosGroupItem(
  const ANode: TTreeNode): Boolean;
var
  DS: TIBDataSet;
begin
  Result := False;
  DisableControls;
  DisableChanges;
  {здесь не пользуемся gdcMacrosGroup т.к. он может быть открыт с
  использованием прав доступа и поэтому поле HasChildren может иметь
  значение 0 хотя группа имеет Children.}

  DS := TIBDataSet.Create(nil);
  DS.Transaction := ibtrFunction;
  try
    try
      DS.SelectSQL.Text:= 'SELECT t1.*, (SELECT 1 FROM RDB$DATABASE WHERE ' +
        'EXISTS (SELECT t3.id FROM EVT_MACROSGROUP t3 WHERE t3.parent = t1.id) ' +
        'OR EXISTS (SELECT t4.id FROM evt_macroslist t4 WHERE ' +
        't4.MacrosGroupKey = t1.id)) AS HASCHILDREN ' +
        ' FROM evt_macrosgroup t1  ' + ' WHERE t1.id = :ID ';
      DS.ParamByName('id').AsInteger :=
        gdcMacrosGroup.FieldByName(fnId).AsInteger;
      DS.Open;
      if DS.FieldByName('haschildren').AsInteger = 0 then
      begin
        if gdcMacrosGroup.State = dsInsert then
          CancelMacrosGroup
        else
        begin
          gdcMacrosGroup.Delete;
          tvClasses.Selected.Delete;
        end;

        CommitTrans;
        Result := True;
        NoChanges;
      end else
        MessageBox(Handle, MSG_CAN_NOT_DELETE_FOULDER,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR);
        RollbackTrans;
      end;
    end;
  finally
    DS.Free;
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty3.DeleteMacros(
  const ANode: TTreeNode): Boolean;
begin
  try
    DisableControls;
    DisableChanges;
    try
      Assert(IsEditMacros(ANode), MSG_INVALID_DATA);
      if gdcMacros.State = dsInsert then
      begin
        CancelMacros;
      end else
      begin
        gdcMacros.Delete;
        tvClasses.Selected.Delete;
        try
          gdcFunction.Delete;
        except
          on E: Exception do
            MessageBox(Handle, PChar(E.Message),
              MSG_ERROR, MB_OK or MB_ICONERROR);
        end;
      end;

      Result := True;
      CommitTrans;
      NoChanges;
    except
      RollbackTrans;
      Result := False;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty3.AddItemNode(const Item: TscrCustomItem;
  const Parent: TTreeNode; Save: Boolean = True): TTreeNode;
begin
  Result := tvClasses.Items.AddChild(Parent, Item.Name);
  Result.Data := Item;
  if Save then
    FObjectList.Add(Item);
end;

procedure TdlgViewProperty3.ShowMacrosTreeRoot(AComponent: TComponent);
var
  Node: TTreeNode;
  TmpGrp: TscrMacrosGroupItem;
begin
  try
    DisableControls;

    StartTrans;
    //чтение Глобальной группы макросов
    gdcMacrosGroup.Close;
    gdcMacrosGroup.SubSet := ssById;
    gdcMacrosGroup.Id := OBJ_GLOBALMACROS;
    gdcMacrosGroup.Open;
    Assert (not gdcMacrosGroup.IsEmpty);

    TmpGrp := TscrMacrosGroupItem.Create;
    TmpGrp.ReadFromDataSet(gdcMacrosGroup);
    Node := AddItemNode(TmpGrp, nil);
    Node.HasChildren := Boolean(gdcMacrosGroup.FieldByName(fnHasChildren).AsInteger);
    TmpGrp.ChildIsRead := not Node.HasChildren;
    //чтение локольной группы макросов
    if AComponent <> Application then
    begin
      //ищем запись с Id = FObjectKey для полущения
      //значения MacrosGroupKey
      gdcObject.Close;
      gdcObject.SubSet := ssById;
      gdcObject.ID := FObjectKey;
      gdcObject.Open;

      //ищем группу локальных макросов
      gdcMacrosGroup.Close;
      gdcMacrosGroup.SubSet := ssById;
      gdcMacrosGroup.Id := gdcObject.FieldByName(fnMacrosGroupKey).AsInteger;
      gdcMacrosGroup.Open;
      TmpGrp := TscrMacrosGroupItem.Create;
      TmpGrp.Name := ROOT_LOCAL_MACROS;
      TmpGrp.IsGlobal := False;
      Node := AddItemNode(TmpGrp, nil);

      if gdcMacrosGroup.IsEmpty then
      begin
        //для данного объекта нет группы макросов.
        //создаём её
        LoadMacrosGroup(Node);
        PostMacrosGroup(Node);

        gdcObject.Edit;
        gdcObject.FieldByName(fnMacrosGroupKey).AsInteger :=
          gdcMacrosGroup.FieldByName(fnId).AsInteger;
        gdcObject.Post;
      end;
      TmpGrp.ReadFromDataSet(gdcMacrosGroup);
      Node.HasChildren := Boolean(gdcMacrosGroup.FieldByName(fnHasChildren).AsInteger);
      TmpGrp.ChildIsRead := not Node.HasChildren;
    end;
  finally
    CommitTrans;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.ShowMacrosGroup(Parent: TTreeNode);
var
  Node: TTreeNode;
  GroupKey: Integer;
  TmpGrp: TscrMacrosGroupItem;
  TmpItem: TscrMacrosItem;
  gdcMG: TgdcMacrosGroup;
  gdcM: TgdcMacros;
begin
  DisableControls;
  gdcMG := TgdcMacrosGroup.Create(nil);
  try
    gdcM := TgdcMacros.Create(nil);
    try
      StartTrans;
      GroupKey := (TObject(Parent.Data) as TscrMacrosGroupItem).Id;
      gdcMG.ID := -1; { !!! Ошибка в gdcBase }
      gdcMG.SubSet := ssMacrosGroup;
      gdcMG.ParamByName(fnParent).AsInteger := GroupKey;
      gdcMG.Open;
      // чтение входящих групп
      while not gdcMG.Eof do
      begin
        TmpGrp := TscrMacrosGroupItem.Create;
        TmpGrp.ReadFromDataSet(gdcMG);
        if FCopiedID <> TmpGrp.ID then
        begin  //проверка нужна для переносов и копирования
          Node := AddItemNode(TmpGrp, Parent);
          Node.HasChildren := Boolean(gdcMG.FieldByName(fnHasChildren).AsInteger);
          TmpGrp.ChildIsRead := not Node.HasChildren;
        end else
          TmpGrp.Free;
        gdcMG.Next;
      end;
      gdcM.SubSet := ssMacrosGroup;
      gdcM.ID := -1; { !!! Ошибка в gdcBase }
      gdcM.ParamByName(fnMacrosGroupKey).AsInteger := GroupKey;
      gdcM.Open;
      //чтение макросов
      while not gdcM.Eof do
      begin
       TmpItem := TscrMacrosItem.Create;
       TmpItem.ReadFromDataSet(gdcM);
        if FCopiedID <> TmpItem.ID then
        begin  //проверка нужна для переносов и копирования
          AddItemNode(TmpItem, Parent);
        end else
          TmpItem.Free;
        gdcM.Next;
      end;
      TscrMacrosGroupItem(Parent.Data).ChildIsRead := True;
    finally
      gdcM.Free;
    end;
  finally
    gdcMG.Free;
    EnableControls;
  end;
end;

function TdlgViewProperty3.PostMacros(const AMacrosNode: TTreeNode): Boolean;
var
  TmpMcr: TscrMacrosItem;
  LFunctionKey: Integer;
begin
  Result := False;
  if not IsMacros(AMacrosNode) then
    Exit;

  try
    DisableControls;

    Result := PostFunction(LFunctionKey);

    if Result then
    begin
      TmpMcr := TscrMacrosItem(AMacrosNode.Data);
      TmpMcr.FunctionKey := LFunctionKey;
      if gdcMacros.FieldByName(fnID).IsNull then
      begin
        //макрос новый поэтому получаем айди
        gdcMacros.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcMacros.Database, gdcMacros.Transaction);
      end;

      gdcMacros.FieldByname(fnMacrosGroupKey).AsInteger := TmpMcr.GroupKey;
      gdcMacros.FieldByName(fnFunctionKey).AsInteger := TmpMcr.FunctionKey;
      gdcMacros.FieldByName(fnName).AsString := AMacrosNode.Text;

      gdcMacros.Post;

      TmpMcr.Id := gdcMacros.FieldByName(fnId).AsInteger;

      gdcMacros.Close;
      Result := True;
    end;

    EnableControls;
  except
    on E: Exception do
    begin
      EnableControls;
      MessageBox(Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
        MSG_ERROR, MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TdlgViewProperty3.Execute(const AnComponent: TComponent;
     const AnShowMode: TShowModeSet = smAll; const AnName: String = '');
begin
  FObjectKey := gdcObject.AddObject(AnComponent);

  if smMacros in AnShowMode then
    ShowMacrosTreeRoot(AnComponent);

  if smReport in AnShowMode then
    ShowReportTreeRoot(AnComponent);

  inherited Execute(AnComponent, AnShowMode, AnName);
end;

function TdlgViewProperty3.OverallCommit: Boolean;
begin
  Result := False;
  if FChanged or FFunctionChanged then
  begin

    case GetSelectedNodeType of
      fpMacros:
      begin
        //сохраняем изменения макроса
        Result := PostMacros(tvClasses.Selected);
      end;
      fpMacrosFolder:
        //сохраняем изменения группы макросов
        Result := PostMacrosGroup(tvClasses.Selected);
      fpReportFolder:
        //сохраняем изменения группы отчётов
        Result := PostReportGroup(tvClasses.Selected);
      fpReportFunction:
      begin
        Result := PostReportFunction(tvClasses.Selected);
      end;
      fpReport:
        //сохраняем отчёт
        if FCanSaveLoad then
          Result := PostReport(tvClasses.Selected);
      fpReportTemplate:
        Result := PostReportTemplate(tvClasses.Selected);
    else
      Result := inherited OverallCommit;
    end;

    if not FReportCreated then
    begin
      if Result then //если все ОК делаем полный коммит
        Result := CommitTrans
      else
        ibtrFunction.RollbackRetaining;
    end;

      FChanged := (not Result) or (FReportCreated);
  end else
    Result := True;
end;

procedure TdlgViewProperty3.actAddMacrosExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  MacrosItem: TscrMacrosItem;

begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpMacros, fpMacrosFolder]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    MacrosItem := TscrMacrosItem.Create;

    MacrosItem.Name := gdcMacros.GetUniqueName(NEW_MACROS_NAME, '');
    MacrosItem.IsGlobal := TscrMacrosGroupItem(ParentFolder.Data).IsGlobal;
    MacrosItem.GroupKey := TscrMacrosGroupItem(ParentFolder.Data).Id;
    Node := AddItemNode(MacrosItem, ParentFolder);
    Node.Selected := True;
    Node.EditText;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty3.actAddFolderExecute(Sender: TObject);
var
  Node, ParentFolder: TTreeNode;
  MacrosGroupItem: TscrMacrosGroupItem;
  ReportGroupItem: TscrReportGroupItem;
begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpMacros, fpMacrosFolder, fpReport, fpReportFolder]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    if TObject(ParentFolder.Data) is TscrMacrosGroupItem then
    begin
      MacrosGroupItem := TscrMacrosGroupItem.Create;
      MacrosGroupItem.Name := GetName(NEW_FOLDER_NAME, ParentFolder);
      MacrosGroupItem.IsGlobal := TscrMacrosGroupItem(ParentFolder.Data).IsGlobal;
      MacrosGroupItem.Parent := TscrMacrosGroupItem(ParentFolder.Data).Id;
      Node := AddItemNode(MacrosGroupItem, ParentFolder);
      Node.Selected := True;
      Node.EditText;
    end
    else
      if TObject(ParentFolder.Data) is TscrReportGroupItem then
      begin
        ReportGroupItem := TscrReportGroupItem.Create;
        ReportGroupItem.Name := GetName(MSG_REPORT_GROUP, ParentFolder);
        ReportGroupItem.Parent := TscrreportGroupItem(ParentFolder.Data).id;
        Node := AddItemNode(ReportGroupItem, ParentFolder);
        Node.Selected := True;
        Node.EditText;
      end;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty3.actAddFolderUpdate(Sender: TObject);
begin
  actAddFolder.Enabled := GetSelectedNodeType in [fpMacros, fpMacrosFolder,
      fpReportFolder, fpReport];
end;

procedure TdlgViewProperty3.actAddMacrosUpdate(Sender: TObject);
begin
  actAddMacros.Enabled := GetSelectedNodeType in [fpMacros, fpMacrosFolder];
end;

procedure TdlgViewProperty3.actDeleteFolderExecute(Sender: TObject);
begin
  if not IsEditFolder(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING) = IDOK then
      if not ((IsMacrosFolder(tvClasses.Selected) and
        DeleteMacrosGroupItem(tvClasses.Selected)) or
        (IsReportFolder(tvClasses.Selected) and
        DeleteReportGroupItem(tvClasses.Selected)))then

        MessageBox(Handle, MSG_CAN_NOT_DELETE_FOULDER,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
end;

procedure TdlgViewProperty3.actDeleteFolderUpdate(Sender: TObject);
begin
  actDeleteFolder.Enabled := IsEditFolder(tvClasses.Selected);
end;

procedure TdlgViewProperty3.actDeleteMacrosExecute(Sender: TObject);
begin
  if not IsEditMacros(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING) = IDOK then
      if not DeleteMacros(tvClasses.Selected) then
        Application.MessageBox(MSG_CAN_NOT_DELETE_MACROS,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
end;

procedure TdlgViewProperty3.actDeleteMacrosUpdate(Sender: TObject);
begin
  actDeleteMacros.Enabled :=  IsEditMacros(tvClasses.Selected);
end;

procedure TdlgViewProperty3.actRenameExecute(Sender: TObject);
begin
  if not (GetNodeType(tvClasses.Selected) in [fpMacros, fpMacrosFolder,
    fpReport, fpReportFolder]) then
    Exit
  else
    tvClasses.Selected.EditText;
end;

procedure TdlgViewProperty3.actRenameUpdate(Sender: TObject);
begin
  actRename.Enabled := IsEditMacros(tvClasses.Selected) or
    IsEditFolder(tvClasses.Selected) or IsReport(tvClasses.Selected);
end;

procedure TdlgViewProperty3.tvClassesExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
{  if IsMacrosFolder(Node) and Node.HasChildren and
    (not TscrMacrosgroupItem(Node.Data).ChildIsRead) then
    ShowMacrosGroup(Node)
  else
    if IsReportFolder(Node) and Node.HasChildren and
      (not TscrReportGroupItem(Node.Data).ChildIsRead) then
      ShowReportGroup(Node);
    }
end;

procedure TdlgViewProperty3.actAddReportExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  ReportItem: TscrReportItem;

begin
  if not (GetNodeType(tvClasses.Selected) in [fpReport, fpReportFolder])then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    ReportItem := TscrReportItem.Create;

    ReportItem.Name := gdcReport.GetUniqueName(NEW_REPORT_NAME, '');
    ReportItem.ReportGroupKey := TscrReportGroupItem(ParentFolder.Data).Id;
    Node := AddReportItem(ReportItem, ParentFolder);
    Node.Selected := True;
    Node.EditText;
    FChanged := True;
    FReportCreated := True;
  end;
end;

procedure TdlgViewProperty3.actAddReportUpdate(Sender: TObject);
begin
  actAddReport.Enabled := (GetNodeType(tvClasses.Selected) in [fpReport, fpReportFolder]) and
    (TscrReportGroupItem(GetParentFolder(tvClasses.Selected).Data).Id > 0);
end;

procedure TdlgViewProperty3.tvClassesChange(Sender: TObject;
  Node: TTreeNode);
begin
  //Отслючаем контролы
  DisableControls;

  StartTrans;
  try
    if GetSelectedNodeType = fpNone then
      Exit;

    if ibqrySetFunction.Active then
      ibqrySetFunction.Close;

    case GetSelectedNodeType of
      fpMacros: LoadMacros(tvClasses.Selected);
      fpMacrosFolder: LoadMacrosGroup(tvClasses.Selected);
      fpReportFolder: LoadReportGroup(tvClasses.Selected);
      fpReportFunction: LoadReportFunction(tvClasses.Selected);
      fpReport: LoadReport(tvClasses.Selected);
      fpReportTemplate: LoadReportTemplate(tvClasses.Selected);
    else
      inherited tvClassesChange(Sender, Node);
    end;

  finally
    //Включаем контролы
    EnableControls;
    //изменяем отображение закладок
    ChangePageVisible;
  end;
end;

procedure TdlgViewProperty3.tvClassesChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);

  function IsRepNode(Node: TTreeNode):Boolean;
  begin
    Result := GetNodeType(Node) in [fpReport, fpReportFunction, fpReportTemplate];
  end;

begin
  if FEnableChanges then //Флаг указывает на необходимость сохранения изменений
  //Равен Фалсе если идет активная работа с деревом на которую нет необходимости
  //реагировать (например удаление нодов при ролбэке)
  begin
    //эта офигенная проверка нужна для правильной работы отчётов
    //при создании нового отчёта
    if (tvClasses.Selected = Node) and (GetNodeType(Node) = fpReportFunction) then
    begin //Переход с самого на себя
      AllowChange := True;
    end else if (GetNodeType(tvClasses.Selected) = fpReport) and
      IsChild(Node, tvClasses.Selected) and FReportCreated then
    begin //переход с вновь созданного отчета на функцию или шаблон
      AllowChange := True;
      FCanSaveLoad := False; //Если отчет вновь созданный то запрещаем загрузку и запись
    end else if (GetNodeType(tvClasses.Selected) in [fpReportFunction, fpReportTemplate]) and
      (GetNodeType(Node) in [fpReport, fpReportFunction, fpReportTemplate]) and
      ((tvClasses.Selected.Parent = Node) or (Node.Parent = tvClasses.Selected.Parent)) then
    begin //Переход с функции или шаблона
      if FReportCreated then
        FCanSaveLoad := False;  //Если отчет вновь созданный то запрещаем загрузку и запись
      if FReportChanged or (not FReportCreated and FChanged) then
        //Изменена функция или шаблон. Вызываем запрос на сохранение
        inherited tvClassesChanging(Sender, Node, AllowChange);
      if FFunctionChanged then
        AllowChange := OverallCommit;
    end else
      begin
      FCanSaveLoad := True;  //Разрешаем загрузку и запись отчета
      //Вызываем запрос на сохранение
      inherited tvClassesChanging(Sender, Node, AllowChange);
    end;
  end;
end;

function TdlgViewProperty3.GetParentFolder(ANode: TTreeNode): TTreeNode;
begin
  Result := ANode;
  While not (GetNodeType(Result) in [fpMacrosFolder, fpReportFolder]) and
   Assigned(Result) do
    Result := Result.Parent;
end;

procedure TdlgViewProperty3.tvClassesEditing(Sender: TObject;
  Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := False;
  if (IsEditFolder(Node) or IsEditMacros(Node) or IsReport(Node)) then
    AllowEdit := True;
end;

procedure TdlgViewProperty3.tvClassesEdited(Sender: TObject;
  Node: TTreeNode; var S: String);

  //Возвращает тру если АНаме уже существует
  function AllReady(const AName: String; ANode: TTreeNode): Boolean;
  var
    I: Integer;
  begin
    DisableControls;
    try
      if IsMacros(ANode) then
        Result := gdcMacros.CheckMacros(AName)
      else if  IsReport(ANode) then
        Result := gdcReport.CheckReport(AName)
      else
      begin
        I := 0;
        while (I < ANode.Parent.Count) and
          (AName <> ANode.Parent.Item[I].Text) do
          Inc(I);
        Result := I < ANode.Parent.Count;
      end;
    finally
      EnableControls;
    end;
  end;

begin
  if not Assigned(Node.Data) then
    Exit;

  // Выходим если в базе уже есть такое имя или новое имя пустое
  if (S = '') or (AllReady(S,Node)) then
  begin
    S := Node.Text;
    Exit;
  end;

  if GetNodeType(Node) = fpReport then
  begin
    gdcReport.FieldByName(fnName).AsString := S;
  end;
  FChanged := True;
end;

procedure TdlgViewProperty3.tvClassesGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  case GetNodeType(Node) of
    fpMacrosFolder:
    begin
      Node.SelectedIndex := 7;
      Node.ImageIndex := 6;
    end;
    fpMacros:
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpReportFolder:
    begin
      Node.SelectedIndex := 9;
      Node.ImageIndex := 8;
    end;
    fpReport:
    begin
      Node.ImageIndex := 10;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpReportFunction:
    begin
      Node.ImageIndex := 4;
      Node.SelectedIndex := Node.ImageIndex;
    end;
  end;
end;

procedure TdlgViewProperty3.tvClassesDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode :TTreeNode;
begin
  TargetNode := tvClasses.GetNodeAt(X, Y);
  Accept := CanPaste(FCopyNode, TargetNode);
end;

procedure TdlgViewProperty3.tvClassesEndDrag(Sender, Target: TObject; X,
  Y: Integer);
var
  TargetNode: TTreeNode;
begin
  if X + Y = 0 then
    Exit;
  TargetNode := tvClasses.GetNodeAt(X,Y);
  if not CanPaste(tvClasses.Selected, TargetNode) then
    Exit;
  Paste(TargetNode);
end;

procedure TdlgViewProperty3.NodeCopy(SourceNode, TargetNode: TTreeNode);
var
  Item: pointer;
  TN: TTreeNode;
begin
  //вставить можно только в папку
  if GetNodeType(TargetNode) in [fpMacrosFolder, fpReportFolder] then
  begin
    Item := nil;
    FParentNode := SourceNode.Parent;
    if FCut then
    begin
      //происходит перемещение
      Item := SourceNode.Data;
      FCopiedID := (TObject(Item) as TscrCustomItem).Id;
    end else
    begin
      DisableControls;
      case TscrCustomItem(SourceNode.Data).ItemType of
        //происходит копирование
        itMacros:
        begin
          //читаем из базы скопированный макрос
          Item := TscrMacrosItem.Create;
          FObjectList.Add(Item);
          gdcMacros.Close;
          gdcMacros.SubSet := ssById;
          gdcMacros.Id := gdcMacros.LastInsertId;
          FCopiedID := gdcMacros.LastInsertId;
          gdcMacros.Open;
          Assert(not gdcMacros.IsEmpty);
          TscrMacrosItem(Item).ReadFromDataSet(gdcMacros);
        end;
        itReport:
        begin
          //читаем из базы скопированный отчёт
          Item := TscrReportItem.Create;
          FObjectList.Add(Item);
          gdcReport.Close;
          gdcReport.SubSet := ssById;
          gdcReport.Id := gdcReport.LastInsertId;
          FCopiedID := gdcReport.LastInsertId;
          gdcReport.Open;
          Assert(not gdcReport.IsEmpty);
          TscrReportItem(Item).ReadFromDataSet(gdcReport);
        end;
      end;
      EnableControls;
    end;
    //изменяем значения парента
    if TObject(Item) is TscrMacrosGroupItem then
    begin
      TscrMacrosGroupItem(Item).Parent :=
        TscrMacrosGroupItem(TargetNode.Data).Id;
      TscrMacrosGroupItem(Item).ChildIsRead := False;
      TN := AddItemNode(Item, TargetNode, False);
    end else if TObject(Item) is TscrMacrosItem then
    begin
      TscrMacrosItem(Item).GroupKey :=
        TscrMacrosGroupItem(TargetNode.Data).Id;
      TN := AddItemNode(Item, TargetNode, False);
    end else if TObject(Item) is TscrReportItem then
    begin
      TscrReportItem(Item).ReportGroupKey :=
        TscrReportGroupItem(TargetNode.Data).Id;
      TN := AddReportItem(Item, TargetNode, False);
    end else if TObject(Item) is TscrReportGroupItem then
    begin
      TscrReportGroupItem(Item).Parent :=
        TscrReportGroupItem(TargetNode.Data).Id;
      TscrReportGroupItem(Item).ChildIsRead := False;
      TN := AddItemNode(Item, TargetNode, False);
    end else
      Exit;

    TN.Selected := True;
    TN.HasChildren := SourceNode.HasChildren;

    if FCut then
      //удаляем старый нод при переносе
      SourceNode.Delete
    else
      TN.EditText;
    FCopiedId := 0;
  end;
end;

procedure TdlgViewProperty3.OverallRollback;
var
  Flag: Boolean;
  TN: TTreeNode;
begin
  //Сохраняем флаг изменения шаблона или функции отчёта
  Flag := FReportChanged;
  //Делаем канселы соответ. датасеты
  case GetSelectedNodeType of
    fpReportTemplate: CancelTemplate;
    fpReportFunction: CancelReportFunction;
    fpReport: CancelReport;
    fpMacros: CancelMacros;
    fpMacrosFolder: CancelMacrosGroup;
    fpReportFolder: CancelReportGroup;
  end;

  DisableChanges;
  DisableControls;

  if (GetSelectedNodeType in [fpReport, fpReportFunction, fpReportTemplate]) and
      FReportCreated and not Flag then
    begin
      //отчет новый и небыло изменений в шаблоне или функциях
      //удаляем нод
      TN:= tvClasses.Selected;
      if GetSelectedNodeType in [fpReportFunction, fpReportTemplate] then
      begin
        tvClasses.Selected.Parent.Parent.Selected := True;
        TN.Parent.Delete;
      end else
      begin
        tvClasses.Selected.Parent.Selected := True;
        TN.Delete;
      end;
      FReportCreated := False;
    end;

  //Делаем откат если не создан отчёт или создан но не изменен
  if (not FReportCreated) or (FReportCreated and not Flag) then
    inherited OverallRollback;

  EnableControls;
  EnableChanges;
end;

function TdlgViewProperty3.GetObjectId(ANode: TTreeNode): Integer;
begin
  Assert(Assigned(ANode) and Assigned(ANode.Data) and
   Assigned(ANode.Parent.Data), MSG_ERROR);

  if TObject(ANode.Data) is TscrMacrosItem then
  begin
    if TscrMacrosGroupItem(ANode.Parent.Data).IsGlobal then
      Result := OBJ_APPLICATION
    else
      Result := FObjectKey;
  end
  else
    if TObject(ANode.Data) is TscrReportFunction then
      Result := FObjectKey
    else
      Result := inherited GetObjectId(ANode);
end;

function TdlgViewProperty3.IsEditFolder(ANode: TTreeNode): Boolean;
begin
  Result := (GetNodeType(ANode) in [fpMacrosFolder, fpReportFolder])
     and (TscrCustomItem(ANode.Data).Id > 0);
end;

function TdlgViewProperty3.IsEditMacros(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacros;
end;

function TdlgViewProperty3.IsMacrosFolder(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacrosFolder;
end;

function TdlgViewProperty3.IsReportFolder(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReportFolder;
end;

function TdlgViewProperty3.IsMacros(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacros;
end;

function TdlgViewProperty3.IsReport(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReport;
end;

procedure TdlgViewProperty3.tvClassesStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  Cut(tvClasses.Selected);
end;

procedure TdlgViewProperty3.actCutTreeItemExecute(Sender: TObject);
begin
  Cut(tvClasses.Selected);
end;

procedure TdlgViewProperty3.actCutTreeItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := IsEditFolder(tvClasses.Selected) or
    IsEditMacros(tvClasses.Selected) or IsReport(tvClasses.Selected);
end;

procedure TdlgViewProperty3.actPasteFromClipBoardExecute(Sender: TObject);
begin
  Paste(tvClasses.Selected);
end;

procedure TdlgViewProperty3.Cut(Node: TTreeNode);
begin
  Copy(Node, True)
end;

procedure TdlgViewProperty3.Paste(TargetNode: TTreeNode);
var
  gdc: TgdcBase;
  S1, S2, S3: String;
begin
  if Assigned(FCopyNode) and OverallCommit then
  begin
    DisableControls;
    //Формируем значения gdc и S1
    if IsMacrosFolder(TargetNode) then
    begin
      S1 := TscrMacrosGroupItem(TargetNode.Data).Name;
      gdc := gdcMacrosGroup;
      gdc.Close;
      gdc.SubSet := ssById;
      gdc.Id := TscrMacrosGroupItem(TargetNode.Data).Id;
      gdc.Open;
    end else if IsReportFolder(TargetNode) then
    begin
      S1 := TscrReportGroupItem(TargetNode.Data).Name;
      gdc := gdcReportGroup;
      gdc.Close;
      gdc.SubSet := ssById;
      gdc.Id := TscrMacrosGroupItem(TargetNode.Data).Id;
      gdc.Open;
    end else
      Exit;

    //формируем S2
    if IsMacrosFolder(FCopyNode) then
      S2 := TscrMacrosGroupItem(FCopyNode.Data).Name
    else if IsMacros(FCopyNode) then
      S2 := TscrMacrosItem(FCopyNode.Data).Name
    else if IsReportFolder(FCopyNode) then
      S2 := TscrReportGroupItem(FCopyNode.Data).Name
    else if IsReport(FCopyNode) then
      S2 := TscrReportItem(FCopyNode.Data).Name;

    //формируем S3
    if FCut then
      S3 := MSG_CUT
    else
      S3 := MSG_COPY;

    if gdc.CanPasteFromClipboard and (MessageBox(Handle, PChar(Format(MSG_SURE_TO_COPY,[S3,S2, S1])),
       MSG_WARNING, MB_YESNO or MB_ICONWARNING) = IDYES) then
    begin
      //вставляем из клипборда
      if gdc.PasteFromClipboard then
      begin
        //переносим нод
        NodeCopy(FCopyNode, TargetNode);
        if FCut then
          FCopyNode := nil;
      end else
        MessageBox(Handle, MSG_PASTE_ERROR, MSG_ERROR, MB_OK and
          MB_ICONERROR);
    end;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.actPasteFromClipBoardUpdate(Sender: TObject);
var
  gdc: TgdcBase;
begin
  (Sender as TAction).Enabled := False;
  if IsMacrosFolder(tvClasses.Selected) then
    gdc := gdcMacrosGroup
  else if IsReportFolder(tvClasses.Selected) then
    gdc := gdcReportGroup
  else
    Exit;

  (Sender as TAction).Enabled := (gdc.CanPasteFromClipboard and
    CanPaste(FCopyNode, tvClasses.Selected));
end;

function TdlgViewProperty3.CanPaste(Source,
  Target: TTreeNode): Boolean;
begin
  Result := Assigned(Target) and Assigned(Target.Data) and
    Assigned(Source) and (Target <> Source) and
    (not IsChild(Target, Source));

  if FCut then
    Result := Result and (Target <> Source.Parent);

  if IsMacrosFolder(Target) then
    Result := Result and (GetNodeType(Source) in [fpMacrosFolder, fpMacros]) and
     (TscrMacrosGroupItem(Target.Data).IsGlobal =
     TscrMacrosGroupItem(GetParentFolder(Source).Data).IsGlobal)
  else if IsReportFolder(Target) then
    Result := Result and (IsReportFolder(Source) or (IsReport(Source) and
      Assigned(Target.Parent)))
  else Result := False;
end;

procedure TdlgViewProperty3.Copy(Node: TTreeNode; ACut: Boolean);
begin
  if not Assigned(tvClasses.Selected) then
    Exit;

  if OverallCommit then
  begin
    DisableControls;
    FCopyNode := tvClasses.Selected;
    FCut := ACut;
    try
      case GetNodeType(FCopyNode) of
        fpMacros:
        begin
          gdcMacros.Close;
          gdcMacros.SubSet := ssById;
          gdcMacros.Id := TscrMacrosItem(FCopyNode.Data).ID;
          gdcMacros.Open;
          gdcMacros.CopyToClipboard(nil, ACut);
        end;
        fpMacrosFolder:
        begin
          gdcMacrosGroup.Close;
          gdcMacrosGroup.SubSet := ssById;
          gdcMacrosGroup.Id := TscrMacrosGroupItem(FCopyNode.Data).Id;
          gdcMacrosGroup.Open;
          gdcMacrosGroup.CopyToClipboard(nil, ACut);
        end;
        fpReport:
        begin
          gdcReport.Close;
          gdcReport.SubSet := ssById;
          gdcReport.Id := TscrReportItem(FCopyNode.Data).ID;
          gdcReport.Open;
          gdcReport.CopyToClipboard(nil, ACut);
        end;
        fpReportFolder:
        begin
          gdcReportGroup.Close;
          gdcReportGroup.SubSet := ssById;
          gdcReportGroup.Id := TscrReportGroupItem(FCopyNode.Data).Id;
          gdcReportGroup.Open;
          gdcReportGroup.CopyToClipboard(nil, ACut);
        end;
      else
        FCopyNode := nil;
      end;
    finally
      EnableControls;
    end;
  end;
end;

procedure TdlgViewProperty3.actCopyTreeItemExecute(Sender: TObject);
begin
  if GetNodeType(tvClasses.Selected) in [fpMacros, fpReport] then
    Copy(tvClasses.Selected, False);
end;

procedure TdlgViewProperty3.actCopyTreeItemUpdate(Sender: TObject);
begin
  actCopyTreeItem.Enabled := GetNodeType(tvClasses.Selected) in
    [fpMacros, fpReport];
end;

function TdlgViewProperty3.GetNodeType(Node: TTreeNode): TFunctionPages;
begin
  Result := fpNone;
  if Assigned(Node) and Assigned(Node.Data) then
  begin
    if (TObject(Node.Data) is TscrMacrosItem) then
      Result := fpMacros
    else if (TObject(Node.Data) is TscrMacrosGroupItem) then
      Result := fpMacrosFolder
    else if (TObject(Node.Data) is TscrReportFunction) then
      Result := fpReportFunction
    else if (TObject(Node.Data) is TscrReportItem) then
      Result := fpReport
    else if (TObject(Node.Data) is TscrReportGroupItem) then
      Result := fpReportFolder
    else if (TObject(Node.Data) is TscrReportTemplate) then
      Result := fpReportTemplate
    else
      Result := inherited GetNodeType(Node);
  end;
end;

procedure TdlgViewProperty3.SetChanged;
begin
  inherited;

  if (GetSelectedNodeType = fpReportFunction) and FEnableControls then
    FReportChanged := True;
end;

procedure TdlgViewProperty3.LoadFunction(const AnModule: String;
  const AnFunctionKey: Integer; const AnFunctionName, AnParams: String);
begin
  inherited LoadFunction(AnModule, AnFunctionKey, AnFunctionName, AnParams);

  FReportChanged := False;
end;

function TdlgViewProperty3.PostFunction(
  out AnFunctionKey: Integer): Boolean;
begin
  Result := inherited PostFunction(AnFunctionKey);

  if (FReportChanged) and (GetSelectedNodeType = fpReportFunction) then
  begin
    FReportChanged:= not Result;
  end;
end;

procedure TdlgViewProperty3.FormCreate(Sender: TObject);
begin
  inherited;

  FReportChanged := False;
  FCopyNode := nil;
  FCut := True;

  cdsTemplateType.CreateDataSet;
{RTF deleted}
  cdsTemplateType.AppendRecord([ReportFR, 'Шаблон FastReport']);
  cdsTemplateType.AppendRecord([ReportXFR, 'Шаблон xFastReport']);
end;

function TdlgViewProperty3.CommitTrans: Boolean;
begin
  DisableControls;
  try
    Result := inherited CommitTrans;
  finally
    EnableControls;
  end;
end;

function TdlgViewProperty3.DeleteReportItem(
  const ANode: TTreeNode): Boolean;
var
  Keys: array [0..3] of Integer;
  I: Integer;
begin
  DisableControls;
  DisableChanges;
  try
    try
      Assert(IsReport(ANode), MSG_INVALID_DATA);

      Keys[0] := gdcReport.FieldByName(fnMainFormulaKey).AsInteger;
      Keys[1] := gdcReport.FieldByName(fnParamFormulaKey).AsInteger;
      Keys[2] := gdcReport.FieldByName(fnEventFormulaKey).AsInteger;
      Keys[3] := gdcReport.FieldByName(fnTemplateKey).AsInteger;

      if gdcReport.State = dsInsert then
        CancelReport
      else
      begin
        gdcReport.Delete; //Удаляем отчет
      end;

      tvClasses.Selected.Delete;

      for I := 0 to 2 do
      begin
        gdcFunction.Close;
        gdcFunction.SubSet := ssById;
        gdcFunction.ID := Keys[I];
        gdcFunction.Open;
        if not gdcFunction.IsEmpty then
        begin
          try
            gdcFunction.Delete;  //Удаляем функцию
          except
            MessageBox(Handle, PChar(Format(MSG_CANNOT_DELETE_REPORTFUNCTION,
              [gdcFunction.FieldByName(fnName).AsString])), MSG_WARNING, MB_OK or MB_ICONWARNING);
          end;
        end;
      end;

      gdcTemplate.Close;
      gdcTemplate.SubSet := ssById;
      gdcTemplate.ID := Keys[3];
      gdcTemplate.Open;
      if not gdcTemplate.IsEmpty then
      begin
        try
          gdcTemplate.Delete;  //Удаляем шаблон
        except
          MessageBox(Handle, PChar(Format(MSG_CANNOT_DELETE_REPORTTEMPLATE,
            [gdcTemplate.FieldByName(fnName).AsString])), MSG_WARNING, MB_OK or MB_ICONWARNING);
        end;
      end;

      Result := True;
      CommitTrans;
      NoChanges;
    except
      RollBackTrans;
      Result := False;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty3.actDeleteReportUpdate(Sender: TObject);
begin
  actDeleteReport.Enabled := GetSelectedNodeType = fpReport;
end;

procedure TdlgViewProperty3.actDeleteReportExecute(Sender: TObject);
begin
  if not IsReport(tvClasses.Selected) then
    Exit
  else
  begin
    if MessageBox(Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING) = IDOK then
      if not DeleteReportItem(tvClasses.Selected) then
        Application.MessageBox(MSG_CAN_NOT_DELETE_MACROS,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
  end;
end;

procedure TdlgViewProperty3.FuncControlChanged(Sender: TObject);
begin
  SetChanged;
end;

procedure TdlgViewProperty3.NoChanges;
begin
  FChanged := False;
  FReportChanged := False;
end;

procedure TdlgViewProperty3.LoadReport(const Node: TTreeNode);
var
  Report: TscrReportItem;
begin
  Assert(IsReport(Node));

  DisableControls;
  StartTrans;
  try
    //закрываем зависимые датасеты
    if ibqryReportServer.Active then
      ibqryReportServer.Close;
    if ibqryTemplate.Active then
      ibqryTemplate.Close;

    //загружаем если не создан новый отчёт
    if not (gdcReport.State = dsInsert) then
    begin
      Report := TscrReportItem(Node.Data);
      gdcReport.Close;
      gdcReport.SubSet := ssById;
      gdcReport.Id := - 1;
      gdcReport.ID := Report.Id;
      gdcReport.Open;
      if gdcReport.IsEmpty then
      begin
        gdcReport.Insert;
        gdcReport.FieldByName(fnName).AsString := Node.Text;
      end else
        gdcReport.Edit;
    end;

    Node.Text := gdcReport.FieldByName(fnName).AsString;

    ibqryReportServer.Open;
    ibqryTemplate.Open;

  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.LoadReportGroup(const Node: TTreeNode);
var
  ReportGroup: TscrReportGroupItem;
begin
  Assert(IsReportFolder(Node));

  DisableControls;
  StartTrans;
  try
    ReportGroup := TscrReportGroupItem(Node.Data);
    gdcReportGroup.Close;
    if ReportGroup.Id > -1 then
    begin
      gdcReportGroup.SubSet := ssById;
      gdcReportGroup.ID := ReportGroup.Id;
      gdcReportGroup.Open;
      if gdcReportGroup.IsEmpty then
      begin
        gdcReportGroup.Insert;
        gdcReportGroup.FieldByName(fnName).AsString := Node.Text;
      end else
        gdcReportGroup.Edit;

      Node.Text := gdcReportGroup.FieldByName(fnName).AsString;
    end;
  finally
    //Устанавливаем датасет для описания
    dsDescription.DataSet := gdcReportGroup;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.ControlChange(Sender: TObject);
begin
  if FEnableControls then
  begin
    FChanged := True;
    FReportChanged := True;
  end;
end;

procedure TdlgViewProperty3.LoadMacrosGroup(const Node: TTreeNode);
var
  MacrosGroup: TscrMacrosGroupItem;
begin
  Assert(IsMacrosFolder(Node));

  DisableControls;
  StartTrans;
  try
    MacrosGroup := TscrMacrosGroupItem(Node.Data);
    gdcMacrosGroup.Close;
    gdcMacrosGroup.SubSet := ssById;
    gdcMacrosGroup.ID := MacrosGroup.Id;
    gdcMacrosGroup.Open;
    if gdcMacrosGroup.IsEmpty then
    begin
      gdcMacrosGroup.Insert;
      gdcMacrosGroup.FieldByName(fnName).AsString := Node.Text;
    end else
      gdcMacrosGroup.Edit;

    Node.Text := gdcMacrosGroup.FieldByName(fnName).AsString;
  finally
    //Устанавливаем датасет для описания
    dsDescription.DataSet := gdcMacrosGroup;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.tvClassesDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Node = FCopyNode then
    FCopyNode := nil;
end;

procedure TdlgViewProperty3.dbcbReportServerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    dbmDescriptionChange(Sender);
    DisableControls;
    gdcReport.FieldByName('serverkey').Clear;
    EnableControls;
  end;
end;

function TdlgViewProperty3.PostReportFunction(
  const AReportFunctionNode: TTreeNode): Boolean;
var
  LFunctionKey: Integer;
  VFunctionKey: Variant;
begin
  LFunctionKey := (TObject(AReportFunctionNode.Data) as TscrCustomItem).Id;
  try
    //сохраняем изменения функции отчётов
    Result := PostFunction(LFunctionKey);
    DisableControls;
    if Result then
    begin
      (TObject(AReportFunctionNode.Data) as TscrReportFunction).Id := LFunctionKey;
      case (TObject(AReportFunctionNode.Data) as TscrReportFunction).FncType of
        //функция должна быть одной из:
        rfMainFnc:
        begin
          TscrReportItem(AReportFunctionNode.Parent.Data).MainFormulaKey := LFunctionKey;
        end;
        rfParamFnc:
          TscrReportItem(AReportFunctionNode.Parent.Data).ParamFormulaKey := LFunctionKey;
        rfEventFnc:
          TscrReportItem(AReportFunctionNode.Parent.Data).EventFormulaKey := LFunctionKey;
      end;

      if LFunctionKey > 0 then
        VFunctionKey := LFunctionKey
      else
        VFunctionKey.Clear;

      if FCanSaveLoad then
        Result := PostReport(AReportFunctionNode.Parent);

      FReportChanged := False;
    end;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.pcFuncParamChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (pcFuncParam.ActivePage = tsReport) or
    (pcFuncParam.ActivePage = tsReportTemplate) then
    AllowChange := SaveChanges;
end;

procedure TdlgViewProperty3.LoadReportTemplate(const Node: TTreeNode);
begin
  Assert(IsReportTemplate(Node));

  try
    //если отчет не находится на редактирование то открываем его

    if not (gdcReport.State in dsEditModes) then
      LoadReport(Node.Parent);

    DisableControls;

    StartTrans;

    gdcTemplate.Close;
    gdcTemplate.SubSet := ssById;
    gdcTemplate.ID :=
      gdcReport.FieldByName(fnTemplateKey).AsInteger;

    gdcTemplate.Open;
    if gdcTemplate.IsEmpty then
    begin
      gdcTemplate.Insert;
      gdcTemplate.FieldByName(fnName).AsString := '';
    end else
      gdcTemplate.Edit;

  finally
    EnableControls;
  end;
end;

function TdlgViewProperty3.IsReportTemplate(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReportTemplate;
end;

function TdlgViewProperty3.PostReportTemplate(
  const ANode: TTreeNode): Boolean;
begin
  Result := False;
  Assert(IsReportTemplate(ANode), MSG_INVALID_DATA);

  try
    DisableControls;
    try
      ibqryTemplate.Close;

      //если были изменения в шабдоне то сохраняем их
      if FReportChanged then
      begin
        if gdcTemplate.FieldByName(fnId).IsNull then
          gdcTemplate.FieldByName(fnId).AsInteger :=
            GetUniqueKey(gdcTemplate.Database, gdcTemplate.Transaction);

        gdcTemplate.Post;

        gdcReport.FieldByName(fnTemplateKey).AsInteger :=
          gdcTemplate.FieldByName(fnId).AsInteger;
        FReportChanged := False;
        Result := True;
      end;


      if FCanSaveLoad then
        Result := PostReport(ANode.Parent);

    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(MSG_ERROR_SAVE_REPORT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR);
      end;
    end;
  finally
    ibqryTemplate.Open;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.actFuncCommitExecute(Sender: TObject);
begin
  if IsReport(tvClasses.Selected) then
    FCanSaveLoad := True;
  inherited;
end;

procedure TdlgViewProperty3.LoadMacros(const Node: TTreeNode);
var
  Name: String;
begin
  Assert(IsMacros(Node));

  DisableControls;
  StartTrans;
  try
    if ibqryReportServer.Active then
      ibqryReportServer.Close;

    gdcMacros.Close;
    gdcMacros.SubSet := ssById;
    gdcMacros.ID := TscrMacrosItem(Node.Data).Id;
    gdcMacros.Open;
    if gdcMacros.IsEmpty then
    begin
      gdcMacros.Insert;
      gdcMacros.FieldByName(fnName).AsString := Node.Text;
    end else
      gdcMacros.Edit;

    Node.Text := gdcMacros.FieldByName(fnName).AsString;

    Name := gdcFunction.GetUniqueName('Macros', '');
    LoadFunction(scrMacrosModuleName,
      gdcMacros.FieldByName(fnFunctionKey).AsInteger, Name,
      Format(MACROS_TEMPLATE,[Name]));

  finally
    ibqryReportServer.Open;
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.CancelReportFunction;
begin
  DisableControls;
  try
    gdcFunction.Cancel;
    FReportChanged := False;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.CancelTemplate;
begin
  DisableControls;
  try
    gdcTemplate.Cancel;
    FReportChanged := False;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.CancelReport;
begin
  DisableControls;
  try
    gdcReport.Cancel;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.CancelMacros;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcMacros.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcMacros.Cancel;
    gdcFunction.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty3.CancelMacrosGroup;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcMacrosGroup.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcMacrosGroup.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty3.CancelReportGroup;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcReportGroup.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcReportGroup.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty3.dbmDescriptionChange(Sender: TObject);
begin
  if FEnableControls then
    FChanged := True;
end;

procedure TdlgViewProperty3.LoadReportFunction(const Node: TTreeNode);
var
  RF: TscrReportFunction;
  Name: String;
begin
  try
    DisableControls;

    StartTrans;

    RF := TscrReportFunction(Node.Data);
    ibqrySetFunction.Close;
    ibqrySetFunction.Params[0].AsString := RF.ModuleName;
    ibqrySetFunction.Params[1].AsInteger := GetObjectId(Node);
    ibqrySetFunction.Open;

    dblcbSetFunction.KeyValue := RF.ID;

    case RF.FncType of
      rfMainFnc:
      begin
        Name := gdcFunction.GetUniqueName('mn_Report','');
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(MAINFUNCTION_TEMPLATE,[Name, Name]));
      end;
      rfParamFnc:
      begin
        Name := gdcFunction.GetUniqueName('pr_Report','');
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(PARAMFUNCTION_TEMPLATE,[Name, Name]));
      end;
      rfEventFnc:
      begin
        Name := gdcFunction.GetUniqueName('ev_Report','');
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(EVENTFUNCTION_TEMPLATE,[Name, Name]));
      end;
    end;

    //если отчет не находится на редактирование то открываем его
    if not (gdcReport.State in dsEditModes) then
      LoadReport(Node.Parent);

  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.actEditTemplateExecute(Sender: TObject);
var
  LfrReport: Tgs_frSingleReport;
  RTFStr: TStream;
  FStr: TFileStream;
begin
  if dblcbType.KeyValue = ReportRTF then
  begin
    RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'),
     bmReadWrite);
    try
      try
        with TgsWord97.Create(Self) do
        try
          Execute(RTFStr);
          Show;
        finally
          Free;
        end;

      except
        on E: Exception do
        begin
          if MessageBox(Handle, PChar('Произошла ошибка при попытке подключения к Word 97:'#13#10 +
           E.Message + #13#10 + 'Загрузить шаблон из файла?'), 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
            with TOpenDialog.Create(Self) do
            try
              if Execute then
              begin
                FStr := TFileStream.Create(FileName, fmOpenRead);
                try
                  RTFStr.Position := 0;
                  RTFStr.Size := 0;
                  RTFStr.CopyFrom(FStr, FStr.Size);
                finally
                  FStr.Free;
                end;
              end;
            finally
              Free;
            end;
        end;
      end;
    finally
      RTFStr.Free;
    end;
  end else
    if dblcbType.KeyValue = ReportFR then
    begin
      LfrReport := Tgs_frSingleReport.Create(Application);
      try
        if FTestReportResult <> nil then
          LfrReport.UpdateDictionary.ReportResult.Assign(FTestReportResult);
        RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'), bmReadWrite);
        try
          LfrReport.LoadFromStream(RTFStr);//BlobField(gdcTemplate.FieldByName('templatedata'));
//          DesignerRestrictions := [frdrDontSaveReport];
          LfrReport.DesignReport;
          if (LfrReport.Modified or LfrReport.ComponentModified) and (MessageBox(Handle,
           'Шаблон был изменен. Сохранить изменения?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES) then
          begin
            RTFStr.Position := 0;
            RTFStr.Size := 0;
            LfrReport.SaveToStream(RTFStr);
          end else
//            LfrReport.SaveToBlobField(gdcTemplate.FieldByName('templatedata'));
        finally
          RTFStr.Free;
        end;
      finally
        LfrReport.Free;
      end;
    end else
      if dblcbType.KeyValue = ReportXFR then
      begin
        RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'),
         bmReadWrite);
        try                                       
          with Txfr_dlgTemplateBuilder.Create(Self) do
          try
            Execute(RTFStr);
          finally
            Free;
          end;
        finally
          RTFStr.Free;
        end;
      end else
        raise Exception.Create(Format('Template type %s not supported', [dblcbType.KeyValue]));
end;

procedure TdlgViewProperty3.actEditTemplateUpdate(Sender: TObject);
begin
(Sender as TAction).Enabled := dblcbType.KeyValue <> NULL;
end;

procedure TdlgViewProperty3.dblcbTemplateChange(Sender: TObject);
begin
  ControlChange(Sender);
  FReportChanged := False;
  DisableControls;

  try
    {TscrReportItem(tvClasses.Selected.Parent.Data).TemplateKey :=
     dblcbTemplate.KeyValue;}
    gdcReport.FieldByName(fnTemplateKey).AsInteger :=
      dblcbTemplate.KeyValue;

    LoadReportTemplate(tvClasses.Selected);
  finally
   EnableControls;
  end;
end;

procedure TdlgViewProperty3.dblcbTemplateKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  ControlChange(Sender);
  FReportChanged := False;
  DisableControls;
  try
    if Key = VK_DELETE then
    begin
      {TscrReportItem(tvClasses.Selected.Parent.Data).TemplateKey := 0;}
      dblcbTemplate.KeyValue := '';
      gdcReport.FieldByName(fnTemplateKey).Clear;

      LoadReportTemplate(tvClasses.Selected);
    end;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty3.DBLookupComboBox1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    SetChanged;

    DisableControls;
    gdcMacros.FieldByName('serverkey').Clear;
    EnableControls;
  end
end;

end.
