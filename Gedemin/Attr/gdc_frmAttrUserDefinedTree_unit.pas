
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmAttrUserDefinedTree_unit.pas

  Abstract

    Part of gedemin project.
    View form for user defined tables with tree structure.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.


--}

unit gdc_frmAttrUserDefinedTree_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, IBDatabase, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcAttrUserDefined,
  gd_MacrosMenu, StdCtrls, gdcTree;

type
  Tgdc_frmAttrUserDefinedTree = class(Tgdc_frmMDVTree)
    Master: TgdcAttrUserDefinedTree;
    Detail: TgdcAttrUserDefinedTree;

    procedure FormCreate(Sender: TObject);

  private

  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    class procedure RegisterClassHierarchy; override;

  end;

var
  gdc_frmAttrUserDefinedTree: Tgdc_frmAttrUserDefinedTree;

implementation

{$R *.DFM}

uses at_classes,  gd_ClassList;

{ Tgdc_frmAttrUserDefinedTree }

constructor Tgdc_frmAttrUserDefinedTree.Create(AnOwner: TComponent);
begin
  inherited;
end;

class function Tgdc_frmAttrUserDefinedTree.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmAttrUserDefinedTree.FormCreate(Sender: TObject);
var
  R: TatRelation;
  LSubType: string;
begin
  gdcObject := Master;
  //gdcObject.SubType := FSubType;

  LSubtype := FSubType;
  While ClassParentSubtype(LSubtype) <> '' do
    LSubtype := ClassParentSubtype(LSubtype);
  R := atDatabase.Relations.ByRelationName(LSubType);
  Assert(R <> nil);

  if tvGroup.DisplayField = '' then
    tvGroup.DisplayField := R.ListField.FieldName;

  gdcDetailObject := Detail;
  gdcDetailObject.SubType := FSubType;
  gdcDetailObject.SubSet := 'ByParent';

  if tvGroup.DisplayField = '' then
    tvGroup.DisplayField := gdcObject.GetListField(gdcObject.SubType);

  inherited;

//  gdcObject.Open;
//  gdcDetailObject.Open;

  with atDatabase.Relations do
    if ByRelationName(FSubType) <> nil then
      Self.Caption := ByRelationName(FSubType).LName
    else
      Self.Caption := 'Подтип не определен!';

end;

class procedure Tgdc_frmAttrUserDefinedTree.RegisterClassHierarchy;

  procedure ReadFromRelations(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    SL: TStringList;
    I: Integer;
  begin
    if ACE.Initialized then
      exit;

    SL := TStringList.Create;
    try
      if ACE.SubType > '' then
      begin
        with atDatabase.Relations do
        for I := 0 to Count - 1 do
        if Items[I].IsUserDefined
          and Assigned(Items[I].PrimaryKey)
          and Assigned(Items[I].PrimaryKey.ConstraintFields)
          and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
          and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
          and  Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))
          and (AnsiCompareText(Items[I].RelationFields.ByFieldName('ID').ForeignKey.ReferencesRelation.RelationName,
            ACE.SubType) = 0) then
        begin
          SL.Add(Items[I].LName + '=' + Items[I].RelationName);
        end;
      end
      else
      begin
        with atDatabase.Relations do
        for I := 0 to Count - 1 do
          if Items[I].IsUserDefined
            and Assigned(Items[I].PrimaryKey)
            and Assigned(Items[I].PrimaryKey.ConstraintFields)
            and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
            and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
            and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
            and not Assigned(Items[I].RelationFields.ByFieldName('LB'))
            and not Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))then
          begin
            SL.Add(Items[I].LName + '=' + Items[I].RelationName);
          end;
      end;

      for I := 0 to SL.Count - 1 do
      begin
        CurrCE := gdClassList.Add(ACE.TheClass, SL.Values[SL.Names[I]], SL.Names[I],  ACE.SubType);
        ReadFromRelations(CurrCE);
      end;
    finally
      SL.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromRelations(CEBase);
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefinedTree);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefinedTree);

end.

