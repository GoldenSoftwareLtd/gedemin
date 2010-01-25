unit gdc_bug_dlgUpdate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, DBCtrls, Mask, IBDatabase, Db, ActnList,
  gsIBLookupComboBox, xDateEdits, ExtCtrls, Menus, gdc_dlgTR_unit,
  at_Container, ComCtrls;

type
  Tgdc_bug_dlgUpdate = class(Tgdc_dlgTRPC)
    xDateDBEdit1: TxDateDBEdit;
    iblkupFixer: TgsIBLookupComboBox;
    DBRadioGroup1: TDBRadioGroup;
    DBMemo1: TDBMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
  end;

var
  gdc_bug_dlgUpdate: Tgdc_bug_dlgUpdate;

implementation

{$R *.DFM}
uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_bug_dlgUpdate);

finalization
  UnRegisterFrmClass(Tgdc_bug_dlgUpdate);
end.
