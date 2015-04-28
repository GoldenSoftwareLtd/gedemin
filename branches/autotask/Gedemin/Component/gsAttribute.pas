  // �������������� ���������� ���������
  TDimensionList = class(TStringList)
  private
    FID: Integer;

    function GetID: Integer;
  public
    procedure Assign(ADimensionAttr: TDimensionAttr);
    procedure Add(AnID: Integer; AName: String);
    procedure Clear; override;

    property ID[Index: Integer]: Integer read GetID;
  end;

  // ���� ���������
  TAttrType = (
    atNone,     // ��� ����
    atInteger,  // �������������
    atDouble,   // �������
    atString,   // ���������
    atBoolean,  // ���������
    atDate,     // ����
    atDateTime, // ���� � �����
    atText,     // �����
    atImage,    // ��������
    atElemenent,   // ������� ���������
    atSet        // ���������
  );

  // ������� �����������
  TAttribute = class
  private
    Fid: Integer;               // ����
    Fhotkey: Integer;           // ������� �������
    Fnumber: Integer;           // �������� ��������
    FName: String;              // ����� ��������
    Fibname: String;            // ������������ ������� ��� ����
    Fdefaultvalue: String;      // �������� �� ���������
    Fcondition: String;         // �������
    FAttrType: TAttrType;       // ��� ��������
    Fmandatory: Boolean;        // ����������� �� ���� ������� �������� �� ������� ��������
    FisLong: Boolean;           // ������� ����������

  public
    procedure Assign(const Attribute: TAttribute);
    constructor Create(
      const Aid, Ahotkey, ANumber: Integer;
      const AName, Aibname, ADefaultValue, ACondition: String
      const AAttrType: TAttrType;
      const AMandatory, AisLong: Boolean);

    property id: Integer read FID;
      // ����
    property hotkey: Integer read Fhotkey write Fhotkey;
      // ������� �������
    property number: Integer read Fnumber write Fnumber;
      // �������� ��������
    property Name: String read FName write FName;
      // ����� ��������
    property ibname: String read FID;
      // ������������ ������� ��� ����
    property Defaultvalue: String read Fdefaultvalue write Fdefaultvalue;
      // �������� �� ���������
    property Condition: String read Fcondition write Fcondition;
      // �������
    property AttrType: TAttrType read FAttrType;
      // ��� ��������
    property Mandatory: Boolean read FMandatory write FMandatory;
      // ����������� �� ���� ������� �������� �� ������� ��������
    property isLong: Boolean read FisLong write FisLong;
      // ������� ����������
  end;

  // ����������
  TReference = class(TStringList)
  private
    Fid: Integer;
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
    constructor Create(const AnID: Integer;
      const ATableName, AKeyFieldName, AListFieldName: String;
      const ACanBeAttr, AllowAttr, AnIsTree: Boolean); virtual;
    destructor Destroy; override;
    procedure Assign(AReference: TReference);
    procedure Clear; override;

    // ����������
    procedure Add(
      const Aid, Ahotkey, ANumber: Integer;
      const AName, Aibname, ADefaultValue, ACondition: String
      const AAttrType: TAttrType;
      const AMandatory, AisLong: Boolean); overload; override;
    procedure Add(Attribute: TAttribute); overload; override;

    // ��������
    procedure Delete(Index: Integer); override;

    property id: Integer read FID write FID;
    // ���� �����������
    property Name: String read FName write FName;
    // ������������
    property TableName: String read FTableName write FTableName;
    // ����� � IB
    property KeyFieldName: String read FKeyFieldName write FKeyFieldName;
    // ���� �����������
    property ListFieldName: String read FListFieldName write FListFieldName;
    // ��������� ���� �����������
    property CanBeAttr: Boolean read FCanBeAttr write FCanBeAttr;
    // ����� ���� ���������
    property AllowAttr: Boolean read FAllowAttr write FAllowAttr;
    // ����� �������� �������
    property IsTree: Boolean read FIsTree write FIsTree;
    // �������� ����������� ����������
    property Attribute[Index: Integer]: TAttribute read GetAttribute;
    property DimensionList: TDimensionList read FDimensionList
      write SetDimensionList;
  end;

  // ������ ������������
  TReferenceList = class(TList)
  private
    function GetReference(Index: Integer): TReference;
  public

    destructor Destroy; override;
    procedure Assign(const Source: TReferenceList);
    procedure Clear; override;
    procedure Delete(const Index: Integer); override;

    function IndexOf(const ID: Integer): Integer; overload;
    function IndexOf(const AName: String): Integer; overload;

    property Reference[Index: Integer]: TReference read GetReference;

    procedure AddVariables(const ID: Integer; VariableList: TVariableList;
      IBQuery: TIBQuery); overload;
    // ��������� � ������ ���������� ������ ���������
    procedure SetAttributeName(const ID: Integer; IBQuery: TIBQuery);
    function Add(const AReference: TReference): Integer; override; overload;
    function Add(const AnID: Integer;
      const ATableName, AKeyFieldName, AListFieldName: String;
      const ACanBeAttr, AllowAttr, AnIsTree: Boolean); override; overload;
  end;

  // ��������� �������. ������������ ���������, ������� ��� ������� �������
  // ��������� ��� ���������� �� ��������� �� ��������� ������������
  // � ���� ��� ���������� ������ �����������.
  // ������ ��������� ���������� � ������� �����. ���� ���������� ���������
  // � ����, �� ��� ����� ���������� ���������� ���������� Attr. � ��� �����,
  // ��� ���������� �������� ������ ������������ ���� ������

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
    // �������� ��������� �������. ���������� ��� ������ ������� ��� ��������� �
    // ReferenceList, TrAnalyzeList ��� CardAnalyzeList
    property ReferenceList: TReferenceList read FReferenceList write SetReferenceList;
    property TrAnalyze: TAnalyzeList read FTrAnalyze write SetTrAnalyze;
    property CardAnalyze: TAnalyzeList read FCardAnalyzeList write SetCardAnalyze;
    // ���������
    property IsLoad: Boolean read FLoad;
    // ��� �� ��������
  published
    // ������ ������ �����������, ��������� ������� ����������
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

  // ��������� ��� ����� ������� � ����������. ������ ��������� ��������� ���
  // ���� (������ �����������) ������ �� ���������� boAttr
  TgsInputAttribute = class(TScrollBox)
  private
    FDataSource: TDataSource;
    FControlLeft: Integer;
    FBlobHeigth: Integer;
    FControlWidth: Integer;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    procedure SetDataSource(ADataSource: TDataSource);
    // �������� �������� ��� ��������-��������
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
    // ����������� ������� ��� ������� ����������� ��������
    property DataSource: TDataSource read FDataSource write SetDataSource;
    // ������ � ���� ��� Controla
    property ControlLeft: Integer read FControlLeft write FControlLeft;
    // ����� ��������
    property ControlWidth: Integer read FControlWidth write FControlWidth;
    // ������ �������� �������� ��� ������
    property BlobHeigth: Integer read FBlobHeigth write FBlobHeigth;
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;



