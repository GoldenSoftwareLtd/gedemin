// ShlTanya, 10.02.2019

{
  Данный модуль содержит все компоненты для работы с проектом Департамент

  Документы:
  Tgdc_dpInventory - акт описи
  Tgdc_dpTransfer - Акт передачи иммущества
  Tgdc_dpRevaluation - Акт переоценки
  Tgdc_dpWithDrawal - Акт конфискации валюты

  Типы клиентов
  Tgdc_dpSale - Реализующие предприятия
  Tgdc_dpMain - Главные уполномоченные органы. Каждый уполномоченный орган привязан к
                главному уполном. органу
  Tgdc_dpAuthority - Уполномоченные органы
  Tgdc_dpFinancial - финансовые органы. Каждый финансовый орган привязан к уполномоченному

  Tgdc_dpDecree - Указы
  Tgdc_dpAssetDest - Вид используемого иммущества
  TgdcBankStatementLineD - Позиция банковской выписки
  Tgdc_dpBSLine - Выборка актов передач и актов описей

  Revisions history

    1.00    29.10.00    sai        Initial version.

}

unit gdcDepartament;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, gdcClasses,
  SysUtils, gdcContacts, gdcStatement, gdcBaseBank, Controls, DB, dbgrids,
  gd_KeyAssoc, gdcBaseInterface;

type

  Tgdc_dpInventory = class(TgdcBaseBank)
  protected
    function GetSelectClause: String; override;
    function GetRefreshSQLText: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure ValidateField(Sender: TField); override;

    function GetDialogDefaultsFields: String; override;

  public
    function DocumentTypeKey: TID; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetSubSetList: String; override;
  end;

  Tgdc_dpTransfer = class(TgdcDocument)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure ValidateField(Sender: TField); override;

    function GetDialogDefaultsFields: String; override;

    function GetReductionCondition: String; override;
    function GetReductionTable: String; override;

  public
    function DocumentTypeKey: TID; override;
    function GetCompany(const Account: String): TID;

    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetSubSetList: String; override;
  end;

  Tgdc_dpRevaluation = class(TgdcDocument)
  private
    FTransferKey: TID;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function GetReductionCondition: String; override;
    function GetReductionTable: String; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function DocumentTypeKey: TID; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetSubSetList: String; override;

    property TransferKey: TID read FTransferKey write FTransferKey;
  end;

  Tgdc_dpSale = class(TgdcCompany)
  protected
    function CreateDialogForm: TCreateableForm; override;
  public
    class function ContactType: Integer; override;
  end;

  Tgdc_dpAuthority = class(TgdcCompany)
  protected
    function CreateDialogForm: TCreateableForm; override;
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure ValidateField(Sender: TField); override;
  public
    class function ContactType: Integer; override;
  end;

  Tgdc_dpFinancial = class(TgdcCompany)
  protected
    function CreateDialogForm: TCreateableForm; override;
  public
    class function ContactType: Integer; override;
  end;

  Tgdc_dpComittee = class(TgdcCompany)
  protected
    function CreateDialogForm: TCreateableForm; override;
  public
    class function ContactType: Integer; override;
  end;

  Tgdc_dpMain = class(TgdcCompany)
  protected
    function CreateDialogForm: TCreateableForm; override;
  public
    class function ContactType: Integer; override;
  end;

  Tgdc_dpDecree = class(TgdcBase)
  protected
    function GetSelectClause: String; override;

    function CreateDialogForm: TCreateableForm; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  Tgdc_dpWithDrawal = class(TgdcDocument)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    function DocumentTypeKey: TID; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
  end;

  Tgdc_dpAssetDest = class(TgdcBase)
  protected
    function GetSelectClause: String; override;

    function CreateDialogForm: TCreateableForm; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

