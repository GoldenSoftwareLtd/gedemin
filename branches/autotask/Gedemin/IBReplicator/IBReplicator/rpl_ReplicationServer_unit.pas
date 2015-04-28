unit rpl_ReplicationServer_unit;

interface
uses rpl_BaseTypes_unit, Classes, rpl_ResourceString_unit, SysUtils, IBSQL, DB,
  rpl_const, Contnrs, rpl_ProgressState_Unit,
  rpl_GlobalVars_unit, IBStoredProc, Controls, Dialogs;

type
  TrpForeignKeys = class;
  TrpTriggers = class;
  TrpRingFKs = class;

  TrplReplicationServer = class(TObject, IConnectChangeNotify)
  private
    FCorDbKey: Integer;
    FReplLog: TReplLog;
    FCortege: TrpCortege;
    FEvent: TrpEvent;
    //Ключ обрабатываемог или формируемого файла реплики
    FReplKey: Integer;
    //Текущее занчение счетчика файлов реплики
    FCurrReplKey: Integer;
    FStreamHeader: TrplStreamHeader;

    FIgnoreError: Boolean;
    //Признак того, что ошибка уже обрабатывалась
    FErrorProcessed: Boolean;
    //Список событий при обработке которых возникла ошибка
    FErrorList: TrpErrorList;

    //Список сообщений об ошибках
    FErrors: TStrings;

    FForeignKeys: TrpForeignKeys;
    FTriggers: TrpTriggers;

    FPreserve: Boolean;
    FRelationKey: Integer;
    //Указатедь на ошибку обрабатываемую вданный момент.
    //Используется при разрешении конфликтных ситуаций
    FError: TrpError;
    //Если данное свойство равно тру, то все неразрешенные конфликты записывать
    //в таблицу rpl$manual_log в противном случае выводится окно для ручного
    //разрешения конфликтов
    FErrorToManualLog: Boolean;

    FUpdateIDSQL: TIBSQL;
    FUpdateRUIDSQL: TIBSQL;
    FDeleteRUIDSQL: TIBSQL;
    FDeletedRUIDCount: integer;

    FIULog: boolean;
    FDLog: boolean;

    FFKsToDrop: TStringList;
    FRingFKs: TrpRingFKs;
    FReplRelations: TStringList;

    procedure SetCorDbKey(const Value: Integer);
    procedure PrepareLog(ReplKey: Integer);
    procedure PrepareGDRUID;
    procedure CheckStreamHeader;
    procedure SaveFKsToDrop(Stream: TStream);
    procedure LoadFKsToDrop(Stream: TStream);
    procedure SaveStreamHeader(Stream: TStream);
    procedure LoadStreamHeader(Stream: TStream);
    procedure BeginRepl;
    procedure EndRepl;
    //Обработчик ошибок
    procedure OnPostError(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
    procedure OnDeleteError(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
    procedure OnPostErrorManual(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
    procedure OnDeleteErrorManual(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
    procedure OnPostRingFKError(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
    //Запоминаем изменения для которого прозошла ошибка
    procedure CollectError(ErrorCode: Integer; ErrorDescription: string);
    {$IFDEF DEBUG}
    procedure CheckInTransaction;
    {$ENDIF}
  protected
    function CheckCortegeRingFKs: boolean;

    procedure CheckUpdateIDSQL(RelName: string);
    procedure CheckUpdateRUIDSQL;
    function  GetUpdateRUIDSQL: string;
    procedure CheckDeleteRUIDSQL;
    function  GetDeleteRUIDSQL: string;
    function  RecordWithIDExists(ID: integer; out RelName: string): boolean;
    //Сохраняет данные экспорта в поток
    function DoExport(Stream: TStream): Boolean;
    function DoImport(Stream: TStream): Boolean;
    function DoExportConfirm(Stream: TStream): Boolean;
    function DoImportConfirm(Stream: TStream): Boolean;
    //Производит откат передач изменений для базы с указанным ИД
    function DoRollBack(DbKey, RollBackCount: Integer): Integer;
    //Делает  репликацию одного события
    procedure DoReplEvent(Stream: TStream);

    function DoConflictResolition(DBKey: Integer): boolean;
    //Возвращает Тру если в журнале событий есть информация о том
    //что запись с данным ключом была изменена.
    //В NewKey возвращается новый ключ записи если запись изменялась
    function RecordChanged(lKey: String; out NewKey: string; RelationKey: Integer): Boolean;
    function RecordDeleted(Key: string; RelationKey: Integer): boolean;
    //Разрешение конфликтных ситуаций
    //Возвращает Тру если необходимо изменить
    function ConflictResolution: Boolean; overload;
    function ConflictResolutionPriority: Boolean;
    function ConflictResolutionTime: Boolean;
    function ConflictResolutionManual: Boolean;
    function ConflictResolutionServer: Boolean;
    //Ручное разрешение конфликтных ситуаций.
    //Возвращает ТРУ, если все конфликты разрешены
    function ConflictResolutioning: Boolean;

    procedure ExecuteSProcedures;
    procedure ExecuteMakeRestProcedure;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;
    procedure AutoConflictResolution(Sender: TObject);

    procedure ProcessRingFKs;
  public
    constructor Create;
    destructor Destroy; override;
    function ExportData(Stream: TStream; CorDBKey: Integer): Boolean;
    function ExportConfirm(Stream: TStream; CorDBKey: Integer): Boolean;
    function ImportData(Stream: TStream; ErrorToManualLog: Boolean = False): Boolean;
    function ImportConfirm(Stream: TStream; ErrorToManualLog: Boolean = False): Boolean;
    function RollBack(DBKey: Integer; Count: Integer): Boolean;
    function RestoreDB: Boolean;
    function ConflictResolution(DBKey: Integer): Boolean; overload;
    //Ключ корреспондирующей базы данных
    property CorDbKey: Integer read FCorDbKey write SetCorDbKey;
  end;

  //Список отключаемых внешних ссылок
  TrpRingFK = class
  private
    FSeqNo: integer;
    FData: TStream;
    function GetData: TStream;
  public
    destructor Destroy; override;
    property SeqNo: integer read FSeqNo write FSeqNo;
    property Data: TStream read GetData;
  end;

  TrpRingFKs = class(TObjectList)
  private
    function GetRingFK(AIndex: integer): TrpRingFK;
  public
    property RingFKs[AIndex: integer]: TrpRingFK read GetRingFK; default;
    function AddEvent(AEvent: TrpEvent; ACortege: TrpCortege): integer;
    function IndexOfSeqNo(ASeqNo: integer): integer;
  end;

  TrpForeignKey = class
  private
    FDropped: Boolean;
    FConstraintName: string;
    FTableName: string;
    FDeleteRule: string;
    FOnFieldName: string;
    FFieldName: string;
    FOnTableName: string;
    FUpdateRule: string;
    procedure SetConstraintName(const Value: string);
    procedure SetDeleteRule(const Value: string);
    procedure SetDropped(const Value: Boolean);
    procedure SetFieldName(const Value: string);
    procedure SetOnFieldName(const Value: string);
    procedure SetOnTableName(const Value: string);
    procedure SetTableName(const Value: string);
    procedure SetUpdateRule(const Value: string);
  public
    //Функции возвращают слк для добавления и удаления внешнего ключа
    function AddDLL: string;
    function DropDLL: string;
    function DelDLL: string;
    function SetNullDLL: string;
    //Чтение из переданного ИБСКЛ
    procedure Read(SQL: TIBSQL);
    //Функции чтения и записи в поток
    procedure SaveToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);

    property TableName: string read FTableName write SetTableName;
    property ConstraintName: string read FConstraintName write SetConstraintName;
    property FieldName: string read FFieldName write SetFieldName;
    property OnTableName: string read FOnTableName write SetOnTableName;
    property OnFieldName: string read FOnFieldName write SetOnFieldName;
    property DeleteRule: string read FDeleteRule write SetDeleteRule;
    property UpdateRule: string read FUpdateRule write SetUpdateRule;
    property Dropped: Boolean read FDropped write SetDropped;
  end;

  TrpForeignKeys = class(TObjectList)
  private
    function GetForeignKeys(Index: Integer): TrpForeignKey;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure SaveToStream(Stream: TStream);
    procedure SaveDroppedToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);
    procedure ReadKeys;
    procedure DropKeys;
    procedure AddKeys;
    procedure RestoreKeys;
    procedure CompareWithEtalon;
    function  IndexOfKey(AName: string): integer; overload;
    function  IndexOfKey(ARelName, AFieldName: string): integer; overload;

    property ForeignKeys[Index: Integer]: TrpForeignKey read GetForeignKeys;
  end;

  TrpTrigger = class
  private
    FPosition: Integer;
    FRelationName: string;
    FTriggerName: string;
    FAction: TTriggerAction;
    FActionPosition: TTriggerActionPosition;
    FState: TTriggerState;
    procedure SetAction(const Value: TTriggerAction);
    procedure SetActionPosition(const Value: TTriggerActionPosition);
    procedure SetBody(const Value: string);
    procedure SetPosition(const Value: Integer);
    procedure SetRelationName(const Value: string);
    procedure SetState(const Value: TTriggerState);
    procedure SetTriggerName(const Value: string);
    procedure SetTrigger(const Value: TTrigger);
    function GetTrigger: TTrigger;
  protected
    FBody: string;
    function GetBody: string; virtual;
  public
    procedure AssignTrigger(T: TTrigger);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStreem(Stream: TStream);

    property TriggerName: string read FTriggerName write SetTriggerName;
    property RelationName: string read FRelationName write SetRelationName;
    property Body: string read GetBody write SetBody;
    property State: TTriggerState read FState write SetState;
    property ActionPosition: TTriggerActionPosition read FActionPosition write SetActionPosition;
    property Action: TTriggerAction read FAction write SetAction;
    property Position: Integer read FPosition write SetPosition;
    property Trigger: TTrigger read GetTrigger write SetTrigger;
  end;

  TrpTriggers = class(TList)
  private
    function GetTriggers(Index: Integer): TrpTrigger;
    {$IFDEF DEBUG}
    procedure CheckDBConect;
    {$ENDIF}
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);

    procedure ActivateTriggers;
    procedure InactivateTriggers;
    procedure RestoreTriggers;

    property Triggers[Index: Integer]: TrpTrigger read GetTriggers;
  end;

function ReplicationServer: TrplReplicationServer;

implementation

uses  IB, IBErrorCodes, rpl_dlg_ConflictResolution_unit, Forms, IBDatabase,
      rpl_ReplicationManager_unit, rpl_mnRelations_unit;

var
  _ReplicationServer: TrplReplicationServer;

function ReplicationServer: TrplReplicationServer;
begin
  if _ReplicationServer = nil then
    _ReplicationServer := TrplReplicationServer.Create;

  Result := _ReplicationServer;
end;

{ TrplReplicationServer }

procedure TrplReplicationServer.BeginRepl;
begin
{ DONE -cСделать : Отключение триггеров, циклических ссылок }
  {$IFNDEF DROPFK}
  FRingFKs.Clear;
  {$ENDIF}
  FReplRelations.Clear;

  FPreserve := True;
  ReplDataBase.Preserve := True;
  ReplDataBase.Connected := False;
  try
    if FForeignKeys = nil then
      FForeignKeys := TrpForeignKeys.Create;
    {$IFDEF DROPFK}
    FForeignKeys.DropKeys;
    {$ELSE}
    ReplDataBase.Connected := True;
    FForeignKeys.ReadKeys;
    {$ENDIF}

    if FTriggers = nil then
      FTriggers := TrpTriggers.Create;

    FTriggers.InactivateTriggers;

  finally
    ReplDataBase.Connected := True;
    FPreserve := False;
    ReplDataBase.Preserve := False;
  end;
end;

{$IFDEF DEBUG}
procedure TrplReplicationServer.CheckInTransaction;
begin
  if ReplDataBase.Transaction.InTransaction then
    raise Exception.Create('Перед вызовом данной функции транзанкция должна быть закрыта');
end;
{$ENDIF}

procedure TrplReplicationServer.CheckStreamHeader;
begin
  if FStreamHeader = nil then
    FStreamHeader := TrplStreamHeader.Create;

  FStreamHeader.DBKey := ReplDataBase.DataBaseInfo.DBID;
  FStreamHeader.LastProcessReplKey := ReplDataBase.LastProcessReplKey[FCorDbKey];
  FStreamHeader.ReplKey := ReplDataBase.ReplKey(FCorDbKey);
  FStreamHeader.Schema := ReplDataBase.DataBaseInfo.Schema;
end;

procedure TrplReplicationServer.CollectError(ErrorCode: Integer;
  ErrorDescription: string);
var
  Error: TrpError;
begin
  if FErrorList = nil then
    FErrorList := TrpErrorList.Create;

  Error := TrpError.Create;
  FErrorList.Add(Error);
  Error.ErrorCode := ErrorCode;
  Error.ErrorDescription := ErrorDescription;

  FEvent.SaveToStream(Error.Data);
  if FEvent.ReplType <> atDelete then
    FCortege.SaveToStream(Error.Data);
end;

constructor TrplReplicationServer.Create;
begin
  FCortege := TrpCortege.Create;
  FCortege.OnPostError := OnPostError;
  FCortege.OnDeleteError := OnDeleteError;
  FEvent := TrpEvent.Create;
  FReplRelations:= TStringList.Create;
  {$IFDEF DROPFK}
  FFKsToDrop:= TStringList.Create;
  {$ELSE}
  FRingFKs:= TrpRingFKs.Create;
  {$ENDIF}

  ReplDataBase.AddConnectNotify(Self);
end;

destructor TrplReplicationServer.Destroy;
begin
  FCortege.Free;
  FEvent.Free;
  FStreamHeader.Free;
  FErrors.Free;
  FForeignKeys.Free;
  FTriggers.Free;
  FReplRelations.Free;
  {$IFDEF DROPFK}
  FFKsToDrop.Free;
  {$ELSE}
  FRingFKs.Free;
  {$ENDIF}
  ReplDataBase.RemoveConnectNotify(Self);

  inherited;
end;

procedure TrplReplicationServer.DoAfterConnectionLost;
begin
  FreeAndNil(FCortege);
  FreeAndNil(FEvent);
  FreeAndNil(FForeignKeys);
  FreeAndNil(FTriggers);
end;

procedure TrplReplicationServer.DoAfterSuccessfullConnection;
begin
  if not FPreserve then
  begin
    FCortege := TrpCortege.Create;
    FEvent := TrpEvent.Create;
  end;
end;

procedure TrplReplicationServer.DoBeforeDisconnect;
begin
  if not FPreserve then
  begin
    FreeAndNil(FCortege);
    FreeAndNil(FEvent);
    FreeAndNil(FForeignKeys);
    FreeAndNil(FTriggers);
  end;
end;

function TrplReplicationServer.DoExport(Stream: TStream): Boolean;
var
  I: Integer;
  DataBase: TReplDataBase;
  lDateSeparator: Char;
  lShortDateFormat: string;
  C: Integer;
begin
  //Тут такая фигня:
  //Если в первичный ключ входит поле с датой то в таблицу rpl$log она
  //всегда попадет в формате YYYY-MM-DD и если на компьюторе региональные
  //установки не совпадают, то функции преобразования строки в число выдадут ошибку
  //Поэтому перед репликацией сохраняем рег установки и записываем новые
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  FIgnoreError:= False;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
    Result := False;
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}

    ProgressState.Log(BeginExport);

    DataBase := ReplDataBase;
    DataBase.Transaction.StartTransaction;
    try
      FReplLog := ReplDataBase.Log;
      try
        FReplKey := ReplDataBase.ReplKey(FCorDbKey);
        if DataBase.DataBaseInfo.DBState = dbsMain then
          //Для основной бязы считываем ранее сохраненные соответствия РУИДов
          // см. ToDo\Сопоставление РУИДОВ.doc
          DataBase.RUIDManager.RUIDConf.LoadFromField(FCorDbKey);

        //Записываем заголовок потока
        SaveStreamHeader(Stream);

        PrepareGDRUID;

        //Подготавливаем журнал событий
        PrepareLog(FReplKey);

        {Записываем количество записей}
        C := FReplLog.ChangesCount;
        Stream.Write(C, SizeOf(C));
        ProgressState.Log(Format(PreparedForExport, [C]));
        ProgressState.MaxMinor := C;

        //Записываем циклические ссылки, которые необходимо отключить
        SaveFKsToDrop(Stream);

        if C > 0 then
        begin
          //Для основной базы записываем соответстие РУИДов
          if DataBase.DataBaseInfo.DBState = dbsMain then
          begin
            //Устанавливаем значение ключа файла реплики, если СР.ReplKey = -1,
            //т.е. СР еще не передавалось на второстепенную базу
            DataBase.RUIDManager.RUIDConf.SetReplKey(FReplKey);
            //сохраняем в поток только непереданные СР
            DataBase.RUIDManager.RUIDConf.SaveToStream(Stream, FReplKey);
          end;
          {Начинаем цикл записи данных}
          for I := 0 to FReplLog.Count - 1 do
          begin
            { TODO :
            Нужно вообще отказаться от TrpEvent, ведь у меня в TReplLog
            есть вся неожходимая информация }
            if not FReplLog[i].NeedDelete then
            begin
              FEvent.Assign(FReplLog[i]);
              FCortege.RelationKey := FEvent.RelationKey;

              {Если запись не удалена то производим запись изменений}
              if FEvent.ReplType <> atDelete then
              begin
                FCortege.Key :=  FEvent.NewKey;
                FCortege.LoadFromDB;
                if FCortege.IsEmptyFieldsData then
                  FEvent.ReplType:= atEmpty;
              end;

              FEvent.SaveToStream(Stream);
              if (FEvent.ReplType <> atDelete) and (FEvent.ReplType <> atEmpty) then
                FCortege.SaveToStream(Stream);

              ProgressState.MinorProgress(Self);
            end;
          end;
          //отмечаем в РПЛ_ЛОГИСТ что для данной  записи репликация призошла
          FReplLog.MarkTransferedRecords(FReplKey);
          //Увеличиваем значение для базы с которой произвоим репл.
          //если передавались данные. Если данные не передавались
          //то файл експорта не будет иметь большого значения
          DataBase.IncReplKey(FCorDbKey);
        end;
        Result := True;
      finally
        FReplLog := nil;
      end;
      DataBase.Transaction.Commit;
    except
      DataBase.Transaction.Rollback;
    end;
  finally
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
end;

function TrplReplicationServer.DoExportConfirm(Stream: TStream): Boolean;
var
  i: integer;
begin
  ProgressState.Log(BeginExportConfirm);
  ReplDataBase.Transaction.StartTransaction;
  SaveStreamHeader(Stream);
  i:= -1;
  Stream.Write(i, SizeOf(i));
  Result := True;
  ReplDataBase.Transaction.Rollback;
end;

function TrplReplicationServer.DoImport(Stream: TStream): Boolean;
var
  CountChanges: Integer;
  DataBase: TReplDataBase;
  //Ключ последнего файла реплики обротанного на корбазе
  LastProcessReplKey: Integer;
  RollbackCount: Integer;
  I: Integer;
  lDateSeparator: Char;
  lShortDateFormat: string;
//  SeqNo: Integer;
begin
  //Тут такая фигня:
  //Если в первичный ключ входит поле с датой то в таблицу rpl$log она
  //всегда попадет в формате YYYY-MM-DD и если на компьюторе региональные
  //установки не совпадают, то функции преобразования строки в число выдадут ошибку
  //Поэтому перед репликацией сохраняем рег установки и записываем новые
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  FIgnoreError:= False;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
    Result := False;
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    //Присваиваем обработчики конф. ситуаций
    FCortege.OnPostError := OnPostError;
    FCortege.OnDeleteError := OnDeleteError;

    DataBase := ReplDataBase;
    FReplLog := DataBase.Log;
    try
      LoadStreamHeader(Stream);
      //Проверяем ключ базы с которой пришел файл реплики
      if not DataBase.CanRepl(FCorDbKey, FStreamHeader.ToDBKey) then
        raise Exception.Create(InvalidDataBaseKey);
      //Проверяем ключ схемы репликации
      if FStreamHeader.Schema <> DataBase.DataBaseInfo.Schema then
        raise Exception.Create(InvalidSchema);

      LastProcessReplKey  := DataBase.LastProcessReplKey[FCorDbKey];
      if FReplKey < LastProcessReplKey + 1 then
        raise Exception.Create(AlreadyReplicated)
      else
      if FReplKey > LastProcessReplKey + 1 then
        raise Exception.Create(Format(MissingFiles, [FReplKey - LastProcessReplKey - 1]));

      FCurrReplKey := DataBase.ReplKey(FCorDbKey);
      if FCurrReplKey - 1 > FStreamHeader.LastProcessReplKey then begin
        RollBackCount := FCurrreplKey - FStreamHeader.LastProcessReplKey - 1;
        if RollBackCount = 1 then
          raise Exception.Create(OneNotConfirmedTransaction)
        else
          raise Exception.Create(Format(ManyNotConfirmedTransaction, [RollBackCount]));
      end;

      Stream.Read(CountChanges, SizeOf(CountChanges));
      //Выдаем сообщение о кол-ве переданных изменений
      ProgressState.Log(Format(NRecordPassed, [CountChanges]));

      //Считываем циклические ссылки, которые необходимо отключить
      LoadFKsToDrop(Stream);

      if CountChanges > 0 then
      begin
        ProgressState.Log(ReplicationStarting);
        BeginRepl;
        try
          DataBase.Transaction.StartTransaction;
          try
            if DataBase.DataBaseInfo.Direction = rdDual then begin
              //Устанавливаем признак подтверждения передачи данных
              FReplLog.TransactionCommit(FCorDbKey, FStreamHeader.LastProcessReplKey);
              FReplLog.PackDB;
            end;
            if DataBase.DataBaseInfo.DBState = dbsMain then
            begin
              //on main database read saved RUIDConformitus
              DataBase.RUIDManager.RUIDConf.LoadFromField(FCorDbKey);
              //Delete commited RUIDConformitus
              DataBase.RUIDManager.RUIDConf.DeleteFromList(FReplKey);
            end else
            begin
              //Для второстепенной базы считываем соответствия из потока
              DataBase.RUIDManager.RUIDConf.ReadFromStream(Stream);
              //Если соответствие было установлено при передачи
              //файла с главной базы на второстепенную то в
              //PRUID будет хранить РУИД второстепенной базы а
              //SRUID будет хранить РУИД главной базы. Поэтому
              //для сохранения сообветствий в базу необходимо произвести
              //инвертирование т.е. в RUID занести значение ConfRUID а в
              //ConfRUID значение RUID
              DataBase.RUIDManager.RUIDConf.Invert;
              //Сохраняем в базу при этом список соответствий очищается
              DataBase.RUIDManager.RUIDConf.SaveToDB;
            end;
            //Запоминаем ключ последнего дошедего до базы файла реплики
            DataBase.LastProcessReplKey[FCorDbKey] := FReplKey;

            FCurrReplKey := DataBase.ReplKey(FCorDbKey);
            if FCurrReplKey - 1 > FStreamHeader.LastProcessReplKey then
            begin
              //В момент формирования обрабатываемого файла, файлы реплики, сформированные на
              //данной базе еще не достигли корбазыб возможно, они потеряны,
              //поэтому необходимо произвести откат реплик
              RollBackCount := FCurrreplKey - FStreamHeader.LastProcessReplKey - 1;
              if RollBackCount = 1 then
                ShowInfoMessage(OneNotConfirmedTransaction)
              else
                ShowInfoMessage(Format(ManyNotConfirmedTransaction, [RollBackCount]));

//              DoRollBack(FCorDbKey, RollBackCount);
            end;

            if DataBase.DataBaseInfo.Direction = rdDual then begin
              //Записи, информация об изменении которых имеется в обрабатываемом файле,
              //могли быть изменены и на текущей базе.
              //Подготавливаем журнал изменений на текущей базе
              PrepareLog(FCurrReplKey);
            end;

            if FErrorList = nil then
              FErrorList := TrpErrorList.Create;

            FErrorList.Clear;
            FErrorList.LoadFromDb(FCorDbKey);

            FIULog:= False;
            FDLog:= False;
            ProgressState.MaxMinor := CountChanges;
            for I := 0 to CountChanges - 1 do
            begin
              DoReplEvent(Stream);
              ProgressState.MinorProgress(Self);
            end;

            if ConflictResolutioning then
            begin
              FErrorList.SaveToDb(FCorDbKey);

              ExecuteSProcedures;
              ExecuteMakeRestProcedure;
              //Для основной базы удаляем не нужные РУИДы
              //см. ToDo\Сопоставление РУИДОВ.doc
              if DataBase.DataBaseInfo.DBState = dbsMain then
              begin
                DataBase.RUIDManager.RUIDConf.DeleteFromDB;
                DataBase.RUIDManager.RUIDConf.SaveToField(FCorDbKey);
              end else
                { TODO : Небходимо ли здесь производить инвертацию списка? }
                //Для второстепенной базы все найденные сопоставления должны сразу попадать
                //в базу
                DataBase.RUIDManager.RUIDConf.SaveToDB;
              DataBase.Transaction.Commit;
              Result := True;
            end else
            begin
              DataBase.Transaction.Rollback;
            end;
          except
            DataBase.Transaction.Rollback;
            raise;
          end;
        finally
          EndRepl;
        end;
      end else
      begin
        DataBase.Transaction.StartTransaction;
        try
          //Устанавливаем признак успешной обработки изменений
          FReplLog.TransactionCommit(FCorDbKey, FStreamHeader.LastProcessReplKey);
          FReplLog.PackDB;
          DataBase.Transaction.Commit;
          Result := True;
        except
          DataBase.Transaction.Rollback;
          raise;
        end;
      end;
    finally
      FReplLog := nil;
    end;
  finally
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
end;

function TrplReplicationServer.DoImportConfirm(Stream: TStream): Boolean;
var
  LastProcessReplKey: Integer;
  RollbackCount: Integer;
  DataBase: TReplDataBase;
begin
  FIgnoreError:= False;
  Result := False;

  DataBase := ReplDataBase;
  FReplLog := DataBase.Log;
  try
    LoadStreamHeader(Stream);
    //Проверяем ключ базы с которой пришел файл реплики
    if not DataBase.CanRepl(FCorDbKey, FStreamHeader.ToDBKey) then
      raise Exception.Create(InvalidDataBaseKey);
    //Проверяем ключ схемы репликации
    if FStreamHeader.Schema <> DataBase.DataBaseInfo.Schema then
      raise Exception.Create(InvalidSchema);

    LastProcessReplKey  := DataBase.LastProcessReplKey[FCorDbKey];
    if FReplKey < LastProcessReplKey + 1 then
      raise Exception.Create(AlreadyReplicated)
    else
    if FReplKey > LastProcessReplKey + 1 then
      raise Exception.Create(Format(MissingFiles, [FReplKey - LastProcessReplKey - 1]));

    FCurrReplKey := DataBase.ReplKey(FCorDbKey);
    if FCurrReplKey - 1 > FStreamHeader.LastProcessReplKey then begin
      RollBackCount := FCurrreplKey - FStreamHeader.LastProcessReplKey - 1;
      if RollBackCount = 1 then
        raise Exception.Create(OneNotConfirmedTransaction)
      else
        raise Exception.Create(Format(ManyNotConfirmedTransaction, [RollBackCount]));
    end;

    DataBase.Transaction.StartTransaction;
    try
      //Устанавливаем признак успешной обработки изменений
      FReplLog.TransactionCommit(FCorDbKey, FStreamHeader.LastProcessReplKey);
      FReplLog.PackDB;
      DataBase.Transaction.Commit;
      Result := True;
    except
      DataBase.Transaction.Rollback;
      raise;
    end;
  finally
    FReplLog := nil;
  end;
end;

procedure TrplReplicationServer.DoReplEvent(Stream: TStream);
var
  lKey, NKey: string;
  B: Boolean;
begin
  FErrorProcessed := False;

  FEvent.LoadFromStream(Stream);
  FCortege.RelationKey := FEvent.RelationKey;
  if FRelationKey <> FEvent.RelationKey then
  begin
    FRelationKey := FEvent.RelationKey;
    if not FIULog and ((FEvent.ReplType[1] = atInsert) or (FEvent.ReplType[1] = atUpdate)) then begin
      ProgressState.Log(MSG_UPDATE_INSERT_RECORDS);
      FIULog:= True;
    end
    else if not FDLog and (FEvent.ReplType[1] = atDelete) then begin
      ProgressState.Log(MSG_DELETE_RECORDS);
      FDLog:= True;
    end;
    ProgressState.Log('   ' + ReplDataBase.Relations[FEvent.RelationKey].RelationName);
  end;

  if FReplRelations.IndexOf(Trim(FCortege.Relation.RelationName)) = -1 then
    FReplRelations.Add(Trim(FCortege.Relation.RelationName));

  lKey := FEvent.OldKey;
  B := False;
  case FEvent.ReplType[1] of
    atInsert:
    begin
      {запись могла быть с реплецирована. Потом на корбазе запись сохранена в
      файл и удалена. Потом пользователь загрузил из файла. Запись вставится со старым ид
      и в файл реплики пойдет информация о вставке. Поэтому необходимо проверять извенялась ли
      данная запись на данной базе}
      FCortege.LoadFromStream(Stream);
      if not RecordChanged(lKey, NKey, FEvent.RelationKey) or ConflictResolution then
      begin
        FCortege.Key := NKey;
        B := FCortege.Insert;
      end else
      begin
        if RecordDeleted(lKey, FEvent.RelationKey) then
          FCortege.SaveIndicesValue;
      end;
    end;
    atUpdate:
    begin
      FCortege.LoadFromStream(Stream);
      if not RecordChanged(lKey, NKey, FEvent.RelationKey) or ConflictResolution then
      begin
        FCortege.Key := NKey;
        B := FCortege.UpDate;
      end else
      begin
        if RecordDeleted(lKey, FEvent.RelationKey) then
          FCortege.SaveIndicesValue;
      end;
    end;
    atDelete:
    begin
      if not RecordChanged(lKey, NKey, FEvent.RelationKey) or ConflictResolution then
      begin
        FCortege.Key := NKey;
        B := FCortege.Delete;
      end;
    end;
  end;

  if (ReplDataBase.DataBaseInfo.DBState = dbsMain) and
     (ReplDataBase.DataBaseInfo.Direction = rdDual) and
    {(ReplDataBase.ReplicationDBCount > 2) and} B then
  begin
    { Если корбаза одна, то регестрировать изменения не надо }
    FReplLog.Log(FEvent);
    {С регистрацией истории получается сведующая херня:
    Допустим есть глявная база А и две втростепенные базы Б и В.
    На всех базах имеется запись х. На Б запись удалили а на
    В запись изменили. Передаем данные с Б на А. В таблицу rdb$loghist вставится запись
    о том что на базу Б данное изменение уже реплецировалось. Аналогично
    при передачи данных с В. При передаче данных с А на Б и В пойдут записи
    об удалении и обновлении.}
//              FReplLog.EnterHistLog(SeqNo, FCorDbKey, FCurrReplKey, 1);
  end;
end;

function TrplReplicationServer.DoRollBack(DbKey,
  RollBackCount: Integer): Integer;
var
  SQL: TIBSQL;
  Key: Integer;
  DidActivate: Boolean;
begin
  DidActivate := not ReplDataBase.Transaction.InTransaction;
  if DidActivate then
    ReplDataBase.Transaction.StartTransaction;
  try
    Result := RepldataBase.NotCommitedTransaction(DbKey);
    if Result > RollBackCount then
      Result := RollBackCount;
    if Result > 0 then
    begin
      //Вычисляем ключ файла до которого необходимо произвести откат
      Key := ReplDataBase.ReplKey(DbKey) - Result;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.Transaction;
        SQL.SQL.Add('DELETE FROM rpl$loghist WHERE dbkey = ' + IntToStr(DBKey) +
          ' AND replkey >= ' + IntToStr(Key));
        SQL.ExecQuery;

        if ReplDataBase.DataBaseInfo.DBState = dbsMain then
        begin
          //Для основной базы необходимо также откатить соответствия рудов
          ReplDataBase.RUIDManager.RUIDConf.RollBack(Key);
          //и сохранить в базу
          ReplDataBase.RUIDManager.RUIDConf.SaveToField(DbKey);
        end;

        SQL.Close;
        SQL.SQL.Text := 'UPDATE rpl$replicationdb SET replkey = ' +
          ':replkey WHERE dbkey = :dbkey';
        SQL.ParamByName(fnReplKey).AsInteger := Key;
        SQl.ParamByName(fnDBKey).AsInteger := DBKey;
        SQL.ExecQuery;
      finally
        SQL.Free;
      end;
    end;
    if DidActivate then
      ReplDataBase.Transaction.Commit;
  except
    on E: Exception do
    begin
      if DidActivate then
        ReplDataBase.Transaction.Rollback;
      Errors.Add(Format(ERR_CANT_ROLLBACK_TRANSACTION, [E.Message]));
      raise;
    end;
  end;
end;

procedure TrplReplicationServer.EndRepl;
begin
  FPreserve := True;
  ReplDataBase.Preserve := True;
  ReplDataBase.Connected := False;
  try
    {$IFDEF DROPFK}
    if FForeignKeys <> nil then FForeignKeys.AddKeys;
    {$ENDIF DROPFK}

    if FTriggers <> nil then
      FTriggers.ActivateTriggers;

  finally
    ReplDataBase.Connected := True;
    FPreserve := False;
    ReplDataBase.Preserve := False;
  end;
end;

procedure TrplReplicationServer.ExecuteMakeRestProcedure;
{$IFDEF GEDEMIN}
var
  SQL: TIBSQL;
  SP: TIBStoredProc;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text := 'SELECT rdb$procedure_name FROM rdb$procedures WHERE rdb$procedure_name = ''INV_MAKEREST''';
    SQL.ExecQuery;
    if not SQL.Eof then begin
      ProgressState.Log(MSG_MAKE_REST);
      SP := TIBStoredProc.Create(nil);
      try
        SP.Transaction := ReplDataBase.Transaction;
        SP.StoredProcName := SQL.Fields[0].AsString;
        SP.ExecProc;
      finally
        SP.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
{$ENDIF}
end;

procedure TrplReplicationServer.ExecuteSProcedures;
{$IFDEF GEDEMIN}
var
  SQL: TIBSQL;
  SP: TIBStoredProc;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReplDataBase.Transaction;
    SQL.SQL.Text :=
      'SELECT DISTINCT p.rdb$procedure_name pname, d.rdb$depended_on_name ' +
      'FROM rdb$procedures p ' +
      '  LEFT JOIN rdb$dependencies d ON d.rdb$dependent_name = p.rdb$procedure_name ' +
      '    AND d.rdb$field_name IS NULL ' +
      '    AND d.rdb$depended_on_type = 0 ' +
      'WHERE rdb$procedure_name CONTAINING ''_P_RESTR''';
    SQL.ExecQuery;
    SP := TIBStoredProc.Create(nil);
    if not SQL.Eof then
      ProgressState.Log(MSG_RESTRUCT);
    try
      SP.Transaction := ReplDataBase.Transaction;
      while not SQL.Eof do
      begin
        if FReplRelations.IndexOf(SQL.Fields[1].AsTrimString) <> -1 then begin
          ProgressState.Log('  ' + SQL.Fields[1].AsTrimString);
          SP.StoredProcName := SQL.Fields[0].AsString;
          SP.ExecProc;
        end;
        SQL.Next;
      end;
    finally
      SP.Free;
    end;
  finally
    SQL.Free;
  end;
{$ENDIF}
end;

function TrplReplicationServer.ExportData(Stream: TStream;
  CorDBKey: Integer): Boolean;
begin
  Errors.Clear;
  if ReplDataBase.CanRepl(CorDbKey) then
  begin
    FCorDbKey := CorDBKey;
    try
      Result := DoExport(Stream);
    except
      on E: Exception do
      begin
        Result := False;
        Errors.Add(E.Message);
      end;
    end;
  end else
  begin
    Result := False;
    Errors.Add(InvalidDataBaseKey);
  end;
end;

function TrplReplicationServer.ExportConfirm(Stream: TStream;
  CorDBKey: Integer): Boolean;
begin
  Errors.Clear;
  if ReplDataBase.CanRepl(CorDbKey) then
  begin
    FCorDbKey := CorDBKey;
    try
      Result := DoExportConfirm(Stream);
    except
      on E: Exception do
      begin
        Result := False;
        Errors.Add(E.Message);
      end;
    end;
  end else
  begin
    Result := False;
    Errors.Add(InvalidDataBaseKey);
  end;
end;

function TrplReplicationServer.ImportData(Stream: TStream;
  ErrorToManualLog: Boolean = False): Boolean;
begin
  Errors.Clear;
  try
    FErrorToManualLog := ErrorToManualLog;
    Result := DoImport(Stream);
  except
    on E: Exception do
    begin
      Result := False;
      Errors.Add(E.Message);
    end;
  end;
end;

function TrplReplicationServer.ImportConfirm(Stream: TStream;
  ErrorToManualLog: Boolean): Boolean;
begin
  Errors.Clear;
  try
    FErrorToManualLog := ErrorToManualLog;
    Result := DoImportConfirm(Stream);
  except
    on E: Exception do
    begin
      Result := False;
      Errors.Add(E.Message);
    end;
  end;
end;

procedure TrplReplicationServer.LoadStreamHeader(Stream: TStream);
begin
  if FStreamHeader = nil then
    FStreamHeader := TrplStreamHeader.Create;

  FStreamHeader.LoadFromStream(Stream);
  FCorDbKey := FStreamHeader.DBKey;
  FReplKey := FStreamHeader.ReplKey;
end;

procedure TrplReplicationServer.OnDeleteError(SQL: TIBSQL; E: Exception;
  var DataAction: TDataAction);
begin
  if FIgnoreError then Exit;
  if FErrorProcessed then
  begin
    //Если ошибка уже обрабатывалась то запоминаем и выходим
    FErrorProcessed := False;
    DataAction := daAbort;
    CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
    Exit;
  end;

  if (E is EIBError) then
  begin
    if (EIBError(E).IBErrorCode = isc_foreign_key) and not FErrorProcessed then
    begin
      { TODO -cОбратить внимание :
      Следует ли удалять ссылки на данную запись или нет?
      Если на второстепенную базу прихдит сообщение о необходимость
      удалить запись, а на второстепенной уже есть записи которые
      ссылаются на данную, то по идее их можно удалить. А если там
      важные данные?
      Возможно нужно сделать удаление внешних записей опционно или
      давать пользователю принять решение об удалении}
      FCortege.DeleteReference;
      FErrorProcessed := True;
      DataAction := daRetry;
    end else
    begin
      CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
      DataAction := daAbort;
    end;
  end;
end;

procedure TrplReplicationServer.OnDeleteErrorManual(SQL: TIBSQL;
  E: Exception; var DataAction: TDataAction);
begin
  if FIgnoreError then Exit;
  if (E is EIBError) then
  begin
    //Обновляем информацию об ошибке
    FError.ErrorCode := EIBError(E).IBErrorCode;
    FError.ErrorDescription := E.Message;
  end;

  FErrorProcessed := True;
  DataAction := daAbort;
end;

procedure TrplReplicationServer.OnPostError(SQL: TIBSQL; E: Exception; var DataAction: TDataAction);
{$IFNDEF DROPFK}
var
  i: integer;
{$ENDIF}
begin
  if FIgnoreError then Exit;
  if FErrorProcessed then
  begin
    //Если ошибка уже обрабатывалась то запоминаем и выходим
    FErrorProcessed := False;
    DataAction := daAbort;
    CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
    Exit;
  end;

  if (E is EIBError) then
  begin
    if (EIBError(E).IBErrorCode = isc_foreign_key) and not FErrorProcessed then
    begin
      {$IFNDEF DROPFK}
      if CheckCortegeRingFKs then begin
        DataAction := daRetry;
      end
      else
      {$ENDIF}
      if not FCortege.CheckFKRecords then begin
//        FCortege.UpdateForeignKey;
//        DataAction := daRetry;
        FErrorProcessed := True;
        DataAction := daAbort;
      end
      else begin
        {$IFNDEF DROPFK}
        i:= FRingFKs.IndexOfSeqNo(FEvent.Seqno);
        if i <> -1 then begin
          FRingFKs[i].Data.Position:= 0;
          FEvent.LoadFromStream(FRingFKs[i].Data);
          FCortege.LoadFromStream(FRingFKs[i].Data);
          FRingFKs.Delete(i);
        end;
        {$ENDIF}
        CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
        DataAction := daAbort;
      end;
    end else
    begin
      CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
      DataAction := daAbort;
    end;
  end;
end;

procedure TrplReplicationServer.OnPostErrorManual(SQL: TIBSQL;
  E: Exception; var DataAction: TDataAction);
begin
  if FIgnoreError then Exit;
  if (E is EIBError) then
  begin
    //Обновляем информацию об ошибке
    FError.ErrorCode := EIBError(E).IBErrorCode;
    FError.ErrorDescription := E.Message;
  end;
  FErrorProcessed := True;
  DataAction := daAbort;
end;

procedure TrplReplicationServer.PrepareLog(ReplKey: Integer);
begin
  ProgressState.Log(rpl_ResourceString_unit.PrepareLog);
  ProgressState.MaxMinor := 3;
  FReplLog.DBKey := FCorDbKey;
  FReplLog.SortLog;
  ProgressState.MinorProgress(Self);
  FReplLog.Pack(ReplKey);
  ProgressState.MinorProgress(Self);
  FReplLog.SortLogFinal;
  ProgressState.MinorProgress(Self);
end;

function TrplReplicationServer.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := 0;
end;

function TrplReplicationServer.RecordChanged(lKey: String;
  out NewKey: string; RelationKey: Integer): Boolean;
var
  Index: Integer;
begin
  NewKey := lKey;
  Index := FReplLog.IndexOfOldKey(RelationKey, lKey);
  Result := Index > - 1;
  if Result then
    NewKey := FReplLog.Logs[Index].NewKey;
end;

function TrplReplicationServer.RestoreDB: Boolean;
var
  SQL: TIBSQL;
begin
  FPreserve := True;
  ReplDataBase.Connected := False;
  SQL:= TIBSQL.Create(nil);
  try
    ReplDataBase.Connected := True;
    SQL.Transaction:= ReplDataBase.ReadTransaction;
    SQL.SQL.Text:= SELECT_DBSTATE_FKFIELD;
    try
      SQL.ExecQuery;
      Result:= not SQL.Eof;
    except
      Result:= False;
    end;

    if not Result then begin
      ProgressState.Log(ERR_CANT_RESTORE_DB);
      Exit;
    end;

    SQL.Close;
    SQL.SQL.Text:= SELECT_DBSTATE_DIRECTION_FIELD;
    try
      SQL.ExecQuery;
      if SQL.Eof then begin
        SQL.Close;
        SQL.Transaction:= ReplDataBase.Transaction;
        SQL.Transaction.StartTransaction;
        SQL.SQL.Text:= ADD_DBSTATE_DIRECTION_FIELD;
        try
          SQL.ExecQuery;
          ReplDataBase.Transaction.Commit;
        except
          ProgressState.Log(ERR_CANT_ADD_DIRECTION_FIELD);
        end;
      end;
    except
    end;

    ReplDataBase.Connected := False;
    if FForeignKeys = nil then
      FForeignKeys := TrpForeignKeys.Create;
    FForeignKeys.RestoreKeys;

    if FTriggers = nil then
      FTriggers := TrpTriggers.Create;

    FTriggers.RestoreTriggers;

    Result := True;
  finally
    ReplDataBase.Connected := True;
    FPreserve := False;
    SQL.Free;
  end;
end;

function TrplReplicationServer.RollBack(DBKey, Count: Integer): Boolean;
var
  I: Integer;
begin
  Errors.Clear;
  I := DoRollBack(DBKey, Count);
  Result := I = Count;
  if not Result then
    Errors.Add(Format(ERR_ROLLBACK_TRANSACTION, [I]))
  else
    Errors.Add(MSG_ROLLBACK_TRANSACTION_SUCCES);  
end;

procedure TrplReplicationServer.SaveStreamHeader(Stream: TStream);
begin
  CheckStreamHeader;
  FStreamHeader.ToDBKey := CorDBKey;
  FStreamHeader.SaveToStream(Stream);
end;

procedure TrplReplicationServer.SetCorDbKey(const Value: Integer);
begin
  FCorDbKey := Value;
end;

function TrplReplicationServer.ConflictResolution: Boolean;
begin
  Result := False;
  case ReplDataBase.DataBaseInfo.ErrorDecision of
    edPriority: Result := ConflictResolutionPriority;
    edTime: Result := ConflictResolutionTime;
//    edManual: Result := ConflictResolutionManual;
    edServer: Result := ConflictResolutionServer;
  end;
end;

function TrplReplicationServer.ConflictResolutioning: Boolean;
var
  D: TdlgConflictResolution;
begin
  { TODO : Реализовать ручное разрешение конфликтов }
  if FErrorList = nil then
    FErrorList := TrpErrorList.Create;

  ProgressState.Log(Format(MSG_THERE_ARE_CONTENTION, [FErrorList.Count]));
  Result := FErrorList.Count = 0;
  if Result then begin
    {$IFNDEF DROPFK}
    ProcessRingFKs;
    Result := FErrorList.Count = 0;
    if Result then
    {$ENDIF}
      Exit;
  end
  else
    ProgressState.Log(MSG_conflict_resolution);

  ProgressState.MaxMinor := FErrorList.Count;

  FCortege.OnPostError := OnPostErrorManual;
  FCortege.OnDeleteError := OnDeleteErrorManual;

  AutoConflictResolution(Self);

  {$IFNDEF DROPFK}
  ProcessRingFKs;
  {$ENDIF}

  if not FErrorToManualLog then
  begin
    if FErrorList.Count > 0 then
    begin
      D := TdlgConflictResolution.Create(nil);
      try
        D.Cortege := FCortege;
        D.Event := FEvent;
        D.ErrorList := FErrorList;
        D.AutoConflictResolution := AutoConflictResolution;
        Result := D.ShowModal = mrOk;
      finally
        D.Free;
      end;
    end else
      Result := True;
  end else
    Result := True;
end;

function TrplReplicationServer.ConflictResolutionManual: Boolean;
begin
  { TODO : Реализовать }
  raise Exception.Create('Will be later');
end;

function TrplReplicationServer.ConflictResolutionPriority: Boolean;
begin
  Result := ReplDataBase.DBPriority(ReplDataBase.DataBaseInfo.DBID) >
    ReplDataBase.DBPriority(FCorDbKey);
end;

function TrplReplicationServer.ConflictResolutionServer: Boolean;
begin
  Result := ReplDataBase.DataBaseInfo.DBState <> dbsMain
end;

function TrplReplicationServer.ConflictResolutionTime: Boolean;
begin
  { TODO : Чето я затупил. Какой здесь должен быть знак сравнения }
  Result := FReplLog.Logs[FReplLog.IndexOfOldKey(FEvent.RelationKey,
    FEvent.OldKey)].ActionTime < FEvent.ActionTime
end;

function TrplReplicationServer._AddRef: Integer;
begin
  Result := 0;
end;

function TrplReplicationServer._Release: Integer;
begin
  Result := 0;
end;

function TrplReplicationServer.RecordDeleted(Key: string; RelationKey: Integer): boolean;
var
  Index: Integer;
begin
  Index := FReplLog.IndexOfOldKey(RelationKey, Key);
  if Index > - 1 then
    Result := FReplLog.Logs[Index].ReplType = atDelete
  else
    Result := False;
end;

procedure TrplReplicationServer.AutoConflictResolution(Sender: TObject);
var
  ErrorCount: Integer;
  I: Integer;
begin
  //Делаем попытку автоматического разрешения конфликтов
  repeat
    ErrorCount := FErrorList.Count;
    //Будем повторять цикл до тех пор пока
    //уменьшается число неразрешенных конфликтов
    for I := FErrorList.Count - 1 downto 0 do
    begin
      FErrorProcessed := False;
      FError := TrpError(FErrorList[I]);
      FError.Data.Position := 0;
      DoReplEvent(FError.Data);
      if not FErrorProcessed then
      begin
        FErrorList.Delete(I);
        ProgressState.MinorProgress(Self);
      end;
    end;
  until ErrorCount = FErrorList.Count;
end;

function TrplReplicationServer.ConflictResolution(DBKey: Integer): Boolean;
begin
  Errors.Clear;
  try
    FErrorToManualLog := False;
    Result := DoConflictResolition(DBKey);
  except
    on E: Exception do
    begin
      Result := False;
      Errors.Add(E.Message);
    end;
  end;
end;

function TrplReplicationServer.DoConflictResolition(DBKey: Integer): boolean;
var
  DataBase: TReplDataBase;
  lDateSeparator: Char;
  lShortDateFormat: string;
begin
  //Тут такая фигня:
  //Если в первичный ключ входит поле с датой то в таблицу rpl$log она
  //всегда попадет в формате YYYY-MM-DD и если на компьюторе региональные
  //установки не совпадают, то функции преобразования строки в число выдадут ошибку
  //Поэтому перед репликацией сохраняем рег установки и записываем новые
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';

    Result := ReplDataBase.ConflictCount(DBKey) = 0;
    {$IFDEF DEBUG}
    CheckInTransaction;
    {$ENDIF}
    DataBase := ReplDataBase;
    FCorDbKey := DBKey;
    FReplLog := DataBase.Log;
    try
      if DataBase.ConflictCount(DBKey) > 0 then
      begin
        ProgressState.Log(ReplicationStarting);
        BeginRepl;
        try
          DataBase.Transaction.StartTransaction;
          try
            if DataBase.DataBaseInfo.DBState = dbsMain then
            begin
              //on main database read saved RUIDConformitus
              DataBase.RUIDManager.RUIDConf.LoadFromField(FCorDbKey);
            end;
            FCurrReplKey := DataBase.ReplKey(FCorDbKey);
            //Записи, информация об изменении которых имеется в обрабатываемом файле,
            //могли быть изменены и на текущей базе.
            //Подготавливаем журнал изменений на текущей базе
            PrepareLog(FCurrReplKey);

            if FErrorList = nil then
              FErrorList := TrpErrorList.Create;

            FErrorList.Clear;
            FErrorList.LoadFromDb(FCorDbKey);

            if ConflictResolutioning then
            begin
              FErrorList.SaveToDb(FCorDbKey);

              ExecuteSProcedures;
              //Для основной базы удаляем не нужные РУИДы
              //см. ToDo\Сопоставление РУИДОВ.doc
              if DataBase.DataBaseInfo.DBState = dbsMain then
              begin
                DataBase.RUIDManager.RUIDConf.DeleteFromDB;
                DataBase.RUIDManager.RUIDConf.SaveToField(FCorDbKey);
              end else
                { TODO : Небходимо ли здесь производить инвертацию списка? }
                //Для второстепенной базы все найденные сопоставления должны сразу попадать
                //в базу
                DataBase.RUIDManager.RUIDConf.SaveToDB;
              DataBase.Transaction.Commit;
              Result := True;
            end else
            begin
              DataBase.Transaction.Rollback;
            end;
          except
            DataBase.Transaction.Rollback;
            raise;
          end;
        finally
          EndRepl;
        end;
      end;
    finally
      FReplLog := nil;
    end;
  finally
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
end;

procedure TrplReplicationServer.PrepareGDRUID;
var
  q: TIBSQL;
  sRelationName: string;
begin
  ProgressState.Log(rpl_ResourceString_unit.PrepareGDRUID);
  FDeletedRUIDCount:= 0;
  q:= TIBSQL.Create(nil);
  try
    q.Transaction:= ReplDataBase.Transaction;
    q.SQL.Text:= 'SELECT id, xid, Count(*) FROM gd_ruid WHERE xid <> id and dbid=:dbid GROUP BY 1, 2';
    q.ParamByName('dbid').AsInteger:= ReplDataBase.DataBaseInfo.DBID;
    q.ExecQuery;
    ProgressState.MaxMinor:= q.Fields[2].AsInteger;
    while not q.Eof do begin
      ProgressState.MinorProgress(Self);
      if RecordWithIDExists(q.FieldByName('id').AsInteger, sRelationName) then begin
        CheckUpdateIDSQL(sRelationName);
        FIgnoreError:= True;
        try
          FUpdateIDSQL.ParamByName('oldid').AsInteger:= q.FieldByName('id').AsInteger;
          FUpdateIDSQL.ParamByName('newid').AsInteger:= q.FieldByName('xid').AsInteger;
          FUpdateIDSQL.ExecQuery;
          FIgnoreError:= False;
          CheckUpdateRUIDSQL;
          FUpdateRUIDSQL.ParamByName('xid').AsInteger:= q.FieldByName('xid').AsInteger;
          FUpdateRUIDSQL.ParamByName('dbid').AsInteger:= ReplDataBase.DataBaseInfo.DBID;
          FUpdateRUIDSQL.ExecQuery;
        except
          FIgnoreError:= False;
          CheckDeleteRUIDSQL;
          FDeleteRUIDSQL.ParamByName('xid').AsInteger:= q.FieldByName('xid').AsInteger;
          FDeleteRUIDSQL.ParamByName('dbid').AsInteger:= ReplDataBase.DataBaseInfo.DBID;
          FDeleteRUIDSQL.ExecQuery;
          Inc(FDeletedRUIDCount);
        end;
        FIgnoreError:= False;
      end
      else begin
        CheckDeleteRUIDSQL;
        FDeleteRUIDSQL.ParamByName('xid').AsInteger:= q.FieldByName('xid').AsInteger;
        FDeleteRUIDSQL.ParamByName('dbid').AsInteger:= ReplDataBase.DataBaseInfo.DBID;
        FDeleteRUIDSQL.ExecQuery;
      end;
      q.Next;
    end;
  finally
    if FDeletedRUIDCount > 0 then
      ProgressState.Log(Format(rpl_ResourceString_unit.DeletedFromGDRUID, [FDeletedRUIDCount]));
    q.Free;
  end;
end;

procedure TrplReplicationServer.CheckUpdateIDSQL(RelName: string);
begin
  if FUpdateIDSQL = nil then
  begin
    FUpdateIDSQL:= TIBSQL.Create(nil);
    FUpdateIDSQL.Transaction := ReplDataBase.Transaction;
  end;
  FUpdateIDSQL.Close;
  FUpdateIDSQL.SQL.Text:=
    'UPDATE ' + RelName + ' SET id=:newid WHERE id=:oldid';
  FUpdateIDSQL.Prepare;
end;

procedure TrplReplicationServer.CheckUpdateRUIDSQL;
begin
  if FUpdateRUIDSQL = nil then
  begin
    FUpdateRUIDSQL:= TIBSQL.Create(nil);
    FUpdateRUIDSQL.Transaction := ReplDataBase.Transaction;
    FUpdateRUIDSQL.SQL.Add(GetDeleteRUIDSQL);
    FUpdateRUIDSQL.Prepare;
  end;
  FUpdateRUIDSQL.Close;
end;

function TrplReplicationServer.GetUpdateRUIDSQL: string;
begin
  Result:= 'UPDATE gd_ruid SET id=:xid WHERE xid=:xid and dbid=:dbid';
end;

procedure TrplReplicationServer.CheckDeleteRUIDSQL;
begin
  if FDeleteRUIDSQL = nil then
  begin
    FDeleteRUIDSQL:= TIBSQL.Create(nil);
    FDeleteRUIDSQL.Transaction := ReplDataBase.Transaction;
    FDeleteRUIDSQL.SQL.Add(GetDeleteRUIDSQL);
    FDeleteRUIDSQL.Prepare;
  end;
  FDeleteRUIDSQL.Close;
end;

function TrplReplicationServer.GetDeleteRUIDSQL: string;
begin
  Result:= 'DELETE FROM gd_ruid WHERE xid=:xid and dbid=:dbid';
end;

function TrplReplicationServer.RecordWithIDExists(ID: integer; out RelName: string): boolean;
var
  q, q1: TIBSQL;
begin
  Result:= False;
  RelName:= '';
  q:= TIBSQL.Create(nil);
  q1:= TIBSQL.Create(nil);
  q.Transaction:= ReplDatabase.Transaction;
  q1.Transaction:= ReplDatabase.Transaction;
  q.SQL.Text:=
    'SELECT rdb$relation_name rn ' +
    'FROM rdb$relation_fields ' +
    'WHERE rdb$field_name = ''ID'' AND rdb$relation_name <> ''GD_RUID''';
  try
    q.ExecQuery;
    while not q.Eof do begin
      q1.Close;
      q1.SQL.Text:=
        'SELECT Count(*) ' +
        'FROM ' + q.FieldByName('rn').AsString +
        ' WHERE id = :id';
      try
        q1.Prepare;
        q1.ParamByName('id').AsInteger:= ID;
        q1.ExecQuery;
        if q1.Fields[0].AsInteger > 0 then begin
          Result:= True;
          RelName:= q.FieldByName('rn').AsString;
          Break;
        end;
      except
      end;
      q.Next;
    end;
  finally
    q.Free;
    q1.Free;
  end;
end;

procedure TrplReplicationServer.SaveFKsToDrop(Stream: TStream);
var
  SQL: TIBSQL;
  FKs: TrpForeignKeys;
  Str: TMemoryStream;
  i: integer;
  Rel: TmnRelation;
  Sl, slRel: TStringList;
begin
  SQL:= TIBSQL.Create(nil);
  FKs:= TrpForeignKeys.Create;
  Str:= TMemoryStream.Create;
  Sl:= TStringList.Create;
  slRel:= TStringList.Create;
  try
    SQL.Transaction:= ReplDataBase.ReadTransaction;
    SQL.SQL.Text:= 'SELECT fketalon FROM rpl$dbstate';
    try
      SQL.ExecQuery;
      SQL.FieldByName(fnFKEtalon).SaveToStream(Str);
      if Str.Size > 0 then begin
        Str.Position:= 0;
        FKs.ReadFromStream(Str);

        for i:= 0 to FReplLog.Count - 1 do begin
          if slRel.IndexOf(IntToStr(FReplLog[i].RelationKey)) = -1 then
            slRel.Add(IntToStr(FReplLog[i].RelationKey));
        end;

        for i:= FKs.Count - 1 downto 0 do begin
          Rel:= ReplicationManager.Relations.FindRelation(TrpForeignKey(FKs[i]).TableName);
          if Assigned(Rel) and (slRel.IndexOf(IntToStr(Rel.RelationKey)) > 0) then
            sl.Add(TrpForeignKey(FKs[i]).ConstraintName);
          Rel:= ReplicationManager.Relations.FindRelation(TrpForeignKey(FKs[i]).OnTableName);
          if Assigned(Rel) and (slRel.IndexOf(IntToStr(Rel.RelationKey)) > 0) then
            sl.Add(TrpForeignKey(FKs[i]).ConstraintName);
        end;

      end;
    except
    end;
    i:= sl.Count;
    Stream.Write(i, SizeOf(i));
    for i:= 0 to sl.Count - 1 do
      SaveStringToStream(sl[i], Stream);
  finally
    SQL.Free;
    FKs.Free;
    Str.Free;
    Sl.Free;
    slRel.Free;
  end;
end;

procedure TrplReplicationServer.LoadFKsToDrop(Stream: TStream);
var
  i, iCount: integer;
  s: string;
  {$IFDEF DROPFK}
  FKs: TrpForeignKeys;
  {$ENDIF}
begin
  {$IFDEF DROPFK}
  FFKsToDrop.Clear;
  {$ELSE}
  FRingFKs.Clear;
  {$ENDIF}
  if FStreamHeader.StreamInfo.Version < 3 then begin
    {$IFDEF DROPFK}
    FKs:= TrpForeignKeys.Create;
    try
      FKs.ReadKeys;
      for i:= 0 to FKs.Count - 1 do
        FFKsToDrop.Add(FKs.ForeignKeys[i].ConstraintName);
    finally
      FKs.Free;
    end;
    {$ENDIF}
    Exit;
  end;
  Stream.Read(iCount, SizeOf(iCount));
  for i:= 1 to iCount do begin
    s:= ReadStringFromStream(Stream);
    {$IFDEF DROPFK}
    FFKsToDrop.Add(s);
    {$ENDIF}
  end;

end;

function TrplReplicationServer.CheckCortegeRingFKs: boolean;
var
  F: TrpField;
  R: TrpRelation;
  i, iData: integer;
begin
  Result:= False;
  {$IFDEF DROPFK}
  Exit;
  {$ENDIF}
  if FEvent.ReplType = atDelete then Exit;
  try
  R:= FCortege.Relation;
  for I := 0 to R.Fields.Count - 1 do begin
    F := R.Fields[I];
    if F.IsForeign and (FForeignKeys.IndexOfKey(R.RelationName, F.FieldName) > -1) then begin
      iData:= FCortege.FieldsData.IndexOfData(R.Fields[i].FieldName);
      if iData > -1 then begin
        if not FCortege.FieldsData[iData].IsNull and not F.NotNull then begin
          if FRingFKs.IndexOfSeqNo(FEvent.Seqno) = -1 then
            FRingFKs.AddEvent(FEvent, FCortege);
          FCortege.FieldsData[iData].IsNull:= True;
          Result:= True;
        end;
      end;
    end;
  end;
  except
  end;
end;

procedure TrplReplicationServer.ProcessRingFKs;
var
  E: TrpErrorEvent;
  i: integer;
  FK: TrpRingFK;
begin
  {$IFDEF DROPFK}
    Exit;
  {$ENDIF}

  if FRingFKs.Count = 0 then Exit;

  ProgressState.Log(MSG_RING_FKS_UPDATE);
  E:= FCortege.OnPostError;
  ProgressState.MaxMinor := FRingFKs.Count;
  FCortege.OnPostError:= OnPostRingFKError;
  try
    for i:= FRingFKs.Count - 1 downto 0 do begin
      FK:= FRingFKs[i];
      FK.Data.Position := 0;
      DoReplEvent(FK.Data);
      FRingFKs.Delete(I);
      ProgressState.MinorProgress(Self);
    end;
  finally
    FCortege.OnPostError:= E;
  end;
end;

procedure TrplReplicationServer.OnPostRingFKError(SQL: TIBSQL;
  E: Exception; var DataAction: TDataAction);
begin
  if FIgnoreError then Exit;

  if (E is EIBError) then
  begin
    if EIBError(E).IBErrorCode = isc_foreign_key then begin
      if not FCortege.CheckFKRecords then begin
        DataAction := daAbort;
      end
      else begin
        CollectError(EIBError(E).IBErrorCode, EIBError(E).Message);
        DataAction := daAbort;
      end;
    end;
  end;
end;

{ TrpForeignKey }

function TrpForeignKey.AddDLL: string;
var
  lOnUpDate, lOnDelete: string;
begin
  if FUpDateRule <> 'RESTRICT' then
    lOnUpDate := ' ON UPDATE ' + FUpdateRule
  else
    lOnUpDate := '';

  if FDeleteRule <> 'RESTRICT' then
    lOnDelete := ' ON DELETE ' + FDeleteRule
  else
    lOnDelete := '';

  Result := 'ALTER TABLE ' + FTableName + ' ADD CONSTRAINT ' +
    FConstraintName + ' FOREIGN KEY (' + FFieldName + ' )' +
    'REFERENCES ' + FOnTableName + '(' + FOnFieldName + ')' +
    lOnUpDate + lOnDelete;
end;

function TrpForeignKey.DelDLL: string;
begin
  Result:= 'DELETE FROM ' + FTableName + ' tbl ' +
    'WHERE tbl.' + FFieldName + ' IS NOT NULL AND NOT EXISTS (' +
    '  SELECT DISTINCT ref.' + FOnFieldName + ' FROM ' + FOnTableName + ' ref ' +
    '  WHERE ref.' + FOnFieldName + ' = tbl.' + FFieldName + ')'
end;

function TrpForeignKey.DropDLL: string;
begin
  Result := 'ALTER TABLE ' + FTableName + ' DROP CONSTRAINT ' +
    FConstraintName;
end;

procedure TrpForeignKey.Read(SQL: TIBSQL);
begin
  FTableName := UpperCase(Trim(SQL.FieldByName(fnTableName).AsString));
  FFieldName := UpperCase(Trim(SQL.FieldByName(fnFieldName).AsString));
  FConstraintName := UpperCase(Trim(SQL.FieldByName(fnConstraintName).AsString));
  FOnTableName := UpperCase(Trim(SQL.FieldByName(fnOnTableName).AsString));
  FOnFieldName := UpperCase(Trim(SQL.FieldByName(fnOnFieldName).AsString));
  FDeleteRule := Trim(SQL.FieldByName(fnOnDelete).AsString);
  FUpdateRule := Trim(SQL.FieldByName(fnOnUpdate).AsString);
  FDropped := False;
end;

procedure TrpForeignKey.ReadFromStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  FConstraintName := ReadStringFromStream(Stream);
  FTableName := ReadStringFromStream(Stream);
  FFieldName := ReadStringFromStream(Stream);
  FOnTableName := ReadStringFromStream(Stream);
  FOnFieldName := ReadStringFromStream(Stream);
  FDeleteRule := ReadStringFromStream(Stream);
  FUpdateRule := ReadStringFromStream(Stream);
  Stream.ReadBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SaveToStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  SaveStringToStream(FConstraintName, Stream);
  SaveStringToStream(FTableName, Stream);
  SaveStringToStream(FFieldName, Stream);
  SaveStringToStream(FOnTableName, Stream);
  SaveStringToStream(FOnFieldName, Stream);
  SaveStringToStream(FDeleteRule, Stream);
  SaveStringToStream(FUpdateRule, Stream);
  Stream.WriteBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SetConstraintName(const Value: string);
begin
  FConstraintName := Value;
end;

procedure TrpForeignKey.SetDeleteRule(const Value: string);
begin
  FDeleteRule := Value;
end;

procedure TrpForeignKey.SetDropped(const Value: Boolean);
begin
  FDropped := Value;
end;

procedure TrpForeignKey.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

function TrpForeignKey.SetNullDLL: string;
begin
  Result:= 'UPDATE ' + FTableName + ' tbl ' +
    'SET tbl.' + FFieldName + ' = NULL ' +
    'WHERE tbl.' + FFieldName + ' IS NOT NULL AND NOT EXISTS (' +
    '  SELECT DISTINCT ref.' + FOnFieldName + ' FROM ' + FOnTableName + ' ref ' +
    '  WHERE ref.' + FOnFieldName + ' = tbl.' + FFieldName + ')'
end;

procedure TrpForeignKey.SetOnFieldName(const Value: string);
begin
  FOnFieldName := Value;
end;

procedure TrpForeignKey.SetOnTableName(const Value: string);
begin
  FOnTableName := Value;
end;

procedure TrpForeignKey.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

procedure TrpForeignKey.SetUpdateRule(const Value: string);
begin
  FUpdateRule := Value;
end;

{ TrpForeignKeys }

procedure TrpForeignKeys.AddKeys;
var
  I: Integer;
  SQL, FKSQL, FKSQL1: TIBSQL;
  Str: TMemoryStream;
begin
  {$IFNDEF DROPFK}
    Exit;
  {$ENDIF}
  ProgressState.Log(MSG_RESTORE_FKs);
  ProgressState.MaxMinor := Count;
  Str := TMemoryStream.Create;
  try
    FKSQL := TIBSQL.Create(nil);
    FKSQL1 := TIBSQL.Create(nil);
    try
      FKSQL.Transaction := ReplDataBase.Transaction;
      FKSQL1.Transaction := ReplDataBase.Transaction;
      FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fk = :fk';
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.Transaction;
        for I:= 0 to Count - 1 do begin
          if TrpForeignKey(Items[I]).Dropped then begin
            ReplDataBase.Connected := True;
            ReplDataBase.Transaction.StartTransaction;
            FKSQL1.SQL.Text := ForeignKeys[I].SetNullDLL;
            try
              FKSQL1.ExecQuery;
            except
              FKSQL1.SQL.Text := ForeignKeys[I].DelDLL;
              FKSQL1.ExecQuery;
            end;
            ReplDataBase.Transaction.Commit;
            ReplDataBase.Connected := False;

            ReplDataBase.Connected := True;
            ReplDataBase.Transaction.StartTransaction;

            SQL.SQL.Text := TrpForeignKey(Items[I]).AddDLL;
            try
              SQL.ExecQuery;
              SQL.Close;
              TrpForeignKey(Items[I]).Dropped := False;
              Str.Clear;
              SaveDroppedToStream(Str);
              Str.Position := 0;
              if Str.Size > 0 then
                FKSQL.ParamByName(fnFk).LoadFromStream(Str)
              else
                FKSQL.ParamByName(fnFk).Clear;
              FKSQL.ExecQuery;

              ReplDataBase.Transaction.Commit;
              ReplDataBase.Connected := False;

              ProgressState.Log(Format(MSG_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                TrpForeignKey(Items[I]).TableName]));
            except
              on E: Exception do
              begin
                ReplDataBase.Transaction.Rollback;
                ReplDataBase.Connected := False;
                ProgressState.Log(Format(ERR_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                  TrpForeignKey(Items[I]).TableName, E.Message]));
              end;
            end;
          end;
          ProgressState.MinorProgress(Self);
        end;
      finally
        SQL.Free;
      end;
    finally
      FKSQL.Free;
    end;
  finally
    Str.Free;
  end;
