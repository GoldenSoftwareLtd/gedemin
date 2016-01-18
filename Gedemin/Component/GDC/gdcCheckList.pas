
unit gdcCheckList;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form,
  dmDatabase_unit, gd_security_OperationConst, gdcClasses, DB,
  gdcPayment, gdcBaseBank, gdcBaseInterface;

type
  TgdcCheckList = class(TgdcBaseBank)
  private
    FDetailObject: TgdcBase;

    function GetDetail: TgdcBase;
    procedure SetDetail(const Value: TgdcBase);

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoBeforePost; override;
    procedure DoAfterOpen; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function ClassDocumentTypeKey: Integer; override;
    class function GetSubSetList: String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

  published
    //Хранит ссылку на детальный объект. Для окна редактирования.
    property DetailObject: TgdcBase read GetDetail write SetDetail;
  end;

  TgdcCheckListLine = class(TgdcDocument)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoAfterOpen; override;
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOnwer: TComponent); override;

    class function ClassDocumentTypeKey: Integer; override;
    class function GetSubSetList: String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  procedure Register;

implementation

uses
  IBSQL,                      gdc_dlgCheckList_unit,          gdc_dlgCheckListLine_unit,
  SysUtils,                   gd_security,                    gdc_frmMDHGRAccount_unit,
  gdc_frmCheckList_unit,      gd_ClassList;

const
  grCheckList = 2000206;

  procedure Register;
  begin
    RegisterComponents('gdcPayment', [
    TgdcCheckList,
    TgdcCheckListLine]);
  end;

{ TgdcCheckListLine }

