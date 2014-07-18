
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcAttrUserDefined.pas

  Abstract

    Gedemin class for user defined tables.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.
           13-03-2002    Julie     Changed alias for main table in all scripts
    2.0    01.05.2002    Julie     Added classes TgdcAttrUserDefinedLBRBTree and
                                   TgdcAttrUserDefinedTree      

--}

unit gdcAttrUserDefined;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdcBase, gd_createable_form, gdcClasses, at_Classes, IBDatabase, DB, IBSQL,
  gdcTree, gdcBaseInterface;

const
  GDC_GDCATTRUSERDEFINED = 'TGDCATTRUSERDEFINED';

type
  TgdcAttrUserDefined = class(TgdcBase)
  private
    FIsView, FIsViewSet: Boolean;

    function GetRelationName: String;
    function GetRelation: TatRelation;
    function GetIsView: Boolean;

  protected
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    //Для представлений не должно быть sql на изменение
    function GetModifySQLText: String; override;
    function GetInsertSQLText: String; override;
    function GetDeleteSQLText: String; override;
    function GetRefreshSQLText: String; override;

    property Relation: TatRelation read GetRelation;

    procedure SetActive(Value: Boolean); override;

    function GetCanDelete: Boolean; override;
    function GetCanCreate: Boolean; override;
    function GetCanEdit: Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubTypeList(SubTypeList: TStrings;
      Subtype: string = ''; OnlyDirect: Boolean = False): Boolean; override;
    class function ClassParentSubtype(Subtype: String): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    property RelationName: String read GetRelationName;
    property IsView: Boolean read GetIsView;
  end;

  TgdcAttrUserDefinedTree = class(TgdcTree)
  private
    function GetRelationName: String;
    function GetRelation: TatRelation;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure SetActive(Value: Boolean); override;

    function CreateDialogForm: TCreateableForm; override;

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubTypeList(SubTypeList: TStrings;
      Subtype: string = ''; OnlyDirect: Boolean = False): Boolean; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    property RelationName: String read GetRelationName;
  end;

  TgdcAttrUserDefinedLBRBTree = class(TgdcLBRBTree)
  private
    function GetRelationName: String;
    function GetRelation: TatRelation;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    function CreateDialogForm: TCreateableForm; override;
    procedure SetActive(Value: Boolean); override;

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubTypeList(SubTypeList: TStrings;
      Subtype: string = ''; OnlyDirect: Boolean = False): Boolean; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    property RelationName: String read GetRelationName;

  published

  end;

procedure Register;

//Возвращает РУИД таблицы
function GetRUIDForRelation(ARelationName: String): String;


implementation


uses
  gdc_frmAttrUserDefined_unit,         gdc_frmAttrUserDefinedTree_unit,
  gdc_frmAttrUserDefinedLBRBTree_unit,
  gdc_dlgAttrUserDefined_unit,         gdc_dlgAttrUserDefinedTree_unit,
  gd_ClassList,                        gdcOLEClassList,
  mtd_i_Base,                          mtd_i_Inherited
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TCrackGdcBase = class(TgdcBase);

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAttrUserDefined,
    TgdcAttrUserDefinedTree, TgdcAttrUserDefinedLBRBTree]);
end;

{По наименованию таблицы возвращает ее руид}
function GetRUIDForRelation(ARelationName: String): String;
var
  ibsql: TIBSQL;
begin
  Assert(Assigned(gdcBaseManager));

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT ruid.xid || ''_'' || ruid.dbid ' +
      'FROM at_relations r JOIN gd_ruid ruid ON ruid.id = r.id ' +
      'WHERE relationname = :rn';
    ibsql.ParamByName('rn').AsString := AnsiUpperCase(ARelationName);
    ibsql.ExecQuery;

    if not ibsql.EOF then
      Result := ibsql.Fields[0].AsString
    else
      Result := '';
  finally
    ibsql.Free;
  end;
end;

{ TgdcAttrUserDefined }

function TgdcAttrUserDefined.GetCanCreate: Boolean;
begin
  Result := inherited GetCanCreate and (not IsView);
end;

function TgdcAttrUserDefined.GetCanDelete: Boolean;
begin
  Result := inherited GetCanDelete and (not IsView);
end;

function TgdcAttrUserDefined.GetCanEdit: Boolean;
begin
  Result := inherited GetCanEdit and (not IsView);
end;

function TgdcAttrUserDefined.GetDeleteSQLText: String;
begin
  if not IsView then
    Result := inherited GetDeleteSQLText
  else
    Result := '';
