
{++

  Copyright (c) 2000-2015 by Golden Software of Belarus, Ltd

  Module

    flt_sqlfilter_condition_type.pas

  Abstract

    Gedemin project. Basic classes of TgsQueryFilter.
    Uses in flt_sqlFilter.pas.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    30.09.00    JKL        Initial version.
    2.00    09.11.00    JKL        Rebuild structure
    2.01    12.12.00    JKL        Add ActionList for Menu
    3.00    07.05.01    JKL        Final version. Search gs.
    3.01    29.10.01    JKL        Entered conditions and script conditions is added.
    3.02    02.03.02    JKL        Distinct proerty was added.
    3.03    09.09.02    JKL        Simple tables processing ability was added

--}

unit flt_sqlfilter_condition_type;

interface

uses
  Classes, StdCtrls, SysUtils;

const
  // ������ ��������������
  cQueryAlias = '/* ����� ������� ��������� ����������� ���������� */';
  cFilterVersion = '1V\';

type
  TFilterFieldType = Integer;
  TFilterConditionType = Integer;

// ��� ����, ������
type
  TRelationName = String[31];
  TLabelStream = array[0..3] of char;
  TArrByte = array of Byte;

const
  // ��������� ��� ������� ������� ����������
  GD_FC_EQUAL_TO	= 10;	// �����
  GD_FC_GREATER_THAN	= 20;	// ������
  GD_FC_GREATER_OR_EQUAL_TO     = 30;// ������ ��� �����
  GD_FC_LESS_THAN	= 40;	// ������
  GD_FC_LESS_OR_EQUAL_TO= 50;	// ������ ��� �����
  GD_FC_BETWEEN		= 60;	// ����� ������� �������
  GD_FC_BETWEEN_LIMIT	= 70;	// ����� �������� �������
  GD_FC_OUT             = 74;   // ��� ������� �������
  GD_FC_OUT_LIMIT       = 76;   // ��� �������� �������
  GD_FC_NOT_EQUAL_TO	= 80;	// �� �����

  GD_FC_BEGINS_WITH	= 90;	// ����������
  GD_FC_CONTAINS	= 100;	// ��������
  GD_FC_DOESNT_CONTAIN	= 110;	// �� ��������
  GD_FC_ENDS_WITH	= 120;	// �������������

  GD_FC_TODAY		= 130;	// �� �������
  GD_FC_SELDAY		= 135;	// ��������� ����
  GD_FC_LAST_N_DAYS	= 140;	// �� ��������� � ����
//  GD_FC_BEFORE	= 150;	// �����
//  GD_FC_AFTER		= 160;	// �����

  GD_FC_INCLUDES	= 170;	// ��������
  GD_FC_CUSTOM_FILTER	= 180;	// ����������
  GD_FC_ACTUATES	= 190;	// ���� ��
  GD_FC_NOT_ACTUATES	= 192;	// �� ��������
  GD_FC_ACTUATES_TREE	= 195;	// ���� ����� ��
  GD_FC_NOT_ACTUATES_TREE	= 197;	// �� �������� �����

  GD_FC_TRUE		= 200;	// ������
  GD_FC_FALSE		= 210;	// ����

  GD_FC_EMPTY		= 220;	// �����
  GD_FC_NOT_EMPTY	= 230;	// �� �����

  GD_FC_QUERY_WHERE   	= 240;	// ������� ��� �������
  GD_FC_QUERY_ALL   	= 245;	// ������� ��� �������

  GD_FC_COMPLEXFIELD    = 250;  // ���������� �� �������������� �����

  GD_FC_SCRIPT          = 260;  // �������� ����������� �������� �������
  GD_FC_ENTER_PARAM     = 270;  // �������� ����� ���������� � ���������� ����


  // ��������� ��� ����������� ���� ������
  GD_DT_UNKNOWN		=  -1;  // �� ���������
  GD_DT_DIGITAL		= 500;	// ��������
  GD_DT_CHAR		= 510;	// ���������
  GD_DT_DATE		= 520;	// ��� ����
  GD_DT_TIMESTAMP       = 525;  // ��� ������� � ����
  GD_DT_TIME		= 530;	// ��� �������
  GD_DT_ATTR_SET	= 540;	// ��������� ��������� ������������
  GD_DT_ATTR_SET_ELEMENT= 550;	// ������� ��������� ��������� ������������
  GD_DT_REF_SET		= 560;	// ���������
  GD_DT_REF_SET_ELEMENT	= 570;	// ������� ���������
  GD_DT_CHILD_SET	= 575;	// ���� �� ������
  GD_DT_UNKNOWN_SET	= 580;	// ��������� � ����������� �����
  GD_DT_BOOLEAN		= 590;	// ���� ���� GD_DT_DIGITAL � ������� DBOOLEAN;
  GD_DT_BLOB_TEXT	= 600;	// ���� ����.
  GD_DT_BLOB    	= 700;	// ���� ����.
  GD_DT_FORMULA		= 800;	// ������� ������������
  GD_DT_ENUMERATION     = 900;  // ������������

  GD_LBL_BGN_FILTERDATA         = '^BFD';
  GD_LBL_END_FILTERDATA         = '^EFD';
  GD_LBL_BGN_CONDITIONLIST      = '^BCL';
  GD_LBL_END_CONDITIONLIST      = '^ECL';
  GD_LBL_CONDITIONLISTITEM      = '^CLI';
  GD_LBL_MERGECONDITION          = '^MCN';
  GD_LBL_BGN_CONDITION          = '^BCO';
  GD_LBL_CONDTYPE               = '^CTP';
  GD_LBL_VALUE1                 = '^VL1';
  GD_LBL_VALUE2                 = '^VL2';
  GD_LBL_BGN_SUBFILTER          = '^BSF';
  GD_LBL_END_SUBFILTER          = '^ESF';
  GD_LBL_BGN_VALUELIST          = '^BVL';
  GD_LBL_END_VALUELIST          = '^EVL';
  GD_LBL_VALUELISTITEM          = '^VLI';
  GD_LBL_END_CONDITION          = '^ECO';
  GD_LBL_BGN_FIELDDATA          = '^BFL';
  GD_LBL_END_FIELDDATA          = '^EFL';
  GD_LBL_TABLENAME              = '^TNM';
  GD_LBL_TABLEALIAS             = '^TAL';
  GD_LBL_PRIMARYNAME            = '^PRN';
  GD_LBL_LOCALTABLE             = '^LTB';
  GD_LBL_FIELDNAME              = '^FNM';
  GD_LBL_LOCALFIELD             = '^LFL';
  GD_LBL_FIELDTYPE              = '^FTP';
  GD_LBL_DISPLAYNAME            = '^DNM';
  GD_LBL_LINKTABLE              = '^LNT';
  GD_LBL_LINKSOURCEFIELD        = '^LSF';
  GD_LBL_LINKTARGETFIELD        = '^LTF';
  GD_LBL_LINKTARGETFIELDTYPE    = '^LTT';
  GD_LBL_REFTABLE               = '^RTB';
  GD_LBL_REFFIELD               = '^RFL';
  GD_LBL_ISREFERENCE            = '^ISR';
  GD_LBL_ISTREE                 = '^IST';
  GD_LBL_ATTRKEY                = '^ATK';
  GD_LBL_ATTRREFKEY             = '^ARK';
  GD_LBL_BGN_ORDERLIST          = '^BOL';
  GD_LBL_END_ORDERLIST          = '^EOL';
  GD_LBL_ORDERLISTITEM          = '^OLI';
  GD_LBL_ISINDEXFIELD           = '^IIF';
  GD_LBL_BGN_ORDERDATA          = '^BOD';
  GD_LBL_END_ORDERDATA          = '^EOD';

  GD_LBL_ERROR_MESSAGE          = '������� ������ ������ �������';

  GD_FC2_ACTUATES_ALIAS         = 'IN';
  GD_FC2_NOT_ACTUATES_ALIAS     = 'NOT IN';
  GD_FC2_INCLUDE_ALIAS          = 'INCLUDE';

  fltTreeLeftBorder = 'LB';
  fltTreeRightBorder = 'RB';

  IntSize = SizeOf(Integer);
  CharSize = SizeOf(Char);
  LblSize = SizeOf(TLabelStream);

  {$IFNDEF GEDEMIN}
  LanguageCount = 2;
  LanguageList: array[0..LanguageCount - 1] of String[20] = ('VBScript', 'JScript');
  {$ELSE}
  LanguageCount = 1;
  LanguageList: array[0..LanguageCount - 1] of String = ('VBScript');
  {$ENDIF}

type
  TFilterOrderBy = class(TObject)
  public
    TableName: TRelationName;                   // ������������ �������
    TableAlias: TRelationName;                  // ������������ ��������
    FieldName: TRelationName;                   // ������������ ����
    LocalField: TRelationName;                  // �������������� ������������ ����
    IsAscending: Boolean;                       // ������� ����������

    procedure Assign(Source: TFilterOrderBy);   // �����������
    procedure Clear;                            // �������

    procedure ReadFromStream(S: TStream);       // ������ �� ������
    procedure WriteToStream(S: TStream);        // ������ � �����
  end;

  // ������ � ����������
  TFilterOrderByList = class(TList)
  private
    FOnlyIndexField: Boolean;                   // ������ ��������������� ����

    function GetOrderText: String;              // ��������� ������ ����������
    function GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
  public
    destructor Destroy; override;

    property OrderText: String read GetOrderText;       // ����� ����������

    procedure Clear; override;                          // ������� ������
    procedure Assign(Source: TFilterOrderByList);       // ����������

    property OnlyIndexField: Boolean read FOnlyIndexField write FOnlyIndexField;
    property OrdersBy[const AnIndex: Integer]: TFilterOrderBy read GetOrderBy;

    function AddOrderBy(const AnOrderByData: TFilterOrderBy): Integer; overload;
    function AddOrderBy(const AnTableName, AnTableAlias, AnLocalTable, AnFieldName,
     AnLocalField: TRelationName; const AnAscending: Boolean): Integer; overload;

    procedure DeleteOrderBy(const AnIndex: Integer);

    procedure ReadFromStream(S: TStream);       // ������ �� ������
    procedure WriteToStream(S: TStream);        // ������ � �����
  end;

type
  TfltFieldData = class(TObject)
  public
    TableName: TRelationName;		// ������������ �������
    TableAlias: TRelationName;  	// ����� ������� � �������
    PrimaryName: TRelationName;         // ������������ ������� ��� � �������
    LocalTable: TRelationName;	        // "��������������" ��� �������
    FieldName: TRelationName;		// ������������ ����
    LocalField: TRelationName;  	// ������������ �� �����
    FieldType: TFilterFieldType;	// ��� ����
    DisplayName: TRelationName;         // ������������ ���� �� �������� ����������� ����� � ����������� �������
    LinkTable: TRelationName;		// ������������ ��������� �������
    LinkSourceField: TRelationName;	// ������������ ���� ������������ �� TableName
    LinkTargetField: TRelationName;	// ������������ ���� ������������� ������� ��� � ��������� �������
    LinkTargetFieldType: Integer;	// ��� ���� ���������� ����
    RefTable: TRelationName;		// ������� ��� ������ ��������(��)
    RefField: TRelationName;		// ���� ��� ������ ��������(��)
    IsReference: Boolean;		// ������� ��������� �������� ������������
    IsTree: Boolean;                    // ������� ��������� �������� ������������ �������
    AttrKey: Integer;			// ���� ��������
    AttrRefKey: Integer;		// ���� ������������ ��������

    constructor Create;

    procedure Clear;                    // ��������
    procedure Assign(Source: TfltFieldData);    // ���������

    procedure ReadFromStream(S: TStream);       // ������ �� ������
    procedure WriteToStream(S: TStream);        // ������ � �����
  end;

type
  TFilterConditionList = class;

  // ������ �������
  TFilterCondition = class(TObject)
  protected
    FTempVariant: Variant;
  public
    FieldData: TfltFieldData;           // ������ ����
    ConditionType: Integer;		// ��� �������
    Value1: String;		        // �������� ������� �������
    Value2: String[40];		        // �������� ������� �������
    SubFilter: TFilterConditionList;	// ������ ������� ��� ������� �� ������ �������.
    ValueList: TStrings;		// ������ �������� ��� ��������� � �������� ���������.

    constructor Create; overload;
    constructor Create(const AnFieldData: TfltFieldData; const AnConditionType: Integer;
     const AnValue1, AnValue2: String; const AnSubFilter: TFilterConditionList;
     const AnValueList: TStringList); overload;

    destructor Destroy; override;

    procedure Assign(Source: TFilterCondition); // ���������
    procedure Clear;                            // ��������

    procedure ReadFromStream(S: TStream);       // ������ �� ������
    procedure WriteToStream(S: TStream);        // ������ � �����
  end;

  // ������ �������
  TFilterConditionList = class(TList)
  private
    FIsAndCondition: Boolean;                   // ������� �����������
    FIsDistinct: Boolean;                       // ������������ ������� � �������

    function GetFilterText: String;             // ����� �������
    function GetCondition(const AnIndex: Integer): TFilterCondition;
  public
    destructor Destroy; override;

    property IsAndCondition: Boolean read FIsAndCondition write FIsAndCondition default True;
    property IsDistinct: Boolean read FIsDistinct write FIsDistinct;

    property FilterText: String read GetFilterText;

    procedure Clear; override;
    procedure Assign(Source: TFilterConditionList);

    property Conditions[const AnIndex: Integer]: TFilterCondition read GetCondition;

    function AddCondition(const AnConditionData: TFilterCondition): Integer; overload;
    function AddCondition(const AnFieldData: TfltFieldData; const AnConditionType: TFilterConditionType;
     const AnValue1, AnValue2: String; const AnSubFilter: TFilterConditionList;
     const AnValueList: TStringList): Integer; overload;

    function CheckCondition(const AnConditionData: TFilterCondition): Boolean;

    procedure DeleteCondition(const AnIndex: Integer);

    procedure ReadFromStream(S: TStream);               // ������ �� ������
    procedure WriteToStream(S: TStream);                // ������ � �����
  end;

  // ��� ������ ��� �������
  TFilterData = class
  private
    function GetFilterText: String;
    function GetOrderText: String;
  public
    ConditionList: TFilterConditionList;        // ������ ������� ����������
    OrderByList: TFilterOrderByList;            // ������ ������� ����������

    constructor Create;
    destructor Destroy; override;

    procedure Assign(Value: TFilterData);       // ���������
    procedure Clear;                            // ��������

    property FilterText: String read GetFilterText;     // ����� �������
    property OrderText: String read GetOrderText;       // ����� ����������

    procedure ReadFromStream(S: TStream);       // ������ �� ������
    procedure WriteToStream(S: TStream);        // ������ � �����
  end;

