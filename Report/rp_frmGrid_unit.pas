unit rp_frmGrid_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, gsDBGrid;

type
  TfrmGrid = class(TFrame)
    dbgSource: TgsDBGrid;
    dsSource: TDataSource;
    procedure dsSourceStateChange(Sender: TObject);

  private
    FViewForm: TForm;

  public
    property ViewForm: TForm write FViewForm;
  end;

implementation

{$R *.DFM}

procedure TfrmGrid.dsSourceStateChange(Sender: TObject);
begin
  if (dsSource.DataSet <> nil)
    and (not dsSource.DataSet.Active)
    and (FViewForm <> nil)
    and FViewForm.Visible
    and (not (csDestroying in FViewForm.ComponentState)) then
  begin
    FViewForm.Hide;
    FViewForm := nil;
  end;
end;

end.