//Позиция банковской выписки для Департамента
  TgdcBankStatementLineD = class(TgdcBaseStatementLine)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    //function GetRefreshSQLText: String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
  public
    procedure DivideLine;
  end;

  Tgdc_dpBSLine = class(TgdcDocument)
  private
    FBSLineKey: TID;
    FCompanyKey: TID;
    FSumNCU: Currency;

    procedure SetBSLineKey(Value: TID);
    procedure SetCompanyKey(const Value: TID);

  protected
    function GetSelectClause: String; override;
    function GetRefreshSQLText: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

    procedure _DoOnNewRecord; override;
    procedure DoAfterOpen; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    procedure Assign(Source: TPersistent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    property BSLineKey: TID read FBSLineKey write SetBSLineKey;
    property CompanyKey: TID read FCompanyKey write SetCompanyKey;
    property SumNCU: Currency read FSumNCU write FSumNCU;

    procedure ChooseCompany;

    function DocumentTypeKey: TID; override;

    procedure ChooseTransfer;
    //Функция для удаления выбранного элемента из группы
    procedure DeleteTransfer(BL: TBookmarkList);

  end;

  procedure Register;

implementation

uses
  IBSQL,
  gdc_frmG_unit,
  gdc_dp_dlgChooseCompany_unit,
  dmDataBase_unit,
  gd_security,
  windows,

  // Диалоговые окна
  gdc_dp_dlgSale_unit,
  gdc_dp_dlgAssetDest_unit,
  gdc_dp_dlgWithDrawal_unit,
  gdc_dp_dlgMain_unit,
  gdc_dp_dlgAuthority_unit,
  gdc_dp_dlgFinancial_unit,
  gdc_dp_dlgDecree_unit,
  gdc_dp_dlgInventory_unit,
  gdc_dp_dlgTransfer_unit,
  gdc_dp_dlgRevaluation_unit,
  gdc_dlgBankStateDepartmentLine_unit,
  gdc_dlgDivideLine_unit,
  gdc_dp_dlgComittee_unit,

  // Формы просмотра

  gdc_dp_frmDecree_unit,
  gdc_dp_frmInventory_unit,
  gdc_dp_frmAssetDest_unit,
  gdc_ab_dp_frmmain_unit,
  gdc_dp_frmWithDrawal_unit,
  gdc_dp_frmBSLine_unit,
  gdc_frmbankStateDepartment_unit, gd_ClassList;

const
  DP_DOC_INVENTORY                         = 849010; // акт описи и оценки
  DP_DOC_TRANSFER                          = 849020; // акт передачи
  DP_DOC_REVALUATION                       = 849030; // акт переоценки
  DP_DOC_WITHDRAWAL                        = 849040; // акт изъятия валюты
  cst_Sale                                 = 100;    //
  cst_Authority                            = 101;    //
  cst_Financial                            = 102;    //
  cst_Main                                 = 103;    //
  cst_Comittee                             = 104;    // Комиссия

  ss_ByCompany                             = 'ByCompany';
  ss_ByLine                                = 'ByLine';

procedure Register;
begin
  RegisterComponents('gdcDepartment', [
    Tgdc_dpInventory,
    Tgdc_dpTransfer,
    Tgdc_dpRevaluation,
    Tgdc_dpSale,
    Tgdc_dpMain,
    Tgdc_dpAuthority,
    Tgdc_dpFinancial,
    Tgdc_dpDecree,
    Tgdc_dpWithDrawal,
    Tgdc_dpAssetDest,
    TgdcBankStatementLineD,
    Tgdc_dpBSLine,
    Tgdc_dpComittee]);
end;

procedure Tgdc_dpInventory._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPINVENTORY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('incomedate').AsDateTime := SysUtils.Date;
  SetTID(FieldByName('documentkey'), FieldByName('id'));
  FieldByName('authorityname').Required := False;
  FieldByName('decreename').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpInventory.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPINVENTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    ' , i.documentkey, i.incomedate, i.decreekey, i.contactkey, ' +
    ' i.authoritykey, i.accountkey, de.name as decreename, a.name as authorityname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpInventory.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPINVENTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'FROM dp_inventory i LEFT JOIN gd_document z ON i.documentkey = z.id ' +
    ' LEFT JOIN dp_decree de ON i.decreekey = de.id ' +
    ' LEFT JOIN gd_contact a ON i.authoritykey = a.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpInventory.GetRefreshSQLText: String;
begin
  Result := GetSelectClause +
    ' FROM gd_document z LEFT JOIN dp_inventory i ON i.documentkey = z.id ' +
    ' LEFT JOIN dp_decree de ON i.decreekey = de.id ' +
    ' LEFT JOIN gd_contact a ON i.authoritykey = a.id ' +
    ' LEFT JOIN gd_contact c ON z.editorkey = c.id ' +
    ' WHERE z.id = :id ';
end;

procedure Tgdc_dpInventory.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPINVENTORY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO dp_inventory '+
    ' (documentkey, incomedate, decreekey, contactkey, authoritykey, accountkey) ' +
    ' VALUES (:new_id, :new_incomedate, :new_decreekey, :new_contactkey, :new_authoritykey, :new_accountkey) ',
    Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpInventory.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPINVENTORY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE dp_inventory SET documentkey = :new_documentkey, ' +
    ' incomedate = :new_incomedate,  decreekey = :new_decreekey,  contactkey = :new_contactkey, ' +
    ' authoritykey = :new_authoritykey, accountkey = :new_accountkey ' +
    ' WHERE documentkey = :old_id ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpInventory.GetWhereClauseConditions(S: TStrings);
var
  Str: String;
  I: Integer;
begin
  if HasSubSet('ByID') then
    S.Add('i.documentkey = :id')
  else if HasSubSet('OnlySelected') then
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
    S.Add(Format('i.documentkey IN (%s)', [Str]));
  end
  else
  begin
    inherited;
  end;
  if HasSubSet('ByAccount') then
    S.Add(' i.accountkey = :accountkey' );

  if HasSubSet('NotDisabled') then
    S.Add(' ((z.disabled = 0) or (z.disabled IS NULL))')
  else if HasSubSet('OnlyDisabled') then
    S.Add('(z.disabled = 1)');

end;

function Tgdc_dpInventory.DocumentTypeKey: TID;
begin
  Result := DP_DOC_INVENTORY;
end;

function Tgdc_dpInventory.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPINVENTORY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgInventory.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpInventory.ValidateField(Sender: TField);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_VALIDATEFIELD('TGDC_DPINVENTORY', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYVALIDATEFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYVALIDATEFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
  {M}          'VALIDATEFIELD', KEYVALIDATEFIELD, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with Sender do
  begin
    if (AnsiCompareText(FieldName, 'accountkey') = 0) and (IsNull) then
      raise Exception.Create('Выберите расчетный счет!');

    if (AnsiCompareText(FieldName, 'decreekey') = 0) and (IsNull) then
      raise Exception.Create('Выберите указ(декрет)!');
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'VALIDATEFIELD', KEYVALIDATEFIELD);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpInventory.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey=' + TID2S(DP_DOC_INVENTORY);
end;

{Tgdc_dpTransfer}

function Tgdc_dpTransfer.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPTRANSFER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    ' , t.documentkey, t.assetdestkey, t.companykey as tcompanykey, t.inventorykey, ' +
    ' t.sumncustart, c.name as companyname, a.name as assetdestname, ' +
    ' (SELECT SUM(ld.sumncu) ' +
    ' FROM bn_bslinedocument ld WHERE ld.documentkey = z.id) as paysum ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpTransfer.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPTRANSFER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN dp_transfer t ON (z.id = t.documentkey ) ' +
    ' LEFT JOIN gd_contact c ON (t.companykey = c.id) ' +
    ' LEFT JOIN dp_assetdest a ON (t.assetdestkey = a.id) ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpTransfer.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPTRANSFER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(' INSERT INTO dp_transfer(documentkey, assetdestkey, companykey, inventorykey, sumncustart) ' +
    ' VALUES (:new_id, :new_assetdestkey, :new_tcompanykey, :new_inventorykey, :new_sumncustart) ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpTransfer.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPTRANSFER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    ' UPDATE dp_transfer SET assetdestkey = :new_assetdestkey, ' +
    ' companykey = :new_tcompanykey, inventorykey = :new_inventorykey, sumncustart = :new_sumncustart ' +
    ' WHERE documentkey = :old_id ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpTransfer.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPTRANSFER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgTransfer.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpTransfer.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPTRANSFER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    FieldByName('sumncustart').AsCurrency :=
      FieldByName('sumncu').AsCurrency;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpTransfer._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPTRANSFER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  SetTID(FieldByName('documentkey'), FieldByName('id'));
  FieldByName('paysum').Required := False;
  FieldByName('companyname').Required := False;
  FieldByName('assetdestname').Required := False;
  SetTID(FieldByName('inventorykey'), (MasterSource.DataSet as TgdcBase).ID);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpTransfer.GetCompany(const Account: String): TID;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  q := CreateReadIBSQL(DidActivate);
  try
    q.SQL.Text := ' SELECT companykey FROM gd_companyaccount WHERE account = :account ';
    q.ParamByName('account').AsString := Account;
    q.ExecQuery;

    if q.RecordCount = 0 then
      Result := -1
    else
      Result := GetTID(q.FieldByName('companykey'));
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
  end;
end;

function Tgdc_dpTransfer.DocumentTypeKey: TID;
begin
  Result := DP_DOC_TRANSFER;
end;

class function Tgdc_dpTransfer.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey=' + TID2S(DP_DOC_TRANSFER);
end;

procedure Tgdc_dpTransfer.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByID') then
    S.Add('t.documentkey = :id');

  if HasSubSet('ByInventory') then
    S.Add('t.inventorykey = :inventorykey');
end;

procedure Tgdc_dpTransfer.ValidateField(Sender: TField);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_VALIDATEFIELD('TGDC_DPTRANSFER', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYVALIDATEFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYVALIDATEFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
  {M}          'VALIDATEFIELD', KEYVALIDATEFIELD, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with Sender do
  if (AnsiCompareText(FieldName, 'sumncu') = 0) and (IsNull or (AsInteger = 0)) then
    raise Exception.Create('Неправильно указана сумма акта');
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'VALIDATEFIELD', KEYVALIDATEFIELD);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpTransfer.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDC_DPTRANSFER', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPTRANSFER', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPTRANSFER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPTRANSFER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPTRANSFER' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'assetdestkey;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPTRANSFER', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPTRANSFER', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpTransfer.GetReductionCondition: String;
begin
  if IsEmpty then
    inherited GetReductionCondition
  else
    Result := ' t.inventorykey = ' + FieldByName('inventorykey').AsString;
end;

function Tgdc_dpTransfer.GetReductionTable: String;
begin
  Result := ' gd_document JOIN dp_transfer t ON id = t.documentkey ';
end;

class function Tgdc_dpTransfer.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByInventory;';
end;

{Tgdc_dpRevaluation}

function Tgdc_dpRevaluation.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPREVALUATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
   ' , r.documentkey, r.transferkey, r.sumncuadd, r.sumncudel, ' +
   ' rdoc.number as transfernumber, rdoc.documentdate as transferdate, ' +
   ' t.companykey as tcompanykey,  c.name as companyname, t.inventorykey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpRevaluation.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPREVALUATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN  dp_revaluation r ON (z.id = r.documentkey) ' +
    ' JOIN  dp_transfer t ON (r.transferkey = t.documentkey) ' +
    ' JOIN  gd_document rdoc ON ( r.transferkey = rdoc.id) ' +
    ' JOIN  gd_contact c ON (t.companykey = c.id) ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpRevaluation.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPREVALUATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    ' INSERT INTO dp_revaluation (documentkey, transferkey, sumncuadd, sumncudel) ' +
    ' VALUES(:new_id, :new_transferkey, :new_sumncuadd, :new_sumncudel)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpRevaluation.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPREVALUATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(' UPDATE dp_revaluation SET documentkey = :new_documentkey, ' +
    ' transferkey = :new_transferkey, sumncuadd = :new_sumncuadd, sumncudel = :new_sumncudel ' +
    ' WHERE documentkey = :old_id ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpRevaluation.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPREVALUATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgRevaluation.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpRevaluation._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPREVALUATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPREVALUATION', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPREVALUATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPREVALUATION',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPREVALUATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  Assert(FTransferKey <> -1);

  SetTID(FieldByName('documentkey'), FieldByName('id'));
  FieldByName('transfernumber').Required := False;
  FieldByName('transferdate').Required := False;
  FieldByName('companyname').Required := False;
  FieldByName('tcompanykey').Required := False;

  SetTID(FieldByName('transferkey'), TransferKey);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPREVALUATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPREVALUATION', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

constructor Tgdc_dpRevaluation.Create(AnOwner: TComponent);
begin
  inherited;

  FTransferKey := -1;
end;

function Tgdc_dpRevaluation.DocumentTypeKey: TID;
begin
  Result := DP_DOC_REVALUATION;
end;

class function Tgdc_dpRevaluation.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey=' + TID2S(DP_DOC_REVALUATION);
end;

procedure Tgdc_dpRevaluation.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByInventory') then
    S.Add(' t.inventorykey = :inventorykey ');
end;

function Tgdc_dpRevaluation.GetReductionCondition: String;
begin
  if IsEmpty then
    inherited GetReductionCondition
  else
    Result := ' r.transferkey = ' + FieldByName('transferkey').AsString;
end;

function Tgdc_dpRevaluation.GetReductionTable: String;
begin
  Result := ' gd_document JOIN dp_revaluation r ON id = r.documentkey ';
end;

class function Tgdc_dpRevaluation.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByInventory;';
end;

{ Tgdc_dpSale }

function Tgdc_dpSale.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPSALE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPSALE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPSALE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPSALE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPSALE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgSale.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPSALE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPSALE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpSale.ContactType: Integer;
begin
  Result := cst_Sale;
end;

{ Tgdc_dpAuthority }

function Tgdc_dpAuthority.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPAUTHORITY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgAuthority.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpAuthority.ContactType: Integer;
begin
  Result := cst_Authority;
end;

function Tgdc_dpAuthority.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPAUTHORITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause + ', a.financialkey, a.mainkey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpAuthority.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPAUTHORITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN dp_authority a ON a.companykey = z.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpAuthority.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPAUTHORITY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(' INSERT INTO dp_authority (companykey, financialkey, mainkey) ' +
    'VALUES (:new_id, :new_financialkey, :new_mainkey)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpAuthority.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPAUTHORITY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(' UPDATE dp_authority set financialkey = :new_financialkey, ' +
    ' mainkey = :new_mainkey WHERE companykey = :old_id ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpAuthority.ValidateField(Sender: TField);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_VALIDATEFIELD('TGDC_DPAUTHORITY', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPAUTHORITY', KEYVALIDATEFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYVALIDATEFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPAUTHORITY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(Sender)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPAUTHORITY',
  {M}          'VALIDATEFIELD', KEYVALIDATEFIELD, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPAUTHORITY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with Sender do
  try
    if (AnsiCompareText(FieldName, 'mainkey') = 0) and (IsNull) then
      raise Exception.Create('Не введен главный уполномоченный орган!');
    if (AnsiCompareText(FieldName, 'sumncu') = 0) and (IsNull or (AsInteger = 0)) then
      raise Exception.Create('Неправильно указана сумма акта');
  except
    raise;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPAUTHORITY', 'VALIDATEFIELD', KEYVALIDATEFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPAUTHORITY', 'VALIDATEFIELD', KEYVALIDATEFIELD);
  {M}  end;
  {END MACRO}
