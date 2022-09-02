// ShlTanya, 07.10.2019
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    gdcInvMovement.pas

  Abstract

    Business class. Inventory movement and remains.

  Author

    Shoihet Michael (17-09-2001)

  Revisions history

    Initial  17-09-2001  Michael  Initial version.
    Changed  29-10-2001  Michael  Minor Change
    Changed  13-11-2001  Michael  ��������� ����� ������ � ���������.
    Changed  15-05-2002  Michael  ��������� �������� �������������� �������� ��� ��������� ���-��

--}

unit gdcInvMovement;

{TODO 1 -oMikle: ���������� ������� ��� �������������� �������� �������� ��� ����������� ������}
{DONE 2 -oMikle: ��� ��������� ��������� �������� ���������� ������ ����� �� ������ ��� ���}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IB, IBCustomDataSet, gdcBase, gdcClasses, gdcInvConsts_unit, IBSQL,
  at_classes, gdcGood, Math, iberrorcodes, IBDataBase, gd_createable_form,
  gdc_createable_form, gdcBaseInterface, gdv_InvCardConfig_unit, gdcAcctConfig,
  gsIBGrid, gdcExplorer, gdcFunction, prm_ParamFunctions_unit, rp_report_const,
  gdcConstants, gd_security_operationconst, Storages, gd_i_ScriptFactory;

const
  cst_ByGoodKey = 'ByGoodKey';
  cst_ByGroupKey = 'ByGroupKey';
  cst_AllRemains = 'AllRemains';
  cst_Holding = 'ByHolding';
  cFunctionName = 'InvCardReportScriptFuction%s';

type
// ��������� ��� �������� ��������� ��������
  TgdcChooseCard = record
    ccCardKey: TID;                            // ��� ��������
    ccQuantity: Currency;                          // ����������
  end;

// ��������� ��� �������� �������� �������� ��������
  TgdcInvCardFeature = record
    optFieldName: String;                          // ������������ ���� ���������
    optValue: Variant;                             // �������� ��������
    optID: TID;
    isID: Boolean;
    isNull: Boolean;
  end;

  TgdcArrInvFeatures = array of TgdcInvCardFeature;

// ��������� ��� �������� �������� ��������
//  PgdcCardValue = ^TgdcCardValue;
  TgdcCardValue = record
    cvalFirstDocumentKey: TID;                   // ��� ������� ��������
    cvalDocumentKey: TID;                        // ��� ��������, ������� ������ ��������
    cvalFirstDate: TDate;                            // ���� ������� ��������� ��������
    cvalCardKey: TID;                            // ��� ��������
    cvalGoodKey: TID;                            // ��� ������
    cvalQuantity: Currency;                          // ����������
    cvalQuantPack: Currency;                         // ���������� ��������
    cvalContactKey: TID;                         // �������
    cvalInvCardFeatures: array of TgdcInvCardFeature;  // ������ ��������� ��������
  end;

  TgdcTypeCheckRemains = (tcrNone, tcrSource, tcrDest);
  TgdcTypeChecksRemains = set of TgdcTypeCheckRemains;

// ��������� ��� �������� �������� ������� ���������
  TgdcInvPosition = record
    ipDocumentKey: TID;                        // ��� ������� ���������
    ipDocumentDate: TDate;                         // ���� ��������
    ipGoodKey: TID;                            // ��� ������
    ipQuantity: Currency;                          // ����������
    ipBaseCardKey: TID;                        // ������� ��������
    ipSourceContactKey: TID;                   // ������� ��������
    ipDestContactKey: TID;                     // ������� ����������
    ipCheckRemains: TgdcTypeChecksRemains;         // ��� �������� ��������
    ipMovementDirection: TgdcInvMovementDirection; // ��� �������� �������
    ipOneRecord: Boolean;                          // ������� ������� ����� ������ � ��������

    ipDelayed: Boolean;                            // ���������� ��������
    ipMinusRemains: Boolean;                       // ����� �� ������������� ��������

// � ������ �������� ����������� ��������� - ���� ����� ipBaseCardKey - �� ������ �� ������
// ���� ipBaseCardKey �� ����� �� �� ������� ��������� �������� (�� �������� �� �����������)
// ���� ��������� �������� ����������� � �������.

    ipInvSourceCardFeatures: array of TgdcInvCardFeature;// ������ ������� ���������
    ipInvDestCardFeatures: array of TgdcInvCardFeature;  // ������ ����� �������
    ipInvMinusCardFeatures: array of TgdcInvCardFeature;  // ������ ������� ��� ������ ��
                                                          // ��������� ��������

    ipSubSourceContactKey: TID;                // ������� �������������� ������ ����������
    ipSubDestContactKey: TID;                  // ������� �������������� ������ �����������

    ipPredefinedSourceContact: array of TID;   // ������ ����������������� ����������
    ipPredefinedDestContact: array of TID;     // ������ ����������������� �����������

    ipSubPredefinedSourceContact: array of TID;   // ������ ����������������� ����������� ����������
    ipSubPredefinedDestContact: array of TID;     // ������ ����������������� ����������� �����������

  end;

// ��� ���������� � ��������
  TgdcChangeMovement = (cmSourceContact, cmDestContact, cmQuantity, cmGood,
    cmSourceFeature, cmDestFeature, cmDate);
  TgdcChangeMovements = set of TgdcChangeMovement;
  TInvRemainsSQLType = (irstSubSelect, irstSimpleSum);
  TIntegerArr = array of Integer;
  TIDArr = array of TID;
  TTypePosition = (tpAll, tpDebit, tpCredit);

type
  TgdcInvRemains = class;

  TgdcInvMovement = class(TgdcBase)
  private
    FibsqlCardInfo: TIBSQL;           // ������ ��� ��������� ���������� �� ��������
    ibsqlLastRemains: TIBSQL;
    ibsqlCardList: TIBSQL;
    FibsqlAddCard: TIBSQL;            // ������ ��� ���������� ��������
    FgdcDocumentLine: TgdcDocument;   // ������� ���������
    FCurrentRemains: Boolean;         // ������� ������� �������� (� ��������� ������ ������� �� ����
    FInvErrorCode: TgdcInvErrorCode;  // ��� ������
    FInvErrorMessage: String;         // ����� ������������ ������
    FIsCreateMovement: Boolean;       // ����������� �� �������� ��� ���������� �������
    FIsLocalPost: Boolean;
    FIsGetRemains: Boolean;
    FCountPositionChanged: Integer;            // Post ������� ������ � ����� �������
    FShowMovementDlg: Boolean;
    FNoWait: Boolean;

    FUseSelectFromSelect: Boolean;
    FEndMonthRemains: Boolean;

// ��������� ������������� ��������
    procedure InitIBSQL;

// ������� ��������� ������� ��������������� �������� �� �������� � ��������
// aContactKey - ������� �� �������� ����������� ��������
// aCardKey - �������� �� ������� ����������� ��������
// aExcludeDocumentKey - ��� ���������, ������� ����������� �� ��������
   function IsMovementExists(const aContactKey, aCardKey,
     aExcludeDocumentKey: TID; const aDocumentDate: TDateTime = 0): Boolean;

// ������� ��� �������� �������������� �����������

// ������� ���������� ���������� �� ������� ���������
// aDocumentKey - ��� ������� �������
    function GetQuantity(const aDocumentKey: TID; TypePosition: TTypePosition): Currency;

// ������� ���������� ������� ������� �� �������� � ��������
// aCardKey - ��� ��������
// aContactKey - ��� �������
    function GetLastRemains(const aCardKey, aContactKey: TID): Currency;

// ������� ���������� ������� �� �������� �� ��������� ����
// aCardKey - ��� ��������
// aContactKey - ��� ��������
// aDate - ����
    function GetRemainsOnDate(const aCardKey, aContactKey: TID;
       aDate: TDateTime): Currency;

// ������� ���������� �������� ��������
// ���� ���������� �������� �� �������� �� ������������ False
    function GetCardInfo(const aCardKey: TID): Boolean;

//  ������� ���������� ��������� �������� �������� ��������, � ������������� �����������
//  aSourceCardKey - ��� �������� ��������
//  aDestGoodKey - ������������ �����
//  aDestInvCardFeatures - ������������ ���������
    function CompareCard(const aSourceCardKey, aDestGoodKey: TID;
      var aDestInvCardFeatures: array of TgdcInvCardFeature): Boolean;

// �������� ����� �������� AddInvCard
//    SourceCardKey - ��� ����� ��������
//    InvPosition   - ��������� ��� �������� �������� �������
    function AddInvCard(SourceCardKey: TID; var InvPosition: TgdcInvPosition;
      const isDestCard: Boolean = True): TID;

// ��������� ������� �������� ModifyInvCard
//    SourceCardKey - ��� ���������� ��������
//    CardFeatures   - ������ ���������� ���������
    function ModifyInvCard(SourceCardKey: TID;
      var CardFeatures: array of TgdcInvCardFeature; const ChangeAll: Boolean = False): Boolean;

// ��������� 1-�� ����������� ��������
//   CardKey - ��� ��������
//   InvPosition - ���������� � �������
    function ModifyFirstMovement(const CardKey: TID;
       var InvPosition: TgdcInvPosition): Boolean;
       
// ��������� ������� � ��������
// MakeCardListSQL - ��������� ��������� ������ ��� ������ �������� � ���������
// InvCardFeatures  - ������ ��������� ��������, ����������� � ���������
// MovementDirection - ��� ��������
    function MakeCardListSQL(MovementDirection: TgdcInvMovementDirection;
    var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;
    function MakeCardListSQL_New(MovementDirection: TgdcInvMovementDirection;
      var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;

//  AddOneMovement - ������� ���������� ����� ������� ��������
//     SourceCardKey - ��� ����� �������� (���� ��� �� -1)
//     Quantity - ����������
//     invPosition - ���������� � ������� ���������
    function AddOneMovement(aSourceCardKey: TID; aQuantity: Currency;
      var invPosition: TgdcInvPosition): Boolean;

//  EditMovement - ������� ����������� ��� ������������ ��������
//  ChangeMove - ������� ����� �������� �����������
//  InvPosition - ���������� � ������� ���������
// gdcInvPositionSaveMode - ��� ������������ ��������
//   (����������������� �� ���� �������� ��� ���������� ����� �������)
    function EditMovement(ChangeMove: TgdcChangeMovements;
       var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
// EditDateMovement - ������� �������� ���� �������� ���, ��� ���� ��������
//                    ����������� ������ ���������
//  InvPosition - ���������� � ������� ���������
// gdcInvPositionSaveMode - ��� ������������ ��������
//   (����������������� �� ���� �������� ��� ���������� ����� �������)
    function EditDateMovement(var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;


//  MakeMovementFromPosition - ��������� �������� �� ��������� �������
//     InvPosition - ������ �� ���������� ������� ���������
// gdcInvPositionSaveMode - ��� ������������ ��������
//   (����������������� �� ���� �������� ��� ���������� ����� �������)
    function MakeMovementFromPosition(var InvPosition: TgdcInvPosition;
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;


//  FillPosition - ��������� ��������� ������ �� �������
//  gdcDocumentLine - ������� ���������
//  InvPosition - ������ �� ���������� ������� ���������
    procedure FillPosition(gdcDocumentLine: TgdcDocument; var InvPosition: TgdcInvPosition);

//  MakePosition - ��������� ��������� ������� �� ��������� ��������
//    procedure MakePosition(gdcInvRemains: TgdcInvRemains; const isAppend: Boolean = True);

//  ShowRemains - �������� ��������
    function ShowRemains(var InvPosition: TgdcInvPosition; const isPosition: Boolean): Boolean;

//  SetEnableMovement - ������������� disabled
    function SetEnableMovement(const aDocumentKey: TID;
      const isEnabled: Boolean): Boolean;

// DeleteEnableMovement - ������� �������� ������ �� disabled
    function DeleteEnableMovement(const aDocumentKey: TID;
      const isEnabled: Boolean): Boolean;
// CheckMovement - �������� �� �������� � ������ ��������� �������

// ���� ���������� �������� ��������, �� �� ������ ���������, ����������� �� ������
// �������� � �������� � ������� ���������� �������� �������� ������������ �������
// ���� ����� �������� ���� �� ������ �������� ��������� �������� �� ������� ����������
// � ���� ����� ���� �� ���������� ��, ���� ��� �� ��� ������ ������ ��� �� ���� � ������
// �������� ������ �������� �� ���� ���������������. (���� � ��� ��� ���� � �������� ����
// ������ �������� �� �� ������ ����������� ���-�� ��� ��������� ��� ������ ������ � ������ ������
// � ����� ������ ��������� ��� ���������)

// InvPosition - �������� ������� ������ ���������
// aCardKey - ��� ������� ��������
    function CheckMovementOnCard(const aCardKey: TID;
      var InvPosition: TgdcInvPosition): Boolean;

// MakeMovementLine - ������� ����� �������� �� ���������� ����������
// Quantity - ���������� �� ������� ���������� ������� ��������
// InvPosition - �������� ������� ������ ���������
// gdcInvPositionSaveMode - ��� ������������ ��������
//   (����������������� �� ���� �������� ��� ���������� ����� �������)
    function MakeMovementLine(Quantity: Currency; var InvPosition: TgdcInvPosition;
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
    function GetIsGetRemains: Boolean;
    procedure SetIsGetRemains(const Value: Boolean);
    function GetCardDocumentKey(const CardKey: TID): TID;

    function IsReplaceDestFeature(ContactKey, CardKey, DocumentKey: TID;
                ChangedField: TStringList; var InvPosition: TgdcInvPosition): Boolean;

    // ��������� ������ ��� ������� GetRemains, � ����������� �� ������ �������
    function GetRemains_GetQueryOld(InvPosition: TgdcInvPosition): String;
    function GetRemains_GetQueryNew(InvPosition: TgdcInvPosition): String;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforeOpen; override;
    procedure _DoOnNewRecord; override;

    procedure CreateFields; override;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure SetSubSet(const Value: TgdcSubSet); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    // ������� ������ ���������
    function SelectGoodFeatures: Boolean;

// ������� ���������� �������� �� ������� ���������
// gdcInvPositionSaveMode - �������� ����������� ��� ���������� ��������� ��� ��� ������ �������

    function CreateMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;

// ������� ���������� �������� �� ���� �������� ���������
    function CreateAllMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument;
      const IsOnlyDisabled: Boolean = False): Boolean;

// ������� ���������� ������� �� ������� � �������� ����������
// isCurrentReamins - ��������� ������� ������� (�� ������� �� ����)
    function GetRemains: Currency;

// ������� ������� ���� � �������� ��� ������ ��������
// IsMakePosition - ����������� �� ������� ����� ������
    function ChooseRemains(const isMakePosition: Boolean = True): Boolean;

    procedure ClearCardQuery;

//  ��� ������
    property InvErrorCode: TgdcInvErrorCode read FInvErrorCode;
    property CountPositionChanged: Integer read FCountPositionChanged;
    property IsGetRemains: Boolean read GetIsGetRemains write SetIsGetRemains;
    property NoWait: Boolean read FNoWait write FNoWait;

    property ShowMovementDlg: Boolean read FShowMovementDlg write FShowMovementDlg default True;
  published
    // ������� ���������
    property gdcDocumentLine: TgdcDocument read FgdcDocumentLine write FgdcDocumentLine;
    property CurrentRemains: Boolean read FCurrentRemains write FCurrentRemains default True;
    property EndMonthRemains: Boolean read FEndMonthRemains write FEndMonthRemains default False;
  end;

{ TgdcInvBaseRemains - ������� ����� ��� ������ � ��������� }

  TgdcInvBaseRemains = class(TgdcBase)
  private
    FRemainsDate: TDateTime;
    FViewFeatures: TStringList;
    FSumFeatures: TStringList;
    FGoodViewFeatures: TStringList;
    FGoodSumFeatures: TStringList;
    FRestrictRemainsBy: String;

    FCurrentRemains: Boolean;
    FRemainsSQLType: TInvRemainsSQLType;
    FIsMinusRemains: Boolean;
    FIsNewDateRemains: Boolean;
    FIsUseCompanyKey: Boolean;

    FUseSelectFromSelect: Boolean;
    FEndMonthRemains: Boolean;

    procedure SetViewFeatures(const Value: TStringList);
    procedure SetSumFeatures(const Value: TStringList);
    procedure ReadFeatures(FFeatures: TStringList; Stream: TStream);
    procedure ReadGoodFeatures(FFeatures: TStringList; Stream: TStream);
    procedure SetGoodSumFeatures(const Value: TStringList);
    procedure SetGoodViewFeatures(const Value: TStringList);
    procedure SetCurrentRemains(const Value: Boolean);

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure SetActive(Value: Boolean); override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure SetSubType(const Value: TgdcSubType); override;

    procedure DoBeforeInsert; override;

    procedure CreateFields; override;

  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListTableAlias: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function IsAbstractClass: Boolean; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
    function GetRemainsName: String;

// ����� ������� �������� ����������� ��� ����������� ��������
    property ViewFeatures: TStringList read FViewFeatures write SetViewFeatures;
// ����� ������� �������� �� ������� ���������� ������������ ������������
    property SumFeatures: TStringList read FSumFeatures write SetSumFeatures;
// ����� ������� �������� ����������� ��� ����������� ��������
    property GoodViewFeatures: TStringList read FGoodViewFeatures write SetGoodViewFeatures;
// ����� ������� �������� �� ������� ���������� ������������ ������������
    property GoodSumFeatures: TStringList read FGoodSumFeatures write SetGoodSumFeatures;

// ��� ���������������� ������� (� ����������� ��� �����)
    property RemainsSQLType: TInvRemainsSQLType read FRemainsSQLType write FRemainsSQLType;

// ���� �� ������� ����������� �������
    property RemainsDate: TDateTime read FRemainsDate write FRemainsDate;
// �������� ������� �������
    property CurrentRemains: Boolean read FCurrentRemains write SetCurrentRemains;
// ��������� �� ������� �� ����� ������
    property EndMonthRemains: Boolean read FEndMonthRemains write FEndMonthRemains;
// ������������ ��� ������� �������� �� ���� ������ ��������� INV_GETCARDMOVEMENT
    property IsNewDateRemains: Boolean read FIsNewDateRemains write FIsNewDateRemains;
    property IsMinusRemains: Boolean read FIsMinusRemains write FIsMinusRemains;
    property IsUseCompanyKey: Boolean read FIsUseCompanyKey write FIsUseCompanyKey;
    property UseSelectFromSelect: Boolean read FUseSelectFromSelect;
// ���������� ����� �������� �� ���������
    property RestrictRemainsBy: String read FRestrictRemainsBy write FRestrictRemainsBy;
  published
    property OnAfterInitSQL;
  end;


{ TgdcInvRemains - ����� ��� ������ � ��������� }

  TgdcInvRemains = class(TgdcInvBaseRemains)
  private
    FGroupKey: TID;
    FGoodKey: TID;
    FChooseFeatures: TgdcArrInvFeatures;
    FIsDest: Boolean;

    FCheckRemains: Boolean;
    FDepartmentKeys: TIDArr;
    FSubDepartmentKeys: TIDArr;
    FIncludeSubDepartment: Boolean;
    FContactType: Integer;
    FgdcDocumentLine: TgdcDocument;

    function GetCountPosition: Integer;
    procedure AddPosition;
    procedure SetgdcDocumentLine(const Value: TgdcDocument);

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure DoAfterPost; override;
    procedure DoBeforePost; override;

    procedure SetOptions_New; virtual;

    procedure DoBeforeOpen; override;

  public
    PositionList: array of TgdcCardValue;

    constructor Create(anOwner: TComponent); override;

    procedure ClearPositionList;

    procedure SetOptions(var InvPosition: TgdcInvPosition;
      InvMovement: TgdcInvMovement; const isPosition: Boolean; const isDest: Boolean = False);

    procedure RemovePosition;

    procedure SetDepartmentKeys(const Value: array of TID);
    procedure SetSubDepartmentKeys(const Value: array of TID);

// �������� ��� ������ ���� � ��������� � ������
// ���������� ��������� �������
    property CountPosition: Integer read GetCountPosition;

// ����� ������� �������� �� ������� ��������������� �����������
    property ChooseFeatures: TgdcArrInvFeatures read FChooseFeatures;

// ��� ������ �� �������� ��������� ������� (���� -1 �� �� ���� ���)
    property GoodKey: TID read FGoodKey write FGoodKey;
// ��� ������ �� ������� ��������� ������� (���� -1 �� �� ���� �������)
    property GroupKey: TID read FGroupKey write FGroupKey;
// ���� ������������� �� ������� ��������� �������
    property DepartmentKeys: TIDArr read FDepartmentKeys;
// ���� ������� ������������� �� ������� ��������� �������
    property SubDepartmentKeys: TIDArr read FSubDepartmentKeys;
// �������� ��������� �������������
    property IncludeSubDepartment: Boolean read FIncludeSubDepartment write FIncludeSubDepartment;
// ��� �������� �� �������� ��������� �������
    property ContactType: Integer read FContactType write FContactType;
// �������� �������� ��� ������
    property CheckRemains: Boolean read FCheckRemains write FCheckRemains;
    property gdcDocumentLine: TgdcDocument read FgdcDocumentLine write SetgdcDocumentLine;
  end;

  TgdcInvGoodRemains = class(TgdcInvRemains)
  protected
    procedure SetOptions_New; override;
  end;

  TgdcInvCard = class(TgdcBase)
  private
    FViewFeatures: TStringList;
    FgdcInvRemains: TgdcInvBaseRemains;
    FRemainsFeatures: TStringList;
    FgdcInvDocumentLine: TgdcDocument;
    FIgnoryFeatures: TStringList;
    FieldPrefix: String;
    FIsHolding: Integer;
    FContactKey: TID;
    procedure SetViewFeatures(const Value: TStringList);
    procedure SetRemainsFeatures(const Value: TStringList);
    procedure SetIgnoryFeatures(const Value: TStringList);
    procedure SetFeatures(DataSet: TDataSet; Prefix: String;
      Features: TgdcInvFeatures);
    function IsHolding: Boolean;
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;
    function GetGroupClause: String; override;

    function GetRefreshSQLText: String; override;
    procedure DoOnNewRecord; override;
  public

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    procedure ReInitialized;
    function GetRemainsOnDate(DateEnd: TDateTime; IsCurrent: Boolean; const AContactKeys: string = ''): Currency;
    procedure SetRemainsConditions;
    procedure SetDocumentLineConditions;

    property ViewFeatures: TStringList read FViewFeatures write SetViewFeatures;
    property RemainsFeatures: TStringList read FRemainsFeatures write SetRemainsFeatures;
    property IgnoryFeatures: TStringList read FIgnoryFeatures write SetIgnoryFeatures;
    property gdcInvRemains: TgdcInvBaseRemains read FgdcInvRemains write FgdcInvRemains;
    property gdcInvDocumentLine: TgdcDocument read FgdcInvDocumentLine write FgdcInvDocumentLine;
    property ContactKey: TID read FContactKey write FContactKey;

  end;

  TgdcInvRemainsOption = class(TgdcBase)
  private
    FSumFeatures: TgdcInvFeatures;
    FViewFeatures: TgdcInvFeatures;
    FGoodViewFeatures: TgdcInvFeatures;
    FGoodSumFeatures: TgdcInvFeatures;
    FRestrictRemainsBy: String;

    procedure UpdateExplorerCommandData(
      MainBranchName, CMD, CommandName, DocumentID, ClassName: String;
      const ShouldUpdateData: Boolean = False;
      const MainBranchKey: TID = -1);

  protected
    procedure _DoOnNewRecord; override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    function GetNotCopyField: String; override;
    procedure DoBeforePost; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure ReadOptions;
    procedure WriteOptions;

    property SumFeatures: TgdcInvFeatures read FSumFeatures;
    property ViewFeatures: TgdcInvFeatures read FViewFeatures;
    property GoodViewFeatures: TgdcInvFeatures read FGoodViewFeatures;
    property GoodSumFeatures: TgdcInvFeatures read FGoodSumFeatures;
    property RestrictRemainsBy: String read FRestrictRemainsBy;
  end;

  TgdcInvCardConfig = class(TgdcBaseAcctConfig)
  private
    FConfig: TInvCardConfig;

    function GetConfig: TInvCardConfig;
    function GetIPCount: integer;

  protected
    procedure DeleteSF;
    procedure CreateSF;
    procedure CreateCommand(SFRUID: TRUID);
    procedure DeleteCommand(SFRUID: TRUID);

    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure _DoOnNewRecord; override;
    procedure DoAfterScroll; override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function GetGDVViewForm: string;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure SaveConfig;
    procedure LoadConfig;
    procedure SaveGrid(Grid: TgsIBGrid);
    procedure ClearGrid;

    property Config: TInvCardConfig read GetConfig;
    property InputParamsCount: integer read GetIPCount;
  end;

type
  EgdcInvMovement = class(Exception);

procedure Register;
procedure SetFieldValue(Field: TField; CardFeature: TgdcInvCardFeature); overload;
procedure SetFieldValue(Field: TParam; CardFeature: TgdcInvCardFeature); overload;
procedure SetFieldValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature); overload;
procedure SetFieldValue(Field: TParam; CardFeature: TgdcInvCardFeature; FromField: TField); overload;
procedure SetFieldValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature; FromField: TField); overload;
procedure SetFieldValue(Field: TIBXSQLVAR; FromField: TIBXSQLVAR); overload;

function CompareOptValue(Field: TField; CardFeature: TgdcInvCardFeature): boolean; overload;
function CompareOptValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature): boolean; overload;


procedure SetOptValue(var CardFeature: TgdcInvCardFeature; Field: TField);

implementation

uses
  dmDatabase_unit, gdcInvDocument_unit, gdc_frmInvSelectRemains_unit, gdc_frmInvSelectGoodRemains_unit, at_sql_setup,
  gd_security, gdc_frmInvViewRemains_unit, gd_ClassList,
  gdc_frmInvRemainsOption_unit, gdc_dlgInvRemainsOption_unit, ComObj,
  gd_resourcestring, gdc_dlgShowMovement_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , IBHeader;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcInvMovement]);
  RegisterComponents('gdc', [TgdcInvBaseRemains]);
  RegisterComponents('gdc', [TgdcInvRemains]);
  RegisterComponents('gdc', [TgdcInvGoodRemains]);
  RegisterComponents('gdc', [TgdcInvCard]);
  RegisterComponents('gdc', [TgdcInvRemainsOption]);
  RegisterComponents('gdc', [TgdcInvCardConfig]);
end;

procedure SetFieldValue(Field: TField; CardFeature: TgdcInvCardFeature); overload;
begin
  if CardFeature.IsID then
  begin
    if not CardFeature.isNull then
      SetTID(Field, CardFeature.optID)
    else
      Field.Clear;
  end
  else
    SetVar2Field(Field, CardFeature.optValue);
end;

procedure SetFieldValue(Field: TParam; CardFeature: TgdcInvCardFeature); overload;
begin
  if CardFeature.IsID then
  begin
    if not CardFeature.IsNull then
      SetTID(Field, CardFeature.optID)
    else
      Field.Clear;
  end
  else
    SetVar2Param(Field, CardFeature.optValue);
end;

procedure SetFieldValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature); overload;
begin
  if CardFeature.IsID then
  begin
    if not CardFeature.IsNull then
      SetTID(Field, CardFeature.optID)
    else
      Field.Clear;
  end
  else
    SetVar2Param(Field, CardFeature.optValue);
end;

procedure SetFieldValue(Field: TParam; CardFeature: TgdcInvCardFeature; FromField: TField); overload;
begin
  if CardFeature.IsID then
  begin
    if not CardFeature.IsNull then
      SetTID(Field, GetTID(FromField))
    else
      Field.Clear;
  end
  else
    SetVar2Param(Field, GetFieldAsVar(FromField));
end;

procedure SetFieldValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature; FromField: TField); overload;
begin
  if CardFeature.IsID then
  begin
    if not CardFeature.IsNull then
      SetTID(Field, GetTID(FromField))
    else
      Field.Clear;
  end
  else
    SetVar2Param(Field, GetFieldAsVar(FromField));
end;

procedure SetFieldValue(Field: TIBXSQLVAR; FromField: TIBXSQLVAR); overload;
var
  F: TatRelationField;
begin

  F := atDatabase.FindRelationField('INV_CARD', FromField.Name);
  if Assigned(F.References) then
  begin
    if not FromField.IsNull then
      SetTID(Field, GetTID(FromField))
    else
      Field.Clear;
  end      
  else
    SetVar2Param(Field, GetFieldAsVar(FromField));

end;


