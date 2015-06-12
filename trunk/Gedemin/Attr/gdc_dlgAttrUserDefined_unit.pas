
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    gdc_dlgAttrUserDefined_unit.pas

  Abstract

    Part of gedemin project.
    Dialog window for user defined tables.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.

--}

unit gdc_dlgAttrUserDefined_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, Db, ActnList, StdCtrls, at_Container, ExtCtrls, gdcAttrUserDefined,
  Menus, gdc_dlgG_unit, IBDatabase;

type
  Tgdc_dlgAttrUserDefined = class(Tgdc_dlgTR)
    pnlMain: TPanel;
    atAttributes: TatContainer;
  end;

var
  gdc_dlgAttrUserDefined: Tgdc_dlgAttrUserDefined;

implementation
{$R *.DFM}

uses
  gd_ClassList;

{ Tgdc_dlgAttrUserDefined }

initialization
  RegisterFrmClass(Tgdc_dlgAttrUserDefined);

finalization
  UnRegisterFrmClass(Tgdc_dlgAttrUserDefined);
end.

