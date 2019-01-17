// andreik, 15.01.2019

unit gdc_frmCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gdcContacts, Db, IBCustomDataSet, gdcBase, gdcTree,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar;

type
  Tgdc_frmCompany = class(Tgdc_frmMDVTree)
    gdcFolder: TgdcFolder;
    gdcCompany: TgdcCompany;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmCompany: Tgdc_frmCompany;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmCompany.FormCreate(Sender: TObject);
begin
  gdcObject := gdcFolder;
  gdcDetailObject := gdcCompany;

  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmCompany);

finalization
  UnRegisterFRMClass(Tgdc_frmCompany);
end.