end;

class function TgdcAttrUserDefined.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAttrUserDefined'; 
end;

class function TgdcAttrUserDefined.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  if aSubType > '' then
    Result := inherited GetDisplayName(aSubType)
  else
    Result := 'Таблица пользователя';
end;

function TgdcAttrUserDefined.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCATTRUSERDEFINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINED', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINED',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINED' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINED', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAttrUserDefined.GetInsertSQLText: String;
begin
  if not IsView then
    Result := inherited GetInsertSQLText
  else
    Result := '';
end;

function TgdcAttrUserDefined.GetIsView: Boolean;
var
  atRelation: TatRelation;
begin
  if not FIsViewSet then
  begin
    if Assigned(atDataBase)  then
      atRelation := atDataBase.Relations.ByRelationName(RelationName)
    else
      atRelation := nil;

    if Assigned(atRelation) then
    begin
      FIsView := atRelation.RelationType = rtView;
    end else
    begin
      MessageBox(ParentHandle,
        PChar('Ошибка при считывании мета-данных. Таблица ' +
        RelationName + ' не найдена! Попробуйте перезагрузиться.'), 'Ошибка!',
        MB_TASKMODAL or MB_OK or MB_ICONERROR);
      FIsView := False;
    end;

    FIsViewSet := True;
  end;

  Result := FIsView;
end;

