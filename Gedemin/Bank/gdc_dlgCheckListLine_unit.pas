// ShlTanya, 30.01.2019

unit gdc_dlgCheckListLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, Mask, DBCtrls, gsIBLookupComboBox,
  gdc_dlgTR_unit, IBDatabase, Menus;

type
  Tgdc_dlgCheckListLine = class(Tgdc_dlgTR)
    ibcmbAccount: TgsIBLookupComboBox;
    dbeSumNCU: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
  end;

var
  gdc_dlgCheckListLine: Tgdc_dlgCheckListLine;

implementation

uses dmDataBase_unit, gd_ClassList;

{$R *.DFM}

{ Tgdc_dlgCheckListLine }


initialization
  RegisterFrmClass(Tgdc_dlgCheckListLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgCheckListLine);

end.