function CompareOptValue(Field: TField; CardFeature: TgdcInvCardFeature): boolean; overload;
begin
  if CardFeature.IsID then
  begin
    if CardFeature.IsNull then
      Result := Field.IsNull
    else
      Result := (GetTID(Field) = CardFeature.optID)
  end
  else
    if CardFeature.IsNull then
      Result := Field.IsNull
    else
      Result := (GetFieldAsVar(Field) = CardFeature.optValue);
end;

function CompareOptValue(Field: TIBXSQLVAR; CardFeature: TgdcInvCardFeature): boolean; overload;
begin
  if CardFeature.IsID then
  begin
    if CardFeature.IsNull then
      Result := Field.IsNull
    else
      Result := (GetTID(Field) = CardFeature.optID)
  end
  else
    if CardFeature.IsNull then
      Result := Field.IsNull
    else
      Result := (GetFieldAsVar(Field) = CardFeature.optValue);
end;



procedure SetOptValue(var CardFeature: TgdcInvCardFeature; Field: TField);
var
  F: TatRelationField;
  S: String;
begin
  S := Field.FieldName;
  if Pos(INV_SOURCEFEATURE_PREFIX, Field.FieldName) > 0 then
    S := copy(s, Pos(INV_SOURCEFEATURE_PREFIX, Field.FieldName) + length(INV_SOURCEFEATURE_PREFIX), 31)
  else
    if Pos(INV_DESTFEATURE_PREFIX, Field.FieldName) > 0 then
      S := copy(s, Pos(INV_DESTFEATURE_PREFIX, Field.FieldName) + length(INV_DESTFEATURE_PREFIX), 31);

  CardFeature.optFieldName := S;
  F := atDatabase.FindRelationField('INV_CARD', S);

  Assert(Assigned(F), '�� ������� ������� � ������� INV_CARD');

  CardFeature.IsNull := Field.IsNull;
  if Assigned(F.References) then
  begin
    CardFeature.IsID := True;
    CardFeature.optID := GetTID(Field);
  end
  else
  begin
    CardFeature.IsID := False;
    CardFeature.optValue := GetFieldAsVar(Field);
  end;

end;

{ TgdcInvMovement }

constructor TgdcInvMovement.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FShowMovementDlg := True;
  FCountPositionChanged := 0;
  FNoWait := True;

  FEndMonthRemains := False;

  FgdcDocumentLine := nil;

  FIsLocalPost := False;
  FIsGetRemains := True;

  FInvErrorCode := iecNoErr;
  FInvErrorMessage := '';

  FCurrentRemains := False;

  FibsqlCardInfo := TIBSQL.Create(Self);
  FibsqlCardInfo.Database := Database;
  FibsqlCardInfo.Transaction := Transaction;

  ibsqlCardList := TIBSQL.Create(Self);
  ibsqlCardList.Database := Database;
  ibsqlCardList.Transaction := Transaction;

  ibsqlLastRemains := TIBSQL.Create(Self);
  ibsqlLastRemains.Database := Database;
  ibsqlLastRemains.Transaction := ReadTransaction;

  FibsqlAddCard := TIBSQL.Create(Self);
  FibsqlAddCard.Database := Database;
  FibsqlAddCard.Transaction := Transaction;  

  CustomProcess := [cpInsert, cpModify];

  // �������������� ��� ������ ��������� � ���� �� ��
  FUseSelectFromSelect :=
    (gdcBaseManager.Database.IsFirebirdConnect and (gdcBaseManager.Database.ServerMajorVersion >= 2));
end;

destructor TgdcInvMovement.Destroy;
begin
  if Assigned(FibsqlCardInfo) then
    FreeAndNil(FibsqlCardInfo);

  if Assigned(ibsqlCardList) then
    FreeAndNil(ibsqlCardList);  

  if Assigned(FibsqlAddCard) then
    FreeAndNil(FibsqlAddCard);

  if Assigned(ibsqlLastRemains) then
    FreeAndNil(ibsqlLastRemains);  
      
  inherited Destroy;
end;

{ ������ ��� ��������, ���������� � �������������� �������� }

function TgdcInvMovement.CompareCard(const aSourceCardKey, aDestGoodKey: TID;
      var aDestInvCardFeatures: array of TgdcInvCardFeature): Boolean;
var
  i: Integer;
begin
  Result := False;

  if not FibsqlCardInfo.Open or (GetTID(FibsqlCardInfo.ParamByName('id')) <> aSourceCardKey) then
  begin
    FibsqlCardInfo.Close;
    SetTID(FibsqlCardInfo.ParamByName('id'), aSourceCardKey);
    FibsqlCardInfo.ExecQuery;
  end;

  if not FibsqlCardInfo.EOF then
  begin
    Result := (GetTID(FibsqlCardInfo.FieldByName('GOODKEY')) = aDestGoodKey);
    if Result then
      for i := Low(aDestInvCardFeatures) to High(aDestInvCardFeatures) do
      begin
        Result := CompareOptValue(FibsqlCardInfo.FieldByName(aDestInvCardFeatures[i].optFieldName), aDestInvCardFeatures[i]);
        if not Result then
          break;
      end;
  end;
end;

(*
  �� �������� �c������ ��� ���������� ������c��
  FirstDocumentKey, FirstDate, � ����� �c� ��������,
  MovementKey - ��� ������� ������� ���������
  �c�� ����� �c������ �� c���c�����, �����
  FirstDocumentKey � DocumentKey = ��� ������� ������� ���������
  FirstDate - ���� �������� ���������.
  ����� �� ���������� c�������� ���������c� �c������c� ��������.
*)

function TgdcInvMovement.AddInvCard(SourceCardKey: TID; var InvPosition: TgdcInvPosition;
  const isDestCard: Boolean = True): TID;
var
  i: Integer;
  isOk: Boolean;
begin

  with InvPosition do
  begin

    if SourceCardKey > 0 then // �c�� �c�� �������� �c������
    begin

      // c�������� ���������� c����� ��������
      isOK := GetCardInfo(SourceCardKey);

    end
    else
      isOk := False;

    if FibsqlAddCard.Transaction = nil then
      FibsqlAddCard.Transaction := Transaction;

    for i:= 0 to FibsqlAddCard.Params.Count - 1 do
      FibsqlAddCard.Params[i].Clear;

  // ��������� ���������������� ����

    Result := GetNextID(True);
    SetTID(FibsqlAddCard.ParamByName('ID'), Result);

    if isOK then
    begin
      SetTID(FibsqlAddCard.ParamByName('Parent'), SourceCardKey);
      SetTID(FibsqlAddCard.ParamByName('FirstDocumentKey'), GetTID(FibsqlCardInfo.FieldByName('FirstDocumentkey')));
      SetTID(FibsqlAddCard.ParamByName('DocumentKey'), InvPosition.ipDocumentKey);
      FibsqlAddCard.ParamByName('FirstDate').AsDateTime := FibsqlCardInfo.FieldByName('FirstDate').AsDateTime;
      SetTID(FibsqlAddCard.ParamByName('GoodKey'), GetTID(FibsqlCardInfo.FieldByName('goodkey')));
      SetTID(FibsqlAddCard.ParamByName('CompanyKey'), GetTID(gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey')));

      for i:= 0 to FibsqlCardInfo.Current.Count - 1 do
      begin
        if Pos(UserPrefix, FibsqlCardInfo.Fields[i].Name) > 0 then
        begin
          SetFieldValue(FibsqlAddCard.ParamByName(FibsqlCardInfo.Fields[i].Name),
            FibsqlCardInfo.FieldByName(FibsqlCardInfo.Fields[i].Name));
        end;
      end;
      // �������� �������� ��������� �� �������� �c������� �� ����� �������� ���������
      if isDestCard then
        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
          SetFieldValue(FibsqlAddCard.ParamByName(ipInvDestCardFeatures[i].optFieldName), ipInvDestCardFeatures[i])
      else
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
          SetFieldValue(FibsqlAddCard.ParamByName(ipInvSourceCardFeatures[i].optFieldName), ipInvSourceCardFeatures[i]);
    end
    else  // �c�� ��� �������� �c�������
    begin

      // �c����������� �������� �� ���������

      FibsqlAddCard.ParamByName('Parent').Clear;
      SetTID(FibsqlAddCard.ParamByName('FirstDocumentKey'), InvPosition.ipDocumentKey);
      SetTID(FibsqlAddCard.ParamByName('DocumentKey'), InvPosition.ipDocumentKey);
      FibsqlAddCard.ParamByName('FirstDate').AsDateTime := InvPosition.ipDocumentDate;
      SetTID(FibsqlAddCard.ParamByName('GoodKey'), ipGoodKey);
      SetTID(FibsqlAddCard.ParamByName('CompanyKey'),
        GetTID(gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey')));

      // ������c�� �������� ���������

      if isDestCard then
      begin
        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
        begin
          SetFieldValue(FibsqlAddCard.ParamByName(ipInvDestCardFeatures[i].optFieldName), ipInvDestCardFeatures[i]);
        end;
      end
      else
      begin
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
        begin
          SetFieldValue(FibsqlAddCard.ParamByName(ipInvSourceCardFeatures[i].optFieldName), ipInvSourceCardFeatures[i]);
        end;
      end;

    end;

  end;

  // c������ ����� ��������

 // ��������� ��������

  try
    FibsqlAddCard.ExecQuery;
  finally
    FibsqlAddCard.Close;
  end;

end;

function TgdcInvMovement.ModifyFirstMovement(const CardKey: TID;
  var InvPosition: TgdcInvPosition): Boolean;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;
    with InvPosition do
    begin
      First;
      Edit;
      FieldByName('movementdate').AsDateTime := ipDocumentDate;
      if ipOneRecord then
      begin
        if ipQuantity > 0 then
        begin
          SetTID(FieldByName('contactkey'), ipDestContactKey);
          FieldByName('debit').AsCurrency := ipQuantity;
        end
        else
        begin
          SetTID(FieldByName('contactkey'), ipSourceContactKey);
          FieldByName('credit').AsCurrency := abs(ipQuantity);
        end;
        Post;
        if ipQuantity = 0 then
          Delete;
      end
      else
      begin
        SetTID(FieldByName('contactkey'), ipSourceContactKey);
        FieldByName('credit').AsCurrency := ipQuantity;
        Post;

        Next;
        if not EOF then
          Edit
        else
          Append;

        FieldByName('movementdate').AsDateTime := ipDocumentDate;
        SetTID(FieldByName('contactkey'), ipDestContactKey);
        FieldByName('debit').AsCurrency := ipQuantity;
        Post;
      end;
// �������� �c������ ��������� ��������

      ibsql.SQL.Text := 'UPDATE inv_card SET firstdate = :firstdate, goodkey = :goodkey ' +
                        '  WHERE id = :id';

      ibsql.Prepare;
      ibsql.ParamByName('firstdate').AsDateTime := ipDocumentDate;
      SetTID(ibsql.ParamByName('goodkey'), ipGoodKey);
      SetTID(ibsql.ParamByName('id'), CardKey);
      ibsql.ExecQuery;
      ibsql.Close;

      Result := ModifyInvCard(CardKey, ipInvDestCardFeatures);

    end;
  finally
    ibsql.Free;
  end;
end;

{
   ��� ��������� �������� �c�����������c� �������� ���������� � CardFeatures ��������
}

function TgdcInvMovement.ModifyInvCard(SourceCardKey: TID;
  var CardFeatures: array of TgdcInvCardFeature; const ChangeAll: Boolean = False): Boolean;
var
  ibsql: TIBSQL;
  i: Integer;
  S: String;
begin
  Result := True;

  if (Length(CardFeatures) = 0) and not ChangeAll then
    exit;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;

    S := 'UPDATE inv_card SET ' + #13#10;
    for i:= Low(CardFeatures) to High(CardFeatures) do
    begin
      S := S + CardFeatures[i].optFieldName + ' = :' + CardFeatures[i].optFieldName;
      if i < High(CardFeatures) then
        S := S + ', ';
    end;

    if (Length(CardFeatures) > 0) then
      S := S + ', goodkey = :goodkey '
    else
      S := S + ' goodkey = :goodkey ';

    if ChangeAll then
    begin
      S := S +
        ', firstdocumentkey = :documentkey, firstdate = :firstdate, documentkey = :documentkey';
    end;

    ibsql.SQL.Text := S + ' WHERE id = :SourceCardKey ';
    ibsql.Prepare;
    SetTID(ibsql.paramByName('SourceCardKey'), SourceCardKey);

    for i:= Low(CardFeatures) to High(CardFeatures) do
      SetFieldValue(ibsql.ParamByName(CardFeatures[i].optFieldName), CardFeatures[i]);

    SetTID(ibsql.ParamByName('goodkey'), GetTID(gdcDocumentLine.FieldByName('goodkey')));

    if ChangeAll then
    begin
      SetTID(ibsql.ParamByName('documentkey'), GetTID(gdcDocumentLine.FieldByName('id')));
      ibsql.ParamByName('firstdate').AsDateTime := gdcDocumentLine.FieldByName('documentdate').AsDateTime;
    end;

    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;

(*
    �������� �� �������� ���������c� ��������:
    1. �c�� BaseCardKey > -1 �� �������������c� ��� ����c����� �����������
       c���c������� ��������, ����� � �c������� ��������c� �� ������� ��������,
       ������� c������c����� ������� �������� � ��� ������ ���������, ������� ���
       ������� ��������� ������c� ��������:
      SELECT
        C.ID, C.FIRSTDATE, SUM(M.DEBET - M.CREDIT)
      FROM
        INV_CARD C
        JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID)
      WHERE
        C.GOODKEY = 147100628
          AND
        M.CONTACTKEY = 146912887
          AND
        M.MOVEMENTDATE <= '01.12.2001'
(          AND c��c�� �c����� �� ��������� )
      GROUP BY C.ID, C.FIRSTDATE

      HAVING SUM(M.DEBET - M.CREDIT) > 0

      ORDER BY C.FIRSTDATE (ASC ��� DESC � ����c���c�� �� ��������).

    3. ����� c������c� ���������� ��������� c ����������� ������� ��������, �c�� ���
       �� c�������� �� ��� ���������� ����� c������ ����� ��������

    4. ����� �� c��c�� ��������� �������� � ���� �� ������� �c� ������c��� � �������� ���������
       ����� ����c�, ��� �� ������� ���c������� ������� �c������, � �������� �� c��c��, � �� �������
       ������� ����������, � �������� ���� c����� ���� ����� c����c�� �.2.

    5. � ����� �������� ����c��c� ����� c���c���.

    6. �c�� BaseCardKey = -1 �� ��� ��������, ��� �������� c������ ��c������ ����� �������� �
       ������ ���� ���c��� ���������� � ������� �������� ����c�� ��� � ����� � ������ ���c��c�
       ����� ��� ��������. � ������ ������� - ������� ����������, � ������� ������� �c������.

    7. �c�� ����c����� �������������� ������� ��������� ��:
       - ������� ��������
       - �c�� c���� ��������, �� ��� �������� �� ������ �� c������ �c����� �� ������� ��c�� �
         ��������� c ������� ������c����, �c�� ��� �������������, �� ��������� c ������c����
         �� ����� ������� �c�� �������������, �� ������ ��������� ���� 2-5. �c�� c���� ��������
         �� �����, �� �� c������ �c����� �� ����� ������� � ���������, ��� �� �� ��� ������ ���
         ����� ��� ������� �c�����.
       - �c�� � ���������� �������� c��������c� ����� ��������, �� �� ������ c�������� ��� ��������
         ����� ����� c��c� �c���������� ������ ��� ��������, �c�� �����-�� �������� c���� ������, ��
         ���������� ������� �� �� ������� ��� ��������. ����� ��������� ���� 2-5.
*)

function TgdcInvMovement.MakeCardListSQL(MovementDirection: TgdcInvMovementDirection;
    var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;
var
  i: Integer;
  Features: String;
  ibsql: TIBSQL;

begin
  if (not CurrentRemains) and not isMinusRemains then
  begin
    Result := 'SELECT  C.ID, C.FIRSTDATE, ';
    if isMinusRemains then
      Result := Result + '(0 - SUM(M.DEBIT - M.CREDIT)) as Quantity ' + #13#10
    else
      Result := Result + 'SUM(M.DEBIT - M.CREDIT) as Quantity ' + #13#10;
    if (GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
       not (gdcDocumentLine as TgdcInvDocumentLine).UseGoodKeyForMakeMovement) or
           (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil)
    then
      Result := Result +
         ' FROM INV_CARD C LEFT JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID) WHERE ' + #13#10 +
         '  C.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey AND M.MOVEMENTDATE <= :movementdate ' +
         '  and m.disabled = 0  ' + #13#10
    else
      Result := Result +
         ' FROM INV_CARD C JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID) AND ' + #13#10 +
         '  M.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey AND M.MOVEMENTDATE <= :movementdate ' +
         '  and m.disabled = 0  ' + #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      Result := Result + ' AND C.COMPANYKEY + 0 = :companykey';
  end
  else
  begin
    if isMinusRemains then
      Result := 'SELECT  C.ID, C.FIRSTDATE, -M.BALANCE as Quantity ' + #13#10
    else
      Result := 'SELECT  C.ID, C.FIRSTDATE, M.BALANCE as Quantity ' + #13#10;
    if (GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or not (gdcDocumentLine as TgdcInvDocumentLine).UseGoodKeyForMakeMovement) or (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil) then
      Result := Result +
         ' FROM INV_CARD C LEFT JOIN INV_BALANCE M ON (M.CARDKEY = C.ID) WHERE ' + #13#10 +
         '  C.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey '
    else
      Result := Result +
         ' FROM INV_CARD C JOIN INV_BALANCE M ON (M.CARDKEY = C.ID) AND ' + #13#10 +
         '  M.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey ';
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      Result := Result + ' AND C.COMPANYKEY + 0 = :companykey';
  end;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
    Result := Result + ' AND C.ID = :CARDKEY '
  else
  begin

    Features := '';

    for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
      if InvCardFeatures[i].isID then
        if InvCardFeatures[i].IsNull then
          Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
        else
          Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
            InvCardFeatures[i].optFieldName
      else
        if InvCardFeatures[i].IsNull then
          Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' IS NULL '
        else
          Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' = :' +
            InvCardFeatures[i].optFieldName;


    Result := Result + Features ;
  end;

  if (not CurrentRemains) and not isMinusRemains then
    Result := Result + ' GROUP BY C.ID, C.FIRSTDATE ' + #13#10
  else
  begin
    if not isMinusRemains then
      Result := Result + ' AND M.BALANCE > 0 '
    else
      Result := Result + ' AND M.BALANCE < 0 ';
  end;

  if (not CurrentRemains) and not isMinusRemains then
  begin
    if not isMinusRemains then
      Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) > 0 '
    else
      Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) < 0 ';
  end;

  if MovementDirection = imdDefault then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT discipline FROM gd_good WHERE id = :id';
      SetTID(ibsql.ParamByName('id'), GetTID(gdcDocumentLine.FieldByName('goodkey')));
      ibsql.ExecQuery;
      if ibsql.FieldByName('discipline').IsNull then
        MovementDirection := imdFIFO
      else
        if ibsql.FieldByName('discipline').AsString = 'F' then
          MovementDirection := imdFIFO
        else
          MovementDirection := imdLIFO;
    finally
      ibsql.Free;
    end;
  end;

  if MovementDirection = imdFIFO then
    Result := Result + ' ORDER BY C.FIRSTDATE '
  else
    Result := Result + ' ORDER BY C.FIRSTDATE DESC ';
end;

function TgdcInvMovement.MakeCardListSQL_New(MovementDirection: TgdcInvMovementDirection;
  var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean): String;
var
  i: Integer;
  Features: String;
  ibsql: TIBSQL;
begin
  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
  begin
    Features := ' AND c.id = :cardkey ';
  end
  else
  begin
    Features := '';
    for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
      if InvCardFeatures[i].isID then
        if InvCardFeatures[i].IsNull then
          Features := Features + ' AND (c.' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
        else
          Features := Features + ' AND (c.' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
            InvCardFeatures[i].optFieldName
      else
        if InvCardFeatures[i].IsNull then
          Features := Features + ' AND c.' + InvCardFeatures[i].optFieldName + ' IS NULL '
        else
          Features := Features + ' AND c.' + InvCardFeatures[i].optFieldName + ' = :' +
            InvCardFeatures[i].optFieldName;
  end;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
    Features := Features + ' AND (c.companykey + 0) = :companykey';

  Result := '';
  if not CurrentRemains then
  begin
    Result :=
      'SELECT' + #13#10 +
      '  mm.id,' + #13#10 +
      '  mm.firstdate,' + #13#10 +
      '  SUM(mm.quantity) AS quantity' + #13#10 +
      'FROM' + #13#10 +
      '  (' + #13#10;
  end;

  Result := Result +
    '     SELECT' + #13#10 +
    '       c.id,' + #13#10 +
    '       c.firstdate,' + #13#10;
  if CurrentRemains and isMinusRemains then
    Result := Result +
      '       - bal.balance AS quantity' + #13#10
  else
    Result := Result +
      '       bal.balance AS quantity' + #13#10;
  Result := Result +
    '     FROM' + #13#10 +
    '       inv_balance bal' + #13#10;
  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
    Result := Result +
      '       JOIN inv_card c ON c.id = bal.cardkey' + #13#10
  else
    Result := Result +
      '       LEFT JOIN inv_card c ON c.id = bal.cardkey' + #13#10;
  Result := Result +
    '     WHERE' + #13#10 +
    '       bal.contactkey = :contactkey' + #13#10 +
    '       AND bal.goodkey = :goodkey' + #13#10 +
      Features + #13#10;

  if CurrentRemains and isMinusRemains then
    Result := Result + ' AND bal.balance < 0 '
  else
    Result := Result + ' AND bal.balance > 0 ';

  if not CurrentRemains then
  begin
    Result := Result +
      ' ' +
      '     UNION ALL' + #13#10 +
      ' ' +
      '     SELECT' + #13#10 +
      '       c.id AS cardkey,' + #13#10 +
      '       c.firstdate,' + #13#10 +
      '       - (m.debit - m.credit) AS quantity' + #13#10 +
      '     FROM' + #13#10 +
      '       inv_movement m' + #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
      Result := Result +
        '       JOIN inv_card c ON c.id = m.cardkey' + #13#10
    else
      Result := Result +
        '       LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10;
    Result := Result +
      '     WHERE' + #13#10 +
      '       m.movementdate > :movementdate' + #13#10 +
      '       AND m.contactkey = :contactkey' + #13#10 +
      '       AND m.goodkey = :goodkey' + #13#10 +
      '       AND m.disabled = 0' + #13#10 +
        Features +
      '  ) mm' + #13#10 +
      'GROUP BY' + #13#10 +
      '  mm.id,' + #13#10 +
      '  mm.firstdate' + #13#10;
  end;

  if MovementDirection = imdDefault then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT discipline FROM gd_good WHERE id = :id';
      SetTID(ibsql.ParamByName('id'), GetTID(gdcDocumentLine.FieldByName('goodkey')));
      ibsql.ExecQuery;
      if ibsql.FieldByName('discipline').IsNull then
        MovementDirection := imdFIFO
      else
        if ibsql.FieldByName('discipline').AsString = 'F' then
          MovementDirection := imdFIFO
        else
          MovementDirection := imdLIFO;
    finally
      ibsql.Free;
    end;
  end;

  if CurrentRemains then
    if MovementDirection = imdFIFO then
      Result := Result + ' ORDER BY c.firstdate '
    else
      Result := Result + ' ORDER BY c.firstdate DESC '
  else
    if MovementDirection = imdFIFO then
      Result := Result + ' ORDER BY mm.firstdate '
    else
      Result := Result + ' ORDER BY mm.firstdate DESC ';
end;

function TgdcInvMovement.AddOneMovement(aSourceCardKey: TID; aQuantity: Currency;
  var invPosition: TgdcInvPosition): Boolean;

  function IsExistsCardKey(const aCardKey: TID): Boolean;
  var
    ibsql: TIBSQL;
  begin
    if aCardKey > 0 then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT id FROM inv_movement WHERE documentkey = :documentkey AND ' +
          ' cardkey = :cardkey ';
        SetTID(ibsql.ParamByName('documentkey'), invPosition.ipDocumentKey);
        SetTID(ibsql.ParamByName('cardkey'), aCardKey);
        ibsql.ExecQuery;
        Result := not ibsql.EOF;
      finally
        ibsql.Free;
      end;
    end
    else
      Result := False;
  end;

var
  SourceCardKey: TID;
  DestCardKey: TID;
  MovementKey: TID;
  ibsql: TIBSQL;
  TempCardKey: TID;
  Flag: Boolean;
  isDestCard: Boolean;
  {$IFDEF DEBUGMOVE}
  Times: LongWord;
  {$ENDIF}
begin
  {$IFDEF DEBUGMOVE}
  Times := GetTickCount;
  {$ENDIF}
  if aSourceCardKey > 0 then
    SourceCardKey := aSourceCardKey
  else
  begin
    if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtInventorization) or
      isExistsCardKey(invPosition.ipBaseCardKey) and (GetLastRemains(invPosition.ipBaseCardKey, invPosition.ipSourceContactKey) > 0) then
      TempCardKey := invPosition.ipBaseCardKey
    else
      TempCardKey := -1;

    if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtInventorization) or ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtFeatureChange) then
      isDestCard := False
    else
    begin
      if (aQuantity < 0) and ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation) then
        isDestCard := False
      else
        isDestCard := True;
    end;

    SourceCardKey := AddInvCard(TempCardKey, invPosition, isDestCard);
  end;

  with invPosition do
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := Transaction;
      // ��������� ����c� �� ������� �� �c�������
      if not ipDelayed then
      begin
        ibsql.SQL.Text := 'INSERT INTO inv_movement (movementkey, movementdate, documentkey, ' +
          ' contactkey, cardkey, debit, credit, disabled) VALUES (:movementkey, :movementdate, ' +
          ' :documentkey, :contactkey, :cardkey, :debit, :credit, 0)';
        MovementKey := GetNextID(True);
        SetTID(ibsql.ParamByName('movementkey'), MovementKey);
        ibsql.ParamByName('movementdate').AsDateTime := ipDocumentDate;
        SetTID(ibsql.ParamByName('documentkey'), ipDocumentKey);

        if not ipOneRecord or not ipMinusRemains then
        begin
          SetTID(ibsql.ParamByName('cardkey'), SourceCardKey);
          ibsql.ParamByName('debit').AsCurrency := 0;
          ibsql.ParamByName('credit').AsCurrency := 0;
          if (ipOneRecord and (aQuantity < 0)) or not ipOneRecord or (aSourceCardKey > 0) then
          begin
            if ipOneRecord then
              aQuantity := abs(aQuantity);
            SetTID(ibsql.ParamByName('contactkey'), ipSourceContactKey);
            ibsql.ParamByName('credit').AsCurrency := aQuantity;
          end
          else
          begin
            SetTID(ibsql.ParamByName('contactkey'), ipDestContactKey);
            ibsql.ParamByName('debit').AsCurrency := abs(aQuantity);
          end;

          Flag := True;
          repeat
            try
              ibsql.ExecQuery;
              Flag := True;
            except
              on E: EIBError do
              begin
                if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
                  and Flag then
                begin
                  ibsql.Close;
                  Randomize;
                  Sleep(Random(2000) + 500);
                  Flag := False;
                end else
                  raise;
              end
              else
                raise;
            end;
          until Flag;
          ibsql.Close;
        end;

        if ((gdcDocumentLine.FindField('fromcardkey') <> nil) and
           gdcDocumentLine.FieldByName('fromcardkey').IsNull) or
           (aSourceCardKey = -1)
        then
        begin
          if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
            gdcDocumentLine.Edit;
          SetTID(gdcDocumentLine.FieldByName('fromcardkey'), SourceCardKey);
        end;

    // �c�� �������� c�c���� �� ���� ����c�� ��������� ����c� �� ������ ����������

        if not ipOneRecord or (ipOneRecord and ipMinusRemains) then
        begin

    // �c�� ��������� �������� � ��������� ��������c� � ��� �� ���� �������������� ��c���������
    // �� c������ ����� ��������, � ��������� c����� �c�������� �������� �c������
          if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtSimple) and ((High(ipInvDestCardFeatures) >= 0) and
             not CompareCard(SourceCardKey, ipGoodKey, ipInvDestCardFeatures))
          then
          begin
            if not ipMinusRemains then
              DestCardKey := AddInvCard(SourceCardKey, invPosition)
            else
            begin
              ModifyInvCard(SourceCardKey, ipInvDestCardFeatures, True);
              DestCardKey := SourceCardKey;
            end;
          end
          else
            DestCardKey := SourceCardKey;

          SetTID(ibsql.ParamByName('contactkey'), ipDestContactKey);
          SetTID(ibsql.ParamByName('cardkey'), DestCardKey);
          ibsql.ParamByName('debit').AsCurrency := aQuantity;
          ibsql.ParamByName('credit').AsCurrency := 0;

          Flag := True;
          repeat
            try
              ibsql.ExecQuery;
              Flag := True;
            except
              on E: EIBError do
              begin
                if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
                  and Flag then
                begin
                  ibsql.Close;
                  Randomize;
                  Sleep(Random(2000) + 500);
                  Flag := False;
                end
                else
                  raise;
              end
              else
                raise;
            end;
          until Flag;
          ibsql.Close;

          if (gdcDocumentLine.FindField('tocardkey') <> nil) and
             (GetTID(gdcDocumentLine.FieldByName('tocardkey')) <> DestCardKey)
          then
          begin
            if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
              gdcDocumentLine.Edit;
            SetTID(gdcDocumentLine.FieldByName('tocardkey'), DestCardKey);
          end;
        end;
      end
      else
      begin
        if (gdcDocumentLine.FindField('fromcardkey') <> nil) and
           gdcDocumentLine.FieldByName('fromcardkey').IsNull
        then
        begin
          if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
            gdcDocumentLine.Edit;
          SetTID(gdcDocumentLine.FieldByName('fromcardkey'), SourceCardKey);
        end;
        if (gdcDocumentLine.FindField('tocardkey') <> nil) then
        begin
          if gdcDocumentLine.FieldByName('tocardkey').IsNull or
             (GetTID(gdcDocumentLine.FieldByName('tocardkey')) =
              GetTID(gdcDocumentLine.FieldByName('fromcardkey')))
          then
          begin
             if not CompareCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
               GetTID(gdcDocumentLine.FieldByName('goodkey')),
               ipInvDestCardFeatures)
             then
               SetTID(gdcDocumentLine.FieldByName('tocardkey'), AddInvCard(
                 GetTID(gdcDocumentLine.FieldByName('fromcardkey')), InvPosition))
             else
               SetTID(gdcDocumentLine.FieldByName('tocardkey'),
                 GetTID(gdcDocumentLine.FieldByName('fromcardkey')))
          end
          else
            ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('tocardkey')),
               ipInvDestCardFeatures);
        end;
      end;
    finally
      ibsql.Free;
    end;
  end;
  Result := True;
  {$IFDEF DEBUGMOVE}
  TimeMakePos := TimeMakePos + GetTickCount - Times;
  {$ENDIF}
