// andreik, 15.01.2019

unit gdc_frmGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVGR_unit, Db, IBCustomDataSet, gdcBase, gdcTree, gdcContacts,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmGroup = class(Tgdc_frmMDVGr)
    gdcGroup: TgdcGroup;
    gdcBaseContact: TgdcBaseContact;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmGroup: Tgdc_frmGroup;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmGroup.FormCreate(Sender: TObject);
begin
  gdcObject := gdcGroup;
  gdcDetailObject := gdcBaseContact;
  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmGroup);

finalization
  UnRegisterFRMClass(Tgdc_frmGroup);
end.
