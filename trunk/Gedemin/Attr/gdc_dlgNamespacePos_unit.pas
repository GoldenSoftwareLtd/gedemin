unit gdc_dlgNamespacePos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, DBCtrls,
  ExtCtrls;

type
  Tgdc_dlgNamespacePos = class(Tgdc_dlgTR)
    Panel1: TPanel;
    lName: TLabel;
    dbchbxalwaysoverwrite: TDBCheckBox;
    dbchbxdontremove: TDBCheckBox;
    dbchbxincludesiblings: TDBCheckBox;
    dbtxtName: TDBText;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgNamespacePos: Tgdc_dlgNamespacePos;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFRMClass(Tgdc_dlgNamespacePos);

finalization
  UnRegisterFRMClass(Tgdc_dlgNamespacePos);

end.
