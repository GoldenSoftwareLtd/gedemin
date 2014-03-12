unit gdc_dlgAcctSubAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgAcctBaseAccount_unit, Db, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, StdCtrls, gsIBLookupComboBox, ExtCtrls, DBCtrls, Mask,
  at_Container, IBDatabase, Menus, ComCtrls, Buttons;

type
  Tgdc_dlgAcctSubAccount = class(Tgdc_dlgAcctBaseAccount)
    lblHint: TLabel;
    procedure dbedAliasChange(Sender: TObject);
  private
  public
  end;

var
  gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount;

implementation

{$R *.DFM}

uses
  gd_ClassList, jclStrings;

procedure Tgdc_dlgAcctSubAccount.dbedAliasChange(Sender: TObject);
begin
  lblHint.Visible := StrIPos(gsiblcGroupAccount.Text, dbedAlias.Text) <> 1;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctSubAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctSubAccount);

end.
