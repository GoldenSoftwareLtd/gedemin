unit gdc_dlgGoodValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, gd_security,
  IBDatabase, dmDatabase_unit, gsIBLookupComboBox, gdc_dlgG_unit, ActnList,
  Menus;

type
  Tgdc_dlgGoodValue = class(Tgdc_dlgG)
    Label1: TLabel;
    dbeName: TDBEdit;
    Label2: TLabel;
    dbedDescription: TDBEdit;
    Label3: TLabel;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    DBCheckBox1: TDBCheckBox;
  private
  public
  end;

var
  gdc_dlgGoodValue: Tgdc_dlgGoodValue;

implementation

uses
  gd_security_OperationConst, gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgGoodValue);

finalization
  UnRegisterFrmClass(Tgdc_dlgGoodValue);

end.
