// ShlTanya, 03.02.2019

unit gdc_frmRplDatabase2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcRplDatabase,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmRplDatabase2 = class(Tgdc_frmSGR)
    gdcRplDatabase2: TgdcRplDatabase2;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmRplDatabase2: Tgdc_frmRplDatabase2;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmRplDatabase2.FormCreate(Sender: TObject);
begin
  gdcObject := gdcRplDatabase2;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmRplDatabase2);

finalization
  UnRegisterFrmClass(Tgdc_frmRplDatabase2);
end.
