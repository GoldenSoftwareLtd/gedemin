
{++

  Copyright (c) 2001-2012 by Golden Software of Belarus

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
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;
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

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    property RelationName: String read GetRelationName;
  end;

  TgdcAttrUserDefinedLBRBTree = class(TgdcLBRBTree)
  private
    function GetRelationName: String;
    function GetRelation: TatRelation;

  protected
    procedure SetActive(Value: Boolean); override;

    property Relation: TatRelation read GetRelation;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

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
    ibsql.SQL.Text := 'SELECT * FROM at_relations WHERE relationname = :rn';
    ibsql.ParamByName('rn').AsString := AnsiUpperCase(ARelationName);
    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      Result := gdcBaseManager.GetRuidStringByID(ibsql.FieldByName('id').AsInteger)
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
  I: Integer;
  S: String;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    S := ASubType
  else
    S := System.Copy(ASubType, I + 1, 1024);

  R := atDatabase.Relations.ByRelationName(S);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefined.GetListTable(const ASubType: TgdcSubType): String;
var
  I: Integer;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    Result := ASubType
  else
    Result := System.Copy(ASubType, I + 1, 1024);  
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
var
  I: Integer;
begin
  I := Pos('=', SubType);
  if I = 0 then
    Result := SubType
  else
    Result := System.Copy(SubType, I + 1, 1024);  
end;

class function TgdcAttrUserDefined.GetSubTypeList(SubTypeList: TStrings): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

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

class function TgdcAttrUserDefined.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
var
  I: Integer;
  S: String;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    S := ASubType
  else
    S := System.Copy(ASubType, I + 1, 1024);

  if atDatabase.Relations.ByRelationName(S) = nil then
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

class function TgdcAttrUserDefinedTree.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  if aSubType > '' then
    Result := inherited GetDisplayName(aSubType)
  else
    Result := 'Таблица пользователя (простое дерево)';
end;

class function TgdcAttrUserDefinedTree.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAttrUserDefinedTree';
end;

class function TgdcAttrUserDefinedTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  I: Integer;
  S: String;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    S := ASubType
  else
    S := System.Copy(ASubType, I + 1, 1024);

  R := atDatabase.Relations.ByRelationName(S);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedTree.GetListTable(const ASubType: TgdcSubType): String;
var
  I: Integer;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    Result := ASubType
  else
    Result := System.Copy(ASubType, I + 1, 1024);
end;

function TgdcAttrUserDefinedTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedTree.GetRelationName: String;
var
  I: Integer;
begin
  I := Pos('=', SubType);
  if I = 0 then
    Result := SubType
  else
    Result := System.Copy(SubType, I + 1, 1024);
end;

class function TgdcAttrUserDefinedTree.GetSubTypeList(SubTypeList: TStrings): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

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
var
  I: Integer;
  S: String;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    S := ASubType
  else
    S := System.Copy(ASubType, I + 1, 1024);

  if atDatabase.Relations.ByRelationName(S) = nil then
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

class function TgdcAttrUserDefinedLBRBTree.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  if aSubType <> '' then
    Result := inherited GetDisplayName(aSubType)
  else
    Result := 'Таблица пользователя (интервальное дерево)';

end;

class function TgdcAttrUserDefinedLBRBTree.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAttrUserDefinedTree';
end;

class function TgdcAttrUserDefinedLBRBTree.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcAttrUserDefinedLBRBTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  I: Integer;
  S: String;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    S := ASubType
  else
    S := System.Copy(ASubType, I + 1, 1024);

  R := atDatabase.Relations.ByRelationName(S);
  if Assigned(R) then
    Result := R.ListField.FieldName
  else
    Result := '';
end;

class function TgdcAttrUserDefinedLBRBTree.GetListTable(const ASubType: TgdcSubType): String;
var
  I: Integer;
begin
  I := Pos('=', ASubType);
  if I = 0 then
    Result := ASubType
  else
    Result := System.Copy(ASubType, I + 1, 1024);
end;

function TgdcAttrUserDefinedLBRBTree.GetRelation: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName(RelationName);
end;

function TgdcAttrUserDefinedLBRBTree.GetRelationName: String;
var
  I: Integer;
begin
  I := Pos('=', SubType);

  if I = 0 then
    Result := SubType
  else
    Result := System.Copy(SubType, I + 1, 1024);
end;

class function TgdcAttrUserDefinedLBRBTree.GetSubTypeList(SubTypeList: TStrings): Boolean;
var
  I: Integer;
begin
  SubTypeList.Clear;

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

