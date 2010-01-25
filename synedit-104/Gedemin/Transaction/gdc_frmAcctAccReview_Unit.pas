unit gdc_frmAcctAccReview_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList;

type
  Tgdc_frmAcctAccReview = class(Tgdc_frmSGR)
    gdcAcctAccReviewConfig: TgdcAcctAccReviewConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAcctAccReview: Tgdc_frmAcctAccReview;

implementation

{$R *.DFM}

procedure Tgdc_frmAcctAccReview.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctAccReviewConfig;
  gdcObject.Open;
end;

initialization
  RegisterFrmClass(Tgdc_frmAcctAccReview);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctAccReview);

end.
