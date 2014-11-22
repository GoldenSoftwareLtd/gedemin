
unit gdcCurrSellContract;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcClasses, gd_createable_form, gd_security,
  gdcBaseInterface;

type
  TgdcCurrDocument  = class(TgdcDocument)
  protected
    procedure KillRequired;
    procedure DoAfterOpen; override;
    procedure _DoOnNewRecord; override;
  end;

  TgdcCurrSellContract = class(TgdcCurrDocument)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;

    function GetGroupID: Integer; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcCurrCommissSell = class(TgdcCurrDocument)
  private
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;

    function GetGroupID: Integer; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcCurrListAllocation = class(TgdcCurrDocument)
  private
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;

    function GetGroupID: Integer; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcCurrBuyContract = class(TgdcCurrDocument)
  private
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    function GetGroupID: Integer; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcCurrConvContract = class(TgdcCurrDocument)
  private
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    function CreateDialogForm: TCreateableForm; override;
    function GetGroupID: Integer; override;

  public
    function DocumentTypeKey: Integer; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gd_security_operationconst, dmDataBase_unit, gd_ClassList,

  bn_frmCurrCommissSell_unit,
  bn_frmCurrBuyContract_unit,
  bn_frmCurrSellContract_unit,
  bn_frmCurrConvContract_unit,
  bn_frmCurrListAllocation_unit,

  bn_dlgCurrSellContract_unit,
  bn_dlgCurrCommissSell_unit,
  bn_dlgCurrBuyContract_unit,
  bn_dlgCurrListAllocation_unit,
  bn_dlgCurrConvContract_unit;

const
  GD_RP_CURRSELLCONTRACT = 2000311;
  GD_RP_CURRCOMMISSSELL = 2000312;
  GD_RP_CURRLISTALLOCATION = 2000313;
  GD_RP_CURRBUYCONTRACT = 2000314;
  GD_RP_CURRCONVCONTRACT = 2000315;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcCurrSellContract, TgdcCurrCommissSell,
    TgdcCurrListAllocation, TgdcCurrBuyContract, TgdcCurrConvContract]);
end;

{ TgdcCurrSellContract }

function TgdcCurrSellContract.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRSELLCONTRACT;
end;

