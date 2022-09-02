// ShlTanya, 09.02.2019

{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    gdcClasses.pas

  Abstract

    Business classes. Document base classes.

  Author

    Smirnov Anton (29.10.00),
    Romanovski Denis,
    Shoihet Michael

  Revisions history

    1.00    29.10.00    sai        Initial version.
    2.00    02.12.01    deniis     Second Version. DocumentType classes added.
    3.00    08.02.01    michael    Third Version. UserDocuments classes done.
    3.01    16.07.02    Julie      Changed Subtype of user documents.

--}

unit gdcClasses;

interface

uses
  Classes,      IBCustomDataSet,   IBDataBase,     gdcBase,
  gdcTree,      Forms,             gd_createable_form,
  at_classes,   gdcBaseInterface,  DB,             gd_KeyAssoc,
  gdcConstants, gd_i_ScriptFactory,gdcClasses_Interface,
  gd_security,  gdcOLEClassList,   DBGrids,        Contnrs,
  gd_ClassList, IBSQL;

{$IFDEF DEBUGMOVE}
const
  TimeDoOnNewRecordClasses: LongWord = 0;
{$ENDIF}

type
  TgdcDocument = class;
  CgdcDocument = class of TgdcDocument;

  TgdcDocument = class(TgdcTree)
  private
    FgdcAcctEntryRegister: TgdcBase;
    FNumberUpdated: Boolean;
    FLastNumber, FAddNumber: Integer;
    FNumberCompanyKey: TID;
    FMask: String;
    FAutoNumber: String;

    procedure UpdateLineFromHeader;

    function GetDocumentDescription: String;
    function GetDocumentName: String;
    function GetIsCommon: Boolean;

    function GetNextNumber: String;
    procedure MakeRollbackNumber;
    function GetgdcAcctEntryRegister: TgdcBase;
    procedure CheckNumber(Field: TField);
    function GetIsCheckNumber: TIsCheckNumber;

  protected
    FIsCommon: Boolean;
    FTransactionFunction: TID;
    FDocumentTypeKey: TID;
    FBranchKey: TID;

    procedure SetSubType(const Value: TgdcSubType); override;
    procedure ReadOptions(DE: TgdDocumentEntry); virtual;

    // ������ ������. OnClick - � PopupMenu
    procedure DoOnReportClick(Sender: TObject); override;

    procedure MakeEntry; virtual;

    procedure _DoOnNewRecord; override;
    procedure DoBeforeCancel; override;
    procedure DoBeforePost; override;

    function GetSelectClause: String; override;

    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function GetNotCopyField: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); override;

    //��������� ������� ��������� ��������������
    procedure ExecuteTransactionFunction;
    function GetMasterObject: TgdcDocument; virtual;
    function GetDetailObject: TgdcDocument; virtual;
    function HaveIsDetailObject: Boolean;

    function GetSecCondition: String; override;

    function GetCanChangeRights: Boolean; override;
    function GetCanCreate: Boolean; override;
    function GetCanDelete: Boolean; override;
    function GetCanEdit: Boolean; override;
    function GetCanPrint: Boolean; override;
    function GetCanView: Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateEntry;

    class function ClassDocumentTypeKey: Integer; virtual;
    function DocumentTypeKey: TID; virtual;
    function Reduction(BL: TBookmarkList): Boolean; override;
    function EditDialog(const ADlgClassName: String = ''): Boolean; override;

    class function GetDocumentClassPart: TgdcDocumentClassPart; virtual;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    function GetObjectName: String; override;

    class function HasLeafs: Boolean; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    // ���������� ����� ���������
    class function GetDocumentClass(const TypeKey: TID;
      const DocClassPart: TgdcDocumentClassPart): TgdcFullClass;

    property DocumentName: String read GetDocumentName;
    property DocumentDescription: String read GetDocumentDescription;

    property gdcAcctEntryRegister: TgdcBase read GetgdcAcctEntryRegister;

    property IsCommon: Boolean read GetIsCommon;
    property IsCheckNumber: TIsCheckNumber read GetIsCheckNumber;
  end;

  TgdcBaseDocumentType = class(TgdcLBRBTree)
  private
    function GetDocLineRelationName: String;
    function GetDocRelationName: String;
    function GetIsComplexDocument: Boolean;

  protected
    function GetParent: TID; override;
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetNotCopyField: String; override;
    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function CheckTheSameStatement: String; override;
    function UpdateReportGroup(MainBranchName: String; DocumentName: String;
      var GroupKey: TID; const ShouldUpdateData: Boolean = False): Boolean;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function IsAbstractClass: Boolean; override;

    property DocRelationName: String read GetDocRelationName;
    property DocLineRelationName: String read GetDocLineRelationName;
    property IsComplexDocument: Boolean read GetIsComplexDocument;
  end;

  TgdcDocumentBranch = class(TgdcBaseDocumentType)
  protected
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcDocumentType = class(TgdcBaseDocumentType)
  protected
    FqGetOptID, FqDel, FqRUID, FqNS, Fq, FqFindObj: TIBSQL;
    FNSID, FHeadObjectKey: TID;
    FNSPos: Integer;

    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetParentSubType: String;

  public
    destructor Destroy; override;

    class function GetHeaderDocumentClass: CgdcBase; virtual;
    procedure FullCopyDocument; virtual;

    class function IsAbstractClass: Boolean; override;

    procedure DoAfterShowDialog(DlgForm: TCreateableForm; IsOk: Boolean); override;
    function GetCurrRecordClass: TgdcFullClass; override;
    procedure InitOpt; virtual;
    procedure DoneOpt; virtual;
    function GetOptID(const AName: String; out AnOptID: TID): Boolean;
    procedure DelOpt(const AName: String);
    procedure AddNSObject(const AnObjID: TID; const AName: String; const ADependentOnID: TID = -1);
  end;

  TgdcUserDocumentType = class(TgdcDocumentType)
  protected
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

  public
    constructor Create(AnOwner: TComponent); override;
    procedure FullCopyDocument; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetHeaderDocumentClass: CgdcBase; override;
  end;

  TgdcUserBaseDocument = class(TgdcDocument)
  protected
    procedure SetActive(Value: Boolean); override;
    function EnumRelationFields(RelationName: String; const AliasName: String = '';
      const UseDot: Boolean = True): String;

    function EnumModificationList(RelationName: String): String;
    procedure _DoOnNewRecord; override;

    function GetNotCopyField: String; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

  public
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function IsAbstractClass: Boolean; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcUserDocument = class(TgdcUserBaseDocument)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

    function GetDetailObject: TgdcDocument; override;
    function GetCompoundMasterTable: String; override;
    procedure CheckCompoundClasses; override;

  public
    class function GetSubSetList: String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcUserDocumentLine = class(TgdcUserBaseDocument)
  protected
    procedure DoBeforeInsert; override;

    function GetMasterObject: TgdcDocument; override;
    function GetCompoundMasterTable: String; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetDocumentClassPart: TgdcDocumentClassPart; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  function EncodeNumber(const AMask: String; const ALastNumber: Integer;
    const ADate: TDateTime; const FixLength: Integer{ = 0}): String;

procedure Register;

implementation

uses
  SysUtils, Windows,

  IBErrorCodes,

  gdc_frmG_unit,

  gd_security_operationconst,

  gdcInvDocument_unit,
  gdcEvent,

  gdcAcctEntryRegister,

  gdc_dlgDocBranch_unit,
  gdc_frmDocumentType_unit,
  gdc_dlgUserDocumentSetup_unit,
  gdc_frmUserSimpleDocument_unit,
  gdc_frmUserComplexDocument_unit,
  gdc_dlgUserSimpleDocument_unit,
  gdc_dlgUserComplexDocument_unit,
  gdc_dlgDocumentType_unit,
  gdc_dlgUserDocumentLine_unit,
  gd_directories_const,
  IB, gdc_frmMDH_unit,
  gd_resourcestring,
  mtd_i_Base,

  jclStrings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  ss_ByIntervalDate = 'ByIntervalDate';

  NumerationVarCount = 7;

  // �����, ����� ���������� "NUMBER" ���� ������ � �������
  // � � ������� ���������
  NumerationVars: array[0..6] of String =
    ('"NUMBER"',
     '"DAY"',
     '"MONTH"',
     '"YEAR"',
     '"MONTHSTR"',
     '"COMPUTER"',
     '"USER"');

const
{SQL ��� ������ � ���������� ���������� ���������}
  cst_sql_GetLastNumber =
    'SELECT * FROM gd_lastnumber WHERE ourcompanykey = :ck ' +
    ' AND documenttypekey = :dtk ';
  cst_sql_InsertLastNumber =
    'INSERT INTO gd_lastnumber ' +
    ' (documenttypekey, ourcompanykey, lastnumber, addnumber, mask, fixlength) ' +
    ' VALUES (:dtk, :ck, :lastnumber, :addnumber, :mask, :fixlength) ';
  cst_sql_ReturnLastNumber =
    'UPDATE gd_lastnumber ' +
    ' SET lastnumber = lastnumber - addnumber ' +
    ' WHERE ourcompanykey = :ck AND documenttypekey = :dtk AND lastnumber = :lastnumber ';
  cst_sql_NextNumber =
    'UPDATE gd_lastnumber ' +
    ' SET lastnumber = lastnumber + addnumber ' +
    ' WHERE ourcompanykey = :ck AND documenttypekey = :dtk ';
  cst_sql_UpdateLastNumber =
    'UPDATE gd_lastnumber ' +
    ' SET lastnumber = :lastnumber, addnumber = :addnumber, mask = :mask, fixlength = :fixlength ' +
    ' WHERE ourcompanykey = :ck AND documenttypekey = :dtk ';

procedure Register;
begin
  RegisterComponents('gdc', [TgdcDocumentBranch, TgdcDocumentType,
    TgdcUserDocument, TgdcUserDocumentLine, TgdcBaseDocumentType]);
end;

function EncodeNumber(const AMask: String; const ALastNumber: Integer;
  const ADate: TDateTime; const FixLength: Integer{ = 0}): String;
const
  NumericArray = ['0'..'9'];
var
  I: Integer;
  J: DWord;
  Substitute: String;
  Y, M, D: Word;
  C: array [0..255] of Char;
begin
  Result := AMask;

  if Result = '' then
    exit;

  Substitute := '';

  DecodeDate(ADate, Y, M, D);

  for I := 0 to NumerationVarCount - 1 do
  begin
    if StrIPos(NumerationVars[I], Result) > 0 then
    begin
      case I of
        0: // �����
          Substitute := IntToStr(ALastNumber);
        1: // ����
          Substitute := IntToStr(D);
        2: // �����
          Substitute := IntToStr(M);
        3: // ���
          Substitute := IntToStr(Y);
        4: //
          Substitute := LongMonthNames[M];
        5: // ���������
        begin
          J := MAX_COMPUTERNAME_LENGTH + 1;
          GetComputerName(@C, J);
          Substitute := StrPas(C);
        end;
        6: // ��������
          Substitute := IBLogin.UserName;
      end;

      Result := StringReplace(Result, NumerationVars[I], Substitute,
        [rfReplaceAll, rfIgnoreCase]);

    end;
  end;

  {���� ������ ������������� ����� ������ � ����� ���������� � �����, �� �������� ��� ������ �� �������� �����}
  if (Length(Result) > 0) and (Result[1] in NumericArray) then
  begin
    while Length(Result) < FixLength do
      Result := '0' + Result;
  end;
end;

{ TgdcDocument }

constructor TgdcDocument.Create(AnOwner: TComponent);
begin
  inherited;

