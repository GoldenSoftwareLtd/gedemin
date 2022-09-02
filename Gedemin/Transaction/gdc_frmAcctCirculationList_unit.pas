// ShlTanya, 09.03.2019

unit gdc_frmAcctCirculationList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList,
  gdcAcctConfig;

type
  Tgdc_frmAcctCirculationList = class(Tgdc_frmSGR)
    gdcAcctCicrilationListConfig: TgdcAcctCicrilationListConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAcctCirculationList: Tgdc_frmAcctCirculationList;

implementation

{$R *.DFM}

procedure Tgdc_frmAcctCirculationList.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctCicrilationListConfig;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmAcctCirculationList);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctCirculationList);
end.
