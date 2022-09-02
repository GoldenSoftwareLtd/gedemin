// ShlTanya, 29.01.2019

unit gdc_wage_frmPosition_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcWgPosition;

type
  Tgdc_wage_frmPosition = class(Tgdc_frmSGR)
    gdcWgPosition: TgdcWgPosition;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_wage_frmPosition: Tgdc_wage_frmPosition;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_wage_frmPosition.FormCreate(Sender: TObject);
begin
  gdcObject := gdcWgPosition;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_wage_frmPosition);

finalization
  UnRegisterFrmClass(Tgdc_wage_frmPosition);
end.
