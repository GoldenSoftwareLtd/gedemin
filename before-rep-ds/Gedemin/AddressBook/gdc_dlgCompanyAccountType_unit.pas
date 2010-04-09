unit gdc_dlgCompanyAccountType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls, Db, gdc_dlgG_unit, Menus;

type
  Tgdc_dlgCompanyAccountType = class(Tgdc_dlgG)
    dbedName: TDBEdit;
    Label4: TLabel;
    DBText1: TDBText;
    Label1: TLabel;

  public
  end;

var
  gdc_dlgCompanyAccountType: Tgdc_dlgCompanyAccountType;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgCompanyAccountType);

finalization
  UnRegisterFrmClass(Tgdc_dlgCompanyAccountType);

end.
