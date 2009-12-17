{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

{$R-}

unit IBCustomDataSet;

interface

// определите этот символ, чтобы большие строки размещались
// в памяти динамически, а не в буфере записи
{_$_DEFINE HEAP_STRING_FIELD}

uses
  Windows, SysUtils, Classes, Controls, IBExternals, IB, IBHeader, StdVcl,
  IBDatabase, IBSQL, Db, IBUtils, IBBlob, GraphicSupport, ContNrs
  //!!!b
  , DBGrids
  //!!!e
//-//  , Dialogs{_dbg!!!}
  ;

const
  //!!!b
  //BufferCacheSize    =  1000;  { Allocate cache in this many record chunks}
  BufferCacheSize    =  16;  { Allocate cache in this many record chunks}
  //!!!e
  UniCache           =  2;     { Uni-directional cache is 2 records big }

type
  TIBCustomDataSet = class;
  TIBDataSet = class;

  //!!!b
  //////////////////////////////////////////////////////////
  // аггрегаты -- значения, вычисляемые по группе записей
  //
  TgdcAggregate = class;
  TgdcAggregates = class;
  TgdcAggUpdateEvent = procedure(Agg: TgdcAggregate) of object;

  TgdcAggregate = class(TCollectionItem)
  private
    FVisible: Boolean;
    FActive: Boolean;
    FInUse: Boolean;
    FDataSize: Integer;
    FIndexName: String;
    FAggregateName: String;
    FExpression: String;
    FDataType: TFieldType;
    FOnUpdate: TgdcAggUpdateEvent;
    FDataSet: TIBCustomDataSet;
    FValue: Variant;

    procedure SetActive(const Value: Boolean);
    procedure SetExpression(const Value: String);
    procedure SetIndexName(const Value: String);
    procedure SetVisible(const Value: Boolean);

  public
    constructor Create(AnAggregates: TgdcAggregates; ADataSet: TIBCustomDataSet); reintroduce;

    function Value: Variant;
    function GetDisplayName: String; override;
    procedure SetValue(AValue: Variant);

    property Active: Boolean read FActive write SetActive;
    property AggregateName: String read FAggregateName write FAggregateName;
    property DataSet: TIBCustomDataSet read FDataSet;
    property DataSize: Integer read FDataSize;
    property DataType: TFieldType read FDataType write FDataType;
    property Expression: String read FExpression write SetExpression;
    property IndexName: String read FIndexName write SetIndexName;
    property InUse: Boolean read FInUse;
    property OnUpdate: TgdcAggUpdateEvent read FOnUpdate write FOnUpdate;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TgdcAggregates = class(TCollection)
  private
    FOwner: TPersistent;

    function GetItem(Index: Integer): TgdcAggregate;
    procedure SetItem(Index: Integer; const Value: TgdcAggregate);

  protected
    function GetOwner: TPersistent; override;

  public
    constructor Create(Owner: TPersistent);

    function Add: TgdcAggregate;
    procedure Clear;
    function Find(const DisplayName: string): TgdcAggregate;
    function IndexOf(const DisplayName: string): Integer;
    property Items[Index: Integer]: TgdcAggregate read GetItem write SetItem; default;
  end;


  //!!!e

  TIBDataSetUpdateObject = class(TComponent)
  private
    FRefreshSQL: TStrings;
    procedure SetRefreshSQL(value: TStrings);
  protected
    function GetDataSet: TIBCustomDataSet; virtual; abstract;
    procedure SetDataSet(ADataSet: TIBCustomDataSet); virtual; abstract;
    {
    procedure Apply(UpdateKind: TUpdateKind); virtual; abstract;
    function GetSQL(UpdateKind: TUpdateKind): TStrings; virtual; abstract;
    }
    property DataSet: TIBCustomDataSet read GetDataSet write SetDataSet;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //!!!!
    //перанесена Andreik
    procedure Apply(UpdateKind: TUpdateKind); virtual; abstract;
    function GetSQL(UpdateKind: TUpdateKind): TStrings; virtual; abstract;
    //!!!!
  published
    property RefreshSQL: TStrings read FRefreshSQL write SetRefreshSQL;
  end;

  PDateTime = ^TDateTime;
  TBlobDataArray = array[0..0] of TIBBlobStream;
  PBlobDataArray = ^TBlobDataArray;

  { TIBCustomDataSet }
  TFieldData = record
    fdDataType: Short;
    fdDataScale: Short;
    fdNullable: Boolean;
    fdIsNull: Boolean;
    fdDataSize: Short;
    fdDataLength: Short;
    fdDataOfs: Integer;
  end;
  PFieldData = ^TFieldData;

  TCachedUpdateStatus = (
                         cusUnmodified, cusModified, cusInserted,
                         cusDeleted, cusUninserted
                        );
  TIBDBKey = record
    DBKey: array[0..7] of Byte;
  end;
  PIBDBKey = ^TIBDBKey;

  {$IFDEF NEW_GRID}
  TRecordKind = (rkRecord,
                 rkHeaderRecord,{ rkGhost,}
                 rkGroup, rkHeader,
                 rkFooter,
                 rkHiddenRecord, rkHiddenFooter);
  TRecordKindOptions = set of TRecordKind;
  {$ENDIF}

  TRecordData = record
    rdBookmarkFlag: TBookmarkFlag;
    rdFieldCount: Short;
    rdRecordNumber: Long;
    rdCachedUpdateStatus: TCachedUpdateStatus;
    rdUpdateStatus: TUpdateStatus;
    rdSavedOffset: DWORD;
    rdDBKey: TIBDBKey;
    {$IFDEF NEW_GRID}
    rdRecordKind: TRecordKind;
    rdRecordGroupFiltered: Boolean;
    {$ENDIF}
    rdFields: array[1..1] of TFieldData;
  end;
  PRecordData = ^TRecordData;

  { TIBStringField allows us to have strings longer than 8196 }

  TIBStringField = class(TStringField)
  public
    constructor Create(AOwner: TComponent); override;
    class procedure CheckTypeSize(Value: Integer); override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetValue(var Value: string): Boolean;
    procedure SetAsString(const Value: string); override;
  end;

  { TIBBCDField }
  {  Actually, there is no BCD involved in this type,
     instead it deals with currency types.
     In IB, this is an encapsulation of Numeric (x, y)
     where x < 18 and y <= 4.
     Note: y > 4 will default to Floats
  }
  TIBBCDField = class(TBCDField)
  protected
    class procedure CheckTypeSize(Value: Integer); override;
    function GetAsCurrency: Currency; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetDataSize: Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Size default 8;
  end;

  TIBDataLink = class(TDetailDataLink)
  private
    FDataSet: TIBCustomDataSet;
  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(Field: TField); override;
    function GetDetailDataSet: TDataSet; override;
    procedure CheckBrowseMode; override;
  public
    constructor Create(ADataSet: TIBCustomDataSet);
    destructor Destroy; override;
  end;

  TIBGeneratorApplyEvent = (gamOnNewRecord, gamOnPost, gamOnServer);

  TIBGeneratorField = class(TPersistent)
  private
    FField: string;
    FGenerator: string;
    FIncrementBy: Integer;
    DataSet: TIBCustomDataSet;
    
    FApplyEvent: TIBGeneratorApplyEvent;
    function  IsComplete: Boolean;
  public
    constructor Create(ADataSet: TIBCustomDataSet);
    function  ValueName: string;
    procedure Apply;
    procedure Assign(Source: TPersistent); override;
  published
    property Field : string read FField write FField;
    property Generator : string read FGenerator write FGenerator;
    property IncrementBy : Integer read FIncrementBy write FIncrementBy default 1;
    property ApplyEvent : TIBGeneratorApplyEvent read FApplyEvent write FApplyEvent default  gamOnNewRecord;
  end;

  { TIBCustomDataSet }
  TIBUpdateAction = (uaFail, uaAbort, uaSkip, uaRetry, uaApply, uaApplied);

  TIBUpdateErrorEvent = procedure(DataSet: TDataSet; E: EDatabaseError;
                                 UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction)
                                 of object;
  TIBUpdateRecordEvent = procedure(DataSet: TDataSet; UpdateKind: TUpdateKind;
                                   var UpdateAction: TIBUpdateAction) of object;

  TIBUpdateRecordTypes = set of TCachedUpdateStatus;

  TLiveMode = (lmInsert, lmModify, lmDelete, lmRefresh);
  TLiveModes = Set of TLiveMode;

  TLastQuery = (lqNone, lqSelect, lqRefresh, lqInsert, lqUpdate, lqDelete);

  {$IFDEF NEW_GRID}
  TFindRecordEvent = procedure(DataSet: TDataSet; var Found: Boolean) of object;

  TAggFunction = (afSum, afCount, afCountNotNull, afMin, afMax, afAvg);
  TGroupAgg = class(TObject)
  private
    FField: TField;
    FValue: Double;
    FCount: Integer;
    FFunction: TAggFunction;
  public
    constructor Create(F: TField; const AFunction: String);

    procedure Calc;
    procedure Clear;
    function GetResult: Double;
    function GetFuncAsStr: string;
    procedure Assign;

    property Field: TField read FField;
    property FunctionA: TAggFunction read FFunction;
  end;

  TGroupSortOrder = (gsoGroupAsc, gsoGroupDesc, gsoSortAsc, gsoSortDesc);
  TDateScale = (dsType, dsDay, dsWeek, dsMonth, dsQuartal, dsYear);
  //значения строковых констант см. в ArDateScale

  TGroupSortField = class(TObject)
  private
    FField: TField;
    FGroupSortOrder: TGroupSortOrder;
    FIntScale: Integer;
    FDateScale: TDateScale;
    FStrScale: String;
  protected
  public
    constructor Create(F: TField; const AGroupSortOrder: TGroupSortOrder;
      AIntScale: Integer = 1; ADateScale: TDateScale = dsType; AStrScale: string = '');
    function GetScaleAsStr: string;

    property Field: TField read FField;
    property GroupSortOrder: TGroupSortOrder read FGroupSortOrder;
    property IntScale: Integer read FIntScale default 1;
    property DateScale: TDateScale read FDateScale default dsType;
    property StrScale: String read FStrScale;
  end;

  TGroupSortFields = class(TObjectList)//dbg/
  private
    function GetItem(Index: Integer): TGroupSortField;
    procedure SetItem(Index: Integer; const Value: TGroupSortField);
  public
    property Items[Index: Integer]: TGroupSortField read GetItem write SetItem; default;
  end;

  TFormulaFields = class(TObjectList)
  private
    function GetItem(Index: Integer): TGroupAgg;
    procedure SetItem(Index: Integer; const Value: TGroupAgg);
  public
    property Items[Index: Integer]: TGroupAgg read GetItem write SetItem; default;
  end;


  {$ENDIF}

  TIBCustomDataSet = class(TDataset)
  private
    //FNeedsRefresh: Boolean;
    FForcedRefresh: Boolean;
    FIBLoaded: Boolean;
    FBase: TIBBase;
    //!!!b
    FAggregatesActive: Boolean;
    FAggregates: TgdcAggregates;
    FReadBase: TIBBase;
    FBeforeInternalPostRecord: TDataSetNotifyEvent;
    FAfterInternalPostRecord: TDataSetNotifyEvent;
    FBeforeInternalDeleteRecord: TDataSetNotifyEvent;
    FAfterInternalDeleteRecord: TDataSetNotifyEvent;
    {$IFDEF NEW_GRID}
    FPseudoRecordsOn: Boolean;
    FPseudoSkip: Integer;
    FOnPseudoRecordsOn: TFilterRecordEvent;
    FGroupSortFields: TGroupSortFields;{TObjectList;}
    FFormulaFields: TFormulaFields{TObjectList};
    FFinding: Boolean;
    {$ELSE}
    FSortField: String;
    FSortAscending: Boolean;
    {$ENDIF}
    //!!!e
    //FBlobCacheOffset: Integer;
    FBlobStreamList: TList;
    FBufferChunks: Integer;
    //FBufferCache,
    FOldBufferCache: PChar;
    FBufferChunkSize,
    FCacheSize,
    FOldCacheSize: Integer;
    //FFilterBuffer: PChar;
    FBPos,
    FOBPos,
    FBEnd,
    FOBEnd: DWord;
    FCachedUpdates: Boolean;
    FCalcFieldsOffset: Integer;
    FCurrentRecord: Long;
    FDeletedRecords: Long;
    //FModelBuffer,
    FOldBuffer, FTempBuffer: PChar;
    FOpen: Boolean;
    FInternalPrepared: Boolean;
    //FQDelete,
    FQInsert,
    FQRefresh,
    //FQSelect,
    FQModify: TIBSQL;
    FRecordBufferSize: Integer;
    //FRecordCount: Integer;
    FRecordSize: Integer;
    FUniDirectional: Boolean;
    FUpdateMode: TUpdateMode;
    //FUpdateObject: TIBDataSetUpdateObject;
    FParamCheck: Boolean;
    FUpdatesPending: Boolean;
    FUpdateRecordTypes: TIBUpdateRecordTypes;
    //FMappedFieldPosition: array of Integer;
    FDataLink: TIBDataLink;
    FStreamedActive : Boolean;
    FLiveMode: TLiveModes;
    FGeneratorField: TIBGeneratorField;
    //FRowsAffected: Integer;

    FBeforeDatabaseDisconnect,
    FAfterDatabaseDisconnect,
    FDatabaseFree: TNotifyEvent;
    FOnUpdateError: TIBUpdateErrorEvent;
    FOnUpdateRecord: TIBUpdateRecordEvent;
    FBeforeTransactionEnd,
    FAfterTransactionEnd,
    FTransactionFree: TNotifyEvent;
    //!!!
    FReadTransactionSet: Boolean;
    FInsertedAt: Integer;
    FAllowStreamedActive: Boolean;
    FSavedRecordCount: Integer;
    FDisableScrollCount : Integer;
    //!!!

    function GetSelectStmtHandle: TISC_STMT_HANDLE;
    procedure SetUpdateMode(const Value: TUpdateMode);
    procedure SetUpdateObject(Value: TIBDataSetUpdateObject);

    function AdjustCurrentRecord(Buffer: Pointer; GetMode: TGetMode): TGetResult;
    procedure AdjustRecordOnInsert(Buffer: Pointer);
    function CanEdit: Boolean;
    function CanInsert: Boolean;
    function CanDelete: Boolean;
    //function CanRefresh: Boolean;
    procedure CheckEditState;
    procedure ClearBlobCache;
    //b!!!
    //procedure CopyRecordBuffer(Source, Dest: Pointer);
    //e!!!
    procedure DoBeforeDatabaseDisconnect(Sender: TObject);
    procedure DoAfterDatabaseDisconnect(Sender: TObject);
    procedure DoDatabaseFree(Sender: TObject);
    procedure DoBeforeTransactionEnd(Sender: TObject);
    //procedure DoAfterTransactionEnd(Sender: TObject);
    procedure DoTransactionFree(Sender: TObject);
    procedure FetchCurrentRecordToBuffer(Qry: TIBSQL; RecordNumber: Integer;
                                         Buffer: PChar);
    function GetDatabase: TIBDatabase;
    function GetDBHandle: PISC_DB_HANDLE;
    function GetDeleteSQL: TStrings;
    function GetInsertSQL: TStrings;
    function GetSQLParams: TIBXSQLDA;
    function GetRefreshSQL: TStrings;
    function GetSelectSQL: TStrings;
    function GetStatementType: TIBSQLTypes;
    function GetModifySQL: TStrings;
    function GetTransaction: TIBTransaction;
    function GetTRHandle: PISC_TR_HANDLE;
    //procedure InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer);
    function InternalLocate(const KeyFields: string; const KeyValues: Variant;
                            Options: TLocateOptions): Boolean;
    //procedure InternalPostRecord(Qry: TIBSQL; Buff: Pointer);
    procedure InternalRevertRecord(RecordNumber: Integer);
    function IsVisible(Buffer: PChar): Boolean;
    procedure SaveOldBuffer(Buffer: PChar);
    procedure SetBufferChunks(Value: Integer);
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetDeleteSQL(Value: TStrings);
    procedure SetInsertSQL(Value: TStrings);
    //procedure SetInternalSQLParams(Qry: TIBSQL; Buffer: Pointer);
    procedure SetRefreshSQL(Value: TStrings);
    procedure SetSelectSQL(Value: TStrings);
    procedure SetModifySQL(Value: TStrings);
    //procedure SetTransaction(Value: TIBTransaction);
    procedure SetUpdateRecordTypes(Value: TIBUpdateRecordTypes);
    procedure SetUniDirectional(Value: Boolean);
    procedure RefreshParams;
    procedure SQLChanging(Sender: TObject);
    function AdjustPosition(FCache: PChar; Offset: DWORD;
                            Origin: Integer): Integer;
    procedure ReadCache(FCache: PChar; Offset: DWORD; Origin: Integer;
                       Buffer: PChar);
    //procedure ReadRecordCache(RecordNumber: Integer; Buffer: PChar;
    //                          ReadOldBuffer: Boolean);
    procedure WriteCache(FCache: PChar; Offset: DWORD; Origin: Integer;
                        Buffer: PChar);
    //procedure WriteRecordCache(RecordNumber: Integer; Buffer: PChar);
    function InternalGetRecord(Buffer: PChar; GetMode: TGetMode;
                       DoCheck: Boolean): TGetResult;
    procedure SetGeneratorField(const Value: TIBGeneratorField);
    {!!!}
    {
    function InternalGetFieldData(Field: TField; Buffer: Pointer): Boolean;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); virtual;
    }
    {!!!}
    function GetPlan: String;

    //!!!
    function GetReadTransaction: TIBTransaction;

    procedure SetAggregatesActive(const Value: Boolean);

    {$IFDEF HEAP_STRING_FIELD}

    // мы будем сохранять это поле в куче или стандартным
    // ИБИКСовским методом
    function IsHeapField(FD: TFieldData): Boolean;

    // если есть поля, сохраненные в куче, то выделим под них
    // память и заполним их значениями из источника
    // т.е. создадим копии динамических строк
    // после использования буфер Дест надо обязательно
    // финализировать!
    procedure InitializeRecordBuffer(Source, Dest: Pointer);

    // кэш содержит несколько буферов записей
    // финализировать кэш означает пройтись по нему и
    // для всех записей, для которых в памяти выделялись динамические
    // строки освободить память
    procedure FinalizeCacheBuffer(Buffer: PChar; const Size: Integer);

    {$ENDIF}
    //!!!


  protected
    {andreik}
    //!!!
    // перенесено из Приват
    //FRowsAffected: Integer;
    FLastQuery: TLastQuery;
    FUpdateObject: TIBDataSetUpdateObject;
    FQSelect, FQDelete: TIBSQL;
    FBlobCacheOffset: Integer;
    FMappedFieldPosition: array of Integer;
    FNeedsRefresh: Boolean;
    FFilterBuffer: PChar;
    FBufferCache: PChar;
    FRecordCount: Integer;
    FDataTransfer: Boolean; // добавлено!
    FAggregatesObsolete: Boolean; // !!!
    FPeekBuffer: PChar; // !!!
    FOpenCounter: Integer; //!!!
    FModelBuffer: PChar; //!!!
    FOnCalcAggregates: TFilterRecordEvent; //добавлено
    FSavedFlag: Boolean; //!!!
    FSavedRN: Integer; //!!!
    function CanRefresh: Boolean;
    procedure InternalPostRecord(Qry: TIBSQL; Buff: Pointer); virtual;
    procedure SetInternalSQLParams(Qry: TIBSQL; Buffer: Pointer);
    procedure InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer); virtual;
    procedure ReadRecordCache(RecordNumber: Integer; Buffer: PChar;
                              ReadOldBuffer: Boolean);
    procedure WriteRecordCache(RecordNumber: Integer; Buffer: PChar);
    procedure DoAfterTransactionEnd(Sender: TObject); virtual;
    function InternalGetFieldData(Field: TField; Buffer: Pointer): Boolean;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); virtual;
    procedure SetTransaction(Value: TIBTransaction); virtual;
    procedure SetFiltered(Value: Boolean); override;

    //b!!!
    procedure CopyRecordBuffer(Source, Dest: Pointer);
    procedure DoBeforeOpen; override;
    procedure DoBeforeScroll; override;
    procedure DoAfterScroll; override;    
    //e!!!

    //!!!
    // если есть поля, сохраненные в куче, освободим память
    // обнулим так же указатели, так что повторный вызов
    // не приведет к фатальным последствиям
    procedure FinalizeRecordBuffer(Buffer: Pointer);
    //!!!

    // добавлено
    procedure DoBeforeReadDatabaseDisconnect(Sender: TObject);
    procedure DoAfterReadDatabaseDisconnect(Sender: TObject);
    procedure DoReadDatabaseFree(Sender: TObject);
    procedure DoBeforeReadTransactionEnd(Sender: TObject);
    procedure DoAfterReadTransactionEnd(Sender: TObject);
    procedure DoReadTransactionFree(Sender: TObject);

    function AllowCloseTransaction: Boolean;

    procedure CheckOperation(Operation: TDataOperation;
      ErrorEvent: TDataSetErrorEvent);

    procedure SetReadTransaction(const Value: TIBTransaction); virtual;
    //!!!

    procedure ActivateConnection;
    function ActivateTransaction: Boolean;
    function ActivateReadTransaction: Boolean;
    procedure DeactivateTransaction;
    procedure DeactivateReadTransaction;
    procedure CheckDatasetClosed;
    procedure CheckDatasetOpen;
    function GetActiveBuf: PChar;
    procedure InternalBatchInput(InputObject: TIBBatchInput); virtual;
    procedure InternalBatchOutput(OutputObject: TIBBatchOutput); virtual;
    procedure InternalPrepare; virtual;
    procedure InternalUnPrepare; virtual;
    procedure InternalExecQuery; virtual;
    procedure InternalRefreshRow; virtual;
    procedure InternalSetParamsFromCursor; virtual;
    procedure CheckNotUniDirectional;
    procedure SetActive(Value: Boolean); override;

    { IProviderSupport }
    procedure PSEndTransaction(Commit: Boolean); override;
    function PSExecuteStatement(const ASQL: string; AParams: TParams;
      ResultSet: Pointer = nil): Integer; override;
    function PsGetTableName: string; override;
    function PSGetQuoteChar: string; override;
    function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError; override;
    function PSInTransaction: Boolean; override;
    function PSIsSQLBased: Boolean; override;
    function PSIsSQLSupported: Boolean; override;
    procedure PSStartTransaction; override;
    procedure PSReset; override;
    function PSUpdateRecord(UpdateKind: TUpdateKind; Delta: TDataSet): Boolean; override;

    { TDataSet support }
    procedure InternalInsert; override;
    procedure InitRecord(Buffer: PChar); override;
    procedure Disconnect; virtual;
    function ConstraintsStored: Boolean;
    procedure ClearCalcFields(Buffer: PChar); override;
    procedure CreateFields; override;
    function AllocRecordBuffer: PChar; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function GetCanModify: Boolean; override;
    function GetDataSource: TDataSource; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function GetRecNo: Integer; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode;
                       DoCheck: Boolean): TGetResult; override;
    function GetRecordCount: Integer; override;
    function GetRecordSize: Word; override;
{$IFDEF NEW_GRID}
    function GetPriorRecord: Boolean; override; //!!!^^^!!!
    function GetNextRecord: Boolean; override; //!!!^^^!!!
{$ENDIF}
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalCancel; override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalRefresh; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    function IsCursorOpen: Boolean; override;
    procedure ReQuery;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetCachedUpdates(Value: Boolean);
    procedure SetDataSource(Value: TDataSource);
    procedure SetFieldData(Field : TField; Buffer : Pointer); override;
    procedure SetFieldData(Field : TField; Buffer : Pointer;
      NativeFormat : Boolean); overload; override;
    procedure SetRecNo(Value: Integer); override;
    procedure DoOnNewRecord; override;
    procedure Loaded; override;

    //!!!b
    procedure DoAfterDelete; override;
    procedure DoAfterPost; override;
    procedure DoAfterRefresh; override;
    //!!!e

    function GetRowsAffected: Integer;

  protected
    {Likely to be made public by descendant classes}
    property SQLParams: TIBXSQLDA read GetSQLParams;
    property Params: TIBXSQLDA read GetSQLParams;
    property InternalPrepared: Boolean read FInternalPrepared;
    property QDelete: TIBSQL read FQDelete;
    property QInsert: TIBSQL read FQInsert;
    property QRefresh: TIBSQL read FQRefresh;
    //property QSelect: TIBSQL read FQSelect;
    property QModify: TIBSQL read FQModify;
    property StatementType: TIBSQLTypes read GetStatementType;
    property SelectStmtHandle: TISC_STMT_HANDLE read GetSelectStmtHandle;
    property LiveMode : TLiveModes read FLiveMode;

    {Likely to be made published by descendant classes}
    property BufferChunks: Integer read FBufferChunks write SetBufferChunks default BufferCacheSize;
    property CachedUpdates: Boolean read FCachedUpdates write SetCachedUpdates default False;
    property UniDirectional: Boolean read FUniDirectional write SetUniDirectional default False;
    property DeleteSQL: TStrings read GetDeleteSQL write SetDeleteSQL;
    property InsertSQL: TStrings read GetInsertSQL write SetInsertSQL;
    property RefreshSQL: TStrings read GetRefreshSQL write SetRefreshSQL;
    property SelectSQL: TStrings read GetSelectSQL write SetSelectSQL;
    property ModifySQL: TStrings read GetModifySQL write SetModifySQL;
    property UpdateMode: TUpdateMode read FUpdateMode write SetUpdateMode default upWhereAll;
    property ParamCheck: Boolean read FParamCheck write FParamCheck default True;
    property GeneratorField : TIBGeneratorField read FGeneratorField write SetGeneratorField;

    property BeforeDatabaseDisconnect: TNotifyEvent read FBeforeDatabaseDisconnect
                                                 write FBeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect: TNotifyEvent read FAfterDatabaseDisconnect
                                                write FAfterDatabaseDisconnect;
    property DatabaseFree: TNotifyEvent read FDatabaseFree
                                        write FDatabaseFree;
    property BeforeTransactionEnd: TNotifyEvent read FBeforeTransactionEnd
                                             write FBeforeTransactionEnd;
    property AfterTransactionEnd: TNotifyEvent read FAfterTransactionEnd
                                            write FAfterTransactionEnd;
    property TransactionFree: TNotifyEvent read FTransactionFree
                                           write FTransactionFree;

    //
    property _RecordBufferSize: Integer read FRecordBufferSize;
    property _CurrentRecord: Integer read FCurrentRecord;
    //

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyUpdates;
    function CachedUpdateStatus: TCachedUpdateStatus;
    {$IFDEF NEW_GRID}
    function RecordKind: TRecordKind;
    procedure SetFinding(Value: Boolean);
    function RecordGroupFilterAccept: Boolean;
    procedure SetPseudoRecordsOn(const Value: Boolean);
