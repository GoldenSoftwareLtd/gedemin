
{++

  Copyright (c) 2001-2013 by Golden Software of Belarus

  Module

    gdcAcctTransaction.pas

  Abstract

    Business class. Transactions and transaction entries.

  Author

    Romanovski Denis (06-11-2001)

  Revisions history

    Initial  06-11-2001  Dennis  Initial version.
    1.10     01-03-2002  Micahel Add TgdcAcctEntryScript and TgdcAcctEntryDocument
             13-03-2002  Julie   Changed alias for main table in all scripts
--}

unit gdcAcctTransaction;

interface

uses
  Classes, gdcBase, gdcTree, gd_createable_form, Forms, gdcClasses, contnrs,
  DB, IBSQL, SysUtils, gdcBaseInterface, gd_KeyAssoc, gd_security, gdcConstants;

const
  ByTransaction = 'ByTransaction';
  ByRecord = 'ByRecord';
  ByEmptyScript = 'ByEmptyScript';

type
  //������� ����� ��������.
  TgdcBaseAcctTransaction = class(TgdcLBRBTree)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

    procedure DoBeforeDelete; override;

  public
    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function GetCurrRecordClass: TgdcFullClass; override;
  end;
  //�.�. ������� ��������
  TgdcAcctTransaction = class(TgdcBaseAcctTransaction)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcBaseAcctTransactionEntry = class(TgdcBase)
  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetCanEdit: Boolean; override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;
    function GetNotCopyField: String; override;

    procedure DoBeforeDelete; override;

  public
    procedure LoadDialogDefaults; overload; override;
    procedure SaveDialogDefaults; overload; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    function GetCurrRecordClass: TgdcFullClass; override;
  end;

  //�.�. ������� ��������
  TgdcAcctTransactionEntry = class(TgdcBaseAcctTransactionEntry)
  private
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
  end;

  EgdcAcctTransaction = class(Exception);

//������ ���� �������������� � �����������.
//������������ ��� ��������� ������������ ��������
//�� ���������
type
  TTransactionCacheItem = class(TgdKeyIntAssoc)
  private
    FFunctionKey: Integer;
    FTrRecordKey: Integer;
    FDocumentTypeKey: Integer;
    FDocumentPart: TgdcDocumentClassPart;
    procedure SetDocumentPart(const Value: TgdcDocumentClassPart);
    procedure SetDocumentTypeKey(const Value: Integer);
    procedure SetFunctionKey(const Value: Integer);
    procedure SetTrRecordKey(const Value: Integer);
  public
    property TrRecordKey: Integer read FTrRecordKey write SetTrRecordKey;
    property FunctionKey: Integer read FFunctionKey write SetFunctionKey;
    property DocumentTypeKey: Integer read FDocumentTypeKey write SetDocumentTypeKey;
    property DocumentPart: TgdcDocumentClassPart read FDocumentPart write SetDocumentPart;
  end;

  TTransactionCacheItems = class(TObjectList)
  private
    function GetItems(Index: Integer): TTransactionCacheItem;
  public
    function IndexOf(TrRecord, DocumentTypeKey: Integer; DocumentPart: TgdcDocumentClassPart): Integer;
    function Add(TrRecordKey, FunctionKey, DocumentTypeKey: Integer; DocumentPart: TgdcDocumentClassPart): Integer;
    property Items[Index: Integer]: TTransactionCacheItem read GetItems; default;
  end;

  TTransactionCache = class(TgdKeyObjectAssoc, IConnectChangeNotify)
  private
    function GetCacheItems(Key: Integer): TTransactionCacheItems;
    function GetCacheItemsByIndex(Index: Integer): TTransactionCacheItems;

    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;

    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create;
    destructor Destroy; override;

    property CacheItemsByKey[Key: Integer]: TTransactionCacheItems read GetCacheItems; default;
    property CacheItemsByIndex[Index: Integer]: TTransactionCacheItems read GetCacheItemsByIndex;
  end;

procedure Register;

function TransactionCache: TTransactionCache;

implementation

uses
  gdc_dlgAcctTransaction_unit,
  gdc_dlgAcctTrEntry_unit,
  gdc_frmAcctTransaction_unit, gd_ClassList;


procedure Register;
begin
  RegisterComponents('gdcAcctAccount', [TgdcAcctTransaction, TgdcBaseAcctTransactionEntry{,
    TgdcAcctEntryDocument}]);
end;

var
  _TransactionCache: TTransactionCache;

function TransactionCache: TTransactionCache;
begin
  if _TransactionCache = nil then
  begin
    _TransactionCache := TTransactionCache.Create;
    _TransactionCache.OwnsObjects := True;
  end;
  Result := _TransactionCache;