procedure TgdcCheckListLine.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKLISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('insert into BN_CHECKLISTLINE ' +
  '  (ID, DOCUMENTKEY, CHECKLISTKEY, ACCOUNTKEY, ACCOUNTTEXT, SUMNCU, NUMBER) ' +
  'values ' +
  '  (:IDLINE, :DOCUMENTKEY, :CHECKLISTKEY, :ACCOUNTKEY, :ACCOUNTTEXT, :SUMNCU, :NUMBER)', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckListLine.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKLISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('update BN_CHECKLISTLINE ' +
    'set ' +
    '  ID = :IDLINE, ' +
    '  DOCUMENTKEY = :DOCUMENTKEY, ' +
    '  CHECKLISTKEY = :CHECKLISTKEY, ' +
    '  ACCOUNTKEY = :ACCOUNTKEY, ' +
    '  ACCOUNTTEXT = :ACCOUNTTEXT, ' +
    '  NUMBER = :NUMBER, ' +
    '  SUMNCU = :SUMNCU ' +
    'where ' +
    '  ID = :OLD_ID ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckListLine.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKLISTLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('ACCOUNTKEY').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckListLine.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKLISTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if State in [dsInsert, dsEdit] then
    begin
      q := TIBSQL(nil);
      try
        q.Database := Database;
        q.Transaction := ReadTransaction;

        q.SQL.Text := 'SELECT account FROM gd_companyaccount ca WHERE ca.id = :id';
        q.ParamByName('id').AsInteger := FieldByName('accountkey').AsInteger;
        q.ExecQuery;

        FieldByName('accounttext').AsString := q.FieldByName('account').AsString;
        FieldByName('idline').AsInteger := FieldByName('id').AsInteger;
        FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;
      finally
        q.Free;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckListLine.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_CHECKLIST;
end;

procedure TgdcCheckListLine._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKLISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if FgdcDataLink.Active then
  begin
    FieldByName('CHECKLISTKEY').AsInteger :=
      FgdcDataLink.DataSet.FieldByName(FgdcDataLink.MasterField).AsInteger;
    FieldByName('PARENT').Value :=
      FgdcDataLink.DataSet.FieldByName('DOCUMENTKEY').Value;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcCheckListLine.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCHECKLISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN bn_checklistline cll ON cll.documentkey = z.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCheckListLine.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCHECKLISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLISTLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLISTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLISTLINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    ', cll.id as idline, ' +
    ' cll.documentkey, ' +
    ' cll.number as numberline, ' +
    ' cll.checklistkey, ' +
    ' cll.accountkey, ' +
    ' cll.accounttext, ' +
    ' cll.sumncu ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckListLine.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByCheckList') then
    S.Add(' cll.checklistkey=:checklistkey ');
end;

constructor TgdcCheckListLine.Create(AnOnwer: TComponent);
begin
  inherited;
  RefreshMaster := True;
end;

class function TgdcCheckListLine.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByCheckList;';
end;

class function TgdcCheckListLine.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCheckListLine';
end;

{ TgdcCheckList }

procedure TgdcCheckList.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKLIST', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('insert into BN_CHECKLIST ' +
    '  (DOCUMENTKEY, ACCOUNTKEY, BANKKEY, OWNBANKTEXT, OWNBANKCITY, ' +
    '   OWNACCOUNT, OWNACCOUNTCODE, OWNCOMPTEXT, OWNTAXID, OWNCOUNTRY,' +
    '   BANKTEXT, BANKCITY, BANKCODE, AMOUNT, PROC, OPER, QUEUE, DESTCODEKEY, ' +
    '   DESTCODE, TERM, DESTINATION, BANKGROUP) '+
    ' values ' +
    '  (:DOCUMENTKEY, :ACCOUNTKEY, :BANKKEY, :OWNBANKTEXT, :OWNBANKCITY, ' +
    '   :OWNACCOUNT, :OWNACCOUNTCODE, :OWNCOMPTEXT, :OWNTAXID, :OWNCOUNTRY, ' +
    '  :BANKTEXT, :BANKCITY, :BANKCODE, :AMOUNT, :PROC, :OPER, :QUEUE, :DESTCODEKEY, ' +
    '   :DESTCODE, :TERM, :DESTINATION, :BANKGROUP)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckList.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCHECKLIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('update BN_CHECKLIST ' +
    ' set ' +
    '  DOCUMENTKEY = :DOCUMENTKEY, ' +
    '  ACCOUNTKEY = :ACCOUNTKEY, ' +
    '  BANKKEY = :BANKKEY, ' +
    '  OWNBANKTEXT = :OWNBANKTEXT, ' +
    '  OWNBANKCITY = :OWNBANKCITY, ' +
    '  OWNACCOUNT  = :OWNACCOUNT, ' +
    '  OWNACCOUNTCODE = :OWNACCOUNTCODE, ' +
    '  OWNCOMPTEXT = :OWNCOMPTEXT, ' +
    '  OWNTAXID = :OWNTAXID, ' +
    '  OWNCOUNTRY = :OWNCOUNTRY, ' +
    '  BANKTEXT = :BANKTEXT, ' +
    '  BANKCITY = :BANKCITY, ' +
    '  BANKCODE = :BANKCODE, ' +
    '  BANKGROUP = :BANKGROUP, ' +
    '  AMOUNT = :AMOUNT, ' +
    '  PROC = :PROC, ' +
    '  OPER = :OPER, ' +
    '  QUEUE = :QUEUE, ' +
    '  DESTCODEKEY = :DESTCODEKEY, ' +
    '  DESTCODE = :DESTCODE, ' +
    '  TERM = :TERM, ' +
    '  DESTINATION = :DESTINATION ' +
    'where ' +
    '  DOCUMENTKEY = :OLD_DOCUMENTKEY', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckList.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKLIST', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('ACCOUNTKEY').Required := True;
  FieldByName('BANKKEY').Required := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCheckList.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCHECKLIST', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
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
      q.Database := Database;
      q.Transaction := ReadTransaction;

      q.SQL.Text :=
        ' SELECT C.COUNTRY, COMP.FULLNAME, CC.TAXID ' +
        ' FROM GD_CONTACT C JOIN GD_COMPANY COMP ON C.ID = COMP.CONTACTKEY ' +
        ' JOIN GD_COMPANYCODE CC ON C.ID = CC.COMPANYKEY ' +
        ' WHERE C.ID = :Companykey ';

      q.Prepare;
      q.ParamByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
      q.ExecQuery;

      FieldByName('OWNTAXID').AsString := q.FieldByName('TAXID').AsString;
      FieldByName('OWNCOUNTRY').AsString := q.FieldByName('COUNTRY').AsString;
      FieldByName('OWNCOMPTEXT').AsString := q.FieldByName('FULLNAME').AsString;

      q.Close;
      q.SQL.Text :=
        ' SELECT COMP.FULLNAME, C.CITY, BANK.BANKCODE, BANK.BANKKEY, A.ACCOUNT ' +
        ' FROM GD_COMPANYACCOUNT A, GD_COMPANY COMP ' +
        ' JOIN GD_CONTACT C ON COMP.CONTACTKEY = C.ID ' +
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
      q.ParamByName('ID').AsInteger := FieldByName('BANKKEY').AsInteger;
      q.ExecQuery;

      FieldByName('BANKCITY').AsString := q.FieldByName('CITY').AsString;
      FieldByName('BANKCODE').AsString := q.FieldByName('BANKCODE').AsString;
      FieldByName('BANKTEXT').AsString := q.FieldByName('FULLNAME').AsString;

      FieldByName('DOCUMENTKEY').AsInteger := FieldByName('ID').AsInteger;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckList.ClassDocumentTypeKey: Integer;
begin
  Result := BN_DOC_CHECKLIST;
end;

function TgdcCheckList.GetDetail: TgdcBase;
begin
  Result := FDetailObject;
end;

function TgdcCheckList.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCHECKLIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' JOIN bn_checklist cl ON cl.documentkey = z.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCheckList.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCHECKLIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCHECKLIST', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCHECKLIST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCHECKLIST' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    ' , cl.* ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCHECKLIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCHECKLIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcCheckList.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAccount;';
end;

class function TgdcCheckList.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCheckList';
end;

procedure TgdcCheckList.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByAccount')  then
    S.Add(' cl.accountkey= :accountkey');
end;

procedure TgdcCheckList.SetDetail(const Value: TgdcBase);
begin
  FDetailObject := Value;
end;

class function TgdcCheckList.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCheckList';
end;

initialization
  with RegisterGdcClass(TgdcCheckList) as TgdBaseEntry do
  begin
    DistinctRelation := 'BN_CHECKLIST';
    GroupID := grCheckList;
  end;
  with RegisterGdcClass(TgdcCheckListLine) as TgdBaseEntry do
    DistinctRelation := 'BN_CHECKLISTLINE';

finalization
  UnregisterGdcClass(TgdcCheckList);
  UnregisterGdcClass(TgdcCheckListLine);
end.