function TgdcCurrSellContract.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCURRSELLCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRSELLCONTRACT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRSELLCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRSELLCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRSELLCONTRACT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgd_dlgCurrSellContract.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRSELLCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRSELLCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrSellContract.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRSELLCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRSELLCONTRACT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRSELLCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRSELLCONTRACT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRSELLCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO bn_currsellcontract (documentkey, currkey, amount, ' +
        'minrate, bankkey, bankaccountkey, ownaccountkey, banktext, bankcode, owncomptext, ' +
        'owntaxid, owncountry, ownaccount) VALUES ' +
        '(:NEW_documentkey, :NEW_currkey, :NEW_amount, ' +
        ':NEW_minrate, :NEW_bankkey, :NEW_bankaccountkey, :NEW_ownaccountkey, :NEW_banktext, ' +
        ':NEW_bankcode, :NEW_owncomptext, ' +
        ':NEW_owntaxid, :NEW_owncountry, :NEW_ownaccount) ', Buff);


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRSELLCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRSELLCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrSellContract.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRSELLCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRSELLCONTRACT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRSELLCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRSELLCONTRACT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRSELLCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CustomExecQuery('UPDATE bn_currsellcontract SET ' +
      'currkey =        :NEW_currkey,        ' +
      'amount =         :NEW_amount,         ' +
      'minrate =        :NEW_minrate,        ' +
      'bankkey =        :NEW_bankkey,        ' +
      'bankaccountkey = :NEW_bankaccountkey, ' +
      'ownaccountkey =  :NEW_ownaccountkey,  ' +
      'banktext =       :NEW_banktext,       ' +
      'bankcode =       :NEW_bankcode,       ' +
      'owncomptext =    :NEW_owncomptext,    ' +
      'owntaxid =       :NEW_owntaxid,       ' +
      'owncountry =     :NEW_owncountry,     ' +
      'ownaccount =     :NEW_ownaccount      ' +
      ' WHERE documentkey = :OLD_documentkey ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRSELLCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRSELLCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrSellContract.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRSELLCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRSELLCONTRACT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRSELLCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRSELLCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRSELLCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) +
    ' RIGHT JOIN BN_CURRSELLCONTRACT CC ON z.id = cc.documentkey ' +
    '  LEFT JOIN GD_CURR C ON C.ID = CC.CURRKEY ' +
    '  LEFT JOIN GD_COMPANYACCOUNT A ON CC.OWNACCOUNTKEY = A.ID ' +
    '  LEFT JOIN GD_COMPANYACCOUNT AB ON CC.BANKACCOUNTKEY = AB.ID ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRSELLCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRSELLCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrSellContract.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRSELLCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRSELLCONTRACT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRSELLCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRSELLCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRSELLCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    '  , CC.*, C.name as currname, c.shortname as currshortname, ' +
    '  A.ACCOUNT AS CURRACCOUNT, AB.ACCOUNT AS NCUACCOUNT ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRSELLCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRSELLCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrSellContract.GetGroupID: Integer;
begin
  Result := GD_RP_CURRSELLCONTRACT {2000311};
end;

class function TgdcCurrSellContract.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tbn_frmCurrSellContract';
end;

{ TgdcCurrCommissSell }

function TgdcCurrCommissSell.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRCOMMISSSELL; 
end;

function TgdcCurrCommissSell.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCURRCOMMISSSELL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSSELL', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSSELL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSSELL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSSELL' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgd_dlgCurrCommissSell.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSSELL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSSELL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommissSell.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCOMMISSSELL', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSSELL', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSSELL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSSELL',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSSELL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO bn_currcommisssell (documentkey, percent, amountcurr, ' +
                  'accountkey, timeint, compercent, toaccountkey, ' +
                  'tocurraccountkey, datevalid, bankkey) VALUES ' +
      '(:NEW_documentkey, :NEW_percent, :NEW_amountcurr, :NEW_accountkey, ' +
      ':NEW_timeint, :NEW_compercent, :NEW_toaccountkey, :NEW_tocurraccountkey, ' +
      ':NEW_datevalid, :NEW_bankkey) ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSSELL', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSSELL', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrCommissSell.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCOMMISSSELL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSSELL', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSSELL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSSELL',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSSELL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE bn_currsellcontract SET ' +
      'percent          = :NEW_percent, ' +
      'amountcurr       = :NEW_amountcurr, ' +
      'accountkey       = :NEW_accountkey, ' +
      'timeint          = :NEW_timeint, ' +
      'compercent       = :NEW_compercent, ' +
      'toaccountkey     = :NEW_toaccountkey, ' +
      'tocurraccountkey = :NEW_tocurraccountkey, ' +
      'datevalid        = :NEW_datevalid ' +
      ' WHERE documentkey = :OLD_documentkey ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSSELL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSSELL', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrCommissSell.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRCOMMISSSELL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSSELL', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSSELL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSSELL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSSELL' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh) + 
    '   RIGHT JOIN bn_currcommisssell cc ON z.id = cc.documentkey ' +
    '   JOIN gd_companyaccount a ON cc.accountkey = a.id ' +
    '   JOIN gd_bank b ON a.bankkey = b.bankkey ' +
    '   JOIN gd_contact bc ON b.bankkey = bc.id ' +
    '   JOIN gd_companyaccount toa ON cc.toaccountkey = toa.id ' +
    '   JOIN gd_bank tob ON toa.bankkey = tob.bankkey ' +
    '   JOIN gd_contact tobc ON tob.bankkey = tobc.id ' +
    '   JOIN gd_companyaccount tocurra ON cc.tocurraccountkey = tocurra.id ' +
    '   JOIN gd_bank tocurrb ON tocurra.bankkey = tocurrb.bankkey ' +
    '   JOIN gd_contact tocurrbc ON tob.bankkey = tocurrbc.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSSELL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSSELL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrCommissSell.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRCOMMISSSELL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCOMMISSSELL', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCOMMISSSELL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCOMMISSSELL',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCOMMISSSELL' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetSelectClause +
    '   ,cc.* , bc.name, b.bankcode, b.bankmfo, a.account, ' +
    '   tobc.name as tobankname, tob.bankcode as tobankcode, ' +
    '   tob.bankmfo as tobankmfo, toa.account as toaccount, '  +
    '   tocurrbc.name as tocurrbankname, tocurrb.bankcode as tocurrbankcode, ' +
    '   tocurrb.bankmfo as tocurrbankmfo, tocurra.account as tocurraccount ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCOMMISSSELL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCOMMISSSELL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrCommissSell.GetGroupID: Integer;