end;

function TrpForeignKeys.IndexOfKey(AName: string): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count - 1 do begin
    if AnsiUpperCase(ForeignKeys[i].ConstraintName) = AnsiUpperCase(AName) then begin
      Result:= i;
      Exit;
    end;
  end;
end;

function TrpForeignKeys.IndexOfKey(ARelName, AFieldName: string): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count - 1 do begin
    if (AnsiUpperCase(ForeignKeys[i].FieldName) = AnsiUpperCase(AFieldName)) and
       (AnsiUpperCase(ForeignKeys[i].TableName) = AnsiUpperCase(ARelName)) then begin
      Result:= i;
      Exit;
    end;
  end;
end;

procedure TrpForeignKeys.CompareWithEtalon;
var
  SQL: TIBSQL;
  FKs: TrpForeignKeys;
  Str: TMemoryStream;
  i: integer;
begin
  SQL:= TIBSQL.Create(nil);
  FKs:= TrpForeignKeys.Create;
  Str:= TMemoryStream.Create;
  try
    SQL.Transaction:= ReplDataBase.ReadTransaction;
    SQL.SQL.Text:= 'SELECT fketalon FROM rpl$dbstate';
    try
      SQL.ExecQuery;
      SQL.FieldByName(fnFKEtalon).SaveToStream(Str);
      if Str.Size > 0 then begin
        Str.Position:= 0;
        FKs.ReadFromStream(Str);
        for i:= FKs.Count - 1 downto 0 do begin
          if IndexOfKey(FKs.ForeignKeys[i].ConstraintName) = -1 then begin
            FKs.ForeignKeys[i].Dropped:= True;
            Add(FKs.ForeignKeys[i]);
            FKs.Extract(FKs.ForeignKeys[i]);
          end;
        end;
      end;
    except
    end;
  finally
    SQL.Free;
    FKs.Free;
    Str.Free;
  end;
