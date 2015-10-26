
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    gdcInvPriceList_unit.pas

  Abstract

    Business class. Price List.

  Author

    Romanovski Denis (19-10-2001)

  Revisions history

    Initial  19-10-2001  Dennis  Initial version.

--}

unit gdcInvPriceList_unit;

interface

uses
  Windows,    Messages,           SysUtils,             Classes,    Graphics,
  Controls,   Forms,              Dialogs,              gd_ClassList,
  gdcBase,    gd_createable_form, gdcClasses_interface, gdcClasses, at_Classes,
  IBDatabase, DB,                 IBSQL,                gdcInvConsts_unit,
  gdcBaseInterface,               ComCtrls;

type
  TgdcInvBasePriceList = class;
  TgdcInvPriceList = class;
  TgdcInvPriceListLine = class;
  TgdcInvPriceListType = class;
  TgdcInvBasePriceListClass = class of TgdcInvBasePriceList;

  TgdcInvBasePriceList = class(TgdcDocument)
  private
    FHeaderFields: TgdcInvPriceFields; // Список настроек для полей шапйки прайс-листа
    FLineFields: TgdcInvPriceFields;   // Список настроек для полей позиции прайс-листа

    FCurrentStreamVersion: String; // Версия настроек, считанных из потока

    FLastRelationCostKey: Integer;
    FLastRelationCostName: String[31];
    FRelCostIBSQL: TIBSQL;

    class function EnumPriceListFields(PriceFields: TgdcInvPriceFields; Alias: String;
      const UseDot: Boolean = True): String;
    class function EnumModificationList(PriceFields: TgdcInvPriceFields): String;

  protected
    procedure ReadOptions(DE: TgdDocumentEntry); override;
    //procedure WriteStream(Stream: TStream); virtual;

    function GetNotCopyField: String; override;

  public
    constructor Create(AnOwner: TComponent); override;
    class function IsAbstractClass: Boolean; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    //Функция возвращает ключ валюты по ключу цены обоснования
    function GetCurrencyKey(const RelationFieldKey: Integer): Integer;

    property HeaderFields: TgdcInvPriceFields read FHeaderFields;
    property LineFields: TgdcInvPriceFields read FLineFields;
  end;

  TgdcInvPriceList = class(TgdcInvBasePriceList)
  private
    FIsPrePosted: Boolean;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;
    procedure DoAfterCancel; override;
    procedure DoAfterDelete; override;
    procedure DoAfterOpen; override;
    procedure DoAfterPost; override;
    function GetDetailObject: TgdcDocument; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetDocumentClassPart: TgdcDocumentClassPart; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure GetProperties(ASL: TStrings); override;
    procedure PrePostDocumentData;
  end;


  TgdcInvPriceListLine = class(TgdcInvBasePriceList)
  private
    FGoodSQL: TIBSQL;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    procedure _DoOnNewRecord; override;
    function GetMasterObject: TgdcDocument; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetDocumentClassPart: TgdcDocumentClassPart; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure UpdateGoodNames;
  end;

  TinvPriceListField = class
  private
    function Get_atField: TatField;

  public
    FPriceField: TgdcInvPriceField;
    FLName: String;
    FFieldSource: String;
    FRelation: TatRelation;
    FIsUsed: Boolean;

    constructor Create(AFieldName, ALName, AFieldSource: String;
      ARelation: TatRelation);

    procedure ClearValues;
    procedure AssignValues(APriceField: TgdcInvPriceField;
      const AnIsUsed: Boolean = False);

    function CanBeUsedAsCurrency: Boolean;
    function GetID: Integer;

    property atField: TatField read Get_atField;
  end;

  TgdcInvPriceListType = class(TgdcDocumentType)
  protected
    procedure CreateFields; override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure UpdateFields(lv: TListView; const AName: String;
      R: TatRelation; AFields: TgdcInvPriceFields);

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function InvDocumentTypeBranchKey: Integer;
    class function GetHeaderDocumentClass: CgdcBase; override;
  end;

  EgdcInvPriceList = class(EgdcException);
  EgdcInvPriceListLine = class(EgdcException);
  EgdcInvPriceListType = class(EgdcException);

procedure Register;

implementation

