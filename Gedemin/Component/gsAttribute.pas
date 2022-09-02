// ShlTanya, 11.02.2019

  // Kоличечтвенные показатели аналитики
  TDimensionList = class(TStringList)
  private
    FID: TID;

    function GetID: TID;
  public
    procedure Assign(ADimensionAttr: TDimensionAttr);
    procedure Add(AnID: Integer; AName: String);
    procedure Clear; override;

    property ID[Index: Integer]: Integer read GetID;
  end;

  // Типы атрибутов
  TAttrType = (
    atNone,     // Без типа
    atInteger,  // Целочисленный
    atDouble,   // Дробный
    atString,   // Строковый
    atBoolean,  // Булевский
    atDate,     // Дата
    atDateTime, // Дата и время
    atText,     // текст
    atImage,    // картинки
    atElemenent,   // Елемент множества
    atSet        // Множество
  );

  // Атрибут справочника
  TAttribute = class
  private
    Fid: TID;               // Ключ
    Fhotkey: Integer;           // Горячая клавиша
    Fnumber: Integer;           // Важность атрибута
    FName: String;              // Метка атрибута
    Fibname: String;            // Наименование таблицы или поля
    Fdefaultvalue: String;      // Значение по умолчанию
    Fcondition: String;         // Условие
    FAttrType: TAttrType;       // Тип атрибута
    Fmandatory: Boolean;        // Обязательно ли надо вносить значение по данному атрибуту
    FisLong: Boolean;           // Большой справочник

  public
    procedure Assign(const Attribute: TAttribute);
    constructor Create(
      const Aid, Ahotkey, ANumber: Integer;
      const AName, Aibname, ADefaultValue, ACondition: String
      const AAttrType: TAttrType;
      const AMandatory, AisLong: Boolean);

    property id: TID read FID;
      // Ключ
    property hotkey: Integer read Fhotkey write Fhotkey;
      // Горячая клавиша
    property number: Integer read Fnumber write Fnumber;
      // Важность атрибута
    property Name: String read FName write FName;
      // Метка атрибута
    property ibname: String read FID;
      // Наименование таблицы или поля
    property Defaultvalue: String read Fdefaultvalue write Fdefaultvalue;
      // Значение по умолчанию
    property Condition: String read Fcondition write Fcondition;
      // Условие
    property AttrType: TAttrType read FAttrType;
      // Тип атрибута
    property Mandatory: Boolean read FMandatory write FMandatory;
      // Обязательно ли надо вносить значение по данному атрибуту
    property isLong: Boolean read FisLong write FisLong;
      // Большой справочник
  end;

  // Справочник
  TReference = class(TStringList)
  private
    Fid: TID;
    FName: String;
    FTableName: String;
    FMayAttr: Boolean;
    FAddAttr: Boolean;
    FIsTree: Boolean;
    FKeyFieldName: String;
    FListFieldName: String;

    procedure SetDimensionList(Value: TDimensionList);
    function GetAttribute: TAttribute;
  public
    constructor Create(const AnID: TID;
      const ATableName, AKeyFieldName, AListFieldName: String;
      const ACanBeAttr, AllowAttr, AnIsTree: Boolean); virtual;
    destructor Destroy; override;
    procedure Assign(AReference: TReference);
    procedure Clear; override;

    // Добавление
    procedure Add(
      const Aid, Ahotkey, ANumber: Integer;
      const AName, Aibname, ADefaultValue, ACondition: String
      const AAttrType: TAttrType;
      const AMandatory, AisLong: Boolean); overload; override;
    procedure Add(Attribute: TAttribute); overload; override;

    // Удаление
    procedure Delete(Index: Integer); override;

    property id: TID read FID write FID;
    // Ключ справочника
    property Name: String read FName write FName;
    // Наименование
    property TableName: String read FTableName write FTableName;
    // Табли в IB
    property KeyFieldName: String read FKeyFieldName write FKeyFieldName;
    // Ключ справочника
    property ListFieldName: String read FListFieldName write FListFieldName;
    // Выводимое поле справочника
    property CanBeAttr: Boolean read FCanBeAttr write FCanBeAttr;
    // Может быть атрибутом
    property AllowAttr: Boolean read FAllowAttr write FAllowAttr;
    // Можно добавить атрибут
    property IsTree: Boolean read FIsTree write FIsTree;
    // Является древовидной структурой
    property Attribute[Index: Integer]: TAttribute read GetAttribute;
    property DimensionList: TDimensionList read FDimensionList
      write SetDimensionList;
  end;

  // Список справочников
  TReferenceList = class(TList)
  private
    function GetReference(Index: Integer): TReference;
  public

    destructor Destroy; override;
    procedure Assign(const Source: TReferenceList);
    procedure Clear; override;
    procedure Delete(const Index: Integer); override;

    function IndexOf(const ID: TID): Integer; overload;
    function IndexOf(const AName: String): Integer; overload;

    property Reference[Index: Integer]: TReference read GetReference;

    procedure AddVariables(const ID: TID; VariableList: TVariableList;
      IBQuery: TIBQuery); overload;
    // Добаление в список переменных списка атрибутов
    procedure SetAttributeName(const ID: TID; IBQuery: TIBQuery);
    function Add(const AReference: TReference): Integer; override; overload;
    function Add(const AnID: TID;
      const ATableName, AKeyFieldName, AListFieldName: String;
      const ACanBeAttr, AllowAttr, AnIsTree: Boolean); override; overload;
  end;

  // Компонент атрибут. Невизуальный компонент, который при запуске системы
  // считывает всю информацию по атрибутам по выбранным справочникам
  // и дает эту информацию другим компонентам.
  // Данный компонент помещается в главную форму. Елси необходимо обращение
  // к нему, то для этого существуют глобальная переменная Attr. В той форме,
  // где необходимо получить данные подключается этот модуль

  TgsAttribute = class(TComponent)
  private
    FReferenceList: TReferenceList;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FTrAnalyze: TAnalyzeList;
    FCardAnalyze: TAnalyzeList;
    FIsLoad: Boolean;

    procedure SetReferenceList(Value: TReferenceList);
    procedure SetTrAnalyze(Value: TAnalyzeList);
    procedure SetCardAnalyze(Value: TAnalyzeList);

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Load;
    // Загрузка структуры атрибут. Вызывается при первом запуске или обращении к
    // ReferenceList, TrAnalyzeList или CardAnalyzeList
    property ReferenceList: TReferenceList read FReferenceList write SetReferenceList;
    property TrAnalyze: TAnalyzeList read FTrAnalyze write SetTrAnalyze;
    property CardAnalyze: TAnalyzeList read FCardAnalyzeList write SetCardAnalyze;
    // Аналитика
    property IsLoad: Boolean read FLoad;
    // Был ли загружен
  published
    // Список ключей справоников, доступных данному приложению
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

  // Компонент для ввода атрибут в справочник. Данный компонент считывает для
  // себя (своего справочника) данные из компонента boAttr
  TgsInputAttribute = class(TScrollBox)
  private
    FDataSource: TDataSource;
    FControlLeft: Integer;
    FBlobHeigth: Integer;
    FControlWidth: Integer;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    procedure SetDataSource(ADataSource: TDataSource);
    // Загрузка картинки для атрибута-картинки
    procedure ImageDblClick(Sender: TObject);
    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);

  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    // Подключение таблицы для которой заполняются атрибуты
    property DataSource: TDataSource read FDataSource write SetDataSource;
    // Отступ с лева для Controla
    property ControlLeft: Integer read FControlLeft write FControlLeft;
    // Длина контрола
    property ControlWidth: Integer read FControlWidth write FControlWidth;
    // Высота контрола картинки или текста
    property BlobHeigth: Integer read FBlobHeigth write FBlobHeigth;
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;