//    procedure First; override; //!!!^^^!!!
//    procedure Last; override; //!!!^^^!!!
//    function MoveBy(Distance: Integer): Integer; override; //!!!^^^!!!
    function _RecordNumber: Long;//dbg/удалить когда-нибудь/
    function Dbg1(Buffer: PChar=nil): string;//dbg/удалить когда-нибудь/
    procedure _setPseudoRecordsOn(V:Boolean);
    {$ENDIF}
    procedure CancelUpdates;
    procedure FetchAll;
    function LocateNext(const KeyFields: string; const KeyValues: Variant;
                        Options: TLocateOptions): Boolean;
    procedure RecordModified(Value: Boolean);
    procedure RevertRecord;
    procedure Undelete;
    procedure Post; override;
    function Current : TIBXSQLDA;
    function SQLType : TIBSQLTypes;

    //!!!b
    procedure Cancel; override;
    procedure CheckRequiredFields;
    //!!!e

    //!!!b
    procedure Sort(F: TField; const Ascending: Boolean = True);
    {$IFDEF NEW_GRID}
    procedure Sort2(BeforeGroup: Boolean = True);

    // AFieldList = FGL[FSL][AFL]
    // FGL = FG[,FG]
    // FG  = "G"(FN)SO
    // FN  = <field name>
    // SO  = {"A"|"D"}
    // FSL = FS[,FS]
    // FS  = "S"(FN)SO
    // AFL = AF[,AF]
    // AF  = "A"(FN)F
    // F   = {SUM|AVG|MAX|MIN|COUNT}
    procedure UnGroup(BeforeGroup: Boolean);
    procedure Group;
    procedure ClearGroupSort;
    procedure AddGroupSortField(F: TField;  const AGroupSortOrder: TGroupSortOrder;
      AIntScale: Integer; ADateScale: TDateScale; AStrScale: string);
    procedure SortGroupSortAtField(F: TField);

    procedure AddFormulaField(F: TField; const AFormula: String);
    function GetFormulaByField(F: TField): string;
    function GroupSortExist: Boolean;
    function IsGroupSortField(F: TField; OnlyGroup: Boolean = false): Boolean;
    function IsGroupSortFieldAsc(F: TField): Boolean;
    procedure WrapGroup;
    procedure WrapAllGroups;
    procedure UnWrapAllGroups;
    procedure InternalWrapGroup(P: PChar);

    function GetDateScale(const Txt: string): TDateScale;
    {$ENDIF}

    procedure DisableScrollEvents;
    procedure EnableScrollEvents;
    //!!!e

    //!!!b
    //
    procedure ResetAllAggs(AnActive: Boolean; BL: TBookmarkList);
    //!!!e

    { TDataSet support methods }
        property CurRecord: Integer read FCurrentRecord;//&&&
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetCurrentRecord(Buffer: PChar): Boolean; override;
    function GetFieldData(Field : TField; Buffer : Pointer) : Boolean; overload; override;
    function GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean; overload; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
                    Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
                    const ResultFields: string): Variant; override;
    function UpdateStatus: TUpdateStatus; override;
    function IsSequenced: Boolean; override;
    property DBHandle: PISC_DB_HANDLE read GetDBHandle;
    property TRHandle: PISC_TR_HANDLE read GetTRHandle;
    property UpdateObject: TIBDataSetUpdateObject read FUpdateObject write SetUpdateObject;
    property UpdatesPending: Boolean read FUpdatesPending;
    property UpdateRecordTypes: TIBUpdateRecordTypes read FUpdateRecordTypes
                                                      write SetUpdateRecordTypes;
    property RowsAffected: Integer read GetRowsAffected;
    property Plan: String read GetPlan;

    //!!!b
    property QSelect: TIBSQL read FQSelect;

    property ReadTransaction: TIBTransaction read GetReadTransaction write SetReadTransaction;
    property CacheSize: Integer read FCacheSize;

    //
    property AggregatesActive: Boolean read FAggregatesActive write SetAggregatesActive;
    property Aggregates: TgdcAggregates read FAggregates;
    property AggregatesObsolete: Boolean read FAggregatesObsolete;

    property OpenCounter: Integer read FOpenCounter;

    property OnCalcAggregates: TFilterRecordEvent read FOnCalcAggregates write FOnCalcAggregates;

    {$IFDEF NEW_GRID}
      property PseudoRecordsOn: Boolean read FPseudoRecordsOn write SetPseudoRecordsOn;
      property PseudoSkip: Integer read FPseudoSkip;
      property OnPseudoRecordsOn: TFilterRecordEvent read FOnPseudoRecordsOn write FOnPseudoRecordsOn;
      property DataLink: TIBDataLink read FDataLink;

      property GroupSortFields: TGroupSortFields{TObjectList} read FGroupSortFields;
      property FormulaFields: TFormulaFields{TObjectList} read FFormulaFields;
      property Finding: Boolean read FFinding;
    {$ELSE}
      property SortField: String read FSortField;
      property SortAscending: Boolean read FSortAscending;
    {$ENDIF}
    //!!!e

  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction
                                          write SetTransaction;
    property ForcedRefresh: Boolean read FForcedRefresh
                                    write FForcedRefresh default False;
    property AutoCalcFields;
    property ObjectView default False;

    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterRefresh;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeRefresh;
    property BeforeScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
    property OnUpdateError: TIBUpdateErrorEvent read FOnUpdateError
                                                 write FOnUpdateError;
    property OnUpdateRecord: TIBUpdateRecordEvent read FOnUpdateRecord
                                                   write FOnUpdateRecord;

    //!!!
    property BeforeInternalPostRecord: TDataSetNotifyEvent read FBeforeInternalPostRecord
      write FBeforeInternalPostRecord;
    property AfterInternalPostRecord: TDataSetNotifyEvent read FAfterInternalPostRecord
      write FAfterInternalPostRecord;
    property BeforeInternalDeleteRecord: TDataSetNotifyEvent read FBeforeInternalDeleteRecord
      write FBeforeInternalDeleteRecord;
    property AfterInternalDeleteRecord: TDataSetNotifyEvent read FAfterInternalDeleteRecord
      write FAfterInternalDeleteRecord;
    //!!!

    //!!!
    property AllowStreamedActive: Boolean read FAllowStreamedActive write FAllowStreamedActive
      default False;
    //!!!
  end;

  TIBDataSet = class(TIBCustomDataSet)
  private
    function GetPrepared: Boolean;

  protected
    procedure PSSetCommandText(const CommandText: string); override;
    procedure SetFiltered(Value: Boolean); override;
    procedure InternalOpen; override;

  public
    procedure Prepare;
    procedure UnPrepare;
    procedure BatchInput(InputObject: TIBBatchInput);
    procedure BatchOutput(OutputObject: TIBBatchOutput);
    procedure ExecSQL;

  public
    function ParamByName(Idx : String) : TIBXSQLVAR;
    property Params;
    property Prepared : Boolean read GetPrepared;
    property StatementType;
    property SelectStmtHandle;
    property LiveMode;

  { by andreik!!! }  
  public
    property QDelete;
    property QInsert;
    property QRefresh;
    property QSelect;
    property QModify;

  published
    { TIBCustomDataSet }
    property BufferChunks;
    property CachedUpdates;
    property DeleteSQL;
    property InsertSQL;
    property RefreshSQL;
    property SelectSQL;
    property ModifySQL;
    property ParamCheck;
    property UniDirectional;
    property Filtered;
    property GeneratorField;
    property BeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect;
    property DatabaseFree;
    property BeforeTransactionEnd;
    property AfterTransactionEnd;
    property TransactionFree;
    property UpdateObject;
    ///!!!!b
    property OnCalcAggregates;
    //!!!!e
    { TIBDataSet }
    property Active;
    property AutoCalcFields;
    property DataSource read GetDataSource write SetDataSource;

    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;

    //andreik!
    property ReadTransaction;
  end;

  { TIBDSBlobStream }
  TIBDSBlobStream = class(TStream)
  protected
    FField: TField;
    FBlobStream: TIBBlobStream;
    FModified : Boolean;
  public
    constructor Create(AField: TField; ABlobStream: TIBBlobStream;
                       Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

  //!!!b

{ TgsMemoField }

  TgsMemoField = class(TMemoField)
  private
    //Вниутренний обработчик OnSetText
    procedure InsideSetText(Sender: TField; const Text: string);

  protected
    procedure SetText(const Value: string); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  //!!!e

const
DefaultFieldClasses: array[TFieldType] of TFieldClass = (
    nil,                { ftUnknown }
    TIBStringField,     { ftString }
    TSmallintField,     { ftSmallint }
    TIntegerField,      { ftInteger }
    TWordField,         { ftWord }
    TBooleanField,      { ftBoolean }
    TFloatField,        { ftFloat }
    TCurrencyField,     { ftCurrency }
    TIBBCDField,        { ftBCD }
    TDateField,         { ftDate }
    TTimeField,         { ftTime }
    TDateTimeField,     { ftDateTime }
    TBytesField,        { ftBytes }
    TVarBytesField,     { ftVarBytes }
    TAutoIncField,      { ftAutoInc }
    TEnhBlobField,
    //TBlobField,         { ftBlob }
    TgsMemoField,         { ftMemo }
    //TMemoField,         { ftMemo }
    TEnhGraphicField,
    //TGraphicField,      { ftGraphic }
    TBlobField,         { ftFmtMemo }
    TBlobField,         { ftParadoxOle }
    TBlobField,         { ftDBaseOle }
    TBlobField,         { ftTypedBinary }
    nil,                { ftCursor }
    TStringField,       { ftFixedChar }
    nil, {TWideStringField } { ftWideString }
    TLargeIntField,     { ftLargeInt }
    TADTField,          { ftADT }
    TArrayField,        { ftArray }
    TReferenceField,    { ftReference }
    TDataSetField,     { ftDataSet }
    TBlobField,         { ftOraBlob }
    TgsMemoField,         { ftOraClob }
    //TMemoField,         { ftOraClob }
    TVariantField,      { ftVariant }
    TInterfaceField,    { ftInterface }
    TIDispatchField,     { ftIDispatch }
    TGuidField);        { ftGuid }

  {$IFDEF NEW_GRID}
  ArDateScale: array[dsType..dsYear] of String =
               ( '', 'День', 'Неделя', 'Месяц', 'Квартал', 'Год' );
  {$ENDIF}

var
  CreateProviderProc: function(DataSet: TIBCustomDataSet): IProvider = nil;

  // глобальная переменная MAX_LOCATE_WAIT определяет
  // как будет осуществляться поиск с помощью LOCATE
  // MAX_LOCATE_WAIT > 0, поиск будет длиться не более
  // указанного количества миллисекунд
  // если время поиска превышено, то возвращается False
  // (запись не найдена)
  // используйте с конструкцией
  // try finally end.
var
  MAX_LOCATE_WAIT: DWORD;

implementation

uses
  IBIntf, DBConsts,
  //uDemo1{&&&},
  {$IFDEF GEDEMIN}
  gd_security,
  {$ENDIF}
  dlgRecordFetch_unit, Forms, flt_sql_parser; //!!! added by Andreik

{ TIBStringField}

constructor TIBStringField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

class procedure TIBStringField.CheckTypeSize(Value: Integer);
begin
  { don't check string size. all sizes valid }
end;

function TIBStringField.GetAsString: string;
begin
  if not GetValue(Result) then Result := '';
end;

function TIBStringField.GetAsVariant: Variant;
var
  S: string;
begin
  if GetValue(S) then Result := S else Result := Null;
end;

function TIBStringField.GetValue(var Value: string): Boolean;
var
  Buffer: PChar;
begin
  Buffer := nil;
  IBAlloc(Buffer, 0, Size + 1);
  try
    Result := GetData(Buffer);
    if Result then
    begin
      Value := string(Buffer);
      if Transliterate and (Value <> '') then
        DataSet.Translate(PChar(Value), PChar(Value), False);
    end
  finally
    FreeMem(Buffer);
  end;
end;

procedure TIBStringField.SetAsString(const Value: string);
var
  Buffer: PChar;
begin
  Buffer := nil;
  IBAlloc(Buffer, 0, Size + 1);
  try
    StrLCopy(Buffer, PChar(Value), Size);
    if Transliterate then
      DataSet.Translate(Buffer, Buffer, True);
    SetData(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

{ TIBBCDField }

constructor TIBBCDField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftBCD);
  Size := 8;
end;

class procedure TIBBCDField.CheckTypeSize(Value: Integer);
begin
{ No need to check as the base type is currency, not BCD }
end;

function TIBBCDField.GetAsCurrency: Currency;
begin
  if not GetValue(Result) then
    Result := 0;
end;

function TIBBCDField.GetAsString: string;
var
  C: System.Currency;
begin
  if GetValue(C) then
    Result := CurrToStr(C)
  else
    Result := '';
end;

function TIBBCDField.GetAsVariant: Variant;
var
  C: System.Currency;
begin
  if GetValue(C) then
    Result := C
  else
    Result := Null;
end;

function TIBBCDField.GetDataSize: Integer;
begin
  Result := 8;
end;

{ TIBDataLink }

constructor TIBDataLink.Create(ADataSet: TIBCustomDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
end;

destructor TIBDataLink.Destroy;
begin
  FDataSet.FDataLink := nil;
  inherited Destroy;
end;


procedure TIBDataLink.ActiveChanged;
begin
  if FDataSet.Active then
    FDataSet.RefreshParams;
end;


function TIBDataLink.GetDetailDataSet: TDataSet;
begin
  Result := FDataSet;
end;

procedure TIBDataLink.RecordChanged(Field: TField);
begin
  if (Field = nil) and FDataSet.Active then
    FDataSet.RefreshParams;
end;

procedure TIBDataLink.CheckBrowseMode;
begin
  if FDataSet.Active then
    FDataSet.CheckBrowseMode;
end;

{ TIBCustomDataSet }

constructor TIBCustomDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIBLoaded := False;
  CheckIBLoaded;
  FIBLoaded := True;
  FBase := TIBBase.Create(Self);
  //!!!
  FReadBase := TIBBase.Create(Self);
  FReadTransactionSet := False;
  FDataTransfer := False;
  FAggregatesObsolete := True;
  FAllowStreamedActive := False;
  FSavedRecordCount := -1;
  FDisableScrollCount := 0;
  //!!!
  FCurrentRecord := -1;
  FDeletedRecords := 0;
  FUniDirectional := False;
  FBufferChunks := BufferCacheSize;
  FBlobStreamList := TList.Create;
  FDataLink := TIBDataLink.Create(Self);
  FQDelete := TIBSQL.Create(Self);
  FQDelete.OnSQLChanging := SQLChanging;
  FQDelete.GoToFirstRecordOnExecute := False;
  FQInsert := TIBSQL.Create(Self);
  FQInsert.OnSQLChanging := SQLChanging;
  FQInsert.GoToFirstRecordOnExecute := False;
  FQRefresh := TIBSQL.Create(Self);
  FQRefresh.OnSQLChanging := SQLChanging;
  FQRefresh.GoToFirstRecordOnExecute := False;
  FQSelect := TIBSQL.Create(Self);
  FQSelect.OnSQLChanging := SQLChanging;
  FQSelect.GoToFirstRecordOnExecute := False;
  FQModify := TIBSQL.Create(Self);
  FQModify.OnSQLChanging := SQLChanging;
  FQModify.GoToFirstRecordOnExecute := False;
  FUpdateRecordTypes := [cusUnmodified, cusModified, cusInserted];
  FParamCheck := True;
  FForcedRefresh := False;
  FGeneratorField := TIBGeneratorField.Create(Self);
  {Bookmark Size is Integer for IBX}
  BookmarkSize := SizeOf(Integer);
  FBase.BeforeDatabaseDisconnect := DoBeforeDatabaseDisconnect;
  FBase.AfterDatabaseDisconnect := DoAfterDatabaseDisconnect;
  FBase.OnDatabaseFree := DoDatabaseFree;
  FBase.BeforeTransactionEnd := DoBeforeTransactionEnd;
  FBase.AfterTransactionEnd := DoAfterTransactionEnd;
  FBase.OnTransactionFree := DoTransactionFree;
  //!!!b
  FReadBase.BeforeDatabaseDisconnect := DoBeforeReadDatabaseDisconnect;
  FReadBase.AfterDatabaseDisconnect := DoAfterReadDatabaseDisconnect;
  FReadBase.OnDatabaseFree := DoReadDatabaseFree;
  FReadBase.BeforeTransactionEnd := DoBeforeReadTransactionEnd;
  FReadBase.AfterTransactionEnd := DoAfterReadTransactionEnd;
  FReadBase.OnTransactionFree := DoReadTransactionFree;

  FAggregates := TgdcAggregates.Create(Self);
  FAggregatesActive := False;

  FOpenCounter := 0;
  //!!!e
  FLiveMode := [];
  //FRowsAffected := 0;
  FLastQuery := lqNone;
  FStreamedActive := false;
  if AOwner is TIBDatabase then
    Database := TIBDatabase(AOwner)
  else
    if AOwner is TIBTransaction then
      Transaction := TIBTransaction(AOwner);

  {$IFDEF NEW_GRID}
  FFinding := false;
  {$ENDIF}
end;

destructor TIBCustomDataSet.Destroy;
begin
  if FIBLoaded then
  begin
    Close;
    FreeAndNil(FDataLink);
    FreeAndNil(FBase);
    //!!!b
    FreeAndNil(FReadBase);
    FreeAndNil(FAggregates);
    {$IFDEF NEW_GRID}
    ClearGroupSort;
    {$ENDIF}
    //!!!e
    ClearBlobCache;
    FreeAndNil(FBlobStreamList);
    {$IFDEF HEAP_STRING_FIELD}
    FinalizeCacheBuffer(FBufferCache, FCacheSize);
    {$ENDIF}
    FreeMem(FBufferCache, 0);
    FBufferCache := nil;
    {$IFDEF HEAP_STRING_FIELD}
    FinalizeCacheBuffer(FOldBufferCache, FOldCacheSize);
    {$ENDIF}
    FreeMem(FOldBufferCache, 0);
    FreeAndNil(FGeneratorField);
    FOldBufferCache := nil;
    FCacheSize := 0;
    FOldCacheSize := 0;
    FMappedFieldPosition := nil;
  end;
  inherited Destroy;
end;

function TIBCustomDataSet.AdjustCurrentRecord(Buffer: Pointer; GetMode: TGetMode):
                                             TGetResult;
begin
  while not IsVisible(Buffer) do
  begin
    if GetMode = gmPrior then
    begin
      Dec(FCurrentRecord);
      if FCurrentRecord = -1 then
      begin
        result := grBOF;
        exit;
      end;
      ReadRecordCache(FCurrentRecord, Buffer, False);
    end
    else
    begin
      Inc(FCurrentRecord);
      if (FCurrentRecord = FRecordCount) then
      begin
        if (not FQSelect.EOF) and (FQSelect.Next <> nil) then
        begin
          FetchCurrentRecordToBuffer(FQSelect, FCurrentRecord, Buffer);
          Inc(FRecordCount);
        end
        else
        begin
          //!!!
          //FAggregatesObsolete := True;
          //!!!
          result := grEOF;
          exit;
        end;
      end
      else
        ReadRecordCache(FCurrentRecord, Buffer, False);
    end;
  end;
  result := grOK;
end;

procedure TIBCustomDataSet.ApplyUpdates;
var
  CurBookmark: string;
  Buffer: PRecordData;
  CurUpdateTypes: TIBUpdateRecordTypes;
  UpdateAction: TIBUpdateAction;
  UpdateKind: TUpdateKind;
  bRecordsSkipped: Boolean;
  R: Boolean;
  //TempCurrent: Integer;
  Buff: PChar;

  procedure GetUpdateKind;
  begin
    case Buffer^.rdCachedUpdateStatus of
      cusModified:
        UpdateKind := ukModify;
      cusInserted:
        UpdateKind := ukInsert;
      else
        UpdateKind := ukDelete;
    end;
  end;

  procedure ResetBufferUpdateStatus;
  begin
    case Buffer^.rdCachedUpdateStatus of
      cusModified:
      begin
        PRecordData(Buffer)^.rdUpdateStatus := usUnmodified;
        PRecordData(Buffer)^.rdCachedUpdateStatus := cusUnmodified;
      end;
      cusInserted:
      begin
        PRecordData(Buffer)^.rdUpdateStatus := usUnmodified;
        PRecordData(Buffer)^.rdCachedUpdateStatus := cusUnmodified;
      end;
      cusDeleted:
      begin
        PRecordData(Buffer)^.rdUpdateStatus := usDeleted;
        PRecordData(Buffer)^.rdCachedUpdateStatus := cusUnmodified;
      end;
    end;
    WriteRecordCache(PRecordData(Buffer)^.rdRecordNumber, Pointer(Buffer));
  end;

  procedure UpdateUsingOnUpdateRecord;
  begin
    UpdateAction := uaFail;
    try
      FOnUpdateRecord(Self, UpdateKind, UpdateAction);
    except
      on E: Exception do
      begin
        if (E is EDatabaseError) and Assigned(FOnUpdateError) then
          FOnUpdateError(Self, EIBError(E), UpdateKind, UpdateAction);
        if UpdateAction = uaFail then
          raise;
      end;
    end;
  end;

  procedure UpdateUsingUpdateObject;
  begin
    UpdateAction := uaApply;
    try
      FUpdateObject.Apply(UpdateKind);
      ResetBufferUpdateStatus;
    except
      on E: Exception do
      begin
        UpdateAction := uaFail;
        if (E is EDatabaseError) and Assigned(FOnUpdateError) then
          FOnUpdateError(Self, EIBError(E), UpdateKind, UpdateAction);
        if UpdateAction = uaFail then
          raise;
      end;
    end;
  end;

  procedure UpdateUsingInternalquery;
  begin
    try
      case Buffer^.rdCachedUpdateStatus of
        cusModified:
          InternalPostRecord(FQModify, Buffer);
        cusInserted:
          InternalPostRecord(FQInsert, Buffer);
        cusDeleted:
          InternalDeleteRecord(FQDelete, Buffer);
      end;
    except
      on E: EIBError do begin
        UpdateAction := uaFail;
        if Assigned(FOnUpdateError) then
          FOnUpdateError(Self, E, UpdateKind, UpdateAction);
        case UpdateAction of
          uaFail: raise;
          uaAbort: SysUtils.Abort;
          uaSkip: bRecordsSkipped := True;
        end;
      end;
    end;
  end;

begin
  if State in [dsEdit, dsInsert] then
    Post;
  FBase.CheckDatabase;
  //!!!
  //FBase.CheckTransaction;
  //!!!
  DisableControls;
  CurBookmark := Bookmark;
  CurUpdateTypes := FUpdateRecordTypes;
  FUpdateRecordTypes := [cusModified, cusInserted, cusDeleted];
  try
    First;
    bRecordsSkipped := False;
    while not EOF do
    begin
      Buffer := PRecordData(GetActiveBuf);
      GetUpdateKind;
      UpdateAction := uaApply;
      if Assigned(FUpdateObject) or Assigned(FOnUpdateRecord) then
      begin
        if (Assigned(FOnUpdateRecord)) then
          UpdateUsingOnUpdateRecord
        else
          if Assigned(FUpdateObject) then
            UpdateUsingUpdateObject;
        case UpdateAction of
          uaFail:
            IBError(ibxeUserAbort, [nil]);
          uaAbort:
            SysUtils.Abort;
          uaApplied:
            ResetBufferUpdateStatus;
          uaSkip:
            bRecordsSkipped := True;
          uaRetry:
            Continue;
        end;
      end;
      if (not Assigned(FUpdateObject)) and (UpdateAction = UaApply) then
      begin
        UpdateUsingInternalquery;
        UpdateAction := uaApplied;
      end;
      Next;
    end;
    FUpdatesPending := bRecordsSkipped;
  finally
    FUpdateRecordTypes := CurUpdateTypes;

    if BookmarkValid(Pointer(CurBookmark)) then
    begin                    {??}
      {TempCurrent := FCurrentRecord;
      FCurrentRecord := PInteger(CurBookmark)^;
      Buff := ActiveBuffer;}
      Buff := FBufferCache + _RecordBufferSize * PInteger(CurBookmark)^;
      R := (_RecordBufferSize * PInteger(CurBookmark)^ < FCacheSize) and
        (PRecordData(Buff)^.rdCachedUpdateStatus <> cusDeleted);
      {FCurrentRecord := TempCurrent;}

      if R then
        Bookmark := CurBookmark
      else
        First;
    end else
      First;
      
    EnableControls;
  end;
end;

procedure TIBCustomDataSet.InternalBatchInput(InputObject: TIBBatchInput);
begin
  FQSelect.BatchInput(InputObject);
end;

procedure TIBCustomDataSet.InternalBatchOutput(OutputObject: TIBBatchOutput);
var
  Qry: TIBSQL;
begin
  Qry := TIBSQL.Create(Self);
  try
    Qry.Database := FBase.Database;
    Qry.Transaction := FBase.Transaction;
    Qry.SQL.Assign(FQSelect.SQL);
    Qry.BatchOutput(OutputObject);
  finally
    Qry.Free;
  end;
end;

procedure TIBCustomDataSet.CancelUpdates;
var
  CurUpdateTypes: TIBUpdateRecordTypes;
begin
  if State in [dsEdit, dsInsert] then
    Cancel;
  if FCachedUpdates and FUpdatesPending then
  begin
    DisableControls;
    CurUpdateTypes := UpdateRecordTypes;
    UpdateRecordTypes := [cusModified, cusInserted, cusDeleted];
    try
      First;
      while not EOF do
      begin
        if UpdateStatus = usInserted then
        //!!!
          begin
        //!!!
            RevertRecord;
        //!!!    
            First;
          end
        //!!!
        else
        begin
          RevertRecord;
          Next;
        end;
      end;
    finally
      UpdateRecordTypes := CurUpdateTypes;
      First;
      FUpdatesPending := False;
      EnableControls;
    end;
  end;
end;

procedure TIBCustomDataSet.ActivateConnection;
begin
  if not Assigned(Database) then
    IBError(ibxeDatabaseNotAssigned, [nil]);
  if not Assigned(Transaction) then
    IBError(ibxeTransactionNotAssigned, [nil]);
  if not Database.Connected then Database.Open;
end;

function TIBCustomDataSet.ActivateTransaction: Boolean;
begin
  Result := False;
  if not Assigned(Transaction) then
    IBError(ibxeTransactionNotAssigned, [nil]);
  if not Transaction.Active then
  begin
    Result := True;
    Transaction.StartTransaction;
  end;
end;

procedure TIBCustomDataSet.DeactivateTransaction;
begin
  if not Assigned(Transaction) then
    IBError(ibxeTransactionNotAssigned, [nil]);
  Transaction.CheckAutoStop;
end;

procedure TIBCustomDataSet.CheckDatasetClosed;
begin
  if FOpen then
    IBError(ibxeDatasetOpen, [nil]);
end;

procedure TIBCustomDataSet.CheckDatasetOpen;
begin
  if not FOpen then
    IBError(ibxeDatasetClosed, [nil]);
end;

procedure TIBCustomDataSet.CheckNotUniDirectional;
begin
  if UniDirectional then
    IBError(ibxeDataSetUniDirectional, [nil]);
end;

procedure TIBCustomDataSet.AdjustRecordOnInsert(Buffer: Pointer);
begin
  with PRecordData(Buffer)^ do
    if (State = dsInsert) and (not Modified) then
    begin
      rdRecordNumber := FRecordCount;
      FCurrentRecord := FRecordCount;
    end;
end;

function TIBCustomDataSet.CanEdit: Boolean;
var
  Buff: PRecordData;
begin         { TODO : CanEdit _ CanEdit}
  Buff := PRecordData(GetActiveBuf);
  result := ((FQModify.SQL.Text <> '') and (lmModify in FLiveMode)) or
    (Assigned(FUpdateObject) and (FUpdateObject.GetSQL(ukModify).Text <> '')) or
    ((Buff <> nil) and (Buff^.rdCachedUpdateStatus = cusInserted) and
      (FCachedUpdates));
end;

function TIBCustomDataSet.CanInsert: Boolean;
begin
  result := ((FQInsert.SQL.Text <> '') and (lmInsert in FLiveMode)) or
    (Assigned(FUpdateObject) and (FUpdateObject.GetSQL(ukInsert).Text <> ''));
end;

function TIBCustomDataSet.CanDelete: Boolean;
begin
  result := ((FQDelete.SQL.Text <> '') and (lmDelete in FLiveMode)) or
    (Assigned(FUpdateObject) and (FUpdateObject.GetSQL(ukDelete).Text <> ''))
  {$IFDEF NEW_GRID}
  and (ActiveBuffer <> nil) and
    ({IsEmpty or }(PRecordData(ActiveBuffer)^.rdRecordKind in [rkRecord{, rkHeaderRecord}]));
  {$ENDIF}
end;

function TIBCustomDataSet.CanRefresh: Boolean;
begin
  result := ((FQRefresh.SQL.Text <> '') and (lmRefresh in FLiveMode)) or
    (Assigned(FUpdateObject) and (FUpdateObject.RefreshSQL.Text <> ''))
  {$IFDEF NEW_GRID}
  and (ActiveBuffer <> nil) and
    ({IsEmpty or }(PRecordData(ActiveBuffer)^.rdRecordKind in [rkRecord{, rkHeaderRecord}]));
  {$ENDIF}
end;

procedure TIBCustomDataSet.CheckEditState;
begin
  case State of
    { Check all the wsEditMode types }
    dsEdit, dsInsert, dsSetKey, dsCalcFields, dsFilter,
    dsNewValue, dsInternalCalc :
    begin
      if (State in [dsEdit]) and (not CanEdit) then
        IBError(ibxeCannotUpdate, [nil]);
      if (State in [dsInsert]) and (not CanInsert) then
        IBError(ibxeCannotInsert, [nil]);
    end;
  else
    IBError(ibxeNotEditing, [])
  end;
end;

procedure TIBCustomDataSet.ClearBlobCache;
var
  i: Integer;
begin
  for i := 0 to FBlobStreamList.Count - 1 do
  begin
    TIBBlobStream(FBlobStreamList[i]).Free;
    FBlobStreamList[i] := nil;
  end;
  FBlobStreamList.Pack;
end;

procedure TIBCustomDataSet.CopyRecordBuffer(Source, Dest: Pointer);
begin
  {$IFDEF HEAP_STRING_FIELD}
  if Source <> Dest then
    FinalizeRecordBuffer(Dest);
  {$ENDIF}

  Move(Source^, Dest^, FRecordBufferSize);

  {$IFDEF HEAP_STRING_FIELD}
  InitializeRecordBuffer(Source, Dest);
  {$ENDIF}
end;

procedure TIBCustomDataSet.DoBeforeOpen;
begin
  inherited;
  if FAggregates <> nil then
    FAggregates.Clear;
end;

procedure TIBCustomDataSet.DoBeforeDatabaseDisconnect(Sender: TObject);
begin
  if Active then
    Active := False;
  FInternalPrepared := False;
  if Assigned(FBeforeDatabaseDisconnect) then
    FBeforeDatabaseDisconnect(Sender);
end;

procedure TIBCustomDataSet.DoAfterDatabaseDisconnect(Sender: TObject);
begin
  if Assigned(FAfterDatabaseDisconnect) then
    FAfterDatabaseDisconnect(Sender);
end;

procedure TIBCustomDataSet.DoDatabaseFree(Sender: TObject);
begin
  if Assigned(FDatabaseFree) then
    FDatabaseFree(Sender);
end;

procedure TIBCustomDataSet.DoBeforeTransactionEnd(Sender: TObject);
begin
  {if Active then
    Active := False;}
  {if FQSelect <> nil then
    FQSelect.FreeHandle;}
  {
  if FQDelete <> nil then
  try
    FQDelete.FreeHandle;
  except
  end;
  if FQInsert <> nil then
  try
    FQInsert.FreeHandle;
  except
  end;
  if FQModify <> nil then
  try
    FQModify.FreeHandle;
  except
  end;
  }
  {if FQRefresh <> nil then
    FQRefresh.FreeHandle;}
  {FInternalPrepared := false;}
  if Assigned(FBeforeTransactionEnd) then
    FBeforeTransactionEnd(Sender);
end;

procedure TIBCustomDataSet.DoAfterTransactionEnd(Sender: TObject);
begin
  if Assigned(FAfterTransactionEnd) then
    FAfterTransactionEnd(Sender);
end;

procedure TIBCustomDataSet.DoTransactionFree(Sender: TObject);
begin
  if Assigned(FTransactionFree) then
    FTransactionFree(Sender);
end;

{ Read the record from FQSelect.Current into the record buffer
  Then write the buffer to in memory cache }
procedure TIBCustomDataSet.FetchCurrentRecordToBuffer(Qry: TIBSQL;
  RecordNumber: Integer; Buffer: PChar);
var
  p: PRecordData;
  i, j: Integer;
  LocalData: Pointer;
  LocalDate, LocalDouble: Double;
  LocalInt: Integer;
  LocalInt64: Int64;
  LocalCurrency: Currency;
  FieldsLoaded: Integer;
begin
  {$IFDEF HEAP_STRING_FIELD}
  FinalizeRecordBuffer(Buffer);
  {$ENDIF}

  p := PRecordData(Buffer);
  { Make sure blob cache is empty }
  if RecordNumber > -1 then
    FillChar(Buffer[FBlobCacheOffset], BlobFieldCount * SizeOf(TIBBlobStream), 0);

  { Get record information }
  p^.rdBookmarkFlag := bfCurrent;
  p^.rdFieldCount := Qry.Current.Count;
  p^.rdRecordNumber := RecordNumber;
  p^.rdUpdateStatus := usUnmodified;
  p^.rdCachedUpdateStatus := cusUnmodified;
  p^.rdSavedOffset := $FFFFFFFF;
  {$IFDEF NEW_GRID}
  FPseudoRecordsOn := false;
  p^.rdRecordKind := rkRecord; { TODO : DBG3 FetchCurrentRecordToBuffer}
  p^.rdRecordGroupFiltered := True;
  {$ENDIF}

  { Load up the fields }
  FieldsLoaded := FQSelect.Current.Count;
  j := 1;
  for i := 0 to Qry.Current.Count - 1 do
  begin
    if (Qry = FQSelect) then
      j := i + 1
    else begin
      if FieldsLoaded = 0 then
        break;
      j := FQSelect.FieldIndex[Qry.Current[i].Name] + 1;
      if j < 1 then
        continue
      else
        Dec(FieldsLoaded);
    end;
    with FQSelect.Current[j - 1].Data^ do
      if aliasname = 'IBX_INTERNAL_DBKEY' then {do not localize}
      begin
        if sqllen <= 8 then
          p^.rdDBKey := PIBDBKEY(Qry.Current[i].AsPointer)^;
        continue;
      end;
    if j > 0 then with p^ do
    begin
      rdFields[j].fdDataType :=
        Qry.Current[i].Data^.sqltype and (not 1);
      rdFields[j].fdDataScale :=
        Qry.Current[i].Data^.sqlscale;
      rdFields[j].fdNullable :=
        (Qry.Current[i].Data^.sqltype and 1 = 1);
      rdFields[j].fdIsNull :=
        (rdFields[j].fdNullable and (Qry.Current[i].Data^.sqlind^ = -1));
      LocalData := Qry.Current[i].Data^.sqldata;
      case rdFields[j].fdDataType of
        SQL_TIMESTAMP:
        begin
          rdFields[j].fdDataSize := SizeOf(TDateTime);
          if RecordNumber >= 0 then
            LocalDate := TimeStampToMSecs(DateTimeToTimeStamp(Qry.Current[i].AsDateTime));
          LocalData := PChar(@LocalDate);
        end;
        SQL_TYPE_DATE:
        begin
          rdFields[j].fdDataSize := SizeOf(TDateTime);
          if RecordNumber >= 0 then
            LocalInt := DateTimeToTimeStamp(Qry.Current[i].AsDateTime).Date;
          LocalData := PChar(@LocalInt);
        end;
        SQL_TYPE_TIME:
        begin
          rdFields[j].fdDataSize := SizeOf(TDateTime);
          if RecordNumber >= 0 then
            LocalInt := DateTimeToTimeStamp(Qry.Current[i].AsDateTime).Time;
          LocalData := PChar(@LocalInt);
        end;
        SQL_SHORT, SQL_LONG:
        begin
          if (rdFields[j].fdDataScale = 0) then
          begin
            rdFields[j].fdDataSize := SizeOf(Integer);
            if RecordNumber >= 0 then
              LocalInt := Qry.Current[i].AsLong;
            LocalData := PChar(@LocalInt);
          end
          else if (rdFields[j].fdDataScale >= (-4)) then
               begin
                 rdFields[j].fdDataSize := SizeOf(Currency);
                 if RecordNumber >= 0 then
                   LocalCurrency := Qry.Current[i].AsCurrency;
                 LocalData := PChar(@LocalCurrency);
               end
               else begin
                 rdFields[j].fdDataSize := SizeOf(Double);
                 if RecordNumber >= 0 then
                   LocalDouble := Qry.Current[i].AsDouble;
                LocalData := PChar(@LocalDouble);
              end;
        end;
        SQL_INT64:
        begin
          if (rdFields[j].fdDataScale = 0) then
          begin
            rdFields[j].fdDataSize := SizeOf(Int64);
            if RecordNumber >= 0 then
              LocalInt64 := Qry.Current[i].AsInt64;
            LocalData := PChar(@LocalInt64);
          end
          else if (rdFields[j].fdDataScale >= (-4)) then
               begin
                 rdFields[j].fdDataSize := SizeOf(Currency);
                 if RecordNumber >= 0 then
                   LocalCurrency := Qry.Current[i].AsCurrency;
                   LocalData := PChar(@LocalCurrency);
               end
               else begin
                  rdFields[j].fdDataSize := SizeOf(Double);
                  if RecordNumber >= 0 then
                    LocalDouble := Qry.Current[i].AsDouble;
                  LocalData := PChar(@LocalDouble);
               end
        end;
        SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
        begin
          rdFields[j].fdDataSize := SizeOf(Double);
          if RecordNumber >= 0 then
            LocalDouble := Qry.Current[i].AsDouble;
          LocalData := PChar(@LocalDouble);
        end;
        SQL_VARYING:
        begin
          rdFields[j].fdDataSize := Qry.Current[i].Data^.sqllen;
          rdFields[j].fdDataLength := isc_vax_integer(Qry.Current[i].Data^.sqldata, 2);
          if RecordNumber >= 0 then
          begin
            if (rdFields[j].fdDataLength = 0) then
              LocalData := nil
            else
              LocalData := @Qry.Current[i].Data^.sqldata[2];
          end;
        end;
        else { SQL_TEXT, SQL_BLOB, SQL_ARRAY, SQL_QUAD }
        begin
          rdFields[j].fdDataSize := Qry.Current[i].Data^.sqllen;
          if (rdFields[j].fdDataType = SQL_TEXT) then
            rdFields[j].fdDataLength := rdFields[j].fdDataSize;
        end;
      end;
      if RecordNumber < 0 then
      begin
        {$IFDEF HEAP_STRING_FIELD}
        rdFields[j].fdIsNull := True;
        if IsHeapField(rdFields[j]) then
        begin
          rdFields[j].fdDataOfs := 0;
          rdFields[j].fdDataLength := 0;
        end else begin
          rdFields[j].fdDataOfs := FRecordSize;
          Inc(FRecordSize, rdFields[j].fdDataSize);
        end;
        {$ELSE}
        Assert(FRecordSize > 0);
        rdFields[j].fdIsNull := True;
        rdFields[j].fdDataOfs := FRecordSize;
        Inc(FRecordSize, rdFields[j].fdDataSize);
        {$ENDIF}
      end
      else begin
        if rdFields[j].fdDataType = SQL_VARYING then
        begin
          {$IFDEF HEAP_STRING_FIELD}
          if IsHeapField(rdFields[j]) then
          begin
            if LocalData <> nil then
            begin
              GetMem(Pointer(rdFields[j].fdDataOfs), rdFields[j].fdDataLength);
              Move(LocalData^, Pointer(rdFields[j].fdDataOfs)^, rdFields[j].fdDataLength);
            end else
              rdFields[j].fdDataOfs := 0;
          end else
          {$ENDIF}
          if LocalData <> nil then
            Move(LocalData^, Buffer[rdFields[j].fdDataOfs], rdFields[j].fdDataLength)
        end
        else
          Move(LocalData^, Buffer[rdFields[j].fdDataOfs], rdFields[j].fdDataSize)
      end;
    end;
  end;
  WriteRecordCache(RecordNumber, PChar(p));

  if UniDirectional then
    ClearBlobCache;
end;

function TIBCustomDataSet.GetActiveBuf: PChar;
begin
  //!!!
  if FPeekBuffer <> nil then
    Result := FPeekBuffer
  else
  //!!!
    case State of
      dsBrowse:
        if IsEmpty then
          result := nil
        else
          result := ActiveBuffer;
      dsEdit, dsInsert:
        result := ActiveBuffer;
      dsCalcFields:
        result := CalcBuffer;
      dsFilter:
        result := FFilterBuffer;
      dsNewValue:
        result := ActiveBuffer;
      dsOldValue:
        if (PRecordData(ActiveBuffer)^.rdSavedOffset <> $FFFFFFFF) then
        begin
          ReadCache(FOldBufferCache, PRecordData(ActiveBuffer)^.rdSavedOffset, FILE_BEGIN,
                       FTempBuffer);
          result := FTempBuffer;
        end
        else
          if (PRecordData(ActiveBuffer)^.rdRecordNumber =
            PRecordData(FOldBuffer)^.rdRecordNumber) then
            result := FOldBuffer
          else
            result := ActiveBuffer;
    else if not FOpen then
      result := nil
    else
      result := ActiveBuffer;
    end;
end;

function TIBCustomDataSet.CachedUpdateStatus: TCachedUpdateStatus;
begin
  if Active and (not IsEmpty) then
    result := PRecordData(GetActiveBuf)^.rdCachedUpdateStatus
  else
    result := cusUnmodified;
end;

{$IFDEF NEW_GRID}
procedure TIBCustomDataSet.SetPseudoRecordsOn(const Value: Boolean);
begin
  FPseudoRecordsOn := Value;
end;

function TIBCustomDataSet.RecordKind: TRecordKind;
begin
  if Active and (not IsEmpty) then
    result := PRecordData(GetActiveBuf)^.rdRecordKind
  else
    result := rkRecord;
end;
procedure TIBCustomDataSet.SetFinding(Value: Boolean);
begin
  FFinding := Value;
end;

function TIBCustomDataSet.RecordGroupFilterAccept: Boolean;
begin
  if Active and (not IsEmpty) then
    result := PRecordData(GetActiveBuf)^.rdRecordGroupFiltered
  else
    result := false;
end;

function TIBCustomDataSet._RecordNumber: Long;//dbg/
begin
  if Active and (not IsEmpty) then
    result := PRecordData(GetActiveBuf)^.rdRecordNumber
  else
    result := -1;                                 
end;
function TIBCustomDataSet.Dbg1(Buffer: PChar=nil): string;//dbg/
var z: string;
begin
  result:='';
  if Active and (not IsEmpty) then begin
    if Buffer=nil then Buffer:=GetActiveBuf;
    case PRecordData(Buffer)^.rdRecordKind of
     rkRecord:  z:='rkRecord';
     rkGroup:   z:='rkGroup';
     rkHeader:  z:='rkHeader';
     rkHiddenRecord: z:='rkHiddenRecord';
    end;
    result:= IntToStr(PRecordData(Buffer)^.rdRecordNumber)+' '+z;
  end;
end;
procedure TIBCustomDataSet._setPseudoRecordsOn(V:Boolean);
begin
  FPseudoRecordsOn := V;
end;
{$ENDIF}

function TIBCustomDataSet.GetDatabase: TIBDatabase;
begin
  result := FBase.Database;
end;

function TIBCustomDataSet.GetDBHandle: PISC_DB_HANDLE;
begin
  result := FBase.DBHandle;
end;

function TIBCustomDataSet.GetDeleteSQL: TStrings;
begin
  result := FQDelete.SQL;
end;

function TIBCustomDataSet.GetInsertSQL: TStrings;
begin
  result := FQInsert.SQL;
end;

function TIBCustomDataSet.GetSQLParams: TIBXSQLDA;
begin
  if not FInternalPrepared then
    InternalPrepare;
  result := FQSelect.Params;
end;

function TIBCustomDataSet.GetRefreshSQL: TStrings;
begin
  result := FQRefresh.SQL;
end;

function TIBCustomDataSet.GetSelectSQL: TStrings;
begin
  result := FQSelect.SQL;
end;

function TIBCustomDataSet.GetStatementType: TIBSQLTypes;
begin
  result := FQSelect.SQLType;
end;

function TIBCustomDataSet.GetModifySQL: TStrings;
begin
  result := FQModify.SQL;
end;

function TIBCustomDataSet.GetTransaction: TIBTransaction;
begin
  result := FBase.Transaction;
end;

function TIBCustomDataSet.GetTRHandle: PISC_TR_HANDLE;
begin
  result := FBase.TRHandle;
end;

procedure TIBCustomDataSet.InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer);
//!!!
var
  DidActivate: Boolean;
//!!!
begin
  //!!!
  if not FDataTransfer then
  begin
  //!!!
  if (Assigned(FUpdateObject) and (FUpdateObject.GetSQL(ukDelete).Text <> '')) then
    FUpdateObject.Apply(ukDelete)
  else
  begin
    //!!!
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      try
        if Assigned(FBeforeInternalDeleteRecord) then
          FBeforeInternalDeleteRecord(Self);
    //!!!
        SetInternalSQLParams(FQDelete, Buff);
        FQDelete.ExecQuery;
        //FRowsAffected := FQDelete.RowsAffected;
        FLastQuery := lqDelete;
    //!!!
        if Assigned(FAfterInternalDeleteRecord) then
          FAfterInternalDeleteRecord(Self);
      except
        if DidActivate and AllowCloseTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      if DidActivate and AllowCloseTransaction then
        Transaction.Commit;
    end;
    //!!!
  end;
  //!!!
  end;
  //!!!
  with PRecordData(Buff)^ do
  begin
    rdUpdateStatus := usDeleted;
    rdCachedUpdateStatus := cusUnmodified;
  end;
  WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
  //!!!b
  {$IFDEF NEW_GRID}
  ClearGroupSort;
  {$ELSE}
  FSortField := '';
  {$ENDIF}
  //!!!e
end;

function TIBCustomDataSet.InternalLocate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  fl: TList;
  CurBookmark: string;
  fld : Variant;
  val : Array of Variant;
  i, fld_cnt: Integer;
  fld_str : String;
  T: DWORD;
  F: TField;
begin
  result := False;
  F := FindField(KeyFields);
  if (F is TIntegerField) and (VarType(KeyValues) = varInteger) then
  begin
    i := KeyValues;

    while not EOF do
    begin
      if F.AsInteger = i then
      begin
        Result := True;
        break;
      end;
      Next;
    end;

    {
    try
      for j := k to FRecordCount - 1 do
      begin
        FPeekBuffer := FBufferCache + j * _RecordBufferSize;
        if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
          continue;

        if Filtered and Assigned(OnFilterRecord) then
        begin
          Accept := True;
          OnFilterRecord(Self, Accept);
          if not Accept then
            continue;
        end;

        if F.AsInteger = i then
        begin
          Result := True;
          FPeekBuffer := nil;
          GotoBookmark(@j);
          exit;
        end;
      end;
    finally
      FPeekBuffer := nil;
    end;
    }
  end else
  begin
    fl := TList.Create;
    try
      GetFieldList(fl, KeyFields);
      fld_cnt := fl.Count;
      if fl.Count = 0 then
        Exit;

      CurBookmark := Bookmark;
      SetLength(val, fld_cnt);
      if not Eof then
        for i := 0 to fld_cnt - 1 do
        begin
          if VarIsArray(KeyValues) then
            val[i] := KeyValues[i]
          else
            val[i] := KeyValues;
          if (TField(fl[i]).DataType = ftString) and
             not VarIsNull(val[i]) then
          begin
            if (loCaseInsensitive in Options) then
              val[i] := AnsiUpperCase(val[i]);
          end;
        end;
      T := GetTickCount;
      while ((not result) and (not Eof)) do
      begin
        i := 0;
        result := True;
        while (result and (i < fld_cnt)) do
        begin
          fld := TField(fl[i]).Value;
          if VarIsNull(fld) then
            result := result and VarIsNull(val[i])
          else
          begin
            // We know the Field is not null so if the passed value is null we are
            //   done with this record
            result := result and not VarIsNull(val[i]);
            if result then
            begin
              try
                fld := VarAsType(fld, VarType(val[i]));
              except
                on E: EVariantError do result := False;
              end;
              if TField(fl[i]).DataType = ftString then
              begin
                fld_str := TField(fl[i]).AsString;
                if (loCaseInsensitive in Options) then
                  fld_str := AnsiUpperCase(fld_str);
                if (loPartialKey in Options) then
                  result := result and (AnsiPos(val[i], fld_str) = 1)
                else
                  result := result and (fld_str = val[i]);
              end
              else
                if TField(fl[i]).DataType in [ftDate, ftTime, ftDateTime] then
                  Result := Result and (DateTimeToStr(val[i]) = DateTimeToStr(fld))
                else
                  result := result and (val[i] = fld);
            end;
          end;
          Inc(i);
        end;
        if not result then
        begin
          if GetTickCount - T > MAX_LOCATE_WAIT then
          begin
            break;
          end;

          Next;
        end;
      end;
      if not result then
        Bookmark := CurBookmark
      else
        CursorPosChanged;
    finally
      fl.Free;
      val := nil;
    end;
  end;
end;

procedure TIBCustomDataSet.InternalPostRecord(Qry: TIBSQL; Buff: Pointer);
var
  i, j, k: Integer;
  pbd: PBlobDataArray;
  //!!!
  DidActivate: Boolean;
  //!!!
begin
  {
  pbd := PBlobDataArray(PChar(Buff) + FBlobCacheOffset);
  j := 0;
  for i := 0 to FieldCount - 1 do
    if Fields[i].IsBlob then
    begin
      k := FMappedFieldPosition[Fields[i].FieldNo -1];
      if pbd^[j] <> nil then
      begin
        pbd^[j].Finalize;
        PISC_QUAD(
          PChar(Buff) + PRecordData(Buff)^.rdFields[k].fdDataOfs)^ :=
          pbd^[j].BlobID;
        PRecordData(Buff)^.rdFields[k].fdIsNull := pbd^[j].Size = 0;
      end;
      Inc(j);
    end;
  }
  if Assigned(FUpdateObject) then
  begin
    if (Qry = FQDelete) then
      FUpdateObject.Apply(ukDelete)
    else
      if (Qry = FQInsert) then
        FUpdateObject.Apply(ukInsert)
      else
        FUpdateObject.Apply(ukModify);
  end
  else
  begin
    //!!!
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      try
        if Assigned(FBeforeInternalPostRecord) then
          FBeforeInternalPostRecord(Self);

        pbd := PBlobDataArray(PChar(Buff) + FBlobCacheOffset);
        j := 0;
        for i := 0 to FieldCount - 1 do
          if Fields[i].IsBlob then
          begin
            k := FMappedFieldPosition[Fields[i].FieldNo -1];
            if pbd^[j] <> nil then
            begin
              pbd^[j].Finalize;
              PISC_QUAD(
                PChar(Buff) + PRecordData(Buff)^.rdFields[k].fdDataOfs)^ :=
                pbd^[j].BlobID;
              PRecordData(Buff)^.rdFields[k].fdIsNull := pbd^[j].Size = 0;
            end;
            Inc(j);
          end;

        CheckRequiredFields;

    //!!!
        SetInternalSQLParams(Qry, Buff);
        Qry.ExecQuery;
        //FRowsAffected := Qry.RowsAffected;
        if Qry = FQInsert then FLastQuery := lqInsert
          else if Qry = FQModify then FLastQuery := lqUpdate
            else FLastQuery := lqNone;
    //!!!
        if Assigned(FAfterInternalPostRecord) then
          FAfterInternalPostRecord(Self);
      except
        if DidActivate and AllowCloseTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      if DidActivate and AllowCloseTransaction then
        Transaction.Commit;
    end;
    //!!!
  end;
  PRecordData(Buff)^.rdUpdateStatus := usUnmodified;
  PRecordData(Buff)^.rdCachedUpdateStatus := cusUnmodified;
  SetModified(False);
  WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
  if (FForcedRefresh or FNeedsRefresh) and CanRefresh then
    InternalRefreshRow;
  //!!!b
  {$IFDEF NEW_GRID}
  ClearGroupSort;
  {$ELSE}
  FSortField := '';
  {$ENDIF}
  //!!!e
end;

procedure TIBCustomDataSet.InternalRefreshRow;
var
  Buff: PChar;
  ofs: DWORD;
  Qry: TIBSQL;
  //!!!
  pbd: PBlobDataArray;
  i, J, K: Integer;
  FreeStream: Boolean;
  //!!!
begin
  //!!!
  //Qry := nil;
  //!!!
  Buff := GetActiveBuf;
  if CanRefresh then
  begin
    if Buff <> nil then
    begin
      if (Assigned(FUpdateObject) and (FUpdateObject.RefreshSQL.Text <> '')) then
      begin
        Qry := TIBSQL.Create(self);
        Qry.Database := Database;
        //!!!
        //Qry.Transaction := Transaction;
        Qry.Transaction := ReadTransaction;
        //!!!
        Qry.GoToFirstRecordOnExecute := False;
        Qry.SQL.Text := FUpdateObject.RefreshSQL.Text;
      //!!!
      end else if {(State in dsEditModes) and} (ReadTransaction <> Transaction) and (Transaction.InTransaction) then
      begin
        Qry := TIBSQL.Create(self);
        Qry.Database := Database;
        Qry.Transaction := Transaction;
        Qry.GoToFirstRecordOnExecute := False;
        Qry.SQL.Text := FQRefresh.SQL.Text;
      end
      //!!!
      else
        Qry := FQRefresh;
      SetInternalSQLParams(Qry, Buff);

      //
      for J := 0 to FQSelect.Params.Count - 1 do
      begin
        for K := 0 to Qry.Params.Count - 1 do
        begin
          if AnsiCompareText(FQSelect.Params[J].Name, Qry.Params[K].Name) = 0 then
          begin
            Qry.Params[K].Assign(FQSelect.Params[J]);
            break;
          end;
        end;
      end;

      Qry.ExecQuery;
      try
        if (Qry.SQLType = SQLExecProcedure) or
           (Qry.Next <> nil) then
        begin
          ofs := PRecordData(Buff)^.rdSavedOffset;

          //!!!
          if PRecordData(Buff)^.rdRecordNumber > -1 then
          begin
            pbd := PBlobDataArray(Buff + FBlobCacheOffset);
            for i := 0 to BlobFieldCount - 1 do
            begin
              FreeStream := True;

              if (FOldBuffer <> nil) and
                (PRecordData(FOldBuffer)^.rdRecordNumber > -1) then
              begin
                if pbd^[i] = PBlobDataArray(FOldBuffer + FBlobCacheOffset)^[i] then
                  FreeStream := False;
              end;

              if FreeStream then
              begin
                FBlobStreamList.Remove(pbd^[i]);
                pbd^[i].Free;
                pbd^[i] := nil;
              end;
            end;
          end;
          //!!!

          FetchCurrentRecordToBuffer(Qry,
                                     PRecordData(Buff)^.rdRecordNumber,
                                     Buff);
          if FCachedUpdates and (ofs <> $FFFFFFFF) then
          begin
            PRecordData(Buff)^.rdSavedOffset := ofs;
            WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
            SaveOldBuffer(Buff);
          end;
        end

        //!!!
        // если запись удалена на другой транзакции, то при рефреше
        // уберем ее из нашего датасета.
        // жалко что для этого приходится вызывать Делете
        // там пройдет запрос на сервер, который ничего не сделает
        // (записи уже нет), но все равно сервер загрузит
        // обратите внимание! что мы не будем удалять запись, которую
        // только что добавили постом
        else if
          (Qry.SQLType = SQLSelect)
          and (Qry.Next = nil)
          and ((not CachedUpdates) or (PRecordData(Buff)^.rdCachedUpdateStatus in [cusModified, cusUnmodified]))
          and ((not FSavedFlag) or (FSavedRN <> PRecordData(Buff)^.rdRecordNumber)) then
        begin
          FDataTransfer := True;
          try
            { TODO : надо изымать из буфера, а не так брутально удалять }
            Delete;
          finally
            FDataTransfer := False;
          end;
        end;
        //!!!

      finally
        Qry.Close;

        //!!!
        if Qry <> FQRefresh then
          Qry.Free;
        //!!!
      end;
    end;
    //!!!
    //if Qry <> FQRefresh then
      //Qry.Free;
    //!!!
  end
  else
    IBError(ibxeCannotRefresh, [nil]);
end;

procedure TIBCustomDataSet.InternalRevertRecord(RecordNumber: Integer);
var
  NewBuffer, OldBuffer: PRecordData;

begin
  NewBuffer := nil;
  OldBuffer := nil;
  NewBuffer := PRecordData(AllocRecordBuffer);
  OldBuffer := PRecordData(AllocRecordBuffer);
  try
    ReadRecordCache(RecordNumber, PChar(NewBuffer), False);
    ReadRecordCache(RecordNumber, PChar(OldBuffer), True);
    case NewBuffer^.rdCachedUpdateStatus of
      cusInserted:
      begin
        NewBuffer^.rdCachedUpdateStatus := cusUninserted;
        Inc(FDeletedRecords);
      end;
      cusModified,
      cusDeleted:
      begin
        if (NewBuffer^.rdCachedUpdateStatus = cusDeleted) then
          Dec(FDeletedRecords);
        CopyRecordBuffer(OldBuffer, NewBuffer);
      end;
    end;

    if State in dsEditModes then
      Cancel;

    WriteRecordCache(RecordNumber, PChar(NewBuffer));

    //!!!
    {if (NewBuffer^.rdCachedUpdateStatus = cusUninserted ) then
      ReSync([]);}
  finally
    FreeRecordBuffer(PChar(NewBuffer));
    FreeRecordBuffer(PChar(OldBuffer));
  end;
end;

{ A visible record is one that is not truly deleted,
  and it is also listed in the FUpdateRecordTypes set }

function TIBCustomDataSet.IsVisible(Buffer: PChar): Boolean;
begin
  result := True;
  if not (State = dsOldValue) then
    result :=
      (PRecordData(Buffer)^.rdCachedUpdateStatus in FUpdateRecordTypes) and
      (not ((PRecordData(Buffer)^.rdCachedUpdateStatus = cusUnmodified) and
        (PRecordData(Buffer)^.rdUpdateStatus = usDeleted)));
  {$IFDEF NEW_GRID}
  //не надо это/удалить не забыть/  result := result and FPseudoRecordsOn;
  {$ENDIF}
end;


function TIBCustomDataSet.LocateNext(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  b : TBookmark;
begin
  DisableControls;
  b := GetBookmark;
  try
    Next;
    Result := InternalLocate(KeyFields, KeyValues, Options);
    if not Result then
      GotoBookmark(b);  // Get back on the record we started with on failure
  finally
    FreeBookmark(b);
    EnableControls;
  end;
end;

procedure TIBCustomDataSet.InternalPrepare;
//var
  //!!!
  //DidActivate: Boolean;
  //ReadDidActivate: Boolean;
  //!!!

  procedure PrepareSQL(iSQL : TIBSQL; SQLText : TStrings; lm : TLiveMode);
  (*
  //!!!
  var
    OldTransaction: TIBTransaction;
  //!!!
  *)
  begin
    try
      if Trim(SQLText.Text) <> '' then
      begin
        (*
        //!!!
        OldTransaction := iSQL.Transaction;
        try
          iSQL.Transaction := ReadTransaction;
        //!!!
          if not iSQL.Prepared then
            iSQL.Prepare;
        //!!!
        finally
          iSQL.Transaction := OldTransaction;
        end;
        //!!!
        *)
        Include(FLiveMode, lm);
      end;
    except
     on E: Exception do
       if not (E is EIBInterbaseRoleError) then
         Raise;
    end;
  end;

begin
  if FInternalPrepared then
    Exit;
  if Trim(FQSelect.SQL.Text) = '' then
    IBError(ibxeEmptySQLStatement, []);
  //!!!
  //DidActivate := False;
  //ReadDidActivate := False;
  //!!!
  try
    ActivateConnection;
    //!!!
    //DidActivate := ActivateTransaction;
    //FBase.CheckDatabase;
    //FBase.CheckTransaction;
    //!!!
    {ReadDidActivate := }ActivateReadTransaction;
    //FReadBase.CheckDatabase;
    //FReadBase.CheckTransaction;
    //!!!
    if Trim(FQSelect.SQL.Text) <> '' then
    begin
      if not FQSelect.Prepared then
      begin
        FQSelect.ParamCheck := ParamCheck;
        FQSelect.Prepare;
      end;
      FLiveMode := [];
      PrepareSQL(FQDelete, FQDelete.SQL, lmDelete);
      PrepareSQL(FQInsert, FQInsert.SQL, lmInsert);
      PrepareSQL(FQModify, FQModify.SQL, lmModify);
      PrepareSQL(FQRefresh, FQRefresh.SQL, lmRefresh);

      FInternalPrepared := True;
      InternalInitFieldDefs;
    end
    else
      IBError(ibxeEmptyQuery, [nil]);
  finally
    // мы открываем транзакцию для чтения и уже не закрываем ее!

    //!!!
    //if DidActivate then
      //DeactivateTransaction;
    //if ReadDidActivate then
      //DeactivateReadTransaction;
    //!!!
  end;
end;

procedure TIBCustomDataSet.RecordModified(Value: Boolean);
begin
  SetModified(Value);
end;

procedure TIBCustomDataSet.RevertRecord;
var
  Buff: PRecordData;
begin
  if FCachedUpdates and FUpdatesPending then
  begin
    Buff := PRecordData(GetActiveBuf);
    InternalRevertRecord(Buff^.rdRecordNumber);
    ReadRecordCache(Buff^.rdRecordNumber, PChar(Buff), False);
    DataEvent(deRecordChange, 0);
  end;
end;

procedure TIBCustomDataSet.SaveOldBuffer(Buffer: PChar);
var
  OldBuffer: Pointer;
  procedure CopyOldBuffer;
  begin
    CopyRecordBuffer(Buffer, OldBuffer);
    if BlobFieldCount > 0 then
      FillChar(PChar(OldBuffer)[FBlobCacheOffset], BlobFieldCount * SizeOf(TIBBlobStream),
               0);
  end;

begin
  if (Buffer <> nil) and (PRecordData(Buffer)^.rdRecordNumber >= 0) then
  begin
    OldBuffer := AllocRecordBuffer;
    try
      if (PRecordData(Buffer)^.rdSavedOffset = $FFFFFFFF) then
      begin
        PRecordData(Buffer)^.rdSavedOffset := AdjustPosition(FOldBufferCache, 0,
                                                             FILE_END);
        CopyOldBuffer;
          WriteCache(FOldBufferCache, 0, FILE_CURRENT, OldBuffer);
          WriteCache(FBufferCache, PRecordData(Buffer)^.rdRecordNumber * FRecordBufferSize,
                     FILE_BEGIN, Buffer);
      end
      else begin
        CopyOldBuffer;
        WriteCache(FOldBufferCache, PRecordData(Buffer)^.rdSavedOffset, FILE_BEGIN,
                   OldBuffer);
      end;
    finally
      FreeRecordBuffer(PChar(OldBuffer));
    end;
  end;
end;

procedure TIBCustomDataSet.SetBufferChunks(Value: Integer);
begin
  if not (csLoading in ComponentState) then
  begin
    if (Value <= 0) then
      FBufferChunks := BufferCacheSize
    else
      FBufferChunks := Value;
  end;    
end;

procedure TIBCustomDataSet.SetDatabase(Value: TIBDatabase);
begin
  if (FBase.Database <> Value) then
  begin
    CheckDatasetClosed;
    FBase.Database := Value;
    //!!!
    FReadBase.Database := Value;
    //!!!
    FQDelete.Database := Value;
    FQInsert.Database := Value;
    FQRefresh.Database := Value;
    FQSelect.Database := Value;
    FQModify.Database := Value;
  end;
end;

procedure TIBCustomDataSet.SetDeleteSQL(Value: TStrings);
begin
  if FQDelete.SQL.Text <> Value.Text then
  begin
    Disconnect;
    FQDelete.SQL.Assign(Value);
  end;
end;

procedure TIBCustomDataSet.SetInsertSQL(Value: TStrings);
begin
  if FQInsert.SQL.Text <> Value.Text then
  begin
    Disconnect;
    FQInsert.SQL.Assign(Value);
  end;
end;

procedure TIBCustomDataSet.SetInternalSQLParams(Qry: TIBSQL; Buffer: Pointer);
var
  i, j: Integer;
  cr, data: PChar;
  fn, st: string;
  OldBuffer: Pointer;
  ts: TTimeStamp;
begin
  if (Buffer = nil) then
    IBError(ibxeBufferNotSet, [nil]);
  if (not FInternalPrepared) then
    InternalPrepare;
  OldBuffer := nil;
  try
    for i := 0 to Qry.Params.Count - 1 do
    begin
      fn := Qry.Params[i].Name;
      if (Pos('OLD_', fn) = 1) then {mbcs ok}
      begin
        fn := Copy(fn, 5, Length(fn));
        if not Assigned(OldBuffer) then
        begin
          OldBuffer := AllocRecordBuffer;
          ReadRecordCache(PRecordData(Buffer)^.rdRecordNumber, OldBuffer, True);
        end;
        cr := OldBuffer;
      end
      else if (Pos('NEW_', fn) = 1) then {mbcs ok}
           begin
             fn := Copy(fn, 5, Length(fn));
             cr := Buffer;
            end
            else
             cr := Buffer;
      j := FQSelect.FieldIndex[fn] + 1;
      if (j > 0) then
        with PRecordData(cr)^ do
        begin
          if Qry.Params[i].name = 'IBX_INTERNAL_DBKEY' then {do not localize}
          begin
            PIBDBKey(Qry.Params[i].AsPointer)^ := rdDBKey;
            continue;
          end;
          if rdFields[j].fdIsNull then
            Qry.Params[i].IsNull := True
          else begin
            Qry.Params[i].IsNull := False;
            data := cr + rdFields[j].fdDataOfs;
            case rdFields[j].fdDataType of
              SQL_TEXT, SQL_VARYING:
              begin
                {$IFDEF HEAP_STRING_FIELD}
                if IsHeapField(rdFields[j]) then
                begin
                  SetString(st, PChar(rdFields[j].fdDataOfs), rdFields[j].fdDataLength);
{!!! Было Qry.Params[i].AsString := st}
//                  Qry.Params[i].AsString := Copy(st, 1, Qry.Params[i].AsXSQLVAR.sqllen);
{!!!}
                  Qry.Params[i].AsString := st;
                end else begin
                {$ENDIF}
                SetString(st, data, rdFields[j].fdDataLength);
{!!! }
//                Qry.Params[i].AsString := Copy(st, 1, Qry.Params[i].AsXSQLVAR.sqllen);
{!!!}
                 Qry.Params[i].AsString := st;
                {$IFDEF HEAP_STRING_FIELD}
                end;
                {$ENDIF}
              end;
            SQL_FLOAT, SQL_DOUBLE, SQL_D_FLOAT:
              Qry.Params[i].AsDouble := PDouble(data)^;
            SQL_SHORT, SQL_LONG:
            begin
              if rdFields[j].fdDataScale = 0 then
                Qry.Params[i].AsLong := PLong(data)^
              else if rdFields[j].fdDataScale >= (-4) then
                Qry.Params[i].AsCurrency := PCurrency(data)^
              else
                Qry.Params[i].AsDouble := PDouble(data)^;
            end;
            SQL_INT64:
            begin
              if rdFields[j].fdDataScale = 0 then
                Qry.Params[i].AsInt64 := PInt64(data)^
              else if rdFields[j].fdDataScale >= (-4) then
                Qry.Params[i].AsCurrency := PCurrency(data)^
              else
                Qry.Params[i].AsDouble := PDouble(data)^;
            end;
            //!!!
            //SQL_BLOB, SQL_ARRAY, SQL_QUAD:
            //  Qry.Params[i].AsQuad := PISC_QUAD(data)^;
            {SQL_BLOB,} SQL_ARRAY, SQL_QUAD:
              Qry.Params[i].AsQuad := PISC_QUAD(data)^;
            SQL_BLOB:
              if Transaction = ReadTransaction then
                Qry.Params[i].AsQuad := PISC_QUAD(data)^
              else
              begin
                { TODO : перекачиваем блоб через локальный комп. это плохо! }
                Qry.Params[i].AsString := FieldByName(fn).AsString;
              end;
            //!!!
            SQL_TYPE_DATE:
            begin
              ts.Date := PInt(data)^;
              ts.Time := 0;
              Qry.Params[i].AsDate :=
                TimeStampToDateTime(ts);
            end;
            SQL_TYPE_TIME:
            begin
              ts.Date := 1;
              ts.Time := PInt(data)^;
              Qry.Params[i].AsTime :=
                TimeStampToDateTime(ts);
            end;
            SQL_TIMESTAMP:
              Qry.Params[i].AsDateTime :=
                TimeStampToDateTime(
                  MSecsToTimeStamp(PDouble(data)^));
          end;
        end;
      end else
      //!!!b
        Qry.Params[i].Clear;
      //!!!e
    end;
  finally
    if (OldBuffer <> nil) then
      FreeRecordBuffer(PChar(OldBuffer));
  end;
end;

procedure TIBCustomDataSet.SetRefreshSQL(Value: TStrings);
begin
  if FQRefresh.SQL.Text <> Value.Text then
  begin
    Disconnect;
    FQRefresh.SQL.Assign(Value);
  end;
end;

procedure TIBCustomDataSet.SetSelectSQL(Value: TStrings);
begin
  if FQSelect.SQL.Text <> Value.Text then
  begin
    Disconnect;
    FQSelect.SQL.Assign(Value);
  end;
end;

procedure TIBCustomDataSet.SetModifySQL(Value: TStrings);
begin
  if FQModify.SQL.Text <> Value.Text then
  begin
    Disconnect;
    FQModify.SQL.Assign(Value);
  end;
end;

procedure TIBCustomDataSet.SetTransaction(Value: TIBTransaction);
begin
  if (FBase.Transaction <> Value) then
  begin
    CheckDatasetClosed;
    if FInternalPrepared then
      InternalUnprepare;
    FBase.Transaction := Value;
    FQDelete.Transaction := Value;
    FQInsert.Transaction := Value;
    //FQRefresh.Transaction := Value;
    //FQSelect.Transaction := Value;
    FQModify.Transaction := Value;

    if (ReadTransaction = nil) or (not FReadTransactionSet) then
      ReadTransaction := Value;
  end;
end;

procedure TIBCustomDataSet.SetFiltered(Value: Boolean);
var
  OldRecNo: Integer;
begin
  if csDestroying in ComponentState then
  begin
    inherited SetFiltered(Value);
    exit;
  end;

  {if Value <> Filtered then
  begin}
    if Active then
      OldRecNo := RecNo
    else
      OldRecNo := -1;
    FSavedRecordCount := -1;
    inherited SetFiltered(Value);
    FAggregatesObsolete := True;
    if Active and (FBufferCache <> nil) then // нет смысла делать Resync если FBufferCache=nil, т.е.
                                             // после операций удаления, вставки или изменения записи
    begin
      {$IFDEF NEW_GRID}
      if (FGroupSortFields <> nil)
        and (FGroupSortFields.Count > 0) then
          Group
      else
          Resync([]);
      {$ELSE}
      Resync([]);
      {$ENDIF}
      if OldRecNo <> RecNo then
      begin
        { TODO :
по хорошему тут не рекордномер надо восстанавливать, а позиционировать именно
на ту запись где был курсор. либо по ключу, либо по ее внутреннему номеру. }
        RecNo := OldRecNo;
      end;
    end;

    //!!!!b
    DataEvent(deLayoutChange, 0);
    //!!!!e
  {end;}
end;

procedure TIBCustomDataSet.SetUniDirectional(Value: Boolean);
begin
  CheckDatasetClosed;
  FUniDirectional := Value;
end;

procedure TIBCustomDataSet.SetUpdateRecordTypes(Value: TIBUpdateRecordTypes);
begin
  FUpdateRecordTypes := Value;
  if Active then
    First;
end;

procedure TIBCustomDataSet.RefreshParams;
var
  DataSet: TDataSet;

  function NeedsRefreshing : Boolean;
  var
    i : Integer;
    cur_param: TIBXSQLVAR;
    cur_field: TField;

  begin
    Result := true;
    i := 0;
    while (i < SQLParams.Count) and (Result) do
    begin
      cur_field := DataSource.DataSet.FindField(SQLParams[i].Name);
      cur_param := SQLParams[i];
      if (cur_field <> nil) then
      begin
        if (cur_field.IsNull) then
          Result := Result and cur_param.IsNull
        else
        case cur_field.DataType of
          ftString:
            Result := Result and (cur_param.AsString = cur_field.AsString);
          ftBoolean, ftSmallint, ftWord:
            Result := Result and (cur_param.AsShort = cur_field.AsInteger);
          ftInteger:
            Result := Result and (cur_param.AsLong = cur_field.AsInteger);
          ftLargeInt:
            Result := Result and (cur_param.AsInt64 = TLargeIntField(cur_field).AsLargeInt);
          ftFloat, ftCurrency:
            Result := Result and (cur_param.AsDouble = cur_field.AsFloat);
          ftBCD:
            Result := Result and (cur_param.AsCurrency = cur_field.AsCurrency);
          ftDate:
            Result := Result and (cur_param.AsDate = cur_field.AsDateTime);
          ftTime:
            Result := Result and (cur_param.AsTime = cur_field.AsDateTime);
          ftDateTime:
            Result := Result and (cur_param.AsDateTime = cur_field.AsDateTime);
          else
            Result := false;
        end;
      end;
      Inc(i);
    end;
    Result := not Result;
  end;

begin
  DisableControls;
  try
    if FDataLink.DataSource <> nil then
    begin
      DataSet := FDataLink.DataSource.DataSet;
      if DataSet <> nil then
        if DataSet.Active and (DataSet.State <> dsSetKey) and NeedsRefreshing then
        begin
          Close;
          Open;
        end;
    end;
  finally
    EnableControls;
  end;
end;


procedure TIBCustomDataSet.SQLChanging(Sender: TObject);
begin
  if FOpen then
    Close;
  if FInternalPrepared then
    InternalUnPrepare;
  if Sender = FQSelect then
    FieldDefs.Clear;
end;

{ I can "undelete" uninserted records (make them "inserted" again).
  I can "undelete" cached deleted (the deletion hasn't yet occurred) }
procedure TIBCustomDataSet.Undelete;
var
  Buff: PRecordData;
begin
  CheckActive;
  Buff := PRecordData(GetActiveBuf);
  with Buff^ do
  begin
    if rdCachedUpdateStatus = cusUninserted then
    begin
      rdCachedUpdateStatus := cusInserted;
      Dec(FDeletedRecords);
    end
    else if (rdUpdateStatus = usDeleted) and
            (rdCachedUpdateStatus = cusDeleted) then
    begin
      rdCachedUpdateStatus := cusUnmodified;
      rdUpdateStatus := usUnmodified;
      Dec(FDeletedRecords);
    end;
    WriteRecordCache(rdRecordNumber, PChar(Buff));
  end;
end;

function TIBCustomDataSet.UpdateStatus: TUpdateStatus;
begin
  if Active then
    if GetActiveBuf <> nil then
      result := PRecordData(GetActiveBuf)^.rdUpdateStatus
    else
      result := usUnmodified
  else
    result := usUnmodified;
end;

function TIBCustomDataSet.IsSequenced: Boolean;
begin
  Result := Assigned( FQSelect ) and FQSelect.EOF;
end;

//!!!b

procedure TIBCustomDataSet.DoAfterDelete;
begin
  inherited;
  FSavedRecordCount := -1;
end;

procedure TIBCustomDataSet.DoAfterPost;
begin
  inherited;
  FSavedRecordCount := -1;
end;

procedure TIBCustomDataSet.DoAfterRefresh;
begin
  inherited;
  FSavedRecordCount := -1;
end;

function TIBCustomDataSet.GetRowsAffected: Integer;
begin
  Result := 0;
  if Assigned(FQSelect) and (FLastQuery = lqSelect) then
    Result := FQSelect.RowsAffected
  else if Assigned(FQRefresh) and (FLastQuery = lqRefresh) then
    Result := FQRefresh.RowsAffected
  else if Assigned(FQInsert) and (FLastQuery = lqInsert) then
    Result := FQInsert.RowsAffected
  else if Assigned(FQModify) and (FLastQuery = lqUpdate) then
    Result := FQModify.RowsAffected
  else if Assigned(FQDelete) and (FLastQuery = lqDelete) then
    Result := FQDelete.RowsAffected;
end;

//!!!e

function TIBCustomDataSet.AdjustPosition(FCache: PChar; Offset: DWORD;
                                        Origin: Integer): Integer;

  function CalcCacheSize(const CS: Integer): Integer;
  begin
    if CS < 2 * 1024 * 1024 then
      Result := CS * 2
    else
      Result := CS + FRecordBufferSize * 100;
  end;

var
  OldCacheSize: Integer;
begin
  if (FCache = FBufferCache) then
  begin
    case Origin of
      FILE_BEGIN:    FBPos := Offset;
      FILE_CURRENT:  FBPos := FBPos + Offset;
      FILE_END:      FBPos := DWORD(FBEnd) + Offset;
    end;
    OldCacheSize := FCacheSize;
    while (FBPos >= DWORD(FCacheSize)) do
      //Inc(FCacheSize, FBufferChunkSize);
      FCacheSize := CalcCacheSize(FCacheSize);
    if FCacheSize > OldCacheSize then
      {$IFDEF HEAP_STRING_FIELD}
      IBAlloc(FBufferCache, OldCacheSize, FCacheSize);
      {$ELSE}
      IBAlloc(FBufferCache, FCacheSize, FCacheSize);
      {$ENDIF}
    result := FBPos;
  end
  else begin
    case Origin of
      FILE_BEGIN:    FOBPos := Offset;
      FILE_CURRENT:  FOBPos := FOBPos + Offset;
      FILE_END:      FOBPos := DWORD(FOBEnd) + Offset;
    end;
    OldCacheSize := FOldCacheSize;
    while (FBPos >= DWORD(FOldCacheSize)) do
      //Inc(FOldCacheSize, FBufferChunkSize);
      FOldCacheSize := CalcCacheSize(FOldCacheSize);
    if FOldCacheSize > OldCacheSize then
      {$IFDEF HEAP_STRING_FIELD}
      IBAlloc(FOldBufferCache, OldCacheSize, FOldCacheSize);
      {$ELSE}
      IBAlloc(FOldBufferCache, FOldCacheSize, FOldCacheSize);
      {$ENDIF}
    result := FOBPos;
  end;
end;

procedure TIBCustomDataSet.ReadCache(FCache: PChar; Offset: DWORD; Origin: Integer;
                                    Buffer: PChar);
var
  pCache: PChar;
  bOld: Boolean;
begin
  bOld := (FCache = FOldBufferCache);
  pCache := PChar(AdjustPosition(FCache, Offset, Origin));
  if not bOld then
    pCache := FBufferCache + Integer(pCache)
  else
    pCache := FOldBufferCache + Integer(pCache);
  {$IFDEF HEAP_STRING_FIELD}
  if pCache <> Buffer then
    FinalizeRecordBuffer(Buffer);
  {$ENDIF}
  Move(pCache^, Buffer^, DWORD(FRecordBufferSize));
  {$IFDEF HEAP_STRING_FIELD}
  InitializeRecordBuffer(pCache, Buffer);
  {$ENDIF}
  AdjustPosition(FCache, FRecordBufferSize, FILE_CURRENT);
end;
{ TODO : ^^^^ ReadRecordCache}
procedure TIBCustomDataSet.ReadRecordCache(RecordNumber: Integer; Buffer: PChar;
                                          ReadOldBuffer: Boolean);
begin
  if FUniDirectional then
    RecordNumber := RecordNumber mod UniCache;
  if (ReadOldBuffer) then
  begin
    ReadRecordCache(RecordNumber, Buffer, False);
    if FCachedUpdates and
      (PRecordData(Buffer)^.rdSavedOffset <> $FFFFFFFF) then
      ReadCache(FOldBufferCache, PRecordData(Buffer)^.rdSavedOffset, FILE_BEGIN,
                Buffer)
    else
      if ReadOldBuffer and
         (PRecordData(FOldBuffer)^.rdRecordNumber = RecordNumber) then
         CopyRecordBuffer( FOldBuffer, Buffer )
  end
  else
    ReadCache(FBufferCache, RecordNumber * FRecordBufferSize, FILE_BEGIN, Buffer);
end;

procedure TIBCustomDataSet.WriteCache(FCache: PChar; Offset: DWORD; Origin: Integer;
                                     Buffer: PChar);
var
  pCache: PChar;
  bOld: Boolean;
  dwEnd: DWORD;
begin
  bOld := (FCache = FOldBufferCache);
  pCache := PChar(AdjustPosition(FCache, Offset, Origin));
  if not bOld then
    pCache := FBufferCache + Integer(pCache)
  else
    pCache := FOldBufferCache + Integer(pCache);
  {$IFDEF HEAP_STRING_FIELD}
  if Buffer <> pCache then
    FinalizeRecordBuffer(pCache);
  {$ENDIF}
  Move(Buffer^, pCache^, FRecordBufferSize);
  {$IFDEF HEAP_STRING_FIELD}
  InitializeRecordBuffer(Buffer, pCache);
  {$ENDIF}
  dwEnd := AdjustPosition(FCache, FRecordBufferSize, FILE_CURRENT);
  if not bOld then
  begin
    if (dwEnd > FBEnd) then
      FBEnd := dwEnd;
  end
  else begin
    if (dwEnd > FOBEnd) then
      FOBEnd := dwEnd;
  end;

  //!!!
  if dsCalcFields <> State then
    FAggregatesObsolete := True;
  //!!!
end;

procedure TIBCustomDataSet.WriteRecordCache(RecordNumber: Integer; Buffer: PChar);
begin
  if RecordNumber >= 0 then
  begin
    if FUniDirectional then
      RecordNumber := RecordNumber mod UniCache;
    WriteCache(FBufferCache, RecordNumber * FRecordBufferSize, FILE_BEGIN, Buffer);
  end;
end;

function TIBCustomDataSet.AllocRecordBuffer: PChar;
begin
  result := nil;
  IBAlloc(result, FRecordBufferSize, FRecordBufferSize);
  Move(FModelBuffer^, result^, FRecordBufferSize);
end;

function TIBCustomDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
var
  pb: PBlobDataArray;
  fs: TIBBlobStream;
  Buff: PChar;
  bTr, bDB: Boolean;
begin
  Buff := GetActiveBuf;
  if Buff = nil then
  begin
    fs := TIBBlobStream.Create;
    fs.Mode := bmReadWrite;
    FBlobStreamList.Add(Pointer(fs));
    result := TIBDSBlobStream.Create(Field, fs, Mode);
    exit;
  end;
  pb := PBlobDataArray(Buff + FBlobCacheOffset);
  if pb^[Field.Offset] = nil then
  begin
    AdjustRecordOnInsert(Buff);

    pb^[Field.Offset] := TIBBlobStream.Create;
    fs := pb^[Field.Offset];
    FBlobStreamList.Add(Pointer(fs));
    fs.Mode := bmReadWrite;
    fs.Database := Database;
    //!!!
    fs.Transaction := Transaction;
    fs.ReadTransaction := ReadTransaction;
    //!!!
    fs.BlobID :=
      PISC_QUAD(@Buff[PRecordData(Buff)^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs])^;
    if (CachedUpdates) then
    begin
      bTr := not fs.ReadTransaction.InTransaction;
      bDB := not fs.Database.Connected;
      if bDB then
        fs.Database.Open;
      if bTr then
        fs.ReadTransaction.StartTransaction;
      fs.Seek(0, soFromBeginning);
      if bTr then
        fs.ReadTransaction.Commit;
      if bDB then
        fs.Database.Close;
    end;
    WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Pointer(Buff));
  end else
    fs := pb^[Field.Offset];
  result := TIBDSBlobStream.Create(Field, fs, Mode);
end;

function TIBCustomDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
const
  CMPLess = -1;
  CMPEql  =  0;
  CMPGtr  =  1;
  RetCodes: array[Boolean, Boolean] of ShortInt = ((2, CMPLess),
                                                   (CMPGtr, CMPEql));
begin
  result := RetCodes[Bookmark1 = nil, Bookmark2 = nil];

  if Result = 2 then
  begin
    if PInteger(Bookmark1)^ < PInteger(Bookmark2)^ then
      Result := CMPLess
    else
    if PInteger(Bookmark1)^ > PInteger(Bookmark2)^ then
      Result := CMPGtr
    else
      Result := CMPEql;
  end;
end;

procedure TIBCustomDataSet.DoBeforeDelete;
var
  Buff: PRecordData;
begin
  if not CanDelete then
    IBError(ibxeCannotDelete, [nil]);
  Buff := PRecordData(GetActiveBuf);
  if FCachedUpdates and
    (Buff^.rdCachedUpdateStatus in [cusUnmodified]) then
    SaveOldBuffer(PChar(Buff));
  inherited DoBeforeDelete;
end;

procedure TIBCustomDataSet.DoBeforeEdit;
var
  Buff: PRecordData;
begin
  inherited DoBeforeEdit;
  Buff := PRecordData(GetActiveBuf);
  if not(CanEdit or
    (FCachedUpdates and Assigned(FOnUpdateRecord))) then
    IBError(ibxeCannotUpdate, [nil]);
  if FCachedUpdates and (Buff^.rdCachedUpdateStatus in [cusUnmodified, cusInserted]) then
    SaveOldBuffer(PChar(Buff));
  CopyRecordBuffer(GetActiveBuf, FOldBuffer);
end;

procedure TIBCustomDataSet.DoBeforeInsert;
begin
  if not CanInsert then
    IBError(ibxeCannotInsert, [nil]);
  inherited DoBeforeInsert;
end;

procedure TIBCustomDataSet.FetchAll;
var
  CurBookmark: string;
begin
  if FQSelect.EOF or not FQSelect.Open then
    exit;
  DisableControls;
  DisableScrollEvents;
  try
    CurBookmark := Bookmark;
    Last;
    Bookmark := CurBookmark;
  finally
    EnableControls;
    EnableScrollEvents;
  end;
end;

procedure TIBCustomDataSet.FreeRecordBuffer(var Buffer: PChar);
begin
  {$IFDEF HEAP_STRING_FIELD}
  FinalizeRecordBuffer(Buffer);
  {$ENDIF}

  ReallocMem(Buffer, 0);
end;

procedure TIBCustomDataSet.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  if not IsEmpty then
    Move(PRecordData(Buffer)^.rdRecordNumber, Data^, BookmarkSize)
end;

function TIBCustomDataSet.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  result := PRecordData(Buffer)^.rdBookmarkFlag;
end;

function TIBCustomDataSet.GetCanModify: Boolean;
begin  { TODO : CanEdit _ GetCanModify v0004.txt}
  result := ([lmInsert, lmModify, lmDelete] * FLiveMode <> []) or
            (Assigned(FUpdateObject));
  {$IFDEF NEW_GRID}
  // раньше 1-ой проверкой был вызов функции ActiveBuffer, но она не срабатывавл если
  // Assigned(FBuffers){приватное поле TDataSet в DB.pas} во время вызова было ложь
  // и выдавалось Access Violation
  if result then
     result := (FRecordCount = 0) or ( (ActiveBuffer <> nil)
       and (PRecordData(ActiveBuffer)^.rdRecordKind in [rkRecord{, rkHeaderRecord}]));
  {$ENDIF}
end;
   { TODO : ^^^^ GetCurrentRecord} {}
function TIBCustomDataSet.GetCurrentRecord(Buffer: PChar): Boolean;
begin
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  begin
    UpdateCursorPos;
    ReadRecordCache(PRecordData(ActiveBuffer)^.rdRecordNumber, Buffer, False);
    result := True;
  end
  else
    result := False;
end;

function TIBCustomDataSet.GetDataSource: TDataSource;
begin
  if FDataLink = nil then
    result := nil
  else
    result := FDataLink.DataSource;
end;

function TIBCustomDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  Result := DefaultFieldClasses[FieldType];
end;

function TIBCustomDataSet.InternalGetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  Buff, Data: PChar;
  CurrentRecord: PRecordData;
begin
  result := False;
  Buff := GetActiveBuf;
  if (Buff = nil) or
     (not IsVisible(Buff)) then
    exit;
  { The intention here is to stuff the buffer with the data for the
   referenced field for the current record }
  CurrentRecord := PRecordData(Buff);
  if (Field.FieldNo < 0) then
  begin
    Inc(Buff, FRecordSize + Field.Offset);
    result := Boolean(Buff[0]);
    if result and (Buffer <> nil) then
      Move(Buff[1], Buffer^, Field.DataSize);
  end
  else
  if (FMappedFieldPosition[Field.FieldNo - 1] > 0) and
     (FMappedFieldPosition[Field.FieldNo - 1] <= CurrentRecord^.rdFieldCount) then
  begin
    result := not CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdIsNull;
    if result and (Buffer <> nil) then
      with CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]] do
      begin
        {$IFDEF HEAP_STRING_FIELD}
        if IsHeapField(CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]]) then
        begin
          Data := Pointer(CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs);
          result := Data <> nil;
          if result then
          begin
            if fdDataLength <= Field.Size then
            begin
              if (Field is TStringfield) and TStringField(Field).FixedChar then
                FillChar(Buffer^, Field.Size, ' ');
              Move(Data^, Buffer^, fdDataLength);
              if (Field is TStringfield) and TStringField(Field).FixedChar then
                PChar(Buffer)[Field.Size] := #0
              else
                PChar(Buffer)[fdDataLength] := #0;
            end
            else
              IBError(ibxeFieldSizeMismatch, [Field.FieldName]);
          end;
        end else begin
        {$ENDIF}
        Assert(CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs > 0);

        Data := Buff + CurrentRecord^.rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs;
        if (fdDataType = SQL_VARYING) or (fdDataType = SQL_TEXT) then
        begin
          if fdDataLength <= Field.Size then
          begin
            if (Field is TStringfield) and TStringField(Field).FixedChar then
              FillChar(Buffer^, Field.Size, ' ');
            Move(Data^, Buffer^, fdDataLength);
            if (Field is TStringfield) and TStringField(Field).FixedChar then
              PChar(Buffer)[Field.Size] := #0
            else
              PChar(Buffer)[fdDataLength] := #0;
            if (fdDataType = SQL_TEXT) and (not TStringField(Field).FixedChar) then
              Move(PChar(TrimRight(PChar(Buffer)))^, Buffer^, fdDataLength);
          end
          else
            IBError(ibxeFieldSizeMismatch, [Field.FieldName]);
        end
        else
          Move(Data^, Buffer^, Field.DataSize);
        {$IFDEF HEAP_STRING_FIELD}
        end;
        {$ENDIF}
      end;
  end;