end;

{ Tgdc_dpFinancial }

function Tgdc_dpFinancial.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPFINANCIAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPFINANCIAL', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPFINANCIAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPFINANCIAL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPFINANCIAL' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgFinancial.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPFINANCIAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPFINANCIAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpFinancial.ContactType: Integer;
begin
  Result := cst_Financial;
end;

{ Tgdc_dpMain }

function Tgdc_dpMain.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPMAIN', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPMAIN', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPMAIN') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPMAIN',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPMAIN' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgMain.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPMAIN', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPMAIN', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpMain.ContactType: Integer;
begin
  Result := cst_Main;
end;

{ Tgdc_dpDecree }

function Tgdc_dpDecree.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPDECREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPDECREE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPDECREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPDECREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPDECREE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT z.id, z.name, z.decreedate, z.description, z.percent, ' +
    ' z.afull, z.achag, z.aview, z.disabled, z.reserved ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPDECREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPDECREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpDecree.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPDECREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPDECREE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPDECREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPDECREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPDECREE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgDecree.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPDECREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPDECREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpDecree.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'dp_decree';
end;

class function Tgdc_dpDecree.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function Tgdc_dpDecree.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dp_frmDecree';
end;

{ Tgdc_dpWithDrawal }

function Tgdc_dpWithDrawal.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPWITHDRAWAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    ' , c.name as contactname, a.name as authorityname, cu.shortname as currname, ' +
    ' w.documentkey, w.authoritykey, w.contactkey ';
