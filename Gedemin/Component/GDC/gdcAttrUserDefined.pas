
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

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
    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

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
    procedure SetActive(Value: Boolean); override;

    function CreateDialogForm: TCreateableForm; override;

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    property RelationName: String read GetRelationName;
  end;

  TgdcAttrUserDefinedLBRBTree = class(TgdcLBRBTree)
  private
    function GetRelationName: String;
    function GetRelation: TatRelation;

  protected
    function CreateDialogForm: TCreateableForm; override;
    procedure SetActive(Value: Boolean); override;

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

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


function TgdcAttrUserDefined.GetCurrRecordClass: TgdcFullClass;
var
  ST: TStringList;
  I: Integer;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := RelationName;

  ST := TStringList.Create;
  try
    GetSubTypeList(ST, RelationName, False);
    for I := 0 to ST.Count - 1 do
    begin
      if not FieldByName(ST.Values[ST.Names[I]], 'INHERITEDKEY').IsNull then
        Result.SubType := ST.Values[ST.Names[I]];
    end;
  finally
    ST.Free;
  end;
end;

class function TgdcAttrUserDefined.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  LSubType: String;
begin
  LSubType := ASubType;
  while ClassParentSubType(LSubType) <> '' do
    LSubType := ClassParentSubtype(LSubType);

  R := atDatabase.Relations.ByRelationName(LSubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefined.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType;
  while ClassParentSubtype(Result) <> '' do
    Result := ClassParentSubtype(Result);
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

function TgdcAttrUserDefinedTree.GetCurrRecordClass: TgdcFullClass;
var
  ST: TStringList;
  I: Integer;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := RelationName;

  ST := TStringList.Create;
  try
    GetSubTypeList(ST, RelationName, False);
    for I := 0 to ST.Count - 1 do
    begin
      if not FieldByName(ST.Values[ST.Names[I]], 'INHERITEDKEY').IsNull then
        Result.SubType := ST.Values[ST.Names[I]];
    end;
  finally
    ST.Free;
  end;
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

class function TgdcAttrUserDefinedTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  LSubType: String;
begin
  LSubType := ASubType;
  While ClassParentSubType(LSubType) <> '' do
    LSubType := ClassParentSubtype(LSubType);

  R := atDatabase.Relations.ByRelationName(LSubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType;
  While ClassParentSubtype(Result) <> '' do
    Result := ClassParentSubtype(Result);
end;

function TgdcAttrUserDefinedTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedTree.GetRelationName: String;
begin
  Result := SubType;
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

function TgdcAttrUserDefinedLBRBTree.GetCurrRecordClass: TgdcFullClass;
var
  ST: TStringList;
  I: Integer;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := RelationName;

  ST := TStringList.Create;
  try
    GetSubTypeList(ST, RelationName, False);
    for I := 0 to ST.Count - 1 do
    begin
      if not FieldByName(ST.Values[ST.Names[I]], 'INHERITEDKEY').IsNull then
        Result.SubType := ST.Values[ST.Names[I]];
    end;
  finally
    ST.Free;
  end;
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

class function TgdcAttrUserDefinedLBRBTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedLBRBTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  LSubType: String;
begin
  LSubType := ASubType;
  While ClassParentSubType(LSubType) <> '' do
    LSubType := ClassParentSubtype(LSubType);

  R := atDatabase.Relations.ByRelationName(LSubType);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedLBRBTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := ASubType;
  While ClassParentSubtype(Result) <> '' do
    Result := ClassParentSubtype(Result);
end;

function TgdcAttrUserDefinedLBRBTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedLBRBTree.GetRelationName: String;
begin
  Result := SubType;
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
  if (SubType > '') or not Value then
    inherited;
end;

initialization
  RegisterGdcClass(TgdcAttrUserDefined, 'Таблица пользователя');
  RegisterGdcClass(TgdcAttrUserDefinedTree, 'Таблица пользователя (простое дерево)');
  RegisterGdcClass(TgdcAttrUserDefinedLBRBTree, 'Таблица пользователя (интервальное дерево)');

finalization
  UnregisterGdcClass(TgdcAttrUserDefined);
  UnregisterGdcClass(TgdcAttrUserDefinedTree);
  UnregisterGdcClass(TgdcAttrUserDefinedLBRBTree);
end.