{ TODO :
���� � ����� ��������� ��� ������ �������� ��
��������� ����������� ��� ��� ��� �� ����
� ������������� � ��� ����������� ������� ������� ������
�������. ���� ��������� ��� �������� ����� ������... }
  CustomProcess := [cpInsert, cpModify];

  FDocumentTypeKey := -1;
  FBranchKey := -1;
end;

procedure TgdcDocument._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
{$IFDEF DEBUGMOVE}
TempTime: LongWord;
{$ENDIF}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

{$IFDEF DEBUGMOVE}
  TempTime := GetTickCount;
{$ENDIF}

  if not(sLoadFromStream in BaseState) then
  begin
    FNumberUpdated := False;

    SetTID(FieldByName('DOCUMENTTYPEKEY'), DocumentTypeKey);
    SetTID(FieldByName('COMPANYKEY'), IBLogin.CompanyKey);

    if GetDocumentClassPart = dcpHeader then
    begin
      FieldByName('DOCUMENTDATE').AsDateTime := Now;
      //����� ������ ������������� ��� ���������� ����� ��������
      //FieldByName('NUMBER').AsString := GetNextNumber;
      FieldByName('PARENT').Clear;
    end else
      UpdateLineFromHeader;

    FieldByName('DISABLED').AsInteger := 0;
  end;

{$IFDEF DEBUGMOVE}
  TimeDoOnNewRecordClasses := TimeDoOnNewRecordClasses + GetTickCount - TempTime;
{$ENDIF}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcDocument.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NUMBER';
end;

class function TgdcDocument.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_DOCUMENT';
end;

function TgdcDocument.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.id, ' +
    '  z.parent, ' +
    '  z.documenttypekey, ' +
    '  z.trtypekey, ' +
    '  z.transactionkey, ' +
    '  z.number, ' +
    '  z.documentdate, ' +
    '  z.description, ' +
    '  z.sumncu, ' +
    '  z.sumcurr, ' +
    '  z.sumeq, ' +
    '  z.delayed, ' +
    '  z.afull, ' +
    '  z.achag, ' +
    '  z.aview, ' +
    '  z.currkey, ' +
    '  z.companykey, ' +
    '  z.creatorkey, ' +
    '  z.creationdate, ' +
    '  z.editorkey, ' +
    '  z.editiondate, ' +
    '  z.printdate, ' +
    '  z.disabled, ' +
    '  z.reserved ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcDocument.GetWhereClauseConditions(S: TStrings);

  procedure _Traverse(CE: TgdClassEntry; var IDs: String);
  var
    I: Integer;
  begin
    for I := 0 to CE.Count - 1 do
      _Traverse(CE.Children[I], IDs);
    IDs := IDs + TID2S((CE as TgdDocumentEntry).TypeID) + ',';
  end;

var
  CE: TgdClassEntry;
  IDs: String;
begin
  Assert(IBLogin <> nil);

  inherited;

  if HasSubSet(ss_ByIntervalDate) then
    S.Add(' z.documentdate >= :datebegin  AND z.documentdate <= :dateend ');

  if ClassName <> 'TgdcDocument' then
  begin
    if SubType > '' then
    begin
      CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, Self.SubType);
      IDs := '';
      _Traverse(CE, IDs);

      if IDs > '' then
      begin
        SetLength(IDs, Length(IDs) - 1);
        S.Add('z.documenttypekey IN (' + IDs + ')');
      end;
    end
    else if DocumentTypeKey > 0 then
      S.Add(' z.documenttypekey = ' + TID2S(DocumentTypeKey));

    if GetDocumentClassPart = dcpLine then
      S.Add('z.parent + 0 IS NOT NULL')
    else
      S.Add('z.parent + 0 IS NULL');
  end;

  if not IsCommon and not HasSubSet('ByID') and not HasSubSet('ByParent') then
    S.Add('z.companykey + 0 in (' + IBLogin.HoldingList + ')');
end;

procedure TgdcDocument.DoOnReportClick(Sender: TObject);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  GridBm: TBookmarkList;
  ibsql: TIBSQL;
  DidActivate: Boolean;
  FPrintList: String;
begin
  {@UNFOLD MACRO INH_ORIG_SENDER('TGDCDOCUMENT', 'DOONREPORTCLICK', KEYDOONREPORTCLICK)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYDOONREPORTCLICK);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOONREPORTCLICK]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          'DOONREPORTCLICK', KEYDOONREPORTCLICK, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  // �������� ������ ������ ����� ����
  if not Owner.InheritsFrom(Tgdc_frmG) then
  begin
    inherited;
    Exit;
  end;

  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    if (Owner is Tgdc_frmMDH) and (Self = (Owner as Tgdc_frmMDH).gdcDetailObject) then
      GridBm := (Owner as Tgdc_frmMDH).GetDetailBookmarkList
    else
      GridBm := (Owner as Tgdc_frmG).GetMainBookmarkList;

    if (GridBm <> nil) and (GridBm.Count > 0) then
    begin
      FPrintList := '';
      for I := 0 to GridBm.Count - 1 do
      begin
        if I > 1000 then
          break;
        FPrintList := FPrintList + TID2S(GetIDForBookmark(GridBm[I])) + ',';
      end;
      if FPrintList > '' then
        SetLength(FPrintList, Length(FPrintList) - 1);
    end
    else
      FPrintList := TID2S(Self.ID);

    ibsql.Transaction := Transaction;
    DidActivate := ActivateTransaction;

    ibsql.SQL.Text := 'UPDATE GD_DOCUMENT SET PRINTDATE=:D WHERE ID IN (' +
      FPrintList + ')';
    ibsql.ParamByName('D').AsDateTime := Now;

    try
      ibsql.ExecQuery;
      ibsql.Close;
    except
      on E: EIBError do
      begin
        if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
        begin
           if MessageBox(ParentHandle,
             '������ �������� ��������� �� ��������������.'#13#10 +
             '�������� ������ ��� ��������. ���������� ������?',
             '��������',
             MB_YESNO or MB_TASKMODAL or MB_ICONWARNING) = IDNO then
           begin
            Abort;
           end;
        end
        else if E.IBErrorCode <> isc_except then
          raise;
      end;
    end;

    if DidActivate then
      Transaction.Commit;

    Self.Refresh;  

    inherited;
  finally
    ibsql.Free;
    if Transaction.InTransaction and DidActivate then
      Transaction.Commit;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'DOONREPORTCLICK', KEYDOONREPORTCLICK)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'DOONREPORTCLICK', KEYDOONREPORTCLICK);
  {M}  end;
  {END MACRO}
end;

function TgdcDocument.GetDocumentDescription: String;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, GetDocumentClassPart, True);
  if DE <> nil then
    Result := DE.Description
  else
    Result := '';
end;

function TgdcDocument.GetDocumentName: String;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, GetDocumentClassPart, True);
  if DE <> nil then
    Result := DE.Caption
  else
    Result := '';
end;

procedure TgdcDocument.DoBeforeCancel;
begin
  inherited;

  if FNumberUpdated then
  begin
    if (GetDocumentClassPart = dcpHeader)
      and (FAddNumber <> 0)
      and (not (sPost in BaseState)) then
    begin
      MakeRollbackNumber;
    end;

    FNumberUpdated := False;
  end;
end;

destructor TgdcDocument.Destroy;
begin
  FreeAndNil(FgdcAcctEntryRegister);
  inherited;
end;

procedure TgdcDocument.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ibsql: TIBSQL;
  AnNumber: String;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDOCUMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  ExecuteTransactionFunction;

  inherited;

  if GetDocumentClassPart = dcpHeader then
  begin
    with FieldByName('NUMBER') do
      if (Length(AsString) > 1) and (System.Copy(AsString, Length(AsString), 1) = ' ') then
        AsString := TrimRight(AsString);

    CheckNumber(FieldByName('NUMBER'));

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := cst_sql_GetLastNumber;
      SetTID(ibsql.ParamByName('ck'), FieldByName('companykey'));
      SetTID(ibsql.ParamByName('dtk'), FieldByName('documenttypekey'));
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        AnNumber := FieldByName('number').AsString;
        if (ibsql.FieldByName('fixlength').AsInteger > 0) and (Length(AnNumber) > 0) and
          (AnNumber[1] in ['0'..'9'])
        then
        begin
          while Length(AnNumber) < ibsql.FieldByName('fixlength').AsInteger do
            AnNumber := '0' + AnNumber;
          FieldByName('number').AsString := AnNumber;
        end;
      end;
    finally
      ibsql.Free;
    end;
  end else
  begin
    with FgdcDataLink do
    begin
      if Active and (DataSet is TgdcDocument) and
        (GetTID(FieldByName('companykey')) <> GetTID(DataSet.FieldByName('companykey')))
      then
        SetTID(FieldByName('companykey'), DataSet.FieldByName('companykey'));
      if Active and (DataSet is TgdcDocument) and
        (FieldByName('documentdate').AsDateTime <> DataSet.FieldByName('documentdate').AsDateTime)
      then
        FieldByName('documentdate').AsDateTime := DataSet.FieldByName('documentdate').AsDateTime;
    end;
  end;

  FAutoNumber := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcDocument.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpHeader;
end;

procedure TgdcDocument.UpdateLineFromHeader;
var
  q: TIBSQL;
begin
  //
  //  ���� ���� ������ ����� mster-detail

  with FgdcDataLink do
    if Active and (DataSet is TgdcDocument) then
    begin
      FieldByName('NUMBER').AsString :=
        DataSet.FieldByName('NUMBER').AsString;

      FieldByName('DOCUMENTDATE').AsDateTime :=
        DataSet.FieldByName('DOCUMENTDATE').AsDateTime;

    end else

    //
    //  ���� ���� ������ ��� mster-detail

    if not FieldByName('PARENT').IsNull then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := ReadTransaction;

        q.SQL.Text := 'SELECT NUMBER, DOCUMENTDATE FROM GD_DOCUMENT WHERE ID = ' +
          FieldByName('PARENT').AsString;

        q.ExecQuery;

        FieldByName('NUMBER').AsString :=
          q.FieldByName('NUMBER').AsString;

        FieldByName('DOCUMENTDATE').AsDateTime :=
          q.FieldByName('DOCUMENTDATE').AsDateTime;
      finally
        q.Free;
      end;
    end;
end;

procedure TgdcDocument.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCDOCUMENT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (Process = cpInsert) or (Process = cpModify) then
    MakeEntry;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcDocument.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField;
  
  if not ((GetDocumentClassPart = dcpLine) and not Assigned(MasterSource)) then
  begin
    Result := Result + ',NUMBER,DOCUMENTDATE';

    if GetDocumentClassPart <> dcpHeader then
      Result := Result + ',PARENT';
  end
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcDocument.MakeEntry;
var
  DetailDoc: TgdcDocument;
  i: Integer;
  EntryRegister: TgdcAcctEntryRegister;
  dsMaster: TDataSource;
  gdcMaster: TgdcDocument;
  Bookmark: String;
  ibsql: TIBSQL;
  isCreateEntry: Boolean;