end;

procedure TrpForeignKeys.DropKeys;
var
  I, Key: Integer;
  SQL, FKSQL: TIBSQL;
  Str: TMemoryStream;
  R: TrpRelation;
begin
  ProgressState.Log(MSG_DROPING_FK);
  if ReplicationServer.FFKsToDrop.Count = 0 then Exit;
  ReplDataBase.Connected := True;
  try
    ReadKeys;
    CompareWithEtalon;
    ProgressState.MaxMinor := ReplicationServer.FFKsToDrop.Count;
    Str := TMemoryStream.Create;
    try
      FKSQL := TIBSQL.Create(nil);
      try
        FKSQL.Transaction := ReplDataBase.Transaction;
        FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fk = :fk';
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := ReplDataBase.Transaction;
          for I := 0 to Count - 1 do
          begin
            if ReplicationServer.FFKsToDrop.IndexOf(TrpForeignKey(Items[I]).ConstraintName) = -1 then
              Continue;
            if not TrpForeignKey(Items[I]).Dropped and
                (ReplicationServer.FFKsToDrop.IndexOf(TrpForeignKey(Items[I]).ConstraintName) > 0) then
            begin
              ReplDataBase.Connected := True;
              ReplDataBase.Transaction.StartTransaction;

              //Перед тем как удалить внешний ключ необходимо
              //занести инфомацию в список таблиц
              Key := ReplDataBase.Relations.KeyByName(TrpForeignKey(Items[I]).TableName);
              R := ReplDataBase.Relations.Relations[Key];
              R.Load;
              SQL.SQL.Text := TrpForeignKey(Items[I]).DropDLL;
              try
                SQL.ExecQuery;
                SQL.Close;
                TrpForeignKey(Items[I]).Dropped := True;
                Str.Clear;
                SaveDroppedToStream(Str);
                Str.Position := 0;
                if Str.Size > 0 then
                  FKSQL.ParamByName(fnFk).LoadFromStream(Str)
                else
                  FKSQL.ParamByName(fnFk).Clear;
                FKSQL.ExecQuery;

                ReplDataBase.Transaction.Commit;
                ReplDataBase.Connected := False;

                ProgressState.Log(Format(MSG_DROP_FK, [TrpForeignKey(Items[I]).FieldName,
                  TrpForeignKey(Items[I]).TableName]));
              except
                on E: Exception do
                begin
                  ReplDataBase.Transaction.Rollback;
                  ReplDataBase.Connected := False;
                  ProgressState.Log(Format(MSG_DROP_FK, [TrpForeignKey(Items[I]).FieldName,
                    TrpForeignKey(Items[I]).TableName, E.Message]));
                end;
              end;
            end;
            ProgressState.MinorProgress(Self);
          end;
        finally
          SQL.Free;
        end;
      finally
        FKSQL.Free;
      end;
    finally
      Str.Free;
    end;
  finally
    ReplDataBase.Connected := False;
  end;