end;
{ TgdcAcctTransaction }

procedure TgdcBaseAcctTransaction.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCBASEACCTTRANSACTION', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTION', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTION',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  TransactionCache.Clear;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTION', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTION', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseAcctTransaction.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  i, key, documentkey: Integer;
  LocalObj: TgdcBase;
  V: OleVariant;
begin
// ��������� ������������� ������� ������� � �������: ����+���� ��� ���.+���.
  if ( (Self.ClassName = 'TgdcAutoTransaction') and
       (CD.ClassName   = 'TgdcAutoTrRecord') ) or
     ( (Self.ClassName = 'TgdcAcctTransaction') and
       (CD.ClassName   = 'TgdcAcctTransactionEntry') ) then
  begin
    for I := 0 to CD.ObjectCount - 1 do
    begin
      if CD.Obj.Locate('ID', CD.ObjectArr[I].ID, []) then
      begin
        CD.Obj.Edit;
        try
          CD.Obj.FieldByName('transactionkey').AsInteger := Self.ID;
          CD.Obj.Post;
        except
          CD.Obj.Cancel;
          raise;
        end;
      end else
      begin
              LocalObj := CgdcBase(FindClass(CD.ClassName)).CreateWithParams(nil,
          Database,
          Transaction,
          '',
          'ByID',
          CD.ObjectArr[I].ID);
        try
          CopyEventHandlers(LocalObj, CD.Obj);

          LocalObj.Open;                        
          if not LocalObj.IsEmpty then
          begin
            LocalObj.Edit;
            try
              LocalObj.FieldByName('transactionkey').AsInteger := Self.ID;
              LocalObj.Post;
            except
              LocalObj.Cancel;
              raise;
            end;
          end;
        finally
          LocalObj.Free;
        end;
      end;
    end;
    Result := True;
  end else         // ��������
    if ( (Self.ClassName = 'TgdcBaseAcctTransaction') and
         (CD.ClassName   = 'TgdcAcctViewEntryRegister') ) then
    begin
// �� ������������ ��. �����.
      for I := 0 to CD.ObjectCount - 1 do
      begin

        key := -1;
        documentkey := -1;
        if CD.Obj.Locate('ID', CD.ObjectArr[I].ID, []) then
          key := CD.Obj.FieldByName('recordkey').AsInteger
        else begin
          ExecSingleQueryResult('SELECT recordkey, documentkey FROM ac_entry WHERE id = :id',
            VarArrayOf([CD.ObjectArr[I].ID]), V);
          if VarType(V) <> VarEmpty then
          begin
            key := Integer(V[0, 0]);
            documentkey := Integer(V[1, 0]);
          end
        end;
        if (Key > -1) and (DocumentKey > -1) then
        begin
          ExecSingleQuery('UPDATE ac_record SET transactionkey = :TrKey WHERE ID = :ID',
            VarArrayOf([Self.ID, Key]));
          ExecSingleQuery('UPDATE gd_document SET transactionkey = :TrKey WHERE ID = :ID',
            VarArrayOf([Self.ID, documentkey]));
        end;
      end;
      Result := True;
    end else
      Result := inherited AcceptClipboard(CD);
end;

function TgdcBaseAcctTransaction.GetCurrRecordClass: TgdcFullClass;
var
  s: string;
  F: TField;
begin
  S := '';                                   
  if FieldByName(fnAutoTransaction).AsInteger = 1 then
  begin
    S := 'TgdcAutoTransaction';
  end else
  begin
    S := 'TgdcAcctTransaction';
  end;
  if S <> '' then
  begin
    Result.gdClass := CgdcBase(GetClass(S));
    Result.SubType := '';

    F := FindField('USR$ST');
    if F <> nil then
      Result.SubType := F.AsString;
    if (Result.SubType > '') and (not Result.gdClass.CheckSubType(Result.SubType)) then
      raise EgdcException.Create('Invalid USR$ST value.');
  end else
    Result := inherited GetCurrRecordClass;
end;

class function TgdcBaseAcctTransaction.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcBaseAcctTransaction.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_transaction';
end;

class function TgdcBaseAcctTransaction.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByCompany;';
end;

procedure TgdcBaseAcctTransaction.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByCompany') then
  begin
    S.Add('(Z.companykey IS NULL OR z.companykey IN (' + IBLogin.HoldingList + '))');
  end;
end;

class function TgdcBaseAcctTransaction.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

{ TgdcAcctTransaction }

class function TgdcAcctTransaction.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAcctTransaction'
end;

class function TgdcAcctTransaction.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctTransaction'
end;

