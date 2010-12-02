unit gdc_dlgRplDatabase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_dlgRplDatabase = class(Tgdc_dlgTRPC)
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
  gdc_dlgRplDatabase: Tgdc_dlgRplDatabase;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgRplDatabase);

finalization
  UnRegisterFrmClass(Tgdc_dlgRplDatabase);
end.
