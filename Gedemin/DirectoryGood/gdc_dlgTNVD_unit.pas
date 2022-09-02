// ShlTanya, 29.01.2019

unit gdc_dlgTNVD_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, gd_security,
  IBDatabase, gdc_dlgG_unit, ActnList, gdcBase, gdcGood, Menus;

type
  Tgdc_dlgTNVD = class(Tgdc_dlgG)
    Label1: TLabel;
    dbeName: TDBEdit;
    lblTNVD: TLabel;
    dbmDescription: TDBMemo;
    gdcTNVD: TgdcTNVD;
  private
  public
  end;

var
  gdc_dlgTNVD: Tgdc_dlgTNVD;

implementation

uses gd_security_OperationConst, gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgTNVD);

finalization
  UnRegisterFrmClass(Tgdc_dlgTNVD);

end.