end;

function TIBCustomDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  lTempCurr : System.Currency;
begin
  if (Field.DataType = ftBCD) and (Buffer <> nil) then
  begin
    Result := InternalGetFieldData(Field, @lTempCurr);
    if Result then
      CurrToBCD(lTempCurr, TBCD(Buffer^), 32, Field.Size);
  end
  else
    Result := InternalGetFieldData(Field, Buffer);
end;

function TIBCustomDataSet.GetFieldData(Field: TField; Buffer: Pointer; NativeFormat: Boolean): Boolean;
begin
  if (Field.DataType = ftBCD) and not NativeFormat then
    Result := InternalGetFieldData(Field, Buffer)
  else
    Result := inherited GetFieldData(Field, Buffer, NativeFormat);
end;

{ GetRecNo and SetRecNo both operate off of 1-based indexes as
 opposed to 0-based indexes.
 This is because we want LastRecordNumber/RecordCount = 1 }

function TIBCustomDataSet.GetRecNo: Integer;
var
  B: PRecordData;
  I: Integer;
  Accept: Boolean;
begin
  if GetActiveBuf = nil then
    result := 0
  else
    //!!!b
    begin
      if (FDeletedRecords = 0) and ((not Filtered) or (not Assigned(OnFilterRecord))) then
        result := PRecordData(GetActiveBuf)^.rdRecordNumber + 1
      else
      begin
        result := 0;
        for I := 0 to PRecordData(GetActiveBuf)^.rdRecordNumber do
        begin
          B := Addr(FBufferCache[_RecordBufferSize * I]);
          if B^.rdUpdateStatus <> usDeleted then
          begin
            if Filtered and Assigned(OnFilterRecord) then
            begin
              FPeekBuffer := PChar(B);
              try
                Accept := True;
                OnFilterRecord(Self, Accept);
                if Accept then
                  Inc(Result);
              finally
                FPeekBuffer := nil;
              end;
            end else
              Inc(Result);
          end;
        end;
      end;
    end;
    //!!!e