begin
  if UnMethodMacro then
    exit;

  EntryRegister := gdcAcctEntryRegister as TgdcAcctEntryRegister;
  if EntryRegister.Active then EntryRegister.Close;

  if (GetDocumentClassPart = dcpLine) and not Assigned(MasterSource) then
  begin
    if GetTID(FieldByName('transactionkey')) > 0 then
    begin
      dsMaster := TDataSource.Create(Self);
      gdcMaster := GetMasterObject;
      if not Assigned(gdcMaster) then
        exit;
      dsMaster.DataSet := gdcMaster;
      gdcMaster.Transaction := Transaction;
      gdcMaster.ReadTransaction := ReadTransaction;
      gdcMaster.SubSet := 'ByID';
      gdcMaster.ID := GetTID(FieldByName('parent'));
      gdcMaster.Open;
      FIsInternalMasterSource := True;
    end
    else
      exit;
  end
  else
  begin
    dsMaster := nil;
    gdcMaster := nil;
  end;

  try
    EntryRegister.Transaction := Transaction;
    EntryRegister.ReadTransaction := ReadTransaction;
    EntryRegister.CreateEntry;
    if FieldByName('PARENT').IsNull then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := Transaction;
        ibsql.SQL.Text := 'SELECT id FROM gd_document doc WHERE ' +
          ' doc.transactionkey IS NOT NULL and doc.parent = :id ';
        SetTID(ibsql.ParamByName('id'), FieldByName('id'));
        ibsql.ExecQuery;
        isCreateEntry := ibsql.RecordCount > 0;
      finally
        ibsql.Free;
      end;

      if isCreateEntry then
      begin

        for i:= 0 to DetailLinksCount - 1 do
          if UpperCase(DetailLinks[i].ClassName) = UpperCase(ClassName) +  'LINE' then
          begin
            DetailDoc := DetailLinks[i] as TgdcDocument;

            if Assigned(DetailDoc) and DetailDoc.Active then
            begin
              if not (DetailDoc.State in [dsEdit, dsInsert]) then
              begin
                Bookmark := DetailDoc.Bookmark;
                DetailDoc.DisableControls;
                try
                  DetailDoc.First;
                  while not DetailDoc.EOF and (GetTID(DetailDoc.FieldByName('parent')) = GetTID(FieldByName('id'))) do
                  begin
                    DetailDoc.MakeEntry;
                    DetailDoc.Next;
                  end;
                finally
                  DetailDoc.Bookmark := Bookmark;
                  DetailDoc.EnableControls;
                end;
              end;
            end;
          end;

        if (DetailLinksCount = 0) and HaveIsDetailObject then
        begin
          DetailDoc := GetDetailObject;
          dsMaster := TDataSource.Create(Self);
          dsMaster.DataSet := Self;
          DetailDoc.SubSet := 'ByParent';
          DetailDoc.MasterField := 'ID';
          DetailDoc.DetailField := 'Parent';
          DetailDoc.MasterSource := dsMaster;
          DetailDoc.Open;

          DetailDoc.First;
          while not DetailDoc.EOF and (GetTID(DetailDoc.FieldByName('parent')) = GetTID(FieldByName('id'))) do
          begin
            DetailDoc.MakeEntry;
            DetailDoc.Next;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(gdcMaster);
    FreeAndNil(dsMaster);
    FIsInternalMasterSource := False;
  end;
end;

function TgdcDocument.GetCurrRecordClass: TgdcFullClass;
var
  DE: TgdDocumentEntry;
  Part: TgdcDocumentClassPart;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if not IsEmpty then
  begin
    if FieldByName('parent').IsNull then
      Part := dcpHeader
    else
      Part := dcpLine;

    DE := gdClassList.FindDocByTypeID(GetTID(FieldByName('documenttypekey')), Part, True);

    if DE <> nil then
    begin
      Result.gdClass := DE.gdcClass;
      Result.SubType := DE.SubType;
    end;
  end;
end;

class function TgdcDocument.HasLeafs: Boolean;
begin
  Result := True;
end;

class function TgdcDocument.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  if GetDocumentClassPart = dcpHeader then
    Result := '��������'
  else
    Result := '�������';

  if ASubType > '' then
    Result := Result + ' ' + Inherited GetDisplayName(ASubType);
end;

class function TgdcDocument.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    ss_ByIntervalDate + ';';
end;

procedure TgdcDocument.CreateEntry;
var
  DidActivate: Boolean;
  CFull: TgdcFullClass;
  C: TClass;
  Obj: TgdcBase;  
begin
  DidActivate := ActivateTransaction;
  try
    try
      if Self.ClassName = 'TgdcDocument' then
      begin
        CFull := GetCurrRecordClass;
        C := CFull.gdClass;

        if not Assigned(C) then
          raise EgdcException.Create('GetCurrRecordClass ������ nil �����.');

        Obj := CgdcBase(C).CreateWithID(Owner, Database, Transaction, ID, CFull.SubType);
        try
          Obj.Open;
          (Obj as TgdcDocument).CreateEntry;
        finally
          Obj.Free;
        end;
      end
      else
        MakeEntry;
    except
      if Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;

end;

function TgdcDocument.DocumentTypeKey: TID;
begin
  if FDocumentTypeKey = -1 then
    Result := ClassDocumentTypeKey
  else
    Result := FDocumentTypeKey;
end;

function TgdcDocument.AcceptClipboard(CD: PgdcClipboardData): Boolean;
begin
  { TODO :
�������� ���������� � TgdcTree ��� �� ����������. ��������� ��� ���������
������ ������ ���� ���, � ��� �������� ��������� ������ ���
������� ������ �� ������. ���� ���-�� ������ � ����� ���������. }
  Result := False;
end;

class function TgdcDocument.GetDocumentClass(const TypeKey: TID;
  const DocClassPart: TgdcDocumentClassPart): TgdcFullClass;
var
  //S: String;
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(TypeKey, DocClassPart, True);
  if DE <> nil then
  begin
    Result.gdClass := DE.gdcClass;
    Result.SubType := DE.SubType;
  end else
  begin
    Result.gdClass := nil;
    Result.SubType := '';
  end;

  (*
  //dcpHeader, dcpLine
  Result.gdClass := nil;
  Result.SubType := '';
  if TypeKey = 0 then Exit;

  if TypeKey >= cstUserIDStart then
  begin
     DE := gdClassList.FindDocByTypeID(TypeKey, DocClassPart);
     if (DE <> nil) and (DE.gdcClass <> nil) then
     begin
       Result.gdClass := CgdcBase(DE.gdcClass);
       Result.SubType := DE.SubType;
     end;
  end
  else begin
    S := '';
    case TypeKey of
      BN_DOC_PAYMENTORDER:                      // ��������� ���������
        S := 'TgdcPaymentOrder';
      BN_DOC_PAYMENTDEMAND:                     // ��������� ����������
        S := 'TgdcPaymentDemand';
      BN_DOC_PAYMENTDEMANDPAYMENT:              // ����������-���������
        S := 'TgdcDemandOrder';
      BN_DOC_ADVICEOFCOLLECTION:                // ���������� ������������
        S := 'TgdcAdviceOfCollection';
      BN_DOC_BANKSTATEMENT:                     // ���������� �������
        if DocClassPart = dcpHeader then
          S := 'TgdcBankStatement'
        else
          {$IFDEF DEPARTMENT}
          S := 'TgdcBankStatementLineD';
          {$ELSE}
          S := 'TgdcBankStatementLine';
          {$ENDIF}
      BN_DOC_BANKCATALOGUE:                     // ���������
        if DocClassPart = dcpHeader then
          S := 'TgdcBankCatalogue'
        else
          S := 'TgdcBankCatalogueLine';
      BN_DOC_CHECKLIST:                         // ������ �����
        S := 'TgdcCheckList';
      BN_DOC_CURRCOMMISION:                     // �������� ��������
        S := 'TgdcCurrCommission';
      BN_DOC_CURRSELLCONTRACT:                  // ������� �� ������� ������
        S := 'TgdcCurrSellContract';
      BN_DOC_CURRCOMMISSSELL:                   // ��������� �� ������� ������
        S := 'TgdcCurrCommissSell';
      BN_DOC_CURRLISTALLOCATION:                // ������ ������������� ������
        S := 'TgdcCurrListAllocation';
      BN_DOC_CURRBUYCONTRACT:                   // ������� �� ������� ������
        S := 'TgdcCurrBuyContract';
      BN_DOC_CURRCONVCONTRACT:                  // �������� �� �������� ������
        S := 'TgdcCurrConvContract';
      GD_DOC_TAXRESULT:
        case DocClassPart of
          dcpHeader: S := 'TgdcTaxDesignDate';
          dcpLine:   S := 'TgdcTaxResult';
        end;

     { TODO -oJulia : � ��� ���� � �����������, ������� �� ����� ������-�������� }
      GD_DOC_REALIZATIONBILL:                   // ��������� �� ������ ���
        S := '';
      GD_DOC_CONTRACT:                          // ��������
        S := '';
      GD_DOC_RETURNBILL:                        // ��������� �� ������� ���
        S := '';
      GD_DOC_BILL:                              // ����-�������
        S := '';

      CTL_DOC_INVOICE:                          // �����-���������
        S := '';
      CTL_DOC_RECEIPT:                          // �������� ���������
        S := '';

      {$IFDEF DEPARTMENT}
      DP_DOC_INVENTORY:                         // ��� ����� � ������
        S := 'Tgdc_dpInventory';
      DP_DOC_TRANSFER:                          // ��� ��������
        S := 'Tgdc_dpTransfer';
      DP_DOC_REVALUATION:                       // ��� ����������
        S := 'Tgdc_dpRevaluation';
      DP_DOC_WITHDRAWAL:                        // ��� ������� ������
        S := 'Tgdc_dpWithdrawal';
      {$ENDIF}

    end;
    Result.gdClass := CgdcBase(GetClass(S));
    Result.SubType := '';
  end;
  *)
end;

function TgdcDocument.GetIsCommon: Boolean;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, GetDocumentClassPart, True);
  Result := (DE <> nil) and DE.IsCommon;
end;

function TgdcDocument.GetNextNumber: String;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  Counter: Integer;
  FFixLength: Integer;
begin
  FNumberUpdated := False;
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    if FieldByName('COMPANYKEY').IsNull then
      FNumberCompanyKey := IBLogin.CompanyKey
    else
      FNumberCompanyKey := GetTID(FieldByName('COMPANYKEY'));

    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := cst_sql_GetLastNumber;
    SetTID(q.ParamByName('ck'), FNumberCompanyKey);
    SetTID(q.ParamByName('dtk'), DocumentTypeKey);
    q.ExecQuery;
    if q.EOF then
    begin
      FLastNumber := 1;
      FAddNumber := 1;
      q.Close;
      q.SQL.Text := cst_sql_InsertLastNumber;
      SetTID(q.ParamByName('ck'), FNumberCompanyKey);
      SetTID(q.ParamByName('dtk'), DocumentTypeKey);
      q.ParamByName('mask').AsString := NumerationVars[0];
      q.ParamByName('lastnumber').AsInteger := FLastNumber;
      q.ParamByName('addnumber').AsInteger := FAddNumber;
      q.ParamByName('fixlength').Clear;
      q.ExecQuery;
      FMask := NumerationVars[0];
      FFixLength := 0;
    end else
    begin
      FAddNumber := q.FieldByName('addnumber').AsInteger;
      FLastNumber := q.FieldByName('lastnumber').AsInteger + FAddNumber;
      FMask := q.FieldByName('mask').AsString;
      FFixLength := q.FieldByName('fixlength').AsInteger;
      q.Close;
      if (FAddNumber <> 0) and (FMask > '') then
      begin
        Counter := 0;
        repeat
          if not Tr.InTransaction then
            Tr.StartTransaction;
          q.Close;
          q.SQL.Text := cst_sql_NextNumber;
          SetTID(q.ParamByName('ck'), FNumberCompanyKey);
          SetTID(q.ParamByName('dtk'), DocumentTypeKey);
          try
            q.ExecQuery;
            Tr.Commit;
            FNumberUpdated := True;
            break;
          except
            if Counter = 4 then
              break;
            Tr.Commit;
            Inc(Counter);
            Sleep(1000);
          end;
        until False;
      end;
    end;
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Commit;
    Tr.Free;
  end;

  //Alexander: � ���� ������ ���� documentdate ��� ������
  Result := EncodeNumber(FMask,
    FLastNumber, Now{FieldByName('documentdate').AsDateTime},
    FFixlength);
