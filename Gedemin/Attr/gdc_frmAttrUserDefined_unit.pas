
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

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
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmAttrUserDefined: Tgdc_frmAttrUserDefined;

implementation

{$R *.DFM}

uses at_classes, gd_ClassList;

{ Tgdc_frmAttrUserDefined }

class function Tgdc_frmAttrUserDefined.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmAttrUserDefined.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAttrUserDefined;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefined);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefined);
end.