end;

function TrpForeignKeys.GetForeignKeys(Index: Integer): TrpForeignKey;
begin
  Result := TrpForeignKey(Items[Index]);
end;

procedure TrpForeignKeys.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
{  if Action = lnDeleted then
    TrpForeignKey(Ptr).Free;}
end;

procedure TrpForeignKeys.ReadFromStream(Stream: TStream);
var
  I: Integer;
  lCount: Integer;
  FK: TrpForeignKey;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Clear;
  Stream.ReadBuffer(lCount, SizeOf(lCount));
  for I := 0 to lCount - 1 do
  begin
    FK := TrpForeignKey.Create;
    FK.ReadFromStream(Stream);
    Add(Fk);
  end;
end;

procedure TrpForeignKeys.ReadKeys;
var
  SQL: TIBSQL;
  CSQL: TIBSQL;
  FK: TrpForeignKey;
begin
  Clear;

  CSQL := TIBSQL.Create(nil);
  try
    CSQL.Transaction := ReplDataBase.ReadTransaction;
    CSQL.SQL.Text := '/*Вытягивает циклические ссылки для таблиц учавствующих в репликации*/' +
      ' SELECT' +
      '  rc1.RDB$CONSTRAINT_NAME' +
      ' FROM' +
      '    RDB$RELATION_CONSTRAINTS rc1' +
      '    INNER JOIN RDB$REF_CONSTRAINTS refc1 ON (rc1.RDB$CONSTRAINT_NAME = refc1.RDB$CONSTRAINT_NAME)' +
      '    INNER JOIN RDB$RELATION_CONSTRAINTS rc2 ON (refc1.RDB$CONST_NAME_UQ = rc2.RDB$CONSTRAINT_NAME)' +
      '    INNER JOIN RDB$INDEX_SEGMENTS i_seg2 ON (rc2.RDB$INDEX_NAME = i_seg2.RDB$INDEX_NAME)' +
      '    INNER JOIN RDB$INDEX_SEGMENTS i_seg1 ON (rc1.RDB$INDEX_NAME = i_seg1.RDB$INDEX_NAME)' +
      ' WHERE' +
      '    rc1.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' and' +
      '   rc1.RDB$RELATION_NAME <> rc2.RDB$RELATION_NAME and' +
      '   EXISTS (' +
      '     SELECT' +
      '       rpl_r.RELATION' +
      '     FROM' +
      '       RPL$RELATIONS rpl_r' +
      '     WHERE' +
      '       rpl_r.RELATION = rc1.RDB$RELATION_NAME' +
      '     ) AND' +
      '   EXISTS (' +
      '     SELECT' +
      '       rc11.RDB$RELATION_NAME' +
      '     FROM' +
      '       RDB$RELATION_CONSTRAINTS rc11' +
      '       INNER JOIN RDB$REF_CONSTRAINTS refc11 ON (rc11.RDB$CONSTRAINT_NAME = refc11.RDB$CONSTRAINT_NAME)' +
      '       INNER JOIN RDB$RELATION_CONSTRAINTS rc12 ON (refc11.RDB$CONST_NAME_UQ = rc12.RDB$CONSTRAINT_NAME)' +
      '       INNER JOIN RDB$INDEX_SEGMENTS i_seg12 ON (rc12.RDB$INDEX_NAME = i_seg12.RDB$INDEX_NAME)' +
      '       INNER JOIN RDB$INDEX_SEGMENTS i_seg11 ON (rc11.RDB$INDEX_NAME = i_seg11.RDB$INDEX_NAME)' +
      '    WHERE' +
      '      rc11.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' and' +
      '      rc1.RDB$RELATION_NAME = rc12.RDB$RELATION_NAME and' +
      '      rc2.RDB$RELATION_NAME = rc11.RDB$RELATION_NAME' +
      '   )';
    CSQL.ExecQuery;
    if not CSQL.Eof then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.ReadTransaction;
        SQL.SQL.Text := '/*Вытягивает для внешних полей всю информацию о них*/' +
          ' SELECT' +
          '  RC1.RDB$CONSTRAINT_NAME as ConstraintName,' +
          '  I_S1.RDB$FIELD_NAME as FieldName,' +
          '  RC2.RDB$RELATION_NAME as OnTableName,' +
          '  I_S2.RDB$FIELD_NAME as OnFieldName,' +
          '  RC1.RDB$RELATION_NAME as TableName,' +
          '  REFC.rdb$update_rule AS OnUpdate,' +
          '  REFC.rdb$delete_rule as OnDelete' +
          ' FROM' +
          '  RDB$RELATION_CONSTRAINTS RC1' +
          '  INNER JOIN RDB$INDEX_SEGMENTS I_S1 ON (RC1.RDB$INDEX_NAME = I_S1.RDB$INDEX_NAME)' +
          '  INNER JOIN RDB$REF_CONSTRAINTS REFC ON (RC1.RDB$CONSTRAINT_NAME = REFC.RDB$CONSTRAINT_NAME)' +
          '  INNER JOIN RDB$RELATION_CONSTRAINTS RC2 ON (REFC.RDB$CONST_NAME_UQ = RC2.RDB$CONSTRAINT_NAME)' +
          '  INNER JOIN RDB$INDEX_SEGMENTS I_S2 ON (RC2.RDB$INDEX_NAME = I_S2.RDB$INDEX_NAME)' +
          ' WHERE' +
          '  RC1.RDB$CONSTRAINT_NAME = :CONSTRAINT_NAME';
        SQL.Prepare;

        while not CSQL.Eof do
        begin
          SQL.ParamByName('CONSTRAINT_NAME').AsString := CSQL.Fields[0].AsString;
          SQL.ExecQuery;

          if not SQL.Eof then
          begin
            FK := TrpForeignKey.Create;
            FK.Read(SQL);
            Add(FK);
          end;

          SQL.Close;
          CSQL.Next;
        end;
      finally
        SQL.Free;
      end;
    end;
  finally
    CSQL.Free;
  end;
