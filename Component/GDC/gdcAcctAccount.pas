
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcAcctAccount.pas

  Abstract

    Бизнес-классы для работы сос счетами

  Author

    Anton Smirnov (07-11-2001)

  Revisions history

    Initial  07-11-2001  sai    Initial version.
             13-03-2002  Julie  Changed alias for main table in all scripts
--}

unit gdcAcctAccount;

interface

uses
  Classes, IBCustomDataSet, gdcBase, gdcTree, gdcBaseInterface,
  Forms, gd_createable_form, SysUtils, ibsql;

const
  cst_ByCompany           = 'ByCompany';
  acc_ss_ChartsAndFolders = 'ChartsAndFolders';
  acc_ss_Accounts         = 'Accounts';

type
  TgdcAcctBase = class(TgdcLBRBTree)
  protected
    procedure _DoOnNewRecord; override;
    function GetAccountType: String; virtual;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;

  public
    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
  end;

  TgdcAcctFolder = class(TgdcAcctBase)
  protected
//    function CreateDialogForm: TCreateableForm; override;
    function GetAccountType: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetRestrictCondition(const ATableName,
      ASubType: String): String; override;
  end;

  TgdcAcctChart = class(TgdcAcctBase)
  protected
//    function CreateDialogForm: TCreateableForm; override;
    function GetAccountType: String; override;
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    procedure CustomInsert(Buff: Pointer); override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    constructor Create(AnOwner: TComponent); override;
  end;

  TgdcAcctAccount = class(TgdcAcctBase)
  protected
//    function CreateDialogForm: TCreateableForm; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetAccountType: String; override;
    procedure DoBeforePost; override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetRestrictCondition(const ATableName,
      ASubType: String): String; override;
  end;

  TgdcAcctSubAccount = class(TgdcAcctAccount)
  protected
//    function CreateDialogForm: TCreateableForm; override;
    function GetAccountType: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetRestrictCondition(const ATableName,
      ASubType: String): String; override;
  end;

  procedure Register;

implementation

uses
  gd_security,
  gdc_dlgAcctAccount_unit,
  gdc_dlgAcctSubAccount_unit,
  gdc_dlgAcctChart_unit,
  gdc_dlgAcctFolder_unit,
  gdc_frmAcctAccount_unit, gd_ClassList;

{ TgdcAcctBase }

procedure TgdcAcctBase._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName('accounttype').AsString := GetAccountType;
  FieldByName('parent').Required := True;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctBase.GetAccountType: String;
begin
  Result := '';
end;

function TgdcAcctBase.GetCurrRecordClass: TgdcFullClass;
begin
  Result := inherited GetCurrRecordClass;
  if (not IsEmpty) and (FieldByName('accounttype').AsString > '') then
    case FieldByName('accounttype').AsString[1] of
      'C': Result.gdClass := TgdcAcctChart;
      'F': Result.gdClass := TgdcAcctFolder;
      'A': Result.gdClass := TgdcAcctAccount;
      'S': Result.gdClass := TgdcAcctSubAccount;
    end;
end;

class function TgdcAcctBase.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'ac_account';
end;

class function TgdcAcctBase.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'alias';
end;

class function TgdcAcctBase.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctAccount';
end;

class function TgdcAcctBase.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Бухгалтерский план счетов'
end;

class function TgdcAcctBase.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    acc_ss_ChartsAndFolders + ';' +
    acc_ss_Accounts + ';' +
    cst_ByCompany + ';';
end;

procedure TgdcAcctBase.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(acc_ss_ChartsAndFolders) then
    S.Add(' z.accounttype IN (''C'', ''F'') ');

  if HasSubSet(acc_ss_Accounts) then
    S.Add(' z.accounttype IN (''A'', ''S'') ');

  if HasSubSet(cst_ByCompany) and Assigned(IBLogin) then
  begin
    S.Add(Format(' exists (SELECT lb FROM ac_account c1 JOIN ac_companyaccount cc ' +
    '  ON c1.ID = cc.accountkey  ' +
    '  WHERE z.LB >= c1.lb AND z.rb <= c1.rb AND cc.companykey IN (%s) ) ',
    [IBLogin.HoldingList]));
  end;
end;

function TgdcAcctBase.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCACCTBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASE' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet('ByID') then
    Result := ''
  else
    Result := ' ORDER BY z.alias ';
    
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;


{ TgdcAcctFolder }

