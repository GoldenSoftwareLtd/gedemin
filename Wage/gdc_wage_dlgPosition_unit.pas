
unit gdc_wage_dlgPosition_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_wage_dlgPosition = class(Tgdc_dlgTRPC)
    Label2: TLabel;
    DBEdit2: TDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_dlgPosition: Tgdc_wage_dlgPosition;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_wage_dlgPosition);

finalization
  UnRegisterFrmClass(Tgdc_wage_dlgPosition);
end.
