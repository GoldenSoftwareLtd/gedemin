
 {++

   Project COMPONENTS
   Copyright © 2000 by Golden Software

   Модуль

     gsDBTreeView.pas

   Описание

     Дерево с подключением к базе данных.

   Автор

   История

     ver    date       who     what

     1.00   04.10.00   anton   Первая версия
     1.01   14.09.01   andreik Добавлено сохранение состояния дерева в поток
                               и считывание из потока. Заметьте! Используются
                               модули mxarrays & mxconsts.

 --}

unit gsDBTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, DB, DBCtrls, Contnrs, DBGrids, ActnList, Menus, gd_KeyAssoc,
  CommCtrl;

const
  Def_KeyField          =       'ID';
  Def_ParentField       =       'PARENT';
  Def_DisplayField      =       'NAME';
  Def_MainFolderCaption =       'Все';

type
  TCheckBoxTVEvent = procedure (Sender: TObject; CheckID: String;
    var Checked: Boolean) of object;
  TAfterCheckTVEvent =  procedure (Sender: TObject; CheckID: String;
    Checked: Boolean) of object;

type
  TgsCustomDBTreeView = class;

  TgsDBTreeViewDataLink = class(TDataLink)
  private
    FDBTreeView: TgsCustomDBTreeView;
    FOldAfterDelete: TDataSetNotifyEvent;
    FOldAfterPost: TDataSetNotifyEvent;
    FOldBeforeDelete: TDataSetNotifyEvent;
    FOldDataSet: TDataSet;
    FDeletingID: Integer;
    FForecast: TTreeNode;

    procedure OnBeforeDelete(Sender: TDataSet);
    procedure OnAfterDelete(Sender: TDataSet);
    procedure OnAfterPost(Sender: TDataSet);

  protected
    procedure ActiveChanged; override;
    //procedure EditingChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure LayoutChanged; override;

  public
    constructor Create(ADBTreeView: TgsCustomDBTreeView);
  end;

  //
  // данный класс предназначен для сохранения состояния дерева
  // (открытые ветви и текущий элемент)
  TIntArray = array of Integer;

  TTVState = class(TObject)
  private
    // связанное дерево
    FTreeView: TgsCustomDBTreeView;

    //
    FExpanded, FChecked: TgdKeyArray;

    // ИД выделенного элемента
    FSelectedID: Integer;

    //
    FBookmarks: TgdKeyStringAssoc;

    //
    FCheckedChanged: Boolean;
    FAfterCheckEvent: TAfterCheckTVEvent;
    FCheckBoxEvent: TCheckBoxTVEvent;

  public
    // создает объект и связывает его с деревом
    constructor Create(ATreeView: TgsCustomDBTreeView);
    destructor Destroy; override;

    // загружает информацию о состоянии дерева из потока
    // во внутренние структуры
    procedure LoadFromStream(S: TStream);
    // сохраняет информацию о состоянии дерева из
    // внутренних структур в потоке
    procedure SaveToStream(S: TStream);

    // используя сохраненные данные из внутренних структур
    // инициализирует связанное дерево
    procedure InitTree;
    // сохраняет информацию о состоянии связанного дерева
    // во внутренних структурах
    procedure SaveTreeState;

    //
    procedure NodeExpanded(const AnID: Integer);
    procedure NodeCollapsed(const AnID: Integer);
    procedure NodeChecked(const AnID: Integer);
    procedure NodeUnChecked(const AnID: Integer);

    //
    property SelectedID: Integer read FSelectedID write FSelectedID;

    //
    property Bookmarks: TgdKeyStringAssoc read FBookmarks;
    property Checked: TgdKeyArray read FChecked;

    //
    property CheckedChanged: Boolean read FCheckedChanged;

    property CheckBoxEvent: TCheckBoxTVEvent read FCheckBoxEvent write FCheckBoxEvent;
    property AfterCheckEvent: TAfterCheckTVEvent read FAfterCheckEvent write FAfterCheckEvent;
  end;

  TgsCustomDBTreeView = class(TCustomTreeView)
  private
    FActionList: TActionList; // Список команд меню для таблицы
    FImages: TImageList; // Список рисунков для списка действий
    FActFind, FActFindNext, FActOpenAll, FActCloseAll, FActOpenNode, FActRefresh: TAction;
    {$IFDEF GEDEMIN}
    FFindValue: String;
    {$ENDIF}
    FInSearch: Boolean;
    FMainFolderHead: Boolean;
    FBuilding: Boolean;
    FInRefresh: Boolean;

    FDataLink: TgsDBTreeViewDataLink;
    FKeyField: String;
    FParentField: String;
    FDisplayField: String;
    FDisplayFields: TStringList;
    FImageField: String;
    FTopKey: Integer;
    FCutNode: TTreeNode;
    FMainFolder: Boolean;
    FMainFolderCaption: String;
    FComponentList: TComponentList;
    FImageValueList: TStringList;
    FTVState: TTVState;
    FWithCheckBox: Boolean;
    FSImages: TImageList;
    FOnFilterRecord: TFilterRecordEvent;
    FOnPostProcess: TNotifyEvent;

    procedure SetDataSource(Value: TDataSource);
    function GetDataSource: TDataSource;
    procedure ActiveChanged(const ARestoreState: Boolean = True);
    procedure FullFillMenu(APopupMenu: TPopupMenu);
    procedure CreateActionList;
    procedure DoOnUpdateAction(Sender: TObject);
    procedure DoOnOpenNode(Sender: TObject);
    procedure DoOnRefresh(Sender: TObject);
    procedure DoOnRefreshUpdate(Sender: TObject);
    procedure DoOnOpenAll(Sender: TObject);
    procedure DoOnCloseAll(Sender: TObject);
    procedure DoOnActFind(Sender: TObject);
    procedure DoOnActFindNext(Sender: TObject);
    procedure SetPopupMenu(Value: TPopupMenu);
    procedure SetImageValueList(Value: TStringList);
    procedure SetMainFolderCaption(Value: String);
    procedure SetWithCheckBox(Value: Boolean);
    function GetID: Integer;
    function GetParentID: Integer;
    procedure SetTopKey(const Value: Integer);
    function GetAfterCheckEvent: TAfterCheckTVEvent;
    function GetCheckBoxEvent: TCheckBoxTVEvent;
    procedure SetAfterCheckEvent(const Value: TAfterCheckTVEvent);
    procedure SetCheckBoxEvent(const Value: TCheckBoxTVEvent);
    procedure SetDisplayField(const Value: String);
    function GetDisplayString(DS: TDataSet): String;
    {procedure InternalOnCompare(Sender: TObject;
      Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);}

  protected
    FMaxWidth: Integer;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Change(Node: TTreeNode); override;
    procedure Collapse(Node: TTreeNode); override;
    procedure Expand(Node: TTreeNode); override;
    procedure Check(Node: TTreeNode); virtual;
    procedure Loaded; override;
    procedure KeyPress(var Key: Char); override;
    procedure SetCheck(Node: TTreeNode; Check: Boolean); virtual;
    function NodeByKeyField(const KeyValue: Integer): TTreeNode;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure Edit(const Item: TTVItem); override;

    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message WM_LBUTTONDBLCLK;
    procedure WMContextMenu(var Message: TWMContextMenu);
      message WM_CONTEXTMENU;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;

    property OnClickCheck: TCheckBoxTVEvent read GetCheckBoxEvent write SetCheckBoxEvent;
    property OnClickedCheck: TAfterCheckTVEvent read GetAfterCheckEvent write SetAfterCheckEvent;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Refresh;
    function GoToID(const AnID: Integer): Boolean;
    procedure DeleteID(const AnID: Integer);
    procedure Cut;
    function Find(const AnID: Integer): TTreeNode;
    procedure DisableActions;

    // две процедуры, сохраняют и восстанавливают состояние дерева
    // из потока (открытые ветви и текущий элемент)
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);

    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property KeyField: String read FKeyField write FKeyField;
    property ParentField: String read FParentField write FParentField;
    property DisplayField: String read FDisplayField write SetDisplayField;
    property ImageField: String read FImageField write FImageField;
    // ключ верхнего уровня
    property TopKey: Integer read FTopKey write SetTopKey default -1;
    property CutNode: TTreeNode read FCutNode;
    property MainFolder: Boolean read FMainFolder write FMainFolder;
    property MainFolderHead: Boolean read FMainFolderHead write FMainFolderHead;
    property MainFolderCaption: String read FMainFolderCaption write SetMainFolderCaption;
    property PopupMenu write SetPopupMenu;
    property ImageValueList: TStringList read FImageValueList write SetImageValueList;
    property WithCheckBox: Boolean read FWithCheckBox write SetWithCheckBox;

    // Идентификатор текущего элемента, -1, если нет элемента
    // или у него нет идентификатора
    property ID: Integer read GetID;
    property ParentID: Integer read GetParentID;

    //
    property TVState: TTVState read FTVState;
    property OnFilterRecord: TFilterRecordEvent read FOnFilterRecord write FOnFilterRecord;
    property OnPostProcess: TNotifyEvent read FOnPostProcess write FOnPostProcess;

    procedure AddCheck(AnID: Integer);
    procedure DeleteCheck(AnID: Integer);

    property MaxWidth: Integer read FMaxWidth;
  end;

  TgsDBTreeView = class(TgsCustomDBTreeView)
  published
    {}
    property DataSource;
    property KeyField;
    property ParentField;
    property DisplayField;
    property ImageField;
    property ImageValueList;
    property OnFilterRecord;
    property OnPostProcess;

    {}
    property Align;
    property Anchors;
    property AutoExpand;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property ChangeDelay;
    property Color;
    property Ctl3D;
    property Constraints;
    property DragKind;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HotTrack;
    property Images;
    property Indent;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RowSelect;
    property ShowButtons;
    property ShowHint;
    property ShowLines;
    property ShowRoot;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property Items;

    property MainFolderHead;
    property MainFolder;
    property MainFolderCaption;

    property TopKey;
    property WithCheckBox;

    property OnClickCheck;
    property OnClickedCheck;
  end;

