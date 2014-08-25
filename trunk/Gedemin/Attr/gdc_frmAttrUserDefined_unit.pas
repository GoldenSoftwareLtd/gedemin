
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmAttrUserDefined_unit.pas

  Abstract

    Part of gedemin project.
    View form for user defined tables.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.


--}

unit gdc_frmAttrUserDefined_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gsDesktopManager,
  gdcAttrUserDefined, IBCustomDataSet, gdcBase, gsDBTreeView, StdCtrls,
  gd_MacrosMenu;

type
  Tgdc_frmAttrUserDefined = class(Tgdc_frmSGR)
    gdcAttrUserDefined: TgdcAttrUserDefined;

    procedure FormCreate(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    class procedure RegisterClassHierarchy; override;
    
  end;

var
  gdc_frmAttrUserDefined: Tgdc_frmAttrUserDefined;

implementation

{$R *.DFM}

uses at_classes, gd_ClassList;

{ Tgdc_frmAttrUserDefined }

constructor Tgdc_frmAttrUserDefined.Create(AnOwner: TComponent);
begin
  inherited;
end;

class function Tgdc_frmAttrUserDefined.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  result := nil;
end;

procedure Tgdc_frmAttrUserDefined.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAttrUserDefined;

  inherited;  

  with atDatabase.Relations do
    if ByRelationName(FSubType) <> nil then
      Self.Caption := ByRelationName(FSubType).LName
    else
      Self.Caption := 'Подтип не определен!';
end;

class procedure Tgdc_frmAttrUserDefined.RegisterClassHierarchy;

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
          SL.Add(Items[I].RelationName);
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
            and not Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
            and not Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))then
          begin
            SL.Add(Items[I].RelationName);
          end;
      end;

      for I := 0 to SL.Count - 1 do
      begin
        CurrCE := frmClassList.Add(ACE.TheClass, SL[I], ACE.SubType);
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
  CEBase := frmClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromRelations(CEBase);
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefined);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefined);


end.

