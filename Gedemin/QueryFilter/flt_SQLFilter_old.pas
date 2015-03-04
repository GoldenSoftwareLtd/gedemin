
{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

    flt_sqlFilter.pas

  Abstract

    Gedemin project. TgsQueryFilter components.

  Author

    Andrey Shadevsky

  Revisions history

    It was created in the summer begining.
    1.00    30.09.00    JKL        Initial version.
    2.00    09.11.00    JKL        Rebuild structure
    2.01    12.12.00    JKL        Add ActionList for Menu
    3.00    07.05.01    JKL        Final version. Search 'gs' in code.
    3.01    29.10.01    JKL        Entered params and script params is added.
    3.02    26.11.01    JKL        Domain condition processing for params is added.
    3.03    02.03.02    JKL        Distinct and other was added.
    3.04    18.03.02    JKL        Original order is dropped. Dlg window for long query (try finally).

--}

unit flt_sqlFilter;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  IBQuery,            IBDatabase,         flt_dlgShowFilter_unit,
  flt_sqlfilter_condition_type,           IBSQL,              IBCustomDataSet,
  DB,                 Menus,              flt_sql_parser,     gd_security,
  IBTable,            flt_msgShowMessage_unit, ActnList;

const
  UnknownDataSet = 'Неизвестный TIBCustomDataSet';
  // Строка идентефикатора
  FQueryAlias = '/* Текст запроса созданный компонентом фильтрации */';
  // Время выполнения запроса, после которого появляется окно сообщения (~10 sec)
  FMaxExecutionTime = 0.0001;
  // Этим значением определяется размером полей в таблице flt_componentfilter
  // По этому значению обрезаются все параметры для получения ключа компоненты
  FIndexFieldLength = 20;

// Для обращения к протектед части
type
  TIBCustomDataSetCracker = class(TIBCustomDataSet);

// Компонент для вызова диалогового окна в котором можно
// задавать условия фильтрации
type
  TgsSQLFilter = class(TComponent)
  private
    FBase: TIBBase;

    FComponentKey: Integer;     // Хранится ключ компонента фильтрации
    FIsCompKey: Boolean;        // Указатель считан ключ или нет
    FOwnerName: String;         // Хранится имя родителя. В дестройте он уже уничтожен, а использовать надо.

    FFilterData: TFilterData;   // Структура для хранения данных текущего фильтра

    FNoVisibleList: TStrings;    // Список полей по которым не надо задавать условия
    FTableList: TfltStringList;  // Наименование таблицы на которую налаживаются условия
    FLinkCondition: TfltStringList; // Список связок. Для правильного наименования таблиц.

    FQueryText: TStrings;    // Полный текст сформированного запроса

    FSelectText: TStrings;   // Начальный текст отображаемых полей
    FFromText: TStrings;     // Начальный текст откуда
    FWhereText: TStrings;    // Начальный текст условий
    FOtherText: TStrings;    // Текст находящийся между WHERE и ORDER BY
    FOrderText: TStrings;    // Начальный текст сортировки

    FFilterName: String;        // Наименование фильтра
    FFilterComment: String;     // Комментарий фильтра
    FLastExecutionTime: TTime;  // Время последнего выполнения
    FDeltaReadCount: Integer;   // Количесто сделанных обращений к фильтру
    FCurrentFilter: Integer;    // Текущий фильтр
    FIsSQLTextChanged: Boolean; // Указатель был ли изменен начальный запрос фильтра

    FOnConditionChanged: TConditionChanged;     // Событие по изменению условий
    FOnFilterChanged: TFilterChanged;           // Событие по изменению выбранного фильтра

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetTransaction(Value: TIBTransaction);

    procedure SetNoVisibleList(Value: TStrings);
    procedure SetTableList(Value: TfltStringList);

    function GetConditionCount: Integer;
    function GetOrderByCount: Integer;
    // Возвращает текст фильтра
    function GetFilterString: String;

    function GetCondition(const AnIndex: Integer): TFilterCondition;
    procedure SetCondition(const AnIndex: Integer; const AnFilterCondition: TFilterCondition);

    function GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
    procedure SetOrderBy(const AnIndex: Integer; const AnFilterOrderBy: TFilterOrderBy);

    // Получаем наименование приложение обрезанное на FIndexFieldLength
    function GetApplicationName: String;

  protected
    FFilterBody: TdlgShowFilter;// Диалоговое окно для изменения параметров фильтра. Создается сразу.

    // Сохраняем время и увеличиванем количество сохранений текущего фильтра
    procedure SaveFilter;
    // Загружаем фильтр по его ключу
    function LoadFilter(const AnFilterKey: Integer): Boolean;
    // Получаем ключ компоненты
    procedure ExtractComponentKey;

    // Функция создает текст запроса по условиям
    function CreateSQLText(AFilterData: TFilterData): Boolean;

    // Это вещь относится только к компоненте. Так надо наверное.
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    //function ShowDialog: Boolean;

    // Использовать только для получения запроса
    procedure SetQueryText(const AnSQLText: String);

    function CreateSQL: Boolean;
    // Создаем новый фильтр
    function AddFilter(out AnFilterKey: Integer): Boolean;
    // Редактируем существующий фильтр
    function EditFilter(out AnFilterKey: Integer): Boolean;
    // Удаляем существующиц фильтр
    function DeleteFilter: Boolean;

    // Добавить условие фильтрации
    function AddCondition(AFilterCondition: TFilterCondition): Integer;
    // Удалить условие фильтрации
    procedure DeleteCondition(const AnIndex: Integer);
    // Очистить список условий фильтрации
    procedure ClearConditions;

    // Добавить условие сортировки
    function AddOrderBy(AnOrderBy: TFilterOrderBy): Integer;
    // Удалить условие сортировки
    procedure DeleteOrderBy(const AnIndex: Integer);
    // Очистить список условий сортировки
    procedure ClearOrdersBy;

    procedure ReadFromStream(S: TStream);
    procedure WriteToStream(S: TStream);

    property SelectText: TStrings read FSelectText;   // Начальный текст отображаемых полей
    property FromText: TStrings read FFromText;     // Начальный текст откуда
    property WhereText: TStrings read FWhereText;    // Начальный текст условий
    property OtherText: TStrings read FOtherText;    // Начальный текст условий
    property OrderText: TStrings read FOrderText;    // Начальный текст сортировки

    property FilteredSQL: TStrings read FQueryText;    // Текст запроса с наложенными условиями

    property FilterName: String read FFilterName;       // Наименование текущего фильтра
    property FilterComment: String read FFilterComment; // Комментарий текущего фильтра
    property LastExecutionTime: TTime read FLastExecutionTime;  // Последнее время выполнение тек. фильтра
    property CurrentFilter: Integer read FCurrentFilter;// Ключ текущего фильтра
    property FilterString: String read GetFilterString; // Текст условий текущего фильтра

    property ConditionCount: Integer read GetConditionCount;    // Количество условий фильтрации
    property Conditions[const AnIndex: Integer]: TFilterCondition read GetCondition write SetCondition;

    property OrderByCount: Integer read GetOrderByCount;        // Количество условий сортировки
    property OrdersBy[const AnIndex: Integer]: TFilterOrderBy read GetOrderBy write SetOrderBy;

    // Список таблиц вытянутых из запроса
    property TableList: TfltStringList read FTableList write SetTableList;
    property FilterData: TFilterData read FFilterData;

  published
    property OnConditionChanged: TConditionChanged read FOnConditionChanged write FOnConditionChanged;
    property OnFilterChanged: TFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property NoVisibleList: TStrings read FNoVisibleList write SetNoVisibleList;
  end;

type
  TgsQueryFilter = class(TgsSQLFilter)
  private
    FIBDataSet: TIBCustomDataSet;         // Компонент в котором будет меняться текст запроса
    FPopupMenu: TPopupMenu;               // Компонент меню для управления фильтром
    FOldBeforeOpen: TDataSetNotifyEvent;        // Храним старое событие перед открытием
    FOldBeforeDatabaseDisconect: TNotifyEvent;  // Храним старое событие перед Disconect
    FOldShortCut: TShortCutEvent;
    FMessageDialog: TmsgShowMessage;    // Диалог сообщения

    FActionList: TActionList;

    FShowBeforeFilter: Boolean; // Флаг показа предупреждения перед выполнением длинного фильтра
    //FParamItemIndex: Integer;
    FRecordCount: Integer;      // Количество записей в запросе

    FIsFirstOpen: Boolean;      // Флаг первого открытия. Все настройки делаются в момент первого открытия
    FIsSQLChanging: Boolean;      // ??? Проверить необходимость данного параметра
    FIsLastSave: Boolean;       // Флаг был ли сохранен последний фильтр

    procedure SetQuery(Value: TIBCustomDataSet);

    procedure SelfBeforeDisconectDatabase(Sender: TObject);
    procedure SelfBeforeOpen(DataSet: TDataSet);
    procedure SelfOnShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure SeparateQuery;

    procedure DoOnCreateFilter(Sender: TObject);// Событие вызываемое из меню по создании нового фильтра
    procedure DoOnEditFilter(Sender: TObject);  // Событие ... по редактированию
    procedure DoOnDeleteFilter(Sender: TObject);// Событие ... по удалению

    procedure DoOnFilterBack(Sender: TObject);  // Событие ... по отмене
    procedure DoOnSelectFilter(Sender: TObject);// Событие ... по выбору сохраненного фильтра
    procedure DoOnViewFilterList(Sender: TObject);// Событие ... по просмотру списка фильтров
    procedure DoOnRecordCount(Sender: TObject); // События ... по выводу количества записей в запросе
    procedure DoOnRefresh(Sender: TObject); //  События ... по обновлению параметров

    // Процедура создания меню
    procedure MakePopupMenu(AnPopupMenu: TMenu);
    procedure CreateActions;

    // Получение ключа пользователя
    function GetUserKey: String;
    function GetISUserKey: String;

    // Отображение предупреждения
    procedure ShowWarning;

    // Извлекаем кодичество записей
    function GetRecordCount: Integer;

    // Сделать необходимые элементы меню доступными AnEnabled
    procedure SetEnabled(const AnEnabled: Boolean);

    function IsIBQuery: Boolean;
    function GetOwnerName: String;

  protected
    procedure DoOnWriteToFile(Sender: TObject);
    procedure DoOnReadFromFile(Sender: TObject);

    function GetDBVersion: String;      // Получаем версию базы данных
    function GetCRC: Integer;           // Получаем CRC запроса
    // Сравниваем версии запросов
    function CompareVersion(const OldCRC: Integer; const DBVersion: String; const Question: Boolean): Boolean;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property RecordCount: Integer read GetRecordCount;

    procedure FilterQuery;      // Устанавливаем условия
    procedure RevertQuery;      // Отменяем условия

    procedure CreatePopupMenu;  // Создаем меню

    procedure SaveLastFilter;   // Сохраняем последний фильтр
    procedure LoadLastFilter;   // Загружаем последний фильтр

    procedure PopupMenu(const X: Integer = -1; const Y: Integer = -1);

    //function ShowDialogAndQuery: Boolean;
  published
    // Компонента базы данных
    property Database;
    // Список невидимых полей
    property NoVisibleList;
    // Компонента TIBQuery
    property IBDataSet: TIBCustomDataSet read FIBDataSet write SetQuery;
    // Событие по изменению условий
    property OnConditionChanged;
    // Событие по изменению тек. фильтра
    property OnFilterChanged;
  end;

