// ShlTanya, 09.03.2019

unit gdc_dlgAcctFolder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, gsIBLookupComboBox, Mask, DBCtrls,
  Menus;

type
  Tgdc_dlgAcctFolder = class(Tgdc_dlgG)
    lblAlias: TLabel;
    dbedAlias: TDBEdit;
    lblName: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    gsiblcGroupAccount: TgsIBLookupComboBox;
    dbchbxDisabled: TDBCheckBox;
  private
  public
  end;

var
  gdc_dlgAcctFolder: Tgdc_dlgAcctFolder;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgAcctFolder);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctFolder);
end.
