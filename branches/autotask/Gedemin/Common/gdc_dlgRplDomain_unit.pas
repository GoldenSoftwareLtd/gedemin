unit gdc_dlgRplDomain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_dlgRplDomain = class(Tgdc_dlgTRPC)
    DBEdit1: TDBEdit;
    Label1: TLabel;
    DBEdit2: TDBEdit;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgRplDomain: Tgdc_dlgRplDomain;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgRplDomain);

finalization
  UnRegisterFrmClass(Tgdc_dlgRplDomain);
end.
