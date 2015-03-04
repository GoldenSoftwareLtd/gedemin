
unit gdcStatement;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form,
  dmDatabase_unit, IBSQL, contnrs, tr_Type_unit, gdcClasses,
  gdcBaseBank, DB, gdcBaseInterface;

type
  TgdcBaseLine = class(TgdcDocument)
  protected
    procedure DoAfterPost; override;
    procedure DoBeforePost; override;
    procedure DoAfterDelete; override;
    procedure DoBeforeInsert; override;

    procedure MakeEntry; override;

  public
    class function GetDocumentClassPart: TgdcDocumentClassPart; override;
    class function IsAbstractClass: Boolean; override;
    //Добавляет счет компании, указанной в выписке/картотеке, если это нужно
    //используется только на диалогах
    procedure SetCompanyAccount;
  end;

  TgdcBankCatalogue = class(TgdcBaseBank)
  protected
    function GetGroupID: Integer; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoAfterOpen; override;
    procedure CreateFields; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetDetailObject: TgdcDocument; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcBankCatalogueLine = class(TgdcBaseLine)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;
    procedure DoAfterOpen; override;
    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcBankStatement = class(TgdcBaseBank)
  protected
    function GetGroupID: Integer; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure DoAfterOpen; override;
    procedure CreateFields; override;

    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetDetailObject: TgdcDocument; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
 end;

  TgdcBaseStatementLine = class(TgdcBaseLine)
  private
    procedure SetCurrFieldReadOnly;

  protected
    procedure DoBeforeInsert; override;
    procedure DoBeforeEdit; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); override;

  public
    function DocumentTypeKey: Integer; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function IsAbstractClass: Boolean; override;
  end;

  TgdcBankStatementLine = class(TgdcBaseStatementLine)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function GetMasterObject: TgdcDocument; override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  SysUtils, JclStrings, gd_security, gd_security_operationconst,
  Dialogs, Controls, IBDataBase, Windows,

  gdc_dlgBankCatalogueLine_unit,
  gdc_dlgBankCatalogue_unit,
  gdc_dlgBankStatementLine_unit,
  gdc_dlgBankStatement_unit,

  gdc_frmMDHGRAccount_unit,
  gdc_frmCatalogue_unit,
  gdc_frmBankStatement_unit, gd_ClassList, gdcAcctEntryRegister,
  gdcContacts,
  gdcCurr
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  grBankStatement = 2000100;
  grBankCatalogue = 2000101;

procedure Register;
begin
  RegisterComponents('gsNew', [
    TgdcBankCatalogue,
    TgdcBankCatalogueLine,
    TgdcBankStatement,
    TgdcBankStatementLine
  ]);
end;

{ TgdcBankCatalogue }