class function TgdcAttrUserDefined.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
begin
  R := atDatabase.Relations.ByRelationName(ASubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefined.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType
end;

function TgdcAttrUserDefined.GetModifySQLText: String;
begin
  if not IsView then
    Result := inherited GetModifySQLText
  else
    Result := '';
end;

function TgdcAttrUserDefined.GetRefreshSQLText: String;
begin
  if not IsView or Assigned(atDatabase.FindRelationField(RelationName, 'ID')) then
    Result := inherited GetRefreshSQLText
  else
    Result := '';
end;

function TgdcAttrUserDefined.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefined.GetRelationName: String;
begin
  Result := SubType;
end;

class function TgdcAttrUserDefined.GetSubTypeList(SubTypeList: TStrings;
  Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

  { TODO : Временно пока нет наследования по Subtype }
  if Subtype > '' then
  begin
    Result := False;
    Exit;
  end;

  { TODO : этот метод будет вызываться часто и тут возможно замедление }
  with atDatabase.Relations do
  for I := 0 to Count - 1 do
  begin
    if Items[I].IsUserDefined
      and Assigned(Items[I].PrimaryKey)
      and Assigned(Items[I].PrimaryKey.ConstraintFields)
      and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
      and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
      and not Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
    then
    begin
      Assert(SubTypeList.IndexOfName(Items[I].LNAME) = -1,
        'Duplicate local name of user defined table "' + Items[I].LNAME + '".');
      SubTypeList.Add(Items[I].LNAME + '=' + Items[I].RelationName);
    end;
  end;  

  Result := SubTypeList.Count > 0;
end;

class function TgdcAttrUserDefined.ClassParentSubtype(
  Subtype: String): String;
begin
  Result := '';
end;

class function TgdcAttrUserDefined.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  if atDatabase.Relations.ByRelationName(ASubType) = nil then
    Result := ''
  else
    Result := 'Tgdc_frmAttrUserDefined';
end;

procedure TgdcAttrUserDefined.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;
end;

{ TgdcAttrUserDefinedTree }

constructor TgdcAttrUserDefinedTree.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [];
end;

function TgdcAttrUserDefinedTree.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCATTRUSERDEFINEDTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDTREE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDTREE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_dlgAttrUserDefinedTree.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedTree.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  if aSubType > '' then
    Result := inherited GetDisplayName(aSubType)
  else
    Result := 'Таблица пользователя (простое дерево)';

end;

function TgdcAttrUserDefinedTree.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCATTRUSERDEFINEDTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDTREE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDTREE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
begin
  R := atDatabase.Relations.ByRelationName(ASubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType;
end;

function TgdcAttrUserDefinedTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedTree.GetRelationName: String;
begin
  Result := SubType;
end;

function TgdcAttrUserDefinedTree.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCATTRUSERDEFINEDTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDTREE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDTREE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Inherited GetSelectClause;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedTree.GetSubTypeList(SubTypeList: TStrings;
  Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

  { TODO : Временно пока нет наследования по Subtype }
  if Subtype > '' then
  begin
    Result := False;
    Exit;
  end;

  { TODO : этот метод будет вызываться часто и тут возможно замедление }
  with atDatabase.Relations do
  for I := 0 to Count - 1 do
  begin
    if
      Items[I].IsUserDefined and  Assigned(Items[I].PrimaryKey) and
      Assigned(Items[I].PrimaryKey.ConstraintFields) and
      (Items[I].PrimaryKey.ConstraintFields.Count = 1) and
      (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
      and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
      and not Assigned(Items[I].RelationFields.ByFieldName('LB'))
      and not Assigned(Items[I].RelationFields.ByFieldName('RB'))
    then
    begin
      Assert(SubTypeList.IndexOfName(Items[I].LNAME) = -1,
        'Duplicate local name of user defined table "' + Items[I].LNAME + '".');
      SubTypeList.Add(Items[I].LNAME + '=' + Items[I].RelationName);
    end;
  end;

  Result := SubTypeList.Count > 0;
end;


class function TgdcAttrUserDefinedTree.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  if atDatabase.Relations.ByRelationName(ASubType) = nil then
    Result := ''
  else
    Result := 'Tgdc_frmAttrUserDefinedTree';
end;

procedure TgdcAttrUserDefinedTree.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;
end;

{ TgdcAttrUserDefinedLBRBTree }

constructor TgdcAttrUserDefinedLBRBTree.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [];
end;

function TgdcAttrUserDefinedLBRBTree.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCATTRUSERDEFINEDLBRBTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDLBRBTREE', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDLBRBTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDLBRBTREE' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_dlgAttrUserDefinedTree.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDLBRBTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDLBRBTREE', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedLBRBTree.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  if aSubType <> '' then
    Result := inherited GetDisplayName(aSubType)
  else
    Result := 'Таблица пользователя (интервальное дерево)';

end;

function TgdcAttrUserDefinedLBRBTree.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCATTRUSERDEFINEDLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDLBRBTREE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDLBRBTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDLBRBTREE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedLBRBTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedLBRBTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
begin
  R := atDatabase.Relations.ByRelationName(ASubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedLBRBTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType
end;

function TgdcAttrUserDefinedLBRBTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedLBRBTree.GetRelationName: String;
begin
  Result := SubType;
end;

function TgdcAttrUserDefinedLBRBTree.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCATTRUSERDEFINEDLBRBTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTRUSERDEFINEDLBRBTREE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTRUSERDEFINEDLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTRUSERDEFINEDLBRBTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTRUSERDEFINEDLBRBTREE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Inherited GetSelectClause;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTRUSERDEFINEDLBRBTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTRUSERDEFINEDLBRBTREE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttrUserDefinedLBRBTree.GetSubTypeList(SubTypeList: TStrings;
  Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

  { TODO : Временно пока нет наследования по Subtype }
  if Subtype > '' then
  begin
    Result := False;
    Exit;
  end;

  { TODO : этот метод будет вызываться часто и тут возможно замедление }
  with atDatabase.Relations do
  for I := 0 to Count - 1 do
  begin
    if
      Items[I].IsUserDefined and  Assigned(Items[I].PrimaryKey) and
      Assigned(Items[I].PrimaryKey.ConstraintFields) and
      (Items[I].PrimaryKey.ConstraintFields.Count = 1) and
      (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
      and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
      and Assigned(Items[I].RelationFields.ByFieldName('LB'))
      and Assigned(Items[I].RelationFields.ByFieldName('RB'))

    then
    begin
      Assert(SubTypeList.IndexOfName(Items[I].LNAME) = -1,
        'Duplicate local name of user defined table "' + Items[I].LNAME + '".');
      SubTypeList.Add(Items[I].LNAME + '=' + Items[I].RelationName);
    end;
  end;

  Result := SubTypeList.Count > 0;
end;

class function TgdcAttrUserDefinedLBRBTree.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  if atDatabase.Relations.ByRelationName(ASubType) = nil then
    Result := ''
  else
    Result := 'Tgdc_frmAttrUserDefinedLBRBTree';
end;

procedure TgdcAttrUserDefinedLBRBTree.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;
end;

initialization
  RegisterGdcClass(TgdcAttrUserDefined);
  RegisterGdcClass(TgdcAttrUserDefinedTree);
  RegisterGdcClass(TgdcAttrUserDefinedLBRBTree);

finalization
  UnRegisterGdcClass(TgdcAttrUserDefined);
  UnRegisterGdcClass(TgdcAttrUserDefinedTree);
  UnRegisterGdcClass(TgdcAttrUserDefinedLBRBTree);
end.

