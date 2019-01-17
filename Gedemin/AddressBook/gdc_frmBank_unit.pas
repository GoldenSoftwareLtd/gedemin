// andreik, 15.01.2019

unit gdc_frmBank_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcTree, gdcContacts;

type
  Tgdc_frmBank = class(Tgdc_frmSGR)
    gdcBank: TgdcBank;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmBank: Tgdc_frmBank;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmBank.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBank;
  inherited;
end;

initialization
  RegisterFRMClass(Tgdc_frmBank);
  
finalization
  UnRegisterFRMClass(Tgdc_frmBank);
end.
