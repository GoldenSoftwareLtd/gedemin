
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcAcctEntryRegister.pas

  Abstract

    Business class. Class that holds all
    information about transactions and
    generates accounting records.

  Author

    Romanovski Denis (23-11-2001)

  Revisions history

    Initial  23-11-2001  Dennis  Initial version.
             13-03-2002  Julie   Changed alias for main table in all scripts
--}


unit gdcAcctEntryRegister;

interface

uses
  Classes, Contnrs, SysUtils,
  DB, IBSQL, Windows, IBDataBase, Dialogs, 
  gd_createable_form, Forms, gdcConstants,
  gdcBase, gdcClasses, gdcAcctTransaction, gdcBaseInterface;

const
  ByDocument = 'ByDocument';
  ByEntry    = 'ByEntry';

  DefaultTransactionKey = 807001;
  DefaultDocumentTypeKey = 806001;
  DefaultEntryKey = 807100;

  erScriptName = 'EntryScript%s_%d';

{$IFDEF DEBUGMOVE}
  DeleteOldEntry: LongWord = 0;
  InsertEntryLine: LongWord = 0;
  PostEntryLine: LongWord = 0;
  OpenEntry: LongWord = 0;
  ExecuteFunction: LongWord = 0;
  OpenTypeEntry: LongWord = 0;
  AllEntryTime: LongWord = 0;
  MakeBalance: LongWord = 0;
  DeleteZero: LongWord = 0;
{$ENDIF}

type
  TEntryGroup = (egAll, egDocument);

  TgdcAcctQuantity = class;

  TgdcAcctBaseEntryRegister = class(TgdcBase)
  private
    FRecordKey: Integer;
    FRecordAdded: Boolean;
    FDocument: TgdcDocument;
    FDescription: String;
    FgdcQuantity: TgdcAcctQuantity;
    FTrRecordKey: Integer;
    {$IFDEF DEBUGMOVE}
    FT: LongWord;
    FTI: LongWord;
    {$ENDIF}

    function GetRecordKey: Integer;
    procedure SetDocument(const Value: TgdcDocument);

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;
    function GetRefreshSQLText: String; override;

    function GetDocument: TgdcDocument; virtual;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;
    procedure DoAfterCancel; override;
    procedure DoAfterInsert; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    procedure DoBeforePost; override;

    procedure CreateFields; override;

    procedure InternalDeleteRecord(Qry: TIBSQL; Buff: Pointer); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    procedure CreateReversalEntry(const AReversalEntryDate: TDateTime; const ATransactionKey: TID; const AllDocEntry: Boolean);

    property RecordKey: Integer read GetRecordKey;
    property Document: TgdcDocument read GetDocument write SetDocument;
    property Description: String read FDescription write FDescription;
    property gdcQuantity: TgdcAcctQuantity read FgdcQuantity;
  end;

  TgdcAcctEntryRegister = class(TgdcAcctBaseEntryRegister)
  private
    FCurrNCUKey: Integer;
    FEntrySQL, FRecordSQL, FEntryDocumentSQL: TIBSQL;

    function GetCurrNCUKey: Integer;

  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure DoBeforePost; override;
    procedure DoBeforeOpen; override;

    procedure DoAfterPost; override;

    procedure CustomInsert(Buff: Pointer); override;
    {$IFDEF DEBUGMOVE}
    procedure DoAfterInsert; override;
    procedure DoBeforeInsert; override;
    {$ENDIF}
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
   {$IFDEF DEBUGMOVE}
    procedure Post; override;
    {$ENDIF}

    procedure CreateEntry(const EmptyEntry: Boolean = False);
  end;

  TgdcAcctComplexRecord = class;

  TgdcAcctViewEntryRegister = class(TgdcAcctBaseEntryRegister)
  private
    FEntryGroup: TEntryGroup;
    procedure SetEntryGroup(const Value: TEntryGroup);
    procedure DataTransfer(gdcAcctComplexRecord: TgdcAcctComplexRecord);
  protected
    function GetSelectClause: String; override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure DoBeforePost; override;

    function GetDocument: TgdcDocument; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetSubSetList: String; override;

    function GetCurrRecordClass: TgdcFullClass; override;
    function CreateDialog(const ADlgClassName: String = ''): Boolean; override;
    function CopyDialog: Boolean; override;
    function EditDialog(const ADlgClassName: String = ''): Boolean; override;

    property EntryGroup: TEntryGroup read FEntryGroup write SetEntryGroup;
  end;

  TCrackGdcBase = class(TgdcBase);

  TgdcAcctEntryLine = class(TgdcBase)
  private
    FRecordKey: Integer;
    FAccountPart: String;
    FgdcQuantity: TgdcAcctQuantity;
    function Get_gdcQuantity: TgdcAcctQuantity;

    procedure OnQuantityPost(DataSet: TDataSet);
    procedure OnQuantityDelete(DataSet: TDataSet);
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoBeforeOpen; override;
    procedure DoBeforePost; override;
    procedure DoAfterCancel; override;
    procedure DoAfterPost; override;
    procedure CreateFields; override;
  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    procedure DataEvent(Event: TDataEvent; Info: Longint); override;

    property AccountPart: String read FAccountPart write FAccountPart;
    property RecordKey: Integer read FRecordKey write FRecordKey;
    property gdcQuantity: TgdcAcctQuantity read Get_gdcQuantity;
  end;

  TgdcAcctSimpleRecord = class(TgdcBase)
  private
    FDocument: TgdcDocument;
    FDebitEntryLine: TgdcAcctEntryLine;
    FCreditEntryLine: TgdcAcctEntryLine;
    FTransactionKey: Integer;
    FCurrNCUKey: Integer;
    FAmountNCU, FAmountCurr: Currency;

    function GetCurrNCUKey: Integer;
    procedure SetupEntryLine;
    procedure SetEntryModified;

  protected
    procedure CreateFields; override;
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomModify(Buff: Pointer); override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetDocument: TgdcDocument;

    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure DoBeforeCancel; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforeEdit; override;

    procedure DoAfterTransactionEnd(Sender: TObject); override;

//    function CreateDialogForm: TCreateableForm; override;

    function GetNotCopyField: String; override;

  public
    //class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    constructor Create(AnOwner: TComponent); override;

    function GetDialogDefaultsFields: String; override;
    function Copy(const AFields: String; AValues: Variant; const ACopyDetail: Boolean = False;
      const APost: Boolean = True; const AnAppend: Boolean = False): Boolean; override;
    function CopyObject(const ACopyDetailObjects: Boolean = False;
      const AShowEditDialog: Boolean = False): Boolean; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    property DebitEntryLine: TgdcAcctEntryLine read FDebitEntryLine;
    property CreditEntryLine: TgdcAcctEntryLine read FCreditEntryLine;
    property Document: TgdcDocument read GetDocument write FDocument;
    property TransactionKey: Integer read FTransactionKey write FTransactionKey;
  end;

  TAcctEntryLines = class(TObjectList)
  private
    function GetLines(Index: Integer): TgdcAcctEntryLine;
  public
    property Lines[Index: Integer]: TgdcAcctEntryLine read GetLines; default;
  end;

  TgdcAcctComplexRecord = class(TgdcBase)
  private
    FEntryLines: TAcctEntryLines;
    FTransactionKey: Integer;
    FDocument: TgdcDocument;
    FCurrNCUKey: Integer;

    function GetEntryLines: TAcctEntryLines;
    function GetDocument: TgdcDocument;

    procedure OnAfterLinePost(DataSet: TDataSet);
    procedure OnAfterLineDelete(DataSet: TDataSet);
    procedure OnAfterLineEdit(DataSet: TDataSet);
    procedure OnAfterLineInsert(DataSet: TDataSet);

    function GetCurrNCUKey: Integer;
  protected
    procedure CreateFields; override;
    procedure DoAfterScroll; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure DoBeforeCancel; override;
    procedure _DoOnNewRecord; override;

    procedure DoAfterTransactionEnd(Sender: TObject); override;
    function GetNotCopyField: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    function GetDialogDefaultsFields: String; override;
    function AppendLine: TgdcAcctEntryLine;
    function DeleteLine(Id: Integer): Boolean;
    function Copy(const AFields: String; AValues: Variant; const ACopyDetail: Boolean = False;
      const APost: Boolean = True; const AnAppend: Boolean = False): Boolean; override;
    function CopyObject(const ACopyDetailObjects: Boolean = False;
      const AShowEditDialog: Boolean = False): Boolean; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    property EntryLines: TAcctEntryLines read GetEntryLines;
    property Document: TgdcDocument read GetDocument write FDocument;
    property TransactionKey: Integer read FTransactionKey write FTransactionKey;
  end;

  TgdcAcctQuantity = class(TgdcBase)
  protected
    function  CheckTheSameStatement: String; override;

    function  GetSelectClause: String; override;
    function  GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;
  end;


procedure Register;

implementation

uses
  gd_i_ScriptFactory, gdcOLEClassList, gd_ClassList, gdc_frmTransaction_unit,
  at_sql_setup, gdcAcctDocument, gdc_acct_dlgEntry_unit, gd_security, at_classes,
  gd_directories_const, IBCustomDataSet
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
//  gdc_createable_form;

procedure Register;
begin
  RegisterComponents('gdcAcctAccount', [TgdcAcctEntryRegister, TgdcAcctViewEntryRegister, TgdcAcctQuantity]);
end;

{ TgdcAcctBaseEntryRegister }
constructor TgdcAcctBaseEntryRegister.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];

  FRecordKey := -1;

  FgdcQuantity := TgdcAcctQuantity.Create(Self);
  FgdcQuantity.Transaction := Self.Transaction;
  FgdcQuantity.SubSet := ByEntry;
  FgdcQuantity.MasterSource := TDataSource.Create(Self);
  FgdcQuantity.MasterSource.DataSet := Self;
  FgdcQuantity.MasterField := 'id';
  FgdcQuantity.DetailField := 'entrykey';
  FgdcQuantity.CachedUpdates := True;
end;

