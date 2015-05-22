unit gdcPayment;

interface

uses
  dmDataBase_unit, gdcClasses, gd_security_OperationConst,
  gd_createable_form, Classes, DB, Sysutils, gdcBase, gsTransaction,
  DBCtrls, IBSQL, stdctrls, Forms, gdcBaseBank, gdcBaseInterface;

type
  TgdcDestCode = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcBasePayment = class(TgdcBaseBank)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure DoAfterOpen; override;
    procedure DoBeforePost; override;
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    procedure UpdateCorrAccount;
    procedure UpdateAdditional;
    procedure UpdateCorrCompany;
    function GetDialogDefaultsFields: String; override;
  end;

  TgdcPaymentDemand = class(TgdcBasePayment)
  protected
    function GetGroupID: Integer; override;

  public
    class function ClassDocumentTypeKey: Integer; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcPaymentOrder = class(TgdcBasePayment)
  protected
    function GetGroupID: Integer; override;
    procedure CreateFields; override;

  public
    class function ClassDocumentTypeKey: Integer; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcDemandOrder = class(TgdcBasePayment)
  protected
    function GetGroupID: Integer; override;

  public
    class function ClassDocumentTypeKey: Integer; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAdviceOfCollection = class(TgdcBasePayment)
  protected
    function GetGroupID: Integer; override;

  public
    class function ClassDocumentTypeKey: Integer; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  procedure Register;

implementation

uses
  gd_security,

  gdc_dlgPaymentOrder_unit,
  gdc_dlgPaymentDemand_unit,
  gdc_dlgDemandOrder_unit,
  gdc_dlgAdviceOfCollection_unit,
  gdc_frmSGRAccount_unit,
  gdc_dlgDestCode_unit,

  gdc_frmDestCode_unit,
  gdc_frmPaymentOrder_unit,
  gdc_frmDemandOrder_unit,
  gdc_frmPaymentDemand_unit,
  gdc_frmAdviceOfCollection_unit, gd_ClassList;

const
  grPaymentOrder = 2000201;
  grPaymentDemand = 2000202;
  grDemandOrder = 2000203;
  grAdviceOfCollection = 2000204;

procedure Register;
begin
  RegisterComponents('gdcPayment', [
    TgdcPaymentDemand,
    TgdcPaymentOrder,
    TgdcDemandOrder,
    TgdcAdviceOfCollection,
    TgdcDestCode]);
end;

{ TgdcDestCode }

class function TgdcDestCode.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'BN_DESTCODE';
end;

class function TgdcDestCode.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'code';
end;

class function TgdcDestCode.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDestCode';
end;

class function TgdcDestCode.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgDestCode';
end;

{ TgdcBasePayment }