end;

{
    ������ ������� ����� ��������c� ������ � c����� c�������� ���������
    1. ������� ����������
    2. �������� c���c���
}

type
  TinvTempRemains = record
    MovementKey: TID;
    Quantity: Currency;
  end;

function TgdcInvMovement.EditMovement(ChangeMove: TgdcChangeMovements;
       var InvPosition: TgdcInvPosition; const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  MovementKey, SourceCardKey, CardKey: TID;
  i: Integer;
  Quantity, CurQuantity, PerQuantity: Currency;
  CountTempRemains: Integer;
  invTempRemains: array of TinvTempRemains;
  FSavepoint: String;

  function CheckDestContactAndFeature: Boolean;
  begin
    with InvPosition do
    begin
      Result := True;

      First;

      MovementKey := -1;
      SourceCardKey := -1;

      while not EOF do
      begin
        if FieldByName('debit').AsCurrency <> 0 then
        begin

          if (
               (cmDestContact in ChangeMove) or
               (
                (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
                (cmDestFeature in ChangeMove) and (MovementKey = GetTID(FieldByName('movementkey')))
                 and (SourceCardKey = GetTID(FieldByName('cardkey'))) and
                 (GetTID(FieldByName('FirstDocumentKey')) <> ipDocumentKey)
                )
             )
             and
             (GetLastRemains(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey'))) <
              FieldByName('debit').AsCurrency)
          then
          begin
            Result := False;
            if (cmDestContact in ChangeMove) then
              FInvErrorCode := iecDontChangeDest
            else
              FInvErrorCode := iecDontChangeFeatures;
            Break;
          end;

          if (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
            (cmDestFeature in ChangeMove) and
            (GetTID(FieldByName('CardDocumentKey')) = ipDocumentKey) and
             not CheckMovementOnCard(GetTID(FieldByName('cardkey')), InvPosition)
          then
          begin
            Result := False;
            FInvErrorCode := iecDontChangeFeatures;
            Break;
          end;

        end
        else
        begin
          MovementKey := GetTID(FieldByName('movementkey'));
          SourceCardKey := GetTID(FieldByName('cardkey'));
        end;
        Next;
      end;
    end;
  end;

begin
  with InvPosition do
  begin

// ��������� ���������� ��������� �� ������ �������� ���c������� � ��������
// ��������� �c����� �� c������ ���������� � �c�� �c� OK �� �������c�� ������.

    Result := CheckDestContactAndFeature;

    if Result and (cmQuantity in ChangeMove) then
    begin

// �c�� ��������c� ������c��� �� �������� ���-�� � ��������

      if not ipOneRecord then
        Quantity := GetQuantity(ipDocumentKey, tpAll)
      else
        Quantity := GetQuantity(ipDocumentKey, tpDebit) - GetQuantity(ipDocumentKey, tpCredit);


      if not ipOneRecord or ((ipQuantity >= 0) and (Quantity > 0)) or ((ipQuantity < 0) and (Quantity < 0)) then
      begin

        if (abs(ipQuantity) < abs(Quantity)) then
        begin

          Quantity := abs(Quantity) - abs(ipQuantity);
          CurQuantity := 0;

  // �c�� ������c��� c���� ������, � ���������c� ����������, �� c������ ��������
  // �� ����� ��������� �� ����� ��� ��������
  // � �c�� ����� �������� � �������� �c��, �� �� � ��������.

  // �c�� �������c� ����������, �� �� ����� c��� ����c�� ������ � ��� c�����, �c��
  // �� c����� ���������� �c� ����� OK, c������c������ ��� ��c������� ������� ������ ��������
  // � �������� ����������.

          if not (cmDestContact in ChangeMove) and (ipQuantity >= 0) then
          begin

            SetLength(invTempRemains, 0);
            CountTempRemains := 0;
            First;
            while not EOF do
            begin
              if ((FieldByName('debit').AsCurrency > 0) and (ipQuantity >= 0)) then
              begin
                if not (ipCheckRemains = [])  then
                  PerQuantity := GetLastRemains(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey')))
                else
                  PerQuantity := FieldByName('debit').AsCurrency;

                if PerQuantity >= FieldByName('debit').AsCurrency then
                  PerQuantity := FieldByName('debit').AsCurrency;
                if PerQuantity > 0 then
                begin
                  Inc(CountTempRemains);
                  SetLength(invTempRemains, CountTempRemains);
                  invTempRemains[High(invTempRemains)].MovementKey := GetTID(FieldByName('MovementKey'));
                  invTempRemains[High(invTempRemains)].Quantity := PerQuantity;
                  CurQuantity := CurQuantity + PerQuantity;
                  if CurQuantity - Quantity > 0 then
                    invTempRemains[High(invTempRemains)].Quantity := invTempRemains[High(invTempRemains)].Quantity -
                      CurQuantity + Quantity;
                end;
                if CurQuantity >= Quantity then
                  Break;
              end
              else
                if ipQuantity < 0 then
                begin
                  if Quantity >= FieldByName('credit').AsCurrency then
                    PerQuantity := FieldByName('credit').AsCurrency
                  else
                    PerQuantity := Quantity;
                  Inc(CountTempRemains);
                  SetLength(invTempRemains, CountTempRemains);
                  invTempRemains[High(invTempRemains)].MovementKey := GetTID(FieldByName('MovementKey'));
                  invTempRemains[High(invTempRemains)].Quantity := PerQuantity;
                  Quantity := Quantity - PerQuantity;
                  if Quantity = 0 then
                    Break;
                end;
              Next;
            end;

  // �c�� �� ����� �������� �� ������� ����� ��������� ������c���, �� ��� � ������
  // � ��������� c����� ���������� ��� ������.

            if CurQuantity >= Quantity then
            begin

              for i:= Low(invTempRemains) to High(invTempRemains) do
              begin
                Locate('MOVEMENTKEY', TID2V(invTempRemains[i].MovementKey), []);
                if GetTID(FieldByName('movementkey')) = invTempRemains[i].MovementKey then
                begin
                  if invTempRemains[i].Quantity = FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency then
                  begin
                    while not EOF and (GetTID(FieldByName('movementkey')) = invTempRemains[i].MovementKey) do
                      Delete;
                  end
                  else
                    while not EOF and (GetTID(FieldByName('movementkey')) = invTempRemains[i].MovementKey) do
                    begin
                      Edit;
                      if FieldByName('credit').AsCurrency > 0 then
                        FieldByName('credit').AsCurrency := FieldByName('credit').AsCurrency - invTempRemains[i].Quantity
                      else
                        FieldByName('debit').AsCurrency := FieldByName('debit').AsCurrency - invTempRemains[i].Quantity;
                      Post;
                      Next;
                    end;
                end;
              end;

            end
            else
            begin

              Result := False;
              FInvErrorCode := iecDontDecreaseQuantity;

            end;
          end

          else
          begin

  // �������c� ���������� ��� �����������c� ��������������

            Last;
            while not BOF do
            begin
              if Quantity < FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency then
              begin
                MovementKey := GetTID(FieldByName('movementkey'));
                while not BOF and (GetTID(FieldByName('movementkey')) = MovementKey) do
                begin
                  Edit;
                  if FieldByName('debit').AsCurrency > 0 then
                    FieldByName('debit').AsCurrency := FieldByName('debit').AsCurrency - Quantity
                  else
                    if FieldByName('credit').AsCurrency > 0 then
                      FieldByName('credit').AsCurrency := FieldByName('credit').AsCurrency - Quantity;
                  Post;
                  Prior;
                end;
                Break;
              end
              else
              begin
                Quantity := Quantity - (FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency);
                MovementKey := GetTID(FieldByName('movementkey'));
                while not BOF and (GetTID(FieldByName('movementkey')) = MovementKey) do
                begin
                  Edit;
                  FieldByName('debit').AsCurrency := 0;
                  FieldByName('credit').AsCurrency := 0;
                  Post;
                  Prior;
                end;
                if MovementKey <> GetTID(FieldByName('movementkey')) then
                  Continue;
              end;
              Prior;
            end;

          end;
        end
        else
        begin

  // �c�� ������c��� ���������c�, �� ���������� c����������� ����� �������� ��
  // �������

  // c�������� ��c������ ��� c�������������� ������ �������� ��� ��������c�� �������c�� �����

          FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
              '-', '', [rfReplaceAll]), 1, 30);
          try
            Transaction.SetSavePoint(FSavepoint);
          except
            FSavepoint := '';
          end;


          Quantity := abs(ipQuantity) - abs(Quantity);

          Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

          if not Result then
            Transaction.RollBackToSavePoint(FSavepoint);

          Transaction.ReleaseSavePoint(FSavepoint);
        end;
      end
      else
      begin
        if (ipQuantity >= 0) and (Quantity <= 0) then
        begin
          Quantity := -ipQuantity;

          FSavepoint := 'S' + System.Copy(StringReplace(
          StringReplace(
            StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
            '-', '', [rfReplaceAll]), 1, 30);
          Transaction.SetSavePoint(FSavepoint);

          try
            DeleteEnableMovement(ipDocumentKey, True);
            Result := True;
          except
            FInvErrorCode := iecDontDisableMovement;
            Result := False;
          end;

          if Result then
            Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

          if not Result then
            Transaction.RollBackToSavePoint(FSavepoint);

          Transaction.ReleaseSavePoint(FSavepoint);
        end
        else
        begin
          if (ipQuantity <= 0) and (Quantity >= 0) then
          begin

            PerQuantity := 1;
            First;
            while not EOF do
            begin
              if (FieldByName('debit').AsCurrency > 0) then
              begin
                PerQuantity := GetLastRemains(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey')));
                if PerQuantity <= FieldByName('debit').AsCurrency then
                begin
                  PerQuantity := 0;
                  Break;
                end;
              end;
              Next;
            end;
            if PerQuantity > 0 then
            begin
              Result := False;
              FInvErrorCode := iecDontDecreaseQuantity;
              exit;
            end;

            Quantity := -ipQuantity;

            FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
              '-', '', [rfReplaceAll]), 1, 30);
            Transaction.SetSavePoint(FSavepoint);

            try
              DeleteEnableMovement(ipDocumentKey, True);
              Result := True;
            except
              FInvErrorCode := iecDontDisableMovement;
              Result := False;
            end;

            if Result then
              Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

            if not Result then
              Transaction.RollBackToSavePoint(FSavepoint);

            Transaction.ReleaseSavePoint(FSavepoint);
          end;
        end;
      end;
    end;

    if Result then
    begin
      if (cmDestContact in ChangeMove) then
        ExecSingleQuery('UPDATE inv_movement SET contactkey = ' +
           IntToStr(ipDestContactKey) + ' WHERE documentkey = ' +
           IntToStr(ipDocumentKey) + ' AND debit <> 0 ');

      if (cmDestFeature in ChangeMove)
      then
      begin
        First;

        MovementKey := -1;
        SourceCardKey := -1;

        while not EOF do
        begin
          if FieldByName('debit').AsCurrency <> 0 then
          begin
            if (cmDestFeature in ChangeMove) and (MovementKey = GetTID(FieldByName('movementkey')))
            then
            begin
              if (SourceCardKey = GetTID(FieldByName('cardkey'))) and
                (GetTID(FieldByName('FirstDocumentKey')) <> ipDocumentKey)
              then
              begin
                CardKey := AddInvCard(SourceCardKey, InvPosition);
                Edit;
                SetTID(FieldByName('cardkey'), CardKey);
                Post;
                if gdcDocumentLine.FindField('TOCARDKEY') <> nil then
                begin
                  if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                    gdcDocumentLine.Edit;
                  SetTID(gdcDocumentLine.FieldByName('TOCARDKEY'), CardKey);
                end;
              end
              else
                ModifyInvCard(GetTID(FieldByName('cardkey')),
                    ipInvDestCardFeatures);
            end
          end
          else
          begin
            MovementKey := GetTID(FieldByName('movementkey'));
            SourceCardKey := GetTID(FieldByName('cardkey'));
          end;
          Next;
        end;
      end;
    end;
  end;
end;

function TgdcInvMovement.EditDateMovement(var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  ibsql: TIBSQL;
begin
  Result := True;
  if InvPosition.ipDocumentDate > FieldByName('movementdate').AsDateTime then
  begin
    // ���� �������� ��������c� �� ����� �������. ���������� ��������� �� ���� �� ��������
    // �������� �� ���� ������ ����������
    if not (sLoadFromStream in gdcDocumentLine.BaseState) and not FCurrentRemains then
    begin
      First;
      while not EOF do
      begin
        if (FieldByName('debit').AsCurrency > 0) and
           (GetRemainsOnDate(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey')),
                InvPosition.ipDocumentDate - 1) < FieldByName('debit').AsCurrency)
        then
        begin
          Result := False;
          FInvErrorCode := iecFoundEarlyMovement;
          Break;
        end;
        Next;
      end;
    end
  end
  else
  begin
    // ���� �������� ��������c� �� ����� ������ �c�� �� ��������� �c�� �������� �c������
    // � �� �� ���� ���������, �� ���� ��������� ������� �c������ �� ��� ����
    if (tcrSource in InvPosition.ipCheckRemains) and not FCurrentRemains then
    begin
      First;
      while not EOF do
      begin
        if (FieldByName('credit').AsCurrency > 0) and (GetRemainsOnDate(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey')),
              InvPosition.ipDocumentDate) < FieldByName('credit').AsCurrency)
        then
        begin
          Result := False;
          FInvErrorCode := iecRemainsNotFoundOnDate;
          exit;
        end;
        Next;
      end;
    end;
  end;
  if Result then
  begin
    Close;
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := Transaction;
      ibsql.SQL.Text := 'UPDATE inv_movement SET movementdate = :movementdate WHERE documentkey = :documentkey';
      ibsql.ParamByName('movementdate').AsDateTime := InvPosition.ipDocumentDate;
      SetTID(ibsql.ParamByName('documentkey'), InvPosition.ipDocumentKey);
      ibsql.ExecQuery;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
    Open;
  end;
end;

function TgdcInvMovement.MakeMovementLine(Quantity: Currency; var InvPosition: TgdcInvPosition;
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  i: Integer;
  tempCardKey: TID;
  isChangeBaseCardKey: Boolean;
  Times: LongWord;
  tmpRemains: Currency;
  isChange: Boolean;
  Day, Month, Year: Word;

function IsChangeSQLText(MovementDirection: TgdcInvMovementDirection; var InvCardFeatures: array of TgdcInvCardFeature): Boolean;
var
  i: Integer;
  Features: String;
begin
  Result := True;
  if MovementDirection = imdDefault then exit;

  for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
    if InvCardFeatures[i].isID then
      if InvCardFeatures[i].isNull then
        Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
          InvCardFeatures[i].optFieldName
    else
      if InvCardFeatures[i].IsNull then
        Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' IS NULL '
      else
        Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' = :' +
          InvCardFeatures[i].optFieldName;

  if Pos(Features, ibsqlCardList.SQL.Text) > 0 then
    Result := False;
end;

begin
  with InvPosition do
  begin
    Times := GetTickCount;
    Result := True;
    repeat
      try
        if (ipBaseCardKey > 0) and ((Quantity > 0) or ipMinusRemains) and not ipDelayed
           and (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources)
        then
        begin
          if ipMinusRemains then
            Quantity := abs(Quantity);


          tempCardKey := -1;
          isChangeBaseCardKey := True;
          try

            {$IFDEF DEBUGMOVE}
            Times := GetTickCount;
            {$ENDIF}
            ibsqlCardList.Close;
            if not ipMinusRemains then
              isChange := IsChangeSQLText(ipMovementDirection, ipInvSourceCardFeatures)
            else
              isChange := IsChangeSQLText(ipMovementDirection, ipInvMinusCardFeatures);

            if (ibsqlCardList.SQL.Text = '') or IsChange then
            begin
              // ��������� ���c� �����c�
              ibsqlCardList.Transaction := Transaction;
              // ���� ������ Firebird 2.0+, � ���� ���� GOODKEY � INV_MOVEMENT � INV_BALANCE,
              //   �� ����� ����� ������� ������ ���������
              if FUseSelectFromSelect
                 and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY'))
                 and GlobalStorage.ReadBoolean('Options\Invent', 'UseNewRemainsMethod', False, False) then
                if ipMinusRemains then
                  ibsqlCardList.SQL.Text := MakeCardListSQL_New(ipMovementDirection, ipInvMinusCardFeatures, ipMinusRemains)
                else
                  ibsqlCardList.SQL.Text := MakeCardListSQL_New(ipMovementDirection, ipInvSourceCardFeatures, ipMinusRemains)
              else
                if ipMinusRemains then
                  ibsqlCardList.SQL.Text := MakeCardListSQL(ipMovementDirection, ipInvMinusCardFeatures, ipMinusRemains)
                else
                  ibsqlCardList.SQL.Text := MakeCardListSQL(ipMovementDirection, ipInvSourceCardFeatures, ipMinusRemains);
            end;

            // �c����������� ���������
            if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
              SetTID(ibsqlCardList.ParamByName('companykey'), GetTID(gdcDocumentLine.FieldByName('companykey')));
            SetTID(ibsqlCardList.ParamByName('goodkey'), ipGoodKey);
            if not ipMinusRemains then
              SetTID(ibsqlCardList.ParamByName('contactkey'), ipSourceContactKey)
            else
              SetTID(ibsqlCardList.ParamByName('contactkey'), ipDestContactKey);

            if (not CurrentRemains) and not ipMinusRemains then
            begin
              if FEndMonthRemains then
              begin
                DecodeDate(IncMonth(ipDocumentDate, 1), Year, Month, Day);
                ibsqlCardList.ParamByName('movementdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
              end
              else
                ibsqlCardList.ParamByName('movementdate').AsDateTime := ipDocumentDate;
            end;

            if not (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
            begin
              if not ipMinusRemains then
              begin
                for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
                  if not ipInvSourceCardFeatures[i].IsNull then
                    SetFieldValue(ibsqlCardList.ParamByName(ipInvSourceCardFeatures[i].optFieldName), ipInvSourceCardFeatures[i])
              end
              else
                for i:= Low(ipInvMinusCardFeatures) to High(ipInvMinusCardFeatures) do
                  if not ipInvMinusCardFeatures[i].IsNull then
                    SetFieldValue(ibsqlCardList.ParamByName(ipInvMinusCardFeatures[i].optFieldName), ipInvMinusCardFeatures[i]);
            end
            else
              SetTID(ibsqlCardList.ParamByName('cardkey'), ipBaseCardKey);


            ibsqlCardList.ExecQuery;
            {$IFDEF DEBUGMOVE}
            TimeQueryList := TimeQueryList + GetTickCount - Times;
            Times := GetTickCount;
            {$ENDIF}
            while not ibsqlCardList.EOF do
            begin
            // �c�� �c����� �����c� ������� (�� ���� ��c������� ���������, �� �����c� ������ ����
            // �c�����
              if CurrentRemains or ipMinusRemains then
                tmpRemains := ibsqlCardList.FieldByName('Quantity').AsCurrency
              else

           // �c�� �c����� ���������c� �� ���� ���������, �� ��������c� ����������� �c�����
           // �� �c����� �� ���� ��������� � �� ���� ��c������� ���������
              tmpRemains := Min(ibsqlCardList.FieldByName('Quantity').AsCurrency,
                GetLastRemains(GetTID(ibsqlCardList.FieldByName('id')), ipSourceContactKey));

          // �����c��� �� �������� ������ ��� �c����� �� ��������� ��������, �� ���������
          // �������� �� �������� �c�����, � ��������� c����� �� ������c��� �� ���������
              if Quantity > tmpRemains
              then
              begin
                if tmpRemains > 0 then
                  Result := AddOneMovement(GetTID(ibsqlCardList.FieldByName('id')),
                    tmpRemains, InvPosition)
                else
                  Result := True;
              end
              else
              begin
                Result := AddOneMovement(GetTID(ibsqlCardList.FieldByName('id')),
                  Quantity, InvPosition);
              end;
              if not Result then
                Break;

         // ������� c�������� ��� ��������, �� ���������� �������
              if (tmpRemains > 0) and (tempCardKey = -1) then
                tempCardKey := GetTID(ibsqlCardList.FieldByName('id'));

              if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
              begin
                if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                  gdcDocumentLine.Edit;
                SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
                  GetTID(ibsqlCardList.FieldByName('id')));
                isChangeBaseCardKey := False
              end
              else
// �c�� �������� ���� ���c����� �� �c���� c����� ��������� �� �� ��������� � ��������� ��cc�� ��������

                if GetTID(gdcDocumentLine.FieldByName('fromcardkey')) =
                   GetTID(ibsqlCardList.FieldByName('id'))
                then
                  isChangeBaseCardKey := False;

              Quantity := Quantity - tmpRemains;

              if Quantity <= 0 then
              begin
                Quantity := 0;
                Break;
              end;

              ibsqlCardList.Next;

            end;

            // � c����� ����������c�� ������ �������� �� ����������
            // �� ���������� �������� � ��������� ����� �������c� � c�����
            // ��������������, ����� ���� �������� �������� ��� c�� �����
            // � �������.
            if isChangeBaseCardKey and (tempCardKey <> -1) then
            begin
              if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                gdcDocumentLine.Edit;
              SetTID(gdcDocumentLine.FieldByName('fromcardkey'), tempCardKey);
            end;
          finally
          end;
        end;

        if not ipDelayed then
        begin
          if (Quantity > 0) or (ipOneRecord and (Quantity < 0)) then
          begin
            if (not (tcrSource in ipCheckRemains)) or (ipOneRecord and (Quantity < 0)) then
            begin
              if ipOneRecord and (Quantity > 0) then
              begin
                Result := AddOneMovement(-1, -Quantity, InvPosition);
              end
              else
              begin
                Result := AddOneMovement(-1, abs(Quantity), InvPosition);
              end
            end
            else
            begin
              Result := False;
              FInvErrorCode := iecRemainsNotFound;
            end;
          end
          else
            Result := True;
        end
        else
          if (ipBaseCardKey <= 0) and (Quantity <> 0) then
          begin
            AddOneMovement(-1, Quantity, InvPosition);
          end;

        if Result then
          FInvErrorCode := iecNoErr;

        break;

      except
        on E: EIBError do
        begin
          if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
          begin
            if not (tcrSource in ipCheckRemains) then
            begin
              Result := AddOneMovement(-1, Quantity, InvPosition);
              Break;
            end
            else
            begin
              if (sLoadFromStream in gdcDocumentLine.BaseState) then raise;
              FInvErrorCode := iecRemainsLocked;

              if (gdcInvPositionSaveMode = ipsmPosition) and (gdcDocumentLine.State in [dsEdit, dsInsert])
              then
              begin
                Result := False;
                Break;
              end;

              if NoWait and (GetTickCount - Times > 10000) then
              begin
                Result := False;
                Break;
              end;
              Sleep(500);
            end
          end else
          begin
            Result := False;
            FInvErrorCode := iecOtherIBError;
            FInvErrorMessage := E.Message;
            Break;
          end;
        end else
        begin
          FInvErrorCode := iecUnknowError;
          Result := False;
          Break;
        end;
      end;

    until False;

  end;
end;

function TgdcInvMovement.MakeMovementFromPosition(var InvPosition: TgdcInvPosition;
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;
var
  tmpQuantity, oldQuantity: Currency;
  i: Integer;
  ChangeMove: TgdcChangeMovements;
  MovementKey: TID;
  ChangedField: TStringList;
  FSavePoint: String;
  isEdit: Boolean;
{$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
{$ENDIF}

begin

{$IFDEF DEBUGMOVE}
  TimeTmp := GetTickCount;
{$ENDIF}

  with InvPosition do
  begin

    FInvErrorCode := iecNoErr;
    Close;
    SetTID(ParamByName('documentkey'), ipDocumentKey);
    Open;

{

  c������ �������� �� ���� �� �������� �� ������ ������� (�c�� ���� ��������, ������
  ��������� ��������������

  �c�� ��� ���, �� ��� ���������� ���������, ��� ��������c�
  1. SourceContact, DestContact
  2. ������c���
  3. �����
  4. ��������
  5. ����

  1. �c�� ��������c� Source Contact ��� ��������c� ������c���, �� ����������
     ������� �������� (c�������� �������� � �� ����� �c����������).
  2. �c�� SourceContact � ������c��� ��������c�, �� ����������
     �������� DestContact (�c�� �� �������c�) � �������� � �������� ���������� ��������
     � �������� �c�� ��� ��������c� (������, �c�� ��� ����������� �c����������c� c�����
     �������� �� �� ������ c������ ����� � �������� �� � ��������).

     �c���� �c�� � ���������� �������������� ���� �������� �����-�� c���c���
     ���������� � �������� �c����������c� c�����, �� ���������� ������ ��������
     �� �c��������� c����� 1-�� ��c�������� ���� ��������. ������c� �� ������ ��c���������
     ��������� ����� �� FirstDocumentKey = DocumentKey �� ��������.
     �c�� �������c� Dest Contact, �� ������ ��� ��� �������� �� ����� �� ������ ���������
     ������ �� �c����� �� ��������� �� c����� (�c�� ����������).

     �������� � � ����� c������
  1. �������� �� �c����� � ���������� (c������). �������� �c���c������c� �� ������� ������.
     �) � c����� ��������� ������c���.
     �) � c����� ��������� ����������.
     �) � c����� c������� ����� ��������.
  2. �������� �� �c����� � �c�������. �� ������� ����.
     �) � c����� ��������� ������c���
     �) � c����� ��������� �c�������
     �) � c����� ��������� ���� ���
     �) � c����� ��������� ����.


  1. ���������� ����������, ��� ��������c�
  2. � ����c���c�� �� ����, ��� ��������c� �������� ��� ���������
     �) �����c��� ��������������� �������� (���c������� c������� ���������� ����������)
     �) �������� ��������� �������� ��������.
}
    ChangeMove := [];

    FIsCreateMovement := False;
    if (RecordCount > 0) and not ipDelayed then
    begin

