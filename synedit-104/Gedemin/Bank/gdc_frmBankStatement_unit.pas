unit gdc_frmBankStatement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, flt_sqlFilter, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, gdcClasses,
  IBCustomDataSet, gdcBase, IBDatabase, IBQuery, StdCtrls, IBSQL,
  gd_security, gd_Security_body, gsIBLookupComboBox, gd_security_OperationConst,
  gsTransaction, gdcBaseInterface, gdcContacts, gdcStatement,
  FrmPlSvr, gdc_frmBankStatementBase_unit, TB2Dock, TB2Item, TB2Toolbar,
  gdcBaseBank, gdcTree, Buttons, gd_MacrosMenu;

type
  Tgdc_frmBankStatement = class(Tgdc_frmBankStatementBase)
    gdcBankStatementLine: TgdcBankStatementLine;
  end;

var
  gdc_frmBankStatement: Tgdc_frmBankStatement;

implementation

uses dmDataBase_unit,  gd_ClassList;

{$R *.DFM}


initialization
  RegisterFrmClass(Tgdc_frmBankStatement);

finalization
  UnRegisterFrmClass(Tgdc_frmBankStatement);
end.
