unit gdc_attr_dlgCheckConstraint_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls, gdcMetaData;

type
  Tgdc_dlgCheckConstraint = class(Tgdc_dlgGMetaData)
    dbeCheckName: TDBEdit;
    lblCheckName: TLabel;
    lblCheckExpression: TLabel;
    dbCheckExpression: TDBMemo;
    dbMsg: TDBMemo;
    lbMsg: TLabel;
  end;

var
  gdc_dlgCheckConstraint: Tgdc_dlgCheckConstraint;

implementation

uses at_classes, gd_ClassList;

{$R *.DFM}

{ Tgdc_dlgCheckConstraint }

initialization
  RegisterFrmClass(Tgdc_dlgCheckConstraint);

finalization
  UnRegisterFrmClass(Tgdc_dlgCheckConstraint);
end.