procedure TgdcBankCatalogue.CustomModify;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKCATALOGUE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery('UPDATE bn_bankcatalogue '+
    ' SET ' +
    '     accountkey=:NEW_accountkey, ' +
    '     cataloguetype=:NEW_cataloguetype ' +
    '     WHERE documentkey=:OLD_ID ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankCatalogue.CustomInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKCATALOGUE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  // для таго, каб уставіць запіс у табліцу выпісак трэба
  // уставіць у табліцу дакументаў і ў, непасрэдна, табліцу
  // выпісак
  inherited;
  CustomExecQuery('INSERT INTO bn_bankcatalogue (documentkey, accountkey, cataloguetype ' +
      ') VALUES ' +
      '(:NEW_id, :NEW_accountkey, :NEW_cataloguetype ' +
      ') ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogue.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANKCATALOGUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    '  JOIN bn_bankcatalogue bc ON z.id = bc.documentkey ';
  if ARefresh then
    Result := Result + ' AND z.id = :NEW_ID';   
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogue.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANKCATALOGUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    ' , ' +
    '  bc.documentkey,' +
    '  bc.accountkey,' +
    '  bc.cataloguetype,' +
    '  bc.sumncu as sumncucat,' +
    '  bc.sumcurr as sumcurrcat ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogue.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_BANKCATALOGUE;
end;

procedure TgdcBankCatalogue.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKCATALOGUE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('sumncucat').ReadOnly := True;
  FieldByName('sumcurrcat').ReadOnly := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogue.GetGroupID: Integer;
begin
  Result := grBankCatalogue;
end;

procedure TgdcBankCatalogue.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByAccount') then
    S.Add(' bc.accountkey = :accountkey');
end;

class function TgdcBankCatalogue.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCatalogue';
end;

procedure TgdcBankCatalogue.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKCATALOGUE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('accountkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogue.GetDetailObject: TgdcDocument;
begin
  Result := TgdcBankCatalogueLine.Create(Owner);
end;

class function TgdcBankCatalogue.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgBankCatalogue';
end;

{ TgdcBankCatalogueLine }

constructor TgdcBankCatalogueLine.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify];
end;

function TgdcBankCatalogueLine.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_BANKCATALOGUE;
end;

procedure TgdcBankCatalogueLine._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKCATALOGUELINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('bankcataloguekey').AsInteger := FieldByName('parent').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogueLine.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANKCATALOGUELINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    '  LEFT JOIN bn_bankcatalogueline bcl ON z.id = bcl.documentkey ' +
    '  LEFT JOIN gd_company c ON c.contactkey = bcl.companykey ' +
    '  LEFT JOIN gd_document ld ON bcl.linkdocumentkey = ld.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankCatalogueLine.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKCATALOGUELINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  try
    CustomExecQuery( 'INSERT INTO bn_bankcatalogueline ' +
      '(documentkey, bankcataloguekey, companykey, linkdocumentkey, ' +
      ' sumncu, sumcurr, paymentdest, acceptdate, fine, account, bankcode, ' +
      ' docnumber, comment, reserved) ' +
      'VALUES ' +
      '(:NEW_ID, :NEW_bankcataloguekey, :NEW_companykeyline, ' +
      ' :NEW_linkdocumentkey, :NEW_sumnculine, :NEW_sumcurrline, ' +
      ' :NEW_paymentdest, :NEW_acceptdate, :NEW_fine, :NEW_account, :NEW_bankcode,' +
      ' :NEW_docnumber, :NEW_comment, :NEW_reservedline) ', Buff);
  except
    inherited CustomDelete(Buff);
    raise;
  end;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankCatalogueLine.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKCATALOGUELINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE bn_bankcatalogueline ' +
    'SET ' +
    '    bankcataloguekey=:NEW_BANKCATALOGUEKEY, ' +
    '    companykey=:NEW_companykeyline, ' +
    '    linkdocumentkey=:NEW_LINKDOCUMENTKEY, ' +
    '    sumncu=:NEW_SUMNCULINE, ' +
    '    sumcurr=:NEW_SUMCURRLINE, ' +
    '    paymentdest=:NEW_PAYMENTDEST, ' +
    '    acceptdate=:NEW_acceptdate, ' +
    '    fine=:NEW_FINE, ' +
    '    account=:NEW_ACCOUNT, ' +
    '    bankcode=:NEW_BANKCODE, ' +
    '    docnumber=:NEW_DOCNUMBER, ' +
    '    comment=:NEW_COMMENT, ' +
    '    reserved=:NEW_RESERVEDLINE ' +
    'WHERE documentkey=:OLD_DOCUMENTKEY ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcBankCatalogueLine.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANKCATALOGUELINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    '  , ' +
    '  bcl.documentkey,' +
    '  bcl.bankcataloguekey,' +
    '  bcl.companykey as companykeyline,' +
    '  c.fullname as companyname, ' +
    '  bcl.linkdocumentkey,' +
    '  bcl.sumncu as sumnculine,' +
    '  bcl.sumcurr as sumcurrline,' +
    '  bcl.paymentdest,' +
    '  bcl.acceptdate,' +
    '  bcl.fine,' +
    '  bcl.account,' +
    '  bcl.bankcode,' +
    '  bcl.docnumber,' +
    '  bcl.comment,' +
    '  bcl.reserved as reservedline, ' +
    '  ld.number as docnumberlink, ' +
    '  ld.documentdate as documentdatelink ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankCatalogueLine.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKCATALOGUELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcBankCatalogueLine.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCatalogue';
end;

procedure TgdcBankCatalogueLine.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKCATALOGUELINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKCATALOGUELINE', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKCATALOGUELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKCATALOGUELINE',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKCATALOGUELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('paymentdest').Required := True;
  FieldByName('account').Required := True;
  FieldByName('bankcode').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKCATALOGUELINE', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKCATALOGUELINE', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

class function TgdcBankCatalogueLine.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgBankCatalogueLine';
end;

{ TgdcBankStatement }

procedure TgdcBankStatement.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery('INSERT INTO bn_bankstatement (documentkey, accountkey, rate' +
      ') VALUES ' +
      '(:NEW_id, :NEW_accountkey, :NEW_rate ' +
      ') ', Buff); 
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatement.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery('UPDATE bn_bankstatement SET accountkey=:NEW_accountkey, ' +
    ' rate = :NEW_rate ' +
    ' WHERE documentkey=:OLD_documentkey ', Buff); 
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatement.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKSTATEMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('dsumncu').ReadOnly := True;
  FieldByName('dsumcurr').ReadOnly := True;
  FieldByName('csumncu').ReadOnly := True;
  FieldByName('csumcurr').ReadOnly := True;
  FieldByName('linecount').ReadOnly := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

function TgdcBankStatement.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_BANKSTATEMENT;
end;

function TgdcBankStatement.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANKSTATEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetFromClause(ARefresh) +
    '  JOIN bn_bankstatement bs ON z.id = bs.documentkey ';

  if ARefresh then
    Result := Result + ' AND z.id = :NEW_ID';

  Result := Result +
    '  LEFT JOIN gd_companyaccount ca ON ca.id = bs.accountkey ' +
    '  LEFT JOIN gd_curr c ON c.id = ca.currkey ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBankStatement.GetGroupID: Integer;
begin
  Result := grBankStatement;
end;

function TgdcBankStatement.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANKSTATEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
    Result :=
    inherited GetSelectClause +
    '  , ' +
    '  bs.documentkey,  ' +
    '  ca.account, ' +
    '  bs.accountkey,' +
    '  bs.dsumncu,' +
    '  bs.csumncu,' +
    '  bs.dsumcurr, ' +
    '  bs.csumcurr, ' +
    '  bs.linecount, ' +
    '  bs.rate, ' +
    '  ca.currkey as bscurrkey, ' +
    '  c.name as currname, ' +
    '  c.sign as currsign, ' +
    '  c.isncu ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatement.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByAccount') then
    S.Add('bs.accountkey = :accountkey ');
end;

class function TgdcBankStatement.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  {$IFDEF DEPARTMENT}
		 Result := 'Tgdc_frmBankStateDepartment';
  {$ELSE}
 		 Result := 'Tgdc_frmBankStatement';
  {$ENDIF}
end;

procedure TgdcBankStatement.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBANKSTATEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENT', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENT',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('accountkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENT', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

function TgdcBankStatement.GetDetailObject: TgdcDocument;
begin
  Result := TgdcBankStatementLine.Create(Owner);
end;

class function TgdcBankStatement.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgBankStatement';
end;

{ TgdcBaseStatementLine }

procedure TgdcBaseStatementLine.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASESTATEMENTLINE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASESTATEMENTLINE', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASESTATEMENTLINE',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  SetCurrFieldReadOnly;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASESTATEMENTLINE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASESTATEMENTLINE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseStatementLine.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASESTATEMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASESTATEMENTLINE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASESTATEMENTLINE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  SetCurrFieldReadOnly;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASESTATEMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASESTATEMENTLINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseStatementLine.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASESTATEMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASESTATEMENTLINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASESTATEMENTLINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (sLoadFromStream in BaseState) then
    exit;
  if not (sMultiple in BaseState) then
  begin
    // Проверяем на дебет и кредит
    if ((FieldByName('dsumncu').AsCurrency <> 0) or
      (FieldByName('dsumcurr').AsCurrency <> 0)) and
      ((FieldByName('csumncu').AsCurrency <> 0) or
      (FieldByName('csumcurr').AsCurrency <> 0))
    then
      raise Exception.Create('Вы ввели дебет и кредит одновременно!');

   // Проверяем на дебет и кредит
    if ((FieldByName('dsumncu').AsCurrency = 0) and
      (FieldByName('dsumcurr').AsCurrency = 0)) and
      ((FieldByName('csumncu').AsCurrency = 0) and
      (FieldByName('csumcurr').AsCurrency = 0))
    then
      raise Exception.Create('Не указана сумма выписки!');
  end;

 {!!!!! Сейчас на bn_bankstatementline стоит Check:
     (dsumncu IS NULL) and (csumncu > 0) OR
     (csumncu IS NULL) and (dsumncu > 0)
   Поэтому если в поле с суммой 0 - то очистим это поле
   Если Check уберут, здесь необходимо убрать очистку!!!!
  }
  if (FieldByName('dsumncu').AsCurrency = 0) and (not FieldByName('dsumncu').IsNull)
  then
    FieldByName('dsumncu').Clear;

  if (FieldByName('csumncu').AsCurrency = 0) and (not FieldByName('csumncu').IsNull)
  then
    FieldByName('csumncu').Clear;

  if (FieldByName('dsumcurr').AsCurrency = 0) and (not FieldByName('dsumcurr').IsNull)
  then
    FieldByName('dsumcurr').Clear;

  if (FieldByName('csumcurr').AsCurrency = 0) and (not FieldByName('csumcurr').IsNull)
  then
    FieldByName('csumcurr').Clear;

  inherited;

  if not (sMultiple in BaseState) then
  begin
    FieldByName('lineid').AsInteger := FieldByName('id').AsInteger;
    FieldByName('bankstatementkey').AsVariant := FieldByName('parent').AsVariant;
  end;

  if ((FieldByName('dsumcurr').AsCurrency > 0) and
    (FieldByName('dsumncu').AsCurrency = 0)) or
    ((FieldByName('csumcurr').AsCurrency > 0) and
    (FieldByName('csumncu').AsCurrency = 0))
  then
    raise EgdcIBError.Create('Если введена валютная сумма, то должна быть указана и сумма В НДЕ!');


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASESTATEMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASESTATEMENTLINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseStatementLine.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_BANKSTATEMENT;
end;

procedure TgdcBaseStatementLine._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASESTATEMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASESTATEMENTLINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASESTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASESTATEMENTLINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASESTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('bankstatementkey').AsInteger := FieldByName('parent').AsInteger;
  FieldByName('lineid').AsInteger := FieldByName('id').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASESTATEMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASESTATEMENTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseStatementLine.SetCurrFieldReadOnly;
var
  qry: TIBSQL;
begin
  if Assigned(MasterSource) and (MasterSource.DataSet is TgdcBankStatement) then
  begin
    if (MasterSource.DataSet.FieldByName('bscurrkey').IsNull) or
      (MasterSource.DataSet.FieldByName('isncu').AsInteger <> 0)then
    begin
      FieldByName('dsumcurr').ReadOnly := True;
      FieldByName('csumcurr').ReadOnly := True;
    end else
    begin
      FieldByName('dsumcurr').ReadOnly := False;
      FieldByName('csumcurr').ReadOnly := False;
    end;
  end else
  begin
    qry := CreateReadIBSQL;
    try
      qry.SQL.Text := 'SELECT ca.currkey, c.isncu ' +
      ' FROM bn_bankstatement bs  ' +
      ' LEFT JOIN gd_companyaccount ca  ON ca.id = bs.accountkey' +
      ' LEFT JOIN gd_curr c ON c.id = ca.currkey ' +
      ' WHERE bs.documentkey = :bankstatementkey ';
      qry.ParamByName('bankstatementkey').AsInteger :=
        FieldByName('bankstatementkey').AsInteger;
      qry.ExecQuery;
      if (qry.FieldByName('currkey').IsNull) or
        (qry.FieldByName('isncu').AsShort = 1)then
      begin
        FieldByName('dsumcurr').ReadOnly := True;
        FieldByName('csumcurr').ReadOnly := True;
      end else
      begin
        FieldByName('dsumcurr').ReadOnly := False;
        FieldByName('csumcurr').ReadOnly := False;
      end;
    finally
      qry.Free;
    end;
  end;
end;

class function TgdcBaseStatementLine.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmBankStatement';
end;

procedure TgdcBaseStatementLine.InternalSetFieldData(Field: TField;
  Buffer: Pointer);
begin
  inherited;

  if FDataTransfer then
    exit;

  if (Field.FieldName = 'CSUMCURR') and (Field.AsCurrency > 0) then
  begin
    FieldByName('dsumncu').Clear;
    FieldByName('dsumcurr').Clear;
  end else

  if (Field.FieldName = 'CSUMNCU') and (Field.AsCurrency > 0) then
  begin
    FieldByName('dsumncu').Clear;
    FieldByName('dsumcurr').Clear;
  end else

  if (Field.FieldName = 'DSUMCURR') and (Field.AsCurrency > 0) then
  begin
    FieldByName('csumncu').Clear;
    FieldByName('csumcurr').Clear;
  end else

  if (Field.FieldName = 'DSUMNCU') and (Field.AsCurrency > 0) then
  begin
    FieldByName('csumncu').Clear;
    FieldByName('csumcurr').Clear;
  end;
end;

class function TgdcBaseStatementLine.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcBaseStatementLine');
end;

{ TgdcBaseLine }

procedure TgdcBaseLine.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASELINE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASELINE', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASELINE',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FgdcDataLink.Active then
    FgdcDataLink.DataSet.Refresh;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASELINE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASELINE', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseLine.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASELINE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASELINE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASELINE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {Чтобы обновлялись данные мастера, которые изменились на триггере}
  if FgdcDataLink.Active then
  begin
    case FgdcDataLink.DataSet.State of
      dsBrowse: FgdcDataLink.DataSet.Refresh;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASELINE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASELINE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseLine.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASELINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASELINE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASELINE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(MasterSource) and Assigned(MasterSource.DataSet) and
    (MasterSource.DataSet.State in dsEditModes) then
  begin
    MasterSource.DataSet.Post;
    MasterSource.DataSet.Edit;
  end;
  
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASELINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASELINE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseLine.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASELINE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASELINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASELINE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASELINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('companykeyline').IsNull then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT ac.companykey, b.bankbranch FROM gd_companyaccount ac ' +
          ' LEFT JOIN gd_bank b ON ac.bankkey = b.bankkey ' +
          ' LEFT JOIN gd_contact c ON ac.companykey = c.id ' +
          ' WHERE ac.account = :account and b.bankcode = :code ' +
          ' AND (c.disabled IS NULL OR c.disabled = 0) AND (ac.disabled IS NULL OR ac.disabled = 0)' ;
        ibsql.ParamByName('account').AsString := FieldByName('account').AsString;
        ibsql.ParamByName('code').AsString := FieldByName('bankcode').AsString;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          ibsql.Next;
          if ibsql.RecordCount = 1 then
          begin
            FieldByName('companykeyline').AsInteger := ibsql.FieldByName('companykey').AsInteger;
            if FieldByName('bankbranch').AsString <> ibsql.FieldByName('bankbranch').AsString then
              FieldByName('bankbranch').AsString := ibsql.FieldByName('bankbranch').AsString;
          end;
        end;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end
    else if (FieldByName('account').AsString = '') and
         (FieldByName('bankcode').AsString = '')
    then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT ac.account, b.bankcode, b.bankbranch ' +
          ' FROM gd_company c ' +
          ' LEFT JOIN gd_companyaccount ac ON c.companyaccountkey = ac.id ' +
          ' LEFT JOIN gd_bank b ON ac.bankkey = b.bankkey ' +
          ' WHERE c.contactkey = :companykey';
        ibsql.ParamByName('companykey').AsInteger := FieldByName('companykeyline').AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          FieldByName('account').AsString := ibsql.FieldByName('account').AsString;
          FieldByName('bankcode').AsString := ibsql.FieldByName('bankcode').AsString;
          FieldByName('bankbranch').AsString := ibsql.FieldByName('bankbranch').AsString;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASELINE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseLine.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine;
end;

class function TgdcBaseLine.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcBaseLine');
end;

procedure TgdcBaseLine.MakeEntry;
begin
  (gdcAcctEntryRegister as TgdcAcctEntryRegister).Description := FieldByName('comment').AsString;
  inherited;
end;

procedure TgdcBaseLine.SetCompanyAccount;
var
  DidActivate: Boolean;
  gdcBank: TgdcBank;
  gdcAccount: TgdcAccount;
  BankID: Integer;
  LastCompanyName: String;
  ibsql: TIBSQL;
  CountCompany: Integer;

  procedure SetCompanyAccountInternal;
  begin
    gdcBank := TgdcBank.Create(Self);
    gdcAccount := TgdcAccount.Create(Self);
    try
      gdcBank.Transaction := Transaction;
      gdcBank.ReadTransaction := Transaction;

      gdcBank.ExtraConditions.Text := 'b.bankcode = ''' + FieldByName('bankcode').AsString + '''';
      gdcBank.Open;
      if gdcBank.RecordCount = 0 then
      begin
        gdcBank.Insert;
        gdcBank.FieldByName('bankcode').AsString := FieldByName('bankcode').AsString;
        if gdcBank.EditDialog then
          BankID := gdcBank.ID
        else
          BankID := -1;
      end else
        BankID := gdcBank.ID;
        
      if BankID > 0 then
      begin
        gdcAccount.Transaction := Transaction;
        gdcAccount.ReadTransaction := Transaction;
        gdcAccount.IgnoryQuestion := True;
        gdcAccount.Open;
        gdcAccount.Insert;
        gdcAccount.FieldByName('account').AsString := FieldByName('account').AsString;
        gdcAccount.FieldByName('bankkey').AsInteger := BankID;
        gdcAccount.FieldByName('companykey').AsInteger := FieldByName('companykeyline').AsInteger;
        gdcAccount.Post;
      end;

    finally
      gdcBank.Free;
      gdcAccount.Free;
    end;

  end;


begin
{Если у такой компании нет расчетного счета и банка, подставим их}
  if (FieldByName('account').AsString > '') and (FieldByName('bankcode').AsString > '')
    and (FieldByName('companykeyline').AsInteger > 0) then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      DidActivate := False;
      try
        DidActivate := ActivateTransaction;
        ibsql.Transaction := Transaction;

        ibsql.SQL.Text := 'SELECT * ' +
          ' FROM gd_companyaccount ca ' +
          ' LEFT JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
          ' WHERE b.bankcode = :bc AND ca.account = :account ' +
          ' AND ca.companykey = :companykey ';
        ibsql.ParamByName('bc').AsString := FieldByName('bankcode').AsString;
        ibsql.ParamByName('account').AsString := FieldByName('account').AsString;
        ibsql.ParamByName('companykey').AsInteger := FieldByName('companykeyline').AsInteger;
        ibsql.ExecQuery;

        if ibsql.RecordCount = 0 then
        begin
          ibsql.Close;
          ibsql.SQL.Text := 'SELECT c.name ' +
            ' FROM gd_companyaccount ca ' +
            ' LEFT JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
            ' LEFT JOIN gd_contact c ON ca.companykey = c.id ' +
            ' WHERE b.bankcode = :bc AND ca.account = :account ' +
            ' AND (ca.disabled IS NULL OR ca.disabled = 0) ' +
            ' AND (c.disabled IS NULL OR c.disabled = 0) ' +
            ' AND ca.companykey <> :companykey ';

          ibsql.ParamByName('bc').AsString := FieldByName('bankcode').AsString;
          ibsql.ParamByName('account').AsString := FieldByName('account').AsString;
          ibsql.ParamByName('companykey').AsInteger := FieldByName('companykeyline').AsInteger;
          ibsql.ExecQuery;

          LastCompanyName := '';
          {Пробежимся по записям и проверим:
            Дублируется ли счет с кем-нибудь еще}
          CountCompany := 0;
          while not ibsql.Eof and (CountCompany < 4) do
          begin
            LastCompanyName := LastCompanyName + ibsql.FieldByName('name').AsString + #13#10;
            CountCompany := CountCompany + 1;
            ibsql.Next;
          end;

          if (ibsql.RecordCount > 0) then
          begin
            if MessageBox(0, PChar('Р/с ' + FieldByName('account').AsString +
              ' код банка ' + FieldByName('bankcode').AsString +
              ' существует уже у следующих компаний: ' + #13#10 +
              LastCompanyName +
              'Подставить его введенной компании ' + FieldByName('companyname').AsString + '?'),
              'Внимание', MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES
            then
              SetCompanyAccountInternal;
          end else
          begin
            SetCompanyAccountInternal;
          end;

        end;
        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      except
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

{ TgdcBankStatementLine }

procedure TgdcBankStatementLine.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  try
    CustomExecQuery  ('INSERT INTO bn_bankstatementline (id, documentkey, bankstatementkey, companykey, ' +
      'contractorkey, dsumncu, dsumcurr, csumncu, csumcurr, paymentmode, operationtype, ' +
      'account, bankcode, bankbranch, docnumber, comment, accountkey) ' +
      'VALUES (:NEW_lineid, :NEW_documentkey, :NEW_bankstatementkey, :NEW_companykeyline, ' +
      ':NEW_contractorkey, :NEW_dsumncu, :NEW_dsumcurr, :NEW_csumncu, :NEW_csumcurr, :NEW_paymentmode, :NEW_operationtype, ' +
      ':NEW_account, :NEW_bankcode, :NEW_bankbranch, :NEW_docnumber, :NEW_comment, :NEW_accountkey) ', Buff);
  except
    inherited CustomDelete(Buff);
    raise;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBankStatementLine.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCBANKSTATEMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CustomExecQuery ('UPDATE bn_bankstatementline SET documentkey=:NEW_documentkey, bankstatementkey=:NEW_BANKSTATEMENTKEY, ' +
    'companykey=:NEW_companykeyline, contractorkey=:NEW_contractorkey, dsumncu=:DSUMNCU, ' +
    'dsumcurr=:NEW_DSUMCURR, csumncu=:NEW_CSUMNCU, csumcurr=:NEW_CSUMCURR, ' +
    'paymentmode=:NEW_PAYMENTMODE, operationtype=:NEW_OPERATIONTYPE, account=:NEW_ACCOUNT, ' +
    'bankcode=:NEW_BANKCODE, bankbranch=:NEW_BANKBRANCH, docnumber=:NEW_DOCNUMBER, comment=:NEW_COMMENT, ' +
    'accountkey = :NEW_accountkey ' +
    'WHERE id=:OLD_lineid ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;


class function TgdcBankStatementLine.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgBankStatementLine'; 
end;

function TgdcBankStatementLine.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBANKSTATEMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=  inherited GetFromClause(ARefresh) +
    '  LEFT JOIN bn_bankstatementline bsl ON' +
    '    z.id = bsl.id ' +
    '  LEFT JOIN gd_document dbsl ON ' +
    '    dbsl.id = bsl.documentkey ' +
    '  LEFT JOIN gd_contact cc ON '+
    '    bsl.companykey = cc.id '+
    '  LEFT JOIN gd_contact ctr ON '+
    '    bsl.contractorkey = ctr.id '+
    '  LEFT JOIN gd_bank bn ON ' +
    '    bn.bankcode = bsl.bankcode and ((bn.bankbranch = bsl.bankbranch) or (bn.bankbranch IS NULL and bsl.bankbranch IS NULL)) ' +
    '  LEFT JOIN gd_contact cb ON '+
    '    cb.id = bn.bankkey ' +
    '  LEFT JOIN ac_transaction t ON ' +
    '    t.id = z.transactionkey ' +
    '  LEFT JOIN ac_account ac ON ' +
    '    ac.id = bsl.accountkey ';
    FSQLSetup.Ignores.AddAliasName('ac');
    FSQLSetup.Ignores.AddAliasName('dbsl');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcBankStatementLine.GetMasterObject: TgdcDocument;
begin
  Result := TgdcBankStatement.Create(Owner);
end;

function TgdcBankStatementLine.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBANKSTATEMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBANKSTATEMENTLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBANKSTATEMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBANKSTATEMENTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBANKSTATEMENTLINE' then
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
    '  ctr.name as contractorname, ' +
    '  t.name as TransactionName, ' +
    '  bsl.contractorkey,' +
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
    '  bsl.bankbranch, ' +
    '  bsl.accountkey, ' +
    '  ac.alias, ' +
    '  cb.name as bankname, ' +
    '  dbsl.number as docnumberlink, ' +
    '  dbsl.documentdate as documentdatelink ' + #13#10;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBANKSTATEMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBANKSTATEMENTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcBaseLine);
  RegisterGdcClass(TgdcBankCatalogue);
  RegisterGdcClass(TgdcBankCatalogueLine);
  RegisterGdcClass(TgdcBankStatement);
  RegisterGdcClass(TgdcBankStatementLine);

finalization
  UnRegisterGdcClass(TgdcBaseLine);
  UnRegisterGdcClass(TgdcBankCatalogue);
  UnRegisterGdcClass(TgdcBankCatalogueLine);
  UnRegisterGdcClass(TgdcBankStatement);
  UnRegisterGdcClass(TgdcBankStatementLine);
end.

