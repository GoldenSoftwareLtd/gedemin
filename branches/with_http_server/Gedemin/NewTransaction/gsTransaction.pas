{++

  Copyright (c) 2000 by Golden Software of Belarus

  Module

    gsTransaction

  Abstract

    Компонент предназначен для работы с операциями:
      1. Определение типа операций
      2. Формирование проводок на основании типовых проводок
      3. Просмотр сформированных проводок
      4. Установка аналитику, за которую документ не отвечает.

      Для работы компоненту необходима следующая входная информация:
         1. Тип документа
         2. Список предоставляемых числовых переменных
         3. Список справочников, являющихся аналитикой и их значения для
            конкретного документа

      Список таблиц к которые необходимы компоненте для подготовки к работе:
         1. Список операций gd_listtrtype
         2. Список типовых проводок gd_entry
         3. План счетов gd_cardaccount
         4. Список условий формирования операций gd_listtrtypecond

         Компонента подключается к DataSource, который отвечает за ту таблицу в
      документе по каждой записи которой будет формироваться операция. В компоненте
      задается имя поля, которое в данной таблице хранит ссылку на тип операции.
      В компоненте задется список дата сетов, которые могут влиять на тип операции,
      на аналитку по счетам в проводках операции или на суммовое значение операции.
      В компоненте устанавливается свойство - будут ли проводки создаваться сразу же
      или компонента будет определять только тип операции.

        Компонента обрабатывает подключенные DataSet и выделяет какие таблицы и поля
      где находтся и на основании этой информации полуечает значений по аналитки,
      опеределеят тип операции и формирует суммы проводок. В этом случае вся
      дальнейшая работа осуществляется самой компонентой - программист может только
      предоставить интерфейс пользователю, что бы тот мог вручную указать нужную
      операцию.
        Если компонента формирует проводки то при закрытии окна если нажата кнопка Ok,
      она пробегает по подключенному DataSet и выбирая из него тип операции и нужные
      значения формирует проводки.

        Для возможности программисту самому определять, когда и что необходимо сделать
      у компоненты во-первых есть свойство AutoCreate, которое устанавливается в False
      и для работы в ручном режиме соответствующие функции и процедуры.

  Author

    Michael Shoihet (04 dec 2000)

  Revisions history

    1.00    04-Dec-2000    michael    Initial version.

--}

unit gsTransaction;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB,
  dbctrls, contnrs, Ibdatabase, IBSQL, at_classes, xCalc, dmDatabase_unit,
  tr_type_unit, IBCustomDataSet, IBQuery, at_sql_tools, gsIBLookupComboBox, stdctrls;

type
  TBeginTransactionType = (btAfterOpen, btManual);
  TEndTransactionType = (etAfterPost, etManual);
  TSetTransactionType = (stBeforePost, stManual);

  TIBCustomDataSetCracker = class(TIBCustomDataSet);


  TgsTransaction = class(TComponent)
  private
    FDataLink: TFieldDataLink;
    FFieldKey: String;
    FFieldTrName: String;
    FDocumentType: Integer;
    FTransactionDate: TDateTime;
    FDocumentNumber: String;
    FFieldDocumentKey: String;
    FCurrencyKey: Integer;
    FBeginTransactionType: TBeginTransactionType;
    FEndTransactionType: TEndTransactionType;
    FSetTransactionType: TSetTransactionType;

    FOldAfterOpen: TDataSetNotifyEvent;
    FOldBeforeClose: TDataSetNotifyEvent;
    FOldBeforePost: TDataSetNotifyEvent;
    FOldAfterPost: TDataSetNotifyEvent;

    FConditionDataSetList: TList;
    FTransactionRelationFieldList: TObjectList;

    FTransactionList: TObjectList;
    FCurTransactionList: TObjectList;
    FPosTransactionList: TObjectList;

    FChanged: Boolean;
    FDocumentOnly: Boolean;
    FMakeDelayedEntry: Boolean;

    procedure DoAfterOpen(DataSet: TDataSet);
    procedure DoAfterPost(DataSet: TDataSet);
    procedure DoBeforePost(DataSet: TDataSet);
    procedure DoOnChangeField(Sender: TField);

    procedure DeleteTransaction(const DocKey, PosKey: Integer);

    function SearchPositionTransaction(const aDocumentKey,
      aPositionKey: Integer): TPositionTransaction;

    function GetTransactionByKey(const aTransactionKey: Integer): TTransaction;

    procedure MakeTransactionRelationFields;
    procedure SetRealEntry(const aDocumentKey, aPositionKey, aTransactionKey: Integer;
      const aDate: TDateTime; ValueList, AnalyzeList: TObjectList;
      const aCurrKey: Integer; isEditEntry: Boolean);

    function AddTransactionToBase(Transaction: TPositionTransaction; IBSQL: TIBSQL): Boolean;

    function CreateTransactionOnType(const aTransactionKey, aDocumentKey, aPositionKey: Integer;
      const aDate: TDateTime): TPositionTransaction;

    function GetDataSource: TDataSource;
    function GetFieldName: String;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetFieldName(const Value: String);
    function GetCurTransactionCount: Integer;
    function GetPosTransaction(Index: Integer): TPositionTransaction;
    function GetPosTransactionCount: Integer;
    function GetCurTransaction(Index: Integer): TTransaction;
    procedure SetAnalyzeAndValue(aDataSet: TDataSet; ValueList,
      AnalyzeList: TObjectList);
    procedure SetEndTransactionType(const Value: TEndTransactionType);
    procedure SetSetTransactionType(const Value: TSetTransactionType);

  protected

    procedure CreateOneTransaction(const aDocumentKey, aPositionKey,
      aCurrKey, aTransactionKey: Integer;
      const aDocumentDate: TDateTime; aValueList: TObjectList; aAnalyzeList: TObjectList;
      aDataSet: TDataSet; isEditTransaction: Boolean);

    procedure Notification(aComponent: TComponent; Operation: TOperation);
      override;
    procedure Loaded; override;

  public
    constructor Create(aOwner: TComponent);
      override;
    destructor Destroy;
      override;

// Считывание всех операций доступных для данного вида документа
//   при установленном флаге программа считывает сформированные ранее проводки
    function SetStartTransactionInfo(const ReadEntry: Boolean = True): Boolean;

// Проверяет была ли считана начальная информация и если нет считывает ее
// и утстанавливает поля по которым необходимо отслеживать изменения
    procedure Refresh;

// Считывание сформированных проводок по документу
    procedure ReadTransactionOnPosition(const aDocumentCode, aPositionCode,
      aEntryKey: Integer);

// Определение списка операций достпуных при установленных текущих значениях
//    ConditionDataSet и DataSource, возвращает ссылку на первую операцию и заполняет
//    TStrings остальными операциями Items - наименование операции, Objects - TTransaction
    function GetTransaction(List: TStrings): TTransaction;

// Создание проводок по позиции. Если установлен флаг isEditTransaction, то после
//   создания проводок будет выведено окно для их изменения

    procedure CreateTransactionOnPosition(
      const aCurrKey: Integer; const aDocumentDate: TDateTime;
      aValueList, aAnalyzeList: TObjectList;
      const isEditTransaction: Boolean = True);

// Создание проводок по отложенным проводкам (например:
//   проводки по позиции выписки на основании платежных документов)

    procedure CreateTransactionByDelayedTransaction(
      const aTransactionKey, aFromDocumentKey, aToDocumentKey,
            aFromPositionKey, aToPositionKey: Integer;
      const aDocumentDate: TDateTime;
      aValueList: TObjectList = nil);

//  Создание и сохранение проводок по документу.
    function CreateTransactionOnDataSet(const aCurrKey: Integer;
      const aDocumentDate: TDateTime; aValueList: TObjectList = nil;
      aAnalyzeList: TObjectList = nil; CheckTransaction: Boolean = False;
      OnlyWithTransaction: Boolean = False): Boolean;

{    procedure CreateTransactionOnDataSetPos(const aCurrKey: Integer;
      const aDocumentDate: TDateTime; aValueList: TObjectList = nil;
      aAnalyzeList: TObjectList = nil; CheckTransaction: Boolean = False;
      OnlyWithTransaction: Boolean = False);                        }

//  Сохранение сформированных ранее проводок в БД
    function AppendEntryToBase: Boolean;

//  Добавление dataset, значения которого влияют на условия формирования операции
    procedure AddConditionDataSet(aDataSets: array of TIBCustomDataSet);

//  Получаем наименование операции по ее коду
    function GetTransactionName(const TransactionKey: Integer): String;

//  Проверка на корректность указанной операция
    function IsValidTransaction(const aTransactionKey: Integer): Boolean;

//  Проверка является ли указанная операция, операцией для текущего типа документа
    function IsValidDocTransaction(const aTransactionKey: Integer): Boolean;

//  Проверка является ли операция валютной
    function IsCurrencyTransaction(const aTransactionKey: Integer): Boolean;

//  Устанавливает код операции для всех записей текущего DataSet (определяя его на основании
//     текущих значений записей).
    procedure SetTransactionOnDataSet;

//  Создает TgsDBLookupComboBox для каждого справочника аналитики, который используется
//     в текущей операции. Контролы помещаются в Sender
    function SetAnalyzeControl(const aTransactionKey: Integer; Sender: TWinControl;
      FOnChange: TNotifyEvent; FTransaction: TIBTransaction): TWinControl;

//  Процедура формирует список аналитики для указанной операции.
    procedure GetAnalyzeList(const aTransactionKey: Integer; aAnalyzeList: TList);

//  Заполняет список наименованиями операциями и привязывает к ним объекты TTransaction
    function SetTransactionStrings(Value: TStrings; aTransactionKey: Integer): Integer;

//  Доступные операции
    property CurTransaction[Index: Integer]: TTransaction read GetCurTransaction;
    property CurTransactionCount: Integer read GetCurTransactionCount;

//  Операции сформированные по данному документу
    property PosTransaction[Index: Integer]: TPositionTransaction
      read GetPosTransaction;
    property PosTransactionCount: Integer read GetPosTransactionCount;

//  Дата операции
    property TransactionDate: TDateTime read FTransactionDate write FTransactionDate;

//  Номер документа
    property DocumentNumber: String read FDocumentNumber;

//  Код валюты документа
    property CurrencyKey: Integer read FCurrencyKey write FCurrencyKey;