;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpWithDrawal.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPWITHDRAWAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM dp_withdrawal w ' +
    ' LEFT JOIN gd_document z ON z.id = w.documentkey ' +
    ' LEFT JOIN gd_contact c ON w.contactkey = c.id ' +
    ' LEFT JOIN gd_contact a ON w.authoritykey = a.id ' +
    ' LEFT JOIN gd_curr cu ON cu.id = z.currkey '
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpWithDrawal.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPWITHDRAWAL', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO dp_withdrawal(documentkey, authoritykey, contactkey) ' +
    'VALUES (:new_id, :new_authoritykey, :new_contactkey)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpWithDrawal.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPWITHDRAWAL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE dp_withdrawal SET ' +
    ' authoritykey = :new_authoritykey, contactkey = :new_contactkey WHERE ' +
    ' documentkey = :old_id', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpWithDrawal.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPWITHDRAWAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgWithDrawal.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpWithDrawal._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPWITHDRAWAL', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPWITHDRAWAL', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPWITHDRAWAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPWITHDRAWAL',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPWITHDRAWAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  SetTID(FieldByName('documentkey'), FieldByName('id'));
  FieldByName('authorityname').Required := False;
  FieldByName('contactname').Required := False;
  FieldByName('currname').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPWITHDRAWAL', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPWITHDRAWAL', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpWithDrawal.DocumentTypeKey: TID;
