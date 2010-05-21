
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    rp_ReportServer.pas

  Abstract

    Gedemin project. REPORT SYSTEM.
    Components: TServerReport, TClientReport;
    It's cool system.

  Author

    Andrey Shadevsky

  Revisions history

    1.00   ~01.05.01    JKL        Initial version.
    1.01    03.11.01    JKL        Additional checking for looking for a Computer with
                                   ReportServer has been added.
    1.02    08.11.01    JKL        The system is more reliable.
    1.03    26.02.02    JKL        Some comments was added. It was so difficult to remember.
    1.03    01.04.03    DAlex      Script-module support and function vertion tracking.

--}

unit rp_ReportServer;

interface

{$DEFINE LogReport}

uses
  Classes, SysUtils, IBDatabase, rp_BaseReport_unit, IBSQL,
  IBQuery, DB, IBCustomDataSet, DBClient, Forms, Provider, ExtCtrls,
  rp_ReportScriptControl, Gedemin_TLB, Windows, {rp_msgConnectServer_unit,}
  ScktComp, gd_SetDatabase{, Messages, Contnrs},
  rp_report_const, gd_KeyAssoc{, gd_DebugLog};

const
  ScriptControlNotRegister = 'Класс Microsoft Script Control не зарегистрирован.';
  VersionReportStorage = $00000010;
  {!!!}
  // константа для отличия функции и отчета при передаче функции от клиента серверу отчетов
  FunctionIdentifier = 'THIS_IS_FUNCTION._USE_FOR_DISTINCTION_FUNCTION!!!';

type
  TBlockSize = Integer;

type
  TServerConnectionState = (rsIdle, rsRefresh, rsRebuild, rsOption, rsGetResult,
    rsDeleteResult);

type
  TrpSocketData = class;

  TrpSocketEvent = procedure(AnSocketData: TrpSocketData) of object;

  // Класс хранит отправляемые/принимаемые данные
  // Разбивает на логические части принимаемую информацию
  // и генерит событие для считывания
  // Класс отдельно не используется
  // При необходимости подключения к серверу использовать TrpServerSocketList
  TrpSocketData = class
  private
    FSocketHandle: Integer;
    FParams: Variant;
    FStaticParam: Variant;
    FReportResult: TReportResult;
    FUniqueClientKey: Cardinal;
    FReportKey: Integer;
    FIsRebuild: Boolean;
    FBuildDate: TDateTime;

    FEventTimer: TTimer;
    FSingleBlock: Boolean;

    FStreamData: TMemoryStream;
    FDataState: Boolean;
    FWaitSize: TBlockSize;

    FSocketEvent: TrpSocketEvent;
    FThreadCreate: TrpSocketEvent;

    procedure SeparateData;
    procedure UnionData;

    procedure OnTime(Sender: TObject);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Assign(AnSource: TrpSocketData);

    procedure ReadData(const AnBuffer; const AnSize: Integer);
    procedure WriteData(var AnBuffer);
    procedure GenerateEvent;

    property SocketHandle: Integer read FSocketHandle write FSocketHandle;
    property ExecuteResult: Variant read FParams write FParams;
    property StaticParam: Variant read FStaticParam write FStaticParam;
    property ReportResult: TReportResult read FReportResult;
    property ReportKey: Integer read FReportKey write FReportKey;
    property UniqueClientKey: Cardinal read FUniqueClientKey write FUniqueClientKey;
    property IsRebuild: Boolean read FIsRebuild write FIsRebuild;
    property BuildDate: TDateTime read FBuildDate write FBuildDate;

    property SingleBlock: Boolean read FSingleBlock write FSingleBlock;

    property OnSocketEvent: TrpSocketEvent read FSocketEvent write FSocketEvent;
    property OnThreadCreate: TrpSocketEvent read FThreadCreate write FThreadCreate;
  end;

type
  TBaseReport = class(TComponent)
  private
    FOnCreateObject: TOnCreateObject;
    FOnCreateGlobalObj: TOnCreateObject;
    FOnCreateConst: TOnCreateObject;
    FOnCreateVBClasses: TOnCreateObject;
    FOnIsCreated: TNotifyEvent;

    FLocStateDB, FLocStateTR: Boolean;
    FLocState: Integer;
    {$IFNDEF GEDEMIN}
    FVBClasses: String;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    FConstants: String;
    {$ENDIF}
//    FVBObjects: String;
    FLogFileName: String;
    FCreateEventLoad: Boolean;
    FNonLoadSFList: TgdKeyDuplArray;
    Fgd_functionVers: Integer;

    function  GetDatabase: TIBDatabase;
    {$IFNDEF GEDEMIN}
    function  GetNonLoadSFList: TgdKeyArray;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    function  Get_gd_functionVersion: Integer;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure CreateModuleVBClass(Sender: TObject;
      const ModuleCode: Integer; VBClassArray: TgdKeyArray);
    {$ENDIF}

    procedure SetDatabase(const AnDatabase: TIBDatabase);
    procedure SetOnCreateObject(const Value: TOnCreateObject);
    procedure SetOnCreateConst(const Value: TOnCreateObject);
    procedure SetOnCreateGlobalObj(const Value: TOnCreateObject);
    procedure SetOnCreateVBClasses(const Value: TOnCreateObject);
    procedure SetOnIsCreated(const Value: TNotifyEvent);

    {$IFNDEF GEDEMIN}
    procedure SetNonLoadSFList(const Value: TgdKeyArray);
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure SetOnCreateEvets;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure CreateVBClassesLists;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateVBConstLists;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateVBClasses(Sender: TObject);
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateConstans(Sender: TObject);
    {$ENDIF}

    procedure SaveLog(const S: String); virtual;
  protected
    FReportList: TReportList;

   {$IFNDEF GEDEMIN}
    FReportScriptControl: TReportScript;
   {$ENDIF}

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure PrepareSourceDatabase; virtual;
    procedure UnPrepareSourceDatabase; virtual;

    procedure CheckScriptControl;

    function ExecuteFunctionWithoutParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
      var AnParamAndResult: Variant): Boolean;
    function InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
    procedure SetTransactionParams; virtual;
    function FindReportNow(const AnReportKey: Integer;
      const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean = True): Boolean;
    function FindFunctionNow(const AnFunctionKey: Integer;
      const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean = True): Boolean;

  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    function ExecuteFunctionWithParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
      var AnParamAndResult: Variant): Boolean;

    procedure Refresh; virtual;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    {$IFNDEF GEDEMIN}
    property NonLoadSFList: TgdKeyArray read GetNonLoadSFList write SetNonLoadSFList;
    {$ENDIF}
    property OnCreateConst: TOnCreateObject read FOnCreateConst write SetOnCreateConst;
    property OnCreateGlobalObj: TOnCreateObject read FOnCreateGlobalObj write SetOnCreateGlobalObj;
    property OnCreateObject: TOnCreateObject read FOnCreateObject write SetOnCreateObject;
    property OnCreateVBClasses: TOnCreateObject read FOnCreateVBClasses write SetOnCreateVBClasses;
    property OnIsCreated: TNotifyEvent read FOnIsCreated write SetOnIsCreated;
  end;

type
  PSocketServerParam = ^TSocketServerParam;
  TSocketServerParam = record
    ServerName: String[60];
    ServerKey: Integer;
    ServerPort: Integer;
  end;

// Класс предназначен для хранения сокета и данных
type
  TrpServerSocket = class
  private
    FClientSocket: TClientSocket;
    FSocketData: TrpSocketData;
    FSafeCounter: Integer;
    FServerKey: Integer;

    procedure SetHost(const AnHost: String);
    function GetHost: String;
    procedure SetPort(const AnPort: Integer);
    function GetPort: Integer;
  public
    constructor Create(const AnHost: String; const AnPort, AnServerKey: Integer);
    destructor Destroy; override;

    property ClientSocket: TClientSocket read FClientSocket;
    property SocketData: TrpSocketData read FSocketData;
    property Host: String read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property ServerKey: Integer read FServerKey write FServerKey;
    property SafeCounter: Integer read FSafeCounter;// write FSafeCounter;
  end;

// Класс для хранения списка доступных серверов системы
type
  TrpServerSocketList = class(TList)
  private
//    FmsgConnectServer: TmsgConnectServer;
    FConnectedFlag: Boolean;
    FSocketDataList: TList;
    FSocketEvent: TrpSocketEvent;

    function GetServerCount: Integer;

    procedure ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientError(Sender: TObject; Socket: TCustomWinSocket;
     ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);

    procedure ShowSocketErrorMessage(Sender: TObject);
    function GetServerSocket(const AnIndex: Integer): TrpServerSocket;

    function ServerSocketBySocket(AnSocket: TCustomWinSocket): TrpServerSocket;
    function ServerSocketByClientSocket(AnClientSocket: TClientSocket): TrpServerSocket;
    procedure SetSocketEvent(const AnSocketEvent: TrpSocketEvent);
    function GetServer(const AnIndex: Integer): TrpServerSocket;
  protected
    function CheckServerExists(const AnServerName: String): Boolean;
    {gs} // Удалить если не используется
    function ServerSocketByServerData(AnSocketData: TrpSocketData): TrpServerSocket;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear; override;

    // Добавление сервера в список. Выполняется вручную программистом.
    function AddServerSocket(const AnHost: String; const AnPort, AnServerKey: Integer): Integer;

    property ServerSocket[const AnIndex: Integer]: TrpServerSocket read GetServerSocket;
    function ActivateReportServer(const AnServerSocket: TClientSocket): Boolean;

    // Запрос сервера
    function QueryServer(const AnHost: String): TrpServerSocket; overload;
    // Запрос сервера
    function QueryServer(const AnServerKey: Integer): TrpServerSocket; overload;
    // Необходимо вызывать после получения результата, но пока не реализованно
    function Release(const AnServerSocket: TrpServerSocket): Integer; overload;
    function Release(const AnSocketData: TrpSocketData): Integer; overload;
    // Количество серверов
    property ServerCount: Integer read GetServerCount;
    // Событие по которому возвращается результат построения отчета
    property OnThreadCreate: TrpSocketEvent read FSocketEvent write SetSocketEvent;
  end;

(*type
  TClientReport = class(TBaseReport)
  private
    FViewReport: TvwReport;

    FDoit: TOnSignal;

    FibsqlServerName: TIBSQL;

    FServerList: TrpServerSocketList;
    FDefaultServer: TrpServerSocket;

    FReportFactory: TReportFactory;

    FUniqueValue: Cardinal;
    FProgressForm: TprgReportCount;
    FClientEventFactory: TClientEventFactory;

    FFirstRead: Boolean;

    procedure PrepareReportServer;
    procedure UnPrepareReportServer;
    function ClientQueryToServer(const AnCurrentServer: TClientSocket; const AnReportKey: Integer;
     const AnReportResult: TReportResult; var AnParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
    function ClientQuery(const ReportData: TCustomReport; const ReportResult: TReportResult;
     var ParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
    procedure ViewResult(const AnReport: TCustomReport; const AnReportResult: TReportResult;
     const AnParam: Variant; const AnBuildDate: TDateTime);
    function ExecuteReport(const AnReport: TCustomReport; const AnResult: TReportResult;
     out AnErrorMessage: String; const AnIsRebuild: Boolean): Boolean;
    function GetDefaultServer: TSocketServerParam;

    procedure ClientEvent(AnSocketData: TrpSocketData);
    procedure FinishExecute(Sender: TObject; var Action: TCloseAction);
    procedure CheckLoaded;
  protected
    function GetReportServerName(const AnServerKey: Integer): String;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure BuildReportWithParam(const AnReportKey: Integer; const AnParam: Variant; const AnIsRebuild: Boolean = False);
    {gs} // Удалить если не используется
    function GetUniqueClientKey: Cardinal;
    procedure CreateNewTemplate(AnIBSQL: TIBSQL; AnTemplate: TTemplateStructure);
    procedure CreateNewFunction(AnIBSQL: TIBSQL; AnFunction: TrpCustomFunction);
    procedure CreateNewReport(AnReport: TCustomReport);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure BuildReport(const AnReportKey: Integer; const AnIsRebuild: Boolean = False);
    procedure Execute(const AnGroupKey: Integer = 0);
    procedure Refresh; override;
    property DefaultServer: TSocketServerParam read GetDefaultServer;
    function DoAction(const AnKey: Integer; const AnAction: TActionType): Boolean;
    procedure SaveReportToFile(const AnReportKey: Integer;
     const AnFileName: String = '');
    function LoadReportFromFile(const AnGroupKey: Integer; const AnFileName: String = ''): Boolean;

    // Only For Testing
    property ReportList: TReportList read FReportList;
  published
    property OnCreateObject;
    property Database;
    property ReportFactory: TReportFactory read FReportFactory write FReportFactory;
  end;
*)
type
  TServerReport = class(TBaseReport)
  private
    FResultDatabase: TIBDatabase;
    FResultTransaction: TIBTransaction;
    //FLogFile: TFileStream;
    FLogFileName: String;

    FibdsResult: TIBDataSet;
    FLocResultTable: TClientDataSet;

    FServerState: TServerConnectionState;

    FServerKey: Integer;
    FComputerName: String;
    FResultPath: String;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FFrqDataRead: TDateTime;
    FActualReport: Integer;
    FUnactualReport: Integer;
    FIBParams: String;
    FLastBuildDate: Cardinal;

    FSourceType: Integer;
    FSourceState: Integer;

    FRefreshTimer: TTimer;
    FServerSocket: TServerSocket;

    FSocketList: TList;

    FCloseSourceConection: TTimer;

    FThisFunc: Boolean;

    FLastErrorMsg: String;

    // Подготовка хранилища для использования
    procedure PrepareResultDataSet;
    // Получение отфильтрованного хранилища
    function GetFiltredDataSet(const AnFilterText: String): TDataSet;
    // Получение хранилища
    function GetResultDataSet: TDataSet;
    // Завершение использования хранилища
    procedure UnPrepareResultDataSet;
    // Делаем Commit где надо
    procedure CommitResultDataSet;

    // Подготовка структуры хранилища для TClientDataSet
    procedure CopyResultFields(const AnClientDataSet: TClientDataSet);

    // Поиск результата отчета в хранилище
    function FindReportResult(const AnReport: TCustomReport; const AnParam: Variant;
     const AnReportResult: TrpResultStructure; const AnIsUpdateUsed: Boolean = False): Boolean;
    // Обновление результата отчета в хранилище
    procedure UpdateReportResult(const AnFunction: TrpCustomFunction; const AnrpResStruct: TrpResultStructure);
    // Добавление результата отчета в хранилище
    procedure InsertReportResult(const AnFunction: TrpCustomFunction; const AnrpResStruct: TrpResultStructure);
    // Удаление не актуальных результатов отчетов из хранилища
    procedure DeleteUnactualReport;
    // СПЕЦИАЛЬНО БОЛЬШИМИ БУКВАМИ
    // ПРОВЕРКА АКТУАЛЬНОСТИ ОТЧЕТА
    function CheckActualReport(const AnReport: TCustomReport;
     const AnResultStruct: TrpResultStructure): Boolean;
    procedure ServerThreadEvent(AnSocketData: TrpSocketData);
    procedure ServerEvent(AnSocketData: TrpSocketData);

    procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerClientError(Sender: TObject; Socket: TCustomWinSocket;
     ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    function GetActiveConnections: Integer;

    // Проверка структуры хранилища для TClientDataSet
    function CheckFieldsStructure(const AnClientDataSet: TClientDataSet): Boolean;
    // Подготовка списка отчетов подлежащих перестройке
    procedure PrepareReportList(const AnReportList: TReportList);
    // Выполнить отчет и сохранить результат
    procedure ExecuteReportAndSaveResult(const AnReport: TCustomReport; const AnParam: Variant);
    procedure RefreshReport(const AnReport: TCustomReport);
  protected
    procedure RefreshTimerExecute(Sender: TObject); virtual;
    procedure CloseTimerExecute(Sender: TObject); virtual;
    procedure PrepareSourceDatabase; override;
    procedure UnPrepareSourceDatabase; override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    // Работа с .log файлом
    procedure SaveLog(const S: String); override;
    // Закрытие соединения с базой, если это возможно
    procedure CloseConnection;
    // Перестройка результатов отчетов
    procedure RebuildReports;
    // Получить результат отчета
    function GetReportResult(const AnReportKey: Integer; const AnParam: Variant;
     const AnReportResult: TReportResult; const AnIsMakeRebuild: Boolean;
     out AnBuildDate: TDateTime): Variant;

    // dalex
    // Получить результат функции
    function GetFunctionResult(const AnFunctionKey: Integer;
     const AnParam: Variant; const AnReportResult: TReportResult;
     const AnIsMakeRebuild: Boolean; out AnBuildDate: TDateTime): Variant;
    // !dalex

    // Настройки сервера
    function ServerOptions: Boolean;
    // Загрузка сервера
    procedure Load;
    // Удаление всех результатов из хранилища
    procedure DeleteResult;

    property ServerKey: Integer read FServerKey;
    property ActiveConnections: Integer read GetActiveConnections;
    // Для определения, что это функия, а не отчет
    property ThisFunc: Boolean read FThisFunc write FThisFunc;

    property OnCreateConst;
    property OnCreateGlobalObj;
    property OnCreateVBClasses;
  published
    property OnCreateObject;
    property Database;
  end;

(*
// Глобальная переменная слиентской части отчетов
// ВНИМАНИЕ! Должен быть только один такой компонент
var
  ClientReport: TClientReport;*)

procedure WriteError(AnError: String);
procedure ProcErrorSocket(ErrorCode: Integer);

procedure Register;

implementation

uses
  jclMath, rp_dlgReportOptions_unit, gd_security_operationconst,
  WinSock, FileCtrl, rp_ExecuteThread_unit, gd_directories_const,
  prm_ParamFunctions_unit, flt_ScriptInterface,
 {$IFDEF GEDEMIN}
  gd_i_ScriptFactory,
 {$ENDIF}
  flt_IBUtils
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$IFNDEF GEDEMIN}
{$R Gedemin.TLB}
{$ENDIF}

procedure WriteError(AnError: String);
var
  FStr: TFileStream;
  S: String;
begin
  try
    AnError := AnError + ' ' + DateTimeToStr(Now) + #13#10;
    S := ChangeFileExt(Application.EXEName, '.log');
    if FileExists(S) then
      FStr := TFileStream.Create(S, fmOpenWrite)
    else
      FStr := TFileStream.Create(S, fmCreate);
    try
      FStr.Position := FStr.Size;
      FStr.Write(AnError[1], Length(AnError));
    finally
      FStr.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'SaveLog', MB_OK or MB_TASKMODAL);
  end;
end;

function rpSetServerState(const AnState: TServerConnectionState): String;
begin
  case AnState of
    rsIdle: Result := 'Свободен';
    rsRefresh: Result := 'Обновление';
    rsRebuild: Result := 'Перестройка';
    rsOption: Result := 'Параметры';
    rsGetResult: Result := 'Вызов клиентом';
  else
    Result := 'Unknown'
  end;
end;

{
function rpGetTemporaryFileName(const Prefix: string): string;
var
  Buffer: array[0..MAX_PATH] of Char;
  Path: string;
begin
  Result := 'reportserver.log';
  Path := Application.GetNamePath + 'Log\';
  if not DirectoryExists(Path) then
    if not CreateDir(Path) then
      Exit;
  GetTempFileName(PChar(Path), PChar(Prefix), 0, Buffer);
  DeleteFile(Buffer);
  Result := Buffer;
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result))) + '.log';
end;
}

