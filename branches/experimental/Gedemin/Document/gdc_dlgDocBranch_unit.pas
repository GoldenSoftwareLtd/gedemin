unit gdc_dlgDocBranch_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Db, ActnList, ExtCtrls, DBCtrls, Mask, Menus,
  gsIBLookupComboBox;

type
  Tgdc_dlgDocBranch = class(Tgdc_dlgG)
    Label1: TLabel;
    dbeBranch: TDBEdit;
    dbmDescription: TDBMemo;
    Label2: TLabel;
    Bevel1: TBevel;
    iblcParent: TgsIBLookupComboBox;
    Label3: TLabel;
  private

  public

  end;

var
  gdc_dlgDocBranch: Tgdc_dlgDocBranch;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgDocBranch);

finalization
  UnRegisterFrmClass(Tgdc_dlgDocBranch);

end.