procedure TgdcAcctTransaction.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  S.Add(' (Z.AUTOTRANSACTION IS NULL OR Z.AUTOTRANSACTION = 0) ');
end;

{ TgdcBaseAcctTransactionEntry }

procedure TgdcBaseAcctTransactionEntry.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(ByTransaction) then
    S.Add(' z.transactionkey = :TransactionKey ')
  else if HasSubSet(ByRecord) then
    S.Add(' z.id = :RecordKey ');
end;


function TgdcBaseAcctTransactionEntry.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCBASEACCTTRANSACTIONENTRY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTIONENTRY', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTIONENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTIONENTRY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTIONENTRY' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ORDER BY z.description'
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTIONENTRY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTIONENTRY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseAcctTransactionEntry.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ByRecord + ';' + ByTransaction + ';';
end;

class function TgdcBaseAcctTransactionEntry.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

function TgdcBaseAcctTransactionEntry.GetCanEdit: Boolean;
begin
  Result := inherited GetCanEdit;
  if Result and (not IsEmpty) then
    Result := ID <> 807100; // ������������ ��������. ������������ � �������.
end;

procedure TgdcBaseAcctTransactionEntry.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCBASEACCTTRANSACTIONENTRY', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTIONENTRY', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTIONENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTIONENTRY',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTIONENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  TransactionCache.Clear;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTIONENTRY', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTIONENTRY', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseAcctTransactionEntry.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASEACCTTRANSACTIONENTRY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTIONENTRY', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTIONENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTIONENTRY',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TGDCBASEACCTTRANSACTIONENTRY(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTIONENTRY' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',' + fnFunctionKey;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTIONENTRY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTIONENTRY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseAcctTransactionEntry.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ac_trrecord';
end;

class function TgdcBaseAcctTransactionEntry.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'description'
end;

class function TgdcBaseAcctTransactionEntry.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id'
end;

function TgdcBaseAcctTransactionEntry.GetCurrRecordClass: TgdcFullClass;
var
  F: TField;
var
  s: string;
  SQL: TIBSQL;
  DidActivate: Boolean;
begin
  S := '';
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    DidActivate := not Transaction.InTransaction;
    if DidActivate then
      Transaction.StartTransaction;
    try
      if State = dsInsert then
      begin
        //��� ������� ������
        //������ ��� ���������� ������� ��������
        //������ � ac_autotrrecord ��� ���
        { TODO : 
        � ������ ����� ����� ���������� �������� � �������
        ac_trrecord ���� ���������������� ����� �������
        ����� ������������� ������ ������ }
        if (FindField(fnImageIndex) <> nil) and
          (FindField(fnFolderKey) <> nil) then
        begin
          S := 'TgdcAutoTrRecord';
        end else
        begin
          S := 'TgdcAcctTransactionEntry';
        end;
      end else
      begin
        SQL.SQl.Text := 'SELECT * FROM ac_autotrrecord WHERE id = :id';
        SQL.ParamByName(fnId).AsInteger := Id;
        SQl.ExecQuery;
        if SQL.RecordCount > 0 then
        begin
          S := 'TgdcAutoTrRecord';
        end else
        begin
          S := 'TgdcAcctTransactionEntry';
        end;
      end;
      if S <> '' then
      begin
        Result.gdClass := CgdcBase(GetClass(S));
        Result.SubType := '';

        F := FindField('USR$ST');
        if F <> nil then
          Result.SubType := F.AsString;
        if (Result.SubType > '') and (not Result.gdClass.CheckSubType(Result.SubType)) then
          raise EgdcException.Create('Invalid USR$ST value.');
      end else
        Result := inherited GetCurrRecordClass;
      if DidActivate then
        Transaction.Commit;
    except
      if DidActivate then
        Transaction.Rollback;
      raise;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcBaseAcctTransactionEntry.LoadDialogDefaults;
begin

end;

procedure TgdcBaseAcctTransactionEntry.SaveDialogDefaults;
begin

end;

procedure TgdcBaseAcctTransactionEntry.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEACCTTRANSACTIONENTRY', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTIONENTRY', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTIONENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTIONENTRY',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTIONENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    ibsql.SQL.Text := 'SELECT * FROM ac_record WHERE trrecordkey = :trkey';
    ibsql.ParamByName('trkey').AsInteger := ID;
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      raise EgdcIBError.Create(Format('�������� ����������: %s %s � ��������������� %d ������������ � ���������!',
        [GetDisplayName(SubType), FieldByName(GetListField(SubType)).AsString, ID]));
  finally
    ibsql.Free;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTIONENTRY', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTIONENTRY', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