end;            {  --  function TIBCustomDataSet.GetRecNo  --  }

function TIBCustomDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
  SaveState: TDataSetState;
  {$IFDEF NEW_GRID}
  RecordKindOptions: TRecordKindOptions;
  //z:string;//&&&
  {$ENDIF}
begin
  Result := grOK;
  {$IFDEF NEW_GRID}
          { TODO : ^^^^ GetRecord FPseudoRecordsOn }
   if GroupSortExist then begin
     FPseudoSkip := 0;
//       if not FPseudoRecordsOn then z:='--' else z:='++';//&&&
//z:=z+' > GetRecord: O='+fm1.Q1ORDERKEY.asString+', '+Dbg1(buffer);//&&&
//       case GetMode of gmPrior: z:=z+' gmPrior'; gmNext: z:=z+' gmNext';//&&&
//        gmCurrent: z:=z+' gmPrior'; end;//&&&
//fm1.Memo1.Lines.Add(z);//&&&
   end;

  RecordKindOptions := [rkHiddenFooter];

  if not FFinding then
    RecordKindOptions := RecordKindOptions + [rkHiddenRecord];
  {  пока закомментрировано  }
  //if GroupSortExist and not PseudoRecordsOn and not FDataTransfer then
  //  RecordKindOptions := RecordKindOptions + [rkHeader, rkGroup];

  repeat
  {$ENDIF}
  if Filtered and Assigned(OnFilterRecord) then
  begin
    Accept := False;
    SaveState := SetTempState(dsFilter);
    while not Accept do
    begin
      Result := InternalGetRecord(Buffer, GetMode, DoCheck);

      if Result <> grOK then
        break;

      if FSavedFlag and (PRecordData(Buffer).rdRecordNumber = FSavedRN) then
        break;

      FFilterBuffer := Buffer;
      Accept := True;

      OnFilterRecord(Self, Accept);
      if not Accept and (GetMode = gmCurrent) then
        GetMode := gmPrior;
    end;
    RestoreState(SaveState);
  end
  else begin
      { TODO : ^^^^ GetRecord}
