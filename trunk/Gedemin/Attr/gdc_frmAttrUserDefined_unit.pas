
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

    class procedure RegisterClassHierarchy(AClass: TClass = nil;
      AValue: String = ''); override;
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

class procedure Tgdc_frmAttrUserDefined.RegisterClassHierarchy(AClass: TClass = nil;
  AValue: String = '');
begin
  TgdcAttrUserDefined.RegisterClassHierarchy(Self);
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefined);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefined);


end.