{ TTransactionCache }

procedure TTransactionCache.DoAfterConnectionLost;
begin

end;

procedure TTransactionCache.DoAfterSuccessfullConnection;
begin
  Clear;
end;

procedure TTransactionCache.DoBeforeDisconnect;
begin

end;

function TTransactionCache.GetCacheItems(
  Key: Integer): TTransactionCacheItems;
begin
  Result := TTransactionCacheItems(ObjectByKey[Key])
end;

function TTransactionCache.GetCacheItemsByIndex(
  Index: Integer): TTransactionCacheItems;
begin
  Result := TTransactionCacheItems(ObjectByIndex[Index])
end;

function TTransactionCache._AddRef: Integer;
begin
  Result := 0;
end;

function TTransactionCache._Release: Integer;
begin
  Result := 0;
end;

function TTransactionCache.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := 0;
  
end;

constructor TTransactionCache.Create;
begin
  if IbLogin <> nil then
  begin
    IbLogin.AddConnectNotify(Self)
  end;
end;

destructor TTransactionCache.Destroy;
begin
  if IbLogin <> nil then
  begin
    IbLogin.RemoveConnectNotify(Self)
  end;

  inherited;
end;

{ TTransactionCacheItem }

procedure TTransactionCacheItem.SetDocumentPart(
  const Value: TgdcDocumentClassPart);
begin
  FDocumentPart := Value;
end;

procedure TTransactionCacheItem.SetDocumentTypeKey(const Value: Integer);
begin
  FDocumentTypeKey := Value;
end;

procedure TTransactionCacheItem.SetFunctionKey(const Value: Integer);
begin
  FFunctionKey := Value;
end;

procedure TTransactionCacheItem.SetTrRecordKey(const Value: Integer);
begin
  FTrRecordKey := Value;
end;

{ TgdcAcctTransactionEntry }

class function TgdcAcctTransactionEntry.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgAcctTrEntry';
end;

procedure TgdcAcctTransactionEntry.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('(NOT EXISTS(SELECT id FROM ac_autotrrecord WHERE id = z.id))');
end;

procedure TgdcBaseAcctTransaction.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEACCTTRANSACTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEACCTTRANSACTION', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEACCTTRANSACTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEACCTTRANSACTION',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEACCTTRANSACTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    ibsql.SQL.Text := 'SELECT * FROM ac_record WHERE transactionkey = :trkey';
    ibsql.ParamByName('trkey').AsInteger := ID;
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      raise EgdcIBError.Create(Format('�������� ����������: %s %s � ��������������� %d ������������ � ���������!',
        [GetDisplayName(SubType), FieldByName(GetListField(SubType)).AsString, ID]));
  finally
    ibsql.Free;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEACCTTRANSACTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEACCTTRANSACTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}

end;

{ TTransactionCacheItems }

function TTransactionCacheItems.Add(TrRecordKey, FunctionKey, DocumentTypeKey: Integer;
  DocumentPart: TgdcDocumentClassPart): Integer;
var
  Index: Integer;
  CI: TTransactionCacheItem;
begin
  Index := IndexOf(TrRecordKey, DocumentTypeKey, DocumentPart);
  if Index = - 1 then
  begin
    CI := TTransactionCacheItem.Create;
    Index := inherited Add(CI);
    CI.TrRecordKey := TrRecordKey;
    CI.FunctionKey := FunctionKey;
    CI.DocumentTypeKey := DocumentTypeKey;
    CI.DocumentPart := DocumentPart;
  end;

  Result := Index;
end;

function TTransactionCacheItems.GetItems(
  Index: Integer): TTransactionCacheItem;
begin
  Result := TTransactionCacheItem(inherited Items[Index]);
end;

function TTransactionCacheItems.IndexOf(
  TrRecord, DocumentTypeKey: Integer;
  DocumentPart: TgdcDocumentClassPart): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if (Items[i].TrRecordKey = TrRecord) and
      (Items[i].DocumentTypeKey = DocumentTypeKey) and
      (Items[i].DocumentPart = DocumentPart) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

initialization
  RegisterGdcClass(TgdcAcctTransaction, ctStorage, '������� ��������');
  RegisterGdcClass(TgdcAcctTransactionEntry, ctStorage, '������� ��������');
  RegistergdcClass(TgdcBaseAcctTransaction);

finalization
  UnRegisterGdcClass(TgdcAcctTransaction);
  UnRegisterGdcClass(TgdcAcctTransactionEntry);
  UnRegisterGdcClass(TgdcBaseAcctTransaction);

  FreeAndNil(_TransactionCache);
end.