type
  TCrackerFilterCondition = class(TFilterCondition);

procedure Register;

implementation

uses
   gd_directories_const, flt_msgBeforeFilter_unit, Registry,
   flt_dlgFilterList_unit, jclMath, gd_SetDatabase, flt_ScriptInterface;

{TgsSQLFilter}

constructor TgsSQLFilter.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBase := TIBBase.Create(nil);

  FNoVisibleList := TStringList.Create;
  FTableList := TfltStringList.Create;

  if not (csDesigning in ComponentState) then
  begin
    Transaction := TIBTransaction.Create(Self);
    Transaction.Params.Clear;
    Transaction.Params.Add('read_committed');
    Transaction.Params.Add('rec_version');
    Transaction.Params.Add('nowait');
    Transaction.DefaultDatabase := Database;

    FFilterBody := TdlgShowFilter.Create(Self);
    FFilterData := TFilterData.Create;

    FLinkCondition := TfltStringList.Create;

    FQueryText := TStringList.Create;

    FSelectText := TStringList.Create;
    FFromText := TStringList.Create;
    FWhereText := TStringList.Create;
    FOtherText := TStringList.Create;
    FOrderText := TStringList.Create;
  end;
end;

destructor TgsSQLFilter.Destroy;
begin
  FreeAndNil(FTableList);
  FreeAndNil(FNoVisibleList);

  if not (csDesigning in ComponentState) then
  begin
    FFilterData.Free;
    FFilterBody.Free;
    FLinkCondition.Free;

    FQueryText.Free;

    FSelectText.Free;
    FFromText.Free;
    FWhereText.Free;
    FOtherText.Free;
    FOrderText.Free;
    if Transaction <> nil then
    begin
      Transaction.Free;
      Transaction := nil;
    end;
  end;

  FreeAndNil(FBase);

  inherited Destroy;
end;

procedure TgsSQLFilter.SetTableList(Value: TfltStringList);
begin
  FTableList.Assign(Value);
end;

procedure TgsSQLFilter.SetNoVisibleList(Value: TStrings);
begin
  FNoVisibleList.Assign(Value);
end;

function TgsSQLFilter.GetDatabase: TIBDatabase;
begin
  if FBase <> nil then
    result := FBase.Database
  else
    result := nil;
end;

function TgsSQLFilter.GetTransaction: TIBTransaction;
begin
  Result := FBase.Transaction;
end;

procedure TgsSQLFilter.SetDatabase(Value: TIBDatabase);
begin
  if FBase.Database <> Value then
  begin
    FBase.Database := Value;
    if Transaction <> nil then
      Transaction.DefaultDatabase := Value;
  end;
end;

procedure TgsSQLFilter.SetTransaction(Value: TIBTransaction);
begin
  if (FBase.Transaction <> Value) then
  begin
    FBase.Transaction := Value;
  end;
end;

function TgsSQLFilter.AddFilter(out AnFilterKey: Integer): Boolean;
begin
  // Стартуем транзакцию
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // Делаем необходимые настройки
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // Извлекаем ключ компонента
  ExtractComponentKey;
  // Вызываем метод создания нового фильтра
  AnFilterKey := FFilterBody.AddFilter(FComponentKey, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged, Result);
  // Устанавливаем флаг, что запрос измене не был
  FIsSQLTextChanged := True;
  // Генерируем событие
  if (AnFilterKey <> 0) and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // Закрываем транзакцию
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

function TgsSQLFilter.EditFilter(out AnFilterKey: Integer): Boolean;
begin
  // Стартуем транзакцию
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // Необходимые установки
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // Извлекаем ключ компонента
  ExtractComponentKey;
  // Вызываем метод редактирования
  AnFilterKey := FFilterBody.EditFilter(FCurrentFilter, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged, Result);
  // Устанавливаем флаг, что запрос измене не был
  FIsSQLTextChanged := True;
  // Генерируем событие
  if (AnFilterKey <> 0) and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // Закрываем транзакцию
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

function TgsSQLFilter.DeleteFilter: Boolean;
begin
  // Стартуем транзакцию
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // Необходимые установки
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // Извлекаем ключ компонента
  ExtractComponentKey;
  // Вызываем метод удаления
  Result := FFilterBody.DeleteFilter(FCurrentFilter);
  // Генерируем событие
  if Result and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // Закрываем транзакцию
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