// �������� �� �� ��� ��������c�

      ChangedField := TStringList.Create;

      try

        MovementKey := GetTID(FieldByName('MovementKey'));

        if ipDocumentDate <> FieldByName('movementdate').AsDateTime then
          ChangeMove := ChangeMove + [cmDate];

  // ��������c� c���c��� ������ ��������
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
          if not CompareOptValue(FieldByName(ipInvSourceCardFeatures[i].optFieldName), ipInvSourceCardFeatures[i])
          then
          begin
            ChangeMove := ChangeMove + [cmSourceFeature];
            Break;
          end;

  // �����c��� c������c� ��� � ����� �� ���������, ��� �c�� �������� ����c��������,
  // ������ �� ������ ��� ������ �� �������

        if not ipOneRecord then
          oldQuantity := GetQuantity(ipDocumentKey, tpAll)
        else
          if ipQuantity > 0 then
            oldQuantity := GetQuantity(ipDocumentKey, tpDebit)
          else
            if ipQuantity < 0 then
              oldQuantity := GetQuantity(ipDocumentKey, tpCredit)
            else
              oldQuantity := GetQuantity(ipDocumentKey, tpAll);

        if abs(ipQuantity) <> OldQuantity then    // ��������c� ������c���
          ChangeMove := ChangeMove + [cmQuantity];

        if GetTID(FieldByName('goodkey')) <> ipGoodKey then // �������c� �����
          ChangeMove := ChangeMove + [cmGood];

        if (FieldByName('credit').AsCurrency <> 0) and (GetTID(FieldByName('contactkey')) <>
           ipSourceContactKey) // �������c� �������-�c������ ������
        then
          ChangeMove := ChangeMove + [cmSourceContact];

        if (FieldByName('credit').AsCurrency <> 0) and not ipOneRecord then
          Next;

        if GetTID(FieldByName('MovementKey')) = MovementKey then
        begin
          if (FieldByName('debit').AsCurrency <> 0) and (GetTID(FieldByName('contactkey')) <>
              ipDestContactKey) // �������c� ����������
          then
            ChangeMove := ChangeMove + [cmDestContact];

          for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
            if not CompareOptValue(FieldByName(ipInvDestCardFeatures[i].optFieldName), ipInvDestCardFeatures[i])       // ��������c� c���c��� ���������� ��������
            then
            begin
              ChangeMove := ChangeMove + [cmDestFeature];
              ChangedField.Add(ipInvDestCardFeatures[i].optFieldName);
            end;
        end;

        if (ChangeMove = []) then // ��������� �������� �� �������� �� ����.
        begin
          Result := True;
          Exit;
        end;

        if (FieldByName('debit').AsCurrency > 0) and
           (ChangeMove = [cmQuantity]) and (ipQuantity > 0) and ipOneRecord
        then
        begin
          tmpQuantity := GetLastRemains(GetTID(FieldByName('cardkey')),
             GetTID(FieldByName('ContactKey'))) - FieldByName('debit').AsCurrency +
             abs(ipQuantity);

          if tmpQuantity >= 0 then
          begin
            // �c�� ��������c� �����c��� � ��������� ��c�� ��������� ����c��������
            // �c�� �����c��� �������, ���c�� ��� ������
            Edit;
            FieldByName('debit').AsCurrency := abs(ipQuantity);
            Post;
            Result := True;
            exit;
          end
          else
          begin
            FInvErrorCode := iecDontDecreaseQuantity;
            Result := False;
            exit;
          end;
        end;

  {
       �c�� ��������c� �������������� �������� �� �c���c������ ��������� ��������
  }
        Next;
        if ((GetTID(FieldByName('FirstDocumentKey')) = ipDocumentKey)) and
             FieldByName('Parent').IsNull and (RecordCount <= 2) and
             not (cmSourceFeature in ChangeMove)
        then
        begin
          if (ipDocumentDate > FieldByName('movementdate').AsDateTime) and not FCurrentRemains and
             (GetRemainsOnDate(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey')),
                ipDocumentDate - 1) < (FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency)) and
             IsMovementExists(GetTID(FieldByName('contactkey')), GetTID(FieldByName('cardkey')),
             GetTID(FieldByName('documentkey')), ipDocumentDate - 1) and not (sLoadFromStream in gdcDocumentLine.BaseState)
          then
          begin
          // ��������c� ���� ��������� � ��� ������ ��� ������ � ������ �c����� �� ������� ��� ����c��
          // ������� ������ �� ����� ������ ����
            FInvErrorCode := iecFoundEarlyMovement;
            Result := False;
            exit;
          end;

          if (ipSourceContactKey <> ipDestContactKey) or ipOneRecord then
            tmpQuantity := FieldByName('credit').AsCurrency - FieldByName('debit').AsCurrency
          else
            tmpQuantity := 0;

          if (tmpQuantity > 0) and ipOneRecord and (ipCheckRemains = []) then
//            Result := True
          else
          begin
            tmpQuantity := GetLastRemains(GetTID(FieldByName('cardkey')), GetTID(FieldByName('contactkey'))) +
               tmpQuantity + ipQuantity;

            if (tmpQuantity < 0)
            then
            begin
            // � ���������� ��������� - �c����� �� ������ ��� ���������� ����� c��������� ����c��
              FInvErrorCode := iecDontDecreaseQuantity;
              Result := False;
              exit;
            end;
          end;
          if ((cmDestContact in ChangeMove) or (cmGood in ChangeMove)) and
            IsMovementExists(GetTID(FieldByName('contactkey')),
              GetTID(FieldByName('cardkey')), GetTID(FieldByName('documentkey')))
          then
          begin
          // �������� ����� � c����� ��� ���-�� �c���������c�
            FInvErrorCode := iecDontChangeDest;
            Result := False;
            exit;
          end;

          if (cmDestFeature in ChangeMove) and (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
             not CheckMovementOnCard(GetTID(FieldByName('cardkey')), InvPosition)
          then
          begin
          // �������� �������� ���������� �������� � ��� ������� � �������������c��
            FInvErrorCode := iecDontChangeFeatures;
            Result := False;
            exit;
          end;

          if (cmDestFeature in ChangeMove) and
              IsMovementExists(GetTID(FieldByName('contactkey')),
              GetTID(FieldByName('cardkey')), GetTID(FieldByName('documentkey')))
              and (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
              not IsReplaceDestFeature(GetTID(FieldByName('contactkey')),
                GetTID(FieldByName('cardkey')), GetTID(FieldByName('documentkey')),
                ChangedField, InvPosition)
          then
          begin
          // �������� �������� ���������� �������� � ��� ������� � �������������c��
            FInvErrorCode := iecDontChangeFeatures;
            Result := False;
            exit;
          end;


          // �c� �������� ������ ����� �������� ��������
          Result := ModifyFirstMovement(GetTID(FieldByName('cardkey')), InvPosition);
          exit;
        end
        else
          if cmGood in ChangeMove then
            InvPosition.ipBaseCardKey := -1;

  {
      ��������� �c�� ������������� ��������� �� ������� ����c������� �������� ��
      ���c�� ����������� c��� ��������
  }

        if not ( (cmSourceContact in ChangeMove) or (cmGood in ChangeMove) or
                 (cmSourceFeature in ChangeMove) )
        then
        begin
          FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
               '-', '', [rfReplaceAll]), 1, 30);
          Transaction.SetSavePoint(FSavepoint);
          try
            Result := EditMovement(ChangeMove, InvPosition, gdcInvPositionSaveMode);
            if Result and (cmDate in ChangeMove) then
              Result := EditDateMovement(invPosition, gdcInvPositionSaveMode);
          except
            on E: Exception do
            begin
              Transaction.RollBackToSavePoint(FSavepoint);
              FInvErrorCode := iecOtherIBError;
              FInvErrorMessage := E.Message;
              Result := False;
            end;
          end;
          Transaction.ReleaseSavePoint(FSavepoint);

          exit;
        end
        else
          if ChangeMove = [cmDate] then
          begin
            Result := EditDateMovement(invPosition, gdcInvPositionSaveMode);
            exit;
          end;
      finally
        ChangedField.Free;
      end;

    end;

    Result := True;
    FIsCreateMovement := True;
    if gdcDocumentLine.State <> dsInsert then
    begin
      try
        SetEnableMovement(ipDocumentKey, False);
      except
        FInvErrorCode := iecDontDisableMovement;
        Result := False;
        exit;
      end;
    end;

    if (ipQuantity = 0) and gdcDocumentLine.FieldByName('fromcardkey').IsNull then
    begin
      if gdcDocumentLine.State in [dsEdit, dsInsert] then
      begin
        SetTID(gdcDocumentLine.FieldByName('fromcardkey'),  AddInvCard(-1, invPosition));
        if gdcDocumentLine.FindField('tocardkey') <> nil then
          SetTID(gdcDocumentLine.FieldByName('tocardkey'), GetTID(gdcDocumentLine.FieldByName('fromcardkey')));
        exit;
      end;
    end
    else
      if (ipQuantity = 0) then
      begin
        if GetTID(FieldByName('GoodKey')) = ipGoodKey then
        begin
          if gdcDocumentLine.FindField('tocardkey') = nil then
          begin
            ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')), ipInvDestCardFeatures)
          end
          else
          begin
            if GetTID(gdcDocumentLine.FieldByName('tocardkey')) <> GetTID(gdcDocumentLine.FieldByName('fromcardkey')) then
              ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('tocardkey')), ipInvDestCardFeatures)
            else
              SetTID(gdcDocumentLine.FieldByName('tocardkey'), AddInvCard(
                GetTID(gdcDocumentLine.FieldByName('fromcardkey')), invPosition));
          end;
        end
        else
        begin
          if GetTID(gdcDocumentLine.FieldByName('id')) =
            GetCardDocumentKey(GetTID(gdcDocumentLine.FieldByName('fromcardkey')))
          then
          begin
            ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
              ipInvSourceCardFeatures, True);
            if gdcDocumentLine.FindField('tocardkey') <> nil then
              ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('tocardkey')), ipInvDestCardFeatures, True);
          end
          else
          begin
            isEdit := (gdcDocumentLine.State in [dsEdit, dsInsert]);
            if not isEdit then
              gdcDocumentLine.Edit;
            if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
              SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
                AddInvCard(-1, InvPosition, False))
            else
              if not (gdcDocumentLine as TgdcInvDocumentLine).IsSetFeaturesFromRemains and
                ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtInventorization) then
                SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
                  AddInvCard(-1, InvPosition));
            if gdcDocumentLine.FindField('tocardkey') <> nil then
              SetTID(gdcDocumentLine.FieldByName('tocardkey'), AddInvCard(
                GetTID(gdcDocumentLine.FieldByName('fromcardkey')), invPosition));
          end
        end;
        exit;
      end;

    tmpQuantity := ipQuantity;

    if ipOneRecord then
      tmpQuantity := tmpQuantity * (-1);

    if not ipDelayed then
      Result := MakeMovementLine(tmpQuantity, InvPosition, gdcInvPositionSaveMode)
    else
    begin
      if (gdcDocumentLine.State = dsInsert) or (gdcDocumentLine.State = dsEdit) then
      begin
        if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
        begin
          if (gdcDocumentLine.FindField('tocardkey') <> nil) or
              (Length(ipInvDestCardFeatures) = 0)
          then
            SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
              AddInvCard(-1, InvPosition, False))
          else
            SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
              AddInvCard(-1, InvPosition, True))
        end
        else
          if (gdcDocumentLine.FindField('tocardkey') <> nil) or
              (Length(ipInvDestCardFeatures) = 0)
          then
          begin
            if not CompareCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
                   GetTID(gdcDocumentLine.FieldByName('goodkey')),
                 ipInvSourceCardFeatures)
            then
            begin
              if GetTID(gdcDocumentLine.FieldByName('id')) =
                GetCardDocumentKey(GetTID(gdcDocumentLine.FieldByName('fromcardkey')))
              then
                ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
                  ipInvSourceCardFeatures)
              else
                SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
                  AddInvCard(-1, InvPosition));
            end;
          end
          else
            if not CompareCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
                   GetTID(gdcDocumentLine.FieldByName('goodkey')),
                 ipInvDestCardFeatures)
            then
            begin
              if GetTID(gdcDocumentLine.FieldByName('id')) =
                GetCardDocumentKey(GetTID(gdcDocumentLine.FieldByName('fromcardkey')))
              then
                ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')),
                  ipInvDestCardFeatures)
              else
                SetTID(gdcDocumentLine.FieldByName('fromcardkey'),
                  AddInvCard(-1, InvPosition, True));
            end;

        if gdcDocumentLine.FindField('tocardkey') <> nil then
        begin
          if gdcDocumentLine.FieldByName('tocardkey').IsNull then
            SetTID(gdcDocumentLine.FieldByName('tocardkey'),
              AddInvCard(GetTID(gdcDocumentLine.FieldByName('fromcardkey')), InvPosition))
          else
            if not CompareCard(GetTID(gdcDocumentLine.FieldByName('tocardkey')),
                   GetTID(gdcDocumentLine.FieldByName('goodkey')),
                 ipInvDestCardFeatures)
            then
              ModifyInvCard(GetTID(gdcDocumentLine.FieldByName('tocardkey')),
                ipInvDestCardFeatures);

        end;
      end;
    end;
  end;

{$IFDEF DEBUGMOVE}
  TimeMakeMovement := TimeMakeMovement + GetTickCount - TimeTmp;
{$ENDIF}
end;

procedure TgdcInvMovement.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  CustomExecQuery('INSERT INTO INV_MOVEMENT (CONTACTKEY, CARDKEY, MOVEMENTKEY, MOVEMENTDATE, DOCUMENTKEY, DEBIT, CREDIT) values ' +
  ' (:NEW_CONTACTKEY, :NEW_CARDKEY, :NEW_MOVEMENTKEY, :NEW_MOVEMENTDATE, :NEW_DOCUMENTKEY, :NEW_DEBIT, :NEW_CREDIT)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    'UPDATE INV_MOVEMENT ' +
    'SET ' +
    '  CONTACTKEY = :CONTACTKEY, ' +
    '  MOVEMENTKEY = :MOVEMENTKEY, ' +
    '  CARDKEY = :CARDKEY, ' +
    '  MOVEMENTDATE = :MOVEMENTDATE, ' +
    '  DOCUMENTKEY = :DOCUMENTKEY, ' +
    '  DEBIT = :DEBIT, ' +
    '  CREDIT = :CREDIT ' +
    'WHERE ' +
    '  ID = :OLD_ID',
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

{ ������������ �����c� }

function TgdcInvMovement.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM inv_movement i LEFT JOIN inv_card c ON i.cardkey = c.id ';
  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'C';
  Ignore.IgnoryType := itReferences;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ORDER BY i.movementkey, i.debit ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' SELECT ' +
            '    i.id, ' +
            '    i.movementkey, ' +
            '    i.movementdate, ' +
            '    i.documentkey, ' +
            '    i.contactkey, ' +
            '    i.cardkey, ' +
            '    i.debit, ' +
            '    i.credit, ' +
            '    i.disabled, ' +
            '    i.reserved, ' +
            '    c.parent, ' +
            '    c.goodkey, ' +
            '    c.documentkey as carddocumentkey, ' +
            '    c.firstdocumentkey, ' +
            '    c.firstdate ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' i.documentkey = :documentkey and i.disabled = 0 ');
end;

procedure TgdcInvMovement.InitIBSQL;
var
  i: Integer;
  Fields, Values: String;
  atRelation: TatRelation;
begin
// ������������ �����c� ��� ������ ��������
  if ibsqlCardList.Transaction = Transaction then
    ibsqlCardList.Transaction := Transaction;

  if ibsqlLastRemains.SQL.Text <> '' then
  begin
    ibsqlLastRemains.SQL.Text := 'SELECT balance FROM inv_balance WHERE contactkey = :contactkey AND ' +
        ' cardkey = :cardkey ';
  end;

  if FibsqlCardInfo.SQL.Text = '' then
  begin
    FibsqlCardInfo.SQL.Text := 'SELECT * FROM inv_card WHERE id = :id';

    FibsqlCardInfo.Transaction := Transaction;

    if not Transaction.InTransaction then Transaction.StartTransaction;

    FibsqlCardInfo.Prepare;

  // ������������� �����c� ��� ���������� ��������
    atRelation := atDatabase.Relations.ByRelationName('inv_card');

    if atRelation <> nil then
    begin
      Fields := '(';
      Values := ' VALUES (';

      for i:= 0 to atRelation.RelationFields.Count - 1 do
      begin
        Fields := Fields + atRelation.RelationFields[i].FieldName;
        Values := Values + ':' + atRelation.RelationFields[i].FieldName;
        if i <> atRelation.RelationFields.Count - 1 then
        begin
          Fields := Fields + ',';
          Values := Values + ',';
        end;
      end;
      Fields := Fields + ')';
      Values := Values + ')';

      FibsqlAddCard.SQL.Text := 'INSERT INTO inv_card ' + Fields + Values;

      FibsqlAddCard.Transaction := Transaction;

      FibsqlAddCard.Prepare;
    end;
  end;
end;


function TgdcInvMovement.IsMovementExists(const aContactKey, aCardKey,
  aExcludeDocumentKey: TID; const aDocumentDate: TDateTime = 0): Boolean;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT id FROM inv_movement WHERE ' +
      'cardkey = :cardkey and documentkey <> :documentkey ';
    if aDocumentDate > 0 then
      ibsql.SQL.Text := ibsql.SQL.Text + ' and movementdate <= :movementdate ';
    if aContactKey > 0 then
      ibsql.SQL.Text := ibsql.SQL.Text + ' and  contactkey = :contactkey ';
    ibsql.Prepare;
    if aContactKey > 0 then
      SetTID(ibsql.ParamByName('contactkey'), aContactKey);
    if aDocumentDate > 0 then
      ibsql.ParamByName('movementdate').AsDateTime := aDocumentDate;
    SetTID(ibsql.ParamByName('cardkey'), aCardKey);
    SetTID(ibsql.ParamByName('documentkey'), aExcludeDocumentKey);
    ibsql.ExecQuery;
    Result := not ibsql.EOF;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.GetQuantity(const aDocumentKey: TID;
  TypePosition: TTypePosition): Currency;
var
  ibsql: TIBSQL;
begin
  Result := 0;
  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT SUM(debit) as Debit, SUM(credit) as Credit FROM inv_movement WHERE ' +
                      ' documentkey = :documentkey';
    ibsql.Prepare;
    SetTID(ibsql.ParamByName('documentkey'), aDocumentKey);
    ibsql.ExecQuery;
    if not ibsql.EOF then
    begin
      case TypePosition of
      tpAll:
        if ibsql.FieldByName('credit').AsCurrency <> 0 then
          Result := ibsql.FieldByName('credit').AsCurrency
        else
          Result := ibsql.FieldByName('debit').AsCurrency;
      tpDebit : Result := ibsql.FieldByName('debit').AsCurrency;
      tpCredit : Result := ibsql.FieldByName('credit').AsCurrency;
      end;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.GetCardInfo(const aCardKey: TID): Boolean;
begin
  if not FibsqlCardInfo.Open or  (GetTID(FibsqlCardInfo.ParamByName('id')) <> aCardKey) then
  begin
    FibsqlCardInfo.Close;
    SetTID(FibsqlCardInfo.ParamByName('id'), aCardKey);
    FibsqlCardInfo.ExecQuery;
  end;  
  Result := not FibsqlCardInfo.EOF;
end;

function TgdcInvMovement.GetLastRemains(const aCardKey,
  aContactKey: TID): Currency;
begin
  Result := 0;
  try
    ibsqlLastRemains.Close;
    if not Assigned(ibsqlLastRemains.Transaction) then
      ibsqlLastRemains.Transaction := ReadTransaction;
    if ibsqlLastRemains.SQL.Text = '' then
    begin
      ibsqlLastRemains.SQL.Text := 'SELECT balance FROM inv_balance WHERE contactkey = :contactkey AND ' +
          ' cardkey = :cardkey ';
    end;
    SetTID(ibsqlLastRemains.ParamByName('contactkey'), aContactKey);
    SetTID(ibsqlLastRemains.ParamByName('cardkey'), aCardKey);
    ibsqlLastRemains.ExecQuery;
    if not ibsqlLastRemains.EOF then
      Result := ibsqlLastRemains.FieldByName('balance').AsCurrency;
    ibsqlLastRemains.Close;  
  finally
  end;
end;

function TgdcInvMovement.GetRemainsOnDate(const aCardKey,
  aContactKey: TID; aDate: TDateTime): Currency;
var
  ibsql: TIBSQL;
begin
  Result := 0;
  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT SUM(m.debit - m.credit) as balance FROM inv_movement m ' +
       ' WHERE m.cardkey = :cardkey and m.contactkey = :contactkey and ' +
       ' m.movementdate <= :movementdate';
    ibsql.Prepare;
    SetTID(ibsql.ParamByName('cardkey'), aCardKey);
    SetTID(ibsql.ParamByName('contactkey'), aContactKey);
    ibsql.ParamByName('movementdate').AsDateTime := aDate;
    ibsql.ExecQuery;
    if not ibsql.EOF then
      Result := ibsql.FieldByName('balance').AsCurrency;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.CreateMovement(
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;
var
  FInvPosition: TgdcInvPosition;
  isOk: Boolean;
  Field: TatRelationField;
begin

  Result := False;

  if FIsLocalPost then exit;

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('�� ����� ���cc ������� ���������');

  Assert(gdcDocumentLine is TgdcInvBaseDocument, '������� ��� ������� ��� ������������ ��������');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('�� ������� ��������� �� ����� ���� c������ ��������');

  if not Assigned(gdcDocumentLine.MasterSource) or not Assigned(gdcDocumentLine.MasterSource.DataSet) then
    exit;

  FillPosition(gdcDocumentLine, FInvPosition);

  if FInvPosition.ipSourceContactKey <= 0 then
  begin
    with (gdcDocumentLine as TgdcInvBaseDocument) do
      Field := atDatabase.FindRelationField(MovementSource.RelationName, MovementSource.SourceFieldName);
    raise EgdcInvMovement.Create(Format('� ������� ��������� �� ��������� ���� %s', [Field.FieldName]));
  end;

  if FInvPosition.ipDestContactKey <= 0 then
  begin
    with (gdcDocumentLine as TgdcInvBaseDocument) do
      Field := atDatabase.FindRelationField(MovementTarget.RelationName, MovementTarget.SourceFieldName);
    raise EgdcInvMovement.Create(Format('� ������� ��������� �� ��������� ���� %s', [Field.FieldName]));
  end;

  Result := MakeMovementFromPosition(FInvPosition, gdcInvPositionSaveMode);
  Close;
  if (gdcDocumentLine.State <> dsInsert) and FIsCreateMovement then
  begin
    isOK := Result and (FInvErrorCode = iecNoErr);
    if InvErrorCode <> iecDontDisableMovement then
      DeleteEnableMovement(FInvPosition.ipDocumentKey, not IsOk);
    if not isOK then
      SetEnableMovement(FInvPosition.ipDocumentKey, True);
  end
  else
    if (not Result or (FInvErrorCode <> iecNoErr)) and FIsCreateMovement then
    begin
      if State in [dsEdit, dsInsert] then
        Cancel;
      DeleteEnableMovement(FInvPosition.ipDocumentKey, True);
    end;
  if not Result then
    raise EgdcInvMovement.Create('��� ������������ �������� �� ������� ' +
      gdcDocumentLine.FieldByName('GOODNAME').AsString + ' ��������� c�������� ������: ' +
      Format(gdcInvErrorMessage[InvErrorCode], [FInvErrorMessage]))
  else
  begin
    if (InvErrorCode = iecNoErr) and (gdcDocumentLine.FieldByName('linedisabled').AsInteger = 1) then
    begin
      if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
        gdcDocumentLine.Edit;
      gdcDocumentLine.FieldByName('linedisabled').AsInteger := 0;
    end;
  end;
end;

function TgdcInvMovement.CreateAllMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument;
      const IsOnlyDisabled: Boolean = False): Boolean;
var
  Bookmark: TBookmark;
  OldIsGetRemains: Boolean;
  IsTransaction: Boolean;
{$IFDEF DEBUGMOVE}
  Times: LongWord;
  TimesPost: LongWord;
  PerTimes: LongWord;
{$ENDIF}
begin
  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('�� ����� ���cc ������� ���������');

  Result := True;

  if gdcDocumentLine.RecordCount = 0 then
    exit;

{$IFDEF DEBUGMOVE}
  Times := GetTickCount;
  TimesPost := 0;
{$ENDIF}
  isTransaction := gdcDocumentLine.Transaction.InTransaction;
  Bookmark := gdcDocumentLine.GetBookmark;
  gdcDocumentLine.DisableControls;
  try
    if not isTransaction then
      gdcDocumentLine.Transaction.StartTransaction;
    FCountPositionChanged := 0;
    gdcDocumentLine.First;
    while not gdcDocumentLine.EOF do
    begin
      if not isOnlyDisabled or (gdcDocumentLine.FieldByName('linedisabled').AsInteger = 1) then
      begin
        Result := CreateMovement(gdcInvPositionSaveMode);
        if not Result then
          Break;
        Inc(FCountPositionChanged);
      end;
      if gdcDocumentLine.State in [dsInsert, dsEdit] then
      begin
        {$IFDEF DEBUGMOVE}
          PerTimes := GetTickCount;
        {$ENDIF}
        FIsLocalPost := True;
        OldIsGetRemains := FIsGetRemains;
        FIsGetRemains := False;
        try
          gdcDocumentLine.Post;
        finally
          FIsLocalPost := False;
          FIsGetRemains := OldIsGetRemains;
        end;
        {$IFDEF DEBUGMOVE}
          TimesPost := TimesPost + GetTickCount - PerTimes;
        {$ENDIF}
      end;
      gdcDocumentLine.Next;
    end;
  finally
    if gdcDocumentLine.State in [dsEdit, dsInsert] then
      gdcDocumentLine.Cancel;

    if not isTransaction then
    begin
      if not Result then
        gdcDocumentLine.Transaction.Rollback
      else
        gdcDocumentLine.Transaction.Commit;
    end;

    gdcDocumentLine.EnableControls;
    gdcDocumentLine.GotoBookmark(Bookmark);
    gdcDocumentLine.FreeBookmark(Bookmark);
  end;
{$IFDEF DEBUGMOVE}
  Times := GetTickCount - Times;
  ShowMessage('All ' + IntToStr(Times) + ' QueryList ' + IntToStr(TimeQueryList)
    + ' Post ' + IntToStr(TimesPost) + ' AllMovement ' + IntToStr(TimeMakeMovement) +
    ' AddPos ' + IntToStr(TimeMakePos));
{$ENDIF}

end;

function TgdcInvMovement.GetRemains_GetQueryNew(InvPosition: TgdcInvPosition): String;
var
  I: Integer;
  S: String;
  AdditionalFeatureClause: String;
begin
  // ����������� �� ������������ ��������� ��������
  AdditionalFeatureClause := '';
  for I := Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
    if InvPosition.ipInvSourceCardFeatures[i].isID then
      if InvPosition.ipInvSourceCardFeatures[i].IsNull then
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName
    else
      if InvPosition.ipInvSourceCardFeatures[i].IsNull then
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' IS NULL '
      else
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
    AdditionalFeatureClause := AdditionalFeatureClause +
      ' AND c.companykey + 0 = ' + TID2S(GetTID(gdcDocumentLine.FieldByName('companykey')));

  // ���� ����� ��������������� � �� ������� �������
  if not CurrentRemains and not InvPosition.ipMinusRemains then
  begin
    S :=
      'SELECT' + #13#10 +
      '  MIN(mm.cardkey) AS cardkey,' + #13#10 +
      '  SUM(mm.balance) AS remains' + #13#10 +
      'FROM' + #13#10 +
      '  (' + #13#10 +
      '     SELECT' + #13#10 +
      '       bal.cardkey AS cardkey,' + #13#10 +
      '       bal.balance' + #13#10 + 
      '     FROM' + #13#10 +
      '       inv_balance bal' + #13#10 + 
      '       LEFT JOIN inv_card c ON c.id = bal.cardkey' + #13#10 +
      '     WHERE' + #13#10 +
      '       bal.contactkey = :contactkey' + #13#10 +
      '       AND bal.goodkey = :goodkey' + #13#10 +
        AdditionalFeatureClause +
      ' ' +
      '     UNION ALL' + #13#10 +
      ' ' +
      '     SELECT' + #13#10 +
      '       m.cardkey AS cardkey,' + #13#10 +
      '       - (m.debit - m.credit) AS balance' + #13#10 +
      '     FROM' + #13#10 +
      '       inv_movement m' + #13#10 +
      '       LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
      '     WHERE' + #13#10 +
      '      m.movementdate > :movementdate' + #13#10 +
      '      AND m.contactkey = :contactkey' + #13#10 +
      '      AND m.goodkey = :goodkey' + #13#10 +
      '      AND m.disabled = 0' + #13#10 +
      '      AND m.documentkey <> :documentkey ' + #13#10 +        
        AdditionalFeatureClause +
      '  ) mm';
  end
  else
  begin
    S :=
        'SELECT ' + #13#10 +
        '  MIN(b.cardkey + 0) as cardkey, ' + #13#10 +
        '  SUM(b.balance) AS remains ' + #13#10 +
        'FROM' + #13#10 +
        '  inv_balance b ' + #13#10 +
        '  LEFT JOIN inv_card c ON c.id = b.balance ' + #13#10 +
        'WHERE ' + #13#10 +
        '  b.goodkey = :goodkey ' + #13#10 +
        '  AND b.contactkey = :contactkey' + #13#10 + AdditionalFeatureClause;
  end;

  Result := S;
end;

function TgdcInvMovement.GetRemains_GetQueryOld(InvPosition: TgdcInvPosition): String;
var
  I: Integer;
  S: String;
begin
  if not CurrentRemains and not InvPosition.ipMinusRemains then
  begin
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False)
       or (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil) then
      S :=
          'SELECT' + #13#10 +
          '  MIN(m.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(m.debit - m.credit) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  LEFT JOIN inv_movement m ON m.cardkey = c.id' + #13#10 +
          'WHERE' + #13#10 +
          '  c.goodkey = :goodkey' + #13#10 +
          '  AND m.contactkey = :contactkey ' + #13#10 +
          '  AND m.movementdate <= :movementdate ' + #13#10 +
          '  AND m.documentkey <> :documentkey' + #13#10 +
          '  AND m.disabled = 0'
    else
      S :=
          'SELECT' + #13#10 +
          '  MIN(m.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(m.debit - m.credit) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  JOIN inv_movement m ON (m.cardkey = c.id)' + #13#10 +
          '    AND m.goodkey = :goodkey ' + #13#10 +
          '    AND m.contactkey = :contactkey ' + #13#10 +
          '    AND m.movementdate <= :movementdate ' + #13#10 +
          '    AND m.documentkey <> :documentkey' + #13#10 +
          '    AND m.disabled = 0';
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      S := S + ' AND c.companykey + 0 = ' + TID2S(GetTID(gdcDocumentLine.FieldByName('companykey')));
  end
  else
  begin
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False)
       or (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil) then
      S :=
          'SELECT' + #13#10 + 
          '  MIN(b.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(b.balance) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  LEFT JOIN inv_balance b ON b.cardkey = c.id' + #13#10 +
          'WHERE' + #13#10 +
          '  c.goodkey = :goodkey' + #13#10 +
          '  AND b.contactkey = :contactkey' +
          #13#10
    else
      S :=
          'SELECT' + #13#10 +
          '  MIN(b.cardkey + 0) as cardkey,' + #13#10 +
          '  SUM(b.balance) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  JOIN inv_balance b ON b.cardkey = c.id' + #13#10 +
          '    AND b.goodkey = :goodkey ' + #13#10 +
          '    AND b.contactkey = :contactkey' +
          #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      S := S + ' AND c.companykey + 0 = ' + TID2S(GetTID(gdcDocumentLine.FieldByName('companykey')));
  end;

  for i:= Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
    if InvPosition.ipInvSourceCardFeatures[i].isID then
      if InvPosition.ipInvSourceCardFeatures[i].IsNull then
        S := S + ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        S := S + ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName
    else
      if InvPosition.ipInvSourceCardFeatures[i].IsNull then
        S := S + ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' IS NULL '
      else
        S := S + ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName;

  Result := S;
