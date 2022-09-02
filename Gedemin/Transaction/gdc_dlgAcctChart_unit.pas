// ShlTanya, 09.03.2019

unit gdc_dlgAcctChart_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, Mask, DBCtrls, Menus;

type
  Tgdc_dlgAcctChart = class(Tgdc_dlgG)
    lblName: TLabel;
    dbedName: TDBEdit;
  private
  public
  end;

var
  gdc_dlgAcctChart: Tgdc_dlgAcctChart;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgAcctChart);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctChart);

end.