type
  TfltStringList = class(TStringList)
  private
    function GetValue(const AnIndex: Integer): String;
    procedure SetValue(const AnIndex: Integer; const Value: String);
  public
    property ValuesOfIndex[const AnIndex: Integer]: string read GetValue write SetValue;
    procedure RemoveDouble;     // �������� ������������� �������. ������ ������ ����� �� ������������
  end;

type
  TIndexEvent = procedure(const AnIndexField: Boolean) of object;
  TConditionChanged = procedure(Sender: TObject) of object;
  TFilterChanged = procedure(Sender: TObject; const AnCurrentFilter: Integer) of object;

{ ������ ������ }

// ������������ ��� fltFieldData
function CompareFieldData(const FirstField, SecondField: TfltFieldData): Boolean;
// ������������ ��� FilterCondition
function CompareConditionData(const FirstCondition, SecondCondition: TFilterCondition): Boolean;
// ������������ ��� FilterConditionList
function CompareConditionList(const FirstList, SecondList: TFilterConditionList): Boolean;
// ������������ ��� FilterOrderBy
function CompareOrderByData(const FirstOrderBy, SecondOrderBy: TFilterOrderBy): Boolean;
// ������������ ��� FilterOrderByList
function CompareOrderByList(const FirstList, SecondList: TFilterOrderByList): Boolean;
// ������������ ��� FilterData
function CompareFilterData(const FirstData, SecondData: TFilterData): Boolean;
// ��������� ��� ������� � ����������� �� ���� ������ � ����� ������ � ��
function ConvertCondition(const ConditionType, DataType: Integer): Integer;
// ��������� ����� ������ � �� � ����������� �� ���� ������ � ��� �������
function ExtractCondition(const ItemIndex, DataType: Integer): Integer;
// ��������� �� ��������� � ����������� �� ���� ������
procedure FillComboCond(const DataType: Integer; var cbCond: TComboBox;
 const IsTree: Boolean);
// ������� �������� ������� �� �� ����
function GetConditionName(ConditionType: Integer): String;
// ����������� TConditionList � TgsParamList
procedure QueryParamsForConditions(const AnFilterComponent, AnFilterKey: Integer;
 const AnConditionList: TFilterConditionList; var AnResult: Boolean; out VarResult: Variant;
 const AShowDlg: Boolean = True; const AFormName: string = ''; const AFilterName: string = '');

// ��������� SQL ������
//- AnFilterData         - ������ �������
//- AnSelectText         - SELECT ����� �������
//- AnFromText           - FROM ����� �������
//- AnWhereText          - WHERE ����� �������
//- AnOtherText          - OTHER ����� �������
//- AnOrderText          - ORDER ����� �������
//- AnQueryText          - SELECT ����� �������
//- AnTableList          - �������������� ������
//- AnComponentKey       - ���� ���������� ����������
//- AnCurrentFilter      - ���� �������� �������
function CreateCustomSQL(AnFilterData: TFilterData; AnSelectText, AnFromText,
  AnWhereText, AnOtherText, AnOrderText, AnQueryText: TStrings;
  AnTableList: TStringList; AnComponentKey, AnCurrentFilter: Integer;
  const AnRequeryParam: Boolean; var AnSilentParams: Variant;
  const AShowDlg: Boolean = True; const AFormName: string = '';
  const AFilterName: string = ''): Boolean;

var
  FSuppressWarning: Boolean;  

implementation

uses
  flt_ScriptInterface, at_Classes, prm_ParamFunctions_unit, flt_IBUtils,
{$IFDEF GEDEMIN}
  gd_splash, Storages,
{$ENDIF}
  Windows

{must be placed after Windows unit!}
{$IFDEF LOCALIZATION}
  , gd_localization_stub
{$ENDIF}

{$IFDEF VER140}
  , Variants
{$ENDIF}
  ;

constructor TfltFieldData.Create;
begin
  Clear;
end;

procedure TfltFieldData.Clear;
begin
  // ������� ��� ����
  TableName := '';
  TableAlias := '';
  LocalTable := '';
  PrimaryName := '';
  FieldName := '';
  LocalField := '';
  DisplayName := '';
  FieldType := GD_DT_UNKNOWN;
  LinkTable := '';
  LinkSourceField := '';
  LinkTargetField := '';
  LinkTargetFieldType := GD_DT_UNKNOWN;
  RefTable := '';
  RefField := '';
  IsReference := False;
  IsTree := False;
  AttrKey := 0;
  AttrRefKey := 0;
end;

procedure TfltFieldData.Assign(Source: TfltFieldData);
begin
  // ����������� ��� ���� �� ���������
  TableName := Source.TableName;
  TableAlias := Source.TableAlias;
  LocalTable := Source.LocalTable;
  PrimaryName := Source.PrimaryName;
  FieldName := Source.FieldName;
  LocalField := Source.LocalField;
  FieldType := Source.FieldType;
  DisplayName := Source.DisplayName;
  LinkTable := Source.LinkTable;
  LinkSourceField := Source.LinkSourceField;
  LinkTargetField := Source.LinkTargetField;
  LinkTargetFieldType := Source.LinkTargetFieldType;
  RefTable := Source.RefTable;
  RefField := Source.RefField;
  IsReference := Source.IsReference;
  AttrKey := Source.AttrKey;
  AttrRefKey := Source.AttrRefKey;
end;

procedure TfltFieldData.ReadFromStream(S: TStream);
type
  PBoolean = ^Boolean;
  PInteger = ^Integer;

var
  LblStr: TLabelStream;
  RelationLength: Integer;
  Buffer: String[255];
begin
  Clear;
  // ��������� �����
  S.ReadBuffer(LblStr, LblSize);
  // ���� ����� �� ��� ������� ������
  if LblStr <> GD_LBL_BGN_FIELDDATA then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  S.ReadBuffer(LblStr, LblSize);
  // ���� �� ��������� ����� ������ ����
  while (LblStr <> GD_LBL_END_FIELDDATA) do
  begin
    // ��������� �������
    if S.Size <= S.Position then
      raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    S.ReadBuffer(RelationLength, IntSize);
    S.ReadBuffer(Buffer, RelationLength);
    // ����������� ���� � ����������� �� ����, ��� �������
    if LblStr = GD_LBL_TABLENAME then
      TableName := Buffer
    else
      if LblStr = GD_LBL_TABLEALIAS then
        TableAlias := Buffer
      else
        if LblStr = GD_LBL_PRIMARYNAME then
          PrimaryName := Buffer
        else
          if LblStr = GD_LBL_LOCALTABLE then
            LocalTable := Buffer
          else
            if LblStr = GD_LBL_FIELDNAME then
              FieldName := Buffer
            else
              if LblStr = GD_LBL_LOCALFIELD then
                LocalField := Buffer
              else
                if LblStr = GD_LBL_FIELDTYPE then
                  FieldType := PInteger(@Buffer)^
                else
                  if LblStr = GD_LBL_DISPLAYNAME then
                    DisplayName := Buffer
                  else
                    if LblStr = GD_LBL_LINKTABLE then
                      LinkTable := Buffer
                    else
                      if LblStr = GD_LBL_LINKSOURCEFIELD then
                        LinkSourceField := Buffer
                      else
                        if LblStr = GD_LBL_LINKTARGETFIELD then
                          LinkTargetField := Buffer
                        else
                          if LblStr = GD_LBL_LINKTARGETFIELDTYPE then
                            LinkTargetFieldType := PInteger(@Buffer)^
                          else
                            if LblStr = GD_LBL_REFTABLE then
                              RefTable := Buffer
                            else
                              if LblStr = GD_LBL_REFFIELD then
                                RefField := Buffer
                              else
                                if LblStr = GD_LBL_ISTREE then
                                  IsTree := PBoolean(@Buffer)^
                                else
                                  if LblStr = GD_LBL_ISREFERENCE then
                                    IsReference := PBoolean(@Buffer)^
                                  else
                                    if LblStr = GD_LBL_ATTRKEY then
                                      AttrKey := PInteger(@Buffer)^
                                    else
                                      if LblStr = GD_LBL_ATTRREFKEY then
                                        AttrRefKey := PInteger(@Buffer)^;
    // ������ ��������� �����
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TfltFieldData.WriteToStream(S: TStream);
  // ��������� ���������� ����. ���������� ������, �����, ������ ������
  procedure SaveField(const Buffer; const AnLabelStream: TLabelStream; const ValSize: Integer);
  begin
    S.Write(AnLabelStream, LblSize);
    S.Write(ValSize, IntSize);
    S.Write(Buffer, ValSize);
  end;
begin
  // ����� ������ ������ ����
  S.Write(GD_LBL_BGN_FIELDDATA, LblSize);
  // ��������� ��� ����
  if TableName > '' then
    SaveField(TableName, GD_LBL_TABLENAME, Length(TableName) * CharSize + 1);

  if TableAlias > '' then
    SaveField(TableAlias, GD_LBL_TABLEALIAS, Length(TableAlias) * CharSize + 1);

  if PrimaryName > '' then
    SaveField(PrimaryName, GD_LBL_PRIMARYNAME, Length(PrimaryName) * CharSize + 1);

  if LocalTable > '' then
    SaveField(LocalTable, GD_LBL_LOCALTABLE, Length(LocalTable) * CharSize + 1);

  if FieldName > '' then
    SaveField(FieldName, GD_LBL_FIELDNAME, Length(FieldName) * CharSize + 1);

  if LocalField > '' then
    SaveField(LocalField, GD_LBL_LOCALFIELD, Length(LocalField) * CharSize + 1);

  if FieldType <> GD_DT_UNKNOWN then
    SaveField(FieldType, GD_LBL_FIELDTYPE, SizeOf(FieldType));

  if DisplayName > '' then
    SaveField(DisplayName, GD_LBL_DISPLAYNAME, Length(DisplayName) * CharSize + 1);

  if LinkTable > '' then
    SaveField(LinkTable, GD_LBL_LINKTABLE, Length(LinkTable) * CharSize + 1);

  if LinkSourceField > '' then
    SaveField(LinkSourceField, GD_LBL_LINKSOURCEFIELD, Length(LinkSourceField) * CharSize + 1);

  if LinkTargetField > '' then
    SaveField(LinkTargetField, GD_LBL_LINKTARGETFIELD, Length(LinkTargetField) * CharSize + 1);

  if LinkTargetFieldType <> GD_DT_UNKNOWN then
    SaveField(LinkTargetFieldType, GD_LBL_LINKTARGETFIELDTYPE, SizeOf(LinkTargetFieldType));

  if RefTable > '' then
    SaveField(RefTable, GD_LBL_REFTABLE, Length(RefTable) * CharSize + 1);

  if RefField > '' then
    SaveField(RefField, GD_LBL_REFFIELD, Length(RefField) * CharSize + 1);

  SaveField(IsTree, GD_LBL_ISTREE, SizeOf(IsTree));
  SaveField(IsReference, GD_LBL_ISREFERENCE, SizeOf(IsReference));

  if AttrKey <> 0 then
    SaveField(AttrKey, GD_LBL_ATTRKEY, SizeOf(AttrKey));

  if AttrRefKey <> 0 then
    SaveField(AttrRefKey, GD_LBL_ATTRREFKEY, SizeOf(AttrRefKey));
  // ����� ����� ������ ����
  S.Write(GD_LBL_END_FIELDDATA, LblSize);
end;

// ��������� ��� �������� ������ �� ������ ������� ����������

procedure TFilterOrderBy.Assign(Source: TFilterOrderBy);
begin
  // ����������� �������� ����� �� ���������
  TableName := Source.TableName;
  TableAlias := Source.TableAlias;
  FieldName := Source.FieldName;
  LocalField := Source.LocalField;
  IsAscending := Source.IsAscending;
end;


procedure TFilterOrderBy.Clear;
begin
  // ������� ����
  TableName := '';
  TableAlias := '';
  FieldName := '';
  LocalField := '';
  IsAscending := False;
end;

procedure TFilterOrderBy.ReadFromStream(S: TStream);
type
  PBoolean = ^Boolean;

var
  LblStr: TLabelStream;
  RelationLength: Integer;
  Buffer: String[255];
