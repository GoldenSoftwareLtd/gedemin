
unit gdc_frmContact_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gdcContacts, Db, IBCustomDataSet, gdcBase, gdcTree,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar;

type
  Tgdc_frmContact = class(Tgdc_frmMDVTree)
    gdcFolder: TgdcFolder;
    gdcContact: TgdcContact;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmContact: Tgdc_frmContact;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmContact.FormCreate(Sender: TObject);
begin
  gdcDetailObject := gdcContact;
  gdcObject := gdcFolder;
  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmContact);

finalization
  UnRegisterFRMClass(Tgdc_frmContact);
end.
