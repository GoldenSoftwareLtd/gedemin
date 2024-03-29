// ShlTanya, 09.02.2019

{
  ��������

  TgdcAccount       - ��������� ����

  TgdcBaseContact   - ������� �������
  TgdcFolder        - �����
  TgdcGroup         - ������
  TgdcContact       - �������
  TgdcDepartment    - �������������
  TgdcCompany       - �������
  TgdcOurCompany    - ������� �����������
  TgdcBank          - ����

  Revisions history

    1.00    29.10.01    sai        Initial version.
    1.01    05.11.01    sai        ���������� ������ ChooseElement
            01.03.02    Julia      ���������� ��������
}

unit gdcContacts;

interface

uses
  DB, Windows, Classes, ContNrs, IBCustomDataSet, gdcBase, gdcTree,
  Forms, gd_createable_form, dbgrids, gdcBaseInterface, Graphics;

const
  // contact type constants
  ct_Folder             = 0;
  ct_Group              = 1;
  ct_Contact            = 2;
  ct_Company            = 3;
  ct_Department         = 4;
  ct_Bank               = 5;

  {$IFDEF DEPARTMENT}
  ct_Sale               = 100;
  ct_Authority          = 101;
  ct_Financial          = 102;
  ct_Main               = 103;
  ct_Comittee           = 104;
  {$ENDIF}

  // sub set constants
  cst_Tree              = 'Tree';
  cst_Contacts          = 'Contacts';
  cst_Group             = 'Group';
  cst_AllContact        = 'AllContact'; //���������� �� All ��� ��� �� �������� �����
  cst_AllPeople         = 'AllPeople';
  cst_AllCompany        = 'AllCompany';
  cst_OnlyCompany       = 'OnlyCompany';
  cst_AllCompanyPeople  = 'AllCompanyPeople';
  cst_ByContactType     = 'ByContactType';
  cst_ByLBRBDepartment  = 'ByLBRBDepartment';
  cst_Holding           = 'ByHolding';
//  cst_DepartmentPeople  = 'DepartmentsAndPeople';

  // ID for reports group
  cst_ContactsGroupID   = 2000510;

type
  // ��������� ���� �����������
  TgdcAccount = class(TgdcBase)
  {private
    FIgnoryQuestion: Boolean;}

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    //procedure DoBeforePost; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetReductionCondition: String; override;

    //
    procedure SyncField(Field: TField); override;
    // ����� ���������� ����� ��������� ������ �� ��������� ��
    // ����������, ��������������, ��������
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;
    function GetDialogDefaultsFields: String; override;

    //��������� ���� �� ������������ �� ������ ������ ��������
    //���������� ������, ���� �������� ������ �������
    //(���� ���� �� �����������, ���� ������������ ��� �����
    //����� ��� ���������)
    //function CheckDouble(AnAccount, ABankCode: String): Boolean;

    //
    //function CheckAccount(const Code, Account: String): Boolean;

    //property IgnoryQuestion: Boolean read FIgnoryQuestion write FIgnoryQuestion;
  end;

  TgdcBaseContact = class;
  CgdcBaseContact = class of TgdcBaseContact;

  TgdcBaseContact = class(TgdcLBRBTree)
  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoBeforeDelete; override;

    procedure SyncField(Field: TField); override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

    procedure CreateFields; override;

  public
    function GetBankAttribute: String;

    constructor Create(AnOwner: TComponent); override;

    function GetDialogDefaultsFields: String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    class function IsAbstractClass: Boolean; override;
    class function ContactType: Integer; virtual;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    //
    class function HasLeafs: Boolean; override;

    procedure SetInclude(const AnID: TID); override;
  end;

  TgdcFolder = class(TgdcBaseContact)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function HasLeafs: Boolean; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcGroup = class(TgdcBaseContact)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoBeforeDelete;override;
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcDepartment = class(TgdcBaseContact)
  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function HasLeafs: Boolean; override;
  end;

  TgdcCompany = class(TgdcBaseContact)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function GetNotCopyField: String; override;
    function IsReverseOrder(const AFieldName: String): Boolean; override;
    procedure CreateFields; override;
    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure DoAfterDelete; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;
    function GetCurrRecordClass: TgdcFullClass; override;
  end;

  TgdcOurCompany = class(TgdcCompany)
  private
    FAddCompany: Boolean;
    FOnlyOurCompany: Boolean;

  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    function DoAfterInitSQL(const AnSQLText: String): String; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function ContactType: Integer; override;

    class function Class_TestUserRights(const SS: TgdcTableInfos;
      const ST: String): Boolean; override;

    class procedure SaveOurCompany(const ACompanyKey: TID);

    function CheckTheSameStatement: String; override;
    procedure _DoOnNewRecord; override;

    property OnlyOurCompany: Boolean read FOnlyOurCompany write FOnlyOurCompany;
  end;

  TgdcContact = class(TgdcBaseContact)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure DoBeforePost; override;

    function GetNotCopyField: String; override;

  public
    procedure _DoOnNewRecord; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class procedure GetClassImage(const ASizeX, ASizeY: Integer; AGraphic: TGraphic); override;
  end;

  TgdcEmployee = class(TgdcContact)
  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetSelectClause: String; override;
    function GetOrderClause: String; override;

    procedure DoBeforePost; override;
    procedure CreateFields; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    //���� �� ������� ������� ��������, �� ������� �������������,
    //�� ������������� ��� �������� �� �������������
    //������ ������� ��������� � ��������� �������������� ��� �������
    procedure SetWCompanyKeyByDepartment;
  end;

  TgdcBank = class(TgdcCompany)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function GetNotCopyField: String; override;

    procedure _DoOnNewRecord; override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class procedure GetClassImage(const ASizeX, ASizeY: Integer; AGraphic: TGraphic); override;

    function CheckTheSameStatement: String; override;
  end;

procedure Register;

implementation

uses
  gd_security,
  Sysutils,
  IBSQL,
  Storages,
  IBDataBase, IB, IBErrorCodes,
  jclStrings,

  dmImages_unit,
  at_classes,
  gdc_dlgFolder_unit,
  gdc_dlgGroup_unit,
  gdc_dlgCompany_unit,
  gdc_dlgBank_unit,
  gdc_dlgDepartment_unit,
  gdc_dlgContact_unit,
  gdc_dlgEmployee_unit,
  gdc_dlgOurCompany_unit,
  gdc_dlgCompanyAccount_unit,

  gdc_ab_frmmain_unit,
  gdc_frmCompany_unit,
  gdc_frmBank_unit,
  gdc_frmAccount_unit,
  gdc_frmOurCompany_unit,
  gdc_frmContact_unit,
  gdc_frmGroup_unit,
  gdc_frmDepartment_unit,
  gd_ClassList
  {$IFDEF DEPARTMENT}
  , gdcDepartament
  {$ENDIF}
  , gd_directories_const,
   at_sql_setup
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
   ;

const
  ContactTypes: array[-1..6] of CgdcBaseContact = (
    TgdcBaseContact,
    TgdcFolder,
    TgdcGroup,
    TgdcContact,
    TgdcCompany,
    TgdcDepartment,
    TgdcBank,
    TgdcOurCompany
  );

procedure Register;
begin
  RegisterComponents('gdcContacts', [TgdcFolder]);
  RegisterComponents('gdcContacts', [TgdcBaseContact]);
  RegisterComponents('gdcContacts', [TgdcDepartment]);
  RegisterComponents('gdcContacts', [TgdcGroup]);
  RegisterComponents('gdcContacts', [TgdcCompany]);
  RegisterComponents('gdcContacts', [TgdcOurCompany]);
  RegisterComponents('gdcContacts', [TgdcContact]);
  RegisterComponents('gdcContacts', [TgdcEmployee]);
  RegisterComponents('gdcContacts', [TgdcBank]);
  RegisterComponents('gdcContacts', [TgdcAccount]);
