unit gdc_msg_dlgBox_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, gsDBTreeView, IBCustomDataSet, gdcBase,
  gdcTree, gdcMessage, gsIBLookupComboBox, dmDatabase_unit, Menus;

type
  Tgdc_msg_dlgBox = class(Tgdc_dlgTRPC)
    lblName: TLabel;
    dbedName: TDBEdit;
    iblkupBox: TgsIBLookupComboBox;
    lblBox: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_msg_dlgBox: Tgdc_msg_dlgBox;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_msg_dlgBox);
  //RegisterClass(Tgdc_msg_dlgBox);
finalization
  UnRegisterFrmClass(Tgdc_msg_dlgBox);

end.