end;

procedure TrpForeignKeys.RestoreKeys;
var
  I, J: Integer;
  SQL: TIBSQL;
  Str: TMemoryStream;
  fkKeys: TrpForeignKeys;
begin
  Clear;
  SQL := TIBSQL.Create(nil);
  try
    SQL.SQL.Text := 'SELECT fk, fketalon FROM rpl$dbstate';
    try
      ReplDataBase.Connected := True;
      SQL.Transaction := ReplDataBase.ReadTransaction;

      Str := TMemoryStream.Create;
      try
        SQL.ExecQuery;
        if SQL.FieldByName(fnFKEtalon).IsNull and SQL.FieldByName(fnFK).IsNull then begin
          ProgressState.Log('Добавление информации о циклических ссылках');
          ReadKeys;
          SaveToStream(Str);
          Str.Position := 0;
          SQL.Close;
          SQL.Transaction := ReplDataBase.Transaction;
          SQL.Transaction.StartTransaction;
          SQL.SQL.Text:= 'UPDATE rpl$dbstate SET fketalon = :fketalon';
          SQL.ParamByName(fnFKEtalon).LoadFromStream(Str);
          try
            SQL.ExecQuery;
            ReplDataBase.Transaction.Commit;
          except
            on E: Exception do
              ProgressState.Log('Ошибка при добавлении информации о циклических ссылках:'#13#10 + E.Message);
          end;
        end
        else begin
          if not SQL.FieldByName(fnFKEtalon).IsNull then begin
            SQL.FieldByName(fnFKEtalon).SaveToStream(Str);
            Str.Position := 0;
            if Str.Size > 0 then begin
              ReadFromStream(Str);
            end;
            for I := 0 to Count - 1 do
              ForeignKeys[I].Dropped:= False;
            if not SQL.FieldByName(fnFK).IsNull then begin
              fkKeys:= TrpForeignKeys.Create;
              try
                Str.Clear;
                SQL.FieldByName(fnFk).SaveToStream(Str);
                Str.Position := 0;
                fkKeys.ReadFromStream(Str);
                for I:= 0 to fkKeys.Count - 1 do
                  if fkKeys.ForeignKeys[I].Dropped then
                    ForeignKeys[IndexOfKey(fkKeys.ForeignKeys[I].ConstraintName)].Dropped:= True;
              finally
                fkKeys.Free;
              end;
            end;
          end
          else begin
            SQL.FieldByName(fnFk).SaveToStream(Str);
            Str.Position := 0;
            if Str.Size > 0 then begin
              ReadFromStream(Str);
            end;
          end;
        end;
      finally
        Str.Free;
      end;

      ReplDataBase.Connected := False;

      if Count > 0 then
      begin
        J := 0;
        for I := 0 to Count - 1 do
          if TrpForeignKey(Items[I]).Dropped then
            Inc(J);
        if J > 0 then
        begin
          ProgressState.Log(Format(MSG_FIND_NOT_RESTORE_FK, [J]));
          AddKeys;
        end;
      end;
    except
      on E: Exception do
      begin
        ReplDataBase.Connected := False;
      end;
    end;
  finally
    SQL.Free;
  end;
end;


procedure TrpForeignKeys.SaveDroppedToStream(Stream: TStream);
var
  I, iCount: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  iCount:= 0;
  for I := 0 to Count -1 do
    if TrpForeignKey(Items[I]).Dropped then
      Inc(iCount);

  if iCount = 0 then
    Stream.Size:= 0
  else begin
    Stream.WriteBuffer(iCount, SizeOf(iCount));
    for I := 0 to Count -1 do
      if TrpForeignKey(Items[I]).Dropped then
        TrpForeignKey(Items[I]).SaveToStream(Stream);
  end;
end;

procedure TrpForeignKeys.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count -1 do
    TrpForeignKey(Items[I]).SaveToStream(Stream);
end;

{ TrpTriggers }

procedure TrpTriggers.ActivateTriggers;
var
  Trigger: TrpTrigger;
  SQL: TIBSQL;
  Str: TStream;
  I: Integer;
begin
  {$IFDEF DEBUG}
  CheckDBConect;
  {$ENDIF}
  ReplDataBase.Connected := True;
  try
    SQL := TIBSQL.Create(nil);
    try
      ProgressState.Log(MSG_ACTIVATE_TRIGGERS);
      ProgressState.MaxMinor := Count;
      SQL.SQL.Text := 'UPDATE rpl$dbstate SET triggers = :triggers';
      SQL.Transaction := ReplDataBase.Transaction;

      try
        for I := Count - 1 downto 0 do
        begin
          Trigger := Triggers[I];
          if Trigger.State = tsInactive then
          begin
            ReplicationManager.ActivateTrigger(Trigger.Trigger, tsActive);
          end;
          Delete(I);
          ProgressState.MinorProgress(Self);
        end;

        ReplDataBase.Transaction.StartTransaction;

        if Count > 0 then
        begin
          Str := TMemoryStream.Create;
          try
            SaveToStream(Str);
            Str.Position := 0;
            SQL.ParamByName(fnTriggers).LoadFromStream(Str);
          finally
            Str.Free;
          end;
        end else
          SQL.ParamByName(fnTriggers).Clear;

        SQL.ExecQuery;
        ReplDataBase.Transaction.Commit;
      except
        on E: Exception do
        begin
          if RepldataBase.Transaction.InTransaction then
            ReplDataBase.Transaction.Rollback;
          ProgressState.Log(Format(ERR_ACTIVATE_TRIGGERS, [E.Message]));
          //Сохраняем сообщение об ошиьке в стек ошибок
          Errors.Add(Format(ERR_ACTIVATE_TRIGGERS, [E.Message]));
          //Делаем попытку сохранить информацию об отключенных триггерах
          ReplDataBase.Transaction.StartTransaction;
          try
            if Count > 0 then
            begin
              Str := TMemoryStream.Create;
              try
                SaveToStream(Str);
                Str.Position := 0;
                SQL.ParamByName(fnTriggers).LoadFromStream(Str);
              finally
                Str.Free;
              end;
            end else
              SQL.ParamByName(fnTriggers).Clear;

            SQL.ExecQuery;
            ReplDataBase.Transaction.Commit;
          except
            ReplDataBase.Transaction.RollBack;
            raise;
          end;

          raise;
        end;
      end;
    finally
      SQL.Free;
    end;
  finally
    ReplDataBase.Connected := False;
  end;
end;

{$IFDEF DEBUG}
procedure TrpTriggers.CheckDBConect;
begin
  if ReplDataBase.Connected then
    raise Exception.Create('Ошибка');
end;
{$ENDIF}
function TrpTriggers.GetTriggers(Index: Integer): TrpTrigger;
begin
  Result := TrpTrigger(Items[Index]);
end;

procedure TrpTriggers.InactivateTriggers;
var
  Trigger: TrpTrigger;
  SQL, uSQL: TIBSQL;
  Str: TStream;
  Count: Integer;
begin
  Clear;
  {$IFDEF DEBUG}
  CheckDBConect;
  {$ENDIF}
  ReplDataBase.Connected := True;
  try
    SQL := TIBSQL.Create(nil);
    try
      ProgressState.Log(MSG_INACTIVATE_TRIGGERS);
      ProgressState.MaxMinor := 0;
      SQL.Transaction := ReplDataBase.ReadTransaction;
      SQL.SQL.Text := 'SELECT Count(*) FROM rdb$triggers t JOIN rpl$relations r ON r.relation = t.rdb$relation_name WHERE ' +
          't.rdb$trigger_inactive = 0 AND (t.rdb$system_flag = 0 OR t.rdb$system_flag IS NULL)';
      SQL.ExecQuery;
      Count := SQL.Fields[0].AsInteger;
      ProgressState.MaxMinor := Count;

      SQL.Close;
      SQL.SQL.Text := 'SELECT t.* FROM rdb$triggers t JOIN rpl$relations r ON r.relation = t.rdb$relation_name WHERE ' +
          't.rdb$trigger_inactive = 0 AND (t.rdb$system_flag = 0 OR t.rdb$system_flag IS NULL)';
      SQL.ExecQuery;
      try
        uSQL := TIBSQL.Create(nil);
        try
          uSQL.SQL.Text := 'UPDATE rpl$dbstate SET triggers = :triggers';
          uSQL.Transaction := ReplDataBase.Transaction;
          while not SQL.Eof do
          begin
            Trigger := TrpTrigger.Create;
            Trigger.TriggerName := Trim(SQL.FieldByName('rdb$trigger_name').AsString);
            Trigger.RelationName := Trim(SQL.FieldByName('rdb$relation_name').AsString);
            Trigger.State := tsActive;
            Add(Trigger);
            ReplicationManager.ActivateTrigger(Trigger.Trigger, tsInactive);
            Trigger.State := tsInactive;

            ReplDataBase.Transaction.StartTransaction;
            Str := TMemoryStream.Create;
            try
              SaveToStream(Str);
              Str.Position := 0;
              uSQL.ParamByName(fnTriggers).LoadFromStream(Str);
              uSQL.ExecQuery;
              ReplDataBase.Transaction.Commit;
            finally
              Str.Free;
            end;

            ProgressState.MinorProgress(Self);
            SQL.Next;
          end;
        finally
          uSQL.Free;
        end;
      except
        on E: Exception do
        begin
          if ReplDataBase.Transaction.InTransaction then
            ReplDataBase.Transaction.Rollback;
          ProgressState.Log(Format(ERR_INACTIVATE_TRIGGERS, [E.Message]));
          //Сохраняем сообщение об ошиьке в стек ошибок
          Errors.Add(Format(ERR_INACTIVATE_TRIGGERS, [E.Message]));
          ProgressState.MaxMinor := Count;
          raise;
        end;
      end;
    finally
      SQL.Free;
    end;
  finally
    ReplDataBase.Connected := False;
  end;
end;

procedure TrpTriggers.LoadFromStream(Stream: TStream);
var
  LCount, I: Integer;
  Tr: TrpTrigger;
begin
  Clear;
  Stream.ReadBuffer(lCount, SizeOf(LCount));
  for I := 0 to lCount - 1 do
  begin
    Tr := TrpTrigger.Create;
    Tr.LoadFromStreem(Stream);
    Add(Tr);
  end;
end;

procedure TrpTriggers.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = lnDeleted then
    TrpTrigger(Ptr).Free;
end;

procedure TrpTriggers.RestoreTriggers;
var
  I, J: Integer;
  SQL: TIBSQL;
  Str: TMemoryStream;
begin
  Clear;
  SQL := TIBSQL.Create(nil);
  try
    SQL.SQL.Text := 'SELECT triggers FROM rpl$dbstate';
    try
      ReplDataBase.Connected := True;
      SQL.Transaction := ReplDataBase.ReadTransaction;

      Str := TMemoryStream.Create;
      try
        SQL.ExecQuery;
        SQL.FieldByName(fnTriggers).SaveToStream(Str);
        Str.Position := 0;
        if Str.Size > 0 then
        begin
          LoadFromStream(Str);
        end;
      finally
        Str.Free;
      end;

      ReplDataBase.Connected := False;

      if Count > 0 then
      begin
        J := 0;
        for I := 0 to Count - 1 do
          if Triggers[I].State = tsInactive then
            Inc(J);
        if J > 0 then
        begin
          ProgressState.Log(Format(MSG_FOUND_NOT_RESTORED_TRIGGERS, [J]));
          ActivateTriggers;
        end;
      end;
    except
      on E: Exception do
      begin
        ReplDataBase.Connected := False;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TrpTriggers.SaveToStream(Stream: TStream);
var
  I: Integer;
  T: TrpTrigger;
begin
  I := Count;
  Stream.WriteBuffer(I, SizeOf(I));
  for I := 0 to Count - 1 do
  begin
    T := Triggers[I];
    T.SaveToStream(Stream);
  end;
end;

{ TrpTrigger }

procedure TrpTrigger.AssignTrigger(T: TTrigger);
begin
  FPosition := T.Position;
  FRelationName := T.RelationName;
  FTriggerName := T.TriggerName;
  FBody := T.Body;
  FAction := T.Action;
  FActionPosition := T.ActionPosition;
  FState := T.State;
end;

function TrpTrigger.GetBody: string;
begin
  Result:= FBody;
end;

function TrpTrigger.GetTrigger: TTrigger;
begin
  Result.Position := FPosition;
  Result.RelationName := FRelationName;
  Result.TriggerName := FTriggerName;
  Result.Body := FBody;
  Result.Action := FAction;
  Result.ActionPosition := FActionPosition;
  Result.State := FState;
end;

procedure TrpTrigger.LoadFromStreem(Stream: TStream);
begin
  Stream.ReadBuffer(FPosition, SizeOF(FPosition));
  FRelationName := ReadStringFromStream(Stream);
  FTriggerName := ReadStringFromStream(Stream);
  FBody := ReadStringFromStream(Stream);
  Stream.ReadBuffer(FAction, SizeOf(FAction));
  Stream.ReadBuffer(FActionPosition, SizeOf(FActionPosition));
  Stream.ReadBuffer(FState, SizeOf(FState));
end;

procedure TrpTrigger.SaveToStream(Stream: TStream);
begin
  Stream.WriteBuffer(FPosition, SizeOf(FPosition));
  SaveStringToStream(FRelationName, Stream);
  SaveStringToStream(FTriggerName, Stream);
  SaveStringToStream(FBody, Stream);
  Stream.WriteBuffer(FAction, SizeOf(FAction));
  Stream.WriteBuffer(FActionPosition, SizeOf(FActionPosition));
  Stream.WriteBuffer(FState, SizeOf(FState));
end;

procedure TrpTrigger.SetAction(const Value: TTriggerAction);
begin
  FAction := Value;
end;

procedure TrpTrigger.SetActionPosition(
  const Value: TTriggerActionPosition);
begin
  FActionPosition := Value;
end;

procedure TrpTrigger.SetBody(const Value: string);
begin
  FBody := Value;
end;

procedure TrpTrigger.SetPosition(const Value: Integer);
begin
  FPosition := Value;
end;

procedure TrpTrigger.SetRelationName(const Value: string);
begin
  FRelationName := Value;
end;

procedure TrpTrigger.SetState(const Value: TTriggerState);
begin
  FState := Value;
end;

procedure TrpTrigger.SetTrigger(const Value: TTrigger);
begin
  AssignTrigger(Value);
end;

procedure TrpTrigger.SetTriggerName(const Value: string);
begin
  FTriggerName := Value;
end;

{ TrpRingFK }

destructor TrpRingFK.Destroy;
begin
  if Assigned(FData) then
    FreeAndNil(FData);

  inherited;
end;

function TrpRingFK.GetData: TStream;
begin
  if FData = nil then
    FData := TMemoryStream.Create;
  
  Result :=  FData;
end;

{ TrpRingFKs }

function TrpRingFKs.AddEvent(AEvent: TrpEvent; ACortege: TrpCortege): integer;
var
  FK: TrpRingFK;
begin
  FK:= TrpRingFK.Create;
  FK.SeqNo:= AEvent.Seqno;
  AEvent.SaveToStream(FK.Data);
  if AEvent.ReplType <> atDelete then
    ACortege.SaveToStream(FK.Data);

  Result:= inherited Add(FK);
end;

function TrpRingFKs.GetRingFK(AIndex: integer): TrpRingFK;
begin
  Result:= TrpRingFK(inherited Items[AIndex]);
end;

function TrpRingFKs.IndexOfSeqNo(ASeqNo: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count - 1 do
    if RingFKs[i].SeqNo = ASeqNo then begin
      Result:= i;
      Exit;
    end;
end;

initialization
finalization
  FreeAndNil(_ReplicationServer);
end.
