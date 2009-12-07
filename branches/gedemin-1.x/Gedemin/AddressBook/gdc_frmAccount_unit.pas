unit gdc_frmAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcContacts,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmAccount = class(Tgdc_frmSGR)
    gdcAccount: TgdcAccount;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAccount: Tgdc_frmAccount;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmAccount.FormCreate(Sender: TObject);
begin
  gdcObject := gdcAccount;
  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmAccount);

finalization
  UnRegisterFRMClass(Tgdc_frmAccount);
end.