end;

function TgdcInvMovement.GetRemains: Currency;
var
  ibsql: TIBSQL;
  i: Integer;
  InvPosition: TgdcInvPosition;
  DocQuantity: Currency;
  Day, Month, Year: Word;
{$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
{$ENDIF}
begin
  Result := 0;

  if not FIsGetRemains then
    exit;

{$IFDEF DEBUGMOVE}
  TimeTmp := GetTickCount;
{$ENDIF}

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('�� ��������� ���cc ������� ���������');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('�� ������� ��������� �� ����� ���� c������ ��������');

  FillPosition(gdcDocumentLine, InvPosition);

  if InvPosition.ipDelayed and (sLoadFromStream in gdcDocumentLine.BaseState) then
    exit;

  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    // ���� ������ Firebird 2.0+, � ���� ���� GOODKEY � INV_MOVEMENT � INV_BALANCE,
    //   �� ����� ����� ������� ������ ���������
    if FUseSelectFromSelect
       and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY'))
       and GlobalStorage.ReadBoolean('Options\Invent', 'UseNewRemainsMethod', False, False) then
      ibsql.SQL.Text := GetRemains_GetQueryNew(InvPosition)
    else
      ibsql.SQL.Text := GetRemains_GetQueryOld(InvPosition);
    ibsql.Prepare;

    if not CurrentRemains and not InvPosition.ipMinusRemains then
    begin
      DocQuantity := 0;
      SetTID(ibsql.ParamByName('documentkey'), InvPosition.ipDocumentKey);

      if FEndMonthRemains then
      begin
        DecodeDate(IncMonth(InvPosition.ipDocumentDate, 1), Year, Month, Day);
        ibsql.ParamByName('movementdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
      end
      else
        ibsql.ParamByName('movementdate').AsDateTime := InvPosition.ipDocumentDate;
    end
    else
    begin
      if gdcDocumentLine.State <> dsInsert then
        DocQuantity := GetQuantity(InvPosition.ipDocumentKey, tpAll)
      else
        DocQuantity := 0;
    end;

    SetTID(ibsql.ParamByName('goodkey'), InvPosition.ipGoodKey);
    SetTID(ibsql.ParamByName('ContactKey'), InvPosition.ipSourceContactKey);

    for i:= Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
      if not InvPosition.ipInvSourceCardFeatures[i].IsNull then
        SetFieldValue(ibsql.ParamByName(InvPosition.ipInvSourceCardFeatures[i].optFieldName), InvPosition.ipInvSourceCardFeatures[i]);

    ibsql.ExecQuery;
    if (not ibsql.EOF) and (GetTID(ibsql.FieldByName('cardkey')) > 0) then
    begin
      Result := ibsql.FieldByName('remains').AsCurrency;
      if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
        gdcDocumentLine.Edit;
      SetTID(gdcDocumentLine.FieldByName('FromCardKey'),
        GetTID(ibsql.FieldByName('cardkey')));
      if (gdcDocumentLine.FindField('tocardkey') <> nil) and
         gdcDocumentLine.FieldByName('tocardkey').IsNull
      then
        SetTID(gdcDocumentLine.FieldByName('tocardkey'),
          GetTID(ibsql.FieldByName('cardkey')));
      if gdcDocumentLine.FindField('remains') <> nil then
      begin
        gdcDocumentLine.FieldByName('remains').ReadOnly := False;
        try
          gdcDocumentLine.FieldByName('remains').AsCurrency :=
            ibsql.FieldByName('remains').AsCurrency + DocQuantity;
        finally
          gdcDocumentLine.FieldByName('remains').ReadOnly := True;
        end;
      end
      else
        if gdcDocumentLine.State = dsInsert then
        begin
          if gdcDocumentLine.FindField('fromquantity') <> nil then
          begin
            gdcDocumentLine.FieldByName('fromquantity').ReadOnly := False;
            try
              gdcDocumentLine.FieldByName('fromquantity').AsCurrency :=
                ibsql.FieldByName('remains').AsCurrency + DocQuantity;
            finally
              gdcDocumentLine.FieldByName('fromquantity').ReadOnly := True;
            end;
          end;
        end;  
    end
    else
    begin
      if (tcrSource in InvPosition.ipCheckRemains) then
      begin
        FInvErrorCode := iecGoodNotFound;
        raise EgdcInvMovement.Create(Format('�� ������� %s �������� c�������� ������: %s',
          [gdcDocumentLine.FieldByName('GOODNAME').AsString,
          Format(gdcInvErrorMessage[InvErrorCode], [FInvErrorMessage])]));
      end;
    end;

    ibsql.Close;
  finally
    ibsql.Free;
  end;

{$IFDEF DEBUGMOVE}
  TimeGetRemains := GetTickCount - TimeTmp;
{$ENDIF}
end;

function TgdcInvMovement.SelectGoodFeatures: Boolean;
var
  InvPosition: TgdcInvPosition;
begin
  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('�� ��������� ���cc ������� ���������');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('�� ������� ��������� �� ����� ���� c������ ��������');

  FillPosition(gdcDocumentLine, InvPosition);

  Result := ShowRemains(InvPosition, True);
end;

function TgdcInvMovement.ChooseRemains(const isMakePosition: Boolean = True): Boolean;
var
  InvPosition: TgdcInvPosition;
begin

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('�� ��������� ���cc ������� ���������');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('�� ������� ��������� �� ����� ���� c������ ��������');


  try
    (gdcDocumentLine as TgdcInvDocumentLine).isChooseRemains := True;
    FillPosition(gdcDocumentLine, InvPosition);

    Result := ShowRemains(InvPosition, False);
  finally
    (gdcDocumentLine as TgdcInvDocumentLine).isChooseRemains := False;
  end;
end;

function TgdcInvMovement.ShowRemains(var InvPosition: TgdcInvPosition;
  const isPosition: Boolean): Boolean;
var
  S: String;
  C: CgdcCreateableForm;
  isDest: Boolean;
  Field: TField;
begin
  if isPosition then
  begin
    S := cst_ByGoodKey;
    C := Tgdc_frmInvSelectGoodRemains;
  end
  else
  begin
    S := cst_ByGroupKey;
    C := Tgdc_frmInvSelectRemains;
  end;
  
  if (Self.gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation then
  begin
    Field := Self.gdcDocumentLine.FindField('INQUANTITY');
    isDest := Assigned(Field);
  end
  else
    isDest := False;

  with Tgdc_frmInvSelectRemains(C.CreateSubType(gdcDocumentLine, gdcDocumentLine.SubType)) do
    try
        Assert(Assigned(gdcObject),
         '�� ����� ������ ���� ��������, ������ ����� ������������ ���������� ������� OnCreate');

      (gdcObject as TgdcInvRemains).SetOptions(InvPosition, Self, isPosition, isDest);
      Setup((gdcObject as TgdcInvRemains));
      SetChoose(gdcDocumentLine);
      Result := ShowModal = mrOk;
      if Result then
      begin
        UserStorage.WriteBoolean('Options\Invent', 'CurrentRemains', (gdcObject as TgdcInvRemains).CurrentRemains);
        if gdcObject.HasSubSet(cst_AllRemains) then
          UserStorage.WriteBoolean('Options\Invent', 'AllRemains', True)
        else
          UserStorage.WriteBoolean('Options\Invent', 'AllRemains', False);
      end;
    finally
      Free;
    end;
end;

class function TgdcInvMovement.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvMovement.GetListField(const ASubType: TgdcSubType): String;
begin                       
  Result := 'ID';
end;

class function TgdcInvMovement.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

procedure TgdcInvMovement.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  InitIBSQL;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  for i:= 0 to FieldCount - 1 do
    Fields[i].Required := False;
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.FillPosition(gdcDocumentLine: TgdcDocument;
  var InvPosition: TgdcInvPosition);
var
  i: Integer;
  MasterDataSet: TgdcInvDocument;
  MasterCreate: Boolean;
  DidActivate: Boolean;
  CE: TgdClassEntry;
{$IFDEF DEBUGMOVE}
TempTime: Longint;
{$ENDIF}
begin
{$IFDEF DEBUGMOVE}
  TempTime := GetTickCount;
{$ENDIF}
  with InvPosition do
  begin
    if Assigned(gdcDocumentLine.MasterSource) and
      Assigned(gdcDocumentLine.MasterSource.DataSet) then
    begin
      MasterDataSet := gdcDocumentLine.MasterSource.DataSet as TgdcInvDocument;
      MasterCreate := False;
    end else
    begin
      MasterDataSet := TgdcInvDocument.CreateSubType(nil,
        gdcDocumentLine.SubType, 'ByID') as TgdcInvDocument;
      MasterCreate := True;
    end;

    try
      DidActivate := False;
      try
        if MasterCreate then
        begin
          DidActivate := ActivateTransaction;
          MasterDataSet.ReadTransaction := gdcDocumentLine.Transaction;
          MasterDataSet.ID := GetTID(gdcDocumentLine.FieldByName('parent'));
          MasterDataSet.Open;
        end;

        ipDocumentKey := GetTID(gdcDocumentLine.FieldByName('documentkey'));
        ipDocumentDate := MasterDataSet.FieldByName('documentdate').AsDateTime;

        ipQuantity := gdcDocumentLine.FieldByName('quantity').AsCurrency;
        if (gdcDocumentLine.FindField('INQUANTITY') <> nil) or (gdcDocumentLine.FindField('OUTQUANTITY') <> nil) then
        begin
          ipQuantity := 0;
          if gdcDocumentLine.FindField('INQUANTITY') <> nil then
            ipQuantity := gdcDocumentLine.FieldByName('INQUANTITY').AsCurrency;
          if gdcDocumentLine.FindField('OUTQUANTITY') <> nil then
            ipQuantity := ipQuantity - gdcDocumentLine.FieldByName('OUTQUANTITY').AsCurrency;
        end    
        else
          if (gdcDocumentLine.FindField('FROMQUANTITY') <> nil) or (gdcDocumentLine.FindField('TOQUANTITY') <> nil) then
          begin
            ipQuantity := gdcDocumentLine.FieldByName('TOQUANTITY').AsCurrency -
              gdcDocumentLine.FieldByName('FROMQUANTITY').AsCurrency
          end;

        ipGoodKey := GetTID(gdcDocumentLine.FieldByName('goodkey'));
        if (gdcDocumentLine.State = dsEdit) and ((gdcDocumentLine.FieldByName('QUANTITY').OldValue = Null) or
           (gdcDocumentLine.FieldByName('QUANTITY').OldValue = 0)) and
           not (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources)
        then
          ipBaseCardKey := -1
        else
          ipBaseCardKey := GetTID(gdcDocumentLine.FieldByName('fromcardkey'));

        FCurrentRemains := (gdcDocumentLine as TgdcInvDocumentLine).LiveTimeRemains;
        FEndMonthRemains := (gdcDocumentLine as TgdcInvDocumentLine).EndMonthRemains;
        ipMinusRemains := (gdcDocumentLine as TgdcInvDocumentLine).isMinusRemains;
        if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation) and
           (gdcDocumentLine.FindField('OUTQUANTITY') <> nil) and
           (gdcDocumentLine.FieldByName('OUTQUANTITY').AsCurrency > 0)
        then
          ipMinusRemains := False;   

        with (gdcDocumentLine as TgdcInvBaseDocument) do
        begin
          CE := gdClassList.Get(TgdDocumentEntry, ClassName, SubType).GetRootSubType;
          if
            (AnsiCompareText(MovementSource.RelationName, TgdDocumentEntry(CE).HeaderRelName) = 0)
               and (MovementSource.SourceFieldName > '')
          then
            ipSourceContactKey := GetTID(MasterDataSet.
              FieldByName(MovementSource.SourceFieldName))
          else

          if (MovementSource.SourceFieldName > '') then
            ipSourceContactKey := GetTID(FieldByName(MovementSource.SourceFieldName));

          if (AnsiCompareText(MovementTarget.RelationName, TgdDocumentEntry(CE).HeaderRelName) = 0) and
             (MovementTarget.SourceFieldName > '')
          then
            ipDestContactKey := GetTID(MasterDataSet.
              FieldByName(MovementTarget.SourceFieldName))
          else

          if (MovementTarget.SourceFieldName > '') then
            ipDestContactKey := GetTID(FieldByName(MovementTarget.SourceFieldName));

    // �c����������� �������� ��������� �������������

          ipSubSourceContactKey := -1;
          ipSubDestContactKey := -1;

          if
            (AnsiCompareText(MovementSource.SubRelationName, TgdDocumentEntry(CE).HeaderRelName) = 0) and
            (MovementSource.SubSourceFieldName > '')
          then
            ipSubSourceContactKey := GetTID(MasterDataSet.
              FieldByName(MovementSource.SubSourceFieldName))
          else

          if (MovementSource.SubSourceFieldName > '') then
            ipSubSourceContactKey := GetTID(FieldByName(MovementSource.SubSourceFieldName));

          if (AnsiCompareText(MovementTarget.SubRelationName, TgdDocumentEntry(CE).HeaderRelName) = 0) and
             (MovementTarget.SubSourceFieldName > '')
          then
            ipSubDestContactKey := GetTID(MasterDataSet.
              FieldByName(MovementTarget.SubSourceFieldName))
          else

          if (MovementTarget.SubSourceFieldName > '') then
            ipSubDestContactKey := GetTID(FieldByName(MovementTarget.SubSourceFieldName));

          SetLength(ipPredefinedSourceContact,
            High(MovementSource.Predefined) - Low(MovementSource.Predefined) + 1);
          for i:= Low(MovementSource.Predefined) to High(MovementSource.Predefined) do
            ipPredefinedSourceContact[i] := MovementSource.Predefined[i];

          SetLength(ipPredefinedDestContact,
            High(MovementTarget.Predefined) - Low(MovementTarget.Predefined) + 1);
          for i:= Low(MovementTarget.Predefined) to High(MovementTarget.Predefined) do
            ipPredefinedDestContact[i] := MovementTarget.Predefined[i];

          SetLength(ipSubPredefinedSourceContact,
            High(MovementSource.SubPredefined) - Low(MovementSource.SubPredefined) + 1);
          for i:= Low(MovementSource.SubPredefined) to High(MovementSource.SubPredefined) do
            ipSubPredefinedSourceContact[i] := MovementSource.SubPredefined[i];

          SetLength(ipSubPredefinedDestContact,
            High(MovementTarget.SubPredefined) - Low(MovementTarget.SubPredefined) + 1);
          for i:= Low(MovementTarget.SubPredefined) to High(MovementTarget.SubPredefined) do
            ipSubPredefinedDestContact[i] := MovementTarget.SubPredefined[i];
        end;

        if not (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources) or
          (gdcDocumentLine.FieldByName('fromcardkey').IsNull and not (gdcDocumentLine as TgdcInvDocumentLine).ControlRemains)
        then
          ipCheckRemains := [tcrDest]
        else
          if (gdcDocumentLine as TgdcInvDocumentLine).ControlRemains then
            ipCheckRemains := [tcrSource]
          else
            ipCheckRemains := [];


        ipMovementDirection := (gdcDocumentLine as TgdcInvDocumentLine).Direction;

        if (gdcDocumentLine as TgdcInvDocumentLine).CanBeDelayed then
          ipDelayed :=
           MasterDataSet.FieldByName('DELAYED').AsInteger <> 0
        else
          ipDelayed := False;

        SetLength(ipInvSourceCardFeatures, 0);

        if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtTransformation) or
           ((gdcDocumentLine as TgdcInvDocumentLine).ViewMovementPart = impExpense) or
           (((gdcDocumentLine as TgdcInvDocumentLine).FindField('OUTQUANTITY') <> nil) and
           ((gdcDocumentLine as TgdcInvDocumentLine).FieldByName('OUTQUANTITY').AsCurrency > 0))
        then
        begin

          SetLength(ipInvSourceCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) + 1);

          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) do

            SetOptValue(ipInvSourceCardFeatures[i], gdcDocumentLine.FieldByName(
                  INV_SOURCEFEATURE_PREFIX +
                  (gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures[i]));

        end;

        SetLength(ipInvMinusCardFeatures, 0);
        if ipMinusRemains then
        begin
          SetLength(ipInvMinusCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) + 1);

          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) do
            SetOptValue(ipInvMinusCardFeatures[i], gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures[i]));

        end;

        SetLength(ipInvDestCardFeatures, 0);

        if (((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtTransformation) or
           ((gdcDocumentLine as TgdcInvDocumentLine).ViewMovementPart = impIncome) or
           (((gdcDocumentLine as TgdcInvDocumentLine).FindField('INQUANTITY') <> nil) and
           ((gdcDocumentLine as TgdcInvDocumentLine).FieldByName('INQUANTITY').AsCurrency > 0))) 

        then
        begin

          SetLength(ipInvDestCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) + 1);


          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) do

            SetOptValue(ipInvDestCardFeatures[i], gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).DestFeatures[i]));


        end;

        ipOneRecord := ((gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInventorization) or
          ((gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtTransformation);

        if DidActivate and gdcDocumentLine.Transaction.InTransaction then
          gdcDocumentLine.Transaction.Commit;

      except
        if DidActivate and gdcDocumentLine.Transaction.InTransaction then
          gdcDocumentLine.Transaction.Rollback;
      end;

    finally
      if MasterCreate then
        MasterDataSet.Free;
    end;
  end;
{$IFDEF DEBUGMOVE}
TimeFillPosition := TimeFillPosition + GetTickCount - TempTime; 
{$ENDIF}
end;

procedure TgdcInvMovement.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FgdcDocumentLine) and (Operation = opRemove) then
    FgdcDocumentLine := nil;
end;

function TgdcInvMovement.SetEnableMovement(const aDocumentKey: TID;
  const isEnabled: Boolean): Boolean;
begin
  Close;
  ExecSingleQuery(Format('UPDATE inv_movement SET disabled = %d WHERE documentkey = %d',
    [Integer(not isEnabled), aDocumentKey]));
  Open;
  Result := True;
end;

function TgdcInvMovement.DeleteEnableMovement(const aDocumentKey: TID;
  const isEnabled: Boolean): Boolean;
begin
  ExecSingleQuery(Format('DELETE FROM inv_movement WHERE disabled = %d AND documentkey = %d',
      [Integer(not isEnabled), aDocumentKey]));
  Result := True;
end;

function TgdcInvMovement.CheckMovementOnCard(const aCardKey: TID;
  var InvPosition: TgdcInvPosition): Boolean;
var
  ibsqlGetCards: TIBSQL;
  ibsqlCardMovement: TIBSQL;
  ibsqlCard: TIBSQL;
  i, IndexField: Integer;
  FieldList: TStringList;
  InvDocument: TgdcInvBaseDocument;
  isChange, isFirst: Boolean;
  S: String;
  //Stream: TStream;
begin
  Result := True;
  ibsqlCardMovement := TIBSQL.Create(nil);
  ibsqlGetCards := TIBSQL.Create(nil);

  FieldList := TStringList.Create;
  try
    GetCardInfo(aCardKey);

    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if not CompareOptValue(FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName), InvPosition.ipInvDestCardFeatures[i])
      then
        FieldList.Add(InvPosition.ipInvDestCardFeatures[i].optFieldName);

    ibsqlCardMovement.Transaction := Transaction;

    ibsqlCardMovement.SQL.Text :=
      ' SELECT '#13#10 +
      '   c.*, doct.id as doctypekey, doct.options, doc.id as dockey, doct.ruid '#13#10 +
      ' FROM inv_card c '#13#10 +
      '   LEFT JOIN inv_movement m '#13#10 +
      '     ON m.cardkey = c.id '#13#10 +
      '   LEFT JOIN gd_document doc '#13#10 +
      '     ON m.documentkey = doc.id '#13#10 +
      '   LEFT JOIN gd_documenttype doct '#13#10 +
      '     ON doc.documenttypekey = doct.id '#13#10 +
      ' WHERE c.id = :id  ';
    S := '';
    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if not CompareOptValue(FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName), InvPosition.ipInvDestCardFeatures[i])
      then
      begin
        if S > '' then
          S := S + ' OR ';
        if InvPosition.ipInvDestCardFeatures[i].isID then
          if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull then
            S := S + ' (C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' + 0) IS NULL '
          else
            S := S + ' (C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' + 0) = :' +
              InvPosition.ipInvDestCardFeatures[i].optFieldName
        else
          if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull then
            S := S + ' C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' IS NULL '
          else
            S := S + ' C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName +
              ' = :' + InvPosition.ipInvDestCardFeatures[i].optFieldName;
      end;

    if S <> '' then
      ibsqlCardMovement.SQL.Text := ibsqlCardMovement.SQL.Text + 'AND (' + S + ' )';

    ibsqlCardMovement.SQL.Text := ibsqlCardMovement.SQL.Text + ' AND m.documentkey <> c.firstdocumentkey ';

    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if   not CompareOptValue(FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName),
         InvPosition.ipInvDestCardFeatures[i]) and
         not FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull
      then
        SetFieldValue(ibsqlCardMovement.ParamByName(InvPosition.ipInvDestCardFeatures[i].optFieldName),
           InvPosition.ipInvDestCardFeatures[i],
           FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName));

    ibsqlGetCards.Transaction := Transaction;
    ibsqlGetCards.SQL.Text := 'SELECT ID FROM inv_p_GetCards( ' + IntToStr(aCardKey) + ') ';
    ibsqlGetCards.ExecQuery;

    isFirst := True;
    while isFirst and not ibsqlGetCards.EOF do
    begin
      ibsqlCardMovement.Close;

      if isFirst then
        SetTID(ibsqlCardMovement.ParamByName('id'), aCardKey)
      else
        SetTID(ibsqlCardMovement.ParamByName('id'), GetTID(ibsqlGetCards.FieldByName('ID')));
      ibsqlCardMovement.ExecQuery;

      if not ibsqlCardMovement.EOF then
      begin
        while not ibsqlCardMovement.EOF do
        begin
          InvDocument := TgdcInvDocumentLine.Create(Self);
          try
            InvDocument.SubType := ibsqlCardMovement.FieldByName('ruid').AsString;
            (*
            ���������� ����� ���������� ��� ���������� ��� �����.
            Stream := TStringStream.Create(ibsqlCardMovement.FieldByName('options').AsString);
            try
              InvDocument.ReadOptions(Stream);
            finally
              Stream.Free;
            end;
            *)

            isChange := False;
            for i:= Low((InvDocument as TgdcInvDocumentLine).SourceFeatures) to
              High((InvDocument as TgdcInvDocumentLine).SourceFeatures) do
            begin
              IndexField :=
                FieldList.IndexOf((InvDocument as TgdcInvDocumentLine).SourceFeatures[i]);
              if (IndexField >= 0) and (GetFieldAsVar(FibsqlCardInfo.FieldByName(FieldList[IndexField])) =
                GetFieldAsVar(ibsqlCardMovement.FieldByName(FieldList[IndexField])))
              then
              begin
                isChange := True;
                Break;
              end;
            end;

            if isChange then
            begin
              ibsqlCard := TIBSQL.Create(nil);
              try
                ibsqlCard.Transaction := Transaction;
                ibsqlCard.SQL.Text := 'SELECT id FROM inv_movement WHERE documentkey = :dk and ' +
                  ' credit > 0 and cardkey <> :ck';
                SetTID(ibsqlCard.ParamByName('dk'), GetTID(ibsqlCardMovement.FieldByName('dockey')));
                SetTID(ibsqlCard.ParamByName('ck'), GetTID(ibsqlCardMovement.FieldByName('id')));
                ibsqlCard.ExecQuery;
                Result := ibsqlCard.EOF;
              finally
                ibsqlCard.Free;
              end;
              if not Result then Break;
            end;
          finally
            InvDocument.Free;
          end;

          ibsqlCardMovement.Next;
        end;
      end;

      if not Result then
        break;

      if not isFirst then
        ibsqlGetCards.Next;
      isFirst := False;
    end;
  finally
    FieldList.Free;
    ibsqlCardMovement.Free;
    ibsqlGetCards.Free;
  end;
end;

function TgdcInvMovement.GetRefreshSQLText: String;
begin
  Result := '';
end;

procedure TgdcInvMovement._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('disabled').AsInteger := 0;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.SetSubSet(const Value: TgdcSubSet);
begin
  inherited;
  BufferChunks := 10;
end;

function TgdcInvMovement.GetIsGetRemains: Boolean;
begin
  Result := FIsGetRemains;
end;

procedure TgdcInvMovement.SetIsGetRemains(const Value: Boolean);
begin
  FIsGetRemains := Value;
end;

function TgdcInvMovement.GetCardDocumentKey(
  const CardKey: TID): TID;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT documentkey FROM inv_card WHERE id = :id';
    SetTID(ibsql.ParamByName('id'), cardkey);
    ibsql.ExecQuery;
    if not ibsql.EOF then
      Result := GetTID(ibsql.FieldByName('documentkey'))
    else
      Result := -1;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.IsReplaceDestFeature(ContactKey, CardKey,
  DocumentKey: TID; ChangedField: TStringList;
  var InvPosition: TgdcInvPosition): Boolean;
begin
  if FShowMovementDlg then
  begin
    with Tgdc_dlgShowMovement.Create(gdcDocumentLine.ParentForm) do
       try
         gdcDocumentLine := Self.gdcDocumentLine;
         Result := ShowModal = mrOk;
       finally
         Free;
       end;
  end
  else
    Result := True;
