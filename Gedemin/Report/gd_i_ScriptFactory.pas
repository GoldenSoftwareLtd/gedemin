{++

  Copyright (c) 2002-2016 by Golden Software of Belarus, Ltd

  Module

    gd_i_ScriptFactory.pas

  Abstract

    Gedemin project.
    IgdScriptFactory

  Author

    Andrey Shadevsky

  Revisions history

    1.00    21.02.02    JKL        Initial version.
    1.01    13.03.03    DAlex      Final version.

--}

unit gd_i_ScriptFactory;

interface

uses
  Classes,
  rp_BaseReport_unit,
  {$IFDEF GEDEMIN}
  rp_ReportScriptControl,
  {$ENDIF} IBDataBase,
  contnrs, gd_ScrException, sysutils;

type
  TPrimaryKey = Integer;

type
  TProcProcess = procedure(const AnFunctionKey: TPrimaryKey; const AnParams, AnResult: Variant);

  // после обработки ошибки скрипт-функции,
  // если скрипт вызывался наредактирование, то возврат ошибки EChangedScript,
  // иначе EErrorScript
  EChangedScript = class(EAbort)
  end;
  EErrorScript = class(EAbort)
  end;

  TgdErrorItem = class(TObject)
  private
    FPos: Integer;
    FLine: Integer;
    FMsg: String;
    FSFID: Integer;
    FText: string;
    procedure SetLine(const Value: Integer);
    procedure SetMsg(const Value: String);
    procedure SetPos(const Value: Integer);
    procedure SetSFID(const Value: Integer);
    procedure SetText(const Value: string);
  public
    // сообщение об ошибке
    property Msg: String read FMsg write SetMsg;
    // строка с ошибкой в с-ф
    property Line: Integer read FLine write SetLine;
    // позиция в сктроке
    property Pos: Integer read FPos write SetPos;
    // ID скрипт-функции
    property SFID: Integer read FSFID write SetSFID;
    //Текст ошибки
    property Text: string read FText write SetText;
  end;

  // Используется для добавления ошибок компиляции
  TgdCompileItem = class(TgdErrorItem)
  private
    FReferenceToSF: Integer;
    FAutoClear: Boolean;
    procedure SetReferenceToSF(const Value: Integer);
    procedure SetAutoClear(const Value: Boolean);
  public
    // ИД СФ, на кот. ссылка в ошибке или предупреждении
    property ReferenceToSF: Integer read FReferenceToSF write SetReferenceToSF;
    // Удалять
    property AutoClear: Boolean read FAutoClear write SetAutoClear default False;
  end;

  TgdErrorlList = class(TObject)
  private
    FErrorList: TObjectList;
    function GetItem(Index: Integer): TgdErrorItem;
    function GetCount: Integer;
  public
    constructor Create;
    destructor  Destroy; override;

    function  Add(const ErrorItem: TgdErrorItem): Integer; overload;
    function  Add(const Msg: String; const Line, Pos, SFID: Integer): Integer; overload;
    procedure Clear;

    property  Count: Integer read GetCount;
    property  Item[Index: Integer]: TgdErrorItem read GetItem; default;
  end;

type
  // тип для управления выводом окна
  // при возникновении ошибок
  TExceptionFlags = record
    Stop: Boolean;
    StopOnInside: Boolean;
    SaveErrorLog: Boolean;
    FileName: String;
    LimitLines: Boolean;
    LinesCount: Integer;
  end;