procedure Register;

const
  siChecked             = 1;
  siUnchecked           = 2;
  siGrayed              = 3;

implementation

uses
  {$IFDEF GEDEMIN}
  IBCustomDataSet, gsdbGrid_dlgFind_unit,
  {$ENDIF}
  Imglist
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R GSDBTREEVIEW.RES}

const
  MENU_FIND             = 'Найти...';
  MENU_FINDNEXT         = 'Найти следующее';
  MENU_OPENNODE         = 'Раскрыть ветвь';
  MENU_OPENALL          = 'Раскрыть дерево';
  MENU_CLOSEALL         = 'Закрыть дерево';
  MENU_Refresh          = 'Обновить';
  KeyFindNext           = VK_F3;
  KeyRefresh            = VK_F5;
  //KeyOpenAll            = VK_F8;
  //KeyCloseAll           = VK_F9;
  //KeyOpenNode           = VK_F10;

  // подпіс плыні
  StreamSign            = 12021977;

  //

type
  PInternalTreeNode = ^TInternalTreeNode;
  TInternalTreeNode = record
    ID: Integer;
    Parent: PInternalTreeNode;
    Items: TList;
    Name: String;
    Virt: Boolean;
    N: TTreeNode;
  end;

  TInternalTree = class(TObject)
  private
    Root: TInternalTreeNode;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Add(const AnID, AParent: Integer; const AName: String);
    function Find(const AnID: Integer): PInternalTreeNode;
    procedure BuildTreeView(TV: TgsCustomDBTreeView);
  end;

{TgdDataLink ---------------------------------------------}

constructor TgsDBTreeViewDataLink.Create(ADBTreeView: TgsCustomDBTreeView);
begin
  inherited Create;
  FDBTreeView := ADBTreeView;
  VisualControl := True;
  FDeletingID := -1;
  FForecast := nil;
  FOldDataSet := nil;
end;

procedure TgsDBTreeViewDataLink.ActiveChanged;
begin
  if FOldDataSet <> DataSet then
  begin
    if FOldDataSet <> nil then
    begin
      FOldDataSet.AfterDelete := FOldAfterDelete;
      FOldDataSet.AfterPost := FOldAfterPost;
      FOldDataSet.BeforeDelete := FOldBeforeDelete;
    end;

    FOldDataSet := DataSet;

    if DataSet <> nil then
    begin
      FOldAfterDelete := DataSet.AfterDelete;
      DataSet.AfterDelete := OnAfterDelete;
      FOldAfterPost := DataSet.AfterPost;
      DataSet.AfterPost := OnAfterPost;
      FOldBeforeDelete := DataSet.BeforeDelete;
      DataSet.BeforeDelete := OnBeforeDelete;
    end;
  end;

  if Assigned(FDBTreeView) then
    FDBTreeView.ActiveChanged;
end;

procedure TgsDBTreeViewDataLink.OnAfterPost(Sender: TDataSet);
var
  N: TTreeNode;
  OldBuilding: Boolean;
  {$IFDEF GEDEMIN}
  I: Integer;
  B, S: String;
  {$ENDIF}
