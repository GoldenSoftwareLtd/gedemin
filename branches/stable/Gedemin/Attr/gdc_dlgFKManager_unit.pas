unit gdc_dlgFKManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls;

type
  Tgdc_dlgFKManager = class(Tgdc_dlgTRPC)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgFKManager: Tgdc_dlgFKManager;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgFKManager);

finalization
  UnRegisterFrmClass(Tgdc_dlgFKManager);

end.