uses
  gd_security_OperationConst,   gdc_dlgSetupInvPriceList_unit, gdc_frmInvPriceList_unit,
  gdc_frmInvPriceListType_unit, gdc_dlgInvPriceList_unit,      at_sql_setup,
  gdc_dlgInvPriceListLine_unit, gdcInvDocument_unit;

procedure Register;
begin
  RegisterComponents('GDC', [TgdcInvPriceListType, TgdcInvPriceList, TgdcInvPriceListLine]);
end;

{ TgdcInvBasePriceList }

constructor TgdcInvBasePriceList.Create(AnOwner: TComponent);
begin
  inherited;

  SetLength(FHeaderFields, 0);
  SetLength(FLineFields, 0);

  FCurrentStreamVersion := gdcInv_Price_Undone;

  FLastRelationCostKey := -1;
end;

class function TgdcInvBasePriceList.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcInvBasePriceList');
end;

class function TgdcInvBasePriceList.EnumModificationList(
  PriceFields: TgdcInvPriceFields): String;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to Length(PriceFields) - 1 do
  begin
    Result := Result + ', ' +
      PriceFields[I].FieldName +
      ' = :' +
      PriceFields[I].FieldName;
  end;
end;

class function TgdcInvBasePriceList.EnumPriceListFields(
  PriceFields: TgdcInvPriceFields; Alias: String;
  const UseDot: Boolean): String;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to Length(PriceFields) - 1 do
  begin
    Result := Result + ', ' + Alias;

    if UseDot then
      Result := Result + '.';

    Result := Result +
      PriceFields[I].FieldName;
  end;
end;