//    case GetMode of
//     gmPrior: ; gmNext:; gmCurrent: ;
//    end;
    Result := InternalGetRecord(Buffer, GetMode, DoCheck);
    {$IFDEF NEW_GRID}
    if GroupSortExist and not FPseudoRecordsOn then begin
      if (PRecordData(Buffer)^.rdRecordKind <> rkRecord) then
        Inc(FPseudoSkip);
    end;
    {$ENDIF}
  end;
  {$IFDEF NEW_GRID}
  until (Result <> grOk) or (GetMode = gmCurrent)
    or (not (PRecordData(Buffer)^.rdRecordKind in RecordKindOptions));
      if GroupSortExist and not FPseudoRecordsOn then  begin
//    case Result of grOK: z:=z+' grOK'; grEOF: z:=z+' grEOF';//&&&
//      grBOF: z:=z+' grBOF'; grError: z:=z+' grError';  end;//&&&
//       fm1.Memo1.Lines.Add('  < GetRecord: O='+fm1.Q1ORDERKEY.asString+', '//&&&
//      +Dbg1(buffer) + ' ' + z);//&&&
      end;
  {$ENDIF}
end;          {  --  function TIBCustomDataSet.GetRecord  --  }

function TIBCustomDataSet.InternalGetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  result := grError;
  case GetMode of
    gmCurrent:
    begin
      if (FCurrentRecord >= 0) then
      begin
        if FCurrentRecord < FRecordCount then
          ReadRecordCache(FCurrentRecord, Buffer, False)
        else
        begin
          while (not FQSelect.EOF) and
                (FCurrentRecord >= FRecordCount) do
          begin
            if FQSelect.Next = nil then
              break;
            FetchCurrentRecordToBuffer(FQSelect, FRecordCount, Buffer);
            Inc(FRecordCount);
            //!!!b
            {$IFDEF NEW_GRID}
            ClearGroupSort;   {???qa}
            {$ELSE}
            FSortField := '';
            {$ENDIF}
            //!!!e
          end;
          FCurrentRecord := FRecordCount - 1;
          if (FCurrentRecord >= 0) then
            ReadRecordCache(FCurrentRecord, Buffer, False);
        end;
        //!!!b
        if FCurrentRecord = -1 then
          result := grBOF
        else
        //!!!e
        result := grOk;
      end
      else
        result := grBOF;
    end;
    gmNext:
    begin
      //!!!b
      FSavedRecordCount := -1;
      //!!!e

      result := grOk;
      if FCurrentRecord = FRecordCount then
        result := grEOF
      else
      if FCurrentRecord = FRecordCount - 1 then
      begin
        if (not FQSelect.EOF) then
        begin
          FQSelect.Next;
          Inc(FCurrentRecord);
        end;
        if (FQSelect.EOF) then
        begin
          result := grEOF;
        end
        else
        begin
          Inc(FRecordCount);
          FetchCurrentRecordToBuffer(FQSelect, FCurrentRecord, Buffer);
        end;
      end
      else
        if (FCurrentRecord < FRecordCount) then
        begin
          Inc(FCurrentRecord);
          ReadRecordCache(FCurrentRecord, Buffer, False);
        end;
    end;
    else { gmPrior }
    begin
      //!!!b
      FSavedRecordCount := -1;
      //!!!e

      if (FCurrentRecord = 0) then
      begin
        Dec(FCurrentRecord);
        result := grBOF;
      end
      else
        if (FCurrentRecord > 0) and
                    (FCurrentRecord <= FRecordCount) then
        begin
          Dec(FCurrentRecord);
          ReadRecordCache(FCurrentRecord, Buffer, False);
          result := grOk;
        end
        else
          if (FCurrentRecord = -1) then
            result := grBOF;
    end;
  end;
  if result = grOk then
    result := AdjustCurrentRecord(Buffer, GetMode);
  if result = grOk then
    with PRecordData(Buffer)^ do
    begin
      rdBookmarkFlag := bfCurrent;
      GetCalcFields(Buffer);
    end
  else
    if (result = grEOF) then
    begin
      CopyRecordBuffer(FModelBuffer, Buffer);
      PRecordData(Buffer)^.rdBookmarkFlag := bfEOF;
    end
    else
      if (result = grBOF) then
      begin
        CopyRecordBuffer(FModelBuffer, Buffer);
        PRecordData(Buffer)^.rdBookmarkFlag := bfBOF;
      end
      else
        if (result = grError) then
        begin
          CopyRecordBuffer(FModelBuffer, Buffer);
          PRecordData(Buffer)^.rdBookmarkFlag := bfEOF;
        end;
end;

function TIBCustomDataSet.GetRecordCount: Integer;
var
  Accept: Boolean;
  I: Integer;
begin
  //!!!
  if Active and Filtered and Assigned(OnFilterRecord) then
  begin
    if FSavedRecordCount <> -1 then
    begin
      Result := FSavedRecordCount;
    end else
    begin
      Result := 0;
      try
        for I := 0 to FRecordCount - 1 do
        begin
          FPeekBuffer := FBufferCache + _RecordBufferSize * I;
          if (PRecordData(FPeekBuffer)^.rdUpdateStatus <> usDeleted) then
          begin
            Accept := True;
            OnFilterRecord(Self, Accept);
            if Accept then
              Result := Result + 1;
          end;
        end;
      finally
        FPeekBuffer := nil;
      end;
      FSavedRecordCount := Result;
    end;
  end else
  //!!!
    result := FRecordCount - FDeletedRecords;
end;

function TIBCustomDataSet.GetRecordSize: Word;
begin
  result := FRecordBufferSize;
end;

{$IFDEF NEW_GRID}
           { TODO : ^^^^ GetPriorRecord} {скорее всего это не пойдёт}
function TIBCustomDataSet.GetPriorRecord: Boolean;
//var
//  I: Long;
//  CurRecord: Long;
begin
  Result := inherited GetPriorRecord;
  exit;
end;
function TIBCustomDataSet.GetNextRecord: Boolean;
//var
//  I: Long;
   { TODO : ^^^^ GetNextRecord} {скорее всего это не пойдёт}
begin
  Result := inherited GetNextRecord;
  exit;
end;
{$ENDIF}

{$IFDEF NEW_GRID}
{ Navigation }

//procedure TIBCustomDataSet.First; //!!!^^^!!! virtual стала
//var Distance, I: Integer;
//    Found: Boolean;
//   { TODO : ^^^^ First} {}
//begin
//  inherited First;
//  if GroupSortExist and not FPseudoRecordsOn then
//  begin
//      DisableControls;
//      FDataTransfer := True;
//      Found:=false;
//      Distance := 0;
//      try
//        I := ActiveRecord;
//        while (I < FRecordCount ) do begin
//          FPeekBuffer := FBufferCache + I * _RecordBufferSize;
//          if (PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord) then begin
//            Found:=True;
//            break;
//          end;
//          if (PRecordData(FPeekBuffer)^.rdRecordKind <> rkHiddenRecord) then
//            inc(Distance);
//          Inc(I);
//        end;
//      finally
//        FPeekBuffer := nil;
//        FDataTransfer := false;
//        EnableControls;
//        if Found then
//          inherited MoveBy(Distance);
//      end;
//    end
//end;

//procedure TIBCustomDataSet.Last;  //!!!^^^!!! virtual стала
//var Distance, I: Integer;
//    Found: Boolean;
//   { TODO : ^^^^ Last} {}
//begin
//  inherited Last;
//
//  if not FDataTransfer then
//  if GroupSortExist and not FPseudoRecordsOn then
//  begin
//      DisableControls;
//      FDataTransfer := True;
//      Found := false;
//      Distance := 0;
//      try
//        I :=  FRecordCount - 1; //PRecordData(ActiveBuffer)^.rdRecordNumber;
//        while (I > 0) do begin
//          FPeekBuffer := FBufferCache + I * _RecordBufferSize;
//          if (PRecordData(FPeekBuffer)^.rdRecordKind <> rkHiddenRecord) then
//            Dec(Distance);
//          if (PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord) then begin
//            Found := True;
//            break;
//          end;
//          Dec(I);
//        end;
//
//      finally
//        FPeekBuffer := nil;
//        FDataTransfer := false;
//        EnableControls;
//        if Found then     {Distance отрицательное и переход с последней записи}
//          inherited MoveBy(Distance + 1);
//      end;
//    end
//end;
//
//function TIBCustomDataSet.MoveBy(Distance: Integer): Integer;
//var
//  I: Long;
//  Found: Boolean;
//  IsInc: Boolean;
//  { TODO : ^^^^ MoveBy} {}
//begin
//  Result := 0; {чтобы не было Warning}
//  if GroupSortExist and not FPseudoRecordsOn
//    and ( (Distance = 1) or (Distance = -1) ) then
//  begin
//    if not FDataTransfer then
//    begin
//      DisableControls;
//      FDataTransfer := True;
//      IsInc := Distance > 0;
//      Found := false;
//      Distance := 0;
//      try
//        I := PRecordData(ActiveBuffer)^.rdRecordNumber;
//        while True do begin
//          if (IsInc and (I = FRecordCount)) or (not IsInc and (I = 0)) then
//            break;
//          if IsInc then Inc(I)
//          else          Dec(I);
//
//          FPeekBuffer := FBufferCache + I * _RecordBufferSize;
//          if (PRecordData(FPeekBuffer)^.rdRecordKind <> rkHiddenRecord) then
//            inc(Distance);
//          if (PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord) then begin
//            Found := True;
//            break;
//          end;
//        end;
//
//      finally
//        FPeekBuffer := nil;
//        FDataTransfer := false;
//        EnableControls;
//        if Found then begin
//          if not IsInc then
//            Distance := -Distance;
//          Result := inherited MoveBy(Distance)
//        end else begin
//          if IsInc then inherited Last
//          else          inherited First;
//        end;
//      end;
//    end
//  end  {конец обработки сгруппированного набора данных с исключением псевдозаписей}
//  else
//    Result := inherited MoveBy(Distance);
//end;
{$ENDIF}

procedure TIBCustomDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  CheckEditState;
  begin
     { When adding records, we *always* append.
       Insertion is just too costly }
    AdjustRecordOnInsert(Buffer);
    with PRecordData(Buffer)^ do
    begin
      rdUpdateStatus := usInserted;
      rdCachedUpdateStatus := cusInserted;
    end;
    if not CachedUpdates then
      InternalPostRecord(FQInsert, Buffer)
    else begin
      WriteRecordCache(FCurrentRecord, Buffer);
      FUpdatesPending := True;
    end;
    Inc(FRecordCount);
    InternalSetToRecord(Buffer);
  end
end;

procedure TIBCustomDataSet.InternalCancel;
var
  Buff: PChar;
  CurRec, i, j : Integer;
  pbd: PBlobDataArray;
begin
  inherited InternalCancel;
  Buff := GetActiveBuf;
  if Buff <> nil then
  begin
    CurRec := FCurrentRecord;
    AdjustRecordOnInsert(Buff);
    if (State = dsEdit) then begin
      CopyRecordBuffer(FOldBuffer, Buff);
      WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
      CopyRecordBuffer(FModelBuffer, FOldBuffer);
    end
    else
    begin
      CopyRecordBuffer(FModelBuffer, Buff);
      PRecordData(Buff)^.rdUpdateStatus := usDeleted;
      PRecordData(Buff)^.rdCachedUpdateStatus := cusUnmodified;
      PRecordData(Buff)^.rdBookmarkFlag := bfEOF;
      FCurrentRecord := CurRec;
    end;
  end;
  pbd := PBlobDataArray(PChar(Buff) + FBlobCacheOffset);
  j := 0;
  for i := 0 to FieldCount - 1 do
    if Fields[i].IsBlob then
    begin
      if pbd^[j] <> nil then
        pbd^[j].Cancel;
      Inc(j);
    end;
end;

procedure TIBCustomDataSet.InternalClose;
begin
  //!!!
  //if Assigned(Transaction) then
  //  Transaction.CheckAutoStop;
  if Assigned(ReadTransaction) then
    ReadTransaction.CheckAutoStop;
  //!!!
  try
    FQSelect.Close;
  except
  end;
  try
    {$IFDEF NEW_GRID}
    if FPseudoRecordsOn then
      FPseudoRecordsOn := false;
    {$ENDIF}
  except
  end;
  ClearBlobCache;
  FreeRecordBuffer(FModelBuffer);
  FreeRecordBuffer(FOldBuffer);
  FreeRecordBuffer(FTempBuffer);
  FCurrentRecord := -1;
  FOpen := False;
  FRecordCount := 0;
  FDeletedRecords := 0;
  FRecordSize := 0;
  FBPos := 0;
  FOBPos := 0;
  FCacheSize := 0;
  FOldCacheSize := 0;
  FBEnd := 0;
  FOBEnd := 0;
  ReallocMem(FBufferCache, 0);
  ReallocMem(FOldBufferCache, 0);
  BindFields(False);
  FUpdatesPending := false;
  if DefaultFields then
    DestroyFields;
end;

procedure TIBCustomDataSet.InternalDelete;
var
  Buff: PChar;
begin
  Buff := GetActiveBuf;
  if CanDelete then
  begin
    if not CachedUpdates then
      InternalDeleteRecord(FQDelete, Buff)
    else
    begin
      with PRecordData(Buff)^ do
      begin
        if rdCachedUpdateStatus = cusInserted then
          rdCachedUpdateStatus := cusUninserted
        else
        begin
          rdUpdateStatus := usDeleted;
          rdCachedUpdateStatus := cusDeleted;
        end;
      end;
      WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
    end;
    Inc(FDeletedRecords);
    FUpdatesPending := True;
  end
  else
    IBError(ibxeCannotDelete, [nil]);
end;
  { TODO : ^^^^ InternalFirst}
procedure TIBCustomDataSet.InternalFirst;
{$IFDEF NEW_GRID}
var
  I: Long;
{$ENDIF}
begin
  FCurrentRecord := -1;
  {ниже кандидат на удаление}
  exit;
  {$IFDEF NEW_GRID}
  if GroupSortExist and not FPseudoRecordsOn then
  begin
    DisableControls;
    FDataTransfer := True;
    try
      I := 0;
      while (I < FRecordCount ) do begin
        FPeekBuffer := FBufferCache + I * _RecordBufferSize;
        if (PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord) then begin
          FCurrentRecord := I - 1;
          //Resync([]);
          break;
        end;
        Inc(I);
      end;
    finally
      FPeekBuffer := nil;
      FDataTransfer := false;
      EnableControls;
    end;
  end;
  {$ENDIF}
end;

procedure TIBCustomDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  FCurrentRecord := PInteger(Bookmark)^;
end;

procedure TIBCustomDataSet.InternalHandleException;
begin
end;

procedure TIBCustomDataSet.InternalInitFieldDefs;
var
  FieldType: TFieldType;
  FieldSize: Word;
  FieldNullable : Boolean;
  i, FieldPosition, FieldPrecision, FieldIndex: Integer;
  FieldAliasName: string;
  RelationName, FieldName: string;

  //!!!b
  PrevRelationName: String;
  //!!!e

begin
  if not InternalPrepared then
  begin
    InternalPrepare;
    exit;
  end;
  FNeedsRefresh := False;
  //!!!b
  PrevRelationName := '';
  //!!!e
  try
    FieldDefs.BeginUpdate;
    FieldDefs.Clear;
    FieldIndex := 0;
    if (Length(FMappedFieldPosition) < FQSelect.Current.Count) then
      SetLength(FMappedFieldPosition, FQSelect.Current.Count);
    for i := 0 to FQSelect.Current.Count - 1 do
      with FQSelect.Current[i].Data^ do
      begin
        { Get the field name }
        SetString(FieldAliasName, aliasname, aliasname_length);
        SetString(RelationName, relname, relname_length);
        SetString(FieldName, sqlname, sqlname_length);
        FieldSize := 0;
        FieldPrecision := 0;
        FieldNullable := FQSelect.Current[i].IsNullable;

        //!!!
        // если в запросе вытаскиваются поля из разных таблиц,
        // то скорее всего эти таблицы связаны джоинами
        // и надо рефрешить запись, чтобы вытащились правильные значения
        if not FNeedsRefresh then
        begin
          FNeedsRefresh := (PrevRelationName > '') and (RelationName <> PrevRelationName);
          PrevRelationName := RelationName;
        end;
        //!!!

        case sqltype and not 1 of
          { All VARCHAR's must be converted to strings before recording
           their values }
          SQL_VARYING, SQL_TEXT:
          begin
            FieldSize := sqllen;
            FieldType := ftString;
          end;
          { All Doubles/Floats should be cast to doubles }
          SQL_DOUBLE, SQL_FLOAT:
            FieldType := ftFloat;
          SQL_SHORT:
          begin
            if (sqlscale = 0) then
              FieldType := ftSmallInt
            else
            begin
              FieldType := ftBCD;
              FieldPrecision := 4;
              FieldSize := -sqlscale;
            end;
          end;
          SQL_LONG:
          begin
            if (sqlscale = 0) then
              FieldType := ftInteger
            else
              if (sqlscale >= (-4)) then
              begin
                FieldType := ftBCD;
                FieldPrecision := 9;
                FieldSize := -sqlscale;
              end
              else
                FieldType := ftFloat;
              end;
          SQL_INT64:
          begin
            if (sqlscale = 0) then
              FieldType := ftLargeInt
            else
              if (sqlscale >= (-4)) then
              begin
                FieldType := ftBCD;
                FieldPrecision := 18;
                FieldSize := -sqlscale;
              end
              else
                FieldType := ftFloat;
              end;
          SQL_TIMESTAMP: FieldType := ftDateTime;
          SQL_TYPE_TIME: FieldType := ftTime;
          SQL_TYPE_DATE: FieldType := ftDate;
          SQL_BLOB:
          begin
            FieldSize := sizeof (TISC_QUAD);
            if (sqlsubtype = 1) then
              FieldType := ftmemo
            else
              FieldType := ftBlob;
          end;
          SQL_ARRAY:
          begin
            FieldSize := sizeof (TISC_QUAD);
            FieldType := ftUnknown;
          end;
          else
            FieldType := ftUnknown;
        end;
        FieldPosition := i + 1;
        if (FieldType <> ftUnknown) and (FieldAliasName <> 'IBX_INTERNAL_DBKEY') then {do not localize}
        begin
          FMappedFieldPosition[FieldIndex] := FieldPosition;
          Inc(FieldIndex);
          with FieldDefs.AddFieldDef do
          begin
            Name := string( FieldAliasName );
            FieldNo := FieldPosition;
            DataType := FieldType;
            Size := FieldSize;
            Precision := FieldPrecision;
            Required := not FieldNullable;
            InternalCalcField := False;
            if (FieldName <> '') and (RelationName <> '') then
            begin
              if Database.Has_COMPUTED_BLR(RelationName, FieldName) then
              begin
                Attributes := [faReadOnly];
                InternalCalcField := True;
                FNeedsRefresh := True;
              end
              else
              begin
                if Database.Has_DEFAULT_VALUE(RelationName, FieldName) then
                begin
                  Attributes := Attributes - [faRequired];
                  FNeedsRefresh := True;
                end;
              end;
            end;
            if ((SQLType and not 1) = SQL_TEXT) then
              Attributes := Attributes + [faFixed];
          end;
        end;
      end;
  finally
    FieldDefs.EndUpdate;
  end;
end;

procedure TIBCustomDataSet.InternalInitRecord(Buffer: PChar);
begin
  CopyRecordBuffer(FModelBuffer, Buffer);
end;

{
procedure TIBCustomDataSet.InternalLast;
var
  Buffer: PChar;
begin
  if (FQSelect.EOF) then
    FCurrentRecord := FRecordCount
  else
  begin
    Buffer := AllocRecordBuffer;
    try
      while FQSelect.Next <> nil do
      begin
        FetchCurrentRecordToBuffer(FQSelect, FRecordCount, Buffer);
        Inc(FRecordCount);
      end;
      FCurrentRecord := FRecordCount;
    finally
      FreeRecordBuffer(Buffer);
    end;
  end;
end;
}
  { TODO : ^^^^ InternalLast}
procedure TIBCustomDataSet.InternalLast;
var
  Buffer: PChar;
  Delta: LongWord;
  I: Integer;
  ShowWindow: Boolean;
  T: DWORD;
begin
  if (FQSelect.EOF) then //begin
    FCurrentRecord := FRecordCount
    {$IFDEF NEW_GRID}      {кандидат на удаление}
