
 {++
   Project ADDRESSBOOK
   Copyright � 2000- by Golden Software

   ������

     gdc_dlgGroup_unit

   ��������

     ���������� ���� ��� ���������� � �������������� �����

   �����

.    Anton

   �������

     ver    date    who    what
     1.00 - 18.06.2000 - anton - ������ ������

 --}

unit gdc_dlgGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, ComCtrls, Mask, IBDatabase, IBCustomDataSet,
  IBUpdateSQL, Db, IBQuery, Menus, ShellApi, gd_security,
  gd_security_OperationConst, ActnList, IBSQL, 
  gdc_dlgCustomGroup_unit, Grids, DBGrids, gsDBGrid, gdcBase, gdcContacts,
  gsIBGrid, gsIBLookupComboBox, gdcTree, at_Container;

type
  Tgdc_dlgGroup = class(Tgdc_dlgCustomGroup)
  end;

var
  gdc_dlgGroup: Tgdc_dlgGroup;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgGroup);

end.