begin
  Result := GD_RP_CurrCommissSell; {2000312}
end;

class function TgdcCurrCommissSell.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tbn_frmCurrCommissSell';
end;

{ TgdcCurrListAllocation }

function TgdcCurrListAllocation.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRLISTALLOCATION;
end;

function TgdcCurrListAllocation.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCURRLISTALLOCATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRLISTALLOCATION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRLISTALLOCATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRLISTALLOCATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRLISTALLOCATION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgd_dlgCurrListAllocation.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRLISTALLOCATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRLISTALLOCATION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrListAllocation.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRLISTALLOCATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRLISTALLOCATION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRLISTALLOCATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRLISTALLOCATION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRLISTALLOCATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('INSERT INTO bn_currlistallocation ' +
      '( ' +
      'documentkey, ' +
      'currkey, ' +
      'amountcurr, ' +
      'dateenter, ' +
      'accountkey, ' +
      'amountnotpay, ' +
      'amountpay, ' +
      'amountpayed, ' +
      'basetext ' +
      ') VALUES ' +
      '( ' +
      ':NEW_documentkey, ' +
      ':NEW_currkey, ' +
      ':NEW_amountcurr, ' +
      ':NEW_dateenter, ' +
      ':NEW_accountkey, ' +
      ':NEW_amountnotpay, ' +
      ':NEW_amountpay, ' +
      ':NEW_amountpayed, ' +
      ':NEW_basetext ' +
      ') ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRLISTALLOCATION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRLISTALLOCATION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrListAllocation.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRLISTALLOCATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRLISTALLOCATION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRLISTALLOCATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRLISTALLOCATION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRLISTALLOCATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery('UPDATE bn_currlistallocation SET ' +
      'currkey      = :NEW_currkey, ' +
      'amountcurr   = :NEW_amountcurr, ' +
      'dateenter    = :NEW_dateenter, ' +
      'accountkey   = :NEW_accountkey, ' +
      'amountnotpay = :NEW_amountnotpay, ' +
      'amountpay    = :NEW_amountpay, ' +
      'amountpayed  = :NEW_amountpayed, ' +
      'basetext     = :NEW_basetext ' +
      ' WHERE documentkey = :OLD_documentkey ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRLISTALLOCATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRLISTALLOCATION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrListAllocation.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRLISTALLOCATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRLISTALLOCATION', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRLISTALLOCATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRLISTALLOCATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRLISTALLOCATION' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '  RIGHT JOIN bn_currlistallocation cc ON cc.documentkey = z.id ' +
    '  JOIN gd_companyaccount a ON cc.accountkey = a.id ' +
    '  JOIN gd_bank b ON a.bankkey = b.bankkey ' +
    '  JOIN gd_contact bc ON b.bankkey = bc.id ' +
    '  LEFT JOIN gd_curr curr ON cc.currkey = curr.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRLISTALLOCATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRLISTALLOCATION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrListAllocation.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRLISTALLOCATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRLISTALLOCATION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRLISTALLOCATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRLISTALLOCATION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRLISTALLOCATION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    ', cc.*, ' +
    ' curr.shortname as shortcurrname, curr.name as currname, ' +
    ' a.Account, b.bankcode, b.bankmfo, bc.name as bankname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRLISTALLOCATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRLISTALLOCATION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrListAllocation.GetGroupID: Integer;
begin
  Result := GD_RP_CURRLISTALLOCATION;{2000313}
end;

class function TgdcCurrListAllocation.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tbn_frmCurrListAllocation';
end;

{ TgdcCurrBuyContract }

function TgdcCurrBuyContract.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCURRBUYCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRBUYCONTRACT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRBUYCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRBUYCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRBUYCONTRACT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgd_dlgCurrBuyContract.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRBUYCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRBUYCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrBuyContract.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRBUYCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRBUYCONTRACT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRBUYCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRBUYCONTRACT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRBUYCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

    CustomExecQuery('INSERT INTO bn_currbuycontract ' +
        '( ' +
        'documentkey, ' +
        'currkey, ' +
        'amountcurr, ' +
        'maxrate, ' +
        'amountncu, ' +
        'percent, ' +
        'destination, ' +
        'accountkey, ' +
        'corrcompkey ' +
        ') VALUES ' +
        '( ' +
        ':NEW_documentkey, ' +
        ':NEW_currkey, ' +
        ':NEW_amountcurr, ' +
        ':NEW_maxrate, ' +
        ':NEW_amountncu, ' +
        ':NEW_percent, ' +
        ':NEW_destination, ' +
        ':NEW_accountkey, ' +
        ':NEW_corrcompkey ' +
        ') ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRBUYCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRBUYCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrBuyContract.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRBUYCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRBUYCONTRACT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRBUYCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRBUYCONTRACT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRBUYCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

    CustomExecQuery('UPDATE bn_currbuycontract SET ' +
        'currkey     = :NEW_currkey , ' +
        'amountcurr  = :NEW_amountcurr , ' +
        'maxrate     = :NEW_maxrate , ' +
        'amountncu   = :NEW_amountncu , ' +
        'percent     = :NEW_percent , ' +
        'destination = :NEW_destination , ' +
        'accountkey  = :NEW_accountkey, ' +
        'corrcompkey = :NEW_corrcompkey  ' +
        ' WHERE documentkey = :OLD_documentkey ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRBUYCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRBUYCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrBuyContract.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRBUYCONTRACT;
end;

function TgdcCurrBuyContract.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRBUYCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRBUYCONTRACT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRBUYCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRBUYCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRBUYCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '   RIGHT JOIN bn_currbuycontract cc ON cc.documentkey = z.id ' +
    '   LEFT JOIN gd_companyaccount a ON cc.accountkey = a.id ' +
    '   LEFT JOIN gd_bank b ON a.bankkey = b.bankkey ' +
    '   LEFT JOIN gd_contact bc ON b.bankkey = bc.id ' +
    '   LEFT JOIN gd_contact cor ON cc.corrcompkey = cor.id ' +
    '   LEFT JOIN gd_curr curr ON cc.currkey = curr.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRBUYCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRBUYCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrBuyContract.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRBUYCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRBUYCONTRACT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRBUYCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRBUYCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRBUYCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause + 
    '   , cc.*, ' +
    '   a.Account, b.bankcode, b.bankmfo, bc.name as bankname, ' +
    '   cor.Name as corrname, cor.country as corrcountry, cor.city as corrcity, ' +
    '   curr.Name as currname, curr.ShortName as currshortname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRBUYCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRBUYCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrBuyContract.GetGroupID: Integer;
begin
  Result := GD_RP_CURRBUYCONTRACT;{2000314}
end;

class function TgdcCurrBuyContract.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tbn_frmCurrBuyContract';
end;

{ TgdcCurrConvContract }

function TgdcCurrConvContract.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCCURRCONVCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCONVCONTRACT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCONVCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCONVCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCONVCONTRACT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgd_dlgCurrConvContract.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCONVCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCONVCONTRACT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrConvContract.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCONVCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCONVCONTRACT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCONVCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCONVCONTRACT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCONVCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

    CustomExecQuery('INSERT INTO bn_currconvcontract ' +
        '( ' +
        'documentkey, ' +
        'fromcurrkey, ' +
        'fromaccountkey, ' +
        'fromamountcurr, ' +
        'tocurrkey, ' +
        'toaccountkey, ' +
        'toamountcurr ' +
        ') VALUES ' +
        '( ' +
        ':NEW_documentkey, ' +
        ':NEW_fromcurrkey, ' +
        ':NEW_fromaccountkey, ' +
        ':NEW_fromamountcurr, ' +
        ':NEW_tocurrkey, ' +
        ':NEW_toaccountkey, ' +
        ':NEW_toamountcurr ' +
        ') ', Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCONVCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCONVCONTRACT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrConvContract.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCCURRCONVCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCONVCONTRACT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCONVCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCONVCONTRACT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCONVCONTRACT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

    CustomExecQuery('UPDATE bn_currconvcontract SET ' +
        'documentkey    = :NEW_documentkey , ' +
        'fromcurrkey    = :NEW_fromcurrkey , ' +
        'fromaccountkey = :NEW_fromaccountkey , ' +
        'fromamountcurr = :NEW_fromamountcurr , ' +
        'tocurrkey      = :NEW_tocurrkey , ' +
        'toaccountkey   = :NEW_toaccountkey , ' +
        'toamountcurr    = :NEW_toamountcurr ' +
        ' WHERE documentkey = :OLD_documentkey ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCONVCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCONVCONTRACT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrConvContract.DocumentTypeKey: Integer;
begin
  Result := BN_DOC_CURRCONVCONTRACT;
end;

function TgdcCurrConvContract.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRCONVCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCONVCONTRACT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCONVCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCONVCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCONVCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '   RIGHT JOIN bn_currconvcontract cc ON cc.documentkey = z.id ' +
    '   LEFT JOIN gd_companyaccount froma ON cc.fromaccountkey = froma.id ' +
    '   LEFT JOIN gd_companyaccount toa ON cc.toaccountkey = toa.id ' +
    '   LEFT JOIN gd_curr fromc ON cc.fromcurrkey = fromc.id ' +
    '   LEFT JOIN gd_curr toc ON cc.tocurrkey = toc.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCONVCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCONVCONTRACT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrConvContract.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRCONVCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRCONVCONTRACT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRCONVCONTRACT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRCONVCONTRACT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRCONVCONTRACT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    '   , cc.*, ' +
    '   froma.Account as FromAccount, toa.Account as ToAccount, ' +
    '   fromc.Name as fromcurrname, fromc.shortname as fromcurrshortname, ' +
    '   toc.Name as tocurrname, toc.shortname as tocurrshortname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRCONVCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRCONVCONTRACT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrConvContract.GetGroupID: Integer;
begin
  Result := GD_RP_CURRCONVCONTRACT;{2000315}
end;

class function TgdcCurrConvContract.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tbn_frmCurrConvContract';
end;

{ TgdcCurrDocument }

procedure TgdcCurrDocument._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCURRDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRDOCUMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRDOCUMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRDOCUMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrDocument.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCURRDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRDOCUMENT', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRDOCUMENT',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  KillRequired;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRDOCUMENT', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrDocument.KillRequired;
var
  i: Integer;
begin
  for i:= 0 to FieldCount - 1 do
    Fields[i].Required := False;
end;

initialization
  RegisterGDCClass(TgdcCurrDocument);
  RegisterGDCClass(TgdcCurrSellContract);
  RegisterGDCClass(TgdcCurrCommissSell);
  RegisterGDCClass(TgdcCurrListAllocation);
  RegisterGDCClass(TgdcCurrBuyContract);
  RegisterGDCClass(TgdcCurrConvContract);

finalization
  UnRegisterGDCClass(TgdcCurrDocument);
  UnRegisterGDCClass(TgdcCurrSellContract);
  UnRegisterGDCClass(TgdcCurrCommissSell);
  UnRegisterGDCClass(TgdcCurrListAllocation);
  UnRegisterGDCClass(TgdcCurrBuyContract);
  UnRegisterGDCClass(TgdcCurrConvContract);

end.











