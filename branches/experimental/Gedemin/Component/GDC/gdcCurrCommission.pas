unit gdcCurrCommission;

interface

uses
  dmDataBase_unit, gdcClasses, gd_security_OperationConst,
  gd_createable_form, Classes, DB, Sysutils, gdcBase, gdcPayment, Forms,
  gdcBaseBank, gdcBaseInterface;

type
  TgdcCurrCommission = class(TgdcBaseBank)
  protected
    function GetGroupID: Integer; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoAfterOpen; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function ClassDocumentTypeKey: Integer; override;

    function GetCurrencyByAccount(AccountKey: Integer): String;
    procedure UpdateAdditional;
    procedure UpdateCorrAccount;
    procedure UpdateCorrCompany;

    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  IBSQL,                         gdc_dlgCurrCommission_unit,
  gd_security,                   gdc_frmCurrCommission_unit,
  gd_ClassList;

const
  grCurrCommission = 2000310;

procedure Register;
begin
  RegisterComponents('gdcPayment', [
    TgdcCurrCommission]);
end;

{ TgdcCurrCommission }

procedure TgdcCurrCommission.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCURRCOMMISSION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if not (sMultiple in BaseState) then
  begin
    q := CreateReadIBSQL;
    try
      /////////////////////////
      //  Данные по плательщику

      q.SQL.Text :=
        ' SELECT C.COUNTRY, COMP.FULLNAME, cc.TAXID FROM ' +
        ' GD_CONTACT C LEFT JOIN GD_COMPANY COMP ON C.ID = COMP.CONTACTKEY ' +
        ' LEFT JOIN GD_COMPANYCODE cc ON C.ID = cc.COMPANYKEY ' +
        ' WHERE C.ID = :Id ';

      q.Prepare;
      q.ParamByName('ID').AsInteger := IBLogin.CompanyKey;

      q.ExecQuery;

      FieldByName('OWNTAXID').AsString := q.FieldByName('TAXID').AsString;
      FieldByName('OWNCOUNTRY').AsString := q.FieldByName('COUNTRY').AsString;
      FieldByName('OWNCOMPTEXT').AsString := q.FieldByName('FULLNAME').AsString;

      q.Close;

      q.ParamByName('ID').AsString := FieldByName('CORRCOMPANYKEY').AsString;
      q.ExecQuery;

      if q.RecordCount > 0 then
      begin
        FieldByName('CORRTAXID').AsString := q.FieldByName('TAXID').AsString;
        FieldByName('CORRCOUNTRY').AsString := q.FieldByName('COUNTRY').AsString;
        FieldByName('CORRCOMPTEXT').AsString := q.FieldByName('FULLNAME').AsString;
      end
      else
      begin
        FieldByName('CORRTAXID').AsString := '';
        FieldByName('CORRCOUNTRY').AsString := '';
      end;

      q.Close;

      q.SQL.Text :=
        ' SELECT COMP.FULLNAME, C.CITY, BANK.BANKCODE, BANK.BANKKEY, A.ACCOUNT ' +
        ' FROM GD_COMPANYACCOUNT A, GD_COMPANY COMP JOIN GD_CONTACT C ON COMP.CONTACTKEY = C.ID ' +
        ' JOIN GD_BANK BANK ON COMP.CONTACTKEY = BANK.BANKKEY ' +
        ' WHERE A.ID = :Id AND COMP.CONTACTKEY = A.BANKKEY ';

      q.Prepare;
      q.ParamByName('ID').AsInteger := FieldByName('ACCOUNTKEY').AsInteger;
      q.ExecQuery;

      FieldByName('OWNBANKTEXT').AsString := q.FieldByName('FULLNAME').AsString;
      FieldByName('OWNBANKCITY').AsString := q.FieldByName('CITY').AsString;
      FieldByName('OWNACCOUNT').AsString := q.FieldByName('ACCOUNT').AsString;
      FieldByName('OWNACCOUNTCODE').AsString := q.FieldByName('BANKCODE').AsString;

      q.Close;

      ///////////////////////
      // Данные по получателю

      q.ParamByName('ID').AsInteger := FieldByName('CORRACCOUNTKEY').AsInteger;
      q.ExecQuery;

      FieldByName('CORRBANKTEXT').AsString := q.FieldByName('FULLNAME').AsString;
      FieldByName('CORRBANKCITY').AsString := q.FieldByName('CITY').AsString;
      FieldByName('CORRACCOUNT').AsString := q.FieldByName('ACCOUNT').AsString;
      FieldByName('CORRACCOUNTCODE').AsString := q.FieldByName('BANKCODE').AsString;

      q.Close;

      FieldByName('DOCUMENTKEY').AsInteger := FieldByName('ID').AsInteger;

      q.Close;
      q.SQL.Text := 'SELECT code FROM bn_destcode WHERE id = :id';
      q.ParamByName('id').AsInteger := FieldByName('destcodekey').AsInteger;
      q.ExecQuery;
      FieldByName('destcode').AsString := q.FieldByName('code').AsString;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommission.UpdateCorrAccount;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  q := CreateReadIBSQL(DidActivate);
  try
    q.SQL.Text := ' SELECT ca.id, ca.account, c.companyaccountkey FROM gd_company c JOIN gd_companyaccount ca ' +
      ' ON c.contactkey = ca.companykey WHERE c.contactkey = :contactkey';

    q.Prepare;                          
    q.ParamByName('contactkey').AsInteger := FieldByName('CORRCOMPANYKEY').AsInteger;

    q.ExecQuery;

    if not (State in [dsInsert, dsEdit]) then
      Edit;
      
    if q.RecordCount = 0 then
      FieldByName('CORRACCOUNTKEY').Clear
    else
    begin
      if FieldByName('CORRACCOUNTKEY').IsNull then
        FieldByName('CORRACCOUNTKEY').AsVariant := q.FieldByName('COMPANYACCOUNTKEY').AsVariant
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

          FieldByName('CORRACCOUNTKEY').AsInteger := q.FieldByName('ID').AsInteger;
        end;
      end;  
    end;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
  end;
