// ShlTanya, 29.01.2019

unit gdc_wage_dlgHoliday_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, IBDatabase, Menus, Db,
  ActnList, at_Container, ComCtrls, xDateEdits;

type
  Tgdc_wage_dlgHoliday = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    Label2: TLabel;
    dbedName: TDBEdit;
    dbeHolidaydate: TxDateDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_dlgHoliday: Tgdc_wage_dlgHoliday;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_wage_dlgHoliday);

finalization
  UnRegisterFrmClass(Tgdc_wage_dlgHoliday);
end.