function TgdcInvBasePriceList.GetCurrencyKey(
  const RelationFieldKey: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FLastRelationCostKey <> RelationFieldKey then
  begin
    if FRelCostIBSQL = nil then
    begin
      FRelCostIBSQL := TIBSQL.Create(Self);
      FRelCostIBSQL.Transaction := ReadTransaction;
      FRelCostIBSQL.SQL.Text := 'SELECT fieldname FROM at_relation_fields WHERE id = :relationkey';
    end;
    FRelCostIBSQL.ParamByName('relationkey').AsInteger := RelationFieldKey;
    FRelCostIBSQL.ExecQuery;
    try
      if not FRelCostIBSQL.Eof then
        FLastRelationCostName := FRelCostIBSQL.FieldByName('fieldname').AsString
      else
        FLastRelationCostName := '';
      FLastRelationCostKey := RelationFieldKey;
    finally
      FRelCostIBSQL.Close
    end;
  end;

  if FLastRelationCostName = '' then
  begin
    Exit;
  end;

  for I := Low(FLineFields) to High(FLineFields) do
  begin
    if AnsiCompareText(FLineFields[I].FieldName, FLastRelationCostName) = 0 then
    begin
      Result := FLineFields[I].CurrencyKey;
      Break;
    end;
  end;
end;

function TgdcInvBasePriceList.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCINVBASEPRICELIST', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEPRICELIST', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEPRICELIST',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEPRICELIST' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY';

  if GetDocumentClassPart <> dcpHeader then
    Result := Result + ',MASTERKEY';

  if Assigned(MasterSource) and (GetDocumentClassPart <> dcpHeader) then
    Result := Result + ',PRICEKEY';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEPRICELIST', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEPRICELIST', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBasePriceList.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvPriceList';
end;

procedure TgdcInvBasePriceList.ReadOptions(DE: TgdDocumentEntry);
begin
  inherited;

  if DE <> nil then
  begin
    FHeaderFields := (DE as TgdInvPriceDocumentEntry).HeaderFields;
    FLineFields := (DE as TgdInvPriceDocumentEntry).LineFields;
  end else
  begin
    SetLength(FHeaderFields, 0);
    SetLength(FLineFields, 0);
  end;
end;

{
procedure TgdcInvBasePriceList.WriteStream(Stream: TStream);
var
  I: Integer;
begin
  with TWriter.Create(Stream, 1024) do
  try
    // Версия потока
    WriteString(gdcInvPrice_Version1_2);

    // Ключ группы отчетов записываем
    WriteInteger(FReportGroupKey);

    // Настройки шапки прайс-листа

    WriteListBegin;
    for I := 0 to Length(FHeaderFields) - 1 do
      Write(FHeaderFields[I], SizeOf(TgdcInvPriceField));
    WriteListEnd;

    // Настройки позиции прайс-листа

    WriteListBegin;
    for I := 0 to Length(FLineFields) - 1 do
      Write(FLineFields[I], SizeOf(TgdcInvPriceField));
    WriteListEnd;
  finally
    Free;
  end;
end;
}

{ TgdcInvPriceList }

procedure TgdcInvPriceList.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVPRICELIST', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (sLoadFromStream in BaseState) then
    inherited
  else if not FIsPrePosted then
  begin
    inherited CustomDelete(Buff);
    inherited;
  end
  else
    inherited CustomModify(Buff);

  CustomExecQuery(
    Format(
      'INSERT INTO inv_price ' +
      '  (documentkey, name, description, relevancedate, reserved%s) ' +
      'VALUES ' +
      '  (:documentkey, :name, :description, :relevancedate, :reserved%s) ',
      [
        EnumPriceListFields(FHeaderFields, '', False),
        EnumPriceListFields(FHeaderFields, ':', False)
      ]
    ),
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceList.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVPRICELIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    Format(
      'UPDATE inv_price ' +
      'SET ' +
      '  documentkey = :documentkey, ' +
      '  name = :name, ' +
      '  description = :description, ' +
      '  relevancedate = :relevancedate, ' +
      '  reserved = :reserved ' +
      '  %s ' +
      'WHERE ' +
      '  (documentkey = :old_documentkey) ',
      [EnumModificationList(FHeaderFields)]
    ),
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceList._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELIST', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  //
  // Устанавливаем значения по умолчанию

  FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;

  FieldByName('name').AsString := DocumentName;
  FieldByName('relevancedate').AsDateTime := FieldByName('documentdate').AsDateTime;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcInvPriceList.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVPRICELIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '  JOIN inv_price p ON z.id = p.documentkey ';
  if ARefresh then
    Result := Result + ' AND z.id = :NEW_id ';  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvPriceList.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVPRICELIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    inherited GetSelectClause +
    ', p.documentkey, p.name, p.description, p.relevancedate, p.reserved ' +
    EnumPriceListFields(FHeaderFields, 'P', True) + ' ';

  FSQLSetup.Ignores.AddAliasName('INV_PRICE');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvPriceList.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpHeader;
end;

class function TgdcInvPriceList.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvPriceList';
end;

procedure TgdcInvPriceList.PrePostDocumentData;
  function Chs(S1, S2: String; IsSecond: Boolean): String;
  begin
    if not IsSecond then
      Result := S1 else
      Result := S2;
  end;
begin
  try
    ExecSingleQuery(Format
    (
      'INSERT INTO gd_document ' +
      '  (id, parent, documenttypekey, trtypekey, number, documentdate, description, ' +
      '   delayed, afull, achag, aview, currkey, companykey, ' +
      '   creatorkey, creationdate, editorkey, editiondate, printdate, disabled, reserved) ' +
      'VALUES ' +
      '  (%s, %s, %s, %s, ''%s'', ''%s'', %s, %s, %s, %s, %s, ' +
      '   %s, %s, %s, ''%s'', %s, ''%s'', %s, %s, %s) ',
      [
        Chs(FieldByName('ID').AsString, 'NULL', FieldByName('ID').IsNull),
        Chs(FieldByName('PARENT').AsString, 'NULL', FieldByName('PARENT').IsNull),
        Chs(FieldByName('DOCUMENTTYPEKEY').AsString, 'NULL', FieldByName('DOCUMENTTYPEKEY').IsNull),
        Chs(FieldByName('TRTYPEKEY').AsString, 'NULL', FieldByName('TRTYPEKEY').IsNull),
        Chs(FieldByName('NUMBER').AsString, '', FieldByName('NUMBER').IsNull),
        FieldByName('DOCUMENTDATE').AsString,
        Chs(FieldByName('DESCRIPTION').AsString, '''''', FieldByName('DESCRIPTION').IsNull),
        Chs(FieldByName('DELAYED').AsString, 'NULL', FieldByName('DELAYED').IsNull),
        FieldByName('AFULL').AsString,
        FieldByName('ACHAG').AsString,
        FieldByName('AVIEW').AsString,
        Chs(FieldByName('CURRKEY').AsString, 'NULL', FieldByName('CURRKEY').IsNull),
        FieldByName('COMPANYKEY').AsString,
        Chs(FieldByName('CREATORKEY').AsString, 'NULL', FieldByName('CREATORKEY').IsNull),
        FieldByName('CREATIONDATE').AsString,
        Chs(FieldByName('EDITORKEY').AsString, 'NULL', FieldByName('EDITORKEY').IsNull),
        FieldByName('EDITIONDATE').AsString,
        Chs('''' + FieldByName('PRINTDATE').AsString + '''', 'NULL', FieldByName('PRINTDATE').IsNull),
        Chs(FieldByName('DISABLED').AsString, 'NULL', FieldByName('DISABLED').IsNull),
        Chs(FieldByName('RESERVED').AsString, 'NULL', FieldByName('RESERVED').IsNull)
      ]
    ));
    FIsPrePosted := True;
  except
    raise;
  end;
end;

constructor TgdcInvPriceList.Create(AnOwner: TComponent);
begin
  inherited;
  FIsPrePosted := False;
end;

procedure TgdcInvPriceList.DoAfterCancel;
begin
  inherited;
  FIsPrePosted := False;
end;

procedure TgdcInvPriceList.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELIST', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceList.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELIST', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceList.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELIST', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELIST', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELIST',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FIsPrePosted := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELIST', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELIST', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcInvPriceList.GetDetailObject: TgdcDocument;
begin
  Result := TgdcInvPriceListLine.CreateSubType(Owner, SubType);
end;

class function TgdcInvPriceList.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgInvPriceList';
end;

procedure TgdcInvPriceList.GetProperties(ASL: TStrings);
begin
  inherited;

end;

{ TgdcInvPriceListLine }

constructor TgdcInvPriceListLine.Create(AnOwner: TComponent);
begin
  inherited;

  FGoodSQL := nil;
end;

procedure TgdcInvPriceListLine.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVPRICELISTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if Assigned(FGoodSQL) then
    FreeAndNil(FGoodSQL);

  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceListLine.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVPRICELISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    Format(
      'INSERT INTO inv_priceline ' +
      '  (documentkey, pricekey, goodkey, reserved%s) ' +
      'VALUES ' +
      '  (:documentkey, :pricekey, :goodkey, :reserved%s) ',
      [
        EnumPriceListFields(FLineFields, '', False),
        EnumPriceListFields(FLineFields, ':', False)
      ]
    ),
    Buff,
    False
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceListLine.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVPRICELISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    Format(
      'UPDATE inv_priceline ' +
      'SET ' +
      '  documentkey = :documentkey, ' +
      '  pricekey = :pricekey, ' +
      '  goodkey = :goodkey, ' +
      '  reserved = :reserved ' +
      '  %s ' +
      'WHERE ' +
      '  (documentkey = :old_documentkey) ',
      [EnumModificationList(FLineFields)]
    ),
    Buff,
    False
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceListLine._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(FgdcDataLink) and (FgdcDataLink.DataSet is TgdcBase) then
  begin
    FieldByName('parent').AsInteger := FgdcDataLink.DataSet.FieldByName('ID').AsInteger;
    FieldByName('pricekey').AsInteger := FgdcDataLink.DataSet.FieldByName('ID').AsInteger;
  end;

  FieldByName('documentkey').AsInteger := FieldByName('id').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvPriceListLine.GetDocumentClassPart: TgdcDocumentClassPart;
begin
  Result := dcpLine;
end;

function TgdcInvPriceListLine.GetFromClause(const ARefresh: Boolean = False): String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  R: TatRelation;
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVPRICELISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetFromClause(ARefresh) +
    '  LEFT JOIN inv_priceline pl ON z.id = pl.documentkey ' +
    '  LEFT JOIN gd_good g ON g.id = pl.goodkey ';


  FSQLSetup.Ignores.AddAliasName('PL');    
  R := atDatabase.Relations.ByRelationName('INV_PRICELINE');

  if Assigned(R) then
  begin
    for i:= 0 to R.RelationFields.Count - 1 do
      if R.RelationFields[i].IsUserDefined and Assigned(R.RelationFields[i].References)
         and Assigned(R.RelationFields[i].Field) then
      begin
        Result := Result + ' LEFT JOIN ' + R.RelationFields[i].Field.RefTable.RelationName +
          ' PL_' + R.RelationFields[i].FieldName + ' ON PL.' + R.RelationFields[i].FieldName +
          ' = PL_' + R.RelationFields[i].FieldName + '.' +
          R.RelationFields[i].Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName
      end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvPriceListLine.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  R: TatRelation;
  i: Integer;  
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVPRICELISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTLINE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTLINE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTLINE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    inherited GetSelectClause +
    ', g.name as goodname, g.alias as goodalias, ' +
    'pl.documentkey, pl.pricekey, pl.goodkey, pl.reserved ' +
    EnumPriceListFields(FLineFields, 'PL', True) + ' ';

  R := atDatabase.Relations.ByRelationName('INV_PRICELINE');

  if Assigned(R) then
  begin
    for i:= 0 to R.RelationFields.Count - 1 do
      if R.RelationFields[i].IsUserDefined and Assigned(R.RelationFields[i].References)
         and Assigned(R.RelationFields[i].Field) then
      begin
        Result := Result + ', PL_' + R.RelationFields[i].FieldName + '.' +
           R.RelationFields[i].Field.RefListFieldName + ' as PL_' +
           R.RelationFields[i].FieldName + '_' + R.RelationFields[i].Field.RefListFieldName;
      end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTLINE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceListLine.UpdateGoodNames;
begin
  if not (State in dsEditModes) then
    Edit;

  if not Assigned(FGoodSQL) then
  begin
    FGoodSQL := TIBSQL.Create(nil);
    FGoodSQL.Database := Database;
    FGoodSQL.Transaction := ReadTransaction;
    FGoodSQL.SQL.Text := 'SELECT NAME, ALIAS FROM GD_GOOD WHERE ID = :ID';
  end;

  FGoodSQL.Transaction := ReadTransaction;
  Transaction.Active := True;

  FGoodSQL.ParamByName('ID').AsInteger := FieldByName('GOODKEY').AsInteger;
  FGoodSQL.ExecQuery;

  if FGoodSQL.RecordCount > 0 then
  begin
    FieldByName('GOODNAME').AsString := FGoodSQL.FieldByName('NAME').AsString;
    FieldByName('GOODALIAS').AsString := FGoodSQL.FieldByName('ALIAS').AsString;
  end;

  FGoodSQL.Close;
end;

function TgdcInvPriceListLine.GetMasterObject: TgdcDocument;
begin
  Result := TgdcInvPriceList.CreateSubType(Owner, SubType);
end;

class function TgdcInvPriceListLine.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgInvPriceLine';
end;

{ TinvPriceListField }

procedure TinvPriceListField.AssignValues(APriceField: TgdcInvPriceField;
  const AnIsUsed: Boolean = False);
begin
  FPriceField.CurrencyKey := APriceField.CurrencyKey;
  FPriceField.ContactKey := APriceField.ContactKey;
  FisUsed := AnIsUsed;
end;

function TinvPriceListField.CanBeUsedAsCurrency: Boolean;
begin
  Result := (atField.FieldType in [ftSmallInt, ftInteger, ftBCD,
    ftFloat, ftLargeInt, ftCurrency])
      and
    not Assigned(atField.RefTable) and
    not Assigned(atField.SetTable);
end;

procedure TinvPriceListField.ClearValues;
begin
  FPriceField.CurrencyKey := -1;
  FPriceField.ContactKey := -1;
end;

constructor TinvPriceListField.Create(AFieldName, ALName, AFieldSource: String;
  ARelation: TatRelation);
begin
  FPriceField.FieldName := AFieldName;

  FLName := ALName;
  FFieldSource := AFieldSource;

  ClearValues;

  FRelation := ARelation;
end;

function TinvPriceListField.GetID: Integer;
var
  RF: TatRelationField;
begin
  Assert(FRelation <> nil);
  RF := FRelation.RelationFields.ByFieldName(FPriceField.FieldName);
  if RF = nil then
    raise Exception.Create('Unknown field name');
  Result := RF.ID;
end;

function TinvPriceListField.Get_atField: TatField;
begin
  Result := atDatabase.Fields.ByFieldName(FFieldSource);
end;

{ TgdcInvPriceListType }

constructor TgdcInvPriceListType.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify];
end;

procedure TgdcInvPriceListType.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVPRICELISTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTTYPE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTTYPE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('headerrelkey').Required := True;
  FieldByName('linerelkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTTYPE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvPriceListType.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCINVPRICELISTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVPRICELISTTYPE', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVPRICELISTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVPRICELISTTYPE',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVPRICELISTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Process = cpInsert then
  begin
    DE := gdClassList.Add('TgdcInvPriceList', FieldByName('ruid').AsString, GetParentSubType,
      TgdInvPriceDocumentEntry, FieldbyName('name').AsString) as TgdDocumentEntry;
    DE.LoadDE(Transaction);
    gdClassList.Add('TgdcInvPriceListLine', FieldByName('ruid').AsString, GetParentSubType,
      TgdInvPriceDocumentEntry, FieldbyName('name').AsString).Assign(DE);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVPRICELISTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVPRICELISTTYPE', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvPriceListType.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgSetupInvPriceList';
end;

class function TgdcInvPriceListType.GetHeaderDocumentClass: CgdcBase;
begin
  Result := TgdcInvPriceList;
end;

class function TgdcInvPriceListType.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvPriceListType';
end;

class function TgdcInvPriceListType.InvDocumentTypeBranchKey: Integer;
begin
  Result := INV_DOC_PRICELISTBRANCH;
end;

procedure TgdcInvPriceListType.UpdateFields(lv: TListView;
  const AName: String; R: TatRelation; AFields: TgdcInvPriceFields);
var
  I, J, OptID: Integer;
  Found: Boolean;
  RF: TatRelationField;
  F: TInvPriceListField;
begin
  Assert(R <> nil);

  for I := 0 to lv.Items.Count - 1 do
  begin
    F := TInvPriceListField(lv.Items[I].Data);
    Found := False;

    for J := Low(AFields) to High(AFields) do
      if AFields[J].FieldName = F.FPriceField.FieldName then
      begin
        Found := True;
        break;
      end;

    if not Found then
    begin
      OptID := GetNextID;

      Fq.Close;
      Fq.SQL.Text :=
        'INSERT INTO gd_documenttype_option (id, dtkey, option_name, bool_value, relationfieldkey, contactkey, currkey) ' +
        'VALUES (:id, :dtkey, :option_name, NULL, :rfk, :ck, :currkey)';
      Fq.ParamByName('id').AsInteger := OptID;
      Fq.ParamByName('dtkey').AsInteger := ID;
      Fq.ParamByName('option_name').AsString := AName;
      Fq.ParamByName('rfk').AsInteger := F.GetID;
      if F.FPriceField.ContactKey > 0 then
        Fq.ParamByName('ck').AsInteger := F.FPriceField.ContactKey
      else
        Fq.ParamByName('ck').Clear;
      if F.FPriceField.CurrencyKey > 0 then
        Fq.ParamByName('currkey').AsInteger := F.FPriceField.CurrencyKey
      else
        Fq.ParamByName('currkey').Clear;
      Fq.ExecQuery;

      AddNSObject(OptID, AName + '.' + F.FPriceField.FieldName, F.GetID);
    end;
  end;

  for J := Low(AFields) to High(AFields) do
  begin
    Found := False;

    for I := 0 to lv.Items.Count - 1 do
    begin
      F := TInvPriceListField(lv.Items[I].Data);
      if AFields[J].FieldName = F.FPriceField.FieldName then
      begin
        Found := True;
        break;
      end;
    end;

    if not Found then
    begin
      RF := R.RelationFields.ByFieldName(AFields[J].FieldName);

      if RF <> nil then
      begin
        Fq.Close;
        Fq.SQL.Text :=
          'DELETE FROM gd_documenttype_option ' +
          'WHERE dtkey = :dtkey AND option_name = :option_name AND relationfieldkey = :rfk';
        Fq.ParamByName('dtkey').AsInteger := ID;
        Fq.ParamByName('option_name').AsString := AName;
        Fq.ParamByname('rfk').AsInteger := RF.ID;
        Fq.ExecQuery;
      end;
    end;
  end;
end;

initialization
  RegisterGdcClass(TgdcInvPriceListType, 'Прайс-лист');
  with RegisterGdcClass(TgdcInvPriceList) as TgdBaseEntry do
    DistinctRelation := 'INV_PRICE';
  with RegisterGdcClass(TgdcInvPriceListLine) as TgdBaseEntry do
    DistinctRelation := 'INV_PRICELINE';

finalization
  UnregisterGdcClass(TgdcInvPriceListType);
  UnregisterGdcClass(TgdcInvPriceList);
  UnregisterGdcClass(TgdcInvPriceListLine);
end.