(*function TgsSQLFilter.ShowDialog: Boolean;
begin
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  ExtractComponentKey;
  Result := False;
{  Result := FFilterBody.AddFilter(FComponentKey, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged) <> 0;
{  Result := FFilterBody.ShowFilter(FFilterData.ConditionList, FFilterData.OrderByList,
   FNoVisibleList, FTableList, FLinkCondition, True, FIsSQLTextChanged);}
  FIsSQLTextChanged := True;
  if Result and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end; *)

// Сохраняем параметры текущего фильтра
procedure TgsSQLFilter.SaveFilter;
var
  TempSQL: TIBQuery;
begin
  if FCurrentFilter = 0 then
    Exit;
  TempSQL := TIBQuery.Create(Self);
  try
    // Необходимые установки
    TempSQL.Database := Database;
    TempSQL.Transaction := Transaction;
    // Запрос АПДЭЙТА
    TempSQL.SQL.Text := 'UPDATE flt_savedfilter SET lastextime = :lasttime, readcount = readcount + :deltaread WHERE id  = ' + IntToStr(FCurrentFilter);
    TempSQL.ParamByName('lasttime').AsDateTime := FLastExecutionTime;
    TempSQL.ParamByName('deltaread').AsInteger := FDeltaReadCount;
    try
      // Стартуем транзакции
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      // Пытаемся выполнить
      TempSQL.ExecSQL;
    except
      // Обработка ошибки
      on E: Exception do
        MessageBox(0, @E.Message[1], 'Внимание', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
    // Закрываем транзакцию
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    TempSQL.Free;
  end;
end;

// Загрузка фільтра
function TgsSQLFilter.LoadFilter(const AnFilterKey: Integer): Boolean;
var
  TempSQL: TIBQuery;
  BlobStream: TIBDSBlobStream;
begin
  Result := True;
  TempSQL := TIBQuery.Create(Self);
  try
    FFilterData.Clear;
    // Необходимые установки
    TempSQL.Database := Database;
    TempSQL.Transaction := Transaction;
    // Текст запроса
    TempSQL.SQL.Text := 'SELECT id, name, description, lastextime, data FROM flt_savedfilter WHERE id = :ID';
    TempSQL.ParamByName('id').AsInteger := AnFilterKey;
    try
      // Стартуем транзакцию
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      // Пытаемся выполнить запрос
      TempSQL.Open;
      // Если найден
      if not TempSQL.Eof then
      begin
        // Считываем параметры фильтра
        FCurrentFilter := TempSQL.FieldByName('id').AsInteger;
        FFilterName := TempSQL.FieldByName('name').AsString;
        FFilterComment := TempSQL.FieldByName('description').AsString;
        FLastExecutionTime := TempSQL.FieldByName('lastextime').AsDateTime;
        FDeltaReadCount := 0;

        BlobStream := TempSQL.CreateBlobStream(TempSQL.FieldByName('data'), bmRead) as TIBDSBlobStream;
        try
          FFilterData.ReadFromStream(BlobStream);
        finally
          BlobStream.Free;
        end;
        if Assigned(FOnFilterChanged) then
          FOnFilterChanged(Self, FCurrentFilter);
      end else
      begin
        Result := False;
        raise Exception.Create('Выбранный фильтр не найден');
      end;
    except
      // Обрабатываем ошибку
      on E: Exception do
        MessageBox(0, @E.Message[1], 'Внимание', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
    // Закрываем транзакцию
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    TempSQL.Free;
  end;
end;

function TgsSQLFilter.GetConditionCount: Integer;
begin
  Result := FFilterData.ConditionList.Count;
end;

function TgsSQLFilter.GetOrderByCount: Integer;
begin
  Result := FFilterData.OrderByList.Count;
end;

function TgsSQLFilter.GetFilterString: String;
begin
  Result := FFilterData.FilterText + FFilterData.OrderText;
end;

function TgsSQLFilter.GetCondition(const AnIndex: Integer): TFilterCondition;
begin
  Result := FFilterData.ConditionList.Conditions[AnIndex];
end;

procedure TgsSQLFilter.SetCondition(const AnIndex: Integer; const AnFilterCondition: TFilterCondition);
begin
  if AnFilterCondition <> nil then
    FFilterData.ConditionList.Conditions[AnIndex].Assign(AnFilterCondition);
end;

function TgsSQLFilter.GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
begin
  Result := FFilterData.OrderByList.OrdersBy[AnIndex];
end;

procedure TgsSQLFilter.SetOrderBy(const AnIndex: Integer; const AnFilterOrderBy: TFilterOrderBy);
begin
  if AnFilterOrderBy <> nil then
    FFilterData.OrderByList.OrdersBy[AnIndex].Assign(AnFilterOrderBy);
end;

function TgsSQLFilter.CreateSQL: Boolean;
begin
  Result := CreateSQLText(FFilterData);
end;

// Функция создающая SQL
function TgsSQLFilter.CreateSQLText(AFilterData: TFilterData): Boolean;
const
  PrefixTbl = ' tbl';
  Sand = ' AND ';
  Sor = ' OR  ';

var
  SelectStr, FromStr, WhereStr, OrderStr, PrefixList: TStrings;
  I: Integer;
  TblN: Integer;
  S, UserSQLText: String;
  IsUserQuery, EnterResult: Boolean;

  // Возвращает префикс таблицы по ее наименованию
  // при этом таблица сначало ищется
  function FindTable(const TableName: String; const FlagAll: Boolean): String;
  begin
    // Поиск существующей таблицы
    Result := PrefixList.Values[TableName];
    if FlagAll and (Result = '') then
      Result := FTableList.Values[TableName];
    // Если не найдено, добавляет новую
    if (Result = '') then
    begin
      Result := PrefixTbl + IntToStr(TblN);
      FromStr.Add(', ' + TableName + ' ' + Result);
      Result := Result + '.';
      PrefixList.Add(TableName + '=' + Result);
      Inc(TblN);
    end;
  end;

  function GetNextPrefix: String;
  begin
    Result := PrefixTbl + IntToStr(TblN);
    Inc(TblN);
  end;

  // Возвращает префикс таблицы по ее наименованию
  // Причем добавляется таблица
  function AddTable(const TableName: String): String;
  begin
    Result := PrefixTbl + IntToStr(TblN);
    FromStr.Add(', ' + TableName + ' ' + Result);
    Result := Result + '.';
    PrefixList.Add(TableName + '=' + Result);
    Inc(TblN);
  end;

  function FindTableAll(const TableName: String): String;
  begin
    Result := FindTable(TableName, True);
  end;

  function FindTableOut(const TableName: String): String;
  begin
    Result := FindTable(TableName, False);
  end;

  function ReplaceOldSign(const AnSourceStr, AnInsStr: String): String;
  begin
    Result := Copy(AnSourceStr, 1, Length(AnSourceStr) - 5) + AnInsStr;
  end;

  // Создает текст запроса для условия
  function AddSQLCondition(AnConditionData: TFilterCondition; AnPrefixName: String;
   const AnUnknownSet, AnMergeCondition: Boolean): Boolean;
  var
    J: Integer;
    CurN, NetN: String;
    FieldName: String;
    FieldType: Integer;
    FValue1, FValue2, Sign1, Sign2, SimpleField, FScriptSign: String;
    MergeSign: String[10];
    VarToPnt: Integer;

    procedure DoActuates(const AnConfluenceSign: String);
    begin
      case FieldType of
        GD_DT_REF_SET_ELEMENT, GD_DT_ATTR_SET_ELEMENT:
          // Добавляем условия
          WhereStr.Add('(' + AnPrefixName + FieldName + AnConfluenceSign + S + ')' + MergeSign);
        GD_DT_REF_SET, GD_DT_CHILD_SET:
        begin
          // Создаем префикс таблицы
          NetN := AddTable(AnConditionData.FieldData.LinkTable);
          // Добавляем условия
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + NetN
           + AnConditionData.FieldData.LinkSourceField + Sand);
          WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + AnConfluenceSign
           + S + ')' + MergeSign);
        end;
        GD_DT_ATTR_SET:
        begin
          // Создаем префикс таблицы
          NetN := AddTable('GD_ATTRVALUE');
          // Добавляем условия
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + NetN + 'id' + Sand);
          WhereStr.Add(NetN + 'attrrefkey = '
           + IntToStr(AnConditionData.FieldData.AttrRefKey) + Sand);
          WhereStr.Add(NetN + 'attrsetkey ' + AnConfluenceSign + S + ')' + MergeSign);
        end;
      end;
    end;

    procedure DoIncludes;
    var
      L: Integer;
    begin
      case FieldType of
        GD_DT_REF_SET, GD_DT_CHILD_SET:
        begin
        // Для каждого включенного элемента множества создаем новую связующую
        // таблицу. Поэтому не используем FindTable
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Add('(');
          for L := 0 to AnConditionData.ValueList.Count - 1 do
          begin
            // Создаем префикс таблицы
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // Добавляем условия
            WhereStr.Add(AnPrefixName + FieldName + ' = '
             + NetN + AnConditionData.FieldData.LinkSourceField + Sand);
            WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' = '
             + IntToStr(Integer(AnConditionData.ValueList.Objects[L])) + Sand);
          end;
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Strings[WhereStr.Count - 1] :=
             ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
        end;

        GD_DT_ATTR_SET:
        begin
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Add('(');
          for L := 0 to AnConditionData.ValueList.Count - 1 do
          begin
            // Создаем префикс таблицы
            NetN := AddTable('GD_ATTRVALUE');
            // Добавляем условия
            WhereStr.Add(AnPrefixName + FieldName + ' = ' + NetN + 'id' + Sand);
            WhereStr.Add(NetN + 'attrrefkey = '
             + IntToStr(AnConditionData.FieldData.AttrRefKey) + Sand);
            WhereStr.Add(NetN + 'attrsetkey = '
             + IntToStr(Integer(AnConditionData.ValueList.Objects[L])) + Sand);
          end;
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Strings[WhereStr.Count - 1] :=
             ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
        end;
      end;
    end;
  begin
    if AnMergeCondition then
      MergeSign := Sand
    else
      MergeSign := Sor;

    // Проверка является ли тип ''неопределенным множеством''
    if (AnConditionData.FieldData.FieldType = GD_DT_UNKNOWN_SET) and AnUnknownSet then
    begin
      //CurN := FindTableAll(AnConditionData.FieldData.LinkTable);
      CurN := AddTable(AnConditionData.FieldData.LinkTable);
      WhereStr.Add('(' + AnConditionData.FieldData.TableAlias + AnConditionData.FieldData.FieldName + ' = '
       + CurN + AnConditionData.FieldData.LinkSourceField + Sand);
      AddSQLCondition(AnConditionData, CurN, False, AnMergeCondition);
      WhereStr.Strings[WhereStr.Count - 1] :=
       ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
      Result := True;

      Exit;
    end;

    // Это тоже сделано для поддержания типа ''неопределенное множество''
    {gs} // Можно удалять условие
    if AnUnknownSet then
    begin
      FieldName := AnConditionData.FieldData.FieldName;
      FieldType := AnConditionData.FieldData.FieldType;
    end else
    begin
      FieldName := AnConditionData.FieldData.LinkTargetField;
      FieldType := AnConditionData.FieldData.LinkTargetFieldType;
    end;

    case AnConditionData.ConditionType of
    GD_FC_SCRIPT:
      begin
        if FilterScript = nil then
          raise Exception.Create('Компонент FilterScript не создан.');
        FValue1 := FilterScript.GetScriptResult(AnConditionData.Value1, AnConditionData.Value2, FScriptSign);
        FValue2 := '';
      end;
    GD_FC_ENTER_PARAM:
      case FieldType of
        GD_DT_REF_SET_ELEMENT, GD_DT_REF_SET, GD_DT_CHILD_SET,
        GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:;
      else
        FValue1 := AnsiUpperCase(TCrackerFilterCondition(AnConditionData).FTempVariant);
        FValue2 := '';
        FScriptSign := AnConditionData.Value2;
        // Замена LIKE на CONTAINING
        if (UpperCase(FScriptSign) = 'LIKE') then
          FScriptSign := 'CONTAINING';
        if (UpperCase(FScriptSign) = 'NOT LIKE') then
          FScriptSign := 'NOT CONTAINING';
      end;
    else
      FValue1 := AnConditionData.Value1;
      FValue2 := AnConditionData.Value2;
    end;
    // В зависимости от типа данных подготавливаем значения
    // Это сделано чтобы как-то объеденить обработку
    case FieldType of
      GD_DT_DIGITAL, GD_DT_BOOLEAN:
      begin
        // Просто присваиваем
        if FValue1 > '' then
          FValue1 := FValue1;
        if FValue2 > '' then
          FValue2 := FValue2;
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_CHAR:
      begin
        // Кавычки добавляем
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        // Регистр устанавливаем
        SimpleField := 'UPPER(' + AnPrefixName + FieldName + ')';
      end;
      GD_DT_BLOB_TEXT:
      begin
        // Кавычки добавляем
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_DATE:
      begin
        // Переводим в строку с кавычками
        if (AnConditionData.ConditionType <> GD_FC_LAST_N_DAYS)
         and (AnConditionData.ConditionType <> GD_FC_TODAY) then
        begin
          if FValue1 > '' then
            FValue1 := '''' + IBDateTimeToStr(StrToDateTime(FValue1)) + '''';
          if FValue2 > '' then
            FValue2 := '''' + IBDateTimeToStr(StrToDateTime(FValue2)) + '''';
          SimpleField := AnPrefixName + FieldName;
        end;
      end;
      GD_DT_TIME:
      begin
        // Переводим в строку с кавычками
        if FValue1 > '' then
          FValue1 := '''' + IBTimeToStr(StrToTime(FValue1)) + '''';
        if FValue2 > '' then
          FValue2 := '''' + IBTimeToStr(StrToTime(FValue2)) + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
    end;

    // Непосредственная обработка условия
    case AnConditionData.ConditionType of
      GD_FC_SCRIPT:
        case FieldType of
          GD_DT_REF_SET_ELEMENT,
          GD_DT_REF_SET, GD_DT_CHILD_SET:
          begin
            S := '(' + FValue1 + ')';
            DoActuates(FScriptSign);
          end;
          GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
            raise Exception.Create('GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT not supported yet.');
        else
          WhereStr.Add('(' + SimpleField + FScriptSign + FValue1 + ')' + MergeSign);
        end;

      GD_FC_ENTER_PARAM:
        case FieldType of
          GD_DT_REF_SET_ELEMENT,
          GD_DT_REF_SET, GD_DT_CHILD_SET:
          begin
            if not VarIsArray(TCrackerFilterCondition(AnConditionData).FTempVariant) or
             ((VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) -
             VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1)) < 0) then
            begin
              Result := True;
              Exit;
            end;

            if (AnsiUpperCase(AnConditionData.Value2) = GD_FC2_INCLUDE_ALIAS) then
            begin
              AnConditionData.ValueList.Clear;
              for J := VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) to
               VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) do
              begin
                VarToPnt := VarAsType(TCrackerFilterCondition(AnConditionData).FTempVariant[J], varInteger);
                AnConditionData.ValueList.AddObject('', Pointer(VarToPnt));
              end;
              DoIncludes;
            end else
            begin
              S := '(';
              for J := VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) to
               VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) do
                S := S + VarAsType(TCrackerFilterCondition(AnConditionData).FTempVariant[J], varString) + ',';
              S[Length(S)] := ')';
              DoActuates(' ' + AnConditionData.Value2 + ' ');
            end;
          end;
          GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
            raise Exception.Create('GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT not supported yet.');
        else
          WhereStr.Add('(' + SimpleField + FScriptSign + FValue1 + ')' + MergeSign);
        end;

      // Вся общая обработка
      GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_GREATER_OR_EQUAL_TO,
      GD_FC_LESS_THAN, GD_FC_LESS_OR_EQUAL_TO, GD_FC_NOT_EQUAL_TO, {GD_FC_CONTAINS,}
      GD_FC_DOESNT_CONTAIN:
      begin
        case AnConditionData.ConditionType of
          GD_FC_EQUAL_TO:
            Sign1 := ' = ';
          GD_FC_GREATER_THAN:
            Sign1 := ' > ';
          GD_FC_GREATER_OR_EQUAL_TO:
            Sign1 := ' >= ';
          GD_FC_LESS_THAN:
            Sign1 := ' < ';
          GD_FC_LESS_OR_EQUAL_TO:
            Sign1 := ' <= ';
          GD_FC_NOT_EQUAL_TO:
            Sign1 := ' <> ';
          {GD_FC_CONTAINS:
            Sign1 := ' CONTAINING ';}
          GD_FC_DOESNT_CONTAIN:
            Sign1 := ' NOT CONTAINING ';
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + ')' + MergeSign);
      end;
      // Условие между
      GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT:
      begin
        case AnConditionData.ConditionType of
          GD_FC_BETWEEN:
          begin
            Sign1 := ' >= ';
            Sign2 := ' <= ';
          end;
          GD_FC_BETWEEN_LIMIT:
          begin
            Sign1 := ' > ';
            Sign2 := ' < ';
          end;
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + Sand
         + SimpleField + Sign2 + FValue2 + ')' + MergeSign);
      end;
      // Условие вне
      GD_FC_OUT, GD_FC_OUT_LIMIT:
      begin
        case AnConditionData.ConditionType of
          GD_FC_OUT:
          begin
            Sign1 := ' <= ';
            Sign2 := ' >= ';
          end;
          GD_FC_OUT_LIMIT:
          begin
            Sign1 := ' < ';
            Sign2 := ' > ';
          end;
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + Sor
         + SimpleField + Sign2 + FValue2 + ')' + MergeSign);
      end;

      // Условие пользователя добавляем как есть
      GD_FC_QUERY_WHERE:
        WhereStr.Add('(' + AnConditionData.Value1 + ')' + MergeSign);
      // Существует
      GD_FC_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('NOT EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add('(' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);

      // Не существует
      GD_FC_NOT_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add(' NOT (' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);
      // Заканчивается на
      GD_FC_ENDS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName + ') LIKE ''%'
         + AnsiUpperCase(AnConditionData.Value1) + ''')' + MergeSign);
      // Содержит
      GD_FC_CONTAINS:
        if FieldType = GD_DT_BLOB_TEXT then
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnConditionData.Value1 + '%'')' + MergeSign)
        else
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // Начинается с
      GD_FC_BEGINS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName
         + ') LIKE ''' +  AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // За сегодня
      GD_FC_TODAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + IBDateToStr(Trunc(Now)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // За выбранный день
      GD_FC_SELDAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + AnConditionData.Value1 + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(StrToDate(AnConditionData.Value1) + 1) + ''')' + MergeSign);
        end;
      // За последние N дней
      GD_FC_LAST_N_DAYS:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= '''
           + IBDateToStr(Trunc(Now) - StrToInt(AnConditionData.Value1)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // Истина
      GD_FC_TRUE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 1)' + MergeSign);
      // Ложь
      GD_FC_FALSE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 0)' + MergeSign);

      // Включает
      GD_FC_INCLUDES:
        DoIncludes;

      // Дополнительная фильтрация
      GD_FC_COMPLEXFIELD:
        if FieldType = GD_DT_REF_SET then
        begin
          CurN := AddTable(AnConditionData.FieldData.LinkTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;

      // Простая фильтрация
      GD_FC_CUSTOM_FILTER:
      case FieldType of
      // Фильтрация, если элемент множества
        GD_DT_REF_SET_ELEMENT:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.RefTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.RefField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;

      // Фильтрация, если множество
        GD_DT_REF_SET:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.RefTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          //NetN := FindTableAll(AnConditionData.FieldData.LinkTable);
          NetN := AddTable(AnConditionData.FieldData.LinkTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + NetN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' = '
           + CurN + AnConditionData.FieldData.RefField + Sand);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;
        // Фильтрация обратного множества
        GD_DT_CHILD_SET:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.LinkTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;
      end;

      // Не включает ветвь
      GD_FC_NOT_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // Создаем префикс таблицы
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // Добавляем условия
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             CurN + '.' + AnConditionData.FieldData.RefField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.RefTable + ' ' +
             NetN + ', ' + AnConditionData.FieldData.RefTable + ' ' + CurN + ' WHERE ');
            NetN := NetN + '.';
            CurN := CurN + '.';
            WhereStr.Add(NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder +
             '))' + MergeSign);
          end;
          GD_DT_REF_SET:
          begin
            // Создаем префикс таблицы
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            FValue1 := GetNextPrefix;
            // Добавляем условия
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             FValue1 + '.' + AnConditionData.FieldData.LinkSourceField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.RefTable + NetN + ', ' +
             AnConditionData.FieldData.RefTable + CurN + ', ' +
             AnConditionData.FieldData.LinkTable + FValue1);

            NetN := NetN + '.';
            CurN := CurN + '.';
            FValue1 := FValue1 + '.';

            WhereStr.Add(' WHERE ' + NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            // Добавляем условия
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + FValue1 + AnConditionData.FieldData.LinkTargetField + '))' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // Создаем префикс таблицы
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // Добавляем условия
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             CurN + '.' + AnConditionData.FieldData.LinkSourceField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.LinkTable + NetN + ', ' +
             AnConditionData.FieldData.LinkTable + CurN + ' WHERE ');
            NetN := NetN + '.';
            CurN := CurN + '.';
            WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + '))' + MergeSign);
          end;
          GD_DT_ATTR_SET_ELEMENT, GD_DT_ATTR_SET:
            Assert(False, 'Not supported');
        end;
      end;

      // Одна ветвь из
      GD_FC_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // Создаем префикс таблицы
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // Добавляем условия
            WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + CurN +
             AnConditionData.FieldData.RefField + Sand);
            WhereStr.Add(NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder +
             ')' + MergeSign);
          end;
          GD_DT_REF_SET:
          begin
            // Создаем префикс таблицы
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // Добавляем условия
            WhereStr.Add('(' + NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            // Создаем префикс таблицы
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // Добавляем условия
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + NetN + AnConditionData.FieldData.LinkTargetField + Sand);
            WhereStr.Add(AnPrefixName + FieldName + ' = '
             + NetN + AnConditionData.FieldData.LinkSourceField + ')' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // Создаем префикс таблицы
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            CurN := AddTable(AnConditionData.FieldData.LinkTable);
            // Добавляем условия
            WhereStr.Add('(' + NetN + AnConditionData.FieldData.LinkTargetField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            WhereStr.Add(CurN + AnConditionData.FieldData.LinkSourceField + ' = '
             + AnPrefixName + FieldName + ')' + MergeSign);
          end;
          GD_DT_ATTR_SET_ELEMENT, GD_DT_ATTR_SET:
            Assert(False, 'Not supported');
        end;
      end;

      // Не включает
      GD_FC_NOT_ACTUATES:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        DoActuates(' NOT IN ');
      end;

      // Один из
      GD_FC_ACTUATES:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        DoActuates(' IN ');
      end;
    end;
    Result := True;
  end;

  // Проверяет является ли условие запросом пользователя
  function CheckUserQuery(const AnConditionList: TFilterConditionList; out AnUserSQLText: String): Boolean;
  begin
    Result := (AnConditionList.Count = 1) and
     (AnConditionList.Conditions[0].FieldData.FieldType = GD_DT_FORMULA) and
     (AnConditionList.Conditions[0].ConditionType = GD_FC_QUERY_ALL);
    if Result then
      AnUserSQLText := AnConditionList.Conditions[0].Value1;
  end;

  // Находит индекс основной таблицы в начальном тексте запроса
  // Необходима для отображения полей пользователя типа элемент множества,
  // т.к. используется LEFT JOIN
(*  function FindMainTable(PerfixName: String): Integer;
  const
    LimitChar = [' ', #13, #10, ','];
  var
    J, SpPos: Integer;
    Flag: Boolean;
  begin
    try
      Flag := False;
      Result := -1;
      S := Trim(MainName);
      for J := 0 to TempFromText.Count - 1 do
      begin
        Flag := True;
        SpPos := Pos(S, TempFromText.Strings[J]);
        if SpPos > 0 then
        begin
          if SpPos > 1 then
            if not (TempFromText.Strings[J][SpPos - 1] in LimitChar) then
              Flag := False;
          if SpPos < Length(TempFromText.Strings[J]) - Length(S) + 1 then
            if not (TempFromText.Strings[J][SpPos + Length(S)] in LimitChar) then
              Flag := False
            else
            begin
              TempFromText.Insert(J, TempFromText.Strings[J]);
              TempFromText.Strings[J] := Copy(TempFromText.Strings[J], 1, SpPos + Length(S) - 1);
              TempFromText.Strings[J + 1] := Copy(TempFromText.Strings[J + 1],
               SpPos + Length(S), Length(TempFromText.Strings[J + 1]));
            end;
          if Flag then
          begin
            Result := J;
            Break;
          end;
        end;
      end;
      if Flag then
      begin
        if Result = TempFromText.Count - 1 then
          TempFromText.Add('');
        if Result = TempFromText.Count then
          Result := -1
        else
          Inc(Result)
      end else
        Result := -1
    except
      Result := -1;
      ShowMessage('При возникновении данной ошибки следует обращаться к разработчику.'
       + 'Слишком много нюансов чтобы все протестировать.'); {gs}
    end;
  end; (**)

  function ParamExist(AnConditionList: TFilterConditionList): Boolean;
  var
    CondCount: Integer;
  begin
    Result := False;
    for CondCount := 0 to AnConditionList.Count - 1 do
    begin
      case AnConditionList.Conditions[CondCount].ConditionType of
        GD_FC_ENTER_PARAM:
          Result := True;
        GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
          Result := ParamExist(AnConditionList.Conditions[CondCount].SubFilter);
      end;
      if Result then
        Break;
    end;
  end;

  // Функция добавляет DISTINCT в текст запроса
  function AddDistinct(const AnSQLText: String): String;
  const
    cDST = ' DISTINCT ';
    cSLT = 'SELECT';
  var
    I: Integer;
  begin
    Result := AnSQLText;
    I := Pos(cSLT, AnsiUpperCase(AnSQLText));
    if I > 0 then
      Insert(cDST, Result, I + Length(cSLT));
  end;
begin
  Result := False;
  // Создаем необходимые списки
  SelectStr := TStringList.Create;
  FromStr := TStringList.Create;
  WhereStr := TStringList.Create;
  OrderStr := TStringList.Create;
  PrefixList := TStringList.Create;
  try
    // Начальные установки
    TblN := 0;
    SelectStr.Clear;
    FromStr.Clear;
    WhereStr.Clear;
    PrefixList.Clear;

(*    // Определяем индекс основной таблицы
   // MainIndex := FindMainTable;
    // Если необходимо создаем начальный текст запроса
   { if Trim(FFromText.Text) = '' then
    begin
      FromStr.Add('FROM ' + FFilterData.TableName + MainName);
      FTableList.Add(FFilterData.TableName);
//      FPrefixList.Add(MainName);
    end;}
    Inc(TblN);
    // Если необходимо создаем начальный текст полей для отображения
    {if Trim(FSelectText.Text) = '' then
      SelectStr.Add('SELECT * ');}
    (*else
      // Если необходимо добавляем атрибуты для отображения
      if FViewAttr then
        for I := 0 to UserFields.Count - 1 do
          case Integer(UserFields.Objects[I]) of
          // Обычное поле
          GD_DT_CHAR, GD_DT_DATE, GD_DT_NUMERIC:
            SelectStr.Add(', ' + MainName + '.' + UserFields.Strings[I]);
          // Элемент множества
          GD_DT_ELEMENT_OF_SET:
            if MainIndex > -1 then
            begin
              S := AnPrefixName + IntToStr(TblN);
              Inc(TblN);
              TempFromText.Insert(MainIndex, ' LEFT JOIN gd_attrset ' + S + ' ON '
               + MainName + '.' + UserFields.Strings[I] + ' = ' + S + '.id');
              SelectStr.Add(', ' + S + '.name ' + UserFields.Strings[I]);
            end else {gs}
              ShowMessage('Не найден префикс основной таблицы.');
          end;
      *)
    IsUserQuery := CheckUserQuery(FFilterData.ConditionList, UserSQLText);

    if not IsUserQuery then
    begin

      // Проверяем наличие хотя бы одного параметра
      if ParamExist(FFilterData.ConditionList) then
        if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
        begin
          QueryParamsForConditions(FComponentKey, FCurrentFilter, FFilterData.ConditionList, EnterResult);
          // При вводе параметром при отмене запрос остается старым!!!
          if not EnterResult then
            Exit;
        end else
          raise Exception.Create('Компонент FilterDlg не создан');

      // Создаем список условий фильтрации
      for I := 0 to FFilterData.ConditionList.Count - 1 do
      begin
        AddSQLCondition(FFilterData.ConditionList.Conditions[I],
         FFilterData.ConditionList.Conditions[I].FieldData.TableAlias, True,
         FFilterData.ConditionList.IsAndCondition);
      end;

      // Создаем список условий сортировки
      if FFilterData.OrderByList.Count > 0 then
      begin
        // Это сделано для того, чтобы сортировка по умочанию затиралась
//        if Trim(FOrderText.Text) = '' then
        OrderStr.Add('ORDER BY');
//        else
//          OrderStr.Add(', ');
        for I := 0 to FFilterData.OrderByList.Count - 1 do
        begin
          if I > 0 then
            OrderStr.Add(', ');
          if FFilterData.OrderByList.OrdersBy[I].IsAscending then
            S := ' ASC'
          else
            S := ' DESC';
          OrderStr.Add(FFilterData.OrderByList.OrdersBy[I].TableAlias
           + FFilterData.OrderByList.OrdersBy[I].FieldName + S);
        end;
      end;

      // Необходимые вставки для коректного слива начального запроса с нашими условиями
      if (FFilterData.ConditionList.Count > 0) and (WhereStr.Count > 0) then
      begin
        // Если необходимо создаем начальное условие
        if Trim(FWhereText.Text) = '' then
          WhereStr.Insert(0, 'WHERE (')
        else
          WhereStr.Insert(0, Sand + '(');
        // Удаляем последнее AND
        WhereStr.Strings[WhereStr.Count - 1] :=
         ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')');
      end;
    end;

    // Создаем текст запроса
    FQueryText.Clear;
    if IsUserQuery then
    begin
      FQueryText.Text := FQueryAlias;
      FQueryText.Add(UserSQLText);
    end else
    begin
      FQueryText.Add(FQueryAlias);
      FQueryText.AddStrings(FSelectText);
      FQueryText.AddStrings(SelectStr);
      FQueryText.AddStrings(FFromText);
      FQueryText.AddStrings(FromStr);
      FQueryText.AddStrings(FWhereText);
      FQueryText.AddStrings(WhereStr);
      FQueryText.AddStrings(FOtherText);
//      FQueryText.AddStrings(FOrderText);
      FQueryText.AddStrings(OrderStr);
      if FFilterData.ConditionList.IsDistinct then
        FQueryText.Text := AddDistinct(FQueryText.Text);
    end;
    Result := True;
  finally
    // Освобождаем используемые списки
    SelectStr.Free;
    FromStr.Free;
    WhereStr.Free;
    OrderStr.Free;

    PrefixList.Free;
  end; (**)
end;

procedure TgsSQLFilter.SetQueryText(const AnSQLText: String);
begin
  FSelectText.Text := ExtractSQLSelect(AnSQLText);
  FFromText.Text := ExtractSQLFrom(AnSQLText);
  FWhereText.Text := ExtractSQLWhere(AnSQLText);
  FOtherText.Text := ExtractSQLOther(AnSQLText);
  FOrderText.Text := ExtractSQLOrderBy(AnSQLText);
end;

function TgsSQLFilter.AddCondition(AFilterCondition: TFilterCondition): Integer;
begin
  if FFilterData.ConditionList.CheckCondition(AFilterCondition) then
    Result := FFilterData.ConditionList.AddCondition(AFilterCondition)
  else
    Result := -1;
end;

procedure TgsSQLFilter.DeleteCondition(const AnIndex: Integer);
begin
  Assert(((AnIndex >= 0) and (AnIndex < FFilterData.ConditionList.Count)), 'Индекс вне диапазона');
  FFilterData.ConditionList.Delete(AnIndex);
end;

procedure TgsSQLFilter.ClearConditions;
begin
  FFilterData.ConditionList.Clear;
end;

function TgsSQLFilter.AddOrderBy(AnOrderBy: TFilterOrderBy): Integer;
begin
  Result := FFilterData.OrderByList.AddOrderBy(AnOrderBy);
end;

procedure TgsSQLFilter.DeleteOrderBy(const AnIndex: Integer);
begin
  Assert(((AnIndex >= 0) and (AnIndex < FFilterData.OrderByList.Count)), 'Индекс вне диапазона');
  FFilterData.OrderByList.Delete(AnIndex);
end;

procedure TgsSQLFilter.ClearOrdersBy;
begin
  FFilterData.OrderByList.Clear;
end;

procedure TgsSQLFilter.ReadFromStream(S: TStream);
begin
  FFilterData.ReadFromStream(S);
end;

procedure TgsSQLFilter.WriteToStream(S: TStream);
begin
  FFilterData.WriteToStream(S);
end;

{TgsQueryFilter}

constructor TgsQueryFilter.Create(AnOwner: TComponent);
var
  Reg: TRegistry;
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    FIsSQLChanging := False;
    FIsFirstOpen := False;
    FIsCompKey := False;
    FIsLastSave := False;
    FOwnerName := GetOwnerName;// Наименование создателя
    FMessageDialog := TmsgShowMessage.Create(Self);     // Создаем д.о. изменения условий
    FActionList := TActionList.Create(Self);
    FRecordCount := -1;

    // Считываем надо ли показывать предупреждение
    FShowBeforeFilter := False;
    try
      Reg := TRegistry.Create(KEY_READ);
      try
        Reg.RootKey := ClientRootRegistryKey;
        if Reg.OpenKeyReadOnly('Software\Golden Software\' + GetApplicationName
         + '\FilterOptions\' + FOwnerName + '\') then
          if Reg.ValueExists(Name) then
            FShowBeforeFilter := Reg.ReadBool(Name);
      finally
        Reg.CloseKey;
        Reg.Free;
      end;
    except
      // Don't show this mistake
    end;

    CreateActions;
    if (Owner <> nil) and (Owner is TForm) then
    begin
      FOldShortCut := (Owner as TForm).OnShortCut;
      (Owner as TForm).OnShortCut := SelfOnShortCut;
    end;
  end;
end;

destructor TgsQueryFilter.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    // Сохраняем последний фильтр
    SaveLastFilter;
    // Освобождаем пользователя
    FMessageDialog.Free;
    FActionList.Free;
  end;

  FPopupMenu.Free;

  inherited Destroy;
end;

procedure TgsQueryFilter.SelfOnShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  Handled := Handled or ((FPopupMenu <> nil) and (FPopupMenu is TPopupMenu)
    and FActionList.IsShortCut(Msg));

  if Assigned(FOldShortCut) then
    FOldShortCut(Msg, Handled);
end;

procedure TgsQueryFilter.DoOnCreateFilter(Sender: TObject);
var
  I: Integer;
begin
  // Вызываем функцию создания фильтра
  if AddFilter(I) then
  begin
    // Если нажата кнопка "ОК"
    if I <> 0 then
    begin
      // Сохраняем текущий
      SaveFilter;

      // Вызываем созданный
      LoadFilter(I);

      // Фильтруем
      FilterQuery;
    end;
    
    // Создаем меню
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnEditFilter(Sender: TObject);
var
  I: Integer;
begin
  // Вызываем редактирование
  if EditFilter(I) then
  begin
    // Если нажата "ОК"
    if I <> 0 then
    begin
      if I = FCurrentFilter then
        FLastExecutionTime := 0;
      SaveFilter;
      LoadFilter(I);
      FilterQuery;
    end;
    // Создаем меню
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnDeleteFilter(Sender: TObject);
begin
  // Вызываем удаление
  if DeleteFilter then
  begin
    RevertQuery;
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnWriteToFile(Sender: TObject);
var
  SD: TSaveDialog;
  St: TMemoryStream;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.DefaultExt := 'flt';
    SD.Filter := 'Фильтры|*.flt';
    SD.Options := SD.Options + [ofOverwritePrompt];
    if SD.Execute then
    begin
      St := TMemoryStream.Create;
      try
        FFilterData.WriteToStream(St);
        St.SaveToFile(SD.FileName);
      finally
        St.Free;
      end;
    end;
  finally
    SD.Free;
  end;
end;

procedure TgsQueryFilter.DoOnReadFromFile(Sender: TObject);
var
  LD: TOpenDialog;
  St: TMemoryStream;
begin
  LD := TOpenDialog.Create(Self);
  try
    LD.Filter := 'Фильтры|*.flt';
    if LD.Execute and ((FCurrentFilter = 0) or (MessageBox(0, 'Вы хотите изменить текущий фильтр?',
     'Внимание', MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL) = IDOK)) then
    begin
      St := TMemoryStream.Create;
      try
        St.LoadFromFile(LD.FileName);
        St.Position := 0;
        FFilterData.ReadFromStream(St);
        FLastExecutionTime := 0;
        FDeltaReadCount := 0;
        FilterQuery;
      finally
        St.Free;
      end;
    end;
  finally
    LD.Free;
  end;
end;

procedure TgsQueryFilter.DoOnRecordCount(Sender: TObject);
begin
  MessageBox(0, PChar('Количество записей в текущей выборке: ' + IntToStr(RecordCount)),
   'Информация', MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

// Снимаем условия фильтрации
procedure TgsQueryFilter.DoOnFilterBack(Sender: TObject);
var
  I: Integer;
begin
  // Делаем недоступными необходимые элементы меню
  SetEnabled(False);

  // Сохраняем параметры текущего фильтра
  SaveFilter;

  // Снимаем свойство Checked
  if FPopupMenu <> nil then
  begin
    for I := 0 to FPopupMenu.Items.Count - 1 do
      FPopupMenu.Items[I].Checked := False
  end;

  RevertQuery;
end;

procedure TgsQueryFilter.DoOnSelectFilter(Sender: TObject);
begin
  // Делаем доступными элементы
  SetEnabled(True);
  // Если выбран текущий, то выходим
  if (Sender as TMenuItem).Tag = FCurrentFilter then
    Exit;
  // Сохраняем текущий
  SaveFilter;
  // Отмечаем
  (Sender as TMenuItem).Checked := True;
  // Загружаем
  if LoadFilter((Sender as TMenuItem).Tag) then
    FilterQuery
  else
    CreatePopupMenu;
end;

procedure TgsQueryFilter.DoOnViewFilterList(Sender: TObject);
var
  F: TdlgFilterList;
  I: Integer;
  Flag: Boolean;  // Были ли изменения
begin
  // Создаем окно
  F := TdlgFilterList.Create(Self);
  try
    // Стартуем транзакцию
    if not Transaction.InTransaction then
      Transaction.StartTransaction;

    // Необходимые установеи
    F.ibsqlFilter.Database := Database;
    F.ibsqlFilter.Transaction := Transaction;

    // Получаем ключ выбранного фильтра
    I := F.ViewFilterList(FComponentKey, Flag, FSelectText.Text + FFromText.Text +
     FWhereText.Text + FOtherText.Text + FOrderText.Text);

    // Остальные действия аналогичны
    if I <> 0 then
    begin
      SaveFilter;
      LoadFilter(I);
      FilterQuery;
    end;

    if Flag then
      CreatePopupMenu;
  finally
    // Завершаем транзакцию
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    F.Free;
  end;
end;

procedure TgsQueryFilter.FilterQuery;
var
  Flag: Boolean;
  StartTime: TTime;
  ParamList: TfltStringList;
  I: Integer;
  LastTrState: Boolean;
begin
  // Запоминаем состояние
  Flag := FIBDataSet.Active;
  // Показываем предупреждение
  if Flag then
    ShowWarning;
  FIsSQLChanging := True;
  // Создаем текст
  if CreateSQLText(FFilterData) then
  begin
    ParamList := TfltStringList.Create;
    try
      if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
            ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
             TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

      // Закрываем запрос и присваиваем текст
      if FIBDataSet.Active then
        FIBDataSet.Close;
      if IsIBQuery then
        TIBQuery(FIBDataSet).SQL.Assign(FQueryText)
      else
        TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Assign(FQueryText);
      // Сбрасываем количество записей
      FRecordCount := -1;
      // Увеличиваем количество обращений
      Inc(FDeltaReadCount);
      // Если были присвоены параметры то присваиваем их
      for I := 0 to ParamList.Count - 1 do
        try
          if TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]) <> nil then
            TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsString := ParamList.ValuesOfIndex[I];
        except
        end;

      LastTrState := False;
      try
        try
          if Assigned(FIBDataSet.Database) and FIBDataSet.Database.Connected and
            Assigned(FIBDataSet.Transaction) and (FIBDataSet.Transaction.DatabaseCount > 0) then
          begin
            // Сохраняем состояние транзакции. Если она существует и закрыта, то Истина.
            LastTrState := Assigned(FIBDataSet.Transaction.DefaultDatabase) and not FIBDataSet.Transaction.InTransaction;
            TIBCustomDataSetCracker(FIBDataSet).InternalPrepare;
          end;
        except
          // Обработка ошибки
          on E: Exception do
          begin
            MessageBox(0, PChar('Произошла ошибка при выполнении запроса.'#13#10
             + 'Запрос возвращен в исходное состояние.'#13#10
             + E.Message), 'Внимание', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
            // Возвращаемся к первоначальному запросу
            RevertQuery;
            CreatePopupMenu;
          end;
        end;
      finally
        // Если транзакция была закрыта и нам не надо открывать Query, то закрываем ее.
        if LastTrState and (not Flag) and FIBDataSet.Transaction.InTransaction then
          //FIBDataSet.Transaction.Commit;
          FIBDataSet.Transaction.CheckAutoStop; // если на транзакции висят другие датасеты
                                                // и хотябы один из них открыт
                                                // или программист принудительно не хочет
                                                // чтобы она закрывалась автоматом
                                                // то она не закроется
                                                // таково предназначение метода CheckAutoStop
                                                // в данном случае использовать надо его, а не
                                                // жесткий Комит
      end;

      // Если запрос был открыт то открываем его
      if Flag then
      try
        // Если время последнего выполнения было больше допустимого выводим окно
        if FLastExecutionTime > FMaxExecutionTime then
        begin
          FMessageDialog.Show;
          Application.ProcessMessages;
        end;
        try
          StartTime := Now;
          FIBDataSet.Open;
          FLastExecutionTime := Now - StartTime;
        finally
          FMessageDialog.Hide;
        end;

      except
        // Обработка ошибки
        on E: Exception do
        begin
          // EAbort специальный класс исключения
          // предназначен для того, чтобы внутренне
          // все работало как при исключении, но
          // пользователю ничего не выдавалось
          // если к нам пришел EAbort значит раньше
          // программист уже предпринял определенные
          // действия, например, проинформирвал пользователя
          // на родном языке и обяснил что ему делать
          // и больше ничего на экран выводить не надо.
          // просто молча сделать свое дело.
          if not (E is EAbort) then
            MessageBox(0, PChar('Произошла ошибка при выполнении запроса.'#13#10
             + 'Запрос возвращен в исходное состояние.'#13#10
             + E.Message), 'Внимание', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
          // Возвращаемся к первоначальному запросу
          RevertQuery;
          FIBDataSet.Open;
          CreatePopupMenu;
        end;
      end;
    finally
      ParamList.Free;
    end;
  end else
  begin
    if FIBDataSet.Active then
      FIBDataSet.Close;
    if Flag then
    begin
      RevertQuery;
      FIBDataSet.Open;
      CreatePopupMenu;
    end;
  end;
  FIsSQLChanging := False;
end;

// Создаем меню
procedure TgsQueryFilter.CreatePopupMenu;
begin
  if FPopupMenu = nil then
    FPopupMenu := TPopupMenu.Create(Self)
  else
    FPopupMenu.Items.Clear;

  MakePopupMenu(FPopupMenu);
end;

procedure TgsQueryFilter.SaveLastFilter;
var
  ibsqlLast: TIBSQL;
begin
  if (FBase = nil) or (Database = nil) or (not Database.Connected) or (Transaction = nil) then
    exit;

  if (not FIsFirstOpen) or FIsLastSave then
    exit;

  ibsqlLast := TIBSQL.Create(Self);
  try
    // Присваиваем необходимые значения
    ibsqlLast.Database := Database;
    ibsqlLast.Transaction := Transaction;
    
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
      
    // Вытягиваем ключ компоненты
    ExtractComponentKey;
    // Сохраняем текущий фильтр
    SaveFilter;
    // Удаляем последний фильтр для текущего пользователя и компоненты
    ibsqlLast.SQL.Text := 'DELETE FROM flt_lastfilter WHERE userkey '
     + GetISUserKey + ' AND componentkey = ' + IntToStr(FComponentKey);

{ TODO -oандрэй -cпамылка : зачем этот try except?? какая-то ошибка? }
    try
      ibsqlLast.ExecQuery;
      if FCurrentFilter <> 0 then
      begin
        // Сохраняем последний фильтр
        ibsqlLast.SQL.Text := 'INSERT INTO flt_lastfilter (userkey, componentkey, lastfilter, crc32, dbversion) '
         + 'VALUES(' + GetUserKey + ', ' + IntToStr(FComponentKey)
         + ', ' + IntToStr(FCurrentFilter) + ', ' + IntToStr(GetCRC) + ', ''' + GetDBVersion + ''')';
        ibsqlLast.ExecQuery;
      end;
    except
    end;
  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    // Устанавливаем флаг о сохранении последнего фильтра
    FIsLastSave := True;
    // Устанавливаем флаг о перврм открытии
    FIsFirstOpen := False;
    FreeAndNil(ibsqlLast);
  end;
end;

// Вызываем последний фильтр
procedure TgsQueryFilter.LoadLastFilter;
var
  ibsqlLast: TIBSQL;
begin
  if (Database = nil) or not Database.Connected or (Transaction = nil) then
    Exit;

  ibsqlLast := TIBSQL.Create(Self);
  try
    // Необходимые установки
    ibsqlLast.Database := Database;
    ibsqlLast.Transaction := Transaction;
    // Ключ компонента
    ExtractComponentKey;
    // Ищем значение фильтра
    ibsqlLast.SQL.Text := 'SELECT * FROM flt_lastfilter WHERE userkey '
     + GetISUserKey + ' AND componentkey = ' + IntToStr(FComponentKey);
    // Стартуем транзакцию
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
    ibsqlLast.ExecQuery;
    if not ibsqlLast.Eof then
      if {not ibsqlLast.FieldByName('crc32').IsNull and}
       CompareVersion(ibsqlLast.FieldByName('crc32').AsInteger,
        ibsqlLast.FieldByName('dbversion').AsString, True) then
      begin
        // Если найден, то загружаем
        LoadFilter(ibsqlLast.FieldByName('lastfilter').AsInteger);
        FilterQuery;
      end;
  finally
    // Закрываем транзакцию
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    FIsLastSave := False;
    ibsqlLast.Free;
  end;
end;

procedure TgsQueryFilter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FIBDataSet) then
    FIBDataSet := nil;
  if (Operation = opRemove) and (AComponent = FDataBase) then
    FDataBase := nil;
end;

procedure TgsQueryFilter.Loaded;
begin
  inherited;
  if (Owner <> nil) and (FOwnerName <> Owner.Name) then
    FOwnerName := GetOwnerName;
end;

// Получение версии БД
function TgsQueryFilter.GetDBVersion: String;
begin
  if IBLogin <> nil then
    Result := Trim(IBLogin.DBVersion)
  else
    Result := '';
end;

// Получаем CRC начального запроса
function TgsQueryFilter.GetCRC: Integer;
var
  TempS: String;
  //ArBt: TArrByte;
begin
  TempS := FSelectText.Text + FFromText.Text + FWhereText.Text + FOtherText.Text + FOrderText.Text;
  {SetLength(ArBt, Length(TempS) * SizeOf(Char));
  ArBt := Copy(TArrByte(TempS), 0, Length(TempS) * SizeOf(Char));}
  Result := Integer(Crc32_P(@TempS[1], Length(TempS), 0));
end;

// Сравниваем версии начальных запросов и БД
function TgsQueryFilter.CompareVersion(const OldCRC: Integer; const DBVersion: String; const Question: Boolean): Boolean;
var
  TempS: String;
  ArBt: TArrByte;
begin
  TempS := FSelectText.Text + FFromText.Text + FWhereText.Text + FOtherText.Text + FOrderText.Text;
  SetLength(ArBt, Length(TempS) * SizeOf(Char));
  ArBt := Copy(TArrByte(TempS), 0, Length(TempS) * SizeOf(Char));
  Result := ((CheckCrc32(ArBt, Length(ArBt), Cardinal(OldCRC)) = 0)
   and (DBVersion = GetDBVersion))
   or (
     MessageBox(0,
       'Версии программы или базы данных были изменены.'#13#10 +
       'Вы хотите загрузить последний фильтр?',
       'Внимание',
       MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
end;

// Извлекаем ключ компоненты
procedure TgsSQLFilter.ExtractComponentKey;
var
  ibsqlComp: TIBSQL;
  FltName: String[21];
begin
  if (Database = nil) or not Database.Connected or (Transaction = nil) then
    Exit;

  FltName := Copy(Name, 1, 20);
  // Если ключ считан то выходим
  if FIsCompKey then
    Exit;
  ibsqlComp := TIBSQL.Create(Self);
  try
    ibsqlComp.Database := Database;
    ibsqlComp.Transaction := Transaction;
    // Ищем компоненту с нашиму параметрами
    ibsqlComp.SQL.Text := 'SELECT id FROM flt_componentfilter WHERE formname = '''
     + FOwnerName + ''' AND filtername = ''' + FltName
     + ''' AND applicationname = ''' + GetApplicationName + '''';
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
    ibsqlComp.ExecQuery;
    if not ibsqlComp.Eof then
      // Если нашли присваиваем значение
      FComponentKey := ibsqlComp.Fields[0].AsInteger
    else
    begin
      // Если нет создаем новый
      try
        ibsqlComp.Close;
        ibsqlComp.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM rdb$database';
        ibsqlComp.ExecQuery;
        FComponentKey := ibsqlComp.Fields[0].AsInteger;
        ibsqlComp.Close;
        ibsqlComp.SQL.Text := 'INSERT INTO flt_componentfilter (id, formname, filtername, applicationname)'
         + ' VALUES(' + IntToStr(FComponentKey) + ',''' + FOwnerName + ''',''' + FltName
         + ''',''' + GetApplicationName + ''')';
        ibsqlComp.ExecQuery;
      except
      end;
    end;
  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    // Устанавливаем флаг, что ключ считан
    FIsCompKey := True;
    ibsqlComp.Free;
  end;
end;

// Получаем ключ пользователя
function TgsQueryFilter.GetUserKey: String;
begin
  if IBLogin <> nil then
    Result := IntToStr(IBLogin.UserKey)
  else
    Result := IntToStr(ADMIN_KEY); // ' NULL '
end;

function TgsQueryFilter.GetISUserKey: String;
begin
  if IBLogin <> nil then
    Result := ' = ' + IntToStr(IBLogin.UserKey)
  else
    Result := ' = ' + IntToStr(ADMIN_KEY); // ' IS NULL '
end;

// Наименование приложения
function TgsSQLFilter.GetApplicationName: String;
begin
  Result := Copy(UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), '')), 1, FIndexFieldLength);
end;

// Показываем предупреждение
procedure TgsQueryFilter.ShowWarning;
var
  F: TmsgBeforeFilter;
  Reg: TRegistry;
begin
  if not FShowBeforeFilter and ((FLastExecutionTime > FMaxExecutionTime)
   {or (FLastExecutionTime = 0)}) then
  begin
    F := TmsgBeforeFilter.Create(Self);
    try
      F.ShowModal;
      if F.cbVisible.Checked then
      try
        Reg := TRegistry.Create;
        try
          FShowBeforeFilter := True;
          Reg.RootKey := ClientRootRegistryKey;
          if Reg.OpenKey('Software\Golden Software\' + GetApplicationName
           + '\FilterOptions\' + FOwnerName + '\', True) then
            Reg.WriteBool(Name, FShowBeforeFilter);
        finally
          Reg.CloseKey;
          Reg.Free;
        end;
      except
        // Don't show this mistake
      end;
    finally
      F.Free;
    end;
  end;
end;

// Установка необходимых элементов AnEnabled
procedure TgsQueryFilter.SetEnabled(const AnEnabled: Boolean);
var
  I: Integer;
begin
  for I := 0 to FActionList.ActionCount - 1 do
    if FActionList.Actions[I].Tag = 1 then
      TAction(FActionList.Actions[I]).Enabled := AnEnabled;
end;

// Получаем количество записей в выборке
function TgsQueryFilter.GetRecordCount: Integer;
var
  ibsqlCount: TIBCustomDataSet;
  OldRecNo: Integer;
  I, J: Integer;
  FlagTr: Boolean;
  ParamList: TStringList;
begin
  // Если количество записей не определено
  if FRecordCount = -1 then
  begin
    if (FIBDataSet <> nil) and FIBDataSet.Active then
    begin
      // Сохраняем старое значение курсора
      OldRecNo := FIBDataSet.RecNo;
      FIBDataSet.DisableControls;
      // Присваиваем текущей записи количество считанных записей
      FIBDataSet.RecNo := FIBDataSet.RecordCount;
      // Пытаемся считать следующуу
      FIBDataSet.Next;
      // Если не удалось значит считаны все записи
      if FIBDataSet.Eof then
        FRecordCount := FIBDataSet.RecordCount;
      // Восстанавливаем значение курсора
      FIBDataSet.RecNo := OldRecNo;
      FIBDataSet.EnableControls;
    end;
    // Если количесто записей не нашли создаем свой запрос возвращающий количество
    if FRecordCount = -1 then
    begin
      if (FIBDataSet is TIBQuery) then
        ibsqlCount := TIBQuery.Create(Self)
      else
        ibsqlCount := TIBDataSet.Create(Self);
      FlagTr := True;

      ParamList := TStringList.Create;
      try
        // Стартуем транзакцию
        if FIBDataSet.Transaction <> nil then
        begin
          FlagTr := FIBDataSet.Transaction.InTransaction;
          if not FlagTr then
            FIBDataSet.Transaction.StartTransaction;
          ibsqlCount.Transaction := FIBDataSet.Transaction;
        end else
        begin
          if not Transaction.InTransaction then
            Transaction.StartTransaction;
          ibsqlCount.Transaction := Transaction;
        end;
        // Необходимые установки
        ibsqlCount.Database := Database;

        if (FIBDataSet <> nil) and (FIBDataSet.Owner <> nil) then
          for I := 0 to FIBDataSet.Owner.ComponentCount - 1 do
            if FIBDataSet.Owner.Components[I] is TboAccess then
              for J := 0 to (FIBDataSet.Owner.Components[I] as TboAccess).DataSetList.Count - 1 do
                if AnsiUpperCase(Trim((FIBDataSet.Owner.Components[I] as TboAccess).DataSetList.Strings[J])) =
                 AnsiUpperCase(FIBDataSet.Name) then
                begin
                  ibsqlCount.BeforeOpen := FIBDataSet.BeforeOpen;
                  Break;
                end;

        // Создаем запрос
        if (FIBDataSet is TIBQuery) then
          with TIBQuery(ibsqlCount) do
          begin
            SQL.Text := 'SELECT COUNT(*)';
            SQL.Add(ExtractSQLFrom(FQueryText.Text));
            SQL.Add(ExtractSQLWhere(FQueryText.Text));
            SQL.Add(ExtractSQLOther(FQueryText.Text));
            SQL.Add(ExtractSQLOrderBy(FQueryText.Text));
          end
        else
          with TIBCustomDataSetCracker(ibsqlCount) do
          begin
            SelectSQL.Text := 'SELECT COUNT(*)';
            SelectSQL.Add(ExtractSQLFrom(FQueryText.Text));
            SelectSQL.Add(ExtractSQLWhere(FQueryText.Text));
            SelectSQL.Add(ExtractSQLOther(FQueryText.Text));
            SelectSQL.Add(ExtractSQLOrderBy(FQueryText.Text));
          end;

        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
            ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
              TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

        // Присваиваем параметры если они есть из оригинального компонента
{        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if (ibsqlCount is TIBQuery) then
          begin
            if TIBQuery(ibsqlCount).ParamByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) <> nil then
              TIBQuery(ibsqlCount).ParamByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name).Value := TIBCustomDataSetCracker(FIBDataSet).Params[I].Value;
          end else
            if TIBCustomDataSetCracker(ibsqlCount).Params.ByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) <> nil then
              TIBCustomDataSetCracker(ibsqlCount).Params.ByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name).Value := TIBCustomDataSetCracker(FIBDataSet).Params[I].Value;}

        for I := 0 to ParamList.Count - 1 do
          if (FIBDataSet is TIBQuery) then
          begin
            if TIBQuery(ibsqlCount).ParamByName(ParamList.Names[I]) <> nil then
              TIBQuery(ibsqlCount).ParamByName(ParamList.Names[I]).AsString :=
                ParamList.Values[ParamList.Names[I]];
          end else
            if TIBCustomDataSetCracker(ibsqlCount).Params.ByName(ParamList.Names[I]) <> nil then
              TIBCustomDataSetCracker(ibsqlCount).Params.ByName(ParamList.Names[I]).AsString :=
                ParamList.Values[ParamList.Names[I]];

        ibsqlCount.Open;
        ibsqlCount.Next;
        if ibsqlCount.Eof then
          // Присваиваем количество записей
          FRecordCount := ibsqlCount.Fields[0].AsInteger
        else
        begin
          ibsqlCount.Last;
          FRecordCount := ibsqlCount.RecordCount;
        end;
      finally
        ParamList.Free;
        // Завершаем транзакцию
        if FIBDataSet.Transaction <> nil then
        begin
          if not FlagTr then
            FIBDataSet.Transaction.Commit;
        end else
          if Transaction.InTransaction then
            Transaction.CommitRetaining;
        ibsqlCount.Free;
      end;
    end;
  end;
  Result := FRecordCount;
end;

procedure TgsQueryFilter.CreateActions;
begin
  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Создать фильтр';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnCreateFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('N'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Изменить фильтр';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnEditFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('E'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Удалить фильтр';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnDeleteFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('D'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Отменить фильтрацию';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnFilterBack;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('B'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Количество записей';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRecordCount;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('C'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Список фильтров';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnViewFilterList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('L'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := 'Обновить данные';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRefresh;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(VK_F5, [ssCtrl]);
end;

// Создаем элементы в меню
procedure TgsQueryFilter.MakePopupMenu(AnPopupMenu: TMenu);
const
  MaxFilterCount = 10;  // Максимальное количесто видимых фильтров

var
  ibsqlFilterList: TIBSQL;
  I: Integer;
  FlagSearch: Boolean;
  TempPM: TMenuItem;
begin
  Assert((Database <> nil) and (Transaction <> nil),
    'TgsQueryFilter.MakePopupMenu: Database or transaction are not assigned');

  if not Database.Connected then
  begin
    MessageBox(0,
      'Нельзя создать меню фильтра, т.к. нет подключения к базе.',
      'Внимание',
      MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    Exit;
  end;

  ibsqlFilterList := TIBSQL.Create(Self);
  try
    ExtractComponentKey;

    FlagSearch := False;
    ibsqlFilterList.Database := Database;
    ibsqlFilterList.Transaction := Transaction;

    if not Transaction.InTransaction then
      Transaction.StartTransaction;

    // Вытягиваем список фильтров
    ibsqlFilterList.SQL.Text := 'SELECT id, name FROM flt_savedfilter WHERE'
     + ' componentkey = ' + IntToStr(FComponentKey) + ' AND (userkey '
     + GetISUserKey + ' OR userkey IS NULL) ORDER BY readcount DESC';
    ibsqlFilterList.ExecQuery;

    TempPM := AnPopupMenu.Items;

    // Создаем разделитель если надо
    if TempPM.Count > 0 then
    begin
      TempPM.Add(TMenuItem.Create(TempPM));
      TempPM.Items[TempPM.Count - 1].Caption := '-';
    end;

    // Создаем начальные элементы
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[0];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[1];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[2];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[3];

{    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := 'Сохранить в файл';
    TempPM.Items[TempPM.Count - 1].OnClick := DoOnWriteToFile;
    TempPM.Items[TempPM.Count - 1].ShortCut := ShortCut(Word('S'), [ssCtrl]);
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := 'Загрузить из файла';
    TempPM.Items[TempPM.Count - 1].OnClick := DoOnReadFromFile;
    TempPM.Items[TempPM.Count - 1].ShortCut := ShortCut(Word('L'), [ssCtrl]);}

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[4];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '-';

    // Создаем список фильтров
    I := 0;
    while (not ibsqlFilterList.Eof) and ((I < MaxFilterCount) or not FlagSearch) do
    begin
      if (I < MaxFilterCount) or (FCurrentFilter = ibsqlFilterList.Fields[0].AsInteger) then
      begin
        TempPM.Add(TMenuItem.Create(TempPM));
        TempPM.Items[TempPM.Count - 1].Caption := ibsqlFilterList.Fields[1].AsString;
        TempPM.Items[TempPM.Count - 1].Tag := ibsqlFilterList.Fields[0].AsInteger;
        TempPM.Items[TempPM.Count - 1].OnClick := DoOnSelectFilter;
        TempPM.Items[TempPM.Count - 1].RadioItem := True;
      end;

      if FCurrentFilter = ibsqlFilterList.Fields[0].AsInteger then
      begin
        TempPM.Items[TempPM.Count - 1].Checked := True;
        FlagSearch := True;
      end;
      Inc(I);

      ibsqlFilterList.Next;
    end;

    // Создаем конечные элементы
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '-';

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[5];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[6];

    // Если не обнаружен текущий элемент, то сбрасываем его
    if (not FlagSearch) and (FCurrentFilter <> 0) then
      RevertQuery;

  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    ibsqlFilterList.Free;
  end;

  if (FCurrentFilter = 0) then
    SetEnabled(False)
  else
    SetEnabled(True);
end;

// Возвращаем запрос в исходное состояние
procedure TgsQueryFilter.RevertQuery;
var
  ParamList: TfltStringList;
  I: Integer;
var
  Flag: Boolean;
begin
  FIsSQLChanging := True;
  // Очищаем параметры
  FFilterData.Clear;
  FCurrentFilter := 0;
  FFilterName := '';
  FFilterComment := '';
  FLastExecutionTime := 0;
  FDeltaReadCount := 0;
  // Создаем тект начального запроса
  Flag := FIBDataSet.Active;
  FQueryText.Clear;
  FQueryText.Add(FQueryAlias);
  FQueryText.AddStrings(FSelectText);
  FQueryText.AddStrings(FFromText);
  FQueryText.AddStrings(FWhereText);
  FQueryText.AddStrings(FOtherText);
  FQueryText.AddStrings(FOrderText);
  ParamList := TfltStringList.Create;
  try
    if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
      for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
        if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
          ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
            TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

    FIBDataSet.Close;

    // Присваиваем текст запроса
    if IsIBQuery then
      TIBQuery(FIBDataSet).SQL.Assign(FQueryText)
    else
      TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Assign(FQueryText);

    for I := 0 to ParamList.Count - 1 do
      try
        if TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]) <> nil then
          TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsString := ParamList.ValuesOfIndex[I];
      except
      end;
  finally
    ParamList.Free;
  end;

  FRecordCount := -1;
  // Открываем если надо
  if Flag then
  try
    FIBDataSet.Open;
  except
    on E: Exception do
      MessageBox(0,
       PChar('Неверен начальный запрос'#13#10 + E.Message),
       'Внимание',
       MB_OK or MB_ICONSTOP or MB_TASKMODAL);
  end;
  FIsSQLChanging := False;
  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self, 0);
end;

(*
function TgsQueryFilter.ShowDialogAndQuery: Boolean;
var
  TempFilter: TFilterData;
  LocalChange: Boolean;
begin
  TempFilter := TFilterData.Create;
  try
    LocalChange := False;
    FSavedFilter := 0;
    TempFilter.Assign(FFilterData);
    Result := ShowDialog;
    if Result then
    begin
      if FSavedFilter <> 0 then
      begin
        SaveFilter;
        if True then      {gs} // Здесь должна следовать проверка на отличие сохраненного и последнего условия
        begin     // Слишком громоздкая схема, надо оптимизировать.
          FCurrentFilter := FSavedFilter;
          FLastExecutionTime := 0;
          FDeltaReadCount := 0;
          SaveFilter;
        end;
        LoadFilter(FSavedFilter);
        CreatePopupMenu;
      end else
      begin
        LocalChange := CompareFilterData(FFilterData, TempFilter);
        if not LocalChange then
        begin
          FLastExecutionTime := 0;
          FDeltaReadCount := 0;
        end;
      end;
      if not LocalChange or (MessageBox(0, 'Условия запроса не изменены.'#13#10
       + 'Перестроить запрос?', 'Внимание', MB_OKCANCEL or MB_ICONQUESTION) = IDOK) then
        FilterQuery;
    end;
    FSavedFilter := 0;
  finally
    TempFilter.Free;
  end;
end;  *)

procedure TgsQueryFilter.SetQuery(Value: TIBCustomDataSet);
begin
  Assert((Value = nil) or not (Value is TIBTable));

  if (FIBDataSet <> nil) then
    if not (csDesigning in ComponentState) then
      FIBDataSet.BeforeOpen := FOldBeforeOpen;

  if Value <> FIBDataSet then
  begin
    FIBDataSet := Value;
    if not (csDesigning in ComponentState) and (FIBDataSet <> nil) then
    begin
      FOldBeforeDatabaseDisconect := TIBCustomDataSetCracker(FIBDataSet).BeforeDatabaseDisconnect;
      TIBCustomDataSetCracker(FIBDataSet).BeforeDatabaseDisconnect := SelfBeforeDisconectDatabase;

      FOldBeforeOpen := TIBCustomDataSetCracker(FIBDataSet).BeforeOpen;
      TIBCustomDataSetCracker(FIBDataSet).BeforeOpen := SelfBeforeOpen;

      SeparateQuery;
    end;
  end;
end;

// Разбираем запрос
procedure TgsQueryFilter.SeparateQuery;
var
  SL: TStringList;
begin
  FRecordCount := -1;
  SL := TStringList.Create;
  try
    SL.Assign(TIBCustomDataSetCracker(FIBDataSet).SelectSQL);

    if not FIsSQLChanging and (FIBDataSet <> nil) and (SL.Count > 0) and
     (SL.Strings[0] <> FQueryAlias) then
    begin
      ExtractTablesList(SL.Text, TableList);             // Список таблиц
      FSelectText.Text := ExtractSQLSelect(SL.Text);     // Часть СЕЛЕКТ
      FFromText.Text := ExtractSQLFrom(SL.Text);         // Часть ФРОМ
      FWhereText.Text := ExtractSQLWhere(SL.Text);       // Часть ВЭА
      FOtherText.Text := ExtractSQLOther(SL.Text);       // Доп. текст
      FOrderText.Text := ExtractSQLOrderBy(SL.Text);     // Часть ОРДЕР
      ExtractFieldLink(SL.Text, FLinkCondition);         // Список связей

      FIsSQLTextChanged := False;                 // Запрос изменен
      FilterQuery;                                // Присваиваем условия
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsQueryFilter.SelfBeforeDisconectDatabase(Sender: TObject);
begin
  if Assigned(FOldBeforeDatabaseDisconect) then
    FOldBeforeDatabaseDisconect(Sender);

  SaveLastFilter;
end;

function TgsQueryFilter.IsIBQuery: Boolean;
begin
  Result := FIBDataSet is TIBQuery;
end;

procedure TgsQueryFilter.SelfBeforeOpen(DataSet: TDataSet);
begin
  SeparateQuery;
  if not FIsFirstOpen then
  begin
    LoadLastFilter;
    CreatePopupMenu;
    FIsFirstOpen := True;
  end;
  if Assigned(FOldBeforeOpen) then
    FOldBeforeOpen(DataSet);
end;

function TgsQueryFilter.GetOwnerName: String;
begin
  if (Owner <> nil) then
    Result := Copy(Owner.Name, 1, FIndexFieldLength)
  else
    Result := '';
end;

procedure TgsQueryFilter.PopupMenu(const X: Integer = -1; const Y: Integer = -1);
var
  Pt: TPoint;
begin
  if FPopupMenu = nil then
    CreatePopupMenu;

  if (X = -1) and (Y = -1) then
  begin
    GetCursorPos(Pt);
    FPopupMenu.Popup(Pt.X, Pt.Y);
  end else
    FPopupMenu.Popup(X, Y);
end;

procedure TgsQueryFilter.DoOnRefresh(Sender: TObject);
begin
  FilterQuery;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsQueryFilter]);
end;

end.