end;

procedure TgdcDocument.MakeRollbackNumber;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(FNumberCompanyKey > 0);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := cst_sql_ReturnLastNumber;
    SetTID(q.ParamByName('ck'), FNumberCompanyKey);
    SetTID(q.ParamByName('dtk'), DocumentTypeKey);
    q.ParamByName('lastnumber').AsInteger := FLastNumber;
    try
      q.ExecQuery;
      Tr.Commit;
      FNumberUpdated := False;
      FNumberCompanyKey := -1;
    except
      //...
    end;
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Commit;
    Tr.Free;
  end;
end;

procedure TgdcDocument.ExecuteTransactionFunction;
var
  DE: TgdDocumentEntry;
  FunctionKey: TID;
  LParams, LResult: Variant;
begin
  FunctionKey := 0;
  DE := gdClassList.FindDocByTypeID(DocumentTypeKey, GetDocumentClassPart, True);

  while DE <> nil do
  begin
    if GetDocumentClassPart = dcpHeader then
      FunctionKey := DE.HeaderFunctionKey
    else
      FunctionKey := DE.LineFunctionKey;

    if FunctionKey > 0 then
      break;

    if (not (DE.Parent is TgdDocumentEntry)) or (DE = DE.GetRootSubType) then
      break;

    DE := TgdDocumentEntry(DE.Parent);
  end;

  if FunctionKey > 0 then
  begin
    LParams := VarArrayOf([GetGdcOLEObject(Self) as IDispatch]);
    ScriptFactory.ExecuteFunction(FunctionKey, LParams, LResult);
  end;
end;

function TgdcDocument.GetgdcAcctEntryRegister: TgdcBase;
begin
  if FgdcAcctEntryRegister = nil then
  begin
    FgdcAcctEntryRegister := TgdcAcctEntryRegister.Create(Self);
    (FgdcAcctEntryRegister as TgdcAcctEntryRegister).Document := Self;
  end;
  Result := FgdcAcctEntryRegister;
end;

procedure TgdcDocument.CheckNumber(Field: TField);
var
  ibsql: TIBSQL;
  V, N, Chck: String;
  FirstCheck: Boolean;
  StartTime: DWORD;
  B, E, I: Integer;
  Y, M, D: Word;
begin
  if sLoadFromStream in BaseState then
    exit;

  N := Trim(FieldByName('number').AsString);

  { ���� ������������ ���������� ������������� � ������������� ���������
    � ������� � ����� ������������ ������� (�� �����), �� ������� ��� ��
    ���� ����� ���������. ��������� ����� � ��������� �� � �����, �����
    ����������� ������ �������������� � ���� ������.
  }
  if (N <> FAutoNumber) and (Pos(NumerationVars[0], UpperCase(FMask)) > 0) then
  begin
    B := 0;
    E := 0;
    I := 1;
    while I <= Length(N) do
    begin
      if N[I] in ['0'..'9'] then
      begin
        if B = 0 then
          B := I
        else begin
          if E > 0 then
            break;
        end;
      end else
      begin
        if (B > 0) and (E = 0) then E := I - 1;
      end;
      Inc(I);
    end;
    if (B > 0) and (E = 0) then E := I - 1;

    if (I > Length(N)) and (B > 0) then
    begin
      FMask := N;
      System.Delete(FMask, B, E - B + 1);
      System.Insert(NumerationVars[0], FMask, B);

      gdcBaseManager.ExecSingleQuery(
        'UPDATE gd_lastnumber SET mask = :mask WHERE ourcompanykey = :ck AND documenttypekey = :dtk ',
        VarArrayOf([FMask, TID2V(FieldByName('companykey')), TID2V(DocumentTypeKey)]));
    end;
  end;

  if IsCheckNumber = icnNever then
    exit;

  FirstCheck := True;
  V := '';
  ibsql := TIBSQL.Create(nil);
  try
    case IsCheckNumber of
      icnYear, icnMonth: Chck := 'AND documentdate >= :db AND documentdate < :de';
    else
      Chck := '';
    end;

    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT id FROM gd_document WHERE number = :number AND ' +
      ' documenttypekey = :dt AND id <> :id AND parent + 0 IS NULL AND companykey = :companykey ' +
      Chck;
    SetTID(ibsql.ParamByName('dt'), DocumentTypeKey);
    SetTID(ibsql.ParamByName('id'), FieldByName('id'));
    SetTID(ibsql.ParamByName('companykey'), FieldByName('companykey'));
    if IsCheckNumber in [icnYear, icnMonth] then
    begin
      DecodeDate(FieldByName('documentdate').AsdateTime, Y, M, D);
      if IsCheckNumber = icnYear then
      begin
        ibsql.ParamByName('db').AsDateTime := EncodeDate(Y, 01, 01);
        ibsql.ParamByName('de').AsDateTime := EncodeDate(Y + 1, 01, 01);
      end else
      begin
        ibsql.ParamByName('db').AsDateTime := EncodeDate(Y, M, 01);
        Inc(M);
        if M > 12 then
        begin
          M := 1;
          Inc(Y);
        end;
        ibsql.ParamByName('de').AsDateTime := EncodeDate(Y, M, 01);
      end;
    end;
    StartTime := GetTickCount;
    repeat
      ibsql.ParamByName('number').AsString := N;
      ibsql.ExecQuery;

      if ibsql.EOF then
        break;

      ibsql.Close;

      if GetTickCount - StartTime > 4000 then
        raise Exception.Create(sDublicateDocumentNumber);

      if Pos(NumerationVars[0], UpperCase(FMask)) = 0 then
        raise Exception.Create(sDublicateDocumentNumber);

      // ���� ������������ ������ ����� �������, ��
      // �� ���������� �������������� ������ ������,
      // ����� ������� ����������
      if FirstCheck and (FAutoNumber <> N) then
        raise Exception.Create(sDublicateDocumentNumber);

      FirstCheck := False;
      V := GetNextNumber;
      if V = N then
        raise Exception.Create(sDublicateDocumentNumber);

      N := V;
    until False;

    if FieldByName('number').AsString <> N then
      FieldByName('number').AsString := N;
  finally
    ibsql.Free;
  end;
end;

procedure TgdcDocument.InternalSetFieldData(Field: TField;
  Buffer: Pointer);
var
  OldCK: TID;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if UpperCase(Field.FieldName) = 'COMPANYKEY' then
    OldCK := GetTID(Field)
  else
    OldCK := -1;

  inherited;

  if FDataTransfer then
    exit;

  if GetDocumentClassPart = dcpHeader then
  begin
    if UpperCase(Field.FieldName) = 'COMPANYKEY' then
    begin
      if (OldCK <> GetTID(Field)) and
        (not (sLoadFromStream in BaseState)) then
      begin
        if FNumberUpdated then
          MakeRollbackNumber;
        FAutoNumber := GetNextNumber;
        FieldByName('NUMBER').AsString := FAutoNumber;
      end;
    end
    else if (sDialog in BaseState)
      and (UpperCase(Field.FieldName) = 'NUMBER')
      and (FAutoNumber > '')
      and (FAutoNumber <> Field.AsString)
      and (StrToIntDef(Field.AsString, 0) > 0)
      and (StrIPos(NumerationVars[0], FMask) > 0) then
    begin
      Tr := TIBTransaction.Create(nil);
      try
        tr.DefaultDatabase := gdcBaseManager.Database;
        tr.StartTransaction;

        q := TIBSQL.Create(nil);
        try
          q.Transaction := Tr;
          q.SQL.Text :=
            'UPDATE gd_lastnumber ' +
            ' SET lastnumber = :ln' +
            ' WHERE ourcompanykey = :ck AND documenttypekey = :dtk ';
          SetTID(q.ParamByName('CK'), FieldByName('companykey'));
          SetTID(q.ParamByName('DTK'), Self.DocumentTypeKey);
          SetTID(q.ParamByName('LN'), Field);
          try
            q.ExecQuery;
            Tr.Commit;
          except
          end;
        finally
          q.Free;
        end;
      finally
        Tr.Free;
      end;
    end;
  end;
end;

function TgdcDocument.GetMasterObject: TgdcDocument;
begin
  Result := nil;
end;

function TgdcDocument.GetDetailObject: TgdcDocument;
begin
  Result := nil;
end;

function TgdcDocument.HaveIsDetailObject: Boolean;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_document WHERE parent = :id';
    SetTID(ibsql.ParamByName('id'), ID);
    Result := ibsql.RecordCount > 0;
  finally
    ibsql.Free;
  end;
end;

function TgdcDocument.GetSecCondition: String;
begin
  if Assigned(MasterSource) and (MasterSource.DataSet is TgdcDocument) then
    Result := ''
  else
    Result := inherited GetSecCondition;
end;

