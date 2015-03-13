
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
    //��� ������������� �� ������ ���� sql �� ���������
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
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

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
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

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
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    property RelationName: String read GetRelationName;
  end;

procedure Register;

//���������� ���� �������
function GetRUIDForRelation(const ARelationName: String): String;

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

{�� ������������ ������� ���������� �� ����}
function GetRUIDForRelation(const ARelationName: String): String;
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
        PChar('������ ��� ���������� ����-������. ������� ' +
        RelationName + ' �� �������! ���������� ���������������.'), '������!',
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
  CE: TgdClassEntry;
begin
  Result := inherited GetListField(ASubType);

  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  if Assigned(R) then
    Result := R.ListField.FieldName
end;

class function TgdcAttrUserDefined.GetListTable(const ASubType: TgdcSubType): String;
begin
  if ASubType = '' then
    Result := ''
  else
    Result := gdClassList.Get(TgdAttrUserDefinedEntry, Self.ClassName,
      ASubType).GetRootSubType.SubType;
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

class function TgdcAttrUserDefinedTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  CE: TgdClassEntry;
begin
  Result := inherited GetListField(ASubType);

  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  if Assigned(R) then
    Result := R.ListField.FieldName
end;

class function TgdcAttrUserDefinedTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  if ASubType = '' then
    Result := ''
  else
    Result := gdClassList.Get(TgdAttrUserDefinedEntry,
      Self.ClassName, ASubType).GetRootSubType.SubType;
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

class function TgdcAttrUserDefinedTree.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAttrUserDefinedTree';
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

class function TgdcAttrUserDefinedLBRBTree.GetListField(const ASubType: TgdcSubType): String;
var
  R: TatRelation;
  CE: TgdClassEntry;
begin
  Result := inherited GetListField(ASubType);

  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  if Assigned(R) then
    Result := R.ListField.FieldName
end;

class function TgdcAttrUserDefinedLBRBTree.GetListTable(const ASubType: TgdcSubType): String;
begin
  if ASubType = '' then
    Result := ''
  else
    Result := gdClassList.Get(TgdAttrUserDefinedEntry,
      Self.ClassName, ASubType).GetRootSubType.SubType;
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
  RegisterGdcClass(TgdcAttrUserDefined, '������� ������������');
  RegisterGdcClass(TgdcAttrUserDefinedTree, '������� ������������ (������� ������)');
  RegisterGdcClass(TgdcAttrUserDefinedLBRBTree, '������� ������������ (������������ ������)');

finalization
  UnregisterGdcClass(TgdcAttrUserDefined);
  UnregisterGdcClass(TgdcAttrUserDefinedTree);
  UnregisterGdcClass(TgdcAttrUserDefinedLBRBTree);
end.

