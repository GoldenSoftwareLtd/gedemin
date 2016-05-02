unit gdc_dlgBlockRule_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_ClassList, gdc_dlgTRPC_unit, Db, IBCustomDataSet, gdcBase, gdcBlockRule,
  IBDatabase, Menus, ActnList, at_Container, DBCtrls, StdCtrls, ComCtrls;

type
  Tgdc_dlgBlockRule = class(Tgdc_dlgTRPC)
    gdcBlockRule: TgdcBlockRule;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgBlockRule: Tgdc_dlgBlockRule;

implementation

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgBlockRule);

finalization
  UnRegisterFrmClass(Tgdc_dlgBlockRule);
end.