//    if GroupSortExist and not FPseudoRecordsOn then
//    begin
//      DisableControls;
//      FDataTransfer := True;
//      try
//        I := FRecordCount - 1;
//        while (I > -1) do begin
//          FPeekBuffer := FBufferCache + I * _RecordBufferSize;
//          if (PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord) then begin
//            FCurrentRecord := I + 1;
//            //Resync([]);
//            break;
//          end;
//          Dec(I);
//        end;
//      finally
//        FPeekBuffer := nil;
//        FDataTransfer := false;
//        EnableControls;
//      end;
//    end;
  {$ENDIF} //end
  else
  begin
    Buffer := AllocRecordBuffer;
    ShowWindow := False;
    Delta := 0;
    T := GetTickCount;
    if Owner is TForm then
      for I := 0 to Owner.ComponentCount - 1 do
        if (Owner.Components[I] is TDataSource) and IsLinkedTo(TDataSource(Owner.Components[I])) then
        begin
          ShowWindow := True;
          break;
        end;
    try
      while FQSelect.Next <> nil do
      begin
        FetchCurrentRecordToBuffer(FQSelect, FRecordCount, Buffer);
        Inc(FRecordCount);
        if ShowWindow then
        begin
          Inc(Delta);
          if Delta mod 2000 = 0 then
          begin
            if dlgRecordFetch = nil then
            begin
              dlgRecordFetch := TdlgRecordFetch.Create(Application);
              dlgRecordFetch.Canceled := False;
            end;
            if not dlgRecordFetch.Visible then
            begin
              dlgRecordFetch.Show;
              dlgRecordFetch.Canceled := False;
            end;
            dlgRecordFetch.lblCount.Caption :=
              Format('Извлечено записей: %d за %d сек', [FRecordCount, (GetTickCount - T + 1000) div 1000]);
            dlgRecordFetch.Update;
            if dlgRecordFetch.Canceled then break;

            if (GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0 then
              break;
          end;
        end;
      end;
      FCurrentRecord := FRecordCount;
    finally
      FreeRecordBuffer(Buffer);
      if dlgRecordFetch <> nil then
        FreeAndNil(dlgRecordFetch);
    end;
  end;
end;

procedure TIBCustomDataSet.InternalSetParamsFromCursor;
var
  i: Integer;
  cur_param: TIBXSQLVAR;
  cur_field: TField;
  s: TStream;
begin
  if FQSelect.SQL.Text = '' then
    IBError(ibxeEmptyQuery, [nil]);
  if not FInternalPrepared then
    InternalPrepare;
  if (SQLParams.Count > 0) and (DataSource <> nil) and (DataSource.DataSet <> nil) then
  begin
    for i := 0 to SQLParams.Count - 1 do
    begin
      cur_field := DataSource.DataSet.FindField(SQLParams[i].Name);
      cur_param := SQLParams[i];
      if (cur_field <> nil) then
      begin
        if (cur_field.IsNull) then
          cur_param.IsNull := True
        else case cur_field.DataType of
          ftString:
            cur_param.AsString := cur_field.AsString;
          ftBoolean, ftSmallint, ftWord:
            cur_param.AsShort := cur_field.AsInteger;
          ftInteger:
            cur_param.AsLong := cur_field.AsInteger;
          ftLargeInt:
            cur_param.AsInt64 := TLargeIntField(cur_field).AsLargeInt;
          ftFloat, ftCurrency:
           cur_param.AsDouble := cur_field.AsFloat;
          ftBCD:
            cur_param.AsCurrency := cur_field.AsCurrency;
          ftDate:
            cur_param.AsDate := cur_field.AsDateTime;
          ftTime:
            cur_param.AsTime := cur_field.AsDateTime;
          ftDateTime:
            cur_param.AsDateTime := cur_field.AsDateTime;
          ftBlob, ftMemo:
          begin
            s := nil;
            try
              s := DataSource.DataSet.
                     CreateBlobStream(cur_field, bmRead);
              cur_param.LoadFromStream(s);
            finally
              s.free;
            end;
          end;
          else
            IBError(ibxeNotSupported, [nil]);
        end;
      end;
    end;
  end;
end;

procedure TIBCustomDataSet.ReQuery;
begin
  FQSelect.Close;
  ClearBlobCache;
  FCurrentRecord := -1;
  FRecordCount := 0;
  FDeletedRecords := 0;
  FBPos := 0;
  FOBPos := 0;
  FBEnd := 0;
  FOBEnd := 0;
  FQSelect.Close;
  FQSelect.ExecQuery;
  FOpen := FQSelect.Open;
  //FRowsAffected := FQSelect.RowsAffected;
  FLastQuery := lqSelect;
  First;
end;

procedure TIBCustomDataSet.InternalOpen;

  function RecordDataLength(n: Integer): Long;
  begin
    result := SizeOf(TRecordData) + ((n - 1) * SizeOf(TFieldData));
  end;

begin
  ActivateConnection;
  //!!!
  //ActivateTransaction;
  ActivateReadTransaction;
  Inc(FOpenCounter);
  FSavedRecordCount := -1;
  //!!!
  if FQSelect.SQL.Text = '' then
    IBError(ibxeEmptyQuery, [nil]);
  if not FInternalPrepared then
    InternalPrepare;
  if FQSelect.SQLType in [SQLSelect, SQLSelectForUpdate] then
  begin
    if DefaultFields then
      CreateFields;
    BindFields(True);
    FCurrentRecord := -1;
    FQSelect.ExecQuery;
    FOpen := FQSelect.Open;

    { Initialize offsets, buffer sizes, etc...
      1. Initially FRecordSize is just the "RecordDataLength".
      2. Allocate a "model" buffer and do a dummy fetch
      3. After the dummy fetch, FRecordSize will be appropriately
         adjusted to reflect the additional "weight" of the field
         data.
      4. Set up the FCalcFieldsOffset, FBlobCacheOffset and FRecordBufferSize.
      5. Now, with the BufferSize available, allocate memory for chunks of records
      6. Re-allocate the model buffer, accounting for the new
         FRecordBufferSize.
      7. Finally, calls to AllocRecordBuffer will work!.
     }
    {Step 1}
    FRecordSize := RecordDataLength(FQSelect.Current.Count);
    {Step 2, 3}
    IBAlloc(FModelBuffer, 0, FRecordSize);
    FetchCurrentRecordToBuffer(FQSelect, -1, FModelBuffer);
    {Step 4}
    FCalcFieldsOffset := FRecordSize;
    FBlobCacheOffset := FCalcFieldsOffset + CalcFieldsSize;
    FRecordBufferSize := (FBlobCacheOffset + (BlobFieldCount * SizeOf(TIBBlobStream)));
    {Step 5}
    if UniDirectional then
      FBufferChunkSize := FRecordBufferSize * UniCache
    else
      FBufferChunkSize := FRecordBufferSize * BufferChunks;
    {$IFDEF HEAP_STRING_FIELD}
    IBAlloc(FBufferCache, 0, FBufferChunkSize);
    {$ELSE}
    IBAlloc(FBufferCache, FBufferChunkSize, FBufferChunkSize);
    {$ENDIF}
    if FCachedUpdates or (csReading in ComponentState) then
      {$IFDEF HEAP_STRING_FIELD}
      IBAlloc(FOldBufferCache, 0, FBufferChunkSize);
      {$ELSE}
      IBAlloc(FOldBufferCache, FBufferChunkSize, FBufferChunkSize);
      {$ENDIF}
    FBPos := 0;
    FOBPos := 0;
    FBEnd := 0;
    FOBEnd := 0;
    FCacheSize := FBufferChunkSize;
    FOldCacheSize := FBufferChunkSize;
    {Step 6}
    IBAlloc(FModelBuffer, RecordDataLength(FQSelect.Current.Count),
                           FRecordBufferSize);
    {Step 7}
    FOldBuffer := AllocRecordBuffer;
    FTempBuffer := AllocRecordBuffer;
  end
  else
    FQSelect.ExecQuery;
  //FRowsAffected := FQSelect.RowsAffected;
  FLastQuery := lqSelect;
  //!!!b
  {$IFDEF NEW_GRID}
  ClearGroupSort;
  {$ELSE}
  FSortField := '';
  {$ENDIF}
  //!!!e
end;

procedure TIBCustomDataSet.InternalPost;
var
  Qry: TIBSQL;
  Buff: PChar;
  bInserting: Boolean;

  //!!!
  procedure ShiftBuffer;
  var
    I: Integer;
  begin
    // паспрабуем прымусіць датасет устаўляць запісы у бягучую
    // пазіцыю, а не ў канец сьпісу
    // пасля таго, як адпрацуе код ІБІКС проста
    // здвінем запісы пачынаючы ад бягучай пазіцыі
    // і ўставім наш запіс. Пасля павялічым нумары
    // здвінутых запісаў.
    if (State = dsInsert) and (FInsertedAt <> -1) and (not UniDirectional) then
    begin
      {$IFDEF HEAP_STRING_FIELD}
      FinalizeRecordBuffer(@FBufferCache[FRecordCount * FRecordBufferSize]);
      {$ENDIF}
      Move(FBufferCache[FInsertedAt * FRecordBufferSize],
        FBufferCache[(FInsertedAt + 1) * FRecordBufferSize],
        (FRecordCount - FInsertedAt) * FRecordBufferSize);
      {$IFDEF HEAP_STRING_FIELD}
      FillChar(FBufferCache[FInsertedAt * FRecordBufferSize],
        FRecordBufferSize, 0);
      {$ENDIF}
      PRecordData(Buff)^.rdRecordNumber := FInsertedAt;
      WriteRecordCache(FInsertedAt, Buff);
      FCurrentRecord := FInsertedAt;
      for I := FInsertedAt + 1 to FRecordCount do
      begin
        Inc(PRecordData(FBufferCache + I * FRecordBufferSize)^.rdRecordNumber);
      end;
      FInsertedAt := -1;
    end;
  end;
  //!!!

begin
//  inherited InternalPost;
  Buff := GetActiveBuf;
  CheckEditState;

  AdjustRecordOnInsert(Buff);
  bInserting := False;
  Qry := nil;
  case State of
    dsInsert :
    begin
      bInserting := True;
      Qry := FQInsert;

      PRecordData(Buff)^.rdUpdateStatus := usInserted;
      PRecordData(Buff)^.rdCachedUpdateStatus := cusInserted;
      PRecordData(Buff)^.rdRecordNumber := FRecordCount;
      WriteRecordCache(FRecordCount, Buff);
      FCurrentRecord := FRecordCount;
    end;
    dsEdit :
    begin
      Qry := FQModify;
      if PRecordData(Buff)^.rdCachedUpdateStatus = cusUnmodified then
      begin
        PRecordData(Buff)^.rdUpdateStatus := usModified;
        PRecordData(Buff)^.rdCachedUpdateStatus := cusModified;
      end
      else
        if PRecordData(Buff)^.rdCachedUpdateStatus = cusUninserted then
        begin
          PRecordData(Buff)^.rdCachedUpdateStatus := cusInserted;
          Dec(FDeletedRecords);
        end;
    end;
  end;
  if (not CachedUpdates) then
  //!!!
  begin
  //!!!
    InternalPostRecord(Qry, Buff);
  //!!!
    ShiftBuffer;
  end
  //!!!
  else
  begin
    //!!!
    ShiftBuffer;
    //!!!
    WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
    FUpdatesPending := True;
  end;
  if bInserting then
  begin
    if not (State in dsEditModes) then
      raise Exception.Create('Dataset not in edit or insert mode.');
    Inc(FRecordCount);
  end;
end;

procedure TIBCustomDataSet.InternalRefresh;
begin
  inherited InternalRefresh;
  //!!!
  if FRecordCount > 0 then
  //!!!
    InternalRefreshRow;
end;
      { TODO : ^^^^ InternalSetToRecord}
procedure TIBCustomDataSet.InternalSetToRecord(Buffer: PChar);
begin
  InternalGotoBookmark(@(PRecordData(Buffer)^.rdRecordNumber));
end;

function TIBCustomDataSet.IsCursorOpen: Boolean;
begin
  result := FOpen;
end;

function TIBCustomDataSet.Locate(const KeyFields: string; const KeyValues: Variant;
                                 Options: TLocateOptions): Boolean;
var
  CurBookmark,NewBookmark: string;
  bsc, asc: TDataSetNotifyEvent;
begin
  DisableControls;
  bsc := BeforeScroll;
  asc := AfterScroll;
  BeforeScroll := nil;
  AfterScroll := nil;
  try
    CurBookmark := Bookmark;
    First;
    result := InternalLocate(KeyFields, KeyValues, Options);
    if not result then
      Bookmark := CurBookmark
    else begin
      if Assigned(Bsc) then begin
        NewBookmark := Bookmark;{сохраним найденную позицию}
        Bookmark := CurBookmark;{вернемся на старую позицию}
        Bsc(Self); {отработаем}
        Bookmark := NewBookmark; {вернемся на найденное}
      end;
      if Assigned(Asc) then
        Asc(Self); {отработаем}
    end;
  finally
    BeforeScroll := bsc;
    AfterScroll := asc;
    EnableControls;
  end;
end;

function TIBCustomDataSet.Lookup(const KeyFields: string; const KeyValues: Variant;
                                 const ResultFields: string): Variant;
var
  fl: TList;
  CurBookmark: string;
begin
  DisableControls;
  fl := TList.Create;
  CurBookmark := Bookmark;
  try
    First;
    if InternalLocate(KeyFields, KeyValues, []) then
    begin
      if (ResultFields <> '') then
        result := FieldValues[ResultFields]
      else
        result := NULL;
    end
    else
      result := Null;
  finally
    Bookmark := CurBookmark;
    fl.Free;
    EnableControls;
  end;
end;

procedure TIBCustomDataSet.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PRecordData(Buffer)^.rdRecordNumber := PInteger(Data)^;
end;

procedure TIBCustomDataSet.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PRecordData(Buffer)^.rdBookmarkFlag := Value;
end;

procedure TIBCustomDataSet.SetCachedUpdates(Value: Boolean);
begin
  if not Value and FCachedUpdates then
    CancelUpdates;
  if (not (csReading in ComponentState)) and Value then
    CheckDatasetClosed;
  FCachedUpdates := Value;
end;

procedure TIBCustomDataSet.SetDataSource(Value: TDataSource);
begin
  if IsLinkedTo(Value) then
    IBError(ibxeCircularReference, [nil]);
  if FDataLink <> nil then
    FDataLink.DataSource := Value;
end;

procedure TIBCustomDataSet.InternalSetFieldData(Field: TField; Buffer: Pointer);
var
  Buff, TmpBuff: PChar;
  {$IFDEF HEAP_STRING_FIELD}
  L: Integer;
  {$ENDIF}
begin
  Buff := GetActiveBuf;
  if Field.FieldNo < 0 then
  begin
    TmpBuff := Buff + FRecordSize + Field.Offset;
    Boolean(TmpBuff[0]) := LongBool(Buffer);
    if Boolean(TmpBuff[0]) then
      Move(Buffer^, TmpBuff[1], Field.DataSize);
    WriteRecordCache(PRecordData(Buff)^.rdRecordNumber, Buff);
  end
  else
  begin
    //!!!
    if not FDataTransfer then
    //!!!
      CheckEditState;
    with PRecordData(Buff)^ do
    begin
      { If inserting, Adjust record position }
      AdjustRecordOnInsert(Buff);
      if (FMappedFieldPosition[Field.FieldNo - 1] > 0) and
         (FMappedFieldPosition[Field.FieldNo - 1] <= rdFieldCount) then
      begin
        //!!!
        if not FDataTransfer then
        //!!!
          Field.Validate(Buffer);
        if (Buffer = nil) or
           (Field is TIBStringField) and (PChar(Buffer)[0] = #0) then
          {$IFDEF HEAP_STRING_FIELD}
          begin
            rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdIsNull := True;
            if IsHeapField(rdFields[FMappedFieldPosition[Field.FieldNo - 1]]) then
              ReallocMem(Pointer(rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs), 0);
          end
          {$ELSE}
          rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdIsNull := True
          {$ENDIF}
        else
        begin
          {$IFDEF HEAP_STRING_FIELD}
          if IsHeapField(rdFields[FMappedFieldPosition[Field.FieldNo - 1]]) then
          begin
            L := StrLen(PChar(Buffer));
            ReallocMem(Pointer(rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs),
              L);
            Move(Buffer^, Pointer(rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs)^,
              L);
            rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataLength := L;
            rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdIsNull := False;
          end else begin
          {$ENDIF}
          Move(Buffer^, Buff[rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataOfs],
                 rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataSize);
          if (rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataType = SQL_TEXT) or
             (rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataType = SQL_VARYING) then
            rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdDataLength := StrLen(PChar(Buffer));
          rdFields[FMappedFieldPosition[Field.FieldNo - 1]].fdIsNull := False;
          {$IFDEF HEAP_STRING_FIELD}
          end;
          {$ENDIF}
          //!!!
          if not FDataTransfer then
          //!!!
            if rdUpdateStatus = usUnmodified then
            begin
              if CachedUpdates then
              begin
                FUpdatesPending := True;
                if State = dsInsert then
                  rdCachedUpdateStatus := cusInserted
                else if State = dsEdit then
                  rdCachedUpdateStatus := cusModified;
              end;

              if State = dsInsert then
                rdUpdateStatus := usInserted
              else
                rdUpdateStatus := usModified;
            end;
          if Buff <> FPeekBuffer then
            WriteRecordCache(rdRecordNumber, Buff);
          //!!!
          if not FDataTransfer then
          //!!!
            SetModified(True);
        end;
      end;
    end;
  end;
  //!!!
  if not FDataTransfer then
  //!!!
    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
        DataEvent(deFieldChange, Longint(Field));
end;{ procedure TIBCustomDataSet.InternalSetFieldData }

procedure TIBCustomDataSet.SetRecNo(Value: Integer);
var
  B: PRecordData;
  I, J: Integer;
  Accept: Boolean;
begin
  CheckBrowseMode;
  if (Value < 1) then
    Value := 1
  else if Value > FRecordCount then
  begin
    InternalLast;
    Value := Min(FRecordCount, Value);
  end;

  //!!!b
  if (FDeletedRecords > 0) or (Filtered and Assigned(OnFilterRecord)) then
  begin
    J := 0;
    for I := 0 to (FRecordCount - 1) do
    begin
      B := Addr(FBufferCache[_RecordBufferSize * I]);
      if B^.rdUpdateStatus <> usDeleted then
      begin
        if Filtered and Assigned(OnFilterRecord) then
        begin
          FPeekBuffer := PChar(B);
          try
            Accept := True;
            OnFilterRecord(Self, Accept);
            if Accept then
              Inc(J);
          finally
            FPeekBuffer := nil;
          end;
        end else
          Inc(J);
      end;
      if J = Value then
      begin
        Value := I + 1;
        break;
      end;
    end;
  end;
  //!!!e

  if (Value <> RecNo) then
  begin
    DoBeforeScroll;
    FCurrentRecord := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;

procedure TIBCustomDataSet.Disconnect;
begin
  Close;
  InternalUnPrepare;
end;

procedure TIBCustomDataSet.SetUpdateMode(const Value: TUpdateMode);
begin
  if not CanModify then
    IBError(ibxeCannotUpdate, [nil])
  else
    FUpdateMode := Value;
end;


procedure TIBCustomDataSet.SetUpdateObject(Value: TIBDataSetUpdateObject);
begin
  if Value <> FUpdateObject then
  begin
    if Assigned(FUpdateObject) and (FUpdateObject.DataSet = Self) then
    begin
      FUpdateObject.RemoveFreeNotification(Self);
      FUpdateObject.DataSet := nil;
    end;
    FUpdateObject := Value;
    if Assigned(FUpdateObject) then
    begin
      FUpdateObject.FreeNotification(Self);
      if Assigned(FUpdateObject.DataSet) and
        (FUpdateObject.DataSet <> Self) then
        FUpdateObject.DataSet.UpdateObject := nil;
      FUpdateObject.DataSet := Self;
    end;
  end;
end;

function TIBCustomDataSet.ConstraintsStored: Boolean;
begin
  Result := Constraints.Count > 0;
end;

procedure TIBCustomDataSet.ClearCalcFields(Buffer: PChar);
begin
 FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
end;


procedure TIBCustomDataSet.InternalUnPrepare;
begin
  if FInternalPrepared then
  begin
    CheckDatasetClosed;
    FieldDefs.Clear;
    FInternalPrepared := False;
    FLiveMode := [];

    //!!!
    DeactivateReadTransaction;
    //!!!
  end;
end;

procedure TIBCustomDataSet.InternalExecQuery;
var
  DidActivate: Boolean;
begin
  DidActivate := False;
  try
    ActivateConnection;
    DidActivate := ActivateTransaction;
    if FQSelect.SQL.Text = '' then
      IBError(ibxeEmptyQuery, [nil]);
    if not FInternalPrepared then
      InternalPrepare;
    if FQSelect.SQLType in [SQLSelect, SQLSelectForUpdate] then
    begin
      IBError(ibxeIsASelectStatement, [nil]);
    end
    else
      FQSelect.ExecQuery;
  finally
    if DidActivate then
      //!!!
      //DeactivateTransaction;
      // Deactivate не подходит потому что использует
      // AutoStopAction а оно по умолчанию
      // saNone. Хотя стоит подумать, может это
      // и правильно...
      Transaction.Commit;
      //!!!
  end;
end;

function TIBCustomDataSet.GetSelectStmtHandle: TISC_STMT_HANDLE;
begin
  Result := FQSelect.Handle;
end;

procedure TIBCustomDataSet.InitRecord(Buffer: PChar);
begin
  inherited InitRecord(Buffer);
  with PRecordData(Buffer)^ do
  begin
    rdUpdateStatus := TUpdateStatus(usInserted);
    rdBookMarkFlag := bfInserted;
    rdRecordNumber := -1;
  end;
end;

procedure TIBCustomDataSet.InternalInsert;
//!!!
var
  B: PChar;
//!!!
begin
  //!!!
  if not UniDirectional then
  begin
    B := GetActiveBuf;
    if GetBookmarkFlag(B) = bfEOF then
      FInsertedAt := -1
    else
      GetBookmarkData(B, @FInsertedAt);
    CopyRecordBuffer(FModelBuffer, FOldBuffer);
  end;  
  //!!!
  CursorPosChanged;
end;

{ TIBDataSet IProviderSupport }

procedure TIBCustomDataSet.PSEndTransaction(Commit: Boolean);
begin
  if Transaction.InTransaction then
  begin
    if Commit then
      Transaction.Commit
    else
      Transaction.Rollback;
  end;
end;

function TIBCustomDataSet.PSExecuteStatement(const ASQL: string; AParams: TParams;
  ResultSet: Pointer = nil): Integer;
var
  FQuery: TIBDataSet;
  i : Integer;
begin
  if Assigned(ResultSet) then
  begin
    TDataSet(ResultSet^) := TIBDataSet.Create(nil);
    with TIBDataSet(ResultSet^) do
    begin
      Database := self.Database;
      Transaction := self.Transaction;
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      QSelect.GenerateParamNames := true;
      SelectSQL.Text := ASQL;
      for i := 0 to AParams.Count - 1 do
        Params[i].Value := AParams[i].Value;
      Open;
      if SQLType = SQLSelect then
      begin
        FetchAll;
        Result := RecordCount;
      end
      else
        Result := RowsAffected;
    end;
  end
  else
  begin
    FQuery := TIBDataSet.Create(nil);
    try
      FQuery.Database := Database;
      FQuery.Transaction := Transaction;
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      FQuery.QSelect.GenerateParamNames := True;
      FQuery.SelectSQL.Text := ASQL;
      for i := 0 to AParams.Count - 1 do
        FQuery.Params[i].Value := AParams[i].Value;
      FQuery.ExecSQL;
      if FQuery.SQLType = SQLSelect then
      begin
        FQuery.FetchAll;
        Result := FQuery.RecordCount;
      end
      else
        Result := FQuery.RowsAffected;
    finally
      FQuery.Free;
    end;
  end;
end;

function TIBCustomDataSet.PSGetQuoteChar: string;
begin
  Result := '';
  if Assigned(Database) and (Database.SQLDialect = 3) then
    Result := '"'
end;

function TIBCustomDataSet.PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError;
var
  PrevErr: Integer;
begin
  if Prev <> nil then
    PrevErr := Prev.ErrorCode else
    PrevErr := 0;
  if E is EIBError then
    with EIBError(E) do
      Result := EUpdateError.Create(E.Message, '', SQLCode, PrevErr, E) else
      Result := inherited PSGetUpdateException(E, Prev);
end;

function TIBCustomDataSet.PSInTransaction: Boolean;
begin
  Result := Transaction.InTransaction;
end;

function TIBCustomDataSet.PSIsSQLBased: Boolean;
begin
  Result := True;
end;

function TIBCustomDataSet.PSIsSQLSupported: Boolean;
begin
  Result := True;
end;

procedure TIBCustomDataSet.PSReset;
begin
  inherited PSReset;
  if Active then
  begin
    Close;
    Open;
  end;
end;

function TIBCustomDataSet.PSUpdateRecord(UpdateKind: TUpdateKind; Delta: TDataSet): Boolean;
var
  UpdateAction: TIBUpdateAction;
  SQL: string;
  Params: TParams;

  procedure AssignParams(DataSet: TDataSet; Params: TParams);
  var
    I: Integer;
    Old: Boolean;
    Param: TParam;
    PName: string;
    Field: TField;
    Value: Variant;
  begin
    for I := 0 to Params.Count - 1 do
    begin
      Param := Params[I];
      PName := Param.Name;
      Old := CompareText(Copy(PName, 1, 4), 'OLD_') = 0; {do not localize}
      if Old then System.Delete(PName, 1, 4);
      Field := DataSet.FindField(PName);
      if not Assigned(Field) then Continue;
      if Old then Param.AssignFieldValue(Field, Field.OldValue) else
      begin
        Value := Field.NewValue;
        if VarIsEmpty(Value) then Value := Field.OldValue;
        Param.AssignFieldValue(Field, Value);
      end;
    end;
  end;

begin
  Result := False;
  if Assigned(OnUpdateRecord) then
  begin
    UpdateAction := uaFail;
    if Assigned(FOnUpdateRecord) then
    begin
      FOnUpdateRecord(Delta, UpdateKind, UpdateAction);
      Result := UpdateAction = uaApplied;
    end;
  end
  else if Assigned(FUpdateObject) then
  begin
    SQL := FUpdateObject.GetSQL(UpdateKind).Text;
    if SQL <> '' then
    begin
      Params := TParams.Create;
      try
        Params.ParseSQL(SQL, True);
        AssignParams(Delta, Params);
        if PSExecuteStatement(SQL, Params) = 0 then
          IBError(ibxeNoRecordsAffected, [nil]);
        Result := True;
      finally
        Params.Free;
      end;
    end;
  end;
end;

procedure TIBCustomDataSet.PSStartTransaction;
begin
  ActivateConnection;
  Transaction.StartTransaction;
end;

function TIBCustomDataSet.PSGetTableName: string;
begin
//  if not FInternalPrepared then
//    InternalPrepare;
  { It is possible for the FQSelectSQL to be unprepared
    with FInternalPreprepared being true (see DoBeforeTransactionEnd).
    So check the Prepared of the SelectSQL instead }
  if not FQSelect.Prepared then
    FQSelect.Prepare;
  Result := FQSelect.UniqueRelationName;
end;

procedure TIBDataSet.BatchInput(InputObject: TIBBatchInput);
begin
  InternalBatchInput(InputObject);
end;

procedure TIBDataSet.BatchOutput(OutputObject: TIBBatchOutput);
begin
  InternalBatchOutput(OutputObject);
end;

procedure TIBDataSet.ExecSQL;
begin
  InternalExecQuery;
  //FRowsAffected := FQSelect.RowsAffected;
  FLastQuery := lqSelect;
end;

procedure TIBDataSet.Prepare;
begin
  InternalPrepare;
end;

procedure TIBDataSet.UnPrepare;
begin
  InternalUnPrepare;
end;

function TIBDataSet.GetPrepared: Boolean;
begin
  Result := InternalPrepared;
end;

procedure TIBDataSet.InternalOpen;
begin
  ActivateConnection;
  //!!!
  //ActivateTransaction;
  ActivateReadTransaction;
  //!!!
  InternalSetParamsFromCursor;
  Inherited InternalOpen;
end;

procedure TIBDataSet.SetFiltered(Value: Boolean);
begin
  //!!!
  inherited SetFiltered(value);
  {if (Filtered <> Value) then
  begin
    inherited SetFiltered(value);
    if Active then
    begin
      Close;
      Open;
    end;
  end
  else
    inherited SetFiltered(value);}
  //!!!
end;

function TIBCustomDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
var
  //TempCurrent : long;
  Buff: PChar;
begin
  Result := false;
  if not Assigned(Bookmark) then
    exit;
  Result := PInteger(Bookmark)^ < FRecordCount;
  // check that this is not a fully deleted record slot
  if Result then
  begin
    {TempCurrent := FCurrentRecord;
    FCurrentRecord := PInteger(Bookmark)^;
    Buff := ActiveBuffer;}

    Buff := FBufferCache + _RecordBufferSize * PInteger(Bookmark)^;

    if (PRecordData(Buff)^.rdUpdateStatus = usDeleted) and
       (PRecordData(Buff)^.rdCachedUpdateStatus = cusUnmodified) then
      Result := false;
    {FCurrentRecord := TempCurrent;}

    //!!!b
    if Result and Filtered and Assigned(OnFilterRecord) then
    begin
      FPeekBuffer := Buff;
      try
        OnFilterRecord(Self, Result);
      finally
        FPeekBuffer := nil;
      end;
    end;
    //!!!e
  end;
end;

procedure TIBCustomDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  lTempCurr : System.Currency;
begin
  if (Field.DataType = ftBCD) and (Buffer <> nil) then
  begin
    BCDToCurr(TBCD(Buffer^), lTempCurr);
    InternalSetFieldData(Field, @lTempCurr);
  end
  else
    InternalSetFieldData(Field, Buffer);
end;

procedure TIBCustomDataSet.SetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean);
begin
  if (not NativeFormat) and (Field.DataType = ftBCD) then
    InternalSetfieldData(Field, Buffer)
  else
    inherited SetFieldData(Field, buffer, NativeFormat);
end;

procedure TIBCustomDataSet.DoOnNewRecord;

  procedure SetFieldsFromParams;
  var
    i : Integer;
    master_field, cur_field: TField;
  begin
    if (SQLParams.Count > 0) then
      for i := 0 to SQLParams.Count - 1 do
      begin
        master_field := FDataLink.DataSource.DataSet.FindField(SQLParams[i].Name);
        cur_field :=  FindField(SQLParams[i].Name);
        if (master_field <> nil) and (cur_field <> nil) and cur_field.IsNull then
        begin
          if (master_field.IsNull) then
            cur_field.Clear
          else
          case cur_field.DataType of
            ftBoolean, ftSmallint, ftWord, ftInteger, ftString, ftFloat, ftCurrency,
            ftBCD, ftDate, ftTime, ftDateTime:
              cur_field.Value := master_field.Value;
            ftLargeInt:
              TLargeIntField(cur_field).AsLargeInt := TLargeIntField(master_field).AsLargeInt;
          end;
        end;
      end;
  end;

begin
  if FGeneratorField.ApplyEvent = gamOnNewRecord then
    FGeneratorField.Apply;
  if FDataLink.DataSource <> nil then
    if FDataLink.DataSource.DataSet <> nil then
      SetFieldsFromParams;
  inherited DoOnNewRecord;
end;

procedure TIBCustomDataSet.CheckRequiredFields;
var
  I: Integer;
begin
  for I := 0 to Fields.Count - 1 do
    with Fields[I] do
      if Required and not ReadOnly and (FieldKind = fkData) and IsNull then
      begin
        FocusControl;
        {$IFDEF GEDEMIN}
        if (IBLogin <> nil) and IBLogin.IsIBUserAdmin then
          DatabaseErrorFmt('Поле "%s" (%s) должно быть заполнено.', [DisplayName, Origin])
        else
          DatabaseErrorFmt('Поле "%s" должно быть заполнено.', [DisplayName]);
        {$ELSE}
        DatabaseErrorFmt(SFieldRequired, [DisplayName]);
        {$ENDIF}
      end;
end;

procedure TIBCustomDataSet.CheckOperation(Operation: TDataOperation;
  ErrorEvent: TDataSetErrorEvent);
var
  Done: Boolean;
  Action: TDataAction;
begin
  Done := False;
  repeat
    try
      UpdateCursorPos;
      Operation;
      Done := True;
    except
      on E: EDatabaseError do
      begin
        Action := daFail;
        if Assigned(ErrorEvent) then ErrorEvent(Self, E, Action);
        if Action = daFail then raise;
        if Action = daAbort then SysUtils.Abort;
      end;
    end;
  until Done;
end;

procedure TIBCustomDataSet.Post;
var
  i : Integer;
begin
  if not FDataTransfer then
  begin
    if (FGeneratorField.ApplyEvent = gamOnServer) and
        FGeneratorField.IsComplete then
      FieldByName(FGeneratorField.Field).Required := false;

    if State = dsInsert then
    begin
      for i := 0 to Fields.Count - 1 do
      begin
      //!!!b
//        if (Fields[i].IsNull) and (Fields[i].DefaultExpression <> '') then
        {Исключаем keyword, которые начинаются с CURRENT_}
        if (Fields[i].IsNull) and (Fields[i].DefaultExpression <> '') and
          (AnsiPos('CURRENT_', Fields[i].DefaultExpression) <> 1) then
        try
        //!!!e
          Fields[i].Value := Fields[i].DefaultExpression;
        //!!!b
        except
        end;
        //!!!e
      end;

      if FGeneratorField.ApplyEvent = gamOnPost then
        FGeneratorField.Apply;
    end;

    //inherited Post;

    UpdateRecord;
    case State of
      dsEdit, dsInsert:
        begin
          DataEvent(deCheckBrowseMode, 0);
          { меняем местами! }
          DoBeforePost;
          {CheckRequiredFields;} {перенесено в ИнтерналПост}
          CheckOperation(InternalPost, OnPostError);
          FreeFieldBuffers;
          SetState(dsBrowse);
          //!!!b
          FSavedFlag := True;
          try
            if GetActiveBuf <> nil then
              FSavedRN := PRecordData(GetActiveBuf)^.rdRecordNumber;
          //!!!e
            Resync([]);
          //!!!b
          finally
            FSavedFlag := False;
          end;
          //!!!e
          DoAfterPost;
        end;
    end;
  end else
  begin
    //inherited Post;

    UpdateRecord;
    case State of
      dsEdit, dsInsert:
        begin
          DataEvent(deCheckBrowseMode, 0);
          { меняем местами! }
          //DoBeforePost;
          //CheckRequiredFields;
          CheckOperation(InternalPost, OnPostError);
          FreeFieldBuffers;
          SetState(dsBrowse);
          //!!!b
          FSavedFlag := True;
          try
            if GetActiveBuf <> nil then
              FSavedRN := PRecordData(GetActiveBuf)^.rdRecordNumber;
          //!!!e
            Resync([]);
          //!!!b
          finally
            FSavedFlag := False;
          end;
          //!!!e
          //DoAfterPost;
        end;
    end;
  end;
end;

procedure TIBCustomDataSet.SetGeneratorField(
  const Value: TIBGeneratorField);
begin
  FGeneratorField.Assign(Value);
end;

procedure TIBCustomDataSet.SetActive(Value: Boolean);
begin
  if (csReading in ComponentState) and
     (not (csDesigning in ComponentState)) then
    FStreamedActive := Value
  else
    inherited SetActive(Value);
end;

procedure TIBCustomDataSet.Loaded;
begin
  //!!!
  if FAllowStreamedActive then
  begin
  //!!!
  if Assigned(FBase.Database) and
      (not FBase.Database.AllowStreamedConnected) and
      (not FBase.Database.Connected) and
       FStreamedActive then
    Active := false
  else
    if FStreamedActive then
      Active := true;
  //!!!
  end;
  //!!!
  inherited Loaded;
end;

function TIBCustomDataSet.Current: TIBXSQLDA;
begin
  if not FInternalPrepared then
    InternalPrepare;
  Result := FQSelect.Current;
end;

function TIBCustomDataSet.SQLType: TIBSQLTypes;
begin
  Result := FQSelect.SQLType;
end;

function TIBCustomDataSet.GetPlan: String;
begin
  Result := FQSelect.Plan;
end;

procedure TIBCustomDataSet.CreateFields;
var
  FieldAliasName, RelationName, FieldName : String;
  i : Integer;
  f : TField;

  //!!!
  PrevRelationName: String;
  //!!!

//!!!
// Added by Golden Software
function RemoveProhibitedSymbols(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if not (S[I] in ['$', ' ']) then Result := Result + S[I]
      else Result := Result + '_';
end;
//!!!

begin
  inherited;

  //!!!
  PrevRelationName := '';
  //!!!

  for i := 0 to FQSelect.Current.Count - 1 do
    with FQSelect.Current[i].Data^ do
    begin
      { Get the field name }
      SetString(FieldAliasName, aliasname, aliasname_length);
      SetString(RelationName, relname, relname_length);
      SetString(FieldName, sqlname, sqlname_length);
      if ownname_length > 0 then // проверка должна исключить поля конструкций EXECUTE BLOCK
      begin
        f := FindField(FieldAliasname);
        if Assigned(f) then
        begin
          //!!!
          // если в запросе вытаскиваются поля из разных таблиц,
          // то скорее всего эти таблицы связаны джоинами
          // и надо рефрешить запись, чтобы вытащились правильные значения
          if not FNeedsRefresh then
          begin
            FNeedsRefresh := (PrevRelationName > '') and (RelationName <> PrevRelationName);
            PrevRelationName := RelationName;
          end;
          //!!!

          if (RelationName <> '') and (FieldName <> '') then
          begin
            f.Origin := QuoteIdentifier(FBase.Database.SQLDialect, RelationName) + '.' +
                        QuoteIdentifier(FBase.Database.SQLDialect, FieldName);

            if Database.Has_DEFAULT_VALUE(RelationName, FieldName) then
            begin
              f.DefaultExpression := Database.Get_DEFAULT_VALUE(RelationName, FieldName);

              // иногда ИБ заключает значения по умолчанию в скобки
              {$IFNDEF DEBUG}
              if (f.DataType in [ftSmallInt, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, ftLargeInt])
                and (Copy(f.DefaultExpression, 1, 1) = '(')
                and (Copy(f.DefaultExpression, Length(f.DefaultExpression), 1) = ')') then
              begin
                f.DefaultExpression := Copy(f.DefaultExpression, 2, Length(f.DefaultExpression) - 2);
              end;
              {$ENDIF}

              { TODO : такие дефаулты не обрабатываем }
             { if Pos('CURRENT_', f.DefaultExpression) = 1 then
                f.DefaultExpression := '';}
            end;

          //!!!!
          //added by Golden Software
          end else
            f.Origin := MakeFieldOrigin(FQSelect.SQL.Text, FieldAliasName,
              FBase.Database.SQLDialect);

          if f.Name = '' then
            f.Name := RemoveProhibitedSymbols(Self.Name + FieldAliasName);
          //!!!
        end;
      end;
    end;
end;

function TIBCustomDataSet.GetReadTransaction: TIBTransaction;
begin
  if FReadBase = nil then
    Result := nil
  else
    Result := FReadBase.Transaction;
end;

procedure TIBCustomDataSet.SetReadTransaction(const Value: TIBTransaction);
begin
  if not (csDestroying in ComponentState) then
  begin
    if (FReadBase.Transaction <> Value) then
    begin
      CheckDatasetClosed;
      FReadBase.Transaction := Value;
      FQRefresh.Transaction := Value;
      FQSelect.Transaction := Value;
      FReadTransactionSet := True;
    end;
  end;  
end;

procedure TIBCustomDataSet.DoAfterReadDatabaseDisconnect(Sender: TObject);
begin

end;

procedure TIBCustomDataSet.DoAfterReadTransactionEnd(Sender: TObject);
begin

end;

procedure TIBCustomDataSet.DoBeforeReadDatabaseDisconnect(Sender: TObject);
begin

end;

procedure TIBCustomDataSet.DoBeforeReadTransactionEnd(Sender: TObject);
begin
  if Active then
    Active := False;
  {
  if FQSelect <> nil then
  try
    FQSelect.FreeHandle;
  except
  end;
  }
  {if FQDelete <> nil then
    FQDelete.FreeHandle;
  if FQInsert <> nil then
    FQInsert.FreeHandle;
  if FQModify <> nil then
    FQModify.FreeHandle;}
  {
  if FQRefresh <> nil then
  try
    FQRefresh.FreeHandle;
  except
  end;
  FInternalPrepared := false;
  }
  {if Assigned(FBeforeTransactionEnd) then
    FBeforeTransactionEnd(Sender);}
end;

procedure TIBCustomDataSet.DoReadDatabaseFree(Sender: TObject);
begin
  //
end;

procedure TIBCustomDataSet.DoReadTransactionFree(Sender: TObject);
begin
  //
end;

function TIBCustomDataSet.ActivateReadTransaction: Boolean;
begin
  Result := False;
  if not Assigned(ReadTransaction) then
    IBError(ibxeTransactionNotAssigned, [nil]);
  if not ReadTransaction.Active then
  begin
    Result := True;
    ReadTransaction.StartTransaction;
  end;
end;

procedure TIBCustomDataSet.DeactivateReadTransaction;
begin
  if not Assigned(ReadTransaction) then
    IBError(ibxeTransactionNotAssigned, [nil]);
  ReadTransaction.CheckAutoStop;
end;

function TIBCustomDataSet.AllowCloseTransaction: Boolean;
begin
  Result := Transaction.InTransaction and
    (Transaction <> ReadTransaction) and (Transaction.IdleTimer = 0);
end;

procedure TIBCustomDataSet.Cancel;
var
  OldState: TDataSetState;
begin
  OldState := State;
  //!!!b
  if State = dsEdit then
  begin
    FSavedFlag := True;
    try
      FSavedRN := PRecordData(GetActiveBuf)^.rdRecordNumber;
      inherited;
    finally
      FSavedFlag := False;
    end;
  end else
  begin
  //!!!e
    if BufferCount > 1 then
    begin
      DisableControls;
      try
        inherited;
        if (OldState = dsInsert) and (FInsertedAt <> -1) and (RecordCount > 0) then
          GotoBookmark(TBookmark(@FInsertedAt));
      finally
        EnableControls;
      end;
    end else
      inherited;
  end;
end;

procedure TIBCustomDataSet.DisableScrollEvents;
begin
 Inc(FDisableScrollCount)
end;

procedure TIBCustomDataSet.EnableScrollEvents;
begin
 if FDisableScrollCount > 0 then
  Dec(FDisableScrollCount)
end;

procedure TIBCustomDataSet.DoAfterScroll;
begin
 if FDisableScrollCount = 0 then
   inherited;
end;

procedure TIBCustomDataSet.DoBeforeScroll;
begin
 if FDisableScrollCount = 0 then
   inherited;
end;

procedure TIBCustomDataSet.Sort(F: TField; const Ascending: Boolean = True);
const
  SortSubStringLength = 40;
var
  SList: TStringList;
  Buffer, Buffer2, pRec: PChar;
  OldFiltered: Boolean;
  Min, E: Double;
  I: Integer;
  WasNotNumber: Boolean;

  procedure QuickSort(SL: TStringList; iLo, iHi: Integer);
  var
    Lo, Hi: Integer;
    S, Mid: String;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := SL[(Lo + Hi) div 2];
    repeat
      while SL[Lo] < Mid do Inc(Lo);
      while SL[Hi] > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        S := SL[Lo];
        SL[Lo] := SL[Hi];
        SL[Hi] := S;

        ReadRecordCache(Lo, Buffer, False);
        ReadRecordCache(Hi, Buffer2, False);

        PRecordData(Buffer)^.rdRecordNumber := Hi;
        PRecordData(Buffer2)^.rdRecordNumber := Lo;

        WriteRecordCache(Lo, Buffer2);
        WriteRecordCache(Hi, Buffer);

        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(SL, iLo, Hi);
    if Lo < iHi then QuickSort(SL, Lo, iHi);
  end;

  procedure QuickSortDesc(SL: TStringList; iLo, iHi: Integer);
  var
    Lo, Hi: Integer;
    S, Mid: String;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := SL[(Lo + Hi) div 2];
    repeat
      while SL[Lo] > Mid do Inc(Lo);
      while SL[Hi] < Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        S := SL[Lo];
        SL[Lo] := SL[Hi];
        SL[Hi] := S;

        ReadRecordCache(Lo, Buffer, False);
        ReadRecordCache(Hi, Buffer2, False);

        PRecordData(Buffer)^.rdRecordNumber := Hi;
        PRecordData(Buffer2)^.rdRecordNumber := Lo;

        WriteRecordCache(Lo, Buffer2);
        WriteRecordCache(Hi, Buffer);

        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSortDesc(SL, iLo, Hi);
    if Lo < iHi then QuickSortDesc(SL, Lo, iHi);
  end;

begin
  Assert(Assigned(F));

  CheckBrowseMode;

  if UniDirectional then
    exit;

  DisableControls;
  DoBeforeScroll;
  DisableScrollEvents;
  try
    if FDeletedRecords > 0 then
    begin
      pRec := FBufferCache;
      I := 0;
      while (I < FRecordCount) and (FDeletedRecords > 0) do
      begin
        if PRecordData(pRec).rdUpdateStatus = usDeleted then
        begin
          Dec(FRecordCount);
          Move(pRec[FRecordBufferSize], pRec^, FRecordCount - I);
          Dec(FDeletedRecords);
        end else
        begin
          Inc(pRec, FRecordBufferSize);
          Inc(I);
        end;
      end;
      FCurrentRecord := -1;
    end;

    SList := TStringList.Create;

    {$IFDEF HEAP_STRING_FIELD}
    Buffer := nil;
    Buffer2 := nil;
    IBAlloc(Buffer, 0, FRecordBufferSize);
    IBAlloc(Buffer2, 0, FRecordBufferSize);
    {$ELSE}
    GetMem(Buffer, FRecordBufferSize);
    GetMem(Buffer2, FRecordBufferSize);
    {$ENDIF}

    OldFiltered := Filtered;
    if Filtered then
      Filtered := False;
    Min := 0;
    WasNotNumber := False;
    try
      Last;

      First;
      while not EOF do
      begin
        case F.DataType of
          ftDate: SList.Add(FormatDateTime('yyyymmdd', F.AsDateTime));
          ftTime: SList.Add(FormatDateTime('hhnnss'{zzz}, F.AsDateTime));
          ftDateTime: SList.Add(FormatDateTime('yyyymmddhhnnss'{zzz}, F.AsDateTime));
          ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeInt:
          begin
            SList.Add(FormatFloat('0000000000000000.0000', F.AsFloat));
            if F.AsFloat < Min then
              Min := F.AsFloat;
          end;
        else
          SList.Add(AnsiUpperCase(Copy(F.AsString, 1, SortSubStringLength)));
          if not WasNotNumber then
            try
              StrToFloat(AnsiUpperCase(Copy(F.AsString, 1, SortSubStringLength)));
            except
              WasNotNumber := True;
            end;
        end;
        Next;
      end;

      if SList.Count > 0 then
      begin
        if (F.DataType = ftString) and (not WasNotNumber) then
        begin
          for I := 0 to SList.Count - 1 do
          begin
            E := StrToFloat(SList[I]);
            SList[I] := FormatFloat('0000000000000000.0000', E);
            if E < Min then
              Min := E;
          end;
        end;

        if Min < 0 then
        begin
          Min := Min - 1; // для того чтобы избежать всяких ошибок с округлениями флоатов
          for I := 0 to SList.Count - 1 do
          begin
            SList[I] := FormatFloat('0000000000000000.0000', StrToFloat(SList[I]) - Min);
          end;
        end;

        if Ascending then
          QuickSort(SList, 0, SList.Count - 1)
        else
          QuickSortDesc(SList, 0, SList.Count - 1)
      end;

      {$IFNDEF NEW_GRID}
      FSortField := F.FieldName;
      FSortAscending := Ascending;
      {$ENDIF}

    finally
      FreeMem(Buffer, FRecordBufferSize);
      FreeMem(Buffer2, FRecordBufferSize);
      SList.Free;

      if Filtered <> OldFiltered then
        Filtered := OldFiltered;

      FCurrentRecord := 0;
      Resync([]);
    end;
  finally
    EnableControls;
    EnableScrollEvents;
    DoAfterScroll;
  end;
end;

{$IFDEF NEW_GRID}

procedure TIBCustomDataSet.Sort2(BeforeGroup: Boolean = True);
var
  TempBuff: Pointer;
  ControlsDisabled: Boolean;

  function Compare(const A, B: Integer): Integer;
  var
    I: Integer;
    TempF: Double;
    TempS: String;
    Fld: TField;
    ADel, BDel: Boolean;
    AVirt, BVirt: Boolean;
  begin
    Result := 0;
    TempF := 0;  TempS := '';
    ADel := false;  BDel := false;
    AVirt := false; BVirt := false;
    for I := 0 to FGroupSortFields.Count - 1 do
    begin
      Fld := (FGroupSortFields[I]).Field;

      FPeekBuffer := FBufferCache + A * FRecordBufferSize;

      if BeforeGroup then
        if PRecordData(FPeekBuffer)^.rdRecordKind = rkHiddenRecord then
          PRecordData(FPeekBuffer)^.rdRecordKind := rkRecord;

      if not (PRecordData(FPeekBuffer)^.rdRecordKind in [rkRecord, rkHiddenRecord]) then
        AVirt := True;

      if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
        ADel := True;

      case Fld.DataType of
        ftDate, ftTime, ftDateTime,
        ftSmallInt, ftInteger, ftWord,
        ftCurrency,
        ftFloat, ftBCD, ftLargeInt: TempF := Fld.AsFloat;
      else
        TempS := Fld.AsString;
      end;

      FPeekBuffer := FBufferCache + B * FRecordBufferSize;

      if not (PRecordData(FPeekBuffer)^.rdRecordKind in [rkRecord, rkHiddenRecord]) then
        BVirt := True;

      if AVirt or BVirt then
        if BeforeGroup then begin
          if AVirt and not BVirt then
            Result := 1
          else if not AVirt and BVirt then
            Result := -1;
          exit;
        end else begin
          if not (FGroupSortFields[I].GroupSortOrder in [gsoGroupAsc, gsoGroupDesc]) then begin
            if AVirt and not BVirt then
              Result := -1
            else if not AVirt and BVirt then
              Result := 1;
            exit;
          end;
        end;

      if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
        BDel := True;

      if ADel or BDel then begin
        if ADel and not BDel then
          Result := 1
        else if not ADel and BDel then
          Result := -1
        else if ADel and BDel then
          Result := 0;
        exit;
      end;

      case Fld.DataType of
        ftDate, ftTime, ftDateTime,
        ftSmallInt, ftInteger, ftWord, ftLargeInt,
        ftCurrency, ftFloat, ftBCD:
        begin                      {??}
          if TempF < Fld.AsFloat then
          begin
            if (FGroupSortFields[I]).GroupSortOrder in [gsoGroupAsc, gsoSortAsc] then
              Result := -1
            else
              Result := 1;
            exit;
          end else if TempF > Fld.AsFloat then
          begin
            if (FGroupSortFields[I]).GroupSortOrder in [gsoGroupAsc, gsoSortAsc] then
              Result := 1
            else
              Result := -1;
            exit;
          end;
        end;
      else
        begin
          Result := AnsiCompareText(TempS, Fld.AsString);

          if (FGroupSortFields[I]).GroupSortOrder in [gsoGroupDesc, gsoSortDesc] then
            Result := Result * -1;

          if Result <> 0 then
            exit;
        end;
      end;
    end;    {  for I:=0  }

    if AVirt and not BVirt then
       Result := -1
    else if not AVirt and BVirt then
       Result := 1;

  end;  {  function Compare  }
  procedure QuickSort(iLo, iHi: Integer);
  var
    Lo, Hi, Mid: Integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := (Lo + Hi) div 2;
    repeat
      while Compare(Lo, Mid) < 0 do Inc(Lo);
      while Compare(Hi, Mid) > 0 do Dec(Hi);

      if Lo <= Hi then
      begin
        if (Lo <> Hi) and (Compare(Lo, Hi) <> 0) then
        begin
          Move((FBufferCache + Lo * FRecordBufferSize)^, TempBuff^, FRecordBufferSize);
          Move((FBufferCache + Hi * FRecordBufferSize)^, (FBufferCache + Lo * FRecordBufferSize)^, FRecordBufferSize);
          Move(TempBuff^, (FBufferCache + Hi * FRecordBufferSize)^, FRecordBufferSize);

          PRecordData(FBufferCache + Hi * FRecordBufferSize)^.rdRecordNumber := Hi;
          PRecordData(FBufferCache + Lo * FRecordBufferSize)^.rdRecordNumber := Lo;

          if Mid = Lo then Mid := Hi
            else if Mid = Hi then Mid := Lo;
        end;

        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(iLo, Hi);
    if Lo < iHi then QuickSort(Lo, iHi);
  end;
{  Sort2  }
Var I: Integer;
begin
  CheckBrowseMode;

  if UniDirectional or (FRecordCount < 2) or (FGroupSortFields = nil)
    or (FGroupSortFields.Count = 0) then
  begin
    exit;
  end;

  ControlsDisabled := not FQSelect.EOF;
  if ControlsDisabled then
    DisableControls;

  GetMem(TempBuff, FRecordBufferSize);
  try
    if ControlsDisabled then
      Last;
    try
      QuickSort(0, FRecordCount - 1);
    finally
      FPeekBuffer := nil;
    end;

    FCurrentRecord := -1;
    Resync([]);
  finally
    FreeMem(TempBuff, FRecordBufferSize);
    for I := FRecordCount - 1 downto 0 do
      if (PRecordData(FBufferCache+I*_RecordBufferSize)^.rdRecordKind
        in [rkRecord, rkHiddenRecord]) then
      begin
        FRecordCount := I + 1;
        break;
      end;
    if ControlsDisabled then
      EnableControls;
  end;
end;

procedure TIBCustomDataSet.ClearGroupSort;
begin
  FreeAndNil(FFormulaFields);
  FreeAndNil(FGroupSortFields);
end;

procedure TIBCustomDataSet.SortGroupSortAtField(F: TField);
var
  I: Integer; FG: TGroupSortField;
  isClearGroupSort: boolean;
begin
  if (F = nil) or (F.DataSet <> Self) then
    raise Exception.Create('Invalid field specified.');

  if not Assigned(FGroupSortFields) then begin
    AddGroupSortField(F, gsoSortAsc, 1, dsType, '');
    Sort2;
  end else begin
   for I := 0 to FGroupSortFields.Count - 1 do begin
    FG := FGroupSortFields[I] as TGroupSortField;
    if (FG.GroupSortOrder in [gsoGroupAsc, gsoGroupDesc]) then
    exit; { Еесли группировка, то далее и не пытаемся сортировать }
   end;

   //если клик по полю не в тек.сортировке, то только оно будет в новой сортировке
   isClearGroupSort := True;
   for I := 0 to FGroupSortFields.Count - 1 do begin
    FG := FGroupSortFields[I] as TGroupSortField;
    if (FG.Field = F) then begin
      if (FG.GroupSortOrder = gsoSortAsc) then
        FG.FGroupSortOrder := gsoSortDesc
      else
        FG.FGroupSortOrder := gsoSortAsc;
      isClearGroupSort := false;
    end;
   end;
   if isClearGroupSort then begin
    ClearGroupSort;
    AddGroupSortField(F, gsoSortAsc, 1, dsType, '');
   end;
   Sort2;
  end;
end;  {  --  procedure TIBCustomDataSet.SortGroupSortAtField  --  }

procedure TIBCustomDataSet.AddGroupSortField(F: TField; const AGroupSortOrder: TGroupSortOrder;
  AIntScale: Integer; ADateScale: TDateScale; AStrScale: string);
var
  I: Integer;
begin
  if (F = nil) or (F.DataSet <> Self) then
    raise Exception.Create('Invalid field specified.');

  if FGroupSortFields = nil then
    FGroupSortFields := TGroupSortFields{TObjectList}.Create(True);

  for I := 0 to FGroupSortFields.Count - 1 do
  begin
    if (FGroupSortFields[I]).Field = F then
      raise Exception.Create('Field is already specified for grouping or sorting.');
  end;

  FGroupSortFields.Add(TGroupSortField.Create(F, AGroupSortOrder,
    AIntScale, ADateScale, AStrScale) );
end;

procedure TIBCustomDataSet.AddFormulaField(F: TField; const AFormula: String);
begin
  if (F = nil) or (F.DataSet <> Self) then
    raise Exception.Create('Invalid field specified.');
  //-~/if (F.DataType = ftString) then
  //-~/  raise Exception.CreateFmt('Invalid datatype field %s specified.', [F.FieldName]);

  if FFormulaFields = nil then
    FFormulaFields := TFormulaFields{TObjectList}.Create(False)
  else
    FFormulaFields.Remove(F);

  FFormulaFields.Add(TGroupAgg.Create(F, AFormula));
end;

function TIBCustomDataSet.GetFormulaByField(F: TField): string;
var J: integer;
begin
   result := '';
   if FFormulaFields <> nil then
     for J := 0 to FFormulaFields.Count - 1 do begin
       if ((FFormulaFields[J]).Field = F) then begin
         result := (FFormulaFields[J]).GetFuncAsStr;
         break;
       end;
     end;
end;

function TIBCustomDataSet.GroupSortExist: Boolean;
begin
  Result := Assigned(GroupSortFields)
        and (FGroupSortFields.Count > 0);
end;

function TIBCustomDataSet.IsGroupSortField(F: TField; OnlyGroup: Boolean = false): Boolean;
var
  I: Integer;
begin
  Result := False;
  if FGroupSortFields <> nil then
  begin
    for I := 0 to FGroupSortFields.Count - 1 do
    begin
      if (FGroupSortFields[I].Field = F) then
      begin
        if OnlyGroup and not (FGroupSortFields[I].FGroupSortOrder
          in [gsoGroupAsc, gsoGroupDesc]) then
            continue;
        Result := True;
        break;
      end;
    end;
  end;
end;

function TIBCustomDataSet.IsGroupSortFieldAsc(F: TField): Boolean;
var
  I: Integer;
begin
  Result := False;
  if FGroupSortFields <> nil then
  begin
    for I := 0 to FGroupSortFields.Count - 1 do
    begin
      if (FGroupSortFields[I].Field = F)
        and (FGroupSortFields[I].FGroupSortOrder in [gsoGroupAsc, gsoSortAsc]) then
      begin
        Result := True;
        break;
      end;
    end;
  end;
end;

procedure TIBCustomDataSet.UnGroup(BeforeGroup: Boolean);
var
  I, II, G: Integer;
  //NewCacheSize: Integer;
  OldPseudoRecordsOn: Boolean;
begin
  {надо бы уменьшить при необходимости прoверить размер FBufferCache}
  if FRecordCount < 1
    then exit;

  if not BeforeGroup then begin
    DisableControls;
    FDataTransfer := True;
    OldPseudoRecordsOn := FPseudoRecordsOn;
    FPseudoRecordsOn := True;
  end;

  try
    G := 0; II := 1;
    I := -1;
    repeat
      Inc(I);
      FPeekBuffer := FBufferCache + I * _RecordBufferSize;

      if (PRecordData(FPeekBuffer)^.rdRecordKind in [rkHeader, rkGroup, rkFooter, rkHiddenFooter])
        or (I = FRecordCount) then
      begin
       if (I > 0) and (G > 0) then begin
         Move( (FBufferCache + II * _RecordBufferSize)^,
           (FBufferCache + (II - G) * _RecordBufferSize)^,
           (I - II) * _RecordBufferSize);
       end;
       if (I < FRecordCount) then begin
         II := I + 1; Inc(G);
       end;
      end else begin                                  { TODO : DBG1 UnGroup}
        if (PRecordData(FPeekBuffer)^.rdRecordKind in [rkHiddenRecord{, rkHeaderRecord}]) then
          PRecordData(FPeekBuffer)^.rdRecordKind := rkRecord;
      end;
    until (I >= FRecordCount);

    if G > 0 then
      Dec(FRecordCount, G);

    FPeekBuffer := FBufferCache;
    for I := 0 to FRecordCount - 1 do
    begin
      PRecordData(FPeekBuffer)^.rdRecordNumber := I;
      Inc(FPeekBuffer, _RecordBufferSize);
    end;

    if not BeforeGroup then begin
      FSavedRecordCount := -1;
      FCurrentRecord := -1;
      Resync([]);
    end;
  finally
    FPeekBuffer := nil;
    if not BeforeGroup then begin
      FDataTransfer := false;
      EnableControls;
{$WARNINGS OFF}
      FPseudoRecordsOn := OldPseudoRecordsOn;
    end;
  end;
end;
{$WARNINGS ON}

procedure TIBCustomDataSet.Group;
var
  CurrValue: array[0..63] of Variant;
  CurrInt: LongInt;
  CurrDate: TDateTime;
  CurrStr: string;
  CountGroupFields: Integer;
  G : Integer;
  // RecInGroup : Integer;
  procedure ClearAggregates;
  var
    I: Integer;
  begin
    if FFormulaFields <> nil then
      for I := 0 to FFormulaFields.Count - 1 do
        (FFormulaFields[I]).Clear;
  end;

  procedure CalcAggregates;
  var
    I: Integer;
  begin
    if FFormulaFields <> nil then
      for I := 0 to FFormulaFields.Count - 1 do
        (FFormulaFields[I]).Calc;
  end;

  procedure AssignAggregates;
  var
    I: Integer;
  begin
    if FFormulaFields <> nil then
      for I := 0 to FFormulaFields.Count - 1 do
        (FFormulaFields[I] as TGroupAgg).Assign;
  end;

  procedure doNewCacheSize;
  var
    NewCacheSize: Integer;
  begin
    NewCacheSize := FCacheSize + _RecordBufferSize * 1024;
    IBAlloc(FBufferCache, NewCacheSize, NewCacheSize);
    FCacheSize := NewCacheSize;
  end;

  function DataTypeIsInt(F: TField): Boolean;
  begin
    result := F.DataType in [ftInteger, ftSmallint, ftWord, ftLargeint, ftFloat,
      ftCurrency, ftBCD];
  end;
  function DataTypeIsDateTime(F: TField): Boolean;
  begin
    result := F.DataType in [ftDate, ftDateTime , ftTime];
  end;
  function DataTypeIsStr(F: TField): Boolean;
  begin
    result := F.DataType in [ftString];
  end;

  function IsIntScale(I: Integer): Boolean;
  begin
    Result := (FGroupSortFields[I].Field.DataType in [ftInteger, ftSmallint, ftWord, ftLargeint, ftFloat,
      ftCurrency, ftBCD]) and (FGroupSortFields[I].FIntScale <> 1);
  end;
  function IsDateScale(I: Integer): Boolean;
  begin
    Result := (FGroupSortFields[I].Field.DataType in [ftDate, ftDateTime {, ftTime,}])
      and (FGroupSortFields[I].FDateScale <> dsType);
  end;
  function IsStrScale(I: Integer): Boolean;
  begin
    Result := (FGroupSortFields[I].Field.DataType in [ftString])
      and (FGroupSortFields[I].FStrScale <> '');
  end;

  function DateScaleBeg(DateA: TDateTime; ADateScale: TDateScale): TDateTime;
  var
   Year, Month, Day: Word;
  begin
    Result := DateA;

    DecodeDate(DateA, Year, Month, Day);

    case ADateScale of
      dsDay:  Result := EncodeDate(Year, Month, Day);
      dsWeek: begin
           Result := EncodeDate( Year, Month, Day);
           while DayofWeek(Result) <> 2 do Result := Result - 1;
         end;
      dsMonth: Result :=  EncodeDate( Year, Month, 1);
      dsQuartal: begin
           Month := ((Month - 1) div 3) * 3  + 1;
           Result := EncodeDate( Year, Month, 1);
         end;
      dsYear: Result := EncodeDate( Year, 1, 1);
    end;
  end;

  procedure SetCurrValue;
  var K: Integer;
  begin
    for K := 0 to CountGroupFields - 1 do
    with FGroupSortFields[K] do begin
      CurrValue[K] := FGroupSortFields[K].Field.AsVariant;

      if VarIsNull(CurrValue[K]) then
        if DataTypeIsInt(FGroupSortFields[K].Field) then
          CurrValue[K] := 0
        else if DataTypeIsDateTime(FGroupSortFields[K].Field) then
          CurrValue[K] := 0
        else if DataTypeIsStr(FGroupSortFields[K].Field) then
          CurrValue[K] := '';

      if IsIntScale(K) then begin
        if VarIsNull(CurrValue[K]) then
          CurrInt := 0
        else
          CurrInt := (Trunc(Float(CurrValue[K])) div FIntScale) * FIntScale;
        CurrValue[K] := CurrInt;
      end;

      if IsDateScale(K) then begin
        if VarIsNull(CurrValue[K]) then
          CurrDate := 0
        else begin
          CurrDate := DateScaleBeg(VarToDateTime(CurrValue[K]), FDateScale);
        end;
        CurrValue[K] := CurrDate;
      end;

      if IsStrScale(K) then begin
        if VarIsNull(CurrValue[K]) then
          CurrStr := ''
        else begin
          CurrStr := FStrScale;
        end;
        CurrValue[K] := CurrStr;
      end;

   end;  {  --  for K := 0 -- }
 end;

 function CurrValueChanged: Boolean;
 var
   J: Integer;
   TempVal: Variant;
 begin
   Result := false;
   for J := 0 to CountGroupFields - 1 do
   with FGroupSortFields[J] do begin
     //F := FGroupSortFields[J].Field;
     if Field.IsNull then begin
       if DataTypeIsInt(Field) then
         TempVal := 0
       else if DataTypeIsDateTime(Field) then
         TempVal := 0
       else if DataTypeIsStr(Field) then
         TempVal := ''
     end else
       TempVal := Field.Value;

     if IsIntScale(J) then begin
       CurrInt := (Trunc(Field.AsFloat) div FIntScale) * FIntScale;
       Result := (CurrValue[J] <> CurrInt);
     end else if IsDateScale(J) then begin
       if VarIsNull(CurrValue[J]) then
         CurrDate := 0
       else begin
         CurrDate := DateScaleBeg(Field.asDateTime, FDateScale);
       end;
       Result := (CurrValue[J] <> CurrDate);
     end else begin
       if DataTypeIsStr(Field) then
         Result := AnsiCompareText(CurrValue[J], Field.AsString) <> 0
       else
         Result := (CurrValue[J] <> TempVal{Field.AsVariant});
     end;

     if Result then
       break;
   end;
 end;
{  TIBCustomDataSet.Group  }
var
  I, D, K : Integer;
  First: Boolean;
  AcceptFilter: Boolean;
  II{CurrGroupOffset}: Integer;
  {CountByteGroup: Integer;}
  FormulaPresent: Boolean;
  OldPseudoRecordsOn: Boolean;
begin
  CheckBrowseMode;

  if UniDirectional or (FRecordCount < 1) then begin
    exit;
  end;

  DisableControls;
  FDataTransfer := True;
  OldPseudoRecordsOn := FPseudoRecordsOn;
  FPseudoRecordsOn := True;
  try
    UnGroup(True);{ TODO : DBG7 Group}
    Sort2;

    if (FGroupSortFields = nil) or (FGroupSortFields.Count = 0) then begin
     FSavedRecordCount := -1;
     FCurrentRecord := -1;
     Resync([]);
     exit; //сделать потом без этого выхода
    end;

    CountGroupFields := 0;
    for I := 0 to FGroupSortFields.Count - 1 do
    begin
      if (FGroupSortFields[I]).GroupSortOrder in [gsoGroupAsc, gsoGroupDesc] then
        CountGroupFields := I + 1
      else
        break;
    end;
    if CountGroupFields = 0 then
      exit; //dbg//

    for I := 0 to CountGroupFields - 1 do
       CurrValue[I] := Unassigned;

  First := false;
  //Подготоавляваем буфер
    if FCacheSize < _RecordBufferSize * (FRecordCount + 1024 + 1) then
      doNewCacheSize;
  // Для того, чтобы последняя запись не "прилипала" к пред. группе добавляем
  // в конец буфера запись и заполняем группировочные поля значениями из 1-й записи
    FPeekBuffer := FBufferCache + (FRecordCount) * _RecordBufferSize;
    Move(FModelBuffer^, FPeekBuffer^, _RecordBufferSize);
  // Делаем наверху пузырь-прослойку между отгруппированными и необработанными записями
    FPeekBuffer := FBufferCache;
    Move(FPeekBuffer^, FPeekBuffer[1024*_RecordBufferSize], (FRecordCount+1)*_RecordBufferSize); //PRecordData(FPeekBuffer)^.rdRecordKind := rkGhost;
  // Сдвиг на обрабатываемеые(неотгруппированные) записи
    D := 1024;
  // Текущая записиь, номер записи текущей группы, количество групп
    I := -1; II := 0; G := 0;
    repeat
      Inc(I);
      //переводим указатель на текущую запись
      FPeekBuffer := FBufferCache + (I + D)*_RecordBufferSize;

      if (I < FRecordCount) then begin

        if PRecordData(FPeekBuffer)^.rdUpdateStatus = usDeleted then
          continue;

        if Filtered and Assigned(OnFilterRecord) then
        begin
          PRecordData(FPeekBuffer)^.rdRecordGroupFiltered := false;
          AcceptFilter := True;
          OnFilterRecord(Self, AcceptFilter);
          if not AcceptFilter then
            continue;
         PRecordData(FPeekBuffer)^.rdRecordGroupFiltered := false;
        end;

        GetCalcFields(FPeekBuffer);
      end;

      if not First then begin
        ClearAggregates;
        SetCurrValue;
        First := True;
      end;

      if I > 0 then
      begin
        if (I = FRecordCount) or CurrValueChanged then
        begin { окончание группы }

          if (G = D) then begin
            if FCacheSize < _RecordBufferSize * (FRecordCount + (D + 1024)) then
              doNewCacheSize;
            FPeekBuffer := FBufferCache + (II + D) * _RecordBufferSize;
            Move(FPeekBuffer^, FPeekBuffer[1024*_RecordBufferSize], (FRecordCount + 1 - II) *_RecordBufferSize);
            Inc(D, 1024);
            FPeekBuffer := FBufferCache + (I + D) * _RecordBufferSize;
          end;

          FormulaPresent := (FFormulaFields <> nil)
            and (FFormulaFields.Count > 0) {and (RecInGroup > -1)};
                     { TODO : DBG8 Group}
          //RecInGroup := I - II;
          //CountByteGroup := (FRecordCount + 1 - II) * _RecordBufferSize;
          if (G + 1) < D then
            Move( (FBufferCache + (II + D) * _RecordBufferSize)^,
                  (FBufferCache + (II + G + 1) * _RecordBufferSize)^, //PeekBuffer[_RecordBufferSize],
                  (I - II) * _RecordBufferSize)
          else
            { пропускаем, так как это перемещение на 0 байт, источник и назначение одинаковы };

          FPeekBuffer := FBufferCache + (II + G) * _RecordBufferSize;
          Move(FModelBuffer^, FPeekBuffer^, _RecordBufferSize);
          PRecordData(FPeekBuffer)^.rdRecordKind := rkHeader;
          for K := 0 to CountGroupFields - 1 do begin
            FGroupSortFields[K].Field.AsVariant := CurrValue[K];
          end;

          if FormulaPresent then
            AssignAggregates;

          PRecordData(FPeekBuffer)^.rdRecordGroupFiltered := True;
          inc(G);  //Inc(FRecordCount); Inc(I);
          {end else
          if RecInGroup = 1 then
            PRecordData(FPeekBuffer)^.rdRecordKind := rkHeaderRecord;}

          if (I < FRecordCount) then begin
            FPeekBuffer := FBufferCache + (I + D)* _RecordBufferSize;
            ClearAggregates;
            SetCurrValue;
            II := I;
          end;

      end; {if} {окончание группы}
     end;  {if} {else}{I = 0}

     if (I < FRecordCount) then
       CalcAggregates;
     Application.ProcessMessages;
    until (I + 1) > FRecordCount;

    if G>0 then
      Inc(FRecordCount, G);

    FPeekBuffer := FBufferCache;
    for K := 0 to FRecordCount - 1 do
    begin
                {  изначально все группы сворачиваем  }
      if PRecordData(FPeekBuffer)^.rdRecordKind = rkHeader then
        PRecordData(FPeekBuffer)^.rdRecordKind := rkGroup;
      if PRecordData(FPeekBuffer)^.rdRecordKind = rkRecord then
        PRecordData(FPeekBuffer)^.rdRecordKind := rkHiddenRecord;
      if PRecordData(FPeekBuffer)^.rdRecordKind = rkFooter then
        PRecordData(FPeekBuffer)^.rdRecordKind := rkHiddenFooter;

      PRecordData(FPeekBuffer)^.rdRecordNumber := K;
      Inc(FPeekBuffer, _RecordBufferSize);
    end;
    FPeekBuffer := nil;

    FSavedRecordCount := -1;
    FCurrentRecord := -1;
    Resync([]);
    //Sort2(false);
  finally
    FDataTransfer := False;
    FPeekBuffer := nil;
    EnableControls;
    FPseudoRecordsOn := OldPseudoRecordsOn;
  end;
end;     {  --  procedure TIBCustomDataSet.Group  --  }

procedure TIBCustomDataSet.InternalWrapGroup(P: PChar);
var
  PG, OldPeekBuffer: PChar;
  V: Variant;
  I: Integer;
begin
  if PRecordData(P)^.rdRecordKind = rkHeader then
  begin
    PRecordData(P)^.rdRecordKind := rkGroup;
    PG := P;
    Inc(P, _RecordBufferSize);
    while (P < FBufferCache + FRecordCount * _RecordBufferSize)
      and (PRecordData(P)^.rdRecordKind in [rkRecord]) do
    begin
      PRecordData(P)^.rdRecordKind := rkHiddenRecord;
      Inc(P, _RecordBufferSize);
    end;
    if (P < FBufferCache + FRecordCount * _RecordBufferSize)
      and (PRecordData(P)^.rdRecordKind in [rkFooter]) then
    begin
      PRecordData(P)^.rdRecordKind := rkHiddenFooter;

      FDataTransfer := True;
      OldPeekBuffer := FPeekBuffer;
      try
        if FFormulaFields <> nil then
        begin
          for I := 0 to FFormulaFields.Count - 1 do
          begin
            FPeekBuffer := P;
            V := (FFormulaFields[i]).Field.Value;
            FPeekBuffer := PG;
            (FFormulaFields[i] as TGroupAgg).Field.Value := V;
          end;
        end;
      finally
        FPeekBuffer := OldPeekBuffer;
        FDataTransfer := False;
      end;
    end;
  end
  else if PRecordData(P)^.rdRecordKind = rkGroup then
  begin
    PRecordData(P)^.rdRecordKind := rkHeader;

    FDataTransfer := True;
    OldPeekBuffer := FPeekBuffer;
    try
      if FFormulaFields <> nil then
      begin
        FPeekBuffer := P;
        for I := 0 to FFormulaFields.Count - 1 do
        begin
          //(FFormulaFields[i]).Field.Clear;
        end;
      end;
    finally
      FPeekBuffer := OldPeekBuffer;
      FDataTransfer := False;
    end;

    Inc(P, _RecordBufferSize);
    while (P < FBufferCache + FRecordCount * _RecordBufferSize)
      and (PRecordData(P)^.rdRecordKind in [rkHiddenRecord]) do
    begin
      PRecordData(P)^.rdRecordKind := rkRecord;
      Inc(P, _RecordBufferSize);
    end;
    if (P < FBufferCache + FRecordCount * _RecordBufferSize)
      and (PRecordData(P)^.rdRecordKind in [rkHiddenFooter]) then
    begin
      PRecordData(P)^.rdRecordKind := rkFooter;
    end;
  end;
end;               {  --  TIBCustomDataSet.InternalWrapGroup  --  }

procedure TIBCustomDataSet.WrapGroup;
var
  P: PChar;
  OldPseudoRecordsOn: Boolean;
begin
  OldPseudoRecordsOn := FPseudoRecordsOn;
  FPseudoRecordsOn := True;
  try
    P := ActiveBuffer;
    if P <> nil then
    begin
      InternalWrapGroup(FBufferCache + PRecordData(P)^.rdRecordNumber * _RecordBufferSize);
      InternalSetToRecord(ActiveBuffer);
    end;
    FSavedRecordCount := -1;
    Resync([rmExact]);
    if not OldPseudoRecordsOn
      and (PRecordData(ActiveBuffer)^.rdRecordKind = rkHeader) then
        Next;
  finally
    { TODO : ^^^^ WrapGroup}
    FPseudoRecordsOn := OldPseudoRecordsOn;
  end;
end;

procedure TIBCustomDataSet.WrapAllGroups;
var
  P: PChar;
  OldPseudoRecordsOn: Boolean;
begin
  OldPseudoRecordsOn := FPseudoRecordsOn;
  FPseudoRecordsOn := True;
  try
    P := FBufferCache;
    while P < FBufferCache + FRecordCount * _RecordBufferSize do
    begin
      if PRecordData(P)^.rdRecordKind = rkHeader then
      begin
        InternalWrapGroup(P);
      end;
      Inc(P, _RecordBufferSize);
    end;

    FCurrentRecord := -1;
    FSavedRecordCount := -1;
    Resync([]);
  finally
    FPseudoRecordsOn := OldPseudoRecordsOn;
  end;
end;

procedure TIBCustomDataSet.UnWrapAllGroups;
var
  P: PChar;
  OldPseudoRecordsOn: Boolean;
begin
  OldPseudoRecordsOn := FPseudoRecordsOn;
  FPseudoRecordsOn := True;
  try
    P := FBufferCache;
    while P < FBufferCache + FRecordCount * _RecordBufferSize do
    begin
      if PRecordData(P)^.rdRecordKind = rkGroup then
      begin
        InternalWrapGroup(P);
      end;
      Inc(P, _RecordBufferSize);
    end;

    FCurrentRecord := -1;
    FSavedRecordCount := -1;
    Resync([]);
  finally
    FPseudoRecordsOn := OldPseudoRecordsOn;
  end;
end;

function TIBCustomDataSet.GetDateScale(const Txt: string): TDateScale;
var I: TDateScale;
begin
  Result := dsType;
  for I := dsType to dsYear do
    if AnsiUpperCase(ArDateScale[I]) = AnsiUpperCase(Txt) then
      Result := I;
end;

{$ENDIF}

procedure TIBCustomDataSet.ResetAllAggs(AnActive: Boolean; BL: TBookmarkList);
var
  J, I: Integer;
  Accept, OldModified: Boolean;
  SaveState: TDataSetState;
  F: TField;
  V: Variant;
begin
  for J := 0 to FAggregates.Count - 1 do
  begin
    if FAggregates[J].DataType in [ftSmallInt, ftInteger, ftWord, ftCurrency, ftBCD] then
      FAggregates[J].SetValue(0.0)
    else
      FAggregates[J].SetValue(VarAsType(0.0, varDouble));
  end;

  FAggregatesObsolete := False;

  if not AnActive then
    exit;

  OldModified := Modified;
  SaveState := SetTempState(dsFilter);
  try
    if (BL = nil) or (BL.Count < 2) then
    begin
      for I := 0 to FRecordCount - 1 do
      begin
        FFilterBuffer := FBufferCache + I * _RecordBufferSize;
        FPeekBuffer := FFilterBuffer;

        {$IFDEF NEW_GRID}
        if not (PRecordData(FPeekBuffer)^.rdRecordKind
                in [rkRecord,rkHiddenRecord,rkHeaderRecord]) then
          continue;
        {$ENDIF}

        if PRecordData(FFilterBuffer)^.rdUpdateStatus = usDeleted then
          continue;

        if Assigned(OnCalcAggregates) then
        begin
          Accept := True;
          OnCalcAggregates(Self, Accept);
          if not Accept then
            continue;
        end;

        if Filtered and Assigned(OnFilterRecord) then
        begin
          Accept := True;
          OnFilterRecord(Self, Accept);
          if not Accept then
            continue;
        end;

        GetCalcFields(FPeekBuffer);

        for J := 0 to FAggregates.Count - 1 do
        begin
          F := FindField(FAggregates[J].Expression);

          if (F <> nil) and (not F.IsNull) then
          begin
            //Если поле имеет тип TLargeintField, то кидает ошибку unknown variant type 14
            //Посмотреть можно если построить журнал ордер на нашей базе
            //кол-во символов после запятой 0
            if F is TLargeintField then
            begin
              V := F.AsString;
              FAggregates[J].SetValue(FAggregates[J].Value + V);
            end else
              FAggregates[J].SetValue(FAggregates[J].Value + F.Value);
          end;
        end;
      end;
    end else
    begin
      for I := 0 to BL.Count - 1 do
      begin
        FFilterBuffer := FBufferCache + PInteger(BL[I])^ * _RecordBufferSize;
        FPeekBuffer := FFilterBuffer;

        {$IFDEF NEW_GRID}
        if not (PRecordData(FPeekBuffer)^.rdRecordKind
                in [rkRecord,rkHiddenRecord,rkHeaderRecord]) then
          continue;
        {$ENDIF}

        if PRecordData(FFilterBuffer)^.rdUpdateStatus = usDeleted then
          continue;

        if Assigned(OnCalcAggregates) then
        begin
          Accept := True;
          OnCalcAggregates(Self, Accept);
          if not Accept then
            continue;
        end;

        if Filtered and Assigned(OnFilterRecord) then
        begin
          Accept := True;
          OnFilterRecord(Self, Accept);
          if not Accept then
            continue;
        end;

        GetCalcFields(FPeekBuffer);

        for J := 0 to FAggregates.Count - 1 do
        begin
          F := FindField(FAggregates[J].Expression);
          if (F <> nil) and (not F.IsNull) then
          begin
            //Если поле имеет тип TLargeintField, то кидает ошибку unknown variant type 14
            //Посмотреть можно если построить журнал ордер на нашей базе
            //кол-во символов после запятой 0
            if F is TLargeintField then
            begin
              V := F.AsString;
              FAggregates[J].SetValue(FAggregates[J].Value + V);
            end else
              FAggregates[J].SetValue(FAggregates[J].Value + F.Value);
          end;
        end;
      end;
    end;
  finally
    FPeekBuffer := nil;
    RestoreState(SaveState);
    SetModified(OldModified);
  end;
end;

procedure TIBCustomDataSet.SetAggregatesActive(const Value: Boolean);
begin
  FAggregatesActive := Value;
end;

procedure TIBCustomDataSet.FinalizeRecordBuffer(Buffer: Pointer);
{$IFDEF HEAP_STRING_FIELD}
var
  I: Integer;
begin
  if Buffer <> nil then
    with PRecordData(Buffer)^ do
      for I := 0 to rdFieldCount - 1 do
        if IsHeapField(rdFields[I]) then
        begin
          ReallocMem(Pointer(rdFields[I].fdDataOfs), 0);
        end;
end;
{$ELSE}
begin
end;
{$ENDIF}

//!!!b

{ TgsMemoField }

constructor TgsMemoField.Create(AOwner: TComponent);
begin
  inherited;

  OnSetText := InsideSetText;
end;

procedure TgsMemoField.InsideSetText(Sender: TField; const Text: string);
begin
  Sender.AsString := Text;
end;

procedure TgsMemoField.SetText(const Value: string);
begin
  SetAsString(Value);
end;

//!!!e

{$IFDEF HEAP_STRING_FIELD}

function TIBCustomDataSet.IsHeapField(FD: TFieldData): Boolean;
begin
  Result := (FD.fdDataType = SQL_VARYING) and (FD.fdDataSize >= 256);
end;

procedure TIBCustomDataSet.InitializeRecordBuffer(Source, Dest: Pointer);
var
  I: Integer;
begin
  if Source <> Dest then
    with PRecordData(Dest)^ do
      for I := 0 to rdFieldCount - 1 do
        if IsHeapField(rdFields[I]) then
        begin
          if PRecordData(Source)^.rdFields[I].fdDataOfs <> 0 then
          begin
            GetMem(Pointer(rdFields[I].fdDataOfs), PRecordData(Source)^.rdFields[I].fdDataLength);
            Move(Pointer(PRecordData(Source)^.rdFields[I].fdDataOfs)^,
              Pointer(rdFields[I].fdDataOfs)^,
              PRecordData(Source)^.rdFields[I].fdDataLength);
          end else
            rdFields[I].fdDataOfs := 0;
        end;
end;

procedure TIBCustomDataSet.FinalizeCacheBuffer(Buffer: PChar;
  const Size: Integer);
var
  P: PChar;
begin
  if Buffer <> nil then
  begin
    P := Buffer;
    while P < (Buffer + Size) do
    begin
      FinalizeRecordBuffer(P);
      Inc(P, FRecordBufferSize);
    end;
  end;
end;

{$ENDIF}

{ TIBDataSetUpdateObject }

constructor TIBDataSetUpdateObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRefreshSQL := TStringList.Create;
end;

destructor TIBDataSetUpdateObject.Destroy;
begin
  FRefreshSQL.Free;
  inherited Destroy;
end;

procedure TIBDataSetUpdateObject.SetRefreshSQL(Value: TStrings);
begin
  FRefreshSQL.Assign(Value);
end;

{ TIBDSBlobStream }

constructor TIBDSBlobStream.Create(AField: TField; ABlobStream: TIBBlobStream;
                                    Mode: TBlobStreamMode);
begin
  FModified := Mode=bmWrite;
  FField := AField;
  FBlobStream := ABlobStream;
  FBlobStream.Seek(0, soFromBeginning);
  if (Mode = bmWrite) then
    FBlobStream.Truncate;
end;

destructor TIBDSBlobStream.Destroy;
begin
  if FModified then
  begin
    FModified := false;
    if not TBlobField(FField).Modified then
      TBlobField(FField).Modified := True;
    TIBCustomDataSet(FField.DataSet).DataEvent(deFieldChange, Longint(FField));
  end;
  inherited Destroy;
end;

function TIBDSBlobStream.Read(var Buffer; Count: Longint): Longint;
begin
  result := FBlobStream.Read(Buffer, Count);
end;

function TIBDSBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  result := FBlobStream.Seek(Offset, Origin);
end;

procedure TIBDSBlobStream.SetSize(NewSize: Longint);
begin
  FBlobStream.SetSize(NewSize);
end;

function TIBDSBlobStream.Write(const Buffer; Count: Longint): Longint;
begin
  FModified := true;
  if not (FField.DataSet.State in [dsEdit, dsInsert]) then
    IBError(ibxeNotEditing, [nil]);
  TIBCustomDataSet(FField.DataSet).RecordModified(True);
  result := FBlobStream.Write(Buffer, Count);
end;

procedure TIBDataSet.PSSetCommandText(const CommandText: string);
begin
  if CommandText <> '' then
    SelectSQL.Text := CommandText;
end;

function TIBDataSet.ParamByName(Idx: String): TIBXSQLVAR;
begin
  if not FInternalPrepared then
    InternalPrepare;
  result := FQSelect.ParamByName(Idx);
end;

{ TGeneratorField }

procedure TIBGeneratorField.Apply;
const
  SGENSQL = 'SELECT GEN_ID(%s, %d) FROM RDB$DATABASE';  {do not localize}
var
  sqlGen : TIBSQL;
  //!!!b
  DidActivate: Boolean;
  //!!!e
begin
  if IsComplete and (DataSet.FieldByName(Field).Value = Null) then
  begin
    sqlGen := TIBSQL.Create(Dataset.Database);
    sqlGen.Transaction := DataSet.Transaction;
    //!!!b
    DidActivate := not sqlGen.Transaction.InTransaction;
    //!!!e
    try
      //!!!b
      if DidActivate then
        sqlGen.Transaction.StartTransaction;
      //!!!e

      sqlGen.SQL.Text := Format(SGENSQL, [QuoteIdentifier(DataSet.Database.SQLDialect, FGenerator), FIncrementBy]);
      sqlGen.ExecQuery;
      if DataSet.FieldByName(Self.Field).ClassType <> TLargeIntField then
        DataSet.FieldByName(Self.Field).AsInteger := sqlGen.Current.Vars[0].AsInt64
      else
        TLargeIntField(DataSet.FieldByName(Self.Field)).AsLargeInt := sqlGen.Current.Vars[0].AsInt64;
      sqlGen.Close;
    finally
      //!!!b
      if DidActivate and sqlGen.Transaction.InTransaction then
        sqlGen.Transaction.Commit;
      //!!!e  
      sqlGen.Free;
    end;
  end;
end;

procedure TIBGeneratorField.Assign(Source: TPersistent);
var
  STemp : TIBGeneratorField;
begin
  if Source is TIBGeneratorField then
  begin
    STemp := Source as TIBGeneratorField;
    FField := STemp.Field;
    FGenerator := STemp.Generator;
    FIncrementBy := STemp.IncrementBy;
    FApplyEvent := STemp.ApplyEvent;
  end
  else
    inherited Assign(Source);
end;

constructor TIBGeneratorField.Create(ADataSet: TIBCustomDataSet);
begin
  inherited Create;
  FField := '';
  FGenerator := '';
  FIncrementBy := 1;
  FApplyEvent := gamOnNewRecord;
  DataSet := ADataSet;
end;

function TIBGeneratorField.IsComplete: Boolean;
begin
  Result := (FGenerator <> '') and (FField <> '');
end;

function TIBGeneratorField.ValueName: string;
begin
  if IsComplete then
    Result := FGenerator + ' -> ' + FField + ' By ' + IntToStr(FIncrementBy) {do not localize}
  else
    Result := '';
end;


//!!!b
{ TgdcAggregate }

constructor TgdcAggregate.Create(AnAggregates: TgdcAggregates;
  ADataSet: TIBCustomDataSet);
begin
  FDataSet := ADataSet;
  inherited Create(AnAggregates);
  FValue := vaNull;
end;

function TgdcAggregate.GetDisplayName: String;
begin
  Result := FAggregateName;
  if Result = '' then Result := Expression;
  if Result = '' then Result := inherited GetDisplayName;
end;

procedure TgdcAggregate.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TgdcAggregate.SetExpression(const Value: String);
begin
  FExpression := Value;
end;

procedure TgdcAggregate.SetIndexName(const Value: String);
begin
  FIndexName := Value;
end;

procedure TgdcAggregate.SetValue(AValue: Variant);
begin
  FValue := AValue;
end;

procedure TgdcAggregate.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

function TgdcAggregate.Value: Variant;
begin
  Result := FValue;
end;

{ TgdcAggregates }

function TgdcAggregates.Add: TgdcAggregate;
begin
  Result := TgdcAggregate(inherited Add);
  Result.FDataSet := TIBCustomDataSet(GetOwner);
end;

procedure TgdcAggregates.Clear;
var
  DataSet: TIBCustomDataSet;
begin
  inherited Clear;
  DataSet := TIBCustomDataSet(GetOwner);
  if DataSet <> nil then
    DataSet.ResetAllAggs(DataSet.AggregatesActive, nil);
end;

constructor TgdcAggregates.Create(Owner: TPersistent);
begin
  inherited Create(TgdcAggregate);
  FOwner := Owner;
end;

function TgdcAggregates.Find(const DisplayName: string): TgdcAggregate;
var
  I: Integer;
begin
  I := IndexOf(DisplayName);
  if I < 0 then Result := nil else Result := TgdcAggregate(Items[I]);
end;

function TgdcAggregates.GetItem(Index: Integer): TgdcAggregate;
begin
  Result := TgdcAggregate(inherited GetItem(Index));
end;

function TgdcAggregates.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TgdcAggregates.IndexOf(const DisplayName: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if AnsiCompareText(TgdcAggregate(Items[Result]).DisplayName, DisplayName) = 0 then Exit;
  Result := -1;
end;

procedure TgdcAggregates.SetItem(Index: Integer;
  const Value: TgdcAggregate);
begin
  inherited SetItem(Index, Value);
end;

//!!!e

{$IFDEF NEW_GRID}
{ TGroupAgg }

procedure TGroupAgg.Assign;
var F: Double;
begin                                   
  F := GetResult;
  try
  if (FField.DataType = ftInteger) and (F > 2147483647) then
    FField.AsFloat := -1
  else //if FField.DataType <> ftString then
    FField.AsFloat := F;  //FField.Value := F;
  except
    on E: EVariantError do FField.Value := 0;
  end;
end;

procedure TGroupAgg.Calc;
var  TempV: Double; K: Integer;
begin
  case FField.DataType of
   ftDate, ftTime, ftDateTime,
   ftSmallInt, ftInteger, ftWord,
   ftCurrency, ftFloat, ftBCD, ftLargeInt: begin
    if FField.IsNull then
      TempV := 0
    else
      TempV := FField.Value;
   end
   else begin
     Val(FField.asString,TempV,K); if (K>0) then TempV := 0;
   end;
  end;

  if (FCount = 0) then
  case FFunction of
    afMin,afMax: FValue := TempV;
  end;

  case FFunction of
    afSum: FValue := FValue + TempV;
    afCount: {-----};
    afCountNotNull: if not FField.IsNull then FValue := FValue + 1;
    afMin: if FValue > TempV then FValue := TempV;
    afMax: if FValue < TempV then FValue := TempV;
    afAvg: FValue := FValue + TempV;
  end;
  Inc(FCount);
end;

procedure TGroupAgg.Clear;
begin
  FValue := 0;
  FCount := 0;
end;

constructor TGroupAgg.Create(F: TField; const AFunction: String);
begin
  FField := F;
  if AFunction = 'SUM' then
    FFunction := afSum
  else if AFunction = 'COUNT' then
    FFunction := afCount
  else if AFunction = 'COUNT_NOT_NULL' then
    FFunction := afCountNotNull
  else if AFunction = 'MAX' then
    FFunction := afMax
  else if AFunction = 'MIN' then
    FFunction := afMin
  else if AFunction = 'AVG' then
    FFunction := afAvg
  else
    raise Exception.Create('Invalid function');
  Clear;
end;

function TGroupAgg.GetResult: Double;
begin
  case FFunction of
    afSum, afMin, afMax, afCountNotNull: Result := FValue;
    afCount: Result := FCount;
  else
    {afAvg:} Result := FValue / FCount;
  end;
end;

function TGroupAgg.GetFuncAsStr: string;
begin
  case FFunction  of
  afSum:   Result := 'SUM';
  afCount: Result := 'COUNT';
  afCountNotNull: Result := 'COUNT_NOT_NULL';
  afMin: Result := 'MIN';
  afMax: Result := 'MAX';
  afAvg: Result := 'AVG';
  end;
end;

{ TFormulaFields }

function TFormulaFields.GetItem(Index: Integer): TGroupAgg;
begin
  Result := TGroupAgg(inherited GetItem(Index));
end;

procedure TFormulaFields.SetItem(Index: Integer;  const Value: TGroupAgg);
begin
  inherited SetItem(Index, Value);
end;

{ TGroupSortField }

constructor TGroupSortField.Create(F: TField; const AGroupSortOrder: TGroupSortOrder;
  AIntScale: Integer = 1; ADateScale: TDateScale = dsType; AStrScale: string = '');
begin
  FField := F;
  FGroupSortOrder := AGroupSortOrder;
  FIntScale := AIntScale;
  FDateScale:= ADateScale;
  FStrScale:= AStrScale;
end;

function TGroupSortField.GetScaleAsStr: string;
begin
  Result := '';
  case FDateScale  of
    dsDay .. dsYear: Result := ArDateScale[FDateScale];
  end;
end;

{ TGroupSortFields }

function TGroupSortFields.GetItem(Index: Integer): TGroupSortField;
begin
  Result := TGroupSortField(inherited GetItem(Index));
end;

procedure TGroupSortFields.SetItem(Index: Integer;  const Value: TGroupSortField);
begin
  inherited SetItem(Index, Value);
end;

{$ENDIF}

initialization
  MAX_LOCATE_WAIT := $FFFFFFFF;
end.