end;

procedure TgdcInvMovement.ClearCardQuery;
begin
  ibsqlCardList.Close;
  ibsqlCardList.SQL.Text := '';
end;

{ TgdcInvBaseRemains }

constructor TgdcInvBaseRemains.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  if not (csDesigning in ComponentState) then
    FIsNewDateRemains := GlobalStorage.ReadBoolean('Options\Invent', 'UseDelMovement', True);
  FViewFeatures := TStringList.Create;
  FSumFeatures := TStringList.Create;
  FGoodViewFeatures := TStringList.Create;
  FGoodSumFeatures := TStringList.Create;

  FCurrentRemains := False;
  FIsMinusRemains := False;
  FIsUseCompanyKey := True;

  FRemainsDate := 0;
  FEndMonthRemains := False;

  RemainsSQLType := irstSimpleSum;

  // �������������� ��� ������ ��������� � ���� �� ��
  FUseSelectFromSelect := True;
 {   (gdcBaseManager.Database.IsFirebirdConnect and (gdcBaseManager.Database.ServerMajorVersion >= 2));}
end;

procedure TgdcInvBaseRemains.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  for i:= 0 to FieldCount - 1 do
  begin
    if (UpperCase(Fields[i].FieldName) <> 'CHOOSEQUANTITY') and
      (UpperCase(Fields[i].FieldName) <> 'CHOOSEQUANTPACK')
    then
      Fields[i].ReadOnly := True
    else
      Fields[i].ReadOnly := False;

    Fields[i].Required := False;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcInvBaseRemains.Destroy;
begin

  inherited;
  if Assigned(FViewFeatures) then
    FreeAndNil(FViewFeatures);

  if Assigned(FSumFeatures) then
    FreeAndNil(FSumFeatures);

  if Assigned(FGoodViewFeatures) then
    FreeAndNil(FGoodViewFeatures);

  if Assigned(FGoodSumFeatures) then
    FreeAndNil(FGoodSumFeatures);

end;

function TgdcInvBaseRemains.GetFromClause(const ARefresh: Boolean = False): String;
var
  Ignore: TatIgnore;
begin
  if UseSelectFromSelect then
  begin
    Result := '';
    exit;
  end;

  Result := ' FROM INV_CARD C JOIN GD_GOOD G ON (G.ID = C.GOODKEY) ';

  if not IBLogin.IsUserAdmin then
    Result := Result + Format(' AND g_sec_test(g.aview, %d) <> 0 ', [IBLogin.InGroup]);

  if csDesigning in ComponentState then
    exit;

  if not CurrentRemains then
  begin
    if not FIsNewDateRemains then
      Result := Result + ' JOIN INV_MOVEMENT M ON C.ID = M.CARDKEY '
    else
      Result := Result + ' JOIN INV_BALANCE M ON C.ID = M.CARDKEY ';
  end
  else
    Result := Result + ' JOIN INV_BALANCE M ON C.ID = M.CARDKEY ';

  if HasSubSet(cst_ByGoodKey) then
  begin

    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
      (not CurrentRemains and (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil)) or
      (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
    then
      Result := Result + ' AND C.GOODKEY = :GOODKEY '
    else
      Result := Result + ' AND M.GOODKEY = :GOODKEY '

  end;

  FSQLSetup.Ignores.AddAliasName('C');

  if not HasSubSet(cst_ByGoodKey) then
  begin
    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'GG';

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'G';
  end;

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'CON';
end;

function TgdcInvBaseRemains.GetGroupClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if csDesigning in ComponentState then
    exit;

  Result := ' GROUP BY g.Name, g.ID, v.Name, g.Alias ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBaseRemains.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvBaseRemains.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvBaseRemains.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

function TgdcInvBaseRemains.GetRefreshSQLText: String;
begin
  Result := '';
end;

function TgdcInvBaseRemains.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' SELECT MIN(m.cardkey) as id, g.id as goodkey, ' +
    'g.name as namegood, g.alias as goodalias, v.name as valuename ';

  if csDesigning in ComponentState then
    exit;

  if not (CurrentRemains or UseSelectFromSelect) then
  begin
    if not FIsNewDateRemains then
    begin
      if FIsMinusRemains then
        Result := Result + ', SUM(M.CREDIT - M.DEBIT) as REMAINS '
      else
        Result := Result + ', SUM(M.DEBIT - M.CREDIT) as REMAINS '
    end
    else
    begin
      if FIsMinusRemains then
        Result := Result + ', SUM(REST.REMAINS - M.BALANCE) as REMAINS '
      else
        Result := Result + ', SUM(M.BALANCE - REST.REMAINS) as REMAINS '
    end;
  end
  else
  begin
    if FIsMinusRemains then
      Result := Result + ', SUM(0-M.BALANCE) AS REMAINS '
    else
      Result := Result + ', SUM(M.BALANCE) AS REMAINS ';
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.GetWhereClauseConditions(S: TStrings);
begin
  Assert(Assigned(IBLogin));

  if csDesigning in ComponentState then
    exit;

  inherited;

  if IsUseCompanyKey then
    S.Add('C.COMPANYKEY + 0 = :companykey');

  if not (CurrentRemains or UseSelectFromSelect) then
  begin
    if not FIsNewDateRemains then
      S.Add(' M.DISABLED = 0 ');
  end
  else
  begin
    if FisMinusRemains then
      S.Add(' M.BALANCE < 0 ')
    else
      if not HasSubSet(cst_AllRemains) then
        S.Add(' M.BALANCE <> 0 ');
  end;
end;

procedure TgdcInvBaseRemains.SetViewFeatures(const Value: TStringList);
begin
  if Assigned(FViewFeatures) then
    FViewFeatures.Assign(Value);
end;


class function TgdcInvBaseRemains.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + cst_ByGoodKey + ';' + cst_ByGroupKey + ';' + cst_AllRemains + ';' + cst_Holding + ';';
end;

class function TgdcInvBaseRemains.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvViewRemains';
end;

procedure TgdcInvBaseRemains.SetSubType(const Value: TgdcSubType);
var
  ibsql: TIBSQL;
  Stream: TStringStream;
begin
  if csDesigning in ComponentState then
    exit;

  if SubType <> Value then
  begin
    inherited;
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT * FROM inv_balanceoption WHERE ruid = :ruid';
      ibsql.ParamByName('ruid').AsString := Value;
      ibsql.ExecQuery;
      if not ibsql.EOF then
      begin
        Stream := TStringStream.Create(ibsql.FieldByName('viewfields').AsString);
        try
          ReadFeatures(FViewFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('sumfields').AsString);
        try
          ReadFeatures(FSumFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('goodviewfields').AsString);
        try
          ReadGoodFeatures(FGoodViewFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('goodsumfields').AsString);
        try
          ReadGoodFeatures(FGoodSumFeatures, Stream);
        finally
          Stream.Free;
        end;

        isUseCompanyKey := ibsql.FieldByName('usecompanykey').AsInteger = 1;

        RestrictRemainsBy := ibsql.FieldByName('restrictremainsby').AsString;

      end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure TgdcInvBaseRemains.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
   if (not CanCreate) and (not IBLogin.IsIBUserAdmin) then
     raise EgdcUserHaventRights.CreateFmt(strHaventRights,
       [strCreate, ClassName, SubType, GetDisplayName(SubType)]);

  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  abort;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;
end;

procedure TgdcInvBaseRemains.SetSumFeatures(const Value: TStringList);
begin
  if Assigned(FSumFeatures) then
    FSumFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.ReadFeatures(FFeatures: TStringList;
  Stream: TStream);
var
  F: TatRelationField;
begin
  with TReader.Create(Stream, 1024) do
  try
    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if not Assigned(F) then Continue;
      FFeatures.Add(F.FieldName);
    end;
    ReadListEnd;
  finally
    Free;
  end;

end;

function TgdcInvBaseRemains.GetRemainsName: String;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT name FROM inv_balanceoption WHERE ruid = :ruid';
    ibsql.ParamByName('ruid').AsString := SubType;
    ibsql.ExecQuery;
    if not ibsql.EOF then
      Result := ibsql.FieldByName('name').AsString
    else
      Result := '�c�����';
    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure TgdcInvBaseRemains.SetGoodSumFeatures(const Value: TStringList);
begin
  if Assigned(FGoodSumFeatures) then
    FGoodSumFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.SetGoodViewFeatures(const Value: TStringList);
begin
  if Assigned(FGoodViewFeatures) then
    FGoodViewFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.ReadGoodFeatures(FFeatures: TStringList;
  Stream: TStream);
var
  F: TatRelationField;
begin
  if Stream.Size > 0 then
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('GD_GOOD', ReadString);
        if not Assigned(F) then Continue;
        FFeatures.Add(F.FieldName);
      end;
      ReadListEnd;
    finally
      Free;
    end;
end;

class function TgdcInvBaseRemains.GetListTableAlias: String;
begin
  Result := 'c';
end;

procedure TgdcInvBaseRemains.SetCurrentRemains(const Value: Boolean);
begin
  if Value <> FCurrentRemains then
  begin
    FCurrentRemains := Value;
    FSQLInitialized := False;
  end;
end;

function TgdcInvBaseRemains.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TGDCINVBASEREMAINS(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBaseRemains.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcInvBaseRemains');
end;

class function TgdcInvBaseRemains.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := '������� ���';

  if ASubType > '' then
    Result := Result + ' ' + Inherited GetDisplayName(ASubType);
end;

{ TgdcInvRemains }

constructor TgdcInvRemains.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  FGoodKey := -1;
  FGroupKey := -1;
  SetLength(FChooseFeatures, 0);
  CachedUpdates := True;
  FCheckRemains := True;
  FgdcDocumentLine := nil;
  FIsDest := False;

  SetLength(FDepartmentKeys, 0);
  SetLength(FSubDepartmentKeys, 0);

end;

function TgdcInvRemains.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
  i: Integer;
  F: TatRelationField;
  St: String;

  function MakeInvBalancePart: String;
  var
    i : Integer;
  begin
    if ((FRestrictRemainsBy <> '') and (atDatabase.FindRelationField('INV_CARD', FRestrictRemainsBy) <> nil)) then
    begin
      Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
        '   M.BALANCE '#13#10 +
        ' FROM '#13#10 +
        '   INV_CARD C '#13#10 +
        ' LEFT JOIN INV_BALANCE M '#13#10 +
        '   ON C.ID = M.CARDKEY ';
    end
    else begin
      Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
        '   M.BALANCE '#13#10 +
        ' FROM '#13#10 +
        '   INV_BALANCE M ';
      if HasSubSet(cst_ByGoodKey) then
        if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
          (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
        then
          Result := Result + #13#10 +
            ' JOIN INV_CARD C ON C.ID = M.CARDKEY ';
    end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey)) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey)) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      Result := Result + ' JOIN GD_GOOD G ON ( G.ID  =  M.GOODKEY ) ';
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';
    end;

    Result := Result + #13#10 + ' WHERE ';
    if FIsMinusRemains then
      Result := Result +  ' M.BALANCE < 0 '
    else
      if not HasSubSet(cst_AllRemains) then
        Result := Result +  '  M.BALANCE <> 0 '
      else
        Result := Result +  '  (1 = 1) ';

    if ((FRestrictRemainsBy <> '') and (atDatabase.FindRelationField('INV_CARD', FRestrictRemainsBy) <> nil)) then
      Result := Result + #13#10 +
        ' and C.' + FRestrictRemainsBy + ' > 0 ';

    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + ' AND C.GOODKEY = :GOODKEY '
      else
        Result := Result + ' AND M.GOODKEY = :GOODKEY '
    end;

    if not HasSubSet(cst_ByGoodKey) then
      if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
        Result := Result +  ' AND ( GG.LB >= :LB AND GG.RB <= :RB )';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('���������� ������� ��c��, ������ ����c����c� ���')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;
  end;

  function MakeInvMovementPart: String;
  var
    i : Integer;
  begin
    if ((FRestrictRemainsBy <> '') and (atDatabase.FindRelationField('INV_CARD', FRestrictRemainsBy) <> nil)) then
    begin
      Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
      '   SUM(M.CREDIT - M.DEBIT) AS BALANCE '#13#10 +
      ' FROM '#13#10 +
        '   INV_CARD C '#13#10 +
        ' LEFT JOIN INV_MOVEMENT M '#13#10 +
        '   ON C.ID = M.CARDKEY ';
    end
    else begin
      Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
        '   SUM(M.CREDIT - M.DEBIT) AS BALANCE '#13#10 +
        ' FROM '#13#10 +
        '   INV_MOVEMENT M ';
      if HasSubSet(cst_ByGoodKey) then
        if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
          (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
        then
          Result := Result + #13#10 +
            ' JOIN INV_CARD C ON C.ID = M.CARDKEY ';
    end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey)) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey)) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      Result := Result + ' JOIN GD_GOOD G ON ( G.ID  =  M.GOODKEY ) ';
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';
    end;

    Result := Result + #13#10 + ' WHERE M.DISABLED = 0 '#13#10 +
      ' AND M.MOVEMENTDATE > :REMAINSDATE ';

    if ((FRestrictRemainsBy <> '') and (atDatabase.FindRelationField('INV_CARD', FRestrictRemainsBy) <> nil)) then
      Result := Result + #13#10 +
        ' and C.' + FRestrictRemainsBy + ' > 0 ';

    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + ' AND C.GOODKEY = :GOODKEY '
      else
        Result := Result + ' AND M.GOODKEY = :GOODKEY '
    end;

    if not HasSubSet(cst_ByGoodKey) then
      if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
        Result := Result +  ' AND ( GG.LB >= :LB AND GG.RB <= :RB )';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('���������� ������� ��c��, ������ ����c����c� ���')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;

    Result := Result + ' GROUP BY 1, 2 ';
  end;

begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if UseSelectFromSelect then
  begin
    Result := inherited GetFromClause(ARefresh);

    Result := ' FROM ('#13#10 +
      MakeInvBalancePart + #13#10;
    if not CurrentRemains then
      Result := Result + ' UNION ALL '#13#10 +
        MakeInvMovementPart + #13#10;

    Result := Result + ' ) M '#13#10 +
       ' LEFT JOIN INV_CARD C ON C.ID = M.CARDKEY '#13#10 +
       ' LEFT JOIN GD_GOOD G ON (G.ID = C.GOODKEY) ';
    if not IBLogin.IsUserAdmin then
      Result := Result + Format(' AND g_sec_test(g.aview, %d) <> 0 ', [IBLogin.InGroup]);

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';

    end;
    Result := Result  + ' LEFT JOIN gd_value v ON g.valuekey = v.id ';

    if csDesigning in ComponentState then
      exit;

    if Assigned(FViewFeatures) then
      for i:= 0 to FViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
            ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          FSQLSetup.Ignores.AddAliasName('C_' + FViewFeatures[i]);
        end;
      end;

    if Assigned(FGoodViewFeatures) then
      for i:= 0 to FGoodViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' G_' + FGoodViewFeatures[i] +
            ' ON G.' + FGoodViewFeatures[i] + ' = ' + ' G_' + FGoodViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          Ignore := FSQLSetup.Ignores.Add;
          Ignore.AliasName := 'G_' + FGoodViewFeatures[i];
        end;
      end;

    FSQLSetup.Ignores.AddAliasName('C');
    if not HasSubSet(cst_ByGoodKey) then
    begin
      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'GG';

      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'G';
    end;
    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'CON';

  end
  else
  begin
    Result := inherited GetFromClause(ARefresh);

    if not CurrentRemains then
    begin
      if not FIsNewDateRemains then
        Result := Result +  ' AND M.DISABLED = 0 ';
    end
    else
      if FIsMinusRemains then
        Result := Result +  ' AND M.BALANCE < 0 '
      else
        if not HasSubSet(cst_AllRemains) then
          Result := Result +  ' AND M.BALANCE > 0 ';

    if not CurrentRemains and not FIsNewDateRemains then
      Result := Result +  ' AND M.MOVEMENTDATE <= :REMAINSDATE ';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('���������� ������� ��c��, ������ ����c����c� ���')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey) ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON (CON1.id = h.companykey AND h.holdingkey = :holdingkey) OR (CON1.ID  = :holdingkey) ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';

    end;
    Result := Result  + ' LEFT JOIN gd_value v ON g.valuekey = v.id ';

    if not CurrentRemains and FIsNewDateRemains then
      Result := Result + ' LEFT JOIN INV_GETCARDMOVEMENT(M.CARDKEY, M.CONTACTKEY, :REMAINSDATE) REST ON 1= 1';

    if csDesigning in ComponentState then
      exit;

    if Assigned(FViewFeatures) then
      for i:= 0 to FViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
            ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          FSQLSetup.Ignores.AddAliasName('C_' + FViewFeatures[i]);
        end;
      end;

    if Assigned(FGoodViewFeatures) then
      for i:= 0 to FGoodViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' G_' + FGoodViewFeatures[i] +
            ' ON G.' + FGoodViewFeatures[i] + ' = ' + ' G_' + FGoodViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          Ignore := FSQLSetup.Ignores.Add;
          Ignore.AliasName := 'G_' + FGoodViewFeatures[i];
        end;
      end;

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'C';

    if not HasSubSet(cst_ByGoodKey) then
    begin
      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'GG';

      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'G';
    end;

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'CON';
  end;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetSelectClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(FgdcDocumentLine) then
    Result := inherited GetSelectClause + ', 0.0 as CHOOSEQUANTITY, 0.0 as CHOOSEQUANTPACK, GEN_ID(inv_g_balancenum, 1) as ChooseID '
  else
    Result := inherited GetSelectClause;

  if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
     (High(DepartmentKeys) >= Low(DepartmentKeys))
  then
  begin
    if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      Result := Result + ', CON.NAME, CON.ID as ContactKey '
    else
      Result := Result + ', CON.NAME, CON.ID as ContactKey ';
  end;

  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      Result := Result + ', C.' + FViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
      begin

        if Assigned(F.Field.RefListField) and Assigned(F.Field.RefListField.Field) and (F.Field.RefListField.Field.FieldType = ftMemo) then
 //         Result := Result + ', ' + Format(' SUBSTRING(%0:s FROM 1 FOR LENGTH(%0:s)) ', ['C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName]) + ' as c_' +
//            FViewFeatures[i] + '_' + F.Field.RefListFieldName
        else
          Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as c_' +
            FViewFeatures[i] + '_' + F.Field.RefListFieldName;
        end
    end;

  if Assigned(FGoodViewFeatures) then
    for i:= 0 to FGoodViewFeatures.Count - 1 do
    begin
      Result := Result + ', G.' + FGoodViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
        Result := Result + ', G_' + FGoodViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as g_' +
          FGoodViewFeatures[i] + '_' + F.Field.RefListFieldName;
    end;

  if Assigned(FSumFeatures) then
    for i := 0 to FSumFeatures.Count - 1 do
      if not (CurrentRemains or UseSelectFromSelect) then
      begin
        if not FIsNewDateRemains then
          Result := Result + ', SUM((m.debit - m.credit) * C.' + FSumFeatures[i] + ') as ' +
            'S_' + FSumFeatures[i]
        else
          Result := Result + ', SUM((m.balance - rest.remains) * C.' + FSumFeatures[i] + ') as ' +
            'S_' + FSumFeatures[i];
      end
      else
        Result := Result + ', SUM(m.balance * cast(C.' + FSumFeatures[i] + ' as double precision)) as ' +
          'S_' + FSumFeatures[i];

  if Assigned(FGoodSumFeatures) then
    for i:= 0 to FGoodSumFeatures.Count - 1 do
      if not (CurrentRemains or UseSelectFromSelect) then
      begin
        if not FIsNewDateRemains then
          Result := Result + ', SUM((m.debit - m.credit) * G.' + FGoodSumFeatures[i] + ') as ' +
            'SG_' + FGoodSumFeatures[i]
        else
          Result := Result + ', SUM((m.balance - rest.remains) * G.' + FGoodSumFeatures[i] + ') as ' +
            'SG_' + FGoodSumFeatures[i]
      end
      else
        Result := Result + ', SUM(m.balance * cast(G.' + FGoodSumFeatures[i] + ' as double precision)) as ' +
          'SG_' + FGoodSumFeatures[i];

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.GetWhereClauseConditions(S: TStrings);
var
  i: Integer;
begin
  if csDesigning in ComponentState then
    exit;

  if not HasSubSet(cst_ByGoodKey) then
  begin
    inherited;
    if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
      S.Add('( GG.LB >= :LB AND GG.RB <= :RB )');
  end
  else
  begin
    if isUseCompanyKey then
      S.Add('C.COMPANYKEY + 0 = :companykey');
  end;

  if High(FChooseFeatures) >= Low(FChooseFeatures) then
    for i:= Low(FChooseFeatures) to High(FChooseFeatures) do
      if not FChooseFeatures[i].IsNull then
        if FChooseFeatures[i].isID then
          S.Add('  (C.' + FChooseFeatures[i].optFieldName + ' + 0) = :' +
                    FChooseFeatures[i].optFieldName)
        else
          S.Add('  C.' + FChooseFeatures[i].optFieldName + ' = :' +
                    FChooseFeatures[i].optFieldName);
end;

