
{++

  Copyright (c) 2001-2013 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project. TBaseFrame_unit.
    Базовый фрайм.

  Author

    Karpuk Alexander

  Revisions history

    1.00    17.10.02    tiptop        Initial version.
--}

unit prp_BaseFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, DBCtrls, Mask, Db, gdcBase, Menus, prp_TreeItems,
  ActnList, prp_dfPropertyTree_Unit, gd_createable_form, prp_dlgEvaluate_unit,
  SuperPageControl, prpDBComboBox, extctrls, StdActns, TB2Item, TB2Dock,
  TB2Toolbar, IBSQL, TB2MDI, TB2Common;

type
 //Тип события вызываемого при изменении положения курсора
  TCaretPosChange = procedure (Sender: TObject; const X, Y: Integer) of object;
  TChangeTreeItem = procedure (Sender: TObject; const ObjectID: Integer) of object;
  TDestroyFrame = procedure (Sender: TObject; ShowNext: Boolean) of  object;

  TBaseFrame = class;
  CBaseFrame = class of TBaseFrame;

  TBaseFrame = class(TFrame)
    PageControl: TSuperPageControl;
    DataSource: TDataSource;
    tsProperty: TSuperTabSheet;
    PopupMenu: TPopupMenu;
    miClose: TMenuItem;
    ActionList1: TActionList;
    actClosePage: TAction;
    miS1: TMenuItem;
    actAddToSetting: TAction;
    miAddToSetting: TMenuItem;
    actCopyIdToClipBoard: TAction;
    actEditCopy: TEditCopy;
    actEditCut: TEditCut;
    actEditDelete: TEditDelete;
    actEditPaste: TEditPaste;
    actEditSelectAll: TEditSelectAll;
    actEditUndo: TEditUndo;
    TBDock1: TTBDock;
    pMain: TPanel;
    lbName: TLabel;
    lbDescription: TLabel;
    dbeName: TprpDBComboBox;
    dbmDescription: TDBMemo;
    actProperty: TAction;
    procedure dbeFunctionNameChange(Sender: TObject);
    procedure actClosePageExecute(Sender: TObject);
    procedure dbeNameChange(Sender: TObject);
    procedure dbeNameDropDown(Sender: TObject);
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actAddToSettingUpdate(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
  private
    FSpeedButton: TTBCustomItem;
    FOnChangeTreeItem: TChangeTreeItem;
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetOnCreate(const Value: TNotifyEvent);
    procedure SetOnDestroy(const Value: TDestroyFrame);

    procedure SetShowDeleteQuestion(const Value: Boolean);
    procedure SetSpeedButton(const Value: TTBCustomItem);
    procedure SetOnChangeTreeItem(const Value: TChangeTreeItem);
    function GetName: string;

    { Private declarations }
  protected
    FNode: TTreeNode;
    //Указывает на необходимость сохранения даже если пользователь ничего не изменял
    FNeedSave: Boolean;
    FEvaluate: TdlgEvaluate;
    FRunning: Boolean;
    FShowDeleteQuestion: Boolean;
    FOnChange: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDestroy: TDestroyFrame;
    FModify: Boolean;
    FCustomTreeItem: TCustomTreeItem;
    FPropertyTreeForm: TdfPropertyTree;
    FMessageListView: TListView;
    FOnCaretPosChange: TCaretPosChange;
    FShowCancelQu: Boolean;
    FShowNext: Boolean;
    FNeedDeleteDetail: Boolean;

    procedure SetCustomTreeItem(const Value: TCustomTreeItem); virtual;
    function GetCaretXY: TPoint; virtual;
    procedure SetCaretXY(const Value: TPoint); virtual;
    function GetMasterObject: TgdcBase;virtual; abstract;
    function GetDetailObject: TgdcBase; virtual;
    function GetObjectID: Integer;
    procedure SetObjectId(const Value: Integer); virtual;
    procedure SetNode(const Value: TTreeNode);
    procedure SetModify(const Value: Boolean); virtual;
    procedure DoOnCreate; virtual;
    procedure DoOnDestroy; virtual;
    procedure DoBeforeDelete; virtual;
    procedure mDoOnNewRecord; virtual;
    procedure dDoOnNewRecord; virtual;
    //Возвращает строку всплывающей подсказки
    function GetInfoHint: String; virtual;
    //Возвращает строку сообщения необходимости сохранения
    function GetSaveMsg: string; virtual;
    //Возвращает сороку сообщения при удалении
    function GetDeleteMsg: string; virtual;
    function GetCanRun: Boolean; virtual;
    function GetCanPrepare: Boolean; virtual;
    function GetForm(Name: string): TCreateableForm;
    function GetFunctionID: Integer; virtual;
    procedure SetMessageListView(const Value: TListView); virtual;
    procedure SetOnCaretPosChange(const Value: TCaretPosChange); virtual;
    // Используется для обработки нового имени
    // Возр. ложь, если отмена
    function  NewNameUpdate: Boolean; virtual; abstract;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure GetNamesList(const SL: TStrings); virtual;
    function GetRunning: Boolean; virtual;
    procedure SetPropertyTreeForm(const Value: TdfPropertyTree); virtual;
    procedure PropertyDialog; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    procedure Post; virtual;
    procedure Cancel; virtual;
    function Delete: Boolean; virtual;
    procedure Setup(const FunctionName: String = ''); virtual;
    function Close: Boolean; virtual;
    function CloseQuery: Boolean; virtual;
    function Run(const SFType: sfTypes): Variant; virtual;
    procedure BuildReport(const OwnerForm: OleVariant); virtual;
    function CanBuildReport: Boolean; virtual;
    procedure Prepare; virtual;
    procedure EditFunction(ID: Integer); virtual;
    procedure InvalidateFrame; virtual;
    procedure Evaluate; virtual;
    procedure ShowTypeInfo; virtual;
    procedure GotoLine(Line, Column: Integer); virtual;
    procedure GotoLineNumber; virtual;
    procedure GotoErrorLine(Line: Integer); virtual;
    function GetSelectedText: string; virtual;
    function GetCurrentWord: string; virtual;
    procedure UpDateSyncs; virtual;
    procedure UpdateBreakPoints; virtual;
    procedure ToggleBreak; virtual;
    function CanToggleBreak: Boolean; virtual;
    function IsExecuteScript: Boolean; virtual;
    //Загрузка из файла
    procedure LoadFromFile; virtual;
    function CanLoadFromFile: Boolean; virtual;
    //Сохраниение в файл
    procedure SaveToFile; virtual;
    function CanSaveToFile: Boolean; virtual;
    //Сохраниение в файл
    procedure Find; virtual;
    procedure Replace; virtual;
    function CanFindReplace: Boolean; virtual;
    function CanGoToLineNumber: Boolean; virtual;
    //Копирование в буфер
    procedure Copy; virtual;
    function CanCopy: Boolean; virtual;
    //Вырезать в буфер
    procedure Cut; virtual;
    function CanCut: Boolean; virtual;
    //Вставить из буфера
    procedure Paste; virtual;
    function CanPaste: Boolean; virtual;
    //Копировать СКЛ
    procedure CopySQl; virtual;
    function CanCopySQL: Boolean; virtual;
    //Вставить СКЛ
    procedure PasteSQL; virtual;
    function CanPasteSQL: Boolean; virtual;
    function IsFunction(Id: Integer): Boolean; virtual;

    procedure Activate; virtual;
    procedure AddTosetting; virtual;

    procedure OnShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo); virtual;

    //Блок процедур отвечающих за копирование
    // ***
    // Проверяет возможность копирования объекта
    function CanMakeCopyObject: Boolean;
    // Вставляет объект
    procedure PasteObject; virtual;
    // не реализовано
    function Move(TreeItem: TCustomTreeItem): TCustomTreeItem; virtual;
    // Помещает объект в буфер
    procedure CopyObject; virtual;
    // ***
    function GetUniCopyname(BaseName: String; IDNewObject: Integer): String;

    class function GetNameById(Id: Integer): string; virtual; abstract;
    class function GetFunctionIdEx(Id: Integer): integer; virtual; abstract;