begin
  Clear;
  // ������ ����� ������ ����� ������ ������� ����������
  S.ReadBuffer(LblStr, LblSize);
  if LblStr <> GD_LBL_BGN_ORDERDATA then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  S.ReadBuffer(LblStr, LblSize);
  // ���� �� ��������� ����� �����
  while (LblStr <> GD_LBL_END_ORDERDATA) do
  begin
    // ��������� ������� ������
    if S.Size <= S.Position then
      raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    S.ReadBuffer(RelationLength, IntSize);
    S.ReadBuffer(Buffer, RelationLength);
    // ��������� ���� �����
    if LblStr = GD_LBL_TABLENAME then
      TableName := Buffer
    else
      if LblStr = GD_LBL_TABLEALIAS then
        TableAlias := Buffer
      else
        if LblStr = GD_LBL_FIELDNAME then
          FieldName := Buffer
        else
          if LblStr = GD_LBL_LOCALFIELD then
            LocalField := Buffer
          else
            if LblStr = GD_LBL_ISREFERENCE then
              IsAscending := PBoolean(@Buffer)^;
    // ��������� ��������� �����
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TFilterOrderBy.WriteToStream(S: TStream);
  procedure SaveField(const Buffer; const AnLabelStream: TLabelStream; const ValSize: Integer);
  begin
    S.Write(AnLabelStream, LblSize);
    S.Write(ValSize, IntSize);
    S.Write(Buffer, ValSize);
  end;
begin
  // ������ ����� �������
  S.Write(GD_LBL_BGN_ORDERDATA, LblSize);
  // ��������� ����
  if TableName > '' then
    SaveField(TableName, GD_LBL_TABLENAME, Length(TableName) * CharSize + 1);

  if TableAlias > '' then
    SaveField(TableAlias, GD_LBL_TABLEALIAS, Length(TableAlias) * CharSize + 1);

  if FieldName > '' then
    SaveField(FieldName, GD_LBL_FIELDNAME, Length(FieldName) * CharSize + 1);

  if LocalField > '' then
    SaveField(LocalField, GD_LBL_LOCALFIELD, Length(LocalField) * CharSize + 1);

  SaveField(IsAscending, GD_LBL_ISREFERENCE, SizeOf(IsAscending));
  // ����� ����� ������
  S.Write(GD_LBL_END_ORDERDATA, LblSize);
end;

// ��������� ��� �������� ������ ������� ����������

destructor TFilterOrderByList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TFilterOrderByList.Clear;
var
  I: Integer;
begin
  for I := Self.Count - 1 downto 0 do
    DeleteOrderBy(I);
  inherited Clear;
end;

function TFilterOrderByList.GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
begin
  Assert((AnIndex >= 0) or (Self.Count > AnIndex), '������ ��� ���������');
  Assert(Self.Items[AnIndex] <> nil, '���� ������ ����');
  Result := TFilterOrderBy(Items[AnIndex]);
end;

procedure TFilterOrderByList.Assign(Source: TFilterOrderByList);
var
  I: Integer;
begin
  if Source <> nil then
  begin
    Self.Clear;
    for I := 0 to Source.Count - 1 do
    begin
      Self.AddOrderBy(Source.OrdersBy[I]);
    end;
  end;
end;

function TFilterOrderByList.AddOrderBy(const AnOrderByData: TFilterOrderBy): Integer;
begin
  Result := Self.Add(TFilterOrderBy.Create);
  if AnOrderByData <> nil then
    TFilterOrderBy(Items[Result]).Assign(AnOrderByData);
end;

function TFilterOrderByList.AddOrderBy(const AnTableName, AnTableAlias, AnLocalTable, AnFieldName,
 AnLocalField: TRelationName; const AnAscending: Boolean): Integer;
begin
  Result := Self.Add(TFilterOrderBy.Create);
  TFilterOrderBy(Items[Result]).TableName := AnTableName;
  TFilterOrderBy(Items[Result]).TableAlias := AnTableAlias;
  TFilterOrderBy(Items[Result]).FieldName := AnFieldName;
  TFilterOrderBy(Items[Result]).LocalField := AnLocalField;
  TFilterOrderBy(Items[Result]).IsAscending := AnAscending;
end;

procedure TFilterOrderByList.DeleteOrderBy(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) or (Self.Count > AnIndex), '������ ��� ���������');
  TFilterOrderBy(Self.Items[AnIndex]).Free;
  Self.Items[AnIndex] := nil;
  Self.Delete(AnIndex);
end;

procedure TFilterOrderByList.ReadFromStream(S: TStream);
var
  LblStr: TLabelStream;
begin
  Clear;
  // ��������� ������ ������ �������
  S.ReadBuffer(LblStr, LblSize);
  if LblStr <> GD_LBL_BGN_ORDERLIST then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  S.ReadBuffer(LblStr, LblSize);
  // ���� �� ��������� �����
  while LblStr <> GD_LBL_END_ORDERLIST do
  begin
    // ����� ���� ������������
    if LblStr = GD_LBL_ISINDEXFIELD then
    begin
      // �������� ������
      if S.Size <= S.Position then
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);
      S.ReadBuffer(FOnlyIndexField, SizeOf(FOnlyIndexField));
    end else
      if LblStr = GD_LBL_ORDERLISTITEM then
      begin
        OrdersBy[AddOrderBy(nil)].ReadFromStream(S);
        // �������� ������
        if S.Size <= S.Position then
          raise Exception.Create(GD_LBL_ERROR_MESSAGE);
      end else
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TFilterOrderByList.WriteToStream(S: TStream);
var
  I: Integer;
begin
  // ������ ������
  S.Write(GD_LBL_BGN_ORDERLIST, LblSize);
  // ������������ ����
  S.Write(GD_LBL_ISINDEXFIELD, LblSize);
  S.Write(FOnlyIndexField, SizeOf(FOnlyIndexField));
  // ��������� ��� �������
  for I := 0 to Count - 1 do
  begin
    S.Write(GD_LBL_ORDERLISTITEM, LblSize);
    OrdersBy[I].WriteToStream(S);
  end;
  // ����� ������
  S.Write(GD_LBL_END_ORDERLIST, LblSize);
end;

function TFilterOrderByList.GetOrderText: String;
var
  I: Integer;
  Asc: String;
begin
  Result := '';

  for I := 0 to Count - 1 do
  begin
    if OrdersBy[I].IsAscending then
      Asc := ' �� �����������'
    else
      Asc := ' �� ��������';
    if OrdersBy[I].LocalField > '' then
      Result := Result + OrdersBy[I].LocalField + Asc + ', '
    else
      Result := Result + OrdersBy[I].FieldName + Asc + ', ';
  end;

  if Count > 0 then
  begin
    System.Delete(Result, Length(Result) - 1, 2);
    Result := '����������� ��: ' + Result;
  end;

end;

// ��������� ��� �������� ������ ������� ����������

constructor TFilterCondition.Create;
begin
  ValueList := TStringList.Create;
  SubFilter := TFilterConditionList.Create;
  FieldData := TfltFieldData.Create;
end;

constructor TFilterCondition.Create(const AnFieldData: TfltFieldData; const AnConditionType: Integer;
 const AnValue1, AnValue2: String; const AnSubFilter: TFilterConditionList;
 const AnValueList: TStringList);
begin
  ValueList := TStringList.Create;
  SubFilter := TFilterConditionList.Create;
  FieldData := TfltFieldData.Create;

  ConditionType := AnConditionType;
  Value1 := AnValue1;
  Value2 := AnValue2;

  if AnValueList <> nil then
    ValueList.Assign(AnValueList);
  if AnSubFilter <> nil then
    SubFilter.Assign(AnSubFilter);
  if AnFieldData <> nil then
    FieldData.Assign(AnFieldData);
end;

destructor TFilterCondition.Destroy;
begin
  ValueList.Free;
  SubFilter.Free;
  FieldData.Free;

  inherited Destroy;
end;

procedure TFilterCondition.Assign(Source: TFilterCondition);
begin
  // ����������� ����
  if Source.FieldData <> nil then
    FieldData.Assign(Source.FieldData);
  ConditionType := Source.ConditionType;
  Value1 := Source.Value1;
  Value2 := Source.Value2;
  if Source.SubFilter <> nil then
    SubFilter.Assign(Source.SubFilter);
  if Source.ValueList <> nil then
    ValueList.Assign(Source.ValueList);
end;

procedure TFilterCondition.Clear;
begin
  // ������� �����
  FieldData.Clear;
  ConditionType := -1;
  Value1 := '';
  Value2 := '';
  SubFilter.Clear;
  ValueList.Clear;
end;

procedure TFilterCondition.ReadFromStream(S: TStream);
var
  LblStr: TLabelStream;
  BufSize: Integer;

  // ������ ����������
  procedure LoadSubFilter;
  var
    TempStr: TLabelStream;
  begin
    SubFilter.ReadFromStream(S);
    S.ReadBuffer(TempStr, LblSize);
    if TempStr <> GD_LBL_END_SUBFILTER then
      raise Exception.Create(GD_LBL_ERROR_MESSAGE);
  end;

  // ������ ������ ��������
  procedure LoadValueList;
  var
    TempInt1, TempInt2: Integer;
    TempLbl: TLabelStream;
    TempStr: String;
  begin
    S.ReadBuffer(TempLbl, LblSize);
    while TempLbl <> GD_LBL_END_VALUELIST do
    begin
      if TempLbl = GD_LBL_VALUELISTITEM then
      begin
        S.ReadBuffer(TempInt1, IntSize);
        S.ReadBuffer(TempInt2, IntSize);
        SetLength(TempStr, TempInt2);
        S.ReadBuffer(Pointer(TempStr)^, TempInt2);
        ValueList.AddObject(TempStr, Pointer(TempInt1));
      end else
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);

      if S.Size <= S.Position then
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);

      S.ReadBuffer(TempLbl, LblSize);
    end;
  end;
begin
  Clear;
  // ������ ������
  S.ReadBuffer(LblStr, LblSize);
  if LblStr <> GD_LBL_BGN_CONDITION then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  // ������ �����
  S.ReadBuffer(LblStr, LblSize);
  while LblStr <> GD_LBL_END_CONDITION do
  begin
    if LblStr = GD_LBL_BGN_FIELDDATA then
    begin
      S.Position := S.Position - LblSize;
      FieldData.ReadFromStream(S);
    end else
      if LblStr = GD_LBL_CONDTYPE then
        S.ReadBuffer(ConditionType, SizeOf(ConditionType))
      else
        if LblStr = GD_LBL_VALUE1 then
        begin
          S.ReadBuffer(BufSize, IntSize);
          SetLength(Value1, BufSize);
          S.ReadBuffer(Pointer(Value1)^, BufSize);
        end else
          if LblStr = GD_LBL_VALUE2 then
            S.ReadBuffer(Value2, SizeOf(Value2))
          else
            if LblStr = GD_LBL_BGN_SUBFILTER then
              LoadSubFilter
            else
              if LblStr = GD_LBL_BGN_VALUELIST then
                LoadValueList;
    // �������� ��������
    if S.Size <= S.Position then
      raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    // ������ ���������� ������
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TFilterCondition.WriteToStream(S: TStream);
var
  BufSize: Integer;

  // ��������� ���������
  procedure SaveSubFilter;
  begin
    if SubFilter.Count > 0 then
    begin
      S.Write(GD_LBL_BGN_SUBFILTER, LblSize);
      SubFilter.WriteToStream(S);
      S.Write(GD_LBL_END_SUBFILTER, LblSize);
    end;
  end;

  // ��������� ������ ��������
  procedure SaveValueList;
  var
    I, Temp: Integer;
  begin
    if ValueList.Count > 0 then
    begin
      S.Write(GD_LBL_BGN_VALUELIST, LblSize);
      for I := 0 to ValueList.Count - 1 do
      begin
        S.Write(GD_LBL_VALUELISTITEM, LblSize);
        Temp := Integer(ValueList.Objects[I]);
        S.Write(Temp, IntSize);
        Temp := Length(ValueList.Strings[I]) * CharSize;
        S.Write(Temp, IntSize);
        S.Write(Pointer(ValueList.Strings[I])^, Temp);
      end;
      S.Write(GD_LBL_END_VALUELIST, LblSize);
    end;
  end;
begin
  // ������ �����
  S.Write(GD_LBL_BGN_CONDITION, LblSize);

  FieldData.WriteToStream(S);

  S.Write(GD_LBL_CONDTYPE, LblSize);
  S.Write(ConditionType, SizeOf(ConditionType));

  if Value1 > '' then
  begin
    S.Write(GD_LBL_VALUE1, LblSize);
    BufSize := Length(Value1) * CharSize;
    S.Write(BufSize, IntSize);
    S.Write(Pointer(Value1)^, BufSize);
  end;

  if Value2 > '' then
  begin
    S.Write(GD_LBL_VALUE2, LblSize);
    S.Write(Value2, SizeOf(Value2));
  end;

  SaveSubFilter;
  SaveValueList;
  // ����� �����
  S.Write(GD_LBL_END_CONDITION, LblSize);
end;

// ��������� ��� �������� ������ ������� ����������

destructor TFilterConditionList.Destroy;
begin
  Clear;

  inherited Destroy;
end;

procedure TFilterConditionList.Assign(Source: TFilterConditionList);
var
  I: Integer;
begin
  if Source <> nil then
  begin
    Self.Clear;
    for I := 0 to Source.Count - 1 do
    begin
      Self.AddCondition(Source.Conditions[I]);
    end;
    FIsAndCondition := Source.IsAndCondition;
    FIsDistinct := Source.IsDistinct;
  end;
end;

procedure TFilterConditionList.Clear;
var
  I: Integer;
begin
  IsAndCondition := True;
  for I := Self.Count - 1 downto 0 do
    DeleteCondition(I);
  inherited Clear;
end;

function TFilterConditionList.AddCondition(const AnConditionData: TFilterCondition): Integer;
begin
  Result := Self.Add(TFilterCondition.Create);
  if AnConditionData <> nil then
    TFilterCondition(Items[Result]).Assign(AnConditionData);
end;

function TFilterConditionList.AddCondition(const AnFieldData: TfltFieldData; const AnConditionType: TFilterConditionType;
 const AnValue1, AnValue2: String; const AnSubFilter: TFilterConditionList; const AnValueList: TStringList): Integer;