procedure TgdcInvRemains.AddPosition;
var
  i, j: Integer;
  isError: Boolean;
  F: TField;
  {$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
  AllTime: LongWord;
  ChangeField: LongWord;
  TimePost: LongWord;
  {$ENDIF}
begin
{$IFDEF DEBUGMOVE}
  TimePost := 0;
  TimeCustomInsertUSR := 0;
  TimeGetRemains := 0;
  TimeMakeMovement := 0;
  TimeMakeInsert := 0;
  TimeQueryList := 0;
  TimeCustomInsertDoc := 0;
  TimeDoOnNewRecord := 0;
  TimeDoOnNewRecordClasses := 0;
  AllTime := GetTickCount;
  TimeFillPosition := 0;
{$ENDIF}
  if not Assigned(gdcDocumentLine) then exit;
  (gdcDocumentLine as TgdcInvDocumentLine).isSetFeaturesFromRemains := True;
  try
    SetLength(PositionList, High(PositionList) - Low(PositionList) + 2);
    with PositionList[High(PositionList) - Low(PositionList)] do
    begin
      cvalFirstDocumentKey := -1;
      cvalDocumentKey := -1;
      cvalFirstDate := -1;

      cvalGoodKey := GetTID(FieldByName('goodkey'));
      cvalCardKey := GetTID(FieldByName('id'));
      cvalQuantity := FieldByName('choosequantity').AsCurrency;
      cvalQuantPack := FieldByName('choosequantpack').AsCurrency;
      SetLength(cvalInvCardFeatures, ViewFeatures.Count);
      for i:= 0 to ViewFeatures.Count - 1 do
        SetOptValue(cvalInvCardFeatures[i], FieldByName(ViewFeatures[i]));
        
      if FindField('ContactKey') <> nil then
        cvalContactKey := GetTID(FieldByName('ContactKey'))
      else
        cvalContactKey := -1;

      if (cvalQuantity <> 0) or (1=1) then
      begin
        {$IFDEF DEBUGMOVE}
        TimeTmp := GetTickCount;
        {$ENDIF}
        if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
          gdcDocumentLine.Append;
        {$IFDEF DEBUGMOVE}
        TimeMakeInsert := GetTickCount - TimeTmp;
        ChangeField := GetTickCount;
        {$ENDIF}

        cvalDocumentKey := GetTID(gdcDocumentLine.FieldByName('documentkey'));

        SetTID(gdcDocumentLine.FieldByName('goodkey'), cvalGoodKey);
        if not FisDest then
          SetTID(gdcDocumentLine.FieldByName('fromcardkey'), cvalCardKey);

        if gdcDocumentLine.FindField('remains') <> nil then
        begin
          gdcDocumentLine.FieldByName('remains').ReadOnly := False;
          try
            gdcDocumentLine.FieldByName('remains').AsCurrency :=
              FieldByName('remains').AsCurrency;
          finally
            gdcDocumentLine.FieldByName('remains').ReadOnly := True;
          end;
        end
        else
          if gdcDocumentLine.FindField('fromquantity') <> nil then
          begin
            gdcDocumentLine.FieldByName('fromquantity').ReadOnly := False;
            try
              gdcDocumentLine.FieldByName('fromquantity').AsCurrency :=
                FieldByName('remains').AsCurrency;
            finally
              gdcDocumentLine.FieldByName('fromquantity').ReadOnly := True;
            end;
          end;

        for j:= Low(cvalInvCardFeatures) to High(cvalInvCardFeatures) do
        begin
          F := gdcDocumentLine.FindField(INV_SOURCEFEATURE_PREFIX +
               cvalInvCardFeatures[j].optFieldName);
          if (F <> nil) and not CompareOptValue(F, cvalInvCardFeatures[j])
          then
            SetFieldValue(F, cvalInvCardFeatures[j]);

          F := gdcDocumentLine.FindField(INV_DESTFEATURE_PREFIX +
               cvalInvCardFeatures[j].optFieldName);
          if (F <> nil) and (F.IsNull or (F.DefaultExpression > '')) and (not CompareOptValue(F, cvalInvCardFeatures[j]))
          then
            SetFieldValue(F, cvalInvCardFeatures[j]);

        end;

        gdcDocumentLine.FieldByName('quantity').AsCurrency := cvalQuantity;

        if (gdcDocumentLine.FindField('ToQuantity') <> nil)
        then
          gdcDocumentLine.FieldByName('ToQuantity').AsCurrency := cvalQuantity;

        if (gdcDocumentLine.FindField('OutQuantity') <> nil)
        then
        begin
          gdcDocumentLine.FieldByName('OutQuantity').AsCurrency := cvalQuantity;
          gdcDocumentLine.FieldByName('quantity').AsCurrency := -cvalQuantity;
        end;

        if (gdcDocumentLine.FindField('InQuantity') <> nil)
        then
          gdcDocumentLine.FieldByName('InQuantity').AsCurrency := cvalQuantity;

        if gdcDocumentLine.FindField('goodkey1') <> nil then
          SetTID(gdcDocumentLine.FieldByName('goodkey1'), cvalGoodKey);


        if (AnsiCompareText((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (gdcDocumentLine as TgdcInvDocumentLine).RelationName) <> 0) and
           ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.SourceFieldName > '') and
           (cvalContactKey > 0)
        then
          SetTID(gdcDocumentLine.FieldByName(
            (gdcDocumentLine as TgdcInvDocumentLine).MovementSource.SourceFieldName),
            cvalContactKey);
        {$IFDEF DEBUGMOVE}
        ChangeField := GetTickCount - ChangeField;
        {$ENDIF}

        isError := False;
        (gdcDocumentLine as TgdcInvDocumentLine).Movement.FIsGetRemains := False;
        try
        {$IFDEF DEBUGMOVE}
          TimePost := GetTickCount;
        {$ENDIF}
          gdcDocumentLine.Post;
        {$IFDEF DEBUGMOVE}
          TimePost := GetTickCount - TimePost;
        {$ENDIF}
        except
          on E: Exception do
          begin
            isError := True;
            MessageBox(ParentHandle, PChar(E.Message), PChar(sAttention), mb_OK);
            gdcDocumentLine.Cancel;
          end;
        end;
        (gdcDocumentLine as TgdcInvDocumentLine).Movement.FIsGetRemains := True;
        if not isError then
        begin
          Edit;
          FieldByName('remains').AsCurrency := FieldByName('remains').AsCurrency -
            FieldByName('choosequantity').AsCurrency;
          FieldByName('choosequantity').AsCurrency := 0;
          Post;
        end;
      end;
    end;
  finally
   (gdcDocumentLine as TgdcInvDocumentLine).isSetFeaturesFromRemains := False;  
  end;

  {$IFDEF DEBUGMOVE}
  AllTime := GetTickCount - AllTime;
  ShowMessage(Format('�c����� %d, GetRemains %d, MakeMovement %d, CustomInsertDoc %d, CustomInsertUSR %d, �c� %d, ���� %d, MakeQuery %d, _DoOnNewRecord %d, _DoOnNew_Classes %d, FillPos %d, AllPost %d',
    [TimeMakeInsert, TimeGetRemains, TimeMakeMovement, TimeCustomInsertDoc, TimeCustomInsertUSR, AllTime, ChangeField, TimeQueryList, TimeDoOnNewRecord, TimeDoOnNewRecordClasses, TimeFillPosition, TimePost]));
  {$ENDIF}
end;

procedure TgdcInvRemains.ClearPositionList;
begin
  SetLength(PositionList, 0)
end;

procedure TgdcInvRemains.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if FieldByName('ChooseQuantity').AsCurrency <> 0 then
    AddPosition;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not (sMultiple in BaseState) then
  begin
    if FCheckRemains and (FieldByName('CHOOSEQUANTITY').AsCurrency <> 0) and
       (FieldByName('CHOOSEQUANTITY').AsCurrency > FieldByName('REMAINS').AsCurrency) and
       ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtInventorization) and not FIsDest
    then
    begin
      MessageBox(ParentHandle, PChar(s_InvErrorChooseRemains), PChar(sAttention),
        mb_OK or mb_IconInformation);
      abort;
    end;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.DoBeforeOpen;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  ibsql: TIBSQL;
  Day, Month, Year: Word;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if GoodKey <> -1 then
    SetTID(ParamByName('goodkey'), GoodKey);

  if isUseCompanyKey then
  begin
    if Assigned(gdcDocumentLine) and Assigned(gdcDocumentLine.MasterSource) and Assigned(gdcDocumentLine.MasterSource.DataSet) then
    begin
      SetTID(ParamByName('companykey'), GetTID(gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey')))
    end
    else
      if GetTID(ParamByName('companykey')) = 0 then
        SetTID(ParamByName('companykey'), IBLogin.CompanyKey);
  end;
  
  if (Length(DepartmentKeys) = 1) then
    try
      SetTID(ParamByName('DepartmentKey'), DepartmentKeys[Low(DepartmentKeys)]);
    except
      // � ������� ����� �� ���� ��������� � ������ DepartmentKey
      on E: EIBClientError do ;
    end
  else
    if (Length(SubDepartmentKeys) = 1) then
    begin
      if not HasSubSet(cst_Holding) then
      begin
        ibsql := TIBSQL.Create(nil);
        try
          ibsql.Transaction := ReadTransaction;
          ibsql.SQL.Text := 'SELECT LB, RB, contacttype FROM gd_contact WHERE id = :ID';
          SetTID(ibsql.ParamByName('id'), SubDepartmentKeys[Low(SubDepartmentKeys)]);
          ibsql.ExecQuery;
          if not ibsql.EOF then
          begin
            try
              ParamByName('SubLB').AsInteger := ibsql.FieldByName('LB').AsInteger;
              ParamByName('SubRB').AsInteger := ibsql.FieldByName('RB').AsInteger;
            except
            end;
          end;
        finally
          ibsql.Free;
        end;
      end
      else
        SetTID(ParamByName('holdingkey'), SubDepartmentKeys[Low(SubDepartmentKeys)]);
    end;

  for i:= Low(FChooseFeatures) to High(FChooseFeatures) do
    if not FChooseFeatures[i].IsNull then
      try
        SetFieldValue(ParamByName(FChooseFeatures[i].optFieldName), FChooseFeatures[i]);
      except
        // TODO: ������ ����������
      end;

  if not CurrentRemains and (RemainsDate <> 0) then
    try
      if EndMonthRemains then
      begin
        DecodeDate(IncMonth(RemainsDate, 1), Year, Month, Day);
        ParamByName('remainsdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
      end  
      else
        ParamByName('remainsdate').AsDateTime := RemainsDate;
    except
      // TODO: ������ ����������
    end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetCountPosition: Integer;
begin
  if csDesigning in ComponentState then
    Result := 0
  else
    Result := High(PositionList) - Low(PositionList) + 1;
end;


procedure TgdcInvRemains.SetDepartmentKeys(const Value: array of TID);
var
  i: Integer;
begin
  SetLength(FDepartmentKeys, High(Value) - Low(Value) + 1);
  for i:= Low(Value) to High(Value) do
    FDepartmentKeys[i] := Value[i];
end;

procedure TgdcInvRemains.SetSubDepartmentKeys(const Value: array of TID);
var
  i: Integer;
begin
  SetLength(FSubDepartmentKeys, High(Value) - Low(Value) + 1);
  for i:= Low(Value) to High(Value) do
    FSubDepartmentKeys[i] := Value[i];
end;

procedure TgdcInvRemains.SetOptions_New;
var
  i: Integer;
  MovementContactType: TgdcInvMovementContactType;
  ipDestContactKey: TID;
  MasterDataSet: TDataSet;
begin
  Assert(Assigned(gdcDocumentLine), '�� ����� ������ ������� ���������');

  Close;

  if gdcDocumentLine.Transaction.InTransaction then
    ReadTransaction := gdcDocumentLine.Transaction;

  if Assigned(gdcDocumentLine.MasterSource) and
    Assigned(gdcDocumentLine.MasterSource.DataSet) then
    MasterDataSet := gdcDocumentLine.MasterSource.DataSet as TgdcInvDocument
  else
    raise Exception.Create('�� ����� ������ ���������');

  with (gdcDocumentLine as TgdcInvDocumentLine) do
  begin
    CurrentRemains := True;//LiveTimeRemains;
    FEndMonthRemains := EndMonthRemains;
    FIsMinusRemains := isMinusRemains;
    FIsUseCompanyKey := isUseCompanyKey;
    FRestrictRemainsBy := RestrictRemainsBy;

    if not FisMinusRemains then
    begin

      if
        (AnsiCompareText(MovementSource.RelationName, RelationName) = 0) and
        (MovementSource.SourceFieldName > '')
      then
      begin
        SetDepartmentKeys([GetTID(MasterDataSet.FieldByName(MovementSource.SourceFieldName))]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText(MovementSource.RelationName, RelationName) = 0
        then
          raise EgdcInvMovement.Create('���������� �������, ������ ���� ����� �c������');

        if
          (AnsiCompareText(MovementSource.SubRelationName, RelationName) = 0) and
          (MovementSource.SubSourceFieldName > '')
        then
        begin
          if GetTID(MasterDataSet.FieldByName(MovementSource.SubSourceFieldName)) > 0 then
            SetSubDepartmentKeys([GetTID(MasterDataSet.FieldByName(MovementSource.SubSourceFieldName))])
          else
            SetSubDepartmentKeys([GetTID(MasterDataSet.FieldByName('companykey'))]);
        end
        else

        if (MovementSource.SubSourceFieldName > '') then
          SetSubDepartmentKeys([GetTID(FieldByName(MovementSource.SubSourceFieldName))])
        else
          if High(MovementSource.Predefined) >= Low(MovementSource.Predefined) then
          begin
            SetDepartmentKeys(MovementSource.Predefined);
            IncludeSubDepartment := False;
          end
          else
            if High(MovementSource.SubPredefined) >= Low(MovementSource.SubPredefined) then
            begin
              SetSubDepartmentKeys(MovementSource.SubPredefined);
              IncludeSubDepartment := True;
            end;
      end;
    end
    else
    begin
      if (AnsiCompareText(MovementTarget.RelationName, RelationName) = 0) and
         (MovementTarget.SourceFieldName > '')
      then
        ipDestContactKey := GetTID(MasterDataSet.
          FieldByName(MovementTarget.SourceFieldName))
      else
        ipDestContactKey := -1;

      if (ipDestContactKey > 0) then
      begin
        SetDepartmentKeys([ipDestContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText(MovementTarget.RelationName, RelationName) = 0
        then
          raise EgdcInvMovement.Create('���������� �������, ������ ���� ����� �c������');

        if (AnsiCompareText(MovementTarget.SubRelationName, RelationName) = 0) and
           (MovementTarget.SubSourceFieldName > '')
        then
        begin
          SetSubDepartmentKeys([GetTID(MasterDataSet.
            FieldByName(MovementTarget.SubSourceFieldName))]);
          IncludeSubDepartment := True;
        end
        else

        if (MovementTarget.SubSourceFieldName > '') then
        begin
          SetSubDepartmentKeys([GetTID(FieldByName(MovementTarget.SubSourceFieldName))]);
          IncludeSubDepartment := True;
        end
        else
          if High(MovementTarget.Predefined) >= Low(MovementTarget.Predefined) then
          begin
            SetDepartmentKeys(MovementTarget.Predefined);
            IncludeSubDepartment := False;
          end
          else
            if High(MovementTarget.SubPredefined) >= Low(MovementTarget.SubPredefined) then
            begin
              SetSubDepartmentKeys(MovementTarget.SubPredefined);
              IncludeSubDepartment := True;
            end;
      end;

    end;

    ContactType := 0;

    if not FIsMinusRemains then
      MovementContactType := MovementSource.ContactType
    else
      MovementContactType := MovementTarget.ContactType;

    case MovementContactType of
    imctOurCompany:
      ContactType := 3;
    imctOurDepartment, imctOurPeople, imctOurDepartAndPeople:
      begin
        if (High(SubDepartmentKeys) < Low(SubDepartmentKeys)) and
           (High(DepartmentKeys) < Low(DepartmentKeys))
        then
        begin
          SetSubDepartmentKeys([GetTID(gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey'))]);
          IncludeSubDepartment := True;
        end;
        if MovementSource.ContactType = imctOurPeople
        then
          ContactType := 2
        else
          ContactType := 4;
      end;
    imctCompany:
      ContactType := 3;
    imctCompanyDepartment:
      ContactType := 4;
    imctCompanyPeople, imctPeople:
      ContactType := 2;
    end;

    RemainsDate := MasterDataSet.FieldByName('documentdate').AsDateTime;

    if not FIsMinusRemains then
    begin
      if (RelationType <> irtTransformation) or (ViewMovementPart = impExpense) or
         ((FindField('OUTQUANTITY') <> nil) and (FieldByName('OUTQUANTITY').AsCurrency > 0))
      then
        ViewFeatures.Clear;
        for i:= Low(SourceFeatures) to High(SourceFeatures) do
          ViewFeatures.Add(SourceFeatures[i]);
    end
    else
    begin
      ViewFeatures.Clear;
      for i:= Low(MinusFeatures) to High(MinusFeatures) do
        ViewFeatures.Add(MinusFeatures[i]);
    end;

  end;
  SubType := gdcDocumentLine.SubType;
  SubSet := cst_ByGroupKey;

end;

procedure TgdcInvRemains.SetOptions(var InvPosition: TgdcInvPosition;
  InvMovement: TgdcInvMovement; const isPosition: Boolean; const isDest: Boolean = False);
var
  i: Integer;
  MovementContactType: TgdcInvMovementContactType;
begin
  Assert(Assigned(InvMovement) and Assigned(InvMovement.gdcDocumentLine),
    '�� ����� ������ �������� ��� ������� ���������');

  FisDest := IsDest;

  Close;

  if InvMovement.Transaction.InTransaction then
    ReadTransaction := InvMovement.Transaction;

  FgdcDocumentLine := InvMovement.gdcDocumentLine;

  FEndMonthRemains := InvMovement.EndMonthRemains;

  FRestrictRemainsBy := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RestrictRemainsBy;

  with InvPosition do
  begin
    CurrentRemains := True;//InvMovement.CurrentRemains;

    CheckRemains := (tcrSource in ipCheckRemains);

    FIsMinusRemains := ipMinusRemains;

    FIsUseCompanyKey := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey;

    if not FisMinusRemains then
    begin
      if (ipSourceContactKey > 0) and
         (AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0)
      then
      begin
        SetDepartmentKeys([ipSourceContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0
        then
          raise EgdcInvMovement.Create('���������� �������, ������ ���� ����� �c������');

        if ipSubSourceContactKey > 0 then
        begin
          SetSubDepartmentKeys([ipSubSourceContactKey]);
          IncludeSubDepartment := True;
        end
        else
          if High(ipPredefinedSourceContact) >= Low(ipPredefinedSourceContact) then
          begin
            SetDepartmentKeys(ipPredefinedSourceContact);
            IncludeSubDepartment := False;
          end
          else
            if High(ipSubPredefinedSourceContact) >= Low(ipSubPredefinedSourceContact) then
            begin
              SetSubDepartmentKeys(ipSubPredefinedSourceContact);
              IncludeSubDepartment := True;
            end;
      end;
    end
    else
    begin
      if (ipDestContactKey > 0) and
         (AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0)
      then
      begin
        SetDepartmentKeys([ipDestContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0
        then
          raise EgdcInvMovement.Create('���������� �������, ������ ���� ����� �c������');

        if ipSubDestContactKey > 0 then
        begin
          SetSubDepartmentKeys([ipSubDestContactKey]);
          IncludeSubDepartment := True;
        end
        else
          if High(ipPredefinedDestContact) >= Low(ipPredefinedDestContact) then
          begin
            SetDepartmentKeys(ipPredefinedDestContact);
            IncludeSubDepartment := False;
          end
          else
            if High(ipSubPredefinedDestContact) >= Low(ipSubPredefinedDestContact) then
            begin
              SetSubDepartmentKeys(ipSubPredefinedDestContact);
              IncludeSubDepartment := True;
            end;
      end;

    end;

    ContactType := 0;

    if not FIsMinusRemains then
      MovementContactType := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType
    else
      MovementContactType := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.ContactType;

    case MovementContactType of
    imctOurCompany:
      ContactType := 3;
    imctOurDepartment, imctOurPeople, imctOurDepartAndPeople:
      begin
        if (High(SubDepartmentKeys) < Low(SubDepartmentKeys)) and
           (High(DepartmentKeys) < Low(DepartmentKeys))
        then
        begin
          SetSubDepartmentKeys([GetTID(gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey'))]);
          IncludeSubDepartment := True;
        end;
        if (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople
        then
          ContactType := 2
        else
          ContactType := 4;
      end;
    imctCompany:
      ContactType := 3;
    imctCompanyDepartment:
      ContactType := 4;
    imctCompanyPeople, imctPeople:
      ContactType := 2;
    end;

    RemainsDate := ipDocumentDate;
    if not FIsMinusRemains and not isDest then
      for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
        ViewFeatures.Add(ipInvSourceCardFeatures[i].optFieldName)
    else
      if FIsMinusRemains then
      begin
        for i:= Low(ipInvMinusCardFeatures) to High(ipInvMinusCardFeatures) do
          ViewFeatures.Add(ipInvMinusCardFeatures[i].optFieldName);
      end
      else
        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
          ViewFeatures.Add(ipInvDestCardFeatures[i].optFieldName);

    if isPosition then
    begin
      GoodKey := ipGoodKey;

      SetLength(FChooseFeatures, Length(ipInvSourceCardFeatures));
      for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
      begin
        FChooseFeatures[i].optFieldName := ipInvSourceCardFeatures[i].optFieldName;
        FChooseFeatures[i].IsNull := ipInvSourceCardFeatures[i].IsNull;
        FChooseFeatures[i].optValue := ipInvSourceCardFeatures[i].optValue;
        FChooseFeatures[i].optID := ipInvSourceCardFeatures[i].optID;
        FChooseFeatures[i].isID := ipInvSourceCardFeatures[i].isID;
      end;

      SubSet := cst_ByGoodKey;
    end
    else
      SubSet := cst_ByGroupKey;

    if (gdcDocumentLine as TgdcInvDocumentLine).SaveRestWindowOption then
    begin
      if UserStorage.ReadBoolean('Options\Invent', 'AllRemains', False) then
        AddSubSet('AllRemains');
      CurrentRemains := UserStorage.ReadBoolean('Options\Invent', 'CurrentRemains', True);
    end;

    SubType := FgdcDocumentLine.SubType;  
  end;
end;


function TgdcInvRemains.GetGroupClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetGroupClause;
  if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
     (High(DepartmentKeys) >= Low(DepartmentKeys))
  then
  begin
    if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      Result := Result + ', CON.NAME, CON.ID '
    else
      Result := Result + ', CON.name, CON.id ';
  end;

  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      Result := Result + ', C.' + FViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
      begin
        if Assigned(F.Field.RefListField) and Assigned(F.Field.RefListField.Field) and (F.Field.RefListField.Field.FieldType = ftMemo) then
//          Result := Result + ', ' +  Format(' SUBSTRING(%0:s FROM 1 FOR LENGTH(%0:s)) ', [ 'C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName])
        else
          Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName;
      end
    end;

  if Assigned(FGoodViewFeatures) then
    for i:= 0 to FGoodViewFeatures.Count - 1 do
    begin
      Result := Result + ', G.' + FGoodViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
        Result := Result + ', G_' + FGoodViewFeatures[i] + '.' + F.Field.RefListFieldName;
    end;

  if not CurrentRemains then
  begin
    if UseSelectFromSelect then
    begin
      if not FisMinusRemains then
      begin
        if not HasSubSet(cst_AllRemains) then
          Result := Result + ' HAVING SUM(M.BALANCE) > 0 ';
      end
      else
        Result := Result + ' HAVING SUM(M.BALANCE) < 0 ';
    end
    else
    begin
      if not FIsMinusRemains then
      begin
        if not HasSubSet(cst_AllRemains) then
        begin
          if not FIsNewDateRemains then
            Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) > 0 '
          else
            Result := Result + ' HAVING SUM ( M.BALANCE - REST.REMAINS )  >  0 '
        end
      end
      else
        if not FIsNewDateRemains then
          Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) < 0 '
        else
          Result := Result + ' HAVING SUM ( M.BALANCE - REST.REMAINS )  <  0 '
    end;
  end
  else
    if not FisMinusRemains then
    begin
      if not HasSubSet(cst_AllRemains) then
        Result := Result + ' HAVING SUM(M.BALANCE) > 0 ';
    end
    else
      Result := Result + ' HAVING SUM(M.BALANCE) < 0 ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetRefreshSQLText: String;
begin
  Result := '';
end;

procedure TgdcInvRemains.RemovePosition;
var
  i: Integer;
begin
  if gdcDocumentLine.State in [dsEdit, dsInsert] then
    gdcDocumentLine.Cancel;

  if (gdcDocumentLine as TgdcInvDocumentLine).SavePoint = '' then
  begin
    for i:= 0 to CountPosition - 1 do
    begin
      if (PositionList[i].cvalDocumentKey > 0) and (PositionList[i].cvalCardKey > 0) then
        if gdcDocumentLine.Locate('documentkey', TID2V(PositionList[i].cvalDocumentKey), []) and
           (GetTID(gdcDocumentLine.FieldByName('documentkey')) = PositionList[i].cvalDocumentKey)
        then
          gdcDocumentLine.Delete;
    end;
    gdcDocumentLine.First;
  end;

end;

procedure TgdcInvRemains.SetgdcDocumentLine(const Value: TgdcDocument);
begin
  if Value <> FgdcDocumentLine then
  begin
    FgdcDocumentLine := Value;
    if Assigned(FgdcDocumentLine) then
      SetOptions_New;
  end;  
end;


{ TgdcInvGoodRemains }

procedure TgdcInvGoodRemains.SetOptions_New;
begin
  inherited;
  SubSet := cst_ByGoodKey;
end;

{ TgdcInvCard }

constructor TgdcInvCard.Create(AnOwner: TComponent);
begin
  inherited;
  FContactKey := -1;
  FViewFeatures := TStringList.Create;
  FieldPrefix := '';
  FRemainsFeatures := TStringList.Create;
  FIgnoryFeatures := TStringList.Create;
  FgdcInvRemains := nil;
  FgdcInvDocumentLine := nil;
end;

destructor TgdcInvCard.Destroy;
begin
  inherited;
  if Assigned(FViewFeatures) then
    FreeAndNil(FViewFeatures);
  if Assigned(FRemainsFeatures) then
    FreeAndNil(FRemainsFeatures);
  if Assigned(FIgnoryFeatures) then
    FreeAndNil(FIgnoryFeatures);
end;

function TgdcInvCard.GetFromClause(const ARefresh: Boolean = False): String;
var
  i: Integer;
  F: TatRelationField;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' FROM inv_card z JOIN inv_movement m ON z.id = m.cardkey ';
  F := atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY');

  if not GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) and Assigned(F)
     and (not HasSubSet('ByGoodDetail'))
  then
    Result := Result + ' AND m.goodkey  = :goodkey ';

  if HasSubSet('ByHolding') then
  begin
    Result := Result + ' LEFT JOIN gd_contact con_m ON m.contactkey = con_m.id ' +
      ' LEFT JOIN gd_contact hold ON con_m.LB >= hold.LB and con_m.RB <= hold.RB ';
    if IsHolding then
      Result := Result + ' LEFT JOIN gd_holding H ON hold.id = h.companykey ';
  end;

  Result := Result +
  ' LEFT JOIN inv_movement m1 ON m.movementkey = m1.movementkey AND m.id <> m1.id ' +
  ' LEFT JOIN gd_contact con ON  con.id = (case when M1.CONTACTKEY is not null then M1.CONTACTKEY else M.CONTACTKEY end) ' +
  ' LEFT JOIN gd_contact main_con ON main_con.id = m.contactkey ';

  Result := Result +
  ' LEFT JOIN inv_card c ON c.id = (case when M1.DEBIT > 0 then M1.cardkey else M.cardkey end) ' +
  ' LEFT JOIN gd_document doc ON m.documentkey = doc.id ' +
  ' LEFT JOIN gd_documenttype doct ON doc.documenttypekey = doct.id ' +
  ' LEFT JOIN gd_good g ON z.goodkey = g.id ' +
  ' LEFT JOIN gd_value v ON g.valuekey = v.id ';

  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      begin
        Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
          ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
      end;
    end;

  if Assigned(FRemainsFeatures) then
    for i:= 0 to FRemainsFeatures.Count - 1 do
    begin
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      begin
        Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' ZR_' + FRemainsFeatures[i] +
          ' ON C.' + FRemainsFeatures[i] + ' = ' + ' ZR_' + FRemainsFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;

        FSQLSetup.Ignores.AddAliasName('ZR_' +
          FRemainsFeatures[i]);
      end;
    end;

  FSQLSetup.Ignores.AddAliasName('Z');
  FSQLSetup.Ignores.AddAliasName('C');
  if HasSubSet('ByGoodDetail') then
    FSQLSetup.Ignores.AddAliasName('G');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvCard.GetGroupClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'GROUP BY con.Name, doc.number, doc.documentdate, doc.creationdate, doc.editiondate, ' +
   ' doct.name, doct.ruid, doc.id, doc.parent, g.Name, v.Name, m.contactkey, z.goodkey, main_con.name, main_con.id ';
  if HasSubSet('ByHolding') then
    Result := Result + ', con_m.name ';

  for i:= 0 to FViewFeatures.Count - 1 do
  begin
    Result := Result + ', C.' + FViewFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if F.Field.FieldType <> ftMemo then
        Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName;
  end;

  for i:= 0 to FRemainsFeatures.Count - 1 do
  begin
    Result := Result + ', C.' + FRemainsFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if Assigned(F.Field.RefListField) and (F.Field.RefListField.Field.FieldType <> ftMemo) then
        Result := Result + ', zr_' + FRemainsFeatures[i] + '.' + F.Field.RefListFieldName;
  end;
  
  if not HasSubSet('ByAllMovement') then
    Result := Result + ' HAVING SUM(m.Debit) <> SUM(m.Credit) ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvCard.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCard.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCard.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

function TgdcInvCard.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet('ByHolding') then
    Result := 'ORDER BY doc.documentdate, doc.editiondate, 16 DESC '
  else
    Result := 'ORDER BY doc.documentdate, doc.editiondate, 15 DESC ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvCard.GetRefreshSQLText: String;
begin
  Result := '';
end;

function TgdcInvCard.GetRemainsOnDate(DateEnd: TDateTime;
  IsCurrent: Boolean; const AContactKeys: string): Currency;
var
  ibsql: TIBSQL;
  FromContactStatement, WhereStatement: String;
  i: Integer;
  DataSet: TDataSet;
  Prefix, SQLText: String;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ReadTransaction;

    Prefix := '';
    if Assigned(gdcInvRemains) then
      DataSet := gdcInvRemains
    else
      if Assigned(gdcInvDocumentLine) then
      begin
        DataSet := gdcInvDocumentLine;
        Prefix := FieldPrefix;
      end
      else
        DataSet := Self;

    // ����������� �� �������� ��������
    WhereStatement := '';
    if not HasSubSet('ByGoodOnly') then
      for i:= 0 to RemainsFeatures.Count - 1 do
      begin
        // ���� ���� INTEGER
        if DataSet.FieldByName(Prefix + RemainsFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt] then
          if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
            WhereStatement := WhereStatement + ' AND (c.' + RemainsFeatures[i]  + ' + 0) = :' + RemainsFeatures[i]
          else
            WhereStatement := WhereStatement + ' AND (c.' + RemainsFeatures[i]  + ' + 0) IS NULL '
        else
          if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
            WhereStatement := WhereStatement + ' AND c.' + RemainsFeatures[i]  + ' = :' + RemainsFeatures[i]
          else
            WhereStatement := WhereStatement + ' AND c.' + RemainsFeatures[i]  + ' IS NULL ';
      end;
    // �������������� ������� ��� ����������� �� ���������
    FromContactStatement := '';
    if HasSubSet('ByLBRBDepot') then
      FromContactStatement :=
        '  LEFT JOIN gd_contact con ON m.contactkey = con.id '
    else
      if HasSubSet('ByHolding') then
        FromContactStatement :=
          '  LEFT JOIN gd_contact con ON m.contactkey = con.id ' +
          '  LEFT JOIN gd_contact hold ON con.LB >= hold.LB and con.RB <= hold.RB ';
    // ����������� �� ��������
    if HasSubSet('ByHolding') then
      WhereStatement := WhereStatement + ' AND hold.id IN (SELECT companykey FROM gd_holding) '
    else
    begin
      if HasSubSet('ByLBRBDepot') then
        WhereStatement := WhereStatement + ' AND con.LB >= :LB AND con.RB <= :RB '
      else if HasSubSet('ByGoodDetail') then
      begin
        if AContactKeys <> '' then
          WhereStatement := WhereStatement + ' AND m.contactkey ' + AContactKeys + ' ';
      end
      else
        WhereStatement := WhereStatement + ' AND m.contactkey = :contactkey ';
    end;
    // ���� ������ Firebird 2.0+, � ���� ���� GOODKEY � INV_MOVEMENT � INV_BALANCE,
    //   �� ����� ����� ������� ������ ���������
    if Database.IsFirebirdConnect and (Database.ServerMajorVersion >= 2)
       and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY')) and (not isCurrent) then
    begin
      SQLText :=
          'SELECT' + #13#10 +
          '  SUM(M.BALANCE) AS remains ' + #13#10 +
          'FROM (' + #13#10 +
          '  SELECT SUM(M.BALANCE) AS BALANCE ' + #13#10 +
          '  FROM INV_BALANCE m' + #13#10 +
          '  LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
          FromContactStatement + #13#10 +
          '  WHERE' + #13#10 +
          '    m.goodkey = :goodkey ' + #13#10 +
          WhereStatement + #13#10;
      if not isCurrent then
        SQLText := SQLText + ' UNION ALL '#13#10 +
          ' SELECT' + #13#10 +
          ' SUM(M.CREDIT - M.DEBIT) AS BALANCE ' + #13#10 +
          ' FROM INV_MOVEMENT m' + #13#10 +
          ' LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
          FromContactStatement + #13#10 +
          ' WHERE' + #13#10 +
          '   m.movementdate > :dateend' + #13#10 +
          '   AND m.goodkey = :goodkey' + #13#10 +
          '   AND m.disabled = 0' + #13#10 +
          WhereStatement + #13#10;
      SQLText := SQLText + ' ) M ';
      
      ibsql.SQL.Text := SQLText;
    end
    else
    begin
      if isCurrent then
        SQLText :=
          'SELECT ' +
          '  SUM(m.balance) as Remains ' +
          'FROM ' +
          '  inv_card c ' +
          '  LEFT JOIN inv_balance m ON c.id = m.cardkey '
      else
        SQLText :=
          'SELECT ' +
          '  SUM(m.debit - m.credit) as Remains ' +
          'FROM ' +
          '  inv_card c ' +
          '  LEFT JOIN inv_movement m ON c.id = m.cardkey ';
      if HasSubSet('ByLBRBDepot') then
        SQLText := SQLText +
          '  LEFT JOIN gd_contact con ON m.contactkey = con.id '
      else
        if HasSubSet('ByHolding') then
          SQLText := SQLText +
            '  LEFT JOIN gd_contact con ON m.contactkey = con.id ' +
            '  LEFT JOIN gd_contact hold ON con.LB >= hold.LB and con.RB <= hold.RB ';

      SQLText := SQLText +
        'WHERE ' +
        '  c.goodkey = :goodkey ' + WhereStatement;

      if not isCurrent then
        SQLText := SQLText + ' AND m.movementdate <= :dateend AND m.disabled = 0 ';

      ibsql.SQL.Text := SQLText;
    end;

    // ��������� ��������� ����� � ��������
    SetTID(ibsql.ParamByName('goodkey'), GetTID(DataSet.FieldByName('goodkey')));
    if HasSubSet('ByLBRBDepot') then
    begin
      ibsql.ParamByName('LB').AsInteger := ParamByName('LB').AsInteger;
      ibsql.ParamByName('RB').AsInteger := ParamByName('RB').AsInteger;
    end
    else
    begin
      if not HasSubSet('ByGoodDetail') and not HasSubSet('ByHolding') then
      begin
        if ContactKey > 0 then
          SetTID(ibsql.ParamByName('contactkey'), ContactKey)
        else
          SetTID(ibsql.ParamByName('contactkey'), GetTID(ParamByName('contactkey')));
      end;
    end;
    // ��������� �������� ����
    if not isCurrent then
      ibsql.ParamByName('dateend').AsDateTime := DateEnd;
    // ��������� ��������� �������� ��������
    if not HasSubSet('ByGoodOnly') then
      for i:= 0 to RemainsFeatures.Count - 1 do
      begin
        if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
          SetVar2Param(ibsql.ParamByName(RemainsFeatures[i]),
            GetFieldAsVar(DataSet.FieldByName(Prefix + RemainsFeatures[i])));
      end;

    ibsql.ExecQuery;

    if not ibsql.EOF then
      Result := ibsql.FieldByName('remains').AsCurrency
    else
      Result := 0;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvCard.GetSelectClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT con.Name, doc.number, doc.documentdate, doc.creationdate, doc.editiondate, g.Name as GoodName, v.Name as ValueName, ' +
   ' doct.name as DocName, doct.ruid, doc.id, doc.parent, m.contactkey, z.goodkey, main_con.name as DEPOTNAME, main_con.id as DEPOTKEY ';
  if HasSubSet('ByHolding') then
    Result := Result + ', con_m.Name as NameMove, SUM(m.Debit) as Debit, SUM(m.Credit) as Credit '
  else
    Result := Result + ', SUM(m.Debit) as Debit, SUM(m.Credit) as Credit ';

  for i:= 0 to FViewFeatures.Count - 1 do
  begin
    Result := Result + ', c.' + FViewFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
    begin
      if F.Field.FieldType <> ftMemo then
        Result := Result + ', c_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as c_' +
          FViewFeatures[i] + '_' + F.Field.RefListFieldName;
     end;
  end;

  for i:= 0 to FRemainsFeatures.Count - 1 do
  begin
    Result := Result + ', c.' + FRemainsFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if Assigned(F.Field.RefListField) and (F.Field.RefListField.Field.FieldType <> ftMemo) then
        Result := Result + ', zr_' + FRemainsFeatures[i] + '.' + F.Field.RefListFieldName + ' as zr_' +
          FRemainsFeatures[i] + '_' + F.Field.RefListFieldName;
  end;

  Result := Result + ', CAST(0 as NUMERIC(15, 4)) as Remains';


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvCard.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByInterval;ByContact;ByLBRBDepot;ByGoodDetail;ByHolding;ByGoodOnly;ByAllMovement;';
end;

procedure TgdcInvCard.GetWhereClauseConditions(S: TStrings);
var
  F: TatRelationField;
begin
  inherited;

  if not HasSubSet('ByID') and not HasSubSet('ByGoodDetail') then
  begin
    F := atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY');
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or not Assigned(F) then
      S.Add('z.goodkey = :goodkey');
  end;

  if HasSubSet('ByGoodDetail') then
    S.Add(' z.companykey in (' + IBLogin.HoldingList + ')');

  if HasSubSet('ByInterval') then
    S.Add(' m.movementdate >= :datebegin AND m.movementdate <= :dateend');

  if HasSubSet('ByHolding') then
  begin
    if isHolding then
      S.Add(' h.holdingkey > 0 ')
    else
      S.Add(' hold.id in (' + IBLogin.HoldingList + ')');  
  end
  else
    if HasSubSet('ByContact') then
      S.Add(' m.contactkey = :contactkey')
    else
      if HasSubSet('ByLBRBDepot') then
        S.Add(' con.LB >= :LB AND con.RB <= :RB ');


end;

procedure TgdcInvCard.SetFeatures(DataSet: TDataSet; Prefix: String; Features: TgdcInvFeatures);
var
  i: Integer;
begin
  if not HasSubSet('ByGoodOnly') then
  begin
    for i:= Low(Features) to High(Features) do
    begin
      if IgnoryFeatures.IndexOf(Features[i]) < 0 then
      begin
        if not DataSet.FieldByName(Prefix + Features[i]).IsNull then
          ExtraConditions.Add('z.' + Features[i] + ' = :' + Features[i])
        else
          ExtraConditions.Add('z.' + Features[i] + ' IS NULL ');
      end;
      RemainsFeatures.Add(Features[i]);
    end;

    for i:= Low(Features) to High(Features) do
    begin
      if IgnoryFeatures.IndexOf(Features[i]) < 0 then
      begin
        if not DataSet.FieldByName(Prefix + Features[i]).IsNull then
        begin
          SetVar2Param(ParamByName(Features[i]),
            GetFieldAsVar(DataSet.FieldByName(Prefix + Features[i])));
        end;
      end;
    end;
  end;
end;

procedure TgdcInvCard.SetDocumentLineConditions;
var
  ibsql: TIBSQL;
begin
  if Assigned(gdcInvDocumentLine) then
  begin

    SetTID(ParamByName('goodkey'), GetTID(gdcInvDocumentLine.FieldByName('goodkey')));

    RemainsFeatures.Clear;

    if (gdcInvDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation then
    begin
      if (gdcInvDocumentLine as TgdcInvDocumentLine).ViewMovementPart in [impIncome, impAll] then
        FieldPrefix := INV_DESTFEATURE_PREFIX
      else
        FieldPrefix := INV_SOURCEFEATURE_PREFIX;
    end else

    if (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.ContactType in [imctOurCompany, imctOurDepartment, imctOurPeople, imctOurDepartAndPeople] then
      FieldPrefix := INV_SOURCEFEATURE_PREFIX
    else
      FieldPrefix := INV_DESTFEATURE_PREFIX;

    if FieldPrefix = INV_SOURCEFEATURE_PREFIX then
    begin
      if not HasSubSet('ByGoodOnly') then
        SetFeatures(gdcInvDocumentLine, FieldPrefix, (gdcInvDocumentLine as TgdcInvDocumentLine).SourceFeatures);

      if not HasSubSet('ByHolding') then
      begin
        if FContactKey > 0 then
          SetTID(ParamByName('contactkey'), FContactKey)
        else
        begin
          if
            (AnsiCompareText((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName, (gdcInvDocumentLine as TgdcInvBaseDocument).RelationName) = 0) and
            ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '')
          then
          begin
            if (gdcInvDocumentLine.MasterSource <> nil) and (gdcInvDocumentLine.MasterSource.DataSet <> nil)
            then
              SetTID(ParamByName('contactkey'), GetTID(gdcInvDocumentLine.MasterSource.DataSet.
                FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName)))
            else
            begin
              ibsql := TIBSQL.Create(nil);
              try
                ibsql.SQL.Text := 'SELECT ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName +
                  ' FROM ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName +
                  ' WHERE documentkey = ' + gdcInvDocumentLine.FieldByName('parent').AsString;
                ibsql.Transaction := gdcInvDocumentLine.ReadTransaction;
                ibsql.ExecQuery;
                SetTID(ParamByName('contactkey'), GetTID(ibsql.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName)));
              finally
                ibsql.Free;
              end;
            end;
          end
          else
            if ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '') then
              SetTID(ParamByName('contactkey'), GetTID(gdcInvDocumentLine.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName)));
        end;
      end;
    end
    else
    begin 
      if not HasSubSet('ByGoodOnly') then
        SetFeatures(gdcInvDocumentLine, FieldPrefix, (gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures);

      if not HasSubSet('ByHolding') then
      begin
        if FContactKey > 0 then
          SetTID(ParamByName('contactkey'), FContactKey)
        else
        begin
          if
            (AnsiCompareText((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.RelationName, (gdcInvDocumentLine as TgdcInvBaseDocument).RelationName) = 0) and
            ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName > '')
          then
          begin
            if (gdcInvDocumentLine.MasterSource <> nil) and (gdcInvDocumentLine.MasterSource.DataSet <> nil)
            then
              SetTID(ParamByName('contactkey'), GetTID(gdcInvDocumentLine.MasterSource.DataSet.
                FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName)))
            else
            begin
              ibsql := TIBSQL.Create(nil);
              try
                ibsql.SQL.Text := 'SELECT ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName +
                  ' FROM ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName +
                  ' WHERE documentkey = ' + gdcInvDocumentLine.FieldByName('parent').AsString;
                ibsql.Transaction := gdcInvDocumentLine.ReadTransaction;
                ibsql.ExecQuery;
                SetTID(ParamByName('contactkey'), GetTID(ibsql.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName)));
              finally
                ibsql.Free;
              end;
            end
          end
          else
            if ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '') then
              SetTID(ParamByName('contactkey'), GetTID(gdcInvDocumentLine.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName)));
        end;
      end;
    end;
  end;
end;

procedure TgdcInvCard.SetIgnoryFeatures(const Value: TStringList);
begin
  if Assigned(FIgnoryFeatures) then
    FIgnoryFeatures.Assign(Value);
end;

procedure TgdcInvCard.SetRemainsConditions;
var
  i: Integer;
begin
  if Assigned(gdcInvRemains) then
  begin
    if not HasSubSet('ByGoodOnly') then
    begin

      RemainsFeatures := gdcInvRemains.ViewFeatures;
      for i:= 0 to gdcInvRemains.ViewFeatures.Count - 1 do
      begin
        if IgnoryFeatures.IndexOf(gdcInvRemains.ViewFeatures[i]) < 0 then
        begin
          if not gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).IsNull then
            ExtraConditions.Add('z.' + gdcInvRemains.ViewFeatures[i] + ' = :' +
            gdcInvRemains.ViewFeatures[i])
          else
            ExtraConditions.Add('z.' + gdcInvRemains.ViewFeatures[i] + ' IS NULL ');
        end;
      end;
    end;

    SetTID(ParamByName('goodkey'),
      GetTID(gdcInvRemains.FieldByName('goodkey')));
    if not HasSubSet('ByHolding') then
    begin
      if FContactKey <= 0 then
      begin
        if gdcInvRemains.FindField('contactkey') <> nil then
          SetTID(ParamByName('contactkey'),
            GetTID(gdcInvRemains.FieldByName('contactkey')))
        else
          SetTID(ParamByName('contactkey'),
            GetTID(gdcInvRemains.ParamByName('departmentkey')));
      end
      else
        SetTID(ParamByName('contactkey'), FContactKey);
    end;

    if not HasSubSet('ByGoodOnly') then
    begin
      for i:= 0 to gdcInvRemains.ViewFeatures.Count - 1 do
      begin
        if IgnoryFeatures.IndexOf(gdcInvRemains.ViewFeatures[i]) < 0 then
        begin
          if not gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).IsNull then
            SetVar2Param(ParamByName(gdcInvRemains.ViewFeatures[i]), GetFieldAsVar(gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i])));
{          if not gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).IsNull then
            if gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).DataType = ftLargeint then
              SetTID(ParamByName(gdcInvRemains.ViewFeatures[i]), gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]))
            else
              ParamByName(gdcInvRemains.ViewFeatures[i]).AsVariant :=
                gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).AsVariant}

        end;
      end;
    end;  
  end;