(*function TgdcAcctFolder.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCACCTFOLDER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTFOLDER', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTFOLDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTFOLDER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTFOLDER' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgAcctFolder.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTFOLDER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTFOLDER', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;*)

function TgdcAcctFolder.GetAccountType: String;
begin
  Result := 'F';
end;

class function TgdcAcctFolder.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgAcctFolder';
end;

class function TgdcAcctFolder.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Раздел плана счетов';
end;

class function TgdcAcctFolder.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.accounttype = ''F''';
end;

procedure TgdcAcctFolder.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.accounttype = ''F''');
end;

{ TgdcAcctChart }

(*function TgdcAcctChart.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCACCTCHART', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCHART', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCHART') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCHART',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCHART' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgAcctChart.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCHART', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCHART', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;*)

function TgdcAcctChart.GetAccountType: String;
begin
  Result := 'C';
end;

procedure TgdcAcctChart._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCHART', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCHART', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCHART') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCHART',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCHART' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName('parent').Required := False;
  FieldByName('parent').Clear;

  FieldByName('alias').Required := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCHART', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCHART', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAcctChart.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCACCTCHART', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCHART', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCHART') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCHART',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCHART' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CustomExecQuery(Format(' INSERT INTO ac_companyaccount(companykey, accountkey, ' +
    ' isactive) VALUES(%d, %d, %d) ',
    [IBLogin.CompanyKey, ID, 0]), Buff);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCHART', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCHART', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

constructor TgdcAcctChart.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  CustomProcess := [cpInsert];
end;

procedure TgdcAcctChart.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.accounttype in (''C'', ''F'')');
end;

procedure TgdcAcctChart.DoBeforePost;
  VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTCHART', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTCHART', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTCHART') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTCHART',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTCHART' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  FieldByName('alias').AsString := System.Copy(
    FieldByName('name').AsString, 1, FieldByName('alias').Size);

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTCHART', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTCHART', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctChart.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgAcctChart';
end;

{ TgdcAcctAccount }

(*function TgdcAcctAccount.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCACCTACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTACCOUNT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTACCOUNT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTACCOUNT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgAcctAccount.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;*)


procedure TgdcAcctAccount.DoBeforePost;
  VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
    ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCACCTACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTACCOUNT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTACCOUNT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FieldByName('activity').AsString <> 'B' then
    FieldByName('analyticalfield').Clear
  else
    if FieldByName('analyticalfield').AsInteger > 0 then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT fieldname FROM at_relation_fields WHERE id = :id';
        ibsql.ParamByName('id').AsInteger := FieldByName('analyticalfield').AsInteger;
        ibsql.ExecQuery;
        FieldByName(ibsql.FieldByName('fieldname').AsString).AsInteger := 1;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTACCOUNT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcAcctAccount.GetAccountType: String;
begin
  Result := 'A';
end;

class function TgdcAcctAccount.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgAcctAccount';
end;

class function TgdcAcctAccount.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Счет';
end;

class function TgdcAcctAccount.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.accounttype IN (''A'', ''S'')';
end;

procedure TgdcAcctAccount.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.accounttype in (''A'', ''S'')');
end;

{ TgdcAcctSubAccount }

(*function TgdcAcctSubAccount.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCACCTSUBACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTSUBACCOUNT', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTSUBACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTSUBACCOUNT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTSUBACCOUNT' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgAcctSubAccount.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTSUBACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTSUBACCOUNT', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;*)

function TgdcAcctSubAccount.GetAccountType: String;
begin
  Result := 'S';
end;

procedure Register;
begin
  RegisterComponents('gdcAcctAccount', [TgdcAcctBase]);
  RegisterComponents('gdcAcctAccount', [TgdcAcctFolder]);
  RegisterComponents('gdcAcctAccount', [TgdcAcctChart]);
  RegisterComponents('gdcAcctAccount', [TgdcAcctAccount]);
  RegisterComponents('gdcAcctAccount', [TgdcAcctSubAccount]);
end;

class function TgdcAcctSubAccount.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgAcctSubAccount';
end;

class function TgdcAcctSubAccount.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Субсчет';
end;

class function TgdcAcctSubAccount.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.accounttype=''S''';
end;

procedure TgdcAcctSubAccount.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.accounttype = ''S''');
end;

initialization
  RegisterGdcClass(TgdcAcctBase);
  RegisterGdcClass(TgdcAcctFolder);
  RegisterGdcClass(TgdcAcctChart);
  RegisterGdcClass(TgdcAcctAccount);
  RegisterGdcClass(TgdcAcctSubAccount);

finalization
  UnRegisterGdcClass(TgdcAcctBase);
  UnRegisterGdcClass(TgdcAcctFolder);
  UnRegisterGdcClass(TgdcAcctChart);
  UnRegisterGdcClass(TgdcAcctAccount);
  UnRegisterGdcClass(TgdcAcctSubAccount);
end.