begin
  Result := Self.Add(TFilterCondition.Create(AnFieldData, AnConditionType, AnValue1,
   AnValue2, AnSubFilter, AnValueList));
end;

// �������� ������� �� ������������ ����������
function TFilterConditionList.CheckCondition(const AnConditionData: TFilterCondition): Boolean;
var
  TempFieldType: Integer;
begin
  // ���� ������� ��������� ������ �� ����� � �������
  if AnConditionData.FieldData.FieldType = GD_DT_FORMULA then
  begin
    Result := (Trim(AnConditionData.Value1) > '')
     and (AnConditionData.ConditionType in [GD_FC_QUERY_WHERE, GD_FC_QUERY_ALL]);
    Exit;
  end;
  // ��������� ������������ ����������
  Result := Trim(AnConditionData.FieldData.TableName) > '';
  Result := Result and (Trim(AnConditionData.FieldData.FieldName) > '');

  if not Result then
    Exit;

  // ������������� ��� ����
  if AnConditionData.FieldData.FieldType <> GD_DT_UNKNOWN_SET then
    TempFieldType := AnConditionData.FieldData.FieldType
  else
  begin
    TempFieldType := AnConditionData.FieldData.LinkTargetFieldType;
    case TempFieldType of
     GD_DT_DIGITAL, GD_DT_CHAR, GD_DT_DATE, GD_DT_TIMESTAMP, GD_DT_TIME,
     GD_DT_BOOLEAN, GD_DT_BLOB_TEXT, GD_DT_BLOB:;
    else
      Result := False;
    end;
    Result := Result and (Trim(AnConditionData.FieldData.LinkTable) > '');
    Result := Result and (Trim(AnConditionData.FieldData.LinkTargetField) > '');
    Result := Result and (Trim(AnConditionData.FieldData.LinkSourceField) > '');
  end;

  if not Result then
    Exit;

  // � ����������� �� ���� ������� ��������� ������� ��������������� ��������
  case AnConditionData.ConditionType of
    GD_FC_TODAY, GD_FC_EMPTY, GD_FC_NOT_EMPTY, GD_FC_TRUE, GD_FC_FALSE:
      {������ ������ �� ��������}
      if (TempFieldType = GD_DT_REF_SET) or (TempFieldType = GD_DT_CHILD_SET) then
        Result := Result and (Trim(AnConditionData.FieldData.LinkSourceField) > '')
         and (Trim(AnConditionData.FieldData.LinkTable) > '');
    GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_LESS_THAN, GD_FC_NOT_EQUAL_TO,
    GD_FC_GREATER_OR_EQUAL_TO, GD_FC_LESS_OR_EQUAL_TO, GD_FC_BEGINS_WITH,
    GD_FC_ENDS_WITH, GD_FC_CONTAINS, GD_FC_DOESNT_CONTAIN, GD_FC_LAST_N_DAYS,
    GD_FC_SELDAY:
      if TempFieldType <> GD_DT_CHAR then
        Result := Result and (Trim(AnConditionData.Value1) > '');

    GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT, GD_FC_SCRIPT,
    GD_FC_ENTER_PARAM:
      if TempFieldType <> GD_DT_CHAR then
        Result := Result and (Trim(AnConditionData.Value1) > '')
         and (Trim(AnConditionData.Value2) > '');

    GD_FC_CUSTOM_FILTER, GD_FC_ACTUATES, GD_FC_NOT_ACTUATES, GD_FC_ACTUATES_TREE,
    GD_FC_NOT_ACTUATES_TREE, GD_FC_INCLUDES, GD_FC_COMPLEXFIELD:
    begin
      case TempFieldType of
        GD_DT_ENUMERATION:
        begin
          Result := Result and (AnConditionData.Value1 > '');
          Exit;
        end;

        GD_DT_REF_SET_ELEMENT:
          Result := Result and (Trim(AnConditionData.FieldData.RefField) > '')
           and (Trim(AnConditionData.FieldData.RefTable) > '');

        GD_DT_CHILD_SET:
          Result := Result and (Trim(AnConditionData.FieldData.LinkSourceField) > '')
           and (Trim(AnConditionData.FieldData.LinkTable) > '')
           and (Trim(AnConditionData.FieldData.LinkTargetField) > '');

        GD_DT_REF_SET:
          Result := Result and (Trim(AnConditionData.FieldData.RefField) > '')
           and (Trim(AnConditionData.FieldData.RefTable) > '')
           and (Trim(AnConditionData.FieldData.LinkTable) > '')
           and (Trim(AnConditionData.FieldData.LinkTargetField) > '')
           and (Trim(AnConditionData.FieldData.LinkSourceField) > '');
        GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
          Result := Result and (AnConditionData.FieldData.AttrKey <> 0)
           and (AnConditionData.FieldData.AttrRefKey <> 0);
      end;

      if AnConditionData.ConditionType in [GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD] then
        Result := Result and (AnConditionData.SubFilter.Count > 0)
      else
        Result := Result and (AnConditionData.ValueList.Count > 0);
    end;
  else
    Result := False;
  end;
end;

function TFilterConditionList.GetCondition(const AnIndex: Integer): TFilterCondition;
begin
  Assert((AnIndex >= 0) or (Self.Count > AnIndex), '������ ��� ���������');
  Assert(Self.Items[AnIndex] <> nil, '���� ������ ����');
  Result := TFilterCondition(Self.Items[AnIndex]);
end;

procedure TFilterConditionList.DeleteCondition(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) or (Self.Count > AnIndex), '������ ��� ���������');
  TFilterCondition(Self.Items[AnIndex]).Free;
  Self.Items[AnIndex] := nil;
  Self.Delete(AnIndex);
end;

procedure TFilterConditionList.ReadFromStream(S: TStream);
var
  LblStr: TLabelStream;
  LByte: Byte;
begin
  // ���� ������ Boolean �� ����� 1 �����, ���� �������� ��� LByte �� ���������������.
  // ��� ���� ������������� � �������� �������� ������ �������� �� �����
  // ������� � ���������� ��-�� ��������� Distinct ��� ��������� ������������� �� ������ ��������
  Assert(SizeOf(Byte) = SizeOf(Boolean), 'Filter format compatibility error');
  Clear;
  // ������ ������ ������
  S.ReadBuffer(LblStr, LblSize);
  if LblStr <> GD_LBL_BGN_CONDITIONLIST then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  S.ReadBuffer(LblStr, LblSize);
  // ���� �� ��������� �����
  while LblStr <> GD_LBL_END_CONDITIONLIST do
  begin
    if LblStr = GD_LBL_MERGECONDITION then
    begin
      // �������� ��������
      if S.Size <= S.Position then
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);
      S.ReadBuffer(LByte, SizeOf(LByte));
      FIsAndCondition := LByte and 1 = 1;
      FIsDistinct := LByte and 2 = 2;
    end else
      if LblStr = GD_LBL_CONDITIONLISTITEM then
      begin
        Conditions[AddCondition(nil)].ReadFromStream(S);
        // �������� ��������
        if S.Size <= S.Position then
          raise Exception.Create(GD_LBL_ERROR_MESSAGE);
      end else
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    // ������ ��������� �����
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TFilterConditionList.WriteToStream(S: TStream);
var
  I: Integer;
  LByte: Byte;
begin
  // ���� ������ Boolean �� ����� 1 �����, ���� �������� ��� LByte �� ���������������.
  // ��� ���� ������������� � �������� �������� ������ �������� �� �����
  // ������� � ���������� ��-�� ��������� Distinct ��� ��������� ������������� �� ������ ��������
  Assert(SizeOf(Byte) = SizeOf(Boolean), 'Filter format compatibility error');
  // ������ ������
  S.Write(GD_LBL_BGN_CONDITIONLIST, LblSize);
  // ������� �����������
  S.Write(GD_LBL_MERGECONDITION, LblSize);
  LByte := Byte(FIsAndCondition) or Byte(FIsDistinct) shl 1;
  S.Write(LByte, SizeOf(LByte));
  // ��������� ��� �������
  for I := 0 to Count - 1 do
  begin
    S.Write(GD_LBL_CONDITIONLISTITEM, LblSize);
    Conditions[I].WriteToStream(S);
  end;
  // ����� ������
  S.Write(GD_LBL_END_CONDITIONLIST, LblSize);
end;

function TFilterConditionList.GetFilterText: String;
var
  I, J: Integer;
  FieldName: String;
  Sign: String;
begin
  if Count > 0 then
    Result := '�������������:'
  else
    Result := '';

  if IsAndCondition then
    Sign := ' �'
  else
    Sign := ' ���';

  for I := 0 to Count - 1 do
  begin
    if Conditions[I].FieldData.LocalField > '' then
      FieldName := Conditions[I].FieldData.LocalField
    else          {gs}  // � ����������� �� ����
      //if Conditions[I].FieldData.LocalTable > '' then
        case Conditions[I].FieldData.FieldType of
          GD_DT_REF_SET:
            FieldName := Conditions[I].FieldData.LinkTable + '-'
             + Conditions[I].FieldData.LinkTargetField;
          GD_DT_CHILD_SET:
            FieldName := Conditions[I].FieldData.LinkTable + '-'
             + Conditions[I].FieldData.LinkSourceField;
        else
          FieldName := Conditions[I].FieldData.TableName + '-'
           + Conditions[I].FieldData.FieldName;
        end;
      {else
        FieldName := Conditions[I].FieldData.TableName + '-'
         + Conditions[I].FieldData.FieldName;}
    Result := Result + '  (' + FieldName +
     GetConditionName(Conditions[I].ConditionType);
    case Conditions[I].ConditionType of

    GD_FC_TODAY, GD_FC_EMPTY, GD_FC_NOT_EMPTY, GD_FC_TRUE, GD_FC_FALSE:
     {������ ������ �� ��������};
    GD_FC_CUSTOM_FILTER:
      Result := Result + ' �� ' + IntToStr(Conditions[I].SubFilter.Count)
       + ' ��������';

    GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_LESS_THAN, GD_FC_NOT_EQUAL_TO, GD_FC_BEGINS_WITH,
    GD_FC_ENDS_WITH, GD_FC_CONTAINS, GD_FC_LAST_N_DAYS, GD_FC_DOESNT_CONTAIN,
    GD_FC_GREATER_OR_EQUAL_TO, GD_FC_LESS_OR_EQUAL_TO, GD_FC_QUERY_WHERE,
    GD_FC_QUERY_ALL, GD_FC_SELDAY:
      Result := Result + Conditions[I].Value1;

    GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
      Result := Result + '(' + Conditions[I].Value1 + ' � '
       + Conditions[I].Value2 + ')';

    GD_FC_SCRIPT:
      Result := Result + '[SCRIPT]';

    GD_FC_ENTER_PARAM:
      Result := Result + '[ENTER]';

    GD_FC_ACTUATES, GD_FC_ACTUATES_TREE, GD_FC_INCLUDES, GD_FC_NOT_ACTUATES,
    GD_FC_NOT_ACTUATES_TREE:
      begin
        Result := Result + '(';
        for J := 0 to Conditions[I].ValueList.Count - 1 do
          Result := Result + ' ' + Conditions[I].ValueList.Strings[J] + ',';
        Result[Length(Result)] := ')';
      end;

    end;
    Result := Result + ')' + Sign + #13#10;
  end;

  if Length(Result) > 0 then
    System.Delete(Result, Length(Result) - Length(Sign) - 2 + 1, Length(Sign) + 2);
end;

// ��������� ��� �������� ������ �������

constructor TFilterData.Create;
begin
  ConditionList := TFilterConditionList.Create;
  ConditionList.IsAndCondition := True;
  OrderByList := TFilterOrderByList.Create;
end;

destructor TFilterData.Destroy;
begin
  ConditionList.Free;
  OrderByList.Free;

  inherited Destroy;
end;

function TFilterData.GetFilterText: String;
begin
  Result := ConditionList.FilterText;
end;

function TFilterData.GetOrderText: String;
begin
  Result := OrderByList.OrderText;
end;

procedure TFilterData.Assign(Value: TFilterData);
begin
  ConditionList.Assign(Value.ConditionList);
  OrderByList.Assign(Value.OrderByList);
end;

procedure TFilterData.Clear;
begin
  ConditionList.Clear;
  OrderByList.Clear;
end;

procedure TFilterData.ReadFromStream(S: TStream);
var
  LblStr: TLabelStream;
begin
  // ������ ��������� �����
  S.ReadBuffer(LblStr, LblSize);
  if LblStr <> GD_LBL_BGN_FILTERDATA then
    raise Exception.Create(GD_LBL_ERROR_MESSAGE);

  S.ReadBuffer(LblStr, LblSize);
  // ���� �� ��������� �������� �����
  while LblStr <> GD_LBL_END_FILTERDATA do
  begin
    if LblStr = GD_LBL_BGN_CONDITIONLIST then
    begin
      S.Position := S.Position - LblSize;
      ConditionList.ReadFromStream(S);
    end else
      if LblStr = GD_LBL_BGN_ORDERLIST then
      begin
        S.Position := S.Position - LblSize;
        OrderByList.ReadFromStream(S);
      end else
        raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    // �������� ��������
    if S.Size <= S.Position then
      raise Exception.Create(GD_LBL_ERROR_MESSAGE);
    // ������ ��������� �����
    S.ReadBuffer(LblStr, LblSize);
  end;
end;

procedure TFilterData.WriteToStream(S: TStream);
begin
  // ������ �����
  S.Write(GD_LBL_BGN_FILTERDATA, LblSize);
  // ��������� ������ ������� ����������
  ConditionList.WriteToStream(S);
  // ��������� ������ ������� ����������
  OrderByList.WriteToStream(S);
  // ����� �����
  S.Write(GD_LBL_END_FILTERDATA, LblSize);