procedure TgdcAcctBaseEntryRegister.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  for i := 0 to FieldCount - 1 do
    Fields[i].Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTBASEENTRYREGISTER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FieldByName('DOCUMENTTYPEKEY').AsInteger <> DefaultDocumentTypeKey then
    CustomExecQuery('DELETE FROM ac_record WHERE ID = :OLD_recordkey', Buff)
  else
    CustomExecQuery('DELETE FROM gd_document WHERE id = :OLD_documentkey', Buff);
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTBASEENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}



    if not FRecordAdded then
    begin
      if FieldByName('trrecordkey').IsNull then
        FieldByName('trrecordkey').AsInteger := FTrRecordKey;

      CustomExecQuery(
        'INSERT INTO ac_record ( ' +
        '  id, trrecordkey, transactionkey, recorddate, documentkey, masterdockey, companykey, afull, '  +
        '  achag, aview, disabled, reserved, description) ' +
        ' VALUES (' + FieldByName('recordkey').AsString + ', :NEW_trrecordkey, ' +
        '   :NEW_transactionkey, :NEW_recorddate, :NEW_documentkey, :NEW_masterdockey, :NEW_companykey, ' +
        '   :NEW_afull, :NEW_achag, :NEW_aview, :NEW_disabled, :NEW_reserved, :NEW_description) ', Buff);
      FRecordAdded := True;
    end;

    if not Assigned(Document) and (sLoadFromStream in Self.BaseState) then
      exit;      
    CustomExecQuery(
      'INSERT INTO ac_entry ( ' +
      '  (id, recordkey, accountkey, accountpart, debitncu, debitcurr, debiteq, ' +
      '    creditncu, creditcurr, crediteq, currkey, entrydate) ' +
      'VALUES (:NEW_id, :NEW_recordkey, :NEW_accountkey, :NEW_accountpart, :NEW_debitncu, :NEW_debitcurr, :NEW_debiteq, ' +
      '    :NEW_creditncu, :NEW_creditcurr, :NEW_crediteq, :NEW_currkey, :NEW_recorddate) ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTBASEENTRYREGISTER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if not (sLoadFromStream in BaseState) and not Assigned(Document) then
    raise EgdcIBError.Create('Не задан документ для формирования проводок');


  inherited;

  if RecordKey <= 0 then
    FRecordKey := GetNextID;
  FieldByName(fnrecordkey).AsInteger := RecordKey;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctBaseEntryRegister.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTBASEENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not HasSubSet('ByID') then
    Result := ' FROM ac_record z JOIN ac_entry r ON z.id = r.recordkey ' +
              '   JOIN gd_document doc ON z.documentkey = doc.id ' +
              '   JOIN ac_account c ON r.accountkey = c.id ' +
              '   JOIN gd_curr cur ON r.currkey = cur.id '
  else
    Result := ' FROM ac_record z LEFT JOIN ac_entry r ON r.recordkey = -1 ' +
              '   LEFT JOIN gd_document doc ON z.documentkey = doc.id ' +
              '   LEFT JOIN ac_account c ON r.accountkey = c.id ' +
              '   LEFT JOIN gd_curr cur ON r.currkey = cur.id ';

  FSQLSetup.Ignores.AddAliasName('C');
  FSQLSetup.Ignores.AddAliasName('DOC');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctBaseEntryRegister.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcAcctBaseEntryRegister.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcAcctBaseEntryRegister.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AC_RECORD';
end;

function TgdcAcctBaseEntryRegister.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCACCTBASEENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ORDER BY r.recordkey, r.accountpart DESC '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctBaseEntryRegister.GetRecordKey: Integer;
begin
  if not Active or FieldByName('recordkey').IsNull then
    Result := FRecordKey
  else
    Result := FieldByName('recordkey').AsInteger;
end;

function TgdcAcctBaseEntryRegister.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTBASEENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT ' +
    ' r.id, '  +
    ' c.alias, ' +
    ' c.name, ' +
    ' r.recordkey, '  +
    ' r.accountkey, '  +
    ' r.accountpart, '  +
    ' r.debitncu, '  +
    ' r.debitcurr, '  +
    ' r.debiteq, '  +
    ' r.creditncu, '  +
    ' r.creditcurr, '  +
    ' r.crediteq, '  +
    ' r.currkey, '  +
    ' r.entrydate, ' +
    ' cur.shortname, ' +
    ' z.trrecordkey, '  +
    ' z.transactionkey, '  +
    ' z.recorddate, '  +
    ' z.documentkey, '  +
    ' z.masterdockey, ' +
    ' z.companykey, '  +
    ' z.afull, '  +
    ' z.achag, '  +
    ' z.aview, '  +
    ' z.disabled, '  +
    ' z.reserved, '  +
    ' z.debitncu as rdebitncu, ' +
    ' z.debitcurr as rdebitcurr, ' +
    ' z.creditncu as rcreditncu, ' +
    ' z.creditcurr as rcreditcurr, ' +
    ' z.description, ' + 
    ' doc.number, ' +
    ' doc.documenttypekey, ' +
    ' doc.creationdate, ' +
    ' doc.editiondate, ' +
    ' doc.documentdate ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctBaseEntryRegister.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ByDocument + ';' + ByTransaction + ';';
end;

procedure TgdcAcctBaseEntryRegister.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if not HasSubSet('ByID') then
    S.Add(' z.companykey + 0 in (' + IBLogin.HoldingList + ')');

  if HasSubSet(ByDocument) then
    S.Add('z.documentkey = :documentkey');
  if HasSubSet(ByTransaction) then
    S.Add('z.transactionkey = :transactionkey');

end;

procedure TgdcAcctBaseEntryRegister.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FRecordKey := -1;
  FRecordAdded := False;
  FTrRecordKey := - 1;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctBaseEntryRegister.GetRefreshSQLText: String;
begin
  Result := inherited GetRefreshSQLText;
end;

destructor TgdcAcctBaseEntryRegister.Destroy;
begin
  inherited;
end;

procedure TgdcAcctBaseEntryRegister.SetDocument(const Value: TgdcDocument);
begin
  if FDocument <> Value then
  begin
    FDocument := Value;

    if Assigned(FDocument) then
    begin
      Database := FDocument.Database;
      Transaction := FDocument.Transaction;
    end;
  end;
end;


function TgdcAcctBaseEntryRegister.GetDocument: TgdcDocument;
begin
  Result := FDocument;
end;

class function TgdcAcctBaseEntryRegister.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTransaction';
end;

procedure TgdcAcctBaseEntryRegister.DoAfterInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYDOAFTERINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'DOAFTERINSERT', KEYDOAFTERINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
//  FgdcQuantity.CachedUpdates := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'DOAFTERINSERT', KEYDOAFTERINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if FgdcQuantity.CachedUpdates then
    FgdcQuantity.ApplyUpdates;

//  FgdcQuantity.CachedUpdates := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.DoAfterCancel;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYDOAFTERCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'DOAFTERCANCEL', KEYDOAFTERCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if FgdcQuantity.CachedUpdates then
  begin
    FgdcQuantity.CancelUpdates;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'DOAFTERCANCEL', KEYDOAFTERCANCEL);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.InternalDeleteRecord(Qry: TIBSQL;
  Buff: Pointer);
var
  RC: TID;
  I: Integer;
begin
  RC := FieldByName('recordkey').AsInteger;
  inherited;
  for I := 0 to FRecordCount - 1 do
  begin
    try
      FPeekBuffer := FBufferCache + _RecordBufferSize * I;

      if PRecordData(FPeekBuffer)^.rdUpdateStatus <> usDeleted then
      begin
        if FieldByName('recordkey').AsInteger = RC then
        begin
          PRecordData(FPeekBuffer)^.rdUpdateStatus := usDeleted;
        end;
      end;
    finally
      FPeekBuffer := nil;
    end;
  end;
end;

procedure TgdcAcctBaseEntryRegister.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASEENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASEENTRYREGISTER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASEENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASEENTRYREGISTER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASEENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if FieldByName('recordkey').IsNull then
    FieldByName('recordkey').AsInteger := RecordKey;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASEENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASEENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctBaseEntryRegister.CreateReversalEntry(
  const AReversalEntryDate: TDateTime; const ATransactionKey: TID; const AllDocEntry: Boolean);
var
  Transaction: TIBTransaction;
  ibsqlInsertDocument, ibsqlInsertEntryRecord, ibsqlInsertEntry: TIBSQL;
  AcEntryRelation: TatRelation;
  FieldCounter: Integer;
  TRRecordKey, CompanyKey, ReversalDocumentKey, ReversalRecordKey, CurrentRecordKey: TID;
  TempString: String;
  CurrentEntry: TgdcAcctEntryRegister;

  procedure InsertEntryPart(const AEntryPart: String);
  var
    Counter: Integer;
  begin
    // заполнение части сторнирующей проводки
    ibsqlInsertEntry.Close;
    ibsqlInsertEntry.ParamByName('RECORDKEY').AsInteger := ReversalRecordKey;
    ibsqlInsertEntry.ParamByName('ENTRYDATE').AsDateTime := AReversalEntryDate;
    ibsqlInsertEntry.ParamByName('TRANSACTIONKEY').AsInteger := ATransactionKey;
    ibsqlInsertEntry.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
    ibsqlInsertEntry.ParamByName('ACCOUNTKEY').AsInteger := CurrentEntry.FieldByName('ACCOUNTKEY').AsInteger;
    ibsqlInsertEntry.ParamByName('ACCOUNTPART').AsString := AEntryPart;
    ibsqlInsertEntry.ParamByName('DEBITNCU').AsCurrency := - CurrentEntry.FieldByName('DEBITNCU').AsCurrency;
    ibsqlInsertEntry.ParamByName('DEBITCURR').AsCurrency := - CurrentEntry.FieldByName('DEBITCURR').AsCurrency;
    ibsqlInsertEntry.ParamByName('DEBITEQ').AsCurrency := - CurrentEntry.FieldByName('DEBITEQ').AsCurrency;
    ibsqlInsertEntry.ParamByName('CREDITNCU').AsCurrency := - CurrentEntry.FieldByName('CREDITNCU').AsCurrency;
    ibsqlInsertEntry.ParamByName('CREDITCURR').AsCurrency := - CurrentEntry.FieldByName('CREDITCURR').AsCurrency;
    ibsqlInsertEntry.ParamByName('CREDITEQ').AsCurrency := - CurrentEntry.FieldByName('CREDITEQ').AsCurrency;
    ibsqlInsertEntry.ParamByName('CURRKEY').AsVariant := CurrentEntry.FieldByName('CURRKEY').AsVariant;
    // Присвоение значения аналитик части сторнирующей проводки
    for Counter := 0 to AcEntryRelation.RelationFields.Count - 1 do
      if AcEntryRelation.RelationFields.Items[Counter].IsUserDefined then
      begin
        TempString := AcEntryRelation.RelationFields.Items[Counter].FieldName;
        ibsqlInsertEntry.ParamByName(TempString).AsVariant := CurrentEntry.FieldByName(TempString).AsVariant;
      end;
    ibsqlInsertEntry.ExecQuery;
  end;

