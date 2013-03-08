{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmCattlePurchasing_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmCattlePurchasing_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmMDHIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid,  gsReportManager, IBStoredProc,
  IBSQL;

type
  Tctl_frmCattlePurchasing = class(Tgd_frmMDHIBF)
    tbtReferences: TToolButton;
    actSetup: TAction;
    ToolButton1: TToolButton;
    actRecalcWeight: TAction;
    spRecalcWeight: TIBStoredProc;
    ibsqlDest: TIBSQL;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailDeleteExecute(Sender: TObject);
    procedure actRecalcWeightExecute(Sender: TObject);
  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    function Get_SelectedKey: OleVariant; override;

  end;

var
  ctl_frmCattlePurchasing: Tctl_frmCattlePurchasing;

implementation

{$R *.DFM}

uses ctl_frmReferences_unit, ctl_dlgWeightInvoice_unit, ctl_dlgWeightInvoiceLine_unit,
     ctl_dlgSetupCattle_unit;

function Tctl_frmCattlePurchasing.Get_SelectedKey: OleVariant;
var
  A: Variant;
  I: Integer;
  Mark: TBookmark;

begin
  if not (ibdsMain.Active and (ibdsMain.RecordCount > 0)) then
    Result := VarArrayOf([])
  else
    if ibgrMain.SelectedRows.Count = 0 then
      Result := VarArrayOf([ibdsMain.FieldByName('documentkey').AsInteger])
    else
    begin
      A := VarArrayCreate([0, ibgrMain.SelectedRows.Count - 1], varVariant);
      Mark := ibdsMain.GetBookmark;
      ibdsMain.DisableControls;

      for I := 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        ibdsMain.GotoBookMark(Pointer(ibgrMain.SelectedRows.Items[I]));
        A[I] := ibdsMain.FieldByName('documentkey').AsInteger;
      end;
      ibdsMain.GotoBookMark(Mark);
      ibdsMain.EnableControls;

      Result := A;
    end;
end;

procedure Tctl_frmCattlePurchasing.actNewExecute(Sender: TObject);
begin
  with Tctl_dlgWeightInvoice.Create(Self) do
  try
    if AddInvoice(Self.ibdsMain) then
    begin
      ibdsMain.Refresh;

      ibdsDetails.DisableControls;
      try
        ibdsDetails.Close;
        ibdsDetails.Open;
      finally
        ibdsDetails.EnableControls;
      end;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattlePurchasing.actEditExecute(Sender: TObject);
var
  q: TIBSQL;
begin
  with Tctl_dlgWeightInvoice.Create(Self) do
  try
    if EditInvoice(Self.ibdsMain) then
    begin
      if not ibdsMain.FieldByName('receiptkey').IsNull then
      begin
        q := TIBSQL.Create(Self);
        try
          q.Transaction := IBTransaction;
          q.SQL.Text := 'DELETE FROM ctl_receipt WHERE documentkey=' +
            ibdsMain.FieldByName('receiptkey').AsString;
          q.ExecQuery;  
        finally
          q.Free;
        end;
      end;

      IBTransaction.CommitRetaining;

      ibdsMain.Refresh;

      ibdsDetails.DisableControls;
      try
        ibdsDetails.Close;
        ibdsDetails.Open;
      finally
        ibdsDetails.EnableControls;
      end;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattlePurchasing.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Удалить накладную?', 'Внимание!',
    MB_YESNO or MB_ICONEXCLAMATION) = ID_YES then
  begin
    ibdsMain.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

class function Tctl_frmCattlePurchasing.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmCattlePurchasing) then
    ctl_frmCattlePurchasing := Tctl_frmCattlePurchasing.Create(AnOwner);
  Result := ctl_frmCattlePurchasing;
end;

{
  Вызываем окно настроек
}

procedure Tctl_frmCattlePurchasing.actSetupExecute(Sender: TObject);
begin
  with Tctl_dlgSetupCattle.Create(Self) do
  try
    Execute(ibdsMain.FieldByName('documentdate').AsDateTime);
  finally
    Free;
  end;
end;

procedure Tctl_frmCattlePurchasing.actDetailNewExecute(Sender: TObject);
begin
  with Tctl_dlgWeightInvoiceLine.Create(Self) do
  try
    CanCommit := True;
    InvoiceID := ibdsMain.FieldByName('DOCUMENTKEY').AsInteger;
    InvoiceKind := ibdsMain.FieldByName('KIND').AsString;

    ibsqlDest.ExecQuery;
    if ibsqlDest.RecordCount > 0 then
      DestinationKey := ibsqlDest.FieldByName('ID').AsInteger
    else
      DestinationKey := -1;
    ibsqlDest.Close;  

    if AddInvoiceLine(ibdsDetails, 0) then
      ibdsDetails.Refresh;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattlePurchasing.actDetailEditExecute(Sender: TObject);
begin
  with Tctl_dlgWeightInvoiceLine.Create(Self) do
  try
    CanCommit := True;
    InvoiceID := ibdsMain.FieldByName('DOCUMENTKEY').AsInteger;
    InvoiceKind := ibdsMain.FieldByName('KIND').AsString;

    ibsqlDest.ExecQuery;
    if ibsqlDest.RecordCount > 0 then
      DestinationKey := ibsqlDest.FieldByName('ID').AsInteger
    else
      DestinationKey := -1;
    ibsqlDest.Close;  

    if EditInvoiceLine(ibdsDetails, 0) then
      ibdsDetails.Refresh;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattlePurchasing.actDetailDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Удалить позицию накладной?', 'Внимание!',
    MB_YESNO or MB_ICONEXCLAMATION) = ID_YES then
  begin
    ibdsDetails.Delete;
  end;
end;

procedure Tctl_frmCattlePurchasing.actRecalcWeightExecute(Sender: TObject);
begin
  spRecalcWeight.ExecProc;
  IBTransaction.CommitRetaining;
end;

initialization

  ctl_frmCattlePurchasing := nil;
  RegisterClass(Tctl_frmCattlePurchasing);

end.