end;

// �������� ������� ��� ������ � ������� �������

function ConvertCondition(const ConditionType, DataType: Integer): Integer;
begin
  case DataType of
    GD_DT_DIGITAL:
    case ConditionType of
      GD_FC_EQUAL_TO:           Result := 0;
      GD_FC_NOT_EQUAL_TO:       Result := 1;
      GD_FC_LESS_THAN:          Result := 2;
      GD_FC_LESS_OR_EQUAL_TO:   Result := 3;
      GD_FC_GREATER_THAN:       Result := 4;
      GD_FC_GREATER_OR_EQUAL_TO: Result := 5;
      GD_FC_BETWEEN:            Result := 6;
      GD_FC_BETWEEN_LIMIT:      Result := 7;
      GD_FC_OUT:                Result := 8;
      GD_FC_OUT_LIMIT:          Result := 9;
      GD_FC_NOT_EMPTY:          Result := 10;
      GD_FC_EMPTY:              Result := 11;
      GD_FC_ENTER_PARAM:        Result := 12;
      GD_FC_SCRIPT:
        Result := 11 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
    else
      Result := -1;
    end;

    GD_DT_ENUMERATION:
    case ConditionType of
      GD_FC_EQUAL_TO:           Result := 0;
      GD_FC_NOT_EQUAL_TO:       Result := 1;
      GD_FC_ACTUATES:           Result := 2;
      GD_FC_NOT_ACTUATES:       Result := 3;
      GD_FC_NOT_EMPTY:          Result := 4;
      GD_FC_EMPTY:              Result := 5;
      GD_FC_ENTER_PARAM:        Result := 6;
      GD_FC_SCRIPT:             Result := 6 + (Integer(Assigned(ParamGlobalDlg)) and 1);
    else
      Result := -1;
    end;

    GD_DT_CHAR:
    case ConditionType of
      GD_FC_BEGINS_WITH:        Result := 0;
      GD_FC_CONTAINS:           Result := 1;
      GD_FC_DOESNT_CONTAIN:     Result := 2;
      GD_FC_ENDS_WITH:          Result := 3;
      GD_FC_EQUAL_TO:           Result := 4;
      GD_FC_NOT_EQUAL_TO:       Result := 5;
      GD_FC_NOT_EMPTY:          Result := 6;
      GD_FC_EMPTY:              Result := 7;
      GD_FC_ENTER_PARAM:        Result := 8;
      GD_FC_SCRIPT:
        Result := 8 + (Integer(Assigned(ParamGlobalDlg)) and 1);
    else
      Result := -1;
    end;

    GD_DT_BLOB_TEXT:
    case ConditionType of
      GD_FC_CONTAINS:           Result := 0;
      GD_FC_DOESNT_CONTAIN:     Result := 1;
      GD_FC_NOT_EMPTY:          Result := 2;
      GD_FC_EMPTY:              Result := 3;
      GD_FC_SCRIPT:             Result := 4;
    else
      Result := -1;
    end;

    GD_DT_BLOB:
    case ConditionType of
      GD_FC_NOT_EMPTY:          Result := 0;
      GD_FC_EMPTY:              Result := 1;
    else
      Result := -1;
    end;

    GD_DT_DATE, GD_DT_TIMESTAMP:
    case ConditionType of
      GD_FC_TODAY:              Result := 0;
      GD_FC_LAST_N_DAYS:        Result := 1;
      GD_FC_EQUAL_TO:           Result := 2;
      GD_FC_NOT_EQUAL_TO:       Result := 3;
      GD_FC_LESS_THAN:          Result := 4;
      GD_FC_LESS_OR_EQUAL_TO:   Result := 5;
      GD_FC_GREATER_THAN:       Result := 6;
      GD_FC_GREATER_OR_EQUAL_TO: Result := 7;
      GD_FC_BETWEEN:            Result := 8;
      GD_FC_BETWEEN_LIMIT:      Result := 9;
      GD_FC_OUT:                Result := 10;
      GD_FC_OUT_LIMIT:          Result := 11;
      GD_FC_NOT_EMPTY:          Result := 12;
      GD_FC_EMPTY:              Result := 13;
      GD_FC_SELDAY:             Result := 14;
      GD_FC_ENTER_PARAM:        Result := 15;
      GD_FC_SCRIPT:
        Result := 14 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
    else
      Result := -1;
    end;

    GD_DT_TIME:
    case ConditionType of
      GD_FC_LESS_THAN:          Result := 0;
      GD_FC_LESS_OR_EQUAL_TO:   Result := 1;
      GD_FC_GREATER_THAN:       Result := 2;
      GD_FC_GREATER_OR_EQUAL_TO: Result := 3;
      GD_FC_BETWEEN:            Result := 4;
      GD_FC_BETWEEN_LIMIT:      Result := 5;
      GD_FC_OUT:                Result := 6;
      GD_FC_OUT_LIMIT:          Result := 7;
      GD_FC_NOT_EMPTY:          Result := 8;
      GD_FC_EMPTY:              Result := 9;
      GD_FC_ENTER_PARAM:        Result := 10;
      GD_FC_SCRIPT:
        Result := 9 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
    else
      Result := -1;
    end;

    GD_DT_BOOLEAN:
    case ConditionType of
      GD_FC_TRUE:               Result := 0;
      GD_FC_FALSE:              Result := 1;
      GD_FC_NOT_EMPTY:          Result := 2;
      GD_FC_EMPTY:              Result := 3;
      GD_FC_ENTER_PARAM:        Result := 4;
      GD_FC_SCRIPT:
        Result := 3 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
    else
      Result := -1;
    end;

    GD_DT_ATTR_SET:
    case ConditionType of
      GD_FC_INCLUDES:           Result := 0;
      GD_FC_ACTUATES:           Result := 1;
    else
      Result := -1;
    end;

    GD_DT_ATTR_SET_ELEMENT:
    case ConditionType of
      GD_FC_ACTUATES:           Result := 0;
      GD_FC_NOT_EMPTY:          Result := 1;
      GD_FC_EMPTY:              Result := 2;
    else
      Result := -1;
    end;

    GD_DT_REF_SET:
    case ConditionType of
      GD_FC_INCLUDES:           Result := 0;
      GD_FC_ACTUATES:           Result := 1;
      GD_FC_NOT_ACTUATES:       Result := 2;
      GD_FC_CUSTOM_FILTER:      Result := 3;
      GD_FC_COMPLEXFIELD:       Result := 4;
      GD_FC_NOT_EMPTY:          Result := 5;
      GD_FC_EMPTY:              Result := 6;
      GD_FC_ENTER_PARAM:        Result := 7;
      GD_FC_SCRIPT:
        Result := 6 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
      GD_FC_ACTUATES_TREE:
        Result := 6 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 1;
      GD_FC_NOT_ACTUATES_TREE:
        Result := 6 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 2;
    else
      Result := -1;
    end;

    GD_DT_CHILD_SET:
    case ConditionType of
      GD_FC_INCLUDES:           Result := 0;
      GD_FC_ACTUATES:           Result := 1;
      GD_FC_NOT_ACTUATES:       Result := 2;
      GD_FC_CUSTOM_FILTER:      Result := 3;
      GD_FC_NOT_EMPTY:          Result := 4;
      GD_FC_EMPTY:              Result := 5;
      GD_FC_ENTER_PARAM:        Result := 6;
      GD_FC_SCRIPT:
        Result := 5 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
      GD_FC_ACTUATES_TREE:
        Result := 5 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 1;
      GD_FC_NOT_ACTUATES_TREE:
        Result := 5 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 2;
    else
      Result := -1;
    end;

    GD_DT_REF_SET_ELEMENT:
    case ConditionType of
      GD_FC_ACTUATES:           Result := 0;
      GD_FC_NOT_ACTUATES:       Result := 1;
      GD_FC_CUSTOM_FILTER:      Result := 2;
      GD_FC_NOT_EMPTY:          Result := 3;
      GD_FC_EMPTY:              Result := 4;
      GD_FC_ENTER_PARAM:        Result := 5;
      GD_FC_SCRIPT:
        Result := 4 + (Integer(Assigned(ParamGlobalDlg)) and 1) + 1;
      GD_FC_ACTUATES_TREE:
        Result := 4 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 1;
      GD_FC_NOT_ACTUATES_TREE:
        Result := 4 + (Integer(Assigned(ParamGlobalDlg)) and 1) +
         (Integer(Assigned(FilterScript)) and 1) + 2;
    else
      Result := -1;
    end;

    GD_DT_FORMULA:
      case ConditionType of
        GD_FC_QUERY_WHERE:      Result := 0;
        GD_FC_QUERY_ALL:        Result := 1;
      else
        Result := -1;
      end;
  else
    Result := -1;
  end;
end;

function ExtractCondition(const ItemIndex, DataType: Integer): Integer;
begin
  case DataType of
    GD_DT_DIGITAL:
    case ItemIndex of
      0: Result := GD_FC_EQUAL_TO;
      1: Result := GD_FC_NOT_EQUAL_TO;
      2: Result := GD_FC_LESS_THAN;
      3: Result := GD_FC_LESS_OR_EQUAL_TO;
      4: Result := GD_FC_GREATER_THAN;
      5: Result := GD_FC_GREATER_OR_EQUAL_TO;
      6: Result := GD_FC_BETWEEN;
      7: Result := GD_FC_BETWEEN_LIMIT;
      8: Result := GD_FC_OUT;
      9: Result := GD_FC_OUT_LIMIT;
      10: Result := GD_FC_NOT_EMPTY;
      11: Result := GD_FC_EMPTY;
      12:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      13: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_ENUMERATION:
    case ItemIndex of
      0: Result := GD_FC_EQUAL_TO;
      1: Result := GD_FC_NOT_EQUAL_TO;
      2: Result := GD_FC_ACTUATES;
      3: Result := GD_FC_NOT_ACTUATES;
      4: Result := GD_FC_NOT_EMPTY;
      5: Result := GD_FC_EMPTY;
      6:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      7: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_CHAR:
    case ItemIndex of
      0: Result := GD_FC_BEGINS_WITH;
      1: Result := GD_FC_CONTAINS;
      2: Result := GD_FC_DOESNT_CONTAIN;
      3: Result := GD_FC_ENDS_WITH;
      4: Result := GD_FC_EQUAL_TO;
      5: Result := GD_FC_NOT_EQUAL_TO;
      6: Result := GD_FC_NOT_EMPTY;
      7: Result := GD_FC_EMPTY;
      8:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      9: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_BLOB_TEXT:
    case ItemIndex of
      0: Result := GD_FC_CONTAINS;
      1: Result := GD_FC_DOESNT_CONTAIN;
      2: Result := GD_FC_NOT_EMPTY;
      3: Result := GD_FC_EMPTY;
      4: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_BLOB:
    case ItemIndex of
      0: Result := GD_FC_NOT_EMPTY;
      1: Result := GD_FC_EMPTY;
    else
      Result := -1;
    end;

    GD_DT_DATE, GD_DT_TIMESTAMP:
    case ItemIndex of
      0: Result := GD_FC_TODAY;
      1: Result := GD_FC_LAST_N_DAYS;
      2: Result := GD_FC_EQUAL_TO;
      3: Result := GD_FC_NOT_EQUAL_TO;
      4: Result := GD_FC_LESS_THAN;
      5: Result := GD_FC_LESS_OR_EQUAL_TO;
      6: Result := GD_FC_GREATER_THAN;
      7: Result := GD_FC_GREATER_OR_EQUAL_TO;
      8: Result := GD_FC_BETWEEN;
      9: Result := GD_FC_BETWEEN_LIMIT;
      10: Result := GD_FC_OUT;
      11: Result := GD_FC_OUT_LIMIT;
      12: Result := GD_FC_NOT_EMPTY;
      13: Result := GD_FC_EMPTY;
      14: Result := GD_FC_SELDAY;
      15:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      16: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_TIME:
    case ItemIndex of
      0: Result := GD_FC_LESS_THAN;
      1: Result := GD_FC_LESS_OR_EQUAL_TO;
      2: Result := GD_FC_GREATER_THAN;
      3: Result := GD_FC_GREATER_OR_EQUAL_TO;
      4: Result := GD_FC_BETWEEN;
      5: Result := GD_FC_BETWEEN_LIMIT;
      6: Result := GD_FC_OUT;
      7: Result := GD_FC_OUT_LIMIT;
      8: Result := GD_FC_NOT_EMPTY;
      9: Result := GD_FC_EMPTY;
      10:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      11: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_BOOLEAN:
    case ItemIndex of
      0: Result := GD_FC_TRUE;
      1: Result := GD_FC_FALSE;
      2: Result := GD_FC_NOT_EMPTY;
      3: Result := GD_FC_EMPTY;
      4:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          Result := GD_FC_SCRIPT;
      5: Result := GD_FC_SCRIPT;
    else
      Result := -1;
    end;

    GD_DT_ATTR_SET:
    case ItemIndex of
      0: Result := GD_FC_INCLUDES;
      1: Result := GD_FC_ACTUATES;
    else
      Result := -1;
    end;

    GD_DT_ATTR_SET_ELEMENT:
    case ItemIndex of
      0: Result := GD_FC_ACTUATES;
      1: Result := GD_FC_NOT_EMPTY;
      2: Result := GD_FC_EMPTY;
    else
      Result := -1;
    end;

    GD_DT_REF_SET:
    case ItemIndex of
      0: Result := GD_FC_INCLUDES;
      1: Result := GD_FC_ACTUATES;
      2: Result := GD_FC_NOT_ACTUATES;
      3: Result := GD_FC_CUSTOM_FILTER;
      4: Result := GD_FC_COMPLEXFIELD;
      5: Result := GD_FC_NOT_EMPTY;
      6: Result := GD_FC_EMPTY;
      7:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE;
      8:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE;
      9:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_NOT_ACTUATES_TREE
          else
            raise Exception.Create('Can''t belived');
      10: Result := GD_FC_NOT_ACTUATES_TREE;
    else
      Result := -1;
    end;

    GD_DT_CHILD_SET:
    case ItemIndex of
      0: Result := GD_FC_INCLUDES;
      1: Result := GD_FC_ACTUATES;
      2: Result := GD_FC_NOT_ACTUATES;
      3: Result := GD_FC_CUSTOM_FILTER;
      4: Result := GD_FC_NOT_EMPTY;
      5: Result := GD_FC_EMPTY;
      6:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE;
      7:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE;
      8:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_NOT_ACTUATES_TREE
          else
            raise Exception.Create('Can''t belived');
      9: Result := GD_FC_NOT_ACTUATES_TREE;
    else
      Result := -1;
    end;

    GD_DT_REF_SET_ELEMENT:
    case ItemIndex of
      0: Result := GD_FC_ACTUATES;
      1: Result := GD_FC_NOT_ACTUATES;
      2: Result := GD_FC_CUSTOM_FILTER;
      3: Result := GD_FC_NOT_EMPTY;
      4: Result := GD_FC_EMPTY;
      5:
        if Assigned(ParamGlobalDlg) then
          Result := GD_FC_ENTER_PARAM
        else
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE;
      6:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_SCRIPT
          else
            Result := GD_FC_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE;
      7:
        if Assigned(ParamGlobalDlg) then
          if Assigned(FilterScript) then
            Result := GD_FC_ACTUATES_TREE
          else
            Result := GD_FC_NOT_ACTUATES_TREE
        else
          if Assigned(FilterScript) then
            Result := GD_FC_NOT_ACTUATES_TREE
          else
            raise Exception.Create('Can''t belived');
      8: Result := GD_FC_NOT_ACTUATES_TREE;
    else
      Result := -1;
    end;

    GD_DT_FORMULA:
    case ItemIndex of
      0: Result := GD_FC_QUERY_WHERE;
      1: Result := GD_FC_QUERY_ALL;
    else
      Result := -1;
    end;

  else
    Result := -1;
  end;