begin
  Transaction := TIBTransaction.Create(nil);
  ibsqlInsertDocument := TIBSQL.Create(nil);
  ibsqlInsertEntryRecord := TIBSQL.Create(nil);
  ibsqlInsertEntry := TIBSQL.Create(nil);
  try
    Transaction.DefaultDatabase := gdcBaseManager.Database;
    Transaction.StartTransaction;
    try
      // Запрос на добавление документа
      ibsqlInsertDocument.Transaction := Transaction;
      ibsqlInsertDocument.SQL.Text :=
        ' INSERT INTO gd_document ' +
        '   (id, documentdate, documenttypekey, transactionkey, number, ' +
        '    currkey, aview, achag, afull, companykey, creatorkey, editorkey, creationdate) ' +
        ' VALUES ' +
        '   (:id, :documentdate, :documenttypekey, :transactionkey, :number, ' +
        '    :currkey, -1, -1, -1, :companykey, :creatorkey, :creatorkey, :creationdate) ';

      // Запрос на добавление шапки проводки
      ibsqlInsertEntryRecord.Transaction := Transaction;
      ibsqlInsertEntryRecord.SQL.Text :=
        ' INSERT INTO ac_record ' +
        '   (id, recorddate, transactionkey, trrecordkey, documentkey, masterdockey, companykey, description) ' +
        ' VALUES ' +
        '   (:recordkey, :recorddate, :transactionkey, :trrecordkey, :documentkey, :documentkey, :companykey, :description) ';
      ibsqlInsertEntryRecord.Prepare;

      AcEntryRelation := atDatabase.Relations.ByRelationName('AC_ENTRY');
      // Запрос на добавление части проводки
      ibsqlInsertEntry.Transaction := Transaction;
      TempString :=
        ' INSERT INTO ac_entry ' +
        '   (recordkey, transactionkey, companykey, entrydate, accountkey, accountpart, ' +
        '    debitncu, debitcurr, debiteq, creditncu, creditcurr, crediteq, currkey ';
      // Возьмем все пользовательские аналитики
      for FieldCounter := 0 to AcEntryRelation.RelationFields.Count - 1 do
        if AcEntryRelation.RelationFields.Items[FieldCounter].IsUserDefined then
          TempString := TempString + ', ' + AcEntryRelation.RelationFields.Items[FieldCounter].FieldName;
      TempString := TempString +
        ') VALUES ' +
        ' (:recordkey, :transactionkey, :companykey, :entrydate, :accountkey, :accountpart, ' +
        '  :debitncu, :debitcurr, :debiteq, :creditncu, :creditcurr, :crediteq, :currkey ';
      for FieldCounter := 0 to AcEntryRelation.RelationFields.Count - 1 do
        if AcEntryRelation.RelationFields.Items[FieldCounter].IsUserDefined then
          TempString := TempString + ', :' + AcEntryRelation.RelationFields.Items[FieldCounter].FieldName;
      ibsqlInsertEntry.SQL.Text := TempString + ')';
      ibsqlInsertEntry.Prepare;

      // Ключ типовой проводки
      TRRecordKey := Self.FieldByName('TRRECORDKEY').AsInteger;
      CompanyKey := Self.FieldByName('COMPANYKEY').AsInteger;

      CurrentEntry := TgdcAcctEntryRegister.Create(nil);
      try
        CurrentEntry.Transaction := Transaction;
        // Если было выбрано сторнирование всех проводок по документу, то ограничиваем по документу
        //  иначе по ключу шапки проводки
        if AllDocEntry then
          CurrentEntry.ExtraConditions.Text := 'R.DOCUMENTKEY = ' + Self.FieldByName('DOCUMENTKEY').AsString
        else
          CurrentEntry.ExtraConditions.Text := 'R.RECORDKEY = ' + Self.FieldByName('RECORDKEY').AsString;
        CurrentEntry.Open;

        // Добавим документ
        ReversalDocumentKey := gdcBaseManager.GetNextID;
        ibsqlInsertDocument.ParamByName('ID').AsInteger := ReversalDocumentKey;
        // Формирование номера документа
        if Trim(CurrentEntry.FieldByName('NUMBER').AsString) <> '' then
        begin
          ibsqlInsertDocument.ParamByName('NUMBER').AsString :=
            System.Copy(Trim(CurrentEntry.FieldByName('NUMBER').AsString), 1, 15) + '_СТРН';
        end
        else
        begin
          ibsqlInsertDocument.ParamByName('NUMBER').AsString :=
            CurrentEntry.FieldByName('DOCUMENTKEY').AsString + '_СТРН';
        end;    
        ibsqlInsertDocument.ParamByName('DOCUMENTDATE').AsDateTime := AReversalEntryDate;
        ibsqlInsertDocument.ParamByName('DOCUMENTTYPEKEY').AsInteger := DefaultDocumentTypeKey;
        ibsqlInsertDocument.ParamByName('TRANSACTIONKEY').AsInteger := ATransactionKey;
        ibsqlInsertDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
        ibsqlInsertDocument.ParamByName('CURRKEY').AsVariant := Self.FieldByName('CURRKEY').AsVariant;
        ibsqlInsertDocument.ParamByName('CREATORKEY').AsInteger := IBLogin.Contactkey;
        ibsqlInsertDocument.ParamByName('CREATIONDATE').AsDateTime := Time;
        ibsqlInsertDocument.ExecQuery;

        CurrentRecordKey := -1;
        while not CurrentEntry.Eof do
        begin
          if CurrentRecordKey <> CurrentEntry.FieldByName('RECORDKEY').AsInteger then
          begin
            // Добавим шапку проводки
            ReversalRecordKey := gdcBaseManager.GetNextID;
            ibsqlInsertEntryRecord.Close;
            ibsqlInsertEntryRecord.ParamByName('RECORDKEY').AsInteger := ReversalRecordKey;
            ibsqlInsertEntryRecord.ParamByName('RECORDDATE').AsDateTime := AReversalEntryDate;
            ibsqlInsertEntryRecord.ParamByName('TRANSACTIONKEY').AsInteger := ATransactionKey;
            ibsqlInsertEntryRecord.ParamByName('TRRECORDKEY').AsInteger := TRRecordKey;
            ibsqlInsertEntryRecord.ParamByName('DOCUMENTKEY').AsInteger := ReversalDocumentKey;
            ibsqlInsertEntryRecord.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
            TempString := CurrentEntry.FieldByName('DESCRIPTION').AsString +
              ' Сторнирование проводок документа ' +
              CurrentEntry.FieldByName('NUMBER').AsString + ' от ' +
              CurrentEntry.FieldByName('DOCUMENTDATE').AsString +
              ' (' + CurrentEntry.FieldByName('DOCUMENTKEY').AsString + ')';
            if Length(TempString) <= 180 then
              ibsqlInsertEntryRecord.ParamByName('DESCRIPTION').AsString := TempString
            else
              ibsqlInsertEntryRecord.ParamByName('DESCRIPTION').AsString := CurrentEntry.FieldByName('DESCRIPTION').AsString;
            ibsqlInsertEntryRecord.ExecQuery;
            CurrentRecordKey := CurrentEntry.FieldByName('RECORDKEY').AsInteger;
          end;

          // Добавим часть проводки
          InsertEntryPart(CurrentEntry.FieldByName('ACCOUNTPART').AsString);
          // Перейдем к следующей части проводки
          CurrentEntry.Next;
        end;
      finally
        CurrentEntry.Free;
      end;

      // Подтвердим изменения
      if Transaction.InTransaction then
        Transaction.Commit;
    except
      on E: Exception do
      begin
        if Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    end;
  finally
    ibsqlInsertEntry.Free;
    ibsqlInsertEntryRecord.Free;
    ibsqlInsertDocument.Free;
    Transaction.Free;
  end;
end;

function TgdcAcctBaseEntryRegister.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := TgdcAcctEntryRegister;
  Result.SubType := Self.SubType; 
end;

{ TgdcAcctEntryRegister }

constructor TgdcAcctEntryRegister.Create(AnOwner: TComponent);
begin
  inherited;

  FCurrNCUKey := -1;
end;

procedure TgdcAcctEntryRegister.CreateEntry(const EmptyEntry: Boolean = False);
var
  LParams, LResult: Variant;
//  CI: TTransactionCacheItem;
  CIs: TTransactionCacheItems;
  Index: Integer;
  I: Integer;
  FunctionKey: Integer;
  {$IFDEF DEBUGMOVE}
  T: LongWord;
  {$ENDIF}
begin
  Assert(Assigned(Document), 'Не задан документ для формирования проводок');

  {$IFDEF DEBUGMOVE}
   T := GetTickCount;
  {$ENDIF}
  if not Document.FieldByName(fnid).IsNull then
    ExecSingleQuery('DELETE FROM ac_record WHERE documentkey = :DK', Document.FieldByName(fnid).AsInteger);
  {$IFDEF DEBUGMOVE}
  DeleteOldEntry := DeleteOldEntry + GetTickCount - T;
  {$ENDIF}

  if
    Document.FieldByName(fnTransactionkey).IsNull
    or
    (Document.FieldByName(fnDelayed).AsInteger = 1)
    or
    (
      (Document.GetDocumentClassPart = dcpLine)
      and
      (Document.MasterSource <> nil)
      and
      (Document.MasterSource.DataSet is TgdcDocument)
      and
      (Document.MasterSource.DataSet.FieldByName(fnDelayed).AsInteger = 1)
    ) then
  begin
    Exit;
  end;

  {$IFDEF DEBUGMOVE}
   T := GetTickCount;
  {$ENDIF}
  if Active then Close;
  SubSet := ByDocument;
  Open;
  {$IFDEF DEBUGMOVE}
   OpenEntry := OpenEntry + GetTickCount - T;
  {$ENDIF}

  try
    SetRefreshSQLOn(False);
    gdcQuantity.SetRefreshSQLOn(False);

    {$IFDEF DEBUGMOVE}
     T := GetTickCount;
    {$ENDIF}
    if not TransactionCache.Find(Document.FieldByName(fnTransactionKey).AsInteger, Index) then
    begin
      CIs := TTransactionCacheItems.Create;
      Index := TransactionCache.AddObject(Document.FieldByName(fnTransactionKey).AsInteger,
        CIs);

      if FEntryDocumentSQL = nil then
      begin
        FEntryDocumentSQL := TIBSQL.Create(Self);
        FEntryDocumentSQL.SQl.Text := 'SELECT r.id, r.functionkey, r.documenttypekey, r.documentpart FROM ac_trrecord r WHERE ' +
          ' r.transactionkey = :transactionkey '
      end;

      if FEntryDocumentSQL.Transaction <> Transaction then
        FEntryDocumentSQL.Transaction := Transaction;

      FEntryDocumentSQL.ParamByName(fnTransactionKey).AsInteger :=
        Document.FieldByName(fnTransactionKey).AsInteger;
      FEntryDocumentSQL.ExecQuery;
      try
        while not FEntryDocumentSQL.Eof do
        begin
          if FEntryDocumentSQL.FieldByName(fnDocumentPart).AsString = 'позиция' then
            CIs.Add(FEntryDocumentSQL.FieldByName(fnId).AsInteger,
              FEntryDocumentSQL.FieldByName(fnFunctionKey).AsInteger,
              FEntryDocumentSQL.FieldByName(fnDocumentTypeKey).AsInteger,
              dcpLine)
          else
            CIs.Add(FEntryDocumentSQL.FieldByName(fnId).AsInteger,
              FEntryDocumentSQL.FieldByName(fnFunctionKey).AsInteger,
              FEntryDocumentSQL.FieldByName(fnDocumentTypeKey).AsInteger,
              dcpHeader);

          FEntryDocumentSQL.Next;
        end;
      finally
        FEntryDocumentSQL.Close;
      end;
    end;
  {$IFDEF DEBUGMOVE}
   OpenTypeEntry := OpenTypeEntry + GetTickCount - T;
  {$ENDIF}

    CIs := TransactionCache.CacheItemsByKey[Document.FieldByName(fnTransactionKey).AsInteger];

    for I := 0 to CIs.Count - 1 do
    begin
      if (CIs[i].DocumentTypeKey = Document.DocumentTypeKey) and
        (CIs[i].DocumentPart = Document.GetDocumentClassPart) then
      begin
        FTrRecordKey := CIs[i].TrRecordKey;
        FRecordAdded := False;
        FunctionKey := CIs[I].FunctionKey;
        if not EmptyEntry then
        begin
          if FunctionKey > 0 then
          begin
            {$IFDEF DEBUGMOVE}
             T := GetTickCount;
            {$ENDIF}
            LParams := VarArrayOf([GetGdcOLEObject(Self) as IDispatch, GetGdcOLEObject(Document) as IDispatch]);
            ScriptFactory.ExecuteFunction(FunctionKey,  LParams, LResult);
            {$IFDEF DEBUGMOVE}
             ExecuteFunction := ExecuteFunction + GetTickCount - T;
            {$ENDIF}
          end;
        end;
      end;
    end;
  finally
    Close;
  end;
end;


procedure TgdcAcctEntryRegister.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  var
    S: string;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYREGISTER', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYREGISTER',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if FRecordKey <> FieldByName(fnRecordKey).AsInteger then
  begin
    if FieldByName(fntrrecordkey).IsNull then
      FieldByName(fntrrecordkey).AsInteger := FTrRecordKey;

    if FRecordSQL = nil then
    begin
      FRecordSQL := TIBSQl.Create(nil);
      FRecordSQL.Transaction := Transaction;
      with TatSQLSetup.Create(nil) do
      try
        S := PrepareSQL('INSERT INTO ac_record ( ' +
          '  id, trrecordkey, transactionkey, recorddate, documentkey, masterdockey, companykey, afull, '  +
          '  achag, aview, disabled, reserved, description) ' +
          ' VALUES (:new_recordkey, :NEW_trrecordkey, ' +
          '   :NEW_transactionkey, :NEW_recorddate, :NEW_documentkey, :NEW_masterdockey, :NEW_companykey, ' +
          '   :NEW_afull, :NEW_achag, :NEW_aview, :NEW_disabled, :NEW_reserved, :NEW_description) ',
           Self.ClassName + '(' + Self.SubType + ')');
      finally
        Free;
      end;
      FRecordSQl.SQL.Text := S;

      FRecordSQl.Prepare;
    end;
    if FRecordSQL.Transaction <> Transaction then
    begin
      FRecordSQL.Transaction := Transaction;
      FRecordSQL.Prepare;
    end;
    SetInternalSQLParams(FRecordSQL, Buff);

    try
      FRecordSQL.ExecQuery;
    finally
      FRecordSQL.Close;
    end;
  end;

  if FEntrySQL = nil then
  begin
    FEntrySQL := TIBSQL.Create(nil);
    FEntrySQl.Transaction := Transaction;
    with TatSQLSetup.Create(nil) do
    try
      S := PrepareSQL('INSERT INTO ac_entry ' +
        '  (id, recordkey, accountkey, accountpart, debitncu, debitcurr, debiteq, ' +
        '    creditncu, creditcurr, crediteq, currkey, entrydate) ' +
        'VALUES (:NEW_id, :NEW_recordkey, :NEW_accountkey, :NEW_accountpart, :NEW_debitncu, :NEW_debitcurr, :NEW_debiteq, ' +
        '    :NEW_creditncu, :NEW_creditcurr, :NEW_crediteq, :NEW_currkey, :NEW_recorddate) ',
         Self.ClassName + '(' + Self.SubType + ')');
    finally
      Free;
    end;

    FEntrySQl.SQl.Text := S;
    FEntrySQl.Prepare;
  end;
  if FEntrySQL.Transaction <> Transaction then
  begin
    FEntrySQL.Transaction := Transaction;
    FEntrySQL.Prepare;
  end;
  SetInternalSQLParams(FEntrySQL, Buff);
  try
    FEntrySQL.ExecQuery;
  finally
    FEntrySQL.Close;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYREGISTER', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