type
  // Интерфейс глобального объекта для выполнения скрипт-функций.
  // Все выполнения скрипт-функций выполняются через данный
  // компонент, кроме отчетов (большой объем кода).
  IgdScriptFactory = interface
  ['{DB54476D-E9D5-427C-97CD-74BA6876D3B9}']
    // Возвращает дефовский объект самое себя.
    function Get_Self: TObject;

    // Возвращают значения свойств
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;

    // !!! Перед использаванием надо быть уверенным, что добавляем скрипт
    //     в данный момент не выполняется
    // Добавляет текст скрипт-функции вместе с инклюд-функциями
    // ModuleKey - ключ модуля
    procedure AddScript(const AnFunction: TrpCustomFunction;
                        const ModuleKey: Integer = 0; const TestInLoaded: Boolean = True);

    // Запрос параметров
    function InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean; overload;
    function InputParams
       (// Ключ функции
        const AnFunctionKey : TPrimaryKey;
        out AnParamResult : Variant) : Boolean; overload;

    // Вызывается после InputParams только там, где возможно передача OwnerForm
    // Если присвоено удачно или нет OwnerForm, то возвр. True
    function GiveOwnerForm(const AnFunction: TrpCustomFunction;
       var AnParamResult: Variant; const OwnerFormName: String): Boolean;

    // используется, где необходимо использовать свой обработчик ошибок
    // для текущей скрипт-функции
    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
     var AParamAndResult: Variant; const AErrorEvent: TNotifyEvent); overload;

    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
     var AParamAndResult: Variant); overload;
    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
     AParams: Variant; out AnResult: Variant); overload;
    procedure ExecuteFunction(const AFunctionKey: Integer;
     AParams: Variant; out AnResult: Variant); overload;

    // Метод служит для выполнения скрипт-функции. При этом входные параметры и результат выполнения передаются разными переменными.
    procedure ExecuteFunctionEx
       (// Передается объект хранящий данные функции подлещащей выполнению.
        const AnFunction : TrpCustomFunction;
        // Входные параметры скрипт-функции.
        AnParams : Variant;
        // Результат выполнения функции
        out AnResult : Variant;
        // обработчик ошибки, если в нем нет необходимости, то передается nil
        // он вызывается для текущей скрип-функции, если из нее вызывается через
        // интерфейс новая скрипт-функция, то для нее используется встроенный обработчик
        const AnErrorEvent: TNotifyEvent;
        // Флаг указывает на возможность кэширования результата выполнения скрипт-функции.
        AnUseCache : Boolean = False); overload;

    // Метод имеет аналогичное предназначение, только входным параметром является ключ скрипт-функции.
    procedure ExecuteFunctionEx
       (const AnFunctionKey : TPrimaryKey;
        AnParams : Variant;
        out AnResult : Variant;
        const AnErrorEvent: TNotifyEvent;
        AnUseCache : Boolean = False); overload;



    // Метод выполняет скрипт функции отчета.
    // Входными параметрами мктода являются
    // Ключ отчета, наименование сервера, возможность использования сервера,
    // адрес процедуры обработки результата
    // В случае существования входных параметров для макроса
    // они запрашиваются автоматически
    procedure ExecuteReport
       (AnReportKey : TPrimaryKey;
        AnServerName : String;
        AnUseServer : Boolean;
        AnProcProcess : TProcProcess);

    // Функция выполняет макрос. Передаваемые параметры:
    // макрос, наименование сервера, возможность его использования.
    // В случае существования входных параметров для макроса
    // они запрашиваются автоматически
    procedure ExecuteMacros
       (OwnerForm: OleVariant; AnMacros : TObject);

    // Выполнение макроса локально по имени с передачей параметров
    // и возвратом результата
    function  ExecuteMacro(const AName, AObjectName: String;
      const AParams: OleVariant): Variant;
    // Выполнение скрипт-функции по ключу
    function  ExecuteScript(const AFunctionKey: Integer;
      const AParams: OleVariant): Variant;
    function  ExecuteObjectScript(const AFunctionName,
      AObjectName: String;  const AParams: OleVariant): Variant;

    // Выполняет Statement в модуле выполнения функции с FunctionKey
    procedure ExecuteStatement(const FunctionKey: Integer; const Statement: WideString);

    // инициализация VB классов
    function  GetCreateVBClasses: TOnCreateObject;

    // Устанавливают значеиня свойств
    procedure SetDatabase(Sourse: TIBDatabase);
    procedure SetTransaction(Sourse: TIBTransaction);

    property DataBase: TIBDatabase read GetDataBase write SetDataBase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

    procedure Reset;
    procedure ResetVBClasses(const ModuleCode: Integer);
    //Вычисление выражения
//    function GetScriptEval(const AnScriptText, AnLanguage: String): Variant;
    function Eval(const Expression: String): Variant;
    //Возвращает строку в которой произошла ошибка
//    function GetErrorLine: Integer;

    function GetScrException: EScrException;
    property scrException: EScrException read GetScrException;

//    function GetShowErrorDialog: Boolean;
//    procedure SetShowErrorDialog(const Value: Boolean);

    //Вызывается после изменения скрипт-функции
    procedure ReloadFunction(FunctionKey: Integer);

//    property ShowErrorDialog: Boolean read GetShowErrorDialog write SetShowErrorDialog;

//    function VBScriptControl: TReportScript;
    function GetErrorList: TgdErrorlList;

    {$IFDEF GEDEMIN}
    function  VBScriptControl: TReportScript;
    {$ENDIF}

    // Указывает, вызывать окно обработки ошибок при исключениях в Делфи или нет
    function  GetExceptionFlags: TExceptionFlags;
    procedure SetExceptionFlags(Value: TExceptionFlags);
    property  ExceptionFlags: TExceptionFlags read GetExceptionFlags
      write SetExceptionFlags;
  end;

var
  ScriptFactory: IgdScriptFactory;

implementation

{ TgdErrorlList }

function TgdErrorlList.Add(const ErrorItem: TgdErrorItem): Integer;
begin
  Result := FErrorList.Add(ErrorItem);
end;

function TgdErrorlList.Add(const Msg: String; const Line, Pos,
  SFID: Integer): Integer;
var
  LErrorItem: TgdErrorItem;
begin
  LErrorItem := TgdErrorItem.Create;
  LErrorItem.Msg := Msg;
  LErrorItem.Line := Line;
  LErrorItem.Pos := Pos;
  LErrorItem.SFID := SFID;
  Result := Add(LErrorItem);
end;

procedure TgdErrorlList.Clear;
begin
  FErrorList.Clear;
end;

constructor TgdErrorlList.Create;
begin
  inherited;

  FErrorList := TObjectList.Create;
  FErrorList.OwnsObjects := True;
end;

destructor TgdErrorlList.Destroy;
begin
  FErrorList.Free;
  inherited;
end;

function TgdErrorlList.GetCount: Integer;
begin
  Result := FErrorList.Count;
end;

function TgdErrorlList.GetItem(Index: Integer): TgdErrorItem;
begin
  Result := TgdErrorItem(FErrorList[Index]);
end;

{ TgdErrorItem }

procedure TgdErrorItem.SetLine(const Value: Integer);
begin
  FLine := Value;
end;

procedure TgdErrorItem.SetMsg(const Value: String);
begin
  FMsg := Value;
end;

procedure TgdErrorItem.SetPos(const Value: Integer);
begin
  FPos := Value;
end;

procedure TgdErrorItem.SetSFID(const Value: Integer);
begin
  FSFID := Value;
end;

procedure TgdErrorItem.SetText(const Value: string);
begin
  FText := Value;
end;

{ TgdCompileItem }

procedure TgdCompileItem.SetAutoClear(const Value: Boolean);
begin
  FAutoClear := Value;
end;

procedure TgdCompileItem.SetReferenceToSF(const Value: Integer);
begin
  FReferenceToSF := Value;
end;

initialization
  ScriptFactory := nil;

finalization
//  ScriptFactory := nil;

end.

