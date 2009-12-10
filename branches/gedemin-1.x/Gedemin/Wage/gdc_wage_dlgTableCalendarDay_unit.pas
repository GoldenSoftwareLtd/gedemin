
unit gdc_wage_dlgTableCalendarDay_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, IBDatabase, Menus, Db,
  ActnList, at_Container, ComCtrls, xDateEdits;

type
  Tgdc_wage_dlgTableCalendarDay = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    DBCheckBox1: TDBCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    xDateDBEdit1: TxDateDBEdit;
    xDateDBEdit2: TxDateDBEdit;
    xDateDBEdit3: TxDateDBEdit;
    xDateDBEdit4: TxDateDBEdit;
    xDateDBEdit5: TxDateDBEdit;
    xDateDBEdit6: TxDateDBEdit;
    xDateDBEdit7: TxDateDBEdit;
    xDateDBEdit8: TxDateDBEdit;
    xDateDBEdit9: TxDateDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_dlgTableCalendarDay: Tgdc_wage_dlgTableCalendarDay;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_wage_dlgTableCalendarDay);

finalization
  UnRegisterFrmClass(Tgdc_wage_dlgTableCalendarDay);
end.
