unit gdc_dlgAutoTask_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls;

type
  Tgdc_dlgAutoTask = class(Tgdc_dlgTR)
    DBEdit1: TDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgAutoTask: Tgdc_dlgAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTask);

end.