end;

procedure FillComboCond(const DataType: Integer; var cbCond: TComboBox;
 const IsTree: Boolean);
begin
  cbCond.Clear;
  case DataType of

    GD_DT_DIGITAL:
    begin
      cbCond.Items.Add('�����');                //GD_FC_EQUAL_TO;
      cbCond.Items.Add('�� ����� (<>)');        //GD_FC_NOT_EQUAL_TO;
      cbCond.Items.Add('������ (<)');           //GD_FC_LESS_THAN;
      cbCond.Items.Add('������ ��� ����� (<=)');//GD_FC_LESS_OR_EQUAL_TO;
      cbCond.Items.Add('������ (>)');           //GD_FC_GREATER_THAN;
      cbCond.Items.Add('������ ��� ����� (>=)');//GD_FC_GREATER_OR_EQUAL_TO;
      cbCond.Items.Add('����� ���. �������');   //GD_FC_BETWEEN;
      cbCond.Items.Add('����� ����. �������');  //GD_FC_BETWEEN_LIMIT;
      cbCond.Items.Add('��� ���. �������');     //GD_FC_OUT;
      cbCond.Items.Add('��� ����. �������');    //GD_FC_OUT_LIMIT;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
    end;

    GD_DT_ENUMERATION:
    begin
      cbCond.Items.Add('�����');                //GD_FC_EQUAL_TO;
      cbCond.Items.Add('�� �����');             //GD_FC_NOT_EQUAL_TO;
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
      cbCond.Items.Add('�� ��������');          //GD_FC_NOT_ACTUATES
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
    end;

    GD_DT_CHAR:
    begin
      cbCond.Items.Add('���������� �');         //GD_FC_BEGINS_WITH;
      cbCond.Items.Add('��������');             //GD_FC_CONTAINS;
      cbCond.Items.Add('�� ��������');          //GD_FC_DOESNT_CONTAINS;
      cbCond.Items.Add('������������� ��');     //GD_FC_ENDS_WIT;
      cbCond.Items.Add('�����');                //GD_FC_EQUAL_TO;
      cbCond.Items.Add('�� �����');             //GD_FC_NOT_EQUAL_TO;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
    end;

    GD_DT_BLOB_TEXT:
    begin
      cbCond.Items.Add('��������');             //GD_FC_CONTAINS;
      cbCond.Items.Add('�� ��������');          //GD_FC_DOESNT_CONTAINS;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
    end;

    GD_DT_BLOB:
    begin
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
    end;

    GD_DT_DATE, GD_DT_TIMESTAMP:
    begin
      cbCond.Items.Add('�� �������');           //GD_FC_TODAY;
      cbCond.Items.Add('��������� __ ����');    //GD_FC_LAST_N_DAYS;
      cbCond.Items.Add('�����');                //GD_FC_EQUAL_TO;
      cbCond.Items.Add('�� ����� (<>)');        //GD_FC_NOT_EQUAL_TO;
      cbCond.Items.Add('������ (<)');           //GD_FC_LESS_THAN;
      cbCond.Items.Add('������ ��� ����� (<=)');//GD_FC_LESS_OR_EQUAL_TO;
      cbCond.Items.Add('������ (>)');           //GD_FC_GREATER_THAN;
      cbCond.Items.Add('������ ��� ����� (>=)');//GD_FC_GREATER_OR_EQUAL_TO;
      cbCond.Items.Add('����� ���. �������');   //GD_FC_BETWEEN;
      cbCond.Items.Add('����� ����. �������');  //GD_FC_BETWEEN_LIMIT;
      cbCond.Items.Add('��� ���. �������');     //GD_FC_OUT;
      cbCond.Items.Add('��� ����. �������');    //GD_FC_OUT_LIMIT;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      cbCond.Items.Add('�� ��������� ����');    //GD_FC_SELDAY
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
    end;

    GD_DT_TIME:
    begin
      cbCond.Items.Add('������ (<)');           //GD_FC_LESS_THAN;
      cbCond.Items.Add('������ ��� ����� (<=)');//GD_FC_LESS_OR_EQUAL_TO;
      cbCond.Items.Add('������ (>)');           //GD_FC_GREATER_THAN;
      cbCond.Items.Add('������ ��� ����� (>=)');//GD_FC_GREATER_OR_EQUAL_TO;
      cbCond.Items.Add('����� ���. �������');   //GD_FC_BETWEEN;
      cbCond.Items.Add('����� ����. �������');  //GD_FC_BETWEEN_LIMIT;
      cbCond.Items.Add('��� ���. �������');     //GD_FC_OUT;
      cbCond.Items.Add('��� ����. �������');    //GD_FC_OUT_LIMIT;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');               //GD_FC_SCRIPT;
    end;

    GD_DT_BOOLEAN:
    begin
      cbCond.Items.Add('������');               //GD_FC_TRUE;
      cbCond.Items.Add('����');                 //GD_FC_FALSE;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');               //GD_FC_SCRIPT;
    end;

    GD_DT_ATTR_SET:
    begin
      cbCond.Items.Add('��������');             //GD_FC_INCLUDE;
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
    end;

    GD_DT_ATTR_SET_ELEMENT:
    begin
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
    end;

    GD_DT_REF_SET:
    begin
      cbCond.Items.Add('��������');             //GD_FC_INCLUDE;
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
      cbCond.Items.Add('�� ��������');          //GD_FC_NOT_ACTUATES
      cbCond.Items.Add('����������');           //GD_FC_FILTERING;
      cbCond.Items.Add('���. ����������');      //GD_FC_COMPLEXFIELD
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');               //GD_FC_SCRIPT;
      if IsTree then
      begin
        cbCond.Items.Add('���� ����� ��');      //GD_FC_ACTUATES_TREE;
        cbCond.Items.Add('�� �������� �����');  //GD_FC_NOT_ACTUATES_TREE;
      end;
    end;

    GD_DT_CHILD_SET:
    begin
      cbCond.Items.Add('��������');             //GD_FC_INCLUDE;
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
      cbCond.Items.Add('�� ��������');          //GD_FC_NOT_ACTUATES
      cbCond.Items.Add('����������');           //GD_FC_FILTERING;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
      if IsTree then
      begin
        cbCond.Items.Add('���� ����� ��');      //GD_FC_ACTUATES_TREE;
        cbCond.Items.Add('�� �������� �����');  //GD_FC_NOT_ACTUATES_TREE
      end;
    end;

    GD_DT_REF_SET_ELEMENT:
    begin
      cbCond.Items.Add('���� ��');              //GD_FC_ACTUATES;
      cbCond.Items.Add('�� ��������');          //GD_FC_NOT_ACTUATES
      cbCond.Items.Add('����������');           //GD_FC_FILTERING;
      cbCond.Items.Add('����������');           //GD_FC_NOT_EMPTY;
      cbCond.Items.Add('�� ����������');        //GD_FC_EMPTY;
      if Assigned(ParamGlobalDlg) then
        cbCond.Items.Add('������ ���������');   //GD_FC_ENTER_PARAM;
      if Assigned(FilterScript) then
        cbCond.Items.Add('������');             //GD_FC_SCRIPT;
      if IsTree then
      begin
        cbCond.Items.Add('���� ����� ��');      //GD_FC_ACTUATES_TREE;
        cbCond.Items.Add('�� �������� �����');  //GD_FC_NOT_ACTUATES_TREE
      end;
    end;

    GD_DT_FORMULA:
    begin
      cbCond.Items.Add('������ �������');              //GD_FC_QUERY_WHERE;
      cbCond.Items.Add('������� ������');
    end;

  end;
end;

function GetConditionName(ConditionType: Integer): String;
begin
  case ConditionType of
    GD_FC_EQUAL_TO:             Result := ' ����� ';
    GD_FC_NOT_EQUAL_TO:         Result := ' �� ����� (<>) ';
    GD_FC_LESS_THAN:            Result := ' ������ (<) ';
    GD_FC_LESS_OR_EQUAL_TO:     Result := ' ������ ��� ����� (<=) ';
    GD_FC_GREATER_THAN:         Result := ' ������ (>) ';
    GD_FC_GREATER_OR_EQUAL_TO:  Result := ' ������ ��� ����� (>=) ';
    GD_FC_BETWEEN:              Result := ' ����� ���. ������� ';
    GD_FC_BETWEEN_LIMIT:        Result := ' ����� ����. ������� ';
    GD_FC_OUT:                  Result := ' ��� ���. ������� ';
    GD_FC_OUT_LIMIT:            Result := ' ��� ����. ������� ';
    GD_FC_NOT_EMPTY:            Result := ' ���������� ';
    GD_FC_EMPTY:                Result := ' �� ���������� ';
    GD_FC_BEGINS_WITH:          Result := ' ���������� � ';
    GD_FC_CONTAINS:             Result := ' �������� ';
    GD_FC_DOESNT_CONTAIN:       Result := ' �� �������� ';
    GD_FC_ENDS_WITH:            Result := ' ������������� �� ';
    GD_FC_TODAY:                Result := ' �� ������� ';
    GD_FC_LAST_N_DAYS:          Result := ' ��������� __ ���� ';
    GD_FC_SELDAY:               Result := ' �� ��������� ���� ';
    GD_FC_INCLUDES:             Result := ' �������� ';
    GD_FC_ACTUATES:             Result := ' ���� �� ';
    GD_FC_NOT_ACTUATES:         Result := ' �� �������� ';
    GD_FC_CUSTOM_FILTER:        Result := ' ���������� ';
    GD_FC_TRUE:                 Result := ' ������ ';
    GD_FC_FALSE:                Result := ' ���� ';
    GD_FC_QUERY_WHERE:          Result := ' ������� ������� ';
    GD_FC_QUERY_ALL:            Result := ' ������ ������ ';
    GD_FC_COMPLEXFIELD:         Result := ' ���������� �� ���. ����� ';
    GD_FC_ACTUATES_TREE:        Result := ' ���� ����� �� ';
    GD_FC_NOT_ACTUATES_TREE:    Result := ' �� �������� ����� ';
    GD_FC_SCRIPT:               Result := ' ����� ������ ';
    GD_FC_ENTER_PARAM:           Result := ' ������ ������� ';
  else
    Result := ' ? '
  end;
end;

{ TfltStringList }

function TfltStringList.GetValue(const AnIndex: Integer): String;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  if AnIndex >= 0 then
    Result := Copy(Strings[AnIndex], Length(Names[AnIndex]) + 2, MaxInt)
  else
    Result := '';
end;

procedure TfltStringList.SetValue(const AnIndex: Integer; const Value: String);
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  Strings[AnIndex] := Names[AnIndex] + '=' + Value;
end;

procedure TfltStringList.RemoveDouble;
var
  I, J: Integer;
begin
  I := 0;
  while I < Count - 1 do
  begin
    J := I + 1;
    while J < Count do
      if Strings[I] = Strings[J] then
        Delete(J)
      else
        Inc(J);
    Inc(I);
  end;
end;

