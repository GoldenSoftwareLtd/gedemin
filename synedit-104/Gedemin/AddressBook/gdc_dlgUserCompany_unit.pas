
 {++
   Project ADDRESSBOOK
   Copyright © 2000- by Golden Software

   Модуль

     gdc_dlgCompany_unit

   Описание

     Окно для работы с компанией

   Автор

    Anton

   История

     ver    date    who    what
     1.00 - 25.06.2001 - anton - Первая версия

 --}


unit gdc_dlgUserCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBCtrls, StdCtrls, ComCtrls, Mask, gdc_dlgCustomCompany_unit, Db,
  IBCustomDataSet, gdcBase, gdcContacts, ActnList, at_Container,
  ToolWin, ExtCtrls, gsDBGrid, gsDBTreeView, gsIBLookupComboBox, Grids,
  DBGrids, Buttons, Menus, gsIBGrid, gdcTree, IBDatabase,
  TB2Item, TB2Dock, TB2Toolbar;

type
  Tgdc_dlgUserCompany = class(Tgdc_dlgCustomCompany)
  private
  public
  end;

var
  gdc_dlgUserCompany: Tgdc_dlgUserCompany;

implementation

{$R *.DFM}


uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgUserCompany);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserCompany);

end.