begin
  Result := DP_DOC_WITHDRAWAL;
end;

procedure Tgdc_dpWithDrawal.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if not IBLogin.IsUserAdmin then
    S.Add('(g_sec_testall(a.aview, a.achag, a.afull, ' + IntToStr(IBLogin.InGroup) +  ' )  <> 0)');
end;

class function Tgdc_dpWithDrawal.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey=' + TID2S(DP_DOC_WITHDRAWAL);
end;

class function Tgdc_dpWithDrawal.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dp_frmWithDrawal';
end;

{ Tgdc_dpAssetDest }

function Tgdc_dpAssetDest.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPASSETDEST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPASSETDEST', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPASSETDEST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPASSETDEST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPASSETDEST' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT z.id, z.name, z.description, z.typeasset, z.afull, z.achag, ' +
    ' z.aview, z.disabled, z.reserved ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPASSETDEST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPASSETDEST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpAssetDest.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPASSETDEST', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPASSETDEST', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPASSETDEST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPASSETDEST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPASSETDEST' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgAssetDest.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPASSETDEST', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPASSETDEST', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpAssetDest.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'dp_assetdest';
end;

class function Tgdc_dpAssetDest.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function Tgdc_dpAssetDest.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dp_frmAssetDest';
end;

{ TgdcBankStatementLineD }

