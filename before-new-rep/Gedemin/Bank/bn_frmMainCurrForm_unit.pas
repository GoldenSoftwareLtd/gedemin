unit bn_frmMainCurrForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, IBDatabase, Db, gsReportManager, flt_sqlFilter, Menus,
  ActnList,  Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls,
  ToolWin, ExtCtrls, gdcBase, TB2Item, TB2Dock, TB2Toolbar, StdCtrls,
  gd_MacrosMenu;

type
  Tbn_frmMainCurrForm = class(Tgdc_frmSGR)
  public
    function Get_SelectedKey: OleVariant; override;
  end;

var
  bn_frmMainCurrForm: Tbn_frmMainCurrForm;

implementation

{$R *.DFM}

uses gd_Security,  gd_ClassList;

function Tbn_frmMainCurrForm.Get_SelectedKey: OleVariant;
var
  A: Variant;
  I: Integer;
  Mark: TBookmark;

begin
  if not (gdcObject.Active and (gdcObject.RecordCount > 0)) then
    Result := VarArrayOf([])
  else
    if ibgrMain.SelectedRows.Count = 0 then
      Result := VarArrayOf([gdcObject.FieldByName('documentkey').AsInteger])
    else
    begin
      A := VarArrayCreate([0, ibgrMain.SelectedRows.Count - 1], varVariant);
      Mark := gdcObject.GetBookmark;
      gdcObject.DisableControls;

      for I := 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        gdcObject.GotoBookMark(Pointer(ibgrMain.SelectedRows.Items[I]));
        A[I] := gdcObject.FieldByName('documentkey').AsInteger;
      end;
      gdcObject.GotoBookMark(Mark);
      gdcObject.EnableControls;

      Result := A;
    end;
end;

initialization
  RegisterFrmClass(Tbn_frmMainCurrForm);

finalization
  UnRegisterFrmClass(Tbn_frmMainCurrForm);

end.
