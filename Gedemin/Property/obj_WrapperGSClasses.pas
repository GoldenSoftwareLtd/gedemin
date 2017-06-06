
{++

  Copyright (c) 2002-2017 by Golden Software of Belarus, Ltd

  Module

    obj_WrapperGSClasses.pas

  Abstract

    Gedemin project. COM-object for GEDEMIN Classes.

  Author

    Alexander Dubrovnik

  Revisions history

    1.00    27.02.2002    DAlex        Initial version.

--}

unit obj_WrapperGSClasses;

interface

uses
  ComObj, ActiveX, AxCtrls, Classes, Gedemin_TLB, grids, dbgrids, gsStorage,
  gsIBGrid, gsDBGrid, gsIBLookupComboBox, mask, xDateEdits, flt_sqlFilter,
  TB2Dock, TB2Toolbar, StdVcl, Controls, StdCtrls, DB, Forms, gsRAChart,
  IBCustomDataSet, gdcBase, menus, Graphics, extctrls, ActnList, obj_WrapperDelphiClasses,
  Dialogs, gd_ClassList, IBDataBase, sysutils, gd_createable_form, gdcBaseInterface,
  gd_KeyAssoc, gdcInvMovement, gsDBReduction, xCalculatorEdit, gdcTree, gdcClasses,
  gdcReport, gdcTemplate, gdcDelphiObject, gdcMacros, gdcConst, gdcExplorer,
  gdcAcctAccount, gdcContacts, gdcAcctTransaction, gdcMetaData, gdcCustomTable,
  gdcUser, gdcGood, gdcInvDocument_unit, gdcInvConsts_unit, gdc_dlgTR_unit, gdc_dlgHGR_unit,
  gdcBaseBank, gdcStatement, gdcAttrUserdefined, gdcBugBase,
  gdcCurr, gdcInvPriceList_unit, gdcJournal, gdc_createable_form,
  gdcTableCalendar, TB2ToolWindow, TB2Item, IBServices, gdc_dlgG_unit, gdc_frmSGR_unit,
  gd_ScrException, gdcAcctEntryRegister,  gdc_frmG_unit, gdc_frmMDH_unit, gdc_frmMD2H_unit,
  gdv_frmG_unit, obj_WrapperIBXClasses, flt_sqlfilter_condition_type,  at_classes,
  gsTransaction, tr_Type_unit, at_Container, NumConv,  gsScaner, gsDBTreeView,
  ColorComboBox, gdc_dlgInvDocument_unit, BtnEdit, gdcTaxFunction, gdc_frmInvCard_unit,
  flt_QueryFilterGDC, gsStorage_CompPath, gd_AttrComboBox, gdcSetting, gdcFile,
  gdEnumComboBox, at_sql_setup, gsSupportClasses, gdc_frmInvSelectedGoods_unit, xCalc,
  gdv_dlgSelectDocument_unit, gdcLink, gsComScaner, gdc_dlgUserComplexDocument_unit
  {$IFDEF MODEM}
  , gsModem
  {$ENDIF}
  , gdcStreamSaver, gdvAcctBase, gdvAcctAccCard, gdvAcctAccReview, gdvAcctLedger,
  gdvAcctGeneralLedger, gdvAcctCirculationList, gdv_frmAcctBaseForm_unit,
  prm_ParamFunctions_unit, gd_main_form, gsFTPClient, gsTRPOS_TLVClient, gsPLClient, FileView
  {$IFDEF WITH_INDY}
  , gd_WebServerControl_unit, gd_WebClientControl_unit
  {$ENDIF}
  ;

type
  TwrpAnalyze = class(TwrpObject, IgsAnalyze)
  private
    function  GetAnalyze: TAnalyze;
  protected
    function  Get_FromTableName: WideString; safecall;
    procedure Set_FromTableName(const Value: WideString); safecall;
    function  Get_FromFieldName: WideString; safecall;
    procedure Set_FromFieldName(const Value: WideString); safecall;
    function  Get_ReferencyName: WideString; safecall;
    procedure Set_ReferencyName(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_ValueAnalyze: Integer; safecall;
    procedure Set_ValueAnalyze(Value: Integer); safecall;
  end;

  TwrpAccount = class(TwrpObject, IgsAccount)
  private
    function  GetAccount: TAccount;
  protected
    function  AnalyzeByType(const aReferencyName: WideString): Integer; safecall;
    function  IsAnalyze(const aReferencyName: WideString): WordBool; safecall;
    function  CountAnalyze: Integer; safecall;
    procedure AddAnalyze(const aFromTableName: WideString; const aFromFieldName: WideString;
                         const aReferencyName: WideString; const aFieldName: WideString;
                         aValueAnalyze: Integer); safecall;
    procedure AssignAnalyze(const aAnalyze: IgsObjectList); safecall;
    function  Get_Code: Integer; safecall;
    procedure Set_Code(Value: Integer); safecall;
    function  Get_Alias: WideString; safecall;
    procedure Set_Alias(const Value: WideString); safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_CurrencyAccount: WordBool; safecall;
    function  Get_AnalyzeItem(Index: Integer): IgsAnalyze; safecall;
  end;

  TwrpEntry = class(TwrpObject, IgsEntry)
  private
    function  GetEntry: TEntry;
  protected
    procedure AddEntryLine(const AccountInfo: IgsAccount; IsDebit: WordBool;
                           const aDescription: WideString); safecall;
    procedure AddFromTypeEntry(const TypeEntry: IgsEntry; const aValueList: IgsObjectList;
                               const aAnalyzeList: IgsObjectList; aCurrKey: Integer); safecall;
    procedure SetSumFromTypeEntry(const TypeEntry: IgsEntry; const aValueList: IgsObjectList); safecall;
    function  IsUseVariable(const aVariable: WideString): WordBool; safecall;
    procedure Clear; safecall;
    function  CheckBalans: WordBool; safecall;
    function  GetDebitSumNCU: Currency; safecall;
    function  GetCreditSumNCU: Currency; safecall;
    function  GetDebitSumCurr: Currency; safecall;
    function  GetCreditSumCurr: Currency; safecall;
    function  IsCurrencyEntry: WordBool; safecall;
    function  Get_EntryDate: TDateTime; safecall;
    procedure Set_EntryDate(Value: TDateTime); safecall;
    function  Get_EntryKey: Integer; safecall;
    procedure Set_EntryKey(Value: Integer); safecall;
    function  Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function  Get_DocumentKey: Integer; safecall;
    procedure Set_DocumentKey(Value: Integer); safecall;
    function  Get_PositionKey: Integer; safecall;
    procedure Set_PositionKey(Value: Integer); safecall;
    function  Get_Changed: WordBool; safecall;
    procedure Set_Changed(Value: WordBool); safecall;
    function  Get_Debit(Index: Integer): IgsAccount; safecall;
    function  Get_Credit(Index: Integer): IgsAccount; safecall;
    function  Get_DebitCount: Integer; safecall;
    function  Get_CreditCount: Integer; safecall;
  end;

  TwrpIBDSBlobStream = class(TwrpStream, IgsIBDSBlobStream)
  private
    function  GetIBDSBlobStream: TIBDSBlobStream;
  protected
    procedure SetSize(NewSize: Integer); safecall;
  end;

  TwrpTransaction = class(TwrpObject, IgsTransaction)
  private
    function  GetTransaction: TTransaction;
  protected
    procedure Assign_(const Source: IgsTransaction); safecall;
    function  IsTransaction(const aTransaction: IgsIBTransaction;
                            const Values: IgsFilterConditionList): WordBool; safecall;
    procedure AddTransactionCondition(const LocBlobStream: IgsIBDSBlobStream); safecall;
    procedure AddTypeEntry(const Entry: IgsEntry); safecall;
    function  IsUseVariable(const aVariable: WideString): WordBool; safecall;
    function  IsCurrencyTransaction: WordBool; safecall;
    function  Get_TransactionFilterData: IgsFilterData; safecall;
    function  Get_TransactionKey: Integer; safecall;
    procedure Set_TransactionKey(Value: Integer); safecall;
    function  Get_DocumentTypeKey: Integer; safecall;
    procedure Set_DocumentTypeKey(Value: Integer); safecall;
    function  Get_IsDocument: WordBool; safecall;
    procedure Set_IsDocument(Value: WordBool); safecall;
    function  Get_TransactionName: WideString; safecall;
    procedure Set_TransactionName(const Value: WideString); safecall;
    function  Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function  Get_TypeEntry(Index: Integer): IgsEntry; safecall;
    function  Get_TypeEntryCount: Integer; safecall;
  end;

  TwrpPositionTransaction = class(TwrpTransaction, IgsPositionTransaction)
  private
    function  GetPositionTransaction: TPositionTransaction;
  protected
    procedure AddRealEntry(const Entry: IgsEntry); safecall;
    function  CreateRealEntry(const aValueList: IgsObjectList; const aAnalyzeList: IgsObjectList;
                              aCurrKey: Integer): WordBool; safecall;
    procedure ClearRealEntry; safecall;
    function  ChangeValue(aDocumentKey: Integer; aPositionKey: Integer; aDocumentDate: TDateTime;
                          const ValueList: IgsObjectList): WordBool; safecall;
    function  Get_DocumentCode: Integer; safecall;
    procedure Set_DocumentCode(Value: Integer); safecall;
    function  Get_PositionCode: Integer; safecall;
    procedure Set_PositionCode(Value: Integer); safecall;
    function  Get_TransactionDate: TDateTime; safecall;
    procedure Set_TransactionDate(Value: TDateTime); safecall;
    function  Get_TransactionChanged: WordBool; safecall;
    procedure Set_TransactionChanged(Value: WordBool); safecall;
    function  Get_SumTransaction: Currency; safecall;
    function  Get_RealEntry(Index: Integer): IgsEntry; safecall;
    function  Get_RealEntryCount: Integer; safecall;
  end;

  TwrpGsTransaction = class(TwrpComponent, IgsGsTransaction)
  private
    function  GetGsTransaction: TGsTransaction;
  protected
    function  SetStartTransactionInfo(ReadEntry: WordBool): WordBool; safecall;
    procedure Refresh; safecall;
    procedure ReadTransactionOnPosition(aDocumentCode: Integer; aPositionCode: Integer;
                                        aEntryKey: Integer); safecall;
    function  GetTransaction(const List: IgsStrings): IgsTransaction; safecall;
    procedure CreateTransactionOnPosition(aCurrKey: Integer; aDocumentDate: TDateTime;
                                          const aValueList: IgsObjectList;
                                          const aAnalyzeList: IgsObjectList;
                                          isEditTransaction: WordBool); safecall;
    procedure CreateTransactionByDelayedTransaction(aTransactionKey: Integer;
                                                    aFromDocumentKey: Integer;
                                                    aToDocumentKey: Integer;
                                                    aFromPositionKey: Integer;
                                                    aToPositionKey: Integer;
                                                    aDocumentDate: TDateTime;
                                                    const aValueList: IgsObjectList); safecall;
    function  CreateTransactionOnDataSet(aCurrKey: Integer; aDocumentDate: TDateTime;
                                         const aValueList: IgsObjectList;
                                         const aAnalyzeList: IgsObjectList;
                                         CheckTransaction: WordBool; OnlyWithTransaction: WordBool): WordBool; safecall;
    function  AppendEntryToBase: WordBool; safecall;
    function  GetTransactionName(TransactionKey: Integer): WideString; safecall;
    function  IsValidTransaction(aTransactionKey: Integer): WordBool; safecall;
    function  IsValidDocTransaction(aTransactionKey: Integer): WordBool; safecall;
    function  IsCurrencyTransaction(aTransactionKey: Integer): WordBool; safecall;
    procedure SetTransactionOnDataSet; safecall;
    procedure GetAnalyzeList(aTransactionKey: Integer; const aAnalyzeList: IgsList); safecall;
    function  SetTransactionStrings(const Value: IgsStrings; aTransactionKey: Integer): Integer; safecall;
    function  Get_CurTransaction(Index: Integer): IgsTransaction; safecall;
    function  Get_CurTransactionCount: Integer; safecall;
    function  Get_PosTransaction(Index: Integer): IgsPositionTransaction; safecall;
    function  Get_PosTransactionCount: Integer; safecall;
    function  Get_TransactionDate: TDateTime; safecall;
    procedure Set_TransactionDate(Value: TDateTime); safecall;
    function  Get_DocumentNumber: WideString; safecall;
    function  Get_CurrencyKey: Integer; safecall;
    procedure Set_CurrencyKey(Value: Integer); safecall;
    function  Get_Changed: WordBool; safecall;
    procedure Set_Changed(Value: WordBool); safecall;
    function  Get_DocumentType: Integer; safecall;
    procedure Set_DocumentType(Value: Integer); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_FieldKey: WideString; safecall;
    procedure Set_FieldKey(const Value: WideString); safecall;
    function  Get_FieldTrName: WideString; safecall;
    procedure Set_FieldTrName(const Value: WideString); safecall;
    function  Get_FieldDocumentKey: WideString; safecall;
    procedure Set_FieldDocumentKey(const Value: WideString); safecall;
    function  Get_BeginTransactionType: TgsBeginTransactionType; safecall;
    procedure Set_BeginTransactionType(Value: TgsBeginTransactionType); safecall;
    function  Get_SetTransactionType: TgsSetTransactionType; safecall;
    procedure Set_SetTransactionType(Value: TgsSetTransactionType); safecall;
    function  Get_DocumentOnly: WordBool; safecall;
    procedure Set_DocumentOnly(Value: WordBool); safecall;
    function  Get_MakeDelayedEntry: WordBool; safecall;
    procedure Set_MakeDelayedEntry(Value: WordBool); safecall;
  end;

  TwrpAtForeignKey = class(TwrpObject, IgsAtForeignKey)
  private
    function  GetAtForeignKey: TAtForeignKey;
  protected
    procedure RefreshData; safecall;
    procedure RefreshData_(const aDatabase: IgsIBDatabase; const ATransaction: IgsIBTransaction); safecall;
    procedure RefreshData_1(const IBSQL: IgsIBSQL); safecall;
    function  Get_ConstraintName: WideString; safecall;
    function  Get_IndexName: WideString; safecall;
    function  Get_Relation: IgsAtRelation; safecall;
    function  Get_ReferencesRelation: IgsAtRelation; safecall;
    function  Get_IsSimpleKey: WordBool; safecall;
    function  Get_ConstraintField: IgsAtRelationField; safecall;
    function  Get_ReferencesField: IgsAtRelationField; safecall;
    function  Get_ConstraintFields: IgsAtRelationFields; safecall;
    function  Get_ReferencesFields: IgsAtRelationFields; safecall;
    function  Get_ReferencesIndex: WideString; safecall;
    function  Get_IsDropped: WordBool; safecall;
  end;

  TwrpAtField = class(TwrpObject, IgsAtField)
  private
    function  GetAtField: TAtField;
  protected
    procedure RefreshData; safecall;
    procedure RefreshData_(const aDatabase: IgsIBDatabase; const ATransaction: IgsIBTransaction); safecall;
    procedure RefreshData_1(const SQLRecord: IgsIBXSQLDA); safecall;
    procedure RecordAcquired; safecall;
    function  GetNumerationName(const Value: WideString): WideString; safecall;
    function  GetNumerationValue(const NameNumeration: WideString): WideString; safecall;
    function  Get_ID: Integer; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldType: TgsFieldType; safecall;
    function  Get_SQLType: Smallint; safecall;
    function  Get_SQLSubType: Smallint; safecall;
    procedure Set_SQLType(Value: Smallint); safecall;
    function  Get_FieldLength: Integer; safecall;
    function  Get_FieldScale: Integer; safecall;
    function  Get_IsNullable: WordBool; safecall;
    function  Get_IsUserDefined: WordBool; safecall;
    function  Get_IsSystem: WordBool; safecall;
    function  Get_Description: WideString; safecall;
    function  Get_LName: WideString; safecall;
    function  Get_Alignment: TgsFieldAlignment; safecall;
    function  Get_ColWidth: Integer; safecall;
    function  Get_Disabled: WordBool; safecall;
    function  Get_FormatString: WideString; safecall;
    function  Get_Visible: WordBool; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    function  Get_gdClassName: WideString; safecall;
    function  Get_gdSubType: WideString; safecall;
    function  Get_RefTableName: WideString; safecall;
    function  Get_RefTable: IgsAtRelation; safecall;
    function  Get_RefListFieldName: WideString; safecall;
    function  Get_RefListField: IgsAtRelationField; safecall;
    function  Get_RefCondition: WideString; safecall;
    function  Get_SetTableName: WideString; safecall;
    function  Get_SetTable: IgsAtRelation; safecall;
    function  Get_SetListFieldName: WideString; safecall;
    function  Get_SetListField: IgsAtRelationField; safecall;
    function  Get_SetCondition: WideString; safecall;
    function  Get_HasRecord: WordBool; safecall;
    function  Get_IsDropped: WordBool; safecall;
  end;

  TwrpAtRelationField = class(TwrpObject, IgsAtRelationField)
  private
    function  GetAtRelationField: TAtRelationField;
  protected
    procedure RefreshData; safecall;
    procedure RefreshData_(const aDatabase: IgsIBDatabase; const ATransaction: IgsIBTransaction); safecall;
    procedure RefreshData_1(const SQLRecord: IgsIBXSQLDA; const aDatabase: IgsIBDatabase;
                            const ATransaction: IgsIBTransaction); safecall;
    procedure RecordAcquired; safecall;
    function  InObject(const AName: WideString): WordBool; safecall;
    function  Get_ID: Integer; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_SQLType: Integer; safecall;
    function  Get_IsUserDefined: WordBool; safecall;
    function  Get_Relation: IgsAtRelation; safecall;
    function  Get_Field: IgsAtField; safecall;
    function  Get_LName: WideString; safecall;
    function  Get_Description: WideString; safecall;
    function  Get_LShortName: WideString; safecall;
    function  Get_Alignment: TgsFieldAlignment; safecall;
    function  Get_ColWidth: Integer; safecall;
    function  Get_FieldPosition: Integer; safecall;
    function  Get_FormatString: WideString; safecall;
    function  Get_Visible: WordBool; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    function  Get_gdClassName: WideString; safecall;
    function  Get_gdSubType: WideString; safecall;
    function  Get_References: IgsAtRelation; safecall;
    function  Get_ReferencesField: IgsAtRelationField; safecall;
    function  Get_ForeignKey: IgsAtForeignKey; safecall;
    function  Get_ReferenceListField: IgsAtRelationField; safecall;
    function  Get_CrossRelation: IgsAtRelation; safecall;
    function  Get_CrossRelationName: WideString; safecall;
    function  Get_CrossRelationField: IgsAtRelationField; safecall;
    function  Get_CrossRelationFieldName: WideString; safecall;
    function  Get_aFull: Integer; safecall;
    function  Get_aChag: Integer; safecall;
    function  Get_AView: Integer; safecall;
    function  Get_HasRecord: WordBool; safecall;
    function  Get_IsDropped: WordBool; safecall;
    function  Get_IsSecurityDescriptor: WordBool; safecall;
    function  Get_IsComputed: WordBool; safecall;
    function  Get_ObjectsList: IgsStringList; safecall;
  end;

  TwrpAtRelation = class(TwrpObject, IgsAtRelation)
  private
    function  GetAtRelation: TAtRelation;
  protected
    procedure RefreshData(IsRefreshFields: WordBool); safecall;
    procedure RefreshData_1(const SQLRecord: IgsIBXSQLDA; const aDatabase: IgsIBDatabase;
                            const aTransaction: IgsIBTransaction; IsRefreshFields: WordBool); safecall;
    procedure RefreshData_2(const aDatabase: IgsIBDatabase; const aTransaction: IgsIBTransaction;
                            IsRefreshFields: WordBool); safecall;
    procedure RefreshConstraints; safecall;
    procedure RefreshConstraints_(const aDatabase: IgsIBDatabase;
                                  const aTransaction: IgsIBTransaction); safecall;
    procedure RecordAcquired; safecall;
    function  Get_RelationType: TgsAtRelationType; safecall;
    function  Get_IsStandartTreeRelation: WordBool; safecall;
    function  Get_IsLBRBTreeRelation: WordBool; safecall;
    function  Get_ID: Integer; safecall;
    function  Get_RelationName: WideString; safecall;
    function  Get_HasRecord: WordBool; safecall;
    function  Get_IsUserDefined: WordBool; safecall;
    function  Get_IsSystem: WordBool; safecall;
    function  Get_HasSecurityDescriptors: WordBool; safecall;
    function  Get_Description: WideString; safecall;
    function  Get_LName: WideString; safecall;
    function  Get_LShortName: WideString; safecall;
    function  Get_RelationFields: IgsAtRelationFields; safecall;
    function  Get_RelationID: Integer; safecall;
    function  Get_ListField: IgsAtRelationField; safecall;
    function  Get_aFull: Integer; safecall;
    function  Get_aChag: Integer; safecall;
    function  Get_aView: Integer; safecall;
    function  Get_PrimaryKey: IgsAtPrimaryKey; safecall;
  end;

  TwrpAtRelationFields = class(TwrpObject, IgsAtRelationFields)
  private
    function  GetAtRelationFields: TAtRelationFields;
  protected
    procedure RefreshData; safecall;
    procedure RefreshData_(const aDatabase: IgsIBDatabase; const aTransaction: IgsIBTransaction); safecall;
    function  Add(const atRelationField: IgsAtRelationField): Integer; safecall;
    function  AddRelationField(const AFieldName: WideString): IgsAtRelationField; safecall;
    function  ByFieldName(const AName: WideString): IgsAtRelationField; safecall;
    function  ByID(aID: Integer): IgsAtRelationField; safecall;
    function  ByPos(APosition: Integer): IgsAtRelationField; safecall;
    procedure Delete(Index: Integer); safecall;
    function  Get_Relation: IgsAtRelation; safecall;
    procedure Set_Relation(const Value: IgsAtRelation); safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Items(Index: Integer): IgsAtRelationField; safecall;
  end;

  TwrpGdcObjectSet = class(TwrpObject, IgsGdcObjectSet)
  private
    function  GetGdcObjectSet: TGdcObjectSet;
  protected
    function  Add(AnID: Integer; const AgdClassName: WideString;
      const ASubType: WideString): Integer; safecall;
    procedure AddgdClass(Index: Integer; const AgdClassName: WideString;
      const ASubType: WideString); safecall;
    function  FindgdClass(Index: Integer; const AgdClassName: WideString;
      const ASubType: WideString): WordBool; safecall;
    function  FindgdClassByID(AnID: Integer; const AgdClassName: WideString; 
      const ASubType: WideString): WordBool; safecall;
    function  Get_gdInfo(Index: Integer): WideString; safecall;
    function  Find(AnID: Integer): Integer; safecall;
    procedure Remove(AnID: Integer); safecall;
    procedure Delete(AnID: Integer); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
    function  Get_gdClass: WideString; safecall;
    procedure Set_gdClass(const Value: WideString); safecall;
    function  Get_gdClassName: WideString; safecall;
    function  Get_SubType: WideString; safecall;
    procedure Set_SubType(const Value: WideString); safecall;
    function  Get_Items(Index: Integer): Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Size: Integer; safecall;
  end;

  TwrpGdcAggregate = class(TwrpCollectionItem, IgsGdcAggregate)
  private
    function  GetGdcAggregate: TGdcAggregate;
  protected
    function  Value: OleVariant; safecall;
    function  GetDisplayName: WideString; safecall;
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  Get_AggregateName: WideString; safecall;
    procedure Set_AggregateName(const Value: WideString); safecall;
    function  Get_DataSet: IgsGDCBase; safecall;
    function  Get_DataSize: Integer; safecall;
    function  Get_DataType: TgsFieldType; safecall;
    procedure Set_DataType(Value: TgsFieldType); safecall;
    function  Get_Expression: WideString; safecall;
    procedure Set_Expression(const Value: WideString); safecall;
    function  Get_IndexName: WideString; safecall;
    procedure Set_IndexName(const Value: WideString); safecall;
    function  Get_InUse: WordBool; safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  end;

  TwrpGdcAggregates = class(TwrpCollection, IgsGdcAggregates)
  private
    function  GetGdcAggregates: TGdcAggregates;
  protected
    function  Add: IgsGdcAggregate; safecall;
    procedure Clear_; safecall;
    function  IndexOf(const DisplayName: WideString): Integer; safecall;
    function  Get_Items(Index: Integer): IgsGdcAggregate; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsGdcAggregate); safecall;
  end;

  TwrpTBItemViewer = class(TwrpObject, IgsTBItemViewer)
  private
    function  GetTBItemViewer: TTBItemViewer;
  protected
    function  Get_Clipped: WordBool; safecall;
    function  Get_Index: Integer; safecall;
    function  Get_Item: IgsTBCustomItem; safecall;
    function  Get_OffEdge: WordBool; safecall;
    function  Get_Show: WordBool; safecall;
    function  Get_View: IgsTBView; safecall;
    procedure BoundsRect(out Left: OleVariant; out Top: OleVariant; out Right: OleVariant;
                         out Bottom: OleVariant); safecall;
    procedure ScreenToClient(InX: Integer; InY: Integer; out OutX: OleVariant; out OutY: OleVariant); safecall;
  end;

  TwrpTBView = class(TwrpComponent, IgsTBView)
  private
    function  GetTBView: TTBView;
  protected
    procedure BeginUpdate; safecall;
    procedure CancelCapture; safecall;
    procedure CloseChildPopups; safecall;
    function  ContainsView(const AView: IgsTBView): WordBool; safecall;
    procedure DrawSubitems(const ACanvas: IgsCanvas); safecall;
    procedure EndUpdate; safecall;
    procedure EnterToolbarLoop(const Options: WideString); safecall;
    function  Find(const Item: IgsTBCustomItem): IgsTBItemViewer; safecall;
    function  FirstSelectable: IgsTBItemViewer; safecall;
    procedure GetOffEdgeControlList(const List: IgsList); safecall;
    procedure GivePriority(const AViewer: IgsTBItemViewer); safecall;
    function  HighestPriorityViewer: IgsTBItemViewer; safecall;
    procedure Invalidate(const AViewer: IgsTBItemViewer); safecall;
    procedure InvalidatePositions; safecall;
    function  IndexOf(const AViewer: IgsTBItemViewer): Integer; safecall;
    procedure NextSelectable(const CurViewer: IgsTBItemViewer; GoForward: WordBool); safecall;
    procedure RecreateAllViewers; safecall;
    procedure ScrollSelectedIntoView; safecall;
    procedure SetCapture; safecall;
    procedure TryValidatePositions; safecall;
    procedure UpdatePositions(out X: OleVariant; out Y: OleVariant); safecall;
    procedure ValidatePositions; safecall;
    function  ViewerFromPoint(X: Integer; Y: Integer): IgsTBItemViewer; safecall;
    function  Get_BackgroundColor: Integer; safecall;
    procedure Set_BackgroundColor(Value: Integer); safecall;
    procedure BaseSize(out X: OleVariant; out Y: OleVariant); safecall;
    function  Get_Capture: WordBool; safecall;
    function  Get_ChevronOffset: Integer; safecall;
    procedure Set_ChevronOffset(Value: Integer); safecall;
    function  Get_Customizing: WordBool; safecall;
    procedure Set_Customizing(Value: WordBool); safecall;
    function  Get_IsPopup: WordBool; safecall;
    function  Get_IsToolbar: WordBool; safecall;
    function  Get_MouseOverSelected: WordBool; safecall;
    function  Get_ParentView: IgsTBView; safecall;
    function  Get_ParentItem: IgsTBCustomItem; safecall;
    function  Get_Orientation: TgsTBViewOrientation; safecall;
    procedure Set_Orientation(Value: TgsTBViewOrientation); safecall;
    function  Get_Selected: IgsTBItemViewer; safecall;
    procedure Set_Selected(const Value: IgsTBItemViewer); safecall;
    function  Get_State: WideString; safecall;
    function  Get_Style: WideString; safecall;
    function  Get_ViewerCount: Integer; safecall;
    function  Get_Window: IgsWinControl; safecall;
    function  Get_WrapOffset: Integer; safecall;
    procedure Set_WrapOffset(Value: Integer); safecall;
  end;

  TwrpTBToolbarView = class(TwrpTBView, IgsTBToolbarView)
  end;

  TwrpTBBasicBackground = class(TwrpComponent, IgsTBBasicBackground)
  end;

  TwrpTBCustomForm = class(TwrpCustomForm, IgsTBCustomForm)
  end;

  TwrpGsStorageItem = class(TwrpObject, IgsGsStorageItem)
  private
    function  GetGsStorageItem: TGsStorageItem;
  protected
    procedure LoadFromFile(const FileName: WideString; FileFormat: TgsGsStorageFileFormat); safecall;
    procedure SaveToFile(const FileName: WideString; FileFormat: TgsGsStorageFileFormat); safecall;
    function  Find(const AList: IgsStringList; const ASearchString: WideString;
                   const ASearchOptions: WideString): WordBool; safecall;
    function  GetStorageName: WideString; safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Parent: IgsGsStorageItem; safecall;
    function  Get_DataSize: Integer; safecall;
    function  Get_Path: WideString; safecall;
    function  Get_Storage: IgsGsStorage; safecall;
    procedure Drop; safecall;
  end;

  TwrpGsStorageFolder = class(TwrpGsStorageItem, IgsGsStorageFolder)
  private
    function  GetGsStorageFolder: TGsStorageFolder;
  protected
    procedure Clear; safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
    function  ReadString(const AValueName: WideString; const Default: WideString): WideString; safecall;
    procedure WriteString(const AValueName: WideString; const Default: WideString); safecall;
    function  ReadInteger(const AValueName: WideString; Default: Integer): Integer; safecall;
    procedure WriteInteger(const AValueName: WideString; Default: Integer); safecall;
    function  ReadCurrency(const AValueName: WideString; Default: Currency): Currency; safecall;
    procedure WriteCurrency(const AValueName: WideString; Default: Currency); safecall;
    function  ReadDateTime(const AValueName: WideString; Default: TDateTime): TDateTime; safecall;
    procedure WriteDateTime(const AValueName: WideString; Default: TDateTime); safecall;
    function  ReadBoolean(const AValueName: WideString; Default: WordBool): WordBool; safecall;
    procedure WriteBoolean(const AValueName: WideString; Default: WordBool); safecall;
    procedure ReadStream(const AValueName: WideString; const S: IgsStream); safecall;
    procedure WriteStream(const AValueName: WideString; const S: IgsStream); safecall;
    procedure WriteValue(const AValue: IgsGsStorageValue); safecall;
    procedure BuildTreeView(const N: IgsTreeNode); safecall;
    function  OpenFolder(const APath: WideString; CanCreate: WordBool): IgsGsStorageFolder; safecall;
    function  CreateFolder(const AName: WideString): IgsGsStorageFolder; safecall;
    function  ValueExists(const AValueName: WideString): WordBool; safecall;
    function  FolderExists(const AFolderName: WideString): WordBool; safecall;
    function  ValueByName(const AValueName: WideString): IgsGsStorageValue; safecall;
    function DeleteFolder(const AName: WideString): WordBool; safecall;
    procedure ExtractFolder(const F: IgsGsStorageFolder); safecall;
    function  AddFolder(const F: IgsGsStorageFolder): Integer; safecall;
    function  FolderByName(const AName: WideString): IgsGsStorageFolder; safecall;
    function  DeleteValue(const AValueName: WideString): WordBool; safecall;
    function  FindFolder(const F: IgsGsStorageFolder; GoSubFolders: WordBool): WordBool; safecall;
    function  MoveFolder(const NewParent: IgsGsStorageFolder): WordBool; safecall;
    procedure ShowPropDialog; safecall;
    function  Get_Folders(Index: Integer): IgsGsStorageFolder; safecall;
    function  Get_FoldersCount: Integer; safecall;
    function  Get_Values(Index: Integer): IgsGsStorageValue; safecall;
    function  Get_ValuesCount: Integer; safecall;
  end;

  TwrpGsRootFolder = class(TwrpGsStorageFolder, IgsGsRootFolder)
  end;

  TwrpGsStorageValue = class(TwrpGsStorageItem, IgsGsStorageValue)
  private
    function  GetGsStorageValue: TGsStorageValue;
  protected
    function  GetTypeId: Integer; safecall;
    function  GetTypeName: WideString; safecall;
    function  GetStorageValueClass: WideString; safecall;
    function  ShowEditValueDialog: Integer; safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsBoolean: WordBool; safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
  end;

  TwrpFilterOrderByList = class(TwrpList, IgsFilterOrderByList)
  private
    function  GetFilterOrderByList: TFilterOrderByList;
  protected
    function  Get_OrderText: WideString; safecall;
    procedure Assign_(const Source: IgsFilterOrderByList); safecall;
    function  Get_OnlyIndexField: WordBool; safecall;
    procedure Set_OnlyIndexField(Value: WordBool); safecall;
    function  Get_OrdersBy(Index: Integer): IgsFilterOrderBy; safecall;
    function  AddOrderBy(const OrderByData: IgsFilterOrderBy): Integer; safecall;
    function  AddOrderByWithParams(const TableName: WideString; const TableAlias: WideString;
                                   const LocalTable: WideString; const FieldName: WideString;
                                   const LocalField: WideString; Ascending: WordBool): Integer; safecall;
    procedure DeleteOrderBy(Index: Integer); safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
  end;

  TwrpFilterData = class(TwrpObject, IgsFilterData)
  private
    function  GetFilterData: TFilterData;
  protected
    function  Get_ConditionList: IgsFilterConditionList; safecall;
    procedure Set_ConditionList(const Value: IgsFilterConditionList); safecall;
    function  Get_OrderByList: IgsFilterOrderByList; safecall;
    procedure Set_OrderByList(const Value: IgsFilterOrderByList); safecall;
    procedure Assign_(const Value: IgsFilterData); safecall;
    procedure Clear; safecall;
    function  Get_FilterText: WideString; safecall;
    function  Get_OrderText: WideString; safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
  end;

  TwrpFltStringList = class(TwrpObject, IgsFltStringList)
  private
    function  GetFltStringList: TFltStringList;
  protected
    function  Get_ValuesOfIndex(Index: Integer): WideString; safecall;
    procedure Set_ValuesOfIndex(Index: Integer; const Value: WideString); safecall;
    procedure RemoveDouble; safecall;
  end;

  TwrpFilterOrderBy = class(TwrpObject, IgsFilterOrderBy)
  private
    function  GetFilterOrderBy: TFilterOrderBy;
  protected
    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;
    function  Get_TableAlias: WideString; safecall;
    procedure Set_TableAlias(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_LocalField: WideString; safecall;
    procedure Set_LocalField(const Value: WideString); safecall;
    function  Get_IsAscending: WordBool; safecall;
    procedure Set_IsAscending(Value: WordBool); safecall;
    procedure Assign_(const Source: IgsFilterOrderBy); safecall;
    procedure Clear; safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
  end;

  TwrpFltFieldData = class(TwrpObject, IgsfltFieldData)
  private
    function  GetFltFieldData: TFltFieldData;
  protected
    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;
    function  Get_TableAlias: WideString; safecall;
    procedure Set_TableAlias(const Value: WideString); safecall;
    function  Get_PrimaryName: WideString; safecall;
    procedure Set_PrimaryName(const Value: WideString); safecall;
    function  Get_LocalTable: WideString; safecall;
    procedure Set_LocalTable(const Value: WideString); safecall;
    function  Get_FieldType: Integer; safecall;
    procedure Set_FieldType(Value: Integer); safecall;
    function  Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function  Get_LinkTable: WideString; safecall;
    procedure Set_LinkTable(const Value: WideString); safecall;
    function  Get_LinkSourceField: WideString; safecall;
    procedure Set_LinkSourceField(const Value: WideString); safecall;
    function  Get_LinkTargetField: WideString; safecall;
    procedure Set_LinkTargetField(const Value: WideString); safecall;
    function  Get_LinkTargetFieldType: Integer; safecall;
    procedure Set_LinkTargetFieldType(Value: Integer); safecall;
    function  Get_RefTable: WideString; safecall;
    procedure Set_RefTable(const Value: WideString); safecall;
    function  Get_RefField: WideString; safecall;
    procedure Set_RefField(const Value: WideString); safecall;
    function  Get_IsReference: WordBool; safecall;
    procedure Set_IsReference(Value: WordBool); safecall;
    function  Get_IsTree: WordBool; safecall;
    procedure Set_IsTree(Value: WordBool); safecall;
    function  Get_AttrKey: Integer; safecall;
    procedure Set_AttrKey(Value: Integer); safecall;
    function  Get_AttrRefKey: Integer; safecall;
    procedure Set_AttrRefKey(Value: Integer); safecall;
    procedure Assign_(const Source: IgsfltFieldData); safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
  end;

  TwrpFilterConditionList = class(TwrpList, IgsFilterConditionList)
  private
    function  GetFilterConditionList: TFilterConditionList;
  protected
    function  Get_IsAndCondition: WordBool; safecall;
    procedure Set_IsAndCondition(Value: WordBool); safecall;
    function  Get_IsDistinct: WordBool; safecall;
    procedure Set_IsDistinct(Value: WordBool); safecall;
    function  Get_FilterText: WideString; safecall;
    function  Get_Conditions(Index: Integer): IgsFilterCondition; safecall;
    function  AddCondition(const AnConditionData: IgsFilterCondition): Integer; safecall;
    function  AddConditionWithParams(const AnFieldData: IgsfltFieldData; AnConditionType: Integer;
                                     const AnValue1: WideString; const AnValue2: WideString;
                                     const AnSubFilter: IgsFilterConditionList;
                                     const AnValueList: IgsStringList): Integer; safecall;
    function  CheckCondition(const AnConditionData: IgsFilterCondition): WordBool; safecall;
    procedure DeleteCondition(Index: Integer); safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
    procedure Assign_(const Source: IgsFilterConditionList); safecall;
  end;

  TwrpFilterCondition = class(TwrpObject, IgsFilterCondition)
  private
    function  GetFilterCondition: TFilterCondition;
  protected
    function  Get_ConditionType: Integer; safecall;
    procedure Set_ConditionType(Value: Integer); safecall;
    function  Get_Value1: WideString; safecall;
    procedure Set_Value1(const Value: WideString); safecall;
    function  Get_Value2: WideString; safecall;
    procedure Set_Value2(const Value: WideString); safecall;
    function  Get_SubFilter: IgsFilterConditionList; safecall;
    procedure Set_SubFilter(const Value: IgsFilterConditionList); safecall;
    function  Get_ValueList: IgsStrings; safecall;
    procedure Set_ValueList(const Value: IgsStrings); safecall;
    procedure Clear; safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
    procedure Assign_(const Source: IgsFilterCondition); safecall;
  end;

  TwrpColumnExpand = class(TwrpCollectionItem, IgsColumnExpand)
  private
    function  GetColumnExpand: TColumnExpand;
  protected
    function  IsExpandValid(const ADataLink: IgsGridDataLink): WordBool; safecall;
    function  Get_Grid: IgsgsCustomDBGrid; safecall;
    function  Get_DisplayField: WideString; safecall;
    procedure Set_DisplayField(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_LineCount: Integer; safecall;
    procedure Set_LineCount(Value: Integer); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
  end;

  TwrpCondition = class(TwrpCollectionItem, IgsCondition)
  private
    function  GetCondition: TCondition;
  protected
    function  Suits(const DisplayField: IgsFieldComponent): WordBool; safecall;
    function  Get_Grid: IgsgsCustomDBGrid; safecall;
    function  Get_ConditionState: TgsConditionState; safecall;
    function  Get_IsValid: WordBool; safecall;
    function  Get_ConditionName: WideString; safecall;
    procedure Set_ConditionName(const Value: WideString); safecall;
    function  Get_DisplayFields: WideString; safecall;
    procedure Set_DisplayFields(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_Font: IgsFont; safecall;
    procedure Set_Font(const Value: IgsFont); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Expression1: WideString; safecall;
    procedure Set_Expression1(const Value: WideString); safecall;
    function  Get_Expression2: WideString; safecall;
    procedure Set_Expression2(const Value: WideString); safecall;
    function  Get_ConditionKind: TgsConditionKind; safecall;
    procedure Set_ConditionKind(Value: TgsConditionKind); safecall;
    function  Get_DisplayOptions: WideString; safecall;
    procedure Set_DisplayOptions(const Value: WideString); safecall;
    function  Get_EvaluateFormula: WordBool; safecall;
    procedure Set_EvaluateFormula(Value: WordBool); safecall;
    function  Get_UserCondition: WordBool; safecall;
    procedure Set_UserCondition(Value: WordBool); safecall;
  end;

  TwrpColumnExpands = class(TwrpCollection, IgsColumnExpands)
  private
    function  GetColumnExpands: TColumnExpands;
  protected
    function  Add: IgsColumnExpand; safecall;
    function  Get_Grid: IgsgsCustomDBGrid; safecall;
    function  Get_Items(Index: Integer): IgsColumnExpand; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsColumnExpand); safecall;
  end;

  TwrpGridConditions = class(TwrpCollection, IgsGridConditions)
  private
    function GetGridConditions: TGridConditions;
  protected
    function  Add: IgsCondition; safecall;
    function  Get_Grid: IgsgsCustomDBGrid; safecall;
    function  Get_Items(Index: Integer): IgsCondition; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsCondition); safecall;
  end;

  TwrpGridCheckBox = class(TwrpPersistent, IgsGridCheckBox)
  private
    function  GetGridCheckBox: TGridCheckBox;
  protected
    function  GetNamePath: WideString; safecall;
    procedure AddCheckInt(Value: Integer); safecall;
    procedure AddCheckStr(const Value: WideString); safecall;
    procedure DeleteCheckInt(Value: Integer); safecall;
    procedure DeleteCheckStr(const Value: WideString); safecall;
    procedure Clear; safecall;
    procedure BeginUpdate; safecall;
    procedure EndUpdate; safecall;
    function  Get_Grid: IgsgsCustomDBGrid; safecall;
    function  Get_CheckCount: Integer; safecall;
    function  Get_StrCheck(Index: Integer): WideString; safecall;
    function  Get_IntCheck(Index: Integer): Integer; safecall;
    function  Get_RecordChecked: WordBool; safecall;
    function  Get_DisplayField: WideString; safecall;
    procedure Set_DisplayField(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_CheckList: IgsStringList; safecall;
    procedure Set_CheckList(const Value: IgsStringList); safecall;
    function  Get_GlyphChecked: IgsBitmap; safecall;
    procedure Set_GlyphChecked(const Value: IgsBitmap); safecall;
    function  Get_GlyphUnChecked: IgsBitmap; safecall;
    procedure Set_GlyphUnChecked(const Value: IgsBitmap); safecall;
    function  Get_FirstColumn: WordBool; safecall;
    procedure Set_FirstColumn(Value: WordBool); safecall;
  end;

  TwrpLookup = class(TwrpPersistent, IgsLookup)
  private
    function  GetLookup: TLookup;
  protected
    function  Get_LookupListField: WideString; safecall;
    procedure Set_LookupListField(const Value: WideString); safecall;
    function  Get_LookupKeyField: WideString; safecall;
    procedure Set_LookupKeyField(const Value: WideString); safecall;
    function  Get_LookupTable: WideString; safecall;
    procedure Set_LookupTable(const Value: WideString); safecall;
    function  Get_Condition: WideString; safecall;
    procedure Set_Condition(const Value: WideString); safecall;
    function  Get_GroupBY: WideString; safecall;
    procedure Set_GroupBY(const Value: WideString); safecall;
    function  Get_CheckUserRights: WordBool; safecall;
    procedure Set_CheckUserRights(Value: WordBool); safecall;
    function  Get_SortOrder: TgsgsSortOrder; safecall;
    procedure Set_SortOrder(Value: TgsgsSortOrder); safecall; 
    function  Get_gdClassName: WideString; safecall;
    procedure Set_gdClassName(const Value: WideString); safecall;
    function  Get_SubType: WideString; safecall;
    procedure Set_SubType(const Value: WideString); safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_IsTree: WordBool; safecall;
    function  Get_ParentField: WideString; safecall;
    function  Get_Fields: WideString; safecall;
    procedure Set_Fields(const Value: WideString); safecall;
    function  Get_Params: IgsStrings; safecall;
    function  Get_Distinct: WordBool; safecall;
    procedure Set_Distinct(Value: WordBool); safecall;
    function  Get_FullSearchOnExit: WordBool; safecall;
    procedure Set_FullSearchOnExit(Value: WordBool); safecall;
    function  Get_ViewType: TgsgsViewType; safecall;
    procedure Set_ViewType(Value: TgsgsViewType); safecall;

  end;

  TwrpSet = class(TwrpPersistent, IgsSet)
  private
    function  GetSet: TSet;
  protected
    function  Get_KeyField: WideString; safecall;
    procedure Set_KeyField(const Value: WideString); safecall;
    function  Get_SourceKeyField: WideString; safecall;
    procedure Set_SourceKeyField(const Value: WideString); safecall;
    function  Get_SourceListField: WideString; safecall;
    procedure Set_SourceListField(const Value: WideString); safecall;
    function  Get_SourceParentField: WideString; safecall;
    procedure Set_SourceParentField(const Value: WideString); safecall;
    function  Get_CrossDestField: WideString; safecall;
    procedure Set_CrossDestField(const Value: WideString); safecall;
    function  Get_CrossSourceField: WideString; safecall;
    procedure Set_CrossSourceField(const Value: WideString); safecall;
    function  Get_SourceTable: WideString; safecall;
    procedure Set_SourceTable(const Value: WideString); safecall;
    function  Get_CrossTable: WideString; safecall;
    procedure Set_CrossTable(const Value: WideString); safecall;
  end;

  TwrpIBColumnEditor = class(TwrpCollectionItem, IgsIBColumnEditor)
  private
    function  GetIBColumnEditor: TgsIBColumnEditor;
  protected
    function  Get_Grid: IgsGsCustomIBGrid; safecall;
    function  Get_Text: WideString; safecall;
    function  Get_Lookup: IgsLookup; safecall;
    procedure Set_Lookup(const Value: IgsLookup); safecall;
    function  Get_LookupSet: IgsSet; safecall;
    procedure Set_LookupSet(const Value: IgsSet); safecall;
    function  Get_EditorStyle: TgsgsIBColumnEditorStyle; safecall;
    procedure Set_EditorStyle(Value: TgsgsIBColumnEditorStyle); safecall;
    function  Get_DisplayField: WideString; safecall;
    procedure Set_DisplayField(const Value: WideString); safecall;
    function  Get_ValueList: IgsStringList; safecall;
    procedure Set_ValueList(const Value: IgsStringList); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;

    function  Get_DropDownCount: Integer; safecall;
    procedure Set_DropDownCount(Value: Integer); safecall;
  end;

  TwrpIBColumnEditors = class(TwrpCollection, IgsIBColumnEditors)
  private
    function  GetIBColumnEditors: TgsIBColumnEditors;
  protected
    function  IndexByField(const Name: WideString): Integer; safecall;
    function  Add: IgsIBColumnEditor; safecall;
    function  Get_Grid: IgsGsCustomIBGrid; safecall;
    function  Get_Items(Index: Integer): IgsIBColumnEditor; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsIBColumnEditor); safecall;
  end;

  TwrpCustomDBGrid = class(TwrpCustomGrid, IgsCustomDBGrid)
  private
    function GetCustomDBGrid: TCustomDBGrid;
  protected
    function  Get_FieldCount: Integer; safecall;
    function  Get_SelectedIndex: Integer; safecall;
    procedure Set_SelectedIndex(Value: Integer); safecall;
    function  ValidFieldIndex(FieldIndex: Integer): WordBool; safecall;
    function  Get_IndicatorOffset: Smallint; safecall;
    function  Get_LayoutLock: Smallint; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_TitleFont: IFontDisp; safecall;
    procedure Set_TitleFont(const Value: IFontDisp); safecall;
    function  Get_SelectedField: IgsFieldComponent; safecall;
    procedure Set_SelectedField(const Value: IgsFieldComponent); safecall;
    function  Get_SelectedRows: IgsBookmarkList; safecall;

    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Fields(Index: Integer): IgsFieldComponent; safecall;
    procedure ExecuteAction(const Action: IgsBasicAction); safecall;
    procedure ShowPopupEditor(const Column: IgsColumn; X: Integer; Y: Integer); safecall;
    function  Get_Columns: IgsDBGridColumns; safecall;
    procedure Set_Columns(const Value: IgsDBGridColumns); safecall;
    function  Get_Options_: WideString; safecall;
    procedure Set_Options_(const Value: WideString); safecall;

    procedure DefaultDrawColumnCell(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
                                    DataCol: Integer; const Column: IgsColumn;
                                    const State: WideString); safecall;

  end;

  TwrpgsCustomDBGrid = class(TwrpCustomDBGrid, IgsgsCustomDBGrid)
  private
    function  GetgsCustomDBGrid: TgsCustomDBGrid;
  protected
    procedure AddCheck; safecall;
    procedure ValidateColumns; safecall;
    function  Get_FormName: WideString; safecall;
    function  Get_GDObject: IgsGDCBase; safecall;
    function  Get_SettingsModified: WordBool; safecall;
    function  Get_DontLoadSettings: WordBool; safecall;
    procedure Set_DontLoadSettings(Value: WordBool); safecall;
    procedure PrepareMaster(const AMaster: IgsForm); safecall;
    procedure SetupGrid(const AMaster: IgsForm; UpdateGrid: WordBool); safecall;
    procedure AfterConstruct; safecall;
    function  Get_CheckBox: IgsGridCheckBox; safecall;
    procedure Set_CheckBox(const Value: IgsGridCheckBox); safecall;

    procedure Read(const Reader: IgsReader); safecall;
    procedure Write(const Writer: IgsWriter); safecall;
    procedure GridCoordFromMouse(out X: OleVariant; out Y: OleVariant); safecall;
    function  ColumnByField(const Field: IgsFieldComponent): IgsColumn; safecall;
    procedure LoadFromStream(const Stream: IgsStream); safecall;
    procedure SaveToStream(const Stream: IgsStream); safecall;
    function  Get_GroupFieldName: WideString; safecall;
    procedure Set_GroupFieldName(const Value: WideString); safecall;
    procedure ResizeColumns; safecall;
    function  Get_Conditions: IgsGridConditions; safecall;
    procedure Set_Conditions(const Value: IgsGridConditions); safecall;
    function  Get_ConditionsActive: WordBool; safecall;
    procedure Set_ConditionsActive(Value: WordBool); safecall;
  end;

  TwrpGsCustomIBGrid = class(TwrpgsCustomDBGrid, IgsGsCustomIBGrid)
  private
    function GetCustomIBGrid: TgsCustomIBGrid;
  protected
    function  Get_Aliases: IgsFieldAliases; safecall;
    procedure Set_Aliases(const Value: IgsFieldAliases); safecall;
    function  Get_ColumnEditors: IgsIBColumnEditors; safecall;
    procedure Set_ColumnEditors(const Value: IgsIBColumnEditors); safecall;

  end;

  TwrpGsIBGrid = class(TwrpGsCustomIBGrid, IgsGsIBGrid)
  private
    function  GetIBGrid: TgsIBGrid;
  protected
    function  Get_TableFont: IFontDisp; safecall;
    procedure Set_TableFont(const Value: IFontDisp); safecall;
    function  Get_TableColor: Integer; safecall;
    procedure Set_TableColor(Value: Integer); safecall;
    function  Get_SelectedFont: IFontDisp; safecall;
    procedure Set_SelectedFont(const Value: IFontDisp); safecall;
    function  Get_SelectedColor: Integer; safecall;
    procedure Set_SelectedColor(Value: Integer); safecall;
    function  Get_TitleColor: Integer; safecall;
    procedure Set_TitleColor(Value: Integer); safecall;
    function  Get_RefreshType: TgsRefreshType; safecall;
    procedure Set_RefreshType(Value: TgsRefreshType); safecall;
    function  Get_Striped: WordBool; safecall;
    procedure Set_Striped(Value: WordBool); safecall;
    function  Get_StripeOdd: Integer; safecall;
    procedure Set_StripeOdd(Value: Integer); safecall;
    function  Get_StripeEven: Integer; safecall;
    procedure Set_StripeEven(Value: Integer); safecall;
    function  Get_ExpandsActive: WordBool; safecall;
    procedure Set_ExpandsActive(Value: WordBool); safecall;
    function  Get_ExpandsSeparate: WordBool; safecall;
    procedure Set_ExpandsSeparate(Value: WordBool); safecall;
    function  Get_ScaleColumns: WordBool; safecall;
    procedure Set_ScaleColumns(Value: WordBool); safecall;
    function  Get_MinColWidth: Integer; safecall;
    procedure Set_MinColWidth(Value: Integer); safecall;
    function  Get_FinishDrawing: WordBool; safecall;
    procedure Set_FinishDrawing(Value: WordBool); safecall;
    function  Get_RememberPosition: WordBool; safecall;
    procedure Set_RememberPosition(Value: WordBool); safecall;
    function  Get_SaveSettings: WordBool; safecall;
    procedure Set_SaveSettings(Value: WordBool); safecall;
    function  Get_InternalMenuKind: TgsInternalMenuKind; safecall;
    procedure Set_InternalMenuKind(Value: TgsInternalMenuKind); safecall;
    function  Get_Expands: IgsColumnExpands; safecall;
    procedure Set_Expands(const Value: IgsColumnExpands); safecall;
    function  Get_ToolBar: IgsToolBar; safecall;
    procedure Set_ToolBar(const Value: IgsToolBar); safecall;
    function  Get_TitlesExpanding: WordBool; safecall;
    procedure Set_TitlesExpanding(Value: WordBool); safecall;

  end;

  TwrpIBLookupComboBoxX = class(TwrpCustomComboBox, IgsIBLookupComboBoxX)
  private
    function  GetIBLookupComboBoxX: TgsIBLookupComboBox;
  protected
    procedure DoLookup(Exact: WordBool); safecall;
    procedure CreateNew; safecall;
    procedure ViewForm; safecall;
    procedure Edit; safecall;
    procedure ObjectProperties; safecall;
    procedure Delete; safecall;
    procedure Reduce; safecall;
    function  Get_CurrentKey: WideString; safecall;
    procedure Set_CurrentKey(const Value: WideString); safecall;
    function  Get_CurrentKeyInt: Integer; safecall;
    procedure Set_CurrentKeyInt(Value: Integer); safecall;
    function  Get_DropDownDialogWidth: Integer; safecall;
    procedure Set_DropDownDialogWidth(Value: Integer); safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_Fields: WideString; safecall;
    procedure Set_Fields(const Value: WideString); safecall;
    function  Get_ListTable: WideString; safecall;
    procedure Set_ListTable(const Value: WideString); safecall;
    function  Get_ListField: WideString; safecall;
    procedure Set_ListField(const Value: WideString); safecall;
    function  Get_KeyField: WideString; safecall;
    procedure Set_KeyField(const Value: WideString); safecall;
    function  Get_Condition: WideString; safecall;
    procedure Set_Condition(const Value: WideString); safecall;
    function  Get_gdClassName: WideString; safecall;
    procedure Set_gdClassName(const Value: WideString); safecall;
    function  Get_CheckUserRights: WordBool; safecall;
    procedure Set_CheckUserRights(Value: WordBool); safecall;
    function  Get_ValidObject: WordBool; safecall;
    function  Get_SubType: WideString; safecall;
    procedure Set_SubType(const Value: WideString); safecall;
    function  Get_SortOrder: TgsgsSortOrder; safecall;
    procedure Set_SortOrder(Value: TgsgsSortOrder); safecall;
    function  Get_SortField: WideString; safecall;
    procedure Set_SortField(const Value: WideString); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_gdClass: WideString; safecall;
    function  Get__Field: IgsFieldComponent; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
    function  Get_Params: IgsStrings; safecall;
    function  Get_Distinct: WordBool; safecall;
    procedure Set_Distinct(Value: WordBool); safecall;
    function  Get_FullSearchOnExit: WordBool; safecall;
    procedure Set_FullSearchOnExit(Value: WordBool); safecall;
    function  Get_ShowDisabled: WordBool; safecall;
    procedure Set_ShowDisabled(Value: WordBool); safecall;
  end;

  TwrpXDateEdit = class(TwrpMaskEdit, IgsXDateEdit)
  private
    function GetXDateEdit: TxDateEdit;
  protected
    function  DaysCount(nMonth: Word; nYear: Word): Integer; safecall;
    procedure GetDateInStr(aDate: TDateTime; var sYear: OleVariant; var sMonth: OleVariant;
                           var sDay: OleVariant); safecall;
    procedure GetTimeInStr(aTime: TDateTime; var sHour: OleVariant; var sMin: OleVariant;
                           var sSec: OleVariant); safecall;
    function  GetLength: Word; safecall;
    function  Get_Date: TDateTime; safecall;
    procedure Set_Date(Value: TDateTime); safecall;
    function  Get_Time: TDateTime; safecall;
    procedure Set_Time(Value: TDateTime); safecall;
    function  Get_DateTime: TDateTime; safecall;
    procedure Set_DateTime(Value: TDateTime); safecall;
    function  Get_CurrentDateTimeAtStart: WordBool; safecall;
    procedure Set_CurrentDateTimeAtStart(Value: WordBool); safecall;
    function  Get_EmptyAtStart: WordBool; safecall;
    procedure Set_EmptyAtStart(Value: WordBool); safecall;
    function  Get_Year: Word; safecall;
    procedure Set_Year(Value: Word); safecall;
    function  Get_Month: Word; safecall;
    procedure Set_Month(Value: Word); safecall;
    function  Get_Day: Word; safecall;
    procedure Set_Day(Value: Word); safecall;
    function  Get_Hour: Word; safecall;
    procedure Set_Hour(Value: Word); safecall;
    function  Get_Min: Word; safecall;
    procedure Set_Min(Value: Word); safecall;
    function  Get_Sec: Word; safecall;
    procedure Set_Sec(Value: Word); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Kind: TgsKind; safecall;
    procedure Set_Kind(Value: TgsKind); safecall;
  end;

  TwrpXDateDBEdit = class(TwrpXDateEdit, IgsXDateDBEdit)
  private
    function  GetXDateDBEdit: TxDateDBEdit;
  protected
    procedure Change; safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
  end;

  TwrpGsSQLFilter = class(TwrpComponent, IgsGsSQLFilter)
  private
    function  GetSQLFilter: TgsSQLFilter;
  protected
    procedure SetQueryText(const AnSQLText: WideString); safecall;
    function  CreateSQL: WordBool; safecall;
    function  AddFilter(out AnFilterKey: OleVariant): WordBool; safecall;
    function  EditFilter(out AnFilterKey: OleVariant): WordBool; safecall;
    function  DeleteFilter: WordBool; safecall;
    procedure DeleteCondition(AnIndex: Integer); safecall;
    procedure ClearConditions; safecall;
    procedure DeleteOrderBy(AnIndex: Integer); safecall;
    procedure ClearOrdersBy; safecall;
    function  Get_SelectText: IgsStrings; safecall;
    function  Get_FromText: IgsStrings; safecall;
    function  Get_WhereText: IgsStrings; safecall;
    function  Get_OtherText: IgsStrings; safecall;
    function  Get_OrderText: IgsStrings; safecall;
    function  Get_FilteredSQL: IgsStrings; safecall;
    function  Get_FilterName: WideString; safecall;
    function  Get_FilterComment: WideString; safecall;
    function  Get_LastExecutionTime: Double; safecall;
    function  Get_CurrentFilter: Integer; safecall;
    function  Get_FilterSrting: WideString; safecall;
    function  Get_ConditionCount: Integer; safecall;
    function  Get_OrderByCount: Integer; safecall;
    function  Get_NoVisibleList: IgsStrings; safecall;
    function  Get_Conditions(Index: Integer): IgsFilterCondition; safecall;
    procedure Set_Conditions(Index: Integer; const Value: IgsFilterCondition); safecall;
    function  Get_OrdersBy(Index: Integer): IgsFilterOrderBy; safecall;
    procedure Set_OrdersBy(Index: Integer; const Value: IgsFilterOrderBy); safecall;

    function  Get_TableList: IgsFltStringList; safecall;
    procedure Set_TableList(const Value: IgsFltStringList); safecall;
    function  Get_FilterData: IgsFilterData; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_RequeryParams: WordBool; safecall;
    procedure Set_RequeryParams(Value: WordBool); safecall;
    function  AddCondition(const FilterCondition: IgsFilterCondition): Integer; safecall;
    function  AddOrderBy(const OrderBy: IgsFilterOrderBy): Integer; safecall;
    procedure ReadFromStream(const S: IgsStream); safecall;
    procedure WriteToStream(const S: IgsStream); safecall;
    function  Get_FilterString: WideString; safecall;
    procedure LoadFilter(FilterKey: Integer); safecall;
    function  Get_ComponentKey: Integer; safecall;
  end;

  TwrpGsQueryFilter = class(TwrpGsSQLFilter, IgsGsQueryFilter)
  private
    function  GetQueryFilter: TgsQueryFilter;
  protected
    function  Get_RecordCount: Integer; safecall;
    procedure FilterQuery(SilentParam: OleVariant); safecall;
    procedure RevertQuery; safecall;
    procedure SaveLastFilter; safecall;
    procedure LoadLastFilter; safecall;
    procedure CreatePopupMenu; safecall;
    procedure PopupMenu(x: Integer; y: Integer); safecall;

    procedure CreateFilterExecute; safecall;
    procedure EditFilterExecute; safecall;
    procedure DeleteFilterExecute; safecall;
    procedure FilterBackExecute; safecall;
    procedure ViewFilterListExecute; safecall;
    procedure ShowRecordCountExecute; safecall;
    procedure RefreshExecute; safecall;
    function  Get_IBDataSet: IgsIBCustomDataSet; safecall;
    procedure Set_IBDataSet(const Value: IgsIBCustomDataSet); safecall;
    function  Get_LastQueriedParams: OleVariant; safecall;
  end;

  TwrpQueryFilterGDC = class(TwrpGsQueryFilter, IgsQueryFilterGDC)
  end;

  TwrpGsStorage = class(TwrpObject, IgsGsStorage)
  private
    function GetStorage: TgsStorage;
  protected
    procedure LoadFromFile(const AFileName: WideString; AFileFormat: OleVariant); safecall;
    procedure SaveToFile(const AFileName: WideString; AFileFormat: OleVariant); safecall;
    procedure Clear; safecall;
    function  FolderExists(const APath: WideString): WordBool; safecall;
    function  ValueExists(const APath: WideString; const AValue: WideString): WordBool; safecall;
    function  ReadCurrency(const APath: WideString; const AValue: WideString; Default: Currency): Currency; safecall;
    function  ReadInteger(const APath: WideString; const AValue: WideString; Default: Integer): Integer; safecall;
    function  ReadDateTime(const APath: WideString; const AValue: WideString; Default: TDateTime): TDateTime; safecall;
    function  ReadBoolean(const APath: WideString; const AValue: WideString; Default: WordBool): WordBool; safecall;
    function  ReadString(const APath: WideString; const AValue: WideString;
                         const Default: WideString): WideString; safecall;
    procedure WriteString(const APath: WideString; const AValueName: WideString;
                          const AValue: WideString); safecall;
    procedure WriteInteger(const APath: WideString; const AValueName: WideString; AValue: Integer); safecall;
    procedure WriteCurrency(const APath: WideString; const AValueName: WideString; AValue: Currency); safecall;
    procedure WriteBoolean(const APath: WideString; const AValueName: WideString; AValue: WordBool); safecall;
    procedure WriteDateTime(const APath: WideString; const AValueName: WideString; AValue: TDateTime); safecall;
    procedure LoadFromDataBase; safecall;
    procedure SaveToDataBase; safecall;
    function  Get_DataString: WideString; safecall;
    procedure Set_DataString(const Value: WideString); safecall;
    function  Get_IsModified: WordBool; safecall;

    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
    procedure LoadFromStream2(const S: IgsStringStream); safecall;
    procedure SaveToStream2(const S: IgsStringStream); safecall;
    procedure BuildTreeView(const N: IgsTreeNode); safecall;
    function  OpenFolder(const APath: WideString; CanCreate: WordBool; SyncWithDatabase: WordBool): IgsGsStorageFolder; safecall;
    procedure CloseFolder(const gsStorageFolder: IgsGsStorageFolder; SyncWithDatabase: WordBool); safecall;
    function  ReadStream(const APath: WideString; const AValue: WideString; const S: IgsStream): WordBool; safecall;
    procedure WriteStream(const APath: WideString; const AValueName: WideString;
                          const AValue: IgsStream); safecall;
    function  Get_Name: WideString; safecall;
    function  BuildComponentPath(const C: IgsComponent; const Context: WideString): WideString; safecall;
  end;

  TwrpGsIBStorage = class(TwrpGsStorage, IgsGsIBStorage)
  end;

  TwrpGsGlobalStorage = class(TwrpGsIBStorage, IgsGsGlobalStorage)
  end;

  TwrpGsCompanyStorage = class(TwrpGsIBStorage, IgsGsCompanyStorage)
  private
    function GetGsCompanyStorage: TgsCompanyStorage;
  protected
    function  Get_CompanyKey: Integer; safecall;
    procedure Set_CompanyKey(Value: Integer); safecall;
  end;

  TwrpGsUserStorage = class(TwrpGsIBStorage, IgsGsUserStorage)
  private
    function GetGsUserStorage: TgsUserStorage;
  protected
    function  Get_UserKey: Integer; safecall;
    procedure Set_UserKey(Value: Integer); safecall;
  end;


  TwrpTBDock = class(TwrpCustomControl, IgsTBDock)
  private
    function GetTBDock: TTBDock;
  protected
    procedure ArrangeToolbars; safecall;
    procedure BeginUpdate; safecall;
    procedure EndUpdate; safecall;
    function  GetCurrentRowSize(Row: Integer; var AFullSize: OleVariant): Integer; safecall;
    function  GetHighestRow(HighestEffective: WordBool): Integer; safecall;
    function  Get_CommitNewPositions: WordBool; safecall;
    procedure Set_CommitNewPositions(Value: WordBool); safecall;
    function  Get_NonClientWidth: Integer; safecall;
    function  Get_NonClientHeight: Integer; safecall;
    function  Get_ToolbarCount: Integer; safecall;
    function  Get_AllowDrag: WordBool; safecall;
    procedure Set_AllowDrag(Value: WordBool); safecall;
    function  Get_BackgroundOnToolbars: WordBool; safecall;
    procedure Set_BackgroundOnToolbars(Value: WordBool); safecall;
    function  Get_FixAlign: WordBool; safecall;
    procedure Set_FixAlign(Value: WordBool); safecall;
    function  Get_LimitToOneRow: WordBool; safecall;
    procedure Set_LimitToOneRow(Value: WordBool); safecall;
    function  Get_Position: TgsTBDockPosition; safecall;
    procedure Set_Position(Value: TgsTBDockPosition); safecall;

    function  Get_Toolbars(Index: Integer): IgsTBCustomDockableWindow; safecall;
    function  Get_Background: IgsTBBasicBackground; safecall;
    procedure Set_Background(const Value: IgsTBBasicBackground); safecall;
    function  GetMinRowSize(Row: Integer; const ExcludeControl: IgsTBCustomDockableWindow): Integer; safecall;
    function  Get_BoundLines: WideString; safecall;
    procedure Set_BoundLines(const Value: WideString); safecall;
  end;

  TwrpTBCustomDockableWindow = class(TwrpCustomControl, IgsTBCustomDockableWindow)
  private
    function GetTBCustomDockableWindow: TTBCustomDockableWindow;
  protected
    function  Get_ActivateParent: WordBool; safecall;
    procedure Set_ActivateParent(Value: WordBool); safecall;
    function  Get_CloseButton: WordBool; safecall;
    procedure Set_CloseButton(Value: WordBool); safecall;
    function  Get_CloseButtonWhenDocked: WordBool; safecall;
    procedure Set_CloseButtonWhenDocked(Value: WordBool); safecall;
    function  Get_DockMode: TgsTBDockMode; safecall;
    procedure Set_DockMode(Value: TgsTBDockMode); safecall;
    function  Get_DragHandleStyle: TgsTBDragHandleStyle; safecall;
    procedure Set_DragHandleStyle(Value: TgsTBDragHandleStyle); safecall;
    function  Get_FloatingMode: TgsTBFloatingMode; safecall;
    procedure Set_FloatingMode(Value: TgsTBFloatingMode); safecall;
    function  Get_FullSize: WordBool; safecall;
    procedure Set_FullSize(Value: WordBool); safecall;
    function  Get_HideWhenInactive: WordBool; safecall;
    procedure Set_HideWhenInactive(Value: WordBool); safecall;
    function  Get_Resizable: WordBool; safecall;
    procedure Set_Resizable(Value: WordBool); safecall;
    function  Get_ShowCaption: WordBool; safecall;
    procedure Set_ShowCaption(Value: WordBool); safecall;
    function  Get_SmoothDrag: WordBool; safecall;
    procedure Set_SmoothDrag(Value: WordBool); safecall;
    function  Get_UseLastDock: WordBool; safecall;
    procedure Set_UseLastDock(Value: WordBool); safecall;
    function  PaletteChanged_(Foreground: WordBool): WordBool; safecall;
    procedure Arrange; safecall;
    procedure ChangeSize(AWidth: Integer; AHeight: Integer); safecall;
    procedure DoubleClick; safecall;
    procedure GetMinMaxSize(AMinClientWidth: Integer; AMinClientHeight: Integer;
                            AMaxClientWidth: Integer; AMaxClientHeight: Integer); safecall;
    function  IsAutoResized: WordBool; safecall;
    procedure SizeChanging(AWidth: Integer; AHeight: Integer); safecall;
    function  Get_Docked: WordBool; safecall;
    function  Get_CurrentSize: Integer; safecall;
    procedure Set_CurrentSize(Value: Integer); safecall;
    function  Get_DockPos: Integer; safecall;
    procedure Set_DockPos(Value: Integer); safecall;
    function  Get_DockRow: Integer; safecall;
    procedure Set_DockRow(Value: Integer); safecall;
    function  Get_EffectiveDockPos: Integer; safecall;
    function  Get_EffectiveDockRow: Integer; safecall;
    function  Get_TBFloating: WordBool; safecall;
    procedure Set_TBFloating(Value: WordBool); safecall;
    function  Get_NonClientWidth: Integer; safecall;
    function  Get_NonClientHeight: Integer; safecall;
    procedure SetBounds_(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); safecall;
    procedure BeginMoving(InitX: Integer; InitY: Integer); safecall;
    function  IsMovable: WordBool; safecall;

    function  Get_CurrentDock: IgsTBDock; safecall;
    procedure Set_CurrentDock(const Value: IgsTBDock); safecall;
    function  Get_LastDock: IgsTBDock; safecall;
    procedure Set_LastDock(const Value: IgsTBDock); safecall;
    function  GetParentComponent: IgsComponent; safecall;
    procedure AddDockForm(const Form: IgsTBCustomForm); safecall;
    procedure BeginSizing(ASizeHandle: TgsTBSizeHandle); safecall;
    procedure MoveOnScreen(OnlyIfFullyOffscreen: WordBool); safecall;
    procedure RemoveDockForm(const Form: IgsTBCustomForm); safecall;
    function  Get_DefaultDock: IgsTBDock; safecall;
    procedure Set_DefaultDock(const Value: IgsTBDock); safecall;
    function  Get_DockableTo: WideString; safecall;
    procedure Set_DockableTo(const Value: WideString); safecall;
    function  Get_Stretch: WordBool; safecall;
    procedure Set_Stretch(Value: WordBool); safecall;
    procedure BeginUpdate; safecall;
    procedure EndUpdate; safecall;
  end;

  TwrpTBCustomToolbar = class(TwrpTBCustomDockableWindow, IgsTBCustomToolbar)
  private
    function  GetTBCustomToolbar: TTBCustomToolbar;
  protected
    function  GetShrinkMode: TgsTBShrinkMode; safecall;
    procedure Loaded; safecall;
    procedure ResizeTrackAccept; safecall;
    procedure ResizeEnd; safecall;
    function  Get_SystemFont: WordBool; safecall;
    procedure Set_SystemFont(Value: WordBool); safecall;
    procedure CreateWrappersForAllControls; safecall;
    procedure InitiateAction_; safecall;
    function  KeyboardOpen(Key: Shortint; RequirePrimaryAccel: WordBool): WordBool; safecall;
    function  Get_FloatingWidth: Integer; safecall;
    procedure Set_FloatingWidth(Value: Integer); safecall;
    function  Get_MenuBar: WordBool; safecall;
    procedure Set_MenuBar(Value: WordBool); safecall;
    function  Get_ProcessShortCuts: WordBool; safecall;
    procedure Set_ProcessShortCuts(Value: WordBool); safecall;
    function  Get_ShrinkMode: TgsTBShrinkMode; safecall;
    procedure Set_ShrinkMode(Value: TgsTBShrinkMode); safecall;
    function  Get_UpdateActions: WordBool; safecall;
    procedure Set_UpdateActions(Value: WordBool); safecall;

    function  Get_ChevronHint: WideString; safecall;
    procedure Set_ChevronHint(const Value: WideString); safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_Items: IgsTBRootItem; safecall;
    function  Get_LinkSubitems: IgsTBCustomItem; safecall;
    procedure Set_LinkSubitems(const Value: IgsTBCustomItem); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
    function  Get_View: IgsTBToolbarView; safecall;
  end;

  TwrpTBToolbar = class(TwrpTBCustomToolbar, IgsTBToolbar)
  end;

  TwrpGDCBase = class(TwrpIBCustomDataSet, IgsGDCBase)
  private
    function  GetGDCBase: TgdcBase;

  protected
    procedure Prepare; safecall;
    procedure PopupReportMenu(X: Integer; Y: Integer); safecall;
    procedure PopupFilterMenu(X: Integer; Y: Integer); safecall;
    procedure Find; safecall;
    function  CreateDialog(const ADlgClassName: WideString): WordBool; safecall;
    function  CreateDialogSubType(const AClassName: WideString; const ASubType: WideString): WordBool; safecall;
    function  CreateDescendant: WordBool; safecall;
    function  CopyDialog: WordBool; safecall;
    function  EditDialog(const ADlgClassName: WideString): WordBool; safecall;
    function  Copy(const AFields: WideString; AValues: OleVariant; ACopyDetail: WordBool;
                   APost: WordBool): WordBool; safecall;
    procedure CreateNext; safecall;
    procedure AssignField(AnID: Integer; const AFieldName: WideString; AValue: OleVariant); safecall;
    function  HideFieldsList: WideString; safecall;
    function  ShowFieldInGrid(const AField: IgsFieldComponent): WordBool; safecall;
    procedure CloseOpen; safecall;
    procedure SaveToFile(const AFileName: WideString); safecall;
    procedure SaveToFile2(const AFileName: WideString; const ADetail: IgsGDCBase; const BL: IgsBookmarkList; OnlyCurrent: WordBool); safecall;
    procedure LoadFromFile(const AFileName: WideString); safecall;
    function  Reduction(const BL: IgsBookmarkList): WordBool; safecall;
    function  GetListNameByID(AnID: Integer): WideString; safecall;
    procedure SetRefreshSQLOn(SetOn: WordBool); safecall;
    procedure GetDistinctColumnValues(const AFieldName: WideString; const S: IgsStrings;
                                      DoSort: WordBool); safecall;
    function  GetNextID(Increment: WordBool): Integer; safecall;
    function  HasAttribute: WordBool; safecall;
    procedure RefreshStats; safecall;
    function  IsBigTable: WordBool; safecall;
    function  GetListTable(const ASubType: WideString): WideString; safecall;
    function  GetListField(const ASubType: WideString): WideString; safecall;
    function  GetListTableAlias: WideString; safecall;
    function  GetKeyField(const ASubType: WideString): WideString; safecall;
    function  GetRestrictCondition(const ATableName: WideString; const ASubType: WideString): WideString; safecall;
    function  GetDisplayName(const ASubType: WideString): WideString; safecall;
    function  GetSubTypeList(const SubTypeList: IgsStrings): WordBool; safecall;
    function  GetSubSetList: WideString; safecall;
    function  RelationByAliasName(const AnAliasName: WideString): WideString; safecall;
    function  FieldNameByAliasName(const AnAliasName: WideString): WideString; safecall;
    function  Get_ID: Integer; safecall;
    procedure Set_ID(Value: Integer); safecall;
    function  Get_ObjectName: WideString; safecall;
    procedure Set_ObjectName(const Value: WideString); safecall;
    function  Get_AggregatesActive: WordBool; safecall;
    procedure Set_AggregatesActive(Value: WordBool); safecall;
    function  Get_DetailClassesCount: Integer; safecall;
    function  Get_DetailLinksCount: Integer; safecall;
    function  Get_GroupID: Integer; safecall;
    function  Get_HasWhereClause: WordBool; safecall;
    function  Get_SubType: WideString; safecall;
    procedure Set_SubType(const Value: WideString); safecall;
    function  Get_MasterField: WideString; safecall;
    procedure Set_MasterField(const Value: WideString); safecall;
    function  Get_DetailField: WideString; safecall;
    procedure Set_DetailField(const Value: WideString); safecall;
    function  Get_NameInScript: WideString; safecall;
    procedure Set_NameInScript(const Value: WideString); safecall;
    function  ParamByName(const Idx: WideString): IgsIBXSQLVAR; safecall;
    function  Get_CreationDate: TDateTime; safecall;
    function  Get_CreatorKey: Integer; safecall;
    function  Get_CreatorName: WideString; safecall;
    function  Get_EditionDate: TDateTime; safecall;
    function  Get_EditorKey: Integer; safecall;
    function  Get_EditorName: WideString; safecall;
    function  Get_ExtraConditions: IgsStrings; safecall;
    function  Get_SelectedID: IgsGDKeyArray; safecall;
    function  Get_DSModified: WordBool; safecall;
    function  Get_MasterSource: IgsDataSource; safecall;
    procedure Set_MasterSource(const Value: IgsDataSource); safecall;
    function  Get_SubSet: WideString; safecall;
    procedure Set_SubSet(const Value: WideString); safecall;
    function  Get_DialogActions: WideString; safecall;
    procedure Set_DialogActions(const Value: WideString); safecall;
    function  CreateViewForm(const AnOwner: IgsComponent; const AClassName: WideString;
                             const ASubType: WideString): IgsForm; safecall;
    function  CreateViewFormNewInstance(const AnOwner: IgsComponent; const AClassName: WideString;
                             const ASubType: WideString; ANewInstance: WordBool): IgsForm; safecall;
    function  GetViewFormClassName(const ASubType: WideString): WideString; safecall;
    function  CreateSingularByID(const AnOwner: IgsComponent; const ADatabase: IgsIBDatabase;
                                 const ATransaction: IgsIBTransaction; AnID: Integer;
                                 const ASubType: WideString): IgsGDCBase; safecall;
    function  CreateDialogForm: IgsCreateableForm; safecall;
    procedure GetWhereClauseConditions(const S: IgsStrings); safecall;
    procedure DoOnNewRecord_; safecall;
    function  CommitRequired: WordBool; safecall;
//    function  Get_ExtraCondition: IgsStrings; safecall;
    function  GetNotCopyField: WideString; safecall;
    function  Get_DetailLinks(Index: Integer): IgsGDCBase; safecall;
    function  ChooseItems(const Cl: WideString; const KeyArray: IgsGDKeyArray; DoProcess: WordBool;
                          const ChooseComponentName: WideString; const ChooseSubSet: WideString;
                          const ChooseSubType: WideString): WordBool; safecall;
    function  ChooseItemsSelf(DoProcess: WordBool; const ChooseComponentName: WideString;
                              const ChooseSubSet: WideString): WordBool; safecall;

    function  ChooseOrderItems(const Cl: WideString; const KA: IgsGDKeyArray;
                               var AChosenIDInOrder: OleVariant;
                               const ChooseComponentName: WideString;
                               const ChooseSubSet: WideString; const ChooseSubType: WideString;
                               const ChooseExtraConditions: WideString): WordBool; safecall;
    function  ChooseOrderItemsSelf(var AChosenIDInOrder: OleVariant;
                                   const ChooseComponentName: WideString;
                                   const ChooseSubSet: WideString;
                                   const ChooseExtraConditions: WideString): WordBool; safecall;


    function  Get_ParentForm: IgsWinControl; safecall;
    function  Get_Aggregates: IgsGdcAggregates; safecall;
    function  Get_DetailClasses(Index: Integer): WideString; safecall;
    function  Get_EventList: IgsStringList; safecall;
    function  Get_gdcTableInfos: WideString; safecall;
    function  Get_BaseState: WideString; safecall;
    function  Get_QueryFilter: IgsQueryFilterGDC; safecall;

    function  Get_QSelect: IgsIBSQL; safecall;
    function  Get_RefreshMaster: WordBool; safecall;
    procedure Set_RefreshMaster(Value: WordBool); safecall;
    function  Get_SetTable: WideString; safecall;
    procedure Set_SetTable(const Value: WideString); safecall;
    function  Get_SubSetCount: Integer; safecall;
    function  Get_SubSets(Index: Integer): WideString; safecall;
    procedure Set_SubSets(Index: Integer; const Value: WideString); safecall;
    function  Get_CanChangeRights: WordBool; safecall;
    function  Get_CanCreate: WordBool; safecall;
    function  Get_CanDelete: WordBool; safecall;
    function  Get_CanEdit: WordBool; safecall;
    function  Get_CanView: WordBool; safecall;
    function  Get_CanPrint: WordBool; safecall;

    function  Get_Variables(const Name: WideString): OleVariant; safecall;
    procedure Set_Variables(const Name: WideString; Value: OleVariant); safecall;
    function  Get_Objects(const Name: WideString): IDispatch; safecall;
    procedure Set_Objects(const Name: WideString; const Value: IDispatch); safecall;
    procedure AddObjectItem(const Name: WideString); safecall;
    procedure AddVariableItem(const Name: WideString); safecall;

    procedure AddToSelectedID(ID: Integer); safecall;
    procedure AddToSelectedArray(const ASelectedID: IgsGDKeyArray); safecall;
    procedure AddToSelectedBookmark(const BL: IgsBookmarkList); safecall;
    procedure RemoveFromSelectedID(ID: Integer); safecall;
    procedure RemoveFromSelectedArray(const BL: IgsBookmarkList); safecall;
    procedure SaveToStream_(const Stream: IgsStream; const ObjectSet: IgsGdcObjectSet;
                            SaveDetailObjects: WordBool); safecall;
    procedure LoadFromStream_(const Stream: IgsStream; const IDMapping: IgsGdKeyIntAssoc;
                              const ObjectSet: IgsGdcObjectSet; const UpdateList: IgsObjectList); safecall;
    procedure AddSubSet(const ASubSet: WideString); safecall;
    procedure AfterConstruction; reintroduce; safecall; { TODO : тут не очень хорошо reintroduce }
    function  CanPasteFromClipboard: WordBool; safecall;
    procedure CheckCurrentRecord; safecall;
    function  CheckSubSet(const ASubSetbstr: WideString): WordBool; safecall;
    function  CheckSubType(const ASubType: WideString): WordBool; safecall;
    procedure ClearSubSets; safecall;
    procedure CopyToClipboard(const BL: IgsBookmarkList; ACut: WordBool); safecall;
    procedure DataEvent(Event: TgsDataEvent; Info: Integer); safecall;
    function  DeleteMultiple(const BL: IgsBookmarkList): WordBool; safecall;
    procedure DeleteSubSet(Index: Integer); safecall;
    procedure DoAfterShowDialog(const DlgForm: IgsCreateableForm; IsOk: WordBool); safecall;
    procedure DoBeforeShowDialog(const DlgForm: IgsCreateableForm); safecall;
    function  EditMultiple(const BL: IgsBookmarkList; const ADlgClassName: WideString): WordBool; safecall;
    function  GetClassName: WideString; safecall;
    procedure GetCurrRecordClass(out AgdcClassName: OleVariant; out ASubType: OleVariant); safecall;
    function  GetFieldValueForBookmark(const ABookmark: WideString; const AFieldName: WideString): OleVariant; safecall;
    function  GetFieldValueForID(AnID: Integer; const AFieldName: WideString): OleVariant; safecall;
    function  HasSubSet(const ASubSet: WideString): WordBool; safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure LoadSelectedFromStream(const S: IgsStream); safecall;
    function  ParentHandle: Integer; safecall;
    function  PasteFromClipboard(ATestKeyboard: WordBool): WordBool; safecall;
    procedure QueryDescendant(out AgdcBaseName: OleVariant; out ASubType: OleVariant); safecall;
    function  QueryLoadFileName(const AFileName: WideString): WideString; safecall;
    function  QuerySaveFileName(const AFileName: WideString): WideString; safecall;
    procedure RemoveSubSet(const ASubSet: WideString); safecall;
    procedure ResetAllAggs(AnActive: WordBool; const BL: IgsBookmarkList); safecall;
    procedure SaveSelectedToStream(const S: IgsStream); safecall;
    procedure SaveToStream(const Stream: IgsStream; const DetailDS: IgsGDCBase;
      const BL: IgsBookmarkList; OnlyCurrent: WordBool); safecall;
    procedure SetExclude(Reopen: WordBool); safecall;
    procedure SetInclude(AnID: Integer); safecall;
    procedure SetValueForBookmark(const ABookmark: WideString; const AFieldName: WideString;
                                  AValue: OleVariant); safecall;
    procedure UnPrepare; safecall;
    function  GetListFieldExtended(const ASubType: WideString): WideString; safecall;
    function  GetTableInfos(const ASubType: WideString): WideString; safecall;
    procedure GetClassImage(ASizeX: Integer; ASizeY: Integer; const AGraphic: IgsGraphic); safecall;
    function  QGetNameForID(AnID: Integer; const ASubType: WideString): WideString; safecall;
    function  Get_QueryFiltered: WordBool; safecall;
    procedure Set_QueryFiltered(Value: WordBool); safecall;
    function  Get_FieldsCallDoChange: IgsStringList; safecall;
    function  VariableExists(const Name: WideString): WordBool; safecall;
    function  ObjectExists(const Name: WideString): WordBool; safecall;
    function  Get_SQLSetup: IgsAtSQLSetup; safecall;
    function  FindFieldByRelation(const ARelationName: WideString; const AFieldName: WideString): IgsField; safecall;
    procedure LoadDialogDefaults; safecall;
    procedure SaveDialogDefaults; safecall;
    function  GetDlgForm: IgsForm; safecall;

    function  Get_StreamSilentProcessing: WordBool; safecall;
    procedure Set_StreamSilentProcessing(Value: WordBool); safecall;
    function  Get_StreamProcessingAnswer: Word; safecall;
    procedure Set_StreamProcessingAnswer(Value: Word); safecall;
    function  Get_CopiedObjectKey: Integer; safecall;
    procedure CopyObject(AWithDetail: WordBool; AShowDialog: WordBool); safecall;
    function  ClassInheritsFrom(const AClassName: WideString; const ASubType: WideString): WordBool; safecall;
    function  CurrRecordInheritsFrom(const AClassName: WideString; const ASubType: WideString): WordBool; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGDCLink = class(TwrpGdcBase, IgsGDCLink)
  private
    function  GetGDCLink: TgdcLink;
  public
    procedure AddLinkedObjectDialog; safecall;
    function  Get_ObjectKey: Integer; safecall;
    procedure Set_ObjectKey(Value: Integer); safecall;
    procedure PopupMenu(X: Integer; Y: Integer); safecall;
  end;

  TwrpGDCClassList = class(TwrpObject, IgsGDCClassList)
  private
    function GetIndexObjectByName(AScriptName: String): Integer;
  protected
    function DeleteObject(const AScriptName: WideString): WordBool; safecall;
    function GetObject(const AScriptName: WideString): IgsGDCBase; safecall;
    function AddObject(const AClassName: WideString; const AScriptName: WideString;
                        const ASubType: WideString; const ATransaction: IgsIBTransaction): Integer; safecall;
    function GetObjectByIndex(AnIndex: Integer): IgsGDCBase; safecall;
    function DeleteObjectByIndex(AnIndex: Integer): WordBool; safecall;
    function Get_Count: Integer; safecall;
  end;

  TwrpCreateableForm = class(TwrpForm, IgsCreateableForm{, IgsViewWindow})
  private
    function GetCreateableForm: TCreateableForm;
  protected
    function CreateAndAssign(const AnOwner: IgsComponent): IgsForm; safecall;
    function FormAssigned(const F: IgsCreateableForm): WordBool; safecall;
    procedure LoadSettingsAfterCreate; safecall;
    procedure LoadSettings; safecall;
    procedure SaveSettings; safecall;
    procedure LoadDesktopSettings; safecall;
    procedure SaveDesktopSettings; safecall;
    procedure Setup(const AnObject: IgsObject); safecall;
    procedure DoHide; safecall;
    procedure DoDestroy; safecall;
    procedure DoCreate; safecall;
    function  Get_SelectedKey: OleVariant; safecall;
    function  Get_WindowQuery: IgsQueryList; safecall;
    function  InitialName: WideString; safecall;
    procedure SetFocusOnComponent(const AComponentName: WideString); safecall;
    function  Get_Variables(const Name: WideString): OleVariant; safecall;
    procedure Set_Variables(const Name: WideString; Value: OleVariant); safecall;
    procedure AddVariableItem(const Name: WideString); safecall;

    function  Get_Objects(const Name: WideString): IDispatch; safecall;
    procedure Set_Objects(const Name: WideString; const Value: IDispatch); safecall;
    function  Get_ShowSpeedButton: WordBool; safecall;
    procedure Set_ShowSpeedButton(Value: WordBool); safecall;

    function  Get_UseDesigner: WordBool; safecall;
    procedure Set_UseDesigner(Value: WordBool); safecall;

    function  Get_Caption_: WideString; safecall;
    procedure Set_Caption_(const Value: WideString); safecall;

    procedure AddObjectItem(const Name: WideString); safecall;

    function  VariableExists(const Name: WideString): WordBool; safecall;
    function  ObjectExists(const Name: WideString): WordBool; safecall;
  public
    constructor Create(AnForm: TComponent; const TypeLib: ITypeLib; const DispIntf: TGUID);
    destructor Destroy; override;
  end;

  TwrpGDKeyArray = class(TwrpObject, IgsGDKeyArray)
  private
    function  GetGDKeyArray: TGDKeyArray;
  protected
    function  Add(InValue: Integer): Integer; safecall;
    function  IndexOf(InValue: Integer): Integer; safecall;
    function  Remove(InValue: Integer): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    function  Find(InValue: Integer; out Index: OleVariant): WordBool; safecall;
    function  Get_Keys(Index: Integer): Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Size: Integer; safecall;
    procedure Clear; safecall;

    procedure Assign_(const KA: IgsGDKeyArray); safecall;
    procedure Extract(const KA: IgsGDKeyArray); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;

    function  CommaText: WideString; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdKeyIntAssoc = class(TwrpGDKeyArray, IgsGdKeyIntAssoc)
  private
    function  GetGdKeyIntAssoc: TGdKeyIntAssoc;
  protected
    function  Get_ValuesByIndex(Index: Integer): Integer; safecall;
    procedure Set_ValuesByIndex(Index: Integer; Value: Integer); safecall;
    function  Get_ValuesByKey(Key: Integer): Integer; safecall;
    procedure Set_ValuesByKey(Key: Integer; Value: Integer); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGDCInvBaseRemains = class(TwrpGDCBase, IgsGDCInvBaseRemains)
  private
    function  GetGDCInvBaseRemains: TgdcInvBaseRemains;
  protected
    function GetOriginalSQL: WideString; safecall;
    function  Get_ViewFeatures: IgsStringList; safecall;
    procedure Set_ViewFeatures(const Value: IgsStringList); safecall;
    function  Get_RemainsDate: TDateTime; safecall;
    procedure Set_RemainsDate(Value: TDateTime); safecall;
    function  Get_CurrentRemains: WordBool; safecall;
    procedure Set_CurrentRemains(Value: WordBool); safecall;
    function  Get_RemainsSQLType: TgsInvRemainsSQLType; safecall;
    procedure Set_RemainsSQLType(Value: TgsInvRemainsSQLType); safecall;
    function  Get_IsMinusRemains: WordBool; safecall;
    procedure Set_IsMinusRemains(Value: WordBool); safecall;

  end;

  TwrpgsDBGrid = class(TwrpgsCustomDBGrid, IgsgsDBGrid)
  private
    function  GetGsDBGrid: TgsDBGrid;
  protected
    function  Get_SelectedRows: IgsBookmarkList; safecall;
    function  Get_TitleColor: Integer; safecall;
    procedure Set_TitleColor(Value: Integer); safecall;
    function  Get_Striped: WordBool; safecall;
    procedure Set_Striped(Value: WordBool); safecall;
    function  Get_RefreshType: TgsRefreshType; safecall;
    procedure Set_RefreshType(Value: TgsRefreshType); safecall;
    function  Get_TableFont: IgsFont; safecall;
    procedure Set_TableFont(const Value: IgsFont); safecall;
    function  Get_TableColor: Integer; safecall;
    procedure Set_TableColor(Value: Integer); safecall;
    function  Get_SelectedFont: IgsFont; safecall;
    procedure Set_SelectedFont(const Value: IgsFont); safecall;
    function  Get_SelectedColor: Integer; safecall;
    procedure Set_SelectedColor(Value: Integer); safecall;
    function  Get_StripeOdd: Integer; safecall;
    procedure Set_StripeOdd(Value: Integer); safecall;
    function  Get_StripeEven: Integer; safecall;
    procedure Set_StripeEven(Value: Integer); safecall;
    function  Get_InternalMenuKind: TgsInternalMenuKind; safecall;
    procedure Set_InternalMenuKind(Value: TgsInternalMenuKind); safecall;
    function  Get_Expands: IgsColumnExpands; safecall;
    procedure Set_Expands(const Value: IgsColumnExpands); safecall;
    function  Get_ExpandsActive: WordBool; safecall;
    procedure Set_ExpandsActive(Value: WordBool); safecall;
    function  Get_ExpandsSeparate: WordBool; safecall;
    procedure Set_ExpandsSeparate(Value: WordBool); safecall;
    function  Get_TitlesExpanding: WordBool; safecall;
    procedure Set_TitlesExpanding(Value: WordBool); safecall;
    function  Get_ScaleColumns: WordBool; safecall;
    procedure Set_ScaleColumns(Value: WordBool); safecall;
    function  Get_MinColWidth: Integer; safecall;
    procedure Set_MinColWidth(Value: Integer); safecall;
    function  Get_ToolBar: IgsToolBar; safecall;
    procedure Set_ToolBar(const Value: IgsToolBar); safecall;
    function  Get_FinishDrawing: WordBool; safecall;
    procedure Set_FinishDrawing(Value: WordBool); safecall;
    function  Get_RememberPosition: WordBool; safecall;
    procedure Set_RememberPosition(Value: WordBool); safecall;
    function  Get_SaveSettings: WordBool; safecall;
    procedure Set_SaveSettings(Value: WordBool); safecall;
  end;

  TwrpgsDBReduction = class(TwrpComponent, IgsgsDBReduction)
  private
    function  GetgsDBReduction: TgsDBReduction;
  protected
    function  Get_KeyField: WideString; safecall;
    procedure Set_KeyField(Const Value: WideString); safecall;
    function  GetPrimary(const TableName: WideString): WideString; safecall;
    function  Prepare: WordBool; safecall;
    function  MakeReduction: WordBool; safecall;
    procedure Reduce; safecall;
    function  Get_Table: WideString; safecall;
    procedure Set_Table(const Value: WideString); safecall;
    function  Get_MasterKey: WideString; safecall;
    procedure Set_MasterKey(const Value: WideString); safecall;
    function  Get_CondemnedKey: WideString; safecall;
    procedure Set_CondemnedKey(const Value: WideString); safecall;
    function  Get_TransferData: WordBool; safecall;
    procedure Set_TransferData(Value: WordBool); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;

    function  Get_ReductionTable: IgsReductionTable; safecall;
    procedure Set_ReductionTable(const Value: IgsReductionTable); safecall;
    function  Get_MainTable: WideString; safecall;
    procedure Set_MainTable(const Value: WideString); safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;

    function  Get_IgnoryQuestion: WordBool; safecall;
    procedure Set_IgnoryQuestion(Value: WordBool); safecall;
    
  end;

  TwrpgsDBReductionWizard = class(TwrpgsDBReduction, IgsgsDBReductionWizard)
  private
    function  GetgsDBReductionWizard: TgsDBReductionWizard;
  protected
    function  Wizard(const AClassName: WideString; const ASubType: WideString): WordBool; safecall;
    function  Get_HideFields: WideString; safecall;
    procedure Set_HideFields(const Value: WideString); safecall;
    function  Get_ListField: WideString; safecall;
    procedure Set_ListField(const Value: WideString); safecall;
    function  Get_Condition: WideString; safecall;
    procedure Set_Condition(const Value: WideString); safecall;
    function  Get_AddCondition: WideString; safecall;
    procedure Set_AddCondition(const Value: WideString); safecall;
  end;

  TwrpXDBCalculatorEdit = class(TwrpEdit, IgsxDBCalculatorEdit)
  private
    function  GetXDBCalculatorEdit: TxDBCalculatorEdit;
  protected
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Value: Double; safecall;
    procedure Set_Value(Value: Double); safecall;
    function  Get_DecDigits: Word; safecall;
    procedure Set_DecDigits(Value: Word); safecall;
  end;

  TwrpGDCTree = class(TwrpGDCBase, IgsGDCTree)
  private
    function  GetGDCTree: TgdcTree;
  protected
    procedure InsertChildren; safecall;
    function  CreateChildrenDialog: WordBool; safecall;
    function  GetParentObject: IgsGDCTree; safecall;
    function  GetCopyFieldName: WideString; safecall;
    procedure Propagate(const AFields: WideString; AnOnlyFirstLevel: WordBool); safecall;
    function  GetParentField(const ASubType: WideString): WideString; safecall;
    function  IsAbstractClass: WordBool; safecall;
    function  HasLeafs: WordBool; safecall;
    function  Get_Parent: Integer; safecall;
    procedure Set_Parent(Value: Integer); safecall;
    function  CreateChildrenDialogWithParam(const AgdcClassName: WideString): WordBool; safecall;
  end;

  TwrpGDCDocument = class(TwrpGDCTree, IgsGDCDocument)
  private
    function  GetGDCDocument: TgdcDocument;
  protected
    function  DocumentTypeKey: Integer; safecall;
    function  GetDocumentClassPart: TgsGDCDocumentClassPart; safecall;
    function  Get_DocumentName(ReadNow: WordBool): WideString; safecall;
    function  Get_DocumentDescription(ReadNow: WordBool): WideString; safecall;
    procedure CreateEntry; safecall;
    function  Get_gdcAcctEntryRegister: IgsGDCBase; safecall;
    function  Get_RelationName: WideString; safecall;
    function  Get_RelationLineName: WideString; safecall;
  end;

  TwrpGdcLBRBTree = class(TwrpGDCTree, IgsGdcLBRBTree)
  private
    function  GetGdcLBRBTree: TgdcLBRBTree;
  protected
    function  Get_LB: Integer; safecall;
    procedure Set_LB(Value: Integer); safecall;
    function  Get_RB: Integer; safecall;
    procedure Set_RB(Value: Integer); safecall;
  end;

  TwrpGdcBaseDocumentType = class(TwrpGdcLBRBTree, IgsGdcBaseDocumentType)
  private
    function  GetGdcBaseDocumentType: TgdcBaseDocumentType;
  protected
    function  UpdateReportGroup(const MainBranchName: WideString; const DocumentName: WideString;
                                var GroupKey: OleVariant; ShouldUpdateData: WordBool): WordBool; safecall;
  end;

  TwrpGdcHoliday = class(TwrpGDCBase, IgsGdcHoliday)
  private
    function GetGdcHoliday: TgdcHoliday;
  public
    function  IsHoliday(TheDate: TDateTime): WordBool; safecall;
    function  QIsHoliday(TheDate: TDateTime): WordBool; safecall;
  end;

  TwrpGdcDocumentType = class(TwrpGdcBaseDocumentType, IgsGdcDocumentType)
  private
    function  GetGdcDocumentType: TgdcDocumentType;
  protected
    function  Get_GetHeaderDocumentClass: WideString; safecall;
  end;

  TwrpGdcUserDocumentType = class(TwrpGdcDocumentType, IgsGdcUserDocumentType)
  private
    function  GetGdcUserDocumentType: TgdcUserDocumentType;
  protected
    function  Get_BranchKey: Integer; safecall;
    procedure Set_BranchKey(Value: Integer); safecall;
    function  Get_DocRelationName: WideString; safecall;
    function  Get_DocLineRelationName: WideString; safecall;
    function  Get_IsComplexDocument: WordBool; safecall;
    function  Get_MainBranchKey: Integer; safecall;
    procedure ReadOptions; safecall;
  end;

  TwrpGdcUserBaseDocument = class(TwrpGDCDocument, IgsGdcUserBaseDocument)
  private
    function  GetGdcUserBaseDocument: TgdcUserBaseDocument;
  protected
    function  EnumRelationFields(const RelationName: WideString; const AliasName: WideString;
                                 UseDot: WordBool): WideString; safecall;
    function  GetGroupID: Integer; safecall;
    procedure ReadOptions(aDocumentTypeKey: Integer); safecall;
    function  Get_Relation: WideString; safecall;
    function  Get_RelationLine: WideString; safecall;
  end;

  TwrpGdcDocumentBranch = class(TwrpGdcBaseDocumentType, IgsGdcDocumentBranch)
  end;

  TwrpGdcUserDocument = class(TwrpGdcUserBaseDocument, IgsGdcUserDocument)
  private
    {function GetGdcUserDocument: TGdcUserDocument;}
  protected
    procedure PrePostDocumentData; safecall;
  end;

  TwrpGdcUserDocumentLine = class(TwrpGdcUserBaseDocument, IgsGdcUserDocumentLine)
  end;
  

  TwrpGdcReportGroup = class(TwrpGdcLBRBTree, IgsGdcReportGroup)
  end;

  TwrpGdcReport = class(TwrpGdcBase, IgsGdcReport)
  private
    function  GetGdcReport: TgdcReport;
  protected
    function  CheckReport(const AName: WideString; ReportGroupKey: Integer): WordBool; safecall;
    function  GetUniqueName(const PrefName: WideString; const Name: WideString;
      ReportGroupKey: Integer): WideString; safecall;
    function  Get_LastInsertID: Integer; safecall;
  end;

  TwrpGdcTemplate = class(TwrpGDCBase, IgsGdcTemplate)
  end;

  TwrpGdcDelphiObject = class(TwrpGdcLBRBTree, IgsGdcDelphiObject)
  private
    function  GetGdcDelphiObject: TgdcDelphiObject;
  protected
    function  AddObject(const AComponent: IgsComponent): Integer; safecall;
    function  NeedModifyFromStream(const SubType: WideString): WordBool; safecall;
  end;

  TwrpGdcMacrosGroup = class(TwrpGdcLBRBTree, IgsGdcMacrosGroup)
  end;

  TwrpGdcMacros = class(TwrpGDCBase, IgsGdcMacros)
  private
    function  GetGdcMacros: TgdcMacros;
  protected
    function  CheckMacros(const AName: WideString; MacrosGroupKey: Integer): WordBool; safecall;
    function  GetUniqueName(const PrefName: WideString; const Name: WideString;
      MacrosGroupKey: Integer): WideString; safecall;
    function  Get_LastInsertID: Integer; safecall;
  end;

  TwrpGdcConst = class(TwrpGDCBase, IgsGdcConst)
  private
    function  GetGdcConst: TgdcConst;

  protected
    function  isUser: WordBool; safecall;
    function  isPeriod: WordBool; safecall;
    function  isCompany: WordBool; safecall;

    function  QGetValueByName(const AName: WideString): OleVariant; safecall;
    function  QGetValueByID(AnID: Integer): OleVariant; safecall;
    function  QGetValueByID2(AnID: Integer; ADate: TDateTime; AUserKey: Integer;
                             ACompanyKey: Integer): OleVariant; safecall;
    function  QGetValueByIDAndDate(AnID: Integer; ADate: TDateTime): OleVariant; safecall;
    function  QGetValueByName2(const AName: WideString; ADate: TDateTime; AUserKey: Integer;
                               ACompanyKey: Integer): OleVariant; safecall;
    function  QGetValueByNameAndDate(const AName: WideString; ADate: TDateTime): OleVariant; safecall;
  end;
{
  TwrpGdcConstValue = class(TwrpGDCBase, IgsGdcConstValue)
  private
    function  GetGdcConstValue: TgdcConstValue;
  protected
    function  Get_ConstKey: Integer; safecall;
    procedure Set_ConstKey(Value: Integer); safecall;
    function  Get_ConstType: Integer; safecall;
    procedure Set_ConstType(Value: Integer); safecall;
  end;
 }

 {
  TwrpGdcLink = class(TwrpGDCBase, IgsGdcLink)
  private
    function  GetGdcLink: TgdcLink;
  protected
    function  Get_ObjectKey: Integer; safecall;
    procedure Set_ObjectKey(Value: Integer); safecall;
    function  CreateViewFormForObject(const AnOwner: IgsComponent; const AnObject: IgsGDCBase): IgsForm; safecall;
  end;
}

  TwrpGdcExplorer = class(TwrpGDCBase, IgsGdcExplorer)
  private
    function  GetGdcExplorer: TgdcExplorer;
  protected
    function  CreateGdcInstance: IgsGDCBase; safecall;
    procedure ShowProgram; safecall;
    procedure ShowProgramWithParam(AlwaysCreateWindow: WordBool); safecall;
    function  Get_gdcClass: WideString; safecall;
  end;

  TwrpGdcAcctCompanyChart = class(TwrpGDCBase, IgsGdcAcctCompanyChart)
  end;

  TwrpGdcBaseContact = class(TwrpGdcLBRBTree, IgsGdcBaseContact)
  private
    function  GetGdcBaseContact: TgdcBaseContact;
  protected
    function  GetBankAttribute: WideString; safecall;
    function  ContactType: Integer; safecall;
  end;

  TwrpGdcCompany = class(TwrpGdcBaseContact, IgsGdcCompany)
  end;

  TwrpGdcOurCompany = class(TwrpGdcCompany, IgsGdcOurCompany)
  protected
    procedure SaveOurCompany(CompanyKey: Integer); safecall;
  end;

  TwrpGdcBaseAcctTransactionEntry = class(TwrpGDCBase, IgsGdcBaseAcctTransactionEntry)
  end;

{  TwrpGdcAcctEntryDocument = class(TwrpGdcBaseAcctTransactionEntry, IgsGdcAcctEntryDocument)
  private
    function  GetGdcAcctEntryDocument: TgdcAcctEntryDocument;
  protected
    function  Get_DocumentTypeKey: Integer; safecall;
    procedure Set_DocumentTypeKey(Value: Integer); safecall;
  end;}

  TwrpGdcMetaBase = class(TwrpGDCBase, IgsGdcMetaBase)
  private
    function  GetGdcMetaBase: TgdcMetaBase;
  protected
    function  Get_IsUserDefined: WordBool; safecall;
  end;

  TwrpGdcField = class(TwrpGdcMetaBase, IgsGdcField)
  private
    function  GetGdcField: TgdcField;
  protected
    function  GetDomainText(isCharSet: WordBool; OnlyDataType: WordBool): WideString; safecall;
  end;

  TwrpGdcRelation = class(TwrpGdcMetaBase, IgsGdcRelation)
  private
    function  GetGdcRelation: TgdcRelation;
  protected
    function  Get_TableType: TgsGdcTableType; safecall;
  end;

  TwrpGdcRelationField = class(TwrpGdcMetaBase, IgsGdcRelationField)
  private
    function  GetGdcRelationField: TGdcRelationField;
  protected
    function  Get_ChangeComputed: WordBool; safecall;
    procedure Set_ChangeComputed(Value: WordBool); safecall;
    function  ReadObjectState(const AFieldId: WideString; const AClassName: WideString): Integer; safecall;
  end;

  TwrpGdcTableField = class(TwrpGdcRelationField, IgsGdcTableField)
  end;

  TwrpGdcBaseTable = class(TwrpGdcRelation, IgsGdcBaseTable)
  private
    function  GetGdcBaseTable: TGdcBaseTable;
  protected
    procedure MakePredefinedRelationFields; safecall;
    function  GetPrimaryFieldName: WideString; safecall;
    function  Get_gdcTableField: IgsGdcTableField; safecall;
    function  Get_AdditionCreateField: IgsStringList; safecall;
    procedure Set_AdditionCreateField(const Value: IgsStringList); safecall;
  end;

  TwrpGdcTable = class(TwrpGdcBaseTable, IgsGdcTable)
  end;

  TwrpGdcCustomTable = class(TwrpGDCBaseTable, IgsGdcCustomTable)
  end;

  TwrpGdcBaseDocumentTable = class(TwrpGdcCustomTable, IgsGdcBaseDocumentTable)
  end;

  TwrpGdcUser = class(TwrpGDCBase, IgsGdcUser)
  private
    function  GetGdcUser: TgdcUser;
  protected
    function  CheckUser(const AUserName: WideString): WordBool; safecall;
    function  CheckIBUser: WordBool; safecall;
    procedure CheckIBUserCreate; safecall;
    procedure CreateIBUser; safecall;
    procedure DeleteIBUser; safecall;
    procedure ReCreateAllUsers; safecall;
    function  CheckIBUserWithParam(const AUser: WideString; const APassw: WideString): WordBool; safecall;
    function  Get_Groups: Integer; safecall;
    procedure Set_Groups(Value: Integer); safecall;
    procedure CopySettings(const ibtr: IgsIBTransaction); safecall;
    procedure CopySettingsByUser(U: Integer; const ibtr: IgsIBTransaction); safecall;
  end;

  TwrpGdcUserGroup = class(TwrpGDCBase, IgsGdcUserGroup)
  private
    function  GetGdcUserGroup: TgdcUserGroup;
  protected
    procedure AddUserByID(AnID: Integer); safecall;
    procedure AddUser(const AnUser: IgsGdcUser); safecall;
    procedure RemoveUserByID(AnID: Integer); safecall;
    procedure RemoveUser(const AnUser: IgsGdcUser); safecall;
    function  GetGroupMask: Integer; safecall;
    function  Get_Mask: Integer; safecall;
    procedure Set_Mask(Value: Integer); safecall;
    function  GetGroupMaskByID(AGroupID: Integer): Integer; safecall;
  end;

{  TwrpGdcBaseOperation = class(TwrpGDCTree, IgsGdcBaseOperation)
  private
    function  GetGdcBaseOperation: TgdcBaseOperation;
  protected
    procedure BuildClassTree; safecall;
  end;}

  TwrpGdcGood = class(TwrpGDCBase, IgsGdcGood)
  private
    function  GetGdcGood: TgdcGood;
  protected
    function  Get_GroupKey: Integer; safecall;
    procedure Set_GroupKey(Value: Integer); safecall;
    function  GetTaxRateOnName(const TaxName: WideString; ForDate: TDateTime): OleVariant; safecall;
    function  GetTaxRate(TaxKey: Integer; ForDate: TDateTime): Currency; safecall;
    function  GetTaxRateByID(aID: Integer; TaxKey: Integer; ForDate: TDateTime): Currency; safecall;
    function  GetTaxRateOnNameByID(aID: Integer; const TaxName: WideString; ForDate: TDateTime): Currency; safecall;
  end;

  TwrpGdcInvBaseDocument = class(TwrpGDCDocument, IgsGdcInvBaseDocument)
  private
    function  GetGdcInvBaseDocument: TgdcInvBaseDocument;
  protected
    function  JoinListFieldByFieldName(const AFieldName: WideString; const AAliasName: WideString;
                                       const AJoinFieldName: WideString): WideString; safecall;
    function  Get_CurrentStreamVersion: WideString; safecall;
    function  Get_Relation: IgsAtRelation; safecall;
    function  Get_RelationLine: IgsAtRelation; safecall;
    function  Get_RelationType: TgsGdcInvRelationType; safecall;
    function  Get_BranchKey: Integer; safecall;
    procedure ReadOptions(const Stream: IgsStream); safecall;
  end;

  TwrpGdcInvDocument = class(TwrpGdcInvBaseDocument, IgsGdcInvDocument)
  private
    function  GetGdcInvDocument: TgdcInvDocument;
  protected
    procedure PrePostDocumentData; safecall;
    function  Get_MovementSource: IgsGdcInvMovementContactOption; safecall;
    function  Get_MovementTarget: IgsGdcInvMovementContactOption; safecall;
  end;

  TwrpGdcInvDocumentLine = class(TwrpGdcInvBaseDocument, IgsGdcInvDocumentLine)
  private
    function  GetGdcInvDocumentLine: TgdcInvDocumentLine;
  protected
    function  ChooseRemains: WordBool; safecall;
    function  SelectGoodFeatures: WordBool; safecall;
    procedure UpdateGoodNames; safecall;
    function  Get_ControlRemains: WordBool; safecall;
    procedure Set_ControlRemains(Value: WordBool); safecall;
    function  Get_Movement: IgsGdcInvMovement; safecall;
    function  Get_UseCachedUpdates: WordBool; safecall;
    function  Get_CanBeDelayed: WordBool; safecall;
    function  Get_LiveTimeRemains: WordBool; safecall;
    procedure  Set_LiveTimeRemains(Value: WordBool); safecall;
    function  Get_Direction: TgsGdcInvMovementDirection; safecall;
    function  Get_ViewMovementPart: TgsGdcInvMovementPart; safecall;
    procedure Set_ViewMovementPart(Value: TgsGdcInvMovementPart); safecall;
    procedure SetFeatures(IsFrom: WordBool; IsTo: WordBool); safecall;
    function  Get_isSetFeaturesFromRemains: WordBool; safecall;
    procedure Set_isSetFeaturesFromRemains(Value: WordBool); safecall;
    function  Get_isChooseRemains: WordBool; safecall;
    procedure Set_isChooseRemains(Value: WordBool); safecall;
    function  Get_Sources: WideString; safecall;
    function  Get_SourceFeatures: OleVariant; safecall;
    function  Get_DestFeatures: OleVariant; safecall;
    function  Get_MinusFeatures: OleVariant; safecall;
    function  Get_IsCheckDestFeatures: WordBool; safecall;
    procedure Set_IsCheckDestFeatures(Value: WordBool); safecall;
    function  Get_UseGoodKeyForMakeMovement: WordBool; safecall;
    procedure Set_UseGoodKeyForMakeMovement(Value: WordBool); safecall;
    function  Get_IsMakeMovementOnFromCardKeyOnly: WordBool; safecall;
    procedure Set_IsMakeMovementOnFromCardKeyOnly(Value: WordBool); safecall;


  end;

  TwrpGdcInvDocumentType = class(TwrpGdcDocumentType, IgsGdcInvDocumentType)
  private
    function  GetGdcInvDocumentType: TgdcInvDocumentType;
  protected
    function  InvDocumentTypeBranchKey: Integer; safecall;
  end;

  TwrpGdcInvMovement = class(TwrpGDCBase, IgsGdcInvMovement)
  private
    function  GetGdcInvMovement: TgdcInvMovement;
  protected
    function  SelectGoodFeatures: WordBool; safecall;
    function  CreateMovement(gdcInvPositionSaveMode: TgsGdcInvPositionSaveMode): WordBool; safecall;
    function  CreateAllMovement(gdcInvPositionSaveMode: TgsGdcInvPositionSaveMode;
                                IsOnlyDisabled: WordBool): WordBool; safecall;
    function GetRemains: Currency; safecall;
    function  ChooseRemains(isMakePosition: WordBool): WordBool; safecall;
    function  Get_InvErrorCode: TgsGdcInvErrorCode; safecall;
    function  Get_gdcDocumentLine: IgsGDCDocument; safecall;
    procedure Set_gdcDocumentLine(const Value: IgsGDCDocument); safecall;
    function  Get_CurrentRemains: WordBool; safecall;
    procedure Set_CurrentRemains(Value: WordBool); safecall;
    function  Get_CountPositionChanged: Integer; safecall;
    function  Get_IsGetRemains: WordBool; safecall;
    procedure Set_IsGetRemains(Value: WordBool); safecall;
    function  Get_ShowMovementDlg: WordBool; safecall;
    procedure Set_ShowMovementDlg(Value: WordBool); safecall;
    function  Get_NoWait: WordBool; safecall;
    procedure Set_NoWait(Value: WordBool); safecall;

  end;

  TwrpGdcInvRemains = class(TwrpGDCInvBaseRemains, IgsGdcInvRemains)
  private
    function  GetGdcInvRemains: TgdcInvRemains;
  protected
    procedure ClearPositionList; safecall;
    function  Get_CountPosition: Integer; safecall;
    function  Get_GoodKey: Integer; safecall;
    procedure Set_GoodKey(Value: Integer); safecall;
    function  Get_GroupKey: Integer; safecall;
    procedure Set_GroupKey(Value: Integer); safecall;
    function  Get_IncludeSubDepartment: WordBool; safecall;
    procedure Set_IncludeSubDepartment(Value: WordBool); safecall;
    function  Get_ContactType: Integer; safecall;
    procedure Set_ContactType(Value: Integer); safecall;
    function  Get_CheckRemains: WordBool; safecall;
    procedure Set_CheckRemains(Value: WordBool); safecall;
    function  Get_gdcDocumentLine: IgsGDCDocument; safecall;
    procedure Set_gdcDocumentLine(const Value: IgsGDCDocument); safecall;
    procedure RemovePosition; safecall;
  end;

  TwrpGdcBaseBank = class(TwrpGDCDocument, IgsGdcBaseBank)
  private
    function  GetGdcBaseBank: TgdcBaseBank;
  protected
    function  GetBankInfo(const AccountKey: WideString): WideString; safecall;
    function  Get_gsTransaction: IgsTransaction; safecall;
    procedure Set_gsTransaction(const Value: IgsTransaction); safecall;
  end;

  {TwrpGdcBasePayment = class(TwrpGdcBaseBank, IgsGdcBasePayment)
  private
    function  GetGdcBasePayment: TgdcBasePayment;
  protected
    procedure UpdateCorrAccount; safecall;
    procedure UpdateAdditional; safecall;
    procedure UpdateCorrCompany; safecall;
  end;

  TwrpGdcCheckList = class(TwrpGdcBaseBank, IgsGdcCheckList)
  private
    function  GetGdcCheckList: TgdcCheckList;
  protected
    function  Get_DetailObject: IgsGDCBase; safecall;
    procedure Set_DetailObject(const Value: IgsGDCBase); safecall;
  end;}

  TwrpGdcAttrUserDefined = class(TwrpGDCBase, IgsGdcAttrUserDefined)
  private
    function  GetGdcAttrUserDefined: TgdcAttrUserDefined;
  protected
    function  Get_RelationName: WideString; safecall;
    function  Get_IsView: WordBool; safecall;
  end;

  TwrpGdcBugBase = class(TwrpGDCBase, IgsGdcBugBase)
  private
    function  GetGdcBugBase: TgdcBugBase;
  protected
    procedure GetBugAreas(const S: IgsStrings); safecall;
    procedure GetSubSystems(const S: IgsStrings); safecall;
  end;

  TwrpGdcCurrRate = class(TwrpGDCBase, IgsGdcCurrRate)
  end;

  TwrpGdcInvBasePriceList = class(TwrpGDCDocument, IgsGdcInvBasePriceList)
  protected
    function  GetCurrencyKey(RelationFieldKey: Integer): Integer; safecall;
  end;

  TwrpGdcInvPriceListType = class(TwrpGdcDocumentType, IgsGdcInvPriceListType)
  end;

  TwrpGdcInvPriceListLine = class(TwrpGdcInvBasePriceList, IgsGdcInvPriceListLine)
  private
    function  GetGdcInvPriceListLine: TgdcInvPriceListLine;
  protected
    procedure UpdateGoodNames; safecall;
  end;

  {TwrpGdcCurrCommission = class(TwrpGdcBaseBank, IgsGdcCurrCommission)
  private
    function  GetGdcCurrCommission: TgdcCurrCommission;
  protected
    function  GetCurrencyByAccount(AccountKey: Integer): WideString; safecall;
    procedure UpdateAdditional; safecall;
    procedure UpdateCorrAccount; safecall;
    procedure UpdateCorrCompany; safecall;
  end;}

  TwrpGdcJournal = class(TwrpGDCBase, IgsGdcJournal)
  private
    function  GetGdcJournal: TgdcJournal;
  protected
    procedure CreateTriggers; safecall;
    procedure DropTriggers; safecall;
  end;

  TwrpFieldAlias = class(TwrpCollectionItem, IgsFieldAlias)
  private
    function  GetFieldAlias: TFieldAlias;
  protected
    function  Get_Grid: IgsGsCustomIBGrid; safecall;
    function  Get_Alias: WideString; safecall;
    procedure Set_Alias(const Value: WideString); safecall;
    function  Get_LName: WideString; safecall;
    procedure Set_LName(const Value: WideString); safecall;
  end;

  TwrpFieldAliases = class(TwrpCollection, IgsFieldAliases)
  private
    function  GetFieldAliases: TFieldAliases;
  protected
    function  Add: IgsFieldAlias; safecall;
    function  FindAlias(const AliasName: WideString; out Alias: OleVariant): WordBool; safecall;
    function  Get_Grid: IgsGsCustomIBGrid; safecall;
    function  Get_Items(Index: Integer): IgsFieldAlias; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsFieldAlias); safecall;
  end;

  TwrpTBToolWindow = class(TwrpTBCustomDockableWindow, IgsTBToolWindow)
  private
    function  GetTBToolWindow: TTBToolWindow;
  protected
    function  Get_ClientAreaHeight: Integer; safecall;
    procedure Set_ClientAreaHeight(Value: Integer); safecall;
    function  Get_ClientAreaWidth: Integer; safecall;
    procedure Set_ClientAreaWidth(Value: Integer); safecall;
    function  Get_MaxClientHeight: Integer; safecall;
    procedure Set_MaxClientHeight(Value: Integer); safecall;
    function  Get_MaxClientWidth: Integer; safecall;
    procedure Set_MaxClientWidth(Value: Integer); safecall;
    function  Get_MinClientHeight: Integer; safecall;
    procedure Set_MinClientHeight(Value: Integer); safecall;
    function  Get_MinClientWidth: Integer; safecall;
    procedure Set_MinClientWidth(Value: Integer); safecall;
  end;

  TwrpXCalculatorEdit = class(TwrpEdit, IgsXCalculatorEdit)
  private
    function  GetXCalculatorEdit: TXCalculatorEdit;
  protected
    function  Get_Value: Double; safecall;
    procedure Set_Value(Value: Double); safecall;
    function  Get_DecDigits: Word; safecall;
    procedure Set_DecDigits(Value: Word); safecall;
  end;

  TwrpTBBackground = class(TwrpComponent, IgsTBBackground)
  private
    function  GetTBBackground: TTBBackground;
  protected
    function  Get_BkColor: Integer; safecall;
    procedure Set_BkColor(Value: Integer); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    function  Get_Bitmap: IgsBitmap; safecall;
    procedure Set_Bitmap(const Value: IgsBitmap); safecall;
  end;

  TwrpxFoCal = class(TwrpComponent, IgsxFoCal)
  private
    function GetxFoCal: TxFoCal;
  protected
    function  Get_Value: Double; safecall;
    procedure Set_Value(Value: Double); safecall;
    function  Get_Expression: WideString; safecall;
    procedure Set_Expression(const Value: WideString); safecall;
    function  Get_Variables: IgsStringList; safecall;
    procedure Set_Variables(const Value: IgsStringList); safecall;
    function  Get_StrictVars: WordBool; safecall;
    procedure Set_StrictVars(Value: WordBool); safecall;
    function  Get_RequiredVariables: IgsStringList; safecall;

    procedure AssignVariables(const AVariables: IgsStringList); safecall;
    procedure AssignVariable(const AName: WideString; AValue: Double); safecall;
    procedure DeleteVariable(const AName: WideString); safecall;
    procedure ClearVariablesList; safecall;

  end;

  TwrpTBCustomItem = class(TwrpComponent, IgsTBCustomItem)
  private
    function  GetTBCustomItem: TTBCustomItem;
  protected
    function  HasParent: WordBool; safecall;
    function  GetParentComponent: IgsComponent; safecall;
    procedure Add(const AItem: IgsTBCustomItem); safecall;
    procedure Clear; safecall;
    procedure Click; safecall;
    function  ContainsItem(const AItem: IgsTBCustomItem): WordBool; safecall;
    procedure Delete(Index: Integer); safecall;
    function  GetHintText: WideString; safecall;
    function  GetShortCutText: WideString; safecall;
    function  IndexOf(const AItem: IgsTBCustomItem): Integer; safecall;
    procedure InitiateAction; safecall;
    procedure Insert(NewIndex: Integer; const AItem: IgsTBCustomItem); safecall;
    procedure Move(CurIndex: Integer; NewIndex: Integer); safecall;
    procedure Popup(X: Integer; Y: Integer; TrackRightButton: WordBool;
                    Alignment: TgsTBPopupAlignment); safecall;
    procedure Remove(const Item: IgsTBCustomItem); safecall;
    procedure ViewBeginUpdate; safecall;
    procedure ViewEndUpdate; safecall;
    function  Get_Action: IgsBasicAction; safecall;
    procedure Set_Action(const Value: IgsBasicAction); safecall;
    function  Get_AutoCheck: WordBool; safecall;
    procedure Set_AutoCheck(Value: WordBool); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function  Get_DisplayMode: TgsTBItemDisplayMode; safecall;
    procedure Set_DisplayMode(Value: TgsTBItemDisplayMode); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_GroupIndex: Integer; safecall;
    procedure Set_GroupIndex(Value: Integer); safecall;
    function  Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_InheritOptions: WordBool; safecall;
    procedure Set_InheritOptions(Value: WordBool); safecall;
    function  Get_Items(Index: Integer): IgsTBCustomItem; safecall;
    function  Get_LinkSubitems: IgsTBCustomItem; safecall;
    procedure Set_LinkSubitems(const Value: IgsTBCustomItem); safecall;
    function  Get_Parent: IgsTBCustomItem; safecall;
    function  Get_ParentComponent: IgsComponent; safecall;
    procedure Set_ParentComponent(const Value: IgsComponent); safecall;
    function  Get_ShortCut: Word; safecall;
    procedure Set_ShortCut(Value: Word); safecall;
    function  Get_SubMenuImages: IgsCustomImageList; safecall;
    procedure Set_SubMenuImages(const Value: IgsCustomImageList); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
  end;

  TwrpTBControlItem = class(TwrpTBCustomItem, IgsTBControlItem)
  private
    function GetTBControlItem: TTBControlItem;
  protected
    function  Get_DontFreeControl: WordBool; safecall;
    procedure Set_DontFreeControl(Value: WordBool); safecall;
    function  Get_Control: IgsControl; safecall;
    procedure Set_Control(const Value: IgsControl); safecall;
  end;


  TwrpTBRootItem = class(TwrpTBCustomItem, IgsTBRootItem)
  end;

  TwrpTBItemContainer = class(TwrpComponent, IgsTBItemContainer)
  private
    function  GetTBItemContainer: TTBItemContainer;
  protected
    function  Get_Items: IgsTBCustomItem; safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
  end;

  TwrpIBCustomService = class(TwrpComponent, IgsIBCustomService)
  private
    function  GetIBCustomService: TIBCustomService;
  protected
    procedure Loaded; safecall;
    function  Login: WordBool; safecall;
    procedure CheckActive; safecall;
    procedure CheckInactive; safecall;
    function  Get_OutputBuffer: WideString; safecall;
    function  Get_OutputBufferOption: TgsOutputBufferOption; safecall;
    procedure Set_OutputBufferOption(Value: TgsOutputBufferOption); safecall;
    function  Get_BufferSize: Integer; safecall;
    procedure Set_BufferSize(Value: Integer); safecall;
    procedure InternalServiceQuery; safecall;
    function  Get_ServiceQueryParams: WideString; safecall;
    procedure Set_ServiceQueryParams(const Value: WideString); safecall;
    procedure Attach; safecall;
    procedure Detach; safecall;
    function  Get_ServiceParamBySPB(Idx: Integer): WideString; safecall;
    procedure Set_ServiceParamBySPB(Idx: Integer; const Value: WideString); safecall;
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  Get_ServerName: WideString; safecall;
    procedure Set_ServerName(const Value: WideString); safecall;
    function  Get_Protocol: TgsProtocol; safecall;
    procedure Set_Protocol(Value: TgsProtocol); safecall;
    function  Get_Params: IgsStrings; safecall;
    procedure Set_Params(const Value: IgsStrings); safecall;
    function  Get_LoginPrompt: WordBool; safecall;
    procedure Set_LoginPrompt(Value: WordBool); safecall;
  end;

  TwrpIBControlService = class(TwrpIBCustomService, IgsIBControlService)
  private
    function  GetIBControlService: TIBControlService;
  protected
    function  Get_ServiceStartParams: WideString; safecall;
    procedure Set_ServiceStartParams(const Value: WideString); safecall;
    procedure SetServiceStartOptions; safecall;
    procedure ServiceStartAddParam(const Value: WideString; Param: Integer); safecall;
    procedure ServiceStartAddParamByInt(Value: Integer; Param: Integer); safecall;
    procedure InternalServiceStart; safecall;
    procedure ServiceStart; safecall;
    function  Get_IsServiceRunning: WordBool; safecall;
  end;

  TwrpIBControlAndQueryService = class(TwrpIBControlService, IgsIBControlAndQueryService)
  private
    function  GetIBControlAndQueryService: TIBControlAndQueryService;
  protected
    function  Get_Action: Integer; safecall;
    procedure Set_Action(Value: Integer); safecall;
    function  GetNextLine: WideString; safecall;
    function  GetNextChunk: WideString; safecall;
    function  Get_Eof: WordBool; safecall;
  end;

  TwrpIBBackupRestoreService = class(TwrpIBControlAndQueryService, IgsIBBackupRestoreService)
  private
    function  GetIBBackupRestoreService: TIBBackupRestoreService;
  protected
    function  Get_Verbose: WordBool; safecall;
    procedure Set_Verbose(Value: WordBool); safecall;
  end;

  TwrpIBRestoreService = class(TwrpIBBackupRestoreService, IgsIBRestoreService)
  private
    function  GetIBRestoreService: TIBRestoreService;
  protected
    function  Get_DatabaseName: IgsStrings; safecall;
    procedure Set_DatabaseName(const Value: IgsStrings); safecall;
    function  Get_BackupFile: IgsStrings; safecall;
    procedure Set_BackupFile(const Value: IgsStrings); safecall;
    function  Get_PageSize: Integer; safecall;
    procedure Set_PageSize(Value: Integer); safecall;
    function  Get_PageBuffers: Integer; safecall;
    procedure Set_PageBuffers(Value: Integer); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
  end;

  TwrpIBBackupService = class(TwrpIBBackupRestoreService, IgsIBBackupService)
  private
    function  GetIBBackupService: TIBBackupService;
  protected
    function  Get_BackupFile: IgsStrings; safecall;
    procedure Set_BackupFile(const Value: IgsStrings); safecall;
    function  Get_BlockingFactor: Integer; safecall;
    procedure Set_BlockingFactor(Value: Integer); safecall;
    function  Get_DatabaseName: WideString; safecall;
    procedure Set_DatabaseName(const Value: WideString); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
  end;

  TwrpGDCCreateableForm = class(TwrpCreateableForm, IgsGDCCreateableForm)
  private
    function  GetGDCCreateableForm: TgdcCreateableForm;
  protected
    function  Get_gdcObject: IgsGDCBase; safecall;
    procedure Set_gdcObject(const Value: IgsGDCBase); safecall;
    procedure SaveGrid(const AGrid: IgsGsCustomDBGrid); safecall;
    procedure LoadGrid(const AGrid: IgsGsCustomDBGrid); safecall;
    function  GetSubTypeList(const SubTypeList: IgsStrings): WordBool; safecall;
    function  Get_SubType: WideString; safecall;
  end;

  TwrpGdc_frmG = class(TwrpGDCCreateableForm, IgsGdc_frmG)
  private
    function  GetGdc_frmG: Tgdc_frmG;
  protected
    procedure SetShortCut(Master: WordBool); safecall;
    function  GetMainBookmarkList: IgsBookmarkList; safecall;
    function  Get_gdcChooseObject: IgsGDCBase; safecall;
    procedure SetChoose(const AnObject: IgsGDCBase); safecall;
    procedure SetupSearchPanel(const Obj: IgsGDCBase; const PN: IgsPanel; const SB: IgsScrollBox; var FO: OleVariant;
                               var PreservedConditions: OleVariant); safecall;
    procedure SearchExecute(const Obj: IgsGDCBase; const SB: IgsPanel; var FO: OleVariant;
                            var PreservedConditions: OleVariant); safecall;
    procedure SetLocalizeListName(const AGrid: IgsGsIBGrid); safecall;
    function  Get_gdcLinkChoose: IgsGDCBase; safecall;
    procedure Set_gdcLinkChoose(const Value: IgsGDCBase); safecall;
    function  Get_InChoose: WordBool; safecall;
    function  Get_ChosenIDInOrder: OleVariant; safecall;
  end;

  TwrpGdc_frmSGR = class(TwrpGdc_frmG, IgsGdc_frmSGR)
  end;

  TwrpGdc_frmInvCard = class(TwrpGdc_frmSGR, IgsGdc_frmInvCard)
  private
    function  GetGdc_frmInvCard: Tgdc_frmInvCard;
  protected
    function  Get_DateBegin: TDateTime; safecall;
    procedure Set_DateBegin(Value: TDateTime); safecall;
    function  Get_DateEnd: TDateTime; safecall;
    procedure Set_DateEnd(Value: TDateTime); safecall;
  end;

  TwrpGdv_frmG = class(TwrpGDCCreateableForm, IgsGdv_frmG)
  private
    function  GetGdv_frmG: Tgdv_frmG;
  protected
    function  Get_DateBegin: TDateTime; safecall;
    procedure Set_DateBegin(Value: TDateTime); safecall;
    function  Get_DateEnd: TDateTime; safecall;
    procedure Set_DateEnd(Value: TDateTime); safecall;
  end;

  TwrpGdv_frmAcctBaseForm = class(TwrpGdv_frmG, IgsGdv_frmAcctBaseForm)
  private
    function  GetGdv_frmAcctBaseForm: Tgdv_frmAcctBaseForm;
  protected
    function  Get_gdvObject: IgsGdvAcctBase; safecall;
  end;

  TwrpGdc_frmMDH = class(TwrpGdc_frmG, IgsGdc_frmMDH)
  private
    function GetGdc_frmMDH: Tgdc_frmMDH;
  protected
    function  Get_gdcDetailObject: IgsGDCBase; safecall;
    procedure Set_gdcDetailObject(const Value: IgsGDCBase); safecall;
    function  GetDetailBookmarkList: IgsBookmarkList; safecall;
  end;

  TwrpGdc_frmMD2H = class(TwrpGdc_frmMDH, IgsGdc_frmMD2H)
  private
    function GetGdc_frmMD2H: Tgdc_frmMD2H;
  protected
    function  Get_gdcSubDetailObject: IgsGDCBase; safecall;
    procedure Set_gdcSubDetailObject(const Value: IgsGDCBase); safecall;
  end;

  TwrpGdc_dlgSelectDocument = class(TwrpGDCCreateableForm, IgsdlgSelectDocument)
  private
    function Get_dlgSelectDocument: TdlgSelectDocument;
  protected
    function Get_SelectedID: integer; safecall;
  end;

  TwrpGDC_dlgG = class(TwrpGDCCreateableForm, IgsGDC_dlgG)
  private
    function  GetGDC_dlgG: Tgdc_dlgG;
  protected
    procedure SetupDialog; safecall;
    procedure SetupRecord; safecall;
    procedure SyncControls; safecall;
    function  Get_MultipleCreated: WordBool; safecall;
    function  Get_ErrorAction: WordBool; safecall;
    procedure Set_ErrorAction(Value: WordBool); safecall;
    procedure ActivateTransaction(const ATransactionATransaction: IgsIBTransaction); safecall;
    function TestCorrect: WordBool; safecall;
    function  Get_FieldsCallOnSync: IgsFieldsCallList; safecall;
    function  DlgModified: WordBool; safecall;
    procedure LockDocument; safecall;
    function  Get_RecordLocked: WordBool; safecall;
  end;

  TwrpScrException = class(TwrpObject, IgsException)
  private
    function  GetScrException: EScrException;
  protected
    procedure  Raise_(const ClassName: WideString;
      const EMessage: WideString); safecall;
    procedure Clear; safecall;
  end;

  TwrpGDCAcctEntryLine = class(TwrpGDCBase, IgsGDCAcctEntryLine)
  private
    function GetGDCAcctEntryLine: TgdcAcctEntryLine;
  protected
    function  Get_AccountPart: WideString; safecall;
    procedure Set_AccountPart(const Value: WideString); safecall;
    function  Get_RecordKey: Integer; safecall;
    procedure Set_RecordKey(Value: Integer); safecall;
    function  Get_gdcQuantity: IgsGdcAcctQuantity; safecall;
  end;

  TwrpGDCAcctSimpleRecord = class(TwrpGDCBase, IgsGDCAcctSimpleRecord)
  private
    function GetGDCAcctSimpleRecord: TgdcAcctSimpleRecord;
  protected
    function  Get_DebitEntryLine: IgsGDCAcctEntryLine; safecall;
    function  Get_CreditEntryLine: IgsGDCAcctEntryLine; safecall;
    function  Get_Document: IgsGDCDocument; safecall;
    procedure Set_Document(const Value: IgsGDCDocument); safecall;
    function  Get_TransactionKey: Integer; safecall;
    procedure Set_TransactionKey(Value: Integer); safecall;
  end;

  TwrpGDCAccount = class(TwrpGDCBase, IgsGDCAccount)
  private
    function GetGDCAccount: TgdcAccount;
  protected
    function  Get_IgnoryQuestion: WordBool; safecall;
    procedure Set_IgnoryQuestion(Value: WordBool); safecall;
    function  CheckDouble(const AnAccount: WideString; const ABankCode: WideString): WordBool; safecall;
    function  CheckAccount(const Code: WideString; const Account: WideString): WordBool; safecall;
  end;

  TwrpAtContainer = class(TwrpScrollingWinControl, IgsAtContainer)
  private
    function  GetAtContainer: TatContainer;
  protected
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
 //   procedure LoadFromStream(const Stream: IgsStream); safecall;
 //   procedure SaveToStream(const Stream: IgsStream); safecall;
    function  Get_ControlByFieldName(const AFieldName: WideString): IgsControl; safecall;
    function  Get_LabelIndent: Integer; safecall;
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
  end;

  TwrpNumberConvert = class(TwrpComponent, IgsNumberConvert)
  private
    function  GetNumberConvert: TNumberConvert;
  protected
    function  ConvertToString(const Digits: WideString; UpCase: WordBool; const Prefix: WideString;
                              const Postfix: WideString): WideString; safecall;
    function  ConvertFromString(const S: WideString; const Digits: WideString;
                                const Prefix: WideString; const Postfix: WideString): Double; safecall;
    function  Get_Value: Double; safecall;
    procedure Set_Value(Value: Double); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function  Get_BlankChar: WideString; safecall;
    procedure Set_BlankChar(const Value: WideString); safecall;
    function  Get_UpperCase: WordBool; safecall;
    procedure Set_UpperCase(Value: WordBool); safecall;
    function  Get_Language: TgsLanguage; safecall;
    procedure Set_Language(Value: TgsLanguage); safecall;
    function  Get_Gender: TgsGender; safecall;
    procedure Set_Gender(Value: TgsGender); safecall;
    function  Get_SignBeforePrefix: WordBool; safecall;
    procedure Set_SignBeforePrefix(Value: WordBool); safecall;
    function  Get_PrefixBeforeBlank: WordBool; safecall;
    procedure Set_PrefixBeforeBlank(Value: WordBool); safecall;
    function  Get_FreeStyleDigits: WideString; safecall;
    procedure Set_FreeStyleDigits(const Value: WideString); safecall;
    function  Get_Dec: WideString; safecall;
    procedure Set_Dec(const Value: WideString); safecall;
    function  Get_Hex: WideString; safecall;
    procedure Set_Hex(const Value: WideString); safecall;
    function  Get_Oct: WideString; safecall;
    procedure Set_Oct(const Value: WideString); safecall;
    function  Get_Bin: WideString; safecall;
    procedure Set_Bin(const Value: WideString); safecall;
    function  Get_Roman: WideString; safecall;
    procedure Set_Roman(const Value: WideString); safecall;
    function  Get_FreeStyle: WideString; safecall;
    procedure Set_FreeStyle(const Value: WideString); safecall;
    function  Get_DecPrefix: WideString; safecall;
    procedure Set_DecPrefix(const Value: WideString); safecall;
    function  Get_HexPrefix: WideString; safecall;
    procedure Set_HexPrefix(const Value: WideString); safecall;
    function  Get_OctPrefix: WideString; safecall;
    procedure Set_OctPrefix(const Value: WideString); safecall;
    function  Get_BinPref: WideString; safecall;
    procedure Set_BinPref(const Value: WideString); safecall;
    function  Get_RomPrefix: WideString; safecall;
    procedure Set_RomPrefix(const Value: WideString); safecall;
    function  Get_FreeStylePref: WideString; safecall;
    procedure Set_FreeStylePref(const Value: WideString); safecall;
    function  Get_NumPrefix: WideString; safecall;
    procedure Set_NumPrefix(const Value: WideString); safecall;
    function  Get_DecPostfix: WideString; safecall;
    procedure Set_DecPostfix(const Value: WideString); safecall;
    function  Get_HexPostfix: WideString; safecall;
    procedure Set_HexPostfix(const Value: WideString); safecall;
    function  Get_OctPostfix: WideString; safecall;
    procedure Set_OctPostfix(const Value: WideString); safecall;
    function  Get_BinPostfix: WideString; safecall;
    procedure Set_BinPostfix(const Value: WideString); safecall;
    function  Get_RomPostfix: WideString; safecall;
    procedure Set_RomPostfix(const Value: WideString); safecall;
    function  Get_FreeStylePostfix: WideString; safecall;
    procedure Set_FreeStylePostfix(const Value: WideString); safecall;
    function  Get_NumPostfix: WideString; safecall;
    procedure Set_NumPostfix(const Value: WideString); safecall;
    function  Get_Numeral: WideString; safecall;
    procedure Set_Numeral(const Value: WideString); safecall;
  end;

  TwrpGsScanerHook = class(TwrpComponent, IgsGsScanerHook)
  private
    function  GetGsScanerHook: TgsScanerHook;
  protected
    function  Get_StartScaner: WordBool; safecall;
    procedure Set_StartScaner(Value: WordBool); safecall;
    function  Get_TestCode: WideString; safecall;
    procedure Set_TestCode(const Value: WideString); safecall;
    function  Get_BeforeChar: Word; safecall;
    procedure Set_BeforeChar(Value: Word); safecall;
    function  Get_AfterChar: Word; safecall;
    procedure Set_AfterChar(Value: Word); safecall;
    function  Get_UseCtrlCode: WordBool; safecall;
    procedure Set_UseCtrlCode(Value: WordBool); safecall;
    function  Get_BarCode: WideString; safecall;
    procedure Set_BarCode(const Value: WideString); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure InitScaner(aEnabled: WordBool); safecall;
    function  Get_UseCtrlCodeAfter: WordBool; safecall;
    procedure Set_UseCtrlCodeAfter(Value: WordBool); safecall;

  end;

  TwrpGsCustomDBTreeView = class(TwrpCustomTreeView, IgsGsCustomDBTreeView)
  private
    function GetGsCustomDBTreeView: TGsCustomDBTreeView;
  protected
    function  GoToID(AnID: Integer): WordBool; safecall;
    procedure DeleteID(AnID: Integer); safecall;
    procedure Cut; safecall;
    function  Find(AnID: Integer): IgsTreeNode; safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_KeyField: WideString; safecall;
    procedure Set_KeyField(const Value: WideString); safecall;
    function  Get_ParentField: WideString; safecall;
    procedure Set_ParentField(const Value: WideString); safecall;
    function  Get_DisplayField: WideString; safecall;
    procedure Set_DisplayField(const Value: WideString); safecall;
    function  Get_ImageField: WideString; safecall;
    procedure Set_ImageField(const Value: WideString); safecall;
    function  Get_TopKey: Integer; safecall;
    procedure Set_TopKey(Value: Integer); safecall;
    function  Get_CutNode: IgsTreeNode; safecall;
    function  Get_MainFolder: WordBool; safecall;
    procedure Set_MainFolder(Value: WordBool); safecall;
    function  Get_MainFolderHead: WordBool; safecall;
    procedure Set_MainFolderHead(Value: WordBool); safecall;
    function  Get_MainFolderCaption: WideString; safecall;
    procedure Set_MainFolderCaption(const Value: WideString); safecall;
    function  Get_ImageValueList: IgsStringList; safecall;
    procedure Set_ImageValueList(const Value: IgsStringList); safecall;
    function  Get_WithCheckBox: WordBool; safecall;
    procedure Set_WithCheckBox(Value: WordBool); safecall;
    function  Get_ID: Integer; safecall;
    function  Get_ParentID: Integer; safecall;
    function  Get_TVState: IgsTvState; safecall;
    procedure AddCheck(AnID: Integer); safecall;
    procedure DeleteCheck(AnID: Integer); safecall;
    procedure SaveToStream_(const S: IgsStream); safecall;
    procedure LoadFromStream_(const S: IgsStream); safecall;

  end;

  TwrpGdKeyStringAssoc = class(TwrpGDKeyArray, IgsGDKeyStringAssoc)
  private
    function  GetGdKeyStringAssoc: TgdKeyStringAssoc;
  protected
    function  Get_ValuesByIndex(Index: Integer): WideString; safecall;
    procedure Set_ValuesByIndex(Index: Integer; const Value: WideString); safecall;
    function  Get_ValuesByKey(Key: Integer): WideString; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpTvState = class(TwrpObject, IgsTvState)
  private
    function  GetTvState: TTVState;
  protected
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
    procedure InitTree; safecall;
    procedure SaveTreeState; safecall;
    procedure NodeExpanded(AnID: Integer); safecall;
    procedure NodeCollapsed(AnID: Integer); safecall;
    procedure NodeChecked(AnID: Integer); safecall;
    procedure NodeUnChecked(AnID: Integer); safecall;
    function  Get_SelectedID: Integer; safecall;
    procedure Set_SelectedID(Value: Integer); safecall;
    function  Get_Bookmarks: IgsGdKeyStringAssoc; safecall;
    function  Get_Checked: IgsGDKeyArray; safecall;
    function  Get_CheckedChanged: WordBool; safecall;
  end;

  TwrpCustomColorComboBox = class(TwrpCustomComboBox, IgsCustomColorComboBox)
  private
    function GetCustomColorComboBox: TCustomColorComboBox;
  protected
    function  Get_Colors(Index: Integer): Integer; safecall;
    function  Get_ColorNames(Index: Integer): WideString; safecall;
    function  Get_Selected: Integer; safecall;
    procedure Set_Selected(Value: Integer); safecall;
    function  Get_DefaultColor: Integer; safecall;
    procedure Set_DefaultColor(Value: Integer); safecall;
    function  Get_NoneColor: Integer; safecall;
    procedure Set_NoneColor(Value: Integer); safecall;
  end;

  TwrpColorComboBox = class(TwrpCustomColorComboBox, IgsColorComboBox)
  end;

  TwrpAtPrimaryKeys = class(TwrpObject, IgsAtPrimaryKeys)
  private
    function  GetAtPrimaryKeys: TAtPrimaryKeys;
  protected
    function  Add(const atPrimaryKey: IgsAtPrimaryKey): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    function  ByConstraintName(const AConstraintName: WideString): IgsAtPrimaryKey; safecall;
    function  IndexOf(const AnObject: IgsObject): Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Items(Index: Integer): IgsAtPrimaryKey; safecall;
  end;

  TwrpAtPrimaryKey = class(TwrpObject, IgsAtPrimaryKey)
  private
    function  GetAtPrimaryKey: TAtPrimaryKey;
  protected
    procedure RefreshData; safecall;
    function  Get_Relation: IgsAtRelation; safecall;
    function  Get_ConstraintName: WideString; safecall;
    function  Get_IndexName: WideString; safecall;
    function  Get_ConstraintFields: IgsAtRelationFields; safecall;
    function  Get_IsDropped: WordBool; safecall;
    procedure RefreshData2(const IBSQL: IgsIBSQL); safecall;
    procedure RefreshData3(const Database: IgsIBDatabase; const Transaction: IgsIBTransaction); safecall;
  end;

  TwrpAtForeignKeys = class(TwrpObject, IgsAtForeignKeys)
  private
    function  GetAtForeignKeys: TAtForeignKeys;
  protected
    function  Add(const atPrimaryKey: IgsAtForeignKey): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    function  ByConstraintName(const AConstraintName: WideString): IgsAtForeignKey; safecall;
    function  ByRelationAndReferencedRelation(const ARelationName: WideString;
                                              const AReferencedRelationName: WideString): IgsAtForeignKey; safecall;
    function  IndexOf(const AnObject: IgsObject): Integer; safecall;
    procedure ConstraintsByRelation(const RelationName: WideString; const List: IgsObjectList); safecall;
    procedure ConstraintsByReferencedRelation(const RelationName: WideString;
                                              const List: IgsObjectList; ClearList: WordBool); safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Items(Index: Integer): IgsAtForeignKey; safecall;
  end;

  TwrpAtFields = class(TwrpObject, IgsAtFields)
  private
    function  GetAtFields: TAtFields;
  protected
    procedure RefreshData; safecall;
    procedure RefreshData3(const Database: IgsIBDatabase; const Transaction: IgsIBTransaction); safecall;
    function  Add(const atField: IgsAtField): Integer; safecall;
    function  ByFieldName(const AFieldName: WideString): IgsAtField; safecall;
    function  ByID(ID: Integer): IgsAtField; safecall;
    procedure Delete(Index: Integer); safecall;
    function  FindFirst(const FieldName: WideString): IgsAtField; safecall;
    function  IndexOf(const AnObject: IgsObject): Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Items(Index: Integer): IgsAtField; safecall;
  end;

  TwrpAtRelations = class(TwrpObject, IgsAtRelations)
  private
    function  GetAtRelations: TAtRelations;
  protected
    procedure RefreshData(WithCommit: WordBool); safecall;
    procedure RefreshData3(const Database: IgsIBDatabase; const Transaction: IgsIBTransaction;
                           IsRefreshFields: WordBool); safecall;
    function  Add(const atPrimaryKey: IgsAtRelation): Integer; safecall;
    procedure Delete(Index: Integer); safecall;
    function  Remove(const atRelation: IgsAtRelation): Integer; safecall;
    function  ByRelationName(const RelationName: WideString): IgsAtRelation; safecall;
    function  ByID(ID: Integer): IgsAtRelation; safecall;
    function  FindFirst(const FieldName: WideString): IgsAtRelation; safecall;
    function  IndexOf(const AnObject: IgsObject): Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Items(Index: Integer): IgsAtRelation; safecall;
    procedure NotifyUpdateObject(const ARelationName: WideString); safecall;
  end;

  TwrpGdc_dlgTR = class(TwrpGDC_dlgG, IgsGdc_dlgTR)
  end;

  TwrpGdc_dlgHGR = class(TwrpGDC_dlgTR, IgsGdc_dlgHGR)
   private
    function GetGdc_dlgHGR: Tgdc_dlgHGR;

  protected
    function  Get_gdcDetailObject: IgsGDCBase; safecall;
    procedure Set_gdcDetailObject(const Value: IgsGDCBase); safecall;
  end;

  TwrpDlgInvDocument = class(TwrpGdc_dlgTR, IgsDlgInvDocument)
  private
    function  GetDlgInvDocument: TdlgInvDocument;
  protected
    function  Get_Document: IgsGdcInvDocument; safecall;
    function  Get_DocumentLine: IgsGdcInvDocumentLine; safecall;
    function  Get_SecondDocumentLine: IgsGdcInvDocumentLine; safecall;
    function  Get_IsInsertMode: WordBool; safecall;
    procedure Set_IsInsertMode(Value: WordBool); safecall;
    function  Get_IsAutoCommit: WordBool; safecall;
    procedure Set_IsAutoCommit(Value: WordBool); safecall;
  end;

  Twrpgdc_dlgUserComplexDocument = class(TwrpGdc_dlgHGR, Igsgdc_dlgUserComplexDocument)
  private
    function  GetDlgUserComplexDocument: Tgdc_dlgUserComplexDocument;
  protected
    function  Get_IsAutoCommit: WordBool; safecall;
    procedure Set_IsAutoCommit(Value: WordBool); safecall;
  end;


  TwrpBtnEdit = class(TwrpCustomEdit, IgsBtnEdit)
  private
    function  GetBtnEdit: TBtnEdit;
  protected
    function  Get_BtnCaption: WideString; safecall;
    procedure Set_BtnCaption(const Value: WideString); safecall;
    function  Get_BtnCursor: Integer; safecall;
    procedure Set_BtnCursor(Value: Integer); safecall;
    function  Get_BtnGlyph: IgsBitmap; safecall;
    procedure Set_BtnGlyph(const Value: IgsBitmap); safecall;
    function  Get_BtnWidth: Integer; safecall;
    procedure Set_BtnWidth(Value: Integer); safecall;
    procedure AssignSize(const Source: IgsBtnEdit); safecall;
  end;

  TwrpGdcTaxResult = class(TwrpGdcBase, IgsGdcTaxResult)
    private
      function  GetGdcTaxResult: TgdcTaxResult;
    protected
      function  Get_CorrectResult: OleVariant; safecall;
  end;

  TwrpFieldsCallList = class(TwrpObject, IgsFieldsCallList)
  private
    function  GetFieldsCallList: TFieldsCallList;
  protected
    function  AddFieldList(const Name: WideString): Integer; safecall;
    procedure RemoveFieldList(const Name: WideString); safecall;
    procedure ClearList; safecall;
    function  Get_FieldList(Index: Integer): IgsStringList; safecall;
    function  CheckField(const DatasetName: WideString; const FieldName: WideString): WordBool; safecall;
    function  IndexOf(const Name: WideString): Integer; safecall;
  end;

  TwrpAtDatabase = class(TwrpObject, IgsAtDatabase)
  protected
    procedure IncrementGarbageCount; safecall;
    function  Get_MultiConnectionTransaction: Integer; safecall;
    function  Get_Relations: IgsAtRelations; safecall;
    function  Get_Fields: IgsAtFields; safecall;
    function  Get_ForeignKeys: IgsAtForeignKeys; safecall;
    function  Get_PrimaryKeys: IgsAtPrimaryKeys; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    function  Get_Loaded: WordBool; safecall;
    function  Get_Loading: WordBool; safecall;
    function  Get_InMultiConnection: WordBool; safecall;
    procedure ProceedLoading(Force: WordBool); safecall;
    procedure ForceLoadFromDatabase; safecall;
    function  FindRelationField(const ARelationName: WideString;
                                const ARelationFieldName: WideString): IgsAtRelationField; safecall;
    procedure NotifyMultiConnectionTransaction; safecall;
    procedure CancelMultiConnectionTransaction(All: WordBool); safecall;
    function  StartMultiConnectionTransaction: WordBool; safecall;
    procedure CheckMultiConnectionTransaction; safecall;
    procedure SyncIndicesAndTriggers(const ATransaction: IgsIBTransaction); safecall;
  end;

  TwrpgsComboBoxAttrSet = class(TwrpComboBox, IgsComboBoxAttrSet)
  private
    function GetComboBoxAttrSet: TgsComboBoxAttrSet;
  protected
    function  Get_ValueID: IgsStrings; safecall;
    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_PrimaryName: WideString; safecall;
    procedure Set_PrimaryName(const Value: WideString); safecall;
    function  Get_DialogType: WordBool; safecall;
    procedure Set_DialogType(Value: WordBool); safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_Condition: WideString; safecall;
    procedure Set_Condition(const Value: WideString); safecall;
    function  Get_SortOrder: TgsgsSortOrder; safecall;
    procedure Set_SortOrder(Value: TgsgsSortOrder); safecall;
    function  Get_SortField: WideString; safecall;
    procedure Set_SortField(const Value: WideString); safecall;
    procedure ValueIDChange; safecall;
    procedure DropDown; safecall;
  end;

  TwrpGdcSetting = class(TwrpGDCBase, IgsGdcSetting)
  private
    function  GetGdcSetting: TGdcSetting;
  protected
    procedure ActivateSetting(const KeyAr: IgsStrings; const BL: IgsBookmarkList;
                              AnModalSQLProcess: WordBool); safecall;
    procedure DeactivateSetting; safecall;
    procedure SaveSettingToBlob(SettingFormat: Word); safecall;
    procedure ReActivateSetting(const BL: IgsBookmarkList); safecall;
    procedure MakeOrder; safecall;
    procedure ChooseMainSetting; safecall;
    function  Get_Silent: WordBool; safecall;
    procedure Set_Silent(Value: WordBool); safecall;
    procedure UpdateActivateError; safecall;
    function  Get_ActivateErrorDescription: WideString; safecall;
    procedure Set_ActivateErrorDescription(const Value: WideString); safecall;
    procedure AddToSetting(FromStorage: WordBool; const BranchName: WideString; 
                           const ValueName: WideString; const AnObject: IgsGDCBase; 
                           const BL: IgsBookmarkList); safecall;
  end;

  TwrpGdcSettingPos = class(TwrpGDCBase, IgsGdcSettingPos)
  private
    function  GetGdcSettingPos: TGdcSettingPos;
  protected
    procedure ChooseNewItem; safecall;
    procedure AddPos(const AnObject: IgsGDCBase; WithDetail: WordBool); safecall;
    procedure Valid(DoAutoDelete: WordBool); safecall;
    procedure SetWithDetail(Value: WordBool; const BL: IgsBookmarkList); safecall;
    procedure SetNeedModify(Value: WordBool; const BL: IgsBookmarkList); safecall;
    procedure SetNeedModifyDefault; safecall;
  end;

  TwrpGdcSettingStorage = class(TwrpGDCBase, IgsGdcSettingStorage)
  private
    function  GetGdcSettingStorage: TGdcSettingStorage;
  protected
    procedure AddPos(const ABranchName: WideString; const AValueName: WideString); safecall;
    procedure Valid; safecall;
  end;

  TwrpGdcAcctQuantity = class(TwrpGdcBase, IgsGdcAcctQuantity);

  TwrpGdcAcctBaseEntryRegister = class(TwrpGDCBase, IgsGdcAcctBaseEntryRegister)
  private
    function GetGdcAcctBaseEntryRegister: TGdcAcctBaseEntryRegister;
  protected
    function  Get_RecordKey: Integer; safecall;
    function  Get_Document: IgsGDCDocument; safecall;
    procedure Set_Document(const Value: IgsGDCDocument); safecall;
    function  Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function  Get_gdcQuantity: IgsGdcAcctQuantity; safecall;
  end;

  TwrpGdcAcctViewEntryRegister = class(TwrpGdcAcctBaseEntryRegister, IgsGdcAcctViewEntryRegister)
  private
    function GetGdcAcctViewEntryRegister: TGdcAcctViewEntryRegister;
  protected
    function  Get_EntryGroup: TgsEntryGroup; safecall;
    procedure Set_EntryGroup(Value: TgsEntryGroup); safecall;
  end;

  TwrpGdcBaseFile = class(TwrpGdcLBRBTree, IgsGdcBaseFile)
  private
    function GetGdcBaseFile: TgdcBaseFile;
  protected
    function  CheckFileName: WordBool; safecall;
    function  SynchronizeByName(const AFileName: WideString; ChooseLocation: WordBool;
                                Action: TgsflAction): WordBool; safecall;
    function  Synchronize(AnID: Integer; ChooseLocation: WordBool; Action: TgsflAction): WordBool; safecall;
    function  Get_FullPath: WideString; safecall;
    function  Get_RootDirectory: WideString; safecall;
    procedure Set_RootDirectory(const Value: WideString); safecall;
    function  Get_Length: Integer; safecall;
    function  Find_(const AFileName: WideString): Integer; safecall;
    function  GetPathToFolder(AFolderID: Integer): WideString; safecall;
  end;

  TwrpGdcFile = class(TwrpGdcBaseFile, IgsGdcFile)
  private
    function GetGdcFile: TgdcFile;
  protected
    procedure LoadDataFromFile(const AFileName: WideString); safecall;
    procedure SaveDataToFile(const AFileName: WideString); safecall;
    procedure ViewFile(NeedExit: WordBool; NeedSave: WordBool); safecall;
    function  GetViewFilePath: WideString; safecall;
    function  TheSame(const AFileName: WideString): WordBool; safecall;
    procedure SaveDataToStream(const Stream: IgsStream); safecall;
    procedure LoadDataFromStream(const Stream: IgsStream); safecall;
  end;

  TwrpGdcFileFolder = class(TwrpGdcBaseFile, IgsGdcFileFolder)
  private
    function GetGdcFileFolder: TgdcFileFolder;
  protected
    function  FolderSize: Integer; safecall;
  end;

  TwrpGdEnumComboBox = class(TwrpCustomComboBox, IgsGdEnumComboBox)
  private
    function  GetGdEnumComboBox: TGdEnumComboBox;
  protected
    function  Get_Field: IgsField; safecall;
    function  Get_CurrentValue: WideString; safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
  end;

  TwrpGsColumn = class(TwrpColumn, IgsGsColumn)
  private
    function GetGsColumn: TgsColumn;
  protected
    function  Filterable: WordBool; safecall;
    function  IsFilterableField(const F: IgsField): WordBool; safecall;
    function  Get_Grid_: IgsCustomDBGrid; safecall;
    function  Get_Max: Integer; safecall;
    procedure Set_Max(Value: Integer); safecall;
    function  Get_FilteredValue: WideString; safecall;
    procedure Set_FilteredValue(const Value: WideString); safecall;
    function  Get_FilteredCache: IgsStringList; safecall;
    procedure Set_FilteredCache(const Value: IgsStringList); safecall;
    function  Get_Filtered: WordBool; safecall;
    procedure Set_Filtered(Value: WordBool); safecall;
    function  Get_DisplayFormat: WideString; safecall;
    procedure Set_DisplayFormat(const Value: WideString); safecall;
    function  Get_TotalType: TgsGsTotalType; safecall;
    procedure Set_TotalType(Value: TgsGsTotalType); safecall;
    function  Get_Frozen: WordBool; safecall;
    procedure Set_Frozen(Value: WordBool); safecall;
  end;

  TwrpGsColumns = class(TwrpDBGridColumns, IgsGsColumns)
  private
    function  GetGsColumns: TgsColumns;
  protected
    function  Add_: IgsGsColumn; safecall;
    function  Get_IsSetupMode: WordBool; safecall;
    function  Get_Grid_: IgsgsCustomDBGrid; safecall;
    function  Get_Items_(Index: Integer): IgsGsColumn; safecall;
    procedure Set_Items_(Index: Integer; const Value: IgsGsColumn); safecall;
  end;

  TwrpAtIgnore = class(TwrpCollectionItem, IgsAtIgnore)
  private
    function  GetAtIgnore: TAtIgnore;
  protected
    function  Get_Link: IgsComponent; safecall;
    procedure Set_Link(const Value: IgsComponent); safecall;
    function  Get_RelationName: WideString; safecall;
    procedure Set_RelationName(const Value: WideString); safecall;
    function  Get_AliasName: WideString; safecall;
    procedure Set_AliasName(const Value: WideString); safecall;
    function  Get_IgnoryType: TgsAtIgnoryType; safecall;
    procedure Set_IgnoryType(Value: TgsAtIgnoryType); safecall;
  end;

  TwrpAtIgnores = class(TwrpCollection, IgsAtIgnores)
  private
    function  GetAtIgnores: TAtIgnores;
  protected
    function  Get_Items(Index: Integer): IgsAtIgnore; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsAtIgnore); safecall;
    function  Add: IgsAtIgnore; safecall;
  end;

  TwrpAtSQLSetup = class(TwrpComponent, IgsAtSQLSetup)
  private
    function  GetAtSQLSetup: TAtSQLSetup;
  protected
    function  Get_Ignores: IgsAtIgnores; safecall;
    procedure Set_Ignores(const Value: IgsAtIgnores); safecall;
    function  Get_State: TgsSQLSetupState; safecall;
    function  PrepareSQL(const Text: WideString; const ObjectClassName: WideString): WideString; safecall;
    procedure AddLink(const AComponent: IgsComponent); safecall;
    procedure Prepare; safecall;
  end;

  TwrpGsRect = class(TwrpObject, IgsGsRect)
  private
    function  GetGsRect: TgsRect;
  protected
    function  Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function  Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function  Get_Right: Integer; safecall;
    procedure Set_Right(Value: Integer); safecall;
    function  Get_Bottom: Integer; safecall;
    procedure Set_Bottom(Value: Integer); safecall;
  end;

  TwrpGsPoint = class(TwrpObject, IgsGsPoint)
  private
    function  GetGsPoint: TgsPoint;
  protected
    function  Get_X: Integer; safecall;
    procedure Set_X(Value: Integer); safecall;
    function  Get_Y: Integer; safecall;
    procedure Set_Y(Value: Integer); safecall;
  end;

  TwrpGdKeyDuplArray = class(TwrpGDKeyArray, IgsGdKeyDuplArray)
  private
    function GetGdKeyDuplArray: TGdKeyDuplArray;
  protected
    function  AddDupl(Value: Integer): Integer; safecall;
    function  Get_Duplicates: TgsDuplicates; safecall;
    procedure Set_Duplicates(Value: TgsDuplicates); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdKeyObjectAssoc = class(TwrpGdKeyDuplArray, IgsGdKeyObjectAssoc)
  private
    function  GetGdKeyObjectAssoc: TGdKeyObjectAssoc;
  protected
    function  Remove(Key: Integer): Integer; safecall;
    function  Get_ObjectByIndex(Index: Integer): IgsObject; safecall;
    procedure Set_ObjectByIndex(Index: Integer; const Value: IgsObject); safecall;
    function  Get_ObjectByKey(Key: Integer): IgsObject; safecall;
    procedure Set_ObjectByKey(Key: Integer; const Value: IgsObject); safecall;
    function  Get_OwnsObjects: WordBool; safecall;
    procedure Set_OwnsObjects(Value: WordBool); safecall;
    function  AddObject(AKey: Integer; const AnObject: IgsObject): Integer; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdKeyIntArrayAssoc = class(TwrpGDKeyArray, IgsGdKeyIntArrayAssoc)
  private
    function GetGdKeyIntArrayAssoc: TGdKeyIntArrayAssoc;
  protected
    function  Get_ValuesByIndex(Index: Integer): IgsGDKeyArray; safecall;
    function  Get_ValuesByKey(Key: Integer): IgsGDKeyArray; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdKeyIntAndStrAssoc = class(TwrpGDKeyArray, IgsGdKeyIntAndStrAssoc)
  private
    function  GetGdKeyIntAndStrAssoc: TGdKeyIntAndStrAssoc;
  protected
    function  Get_StrByIndex(Index: Integer): WideString; safecall;
    procedure Set_StrByIndex(Index: Integer; const Value: WideString); safecall;
    function  Get_StrByKey(Key: Integer): WideString; safecall;
    procedure Set_StrByKey(Key: Integer; const Value: WideString); safecall;
    function  Get_IntByIndex(Index: Integer): Integer; safecall;
    procedure Set_IntByIndex(Index: Integer; Value: Integer); safecall;
    function  Get_IntByKey(Key: Integer): Integer; safecall;
    procedure Set_IntByKey(Key: Integer; Value: Integer); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdc_frmInvSelectedGoods = class(TwrpGdc_frmG, IgsGdc_frmInvSelectedGoods)
  private
    function GetGdc_frmInvSelectedGoods: Tgdc_frmInvSelectedGoods;
  protected
    function  Get_AssignFieldsName: WideString; safecall;
    procedure Set_AssignFieldsName(const Value: WideString); safecall;
    function  Get_EditedFieldsName: WideString; safecall;
    procedure Set_EditedFieldsName(const Value: WideString); safecall;
  end;

  TwrpGdcInvMovementContactOption = class(TwrpObject, IgsGdcInvMovementContactOption)
  private
    function GetGdcInvMovementContactOption: TGdcInvMovementContactOption;
  protected
    function  Get_RelationName: WideString; safecall;
    function  Get_SourceFieldName: WideString; safecall;
    function  Get_SubRelationName: WideString; safecall;
    function  Get_SubSourceFieldName: WideString; safecall;
    function  Get_ContactType: TGsGdcInvMovementContactType; safecall;
  end;

{$IFDEF MODEM}
  TwrpGsModem = class(TwrpComponent, IgsModem)
  private
    function  GetGsModem: TgsModem;
  protected

    procedure Cancel; safecall;
    function  ChooseModem: WordBool; safecall;
    procedure Call(const AnPhone: WideString); safecall;
    procedure Send(const AFileName: WideString); safecall;
    procedure WaitFile; safecall;

    function  Get_SelectedModem: WideString; safecall;
    procedure Set_SelectedModem(const Value: WideString); safecall;
    function  Get_Dialing: WordBool; safecall;
    function  Get_TapiState: Integer; safecall;

    function Get_Baud: Longint; safecall;
    procedure Set_Baud(Value: Longint); safecall;
    function Get_AnswerOnRing: Shortint; safecall;
    procedure Set_AnswerOnRing(Value: Shortint); safecall;
    function Get_MaxAttempts: Word; safecall;
    procedure Set_MaxAttempts(Value: Word); safecall;
    function Get_RetryWait: Word; safecall;
    procedure Set_RetryWait(Value: Word); safecall;
    function Get_TimeOut: Integer; safecall;
    procedure Set_TimeOut(Value: Integer); safecall;
    function Get_AutoReceive: WordBool; safecall;
    procedure Set_AutoReceive(Value: WordBool); safecall;
    function Get_DestinationDirectory: WideString; safecall;
    procedure Set_DestinationDirectory(const Value: WideString); safecall;
    function Get_ProtocolStatusCaption: WideString; safecall;
    procedure Set_ProtocolStatusCaption(const Value: WideString); safecall;
  end;
{$ENDIF}

  TwrpGsComScaner = class(TwrpComponent, IgsGsComScaner)
  private
    function  GetGsComScaner: TgsComScaner;
  protected
    function  Get_ComNumber: Shortint; safecall;
    procedure Set_ComNumber(Value: Shortint); safecall;
    function  Get_Parity: TgsParity; safecall;
    procedure Set_Parity(Value: TgsParity); safecall;
    function  Get_BaudRate: Integer; safecall;
    procedure Set_BaudRate(Value: Integer); safecall;
    function  Get_DataBits: Shortint; safecall;
    procedure Set_DataBits(Value: Shortint); safecall;
    function  Get_StopBits: Shortint; safecall;
    procedure Set_StopBits(Value: Shortint); safecall;
    function  Get_BeforeChar: Integer; safecall;
    procedure Set_BeforeChar(Value: Integer); safecall;
    function  Get_AfterChar: Shortint; safecall;
    procedure Set_AfterChar(Value: Shortint); safecall;
    function  Get_CRSuffix: WordBool; safecall;
    procedure Set_CRSuffix(Value: WordBool); safecall;
    function  Get_LFSuffix: WordBool; safecall;
    procedure Set_LFSuffix(Value: WordBool); safecall;
    function  Get_BarCode: WideString; safecall;
    procedure Set_BarCode(const Value: WideString); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_AllowStreamedEnabled: WordBool; safecall;
    procedure Set_AllowStreamedEnabled(Value: WordBool); safecall;
    procedure PutString(const S: WideString); safecall;
    function  Get_PacketSize: Integer; safecall;
    procedure Set_PacketSize(Value: Integer); safecall;
    function  Get_IntCode: Integer; safecall;
  end;

  TwrpStreamSaver = class(TwrpObject, IgsStreamSaver)
  private
    function  GetStreamSaver: TgdcStreamSaver;
  protected
    procedure AddObject(const AgdcObject: IgsGDCBase; AWithDetail: WordBool); safecall;
    procedure PrepareForIncrementSaving(ABasekey: Integer); safecall;
    procedure SaveToStream(const S: IgsStream; AFormat: WordBool = false); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure Clear; safecall;
    function Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_Silent: WordBool; safecall;
    procedure Set_Silent(Value: WordBool); safecall;
    function  Get_SaveWithDetailList: IgsGDKeyArray; safecall;
    procedure Set_SaveWithDetailList(const Value: IgsGDKeyArray); safecall;
    function  Get_NeedModifyList: IgsGDKeyIntAssoc; safecall;
    procedure Set_NeedModifyList(const Value: IgsGDKeyIntAssoc); safecall;
    function  Get_StreamFormat: WideString; safecall;
    procedure Set_StreamFormat(const Value: WideString); safecall;
    function  Get_ReplaceRecordAnswer: Word; safecall;
    procedure Set_ReplaceRecordAnswer(Value: Word); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdvAcctBase = class(TwrpIBCustomDataSet, IgsGdvAcctBase)
  private
    function GetGdvAcctBase: TgdvAcctBase;
  protected
    procedure ShowInNcu(Show: WordBool; DecDigits: Integer = -1; Scale: Integer = 0); safecall;
    procedure ShowInCurr(Show: WordBool; DecDigits: Integer = -1; Scale: Integer = 0; CurrKey: Integer = -1); safecall;
    procedure ShowInEQ(Show: WordBool; DecDigits: Integer = -1; Scale: Integer = 0); safecall;
    procedure ShowInQuantity(DecDigits: Integer = -1; Scale: Integer = 0); safecall;

    procedure AddAccount(AccountKey: Integer); safecall;
    procedure AddCorrAccount(AccountKey: Integer); safecall;
    procedure AddCondition(const FieldName: WideString; const AValue: WideString); safecall;
    procedure AddValue(ValueKey: Integer; const ValueName: WideString); safecall;

    procedure LoadConfig(AID: Integer); safecall;
    function  SaveConfig(AConfigKey: Integer): Integer; safecall;

    function  ParamByName(const ParamName: WideString): IgsIBXSQLVAR; safecall;
    procedure Execute(ConfigID: Integer); safecall;
    procedure BuildReport; safecall;
    procedure Clear; safecall;

    function  Get_DateBegin: TDateTime; safecall;
    procedure Set_DateBegin(Value: TDateTime); safecall;
    function  Get_DateEnd: TDateTime; safecall;
    procedure Set_DateEnd(Value: TDateTime); safecall;
    function  Get_MakeEmpty: WordBool; safecall;
    procedure Set_MakeEmpty(Value: WordBool); safecall;
    function  Get_CompanyKey: Integer; safecall;
    procedure Set_CompanyKey(Value: Integer); safecall;
    function  Get_AllHolding: WordBool; safecall;
    procedure Set_AllHolding(Value: WordBool); safecall;
    function  Get_WithSubAccounts: WordBool; safecall;
    procedure Set_WithSubAccounts(Value: WordBool); safecall;
    function  Get_IncludeInternalMovement: WordBool; safecall;
    procedure Set_IncludeInternalMovement(Value: WordBool); safecall;
    function  Get_ShowExtendedFields: WordBool; safecall;
    procedure Set_ShowExtendedFields(Value: WordBool); safecall;
    function  Get_CompanyName: WideString; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;
                    
  TwrpGdvAcctAccReview = class(TwrpGdvAcctBase, IgsGdvAcctAccReview)
  private
    function GetGdvAcctAccReview: TgdvAcctAccReview;
  protected
    function  Get_CorrDebit: WordBool; safecall;
    procedure Set_CorrDebit(Value: WordBool); safecall;
    function  Get_WithCorrSubAccounts: WordBool; safecall;
    procedure Set_WithCorrSubAccounts(Value: WordBool); safecall;
    function  Get_SaldoBeginNcu: Currency; safecall;
    function  Get_SaldoBeginCurr: Currency; safecall;
    function  Get_SaldoBeginEQ: Currency; safecall;
    function  Get_SaldoEndNcu: Currency; safecall;
    function  Get_SaldoEndCurr: Currency; safecall;
    function  Get_SaldoEndEQ: Currency; safecall;
    function  Get_IBDSSaldoBegin: IgsIBDataSet; safecall;
    function  Get_IBDSSaldoEnd: IgsIBDataSet; safecall;
    function  Get_IBDSCirculation: IgsIBDataSet; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdvAcctAccCard = class(TwrpGdvAcctAccReview, IgsGdvAcctAccCard)
  private
    function GetGdvAcctAccCard: TgdvAcctAccCard;
  protected
    function  Get_DoGroup: WordBool; safecall;
    procedure Set_DoGroup(Value: WordBool); safecall;
    function  Get_IBDSSaldoQuantityBegin: IgsIBDataSet; safecall;
    function  Get_IBDSSaldoQuantityEnd: IgsIBDataSet; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdvAcctLedger = class(TwrpGdvAcctBase, IgsGdvAcctLedger)
  private
    function GetGdvAcctLedger: TgdvAcctLedger;
  protected
    procedure AddGroupBy(const GroupFieldName: WideString); safecall;
    procedure AddAnalyticLevel(const AnalyticName: WideString; const Levels: WideString); safecall;
    function  Get_ShowDebit: WordBool; safecall;
    procedure Set_ShowDebit(Value: WordBool); safecall;
    function  Get_ShowCredit: WordBool; safecall;
    procedure Set_ShowCredit(Value: WordBool); safecall;
    function  Get_ShowCorrSubAccounts: WordBool; safecall;
    procedure Set_ShowCorrSubAccounts(Value: WordBool); safecall;
    function  Get_EnchancedSaldo: WordBool; safecall;
    procedure Set_EnchancedSaldo(Value: WordBool); safecall;
    function  Get_SumNull: WordBool; safecall;
    procedure Set_SumNull(Value: WordBool); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdvAcctGeneralLedger = class(TwrpGdvAcctLedger, IgsGdvAcctGeneralLedger)
  protected
    function GetGdvAcctGeneralLedger: TgdvAcctGeneralLedger;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGdvAcctCirculationList = class(TwrpGdvAcctLedger, IgsGdvAcctCirculationList)
  protected
    function GetGdvAcctCirculationList: TgdvAcctCirculationList;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGsParamData = class(TwrpObject, IgsParamData)
  private
    function GetParamData: TgsParamData;
  protected
    function  Get_RealName: WideString; safecall;
    procedure Set_RealName(const Value: WideString); safecall;
    function  Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function  Get_ParamType: WideString; safecall;
    procedure Set_ParamType(const Value: WideString); safecall;
    function  Get_Comment: WideString; safecall;
    procedure Set_Comment(const Value: WideString); safecall;
    function  Get_LinkTableName: WideString; safecall;
    procedure Set_LinkTableName(const Value: WideString); safecall;
    function  Get_LinkDisplayField: WideString; safecall;
    procedure Set_LinkDisplayField(const Value: WideString); safecall;
    function  Get_LinkPrimaryField: WideString; safecall;
    procedure Set_LinkPrimaryField(const Value: WideString); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function  Get_LinkConditionFunction: WideString; safecall;
    procedure Set_LinkConditionFunction(const Value: WideString); safecall;
    function  Get_LinkFunctionLanguage: WideString; safecall;
    procedure Set_LinkFunctionLanguage(const Value: WideString); safecall;
    function  Get_Required: WordBool; safecall;
    procedure Set_Required(Value: WordBool); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    procedure Assign_(const Source: IgsParamData); safecall;
    function  Get_ValuesList: WideString; safecall;
    procedure Set_ValuesList(const Value: WideString); safecall;
    function  Get_SortOrder: Shortint; safecall;
    procedure Set_SortOrder(Value: Shortint); safecall;
    function  Get_SortField: WideString; safecall;
    procedure Set_SortField(const Value: WideString); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGsParamList = class(TwrpObjectList, IgsParamList)
  private
    function GetParamList: TgsParamList;
  protected
    function AddParam(const AnDisplayName: WideString;
      const AnParamType: WideString; const AnComment: WideString): SYSINT; safecall;
    function  AddLinkParam(const AnDisplayName: WideString;
      const AnParamType: WideString; const AnTableName: WideString;
      const AnPrimaryField: WideString; const AnDisplayField: WideString;
      const AnLinkConditionFunction: WideString;
      const AnLinkFunctionLanguage: WideString; const AnComment: WideString): SYSINT; safecall;
    function GetVariantArray: OleVariant; safecall;
    function  Get_Params(Index: Integer): IgsParamData; safecall;
    procedure Assign_(const Source: IgsParamList); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGsFrmGedeminMain = class(TwrpCreateableForm, IgsFrmGedeminMain)
  private
    function GetFrmGedeminMain: TfrmGedeminMain;
  protected
    procedure AddFormToggleItem(const AForm: IgsForm); safecall;
    function  GetFormToggleItem(const AForm: IgsForm): IgsTBCustomItem; safecall;
    function  GetFormToggleItemIndex(const AForm: IgsForm): Integer; safecall;
  end;

  {$IFDEF WITH_INDY}
  TwrpGdWebServerControl = class(TwrpObject, IgdWebServerControl)
  private
    function GetWebServerControl: TgdWebServerControl;
  protected
    procedure RegisterOnGetEvent(const AComponent: IgsComponent; const AToken: WideString;
                                 const AEventName: WideString); safecall;
    procedure UnRegisterOnGetEvent(const AComponent: IgsComponent); safecall;
  end;

  TwrpGdWebClientControl = class(TwrpObject, IgdWebClientControl)
  private
    function GetWebClientControl: TgdWebClientControl;
  protected
    function  SendEMail(const Host: WideString; Port: Integer; const IPSec: WideString;
                        const Login: WideString; const Passw: WideString;
                        const SenderEmail: WideString; const Recipients: WideString;
                        const Subject: WideString; const BodyText: WideString;
                        const FileName: WideString; WipeFile: WordBool; WIpeDirectory: WordBool;
                        Sync: WordBool; WndHandle: Integer; ThreadID: Integer): Integer; safecall;
    function  SendEMail2(SMTPKey: Integer;
                         const Recipients: WideString; const Subject: WideString;
                         const BodyText: WideString; const FileName: WideString;
                         WipeFile: WordBool; WIpeDirectory: WordBool; Sync: WordBool;
                         WndHandle: Integer; ThreadID: Integer): Integer; safecall;
    function  SendEMail3(SMTPKey: Integer; const Recipients: WideString; const Subject: WideString;
                         const BodyText: WideString; ReportKey: Integer;
                         const ExportType: WideString; Sync: WordBool; WndHandle: Integer;
                         ThreadID: Integer): Integer; safecall;
    function  Get_EmailErrorMsg: WideString; safecall;
    function  Get_EmailCount: Integer; safecall;
  end;
  {$ENDIF}

  TwrpFTPClient = class(TwrpObject, IgsFTPClient)
  private
    function GetFTPClient: TgsFTPClient;
  protected
    function Get_ServerName: WideString; safecall;
    procedure Set_ServerName(const Value: WideString); safecall;
    function Get_ServerPort: Integer; safecall;
    procedure Set_ServerPort(Value: Integer); safecall;
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_Password: WideString; safecall;
    procedure Set_Password(const Value: WideString); safecall;
    function Get_TimeOut: Integer; safecall;
    procedure Set_TimeOut(Value: Integer); safecall;
    function Get_Files: WideString; safecall;
    function Get_LastError: Integer; safecall;

    function Connect: WordBool; safecall;
    function Connected: WordBool; safecall;
    procedure Close; safecall;

    function GetFile(const RemoteFile: WideString; const LocalFile: WideString; const RemotePath: WideString; Overwrite: Wordbool): WordBool; safecall;
    function PutFile(const LocalFile: WideString; const RemoteFile: wideString; const RemotePath: WideString; Overwrite: Wordbool): WordBool; safecall;
    function Deletefile(const RemoteFile: WideString; const RemotePath: WideString): WordBool; safecall;
    function GetAllFiles(const RemotePath: WideString): WordBool; safecall;
    function RenameFile(const OldName: WideString; const NewName: WideString; const Path: WideString): WordBool; safecall;
    function CreateDir(const DirName: WideString): WordBool; safecall;
    function DeleteDir(const DirName: WideString): WordBool; safecall;
    function  GetCurrentDirectory: WideString; safecall;
    function  SetCurrentDirectory(const RemotePath: WideString): WordBool; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpTRPOSClient = class(TwrpObject, IgsTRPOSClient)
  private
    function GetTRPOSClient: TgsTRPOSClient;
  protected
    function Get_Host: WideString; safecall;
    procedure Set_Host(const Value: WideString); safecall;
    function  Get_Port: Integer; safecall;
    procedure Set_Port(Value: Integer); safecall;
    function  Get_ReadTimeOut: Integer; safecall;
    procedure Set_ReadTimeOut(Value: Integer); safecall;
    function  Get_Connected: WordBool; safecall;
    procedure TestHost(ACashNumber: LongWord); safecall;
    procedure TestPinPad(ACashNumber: LongWord); safecall;
    procedure Connect; safecall;
    procedure Disconnect; safecall;
    procedure ReadData(const AParams: IgsTRPOSOutPutData); safecall;
    procedure Payment(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
      ACurrCode: Integer; APreAUT: WordBool; const AParam: IgsTRPOSParamData); safecall;
    procedure Cash(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord; ACurrCode: Integer; 
      const AParam: IgsTRPOSParamData); safecall;
    procedure Replenishment(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
      ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
    procedure Cancel(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord; 
      ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
    procedure Return(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord; 
      ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
    procedure ReadJournal(ATrNumber: LongWord; ACashNumber: LongWord; 
      const AParam: IgsTRPOSParamData); safecall;
    procedure PreAuthorize(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord; 
      ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
    procedure Balance(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData); safecall;
    procedure ResetLockJournal(ATrNumber: LongWord; ACashNumber: LongWord; 
      const AParam: IgsTRPOSParamData); safecall;
    procedure Calculation(ATrNumber: LongWord; ACashNumber: LongWord; 
      const AParam: IgsTRPOSParamData); safecall;
    procedure Ping(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData); safecall;
    procedure ReadCard(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData); safecall;
    procedure ReconciliationResults(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure Duplicate(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure JRNClean(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure RVRClean(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure FullClean(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure MenuPrintReport(ACashNumber: LongWord); safecall;
    procedure DSortByDate(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure DSortByIssuer(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure SSortByDate(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
    procedure RePrint(ATrNumber: LongWord; ACashNumber: LongWord); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpTRPOSOutPutData = class(TwrpObject, IgsTRPOSOutPutData)
  private
    function GetTRPOSOutPutData: TgsTRPOSOutPutData;
  protected
    function  Get_MessageID: WideString; safecall;
    function  Get_ECRnumber: LongWord; safecall;
    function  Get_ERN: LongWord; safecall;
    function  Get_ResponseCode: WideString; safecall;
    function  Get_TransactionAmount: WideString; safecall;
    function  Get_Pan: WideString; safecall;
    function  Get_ExpDate: WideString; safecall;
    function  Get_Approve: WideString; safecall;
    function  Get_Receipt: WideString; safecall;
    function  Get_InvoiceNumber: WideString; safecall;
    function  Get_AuthorizationID: WideString; safecall;
    function  Get_Date: WideString; safecall;
    function  Get_Time: WideString; safecall;
    function  Get_VerificationChr: WideString; safecall;
    function  Get_RRN: WideString; safecall;
    function  Get_TVR: WideString; safecall;
    function  Get_TerminalID: WideString; safecall;
    function  Get_CardDataEnc: WideString; safecall;
    function  Get_VisualHostResponse: WideString; safecall;
    procedure Clear; safecall;
  end;

  TwrpTRPOSParamData = class(TwrpObject, IgsTRPOSParamData)
  private
    function GetTRPOSParamData: TgsTRPOSParamData;
  protected
    function  Get_Track1Data: WideString; safecall;
    procedure Set_Track1Data(const Value: WideString); safecall;
    function  Get_Track2Data: WideString; safecall;
    procedure Set_Track2Data(const Value: WideString); safecall;
    function  Get_Track3Data: WideString; safecall;
    procedure Set_Track3Data(const Value: WideString); safecall;
    function  Get_Pan: WideString; safecall;
    procedure Set_Pan(const Value: WideString); safecall;
    function  Get_ExpDate: WideString; safecall;
    procedure Set_ExpDate(const Value: WideString); safecall;
    function  Get_InvoiceNumber: Integer; safecall;
    procedure Set_InvoiceNumber(Value: Integer); safecall;
    function  Get_AuthorizationID: Integer; safecall;
    procedure Set_AuthorizationID(Value: Integer); safecall;
    function  Get_MerchantID: Integer; safecall;
    procedure Set_MerchantID(Value: Integer); safecall;
    function  Get_RRN: WideString; safecall;
    procedure Set_RRN(const Value: WideString); safecall;
    function  Get_CardDataEnc: WideString; safecall;
    procedure Set_CardDataEnc(const Value: WideString); safecall;  
  end;

  TwrpPLTermv = class(TwrpObject, IgsPLTermv)
  private
    function GetPLTermv: TgsPLTermv;
  protected
    procedure PutInteger(Idx: LongWord; AValue: Integer); safecall;
    procedure PutString(Idx: LongWord; const AValue: WideString); safecall;
    procedure PutFloat(Idx: LongWord; AValue: Double); safecall;
    procedure PutDateTime(Idx: LongWord; AValue: TDateTime); safecall;
    procedure PutDate(Idx: LongWord; AValue: TDateTime); safecall;
    procedure PutInt64(Idx: LongWord; AValue: Int64); safecall;
    procedure PutAtom(Idx: LongWord; const AValue: WideString); safecall;
    procedure PutVariable(Idx: LongWord); safecall;
    procedure Reset; safecall;
    function  ReadInteger(Idx: LongWord): Integer; safecall;
    function  ReadString(Idx: LongWord): WideString; safecall;
    function  ReadFloat(Idx: LongWord): Double; safecall;
    function  ReadDateTime(Idx: LongWord): TDateTime; safecall;
    function  ReadDate(Idx: LongWord): TDateTime; safecall;
    function  ReadInt64(Idx: LongWord): Int64; safecall;
    function  ReadAtom(Idx: LongWord): WideString; safecall;
    function  ToString(Idx: LongWord): WideString; safecall;
    function  ToTrimQuotesString(Idx: LongWord): WideString; safecall;
    function  Get_DataType(Idx: LongWord): Integer; safecall;
    function  Get_Term(Idx: LongWord): LongWord; safecall;
    function  Get_Size: LongWord; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpPLClient = class(TwrpObject, IgsPLClient)
  private
    function GetPLClient: TgsPLClient;
  protected
    function Call(const APredicateName: WideString; const AParams: IgsPLTermv): WordBool; safecall;
    function Call2(const AGoal: WideString): WordBool; safecall;
    function Initialise(const AParams: WideString): WordBool; safecall;
    function IsInitialised: WordBool; safecall;
    function Cleanup: WordBool; safecall;
    procedure ExtractData(const ADataSet: IgsClientDataSet; const APredicateName: WideString;
      const ATermv: IgsPLTermv); safecall;
    function MakePredicatesOfSQLSelect(const ASQL: WideString; const ATr: IgsIBTransaction;
      const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer; safecall;
    function MakePredicatesOfDataSet(const ADataSet: IgsDataSet; const AFieldList: WideString;
      const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer; safecall;
    {*function MakePredicatesOfObject(const AClassName: WideString; const SubType: WideString;
      const ASubSet: WideString; AParams: OleVariant; const AnExtraConditions: IgsStringList;
      const AFieldList: WideString; const ATr: IgsIBTransaction;
      const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer; safecall;
    *}
    procedure Compound(AGoal: LongWord; const AFunctor: WideString; const ATermv: IgsPLTermv); safecall;
    function LoadScript(AScriptID: Integer): WordBool; safecall;
    function LoadScriptByName(const AScriptName: WideString): WordBool; safecall;
    function Get_Debug: WordBool; safecall;
    procedure Set_Debug(Value: WordBool); safecall;
    procedure SavePredicatesToFile(const APredicateName: WideString; const ATermv: IgsPLTermv;
      const AFileName: WideString); safecall;
  end;

  TwrpPLQuery = class(TwrpObject, IgsPLQuery)
  private
    function GetPLQuery: TgsPLQuery;
  protected
    procedure NextSolution; safecall;
    procedure OpenQuery; safecall;
    procedure Close; safecall;
    function Get_PredicateName: WideString; safecall;
    procedure Set_PredicateName(const Value: WideString); safecall;
    function Get_Eof: WordBool; safecall;
    function Get_Termv: IgsPLTermv; safecall;
    procedure Set_Termv(const Value: IgsPLTermv); safecall;
    procedure Cut; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpFilesFrame = class(TwrpFrame, IgsFilesFrame)
  private
    function GetFilesFrame: TFilesFrame;
  protected
    function  Get_ChangeCount: integer; safecall;
    procedure Setup; safecall;
    procedure Cleanup; safecall;
    procedure DisplayDiffs; safecall;
    procedure NextClick; safecall;
    procedure PrevClick; safecall;
    procedure FindClick(const OwnerForm: IgsCustomForm); safecall;
    procedure FindNextClick(const OwnerForm: IgsCustomForm); safecall;
    procedure ReplaceClick(const OwnerForm: IgsCustomForm); safecall;
    procedure Compare(const S1: WideString; const S2: WideString); safecall;
    function  Get_ShowDiffsOnly: WordBool; safecall;
    procedure Set_ShowDiffsOnly(Value: WordBool); safecall;
  end;

  TwrpGSRAChart = class(TwrpCustomControl, IgsRAChart)
  private
    function GetRAChart: TgsRAChart;
  protected
    function  Get_MinValue: OleVariant; safecall;
    procedure Set_MinValue(Value: OleVariant); safecall;
    function  Get_MaxValue: OleVariant; safecall;
    procedure Set_MaxValue(Value: OleVariant); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function  Get_ResourceID: Integer; safecall;
    procedure Set_ResourceID(Value: Integer); safecall;
    function  Get_FirstVisibleValue: OleVariant; safecall;
    procedure Set_FirstVisibleValue(Value: OleVariant); safecall;
    function  AddRowHead(const ACaption: WideString; AWidth: Integer): Integer; safecall;
    function  AddRowTail(const ACaption: WideString; AWidth: Integer): Integer; safecall;
    function  AddResource(AnID: Integer; const AName: WideString; const ASubItems: WideString): Integer; safecall;
    function  AddSubResource(AnID: Integer; AParentID: Integer; const AName: WideString;
                             const ASubItems: WideString): Integer; safecall;
    function  AddInterval(AnID: Integer; AResourceID: Integer; AStartValue: OleVariant;
                          AnEndValue: OleVariant; AData: OleVariant; const AComment: WideString;
                          AColor: Integer; AFontColor: Integer; ABorderKind: Integer): Integer; safecall;
    function  Get_IntervalID: Integer; safecall;
    function  Get_DragValue: OleVariant; safecall;
    function  Get_DragResourceID: Integer; safecall;
    function  Get_DragIntervalID: Integer; safecall;
    procedure ClearResources; safecall;
    procedure DeleteResource(AnID: Integer); safecall;
    procedure ClearIntervals(AResourceID: Integer); safecall;
    procedure DeleteInterval(AResourceID: Integer; AnID: Integer); safecall;
    function  Get_SelectedCount: Integer; safecall;
    procedure GetSelected(Idx: Integer; out AValue: OleVariant; out AResourceID: OleVariant); safecall;
    procedure ClearSelected; safecall;
    function  Get_RowHeight: Integer; safecall;
    procedure Set_RowHeight(Value: Integer); safecall;
    function  Get_CellWidth: Integer; safecall;
    procedure Set_CellWidth(Value: Integer); safecall;
    function  FindIntervalID(AResourceID: Integer; AValue: OleVariant): Integer; safecall;
    procedure GetIntervalData(AResourceID: Integer; AnIntervalID: Integer; 
                              out AStartValue: OleVariant; out AnEndValue: OleVariant; 
                              out AData: OleVariant; out AComment: OleVariant); safecall;
    function  Get_ScaleKind: Integer; safecall;
    procedure Set_ScaleKind(Value: Integer); safecall;
    procedure ScrollTo(AResourceID: Integer; AValue: OleVariant); safecall;
  end;

implementation

uses
  gdcOLEClassList, ComServ, obj_QueryList, IBTable, imglist, prp_Methods,
  {$IFDEF MESSAGE}
  obj_WrapperMessageClasses,
  {$ENDIF}
  gd_i_ScriptFactory, comctrls, contnrs, windows, IBSQL, AdPort, jclStrings,
  gsStreamHelper, dbclient, at_AddToSetting, gdcClasses_Interface;

type
  TCrackIBControlAndQueryService = class(TIBControlAndQueryService);
  TCrackIBControlService = class(TIBControlService);
  TCrackIBCustomService = class(TIBCustomService);
  TCrackgsCustomIBGrid = class(TgsCustomIBGrid);
  TCrackGdcUserBaseDocument = class(TgdcUserBaseDocument);
  TCrackGDCDocument = class(TgdcDocument);
  TCrackGDCBase = class(TgdcBase);
  TCrackCustomDBGrid = class(TCustomDBGrid);
  TCrackTBCustomDockableWindow = class(TTBCustomDockableWindow);
  TCrackCustomToolbar = class(TTBCustomToolbar);
  TCrackCreateableForm = class(TCreateableForm);
  TCrackGsCustomDBGrid = class(TgsCustomDBGrid);
  TCrackGdc_dlgG = class(Tgdc_dlgG);
  TCrackGdc_frmG = class(Tgdc_frmG);
  TCrackgsComboBoxAttrSet = class(TgsComboBoxAttrSet);

{ TwrpCustomDBGrid }

function TwrpCustomDBGrid.Get_FieldCount: Integer;
begin
  Result := GetCustomDBGrid.FieldCount;
end;

function TwrpCustomDBGrid.Get_SelectedIndex: Integer;
begin
  Result := GetCustomDBGrid.SelectedIndex;
end;

function TwrpCustomDBGrid.GetCustomDBGrid: TCustomDBGrid;
begin
  Result := GetObject as TCustomDBGrid;
end;

procedure TwrpCustomDBGrid.Set_SelectedIndex(Value: Integer);
begin
  GetCustomDBGrid.SelectedIndex := Value;
end;

function TwrpCustomDBGrid.ValidFieldIndex(FieldIndex: Integer): WordBool;
begin
  Result := GetCustomDBGrid.ValidFieldIndex(FieldIndex);
end;

function TwrpCustomDBGrid.Get_IndicatorOffset: Smallint;
begin
  Result := TCrackCustomDBGrid(GetCustomDBGrid).IndicatorOffset;
end;

function TwrpCustomDBGrid.Get_LayoutLock: Smallint;
begin
  Result := TCrackCustomDBGrid(GetCustomDBGrid).LayoutLock;
end;

function TwrpCustomDBGrid.Get_ReadOnly: WordBool;
begin
  Result := TCrackCustomDBGrid(GetCustomDBGrid).ReadOnly;
end;

function TwrpCustomDBGrid.Get_TitleFont: IFontDisp;
begin
  SetOleFont(TCrackCustomDBGrid(GetCustomDBGrid).TitleFont, Result);
end;

procedure TwrpCustomDBGrid.Set_ReadOnly(Value: WordBool);
begin
  TCrackCustomDBGrid(GetCustomDBGrid).ReadOnly := Value;
end;

procedure TwrpCustomDBGrid.Set_TitleFont(const Value: IFontDisp);
begin
  SetOleFont(TCrackCustomDBGrid(GetCustomDBGrid).TitleFont, Value);
end;

function TwrpCustomDBGrid.Get_SelectedField: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(TCrackCustomDBGrid(GetCustomDBGrid).SelectedField) as IgsFieldComponent;
end;

procedure TwrpCustomDBGrid.Set_SelectedField(
  const Value: IgsFieldComponent);
begin
  TCrackCustomDBGrid(GetCustomDBGrid).SelectedField :=
    InterfaceToObject(Value) as TField;

end;

function TwrpCustomDBGrid.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetCustomDBGrid.DataSource) as IgsDataSource;
end;

function TwrpCustomDBGrid.Get_Fields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetCustomDBGrid.Fields[Index]) as IgsFieldComponent;
end;

procedure TwrpCustomDBGrid.Set_DataSource(const Value: IgsDataSource);
begin
  GetCustomDBGrid.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpCustomDBGrid.ExecuteAction(const Action: IgsBasicAction);
begin
  GetCustomDBGrid.ExecuteAction(InterfaceToObject(Action) as TBasicAction)
end;

procedure TwrpCustomDBGrid.ShowPopupEditor(const Column: IgsColumn; X,
  Y: Integer);
begin
  GetCustomDBGrid.ShowPopupEditor(InterfaceToObject(Column) as TColumn, X, Y);
end;

function TwrpCustomDBGrid.Get_Columns: IgsDBGridColumns;
var
  LColumns: TDBGridColumns;
begin
  LColumns := TCrackCustomDBGrid(GetCustomDBGrid).Columns;
  if LColumns.InheritsFrom(TgsColumns) then
    Result :=  GetGdcOLEObject(TCrackCustomDBGrid(GetCustomDBGrid).Columns) as IgsGsColumns
  else
    Result :=  GetGdcOLEObject(TCrackCustomDBGrid(GetCustomDBGrid).Columns) as IgsDBGridColumns;
end;

procedure TwrpCustomDBGrid.Set_Columns(const Value: IgsDBGridColumns);
begin
  TCrackCustomDBGrid(GetCustomDBGrid).Columns := InterfaceToObject(Value) as TDBGridColumns;
end;

function TwrpCustomDBGrid.Get_SelectedRows: IgsBookmarkList;
begin
  Result :=
    GetGdcOLEObject(TCrackCustomDBGrid(GetCustomDBGrid).SelectedRows) as IgsBookmarkList;
end;

function TwrpCustomDBGrid.Get_Options_: WideString;
begin
  Result := ' ';
  with TCrackCustomDBGrid(GetCustomDBGrid) do
  begin
    if dgEditing in Options then
      Result := Result + 'dgEditing ';
    if dgAlwaysShowEditor in Options then
      Result := Result + 'dgAlwaysShowEditor ';
    if dgTitles in Options then
      Result := Result + 'dgTitles ';
    if dgIndicator in Options then
      Result := Result + 'dgIndicator ';
    if dgColumnResize in Options then
      Result := Result + 'dgColumnResize ';
    if dgColLines in Options then
      Result := Result + 'dgColLines ';
    if dgRowLines in Options then
      Result := Result + 'dgRowLines ';
    if dgTabs in Options then
      Result := Result + 'dgTabs ';
    if dgRowSelect in Options then
      Result := Result + 'dgRowSelect ';
    if dgAlwaysShowSelection in Options then
      Result := Result + 'dgAlwaysShowSelection ';
    if dgConfirmDelete in Options then
      Result := Result + 'dgConfirmDelete ';
    if dgCancelOnExit in Options then
      Result := Result + 'dgCancelOnExit ';
    if dgMultiSelect in Options then
      Result := Result + 'dgMultiSelect ';
  end;
end;

procedure TwrpCustomDBGrid.Set_Options_(const Value: WideString);
var
  Options: TDBGridOptions;
begin
  Options := [];
  if Pos('EDITING', AnsiUppercase(Value)) > 0 then
    include(Options, DGEDITING);
  if Pos('ALWAYSSHOWEDITOR', AnsiUppercase(Value)) > 0 then
    include(Options, DGALWAYSSHOWEDITOR);
  if Pos('TITLES', AnsiUppercase(Value)) > 0 then
    include(Options, DGTITLES);
  if Pos('INDICATOR', AnsiUppercase(Value)) > 0 then
    include(Options, DGINDICATOR);
  if Pos('COLUMNRESIZE', AnsiUppercase(Value)) > 0 then
    include(Options, DGCOLUMNRESIZE);
  if Pos('COLLINES', AnsiUppercase(Value)) > 0 then
    include(Options, DGCOLLINES);
  if Pos('ROWLINES', AnsiUppercase(Value)) > 0 then
    include(Options, DGROWLINES);
  if Pos('TABS', AnsiUppercase(Value)) > 0 then
    include(Options, DGTABS);
  if Pos('ROWSELECT', AnsiUppercase(Value)) > 0 then
    include(Options, DGROWSELECT);
  if Pos('ALWAYSSHOWSELECTION', AnsiUppercase(Value)) > 0 then
    include(Options, DGALWAYSSHOWSELECTION);
  if Pos('CONFIRMDELETE', AnsiUppercase(Value)) > 0 then
    include(Options, DGCONFIRMDELETE);
  if Pos('CANCELONEXIT', AnsiUppercase(Value)) > 0 then
    include(Options, DGCANCELONEXIT);
  if Pos('MULTISELECT', AnsiUppercase(Value)) > 0 then
    include(Options, DGMULTISELECT);
  TCrackCustomDBGrid(GetCustomDBGrid).Options := Options;
end;



procedure TwrpCustomDBGrid.DefaultDrawColumnCell(X1, Y1, X2, Y2,
  DataCol: Integer; const Column: IgsColumn;
  const State: WideString);
var
  R: TRect;
  S: TGridDrawState;
begin
  R.Left := X1;
  R.Top := Y1;
  R.Right := X2;
  R.Bottom := Y2;
  S := [];
  if Pos('GDSELECTED', AnsiUppercase(State)) > 0 then
    include(S, gdSelected);
  if Pos('GDFOCUSED', AnsiUppercase(State)) > 0 then
    include(S, gdFocused);
  if Pos('GDFIXED', AnsiUppercase(State)) > 0 then
    include(S, gdFixed);

  GetCustomDBGrid.DefaultDrawColumnCell(R, DataCol, InterfaceToObject(Column) as TColumn, S)

end;

{ TwrpgsCustomDBGrid }

function TwrpgsCustomDBGrid.Get_FormName: WideString;
begin
  Result := GetgsCustomDBGrid.FormName;
end;

procedure TwrpgsCustomDBGrid.AddCheck;
begin
  GetgsCustomDBGrid.AddCheck;
end;


function TwrpgsCustomDBGrid.GetgsCustomDBGrid: TgsCustomDBGrid;
begin
  Result := GetObject as TgsCustomDBGrid;
end;

procedure TwrpgsCustomDBGrid.ValidateColumns;
begin
  GetgsCustomDBGrid.ValidateColumns;
end;

function TwrpgsCustomDBGrid.Get_DontLoadSettings: WordBool;
begin
  Result := GetgsCustomDBGrid.DontLoadSettings;
end;

function TwrpgsCustomDBGrid.Get_GDObject: IgsGDCBase;
begin
  {$IFDEF GEDEMIN}
  Result := GetGdcOLEObject(GetgsCustomDBGrid.GDObject) as IgsGDCBase;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TwrpgsCustomDBGrid.Get_SettingsModified: WordBool;
begin
  Result := GetgsCustomDBGrid.SettingsModified;
end;

procedure TwrpgsCustomDBGrid.Set_DontLoadSettings(Value: WordBool);
begin
  GetgsCustomDBGrid.DontLoadSettings := Value;
end;

procedure TwrpgsCustomDBGrid.AfterConstruct;
begin
  GetgsCustomDBGrid.AfterConstruction;
end;

procedure TwrpgsCustomDBGrid.PrepareMaster(const AMaster: IgsForm);
begin
  GetgsCustomDBGrid.PrepareMaster(InterfaceToObject(AMaster) as TForm);
end;

procedure TwrpgsCustomDBGrid.SetupGrid(const AMaster: IgsForm;
  UpdateGrid: WordBool);
begin
  GetgsCustomDBGrid.SetupGrid(InterfaceToObject(AMaster) as TForm, UpdateGrid);
end;

function TwrpgsCustomDBGrid.Get_CheckBox: IgsGridCheckBox;
begin
  Result := GetGdcOLEObject(TCrackGsCustomDBGrid(GetgsCustomDBGrid).CheckBox) as IgsGridCheckBox;
end;

procedure TwrpgsCustomDBGrid.Set_CheckBox(const Value: IgsGridCheckBox);
begin
  TCrackGsCustomDBGrid(GetgsCustomDBGrid).CheckBox :=
    InterfaceToObject(Value) as TGridCheckBox;
end;

function TwrpgsCustomDBGrid.ColumnByField(
  const Field: IgsFieldComponent): IgsColumn;
begin
  Result := GetGdcOLEObject(GetgsCustomDBGrid.ColumnByField(InterfaceToObject(Field) as TField)) as IgsColumn;
end;

procedure TwrpgsCustomDBGrid.GridCoordFromMouse(out X, Y: OleVariant);
var
  LCoord: TGridCoord;
begin
  LCoord := GetgsCustomDBGrid.GridCoordFromMouse;
  X := LCoord.X;
  Y := LCoord.Y;
end;

procedure TwrpgsCustomDBGrid.LoadFromStream(const Stream: IgsStream);
begin
  GetgsCustomDBGrid.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpgsCustomDBGrid.Read(const Reader: IgsReader);
begin
  GetgsCustomDBGrid.Read(InterfaceToObject(Reader) as TReader);
end;

procedure TwrpgsCustomDBGrid.SaveToStream(const Stream: IgsStream);
begin
  GetgsCustomDBGrid.SaveToStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpgsCustomDBGrid.Write(const Writer: IgsWriter);
begin
  GetgsCustomDBGrid.Write(InterfaceToObject(Writer) as TWriter);
end;

function TwrpgsCustomDBGrid.Get_GroupFieldName: WideString;
begin
  Result := GetgsCustomDBGrid.GroupFieldName;
end;

procedure TwrpgsCustomDBGrid.Set_GroupFieldName(const Value: WideString);
begin
  GetgsCustomDBGrid.GroupFieldName := Value;
end;

procedure TwrpgsCustomDBGrid.ResizeColumns;
begin
  GetgsCustomDBGrid.ResizeColumns;
end;

{ TwrpGsCustomIBGrid }

function TwrpGsCustomIBGrid.GetCustomIBGrid: TgsCustomIBGrid;
begin
  Result := GetObject as TgsCustomIBGrid;
end;

function TwrpGsCustomIBGrid.Get_Aliases: IgsFieldAliases;
begin
  Result := GetGdcOLEObject(TCrackgsCustomIBGrid(GetCustomIBGrid).Aliases)
    as IgsFieldAliases;
end;

function TwrpGsCustomIBGrid.Get_ColumnEditors: IgsIBColumnEditors;
begin
  Result := GetGdcOLEObject(TCrackgsCustomIBGrid(GetCustomIBGrid).ColumnEditors)
    as IgsIBColumnEditors;
end;


procedure TwrpGsCustomIBGrid.Set_Aliases(const Value: IgsFieldAliases);
begin
  TCrackgsCustomIBGrid(GetCustomIBGrid).Aliases :=
    InterfaceToObject(Value) as TFieldAliases;
end;

procedure TwrpGsCustomIBGrid.Set_ColumnEditors(
  const Value: IgsIBColumnEditors);
begin
  TCrackgsCustomIBGrid(GetCustomIBGrid).ColumnEditors :=
    InterfaceToObject(Value) as TgsIBColumnEditors;
end;


{ TwrpGsIBGrid }

function TwrpGsIBGrid.Get_ExpandsActive: WordBool;
begin
  Result := GetIBGrid.ExpandsActive;
end;

function TwrpGsIBGrid.Get_ExpandsSeparate: WordBool;
begin
  Result := GetIBGrid.ExpandsSeparate;
end;

function TwrpGsIBGrid.Get_FinishDrawing: WordBool;
begin
  Result := GetIBGrid.FinishDrawing;
end;

function TwrpGsIBGrid.Get_MinColWidth: Integer;
begin
  Result := GetIBGrid.MinColWidth;
end;

function TwrpGsIBGrid.Get_RefreshType: TgsRefreshType;
begin
  Result := TgsRefreshType(GetIBGrid.RefreshType);
end;

function TwrpGsIBGrid.Get_RememberPosition: WordBool;
begin
  Result := GetIBGrid.RememberPosition;
end;

function TwrpGsIBGrid.Get_SaveSettings: WordBool;
begin
  Result := GetIBGrid.SaveSettings;
end;

function TwrpGsIBGrid.Get_ScaleColumns: WordBool;
begin
  Result := GetIBGrid.ScaleColumns;
end;

function TwrpGsIBGrid.Get_SelectedColor: Integer;
begin
  Result := TColor(GetIBGrid.SelectedColor);
end;

function TwrpGsIBGrid.Get_SelectedFont: IFontDisp;
begin
  GetOleFont(GetIBGrid.SelectedFont, Result);
end;

function TwrpGsIBGrid.Get_Striped: WordBool;
begin
  Result := GetIBGrid.Striped;
end;

function TwrpGsIBGrid.Get_StripeEven: Integer;
begin
  Result := TColor(GetIBGrid.StripeEven);
end;

function TwrpGsIBGrid.Get_StripeOdd: Integer;
begin
  Result := TColor(GetIBGrid.StripeOdd);
end;

function TwrpGsIBGrid.Get_TableColor: Integer;
begin
  Result := TColor(GetIBGrid.TableColor);
end;

function TwrpGsIBGrid.Get_TableFont: IFontDisp;
begin
  GetOleFont(GetIBGrid.TableFont, Result);
end;

function TwrpGsIBGrid.Get_TitleColor: Integer;
begin
  Result := TColor(GetIBGrid.TitleColor);
end;

function TwrpGsIBGrid.GetIBGrid: TgsIBGrid;
begin
  Result := GetObject as TgsIBGrid;
end;

procedure TwrpGsIBGrid.Set_ExpandsActive(Value: WordBool);
begin
  GetIBGrid.ExpandsActive := Value;
end;

procedure TwrpGsIBGrid.Set_ExpandsSeparate(Value: WordBool);
begin
  GetIBGrid.ExpandsSeparate := Value;
end;

procedure TwrpGsIBGrid.Set_FinishDrawing(Value: WordBool);
begin
  GetIBGrid.FinishDrawing := Value;
end;

procedure TwrpGsIBGrid.Set_MinColWidth(Value: Integer);
begin
  GetIBGrid.MinColWidth := Value;
end;

procedure TwrpGsIBGrid.Set_RefreshType(Value: TgsRefreshType);
begin
  GetIBGrid.RefreshType := TRefreshType(Value);
end;

procedure TwrpGsIBGrid.Set_RememberPosition(Value: WordBool);
begin
  GetIBGrid.RememberPosition := Value;
end;

procedure TwrpGsIBGrid.Set_SaveSettings(Value: WordBool);
begin
  GetIBGrid.SaveSettings := Value;
end;

procedure TwrpGsIBGrid.Set_ScaleColumns(Value: WordBool);
begin
  GetIBGrid.ScaleColumns := Value;
end;

procedure TwrpGsIBGrid.Set_SelectedColor(Value: Integer);
begin
  GetIBGrid.SelectedColor := TColor(Value);
end;

procedure TwrpGsIBGrid.Set_SelectedFont(const Value: IFontDisp);
begin
  SetOleFont(GetIBGrid.SelectedFont, Value);
end;

procedure TwrpGsIBGrid.Set_Striped(Value: WordBool);
begin
  GetIBGrid.Striped := Value;
end;

procedure TwrpGsIBGrid.Set_StripeEven(Value: Integer);
begin
  GetIBGrid.StripeEven := TColor(Value);
end;

procedure TwrpGsIBGrid.Set_StripeOdd(Value: Integer);
begin
  GetIBGrid.StripeOdd := TColor(Value);
end;

procedure TwrpGsIBGrid.Set_TableColor(Value: Integer);
begin
  GetIBGrid.TableColor := TColor(Value);
end;

procedure TwrpGsIBGrid.Set_TableFont(const Value: IFontDisp);
begin
  SetOleFont(GetIBGrid.TableFont, Value);
end;

procedure TwrpGsIBGrid.Set_TitleColor(Value: Integer);
begin
  GetIBGrid.TitleColor := TColor(Value);
end;


function TwrpGsIBGrid.Get_InternalMenuKind: TgsInternalMenuKind;
begin
  Result := TgsInternalMenuKind(GetIBGrid.InternalMenuKind);
end;

procedure TwrpGsIBGrid.Set_InternalMenuKind(Value: TgsInternalMenuKind);
begin
  GetIBGrid.InternalMenuKind := TInternalMenuKind(Value);
end;

function TwrpGsIBGrid.Get_Expands: IgsColumnExpands;
begin
  Result := GetGdcOLEObject(GetIBGrid.Expands) as IgsColumnExpands;
end;

procedure TwrpGsIBGrid.Set_Expands(const Value: IgsColumnExpands);
begin
  GetIBGrid.Expands := InterfaceToObject(Value) as TColumnExpands;
end;

function TwrpGsIBGrid.Get_ToolBar: IgsToolBar;
begin
  Result := GetGdcOLEObject(GetIBGrid.ToolBar) as IgsToolBar;
end;

procedure TwrpGsIBGrid.Set_ToolBar(const Value: IgsToolBar);
begin
  GetIBGrid.ToolBar := InterfaceToObject(Value) as TToolBar;
end;

function TwrpGsIBGrid.Get_TitlesExpanding: WordBool;
begin
  Result := GetIBGrid.TitlesExpanding;
end;

procedure TwrpGsIBGrid.Set_TitlesExpanding(Value: WordBool);
begin
  GetIBGrid.TitlesExpanding := Value;
end;

{ TwrpIBLookupComboBoxX }

function TwrpIBLookupComboBoxX.Get_CheckUserRights: WordBool;
begin
  Result := GetIBLookupComboBoxX.CheckUserRights;
end;

function TwrpIBLookupComboBoxX.Get_Condition: WideString;
begin
  Result := GetIBLookupComboBoxX.Condition;
end;

function TwrpIBLookupComboBoxX.Get_CurrentKey: WideString;
begin
  Result := GetIBLookupComboBoxX.CurrentKey;
end;

function TwrpIBLookupComboBoxX.Get_CurrentKeyInt: Integer;
begin
  Result := GetIBLookupComboBoxX.CurrentKeyInt;
end;

function TwrpIBLookupComboBoxX.Get_DataField: WideString;
begin
  Result := GetIBLookupComboBoxX.DataField;
end;

function TwrpIBLookupComboBoxX.Get_DropDownDialogWidth: Integer;
begin
  Result := GetIBLookupComboBoxX.DropDownDialogWidth;
end;

function TwrpIBLookupComboBoxX.Get_Fields: WideString;
begin
  Result := GetIBLookupComboBoxX.Fields;
end;

function TwrpIBLookupComboBoxX.Get_gdClassName: WideString;
begin
  Result := GetIBLookupComboBoxX.gdClassName;
end;

function TwrpIBLookupComboBoxX.Get_KeyField: WideString;
begin
  Result := GetIBLookupComboBoxX.KeyField;
end;

function TwrpIBLookupComboBoxX.Get_ListField: WideString;
begin
  Result := GetIBLookupComboBoxX.ListField;
end;

function TwrpIBLookupComboBoxX.Get_ListTable: WideString;
begin
  Result := GetIBLookupComboBoxX.ListTable;
end;

function TwrpIBLookupComboBoxX.Get_SortOrder: TgsgsSortOrder;
begin
  Result := TgsgsSortOrder(GetIBLookupComboBoxX.SortOrder);
end;

function TwrpIBLookupComboBoxX.Get_SortField: WideString;
begin
  Result := GetIBLookupComboBoxX.SortField;
end;

function TwrpIBLookupComboBoxX.Get_SubType: WideString;
begin
  Result := GetIBLookupComboBoxX.SubType;
end;

function TwrpIBLookupComboBoxX.Get_ValidObject: WordBool;
begin
  Result := GetIBLookupComboBoxX.ValidObject;
end;

function TwrpIBLookupComboBoxX.GetIBLookupComboBoxX: TgsIBLookupComboBox;
begin
  Result := GetObject as TgsIBLookupComboBox;
end;

procedure TwrpIBLookupComboBoxX.CreateNew;
begin
  GetIBLookupComboBoxX.CreateNew(gdcFullClass(nil, ''));
end;

procedure TwrpIBLookupComboBoxX.Delete;
begin
  GetIBLookupComboBoxX.Delete;
end;

procedure TwrpIBLookupComboBoxX.DoLookup(Exact: WordBool);
begin
  if Exact then
    GetIBLookupComboBoxX.DoLookup(stExact)
  else
    GetIBLookupComboBoxX.DoLookup(stLike);
end;

procedure TwrpIBLookupComboBoxX.Edit;
begin
  GetIBLookupComboBoxX.Edit;
end;

procedure TwrpIBLookupComboBoxX.ObjectProperties;
begin
  GetIBLookupComboBoxX.ObjectProperties;
end;

procedure TwrpIBLookupComboBoxX.Reduce;
begin
  GetIBLookupComboBoxX.Reduce;
end;

procedure TwrpIBLookupComboBoxX.Set_CheckUserRights(Value: WordBool);
begin
  GetIBLookupComboBoxX.CheckUserRights := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_Condition(const Value: WideString);
begin
  GetIBLookupComboBoxX.Condition := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_CurrentKey(const Value: WideString);
begin
  GetIBLookupComboBoxX.CurrentKey := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_CurrentKeyInt(Value: Integer);
begin
  GetIBLookupComboBoxX.CurrentKeyInt := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_DataField(const Value: WideString);
begin
  GetIBLookupComboBoxX.DataField := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_DropDownDialogWidth(Value: Integer);
begin
  GetIBLookupComboBoxX.DropDownDialogWidth := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_Fields(const Value: WideString);
begin
  GetIBLookupComboBoxX.Fields := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_gdClassName(const Value: WideString);
begin
  GetIBLookupComboBoxX.gdClassName := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_KeyField(const Value: WideString);
begin
  GetIBLookupComboBoxX.KeyField := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_ListField(const Value: WideString);
begin
  GetIBLookupComboBoxX.ListField := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_ListTable(const Value: WideString);
begin
  GetIBLookupComboBoxX.ListTable := String(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_SortOrder(Value: TgsgsSortOrder);
begin
  GetIBLookupComboBoxX.SortOrder := TgsSortOrder(Value);
end;

procedure TwrpIBLookupComboBoxX.Set_SortField(const Value: WideString);
begin
  GetIBLookupComboBoxX.SortField := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_SubType(const Value: WideString);
begin
  GetIBLookupComboBoxX.SubType := String(Value);
end;

procedure TwrpIBLookupComboBoxX.ViewForm;
begin
  GetIBLookupComboBoxX.ViewForm;
end;

function TwrpIBLookupComboBoxX.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetIBLookupComboBoxX.Transaction) as IgsIBTransaction;
end;

procedure TwrpIBLookupComboBoxX.Set_Transaction(
  const Value: IgsIBTransaction);
begin
  GetIBLookupComboBoxX.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

function TwrpIBLookupComboBoxX.Get__Field: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetIBLookupComboBoxX._Field) as IgsFieldComponent;
end;

function TwrpIBLookupComboBoxX.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetIBLookupComboBoxX.Database) as IgsIBDatabase;
end;

function TwrpIBLookupComboBoxX.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetIBLookupComboBoxX.DataSource) as IgsDataSource;
end;

function TwrpIBLookupComboBoxX.Get_gdClass: WideString;
begin
  Result := GetIBLookupComboBoxX.gdClass.ClassName;
end;

function TwrpIBLookupComboBoxX.Get_ReadOnly: WordBool;
begin
  Result := GetIBLookupComboBoxX.ReadOnly;
end;

procedure TwrpIBLookupComboBoxX.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBLookupComboBoxX.Database := InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpIBLookupComboBoxX.Set_DataSource(const Value: IgsDataSource);
begin
  GetIBLookupComboBoxX.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpIBLookupComboBoxX.Set_ReadOnly(Value: WordBool);
begin
  GetIBLookupComboBoxX.ReadOnly := Value;
end;

procedure TwrpIBLookupComboBoxX.LoadFromStream(const S: IgsStream);
begin
  GetIBLookupComboBoxX.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpIBLookupComboBoxX.SaveToStream(const S: IgsStream);
begin
  GetIBLookupComboBoxX.SaveToStream(InterfaceToObject(S) as TStream);
end;

function TwrpIBLookupComboBoxX.Get_Params: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBLookupComboBoxX.Params);
end;

function TwrpIBLookupComboBoxX.Get_Distinct: WordBool;
begin
  Result := GetIBLookupComboBoxX.Distinct;
end;

function TwrpIBLookupComboBoxX.Get_FullSearchOnExit: WordBool;
begin
  Result := GetIBLookupComboBoxX.FullSearchOnExit;
end;

function  TwrpIBLookupComboBoxX.Get_ShowDisabled: WordBool;
begin
  Result := GetIBLookupComboBoxX.ShowDisabled;
end;

procedure TwrpIBLookupComboBoxX.Set_Distinct(Value: WordBool);
begin
  GetIBLookupComboBoxX.Distinct := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_FullSearchOnExit(Value: WordBool);
begin
  GetIBLookupComboBoxX.FullSearchOnExit := Value;
end;

procedure TwrpIBLookupComboBoxX.Set_ShowDisabled(Value: WordBool);
begin
  GetIBLookupComboBoxX.ShowDisabled := Value;
end;

{ TwrpXDateEdit }

function TwrpXDateEdit.GetXDateEdit: TxDateEdit;
begin
  Result := GetObject as TxDateEdit;
end;

function TwrpXDateEdit.Get_AutoSize: WordBool;
begin
  Result := GetXDateEdit.AutoSize;
end;

function TwrpXDateEdit.Get_Color: Integer;
begin
  Result := Integer(GetXDateEdit.Color);
end;

function TwrpXDateEdit.Get_CurrentDateTimeAtStart: WordBool;
begin
  Result := GetXDateEdit.CurrentDateTimeAtStart;
end;

function TwrpXDateEdit.Get_Date: TDateTime;
begin
  Result := Double(GetXDateEdit.Date);
end;

function TwrpXDateEdit.Get_DateTime: TDateTime;
begin
  Result := GetXDateEdit.DateTime;
end;

function TwrpXDateEdit.Get_Day: Word;
begin
  Result := GetXDateEdit.Day;
end;

function TwrpXDateEdit.Get_EmptyAtStart: WordBool;
begin
  Result := GetXDateEdit.EmptyAtStart;
end;

function TwrpXDateEdit.Get_Hour: Word;
begin
  Result := GetXDateEdit.Hour;
end;

function TwrpXDateEdit.Get_Kind: TgsKind;
begin
  Result := TgsKind(GetXDateEdit.Kind);
end;

function TwrpXDateEdit.Get_Min: Word;
begin
  Result := GetXDateEdit.Min;
end;

function TwrpXDateEdit.Get_Month: Word;
begin
  Result := GetXDateEdit.Month;
end;

function TwrpXDateEdit.Get_Sec: Word;
begin
  Result := GetXDateEdit.Sec;
end;

function TwrpXDateEdit.Get_Time: TDateTime;
begin
  Result := Double(GetXDateEdit.Time);
end;

function TwrpXDateEdit.Get_Year: Word;
begin
  Result := GetXDateEdit.Year;
end;

function TwrpXDateEdit.GetLength: Word;
begin
  Result := GetXDateEdit.GetLength;
end;

procedure TwrpXDateEdit.GetDateInStr(aDate: TDateTime; var sYear, sMonth,
  sDay: OleVariant);
var
  FsYear, FsMonth, FsDay: String;
begin
  FsYear := sYear;
  FsMonth := sMonth;
  FsDay := sDay;
  GetXDateEdit.GetDateInStr(aDate, FsYear, FsMonth, FsDay);
  sYear := FsYear;
  sMonth := FsMonth;
  sDay := FsDay;
end;

procedure TwrpXDateEdit.GetTimeInStr(aTime: TDateTime; var sHour, sMin,
  sSec: OleVariant);
var
  FsHour, FsMin, FsSec: String;
begin
  FsHour := sHour;
  FsMin := sMin;
  FsSec := sSec;
  GetXDateEdit.GetTimeInStr(aTime, FsHour, FsMin, FsSec);
  sHour := FsHour;
  sMin := FsMin;
  sSec := FsSec;
end;

procedure TwrpXDateEdit.Set_AutoSize(Value: WordBool);
begin
  GetXDateEdit.AutoSize := Value;
end;

procedure TwrpXDateEdit.Set_Color(Value: Integer);
begin
  GetXDateEdit.Color := TColor(Value);
end;

procedure TwrpXDateEdit.Set_CurrentDateTimeAtStart(Value: WordBool);
begin
  GetXDateEdit.CurrentDateTimeAtStart := Value;
end;

procedure TwrpXDateEdit.Set_Date(Value: TDateTime);
begin
  GetXDateEdit.Date := TDate(Value);
end;

procedure TwrpXDateEdit.Set_DateTime(Value: TDateTime);
begin
  GetXDateEdit.DateTime := Value;
end;

procedure TwrpXDateEdit.Set_Day(Value: Word);
begin
  GetXDateEdit.Day := Value;
end;

procedure TwrpXDateEdit.Set_EmptyAtStart(Value: WordBool);
begin
  GetXDateEdit.EmptyAtStart := Value;
end;

procedure TwrpXDateEdit.Set_Hour(Value: Word);
begin
  GetXDateEdit.Hour := Value;
end;

procedure TwrpXDateEdit.Set_Kind(Value: TgsKind);
begin
  GetXDateEdit.Kind := TKind(Value);
end;

procedure TwrpXDateEdit.Set_Min(Value: Word);
begin
  GetXDateEdit.Min := Value;
end;

procedure TwrpXDateEdit.Set_Month(Value: Word);
begin
  GetXDateEdit.Month := Value;
end;

procedure TwrpXDateEdit.Set_Sec(Value: Word);
begin
  GetXDateEdit.Sec := Value;
end;

procedure TwrpXDateEdit.Set_Time(Value: TDateTime);
begin
  GetXDateEdit.Time := TTime(Value);
end;

procedure TwrpXDateEdit.Set_Year(Value: Word);
begin
  GetXDateEdit.Year := Value;
end;

function TwrpXDateEdit.DaysCount(nMonth, nYear: Word): Integer;
begin
  Result := GetXDateEdit.DaysCount(nMonth, nYear);
end;

{ TwrpXDateDBEdit }

procedure TwrpXDateDBEdit.Change;
begin
  GetXDateDBEdit.Change;
end;

function TwrpXDateDBEdit.Get_DataField: WideString;
begin
  Result := GetXDateDBEdit.DataField;
end;

function TwrpXDateDBEdit.GetXDateDBEdit: TxDateDBEdit;
begin
  Result := GetObject as TxDateDBEdit;
end;

procedure TwrpXDateDBEdit.Set_DataField(const Value: WideString);
begin
  GetXDateDBEdit.DataField := String(Value);
end;

function TwrpXDateDBEdit.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetXDateDBEdit.DataSource) as IgsDataSource;
end;

function TwrpXDateDBEdit.Get_Field: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetXDateDBEdit.Field) as IgsFieldComponent;
end;

procedure TwrpXDateDBEdit.Set_DataSource(const Value: IgsDataSource);
begin
  GetXDateDBEdit.DataSource := InterfaceToObject(Value) as TDataSource;
end;

{ TwrpGsSQLFilter }

function TwrpGsSQLFilter.AddFilter(out AnFilterKey: OleVariant): WordBool;
var
  fk: Integer;
begin
  Result := GetSQLFilter.AddFilter(fk);
  AnFilterKey := fk;
end;

procedure TwrpGsSQLFilter.ClearConditions;
begin
  GetSQLFilter.ClearConditions;
end;

procedure TwrpGsSQLFilter.ClearOrdersBy;
begin
  GetSQLFilter.ClearOrdersBy;
end;

function TwrpGsSQLFilter.CreateSQL: WordBool;
begin
  Result := GetSQLFilter.CreateSQL;
end;

procedure TwrpGsSQLFilter.DeleteCondition(AnIndex: Integer);
begin
  GetSQLFilter.DeleteCondition(AnIndex);
end;

function TwrpGsSQLFilter.DeleteFilter: WordBool;
begin
  Result := GetSQLFilter.DeleteFilter;
end;

procedure TwrpGsSQLFilter.DeleteOrderBy(AnIndex: Integer);
begin
  GetSQLFilter.DeleteOrderBy(AnIndex);
end;

function TwrpGsSQLFilter.EditFilter(out AnFilterKey: OleVariant): WordBool;
var
  fk: Integer;
begin
  Result := GetSQLFilter.EditFilter(fk);
  AnFilterKey := fk;
end;

function TwrpGsSQLFilter.Get_ConditionCount: Integer;
begin
  Result := GetSQLFilter.ConditionCount;
end;

function TwrpGsSQLFilter.Get_CurrentFilter: Integer;
begin
  Result := GetSQLFilter.CurrentFilter;
end;

function TwrpGsSQLFilter.Get_FilterComment: WideString;
begin
  Result := GetSQLFilter.FilterComment;
end;

function TwrpGsSQLFilter.Get_FilteredSQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.FilteredSQL);
end;

function TwrpGsSQLFilter.Get_FilterName: WideString;
begin
  Result := GetSQLFilter.FilterName;
end;

function TwrpGsSQLFilter.Get_FilterSrting: WideString;
begin
  Result := GetSQLFilter.FilterString;
end;

function TwrpGsSQLFilter.Get_FromText: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.FromText);
end;

function TwrpGsSQLFilter.Get_LastExecutionTime: Double;
begin
  Result := GetSQLFilter.LastExecutionTime;
end;

function TwrpGsSQLFilter.Get_NoVisibleList: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.NoVisibleList);
end;

function TwrpGsSQLFilter.Get_OrderByCount: Integer;
begin
  Result := GetSQLFilter.OrderByCount;
end;

function TwrpGsSQLFilter.Get_OrderText: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.OrderText);
end;

function TwrpGsSQLFilter.Get_OtherText: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.OtherText);
end;

function TwrpGsSQLFilter.Get_SelectText: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.SelectText);
end;

function TwrpGsSQLFilter.Get_WhereText: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetSQLFilter.WhereText);
end;

function TwrpGsSQLFilter.GetSQLFilter: TgsSQLFilter;
begin
  Result := GetObject as TgsSQLFilter;
end;

procedure TwrpGsSQLFilter.SetQueryText(const AnSQLText: WideString);
begin
  GetSQLFilter.SetQueryText(String(AnSQLText));
end;

function TwrpGsSQLFilter.Get_Conditions(Index: Integer): IgsFilterCondition;
begin
  Result := GetGdcOLEObject(GetSQLFilter.Conditions[Index]) as IgsFilterCondition;
end;

procedure TwrpGsSQLFilter.Set_Conditions(Index: Integer;
  const Value: IgsFilterCondition);
begin
  GetSQLFilter.Conditions[Index] := InterfaceToObject(Value) as TFilterCondition;
end;

function TwrpGsSQLFilter.Get_OrdersBy(Index: Integer): IgsFilterOrderBy;
begin
  Result := GetGdcOLEObject(GetSQLFilter.OrdersBy[Index]) as IgsFilterOrderBy;
end;

procedure TwrpGsSQLFilter.Set_OrdersBy(Index: Integer;
  const Value: IgsFilterOrderBy);
begin
  GetSQLFilter.OrdersBy[Index] := InterfaceToObject(Value) as TFilterOrderBy;
end;

function TwrpGsSQLFilter.AddCondition(
  const FilterCondition: IgsFilterCondition): Integer;
begin
  Result := GetSQLFilter.AddCondition(InterfaceToObject(FilterCondition) as TFilterCondition);
end;

function TwrpGsSQLFilter.AddOrderBy(const OrderBy: IgsFilterOrderBy): Integer;
begin
  Result := GetSQLFilter.AddOrderBy(InterfaceToObject(OrderBy) as TFilterOrderBy);
end;

function TwrpGsSQLFilter.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetSQLFilter.Database) as IgsIBDatabase;
end;

function TwrpGsSQLFilter.Get_FilterData: IgsFilterData;
begin
  Result := GetGdcOLEObject(GetSQLFilter.FilterData) as IgsFilterData;
end;

function TwrpGsSQLFilter.Get_RequeryParams: WordBool;
begin
  Result := GetSQLFilter.RequeryParams;
end;

function TwrpGsSQLFilter.Get_TableList: IgsFltStringList;
begin
  Result := GetGdcOLEObject(GetSQLFilter.TableList) as  IgsFltStringList;
end;

procedure TwrpGsSQLFilter.ReadFromStream(const S: IgsStream);
begin
  GetSQLFilter.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsSQLFilter.Set_Database(const Value: IgsIBDatabase);
begin
  GetSQLFilter.Database := InterfaceToObject(Value) as TIbDatabase;
end;

procedure TwrpGsSQLFilter.Set_RequeryParams(Value: WordBool);
begin
  GetSQLFilter.RequeryParams := Value;
end;

procedure TwrpGsSQLFilter.Set_TableList(const Value: IgsFltStringList);
begin
  GetSQLFilter.TableList := InterfaceToObject(Value) as TfltStringList;
end;

procedure TwrpGsSQLFilter.WriteToStream(const S: IgsStream);
begin
  GetSQLFilter.WriteToStream(InterfaceToObject(S) as TStream);
end;

function TwrpGsSQLFilter.Get_FilterString: WideString;
begin
  Result := GetSQLFilter.FilterString;
end;

procedure TwrpGsSQLFilter.LoadFilter(FilterKey: Integer);
begin
  GetSQLFilter.LoadFilter(FilterKey);
end;

function TwrpGsSQLFilter.Get_ComponentKey: Integer;
begin
  Result := GetSQLFilter.ComponentKey;
end;

{ TwrpGsQueryFilter }

procedure TwrpGsQueryFilter.CreatePopupMenu;
begin
  GetQueryFilter.CreatePopupMenu;
end;

procedure TwrpGsQueryFilter.FilterQuery(SilentParam: OleVariant);
begin
  GetQueryFilter.FilterQuery(SilentParam);
end;

function TwrpGsQueryFilter.Get_RecordCount: Integer;
begin
  Result := GetQueryFilter.RecordCount;
end;

function TwrpGsQueryFilter.GetQueryFilter: TgsQueryFilter;
begin
  Result := GetObject as TgsQueryFilter;
end;

procedure TwrpGsQueryFilter.LoadLastFilter;
begin
  GetQueryFilter.LoadLastFilter;
end;

procedure TwrpGsQueryFilter.PopupMenu(x, y: Integer);
begin
  GetQueryFilter.PopupMenu(x, y);
end;

procedure TwrpGsQueryFilter.RevertQuery;
begin
  GetQueryFilter.RevertQuery;
end;

procedure TwrpGsQueryFilter.SaveLastFilter;
begin
  GetQueryFilter.SaveLastFilter;
end;

procedure TwrpGsQueryFilter.CreateFilterExecute;
begin
  GetQueryFilter.CreateFilterExecute;
end;

procedure TwrpGsQueryFilter.DeleteFilterExecute;
begin
  GetQueryFilter.DeleteFilterExecute;
end;

procedure TwrpGsQueryFilter.EditFilterExecute;
begin
  GetQueryFilter.EditFilterExecute;
end;

procedure TwrpGsQueryFilter.FilterBackExecute;
begin
  GetQueryFilter.FilterBackExecute;
end;

procedure TwrpGsQueryFilter.RefreshExecute;
begin
  GetQueryFilter.RefreshExecute;
end;

procedure TwrpGsQueryFilter.ShowRecordCountExecute;
begin
  GetQueryFilter.ShowRecordCountExecute;
end;

procedure TwrpGsQueryFilter.ViewFilterListExecute;
begin
  GetQueryFilter.ViewFilterListExecute;
end;

function TwrpGsQueryFilter.Get_IBDataSet: IgsIBCustomDataSet;
begin
  Result := GetGdcOLEObject(GetQueryFilter.IBDataSet) as IgsIBCustomDataSet;
end;

procedure TwrpGsQueryFilter.Set_IBDataSet(const Value: IgsIBCustomDataSet);
begin
  GetQueryFilter.IBDataSet := InterfaceToObject(Value) as TIBCustomDataSet;
end;

function TwrpGsQueryFilter.Get_LastQueriedParams: OleVariant;
begin
  Result := GetQueryFilter.LastQueriedParams;
end;

{ TwrpGsStorage }

procedure TwrpGsStorage.Clear;
begin
  GetStorage.Clear;
end;

function TwrpGsStorage.FolderExists(const APath: WideString): WordBool;
begin
  Result := GetStorage.FolderExists(APath);
end;

function TwrpGsStorage.Get_DataString: WideString;
begin
  Result := GetStorage.DataString;
end;

function TwrpGsStorage.Get_IsModified: WordBool;
begin
  Result := GetStorage.IsModified;
end;

function TwrpGsStorage.GetStorage: TgsStorage;
begin
  Result := GetObject as TgsStorage;
end;

procedure TwrpGsStorage.LoadFromDataBase;
begin
  (GetStorage as TgsIBStorage).LoadFromDataBase;
end;

procedure TwrpGsStorage.LoadFromFile(const AFileName: WideString;
  AFileFormat: OleVariant);
begin
  GetStorage.LoadFromFile(AFileName, AFileFormat);
end;

function TwrpGsStorage.ReadBoolean(const APath, AValue: WideString;
  Default: WordBool): WordBool;
begin
  Result := GetStorage.ReadBoolean(APath, AValue, Default);
end;

function TwrpGsStorage.ReadCurrency(const APath, AValue: WideString;
  Default: Currency): Currency;
begin
  Result := GetStorage.ReadCurrency(APath, AValue, Default);
end;

function TwrpGsStorage.ReadDateTime(const APath, AValue: WideString;
  Default: TDateTime): TDateTime;
begin
  Result := GetStorage.ReadDateTime(APath, AValue, Default);
end;

function TwrpGsStorage.ReadInteger(const APath, AValue: WideString;
  Default: Integer): Integer;
begin
  Result := GetStorage.ReadInteger(APath, AValue, Default);
end;

function TwrpGsStorage.ReadString(const APath, AValue,
  Default: WideString): WideString;
begin
  Result := GetStorage.ReadString(APath, AValue, Default);
end;

procedure TwrpGsStorage.SaveToDataBase;
begin
  (GetStorage as TgsIBStorage).SaveToDataBase;
end;

procedure TwrpGsStorage.SaveToFile(const AFileName: WideString;
  AFileFormat: OleVariant);
begin
  GetStorage.SaveToFile(AFileName, AFileFormat);
end;

procedure TwrpGsStorage.Set_DataString(const Value: WideString);
begin
  GetStorage.DataString := String(Value);
end;

function TwrpGsStorage.ValueExists(const APath, AValue: WideString): WordBool;
begin
  Result := GetStorage.ValueExists(APath, AValue);
end;

procedure TwrpGsStorage.WriteBoolean(const APath, AValueName: WideString;
  AValue: WordBool);
begin
  GetStorage.WriteBoolean(APath, AValueName,AValue);
end;

procedure TwrpGsStorage.WriteCurrency(const APath, AValueName: WideString;
  AValue: Currency);
begin
  GetStorage.WriteCurrency(APath, AValueName,AValue);
end;

procedure TwrpGsStorage.WriteDateTime(const APath, AValueName: WideString;
  AValue: TDateTime);
begin
  GetStorage.WriteDateTime(APath, AValueName,AValue);
end;

procedure TwrpGsStorage.WriteInteger(const APath, AValueName: WideString;
  AValue: Integer);
begin
  GetStorage.WriteInteger(APath, AValueName,AValue);
end;

procedure TwrpGsStorage.WriteString(const APath, AValueName,
  AValue: WideString);
begin
  GetStorage.WriteString(APath, AValueName,AValue);
end;

procedure TwrpGsStorage.LoadFromStream(const S: IgsStream);
begin
  GetStorage.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsStorage.SaveToStream(const S: IgsStream);
begin
  GetStorage.SaveToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsStorage.BuildTreeView(const N: IgsTreeNode);
begin
  GetStorage.BuildTreeView(InterfaceToObject(N) as TTreeNode);
end;

procedure TwrpGsStorage.CloseFolder(
  const gsStorageFolder: IgsGsStorageFolder; SyncWithDatabase: WordBool);
begin
  GetStorage.CloseFolder(InterfaceToObject(gsStorageFolder) as
    TgsStorageFolder, SyncWithDatabase);
end;

procedure TwrpGsStorage.LoadFromStream2(const S: IgsStringStream);
begin
  GetStorage.LoadFromStream2(InterfaceToObject(S) as TStringStream);
end;

function TwrpGsStorage.OpenFolder(const APath: WideString; CanCreate,
  SyncWithDatabase: WordBool): IgsGsStorageFolder;
begin
  Result := GetGdcOLEObject(GetStorage.OpenFolder(APath, CanCreate, SyncWithDatabase)) as IgsGsStorageFolder;
end;

function TwrpGsStorage.ReadStream(const APath, AValue: WideString;
  const S: IgsStream): WordBool;
begin
  Result := GetStorage.ReadStream(APath, AValue, InterfaceToObject(S) as TStream);
end;

procedure TwrpGsStorage.SaveToStream2(const S: IgsStringStream);
begin
  GetStorage.SaveToStream2(InterfaceToObject(S) as TStringStream);
end;

procedure TwrpGsStorage.WriteStream(const APath, AValueName: WideString;
  const AValue: IgsStream);
begin
  GetStorage.WriteStream(APath, AValueName, InterfaceToObject(AValue) as TStream);
end;

function TwrpGsStorage.Get_Name: WideString;
begin
  Result := GetStorage.Name;
end;

function TwrpGsStorage.BuildComponentPath(const C: IgsComponent;
  const Context: WideString): WideString;
begin
  Result := gsStorage_CompPath.BuildComponentPath(InterfaceToObject(C) as TComponent, Context);
end;

{ TwrpTBDock }

procedure TwrpTBDock.ArrangeToolbars;
begin
  GetTBDock.ArrangeToolbars;
end;

procedure TwrpTBDock.BeginUpdate;
begin
  GetTBDock.BeginUpdate;
end;

procedure TwrpTBDock.EndUpdate;
begin
  GetTBDock.EndUpdate;
end;

function TwrpTBDock.Get_AllowDrag: WordBool;
begin
  Result := GetTBDock.AllowDrag;
end;

function TwrpTBDock.Get_BackgroundOnToolbars: WordBool;
begin
  Result := GetTBDock.BackgroundOnToolbars;
end;

function TwrpTBDock.Get_CommitNewPositions: WordBool;
begin
  Result := GetTBDock.CommitNewPositions;
end;

function TwrpTBDock.Get_FixAlign: WordBool;
begin
  Result := GetTBDock.FixAlign;
end;

function TwrpTBDock.Get_LimitToOneRow: WordBool;
begin
  Result := GetTBDock.LimitToOneRow;
end;

function TwrpTBDock.Get_NonClientHeight: Integer;
begin
  Result :=  GetTBDock.NonClientHeight;
end;

function TwrpTBDock.Get_NonClientWidth: Integer;
begin
  Result := GetTBDock.NonClientWidth;
end;

function TwrpTBDock.Get_Position: TgsTBDockPosition;
begin
  Result := TgsTBDockPosition(GetTBDock.Position);
end;

function TwrpTBDock.Get_ToolbarCount: Integer;
begin
  Result := GetTBDock.ToolbarCount;
end;

function TwrpTBDock.GetCurrentRowSize(Row: Integer;
  var AFullSize: OleVariant): Integer;
var Temp: Boolean;
begin
  Temp := AFullSize;
  Result := GetTBDock.GetCurrentRowSize(Row, Temp);
  AFullSize := Temp;
end;

function TwrpTBDock.GetHighestRow(HighestEffective: WordBool): Integer;
begin
  Result := GetTBDock.GetHighestRow(HighestEffective);
end;

function TwrpTBDock.GetTBDock: TTBDock;
begin
  Result := GetObject as TTBDock;
end;

procedure TwrpTBDock.Set_AllowDrag(Value: WordBool);
begin
  GetTBDock.AllowDrag := Value;
end;

procedure TwrpTBDock.Set_BackgroundOnToolbars(Value: WordBool);
begin
  GetTBDock.BackgroundOnToolbars := Value;
end;

procedure TwrpTBDock.Set_CommitNewPositions(Value: WordBool);
begin
  GetTBDock.CommitNewPositions := Value;
end;

procedure TwrpTBDock.Set_FixAlign(Value: WordBool);
begin
  GetTBDock.FixAlign := Value;
end;

procedure TwrpTBDock.Set_LimitToOneRow(Value: WordBool);
begin
  GetTBDock.LimitToOneRow := Value;
end;

procedure TwrpTBDock.Set_Position(Value: TgsTBDockPosition);
begin
  GetTBDock.Position := TTBDockPosition(Value);
end;

function TwrpTBDock.Get_Background: IgsTBBasicBackground;
begin
  Result := GetGdcOLEObject(GetTBDock.Background) as IgsTBBasicBackground;
end;

function TwrpTBDock.Get_Toolbars(
  Index: Integer): IgsTBCustomDockableWindow;
begin
  Result := GetGdcOLEObject(GetTBDock.Toolbars[Index]) as IgsTBCustomDockableWindow;
end;

function TwrpTBDock.GetMinRowSize(Row: Integer;
  const ExcludeControl: IgsTBCustomDockableWindow): Integer;
begin
  Result := GetTBDock.GetMinRowSize(Row, InterfaceToObject(ExcludeControl) as TTBCustomDockableWindow);
end;

procedure TwrpTBDock.Set_Background(const Value: IgsTBBasicBackground);
begin
  GetTBDock.Background := InterfaceToObject(Value) as TTBBasicBackground;
end;

function TwrpTBDock.Get_BoundLines: WideString;
begin
  Result := ' ';
  if blTop in GetTBDock.BoundLines then
    Result := Result + 'blTop ';
  if blBottom in GetTBDock.BoundLines then
    Result := Result + 'blBottom ';
  if blLeft in GetTBDock.BoundLines then
    Result := Result + 'blLeft ';
  if blRight in GetTBDock.BoundLines then
    Result := Result + 'blRight ';
end;

procedure TwrpTBDock.Set_BoundLines(const Value: WideString);
var
  LBLines: TTBDockBoundLines;
begin
  LBLines := [];
  if Pos('BLTOP', AnsiUpperCase(Value)) > 0 then
    include(LBLines, BLTOP);
  if Pos('BLBOTTOM', AnsiUpperCase(Value)) > 0 then
    include(LBLines, BLBOTTOM);
  if Pos('BLLEFT', AnsiUpperCase(Value)) > 0 then
    include(LBLines, BLLEFT);
  if Pos('BLRIGHT', AnsiUpperCase(Value)) > 0 then
    include(LBLines, BLRIGHT);
  GetTBDock.BoundLines := LBLines;
end;

{ TwrpTBCustomDockableWindow }

procedure TwrpTBCustomDockableWindow.Arrange;
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).Arrange;
end;

procedure TwrpTBCustomDockableWindow.BeginMoving(InitX,
  InitY: Integer);
begin
  GetTBCustomDockableWindow.BeginMoving(InitX, InitY);
end;

procedure TwrpTBCustomDockableWindow.ChangeSize(AWidth,
  AHeight: Integer);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).ChangeSize(AWidth, AHeight);
end;

procedure TwrpTBCustomDockableWindow.DoubleClick;
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DoubleClick;
end;

function TwrpTBCustomDockableWindow.Get_ActivateParent: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).ActivateParent;
end;

function TwrpTBCustomDockableWindow.Get_CloseButton: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).CloseButton;
end;

function TwrpTBCustomDockableWindow.Get_CloseButtonWhenDocked: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).CloseButtonWhenDocked;
end;

function TwrpTBCustomDockableWindow.Get_CurrentSize: Integer;
begin
  Result := GetTBCustomDockableWindow.CurrentSize;
end;

function TwrpTBCustomDockableWindow.Get_Docked: WordBool;
begin
  Result := GetTBCustomDockableWindow.Docked;
end;

function TwrpTBCustomDockableWindow.Get_DockMode: TgsTBDockMode;
begin
  Result := TgsTBDockMode(TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DockMode);
end;

function TwrpTBCustomDockableWindow.Get_DockPos: Integer;
begin
  Result := GetTBCustomDockableWindow.DockPos;
end;

function TwrpTBCustomDockableWindow.Get_DockRow: Integer;
begin
  Result := GetTBCustomDockableWindow.DockRow;
end;

function TwrpTBCustomDockableWindow.Get_DragHandleStyle: TgsTBDragHandleStyle;
begin
  Result := TgsTBDragHandleStyle(TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DragHandleStyle);
end;

function TwrpTBCustomDockableWindow.Get_EffectiveDockPos: Integer;
begin
  Result := GetTBCustomDockableWindow.EffectiveDockPos;
end;

function TwrpTBCustomDockableWindow.Get_EffectiveDockRow: Integer;
begin
  Result := GetTBCustomDockableWindow.EffectiveDockRow;
end;

function TwrpTBCustomDockableWindow.Get_TBFloating: WordBool;
begin
  Result := GetTBCustomDockableWindow.Floating;
end;

function TwrpTBCustomDockableWindow.Get_FloatingMode: TgsTBFloatingMode;
begin
  Result := TgsTBFloatingMode(TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).FloatingMode);
end;

function TwrpTBCustomDockableWindow.Get_FullSize: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).FullSize;
end;

function TwrpTBCustomDockableWindow.Get_HideWhenInactive: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).HideWhenInactive;
end;

function TwrpTBCustomDockableWindow.Get_NonClientHeight: Integer;
begin
  Result := GetTBCustomDockableWindow.NonClientHeight;
end;

function TwrpTBCustomDockableWindow.Get_NonClientWidth: Integer;
begin
  Result := GetTBCustomDockableWindow.NonClientWidth;
end;

function TwrpTBCustomDockableWindow.Get_Resizable: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).Resizable;
end;

function TwrpTBCustomDockableWindow.Get_ShowCaption: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).ShowCaption;
end;

function TwrpTBCustomDockableWindow.Get_SmoothDrag: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).SmoothDrag;
end;

function TwrpTBCustomDockableWindow.Get_UseLastDock: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).UseLastDock;
end;

procedure TwrpTBCustomDockableWindow.GetMinMaxSize(AMinClientWidth,
  AMinClientHeight, AMaxClientWidth, AMaxClientHeight: Integer);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).GetMinMaxSize(AMinClientWidth,
    AMinClientHeight, AMaxClientWidth, AMaxClientHeight);
end;

function TwrpTBCustomDockableWindow.GetTBCustomDockableWindow: TTBCustomDockableWindow;
begin
  Result := GetObject as TTBCustomDockableWindow;
end;

function TwrpTBCustomDockableWindow.IsAutoResized: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).IsAutoResized;
end;

function TwrpTBCustomDockableWindow.IsMovable: WordBool;
begin
  Result := GetTBCustomDockableWindow.IsMovable;
end;

function TwrpTBCustomDockableWindow.PaletteChanged_(
  Foreground: WordBool): WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).PaletteChanged(Foreground);
end;

procedure TwrpTBCustomDockableWindow.Set_ActivateParent(
  Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).ActivateParent := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_CloseButton(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).CloseButton := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_CloseButtonWhenDocked(
  Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).CloseButtonWhenDocked := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_CurrentSize(Value: Integer);
begin
  GetTBCustomDockableWindow.CurrentSize := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_DockMode(
  Value: TgsTBDockMode);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DockMode := TTBDockMode(Value);
end;

procedure TwrpTBCustomDockableWindow.Set_DockPos(Value: Integer);
begin
  GetTBCustomDockableWindow.DockPos := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_DockRow(Value: Integer);
begin
  GetTBCustomDockableWindow.DockRow := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_DragHandleStyle(
  Value: TgsTBDragHandleStyle);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DragHandleStyle :=
    TTBDragHandleStyle(Value);
end;

procedure TwrpTBCustomDockableWindow.Set_TBFloating(Value: WordBool);
begin
  GetTBCustomDockableWindow.Floating := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_FloatingMode(
  Value: TgsTBFloatingMode);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).FloatingMode :=
    TTBFloatingMode(Value);
end;

procedure TwrpTBCustomDockableWindow.Set_FullSize(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).FullSize := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_HideWhenInactive(
  Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).HideWhenInactive := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_Resizable(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).Resizable := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_ShowCaption(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).ShowCaption := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_SmoothDrag(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).SmoothDrag := Value;
end;

procedure TwrpTBCustomDockableWindow.Set_UseLastDock(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).UseLastDock := Value;
end;

procedure TwrpTBCustomDockableWindow.SetBounds_(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).SetBounds(ALeft, ATop,
    AWidth, AHeight);
end;

procedure TwrpTBCustomDockableWindow.SizeChanging(AWidth,
  AHeight: Integer);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).SizeChanging(AWidth, AHeight);
end;

procedure TwrpTBCustomDockableWindow.AddDockForm(
  const Form: IgsTBCustomForm);
begin
  GetTBCustomDockableWindow.AddDockForm(InterfaceToObject(Form) as TTBCustomForm);
end;

procedure TwrpTBCustomDockableWindow.BeginSizing(
  ASizeHandle: TgsTBSizeHandle);
begin
  GetTBCustomDockableWindow.BeginSizing(TTBSizeHandle(ASizeHandle));
end;

function TwrpTBCustomDockableWindow.Get_CurrentDock: IgsTBDock;
begin
  Result := GetGdcOLEObject(GetTBCustomDockableWindow.CurrentDock) as IgsTBDock;
end;

function TwrpTBCustomDockableWindow.Get_LastDock: IgsTBDock;
begin
  Result := GetGdcOLEObject(GetTBCustomDockableWindow.LastDock) as IgsTBDock;
end;

function TwrpTBCustomDockableWindow.GetParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetTBCustomDockableWindow.GetParentComponent) as IgsComponent;
end;

procedure TwrpTBCustomDockableWindow.MoveOnScreen(
  OnlyIfFullyOffscreen: WordBool);
begin
  GetTBCustomDockableWindow.MoveOnScreen(OnlyIfFullyOffscreen);
end;

procedure TwrpTBCustomDockableWindow.RemoveDockForm(
  const Form: IgsTBCustomForm);
begin
  GetTBCustomDockableWindow.RemoveDockForm(InterfaceToObject(Form) as TTBCustomForm);
end;

procedure TwrpTBCustomDockableWindow.Set_CurrentDock(
  const Value: IgsTBDock);
begin
  GetTBCustomDockableWindow.CurrentDock := InterfaceToObject(Value) as TTBDock;
end;

procedure TwrpTBCustomDockableWindow.Set_LastDock(const Value: IgsTBDock);
begin
  GetTBCustomDockableWindow.LastDock := InterfaceToObject(Value) as TTBDock;
end;

function TwrpTBCustomDockableWindow.Get_DefaultDock: IgsTBDock;
begin
  Result := GetGdcOLEObject(TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DefaultDock) as IgsTBDock;
end;

function TwrpTBCustomDockableWindow.Get_DockableTo: WideString;
var
  LD: TTBDockableTo;
begin
  Result := ' ';
  LD := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DockableTo;
  if dpTop in LD then
    Result := Result + 'dpTop ';
  if dpBottom in LD then
    Result := Result + 'dpBottom ';
  if dpLeft in LD then
    Result := Result + 'dpLeft ';
  if dpRight in LD then
    Result := Result + 'dpRight ';
end;

function TwrpTBCustomDockableWindow.Get_Stretch: WordBool;
begin
  Result := TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).Stretch;
end;

procedure TwrpTBCustomDockableWindow.Set_DefaultDock(
  const Value: IgsTBDock);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DefaultDock :=
    InterfaceToObject(Value) as TTBDock;
end;

procedure TwrpTBCustomDockableWindow.Set_DockableTo(
  const Value: WideString);
var
  LD: TTBDockableTo;
begin
  LD := [];
  if Pos('DPTOP', Value) > 0 then
    Include(LD, DPTOP);
  if Pos('DPBOTTOM', Value) > 0 then
    Include(LD, DPBOTTOM);
  if Pos('DPLEFT', Value) > 0 then
    Include(LD, DPLEFT);
  if Pos('DPRIGHT', Value) > 0 then
    Include(LD, DPRIGHT);

  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).DockableTo := LD;
end;

procedure TwrpTBCustomDockableWindow.Set_Stretch(Value: WordBool);
begin
  TCrackTBCustomDockableWindow(GetTBCustomDockableWindow).Stretch := Value;
end;

procedure TwrpTBCustomDockableWindow.BeginUpdate;
begin
  GetTBCustomDockableWindow.BeginUpdate;
end;

procedure TwrpTBCustomDockableWindow.EndUpdate;
begin
  GetTBCustomDockableWindow.EndUpdate;
end;

{ TwrpTBCustomToolbar }

procedure TwrpTBCustomToolbar.CreateWrappersForAllControls;
begin
  GetTBCustomToolbar.CreateWrappersForAllControls;
end;

function TwrpTBCustomToolbar.Get_FloatingWidth: Integer;
begin
  Result := GetTBCustomToolbar.FloatingWidth;
end;

function TwrpTBCustomToolbar.Get_MenuBar: WordBool;
begin
  Result := GetTBCustomToolbar.MenuBar;
end;

function TwrpTBCustomToolbar.Get_ProcessShortCuts: WordBool;
begin
  Result := GetTBCustomToolbar.ProcessShortCuts;
end;

function TwrpTBCustomToolbar.Get_ShrinkMode: TgsTBShrinkMode;
begin
  Result := TgsTBShrinkMode(GetTBCustomToolbar.ShrinkMode);
end;

function TwrpTBCustomToolbar.Get_SystemFont: WordBool;
begin
  Result := TCrackCustomToolbar(GetTBCustomToolbar).SystemFont;
end;

function TwrpTBCustomToolbar.Get_UpdateActions: WordBool;
begin
  Result := GetTBCustomToolbar.UpdateActions;
end;

function TwrpTBCustomToolbar.GetShrinkMode: TgsTBShrinkMode;
begin
  Result := TgsTBShrinkMode(TCrackCustomToolbar(GetTBCustomToolbar).GetShrinkMode);
end;

function TwrpTBCustomToolbar.GetTBCustomToolbar: TTBCustomToolbar;
begin
  Result := GetObject as TTBCustomToolbar;
end;

procedure TwrpTBCustomToolbar.InitiateAction_;
begin
  GetTBCustomToolbar.InitiateAction;
end;

function TwrpTBCustomToolbar.KeyboardOpen(Key: Shortint;
  RequirePrimaryAccel: WordBool): WordBool;
begin
  Result := GetTBCustomToolbar.KeyboardOpen(Char(Key), RequirePrimaryAccel);
end;

procedure TwrpTBCustomToolbar.Loaded;
begin
  TCrackCustomToolbar(GetTBCustomToolbar).Loaded;
end;

procedure TwrpTBCustomToolbar.ResizeEnd;
begin
  TCrackCustomToolbar(GetTBCustomToolbar).ResizeEnd;
end;

procedure TwrpTBCustomToolbar.ResizeTrackAccept;
begin
  TCrackCustomToolbar(GetTBCustomToolbar).ResizeTrackAccept;
end;

procedure TwrpTBCustomToolbar.Set_FloatingWidth(Value: Integer);
begin
  GetTBCustomToolbar.FloatingWidth := Value;
end;

procedure TwrpTBCustomToolbar.Set_MenuBar(Value: WordBool);
begin
  GetTBCustomToolbar.MenuBar := Value;
end;

procedure TwrpTBCustomToolbar.Set_ProcessShortCuts(Value: WordBool);
begin
  GetTBCustomToolbar.ProcessShortCuts := Value;
end;

procedure TwrpTBCustomToolbar.Set_ShrinkMode(Value: TgsTBShrinkMode);
begin
  GetTBCustomToolbar.ShrinkMode := TTBShrinkMode(Value);
end;

procedure TwrpTBCustomToolbar.Set_SystemFont(Value: WordBool);
begin
  TCrackCustomToolbar(GetTBCustomToolbar).SystemFont := Value;
end;

procedure TwrpTBCustomToolbar.Set_UpdateActions(Value: WordBool);
begin
  TCrackCustomToolbar(GetTBCustomToolbar).UpdateActions := Value;
end;

function TwrpTBCustomToolbar.Get_ChevronHint: WideString;
begin
  Result := GetTBCustomToolbar.ChevronHint;
end;

function TwrpTBCustomToolbar.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetTBCustomToolbar.Images) as IgsCustomImageList;
end;

function TwrpTBCustomToolbar.Get_Items: IgsTBRootItem;
begin
  Result := GetGdcOLEObject(GetTBCustomToolbar.Items) as IgsTBRootItem;
end;

function TwrpTBCustomToolbar.Get_LinkSubitems: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBCustomToolbar.LinkSubitems) as IgsTBCustomItem;
end;

function TwrpTBCustomToolbar.Get_Options: WideString;
begin
  Result := ' ';
  if tboDefault in GetTBCustomToolbar.Options then
    Result := Result + 'tboDefault ';
  if tboDropdownArrow in GetTBCustomToolbar.Options then
    Result := Result + 'tboDropdownArrow ';
  if tboImageAboveCaption in GetTBCustomToolbar.Options then
    Result := Result + 'tboImageAboveCaption ';
  if tboLongHintInMenuOnly in GetTBCustomToolbar.Options then
    Result := Result + 'tboLongHintInMenuOnly ';
  if tboNoRotation in GetTBCustomToolbar.Options then
    Result := Result + 'tboNoRotation ';
  if tboShowHint in GetTBCustomToolbar.Options then
    Result := Result + 'tboShowHint ';
  if tboToolbarStyle in GetTBCustomToolbar.Options then
    Result := Result + 'tboToolbarStyle ';
  if tboToolbarSize in GetTBCustomToolbar.Options then
    Result := Result + 'tboToolbarSize ';
end;

procedure TwrpTBCustomToolbar.Set_ChevronHint(const Value: WideString);
begin
  GetTBCustomToolbar.ChevronHint := Value;
end;

procedure TwrpTBCustomToolbar.Set_Images(const Value: IgsCustomImageList);
begin
  GetTBCustomToolbar.Images := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpTBCustomToolbar.Set_LinkSubitems(
  const Value: IgsTBCustomItem);
begin
  GetTBCustomToolbar.LinkSubitems := InterfaceToObject(Value) as TTBCustomItem;
end;

procedure TwrpTBCustomToolbar.Set_Options(const Value: WideString);
var
  LOpt: TTBItemOptions;
begin
  LOpt := [];
  if Pos('TBODEFAULT', Value) > 0 then
    Include(LOpt, TBODEFAULT);
  if Pos('TBODROPDOWNARROW', Value) > 0 then
    Include(LOpt, TBODROPDOWNARROW);
  if Pos('TBOIMAGEABOVECAPTION', Value) > 0 then
    Include(LOpt, TBOIMAGEABOVECAPTION);
  if Pos('TBOLONGHINTINMENUONLY', Value) > 0 then
    Include(LOpt, TBOLONGHINTINMENUONLY);
  if Pos('TBONOROTATION', Value) > 0 then
    Include(LOpt, TBONOROTATION);
  if Pos('TBOSHOWHINT', Value) > 0 then
    Include(LOpt, TBOSHOWHINT);
  if Pos('TBOTOOLBARSTYLE', Value) > 0 then
    Include(LOpt, TBOTOOLBARSTYLE);
  if Pos('TBOTOOLBARSIZE', Value) > 0 then
    Include(LOpt, TBOTOOLBARSIZE);

  GetTBCustomToolbar.Options := LOpt;
end;

function TwrpTBCustomToolbar.Get_View: IgsTBToolbarView;
begin
  Result := GetGdcOLEObject(GetTBCustomToolbar.View) as IgsTBToolbarView;
end;

{ TwrpGDCBase }

procedure TwrpGDCBase.AssignField(AnID: Integer;
  const AFieldName: WideString; AValue: OleVariant);
begin
  GetGDCBase.AssignField(AnID, AFieldName, AValue);
end;

procedure TwrpGDCBase.CloseOpen;
begin
  GetGDCBase.CloseOpen;
end;

function TwrpGDCBase.Copy(const AFields: WideString; AValues: OleVariant;
  ACopyDetail, APost: WordBool): WordBool;
begin
  Result := GetGDCBase.Copy(AFields, AValues, ACopyDetail, APost);
end;

function TwrpGDCBase.CopyDialog: WordBool;
begin
  Result := GetGDCBase.CopyDialog;
end;

function TwrpGDCBase.CreateDescendant: WordBool;
begin
  Result := GetGDCBase.CreateDescendant;
end;

function TwrpGDCBase.CreateDialog(const ADlgClassName: WideString): WordBool;
begin
  Result := GetGDCBase.CreateDialog(ADlgClassName);
end;

procedure TwrpGDCBase.CreateNext;
begin
  GetGDCBase.CreateNext;
end;

function TwrpGDCBase.EditDialog(const ADlgClassName: WideString): WordBool;
begin
  Result := GetGDCBase.EditDialog(ADlgClassName);
end;

function TwrpGDCBase.FieldNameByAliasName(
  const AnAliasName: WideString): WideString;
begin
  Result := GetGDCBase.FieldNameByAliasName(AnAliasName);
end;

procedure TwrpGDCBase.Find;
begin
  //GetGDCBase.Find;
end;

function TwrpGDCBase.Get_AggregatesActive: WordBool;
begin
  Result := GetGDCBase.AggregatesActive;
end;

function TwrpGDCBase.Get_DetailClassesCount: Integer;
begin
  Result := 0;
end;

function TwrpGDCBase.Get_DetailField: WideString;
begin
  Result := GetGDCBase.DetailField;
end;

function TwrpGDCBase.Get_DetailLinksCount: Integer;
begin
  Result := GetGDCBase.DetailLinksCount;
end;

function TwrpGDCBase.Get_GroupID: Integer;
begin
  Result := GetGDCBase.GroupID;
end;

function TwrpGDCBase.Get_HasWhereClause: WordBool;
begin
  Result := GetGDCBase.HasWhereClause;
end;

function TwrpGDCBase.Get_ID: Integer;
begin
  Result := GetGDCBase.ID;
end;

function TwrpGDCBase.Get_MasterField: WideString;
begin
  Result := GetGDCBase.MasterField;
end;

function TwrpGDCBase.Get_NameInScript: WideString;
begin
  Result := GetGDCBase.NameInScript;
end;

function TwrpGDCBase.Get_ObjectName: WideString;
begin
  Result := GetGDCBase.ObjectName;
end;

function TwrpGDCBase.Get_SubType: WideString;
begin
  Result := GetGDCBase.SubType;
end;

function TwrpGDCBase.GetDisplayName(
  const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetDisplayName(ASubType);
end;

procedure TwrpGDCBase.GetDistinctColumnValues(const AFieldName: WideString;
  const S: IgsStrings; DoSort: WordBool);
begin
  GetGDCBase.GetDistinctColumnValues(AFieldName, IgsStringsToTStrings(S), DoSort);
end;

function TwrpGDCBase.GetGDCBase: TgdcBase;
begin
  Result := GetObject as TgdcBase;
end;

function TwrpGDCBase.GetKeyField(const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetKeyField(ASubType);
end;

function TwrpGDCBase.GetListField(const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetListField(ASubType);
end;

function TwrpGDCBase.GetListNameByID(AnID: Integer): WideString;
begin
  Result := GetGDCBase.GetListNameByID(AnID);
end;

function TwrpGDCBase.GetListTable(const ASubType: WideString): WideString;
begin
  Result := CgdcBase(Get_SelfClass).GetListTable(ASubType);
end;

function TwrpGDCBase.GetListTableAlias: WideString;
begin
  Result := GetGDCBase.GetListTableAlias;
end;

function TwrpGDCBase.GetNextID(Increment: WordBool): Integer;
begin
  Result := GetGDCBase.GetNextID(Increment);
end;

function TwrpGDCBase.GetRestrictCondition(const ATableName,
  ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetRestrictCondition(ATableName, ASubType);
end;

function TwrpGDCBase.GetSubSetList: WideString;
begin
  Result := GetGDCBase.GetSubSetList;
end;

function TwrpGDCBase.GetSubTypeList(const SubTypeList: IgsStrings): WordBool;
begin
  Result := GetGDCBase.GetSubTypeList(IgsStringsToTStrings(SubTypeList));
end;

function TwrpGDCBase.HasAttribute: WordBool;
begin
  Result := GetGDCBase.HasAttribute;
end;

function TwrpGDCBase.HideFieldsList: WideString;
begin
  Result := GetGDCBase.HideFieldsList;
end;

function TwrpGDCBase.IsBigTable: WordBool;
begin
  Result := GetGDCBase.IsBigTable
end;

procedure TwrpGDCBase.LoadFromFile(const AFileName: WideString);
begin
  GetGDCBase.LoadFromFile(AFileName);
end;

procedure TwrpGDCBase.PopupFilterMenu(X, Y: Integer);
begin
  GetGDCBase.PopupFilterMenu(X, Y);
end;

procedure TwrpGDCBase.PopupReportMenu(X, Y: Integer);
begin
  GetGDCBase.PopupReportMenu(X, Y);
end;

procedure TwrpGDCBase.Prepare;
begin
  GetGDCBase.Prepare;
end;

function TwrpGDCBase.Reduction(const BL: IgsBookmarkList): WordBool;
begin
  Result := GetGDCBase.Reduction(InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGDCBase.RefreshStats;
begin
  GetGDCBase.RefreshStats;
end;

function TwrpGDCBase.RelationByAliasName(
  const AnAliasName: WideString): WideString;
begin
  Result := GetGDCBase.RelationByAliasName(AnAliasName);
end;

procedure TwrpGDCBase.SaveToFile(const AFileName: WideString);
begin
  GetGDCBase.SaveToFile(AFileName);
end;

procedure TwrpGDCBase.Set_AggregatesActive(Value: WordBool);
begin
  GetGDCBase.AggregatesActive := Value;
end;

procedure TwrpGDCBase.Set_DetailField(const Value: WideString);
begin
  GetGDCBase.DetailField := Value;
end;

procedure TwrpGDCBase.Set_ID(Value: Integer);
begin
  GetGDCBase.ID := Value;
end;

procedure TwrpGDCBase.Set_MasterField(const Value: WideString);
begin
  GetGDCBase.MasterField := Value;
end;

procedure TwrpGDCBase.Set_NameInScript(const Value: WideString);
begin
  GetGDCBase.NameInScript := Value;
end;

procedure TwrpGDCBase.Set_ObjectName(const Value: WideString);
begin
  GetGDCBase.ObjectName := Value;
end;

procedure TwrpGDCBase.Set_SubType(const Value: WideString);
begin
  GetGDCBase.SubType := Value;
end;

procedure TwrpGDCBase.SetRefreshSQLOn(SetOn: WordBool);
begin
  GetGDCBase.SetRefreshSQLOn(SetOn);
end;

function TwrpGDCBase.ShowFieldInGrid(const AField: IgsFieldComponent): WordBool;
begin
  Result := GetGDCBase.ShowFieldInGrid(InterfaceToObject(AField) as TField);
end;


{
function TwrpGDCBase.Get_Transaction: IgsIBTransaction;
begin
  Result :=  GetGdcOLEObject(GetGDCBase.Transaction) as IgsIBTransaction;
end;

}
{
procedure TwrpGDCBase.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetGDCBase.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;
 }
function TwrpGDCBase.ParamByName(const Idx: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetGDCBase.ParamByName(Idx)) as IgsIBXSQLVAR;
end;

function TwrpGDCBase.Get_CreationDate: TDateTime;
begin
  Result := GetGDCBase.CreationDate;
end;

function TwrpGDCBase.Get_CreatorKey: Integer;
begin
  Result := GetGDCBase.CreatorKey;
end;

function TwrpGDCBase.Get_CreatorName: WideString;
begin
  Result := GetGDCBase.CreatorName;
end;

function TwrpGDCBase.Get_DSModified: WordBool;
begin
  Result := GetGDCBase.DSModified;
end;

function TwrpGDCBase.Get_EditionDate: TDateTime;
begin
  Result := GetGDCBase.EditionDate;
end;

function TwrpGDCBase.Get_EditorKey: Integer;
begin
  Result := GetGDCBase.EditorKey;
end;

function TwrpGDCBase.Get_EditorName: WideString;
begin
  Result := GetGDCBase.EditorName;
end;

function TwrpGDCBase.Get_ExtraConditions: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetGDCBase.ExtraConditions);
end;

function TwrpGDCBase.Get_SelectedID: IgsGDKeyArray;
begin
  Result := GetGdcOLEObject(GetGDCBase.SelectedID) as IgsGDKeyArray;
end;

function TwrpGDCBase.Get_MasterSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetGDCBase.MasterSource) as IgsDataSource;
end;

procedure TwrpGDCBase.Set_MasterSource(const Value: IgsDataSource);
begin
  GetGDCBase.MasterSource := InterfaceToObject(Value) as TDataSource;
end;

function TwrpGDCBase.Get_SubSet: WideString;
begin
  Result := GetGDCBase.SubSet;
end;

procedure TwrpGDCBase.Set_SubSet(const Value: WideString);
begin
  GetGDCBase.SubSet := TgdcSubSet(Value);
end;

{
function TwrpGDCBase.Get_Fields: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetGDCBase.Fields) as IgsFieldComponent;
end;
}

{
function TwrpGDCBase.Get_Params: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetGDCBase.Params) as IgsIBXSQLDA;
end;
}

function TwrpGDCBase.Get_DialogActions: WideString;
begin
  Result := ' ';
  {if daOkNone in GetGDCBase.DialogActions then
    Result := Result + 'daOkNone ';
  if daOkCommit in GetGDCBase.DialogActions then
    Result := Result + 'daOkCommit ';
  if daOkCommitReopen in GetGDCBase.DialogActions then
    Result := Result + 'daOkCommitReopen ';
  if daOkCommitRetaining in GetGDCBase.DialogActions then
    Result := Result + 'daOkCommitRetaining ';
  if daCancelNone in GetGDCBase.DialogActions then
    Result := Result + 'daCancelNone ';
  if daCancelRollback in GetGDCBase.DialogActions then
    Result := Result + 'daCancelRollback ';
  if daCancelRollbackReopen in GetGDCBase.DialogActions then
    Result := Result + 'daCancelRollbackReopen ';
  if daCancelRollbackRetaining in GetGDCBase.DialogActions then
    Result := Result + 'daCancelRollbackRetaining ';}
end;

procedure TwrpGDCBase.Set_DialogActions(const Value: WideString);
{var
  LocDialogActions: TgsDialogActions;
  Str: String;}
begin
  {Str := UpperCase(Value);
  if Pos('DAOKNONE' , str) > 0 then
    Include(LocDialogActions, daOkNone);
  if Pos('DAOKCOMMIT' , str) > 0 then
    Include(LocDialogActions, daOkCommit);
  if Pos('DAOKCOMMITREOPEN' , str) > 0 then
    Include(LocDialogActions, daOkCommitReopen);
  if Pos('DAOKCOMMITRETAINING' , str) > 0 then
    Include(LocDialogActions, daOkCommitRetaining);
  if Pos('DACANCELNONE' , str) > 0 then
    Include(LocDialogActions, daCancelNone);
  if Pos('DACANCELROLLBACK' , str) > 0 then
    Include(LocDialogActions, daCancelRollback);
  if Pos('DACANCELROLLBACKREOPEN' , str) > 0 then
    Include(LocDialogActions, daCancelRollbackReopen);
  if Pos('DACANCELROLLBACKRETAINING' , str) > 0 then
    Include(LocDialogActions, daCancelRollbackRetaining);}
end;

function TwrpGDCBase.CreateViewForm(const AnOwner: IgsComponent;
  const AClassName, ASubType: WideString): IgsForm;
begin
  Result := GetGdcOLEObject(GetGDCBase.CreateViewForm(
    InterfaceToObject(AnOwner) as TComponent, AClassName, ASubType)) as IgsForm;

end;

function TwrpGDCBase.GetViewFormClassName(
  const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetViewFormClassName(ASubType);
end;

function TwrpGDCBase.CreateSingularByID(const AnOwner: IgsComponent;
  const ADatabase: IgsIBDatabase; const ATransaction: IgsIBTransaction;
  AnID: Integer; const ASubType: WideString): IgsGDCBase;
begin
  Result := GetGDCOleObject(GetGDCBase.CreateSingularByID(InterfaceToObject(AnOwner) as TComponent,
    InterfaceToObject(ADatabase) as TIBDatabase, InterfaceToObject(ATransaction) as TIBTransaction,
    AnID, ASubType)) as IgsGDCBase;
end;

function TwrpGDCBase.CreateDialogForm: IgsCreateableForm;
begin
  Result := GetGdcOLEObject(TCrackGDCBase(GetGDCBase).CreateDialogForm) as IgsCreateableForm;
end;

procedure TwrpGDCBase.GetWhereClauseConditions(const S: IgsStrings);
begin
  TCrackGDCBase(GetGDCBase).GetWhereClauseConditions(IgsStringsToTStrings(S));
end;

procedure TwrpGDCBase.DoOnNewRecord_;
begin
  TCrackGDCBase(GetGDCBase)._DoOnNewRecord;
end;

function TwrpGDCBase.CommitRequired: WordBool;
begin
  Result := GetGDCBase.CommitRequired;
end;

{function TwrpGDCBase.Get_ExtraCondition: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetGDCBase.ExtraConditions);
end;}

function TwrpGDCBase.GetNotCopyField: WideString;
begin
  Result := TCrackGdcBase(GetGDCBase).GetNotCopyField;
end;

function TwrpGDCBase.Get_DetailLinks(Index: Integer): IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGDCBase.DetailLinks[Index]) as IgsGDCBase;
end;

{function TwrpGDCBase.ChooseItems(const Cl: WideString;
  const KeyArray: IgsGDKeyArray; DoProcess: WordBool;
  const ChooseComponentName, ChooseSubSet: WideString): WordBool;
var
  LgdcClass: CgdcBase;
begin
  Result := False;
  LgdcClass := gdcClassList.GetGDCClass(Cl);
  if Assigned(LgdcClass) then
    Result := GetGDCBase.ChooseItems(LgdcClass, InterfaceToObject(KeyArray) as TgdKeyArray,
      DoProcess, ChooseComponentName, ChooseSubSet);
end;

function TwrpGDCBase.ChooseItemsSelf(DoProcess: WordBool;
  const ChooseComponentName, ChooseSubSet: WideString): WordBool;
begin
  Result := GetGDCBase.ChooseItems(DoProcess, ChooseComponentName, ChooseSubSet);
end;
}
function TwrpGDCBase.ChooseItems(const Cl: WideString;
  const KeyArray: IgsGDKeyArray; DoProcess: WordBool;
  const ChooseComponentName, ChooseSubSet,
  ChooseSubType: WideString): WordBool;
var
  LgdcClass: CgdcBase;
  V: OleVariant;
  CE: TgdClassEntry;
begin
  CE := gdClassList.Find(Cl);
  if CE is TgdBaseEntry then
    LgdcClass := TgdBaseEntry(CE).gdcClass
  else
    LgdcClass := nil;
  Result := GetGDCBase.ChooseItems(LgdcClass, InterfaceToObject(KeyArray) as TgdKeyArray,
    V, ChooseComponentName, ChooseSubSet, ChooseSubType);
end;

function TwrpGDCBase.ChooseItemsSelf(DoProcess: WordBool;
  const ChooseComponentName, ChooseSubSet: WideString): WordBool;
var
  V: OleVariant;  
begin
  Result := GetGDCBase.ChooseItems(V, ChooseComponentName, ChooseSubSet);
end;

function TwrpGDCBase.Get_ParentForm: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetGDCBase.ParentForm) as IgsWinControl;
end;

function TwrpGDCBase.Get_Aggregates: IgsGdcAggregates;
begin
  Result := GetGdcOLEObject(GetGDCBase.Aggregates) as IgsGdcAggregates;
end;

function TwrpGDCBase.Get_BaseState: WideString;
begin
  Result := ' ';
  if sNone in GetGDCBase.BaseState then
    Result := Result + 'sNone ';
  if sView in GetGDCBase.BaseState then
    Result := Result + 'sView ';
  if sDialog in GetGDCBase.BaseState then
    Result := Result + 'sDialog ';
  if sSubDialog in GetGDCBase.BaseState then
    Result := Result + 'sSubDialog ';
  if sSyncControls in GetGDCBase.BaseState then
    Result := Result + 'sSyncControls ';
  if sLoadFromStream in GetGDCBase.BaseState then
    Result := Result + 'sLoadFromStream ';
  if sMultiple in GetGDCBase.BaseState then
    Result := Result + 'sMultiple ';
  if sFakeLoad in GetGDCBase.BaseState then
    Result := Result + 'sFakeLoad ';
  if sPost in GetGDCBase.BaseState then
    Result := Result + 'sPost ';
  if sCopy in GetGDCBase.BaseState then
    Result := Result + 'sCopy ';
  if sSkipMultiple in GetGDCBase.BaseState then
    Result := Result + 'sSkipMultiple ';
  if sAskMultiple in GetGDCBase.BaseState then
    Result := Result + 'sAskMultiple ';
  if sSubProcess in GetGDCBase.BaseState then
    Result := Result + 'sSubProcess ';
end;

function TwrpGDCBase.Get_DetailClasses(Index: Integer): WideString;
begin
  Result := '';
end;

function TwrpGDCBase.Get_EventList: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGDCBase.EventList) as IgsStringList;
end;

function TwrpGDCBase.Get_QueryFilter: IgsQueryFilterGDC;
begin
  Result := GetGdcOLEObject(GetGDCBase.Filter) as IgsQueryFilterGDC;
end;

function TwrpGDCBase.Get_gdcTableInfos: WideString;
begin
  Result := ' ';
  if tiID in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiID ';
  if tiParent in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiParent ';
  if tiLBRB in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiLBRB ';
  if tiCreatorKey in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiCreatorKey ';
  if tiCreationDate in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiCreationDate ';
  if tiEditorKey in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiEditorKey ';
  if tiEditionDate in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiEditionDate ';
  if tiAFull in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiAFull ';
  if tiAChag in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiAChag ';
  if tiAView in GetGDCBase.gdcTableInfos then
    Result := Result + 'tiAView ';
end;

function TwrpGDCBase.Get_CanChangeRights: WordBool;
begin
  Result := GetGDCBase.CanChangeRights;
end;

function TwrpGDCBase.Get_CanCreate: WordBool;
begin
  Result := GetGDCBase.CanCreate;
end;

function TwrpGDCBase.Get_CanDelete: WordBool;
begin
  Result := GetGDCBase.CanDelete;
end;

function TwrpGDCBase.Get_CanEdit: WordBool;
begin
  Result := GetGDCBase.CanEdit;
end;

function TwrpGDCBase.Get_CanPrint: WordBool;
begin
  Result := GetGDCBase.CanPrint;
end;

function TwrpGDCBase.Get_CanView: WordBool;
begin
  Result := GetGDCBase.CanView;
end;

function TwrpGDCBase.Get_QSelect: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetGDCBase.QSelect) as IgsIBSQL;
end;

function TwrpGDCBase.Get_RefreshMaster: WordBool;
begin
  Result := GetGDCBase.RefreshMaster;
end;

function TwrpGDCBase.Get_SetTable: WideString;
begin
  Result := GetGDCBase.SetTable;
end;

function TwrpGDCBase.Get_SubSetCount: Integer;
begin
  Result := GetGDCBase.SubSetCount;
end;

function TwrpGDCBase.Get_SubSets(Index: Integer): WideString;
begin
  Result := GetGDCBase.SubSets[Index];
end;

procedure TwrpGDCBase.Set_RefreshMaster(Value: WordBool);
begin
  GetGDCBase.RefreshMaster := Value;
end;

procedure TwrpGDCBase.Set_SetTable(const Value: WideString);
begin
  GetGDCBase.SetTable := Value;
end;

procedure TwrpGDCBase.Set_SubSets(Index: Integer;
  const Value: WideString);
begin
  GetGDCBase.SubSets[Index] := Value
end;

procedure TwrpGDCBase.LoadFromStream_(const Stream: IgsStream;
  const IDMapping: IgsGdKeyIntAssoc; const ObjectSet: IgsGdcObjectSet;
  const UpdateList: IgsObjectList);
begin
  GetGDCBase._LoadFromStream(InterfaceToObject(Stream) as TStream,
    InterfaceToObject(IDMapping) as TgdKeyIntAssoc, InterfaceToObject(ObjectSet)
    as TgdcObjectSet, InterfaceToObject(UpdateList) as TObjectList);
end;

procedure TwrpGDCBase.SaveToStream_(const Stream: IgsStream;
  const ObjectSet: IgsGdcObjectSet;
  SaveDetailObjects: WordBool);
begin
  GetGDCBase._SaveToStream(InterfaceToObject(Stream) as TStream,
    InterfaceToObject(ObjectSet) as TgdcObjectSet, nil, nil, nil, SaveDetailObjects);
end;

procedure TwrpGDCBase.AddSubSet(const ASubSet: WideString);
begin
  GetGDCBase.AddSubSet(ASubSet);
end;

procedure TwrpGDCBase.AddToSelectedArray(const ASelectedID: IgsGDKeyArray);
begin
  GetGDCBase.AddToSelectedID(InterfaceToObject(ASelectedID) as TgdKeyArray);
end;

procedure TwrpGDCBase.AddToSelectedBookmark(const BL: IgsBookmarkList);
begin
  GetGDCBase.AddToSelectedID(InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGDCBase.AddToSelectedID(ID: Integer);
begin
  GetGDCBase.AddToSelectedID(ID);
end;

procedure TwrpGDCBase.AfterConstruction;
begin
  GetGDCBase.AfterConstruction;
end;

function TwrpGDCBase.CanPasteFromClipboard: WordBool;
begin
  Result := GetGDCBase.CanPasteFromClipboard;
end;

procedure TwrpGDCBase.CheckCurrentRecord;
begin
  GetGDCBase.CheckCurrentRecord;
end;

function TwrpGDCBase.CheckSubSet(const ASubSetbstr: WideString): WordBool;
begin
  Result := GetGDCBase.CheckSubSet(ASubSetbstr);
end;

procedure TwrpGDCBase.ClearSubSets;
begin
  GetGDCBase.ClearSubSets;
end;

procedure TwrpGDCBase.CopyToClipboard(const BL: IgsBookmarkList; ACut: WordBool);
begin
  GetGDCBase.CopyToClipboard(InterfaceToObject(BL) as TBookmarkList, ACut);
end;

procedure TwrpGDCBase.DataEvent(Event: TgsDataEvent; Info: Integer);
begin
  TCrackGdcBase(GetGDCBase).DataEvent(TDataEvent(Event), Info);
end;

function TwrpGDCBase.DeleteMultiple(const BL: IgsBookmarkList): WordBool;
begin
  Result := GetGDCBase.DeleteMultiple(InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGDCBase.DeleteSubSet(Index: Integer);
begin
  GetGDCBase.DeleteSubSet(Index);
end;

procedure TwrpGDCBase.DoAfterShowDialog(const DlgForm: IgsCreateableForm;
  IsOk: WordBool);
begin
  GetGDCBase.DoAfterShowDialog(InterfaceToObject(DlgForm) as TCreateableForm, IsOk);
end;

procedure TwrpGDCBase.DoBeforeShowDialog(const DlgForm: IgsCreateableForm);
begin
  GetGDCBase.DoBeforeShowDialog(InterfaceToObject(DlgForm) as TgdcCreateableForm);
end;

function TwrpGDCBase.EditMultiple(const BL: IgsBookmarkList;
  const ADlgClassName: WideString): WordBool;
begin
  Result := GetGDCBase.EditMultiple(InterfaceToObject(BL) as TBookmarkList, ADlgClassName);
end;

procedure TwrpGDCBase.GetClassImage(ASizeX, ASizeY: Integer;
  const AGraphic: IgsGraphic);
begin
  GetGDCBase.GetClassImage(ASizeX, ASizeY, InterfaceToObject(AGraphic) as TGraphic);
end;

function TwrpGDCBase.GetClassName: WideString;
begin
  Result := GetGDCBase.GetClassName;
end;

procedure TwrpGDCBase.GetCurrRecordClass(out AgdcClassName,
  ASubType: OleVariant);
begin
  AgdcClassName := GetGDCBase.GetCurrRecordClass.gdClass.ClassName;
  ASubType := GetGDCBase.GetCurrRecordClass.SubType;
end;

function TwrpGDCBase.GetFieldValueForBookmark(const ABookmark,
  AFieldName: WideString): OleVariant;
begin
  Result := GetGDCBase.GetFieldValueForBookmark(ABookmark, AFieldName);
end;

function TwrpGDCBase.GetFieldValueForID(AnID: Integer;
  const AFieldName: WideString): OleVariant;
begin
  Result := GetGDCBase.GetFieldValueForID(AnID, AFieldName);
end;

function TwrpGDCBase.GetListFieldExtended(const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.GetListFieldExtended(ASubType);
end;

function TwrpGDCBase.GetTableInfos(const ASubType: WideString): WideString;
var
  LInfo: TgdcTableInfos;
begin
  Result := ' ';
  LInfo :=  GetGDCBase.GetTableInfos(ASubType);
  if tiID in LInfo then
    Result := Result + 'tiID ';
  if tiParent in LInfo then
    Result := Result + 'tiParent ';
  if tiLBRB in LInfo then
    Result := Result + 'tiLBRB ';
  if tiCreatorKey in LInfo then
    Result := Result + 'tiCreatorKey ';
  if tiCreationDate in LInfo then
    Result := Result + 'tiCreationDate ';
  if tiEditorKey in LInfo then
    Result := Result + 'tiEditorKey ';
  if tiEditionDate in LInfo then
    Result := Result + 'tiEditionDate ';
  if tiAFull in LInfo then
    Result := Result + 'tiAFull ';
  if tiAChag in LInfo then
    Result := Result + 'tiAChag ';
  if tiAView in LInfo then
    Result := Result + 'tiAView ';
end;

function TwrpGDCBase.HasSubSet(const ASubSet: WideString): WordBool;
begin
  Result := GetGDCBase.HasSubSet(ASubSet);
end;

procedure TwrpGDCBase.LoadFromStream(const S: IgsStream);
begin
  GetGDCBase.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGDCBase.LoadSelectedFromStream(const S: IgsStream);
begin
  GetGDCBase.LoadSelectedFromStream(InterfaceToObject(S) as TStream);
end;

function TwrpGDCBase.ParentHandle: Integer;
begin
  Result := GetGDCBase.ParentHandle;
end;

function TwrpGDCBase.PasteFromClipboard(ATestKeyboard: WordBool): WordBool;
begin
  Result := GetGDCBase.PasteFromClipboard(ATestKeyboard);
end;

function TwrpGDCBase.QGetNameForID(AnID: Integer; const ASubType: WideString): WideString;
begin
  Result := GetGDCBase.QGetNameForID(AnID, ASubType);
end;

procedure TwrpGDCBase.QueryDescendant(out AgdcBaseName,
  ASubType: OleVariant);
begin
  AgdcBaseName := GetGdcBase.QueryDescendant.gdClass.ClassName;
  ASubType := GetGdcBase.QueryDescendant.SubType;
end;

function TwrpGDCBase.QueryLoadFileName(
  const AFileName: WideString): WideString;
begin
  Result := GetGDCBase.QueryLoadFileName(AFileName);
end;

function TwrpGDCBase.QuerySaveFileName(
  const AFileName: WideString): WideString;
begin
  Result := GetGDCBase.QuerySaveFileName(AFileName);
end;

procedure TwrpGDCBase.RemoveFromSelectedArray(const BL: IgsBookmarkList);
begin
  GetGDCBase.RemoveFromSelectedID(InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGDCBase.RemoveFromSelectedID(ID: Integer);
begin
  GetGDCBase.RemoveFromSelectedID(ID);
end;

procedure TwrpGDCBase.RemoveSubSet(const ASubSet: WideString);
begin
  GetGDCBase.RemoveSubSet(ASubSet);
end;

procedure TwrpGDCBase.ResetAllAggs(AnActive: WordBool;
  const BL: IgsBookmarkList);
begin
  GetGDCBase.ResetAllAggs(AnActive, InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGDCBase.SaveSelectedToStream(const S: IgsStream);
begin
  GetGDCBase.SaveSelectedToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGDCBase.SaveToStream(const Stream: IgsStream;
  const DetailDS: IgsGDCBase; const BL: IgsBookmarkList; OnlyCurrent: WordBool);
begin
  GetGDCBase.SaveToStream(InterfaceToObject(Stream) as TStream,
    InterfaceToObject(DetailDS) as TgdcBase, InterfaceToObject(BL) as TBookmarkList, OnlyCurrent);
end;

procedure TwrpGDCBase.SetExclude(Reopen: WordBool);
begin
  GetGDCBase.SetExclude(Reopen);
end;

procedure TwrpGDCBase.SetInclude(AnID: Integer);
begin
  GetGDCBase.SetInclude(AnID);
end;

procedure TwrpGDCBase.SetValueForBookmark(const ABookmark,
  AFieldName: WideString; AValue: OleVariant);
begin
  GetGDCBase.SetValueForBookmark(ABookmark, AFieldName, AValue)
end;

procedure TwrpGDCBase.UnPrepare;
begin
  GetGDCBase.UnPrepare;
end;

function TwrpGDCBase.Get_QueryFiltered: WordBool;
begin
  Result := GetGDCBase.QueryFiltered;
end;

procedure TwrpGDCBase.Set_QueryFiltered(Value: WordBool);
begin
  GetGDCBase.QueryFiltered := Value;
end;

function TwrpGDCBase.Get_FieldsCallDoChange: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGDCBase.FieldsCallDoChange) as IgsStringList;
end;

procedure TwrpGDCBase.AddObjectItem(const Name: WideString);
begin
  GetGDCBase.AddObjectItem(Name);
end;

procedure TwrpGDCBase.AddVariableItem(const Name: WideString);
begin
  GetGDCBase.AddVariableItem(Name)
end;

function TwrpGDCBase.Get_Objects(const Name: WideString): IDispatch;
begin
  Result := GetGDCBase.Objects[Name]
end;

function TwrpGDCBase.Get_Variables(const Name: WideString): OleVariant;
begin
  Result := GetGDCBase.Variables[Name]
end;

procedure TwrpGDCBase.Set_Objects(const Name: WideString;
  const Value: IDispatch);
begin
  GetGDCBase.Objects[Name] := Value
end;

procedure TwrpGDCBase.Set_Variables(const Name: WideString;
  Value: OleVariant);
begin
  GetGDCBase.Variables[Name] := Value
end;

function TwrpGDCBase.ObjectExists(const Name: WideString): WordBool;
begin
  Result := GetGDCBase.ObjectExists(Name);
end;

function TwrpGDCBase.VariableExists(const Name: WideString): WordBool;
begin
  Result := GetGDCBase.VariableExists(Name);
end;

function TwrpGDCBase.CreateViewFormNewInstance(const AnOwner: IgsComponent;
  const AClassName, ASubType: WideString; ANewInstance: WordBool): IgsForm;
begin
  Result := GetGdcOLEObject(GetGDCBase.CreateViewForm(
    InterfaceToObject(AnOwner) as TComponent, AClassName, ASubType, ANewInstance)) as IgsForm;
end;

class function TwrpGDCBase.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := nil;
  if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 1) then
    Result := CgdcBase(DelphiClass).CreateSubType(InterfaceToObject(Params[0]) as TComponent,
      TgdcSubType(Params[1]))
  else
    if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 2) then
      Result := CgdcBase(DelphiClass).CreateSubType(InterfaceToObject(Params[0]) as TComponent,
        TgdcSubType(Params[1]), TgdcSubSet(PArams[2]))
    else
      ErrorParamsCount('2 или 3');
end;

function TwrpGDCBase.Get_SQLSetup: IgsAtSQLSetup;
begin
  Result := GetGdcOLEObject(GetGDCBase.SQLSetup) as IgsAtSQLSetup
end;

function TwrpGDCBase.FindFieldByRelation(const ARelationName,
  AFieldName: WideString): IgsField;
begin
  Result := GetGdcOLEObject(GetGDCBase.FindField(ARelationName, AFieldName)) As IgsField;
end;

function TwrpGDCBase.CreateDialogSubType(const AClassName,
  ASubType: WideString): WordBool;
var
  C: TPersistentClass;
  F: TgdcFullClass;
begin
  C := FindClass(AClassName);
  if not C.InheritsFrom(TgdcBase) then
    raise Exception.Create('Класс ' + AClassName + ' должен быть наследован от TgdcBase!');
  F.gdClass := CgdcBase(C);
  F.SubType := ASubType;
  Result := GetGDCBase.CreateDialog(F);    
end;

function TwrpGDCBase.ChooseOrderItems(const Cl: WideString;
  const KA: IgsGDKeyArray; var AChosenIDInOrder: OleVariant;
  const ChooseComponentName, ChooseSubSet, ChooseSubType,
  ChooseExtraConditions: WideString): WordBool;
var
  CE: TgdClassEntry;
begin
  CE := gdClassList.Find(Cl);
  if CE is TgdBaseEntry then
    Result := GetGDCBase.ChooseItems(TgdBaseEntry(CE).gdcClass, InterfaceToObject(KA) as TgdKeyArray,
      AChosenIDInOrder, ChooseComponentName, ChooseSubSet, ChooseSubType, ChooseExtraConditions)
  else
    Result := False;
end;

function TwrpGDCBase.ChooseOrderItemsSelf(
  var AChosenIDInOrder: OleVariant; const ChooseComponentName,
  ChooseSubSet,
  ChooseExtraConditions: WideString): WordBool;
begin
  Result := GetGDCBase.ChooseItems(AChosenIDInOrder, ChooseComponentName,
    ChooseSubSet, ChooseExtraConditions);
end;

procedure TwrpGDCBase.SaveToFile2(const AFileName: WideString;
  const ADetail: IgsGDCBase; const BL: IgsBookmarkList;
  OnlyCurrent: WordBool);
begin
  GetGDCBase.SaveToFile(AFileName, InterfaceToObject(ADetail) as TGDCBase, InterfaceToObject(BL) as TBookmarkList, OnlyCurrent);
end;

procedure TwrpGDCBase.LoadDialogDefaults;
begin
  GetGDCBase.LoadDialogDefaults;
end;

procedure TwrpGDCBase.SaveDialogDefaults;
begin
  GetGDCBase.SaveDialogDefaults;
end;

function TwrpGDCBase.GetDlgForm: IgsForm;
begin
  Result := GetGdcOLEObject(GetGDCBase.GetDlgForm) as IgsForm;
end;

function TwrpGDCBase.Get_StreamProcessingAnswer: Word;
begin
  Result := GetGDCBase.StreamProcessingAnswer;
end;

procedure TwrpGDCBase.Set_StreamProcessingAnswer(Value: Word);
begin
  if Value <= mrYesToAll then
    GetGDCBase.StreamProcessingAnswer := Value
  else
    raise Exception.Create(Format('Unknown value of StreamProcessingAnswer (%d)', [Value]));
end;

function TwrpGDCBase.Get_StreamSilentProcessing: WordBool;
begin
  Result := GetGDCBase.StreamSilentProcessing;
end;

procedure TwrpGDCBase.Set_StreamSilentProcessing(Value: WordBool);
begin
  GetGDCBase.StreamSilentProcessing := Value;
end;

procedure TwrpGDCBase.CopyObject(AWithDetail, AShowDialog: WordBool);
begin
  GetGDCBase.CopyObject(AWithDetail, AShowDialog);
end;

function TwrpGDCBase.Get_CopiedObjectKey: Integer;
begin
  Result := GetGDCBase.CopiedObjectKey;
end;

function TwrpGDCBase.CheckSubType(const ASubType: WideString): WordBool;
begin
  Result := GetGDCBase.CheckSubType(ASubType);
end;

function TwrpGDCBase.ClassInheritsFrom(const AClassName,
  ASubType: WideString): WordBool;
begin
  Result := GetGDCBase.ClassInheritsFrom(AClassName, ASubType);
end;

function TwrpGDCBase.CurrRecordInheritsFrom(const AClassName,
  ASubType: WideString): WordBool;
begin
  Result := GetGDCBase.CurrRecordInheritsFrom(AClassName, ASubType);
end;

{ TwrpGDCClassList }

function  TwrpGDCClassList.AddObject(const AClassName: WideString;
  const AScriptName: WideString; const ASubType: WideString;
  const ATransaction: IgsIBTransaction): Integer; safecall;
var
  Cl: TPersistentClass;
  gdcBaseClass: CgdcBase;
  gdcObject: TgdcBase;
begin
  Result := GetIndexObjectByName(AScriptName);

  if Result > -1 then
    exit;

  try
    Cl := GetClass(AClassName);
    gdcBaseClass := CgdcBase(Cl);

    if Assigned(gdcBaseClass) then
    begin
      gdcObject := gdcBaseClass.CreateSubType(Application, ASubType);
      Result := gdcObjectList.IndexOf(gdcObject);
      gdcObject.NameInScript := AScriptName;
    end;
  except
    raise Exception.Create('Ошибка при создании объекта типа ' + AClassName);
  end;
end;

function TwrpGDCClassList.GetObject(const AScriptName: WideString): IgsGDCBase; safecall;
begin
  if GetIndexObjectByName(AScriptName) > -1 then
    Result := GetGdcOLEObject(gdcObjectList.Items[GetIndexObjectByName(AScriptName)]) as IgsGDCBase
  else
    Result := nil;
end;

function TwrpGDCClassList.GetIndexObjectByName(AScriptName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to gdcObjectList.Count - 1 do
    if (gdcObjectList.Items[I] is TgdcBase) and
        AnsiSameText((gdcObjectList.Items[I] as TgdcBase).NameInScript, AScriptName) then
    begin
      Result := I;
      break;
    end;
end;

function TwrpGDCClassList.DeleteObject(const AScriptName: WideString): WordBool; safecall;
begin
  Result := DeleteObjectByIndex(GetIndexObjectByName(AScriptName));
end;

function TwrpGDCClassList.DeleteObjectByIndex(
  AnIndex: Integer): WordBool;
var
  P: TObject;
begin
  if (-1 < AnIndex) and (AnIndex < gdcObjectList.Count) then
  begin
    P := gdcObjectList[AnIndex];
    gdcObjectList.Delete(AnIndex);
    P.Free;
    Result := True;
  end else
    Result := False;
end;

function TwrpGDCClassList.GetObjectByIndex(AnIndex: Integer): IgsGDCBase;
begin
  if (-1 < AnIndex) and (AnIndex < gdcObjectList.Count) then
    Result := GetGdcOLEObject(gdcObjectList.Items[AnIndex]) as IgsGDCBase
  else
    Result := nil;
end;

function TwrpGDCClassList.Get_Count: Integer;
begin
  Result := gdcObjectList.Count;
end;

{ TwrpCreateableForm }

function TwrpCreateableForm.CreateAndAssign(
  const AnOwner: IgsComponent): IgsForm;
begin
  Result := GetGdcOLEObject(GetCreateableForm.CreateAndAssign(
    InterfaceToObject(AnOwner) as TComponent)) as IgsForm;
end;

procedure TwrpCreateableForm.DoCreate;
begin
  TCrackCreateableForm(GetCreateableForm).DoCreate;
end;

procedure TwrpCreateableForm.DoDestroy;
begin
  TCrackCreateableForm(GetCreateableForm).DoDestroy;
end;

procedure TwrpCreateableForm.DoHide;
begin
  TCrackCreateableForm(GetCreateableForm).DoHide;
end;

function TwrpCreateableForm.FormAssigned(
  const F: IgsCreateableForm): WordBool;
begin
  Result := GetCreateableForm.FormAssigned(InterfaceToObject(F) as TCreateableForm);
end;

function TwrpCreateableForm.Get_SelectedKey: OleVariant;
begin
  Result := TCrackCreateableForm(GetCreateableForm).Get_SelectedKey;
end;

function TwrpCreateableForm.Get_WindowQuery: IgsQueryList;
var
  FLocalQuery: TgsQueryList;
  I: Integer;
begin
  Result := TCrackCreateableForm(GetCreateableForm).Get_WindowQuery;

  if Result <> nil then
    Exit;

  FLocalQuery := TgsQueryList.Create(gdcBaseManager.Database, nil, True);
  try
    for I := 0 to GetCreateableForm.ComponentCount - 1 do
    begin
      if (GetCreateableForm.Components[I] is TIBCustomDataSet) and not (GetCreateableForm.Components[I] is TIBTable) then
        FLocalQuery.AddRealQuery(TgsRealDataSet.Create((GetCreateableForm.Components[I] as TIBCustomDataSet)));
      if (GetCreateableForm.Components[I] is TClientDataSet) then
        FLocalQuery.AddRealQuery(TgsRealDataSet.Create((GetCreateableForm.Components[I] as TClientDataSet)));
    end;
    Result := FLocalQuery;
  except
    FLocalQuery.Free;
  end;
end;

function TwrpCreateableForm.GetCreateableForm: TCreateableForm;
begin
  Result := GetObject as TCreateableForm;
end;

procedure TwrpCreateableForm.LoadDesktopSettings;
begin
  GetCreateableForm.LoadDesktopSettings;
end;

procedure TwrpCreateableForm.LoadSettings;
begin
  GetCreateableForm.LoadSettings;
end;

procedure TwrpCreateableForm.LoadSettingsAfterCreate;
begin
  GetCreateableForm.LoadSettingsAfterCreate;
end;

procedure TwrpCreateableForm.SaveDesktopSettings;
begin
  GetCreateableForm.SaveDesktopSettings;
end;

procedure TwrpCreateableForm.SaveSettings;
begin
  GetCreateableForm.SaveSettings;
end;

procedure TwrpCreateableForm.Setup(const AnObject: IgsObject);
begin
  GetCreateableForm.Setup(InterfaceToObject(AnObject) as TObject);
end;

constructor TwrpCreateableForm.Create(AnForm: TComponent; const TypeLib: ITypeLib;
  const DispIntf: TGUID);
begin
  Assert(Assigned(AnForm));

  inherited Create(AnForm, TypeLib, DispIntf);

end;

destructor TwrpCreateableForm.Destroy;
begin

  inherited;
end;

function TwrpCreateableForm.InitialName: WideString;
begin
  Result := GetCreateableForm.InitialName;
end;

function TwrpCreateableForm.Get_Variables(const Name: WideString): OleVariant;
begin
  Result := TCrackCreateableForm(GetCreateableForm).Variables[Name];
end;

procedure TwrpCreateableForm.Set_Variables(const Name: WideString; Value: OleVariant);
begin
  TCrackCreateableForm(GetCreateableForm).Variables[Name] := Value;
end;

procedure TwrpCreateableForm.AddVariableItem(const Name: WideString);
begin
  TCrackCreateableForm(GetCreateableForm).AddVariableItem(Name);
end;

procedure TwrpCreateableForm.AddObjectItem(const Name: WideString);
begin
  TCrackCreateableForm(GetCreateableForm).AddObjectItem(Name);
end;

function TwrpCreateableForm.Get_Objects(const Name: WideString): IDispatch;
begin
  Result := TCrackCreateableForm(GetCreateableForm).Objects[Name];
end;

procedure TwrpCreateableForm.Set_Objects(const Name: WideString;
  const Value: IDispatch);
begin
  TCrackCreateableForm(GetCreateableForm).Objects[Name] := Value;
end;

procedure TwrpCreateableForm.SetFocusOnComponent(
  const AComponentName: WideString);
begin
  GetCreateableForm.SetFocusOnComponent(AComponentName);
end;

function TwrpCreateableForm.Get_ShowSpeedButton: WordBool;
begin
  Result := GetCreateableForm.ShowSpeedButton;
end;

procedure TwrpCreateableForm.Set_ShowSpeedButton(Value: WordBool);
begin
  GetCreateableForm.ShowSpeedButton := Value;
end;

function TwrpCreateableForm.Get_UseDesigner: WordBool;
begin
  Result := GetCreateableForm.UseDesigner;
end;

procedure TwrpCreateableForm.Set_UseDesigner(Value: WordBool);
begin
  GetCreateableForm.UseDesigner := Value;
end;

function TwrpCreateableForm.ObjectExists(const Name: WideString): WordBool;
begin
  Result := TCrackCreateableForm(GetCreateableForm).ObjectExists(Name);
end;

function TwrpCreateableForm.VariableExists(
  const Name: WideString): WordBool;
begin
  Result := TCrackCreateableForm(GetCreateableForm).VariableExists(Name);
end;

function TwrpCreateableForm.Get_Caption_: WideString;
begin
  Result := TCrackCreateableForm(GetCreateableForm).Caption;
end;

procedure TwrpCreateableForm.Set_Caption_(const Value: WideString);
begin
  TCrackCreateableForm(GetCreateableForm).Caption := Value;
end;

{ TwrpGDKeyArray }

function TwrpGDKeyArray.Add(InValue: Integer): Integer;
begin
  Result := GetGDKeyArray.Add(InValue);
end;

procedure TwrpGDKeyArray.Delete(Index: Integer);
begin
  GetGDKeyArray.Delete(Index);
end;

function TwrpGDKeyArray.Find(InValue: Integer;
  out Index: OleVariant): WordBool;
var
  i: Integer;
begin
  i := Integer(Index);
  Result := GetGDKeyArray.Find(InValue, I);
  Index := i
end;

function TwrpGDKeyArray.Get_Count: Integer;
begin
  Result := GetGDKeyArray.Count;
end;

function TwrpGDKeyArray.Get_Keys(Index: Integer): Integer;
begin
  Result := GetGDKeyArray.Keys[Index];
end;

function TwrpGDKeyArray.Get_Size: Integer;
begin
  Result := GetGDKeyArray.Size;
end;

function TwrpGDKeyArray.GetGDKeyArray: TGDKeyArray;
begin
  Result := GetObject as TgdKeyArray;
end;

function TwrpGDKeyArray.IndexOf(InValue: Integer): Integer;
begin
  Result := GetGDKeyArray.IndexOf(InValue);
end;

function TwrpGDKeyArray.Remove(InValue: Integer): Integer;
begin
  Result := GetGDKeyArray.Remove(InValue);
end;

procedure TwrpGDKeyArray.Clear;
begin
  GetGDKeyArray.Clear;
end;

procedure TwrpGDKeyArray.Assign_(const KA: IgsGDKeyArray);
begin
  GetGDKeyArray.Assign(InterfaceToObject(KA) as TgdKeyArray);
end;

procedure TwrpGDKeyArray.Extract(const KA: IgsGDKeyArray);
begin
  GetGDKeyArray.Extract(InterfaceToObject(KA) as TgdKeyArray);
end;

procedure TwrpGDKeyArray.LoadFromStream(const S: IgsStream);
begin
  GetGDKeyArray.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGDKeyArray.SaveToStream(const S: IgsStream);
begin
  GetGDKeyArray.SaveToStream(InterfaceToObject(S) as TStream);
end;

function TwrpGDKeyArray.CommaText: WideString;
begin
  Result := GetGDKeyArray.CommaText;
end;

class function TwrpGDKeyArray.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyArray), 'Invalide Delphi class');
  Result := TgdKeyArray.Create;
end;

{ TwrpGDCInvBaseRemains }

function TwrpGDCInvBaseRemains.Get_CurrentRemains: WordBool;
begin
  Result := GetGDCInvBaseRemains.CurrentRemains;
end;

function TwrpGDCInvBaseRemains.Get_RemainsDate: TDateTime;
begin
  Result := GetGDCInvBaseRemains.RemainsDate;
end;

function TwrpGDCInvBaseRemains.Get_RemainsSQLType: TgsInvRemainsSQLType;
begin
  Result := TgsInvRemainsSQLType(GetGDCInvBaseRemains.RemainsSQLType);
end;

function TwrpGDCInvBaseRemains.Get_ViewFeatures: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGDCInvBaseRemains.ViewFeatures) as IgsStringList;
end;

function TwrpGDCInvBaseRemains.GetGDCInvBaseRemains: TgdcInvBaseRemains;
begin
  Result := GetObject as TgdcInvBaseRemains;
end;

function TwrpGDCInvBaseRemains.GetOriginalSQL: WideString;
begin
  Result := '';
end;

procedure TwrpGDCInvBaseRemains.Set_CurrentRemains(Value: WordBool);
begin
  GetGDCInvBaseRemains.CurrentRemains := Value;
end;

procedure TwrpGDCInvBaseRemains.Set_RemainsDate(Value: TDateTime);
begin
  GetGDCInvBaseRemains.RemainsDate := Value;
end;

procedure TwrpGDCInvBaseRemains.Set_RemainsSQLType(
  Value: TgsInvRemainsSQLType);
begin
  GetGDCInvBaseRemains.RemainsSQLType := TInvRemainsSQLType(Value);
end;

procedure TwrpGDCInvBaseRemains.Set_ViewFeatures(
  const Value: IgsStringList);
begin
  GetGDCInvBaseRemains.ViewFeatures := InterfaceToObject(Value) as TStringList;
end;

function TwrpGDCInvBaseRemains.Get_IsMinusRemains: WordBool;
begin
  Result := GetGDCInvBaseRemains.IsMinusRemains;
end;

procedure TwrpGDCInvBaseRemains.Set_IsMinusRemains(Value: WordBool);
begin
  GetGDCInvBaseRemains.IsMinusRemains := Value;
end;

{ TwrpgsDBReduction }

function TwrpgsDBReduction.Get_CondemnedKey: WideString;
begin
  Result := GetgsDBReduction.CondemnedKey;
end;

function TwrpgsDBReduction.Get_KeyField: WideString;
begin
  Result := GetgsDBReduction.KeyField;
end;

function TwrpgsDBReduction.Get_MasterKey: WideString;
begin
  Result := GetgsDBReduction.MasterKey;
end;

function TwrpgsDBReduction.Get_Table: WideString;
begin
  Result := GetgsDBReduction.Table;
end;

function TwrpgsDBReduction.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetgsDBReduction.Transaction) as IgsIBTransaction;
end;

function TwrpgsDBReduction.Get_TransferData: WordBool;
begin
  Result := GetgsDBReduction.TransferData;
end;

function TwrpgsDBReduction.GetgsDBReduction: TgsDBReduction;
begin
  Result := GetObject as TgsDBReduction;
end;

function TwrpgsDBReduction.GetPrimary(
  const TableName: WideString): WideString;
begin
  Result := GetgsDBReduction.GetPrimary(TableName);
end;

function TwrpgsDBReduction.MakeReduction: WordBool;
begin
  Result := GetgsDBReduction.MakeReduction;
end;

function TwrpgsDBReduction.Prepare: WordBool;
begin
  Result := GetgsDBReduction.Prepare;
end;

procedure TwrpgsDBReduction.Reduce;
begin
  GetgsDBReduction.Reduce;
end;

procedure TwrpgsDBReduction.Set_CondemnedKey(const Value: WideString);
begin
  GetgsDBReduction.CondemnedKey := Value;
end;

procedure TwrpgsDBReduction.Set_MasterKey(const Value: WideString);
begin
  GetgsDBReduction.MasterKey := Value;
end;

procedure TwrpgsDBReduction.Set_Table(const Value: WideString);
begin
  GetgsDBReduction.Table := Value;
end;

procedure TwrpgsDBReduction.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetgsDBReduction.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpgsDBReduction.Set_TransferData(Value: WordBool);
begin
  GetgsDBReduction.TransferData := Value;
end;

function TwrpgsDBReduction.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetgsDBReduction.Database) as IgsIBDatabase;
end;

function TwrpgsDBReduction.Get_MainTable: WideString;
begin
  Result := GetgsDBReduction.MainTable;
end;

function TwrpgsDBReduction.Get_ReductionTable: IgsReductionTable;
begin
  Result := GetGdcOLEObject(GetgsDBReduction.ReductionTable) as IgsReductionTable;
end;

procedure TwrpgsDBReduction.Set_Database(const Value: IgsIBDatabase);
begin
  GetgsDBReduction.Database :=  InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpgsDBReduction.Set_MainTable(const Value: WideString);
begin
  GetgsDBReduction.MainTable := Value;
end;

procedure TwrpgsDBReduction.Set_ReductionTable(
  const Value: IgsReductionTable);
begin
  GetgsDBReduction.ReductionTable := InterfaceToObject(Value) as TReductionTable;
end;

procedure TwrpgsDBReduction.Set_KeyField(const Value: WideString);
begin
  GetgsDBReduction.KeyField := Value;
end;

function TwrpgsDBReduction.Get_IgnoryQuestion: WordBool;
begin
  Result := GetgsDBReduction.IgnoryQuestion;
end;

procedure TwrpgsDBReduction.Set_IgnoryQuestion(Value: WordBool);
begin
  GetgsDBReduction.IgnoryQuestion := Value;
end;

{ TwrpgsDBReductionWizard }

function TwrpgsDBReductionWizard.Get_Condition: WideString;
begin
  Result := GetgsDBReductionWizard.Condition;
end;

function TwrpgsDBReductionWizard.Get_HideFields: WideString;
begin
  Result := GetgsDBReductionWizard.HideFields;
end;

function TwrpgsDBReductionWizard.Get_ListField: WideString;
begin
  Result := GetgsDBReductionWizard.ListField;
end;

function TwrpgsDBReductionWizard.GetgsDBReductionWizard: TgsDBReductionWizard;
begin
  Result := GetObject as TgsDBReductionWizard;
end;

procedure TwrpgsDBReductionWizard.Set_Condition(const Value: WideString);
begin
  GetgsDBReductionWizard.Condition := Value;
end;

procedure TwrpgsDBReductionWizard.Set_HideFields(const Value: WideString);
begin
  GetgsDBReductionWizard.HideFields := Value;
end;

procedure TwrpgsDBReductionWizard.Set_ListField(const Value: WideString);
begin
  GetgsDBReductionWizard.ListField := Value;
end;

function TwrpgsDBReductionWizard.Wizard(const AClassName,
  ASubType: WideString): WordBool;
begin
  Result := GetgsDBReductionWizard.Wizard(AClassName, ASubType);
end;

function TwrpgsDBReductionWizard.Get_AddCondition: WideString;
begin
  Result := GetgsDBReductionWizard.AddCondition;
end;

procedure TwrpgsDBReductionWizard.Set_AddCondition(
  const Value: WideString);
begin
  GetgsDBReductionWizard.AddCondition := Value;
end;

{ TwrpXDBCalculatorEdit }

function TwrpXDBCalculatorEdit.Get_DataField: WideString;
begin
  Result := GetXDBCalculatorEdit.DataField;
end;

function TwrpXDBCalculatorEdit.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetXDBCalculatorEdit.DataSource) as IgsDataSource;
end;

function TwrpXDBCalculatorEdit.Get_DecDigits: Word;
begin
  Result := GetXDBCalculatorEdit.DecDigits;
end;

function TwrpXDBCalculatorEdit.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetXDBCalculatorEdit.Field) as IgsFieldComponent;
end;

function TwrpXDBCalculatorEdit.Get_Value: Double;
begin
  Result := GetXDBCalculatorEdit.Value;
end;

function TwrpXDBCalculatorEdit.GetXDBCalculatorEdit: TxDBCalculatorEdit;
begin
  Result := GetObject as TxDBCalculatorEdit;
end;

procedure TwrpXDBCalculatorEdit.Set_DataField(const Value: WideString);
begin
  GetXDBCalculatorEdit.DataField := Value;
end;

procedure TwrpXDBCalculatorEdit.Set_DataSource(const Value: IgsDataSource);
begin
  GetXDBCalculatorEdit.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpXDBCalculatorEdit.Set_DecDigits(Value: Word);
begin
  GetXDBCalculatorEdit.DecDigits := Value;
end;

procedure TwrpXDBCalculatorEdit.Set_Value(Value: Double);
begin
  GetXDBCalculatorEdit.Value := Value;
end;

{ TwrpGDCTree }

function TwrpGDCTree.CreateChildrenDialog: WordBool;
begin
  Result := GetGDCTree.CreateChildrenDialog;
end;

function TwrpGDCTree.Get_Parent: Integer;
begin
  Result := GetGDCTree.Parent;
end;

function TwrpGDCTree.GetCopyFieldName: WideString;
begin
  Result := '';
  //Result := GetGDCTree.GetCopyFieldName;
end;

function TwrpGDCTree.GetGDCTree: TgdcTree;
begin
  Result := GetObject as TgdcTree;
end;

function TwrpGDCTree.GetParentField(
  const ASubType: WideString): WideString;
begin
  Result := GetGDCTree.GetParentField(ASubType);
end;

function TwrpGDCTree.GetParentObject: IgsGDCTree;
begin
  Result := GetGDCOleObject(GetGDCTree.GetParentObject) as IgsGDCTree;
end;

function TwrpGDCTree.HasLeafs: WordBool;
begin
  Result := GetGDCTree.HasLeafs;
end;

procedure TwrpGDCTree.InsertChildren;
begin
  GetGDCTree.InsertChildren;
end;

function TwrpGDCTree.IsAbstractClass: WordBool;
begin
  Result := GetGDCTree.IsAbstractClass;
end;

procedure TwrpGDCTree.Propagate(const AFields: WideString;
  AnOnlyFirstLevel: WordBool);
begin
  GetGDCTree.Propagate(AFields, AnOnlyFirstLevel);
end;

procedure TwrpGDCTree.Set_Parent(Value: Integer);
begin
  GetGDCTree.Parent := Value;
end;

function TwrpGDCTree.CreateChildrenDialogWithParam(
  const AgdcClassName: WideString): WordBool;
var
  CE: TgdClassEntry;
begin
  CE := gdClassList.Get(TgdBaseEntry, AgdcClassName);
  Result := GetGDCTree.CreateChildrenDialog(TgdBaseEntry(CE).gdcClass);
end;

{ TwrpGDCDocument }

function TwrpGDCDocument.DocumentTypeKey: Integer;
begin
  Result := GetGDCDocument.DocumentTypeKey;
end;

function TwrpGDCDocument.Get_DocumentDescription(
  ReadNow: WordBool): WideString;
begin
  Result := GetGDCDocument.DocumentDescription;
end;

function TwrpGDCDocument.Get_DocumentName(ReadNow: WordBool): WideString;
begin
  Result := GetGDCDocument.DocumentName;
end;

function TwrpGDCDocument.GetDocumentClassPart: TgsGDCDocumentClassPart;
begin
  Result := TgsGDCDocumentClassPart(GetGDCDocument.GetDocumentClassPart);
end;

function TwrpGDCDocument.GetGDCDocument: TgdcDocument;
begin
  Result := GetObject as TgdcDocument;
end;

procedure TwrpGDCDocument.CreateEntry;
begin
  GetGDCDocument.CreateEntry;
end;

function TwrpGDCDocument.Get_gdcAcctEntryRegister: IgsGDCBase;
begin
  Result := GetGDCOLEObject(GetGDCDocument.gdcAcctEntryRegister) as IgsGDCBase;
end;

function TwrpGDCDocument.Get_RelationLineName: WideString;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, dcpLine);
  if DE <> nil then
    Result := DE.LineRelName
  else
    Result := '';
end;

function TwrpGDCDocument.Get_RelationName: WideString;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, dcpHeader);
  if DE <> nil then
    Result := DE.HeaderRelName
  else
    Result := '';
end;

{ TwrpGdcLBRBTree }

function TwrpGdcLBRBTree.Get_LB: Integer;
begin
  Result := GetGdcLBRBTree.LB;
end;

function TwrpGdcLBRBTree.Get_RB: Integer;
begin
  Result := GetGdcLBRBTree.RB;
end;

function TwrpGdcLBRBTree.GetGdcLBRBTree: TgdcLBRBTree;
begin
  Result := GetObject as TgdcLBRBTree;
end;

procedure TwrpGdcLBRBTree.Set_LB(Value: Integer);
begin
  GetGdcLBRBTree.LB := Value;
end;

procedure TwrpGdcLBRBTree.Set_RB(Value: Integer);
begin
  GetGdcLBRBTree.RB := Value;
end;

{ TwrpGdcBaseDocumentType }

function TwrpGdcBaseDocumentType.GetGdcBaseDocumentType: TgdcBaseDocumentType;
begin
  Result := GetObject as TgdcBaseDocumentType;
end;

function TwrpGdcBaseDocumentType.UpdateReportGroup(const MainBranchName,
  DocumentName: WideString; var GroupKey: OleVariant;
  ShouldUpdateData: WordBool): WordBool;
var
  gk: Integer;
begin
  gk := GroupKey;
  Result := GetGdcBaseDocumentType.UpdateReportGroup(MainBranchName, DocumentName, GK, ShouldUpdateData);
  GroupKey := gk;
end;

{ TwrpGdcUserDocumentType }

function TwrpGdcUserDocumentType.Get_BranchKey: Integer;
begin
  Result := -1;
//  Result := GetGdcUserDocumentType.BranchKey;
end;

function TwrpGdcUserDocumentType.Get_DocLineRelationName: WideString;
begin
  Result := GetGdcUserDocumentType.DocLineRelationName;
end;

function TwrpGdcUserDocumentType.Get_DocRelationName: WideString;
begin
  Result := GetGdcUserDocumentType.DocRelationName;
end;

function TwrpGdcUserDocumentType.Get_IsComplexDocument: WordBool;
begin
  Result := GetGdcUserDocumentType.IsComplexDocument;
end;

function TwrpGdcUserDocumentType.Get_MainBranchKey: Integer;
begin
  Result := -1;
 // Result := GetGdcUserDocumentType.MainBranchKey;
end;

function TwrpGdcUserDocumentType.GetGdcUserDocumentType: TgdcUserDocumentType;
begin
  Result := GetObject as TgdcUserDocumentType;
end;

procedure TwrpGdcUserDocumentType.ReadOptions;
begin
  //GetGdcUserDocumentType.ReadOptions;
end;

procedure TwrpGdcUserDocumentType.Set_BranchKey(Value: Integer);
begin
//  GetGdcUserDocumentType.BranchKey := Value;
end;

{ TwrpGdcUserBaseDocument }

function TwrpGdcUserBaseDocument.EnumRelationFields(const RelationName,
  AliasName: WideString; UseDot: WordBool): WideString;
begin
  Result := TCrackGdcUserBaseDocument(GetGdcUserBaseDocument).EnumRelationFields(
    RelationName, AliasName, UseDot)
end;

function TwrpGdcUserBaseDocument.Get_Relation: WideString;
begin
  Result := Get_RelationName;
end;

function TwrpGdcUserBaseDocument.Get_RelationLine: WideString;
begin
  Result := Get_RelationLineName;
end;

function TwrpGdcUserBaseDocument.GetGdcUserBaseDocument: TgdcUserBaseDocument;
begin
  Result := GetObject as TgdcUserBaseDocument;
end;

function TwrpGdcUserBaseDocument.GetGroupID: Integer;
begin
  Result := TCrackGdcUserBaseDocument(GetGdcUserBaseDocument).GetGroupID;
end;

procedure TwrpGdcUserBaseDocument.ReadOptions(aDocumentTypeKey: Integer);
begin
  //GetGdcUserBaseDocument.ReadOptions(aDocumentTypeKey);
end;

{ TwrpGdcReport }

function TwrpGdcReport.CheckReport(const AName: WideString; ReportGroupKey: Integer): WordBool;
begin
  Result := GetGdcReport.CheckReport(AName, ReportGroupKey);
end;

function TwrpGdcReport.Get_LastInsertID: Integer;
begin
  Result := GetGdcReport.LastInsertID;
end;

function TwrpGdcReport.GetGdcReport: TgdcReport;
begin
  Result := GetObject as TgdcReport;
end;

function TwrpGdcReport.GetUniqueName(const PrefName,
  Name: WideString; ReportGroupKey: Integer): WideString;
begin
  Result := GetGdcReport.GetUniqueName(PrefName, Name, ReportGroupKey);
end;

{ TwrpGdcDelphiObject }

function TwrpGdcDelphiObject.AddObject(
  const AComponent: IgsComponent): Integer;
begin
  Result := TgdcDelphiObject.AddObject(InterfaceToObject(AComponent) as TComponent);
end;

function TwrpGdcDelphiObject.GetGdcDelphiObject: TgdcDelphiObject;
begin
  Result := GetObject as TgdcDelphiObject;
end;

function TwrpGdcDelphiObject.NeedModifyFromStream(
  const SubType: WideString): WordBool;
begin
  Result := GetGdcDelphiObject.NeedModifyFromStream(SubType);
end;

{ TwrpGdcMacros }

function TwrpGdcMacros.CheckMacros(const AName: WideString; MacrosGroupKey: Integer): WordBool;
begin
  Result := GetGdcMacros.CheckMacros(AName, MacrosGroupKey);
end;

function TwrpGdcMacros.Get_LastInsertID: Integer;
begin
  Result := GetGdcMacros.LastInsertID;
end;

function TwrpGdcMacros.GetGdcMacros: TgdcMacros;
begin
  Result := GetObject as TgdcMacros;
end;

function TwrpGdcMacros.GetUniqueName(const PrefName,
  Name: WideString; MacrosGroupKey: Integer): WideString;
begin
  Result := GetGdcMacros.GetUniqueName(PrefName, Name, MacrosGroupKey);
end;

{ TwrpGdcConst }

function TwrpGdcConst.GetGdcConst: TgdcConst;
begin
  Result := GetObject as TgdcConst;
end;

function TwrpGdcConst.isCompany: WordBool;
begin
  Result := GetGdcConst.isCompany;
end;

function TwrpGdcConst.isPeriod: WordBool;
begin
  Result := GetGdcConst.isPeriod;
end;

function TwrpGdcConst.isUser: WordBool;
begin
  Result := GetGdcConst.isUser;
end;

{ TwrpGdcConstValue }
{
function TwrpGdcConstValue.Get_ConstKey: Integer;
begin
  Result := GetGdcConstValue.ConstKey;
end;

function TwrpGdcConstValue.Get_ConstType: Integer;
begin
  Result := GetGdcConstValue.ConstType;
end;

function TwrpGdcConstValue.GetGdcConstValue: TgdcConstValue;
begin
  Result := GetObject as  TgdcConstValue;
end;

procedure TwrpGdcConstValue.Set_ConstKey(Value: Integer);
begin
  GetGdcConstValue.ConstKey := Value;
end;

procedure TwrpGdcConstValue.Set_ConstType(Value: Integer);
begin
  GetGdcConstValue.ConstType := Value;
end;
 }
function TwrpGdcConst.QGetValueByID(AnID: Integer): OleVariant;
begin
  Result := GetGdcConst.QGetValueByID(AnID);
end;

function TwrpGdcConst.QGetValueByID2(AnID: Integer; ADate: TDateTime;
  AUserKey, ACompanyKey: Integer): OleVariant;
begin
  Result := GetGdcConst.QGetValueByID2(AnID, ADate, AUserKey, ACompanyKey);
end;

function TwrpGdcConst.QGetValueByIDAndDate(AnID: Integer;
  ADate: TDateTime): OleVariant;
begin
  Result := GetGdcConst.QGetValueByIDAndDate(AnID, ADate);
end;

function TwrpGdcConst.QGetValueByName(const AName: WideString): OleVariant;
begin
  Result := GetGdcConst.QGetValueByName(AName);
end;

function TwrpGdcConst.QGetValueByName2(const AName: WideString;
  ADate: TDateTime; AUserKey, ACompanyKey: Integer): OleVariant;
begin
  Result := GetGdcConst.QGetValueByName2(AName, ADate, AUserKey, ACompanyKey);
end;

function TwrpGdcConst.QGetValueByNameAndDate(const AName: WideString;
  ADate: TDateTime): OleVariant;
begin
  Result := GetGdcConst.QGetValueByNameAndDate(AName, ADate);
end;

{ TwrpGdcLink }

{
function TwrpGdcLink.Get_ObjectKey: Integer;
begin
  Result := GetGdcLink.ObjectKey;
end;

function TwrpGdcLink.GetGdcLink: TgdcLink;
begin
  Result := GetObject as TgdcLink;
end;

procedure TwrpGdcLink.Set_ObjectKey(Value: Integer);
begin
  GetGdcLink.ObjectKey := Value;
end;

function TwrpGdcLink.CreateViewFormForObject(const AnOwner: IgsComponent;
  const AnObject: IgsGDCBase): IgsForm;
begin
  Result := GetGdcOLEObject(GetGdcLink.CreateViewFormForObject(
    InterfaceToObject(AnOwner) as TComponent,
    InterfaceToObject(AnObject) as TgdcBase)) as IgsForm;
end;
}

{ TwrpGdcExplorer }

function TwrpGdcExplorer.CreateGdcInstance: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdcExplorer.CreateGdcInstance) as IgsGDCBase;
end;

function TwrpGdcExplorer.GetGdcExplorer: TgdcExplorer;
begin
  Result := GetObject as TgdcExplorer;
end;

function TwrpGdcExplorer.Get_gdcClass: WideString;
begin
  Result := GetGdcExplorer.gdcClass.ClassName;
end;

procedure TwrpGdcExplorer.ShowProgram;
begin
  GetGdcExplorer.ShowProgram;
end;

procedure TwrpGdcExplorer.ShowProgramWithParam(
  AlwaysCreateWindow: WordBool);
begin
  GetGdcExplorer.ShowProgram(AlwaysCreateWindow);
end;

{ TwrpGdcBaseContact }

function TwrpGdcBaseContact.ContactType: Integer;
begin
  Result := GetGdcBaseContact.ContactType;
end;

function TwrpGdcBaseContact.GetBankAttribute: WideString;
begin
  Result := GetGdcBaseContact.GetBankAttribute;
end;

function TwrpGdcBaseContact.GetGdcBaseContact: TgdcBaseContact;
begin
  Result := GetObject as TgdcBaseContact;
end;

{ TwrpGdcOurCompany }

procedure TwrpGdcOurCompany.SaveOurCompany(CompanyKey: Integer);
begin
//  GetGdcOurCompany.SaveOurCompany(CompanyKey);
  TgdcOurCompany.SaveOurCompany(CompanyKey);
end;

{ TwrpGdcAcctEntryDocument }

{function TwrpGdcAcctEntryDocument.Get_DocumentTypeKey: Integer;
begin
  Result := GetGdcAcctEntryDocument.DocumentTypeKey;
end;

function TwrpGdcAcctEntryDocument.GetGdcAcctEntryDocument: TgdcAcctEntryDocument;
begin
  Result := GetObject as TgdcAcctEntryDocument;
end;

procedure TwrpGdcAcctEntryDocument.Set_DocumentTypeKey(Value: Integer);
begin
  GetGdcAcctEntryDocument.DocumentTypeKey := Value;
end;}

{ TwrpGdcMetaBase }

function TwrpGdcMetaBase.Get_IsUserDefined: WordBool;
begin
  Result := GetGdcMetaBase.IsUserDefined;
end;

function TwrpGdcMetaBase.GetGdcMetaBase: TgdcMetaBase;
begin
  Result := GetObject as TgdcMetaBase;
end;

{ TwrpGdcField }

function TwrpGdcField.GetDomainText(isCharSet: WordBool; OnlyDataType: WordBool): WideString;
begin
  Result := GetGdcField.GetDomainText(isCharSet, OnlyDataType);
end;

function TwrpGdcField.GetGdcField: TgdcField;
begin
  GetGdcField := GetObject as TgdcField;
end;

{ TwrpGdcRelation }

function TwrpGdcRelation.Get_TableType: TgsGdcTableType;
begin
  Result := TgsGdcTableType(GetGdcRelation.TableType);
end;

function TwrpGdcRelation.GetGdcRelation: TgdcRelation;
begin
  Result := GetObject as TgdcRelation;
end;

{ TwrpGdcUser }

function TwrpGdcUser.CheckIBUser: WordBool;
begin
  Result := GetGdcUser.CheckIBUser;
end;

function TwrpGdcUser.CheckIBUserWithParam(const AUser,
  APassw: WideString): WordBool;
begin
  Result := GetGdcUser.CheckIBUser(AUser, APassw);
end;

function TwrpGdcUser.CheckUser(const AUserName: WideString): WordBool;
begin
  Result := GetGdcUser.CheckUser(AUserName);
end;

procedure TwrpGdcUser.CreateIBUser;
begin
  GetGdcUser.CreateIBUser;
end;

procedure TwrpGdcUser.DeleteIBUser;
begin
  GetGdcUser.DeleteIBUser;
end;

function TwrpGdcUser.Get_Groups: Integer;
begin
  Result := GetGdcUser.Groups;
end;

function TwrpGdcUser.GetGdcUser: TgdcUser;
begin
  Result := GetObject as TgdcUser;
end;

procedure TwrpGdcUser.ReCreateAllUsers;
begin
  GetGdcUser.ReCreateAllUsers;
end;

procedure TwrpGdcUser.Set_Groups(Value: Integer);
begin
  GetGdcUser.Groups := Value;
end;

procedure TwrpGdcUser.CheckIBUserCreate;
begin
  GetGdcUser.CheckIBUser;
end;

procedure TwrpGdcUser.CopySettings;
begin 
  GetGdcUser.CopySettings(InterfaceToObject(ibtr) as
    TIBTransaction);
end;

procedure TwrpGdcUser.CopySettingsByUser;
begin
  GetGdcUser.CopySettingsByUser(U, InterfaceToObject(ibtr) as
    TIBTransaction);
end;

{ TwrpGdcUserGroup }

procedure TwrpGdcUserGroup.AddUser(const AnUser: IgsGdcUser);
begin
  GetGdcUserGroup.AddUser(InterfaceToObject(AnUser) as TgdcUser);
end;

procedure TwrpGdcUserGroup.AddUserByID(AnID: Integer);
begin
  GetGdcUserGroup.AddUser(AnID);
end;

function TwrpGdcUserGroup.Get_Mask: Integer;
begin
  Result := GetGdcUserGroup.Mask;
end;

function TwrpGdcUserGroup.GetGdcUserGroup: TgdcUserGroup;
begin
  Result := GetObject as TgdcUserGroup;
end;

function TwrpGdcUserGroup.GetGroupMask: Integer;
begin
  Result := GetGdcUserGroup.GetGroupMask;
end;

function TwrpGdcUserGroup.GetGroupMaskByID(AGroupID: Integer): Integer;
begin
  Result := GetGdcUserGroup.GetGroupMask(AGroupID);
end;

procedure TwrpGdcUserGroup.RemoveUser(const AnUser: IgsGdcUser);
begin
  GetGdcUserGroup.RemoveUser(InterfaceToObject(AnUser) as TgdcUser);
end;

procedure TwrpGdcUserGroup.RemoveUserByID(AnID: Integer);
begin
  GetGdcUserGroup.RemoveUser(AnID);
end;

procedure TwrpGdcUserGroup.Set_Mask(Value: Integer);
begin
  GetGdcUserGroup.Mask := Value;
end;

{ TwrpGdcBaseOperation }

{procedure TwrpGdcBaseOperation.BuildClassTree;
begin
  GetGdcBaseOperation.BuildClassTree;
end;

function TwrpGdcBaseOperation.GetGdcBaseOperation: TgdcBaseOperation;
begin
  Result := GetObject as TgdcBaseOperation;
end;}

{ TwrpGdcGood }

function TwrpGdcGood.Get_GroupKey: Integer;
begin
  Result := GetGdcGood.GroupKey;
end;

function TwrpGdcGood.GetGdcGood: TgdcGood;
begin
  Result := GetObject as TgdcGood;
end;

procedure TwrpGdcGood.Set_GroupKey(Value: Integer);
begin
  GetGdcGood.GroupKey := Value;
end;

function TwrpGdcGood.GetTaxRateOnName(const TaxName: WideString;
  ForDate: TDateTime): OleVariant;
begin
  Result := GetGdcGood.GetTaxRateOnName(TaxName, ForDate);
end;

function TwrpGdcGood.GetTaxRate(TaxKey: Integer;
  ForDate: TDateTime): Currency;
begin
  Result := GetGdcGood.GetTaxRate(TaxKey, ForDate);
end;

function TwrpGdcGood.GetTaxRateByID(aID, TaxKey: Integer;
  ForDate: TDateTime): Currency;
begin
  Result := GetGdcGood.GetTaxRateByID(aID, TaxKey, ForDate);
end;

function TwrpGdcGood.GetTaxRateOnNameByID(aID: Integer;
  const TaxName: WideString; ForDate: TDateTime): Currency;
begin
  Result := GetGdcGood.GetTaxRateOnNameByID(aID, TaxName, ForDate);
end;

{ TwrpGdcInvBaseDocument }

function TwrpGdcInvBaseDocument.Get_CurrentStreamVersion: WideString;
begin
  Result := GetGdcInvBaseDocument.CurrentStreamVersion;
end;

function TwrpGdcInvBaseDocument.GetGdcInvBaseDocument: TgdcInvBaseDocument;
begin
  Result := GetObject as TgdcInvBaseDocument;
end;

function TwrpGdcInvBaseDocument.JoinListFieldByFieldName(const AFieldName,
  AAliasName, AJoinFieldName: WideString): WideString;
begin
  Result := GetGdcInvBaseDocument.JoinListFieldByFieldName(
    AFieldName, AAliasName, AJoinFieldName);
end;

function TwrpGdcInvBaseDocument.Get_BranchKey: Integer;
begin
  Result := GetGdcInvBaseDocument.BranchKey;
end;

function TwrpGdcInvBaseDocument.Get_Relation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetGdcInvBaseDocument.Relation) as IgsAtRelation;
end;

function TwrpGdcInvBaseDocument.Get_RelationLine: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetGdcInvBaseDocument.RelationLine) as IgsAtRelation;
end;

function TwrpGdcInvBaseDocument.Get_RelationType: TgsGdcInvRelationType;
begin
  Result := TgsGdcInvRelationType(GetGdcInvBaseDocument.RelationType);
end;

procedure TwrpGdcInvBaseDocument.ReadOptions(const Stream: IgsStream);
begin
  //GetGdcInvBaseDocument.ReadOptions(InterfaceToObject(Stream) as TStream);
end;

{ TwrpGdcInvDocument }

function TwrpGdcInvDocument.GetGdcInvDocument: TgdcInvDocument;
begin
  Result := GetObject as TgdcInvDocument;
end;

function TwrpGdcInvDocument.Get_MovementSource: IgsGdcInvMovementContactOption;
begin
  Result := GetGdcOLEObject(GetGdcInvDocument.MovementSource) as IgsGdcInvMovementContactOption;
end;

function TwrpGdcInvDocument.Get_MovementTarget: IgsGdcInvMovementContactOption;
begin
  Result := GetGdcOLEObject(GetGdcInvDocument.MovementTarget) as IgsGdcInvMovementContactOption;
end;

procedure TwrpGdcInvDocument.PrePostDocumentData;
begin
//  GetGdcInvDocument.PrePostDocumentData;
end;

{ TwrpGdcInvDocumentLine }

function TwrpGdcInvDocumentLine.ChooseRemains: WordBool;
begin
  Result := GetGdcInvDocumentLine.ChooseRemains;
end;

function TwrpGdcInvDocumentLine.Get_CanBeDelayed: WordBool;
begin
  Result := GetGdcInvDocumentLine.CanBeDelayed;
end;

function TwrpGdcInvDocumentLine.Get_ControlRemains: WordBool;
begin
  Result := GetGdcInvDocumentLine.ControlRemains;
end;

function TwrpGdcInvDocumentLine.Get_LiveTimeRemains: WordBool;
begin
  Result := GetGdcInvDocumentLine.LiveTimeRemains;
end;

function TwrpGdcInvDocumentLine.Get_Movement: IgsGdcInvMovement;
begin
  Result := GetGDCOleObject(GetGdcInvDocumentLine.Movement) as IgsGdcInvMovement;
end;

function TwrpGdcInvDocumentLine.Get_UseCachedUpdates: WordBool;
begin
  Result := GetGdcInvDocumentLine.UseCachedUpdates;
end;

function TwrpGdcInvDocumentLine.GetGdcInvDocumentLine: TgdcInvDocumentLine;
begin
  Result := GetObject as TgdcInvDocumentLine;
end;

function TwrpGdcInvDocumentLine.SelectGoodFeatures: WordBool;
begin
  Result := GetGdcInvDocumentLine.SelectGoodFeatures;
end;

procedure TwrpGdcInvDocumentLine.UpdateGoodNames;
begin
  GetGdcInvDocumentLine.UpdateGoodNames;
end;

function TwrpGdcInvDocumentLine.Get_Direction: TgsGdcInvMovementDirection;
begin
  Result := TgsGdcInvMovementDirection(GetGdcInvDocumentLine.Direction);
end;

function TwrpGdcInvDocumentLine.Get_ViewMovementPart: TgsGdcInvMovementPart;
begin
  Result := TgsGdcInvMovementPart(GetGdcInvDocumentLine.ViewMovementPart);
end;

procedure TwrpGdcInvDocumentLine.Set_ViewMovementPart(
  Value: TgsGdcInvMovementPart);
begin
  GetGdcInvDocumentLine.ViewMovementPart := TgdcInvMovementPart(Value);
end;

procedure TwrpGdcInvDocumentLine.SetFeatures(IsFrom, IsTo: WordBool);
begin
  GetGdcInvDocumentLine.SetFeatures(IsFrom, IsTo);
end;

function TwrpGdcInvDocumentLine.Get_isSetFeaturesFromRemains: WordBool;
begin
  Result := GetGdcInvDocumentLine.isSetFeaturesFromRemains;
end;

procedure TwrpGdcInvDocumentLine.Set_isSetFeaturesFromRemains(
  Value: WordBool);
begin
  GetGdcInvDocumentLine.isSetFeaturesFromRemains := Value;
end;

procedure TwrpGdcInvDocumentLine.Set_ControlRemains(Value: WordBool);
begin
  GetGdcInvDocumentLine.ControlRemains := Value;
end;

function TwrpGdcInvDocumentLine.Get_DestFeatures: OleVariant;
var
  I: Integer;
begin
  Result := VarArrayCreate([Low(GetGdcInvDocumentLine.DestFeatures), High(GetGdcInvDocumentLine.DestFeatures)], varVariant);

  for I := Low(GetGdcInvDocumentLine.DestFeatures) to High(GetGdcInvDocumentLine.DestFeatures) do
    Result[I] := GetGdcInvDocumentLine.DestFeatures[I];
end;

function TwrpGdcInvDocumentLine.Get_MinusFeatures: OleVariant;
var
  I: Integer;
begin
  Result := VarArrayCreate([Low(GetGdcInvDocumentLine.MinusFeatures), High(GetGdcInvDocumentLine.MinusFeatures)], varVariant);

  for I := Low(GetGdcInvDocumentLine.MinusFeatures) to High(GetGdcInvDocumentLine.MinusFeatures) do
    Result[I] := GetGdcInvDocumentLine.MinusFeatures[I];
end;

function TwrpGdcInvDocumentLine.Get_SourceFeatures: OleVariant;
var
  I: Integer;
begin
  Result := VarArrayCreate([Low(GetGdcInvDocumentLine.SourceFeatures), High(GetGdcInvDocumentLine.SourceFeatures)], varVariant);

  for I := Low(GetGdcInvDocumentLine.SourceFeatures) to High(GetGdcInvDocumentLine.SourceFeatures) do
    Result[I] := GetGdcInvDocumentLine.SourceFeatures[I];
end;

function TwrpGdcInvDocumentLine.Get_Sources: WideString;
begin

  Result := '';
  if irsGoodRef in GetGdcInvDocumentLine.Sources then
    Result := 'irsGoodRef';

  if irsRemainsRef in GetGdcInvDocumentLine.Sources then
    Result := Result + ' ' + 'irsRemainsRef';

end;

procedure TwrpGdcInvDocumentLine.Set_LiveTimeRemains(Value: WordBool);
begin
  GetGdcInvDocumentLine.LiveTimeRemains := Value;
end;

function TwrpGdcInvDocumentLine.Get_IsCheckDestFeatures: WordBool;
begin
  Result := GetGdcInvDocumentLine.IsCheckDestFeatures;
end;

procedure TwrpGdcInvDocumentLine.Set_IsCheckDestFeatures(Value: WordBool);
begin
  GetGdcInvDocumentLine.IsCheckDestFeatures := Value;
end;

function TwrpGdcInvDocumentLine.Get_isChooseRemains: WordBool;
begin
  Result := GetGdcInvDocumentLine.IsChooseRemains;
end;

procedure TwrpGdcInvDocumentLine.Set_isChooseRemains(Value: WordBool);
begin
  GetGdcInvDocumentLine.IsChooseRemains := Value;
end;

function TwrpGdcInvDocumentLine.Get_UseGoodKeyForMakeMovement: WordBool;
begin
  Result := GetGdcInvDocumentLine.UseGoodKeyForMakeMovement;
end;

procedure TwrpGdcInvDocumentLine.Set_UseGoodKeyForMakeMovement(
  Value: WordBool);
begin
  GetGdcInvDocumentLine.UseGoodKeyForMakeMovement := Value;
end;

function TwrpGdcInvDocumentLine.Get_IsMakeMovementOnFromCardKeyOnly: WordBool;
begin
  Result := GetGdcInvDocumentLine.IsMakeMovementOnFromCardKeyOnly;
end;

procedure TwrpGdcInvDocumentLine.Set_IsMakeMovementOnFromCardKeyOnly(
  Value: WordBool);
begin
  GetGdcInvDocumentLine.IsMakeMovementOnFromCardKeyOnly := Value;
end;

{ TwrpGdcInvDocumentType }

function TwrpGdcInvDocumentType.GetGdcInvDocumentType: TgdcInvDocumentType;
begin
  Result := GetObject as TgdcInvDocumentType;
end;

function TwrpGdcInvDocumentType.InvDocumentTypeBranchKey: Integer;
begin
  Result := GetGdcInvDocumentType.InvDocumentTypeBranchKey;
end;

{ TwrpGdcInvMovement }

function TwrpGdcInvMovement.ChooseRemains(
  isMakePosition: WordBool): WordBool;
begin
  Result := GetGdcInvMovement.ChooseRemains(isMakePosition);
end;

function TwrpGdcInvMovement.CreateAllMovement(
  gdcInvPositionSaveMode: TgsGdcInvPositionSaveMode;
  IsOnlyDisabled: WordBool): WordBool;
begin
  Result := GetGdcInvMovement.CreateAllMovement(TgdcInvPositionSaveMode(gdcInvPositionSaveMode),
    IsOnlyDisabled);
end;

function TwrpGdcInvMovement.CreateMovement(
  gdcInvPositionSaveMode: TgsGdcInvPositionSaveMode): WordBool;
begin
  Result := GetGdcInvMovement.CreateMovement(TgdcInvPositionSaveMode(gdcInvPositionSaveMode));
end;

function TwrpGdcInvMovement.Get_CurrentRemains: WordBool;
begin
  Result := GetGdcInvMovement.CurrentRemains;
end;

function TwrpGdcInvMovement.Get_gdcDocumentLine: IgsGDCDocument;
begin
  Result := GetGdcOLEObject(GetGdcInvMovement.gdcDocumentLine) as IgsGDCDocument;
end;

function TwrpGdcInvMovement.Get_InvErrorCode: TgsGdcInvErrorCode;
begin
  Result := TgsGdcInvErrorCode(GetGdcInvMovement.InvErrorCode);
end;

function TwrpGdcInvMovement.GetGdcInvMovement: TgdcInvMovement;
begin
  Result := GetObject as TgdcInvMovement;
end;

function TwrpGdcInvMovement.GetRemains: Currency;
begin
  Result := GetGdcInvMovement.GetRemains;
end;

function TwrpGdcInvMovement.SelectGoodFeatures: WordBool;
begin
  Result := GetGdcInvMovement.SelectGoodFeatures;
end;

procedure TwrpGdcInvMovement.Set_CurrentRemains(Value: WordBool);
begin
  GetGdcInvMovement.CurrentRemains := Value;
end;

procedure TwrpGdcInvMovement.Set_gdcDocumentLine(
  const Value: IgsGDCDocument);
begin
  GetGdcInvMovement.gdcDocumentLine := InterfaceToObject(Value) as TgdcDocument;
end;

function TwrpGdcInvMovement.Get_CountPositionChanged: Integer;
begin
  Result := GetGdcInvMovement.CountPositionChanged;
end;

function TwrpGdcInvMovement.Get_IsGetRemains: WordBool;
begin
  Result := GetGdcInvMovement.IsGetRemains;
end;

procedure TwrpGdcInvMovement.Set_IsGetRemains(Value: WordBool);
begin
  GetGdcInvMovement.IsGetRemains := Value;
end;

function TwrpGdcInvMovement.Get_ShowMovementDlg: WordBool;
begin
  Result := GetGdcInvMovement.ShowMovementDlg;
end;

procedure TwrpGdcInvMovement.Set_ShowMovementDlg(Value: WordBool);
begin
  GetGdcInvMovement.ShowMovementDlg := Value;
end;

function TwrpGdcInvMovement.Get_NoWait: WordBool;
begin
  Result := GetGdcInvMovement.NoWait;
end;

procedure TwrpGdcInvMovement.Set_NoWait(Value: WordBool);
begin
  GetGdcInvMovement.NoWait := Value;
end;

{ TwrpGdcInvRemains }

procedure TwrpGdcInvRemains.ClearPositionList;
begin
  GetGdcInvRemains.ClearPositionList;
end;

function TwrpGdcInvRemains.Get_CheckRemains: WordBool;
begin
  Result := GetGdcInvRemains.CheckRemains;
end;

function TwrpGdcInvRemains.Get_ContactType: Integer;
begin
  Result := GetGdcInvRemains.ContactType;
end;

function TwrpGdcInvRemains.Get_CountPosition: Integer;
begin
  Result := GetGdcInvRemains.CountPosition;
end;

function TwrpGdcInvRemains.Get_GoodKey: Integer;
begin
  Result := GetGdcInvRemains.GoodKey;
end;

function TwrpGdcInvRemains.Get_GroupKey: Integer;
begin
  Result := GetGdcInvRemains.GroupKey;
end;

function TwrpGdcInvRemains.Get_IncludeSubDepartment: WordBool;
begin
  Result := GetGdcInvRemains.IncludeSubDepartment;
end;

function TwrpGdcInvRemains.GetGdcInvRemains: TgdcInvRemains;
begin
  Result := GetObject as TgdcInvRemains;
end;

procedure TwrpGdcInvRemains.Set_CheckRemains(Value: WordBool);
begin
  GetGdcInvRemains.CheckRemains := Value;
end;

procedure TwrpGdcInvRemains.Set_ContactType(Value: Integer);
begin
  GetGdcInvRemains.ContactType := Value;
end;

procedure TwrpGdcInvRemains.Set_GoodKey(Value: Integer);
begin
  GetGdcInvRemains.GoodKey := Value;
end;

procedure TwrpGdcInvRemains.Set_GroupKey(Value: Integer);
begin
  GetGdcInvRemains.GroupKey := Value;
end;

procedure TwrpGdcInvRemains.Set_IncludeSubDepartment(Value: WordBool);
begin
  GetGdcInvRemains.IncludeSubDepartment := Value;
end;

function TwrpGdcInvRemains.Get_gdcDocumentLine: IgsGDCDocument;
begin
  Result := GetGdcOLEObject(GetGdcInvRemains.gdcDocumentLine) as IgsGDCDocument;
end;

procedure TwrpGdcInvRemains.RemovePosition;
begin
  GetGdcInvRemains.RemovePosition;
end;

procedure TwrpGdcInvRemains.Set_gdcDocumentLine(
  const Value: IgsGDCDocument);
begin
  GetGdcInvRemains.gdcDocumentLine := InterfaceToObject(Value) as TgdcDocument;
end;

{ TwrpGdcBaseBank }

function TwrpGdcBaseBank.GetBankInfo(
  const AccountKey: WideString): WideString;
begin
  Result := GetGdcBaseBank.GetBankInfo(AccountKey);
end;

function TwrpGdcBaseBank.GetGdcBaseBank: TgdcBaseBank;
begin
  Result := GetObject as TgdcBaseBank;
end;

function TwrpGdcBaseBank.Get_gsTransaction: IgsTransaction;
begin
  Result := GetGdcOLEObject(GetGdcBaseBank.gsTransaction) as IgsTransaction;
end;

procedure TwrpGdcBaseBank.Set_gsTransaction(const Value: IgsTransaction);
begin
  GetGdcBaseBank.gsTransaction := InterfaceToObject(Value) as TgsTransaction; 
end;

{ TwrpGdcBasePayment }

{function TwrpGdcBasePayment.GetGdcBasePayment: TgdcBasePayment;
begin
  Result := GetObject as TgdcBasePayment;
end;

procedure TwrpGdcBasePayment.UpdateAdditional;
begin
  GetGdcBasePayment.UpdateAdditional;
end;

procedure TwrpGdcBasePayment.UpdateCorrAccount;
begin
  GetGdcBasePayment.UpdateCorrAccount;
end;

procedure TwrpGdcBasePayment.UpdateCorrCompany;
begin
  GetGdcBasePayment.UpdateCorrCompany;
end;}

{ TwrpGdcCheckList }

{function TwrpGdcCheckList.Get_DetailObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdcCheckList.DetailObject) as IgsGdcBase;
end;

function TwrpGdcCheckList.GetGdcCheckList: TgdcCheckList;
begin
  Result := GetObject as TgdcCheckList;
end;

procedure TwrpGdcCheckList.Set_DetailObject(const Value: IgsGDCBase);
begin
  GetGdcCheckList.DetailObject := InterfaceToObject(Value) as TgdcBase;
end;}

{ TwrpGdcAttrUserDefined }

function TwrpGdcAttrUserDefined.Get_RelationName: WideString;
begin
  Result := GetGdcAttrUserDefined.RelationName;
end;

function TwrpGdcAttrUserDefined.GetGdcAttrUserDefined: TgdcAttrUserDefined;
begin
  Result := GetObject as TgdcAttrUserDefined;
end;

function TwrpGdcAttrUserDefined.Get_IsView: WordBool;
begin
  Result := GetGdcAttrUserDefined.IsView;
end;

{ TwrpGdcBugBase }

procedure TwrpGdcBugBase.GetBugAreas(const S: IgsStrings);
begin
  GetGdcBugBase.GetBugAreas(IgsStringsToTStrings(S));
end;

function TwrpGdcBugBase.GetGdcBugBase: TgdcBugBase;
begin
  Result := GetObject as TgdcBugBase;
end;

procedure TwrpGdcBugBase.GetSubSystems(const S: IgsStrings);
begin
  GetGdcBugBase.GetSubSystems(IgsStringsToTStrings(S));
end;

{ TwrpGdcInvPriceListLine }

function TwrpGdcInvPriceListLine.GetGdcInvPriceListLine: TgdcInvPriceListLine;
begin
  Result := GetObject as TgdcInvPriceListLine;
end;

procedure TwrpGdcInvPriceListLine.UpdateGoodNames;
begin
  GetGdcInvPriceListLine.UpdateGoodNames;
end;

{ TwrpGdcCurrCommission }

{function TwrpGdcCurrCommission.GetCurrencyByAccount(
  AccountKey: Integer): WideString;
begin
  Result := GetGdcCurrCommission.GetCurrencyByAccount(AccountKey);
end;

function TwrpGdcCurrCommission.GetGdcCurrCommission: TgdcCurrCommission;
begin
  Result := GetObject as TgdcCurrCommission;
end;

procedure TwrpGdcCurrCommission.UpdateAdditional;
begin
  GetGdcCurrCommission.UpdateAdditional;
end;

procedure TwrpGdcCurrCommission.UpdateCorrAccount;
begin
  GetGdcCurrCommission.UpdateCorrAccount;
end;

procedure TwrpGdcCurrCommission.UpdateCorrCompany;
begin
  GetGdcCurrCommission.UpdateCorrCompany;
end;}

{ TwrpGdcJournal }

procedure TwrpGdcJournal.CreateTriggers;
begin
  GetGdcJournal.CreateTriggers;
end;

procedure TwrpGdcJournal.DropTriggers;
begin
  GetGdcJournal.DropTriggers;
end;

function TwrpGdcJournal.GetGdcJournal: TgdcJournal;
begin
  Result := GetObject as TgdcJournal;
end;

{ TwrpFieldAlias }

function TwrpFieldAlias.Get_Alias: WideString;
begin
  Result := GetFieldAlias.Alias;
end;

function TwrpFieldAlias.Get_Grid: IgsGsCustomIBGrid;
begin
  Result := GetGdcOLEObject(GetFieldAlias.Grid) as IgsGsCustomIBGrid;
end;

function TwrpFieldAlias.Get_LName: WideString;
begin
  Result := GetFieldAlias.LName;
end;

function TwrpFieldAlias.GetFieldAlias: TFieldAlias;
begin
  Result := GetObject as TFieldAlias;
end;

procedure TwrpFieldAlias.Set_Alias(const Value: WideString);
begin
  GetFieldAlias.Alias := Value;
end;

procedure TwrpFieldAlias.Set_LName(const Value: WideString);
begin
  GetFieldAlias.LName := Value;
end;

{ TwrpFieldAliases }

function TwrpFieldAliases.Add: IgsFieldAlias;
begin
  Result := GetGdcOLEObject(GetFieldAliases.Add) as IgsFieldAlias;
end;

function TwrpFieldAliases.FindAlias(const AliasName: WideString;
  out Alias: OleVariant): WordBool;
var
  LAlias: TFieldAlias;
begin
  Result := GetFieldAliases.FindAlias(AliasName, LAlias);
  if Assigned(LAlias) then
    Alias := GetGdcOLEObject(LAlias) as IgsFieldAlias;
end;

function TwrpFieldAliases.Get_Grid: IgsGsCustomIBGrid;
begin
  Result := GetGdcOLEObject(GetFieldAliases.Grid) as IgsGsCustomIBGrid;
end;

function TwrpFieldAliases.Get_Items(Index: Integer): IgsFieldAlias;
begin
  Result := GetGdcOLEObject(GetFieldAliases.Items[Index]) as IgsFieldAlias;
end;

function TwrpFieldAliases.GetFieldAliases: TFieldAliases;
begin
  Result := GetObject as TFieldAliases;
end;

procedure TwrpFieldAliases.Set_Items(Index: Integer;
  const Value: IgsFieldAlias);
begin
  GetFieldAliases.Items[Index] := InterfaceToObject(Value) as TFieldAlias;
end;

{ TwrpTBToolWindow }

function TwrpTBToolWindow.Get_ClientAreaHeight: Integer;
begin
  Result := GetTBToolWindow.ClientAreaHeight;
end;

function TwrpTBToolWindow.Get_ClientAreaWidth: Integer;
begin
  Result := GetTBToolWindow.ClientAreaWidth;
end;

function TwrpTBToolWindow.Get_MaxClientHeight: Integer;
begin
  Result := GetTBToolWindow.MaxClientHeight;
end;

function TwrpTBToolWindow.Get_MaxClientWidth: Integer;
begin
  Result := GetTBToolWindow.MaxClientWidth;
end;

function TwrpTBToolWindow.Get_MinClientHeight: Integer;
begin
  Result := GetTBToolWindow.MinClientHeight;
end;

function TwrpTBToolWindow.Get_MinClientWidth: Integer;
begin
  Result := GetTBToolWindow.MinClientWidth;
end;

function TwrpTBToolWindow.GetTBToolWindow: TTBToolWindow;
begin
  Result := GetObject as TTBToolWindow;
end;

procedure TwrpTBToolWindow.Set_ClientAreaHeight(Value: Integer);
begin
  GetTBToolWindow.ClientAreaHeight := Value;
end;

procedure TwrpTBToolWindow.Set_ClientAreaWidth(Value: Integer);
begin
  GetTBToolWindow.ClientAreaWidth := Value;
end;

procedure TwrpTBToolWindow.Set_MaxClientHeight(Value: Integer);
begin
  GetTBToolWindow.MaxClientHeight := Value;
end;

procedure TwrpTBToolWindow.Set_MaxClientWidth(Value: Integer);
begin
  GetTBToolWindow.MaxClientWidth := Value;
end;

procedure TwrpTBToolWindow.Set_MinClientHeight(Value: Integer);
begin
  GetTBToolWindow.MinClientHeight := Value;
end;

procedure TwrpTBToolWindow.Set_MinClientWidth(Value: Integer);
begin
  GetTBToolWindow.MinClientWidth := Value;
end;

{ TwrpXCalculatorEdit }

function TwrpXCalculatorEdit.Get_DecDigits: Word;
begin
  Result := GetXCalculatorEdit.DecDigits;
end;

function TwrpXCalculatorEdit.Get_Value: Double;
begin
  Result := GetXCalculatorEdit.Value;
end;

function TwrpXCalculatorEdit.GetXCalculatorEdit: TXCalculatorEdit;
begin
  Result := GetObject as TxCalculatorEdit;
end;

procedure TwrpXCalculatorEdit.Set_DecDigits(Value: Word);
begin
  GetXCalculatorEdit.DecDigits := Value;
end;

procedure TwrpXCalculatorEdit.Set_Value(Value: Double);
begin
  GetXCalculatorEdit.Value := Value;
end;

{ TwrpTBBackground }

function TwrpTBBackground.Get_BkColor: Integer;
begin
  Result := GetTBBackground.BkColor;
end;

function TwrpTBBackground.Get_Transparent: WordBool;
begin
  Result := GetTBBackground.Transparent;
end;

function TwrpTBBackground.GetTBBackground: TTBBackground;
begin
  Result := GetObject as TTBBackground;
end;

procedure TwrpTBBackground.Set_BkColor(Value: Integer);
begin
  GetTBBackground.BkColor := Value;
end;

procedure TwrpTBBackground.Set_Transparent(Value: WordBool);
begin
  GetTBBackground.Transparent := Value;
end;

function TwrpTBBackground.Get_Bitmap: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetTBBackground.Bitmap) as IgsBitmap;
end;

procedure TwrpTBBackground.Set_Bitmap(const Value: IgsBitmap);
begin
  GetTBBackground.Bitmap := InterfaceToObject(Value) as Graphics.TBitmap;
end;

{ TwrpTBCustomItem }

procedure TwrpTBCustomItem.Add(const AItem: IgsTBCustomItem);
begin
  GetTBCustomItem.Add(InterfaceToObject(AItem) as TTBCustomItem);
end;

procedure TwrpTBCustomItem.Clear;
begin
  GetTBCustomItem.Clear;
end;

procedure TwrpTBCustomItem.Click;
begin
  GetTBCustomItem.Click;
end;

function TwrpTBCustomItem.ContainsItem(
  const AItem: IgsTBCustomItem): WordBool;
begin
  Result := GetTBCustomItem.ContainsItem(InterfaceToObject(AItem) as TTBCustomItem);
end;

procedure TwrpTBCustomItem.Delete(Index: Integer);
begin
  GetTBCustomItem.Delete(Index);
end;

function TwrpTBCustomItem.Get_Action: IgsBasicAction;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.Action) as IgsBasicAction;
end;

function TwrpTBCustomItem.Get_AutoCheck: WordBool;
begin
  Result := GetTBCustomItem.AutoCheck;
end;

function TwrpTBCustomItem.Get_Caption: WideString;
begin
  Result := GetTBCustomItem.Caption;
end;

function TwrpTBCustomItem.Get_Checked: WordBool;
begin
  Result := GetTBCustomItem.Checked;
end;

function TwrpTBCustomItem.Get_Count: Integer;
begin
  Result := GetTBCustomItem.Count;
end;

function TwrpTBCustomItem.Get_DisplayMode: TgsTBItemDisplayMode;
begin
  Result := TgsTBItemDisplayMode(GetTBCustomItem.DisplayMode);
end;

function TwrpTBCustomItem.Get_Enabled: WordBool;
begin
  Result := GetTBCustomItem.Enabled;
end;

function TwrpTBCustomItem.Get_GroupIndex: Integer;
begin
  Result := GetTBCustomItem.GroupIndex;
end;

function TwrpTBCustomItem.Get_Hint: WideString;
begin
  Result := GetTBCustomItem.Hint;
end;

function TwrpTBCustomItem.Get_ImageIndex: Integer;
begin
  Result := GetTBCustomItem.ImageIndex;
end;

function TwrpTBCustomItem.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.Images) as IgsCustomImageList;
end;

function TwrpTBCustomItem.Get_InheritOptions: WordBool;
begin
  Result := GetTBCustomItem.InheritOptions;
end;

function TwrpTBCustomItem.Get_Items(Index: Integer): IgsTBCustomItem;
begin
  Result := GetGDCOleObject(GetTBCustomItem.Items[Index]) as IgsTBCustomItem;
end;

function TwrpTBCustomItem.Get_LinkSubitems: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.LinkSubitems) as IgsTBCustomItem;
end;

function TwrpTBCustomItem.Get_Parent: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.Parent) as IgsTBCustomItem;
end;

function TwrpTBCustomItem.Get_ParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.ParentComponent) as IgsComponent;
end;

function TwrpTBCustomItem.Get_ShortCut: Word;
begin
  Result := GetTBCustomItem.ShortCut;
end;

function TwrpTBCustomItem.Get_SubMenuImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.SubMenuImages) as IgsCustomImageList;
end;

function TwrpTBCustomItem.Get_Visible: WordBool;
begin
  Result := GetTBCustomItem.Visible;
end;

function TwrpTBCustomItem.GetHintText: WideString;
begin
  Result := GetTBCustomItem.Hint;
end;

function TwrpTBCustomItem.GetParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetTBCustomItem.GetParentComponent) as IgsControl;
end;

function TwrpTBCustomItem.GetShortCutText: WideString;
begin
  Result := GetTBCustomItem.GetShortCutText;
end;

function TwrpTBCustomItem.GetTBCustomItem: TTBCustomItem;
begin
  Result := GetObject as TTBCustomItem;
end;

function TwrpTBCustomItem.HasParent: WordBool;
begin
  Result := GetTBCustomItem.HasParent;
end;

function TwrpTBCustomItem.IndexOf(const AItem: IgsTBCustomItem): Integer;
begin
  Result := GetTBCustomItem.IndexOf(InterfaceToObject(AItem) as TTBCustomItem);
end;

procedure TwrpTBCustomItem.InitiateAction;
begin
  GetTBCustomItem.InitiateAction;
end;

procedure TwrpTBCustomItem.Insert(NewIndex: Integer;
  const AItem: IgsTBCustomItem);
begin
  GetTBCustomItem.Insert(NewIndex, InterfaceToObject(AItem) as TTBCustomItem);
end;

procedure TwrpTBCustomItem.Move(CurIndex, NewIndex: Integer);
begin
  GetTBCustomItem.Move(CurIndex, NewIndex);
end;

procedure TwrpTBCustomItem.Popup(X, Y: Integer; TrackRightButton: WordBool;
  Alignment: TgsTBPopupAlignment);
begin
  GetTBCustomItem.Popup(X, Y, TrackRightButton, TTBPopupAlignment(Alignment));
end;

procedure TwrpTBCustomItem.Remove(const Item: IgsTBCustomItem);
begin
  GetTBCustomItem.Remove(InterfaceToObject(Item) as TTBCustomItem);
end;

procedure TwrpTBCustomItem.Set_Action(const Value: IgsBasicAction);
begin
  GetTBCustomItem.Action := InterfaceToObject(Value) as TBasicAction;
end;

procedure TwrpTBCustomItem.Set_AutoCheck(Value: WordBool);
begin
  GetTBCustomItem.AutoCheck := Value;
end;

procedure TwrpTBCustomItem.Set_Caption(const Value: WideString);
begin
  GetTBCustomItem.Caption := Value;
end;

procedure TwrpTBCustomItem.Set_Checked(Value: WordBool);
begin
  GetTBCustomItem.Checked := Value;
end;

procedure TwrpTBCustomItem.Set_DisplayMode(Value: TgsTBItemDisplayMode);
begin
  GetTBCustomItem.DisplayMode := TTBItemDisplayMode(Value);
end;

procedure TwrpTBCustomItem.Set_Enabled(Value: WordBool);
begin
  GetTBCustomItem.Enabled := Value;
end;

procedure TwrpTBCustomItem.Set_GroupIndex(Value: Integer);
begin
  GetTBCustomItem.GroupIndex := Value;
end;

procedure TwrpTBCustomItem.Set_Hint(const Value: WideString);
begin
  GetTBCustomItem.Hint := Value;
end;

procedure TwrpTBCustomItem.Set_ImageIndex(Value: Integer);
begin
  GetTBCustomItem.ImageIndex := Value;
end;

procedure TwrpTBCustomItem.Set_Images(const Value: IgsCustomImageList);
begin
  GetTBCustomItem.Images := InterfaceToObject(Value) as TCustomImageList ;
end;

procedure TwrpTBCustomItem.Set_InheritOptions(Value: WordBool);
begin
  GetTBCustomItem.InheritOptions := Value;
end;

procedure TwrpTBCustomItem.Set_LinkSubitems(const Value: IgsTBCustomItem);
begin
  GetTBCustomItem.LinkSubitems := InterfaceToObject(Value) as TTBCustomItem;
end;

procedure TwrpTBCustomItem.Set_ParentComponent(const Value: IgsComponent);
begin
  GetTBCustomItem.ParentComponent := InterfaceToObject(Value) as  TComponent;
end;

procedure TwrpTBCustomItem.Set_ShortCut(Value: Word);
begin
  GetTBCustomItem.ShortCut := Value;
end;

procedure TwrpTBCustomItem.Set_SubMenuImages(
  const Value: IgsCustomImageList);
begin
  GetTBCustomItem.SubMenuImages := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpTBCustomItem.Set_Visible(Value: WordBool);
begin
  GetTBCustomItem.Visible := Value;
end;

procedure TwrpTBCustomItem.ViewBeginUpdate;
begin
  GetTBCustomItem.ViewBeginUpdate;
end;

procedure TwrpTBCustomItem.ViewEndUpdate;
begin
  GetTBCustomItem.ViewEndUpdate;
end;

function TwrpTBCustomItem.Get_HelpContext: Integer;
begin
  Result := GetTBCustomItem.HelpContext;
end;

procedure TwrpTBCustomItem.Set_HelpContext(Value: Integer);
begin
  GetTBCustomItem.HelpContext := Value;
end;

{ TwrpTBItemContainer }

function TwrpTBItemContainer.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetTBItemContainer.Images) as IgsCustomImageList;
end;

function TwrpTBItemContainer.Get_Items: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBItemContainer.Items) as IgsTBCustomItem;
end;

function TwrpTBItemContainer.GetTBItemContainer: TTBItemContainer;
begin
  Result := GetObject as TTBItemContainer;
end;

procedure TwrpTBItemContainer.Set_Images(const Value: IgsCustomImageList);
begin
  GetTBItemContainer.Images := InterfaceToObject(Value) as TCustomImageList;
end;


{ TwrpLookup }

function TwrpLookup.Get_CheckUserRights: WordBool;
begin
  Result := GetLookup.CheckUserRights;
end;

function TwrpLookup.Get_Condition: WideString;
begin
  Result := GetLookup.Condition;
end;

function TwrpLookup.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetLookup.Database) as IgsIBDatabase;
end;

function TwrpLookup.Get_gdClassName: WideString;
begin
  Result := GetLookup.gdClassName;
end;

function TwrpLookup.Get_GroupBY: WideString;
begin
  Result := GetLookup.GroupBY;
end;

function TwrpLookup.Get_LookupKeyField: WideString;
begin
  Result := GetLookup.LookupKeyField;
end;

function TwrpLookup.Get_LookupListField: WideString;
begin
  Result := GetLookup.LookupListField;
end;

function TwrpLookup.Get_LookupTable: WideString;
begin
  Result := GetLookup.LookupTable;
end;

function TwrpLookup.Get_SortOrder: TgsgsSortOrder;
begin
  Result := TgsgsSortOrder(GetLookup.SortOrder);
end;

function TwrpLookup.Get_SubType: WideString;
begin
  Result := GetLookup.SubType;
end;

function TwrpLookup.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetLookup.Transaction) as IgsIBTransaction;
end;

function TwrpLookup.GetLookup: TLookup;
begin
  Result := GetObject as TLookup;
end;

procedure TwrpLookup.Set_CheckUserRights(Value: WordBool);
begin
  GetLookup.CheckUserRights := Value;
end;

procedure TwrpLookup.Set_Condition(const Value: WideString);
begin
  GetLookup.Condition := Value;
end;

procedure TwrpLookup.Set_Database(const Value: IgsIBDatabase);
begin
  GetLookup.Database := InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpLookup.Set_gdClassName(const Value: WideString);
begin
  GetLookup.gdClassName := Value;
end;

procedure TwrpLookup.Set_GroupBY(const Value: WideString);
begin
  GetLookup.GroupBY := Value;
end;

procedure TwrpLookup.Set_LookupKeyField(const Value: WideString);
begin
  GetLookup.LookupKeyField := Value;
end;

procedure TwrpLookup.Set_LookupListField(const Value: WideString);
begin
  GetLookup.LookupListField := Value;
end;

procedure TwrpLookup.Set_LookupTable(const Value: WideString);
begin
  GetLookup.LookupTable := Value;
end;

procedure TwrpLookup.Set_SortOrder(Value: TgsgsSortOrder);
begin
  GetLookup.SortOrder := gsIBGrid.TgsSortOrder(Value);
end;

procedure TwrpLookup.Set_SubType(const Value: WideString);
begin
  GetLookup.SubType := Value;
end;

procedure TwrpLookup.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetLookup.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

function TwrpLookup.Get_Fields: WideString;
begin
  Result := GetLookup.Fields;
end;

function TwrpLookup.Get_IsTree: WordBool;
begin
  Result := GetLookup.IsTree;
end;

function TwrpLookup.Get_ParentField: WideString;
begin
  Result := GetLookup.ParentField;
end;

procedure TwrpLookup.Set_Fields(const Value: WideString);
begin
  GetLookup.Fields := Value;
end;

function TwrpLookup.Get_Params: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetLookup.Params);
end;

function TwrpLookup.Get_Distinct: WordBool;
begin
  Result := GetLookup.Distinct;
end;

function TwrpLookup.Get_FullSearchOnExit: WordBool;
begin
  Result := GetLookup.FullSearchOnExit;
end;

procedure TwrpLookup.Set_Distinct(Value: WordBool);
begin
  GetLookup.Distinct := Value;
end;

procedure TwrpLookup.Set_FullSearchOnExit(Value: WordBool);
begin
  GetLookup.FullSearchOnExit := Value;
end;

function TwrpLookup.Get_ViewType: TgsgsViewType;
begin
  Result := TgsgsViewType(GetLookup.ViewType);
end;

procedure TwrpLookup.Set_ViewType(Value: TgsgsViewType);
begin
  GetLookup.ViewType :=  gsIbGrid.TgsViewType(Value);
end;

{ TwrpSet }

function TwrpSet.Get_CrossDestField: WideString;
begin
  Result := GetSet.CrossDestField;
end;

function TwrpSet.Get_CrossSourceField: WideString;
begin
  Result := GetSet.CrossSourceField;
end;

function TwrpSet.Get_CrossTable: WideString;
begin
  Result := GetSet.CrossTable;
end;

function TwrpSet.Get_KeyField: WideString;
begin
  Result := GetSet.KeyField;
end;

function TwrpSet.Get_SourceKeyField: WideString;
begin
  Result := GetSet.SourceKeyField
end;

function TwrpSet.Get_SourceListField: WideString;
begin
  Result := GetSet.SourceListField;
end;

function TwrpSet.Get_SourceParentField: WideString;
begin
  Result := GetSet.SourceParentField;
end;

function TwrpSet.Get_SourceTable: WideString;
begin
  Result := GetSet.SourceTable;
end;

function TwrpSet.GetSet: TSet;
begin
  Result := GetObject as TSet;
end;

procedure TwrpSet.Set_CrossDestField(const Value: WideString);
begin
  GetSet.CrossDestField := Value;
end;

procedure TwrpSet.Set_CrossSourceField(const Value: WideString);
begin
  GetSet.CrossSourceField := Value;
end;

procedure TwrpSet.Set_CrossTable(const Value: WideString);
begin
  GetSet.CrossTable := Value;
end;

procedure TwrpSet.Set_KeyField(const Value: WideString);
begin
  GetSet.KeyField := Value;
end;

procedure TwrpSet.Set_SourceKeyField(const Value: WideString);
begin
  GetSet.SourceKeyField := Value;
end;

procedure TwrpSet.Set_SourceListField(const Value: WideString);
begin
  GetSet.SourceListField := Value;
end;

procedure TwrpSet.Set_SourceParentField(const Value: WideString);
begin
  GetSet.SourceParentField := Value;
end;

procedure TwrpSet.Set_SourceTable(const Value: WideString);
begin
  GetSet.SourceTable := Value;
end;

{ TwrpIBColumnEditor }

function TwrpIBColumnEditor.Get_DisplayField: WideString;
begin
  Result := GetIBColumnEditor.DisplayField;
end;

function TwrpIBColumnEditor.Get_EditorStyle: TgsgsIBColumnEditorStyle;
begin
  Result := TgsgsIBColumnEditorStyle(GetIBColumnEditor.EditorStyle);
end;

function TwrpIBColumnEditor.Get_Grid: IgsGsCustomIBGrid;
begin
  Result := GetGdcOLEObject(GetIBColumnEditor.Grid) as IgsGsCustomIBGrid;
end;

function TwrpIBColumnEditor.Get_Lookup: IgsLookup;
begin
  Result := GetGdcOLEObject(GetIBColumnEditor.Lookup) as IgsLookup;
end;

function TwrpIBColumnEditor.Get_LookupSet: IgsSet;
begin
  Result := GetGdcOLEObject(GetIBColumnEditor.LookupSet) as IgsSet;
end;

function TwrpIBColumnEditor.Get_Text: WideString;
begin
  Result := GetIBColumnEditor.Text;
end;

function TwrpIBColumnEditor.Get_ValueList: IgsStringList;
begin
  Result := GetGdcOLEObject(GetIBColumnEditor.ValueList) as IgsStringList;
end;

function TwrpIBColumnEditor.GetIBColumnEditor: TgsIBColumnEditor;
begin
  Result := GetObject as TgsIBColumnEditor;
end;

procedure TwrpIBColumnEditor.Set_DisplayField(const Value: WideString);
begin
  GetIBColumnEditor.DisplayField := Value;
end;

procedure TwrpIBColumnEditor.Set_EditorStyle(
  Value: TgsgsIBColumnEditorStyle);
begin
  GetIBColumnEditor.EditorStyle := TgsIBColumnEditorStyle(Value);
end;

procedure TwrpIBColumnEditor.Set_Lookup(const Value: IgsLookup);
begin
  GetIBColumnEditor.Lookup := InterfaceToObject(Value) as TLookup;
end;

procedure TwrpIBColumnEditor.Set_LookupSet(const Value: IgsSet);
begin
  GetIBColumnEditor.LookupSet := InterfaceToObject(Value) as TSet;
end;

procedure TwrpIBColumnEditor.Set_ValueList(const Value: IgsStringList);
begin
  GetIBColumnEditor.ValueList := InterfaceToObject(Value) as TStringList;
end;

function TwrpIBColumnEditor.Get_FieldName: WideString;
begin
 Result := GetIBColumnEditor.FieldName;
end;

procedure TwrpIBColumnEditor.Set_FieldName(const Value: WideString);
begin
  GetIBColumnEditor.FieldName := Value;
end;

function TwrpIBColumnEditor.Get_DropDownCount: Integer;
begin
  Result := GetIBColumnEditor.DropDownCount;
end;

procedure TwrpIBColumnEditor.Set_DropDownCount(Value: Integer);
begin
  GetIBColumnEditor.DropDownCount := Value;
end;

{ TwrpIBColumnEditors }

function TwrpIBColumnEditors.Add: IgsIBColumnEditor;
begin
  Result := GetGdcOLEObject(GetIBColumnEditors.Add) as IgsIBColumnEditor;
end;

function TwrpIBColumnEditors.Get_Grid: IgsGsCustomIBGrid;
begin
  Result := GetGdcOLEObject(GetIBColumnEditors.Grid) as IgsGsCustomIBGrid;
end;

function TwrpIBColumnEditors.Get_Items(Index: Integer): IgsIBColumnEditor;
begin
  Result := GetGdcOLEObject(GetIBColumnEditors.Items[Index]) as IgsIBColumnEditor;
end;

function TwrpIBColumnEditors.GetIBColumnEditors: TgsIBColumnEditors;
begin
  Result := GetObject as TgsIBColumnEditors;
end;

function TwrpIBColumnEditors.IndexByField(const Name: WideString): Integer;
begin
  Result := GetIBColumnEditors.IndexByField(Name);
end;

procedure TwrpIBColumnEditors.Set_Items(Index: Integer;
  const Value: IgsIBColumnEditor);
begin
  GetIBColumnEditors.Items[Index] := InterfaceToObject(Value) as TgsIBColumnEditor;
end;

{ TwrpIBCustomService }

procedure TwrpIBCustomService.Attach;
begin
  GetIBCustomService.Attach;
end;

procedure TwrpIBCustomService.CheckActive;
begin
  TCrackIBCustomService(GetIBCustomService).CheckActive;
end;

procedure TwrpIBCustomService.CheckInactive;
begin
  TCrackIBCustomService(GetIBCustomService).CheckInactive;
end;

procedure TwrpIBCustomService.Detach;
begin
  GetIBCustomService.Detach;
end;

function TwrpIBCustomService.Get_Active: WordBool;
begin
  Result := GetIBCustomService.Active;
end;

function TwrpIBCustomService.Get_BufferSize: Integer;
begin
  Result := TCrackIBCustomService(GetIBCustomService).BufferSize;
end;

function TwrpIBCustomService.Get_LoginPrompt: WordBool;
begin
  Result := GetIBCustomService.LoginPrompt;
end;

function TwrpIBCustomService.Get_OutputBuffer: WideString;
begin
  Result := TCrackIBCustomService(GetIBCustomService).OutputBuffer;
end;

function TwrpIBCustomService.Get_OutputBufferOption: TgsOutputBufferOption;
begin
  Result := TgsOutputBufferOption(TCrackIBCustomService(GetIBCustomService).OutputBufferOption);
end;

function TwrpIBCustomService.Get_Params: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBCustomService.Params);
end;

function TwrpIBCustomService.Get_Protocol: TgsProtocol;
begin
  Result := TgsProtocol(GetIBCustomService.Protocol);
end;

function TwrpIBCustomService.Get_ServerName: WideString;
begin
  Result := GetIBCustomService.ServerName;
end;

function TwrpIBCustomService.Get_ServiceParamBySPB(
  Idx: Integer): WideString;
begin
  Result := GetIBCustomService.ServiceParamBySPB[Idx];
end;

function TwrpIBCustomService.Get_ServiceQueryParams: WideString;
begin
  Result := TCrackIBCustomService(GetIBCustomService).ServiceQueryParams;
end;

function TwrpIBCustomService.GetIBCustomService: TIBCustomService;
begin
  Result := GetObject as TIBCustomService;
end;

procedure TwrpIBCustomService.InternalServiceQuery;
begin
  TCrackIBCustomService(GetIBCustomService).InternalServiceQuery;
end;

procedure TwrpIBCustomService.Loaded;
begin
  TCrackIBCustomService(GetIBCustomService).Loaded;
end;

function TwrpIBCustomService.Login: WordBool;
begin
  Result := TCrackIBCustomService(GetIBCustomService).Login;
end;

procedure TwrpIBCustomService.Set_Active(Value: WordBool);
begin
  GetIBCustomService.Active := Value;
end;

procedure TwrpIBCustomService.Set_BufferSize(Value: Integer);
begin
  TCrackIBCustomService(GetIBCustomService).BufferSize := Value;
end;

procedure TwrpIBCustomService.Set_LoginPrompt(Value: WordBool);
begin
  GetIBCustomService.LoginPrompt := Value;
end;

procedure TwrpIBCustomService.Set_OutputBufferOption(
  Value: TgsOutputBufferOption);
begin
  TCrackIBCustomService(GetIBCustomService).OutputBufferOption := TOutputBufferOption(Value);
end;

procedure TwrpIBCustomService.Set_Params(const Value: IgsStrings);
begin
  GetIBCustomService.Params := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomService.Set_Protocol(Value: TgsProtocol);
begin
  GetIBCustomService.Protocol := TProtocol(Value);
end;

procedure TwrpIBCustomService.Set_ServerName(const Value: WideString);
begin
  GetIBCustomService.ServerName := Value;
end;

procedure TwrpIBCustomService.Set_ServiceParamBySPB(Idx: Integer;
  const Value: WideString);
begin
  TCrackIBCustomService(GetIBCustomService).ServiceParamBySPB[Idx] := Value;
end;

procedure TwrpIBCustomService.Set_ServiceQueryParams(
  const Value: WideString);
begin
  TCrackIBCustomService(GetIBCustomService).ServiceQueryParams := Value;
end;

{ TwrpIBControlService }

function TwrpIBControlService.Get_IsServiceRunning: WordBool;
begin
  Result := GetIBControlService.IsServiceRunning;
end;

function TwrpIBControlService.Get_ServiceStartParams: WideString;
begin
  Result := TCrackIBControlService(GetIBControlService).ServiceStartParams;
end;

function TwrpIBControlService.GetIBControlService: TIBControlService;
begin
  Result := GetObject as TIBControlService;
end;

procedure TwrpIBControlService.InternalServiceStart;
begin
  TCrackIBControlService(GetIBControlService).InternalServiceStart;
end;

procedure TwrpIBControlService.ServiceStart;
begin
  GetIBControlService.ServiceStart;
end;

procedure TwrpIBControlService.ServiceStartAddParam(
  const Value: WideString; Param: Integer);
begin
  TCrackIBControlService(GetIBControlService).ServiceStartAddParam(Value, Param);
end;

procedure TwrpIBControlService.ServiceStartAddParamByInt(Value,
  Param: Integer);
begin
  TCrackIBControlService(GetIBControlService).ServiceStartAddParam(value, Param);
end;

procedure TwrpIBControlService.Set_ServiceStartParams(
  const Value: WideString);
begin
  TCrackIBControlService(GetIBControlService).ServiceStartParams := Value;
end;

procedure TwrpIBControlService.SetServiceStartOptions;
begin
  TCrackIBControlService(GetIBControlService).SetServiceStartOptions;
end;

{ TwrpIBControlAndQueryService }

function TwrpIBControlAndQueryService.Get_Action: Integer;
begin
  Result := TCrackIBControlAndQueryService(GetIBControlAndQueryService).Action;
end;

function TwrpIBControlAndQueryService.Get_Eof: WordBool;
begin
  Result := GetIBControlAndQueryService.Eof;
end;

function TwrpIBControlAndQueryService.GetIBControlAndQueryService: TIBControlAndQueryService;
begin
  Result := GetObject as TIBControlAndQueryService;
end;

function TwrpIBControlAndQueryService.GetNextChunk: WideString;
begin
  Result := GetIBControlAndQueryService.GetNextChunk;
end;

function TwrpIBControlAndQueryService.GetNextLine: WideString;
begin
  Result := GetIBControlAndQueryService.GetNextLine;
end;

procedure TwrpIBControlAndQueryService.Set_Action(Value: Integer);
begin
  TCrackIBControlAndQueryService(GetIBControlAndQueryService).Action := Value;
end;

{ TwrpIBBackupRestoreService }

function TwrpIBBackupRestoreService.Get_Verbose: WordBool;
begin
  Result := GetIBBackupRestoreService.Verbose;
end;

function TwrpIBBackupRestoreService.GetIBBackupRestoreService: TIBBackupRestoreService;
begin
  Result := GetObject as TIBBackupRestoreService;
end;

procedure TwrpIBBackupRestoreService.Set_Verbose(Value: WordBool);
begin
  GetIBBackupRestoreService.Verbose := Value;
end;

{ TwrpIBRestoreService }

function TwrpIBRestoreService.Get_BackupFile: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBRestoreService.BackupFile);
end;

function TwrpIBRestoreService.Get_DatabaseName: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBRestoreService.DatabaseName);
end;

function TwrpIBRestoreService.Get_PageBuffers: Integer;
begin
  Result := GetIBRestoreService.PageBuffers;
end;

function TwrpIBRestoreService.Get_PageSize: Integer;
begin
  Result := GetIBRestoreService.PageSize;
end;

function TwrpIBRestoreService.GetIBRestoreService: TIBRestoreService;
begin
  Result := GetObject as TIBRestoreService;
end;

procedure TwrpIBRestoreService.Set_BackupFile(const Value: IgsStrings);
begin
  GetIBRestoreService.BackupFile := IgsStringsToTStrings(Value);
end;

procedure TwrpIBRestoreService.Set_DatabaseName(const Value: IgsStrings);
begin
  GetIBRestoreService.DatabaseName := IgsStringsToTStrings(Value);
end;

procedure TwrpIBRestoreService.Set_PageBuffers(Value: Integer);
begin
  GetIBRestoreService.PageBuffers := Value;
end;

procedure TwrpIBRestoreService.Set_PageSize(Value: Integer);
begin
  GetIBRestoreService.PageSize := Value;
end;

function TwrpIBRestoreService.Get_Options: WideString;
var
  LOptions: TRestoreOptions;
begin
  Result := ' ';
  LOptions := GetIBRestoreService.Options;
  with GetIBRestoreService do
  begin
    if DeactivateIndexes in LOptions then
      Result := Result + 'DeactivateIndexes ';
    if NoShadow in LOptions then
      Result := Result + 'NoShadow ';
    if NoValidityCheck in LOptions then
      Result := Result + 'NoValidityCheck ';
    if OneRelationAtATime in LOptions then
      Result := Result + 'OneRelationAtATime ';
    if Replace in LOptions then
      Result := Result + 'Replace ';
    if CreateNewDB in LOptions then
      Result := Result + 'CreateNewDB ';
    if UseAllSpace in LOptions then
      Result := Result + 'UseAllSpace ';
  end;
end;

procedure TwrpIBRestoreService.Set_Options(const Value: WideString);
var
  LOptions: TRestoreOptions;
begin
  LOptions := [];

  if Pos('DEACTIVATEINDEXES', AnsiUppercase(Value)) > 0 then
    include(LOptions, DEACTIVATEINDEXES);
  if Pos('NOSHADOW', AnsiUppercase(Value)) > 0 then
    include(LOptions, NOSHADOW);
  if Pos('NOVALIDITYCHECK', AnsiUppercase(Value)) > 0 then
    include(LOptions, NOVALIDITYCHECK);
  if Pos('ONERELATIONATATIME', AnsiUppercase(Value)) > 0 then
    include(LOptions, ONERELATIONATATIME);
  if Pos('REPLACE', AnsiUppercase(Value)) > 0 then
    include(LOptions, REPLACE);
  if Pos('CREATENEWDB', AnsiUppercase(Value)) > 0 then
    include(LOptions, CREATENEWDB);
  if Pos('USEALLSPACE', AnsiUppercase(Value)) > 0 then
    include(LOptions, USEALLSPACE);

  GetIBRestoreService.Options := LOptions;
end;

{ TwrpIBBackupService }

function TwrpIBBackupService.Get_BackupFile: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBBackupService.BackupFile);
end;

function TwrpIBBackupService.Get_BlockingFactor: Integer;
begin
  Result := GetIBBackupService.BlockingFactor;
end;

function TwrpIBBackupService.Get_DatabaseName: WideString;
begin
  Result := GetIBBackupService.DatabaseName;
end;

function TwrpIBBackupService.GetIBBackupService: TIBBackupService;
begin
  Result := GetObject as TIBBackupService;
end;

procedure TwrpIBBackupService.Set_BackupFile(const Value: IgsStrings);
begin
  GetIBBackupService.BackupFile := IgsStringsToTStrings(Value);
end;

procedure TwrpIBBackupService.Set_BlockingFactor(Value: Integer);
begin
  GetIBBackupService.BlockingFactor := Value;
end;

procedure TwrpIBBackupService.Set_DatabaseName(const Value: WideString);
begin
  GetIBBackupService.DatabaseName := Value;
end;

{ TwrpGDCCreateableForm }

{function TwrpGDCCreateableForm.Get_gdcChooseObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGDCCreateableForm.gdcChooseObject) as IgsGDCBase;
end;}

function TwrpGDCCreateableForm.Get_gdcObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGDCCreateableForm.gdcObject) as IgsGDCBase;
end;

function TwrpGDCCreateableForm.GetGDCCreateableForm: TgdcCreateableForm;
begin
  Result := GetObject as TgdcCreateableForm;
end;

procedure TwrpGDCCreateableForm.Set_gdcObject(const Value: IgsGDCBase);
begin
  GetGDCCreateableForm.gdcObject :=
    InterfaceToObject(Value) as TGDCBase;
end;

procedure TwrpGDCCreateableForm.LoadGrid(const AGrid: IgsGsCustomDBGrid);
begin
  GetGDCCreateableForm.LoadGrid(InterfaceToObject(AGrid) as TgsCustomDBGrid);
end;

procedure TwrpGDCCreateableForm.SaveGrid(const AGrid: IgsGsCustomDBGrid);
begin
  GetGDCCreateableForm.SaveGrid(InterfaceToObject(AGrid) as TgsCustomDbGrid);
end;

function TwrpGDCCreateableForm.GetSubTypeList(
  const SubTypeList: IgsStrings): WordBool;
begin
  Result := GetGDCCreateableForm.GetSubTypeList(IgsStringsToTStrings(SubTypeList));
end;

function TwrpIBBackupService.Get_Options: WideString;
var
  LOptions: TBackupOptions;
begin
  Result := ' ';
  LOptions := GetIBBackupService.Options;
  begin
    if IgnoreChecksums in LOptions then
      Result := Result + 'IgnoreChecksums ';
    if IgnoreLimbo in LOptions then
      Result := Result + 'IgnoreLimbo ';
    if MetadataOnly in LOptions then
      Result := Result + 'MetadataOnly ';
    if NoGarbageCollection in LOptions then
      Result := Result + 'NoGarbageCollection ';
    if OldMetadataDesc in LOptions then
      Result := Result + 'OldMetadataDesc ';
    if NonTransportable in LOptions then
      Result := Result + 'NonTransportable ';
    if ConvertExtTables in LOptions then
      Result := Result + 'ConvertExtTables ';
  end;
end;

procedure TwrpIBBackupService.Set_Options(const Value: WideString);
var
  LOptions: TBackupOptions;
begin
  LOptions := [];

  if Pos('IGNORECHECKSUMS', AnsiUppercase(Value)) > 0 then
    include(LOptions, IGNORECHECKSUMS);
  if Pos('IGNORELIMBO', AnsiUppercase(Value)) > 0 then
    include(LOptions, IGNORELIMBO);
  if Pos('METADATAONLY', AnsiUppercase(Value)) > 0 then
    include(LOptions, METADATAONLY);
  if Pos('NOGARBAGECOLLECTION', AnsiUppercase(Value)) > 0 then
    include(LOptions, NOGARBAGECOLLECTION);
  if Pos('OLDMETADATADESC', AnsiUppercase(Value)) > 0 then
    include(LOptions, OLDMETADATADESC);
  if Pos('NONTRANSPORTABLE', AnsiUppercase(Value)) > 0 then
    include(LOptions, NONTRANSPORTABLE);
  if Pos('CONVERTEXTTABLES', AnsiUppercase(Value)) > 0 then
    include(LOptions, CONVERTEXTTABLES);
  GetIBBackupService.Options := LOptions;
end;

{ TwrpGDC_dlgG }

function TwrpGDC_dlgG.Get_MultipleCreated: WordBool;
begin
  Result := GetGDC_dlgG.MultipleCreated;
end;

function TwrpGDC_dlgG.GetGDC_dlgG: Tgdc_dlgG;
begin
  Result := GetObject as Tgdc_dlgG
end;

procedure TwrpGDC_dlgG.SyncControls;
begin
  GetGDC_dlgG.SyncControls;
end;

function TwrpGDC_dlgG.Get_ErrorAction: WordBool;
begin
  Result := GetGDC_dlgG.ErrorAction;
end;

procedure TwrpGDC_dlgG.Set_ErrorAction(Value: WordBool);
begin
  GetGDC_dlgG.ErrorAction := Value;
end;

procedure TwrpGDC_dlgG.SetupDialog;
begin
  TCrackGdc_dlgG(GetGDC_dlgG).SetupDialog;
end;

procedure TwrpGDC_dlgG.SetupRecord;
begin
  TCrackGdc_dlgG(GetGDC_dlgG).SetupRecord;
end;

procedure TwrpGDC_dlgG.ActivateTransaction(
  const ATransactionATransaction: IgsIBTransaction);
begin
  TCrackGdc_dlgG(GetGDC_dlgG).ActivateTransaction(
    InterfaceToObject(ATransactionATransaction) as TIBTransaction)
end;

function TwrpGDC_dlgG.TestCorrect: WordBool;
begin
  Result := TCrackGdc_dlgG(GetGDC_dlgG).TestCorrect;
end;

function TwrpGDC_dlgG.Get_FieldsCallOnSync: IgsFieldsCallList;
begin
  Result := GetGdcOLEObject(GetGDC_dlgG.FieldsCallOnSync) as IgsFieldsCallList;
end;

function TwrpGDC_dlgG.DlgModified: WordBool;
begin
  Result := TCrackGdc_dlgG(GetGDC_dlgG).DlgModified;
end;

procedure TwrpGDC_dlgG.LockDocument;
begin
  TCrackGdc_dlgG(GetGDC_dlgG).LockDocument;
end;

function TwrpGDC_dlgG.Get_RecordLocked: WordBool;
begin
  Result := GetGDC_dlgG.RecordLocked;
end;

{ TwrpScrException }

procedure TwrpScrException.Clear;
begin
  GetScrException.DelRaise;
end;

function TwrpScrException.GetScrException: EScrException;
begin
  Result := ScriptFactory.scrException;
end;

procedure TwrpScrException.Raise_(const ClassName,
  EMessage: WideString);
begin
  // добавляем исключении
  GetScrException.AddRaise(ClassName, EMessage);
  // генерируем исключение
  raise Exception.Create(EMessage);
end;

{ TwrpGdcHoliday }

function TwrpGdcHoliday.GetGdcHoliday: TgdcHoliday;
begin
  Result := GetObject as TgdcHoliday;
end;

function TwrpGdcHoliday.IsHoliday(TheDate: TDateTime): WordBool;
begin
  Result := GetGdcHoliday.IsHoliday(TheDate);
end;

function TwrpGdcHoliday.QIsHoliday(TheDate: TDateTime): WordBool;
begin
  Result := GetGdcHoliday.QIsHoliday(TheDate);
end;

{ TwrpGDCAcctEntryLine }

function TwrpGDCAcctEntryLine.Get_AccountPart: WideString;
begin
  Result := GetGDCAcctEntryLine.AccountPart;
end;

function TwrpGDCAcctEntryLine.Get_RecordKey: Integer;
begin
    Result := GetGDCAcctEntryLine.RecordKey;
end;

function TwrpGDCAcctEntryLine.GetGDCAcctEntryLine: TgdcAcctEntryLine;
begin
  Result := GetObject as TgdcAcctEntryLine;
end;

procedure TwrpGDCAcctEntryLine.Set_AccountPart(const Value: WideString);
begin
  GetGDCAcctEntryLine.AccountPart := Value;
end;

procedure TwrpGDCAcctEntryLine.Set_RecordKey(Value: Integer);
begin
  GetGDCAcctEntryLine.RecordKey := Value;
end;

function TwrpGDCAcctEntryLine.Get_gdcQuantity: IgsGdcAcctQuantity;
begin
  Result := GetGdcOLEObject(GetGDCAcctEntryLine.gdcQuantity) as IgsGdcAcctQuantity;
end;

{ TwrpGDCAcctSimpleRecord }

function TwrpGDCAcctSimpleRecord.Get_CreditEntryLine: IgsGDCAcctEntryLine;
begin
  Result := GetGdcOLEObject(GetGDCAcctSimpleRecord.CreditEntryLine) as IgsGDCAcctEntryLine;
end;

function TwrpGDCAcctSimpleRecord.Get_DebitEntryLine: IgsGDCAcctEntryLine;
begin
  Result := GetGdcOLEObject(GetGDCAcctSimpleRecord.DebitEntryLine) as IgsGDCAcctEntryLine;
end;

function TwrpGDCAcctSimpleRecord.GetGDCAcctSimpleRecord: TgdcAcctSimpleRecord;
begin
  Result := GetObject as TgdcAcctSimpleRecord;
end;

function TwrpGDCAcctSimpleRecord.Get_Document: IgsGDCDocument;
begin
  Result := GetGdcOLEObject(GetGDCAcctSimpleRecord.Document) as IgsGDCDocument;
end;

function TwrpGDCAcctSimpleRecord.Get_TransactionKey: Integer;
begin
  Result := GetGDCAcctSimpleRecord.TransactionKey;
end;

procedure TwrpGDCAcctSimpleRecord.Set_Document(
  const Value: IgsGDCDocument);
begin
  GetGDCAcctSimpleRecord.Document := InterfaceToObject(Value) as TgdcDocument;
end;

procedure TwrpGDCAcctSimpleRecord.Set_TransactionKey(Value: Integer);
begin
  GetGDCAcctSimpleRecord.TransactionKey := Value;
end;

{ TwrpGDCAccount }

function TwrpGDCAccount.Get_IgnoryQuestion: WordBool;
begin
 Result := GetGDCAccount.IgnoryQuestion;
end;

function TwrpGDCAccount.GetGDCAccount: TgdcAccount;
begin
  Result := GetObject as TgdcAccount;
end;

procedure TwrpGDCAccount.Set_IgnoryQuestion(Value: WordBool);
begin
  GetGDCAccount.IgnoryQuestion := Value;
end;

function TwrpGDCAccount.CheckAccount(const Code,
  Account: WideString): WordBool;
begin
  Result := GetGDCAccount.CheckAccount(Code, Account);
end;

function TwrpGDCAccount.CheckDouble(const AnAccount,
  ABankCode: WideString): WordBool;
begin
  Result := GetGDCAccount.CheckDouble(AnAccount, ABankCode);
end;

{ TwrpGdc_frmG }

function TwrpGdc_frmG.GetGdc_frmG: Tgdc_frmG;
begin
  Result := GetObject as Tgdc_frmG;
end;

procedure TwrpGdc_frmG.SetShortCut(Master: WordBool);
begin
  TCrackGdc_frmG(GetGdc_frmG).SetShortCut(Master);
end;

function TwrpGdc_frmG.GetMainBookmarkList: IgsBookmarkList;
begin
  Result := GetGdcOLEObject(GetGdc_frmG.GetMainBookmarkList) as IgsBookmarkList;
end;

function TwrpGdc_frmG.Get_gdcChooseObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdc_frmG.gdcChooseObject) as IgsGDCBase;
end;

procedure TwrpGdc_frmG.SetChoose(const AnObject: IgsGDCBase);
begin
  GetGdc_frmG.SetChoose(InterfaceToObject(AnObject) as TgdcBase);
end;

procedure TwrpGdc_frmG.SetupSearchPanel(const Obj: IgsGDCBase;
  const PN: IgsPanel; const SB: IgsScrollBox; var FO, PreservedConditions: OleVariant);
var
  FFO: TStringList;
  FPreservedConditions: String;
begin
  if VarType(FO) = varEmpty then
  begin
    FFO := nil;
  end else
  begin
    FFO := InterfaceToObject(FO) as TStringList;
  end;
  FPreservedConditions := PreservedConditions;
  TCrackGdc_frmG(GetGDC_frmG).SetupSearchPanel(InterfaceToObject(Obj) as TgdcBase,
    InterfaceToObject(PN) as TPanel, InterfaceToObject(SB) as TScrollBox,
    nil, FFO, FPreservedConditions);
  FO := GetGdcOLEObject(FFO) as IDispatch;
  PreservedConditions := FPreservedConditions;
end;

procedure TwrpGdc_frmG.SearchExecute(const Obj: IgsGDCBase;
  const SB: IgsPanel; var FO, PreservedConditions: OleVariant);
var
  FFO: TStringList;
  FPreservedConditions: String;
begin
  if VarType(FO) = varEmpty then
  begin
    FFO := nil;
  end else
  begin
    FFO := InterfaceToObject(FO) as TStringList;
  end;
  FPreservedConditions := PreservedConditions;
  TCrackGdc_frmG(GetGDC_frmG).SearchExecute(InterfaceToObject(Obj) as TgdcBase,
    InterfaceToObject(SB) as TPanel, FFO, FPreservedConditions);
  FO := GetGdcOLEObject(FFO) as IDispatch;
  PreservedConditions := FPreservedConditions;
end;

procedure TwrpGdc_frmG.SetLocalizeListName(const AGrid: IgsGsIBGrid);
begin
  TCrackGdc_frmG(GetGDC_frmG).SetLocalizeListName(InterfaceToObject(AGrid) as TgsIBGrid);
end;

function TwrpGdc_frmG.Get_gdcLinkChoose: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGDC_frmG.gdcLinkChoose) as IgsGDCBase;
end;

procedure TwrpGdc_frmG.Set_gdcLinkChoose(const Value: IgsGDCBase);
begin
  GetGDC_frmG.gdcLinkChoose := InterfaceToObject(Value) as TgdcBase;
end;

function TwrpGdc_frmG.Get_InChoose: WordBool;
begin
  Result := GetGdc_frmG.InChoose;
end;

function TwrpGdc_frmG.Get_ChosenIDInOrder: OleVariant;
begin
  Result := GetGDC_frmG.ChosenIDInOrder;
end;

{ TwrpGdc_frmMDH }

function TwrpGdc_frmMDH.Get_gdcDetailObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdc_frmMDH.gdcDetailObject) as IgsGDCBase;
end;

function TwrpGdc_frmMDH.GetGdc_frmMDH: Tgdc_frmMDH;
begin
  Result := GetObject as Tgdc_frmMDH;
end;

procedure TwrpGdc_frmMDH.Set_gdcDetailObject(const Value: IgsGDCBase);
begin
  GetGdc_frmMDH.gdcDetailObject := InterfaceToObject(Value) as TgdcBase;
end;

function TwrpGdc_frmMDH.GetDetailBookmarkList: IgsBookmarkList;
begin
  Result := GetGdcOLEObject(GetGdc_frmMDH.GetDetailBookmarkList) as IgsBookmarkList;
end;

{ TwrpGridCheckBox }

procedure TwrpGridCheckBox.AddCheckInt(Value: Integer);
begin
  GetGridCheckBox.AddCheck(Value);
end;

procedure TwrpGridCheckBox.AddCheckStr(const Value: WideString);
begin
  GetGridCheckBox.AddCheck(Value);
end;

procedure TwrpGridCheckBox.BeginUpdate;
begin
  GetGridCheckBox.BeginUpdate;
end;

procedure TwrpGridCheckBox.Clear;
begin
  GetGridCheckBox.Clear;
end;

procedure TwrpGridCheckBox.DeleteCheckInt(Value: Integer);
begin
  GetGridCheckBox.DeleteCheck(Value);
end;

procedure TwrpGridCheckBox.DeleteCheckStr(const Value: WideString);
begin
  GetGridCheckBox.DeleteCheck(Value);
end;

procedure TwrpGridCheckBox.EndUpdate;
begin
  GetGridCheckBox.EndUpdate;
end;

function TwrpGridCheckBox.Get_CheckCount: Integer;
begin
  Result := GetGridCheckBox.CheckCount;
end;

function TwrpGridCheckBox.Get_CheckList: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGridCheckBox.CheckList) as IgsStringList;
end;

function TwrpGridCheckBox.Get_DisplayField: WideString;
begin
  Result := GetGridCheckBox.DisplayField;
end;

function TwrpGridCheckBox.Get_FieldName: WideString;
begin
  Result := GetGridCheckBox.FieldName;
end;

function TwrpGridCheckBox.Get_GlyphChecked: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetGridCheckBox.GlyphChecked) as IgsBitmap;
end;

function TwrpGridCheckBox.Get_GlyphUnChecked: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetGridCheckBox.GlyphUnChecked) as IgsBitmap;
end;

function TwrpGridCheckBox.Get_Grid: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetGridCheckBox.Grid) as IgsgsCustomDBGrid;
end;

function TwrpGridCheckBox.Get_IntCheck(Index: Integer): Integer;
begin
  Result := GetGridCheckBox.IntCheck[Index];
end;

function TwrpGridCheckBox.Get_RecordChecked: WordBool;
begin
  Result := GetGridCheckBox.RecordChecked;
end;

function TwrpGridCheckBox.Get_StrCheck(Index: Integer): WideString;
begin
  Result := GetGridCheckBox.StrCheck[index];
end;

function TwrpGridCheckBox.Get_Visible: WordBool;
begin
  Result := GetGridCheckBox.Visible;
end;

function TwrpGridCheckBox.GetGridCheckBox: TGridCheckBox;
begin
  Result := GetObject as TGridCheckBox;
end;

function TwrpGridCheckBox.GetNamePath: WideString;
begin
  Result := GetGridCheckBox.GetNamePath;
end;

procedure TwrpGridCheckBox.Set_CheckList(const Value: IgsStringList);
begin
  GetGridCheckBox.CheckList := InterfaceToObject(Value) as TStringList;
end;

procedure TwrpGridCheckBox.Set_DisplayField(const Value: WideString);
begin
  GetGridCheckBox.DisplayField := Value;
end;

procedure TwrpGridCheckBox.Set_FieldName(const Value: WideString);
begin
  GetGridCheckBox.FieldName := Value;
end;

procedure TwrpGridCheckBox.Set_GlyphChecked(const Value: IgsBitmap);
begin
  GetGridCheckBox.GlyphChecked := InterfaceToObject(Value) as Graphics.TBitmap;
end;

procedure TwrpGridCheckBox.Set_GlyphUnChecked(const Value: IgsBitmap);
begin
  GetGridCheckBox.GlyphUnChecked := InterfaceToObject(Value) as Graphics.TBitmap;
end;

procedure TwrpGridCheckBox.Set_Visible(Value: WordBool);
begin
  GetGridCheckBox.Visible := Value;
end;

function TwrpGridCheckBox.Get_FirstColumn: WordBool;
begin
  Result := GetGridCheckBox.FirstColumn;
end;

procedure TwrpGridCheckBox.Set_FirstColumn(Value: WordBool);
begin
  GetGridCheckBox.FirstColumn := Value;
end;

{ TwrpColumnExpand }

function TwrpColumnExpand.Get_DisplayField: WideString;
begin
  Result := GetColumnExpand.DisplayField;
end;

function TwrpColumnExpand.Get_FieldName: WideString;
begin
  Result := GetColumnExpand.FieldName;
end;

function TwrpColumnExpand.Get_Grid: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetColumnExpand.Grid) as IgsGsCustomDBGrid;
end;

function TwrpColumnExpand.Get_LineCount: Integer;
begin
  Result := GetColumnExpand.LineCount;
end;

function TwrpColumnExpand.Get_Options: WideString;
begin
  Result := ' ';
  if ceoAddField in GetColumnExpand.Options then
    Result := Result + 'ceoAddField ';
  if ceoAddFieldMultiline in GetColumnExpand.Options then
    Result := Result + 'ceoAddFieldMultiline ';
  if ceoMultiline in GetColumnExpand.Options then
    Result := Result + 'ceoMultiline ';
end;

function TwrpColumnExpand.GetColumnExpand: TColumnExpand;
begin
  Result := GetObject as TColumnExpand;
end;

function TwrpColumnExpand.IsExpandValid(
  const ADataLink: IgsGridDataLink): WordBool;
begin
  Result := GetColumnExpand.IsExpandValid(InterfaceToObject(ADataLink) as TGridDataLink);
end;

procedure TwrpColumnExpand.Set_DisplayField(const Value: WideString);
begin
  GetColumnExpand.DisplayField := Value;
end;

procedure TwrpColumnExpand.Set_FieldName(const Value: WideString);
begin
  GetColumnExpand.FieldName := Value;
end;

procedure TwrpColumnExpand.Set_LineCount(Value: Integer);
begin
  GetColumnExpand.LineCount := Value;
end;

procedure TwrpColumnExpand.Set_Options(const Value: WideString);
var
  LOptions: TColumnExpandOptions;
begin
  LOptions := [];
  if Pos('CEOADDFIELD', Value) > 0 then
    include(LOptions, CEOADDFIELD);
  if Pos('CEOADDFIELDMULTILINE', Value) > 0 then
    include(LOptions, CEOADDFIELDMULTILINE);
  if Pos('CEOMULTILINE', Value) > 0 then
    include(LOptions, CEOMULTILINE);

  GetColumnExpand.Options := LOptions;
end;

{ TwrpColumnExpands }

function TwrpColumnExpands.Add: IgsColumnExpand;
begin
  Result := GetGdcOLEObject(GetColumnExpands.Add) as IgsColumnExpand;
end;

function TwrpColumnExpands.Get_Grid: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetColumnExpands.Grid) as IgsgsCustomDBGrid;
end;

function TwrpColumnExpands.Get_Items(Index: Integer): IgsColumnExpand;
begin
  Result := GetGdcOLEObject(GetColumnExpands.Items[index]) as IgsColumnExpand;
end;

function TwrpColumnExpands.GetColumnExpands: TColumnExpands;
begin
  Result := GetObject as TColumnExpands;
end;

procedure TwrpColumnExpands.Set_Items(Index: Integer;
  const Value: IgsColumnExpand);
begin
  GetColumnExpands.Items[Index] := InterfaceToObject(Value) as TColumnExpand;
end;

{ TwrpFilterCondition }

procedure TwrpFilterCondition.Assign_(const Source: IgsFilterCondition);
begin
  GetFilterCondition.Assign(InterfaceToObject(Source) as TFilterCondition);
end;

procedure TwrpFilterCondition.Clear;
begin
  GetFilterCondition.Clear;
end;

function TwrpFilterCondition.Get_ConditionType: Integer;
begin
  Result := GetFilterCondition.ConditionType;
end;

function TwrpFilterCondition.Get_SubFilter: IgsFilterConditionList;
begin
  Result := GetGdcOleObject(GetFilterCondition.SubFilter) as IgsFilterConditionList;
end;

function TwrpFilterCondition.Get_Value1: WideString;
begin
  Result := GetFilterCondition.Value1;
end;

function TwrpFilterCondition.Get_Value2: WideString;
begin
  Result := GetFilterCondition.Value2;
end;

function TwrpFilterCondition.Get_ValueList: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetFilterCondition.ValueList);
end;

function TwrpFilterCondition.GetFilterCondition: TFilterCondition;
begin
  Result := GetObject as TFilterCondition;
end;

procedure TwrpFilterCondition.ReadFromStream(const S: IgsStream);
begin
  GetFilterCondition.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFilterCondition.Set_ConditionType(Value: Integer);
begin
  GetFilterCondition.ConditionType := Value;
end;

procedure TwrpFilterCondition.Set_SubFilter(
  const Value: IgsFilterConditionList);
begin
  GetFilterCondition.SubFilter := InterfaceToObject(Value) as TFilterConditionList;
end;

procedure TwrpFilterCondition.Set_Value1(const Value: WideString);
begin
  GetFilterCondition.Value1 := Value;
end;

procedure TwrpFilterCondition.Set_Value2(const Value: WideString);
begin
  GetFilterCondition.Value2 := Value;
end;

procedure TwrpFilterCondition.Set_ValueList(const Value: IgsStrings);
begin
  GetFilterCondition.ValueList := IgsStringsToTStrings(Value);
end;

procedure TwrpFilterCondition.WriteToStream(const S: IgsStream);
begin
  GetFilterCondition.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpFilterConditionList }

function TwrpFilterConditionList.AddCondition(
  const AnConditionData: IgsFilterCondition): Integer;
begin
  Result :=
    GetFilterConditionList.AddCondition(InterfaceToObject(AnConditionData) as TFilterCondition);
end;

function TwrpFilterConditionList.AddConditionWithParams(
  const AnFieldData: IgsfltFieldData; AnConditionType: Integer;
  const AnValue1, AnValue2: WideString;
  const AnSubFilter: IgsFilterConditionList;
  const AnValueList: IgsStringList): Integer;
begin
  Result :=
    GetFilterConditionList.AddCondition(InterfaceToObject(AnFieldData) as TfltFieldData,
    AnConditionType, AnValue1, AnValue2, InterfaceToObject(AnSubFilter) as TFilterConditionList,
    InterfaceToObject(AnValueList) as TStringList);
end;

procedure TwrpFilterConditionList.Assign_(
  const Source: IgsFilterConditionList);
begin
  GetFilterConditionList.Assign(InterfaceToObject(Source) as TFilterConditionList);
end;

function TwrpFilterConditionList.CheckCondition(
  const AnConditionData: IgsFilterCondition): WordBool;
begin
  Result := GetFilterConditionList.CheckCondition(InterfaceToObject(AnConditionData) as TFilterCondition);
end;

procedure TwrpFilterConditionList.DeleteCondition(Index: Integer);
begin
  GetFilterConditionList.DeleteCondition(Index);
end;

function TwrpFilterConditionList.Get_Conditions(
  Index: Integer): IgsFilterCondition;
begin
  Result := GetGdcOLEObject(GetFilterConditionList.Conditions[Index]) as IgsFilterCondition;
end;

function TwrpFilterConditionList.Get_FilterText: WideString;
begin
  Result := GetFilterConditionList.FilterText;
end;

function TwrpFilterConditionList.Get_IsAndCondition: WordBool;
begin
  Result := GetFilterConditionList.IsAndCondition;
end;

function TwrpFilterConditionList.Get_IsDistinct: WordBool;
begin
  Result := GetFilterConditionList.IsDistinct;
end;

function TwrpFilterConditionList.GetFilterConditionList: TFilterConditionList;
begin
  Result := GetObject as TFilterConditionList;
end;

procedure TwrpFilterConditionList.ReadFromStream(const S: IgsStream);
begin
  GetFilterConditionList.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFilterConditionList.Set_IsAndCondition(Value: WordBool);
begin
  GetFilterConditionList.IsAndCondition := Value;
end;

procedure TwrpFilterConditionList.Set_IsDistinct(Value: WordBool);
begin
  GetFilterConditionList.IsDistinct := Value;
end;

procedure TwrpFilterConditionList.WriteToStream(const S: IgsStream);
begin
  GetFilterConditionList.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpFltFieldData }

procedure TwrpFltFieldData.Assign_(const Source: IgsfltFieldData);
begin
  GetFltFieldData.Assign(InterfaceToObject(Source) as TfltFieldData);
end;

function TwrpFltFieldData.Get_AttrKey: Integer;
begin
  Result := GetFltFieldData.AttrKey;
end;

function TwrpFltFieldData.Get_AttrRefKey: Integer;
begin
  Result := GetFltFieldData.AttrRefKey;
end;

function TwrpFltFieldData.Get_DisplayName: WideString;
begin
  Result := GetFltFieldData.DisplayName;
end;

function TwrpFltFieldData.Get_FieldType: Integer;
begin
  Result := GetFltFieldData.FieldType;
end;

function TwrpFltFieldData.Get_IsReference: WordBool;
begin
  Result := GetFltFieldData.IsReference;
end;

function TwrpFltFieldData.Get_IsTree: WordBool;
begin
  Result := GetFltFieldData.IsTree;
end;

function TwrpFltFieldData.Get_LinkSourceField: WideString;
begin
  Result := GetFltFieldData.LinkSourceField;
end;

function TwrpFltFieldData.Get_LinkTable: WideString;
begin
  Result := GetFltFieldData.LinkTable;
end;

function TwrpFltFieldData.Get_LinkTargetField: WideString;
begin
  Result := GetFltFieldData.LinkTargetField;
end;

function TwrpFltFieldData.Get_LinkTargetFieldType: Integer;
begin
  Result := GetFltFieldData.LinkTargetFieldType;
end;

function TwrpFltFieldData.Get_LocalTable: WideString;
begin
  Result := GetFltFieldData.LocalTable;
end;

function TwrpFltFieldData.Get_PrimaryName: WideString;
begin
  Result := GetFltFieldData.PrimaryName;
end;

function TwrpFltFieldData.Get_RefField: WideString;
begin
  Result := GetFltFieldData.RefField;
end;

function TwrpFltFieldData.Get_RefTable: WideString;
begin
  Result := GetFltFieldData.RefTable;
end;

function TwrpFltFieldData.Get_TableAlias: WideString;
begin
  Result := GetFltFieldData.TableAlias;
end;

function TwrpFltFieldData.Get_TableName: WideString;
begin
  Result := GetFltFieldData.TableName;
end;

function TwrpFltFieldData.GetFltFieldData: TFltFieldData;
begin
  Result := GetObject as TfltFieldData;
end;

procedure TwrpFltFieldData.ReadFromStream(const S: IgsStream);
begin
  GetFltFieldData.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFltFieldData.Set_AttrKey(Value: Integer);
begin
  GetFltFieldData.AttrKey := Value;
end;

procedure TwrpFltFieldData.Set_AttrRefKey(Value: Integer);
begin
  GetFltFieldData.AttrRefKey := Value;
end;

procedure TwrpFltFieldData.Set_DisplayName(const Value: WideString);
begin
  GetFltFieldData.DisplayName := Value;
end;

procedure TwrpFltFieldData.Set_FieldType(Value: Integer);
begin
  GetFltFieldData.FieldType := Value;
end;

procedure TwrpFltFieldData.Set_IsReference(Value: WordBool);
begin
  GetFltFieldData.IsReference := Value;
end;

procedure TwrpFltFieldData.Set_IsTree(Value: WordBool);
begin
  GetFltFieldData.IsTree := Value;
end;

procedure TwrpFltFieldData.Set_LinkSourceField(const Value: WideString);
begin
  GetFltFieldData.LinkSourceField := Value;
end;

procedure TwrpFltFieldData.Set_LinkTable(const Value: WideString);
begin
  GetFltFieldData.LinkTable := Value;
end;

procedure TwrpFltFieldData.Set_LinkTargetField(const Value: WideString);
begin
  GetFltFieldData.LinkTargetField := Value;
end;

procedure TwrpFltFieldData.Set_LinkTargetFieldType(Value: Integer);
begin
  GetFltFieldData.LinkTargetFieldType := Value;
end;

procedure TwrpFltFieldData.Set_LocalTable(const Value: WideString);
begin
  GetFltFieldData.LocalTable := Value;
end;

procedure TwrpFltFieldData.Set_PrimaryName(const Value: WideString);
begin
  GetFltFieldData.PrimaryName := Value;
end;

procedure TwrpFltFieldData.Set_RefField(const Value: WideString);
begin
  GetFltFieldData.RefField := Value;
end;

procedure TwrpFltFieldData.Set_RefTable(const Value: WideString);
begin
  GetFltFieldData.RefTable := Value;
end;

procedure TwrpFltFieldData.Set_TableAlias(const Value: WideString);
begin
  GetFltFieldData.TableAlias := Value;
end;

procedure TwrpFltFieldData.Set_TableName(const Value: WideString);
begin
  GetFltFieldData.TableName := Value;
end;

procedure TwrpFltFieldData.WriteToStream(const S: IgsStream);
begin
  GetFltFieldData.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpFilterOrderBy }

procedure TwrpFilterOrderBy.Assign_(const Source: IgsFilterOrderBy);
begin
  GetFilterOrderBy.Assign(InterfaceToObject(Source) as TFilterOrderBy);
end;

procedure TwrpFilterOrderBy.Clear;
begin
  GetFilterOrderBy.Clear;
end;

function TwrpFilterOrderBy.Get_FieldName: WideString;
begin
  Result := GetFilterOrderBy.FieldName;
end;

function TwrpFilterOrderBy.Get_IsAscending: WordBool;
begin
  Result := GetFilterOrderBy.IsAscending;
end;

function TwrpFilterOrderBy.Get_LocalField: WideString;
begin
  Result := GetFilterOrderBy.LocalField;
end;

function TwrpFilterOrderBy.Get_TableAlias: WideString;
begin
  Result := GetFilterOrderBy.TableAlias;
end;

function TwrpFilterOrderBy.Get_TableName: WideString;
begin
  Result := GetFilterOrderBy.TableName;
end;

function TwrpFilterOrderBy.GetFilterOrderBy: TFilterOrderBy;
begin
  Result := GetObject as TFilterOrderBy;
end;

procedure TwrpFilterOrderBy.ReadFromStream(const S: IgsStream);
begin
  GetFilterOrderBy.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFilterOrderBy.Set_FieldName(const Value: WideString);
begin
  GetFilterOrderBy.FieldName := Value;
end;

procedure TwrpFilterOrderBy.Set_IsAscending(Value: WordBool);
begin
  GetFilterOrderBy.IsAscending := Value;
end;

procedure TwrpFilterOrderBy.Set_LocalField(const Value: WideString);
begin
  GetFilterOrderBy.LocalField := Value;
end;

procedure TwrpFilterOrderBy.Set_TableAlias(const Value: WideString);
begin
  GetFilterOrderBy.TableAlias := Value;
end;

procedure TwrpFilterOrderBy.Set_TableName(const Value: WideString);
begin
  GetFilterOrderBy.TableName := Value;
end;

procedure TwrpFilterOrderBy.WriteToStream(const S: IgsStream);
begin
  GetFilterOrderBy.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpFltStringList }

function TwrpFltStringList.Get_ValuesOfIndex(Index: Integer): WideString;
begin
  Result := GetFltStringList.ValuesOfIndex[Index];
end;

function TwrpFltStringList.GetFltStringList: TFltStringList;
begin
  Result := GetObject as TfltStringList;
end;

procedure TwrpFltStringList.RemoveDouble;
begin
  GetFltStringList.RemoveDouble;
end;

procedure TwrpFltStringList.Set_ValuesOfIndex(Index: Integer;
  const Value: WideString);
begin
  GetFltStringList.ValuesOfIndex[Index] := Value;
end;

{ TwrpFilterData }

procedure TwrpFilterData.Assign_(const Value: IgsFilterData);
begin
  GetFilterData.Assign(InterfaceToObject(Value) as TFilterData);
end;

procedure TwrpFilterData.Clear;
begin
  GetFilterData.Clear;
end;

function TwrpFilterData.Get_ConditionList: IgsFilterConditionList;
begin
  Result := GetGdcOLEObject(GetFilterData.ConditionList) as IgsFilterConditionList;
end;

function TwrpFilterData.Get_FilterText: WideString;
begin
  Result := GetFilterData.FilterText;
end;

function TwrpFilterData.Get_OrderByList: IgsFilterOrderByList;
begin
  Result := GetGdcOLEObject(GetFilterData.OrderByList) as IgsFilterOrderByList;
end;

function TwrpFilterData.Get_OrderText: WideString;
begin
  Result := GetFilterData.OrderText;
end;

function TwrpFilterData.GetFilterData: TFilterData;
begin
  Result := GetObject as TFilterData;
end;

procedure TwrpFilterData.ReadFromStream(const S: IgsStream);
begin
  GetFilterData.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFilterData.Set_ConditionList(
  const Value: IgsFilterConditionList);
begin
  GetFilterData.ConditionList := InterfaceToObject(Value) as TFilterConditionList;
end;

procedure TwrpFilterData.Set_OrderByList(
  const Value: IgsFilterOrderByList);
begin
  GetFilterData.OrderByList := InterfaceToObject(Value) as TFilterOrderByList;
end;

procedure TwrpFilterData.WriteToStream(const S: IgsStream);
begin
  GetFilterData.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpFilterOrderByList }

function TwrpFilterOrderByList.AddOrderBy(
  const OrderByData: IgsFilterOrderBy): Integer;
begin
  Result := GetFilterOrderByList.AddOrderBy(InterfaceToObject(OrderByData) as TFilterOrderBy);
end;

function TwrpFilterOrderByList.AddOrderByWithParams(const TableName,
  TableAlias, LocalTable, FieldName, LocalField: WideString;
  Ascending: WordBool): Integer;
begin
  Result := GetFilterOrderByList.AddOrderBy(TableName,
    TableAlias, LocalTable, FieldName, LocalField, Ascending);
end;

procedure TwrpFilterOrderByList.Assign_(
  const Source: IgsFilterOrderByList);
begin
  GetFilterOrderByList.Assign(InterfaceToObject(Source) as TFilterOrderByList);
end;

procedure TwrpFilterOrderByList.DeleteOrderBy(Index: Integer);
begin
  GetFilterOrderByList.DeleteOrderBy(Index);
end;

function TwrpFilterOrderByList.Get_OnlyIndexField: WordBool;
begin
  Result := GetFilterOrderByList.OnlyIndexField;
end;

function TwrpFilterOrderByList.Get_OrdersBy(
  Index: Integer): IgsFilterOrderBy;
begin
  Result := GetGdcOLEObject(GetFilterOrderByList.OrdersBy[index]) as IgsFilterOrderBy;
end;

function TwrpFilterOrderByList.Get_OrderText: WideString;
begin
  Result := GetFilterOrderByList.OrderText;
end;

function TwrpFilterOrderByList.GetFilterOrderByList: TFilterOrderByList;
begin
  Result := GetObject as TFilterOrderByList;
end;

procedure TwrpFilterOrderByList.ReadFromStream(const S: IgsStream);
begin
  GetFilterOrderByList.ReadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpFilterOrderByList.Set_OnlyIndexField(Value: WordBool);
begin
  GetFilterOrderByList.OnlyIndexField := Value;
end;

procedure TwrpFilterOrderByList.WriteToStream(const S: IgsStream);
begin
  GetFilterOrderByList.WriteToStream(InterfaceToObject(S) as TStream);
end;

{ TwrpGsStorageItem }

function TwrpGsStorageItem.Find(const AList: IgsStringList; const ASearchString,
  ASearchOptions: WideString): WordBool;
var
  LOptions: TgstSearchOptions;
begin
  LOptions := [];
  if Pos('GSTSOVALUE', AnsiUpperCase(ASearchOptions)) > 0 then
    Include(LOptions, GSTSOVALUE);
  if Pos('GSTSOFOLDER', AnsiUpperCase(ASearchOptions)) > 0 then
    Include(LOptions, GSTSOFOLDER);
  if Pos('GSTSODATA', AnsiUpperCase(ASearchOptions)) > 0 then
    Include(LOptions, GSTSODATA);
  Result := False;
  Result := GetGsStorageItem.Find(InterfaceToObject(AList) as TStringList,
    ASearchString, LOptions);
end;

function TwrpGsStorageItem.Get_DataSize: Integer;
begin
  Result := GetGsStorageItem.DataSize;
end;

function TwrpGsStorageItem.Get_Name: WideString;
begin
  Result := GetGsStorageItem.Name;
end;

function TwrpGsStorageItem.Get_Parent: IgsGsStorageItem;
begin
  Result := GetGdcOLEObject(GetGsStorageItem.Parent) as IgsGsStorageItem;
end;

function TwrpGsStorageItem.Get_Path: WideString;
begin
  Result := GetGsStorageItem.Path;
end;

function TwrpGsStorageItem.Get_Storage: IgsGsStorage;
begin
  Result := GetGdcOLEObject(GetGsStorageItem.Storage) as IgsGsStorage;
end;

function TwrpGsStorageItem.GetGsStorageItem: TGsStorageItem;
begin
  Result := GetObject as TGsStorageItem;
end;

function TwrpGsStorageItem.GetStorageName: WideString;
begin
  if GetGsStorageItem.Storage <> nil then
    Result := GetGsStorageItem.Storage.Name
  else
    Result := '';  
end;

procedure TwrpGsStorageItem.LoadFromFile(const FileName: WideString;
  FileFormat: TgsGsStorageFileFormat);
begin
  GetGsStorageItem.LoadFromFile(FileName, TgsStorageFileFormat(FileFormat));
end;

procedure TwrpGsStorageItem.SaveToFile(const FileName: WideString;
  FileFormat: TgsGsStorageFileFormat);
begin
  GetGsStorageItem.SaveToFile(FileName, TgsStorageFileFormat(FileFormat));
end;

procedure TwrpGsStorageItem.Set_Name(const Value: WideString);
begin
  GetGsStorageItem.Name := Value;
end;

procedure TwrpGsStorageItem.Drop;
begin
  GetGsStorageItem.Drop;
end;

{ TwrpGsStorageFolder }

function TwrpGsStorageFolder.AddFolder(
  const F: IgsGsStorageFolder): Integer;
begin
  GetGsStorageFolder.AddFolder(InterfaceToObject(F) as TgsStorageFolder);
  Result := 0;
end;

procedure TwrpGsStorageFolder.BuildTreeView(const N: IgsTreeNode);
begin
  GetGsStorageFolder.BuildTreeView(InterfaceToObject(N) as TTreeNode);
end;

procedure TwrpGsStorageFolder.Clear;
begin
  GetGsStorageFolder.Clear;
end;

function TwrpGsStorageFolder.CreateFolder(const AName: WideString): IgsGsStorageFolder;
begin
  Result := GetGdcOLEObject(GetGsStorageFolder.CreateFolder(AName)) as IgsgsStorageFolder;
end;

function TwrpGsStorageFolder.DeleteFolder(const AName: WideString): WordBool;
begin
  Result := GetGsStorageFolder.DeleteFolder(AName);
end;

function TwrpGsStorageFolder.DeleteValue(
  const AValueName: WideString): WordBool;
begin
  Result := GetGsStorageFolder.DeleteValue(AValueName);
end;

procedure TwrpGsStorageFolder.ExtractFolder(const F: IgsGsStorageFolder);
begin
  GetGsStorageFolder.ExtractFolder(InterfaceToObject(F) as TgsStorageFolder);
end;

function TwrpGsStorageFolder.FindFolder(const F: IgsGsStorageFolder;
  GoSubFolders: WordBool): WordBool;
begin
  Result := GetGsStorageFolder.FindFolder(InterfaceToObject(F) as
    TgsStorageFolder, GoSubFolders);
end;

function TwrpGsStorageFolder.FolderByName(
  const AName: WideString): IgsGsStorageFolder;
begin
  Result := GetGdcOLEObject(GetGsStorageFolder.FolderByName(AName)) as IgsGsStorageFolder;
end;

function TwrpGsStorageFolder.FolderExists(
  const AFolderName: WideString): WordBool;
begin
  Result := GetGsStorageFolder.FolderExists(AFolderName);
end;

function TwrpGsStorageFolder.Get_Folders(
  Index: Integer): IgsGsStorageFolder;
begin
  Result := GetGdcOLEObject(GetGsStorageFolder.Folders[Index]) as IgsGsStorageFolder;
end;

function TwrpGsStorageFolder.Get_FoldersCount: Integer;
begin
  Result := GetGsStorageFolder.FoldersCount;
end;

function TwrpGsStorageFolder.Get_Values(Index: Integer): IgsGsStorageValue;
begin
  Result := GetGdcOLEObject(GetGsStorageFolder.Values[Index]) as IgsGsStorageValue;
end;

function TwrpGsStorageFolder.Get_ValuesCount: Integer;
begin
  Result := GetGsStorageFolder.ValuesCount;
end;

function TwrpGsStorageFolder.GetGsStorageFolder: TGsStorageFolder;
begin
  Result := GetObject as TGsStorageFolder;
end;

function TwrpGsStorageFolder.MoveFolder(
  const NewParent: IgsGsStorageFolder): WordBool;
begin
  Result := False; //GetGsStorageFolder.MoveFolder(InterfaceToObject(NewParent) as TgsStorageFolder)
end;

function TwrpGsStorageFolder.OpenFolder(const APath: WideString;
  CanCreate: WordBool): IgsGsStorageFolder;
begin
  Result := GetGdcOLEObject(GetGsStorageFolder.OpenFolder(APath, CanCreate)) as IgsGsStorageFolder;
end;

function TwrpGsStorageFolder.ReadBoolean(const AValueName: WideString;
  Default: WordBool): WordBool;
begin
  Result := GetGsStorageFolder.ReadBoolean(AValueName, Default);
end;

function TwrpGsStorageFolder.ReadCurrency(const AValueName: WideString;
  Default: Currency): Currency;
begin
  Result := GetGsStorageFolder.ReadCurrency(AValueName, Default);
end;

function TwrpGsStorageFolder.ReadDateTime(const AValueName: WideString;
  Default: TDateTime): TDateTime;
begin
  Result := GetGsStorageFolder.ReadDateTime(AValueName, Default);
end;

procedure TwrpGsStorageFolder.LoadFromStream(const S: IgsStream);
begin
  GetGsStorageFolder.LoadFromStream(InterfaceToObject(S) as TStream);
end;

function TwrpGsStorageFolder.ReadInteger(const AValueName: WideString;
  Default: Integer): Integer;
begin
  Result := GetGsStorageFolder.ReadInteger(AValueName, Default);
end;

procedure TwrpGsStorageFolder.ReadStream(const AValueName: WideString; const S: IgsStream);
begin
  GetGsStorageFolder.ReadStream(AValueName, InterfaceToObject(S) as TStream);
end;

function TwrpGsStorageFolder.ReadString(const AValueName,
  Default: WideString): WideString;
begin
  Result := GetGsStorageFolder.ReadString(AValueName, Default)
end;

procedure TwrpGsStorageFolder.ShowPropDialog;
begin
  GetGsStorageFolder.ShowPropDialog;
end;

function TwrpGsStorageFolder.ValueByName(
  const AValueName: WideString): IgsGsStorageValue;
begin
  Result := GetGdcOleObject(GetGsStorageFolder.ValueByName(AValueName)) as IgsGsStorageValue;
end;

function TwrpGsStorageFolder.ValueExists(
  const AValueName: WideString): WordBool;
begin
  Result := GetGsStorageFolder.ValueExists(AValueName)
end;

procedure TwrpGsStorageFolder.WriteBoolean(const AValueName: WideString;
  Default: WordBool);
begin
  GetGsStorageFolder.WriteBoolean(AValueName, Default);
end;

procedure TwrpGsStorageFolder.WriteCurrency(const AValueName: WideString;
  Default: Currency);
begin
  GetGsStorageFolder.WriteCurrency(AValueName, Default);
end;

procedure TwrpGsStorageFolder.WriteDateTime(const AValueName: WideString;
  Default: TDateTime);
begin
  GetGsStorageFolder.WriteDateTime(AValueName, Default);
end;

procedure TwrpGsStorageFolder.WriteInteger(const AValueName: WideString;
  Default: Integer);
begin
  GetGsStorageFolder.WriteInteger(AValueName, Default);
end;

procedure TwrpGsStorageFolder.WriteStream(const AValueName: WideString;
  const S: IgsStream);
begin
  GetGsStorageFolder.WriteStream(AValueName, InterfaceToObject(S) as TStream);
end;

procedure TwrpGsStorageFolder.WriteString(const AValueName,
  Default: WideString);
begin
  GetGsStorageFolder.WriteString(AValueName, Default);
end;

procedure TwrpGsStorageFolder.SaveToStream(const S: IgsStream);
begin
  GetGsStorageFolder.SaveToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsStorageFolder.WriteValue(const AValue: IgsGsStorageValue);
begin
  GetGsStorageFolder.WriteValue(InterfaceToObject(AValue) as TGsStorageValue);
end;

{ TwrpGsStorageValue }

function TwrpGsStorageValue.Get_AsBoolean: WordBool;
begin
  Result := GetGsStorageValue.AsBoolean;
end;

function TwrpGsStorageValue.Get_AsCurrency: Currency;
begin
  Result := GetGsStorageValue.AsCurrency;
end;

function TwrpGsStorageValue.Get_AsDateTime: TDateTime;
begin
  Result := GetGsStorageValue.AsDateTime;
end;

function TwrpGsStorageValue.Get_AsInteger: Integer;
begin
  Result := GetGsStorageValue.AsInteger;
end;

function TwrpGsStorageValue.Get_AsString: WideString;
begin
  Result := GetGsStorageValue.AsString;
end;

function TwrpGsStorageValue.GetGsStorageValue: TGsStorageValue;
begin
  Result := GetObject as TGsStorageValue;
end;

function TwrpGsStorageValue.GetStorageValueClass: WideString;
begin
  Result := GetGsStorageValue.ClassType.ClassName;
end;

function TwrpGsStorageValue.GetTypeId: Integer;
begin
  Result := GetGsStorageValue.GetTypeId;
end;

function TwrpGsStorageValue.GetTypeName: WideString;
begin
  Result := GetGsStorageValue.GetTypeName;
end;

procedure TwrpGsStorageValue.Set_AsBoolean(Value: WordBool);
begin
  GetGsStorageValue.AsBoolean := Value;
end;

procedure TwrpGsStorageValue.Set_AsCurrency(Value: Currency);
begin
  GetGsStorageValue.AsCurrency := Value;
end;

procedure TwrpGsStorageValue.Set_AsDateTime(Value: TDateTime);
begin
  GetGsStorageValue.AsDateTime := Value;
end;

procedure TwrpGsStorageValue.Set_AsInteger(Value: Integer);
begin
  GetGsStorageValue.AsInteger := Value;
end;

procedure TwrpGsStorageValue.Set_AsString(const Value: WideString);
begin
  GetGsStorageValue.AsString := Value;
end;

function TwrpGsStorageValue.ShowEditValueDialog: Integer;
begin
  Result := GetGsStorageValue.ShowEditValueDialog;
end;

{ TwrpTBView }

procedure TwrpTBView.BaseSize(out X, Y: OleVariant);
begin
  x := getTBView.BaseSize.x;
  y := getTBView.BaseSize.y;
end;

procedure TwrpTBView.BeginUpdate;
begin
  GetTBView.BeginUpdate;
end;

procedure TwrpTBView.CancelCapture;
begin
  GetTBView.CancelCapture;
end;

procedure TwrpTBView.CloseChildPopups;
begin
  GetTBView.CloseChildPopups;
end;

function TwrpTBView.ContainsView(const AView: IgsTBView): WordBool;
begin
  Result := GetTBView.ContainsView(InterfaceToObject(AView) as TTBView);
end;

procedure TwrpTBView.DrawSubitems(const ACanvas: IgsCanvas);
begin
  GetTBView.DrawSubitems(InterfaceToObject(ACanvas) as TCanvas);
end;

procedure TwrpTBView.EndUpdate;
begin
  GetTBView.EndUpdate;
end;

procedure TwrpTBView.EnterToolbarLoop(const Options: WideString);
var
  LOpt: TTBEnterToolbarLoopOptions;
begin
  LOpt := [];
  if Pos('TBETMOUSEDOWN', AnsiUpperCase(Options)) > 0 then
    Include(LOpt, TBETMOUSEDOWN);
{  if Pos('TBETEXECUTESELECTED', AnsiUpperCase(Options)) > 0 then
    Include(LOpt, tbetExecuteSelected);
  if Pos('TBETFROMMSAA', AnsiUpperCase(Options)) > 0 then
    Include(LOpt, tbetFromMSAA);}

  GetTBView.EnterToolbarLoop(LOpt);
end;

function TwrpTBView.Find(const Item: IgsTBCustomItem): IgsTBItemViewer;
begin
  Result := GetGdcOLEObject(GetTBView.Find(InterfaceToObject(Item) as TTBCustomItem)) as IgsTBItemViewer;
end;

function TwrpTBView.FirstSelectable: IgsTBItemViewer;
begin
  Result := GetGdcOLEObject(GetTBView.FirstSelectable) as IgsTBItemViewer;
end;

function TwrpTBView.Get_BackgroundColor: Integer;
begin
  Result := GetTBView.BackgroundColor;
end;

function TwrpTBView.Get_Capture: WordBool;
begin
  Result := GetTBView.Capture;
end;

function TwrpTBView.Get_ChevronOffset: Integer;
begin
  Result := GetTBView.ChevronOffset;
end;

function TwrpTBView.Get_Customizing: WordBool;
begin
  Result := GetTBView.Customizing;
end;

function TwrpTBView.Get_IsPopup: WordBool;
begin
  Result := GetTBView.IsPopup;
end;

function TwrpTBView.Get_IsToolbar: WordBool;
begin
  Result := GetTBView.IsToolbar;
end;

function TwrpTBView.Get_MouseOverSelected: WordBool;
begin
  Result := GetTBView.MouseOverSelected;
end;

function TwrpTBView.Get_Orientation: TgsTBViewOrientation;
begin
  Result := TgsTBViewOrientation(GetTBView.Orientation);
end;

function TwrpTBView.Get_ParentItem: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBView.ParentItem) as IgsTBCustomItem;
end;

function TwrpTBView.Get_ParentView: IgsTBView;
begin
  Result := GetGdcOLEObject(GetTBView.ParentView) as IgsTBView;
end;

function TwrpTBView.Get_Selected: IgsTBItemViewer;
begin
  Result := GetGdcOLEObject(GetTBView.Selected) as IgsTBItemViewer;
end;

function TwrpTBView.Get_State: WideString;
begin
  Result := ' ';
{  if vsModal in GetTBView.State then
    Result := Result + 'vsModal ';
  if vsMouseInWindow in GetTBView.State then
    Result := Result + 'vsMouseInWindow ';
  if vsDrawInOrder in GetTBView.State then
    Result := Result + 'vsDrawInOrder ';
  if vsOppositePopup in GetTBView.State then
    Result := Result + 'vsOppositePopup ';
  if vsIgnoreFirstMouseUp in GetTBView.State then
    Result := Result + 'vsIgnoreFirstMouseUp ';
  if vsShowAccels in GetTBView.State then
    Result := Result + 'vsShowAccels ';
  if vsDropDownMenus in GetTBView.State then
    Result := Result + 'vsDropDownMenus ';
  if vsNoAnimation in GetTBView.State then
    Result := Result + 'vsNoAnimation ';}
end;

function TwrpTBView.Get_Style: WideString;
begin
  Result := ' ';
  if vsUseHiddenAccels in GetTBView.Style then
    Result := Result + 'vsUseHiddenAccels ';
  if vsAlwaysShowHints in GetTBView.Style then
    Result := Result + 'vsAlwaysShowHints ';
end;

function TwrpTBView.Get_ViewerCount: Integer;
begin
  Result := GetTBView.ViewerCount;
end;

function TwrpTBView.Get_Window: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetTBView.Window) as IgsWinControl;
end;

function TwrpTBView.Get_WrapOffset: Integer;
begin
  Result := GetTBView.WrapOffset;
end;

procedure TwrpTBView.GetOffEdgeControlList(const List: IgsList);
begin
  GetTBView.GetOffEdgeControlList(InterfaceToObject(List) as TList);
end;

function TwrpTBView.GetTBView: TTBView;
begin
  Result := GetObject as TTBView;
end;

procedure TwrpTBView.GivePriority(const AViewer: IgsTBItemViewer);
begin
  GetTBView.GivePriority(InterfaceToObject(AViewer) as TTBItemViewer);
end;

function TwrpTBView.HighestPriorityViewer: IgsTBItemViewer;
begin
  Result := GetGdcOLEObject(GetTBView.HighestPriorityViewer) as IgsTBItemViewer;
end;

function TwrpTBView.IndexOf(const AViewer: IgsTBItemViewer): Integer;
begin
  Result := GetTBView.IndexOf(InterfaceToObject(AViewer) as TTBItemViewer);
end;

procedure TwrpTBView.Invalidate(const AViewer: IgsTBItemViewer);
begin
  GetTBView.Invalidate(InterfaceToObject(AViewer) as TTBItemViewer);
end;

procedure TwrpTBView.InvalidatePositions;
begin
  GetTBView.InvalidatePositions;
end;

procedure TwrpTBView.NextSelectable(const CurViewer:
   IgsTBItemViewer; GoForward: WordBool);
begin
  GetTBView.NextSelectable(InterfaceToObject(CurViewer) as
    TTBItemViewer, GoForward);
end;

procedure TwrpTBView.RecreateAllViewers;
begin
  GetTBView.RecreateAllViewers;
end;

procedure TwrpTBView.ScrollSelectedIntoView;
begin
  GetTBView.ScrollSelectedIntoView;
end;

procedure TwrpTBView.Set_BackgroundColor(Value: Integer);
begin
  GetTBView.BackgroundColor := Value;
end;

procedure TwrpTBView.Set_ChevronOffset(Value: Integer);
begin
  GetTBView.ChevronOffset := Value;
end;

procedure TwrpTBView.Set_Customizing(Value: WordBool);
begin
  GetTBView.Customizing := Value;
end;

procedure TwrpTBView.Set_Orientation(Value: TgsTBViewOrientation);
begin
  GetTBView.Orientation := TTBViewOrientation(Value);
end;

procedure TwrpTBView.Set_Selected(const Value: IgsTBItemViewer);
begin
  GetTBView.Selected := InterfaceToObject(Value) as TTBItemViewer;
end;

procedure TwrpTBView.Set_WrapOffset(Value: Integer);
begin
  GetTBView.WrapOffset := Value;
end;

procedure TwrpTBView.SetCapture;
begin
  GetTBView.SetCapture;
end;

procedure TwrpTBView.TryValidatePositions;
begin
  GetTBView.TryValidatePositions;
end;

procedure TwrpTBView.UpdatePositions(out X, Y: OleVariant);
begin
  X := GetTBView.UpdatePositions.x;
  Y := GetTBView.UpdatePositions.y;
end;

procedure TwrpTBView.ValidatePositions;
begin
  GetTBView.ValidatePositions;
end;

function TwrpTBView.ViewerFromPoint(X, Y: Integer): IgsTBItemViewer;
var
  lp: TPoint;
begin
  lp.x := x;
  lp.y := y;
  Result := GetGdcOLEObject(GetTBView.ViewerFromPoint(lp)) as IgsTBItemViewer;
end;

{ TwrpTBItemViewer }

procedure TwrpTBItemViewer.BoundsRect(out Left, Top, Right,
  Bottom: OleVariant);
var
  R: Trect;
begin
  R := GetTBItemViewer.BoundsRect;
  Left := R.Left;
  Top := R.Top;
  Right := R.Right;
  Bottom := R.Bottom;
end;

function TwrpTBItemViewer.Get_Clipped: WordBool;
begin
  Result := GetTBItemViewer.Clipped;
end;

function TwrpTBItemViewer.Get_Index: Integer;
begin
  Result := GetTBItemViewer.Index;
end;

function TwrpTBItemViewer.Get_Item: IgsTBCustomItem;
begin
  Result := GetGdcOLEObject(GetTBItemViewer.Item) as IgsTBCustomItem;
end;

function TwrpTBItemViewer.Get_OffEdge: WordBool;
begin
  Result := GetTBItemViewer.OffEdge;
end;

function TwrpTBItemViewer.Get_Show: WordBool;
begin
  Result := GetTBItemViewer.Show;
end;

function TwrpTBItemViewer.Get_View: IgsTBView;
begin
  Result := GetGdcOLEObject(GetTBItemViewer.View) as IgsTBView;
end;

function TwrpTBItemViewer.GetTBItemViewer: TTBItemViewer;
begin
  Result := GetObject as TTBItemViewer;
end;

procedure TwrpTBItemViewer.ScreenToClient(InX, InY: Integer; out OutX,
  OutY: OleVariant);
var
  InPoint: TPoint;
begin
  InPoint.x := InX;
  InPoint.y := InY;
  OutX := GetTBItemViewer.ScreenToClient(InPoint).x;
  OutY := GetTBItemViewer.ScreenToClient(InPoint).y;
end;

{ TwrpGdcAggregates }

function TwrpGdcAggregates.Add: IgsGdcAggregate;
begin
  Result := GetGdcOLEObject(GetGdcAggregates.Add) as IgsGdcAggregate;
end;

procedure TwrpGdcAggregates.Clear_;
begin
  GetGdcAggregates.Clear;
end;

function TwrpGdcAggregates.Get_Items(Index: Integer): IgsGdcAggregate;
begin
  Result := GetGdcOLEObject(GetGdcAggregates.Items[Index]) as IgsGdcAggregate;
end;

function TwrpGdcAggregates.GetGdcAggregates: TGdcAggregates;
begin
  Result := GetObject as TgdcAggregates;
end;

function TwrpGdcAggregates.IndexOf(
  const DisplayName: WideString): Integer;
begin
  Result := GetGdcAggregates.IndexOf(DisplayName);
end;

procedure TwrpGdcAggregates.Set_Items(Index: Integer; const Value: IgsGdcAggregate);
begin
  GetGdcAggregates.Items[Index] := InterfaceToObject(Value) as TGdcAggregate;
end;

{ TwrpGdcAggregate }

function TwrpGdcAggregate.Get_Active: WordBool;
begin
  Result := GetGdcAggregate.Active;
end;

function TwrpGdcAggregate.Get_AggregateName: WideString;
begin
  Result := GetGdcAggregate.AggregateName;
end;

function TwrpGdcAggregate.Get_DataSet: IgsGDCBase;
begin
  Result := GetGdcOleObject(GetGdcAggregate.DataSet) as IgsGDCBase;
end;

function TwrpGdcAggregate.Get_DataSize: Integer;
begin
  Result := GetGdcAggregate.DataSize;
end;

function TwrpGdcAggregate.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(GetGdcAggregate.DataType);
end;

function TwrpGdcAggregate.Get_Expression: WideString;
begin
  Result := GetGdcAggregate.Expression;
end;

function TwrpGdcAggregate.Get_IndexName: WideString;
begin
  Result := GetGdcAggregate.IndexName;
end;

function TwrpGdcAggregate.Get_InUse: WordBool;
begin
  Result := GetGdcAggregate.InUse;
end;

function TwrpGdcAggregate.Get_Visible: WordBool;
begin
  Result := GetGdcAggregate.Visible;
end;

function TwrpGdcAggregate.GetDisplayName: WideString;
begin
  REsult := GetGdcAggregate.GetDisplayName;
end;

function TwrpGdcAggregate.GetGdcAggregate: TGdcAggregate;
begin
  Result := GetObject as TGdcAggregate;
end;

procedure TwrpGdcAggregate.Set_Active(Value: WordBool);
begin
  GetGdcAggregate.Active := Value;
end;

procedure TwrpGdcAggregate.Set_AggregateName(const Value: WideString);
begin
  GetGdcAggregate.AggregateName := Value;
end;

procedure TwrpGdcAggregate.Set_DataType(Value: TgsFieldType);
begin
  GetGdcAggregate.DataType := TFieldType(Value);
end;

procedure TwrpGdcAggregate.Set_Expression(const Value: WideString);
begin
  GetGdcAggregate.Expression := Value;
end;

procedure TwrpGdcAggregate.Set_IndexName(const Value: WideString);
begin
  GetGdcAggregate.IndexName := Value;
end;

procedure TwrpGdcAggregate.Set_Visible(Value: WordBool);
begin
  GetGdcAggregate.Visible := Value;
end;

function TwrpGdcAggregate.Value: OleVariant;
begin
  Result := GetGdcAggregate.Value;
end;

{ TwrpGdcObjectSet }

function TwrpGdcObjectSet.Add(AnID: Integer; const AgdClassName: WideString;
  const ASubType: WideString): Integer;
begin
  Result := GetGdcObjectSet.Add(AnID, AgdClassName, ASubType, '');
end;

procedure TwrpGdcObjectSet.Delete(AnID: Integer);
begin
  GetGdcObjectSet.Delete(AnID);
end;

function TwrpGdcObjectSet.Find(AnID: Integer): Integer;
begin
  Result := GetGdcObjectSet.Find(AnID)
end;

function TwrpGdcObjectSet.Get_Count: Integer;
begin
  Result := GetGdcObjectSet.Count;
end;

function TwrpGdcObjectSet.Get_gdClass: WideString;
begin
  Result := GetGdcObjectSet.gdClass.ClassName;
end;

function TwrpGdcObjectSet.Get_gdClassName: WideString;
begin
  Result := GetGdcObjectSet.gdClassName;
end;

function TwrpGdcObjectSet.Get_Items(Index: Integer): Integer;
begin
  Result := GetGdcObjectSet.Items[Index];
end;

function TwrpGdcObjectSet.Get_Size: Integer;
begin
  Result := GetGdcObjectSet.Size;
end;

function TwrpGdcObjectSet.Get_SubType: WideString;
begin
  Result := GetGdcObjectSet.SubType;
end;

function TwrpGdcObjectSet.GetGdcObjectSet: TGdcObjectSet;
begin
  Result := GetObject as TGdcObjectSet;
end;

procedure TwrpGdcObjectSet.LoadFromStream(const S: IgsStream);
begin
  GetGdcObjectSet.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGdcObjectSet.Remove(AnID: Integer);
begin
  GetGdcObjectSet.Remove(AnID);
end;

procedure TwrpGdcObjectSet.SaveToStream(const S: IgsStream);
begin
  GetGdcObjectSet.SaveToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGdcObjectSet.Set_gdClass(const Value: WideString);
var
  CE: TgdClassEntry;
begin
  { TODO : перепроверить!
  тут тип и подтип отдельно присваиваются.
  правильно ли это?
  }
  CE := gdClassList.Get(TgdBaseEntry, Value);
  GetGdcObjectSet.gdClass := TgdBaseEntry(CE).gdcClass;
end;

procedure TwrpGdcObjectSet.Set_SubType(const Value: WideString);
begin
  GetGdcObjectSet.SubType := Value;
end;

procedure TwrpGdcObjectSet.AddgdClass(Index: Integer; const AgdClassName,
  ASubType: WideString);
begin
  GetGdcObjectSet.AddgdClass(Index, AgdClassName, ASubType, '');
end;

function TwrpGdcObjectSet.FindgdClass(Index: Integer; const AgdClassName,
  ASubType: WideString): WordBool;
begin
  Result := GetGdcObjectSet.FindgdClass(Index, AgdClassName, ASubType, '');
end;

function TwrpGdcObjectSet.FindgdClassByID(AnID: Integer;
  const AgdClassName, ASubType: WideString): WordBool;
begin
  Result := GetGdcObjectSet.FindgdClassByID(AnID, AgdClassName, ASubType, '');
end;

function TwrpGdcObjectSet.Get_gdInfo(Index: Integer): WideString;
begin
  Result := GetGdcObjectSet.gdInfo[Index];
end;

{ TwrpGdKeyIntAssoc }

function TwrpGdKeyIntAssoc.Get_ValuesByIndex(Index: Integer): Integer;
begin
  Result := GetGdKeyIntAssoc.ValuesByIndex[Index];
end;

function TwrpGdKeyIntAssoc.Get_ValuesByKey(Key: Integer): Integer;
begin
  Result := GetGdKeyIntAssoc.ValuesByKey[Key]
end;

function TwrpGdKeyIntAssoc.GetGdKeyIntAssoc: TGdKeyIntAssoc;
begin
  Result := GetObject as TgdKeyIntAssoc;
end;

procedure TwrpGdKeyIntAssoc.Set_ValuesByIndex(Index, Value: Integer);
begin
  GetGdKeyIntAssoc.ValuesByIndex[Index] := Value;
end;

procedure TwrpGdKeyIntAssoc.Set_ValuesByKey(Key, Value: Integer);
begin
  GetGdKeyIntAssoc.ValuesByKey[Key] := Value;
end;

class function TwrpGdKeyIntAssoc.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyIntAssoc), 'Invalide Delphi class');
  Result := TgdKeyIntAssoc.Create;
end;

{ TwrpgsDBGrid }

function TwrpgsCustomDBGrid.Get_Conditions: IgsGridConditions;
begin
  Result := GetGdcOLEObject(GetgsCustomDBGrid.Conditions) as IgsGridConditions;
end;

function TwrpgsCustomDBGrid.Get_ConditionsActive: WordBool;
begin
  Result := GetGsCustomDBGrid.ConditionsActive;
end;

function TwrpgsDBGrid.Get_Expands: IgsColumnExpands;
begin
  Result := GetGdcOleObject(GetGsDBGrid.Expands) as IgsColumnExpands;
end;

function TwrpgsDBGrid.Get_ExpandsActive: WordBool;
begin
  Result := GetGsDBGrid.ExpandsActive;
end;

function TwrpgsDBGrid.Get_ExpandsSeparate: WordBool;
begin
  Result := GetGsDBGrid.ExpandsSeparate;
end;

function TwrpgsDBGrid.Get_FinishDrawing: WordBool;
begin
  Result := GetGsDBGrid.FinishDrawing;
end;

function TwrpgsDBGrid.Get_InternalMenuKind: TgsInternalMenuKind;
begin
  Result := TgsInternalMenuKind(GetGsDBGrid.InternalMenuKind);
end;

function TwrpgsDBGrid.Get_MinColWidth: Integer;
begin
  Result := GetGsDBGrid.MinColWidth;
end;

function TwrpgsDBGrid.Get_RefreshType: TgsRefreshType;
begin
  Result := TgsRefreshType(GetGsDBGrid.RefreshType);
end;

function TwrpgsDBGrid.Get_RememberPosition: WordBool;
begin
  Result := GetGsDBGrid.RememberPosition;
end;

function TwrpgsDBGrid.Get_SaveSettings: WordBool;
begin
  Result := GetGsDBGrid.SaveSettings;
end;

function TwrpgsDBGrid.Get_ScaleColumns: WordBool;
begin
  Result := GetGsDBGrid.ScaleColumns;
end;

function TwrpgsDBGrid.Get_SelectedColor: Integer;
begin
  Result := GetGsDBGrid.SelectedColor;
end;

function TwrpgsDBGrid.Get_SelectedFont: IgsFont;
begin
  Result := GetGdcOLEObject(GetGsDBGrid.SelectedFont) as IgsFont;
end;

function TwrpgsDBGrid.Get_SelectedRows: IgsBookmarkList;
begin
  Result := GetGdcOLEObject(GetGsDBGrid.SelectedRows) as IgsBookmarkList;
end;

function TwrpgsDBGrid.Get_Striped: WordBool;
begin
  Result := GetGsDBGrid.Striped;
end;

function TwrpgsDBGrid.Get_StripeEven: Integer;
begin
  Result := GetGsDBGrid.StripeEven;
end;

function TwrpgsDBGrid.Get_StripeOdd: Integer;
begin
  Result := GetGsDBGrid.StripeOdd;
end;

function TwrpgsDBGrid.Get_TableColor: Integer;
begin
  Result := GetGsDBGrid.TableColor;
end;

function TwrpgsDBGrid.Get_TableFont: IgsFont;
begin
  Result := GetGdcOLEObject(GetGsDBGrid.TableFont) as IgsFont;
end;

function TwrpgsDBGrid.Get_TitleColor: Integer;
begin
  Result := GetGsDBGrid.TitleColor;
end;

function TwrpgsDBGrid.Get_TitlesExpanding: WordBool;
begin
  Result := GetGsDBGrid.TitlesExpanding;
end;

function TwrpgsDBGrid.Get_ToolBar: IgsToolBar;
begin
  Result := GetGdcOLEObject(GetGsDBGrid.ToolBar) as IgsToolbar;
end;

function TwrpgsDBGrid.GetGsDBGrid: TgsDBGrid;
begin
  Result := GetObject as TgsDBGrid;
end;

procedure TwrpgsCustomDBGrid.Set_Conditions(const Value: IgsGridConditions);
begin
  GetgsCustomDBGrid.Conditions := InterfaceToObject(Value) as TGridConditions;
end;

procedure TwrpgsCustomDBGrid.Set_ConditionsActive(Value: WordBool);
begin
  GetGsCustomDBGrid.ConditionsActive := Value;
end;

procedure TwrpgsDBGrid.Set_Expands(const Value: IgsColumnExpands);
begin
  GetGsDBGrid.Expands := InterfaceToObject(Value) as TColumnExpands;
end;

procedure TwrpgsDBGrid.Set_ExpandsActive(Value: WordBool);
begin
  GetGsDBGrid.ExpandsActive := Value;
end;

procedure TwrpgsDBGrid.Set_ExpandsSeparate(Value: WordBool);
begin
  GetGsDBGrid.ExpandsSeparate := Value;
end;

procedure TwrpgsDBGrid.Set_FinishDrawing(Value: WordBool);
begin
  GetGsDBGrid.FinishDrawing := Value;
end;

procedure TwrpgsDBGrid.Set_InternalMenuKind(Value: TgsInternalMenuKind);
begin
  GetGsDBGrid.InternalMenuKind := TInternalMenuKind(Value);
end;

procedure TwrpgsDBGrid.Set_MinColWidth(Value: Integer);
begin
  GetGsDBGrid.MinColWidth := Value;
end;

procedure TwrpgsDBGrid.Set_RefreshType(Value: TgsRefreshType);
begin
  GetGsDBGrid.RefreshType := TRefreshType(Value);
end;

procedure TwrpgsDBGrid.Set_RememberPosition(Value: WordBool);
begin
  GetGsDBGrid.RememberPosition := Value;
end;

procedure TwrpgsDBGrid.Set_SaveSettings(Value: WordBool);
begin
  GetGsDBGrid.SaveSettings := Value;
end;

procedure TwrpgsDBGrid.Set_ScaleColumns(Value: WordBool);
begin
  GetGsDBGrid.ScaleColumns := Value;
end;

procedure TwrpgsDBGrid.Set_SelectedColor(Value: Integer);
begin
  GetGsDBGrid.SelectedColor := Value;
end;

procedure TwrpgsDBGrid.Set_SelectedFont(const Value: IgsFont);
begin
  GetGsDBGrid.SelectedFont := InterfaceToObject(Value) as TFont;
end;

procedure TwrpgsDBGrid.Set_Striped(Value: WordBool);
begin
  GetGsDBGrid.Striped := Value;
end;

procedure TwrpgsDBGrid.Set_StripeEven(Value: Integer);
begin
  GetGsDBGrid.StripeEven := Value;
end;

procedure TwrpgsDBGrid.Set_StripeOdd(Value: Integer);
begin
  GetGsDBGrid.StripeOdd := Value;
end;

procedure TwrpgsDBGrid.Set_TableColor(Value: Integer);
begin
  GetGsDBGrid.TableColor := Value;
end;

procedure TwrpgsDBGrid.Set_TableFont(const Value: IgsFont);
begin
  GetGsDBGrid.TableFont := InterfaceToObject(Value) as TFont;
end;

procedure TwrpgsDBGrid.Set_TitleColor(Value: Integer);
begin
  GetGsDBGrid.TitleColor := Value;
end;

procedure TwrpgsDBGrid.Set_TitlesExpanding(Value: WordBool);
begin
  GetGsDBGrid.TitlesExpanding := Value;
end;

procedure TwrpgsDBGrid.Set_ToolBar(const Value: IgsToolBar);
begin
  GetGsDBGrid.ToolBar := InterfaceToObject(Value) as TToolBar;
end;

{ TwrpGdcUserDocument }


{
function TwrpGdcUserDocument.GetGdcUserDocument: TGdcUserDocument;
begin
  Result := GetObject as TGdcUserDocument;
end;
}

procedure TwrpGdcUserDocument.PrePostDocumentData;
begin
//  GetGdcUserDocument.PrePostDocumentData;
end;

{ TwrpGdcBaseTable }

function TwrpGdcBaseTable.Get_AdditionCreateField: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGdcBaseTable.AdditionCreateField ) as IgsStringList;
end;

function TwrpGdcBaseTable.Get_gdcTableField: IgsGdcTableField;
begin
  Result := GetGdcOLEObject(GetGdcBaseTable.gdcTableField ) as IgsGdcTableField;
end;

function TwrpGdcBaseTable.GetGdcBaseTable: TGdcBaseTable;
begin
  Result := GetObject as TGdcBaseTable;
end;

function TwrpGdcBaseTable.GetPrimaryFieldName: WideString;
begin
  Result := GetGdcBaseTable.GetPrimaryFieldName;
end;

procedure TwrpGdcBaseTable.MakePredefinedRelationFields;
begin
  GetGdcBaseTable.MakePredefinedRelationFields;
end;

procedure TwrpGdcBaseTable.Set_AdditionCreateField(
  const Value: IgsStringList);
begin
  GetGdcBaseTable.AdditionCreateField := InterfaceToObject(Value) as TStringList;
end;

{ TwrpGdcRelationField }

function TwrpGdcRelationField.Get_ChangeComputed: WordBool;
begin
  Result := GetGdcRelationField.ChangeComputed;
end;

function TwrpGdcRelationField.GetGdcRelationField: TGdcRelationField;
begin
  Result := GetObject as TGdcRelationField;
end;

function TwrpGdcRelationField.ReadObjectState(const AFieldId,
  AClassName: WideString): Integer;
begin
  { TODO : Уже нет нужды в этой функции. }
  Result := 0; //GetGdcRelationField.ReadObjectState(AFieldId, AClassName);
end;

procedure TwrpGdcRelationField.Set_ChangeComputed(Value: WordBool);
begin
  GetGdcRelationField.ChangeComputed := Value;
end;

{ TwrpAtRelation }

function TwrpAtRelation.Get_aChag: Integer;
begin
  Result := GetAtRelation.aChag;
end;

function TwrpAtRelation.Get_aFull: Integer;
begin
  Result := GetAtRelation.aFull;
end;

function TwrpAtRelation.Get_aView: Integer;
begin
  Result := GetAtRelation.aView;
end;

function TwrpAtRelation.Get_Description: WideString;
begin
  Result := GetAtRelation.Description;
end;

function TwrpAtRelation.Get_HasRecord: WordBool;
begin
  Result := GetAtRelation.HasRecord
end;

function TwrpAtRelation.Get_HasSecurityDescriptors: WordBool;
begin
  Result := GetAtRelation.HasSecurityDescriptors;
end;

function TwrpAtRelation.Get_ID: Integer;
begin
  Result := GetAtRelation.ID;
end;

function TwrpAtRelation.Get_IsLBRBTreeRelation: WordBool;
begin
  Result := GetAtRelation.IsLBRBTreeRelation;
end;

function TwrpAtRelation.Get_IsStandartTreeRelation: WordBool;
begin
  Result := GetAtRelation.IsStandartTreeRelation;
end;

function TwrpAtRelation.Get_IsSystem: WordBool;
begin
  Result := GetAtRelation.IsSystem;
end;

function TwrpAtRelation.Get_IsUserDefined: WordBool;
begin
  Result := GetAtRelation.IsUserDefined;
end;

function TwrpAtRelation.Get_ListField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelation.ListField) as IgsAtRelationField;
end;

function TwrpAtRelation.Get_LName: WideString;
begin
  Result := GetAtRelation.LName;
end;

function TwrpAtRelation.Get_LShortName: WideString;
begin
  Result := GetAtRelation.LShortName;
end;

function TwrpAtRelation.Get_RelationFields: IgsAtRelationFields;
begin
  Result := GetGdcOLEObject(GetAtRelation.RelationFields) as IgsAtRelationFields;
end;

function TwrpAtRelation.Get_RelationID: Integer;
begin
  Result := GetAtRelation.RelationID;
end;

function TwrpAtRelation.Get_RelationName: WideString;
begin
  Result := GetAtRelation.RelationName;
end;

function TwrpAtRelation.Get_RelationType: TgsAtRelationType;
begin
  Result := TgsAtRelationType(GetAtRelation.RelationType);
end;

function TwrpAtRelation.GetAtRelation: TAtRelation;
begin
  Result := GetObject as TatRelation;
end;

procedure TwrpAtRelation.RecordAcquired;
begin
  GetAtRelation.RecordAcquired;
end;

procedure TwrpAtRelation.RefreshConstraints;
begin
  GetAtRelation.RefreshConstraints;
end;

procedure TwrpAtRelation.RefreshConstraints_(
  const aDatabase: IgsIBDatabase; const aTransaction: IgsIBTransaction);
begin
  GetAtRelation.RefreshConstraints(InterfaceToObject(aDatabase) as TIBDatabase,
    InterfaceToObject(aTransaction) as TIBTransaction);
end;

procedure TwrpAtRelation.RefreshData(IsRefreshFields: WordBool);
begin
  GetAtRelation.RefreshData(IsRefreshFields);
end;

procedure TwrpAtRelation.RefreshData_1(const SQLRecord: IgsIBXSQLDA;
  const aDatabase: IgsIBDatabase; const aTransaction: IgsIBTransaction;
  IsRefreshFields: WordBool);
begin
  GetAtRelation.RefreshData(InterfaceToObject(SQLRecord) as TIBXSQLDA,
    InterfaceToObject(aDatabase) as TIBDatabase,
    InterfaceToObject(aTransaction) as TIBTransaction, IsRefreshFields);
end;

procedure TwrpAtRelation.RefreshData_2(const aDatabase: IgsIBDatabase;
  const aTransaction: IgsIBTransaction; IsRefreshFields: WordBool);
begin
  GetAtRelation.RefreshData(InterfaceToObject(aDatabase) as TIBDatabase,
    InterfaceToObject(aTransaction) as TIBTransaction, IsRefreshFields);
end;

function TwrpAtRelation.Get_PrimaryKey: IgsAtPrimaryKey;
begin
  Result := GetGdcOLEObject(GetAtRelation.PrimaryKey) as IgsAtPrimaryKey;
end;

{ TwrpAtRelationFields }

function TwrpAtRelationFields.Add(
  const atRelationField: IgsAtRelationField): Integer;
begin
  Result := GetAtRelationFields.Add(InterfaceToObject(atRelationField)
    as TatRelationField);
end;

function TwrpAtRelationFields.AddRelationField(
  const AFieldName: WideString): IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.AddRelationField(AFieldName)) as IgsAtRelationField;
end;

function TwrpAtRelationFields.ByFieldName(
  const AName: WideString): IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.ByFieldName(AName)) as IgsAtRelationField;
end;

function TwrpAtRelationFields.ByID(aID: Integer): IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.ByID(aID)) as IgsAtRelationField;
end;

function TwrpAtRelationFields.ByPos(
  APosition: Integer): IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.ByPos(APosition)) as IgsAtRelationField;
end;

procedure TwrpAtRelationFields.Delete(Index: Integer);
begin
  GetAtRelationFields.Delete(Index);
end;

function TwrpAtRelationFields.Get_Count: Integer;
begin
  Result := GetAtRelationFields.Count;
end;

function TwrpAtRelationFields.Get_Items(
  Index: Integer): IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.Items[Index]) as IgsAtRelationField;
end;

function TwrpAtRelationFields.Get_Relation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelationFields.Relation) as IgsAtRelation;
end;

function TwrpAtRelationFields.GetAtRelationFields: TAtRelationFields;
begin
  Result := GetObject as TAtRelationFields;
end;

procedure TwrpAtRelationFields.RefreshData;
begin
  GetAtRelationFields.RefreshData;
end;

procedure TwrpAtRelationFields.RefreshData_(const aDatabase: IgsIBDatabase;
  const aTransaction: IgsIBTransaction);
begin
  GetAtRelationFields.RefreshData(InterfaceToObject(aDatabase) as TIBDatabase,
    InterfaceToObject(aTransaction) as TIBTransaction);
end;

procedure TwrpAtRelationFields.Set_Relation(const Value: IgsAtRelation);
begin
  GetAtRelationFields.Relation := InterfaceToObject(Value) as TatRelation;
end;

{ TwrpAtRelationField }

function TwrpAtRelationField.Get_aChag: Integer;
begin
  Result := GetAtRelationField.aChag;
end;

function TwrpAtRelationField.Get_aFull: Integer;
begin
  Result := GetAtRelationField.aFull;
end;

function TwrpAtRelationField.Get_Alignment: TgsFieldAlignment;
begin
  Result := TgsFieldAlignment(GetAtRelationField.Alignment);
end;

function TwrpAtRelationField.Get_AView: Integer;
begin
  Result := GetAtRelationField.aView;
end;

function TwrpAtRelationField.Get_ColWidth: Integer;
begin
  Result := GetAtRelationField.ColWidth;
end;

function TwrpAtRelationField.Get_CrossRelation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelationField.CrossRelation) as IgsAtRelation;
end;

function TwrpAtRelationField.Get_CrossRelationField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationField.CrossRelationField) as IgsAtRelationField;
end;

function TwrpAtRelationField.Get_CrossRelationFieldName: WideString;
begin
  Result := GetAtRelationField.CrossRelationFieldName;
end;

function TwrpAtRelationField.Get_CrossRelationName: WideString;
begin
  Result := GetAtRelationField.CrossRelationName;
end;

function TwrpAtRelationField.Get_Description: WideString;
begin
  Result := GetAtRelationField.Description;
end;

function TwrpAtRelationField.Get_Field: IgsAtField;
begin
  Result := GetGdcOLEObject(GetAtRelationField.Field) as IgsAtField;
end;

function TwrpAtRelationField.Get_FieldName: WideString;
begin
  Result := GetAtRelationField.FieldName;
end;

function TwrpAtRelationField.Get_FieldPosition: Integer;
begin
  Result := GetAtRelationField.FieldPosition;
end;

function TwrpAtRelationField.Get_ForeignKey: IgsAtForeignKey;
begin
  Result := GetGdcOLEObject(GetAtRelationField.ForeignKey) as IgsAtForeignKey;
end;

function TwrpAtRelationField.Get_FormatString: WideString;
begin
  Result := GetAtRelationField.FormatString;
end;

function TwrpAtRelationField.Get_gdClassName: WideString;
begin
  Result := GetAtRelationField.gdClassName;
end;

function TwrpAtRelationField.Get_gdSubType: WideString;
begin
  Result := GetAtRelationField.gdSubType;
end;

function TwrpAtRelationField.Get_HasRecord: WordBool;
begin
  Result := GetAtRelationField.HasRecord;
end;

function TwrpAtRelationField.Get_ID: Integer;
begin
  Result := GetAtRelationField.ID;
end;

function TwrpAtRelationField.Get_IsComputed: WordBool;
begin
  Result := GetAtRelationField.IsComputed;
end;

function TwrpAtRelationField.Get_IsDropped: WordBool;
begin
  Result := GetAtRelationField.IsDropped;
end;

function TwrpAtRelationField.Get_IsSecurityDescriptor: WordBool;
begin
  Result := GetAtRelationField.IsSecurityDescriptor;
end;

function TwrpAtRelationField.Get_IsUserDefined: WordBool;
begin
  Result := GetAtRelationField.IsUserDefined;
end;

function TwrpAtRelationField.Get_LName: WideString;
begin
  Result := GetAtRelationField.LName;
end;

function TwrpAtRelationField.Get_LShortName: WideString;
begin
  Result := GetAtRelationField.LShortName;
end;

function TwrpAtRelationField.Get_ObjectsList: IgsStringList;
begin
  if GetAtRelationField.ObjectsList <> nil then
    Result := GetGdcOLEObject(GetAtRelationField.ObjectsList) as IgsStringList
  else
    Result := nil;  
end;

function TwrpAtRelationField.Get_ReadOnly: WordBool;
begin
  Result := GetAtRelationField.ReadOnly;
end;

function TwrpAtRelationField.Get_ReferenceListField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationField.ReferenceListField) as IgsAtRelationField;
end;

function TwrpAtRelationField.Get_References: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelationField.References) as IgsAtRelation;
end;

function TwrpAtRelationField.Get_ReferencesField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtRelationField.ReferencesField) as IgsAtRelationField;
end;                                                 

function TwrpAtRelationField.Get_Relation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelationField.Relation) as IgsAtRelation;
end;

function TwrpAtRelationField.Get_SQLType: Integer;
begin
  Result := GetAtRelationField.SQLType;
end;

function TwrpAtRelationField.Get_Visible: WordBool;
begin
  Result := GetAtRelationField.Visible;
end;

function TwrpAtRelationField.GetAtRelationField: TAtRelationField;
begin
  Result := GetObject as TAtRelationField;
end;

function TwrpAtRelationField.InObject(const AName: WideString): WordBool;
begin
  { TODO : Уже нет нужды в этой функции. }
  Result := False; //GetAtRelationField.InObject(AName);
end;

procedure TwrpAtRelationField.RecordAcquired;
begin
  GetAtRelationField.RecordAcquired;
end;

procedure TwrpAtRelationField.RefreshData;
begin
  GetAtRelationField.RefreshData;
end;

procedure TwrpAtRelationField.RefreshData_(const aDatabase: IgsIBDatabase;
  const ATransaction: IgsIBTransaction);
begin
  GetAtRelationField.RefreshData(InterfaceToObject(aDatabase) as
    TIBDatabase, InterfaceToObject(ATransaction) as TIBTransaction);
end;

procedure TwrpAtRelationField.RefreshData_1(const SQLRecord: IgsIBXSQLDA;
  const aDatabase: IgsIBDatabase; const ATransaction: IgsIBTransaction);
begin
  GetAtRelationField.RefreshData(InterfaceToObject(SQLRecord) as TIBXSQLDA,
    InterfaceToObject(aDatabase) as  TIBDatabase,
    InterfaceToObject(ATransaction) as TIBTransaction);
end;

{ TwrpAtField }

function TwrpAtField.Get_Alignment: TgsFieldAlignment;
begin
  Result := TgsFieldAlignment(GetAtField.Alignment);
end;

function TwrpAtField.Get_ColWidth: Integer;
begin
  Result := GetAtField.ColWidth;
end;

function TwrpAtField.Get_Description: WideString;
begin
  Result := GetAtField.Description;
end;

function TwrpAtField.Get_Disabled: WordBool;
begin
  Result := GetAtField.Disabled;
end;

function TwrpAtField.Get_FieldLength: Integer;
begin
  Result := GetAtField.FieldLength;
end;

function TwrpAtField.Get_FieldName: WideString;
begin
  Result := GetAtField.FieldName;
end;

function TwrpAtField.Get_FieldScale: Integer;
begin
  Result := GetAtField.FieldScale;
end;

function TwrpAtField.Get_FieldType: TgsFieldType;
begin
  Result := TgsFieldType(GetAtField.FieldType);
end;

function TwrpAtField.Get_FormatString: WideString;
begin
  Result := GetAtField.FormatString;
end;

function TwrpAtField.Get_gdClassName: WideString;
begin
  Result := GetAtField.gdClassName;
end;

function TwrpAtField.Get_gdSubType: WideString;
begin
  Result := GetAtField.gdSubType;
end;

function TwrpAtField.Get_HasRecord: WordBool;
begin
  Result := GetAtField.HasRecord;
end;

function TwrpAtField.Get_ID: Integer;
begin
  Result := GetAtField.ID;
end;

function TwrpAtField.Get_IsDropped: WordBool;
begin
  Result := GetAtField.IsDropped;
end;

function TwrpAtField.Get_IsNullable: WordBool;
begin
  Result := GetAtField.IsNullable;
end;

function TwrpAtField.Get_IsSystem: WordBool;
begin
  Result := GetAtField.IsSystem;
end;

function TwrpAtField.Get_IsUserDefined: WordBool;
begin
  Result := GetAtField.IsUserDefined;
end;

function TwrpAtField.Get_LName: WideString;
begin
  Result := GetAtField.LName;
end;

function TwrpAtField.Get_ReadOnly: WordBool;
begin
  Result := GetAtField.ReadOnly;
end;

function TwrpAtField.Get_RefCondition: WideString;
begin
  Result := GetAtField.RefCondition;
end;

function TwrpAtField.Get_RefListField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtField.RefListField) as IgsAtRelationField;
end;

function TwrpAtField.Get_RefListFieldName: WideString;
begin
  Result := GetAtField.RefListFieldName;
end;

function TwrpAtField.Get_RefTable: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtField.RefTable) as IgsAtRelation;
end;

function TwrpAtField.Get_RefTableName: WideString;
begin
  Result := GetAtField.RefTableName;
end;

function TwrpAtField.Get_SetCondition: WideString;
begin
  Result := GetAtField.SetCondition;
end;

function TwrpAtField.Get_SetListField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtField.SetListField) as IgsAtRelationField;
end;

function TwrpAtField.Get_SetListFieldName: WideString;
begin
  Result := GetAtField.SetListFieldName;
end;

function TwrpAtField.Get_SetTable: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtField.SetTable) as IgsAtRelation;
end;

function TwrpAtField.Get_SetTableName: WideString;
begin
  Result := GetAtField.SetTableName;
end;

function TwrpAtField.Get_SQLSubType: Smallint;
begin
  Result := GetAtField.SQLSubType;
end;

function TwrpAtField.Get_SQLType: Smallint;
begin
  Result := GetAtField.SQLType;
end;

function TwrpAtField.Get_Visible: WordBool;
begin
  Result := GetAtField.Visible;
end;

function TwrpAtField.GetAtField: TAtField;
begin
  Result := GetObject as TAtField;
end;

function TwrpAtField.GetNumerationName(
  const Value: WideString): WideString;
begin
  Result := GetAtField.GetNumerationName(Value);
end;

function TwrpAtField.GetNumerationValue(
  const NameNumeration: WideString): WideString;
begin
  Result := GetAtField.GetNumerationValue(NameNumeration);
end;

procedure TwrpAtField.RecordAcquired;
begin
  GetAtField.RecordAcquired;
end;

procedure TwrpAtField.RefreshData;
begin
  GetAtField.RefreshData;
end;

procedure TwrpAtField.RefreshData_(const aDatabase: IgsIBDatabase;
  const ATransaction: IgsIBTransaction);
begin
  GetAtField.RefreshData(InterfaceToObject(aDatabase) as TIBDatabase,
    InterfaceToObject(ATransaction) as TIBTransaction);
end;

procedure TwrpAtField.RefreshData_1(const SQLRecord: IgsIBXSQLDA);
begin
  GetAtField.RefreshData(InterfaceToObject(SQLRecord) as TIBXSQLDA);
end;

procedure TwrpAtField.Set_SQLType(Value: Smallint);
begin
  GetAtField.SQLType := Value;
end;

{ TwrpAtForeignKey }

function TwrpAtForeignKey.Get_ConstraintField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.ConstraintField) as IgsAtRelationField;
end;

function TwrpAtForeignKey.Get_ConstraintFields: IgsAtRelationFields;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.ConstraintFields) as IgsAtRelationFields;
end;

function TwrpAtForeignKey.Get_ConstraintName: WideString;
begin
  Result := GetAtForeignKey.ConstraintName;
end;

function TwrpAtForeignKey.Get_IndexName: WideString;
begin
  Result := GetAtForeignKey.IndexName;
end;

function TwrpAtForeignKey.Get_IsDropped: WordBool;
begin
  Result := GetAtForeignKey.IsDropped;
end;

function TwrpAtForeignKey.Get_IsSimpleKey: WordBool;
begin
  Result := GetAtForeignKey.IsSimpleKey;
end;

function TwrpAtForeignKey.Get_ReferencesField: IgsAtRelationField;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.ReferencesField) as IgsAtRelationField;
end;

function TwrpAtForeignKey.Get_ReferencesFields: IgsAtRelationFields;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.ReferencesFields) as IgsAtRelationFields;
end;

function TwrpAtForeignKey.Get_ReferencesIndex: WideString;
begin
  Result := GetAtForeignKey.ReferencesIndex;
end;

function TwrpAtForeignKey.Get_ReferencesRelation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.ReferencesRelation) as IgsAtRelation;
end;

function TwrpAtForeignKey.Get_Relation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtForeignKey.Relation) as IgsAtRelation;
end;

function TwrpAtForeignKey.GetAtForeignKey: TAtForeignKey;
begin
  Result := GetObject as TAtForeignKey;
end;

procedure TwrpAtForeignKey.RefreshData;
begin
  GetAtForeignKey.RefreshData;
end;

procedure TwrpAtForeignKey.RefreshData_(const aDatabase: IgsIBDatabase;
  const ATransaction: IgsIBTransaction);
begin
  GetAtForeignKey.RefreshData(InterfaceToObject(aDatabase) as
    TIBDatabase, InterfaceToObject(ATransaction) as TIBTransaction);
end;

procedure TwrpAtForeignKey.RefreshData_1(const IBSQL: IgsIBSQL);
begin
  GetAtForeignKey.RefreshData(InterfaceToObject(IBSQL) as TIBSQL);
end;

{ TwrpGsTransaction }

function TwrpGsTransaction.AppendEntryToBase: WordBool;
begin
  Result := GetGsTransaction.AppendEntryToBase;
end;

procedure TwrpGsTransaction.CreateTransactionByDelayedTransaction(
  aTransactionKey, aFromDocumentKey, aToDocumentKey, aFromPositionKey,
  aToPositionKey: Integer; aDocumentDate: TDateTime;
  const aValueList: IgsObjectList);
begin
  GetGsTransaction.CreateTransactionByDelayedTransaction(
    aTransactionKey, aFromDocumentKey, aToDocumentKey, aFromPositionKey,
    aToPositionKey, aDocumentDate, InterfaceToObject(aValueList) as TObjectList);
end;

function TwrpGsTransaction.CreateTransactionOnDataSet(aCurrKey: Integer;
  aDocumentDate: TDateTime; const aValueList, aAnalyzeList: IgsObjectList;
  CheckTransaction, OnlyWithTransaction: WordBool): WordBool;
begin
  Result := GetGsTransaction.CreateTransactionOnDataSet(aCurrKey, aDocumentDate,
    InterfaceToObject(aValueList) as TObjectList,
    InterfaceToObject(aAnalyzeList) as TObjectList, CheckTransaction, OnlyWithTransaction);
end;

procedure TwrpGsTransaction.CreateTransactionOnPosition(aCurrKey: Integer;
  aDocumentDate: TDateTime; const aValueList, aAnalyzeList: IgsObjectList;
  isEditTransaction: WordBool);
begin
  GetGsTransaction.CreateTransactionOnPosition(aCurrKey, aDocumentDate,
    InterfaceToObject(aValueList) as TObjectList,
    InterfaceToObject(aAnalyzeList) as TObjectList, isEditTransaction);
end;

function TwrpGsTransaction.Get_BeginTransactionType: TgsBeginTransactionType;
begin
  Result := TgsBeginTransactionType(GetGsTransaction.BeginTransactionType);
end;

function TwrpGsTransaction.Get_Changed: WordBool;
begin
  Result := GetGsTransaction.Changed;
end;

function TwrpGsTransaction.Get_CurrencyKey: Integer;
begin
  Result := GetGsTransaction.CurrencyKey;
end;

function TwrpGsTransaction.Get_CurTransaction(
  Index: Integer): IgsTransaction;
begin
  Result := GetGdcOLEObject(GetGsTransaction.CurTransaction[Index]) as IgsTransaction;
end;

function TwrpGsTransaction.Get_CurTransactionCount: Integer;
begin
  Result := GetGsTransaction.CurTransactionCount;
end;

function TwrpGsTransaction.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetGsTransaction.DataSource) as IgsDataSource;
end;

function TwrpGsTransaction.Get_DocumentNumber: WideString;
begin
  Result := GetGsTransaction.DocumentNumber;
end;

function TwrpGsTransaction.Get_DocumentOnly: WordBool;
begin
  Result := GetGsTransaction.DocumentOnly;
end;

function TwrpGsTransaction.Get_DocumentType: Integer;
begin
  Result := GetGsTransaction.DocumentType;
end;

function TwrpGsTransaction.Get_FieldDocumentKey: WideString;
begin
  Result := GetGsTransaction.FieldDocumentKey;
end;

function TwrpGsTransaction.Get_FieldKey: WideString;
begin
  Result := GetGsTransaction.FieldKey;
end;

function TwrpGsTransaction.Get_FieldName: WideString;
begin
  Result := GetGsTransaction.FieldName;
end;

function TwrpGsTransaction.Get_FieldTrName: WideString;
begin
  Result := GetGsTransaction.FieldTrName;
end;

function TwrpGsTransaction.Get_MakeDelayedEntry: WordBool;
begin
  Result := GetGsTransaction.MakeDelayedEntry;
end;

function TwrpGsTransaction.Get_PosTransaction(
  Index: Integer): IgsPositionTransaction;
begin
  Result := GetGdcOLEObject(GetGsTransaction.PosTransaction[Index]) as IgsPositionTransaction;
end;

function TwrpGsTransaction.Get_PosTransactionCount: Integer;
begin
  Result := GetGsTransaction.PosTransactionCount;
end;

function TwrpGsTransaction.Get_SetTransactionType: TgsSetTransactionType;
begin
  Result := TgsSetTransactionType(GetGsTransaction.SetTransactionType);
end;

function TwrpGsTransaction.Get_TransactionDate: TDateTime;
begin
  Result := GetGsTransaction.TransactionDate;
end;

procedure TwrpGsTransaction.GetAnalyzeList(aTransactionKey: Integer;
  const aAnalyzeList: IgsList);
begin
  GetGsTransaction.GetAnalyzeList(aTransactionKey, InterfaceToObject(aAnalyzeList) as TList);
end;

function TwrpGsTransaction.GetGsTransaction: TGsTransaction;
begin
  Result := GetObject as TGsTransaction;
end;

function TwrpGsTransaction.GetTransaction(
  const List: IgsStrings): IgsTransaction;
begin
  Result := getGdcOLEObject(GetGsTransaction.GetTransaction(IgsStringsToTStrings(List)))
    as IgsTransaction;
end;

function TwrpGsTransaction.GetTransactionName(
  TransactionKey: Integer): WideString;
begin
  Result := GetGsTransaction.GetTransactionName(TransactionKey);
end;

function TwrpGsTransaction.IsCurrencyTransaction(
  aTransactionKey: Integer): WordBool;
begin
  Result := GetGsTransaction.IsCurrencyTransaction(aTransactionKey);
end;

function TwrpGsTransaction.IsValidDocTransaction(
  aTransactionKey: Integer): WordBool;
begin
  Result := GetGsTransaction.IsValidDocTransaction(aTransactionKey);
end;

function TwrpGsTransaction.IsValidTransaction(
  aTransactionKey: Integer): WordBool;
begin
  Result := GetGsTransaction.IsValidTransaction(aTransactionKey);
end;

procedure TwrpGsTransaction.ReadTransactionOnPosition(aDocumentCode,
  aPositionCode, aEntryKey: Integer);
begin
  GetGsTransaction.ReadTransactionOnPosition(aDocumentCode, aPositionCode, aEntryKey);
end;

procedure TwrpGsTransaction.Refresh;
begin
  GetGsTransaction.Refresh;
end;

procedure TwrpGsTransaction.Set_BeginTransactionType(
  Value: TgsBeginTransactionType);
begin
  GetGsTransaction.BeginTransactionType := TBeginTransactionType(Value);
end;

procedure TwrpGsTransaction.Set_Changed(Value: WordBool);
begin
  GetGsTransaction.Changed := Value;
end;

procedure TwrpGsTransaction.Set_CurrencyKey(Value: Integer);
begin
  GetGsTransaction.CurrencyKey := Value;
end;

procedure TwrpGsTransaction.Set_DataSource(const Value: IgsDataSource);
begin
  GetGsTransaction.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpGsTransaction.Set_DocumentOnly(Value: WordBool);
begin
  GetGsTransaction.DocumentOnly := Value;
end;

procedure TwrpGsTransaction.Set_DocumentType(Value: Integer);
begin
  GetGsTransaction.DocumentType := Value;
end;

procedure TwrpGsTransaction.Set_FieldDocumentKey(const Value: WideString);
begin
  GetGsTransaction.FieldDocumentKey := Value;
end;

procedure TwrpGsTransaction.Set_FieldKey(const Value: WideString);
begin
  GetGsTransaction.FieldKey := Value;
end;

procedure TwrpGsTransaction.Set_FieldName(const Value: WideString);
begin
  GetGsTransaction.FieldName := Value;
end;

procedure TwrpGsTransaction.Set_FieldTrName(const Value: WideString);
begin
  GetGsTransaction.FieldTrName := Value;
end;

procedure TwrpGsTransaction.Set_MakeDelayedEntry(Value: WordBool);
begin
  GetGsTransaction.MakeDelayedEntry := Value;
end;

procedure TwrpGsTransaction.Set_SetTransactionType(
  Value: TgsSetTransactionType);
begin
  GetGsTransaction.SetTransactionType := TSetTransactionType(Value);
end;

procedure TwrpGsTransaction.Set_TransactionDate(Value: TDateTime);
begin
  GetGsTransaction.TransactionDate := Value;
end;

function TwrpGsTransaction.SetStartTransactionInfo(
  ReadEntry: WordBool): WordBool;
begin
  Result := GetGsTransaction.SetStartTransactionInfo(ReadEntry);
end;

procedure TwrpGsTransaction.SetTransactionOnDataSet;
begin
  GetGsTransaction.SetTransactionOnDataSet;
end;

function TwrpGsTransaction.SetTransactionStrings(const Value: IgsStrings;
  aTransactionKey: Integer): Integer;
begin
  Result := GetGsTransaction.SetTransactionStrings(IgsStringsToTStrings(Value),
    aTransactionKey);
end;

{ TwrpTransaction }

procedure TwrpTransaction.AddTransactionCondition(
  const LocBlobStream: IgsIBDSBlobStream);
begin
  GetTransaction.AddTransactionCondition(InterfaceToObject(LocBlobStream) as TIBDSBlobStream);
end;

procedure TwrpTransaction.AddTypeEntry(const Entry: IgsEntry);
begin
  GetTransaction.AddTypeEntry(InterfaceToObject(Entry) as TEntry);
end;

procedure TwrpTransaction.Assign_(const Source: IgsTransaction);
begin
  GetTransaction.Assign(InterfaceToObject(Source) as TTransaction);
end;

function TwrpTransaction.Get_Description: WideString;
begin
  Result := GetTransaction.Description;
end;

function TwrpTransaction.Get_DocumentTypeKey: Integer;
begin
  Result := GetTransaction.DocumentTypeKey;
end;

function TwrpTransaction.Get_IsDocument: WordBool;
begin
  Result := GetTransaction.IsDocument;
end;

function TwrpTransaction.Get_TransactionFilterData: IgsFilterData;
begin
  Result := GetGdcOLEObject(GetTransaction.TransactionFilterData) as IgsFilterData;
end;

function TwrpTransaction.Get_TransactionKey: Integer;
begin
  Result := GetTransaction.TransactionKey;
end;

function TwrpTransaction.Get_TransactionName: WideString;
begin
  Result := GetTransaction.TransactionName;
end;

function TwrpTransaction.Get_TypeEntry(Index: Integer): IgsEntry;
begin
  Result := GetGdcOLEObject(GetTransaction.TypeEntry[Index]) as IgsEntry;
end;

function TwrpTransaction.Get_TypeEntryCount: Integer;
begin
  Result := GetTransaction.TypeEntryCount;
end;

function TwrpTransaction.GetTransaction: TTransaction;
begin
  Result := GetObject as TTransaction;
end;

function TwrpTransaction.IsCurrencyTransaction: WordBool;
begin
  Result := GetTransaction.IsCurrencyTransaction;
end;

function TwrpTransaction.IsTransaction(
  const aTransaction: IgsIBTransaction;
  const Values: IgsFilterConditionList): WordBool;
begin
  Result := GetTransaction.IsTransaction(InterfaceToObject(aTransaction) as
    TIBTransaction, InterfaceToObject(Values) as TFilterConditionList);
end;

function TwrpTransaction.IsUseVariable(
  const aVariable: WideString): WordBool;
begin
  Result := GetTransaction.IsUseVariable(aVariable);
end;

procedure TwrpTransaction.Set_Description(const Value: WideString);
begin
  GetTransaction.Description := Value;
end;

procedure TwrpTransaction.Set_DocumentTypeKey(Value: Integer);
begin
  GetTransaction.DocumentTypeKey := Value;
end;

procedure TwrpTransaction.Set_IsDocument(Value: WordBool);
begin
  GetTransaction.IsDocument := Value;
end;

procedure TwrpTransaction.Set_TransactionKey(Value: Integer);
begin
  GetTransaction.TransactionKey := Value;
end;

procedure TwrpTransaction.Set_TransactionName(const Value: WideString);
begin
  GetTransaction.TransactionName := Value;
end;

{ TwrpPositionTransaction }

procedure TwrpPositionTransaction.AddRealEntry(const Entry: IgsEntry);
begin
  GetPositionTransaction.AddRealEntry(InterfaceToObject(Entry) as TEntry);
end;

function TwrpPositionTransaction.ChangeValue(aDocumentKey,
  aPositionKey: Integer; aDocumentDate: TDateTime;
  const ValueList: IgsObjectList): WordBool;
begin
  Result := GetPositionTransaction.ChangeValue(aDocumentKey,
    aPositionKey, aDocumentDate, InterfaceToObject(ValueList) as TObjectList);
end;

procedure TwrpPositionTransaction.ClearRealEntry;
begin
  GetPositionTransaction.ClearRealEntry;
end;

function TwrpPositionTransaction.CreateRealEntry(const aValueList,
  aAnalyzeList: IgsObjectList; aCurrKey: Integer): WordBool;
begin
  Result := GetPositionTransaction.CreateRealEntry(InterfaceToObject(aValueList) as
    TObjectList, InterfaceToObject(aAnalyzeList) as TObjectList, aCurrKey);
end;

function TwrpPositionTransaction.Get_DocumentCode: Integer;
begin
  Result := GetPositionTransaction.DocumentCode;
end;

function TwrpPositionTransaction.Get_PositionCode: Integer;
begin
  Result := GetPositionTransaction.PositionCode;
end;

function TwrpPositionTransaction.Get_RealEntry(Index: Integer): IgsEntry;
begin
  Result := GetGdcOLEObject(GetPositionTransaction.RealEntry[Index]) as IgsEntry;
end;

function TwrpPositionTransaction.Get_RealEntryCount: Integer;
begin
  Result := GetPositionTransaction.RealEntryCount;
end;

function TwrpPositionTransaction.Get_SumTransaction: Currency;
begin
  Result := GetPositionTransaction.SumTransaction;
end;

function TwrpPositionTransaction.Get_TransactionChanged: WordBool;
begin
  Result := GetPositionTransaction.TransactionChanged;
end;

function TwrpPositionTransaction.Get_TransactionDate: TDateTime;
begin
  Result := GetPositionTransaction.TransactionDate;
end;

function TwrpPositionTransaction.GetPositionTransaction: TPositionTransaction;
begin
  Result := GetObject as TPositionTransaction;
end;

procedure TwrpPositionTransaction.Set_DocumentCode(Value: Integer);
begin
  GetPositionTransaction.DocumentCode := Value;
end;

procedure TwrpPositionTransaction.Set_PositionCode(Value: Integer);
begin
  GetPositionTransaction.PositionCode := Value;
end;

procedure TwrpPositionTransaction.Set_TransactionChanged(Value: WordBool);
begin
  GetPositionTransaction.TransactionChanged := Value;
end;

procedure TwrpPositionTransaction.Set_TransactionDate(Value: TDateTime);
begin
  GetPositionTransaction.TransactionDate := Value;
end;

{ TwrpIBDSBlobStream }

function TwrpIBDSBlobStream.GetIBDSBlobStream: TIBDSBlobStream;
begin
  Result := GetObject as TIBDSBlobStream;
end;

procedure TwrpIBDSBlobStream.SetSize(NewSize: Integer);
begin
  GetIBDSBlobStream.SetSize(NewSize);
end;

{ TwrpEntry }

procedure TwrpEntry.AddEntryLine(const AccountInfo: IgsAccount;
  IsDebit: WordBool; const aDescription: WideString);
begin
  GetEntry.AddEntryLine(InterfaceToObject(AccountInfo) as TAccount,
    IsDebit, aDescription);
end;

procedure TwrpEntry.AddFromTypeEntry(const TypeEntry: IgsEntry;
  const aValueList, aAnalyzeList: IgsObjectList; aCurrKey: Integer);
begin
  GetEntry.AddFromTypeEntry(InterfaceToObject(TypeEntry) as TEntry,
    InterfaceToObject(aValueList) as TObjectList,
    InterfaceToObject(aAnalyzeList) as TObjectList, aCurrKey);
end;

function TwrpEntry.CheckBalans: WordBool;
begin
  Result := GetEntry.CheckBalans;
end;

procedure TwrpEntry.Clear;
begin
  GetEntry.Clear;
end;

function TwrpEntry.Get_Changed: WordBool;
begin
  Result := GetEntry.Changed;
end;

function TwrpEntry.Get_Credit(Index: Integer): IgsAccount; safecall;
begin
  Result := GetGdcOLEObject(GetEntry.Credit[index]) as IgsAccount;
end;

function TwrpEntry.Get_CreditCount: Integer;
begin
  Result := GetEntry.CreditCount;
end;

function TwrpEntry.Get_Debit(Index: Integer): IgsAccount;
begin
  Result := GetGdcOLEObject(GetEntry.Debit[index]) as IgsAccount;
end;

function TwrpEntry.Get_DebitCount: Integer;
begin
  Result := GetEntry.DebitCount;
end;

function TwrpEntry.Get_Description: WideString;
begin
  Result := GetEntry.Description;
end;

function TwrpEntry.Get_DocumentKey: Integer;
begin
  Result := GetEntry.DocumentKey;
end;

function TwrpEntry.Get_EntryDate: TDateTime;
begin
  Result := GetEntry.EntryDate;
end;

function TwrpEntry.Get_EntryKey: Integer;
begin
  Result := GetEntry.EntryKey;
end;

function TwrpEntry.Get_PositionKey: Integer;
begin
  Result := GetEntry.PositionKey;
end;

function TwrpEntry.GetCreditSumCurr: Currency;
begin
  Result := GetEntry.GetCreditSumCurr;
end;

function TwrpEntry.GetCreditSumNCU: Currency;
begin
  Result := GetEntry.GetCreditSumNCU;
end;

function TwrpEntry.GetDebitSumCurr: Currency;
begin
  Result := GetEntry.GetDebitSumCurr;
end;

function TwrpEntry.GetDebitSumNCU: Currency;
begin
  Result := GetEntry.GetDebitSumNCU;
end;

function TwrpEntry.GetEntry: TEntry;
begin
  Result := GetObject as TEntry;
end;

function TwrpEntry.IsCurrencyEntry: WordBool;
begin
  Result := GetEntry.IsCurrencyEntry;
end;

function TwrpEntry.IsUseVariable(const aVariable: WideString): WordBool;
begin
  Result := GetEntry.IsUseVariable(aVariable);
end;

procedure TwrpEntry.Set_Changed(Value: WordBool);
begin
  GetEntry.Changed := Value;
end;

procedure TwrpEntry.Set_Description(const Value: WideString);
begin
  GetEntry.Description := Value;
end;

procedure TwrpEntry.Set_DocumentKey(Value: Integer);
begin
  GetEntry.DocumentKey := Value;
end;

procedure TwrpEntry.Set_EntryDate(Value: TDateTime);
begin
  GetEntry.EntryDate := Value;
end;

procedure TwrpEntry.Set_EntryKey(Value: Integer);
begin
  GetEntry.EntryKey := Value;
end;

procedure TwrpEntry.Set_PositionKey(Value: Integer);
begin
  GetEntry.PositionKey := Value;
end;

procedure TwrpEntry.SetSumFromTypeEntry(const TypeEntry: IgsEntry;
  const aValueList: IgsObjectList);
begin
  GetEntry.SetSumFromTypeEntry(InterfaceToObject(TypeEntry) as TEntry,
    InterfaceToObject(aValueList) as TObjectList);
end;

{ TwrpAccount }

procedure TwrpAccount.AddAnalyze(const aFromTableName, aFromFieldName,
  aReferencyName, aFieldName: WideString; aValueAnalyze: Integer);
begin
  GetAccount.AddAnalyze(aFromTableName, aFromFieldName, aReferencyName,
    aFieldName, aValueAnalyze);
end;

function TwrpAccount.AnalyzeByType(
  const aReferencyName: WideString): Integer;
begin
  Result := GetAccount.AnalyzeByType(aReferencyName);
end;

procedure TwrpAccount.AssignAnalyze(const aAnalyze: IgsObjectList);
begin
  GetAccount.AssignAnalyze(InterfaceToObject(aAnalyze) as TObjectList);
end;

function TwrpAccount.CountAnalyze: Integer;
begin
  Result := GetAccount.CountAnalyze;
end;

function TwrpAccount.Get_Alias: WideString;
begin
  Result := GetAccount.Alias;
end;

function TwrpAccount.Get_AnalyzeItem(Index: Integer): IgsAnalyze;
begin
  Result := GetGdcOLEObject(GetAccount.AnalyzeItem[index]) as IgsAnalyze;
end;

function TwrpAccount.Get_Code: Integer;
begin
  Result := GetAccount.Code;
end;

function TwrpAccount.Get_CurrencyAccount: WordBool;
begin
  Result := GetAccount.CurrencyAccount;
end;

function TwrpAccount.Get_Name: WideString;
begin
  Result := GetAccount.Name;
end;

function TwrpAccount.GetAccount: TAccount;
begin
  Result := GetObject as TAccount;
end;

function TwrpAccount.IsAnalyze(const aReferencyName: WideString): WordBool;
begin
  Result := GetAccount.IsAnalyze(aReferencyName);
end;

procedure TwrpAccount.Set_Alias(const Value: WideString);
begin
  GetAccount.Alias := Value;
end;

procedure TwrpAccount.Set_Code(Value: Integer);
begin
  GetAccount.Code := Value;
end;

procedure TwrpAccount.Set_Name(const Value: WideString);
begin
  GetAccount.Name := Value;
end;

{ TwrpAnalyze }

function TwrpAnalyze.Get_FieldName: WideString;
begin
  Result := GetAnalyze.FieldName;
end;

function TwrpAnalyze.Get_FromFieldName: WideString;
begin
  Result := GetAnalyze.FromFieldName;
end;

function TwrpAnalyze.Get_FromTableName: WideString;
begin
  Result := GetAnalyze.FromTableName;
end;

function TwrpAnalyze.Get_ReferencyName: WideString;
begin
  Result := GetAnalyze.ReferencyName;
end;

function TwrpAnalyze.Get_ValueAnalyze: Integer;
begin
  Result := GetAnalyze.ValueAnalyze;
end;

function TwrpAnalyze.GetAnalyze: TAnalyze;
begin
  Result := GetObject as TAnalyze;
end;

procedure TwrpAnalyze.Set_FieldName(const Value: WideString);
begin
  GetAnalyze.FieldName := Value;
end;

procedure TwrpAnalyze.Set_FromFieldName(const Value: WideString);
begin
  GetAnalyze.FromFieldName := Value;
end;

procedure TwrpAnalyze.Set_FromTableName(const Value: WideString);
begin
  GetAnalyze.FromTableName := Value;
end;

procedure TwrpAnalyze.Set_ReferencyName(const Value: WideString);
begin
  GetAnalyze.ReferencyName := Value;
end;

procedure TwrpAnalyze.Set_ValueAnalyze(Value: Integer);
begin
  GetAnalyze.ValueAnalyze := Value;
end;

{ TwrpGsUserStorage }

function TwrpGsUserStorage.Get_UserKey: Integer;
begin
  Result := GetGsUserStorage.ObjectKey;
end;

function TwrpGsUserStorage.GetGsUserStorage: TgsUserStorage;
begin
  Result := GetObject as TgsUserStorage;
end;

procedure TwrpGsUserStorage.Set_UserKey(Value: Integer);
begin
  GetGsUserStorage.ObjectKey := Value;
end;

{ TwrpAtContainer }

function TwrpAtContainer.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(GetAtContainer.BorderStyle);
end;

function TwrpAtContainer.Get_ControlByFieldName(
  const AFieldName: WideString): IgsControl;
begin
  Result := GetGdcOLEObject(GetAtContainer.ControlByFieldName[AFieldName]) as IgsControl;
end;

function TwrpAtContainer.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetAtContainer.DataSource) as IgsDataSource;
end;

function TwrpAtContainer.Get_LabelIndent: Integer;
begin
  Result := GetAtContainer.LabelIndent;
end;

function TwrpAtContainer.GetAtContainer: TatContainer;
begin
  Result := GetObject as TatContainer;
end;

{procedure TwrpAtContainer.LoadFromStream(const Stream: IgsStream);
begin
  GetAtContainer.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpAtContainer.SaveToStream(const Stream: IgsStream);
begin
  GetAtContainer.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;}

procedure TwrpAtContainer.Set_BorderStyle(Value: TgsBorderStyle);
begin
  GetAtContainer.BorderStyle := TBorderStyle(Value);
end;

procedure TwrpAtContainer.Set_DataSource(const Value: IgsDataSource);
begin
  GetAtContainer.DataSource := InterfaceToObject(Value) as TDataSource;
end;

{ TwrpNumberConvert }

function TwrpNumberConvert.ConvertFromString(const S, Digits, Prefix,
  Postfix: WideString): Double;
begin
  Result := GetNumberConvert.ConvertFromString(S, Digits, Prefix, Postfix);
end;

function TwrpNumberConvert.ConvertToString(const Digits: WideString;
  UpCase: WordBool; const Prefix, Postfix: WideString): WideString;
begin
  Result := GetNumberConvert.ConvertToString(Digits, UpCase, Prefix, Postfix);
end;

function TwrpNumberConvert.Get_Bin: WideString;
begin
  Result := GetNumberConvert.Bin;
end;

function TwrpNumberConvert.Get_BinPostfix: WideString;
begin
  Result := GetNumberConvert.BinPostfix;
end;

function TwrpNumberConvert.Get_BinPref: WideString;
begin
  Result := GetNumberConvert.BinPref;
end;

function TwrpNumberConvert.Get_BlankChar: WideString;
begin
  Result := GetNumberConvert.BlankChar;
end;

function TwrpNumberConvert.Get_Dec: WideString;
begin
  Result := GetNumberConvert.Dec;
end;

function TwrpNumberConvert.Get_DecPostfix: WideString;
begin
  Result := GetNumberConvert.DecPostfix;
end;

function TwrpNumberConvert.Get_DecPrefix: WideString;
begin
  Result := GetNumberConvert.DecPrefix;
end;

function TwrpNumberConvert.Get_FreeStyle: WideString;
begin
  Result := GetNumberConvert.FreeStyle;
end;

function TwrpNumberConvert.Get_FreeStyleDigits: WideString;
begin
  Result := GetNumberConvert.FreeStyleDigits;
end;

function TwrpNumberConvert.Get_FreeStylePostfix: WideString;
begin
  Result := GetNumberConvert.FreeStylePostfix;
end;

function TwrpNumberConvert.Get_FreeStylePref: WideString;
begin
  Result := GetNumberConvert.FreeStylePref;
end;

function TwrpNumberConvert.Get_Gender: TgsGender;
begin
  Result := TgsGender(GetNumberConvert.Gender);
end;

function TwrpNumberConvert.Get_Hex: WideString;
begin
  Result := GetNumberConvert.Hex;
end;

function TwrpNumberConvert.Get_HexPostfix: WideString;
begin
  Result := GetNumberConvert.HexPostfix;
end;

function TwrpNumberConvert.Get_HexPrefix: WideString;
begin
  Result := GetNumberConvert.HexPrefix;
end;

function TwrpNumberConvert.Get_Language: TgsLanguage;
begin
  Result := TgsLanguage(GetNumberConvert.Language);
end;

function TwrpNumberConvert.Get_Numeral: WideString;
begin
  Result := GetNumberConvert.Numeral;
end;

function TwrpNumberConvert.Get_NumPostfix: WideString;
begin
  Result := GetNumberConvert.NumPostfix;
end;

function TwrpNumberConvert.Get_NumPrefix: WideString;
begin
  Result := GetNumberConvert.NumPrefix;
end;

function TwrpNumberConvert.Get_Oct: WideString;
begin
  Result := GetNumberConvert.Oct;
end;

function TwrpNumberConvert.Get_OctPostfix: WideString;
begin
  Result := GetNumberConvert.OctPostfix;
end;

function TwrpNumberConvert.Get_OctPrefix: WideString;
begin
  Result := GetNumberConvert.OctPrefix;
end;

function TwrpNumberConvert.Get_PrefixBeforeBlank: WordBool;
begin
  Result := GetNumberConvert.PrefixBeforeBlank;
end;

function TwrpNumberConvert.Get_Roman: WideString;
begin
  Result := GetNumberConvert.Roman;
end;

function TwrpNumberConvert.Get_RomPostfix: WideString;
begin
  Result := GetNumberConvert.RomPostfix;
end;

function TwrpNumberConvert.Get_RomPrefix: WideString;
begin
  Result := GetNumberConvert.RomPrefix;
end;

function TwrpNumberConvert.Get_SignBeforePrefix: WordBool;
begin
  Result := GetNumberConvert.SignBeforePrefix;
end;

function TwrpNumberConvert.Get_UpperCase: WordBool;
begin
  Result := GetNumberConvert.UpperCase;
end;

function TwrpNumberConvert.Get_Value: Double;
begin
  Result := GetNumberConvert.Value;
end;

function TwrpNumberConvert.Get_Width: Integer;
begin
  Result := GetNumberConvert.Width;
end;

function TwrpNumberConvert.GetNumberConvert: TNumberConvert;
begin
  Result := GetObject as TNumberConvert;
end;

procedure TwrpNumberConvert.Set_Bin(const Value: WideString);
begin
  GetNumberConvert.Bin := Value;
end;

procedure TwrpNumberConvert.Set_BinPostfix(const Value: WideString);
begin
  GetNumberConvert.BinPostfix := Value;
end;

procedure TwrpNumberConvert.Set_BinPref(const Value: WideString);
begin
  GetNumberConvert.BinPref := Value;
end;

procedure TwrpNumberConvert.Set_BlankChar(const Value: WideString);
var
  S: String;
begin
  S := Trim(Value);
  Assert(Length(S) <> 1, 'Несоответствие типа. Необходимо присвоить один символ.');


  GetNumberConvert.BlankChar := S[1];
end;

procedure TwrpNumberConvert.Set_Dec(const Value: WideString);
begin
  GetNumberConvert.Dec := Value;
end;

procedure TwrpNumberConvert.Set_DecPostfix(const Value: WideString);
begin
  GetNumberConvert.DecPostfix := Value;
end;

procedure TwrpNumberConvert.Set_DecPrefix(const Value: WideString);
begin
  GetNumberConvert.DecPrefix := Value;
end;

procedure TwrpNumberConvert.Set_FreeStyle(const Value: WideString);
begin
  GetNumberConvert.FreeStyle := Value;
end;

procedure TwrpNumberConvert.Set_FreeStyleDigits(const Value: WideString);
begin
  GetNumberConvert.FreeStyleDigits := Value;
end;

procedure TwrpNumberConvert.Set_FreeStylePostfix(const Value: WideString);
begin
  GetNumberConvert.FreeStylePostfix := Value;
end;

procedure TwrpNumberConvert.Set_FreeStylePref(const Value: WideString);
begin
  GetNumberConvert.FreeStylePref := Value;
end;

procedure TwrpNumberConvert.Set_Gender(Value: TgsGender);
begin
  GetNumberConvert.Gender := TGender(Value);
end;

procedure TwrpNumberConvert.Set_Hex(const Value: WideString);
begin
  GetNumberConvert.Hex := Value;
end;

procedure TwrpNumberConvert.Set_HexPostfix(const Value: WideString);
begin
  GetNumberConvert.HexPostfix := Value;
end;

procedure TwrpNumberConvert.Set_HexPrefix(const Value: WideString);
begin
  GetNumberConvert.HexPrefix := Value;
end;

procedure TwrpNumberConvert.Set_Language(Value: TgsLanguage);
begin
  GetNumberConvert.Language := TLanguage(Value);
end;

procedure TwrpNumberConvert.Set_Numeral(const Value: WideString);
begin
  GetNumberConvert.Numeral := Value;
end;

procedure TwrpNumberConvert.Set_NumPostfix(const Value: WideString);
begin
  GetNumberConvert.NumPostfix := Value;
end;

procedure TwrpNumberConvert.Set_NumPrefix(const Value: WideString);
begin
  GetNumberConvert.NumPrefix := Value;
end;

procedure TwrpNumberConvert.Set_Oct(const Value: WideString);
begin
  GetNumberConvert.Oct := Value;
end;

procedure TwrpNumberConvert.Set_OctPostfix(const Value: WideString);
begin
  GetNumberConvert.OctPostfix := Value;
end;

procedure TwrpNumberConvert.Set_OctPrefix(const Value: WideString);
begin
  GetNumberConvert.OctPrefix := Value;
end;

procedure TwrpNumberConvert.Set_PrefixBeforeBlank(Value: WordBool);
begin
  GetNumberConvert.PrefixBeforeBlank := Value;
end;

procedure TwrpNumberConvert.Set_Roman(const Value: WideString);
begin
  GetNumberConvert.Roman := Value;
end;

procedure TwrpNumberConvert.Set_RomPostfix(const Value: WideString);
begin
  GetNumberConvert.RomPostfix := Value;
end;

procedure TwrpNumberConvert.Set_RomPrefix(const Value: WideString);
begin
  GetNumberConvert.RomPrefix := Value;
end;

procedure TwrpNumberConvert.Set_SignBeforePrefix(Value: WordBool);
begin
  GetNumberConvert.SignBeforePrefix := Value;
end;

procedure TwrpNumberConvert.Set_UpperCase(Value: WordBool);
begin
  GetNumberConvert.UpperCase := Value;
end;

procedure TwrpNumberConvert.Set_Value(Value: Double);
begin
  GetNumberConvert.Value := Value;
end;

procedure TwrpNumberConvert.Set_Width(Value: Integer);
begin
  GetNumberConvert.Width := Value;
end;

{ TwrpGsScanerHook }

function TwrpGsScanerHook.Get_AfterChar: Word;
begin
  Result := GetGsScanerHook.AfterChar;
end;

function TwrpGsScanerHook.Get_BarCode: WideString;
begin
  Result := GetGsScanerHook.BarCode;
end;

function TwrpGsScanerHook.Get_BeforeChar: Word;
begin
  Result := GetGsScanerHook.BeforeChar
end;

function TwrpGsScanerHook.Get_StartScaner: WordBool;
begin
  Result := GetGsScanerHook.StartScaner
end;

function TwrpGsScanerHook.Get_TestCode: WideString;
begin
  Result := GetGsScanerHook.TestCode
end;

function TwrpGsScanerHook.Get_UseCtrlCode: WordBool;
begin
  Result := GetGsScanerHook.UseCtrlCode
end;

function TwrpGsScanerHook.GetGsScanerHook: TgsScanerHook;
begin
  Result := GetObject as TgsScanerHook;
end;

procedure TwrpGsScanerHook.Set_AfterChar(Value: Word);
begin
  GetGsScanerHook.AfterChar := Value;
end;

procedure TwrpGsScanerHook.Set_BarCode(const Value: WideString);
begin
  GetGsScanerHook.BarCode := Value;
end;

procedure TwrpGsScanerHook.Set_BeforeChar(Value: Word);
begin
  GetGsScanerHook.BeforeChar := Value;
end;

procedure TwrpGsScanerHook.Set_StartScaner(Value: WordBool);
begin
  GetGsScanerHook.StartScaner := Value;
end;

procedure TwrpGsScanerHook.Set_TestCode(const Value: WideString);
begin
  GetGsScanerHook.TestCode := Value;
end;

procedure TwrpGsScanerHook.Set_UseCtrlCode(Value: WordBool);
begin
  GetGsScanerHook.UseCtrlCode := Value;
end;

function TwrpGsScanerHook.Get_Enabled: WordBool;
begin
  Result := GetGsScanerHook.Enabled;
end;

procedure TwrpGsScanerHook.Set_Enabled(Value: WordBool);
begin
  GetGsScanerHook.Enabled := Value;
end;

procedure TwrpGsScanerHook.InitScaner(aEnabled: WordBool);
begin
  GetGsScanerHook.InitScaner(aEnabled);
end;

function TwrpGsScanerHook.Get_UseCtrlCodeAfter: WordBool;
begin
  Result := GetGsScanerHook.UseCtrlCodeAfter
end;

procedure TwrpGsScanerHook.Set_UseCtrlCodeAfter(Value: WordBool);
begin
  GetGsScanerHook.UseCtrlCodeAfter := Value;
end;

{ TwrpGsCustomDBTreeView }

procedure TwrpGsCustomDBTreeView.AddCheck(AnID: Integer);
begin
  GetGsCustomDBTreeView.AddCheck(AnID);
end;

procedure TwrpGsCustomDBTreeView.Cut;
begin
  GetGsCustomDBTreeView.Cut
end;

procedure TwrpGsCustomDBTreeView.DeleteCheck(AnID: Integer);
begin
  GetGsCustomDBTreeView.DeleteCheck(AnID)
end;

procedure TwrpGsCustomDBTreeView.DeleteID(AnID: Integer);
begin
  GetGsCustomDBTreeView.DeleteID(AnID)
end;

function TwrpGsCustomDBTreeView.Find(AnID: Integer): IgsTreeNode;
begin
  GetGsCustomDBTreeView.Find(AnID)
end;

function TwrpGsCustomDBTreeView.GetGsCustomDBTreeView: TGsCustomDBTreeView;
begin
  Result := GetObject as TgsCustomDBTreeView;
end;

function TwrpGsCustomDBTreeView.Get_CutNode: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetGsCustomDBTreeView.CutNode) as IgsTreeNode;
end;

function TwrpGsCustomDBTreeView.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetGsCustomDBTreeView.DataSource) as IgsDataSource;
end;

function TwrpGsCustomDBTreeView.Get_DisplayField: WideString;
begin
  Result := GetGsCustomDBTreeView.DisplayField;
end;

function TwrpGsCustomDBTreeView.Get_ID: Integer;
begin
  Result := GetGsCustomDBTreeView.ID
end;

function TwrpGsCustomDBTreeView.Get_ImageField: WideString;
begin
  Result := GetGsCustomDBTreeView.ImageField;
end;

function TwrpGsCustomDBTreeView.Get_ImageValueList: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGsCustomDBTreeView.ImageValueList) as IgsStringList;
end;

function TwrpGsCustomDBTreeView.Get_KeyField: WideString;
begin
  Result := GetGsCustomDBTreeView.KeyField;
end;

function TwrpGsCustomDBTreeView.Get_MainFolder: WordBool;
begin
  Result := GetGsCustomDBTreeView.MainFolder;
end;

function TwrpGsCustomDBTreeView.Get_MainFolderCaption: WideString;
begin
  Result := GetGsCustomDBTreeView.MainFolderCaption;
end;

function TwrpGsCustomDBTreeView.Get_MainFolderHead: WordBool;
begin
  Result := GetGsCustomDBTreeView.MainFolderHead
end;

function TwrpGsCustomDBTreeView.Get_ParentField: WideString;
begin
  Result := GetGsCustomDBTreeView.ParentField
end;

function TwrpGsCustomDBTreeView.Get_ParentID: Integer;
begin
  Result := GetGsCustomDBTreeView.ParentID
end;

function TwrpGsCustomDBTreeView.Get_TopKey: Integer;
begin
  Result := GetGsCustomDBTreeView.TopKey
end;

function TwrpGsCustomDBTreeView.Get_TVState: IgsTvState;
begin
  Result := GetGdcOLEObject(GetGsCustomDBTreeView.TVState) as IgsTvState;
end;

function TwrpGsCustomDBTreeView.Get_WithCheckBox: WordBool;
begin
  Result := GetGsCustomDBTreeView.WithCheckBox
end;

function TwrpGsCustomDBTreeView.GoToID(AnID: Integer): WordBool;
begin
  Result := GetGsCustomDBTreeView.GoToID(AnID)
end;

procedure TwrpGsCustomDBTreeView.LoadFromStream_(const S: IgsStream);
begin
  GetGsCustomDBTreeView.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsCustomDBTreeView.SaveToStream_(const S: IgsStream);
begin
  GetGsCustomDBTreeView.SaveToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpGsCustomDBTreeView.Set_DataSource(
  const Value: IgsDataSource);
begin
  GetGsCustomDBTreeView.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpGsCustomDBTreeView.Set_DisplayField(const Value: WideString);
begin
  GetGsCustomDBTreeView.DisplayField := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_ImageField(const Value: WideString);
begin
  GetGsCustomDBTreeView.ImageField := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_ImageValueList(
  const Value: IgsStringList);
begin
  GetGsCustomDBTreeView.ImageValueList := InterfaceToObject(Value) as TStringList;
end;

procedure TwrpGsCustomDBTreeView.Set_KeyField(const Value: WideString);
begin
  GetGsCustomDBTreeView.KeyField := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_MainFolder(Value: WordBool);
begin
  GetGsCustomDBTreeView.MainFolder := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_MainFolderCaption(
  const Value: WideString);
begin
  GetGsCustomDBTreeView.MainFolderCaption := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_MainFolderHead(Value: WordBool);
begin
  GetGsCustomDBTreeView.MainFolderHead := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_ParentField(const Value: WideString);
begin
  GetGsCustomDBTreeView.ParentField := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_TopKey(Value: Integer);
begin
  GetGsCustomDBTreeView.TopKey := Value;
end;

procedure TwrpGsCustomDBTreeView.Set_WithCheckBox(Value: WordBool);
begin
  GetGsCustomDBTreeView.WithCheckBox := Value;
end;

{ TwrpGdKeyStringAssoc }

function TwrpGdKeyStringAssoc.Get_ValuesByIndex(
  Index: Integer): WideString;
begin
  Result := GetGdKeyStringAssoc.ValuesByIndex[Index];
end;

function TwrpGdKeyStringAssoc.Get_ValuesByKey(Key: Integer): WideString;
begin
  Result := GetGdKeyStringAssoc.ValuesByKey[Key];
end;

function TwrpGdKeyStringAssoc.GetGdKeyStringAssoc: TgdKeyStringAssoc;
begin
  Result:= GetObject as TgdKeyStringAssoc;
end;

procedure TwrpGdKeyStringAssoc.Set_ValuesByIndex(Index: Integer;
  const Value: WideString);
begin
  GetGdKeyStringAssoc.ValuesByIndex[Index] := Value;
end;

class function TwrpGdKeyStringAssoc.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyStringAssoc), 'Invalide Delphi class');
  Result := TgdKeyStringAssoc.Create;
end;

{ TwrpTvState }

function TwrpTvState.Get_Bookmarks: IgsGdKeyStringAssoc;
begin
  Result := GetGdcOLEObject(GetTvState.Bookmarks) as IgsGdKeyStringAssoc
end;

function TwrpTvState.Get_Checked: IgsGDKeyArray;
begin
  Result := GetGdcOLEObject(GetTvState.Checked) as IgsGDKeyArray
end;

function TwrpTvState.Get_CheckedChanged: WordBool;
begin
  Result := GetTvState.CheckedChanged;
end;

function TwrpTvState.Get_SelectedID: Integer;
begin
  Result := GetTvState.SelectedID;
end;

function TwrpTvState.GetTvState: TTVState;
begin
  Result := GetObject as TTvState;
end;

procedure TwrpTvState.InitTree;
begin
  GetTvState.InitTree
end;

procedure TwrpTvState.LoadFromStream(const S: IgsStream);
begin
  GetTvState.LoadFromStream(InterfaceToObject(S) as TStream)
end;

procedure TwrpTvState.NodeChecked(AnID: Integer);
begin
  GetTvState.NodeChecked(AnID)
end;

procedure TwrpTvState.NodeCollapsed(AnID: Integer);
begin
  GetTvState.NodeCollapsed(AnID)
end;

procedure TwrpTvState.NodeExpanded(AnID: Integer);
begin
  GetTvState.NodeExpanded(AnID)
end;

procedure TwrpTvState.NodeUnChecked(AnID: Integer);
begin
  GetTvState.NodeUnChecked(AnID)
end;

procedure TwrpTvState.SaveToStream(const S: IgsStream);
begin
  GetTvState.SaveToStream(InterfaceToObject(S) as TStream)
end;

procedure TwrpTvState.SaveTreeState;
begin
  GetTvState.SaveTreeState
end;

procedure TwrpTvState.Set_SelectedID(Value: Integer);
begin
  GetTvState.SelectedID := Value;
end;

{ TwrpCustomColorComboBox }

function TwrpCustomColorComboBox.Get_ColorNames(
  Index: Integer): WideString;
begin
  Result := GetCustomColorComboBox.ColorNames[Index];
end;

function TwrpCustomColorComboBox.Get_Colors(Index: Integer): Integer;
begin
  Result := GetCustomColorComboBox.Colors[Index];
end;

function TwrpCustomColorComboBox.Get_DefaultColor: Integer;
begin
  Result := GetCustomColorComboBox.DefaultColor
end;

function TwrpCustomColorComboBox.Get_NoneColor: Integer;
begin
  Result := GetCustomColorComboBox.NoneColor;
end;

function TwrpCustomColorComboBox.Get_Selected: Integer;
begin
  Result := GetCustomColorComboBox.Selected;
end;

function TwrpCustomColorComboBox.GetCustomColorComboBox: TCustomColorComboBox;
begin
  Result := GetObject as TCustomColorComboBox;
end;

procedure TwrpCustomColorComboBox.Set_DefaultColor(Value: Integer);
begin
  GetCustomColorComboBox.DefaultColor := Value;
end;

procedure TwrpCustomColorComboBox.Set_NoneColor(Value: Integer);
begin
  GetCustomColorComboBox.NoneColor := Value;
end;

procedure TwrpCustomColorComboBox.Set_Selected(Value: Integer);
begin
  GetCustomColorComboBox.Selected := Value;
end;

{ TwrpAtPrimaryKeys }

function TwrpAtPrimaryKeys.Add(
  const atPrimaryKey: IgsAtPrimaryKey): Integer;
begin
  Result := GetAtPrimaryKeys.Add(InterfaceToObject(atPrimaryKey) as TAtPrimaryKey);
end;

function TwrpAtPrimaryKeys.ByConstraintName(
  const AConstraintName: WideString): IgsAtPrimaryKey;
begin
  Result := GetGdcOLEObject(GetAtPrimaryKeys.ByConstraintName(AConstraintName)) as IgsAtPrimaryKey;
end;

procedure TwrpAtPrimaryKeys.Delete(Index: Integer);
begin
  GetAtPrimaryKeys.Delete(Index);
end;

function TwrpAtPrimaryKeys.Get_Count: Integer;
begin
  Result := GetAtPrimaryKeys.Count;
end;

function TwrpAtPrimaryKeys.Get_Items(Index: Integer): IgsAtPrimaryKey;
begin
  Result := GetGdcOLEObject(GetAtPrimaryKeys.Items[Index]) as IgsAtPrimaryKey
end;

function TwrpAtPrimaryKeys.GetAtPrimaryKeys: TAtPrimaryKeys;
begin
  Result := GetObject as TAtPrimaryKeys;
end;

function TwrpAtPrimaryKeys.IndexOf(const AnObject: IgsObject): Integer;
begin
  Result := GetAtPrimaryKeys.IndexOf(InterfaceToObject(AnObject))
end;

{ TwrpAtPrimaryKey }

function TwrpAtPrimaryKey.Get_ConstraintFields: IgsAtRelationFields;
begin
  Result := GetGdcOLEObject(GetAtPrimaryKey.ConstraintFields) as IgsAtRelationFields;
end;

function TwrpAtPrimaryKey.Get_ConstraintName: WideString;
begin
  Result :=  GetAtPrimaryKey.ConstraintName;
end;

function TwrpAtPrimaryKey.Get_IndexName: WideString;
begin
  Result :=  GetAtPrimaryKey.IndexName;
end;

function TwrpAtPrimaryKey.Get_IsDropped: WordBool;
begin
  Result :=  GetAtPrimaryKey.IsDropped;
end;

function TwrpAtPrimaryKey.Get_Relation: IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtPrimaryKey.Relation) as IgsAtRelation
end;

function TwrpAtPrimaryKey.GetAtPrimaryKey: TAtPrimaryKey;
begin
  Result := GetObject as TAtPrimaryKey;
end;

procedure TwrpAtPrimaryKey.RefreshData;
begin
  GetAtPrimaryKey.RefreshData;
end;

procedure TwrpAtPrimaryKey.RefreshData2(const IBSQL: IgsIBSQL);
begin
  GetAtPrimaryKey.RefreshData(InterfaceToObject(IBSQL) as TIBSQL);
end;

procedure TwrpAtPrimaryKey.RefreshData3(const Database: IgsIBDatabase;
  const Transaction: IgsIBTransaction);
begin
  GetAtPrimaryKey.RefreshData(InterfaceToObject(Database) as TIBDatabase,
    InterfaceToObject(Transaction) as TIBTransaction);
end;

{ TwrpAtForeignKeys }

function TwrpAtForeignKeys.Add(
  const atPrimaryKey: IgsAtForeignKey): Integer;
begin
  Result := GetAtForeignKeys.Add(InterfaceToObject(atPrimaryKey) as TatForeignKey)
end;

function TwrpAtForeignKeys.ByConstraintName(
  const AConstraintName: WideString): IgsAtForeignKey;
begin
  Result := GetGdcOLEObject(GetAtForeignKeys.ByConstraintName(AConstraintName)) as IgsAtForeignKey
end;

function TwrpAtForeignKeys.ByRelationAndReferencedRelation(
  const ARelationName: WideString;
  const AReferencedRelationName: WideString): IgsAtForeignKey;
begin
  Result := GetGdcOleObject(GetAtForeignKeys.ByRelationAndReferencedRelation(
    ARelationName, AReferencedRelationName)) as IgsAtForeignKey;
end;

procedure TwrpAtForeignKeys.ConstraintsByReferencedRelation(
  const RelationName: WideString; const List: IgsObjectList;
  ClearList: WordBool);
begin
  GetAtForeignKeys.ConstraintsByReferencedRelation(RelationName,
    InterfaceToObject(List) as TObjectList, ClearList);
end;

procedure TwrpAtForeignKeys.ConstraintsByRelation(
  const RelationName: WideString; const List: IgsObjectList);
begin
  GetAtForeignKeys.ConstraintsByRelation(RelationName,
    InterfaceToObject(List) as TObjectList);
end;

procedure TwrpAtForeignKeys.Delete(Index: Integer);
begin
  GetAtForeignKeys.Delete(Index);
end;

function TwrpAtForeignKeys.Get_Count: Integer;
begin
  Result := GetAtForeignKeys.Count;
end;

function TwrpAtForeignKeys.Get_Items(Index: Integer): IgsAtForeignKey;
begin
  Result := GetGdcOLEObject(GetAtForeignKeys.Items[Index]) as IgsAtForeignKey;
end;

function TwrpAtForeignKeys.GetAtForeignKeys: TAtForeignKeys;
begin
  Result := GetObject as TAtForeignKeys;
end;

function TwrpAtForeignKeys.IndexOf(const AnObject: IgsObject): Integer;
begin
  Result := GetAtForeignKeys.IndexOf(InterfaceToObject(AnObject))
end;

{ TwrpAtFields }

function TwrpAtFields.Add(const atField: IgsAtField): Integer;
begin
  Result := GetAtFields.Add(InterfaceToObject(atField) as TatField);
end;

function TwrpAtFields.ByFieldName(
  const AFieldName: WideString): IgsAtField;
begin
  Result := GetGdcOLEObject(GetAtFields.ByFieldName(AFieldName)) as IgsAtField;
end;

function TwrpAtFields.ByID(ID: Integer): IgsAtField;
begin
  Result := GetGdcOLEObject(GetAtFields.ByID(ID)) as IgsAtField;
end;

procedure TwrpAtFields.Delete(Index: Integer);
begin
  GetAtFields.Delete(Index);
end;

function TwrpAtFields.FindFirst(const FieldName: WideString): IgsAtField;
begin
  Result := GetGdcOLEObject(GetAtFields.FindFirst(FieldName)) as IgsAtField;
end;

function TwrpAtFields.Get_Count: Integer;
begin
  Result := GetAtFields.Count
end;

function TwrpAtFields.Get_Items(Index: Integer): IgsAtField;
begin
  Result := GetGdcOLEObject(GetAtFields.Items[Index]) as IgsAtField;
end;

function TwrpAtFields.GetAtFields: TAtFields;
begin
  Result := GetObject as TAtFields;
end;

function TwrpAtFields.IndexOf(const AnObject: IgsObject): Integer;
begin
  Result := GetAtFields.IndexOf(InterfaceToObject(AnObject))
end;

procedure TwrpAtFields.RefreshData;
begin
  GetAtFields.RefreshData;
end;

procedure TwrpAtFields.RefreshData3(const Database: IgsIBDatabase;
  const Transaction: IgsIBTransaction);
begin
  GetAtFields.RefreshData(InterfaceToObject(Database) as TIBDatabase,
    InterfaceToObject(Transaction) as TIBTransaction)
end;

{ TwrpAtRelations }

function TwrpAtRelations.Add(const atPrimaryKey: IgsAtRelation): Integer;
begin
  Result := GetAtRelations.Add(InterfaceToObject(atPrimaryKey) as TatRelation);
end;

function TwrpAtRelations.ByID(ID: Integer): IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelations.ByID(ID)) as IgsAtRelation;
end;

function TwrpAtRelations.ByRelationName(
  const RelationName: WideString): IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelations.ByRelationName(RelationName)) as IgsAtRelation;
end;

procedure TwrpAtRelations.Delete(Index: Integer);
begin
  GetAtRelations.Delete(Index);
end;

function TwrpAtRelations.FindFirst(const FieldName: WideString): IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelations.FindFirst(FieldName)) as IgsAtRelation;
end;

function TwrpAtRelations.Get_Count: Integer;
begin
  Result := GetAtRelations.Count;
end;

function TwrpAtRelations.Get_Items(Index: Integer): IgsAtRelation;
begin
  Result := GetGdcOLEObject(GetAtRelations.Items[Index] ) as IgsAtRelation
end;

function TwrpAtRelations.GetAtRelations: TAtRelations;
begin
  Result := GetObject as TatRelations;
end;

function TwrpAtRelations.IndexOf(const AnObject: IgsObject): Integer;
begin
  Result := GetAtRelations.IndexOf( InterfaceToObject(AnObject))

end;

procedure TwrpAtRelations.NotifyUpdateObject(
  const ARelationName: WideString);
begin
  GetAtRelations.NotifyUpdateObject(ARelationName)
end;

procedure TwrpAtRelations.RefreshData(WithCommit: WordBool);
begin
  GetAtRelations.RefreshData(WithCommit)
end;

procedure TwrpAtRelations.RefreshData3(const Database: IgsIBDatabase;
  const Transaction: IgsIBTransaction; IsRefreshFields: WordBool);
begin
  GetAtRelations.RefreshData(InterfaceToObject(Database) as TIBDatabase,
    InterfaceToObject(Transaction) as TIBTransaction, IsRefreshFields)

end;

function TwrpAtRelations.Remove(const atRelation: IgsAtRelation): Integer;
begin
  Result := GetAtRelations.Remove(InterfaceToObject(atRelation) as TatRelation)
end;

{ TwrpDlgInvDocument }

function TwrpDlgInvDocument.Get_Document: IgsGdcInvDocument;
begin
  Result := GetGdcOLEObject(GetDlgInvDocument.Document) as IgsGdcInvDocument;
end;

function TwrpDlgInvDocument.Get_DocumentLine: IgsGdcInvDocumentLine;
begin
  Result := GetGdcOLEObject(GetDlgInvDocument.DocumentLine) as IgsGdcInvDocumentLine;
end;

function TwrpDlgInvDocument.Get_IsInsertMode: WordBool;
begin
  Result := GetDlgInvDocument.IsInsertMode;
end;

function TwrpDlgInvDocument.Get_SecondDocumentLine: IgsGdcInvDocumentLine;
begin
  Result := GetGdcOLEObject(GetDlgInvDocument.SecondDocumentLine) as IgsGdcInvDocumentLine;
end;

function TwrpDlgInvDocument.GetDlgInvDocument: TdlgInvDocument;
begin
  Result := GetObject as TdlgInvDocument;
end;

procedure TwrpDlgInvDocument.Set_IsInsertMode(Value: WordBool);
begin
  GetDlgInvDocument.IsInsertMode := Value;
end;

function TwrpDlgInvDocument.Get_IsAutoCommit: WordBool;
begin
  Result := GetDlgInvDocument.IsAutoCommit;
end;

procedure TwrpDlgInvDocument.Set_IsAutoCommit(Value: WordBool);
begin
  GetDlgInvDocument.IsAutoCommit := Value;
end;

{ TwrpBtnEdit }

procedure TwrpBtnEdit.AssignSize(const Source: IgsBtnEdit);
begin
  GetBtnEdit.AssignSize(InterfaceToObject(Source) as TBtnEdit);
end;

function TwrpBtnEdit.Get_BtnCaption: WideString;
begin
  Result := GetBtnEdit.BtnCaption;
end;

function TwrpBtnEdit.Get_BtnCursor: Integer;
begin
  Result := GetBtnEdit.Cursor;
end;

function TwrpBtnEdit.Get_BtnGlyph: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetBtnEdit.BtnGlyph) as IgsBitmap;
end;

function TwrpBtnEdit.Get_BtnWidth: Integer;
begin
  Result := GetBtnEdit.BtnWidth;
end;

function TwrpBtnEdit.GetBtnEdit: TBtnEdit;
begin
  Result := GetObject as TBtnEdit;
end;

procedure TwrpBtnEdit.Set_BtnCaption(const Value: WideString);
begin
  GetBtnEdit.BtnCaption := Value;
end;

procedure TwrpBtnEdit.Set_BtnCursor(Value: Integer);
begin
  GetBtnEdit.BtnCursor := Value;
end;

procedure TwrpBtnEdit.Set_BtnGlyph(const Value: IgsBitmap);
begin
  GetBtnEdit.BtnGlyph := InterfaceToObject(Value) as graphics.TBitmap;
end;

procedure TwrpBtnEdit.Set_BtnWidth(Value: Integer);
begin
  GetBtnEdit.BtnWidth := Value;
end;

{ TwrpGdcTaxResult }

function TwrpGdcTaxResult.Get_CorrectResult: OleVariant;
begin
  Result := GetGdcTaxResult.CorrectResult;
end;

function TwrpGdcTaxResult.GetGdcTaxResult: TgdcTaxResult;
begin
  Result := GetObject as TgdcTaxResult;
end;

{ TwrpFieldsCallList }

function TwrpFieldsCallList.AddFieldList(const Name: WideString): Integer;
begin
  Result := GetFieldsCallList.AddFieldList(Name);
end;

procedure TwrpFieldsCallList.ClearList;
begin
  GetFieldsCallList.ClearList;
end;

function TwrpFieldsCallList.Get_FieldList(Index: Integer): IgsStringList;
begin
  Result := GetGDCOleObject(GetFieldsCallList.FieldList[Index]) as IgsStringList;
end;

function TwrpFieldsCallList.GetFieldsCallList: TFieldsCallList;
begin
  Result := GetObject as TFieldsCallList;
end;

procedure TwrpFieldsCallList.RemoveFieldList(const Name: WideString);
begin
  GetFieldsCallList.RemoveFieldList(Name);
end;

function TwrpFieldsCallList.CheckField(const DatasetName,
  FieldName: WideString): WordBool;
begin
  Result := GetFieldsCallList.CheckField(DatasetName, FieldName);
end;

function TwrpFieldsCallList.IndexOf(const Name: WideString): Integer;
begin
  Result := GetFieldsCallList.IndexOf(Name);
end;

{ TwrpAtDatabase }

procedure TwrpAtDatabase.CancelMultiConnectionTransaction(All: WordBool);
begin
  if Assigned(atDatabase) then
    atDatabase.CancelMultiConnectionTransaction(All);
end;

procedure TwrpAtDatabase.CheckMultiConnectionTransaction;
begin
  if Assigned(atDatabase) then
    atDatabase.CheckMultiConnectionTransaction;
end;

function TwrpAtDatabase.FindRelationField(const ARelationName,
  ARelationFieldName: WideString): IgsAtRelationField;
begin
  Result := nil;
  if Assigned(atDatabase) then
    Result := GetGdcOLEObject(
      atDatabase.FindRelationField(ARelationName, ARelationFieldName)) as IgsAtRelationField;
end;

procedure TwrpAtDatabase.ForceLoadFromDatabase;
begin
  if Assigned(atDatabase) then
    atDatabase.ForceLoadFromDatabase;
end;

function TwrpAtDatabase.Get_Fields: IgsAtFields;
begin
  Result := nil;
  if Assigned(atDatabase) then
    Result := GetGdcOLEObject
      (atDatabase.Fields) as IgsAtFields;
end;

function TwrpAtDatabase.Get_ForeignKeys: IgsAtForeignKeys;
begin
  Result := nil;
  if Assigned(atDatabase) then
    Result := GetGdcOLEObject(
      atDatabase.ForeignKeys) as IgsAtForeignKeys;
end;

function TwrpAtDatabase.Get_InMultiConnection: WordBool;
begin
  Result := False;
  if Assigned(atDatabase) then
    Result := atDatabase.InMultiConnection;
end;

function TwrpAtDatabase.Get_Loaded: WordBool;
begin
  Result := False;
  if Assigned(atDatabase) then
    Result := atDatabase.Loaded;
end;

function TwrpAtDatabase.Get_Loading: WordBool;
begin
  if Assigned(atDatabase) then
    Result := atDatabase.Loading
end;

function TwrpAtDatabase.Get_MultiConnectionTransaction: Integer;
begin
  if Assigned(atDatabase) then
    Result := atDatabase.MultiConnectionTransaction;
end;

function TwrpAtDatabase.Get_PrimaryKeys: IgsAtPrimaryKeys;
begin
  Result := nil;
  if Assigned(atDatabase) then
    Result := GetGdcOLEObject(
      atDatabase.PrimaryKeys) as IgsAtPrimaryKeys;

end;

function TwrpAtDatabase.Get_ReadOnly: WordBool;
begin
  if Assigned(atDatabase) then
    Result := atDatabase.ReadOnly;
end;

function TwrpAtDatabase.Get_Relations: IgsAtRelations;
begin
  Result := nil;
  if Assigned(atDatabase) then
    Result :=
      GetGdcOLEObject(atDatabase.Relations) as IgsAtRelations;
end;

procedure TwrpAtDatabase.IncrementGarbageCount;
begin
  if Assigned(atDatabase) then
    atDatabase.IncrementGarbageCount;
end;

procedure TwrpAtDatabase.NotifyMultiConnectionTransaction;
begin
  if Assigned(atDatabase) then
    atDatabase.NotifyMultiConnectionTransaction;
end;

procedure TwrpAtDatabase.ProceedLoading(Force: WordBool);
begin
  if Assigned(atDatabase) then
    atDatabase.ProceedLoading(Force);
end;

function TwrpAtDatabase.StartMultiConnectionTransaction: WordBool;
begin
  if Assigned(atDatabase) then
    Result := atDatabase.StartMultiConnectionTransaction;
end;

procedure TwrpAtDatabase.SyncIndicesAndTriggers(
  const ATransaction: IgsIBTransaction);
begin
  if Assigned(atDatabase) then
    atDatabase.SyncIndicesAndTriggers(InterfaceToObject(ATransaction) as TIBTransaction);
end;

{ TwrpgsComboBoxAttrSet }

procedure TwrpgsComboBoxAttrSet.DropDown;
begin
  TCrackgsComboBoxAttrSet(GetComboBoxAttrSet).DropDown;
end;

function TwrpgsComboBoxAttrSet.GetComboBoxAttrSet: TgsComboBoxAttrSet;
begin
  Result := GetObject as TgsComboBoxAttrSet;
end;

function TwrpgsComboBoxAttrSet.Get_Condition: WideString;
begin
  Result := GetComboBoxAttrSet.Condition;
end;

function TwrpgsComboBoxAttrSet.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetComboBoxAttrSet.Database) as IgsIBDatabase;
end;

function TwrpgsComboBoxAttrSet.Get_DialogType: WordBool;
begin
  Result := GetComboBoxAttrSet.DialogType;
end;

function TwrpgsComboBoxAttrSet.Get_FieldName: WideString;
begin
  Result := GetComboBoxAttrSet.FieldName;
end;

function TwrpgsComboBoxAttrSet.Get_PrimaryName: WideString;
begin
  Result := GetComboBoxAttrSet.PrimaryName;
end;

function TwrpgsComboBoxAttrSet.Get_TableName: WideString;
begin
  Result := GetComboBoxAttrSet.TableName;
end;

function TwrpgsComboBoxAttrSet.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetComboBoxAttrSet.Transaction) as IgsIBTransaction;
end;

function TwrpgsComboBoxAttrSet.Get_SortOrder: TgsgsSortOrder;
begin
  Result := TgsgsSortOrder(GetComboBoxAttrSet.SortOrder);
end;

function TwrpgsComboBoxAttrSet.Get_SortField: WideString;
begin
  Result := GetComboBoxAttrSet.SortField;
end;

function TwrpgsComboBoxAttrSet.Get_ValueID: IgsStrings;
begin
  Result := GetGdcOLEObject(GetComboBoxAttrSet.ValueID) as IgsStrings;
end;

procedure TwrpgsComboBoxAttrSet.Set_Condition(const Value: WideString);
begin
  GetComboBoxAttrSet.Condition := Value;
end;

procedure TwrpgsComboBoxAttrSet.Set_Database(const Value: IgsIBDatabase);
begin
  GetComboBoxAttrSet.Database := InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpgsComboBoxAttrSet.Set_DialogType(Value: WordBool);
begin
  GetComboBoxAttrSet.DialogType := Value;
end;

procedure TwrpgsComboBoxAttrSet.Set_FieldName(const Value: WideString);
begin
  GetComboBoxAttrSet.FieldName := Value;
end;

procedure TwrpgsComboBoxAttrSet.Set_PrimaryName(const Value: WideString);
begin
  GetComboBoxAttrSet.PrimaryName := Value;
end;
                
procedure TwrpgsComboBoxAttrSet.Set_TableName(const Value: WideString);
begin
  GetComboBoxAttrSet.TableName := Value;
end;

procedure TwrpgsComboBoxAttrSet.Set_Transaction(
  const Value: IgsIBTransaction);
begin
  GetComboBoxAttrSet.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpgsComboBoxAttrSet.ValueIDChange;
begin
  GetComboBoxAttrSet.ValueIDChange(GetComboBoxAttrSet);
end;

procedure TwrpgsComboBoxAttrSet.Set_SortOrder(Value: TgsgsSortOrder);
begin
  GetComboBoxAttrSet.SortOrder := TgsComboBoxSortOrder(Value);
end;

procedure TwrpgsComboBoxAttrSet.Set_SortField(const Value: WideString);
begin
  GetComboBoxAttrSet.SortField := Value;
end;

{ TwrpGdcSetting }

procedure TwrpGdcSetting.ActivateSetting(const KeyAr: IgsStrings;
  const BL: IgsBookmarkList; AnModalSQLProcess: WordBool);
begin
  GetGdcSetting.ActivateSetting(IgsStringsToTStrings(KeyAr),
    InterfaceToObject(BL) as TBookmarkList, AnModalSQLProcess);
end;

procedure TwrpGdcSetting.ChooseMainSetting;
begin
  GetGdcSetting.ChooseMainSetting;
end;

procedure TwrpGdcSetting.DeactivateSetting;
begin
  GetGdcSetting.DeactivateSetting;
end;

function TwrpGdcSetting.GetGdcSetting: TGdcSetting;
begin
  Result := GetObject as TgdcSetting;
end;

procedure TwrpGdcSetting.MakeOrder;
begin
  GetGdcSetting.MakeOrder;
end;

procedure TwrpGdcSetting.ReActivateSetting(const BL: IgsBookmarkList);
begin
  GetGdcSetting.ReActivateSetting(InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGdcSetting.SaveSettingToBlob(SettingFormat: Word);
var
  StreamType: TgsStreamType;
begin
  StreamType := TgsStreamType(SettingFormat);
  if (StreamType >= Low(TgsStreamType)) and (StreamType <= High(TgsStreamType)) then
    GetGdcSetting.SaveSettingToBlob(StreamType)
  else
    raise Exception.Create(Format('SaveSettingToBlob: Передан неизвестный тип потока (%d)', [SettingFormat]));
end;

function  TwrpGdcSetting.Get_Silent: WordBool;
begin
  Result := GetGdcSetting.Silent;
end;

procedure TwrpGdcSetting.Set_Silent(Value: WordBool);
begin
  GetGdcSetting.Silent := Value;
end;

function TwrpGdcSetting.Get_ActivateErrorDescription: WideString;
begin
  Result := GetGdcSetting.ActivateErrorDescription;
end;

procedure TwrpGdcSetting.Set_ActivateErrorDescription(
  const Value: WideString);
begin
//  GetGdcSetting.ActivateErrorDescription := Value;
end;

procedure TwrpGdcSetting.UpdateActivateError;
begin
  GetGdcSetting.UpdateActivateError;
end;

procedure TwrpGdcSetting.AddToSetting(FromStorage: WordBool; const BranchName: WideString; 
                           const ValueName: WideString; const AnObject: IgsGDCBase; 
                           const BL: IgsBookmarkList);
begin
  at_AddToSetting.AddToSetting(FromStorage, BranchName, ValueName,
    InterfaceToObject(AnObject) as TgdcBase, InterfaceToObject(BL) as TBookmarkList);
end;

{ TwrpGdcSettingPos }

procedure TwrpGdcSettingPos.AddPos(const AnObject: IgsGDCBase;
  WithDetail: WordBool);
begin
  GetGdcSettingPos.AddPos(InterfaceToObject(AnObject) as TgdcBase, WithDetail)
end;

procedure TwrpGdcSettingPos.ChooseNewItem;
begin
  GetGdcSettingPos.ChooseNewItem;
end;

function TwrpGdcSettingPos.GetGdcSettingPos: TGdcSettingPos;
begin
  Result := GetObject as TgdcSettingPos;
end;

procedure TwrpGdcSettingPos.SetNeedModify(Value: WordBool;
  const BL: IgsBookmarkList);
begin
  GetGdcSettingPos.SetNeedModify(Value, InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGdcSettingPos.SetNeedModifyDefault;
begin
  GetGdcSettingPos.SetNeedModifyDefault;
end;

procedure TwrpGdcSettingPos.SetWithDetail(Value: WordBool;
  const BL: IgsBookmarkList);
begin
  GetGdcSettingPos.SetWithDetail(Value, InterfaceToObject(BL) as TBookmarkList);
end;

procedure TwrpGdcSettingPos.Valid(DoAutoDelete: WordBool);
begin
  GetGdcSettingPos.Valid(DoAutoDelete);
end;

{ TwrpGdcSettingStorage }

procedure TwrpGdcSettingStorage.AddPos(const ABranchName,
  AValueName: WideString);
begin
  GetGdcSettingStorage.AddPos(ABranchName, AValueName)
end;

function TwrpGdcSettingStorage.GetGdcSettingStorage: TGdcSettingStorage;
begin
  Result := GetObject as TgdcSettingStorage;
end;

procedure TwrpGdcSettingStorage.Valid;
begin
  GetGdcSettingStorage.Valid;
end;

{ TwrpGdc_dlgHGR }

function TwrpGdc_dlgHGR.GetGdc_dlgHGR: Tgdc_dlgHGR;
begin
  Result := GetObject as Tgdc_dlgHGR;
end;

function TwrpGdc_dlgHGR.Get_gdcDetailObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdc_dlgHGR.gdcDetailObject) as IgsGDCBase;
end;

procedure TwrpGdc_dlgHGR.Set_gdcDetailObject(const Value: IgsGDCBase);
begin
  GetGdc_dlgHGR.gdcDetailObject := InterfaceToObject(Value) as TgdcBase;
end;


{ TwrpGdcAcctBaseEntryRegister }

function TwrpGdcAcctBaseEntryRegister.Get_Description: WideString;
begin
  Result := GetGdcAcctBaseEntryRegister.Description;
end;

function TwrpGdcAcctBaseEntryRegister.Get_Document: IgsGDCDocument;
begin
  Result := GetGdcOleObject(GetGdcAcctBaseEntryRegister.Document) as IgsGDCDocument;
end;

function TwrpGdcAcctBaseEntryRegister.Get_gdcQuantity: IgsGdcAcctQuantity;
begin
  Result := GetGdcOleObject(GetGdcAcctBaseEntryRegister.gdcQuantity) as IgsGdcAcctQuantity;
end;

function TwrpGdcAcctBaseEntryRegister.Get_RecordKey: Integer;
begin
  Result := GetGdcAcctBaseEntryRegister.RecordKey;
end;

function TwrpGdcAcctBaseEntryRegister.GetGdcAcctBaseEntryRegister: TGdcAcctBaseEntryRegister;
begin
  Result := GetObject as TGdcAcctBaseEntryRegister;
end;

procedure TwrpGdcAcctBaseEntryRegister.Set_Description(
  const Value: WideString);
begin
  GetGdcAcctBaseEntryRegister.Description := Value;
end;

procedure TwrpGdcAcctBaseEntryRegister.Set_Document(
  const Value: IgsGDCDocument);
begin
  GetGdcAcctBaseEntryRegister.Document := InterfaceToObject(Value) as TgdcDocument;
end;

{ TwrpGdcAcctViewEntryRegister }

function TwrpGdcAcctViewEntryRegister.Get_EntryGroup: TgsEntryGroup;
begin
  Result := TgsEntryGroup(GetGdcAcctViewEntryRegister.EntryGroup);
end;

function TwrpGdcAcctViewEntryRegister.GetGdcAcctViewEntryRegister: TGdcAcctViewEntryRegister;
begin
  Result := GetObject as TGdcAcctViewEntryRegister;
end;

procedure TwrpGdcAcctViewEntryRegister.Set_EntryGroup(
  Value: TgsEntryGroup);
begin
  GetGdcAcctViewEntryRegister.EntryGroup := TEntryGroup(Value);
end;


{$IFDEF MODEM}

procedure TwrpGsModem.Call(const AnPhone: WideString);
begin
  GetGsModem.Call(AnPhone);
end;

procedure TwrpGsModem.Cancel;
begin
  GetGsModem.Cancel;
end;

function TwrpGsModem.ChooseModem: WordBool;
begin
  Result := GetGsModem.ChooseModem;
end;

function TwrpGsModem.Get_AnswerOnRing: Shortint;
begin
  Result := GetGsModem.AnswerOnRing;
end;

function TwrpGsModem.Get_AutoReceive: WordBool;
begin
  Result := GetgsModem.AutoReceive;
end;

function TwrpGsModem.Get_Baud: Longint;
begin
  Result := GetgsModem.Baud;
end;

function TwrpGsModem.Get_DestinationDirectory: WideString;
begin
  Result := GetgsModem.DestinationDirectory;
end;

function TwrpGsModem.Get_Dialing: WordBool;
begin
  Result := GetgsModem.Dialing;
end;

function TwrpGsModem.Get_MaxAttempts: Word;
begin
  Result := GetgsModem.MaxAttempts;
end;

function TwrpGsModem.Get_ProtocolStatusCaption: WideString;
begin
  Result := GetgsModem.ProtocolStatusCaption;
end;

function TwrpGsModem.Get_RetryWait: Word;
begin
  Result := GetgsModem.RetryWait;
end;

function TwrpGsModem.Get_SelectedModem: WideString;
begin
  Result := GetgsModem.SelectedModem;
end;

function TwrpGsModem.Get_TapiState: Integer;
begin
  Result := Integer(GetgsModem.TapiState);
end;

function TwrpGsModem.Get_TimeOut: Integer;
begin
  Result := GetgsModem.TimeOut;
end;

function TwrpGsModem.GetGsModem: TgsModem;
begin
  Result := GetObject as TgsModem;
end;

procedure TwrpGsModem.Send(const AFileName: WideString);
begin
  GetgsModem.Send(AFileName)
end;

procedure TwrpGsModem.Set_AnswerOnRing(Value: Shortint);
begin
  GetgsModem.AnswerOnRing := Value;
end;

procedure TwrpGsModem.Set_AutoReceive(Value: WordBool);
begin
  GetgsModem.AutoReceive := Value;
end;

procedure TwrpGsModem.Set_Baud(Value: Integer);
begin
  GetgsModem.Baud := Value;
end;

procedure TwrpGsModem.Set_DestinationDirectory(const Value: WideString);
begin
  GetgsModem.DestinationDirectory := Value;
end;

procedure TwrpGsModem.Set_MaxAttempts(Value: Word);
begin
  GetgsModem.MaxAttempts := Value;
end;

procedure TwrpGsModem.Set_ProtocolStatusCaption(const Value: WideString);
begin
  GetgsModem.ProtocolStatusCaption := Value;
end;

procedure TwrpGsModem.Set_RetryWait(Value: Word);
begin
  GetgsModem.RetryWait := Value;
end;

procedure TwrpGsModem.Set_SelectedModem(const Value: WideString);
begin
  GetgsModem.SelectedModem := Value;
end;

procedure TwrpGsModem.Set_TimeOut(Value: Integer);
begin
  GetgsModem.TimeOut := Value;
end;

procedure TwrpGsModem.WaitFile;
begin
  GetgsModem.WaitFile;
end;
{$ENDIF}


{ TwrpGdcBaseFile }

function TwrpGdcBaseFile.CheckFileName: WordBool;
begin
  Result := GetGdcBaseFile.CheckFileName;
end;

function TwrpGdcBaseFile.Find_(const AFileName: WideString): Integer;
begin
  Result := getGdcBaseFile.Find(AFileName);
end;

function TwrpGdcBaseFile.Get_FullPath: WideString;
begin
  Result := GetGdcBaseFile.FullPath;
end;

function TwrpGdcBaseFile.Get_Length: Integer;
begin
  Result := GetGdcBaseFile.Length;
end;

function TwrpGdcBaseFile.Get_RootDirectory: WideString;
begin
  Result := GetGdcBaseFile.RootDirectory;
end;

function TwrpGdcBaseFile.GetGdcBaseFile: TgdcBaseFile;
begin
  Result := GetObject as TgdcBaseFile;
end;

function TwrpGdcBaseFile.GetPathToFolder(AFolderID: Integer): WideString;
begin
  Result := GetGdcBaseFile.GetPathToFolder(AFolderID);
end;

procedure TwrpGdcBaseFile.Set_RootDirectory(const Value: WideString);
begin
  GetGdcBaseFile.RootDirectory := Value;
end;

function TwrpGdcBaseFile.SynchronizeByName(const AFileName: WideString;
  ChooseLocation: WordBool; Action: TgsflAction): WordBool;
begin
  GetGdcBaseFile.Synchronize(AFileName, ChooseLocation, TflAction(Integer(Action)));
end;

function TwrpGdcBaseFile.Synchronize(AnID: Integer;
  ChooseLocation: WordBool; Action: TgsflAction): WordBool;
begin
  GetGdcBaseFile.Synchronize(AnID, ChooseLocation, TflAction(Integer(Action)));
end;

{ TwrpGdcFile }

function TwrpGdcFile.GetGdcFile: TgdcFile;
begin
  Result := GetObject as TgdcFile;
end;

function TwrpGdcFile.GetViewFilePath: WideString;
begin
  Result := GetGdcFile.GetViewFilePath;
end;

procedure TwrpGdcFile.LoadDataFromFile(const AFileName: WideString);
begin
  GetGdcFile.LoadDataFromFile(AFileName);
end;

procedure TwrpGdcFile.LoadDataFromStream(const Stream: IgsStream);
begin
  GetGdcFile.LoadDataFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpGdcFile.SaveDataToFile(const AFileName: WideString);
begin
  GetGdcFile.SaveDataToFile(AFileName);
end;

procedure TwrpGdcFile.SaveDataToStream(const Stream: IgsStream);
begin
  GetGdcFile.SaveDataToStream(InterfaceToObject(Stream) as TStream);
end;

function TwrpGdcFile.TheSame(const AFileName: WideString): WordBool;
begin
  Result := GetGdcFile.TheSame(AFileName);
end;

procedure TwrpGdcFile.ViewFile(NeedExit, NeedSave: WordBool);
begin
  GetGdcFile.ViewFile(NeedExit, NeedSave);
end;

{ TwrpGdcFileFolder }

function TwrpGdcFileFolder.FolderSize: Integer;
begin
  Result := GetGdcFileFolder.FolderSize;
end;

function TwrpGdcFileFolder.GetGdcFileFolder: TgdcFileFolder;
begin
  Result := GetObject as TgdcFileFolder;
end;

{ TwrpGdEnumComboBox }

function TwrpGdEnumComboBox.Get_CurrentValue: WideString;
begin
  Result := GetGdEnumComboBox.CurrentValue;
end;

function TwrpGdEnumComboBox.Get_DataField: WideString;
begin
  Result := GetGdEnumComboBox.DataField;
end;

function TwrpGdEnumComboBox.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetGdEnumComboBox.DataSource) as IgsDataSource;
end;

function TwrpGdEnumComboBox.Get_Field: IgsField;
begin
  Result := GetGdcOLEObject(GetGdEnumComboBox.Field) as IgsField;
end;

function TwrpGdEnumComboBox.GetGdEnumComboBox: TGdEnumComboBox;
begin
  Result := GetObject as TGdEnumComboBox;
end;

procedure TwrpGdEnumComboBox.Set_DataField(const Value: WideString);
begin
  GetGdEnumComboBox.DataField := Value;
end;

procedure TwrpGdEnumComboBox.Set_DataSource(const Value: IgsDataSource);
begin
  GetGdEnumComboBox.DataSource := InterfaceToObject(Value) as TDataSource;
end;

{ TwrpGsColumn }

function TwrpGsColumn.Filterable: WordBool;
begin
  Result := GetGsColumn.Filterable;
end;

function TwrpGsColumn.Get_DisplayFormat: WideString;
begin
  Result := GetGsColumn.DisplayFormat;
end;

function TwrpGsColumn.Get_Filtered: WordBool;
begin
  Result := GetGsColumn.Filtered;
end;

function TwrpGsColumn.Get_FilteredCache: IgsStringList;
begin
  Result := GetGdcOLEObject(GetGsColumn.FilteredCache) as IgsStringList;
end;

function TwrpGsColumn.Get_FilteredValue: WideString;
begin
  Result := GetGsColumn.FilteredValue;
end;

function TwrpGsColumn.Get_Grid_: IgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetGsColumn.Grid) as IgsCustomDBGrid;
end;

function TwrpGsColumn.Get_Max: Integer;
begin
  Result := GetGsColumn.Max;
end;

function TwrpGsColumn.Get_TotalType: TgsGsTotalType;
begin
  Result := TgsGsTotalType(GetGsColumn.TotalType);
end;

function TwrpGsColumn.GetGsColumn: TgsColumn;
begin
  Result := GetObject as TgsColumn;
end;

function TwrpGsColumn.IsFilterableField(const F: IgsField): WordBool;
begin
  Result := GetGsColumn.IsFilterableField(InterfaceToObject(F) as TField);
end;

procedure TwrpGsColumn.Set_DisplayFormat(const Value: WideString);
begin
  GetGsColumn.DisplayFormat := Value;
end;

procedure TwrpGsColumn.Set_Filtered(Value: WordBool);
begin
  GetGsColumn.Filtered := Value;
end;

procedure TwrpGsColumn.Set_FilteredCache(const Value: IgsStringList);
begin
  GetGsColumn.FilteredCache := InterfaceToObject(Value) as TStringList;
end;

procedure TwrpGsColumn.Set_FilteredValue(const Value: WideString);
begin
  GetGsColumn.FilteredValue := Value;
end;

procedure TwrpGsColumn.Set_Max(Value: Integer);
begin
  GetGsColumn.Max := Value;
end;

procedure TwrpGsColumn.Set_TotalType(Value: TgsGsTotalType);
begin
  GetGsColumn.TotalType := TgsTotalType(Value);
end;

function TwrpGsColumn.Get_Frozen: WordBool;
begin
  Result := GetGsColumn.Frozen;
end;

procedure TwrpGsColumn.Set_Frozen(Value: WordBool);
begin
  GetGsColumn.Frozen := Value;
end;

{ TwrpGsColumns }

function TwrpGsColumns.Add_: IgsGsColumn;
begin
  Result := GetGdcOLEObject(GetGsColumns.Add) as IgsGsColumn;
end;

function TwrpGsColumns.Get_Grid_: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetGsColumns.Grid) as IgsgsCustomDBGrid;
end;

function TwrpGsColumns.Get_IsSetupMode: WordBool;
begin
  Result := GetGsColumns.IsSetupMode;
end;

function TwrpGsColumns.Get_Items_(Index: Integer): IgsGsColumn;
begin
  Result := GetGdcOLEObject(GetGsColumns.Items[Index]) as IgsGsColumn;
end;

function TwrpGsColumns.GetGsColumns: TgsColumns;
begin
  Result := GetObject as TgsColumns;
end;

procedure TwrpGsColumns.Set_Items_(Index: Integer;
  const Value: IgsGsColumn);
begin
  GetGsColumns.Items[Index] := InterfaceToObject(value) as TgsColumn;
end;

{ TwrpAtIgnore }

function TwrpAtIgnore.GetAtIgnore: TAtIgnore;
begin
  Result := GetObject As TAtIgnore;
end;

function TwrpAtIgnore.Get_AliasName: WideString;
begin
  Result := GetAtIgnore.AliasName;
end;

function TwrpAtIgnore.Get_IgnoryType: TgsAtIgnoryType;
begin
  Result := TgsAtIgnoryType(GetAtIgnore.IgnoryType);
end;

function TwrpAtIgnore.Get_Link: IgsComponent;
begin
  Result := GetGdcOLEObject(GetAtIgnore.Link) as IgsComponent;
end;

function TwrpAtIgnore.Get_RelationName: WideString;
begin
  Result := GetAtIgnore.RelationName;
end;

procedure TwrpAtIgnore.Set_AliasName(const Value: WideString);
begin
  GetAtIgnore.AliasName := Value;
end;

procedure TwrpAtIgnore.Set_IgnoryType(Value: TgsAtIgnoryType);
begin
  GetAtIgnore.IgnoryType := TatIgnoryType(Value);
end;

procedure TwrpAtIgnore.Set_Link(const Value: IgsComponent);
begin
  GetAtIgnore.Link := InterfaceToObject(Value) as TComponent;
end;

procedure TwrpAtIgnore.Set_RelationName(const Value: WideString);
begin
  GetAtIgnore.RelationName := Value;
end;

{ TwrpAtSQLSetup }

procedure TwrpAtSQLSetup.AddLink(const AComponent: IgsComponent);
begin
  GetAtSQLSetup.AddLink(InterfaceToObject(AComponent) as TComponent);
end;

function TwrpAtSQLSetup.Get_Ignores: IgsAtIgnores;
begin
  Result := GetGdcOLEObject(GetAtSQLSetup.Ignores) as IgsAtIgnores;
end;

function TwrpAtSQLSetup.Get_State: TgsSQLSetupState;
begin
  Result := TgsSQLSetupState(GetAtSQLSetup.State);
end;

function TwrpAtSQLSetup.GetAtSQLSetup: TAtSQLSetup;
begin
  Result := GetObject As TAtSQLSetup;
end;

procedure TwrpAtSQLSetup.Prepare;
begin
  GetAtSQLSetup.Prepare;
end;

function TwrpAtSQLSetup.PrepareSQL(const Text,
  ObjectClassName: WideString): WideString;
begin
  Result := GetAtSQLSetup.PrepareSQL(Text, ObjectClassName);
end;

procedure TwrpAtSQLSetup.Set_Ignores(const Value: IgsAtIgnores);
begin
  GetAtSQLSetup.Ignores := InterfaceToObject(Value) as TAtIgnores;
end;


{ TwrpAtIgnores }

function TwrpAtIgnores.Add: IgsAtIgnore;
begin
  Result := GetGdcOLEObject(GetAtIgnores.Add) As IgsAtIgnore;
end;

function TwrpAtIgnores.Get_Items(Index: Integer): IgsAtIgnore;
begin
  Result := GetGdcOLEObject(GetAtIgnores.Items[Index]) as IgsAtIgnore;
end;

function TwrpAtIgnores.GetAtIgnores: TAtIgnores;
begin
  Result := GetObject as TAtIgnores;
end;

procedure TwrpAtIgnores.Set_Items(Index: Integer;
  const Value: IgsAtIgnore);
begin
  GetAtIgnores.Items[Index] := InterfaceToObject(Value) As TAtIgnore;
end;

{ TwrpGsRect }

function TwrpGsRect.GetGsRect: TgsRect;
begin
  Result := GetObject as TgsRect;
end;

function TwrpGsRect.Get_Bottom: Integer;
begin
  Result := GetGsRect.Bottom
end;

function TwrpGsRect.Get_Left: Integer;
begin
  Result := GetGsRect.Left
end;

function TwrpGsRect.Get_Right: Integer;
begin
  Result := GetGsRect.Right
end;

function TwrpGsRect.Get_Top: Integer;
begin
  Result := GetGsRect.Top
end;

procedure TwrpGsRect.Set_Bottom(Value: Integer);
begin
  GetGsRect.Bottom := Value;
end;

procedure TwrpGsRect.Set_Left(Value: Integer);
begin
  GetGsRect.Left := Value;
end;

procedure TwrpGsRect.Set_Right(Value: Integer);
begin
  GetGsRect.Right := Value;
end;

procedure TwrpGsRect.Set_Top(Value: Integer);
begin
  GetGsRect.Top := Value;
end;

{ TwrpGsPoint }

function TwrpGsPoint.Get_X: Integer;
begin
  Result := GetGsPoint.X
end;

function TwrpGsPoint.Get_Y: Integer;
begin
  Result := GetGsPoint.Y
end;

function TwrpGsPoint.GetGsPoint: TgsPoint;
begin
  Result := GetObject as TgsPoint;
end;

procedure TwrpGsPoint.Set_X(Value: Integer);
begin
  GetGsPoint.X := Value;
end;

procedure TwrpGsPoint.Set_Y(Value: Integer);
begin
  GetGsPoint.Y := Value;
end;

{ TwrpGdKeyDuplArray }

function TwrpGdKeyDuplArray.AddDupl(Value: Integer): Integer;
begin
  Result := GetGdKeyDuplArray.Add(Value);

end;

function TwrpGdKeyDuplArray.Get_Duplicates: TgsDuplicates;
begin
  Result := TgsDuplicates(GetGdKeyDuplArray.Duplicates);
end;

function TwrpGdKeyDuplArray.GetGdKeyDuplArray: TGdKeyDuplArray;
begin
  Result := GetObject as TGdKeyDuplArray;
end;

procedure TwrpGdKeyDuplArray.Set_Duplicates(Value: TgsDuplicates);
begin
  GetGdKeyDuplArray.Duplicates := TDuplicates(Value)
end;

class function TwrpGdKeyDuplArray.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyDuplArray), 'Invalide Delphi class');
  Result := TgdKeyDuplArray.Create;
end;

{ TwrpGdKeyObjectAssoc }

function TwrpGdKeyObjectAssoc.Get_ObjectByIndex(Index: Integer): IgsObject;
begin
  Result := GetGdcOLEObject(GetGdKeyObjectAssoc.ObjectByIndex[Index]) as IgsObject;
end;

function TwrpGdKeyObjectAssoc.Get_ObjectByKey(Key: Integer): IgsObject;
begin
  Result := GetGdcOLEObject(GetGdKeyObjectAssoc.ObjectByKey[Key]) as IgsObject;
end;

function TwrpGdKeyObjectAssoc.Get_OwnsObjects: WordBool;
begin
  Result := GetGdKeyObjectAssoc.OwnsObjects;
end;

function TwrpGdKeyObjectAssoc.GetGdKeyObjectAssoc: TGdKeyObjectAssoc;
begin
  Result := GetObject as TGdKeyObjectAssoc;
end;

function TwrpGdKeyObjectAssoc.Remove(Key: Integer): Integer;
begin
  Result := GetGdKeyObjectAssoc.Remove(Key);
end;

procedure TwrpGdKeyObjectAssoc.Set_ObjectByIndex(Index: Integer;
  const Value: IgsObject);
begin
  GetGdKeyObjectAssoc.ObjectByIndex[Index] := InterfaceToObject(Value) as TObject;
end;

procedure TwrpGdKeyObjectAssoc.Set_ObjectByKey(Key: Integer;
  const Value: IgsObject);
begin
  GetGdKeyObjectAssoc.ObjectByKey[Key] := InterfaceToObject(Value) as TObject;
end;

procedure TwrpGdKeyObjectAssoc.Set_OwnsObjects(Value: WordBool);
begin
  GetGdKeyObjectAssoc.OwnsObjects := Value;
end;

function TwrpGdKeyObjectAssoc.AddObject(AKey: Integer;
  const AnObject: IgsObject): Integer;
begin
  Result := GetGdKeyObjectAssoc.AddObject(AKey, InterfaceToObject(AnObject) as TObject);

end;

class function TwrpGdKeyObjectAssoc.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyObjectAssoc), 'Invalide Delphi class');

  if VarType(Params) = vtBoolean then
    Result := TgdKeyObjectAssoc.Create(Boolean(Params))
  else begin
    if (VariantIsArray(Params) and (VarType(Params[0]) = vtBoolean))  then
      Result := TgdKeyObjectAssoc.Create(Boolean(Params[0]))
    else
      Result := TgdKeyObjectAssoc.Create;
  end;
end;

{ TwrpGdKeyIntArrayAssoc }

function TwrpGdKeyIntArrayAssoc.Get_ValuesByIndex(
  Index: Integer): IgsGDKeyArray;
begin
  Result := GetGdcOLEObject(GetGdKeyIntArrayAssoc.ValuesByIndex[Index]) as IgsGDKeyArray;
end;

function TwrpGdKeyIntArrayAssoc.Get_ValuesByKey(
  Key: Integer): IgsGDKeyArray;
begin
  Result := GetGdcOLEObject(GetGdKeyIntArrayAssoc.ValuesByKey[Key]) as IgsGDKeyArray;
end;

function TwrpGdKeyIntArrayAssoc.GetGdKeyIntArrayAssoc: TGdKeyIntArrayAssoc;
begin
  Result := GetObject as TGdKeyIntArrayAssoc;
end;

class function TwrpGdKeyIntArrayAssoc.CreateObject(
  const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyIntArrayAssoc), 'Invalide Delphi class');
  Result := TgdKeyIntArrayAssoc.Create;
end;

{ TwrpGdKeyIntAndStrAssoc }

function TwrpGdKeyIntAndStrAssoc.Get_IntByIndex(Index: Integer): Integer;
begin
  Result := GetGdKeyIntAndStrAssoc.IntByIndex[Index];
end;

function TwrpGdKeyIntAndStrAssoc.Get_IntByKey(Key: Integer): Integer;
begin
  Result := GetGdKeyIntAndStrAssoc.IntByKey[Key];
end;

function TwrpGdKeyIntAndStrAssoc.Get_StrByIndex(
  Index: Integer): WideString;
begin
  Result := GetGdKeyIntAndStrAssoc.StrByIndex[Index];
end;

function TwrpGdKeyIntAndStrAssoc.Get_StrByKey(Key: Integer): WideString;
begin
  Result := GetGdKeyIntAndStrAssoc.StrByKey[Key];
end;

function TwrpGdKeyIntAndStrAssoc.GetGdKeyIntAndStrAssoc: TGdKeyIntAndStrAssoc;
begin
  Result := GetObject as TGdKeyIntAndStrAssoc;
end;

procedure TwrpGdKeyIntAndStrAssoc.Set_IntByIndex(Index, Value: Integer);
begin
  GetGdKeyIntAndStrAssoc.IntByIndex[Index] := Value;
end;

procedure TwrpGdKeyIntAndStrAssoc.Set_IntByKey(Key, Value: Integer);
begin
  GetGdKeyIntAndStrAssoc.IntByKey[Key] := Value;
end;

procedure TwrpGdKeyIntAndStrAssoc.Set_StrByIndex(Index: Integer;
  const Value: WideString);
begin
  GetGdKeyIntAndStrAssoc.StrByIndex[Index] := Value;
end;

procedure TwrpGdKeyIntAndStrAssoc.Set_StrByKey(Key: Integer;
  const Value: WideString);
begin
  GetGdKeyIntAndStrAssoc.StrByKey[Key] := Value;
end;

class function TwrpGdKeyIntAndStrAssoc.CreateObject(
  const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdKeyIntAndStrAssoc), 'Invalide Delphi class');
  Result := TgdKeyIntAndStrAssoc.Create;
end;

{ TwrpGdcInvBasePriceList }

function TwrpGdcInvBasePriceList.GetCurrencyKey(
  RelationFieldKey: Integer): Integer;
begin
  Result := (GetObject as TgdcInvBasePriceList).GetCurrencyKey(RelationFieldKey);
end;

{ TwrpGdcDocumentType }

function TwrpGdcDocumentType.GetGdcDocumentType: TgdcDocumentType;
begin
  Result := GetObject as TgdcDocumentType;
end;

function TwrpGdcDocumentType.Get_GetHeaderDocumentClass: WideString;
begin
  Result := GetGdcDocumentType.GetHeaderDocumentClass.ClassName;
end;

{ TwrpGdc_frmInvSelectedGoods }

function TwrpGdc_frmInvSelectedGoods.Get_AssignFieldsName: WideString;
begin
  Result := GetGdc_frmInvSelectedGoods.AssignFieldsName;
end;

function TwrpGdc_frmInvSelectedGoods.Get_EditedFieldsName: WideString;
begin
  Result := GetGdc_frmInvSelectedGoods.EditedFieldsName;
end;

function TwrpGdc_frmInvSelectedGoods.GetGdc_frmInvSelectedGoods: Tgdc_frmInvSelectedGoods;
begin
  Result := GetObject as Tgdc_frmInvSelectedGoods;
end;

procedure TwrpGdc_frmInvSelectedGoods.Set_AssignFieldsName(
  const Value: WideString);
begin
  GetGdc_frmInvSelectedGoods.AssignFieldsName := Value;
end;

procedure TwrpGdc_frmInvSelectedGoods.Set_EditedFieldsName(
  const Value: WideString);
begin
  GetGdc_frmInvSelectedGoods.EditedFieldsName := Value;
end;

{ TwrpTBControlItem }

function TwrpTBControlItem.Get_Control: IgsControl;
begin
  Result := GetGdcOLEObject(GetTBControlItem.Control) as IgsControl;
end;

function TwrpTBControlItem.Get_DontFreeControl: WordBool;
begin
  Result := GetTBControlItem.DontFreeControl;
end;

function TwrpTBControlItem.GetTBControlItem: TTBControlItem;
begin
  Result := GetObject as TTBControlItem;
end;

procedure TwrpTBControlItem.Set_Control(const Value: IgsControl);
begin
  GetTBControlItem.Control := InterfaceToObject(Value) as TControl;
end;

procedure TwrpTBControlItem.Set_DontFreeControl(Value: WordBool);
begin
  GetTBControlItem.DontFreeControl := Value;
end;

{ TwrpGdcInvMovementContactOption }

function TwrpGdcInvMovementContactOption.Get_ContactType: TGsGdcInvMovementContactType;
begin
  Result := TGsGdcInvMovementContactType(getGdcInvMovementContactOption.ContactType)
end;

function TwrpGdcInvMovementContactOption.Get_RelationName: WideString;
begin
  Result := getGdcInvMovementContactOption.RelationName
end;

function TwrpGdcInvMovementContactOption.Get_SourceFieldName: WideString;
begin
  Result := getGdcInvMovementContactOption.SourceFieldName
end;

function TwrpGdcInvMovementContactOption.Get_SubRelationName: WideString;
begin
  Result := getGdcInvMovementContactOption.SubRelationName
end;

function TwrpGdcInvMovementContactOption.Get_SubSourceFieldName: WideString;
begin
  Result := getGdcInvMovementContactOption.SubSourceFieldName
end;

function TwrpGdcInvMovementContactOption.GetGdcInvMovementContactOption: TGdcInvMovementContactOption;
begin
  Result := GetObject as TGdcInvMovementContactOption;
end;

{ TwrpxFoCal }

function TwrpxFoCal.Get_Expression: WideString;
begin
  Result := GetxFoCal.Expression;
end;

function TwrpxFoCal.Get_StrictVars: WordBool;
begin
  Result := GetxFoCal.StrictVars;
end;

function TwrpxFoCal.Get_Value: Double;
begin
  Result := GetxFoCal.Value;
end;

function TwrpxFoCal.Get_Variables: IgsStringList;
begin
  Result := GetGdcOLEObject(GetxFoCal.Variables) as IgsStringList;
end;

function TwrpxFoCal.GetxFoCal: TxFoCal;
begin
  Result := GetObject as TxFoCal;
end;

procedure TwrpxFoCal.Set_Expression(const Value: WideString);
begin
  GetxFoCal.Expression := Value;
end;

procedure TwrpxFoCal.Set_StrictVars(Value: WordBool);
begin
  GetxFoCal.StrictVars := Value;
end;

function TwrpxFoCal.Get_RequiredVariables: IgsStringList;
begin
  Result := GetGdcOLEObject(GetxFoCal.RequiredVariables) as IgsStringList;
end;


procedure TwrpxFoCal.Set_Value(Value: Double);
begin
  GetxFoCal.Value := Value;
end;

procedure TwrpxFoCal.Set_Variables(const Value: IgsStringList);
begin
  GetxFoCal.Variables := InterfaceToObject(Value) as TStringList;
end;

procedure TwrpxFoCal.AssignVariable(const AName: WideString;
  AValue: Double);
begin
  GetxFoCal.AssignVariable(AName, AValue);
end;

procedure TwrpxFoCal.AssignVariables(const AVariables: IgsStringList);
begin
  GetxFoCal.AssignVariables(InterfaceToObject(AVariables) as TStringList);
end;

procedure TwrpxFoCal.ClearVariablesList;
begin
  GetxFoCal.ClearVariablesList;
end;

procedure TwrpxFoCal.DeleteVariable(const AName: WideString);
begin
  GetxFoCal.DeleteVariable(AName);
end;

{ TwrpGdc_dlgSelectDocument }

function TwrpGdc_dlgSelectDocument.Get_dlgSelectDocument: TdlgSelectDocument;
begin
  Result := GetObject as TdlgSelectDocument;
end;

function TwrpGdc_dlgSelectDocument.Get_SelectedID: integer;
begin
  Result := Get_dlgSelectDocument.SelectedID;
end;

{ TwrpGdc_frmMD2H }

function TwrpGdc_frmMD2H.Get_gdcSubDetailObject: IgsGDCBase;
begin
  Result := GetGdcOLEObject(GetGdc_frmMD2H.gdcSubDetailObject) as IgsGDCBase;
end;

function TwrpGdc_frmMD2H.GetGdc_frmMD2H: Tgdc_frmMD2H;
begin
  Result := GetObject as Tgdc_frmMD2H;
end;

procedure TwrpGdc_frmMD2H.Set_gdcSubDetailObject(const Value: IgsGDCBase);
begin
  GetGdc_frmMD2H.gdcSubDetailObject := InterfaceToObject(Value) as TgdcBase;
end;

{ TwrpGDCLink }

procedure TwrpGDCLink.AddLinkedObjectDialog;
begin
  GetGdcLink.AddLinkedObjectDialog;
end;

function TwrpGDCLink.GetGDCLink: TgdcLink;
begin
  Result := GetObject as TgdcLink;
end;

function TwrpGDCLink.Get_ObjectKey: Integer;
begin
  Result := GetGdcLink.ObjectKey;
end;

procedure TwrpGDCLink.PopupMenu(X, Y: Integer);
begin
  GetGdcLink.PopupMenu(X, Y);
end;

procedure TwrpGDCLink.Set_ObjectKey(Value: Integer);
begin
  GetGdcLink.ObjectKey := Value;
end;

{ TgsComScaner }

function TwrpGsComScaner.GetGsComScaner: TgsComScaner;
begin
  Result := GetObject as TgsComScaner;
end;

function TwrpGsComScaner.Get_ComNumber: Shortint;
begin
  Result := GetGsComScaner.ComNumber;
end;

procedure TwrpGsComScaner.Set_ComNumber(Value: Shortint);
begin
  GetGsComScaner.ComNumber := Value;
end;

function TwrpGsComScaner.Get_Parity: TgsParity;
begin
  Result := TgsParity(GetGsComScaner.Parity);
end;

procedure TwrpGsComScaner.Set_Parity(Value: TgsParity);
begin
  GetGsComScaner.Parity := TParity(Value);
end;

function TwrpGsComScaner.Get_BaudRate: Integer;
begin
  Result := GetGsComScaner.BaudRate;
end;

procedure TwrpGsComScaner.Set_BaudRate(Value: Integer);
begin
  GetGsComScaner.BaudRate := Value;
end;

function TwrpGsComScaner.Get_DataBits: Shortint;
begin
  Result := GetGsComScaner.DataBits;
end;

procedure TwrpGsComScaner.Set_DataBits(Value: Shortint);
begin
  GetGsComScaner.DataBits := Value;
end;

function TwrpGsComScaner.Get_StopBits: Shortint;
begin
  Result := GetGsComScaner.StopBits;
end;

procedure TwrpGsComScaner.Set_StopBits(Value: Shortint);
begin
  GetGsComScaner.StopBits := Value;
end;

function TwrpGsComScaner.Get_BeforeChar: Integer;
begin
  Result := GetGsComScaner.BeforeChar;
end;

procedure TwrpGsComScaner.Set_BeforeChar(Value: Integer);
begin
  GetGsComScaner.BeforeChar := Value;
end;

function TwrpGsComScaner.Get_AfterChar: Shortint;
begin
  Result := GetGsComScaner.AfterChar;
end;

procedure TwrpGsComScaner.Set_AfterChar(Value: Shortint);
begin
  GetGsComScaner.AfterChar := Value;
end;

function TwrpGsComScaner.Get_CRSuffix: WordBool;
begin
  Result := GetGsComScaner.CRSuffix;
end;

procedure TwrpGsComScaner.Set_CRSuffix(Value: WordBool);
begin
  GetGsComScaner.CRSuffix := Value;
end;

function TwrpGsComScaner.Get_LFSuffix: WordBool;
begin
  Result := GetGsComScaner.LFSuffix;
end;

procedure TwrpGsComScaner.Set_LFSuffix(Value: WordBool);
begin
  GetGsComScaner.LFSuffix := Value;
end;

function TwrpGsComScaner.Get_BarCode: WideString;
begin
  Result := GetGsComScaner.BarCode;
end;

procedure TwrpGsComScaner.Set_BarCode(const Value: WideString);
begin
  //GetGsComScaner.BarCode := Value;
end;

function TwrpGsComScaner.Get_Enabled: WordBool;
begin
  Result := GetGsComScaner.Enabled;
end;

procedure TwrpGsComScaner.Set_Enabled(Value: WordBool);
begin
  GetGsComScaner.Enabled := Value;                      
end;

function TwrpGsComScaner.Get_AllowStreamedEnabled: WordBool;
begin
  Result := GetGsComScaner.AllowStreamedEnabled;
end;

procedure TwrpGsComScaner.Set_AllowStreamedEnabled(Value: WordBool);
begin
  GetGsComScaner.AllowStreamedEnabled := Value;
end;

{ TwrpGridConditions }

function TwrpGridConditions.Add: IgsCondition;
begin
  Result := GetGdcOLEObject(GetGridConditions.Add) as IgsCondition;
end;

function TwrpGridConditions.Get_Grid: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetGridConditions.Grid) as IgsgsCustomDBGrid;
end;

function TwrpGridConditions.Get_Items(Index: Integer): IgsCondition;
begin
  Result := GetGdcOLEObject(GetGridConditions.Items[index]) as IgsCondition;
end;

function TwrpGridConditions.GetGridConditions: TGridConditions;
begin
  Result := GetObject as TGridConditions;
end;

procedure TwrpGridConditions.Set_Items(Index: Integer;
  const Value: IgsCondition);
begin
  GetGridConditions.Items[Index] := InterfaceToObject(Value) as TCondition;
end;

{ TwrpCondition }

function TwrpCondition.Get_Color: Integer;
begin
  Result := GetCondition.Color;
end;

function TwrpCondition.Get_ConditionKind: TgsConditionKind;
begin
  Result := TgsConditionKind(GetCondition.ConditionKind);
end;

function TwrpCondition.Get_ConditionName: WideString;
begin
  Result := GetCondition.ConditionName;
end;

function TwrpCondition.Get_ConditionState: TgsConditionState;
begin
  Result := TgsConditionState(GetCondition.ConditionState);
end;

function TwrpCondition.Get_DisplayFields: WideString;
begin
  Result := GetCondition.DisplayFields;
end;

function TwrpCondition.Get_DisplayOptions: WideString;
begin
  Result := '';
  if doColor in GetCondition.DisplayOptions then
    Result := Result + 'doColor';
  if doFont in GetCondition.DisplayOptions then
    Result := Result + 'doFont';
end;

function TwrpCondition.Get_EvaluateFormula: WordBool;
begin
  Result := GetCondition.EvaluateFormula;
end;

function TwrpCondition.Get_Expression1: WideString;
begin
  Result := GetCondition.Expression1;
end;

function TwrpCondition.Get_Expression2: WideString;
begin
  Result := GetCondition.Expression2;
end;

function TwrpCondition.Get_FieldName: WideString;
begin
  Result := GetCondition.FieldName;
end;

function TwrpCondition.Get_Font: IgsFont;
begin
  Result := GetGdcOLEObject(GetCondition.Font) as IgsFont;
end;

function TwrpCondition.Get_Grid: IgsgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetCondition.Grid) as IgsGsCustomDBGrid;
end;

function TwrpCondition.Get_IsValid: WordBool;
begin
  Result := GetCondition.IsValid;
end;

function TwrpCondition.Get_UserCondition: WordBool;
begin
  Result := GetCondition.UserCondition;
end;

function TwrpCondition.GetCondition: TCondition;
begin
  Result := GetObject as TCondition;
end;

procedure TwrpCondition.Set_Color(Value: Integer);
begin
  GetCondition.Color := Value;
end;

procedure TwrpCondition.Set_ConditionKind(Value: TgsConditionKind);
begin
  GetCondition.ConditionKind := TConditionKind(Value);
end;

procedure TwrpCondition.Set_ConditionName(const Value: WideString);
begin
  GetCondition.ConditionName := Value;
end;

procedure TwrpCondition.Set_DisplayFields(const Value: WideString);
begin
  GetCondition.DisplayFields := Value;
end;

procedure TwrpCondition.Set_DisplayOptions(const Value: WideString);
var
  dopt: TDisplayOptions;
begin
  dopt := [];
  if StrIPos('doColor', Value) > 0 then
    Include(dopt, doColor);
  if StrIPos('doFont', Value) > 0 then
    Include(dopt, doFont);
  GetCondition.DisplayOptions := dopt;
end;

procedure TwrpCondition.Set_EvaluateFormula(Value: WordBool);
begin
  GetCondition.EvaluateFormula := Value;
end;

procedure TwrpCondition.Set_Expression1(const Value: WideString);
begin
  GetCondition.Expression1 := Value;
end;

procedure TwrpCondition.Set_Expression2(const Value: WideString);
begin
  GetCondition.Expression2 := Value;
end;

procedure TwrpCondition.Set_FieldName(const Value: WideString);
begin
  GetCondition.FieldName := Value;
end;

procedure TwrpCondition.Set_Font(const Value: IgsFont);
begin
  GetCondition.Font := InterfaceToObject(Value) as TFont;
end;

procedure TwrpCondition.Set_UserCondition(Value: WordBool);
begin
  GetCondition.UserCondition := Value;
end;

function TwrpCondition.Suits(
  const DisplayField: IgsFieldComponent): WordBool;
begin
  Result := GetCondition.Suits(InterfaceToObject(DisplayField) as TField);
end;

{ Twrpgdc_dlgUserComplexDocument }

function Twrpgdc_dlgUserComplexDocument.Get_IsAutoCommit: WordBool;
begin
  Result := GetDlgUserComplexDocument.IsAutoCommit;
end;

function Twrpgdc_dlgUserComplexDocument.GetDlgUserComplexDocument: Tgdc_dlgUserComplexDocument;
begin
  Result := GetObject as Tgdc_dlgUserComplexDocument;
end;

procedure Twrpgdc_dlgUserComplexDocument.Set_IsAutoCommit(Value: WordBool);
begin
  GetDlgUserComplexDocument.IsAutoCommit := Value;
end;
 
procedure TwrpGsComScaner.PutString(const S: WideString);
begin
  GetGsComScaner.PutString(S);
end;

{ TwrpGsCompanyStorage }

function TwrpGsCompanyStorage.Get_CompanyKey: Integer;
begin
  Result := GetGsCompanyStorage.ObjectKey;
end;

function TwrpGsCompanyStorage.GetGsCompanyStorage: TgsCompanyStorage;
begin
  Result := GetObject as TgsCompanyStorage;
end;

procedure TwrpGsCompanyStorage.Set_CompanyKey(Value: Integer);
begin
  GetGsCompanyStorage.ObjectKey := Value;
end;

{ TwrpStreamSaver }

class function TwrpStreamSaver.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdcStreamSaver), 'Invalide Delphi class');

  if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 1) then
    Result := TgdcStreamSaver.Create(InterfaceToObject(Params[0]) as TIBDatabase, InterfaceToObject(Params[1]) as TIBTransaction)
  else
    Result := TgdcStreamSaver.Create;
end;

function TwrpStreamSaver.GetStreamSaver: TgdcStreamSaver;
begin
  Result := GetObject as TgdcStreamSaver;
end;

procedure TwrpStreamSaver.AddObject(const AgdcObject: IgsGDCBase; AWithDetail: WordBool);
begin
  GetStreamSaver.AddObject(InterfaceToObject(AgdcObject) as TgdcBase, AWithDetail);
end;

procedure TwrpStreamSaver.SaveToStream(const S: IgsStream; AFormat: WordBool = false);
begin
  // Параметр оставлен для обратной совместимости,
  //  теперь менять формат нужно через TwrpStreamSaver.StreamFormat
  if AFormat then
    GetStreamSaver.StreamFormat := sttXML;
  GetStreamSaver.SaveToStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpStreamSaver.LoadFromStream(const S: IgsStream);
begin
  GetStreamSaver.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpStreamSaver.PrepareForIncrementSaving(ABasekey: Integer);
begin
  GetStreamSaver.PrepareForIncrementSaving(ABasekey);
end;

function TwrpStreamSaver.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetStreamSaver.Transaction) as IgsIBTransaction;
end;

procedure TwrpStreamSaver.Set_Transaction(const Value: IgsIBTransaction);
begin
  if Assigned(Value) then
    GetStreamSaver.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

function TwrpStreamSaver.Get_Silent: WordBool;
begin
  Result := GetStreamSaver.Silent;
end;

procedure TwrpStreamSaver.Set_Silent(Value: WordBool);
begin
  GetStreamSaver.Silent := Value;
end;

function TwrpStreamSaver.Get_NeedModifyList: IgsGDKeyIntAssoc;
begin
  Result := GetGdcOLEObject(GetStreamSaver.NeedModifyList) as IgsGDKeyIntAssoc;
end;

function TwrpStreamSaver.Get_SaveWithDetailList: IgsGDKeyArray;
begin
  Result := GetGdcOLEObject(GetStreamSaver.SaveWithDetailList) as IgsGDKeyArray;
end;

procedure TwrpStreamSaver.Set_NeedModifyList(const Value: IgsGDKeyIntAssoc);
begin
  GetStreamSaver.NeedModifyList := InterfaceToObject(Value) as TgdKeyIntAssoc;
end;

procedure TwrpStreamSaver.Set_SaveWithDetailList(const Value: IgsGDKeyArray);
begin
  GetStreamSaver.SaveWithDetailList := InterfaceToObject(Value) as TgdKeyArray;
end;

function TwrpStreamSaver.Get_StreamFormat: WideString;
begin
  Result := StreamTypeToString(GetStreamSaver.StreamFormat);
end;

procedure TwrpStreamSaver.Set_StreamFormat(const Value: WideString);
begin
  GetStreamSaver.StreamFormat := StringToStreamType(Value);
end;

procedure TwrpStreamSaver.Clear;
begin
  GetStreamSaver.Clear;
end;

function TwrpStreamSaver.Get_ReplaceRecordAnswer: Word;
begin
  Result := GetStreamSaver.ReplaceRecordAnswer;
end;

procedure TwrpStreamSaver.Set_ReplaceRecordAnswer(Value: Word);
begin
  GetStreamSaver.ReplaceRecordAnswer := Value;
end;

{ TwrpGdvAcctBase }

procedure TwrpGdvAcctBase.AddAccount(AccountKey: Integer);
begin
  GetGdvAcctBase.AddAccount(AccountKey);
end;

procedure TwrpGdvAcctBase.AddCondition(const FieldName, AValue: WideString);
begin
  GetGdvAcctBase.AddCondition(FieldName, AValue);
end;

procedure TwrpGdvAcctBase.AddCorrAccount(AccountKey: Integer);
begin
  GetGdvAcctBase.AddCorrAccount(AccountKey);
end;

procedure TwrpGdvAcctBase.AddValue(ValueKey: Integer; const ValueName: WideString);
begin
  GetGdvAcctBase.AddValue(ValueKey, ValueName);
end;

class function TwrpGdvAcctBase.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctBase), 'Invalide Delphi class');
  Result := TgdvAcctBase.Create(InterfaceToObject(Params[0]) as TComponent);
end;

procedure TwrpGdvAcctBase.Execute(ConfigID: Integer);
begin
  GetGdvAcctBase.Execute(ConfigID);
end;

function TwrpGdvAcctBase.Get_AllHolding: WordBool;
begin
  Result := GetGdvAcctBase.AllHolding;
end;

function TwrpGdvAcctBase.Get_CompanyKey: Integer;
begin
  Result := GetGdvAcctBase.CompanyKey;
end;

function TwrpGdvAcctBase.Get_DateBegin: TDateTime;
begin
  Result := GetGdvAcctBase.DateBegin;
end;

function TwrpGdvAcctBase.Get_DateEnd: TDateTime;
begin
  Result := GetGdvAcctBase.DateEnd;
end;

function TwrpGdvAcctBase.Get_IncludeInternalMovement: WordBool;
begin
  Result := GetGdvAcctBase.IncludeInternalMovement;
end;

function TwrpGdvAcctBase.Get_MakeEmpty: WordBool;
begin
  Result := GetGdvAcctBase.MakeEmpty;
end;

function TwrpGdvAcctBase.Get_ShowExtendedFields: WordBool;
begin
  Result := GetGdvAcctBase.ShowExtendedFields;
end;

function TwrpGdvAcctBase.Get_WithSubAccounts: WordBool;
begin
  Result := GetGdvAcctBase.WithSubAccounts;
end;

function TwrpGdvAcctBase.GetGdvAcctBase: TgdvAcctBase;
begin
  Result := GetObject as TgdvAcctBase;
end;

procedure TwrpGdvAcctBase.Set_AllHolding(Value: WordBool);
begin
  GetGdvAcctBase.AllHolding := Value;
end;

procedure TwrpGdvAcctBase.Set_CompanyKey(Value: Integer);
begin
  GetGdvAcctBase.CompanyKey := Value;
end;

procedure TwrpGdvAcctBase.Set_DateBegin(Value: TDateTime);
begin
  GetGdvAcctBase.DateBegin := Value;
end;

procedure TwrpGdvAcctBase.Set_DateEnd(Value: TDateTime);
begin
  GetGdvAcctBase.DateEnd := Value;
end;

procedure TwrpGdvAcctBase.Set_IncludeInternalMovement(Value: WordBool);
begin
  GetGdvAcctBase.IncludeInternalMovement := Value;
end;

procedure TwrpGdvAcctBase.Set_MakeEmpty(Value: WordBool);
begin
  GetGdvAcctBase.MakeEmpty := Value;
end;

procedure TwrpGdvAcctBase.Set_ShowExtendedFields(Value: WordBool);
begin
  GetGdvAcctBase.ShowExtendedFields := Value;
end;

procedure TwrpGdvAcctBase.Set_WithSubAccounts(Value: WordBool);
begin
  GetGdvAcctBase.WithSubAccounts := Value;
end;

procedure TwrpGdvAcctBase.ShowInCurr(Show: WordBool; DecDigits, Scale,
  CurrKey: Integer);
begin
  GetGdvAcctBase.ShowInCurr(Show, DecDigits, Scale, Currkey);
end;

procedure TwrpGdvAcctBase.ShowInEQ(Show: WordBool; DecDigits,
  Scale: Integer);
begin
  GetGdvAcctBase.ShowInEQ(Show, DecDigits, Scale);
end;

procedure TwrpGdvAcctBase.ShowInNcu(Show: WordBool; DecDigits,
  Scale: Integer);
begin
  GetGdvAcctBase.ShowInNcu(Show, DecDigits, Scale);
end;

procedure TwrpGdvAcctBase.ShowInQuantity(DecDigits, Scale: Integer);
begin
  GetGdvAcctBase.ShowInQuantity(DecDigits, Scale);
end;

procedure TwrpGdvAcctBase.BuildReport;
begin
  GetGdvAcctBase.BuildReport;
end;

procedure TwrpGdvAcctBase.Clear;
begin
  GetGdvAcctBase.Clear;
end;

procedure TwrpGdvAcctBase.LoadConfig(AID: Integer);
begin
  GetGdvAcctBase.LoadConfig(AID);
end;

function TwrpGdvAcctBase.SaveConfig(AConfigKey: Integer): Integer;
begin
  Result := GetGdvAcctBase.SaveConfig(AConfigKey);
end;

function TwrpGdvAcctBase.ParamByName(const ParamName: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetGdvAcctBase.ParamByName(ParamName)) as IgsIBXSQLVAR;
end;

function TwrpGdvAcctBase.Get_CompanyName: WideString;
begin
  Result := GetGdvAcctBase.CompanyName;
end;

{ TwrpGdvAcctAccReview }

class function TwrpGdvAcctAccReview.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctAccReview), 'Invalide Delphi class');
  Result := TgdvAcctAccReview.Create(InterfaceToObject(Params[0]) as TComponent);
end;

function TwrpGdvAcctAccReview.Get_CorrDebit: WordBool;
begin
  Result := GetGdvAcctAccReview.CorrDebit;
end;

function TwrpGdvAcctAccReview.Get_SaldoBeginCurr: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoBeginCurr;
end;

function TwrpGdvAcctAccReview.Get_SaldoBeginEQ: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoBeginEQ;
end;

function TwrpGdvAcctAccReview.Get_SaldoBeginNcu: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoBeginNcu;
end;

function TwrpGdvAcctAccReview.Get_SaldoEndCurr: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoEndCurr;
end;

function TwrpGdvAcctAccReview.Get_SaldoEndEQ: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoEndEQ;
end;

function TwrpGdvAcctAccReview.Get_SaldoEndNcu: Currency;
begin
  Result := GetGdvAcctAccReview.SaldoEndNcu;
end;

function TwrpGdvAcctAccReview.Get_WithCorrSubAccounts: WordBool;
begin
  Result := GetGdvAcctAccReview.WithCorrSubAccounts;
end;

function TwrpGdvAcctAccReview.GetGdvAcctAccReview: TgdvAcctAccReview;
begin
  Result := GetObject as TgdvAcctAccReview;
end;

procedure TwrpGdvAcctAccReview.Set_CorrDebit(Value: WordBool);
begin
  GetGdvAcctAccReview.CorrDebit := Value;
end;

procedure TwrpGdvAcctAccReview.Set_WithCorrSubAccounts(Value: WordBool);
begin
  GetGdvAcctAccReview.WithCorrSubAccounts := Value;
end;

function TwrpGdvAcctAccReview.Get_IBDSSaldoBegin: IgsIBDataSet;
begin
  Result := GetGdcOLEObject(GetGdvAcctAccReview.IBDSSaldoBegin) as IgsIBDataSet;
end;

function TwrpGdvAcctAccReview.Get_IBDSSaldoEnd: IgsIBDataSet;
begin
  Result := GetGdcOLEObject(GetGdvAcctAccReview.IBDSSaldoEnd) as IgsIBDataSet;
end;

function TwrpGdvAcctAccReview.Get_IBDSCirculation: IgsIBDataSet;
begin
  Result := GetGdcOLEObject(GetGdvAcctAccReview.IBDSCirculation) as IgsIBDataSet;
end;

{ TwrpGdvAcctAccCard }

class function TwrpGdvAcctAccCard.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctAccCard), 'Invalide Delphi class');
  Result := TgdvAcctAccCard.Create(InterfaceToObject(Params[0]) as TComponent);
end;

function TwrpGdvAcctAccCard.Get_DoGroup: WordBool;
begin
  Result := GetGdvAcctAccCard.DoGroup;
end;

procedure TwrpGdvAcctAccCard.Set_DoGroup(Value: WordBool);
begin
  GetGdvAcctAccCard.DoGroup := Value;
end;

function TwrpGdvAcctAccCard.GetGdvAcctAccCard: TgdvAcctAccCard;
begin
  Result := GetObject as TgdvAcctAccCard;
end;

function TwrpGdvAcctAccCard.Get_IBDSSaldoQuantityBegin: IgsIBDataSet;
begin
  Result := GetGdcOLEObject(GetGdvAcctAccCard.IBDSSaldoQuantityBegin) as IgsIBDataSet;
end;

function TwrpGdvAcctAccCard.Get_IBDSSaldoQuantityEnd: IgsIBDataSet;
begin
  Result := GetGdcOLEObject(GetGdvAcctAccCard.IBDSSaldoQuantityEnd) as IgsIBDataSet;
end;

{ TwrpGdvAcctLedger }

class function TwrpGdvAcctLedger.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctLedger), 'Invalide Delphi class');
  Result := TgdvAcctLedger.Create(InterfaceToObject(Params[0]) as TComponent);
end;

function TwrpGdvAcctLedger.GetGdvAcctLedger: TgdvAcctLedger;
begin
  Result := GetObject as TgdvAcctLedger;
end;

procedure TwrpGdvAcctLedger.AddAnalyticLevel(const AnalyticName,
  Levels: WideString);
begin
  GetGdvAcctLedger.AddAnalyticLevel(AnalyticName, Levels);
end;

procedure TwrpGdvAcctLedger.AddGroupBy(const GroupFieldName: WideString);
begin
  GetGdvAcctLedger.AddGroupBy(GroupFieldName);
end;

function TwrpGdvAcctLedger.Get_EnchancedSaldo: WordBool;
begin
  Result := GetGdvAcctLedger.EnchancedSaldo;
end;

function TwrpGdvAcctLedger.Get_ShowCorrSubAccounts: WordBool;
begin
  Result := GetGdvAcctLedger.ShowCorrSubAccounts;
end;

function TwrpGdvAcctLedger.Get_ShowCredit: WordBool;
begin
  Result := GetGdvAcctLedger.ShowCredit;
end;

function TwrpGdvAcctLedger.Get_ShowDebit: WordBool;
begin
  Result := GetGdvAcctLedger.ShowDebit;
end;

function TwrpGdvAcctLedger.Get_SumNull: WordBool;
begin
  Result := GetGdvAcctLedger.SumNull;
end;

procedure TwrpGdvAcctLedger.Set_EnchancedSaldo(Value: WordBool);
begin
  GetGdvAcctLedger.EnchancedSaldo := Value;
end;

procedure TwrpGdvAcctLedger.Set_ShowCorrSubAccounts(Value: WordBool);
begin
  GetGdvAcctLedger.ShowCorrSubAccounts := Value;
end;

procedure TwrpGdvAcctLedger.Set_ShowCredit(Value: WordBool);
begin
  GetGdvAcctLedger.ShowCredit := Value;
end;

procedure TwrpGdvAcctLedger.Set_ShowDebit(Value: WordBool);
begin
  GetGdvAcctLedger.ShowDebit := Value;
end;

procedure TwrpGdvAcctLedger.Set_SumNull(Value: WordBool);
begin
  GetGdvAcctLedger.SumNull := Value;
end;

{ TwrpGdvAcctGeneralLedger }

class function TwrpGdvAcctGeneralLedger.CreateObject(
  const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctGeneralLedger), 'Invalide Delphi class');
  Result := TgdvAcctGeneralLedger.Create(InterfaceToObject(Params[0]) as TComponent);
end;

function TwrpGdvAcctGeneralLedger.GetGdvAcctGeneralLedger: TgdvAcctGeneralLedger;
begin
  Result := GetObject as TgdvAcctGeneralLedger;
end;

{ TwrpGdvAcctCirculationList }

class function TwrpGdvAcctCirculationList.CreateObject(
  const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgdvAcctCirculationList), 'Invalide Delphi class');
  Result := TgdvAcctCirculationList.Create(InterfaceToObject(Params[0]) as TComponent);
end;

function TwrpGdvAcctCirculationList.GetGdvAcctCirculationList: TgdvAcctCirculationList;
begin
  Result := GetObject as TgdvAcctCirculationList;
end;

{ TwrpGsParamList }

function TwrpGsParamList.AddLinkParam(const AnDisplayName,
  AnParamType, AnTableName, AnPrimaryField, AnDisplayField,
  AnLinkConditionFunction, AnLinkFunctionLanguage,
  AnComment: WideString): SYSINT;
begin
  Result := GetParamList.AddLinkParam(AnDisplayName, AnDisplayName, StringToParamType(AnParamType),
    AnTableName, AnDisplayField, AnPrimaryField, AnLinkConditionFunction, AnLinkFunctionLanguage,
    AnComment);
end;

function TwrpGsParamList.AddParam(const AnDisplayName: WideString;
  const AnParamType: WideString; const AnComment: WideString): SYSINT;
begin
  Result := GetParamList.AddParam(AnDisplayName, AnDisplayName, StringToParamType(AnParamType), AnComment);
end;

procedure TwrpGsParamList.Assign_(const Source: IgsParamList);
begin
  GetParamList.Assign(InterfaceToObject(Source) as TgsParamList);
end;

class function TwrpGsParamList.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsParamList), 'Invalide Delphi class');
  Result := TgsParamList.Create;
end;

function TwrpGsParamList.GetParamList: TgsParamList;
begin
  Result := GetObject as TgsParamList;
end;

function TwrpGsParamList.GetVariantArray: OleVariant;
begin
  Result := GetParamList.GetVariantArray;
end;

function TwrpGsParamList.Get_Params(Index: Integer): IgsParamData;
begin
  Result := GetGdcOLEObject(GetParamList.Params[Index]) as IgsParamData;
end;

{ TwrpGsParamData }

class function TwrpGsParamData.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsParamData), 'Invalide Delphi class');
  Result := TgsParamData.Create;
end;

function TwrpGsParamData.Get_Comment: WideString;
begin
  Result := GetParamData.Comment;
end;

function TwrpGsParamData.Get_DisplayName: WideString;
begin
  Result := GetParamData.DisplayName;
end;

function TwrpGsParamData.Get_LinkConditionFunction: WideString;
begin
  Result := GetParamData.LinkConditionFunction;
end;

function TwrpGsParamData.Get_LinkDisplayField: WideString;
begin
  Result := GetParamData.LinkDisplayField;
end;

function TwrpGsParamData.Get_LinkFunctionLanguage: WideString;
begin
  Result := GetParamData.LinkFunctionLanguage;
end;

function TwrpGsParamData.Get_LinkPrimaryField: WideString;
begin
  Result := GetParamData.LinkPrimaryField;
end;

function TwrpGsParamData.Get_LinkTableName: WideString;
begin
  Result := GetParamData.LinkTableName;
end;

function TwrpGsParamData.Get_ParamType: WideString;
begin
  Result := ParamTypeToString(GetParamData.ParamType);
end;

function TwrpGsParamData.Get_RealName: WideString;
begin
  Result := GetParamData.RealName;
end;

function TwrpGsParamData.Get_Required: WordBool;
begin
  Result := GetParamData.Required;
end;

function TwrpGsParamData.Get_Value: OleVariant;
begin
  Result := GetParamData.ResultValue;
end;

procedure TwrpGsParamData.Set_Comment(const Value: WideString);
begin
  GetParamData.Comment := Value;
end;

procedure TwrpGsParamData.Set_DisplayName(const Value: WideString);
begin
  GetParamData.DisplayName := Value;
end;

procedure TwrpGsParamData.Set_LinkConditionFunction(const Value: WideString);
begin
  GetParamData.LinkConditionFunction := Value;
end;

procedure TwrpGsParamData.Set_LinkDisplayField(const Value: WideString);
begin
  GetParamData.LinkDisplayField := Value;
end;

procedure TwrpGsParamData.Set_LinkFunctionLanguage(const Value: WideString);
begin
  GetParamData.LinkFunctionLanguage := Value;
end;

function  TwrpGsParamData.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetParamData.Transaction) as IgsIBTransaction;
end;

procedure TwrpGsParamData.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetParamData.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpGsParamData.Set_LinkPrimaryField(const Value: WideString);
begin
  GetParamData.LinkPrimaryField := Value;
end;

procedure TwrpGsParamData.Set_LinkTableName(const Value: WideString);
begin
  GetParamData.LinkTableName := Value;
end;

procedure TwrpGsParamData.Set_ParamType(const Value: WideString);
begin
  GetParamData.ParamType := StringToParamType(Value);
end;

procedure TwrpGsParamData.Set_RealName(const Value: WideString);
begin
  GetParamData.RealName := Value;
end;

procedure TwrpGsParamData.Set_Required(Value: WordBool);
begin
  GetParamData.Required := Value;
end;

procedure TwrpGsParamData.Set_Value(Value: OleVariant);
begin
  GetParamData.ResultValue := Value;
end;

function TwrpGsParamData.GetParamData: TgsParamData;
begin
  Result := GetObject as TgsParamData;
end;

procedure TwrpGsParamData.Assign_(const Source: IgsParamData);
begin
  GetParamData.Assign(InterfaceToObject(Source) as TgsParamData);
end;

function TwrpGsParamData.Get_ValuesList: WideString;
begin
  Result := GetParamData.ValuesList;
end;

procedure TwrpGsParamData.Set_ValuesList(const Value: WideString);
begin
  GetParamData.ValuesList := Value;
end;

function TwrpGsParamData.Get_SortOrder: Shortint;
begin
  Result := GetParamData.SortOrder;
end;

procedure TwrpGsParamData.Set_SortOrder(Value: Shortint);
begin
  GetParamData.SortOrder := Value;
end;

function TwrpGsParamData.Get_SortField: WideString;
begin
  Result := GetParamData.SortField;
end;

procedure TwrpGsParamData.Set_SortField(const Value: WideString);
begin
  GetParamData.SortField := Value;
end;

{ TwrpGsFrmGedeminMain }

function TwrpGsFrmGedeminMain.GetFrmGedeminMain: TfrmGedeminMain;
begin
  Result := GetObject as TfrmGedeminMain;
end;

procedure TwrpGsFrmGedeminMain.AddFormToggleItem(const AForm: IgsForm);
begin
  GetFrmGedeminMain.AddFormToggleItem(InterfaceToObject(AForm) as TForm);
end;

function TwrpGsFrmGedeminMain.GetFormToggleItemIndex(const AForm: IgsForm): Integer;
begin
  Result := GetFrmGedeminMain.GetFormToggleItemIndex(InterfaceToObject(AForm) as TForm);
end;

function TwrpGsFrmGedeminMain.GetFormToggleItem(const AForm: IgsForm): IgsTBCustomItem;
var
  Index: Integer;
begin
  Index := GetFrmGedeminMain.GetFormToggleItemIndex(InterfaceToObject(AForm) as TForm);
  if Index > -1 then
    Result := GetGdcOLEObject(GetFrmGedeminMain.tbForms.Items[Index]) as IgsTBCustomItem
  else
    Result := nil;  
end;

{ TwrpGdv_frmG }

function TwrpGdv_frmG.Get_DateBegin: TDateTime;
begin
  Result := GetGdv_frmG.DateBegin;
end;

function TwrpGdv_frmG.Get_DateEnd: TDateTime;
begin
  Result := GetGdv_frmG.DateEnd;
end;

function TwrpGdv_frmG.GetGdv_frmG: Tgdv_frmG;
begin
  Result := GetObject as Tgdv_frmG;
end;

procedure TwrpGdv_frmG.Set_DateBegin(Value: TDateTime);
begin
  GetGdv_frmG.DateBegin := Value;
end;

procedure TwrpGdv_frmG.Set_DateEnd(Value: TDateTime);
begin
  GetGdv_frmG.DateEnd := Value;
end;

{ TwrpGdc_frmInvCard }

function TwrpGdc_frmInvCard.Get_DateBegin: TDateTime;
begin
  Result := GetGdc_frmInvCard.gsPeriodEdit.Date;
end;

function TwrpGdc_frmInvCard.Get_DateEnd: TDateTime;
begin
  Result := GetGdc_frmInvCard.gsPeriodEdit.EndDate;
end;

function TwrpGdc_frmInvCard.GetGdc_frmInvCard: Tgdc_frmInvCard;
begin
  Result := GetObject as Tgdc_frmInvCard;
end;

procedure TwrpGdc_frmInvCard.Set_DateBegin(Value: TDateTime);
begin
  GetGdc_frmInvCard.gsPeriodEdit.Date := Value;
end;

procedure TwrpGdc_frmInvCard.Set_DateEnd(Value: TDateTime);
begin
  GetGdc_frmInvCard.gsPeriodEdit.EndDate := Value;
end;

{ TwrpGdWebServerControl }

{$IFDEF WITH_INDY}
function TwrpGdWebServerControl.GetWebServerControl: TgdWebServerControl;
begin
  Result := gdWebServerControl;
end;

procedure TwrpGdWebServerControl.RegisterOnGetEvent(const AComponent: IgsComponent;
  const AToken: WideString; const AEventName: WideString);
begin
  if GetWebServerControl <> nil then
    GetWebServerControl.RegisterOnGetEvent(InterfaceToObject(AComponent) as TComponent, AToken, AEventName);
end;

procedure TwrpGdWebServerControl.UnRegisterOnGetEvent(const AComponent: IgsComponent);
begin
  if GetWebServerControl <> nil then
    GetWebServerControl.UnRegisterOnGetEvent(InterfaceToObject(AComponent) as TComponent)
end;
{$ENDIF}

{ TwrpFTPClient }
function TwrpFTPClient.GetFTPClient: TgsFTPClient;
begin
  Result := GetObject as TgsFTPClient;
end;

function TwrpFTPClient.Get_ServerName: WideString;
begin
  Result := GetFTPClient.ServerName;
end;

procedure TwrpFTPClient.Set_ServerName(const Value: WideString);
begin
  GetFTPClient.ServerName := Value;
end;

function TwrpFTPClient.Connect: WordBool;
begin
  Result := GetFTPClient.Connect;
end;

function TwrpFTPClient.Get_ServerPort: Integer;
begin
  Result := GetFTPClient.ServerPort;
end;

procedure TwrpFTPClient.Set_ServerPort(Value: Integer);
begin
  GetFTPClient.ServerPort := Value;
end;

function TwrpFTPClient.Get_UserName: WideString;
begin
  Result := GetFTPClient.UserName;
end;

procedure TwrpFTPClient.Set_UserName(const Value: WideString);
begin
  GetFTPClient.UserName := Value;
end;

function TwrpFTPClient.Get_Password: WideString;
begin
  Result := GetFTPClient.Password;
end;

procedure TwrpFTPClient.Set_Password(const Value: WideString);
begin
  GetFTPClient.Password := Value;
end;

function TwrpFTPClient.Get_TimeOut: Integer;
begin
  Result := GetFTPClient.TimeOut;
end;

procedure TwrpFTPClient.Set_TimeOut(Value: Integer); safecall;
begin
  GetFTPClient.TimeOut := Value;
end;

function TwrpFTPClient.Get_Files: WideString;
begin
  Result := GetFTPClient.Files;
end;

function TwrpFTPClient.Get_LastError: Integer;
begin
  Result := GetFTPClient.LastError;
end;

function TwrpFTPClient.GetAllFiles(const RemotePath: WideString): WordBool;
begin
  Result := GetFTPClient.GetAllFiles(RemotePath);
end;

function TwrpFTPClient.Connected: WordBool;
begin
  Result := GetFTPClient.Connected;
end;

procedure TwrpFTPClient.Close;
begin
  GetFTPClient.Close;
end;

function TwrpFTPClient.GetFile(const RemoteFile: WideString; const LocalFile: WideString; const RemotePath: WideString; Overwrite: Wordbool): WordBool;
begin
  Result := GetFTPClient.GetFile(RemoteFile, LocalFile, RemotePath, OverWrite);
end;

function TwrpFTPClient.PutFile(const LocalFile: WideString; const RemoteFile: WideString; const RemotePath: WideString; OverWrite: Wordbool): WordBool;
begin
  Result := GetFTPClient.PutFile(LocalFile, RemoteFile, RemotePath, OverWrite);
end;

function TwrpFTPClient.DeleteFile(const RemoteFile: WideString; const RemotePath: WideString): WordBool;
begin
  Result := GetFTPClient.DeleteFile(RemoteFile, RemotePath);
end;

function TwrpFTPClient.RenameFile(const OldName: WideString; const NewName: WideString; const Path: WideString): WordBool;
begin
  Result := GetFTPClient.RenameFile(OldName, NewName, Path);
end;

function TwrpFTPClient.CreateDir(const DirName: WideString): WordBool;
begin
  Result := GetFTPClient.CreateDir(DirName);
end;

function TwrpFTPClient.DeleteDir(const DirName: WideString): WordBool;
begin
  Result := GetFTPClient.DeleteDir(DirName);
end;

class function TwrpFTPClient.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsFTPClient), 'Invalide Delphi class');
  Result := TgsFTPClient.Create;
end;

function TwrpTRPOSClient.GetTRPOSClient: TgsTRPOSClient;
begin
  Result := GetObject as TgsTRPOSClient;
end;

function TwrpTRPOSClient.Get_Host: WideString;
begin
  Result := GetTRPOSClient.Host;
end;

function TwrpTRPOSClient.Get_Port: Integer;
begin
  Result := GetTRPOSClient.Port;
end;

procedure TwrpTRPOSClient.Set_Host(const Value: WideString);
begin
  GetTRPOSClient.Host := Value;
end;

procedure TwrpTRPOSClient.Set_Port(Value: Integer);
begin
  GetTRPOSClient.Port := Value;
end;

procedure TwrpTRPOSClient.TestHost(ACashNumber: LongWord);
begin
  GetTRPOSClient.TestHost(ACashNumber);
end;

procedure TwrpTRPOSClient.TestPinPad(ACashNumber: LongWord);
begin
  GetTRPOSClient.TestPinPad(ACashNumber);
end;

procedure TwrpTRPOSClient.Connect;
begin
  GetTRPOSClient.Connect;
end;

procedure TwrpTRPOSClient.Disconnect;
begin
  GetTRPOSClient.Disconnect;
end;

function TwrpTRPOSClient.Get_Connected: WordBool;
begin
  Result := GetTRPOSClient.Connected;
end;

procedure TwrpTRPOSClient.ReadData(const AParams: IgsTRPOSOutPutData);
begin
  GetTRPOSClient.ReadData(InterfaceToObject(AParams) as TgsTRPOSOutPutData);
end;

procedure TwrpTRPOSClient.Payment(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
  ACurrCode: Integer; APreAUT: WordBool; const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.Payment(ASumm, ATrNumber, ACashNumber, ACurrCode, APreAUT,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Cash(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord; ACurrCode: Integer;
  const AParam: IgsTRPOSParamData); safecall;
begin
  GetTRPOSClient.Cash(ASumm, ATrNumber, ACashNumber, ACurrCode,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Replenishment(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
  ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
begin
  GetTRPOSClient.Replenishment(ASumm, ATrNumber, ACashNumber, ACurrCode,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Cancel(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
  ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
begin
  GetTRPOSClient.Cancel(ASumm, ATrNumber, ACashNumber, ACurrCode,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Return(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
  ACurrCode: Integer; const AParam: IgsTRPOSParamData); safecall;
begin
  GetTRPOSClient.Return(ASumm, ATrNumber, ACashNumber, ACurrCode,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.ReadJournal(ATrNumber: LongWord; ACashNumber: LongWord;
  const AParam: IgsTRPOSParamData); safecall;
begin
  GetTRPOSClient.ReadJournal(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.PreAuthorize(ASumm: Currency; ATrNumber: LongWord; ACashNumber: LongWord;
  ACurrCode: Integer; const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.PreAuthorize(ASumm, ATrNumber, ACashNumber, ACurrCode,
    InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Balance(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.Balance(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.ResetLockJournal(ATrNumber: LongWord; ACashNumber: LongWord;
  const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.ResetLockJournal(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Calculation(ATrNumber: LongWord; ACashNumber: LongWord;
  const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.Calculation(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.Ping(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.Ping(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.ReadCard(ATrNumber: LongWord; ACashNumber: LongWord; const AParam: IgsTRPOSParamData);
begin
  GetTRPOSClient.ReadCard(ATrNumber, ACashNumber, InterfaceToObject(AParam) as TgsTRPOSParamData);
end;

procedure TwrpTRPOSClient.ReconciliationResults(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.ReconciliationResults(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.Duplicate(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.Duplicate(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.JRNClean(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.JRNClean(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.RVRClean(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.RVRClean(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.FullClean(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.FullClean(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.MenuPrintReport(ACashNumber: LongWord);
begin
  GetTRPOSClient.MenuPrintReport(ACashNumber);
end;

procedure TwrpTRPOSClient.DSortByDate(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.DSortByDate(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.DSortByIssuer(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.DSortByIssuer(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.SSortByDate(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.SSortByDate(ATrNumber, ACashNumber);
end;

procedure TwrpTRPOSClient.RePrint(ATrNumber: LongWord; ACashNumber: LongWord);
begin
  GetTRPOSClient.RePrint(ATrNumber, ACashNumber);
end;

function TwrpTRPOSClient.Get_ReadTimeOut: Integer;
begin
  Result := GetTRPOSClient.ReadTimeOut;
end;

procedure TwrpTRPOSClient.Set_ReadTimeOut(Value: Integer);
begin
  GetTRPOSClient.ReadTimeOut := Value;
end;

class function TwrpTRPOSClient.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsTRPOSClient), 'Invalide Delphi class');
  Result := TgsTRPOSClient.Create;
end;

function TwrpTRPOSOutPutData.GetTRPOSOutPutData: TgsTRPOSOutPutData;
begin
  Result := GetObject as TgsTRPOSOutPutData;
end;

function  TwrpTRPOSOutPutData.Get_MessageID: WideString;
begin
  Result := GetTRPOSOutPutData.MessageID;
end;

function TwrpTRPOSOutPutData.Get_ECRnumber: LongWord;
begin
  Result := GetTRPOSOutPutData.ECRnumber;
end;

function TwrpTRPOSOutPutData.Get_ERN: LongWord;
begin
  Result := GetTRPOSOutPutData.ERN;
end;

function TwrpTRPOSOutPutData.Get_ResponseCode: WideString;
begin
  Result := GetTRPOSOutPutData.ResponseCode;
end;

function TwrpTRPOSOutPutData.Get_TransactionAmount: WideString;
begin
  Result := GetTRPOSOutPutData.TransactionAmount;
end;

function TwrpTRPOSOutPutData.Get_Pan: WideString;
begin
  Result := GetTRPOSOutPutData.Pan;
end;

function TwrpTRPOSOutPutData.Get_ExpDate: WideString;
begin
  Result := GetTRPOSOutPutData.ExpDate;
end;

function TwrpTRPOSOutPutData.Get_Approve: WideString;
begin
  Result := GetTRPOSOutPutData.Approve;
end;

function TwrpTRPOSOutPutData.Get_Receipt: WideString;
begin
  Result := GetTRPOSOutPutData.Receipt;
end;

function TwrpTRPOSOutPutData.Get_InvoiceNumber: WideString;
begin
  Result := GetTRPOSOutPutData.InvoiceNumber;
end;

function TwrpTRPOSOutPutData.Get_AuthorizationID: WideString;
begin
  Result := GetTRPOSOutPutData.AuthorizationID;
end;

function TwrpTRPOSOutPutData.Get_Date: WideString;
begin
  Result := GetTRPOSOutPutData.Date;
end;

function TwrpTRPOSOutPutData.Get_Time: WideString;
begin
  Result := GetTRPOSOutPutData.Time;
end;

function TwrpTRPOSOutPutData.Get_VerificationChr: WideString;
begin
  Result := GetTRPOSOutPutData.VerificationChr;
end;

function TwrpTRPOSOutPutData.Get_RRN: WideString;
begin
  Result := GetTRPOSOutPutData.RRN;
end;

function TwrpTRPOSOutPutData.Get_TVR: WideString;
begin
  Result := GetTRPOSOutPutData.TVR;
end;

function TwrpTRPOSOutPutData.Get_TerminalID: WideString;
begin
  Result := GetTRPOSOutPutData.TerminalID;
end;

function TwrpTRPOSOutPutData.Get_CardDataEnc: WideString;
begin
  Result := GetTRPOSOutPutData.CardDataEnc;
end;

function TwrpTRPOSOutPutData.Get_VisualHostResponse: WideString;
begin
  Result := GetTRPOSOutPutData.VisualHostResponse;
end;

procedure TwrpTRPOSOutPutData.Clear;
begin
  GetTRPOSOutPutData.Clear;
end;

function TwrpTRPOSParamData.GetTRPOSParamData: TgsTRPOSParamData;
begin
  Result := GetObject as TgsTRPOSParamData;
end;

function TwrpTRPOSParamData.Get_Track1Data: WideString;
begin
  Result := GetTRPOSParamData.Track1Data;
end;

procedure TwrpTRPOSParamData.Set_Track1Data(const Value: WideString);
begin
  GetTRPOSParamData.Track1Data := Value;
end;

function TwrpTRPOSParamData.Get_Track2Data: WideString;
begin
  Result := GetTRPOSParamData.Track2Data;
end;

procedure TwrpTRPOSParamData.Set_Track2Data(const Value: WideString);
begin
  GetTRPOSParamData.Track2Data := Value;
end;

function TwrpTRPOSParamData.Get_Track3Data: WideString;
begin
  Result := GetTRPOSParamData.Track3Data;
end;

procedure TwrpTRPOSParamData.Set_Track3Data(const Value: WideString);
begin
  GetTRPOSParamData.Track3Data := Value;
end;

function TwrpTRPOSParamData.Get_Pan: WideString;
begin
  Result := GetTRPOSParamData.Pan;
end;

procedure TwrpTRPOSParamData.Set_Pan(const Value: WideString);
begin
  GetTRPOSParamData.Pan := Value;
end;

function TwrpTRPOSParamData.Get_ExpDate: WideString;
begin
  Result := GetTRPOSParamData.ExpDate;
end;

procedure TwrpTRPOSParamData.Set_ExpDate(const Value: WideString);
begin
  GetTRPOSParamData.ExpDate := Value;
end;

function TwrpTRPOSParamData.Get_InvoiceNumber: Integer;
begin
  Result := GetTRPOSParamData.InvoiceNumber;
end;

procedure TwrpTRPOSParamData.Set_InvoiceNumber(Value: Integer);
begin
  GetTRPOSParamData.InvoiceNumber := Value;
end;

function TwrpTRPOSParamData.Get_AuthorizationID: Integer;
begin
  Result := GetTRPOSParamData.AuthorizationID;
end;

procedure TwrpTRPOSParamData.Set_AuthorizationID(Value: Integer);
begin
end;

function TwrpTRPOSParamData.Get_MerchantID: Integer;
begin
  Result := GetTRPOSParamData.MerchantID;
end;

procedure TwrpTRPOSParamData.Set_MerchantID(Value: Integer);
begin
  GetTRPOSParamData.MerchantID := Value;
end;

function TwrpTRPOSParamData.Get_RRN: WideString;
begin
  Result := GetTRPOSParamData.RRN;
end;

procedure TwrpTRPOSParamData.Set_RRN(const Value: WideString);
begin
  GetTRPOSParamData.RRN := Value;
end;

function TwrpTRPOSParamData.Get_CardDataEnc: WideString;
begin
  Result := GetTRPOSParamData.CardDataEnc;
end;

procedure TwrpTRPOSParamData.Set_CardDataEnc(const Value: WideString);
begin
  GetTRPOSParamData.CardDataEnc := Value;
end;

function TwrpGsComScaner.Get_PacketSize: Integer;
begin
  Result := GetGsComScaner.PacketSize;
end;

procedure TwrpGsComScaner.Set_PacketSize(Value: Integer);
begin
  GetGsComScaner.PacketSize := Value;
end;

function TwrpGsComScaner.Get_IntCode: Integer;
begin
  Result := GetGsComScaner.IntCode;
end;

function TwrpFTPClient.GetCurrentDirectory: WideString;
begin
  Result := GetFTPClient.GetCurrentDirectory;
end;

function TwrpFTPClient.SetCurrentDirectory(
  const RemotePath: WideString): WordBool;
begin
  Result := GetFTPClient.SetCurrentDirectory(RemotePath);
end;

{ TwrpGdv_frmAcctBaseForm }

function TwrpGdv_frmAcctBaseForm.GetGdv_frmAcctBaseForm: Tgdv_frmAcctBaseForm;
begin
  Result := GetObject as Tgdv_frmAcctBaseForm;
end;

function TwrpGdv_frmAcctBaseForm.Get_gdvObject: IgsGdvAcctBase;
begin
  Result := GetGdcOLEObject(GetGdv_frmAcctBaseForm.gdvObject) as IgsGdvAcctBase;
end;

function TwrpPLTermv.GetPLTermv: TgsPLTermv;
begin
  Result := GetObject as TgsPLTermv;
end;

procedure TwrpPLTermv.PutInteger(Idx: LongWord; AValue: Integer);
begin
  GetPLTermv.PutInteger(Idx, AValue);
end;

procedure TwrpPLTermv.PutString(Idx: LongWord; const AValue: WideString);
begin
  GetPLTermv.PutString(Idx, AValue);
end;

procedure TwrpPLTermv.PutFloat(Idx: LongWord; AValue: Double);
begin
  GetPLTermv.PutFloat(Idx, AValue);
end;

procedure TwrpPLTermv.PutDateTime(Idx: LongWord; AValue: TDateTime);
begin
  GetPLTermv.PutDateTime(Idx, AValue);
end;

procedure TwrpPLTermv.PutDate(Idx: LongWord; AValue: TDateTime);
begin
  GetPLTermv.PutDate(Idx, AValue);
end;

procedure TwrpPLTermv.PutInt64(Idx: LongWord; AValue: Int64);
begin
  GetPLTermv.PutInt64(Idx, AValue);
end;

procedure TwrpPLTermv.PutAtom(Idx: LongWord; const AValue: WideString);
begin
  GetPLTermv.PutAtom(Idx, AValue);
end;

procedure TwrpPLTermv.PutVariable(Idx: LongWord);
begin
  GetPLTermv.PutVariable(Idx);
end;

function TwrpPLTermv.ReadInteger(Idx: LongWord): Integer;
begin
  Result := GetPLTermv.ReadInteger(Idx);
end;

function TwrpPLTermv.ReadString(Idx: LongWord): WideString;
begin
  Result := GetPLTermv.ReadString(Idx);
end;

function TwrpPLTermv.ReadFloat(Idx: LongWord): Double;
begin
  Result := GetPLTermv.ReadFloat(Idx);
end;

function TwrpPLTermv.ReadDateTime(Idx: LongWord): TDateTime;
begin
  Result := GetPLTermv.ReadDateTime(Idx);
end;

function TwrpPLTermv.ReadDate(Idx: LongWord): TDateTime;
begin
  Result := GetPLTermv.ReadDate(Idx);
end;

function TwrpPLTermv.ReadInt64(Idx: LongWord): Int64;
begin
  Result := GetPLTermv.ReadInt64(Idx);
end;

function TwrpPLTermv.ReadAtom(Idx: LongWord): WideString;
begin
  Result := GetPLTermv.ReadAtom(Idx);
end;

function TwrpPLTermv.ToString(Idx: LongWord): WideString;
begin
  Result := GetPLTermv.ToString(Idx);
end;

function TwrpPLTermv.ToTrimQuotesString(Idx: LongWord): WideString;
begin
  Result := GetPLTermv.ToTrimQuotesString(Idx);
end;

procedure TwrpPLTermv.Reset;
begin
  GetPLTermv.Reset;
end;

function TwrpPLTermv.Get_DataType(Idx: LongWord): Integer;
begin
  Result := GetPLTermv.DataType[Idx];
end;

function TwrpPLTermv.Get_Term(Idx: LongWord): LongWord;
begin
  Result := GetPLTermv.Term[Idx];
end;

function TwrpPLTermv.Get_Size: LongWord;
begin
  Result := GetPLTermv.Size;
end;

class function TwrpPLTermv.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsPLTermv), 'Invalide Delphi class');
  if VarType(Params) in [varSmallint, varInteger] then
    Result := TgsPLTermv.CreateTermv(LongWord(Params))
  else
    raise Exception.Create('Invalid input param!');
end;

function TwrpPLClient.GetPLClient: TgsPLClient;
begin
  Result := GetObject as TgsPLClient;
end;

function TwrpPLClient.Call(const APredicateName: WideString; const AParams: IgsPLTermv): WordBool;
begin
  Result := GetPLClient.Call(APredicateName, InterfaceToObject(AParams) as TgsPLTermv);
end;

function TwrpPLClient.Call2(const AGoal: WideString): WordBool;
begin
  Result := GetPLClient.Call2(AGoal);
end;

function TwrpPLClient.Initialise(const AParams: WideString): WordBool;
begin
  Result := GetPLClient.Initialise(AParams);
end;

function TwrpPLClient.IsInitialised: WordBool;
begin
  Result := GetPLClient.IsInitialised;
end;

function TwrpPLClient.Cleanup: WordBool;
begin
  Result := GetPLClient.Cleanup;
end;

procedure TwrpPLClient.ExtractData(const ADataSet: IgsClientDataSet;
  const APredicateName: WideString; const ATermv: IgsPLTermv);
begin
  GetPLCLient.ExtractData(InterfaceToObject(ADataSet) as TClientDataSet, APredicateName, InterfaceToObject(ATermv) as TgsPLTermv);
end;

function TwrpPLClient.MakePredicatesOfSQLSelect(const ASQL: WideString; const ATr: IgsIBTransaction;
  const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer;
begin
  Result := GetPLClient.MakePredicatesOfSQLSelect(ASQL, InterfaceToObject(ATr) as TIBTRansaction, APredicateName,
    AFileName, AnAppend);
end;

function TwrpPLClient.MakePredicatesOfDataSet(const ADataSet: IgsDataSet; const AFieldList: WideString;
  const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer;
begin
  Result := GetPLClient.MakePredicatesOfDataSet(InterfaceToObject(ADataSet) as TDataSet, AFieldList, APredicateName,
    AFileName, AnAppend);
end;

{*
function TwrpPLClient.MakePredicatesOfObject(const AClassName: WideString; const SubType: WideString;
  const ASubSet: WideString; AParams: OleVariant; const AnExtraConditions: IgsStringList;
  const AFieldList: WideString; const ATr: IgsIBTransaction;
  const APredicateName: WideString; const AFileName: WideString; AnAppend: WordBool): Integer;
begin
  Result := GetPLClient.MakePredicatesOfObject(AClassName, SubType, ASubSet, AParams,
    InterfaceToObject(AnExtraConditions) as TStringList, AFieldList, InterfaceToObject(ATr) as TIBTransaction,
    APredicateName, AFileName, AnAppend);
end;
*}

procedure TwrpPLClient.SavePredicatesToFile(const APredicateName: WideString; const ATermv: IgsPLTermv;
  const AFileName: WideString);
begin
  GetPLClient.SavePredicatesToFile(APredicateName, InterfaceToObject(ATermv) as TgsPLTermv, AFileName);
end;  

procedure TwrpPLClient.Compound(AGoal: LongWord; const AFunctor: WideString; const ATermv: IgsPLTermv);
begin
  GetPLClient.Compound(AGoal, AFunctor, InterfaceToObject(ATermv) as TgsPLTermv);
end;

function TwrpPLClient.LoadScript(AScriptID: Integer): WordBool;
begin
  Result := GetPLClient.LoadScript(AScriptID);
end;

function TwrpPLClient.LoadScriptByName(const AScriptName: WideString): WordBool;
begin
  Result := GetPLClient.LoadScriptByName(AScriptName);
end;

function TwrpPLClient.Get_Debug: WordBool;
begin
  Result := GetPLClient.Debug;
end;

procedure TwrpPLClient.Set_Debug(Value: WordBool);
begin
  GetPLClient.Debug := Value;
end;

function TwrpPLQuery.GetPLQuery: TgsPLQuery;
begin
  Result := GetObject as TgsPLQuery;
end;

procedure TwrpPLQuery.NextSolution;
begin
  GetPLQuery.NextSolution;
end;

procedure TwrpPLQuery.OpenQuery;
begin
  GetPLQuery.OpenQuery;
end;

procedure TwrpPLQuery.Close;
begin
  GetPLQuery.Close;
end;

procedure TwrpPLQuery.Cut;
begin
  GetPLQuery.Cut;
end;

function TwrpPLQuery.Get_PredicateName: WideString;
begin
  Result := GetPLQuery.PredicateName;
end;

procedure TwrpPLQuery.Set_PredicateName(const Value: WideString);
begin
  GetPLQuery.PredicateName := Value;
end;

function TwrpPLQuery.Get_Eof: WordBool;
begin
  Result := GetPLQuery.Eof;
end;

function TwrpPLQuery.Get_Termv: IgsPLTermv;
begin
  Result := GetGdcOLEObject(GetPLQuery.Termv) as IgsPLTermv;
end;

procedure TwrpPLQuery.Set_Termv(const Value: IgsPLTermv);
begin
  GetPLQuery.Termv := InterfaceToObject(Value) as TgsPLTermv;
end;

class function TwrpPLQuery.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Assert(DelphiClass.InheritsFrom(TgsPLQuery), 'Invalide Delphi class');
  Result := TgsPLQuery.Create;
end;

{ TwrpFilesFrame }

procedure TwrpFilesFrame.Cleanup;
begin
  GetFilesFrame.Cleanup;
end;

procedure TwrpFilesFrame.Compare(const S1, S2: Widestring);
begin
  GetFilesFrame.Compare(S1, S2);
end;

procedure TwrpFilesFrame.DisplayDiffs;
begin
  GetFilesFrame.DisplayDiffs;
end;

function TwrpFilesFrame.Get_ShowDiffsOnly: WordBool;
begin
 Result := GetFilesFrame.ShowDiffsOnly;
end;

function TwrpFilesFrame.GetFilesFrame: TFilesFrame;
begin
  Result := GetObject as TFilesFrame;
end;

procedure TwrpFilesFrame.NextClick;
begin
 GetFilesFrame.NextClick;
end;

procedure TwrpFilesFrame.PrevClick;
begin
 GetFilesFrame.PrevClick;
end;

procedure TwrpFilesFrame.Set_ShowDiffsOnly(Value: WordBool);
begin
  GetFilesFrame.ShowDiffsOnly := Value;
end;

procedure TwrpFilesFrame.Setup;
begin
 GetFilesFrame.Setup;
end;

function TwrpFilesFrame.Get_ChangeCount: integer;
begin
  Result := GetFilesFrame.ChangeCount;
end;

procedure TwrpFilesFrame.FindClick(const OwnerForm: IgsCustomForm);
begin
  GetFilesFrame.FindClick(InterfaceToObject(OwnerForm) as TCustomForm);
end;

procedure TwrpFilesFrame.FindNextClick(const OwnerForm: IgsCustomForm);
begin
  GetFilesFrame.FindNextClick(InterfaceToObject(OwnerForm) as TCustomForm);
end;

procedure TwrpFilesFrame.ReplaceClick(const OwnerForm: IgsCustomForm);
begin
  GetFilesFrame.ReplaceClick(InterfaceToObject(OwnerForm) as TCustomForm);
end;

{ TwrpGdWebClientControl }

{$IFDEF WITH_INDY}
function TwrpGdWebClientControl.GetWebClientControl: TgdWebClientControl;
begin
  Result := gdWebClientControl;
end;

function TwrpGdWebClientControl.Get_EmailCount: Integer;
begin
  if GetWebClientControl <> nil then
    Result := GetWebClientControl.EmailCount
  else
    Result := 0;
end;

function TwrpGdWebClientControl.Get_EmailErrorMsg: WideString;
begin
  if GetWebClientControl <> nil then
    Result := GetWebClientControl.EmailErrorMsg
  else
    Result := '';
end;

function TwrpGdWebClientControl.SendEMail(const Host: WideString;
  Port: Integer; const IPSec, Login, Passw, SenderEmail, Recipients,
  Subject, BodyText, FileName: WideString; WipeFile, WIpeDirectory,
  Sync: WordBool; WndHandle, ThreadID: Integer): Integer;
begin
  if GetWebClientControl <> nil then
    Result := GetWebClientControl.SendEmail(Host, Port, IPSec, Login, Passw,
      SenderEmail, Recipients, Subject, BodyText, FileName, WipeFile, WipeDirectory,
      Sync, WndHandle, ThreadID)
  else
    Result := 0;
end;

function TwrpGdWebClientControl.SendEMail2(SMTPKey: Integer;
  const Recipients, Subject, BodyText, FileName: WideString;
  WipeFile, WIpeDirectory, Sync: WordBool; WndHandle,
  ThreadID: Integer): Integer;
begin
  if GetWebClientControl <> nil then
    Result := GetWebClientControl.SendEmail(SMTPKey,
      Recipients, Subject, BodyText, FileName, WipeFile, WipeDirectory,
      Sync, WndHandle, ThreadID)
  else
    Result := 0;
end;

function TwrpGdWebClientControl.SendEMail3(SMTPKey: Integer;
  const Recipients, Subject, BodyText: WideString; ReportKey: Integer;
  const ExportType: WideString; Sync: WordBool; WndHandle,
  ThreadID: Integer): Integer;
begin
  if GetWebClientControl <> nil then
    Result := GetWebClientControl.SendEmail(SMTPKey,
      Recipients, Subject, BodyText, ReportKey, ExportType,
      Sync, WndHandle, ThreadID)
  else
    Result := 0;
end;
{$ENDIF}

function TwrpGDCCreateableForm.Get_SubType: WideString;
begin
  Result := GetGDCCreateableForm.SubType;
end;

{ TwrpGSRAChart }

function TwrpGSRAChart.Get_MaxValue: OleVariant;
begin
  Result := GetRAChart.MaxValue;
end;

function TwrpGSRAChart.Get_MinValue: OleVariant;
begin
  Result := GetRAChart.MinValue;
end;

function TwrpGSRAChart.GetRAChart: TgsRAChart;
begin
  Result := GetObject as TgsRAChart;
end;

procedure TwrpGSRAChart.Set_MaxValue(Value: OleVariant);
begin
  GetRAChart.MaxValue := Value;
end;

procedure TwrpGSRAChart.Set_MinValue(Value: OleVariant);
begin
  GetRAChart.MinValue := Value;
end;

function TwrpGSRAChart.Get_FirstVisibleValue: OleVariant;
begin
  Result := GetRAChart.FirstVisibleValue;
end;

function TwrpGSRAChart.Get_ResourceID: Integer;
begin
  Result := GetRAChart.ResourceID;
end;

function TwrpGSRAChart.Get_Value: OleVariant;
begin
  Result := GetRAChart.Value;
end;

procedure TwrpGSRAChart.Set_FirstVisibleValue(Value: OleVariant);
begin
  GetRAChart.FirstVisibleValue := Value;
end;

procedure TwrpGSRAChart.Set_ResourceID(Value: Integer);
begin
  GetRAChart.ResourceID := Value;
end;

procedure TwrpGSRAChart.Set_Value(Value: OleVariant);
begin
  GetRAChart.Value := Value;
end;

function TwrpGSRAChart.AddResource(AnID: Integer; const AName,
  ASubItems: WideString): Integer;
begin
  Result := GetRAChart.AddResource(AnID, AName, ASubItems);
end;

function TwrpGSRAChart.AddRowHead(const ACaption: WideString;
  AWidth: Integer): Integer;
begin
  Result := GetRAChart.AddRowHead(ACaption, AWidth);
end;

function TwrpGSRAChart.AddRowTail(const ACaption: WideString;
  AWidth: Integer): Integer;
begin
  Result := GetRAChart.AddRowTail(ACaption, AWidth);
end;

function TwrpGSRAChart.AddSubResource(AnID, AParentID: Integer;
  const AName, ASubItems: WideString): Integer;
begin
  Result := GetRAChart.AddSubResource(AnID, AParentID, AName, ASubItems);
end;

function TwrpGSRAChart.AddInterval(AnID: Integer; AResourceID: Integer; AStartValue: OleVariant;
                          AnEndValue: OleVariant; AData: OleVariant; const AComment: WideString;
                          AColor: Integer; AFontColor: Integer; ABorderKind: Integer): Integer;
begin
  Result := GetRAChart.AddInterval(AnID, AResourceID, AStartValue,
    AnEndValue, AData, AComment, AColor, AFontColor, ABorderKind);
end;

function TwrpGSRAChart.Get_IntervalID: Integer;
begin
  Result := GetRAChart.IntervalID;
end;

function TwrpGSRAChart.Get_DragResourceID: Integer;
begin
  Result := GetRAChart.DragResourceID;
end;

function TwrpGSRAChart.Get_DragValue: OleVariant;
begin
  Result := GetRAChart.DragValue;
end;

procedure TwrpGSRAChart.ClearIntervals(AResourceID: Integer);
begin
  GetRAChart.ClearIntervals(AResourceID);
end;

procedure TwrpGSRAChart.ClearResources;
begin
  GetRAChart.ClearResources;
end;

procedure TwrpGSRAChart.DeleteInterval(AResourceID, AnID: Integer);
begin
  GetRAChart.DeleteInterval(AResourceID, AnID);
end;

procedure TwrpGSRAChart.DeleteResource(AnID: Integer);
begin
   GetRAChart.DeleteResource(AnID);
end;

function TwrpGSRAChart.Get_SelectedCount: Integer;
begin
  Result := GetRAChart.SelectedCount;
end;

procedure TwrpGSRAChart.GetSelected(Idx: Integer; out AValue: OleVariant;
  out AResourceID: OleVariant);
var
  V: Variant;
  R: Integer;
begin
  GetRAChart.GetSelected(Idx, V, R);
  AValue := V;
  AResourceID := R;
end;

procedure TwrpGSRAChart.ClearSelected;
begin
  GetRAChart.ClearSelected;
end;

function TwrpGSRAChart.Get_CellWidth: Integer;
begin
  Result := GetRAChart.CellWidth;
end;

function TwrpGSRAChart.Get_RowHeight: Integer;
begin
  Result := GetRAChart.RowHeight;
end;

procedure TwrpGSRAChart.Set_CellWidth(Value: Integer);
begin
  GetRAChart.CellWidth := Value;
end;

procedure TwrpGSRAChart.Set_RowHeight(Value: Integer);
begin
  GetRAChart.RowHeight := Value;
end;

function TwrpGSRAChart.FindIntervalID(AResourceID: Integer;
  AValue: OleVariant): Integer;
begin
  Result := GetRAChart.FindIntervalID(AResourceID, AValue);
end;

procedure TwrpGSRAChart.GetIntervalData(AResourceID, AnIntervalID: Integer;
  out AStartValue, AnEndValue, AData, AComment: OleVariant);
var
  SV, EV, D: Variant;
  C: String;
begin
  GetRAChart.GetIntervalData(AResourceID, AnIntervalID, SV, EV, D, C);
  AStartValue := SV;
  AnEndValue := EV;
  AData := D;
  AComment := C;
end;

function TwrpGSRAChart.Get_DragIntervalID: Integer;
begin
  Result := GetRAChart.DragIntervalID;
end;

function TwrpGSRAChart.Get_ScaleKind: Integer;
begin
  Result := GetRAChart.ScaleKind;
end;

procedure TwrpGSRAChart.Set_ScaleKind(Value: Integer);
begin
  GetRAChart.ScaleKind := Value;
end;

procedure TwrpGSRAChart.ScrollTo(AResourceID: Integer; AValue: OleVariant);
begin
  GetRAChart.ScrollTo(AResourceID, AValue);
end;

initialization
  RegisterGdcOLEClass(TgsIBGrid, TwrpGsIBGrid, ComServer.TypeLib, IID_IgsGsIBGrid);
  RegisterGdcOLEClass(TgsIBLookupComboBox, TwrpIBLookupComboBoxX, ComServer.TypeLib, IID_IgsIBLookupComboBoxX);
  RegisterGdcOLEClass(TxDateEdit, TwrpXDateEdit, ComServer.TypeLib, IID_IgsXDateEdit);
  RegisterGdcOLEClass(TxDateDBEdit, TwrpXDateDBEdit, ComServer.TypeLib, IID_IgsXDateDBEdit);
  RegisterGdcOLEClass(TgsQueryFilter, TwrpGsQueryFilter, ComServer.TypeLib, IID_IgsGsQueryFilter);
  RegisterGdcOLEClass(TgsStorage, TwrpGsStorage, ComServer.TypeLib, IID_IgsGsStorage);
  RegisterGdcOLEClass(TTBDock, TwrpTBDock, ComServer.TypeLib, IID_IgsTBDock);
  RegisterGdcOLEClass(TTBToolbar, TwrpTBToolbar, ComServer.TypeLib, IID_IgsTBToolbar);
  RegisterGdcOLEClass(TgdcBase, TwrpGDCBase, ComServer.TypeLib, IID_IgsGDCBase);
  RegisterGdcOLEClass(TgdClassList, TwrpGDCClassList, ComServer.TypeLib, IID_IgsGDCClassList);
  RegisterGdcOLEClass(TCreateableForm, TwrpCreateableForm, ComServer.TypeLib, IID_IgsCreateableForm);
  RegisterGdcOLEClass(TgdKeyArray, TwrpGDKeyArray, ComServer.TypeLib, IID_IgsGDKeyArray);
  RegisterGdcOLEClass(TgdcInvBaseRemains, TwrpGDCInvBaseRemains, ComServer.TypeLib, IID_IgsGDCInvBaseRemains);

  RegisterGdcOLEClass(TgsDBGrid, TwrpgsDBGrid, ComServer.TypeLib, IID_IgsgsDBGrid);
  RegisterGdcOLEClass(TgsDBReduction, TwrpgsDBReduction, ComServer.TypeLib, IID_IgsgsDBReduction);
  RegisterGdcOLEClass(TxDBCalculatorEdit, TwrpxDBCalculatorEdit, ComServer.TypeLib, IID_IgsxDBCalculatorEdit);
  RegisterGdcOLEClass(TgsDBReductionWizard, TwrpgsDBReductionWizard, ComServer.TypeLib, IID_IgsgsDBReductionWizard);
  RegisterGdcOLEClass(TgdcTree, TwrpGDCTree, ComServer.TypeLib, IID_IgsGDCTree);
  RegisterGdcOLEClass(TgdcDocument, TwrpGDCDocument, ComServer.TypeLib, IID_IgsGDCDocument);
  RegisterGdcOLEClass(TgdcLBRBTree, TwrpGdcLBRBTree, ComServer.TypeLib, IID_IgsGdcLBRBTree);
  RegisterGdcOLEClass(TgdcBaseDocumentType, TwrpGdcBaseDocumentType, ComServer.TypeLib, IID_IgsGdcBaseDocumentType);
  RegisterGdcOLEClass(TgdcHoliday, TwrpGdcHoliday, ComServer.TypeLib, IID_IgsGdcHoliday);
  RegisterGdcOLEClass(TgdcDocumentType, TwrpGdcDocumentType, ComServer.TypeLib, IID_IgsGdcDocumentType);
  RegisterGdcOLEClass(TgdcUserDocumentType, TwrpGdcUserDocumentType, ComServer.TypeLib, IID_IgsGdcUserDocumentType);
  RegisterGdcOLEClass(TgdcUserBaseDocument, TwrpGdcUserBaseDocument, ComServer.TypeLib, IID_IgsGdcUserBaseDocument);
  RegisterGdcOLEClass(TgdcDocumentBranch, TwrpGdcDocumentBranch, ComServer.TypeLib, IID_IgsGdcDocumentBranch);
  RegisterGdcOLEClass(TgdcUserDocument, TwrpGdcUserDocument, ComServer.TypeLib, IID_IgsGdcUserDocument);
  RegisterGdcOLEClass(TgdcUserDocumentLine, TwrpGdcUserDocumentLine, ComServer.TypeLib, IID_IgsGdcUserDocumentLine);
  RegisterGdcOLEClass(TgdcReportGroup, TwrpGdcReportGroup, ComServer.TypeLib, IID_IgsGdcReportGroup);
  RegisterGdcOLEClass(TgdcReport, TwrpGdcReport, ComServer.TypeLib, IID_IgsGdcReport);
  RegisterGdcOLEClass(TgdcTemplate, TwrpGdcTemplate, ComServer.TypeLib, IID_IgsGdcTemplate);
  RegisterGdcOLEClass(TgdcDelphiObject, TwrpGdcDelphiObject, ComServer.TypeLib, IID_IgsGdcDelphiObject);
  RegisterGdcOLEClass(TgdcMacrosGroup, TwrpGdcMacrosGroup, ComServer.TypeLib, IID_IgsGdcMacrosGroup);
  RegisterGdcOLEClass(TgdcMacros, TwrpGdcMacros, ComServer.TypeLib, IID_IgsGdcMacros);
  RegisterGdcOLEClass(TgdcConst, TwrpGdcConst, ComServer.TypeLib, IID_IgsGdcConst);
//  RegisterGdcOLEClass(TgdcConstValue, TwrpGdcConstValue, ComServer.TypeLib, IID_IgsGdcConstValue);
  RegisterGdcOLEClass(TgdcLink, TwrpGdcLink, ComServer.TypeLib, IID_IgsGdcLink);
  RegisterGdcOLEClass(TgdcExplorer, TwrpGdcExplorer, ComServer.TypeLib, IID_IgsGdcExplorer);
//  RegisterGdcOLEClass(TgdcAcctCompanyChart, TwrpGdcAcctCompanyChart, ComServer.TypeLib, IID_IgsGdcAcctCompanyChart);
  RegisterGdcOLEClass(TgdcBaseContact, TwrpGdcBaseContact, ComServer.TypeLib, IID_IgsGdcBaseContact);
  RegisterGdcOLEClass(TgdcCompany, TwrpGdcCompany, ComServer.TypeLib, IID_IgsGdcCompany);
  RegisterGdcOLEClass(TgdcOurCompany, TwrpGdcOurCompany, ComServer.TypeLib, IID_IgsGdcOurCompany);
  RegisterGdcOLEClass(TgdcBaseAcctTransactionEntry, TwrpGdcBaseAcctTransactionEntry, ComServer.TypeLib, IID_IgsGdcBaseAcctTransactionEntry);
//  RegisterGdcOLEClass(TgdcAcctEntryDocument, TwrpGdcAcctEntryDocument, ComServer.TypeLib, IID_IgsGdcAcctEntryDocument);
  RegisterGdcOLEClass(TgdcMetaBase, TwrpGdcMetaBase, ComServer.TypeLib, IID_IgsGdcMetaBase);
  RegisterGdcOLEClass(TgdcField, TwrpGdcField, ComServer.TypeLib, IID_IgsGdcField);
  RegisterGdcOLEClass(TgdcRelation, TwrpGdcRelation, ComServer.TypeLib, IID_IgsGdcRelation);
  RegisterGdcOLEClass(TgdcTableField, TwrpGdcTableField, ComServer.TypeLib, IID_IgsGdcTableField);
  RegisterGdcOLEClass(TgdcTable, TwrpGdcTable, ComServer.TypeLib, IID_IgsGdcTable);
  RegisterGdcOLEClass(TgdcBaseDocumentTable, TwrpGdcBaseDocumentTable, ComServer.TypeLib, IID_IgsGdcBaseDocumentTable);
  RegisterGdcOLEClass(TgdcUser, TwrpGdcUser, ComServer.TypeLib, IID_IgsGdcUser);
  RegisterGdcOLEClass(TgdcUserGroup, TwrpGdcUserGroup, ComServer.TypeLib, IID_IgsGdcUserGroup);
  //RegisterGdcOLEClass(TgdcBaseOperation, TwrpGdcBaseOperation, ComServer.TypeLib, IID_IgsGdcBaseOperation);
  RegisterGdcOLEClass(TgdcGood, TwrpGdcGood, ComServer.TypeLib, IID_IgsGdcGood);
  RegisterGdcOLEClass(TgdcInvBaseDocument, TwrpGdcInvBaseDocument, ComServer.TypeLib, IID_IgsGdcInvBaseDocument);
  RegisterGdcOLEClass(TgdcInvDocument, TwrpGdcInvDocument, ComServer.TypeLib, IID_IgsGdcInvDocument);
  RegisterGdcOLEClass(TgdcInvDocumentLine, TwrpGdcInvDocumentLine, ComServer.TypeLib, IID_IgsGdcInvDocumentLine);
  RegisterGdcOLEClass(TgdcInvDocumentType, TwrpGdcInvDocumentType, ComServer.TypeLib, IID_IgsGdcInvDocumentType);
  RegisterGdcOLEClass(TgdcInvMovement, TwrpGdcInvMovement, ComServer.TypeLib, IID_IgsGdcInvMovement);
  RegisterGdcOLEClass(TgdcInvRemains, TwrpGdcInvRemains, ComServer.TypeLib, IID_IgsGdcInvRemains);
  RegisterGdcOLEClass(TgdcBaseBank, TwrpGdcBaseBank, ComServer.TypeLib, IID_IgsGdcBaseBank);
//  RegisterGdcOLEClass(TgdcBasePayment, TwrpGdcBasePayment, ComServer.TypeLib, IID_IgsGdcBasePayment);
//  RegisterGdcOLEClass(TgdcCheckList, TwrpGdcCheckList, ComServer.TypeLib, IID_IgsGdcCheckList);
  RegisterGdcOLEClass(TgdcAttrUserDefined, TwrpGdcAttrUserDefined, ComServer.TypeLib, IID_IgsGdcAttrUserDefined);
  RegisterGdcOLEClass(TgdcBugBase, TwrpGdcBugBase, ComServer.TypeLib, IID_IgsGdcBugBase);
  RegisterGdcOLEClass(TgdcCurrRate, TwrpGdcCurrRate, ComServer.TypeLib, IID_IgsGdcCurrRate);
  RegisterGdcOLEClass(TgdcInvPriceListType, TwrpGdcInvPriceListType, ComServer.TypeLib, IID_IgsGdcInvPriceListType);
  RegisterGdcOLEClass(TgdcInvPriceListLine, TwrpGdcInvPriceListLine, ComServer.TypeLib, IID_IgsGdcInvPriceListLine);
//  RegisterGdcOLEClass(TgdcCurrCommission, TwrpGdcCurrCommission, ComServer.TypeLib, IID_IgsGdcCurrCommission);
  RegisterGdcOLEClass(TgdcJournal, TwrpGdcJournal, ComServer.TypeLib, IID_IgsGdcJournal);

  RegisterGdcOLEClass(TgsCustomIBGrid, TwrpGsCustomIBGrid, ComServer.TypeLib, IID_IgsGsCustomIBGrid);
  RegisterGdcOLEClass(TFieldAlias, TwrpFieldAlias, ComServer.TypeLib, IID_IgsFieldAlias);
  RegisterGdcOLEClass(TFieldAliases, TwrpFieldAliases, ComServer.TypeLib, IID_IgsFieldAliases);
  RegisterGdcOLEClass(TTBCustomToolbar, TwrpTBCustomToolbar, ComServer.TypeLib, IID_IgsTBCustomToolbar);
  RegisterGdcOLEClass(TTBCustomDockableWindow, TwrpTBCustomDockableWindow, ComServer.TypeLib, IID_IgsTBCustomDockableWindow);
  RegisterGdcOLEClass(TTBToolWindow, TwrpTBToolWindow, ComServer.TypeLib, IID_IgsTBToolWindow);
  RegisterGdcOLEClass(TxCalculatorEdit, TwrpXCalculatorEdit, ComServer.TypeLib, IID_IgsXCalculatorEdit);
  RegisterGdcOLEClass(TTBBackground, TwrpTBBackground, ComServer.TypeLib, IID_IgsTBBackground);
  RegisterGdcOLEClass(TTBCustomItem, TwrpTBCustomItem, ComServer.TypeLib, IID_IgsTBCustomItem);
  RegisterGdcOLEClass(TTBItemContainer, TwrpTBItemContainer, ComServer.TypeLib, IID_IgsTBItemContainer);

  RegisterGdcOLEClass(TLookup, TwrpLookup, ComServer.TypeLib, IID_IgsLookup);
  RegisterGdcOLEClass(TSet, TwrpSet, ComServer.TypeLib, IID_IgsSet);
  RegisterGdcOLEClass(TgsIBColumnEditor, TwrpIBColumnEditor, ComServer.TypeLib, IID_IgsIBColumnEditor);
  RegisterGdcOLEClass(TgsIBColumnEditors, TwrpIBColumnEditors, ComServer.TypeLib, IID_IgsIBColumnEditors);

  RegisterGdcOLEClass(TIBCustomService, TwrpIBCustomService, ComServer.TypeLib, IID_IgsIBCustomService);
  RegisterGdcOLEClass(TIBControlService, TwrpIBControlService, ComServer.TypeLib, IID_IgsIBControlService);
  RegisterGdcOLEClass(TIBControlAndQueryService, TwrpIBControlAndQueryService, ComServer.TypeLib, IID_IgsIBControlAndQueryService);
  RegisterGdcOLEClass(TIBBackupRestoreService, TwrpIBBackupRestoreService, ComServer.TypeLib, IID_IgsIBBackupRestoreService);
  RegisterGdcOLEClass(TIBRestoreService, TwrpIBRestoreService, ComServer.TypeLib, IID_IgsIBRestoreService);
  RegisterGdcOLEClass(TIBBackupService, TwrpIBBackupService, ComServer.TypeLib, IID_IgsIBBackupService);

  RegisterGdcOLEClass(TgdcAcctEntryLine, TwrpgdcAcctEntryLine, ComServer.TypeLib, IID_IgsgdcAcctEntryLine);
  RegisterGdcOLEClass(TGDCAcctSimpleRecord, TwrpGDCAcctSimpleRecord, ComServer.TypeLib, IID_IgsGDCAcctSimpleRecord);
  RegisterGdcOLEClass(TgdcAccount, TwrpGDCAccount, ComServer.TypeLib, IID_IgsGDCAccount);

  RegisterGdcOLEClass(TgdcCreateableForm, TwrpGDCCreateableForm, ComServer.TypeLib, IID_IgsGDCCreateableForm);
  RegisterGdcOLEClass(Tgdc_dlgG, TwrpGDC_dlgG, ComServer.TypeLib, IID_IgsGDC_dlgG);

  RegisterGdcOLEClass(EScrException, TwrpScrException, ComServer.TypeLib, IID_IgsException);
  RegisterGdcOLEClass(Tgdc_frmG, TwrpGdc_frmG, ComServer.TypeLib, IID_IgsGdc_frmG);
  RegisterGdcOLEClass(Tgdc_frmMDH, TwrpGdc_frmMDH, ComServer.TypeLib, IID_IgsGdc_frmMDH);
  RegisterGdcOLEClass(Tgdc_frmMD2H, TwrpGdc_frmMD2H, ComServer.TypeLib, IID_IgsGdc_frmMD2H);
  RegisterGdcOLEClass(Tgdc_frmSGR, TwrpGdc_frmSGR, ComServer.TypeLib, IID_IgsGdc_frmSGR);
  RegisterGdcOLEClass(Tgdv_frmG, TwrpGdv_frmG, ComServer.TypeLib, IID_IgsGdv_frmG);
  RegisterGdcOLEClass(Tgdv_frmAcctBaseForm, TwrpGdv_frmAcctBaseForm, ComServer.TypeLib, IID_IgsGdv_frmAcctBaseForm);
  RegisterGdcOLEClass(Tgdc_frmInvCard, TwrpGdc_frmInvCard, ComServer.TypeLib, IID_IgsGdc_frmInvCard);
  RegisterGdcOLEClass(TGridCheckBox, TwrpGridCheckBox, ComServer.TypeLib, IID_IgsGridCheckBox);
  RegisterGdcOLEClass(TColumnExpand, TwrpColumnExpand, ComServer.TypeLib, IID_IgsColumnExpand);
  RegisterGdcOLEClass(TColumnExpands, TwrpColumnExpands, ComServer.TypeLib, IID_IgsColumnExpands);
  RegisterGdcOLEClass(TCondition, TwrpCondition, ComServer.TypeLib, IID_IgsCondition);
  RegisterGdcOLEClass(TGridConditions, TwrpGridConditions, ComServer.TypeLib, IID_IgsGridConditions);
  RegisterGdcOLEClass(TFilterCondition, TwrpFilterCondition, ComServer.TypeLib, IID_IgsFilterCondition);
  RegisterGdcOLEClass(TFilterConditionList, TwrpFilterConditionList, ComServer.TypeLib, IID_IgsFilterConditionList);
  RegisterGdcOLEClass(TFltFieldData, TwrpFltFieldData, ComServer.TypeLib, IID_IgsFltFieldData);
  RegisterGdcOLEClass(TFilterOrderBy, TwrpFilterOrderBy, ComServer.TypeLib, IID_IgsFilterOrderBy);
  RegisterGdcOLEClass(TFltStringList, TwrpFltStringList, ComServer.TypeLib, IID_IgsFltStringList);
  RegisterGdcOLEClass(TFilterData, TwrpFilterData, ComServer.TypeLib, IID_IgsFilterData);
  RegisterGdcOLEClass(TFilterOrderByList, TwrpFilterOrderByList, ComServer.TypeLib, IID_IgsFilterOrderByList);
  RegisterGdcOLEClass(TgsSQLFilter, TwrpGsSQLFilter, ComServer.TypeLib, IID_IgsGsSQLFilter);
  RegisterGdcOLEClass(TgsStorageItem, TwrpGsStorageItem, ComServer.TypeLib, IID_IgsGsStorageItem);
  RegisterGdcOLEClass(TGsStorageFolder, TwrpGsStorageFolder, ComServer.TypeLib, IID_IgsGsStorageFolder);
  RegisterGdcOLEClass(TGsStorageValue, TwrpGsStorageValue, ComServer.TypeLib, IID_IgsGsStorageValue);
  RegisterGdcOLEClass(TGsRootFolder, TwrpGsRootFolder, ComServer.TypeLib, IID_IgsGsRootFolder);
  RegisterGdcOLEClass(TTBBasicBackground, TwrpTBBasicBackground, ComServer.TypeLib, IID_IgsTBBasicBackground);
  RegisterGdcOLEClass(TTBCustomForm, TwrpTBCustomForm, ComServer.TypeLib, IID_IgsTBCustomForm);
  RegisterGdcOLEClass(TTBRootItem, TwrpTBRootItem, ComServer.TypeLib, IID_IgsTBRootItem);
  RegisterGdcOLEClass(TTBView, TwrpTBView, ComServer.TypeLib, IID_IgsTBView);
  RegisterGdcOLEClass(TTBItemViewer, TwrpTBItemViewer, ComServer.TypeLib, IID_IgsTBItemViewer);
  RegisterGdcOLEClass(TTBToolbarView, TwrpTBToolbarView, ComServer.TypeLib, IID_IgsTBToolbarView);
  RegisterGdcOLEClass(TGdcAggregates, TwrpGdcAggregates, ComServer.TypeLib, IID_IgsGdcAggregates);
  RegisterGdcOLEClass(TGdcAggregate, TwrpGdcAggregate, ComServer.TypeLib, IID_IgsGdcAggregate);
  RegisterGdcOLEClass(TGdcObjectSet, TwrpGdcObjectSet, ComServer.TypeLib, IID_IgsGdcObjectSet);
  RegisterGdcOLEClass(TGdKeyIntAssoc, TwrpGdKeyIntAssoc, ComServer.TypeLib, IID_IgsGdKeyIntAssoc);
  RegisterGdcOLEClass(TGdcBaseTable, TwrpGdcBaseTable, ComServer.TypeLib, IID_IgsGdcBaseTable);
  RegisterGdcOLEClass(TGdcRelationField, TwrpGdcRelationField, ComServer.TypeLib, IID_IgsGdcRelationField);
  RegisterGdcOLEClass(TGdcCustomTable, TwrpGdcCustomTable, ComServer.TypeLib, IID_IgsGdcCustomTable);
  RegisterGdcOLEClass(TAtRelation, TwrpAtRelation, ComServer.TypeLib, IID_IgsAtRelation);
  RegisterGdcOLEClass(TAtRelationFields, TwrpAtRelationFields, ComServer.TypeLib, IID_IgsAtRelationFields);
  RegisterGdcOLEClass(TAtRelationField, TwrpAtRelationField, ComServer.TypeLib, IID_IgsAtRelationField);
  RegisterGdcOLEClass(TAtField, TwrpAtField, ComServer.TypeLib, IID_IgsAtField);
  RegisterGdcOLEClass(TAtForeignKey, TwrpAtForeignKey, ComServer.TypeLib, IID_IgsAtForeignKey);
  RegisterGdcOLEClass(TGsTransaction, TwrpGsTransaction, ComServer.TypeLib, IID_IgsGsTransaction);
  RegisterGdcOLEClass(TTransaction, TwrpTransaction, ComServer.TypeLib, IID_IgsTransaction);
  RegisterGdcOLEClass(TPositionTransaction, TwrpPositionTransaction, ComServer.TypeLib, IID_IgsPositionTransaction);
  RegisterGdcOLEClass(TIBDSBlobStream, TwrpIBDSBlobStream, ComServer.TypeLib, IID_IgsIBDSBlobStream);
  RegisterGdcOLEClass(TEntry, TwrpEntry, ComServer.TypeLib, IID_IgsEntry);
  RegisterGdcOLEClass(TAccount, TwrpAccount, ComServer.TypeLib, IID_IgsAccount);
  RegisterGdcOLEClass(TAnalyze, TwrpAnalyze, ComServer.TypeLib, IID_IgsAnalyze);
  RegisterGdcOLEClass(TGdcInvBasePriceList, TwrpGdcInvBasePriceList, ComServer.TypeLib, IID_IgsGdcInvBasePriceList);

  RegisterGdcOLEClass(TGsIBStorage, TwrpGsIBStorage, ComServer.TypeLib, IID_IgsGsIBStorage);
  RegisterGdcOLEClass(TGsGlobalStorage, TwrpGsGlobalStorage, ComServer.TypeLib, IID_IgsGsGlobalStorage);
  RegisterGdcOLEClass(TGsCompanyStorage, TwrpGsCompanyStorage, ComServer.TypeLib, IID_IgsGsCompanyStorage);
  RegisterGdcOLEClass(TGsUserStorage, TwrpGsUserStorage, ComServer.TypeLib, IID_IgsGsUserStorage);
  RegisterGdcOLEClass(TatContainer, TwrpAtContainer, ComServer.TypeLib, IID_IgsAtContainer);
  RegisterGdcOLEClass(TNumberConvert, TwrpNumberConvert, ComServer.TypeLib, IID_IgsNumberConvert);
  RegisterGdcOLEClass(TgsScanerHook, TwrpGsScanerHook, ComServer.TypeLib, IID_IgsgsScanerHook);
  RegisterGdcOLEClass(TgsCustomDBTreeView, TwrpGsCustomDBTreeView, ComServer.TypeLib, IID_IgsGsCustomDBTreeView);
  RegisterGdcOLEClass(TgdKeyStringAssoc, TwrpGdKeyStringAssoc, ComServer.TypeLib, IID_IgsGdKeyStringAssoc);
  RegisterGdcOLEClass(TTvState, TwrpTvState, ComServer.TypeLib, IID_IgsTvState);
  RegisterGdcOLEClass(TCustomColorComboBox, TwrpCustomColorComboBox, ComServer.TypeLib, IID_IgsCustomColorComboBox);
  RegisterGdcOLEClass(TgsColorComboBox, TwrpColorComboBox, ComServer.TypeLib, IID_IgsColorComboBox);
  RegisterGdcOLEClass(TAtPrimaryKeys, TwrpAtPrimaryKeys, ComServer.TypeLib, IID_IgsAtPrimaryKeys);
  RegisterGdcOLEClass(TAtPrimaryKey, TwrpAtPrimaryKey, ComServer.TypeLib, IID_IgsAtPrimaryKey);
  RegisterGdcOLEClass(TAtForeignKeys, TwrpAtForeignKeys, ComServer.TypeLib, IID_IgsAtForeignKeys);
  RegisterGdcOLEClass(TAtFields, TwrpAtFields, ComServer.TypeLib, IID_IgsAtFields);
  RegisterGdcOLEClass(TAtRelations, TwrpAtRelations, ComServer.TypeLib, IID_IgsAtRelations);

  RegisterGdcOLEClass(Tgdc_dlgTR, TwrpGdc_dlgTR, ComServer.TypeLib, IID_IgsGdc_dlgTR);
  RegisterGdcOLEClass(Tgdc_dlgHGR, TwrpGdc_dlgHGR, ComServer.TypeLib, IID_IgsGdc_dlgHGR);
  RegisterGdcOLEClass(TdlgInvDocument, TwrpDlgInvDocument, ComServer.TypeLib, IID_IgsDlgInvDocument);

  RegisterGdcOLEClass(Tgdc_dlgUserComplexDocument, Twrpgdc_dlgUserComplexDocument, ComServer.TypeLib, IID_Igsgdc_dlgUserComplexDocument);

  RegisterGdcOLEClass(TBtnEdit, TwrpBtnEdit, ComServer.TypeLib, IID_IgsBtnEdit);
  RegisterGdcOLEClass(TgdcTaxResult, TwrpGdcTaxResult, ComServer.TypeLib, IID_IgsGdcTaxResult);
  RegisterGdcOLEClass(TFieldsCallList, TwrpFieldsCallList, ComServer.TypeLib, IID_IgsFieldsCallList);
  RegisterGdcOLEClass(TQueryFilterGDC, TwrpQueryFilterGDC, ComServer.TypeLib, IID_IgsQueryFilterGDC);
  RegisterGdcOLEClass(TatDatabase, TwrpAtDatabase, ComServer.TypeLib, IID_IgsAtDatabase);
  RegisterGdcOLEClass(TgsComboBoxAttrSet, TwrpgsComboBoxAttrSet, ComServer.TypeLib, IID_IgsComboBoxAttrSet);
  RegisterGdcOLEClass(TGdcSetting, TwrpGdcSetting, ComServer.TypeLib, IID_IgsGdcSetting);
  RegisterGdcOLEClass(TGdcSettingPos, TwrpGdcSettingPos, ComServer.TypeLib, IID_IgsGdcSettingPos);
  RegisterGdcOLEClass(TgdcSettingStorage, TwrpGdcSettingStorage, ComServer.TypeLib, IID_IgsGdcSettingStorage);
  RegisterGdcOLEClass(TgdcAcctQuantity, TwrpGdcAcctQuantity, ComServer.TypeLib, IID_IgsGdcAcctQuantity);
  RegisterGdcOLEClass(TgdcAcctBaseEntryRegister, TwrpGdcAcctBaseEntryRegister, ComServer.TypeLib, IID_IgsGdcAcctBaseEntryRegister);
  RegisterGdcOLEClass(TgdcAcctViewEntryRegister, TwrpGdcAcctViewEntryRegister, ComServer.TypeLib, IID_IgsGdcAcctViewEntryRegister);

  RegisterGdcOLEClass(TgdcBaseFile, TwrpGdcBaseFile, ComServer.TypeLib, IID_IgsGdcBaseFile);
  RegisterGdcOLEClass(TgdcFile, TwrpGdcFile, ComServer.TypeLib, IID_IgsGdcFile);
  RegisterGdcOLEClass(TgdcFileFolder, TwrpGdcFileFolder, ComServer.TypeLib, IID_IgsGdcFileFolder);
  RegisterGdcOLEClass(TGdEnumComboBox, TwrpGdEnumComboBox, ComServer.TypeLib, IID_IgsGdEnumComboBox);
  RegisterGdcOLEClass(TCustomDBGrid, TwrpCustomDBGrid, ComServer.TypeLib, IID_IgsCustomDBGrid);

  RegisterGdcOLEClass(TgsColumn, TwrpGsColumn, ComServer.TypeLib, IID_IgsGsColumn);
  RegisterGdcOLEClass(TgsColumns, TwrpGsColumns, ComServer.TypeLib, IID_IgsGsColumns);

  RegisterGdcOLEClass(TAtSQLSetup, TwrpAtSQLSetup, ComServer.TypeLib, IID_IgsAtSQLSetup);
  RegisterGdcOLEClass(TAtIgnore, TwrpAtIgnore, ComServer.TypeLib, IID_IgsAtIgnore);
  RegisterGdcOLEClass(TAtIgnores, TwrpAtIgnores, ComServer.TypeLib, IID_IgsAtIgnores);

  RegisterGdcOLEClass(TGsRect, TwrpGsRect, ComServer.TypeLib, IID_IgsGsRect);
  RegisterGdcOLEClass(TGsPoint, TwrpGsPoint, ComServer.TypeLib, IID_IgsGsPoint);

  RegisterGdcOLEClass(TGdKeyDuplArray, TwrpGdKeyDuplArray, ComServer.TypeLib, IID_IgsGdKeyDuplArray);
  RegisterGdcOLEClass(TGdKeyObjectAssoc, TwrpGdKeyObjectAssoc, ComServer.TypeLib, IID_IgsGdKeyObjectAssoc);
  RegisterGdcOLEClass(TGdKeyIntArrayAssoc, TwrpGdKeyIntArrayAssoc, ComServer.TypeLib, IID_IgsGdKeyIntArrayAssoc);
  RegisterGdcOLEClass(TGdKeyIntAndStrAssoc, TwrpGdKeyIntAndStrAssoc, ComServer.TypeLib, IID_IgsGdKeyIntAndStrAssoc);
  RegisterGdcOLEClass(TGdc_frmInvSelectedGoods, TwrpGdc_frmInvSelectedGoods, ComServer.TypeLib, IID_IgsGdc_frmInvSelectedGoods);
  RegisterGdcOLEClass(TTBControlItem, TwrpTBControlItem, ComServer.TypeLib, IID_IgsTBControlItem);
  RegisterGdcOLEClass(TgdcInvMovementContactOption, TwrpGdcInvMovementContactOption, ComServer.TypeLib, IID_IgsGdcInvMovementContactOption);
  RegisterGdcOLEClass(TxFoCal, TwrpxFoCal, ComServer.TypeLib, IID_IgsxFoCal);
  RegisterGdcOLEClass(TdlgSelectDocument, TwrpGdc_dlgSelectDocument, ComServer.TypeLib, IID_IgsdlgSelectDocument);

  {$IFDEF MODEM}
  RegisterGdcOLEClass(TgsModem, TwrpGsModem, ComServer.TypeLib, IID_IgsModem);
  {$ENDIF}

  RegisterGdcOLEClass(TgsComScaner, TwrpGsComScaner, ComServer.TypeLib, IID_IgsgsComScaner);

  RegisterGdcOLEClass(TgdcStreamSaver, TwrpStreamSaver, ComServer.TypeLib, IID_IgsStreamSaver);

  RegisterGdcOLEClass(TgdvAcctBase, TwrpGdvAcctBase, ComServer.TypeLib, IID_IgsGdvAcctBase);
  RegisterGdcOLEClass(TgdvAcctAccReview, TwrpGdvAcctAccReview, ComServer.TypeLib, IID_IgsGdvAcctAccReview);
  RegisterGdcOLEClass(TgdvAcctAccCard, TwrpGdvAcctAccCard, ComServer.TypeLib, IID_IgsGdvAcctAccCard);
  RegisterGdcOLEClass(TgdvAcctLedger, TwrpGdvAcctLedger, ComServer.TypeLib, IID_IgsGdvAcctLedger);
  RegisterGdcOLEClass(TgdvAcctGeneralLedger, TwrpGdvAcctGeneralLedger, ComServer.TypeLib, IID_IgsGdvAcctGeneralLedger);
  RegisterGdcOLEClass(TgdvAcctCirculationList, TwrpGdvAcctCirculationList, ComServer.TypeLib, IID_IgsGdvAcctCirculationList);

  RegisterGdcOLEClass(TgsParamList, TwrpGsParamList, ComServer.TypeLib, IID_IgsParamList);
  RegisterGdcOLEClass(TgsParamData, TwrpGsParamData, ComServer.TypeLib, IID_IgsParamData);

  RegisterGdcOLEClass(TfrmGedeminMain, TwrpGsFrmGedeminMain, ComServer.TypeLib, IID_IgsFrmGedeminMain);
  {$IFDEF WITH_INDY}
  RegisterGdcOLEClass(TgdWebServerControl, TwrpGdWebServerControl, ComServer.TypeLib, IID_IgdWebServerControl);
  RegisterGdcOLEClass(TgdWebClientControl, TwrpGdWebClientControl, ComServer.TypeLib, IID_IgdWebClientControl);
  {$ENDIF}
  RegisterGdcOLEClass(TgsFTPClient, TwrpFTPClient, ComServer.TypeLib, IID_IgsFTPClient);
  RegisterGdcOLEClass(TgsTRPOSClient, TwrpTRPOSClient, ComServer.TypeLib, IID_IgsTRPOSClient);
  RegisterGdcOLEClass(TgsTRPOSOutPutData, TwrpTRPOSOutPutData, ComServer.TypeLib, IID_IgsTRPOSOutPutData);
  RegisterGdcOLEClass(TgsTRPOSParamData, TwrpTRPOSParamData, ComServer.TypeLib, IID_IgsTRPOSParamData);
  RegisterGdcOLEClass(TgsPLTermv, TwrpPLTermv, ComServer.TypeLib, IID_IgsPLTermv);
  RegisterGdcOLEClass(TgsPLClient, TwrpPLClient, ComServer.TypeLib, IID_IgsPLClient);
  RegisterGdcOLEClass(TgsPLQuery, TwrpPLQuery, ComServer.TypeLib, IID_IgsPLQuery);
  RegisterGdcOLEClass(TFilesFrame, TwrpFilesFrame, ComServer.TypeLib, IID_IgsFilesFrame);
  RegisterGdcOLEClass(TgsRAChart, TwrpGSRAChart, ComServer.TypeLib, IID_IgsRAChart);
end.
