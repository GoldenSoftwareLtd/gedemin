unit gdc_dlgAcctAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgAcctBaseAccount_unit, Db, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, StdCtrls, gsIBLookupComboBox, ExtCtrls, DBCtrls, Mask,
  at_Container, IBDatabase, Menus, ComCtrls;

type
  Tgdc_dlgAcctAccount = class(Tgdc_dlgAcctBaseAccount)
  private
  public
  end;

var
  gdc_dlgAcctAccount: Tgdc_dlgAcctAccount;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgAcctAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctAccount);

end.