end;

{ TgdcAccount }

class function TgdcAccount.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'account';
end;

class function TgdcAccount.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'gd_companyaccount';
end;

function TgdcAccount.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCACCOUNT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ' +
    '  gd_companyaccount z ' +
    '  LEFT JOIN gd_bank b ON z.bankkey = b.bankkey ' +
    '  LEFT JOIN gd_contact c ON z.bankkey = c.id ' +
    '  LEFT JOIN gd_compacctype t ON z.accounttypekey = t.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAccount.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCACCOUNT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.id, ' +
    '  z.bankkey, ' +
    '  t.name AS joinaccounttype, ' +
    '  z.companykey, ' +
    '  z.disabled, ' +
    '  z.currkey, ' +
    '  z.account, ' +
    '  z.iban, ' +
    '  z.accounttypekey, ' +
    '  z.payername, ' +
    '  z.editiondate, ' +
    '  c.name AS bankname, ' +
    '  b.bankcode, ' +
    '  b.bankmfo, ' +
    '  b.SWIFT ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAccount.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByCompany') then
    S.Add('z.companykey = :CompanyKey');
  if HasSubSet('ByAccount') then
    S.Add('z.account = :Account');
end;

class function TgdcAccount.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAccount;ByCompany;';
end;

(*
procedure TgdcAccount.DoBeforePost;
var
  q: TIBSQL;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    q := TIBSQL.Create(nil);
    try
      if Transaction.InTransaction then
        q.Transaction := Transaction
      else
        q.Transaction := ReadTransaction;

      q.SQL.Text := 'SELECT bankcode, bankmfo, swift FROM gd_bank WHERE bankkey = :id';
      q.ParamByName('id').AsString := FieldByName('bankkey').AsString;
      q.ExecQuery;

      if not q.EOF then
      begin
        FieldByName('bankcode').AsString := q.FieldByName('bankcode').AsString;
        FieldByName('bankmfo').AsString := q.FieldByName('bankmfo').AsString;
        FieldByName('swift').AsString := q.FieldByName('swift').AsString;
      end;

      {if (not (sLoadFromStream in BaseState))
        and (not IgnoryQuestion)
        and
          (not
            (
              CheckAccount(FieldByName('bankcode').AsString, FieldByName('account').AsString)
              and
              CheckDouble(FieldByName('account').AsString, FieldByName('bankcode').AsString)
            )
          ) then
        raise Exception.Create('�������� ��������� ����!');}
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;
*)

{
function TgdcAccount.CheckDouble(AnAccount, ABankCode: String): Boolean;
var
  q: TIBSQL;
  qBank: TIBSQL;
  DidActivate: Boolean;
begin
  Result := True;

  if (sLoadFromStream in BaseState) then Exit;

  q := CreateReadIBSQL(DidActivate);
  qBank := CreateReadIBSQL(DidActivate);
  try
    qBank.SQL.Text := 'SELECT * FROM gd_bank WHERE bankcode = :bankcode';
    qBank.ParamByName('bankcode').AsString := ABankCode;
    qBank.ExecQuery;
// �.�. � ����� ������ ���������������, ��� ��� ����� �� ��������
    while not qBank.Eof do
    begin
      q.Close;
      q.SQL.Text :=
        ' SELECT c.name FROM gd_companyaccount ca LEFT JOIN gd_contact c ' +
        ' ON ca.companykey = c.id WHERE ca.id <> :id' +
        ' and ca.account = :account and ca.bankkey = :bankkey ';
      q.ParamByName('id').AsString := FieldByName('id').AsString;
      q.ParamByName('account').AsString := AnAccount;
      q.ParamByName('bankkey').AsString := qBank.FieldByName('bankkey').AsString;
      q.ExecQuery;

      if (q.RecordCount > 0) then
         Result := MessageBox(HWND(nil), Pchar('�/� ����������� ' + q.FieldByName('NAME').AsString +
           ' ��������� ?'),
         '��������', MB_YESNO) = idYes;

      if not Result then Break;
      q.Close;
      qBank.Next;
    end;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
    qBank.Free;
  end;
end;
}

{
function TgdcAccount.CheckAccount(const Code, Account: String): Boolean;
const
  Control: array[1..16] of Byte =
    (7, 1, 3, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3);
var
  CheckString: String[16];
  I, Base: Byte;
begin
  Result := True;

  if (sLoadFromStream in BaseState)
    or (not (Owner is TCustomForm)) then
  begin
    Result := True;
    Exit;
  end;

  // ��������� ������ ����������� 13-�� ������� �����
  if Length(Account) <> 13 then
  begin
    Result := True;
    Exit;
  end;

  if Assigned(GlobalStorage)
    and (not (GlobalStorage.ReadBoolean('Options',
      'CheckAccount', True, False))) then
  begin
    Result := True;
    Exit;
  end;

  if Length(Code) > 3 then
    CheckString := System.copy(Code, Length(Code) - 2, 3) + Account
  else
    CheckString := Code + Account;
  if (Length(CheckString) <> 16) then
    Result := False
  else begin
    Base := 0;
    for I := 1 to 15 do
      Base := Base + (((Ord(CheckString[I]) - 48) * Control[I]) mod 10);
    Result := (Ord(CheckString[16]) - 48) = ((Base * Control[16]) mod 10);
  end;

  if (not Result) then
  begin
     Result := MessageBox(0,
      PChar('������������ ��������� ���� ' + Account + '. ���������?'),
      '��������',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = idYes;
  end;
end;
}

function TgdcAccount.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCACCOUNT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'accounttypekey;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcAccount.GetReductionCondition: String;
begin
  if not IsEmpty then
    Result := ' companykey = ' + FieldByName('companykey').AsString
  else
    Result := inherited GetReductionCondition;  
end;

procedure TgdcAccount.SyncField(Field: TField);
var
  q: TIBSQL;
begin
  if (State in dsEditModes) and CachedUpdates then
  begin
    if AnsiSameText(Field.FieldName, 'bankkey') then
    begin
      if Field.AsString = '' then
        FieldByName('bankname').Clear
      else
      begin
        q := TIBSQL.Create(nil);
        try
          q.Database := Database;
          q.Transaction := ReadTransaction;
          q.SQL.Text := 'SELECT name FROM gd_contact WHERE id=' + Field.AsString;
          q.ExecQuery;
          if q.EOF or q.Fields[0].IsNull then
            FieldByName('bankname').Clear
          else
            FieldByName('bankname').AsString := q.Fields[0].AsString;

          q.Close;
          q.SQL.Text := 'SELECT bankcode, bankmfo, SWIFT FROM gd_bank WHERE bankkey=' + Field.AsString;
          q.ExecQuery;
          if q.EOF or q.Fields[0].IsNull then
            FieldByName('bankcode').Clear
          else
            FieldByName('bankcode').AsString := q.Fields[0].AsString;
          if q.EOF or q.Fields[1].IsNull then
            FieldByName('bankmfo').Clear
          else
            FieldByName('bankmfo').AsString := q.Fields[1].AsString;
          if q.EOF or q.Fields[2].IsNull then
            FieldByName('SWIFT').Clear
          else
            FieldByName('SWIFT').AsString := q.Fields[1].AsString;
        finally
          q.Free;
        end;
      end;
    end;
  end;

  inherited;
end;

constructor TgdcAccount.Create(AnOwner: TComponent);
begin
  inherited;
  //FIgnoryQuestion := False;
end;

class function TgdcAccount.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAccount';
end;

procedure TgdcAccount.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCACCOUNT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if Process = cpInsert then
  begin
  //��������, ���� �� � �������� ������� ����, ���� ���, �� ������� ������� �������
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := Transaction;
      ibsql.SQL.Text := 'SELECT * FROM gd_company WHERE contactkey = :ck';
      SetTID(ibsql.ParamByName('ck'), FieldByName('companykey'));
      ibsql.ExecQuery;
      if (not ibsql.EOF) and ibsql.FieldByName('companyaccountkey').IsNull then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_company SET companyaccountkey = :cak ' +
          ' WHERE contactkey = :ck ';
        SetTID(ibsql.ParamByName('ck'), FieldByName('companykey'));
        SetTID(ibsql.ParamByName('cak'), ID);
        ibsql.ExecQuery;
      end;
    finally
      ibsql.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}