destructor TgdcAcctEntryRegister.Destroy;
begin
  FreeAndNil(FEntryDocumentSQL);
  FreeAndNil(FEntrySQL);
  FreeAndNil(FRecordSQL);
  inherited;
end;

{$IFDEF DEBUGMOVE}
procedure TgdcAcctEntryRegister.DoAfterInsert;
begin
  inherited;
  InsertEntryLine := InsertEntryLine + GetTickCount - FTI;
end;
{$ENDIF}

procedure TgdcAcctEntryRegister.DoAfterPost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
//  FM, FD: TField;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYREGISTER', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYREGISTER',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FRecordKey := FieldByName(fnRecordKey).AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYREGISTER', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

{$IFDEF DEBUGMOVE}
procedure TgdcAcctEntryRegister.DoBeforeInsert;
begin
  FTI := GetTickCount;
  inherited;
end;
{$ENDIF}

procedure TgdcAcctEntryRegister.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYREGISTER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYREGISTER', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYREGISTER',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if HasSubSet(ByDocument) then
    ParamByName(fnDocumentKey).AsInteger := Document.FieldByName(fnid).AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYREGISTER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYREGISTER', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctEntryRegister.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin

  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYREGISTER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYREGISTER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if not (sLoadFromStream in BaseState) then
  begin
    Assert(Assigned(Document), 'Не задан документ для формирования проводок');

    if not (sMultiple in BaseState) then
    begin
      if not FRecordAdded then
      begin
        FieldByName(fndocumentkey).AsInteger := Document.FieldByName(fnid).AsInteger;
        if Document.FieldByName(fnparent).IsNull then
          FieldByName(fnmasterdockey).AsInteger := Document.FieldByName(fnid).AsInteger
        else
          FieldByName(fnmasterdockey).AsInteger := Document.FieldByName(fnparent).AsInteger;
        if FieldByName(fncompanykey).IsNull then
          FieldByName(fncompanykey).AsInteger := Document.FieldByName(fncompanykey).AsInteger;
        if FieldByName(fntransactionkey).IsNull then
          FieldByName(fntransactionkey).AsInteger := Document.FieldByName(fntransactionkey).AsInteger;

        FieldByName(fnafull).AsInteger := Document.FieldByName(fnafull).AsInteger;
        FieldByName(fnachag).AsInteger := Document.FieldByName(fnachag).AsInteger;
        FieldByName(fnaview).AsInteger := Document.FieldByName(fnaview).AsInteger;
      end;
    end;

    if FieldByName(fnrecorddate).IsNull then
    begin
      if (Document.GetDocumentClassPart = dcpLine) and Assigned(Document.MasterSource) and
         Assigned(Document.MasterSource.DataSet) and (Document.MasterSource.DataSet is TgdcDocument) then
        FieldByName(fnrecorddate).AsDateTime := Document.MasterSource.DataSet.FieldByName(fndocumentdate).AsDateTime
      else
        FieldByName(fnrecorddate).AsDateTime := Document.FieldByName(fndocumentdate).AsDateTime;
    end;

    if FieldByName(fnCurrKey).IsNull then
      FieldByName(fnCurrKey).AsInteger := GetCurrNCUKey;
   end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctEntryRegister.GetCurrNCUKey: Integer;
var
  ibsql: TIBSQL;
begin
  if FCurrNCUKey = -1 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Database := Database;
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT id FROM gd_curr WHERE isNCU = 1';
      ibsql.ExecQuery;
      FCurrNCUKey := ibsql.FieldByName('id').AsInteger;
    finally
      ibsql.Free;
    end;
  end;
  Result := FCurrNCUKey;
end;

function TgdcAcctEntryRegister.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYREGISTER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYREGISTER',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh);

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'R';
  Ignore.IgnoryType := itReferences;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;


{$IFDEF DEBUGMOVE}
procedure TgdcAcctEntryRegister.Post;
begin
  FT := GetTickCount;
  inherited;
  PostEntryLine := PostEntryLine + GetTickCount - FT;
end;
{$ENDIF}

{ TgdcAcctViewEntryRegister }

