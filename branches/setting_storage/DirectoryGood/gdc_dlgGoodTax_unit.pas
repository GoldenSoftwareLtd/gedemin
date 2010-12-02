unit gdc_dlgGoodTax_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  ComCtrls, gd_security, gdc_dlgG_unit, xDateEdits, ActnList, gdcBase,
  gdcGood, Menus;

type
  Tgdc_dlgGoodTax = class(Tgdc_dlgG)
    dbeName: TDBEdit;
    dbeRate: TDBEdit;
    Label1: TLabel;
    lblRate: TLabel;
  private
  public
  end;

var
  gdc_dlgGoodTax: Tgdc_dlgGoodTax;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgGoodTax);

finalization
  UnRegisterFrmClass(Tgdc_dlgGoodTax);

end.