procedure TgdcBasePayment.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASEPAYMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('insert into BN_DEMANDPAYMENT ' +
    '  (DOCUMENTKEY, ACCOUNTKEY, CORRCOMPANYKEY,' +
    'CORRACCOUNTKEY,' +
    '   OWNCOMPTEXT, OWNTAXID, OWNCOUNTRY, OWNBANKTEXT,' +
    'OWNBANKCITY, OWNACCOUNT,' +
    '   OWNACCOUNTCODE, CORRCOMPTEXT, CORRTAXID, CORRCOUNTRY,' +
    'CORRBANKTEXT,' +
    '   CORRBANKCITY, CORRACCOUNT, CORRACCOUNTCODE, CORRSECACC,' +
    'AMOUNT, PROC,' +
    '   OPER, QUEUE, DESTCODEKEY, TERM, DESTINATION,' +
    'SECONDACCOUNTKEY, SECONDAMOUNT,' +
    '   ENTERDATE, SPECIFICATION, CARGOSENDER, CARGORECIEVER,' +
    'CONTRACT, PAPER,' +
    '   CARGOSENDDATE, PAPERSENDDATE, DESTCODE, KIND, EXPENSEACCOUNT,' +
    'MIDCORRBANKTEXT, WITHACCEPTANCE, WITHACCEPT) ' +
    'values ' +
    '  (:DOCUMENTKEY, :ACCOUNTKEY, :CORRCOMPANYKEY,' +
    ':CORRACCOUNTKEY,' +
    '   :OWNCOMPTEXT, :OWNTAXID, :OWNCOUNTRY, :OWNBANKTEXT,' +
    ':OWNBANKCITY, :OWNACCOUNT,' +
    '   :OWNACCOUNTCODE, :CORRCOMPTEXT, :CORRTAXID, :CORRCOUNTRY,' +
    ':CORRBANKTEXT,' +
    '   :CORRBANKCITY, :CORRACCOUNT, :CORRACCOUNTCODE, :CORRSECACC,' +
    ':AMOUNT,' +
    '   :PROC, :OPER, :QUEUE, :DESTCODEKEY, :TERM, :DESTINATION,' +
    ':SECONDACCOUNTKEY,' +
    '   :SECONDAMOUNT, :ENTERDATE, :SPECIFICATION, :CARGOSENDER,' +
    ':CARGORECIEVER,' +
    '   :CONTRACT, :PAPER, :CARGOSENDDATE, :PAPERSENDDATE, :DESTCODE,' +
    ':KIND, :EXPENSEACCOUNT, :MIDCORRBANKTEXT, :WITHACCEPTANCE, :WITHACCEPT)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBasePayment.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBASEPAYMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('update BN_DEMANDPAYMENT ' +
    'set ' +
    '  DOCUMENTKEY = :DOCUMENTKEY,' +
    '  ACCOUNTKEY = :ACCOUNTKEY,' +
    '  CORRCOMPANYKEY = :CORRCOMPANYKEY,' +
    '  CORRACCOUNTKEY = :CORRACCOUNTKEY,' +
    '  OWNCOMPTEXT = :OWNCOMPTEXT,' +
    '  OWNTAXID = :OWNTAXID,' +
    '  OWNCOUNTRY = :OWNCOUNTRY,' +
    '  OWNBANKTEXT = :OWNBANKTEXT,' +
    '  OWNBANKCITY = :OWNBANKCITY,' +
    '  OWNACCOUNT = :OWNACCOUNT,' +
    '  OWNACCOUNTCODE = :OWNACCOUNTCODE,' +
    '  CORRCOMPTEXT = :CORRCOMPTEXT,' +
    '  CORRTAXID = :CORRTAXID,' +
    '  CORRCOUNTRY = :CORRCOUNTRY,' +
    '  CORRBANKTEXT = :CORRBANKTEXT,' +
    '  CORRBANKCITY = :CORRBANKCITY,' +
    '  CORRACCOUNT = :CORRACCOUNT,' +
    '  CORRACCOUNTCODE = :CORRACCOUNTCODE,' +
    '  CORRSECACC = :CORRSECACC,' +
    '  AMOUNT = :AMOUNT,' +
    '  PROC = :PROC,' +
    '  OPER = :OPER,' +
    '  QUEUE = :QUEUE,' +
    '  DESTCODEKEY = :DESTCODEKEY,' +
    '  TERM = :TERM,' +
    '  DESTINATION = :DESTINATION,' +
    '  SECONDACCOUNTKEY = :SECONDACCOUNTKEY,' +
    '  SECONDAMOUNT = :SECONDAMOUNT,' +
    '  ENTERDATE = :ENTERDATE,' +
    '  SPECIFICATION = :SPECIFICATION,' +
    '  CARGOSENDER = :CARGOSENDER,' +
    '  CARGORECIEVER = :CARGORECIEVER,' +
    '  CONTRACT = :CONTRACT,' +
    '  PAPER = :PAPER,' +
    '  CARGOSENDDATE = :CARGOSENDDATE,' +
    '  PAPERSENDDATE = :PAPERSENDDATE,' +
    '  DESTCODE = :DESTCODE,' +
    '  KIND = :KIND,' +
    '  EXPENSEACCOUNT = :EXPENSEACCOUNT,' +
    '  WITHACCEPTANCE = :WITHACCEPTANCE, ' +
    '  WITHACCEPT = :WITHACCEPT, ' +
    '  MIDCORRBANKTEXT = :MIDCORRBANKTEXT ' +
    ' where ' +
    '  DOCUMENTKEY = :OLD_DOCUMENTKEY', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBasePayment.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEPAYMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('corrcompanykey').Required := True;
  FieldByName('corraccountkey').Required := True;
  FieldByName('amount').Required := True;
  FieldByName('accountkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBasePayment.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEPAYMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
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
      FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;

    q := CreateReadIBSQL;
    try
      /////////////////////////
      //  Данные по плательщику
      q.Close;
      q.SQL.Text :=
        ' SELECT c.country, comp.fullname, cc.taxid FROM gd_contact c ' +
        ' LEFT JOIN gd_company comp on c.id = comp.contactkey ' +
        ' LEFT JOIN gd_companycode cc on c.id = cc.companykey ' +
        ' WHERE c.id = :id ';
      q.Prepare;

      q.Params.ByName('id').AsInteger := IBLogin.CompanyKey;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        FieldByName('owntaxid').AsString := q.FieldByName('taxid').AsString;
        FieldByName('owncountry').AsString := q.FieldByName('country').AsString;
        FieldByName('owncomptext').AsString := q.FieldByName('fullname').AsString;
      end;

      q.Close;

      ///////////////////////
      // Данные по получателю

      q.Params.ByName('id').AsString := FieldByName('corrcompanykey').AsString;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        FieldByName('corrtaxid').AsString := q.FieldByName('taxid').AsString;
        FieldByName('corrcountry').AsString := q.FieldByName('country').AsString;
        FieldByName('corrcomptext').AsString := q.FieldByName('fullname').AsString;
      end
      else
      begin
        FieldByName('corrtaxid').AsString := '';
        FieldByName('corrcountry').AsString := '';
      end;

      q.Close;

      q.SQL.Text :=
        ' SELECT COMP.FULLNAME, C.CITY, BANK.BANKCODE, BANK.BANKKEY, A.ACCOUNT ' +
        ' FROM GD_COMPANYACCOUNT A, GD_COMPANY COMP ' +
        '  JOIN GD_CONTACT C ON COMP.CONTACTKEY = C.ID ' +
        '  JOIN GD_BANK BANK ON COMP.CONTACTKEY = BANK.BANKKEY ' +
        ' WHERE A.ID = :Id  AND COMP.CONTACTKEY = A.BANKKEY';
      q.Prepare;

      q.Params.ByName('ID').AsInteger := FieldByName('ACCOUNTKEY').AsInteger;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        FieldByName('OWNBANKTEXT').AsString := q.FieldByName('FULLNAME').AsString;
        FieldByName('OWNBANKCITY').AsString := q.FieldByName('CITY').AsString;
        FieldByName('OWNACCOUNTCODE').AsString := q.FieldByName('BANKCODE').AsString;
        FieldByName('OWNACCOUNT').AsString := q.FieldByName('ACCOUNT').AsString;
      end;

      q.Close;

      q.Params.ByName('ID').AsInteger := FieldByName('CORRACCOUNTKEY').AsInteger;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        FieldByName('CORRBANKTEXT').AsString := q.FieldByName('FULLNAME').AsString;
        FieldByName('CORRBANKCITY').AsString := q.FieldByName('CITY').AsString;
        FieldByName('CORRACCOUNTCODE').AsString := q.FieldByName('BANKCODE').AsString;
        FieldByName('CORRACCOUNT').AsString := q.FieldByName('ACCOUNT').AsString;
      end;

      q.Close;
      q.SQL.Text := 'SELECT code FROM bn_destcode WHERE id = :id';
      q.ParamByName('id').AsInteger := FieldByName('destcodekey').AsInteger;
      q.ExecQuery;
      if q.RecordCount > 0 then
        FieldByName('destcode').AsString := q.FieldByName('code').AsString;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcBasePayment.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBASEPAYMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
  ' LEFT JOIN bn_demandpayment dp  ' +
  '   ON dp.documentkey = z.id ' +
  ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBasePayment.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBASEPAYMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
  ', dp.* ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBasePayment.UpdateCorrAccount;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    DidActivate := ActivateReadTransaction;

    q.SQL.Text :=
      ' SELECT ca.id, ca.account FROM gd_companyaccount ca WHERE ca.companykey = :CorrCompanyKey ';

    q.Prepare;
    q.ParamByName('CORRCOMPANYKEY').AsInteger :=
      FieldByName('CORRCOMPANYKEY').AsInteger;
    q.ExecQuery;

    if q.RecordCount = 0 then
      FieldByName('CORRACCOUNTKEY').Clear
    else
    begin
      while not q.Eof do
      begin
        if FieldByName('CORRACCOUNTKEY').Value = q.FieldByName('ID').Value then
          Break;
        q.Next;
      end;

      if q.Eof then
      begin
        q.Close;
        q.SQL.Text :=
        ' SELECT ca.id, ca.account FROM gd_company c ' +
        ' JOIN gd_companyaccount ca ON c.companyaccountkey = ca.id WHERE c.contactkey = :CorrCompanyKey ';

        q.ParamByName('CORRCOMPANYKEY').AsInteger :=
          FieldByName('CORRCOMPANYKEY').AsInteger;
        q.ExecQuery;

        if q.RecordCount > 0 then
          FieldByName('CORRACCOUNTKEY').AsInteger := q.FieldByName('ID').AsInteger;
      end;
    end;
  finally
    q.Free;

    if DidActivate then
      DeactivateReadTransaction;
  end;
end;

procedure TgdcBasePayment.UpdateAdditional;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  if State in [dsEdit, dsInsert] then
  begin
    DidActivate := False;
    q := TIBSQL.Create(nil);
    try
      q.Database := Database;
      q.Transaction := ReadTransaction;
      DidActivate := ActivateReadTransaction;

      q.SQL.Text :=
        ' SELECT C.NAME, C.COUNTRY, COMP.FULLNAME, CC.TAXID ' +
        ' FROM GD_CONTACT C LEFT JOIN GD_COMPANY COMP ON C.ID = COMP.CONTACTKEY ' +
        '   LEFT JOIN GD_COMPANYCODE CC ON C.ID = CC.COMPANYKEY ' +
        ' WHERE C.ID = :Id ';

      q.Prepare;
      q.ParamByName('ID').AsInteger :=
        FieldByName('CORRCOMPANYKEY').AsInteger;
      q.ExecQuery;

      if (q.RecordCount > 0) then
      begin
        if (q.FieldByName('FullName').AsString = '') then
          FieldByName('CorrCompText').AsString := q.FieldByName('Name').AsString
        else
          FieldByName('CorrCompText').AsString := q.FieldByName('FullName').AsString;
      end;
    finally
      q.Free;

      if DidActivate then
        DeactivateReadTransaction;
    end;
  end;
end;

procedure TgdcBasePayment.UpdateCorrCompany;
var
  q: TIBSQL;
begin
   if (not FieldByName('corraccountkey').IsNull) and (State in [dsEdit, dsInsert]) then
   begin
     q := CreateReadIBSQL;
     try
       q.SQL.Text := 'SELECT ca.companykey FROM gd_companyaccount ca ' +
         'WHERE ca.id = :id';
       q.ParamByName('id').AsInteger := FieldByName('corraccountkey').AsInteger;
       q.ExecQuery;

       if q.RecordCount > 0 then
         FieldByName('corrcompanykey').AsInteger := q.FieldByName('companykey').AsInteger
       else
         FieldByName('corrcompanykey').Clear;
     finally
       q.Free;
     end;
   end;
end;

procedure TgdcBasePayment.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByAccount') then
    S.Add(' dp.accountkey = :accountkey');
end;

procedure TgdcBasePayment._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEPAYMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBasePayment.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASEPAYMENT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEPAYMENT', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEPAYMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEPAYMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEPAYMENT' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'accountkey;';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEPAYMENT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEPAYMENT', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

{ TgdcPaymentDemand }

class function TgdcPaymentDemand.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_PAYMENTDEMAND;
end;

function TgdcPaymentDemand.GetGroupID: Integer;
begin
  Result := grPaymentDemand;
end;

class function TgdcPaymentDemand.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey = ' + IntToStr(BN_DOC_PAYMENTDEMAND);
end;

class function TgdcPaymentDemand.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmPaymentDemand';
end;

class function TgdcPaymentDemand.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgPaymentDemand';
end;

{ TgdcPaymentOrder }

class function TgdcPaymentOrder.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_PAYMENTORDER;
end;

function TgdcPaymentOrder.GetGroupID: Integer;
begin
  Result := grPaymentOrder;
end;

class function TgdcPaymentOrder.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey = ' + IntToStr(BN_DOC_PAYMENTORDER);
end;

class function TgdcPaymentOrder.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmPaymentOrder';
end;

procedure TgdcPaymentOrder.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCPAYMENTORDER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPAYMENTORDER', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPAYMENTORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPAYMENTORDER',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPAYMENTORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('kind').Required := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPAYMENTORDER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPAYMENTORDER', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcPaymentOrder.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgPaymentOrder';
end;

{ TgdcDemandOrder }

class function TgdcDemandOrder.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_PAYMENTDEMANDPAYMENT;
end;

function TgdcDemandOrder.GetGroupID: Integer;
begin
  Result := grDemandOrder;
end;

class function TgdcDemandOrder.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.documenttypekey = ' + IntToStr(BN_DOC_PAYMENTDEMANDPAYMENT);
end;

class function TgdcDemandOrder.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDemandOrder';
end;

class function TgdcDemandOrder.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgDemandOrder';
end;

{ TgdcAdviceOfCollection }

class function TgdcAdviceOfCollection.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_ADVICEOFCOLLECTION;
end;

function TgdcAdviceOfCollection.GetGroupID: Integer;
begin
  Result := grAdviceOfCollection;
end;

class function TgdcAdviceOfCollection.GetRestrictCondition(
  const ATableName, ASubType: String): String;
begin
  Result := 'z.documenttypekey = ' + IntToStr(BN_DOC_ADVICEOFCOLLECTION);
end;

class function TgdcAdviceOfCollection.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAdviceOfCollection';
end;

class function TgdcAdviceOfCollection.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAdviceOfCollection';
end;

initialization
  RegisterGdcClass(TgdcPaymentDemand);
  RegisterGdcClass(TgdcPaymentOrder);
  RegisterGdcClass(TgdcDemandOrder);
  RegisterGdcClass(TgdcAdviceOfCollection);
  RegisterGdcClass(TgdcDestCode);

finalization
  UnregisterGdcClass(TgdcPaymentDemand);
  UnregisterGdcClass(TgdcPaymentOrder);
  UnregisterGdcClass(TgdcDemandOrder);
  UnregisterGdcClass(TgdcAdviceOfCollection);
  UnregisterGdcClass(TgdcDestCode);
end.