// TrpSocketData

constructor TrpSocketData.Create;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.Create');
  {$ENDIF}
  FReportResult := TReportResult.Create;
  FReportResult.IsStreamData := True;
  FStreamData := TMemoryStream.Create;
  FSocketEvent := nil;
  FEventTimer := TTimer.Create(nil);
  FEventTimer.Enabled := False;
  FEventTimer.Interval := 100;
  FEventTimer.OnTimer := OnTime;
  FUniqueClientKey := 0;
  FSingleBlock := True;
  FIsRebuild := False;
  Clear;
end;

destructor TrpSocketData.Destroy;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.Destroy');
  {$ENDIF}
  FreeAndNil(FReportResult);
  FreeAndNil(FStreamData);
  FSocketEvent := nil;
  FreeAndNil(FEventTimer);

  inherited;
end;

procedure TrpSocketData.Clear;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.Clear');
  {$ENDIF}
  FStreamData.Size := 0;
  FDataState := False;
  FWaitSize := 0;
  FIsRebuild := False;
end;

procedure TrpSocketData.Assign(AnSource: TrpSocketData);
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.Assign');
  {$ENDIF}
  FSocketHandle := AnSource.SocketHandle;
  FParams := AnSource.ExecuteResult;
  FStaticParam := AnSource.StaticParam;
  FReportResult.Assign(AnSource.ReportResult);
  FUniqueClientKey := AnSource.UniqueClientKey;
  FReportKey := AnSource.ReportKey;
  FIsRebuild := AnSource.IsRebuild;
end;

procedure TrpSocketData.SeparateData;
var
  VarStr: TVarStream;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.SeparateData');
  {$ENDIF}
  FStreamData.Position := 0;
  try
    FStreamData.ReadBuffer(FReportKey, SizeOf(FReportKey));
    FStreamData.ReadBuffer(FIsRebuild, SizeOf(FIsRebuild));
    FStreamData.ReadBuffer(FBuildDate, SizeOf(FBuildDate));

    VarStr := TVarStream.Create(FStreamData);
    try
      VarStr.Read(FParams);
      VarStr.Read(FStaticParam);
    finally
      VarStr.Free;
    end;

    FReportResult.TempStream.Clear;
    FReportResult.TempStream.CopyFrom(FStreamData, FStreamData.Size - FStreamData.Position);
  except
    on E: Exception do
    begin
      ExecuteResult := E.Message;
      GenerateEvent;
      Clear;
      raise;
    end;
  end;
  GenerateEvent;
end;

procedure TrpSocketData.UnionData;
var
  VarStr: TVarStream;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.UnionData');
  {$ENDIF}
  FStreamData.Size := 0;

  FStreamData.WriteBuffer(FReportKey, SizeOf(FReportKey));
  FStreamData.WriteBuffer(FIsRebuild, SizeOf(FIsRebuild));
  FStreamData.WriteBuffer(FBuildDate, SizeOf(FBuildDate));

  VarStr := TVarStream.Create(FStreamData);
  try
    VarStr.Write(FParams);
    VarStr.Write(FStaticParam);
  finally
    VarStr.Free;
  end;

  if FReportResult.IsStreamData then
    FReportResult.TempStream.SaveToStream(FStreamData)
  else
    FReportResult.SaveToStream(FStreamData);
  FWaitSize := FStreamData.Size;
end;

procedure TrpSocketData.OnTime(Sender: TObject);
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.OnTime');
  {$ENDIF}
  FEventTimer.Enabled := False;
  if Assigned(FSocketEvent) then
    FSocketEvent(Self);
end;

procedure TrpSocketData.ReadData(const AnBuffer; const AnSize: Integer);
var
  CopyIndex: Integer;
  CopySize: Integer;
  CopyIndex2: Integer;

  function CheckEndBuffer(const AnIndex: Integer): Boolean;
  begin
    Result := (AnIndex = FWaitSize);
    if Result then
      FStreamData.Size := FWaitSize;
  end;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.ReadData');
  {$ENDIF}
  CopyIndex := 0;
  CopySize := 0;
  if not FDataState then
  begin
    CopyIndex := Pos(rpStartBlock, PString(@AnBuffer)^);
    if CopyIndex > 0 then
    begin
      Clear;
      TDnByteArray(AnBuffer)[CopyIndex - 1] := 0;
      CopyIndex := CopyIndex + Length(rpStartBlock) - 1;
      CopyMemory(@FWaitSize, @TDnByteArray(AnBuffer)[CopyIndex], SizeOf(FWaitSize));
      CopyIndex := CopyIndex + SizeOf(FWaitSize);
      CopySize := AnSize - CopyIndex;

      FDataState := True;
    end;
  end else
    CopySize := AnSize;

  FStreamData.WriteBuffer(TDnByteArray(AnBuffer)[CopyIndex], CopySize);

  if (FStreamData.Size > FWaitSize) then
  begin
    CopyIndex := Pos(rpFinishBlock, PString(@AnBuffer)^);
    while (CopyIndex > 0) do
    begin
      TDnByteArray(AnBuffer)[CopyIndex - 1] := 0;
      if CheckEndBuffer(CopyIndex + FStreamData.Size - AnSize - 1) then
      begin
        SeparateData;
        Break;
      end;
      CopyIndex := Pos(rpFinishBlock, PString(@AnBuffer)^);
    end;
    Clear;

    if not FSingleBlock then
      if CopyIndex + Length(rpFinishBlock) < AnSize then
      begin
        CopyIndex2 := Pos(rpStartBlock, PString(@AnBuffer)^);
        while (CopyIndex + Length(rpFinishBlock) > CopyIndex2) and (CopyIndex2 > 0) do
        begin
          TDnByteArray(AnBuffer)[CopyIndex2 - 1] := 0;
          CopyIndex2 := Pos(rpStartBlock, PString(@AnBuffer)^);
        end;
        ReadData(AnBuffer, AnSize);
      end;
  end;
end;

procedure TrpSocketData.WriteData(var AnBuffer);
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.WriteData');
  {$ENDIF}
  UnionData;
  SetLength(TDnByteArray(AnBuffer), Length(rpStartBlock) + Length(rpFinishBlock) +
   SizeOf(FWaitSize) + FStreamData.Size);
  CopyMemory(@TDnByteArray(AnBuffer)[0], @rpStartBlock[1], Length(rpStartBlock));
  CopyMemory(@TDnByteArray(AnBuffer)[Length(rpStartBlock)], @FWaitSize, SizeOf(FWaitSize));
  CopyMemory(@TDnByteArray(AnBuffer)[Length(rpStartBlock) + SizeOf(FWaitSize)],
   FStreamData.Memory, FStreamData.Size);
  CopyMemory(@TDnByteArray(AnBuffer)[Length(TDnByteArray(AnBuffer)) - Length(rpFinishBlock)],
   @rpFinishBlock[1], Length(rpFinishBlock));
end;

procedure TrpSocketData.GenerateEvent;
begin
  {$IFDEF DEBUG}
  WriteError('TrpSocketData.GenerateEvent');
  {$ENDIF}
  if Assigned(FThreadCreate) then
    FThreadCreate(Self);

  FEventTimer.Enabled := True;
end;

// TBaseReport