//    function GetUniname(SQLText, BaseName: String;
//      const NameList: TStrings; const IBSQL: TIBSQL): String;

    //Указывает на то что скрипт был запущен из данного фрайма
    property Running: Boolean read GetRunning;
    //Возвращает основной гдс-объект
    property MasterObject: TgdcBase read GetMasterObject;
    property DetailObject: TgdcBase read GetDetailObject;
    //Ид объекта
    property ObjectId: Integer read GetObjectID write SetObjectId;
    property FunctionId: Integer read GetFunctionID;
    //Нод в дереве для которого идет редактирование
    property Node: TTreeNode read FNode write SetNode;
    property SpeedButton: TTBCustomItem read FSpeedButton write SetSpeedButton;
    //
    property Modify: Boolean read FModify write SetModify;
    property CustomTreeItem: TCustomTreeItem read FCustomTreeItem write SetCustomTreeItem;
    property PropertyTreeForm: TdfPropertyTree read FPropertyTreeForm write SetPropertyTreeForm;
    property InfoHint: String read GetInfoHint;
    property CanRun: Boolean read GetCanRun;
    property CanPrepare: Boolean read GetCanPrepare;
    property CaretXY: TPoint read GetCaretXY write SetCaretXY;
    property MessageListView: TListView read FMessageListView write SetMessageListView;
    property ShowDeleteQuestion: Boolean read FShowDeleteQuestion write SetShowDeleteQuestion;
    property Name: string read GetName;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property OnCreate: TNotifyEvent read FOnCreate write SetOnCreate;
    property OnDestroy: TDestroyFrame read FOnDestroy write SetOnDestroy;
    property OnCaretPosChange: TCaretPosChange read FOnCaretPosChange write SetOnCaretPosChange;
    property OnChangeTreeItem: TChangeTreeItem read FOnChangeTreeItem write SetOnChangeTreeItem;
  end;

  TTBFrameButton = class(TTBCustomItem)
  private
    FButtonType: TTBMDIButtonType;
  protected
    function GetItemViewerClass (AView: TTBView): TTBItemViewerClass; override;
  public
    constructor Create (AOwner: TComponent); override;
  end;

  TTBFrameButtonItem = class(TTBCustomItem)
    FCloseItem: TTBFrameButton;
  private
    FOnItemClick: TNotifyEvent;
    procedure ItemClick(Sender: TObject);
    procedure SetOnItemClick(const Value: TNotifyEvent);
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateVisible(V: Boolean);

    property OnItemClick: TNotifyEvent read FOnItemClick write SetOnItemClick;
    property CloseItem: TTBFrameButton read FCloseItem;
  end;