begin
  { TODO :
почему мы отказались от сравнения с датасетом:
потому что в бизнес объекте может быть создана копия
объекта при редактировании или вставке }
  if (Sender is TDataSet) and Sender.InheritsFrom(DataSet.ClassType) then
  with (Sender as TDataSet), FDBTreeView do
  begin

    // калі паменялі назву аб'екту -- паменяем тэкст
    // у нода дрэва
    if Assigned(FDBTreeView) and
       (FDBTreeView.ID = {DataSet.}FieldByName(FDBTreeView.KeyField).AsInteger) and
       (FDBTreeView.Selected.Text <> GetDisplayString(Sender as TDataSet)) then
      FDBTreeView.Selected.Text := GetDisplayString(Sender as TDataSet);

    OldBuilding := FDBTreeView.FBuilding;
    FDBTreeView.FBuilding := True;
    try
      N := FDBTreeView.Find(FieldByName(FDBTreeView.KeyField).AsInteger);
      if N = nil then
      begin
        if (FTopKey = 0) or (FieldByName(FDBTreeView.KeyField).AsInteger <> FTopKey) then
        begin
          N := FDBTreeView.Find(FieldByName(FDBTreeView.ParentField).AsInteger);
          N := FDBTreeView.Items.AddChildObject(N, '',
            Pointer(FieldByName(FDBTreeView.KeyField).AsInteger));

          N.ImageIndex := {GetImageIndex(ImageField)}0;
          N.SelectedIndex := N.ImageIndex;
          if FDBTreeView.WithCheckBox then
           N.StateIndex := 2
          else
           N.StateIndex := 0;

          FDBTreeView.Selected := N;

          // текст изменяем отдельно чтобы вызвать
          // внутреннюю сортировку и поставить
          // элемент туда куда надо
          FDBTreeView.Selected.Text := GetDisplayString(Sender as TDataSet);

          // в нашем ИБКастомДатасете вставка записи
          // сдвигает все содержимое внутреннего кэша
          // букмарки -- это индексы записей во внутреннем
          // кэше. следовательно после вставки записи
          // букмарки надо актуализировать. а именно
          // все букмарки после вставленной записи
          // сдвинуть на единицу.
          if Sender = DataSet then
          begin
            {$IFDEF GEDEMIN}
            if DataSet is TIBCustomDataSet then
            begin
             B := DataSet.Bookmark;
             for I := 0 to FTVState.Bookmarks.Count - 1 do
             begin
               S := FTVState.Bookmarks.ValuesByIndex[I];
               if pInteger(S)^ >= pInteger(B)^ then
               begin
                 pInteger(S)^ := pInteger(S)^ + 1;
                 FTVState.Bookmarks.ValuesByIndex[I] := S;
               end;
             end;
            end;
            {$ENDIF}

            FTVState.Bookmarks.ValuesByIndex[
             FTVState.Bookmarks.Add(FieldByName(FDBTreeView.KeyField).AsInteger)] := DataSet.Bookmark;
          end else
          begin
            FTVState.Bookmarks.Clear;
          end;
        end;

      end else
      begin
        if ((N.Parent = nil) and (not FieldByName(FDBTreeView.ParentField).IsNull))
          or ((N.Parent <> nil) and (Integer(N.Parent.Data) <> FieldByName(FDBTreeView.ParentField).AsInteger)) then
        begin
          if FieldByName(FDBTreeView.ParentField).IsNull then
            N.MoveTo(nil, naAddChild)
          else begin
            N.MoveTo(FDBTreeView.Find(
              FieldByName(FDBTreeView.ParentField).AsInteger), naAddChild);
          end;
        end;
      end;
    finally
      FDBTreeView.FBuilding := OldBuilding;
    end;

    if Assigned(FOldAfterPost) then
      FOldAfterPost(DataSet);
  end;
end;

procedure TgsDBTreeViewDataLink.OnAfterDelete(Sender: TDataSet);
var
  I: Integer;
begin
  if Assigned(DataSet) and (Sender = DataSet) then
  begin
    if Assigned(FDBTreeView) then
    begin
      FDBTreeView.DeleteID(FDeletingID);
      if FForecast <> nil then
      begin
        for I := 0 to FDBTreeView.Items.Count - 1 do
        begin
          if FDBTreeView.Items[I] = FForecast then
          begin
            FDBTreeView.Selected := FForecast;
            break;
          end;
        end;
      end;
    end;

    FForecast := nil;
    FDeletingID := -1;

    if Assigned(FOldAfterDelete) then
      FOldAfterDelete(DataSet);
  end;
end;

{TgsCustomDBTreeView -------------------------------------}

constructor TgsCustomDBTreeView.Create(AOwner: TComponent);
begin
  inherited;

  FMainFolderHead := True;
  FActFind := nil;
  FActFindNext := nil;
  FActOpenAll := nil;
  FActCloseAll := nil;
  FActOpenNode := nil;
  FActRefresh := nil;

  FBuilding := False;

  FDataLink := TgsDBTreeViewDataLink.Create(Self);

  // В режиме запуска программы создаем список действий
  if not (csDesigning in ComponentState) then
  begin
    FActionList := TActionList.Create(Self);
    FImages := TImageList.Create(Self);

    CreateActionList;
  end
  else
  begin
    FActionList := nil;
    FImages := nil;
  end;

  FKeyField := Def_KeyField;
  FParentField := Def_ParentField;
  FDisplayField := Def_DisplayField;
  FDisplayFields := nil;
  FTopKey := -1;
  FMainFolder := False;
  FMainFolderCaption := Def_MainFolderCaption;

  FComponentList := TComponentList.Create;
  FImageValueList := TStringList.Create;

  FTVState := TTVState.Create(Self);
  FWithCheckBox := False;

  FSImages := TImageList.Create(nil);
  FSImages.Width := 16;
  FSImages.Height := 16;
end;

destructor TgsCustomDBTreeView.Destroy;
begin
  //FNodeList.Free;
  FDataLink.Free;
  FComponentList.Free;
  FImageValueList.Free;
  FTVState.Free;
  FSImages.Free;
  FDisplayFields.Free;

  inherited;
end;

procedure TgsCustomDBTreeView.KeyPress(var Key: Char);
begin
  if (Key = ' ') and (not IsEditing) then
    Check(Selected);
end;

procedure TgsCustomDBTreeView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    if Assigned(FActFindNext) then FActFindNext.Execute;
  end else if (Key = Word('F')) and ([ssCtrl] = Shift) then
  begin
    if Assigned(FActFind) then FActFind.Execute;
  end;

  inherited KeyDown(Key, Shift);
end;

procedure TgsCustomDBTreeView.DoOnRefresh(Sender: TObject);
begin
  Refresh;
end;

procedure TgsCustomDBTreeView.DoOnOpenNode(Sender: TObject);
begin
  if Selected <> nil then
  begin
    Items.BeginUpdate;
    try
      Selected.Expand(True);
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TgsCustomDBTreeView.DoOnOpenAll(Sender: TObject);
begin
  Items.BeginUpdate;
  try
    FullExpand;
  finally
    Items.EndUpdate;
  end;
end;

procedure TgsCustomDBTreeView.DoOnCloseAll(Sender: TObject);
begin
  Items.BeginUpdate;
  try
    FullCollapse;
  finally
    Items.EndUpdate;
  end;
end;

procedure TgsCustomDBTreeView.DoOnActFindNext(Sender: TObject);
  {$IFDEF GEDEMIN}
const
  OldTime: TDateTime = 0;