function CompareFieldData(const FirstField, SecondField: TfltFieldData): Boolean;
begin
  Result := (FirstField.TableName = SecondField.TableName) and
   (UpperCase(FirstField.TableAlias) = UpperCase(SecondField.TableAlias)) and
   (UpperCase(FirstField.PrimaryName) = UpperCase(SecondField.PrimaryName)) and
   (UpperCase(FirstField.FieldName) = UpperCase(SecondField.FieldName)) and
   (FirstField.FieldType = SecondField.FieldType) and
   (UpperCase(FirstField.LinkTable) = UpperCase(SecondField.LinkTable)) and
   (UpperCase(FirstField.LinkSourceField) = UpperCase(SecondField.LinkSourceField)) and
   (UpperCase(FirstField.LinkTargetField) = UpperCase(SecondField.LinkTargetField)) and
   (FirstField.LinkTargetFieldType = SecondField.LinkTargetFieldType) and
   (UpperCase(FirstField.RefTable) = UpperCase(SecondField.RefTable)) and
   (UpperCase(FirstField.RefField) = UpperCase(SecondField.RefField)) and
   (FirstField.AttrKey = SecondField.AttrKey) and                        {?}
   (FirstField.AttrRefKey = SecondField.AttrRefKey);                     {?}
end;

function CompareConditionData(const FirstCondition, SecondCondition: TFilterCondition): Boolean;
var
  I: Integer;
begin
  Result := True;
  if not CompareFieldData(FirstCondition.FieldData, SecondCondition.FieldData) or
   (FirstCondition.ConditionType <> SecondCondition.ConditionType) or
   (FirstCondition.Value1 <> SecondCondition.Value1) or
   (FirstCondition.Value2 <> SecondCondition.Value2) or
   (FirstCondition.SubFilter.Count <> SecondCondition.SubFilter.Count) or
   (FirstCondition.ValueList.Count <> SecondCondition.ValueList.Count) then
    Result := False
  else
    if (FirstCondition.SubFilter.Count > 0) and
     not CompareConditionList(FirstCondition.SubFilter, SecondCondition.SubFilter) then
      Result := False
    else
      if FirstCondition.ValueList.Count > 0 then
        for I := 0 to FirstCondition.ValueList.Count - 1 do
          if FirstCondition.ValueList.Objects[I] <> SecondCondition.ValueList.Objects[I] then
          begin
            Result := False;
            Break;
          end;
end;

function CompareConditionList(const FirstList, SecondList: TFilterConditionList): Boolean;
var
  I: Integer;
begin
  Result := (FirstList.Count = SecondList.Count) and
   (FirstList.IsAndCondition = SecondList.IsAndCondition);
  if not Result then
    Exit;
  for I := 0 to FirstList.Count - 1 do
  begin
    Result := CompareConditionData(FirstList.Conditions[I], SecondList.Conditions[I]);
    if not Result then
      Exit;
  end;
end;

function CompareOrderByData(const FirstOrderBy, SecondOrderBy: TFilterOrderBy): Boolean;
begin
  Result := (UpperCase(FirstOrderBy.TableName) = UpperCase(SecondOrderBy.TableName)) and
   (UpperCase(FirstOrderBy.TableAlias) = UpperCase(SecondOrderBy.TableAlias)) and
   (UpperCase(FirstOrderBy.FieldName) = UpperCase(SecondOrderBy.FieldName)) and
   (FirstOrderBy.IsAscending = SecondOrderBy.IsAscending);
end;

function CompareOrderByList(const FirstList, SecondList: TFilterOrderByList): Boolean;
var
  I: Integer;
begin
  Result := (FirstList.Count = SecondList.Count) and
   (FirstList.OnlyIndexField = SecondList.OnlyIndexField);
  if not Result then
    Exit;
  for I := 0 to FirstList.Count - 1 do
  begin
    Result := CompareOrderByData(FirstList.OrdersBy[I], SecondList.OrdersBy[I]);
    if not Result then
      Exit;
  end;
end;

function CompareFilterData(const FirstData, SecondData: TFilterData): Boolean;
begin
  Result := CompareConditionList(FirstData.ConditionList, SecondData.ConditionList)
   and CompareOrderByList(FirstData.OrderByList, SecondData.OrderByList);
end;

function GetCondition(const AnTableName, AnFieldName: String): String;
var
  R: TatRelation;
  F: TatRelationField;
begin
  Result := '';
  if Assigned(atDatabase) then
  begin
    R := atDatabase.Relations.ByRelationName(AnTableName);
    if Assigned(R) then
    begin
      F := R.RelationFields.ByFieldName(AnFieldName);
      if Assigned(F) then
        Result := F.Field.RefCondition;
    end;
  end;
end;

procedure SetParams(const LocConditionList: TFilterConditionList; const LocParamList: TgsParamList);
var
  I: Integer;
begin
  for I := 0 to LocConditionList.Count - 1 do
  begin
    case LocConditionList.Conditions[I].ConditionType of
      GD_FC_ENTER_PARAM:
      begin
        LocParamList.AddParam(LocConditionList.Conditions[I].FieldData.LocalField,
         LocConditionList.Conditions[I].Value1, prmInteger, '');
        case LocConditionList.Conditions[I].FieldData.FieldType of
          GD_DT_DIGITAL:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmFloat;
          GD_DT_CHAR:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmString;
          GD_DT_DATE:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmDate;
          GD_DT_TIMESTAMP:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmDateTime;
          GD_DT_TIME:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmTime;
          GD_DT_ENUMERATION:
          begin
            LocParamList.Params[LocParamList.Count - 1].LinkTableName :=
             LocConditionList.Conditions[I].FieldData.TableName;
            LocParamList.Params[LocParamList.Count - 1].LinkDisplayField :=
             LocConditionList.Conditions[I].FieldData.FieldName;
            LocParamList.Params[LocParamList.Count - 1].SortOrder := 1;
            if (LocConditionList.Conditions[I].Value2 = GD_FC2_ACTUATES_ALIAS)
             or (LocConditionList.Conditions[I].Value2 = GD_FC2_NOT_ACTUATES_ALIAS) then
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmEnumSet
            else
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmEnumElement;
          end;
          GD_DT_REF_SET,
          GD_DT_REF_SET_ELEMENT:
          begin
            LocParamList.Params[LocParamList.Count - 1].LinkTableName :=
             LocConditionList.Conditions[I].FieldData.RefTable;
            LocParamList.Params[LocParamList.Count - 1].LinkDisplayField :=
             LocConditionList.Conditions[I].FieldData.DisplayName;
            LocParamList.Params[LocParamList.Count - 1].LinkPrimaryField :=
             LocConditionList.Conditions[I].FieldData.RefField;
            LocParamList.Params[LocParamList.Count - 1].LinkConditionFunction :=
             GetCondition(LocConditionList.Conditions[I].FieldData.TableName,
             LocConditionList.Conditions[I].FieldData.FieldName);
            LocParamList.Params[LocParamList.Count - 1].SortOrder := 1;
            if (LocConditionList.Conditions[I].Value2 = GD_FC2_ACTUATES_ALIAS)
             or (LocConditionList.Conditions[I].Value2 = GD_FC2_NOT_ACTUATES_ALIAS)
             or (LocConditionList.Conditions[I].Value2 = GD_FC2_INCLUDE_ALIAS) then
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmLinkSet
            else
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmLinkElement;
          end;
          GD_DT_CHILD_SET:
          begin
            LocParamList.Params[LocParamList.Count - 1].LinkTableName :=
             LocConditionList.Conditions[I].FieldData.LinkTable;
            LocParamList.Params[LocParamList.Count - 1].LinkDisplayField :=
             LocConditionList.Conditions[I].FieldData.DisplayName;
            LocParamList.Params[LocParamList.Count - 1].LinkPrimaryField :=
             LocConditionList.Conditions[I].FieldData.LinkTargetField;
            LocParamList.Params[LocParamList.Count - 1].LinkConditionFunction :=
             GetCondition(LocConditionList.Conditions[I].FieldData.TableName,
             LocConditionList.Conditions[I].FieldData.FieldName);
            LocParamList.Params[LocParamList.Count - 1].SortOrder := 1;
            if (LocConditionList.Conditions[I].Value2 = GD_FC2_ACTUATES_ALIAS)
             or (LocConditionList.Conditions[I].Value2 = GD_FC2_NOT_ACTUATES_ALIAS)
             or (LocConditionList.Conditions[I].Value2 = GD_FC2_INCLUDE_ALIAS) then
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmLinkSet
            else
              LocParamList.Params[LocParamList.Count - 1].ParamType := prmLinkElement;
          end;
          GD_DT_BOOLEAN:
            LocParamList.Params[LocParamList.Count - 1].ParamType := prmBoolean;
        end;
      end;
      GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
        SetParams(LocConditionList.Conditions[I].SubFilter, LocParamList);
    end;
  end;
end;

procedure GetParams(const LocConditionList: TFilterConditionList; const LocVarResult: Variant; var J: Integer);
var
  I: Integer;
  TempBool: Boolean;
begin
  for I := 0 to LocConditionList.Count - 1 do
    case LocConditionList.Conditions[I].ConditionType of
      GD_FC_ENTER_PARAM:
      begin
        case LocConditionList.Conditions[I].FieldData.FieldType of
          GD_DT_BOOLEAN:
          begin
            TempBool := LocVarResult[J];
            LocConditionList.Conditions[I].FTempVariant := Abs(Integer(TempBool));
          end;
          GD_DT_TIME:
            LocConditionList.Conditions[I].FTempVariant := TimeToStr(LocVarResult[J]);
        else
          LocConditionList.Conditions[I].FTempVariant := LocVarResult[J];
        end;
        Inc(J);
      end;
      GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
        GetParams(LocConditionList.Conditions[I].SubFilter, LocVarResult, J);
    end;
end;

procedure QueryParamsForConditions(const AnFilterComponent, AnFilterKey: Integer;
 const AnConditionList: TFilterConditionList; var AnResult: Boolean; out VarResult: Variant;
 const AShowDlg: Boolean = True; const AFormName: string = ''; const AFilterName: string = '');
var
  LocParamList: TgsParamList;
  J: Integer;
begin
  AnResult := False;
  LocParamList := TgsParamList.Create;
  try
    SetParams(AnConditionList, LocParamList);
    if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
    begin
      ParamGlobalDlg.QueryParams(AnFilterComponent, AnFilterKey, LocParamList,
        AnResult, AShowDlg, AFormName, AFilterName);
    end;
    if AnResult then
    begin
      J := 0;
      VarResult := LocParamList.GetVariantArray;
      GetParams(AnConditionList, VarResult, J);
    end;
  finally
    LocParamList.Free;
  end;
end;

// ������� ��������� SQL
function CreateCustomSQL(AnFilterData: TFilterData; AnSelectText, AnFromText,
  AnWhereText, AnOtherText, AnOrderText, AnQueryText: TStrings;
  AnTableList: TStringList; AnComponentKey, AnCurrentFilter: Integer;
  const AnReQueryParam: Boolean; var AnSilentParams: Variant;
  const AShowDlg: Boolean = True; const AFormName: string = ''; const AFilterName: string = ''): Boolean;
const
  PrefixTbl = ' tbl';
  Sand = ' AND ';
  Sor = ' OR  ';
  OldTime: DWord = 0;