//  Изменилась ли транзанкция
    property Changed: Boolean read FChanged write FChanged;

  published
//  Тип документа
    property DocumentType: Integer read FDocumentType write FDocumentType;
//  Таблица источник операции
    property DataSource: TDataSource read GetDataSource write SetDataSource;
//  Наименовнаие поля ссылки на операцию
    property FieldName: String read GetFieldName write SetFieldName;
//  Наименование поля - уникальный ключ записи по которой формируется операция
    property FieldKey: String read FFieldKey write FFieldKey;
//  Наименование поля - наименование операции
    property FieldTrName: String read FFieldTrName write FFieldTrName;
//  Наименование поля - ссылка на главный документ
    property FieldDocumentKey: String read FFieldDocumentKey write FFieldDocumentKey;

//  Устанавливает в какой момент будет производится считывание начальных настроек
    property BeginTransactionType: TBeginTransactionType read FBeginTransactionType
      write FBeginTransactionType default btAfterOpen;

//  Устанавливает в какой момент будут формироваться проводки по документу
    property EndTransactionType: TEndTransactionType read FEndTransactionType
      write SetEndTransactionType default etManual;

//  Устанавливает в какой момент будет формироваться тип операции
    property SetTransactionType: TSetTransactionType read FSetTransactionType
      write SetSetTransactionType default stManual;

    property DocumentOnly: Boolean read FDocumentOnly write FDocumentOnly;
    property MakeDelayedEntry: Boolean read FMakeDelayedEntry write FMakeDelayedEntry;

  end;

procedure Register;

implementation

uses
  at_sql_Setup, flt_sqlfilter_condition_type, tr_dlgEditEntry_unit,
  gd_security, gdcBaseInterface;

{ TgsTransaction }

constructor TgsTransaction.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDataLink := TFieldDataLink.Create;
  FFieldKey := 'ID';
  FFieldTrName := 'TRANSACTIONNAME';
  FFieldDocumentKey := 'DOCUMENTKEY';

  FBeginTransactionType := btAfterOpen;
  FEndTransactionType := etManual;
  FSetTransactionType := stManual;

  FTransactionRelationFieldList := TObjectList.Create;

  FMakeDelayedEntry := False;

//  FTransaction := nil;
//  FDatabase := nil;

  FOldAfterOpen := nil;
  FOldBeforeClose := nil;
  FOldBeforePost := nil;
  FOldAfterPost := nil;

  FCurrencyKey := -1;
  FDocumentType := -1;

  FTransactionDate := Now;
  FDocumentNumber := '';

  FChanged := False;
  FDocumentOnly := False;

  FConditionDataSetList := TList.Create;
  FTransactionList := TObjectList.Create;
  FCurTransactionList := TObjectList.Create;
  FPosTransactionList := TObjectList.Create;
end;

destructor TgsTransaction.Destroy;
begin
  if Assigned(FTransactionRelationFieldList) then
    FreeAndNil(FTransactionRelationFieldList);
  if Assigned(FTransactionList) then
    FreeAndNil(FTransactionList);
  if Assigned(FCurTransactionList) then
    FreeAndNil(FCurTransactionList);
  if Assigned(FPosTransactionList) then
    FreeAndNil(FPosTransactionList);
  if Assigned(FConditionDataSetList) then
    FreeAndNil(FConditionDataSetList);

  if Assigned(FDataLink) then
    FreeAndNil(FDataLink);

  inherited;

end;

procedure TgsTransaction.Loaded;
begin
  inherited;

  if not (csDesigning in ComponentState)
  then
  begin
    if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    begin
      { TODO 1 -oденис -cпросто : Кстати, можно использовать DataLink }

      FOldAfterOpen := DataSource.DataSet.AfterOpen;
      DataSource.DataSet.AfterOpen := DoAfterOpen;

      FOldAfterPost := DataSource.DataSet.AfterPost;
      FOldBeforePost := DataSource.DataSet.BeforePost;

      DataSource.DataSet.BeforePost := DoBeforePost;
      DataSource.DataSet.AfterPost := DoAfterPost
    end;
  end;
end;

function TgsTransaction.GetCurTransactionCount: Integer;
begin
  if Assigned(FCurTransactionList) then
    Result := FCurTransactionList.Count
  else
    Result := 0;
end;

function TgsTransaction.GetCurTransaction(Index: Integer): TTransaction;
begin
  if CurTransactionCount > 0 then
    Result := (FCurTransactionList[Index] as TTransaction)
  else
    Result := nil;
end;

function TgsTransaction.GetTransaction(List: TStrings): TTransaction;
var
  i, j: Integer;
  isOk: Boolean;
  Transaction: TTransaction;
  ValueCondition: TFilterConditionList;
  LocCond: TFilterCondition;
  DS: TIBCustomDataSetCracker;
  FTransaction: TIBTransaction;

begin
  Result := nil;

  if not Assigned(FCurTransactionList) then exit;
  if not Assigned(FTransactionList) then exit;

  ValueCondition := TFilterConditionList.Create;
  LocCond := TFilterCondition.Create;
  try

    for i:= 0 to FConditionDataSetList.Count - 1 do
    begin

      DS := TIBCustomDataSetCracker(FConditionDataSetList[i]);
      if DS.Active then
      begin
        for j := 0 to DS.QSelect.Current.Count - 1 do
        begin
          if DS.QSelect.Current[j].AsXSQLVAR.relname[0] <> #0 then
          begin
            LocCond.FieldData.TableName :=
              StrPas(DS.QSelect.Current[j].AsXSQLVAR.relname);
            LocCond.FieldData.TableAlias := 'A';
            LocCond.FieldData.FieldName :=
              StrPas(DS.QSelect.Current[j].AsXSQLVAR.sqlname);
            LocCond.Value1 := DS.Fields[j].AsString;
            ValueCondition.AddCondition(LocCond);
          end;
        end;
      end;
    end;

    FCurTransactionList.Clear;

    if Assigned(List) then
      List.Clear;

    if FTransactionList.Count = 0 then
      SetStartTransactionInfo;

    FTransaction := (DataSource.DataSet as TIBCustomDataSet).ReadTransaction;       

    for i:= 0 to FTransactionList.Count - 1 do
    begin
      isOK := TTransaction(FTransactionList[i]).IsTransaction(FTransaction,
        ValueCondition);

      if isOK then
      begin
        if Result = nil then
          Result := TTransaction(FTransactionList[i]);

        Transaction := TTransaction.Create(-1, -1, '', '', FDocumentOnly);
        Transaction.Assign(TTransaction(FTransactionList[i]));
        FCurTransactionList.Add(Transaction);
        if Assigned(List) then
          List.AddObject(Transaction.TransactionName, Transaction);
      end;

    end;

    if Assigned(DataSource) and Assigned(DataSource.DataSet) and (FieldName > '') and
       IsValidTransaction(DataSource.DataSet.FieldByName(FieldName).AsInteger)
    then
      Result := GetTransactionByKey(DataSource.DataSet.FieldByName(FieldName).AsInteger);

  finally
    ValueCondition.Free;
    LocCond.Free;
  end;
  
end;


procedure TgsTransaction.Notification(aComponent: TComponent;
  Operation: TOperation);

procedure SearchAndDeleteDataSet;
var
  i: Integer;
begin
  if Assigned(FConditionDataSetList) then
  begin
    for i:= 0 to FConditionDataSetList.Count - 1 do
      if FConditionDataSetList[i] = aComponent then
      begin
        FConditionDataSetList.Delete(i);
        Break;
      end;
  end;    
end;

begin
  inherited;

  if Operation = opRemove then
  begin
    if Assigned(FDataLink) and (AComponent = FDataLink.DataSource) then
      FDataLink.DataSource := nil
    else {if AComponent = FTransaction then
      Transaction := nil
    else if AComponent = FDatabase then
      Database := nil
    else} if AComponent is TIBDataSet then
      SearchAndDeleteDataSet;
  end;

end;

function TgsTransaction.SetStartTransactionInfo(const ReadEntry: Boolean): Boolean;
var
  ibsql: TIBSQL;
  ibsqlAR: TIBSQL;
  ibdsCondition: TIBDataSet;
  atSQLSetup: TatSQLSetup;
  TransactionKey: Integer;
  EntryKey: Integer;

  Transaction: TTransaction;
  Entry: TEntry;
  Account: TTypeAccount;
  LocBlobStream: TIBDSBlobStream;
  FTransaction: TIBTransaction;

procedure MakeAnalyzeList;
var
  i: Integer;
  Value: Integer;
  FieldName_Type: String;
  FieldName_Value: String;
  S, FieldName: String;
  RelationField: TatRelationField;
