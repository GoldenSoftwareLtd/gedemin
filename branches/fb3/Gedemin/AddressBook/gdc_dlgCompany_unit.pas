
 {++

   Copyright � 2000-2015 by Golden Software

   ������

     gdc_dlgCompany_unit

   ��������

     ���� ��� ������ � ���������

   �����

    Anton

   �������

     ver    date    who    what
     1.00 - 25.06.2001 - anton - ������ ������

 --}


unit gdc_dlgCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBCtrls, StdCtrls, gdc_dlgCustomCompany_unit, Menus, gdcContacts, Db,
  IBCustomDataSet, gdcBase, ActnList, at_Container, ComCtrls, ToolWin,
  ExtCtrls, gsDBTreeView, gsIBLookupComboBox, Grids,
  DBGrids, gsDBGrid, gsIBGrid, Mask, IBDatabase, gdcTree, TB2Item, TB2Dock,
  TB2Toolbar, JvDBImage;

type
  Tgdc_dlgCompany = class(Tgdc_dlgCustomCompany)
  end;

var
  gdc_dlgCompany: Tgdc_dlgCompany;

implementation

{$R *.DFM}


uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgCompany);

finalization
  UnRegisterFrmClass(Tgdc_dlgCompany);

end.