function TgdcBankStatementLineD.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCBANKSTATEMENTLINED', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINED', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINED',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINED' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgBankStateDepartmentLine.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINED', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINED', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatementLineD.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENTLINED', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINED', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINED',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINED' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery  ('INSERT INTO bn_bankstatementline (id, documentkey, bankstatementkey, companykey, ' +
    'trtypekey, dsumncu, dsumcurr, csumncu, csumcurr, paymentmode, operationtype, ' +
    'account, bankcode, docnumber, comment) ' +
    'VALUES (:new_lineid, :new_documentkey, :new_bankstatementkey, :new_companykeyline, ' +
    ':new_trtypekeyline, :new_dsumncu, :new_dsumcurr, :new_csumncu, :new_csumcurr, :new_paymentmode, :new_operationtype, ' +
    ':new_account, :new_bankcode, :new_docnumber, :new_comment) ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINED', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINED', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatementLineD.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENTLINED', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINED', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINED',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINED' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery ('UPDATE bn_bankstatementline SET documentkey=:new_documentkey, bankstatementkey=:new_bankstatementkey, ' +
    'companykey=:new_companykeyline, trtypekey=:new_trtypekeyline, dsumncu=:dsumncu, ' +
    'dsumcurr=:new_dsumcurr, csumncu=:new_csumncu, csumcurr=:new_csumcurr, ' +
    'paymentmode=:new_paymentmode, operationtype=:new_operationtype, account=:new_account, ' +
    'bankcode=:new_bankcode, docnumber=:new_docnumber, comment=:new_comment ' +
    'where id=:old_lineid', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINED', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINED', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatementLineD.DivideLine;
var
  OperationType: String;
  BankCode: String;
  Account: String;
  DocNumber: String;
  Comment: String;
  CompanyKey: String;
  TrtypeKeyLine: String;
  PaymentMode: String;

  procedure AddNew(S: String);
  begin
    if S > '' then
    begin
      Insert;
      FieldByName('operationtype').AsString := operationtype;
      FieldByName('bankcode').AsString := bankcode;
      FieldByName('account').AsString := account;
      FieldByName('docnumber').AsString := docnumber;
      FieldByName('comment').AsString := comment;
      FieldByName('csumncu').AsString := S;
      FieldByName('companykeyline').AsString := companykey;
      FieldByName('trtypekeyline').AsString := trtypekeyline;
      FieldByName('paymentmode').AsString := paymentmode;
      Post;
    end;
  end;

begin
  with Tgdc_dlgDivideLine.Create(nil) do
  try
    lbSum.Caption := FieldByName('csumncu').AsString;
    Edit1.Text := FieldByName('csumncu').AsString;
    if ShowModal = mrOk then
    begin
      operationtype := FieldByName('operationtype').AsString;
      bankcode := FieldByName('bankcode').AsString;
      account := FieldByName('account').AsString;
      docnumber := FieldByName('docnumber').AsString;
      comment := FieldByName('comment').AsString;
      companykey := FieldByName('companykeyline').AsString;
      trtypekeyline := FieldByName('trtypekeyline').AsString;
      paymentmode := FieldByName('paymentmode').AsString;

      if Edit2.Text > '' then
      begin
        Edit;
        FieldByName('CSUMNCU').AsString := Edit1.Text;
        Post;
        AddNew(Edit2.Text);
        AddNew(Edit3.Text);
        AddNew(Edit4.Text);
        AddNew(Edit5.Text);
        AddNew(Edit6.Text);
        AddNew(Edit7.Text);
        AddNew(Edit8.Text);
        AddNew(Edit9.Text);
        AddNew(Edit10.Text);
      end;
    end;
  finally
    Free;
  end;
end;

function TgdcBankStatementLineD.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANKSTATEMENTLINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINED', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINED',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINED' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    '  FROM gd_document z ' +
    '  LEFT JOIN bn_bankstatementline bsl ON ' +
    '    z.id = bsl.id ' +
    '  LEFT JOIN gd_document dbsl ON ' +
    '    dbsl.id = bsl.documentkey ' +
    '  LEFT JOIN gd_contact cc ON '+
    '    bsl.companykey = cc.id '+
    '  LEFT JOIN gd_listtrtype lt ON ' +
    '    lt.id = bsl.trtypekey ' +
    '  LEFT JOIN gd_bank bn ON ' +
    '    bn.bankcode = bsl.bankcode ' +
    '  LEFT JOIN gd_contact ctb  ' +
    '    ON ctb.id = bn.bankkey ' ;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

{function TgdcBankStatementLineD.GetRefreshSQLText: String;
begin
  Result := GetSelectClause +
    '  FROM bn_bankstatementline bsl ' +
    '  JOIN gd_document z ON ' +
    '    z.id = bsl.id ' +
    '  LEFT JOIN gd_document dbsl ON ' +
    '    dbsl.id = bsl.documentkey ' +
    '  LEFT JOIN gd_contact cc ON '+
    '    bsl.companykey = cc.id '+
    '  LEFT JOIN gd_listtrtype lt ON ' +
    '    lt.id = bsl.trtypekey ' +
    '  LEFT JOIN gd_bank bn ON ' +
    '    bn.bankcode = bsl.bankcode ' +
    '  LEFT JOIN gd_contact ctb  ' +
    '    ON ctb.id = bn.bankkey ' +
    '  WHERE '+
    '    bsl.id = :id';
end;}

function TgdcBankStatementLineD.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANKSTATEMENTLINED', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINED', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINED',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINED' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    '  , ' +
    '  bsl.id AS lineid,' +
    '  bsl.documentkey,' +
    '  bsl.bankstatementkey,' +
    '  bsl.companykey as companykeyline,' +
    '  cc.name as companyname, ' +
    '  bsl.trtypekey as trtypekeyline,' +
    '  lt.name as OperationName, ' +
    '  bsl.dsumncu,' +
    '  bsl.dsumcurr,' +
    '  bsl.csumncu,' +
    '  bsl.csumcurr,' +
    '  bsl.paymentmode,' +
    '  bsl.operationtype,' +
    '  bsl.account,' +
    '  bsl.docnumber,' +
    '  bsl.comment,' +
    '  bsl.bankcode, ' +
    '  bsl.USR$RETURN, ' +
    '  ctb.name as bankname, ' +
    '  dbsl.number as DocNumberLink, ' +
    '  dbsl.documentdate as DocumentDateLink ' + #13#10;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINED', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINED', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatementLineD.GetWhereClauseConditions(S: TStrings);
var
  Str: String;
  I: Integer;
begin
  inherited;
  if HasSubSet('ByID') then
  //Перекрыто, т.к. подобное условие увеличивает скорость выполнения запроса в 2 раза
    S.Add('bsl.id = :id')
  else
  begin
    if not IBLogin.IsUserAdmin then
      S.Add(' (g_sec_testall(cc.aview, cc.achag, cc.afull, ' +
        IntToStr(IBLogin.InGroup) + ') <> 0  OR (cc.id IS NULL))');
  end;
//Условие проверяет права на акты описи, т.е. будут отображаться только те выписки,
//по которым либо нет актов описи, либо есть право на отображение актов
  S.Add(' ( EXISTS(SELECT * FROM bn_bslinedocument bsld ' +
    ' LEFT JOIN gd_document dt ON dt.id = bsld.documentkey ' +
    ' WHERE bsld.bslinekey = z.id AND (g_sec_test(dt.aview,' +
      IntToStr(IBLogin.InGroup) + ') <> 0)) ' +
    '  OR ' +
    ' NOT EXISTS(SELECT * FROM bn_bslinedocument bsld1 ' +
    ' WHERE bsld1.bslinekey = z.id)) ');

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
    S.Add(Format('bsl.id IN (%s)', [Str]));
  end;
end;

{Tgdc_dpBSLine}

function Tgdc_dpBSLine.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDC_DPBSLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(ss_ByLine) then
    Result := 'SELECT z.*, ' +
      ' inv.number as invnumber, inv.documentdate as invdate, ' +
      ' c.name as companyname, ' +
      ' (bs.sumncu) as bsldsumncu, (SELECT ' +
      ' SUM(r.sumncuadd - r.sumncudel) ' +
      ' FROM dp_revaluation r  ' +
      ' WHERE r.transferkey = t.documentkey) as revsum '
  else
    Result := 'SELECT z.*, ' +
      ' inv.number as invnumber, inv.documentdate as invdate, ' +
      ' c.name as companyname, ' +
      ' (SELECT SUM(bsld.sumncu) FROM bn_bslinedocument bsld ' +
      ' WHERE bsld.documentkey = z.id) as bsldsumncu , (SELECT ' +
      ' SUM(r.sumncuadd - r.sumncudel) ' +
      ' FROM dp_revaluation r ' +
      ' WHERE r.transferkey = t.documentkey) as revsum ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function Tgdc_dpBSLine.GetRefreshSQLText: String;
begin
  if HasSubSet(ss_ByLine) then
    Result := 'SELECT z.*, ' +
        ' inv.number as invnumber, inv.documentdate as invdate, ' +
        ' c.name as companyname, ' +
        ' (SELECT SUM(bsld.sumncu) FROM bn_bslinedocument bsld ' +
        ' WHERE bsld.documentkey = z.id and bsld.bslinekey = ' +
        TID2S(FBSLineKey) + ') as bsldsumncu '
  else
  Result := 'SELECT z.*, ' +
    ' inv.number as invnumber, inv.documentdate as invdate, ' +
    ' c.name as companyname, ' +
    ' (SELECT SUM(bsld.sumncu) FROM bn_bslinedocument bsld ' +
    ' WHERE bsld.documentkey = z.id) as bsldsumncu ';

  Result := Result +
    ' FROM dp_transfer t ' +
    ' LEFT JOIN gd_contact c ON t.companykey=c.id ' +
    ' LEFT JOIN gd_document z ON  z.id=t.documentkey ' +
    ' LEFT JOIN gd_document inv ON inv.id=t.inventorykey ' +
    ' WHERE t.documentkey = :id '
end;


function Tgdc_dpBSLine.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDC_DPBSLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ORDER BY inv.documentdate DESC, inv.number ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpBSLine.SetBSLineKey(Value: TID);
var
  WasActive: Boolean;
begin
  if FBSLineKey <> Value then
  begin
    WasActive := Active;
    Close;
    FBSLineKey := Value;
    FSQLInitialized := False;
    if WasActive then
      Open;
  end;
end;

function Tgdc_dpBSLine.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDC_DPBSLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(ss_ByLine) then
    Result := 'FROM bn_bslinedocument bs ' +
        ' LEFT JOIN dp_transfer t ON bs.documentkey = t.documentkey ' +
        ' LEFT JOIN gd_contact c ON t.companykey=c.id ' +
        ' LEFT JOIN gd_document z ON  z.id=t.documentkey ' +
        ' LEFT JOIN gd_document inv ON inv.id=t.inventorykey '
  else if HasSubSet (ss_ByCompany) then
    Result := ' FROM dp_transfer t ' +
        ' JOIN gd_contact c ON t.companykey=c.id ' +
        ' LEFT JOIN gd_document z ON  z.id=t.documentkey ' +
        ' LEFT JOIN gd_document inv ON inv.id=t.inventorykey '
  else
    Result := ' FROM gd_document z ' +
        ' LEFT JOIN dp_transfer t ON  (z.id=t.documentkey) AND (z.documenttypekey = ' +
        IntToStr(DP_DOC_TRANSFER)+ ' ) ' +
        ' LEFT JOIN gd_contact c ON t.companykey=c.id ' +
        ' LEFT JOIN gd_document inv ON inv.id=t.inventorykey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpBSLine.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'gd_document'
end;

class function Tgdc_dpBSLine.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'number'
end;

class function Tgdc_dpBSLine.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id'
end;

procedure Tgdc_dpBSLine.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPBSLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpBSLine.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPBSLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpBSLine.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDC_DPBSLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//Из этого объекта не должно ничего удалятся
//Он является информационным при разноске выписки по актам описи
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

constructor Tgdc_dpBSLine.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  CustomProcess := [cpDelete, cpInsert, cpModify];
  FBSLineKey := -1;
  FCompanyKey := -1;
  FSumNCU := 0;
//  SearchSubSet := ss_ByCompany;
  SubSet := ss_ByLine;
end;

procedure Tgdc_dpBSLine.Assign(Source: TPersistent);
begin
  Assert(Source is Tgdc_dpBSLine);
  inherited;
  FCompanyKey := (Source as Tgdc_dpBSLine).CompanyKey;
  FBSLineKey := (Source as Tgdc_dpBSLine).BSLineKey;
end;

procedure Tgdc_dpBSLine.GetWhereClauseConditions(S: TStrings);
begin
  if HasSubSet(ss_ByCompany) then
    S.Add('(c.id = :companykey ' + { IntToStr(FCompanyKey) +}
      ') AND ((inv.disabled = 0) or (inv.disabled IS NULL))' )
  else if HasSubSet(ss_ByLine) then
    S.Add(' bs.bslinekey = ' + TID2S(BSLineKey) )
  else
    inherited;
end;

procedure Tgdc_dpBSLine._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPBSLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('bsldsumncu').AsCurrency := FSumNCU;
  FieldByName('invnumber').Required := False;
  FieldByName('invdate').Required := False;
  FieldByName('number').Required := False;
  FieldByName('documentdate').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;


procedure Tgdc_dpBSLine.SetCompanyKey(const Value: TID);
var
  WasActive: Boolean;
begin
{ if FCompanykey <> Value then
  begin}
    FCompanyKey := Value;
    if HasSubSet(ss_ByCompany) then
    begin
      WasActive := Active;
      Close;
      SetTID(ParamByName('companykey'), FCompanyKey);
      Active := WasActive;
    end;
{ end;}
end;

class function Tgdc_dpBSLine.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    ss_ByCompany + ';' +
    ss_ByLine + ';';
end;

procedure Tgdc_dpBSLine.DeleteTransfer(BL: TBookmarkList);
var
  I: Integer;
begin
  if Assigned(BL) then
    BL.Refresh;

  if (BL = nil) or (BL.Count <= 1) then
  begin
    if (RecordCount > 0) and
       (
         (not (sView in BaseState)) or
         (MessageBox(ParentHandle, PChar(Format('Удалить выделенную запись "%s"?', [ObjectName])), 'Внимание!', MB_YESNO or MB_ICONQUESTION) = IDYES)
       ) then
    begin
      try
        ExecSingleQuery('DELETE FROM bn_bslinedocument WHERE bslinekey = :old_bslinekey and documentkey = :old_documentkey',
          VarArrayOf([TID2V(FBSLineKey), TID2V(ID)]));

      except
        raise EgdcException.Create('Ошибка при удалении записи из группы!');
      end;
    end;
  end
  else
    if (not (sView in BaseState)) or (MessageBox(ParentHandle,
          PChar(Format('Выделено записей: %d'#13#10'Удалить?', [BL.Count])),
          'Внимание!',
          MB_YESNO or MB_ICONQUESTION) = IDYES) then
    begin
      DisableControls;
      try
        for I := BL.Count - 1 downto 0 do
        begin
          if BookmarkValid(Pointer(BL[I])) then
          begin
            Bookmark := BL[I];
            try
              ExecSingleQuery('DELETE FROM bn_bslinedocument WHERE bslinekey = :old_bslinekey and documentkey = :old_documentkey',
                VarArrayOf([TID2V(FBSLineKey), TID2V(ID)]));
            except
              raise EgdcException.Create('Ошибка при удалении записи из группы!');
            end;
          end;
        end;
      finally
        EnableControls;
      end;
    end;
  FDSModified := True;
  CloseOpen;
end;

procedure Tgdc_dpBSLine.ChooseCompany;
begin
  with Tgdc_dlgChooseCompany.Create(Self) do
  begin
    try
      if HasSubSet('ByCompany') then
        ibcmbCompany.CurrentKeyInt := GetTID(ParamByName('companykey'))
      else
        ibcmbCompany.CurrentKeyInt := FCompanyKey;
      if ShowModal = mrOk then
        SetCompanyKey(ibcmbCompany.CurrentKeyInt);
    finally
      Free;
    end;
  end;
end;

class function Tgdc_dpBSLine.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dp_frmBSLine';
end;

function Tgdc_dpInventory.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDC_DPINVENTORY', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPINVENTORY', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPINVENTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPINVENTORY',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPINVENTORY' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPINVENTORY', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPINVENTORY', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure Tgdc_dpBSLine.ChooseTransfer;
var
  I: Integer;
begin
  if Self.ChooseItems(False, '', '') then
  begin
    for I := 0 to SelectedID.Count - 1 do
      ExecSingleQuery('INSERT INTO bn_bslinedocument(bslinekey,  documentkey, sumncu) VALUES (:bslinekey,  :documentkey, :sumncu)',
        VarArrayOf([TID2V(FBSLineKey), TID2V(SelectedID.Keys[I]),FSumNCU]));
    if SelectedID.Count > 0 then
    begin
      SelectedID.Clear;
      if not CachedUpdates then
        CloseOpen;
      FDSModified := True;
    end;
  end;
end;

class function Tgdc_dpInventory.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dp_frmInventory';
end;

function Tgdc_dpBSLine.DocumentTypeKey: TID;
begin
  Result := DP_DOC_TRANSFER;
end;

procedure Tgdc_dpBSLine.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDC_DPBSLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPBSLINE', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPBSLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPBSLINE',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPBSLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if HasSubSet('ByCompany') then
    if (GetTID(ParamByName('companykey')) > 0) and
      (FCompanyKey <> GetTID(ParamByName('companykey')))
    then
      FCompanyKey := GetTID(ParamByName('companykey'));
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPBSLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPBSLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

{ Tgdc_dpComittee }

class function Tgdc_dpComittee.ContactType: Integer;
begin
  Result := cst_Comittee;
end;

function Tgdc_dpComittee.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDC_DPCOMITTEE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DPCOMITTEE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DPCOMITTEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DPCOMITTEE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DPCOMITTEE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dp_dlgComittee.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDC_DPCOMITTEE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDC_DPCOMITTEE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function Tgdc_dpInventory.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'NotDisabled;OnlyDisabled;';
end;

initialization
  RegisterGdcClass(Tgdc_dpInventory, ctStorage, 'Акты описи и оценки');
  RegisterGdcClass(Tgdc_dpTransfer, ctStorage, 'Акты передачи');
  RegisterGdcClass(Tgdc_dpRevaluation, ctStorage, 'Акты переоценки');
  RegisterGdcClass(Tgdc_dpSale, ctStorage, 'Реализующая организация');
  RegisterGdcClass(Tgdc_dpMain, ctStorage, 'Главный уполномоченный орган');
  RegisterGdcClass(Tgdc_dpAuthority, ctStorage, 'Уполномоченный орган');
  RegisterGdcClass(Tgdc_dpFinancial, ctStorage, 'Финансовый орган');
  RegisterGdcClass(Tgdc_dpDecree);
  RegisterGdcClass(Tgdc_dpComittee, ctStorage, 'Комиссия');
  RegisterGdcClass(Tgdc_dpWithDrawal);
  RegisterGdcClass(Tgdc_dpAssetDest);
  RegisterGdcClass(TgdcBankStatementLineD);
  RegisterGdcClass(Tgdc_dpBSLine);

finalization
  UnregisterGdcClass(Tgdc_dpInventory);
  UnregisterGdcClass(Tgdc_dpTransfer);
  UnregisterGdcClass(Tgdc_dpRevaluation);
  UnregisterGdcClass(Tgdc_dpSale);
  UnregisterGdcClass(Tgdc_dpMain);
  UnregisterGdcClass(Tgdc_dpAuthority);
  UnregisterGdcClass(Tgdc_dpFinancial);
  UnregisterGdcClass(Tgdc_dpDecree);
  UnregisterGdcClass(Tgdc_dpComittee);
  UnregisterGdcClass(Tgdc_dpWithDrawal);
  UnregisterGdcClass(Tgdc_dpAssetDest);
  UnregisterGdcClass(TgdcBankStatementLineD);
  UnregisterGdcClass(Tgdc_dpBSLine);

end.
