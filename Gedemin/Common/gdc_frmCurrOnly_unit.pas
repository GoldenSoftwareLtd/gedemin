// ShlTanya, 24.02.2019

unit gdc_frmCurrOnly_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcCurr, gd_MacrosMenu,
  Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls,
  TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmCurrOnly = class(Tgdc_frmSGR)
    gdcCurr: TgdcCurr;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmCurrOnly: Tgdc_frmCurrOnly;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmCurrOnly.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurr;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmCurrOnly);

finalization
  UnRegisterFrmClass(Tgdc_frmCurrOnly);
end.

 