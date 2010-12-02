unit gdc_dlgGoodMetal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  gd_security, IBDatabase, gdc_dlgG_unit, ActnList, Menus;

type
  Tgdc_dlgGoodMetal = class(Tgdc_dlgG)
    dbeName: TDBEdit;
    Label1: TLabel;
    lblTNVD: TLabel;
    dbmDescription: TDBMemo;
  private
  public
  end;

var
  gdc_dlgGoodMetal: Tgdc_dlgGoodMetal;

implementation

uses gd_security_OperationConst, gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgGoodMetal);

finalization
  UnRegisterFrmClass(Tgdc_dlgGoodMetal);

end.