constructor TBaseReport.Create(Owner: TComponent);
begin
  {$IFDEF DEBUG}
  SaveLog('    Create');
  {$ENDIF}
  inherited Create(Owner);

  FLogFileName := '';
  FCreateEventLoad := False;
  FReportList := nil;
  FTransaction := nil;
  {$IFNDEF GEDEMIN}
  FReportScriptControl := nil;
  {$ENDIF}
  Fgd_functionVers := 0;

  if not (csDesigning in ComponentState) then
  begin
    FNonLoadSFList := TgdKeyDuplArray.Create;
    FNonLoadSFList.Duplicates := dupIgnore;
    FTransaction := TIBTransaction.Create(Self);
    SetTransactionParams;
    FReportList := TReportList.Create;
    FReportList.Transaction := FTransaction;
   {$IFNDEF GEDEMIN}
    try
      FReportScriptControl := TReportScript.CreateWithParam(Self, True, True);
      FReportScriptControl.Transaction := FTransaction;
      FReportScriptControl.OnCreateModuleVBClasses := CreateModuleVBClass;

    except
      (*on E: Exception do
      begin
        {MessageBox(0, PChar(ScriptControlNotRegister + #13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
        Abort;
      end;*)
    end;
   {$ENDIF}
  end;
end;

destructor TBaseReport.Destroy;
begin
  {$IFDEF DEBUG}
  SaveLog('    Destroy');
  {$ENDIF}
  if Assigned(FReportList) then
    FReportList.Free;
  {$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.Free;
  {$ENDIF}
  if Assigned(FTransaction) then
    FTransaction.Free;
  if Assigned(FNonLoadSFList) then
    FNonLoadSFList.Free;

  inherited Destroy;
end;

procedure TBaseReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  {$IFDEF DEBUG}
  SaveLog('    Notification ' + AComponent.ClassName);
  {$ENDIF}
  inherited Notification(AComponent, Operation);

  if (Operation = Classes.opRemove) and (FDatabase <> nil)
    and (AComponent = FDatabase) then FDatabase := nil;
end;

function TBaseReport.GetDatabase: TIBDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    GetDatabase');
  {$ENDIF}
  Result := FDatabase;
end;

procedure TBaseReport.SetDatabase(const AnDatabase: TIBDatabase);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetDatabase');
  {$ENDIF}
  FDatabase := AnDatabase;
  if Assigned(FTransaction) then
  begin
    if FTransaction.InTransaction then
      FTransaction.Commit;
    FTransaction.DefaultDatabase := FDatabase;

    FReportList.Database := FDatabase;

//    CreateLists;
//    SetOnCreateVBClasses(CreateVBClasses);
//    SetOnCreateConst(CreateConstans);

//    FReportScriptControl.CreateConst;
//    FReportScriptControl.CreateObject;
//    FReportScriptControl.CreateVBClasses;
  end;
end;

procedure TBaseReport.SetOnCreateObject(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateObject');
  {$ENDIF}
  FOnCreateObject := Value;
  {$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateObject := FOnCreateObject;
  {$ENDIF}
end;

function TBaseReport.ExecuteFunctionWithParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
 var AnParamAndResult: Variant): Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog('    ExecuteFunctionWithParam');
  {$ENDIF}
  Result := False;
  if InputParams(AnFunction, AnParamAndResult) then
    Result := ExecuteFunctionWithoutParam(AnFunction, AnReportResult, AnParamAndResult);
end;

function TBaseReport.ExecuteFunctionWithoutParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
 var AnParamAndResult: Variant): Boolean;
var
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  VarResult: Variant;
 {$IFNDEF GEDEMIN}
  LocRpScrCtrl: TReportScript;
 {$ENDIF}

  TempInt: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    ExecuteFunctionWithoutParam');
  {$ENDIF}
  try
   {$IFDEF GEDEMIN}
    try
      Result := True;
      ScriptFactory.ExecuteFunction(AnFunction, AnParamAndResult);
    except
      Result := False;
    end;
   {$ELSE}
    if FReportScriptControl.IsBusy then
    begin
      LocRpScrCtrl := TReportScript.CreateWithParam(nil, True, True);
      try
        LocRpScrCtrl.OnCreateConst := FReportScriptControl.OnCreateConst;
        LocRpScrCtrl.OnCreateVBClasses := FReportScriptControl.OnCreateVBClasses;
        LocRpScrCtrl.OnCreateObject := FReportScriptControl.OnCreateObject;
        LocRpScrCtrl.OnIsCreated := FReportScriptControl.OnIsCreated;
        LocRpScrCtrl.OnCreateModuleVBClasses := FReportScriptControl.OnCreateModuleVBClasses;
        LocRpScrCtrl.Transaction := FTransaction;

        Result := LocRpScrCtrl.ExecuteFunction(AnFunction, AnParamAndResult);
      finally
        LocRpScrCtrl.Free;
      end;
    end else
    begin
      FReportScriptControl.Reset;
      Result := FReportScriptControl.ExecuteFunction(AnFunction, AnParamAndResult);
    end;
   {$ENDIF}

    if Result then
    begin
      if AnFunction.Module = MainModuleName then
        if VarType(AnParamAndResult) = varDispatch then
        begin
          LocDispatch := AnParamAndResult;
          LocReportResult := LocDispatch as IgsQueryList;
          try
            VarResult := LocReportResult.ResultStream;

            AnReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) - VarArrayLowBound(VarResult, 1) + 1;
            CopyMemory(AnReportResult.TempStream.Memory, VarArrayLock(VarResult), AnReportResult.TempStream.Size);
            VarArrayUnLock(VarResult);
            AnReportResult.TempStream.Position := 0;
            if not AnReportResult.IsStreamData then
            begin
              AnReportResult.LoadFromStream(AnReportResult.TempStream);
              AnReportResult.TempStream.Clear;
            end;
          finally
            LocReportResult.Clear;
          end                      
        end else
        begin
          Result := False;
          AnParamAndResult := 'При написании скрипта должна использоваться функция.'#13#10 +
           'Например: Set <function_result> = BaseQueryList';
        end
      else
      if AnFunction.Module = ParamModuleName then
      begin
        if not VarIsArray(AnParamAndResult) then
        begin
          Result := False;
          if (VarType(AnParamAndResult) <> varEmpty) then
            AnParamAndResult := 'Функция параметров должна возвращать массив.';
        end
      end else
        if AnFunction.Module = EventModuleName then
        begin
          Result := (VarType(AnParamAndResult) in [varBoolean, varSmallInt, varByte]);
          if Result then
          begin
            TempInt := AnParamAndResult;
            Result := ((TempInt = 0) or (TempInt = 1));
          end;
          if not Result then
            AnParamAndResult := 'При написании скрипта должна использоваться функция.'#13#10 +
             'Ее результатом должено быть булевское значение 0 либо 1.';
        end;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      AnParamAndResult := E.Message;
    end;
  end;
end;

procedure TBaseReport.SetTransactionParams;
begin
  {$IFDEF DEBUG}
  SaveLog('    SetTransactionParams');
  {$ENDIF}
  FTransaction.Params.Clear;
  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
end;

function TBaseReport.InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
var
  {$IFNDEF GEDEMIN}
  LocRpScrCtrl: TReportScript;
  {$ENDIF}
  LocParamList: TgsParamList;
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    InputParams');
  {$ENDIF}
  {$IFNDEF GEDEMIN}
  SetOnCreateEvets;
  {$ENDIF}
  Result := False;
  LocParamList := TgsParamList.Create;
  try
    GetParamsFromText(LocParamList, AnFunction.Name, AnFunction.Script.Text);
    if AnFunction.EnteredParams.Count = LocParamList.Count then
    begin
      Result := True;
      for I := 0 to LocParamList.Count - 1 do
        Result := Result and (UpperCase(LocParamList.Params[I].RealName) =
         UpperCase(AnFunction.EnteredParams.Params[I].RealName));
    end;
  finally
    LocParamList.Free;
  end;

  if Result and Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
  begin
    ParamGlobalDlg.QueryParams(GD_PRM_REPORT, AnFunction.FunctionKey, AnFunction.EnteredParams, Result);
    AnParamResult := AnFunction.EnteredParams.GetVariantArray;
  end else
    begin
      {$IFDEF GEDEMIN}
      Result := ScriptFactory.InputParams(AnFunction, AnParamResult);
      {$ELSE}
      if FReportScriptControl.IsBusy then
      begin
        LocRpScrCtrl := TReportScript.CreateWithParam(nil, True, True);
        try
          LocRpScrCtrl.OnCreateConst := FReportScriptControl.OnCreateConst;
          LocRpScrCtrl.OnCreateVBClasses := FReportScriptControl.OnCreateVBClasses;
          LocRpScrCtrl.OnCreateObject := FReportScriptControl.OnCreateObject;
          LocRpScrCtrl.OnIsCreated := FReportScriptControl.OnIsCreated;
          LocRpScrCtrl.OnCreateModuleVBClasses := FReportScriptControl.OnCreateModuleVBClasses;
          LocRpScrCtrl.Transaction := FTransaction;

  //        LocRpScrCtrl.CreateConst;
  //        LocRpScrCtrl.CreateObject;
  //        LocRpScrCtrl.CreateVBClasses;
  //        LocRpScrCtrl.CreateGlobalObj;
          Result := LocRpScrCtrl.InputParams(AnFunction, AnParamResult);
        finally
          LocRpScrCtrl.Free;
        end;
      end else
        Result := FReportScriptControl.InputParams(AnFunction, AnParamResult);
      {$ENDIF}
    end;
end;

procedure TBaseReport.Refresh;
begin
  {$IFDEF DEBUG}
  SaveLog('    Refresh');
  {$ENDIF}
  try
    PrepareSourceDatabase;
    try
      FReportList.Refresh;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
    begin
      SaveLog(E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TBaseReport.PrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    PrepareSourceDatabase');
  {$ENDIF}
  if FLocState = 0 then
  begin
    FLocStateDB := FDatabase.Connected;
    FLocStateTR := FTransaction.InTransaction;
    if not FLocStateDB then
      FDatabase.Connected := True;
    if not FLocStateTR then
      FTransaction.StartTransaction;
  end;
  Inc(FLocState);
end;

procedure TBaseReport.CheckScriptControl;
begin
  {$IFDEF DEBUG}
  SaveLog('    CheckScriptControl');
  {$ENDIF}
  {$IFNDEF GEDEMIN}
  if not Assigned(FReportScriptControl) then
    raise Exception.Create(ScriptControlNotRegister);
  {$ENDIF}
end;

procedure TBaseReport.UnPrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    UnPrepareSourceDatabase');
  {$ENDIF}
  Dec(FLocState);
  if FLocState = 0 then
  begin
    if not FLocStateTR then
      FTransaction.Commit;
    if not FLocStateDB then
      FDatabase.Connected := False;
  end;
end;

function TBaseReport.FindReportNow(const AnReportKey: Integer;
  const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean): Boolean;
var
  TempQuery: TIBQuery;
  ParamKey, MainKey, EventKey: Integer;
  FunctionKeyList: TgdKeyArray;

  procedure AddIncludingFunctions(const AddQuery: TIBQuery; const AnFunction: TrpCustomFunction;
    const KeyList: TgdKeyArray);
  var
    i: Integer;
    LFunction: TrpCustomFunction;
  begin
    AddQuery.Close;
    AddQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
    LFunction := TrpCustomFunction.Create;
    try
      for i := 0 to KeyList.Count - 1 do
      begin
        if FunctionKeyList.IndexOf(KeyList.Keys[i]) > -1 then
          Continue;

        AddQuery.Close;
        AddQuery.Params[0].AsInteger := KeyList.Keys[i];
        AddQuery.Open;
        LFunction.ReadFromDataSet(AddQuery);
        AnFunction.Script.Text := AnFunction.Script.Text +
          #13#10 + LFunction.Script.Text;
        FunctionKeyList.Add(KeyList.Keys[i]);
        if LFunction.IncludingList.Count > 0 then
          AddIncludingFunctions(AddQuery, AnFunction, LFunction.IncludingList);
      end;
    finally
      LFunction.Free;
    end;

    for i := 0 to AnFunction.IncludingList.Count - 1 do
    begin
      if FunctionKeyList.IndexOf(AnFunction.IncludingList[i]) = -1 then
      begin
      end;
    end;

    AddQuery.Close;

  end;

begin
  {$IFDEF DEBUG}
  SaveLog('    FindReportNow');
  {$ENDIF}
  Result := False;
  try
    PrepareSourceDatabase;
    try
      TempQuery := TIBQuery.Create(nil);
      try
        TempQuery.Database := FDatabase;
        TempQuery.Transaction := FTransaction;
        TempQuery.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id = ' + IntToStr(AnReportKey);
        TempQuery.Open;
        if TempQuery.Eof then
          raise Exception.Create(Format('Запись отчета %d не найдена.', [AnReportKey]));
        AnCustomReport.ReadFromDataSet(TempQuery, AnReadTemplate);

        ParamKey := TempQuery.FieldByName('paramformulakey').AsInteger;
        MainKey := TempQuery.FieldByName('mainformulakey').AsInteger;
        EventKey := TempQuery.FieldByName('eventformulakey').AsInteger;

        TempQuery.Close;
        TempQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';

        FunctionKeyList := TgdKeyArray.Create;
        try
          TempQuery.Close;
          if ParamKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := ParamKey;
            TempQuery.Open;
          end;
          AnCustomReport.ParamFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.ParamFunction,
//            AnCustomReport.ParamFunction.IncludingList);
//          AnCustomReport.ParamFunction.IncludingList.Clear;

          TempQuery.Close;
          if MainKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := MainKey;
            TempQuery.Open;
          end;
          AnCustomReport.MainFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.MainFunction,
//            AnCustomReport.MainFunction.IncludingList);
//          AnCustomReport.MainFunction.IncludingList.Clear;

          TempQuery.Close;
          if EventKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := EventKey;
            TempQuery.Open;
          end;
          AnCustomReport.EventFunction.ReadFromDataSet(TempQuery);
//          AnCustomReport.EventFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.EventFunction,
//            AnCustomReport.EventFunction.IncludingList);
//          AnCustomReport.EventFunction.IncludingList.Clear;
        finally
          FunctionKeyList.Free;
        end;

        Result := True;
      finally
        TempQuery.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
{    on E: Exception do
      if (Self is TClientReport) then
        MessageBox(0, PChar('Произошла ошибка при поиске отчета.'#13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
  end;
end;

function TBaseReport.FindFunctionNow(const AnFunctionKey: Integer;
  const AnCustomReport: TCustomReport;
  const AnReadTemplate: Boolean): Boolean;
var
  TempQuery: TIBQuery;
//  ParamKey, MainKey, EventKey: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    FindFunctionNow');
  {$ENDIF}
  Result := False;
  try
    AnCustomReport.FrqRefresh := 100;
    PrepareSourceDatabase;
    try
      TempQuery := TIBQuery.Create(nil);
      try
        TempQuery.Database := FDatabase;
        TempQuery.Transaction := FTransaction;
        TempQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
        TempQuery.Params[0].AsInteger := AnFunctionKey;
        TempQuery.Open;
        if TempQuery.Eof then
          raise Exception.Create(Format('Запись функции %d не найдена.', [AnFunctionKey]));
        AnCustomReport.MainFunction.ReadFromDataSet(TempQuery);
        Result := True;
      finally
        TempQuery.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
{    on E: Exception do
      if (Self is TClientReport) then
        MessageBox(0, PChar('Произошла ошибка при поиске отчета.'#13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
  end;
end;

procedure TBaseReport.SetOnCreateConst(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateConst');
  {$ENDIF}
  FOnCreateConst := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateConst := FOnCreateConst;
{$ENDIF}
end;

procedure TBaseReport.SetOnCreateGlobalObj(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateGlobalObj');
  {$ENDIF}
  FOnCreateGlobalObj := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateGlobalObj := FOnCreateGlobalObj;
{$ENDIF}
end;

procedure TBaseReport.SetOnCreateVBClasses(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateVBClasses');
  {$ENDIF}
  FOnCreateVBClasses := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateVBClasses := FOnCreateVBClasses;
{$ENDIF}
end;

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBClassesLists;
var
  ibsqlVB: TIBSQL;
  ibtrVB: TIBTransaction;
  TestRS: TReportScript;
  StateDB: Boolean;
  ErrScript: String;
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBClassesLists');
  {$ENDIF}
  FVBClasses := '';
  StateDB := FDatabase.Connected;
  ibtrVB := TIBTransaction.Create(nil);
  try
    ibtrVB.DefaultDatabase := FDatabase;
    if not StateDB then
      FDatabase.Open;

    ibsqlVB := TIBSQL.Create(nil);
    try
      ibsqlVB.Database := FDatabase;
      ibsqlVB.Transaction := ibtrVB;
      ibtrVB.StartTransaction;
      try

        ibsqlVB.SQL.Text := 'SELECT * ' +
          'FROM gd_function WHERE module = ''VBCLASSES'' AND modulecode = ' +
          IntToStr(OBJ_APPLICATION);
        ibsqlVB.ExecQuery;

        // сохраняем вб-классы
        TestRS := TReportScript.Create(nil);
        TestRS.OnCreateConst := FReportScriptControl.OnCreateConst;
        TestRS.IsCreate;
        try
          while not ibsqlVB.Eof do
          begin
            try
              FNonLoadSFList.Add(ibsqlVB.FieldByName('id').AsInteger);
              TestRS.AddCode(ibsqlVB.FieldByName('script').AsString);
              FVBClasses := FVBClasses +
                ibsqlVB.FieldByName('script').AsString + #13#10;
            except
              begin
                ErrScript := #13#10 + 'ОШИБКА!!!  Класс ' +  ibsqlVB.FieldByName('Name').AsString +
                  ' не загружен.'#13#10 + '  ' + TestRS.Error.Description + ': ' + TestRS.Error.Text + #13#10 +
                  '  Строка: ' + IntToStr(TestRS.Error.Line) + #13#10 + '  Дата: ';
                SaveLog(ErrScript);
              end;
            end;
            ibsqlVB.Next;
          end;
        finally
          TestRS.Free;
        end;
      finally
        ibtrVB.Commit;
      end;
    finally
      ibsqlVB.Free;
    end;
  finally
    if not StateDB then
      FDatabase.Close;
    ibtrVB.Free;
  end;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBClasses(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBClasses');
  {$ENDIF}
  (Sender as TReportScript).AddCode(FVBClasses);
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateConstans(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateConstans');
  {$ENDIF}
  (Sender as TReportScript).AddCode(FConstants);
end;
{$ENDIF}


{$IFNDEF GEDEMIN}
procedure TBaseReport.SetOnCreateEvets;
var
  LVers: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateEvets');
  {$ENDIF}
//  if FReportScriptControl.IsBusy
  LVers := Get_gd_functionVersion;
  if Fgd_functionVers <> LVers then
  begin
    Fgd_functionVers := LVers;
    FCreateEventLoad := False;
    FReportScriptControl.ClearFlag := True;
  end;

  if not FCreateEventLoad then
  begin
    FNonLoadSFList.Clear;

    if Assigned(FOnCreateConst) then
      FReportScriptControl.OnCreateConst := FOnCreateConst
    else
      begin
        CreateVBConstLists;
        FReportScriptControl.OnCreateConst := CreateConstans;
      end;
    if Assigned(FOnCreateVBClasses) then
      FReportScriptControl.OnCreateVBClasses := FOnCreateVBClasses
    else
      begin
        CreateVBClassesLists;
        FReportScriptControl.OnCreateVBClasses := CreateVBClasses;
      end;
    if Assigned(FOnCreateGlobalObj) then
      FReportScriptControl.OnCreateGlobalObj := FOnCreateGlobalObj
    else
      begin
        FReportScriptControl.OnCreateGlobalObj := nil;
      end;
    if (not Assigned(FOnIsCreated)) and (FReportScriptControl.NonLoadSFList = nil) then
      FReportScriptControl.NonLoadSFList := FNonLoadSFList;

    FCreateEventLoad := True;
  end;
end;
{$ENDIF}


{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBConstLists;
var
  ibsqlVB: TIBSQL;
  ibtrVB: TIBTransaction;
  TestRS: TReportScript;
  StateDB: Boolean;
  ErrScript: String;
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBConstLists');
  {$ENDIF}
  FConstants := '';
  StateDB := FDatabase.Connected;
  ibtrVB := TIBTransaction.Create(nil);
  try
    ibtrVB.DefaultDatabase := FDatabase;
    if not StateDB then
      FDatabase.Open;

    ibsqlVB := TIBSQL.Create(nil);
    try
      ibsqlVB.Database := FDatabase;
      ibsqlVB.Transaction := ibtrVB;
      ibtrVB.StartTransaction;
      try
        TestRS := TReportScript.Create(nil);
        try
          ibsqlVB.SQL.Text := 'SELECT * ' +
            'FROM gd_function WHERE module = ''CONST''';
          ibsqlVB.ExecQuery;

          // сохраняем в константы
          while not ibsqlVB.Eof do
          begin
            try
              FNonLoadSFList.Add(ibsqlVB.FieldByName('id').AsInteger);
              TestRS.AddCode(ibsqlVB.FieldByName('script').AsString);
              FConstants := FConstants +
                ibsqlVB.FieldByName('script').AsString + #13#10;
            except
              begin
//                MessageBeep(1000);
                ErrScript := #13#10 + 'ОШИБКА!!!  Блок констант ' +  ibsqlVB.FieldByName('Name').AsString +
                  ' не загружен.'#13#10 + '  ' + TestRS.Error.Description + ': ' + TestRS.Error.Text + #13#10 +
                  '  Строка: ' + IntToStr(TestRS.Error.Line) + #13#10 + '  Дата: ';
                SaveLog(ErrScript);

              end;
            end;
            ibsqlVB.Next;
          end;
        finally
          TestRS.Free;
        end;
      finally
        ibtrVB.Commit;
      end;
    finally
      ibsqlVB.Free;
    end;
  finally
    if not StateDB then
      FDatabase.Close;
    ibtrVB.Free;
  end;
end;
{$ENDIF}

procedure TBaseReport.SaveLog(const S: String);
{$IFDEF LogReport}
var
  F: TextFile;
{$ENDIF}
begin
  {$IFDEF LogReport}
  if FLogFileName = '' then
    FLogFileName := ChangeFileExt(Application.EXEName, '.log');
//    FLogFileName := rpGetTemporaryFileName('rpsrvlog');

  try
    AssignFile(F, FLogFileName);
    if FileExists(FLogFileName) then
      Append(F)
    else
      Rewrite(F);
    try
      Writeln(F, S + ': ' + DateTimeToStr(Now));
      Flush(F);
    finally
      CloseFile(F);
    end;
  except
    //
  end;
  {$ENDIF}
end;

procedure TBaseReport.SetOnIsCreated(const Value: TNotifyEvent);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnIsCreated');
  {$ENDIF}
  FOnIsCreated := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnIsCreated := Value;
{$ENDIF}
end;

{$IFNDEF GEDEMIN}
procedure TBaseReport.SetNonLoadSFList(const Value: TgdKeyArray);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetNonLoadSFList');
  {$ENDIF}
  FReportScriptControl.NonLoadSFList := Value;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
function TBaseReport.GetNonLoadSFList: TgdKeyArray;
begin
  {$IFDEF DEBUG}
  SaveLog('    GetNonLoadSFList');
  {$ENDIF}
  Result := FReportScriptControl.NonLoadSFList;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateModuleVBClass(Sender: TObject;
  const ModuleCode: Integer; VBClassArray: TgdKeyArray);
var
  ibDatasetWork: TIBDataset;
  SF: TrpCustomFunction;
  I: Integer;
  LModuleName: String;
  TrFlag: Boolean;

begin
  {$IFDEF DEBUG}
  SaveLog('    CreateModuleVBClass');
  {$ENDIF}
  VBClassArray.Clear;
  begin
    LModuleName := IntToStr(ModuleCode);
    ibDatasetWork := TIBDataset.Create(nil);
    try
      ibDatasetWork.Transaction := FTransaction;
      TrFlag := FTransaction.Active;
      if not TrFlag then
        FTransaction.StartTransaction;
      try
        ibDatasetWork.SelectSQL.Text := 'SELECT * ' +
         'FROM gd_function WHERE module = ''' + scrVBClasses +
         ''' AND modulecode = ' + LModuleName;
        ibDatasetWork.Open;
        ibDatasetWork.First;

        VBClassArray.Clear;

        if not ibDatasetWork.IsEmpty then
        begin
          SF := TrpCustomFunction.Create;
          try
            while not (ibDatasetWork.Eof) do
            begin
                SF.ReadFromDataSet(ibDatasetWork);
                I := VBClassArray.Add(SF.FunctionKey, True);
                try
                  (Sender as TReportScript).AddScript(SF, LModuleName, ModuleCode);
                except
                  { TODO : Ошибка добавления класса, надо добавить в лог. }
                  VBClassArray.Delete(I);
                end;
              ibDatasetWork.Next;
            end;
          finally
            SF.Free;
          end;
        end;
      finally
        if not TrFlag then
          FTransaction.Commit;
      end;
    finally
      ibDatasetWork.Free;
    end;
  end;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
function TBaseReport.Get_gd_functionVersion: Integer;
var
  IBSQL: TIBSQL;
  TrState: Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog('    Get_gd_functionVersion');
  {$ENDIF}
  Result := -1;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := FTransaction;
    TrState := FTransaction.Active;
    if not TrState then
      FTransaction.StartTransaction;
    IBSQL.SQL.Text :=
      'SELECT GEN_ID(gd_g_functionch, 0) FROM rdb$database';
    IBSQL.ExecQuery;
    if not IBSQL.Eof then
      Result := IBSQL.Fields[0].AsInteger;
  finally
    IBSQL.Free;
  end;
end;
{$ENDIF}

// TrpServerSocket

constructor TrpServerSocket.Create(const AnHost: String; const AnPort, AnServerKey: Integer);
begin
  inherited Create;

  FClientSocket := TClientSocket.Create(nil);
  FClientSocket.Host := AnHost;
  FClientSocket.Port := AnPort;
  FServerKey := AnServerKey;
  FSocketData := TrpSocketData.Create;
  FSafeCounter := 0;
end;

destructor TrpServerSocket.Destroy;
begin
  if Assigned(FClientSocket) then
    FreeAndNil(FClientSocket);
  if Assigned(FSocketData) then
    FreeAndNil(FSocketData);

  inherited Destroy;
end;

procedure TrpServerSocket.SetHost(const AnHost: String);
begin
  FClientSocket.Host := AnHost;
end;

function TrpServerSocket.GetHost: String;
begin
  Result := FClientSocket.Host;
end;

procedure TrpServerSocket.SetPort(const AnPort: Integer);
begin
  FClientSocket.Port := AnPort;
end;

function TrpServerSocket.GetPort: Integer;
begin
  Result := FClientSocket.Port;
end;

// TrpServerSocketList

constructor TrpServerSocketList.Create;
begin
  inherited Create;

//  FmsgConnectServer := TmsgConnectServer.Create(nil);
  FSocketDataList := TList.Create;
  FSocketEvent := nil;
end;

destructor TrpServerSocketList.Destroy;
begin
  Clear;

//  if Assigned(FmsgConnectServer) then
//    FreeAndNil(FmsgConnectServer);

  FSocketDataList.Free;  

  inherited Destroy;
end;

procedure TrpServerSocketList.Clear;
var
  I: Integer;
begin
  for I := ServerCount - 1 downto 0 do
  begin
    TrpServerSocket(Items[I]).ClientSocket.Active := False;
    TrpServerSocket(Items[I]).Free;
    Items[I] := nil;
  end;

  inherited Clear;
end;

function TrpServerSocketList.Release(const AnServerSocket: TrpServerSocket): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := IndexOf(AnServerSocket);
  if I <> - 1 then
  begin
    AnServerSocket.FSafeCounter := AnServerSocket.FSafeCounter - 1;
    if AnServerSocket.FSafeCounter <= 0 then
    begin
      AnServerSocket.ClientSocket.Active := False;
      AnServerSocket.FSafeCounter := 0;
    end;
    Result := AnServerSocket.FSafeCounter;
  end;
end;

function TrpServerSocketList.QueryServer(const AnServerKey: Integer): TrpServerSocket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if TrpServerSocket(Items[I]).ServerKey = AnServerKey then
    begin
      Result := GetServer(I);
      Break;
    end;
end;

function TrpServerSocketList.GetServer(const AnIndex: Integer): TrpServerSocket;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  Result := TrpServerSocket(Items[AnIndex]);
  if not Result.ClientSocket.Active then
    if not ActivateReportServer(Result.ClientSocket) then
      Result := nil;
  if Result <> nil then
    Result.FSafeCounter := Result.FSafeCounter + 1;
end;

function TrpServerSocketList.QueryServer(const AnHost: String): TrpServerSocket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if TrpServerSocket(Items[I]).ClientSocket.Host = AnHost then
    begin
      Result := GetServer(I);
      Break;
    end;
end;

procedure TrpServerSocketList.ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  BufSize: Integer;
  TempBuffer: Pointer;
  LocServerSocket: TrpServerSocket;
begin
  BufSize := Socket.ReceiveLength;
  GetMem(TempBuffer, BufSize);
  try
    BufSize := Socket.ReceiveBuf(TempBuffer^, BufSize);
    LocServerSocket := ServerSocketBySocket(Socket);
    if LocServerSocket <> nil then
    try
      LocServerSocket.SocketData.ReadData(TempBuffer, BufSize);
    except
      LocServerSocket.SocketData.Clear;
    end;
  finally
    FreeMem(TempBuffer);
  end;
end;

procedure TrpServerSocketList.ClientError(Sender: TObject; Socket: TCustomWinSocket;
 ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ShowSocketErrorMessage(Sender);
  ErrorCode := 0;
end;

procedure TrpServerSocketList.ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  LocServerSocket: TrpServerSocket;
begin
  LocServerSocket := ServerSocketByClientSocket(Sender as TClientSocket);
  if LocServerSocket <> nil then
    LocServerSocket.SocketData.SocketHandle := Socket.SocketHandle;
end;

procedure TrpServerSocketList.ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  LocServerSocket: TrpServerSocket;
begin
  ShowSocketErrorMessage(Sender);

  LocServerSocket := ServerSocketByClientSocket(Sender as TClientSocket);
  if LocServerSocket <> nil then
    LocServerSocket.SocketData.SocketHandle := 0;
end;

procedure TrpServerSocketList.ShowSocketErrorMessage(Sender: TObject);
begin
  FConnectedFlag := False;
  if (Sender as TClientSocket).Active then
  begin
    (Sender as TClientSocket).Active := False;
    MessageBox(0, 'Произошла ошибка при обращении к серверу отчетов.'#13#10 +
     'Соединение будет оборвано. Для создания нового соединения'#13#10 +
     'обновите данные отчетов.', 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;

function TrpServerSocketList.GetServerSocket(const AnIndex: Integer): TrpServerSocket;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  Result := TrpServerSocket(Items[AnIndex]);
end;

function TrpServerSocketList.ServerSocketBySocket(AnSocket: TCustomWinSocket): TrpServerSocket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if ServerSocket[I].ClientSocket.Socket = AnSocket then
    begin
      Result := ServerSocket[I];
      Break;
    end;
end;

function TrpServerSocketList.ServerSocketByClientSocket(AnClientSocket: TClientSocket): TrpServerSocket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if ServerSocket[I].ClientSocket = AnClientSocket then
    begin
      Result := ServerSocket[I];
      Break;
    end;
end;

function TrpServerSocketList.ServerSocketByServerData(AnSocketData: TrpSocketData): TrpServerSocket;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if ServerSocket[I].SocketData = AnSocketData then
    begin
      Result := ServerSocket[I];
      Break;
    end;
end;

function TrpServerSocketList.AddServerSocket(const AnHost: String;
 const AnPort, AnServerKey: Integer): Integer;
begin
  Result := Add(TrpServerSocket.Create(AnHost, AnPort, AnServerKey));
  TrpServerSocket(Items[Result]).ClientSocket.OnRead := ClientRead;
  TrpServerSocket(Items[Result]).ClientSocket.OnError := ClientError;
  TrpServerSocket(Items[Result]).ClientSocket.OnDisconnect := ClientDisconnect;
  TrpServerSocket(Items[Result]).ClientSocket.OnConnect := ClientConnect;
  TrpServerSocket(Items[Result]).SocketData.OnThreadCreate := FSocketEvent;
  TrpServerSocket(Items[Result]).SocketData.SingleBlock := False;
end;

procedure TrpServerSocketList.SetSocketEvent(const AnSocketEvent: TrpSocketEvent);
var
  I: Integer;
begin
  FSocketEvent := AnSocketEvent;
  for I := 0 to Count - 1 do
    TrpServerSocket(Items[I]).SocketData.OnThreadCreate := FSocketEvent;
end;

function TrpServerSocketList.GetServerCount: Integer;
begin
  Result := Count;
end;

function TrpServerSocketList.CheckServerExists(const AnServerName: String): Boolean;
const
  DoubleFlash = '\\';
var
  NetResource : TNetResource;
  lphEnum     : THandle;
begin
  try
    FillChar(NetResource, SizeOf(NetResource), 0);
    NetResource.lpRemoteName := PChar(DoubleFlash + AnServerName);
    NetResource.dwDisplayType := RESOURCEDISPLAYTYPE_SHARE;
    NetResource.dwUsage := RESOURCEUSAGE_CONNECTABLE;
    NetResource.dwScope := RESOURCE_GLOBALNET;
    NetResource.dwType := RESOURCETYPE_ANY;
    Result := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK,
     RESOURCEUSAGE_CONNECTABLE, @NetResource, lphEnum) = NO_ERROR;
    WNetCloseEnum(lphEnum);
  except
    Beep(2000, 100);
    Result := False;
  end;
end;

function TrpServerSocketList.ActivateReportServer(const AnServerSocket: TClientSocket): Boolean;
begin
  FConnectedFlag := True;
  if CheckServerExists(AnServerSocket.Host) then
  begin
    AnServerSocket.Active := True;
    while (not AnServerSocket.Active) and FConnectedFlag 
      and (not Application.Terminated) do
    begin
      Sleep(10);
      Application.ProcessMessages;
    end;
  end;
  FConnectedFlag := False;
  Result := AnServerSocket.Active;
end;

function TrpServerSocketList.Release(
  const AnSocketData: TrpSocketData): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if TrpServerSocket(Items[I]).SocketData = AnSocketData then
    begin
      Result := Release(TrpServerSocket(Items[I]));
      Break;
    end;
end;
(*
// TClientReport

constructor TClientReport.Create(Owner: TComponent);
begin
  Assert(ClientReport = nil, 'ClientReport must be one for project.');

  inherited Create(Owner);

  FViewReport := nil;
  FibsqlServerName := nil;
  FServerList := nil;
  FUniqueValue := 0;
  FDefaultServer := nil;
  FReportFactory := nil;
  FProgressForm := nil;
  FClientEventFactory := nil;
  FFirstRead := False;

  if not (csDesigning in ComponentState) then
  begin
    FServerList := TrpServerSocketList.Create;
    FServerList.OnThreadCreate := ClientEvent;
    FProgressForm := TprgReportCount.Create(nil);
    FClientEventFactory := TClientEventFactory.Create;
    FViewReport := TvwReport.Create(Self);
    FDoIt := FViewReport.EventAction;
    FibsqlServerName := TIBSQL.Create(Self);
    FibsqlServerName.SQL.Text := 'SELECT computername FROM rp_reportserver ' +
     'WHERE id = :id';

    if not Assigned(FReportScriptControl) then
    begin
      {$IFNDEF DEPARTMENT}
      MessageBox(0, ScriptControlNotRegister, 'Ошибка', MB_OK or MB_ICONERROR);
      {$ENDIF}
      Abort;
    end;
  end;

  ClientReport := Self;
end;

destructor TClientReport.Destroy;
begin
  if Assigned(FViewReport) then
    FreeAndNil(FViewReport);
  if Assigned(FibsqlServerName) then
    FreeAndNil(FibsqlServerName);
  if Assigned(FServerList) then
    FreeAndNil(FServerList);
  if Assigned(FProgressForm) then
    FreeAndNil(FProgressForm);
  FDefaultServer := nil;

  inherited Destroy;
  
  ClientReport := nil;
end;

procedure TClientReport.ViewResult(const AnReport: TCustomReport; const AnReportResult: TReportResult;
 const AnParam: Variant; const AnBuildDate: TDateTime);
begin
  if Assigned(FReportFactory) then
    FReportFactory.CreateReport(AnReport.TemplateStructure, AnReportResult,
     AnParam, AnBuildDate, AnReport.Preview, AnReport.EventFunction, AnReport.ReportName)
  else
    raise Exception.Create('Object ReportFactory not assigned.');
end;

procedure TClientReport.ClientEvent(AnSocketData: TrpSocketData);
var
  TempReport: TCustomReport;
  TempFlag: Boolean;
  TempMsg: String;
begin
  TempFlag := (VarType(AnSocketData.ExecuteResult) = varBoolean) and AnSocketData.ExecuteResult;
  if TempFlag then
  begin
    TempReport := TCustomReport.Create;
    try
      if FindReportNow(AnSocketData.ReportKey, TempReport) then
        ViewResult(TempReport, AnSocketData.ReportResult, AnSocketData.StaticParam, AnSocketData.BuildDate)
      else
      begin
        TempFlag := False;
        TempMsg := 'ОШИБКА!!! Отчет построен, но его запись не найдена.';
      end;
    finally
      TempReport.Free;
    end;
  end else
    TempMsg := 'Произошла ошибка при выполнении отчета.';
  AnSocketData.ReportResult.Clear;
  AnSocketData.ReportResult.TempStream.Clear;
  FClientEventFactory.AddThread(TClientEventThread.Create(FProgressForm, False, TempFlag, TempMsg));
end;

function TClientReport.GetDefaultServer: TSocketServerParam;
var
  ibsqlDefaultServer: TIBSQL;
begin
  Result.ServerName := '';
  Result.ServerPort := 0;
  PrepareSourceDatabase;
  try
    ibsqlDefaultServer := TIBSQL.Create(nil);
    try
      ibsqlDefaultServer.Database := FDatabase;
      ibsqlDefaultServer.Transaction := FTransaction;
      ibsqlDefaultServer.SQL.Text := 'SELECT rs.computername, rs.serverport, ' +
       'rs.id FROM ' +
       'rp_reportserver rs, rp_reportdefaultserver rds WHERE rds.serverkey = rs.id AND ' +
       'rds.clientname = ''' + rpGetComputerName + '''';
      ibsqlDefaultServer.ExecQuery;
      if not ibsqlDefaultServer.Eof then
      begin
        Result.ServerName := ibsqlDefaultServer.Fields[0].AsString;
        Result.ServerPort := ibsqlDefaultServer.Fields[1].AsInteger;
        Result.ServerKey := ibsqlDefaultServer.Fields[2].AsInteger;
      end;
    finally
      ibsqlDefaultServer.Free;
    end;
  finally
    UnPrepareSourceDatabase;
  end;
end;

function TClientReport.GetUniqueClientKey: Cardinal;
begin
  Inc(FUniqueValue);
  Result := FUniqueValue;
end;

procedure TClientReport.PrepareReportServer;
var
  ibsqlWork: TIBSQL;
  LocDefaultServer: TSocketServerParam;
  I: Integer;
begin
  try
    FProgressForm.Clear;
    FServerList.Clear;
    // Считываем сервер отчетов используемый по умолчанию
    LocDefaultServer := DefaultServer;
    // Если таковой существует пытаемся создать
    // Если создать не удалось получаем список зарегестрированных серверов
    // и пытаемся создавать по порядку до первой удачной попытки
    PrepareSourceDatabase;
    try
      ibsqlWork := TIBSQL.Create(nil);
      try
        ibsqlWork.Database := FDatabase;
        ibsqlWork.Transaction := FTransaction;
        ibsqlWork.SQL.Text := 'SELECT computername, serverport, id ' +
         'FROM rp_reportserver ORDER BY usedorder';
        ibsqlWork.ExecQuery;
        while not (ibsqlWork.Eof) do
        begin
          FServerList.AddServerSocket(ibsqlWork.Fields[0].AsString,
           ibsqlWork.Fields[1].AsInteger, ibsqlWork.Fields[2].AsInteger);


          ibsqlWork.Next;
        end;
      finally
        ibsqlWork.Free;
      end;

      FDefaultServer := FServerList.QueryServer(LocDefaultServer.ServerName);
      if FDefaultServer = nil then
      begin
        I := 0;
        while (I < FServerList.Count) and (FDefaultServer = nil) do
        begin
          {gs} // Не оптимизированно. Двойной поиск.
          FDefaultServer := FServerList.QueryServer(FServerList.ServerSocket[I].Host);
          Inc(I);
        end;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
    // Если сервер не создан построение отчетов выполняется клиентским приложением самостоятельно
    if (FDefaultServer = nil) and (FServerList.Count > 0) then
      MessageBox(0, 'Не удалось установить соединение ни с одним сервером отчетов.',
       'Внимание', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;

procedure TClientReport.UnPrepareReportServer;
begin
  // На всякий пожарный.
  FServerList.Clear;
end;

function TClientReport.ClientQueryToServer(const AnCurrentServer: TClientSocket; const AnReportKey: Integer;
 const AnReportResult: TReportResult; var AnParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
var
//  VarReportResult: OleVariant;
  TempParam: OleVariant;
//  MStr: TMemoryStream;
  TempAr: TDnByteArray;
  LocSendSocketData: TrpSocketData;
begin
  Result := False;
  if Assigned(AnCurrentServer) and not AnCurrentServer.Active then
    FServerList.ActivateReportServer(AnCurrentServer);
  if Assigned(AnCurrentServer) and AnCurrentServer.Active then
  begin
    try
      TempParam := AnParamAndResult;
      LocSendSocketData := TrpSocketData.Create;
      try
        LocSendSocketData.ReportKey := AnReportKey;
        LocSendSocketData.ExecuteResult := AnParamAndResult;
        LocSendSocketData.StaticParam := AnParamAndResult;
        LocSendSocketData.ReportResult.Assign(AnReportResult);
        LocSendSocketData.SocketHandle := AnCurrentServer.Socket.SocketHandle;
        LocSendSocketData.IsRebuild := AnIsRebuild;
        LocSendSocketData.WriteData(TempAr);
        Result := AnCurrentServer.Socket.SendBuf(TempAr[0], Length(TempAr)) = Length(TempAr);
      finally
        LocSendSocketData.Free;
      end;
      if not Result then
        AnParamAndResult := 'ОШИБКА! Нарушен формат данных протокола.';
    except
      on E: Exception do
      begin
        AnParamAndResult := E.Message;
        Result := False;
      end;
    end;
  end else
    AnParamAndResult := 'Оборвано соединение с сервером отчетов.';
end;

procedure TClientReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (FReportFactory <> nil)
    and (AComponent = FReportFactory) then FReportFactory := nil;
end;

function TClientReport.GetReportServerName(const AnServerKey: Integer): String;
begin
  PrepareSourceDatabase;
  try
    FibsqlServerName.Close;
    FibsqlServerName.Database := FDatabase;
    FibsqlServerName.Transaction := FTransaction;
    FibsqlServerName.Params[0].AsInteger := AnServerKey;
    FibsqlServerName.ExecQuery;
    Result := FibsqlServerName.Fields[0].AsString;
  finally
    FibsqlServerName.Close;
    UnPrepareSourceDatabase;
  end;
end;

function TClientReport.ClientQuery(const ReportData: TCustomReport; const ReportResult: TReportResult;
 var ParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
var
  FTempServerData: TrpServerSocket;
  FTempClientSocket: TClientSocket;
  LocClientSocketData: TrpSocketData;
  TempParam: Variant;
begin
//  Result := False;

  TempParam := ParamAndResult;
  FTempServerData := nil;
  FTempClientSocket := nil;
  try
    // Если отчет должен выполняться локально то ничего не делаем
    if not ReportData.IsLocalExecute then
    begin
      // Если отчет должен выполняться не на нашем сервере по умолчанию,
      // то создаем этот сервер
      if (ReportData.ServerKey <> NULL) and not ((FDefaultServer <> nil) and
       (FDefaultServer.ServerKey = ReportData.ServerKey)) then
        FTempServerData := FServerList.QueryServer(ReportData.ServerKey);

      if FTempServerData = nil then
        if FDefaultServer <> nil then
          FTempClientSocket := FDefaultServer.ClientSocket
        else
          FTempClientSocket := nil
      else
        FTempClientSocket := FTempServerData.ClientSocket;
    end;

    // Если есть сервер у которого можно что-то запросить, то запрашиваем
    if FTempClientSocket <> nil then
    begin
      Result := ClientQueryToServer(FTempClientSocket, ReportData.ReportKey, ReportResult, ParamAndResult, AnIsRebuild);
      if Result then
        FProgressForm.AddRef;
    end else
    begin
      FProgressForm.AddRef;
      Result := ExecuteFunctionWithoutParam(ReportData.MainFunction, ReportResult,
       ParamAndResult);
      if Result then
      begin
        LocClientSocketData := TrpSocketData.Create;
        try
          LocClientSocketData.ReportKey := ReportData.ReportKey;
          LocClientSocketData.ReportResult.AssignTempStream(ReportResult.TempStream);
          LocClientSocketData.ExecuteResult := Result;
          LocClientSocketData.StaticParam := TempParam;
          ClientEvent(LocClientSocketData);
        finally
          LocClientSocketData.Free;
        end;
      end else
        FProgressForm.Release;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      ParamAndResult := E.Message;
    end;
  end;
end;

function TClientReport.ExecuteReport(const AnReport: TCustomReport; const AnResult: TReportResult;
 out AnErrorMessage: String; const AnIsRebuild: Boolean): Boolean;
var
  Param: Variant;
begin
  AnErrorMessage := '';
  {$IFDEF DEBUG}
  if Assigned(Log) then
    Log.LogLn(DateTimeToStr(Now) + ': Запущен на выполнение отчет ' + AnReport.ReportName +
      '  ИД  ' + IntToStr(AnReport.ReportKey));
  {$ENDIF}

  if AnReport.ParamFunction.FunctionKey <> 0 then
    Result := ExecuteFunctionWithoutParam(AnReport.ParamFunction, AnResult, Param)
  else
    Result := InputParams(AnReport.MainFunction, Param);

  if VarType(Param) = varString then
    AnErrorMessage := Param;

  if Result then
  begin
    Result := ClientQuery(AnReport, AnResult, Param, AnIsRebuild);

    if not Result then
    begin
      {$IFDEF DEBUG}
      if Assigned(Log) then
        Log.LogLn(DateTimeToStr(Now) + ': Ошибка во время выполнения отчета ' + AnReport.ReportName +
          '  ИД ' + IntToStr(AnReport.ReportKey));
      {$ENDIF}
      AnErrorMessage := Param;
    end else
      begin
        {$IFDEF DEBUG}
        if Assigned(Log) then
          Log.LogLn(DateTimeToStr(Now) + ': Удачное выполнение отчета ' + AnReport.ReportName +
            '  ИД ' + IntToStr(AnReport.ReportKey));
        {$ENDIF}
      end;
  end;
end;

procedure TClientReport.Refresh;
begin
  FFirstRead := True;
  UnPrepareReportServer;
//  inherited Refresh;

{  PrepareSourceDatabase;
  try
    FReportGroupList.ReadData(FDatabase, FTransaction);
  finally
    UnPrepareSourceDatabase;
  end;}
  PrepareReportServer;
end;

procedure TClientReport.Execute(const AnGroupKey: Integer = 0);
begin
  CheckLoaded;
  if FViewReport = nil then
  begin
    MessageBox(0, 'ErrorTesting. При появлении этого окна обратиться ко мне JKL.',
     'Внимание', MB_OK or MB_TOPMOST);
    FViewReport := FViewReport;
  end;
  FViewReport.vwExecuteReport := ExecuteReport;
  FViewReport.vwExecuteFunction := ExecuteFunctionWithParam;
  FViewReport.vwViewResult := ViewResult;
  FViewReport.vwRefreshReportData := Refresh;
  FViewReport.vwBuildReport := BuildReport;
  FViewReport.OnClose := FinishExecute;
  FViewReport.vwSaveFile := SaveReportToFile;
  FViewReport.vwLoadFile := LoadReportFromFile;
  FViewReport.Execute(AnGroupKey, FDatabase);
end;

procedure TClientReport.FinishExecute(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FReportFactory) then
    FReportFactory.Clear;
  FClientEventFactory.Clear;
end;

procedure TClientReport.BuildReportWithParam(const AnReportKey: Integer;
 const AnParam: Variant; const AnIsRebuild: Boolean = False);
var
  CurrentReport: TCustomReport;
  LocReportResult: TReportResult;
  LocErrorMessage: String;
  TempParam: Variant;
begin
  CheckLoaded;
  CurrentReport := TCustomReport.Create;
  try
    if not FindReportNow(AnReportKey, CurrentReport, False) then
    begin
      MessageBox(0, 'Отчет не найден', 'Внимание', MB_OK or MB_ICONWARNING or MB_TOPMOST);
      Exit;
    end;
    LocReportResult := TReportResult.Create;
    try
      LocReportResult.IsStreamData := True;
      LocErrorMessage := '';

      TempParam := AnParam;
      if not ClientQuery(CurrentReport, LocReportResult, TempParam, AnIsRebuild) then
        if (VarType(TempParam) = varString) and (TempParam > '') then
        begin
          LocErrorMessage := TempParam;
          MessageBox(0, PChar('Произошла ошибка при построении отчета: '#13#10 +
           LocErrorMessage), 'Внимание!', MB_OK or MB_ICONERROR or MB_TOPMOST);
        end;

    finally
      LocReportResult.Free;
    end;
  finally
    CurrentReport.Free;
  end;
end;

procedure TClientReport.BuildReport(const AnReportKey: Integer; const AnIsRebuild: Boolean = False);
var
  CurrentReport: TCustomReport;
  LocReportResult: TReportResult;
  LocErrorMessage: String;
begin
  CheckLoaded;
  CurrentReport := TCustomReport.Create;
  try
    if not FindReportNow(AnReportKey, CurrentReport, False) then
    begin
      MessageBox(0, 'Отчет не найден', 'Внимание', MB_OK or MB_ICONWARNING or MB_TOPMOST);
      Exit;
    end;
    LocReportResult := TReportResult.Create;
    try
      LocReportResult.IsStreamData := True;
      LocErrorMessage := '';
      if not ExecuteReport(CurrentReport, LocReportResult, LocErrorMessage, AnIsRebuild) then
        if (LocErrorMessage > '') then
          MessageBox(0, PChar('Произошла ошибка при построении отчета: '#13#10 +
           LocErrorMessage), 'Внимание!', MB_OK or MB_ICONERROR or MB_TOPMOST);
    finally
      LocReportResult.Free;
    end;
  finally
    CurrentReport.Free;
  end;
end;

procedure TClientReport.CheckLoaded;
begin
  if not FFirstRead then
    Refresh;
end;

function TClientReport.DoAction(const AnKey: Integer;
  const AnAction: TActionType): Boolean;
begin
  Result := False;
  if Assigned(FDoIt) then
    Result := FDoIt(AnKey, AnAction);
end;

function TClientReport.LoadReportFromFile(const AnGroupKey: Integer; const AnFileName: String): Boolean;
var
  TempReport: TCustomReport;
  FStr: TFileStream;
  TempLength: Integer;
  TestVersion: DWord;
  TempStr: String;
begin
  Result := False;
  try
    TempReport := TCustomReport.Create;
    try
      FStr := TFileStream.Create(AnFileName, fmOpenRead);
      try
        FStr.Read(TestVersion, SizeOf(TestVersion));
        if VersionReportStorage <> TestVersion then
          raise Exception.Create('Неверный формат файла');

        FStr.Read(TempLength, SizeOf(TempLength));
        SetLength(TempStr, TempLength);
        FStr.Read(TempStr[1], TempLength);
        TCrackCustomReport(TempReport).FReportName := TempStr;

        FStr.Read(TempLength, SizeOf(TempLength));
        SetLength(TempStr, TempLength);
        FStr.Read(TempStr[1], TempLength);
        TCrackCustomReport(TempReport).FReportDescription := TempStr;

        FStr.Read(TempLength, SizeOf(TempLength));
        TCrackCustomReport(TempReport).FFrqRefresh := TempLength;

        FStr.Read(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FServerKey := null
        else
          TCrackCustomReport(TempReport).FServerKey := TempLength;

        FStr.Read(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FPreview := False
        else
          TCrackCustomReport(TempReport).FPreview := True;

        FStr.Read(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FIsRebuild := False
        else
          TCrackCustomReport(TempReport).FIsRebuild := True;

        FStr.Read(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FIsLocalExecute := False
        else
          TCrackCustomReport(TempReport).FIsLocalExecute := True;

        TempReport.ParamFunction.LoadFromStream(FStr);
        TempReport.MainFunction.LoadFromStream(FStr);
        TempReport.EventFunction.LoadFromStream(FStr);
        TempReport.TemplateStructure.LoadFromStream(FStr);
        TCrackCustomReport(TempReport).FReportGroupKey := AnGroupKey;
      finally
        FStr.Free;
      end;
      CreateNewReport(TempReport);
      Result := True;
    finally
      TempReport.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar('Произошла ошибка при создании нового отчета из файла'#13#10
       + E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;

procedure TClientReport.SaveReportToFile(const AnReportKey: Integer;
  const AnFileName: String);
var
  TempReport: TCustomReport;
  FStr: TFileStream;
  TempLength: Integer;
  TestVersion: DWord;
begin
  try
    TempReport := TCustomReport.Create;
    try
      FindReportNow(AnReportKey, TempReport);

      FStr := TFileStream.Create(AnFileName, fmCreate);
      try
        TestVersion := VersionReportStorage;
        FStr.Write(TestVersion, SizeOf(TestVersion));

        TempLength := Length(TempReport.ReportName);
        FStr.Write(TempLength, SizeOf(TempLength));
        FStr.Write(TempReport.ReportName[1], TempLength);

        TempLength := Length(TempReport.Description);
        FStr.Write(TempLength, SizeOf(TempLength));
        FStr.Write(TempReport.Description[1], TempLength);

        TempLength := TempReport.FrqRefresh;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.ServerKey = null then
          TempLength := 0
        else
          TempLength := TempReport.ServerKey;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.Preview then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.IsRebuild then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.IsLocalExecute then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        TempReport.ParamFunction.SaveToStream(FStr);
        TempReport.MainFunction.SaveToStream(FStr);
        TempReport.EventFunction.SaveToStream(FStr);
        TempReport.TemplateStructure.SaveToStream(FStr);
      finally
        FStr.Free;
      end;
    finally
      TempReport.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar('Произошла ошибка при сохранении отчета в файл'#13#10
       + E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;

procedure TClientReport.CreateNewTemplate(AnIBSQL: TIBSQL;
  AnTemplate: TTemplateStructure);
begin
  Assert((AnIBSQL <> nil) and (AnTemplate <> nil), 'Can''t send nil');
  Assert(AnIBSQL.Database.Connected, 'Database must been connected');
  Assert(AnIBSQL.Transaction.InTransaction, 'Transaction must been started');

  if AnTemplate.TemplateKey = 0 then
    Exit;
  AnIBSQL.Close;
  AnIBSQL.SQL.Text := 'insert into rp_reporttemplate ' +
   '(ID, NAME, DESCRIPTION, TEMPLATEDATA, TEMPLATETYPE, AFULL, ACHAG, ' +
   'AVIEW, RESERVED) values (:ID, :NAME, :DESCRIPTION, :TEMPLATEDATA, ' +
   ':TEMPLATETYPE, :AFULL, :ACHAG, :AVIEW, :RESERVED)';
  AnIBSQL.Params[0].AsInteger := GetUniqueKey(AnIBSQL.Database, AnIBSQL.Transaction);
  AnTemplate.TemplateKey := AnIBSQL.Params[0].AsInteger;
  AnIBSQL.Params[1].AsString := AnTemplate.Name;
  AnIBSQL.Params[2].AsString := AnTemplate.Description;
  AnIBSQL.Params[3].LoadFromStream(AnTemplate.ReportTemplate);
  AnIBSQL.Params[4].AsString := AnTemplate.TemplateType;
  AnIBSQL.Params[5].AsInteger := AnTemplate.AFull;
  AnIBSQL.Params[6].AsInteger := AnTemplate.AChag;
  AnIBSQL.Params[7].AsInteger := AnTemplate.AView;
  AnIBSQL.ExecQuery;
end;

procedure TClientReport.CreateNewFunction(AnIBSQL: TIBSQL;
  AnFunction: TrpCustomFunction);
begin
  Assert((AnIBSQL <> nil) and (AnFunction <> nil), 'Can''t send nil');
  Assert(AnIBSQL.Database.Connected, 'Database must been connected');
  Assert(AnIBSQL.Transaction.InTransaction, 'Transaction must been started');

  if AnFunction.FunctionKey = 0 then
    Exit;
  AnIBSQL.Close;
  AnIBSQL.SQL.Text := 'insert into gd_function (ID, MODULE, LANGUAGE, NAME, ' +
   'COMMENT, SCRIPT, AFULL, ACHAG, AVIEW, MODIFYDATE) ' +
   'values(:ID, :MODULE, :LANGUAGE, :NAME, :COMMENT, :SCRIPT, :AFULL, :ACHAG, ' +
   ':AVIEW, :MODIFYDATE)';
  AnIBSQL.Params[0].AsInteger := GetUniqueKey(AnIBSQL.Database, AnIBSQL.Transaction);
  AnFunction.FunctionKey := AnIBSQL.Params[0].AsInteger;
  AnIBSQL.Params[1].AsString := AnFunction.Module;
  AnIBSQL.Params[2].AsString := AnFunction.Language;
  AnIBSQL.Params[3].AsString := AnFunction.Name;
  AnIBSQL.Params[4].AsString := AnFunction.Comment;
  AnIBSQL.Params[5].AsString := AnFunction.Script.Text;
  AnIBSQL.Params[6].AsInteger := AnFunction.AFull;
  AnIBSQL.Params[7].AsInteger := AnFunction.AChag;
  AnIBSQL.Params[8].AsInteger := AnFunction.AView;
  AnIBSQL.Params[9].AsDateTime := AnFunction.ModifyDate;
  AnIBSQL.ExecQuery;
end;

procedure TClientReport.CreateNewReport(AnReport: TCustomReport);
var
  LocIBTR: TIBTransaction;
  LocIBSQL: TIBSQL;
  I: Integer;
begin
  LocIBTR := TIBTransaction.Create(nil);
  try
    try
      LocIBTR.DefaultDatabase := FDatabase;
      LocIBTR.StartTransaction;
      LocIBSQL := TIBSQL.Create(nil);
      try
        LocIBSQL.Database := FDatabase;
        LocIBSQL.Transaction := LocIBTR;
        CreateNewTemplate(LocIBSQL, AnReport.TemplateStructure);
        CreateNewFunction(LocIBSQL, AnReport.ParamFunction);
        CreateNewFunction(LocIBSQL, AnReport.MainFunction);
        CreateNewFunction(LocIBSQL, AnReport.EventFunction);

        LocIBSQL.Close;
        LocIBSQL.SQL.Text := 'insert into rp_reportlist (ID, NAME, DESCRIPTION, ' +
         'FRQREFRESH, REPORTGROUPKEY, PARAMFORMULAKEY, MAINFORMULAKEY, ' +
         'EVENTFORMULAKEY, TEMPLATEKEY, ISREBUILD, AFULL, ACHAG, AVIEW, ' +
         'SERVERKEY, ISLOCALEXECUTE, PREVIEW) values(:ID, :NAME, ' +
         ':DESCRIPTION, :FRQREFRESH, :REPORTGROUPKEY, :PARAMFORMULAKEY, ' +
         ':MAINFORMULAKEY, :EVENTFORMULAKEY, :TEMPLATEKEY, :ISREBUILD, :AFULL, ' +
         ':ACHAG, :AVIEW, :SERVERKEY, :ISLOCALEXECUTE, :PREVIEW)';

        for I := 0 to LocIBSQL.Params.Count - 1 do
          LocIBSQL.Params[I].Clear;

        LocIBSQL.Params[0].AsInteger := GetUniqueKey(LocIBSQL.Database, LocIBSQL.Transaction);
        LocIBSQL.Params[1].AsString := AnReport.ReportName;
        LocIBSQL.Params[2].AsString := AnReport.Description;
        LocIBSQL.Params[3].AsInteger := AnReport.FrqRefresh;
        LocIBSQL.Params[4].AsInteger := AnReport.ReportGroupKey;
        if AnReport.ParamFunction.FunctionKey <> 0 then
          LocIBSQL.Params[5].AsInteger := AnReport.ParamFunction.FunctionKey;
        if AnReport.MainFunction.FunctionKey <> 0 then
          LocIBSQL.Params[6].AsInteger := AnReport.MainFunction.FunctionKey;
        if AnReport.EventFunction.FunctionKey <> 0 then
          LocIBSQL.Params[7].AsInteger := AnReport.EventFunction.FunctionKey;
        if AnReport.TemplateStructure.TemplateKey <> 0 then
          LocIBSQL.Params[8].AsInteger := AnReport.TemplateStructure.TemplateKey;
        LocIBSQL.Params[9].AsInteger := Integer(AnReport.IsRebuild);
        LocIBSQL.Params[10].AsInteger := AnReport.AFull;
        LocIBSQL.Params[11].AsInteger := AnReport.AChag;
        LocIBSQL.Params[12].AsInteger := AnReport.AView;
        LocIBSQL.Params[13].Value := AnReport.ServerKey;
        LocIBSQL.Params[14].AsInteger := Integer(AnReport.IsLocalExecute);
        LocIBSQL.Params[15].AsInteger := Integer(AnReport.Preview);
        LocIBSQL.ExecQuery;
      finally
        LocIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        if LocIBTR.InTransaction then
          LocIBTR.Rollback;
        MessageBox(0, PChar('Произошла ошибка при создании отчета из файла'#13#10 +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
      end;
    end
  finally
    if LocIBTR.InTransaction then
      LocIBTR.Commit;
    LocIBTR.Free;
  end;
end;
  *)
// TServerReport

procedure TServerReport.PrepareReportList(const AnReportList: TReportList);
var
  I: Integer;
  ibsqlWork, ibsqlFunction: TIBQuery;
  ResultDataSet: TDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' PrepareReportList');
  {$ENDIF}
  try
    ibsqlWork := TIBQuery.Create(nil);
    try
      PrepareSourceDatabase;
      ibsqlWork.Database := FDatabase;
      ibsqlWork.Transaction := FTransaction;
      ibsqlWork.SQL.Text := 'SELECT mainformulakey, MIN(frqrefresh) FROM ' +
       'rp_reportlist WHERE serverkey = ' + IntToStr(FServerKey) +
       ' OR serverkey IS NULL GROUP BY mainformulakey';
      ibsqlWork.Open;

      ibsqlFunction := TIBQuery.Create(nil);
      try
        ibsqlFunction.Database := FDatabase;
        ibsqlFunction.Transaction := FTransaction;
        ibsqlFunction.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
        ibsqlFunction.Prepare;

        PrepareResultDataSet;
        try
          AnReportList.Clear;
          while not ibsqlWork.Eof do
          begin
            I := AnReportList.AddReport;
            AnReportList.Reports[I].FrqRefresh := ibsqlWork.FieldByName('min').AsInteger;
            ibsqlFunction.Close;
            ibsqlFunction.Params[0].AsInteger := ibsqlWork.FieldByName('mainformulakey').AsInteger;
            ibsqlFunction.Open;
            AnReportList.Reports[I].MainFunction.ReadFromDataSet(ibsqlFunction);

            ResultDataSet := GetFiltredDataSet('functionkey = ' +
             IntToStr(AnReportList.Reports[I].MainFunction.FunctionKey) + ' AND createdate < ''' +
             IBDateTimeToStr(AnReportList.Reports[I].MainFunction.ModifyDate) + '''');
            ResultDataSet.First;
            while not ResultDataSet.Eof do
            begin
              SaveLog('Удален результат функции ' + ResultDataSet.FieldByName('functionkey').AsString +
               ' CRC: ' + ResultDataSet.FieldByName('crcparam').AsString);
              ResultDataSet.Delete;
            end;

            ResultDataSet := GetFiltredDataSet('functionkey = ' +
             IntToStr(AnReportList.Reports[I].MainFunction.FunctionKey) +
             ' AND lastusedate > ''' + IBDateTimeToStr(Now - FActualReport -
             ibsqlWork.FieldByName('min').AsInteger) + ''' AND createdate < ''' +
             IBDateTimeToStr(Now - ibsqlWork.FieldByName('min').AsInteger + FrqRebuildReport) + '''');
            AnReportList.Reports[I].ReportResultList.ReadFromDataSet(ResultDataSet);

            ibsqlWork.Next;
          end;
        finally
          UnPrepareResultDataSet;
        end;
      finally
        ibsqlFunction.Free;
      end;
    finally
      ibsqlWork.Free;
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

constructor TServerReport.Create(Owner: TComponent);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' Create');
  {$ENDIF}
  inherited Create(Owner);

  FServerState := rsIdle;
  FServerKey := 0;
  FSourceState := 0;
  FLocState := 0;
  FLogFileName := '';
  FRefreshTimer := nil;
  FLastBuildDate := 0;
  FServerSocket := nil;
  FSocketList := nil;
  FCloseSourceConection := nil;

  if not (csDesigning in ComponentState) then
  begin
    FRefreshTimer := TTimer.Create(nil);
    FRefreshTimer.Enabled := False;
    FRefreshTimer.OnTimer := RefreshTimerExecute;

    FCloseSourceConection := TTimer.Create(nil);
    FCloseSourceConection.Enabled := False;
    FCloseSourceConection.OnTimer := CloseTimerExecute;
    FCloseSourceConection.Interval := 150000;

    FServerSocket := TServerSocket.Create(nil);
    SetErrorProc(ProcErrorSocket);
    FServerSocket.Port := DefaultTCPPort;
    FServerSocket.OnClientRead := ServerClientRead;
    FServerSocket.OnClientConnect := ServerClientConnect;
    FServerSocket.OnClientDisconnect := ServerClientDisconnect;
    FServerSocket.OnClientError := ServerClientError;
    FSocketList := TList.Create;

  {$IFDEF LogReport}
    SaveLog(#13#10'Старт программы');
  {$ENDIF}
    for I := 0 to ParamCount do
      SaveLog(ParamStr(I));

    {$IFNDEF GEDEMIN}
    if not Assigned(FReportScriptControl) then
    begin
      SaveLog(ScriptControlNotRegister);
      raise Exception.Create(ScriptControlNotRegister);
    end;

    FReportScriptControl.AllowUI := False;
    {$ENDIF}
  end;
end;

destructor TServerReport.Destroy;
begin
  {$IFDEF DEBUG}
  SaveLog(' Destroy');
  {$ENDIF}

  if FSourceState > 0 then
    UnPrepareResultDataSet;

  if not (csDesigning in ComponentState) then
  begin
  {$IFDEF LogReport}
    SaveLog('Завершение программы');
  {$ENDIF}
  end;

  //if FLogFile <> nil then
  //  FreeAndNil(FLogFile);
  if FRefreshTimer <> nil then
    FreeAndNil(FRefreshTimer);
  if Assigned(FServerSocket) then
    FreeAndNil(FServerSocket);
  if Assigned(FSocketList) then
    FreeAndNil(FSocketList);

  inherited Destroy;
end;

procedure TServerReport.CloseTimerExecute(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog(' CloseTimerExecute');
  {$ENDIF}
  // В данном случае следует отключать результирующий ДатаСет,
  // т.к. подключение к рабочей базе может оставаться только
  // в том случае, если хранилище результатов тоже является
  // рабочей базой
  if FServerState <> rsIdle then
    Exit;
  if FSourceState > 0 then
    UnPrepareResultDataSet;
  FCloseSourceConection.Enabled := False;
end;

procedure TServerReport.RefreshTimerExecute(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog(' RefreshTimerExecute');
  {$ENDIF}
  FRefreshTimer.Enabled := False;
  try
    try
      Load;
      if (FLastBuildDate <= Trunc(Now) - FrqRebuildReport) and (FStartTime <= Frac(Now)) and
       (FEndTime >= Frac(Now)) then
        RebuildReports;
    finally
      FRefreshTimer.Enabled := True;
    end;
  except
    on E: Exception do
      SaveLog('Произошла ошибка при плановой работе сервера отчетов:'#13#10 +
       E.Message);
  end;
end;

procedure TServerReport.DeleteUnactualReport;
var
  ibsqlWork, ibsqlFunction: TIBQuery;
  ResultDataSet: TDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' DeleteUnactualReport');
  {$ENDIF}
  try
    SaveLog('Начат автоматический процесс очистки хранилища');
    ibsqlWork := TIBQuery.Create(nil);
    try
      PrepareSourceDatabase;
      ibsqlWork.Database := FDatabase;
      ibsqlWork.Transaction := FTransaction;
      ibsqlWork.SQL.Text := 'SELECT mainformulakey, MAX(frqrefresh) FROM ' +
       'rp_reportlist WHERE serverkey = ' + IntToStr(FServerKey) +
       ' OR serverkey IS NULL GROUP BY mainformulakey';
      ibsqlWork.Open;

      ibsqlFunction := TIBQuery.Create(nil);
      try
        ibsqlFunction.Database := FDatabase;
        ibsqlFunction.Transaction := FTransaction;
        ibsqlFunction.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
        ibsqlFunction.Prepare;

        PrepareResultDataSet;
        try
          while not ibsqlWork.Eof do
          begin
            ibsqlFunction.Close;
            ibsqlFunction.Params[0].AsInteger := ibsqlWork.FieldByName('mainformulakey').AsInteger;
            ibsqlFunction.Open;

            ResultDataSet := GetFiltredDataSet('functionkey = ' +
             ibsqlFunction.FieldByName('id').AsString +
             ' AND lastusedate < ''' + IBDateTimeToStr(Now - FUnActualReport -
             ibsqlWork.FieldByName('max').AsInteger) + '''');
            ResultDataSet.First;
            while not ResultDataSet.Eof do
            begin
              SaveLog('Удален результат функции ' + ResultDataSet.FieldByName('functionkey').AsString +
               ' CRC: ' + ResultDataSet.FieldByName('crcparam').AsString);
              ResultDataSet.Delete;
            end;

            ibsqlWork.Next;
          end;
        finally
          UnPrepareResultDataSet;
        end;
      finally
        ibsqlFunction.Free;
      end;
    finally
      ibsqlWork.Free;
      UnPrepareSourceDatabase;
      SaveLog('Процесс автоматической очистки хранилища завершен');
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

procedure TServerReport.RebuildReports;
var
  LocReportList: TReportList;
  I, J: Integer;
  StateDB, StateTR: Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog(' RebuildReports');
  {$ENDIF}
  if FServerState <> rsIdle then
  begin
    SaveLog(Format('ОШИБКА!!! Произошел збой при попытке перестройки. Сервер занят "%s".',
     [rpSetServerState(FServerState)]));
    Exit;
  end;

  FServerState := rsRebuild;
  try
    StateDB := FDatabase.Connected;
    StateTR := FTransaction.InTransaction;
    LocReportList := TReportList.Create;
    try
      if not StateDB then
        FDatabase.Connected := True;
      if not StateTR then
        FTransaction.StartTransaction;

      LocReportList.Database := FDatabase;
      LocReportList.Transaction := FTransaction;

      PrepareResultDataSet;
      try
        DeleteUnactualReport;
        SaveLog('Начат процесс автоматической перестройки отчетов');
        PrepareReportList(LocReportList);

        for I := 0 to LocReportList.Count - 1 do
          for J := 0 to LocReportList.Reports[I].ReportResultList.Count - 1 do
            ExecuteReportAndSaveResult(LocReportList.Reports[I],
             LocReportList.Reports[I].ReportResultList.ResultStructure[J].Params);

        FLastBuildDate := Trunc(Now);
      finally
        UnPrepareResultDataSet;
        SaveLog('Процесс автоматической перестройки отчетов завершен');
      end;
    finally
      if not StateTR then
        FTransaction.Commit;
      if not StateDB then
        FDatabase.Connected := False;
      LocReportList.Free;
    end;
  finally
    FServerState := rsIdle;
  end;
end;

function TServerReport.FindReportResult(const AnReport: TCustomReport; const AnParam: Variant;
 const AnReportResult: TrpResultStructure; const AnIsUpdateUsed: Boolean = False): Boolean;
var
  CRCParam: Integer;
  Str: TStream;
  VStr: TVarStream;
  TempVar: Variant;
  LocDataSet: TDataSet;
  LocFunction: TrpCustomFunction;
begin
  {$IFDEF DEBUG}
  SaveLog(' FindReportResult');
  {$ENDIF}
  Result := False;
  LocFunction := AnReport.MainFunction;
  PrepareResultDataSet;
  try
    CRCParam := GetParamCRC(AnParam);
    LocDataSet := GetFiltredDataSet('functionkey = ' + IntToStr(LocFunction.FunctionKey) +
     ' AND crcparam = ' + IntToStr(CRCParam));
    LocDataSet.First;
    while not LocDataSet.Eof do
    begin
      if (LocDataSet.FieldByName('createdate').AsDateTime >= LocFunction.ModifyDate)
       and (LocDataSet.FieldByName('createdate').AsDateTime + FUnActualReport + AnReport.FrqRefresh >= Now) then
      begin
        Str := LocDataSet.CreateBlobStream(LocDataSet.FieldByName('paramdata'), DB.bmRead);
        try
          VStr := TVarStream.Create(Str);
          try
            VStr.Read(TempVar);
          finally
            VStr.Free;
          end;
        finally
          Str.Free;
        end;

        if CompareParams(TempVar, AnParam) then
        begin
          Result := True;
          Break;
        end;
        LocDataSet.Next;
      end else
        LocDataSet.Delete;
    end;

    if Result then
    begin
      if AnIsUpdateUsed then
      begin
        LocDataSet.Edit;
        LocDataSet.FieldByName('lastusedate').AsDateTime := Now;
        LocDataSet.Post;
        CommitResultDataSet;
      end;
      AnReportResult.ReadFromDataSet(LocDataSet)
    end else
    begin
      AnReportResult.CRCParam := CRCParam;
      LocDataSet.Last;
      if not LocDataSet.Eof then
        AnReportResult.ParamOrder := LocDataSet.FieldByName('paramorder').AsInteger + 1
      else
        AnReportResult.ParamOrder := 0;
    end;
  finally
    UnPrepareResultDataSet;
  end;
end;

procedure TServerReport.UpdateReportResult(const AnFunction: TrpCustomFunction; const AnrpResStruct: TrpResultStructure);
var
  LocDataSet: TDataSet;
  Str: TStream;
begin
  {$IFDEF DEBUG}
  SaveLog(' UpdateReportResult');
  {$ENDIF}
  PrepareResultDataSet;
  try
    LocDataSet := GetResultDataSet;
    LocDataSet.Edit;
    LocDataSet.FieldByName('functionkey').AsInteger := AnFunction.FunctionKey;
    LocDataSet.FieldByName('crcparam').AsInteger := AnrpResStruct.CRCParam;
    LocDataSet.FieldByName('paramorder').AsInteger := AnrpResStruct.ParamOrder;

    LocDataSet.FieldByName('createdate').AsDateTime := Now;
    LocDataSet.FieldByName('executetime').AsDateTime := AnrpResStruct.ExecuteTime;
    Str := LocDataSet.CreateBlobStream(LocDataSet.FieldByName('resultdata'), DB.bmWrite);
    try
      if AnrpResStruct.ReportResult.IsStreamData then
      begin
        AnrpResStruct.ReportResult.TempStream.SaveToStream(Str);
        Str.Size := AnrpResStruct.ReportResult.TempStream.Size;
      end else
        AnrpResStruct.ReportResult.SaveToStream(Str);
    finally
      Str.Free;
    end;

    LocDataSet.Post;
    CommitResultDataSet;
  finally
    UnPrepareResultDataSet;
  end;
end;

procedure TServerReport.InsertReportResult(const AnFunction: TrpCustomFunction;
 const AnrpResStruct: TrpResultStructure);
var
  LocDataSet: TDataSet;
  Str: TStream;
  VStr: TVarStream;
begin
  {$IFDEF DEBUG}
  SaveLog(' InsertReportResult');
  {$ENDIF}
  PrepareResultDataSet;
  try
    LocDataSet := GetResultDataSet;

    LocDataSet.Insert;
    LocDataSet.FieldByName('functionkey').AsInteger := AnFunction.FunctionKey;
    LocDataSet.FieldByName('crcparam').AsInteger := AnrpResStruct.CRCParam;
    LocDataSet.FieldByName('paramorder').AsInteger := AnrpResStruct.ParamOrder;

    LocDataSet.FieldByName('createdate').AsDateTime := Now;
    LocDataSet.FieldByName('executetime').AsDateTime := AnrpResStruct.ExecuteTime;
    LocDataSet.FieldByName('lastusedate').AsDateTime :=
     LocDataSet.FieldByName('createdate').AsDateTime;

    Str := LocDataSet.CreateBlobStream(LocDataSet.FieldByName('resultdata'), DB.bmWrite);
    try
      if AnrpResStruct.ReportResult.IsStreamData then
      begin
        AnrpResStruct.ReportResult.TempStream.SaveToStream(Str);
        Str.Size := AnrpResStruct.ReportResult.TempStream.Size;
      end else
        AnrpResStruct.ReportResult.SaveToStream(Str);
    finally
      Str.Free;
    end;

    Str := LocDataSet.CreateBlobStream(LocDataSet.FieldByName('paramdata'), DB.bmWrite);
    try
      VStr := TVarStream.Create(Str);
      try
        VStr.Write(AnrpResStruct.Params);
      finally
        VStr.Free;
      end;
    finally
      Str.Free;
    end;

    LocDataSet.Post;
    CommitResultDataSet;
  finally
    UnPrepareResultDataSet;
  end;
end;

function TServerReport.CheckActualReport(const AnReport: TCustomReport;
 const AnResultStruct: TrpResultStructure): Boolean;
begin
  Result := False;
  {TODO 1: jkl Проверка актуальности отчета}
end;

{
procedure ServerThreadEvent(AnSocketData: TrpSocketData);
begin
end;
}

procedure TServerReport.ServerThreadEvent(AnSocketData: TrpSocketData);
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerThreadEvent');
  {$ENDIF}
  with TReportResultThread.Create(Self, AnSocketData) do
    OnSendData := ServerEvent;
end;

procedure TServerReport.ServerEvent(AnSocketData: TrpSocketData);
var
  TempBuf: TDnByteArray;
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerEvent');
  {$ENDIF}
{  AnSocketData.Params := GetReportResult(AnSocketData.ReportKey, AnSocketData.Params,
   AnSocketData.ReportResult);}
  AnSocketData.WriteData(TempBuf);
  for I := 0 to FServerSocket.Socket.ActiveConnections - 1 do
    if FServerSocket.Socket.Connections[I].SocketHandle = AnSocketData.SocketHandle then
    begin
      FServerSocket.Socket.Connections[I].Lock;
      try
        if FServerSocket.Socket.Connections[I].SendBuf(TempBuf[0], Length(TempBuf)) = Length(TempBuf) then
          SaveLog('Результат выполнения отчета был передан клиенту')
        else
          SaveLog('Возникла ОШИБКА при передаче результата отчета');
      finally
        FServerSocket.Socket.Connections[I].Unlock;
      end;
      Break;
    end;
  AnSocketData.ReportResult.Clear;
  AnSocketData.ReportResult.TempStream.Clear;
end;

procedure TServerReport.ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  BufSize: Integer;
  TempBuffer: TDnByteArray;
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerClientRead');
  {$ENDIF}
  try
    BufSize := Socket.ReceiveLength;
    SetLength(TempBuffer, BufSize);
    BufSize := Socket.ReceiveBuf(TempBuffer[0], BufSize);
    SetLength(TempBuffer, BufSize);
    for I := 0 to FSocketList.Count - 1 do
      if TrpSocketData(FSocketList.Items[I]).SocketHandle = Socket.SocketHandle then
      begin
        TrpSocketData(FSocketList.Items[I]).ReadData(TempBuffer, BufSize);
        Break;
      end;
  except
    on E: Exception do
      SaveLog('Произошла ошибка при разборе запроса с клиентской части: ' + E.Message);
  end;
end;

procedure TServerReport.ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerClientConnect');
  {$ENDIF}
  I := FSocketList.Add(TrpSocketData.Create);
  TrpSocketData(FSocketList.Items[I]).SocketHandle := Socket.SocketHandle;
  TrpSocketData(FSocketList.Items[I]).SingleBlock := False;
  TrpSocketData(FSocketList.Items[I]).OnThreadCreate := ServerThreadEvent;
end;

procedure TServerReport.ServerClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerClientDisconnect');
  {$ENDIF}
  for I := 0 to FSocketList.Count - 1 do
    if TrpSocketData(FSocketList.Items[I]).SocketHandle = Socket.SocketHandle then
    begin
      TrpSocketData(FSocketList.Items[I]).Free;
      FSocketList.Delete(I);
      Break;
    end;
end;

procedure TServerReport.ServerClientError(Sender: TObject; Socket: TCustomWinSocket;
 ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerClientError');
  {$ENDIF}
  try
    Socket.Close;
    ErrorCode := 0;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

function TServerReport.GetActiveConnections: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' GetActiveConnections');
  {$ENDIF}
  Result := 0;
  if Assigned(FServerSocket) then
    Result := FServerSocket.Socket.ActiveConnections;
end;

function TServerReport.GetReportResult(const AnReportKey: Integer;
 const AnParam: Variant; const AnReportResult: TReportResult;
 const AnIsMakeRebuild: Boolean; out AnBuildDate: TDateTime): Variant;
var
  LocReport: TCustomReport;
  ResultStruct: TrpResultStructure;
  LocParam: Variant;
  FindNow: Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog(' GetReportResult');
  {$ENDIF}
  Result := False;
  try

    if FServerState <> rsIdle then
    begin
      SaveLog(Format('ОШИБКА!!! Произошел збой при попытке запроса результата. Сервер занят "%s".',
       [rpSetServerState(FServerState)]));
      Exit;
    end;

    FServerState := rsGetResult;
    try
      ResultStruct := TrpResultStructure.Create;
      try
        ResultStruct.ReportResult.IsStreamData := True;
    {    LocReport := FReportList.FindReport(AnReportKey);
        if LocReport = nil then
        begin
          SaveLog('Не обнаружен отчет ' + IntToStr(AnReportKey) + '. Обновление данных.');
          Refresh;
          LocReport := FReportList.FindReport(AnReportKey);
        end;
        if LocReport <> nil then
        // Этот кусок кода позволяет кэшировать данные на сервере }

        LocReport := TCustomReport.Create;
        if ThisFunc then
          FindNow := FindFunctionNow(AnReportKey, LocReport, False)
        else
          FindNow := FindReportNow(AnReportKey, LocReport, False);
        try
  //        if FindReportNow(AnReportKey, LocReport, False) then
          if FindNow then
          begin
            if AnIsMakeRebuild then
              RefreshReport(LocReport);

            Result := True;
            if not LocReport.IsRebuild and not AnIsMakeRebuild then
              if FindReportResult(LocReport, AnParam, ResultStruct, True) then
                AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
              else
              begin
                ExecuteReportAndSaveResult(LocReport, AnParam);
                Result := FindReportResult(LocReport, AnParam, ResultStruct, True);
                if Result then
                  AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
                else
                begin
                  SaveLog('ОШИБКА: Результат сохранен но не найден.');
                  //{error} raise Exception.Create('');
                  Result := FLastErrorMsg;
                end;
              end
            else
            begin
              Result := False;
              LocParam := AnParam;

              if FindReportResult(LocReport, AnParam, ResultStruct, True) then
                if CheckActualReport(LocReport, ResultStruct) and not AnIsMakeRebuild then
                begin
                  AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream);
                  Result := True;
                end;

              if not Result then
              begin
                ExecuteReportAndSaveResult(LocReport, AnParam);
                Result := FindReportResult(LocReport, AnParam, ResultStruct, True);
                if Result then
                  AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
                else
                begin
                  SaveLog('ОШИБКА: Результат сохранен но не найден.');
                  Result := FLastErrorMsg;
                end;
              end;

              {Result := ExecuteFunctionWithoutParam(LocReport.MainFunction, AnReportResult, LocParam);
              if not Result then
                SaveLog('ОШИБКА: Функция выполнена с ошибкой. ' + LocParam);}
            end;
            if (VarType(Result) = varBoolean) then
              if Result then
                SaveLog('Успешно возвращен результат отчета ' + IntToStr(AnReportKey));
          end else
            SaveLog('Не обнаружен отчет ' + IntToStr(AnReportKey));
        finally
          LocReport.Free;
        end;
      finally
        AnBuildDate := ResultStruct.CreateDate;
        ResultStruct.Free;
      end;
    finally
      FServerState := rsIdle;
    end;
  except
    on E: Exception do
    begin
      SaveLog('Произошла ошибка при попытке получить результат на сервере отчетов:');
      SaveLog(E.Message);
    end;
  end;
end;

procedure TServerReport.ExecuteReportAndSaveResult(const AnReport: TCustomReport;
 const AnParam: Variant);
var
  ReportResult: TReportResult;
  LocParam: Variant;
  ExTime: TDateTime;
  RpResStruct: TrpResultStructure;
  LocFunction: TrpCustomFunction;
begin
  {$IFDEF DEBUG}
  SaveLog(' ExecuteReportAndSaveResult');
  {$ENDIF}
  LocFunction := AnReport.MainFunction;

  ReportResult := TReportResult.Create;
  try
    PrepareResultDataSet;
    try
      ExTime := Now;
      LocParam := AnParam;

      if ExecuteFunctionWithoutParam(LocFunction, ReportResult, LocParam) then
      begin
        ExTime := Now - ExTime;

        RpResStruct := TrpResultStructure.Create;
        try
          if FindReportResult(AnReport, AnParam, RpResStruct) then
          begin
            RpResStruct.ExecuteTime := ExTime;
            RpResStruct.ReportResult.Assign(ReportResult);
            UpdateReportResult(LocFunction, RpResStruct);
          end else
          begin
            RpResStruct.ExecuteTime := ExTime;
            RpResStruct.ReportResult.Assign(ReportResult);
            RpResStruct.Params := AnParam;
            InsertReportResult(LocFunction, RpResStruct);
          end;
          SaveLog('Функция построена успешно ' + IntToStr(LocFunction.FunctionKey) + ' CRC: ' + IntToStr(RpResStruct.CRCParam));
        finally
          RpResStruct.Free;
        end;
      end else
      begin
        SaveLog('Произошла ошибка при выполнении функции ' + IntToStr(LocFunction.FunctionKey) + ' ' + LocParam);
        FLastErrorMsg := LocParam;
      end;
    finally
      UnPrepareResultDataSet;
    end;
  finally
    ReportResult.Free;
  end;
end;

procedure TServerReport.SaveLog(const S: String);
(*{$IFDEF LogReport}
var
  F: TextFile;
{$ENDIF}
begin
  {$IFDEF LogReport}
  if FLogFileName = '' then
    FLogFileName := ChangeFileExt(Application.EXEName, '.log');
//    FLogFileName := rpGetTemporaryFileName('rpsrvlog');

  try
    AssignFile(F, FLogFileName);
    if FileExists(FLogFileName) then
      Append(F)
    else
      Rewrite(F);
    try
      Writeln(F, S + ': ' + DateTimeToStr(Now));
      Flush(F);
    finally
      CloseFile(F);
    end;
  except
    //
  end;
  {$ENDIF}*)
begin
  try
    inherited SaveLog(S);
  except
    {on E: Exception do
      MessageBox(0, PChar(E.Message), 'SaveLog', MB_OK);}
  end;
end;

function TServerReport.CheckFieldsStructure(const AnClientDataSet: TClientDataSet): Boolean;
var
  LocClientDataSet: TClientDataSet;
  I: Integer;
  LocField: TField;
begin
  {$IFDEF DEBUG}
  SaveLog(' CheckFieldsStructure');
  {$ENDIF}
  Result := AnClientDataSet.Active;
  if Result then
  begin
    LocClientDataSet := TClientDataSet.Create(nil);
    try
      CopyResultFields(LocClientDataSet);

      for I := 0 to LocClientDataSet.FieldCount - 1 do
      begin
        LocField := AnClientDataSet.FindField(LocClientDataSet.Fields[I].FieldName);
        Result := LocField <> nil;
        if not Result then
          Exit;

        Result := (LocClientDataSet.Fields[I].FieldName = LocField.FieldName)
         and (LocClientDataSet.Fields[I].DataType = LocField.DataType);
        if not Result then
          Exit;
      end;

      AnClientDataSet.IndexFieldNames := LocClientDataSet.IndexFieldNames;
    finally
      LocClientDataSet.Free;
    end;
  end;
end;

procedure TServerReport.CopyResultFields(const AnClientDataSet: TClientDataSet);
var
  LocDataSetProvider: TDataSetProvider;
  ibqryTemplate: TIBQuery;
begin
  {$IFDEF DEBUG}
  SaveLog(' CopyResultFields');
  {$ENDIF}
  try
    PrepareSourceDatabase;
    try
      LocDataSetProvider := TDataSetProvider.Create(Self);
      try
        ibqryTemplate := TIBQuery.Create(Self);
        try
          ibqryTemplate.Database := FDatabase;
          ibqryTemplate.Transaction := FTransaction;
          ibqryTemplate.SQL.Text := 'SELECT * FROM rp_reportresult WHERE functionkey IS NULL';
          ibqryTemplate.Open;
          LocDataSetProvider.DataSet := ibqryTemplate;
          AnClientDataSet.SetProvider(LocDataSetProvider);
          AnClientDataSet.Open;
          AnClientDataSet.IndexFieldNames := ReportResultIndex;
        finally
          ibqryTemplate.Free;
        end;
      finally
        LocDataSetProvider.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

procedure TServerReport.PrepareResultDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' PrepareResultDataSet');
  {$ENDIF}
  try
    if FSourceState = 0 then
    begin
      case FSourceType of
        0:
        begin
          PrepareSourceDatabase;
          try
            FibdsResult := TIBDataSet.Create(nil);
            FibdsResult.Database := FDatabase;
            FibdsResult.Transaction := FTransaction;
            FibdsResult.SelectSQL.Text := ResultSelectSQL + ResultOrderSQL;
            FibdsResult.InsertSQL.Text := ResultInsertSQL;
            FibdsResult.ModifySQL.Text := ResultUpdateSQL;
            FibdsResult.DeleteSQL.Text := ResultDeleteSQL;
            FibdsResult.Open;
            SaveLog('Установленно подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
          except
            on E: Exception do
            begin
              if FibdsResult <> nil then
                FibdsResult.Free;
              UnPrepareSourceDatabase;
              SaveLog('Возникла ОШИБКА при подключении к хранилищу результатов, тип ' +
               IntToStr(FSourceType) + #13#10 + E.Message);
              Exit;
            end;
          end;
        end;
        1:
        try
          FResultDatabase := TIBDatabase.Create(nil);
          FResultDatabase.DatabaseName := FResultPath;
          if FIBParams > '' then
            FResultDatabase.Params.Text := FIBParams
          else
          begin
            { TODO : На всякий пожарный}
            FResultDatabase.Params.Add('user_name=' + SysDBAUserName);
            FResultDatabase.Params.Add('password=masterkey');
            FResultDatabase.Params.Add('lc_ctype=WIN1251');
            { TODO : !!!
  пароль не обязательно будет masterkey!
  пользователь, как правило, будет его менять
  мы рекомендуем это при инстолляции программы }
          end;
          FResultDatabase.LoginPrompt := False;
          FResultDatabase.SQLDialect := 3;

          FResultDatabase.Connected := True;

          FResultTransaction := TIBTransaction.Create(nil);
          FResultTransaction.DefaultDatabase := FResultDatabase;
          FResultTransaction.Params.Assign(FTransaction.Params);
          FResultTransaction.StartTransaction;

          FibdsResult := TIBDataSet.Create(nil);
          FibdsResult.Database := FResultDatabase;
          FibdsResult.Transaction := FResultTransaction;
          FibdsResult.SelectSQL.Text := ResultSelectSQL + ResultOrderSQL;
          FibdsResult.InsertSQL.Text := ResultInsertSQL;
          FibdsResult.ModifySQL.Text := ResultUpdateSQL;
          FibdsResult.DeleteSQL.Text := ResultDeleteSQL;
          FibdsResult.Open;
          SaveLog('Установленно подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
        except
          on E: Exception do
          begin
            if FibdsResult <> nil then
              FibdsResult.Free;
            if FResultTransaction <> nil then
              FResultTransaction.Free;
            if FResultDatabase <> nil then
              FResultDatabase.Free;
            SaveLog('Возникла ОШИБКА при подключении к хранилищу результатов, тип ' +
             IntToStr(FSourceType) + #13#10 + E.Message);
            Exit;
          end;
        end;
        2:
        try
          FLocResultTable := TClientDataSet.Create(Self);
          if Trim(FResultPath) = '' then
            FResultPath := 'ReportStorage.cds';
          if FileExists(FResultPath) then
          begin
            FLocResultTable.LoadFromFile(FResultPath);
            FLocResultTable.Active := CheckFieldsStructure(FLocResultTable);
            if not FLocResultTable.Active then
              SaveLog('Структура файла не соответствует структуре таблицы');
          end;

          if not FLocResultTable.Active then
          begin
            CopyResultFields(FLocResultTable);
            SaveLog('Создан файл с новой структурой: ' + FResultPath);
          end;

          SaveLog('Установленно подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
        except
          on E: Exception do
          begin
            if FLocResultTable <> nil then
              FLocResultTable.Free;
            SaveLog('Возникла ОШИБКА при подключении к хранилищу результатов, тип ' +
             IntToStr(FSourceType) + #13#10 + E.Message);
            Exit;
          end;
        end;
      else
        raise Exception.Create('Not supported');
      end;
      Inc(FSourceState);
    end;
    Inc(FSourceState);
    FCloseSourceConection.Enabled := False;
    FCloseSourceConection.Enabled := True;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

procedure TServerReport.UnPrepareResultDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' UnPrepareResultDataSet');
  {$ENDIF}
  try
    Dec(FSourceState);
    if FSourceState = 0 then
      case FSourceType of
        0:
        begin
          FibdsResult.Close;
          FreeAndNil(FibdsResult);
          UnPrepareSourceDatabase;
          SaveLog('Завершено подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
        end;
        1:
        begin
          FibdsResult.Close;
          FResultTransaction.Commit;
          FResultDatabase.Connected := False;
          FreeAndNil(FibdsResult);
          FreeAndNil(FResultTransaction);
          FreeAndNil(FResultDatabase);
          SaveLog('Завершено подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
        end;
        2:
        begin
          FLocResultTable.SaveToFile(FResultPath);
          FreeAndNil(FLocResultTable);
          SaveLog('Завершено подключение к хранилищу результатов, тип ' + IntToStr(FSourceType));
        end;
      else
        raise Exception.Create('Not supported');
      end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

procedure TServerReport.CommitResultDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' CommitResultDataSet');
  {$ENDIF}
  if FSourceState <> 0 then
    case FSourceType of
      0: FTransaction.CommitRetaining;
      1: FResultTransaction.CommitRetaining;
      2: ;
    else
      raise Exception.Create('Not supported');
    end;
//  SaveLog('Произошел CommitRetaining для транзакции, тип ' + IntToStr(FSourceType));
end;

procedure TServerReport.RefreshReport(const AnReport: TCustomReport);
var
  ibqryRefresh: TIBQuery;
  LocFunctionKey: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog(' RefreshReport');
  {$ENDIF}
  try
    PrepareSourceDatabase;
    try
      ibqryRefresh := TIBQuery.Create(nil);
      try
        ibqryRefresh.Database := FDatabase;
        ibqryRefresh.Transaction := FTransaction;
        ibqryRefresh.SQL.Text := Format('SELECT * FROM rp_reportlist WHERE id = %d',
         [AnReport.ReportKey]);
        ibqryRefresh.Open;
        AnReport.ReadFromDataSet(ibqryRefresh);
        LocFunctionKey := ibqryRefresh.FieldByName('mainformulakey').AsInteger;
        ibqryRefresh.Close;
        ibqryRefresh.SQL.Text := Format('SELECT * FROM gd_function WHERE id = %d',
         [LocFunctionKey]);
        ibqryRefresh.Open;
        AnReport.MainFunction.ReadFromDataSet(ibqryRefresh);
      finally
        ibqryRefresh.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

function TServerReport.GetFiltredDataSet(const AnFilterText: String): TDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' GetFiltredDataSet');
  {$ENDIF}
  case FSourceType of
    0, 1:
    begin
      FibdsResult.Close;
      FibdsResult.SelectSQL.Text := ResultSelectSQL + ' WHERE ' + AnFilterText +
       ResultOrderSQL;
      FibdsResult.Open;
      Result := FibdsResult;
    end;
    2:
    begin
      FLocResultTable.Filtered := False;
      FLocResultTable.Filter := AnFilterText;
      FLocResultTable.Filtered := True;
      Result := FLocResultTable;
    end;
  else
    raise Exception.Create('Not supported');
  end;
end;

function TServerReport.GetResultDataSet: TDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' GetResultDataSet');
  {$ENDIF}
  case FSourceType of
    0, 1: Result := FibdsResult;
    2: Result := FLocResultTable;
  else
    raise Exception.Create('Not supported');
  end;
end;

function TServerReport.ServerOptions: Boolean;
var
  F: TdlgReportOptions;
begin
  {$IFDEF DEBUG}
  SaveLog(' ServerOptions');
  {$ENDIF}
  Result := False;
  try

    if FServerState <> rsIdle then
    begin
      SaveLog(Format('ОШИБКА!!! Произошел збой при попытке установки параметров. Сервер занят "%s".',
       [rpSetServerState(FServerState)]));
      Exit;
    end;

    FServerState := rsOption;
    try
      PrepareSourceDatabase;
      try
        F := TdlgReportOptions.Create(Self);
        try
          SetDatabaseAndTransaction(F, FDatabase, FTransaction);
          Result := F.ViewOptions(FServerKey);
          if Result then
          begin
            FTransaction.CommitRetaining;
            SaveLog('Изменены параметры сервера отчетов.');
            FServerState := rsIdle;
            Load;
            FServerState := rsOption;
          end;
        finally
          F.Free;
        end;
      finally
        UnPrepareSourceDatabase;
      end;
    finally
      FServerState := rsIdle;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
  end;
end;

procedure TServerReport.Load;
var
  ibsqlWork: TIBSQL;
  S: String;
begin
  {$IFDEF DEBUG}
  SaveLog(' Load');
  {$ENDIF}
{  asm
    pop ESP
  end;}
  try
    if FServerState <> rsIdle then
    begin
      SaveLog(Format('ОШИБКА!!! Произошел збой при попытке обновления данных. Сервер занят "%s".',
       [rpSetServerState(FServerState)]));
      Exit;
    end;

    FServerState := rsRefresh;
    try
      if FSourceState > 0 then
        UnPrepareResultDataSet;

      if FSourceState > 0 then
      begin
        SaveLog('ОШИБКА! При обновлении данных количество подготовок ' + IntToStr(FSourceState));
        FSourceState := 1;
        UnPrepareResultDataSet;
      end;

      FSourceType := 0;
      FServerSocket.Active := False;

      PrepareSourceDatabase;
      ibsqlWork := TIBSQL.Create(nil);
      try
        S := rpGetComputerName;
        ibsqlWork.Database := FDatabase;
        ibsqlWork.Transaction := FTransaction;
        ibsqlWork.SQL.Text := 'SELECT * FROM rp_reportserver WHERE computername = ''' +
          S + '''';
        ibsqlWork.ExecQuery;
        if ibsqlWork.Eof then
        begin
          ibsqlWork.Close;
          ibsqlWork.SQL.Text := 'INSERT INTO rp_reportserver (id, computername, serverport) ' +
           'VALUES(:id, :computername, :serverport)';
          ibsqlWork.ParamByName('id').AsInteger := GetUniqueKey(FDatabase, FTransaction);
          ibsqlWork.ParamByName('computername').AsString := S;
          ibsqlWork.ParamByName('serverport').AsInteger := DefaultTCPPort;
          ibsqlWork.ExecQuery;
          FServerKey := ibsqlWork.ParamByName('id').AsInteger;
          FServerState := rsIdle;
          if not ServerOptions then
            Load;
          FServerState := rsRefresh;
        end else
        begin
          FServerKey := ibsqlWork.FieldByName('id').AsInteger;
          FComputerName := ibsqlWork.FieldByName('computername').AsString;
          FResultPath := ibsqlWork.FieldByName('resultpath').AsString;
          FStartTime := ibsqlWork.FieldByName('starttime').AsTime;
          FEndTime := ibsqlWork.FieldByName('endtime').AsTime;
          FFrqDataRead := ibsqlWork.FieldByName('frqdataread').AsTime;
          FActualReport := ibsqlWork.FieldByName('actualreport').AsInteger;
          FUnactualReport := ibsqlWork.FieldByName('unactualreport').AsInteger;
          FIBParams := ibsqlWork.FieldByName('ibparams').AsString;
          FServerSocket.Port := ibsqlWork.FieldByName('serverport').AsInteger;

          if ibsqlWork.FieldByName('localstorage').AsInteger <> 0 then
            FSourceType := 0
          else
            if CheckGDBFile(FResultPath) then
              FSourceType := 1
            else
              FSourceType := 2;

    // Для КЭШИРОВАНИЯ
    //      Refresh;

          FServerSocket.Active := True;
        end;
        FRefreshTimer.Interval := DateTimeToTimeStamp(FFrqDataRead).Time;
        FRefreshTimer.Enabled := True;
      finally
        ibsqlWork.Free;
        UnPrepareSourceDatabase;
      end;
    finally
      FServerState := rsIdle;
    end;

  {  if FSourceState = 0 then
      PrepareResultDataSet;}

    FRefreshTimer.Enabled := True;
  except
    on E: Exception do
    begin
      SaveLog(E.Message);
      raise;
    end;
  end;
end;

procedure ProcErrorSocket(ErrorCode: Integer);
begin
  MessageBox(0, PChar(Format('Произошла ошибка (%d) при попытке открыть порт.', [ErrorCode]) +
     #13#10 + SysErrorMessage(ErrorCode)), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  Application.Terminate;
end;

procedure TServerReport.DeleteResult;
var
  FDataSet: TDataSet;
begin
  {$IFDEF DEBUG}
  SaveLog(' DeleteResult');
  {$ENDIF}
  if FServerState <> rsIdle then
  begin
    SaveLog(Format('ОШИБКА!!! Произошел збой при попытке обновления данных. Сервер занят "%s".',
     [rpSetServerState(FServerState)]));
    Exit;
  end;

  FServerState := rsDeleteResult;
  try
    PrepareResultDataSet;
    try
      SaveLog('Начат процесс очистки хранилища результатов');
      FDataSet := GetResultDataSet;
      FDataSet.First;
      while not FDataSet.Eof do
        FDataSet.Delete;
    finally
      UnPrepareResultDataSet;
      SaveLog('Процесс очистки хранилища результатов завершен');
    end;
  finally
    FServerState := rsIdle;
  end;
end;

procedure TServerReport.PrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog(' PrepareSourceDatabase');
  {$ENDIF}

  inherited PrepareSourceDatabase;

  if FLocState = 1 then
  begin
    SaveLog('Установлено соединение с рабочей базой');
    SaveLog(FDatabase.DatabaseName);
  end;
end;

procedure TServerReport.UnPrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog(' UnPrepareSourceDatabase');
  {$ENDIF}

  inherited UnPrepareSourceDatabase;

  if FLocState = 0 then
    SaveLog('Завершено соединение с рабочей базой');
end;

procedure TServerReport.CloseConnection;
begin
  {$IFDEF DEBUG}
  SaveLog(' CloseConnection');
  {$ENDIF}
  SaveLog('!!!ATENTION!!!TServerReport.CloseConnection');
  CloseTimerExecute(nil);
end;

procedure Register;
begin
//  RegisterComponents('gsReport', [TClientReport]);
  RegisterComponents('gsReport', [TServerReport]);
end;

// dalex
function TServerReport.GetFunctionResult(const AnFunctionKey: Integer;
 const AnParam: Variant; const AnReportResult: TReportResult;
 const AnIsMakeRebuild: Boolean; out AnBuildDate: TDateTime): Variant;
var
  LocReport: TCustomReport;
  ResultStruct: TrpResultStructure;
  LocParam: Variant;
begin
  {$IFDEF DEBUG}
  SaveLog(' GetFunctionResult');
  {$ENDIF}
  Result := False;

  if FServerState <> rsIdle then
  begin
    SaveLog(Format('ОШИБКА!!! Произошел збой при попытке запроса результата. Сервер занят "%s".',
     [rpSetServerState(FServerState)]));
    Exit;
  end;

  FServerState := rsGetResult;
  try
    ResultStruct := TrpResultStructure.Create;
    try
      ResultStruct.ReportResult.IsStreamData := True;
      // Этот кусок кода позволяет кэшировать данные на сервере }
      LocReport := TCustomReport.Create;
      LocReport.FrqRefresh := 100;
      try
        if FindFunctionNow(AnFunctionKey, LocReport, False) then
        begin
          if AnIsMakeRebuild then
            RefreshReport(LocReport);

          Result := True;
          if not LocReport.IsRebuild and not AnIsMakeRebuild then
            // определить LocReport.MainFunction
            if FindReportResult(LocReport, AnParam, ResultStruct, True) then
              AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
            else
            begin
              ExecuteReportAndSaveResult(LocReport, AnParam);
              Result := FindReportResult(LocReport, AnParam, ResultStruct, True);
              if Result then
                AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
              else
              begin
                SaveLog('ОШИБКА: Результат сохранен но не найден.');
                //{error} raise Exception.Create('');
                Result := FLastErrorMsg;
              end;
            end
          else
          begin
            Result := False;
            LocParam := AnParam;

            if FindReportResult(LocReport, AnParam, ResultStruct, True) then
              if CheckActualReport(LocReport, ResultStruct) and not AnIsMakeRebuild then
              begin
                AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream);
                Result := True;
              end;

            if not Result then
            begin
              ExecuteReportAndSaveResult(LocReport, AnParam);
              Result := FindReportResult(LocReport, AnParam, ResultStruct, True);
              if Result then
                AnReportResult.AssignTempStream(ResultStruct.ReportResult.TempStream)
              else
              begin
                SaveLog('ОШИБКА: Результат сохранен но не найден.');
                Result := FLastErrorMsg;
              end;
            end;

            {Result := ExecuteFunctionWithoutParam(LocReport.MainFunction, AnReportResult, LocParam);
            if not Result then
              SaveLog('ОШИБКА: Функция выполнена с ошибкой. ' + LocParam);}
          end;
          if Result then
            SaveLog('Успешно возвращен результат отчета ' + IntToStr(AnFunctionKey));
        end else
          SaveLog('Не обнаружен отчет ' + IntToStr(AnFunctionKey));
      finally
        LocReport.Free;
      end;
    finally
      AnBuildDate := ResultStruct.CreateDate;
      ResultStruct.Free;
    end;
  finally
    FServerState := rsIdle;
  end;
end;
// !dalex



(*initialization
  ClientReport := nil;
finalization
  ClientReport := nil;*)

end.