end;

function TgdcCurrCommission.GetCurrencyByAccount(AccountKey: Integer): String;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  q := CreateReadIBSQL(DidActivate);
  try
    q.SQL.Text :=
      ' SELECT  C.name as currname, c.shortname as currshortname ' +
      ' FROM GD_COMPANYACCOUNT CA  ' +
      ' LEFT JOIN GD_CURR C ON C.ID = CA.CURRKEY WHERE CA.ID = ' + IntToStr(AccountKey);
    q.ExecQuery;
    Result := q.FieldByName('currname').AsString + ', ' + q.FieldByName('CURRSHORTNAME').AsString;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
  end;
end;

procedure TgdcCurrCommission.UpdateAdditional;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  if FieldByName('CORRCOMPANYKEY').IsNull then
  begin
    FieldByName('CorrCompText').Clear;
    Exit;
  end;

  q := CreateReadIBSQL(DidActivate);
  try
    q.SQL.Text :=
      ' SELECT comp.fullname, c.name FROM gd_company comp, gd_contact c ' +
      ' WHERE c.id = comp.contactkey and c.id = ' + FieldByName('CORRCOMPANYKEY').AsString;

    q.ExecQuery;

    if q.FieldByName('FullName').AsString = '' then
      FieldByName('CorrCompText').AsString := q.FieldByName('Name').AsString
    else
      FieldByName('CorrCompText').AsString := q.FieldByName('FullName').AsString;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;

    q.Free;
  end;
end;

