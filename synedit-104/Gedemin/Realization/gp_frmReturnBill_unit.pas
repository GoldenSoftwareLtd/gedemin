unit gp_frmReturnBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gp_frmRealizationBill_unit, IBSQL, at_sql_setup, gsReportRegistry, Menus,
  flt_sqlFilter, Db, IBCustomDataSet, IBDatabase, ActnList, 
   ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsReportManager;

type
  TfrmReturnBill = class(TfrmRealizationBill)
  private
    { Private declarations }
  protected
    function GetTypeDocumentKey: Integer; override;
    function CreateEditDialog: TForm; override;
    procedure DestroyEditDialog; override;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmReturnBill: TfrmReturnBill;

implementation

{$R *.DFM}

uses gp_dlgReturnBill_unit;

{ TfrmReturnBill }

class function TfrmReturnBill.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmReturnBill) then
    frmReturnBill := TfrmReturnBill.Create(AnOwner);

  Result := frmReturnBill;

end;

function TfrmReturnBill.CreateEditDialog: TForm;
begin
  Result := TdlgReturnBill.CreateAndAssign(Self);
end;

procedure TfrmReturnBill.DestroyEditDialog;
begin
//  if Assigned(dlgReturnBill) then
//    FreeAndNil(dlgReturnBill);
  dlgReturnBill := nil;
end;

function TfrmReturnBill.GetTypeDocumentKey: Integer;
begin
  Result := 802003;
end;

initialization
  RegisterClass(TfrmReturnBill);


end.
