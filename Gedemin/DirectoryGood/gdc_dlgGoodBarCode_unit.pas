// ShlTanya, 29.01.2019

unit gdc_dlgGoodBarCode_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  ComCtrls, gd_security, gdc_dlgG_unit, ActnList, Menus;

type
  Tgdc_dlgGoodBarCode = class(Tgdc_dlgG)
    Label1: TLabel;
    lblTNVD: TLabel;
    dbeBarCode: TDBEdit;
    dbeDescription: TDBEdit;
  private
  public
  end;

var
  gdc_dlgGoodBarCode: Tgdc_dlgGoodBarCode;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgGoodBarCode);

finalization
  UnRegisterFrmClass(Tgdc_dlgGoodBarCode);

end.