end;

procedure TgdcInvCard.SetRemainsFeatures(const Value: TStringList);
begin
  if Assigned(FRemainsFeatures) then
    FRemainsFeatures.Assign(Value);

end;

procedure TgdcInvCard.SetViewFeatures(const Value: TStringList);
begin
  if Assigned(FViewFeatures) then
    FViewFeatures.Assign(Value);
end;

procedure TgdcInvCard.ReInitialized;
begin
  FSQLInitialized := False;
end;

function TgdcInvCard.IsHolding: Boolean;
var
  ibsql: TIBSQL;
begin
  if FIsHolding = -1 then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT * FROM gd_holding WHERE companykey = <companykey/>';
      ibsql.ExecQuery;
      if ibsql.EOF then
        FIsHolding := 0
      else
        FIsHolding := 1;
    finally
      ibsql.Free;
    end;
  end;
  Result := FIsHolding = 1;

end;

procedure TgdcInvCard.DoOnNewRecord;
begin

  Abort;

end;

{ TgdcInvRemainsOption }

procedure TgdcInvRemainsOption.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  //
  // ������� ������ �� ������� ������

  ExecSingleQuery(Format(
    'DELETE FROM gd_command WHERE classname = ''TgdcInvRemains'' AND ' +
    '  subtype = ''%s''',
    [FieldByName('ruid').AsString]));

  gdClassList.RemoveSubType(FieldByName('ruid').AsString);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemainsOption.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UpdateExplorerCommandData(
    'c����c��� ����', 'inventory'
    FieldByName('NAME').AsString, FieldByName('ruid').AsString,
    TgdcInvRemains.ClassName, False, GetTID(FieldByName('branchkey'))
  );

  gdClassList.Add(TgdcInvRemains, FieldByName('RUID').AsString, '',
    TgdBaseEntry, FieldByName('name').AsString);
  gdClassList.Add(TgdcInvGoodRemains, FieldByName('RUID').AsString, '',
    TgdBaseEntry, FieldByName('name').AsString);

  gdClassList.Add('Tgdc_frmInvSelectGoodRemains', FieldByName('RUID').AsString, '',
    TgdFormEntry, FieldByName('name').AsString);
  gdClassList.Add('Tgdc_frmInvSelectRemains', FieldByName('RUID').AsString, '',
    TgdFormEntry, FieldByName('name').AsString);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemainsOption.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  CE: TgdClassEntry;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UpdateExplorerCommandData(
    'c����c��� ����', 'inventory',
    FieldByName('NAME').AsString, FieldByName('ruid').AsString,
    TgdcInvRemains.ClassName,
    True, GetTID(FieldByName('branchkey'))
  );

  if FieldChanged('name') then
  begin
    CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvRemains', FieldByName('RUID').AsString);
    CE.Caption := FieldByName('name').AsString;

    CE := gdClassList.Get(TgdBaseEntry, 'TgdcInvGoodRemains', FieldByName('RUID').AsString);
    CE.Caption := FieldByName('name').AsString;

    CE := gdClassList.Get(TgdFormEntry, 'Tgdc_frmInvSelectGoodRemains', FieldByName('RUID').AsString);
    CE.Caption := FieldByName('name').AsString;

    CE := gdClassList.Get(TgdFormEntry, 'Tgdc_frmInvSelectRemains', FieldByName('RUID').AsString);
    CE.Caption := FieldByName('name').AsString;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemainsOption.DoBeforePost;
var
  ibsql: TIBSQL;
  S: String;
  L: Integer;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
{  ���� �� � ��������� �������� �� ������, �������� �������� �� ������������ ������������ ���������
  ��� ������������ ������������, ��������������� ���
  �������� ���� ����� ������ � ����, ������� �����!!!}

  if (sLoadFromStream in BaseState) then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      if Transaction.InTransaction then
        ibsql.Transaction := Transaction
      else
        ibsql.Transaction := ReadTransaction;

      ibsql.SQL.Text := 'SELECT id FROM INV_BALANCEOPTION WHERE UPPER(name) = :name and id <> :id';
      ibsql.ParamByName('name').AsString := AnsiUpperCase(FieldByName('name').AsString);
      SetTID(ibsql.ParamByName('id'), ID);
      ibsql.ExecQuery;

      if not ibsql.EOF then
      begin
        S := FieldByName('name').AsString + FieldByName(GetKeyField(SubType)).AsString;
        L := Length(S);
        if L > 60 then
        begin
          S := System.Copy(FieldByName('name').AsString, 1,
            L - Length(FieldByName(GetKeyField(SubType)).AsString)) +
            FieldByName(GetKeyField(SubType)).AsString;
        end;
        FieldByName('name').AsString := S;
      end;
    finally
      ibsql.Free;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvRemainsOption.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgInvRemainsOption';
end;

class function TgdcInvRemainsOption.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvRemainsOption.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcInvRemainsOption.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_BALANCEOPTION';
end;

function TgdcInvRemainsOption.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TGDCINVREMAINSOPTION(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField;

  if Result > '' then
    Result := Result + ',RUID'
  else
    Result := 'RUID';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvRemainsOption.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvRemainsOption';
end;

procedure TgdcInvRemainsOption.ReadOptions;
var
  Stream: TStream;
begin
  FRestrictRemainsBy := FieldByName('restrictremainsby').AsString;
  Stream := TStringStream.Create(FieldByName('viewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FViewFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FViewFeatures, Length(FViewFeatures) + 1);
        FViewFeatures[Length(FViewFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('sumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FSumFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FSumFeatures, Length(FSumFeatures) + 1);
        FSumFeatures[Length(FSumFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('goodviewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FGoodViewFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FGoodViewFeatures, Length(FGoodViewFeatures) + 1);
        FGoodViewFeatures[Length(FGoodViewFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('goodsumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FGoodSumFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FGoodSumFeatures, Length(FGoodSumFeatures) + 1);
        FGoodSumFeatures[Length(FGoodSumFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TgdcInvRemainsOption.UpdateExplorerCommandData(MainBranchName,
  CMD, CommandName, DocumentID, ClassName: String;
  const ShouldUpdateData: Boolean; const MainBranchKey: TID);
var
  ibsql: TIBSQL;
  BranchID: TID;
  DidActivate: Boolean;
begin
  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    //
    // �c���c������ ���c� ����c�

    ibsql.Transaction := Transaction;

    DidActivate := ActivateTransaction;

    ibsql.SQL.Text := Format(
      'SELECT CLASSNAME, SUBTYPE FROM ' +
      '  GD_COMMAND WHERE CLASSNAME = ''%s'' AND SUBTYPE = ''%s''',
      [ClassName, DocumentID]
    );

    ibsql.ExecQuery;

    //�c�� �� ������� �����, �� ������ ����c� �� �cc���������� �� �� ���cc� � c�������
    if (MainBranchKey <= 0) then
    begin
      ibsql.Close;
      ibsql.SQl.Text := 'DELETE FROM gd_command WHERE UPPER(classname) = :classname ' +
        ' AND UPPER(subtype) = :subtype ';
      ibsql.ParamByName('classname').AsString := AnsiUpperCase(ClassName);
      ibsql.ParamByName('subtype').AsString := AnsiUpperCase(DocumentID);
      ibsql.ExecQuery;
    end else

    //
    // �c�� ����c� ��� �� ��������� �c���c������ �� ����������
    if ibsql.EOF then
    begin
      //
      // �c���c������ �������� �� ������� ����� �����

      ibsql.Close;
      ibsql.SQL.Text :=
        'SELECT ID, NAME FROM GD_COMMAND WHERE ID = :ID';
      SetTID(ibsql.ParamByName('ID'), MainBranchKey);
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        //
        // �c�� ����� ��� - ��������� ��

        { TODO 1 -o����c -cc������ : 710000 c������ �������� �� ���c����� }

        ibsql.Close;
        ibsql.SQL.Text :=
          'INSERT INTO GD_COMMAND (ID, PARENT, NAME, CMD, CMDTYPE, IMGINDEX) ' +
          'VALUES ' +
          '  (:ID, :Parent, :NAME, :CMD, 0, 0) ';

        SetTID(ibsql.ParamByName('ID'), GetNextID(True));
        SetTID(ibsql.ParamByName('PARENT'), 710000);
        ibsql.ParamByName('NAME').AsString := MainBranchName;
        ibsql.ParamByName('CMD').AsString := CMD;

        ibsql.ExecQuery;

        BranchID := GetTID(ibsql.ParamByName('ID'));
      end else
        BranchID := GetTID(ibsql.FieldByName('ID'));

      //
      // �c���c������ ���������� �������

      ibsql.Close;
      ibsql.SQL.Text :=
        'INSERT INTO GD_COMMAND (ID, PARENT, NAME, CMD, CMDTYPE, CLASSNAME, SUBTYPE, ' +
        '  IMGINDEX) ' +
        'VALUES ' +
        '  (:ID, :PARENT, :NAME, :CMD, 0, :CLASSNAME, :SUBTYPE, 17) ';

      SetTID(ibsql.ParamByName('ID'), GetNextID(True));
      SetTID(ibsql.ParamByName('PARENT'), BranchID);
      ibsql.ParamByName('NAME').AsString := CommandName;
      ibsql.ParamByName('CMD').AsString := DocumentID;
      ibsql.ParamByName('CLASSNAME').AsString := ClassName;
      ibsql.ParamByName('SUBTYPE').AsString := DocumentID;

      ibsql.ExecQuery;
    end else

    if ShouldUpdateData then
    begin
      ibsql.Close;
      if MainBranchKey > 0 then
        ibsql.SQL.Text :=
          'UPDATE GD_COMMAND SET NAME = :NAME, PARENT = :PARENT ' +
          '  WHERE CLASSNAME = :CLASSNAME AND SUBTYPE = :SUBTYPE '
      else
        ibsql.SQL.Text :=
          'UPDATE GD_COMMAND SET NAME = :NAME ' +
          '  WHERE CLASSNAME = :CLASSNAME AND SUBTYPE = :SUBTYPE ';

      ibsql.ParamByName('NAME').AsString := CommandName;
      if MainBranchKey > 0 then
        SetTID(ibsql.ParamByName('PARENT'), MainBranchKey);
      ibsql.ParamByName('CLASSNAME').AsString := ClassName;
      ibsql.ParamByName('SUBTYPE').AsString := DocumentID;
      ibsql.ExecQuery;
    end;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
    ibsql.Free;
  end;
end;

procedure TgdcInvRemainsOption.WriteOptions;
var
  Stream: TStringStream;
  i: Integer;
begin
  FieldByName('restrictremainsby').AsString := FRestrictRemainsBy;
  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FViewFeatures) - 1 do
        WriteString(FViewFeatures[I]);
      WriteListEnd;
      FieldByName('viewfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FSumFeatures) - 1 do
        WriteString(FSumFeatures[I]);
      WriteListEnd;
      FieldByName('sumfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FGoodViewFeatures) - 1 do
        WriteString(FGoodViewFeatures[I]);
      WriteListEnd;
      FieldByName('goodviewfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FGoodSumFeatures) - 1 do
        WriteString(FGoodSumFeatures[I]);
      WriteListEnd;
      FieldByName('goodsumfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TgdcInvRemainsOption._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('ruid').AsString := RUIDToStr(GetRUID);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TgdcInvCardConfig }

constructor TgdcInvCardConfig.Create(AnOwner: TComponent);
begin
  inherited Create(anOwner);
  FConfig:= TInvCardConfig.Create;
end;

destructor TgdcInvCardConfig.Destroy;
begin
  FConfig.Free;
  inherited;
end;

function TgdcInvCardConfig.GetConfig: TInvCardConfig;
begin
  Result:= FConfig;
end;

class function TgdcInvCardConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgInvCardConfig'
end;

class function TgdcInvCardConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvCardConfig'
end;

procedure TgdcInvCardConfig.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TInvCardConfig''')
end;

procedure TgdcInvCardConfig.LoadConfig;
var
  Str: TStream;
begin
  if (not ID > 0) or FieldByName('config').IsNull then Exit;
  Str := CreateBlobStream(FieldByName('config'), bmRead);
  try
    Config.LoadFromStream(Str);
  finally
    Str.Free
  end;
end;

procedure TgdcInvCardConfig.SaveConfig;
var
  Str: TStream;
begin
  if not (State in dsEditModes) then
    Edit;
  if not ID > 0 then Exit;
  Str := TMemoryStream.Create;
  try
    Config.SaveToStream(Str);
    (FieldByName('config') as TBlobField).LoadFromStream(Str);
  finally
    Str.Free
  end;
  Post;
end;

procedure TgdcInvCardConfig.ClearGrid;
begin
  Config.GridSettings.Clear;
  SaveConfig;
end;

procedure TgdcInvCardConfig.SaveGrid(Grid: TgsIBGrid);
begin
  Grid.SaveToStream(Config.GridSettings);
  SaveConfig;
end;

procedure TgdcInvCardConfig._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARDCONFIG', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARDCONFIG',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('classname').AsString := 'TInvCardConfig';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvCardConfig.DoAfterScroll;
begin
  LoadConfig;
  inherited;
end;

procedure TgdcInvCardConfig.CreateCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = :CMD';
    SQL.ParamByName('cmd').AsString := RUIDToStr(SFRUID);
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := GetTID(SQL.FieldByName('id'));
      gdcExplorer.Open;
      gdcExplorer.Edit;
      try
        if FieldByName('folder').IsNull then
          gdcExplorer.FieldByName('parent').Clear
        else
          SetTID(gdcExplorer.FieldByName('parent'), GetTID(FieldByName('folder')));
        gdcExplorer.FieldByName('name').AsString := FieldByName('name').AsString;
        gdcExplorer.FieldByName('cmd').AsString := RUIDToStr(SFRUID);
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
        gdcExplorer.FieldByName('imgindex').AsInteger := FieldByName('imageindex').AsInteger;
        gdcExplorer.Post;
      except
        gdcExplorer.Cancel;
        raise;
      end;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcInvCardConfig.DeleteCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = :CMD ';
    SQL.ParamByName('cmd').AsString := RUIDToStr(SFRUID);
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := GetTID(SQL.FieldByName('id'));
      gdcExplorer.Open;
      if not gdcExplorer.Eof then
        gdcExplorer.Delete;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcInvCardConfig.CreateSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
const
  cFunctionBody =
    'Sub %s '#13 +
    '  Dim ConfigKey '#13 +
    '  Set Creator = New TCreator '#13 +
    '  Set F = Designer.CreateObject(Application, "%s", "") '#13 +
    '  ConfigKey = gdcBaseManager.GetIdByRuidString("%s") '#13 +
    '  F.FindComponent("cmbConfig").CurrentKeyInt = ConfigKey '#13 +
    '  F.FindComponent("actShowCard").Execute '#13 +
    'End Sub';
begin
  if FieldByName('showinexplorer').AsInteger <> 1 then
    DeleteSF
  else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReadTransaction;
      SQL.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
        Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
      SQL.ExecQuery;
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := GetTID(SQL.FieldByName('Id'));
        gdcFunction.Open;
        gdcFunction.Edit;
        try
          gdcFunction.FieldByName(fnName).AsString := Format(cFunctionName, [RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnModule).AsString := scrUnkonownModule;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnScript).AsString := Format(cFunctionBody,
            [gdcFunction.FieldByName(fnName).AsString,
            GetGDVViewForm,
            RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnLanguage).AsString := DefaultLanguage;
          gdcFunction.Post;

          if ScriptFactory <> nil then
            ScriptFactory.ReloadFunction(GetTID(gdcFunction.FieldByName(fnID)));
        except
          gdcFunction.Cancel;
          raise;
        end;
        CreateCommand(gdcFunction.GetRUID);
      finally
        gdcFunction.Free;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TgdcInvCardConfig.DeleteSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQl.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
      Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
    SQL.ExecQuery;
    if GetTID(SQL.FieldByName('id')) > 0 then begin
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := GetTID(SQL.FieldByName('Id'));
        gdcFunction.Open;
        DeleteCommand(gdcFunction.GetRUID);
        gdcFunction.Delete;
      finally
        gdcFunction.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TgdcInvCardConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmInvCard'
end;

procedure TgdcInvCardConfig.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARDCONFIG', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARDCONFIG',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
                                        
  if Process = cpDelete then
    DeleteSF
  else
    CreateSF;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcInvCardConfig.GetIPCount: integer;
var
  S: TStrings;
  I: Integer;
begin
  Result:= 0;
  S := TStringList.Create;
  try
    if Config.GoodValue = cInputParam then
      Result:= 1;
    if Config.DeptValue = cInputParam then
      Inc(Result);

    S.Text := Config.CardValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
      Inc(Result);
    end;

    S.Text := Config.GoodValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
      Inc(Result);
    end;
  finally
    S.Free;
  end;
end;

initialization
  RegisterGdcClass(TgdcInvBaseRemains);
  RegisterGdcClass(TgdcInvRemains);
  RegisterGdcClass(TgdcInvGoodRemains);
  RegisterGdcClass(TgdcInvMovement);
  RegisterGdcClass(TgdcInvCard);
  RegisterGdcClass(TgdcInvRemainsOption);
  RegisterGdcClass(TgdcInvCardConfig);

finalization
  UnregisterGdcClass(TgdcInvGoodRemains);
  UnregisterGdcClass(TgdcInvRemains);
  UnregisterGdcClass(TgdcInvBaseRemains);
  UnregisterGdcClass(TgdcInvMovement);
  UnregisterGdcClass(TgdcInvCard);
  UnregisterGdcClass(TgdcInvRemainsOption);
  UnregisterGdcClass(TgdcInvCardConfig);
end.