implementation

uses
  gdcConstants,
  prp_MessageConst,
  prp_PropertySettings,
  evt_i_Base,
  at_AddToSetting,
  obj_i_Debugger,
  mtd_i_Base,
  gd_ClassList,
  gdcBaseInterface,
  gdcCustomFunction,
  rp_report_const,
  gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  FramsList: TList;
  FrameButtonsItems: TList;

const
  DefaultExt = 'dat';
  DefaultFilter = 'Файлы данных|*.dat|Все файлы|*.*';
{$R *.DFM}

{ TBaseFrame }

procedure TBaseFrame.Cancel;
begin
  if FShowCancelQu then
    if MessageBox(Application.Handle, 'Последние изменения будут потеряны.',
      MSG_WARNING, MB_OKCANCEL  or MB_ICONWARNING or MB_TASKMODAL) = ID_CANCEL then
      Exit;
  if Assigned(DetailObject) then
  begin
    DetailObject.Cancel;
    DetailObject.Close;
  end;
  MasterObject.BaseState := MasterObject.BaseState - [sDialog];
  MasterObject.Cancel;
  if MasterObject.IsEmpty then
  begin
    MasterObject.Insert;
  end else
    MasterObject.Edit;
  MasterObject.BaseState := MasterObject.BaseState + [sDialog];

  if Assigned(DetailObject) then
  begin
    DetailObject.Open;
    if DetailObject.IsEmpty then
    begin
      DetailObject.Insert;
    end else
      DetailObject.Edit;
  end;
    if (MasterObject.State = dsInsert) or (Assigned(DetailObject) and
      (DetailObject.State = dsInsert)) then Setup;
  FModify := False;
  FNeedSave := False;
end;

function TBaseFrame.Delete: Boolean;
var
  Value: Variant;
  FunctionKey: Integer;
  LocGdcBase: TgdcBase;
  CE: TgdClassEntry;