function TgdcAcctViewEntryRegister.CopyDialog: Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcAcctComplexRecord: TgdcAcctComplexRecord;
begin
  {@UNFOLD MACRO INH_ORIG_COPYDIALOG('TGDCACCTVIEWENTRYREGISTER', 'COPYDIALOG', KEYCOPYDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYCOPYDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCOPYDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'COPYDIALOG', KEYCOPYDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'COPYDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited CopyDialog;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//  if FieldByName('documenttypekey').AsInteger = DefaultDocumentTypeKey then
//  begin
    gdcAcctComplexRecord := TgdcAcctComplexRecord.Create(Self);
    try
      gdcAcctComplexRecord.Transaction := Transaction;
      gdcAcctComplexRecord.SubSet := 'ByID';
      gdcAcctComplexRecord.ID := FieldByName('recordkey').AsInteger;
      gdcAcctComplexRecord.Open;
      Result := gdcAcctComplexRecord.CopyDialog;
      if Result then
      begin
        DataTransfer(gdcAcctComplexRecord);
      end;
      gdcAcctComplexRecord.Close;
    finally
      gdcAcctComplexRecord.Free;
    end;
//  end
//  else
//    Result := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'COPYDIALOG', KEYCOPYDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'COPYDIALOG', KEYCOPYDIALOG);
  {M}  end;
  {END MACRO}
end;

constructor TgdcAcctViewEntryRegister.Create(AnOwner: TComponent);
begin
  inherited;
  FEntryGroup := egAll;
end;

function TgdcAcctViewEntryRegister.CreateDialog(
  const ADlgClassName: String): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcAcctComplexRecord: TgdcAcctComplexRecord;
begin
  {@UNFOLD MACRO INH_ORIG_CREATEDIALOG('TGDCACCTVIEWENTRYREGISTER', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYCREATEDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'CREATEDIALOG', KEYCREATEDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CREATEDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited CreateDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if ADlgClassName <> '' then
    Result := inherited CreateDialog(ADlgClassName)
  else
  begin
    gdcAcctComplexRecord := TgdcAcctComplexRecord.Create(Self);
    try
      gdcAcctComplexRecord.Transaction := Transaction;
      gdcAcctComplexRecord.SubSet := 'ByID';
      gdcAcctComplexRecord.Open;
      if Active and not FieldByName('transactionkey').IsNull then
        gdcAcctComplexRecord.TransactionKey := FieldByName('transactionkey').AsInteger
      else
        if Assigned(MasterSource) and Assigned(MasterSource.DataSet) then
          gdcAcctComplexRecord.TransactionKey := MasterSource.DataSet.FieldByName('id').AsInteger;
      Result := gdcAcctComplexRecord.CreateDialog;
      if Result and Active then
      begin
        DataTransfer(gdcAcctComplexRecord);
      end;
      gdcAcctComplexRecord.Close;
    finally
      gdcAcctComplexRecord.Free;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'CREATEDIALOG', KEYCREATEDIALOG);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctViewEntryRegister.DataTransfer(gdcAcctComplexRecord: TgdcAcctComplexRecord);
var
  I, J: Integer;
begin
  FDataTransfer := True;
  try
    for I := 0 to gdcAcctComplexRecord.EntryLines.Count - 1 do
    begin
      if not gdcAcctComplexRecord.EntryLines[i].FieldByName('accountkey').IsNull then
      begin
        Insert;
        FieldByName('id').AsInteger := gdcAcctComplexRecord.EntryLines[i].FieldByName('id').AsInteger;
        FieldByName('alias').AsString := gdcAcctComplexRecord.EntryLines[i].FieldByName('alias').AsString;
        FieldByName('name').AsString := gdcAcctComplexRecord.EntryLines[i].FieldByName('name').AsString;
        FieldByName('recordkey').AsInteger := gdcAcctComplexRecord.FieldByName('id').AsInteger;
        FieldByName('accountkey').AsInteger := gdcAcctComplexRecord.EntryLines[i].FieldByName('accountkey').AsInteger;
        FieldByName('accountpart').AsString := gdcAcctComplexRecord.EntryLines[i].FieldByName('accountpart').AsString;
        FieldByName('debitncu').AsCurrency := gdcAcctComplexRecord.EntryLines[i].FieldByName('debitncu').AsCurrency;
        FieldByName('debitcurr').AsCurrency := gdcAcctComplexRecord.EntryLines[i].FieldByName('debitcurr').AsCurrency;
        FieldByName('debiteq').AsCurrency := 0;
        FieldByName('creditncu').AsCurrency := gdcAcctComplexRecord.EntryLines[i].FieldByName('creditncu').AsCurrency;
        FieldByName('creditcurr').AsCurrency := gdcAcctComplexRecord.EntryLines[i].FieldByName('creditcurr').AsCurrency;
        FieldByName('currkey').AsInteger := gdcAcctComplexRecord.EntryLines[i].FieldByName('currkey').AsInteger;
        FieldByName('trrecordkey').AsInteger := gdcAcctComplexRecord.FieldByName('trrecordkey').AsInteger;
        FieldByName('transactionkey').AsInteger := gdcAcctComplexRecord.FieldByName('transactionkey').AsInteger;
        FieldByName('recorddate').AsDateTime := gdcAcctComplexRecord.FieldByName('recorddate').AsDateTime;
        FieldByName('documentkey').AsInteger := gdcAcctComplexRecord.FieldByName('documentkey').AsInteger;
        FieldByName('masterdockey').AsInteger := gdcAcctComplexRecord.FieldByName('masterdockey').AsInteger;
        FieldByName('companykey').AsInteger := gdcAcctComplexRecord.FieldByName('companykey').AsInteger;
        FieldByName('afull').AsInteger := gdcAcctComplexRecord.FieldByName('afull').AsInteger;
        FieldByName('achag').AsInteger := gdcAcctComplexRecord.FieldByName('achag').AsInteger;
        FieldByName('aview').AsInteger := gdcAcctComplexRecord.FieldByName('aview').AsInteger;
        FieldByName('disabled').AsInteger := gdcAcctComplexRecord.FieldByName('disabled').AsInteger;
        FieldByName('reserved').AsInteger := gdcAcctComplexRecord.FieldByName('reserved').AsInteger;
        FieldByName('rdebitncu').AsCurrency := gdcAcctComplexRecord.FieldByName('debitncu').AsCurrency;
        FieldByName('rdebitcurr').AsCurrency := gdcAcctComplexRecord.FieldByName('debitcurr').AsCurrency;
        FieldByName('rcreditncu').AsCurrency := gdcAcctComplexRecord.FieldByName('creditncu').AsCurrency;
        FieldByName('rcreditcurr').AsCurrency := gdcAcctComplexRecord.FieldByName('creditcurr').AsCurrency;
        FieldByName('number').AsString := gdcAcctComplexRecord.FieldByName('number').AsString;
        FieldByName('documenttypekey').AsInteger := gdcAcctComplexRecord.FieldByName('documenttypekey').AsInteger;
        FieldByName('documentdate').AsDateTime := gdcAcctComplexRecord.FieldByName('recorddate').AsDateTime;
        for j:= 0 to gdcAcctComplexRecord.EntryLines[i].FieldCount - 1 do
          if (Pos(UserPrefix, gdcAcctComplexRecord.EntryLines[i].Fields[j].FieldName) > 0) and
             (FindField(gdcAcctComplexRecord.EntryLines[i].Fields[j].FieldName) <> nil)
          then
            FieldByName(gdcAcctComplexRecord.EntryLines[i].Fields[j].FieldName).AsVariant :=
              gdcAcctComplexRecord.EntryLines[i].Fields[j].AsVariant;
        Post;
      end;
    end;
  finally
    FDataTransfer := False;
  end;
end;

procedure TgdcAcctViewEntryRegister.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTVIEWENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  Assert(Assigned(Document), 'Не задан документ для формирования проводок');

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('accountpart').AsString = 'Z' then
    begin
      if FieldByName('recorddate').IsNull then
        FieldByName('recorddate').AsDateTime := Document.FieldByName('documentdate').AsDateTime;
      FieldByName('documentkey').AsInteger := Document.FieldByName('id').AsInteger;

      if Document.FieldByName('parent').IsNull then
        FieldByName('masterdockey').AsInteger := Document.FieldByName('id').AsInteger
      else
        FieldByName('masterdockey').AsInteger := Document.FieldByName('parent').AsInteger;

      FieldByName('companykey').AsInteger := Document.FieldByName('companykey').AsInteger;
      FieldByName('transactionkey').AsInteger := Document.FieldByName('transactionkey').AsInteger;

      FieldByName('afull').AsInteger := Document.FieldByName('afull').AsInteger;
      FieldByName('achag').AsInteger := Document.FieldByName('achag').AsInteger;
      FieldByName('aview').AsInteger := Document.FieldByName('aview').AsInteger;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctViewEntryRegister.EditDialog(const ADlgClassName: String = ''): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  tmpDocument: TgdcDocument;
  gdcacctComplexRecord: TgdcacctComplexRecord;
  isParent: Boolean;

  procedure RefreshLine;
  var
    i, J: Integer;
    S: String;
  begin
    Edit;
    FieldByName('currkey').AsInteger := gdcacctComplexRecord.FieldByName('currkey').AsInteger;
    FieldByName('trrecordkey').AsInteger := gdcacctComplexRecord.FieldByName('trrecordkey').AsInteger;
    FieldByName('transactionkey').AsInteger := gdcacctComplexRecord.FieldByName('transactionkey').AsInteger;
    FieldByName('recorddate').AsDateTime := gdcacctComplexRecord.FieldByName('recorddate').AsDateTime;
    FieldByName('afull').AsInteger := gdcacctComplexRecord.FieldByName('afull').AsInteger;
    FieldByName('achag').AsInteger := gdcacctComplexRecord.FieldByName('achag').AsInteger;
    FieldByName('aview').AsInteger := gdcacctComplexRecord.FieldByName('aview').AsInteger;
    FieldByName('disabled').AsInteger := gdcacctComplexRecord.FieldByName('disabled').AsInteger;
    FieldByName('reserved').AsInteger := gdcacctComplexRecord.FieldByName('reserved').AsInteger;
    FieldByName('rdebitncu').AsCurrency := gdcacctComplexRecord.FieldByName('debitncu').AsCurrency;
    FieldByName('rdebitcurr').AsCurrency := gdcacctComplexRecord.FieldByName('debitcurr').AsCurrency;
    FieldByName('rcreditncu').AsCurrency := gdcacctComplexRecord.FieldByName('creditncu').AsCurrency;
    FieldByName('rcreditcurr').AsCurrency := gdcacctComplexRecord.FieldByName('creditcurr').AsCurrency;
    FieldByName('number').AsString := gdcacctComplexRecord.FieldByName('number').AsString;
    FieldByName('documenttypekey').AsInteger := gdcacctComplexRecord.FieldByName('documenttypekey').AsInteger;
    FieldByName('documentdate').AsDateTime := gdcacctComplexRecord.FieldByName('recorddate').AsDateTime;
    FieldByName('description').AsString := gdcacctComplexRecord.FieldByName('description').AsString;

    for j := 0 to gdcAcctComplexRecord.EntryLines.Count - 1 do
    begin
      if FieldByName('id').AsInteger = gdcAcctComplexRecord.EntryLines[J].FieldByName('id').AsInteger then
      begin
        FieldByName('id').AsInteger := gdcacctComplexRecord.EntryLines[J].FieldByName('id').AsInteger;
        FieldByName('alias').AsString := gdcacctComplexRecord.EntryLines[J].FieldByName('alias').AsString;
        FieldByName('name').AsString := gdcacctComplexRecord.EntryLines[J].FieldByName('name').AsString;
        FieldByName('accountkey').AsInteger := gdcacctComplexRecord.EntryLines[J].FieldByName('accountkey').AsInteger;
        FieldByName('creditncu').AsCurrency := gdcacctComplexRecord.EntryLines[J].FieldByName('creditncu').AsCurrency;
        FieldByName('creditcurr').AsCurrency := gdcacctComplexRecord.EntryLines[J].FieldByName('creditcurr').AsCurrency;
        FieldByName('debitncu').AsCurrency := gdcacctComplexRecord.EntryLines[J].FieldByName('debitncu').AsCurrency;
        FieldByName('debitcurr').AsCurrency := gdcacctComplexRecord.EntryLines[J].FieldByName('debitcurr').AsCurrency;

        for i:= 0 to gdcAcctComplexRecord.EntryLines[J].FieldCount - 1 do
        begin
          if (Pos(UserPrefix, gdcAcctComplexRecord.EntryLines[J].Fields[i].FieldName) > 0)
          then
          begin
            if Pos('Z_', gdcAcctComplexRecord.EntryLines[J].Fields[i].FieldName) = 1 then
              S := 'R_' + System.copy(gdcAcctComplexRecord.EntryLines[J].Fields[i].FieldName, 3, 255)
            else
              S := gdcAcctComplexRecord.EntryLines[J].Fields[i].FieldName;
            if FindField(S) <> nil then
              FieldByName(S).AsVariant :=
                gdcAcctComplexRecord.EntryLines[J].Fields[i].AsVariant;
          end;
        end;
        Break;
      end;
      Post;
    end;
  end;

begin
  {@UNFOLD MACRO INH_ORIG_EDITDIALOG('TGDCACCTVIEWENTRYREGISTER', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYEDITDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYEDITDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'EDITDIALOG', KEYEDITDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'EDITDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}          Exit;
  {M}    end;
  {END MACRO}

  if FieldByName('documenttypekey').AsInteger <> DefaultDocumentTypeKey then
  begin
    tmpDocument := TgdcDocument.Create(Self);
    try
      tmpDocument.SubSet := 'ByID';

      if FEntryGroup = egAll then
      begin
        isParent := False;
        if FieldByName('masterdockey').AsInteger <>  FieldByName('documentkey').AsInteger then
        begin
          isParent := MessageBox(ParentHandle, 'Просмотреть весь документ ?', 'Внимание',
            mb_YesNo or mb_IconQuestion) = idYes;
        end;
      end
      else
        isParent := True;

      if not isParent then
        tmpDocument.ParamByName('id').AsInteger := FieldByName('documentkey').AsInteger
      else
        tmpDocument.ParamByName('id').AsInteger := FieldByName('masterdockey').AsInteger;
      tmpDocument.Open;

      if tmpDocument.RecordCount > 0 then
        Result := tmpDocument.EditDialog(ADlgClassName)
      else
        MessageDlg('Отсутствуют права на просмотр документа.', mtInformation, [mbOk], -1);
    finally
      tmpDocument.Free;
    end;
  end
  else
  begin
    gdcacctComplexRecord := TgdcacctComplexRecord.Create(Self);
    try
      gdcAcctComplexRecord.Transaction := Transaction;
      gdcAcctComplexRecord.ReadTransaction := ReadTransaction;
      gdcAcctComplexRecord.SubSet := 'ByID';
      gdcAcctComplexRecord.ID := FieldByName('recordkey').AsInteger;
      gdcAcctComplexRecord.Open;
      Result := gdcAcctComplexRecord.EditDialog(ADlgClassName);
      if Result then
      begin
        FDataTransfer := True;
        try
          while not Bof and (FieldByName('recordkey').AsInteger = gdcAcctComplexRecord.FieldByName('id').AsInteger) do
          begin
            Prior;
          end;

          while not Eof and (FieldByName('recordkey').AsInteger = gdcAcctComplexRecord.FieldByName('id').AsInteger) do
          begin
            Delete;
          end;

          DataTransfer(gdcAcctComplexRecord);
        finally
          FDataTransfer := False;
        end;
      end;
      gdcacctComplexRecord.Close;
    finally
      gdcacctComplexRecord.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'EDITDIALOG', KEYEDITDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctViewEntryRegister.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := TgdcAcctViewEntryRegister;
  Result.SubType := Self.SubType; 
end;

function TgdcAcctViewEntryRegister.GetDocument: TgdcDocument;
begin
  if not Assigned(FDocument) then
  begin
    FDocument := TgdcAcctDocument.Create(Self);
    FDocument.Database := Database;
    FDocument.Transaction := Transaction;
  end;
  Result := FDocument;
end;

function TgdcAcctViewEntryRegister.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTVIEWENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' FROM ac_transaction t JOIN ac_record z ON t.id = z.transactionkey ' +
            '   JOIN ac_entry r ON z.id = r.recordkey ' +
            '   LEFT JOIN gd_document doc ON z.documentkey = doc.id ' +
            '   LEFT JOIN ac_account c ON r.accountkey = c.id ' +
            '   LEFT JOIN gd_curr cur ON r.currkey = cur.id ' ;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctViewEntryRegister.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCACCTVIEWENTRYREGISTER', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if FEntryGroup = egAll then
    Result := inherited GetGroupClause
  else
    Result :=
        ' GROUP BY ' +
        '   Z.MASTERDOCKEY, ' +
        '   DOC.NUMBER, ' +
        '   CUR.SHORTNAME, ' +
        '   R.ACCOUNTPART, ' +
        '   R.ACCOUNTKEY, ' +
        '   C.ALIAS, ' +
        '   DOC.DOCUMENTTYPEKEY, ' +
        '   C.NAME, ' +
        '   DOC.DOCUMENTDATE, ' +
        '   R.CURRKEY, ' +
        '   Z.TRRECORDKEY, ' +
        '   Z.TRANSACTIONKEY, ' +
        '   Z.RECORDDATE, ' +
        '   T.Name, ' + 
        '   Z.COMPANYKEY, ' +
        '   Z.AFULL, ' +
        '   Z.ACHAG, ' +
        '   Z.AVIEW, ' +
        '   Z.DISABLED, ' +
        '   Z.RESERVED ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctViewEntryRegister.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCACCTVIEWENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FEntryGroup = egAll then
    Result := inherited GetGroupClause
  else
    Result := 'ORDER BY z.masterdockey, r.accountpart';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}

end;

function TgdcAcctViewEntryRegister.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTVIEWENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTVIEWENTRYREGISTER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTVIEWENTRYREGISTER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTVIEWENTRYREGISTER',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTVIEWENTRYREGISTER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if FEntryGroup = egAll then
    Result := inherited GetSelectClause + ', t.name as transactionname '
  else
    Result :=
      ' SELECT ' +
      ' z.trrecordkey as recordkey, '  +
      ' r.accountkey, '  +
      ' c.alias, ' +
      ' c.name, ' +
      ' cur.shortname, ' +
      ' r.accountpart, '  +
      ' r.currkey, '  +
      ' z.trrecordkey, '  +
      ' z.transactionkey, '  +
      ' z.recorddate, '  +
      ' z.masterdockey, ' +
      ' z.masterdockey as ID, ' +
      ' z.companykey, '  +
      ' z.afull, '  +
      ' z.achag, '  +
      ' z.aview, '  +
      ' z.disabled, '  +
      ' z.reserved, '  +
      ' doc.number, ' +
      ' doc.documenttypekey, ' +
      ' doc.documentdate, ' +
      ' MAX(doc.creationdate) as creationdate, ' +
      ' MAX(doc.editiondate) as editiondate, ' +
      ' t.name as transactionname, ' +
      ' SUM(z.debitncu) as rdebitncu, ' +
      ' SUM(z.debitcurr) as rdebitcurr, ' +
      ' SUM(z.creditncu) as rcreditncu, ' +
      ' SUM(z.creditcurr) as rcreditcurr, ' +
      ' SUM(r.debitncu) as debitncu, '  +
      ' SUM(r.debitcurr) as debitcurr, '  +
      ' SUM(r.debiteq) as debiteq, '  +
      ' SUM(r.creditncu) as creditncu, '  +
      ' SUM(r.creditcurr) as creditcurr, '  +
      ' SUM(r.crediteq) as crediteq ';


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTVIEWENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTVIEWENTRYREGISTER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctViewEntryRegister.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByLBRB;';
end;

procedure TgdcAcctViewEntryRegister.GetWhereClauseConditions(S: TStrings);
var
  I: Integer;
  Str: string;
begin
  if HasSubSet('OnlySelected') then begin
    Str := '';
    for I := 0 to SelectedID.Count - 1 do
    begin
      if Length(Str) >= 8192 then break;
      Str := Str + IntToStr(SelectedID[I]) + ',';
    end;
    if Str = '' then
      Str := '-1'
    else
      SetLength(Str, Length(Str) - 1);
    if FEntryGroup = egAll then
      S.Add(Format('r.%s IN (%s)', [GetKeyField(SubType), Str]))
    else
      S.Add(Format('%s IN (%s)', ['z.masterdockey', Str]));
  end
  else
    inherited;

  if HasSubSet('ByLBRB') then
    S.Add('t.LB >= :LB and t.RB <= :RB');

end;

procedure TgdcAcctViewEntryRegister.SetEntryGroup(
  const Value: TEntryGroup);
begin
  if FEntryGroup <> Value then
  begin
    FEntryGroup := Value;
    Close;
    FSQLInitialized := False;
    Open;
  end;
end;

{ TgdcAcctSimpleRecord }

constructor TgdcAcctSimpleRecord.Create(AnOwner: TComponent);
begin
  inherited;

  CustomProcess := [cpModify];
  FCurrNCUKey := -1;

  FDebitEntryLine := TgdcAcctEntryLine.Create(Self);


  FCreditEntryLine := TgdcAcctEntryLine.Create(Self);


  FTransactionKey := -1;
end;

(*function TgdcAcctSimpleRecord.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCACCTSIMPLERECORD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := TCreateableForm(CCreateableForm(FindClass('Tgdc_acct_dlgEntry')).Create(ParentForm));
//  Result := TCreateableForm(CgdcCreateableForm(FindClass('Tgdc_acct_dlgEntry')).Create(ParentForm));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;*)

procedure TgdcAcctSimpleRecord.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTSIMPLERECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FAmountNCU := FieldByName('debitncu').AsCurrency;
  FAmountCurr := FieldByName('debitcurr').AsCurrency;

  if FieldByName('number').AsString = '' then
    FieldByName('number').AsString := ' ';

  if FieldByName('currkey').IsNull then
    FieldByName('currkey').AsInteger := GetCurrNCUKey;

  if FieldByName('documentkey').IsNull then
  begin
    FieldByName('documentkey').AsInteger := GetNextID;
    FieldByName('masterdockey').AsInteger := FieldByName('documentkey').AsInteger;

    ExecSingleQuery(
      'INSERT INTO GD_DOCUMENT ' +
      '  (ID, DOCUMENTTYPEKEY, NUMBER, DOCUMENTDATE, ' +
      '   CURRKEY, COMPANYKEY, AVIEW, ACHAG, AFULL, ' +
      '   CREATORKEY, CREATIONDATE, EDITORKEY, EDITIONDATE, TRANSACTIONKEY) ' +
      'VALUES ' +
      '  (:ID, :DOCUMENTTYPEKEY, :NUMBER, :DOCUMENTDATE, ' +
      '   :CURRKEY, :COMPANYKEY, :AVIEW, :ACHAG, :AFULL, ' +
      '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :TRANSACTIONKEY) ',
      VarArrayOf([
        FieldByName('documentkey').AsInteger,
        DefaultDocumentTypeKey,
        FieldByName('NUMBER').AsString,
        FieldByName('RECORDDATE').AsDateTime,
        FieldByName('CURRKEY').AsInteger,
        IBLogin.CompanyKey,
        FieldByName('AVIEW').AsInteger,
        FieldByName('ACHAG').AsInteger,
        FieldByName('AFULL').AsInteger,
        IBLogin.ContactKey,
        Now,
        IBLogin.ContactKey,
        Now, FieldByName('transactionkey').AsInteger
      ])
    );
  end
  else
    ExecSingleQuery(
      'UPDATE GD_DOCUMENT SET ' +
      '  NUMBER = :NUMBER, DOCUMENTDATE = :DOCUMENTDATE, ' +
      '   CURRKEY = :CURRKEY, AVIEW = :AVIEW, ACHAG = :ACHAG, AFULL = :AFULL, ' +
      '   EDITORKEY = :EDITORKEY, EDITIONDATE = :EDITIONDATE, TRANSACTIONKEY = :TRANSACTIONKEY ' +
      'WHERE ID = :ID ',
      VarArrayOf([
        FieldByName('NUMBER').AsString,
        FieldByName('RECORDDATE').AsDateTime,
        FieldByName('CURRKEY').AsInteger,
        FieldByName('AVIEW').AsInteger,
        FieldByName('ACHAG').AsInteger,
        FieldByName('AFULL').AsInteger,
        IBLogin.ContactKey,
        Now, FieldByName('transactionkey').AsInteger,
        FieldByName('documentkey').AsInteger
      ])
    );


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctSimpleRecord.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTSIMPLERECORD', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not DebitEntryLine.FieldByName('accountkey').IsNull then
  begin
    if not (DebitEntryLine.State in [dsEdit, dsInsert]) then
      DebitEntryLine.Edit;
    try
      DebitEntryLine.FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;
      DebitEntryLine.FieldByName('accountpart').AsString := 'D';
      DebitEntryLine.FieldByName('debitncu').AsCurrency := FAmountNCU;
      DebitEntryLine.FieldByName('entrydate').AsDateTime := FieldByName('recorddate').AsDateTime;
      if DebitEntryLine.FieldByName('currkey').IsNull then
      begin
        if not FieldByName('currkey').IsNull then
          DebitEntryLine.FieldByName('currkey').AsVariant := FieldByName('currkey').AsVariant
        else
          DebitEntryLine.FieldByName('currkey').AsInteger := GetCurrNCUKey;
      end;
      if (DebitEntryLine.FieldByName('debitcurr').AsCurrency = 0) and  (DebitEntryLine.FieldByName('currkey').AsInteger <> GetCurrNCUKey) then
        DebitEntryLine.FieldByName('debitcurr').AsCurrency := FAmountCurr;
      DebitEntryLine.Post;
    except
      DebitEntryLine.Cancel;
      raise;
    end;
  end;

  if not CreditEntryLine.FieldByName('accountkey').IsNull then
  begin
    if not (CreditEntryLine.State in [dsEdit, dsInsert]) then
      CreditEntryLine.Edit;
    try
      CreditEntryLine.FieldByName('entrydate').AsDateTime := FieldByName('recorddate').AsDateTime;
      CreditEntryLine.FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;
      CreditEntryLine.FieldByName('accountpart').AsString := 'C';
      CreditEntryLine.FieldByName('creditncu').AsCurrency := FAmountNCU;
      if CreditEntryLine.FieldByName('currkey').IsNull then
      begin
        if not FieldByName('currkey').IsNull then
          CreditEntryLine.FieldByName('currkey').AsVariant := FieldByName('currkey').AsVariant
        else
          CreditEntryLine.FieldByName('currkey').AsVariant := GetCurrNCUKey;
      end;
      if (CreditEntryLine.FieldByName('creditcurr').AsCurrency = 0) and  (CreditEntryLine.FieldByName('currkey').AsInteger <> GetCurrNCUKey) then
        CreditEntryLine.FieldByName('creditcurr').AsCurrency := FAmountCurr;
      CreditEntryLine.Post;
    except
      CreditEntryLine.Cancel;
      raise;
    end;
  end;

  Refresh;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;


function TgdcAcctSimpleRecord.GetDocument: TgdcDocument;
begin
  if not Assigned(FDocument) then
  begin
    FDocument := TgdcAcctDocument.Create(Self);
    FDocument.Database := Database;
    FDocument.Transaction := Transaction;
  end;
  Result := FDocument;
end;

function TgdcAcctSimpleRecord.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTSIMPLERECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM ac_record z LEFT JOIN gd_document doc ON z.documentkey = doc.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctSimpleRecord.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcAcctSimpleRecord.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'description';
end;

class function TgdcAcctSimpleRecord.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_record';
end;

procedure TGDCACCTSIMPLERECORD.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTSIMPLERECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  CustomExecQuery(
    'UPDATE ac_record SET ' +
    '  id = :NEW_ID, trrecordkey = :NEW_trrecordkey, transactionkey = :NEW_transactionkey, ' +
    '  recorddate = :NEW_recorddate, documentkey = :NEW_documentkey, ' +
    '  masterdockey = :NEW_masterdockey, companykey = :NEW_companykey, afull = :NEW_afull, '  +
    '  achag = :NEW_achag, aview = :NEW_AVIEW, disabled = :NEW_DISABLED, reserved = :NEW_reserved, ' +
    '  description = :NEW_description ' + 
    'WHERE id = :NEW_id ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;


function TgdcAcctSimpleRecord.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTSIMPLERECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT ' +
            '   z.id, ' +
            '   z.trrecordkey, ' +
            '   z.transactionkey, ' +
            '   z.recorddate, ' +
            '   z.description, ' +
            '   z.documentkey, ' +
            '   z.masterdockey, ' +
            '   z.companykey, ' +
            '   z.debitncu, ' +
            '   z.debitcurr, ' +
            '   z.creditncu, ' +
            '   z.creditcurr, ' +
            '   z.delayed, ' +
            '   z.incorrect, ' +
            '   z.afull, ' +
            '   z.achag, ' +
            '   z.aview, ' +
            '   z.disabled, ' +
            '   z.reserved, ' +
            '   doc.number, ' +
            '   doc.currkey, ' +
            '   doc.documenttypekey ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctSimpleRecord.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ByTransaction + ';';
end;

procedure TgdcAcctSimpleRecord.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(ByTransaction) then
    S.Add(' transactionkey = :transactionkey ');
end;

procedure TgdcAcctSimpleRecord._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTSIMPLERECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if TransactionKey <> -1 then
    FieldByName('transactionkey').AsInteger := TransactionKey
  else
    FieldByName('transactionkey').AsInteger := DefaultTransactionKey;

  FieldByName('trrecordkey').AsInteger := DefaultEntryKey;
  FieldByName('companykey').AsInteger := IBLogin.CompanyKey;

  SetupEntryLine;


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctSimpleRecord.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTSIMPLERECORD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('documentkey').Required := False;
  FieldByName('masterdockey').Required := False;  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctSimpleRecord.GetCurrNCUKey: Integer;
var
  ibsql: TIBSQL;
begin
  if FCurrNCUKey = -1 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Database := Database;
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT id FROM gd_curr WHERE isNCU = 1';
      ibsql.ExecQuery;
      FCurrNCUKey := ibsql.FieldByName('id').AsInteger;
    finally
      ibsql.Free;
    end;
  end;
  Result := FCurrNCUKey;
end;

procedure TgdcAcctSimpleRecord.SetupEntryLine;
begin
  DebitEntryLine.Close;
  CreditEntryLine.Close;  

  DebitEntryLine.Transaction := Transaction;
  DebitEntryLine.ReadTransaction := ReadTransaction;
  DebitEntryLine.SubSet := 'ByRecord,ByAccountPart';

  CreditEntryLine.Transaction := Transaction;
  CreditEntryLine.ReadTransaction := ReadTransaction;  
  CreditEntryLine.SubSet := 'ByRecord,ByAccountPart';

  DebitEntryLine.AccountPart := 'D';
  DebitEntryLine.RecordKey := FieldByName('id').AsInteger;
  DebitEntryLine.Open;

  CreditEntryLine.AccountPart := 'C';
  CreditEntryLine.RecordKey := FieldByName('id').AsInteger;
  CreditEntryLine.Open;

end;

procedure TgdcAcctSimpleRecord.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
   if (not CanEdit) and (not IBLogin.IsIBUserAdmin) then
     raise EgdcUserHaventRights.CreateFmt(strHaventRights,
       [strEdit, ClassName, SubType, GetDisplayName(SubType)]);

  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTSIMPLERECORD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  SetupEntryLine;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctSimpleRecord.DoAfterTransactionEnd(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCACCTSIMPLERECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYDOAFTERTRANSACTIONEND);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERTRANSACTIONEND]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FDSModified := False;
  if Active then
  begin
    Cancel;
    if DebitEntryLine.Active then
    begin
      DebitEntryLine.Cancel;
      DebitEntryLine.Refresh;
    end;
    if CreditEntryLine.Active and (not CreditEntryLine.FieldByName('accountkey').IsNull) then
    begin
      CreditEntryLine.Cancel;
      CreditEntryLine.Refresh;
    end;
    Refresh;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctSimpleRecord.DoBeforeCancel;
begin
  DebitEntryLine.Cancel;
  CreditEntryLine.Cancel;
  
  inherited;

end;

procedure TgdcAcctSimpleRecord.SetEntryModified;
begin
  SetModified(True);
end;

function TgdcAcctSimpleRecord.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCACCTSIMPLERECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'recorddate;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctSimpleRecord.Copy(const AFields: String; AValues: Variant;
  const ACopyDetail: Boolean = False;const APost: Boolean = True; const AnAppend: Boolean = False): Boolean;
var
  DebitV, CreditV: array of Variant;
  I: Integer;
//  L: TList;
begin
  SetupEntryLine;

  SetLength(DebitV, DebitEntryLine.FieldCount);
  for I := 0 to DebitEntryLine.FieldCount - 1 do
    DebitV[I] := DebitEntryLine.Fields[I].AsVariant;

  SetLength(CreditV, CreditEntryLine.FieldCount);
  for I := 0 to CreditEntryLine.FieldCount - 1 do
    CreditV[I] := CreditEntryLine.Fields[I].AsVariant;

  inherited Copy(aFields, aValues, aCopyDetail, aPost, AnAppend);


  if AnAppend then
    DebitEntryLine.Append
  else
    DebitEntryLine.Insert;

  for i:= 0 to DebitEntryLine.FieldCount - 1 do
    if (UpperCase(DebitEntryLine.Fields[i].FieldName) <> 'RECORDKEY') and
       (UpperCase(DebitEntryLine.Fields[i].FieldName) <> 'ID')
    then
      DebitEntryLine.Fields[i].Value := DebitV[i];

  DebitEntryLine.FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;

  if AnAppend then
    CreditEntryLine.Append
  else
    CreditEntryLine.Insert;

  for i:= 0 to CreditEntryLine.FieldCount - 1 do
    if (UpperCase(CreditEntryLine.Fields[i].FieldName) <> 'RECORDKEY') and
       (UpperCase(CreditEntryLine.Fields[i].FieldName) <> 'ID')
    then
      CreditEntryLine.Fields[i].Value := CreditV[i];

  CreditEntryLine.FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;

  Result := True;
end;

function TgdcAcctSimpleRecord.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCACCTSIMPLERECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSIMPLERECORD', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSIMPLERECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSIMPLERECORD',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSIMPLERECORD' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY,RECORDKEY'

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSIMPLERECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSIMPLERECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

{
class function TgdcAcctSimpleRecord.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_acct_dlgEntry'
end;
}


function TgdcAcctSimpleRecord.CopyObject(const ACopyDetailObjects,
  AShowEditDialog: Boolean): Boolean;
begin
  Result := Copy('', NULL, True, False) and EditDialog;
end;

{ TgdcAcctEntryLine }

constructor TgdcAcctEntryLine.Create(AnOwner: TComponent);
begin
  inherited;
  AccountPart := '';
  RecordKey := -1;
end;

procedure TgdcAcctEntryLine.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYLINE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName('issimple').Required := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctEntryLine.DataEvent(Event: TDataEvent; Info: Integer);
begin
  inherited;
  if (Event = deFieldChange) and (Owner is TgdcAcctSimpleRecord) then
    (Owner as TgdcAcctSimpleRecord).SetEntryModified;

end;

procedure TgdcAcctEntryLine.DoAfterCancel;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYLINE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYDOAFTERCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'DOAFTERCANCEL', KEYDOAFTERCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if (FgdcQuantity <> nil) and (FgdcQuantity.Active) then
  begin
    if FgdcQuantity.CachedUpdates then
    begin
      FgdcQuantity.CancelUpdates;
    end;
  end;  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'DOAFTERCANCEL', KEYDOAFTERCANCEL);
  {M}  end;
  {END MACRO}
end;


procedure TgdcAcctEntryLine.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYLINE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if (FgdcQuantity <> nil) and (FgdcQuantity.Active) then
  begin
    if FgdcQuantity.CachedUpdates then
    begin
      FgdcQuantity.ApplyUpdates;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctEntryLine.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYLINE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if HasSubSet('ByRecord') and (RecordKey <> -1) then
    ParamByName('recordkey').AsInteger := RecordKey;

  if HasSubSet('ByAccountPart') and (AccountPart <> '') then
    ParamByName('accountpart').AsString := AccountPart;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctEntryLine.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTENTRYLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited DoBeforePost;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctEntryLine.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTENTRYLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM ac_entry z LEFT JOIN ac_account c ON z.accountkey = c.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctEntryLine.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcAcctEntryLine.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcAcctEntryLine.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_entry';
end;

function TgdcAcctEntryLine.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTENTRYLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTENTRYLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTENTRYLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTENTRYLINE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTENTRYLINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT ' +
            '   z.id, ' +
            '   z.entrydate, ' +
            '   z.recordkey, ' +
            '   z.accountkey, ' +
            '   z.accountpart, ' +
            '   z.debitncu, ' +
            '   z.debitcurr, ' +
            '   z.debiteq, ' +
            '   z.creditncu, ' +
            '   z.creditcurr, ' +
            '   z.crediteq, ' +
            '   z.currkey, ' +
            '   z.disabled, ' +
            '   z.reserved, ' +
            '   z.issimple, ' +
            '   c.alias, ' +
            '   c.name ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTENTRYLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTENTRYLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctEntryLine.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRecord;ByAccountPart;';
end;

procedure TgdcAcctEntryLine.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByAccountPart') then
    S.Add('z.accountpart = :accountpart');

  if HasSubSet('ByRecord') then
    S.Add('z.recordkey = :recordkey');

end;

function TgdcAcctEntryLine.Get_gdcQuantity: TgdcAcctQuantity;
begin
  if FgdcQuantity = nil then
  begin
    FgdcQuantity := TgdcAcctQuantity.Create(Self);
    FgdcQuantity.SubSet := ByEntry;
    FgdcQuantity.MasterSource := TDataSource.Create(Self);
    FgdcQuantity.MasterSource.DataSet := Self;
    FgdcQuantity.MasterField := 'id';
    FgdcQuantity.DetailField := 'entrykey';
    FgdcQuantity.Transaction := Transaction;
    FgdcQuantity.AfterPost := OnQuantityPost;
    FgdcQuantity.AfterDelete := OnQuantityDelete;
    FgdcQuantity.CachedUpdates := True;
    if Active then FgdcQuantity.Open;
  end;

  Result := FgdcQuantity;
end;

procedure TgdcAcctEntryLine.OnQuantityDelete(DataSet: TDataSet);
begin
  RecordModified(True);
  if (Owner is TgdcAcctSimpleRecord) then
     (Owner as TgdcAcctSimpleRecord).SetEntryModified;  
end;

procedure TgdcAcctEntryLine.OnQuantityPost(DataSet: TDataSet);
begin
  RecordModified(True);
  if (Owner is TgdcAcctSimpleRecord) then
     (Owner as TgdcAcctSimpleRecord).SetEntryModified;
end;


{ TgdcAcctQuantity }

function TgdcAcctQuantity.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCACCTQUANTITY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTQUANTITY', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTQUANTITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTQUANTITY',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTQUANTITY' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//Стандартные записи ищем по идентификатору
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE entrykey = %s AND valuekey = %s',
      [GetKeyField(SubType), GetListTable(SubType), FieldByName('entrykey').AsInteger, FieldByName('valuekey').AsInteger]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTQUANTITY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTQUANTITY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctQuantity.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTQUANTITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTQUANTITY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTQUANTITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTQUANTITY',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTQUANTITY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ac_quantity z ' +
    '  LEFT JOIN gd_value v ON z.valuekey = v.id  ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTQUANTITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTQUANTITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctQuantity.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'quantity';
end;

class function TgdcAcctQuantity.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_quantity';
end;

function TgdcAcctQuantity.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTQUANTITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTQUANTITY', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTQUANTITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTQUANTITY',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTQUANTITY' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
    Result := ' SELECT z.*, v.name as valuename ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTQUANTITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTQUANTITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctQuantity.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ByEntry + '; ';
end;

procedure TgdcAcctQuantity.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(ByEntry) then
    S.Add('entrykey = :entrykey');
end;

{ TgdcAcctComplexRecord }

function TgdcAcctComplexRecord.AppendLine: TgdcAcctEntryLine;
begin
  Result := TgdcAcctEntryLine.Create(nil);
  EntryLines.Add(Result);
  Result.AfterPost := OnAfterLinePost;
  Result.AfterDelete := OnAfterLineDelete;
  Result.AfterEdit := OnAfterLineEdit;
  Result.AfterInsert := OnAfterLineInsert;
  Result.Transaction := Transaction;
  Result.ReadTransaction := ReadTransaction;
  Result.SubSet := 'ByID';
  Result.ParamByName('id').AsInteger := - 1;
  Result.Open;
end;

function TgdcAcctComplexRecord.Copy(const AFields: String;
  AValues: Variant; const ACopyDetail, APost, AnAppend: Boolean): Boolean;
var
  V: array of Variant;
  I, J: Integer;
  L: TgdcAcctEntryLine;
begin
  SetLength(V, EntryLines.Count);
  for I := 0 to EntryLines.Count - 1 do
  begin
    V[I] := VarArrayCreate([0, EntryLines[I].Fields.Count - 1], varVariant);
    for J := 0 to EntryLines[I].Fields.Count - 1 do
    begin
      V[I][J] := EntryLines[I].Fields[J].Value;
    end;
  end;

  Result := inherited Copy(aFields, aValues, aCopyDetail, aPost, AnAppend);

  if Result then
  begin
    EntryLines.Clear;
    for I := VarArrayLowBound(V, 1) to VarArrayHighBound(V, 1) do
    begin
      L := AppendLine;
      L.Insert;
      for J := 0 to L.Fields.Count -1 do
      begin
        if L.Fields[J].FieldName <> 'ID' then
        begin
          L.Fields[J].Value := V[I][J];
        end;  
      end;
      L.FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;
      if APost then
        L.Post;
    end;
  end;
end;

function TgdcAcctComplexRecord.CopyObject(const ACopyDetailObjects,
  AShowEditDialog: Boolean): Boolean;
begin
  Result := Copy('', NULL, True, False) and EditDialog;
end;

constructor TgdcAcctComplexRecord.Create(AOwner: TComponent);
begin
  inherited;
  FCurrNCUKey := - 1;
  FTransactionKey := -1;
end;

procedure TgdcAcctComplexRecord.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCOMPLEXRECORD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('documentkey').Required := False;
  FieldByName('masterdockey').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctComplexRecord.DeleteLine(Id: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if FEntryLines <> nil then
  begin
    for I := 0 to FEntryLines.Count - 1 do
    begin
      if Id = FEntryLines[i].FieldByName('id').AsInteger then
      begin
        FEntryLines[I].Delete;
        FEntryLines.Delete(i);
        Result := True;
        Exit;
      end;
    end;
  end;
end;

destructor TgdcAcctComplexRecord.Destroy;
begin
  FEntryLines.Free;
  inherited;
end;

procedure TgdcAcctComplexRecord.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCOMPLEXRECORD', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FEntryLines <> nil then
  begin
    for I := 0 to FEntryLines.Count - 1 do
    begin
      if (not (FEntryLines[I].State in [dsInsert, dsEdit])) and
        (FEntryLines[I].RecordCount > 0) and
        (FEntryLines[I].FieldByName('accountkey').AsInteger > 0) then
        FEntryLines[I].Edit;
      try
        FEntryLines[I].FieldByName('recordkey').AsInteger := FieldByName('id').AsInteger;
        FEntryLines[i].FieldByName('entrydate').AsDateTime := FieldByName('recorddate').AsDateTime;
        if FEntryLines[I].FieldByName('currkey').IsNull then
          FEntryLines[I].FieldByName('currkey').Value := FieldByName('currkey').Value;
        FEntryLines[i].Post;
      except
        FEntryLines[i].Cancel;
        raise;
      end;
    end;
  end;

//  Refresh;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctComplexRecord.DoAfterScroll;
var
  SQL: TIBSQL;
  L: TgdcAcctEntryLine;
begin
  EntryLines.Clear;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQl.SQL.Text := 'SELECT id FROM ac_entry WHERE recordkey = :recordkey';
    SQL.ParamByName('recordkey').AsInteger := FieldByName('id').AsInteger;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      L := TgdcAcctentryLine.Create(nil);
      L.AfterPost := OnAfterLinePost;
      L.AfterDelete := OnAfterLineDelete;
      L.AfterEdit := OnAfterLineEdit;
      L.AfterInsert := OnAfterLineInsert;
      L.Transaction := Transaction;
      L.ReadTransaction := ReadTransaction;
      L.SubSet := 'ByID';
      L.ParamByName('Id').AsInteger := SQL.FieldByName('id').AsInteger;
      L.Open;
      EntryLines.Add(L);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;

  inherited;
end;

procedure TgdcAcctComplexRecord.DoAfterTransactionEnd(Sender: TObject);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  var
    I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCACCTCOMPLEXRECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYDOAFTERTRANSACTIONEND);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERTRANSACTIONEND]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FDSModified := False;
  if Active then
  begin
    Cancel;
    if FEntryLines <> nil then
    begin
      for I := 0 to FEntryLines.Count - 1 do
      begin
        if FEntryLines[i].Active then
        begin
          FEntryLines[i].Cancel;
          //FEntryLines[i].Refresh;
        end;
      end;
    end;
//    Refresh;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'DOAFTERTRANSACTIONEND', KEYDOAFTERTRANSACTIONEND);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctComplexRecord.DoBeforeCancel;
var
  I: Integer;
begin
  inherited;

  if FEntryLines <> nil then
  begin
    for I := 0 to FEntryLines.Count - 1 do
    begin
      FEntryLines[i].Cancel;
    end;
  end;
end;

procedure TgdcAcctComplexRecord.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCOMPLEXRECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  { TODO : Добавить проверку корректности сумм }
  if FieldByName('number').AsString = '' then
    FieldByName('number').AsString := ' ';

  if FieldByName('currkey').IsNull then
    FieldByName('currkey').AsInteger := GetCurrNCUKey;

  if FieldByName('TransactionKey').IsNull then
    FieldByName('TransactionKey').AsInteger := FTransactionKey;

  if FieldByName('documentkey').IsNull then
  begin
    FieldByName('documentkey').AsInteger := GetNextID;
    FieldByName('masterdockey').AsInteger := FieldByName('documentkey').AsInteger;

    ExecSingleQuery(
      'INSERT INTO GD_DOCUMENT ' +
      '  (ID, DOCUMENTTYPEKEY, NUMBER, DOCUMENTDATE, ' +
      '   CURRKEY, COMPANYKEY, AVIEW, ACHAG, AFULL, ' +
      '   CREATORKEY, CREATIONDATE, EDITORKEY, EDITIONDATE, TRANSACTIONKEY) ' +
      'VALUES ' +
      '  (:ID, :DOCUMENTTYPEKEY, :NUMBER, :DOCUMENTDATE, ' +
      '   :CURRKEY, :COMPANYKEY, :AVIEW, :ACHAG, :AFULL, ' +
      '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :TRANSACTIONKEY) ',
      VarArrayOf([
        FieldByName('documentkey').AsInteger,
        DefaultDocumentTypeKey,
        FieldByName('NUMBER').AsString,
        FieldByName('RECORDDATE').AsDateTime,
        FieldByName('CURRKEY').AsInteger,
        IBLogin.CompanyKey,
        FieldByName('AVIEW').AsInteger,
        FieldByName('ACHAG').AsInteger,
        FieldByName('AFULL').AsInteger,
        IBLogin.ContactKey,
        Now,
        IBLogin.ContactKey,
        Now, FieldByName('transactionkey').AsInteger
      ])
    );
  end
  else
    ExecSingleQuery(
      'UPDATE GD_DOCUMENT SET ' +
      '  NUMBER = :NUMBER, DOCUMENTDATE = :DOCUMENTDATE, ' +
      '   CURRKEY = :CURRKEY, AVIEW = :AVIEW, ACHAG = :ACHAG, AFULL = :AFULL, ' +
      '   EDITORKEY = :EDITORKEY, EDITIONDATE = :EDITIONDATE, TRANSACTIONKEY = :TRANSACTIONKEY ' +
      'WHERE ID = :ID ',
      VarArrayOf([
        FieldByName('NUMBER').AsString,
        FieldByName('RECORDDATE').AsDateTime,
        FieldByName('CURRKEY').AsInteger,
        FieldByName('AVIEW').AsInteger,
        FieldByName('ACHAG').AsInteger,
        FieldByName('AFULL').AsInteger,
        IBLogin.ContactKey,
        Now, FieldByName('transactionkey').AsInteger,
        FieldByName('documentkey').AsInteger
      ])
    );

  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctComplexRecord.GetCurrNCUKey: Integer;
var
  ibsql: TIBSQL;
begin
  if FCurrNCUKey = -1 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Database := Database;
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT id FROM gd_curr WHERE isNCU = 1';
      ibsql.ExecQuery;
      FCurrNCUKey := ibsql.FieldByName('id').AsInteger;
    finally
      ibsql.Free;
    end;
  end;
  Result := FCurrNCUKey;
end;

function TgdcAcctComplexRecord.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCACCTCOMPLEXRECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'recorddate;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctComplexRecord.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_acct_dlgEntry'
end;

function TgdcAcctComplexRecord.GetDocument: TgdcDocument;
begin
  if not Assigned(FDocument) then
  begin
    FDocument := TgdcAcctDocument.Create(Self);
    FDocument.Database := Database;
    FDocument.Transaction := Transaction;
  end;
  Result := FDocument;
end;

function TgdcAcctComplexRecord.GetEntryLines: TAcctEntryLines;
begin
  if FEntryLines = nil then
    FEntryLines := TAcctEntryLines.Create;

  Result := FEntryLines;  
end;

function TgdcAcctComplexRecord.GetFromClause(
  const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCTCOMPLEXRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM ac_record z LEFT JOIN gd_document doc ON z.documentkey = doc.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctComplexRecord.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcAcctComplexRecord.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'description';
end;

class function TgdcAcctComplexRecord.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_record';
end;

function TgdcAcctComplexRecord.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCACCTCOMPLEXRECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY,RECORDKEY'

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctComplexRecord.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCTCOMPLEXRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT ' +
            '   z.id, ' +
            '   z.trrecordkey, ' +
            '   z.transactionkey, ' +
            '   z.recorddate, ' +
            '   z.description, ' +
            '   z.documentkey, ' +
            '   z.masterdockey, ' +
            '   z.companykey, ' +
            '   z.debitncu, ' +
            '   z.debitcurr, ' +
            '   z.creditncu, ' +
            '   z.creditcurr, ' +
            '   z.delayed, ' +
            '   z.incorrect, ' +
            '   z.afull, ' +
            '   z.achag, ' +
            '   z.aview, ' +
            '   z.disabled, ' +
            '   z.reserved, ' +
            '   doc.number, ' +
            '   doc.currkey, ' +
            '   doc.documenttypekey ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctComplexRecord.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ByTransaction + ';';
end;

procedure TgdcAcctComplexRecord.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(ByTransaction) then
    S.Add(' transactionkey = :transactionkey ');
end;

procedure TgdcAcctComplexRecord.OnAfterLineDelete(DataSet: TDataSet);
begin
  SetModified(True);
  FDSModified := True;
  Edit;
end;

procedure TgdcAcctComplexRecord.OnAfterLineEdit(DataSet: TDataSet);
begin
  SetModified(True);
  FDSModified := True;
  Edit;
end;

procedure TgdcAcctComplexRecord.OnAfterLineInsert(DataSet: TDataSet);
begin
  SetModified(True);
  FDSModified := True;
  Edit;
end;

procedure TgdcAcctComplexRecord.OnAfterLinePost(DataSet: TDataSet);
begin
  SetModified(True);
  FDSModified := True;
  Edit;
end;

procedure TgdcAcctComplexRecord._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCOMPLEXRECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCOMPLEXRECORD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCOMPLEXRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCOMPLEXRECORD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCOMPLEXRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if TransactionKey <> -1 then
    FieldByName('transactionkey').AsInteger := TransactionKey
  else
    FieldByName('transactionkey').AsInteger := DefaultTransactionKey;

  FieldByName('trrecordkey').AsInteger := DefaultEntryKey;
  FieldByName('companykey').AsInteger := IBLogin.CompanyKey;


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCOMPLEXRECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCOMPLEXRECORD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TAcctEntryLines }

function TAcctEntryLines.GetLines(Index: Integer): TgdcAcctEntryLine;
begin
  Result := TgdcAcctEntryLine(Items[Index]);
end;

initialization
  RegisterGdcClass(TgdcAcctEntryRegister);
  RegisterGdcClass(TgdcAcctBaseEntryRegister);
  RegisterGdcClass(TgdcAcctViewEntryRegister);
  RegisterGdcClass(TgdcAcctEntryLine);
  RegisterGdcClass(TgdcAcctSimpleRecord);
  RegisterGdcClass(TgdcAcctQuantity);
  RegisterGdcClass(TgdcAcctComplexRecord);
finalization
  UnRegisterGdcClass(TgdcAcctEntryRegister);
  UnRegisterGdcClass(TgdcAcctBaseEntryRegister);
  UnRegisterGdcClass(TgdcAcctViewEntryRegister);
  UnRegisterGdcClass(TgdcAcctEntryLine);
  UnRegisterGdcClass(TgdcAcctSimpleRecord);
  UnRegisterGdcClass(TgdcAcctQuantity);
  UnRegisterGdcClass(TgdcAcctComplexRecord);
end.