procedure TgdcCurrCommission.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCOMMISSION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO bn_currcommission ' +
    '   (documentkey, accountkey, corrcompanykey, corraccountkey, ' +
    'owncomptext, ' +
    '   owntaxid, owncountry, corrcomptext, corrtaxid, ' +
    'corrcountry, corrbanktext, ' +
    '   corrbankcity, corraccount, corraccountcode, amount, ' +
    'destination, ownbanktext, ' +
    '   ownbankcity, ownaccount, ownaccountcode, ' +
    'kind, expenseaccount, midcorrbanktext, queue, destcode, ' +
    '  destcodekey) ' +
    ' VALUES ' +
    '  (:documentkey, :accountkey, :corrcompanykey, :corraccountkey, ' +
    ':owncomptext, ' +
    '   :owntaxid, :owncountry, :corrcomptext, :corrtaxid, '+
    ':corrcountry, :corrbanktext, ' +
    '   :corrbankcity, :corraccount, :corraccountcode, :amount, ' +
    ':destination, ' +
    '   :ownbanktext, :ownbankcity, :ownaccount, :ownaccountcode, ' +
    ':kind, :expenseaccount, :midcorrbanktext, :queue, :destcode,' +
    '   :destcodekey)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommission.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCOMMISSION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE bn_currcommission ' +
    ' SET ' +
    '  documentkey = :documentkey, ' +
    '  accountkey = :accountkey, ' +
    '  corrcompanykey = :corrcompanykey, ' +
    '  corraccountkey = :corraccountkey, ' +
    '  owncomptext = :owncomptext, ' +
    '  owntaxid = :owntaxid, ' +
    '  owncountry = :owncountry, ' +
    '  corrcomptext = :corrcomptext, ' +
    '  corrtaxid = :corrtaxid, ' +
    '  corrcountry = :corrcountry, ' +
    '  corrbanktext = :corrbanktext, ' +
    '  corrbankcity = :corrbankcity, ' +
    '  corraccount = :corraccount, ' +
    '  corraccountcode = :corraccountcode, ' +
    '  amount = :amount, ' +
    '  destination = :destination, ' +
    '  ownbanktext = :ownbanktext, ' +
    '  ownbankcity = :ownbankcity, ' +
    '  ownaccount = :ownaccount, ' +
    '  ownaccountcode = :ownaccountcode, ' +
    '  kind = :kind, ' +
    '  expenseaccount = :expenseaccount, ' +
    '  midcorrbanktext = :midcorrbanktext, ' +
    '  queue = :queue, ' +
    '  destcode = :destcode, ' +
    '  destcodekey = :destcodekey ' +
    'WHERE ' +
    '  documentkey = :old_documentkey', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommission.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCURRCOMMISSION', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
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
  FieldByName('kind').Required := True;
  FieldByName('expenseaccount').Required := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

class function TgdcCurrCommission.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRCOMMISION;
end;

function TgdcCurrCommission.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRCOMMISSION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM bn_currcommission cc ' +
    ' JOIN GD_COMPANYACCOUNT CA ON CA.ID = cc.ACCOUNTKEY ' +
    ' LEFT JOIN GD_DOCUMENT z ON z.ID = cc.DOCUMENTKEY ' +
    ' LEFT JOIN GD_CURR C ON C.ID = CA.CURRKEY ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrCommission.GetGroupID: Integer;
begin
  Result := grCurrCommission;
end;

function TgdcCurrCommission.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRCOMMISSION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
  ' , cc.*, C.name as currname, c.shortname as currshortname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommission.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  S.Add( ' z.documenttypekey = ' + IntToStr(DocumentTypeKey) + ' ');

  if HasSubSet('ByAccount') then
    S.Add(' cc.accountkey = :accountkey');
end;

procedure TgdcCurrCommission.UpdateCorrCompany;
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
       q.Free
     end;
   end;
end;

class function TgdcCurrCommission.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAccount;';
end;

class function TgdcCurrCommission.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCurrCommission';
end;

class function TgdcCurrCommission.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCurrCommission';
end;

initialization
  RegisterGdcClass(TgdcCurrCommission);

finalization
  UnregisterGdcClass(TgdcCurrCommission);
end.
