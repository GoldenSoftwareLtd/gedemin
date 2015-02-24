
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

unit gdc_frmAttrUserDefinedLBRBTree_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, IBDatabase, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcAttrUserDefined,
  gd_MacrosMenu, StdCtrls, gdcTree;

type
  Tgdc_frmAttrUserDefinedLBRBTree = class(Tgdc_frmMDVTree)
    Master: TgdcAttrUserDefinedLBRBTree;
    Detail: TgdcAttrUserDefinedLBRBTree;

    procedure FormCreate(Sender: TObject);

  private

  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmAttrUserDefinedLBRBTree: Tgdc_frmAttrUserDefinedLBRBTree;

implementation

{$R *.DFM}

uses at_classes,  gd_ClassList;

{ Tgdc_frmAttrUserDefinedTree }

constructor Tgdc_frmAttrUserDefinedLBRBTree.Create(AnOwner: TComponent);
begin
  inherited;
end;

class function Tgdc_frmAttrUserDefinedLBRBTree.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmAttrUserDefinedLBRBTree.FormCreate(Sender: TObject);
begin
  gdcObject := Master;
  //gdcObject.SubType := FSubType;

  if tvGroup.DisplayField = '' then
    tvGroup.DisplayField := gdcObject.GetListField(gdcObject.SubType);

  gdcDetailObject := Detail;
  gdcDetailObject.SubType := FSubType;
  //gdcDetailObject.SubSet := 'ByLBRB';

  inherited;

  with atDatabase.Relations do
  begin
    if ByRelationName(FSubType) <> nil then
      Self.Caption := ByRelationName(FSubType).LName
    else
      Self.Caption := 'Подтип не определен!';
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefinedLBRBTree, ctUserDefinedLBRBTree);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefinedLBRBTree);

end.