function TgdcDocument.GetCanChangeRights: Boolean;
begin
  Result := inherited GetCanChangeRights;

  if Result then
  begin
    Result :=
      (not Assigned(MasterSource))
      or
      (not (MasterSource.DataSet is TgdcDocument))
      or
      (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
      or
      (TgdcBase(MasterSource.DataSet).TestUserRights([tiAFull]));
  end;
end;

function TgdcDocument.GetCanCreate: Boolean;
begin
  Result := inherited GetCanCreate;

  if Result then
  begin
    Result :=
      (not Assigned(MasterSource))
      or
      (not (MasterSource.DataSet is TgdcDocument))
      or
      (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
      or
      (TgdcBase(MasterSource.DataSet).Class_TestUserRights([tiAChag],
        TgdcBase(MasterSource.DataSet).SubType));
  end;
end;

function TgdcDocument.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete;

  if Result then
  begin
    Result :=
      (not Assigned(MasterSource))
      or
      (not (MasterSource.DataSet is TgdcDocument))
      or
      (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
      or
      (TgdcBase(MasterSource.DataSet).TestUserRights([tiAFull]));
  end;
end;

function TgdcDocument.GetCanEdit: Boolean;
begin
  if State = dsInsert then
    Result := True
  else begin
    Result := inherited GetCanEdit;

    if Result then
    begin
      Result :=
          (not Assigned(MasterSource))
          or
          (not (MasterSource.DataSet is TgdcDocument))
          or
          (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
          or
          (TgdcBase(MasterSource.DataSet).TestUserRights([tiAChag]));
    end;
  end;
end;

function TgdcDocument.GetCanPrint: Boolean;
begin
  Result := inherited GetCanPrint;

  if Result then
  begin
    Result :=
      (not Assigned(MasterSource))
      or
      (not (MasterSource.DataSet is TgdcDocument))
      or
      (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
      or
      (TgdcBase(MasterSource.DataSet).TestUserRights([tiAView]));
  end;
end;

function TgdcDocument.GetCanView: Boolean;
begin
  Result := inherited GetCanView;

  if Result then
  begin
    Result :=
      (not Assigned(MasterSource))
      or
      (not (MasterSource.DataSet is TgdcDocument))
      or
      (TgdcBase(MasterSource.DataSet).State in dsEditModes)
      or
      (TgdcBase(MasterSource.DataSet).SubType <> Self.SubType)
      or
      (TgdcBase(MasterSource.DataSet).TestUserRights([tiAView]));
  end;
end;

function TgdcDocument.Reduction(BL: TBookmarkList): Boolean;
begin
  raise EgdcException.Create('��������� ������ ����������!');
end;

function TgdcDocument.GetIsCheckNumber: TIsCheckNumber;
var
  DE: TgdDocumentEntry;
begin
  if (not IsEmpty) and (GetTID(FieldByName('documenttypekey')) > 0) then
  begin
    DE := gdClassList.FindDocByTypeID(GetTID(FieldByName('documenttypekey')),
      GetDocumentClassPart, True);
    if DE <> nil then
      Result := DE.IsCheckNumber
    else
      Result := icnNever;
  end else
    Result := icnNever;
end;

function TgdcDocument.EditDialog(const ADlgClassName: String): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcAcctComplexRecord: TgdcAcctComplexRecord;
begin
  {@UNFOLD MACRO INH_ORIG_EDITDIALOG('TGDCDOCUMENT', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENT', KEYEDITDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYEDITDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENT',
  {M}          'EDITDIALOG', KEYEDITDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'EDITDIALOG' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENT' then
  {M}        begin
  {M}          Result := inherited EditDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Active and (not EOF) and (ADlgClassName = '')
    and (GetTID(FieldByName('documenttypekey')) = DefaultDocumentTypeKey) then
  begin
    gdcAcctComplexRecord := TgdcAcctComplexRecord.Create(nil);
    try
      gdcAcctComplexRecord.Transaction := Transaction;
      gdcAcctComplexRecord.ReadTransaction := ReadTransaction;
      gdcAcctComplexRecord.SubSet := 'ByDocument';
      SetTID(gdcAcctComplexRecord.ParamByName('documentkey'), Self.ID);
      gdcAcctComplexRecord.Open;
      if gdcAcctComplexRecord.EOF then
        Result := inherited EditDialog(ADlgClassName)
      else
        Result := gdcAcctComplexRecord.EditDialog(ADlgClassName);
    finally
      gdcAcctComplexRecord.Free;
    end;
  end else
    Result := inherited EditDialog(ADlgClassName);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENT', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENT', 'EDITDIALOG', KEYEDITDIALOG);
  {M}  end;
  {END MACRO}
end;

class function TgdcDocument.ClassDocumentTypeKey: Integer;
begin
  Result := -1;
end;

procedure TgdcDocument.SetSubType(const Value: TgdcSubType);
var
  DE: TgdDocumentEntry;
begin
  if SubType <> Value then
  begin
    inherited;
    if SubType > '' then
    begin
      DE := gdClassList.FindDocByRUID(Value, GetDocumentClassPart, True);
      if DE = nil then
        raise Exception.Create('Invalid document type');
      ReadOptions(DE);
    end else
      ReadOptions(nil);
  end;
end;

procedure TgdcDocument.ReadOptions(DE: TgdDocumentEntry);
begin
  if DE <> nil then
  begin
    FDocumentTypeKey := DE.TypeID;
    FBranchKey := DE.BranchKey;
  end else
  begin
    FDocumentTypeKey := -1;
    FBranchKey := -1;
  end;
end;

function TgdcDocument.GetObjectName: String;
begin
  if Active and (not IsEmpty) then
  begin
    Result := GetDisplayName(SubType) + ', � ' + FieldByName('number').AsString +
      ' �� ' + FormatDateTime('dd.mm.yyyy', FieldbyName('documentdate').AsDateTime)
  end else
    Result := FObjectName;
end;

{ TgdcBaseDocumentType }

constructor TgdcBaseDocumentType.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify];
end;

procedure TgdcBaseDocumentType._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEDOCUMENTTYPE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEDOCUMENTTYPE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('ruid').AsString := RUIDToStr(GetRUID);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseDocumentType.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if not IsEmpty then
  begin
    if FieldByName('documenttype').AsString = 'B' then
      Result.gdClass := TgdcDocumentBranch
    else if (FieldByName('documenttype').AsString = 'D') and (FieldByName('classname').AsString > '') then
      Result.gdClass := (gdClassList.Get(TgdBaseEntry, FieldByName('classname').AsString, '') as TgdBaseEntry).gdcClass
    else
      Result.gdClass := TgdcDocumentType;
  end;

  FindInheritedSubType(Result);
end;

class function TgdcBaseDocumentType.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcBaseDocumentType.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'gd_documenttype';
end;

function TgdcBaseDocumentType.GetParent: TID;
begin
  if not IsEmpty then
    Result := inherited GetParent
  else

  // ���� ��� �������, �������� ���������� � master-�����
  // ������ master-detail.
  begin
    if Assigned(FgdcDataLink.DataSet) and
      (FgdcDataLink.DataSet is TgdcBaseDocumentType)
    then
      Result := GetTID(FgdcDataLink.DataSet.FieldByName('id'))
    else
      Result := inherited GetParent;
  end;
end;

class function TgdcBaseDocumentType.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := inherited GetRestrictCondition(ATableName, ASubType);
  if AnsiCompareText(ATableName, GetListTable(ASubType)) = 0 then
  begin
    if Self = TgdcDocumentBranch then
      Result := 'z.documenttype = ''B'''
    else if Self = TgdcDocumentType then
      Result := 'z.documenttype = ''D''';
  end;
end;

function TgdcBaseDocumentType.UpdateReportGroup(
  MainBranchName, DocumentName: String;
  var GroupKey: TID; const ShouldUpdateData: Boolean): Boolean;
var
  ibsql: TIBSQL;
  BranchID: TID;
  DidActivate: Boolean;
begin
  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;

    DidActivate := ActivateTransaction;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE id = :id';
    SetTID(ibsql.ParamByName('id'), GroupKey);
    ibsql.ExecQuery;

    //
    // ���� ������ ��� �� ���������
    // ������������ ����������. ����� ���� ��������� �� ������� ����� �����

    if ibsql.EOF then
    begin
      ibsql.Close;
      ibsql.SQL.Text :=
        'SELECT id FROM rp_reportgroup WHERE name = :name AND parent IS NULL';

      ibsql.ParamByName('name').AsString := MainBranchName;
      ibsql.ExecQuery;

      //
      // ���� �� ���� ��������� ������� ����� ������� ������������
      // �� ����������

      if ibsql.EOF then
      begin
        ibsql.Close;
        ibsql.SQL.Text :=
          'INSERT INTO rp_reportgroup ' +
          '  (id, parent, name, description, usergroupname) ' +
          'VALUES ' +
          '  (:id, :parent, :name, :description, :usergroupname) ';

        SetTID(ibsql.ParamByName('id'), GetNextID);
        ibsql.ParamByName('parent').Clear;
        ibsql.ParamByName('name').AsString := MainBranchName;
        ibsql.ParamByName('description').AsString := MainBranchName;
        ibsql.ParamByName('usergroupname').AsString :=
          gdcBaseManager.GetRUIDStringByID(GetTID(ibsql.ParamByName('ID')));

        ibsql.ExecQuery;

        BranchID := GetTID(ibsql.ParamByName('id'));
      end else
        BranchID := GetTID(ibsql.Fields[0]);

      ibsql.Close;
      ibsql.SQL.Text :=
        'INSERT INTO rp_reportgroup ' +
        ' (id, parent, name, description, usergroupname) ' +
        'VALUES ' +
        ' (:id, :parent, :name, :description, :usergroupname)';

      SetTID(ibsql.ParamByName('id'), GetNextID);
      SetTID(ibsql.ParamByName('parent'), BranchID);
      ibsql.ParamByName('name').AsString := DocumentName;
      ibsql.ParamByName('description').AsString := DocumentName;
      ibsql.ParamByName('usergroupname').AsString :=
        gdcBaseManager.GetRUIDStringByID(GetTID(ibsql.ParamByName('ID')));

      ibsql.ExecQuery;

      GroupKey := GetTID(ibsql.ParamByName('id'));
      Result := True;
    end else

    //
    // ���� ������ ��� ���������, ������������ ����������
    // ���� ��� ������ ��������������� �������� �������

    if ShouldUpdateData then
    begin
      ibsql.Close;
      ibsql.SQL.Text :=
        'UPDATE rp_reportgroup ' +
        'SET ' +
        '  name = :name, ' +
        '  description = :description ' +
        'WHERE ' +
        '  id = :id';

      SetTID(ibsql.ParamByName('id'), GroupKey);
      ibsql.ParamByName('name').AsString := DocumentName;
      ibsql.ParamByName('description').AsString := DocumentName;
      ibsql.ExecQuery;
      Result := True;
    end else
      Result := False;

  finally
    if DidActivate then
      Transaction.Commit;

    ibsql.Free;
  end;
end;

class function TgdcBaseDocumentType.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDocumentType';
end;

class function TgdcBaseDocumentType.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByRUID;';
end;

procedure TgdcBaseDocumentType.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByRUID') then
    S.Add(' z.ruid = :ruid ');
end;

function TgdcBaseDocumentType.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCBASEDOCUMENTTYPE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEDOCUMENTTYPE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEDOCUMENTTYPE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEDOCUMENTTYPE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM gd_documenttype WHERE ruid = :ruid'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := 'SELECT id FROM gd_documenttype WHERE ruid = ''' + FieldByName('ruid').AsString + '''';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEDOCUMENTTYPE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEDOCUMENTTYPE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseDocumentType.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcBaseDocumentType.DoBeforePost;
var
  ibsql: TIBSQL;
  S, S2: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEDOCUMENTTYPE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEDOCUMENTTYPE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEDOCUMENTTYPE' then
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

  if sCopy in BaseState then
    FieldByName('name').AsString := System.copy('Copy ' + FieldByName('name').AsString, 1, 50); 

  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    ibsql.SQL.Text :=
      'SELECT id, name FROM gd_documenttype ' +
      'WHERE UPPER(name) = :name and id <> :id';
    ibsql.ParamByName('name').AsString := AnsiUpperCase(FieldByName('name').AsString);
    SetTID(ibsql.ParamByName('id'), ID);
    ibsql.ExecQuery;

    if not ibsql.EOF then
    begin
      if sLoadFromStream in BaseState then
      begin
        S := FieldByName('name').AsString;
        S2 := FieldByName(GetKeyField(SubType)).AsString;
        if Length(S) + Length(S2) <= FieldByName('name').Size then
          FieldByName('name').AsString := S + S2
        else
          FieldByName('name').AsString := System.Copy(S, 1, 60 - Length(S2)) + S2;
      end else
        raise EgdcIBError.Create(
          '� ���� ������ ��� ���������� �������� ��� ������ ����������'#13#10 +
          '� ������ "' + FieldByName('name').AsString + '".' +
          '������������ ������������ �����������!');
    end;
  finally
    ibsql.Free;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEDOCUMENTTYPE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseDocumentType.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASEDOCUMENTTYPE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEDOCUMENTTYPE', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEDOCUMENTTYPE',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEDOCUMENTTYPE' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',RUID,REPORTGROUPKEY';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEDOCUMENTTYPE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEDOCUMENTTYPE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseDocumentType.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcBaseDocumentType');
end;

class function TgdcBaseDocumentType.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgDocumentType';
end;

function TgdcBaseDocumentType.GetDocLineRelationName: String;
var
  R: TatRelation;
begin
  if not IsEmpty then
  begin
    R := atDatabase.Relations.ByID(GetTID(FieldByName('linerelkey')));
    if R <> nil then
      Result := R.RelationName
    else
      Result := '';
  end else
    Result := '';
end;

function TgdcBaseDocumentType.GetDocRelationName: String;
var
  R: TatRelation;
begin
  if not IsEmpty then
  begin
    R := atDatabase.Relations.ByID(GetTID(FieldByName('headerrelkey')));
    if R <> nil then
      Result := R.RelationName
    else
      Result := '';
  end else
    Result := '';
end;

function TgdcBaseDocumentType.GetIsComplexDocument: Boolean;
begin
  Result := DocLineRelationName > '';
end;

{ TgdcDocumentBranch }

procedure TgdcDocumentBranch._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDOCUMENTBRANCH', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTBRANCH', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTBRANCH') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTBRANCH',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTBRANCH' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('documenttype').AsString := 'B';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTBRANCH', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTBRANCH', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcDocumentBranch.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' z.documenttype = ''B'' ');
end;

class function TgdcDocumentBranch.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgDocBranch';
end;

{ TgdcDocumentType }

procedure TgdcDocumentType._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DEParent: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTTYPE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTTYPE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sLoadFromStream in BaseState) then
  begin
    FieldByName('documenttype').AsString := 'D';
    SetTID(FieldByName('parent'), GetParent);
    FieldByName('classname').AsString := ClassName;

    DEParent := gdClassList.FindDocByTypeID(GetTID(FieldByName('parent')), dcpHeader, True);
    if DEParent <> nil then
    begin
      FieldByName('name').AsString := '��������� ' + DEParent.Caption;
      if DEParent.BranchKey > 0 then
        SetTID(FieldByName('branchkey'), DEParent.BranchKey)
      else
        FieldByName('branchkey').Clear;
      if DEParent.HeaderRelKey > 0 then
        SetTID(FieldByName('headerrelkey'), DEParent.HeaderRelKey)
      else
        FieldByName('headerrelkey').Clear;
      if DEParent.LineRelKey > 0 then
        SetTID(FieldByName('linerelkey'), DEParent.LineRelKey)
      else
        FieldByName('linerelkey').Clear;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTTYPE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcDocumentType.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add( ' z.documenttype = ''D'' ');
end;

procedure TgdcDocumentType.DoAfterShowDialog(DlgForm: TCreateableForm;
  IsOk: Boolean);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE, DELn: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERSHOWDIALOG('TGDCDOCUMENTTYPE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTTYPE', KEYDOAFTERSHOWDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERSHOWDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          GetGdcInterface(DlgForm), IsOk]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTTYPE',
  {M}          'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if IsOk then
  begin
    DE := gdClassList.FindDocByRUID(FieldByName('ruid').AsString, dcpHeader);

    if DE <> nil then
    begin
      DE.LoadDE(Transaction);
      DELn := gdClassList.FindDocByRUID(FieldByName('ruid').AsString, dcpLine);
      if DELn <> nil then
        DELn.Assign(DE);
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTTYPE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTTYPE', 'DOAFTERSHOWDIALOG', KEYDOAFTERSHOWDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcDocumentType.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if FieldByName('classname').AsString > '' then
    Result.gdClass := (gdClassList.Get(TgdBaseEntry, FieldByName('classname').AsString, '') as TgdBaseEntry).gdcClass;

  FindInheritedSubType(Result);
end;

function TGDCDOCUMENTTYPE.GetFromClause(
  const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCDOCUMENTTYPE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTTYPE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTTYPE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTTYPE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetFromClause(ARefresh) +
    ' LEFT JOIN gd_lastnumber ln ON ln.ourcompanykey = ' + TID2S(IBLogin.CompanyKey)
    + ' AND ln.documenttypekey = z.id ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTTYPE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTTYPE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcDocumentType.GetParentSubType: String;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    q.SQL.Text :=
      'SELECT ruid FROM gd_documenttype WHERE id = :id AND documenttype = ''D'' ';
    SetTID(q.ParamByName('id'), FieldByName('parent'));
    q.ExecQuery;
    if not q.Eof then
      Result := q.FieldByName('RUID').AsString
    else
      Result := '';
  finally
    q.Free;
  end;
end;

function TGDCDOCUMENTTYPE.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCDOCUMENTTYPE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTTYPE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTTYPE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTTYPE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetSelectClause +
    ', ln.lastnumber, ln.addnumber, ln.mask, ln.fixlength ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTTYPE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTTYPE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcDocumentType.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
  DE, DELn: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDOCUMENTTYPE', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDOCUMENTTYPE',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Process = cpDelete then
    gdClassList.RemoveSubType(FieldByName('ruid').AsString)
  else if Process = cpModify then
  begin
    DE := gdClassList.FindDocByRUID(FieldByName('ruid').AsString, dcpHeader);
    if DE = nil then
      raise Exception.Create('Document type info not found');
    DE.LoadDE(Transaction);
    DELn := gdClassList.FindDocByRUID(FieldByName('ruid').AsString, dcpLine);
    if DELn is TgdDocumentEntry then
      DELn.Assign(DE);
  end;

  if Process <> cpDelete then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text := cst_sql_GetLastNumber;
      SetTID(q.ParamByName('ck'), IBLogin.CompanyKey);
      SetTID(q.ParamByName('dtk'), ID);
      q.ExecQuery;

      if q.EOF then
      begin
        //��������� �� ������
        //������� ������ � ���������, ��������� ����� ���������������� �������� ���
        //��������� (�������� � ��������� 1)
        q.Close;
        q.SQL.Text := cst_sql_InsertLastNumber;
        SetTID(q.ParamByName('ck'), IBLogin.CompanyKey);
        SetTID(q.ParamByName('dtk'), ID);
        q.ParamByName('lastnumber').AsInteger := FieldByName('lastnumber').AsInteger;

        if not (sLoadFromStream in BaseState) then
        begin
          if FieldByName('mask').IsNull then
            q.ParamByName('mask').AsString := NumerationVars[0]
          else
            q.ParamByName('mask').AsString := FieldByName('mask').AsString;
          if FieldbyName('addnumber').IsNull then
            q.ParamByName('addnumber').AsInteger := 1
          else
            q.ParamByName('addnumber').AsInteger := FieldByName('addnumber').AsInteger;
        end else
        begin
          if FieldByName('mask').IsNull then
            q.ParamByName('mask').Clear
          else
            q.ParamByName('mask').AsString := FieldByName('mask').AsString;
          if FieldbyName('addnumber').IsNull then
            q.ParamByName('addnumber').Clear
          else
            q.ParamByName('addnumber').AsInteger := FieldByName('addnumber').AsInteger;
        end;

        if FieldByName('fixlength').AsInteger <= 0 then
          q.ParamByName('fixlength').Clear
        else
          q.ParamByName('fixlength').AsInteger := FieldByName('fixlength').AsInteger;
        q.ExecQuery;
      end else
      begin
        //��������� ������ � ��� �� �������� �� ������
        if not (sLoadFromStream in BaseState) then
        begin
          q.Close;
          q.SQL.Text := cst_sql_UpdateLastNumber;
          q.ParamByName('lastnumber').AsInteger := FieldByName('lastnumber').AsInteger;
          SetTID(q.ParamByName('ck'), IBLogin.CompanyKey);
          SetTID(q.ParamByName('dtk'), ID);
          q.ParamByName('mask').AsString := FieldByName('mask').AsString;

          q.ParamByName('addnumber').AsInteger := FieldByName('addnumber').AsInteger;
          if FieldByName('fixlength').AsInteger <= 0 then
            q.ParamByName('fixlength').Clear
          else
            q.ParamByName('fixlength').AsInteger := FieldByName('fixlength').AsInteger;
          q.ExecQuery;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

class function TgdcDocumentType.GetHeaderDocumentClass: CgdcBase;
begin
  Result := TgdcDocument;
end;

class function TgdcDocumentType.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcDocumentType');
end;

destructor TgdcDocumentType.Destroy;
begin
  FqGetOptID.Free;
  FqDel.Free;
  FqRUID.Free;
  FqNS.Free;
  Fq.Free;
  inherited;
end;

procedure TgdcDocumentType.DoneOpt;
begin
  FreeAndNil(FqGetOptID);
  FreeAndNil(FqDel);
  FreeAndNil(FqRUID);
  FreeAndNil(FqNS);
  FreeAndNil(FqFindObj);
  FreeAndNil(Fq);
end;

procedure TgdcDocumentType.InitOpt;
begin
  Assert(FqGetOptID = nil);
  Assert(FqDel = nil);
  Assert(FqRUID = nil);
  Assert(FqNS = nil);

  FqGetOptID := TIBSQL.Create(nil);
  FqGetOptID.Transaction := Transaction;
  FqGetOptID.SQL.Text :=
    'SELECT id FROM gd_documenttype_option ' +
    'WHERE dtkey = :dtkey AND option_name STARTING WITH :s';

  FqDel := TIBSQL.Create(nil);
  FqDel.Transaction := Transaction;
  FqDel.SQL.Text :=
    'DELETE FROM gd_documenttype_option WHERE dtkey = :dtkey AND option_name STARTING WITH :s';

  FqRUID := TIBSQL.Create(nil);
  FqRUID.Transaction := Transaction;
  FqRUID.SQL.Text :=
    'INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) ' +
    'VALUES (:id, :id, GEN_ID(gd_g_dbid, 0), CURRENT_TIMESTAMP, <CONTACTKEY/>)';

  FqNS := TIBSQL.Create(nil);
  FqNS.Transaction := Transaction;
  FqNS.SQL.Text :=
    'INSERT INTO at_object (namespacekey, objectname, objectclass, xid, dbid, objectpos, headobjectkey) ' +
    'VALUES (:namespacekey, :objectname, ''TgdcInvDocumentTypeOptions'', :xid, GEN_ID(gd_g_dbid, 0), :objectpos, :headobjectkey)';

  FqFindObj := TIBSQL.Create(nil);
  FqFindObj.Transaction := Transaction;
  FqFindObj.SQL.Text :=
    'SELECT o.objectpos FROM at_object o ' +
    'JOIN gd_ruid r ON r.xid = o.xid AND r.dbid = o.dbid ' +
    'WHERE o.namespacekey = :nk AND r.id = :id AND o.objectpos > :p';

  Fq := TIBSQL.Create(nil);
  Fq.Transaction := Transaction;
  Fq.SQL.Text :=
    'SELECT FIRST 1 obj.id, obj.namespacekey, obj.objectpos ' +
    'FROM at_object obj ' +
    '  JOIN gd_ruid r ON r.xid = obj.xid AND r.dbid = obj.dbid ' +
    'WHERE r.id = :id';
  SetTID(Fq.ParamByName('id'), ID);
  Fq.ExecQuery;
  if Fq.EOF then
  begin
    FNSID := -1;
    FNSPos := -1;
    FHeadObjectKey := -1;
  end else
  begin
    FNSID := GetTID(Fq.FieldbyName('namespacekey'));
    FNSPos := Fq.FieldByName('objectpos').AsInteger;
    FHeadObjectKey := GetTID(Fq.FieldByName('id'));
  end;
  Fq.Close;
end;

function TgdcDocumentType.GetOptID(const AName: String;
  out AnOptID: TID): Boolean;
begin
  Assert(FqGetOptID <> nil);
  FqGetOptID.Close;
  SetTID(FqGetOptID.ParamByName('dtkey'), ID);
  FqGetOptID.ParamByName('s').AsString := AName;
  FqGetOptID.ExecQuery;
  if FqGetOptID.EOF then
  begin
    AnOptID := GetNextID;
    Result := False;
  end else
  begin
    AnOptID := GetTID(FqGetOptID.Fields[0]);
    Result := True;
  end;
end;

procedure TgdcDocumentType.DelOpt(const AName: String);
begin
  Assert(FqDel <> nil);
  SetTID(FqDel.ParamByName('dtkey'), ID);
  FqDel.ParamByName('s').AsString := AName;
  FqDel.ExecQuery;
end;

procedure TgdcDocumentType.AddNSObject(const AnObjID: TID;
  const AName: String; const ADependentOnID: TID = -1);
var
  P: Integer;
begin
  if FNSID > -1 then
  begin
    FqRUID.ParamByName('id').AsInteger := AnObjID;
    FqRUID.ExecQuery;

    P := 0;

    if ADependentOnID > 147000000 then
    begin
      FqFindObj.Close;
      SetTID(FqFindObj.ParamByName('nk'), FNSID);
      SetTID(FqFindObj.ParamByName('id'), ADependentOnID);
      FqFindObj.ParamByName('p').AsInteger := FNSPos;
      FqFindObj.ExecQuery;
      if not FqFindObj.EOF then
        P := FqFindObj.Fields[0].AsInteger + 1;
      FqFindObj.Close;
    end;

    if P = 0 then
    begin
      Inc(FNSPos);
      P := FNSPos;
    end;

    SetTID(FqNS.ParamByName('namespacekey'), FNSID);
    FqNS.ParamByName('objectname').AsString := System.Copy(AName, 1, 60);
    SetTID(FqNS.ParamByName('xid'), AnObjID);
    FqNS.ParamByName('objectpos').AsInteger := P;
    SetTID(FqNS.ParamByName('headobjectkey'), FHeadObjectKey);
    FqNS.ExecQuery;
  end;
end;

procedure TgdcDocumentType.FullCopyDocument;
var
  InTransaction: Boolean;
  ibsql: TIBSQL;
  OldID: TID;
  OldRUID: String;
  CurID, NewID, NewFuncID, NewEvID: TID;

procedure InsertFunction(OldFuncID, MainFuncID: TID);
var
  ibsqlList: TIBSQL;
  NewLinkID: TID;
  NewRUIDStr: String;
  NameFunc: String;
begin
  ibsqlList := TIBSQL.Create(nil);
  try
    ibsqlList.Transaction := Transaction;
    ibsqlList.SQL.Text := 'select ADDFUNCTIONKEY as id, f.name from RP_ADDITIONALFUNCTION r left join gd_function f ON r.ADDFUNCTIONKEY = f.id where r.MAINFUNCTIONKEY = :id';
    ibsqlList.ParamByName('id').AsInteger := OldFuncID;
    ibsqlList.ExecQuery;
    while not ibsqlList.EOF do
    begin
      if MessageBox(ParentHandle,
             PChar('������������ ������� ' + ibsqlList.FieldByName('name').AsString +  '. ������� �� ����� ��� ������� ������ �� ��������?'),
             PChar(sAttention),
             MB_YESNO or MB_TASKMODAL or MB_ICONWARNING) = IDYES then
      begin
        NewLinkID := GetNextID;
        NewRUIDStr := gdcBaseManager.GetRUIDStringByID(NewLinkID, Transaction);
        NameFunc := System.copy(ibsqlList.FieldByName('name').AsString, 1, 60 - Length(NewRUIDStr)) + NewRUIDStr;
        gdcBaseManager.ExecSingleQuery('insert into gd_function (ID, ACHAG,AFULL,AVIEW,BREAKPOINTS,COMMENT,DISPLAYSCRIPT,EDITIONDATE,EDITORKEY,EDITORSTATE,ENTEREDPARAMS,EVENT,FUNCTIONTYPE,GROUPNAME, ' +
            ' INHERITEDRULE,LANGUAGE,LOCALNAME,MODIFYDATE,MODULE,MODULECODE,NAME,OWNERNAME,PUBLICFUNCTION,RESERVED,SCRIPT,SHORTCUT,TESTRESULT,USEDEBUGINFO) ' +
            ' select ' + TID2S(NewLinkID) + ', ACHAG,AFULL,AVIEW,BREAKPOINTS,COMMENT,DISPLAYSCRIPT,EDITIONDATE,EDITORKEY,EDITORSTATE,ENTEREDPARAMS,EVENT,FUNCTIONTYPE,GROUPNAME, ' +
            '  INHERITEDRULE,LANGUAGE,LOCALNAME,MODIFYDATE,MODULE,MODULECODE,''' + NameFunc + ''',OWNERNAME,PUBLICFUNCTION,RESERVED,SCRIPT,SHORTCUT,TESTRESULT,USEDEBUGINFO ' +
            '  from gd_function where id = ' + TID2S(ibsqlList.FieldByName('id')), Transaction);
        gdcBaseManager.ExecSingleQuery('update gd_function set script = replace(script, ''' + ibsqlList.FieldByName('name').AsString + ''', ''' + NameFunc + ''') where id = ' + TID2S(NewLinkID), Transaction);
        gdcBaseManager.ExecSingleQuery('update gd_function set script = replace(script, ''' + ibsqlList.FieldByName('name').AsString + ''', ''' + NameFunc + ''') where id = ' + TID2S(MainFuncID), Transaction);
        InsertFunction(GetTID(ibsqlList.FieldByName('id')), NewLinkID);
      end
      else
      begin
        NameFunc := ibsqlList.FieldByName('name').AsString;
        NewLinkID := GetTID(ibsqlList.FieldByName('id'));
      end;
      gdcBaseManager.ExecSingleQuery('INSERT INTO RP_ADDITIONALFUNCTION (MAINFUNCTIONKEY, ADDFUNCTIONKEY) VALUES(' + TID2S(MainFuncID) + ',' + TID2S(NewLinkID) + ')', Transaction);
      ibsqlList.Next;
    end;
  finally
    ibsqlList.Free;
  end
end;

procedure CopyStorageDocument;
begin

end;

begin
  InTransaction := Transaction.InTransaction;

{ ����������� ������ ��������� � ���������� }
  OldRUID := FieldByName('RUID').AsString;
  OldID := GetTID(FieldByName('ID'));
  if not InTransaction then
    Transaction.StartTransaction;
  try
    CopyObject(True, False);
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := Transaction;
      ibsql.SQL.Text := 'INSERT INTO GD_DOCUMENTTYPE_OPTION (BOOL_VALUE,CONTACTKEY,CURRKEY,DISABLED,DTKEY,EDITIONDATE,OPTION_NAME,RELATIONFIELDKEY) ' +
        ' select BOOL_VALUE,CONTACTKEY,CURRKEY,DISABLED,CAST(:DTKEY as DINTKEY),EDITIONDATE,OPTION_NAME,RELATIONFIELDKEY from GD_DOCUMENTTYPE_OPTION where DTKEY = :OLDID ';
      SetTID(ibsql.ParamByName('DTKEY'), ID);
      SetTID(ibsql.ParamByName('OLDID'), OLDID);
      ibsql.ExecQuery;

  { ����������� ��������, ������� � ������� }
      CurID := -1;
      NewID := -1;
      ibsql.Close;
      ibsql.SQL.Text :=
        ' select e.id, e.NAME, e.objectname, ev.id as ev_id, e.subtype, ev.functionkey, f.name as function_name from evt_object e ' +
        '  left join EVT_OBJECTEVENT ev ON e.ID = ev.OBJECTKEY ' +
        '  left join gd_function f ON ev.functionkey = f.id ' +
        ' where e.name like ''%' + OldRUID + '%''' +
        ' order by e.id ';
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        if CurID <> GetTID(ibsql.FieldByName('id')) then
        begin
          NewID := GetNextID;
          if ibsql.FieldByName('subtype').AsString = '' then
            gdcBaseManager.ExecSingleQuery('INSERT INTO evt_object (REPORTGROUPKEY,EDITIONDATE,RESERVED,ID,PARENTINDEX,CLASSNAME,MACROSGROUPKEY,EDITORKEY,LB,NAME,OBJECTNAME,DESCRIPTION,AFULL,RB,ACHAG,PARENT,OBJECTTYPE,AVIEW) ' +
              ' select REPORTGROUPKEY,EDITIONDATE,RESERVED,' + TID2S(NewID) + ',PARENTINDEX,CLASSNAME,MACROSGROUPKEY,EDITORKEY,LB,''' + StringReplace(ibsql.FieldByName('name').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''',''' + StringReplace(ibsql.FieldByName('objectname').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''',DESCRIPTION,AFULL,RB,ACHAG,PARENT,OBJECTTYPE,AVIEW from evt_object where id = ' + TID2S(ibsql.FieldByName('id')),
              Transaction)
          else
            gdcBaseManager.ExecSingleQuery('INSERT INTO evt_object (REPORTGROUPKEY,EDITIONDATE,RESERVED,ID,PARENTINDEX,CLASSNAME,MACROSGROUPKEY,EDITORKEY,LB,NAME,OBJECTNAME,DESCRIPTION,AFULL,RB,ACHAG,PARENT,OBJECTTYPE,AVIEW, SUBTYPE) ' +
              ' select REPORTGROUPKEY,EDITIONDATE,RESERVED,' + TID2S(NewID) + ',PARENTINDEX,CLASSNAME,MACROSGROUPKEY,EDITORKEY,LB,''' + StringReplace(ibsql.FieldByName('name').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''',''' + StringReplace(ibsql.FieldByName('objectname').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''',DESCRIPTION,AFULL,RB,ACHAG,PARENT,OBJECTTYPE,AVIEW, ''' + FieldByName('ruid').AsString + ''' from evt_object where id = ' + TID2S(ibsql.FieldByName('id')),
              Transaction);
          CurID := GetTID(ibsql.FieldByName('id'));
        end;
        if ibsql.FieldByName('functionkey').AsInteger > 0 then
        begin
          NewFuncID := GetNextID;
          gdcBaseManager.ExecSingleQuery('insert into gd_function (ID, ACHAG,AFULL,AVIEW,BREAKPOINTS,COMMENT,DISPLAYSCRIPT,EDITIONDATE,EDITORKEY,EDITORSTATE,ENTEREDPARAMS,EVENT,FUNCTIONTYPE,GROUPNAME, ' +
            ' INHERITEDRULE,LANGUAGE,LOCALNAME,MODIFYDATE,MODULE,MODULECODE,NAME,OWNERNAME,PUBLICFUNCTION,RESERVED,SCRIPT,SHORTCUT,TESTRESULT,USEDEBUGINFO) ' +
            ' select ' + TID2S(NewFuncID) + ', ACHAG,AFULL,AVIEW,BREAKPOINTS,COMMENT,DISPLAYSCRIPT,EDITIONDATE,EDITORKEY,EDITORSTATE,ENTEREDPARAMS,EVENT,FUNCTIONTYPE,GROUPNAME, ' +
            '  INHERITEDRULE,LANGUAGE,LOCALNAME,MODIFYDATE,MODULE,MODULECODE,''' + StringReplace(ibsql.FieldByName('function_name').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''',OWNERNAME,PUBLICFUNCTION,RESERVED,SCRIPT,SHORTCUT,TESTRESULT,USEDEBUGINFO ' +
            '  from gd_function where id = ' + TID2S(ibsql.FieldByName('functionkey')), Transaction);

          gdcBaseManager.ExecSingleQuery('update gd_function set script = replace(script, ''' + ibsql.FieldByName('function_name').AsString + ''', ''' + StringReplace(ibsql.FieldByName('function_name').AsString, OldRUID, FieldByName('ruid').AsString, []) + ''') where id = ' + TID2S(NewFuncID), Transaction);

          InsertFunction(GetTID(ibsql.FieldByName('functionkey')), NewFuncID);

          NewEvID := GetNextID;
          gdcBaseManager.ExecSingleQuery('insert into evt_objectevent (EDITIONDATE,RESERVED,ID,EDITORKEY,OBJECTKEY,DISABLE,AFULL,EVENTNAME,FUNCTIONKEY) ' +
            ' select EDITIONDATE,RESERVED,' + TID2S(NewEvID) + ',EDITORKEY,' + TID2S(NewID) + ',DISABLE,AFULL,EVENTNAME, ' + TID2S(NewFuncID) + ' from evt_objectevent where id = ' +  TID2S(ibsql.FieldByName('ev_id')),
            Transaction);
        end;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

  { ����������� ������� }

    if not InTransaction then
      Transaction.Commit;
  except
    if not InTransaction then
      Transaction.Rollback;
    Refresh;  
  end
end;

{ TgdcUserDocumentType }

constructor TgdcUserDocumentType.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

procedure TgdcUserDocumentType.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCUSERDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERDOCUMENTTYPE', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERDOCUMENTTYPE',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Process = cpInsert then
  begin
    DE := gdClassList.Add('TgdcUserDocument', FieldByName('ruid').AsString, GetParentSubType,
      TgdDocumentEntry, FieldbyName('name').AsString) as TgdDocumentEntry;
    DE.TypeID := ID;
    DE.LoadDE(Transaction);

    if GetTID(FieldbyName('linerelkey')) > 0 then
    begin
      gdClassList.Add('TgdcUserDocumentLine', FieldByName('ruid').AsString, GetParentSubType,
        TgdDocumentEntry, FieldbyName('name').AsString).Assign(DE);
    end else
      gdClassList.Remove('TgdcUserDocumentLine', FieldByName('ruid').AsString);

    gdClassList.CreateFormSubTypes;  
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERDOCUMENTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserDocumentType.GetHeaderDocumentClass: CgdcBase;
begin
  Result := TgdcUserDocument;
end;

class function TgdcUserDocumentType.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgUserDocumentSetup';
end;

procedure TgdcUserDocumentType.FullCopyDocument;
begin
  inherited;
{ �������� ��� �������� ��� ���� �������� ��� �������� + copy }

{ � ��������� ���� ����� Tgdc_dlgUserSimpleDocument, Tgdc_dlgUserComplexDocument, Tgdc_dlgUserDocumentLine (��������� ���� ���� �������) }
{    Tgdc_frmUserSimpleDocument, Tgdc_frmUserComplexDocument }
{ � ���� ������ ���� ���� � �������� }
{ � ��������� � ����� Administrator ���� ����� gdc_dlgUserComplexDocumentRUID � �������� ��� ����������,
  ��� �� gdc_frmUserSimpleDOcumentRUID � gdc_frmUserComplexDocmentRUID }
{ � ������� evt_object ���� ��� ������� ������� �������� ���� ������ ��������� � ��� ��������� }
{ �� ��������� �������� ������� ����� � ���� ��� ��� ������ � ������� evt_objectevent }
{ � �������� ������ � ������� gd_function ������� ������� ��� evt_objectevent � ������� ����� ������� }
  
end;

{ TgdcUserBaseDocument }

procedure TgdcUserBaseDocument._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCUSERBASEDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  SetTID(FieldByName('documentkey'), FieldByName('ID'));
  if GetDocumentClassPart <> dcpHeader then
    SetTID(FieldByName('masterkey'), FieldByName('parent'));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcUserBaseDocument.EnumModificationList(
  RelationName: String): String;
var
  I: Integer;
  R: TatRelation;
begin
  Result := '';
  if not Assigned(atDatabase) then Exit;

  R := atDatabase.Relations.ByRelationName(RelationName);
  if not Assigned(R) then Exit;

  for I := 0 to R.RelationFields.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result :=
      Result +
      R.RelationFields[I].FieldName +
      ' = :' +
      R.RelationFields[I].FieldName;
  end;
end;

function TgdcUserBaseDocument.EnumRelationFields(RelationName: String;
  const AliasName: String; const UseDot: Boolean): String;
var
  R: TatRelation;
  I: Integer;
begin
  Result := '';

  if not Assigned(atDatabase) then Exit;
  R := atDatabase.Relations.ByRelationName(RelationName);

  if not Assigned(R) then Exit;

  for I := 0 to R.RelationFields.Count - 1 do
  begin
    if Result > '' then
      Result := Result + ', ';

    Result := Result + AliasName;

    if UseDot then
      Result := Result + '.';

    Result := Result + R.RelationFields[I].FieldName;
  end;
end;

function TgdcUserBaseDocument.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCUSERBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY';

  if GetDocumentClassPart <> dcpHeader then
    Result := Result + ',MASTERKEY';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserBaseDocument.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := Format('z.documenttypekey = %d AND z.parent + 0 IS NULL ',
    [gdcBaseManager.GetIDByRUIDString(ASubType)]);
end;

procedure TgdcUserBaseDocument.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;
end;

function TgdcUserBaseDocument.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  CE: TgdClassEntry;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCUSERBASEDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if SubType > '' then
  begin
    CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, Self.SubType).GetRootSubType;
    Result :=
      inherited GetSelectClause + ', ' +
      EnumRelationFields(TgdDocumentEntry(CE).DistinctRelation, 'U', True);
  end else
    Result := inherited GetSelectClause;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcUserBaseDocument.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  CE: TgdClassEntry;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCUSERBASEDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if SubType > '' then
  begin
    CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, Self.SubType).GetRootSubType;
    Result :=
      inherited GetFromClause(ARefresh) +
      Format(
        '  JOIN %s u ON ' +
        '    u.documentkey = z.id ',
        [TgdDocumentEntry(CE).DistinctRelation]
      );
  end else
    Result := inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUserBaseDocument.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  CE: TgdClassEntry;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSERBASEDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if GetTID(FieldByName('documentkey')) <> GetTID(FieldByName('id')) then
    SetTID(FieldByName('documentkey'), FieldByName('id'));

  CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, Self.SubType).GetRootSubType;
  CustomExecQuery(
    Format(
      'INSERT INTO %s ' +
      '  (%s) ' +
      'VALUES ' +
      '  (%s) ',
      [TgdBaseEntry(CE).DistinctRelation, EnumRelationFields(TgdBaseEntry(CE).DistinctRelation, '', False),
        EnumRelationFields(TgdBaseEntry(CE).DistinctRelation, ':', False)]
    ),
    Buff
  );

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUserBaseDocument.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  CE: TgdClassEntry;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSERBASEDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERBASEDOCUMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERBASEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERBASEDOCUMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERBASEDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, Self.SubType).GetRootSubType;
  CustomExecQuery(
    Format(
      'UPDATE %s ' +
      'SET ' +
      '  %s ' +
      'WHERE ' +
      '  (documentkey = :old_documentkey) ',
      [TgdBaseEntry(CE).DistinctRelation, EnumModificationList(TgdBaseEntry(CE).DistinctRelation)]
    ),
    Buff
  );

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERBASEDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERBASEDOCUMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserBaseDocument.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByRUID(ASubType, GetDocumentClassPart, True);
  if DE <> nil then
  begin
    if DE.LineRelName = '' then
      Result := 'Tgdc_frmUserSimpleDocument'
    else
      Result := 'Tgdc_frmUserComplexDocument';
  end else
    raise Exception.Create('������� ��� ���������');
end;

class function TgdcUserBaseDocument.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcUserBaseDocument');
end;

{ TgdcUserDocument }

class function TgdcUserDocument.GetSubSetList: String;
begin
  Result := StringReplace(inherited GetSubSetList,
    'ByParent;', '', []);
end;

function TgdcUserDocument.GetDetailObject: TgdcDocument;
begin
  if gdClassList.Find('TgdcUserDocumentLine', SubType) <> nil then
  begin
    Result := TgdcUserDocumentLine.CreateSubType(Owner, SubType);
    if sLoadFromStream in BaseState then
      Result.SetBaseState(Result.BaseState + [sLoadFromStream]);
  end else
    Result := nil;
end;

procedure TgdcUserDocument.GetWhereClauseConditions(S: TStrings);
var
  Str: String;
  i: Integer;
begin
  inherited;
  if HasSubSet('OnlySelected') then
  begin
    Str := '';
    for I := 0 to SelectedID.Count - 1 do
    begin
      if Length(Str) >= 8192 then break;
      Str := Str + TID2S(SelectedID[I]) + ',';
    end;
    if Str = '' then
      Str := '-1'
    else
      SetLength(Str, Length(Str) - 1);
    S.Add(Format('%s.%s IN (%s)', ['U', 'documentkey', Str]));
  end;

end;

function TgdcUserDocument.GetCompoundMasterTable: String;
begin
  Result := TgdBaseEntry(gdClassList.Get(TgdDocumentEntry, ClassName, SubType)).DistinctRelation;
end;

procedure TgdcUserDocument.CheckCompoundClasses;
var
  I: Integer;
begin
  inherited;

  if FCompoundClasses = nil then
    FCompoundClasses := TObjectList.Create(True);

  for I := 0 to FCompoundClasses.Count - 1 do
  begin
    if (FCompoundClasses[I] as TgdcCompoundClass).SubType = SubType then
      exit;
  end;

  FCompoundClasses.Add(
    TgdcCompoundClass.Create(TgdcUserDocumentLine, SubType,
      TgdDocumentEntry(gdClassList.Get(TgdDocumentEntry, ClassName, SubType)).LineRelName,
      'MASTERKEY'));
end;

class function TgdcUserDocument.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
var
  CE: TgdClassEntry;
begin
  CE := gdClassList.Get(TgdDocumentEntry, Self.ClassName, ASubType);

  if (CE as TgdDocumentEntry).LineRelKey > 0 then
    Result := 'Tgdc_dlgUserComplexDocument'
  else
    Result := 'Tgdc_dlgUserSimpleDocument';
end;

{ TgdcUserDocumentLine }

constructor TgdcUserDocumentLine.Create(AnOwner: TComponent);
begin
  inherited;
  DetailField := 'Parent';
end;

procedure TgdcUserDocumentLine.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M} VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCUSERDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERDOCUMENTLINE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERDOCUMENTLINE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not CachedUpdates) and Assigned(MasterSource)
    and Assigned(MasterSource.DataSet) and (MasterSource.DataSet.State = dsInsert) then
  begin
    try
      MasterSource.DataSet.Post;
    except
      on E: Exception do
      begin
        MessageBox(ParentHandle,
          PChar(Format(s_InvErrorSaveHeadDocument, [E.Message])),
          PChar(sAttention),
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
        Abort;
      end;
    end;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERDOCUMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

function TgdcUserDocumentLine.GetCompoundMasterTable: String;
begin
  Result := TgdDocumentEntry(gdClassList.Get(TgdDocumentEntry, ClassName, SubType)).LineRelName;
end;

class function TgdcUserDocumentLine.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgUserDocumentLine';
end;

class function TgdcUserDocumentLine.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine;
end;

function TgdcUserDocumentLine.GetMasterObject: TgdcDocument;
begin
  Result := TgdcUserDocument.CreateSubType(Owner, SubType);
end;

class function TgdcUserDocumentLine.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := Format('z.documenttypekey = %d AND z.parent IS NOT NULL ',
    [gdcBaseManager.GetIDByRUIDString(ASubType)]);
end;

initialization
  RegisterGdcClass(TgdcDocument);
  RegisterGdcClass(TgdcBaseDocumentType);
  RegisterGdcClass(TgdcDocumentBranch,    '�����');
  RegisterGdcClass(TgdcDocumentType,      '��� ���������');
  RegisterGdcClass(TgdcUserDocumentType,  '��� ����������������� ���������');
  RegisterGdcClass(TgdcUserBaseDocument);
  RegisterGdcClass(TgdcUserDocument);
  RegisterGdcClass(TgdcUserDocumentLine);

finalization
  UnregisterGdcClass(TgdcDocument);
  UnregisterGdcClass(TgdcBaseDocumentType);
  UnregisterGdcClass(TgdcDocumentBranch);
  UnregisterGdcClass(TgdcDocumentType);
  UnregisterGdcClass(TgdcUserDocumentType);
  UnregisterGdcClass(TgdcUserBaseDocument);
  UnregisterGdcClass(TgdcUserDocument);
  UnregisterGdcClass(TgdcUserDocumentLine);
end.