end;

function TgdcAccount.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCACCOUNT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCOUNT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCOUNT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCOUNT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT acc.id FROM gd_companyaccount acc WHERE acc.account = :account '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT acc.id FROM gd_companyaccount acc WHERE acc.account = ''%s'' ',
      [StringReplace(FieldByName('account').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCOUNT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCOUNT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcAccount.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCompanyAccount';
end;

{ TgdcBaseContact }

constructor TgdcBaseContact.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify];
end;

function TgdcBaseContact.GetBankAttribute: String;
var
  q: TIBSQL;
begin
  q := CreateReadIBSQL;
  try
    q.SQL.Text :=
      ' SELECT ca.account, bc.name, b.bankcode ' +
      ' FROM gd_company cm ' +
      ' JOIN gd_companyaccount ca ON cm.companyaccountkey = ca.id ' +
      ' JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' JOIN gd_contact bc ON bc.id = ca.bankkey ' +
      ' WHERE cm.contactkey = :id ';
    q.Prepare;

    SetTID(q.ParamByName('id'), FieldByName('id'));
    q.ExecQuery;
    if q.RecordCount > 0 then
      Result := '�/� ' + q.FieldByName('account').AsString +
        ' ����: ' + q.FieldByName('name').AsString + ' ���: ' +
        q.FieldByName('bankcode').AsString
    else
      Result := '';
  finally
    q.Free;
  end;
end;

function TgdcBaseContact.GetCurrRecordClass: TgdcFullClass;
var
  q: TIBSQL;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if not IsEmpty then
  begin
    case FieldByName('contacttype').AsInteger of
      ct_Folder: Result.gdClass := TgdcFolder;
      ct_Group: Result.gdClass := TgdcGroup;
      ct_Contact: Result.gdClass := TgdcContact;
      ct_Company: Result.gdClass := TgdcCompany;
      ct_Department: Result.gdClass := TgdcDepartment;
      ct_Bank: Result.gdClass := TgdcBank;

      {$IFDEF DEPARTMENT}
      ct_Sale: Result.gdClass := Tgdc_dpSale;
      ct_Authority: Result.gdClass := Tgdc_dpAuthority;
      ct_Financial: Result.gdClass := Tgdc_dpFinancial;
      ct_Main: Result.gdClass := Tgdc_dpMain;
      ct_Comittee: Result.gdClass := Tgdc_dpComittee;
      {$ENDIF}
    else
      raise EgdcException.CreateObj('Invalid contact type', Self);
    end;

    if (Result.gdClass = TgdcContact) and (not FieldByName('parent').IsNull) then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := ReadTransaction;
        q.SQL.Text :=
          'SELECT c.contacttype ' +
          'FROM ' +
          '  gd_contact c ' +
          '    JOIN gd_contact p ON p.id = c.parent AND p.contacttype IN (3, 4, 5) ' +
          '    JOIN gd_employee e ON e.contactkey = c.id ' +
          'WHERE ' +
          '  c.id = :ID';
        SetTID(q.ParamByName('ID'), FieldByName('id'));
        q.ExecQuery;
        if not q.EOF then
          Result.gdClass := TgdcEmployee;
      finally
        q.Free;
      end;
    end;
  end;

  FindInheritedSubType(Result);
end;

procedure TgdcBaseContact._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASECONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASECONTACT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASECONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASECONTACT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASECONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited _DoOnNewRecord;
  FieldByName('contacttype').AsInteger := ContactType;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASECONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASECONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseContact.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASECONTACT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASECONTACT', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASECONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASECONTACT',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASECONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  ExecSingleQuery('DELETE FROM gd_contactlist WHERE contactkey= :id ', TID2V(ID));

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASECONTACT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASECONTACT', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;


class function TgdcBaseContact.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcBaseContact.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'gd_contact';
end;

procedure TgdcBaseContact.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(cst_Tree) then
    S.Add('z.contacttype IN (' + IntToStr(ct_Folder) + {' ,' + IntToStr(ct_Group) + }') ');

  if HasSubSet(cst_Contacts) then
    S.Add(Format('(not (z.contacttype in (%d, '+{%d,}' %d)))', [ct_Folder, {ct_Group,} ct_Department]));

  if HasSubSet(cst_AllCompanyPeople) then
    S.Add(' z.contacttype in (2, 3, 5) ');

  if HasSubSet(cst_AllCompany) then
    S.Add(' z.contacttype in (3, 5) ');

  if HasSubSet(cst_OnlyCompany) then
    S.Add('z.contacttype = 3');

  if HasSubSet(cst_ByContactType) then
    S.Add(Format('z.contacttype = %d ', [ContactType]));

  if HasSubSet(cst_Group) then
    S.Add('g.groupkey = :groupkey');

  if HasSubSet(cst_AllPeople) then
    S.Add('z.contacttype = 2');

  if HasSubSet(cst_AllContact) then
    S.Add('z.contacttype > 1');
end;

class function TgdcBaseContact.ContactType: Integer;
var
  F: Boolean;
  C: TClass;
begin
  Result := -1;
  F := False;
  C := Self;
  while (not F) and (C <> nil) do
  begin
    for Result := Low(ContactTypes) to High(ContactTypes) do
      if ContactTypes[Result].ClassNameIs(C.ClassName) then
      begin
        F := True;
        break;
      end;
    if not F then
      C := C.ClassParent;
  end;

  if not F then
    raise Exception.Create('Unknown contact type');
end;

class function TgdcBaseContact.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  if (Self <> TgdcBaseContact) and (AnsiCompareText(ATableName, GetListTable(ASubType)) = 0) then
    Result := 'z.contacttype=' + IntToStr(ContactType)
  else
    Result := inherited GetRestrictCondition(ATableName, ASubType);
end;

class function TgdcBaseContact.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    cst_Group + ';' +
    cst_AllPeople + ';' +
    cst_AllContact + ';' +
    cst_Tree + ';' +
    cst_Contacts + ';' +
    cst_AllCompany + ';' +
    cst_AllCompanyPeople + ';' +
    cst_ByContactType + ';' +
    cst_OnlyCompany + ';';
end;

class function TgdcBaseContact.HasLeafs: Boolean;
begin
  Result := True;
end;

function TgdcBaseContact.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASECONTACT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASECONTACT', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASECONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASECONTACT',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASECONTACT' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASECONTACT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASECONTACT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseContact.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBASECONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASECONTACT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASECONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASECONTACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASECONTACT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh);
  if (not ARefresh) and HasSubSet(cst_Group) then
    Result := Result + ' JOIN gd_contactlist g ON g.contactkey=z.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASECONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASECONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseContact.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  {$IFDEF DEPARTMENT}
  Result := 'Tgdc_ab_dp_frmmain';
  {$ELSE}
  Result := 'Tgdc_ab_frmmain';
  {$ENDIF}
end;

procedure TgdcBaseContact.SyncField(Field: TField);

  procedure DoIt(const Pref: String);
  var
    q: TIBSQL;
  begin
    if (AnsiCompareText(Field.FieldName, Pref + 'PLACEKEY') = 0) and
      FieldChanged(Field.FieldName) then
    begin
    {���� �� ������ �������� ���� "��������������" ������� ��������� ����}
      FieldByName(Pref + 'city').Clear;
      FieldByName(Pref + 'district').Clear;
      FieldByName(Pref + 'region').Clear;
      FieldByName(Pref + 'country').Clear;
      if (not Field.IsNull) then
      begin
        q := TIBSQL.Create(nil);
        try
          q.Transaction := ReadTransaction;
          q.SQL.Text :=
            'SELECT parent, name, placetype FROM gd_place WHERE id=:ID';
          q.Prepare;
          repeat
            if q.Open then
            begin
              q.Close;
              SetTID(q.Params[0], q.Fields[0]);
            end else
              SetTID(q.Params[0], Field);
            q.ExecQuery;
            if q.EOF then
              break;
            if (StrIPos('�����', q.Fields[2].AsString) <> 0) or
              (StrIPos('�����', q.Fields[2].AsString) <> 0) then
              FieldByName(Pref + 'city').AsString := q.Fields[1].AsString
            else if AnsiCompareText(q.Fields[2].AsString, '�����') = 0 then
              FieldByName(Pref + 'district').AsString := q.Fields[1].AsString
            else if AnsiCompareText(q.Fields[2].AsString, '�������') = 0 then
              FieldByName(Pref + 'region').AsString := q.Fields[1].AsString
            else if AnsiCompareText(q.Fields[2].AsString, '������') = 0 then
              FieldByName(Pref + 'country').AsString := q.Fields[1].AsString;
          until q.Fields[0].IsNull;
        finally
          q.Free;
        end;
      end;
    end;
  end;

begin
  inherited;

  if State in dsEditModes then
  begin
    DoIt('');
    DoIt('h');
  end;  
end;

function TgdcBaseContact.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  C: TgdcFullClass;
  I: Integer;
  S: String;
  R: OleVariant;
begin
  Result := False;
  C := GetCurrRecordClass;

  if C.gdClass.InheritsFrom(TgdcFolder) or
     C.gdClass.InheritsFrom(TgdcGroup) or
     (CD.Obj is TgdcDepartment) then
  begin
    S := '';
    for I := 0 to CD.ObjectCount - 1 do
      S := S + TID2S(CD.ObjectArr[I].ID) + ',';
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT c.id FROM gd_contact c JOIN gd_contact p ON c.parent = p.id ' +
      'WHERE c.contacttype=2 AND p.contacttype=4 AND c.id IN (' + System.Copy(S, 1, Length(S) - 1) + ')',
      0, R);
    if VarIsEmpty(R) then
      Result := inherited AcceptClipboard(CD)
    else if sView in BaseState then
      MessageBox(ParentHandle,
        '������ ���� "��������� �����������" ������ ���������� � �����.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

procedure TgdcBaseContact.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASECONTACT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASECONTACT', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASECONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASECONTACT',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASECONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (Self.ClassName <> 'TgdcFolder') and (Self.ClassName <> 'TgdcGroup') then
  begin
    FieldByName('parent').Required := True;
  end;  

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASECONTACT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASECONTACT', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseContact.SetInclude(const AnID: TID);
var
  Obj: TgdcCompany;
  ibsql: TIBSQL;
  DidActivate: Boolean;
begin
  DidActivate := False;
  try
    DiDActivate := ActivateTransaction;

    inherited;

    if AnsiCompareText(Trim(SetTable), 'GD_HOLDING') = 0 then
    begin
      Obj := TgdcCompany.CreateSubType(nil, '', 'ByID');
      ibsql := TIBSQL.Create(nil);
      try
        Obj.ReadTransaction := Transaction;
        ibsql.Transaction := Transaction;
        ibsql.SQL.Text := 'SELECT * FROM gd_ourcompany WHERE companykey = :id';
        SetTID(ibsql.ParamByName('id'), ParamByName('MASTER_RECORD_ID'));
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          Obj.ID := AnID;
          Obj.Open;
          {���� �� ��������� �������� � ��� �� �������� ����� ���������, �� ������ �� ����� ���������}
          if (Obj.RecordCount > 0) and (Obj.GetCurrRecordClass.gdClass <> TgdcOurCompany) then
          begin
            ibsql.Close;
            ibsql.SQL.Text := (Format('INSERT INTO gd_ourcompany(companykey) ' +
              ' VALUES (%d)', [TID264(AnID)]));
            ibsql.ExecQuery;
          end;
        end;
      finally
        Obj.Free;
       ibsql.Free;
      end;
    end;

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  except
    if DidActivate and Transaction.InTransaction then
      Transaction.Rollback;
    raise;
  end;
end;

class function TgdcBaseContact.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcBaseContact');
end;

{ TgdcFolder }

class function TgdcFolder.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgFolder';
end;

procedure TgdcFolder.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.contacttype=0');
end;

class function TgdcFolder.HasLeafs: Boolean;
begin
  Result := False;
end;

{ TgdcGroup }

procedure TgdcGroup.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGROUP', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGROUP', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGROUP',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  ExecSingleQuery('DELETE FROM gd_contactlist WHERE groupkey= :id ', TID2V(ID));

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGROUP', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGROUP', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

class function TgdcGroup.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGroup';
end;

class function TgdcGroup.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmGroup';
end;

procedure TgdcGroup.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(GetListTableAlias + '.contacttype=1');
end;

{ TgdcDepartment }

procedure TgdcDepartment.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.contacttype = ' + IntToStr(ContactType));
  if HasSubSet(cst_Holding) then
    S.Add('h.holdingkey = :companykey')
  else if HasSubSet(cst_ByLBRBDepartment) then
    S.Add('clb.id = :companykey');
end;

function TgdcDepartment.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  i: Integer;
  LocalObj: TgdcEmployee;
begin
  if CD.Obj is TgdcEmployee then
  begin
    for I := 0 to CD.ObjectCount - 1 do
    begin
      if CD.Obj.Locate('ID', TID2V(CD.ObjectArr[I].ID), []) then
      begin
        CD.Obj.Edit;
        try
          SetTID(CD.Obj.FieldByName('parent'), Self.ID);
          CD.Obj.Post;
        except
          CD.Obj.Cancel;
          raise;
        end;
      end else
      begin
        LocalObj := TgdcEmployee.CreateWithParams(nil,
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
              SetTID(LocalObj.FieldByName('parent'), Self.ID);
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
  end else
    Result := inherited AcceptClipboard(CD);
end;

class function TgdcDepartment.HasLeafs: Boolean;
begin
  Result := False;
end;

class function TgdcDepartment.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    cst_ByLBRBDepartment + ';' + cst_Holding + ';';
end;

function TgdcDepartment.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCDEPARTMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDEPARTMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDEPARTMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDEPARTMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh);

  { TODO : ����� ������� ������ � ���� �������
  �� ����� ��� ��� ���������� ��������� �����
  }
  if (not ARefresh) and (HasSubSet(cst_ByLBRBDepartment) or HasSubSet(cst_Holding)) then
  begin
    Result := StringReplace(Result,
      'gd_contact z',
      'gd_contact clb JOIN gd_contact z ON z.lb >= clb.lb AND z.rb <= clb.rb ',
      [rfIgnoreCase]);
    if HasSubSet(cst_Holding) then
      Result := Result + ' JOIN gd_holding h ON clb.id = h.companykey ';

    FSQLSetup.Ignores.AddAliasName('clb');
    FSQLSetup.Ignores.AddAliasName('z').IgnoryType := itReferences;
  end
//    Result := Result + ' JOIN gd_contact clb ON z.lb >= clb.lb  AND  z.rb <= clb.rb ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDEPARTMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDEPARTMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcDepartment.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDepartment';
end;

class function TgdcDepartment.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgDepartment';
end;

{ TgdcContact }

procedure TgdcContact.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCONTACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(' INSERT INTO gd_people(contactkey, firstname, surname, middlename, nickname, rank, ' +
    ' haddress, hcity, hregion, hzip, hcountry, hdistrict, hphone, ' +
    '    wcompanykey, wcompanyname, wdepartment, ' +
    '    spouse, children, sex, birthday, visitcard, photo, ' +
    '    passportnumber, passportexpdate, passportissdate, passportissuer, ' +
    '    passportisscity, personalnumber, wpositionkey, hplacekey) ' +
    ' VALUES(:new_id, :new_firstname, :new_surname, :new_middlename, :new_nickname, :new_rank, ' +
    ' :new_haddress, :new_hcity, :new_hregion, :new_hzip, :new_hcountry, :new_hdistrict, :new_hphone, ' +
    ' :new_wcompanykey, :new_wcompanyname, :new_wdepartment, ' +
    ' :new_spouse, :new_children, :new_sex, :new_birthday, ' +
    ' :new_visitcard, :new_photo, ' +
    ' :new_passportnumber, :new_passportexpdate, :new_passportissdate, :new_passportissuer, ' +
    ' :new_passportisscity, :new_personalnumber, :new_wpositionkey, :new_hplacekey) ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcContact.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCONTACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    ' UPDATE gd_people SET contactkey = :new_id, firstname = :new_firstname, surname = :new_surname, ' +
    ' middlename = :new_middlename, nickname = :new_nickname, rank = :new_rank, haddress = :new_haddress, ' +
    ' hcity = :new_hcity, hregion = :new_hregion, hzip = :new_hzip, hcountry = :new_hcountry, hdistrict = :new_hdistrict, ' +
    ' hphone = :new_hphone, ' +
    ' wcompanykey = :new_wcompanykey, wcompanyname = :new_wcompanyname, ' +
    ' wdepartment = :new_wdepartment, ' +
    ' spouse = :new_spouse, children = :new_children, ' +
    ' sex = :new_sex, birthday = :new_birthday, visitcard = :new_visitcard, ' +
    ' photo = :new_photo, passportnumber = :new_passportnumber, ' +
    ' passportexpdate = :new_passportexpdate, passportissdate = :new_passportissdate,' +
    ' passportissuer = :new_passportissuer, ' +
    ' personalnumber = :new_personalnumber, wpositionkey = :new_wpositionkey, ' +
    ' passportisscity = :new_passportisscity, hplacekey = :new_hplacekey WHERE contactkey = :old_id ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcContact.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    '  JOIN gd_people p ON p.contactkey = z.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcContact.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCONTACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetSelectClause +
    ', ' +
    'p.contactkey, ' +
    'p.firstname, ' +
    'p.surname, ' +
    'p.middlename, ' +
    'p.nickname,  ' +
    'p.rank, ' +
    'p.hplacekey, ' +
    'p.haddress, ' +
    'p.hcity, ' +
    'p.hregion, ' +
    'p.hzip, ' +
    'p.hcountry, ' +
    'p.hdistrict, ' +
    'p.hphone, ' +
    'p.wcompanykey, ' +
    'p.wcompanyname, ' +
    'p.wdepartment, ' +
    'p.passportnumber, ' +
    'p.passportexpdate, ' +
    'p.passportissdate, ' +
    'p.passportissuer, ' +
    'p.passportisscity, ' +
    'p.personalnumber, ' +
    'p.wpositionkey, ' +
    'p.spouse, ' +
    'p.children, ' +
    'p.sex, ' +
    'p.birthday, ' +
    'p.visitcard, ' +
    'p.photo ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcContact.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCCONTACT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',contactkey';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcContact._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  SetTID(FieldByName('contactkey'), FieldByName('id'));
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcContact.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmContact';
end;

class procedure TgdcContact.GetClassImage(const ASizeX, ASizeY: Integer;
  AGraphic: TGraphic);
begin
  if (ASizeX = 16) and (ASizeY = 16) and (AGraphic is Graphics.TBitmap) then
    dmImages.il16x16.GetBitmap(148, Graphics.TBitmap(AGraphic))
  else
    inherited;
end;

class function TgdcContact.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgContact';
end;

procedure TgdcContact.DoBeforePost;
var
  TempS: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCONTACT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCONTACT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCONTACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCONTACT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCONTACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (FieldChanged('surname') or FieldChanged('firstname') or FieldChanged('middlename'))
    and ((FieldByName('nickname').AsString = '') or (not FieldChanged('nickname'))) then
  begin
    Temps := AnsiUpperCase(System.Copy(FieldByName('surname').AsString, 1, 1))
      + System.Copy(FieldByName('surname').AsString, 2, 1024);

    if FieldByName('firstname').AsString > '' then
    begin
      TempS := TempS + ' '
        + AnsiUpperCase(System.Copy(FieldByName('firstname').AsString, 1, 1))
        + '.';

      if FieldByName('middlename').AsString > '' then
      begin
        TempS := TempS + ' '
          + AnsiUpperCase(System.Copy(FieldByName('middlename').AsString, 1, 1))
          + '.';
      end;
    end;

    FieldByName('nickname').AsString := System.Copy(TempS, 1, FieldByName('nickname').Size);
  end;

  if FieldByName('name').AsString = '' then
    FieldByName('name').AsString := FieldByName('nickname').AsString;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCONTACT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCONTACT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

{ TgdcCompany }

procedure TgdcCompany.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO gd_company(contactkey, headcompany, companytype, ' +
  '   fullname, logo, companyaccountkey, directorkey, chiefaccountantkey) ' +
  ' VALUES (:new_id, :new_headcompany, :new_companytype, :new_fullname, ' +
  '   :new_logo, :new_companyaccountkey, :new_directorkey, :new_chiefaccountantkey)', Buff);

  CustomExecQuery('INSERT INTO gd_companycode(companykey, legalnumber, taxid, okulp, okpo, oknh, soato, soou, licence) ' +
    ' VALUES (:new_id, :new_legalnumber, :new_taxid, :new_okulp, :new_okpo, :new_oknh, :new_soato, :new_new_soou, :new_licence) ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCompany.CustomModify(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := Transaction;
    q.SQL.Text := 'SELECT companykey FROM gd_companycode WHERE companykey=' + FieldByName('id').AsString;
    q.ExecQuery;

    CustomExecQuery(' UPDATE gd_company SET contactkey = :new_id, headcompany = :new_headcompany, ' +
    ' companytype = :new_companytype, fullname = :new_fullname, logo = :new_logo, ' +
    ' companyaccountkey = :new_companyaccountkey, ' +
    ' directorkey = :new_directorkey, chiefaccountantkey = :new_chiefaccountantkey, ' +
    ' WHERE contactkey = :old_id', Buff);

    if q.EOF then
      {TODO: ������ �������� ����� ���������� ������� �� ���� �����}
      if Assigned(atDatabase.FindRelationField('GD_COMPANYCODE', 'OKULP')) then
        CustomExecQuery('INSERT INTO gd_companycode(companykey, legalnumber, taxid, okulp, okpo, oknh, soato, soou, licence) ' +
        ' VALUES (:new_id, :new_legalnumber, :new_taxid, :new_okulp, :new_okpo, :new_oknh, :new_soato, :new_new_soou, :new_licence)', Buff)
      else
        CustomExecQuery('INSERT INTO gd_companycode(companykey, legalnumber, taxid, okpo, oknh, soato, soou, licence) ' +
        ' VALUES (:new_id, :new_legalnumber, :new_taxid, :new_okpo, :new_oknh, :new_soato, :new_new_soou, :new_licence)', Buff)
    else
      {TODO: ������ �������� ����� ���������� ������� �� ���� �����}
      if Assigned(atDatabase.FindRelationField('GD_COMPANYCODE', 'OKULP')) then
        CustomExecQuery(' UPDATE gd_companycode SET legalnumber = :new_legalnumber, ' +
        ' taxid = :new_taxid, okulp = :new_okulp, okpo = :new_okpo, oknh = :new_oknh, soato = :new_soato, soou = :new_soou, licence = :new_licence ' +
        ' WHERE companykey = :old_id', Buff)
      else
        CustomExecQuery(' UPDATE gd_companycode SET legalnumber = :new_legalnumber, ' +
        ' taxid = :new_taxid, okpo = :new_okpo, oknh = :new_oknh, soato = :new_soato, soou = :new_soou, licence = :new_licence ' +
        ' WHERE companykey = :old_id', Buff);
  finally
    q.Free;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCompany.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '  JOIN gd_company cm ON cm.contactkey = z.id ' +
    '  LEFT JOIN gd_companycode cc ON cc.companykey = cm.contactkey ';
  if HasSubSet('WithAccount') then
    Result := Result +
      '  LEFT JOIN gd_companyaccount cacc ON cacc.id = cm.companyaccountkey ' +
      '  LEFT JOIN gd_contact cbank ON cbank.id = cacc.bankkey ' +
      '  LEFT JOIN gd_bank bbank ON bbank.bankkey = cacc.bankkey ';

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'CACC';
  Ignore.IgnoryType := itFull;

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'CBANK';
  Ignore.IgnoryType := itFull;

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'BBANK';
  Ignore.IgnoryType := itFull;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCompany.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCOMPANY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  {TODO: ������ �������� ����� ���������� ������� �� ���� �����}
  if Assigned(atDatabase.FindRelationField('GD_COMPANYCODE', 'OKULP')) then
    Result := inherited GetSelectClause +
      ', cc.companykey, cm.contactkey, cm.headcompany, cm.companytype, cm.fullname, cm.logo, cm.companyaccountkey, cm.directorkey, cm.chiefaccountantkey,' +
      ' cc.legalnumber, cc.taxid, cc.okulp, cc.okpo, cc.oknh, cc.soato, cc.soou, cc.licence '
  else
    Result := inherited GetSelectClause +
      ', cc.companykey, cm.contactkey, cm.headcompany, cm.companytype, cm.fullname, cm.logo, cm.companyaccountkey, cm.directorkey, cm.chiefaccountantkey,' +
      ' cc.legalnumber, cc.taxid, cc.okpo, cc.oknh, cc.soato, cc.soou, cc.licence ';
  if HasSubSet('WithAccount') then
    Result := Result + ', cacc.account, cbank.name AS bankname, bbank.bankcode AS bankcode ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCompany.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCCOMPANY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',contactkey,companykey';
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCompany._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  SetTID(FieldByName('contactkey'), FieldByName('id'));
  SetTID(FieldByName('companykey'), FieldByName('id'));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{TgdcOurCompany -----------------------------------------}

class procedure TgdcOurCompany.SaveOurCompany(const ACompanyKey: TID);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    q.Transaction := Tr;
    Tr.StartTransaction;
    q.SQL.Text :=
      'UPDATE OR INSERT INTO gd_usercompany (userkey, companykey) ' +
      'VALUES (:uk, :ck) MATCHING (userkey)';
    SetTID(q.ParamByName('uk'), IBLogin.UserKey);
    SetTID(q.ParamByName('ck'), ACompanyKey);
    q.ExecQuery;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

function TgdcOurCompany.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCOURCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    ' FROM gd_ourcompany uc LEFT JOIN gd_contact z ON uc.companykey=z.id ' +
    ' LEFT JOIN gd_company cm ON cm.contactkey=z.id ' +
    ' LEFT JOIN gd_companycode cc ON cc.companykey=cm.contactkey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcOurCompany.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCOURCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if sLoadFromStream in BaseState then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text := 'SELECT contactkey FROM gd_company WHERE contactkey = :ID';
      SetTID(q.ParamByName('id'), ID);
      q.ExecQuery;

      if q.EOF then
        inherited;
    finally
      q.Free;
    end;
  end
  else if FAddCompany then
    inherited;

  CustomExecQuery('INSERT INTO gd_ourcompany(COMPANYKEY, AVIEW, ACHAG, AFULL) ' +
   ' VALUES (:NEW_ID, :NEW_AVIEW, :NEW_ACHAG, :NEW_AFULL)', Buff);

  if sLoadFromStream in BaseState then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := Transaction;
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_usercompany(userkey, companykey) ' +
        '  VALUES (RDB$GET_CONTEXT(''USER_SESSION'', ''GD_USERKEY''), :ID) ' +
        '  MATCHING (userkey)';
      SetTID(q.ParamByName('id'), ID);
      q.ExecQuery;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcOurCompany.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCOURCOMPANY', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if GetTID(FieldByName(GetKeyField(Subset))) = IbLogin.Companykey then
    raise Exception.Create('������ ������� ������� ������� �����������!');

  try
    CustomExecQuery('DELETE FROM gd_ourcompany WHERE companykey = :old_id ', Buff);
  except
    on E: Exception do
    begin
      if IBLogin.IsUserAdmin then
        S := #13#10#13#10'��������� �� ������:'#13#10 + E.Message
      else
        S := '';

      MessageBox(ParentHandle,
        PChar('������ ������� �����������. �������� �� ��� ������� ���������.' + S),
        '��������',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);

      Abort;
    end;
  end;

  if not FOnlyOurCompany then
    inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

constructor TgdcOurCompany.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FAddCompany := True;
  FOnlyOurCompany := False;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

procedure TgdcOurCompany._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCOURCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  SetTID(FieldByName('CompanyKey'), FieldByName('ID'));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcCompany.IsReverseOrder(const AFieldName: String): Boolean;
begin
  Result := (AnsiCompareText(AFieldName, 'COMPANYACCOUNTKEY') = 0) or
    (AnsiCompareText(AFieldName, 'CHIEFACCOUNTANTKEY') = 0 ) or
    (AnsiCompareText(AFieldName, 'DIRECTORKEY') = 0 );
end;

procedure TgdcCompany.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  FD: TFieldDef;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCOMPANY', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  FD := FieldDefs.Find('contactkey');
  if FD <> nil then
    FD.Attributes := FD.Attributes + [DB.faReadOnly];
  FD := FieldDefs.Find('companykey');
  if FD <> nil then
    FD.Attributes := FD.Attributes + [DB.faReadOnly];

  if HasSubSet('WithAccount') then
  begin
    FieldDefs.Find('account').Required := False;
    FieldDefs.Find('bankname').Required := False;
    FieldDefs.Find('bankcode').Required := False;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcCompany.GetCurrRecordClass: TgdcFullClass;
var
  q: TIBSQL;
begin
  Result := inherited GetCurrRecordClass;

  if (Result.gdClass = TgdcCompany) and (Result.SubType = '') and
    (not IsEmpty) and Assigned(IBLogin) then
  begin
    if ID = IBLogin.CompanyKey then
      Result.gdClass := TgdcOurCompany
    else begin
      q := TIBSQL.Create(nil);
      try
        q.Database := Database;
        q.Transaction := ReadTransaction;
        q.SQL.Text := 'SELECT * FROM gd_ourcompany WHERE companykey=:id';
        SetTID(q.Params[0], ID);
        q.ExecQuery;
        if not q.EOF then
          Result.gdClass := TgdcOurCompany;
      finally
        q.Free;
      end;
    end;
  end;
end;

procedure TgdcCompany.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCOMPANY', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if (State in [dsInsert, dsEdit]) then
    begin
      if Pos(' ', FieldByName('name').AsString) > 0 then
      begin
        FieldByName('name').AsString :=
          Trim(FieldByName('name').AsString);
      end;

      if (Trim(FieldByName('fullname').AsString) = '') then
      begin
        FieldByName('fullname').AsString :=
          FieldByName('name').AsString;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

constructor TgdcCompany.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify];
end;

class function TgdcCompany.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  if (Self = TgdcCompany) and (AnsiCompareText(ATableName, 'gd_contact') = 0) then
    Result := 'z.contacttype in (3, 5)' // ���� -- ��� ���� ��������!
  else
    Result := inherited GetRestrictCondition(ATableName, ASubType);
end;

procedure TgdcCompany.GetWhereClauseConditions(S: TStrings);
var
  Str: String;
  I: Integer;
begin
  //����������� ������ ByID ��� ��������
  if HasSubSet('ByID') then
    S.Add('cm.contactkey = :id')
  else
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
    S.Add(Format('cm.contactkey IN (%s)', [Str]));
  end;

end;

function TgdcCompany.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT c.id FROM gd_contact c JOIN gd_company co ON co.contactkey = c.id ' +
      '  LEFT JOIN gd_companycode cp ON cp.companykey = c.id ' +
      'WHERE UPPER(c.name)=UPPER(:name) AND cp.taxid IS NOT DISTINCT FROM :taxid '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else begin
    if FieldByName('taxid').IsNull then
      Result := Format(
        'SELECT c.id FROM gd_contact c JOIN gd_company co ON co.contactkey = c.id ' +
        'WHERE UPPER(c.name)=UPPER(''%s'') ',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll])])
    else
      Result := Format(
        'SELECT c.id FROM gd_contact c JOIN gd_companycode cp ON cp.companykey = c.id ' +
        'WHERE UPPER(c.name)=UPPER(''%s'') AND cp.taxid = ''%s'' ',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
         StringReplace(FieldByName('taxid').AsString, '''', '''''', [rfReplaceAll])]);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcCompany.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCompany';
end;

procedure TgdcCompany.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCOMPANY', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(IBLogin) then
    IBLogin.ClearHoldingListCache;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCompany.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCOMPANY', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCOMPANY', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCOMPANY',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(IBLogin) then
    IBLogin.ClearHoldingListCache;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCOMPANY', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCOMPANY', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcCompany.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'WithAccount;';
end;

class function TgdcCompany.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCompany';
end;

{ TgdcBank }

procedure TgdcBank.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {M}  F: TatRelationField;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANK', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  F := atDatabase.FindRelationField('GD_BANK', 'BANKBRANCH');
  if not Assigned(F) then
    CustomExecQuery('INSERT INTO gd_bank (bankkey, bankcode, bankmfo, SWIFT) VALUES ' +
    ' (:new_id, :new_bankcode, :new_bankmfo, :new_SWIFT)', Buff)
  else
    try
      CustomExecQuery('INSERT INTO gd_bank (bankkey, bankcode, bankmfo, SWIFT, bankbranch) VALUES ' +
      ' (:new_id, :new_bankcode, :new_bankmfo, :new_SWIFT, :new_bankbranch)', Buff);
    except
      on E: EIBError do
      begin
        if E.IBErrorCode = isc_no_dup then
        begin
          MessageBox(ParentHandle,
            '���� � ����� ����� � ������� ��������� ����������.'#13#10 +
            '��������, ���������� ������� ����� ��������� (���).',
            '��������',
            MB_OK or MB_ICONEXCLAMATION);
          abort;
        end else
          raise;
      end;
    end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBank.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {M}  F: TatRelationField;  
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  F := atDatabase.FindRelationField('GD_BANK', 'BANKBRANCH');
  if not Assigned(F) then
    CustomExecQuery('UPDATE gd_bank SET bankkey = :new_id, bankcode = :new_bankcode, bankmfo = :new_bankmfo, SWIFT = :new_SWIFT ' +
     ' WHERE bankkey = :old_id ', Buff)
  else
    try
      CustomExecQuery('UPDATE gd_bank SET bankkey = :new_id, bankcode = :new_bankcode, bankmfo = :new_bankmfo, bankbranch = :bankbranch, SWIFT = :new_SWIFT ' +
       ' WHERE bankkey = :old_id ', Buff);
    except
      on E: EIBError do
      begin
        if E.IBErrorCode = isc_no_dup then
        begin
          MessageBox(ParentHandle,
            '���� � ����� ����� � ������� ��������� ����������.'#13#10 +
            '��������, ���������� ������� ����� ��������� (���).',
            '��������',
            MB_OK or MB_ICONEXCLAMATION);
          abort;
        end else
          raise;
      end;
    end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcBank.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANK', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ' +
    '  gd_bank b JOIN gd_contact z ON b.bankkey = z.id ' +
    '  JOIN gd_company cm ON cm.contactkey = z.id ' +
    '  LEFT JOIN gd_companycode cc ON cc.companykey = cm.contactkey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBank.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {M}  F: TatRelationField; 
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANK', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetSelectClause +
    ', b.bankkey, b.bankcode, b.bankmfo, b.SWIFT ';

  F := atDatabase.FindRelationField('GD_BANK', 'BANKBRANCH');
  if Assigned(F) then
    Result := Result + ', b.bankbranch';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBank.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',bankkey';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBank._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  SetTID(FieldByName('bankkey'), FieldByName('id'));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcOurCompany.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := ' EXISTS(SELECT * FROM gd_ourcompany our WHERE our.companykey = z.id) ';
end;

function TgdcBank.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCBANK', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANK', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANK',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANK' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT b.bankkey FROM gd_bank b WHERE b.bankcode = :bankcode '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format(
      'SELECT b.bankkey FROM gd_bank b WHERE b.bankcode = ''%s'' ',
      [
        StringReplace(FieldByName('bankcode').AsString, '''', '''''', [rfReplaceAll])
      ]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANK', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANK', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcBank.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmBank';
end;

class function TgdcOurCompany.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmOurCompany';
end;

class function TgdcOurCompany.ContactType: Integer;
begin
  Result := 3;
end;

class procedure TgdcBank.GetClassImage(const ASizeX, ASizeY: Integer;
  AGraphic: TGraphic);
begin
  if (ASizeX = 16) and (ASizeY = 16) and (AGraphic is Graphics.TBitmap) then
    dmImages.il16x16.GetBitmap(165, Graphics.TBitmap(AGraphic))
  else
    inherited;
end;

procedure TgdcEmployee.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEMPLOYEE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEMPLOYEE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEMPLOYEE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName('parent').Required := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEMPLOYEE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEMPLOYEE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcEmployee.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Obj: TgdcDepartment;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEMPLOYEE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEMPLOYEE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEMPLOYEE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FieldByName('parent').IsNull and FieldByName('wcompanykey').IsNull then
  begin
    if not (sLoadFromStream in BaseState) then
      MessageBox(ParentHandle,
        '���� "������� �����������" ��� "�������������" ������ ���� ���������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Abort;
  end;

  {���� ������� �������������, �� �� ������� ��������, ��������� ��������}
  SetWCompanyKeyByDepartment;

  if FieldByName('parent').IsNull and (not FieldByName('wcompanykey').IsNull) then
  begin
    Obj := TgdcDepartment.Create(nil);
    try
      Obj.SubSet := 'ByParent';
      Obj.Transaction := Transaction;
      SetTID(Obj.ParamByName('Parent'), FieldByName('wcompanykey'));
      Obj.Open;

      if Obj.EOF then
      begin
        Obj.Insert;
        SetTID(Obj.FieldByName('parent'), FieldByName('wcompanykey'));
        Obj.FieldByName('name').AsString := '����';
        Obj.Post;
      end;

      SetTID(FieldByName('parent'), Obj.ID);
    finally
      Obj.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEMPLOYEE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEMPLOYEE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcEmployee.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCEMPLOYEE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEMPLOYEE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEMPLOYEE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEMPLOYEE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN gd_employee empl ON empl.contactkey = z.id ' +
    ' JOIN gd_contact cp ON cp.id = z.parent and cp.contacttype in(3,4,5) ' +
    ' LEFT JOIN wg_position wpos ON p.wpositionkey = wpos.id ';
  SQLSetup.Ignores.AddAliasName('cp');
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEMPLOYEE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEMPLOYEE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcEmployee.GetSelectClause: String;
begin
  Result := inherited GetSelectClause + ', wpos.name as newrank ';
end;

function TgdcEmployee.GetOrderClause: String;
begin
  Result := inherited GetOrderClause;

  if Result = '' then
    Result := 'ORDER BY Z.NAME'
  else
    Result := Result + ', Z.NAME';
end;

class function TgdcEmployee.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDepartment';
end;

procedure TgdcEmployee.SetWCompanyKeyByDepartment;
var
  ibsql: TIBSQL;
begin
  Assert(State in dsEditModes);
  if (GetTID(FieldByName('parent')) > 0) and FieldByName('wcompanykey').IsNull then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      if Transaction.InTransaction then
        ibsql.Transaction := Transaction
      else
        ibsql.Transaction := ReadTransaction;

      ibsql.SQL.Text :=
        ' SELECT FIRST 1 cc.id, cc.name, cc.lb ' +
        ' FROM ' +
        '   gd_contact c ' +
        ' LEFT JOIN gd_contact cc ON cc.lb <= c.lb AND cc.rb >= c.rb ' +
        ' WHERE ' +
        ' c.id = :id ' +
        ' AND cc.contacttype in (3,5) ' +
        ' ORDER BY cc.lb DESC ';

      SetTID(ibsql.ParamByName('id'), FieldByName('parent'));
      ibsql.ExecQuery;

      if not ibsql.EOF then
        SetTID(FieldByName('wcompanykey'), ibsql.FieldByName('id'));
    finally
      ibsql.Free;
    end;
  end;

end;

class function TgdcOurCompany.Class_TestUserRights(
  const SS: TgdcTableInfos; const ST: String): Boolean;
begin
  Result := inherited Class_TestUserRights(SS, ST);
  if Result and ((SS * [tiAFull, tiAChag]) <> []) then
  begin
    Result := Assigned(GlobalStorage)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_CHANGE_WO_ID, GD_POL_CHANGE_WO_MASK, False) and IBLogin.InGroup) <> 0);
  end;
end;

function TgdcOurCompany.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCOURCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    Result := '';
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT c.id FROM gd_contact c ' +
      ' LEFT JOIN gd_companycode cp ON cp.companykey = c.id ' +
      ' JOIN gd_ourcompany oc ON oc.companykey = c.id ' +
      ' WHERE UPPER(c.name)=UPPER(:name) AND cp.taxid IS NOT DISTINCT FROM taxid '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT c.id FROM gd_contact c ' +
      ' LEFT JOIN gd_companycode cp ON cp.companykey = c.id ' +
      ' JOIN gd_ourcompany oc ON oc.companykey = c.id ' +
      ' WHERE UPPER(c.name)=UPPER(''%s'') AND COALESCE(cp.taxid, '''') = ''%s'' ',
      [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
       StringReplace(FieldByName('taxid').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
end;

function TgdcOurCompany.DoAfterInitSQL(const AnSQLText: String): String;
var
  S: String;
begin
  Result := inherited DoAfterInitSQL(AnSQLText);
  if Result = '' then
    Result := AnSQLText;
  Result := StringReplace(Result, 'Z.AVIEW', 'UC.AVIEW', [rfIgnoreCase]);
  Result := StringReplace(Result, 'Z.ACHAG', 'UC.ACHAG', [rfIgnoreCase]);
  Result := StringReplace(Result, 'Z.AFULL', 'UC.AFULL', [rfIgnoreCase]);

  S := RefreshSQL.Text;
  S := StringReplace(S, 'Z.AVIEW', 'UC.AVIEW', [rfIgnoreCase]);
  S := StringReplace(S, 'Z.ACHAG', 'UC.ACHAG', [rfIgnoreCase]);
  S := StringReplace(S, 'Z.AFULL', 'UC.AFULL', [rfIgnoreCase]);
  RefreshSQL.Text := S;

  S := InsertSQL.Text;
  S := StringReplace(S, 'AVIEW,', '', [rfIgnoreCase]);
  S := StringReplace(S, 'ACHAG,', '', [rfIgnoreCase]);
  S := StringReplace(S, 'AFULL,', '', [rfIgnoreCase]);
  S := StringReplace(S, ':NEW_AVIEW,', '', [rfIgnoreCase]);
  S := StringReplace(S, ':NEW_ACHAG,', '', [rfIgnoreCase]);
  S := StringReplace(S, ':NEW_AFULL,', '', [rfIgnoreCase]);
  InsertSQL.Text := S;

  S := ModifySQL.Text;
  S := StringReplace(S, ' = ', '=', [rfReplaceAll]);
  S := StringReplace(S, ' = ', '=', [rfReplaceAll]);
  S := StringReplace(S, 'AVIEW=:NEW_AVIEW,', '', [rfIgnoreCase]);
  S := StringReplace(S, 'ACHAG=:NEW_ACHAG,', '', [rfIgnoreCase]);
  S := StringReplace(S, 'AFULL=:NEW_AFULL,', '', [rfIgnoreCase]);
  ModifySQL.Text := S;
end;

procedure TgdcOurCompany.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMMODIFY('TGDCOURCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCOURCOMPANY', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCOURCOMPANY',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CustomExecQuery('UPDATE gd_ourcompany SET AVIEW = :NEW_AVIEW, ACHAG = :NEW_ACHAG, AFULL = :NEW_AFULL ' +
    'WHERE COMPANYKEY = :NEW_ID', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCOURCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCOURCOMPANY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

class function TgdcOurCompany.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgOurCompany';
end;

class function TgdcEmployee.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgEmployee';
end;

class function TgdcBank.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgBank';
end;

procedure TgdcEmployee.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCEMPLOYEE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEMPLOYEE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEMPLOYEE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  CustomExecQuery('INSERT INTO gd_employee(contactkey) VALUES (:new_id)', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEMPLOYEE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEMPLOYEE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcEmployee.CustomModify(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCEMPLOYEE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEMPLOYEE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEMPLOYEE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  CustomExecQuery('UPDATE gd_employee SET contactkey = :new_id WHERE contactkey = :old_id', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEMPLOYEE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEMPLOYEE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcBaseContact, '�������� �����').GroupID := cst_ContactsGroupID;
  RegisterGdcClass(TgdcFolder,      '�����');
  RegisterGdcClass(TgdcGroup,       '������');
  with RegisterGdcClass(TgdcContact,     '���������� ����') as TgdBaseEntry do
    DistinctRelation := 'GD_PEOPLE';
  with RegisterGdcClass(TgdcEmployee,    '��������� �����������') as TgdBaseEntry do
    DistinctRelation := 'GD_EMPLOYEE';
  RegisterGdcClass(TgdcDepartment,  '�������������');
  with RegisterGdcClass(TgdcCompany, '�����������') as TgdBaseEntry do
    DistinctRelation := 'GD_COMPANY';
  with RegisterGdcClass(TgdcOurCompany, '������� �����������') as TgdBaseEntry do
  begin
    Hidden := True;
    DistinctRelation := 'GD_OURCOMPANY';
  end;
  with RegisterGdcClass(TgdcBank, '����') as TgdBaseEntry do
    DistinctRelation := 'GD_BANK';
  RegisterGdcClass(TgdcAccount,     '��������� ����');

finalization
  UnregisterGdcClass(TgdcBaseContact);
  UnregisterGdcClass(TgdcFolder);
  UnregisterGdcClass(TgdcGroup);
  UnregisterGdcClass(TgdcContact);
  UnregisterGdcClass(TgdcEmployee);
  UnregisterGdcClass(TgdcDepartment);
  UnregisterGdcClass(TgdcCompany);
  UnregisterGdcClass(TgdcOurCompany);
  UnregisterGdcClass(TgdcBank);
  UnregisterGdcClass(TgdcAccount);
end.