begin
  Result := False;
  //If it has not rights for delete then exit
  if not MasterObject.CanDelete then Exit;

  //Если из данного фрайма был запущен макрос то закрытие не возможно
  if Running then
  begin
    //Если скритп запущен из окна то это не событие и не метод
    //поэтому без зазрения совести снимаем скритп с выполнения
    if (Debugger <> nil) {and Debugger.IsPaused} then
      Debugger.Reset;
    MessageBox(Application.Handle,
      'В данный момент выполняется скрипт,'#13#10 +
      'запущенный из "Редактора свойств".'#13#10 +
      'Система делает попытку остановить'#13#10 +
      'выполнение скрипта. Пожалуйста повторите'#13#10 +
      'свой действия',  MSG_WARNING, MB_OK or MB_ICONWARNING +
      MB_APPLMODAL);
    Exit;
  end;

  //Если выполнение скрипта остановлено в данном фраме то выдаес
  //пользователю сообщение об этом.
  if (Debugger <> nil) and Debugger.IsPaused and
    IsExecuteScript then
  begin
    if MessageBox(Application.Handle, PChar(Format(
      'Перед удалением необходимо'#13#10 +
      'закончить выполнение скрипта "%s".', [CustomTreeItem.Name])),
      MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING +
      MB_APPLMODAL) = ID_OK then
      Debugger.Run
    else
      Exit;
  end;

  if FShowDeleteQuestion then
    //Задаем вопрос и если не получаем утв. ответа выходим
    if MessageBox(Application.Handle, PChar(GetDeleteMsg),
      MSG_WARNING, MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) <> IDYES then
      Exit;

  DoBeforeDelete;
  FunctionKey := 0;
  if Assigned(DetailObject) then
  begin
    Value := MasterObject.FieldByName(DetailObject.MasterField).Value;
    FunctionKey := DetailObject.ID;
  end;

  MasterObject.BaseState := MasterObject.BaseState - [sDialog];
  if MasterObject.State = dsInsert then
    MasterObject.Cancel
  else
    try
      MasterObject.Delete;
    except
      on E: Exception do
      begin
        if not (E is EAbort) then
          MessageBox(Application.Handle, PChar(E.Message),
            MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
        Exit;
      end;
    end;

  // 03.03.2003 DAlex. Удалять запись должен объект того же класса, что и создает ее.
  if FNeedDeleteDetail and Assigned(DetailObject) and (FunctionKey <> 0) then
  begin
    CE := gdClassList.Find(DetailObject.ClassName);
    if CE is TgdBaseEntry then
    begin
      LocGdcBase := TgdBaseEntry(CE).gdcClass.Create(nil);
      try
        LocGdcBase.Transaction := MasterObject.Transaction;
        LocGdcBase.SubSet := 'ByID';
        LocGdcBase.Params[0].AsInteger := FunctionKey;
        LocGdcBase.Open;
        if not LocGdcBase.Eof then
        try
          LocGdcBase.Delete;
        except
        end;
      finally
        LocGdcBase.Free;
      end;
    end;
  end;

  Modify := False;
  FNeedSave := False;
  Result := True;
  FShowNext := False;
  Free;
end;

function TBaseFrame.GetObjectID: Integer;
begin
  Result := MasterObject.ID;
end;

procedure TBaseFrame.Post;
var
  B: Boolean;
begin
  if dbeName.Focused then
    SendMessage(dbeName.Handle, CM_EXIT, 0, 0);
  if not MasterObject.CanEdit then
  begin
    B := FShowCancelQu;
    try
      FShowCancelQu := False;
      Cancel;
      Exit;
    finally
      FShowCancelQu := B;
    end;
  end;

  if Assigned(DetailObject) then
  begin
    DetailObject.Post;
    DetailObject.Close;
  end;
  MasterObject.BaseState := MasterObject.BaseState - [sDialog];
  try
    MasterObject.Post;
  except
    MasterObject.BaseState := MasterObject.BaseState + [sDialog];
    if DetailObject <> nil then
    begin
      DetailObject.Open;
      DetailObject.Edit;
    end;
    raise;  
  end;
  if Assigned(CustomTreeItem) then
    CustomTreeItem.Id := MasterObject.Id;
  MasterObject.Edit;
  MasterObject.BaseState := MasterObject.BaseState + [sDialog];
  if Assigned(DetailObject) then
  begin
    DetailObject.Open;
    DetailObject.Edit;
  end;
  FModify := False;
  FNeedSave := False;
  if Assigned(Node) then
    Node.Text := MasterObject.FieldByName(MasterObject.GetListField('')).AsString;

  if Assigned(CustomTreeItem) then
    CustomTreeItem.Name := MasterObject.FieldByName(MasterObject.GetListField('')).AsString;

  if FSpeedButton <> nil then
    FSpeedButton.Caption := MasterObject.FieldByName(MasterObject.GetListField('')).AsString;

  if Assigned(CustomTreeItem) and (CustomTreeItem.ItemType = tiReport) then
    EventControl.UpdateReportGroup;
end;

procedure TBaseFrame.SetNode(const Value: TTreeNode);
begin
  FNode := Value;
end;

procedure TBaseFrame.SetObjectId(const Value: Integer);
begin
  if MasterObject.ID <> Value then
  begin
    if MasterObject.Active then
      MasterObject.Close;
    MasterObject.ID := Value;
    MasterObject.Open;
    if Value = 0 then
    begin
      MasterObject.Insert;
      mDoOnNewRecord;
      PageControl.ActivePage := tsProperty;
      dbeName.SetFocus;
    end else
    begin
      if MasterObject.RecordCount = 0 then
      begin
        //Если у пользователя нет прав на редактирование записи выдаем об
        //этом сообщение.
        MessageBox(Application.Handle,
          'У вас отсутствуют права на просмотр,'#13#10 +
          'редактирование и удаление данной записи или'#13#10 +
          'запись была удалена другим пользователем системы.', MSG_WARNING,
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        Abort;
      end else
      begin
        if not MasterObject.CanEdit then
        begin
          MessageBox(Application.Handle,
            'У вас отсутствуют права на редактирование,'#13#10 +
            'и удаление данной записи', MSG_WARNING,
            MB_OK or MB_TASKMODAL);
        end else
          if not MasterObject.CanDelete then
            MessageBox(Application.Handle,
              'У вас отсутствуют права на удаленеие,'#13#10 +
              'данной записи', MSG_WARNING,
              MB_OK or MB_TASKMODAL);
      end;
      MasterObject.Edit;
    end;
    if Assigned(DetailObject) then
    begin
      if DetailObject.IsEmpty then
      begin
        DetailObject.Insert;
        dDoOnNewRecord;
      end else
        DetailObject.Edit;
    end;
    if (MasterObject.State = dsInsert) or (Assigned(DetailObject) and
      (DetailObject.State = dsInsert)) then
    { TODO :
    Производим первоначальную инициализацию если один из гдс
    объектов находится в режиме вставки }
      Setup;
    MasterObject.BaseState := MasterObject.BaseState + [sDialog];
    FModify := False;
    if Assigned(FOnChangeTreeItem) then
      FOnChangeTreeItem(Self, Value);
  end;
end;

procedure TBaseFrame.Setup(const FunctionName: String = '');
begin
end;

function TBaseFrame.GetDetailObject: TgdcBase;
begin
  Result := nil;
end;

procedure TBaseFrame.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TBaseFrame.SetOnCreate(const Value: TNotifyEvent);
begin
  FOnCreate := Value;
end;

procedure TBaseFrame.SetOnDestroy(const Value: TDestroyFrame);
begin
  FOnDestroy := Value;
end;

constructor TBaseFrame.Create(AOwner: TComponent);
var
  I: Integer;
  B: Boolean;
begin
  B := UnMethodMacro;
  UnMethodMacro := True;
  try
    inherited;
    for I := 0 to ComponentCount - 1 do
      if Components[I] is TgdcBase then
      begin
        TgdcBase(Components[I]).UseScriptMethod := False;
        TgdcBase(Components[I]).QueryFiltered := False;
      end;
    FNeedDeleteDetail:= True;
    FShowDeleteQuestion := True;
    DoOnCreate;
    Modify := False;
    FShowCancelQu := True;
    FShowNext := True;
    FramsList.Add(Self);
  finally
    UnMethodMacro := B;
  end;
end;

destructor TBaseFrame.Destroy;
begin
  FramsList.Remove(Self);

  DoOnDestroy;

  if Assigned(MasterObject) and MasterObject.Active then
    MasterObject.Close;

  if FSpeedButton <> nil then
    FSpeedButton := nil;

  if Assigned(CustomTreeItem) then
  begin
    CustomTreeItem.EditorFrame := nil;
    CustomTreeItem := nil;
  end;
  
  if Assigned(FEvaluate) then
    FEvaluate.Free;

  inherited;
end;

procedure TBaseFrame.DoOnCreate;
begin
  if Assigned(OnCreate) then
    OnCreate(Self);
end;

procedure TBaseFrame.DoOnDestroy;
begin
  if Assigned(OnDestroy) then
    OnDestroy(Self, FShowNext);
end;

procedure TBaseFrame.dbeFunctionNameChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TBaseFrame.SetModify(const Value: Boolean);
begin
  FModify := Value;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TBaseFrame.dDoOnNewRecord;
begin

end;

procedure TBaseFrame.mDoOnNewRecord;
begin

end;

procedure TBaseFrame.SetCustomTreeItem(const Value: TCustomTreeItem);
begin
  FCustomTreeItem := Value;
end;

procedure TBaseFrame.actClosePageExecute(Sender: TObject);
begin
  Close;
end;

function TBaseFrame.Close: Boolean;
begin
  Result := CloseQuery;
  if Result then Free;
end;

procedure TBaseFrame.SetPropertyTreeForm(const Value: TdfPropertyTree);
begin
  FPropertyTreeForm := Value;
end;

function TBaseFrame.GetInfoHint: String;
begin
  Result := '';
end;

function TBaseFrame.GetForm(Name: string): TCreateableForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[I] is TCreateableForm then
    begin
      if UpperCase(TCreateableForm(Screen.Forms[I]).InitialName) =
        UpperCase(Name) then
      begin
        Result := TCreateableForm(Screen.Forms[I]);
        Break;
      end;
    end;
  end;
end;


function TBaseFrame.GetCanPrepare: Boolean;
begin
  Result := False;
end;

function TBaseFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

procedure TBaseFrame.Prepare;
begin

end;

function TBaseFrame.Run(const SFType: sfTypes): Variant;
begin

end;

procedure TBaseFrame.EditFunction(ID: Integer);
begin

end;

function TBaseFrame.GetFunctionID: Integer;
begin
  Result := 0;
end;

procedure TBaseFrame.InvalidateFrame;
begin

end;

function TBaseFrame.GetCaretXY: TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
end;

procedure TBaseFrame.SetCaretXY(const Value: TPoint);
begin

end;

procedure TBaseFrame.Evaluate;
begin
  if not Assigned(FEvaluate) then
    FEvaluate := TdlgEvaluate.Create(Self);
  FEvaluate.cbExpression.Text := '';
  FEvaluate.ShowModal;
end;

procedure TBaseFrame.GotoLine(Line, Column: Integer);
begin

end;

procedure TBaseFrame.GotoErrorLine(Line: Integer);
begin

end;

function TBaseFrame.GetSelectedText: string;
begin
  Result := '';
end;

function TBaseFrame.GetSaveMsg: string;
begin
  Result := 'Информация была изменена. Сохранить?';
end;

procedure TBaseFrame.dbeNameChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TBaseFrame.UpDateSyncs;
begin

end;

procedure TBaseFrame.ToggleBreak;
begin

end;

function TBaseFrame.CanToggleBreak: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanLoadFromFile: Boolean;
begin
  Result := MasterObject <> nil;
end;

procedure TBaseFrame.LoadFromFile;
var
  D: TOpenDialog;
begin
  if MasterObject <> nil then
  begin
    D := TOpenDialog.Create(nil);
    try
      D.DefaultExt := DefaultExt;
      D.Filter := DefaultFilter;
      D.FileName := dbeName.Text;
      if D.Execute then
        MasterObject.LoadFromFile(D.FileName);
      MasterObject.Edit  
    finally
      D.Free;
    end;
  end;
end;

function TBaseFrame.CanSaveToFile: Boolean;
begin
  Result := MasterObject <> nil;
end;

procedure TBaseFrame.SaveToFile;
var
  D: TSaveDialog;
begin
  if MasterObject <> nil then
  begin
    D := TSaveDialog.Create(nil);
    try
      D.DefaultExt := DefaultExt;
      D.Filter := DefaultFilter;
      D.FileName := dbeName.Text;
      if D.Execute then
        MasterObject.SaveToFile(D.FileName);
      MasterObject.Edit  
    finally
      D.Free;
    end;
  end;
end;

function TBaseFrame.CanFindReplace: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanGoToLineNumber: Boolean;
begin
  Result := False;
end;

procedure TBaseFrame.Find;
begin

end;

procedure TBaseFrame.Replace;
begin

end;

function TBaseFrame.CanCopy: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanCopySQL: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanCut: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanPaste: Boolean;
begin
  Result := False;
end;

function TBaseFrame.CanPasteSQL: Boolean;
begin
  Result := False;
end;

procedure TBaseFrame.Copy;
begin

end;

procedure TBaseFrame.CopySQl;
begin

end;

procedure TBaseFrame.Cut;
begin

end;

procedure TBaseFrame.Paste;
begin

end;

procedure TBaseFrame.PasteSQL;
begin

end;

procedure TBaseFrame.SetMessageListView(const Value: TListView);
begin
  FMessageListView := Value;
end;

function TBaseFrame.GetRunning: Boolean;
begin
  Result := FRunning;
end;

function TBaseFrame.GetDeleteMsg: string;
begin
  Result := 'Удаленные данные восстановить невозможно. Удалить?';
end;

procedure TBaseFrame.dbeNameDropDown(Sender: TObject);
var
  I: Integer;
  W: Integer;
  T: Integer;
  C: TControlCanvas;
begin
  dbeName.Items.Clear;
  GetNamesList(dbeName.Items);

  W := SendMessage(dbeName.Handle, CB_GETDROPPEDWIDTH, 0, 0);
  C := TControlCanvas.Create;
  try
    C.Control := dbeName;
    C.Font := dbeName.Font;
    for I := 0 to dbeName.Items.Count -1 do
    begin
      T := C.TextWidth(dbeName.Items[I]);
      if T > W then W := T + 10;
    end;
  finally
    C.Free;
  end;
  SendMessage(dbeName.Handle, CB_SETDROPPEDWIDTH, W, 0);
end;

procedure TBaseFrame.SetOnCaretPosChange(const Value: TCaretPosChange);
begin
  FOnCaretPosChange := Value;
end;

procedure TBaseFrame.BuildReport(const OwnerForm: OleVariant);
begin

end;

function TBaseFrame.CanBuildReport: Boolean;
begin
  Result := False;
end;

procedure TBaseFrame.SetShowDeleteQuestion(const Value: Boolean);
begin
  FShowDeleteQuestion := Value;
end;

procedure TBaseFrame.SetSpeedButton(const Value: TTBCustomItem);
begin
  FSpeedButton := Value;
end;

procedure TBaseFrame.DoBeforeDelete;
begin

end;

procedure TBaseFrame.SetOnChangeTreeItem(const Value: TChangeTreeItem);
begin
  FOnChangeTreeItem := Value;
end;

function TBaseFrame.GetName: string;
begin
  if FCustomTreeItem <> nil then
    Result := FCustomTreeItem.Name
  else
    Result := '';  
end;

function TBaseFrame.GetCurrentWord: string;
begin
  Result := '';
end;

procedure TBaseFrame.Activate;
begin
  SetFocus
end;

procedure TBaseFrame.AddTosetting;
begin
  at_AddToSetting.AddToSetting(False, '', '', MasterObject, nil);
end;

procedure TBaseFrame.actAddToSettingExecute(Sender: TObject);
begin
  AddToSetting;
end;

procedure TBaseFrame.actAddToSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (MasterObject <> nil) and (MasterObject.State = dsEdit);
end;

procedure TBaseFrame.AlignControls(AControl: TControl; var Rect: TRect);
var
  I: Integer;
begin
  inherited;

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TgdcBase then
      TgdcBase(Components[I]).UseScriptMethod := False;
    if (Components[I] is TControl) and not(Components[I] is TBaseFrame) then
    begin
      if (TControl(Components[I]).Align <> alClient) and
        (akRight in TControl(Components[I]).Anchors) and
        Assigned(TControl(Components[I]).Parent) then
        TControl(Components[I]).Width :=
          TControl(Components[I]).Parent.ClientWidth - 10 -
          TControl(Components[I]).Left;
    end;
  end;
end;

procedure TBaseFrame.GetNamesList(const SL: TStrings);
begin

end;

function TBaseFrame.CloseQuery: Boolean;
var
  MR: Integer;
begin
  Result := True;
  if Modify or FNeedSave then
  begin
    MR := IDYES;

    if Modify and not PropertySettings.GeneralSet.AutoSaveChanges then
    begin
      MR := MessageBox(Application.Handle, PChar(GetSaveMsg), MSG_WARNING,
        MB_YESNOCANCEL or MB_ICONWARNING +  MB_APPLMODAL);
    end;

    case MR of
      IDYES:
        try
          Post
        except
          on E: Exception do
          begin
            if MessageBox(Application.Handle, PChar(Format(
              'При сохранении изменений %s возникла ошибка: '#13#10 +
              '%s'#13#10'Продолжить закрытие окна с потерей последних изменений %s?',
              [Name, E.Message, Name])),
              MSG_ERROR, MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) <> ID_YES then
              Result := False
          end;
        end;
      IDNO:
        begin
          FShowCancelQu := False;
          try
            Cancel;
          finally
            FShowCancelQu := True;
          end;
        end;
      IDCANCEL: Result := False;
    end;
  end;

  if Result then
  begin
    //Если из данного фрайма был запущен макрос то закрытие не возможно
    if Running then
    begin
      //Если скритп запущен из окна то это не событие и не метод
      //поэтому без зазрения совести снимаем скритп с выполнения
      if (Debugger <> nil) {and Debugger.IsPaused} then
        Debugger.Reset;
      MessageBox(Application.Handle,
        'В данный момент выполняется скрипт,'#13#10 +
        'запущенный из "Редактора свойств".'#13#10 +
        'Система делает попытку остановить'#13#10 +
        'выполнение скрипта. Пожалуйста повторите'#13#10 +
        'свой действия',  MSG_WARNING, MB_OK or MB_ICONWARNING +
        MB_APPLMODAL);
      Result := False;
      Exit;
    end;
  end;

  if Result then
  begin
    //Если выполнение скрипта остановлено в данном фраме то выдаес
    //пользователю сообщение об этом.
    if (Debugger <> nil) and Debugger.IsPaused and
      IsExecuteScript then
    begin
      Result :=  MessageBox(Application.Handle, PChar(Format(
        'После закрытия "%s" скрипт'#13#10 +
        'продолжит cвоё выполнение.'#13#10, [CustomTreeItem.Name])),
        MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING +
        MB_APPLMODAL) = ID_OK;
      if Result then Debugger.Run
    end;
  end;
end;

function TBaseFrame.IsExecuteScript: Boolean;
begin
  Result := False;
end;

procedure TBaseFrame.OnShowHint(var HintStr: String; var CanShow: Boolean;
  var HintInfo: THintInfo);
begin

end;

procedure TBaseFrame.UpdateBreakPoints;
begin

end;

function TBaseFrame.IsFunction(Id: Integer): Boolean;
begin
  Result := id = GetFunctionID;
end;

procedure TBaseFrame.actPropertyExecute(Sender: TObject);
begin
  PropertyDialog;
end;

procedure TBaseFrame.PropertyDialog;
var
  R: Boolean;
begin
  if MasterObject <> nil then
  begin
    EventControl.DisableProperty;
    try
      R := MasterObject.EditDialog('Tgdc_dlgObjectProperties');
      if R then Modify := R;
    finally
      EventControl.EnableProperty;
    end;
  end;
end;

procedure TBaseFrame.actPropertyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (MasterObject <> nil) and
    (MasterObject.State = dsEdit);
end;

procedure TBaseFrame.CopyObject;
begin
  //
end;

function TBaseFrame.Move(TreeItem: TCustomTreeItem): TCustomTreeItem;
begin
  Result := nil;
end;

function TBaseFrame.CanMakeCopyObject: Boolean;
begin
  if (MasterObject = nil) or (MasterObject.State <> dsBrowse) then
  begin
    MessageBox(Handle, PChar('Объект, помещаеммый с буфер, должен быть сохранен.'),
      PChar('Ошибка'), MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    Result := False;
  end else
    Result := True;
end;

procedure TBaseFrame.PasteObject;
begin
//
end;

function TBaseFrame.GetUniCopyname(BaseName: String;
  IDNewObject: Integer): String;
var
  RUIDStr: String;
  RUID: TRUID;
begin
  RUID.XID := IDNewObject;
  if IBLogin <> nil then
    RUID.DBID := IBLogin.DBVersionID;

  RUIDStr := RUIDToStr(RUID);
  if (Length(BaseName) + Length(RUIDStr)) > 60 then
    BaseName := System.Copy(BaseName, 1, 60 - Length(RUIDStr));
  Result := BaseName + RUIDStr;
end;

procedure TBaseFrame.ShowTypeInfo;
begin
//
end;

procedure TBaseFrame.GotoLineNumber;
begin

end;

{ TTBFrameButtonItem }

constructor TTBFrameButtonItem.Create(AOwner: TComponent);

  function CreateItem (const AType: TTBMDIButtonType): TTBFrameButton;
  begin
    Result := TTBFrameButton.Create(Self);
    Result.FButtonType := AType;
    Result.OnClick := ItemClick;
  end;
begin
  inherited;
  ItemStyle := ItemStyle + [tbisEmbeddedGroup];
  FCloseItem := CreateItem(tbmbClose);
  Add (FCloseItem);
  AddToList (FrameButtonsItems, Self);
end;

destructor TTBFrameButtonItem.Destroy;
begin
  RemoveFromList (FrameButtonsItems, Self);
  inherited;
end;

procedure TTBFrameButtonItem.ItemClick(Sender: TObject);
begin
  if Assigned(FOnItemClick) then
    FOnItemClick(Sender);
end;

procedure TTBFrameButtonItem.SetOnItemClick(const Value: TNotifyEvent);
begin
  FOnItemClick := Value;
end;

{ TTBMDIButton }

constructor TTBFrameButton.Create(AOwner: TComponent);
begin
  inherited;
  ItemStyle := ItemStyle - [tbisSelectable, tbisRedrawOnSelChange] +
    [tbisRightAlign];
end;

function TTBFrameButton.GetItemViewerClass(
  AView: TTBView): TTBItemViewerClass;
begin
  Result := TTBMDIButtonItemViewer;
end;

procedure TTBFrameButtonItem.UpdateVisible(V: Boolean);
begin
  if FCloseItem.Visible <> V then
  begin
    FCloseItem.Visible := V;
  end;
end;

initialization
  FramsList := TList.Create;
  RegisterClass(TBaseFrame);
finalization
  UnRegisterClass(TBaseFrame);
  FramsList.Free;
end.