var
  Found, Loop: Boolean;
  I: Integer;
  FFindDlg: TgsdbGrid_dlgFind;
  F: Boolean;
  S, V: String;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  Found := False;
  Loop := False;
  FFindDlg := TgsdbGrid_dlgFind.Create(Self);
  try
    FFindDlg.cbFindText.Text := FFindValue;

    if FInSearch and (Now - OldTime < 1 / 24 / 60) then
    begin
      F := True;
    end else
      F := FFindDlg.ShowModal = mrOk;

    OldTime := Now;

    if F then
    begin
      FInSearch := True;

      FFindValue := FFindDlg.cbFindText.Text;

      if not FFindDlg.chbxMatchCase.Checked then
        V := AnsiUpperCase(FFindValue)
      else
        V := FFindValue;

      if FFindDlg.rbBegin.Checked then
      begin
        if Selected = nil then
        begin
          if FFindDlg.rbDown.Checked then
            I := -1
          else
            I := Items.Count;
        end else
        begin
          I := Selected.AbsoluteIndex;
        end;
      end else
      begin
        if Selected <> nil then
          I := Selected.AbsoluteIndex
        else
          I := 0;
      end;

      while True do
      begin

        if FFindDlg.rbDown.Checked then
          Inc(I)
        else
          Dec(I);

        if (I < 0) or (I >= Items.Count) then
        begin
          if Loop then
            Break
          else begin
            Loop := True;
            if I < 0 then
              I := Items.Count
            else
              I := -1;
            continue;
          end;
        end;

        S := Items[I].Text;

        if not FFindDlg.chbxMatchCase.Checked then
          S := AnsiUpperCase(S);

        if (FFindDlg.chbxWholeWord.Checked and (S = V))
          or ((not FFindDlg.chbxWholeWord.Checked) and (AnsiPos(V, S) > 0)) then
        begin
          Found := True;
          Items[I].Selected := True;
          Break;
        end;

      end;

      if not Found then
      begin
        {$IFDEF GED_LOC_RUS}
        MessageBox(Handle,
          'Значение не найдено!',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        {$ELSE}
        MessageBox(Handle,
          'Value not found!',
          'Attention',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        {$ENDIF}
        FInSearch := False;
      end;
    end;
  finally
    FFindDlg.Free;
  end;
  {$ENDIF}
end;

procedure TgsCustomDBTreeView.SetPopupMenu(Value: TPopupMenu);
begin
  inherited PopupMenu := Value;
  if not (csDesigning in ComponentState) then
  begin
    FComponentList.Clear;

    FullFillMenu(PopupMenu);
  end;
end;

procedure TgsCustomDBTreeView.SetImageValueList(Value: TStringList);
begin
  if Value <> nil then
    FImageValueList.Assign(Value);
end;

procedure TgsCustomDBTreeView.SetMainFolderCaption(Value: String);
var
  I: Integer;
begin
  FMainFolderCaption := Value;
  if FMainFolder then
    for I := 0 to Items.Count - 1 do
      if Integer(Items[I].Data) = TopKey then
        Items[I].Text := Value;
end;


procedure TgsCustomDBTreeView.SetWithCheckBox(Value: Boolean);
var
  B: TBitMap;
begin
  if FWithCheckBox <> Value then
  begin
    FWithCheckBox := Value;
    if FWithCheckBox and Assigned(FSImages) then
    begin
      StateImages := FSImages;
      FSImages.Clear;

      B := TBitmap.Create;
      try
        B.LoadFromResourceName(hInstance, 'UNCHECKED');
        FSImages.Add(B, nil);
        B.LoadFromResourceName(hInstance, 'CHECKED');
        FSImages.Add(B, nil);
        B.LoadFromResourceName(hInstance, 'UNCHECKED');
        FSImages.Add(B, nil);
        B.LoadFromResourceName(hInstance, 'GRAY');
        FSImages.Add(B, nil);
      finally
        B.Free;
      end;
    end
    else
      if StateImages = FSImages then
        StateImages := nil;
  end;
end;

procedure TgsCustomDBTreeView.CreateActionList;

  // Добавляет новое действие
  function NewAction: TAction;
  begin
    Result := TAction.Create(FActionList);
    Result.ActionList := FActionList;
    Result.OnUpdate := DoOnUpdateAction;
  end;

begin
  Assert(Assigned(FImages));

  FImages.Width := 16;
  FImages.Height := 16;

  FImages.GetResource(rtBitmap, 'ALL', 16, [lrDefaultColor], clOlive);
  FActionList.Images := FImages;

  // Пункт Мастер установок
  FActFind := NewAction;
  FActFind.OnExecute := DoOnActFind;
  FActFind.ShortCut := TextToShortcut('Ctrl+F');
  FActFind.Caption := MENU_FIND;
  FActFind.ImageIndex := 23;
  FActFind.Hint := MENU_FIND;

  // Пункт Мастер установок
  FActFindNext := NewAction;
  FActFindNext.OnExecute := DoOnActFindNext;
  FActFindNext.ShortCut := KeyFindNext;
  FActFindNext.Caption := MENU_FINDNEXT;
  FActFindNext.ImageIndex := 24;
  FActFindNext.Hint := MENU_FINDNEXT;

  // Пункт Обновить данные
  FActOpenAll := NewAction;
  FActOpenAll.OnExecute := DoOnOpenAll;
  //FActOpenAll.ShortCut := KeyOpenAll;
  FActOpenAll.Caption := MENU_OPENALL;
  FActOpenAll.ImageIndex := -1{0};
  FActOpenAll.Hint := MENU_OPENALL;

  // Пункт Найти
  FActCloseAll := NewAction;
  FActCloseAll.OnExecute := DoOnCloseAll;
  //FActCloseAll.ShortCut := KeyCloseAll;
  FActCloseAll.Caption := MENU_CLOSEALL;
  FActCloseAll.ImageIndex := -1{1};
  FActCloseAll.Hint := MENU_CLOSEALL;

  // Пункт Панель инструментов
  FActOpenNode := NewAction;
  FActOpenNode.OnExecute := DoOnOpenNode;
  //FActOpenNode.ShortCut := KeyOpenNode;
  FActOpenNode.Caption := MENU_OPENNODE;
  FActOpenNode.ImageIndex := -1{3};
  FActOpenNode.Hint := MENU_OPENNODE;

  // Пункт Панель инструментов
  FActRefresh := NewAction;
  FActRefresh.OnExecute := DoOnRefresh;
  FActRefresh.OnUpdate := DoOnRefreshUpdate;
  FActRefresh.ShortCut := KeyRefresh;
  FActRefresh.Caption := MENU_Refresh;
  FActRefresh.ImageIndex := 17;
  FActRefresh.Hint := MENU_Refresh;
end;

procedure TgsCustomDBTreeView.FullFillMenu(APopupMenu: TPopupMenu);
var
  MenuItem: TMenuItem;

  // Добавляем элемент в меню
  function AddItem(Group: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Group.Add(Result);
  end;

begin
  {$IFNDEF GED_LOC_RUS}
  exit;
  {$ENDIF}

  if Assigned(APopupMenu) then
  begin
    MenuItem := AddItem(APopupMenu.Items, '-');
    FComponentList.Add(MenuItem);

    // Поиск
    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActFind;
    FComponentList.Add(MenuItem);

    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActFindNext;
    FComponentList.Add(MenuItem);

    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActOpenAll;
    FComponentList.Add(MenuItem);

    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActCloseAll;
    FComponentList.Add(MenuItem);

    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActOpenNode;
    FComponentList.Add(MenuItem);

    MenuItem := AddItem(APopupMenu.Items, '');
    MenuItem.Action := FActRefresh;
    FComponentList.Add(MenuItem);
  end;
end;

function TgsCustomDBTreeView.GoToID(const AnID: Integer): Boolean;
var
  I: Integer;
begin
  if ID = AnID then
    Result := True
  else begin
    Result := False;
    for I := 0 to Items.Count - 1 do
      if Integer(Items[I].Data) = AnID then
      begin
        Items[I].Selected := True;
        Result := True;
        exit;
      end;
  end;
end;

function TgsCustomDBTreeView.GetDataSource: TDataSource;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.DataSource
  else
    Result := nil;
end;

procedure TgsCustomDBTreeView.SetDataSource(Value: TDataSource);
begin
  if Assigned(FDataLink) then
  begin
    FDataLink.DataSource := Value;
    if (not (csLoading in ComponentState)) {and (not (csDesiging in ComponentState))} then
    begin
      ActiveChanged;
    end;
  end;
end;

procedure TgsCustomDBTreeView.ActiveChanged(const ARestoreState: Boolean = True);
var
  OldBookmark: String;
  Accept: Boolean;
  IT: TInternalTree;
  ParentID: Integer;
begin
  FBuilding := True;
  try
    FMaxWidth := 0;
    FTVState.Bookmarks.Clear;

    if Enabled
      and (FDataLink.DataSet <> nil)
      and (FDataLink.DataSet.Active)
      and (not (csDesigning in ComponentState))
      and (not (csLoading in ComponentState))
      and (not (csDestroying in ComponentState)) then
    begin
      IT := TInternalTree.Create;
      Items.BeginUpdate;
      FDataLink.DataSet.DisableControls;
      try
        Items.Clear;

        OldBookmark := '';
        if not FDataLink.DataSet.IsEmpty then
          with FDataLink.DataSet do
          begin
            OldBookmark := Bookmark;
            First;
            while not Eof do
            begin
              if Assigned(FOnFilterRecord) then
              begin
                Accept := True;
                FOnFilterRecord(FDataLink.DataSet, Accept);
                if not Accept then
                begin
                  Next;
                  continue;
                end;
              end;

              ParentID := FieldByName(FParentField).AsInteger;
              if ParentID = FTopKey then
                ParentID := 0;

              IT.Add(FieldByName(FKeyField).AsInteger,
                ParentID,
                GetDisplayString(FDataLink.DataSet));

              with FTVState.Bookmarks do
                ValuesByIndex[Add(FieldByName(FKeyField).AsInteger)] := Bookmark;

              Next;
            end;
        end;

        IT.BuildTreeView(Self);

        if SortType = stText then
        begin
          {if Assigned(OnCompare) then
            AlphaSort
          else
          begin
            OnCompare := InternalOnCompare;}
            AlphaSort;
            {OnCompare := nil;
          end;}
        end;

        if ARestoreState then
        begin
          FTVState.InitTree;

          if (Selected = nil) and (Items.Count > 0) and (Items[0] <> nil) then
          begin
            Items[0].Selected := True;
            Items[0].MakeVisible;
          end;

          SetScrollPos(Self.Handle, SB_HORZ, 0, True);

          if Selected <> nil then
            FDataLink.DataSet.Bookmark := FTVState.Bookmarks.ValuesByKey[Integer(Selected.Data)]
          else if OldBookmark > '' then
            FDataLink.DataSet.Bookmark := OldBookmark;
        end else if OldBookmark > '' then
        begin
          FDataLink.DataSet.Bookmark := OldBookmark;
          FTVState.SelectedID := FDataLink.DataSet.FieldByName(FKeyField).AsInteger;
          Selected := PInternalTreeNode(IT.Find(FTVState.SelectedID))^.N;
        end;

        if Assigned(FOnPostProcess) then
          FOnPostProcess(Self);
      finally
        Items.EndUpdate;
        FDataLink.DataSet.EnableControls;
        FTVState.SaveTreeState;
        IT.Free;
      end;
    end else
    if Enabled
      and (FDataLink.DataSet <> nil)
      and (not FDataLink.DataSet.Active)
      and (not (csDesigning in ComponentState))
      and (not (csLoading in ComponentState))
      and (not (csDestroying in ComponentState)) then
    begin
      if not FInRefresh then
        Items.Clear;
    end;
  finally
    FBuilding := False;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsDBTreeView]);
end;

procedure TgsCustomDBTreeView.Refresh;
var
  OldID: Integer;
begin
  if (FDataLink.DataSet <> nil) and (FDataLink.DataSet.Active) then
  begin
    FInRefresh := True;
    try
      OldID := ID;
      FDataLink.DataSet.DisableControls;
      try
        FDataLink.DataSet.Close;
        FDataLink.DataSet.Open;
      finally
        FDataLink.DataSet.EnableControls;
      end;
      GotoID(OldID);
    finally
      FInRefresh := False;
    end;
  end;
end;

procedure TgsCustomDBTreeView.Cut;
begin
  if Assigned(Selected) then
  begin
    FCutNode := Selected;
    Selected.Cut;
  end;
end;

procedure TgsCustomDBTreeView.Change(Node: TTreeNode);
begin
  // синхронизируем положение текущей записи в ДатаСете с
  // выбранным элементом в дереве
  if FBuilding then
    exit;

  if (FDataLink.DataSet <> nil) and FDataLink.DataSet.Active
    and (not (FDataLink.DataSet.State in dsEditModes))
    and (not FDataLink.DataSet.ControlsDisabled) then
  begin
    if (Node <> nil) and (Node.Data <> nil)
      and (not (csDesigning in ComponentState)) then
    begin
      if Integer(Node.Data) > -1 then
      begin
        if FTVState.Bookmarks.IndexOf(Integer(Node.Data)) <> -1 then
        begin
          if FDataLink.DataSet.Bookmark <> FTVState.Bookmarks.ValuesByKey[Integer(Node.Data)] then
            FDataLink.DataSet.Bookmark := FTVState.Bookmarks.ValuesByKey[Integer(Node.Data)];
        end else
        begin
          if FDataLink.DataSet.Locate(FKeyField, Integer(Node.Data), []) then
          begin
            FTVState.Bookmarks.ValuesByIndex[
              FTVState.Bookmarks.Add(Integer(Node.Data))] := FDataLink.DataSet.Bookmark;
          end;
        end;

        FTVState.SelectedID := Integer(Node.Data);

        if (Node.Text <> GetDisplayString(FDataLink.DataSet))
          and (not ((Node.Text = '<Пусто>') and (GetDisplayString(FDataLink.DataSet) = ''))) then
        begin
          if (not FDataLink.ReadOnly) and FDataLink.DataSet.CanModify then
          begin
            if (Node.Text > '') and (FDisplayFields = nil)  then
            begin
              FDataLink.DataSet.DisableControls;
              try
                FDataLink.DataSet.Edit;
                FDataLink.DataSet.FieldByName(DisplayField).AsString := Node.Text;
                FDataLink.DataSet.Post;
              finally
                FDataLink.DataSet.EnableControls;
              end;
            end else
              Node.Text := GetDisplayString(FDataLink.DataSet);
          end;
        end;
      end else
      begin
        FDataLink.DataSet.First;
        FDataLink.DataSet.Prior;
      end;
    end;
  end;

  inherited;
end;

procedure TgsCustomDBTreeView.LoadFromStream(S: TStream);
begin
  FTVState.LoadFromStream(S);
  if FDataLink.Active then
    FTVState.InitTree;
end;

(*

  У плыні мы захоўваем ідэнтыфікатары адчыненых
  галінак, а такчама ідэнтыфікатар вылучанага элементу.

  Фармат плыні:

  1. подпіс (4 байты)
  2. ІД вылучанага элементу (4 байты)
  3. колькасць запісаў (4 байты)
  4. 1..n ідэнтыфікатараў па 4 байты

*)

procedure TgsCustomDBTreeView.SaveToStream(S: TStream);
begin
  FTVState.SaveToStream(S);
end;

procedure TgsCustomDBTreeView.Collapse(Node: TTreeNode);
begin
  inherited;
  if (Node.Data <> nil) then
    FTVState.NodeCollapsed(Integer(Node.Data));
end;

procedure TgsCustomDBTreeView.Expand(Node: TTreeNode);
begin
  inherited;
  if (Node.Data <> nil) then
    FTVState.NodeExpanded(Integer(Node.Data));
end;

procedure TgsCustomDBTreeView.SetCheck(Node: TTreeNode; Check: Boolean);

  procedure SetChecked(N: TTreeNode);
  begin
    N.StateIndex := 1;
    FTVState.NodeChecked(Integer(N.Data));

    N := N.Parent;
    while (N <> nil) and (N.StateIndex <> 1) do
    begin
      N.StateIndex := 3;
      N := N.Parent;
    end;
  end;

  procedure SetUnchecked(N: TTreeNode);

    procedure DoRecurs(_N: TTreeNode);
    var
      I: Integer;
    begin
      for I := 0 to _N.Count - 1 do
      begin
        _N.Item[I].StateIndex := siUnchecked;
        FTVState.NodeUnChecked(Integer(_N.Item[I].Data));
        DoRecurs(_N.Item[I]);
      end;
    end;

  var
    B: Boolean;
    NN: TTreeNode;
  begin
    if N.StateIndex = siChecked then
    begin
      DoRecurs(N);
      B := True;//N.Count > 0;
    end else
      B := False;
    NN := N.GetNextSibling;
    while B and (NN <> nil) do
    begin
      B := NN.StateIndex <> siChecked;
      NN := NN.GetNextSibling;
    end;
    NN := N.GetPrevSibling;
    while B and (NN <> nil) do
    begin
      B := NN.StateIndex <> siChecked;
      NN := NN.GetPrevSibling;
    end;
    N.StateIndex := siUnchecked;
    FTVState.NodeUnChecked(Integer(N.Data));
    N := N.Parent;
    while (N <> nil) and (N.StateIndex <> siUnchecked) do
    begin
      if B then
      begin
        N.StateIndex := siUnchecked;
        FTVState.NodeUnChecked(Integer(N.Data));
      end else
        N.StateIndex := siGrayed;
      N := N.Parent;
    end;
  end;

begin
  if (Node.Data <> nil) then
  begin
    if Check then
      SetChecked(Node)
    else
      SetUnChecked(Node);
  end;
end;

procedure TgsCustomDBTreeView.Check(Node: TTreeNode);
var
  N: TTreeNode;
begin
  if (Node <> nil) and (Node.Data <> nil) then
  begin
    if ((GetAsyncKeyState(VK_SHIFT) shr 1) <> 0)
      and (Selected <> nil) {and (Node <> Selected)}
      and (Node.Parent = Selected.Parent) then
    begin
      SetCheck(Node, True);
      if Node.Parent <> nil then
      begin
        if Node.Parent.IndexOf(Node) > Node.Parent.IndexOf(Selected) then
        begin
          N := Node;
          repeat
            N := N.GetPrevSibling;
            SetCheck(N, True);
          until N = Selected;
          N := Node.GetNextSibling;
          while N <> nil do
          begin
            SetCheck(N, False);
            N := N.GetNextSibling;
          end;
          N := Selected.GetPrevSibling;
          while N <> nil do
          begin
            SetCheck(N, False);
            N := N.GetPrevSibling;
          end;
        end
        else if Node.Parent.IndexOf(Node) < Node.Parent.IndexOf(Selected) then
        begin
          N := Node;
          repeat
            N := N.GetNextSibling;
            SetCheck(N, True);
          until N = Selected;
          N := Node.GetPrevSibling;
          while N <> nil do
          begin
            SetCheck(N, False);
            N := N.GetPrevSibling;
          end;
          N := Selected.GetNextSibling;
          while N <> nil do
          begin
            SetCheck(N, False);
            N := N.GetNextSibling;
          end;
        end;
      end;  
    end else
      SetCheck(Node, Node.StateIndex <> siChecked);
  end;
end;

procedure TgsCustomDBTreeView.Loaded;
begin
  inherited;

  // убираем элементы, которые пользователь
  // мог ввести в дизайн режиме
  if (not FDataLink.Active) and (Items.Count > 0) then
  begin
    Items.BeginUpdate;
    try
      Items.Clear;
    finally
      Items.EndUpdate;
    end;
  end;
end;

{ TTVState }

procedure TTVState.NodeUnChecked(const AnID: Integer);
var
  Checked: Boolean;
begin
  if FChecked.IndexOf(AnID) <> -1 then
  begin
    Checked := False;
    if Assigned(FCheckBoxEvent) then
      FCheckBoxEvent(FTreeView, IntToStr(AnID), Checked);

    if not Checked then
    begin
      FChecked.Remove(AnID);
      FCheckedChanged := True;
    end;

    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(FTreeView, IntToStr(AnID), Checked);
  end;
end;

procedure TTVState.NodeCollapsed(const AnID: Integer);
begin
  FExpanded.Remove(AnID);
end;

constructor TTVState.Create(ATreeView: TgsCustomDBTreeView);
begin
  FTreeView := ATreeView;
  FSelectedID := -1;
  FExpanded := TgdKeyArray.Create;
  FChecked := TgdKeyArray.Create;
  FBookmarks := TgdKeyStringAssoc.Create;
  FCheckedChanged := False;
end;

destructor TTVState.Destroy;
begin
  FBookmarks.Free;
  FExpanded.Free;
  FChecked.Free;
  inherited;
end;

procedure TTVState.NodeChecked(const AnID: Integer);
var
  Checked: Boolean;
begin
  if FChecked.IndexOf(AnID) = -1 then
  begin
    Checked := True;
    if Assigned(FCheckBoxEvent) then
      FCheckBoxEvent(FTreeView, IntToStr(AnID), Checked);

    if Checked then
    begin
      FChecked.Add(AnID);
      FCheckedChanged := True;
    end;

    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(FTreeView, IntToStr(AnID), Checked);
  end;
end;

procedure TTVState.NodeExpanded(const AnID: Integer);
begin
  if FExpanded.IndexOf(AnID) = -1 then
    FExpanded.Add(AnID);
end;

procedure TTVState.InitTree;
var
  I: Integer;
  N: TTreeNode;
begin
  N := nil;
  with FTreeView do
  begin
    Items.BeginUpdate;
    try
      for I := 0 to Items.Count - 1 do
        if (Items[I].Data <> nil) then
        begin
          Items[I].Expanded := FExpanded.IndexOf(Integer(Items[I].Data)) <> -1;

          if FSelectedID = Integer(Items[I].Data) then
            N := Items[I];

          if FChecked.IndexOf(Integer(Items[I].Data)) <> -1 then
            Items[I].StateIndex := siChecked
          else
            Items[I].StateIndex := siUnchecked;
        end;

      if N <> nil then
        N.Selected := True;

      if Selected <> nil then
        Selected.MakeVisible;
    finally
      Items.EndUpdate;
    end;
  end;

  FCheckedChanged := False;
end;

procedure TTVState.LoadFromStream(S: TStream);
var
  Sign: Integer;
begin
  FSelectedID := -1;
  try
    S.ReadBuffer(Sign, SizeOf(Sign));
    if Sign <> StreamSign then exit;
    S.ReadBuffer(FSelectedID, SizeOf(FSelectedID));
    FExpanded.LoadFromStream(S);
    FChecked.LoadFromStream(S);
  except
    // нават калі нам перадалі некарэктную плынь
    // мы ня будзем кідаць памылак, а моўчкі нічога не зробім
  end;
end;

procedure TTVState.SaveToStream(S: TStream);
var
  Sign: Integer;
begin
  Sign := StreamSign;
  S.Write(Sign, SizeOf(Sign));
  S.Write(FSelectedID, SizeOf(FSelectedID));
  FExpanded.SaveToStream(S);
  FChecked.SaveToStream(S);
end;

procedure TTVState.SaveTreeState;
var
  I: Integer;
begin
  with FTreeView do
  begin
    FSelectedID := ID;
    FExpanded.Clear;
    FChecked.Clear;
    for I := 0 to Items.Count - 1 do
      if (Items[I].Data <> nil) then
      begin
        if Items[I].Expanded then
          FExpanded.Add(Integer(Items[I].Data));

        if Items[I].StateIndex = 1 then
          FChecked.Add(Integer(Items[I].Data));
      end;
  end;
end;

function TgsCustomDBTreeView.NodeByKeyField(
  const KeyValue: Integer): TTreeNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Items.Count - 1 do
    if Integer(Items[I].Data) = KeyValue then
    begin
      Result := Items[I];
      Break;
    end;
end;

function TgsCustomDBTreeView.GetID: Integer;
begin
  if Selected <> nil then
    Result := Integer(Selected.Data)
  else
    Result := -1;
end;

function TgsCustomDBTreeView.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  PostMessage(Handle, WM_KEYDOWN, VK_DOWN, 0);
  Result := True;
end;

function TgsCustomDBTreeView.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  PostMessage(Handle, WM_KEYDOWN, VK_UP, 0);
  Result := True;
end;

function TgsCustomDBTreeView.GetParentID: Integer;
begin
  if (Selected <> nil) and (Selected.Parent <> nil) then
    Result := Integer(Selected.Parent.Data)
  else
    Result := -1;
end;

procedure TgsCustomDBTreeView.SetTopKey(const Value: Integer);
begin
  Assert((FTopKey = -1) or (FTopKey > 0), 'Invalid top key');
  FTopKey := Value;
end;

procedure TgsDBTreeViewDataLink.RecordChanged(Field: TField);
begin
  if (Field = nil) and (FDBTreeView <> nil) and FDBTreeView.Enabled then
  begin
    if (DataSet <> nil) and (not (DataSet.State in dsEditModes)) then
    begin
      if FForecast = nil then
        FDBTreeView.GoToID(DataSet.FieldByName(FDBTreeView.KeyField).AsInteger);
    end;    
  end;
end;

procedure TgsDBTreeViewDataLink.OnBeforeDelete(Sender: TDataSet);
begin
  if Assigned(DataSet) and (DataSet = Sender) then
  begin
    FDeletingID := DataSet.FieldByName(FDBTreeView.KeyField).AsInteger;

    if FDBTreeView <> nil then
      with FDBTreeView do
        if Selected <> nil then
        begin
          FForecast := Selected.GetPrevSibling;
          if (FForecast = nil) or (FForecast = Selected) then
            FForecast := Selected.GetNextSibling;
          if (FForecast = nil) or (FForecast = Selected) then
            FForecast := Selected.Parent;
        end else
          FForecast := nil;

    if Assigned(FOldBeforeDelete) then
      FOldBeforeDelete(Sender);
  end;
end;

procedure TgsCustomDBTreeView.DeleteID(const AnID: Integer);
var
  I: Integer;
begin
  if ID <> AnID then
  begin
    for I := 0 to Items.Count - 1 do
      if Integer(Items[I].Data) = AnID then
      begin
        Items.Delete(Items[I]);
        exit;
      end;
  end else
    Items.Delete(Selected);
  FTVState.Bookmarks.Remove(AnID);
end;

function TgsCustomDBTreeView.Find(const AnID: Integer): TTreeNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Items.Count - 1 do
    if AnID = Integer(Items[I].Data) then
    begin
      Result := Items[I];
      exit;
    end;
end;

function TgsCustomDBTreeView.GetAfterCheckEvent: TAfterCheckTVEvent;
begin
  Result := FTVState.AfterCheckEvent;
end;

function TgsCustomDBTreeView.GetCheckBoxEvent: TCheckBoxTVEvent;
begin
  Result := FTVState.CheckBoxEvent;
end;

procedure TgsCustomDBTreeView.SetAfterCheckEvent(
  const Value: TAfterCheckTVEvent);
begin
  FTVState.AfterCheckEvent := Value;
end;

procedure TgsCustomDBTreeView.SetCheckBoxEvent(
  const Value: TCheckBoxTVEvent);
begin
  FTVState.CheckBoxEvent := Value;
end;

procedure TgsCustomDBTreeView.AddCheck(AnID: Integer);
var
  tn: TTreeNode;
begin
  tn := Find(AnID);
  if tn <> nil then
    SetCheck(Find(AnID), True);
end;

procedure TgsCustomDBTreeView.DeleteCheck(AnID: Integer);
var
  tn: TTreeNode;
begin
  tn := Find(AnID);
  if tn <> nil then
    SetCheck(Find(AnID), False);
end;

procedure TgsCustomDBTreeView.Edit(const Item: TTVItem);
begin
  inherited;

  if Assigned(Selected) and (FDisplayFields = nil)
    and (FDataLink.DataSet <> nil)
    and (not FDataLink.ReadOnly)
    and (FDataLink.DataSet.CanModify)
    and (Selected.Text <> FDataLink.DataSet.FieldByName(DisplayField).AsString) then
  begin
    FDataLink.DataSet.DisableControls;
    try
      FDataLink.DataSet.Edit;
      FDataLink.DataSet.FieldByName(DisplayField).AsString := Selected.Text;
      FDataLink.DataSet.Post;
    finally
      FDataLink.DataSet.EnableControls;
    end;
  end;
end;

procedure TgsDBTreeViewDataLink.LayoutChanged;
begin
//  inherited;

  { TODO : LayoutChanged вызывается по EnableControls
  мы будем по нему перестраивать дерево }
  if Assigned(FDBTreeView) then
    FDBTreeView.ActiveChanged;
end;

procedure TgsCustomDBTreeView.SetDisplayField(const Value: String);
begin
  FDisplayField := Value;

  if Pos(',', FDisplayField) <> 0 then
  begin
    if FDisplayFields = nil then
      FDisplayFields := TStringList.Create;
    FDisplayFields.CommaText := FDisplayField;
  end else
    FreeAndNil(FDisplayFields);
end;

procedure TgsCustomDBTreeView.WMLButtonDblClk(
  var Message: TWMLButtonDblClk);
var
  N: TTreeNode;
begin
  N := GetNodeAt(Message.XPos, Message.YPos);
  if Assigned(N) then
  begin
    if Assigned(OnDblClick) and N.HasChildren then
    begin
      OnDblClick(Self);
      Message.Result := 0;
    end else
      inherited;
  end else
    inherited;
end;

procedure TgsCustomDBTreeView.WMContextMenu(var Message: TWMContextMenu);
begin

  // чтобы по нажатию на правую кнопку курсор
  // перемещался на позицию над которой мышка
  // стоит...
  if RightClickSelect then
    Selected := Selected;

  inherited;
end;

procedure TgsCustomDBTreeView.DoOnActFind(Sender: TObject);
begin
  FInSearch := False;
  DoOnActFindNext(Sender);
end;

function TgsCustomDBTreeView.GetDisplayString(DS: TDataSet): String;
var
  I: Integer;
begin
  Assert(Assigned(DS));
  if FDisplayFields = nil then
    Result := DS.FieldByName(FDisplayField).AsString
  else begin
    Result := '';
    for I := 0 to FDisplayFields.Count - 1 do
    begin
      Result := Result + DS.FieldByName(FDisplayFields[I]).AsString;
      if I <> FDisplayFields.Count - 1 then
        Result := Result + ' ';
    end;
  end;
end;

{ TInternalTree }

procedure TInternalTree.Add(const AnID, AParent: Integer;
  const AName: String);
var
  P: PInternalTreeNode;

  procedure SetParent;
  begin
    P^.Parent := Find(AParent);
    if P^.Parent = nil then
    begin
      New(P^.Parent);
      P^.Parent^.ID := AParent;
      P^.Parent^.Name := '<' + IntToStr(AParent) + '>';
      P^.Parent^.Items := TList.Create;
      P^.Parent^.Virt := True;
      P^.Parent^.Parent := @Root;
      Root.Items.Add(P^.Parent);
    end;
    P^.Parent^.Items.Add(P);
  end;

begin
  P := Find(AnID);

  if P = nil then
  begin
    New(P);
    P^.ID := AnID;
    P^.Name := AName;
    P^.Items := TList.Create;
    P^.Virt := False;
    SetParent;
  end else
  begin
    P^.Name := AName;
    P^.Virt := False;
    if (P^.Parent <> nil) and (P^.Parent^.ID <> AParent) then
    begin
      P^.Parent^.Items.Remove(P);
      SetParent;
    end;
  end;
end;

procedure TInternalTree.BuildTreeView(TV: TgsCustomDBTreeView);

var
  DC: HDC;
  OldF: THandle;
  Level: Integer;

  procedure _Scan(P: PInternalTreeNode);
  var
    I: Integer;
    T, Q: PInternalTreeNode;
    Pt: TSize;
    TempS: String;
  begin
    Inc(Level);
    try
      for I := 0 to P^.Items.Count - 1 do
      begin
        T := PInternalTreeNode(P^.Items[I]);
        if not T^.Virt then
        begin
          if P^.N = nil then
            T^.N := TV.Items.AddObject(nil, T^.Name, Pointer(T^.ID))
          else
          begin
            Q := P;
            while (Q <> nil) and Q^.Virt do
            begin
              Q := Q^.Parent;
            end;
            if (Q = nil) or (Q^.N = nil) then
              T^.N := TV.Items.AddObject(nil, T^.Name, Pointer(T^.ID))
            else
              T^.N := TV.Items.AddChildObject(Q^.N, T^.Name, Pointer(T^.ID));
          end;
          if T^.N.Text = '' then
            T^.N.Text := '<Пусто>';
          if TV.WithCheckBox then
            T^.N.StateIndex := 2
          else
            T^.N.StateIndex := 0;

          TempS := T^.N.Text;
          GetTextExtentPoint(DC, @TempS[1], Length(TempS), Pt);
          if Pt.cx + TV.Indent * Level > TV.FMaxWidth then
          begin
            TV.FMaxWidth := Pt.cx + TV.Indent * Level;
          end;
        end;
        _Scan(T);
      end;
    finally
      Dec(Level);
    end;
  end;

var
  J: Integer;
  P: PInternalTreeNode;
begin
  if (Root.Items.Count = 1) and PInternalTreeNode(Root.Items[0])^.Virt then
  begin
    P := PInternalTreeNode(Root.Items[0]);
    Root.Items.Remove(P);
    for J := 0 to P^.Items.Count - 1 do
    begin
      PInternalTreeNode(P^.Items[J]).Parent := @Root;
      Root.Items.Add(P^.Items[J]);
    end;
    P^.Items.Free;
    Dispose(P);
  end;

  if TV.Items.Count > 0 then
    Root.N := TV.Items[0]
  else
    Root.N := nil;

  Level := 0;
  DC := GetDC(0);
  OldF := SelectObject(DC, TV.Font.Handle);
  try
    _Scan(@Root);
  finally
    SelectObject(DC, OldF);
    ReleaseDC(0, DC);
  end;

  {if TV.Items.Count = 0 then
    _Scan2(@Root); }
end;

procedure TInternalTree.Clear;

  procedure _Scan(P: PInternalTreeNode);
  var
    I: Integer;
    T: PInternalTreeNode;
  begin
    for I := 0 to P^.Items.Count - 1 do
    begin
      T := PInternalTreeNode(P^.Items[I]);
      _Scan(T);
      T^.Items.Free;
      Dispose(T);
    end;
    P^.Items.Clear;
  end;

begin
  _Scan(@Root);
end;

constructor TInternalTree.Create;
begin
  Root.ID := 0;
  Root.Parent := nil;
  Root.Items := TList.Create;
  Root.Name := '';
  Root.Virt := True;
end;

destructor TInternalTree.Destroy;
begin
  Clear;
  Root.Items.Free;
  inherited;
end;

function TInternalTree.Find(const AnID: Integer): PInternalTreeNode;

  function _Scan(P: PInternalTreeNode): PInternalTreeNode;
  var
    I: Integer;
  begin
    if P^.ID = AnID then
      Result := P
    else
    begin
      Result := nil;
      for I := 0 to P^.Items.Count - 1 do
      begin
        Result := _Scan(PInternalTreeNode(P^.Items[I]));
        if Result <> nil then
          break;
      end;
    end;
  end;

begin
  Result := _Scan(@Root);
end;

procedure TgsCustomDBTreeView.DoOnUpdateAction(Sender: TObject);
begin
  (Sender as TAction).Enabled := Items.Count > 0;
end;

{
procedure TgsCustomDBTreeView.InternalOnCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  if Node1.HasChildren xor Node2.HasChildren then
  begin
    if Node1.HasChildren then
      Compare := -1
    else
      Compare := 1;
  end else
    Compare := AnsiCompareText(Node1.Text, Node2.Text)
end;
}

procedure TgsCustomDBTreeView.DoOnRefreshUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Self.Focused;
end;

procedure TgsCustomDBTreeView.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if (htOnStateIcon in GetHitTestInfoAt(Message.XPos, Message.YPos))
    or ((GetAsyncKeyState(VK_SHIFT) shr 1) <> 0) then
  begin
    Items.BeginUpdate;
    try
      Check(GetNodeAt(Message.XPos, Message.YPos));
    finally
      Items.EndUpdate;
    end;
  end;
  inherited;
end;

procedure TgsCustomDBTreeView.DisableActions;
begin
  FreeAndNil(FActFind);
  FreeAndNil(FActFindNext);
  FreeAndNil(FActRefresh);
end;

end.

