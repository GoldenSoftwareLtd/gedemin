unit gdc_dlgGoodGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, ActnList, gd_security, IBQuery, Db,
  IBCustomDataSet, IBStoredProc, IBUpdateSQL, {GroupType_unit,} IBSQL,
  IBDatabase, dmDatabase_unit, at_sql_setup, at_Container, ComCtrls,
  gdc_dlgG_unit, Menus, gsIBLookupComboBox;

type
  Tgdc_dlgGoodGroup = class(Tgdc_dlgG)
    PageControl1: TPageControl;
    tsGood: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbmDescription: TDBMemo;
    dbcbDisabled: TDBCheckBox;
    dbeName: TDBEdit;
    dbeAlias: TDBEdit;
    TabSheet1: TTabSheet;
    atContainer1: TatContainer;
    Label4: TLabel;
    iblcGoodGroup: TgsIBLookupComboBox;
    procedure FormCreate(Sender: TObject);
  private
  public
  
  end;

var
  gdc_dlgGoodGroup: Tgdc_dlgGoodGroup;

implementation

uses gd_security_OperationConst, gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgGoodGroup.FormCreate(Sender: TObject);
begin
  inherited;
  PageControl1.ActivePageIndex := 0;
end;

initialization
  RegisterFrmClass(Tgdc_dlgGoodGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgGoodGroup);

end.

