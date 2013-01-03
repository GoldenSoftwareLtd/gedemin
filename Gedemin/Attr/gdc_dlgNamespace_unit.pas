unit gdc_dlgNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, SynEdit, SynDBEdit;

type
  Tgdc_dlgNamespace = class(Tgdc_dlgTR)
    dbseHeader: TDBSynEdit;
    dbedName: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgNamespace: Tgdc_dlgNamespace;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFRMClass(Tgdc_dlgNamespace);

finalization
  UnRegisterFRMClass(Tgdc_dlgNamespace);
end.
