unit gdc_dlgReportGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls, DBCtrls, Mask,
  gsIBLookupComboBox, gdc_dlgTRPC_unit, IBDatabase, at_Container, ComCtrls;

type
  Tgdc_dlgReportGroup = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DBEdit1: TDBEdit;
    DBMemo1: TDBMemo;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgReportGroup: Tgdc_dlgReportGroup;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgReportGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgReportGroup);

end.