var
  SelectStr, FromStr, WhereStr, OrderStr, PrefixList: TStrings;
  I: Integer;
  TblN: Integer;
  S, UserSQLText: String;
  IsUserQuery, EnterResult: Boolean;

  // ���������� ������� ������� �� �� ������������
  // ��� ���� ������� ������� ������
  function FindTable(const TableName: String; const FlagAll: Boolean): String;
  begin
    // ����� ������������ �������
    Result := PrefixList.Values[TableName];
    if FlagAll and (Result = '') then
      Result := AnTableList.Values[TableName];
    // ���� �� �������, ��������� �����
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

  // ���������� ������� ������� �� �� ������������
  // ������ ����������� �������
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

  // ������� ����� ������� ��� �������
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
        GD_DT_ENUMERATION:
          WhereStr.Add('(' + AnPrefixName + FieldName + AnConfluenceSign + '(' + FValue1 + '))' + MergeSign);
        GD_DT_REF_SET_ELEMENT, GD_DT_ATTR_SET_ELEMENT:
          // ��������� �������
          WhereStr.Add('(' + AnPrefixName + FieldName + AnConfluenceSign + S + ')' + MergeSign);
        GD_DT_REF_SET, GD_DT_CHILD_SET:
        begin
          // ������� ������� �������
          NetN := AddTable(AnConditionData.FieldData.LinkTable);
          // ��������� �������
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + NetN
           + AnConditionData.FieldData.LinkSourceField + Sand);
          WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + AnConfluenceSign
           + S + ')' + MergeSign);
        end;
        GD_DT_ATTR_SET:
        begin
          // ������� ������� �������
          NetN := AddTable('GD_ATTRVALUE');
          // ��������� �������
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
        // ��� ������� ����������� �������� ��������� ������� ����� ���������
        // �������. ������� �� ���������� FindTable
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Add('(');
          for L := 0 to AnConditionData.ValueList.Count - 1 do
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
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
            // ������� ������� �������
            NetN := AddTable('GD_ATTRVALUE');
            // ��������� �������
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

    // �������� �������� �� ��� ''�������������� ����������''
    if (AnConditionData.FieldData.FieldType = GD_DT_UNKNOWN_SET) and AnUnknownSet then
    begin
      CurN := AddTable(AnConditionData.FieldData.LinkTable);
      WhereStr.Add('(' + AnConditionData.FieldData.TableAlias + AnConditionData.FieldData.FieldName + ' = '
       + CurN + AnConditionData.FieldData.LinkSourceField + Sand);
      AddSQLCondition(AnConditionData, CurN, False, AnMergeCondition);
      WhereStr.Strings[WhereStr.Count - 1] :=
       ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
      Result := True;

      Exit;
    end;

    // ��� ���� ������� ��� ����������� ���� ''�������������� ���������''
    {gs} // ����� ������� �������
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
          raise Exception.Create('��������� FilterScript �� ������.');
        FValue1 := FilterScript.GetScriptResult(AnConditionData.Value1, AnConditionData.Value2, FScriptSign);
        FValue2 := '';
      end;
    GD_FC_ENTER_PARAM:
      case FieldType of
        GD_DT_REF_SET_ELEMENT, GD_DT_REF_SET, GD_DT_CHILD_SET,
        GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:;
      else
        if VarType(AnConditionData.FTempVariant) = varDate then
          FValue1 := DateTimeToStr(AnConditionData.FTempVariant)
        else
          FValue1 := AnsiUpperCase(AnConditionData.FTempVariant);
        FValue2 := '';
        FScriptSign := AnConditionData.Value2;
        // ������ LIKE �� CONTAINING
        if (UpperCase(FScriptSign) = 'LIKE') then
          FScriptSign := 'CONTAINING';
        if (UpperCase(FScriptSign) = 'NOT LIKE') then
          FScriptSign := 'NOT CONTAINING';
      end;
    else
      FValue1 := AnConditionData.Value1;
      FValue2 := AnConditionData.Value2;
    end;
    // � ����������� �� ���� ������ �������������� ��������
    // ��� ������� ����� ���-�� ���������� ���������
    case FieldType of
      GD_DT_DIGITAL, GD_DT_BOOLEAN, GD_DT_ENUMERATION:
      begin
        // ������ �����������
        if FValue1 > '' then
          FValue1 := StringReplace(FValue1, ',', '.', []);
        if FValue2 > '' then
          FValue2 := StringReplace(FValue2, ',', '.', []);
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_CHAR:
      begin
        if AnConditionData.ConditionType = GD_FC_SCRIPT then
          FValue1 := AnsiUpperCase(FValue1);
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        SimpleField := 'UPPER(' + AnPrefixName + FieldName + ')';
      end;
      GD_DT_BLOB_TEXT:
      begin
        // ������� ���������
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_DATE, GD_DT_TIMESTAMP:
      begin
        // ��������� � ������ � ���������
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
        // ��������� � ������ � ���������
        if FValue1 > '' then
          FValue1 := '''' + IBTimeToStr(StrToTime(FValue1)) + '''';
        if FValue2 > '' then
          FValue2 := '''' + IBTimeToStr(StrToTime(FValue2)) + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
    end;

    // ���������������� ��������� �������
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
            if not VarIsArray(AnConditionData.FTempVariant) or
             ((VarArrayHighBound(AnConditionData.FTempVariant, 1) -
             VarArrayLowBound(AnConditionData.FTempVariant, 1)) < 0) then
            begin
              Result := True;
              Exit;
            end;

            if (AnsiUpperCase(AnConditionData.Value2) = GD_FC2_INCLUDE_ALIAS) then
            begin
              AnConditionData.ValueList.Clear;
              for J := VarArrayLowBound(AnConditionData.FTempVariant, 1) to
               VarArrayHighBound(AnConditionData.FTempVariant, 1) do
              begin
                VarToPnt := VarAsType(AnConditionData.FTempVariant[J], varInteger);
                AnConditionData.ValueList.AddObject('', Pointer(VarToPnt));
              end;
              DoIncludes;
            end else
            begin
              S := '(';
              for J := VarArrayLowBound(AnConditionData.FTempVariant, 1) to
               VarArrayHighBound(AnConditionData.FTempVariant, 1) do
                S := S + VarAsType(AnConditionData.FTempVariant[J], varString) + ',';
              S[Length(S)] := ')';
              DoActuates(' ' + AnConditionData.Value2 + ' ');
            end;
          end;
          GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
            raise Exception.Create('GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT not supported yet.');
          GD_DT_ENUMERATION:
          begin
            if FValue1 = '' then
            begin
              Result := True;
              Exit;
            end;
            if (AnsiUpperCase(AnConditionData.Value2) = GD_FC2_ACTUATES_ALIAS)
             or (AnsiUpperCase(AnConditionData.Value2) = GD_FC2_NOT_ACTUATES_ALIAS) then
              WhereStr.Add('(' + SimpleField + ' ' + FScriptSign + ' (' + FValue1 + '))' + MergeSign)
            else
              WhereStr.Add('(' + SimpleField + ' ' + FScriptSign + ' ' + FValue1 + ')' + MergeSign);
          end;
        else
          if FValue1 = '' then
          begin
            Result := True;
            Exit;
          end;
          WhereStr.Add('(' + SimpleField + ' ' + FScriptSign + ' ' + FValue1 + ')' + MergeSign);
        end;

      // ��� ����� ���������
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
      // ������� �����
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
      // ������� ���
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

      // ������� ������������ ��������� ��� ����
      GD_FC_QUERY_WHERE:
        WhereStr.Add('(' + AnConditionData.Value1 + ')' + MergeSign);
      // ����������
      GD_FC_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('NOT EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add('(' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);

      // �� ����������
      GD_FC_NOT_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add(' NOT (' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);
      // ������������� ��
      GD_FC_ENDS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName + ') LIKE ''%'
         + AnsiUpperCase(AnConditionData.Value1) + ''')' + MergeSign);
      // ��������
      GD_FC_CONTAINS:
        if FieldType = GD_DT_BLOB_TEXT then
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnConditionData.Value1 + '%'')' + MergeSign)
        else
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // ���������� �
      GD_FC_BEGINS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName
         + ') LIKE ''' +  AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // �� �������
      GD_FC_TODAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + IBDateToStr(Trunc(Now)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // �� ��������� ����
      GD_FC_SELDAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + AnConditionData.Value1 + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(StrToDate(AnConditionData.Value1) + 1) + ''')' + MergeSign);
        end;
      // �� ��������� N ����
      GD_FC_LAST_N_DAYS:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= '''
           + IBDateToStr(Trunc(Now) - StrToInt(AnConditionData.Value1)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // ������
      GD_FC_TRUE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 1)' + MergeSign);
      // ����
      GD_FC_FALSE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 0)' + MergeSign);

      // ��������
      GD_FC_INCLUDES:
        DoIncludes;

      // �������������� ����������
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

      // ������� ����������
      GD_FC_CUSTOM_FILTER:
      case FieldType of
      // ����������, ���� ������� ���������
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

      // ����������, ���� ���������
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
        // ���������� ��������� ���������
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

      // �� �������� �����
      GD_FC_NOT_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // ��������� �������
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
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            FValue1 := GetNextPrefix;
            // ��������� �������
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
            // ��������� �������
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + FValue1 + AnConditionData.FieldData.LinkTargetField + '))' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // ��������� �������
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

      // ���� ����� ��
      GD_FC_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // ��������� �������
            WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + CurN +
             AnConditionData.FieldData.RefField + Sand);
            WhereStr.Add(NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder +
             ')' + MergeSign);
          end;
          GD_DT_REF_SET:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // ��������� �������
            WhereStr.Add('(' + NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + NetN + AnConditionData.FieldData.LinkTargetField + Sand);
            WhereStr.Add(AnPrefixName + FieldName + ' = '
             + NetN + AnConditionData.FieldData.LinkSourceField + ')' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            CurN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
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

      // �� ��������
      GD_FC_NOT_ACTUATES:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        DoActuates(' NOT IN ');
      end;

      // ���� ��
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

  // ��������� �������� �� ������� �������� ������������
  function CheckUserQuery(const AnConditionList: TFilterConditionList; out AnUserSQLText: String): Boolean;
  begin
    Result := (AnConditionList.Count = 1) and
     (AnConditionList.Conditions[0].FieldData.FieldType = GD_DT_FORMULA) and
     (AnConditionList.Conditions[0].ConditionType = GD_FC_QUERY_ALL);
    if Result then
      AnUserSQLText := AnConditionList.Conditions[0].Value1;
  end;

  function ParamQueryNeeded(AnConditionList: TFilterConditionList): Boolean;
  var
    CondCount: Integer;
    Flag1, Flag2: Boolean;
  begin
    Flag2 := False;
    Flag1 := True;
    for CondCount := 0 to AnConditionList.Count - 1 do
    begin
      case AnConditionList.Conditions[CondCount].ConditionType of
        GD_FC_ENTER_PARAM:
          Flag2 := True;
        GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
          Flag2 := ParamQueryNeeded(AnConditionList.Conditions[CondCount].SubFilter);
      end;
      // ���� ����������� ������������� � ����� �������� �� �������
      if Flag2 then
      begin
        if AnReQueryParam then
          Break
        else
          Flag1 := Flag1 and not (VarIsNull(AnConditionList.Conditions[CondCount].FTempVariant) or
           (VarType(AnConditionList.Conditions[CondCount].FTempVariant) = varEmpty));
      end;
      Flag2 := False;
      if not Flag1 then
        Break;
    end;
    Result := not Flag1 or Flag2;
  end;

  // ������� ��������� DISTINCT � ����� �������
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

var
  L: Integer;
begin
  Result := False;

  // ������� ����������� ������
  SelectStr := TStringList.Create;
  FromStr := TStringList.Create;
  WhereStr := TStringList.Create;
  OrderStr := TStringList.Create;
  PrefixList := TStringList.Create;
  try
    // ��������� ���������
    TblN := 0;
    try
      IsUserQuery := CheckUserQuery(AnFilterData.ConditionList, UserSQLText);

      if not IsUserQuery then
      begin

        // ��������� ������� ���� �� ������ ���������
        if ParamQueryNeeded(AnFilterData.ConditionList) then
        begin
          if VarType(AnSilentParams) = varArray then
          begin
            L := 0;
            GetParams(AnFilterData.ConditionList, AnSilentParams, L);
          end else
          begin
            if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
            begin
              QueryParamsForConditions(AnComponentKey, AnCurrentFilter,
                AnFilterData.ConditionList, EnterResult, AnSilentParams, AShowDlg, AFormName, AFilterName);
              // ��� ����� ���������� ��� ������ ������ �������� ������!!!
              if not EnterResult then
                Exit;
            end else
              raise Exception.Create('��������� FilterDlg �� ������');
          end;
        end else
        begin
          if AShowDlg then
          begin
            if Assigned(AnFilterData)
              and (AnFilterData.ConditionList.Count > 0)
              and ((GetTickCount - OldTime) > 2200)
              and (not FSuppressWarning)
              {$IFDEF GEDEMIN}
              and (gdSplash = nil)
              and Assigned(UserStorage)
              and UserStorage.ReadBoolean('Options', 'FilterParams', True, False)
              {$ENDIF}
              then
            begin
              MessageBox(0,
                PChar('� ������ �������� ������.'#13#10#13#10 +
                '������ ��������� �������� ��������������.'#13#10 +
                '��������� ��� �� ������ � ���� �����,'#13#10 +
                '������� ������ �������� ���� ���������.'),
                '����������',
                MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
            end;
            OldTime := GetTickCount;
          end;
        end;

        // ������� ������ ������� ����������
        for I := 0 to AnFilterData.ConditionList.Count - 1 do
        begin
          AddSQLCondition(AnFilterData.ConditionList.Conditions[I],
           AnFilterData.ConditionList.Conditions[I].FieldData.TableAlias, True,
           AnFilterData.ConditionList.IsAndCondition);
        end;

        // ������� ������ ������� ����������
        if AnFilterData.OrderByList.Count > 0 then
        begin
          // ��� ������� ��� ����, ����� ���������� �� �������� ����������
          OrderStr.Add('ORDER BY');
          for I := 0 to AnFilterData.OrderByList.Count - 1 do
          begin
            if I > 0 then
              OrderStr.Add(', ');
            if AnFilterData.OrderByList.OrdersBy[I].IsAscending then
              S := ' ASC'
            else
              S := ' DESC';
            OrderStr.Add(AnFilterData.OrderByList.OrdersBy[I].TableAlias
             + AnFilterData.OrderByList.OrdersBy[I].FieldName + S);
          end;
        end;

        // ����������� ������� ��� ���������� ����� ���������� ������� � ������ ���������
        if (AnFilterData.ConditionList.Count > 0) and (WhereStr.Count > 0) then
        begin
          // ���� ���������� ������� ��������� �������
          if Trim(AnWhereText.Text) = '' then
            WhereStr.Insert(0, 'WHERE (')
          else
            WhereStr.Insert(0, Sand + '(');
          // ������� ��������� AND
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')');
        end;
      end;

      // ������� ����� �������
      AnQueryText.Clear;
      if IsUserQuery then
      begin
        AnQueryText.Text := cQueryAlias;
        AnQueryText.Add(UserSQLText);
      end else
      begin
        AnQueryText.Add(cQueryAlias);
        AnQueryText.AddStrings(AnSelectText);
        AnQueryText.AddStrings(SelectStr);
        AnQueryText.AddStrings(AnFromText);
        AnQueryText.AddStrings(FromStr);
        AnQueryText.AddStrings(AnWhereText);
        AnQueryText.AddStrings(WhereStr);
        AnQueryText.AddStrings(AnOtherText);
        if AnCurrentFilter = 0 then
          AnQueryText.AddStrings(AnOrderText);
        AnQueryText.AddStrings(OrderStr);
        if AnFilterData.ConditionList.IsDistinct then
          AnQueryText.Text := AddDistinct(AnQueryText.Text);
      end;
      Result := True;
    except
      // ���� ������ ��������� ������������ ������ ��� ������� �������
      // ����� ���������� ������ ��� ���������� ������� ������� ������������
      // ��������� ������ ��������, ����� �� �������� �� ������� ��������
      on E: Exception do
        MessageBox(0, PChar('��������� ������ ��� �������� �������: ' + E.Message),
         '������', MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  finally
    // ����������� ������������ ������
    SelectStr.Free;
    FromStr.Free;
    WhereStr.Free;
    OrderStr.Free;

    PrefixList.Free;
  end;
end;

end.