begin
  S := ibsql.Current.Names;
  for i:= 0 to ibsql.Current.Count - 1 do
  begin
    if Pos(#13#10, S) > 0 then
    begin
      FieldName := copy(S, 1, Pos(#13, S) - 1);
      S := copy(S, Pos(#10, S) + 1, Length(S));
    end
    else
    begin
      FieldName := S;
      S := '';
    end;

    if Pos(UserPrefix, FieldName) > 0 then
    begin
      if copy(FieldName, Length(FieldName), 1) = '1' then
      begin
        FieldName_Type := FieldName;
        FieldName_Value := copy(FieldName, 1, Length(FieldName) - 1);
      end
      else
      begin
        FieldName_Value := FieldName;
        FieldName_Type := FieldName + '1';
      end;

      if (Pos(FieldName_Type, ibsql.Current.Names) > 0) and
         (ibsql.FieldByName(FieldName_Type).AsInteger = 1) then
      begin
        if ibsql.FieldByName(FieldName_Value).IsNull then
          Value := -1
        else
          Value := ibsql.FieldByName(FieldName_Value).AsInteger;

        RelationField := atDatabase.FindRelationField('GD_ENTRY', FieldName_Value);

        if  Assigned(RelationField) and Assigned(RelationField.References)
        then
        begin
          ibsqlAR.ParamByName('elk').AsInteger := ibsql.FieldByName('EntryLineKey').AsInteger;
          ibsqlAR.ParamByName('af').AsString := RelationField.FieldName;
          ibsqlAR.ExecQuery;
          Account.AddAnalyze(Trim(ibsqlAR.FieldByName('docrelname').AsString),
            Trim(ibsqlAR.FieldByName('docfieldname').AsString),
            Trim(RelationField.References.RelationName), Trim(RelationField.FieldName), Value);
          ibsqlAR.Close;
        end;
      end;

    end;

  end;
end;

begin
  Result := False;
  if not Assigned(DataSource) or not Assigned(DataSource.DataSet) or (FDocumentType = -1) then exit;

{  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;}

  FTransaction := (DataSource.DataSet as TIBCustomDataSet).ReadTransaction;


  ibsql := TIBSQL.Create(Self);
  ibsqlAR := TIBSQL.Create(Self);
  ibdsCondition := TIBDataSet.Create(Self);
  try
    ibsql.Transaction := FTransaction;
    ibsqlAR.Transaction := FTransaction;
    ibdsCondition.Transaction := FTransaction;

    ibsqlAR.SQL.Text :=
      'SELECT * FROM gd_entryanalyzerel WHERE entrylinekey = :elk AND analyzefield = :af ' +
        'AND doctypekey = :dtk';
    ibsqlAR.Prepare;
    ibsqlAR.ParamByName('dtk').AsInteger := FDocumentType;

    ibsql.SQL.Text :=
      Format(
      'SELECT t.id as TransactionKey, t.name as TransactionName, t.Description as TransactionDesc, ' +
      ' e.ID as EntryLineKey, e.EntryKey, e.expressionncu, e.expressioncurr, ' +
      ' e.expressioneq, e.accounttype, c.id as AccountKey,' +
      ' c.Alias, c.Name as AccountName, c.multycurr ' +
      ' FROM gd_documenttrtype d  LEFT JOIN gd_listtrtype t ON t.id = d.trtypekey ' +
      '      LEFT JOIN gd_entry e ON e.trtypekey = t.id LEFT JOIN gd_cardaccount c ON e.accountkey = c.id ' +
      ' WHERE ' +
      '   d.documenttypekey = %d AND isdocument = :isd' +
      ' ORDER BY t.id, e.entrykey, e.accounttype, c.id',
      [FDocumentType]);

    atSQLSetup := TatSQLSetup.Create(Self);
    try
      ibsql.SQL.Text := atSQLSetup.PrepareSQL(ibsql.SQL.Text);
    finally
      atSQLSetup.Free;
    end;

    if FDocumentOnly then
      ibsql.ParamByName('isd').AsInteger := 1
    else
      ibsql.ParamByName('isd').AsInteger := 0;

    ibsql.ExecQuery;

    TransactionKey := -1;
    EntryKey := -1;

    Transaction := nil;
    Entry := nil;

    FTransactionList.Clear;

    while not ibsql.Eof do
    begin

      if ibsql.FieldByName('TransactionKey').AsInteger <> TransactionKey then
      begin
        if Assigned(Transaction) and Assigned(Entry) then
        begin
          if (Entry.DebitCount > 0) and (Entry.CreditCount > 0) then
            Transaction.AddTypeEntry(Entry);
          FTransactionList.Add(Transaction);
        end;
        TransactionKey := ibsql.FieldByName('TransactionKey').AsInteger;

        Transaction := TTransaction.Create(
          ibsql.FieldByName('TransactionKey').AsInteger,
          FDocumentType, ibsql.FieldByName('TransactionName').AsString,
          ibsql.FieldByName('TransactionDesc').AsString,
          FDocumentOnly);

        Entry := nil;  

{ Заполняем условия формирования }

        ibdsCondition.SelectSQL.Text :=
          FORMAT('SELECT * FROM gd_listtrtypecond WHERE listtrtypekey = %d AND documenttypekey = %d',
            [TransactionKey, FDocumentType]);
        ibdsCondition.Open;
        LocBlobStream := ibdsCondition.CreateBlobStream(ibdsCondition.FieldByName('data'), bmRead) as TIBDSBlobStream;
        try
          if LocBlobStream.Size > 0 then
            Transaction.AddTransactionCondition(LocBlobStream);
        finally
          FreeAndNil(LocBlobStream);
        end;
        ibdsCondition.Close;
      end;

      if ibsql.FieldByName('EntryKey').AsInteger <> EntryKey then
      begin
        if Assigned(Entry) and (Entry.DebitCount > 0) and (Entry.CreditCount > 0) then
          Transaction.AddTypeEntry(Entry);
        EntryKey := ibsql.FieldByName('EntryKey').AsInteger;
        Entry := TEntry.Create(EntryKey, -1, -1, 0);
      end;

{ Заполняем информацию по счету }

      if ibsql.FieldByName('AccountKey').AsInteger > 0 then
      begin
        Account := TTypeAccount.Create(
          ibsql.FieldByName('AccountKey').AsInteger,
          ibsql.FieldByName('Alias').AsString,
          ibsql.FieldByName('AccountName').AsString,
          ibsql.FieldByName('expressionncu').AsString,
          ibsql.FieldByName('expressioncurr').AsString,
          ibsql.FieldByName('expressioneq').AsString,
          ibsql.FieldByName('multycurr').AsInteger = 1);

{ Формируем список аналитики }

        MakeAnalyzeList;

        Entry.AddEntryLine(Account, ibsql.FieldByName('accounttype').AsString = 'D', '');
      end;

      ibsql.Next;
    end;

    if Assigned(Transaction) and Assigned(Entry) and (Entry.DebitCount > 0) and
       (Entry.CreditCount > 0)
    then
      Transaction.AddTypeEntry(Entry);

    if Assigned(Transaction) then
      FTransactionList.Add(Transaction);

    Result := FTransactionList.Count > 0;

    if Result and ReadEntry then
    begin
      Assert(Assigned(DataSource) and Assigned(DataSource.DataSet),
        'Необходимо задать DataSource и DataSet при автоматическом считывании проводок.');

      ReadTransactionOnPosition(DataSource.DataSet.FieldByName(FieldDocumentKey).AsInteger,
        -1, -1);
    end;

  finally
    ibsql.Free;
    ibsqlAR.Free;
    ibdsCondition.Free;
  end;

end;

procedure TgsTransaction.SetRealEntry(const aDocumentKey, aPositionKey, aTransactionKey: Integer;
  const aDate: TDateTime; ValueList, AnalyzeList: TObjectList; const aCurrKey: Integer;
  isEditEntry: Boolean);
var
  i: Integer;
  Transaction: TTransaction;
begin
  FTransactionDate := aDate;
  Transaction := nil;
  for i:= 0 to PosTransactionCount - 1 do
  begin
    if (PosTransaction[i].DocumentCode = aDocumentKey) and
       (PosTransaction[i].PositionCode = aPositionKey)
    then
    begin
      Transaction := PosTransaction[i];
      Break;
    end;
  end;

  if Assigned(Transaction) and (Transaction.TransactionKey <> aTransactionKey) then
  begin
    FPosTransactionList.Remove(Transaction);
    Transaction := nil;
  end;

  if not Assigned(Transaction) then
  begin
    Transaction := CreateTransactionOnType(aTransactionKey, aDocumentKey, aPositionKey, aDate);
    if Assigned(Transaction) then
      FPosTransactionList.Add(Transaction);
  end;

  if Assigned(Transaction) and (((Transaction as TPositionTransaction).RealEntryCount = 0) or
     (Transaction as TPositionTransaction).TransactionChanged or FChanged)
  then
  begin
    (Transaction as TPositionTransaction).TransactionDate := aDate;
    (Transaction as TPositionTransaction).CreateRealEntry(ValueList, AnalyzeList, aCurrKey);
  end
  else
    if Assigned(Transaction) then
    begin
      if (Transaction as TPositionTransaction).SumTransaction = 0 then
        (Transaction as TPositionTransaction).ChangeValue(
          (Transaction as TPositionTransaction).DocumentCode,
          (Transaction as TPositionTransaction).PositionCode, aDate,
          ValueList)
      else
        (Transaction as TPositionTransaction).TransactionDate := aDate;
    end;

  if Assigned(Transaction) and isEditEntry then
    with TdlgEditEntry.Create(Self) do
      try
        SetupDialog((Transaction as TPositionTransaction));
        if ShowModal = mrOk then
        begin
          Transaction.Assign(PositionTransaction);
          (Transaction as TPositionTransaction).TransactionChanged := False;
          FChanged := False;
        end;
      finally
        Free;
      end;

end;

function TgsTransaction.AddTransactionToBase(Transaction: TPositionTransaction; IBSQL: TIBSQL): Boolean;
var
  j, k, l: Integer;
  StringDate: String;
begin
  Result := True;
  with Transaction do
  begin
    for k:= 0 to RealEntryCount - 1 do
    begin
      if RealEntry[k].EntryKey > 1000000 then
      begin
        ibsql.SQL.Text :=
          Format('DELETE FROM GD_ENTRYS WHERE ENTRYKEY = %d',
          [RealEntry[k].EntryKey]);
        ibsql.ExecQuery;
        ibsql.Close;
      end
      else
      begin
        RealEntry[k].EntryKey := gdcBaseManager.GetNextID;
        if k = 0 then
        begin
          ibsql.SQL.Text :=
            Format('DELETE FROM GD_ENTRYS WHERE DOCUMENTKEY = %d AND POSITIONKEY = %d',
            [RealEntry[k].DocumentKey, RealEntry[k].PositionKey]);
          ibsql.ExecQuery;
          ibsql.Close;
        end;
      end;

      DateTimeToString(StringDate, 'dd.mm.yyyy', RealEntry[k].EntryDate);

      if FMakeDelayedEntry or (RealEntry[k].GetDebitSumNCU <> 0) then
      begin
        try
          for j:= 0 to RealEntry[k].DebitCount - 1 do
          begin

            ibsql.SQL.Text :=
              'INSERT INTO gd_entrys (entrykey, trtypekey, accountkey, accounttype, entrydate, ' +
              ' debitsumncu, debitsumcurr, debitsumeq, currkey, documentkey, positionkey, ' +
              ' description, afull, achag, aview, companykey, delayedentry ';

            for l:= 0 to TRealAccount(RealEntry[k].Debit[j]).CountAnalyze - 1 do
              ibsql.SQL.Text := ibsql.SQL.Text + ', ' +
                 TRealAccount(RealEntry[k].Debit[j]).AnalyzeItem[l].FieldName;

            ibsql.SQL.Text := ibsql.SQL.Text + ') ' +
              Format(' VALUES(%d, %d, %d, ''D'', ''%s'', :ncu, :curr, :eq, :CurrKey, %d, %d, ''%s'', -1, -1, -1, %d, %d',
              [RealEntry[k].EntryKey, TransactionKey, RealEntry[k].Debit[j].Code,
               StringDate,
               RealEntry[k].DocumentKey, RealEntry[k].PositionKey,
               RealEntry[k].Description, IBLogin.CompanyKey, Integer(FMakeDelayedEntry)]);

            for l := 0 to TRealAccount(RealEntry[k].Debit[j]).CountAnalyze - 1 do
              if TRealAccount(RealEntry[k].Debit[j]).AnalyzeItem[l].ValueAnalyze > 0 then
                ibsql.SQL.Text := ibsql.SQL.Text + ', ' +
                   IntToStr(TRealAccount(RealEntry[k].Debit[j]).AnalyzeItem[l].ValueAnalyze)
              else
                ibsql.SQL.Text := ibsql.SQL.Text + ', NULL';
            ibsql.SQL.Text := ibsql.SQL.Text + ')';

            if TRealAccount(RealEntry[k].Debit[j]).CurrKey > 0 then
              ibsql.ParamByName('CurrKey').AsInteger := TRealAccount(RealEntry[k].Debit[j]).CurrKey
            else
              ibsql.ParamByName('CurrKey').Clear;

            ibsql.ParamByName('ncu').AsCurrency := TRealAccount(RealEntry[k].Debit[j]).SumNCU;
            ibsql.ParamByName('curr').AsCurrency := TRealAccount(RealEntry[k].Debit[j]).SumCurr;
            ibsql.ParamByName('eq').AsCurrency := TRealAccount(RealEntry[k].Debit[j]).SumEq;

            ibsql.ExecQuery;
            ibsql.Close;
          end;

          for j:= 0 to RealEntry[k].CreditCount - 1 do
          begin
            ibsql.SQL.Text :=
              'INSERT INTO gd_entrys (entrykey, trtypekey, accountkey, accounttype, entrydate, ' +
              ' creditsumncu, creditsumcurr, creditsumeq, currkey, documentkey, positionkey, ' +
              ' description, afull, achag, aview, companykey, delayedentry ';

            for l:= 0 to TRealAccount(RealEntry[k].Credit[j]).CountAnalyze - 1 do
              ibsql.SQL.Text := ibsql.SQL.Text + ', ' +
                 TRealAccount(RealEntry[k].Credit[j]).AnalyzeItem[l].FieldName;

            ibsql.SQL.Text := ibsql.SQL.Text + ') ' +
              Format(' VALUES(%d, %d, %d, ''K'', ''%s'', :ncu, :curr, :eq, :CurrKey, %d, %d, ''%s'', -1, -1, -1, %d, %d',
              [RealEntry[k].EntryKey, TransactionKey, RealEntry[k].Credit[j].Code,
               StringDate,
               RealEntry[k].DocumentKey, RealEntry[k].PositionKey,
               RealEntry[k].Description, IBLogin.CompanyKey,
               Integer(FMakeDelayedEntry)]);

            for l := 0 to TRealAccount(RealEntry[k].Credit[j]).CountAnalyze - 1 do
              if TRealAccount(RealEntry[k].Credit[j]).AnalyzeItem[l].ValueAnalyze > 0 then
                ibsql.SQL.Text := ibsql.SQL.Text + ', ' +
                   IntToStr(TRealAccount(RealEntry[k].Credit[j]).AnalyzeItem[l].ValueAnalyze)
              else
                ibsql.SQL.Text := ibsql.SQL.Text + ', NULL';

            ibsql.SQL.Text := ibsql.SQL.Text + ')';

            if TRealAccount(RealEntry[k].Credit[j]).CurrKey > 0 then
              ibsql.ParamByName('CurrKey').AsInteger := TRealAccount(RealEntry[k].Credit[j]).CurrKey
            else
              ibsql.ParamByName('CurrKey').Clear;

            ibsql.ParamByName('ncu').AsCurrency := TRealAccount(RealEntry[k].Credit[j]).SumNCU;
            ibsql.ParamByName('curr').AsCurrency := TRealAccount(RealEntry[k].Credit[j]).SumCurr;
            ibsql.ParamByName('eq').AsCurrency := TRealAccount(RealEntry[k].Credit[j]).SumEq;

            ibsql.ExecQuery;
            ibsql.Close;
          end;
        except
          if ibsql.Open then
            ibsql.Close;
          ibsql.SQL.Text :=
            Format('DELETE FROM GD_ENTRYS WHERE ENTRYKEY = %d',
            [RealEntry[k].EntryKey]);
          ibsql.ExecQuery;
          ibsql.Close;
          Result := False;
        end;
      end;
    end;
  end;

end;

function TgsTransaction.AppendEntryToBase: Boolean;
var
  i: Integer;
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  Result := True;
  ibsql := TIBSQL.Create(Self);
  try

    if DataSource.DataSet is TIBCustomDataSet then
      ibsql.Transaction := (DataSource.DataSet as TIBCustomDataSet).Transaction;

    DidActivate := not (DataSource.DataSet as TIBCustomDataSet).Transaction.InTransaction;
    if DidActivate then
      (DataSource.DataSet as TIBCustomDataSet).Transaction.StartTransaction;
    try
      for i:= 0 to PosTransactionCount - 1 do
      begin
        Result := AddTransactionToBase(PosTransaction[i], ibsql);
        if not Result then
          Break;
      end;
    finally
      if DidActivate then
      begin
        if Result then
          ibsql.Transaction.Commit
        else
          ibsql.Transaction.RollBack;
      end;
    end;

    FPosTransactionList.Clear;
  finally
    ibsql.Free;
  end;
end;

function TgsTransaction.GetDataSource: TDataSource;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.DataSource
  else
    Result := nil;
end;

function TgsTransaction.GetFieldName: String;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.FieldName
  else
    Result := '';
end;

procedure TgsTransaction.SetDataSource(const Value: TDataSource);
begin
  if Assigned(FDataLink) then
    FDataLink.DataSource := Value;
end;

procedure TgsTransaction.SetFieldName(const Value: String);
begin
  if Assigned(FDataLink) then
    FDataLink.FieldName := Value;
end;

procedure TgsTransaction.CreateTransactionOnPosition(
      const aCurrKey: Integer; const aDocumentDate: TDateTime;
      aValueList, aAnalyzeList: TObjectList;
      const isEditTransaction: Boolean = True);
begin

  Assert(Assigned(DataSource) and Assigned(DataSource.DataSet),
    'Не задан DataSource или DataSet для формирования операции');

  Assert(Assigned(DataSource.DataSet.FindField(FieldDocumentKey)) and
    Assigned(DataSource.DataSet.FindField(FieldKey)) and
    Assigned(DataSource.DataSet.FindField(FieldName)),
    'Не найдены поля для формирования операции');

  CreateOneTransaction(DataSource.DataSet.FieldByName(FieldDocumentKey).AsInteger,
    DataSource.DataSet.FieldByName(FieldKey).AsInteger,
    aCurrKey,
    DataSource.DataSet.FieldByName(FieldName).AsInteger,
    aDocumentDate, aValueList, aAnalyzeList,
    DataSource.DataSet, isEditTransaction);

end;

function TgsTransaction.CreateTransactionOnDataSet(const aCurrKey: Integer;
      const aDocumentDate: TDateTime;
      aValueList: TObjectList = nil; aAnalyzeList: TObjectList = nil;
      CheckTransaction: Boolean = False; OnlyWithTransaction: Boolean = False): Boolean;
var
  DataSet: TDataSet;
  isEdit: Boolean;
  T: TTransaction;
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  Result := True;
  if Assigned(FDataLink) and Assigned(FDataLink.DataSource) and
     Assigned(FDataLink.DataSource.DataSet) and (FDataLink.FieldName > '')
  then
  begin
    FTransactionDate := aDocumentDate;

    DataSet := FDataLink.DataSource.DataSet;
    DataSet.DisableControls;
    try
      if not FDocumentOnly then
        DataSet.First;
      while not DataSet.EOF do
      begin
        if FDocumentOnly then
          try
            FTransactionDate := DataSet.FieldByName('documentdate').AsDateTime;
          except
            FTransactionDate := aDocumentDate;
          end;
        if not OnlyWithTransaction and (DataSet.FieldByName(FieldName).AsInteger = 0) then
        begin
          T := GetTransaction(nil);
          if Assigned(T) then
          begin
            isEdit := True;
            if not (DataSet.State in [dsEdit, dsInsert]) then
            begin
              isEdit := False;
              DataSet.Edit;
            end;
            DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey;
            if not isEdit then
              DataSet.Post;
          end;
        end
        else
          if CheckTransaction then
          begin
            T := GetTransaction(nil);
            if not isValidTransaction(DataSet.FieldByName(FieldName).AsInteger)
            then
            begin
              DeleteTransaction(DataSet.FieldByName(FieldDocumentKey).AsInteger,
                DataSet.FieldByName(FFieldKey).AsInteger);
              isEdit := True;
              if not (DataSet.State in [dsEdit, dsInsert]) then
              begin
                isEdit := False;
                DataSet.Edit;
              end;
              if Assigned(T) then
                DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey
              else
              begin

                DataSet.FieldByName(FieldName).Clear;
                ibsql := TIBSQL.Create(Self);
                try
                  if DataSource.DataSet is TIBCustomDataSet then
                    ibsql.Transaction := (DataSource.DataSet as TIBCustomDataSet).Transaction;

                  DidActivate := not (DataSource.DataSet as TIBCustomDataSet).Transaction.InTransaction;
                  if DidActivate then
                    (DataSource.DataSet as TIBCustomDataSet).Transaction.StartTransaction;
                  try
                    ibsql.SQL.Text :=
                      Format('DELETE FROM GD_ENTRYS WHERE documentkey = %d and positionkey = %d',
                      [DataSet.FieldByName(FieldDocumentKey).AsInteger, DataSet.FieldByName(FFieldKey).AsInteger]);
                    ibsql.ExecQuery;
                    ibsql.Close;
                  finally
                    if DidActivate then
                      ibsql.Transaction.Commit;
                  end;
                finally
                  ibsql.Free;
                end;
              end;
              if not isEdit then
                DataSet.Post;
            end
          end
          else
            if DataSet.FieldByName(FieldName).IsNull then
            begin
              ibsql := TIBSQL.Create(Self);
              try
                if DataSource.DataSet is TIBCustomDataSet then
                  ibsql.Transaction := (DataSource.DataSet as TIBCustomDataSet).Transaction;

                DidActivate := not (DataSource.DataSet as TIBCustomDataSet).Transaction.InTransaction;
                if DidActivate then
                  (DataSource.DataSet as TIBCustomDataSet).Transaction.StartTransaction;
                try
                  ibsql.SQL.Text :=
                    Format('DELETE FROM GD_ENTRYS WHERE positionkey = %d',
                    [DataSet.FieldByName(FFieldKey).AsInteger]);
                  ibsql.ExecQuery;
                  ibsql.Close;
                finally
                  if DidActivate then
                    ibsql.Transaction.Commit;
                end;
              finally
                ibsql.Free;
              end;
            end;

        if (DataSet.FieldByName(FieldName).AsInteger > 0) and
           (DataSet.FieldByName(FieldDocumentKey).AsInteger > 0)
        then
          CreateOneTransaction(DataSet.FieldByName(FieldDocumentKey).AsInteger,
            DataSet.FieldByName(FFieldKey).AsInteger,
            aCurrKey, DataSet.FieldByName(FieldName).AsInteger, aDocumentDate,
            aValueList, aAnalyzeList, DataSet, False);
        if not FDocumentOnly then
          DataSet.Next
        else
          Break;  
      end;
      Result := AppendEntryToBase;
    finally
      DataSet.EnableControls;
    end;
  end;
end;

{procedure TgsTransaction.CreateTransactionOnDataSetPos(const aCurrKey: Integer;
      const aDocumentDate: TDateTime;
      aValueList: TObjectList = nil; aAnalyzeList: TObjectList = nil;
      CheckTransaction: Boolean = False; OnlyWithTransaction: Boolean = False);
var
  DataSet: TDataSet;
  isEdit: Boolean;
  T: TTransaction;
  ibsql: TIBSQL;
begin
  if Assigned(FDataLink) and Assigned(FDataLink.DataSource) and
     Assigned(FDataLink.DataSource.DataSet) and (FDataLink.FieldName > '')
  then
  begin
    FTransactionDate := aDocumentDate;

    DataSet := FDataLink.DataSource.DataSet;
    DataSet.DisableControls;
    try
      {DataSet.First;
      while not DataSet.EOF do
      begin}
 {       if FDocumentOnly then
          try
            FTransactionDate := DataSet.FieldByName('documentdate').AsDateTime;
          except
            FTransactionDate := aDocumentDate;
          end;
        if not OnlyWithTransaction and (DataSet.FieldByName(FieldName).AsInteger = 0) then
        begin
          T := GetTransaction(nil);
          if Assigned(T) then
          begin
            isEdit := True;
            if not (DataSet.State in [dsEdit, dsInsert]) then
            begin
              isEdit := False;
              DataSet.Edit;
            end;
            DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey;
            if not isEdit then
              DataSet.Post;
          end;
        end
        else
          if CheckTransaction then
          begin
            T := GetTransaction(nil);
            if not isValidTransaction(DataSet.FieldByName(FieldName).AsInteger)
            then
            begin
              isEdit := True;
              if not (DataSet.State in [dsEdit, dsInsert]) then
              begin
                isEdit := False;
                DataSet.Edit;
              end;
              if Assigned(T) then
                DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey
              else
              begin
                DataSet.FieldByName(FieldName).Clear;
                ibsql := TIBSQL.Create(Self);
                try
                  ibsql.Transaction := FTransaction;
                  ibsql.SQL.Text :=
                    Format('DELETE FROM GD_ENTRYS WHERE positionkey = %d',
                    [DataSet.FieldByName(FFieldKey).AsInteger]);
                  ibsql.ExecQuery;
                  ibsql.Close;
                finally
                  ibsql.Free;
                end;
              end;
              if not isEdit then
                DataSet.Post;
            end
          end;

        if (DataSet.FieldByName(FieldName).AsInteger > 0) and
           (DataSet.FieldByName(FieldDocumentKey).AsInteger > 0)
        then
          CreateOneTransaction(DataSet.FieldByName(FieldDocumentKey).AsInteger,
            DataSet.FieldByName(FFieldKey).AsInteger,
            aCurrKey, DataSet.FieldByName(FieldName).AsInteger, aDocumentDate,
            aValueList, aAnalyzeList, DataSet, False);

      {  DataSet.Next
      end;}
  {    AppendEntryToBase;
    finally
      DataSet.EnableControls;
    end;
  end;
end;}

function TgsTransaction.GetPosTransaction(
  Index: Integer): TPositionTransaction;
begin
  if (Index >= 0) and (Index < PosTransactionCount) then
    Result := TPositionTransaction(FPosTransactionList[Index])
  else
    Result := nil;
end;

function TgsTransaction.GetPosTransactionCount: Integer;
begin
  if Assigned(FPosTransactionList) then
    Result := FPosTransactionList.Count
  else
    Result := 0;
end;

function TgsTransaction.CreateTransactionOnType(const aTransactionKey, aDocumentKey,
  aPositionKey: Integer; const aDate: TDateTime): TPositionTransaction;
var
  i, j: Integer;
begin
  Result := nil;
  for i:= 0 to FTransactionList.Count - 1 do
    if (TTransaction(FTransactionList[i]).TransactionKey = aTransactionKey) and
      (TTransaction(FTransactionList[i]).TypeEntryCount > 0)
    then
    begin

      Result := TPositionTransaction.Create(aTransactionKey,
        DocumentType, aDocumentKey, aPositionKey, TTransaction(FTransactionList[i]).TransactionName,
        TTransaction(FTransactionList[i]).Description, aDate,
        TTransaction(FTransactionList[i]).IsDocument);

      for j:= 0 to TTransaction(FTransactionList[i]).TypeEntryCount - 1 do
      begin
        Result.AddTypeEntry(TEntry.Create(TTransaction(FTransactionList[i]).TypeEntry[j], True));
      end;

      Break;

    end;

end;

procedure TgsTransaction.ReadTransactionOnPosition(const aDocumentCode,
  aPositionCode, aEntryKey: Integer);
var
  ibsql: TIBSQL;
  atSQLSetup: TatSQLSetup;
  TransactionKey: Integer;
  EntryKey: Integer;
  PosCode: Integer;

  Transaction: TPositionTransaction;
  Entry: TEntry;
  Account: TRealAccount;
  Description: String;

procedure MakeAnalyzeList;
var
  i: Integer;
  Value: Integer;
  FieldName_Type: String;
  FieldName_Value: String;
  S, FieldName: String;
  RelationField: TatRelationField;
begin
  S := ibsql.Current.Names;
  for i:= 0 to ibsql.Current.Count - 1 do
  begin
    if Pos(#13#10, S) > 0 then
    begin
      FieldName := copy(S, 1, Pos(#13, S) - 1);
      S := copy(S, Pos(#10, S) + 1, Length(S));
    end
    else
    begin
      FieldName := S;
      S := '';
    end;

    if Pos(UserPrefix, FieldName) > 0 then
    begin
      if copy(FieldName, Length(FieldName), 1) = '1' then
      begin
        FieldName_Type := FieldName;
        FieldName_Value := copy(FieldName, 1, Length(FieldName) - 1);
      end
      else
      begin
        FieldName_Value := FieldName;
        FieldName_Type := FieldName + '1';
      end;

      if (Pos(FieldName_Type, ibsql.Current.Names) > 0) and
         (ibsql.FieldByName(FieldName_Type).AsInteger = 1) then
      begin
        if ibsql.FieldByName(FieldName_Value).IsNull then
          Value := -1
        else
          Value := ibsql.FieldByName(FieldName_Value).AsInteger;

        RelationField := atDatabase.FindRelationField('GD_ENTRY', FieldName_Value);

        if  Assigned(RelationField) and Assigned(RelationField.References)
        then
          Account.AddAnalyze('', '', RelationField.References.RelationName,
            RelationField.FieldName, Value);
      end;

    end;

  end;
end;

begin
  ibsql := TIBSQL.Create(Self);
  try
    if DataSource.DataSet is TIBCustomDataSet then
      ibsql.Transaction := (DataSource.DataSet as TIBCustomDataSet).ReadTransaction;

    ibsql.SQL.Text :=
        'SELECT t.id as TransactionKey, t.name as TransactionName, t.Description as TransactionDesc, ' +
        '  e.EntryKey, e.Entrydate, e.debitsumncu, e.debitsumcurr, e.debitsumeq, ' +
        '  e.description as entrydesc, ' +
        '  e.creditsumncu, e.creditsumcurr, e.creditsumeq, e.accounttype, e.documentkey, ' +
        '  e.positionkey, e.currkey, c.id as AccountKey, c.multycurr, c.Alias, c.Name as AccountName ' +
        'FROM GD_ENTRYS E, GD_LISTTRTYPE T, '+
        '     GD_CARDACCOUNT C ';
        
    if aEntryKey = -1 then
    begin
      if aPositionCode = -1 then
        ibsql.SQL.Text := ibsql.SQL.Text +
          Format(
            ' WHERE E.TRTYPEKEY = T.ID AND E.DOCUMENTKEY = %d'+
            '       AND E.ACCOUNTKEY = C.ID ' ,
            [aDocumentCode])
      else
        ibsql.SQL.Text := ibsql.SQL.Text +
          Format(
            ' WHERE E.TRTYPEKEY = T.ID AND E.DOCUMENTKEY = %d AND E.POSITIONKEY = %d '+
            '       AND E.ACCOUNTKEY = C.ID ' ,
            [aDocumentCode, aPositionCode]);
    end
    else
      ibsql.SQL.Text := ibsql.SQL.Text +
        Format(
          'WHERE E.TRTYPEKEY = T.ID AND E.ENTRYKEY = %D AND E.ACCOUNTKEY = C.ID',
          [aEntryKey]);

    if MakeDelayedEntry then
      ibsql.SQL.Text := ibsql.SQL.Text + ' AND E.DELAYEDENTRY = 1 '
    else
      ibsql.SQL.Text := ibsql.SQL.Text + ' AND E.DELAYEDENTRY = 0 ';

    ibsql.SQL.Text := ibsql.SQL.Text + ' ORDER BY t.id, e.entrykey, e.accounttype';

    atSQLSetup := TatSQLSetup.Create(Self);
    try
      ibsql.SQL.Text := atSQLSetup.PrepareSQL(ibsql.SQL.Text);
    finally
      atSQLSetup.Free;
    end;

    ibsql.ExecQuery;

    FPosTransactionList.Clear;

    TransactionKey := -1;
    PosCode := -1;
    EntryKey := -1;

    Transaction := nil;
    Entry := nil;

    while not ibsql.Eof do
    begin

      if (ibsql.FieldByName('positionkey').AsInteger <> PosCode) or
         (ibsql.FieldByName('TransactionKey').AsInteger <> TransactionKey)
      then
      begin
        if Assigned(Transaction) and Assigned(Entry) then
        begin
          Transaction.AddRealEntry(Entry);
          FPosTransactionList.Add(Transaction);
          Entry := nil;
        end;

        TransactionKey := ibsql.FieldByName('TransactionKey').AsInteger;
        PosCode := ibsql.FieldByName('PositionKey').AsInteger;

        Transaction := CreateTransactionOnType(
          ibsql.FieldByName('TransactionKey').AsInteger,
          ibsql.FieldByName('DocumentKey').AsInteger,
          ibsql.FieldByName('PositionKey').AsInteger,
          ibsql.FieldByName('entrydate').AsDateTime);

      end;

      if Transaction <> nil then
      begin

        if ibsql.FieldByName('EntryKey').AsInteger <> EntryKey then
        begin
          Description := ibsql.FieldByName('entrydesc').AsString;
          if Assigned(Entry) then
            Transaction.AddRealEntry(Entry);
          EntryKey := ibsql.FieldByName('EntryKey').AsInteger;
          Entry := TEntry.Create(EntryKey,
           ibsql.FieldByName('DocumentKey').AsInteger,
           ibsql.FieldByName('PositionKey').AsInteger,
           ibsql.FieldByName('entrydate').AsDateTime);
        end;

  { Заполняем информацию по счету }

        if ibsql.FieldByName('accounttype').AsString = 'D' then
          Account := TRealAccount.Create(
            ibsql.FieldByName('AccountKey').AsInteger,
            ibsql.FieldByName('Alias').AsString,
            ibsql.FieldByName('AccountName').AsString,
            ibsql.FieldByName('debitsumncu').AsCurrency,
            ibsql.FieldByName('debitsumcurr').AsCurrency,
            ibsql.FieldByName('debitsumeq').AsCurrency,
            ibsql.FieldByName('multycurr').AsInteger = 1,
            ibsql.FieldByName('currkey').AsInteger)
        else
          Account := TRealAccount.Create(
            ibsql.FieldByName('AccountKey').AsInteger,
            ibsql.FieldByName('Alias').AsString,
            ibsql.FieldByName('AccountName').AsString,
            ibsql.FieldByName('creditsumncu').AsCurrency,
            ibsql.FieldByName('creditsumcurr').AsCurrency,
            ibsql.FieldByName('creditsumeq').AsCurrency,
            ibsql.FieldByName('multycurr').AsInteger = 1,
            ibsql.FieldByName('currkey').AsInteger);

  { Формируем список аналитики }

        MakeAnalyzeList;

        Entry.AddEntryLine(Account, ibsql.FieldByName('accounttype').AsString = 'D',
          Description);

        Description := '';
      end;
      ibsql.Next;
    end;

    if Assigned(Transaction) and Assigned(Entry) then
    begin
      Transaction.AddRealEntry(Entry);
      FPosTransactionList.Add(Transaction);
    end;
  finally
    ibsql.Free;
  end;
end;

function TgsTransaction.GetTransactionName(
  const TransactionKey: Integer): String;
var
  T: TTransaction;
begin
  Result := '';
  T := GetTransactionByKey(TransactionKey);
  if Assigned(T) then
    Result := T.TransactionName;
end;

procedure TgsTransaction.AddConditionDataSet(aDataSets: array of TIBCustomDataSet);
var
  i: Integer;
begin
  for i:= Low(aDataSets) to High(aDataSets) do
    FConditionDataSetList.Add(aDataSets[i]);
  MakeTransactionRelationFields;  
end;

function TgsTransaction.IsValidTransaction(
  const aTransactionKey: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to CurTransactionCount - 1 do
    if CurTransaction[i].TransactionKey = aTransactionKey then
    begin
      Result := True;
      Break;
    end;
end;

function TgsTransaction.IsValidDocTransaction(const aTransactionKey: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to FTransactionList.Count - 1 do
    if TTransaction(FTransactionList[i]).TransactionKey = aTransactionKey then
    begin
      Result := True;
      Break;
    end;
end;

procedure TgsTransaction.SetTransactionOnDataSet;
var
  Bookmark: TBookmark;
  T: TTransaction;
begin
  if not Assigned(DataSource) or not Assigned(DataSource.DataSet) or
     (FieldName = '')
  then exit;
  Bookmark := DataSource.DataSet.GetBookmark;
  DataSource.DataSet.DisableControls;
  try
    DataSource.DataSet.First;
    while not DataSource.DataSet.EOF do
    begin
      T := GetTransaction(nil);
      if T <> nil then
      begin
        DataSource.DataSet.Edit;
        DataSource.DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey;
        if FieldTrName > '' then
          DataSource.DataSet.FieldByName(FieldTrName).AsString := T.TransactionName;
        DataSource.DataSet.Post;
      end;
      DataSource.DataSet.Next;
    end;
  finally
    DataSource.DataSet.GotoBookmark(Bookmark);
    DataSource.DataSet.FreeBookmark(Bookmark);
    DataSource.DataSet.EnableControls;
  end;
end;

function TgsTransaction.SetAnalyzeControl(const aTransactionKey: Integer;
  Sender: TWinControl; FOnChange: TNotifyEvent; FTransaction: TIBTransaction): TWinControl;
var
  AnalyzeList: TList;
  i: Integer;
  lab: TLabel;
  gsiblc: TgsIBLookupComboBox;
  H: Integer;
  R: TatRelation;
begin
  AnalyzeList := TList.Create;
  try
    GetAnalyzeList(aTransactionKey, AnalyzeList);
    for i:= 0 to Sender.ControlCount - 1 do
      Sender.Controls[0].Free;

    H := 2;
    Result := nil;
    for i:= 0 to AnalyzeList.Count - 1 do
    begin
      R := atDatabase.Relations.ByRelationName(TAnalyze(AnalyzeList[i]).ReferencyName);
      if Assigned(R) then
      begin
        lab := TLabel.Create(Owner);
        lab.Name := Format('USRLabel%d', [i]);
        Sender.InsertControl(lab);
        lab.Left := 5;
        lab.Top := H + 4;
        lab.Caption := R.LName;



        gsiblc := TgsIBLookupComboBox.Create(Owner);
        gsiblc.Name := Format('USRgsIBLookupComboBox%d', [i]);
        gsiblc.Text := '';
        {!!!!!!!!!!!}
        gsiblc.Transaction := FTransaction;
        Sender.InsertControl(gsiblc);
        gsiblc.Left := 10 + lab.Canvas.TextWidth(lab.Caption);
        gsiblc.Top := H;
        gsiblc.Width := Sender.Width - gsiblc.Left - 10;
        gsiblc.ListTable := R.RelationName;
        gsiblc.KeyField := R.PrimaryKey.ConstraintFields[0].FieldName;
        gsiblc.ListField := R.ListField.FieldName;
        gsiblc.OnChange := FOnChange;

        if TAnalyze(AnalyzeList[i]).ValueAnalyze > 0 then
          gsiblc.CurrentKeyInt := TAnalyze(AnalyzeList[i]).ValueAnalyze;

        if not Assigned(Result) then
          Result := gsiblc;
        H := H + gsiblc.Height + 5;
      end;
    end;
  finally
    AnalyzeList.Free;
  end;
end;

procedure TgsTransaction.GetAnalyzeList(const aTransactionKey: Integer;
  aAnalyzeList: TList);
var
  aTransaction: TTransaction;
  i, j, k: Integer;

function IsNewAnalyze(aAnalyze: TAnalyze): Boolean;
var
  l: Integer;
begin
  Result := True;
  for l:= 0 to aAnalyzeList.Count - 1 do
    if (Trim(TAnalyze(aAnalyzeList[l]).ReferencyName) = Trim(aAnalyze.ReferencyName)) and
       (Trim(TAnalyze(aAnalyzeList[l]).FieldName) = Trim(aAnalyze.FieldName))
    then
    begin
      Result := False;
      Break;
    end;

end;

begin
  aTransaction := nil;
  aAnalyzeList.Clear;

  if PosTransactionCount = 0 then
  begin
    for i:= 0 to FTransactionList.Count - 1 do
      if TTransaction(FTransactionList[i]).TransactionKey = aTransactionKey then
      begin
        aTransaction := TTransaction(FTransactionList[i]);
        Break;
      end;

    if Assigned(aTransaction) then
    begin
      for i:= 0 to aTransaction.TypeEntryCount - 1 do
      begin
        for j:= 0 to aTransaction.TypeEntry[i].DebitCount - 1 do
        begin
          for k:= 0 to aTransaction.TypeEntry[i].Debit[j].CountAnalyze - 1 do
            if isNewAnalyze(aTransaction.TypeEntry[i].Debit[j].AnalyzeItem[k]) then
              aAnalyzeList.Add(aTransaction.TypeEntry[i].Debit[j].AnalyzeItem[k]);
        end;

        for j:= 0 to aTransaction.TypeEntry[i].CreditCount - 1 do
        begin
          for k:= 0 to aTransaction.TypeEntry[i].Credit[j].CountAnalyze - 1 do
            if isNewAnalyze(aTransaction.TypeEntry[i].Credit[j].AnalyzeItem[k]) then
              aAnalyzeList.Add(aTransaction.TypeEntry[i].Credit[j].AnalyzeItem[k]);
        end;
      end;
    end;

  end
  else
  begin
    for i:= 0 to PosTransactionCount - 1 do
      if PosTransaction[i].TransactionKey = aTransactionKey then
      begin
        aTransaction := PosTransaction[i];
        Break;
      end;

  { DONE 1 -oденис -cпросто : Приведение к типу через AS!!!!!!!! }
    if Assigned(aTransaction) then
    begin
      for i:= 0 to (aTransaction as TPositionTransaction).RealEntryCount - 1 do
      begin
        for j:= 0 to (aTransaction as TPositionTransaction).RealEntry[i].DebitCount - 1 do
        begin
          for k:= 0 to (aTransaction as TPositionTransaction).RealEntry[i].Debit[j].CountAnalyze - 1 do
            if isNewAnalyze((aTransaction as TPositionTransaction).RealEntry[i].Debit[j].AnalyzeItem[k]) then
              aAnalyzeList.Add((aTransaction as TPositionTransaction).RealEntry[i].Debit[j].AnalyzeItem[k]);
        end;

        for j:= 0 to (aTransaction as TPositionTransaction).RealEntry[i].CreditCount - 1 do
        begin
          for k:= 0 to (aTransaction as TPositionTransaction).RealEntry[i].Credit[j].CountAnalyze - 1 do
            if isNewAnalyze((aTransaction as TPositionTransaction).RealEntry[i].Credit[j].AnalyzeItem[k]) then
              aAnalyzeList.Add((aTransaction as TPositionTransaction).RealEntry[i].Credit[j].AnalyzeItem[k]);
        end;
      end;
    end;
  end;

end;

procedure TgsTransaction.SetAnalyzeAndValue(aDataSet: TDataSet;
  ValueList, AnalyzeList: TObjectList);
var
  i: Integer;
  R: TatRelationField;
  Val: Currency;
begin
  for i:= 0 to aDataSet.FieldCount - 1 do
  begin

    R := atDatabase.FindRelationField(
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[i].FieldName).AsXSQLVAR.relname),
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[i].FieldName).AsXSQLVAR.sqlname));

    if Assigned(R) then
    begin
      if Assigned(AnalyzeList) and
        (aDataSet.Fields[i].DataType in [ftSmallInt, ftInteger, ftWord, ftLargeInt]) then
      begin
        if Assigned(R.References) then
          AnalyzeList.Add(TAnalyze.Create(
            R.Relation.RelationName,
            R.FieldName,
            Trim(R.References.RelationName), '',
            aDataSet.Fields[i].AsInteger))
        else
          AnalyzeList.Add(TAnalyze.Create(
            R.Relation.RelationName,
            R.FieldName,
            Trim(R.Relation.RelationName), '',
            aDataSet.Fields[i].AsInteger))

      end;
      
      if Assigned(ValueList) then
      begin
        try
          Val := aDataSet.Fields[i].AsCurrency;
          ValueList.Add(TValue.Create(Trim(R.Relation.RelationName),
            Trim(R.FieldName), Val));
        except
        end;
      end;  
    end;
  end;

end;


(*

 При создании проводки по отложенным проводкам необходимо:
  1. Считать отложенные проводки
  2. Пересчитать сумму проводок
  3. Подставить эту сумму в отложенные проводки
  4. Поменять дату и коды документов
  5. Занести полученные проводки в базу

*)

procedure TgsTransaction.CreateTransactionByDelayedTransaction(
  const aTransactionKey, aFromDocumentKey, aToDocumentKey,
  aFromPositionKey, aToPositionKey: Integer;
  const aDocumentDate: TDateTime;
  aValueList: TObjectList = nil);
var
  OldMakeDelayedEntry: Boolean;
  i: Integer;
  ValueList: TObjectList;
begin

  OldMakeDelayedEntry := FMakeDelayedEntry;
  FMakeDelayedEntry := True;
  ValueList := TObjectList.Create;

  try

{ Заполняем ValueList значениями из текущего FCondition и передаными значениями }

    if Assigned(aValueList) then
      for i:= 0 to aValueList.Count - 1 do
        ValueList.Add(TValue.Create(TValue(aValueList[i])));

    for i := 0 to FConditionDataSetList.Count - 1 do
      SetAnalyzeAndValue(TDataSet(FConditionDataSetList[i]), ValueList, nil);

{ Считываем отложенные позиции }

    ReadTransactionOnPosition(aFromDocumentKey, aFromPositionKey, -1);

{ Заменяем сумма в операции }

    for i:= 0 to PosTransactionCount - 1 do
      PosTransaction[i].ChangeValue(aToDocumentKey, aToPositionKey, aDocumentDate, aValueList);

    FMakeDelayedEntry := False;

    AppendEntryToBase;

  finally
    FMakeDelayedEntry := OldMakeDelayedEntry;
  end;


end;



procedure TgsTransaction.CreateOneTransaction(const aDocumentKey,
  aPositionKey, aCurrKey, aTransactionKey: Integer;
  const aDocumentDate: TDateTime; aValueList, aAnalyzeList: TObjectList;
  aDataSet: TDataSet; isEditTransaction: Boolean);
var
  ValueList: TObjectList;
  AnalyzeList: TObjectList;
  i: Integer;

begin

  ValueList := TObjectList.Create;
  AnalyzeList := TObjectList.Create;
  try
    if aTransactionKey > 0 then
    begin

      if Assigned(aValueList) then
        for i:= 0 to aValueList.Count - 1 do
          ValueList.Add(TValue.Create(TValue(aValueList[i])));

      if Assigned(aAnalyzeList) then
        for i:= 0 to aAnalyzeList.Count - 1 do
          AnalyzeList.Add(TAnalyze.Create(
            TAnalyze(aAnalyzeList[i]).FromTableName,
            TAnalyze(aAnalyzeList[i]).FromFieldName,
            TAnalyze(aAnalyzeList[i]).ReferencyName,
            '', TAnalyze(aAnalyzeList[i]).ValueAnalyze));

      for i := 0 to FConditionDataSetList.Count - 1 do
        if FConditionDataSetList[i] <> aDataSet then
          SetAnalyzeAndValue(TDataSet(FConditionDataSetList[i]), ValueList, AnalyzeList);

      if Assigned(aDataSet) then
        SetAnalyzeAndValue(aDataSet, ValueList, AnalyzeList);

      SetRealEntry(aDocumentKey,
        aPositionKey, aTransactionKey,
        aDocumentDate, ValueList, AnalyzeList, aCurrKey, isEditTransaction);

    end;
  finally
    ValueList.Free;
    AnalyzeList.Free;
  end;
end;

procedure TgsTransaction.DoAfterOpen(DataSet: TDataSet);
begin
  if Assigned(FOldAfterOpen) then FOldAfterOpen(DataSet);

  if (BeginTransactionType = btAfterOpen) then
    SetStartTransactionInfo;
end;

procedure TgsTransaction.DoBeforePost(DataSet: TDataSet);
var
  T: TTransaction;
begin
  if Assigned(FOldBeforePost) then
    FOldBeforePost(DataSet);

  if (SetTransactionType = stBeforePost) and (DataSet.FindField(FieldName) <> nil) then
  begin
    T := GetTransaction(nil);
    if Assigned(T) then
    begin
      if DataSet.FieldByName(FieldName).IsNull or
          not IsValidTransaction(DataSet.FieldByName(FieldName).AsInteger)
      then
      begin
        DataSet.FieldByName(FieldName).AsInteger := T.TransactionKey;
        if DataSet.FindField(FFieldTrName) <> nil then
          DataSet.FieldByName(FFieldTrName).AsString := T.TransactionName;
      end;
    end
    else
      DataSet.FieldByName(FieldName).Clear;
  end;
end;

procedure TgsTransaction.MakeTransactionRelationFields;
var
  i, k, l: Integer;
  DataSet: TDataSet;

procedure Add(FC: TFilterCondition; TypeRelation: TTypeRelation);
var
  j, Index: Integer;
begin
  Index := -1;
  for j:= 0 to FTransactionRelationFieldList.Count - 1 do
  begin
    if (TTransactionRelationField(FTransactionRelationFieldList[j]).RelationName =
       FC.FieldData.TableName) and
       (TTransactionRelationField(FTransactionRelationFieldList[j]).FieldName =
       FC.FieldData.FieldName)
    then
    begin
      Index := j;
      Break;
    end;
  end;
  if Index = -1 then
    FTransactionRelationFieldList.Add(TTransactionRelationField.Create(FC.FieldData.TableName,
      FC.FieldData.FieldName, TypeRelation))
  else
    TTransactionRelationField(FTransactionRelationFieldList[Index]).AddTypeRelation(TypeRelation);
end;

procedure AddField(TableName, FieldName: String; TypeRelation: TTypeRelation);
var
  j, Index: Integer;
begin
  Index := -1;
  for j:= 0 to FTransactionRelationFieldList.Count - 1 do
  begin
    if (TTransactionRelationField(FTransactionRelationFieldList[j]).RelationName =
       TableName) and
       (TTransactionRelationField(FTransactionRelationFieldList[j]).FieldName =
       FieldName)
    then
    begin
      Index := j;
      Break;
    end;
  end;
  if Index = -1 then
    FTransactionRelationFieldList.Add(TTransactionRelationField.Create(TableName,
      FieldName, TypeRelation))
  else
    TTransactionRelationField(FTransactionRelationFieldList[Index]).AddTypeRelation(TypeRelation);
end;


procedure AddAnalyze(Account: TAccount);
var
  j: Integer;
begin
  for j:= 0 to Account.CountAnalyze - 1 do
  begin
    if (Account.AnalyzeItem[j].FromTableName = '') or (Account.AnalyzeItem[j].FromFieldName = '')
    then
      FTransactionRelationFieldList.Add(TTransactionRelationField.Create(
        Account.AnalyzeItem[j].ReferencyName, '', trAnalyze))
    else
      FTransactionRelationFieldList.Add(TTransactionRelationField.Create(
        Account.AnalyzeItem[j].FromTableName, Account.AnalyzeItem[j].FromFieldName, trAnalyze))

  end;
end;

function isRelationField(const TableName, FieldName: String): Integer;
var
  j: Integer;
  R: TatRelationField;
begin
  Result := -1;
  for j:= 0 to FTransactionRelationFieldList.Count - 1 do

    if (TTransactionRelationField(FTransactionRelationFieldList[j]).RelationName = TableName)
       and
       (TTransactionRelationField(FTransactionRelationFieldList[j]).FieldName = FieldName)
    then
    begin
      Result := j;
      Break;
    end;
    
  if Result = -1 then
  begin
    for j:= 0 to FTransactionRelationFieldList.Count - 1 do
      if TTransactionRelationField(FTransactionRelationFieldList[j]).FieldName = '' then
      begin
        R := atDatabase.FindRelationField(TableName, FieldName);
        if Assigned(R) and Assigned(R.References) and (R.References.RelationName =
           TTransactionRelationField(FTransactionRelationFieldList[j]).RelationName)
        then
        begin
          Result := -10000;
          Break;
        end;
      end;
  end;
end;

function IsUseVariable(const aVariable: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to FTransactionList.Count - 1 do
    if TTransaction(FTransactionList[i]).IsUseVariable(aVariable) then
    begin
      Result := True;
      Break;
    end;
end;

procedure CheckChangedField(aDataSet: TDataSet);
var
  j, Index: Integer;
  R: TatRelationField;
  E1, E2: TFieldNotifyEvent;
begin
  for j:= 0 to aDataSet.FieldCount - 1 do
  begin
    R := atDatabase.FindRelationField(
    StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.relname),
    StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.sqlname));

    if Assigned(R) and (R.Relation.LShortName > '') and (R.LShortName > '') and
       IsUseVariable(Trim(R.Relation.LShortName) + '_' + Trim(R.LShortName))
    then
      AddField(
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.relname),
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.sqlname), trValue);

    Index := isRelationField(
    StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.relname),
    StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.sqlname));

    if Index = -10000 then
    begin
      AddField(
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.relname),
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.sqlname), trAnalyze);

      Index := isRelationField(
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.relname),
      StrPas(TIBCustomDataSetCracker(aDataSet).QSelect.Current.ByName(aDataSet.Fields[j].FieldName).AsXSQLVAR.sqlname));
    end;

    if Index > -1 then
    begin
      E1 := DoOnChangeField;
      E2 := aDataSet.Fields[j].OnChange;
      if @E1 <> @E2 then
        TTransactionRelationField(FTransactionRelationFieldList[Index]).OldOnChange :=
          aDataSet.Fields[j].OnChange;
      aDataSet.Fields[j].OnChange := DoOnChangeField;
    end;
  end;
end;

begin
  if Assigned(FTransactionList) then
  begin
    if Assigned(DataSource) and Assigned(DataSource.DataSet) and DataSource.DataSet.Active then
      DataSet := DataSource.DataSet
    else
      exit;

    for i:= 0 to FTransactionList.Count - 1 do
    begin
      for k:= 0 to TTransaction(FTransactionList[i]).TransactionFilterData.ConditionList.Count - 1 do
      begin
        Add(TFilterCondition(
          TTransaction(FTransactionList[i]).TransactionFilterData.ConditionList[k]),
            trCondition);
      end;
      for k:= 0 to TTransaction(FTransactionList[i]).TypeEntryCount - 1 do
      begin
        for l:= 0 to TTransaction(FTransactionList[i]).TypeEntry[k].DebitCount - 1 do
          AddAnalyze(TTransaction(FTransactionList[i]).TypeEntry[k].Debit[l]);
        for l:= 0 to TTransaction(FTransactionList[i]).TypeEntry[k].CreditCount - 1 do
          AddAnalyze(TTransaction(FTransactionList[i]).TypeEntry[k].Credit[l]);
      end;
    end;

    for i:= 0 to FConditionDataSetList.Count - 1 do
    begin
      if FConditionDataSetList[i] <> DataSet then
        CheckChangedField(TDataSet(FConditionDataSetList[i]));
    end;

    if Assigned(DataSet) then
      CheckChangedField(DataSet);


  end;
end;

procedure TgsTransaction.DoOnChangeField(Sender: TField);
var
  T: TPositionTransaction;
  CurT: TTransaction;
  TableName: String;
  CurFieldName: String;
  CurField: Integer;
  TypeRelations: TTypeRelations;
  isValid: Boolean;
  E1, E2: TFieldNotifyEvent;

function SearchTypeRelation: TTypeRelations;
var
  i: Integer;
  R: TatRelationField;
begin
  CurField := -1;
  Result := [trNone];
  for i:= 0 to FTransactionRelationFieldList.Count - 1 do
    if (TTransactionRelationField(FTransactionRelationFieldList[i]).RelationName = TableName)
        and
       (TTransactionRelationField(FTransactionRelationFieldList[i]).FieldName = CurFieldName)
    then
    begin
      Result := TTransactionRelationField(FTransactionRelationFieldList[i]).TypeRelations;
      CurField := i;
      Break;
    end;

  if Result = [trNone] then
  begin

    R := atDatabase.FindRelationField(TableName, CurFieldName);

    if Assigned(R) and Assigned(R.References) then
    
      for i:= 0 to FTransactionRelationFieldList.Count - 1 do
        if (TTransactionRelationField(FTransactionRelationFieldList[i]).RelationName =
            R.References.RelationName)
            and
           (TTransactionRelationField(FTransactionRelationFieldList[i]).FieldName = '')
        then
        begin
          Result := TTransactionRelationField(FTransactionRelationFieldList[i]).TypeRelations;
          CurField := i;
          Break;
        end;

  end;

end;

begin
  Assert(Assigned(Sender.DataSet), 'Полю незадан DataSet!');

  try

    TableName :=
      StrPas(TIBCustomDataSetCracker(Sender.DataSet).QSelect.Current.ByName(Sender.FieldName).AsXSQLVAR.relname);
    CurFieldName :=
      StrPas(TIBCustomDataSetCracker(Sender.DataSet).QSelect.Current.ByName(Sender.FieldName).AsXSQLVAR.sqlname);

    TypeRelations := SearchTypeRelation;

    if Sender.OldValue <> Sender.NewValue then
    begin

      if TypeRelations <> [trNone] then
      begin

        if trCondition in TypeRelations then
          CurT := GetTransaction(nil)
        else
          CurT := nil;

        if Assigned(DataSource) and Assigned(DataSource.DataSet) and
           (DataSource.DataSet = Sender.DataSet)
        then
        begin

          if (trCondition in TypeRelations) and (FieldName > '') and
             not Sender.DataSet.FieldByName(FieldName).IsNull and
             not isValidTransaction(Sender.DataSet.FieldByName(FieldName).AsInteger)
          then
          begin
            if Assigned(CurT) then
              Sender.DataSet.FieldByName(FieldName).AsInteger := CurT.TransactionKey
            else
              Sender.DataSet.FieldByName(FieldName).Clear;
            isValid := False;
          end
          else
            isValid := True;

          if (FFieldKey > '') and (FFieldDocumentKey > '') then
          begin
            T := SearchPositionTransaction(DataSource.DataSet.FieldByName(FFieldDocumentKey).AsInteger,
                   DataSource.DataSet.FieldByName(FFieldKey).AsInteger);

            if Assigned(T) then
              T.TransactionChanged := True;

            if Assigned(T) and not isValid then
              FPosTransactionList.Remove(T);

          end;

        end
        else
          FChanged := True;

      end;
    end;
  finally
    if (CurField <> -1) and
       Assigned(TTransactionRelationField(FTransactionRelationFieldList[CurField]).OldOnChange)
    then
    begin
      E1 := DoOnChangeField;
      E2 := TTransactionRelationField(FTransactionRelationFieldList[CurField]).OldOnChange;
      if @E1 <> @E2 then
        TTransactionRelationField(FTransactionRelationFieldList[CurField]).OldOnChange(Sender);
    end;
  end;
end;

function TgsTransaction.GetTransactionByKey(const aTransactionKey: Integer): TTransaction;
var
  i: Integer;
begin
  Result := nil;
  if Assigned(FTransactionList) then
    for i:= 0 to FTransactionList.Count - 1 do
      if TTransaction(FTransactionList[i]).TransactionKey = aTransactionKey then
      begin
        Result := TTransaction(FTransactionList[i]);
        Break;
      end;
end;

function TgsTransaction.SearchPositionTransaction(const aDocumentKey,
  aPositionKey: Integer): TPositionTransaction;
var
  i: Integer;
begin
  Result := nil;
  for i:= 0 to PosTransactionCount - 1 do
    if (PosTransaction[i].DocumentCode = aDocumentKey) and
       (PosTransaction[i].PositionCode = aPositionKey)
    then
    begin
      Result := PosTransaction[i];
      Break;
    end;
end;

procedure TgsTransaction.DoAfterPost(DataSet: TDataSet);
begin
  if Assigned(FOldAfterPost) then FOldAfterPost(DataSet);
  if FEndTransactionType = etAfterPost then
    CreateTransactionOnDataSet(CurrencyKey, TransactionDate);
end;

function TgsTransaction.SetTransactionStrings(Value: TStrings; aTransactionKey: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if Assigned(Value) then
  begin
    Value.Clear;
    for i:= 0 to CurTransactionCount - 1 do
    begin
      Value.AddObject(CurTransaction[i].TransactionName, CurTransaction[i]);
      if CurTransaction[i].TransactionKey = aTransactionKey then
        Result := i;
    end;
  end;
end;

function TgsTransaction.IsCurrencyTransaction(
  const aTransactionKey: Integer): Boolean;
var
  T: TTransaction;
begin
  T := GetTransactionByKey(aTransactionKey);
  if Assigned(T) then
    Result := T.IsCurrencyTransaction
  else
    Result := False;
end;

procedure TgsTransaction.Refresh;
begin
  if FTransactionList.Count = 0 then
    SetStartTransactionInfo;
  MakeTransactionRelationFields;
end;


procedure TgsTransaction.SetEndTransactionType(
  const Value: TEndTransactionType);
begin
  FEndTransactionType := Value;
end;

procedure TgsTransaction.SetSetTransactionType(
  const Value: TSetTransactionType);
begin
  FSetTransactionType := Value;
end;

procedure TgsTransaction.DeleteTransaction(const DocKey, PosKey: Integer);
var
  i: Integer;
begin
  for i:= 0 to PosTransactionCount - 1 do
    if (PosTransaction[i].DocumentCode = DocKey) and
       (PosTransaction[i].PositionCode = PosKey)
    then
    begin
      FPosTransactionList.Delete(i);
      Break;
    end;
end;



{ Register }

procedure Register;
begin
  RegisterComponents('gsNew', [TgsTransaction]);
end;


end.
