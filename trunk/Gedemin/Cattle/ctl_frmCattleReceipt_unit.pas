{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmCattleReceipt_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmCattleReceipt_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmMDHIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList, ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid,  gsReportRegistry, at_sql_setup,
  NumConv, gsReportManager, IBSQL;

type
  Tctl_frmCattleReceipt = class(Tgd_frmMDHIBF)
    actSetup: TAction;
    gsReportRegistry: TgsReportRegistry;
    pmPrint: TPopupMenu;
    atSQLSetup: TatSQLSetup;
    NumberConvert: TNumberConvert;
    tbSetup: TToolButton;
    actPayments: TAction;
    tbPaymentRoll: TToolButton;
    actPaymentRoll: TAction;
    tbRecallReceipt: TToolButton;
    actRecall: TAction;
    ibsqlGetInvoiceKey: TIBSQL;
    ToolButton1: TToolButton;
    actSelect: TAction;

    procedure actNewExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure gsReportRegistryBeforePrint(Sender: TObject; isRegistry,
      isQuick: Boolean);
    procedure actSetupExecute(Sender: TObject);
    procedure actPaymentsExecute(Sender: TObject);
    procedure actPaymentRollExecute(Sender: TObject);
    procedure actRecallExecute(Sender: TObject);
    procedure actRecallUpdate(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);

  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    function Get_SelectedKey: OleVariant; override;

  end;

var
  ctl_frmCattleReceipt: Tctl_frmCattleReceipt;

implementation

{$R *.DFM}

uses
  ctl_dlgMakeReceipts_unit, ctl_dlgReceipt_unit, gsStorage,
  dmDataBase_unit, ctl_CattleConstants_unit, ctl_dlgSetupReceipt_unit,
  ctl_dlgSetupCattle_unit, ctl_dlgMakePayments_unit,
  ctl_dlgPaymentRoll_unit, ctl_dlgDate_unit, Storages;


function Tctl_frmCattleReceipt.Get_SelectedKey: OleVariant;
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

class function Tctl_frmCattleReceipt.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmCattleReceipt) then
    ctl_frmCattleReceipt := Tctl_frmCattleReceipt.Create(AnOwner);
  Result := ctl_frmCattleReceipt;
end;

procedure Tctl_frmCattleReceipt.actNewExecute(Sender: TObject);
begin
  with Tctl_dlgMakeReceipts.Create(Self) do
  try
    if ProceedReceiptCreation then
    begin
      ibdsMain.DisableControls;

      ibdsMain.Close;
      ibdsMain.Open;

      ibdsMain.EnableControls;

      if LastReceiptKey > -1 then
      begin
        ibdsMain.Locate('documentkey', LastReceiptKey, []);
        ibgrMain.SelectedRows.Clear;
      end;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  if ibdsMain.IsEmpty then Exit;

  if ibgrMain.SelectedRows.Count > 0 then
  begin
    ibdsMain.DisableControls;
    try
      for I := 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        ibdsMain.GotoBookmark(Pointer(ibgrMain.SelectedRows.Items[I]));
        ibdsMain.Delete;
      end;
      IBTransaction.CommitRetaining;
    finally
      ibdsMain.EnableControls;
    end;
  end
  else
    if MessageBox(Handle, 'Удалить квитанцию?', 'Внимание!',
      MB_YESNO or MB_ICONQUESTION) = ID_YES then
    begin
      ibdsMain.Delete;
      IBTransaction.CommitRetaining;
    end;
end;

procedure Tctl_frmCattleReceipt.actEditExecute(Sender: TObject);
begin
  with Tctl_dlgReceipt.Create(Self) do
  try
    if EditReceipt(Self.ibdsMain) then
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

procedure Tctl_frmCattleReceipt.gsReportRegistryBeforePrint(
  Sender: TObject; isRegistry, isQuick: Boolean);
var
  F: TgsStorageFolder;
  List: TCalculationList;
  Z: Integer;
  Stream: TStream;
begin
  List := TCalculationList.Create;

  try
    F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
    Stream := TMemoryStream.Create;
    try
      F.ReadStream(VALUE_RECEIPT_FORMULA, Stream);

      if Stream <> nil then
        List.LoadFromStream(Stream)
      else
        raise Ectl_dlgMakeReceipts.Create(
          'Невозможно печатать квитанцию без настроек полей!');
    finally
      GlobalStorage.CloseFolder(F, False);
      Stream.Free;
    end;


    //
    //  Осуществляем добавление списка переменных

    with gsReportRegistry.VariableList do
    begin
      Clear;

      //
      //  Поставщик

      Add('Supplier=' + ibdsMain.FieldByName('SUPPLIER').AsString);

      Add('Province=' + ibdsMain.FieldByName('REGION').AsString);
      Add('District=' + ibdsMain.FieldByName('DISTRICT').AsString);

      //
      // Реквизиты

      Add('Number=' + ibdsMain.FieldByName('NUMBER').AsString);
      Add('ReceiptDate=' + ibdsMain.FieldByName('DOCUMENTDATE').AsString);
      Add('SheetNumber=' + ibdsMain.FieldByName('INVOICENUMBER').AsString);

      if ibdsMain.FieldByName('PURCHASEKIND').AsString = 'P' then
        Add('DeliveryKind=' + 'От населения') else
      if ibdsMain.FieldByName('DELIVERYKIND').AsString = 'C' then
        Add('DeliveryKind=' + 'ЦЕНТРОВЫВОЗ') else
      if ibdsMain.FieldByName('DELIVERYKIND').AsString = 'S' then
        Add('DeliveryKind=' + 'САМОВЫВОЗ') else
      if ibdsMain.FieldByName('DELIVERYKIND').AsString = 'P' then
        Add('DeliveryKind=' + 'РАЗГРУЗОЧНЫЙ ПОСТ');

      //
      //  Итоговые суммы

      for Z := 0 to List.Count - 1 do
        if List[Z].FieldName > '' then
          Add(
            List[Z].FieldName + '=' +
            ibdsMain.FieldByName(List[Z].FieldName).AsString
          );

      NumberConvert.Value := ibdsMain.FieldByName('SUMNCU').AsFloat;
      Add('AmountWritly=' + NumberConvert.Numeral);
    end;
  finally
    List.Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actSetupExecute(Sender: TObject);
begin
  with Tctl_dlgSetupCattle.Create(Self) do
  try
    Execute(ibdsMain.FieldByName('documentdate').AsDateTime);
  finally
    Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actPaymentsExecute(Sender: TObject);
begin
  with Tctl_dlgMakePayments.Create(Self) do
  try
    Execute;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actPaymentRollExecute(Sender: TObject);
begin
  with Tctl_dlgPaymentRoll.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actRecallExecute(Sender: TObject);
var
  I: Integer;
  IKey: Integer;
  BookMark: TBookmark;

  procedure GetIKey;
  begin
    ibsqlGetInvoiceKey.Close;
    ibsqlGetInvoiceKey.ParamByName('id').AsInteger :=
      ibdsMain.FieldByName('documentkey').AsInteger;
    ibsqlGetInvoiceKey.ExecQuery;
    if ibsqlGetInvoiceKey.RecordCount = 0 then
      IKey := -1
    else
      IKey := ibsqlGetInvoiceKey.FieldByName('documentkey').AsInteger;
  end;

begin
  BookMark := ibdsMain.GetBookmark;

  with Tctl_dlgMakeReceipts.Create(Self) do
  try
    if ibgrMain.SelectedRows.Count = 0 then
    begin
      GetIKey;
      if IKey <> -1 then
        MakeInvoice(IKey, ibdsMain.FieldByName('documentkey').AsInteger);
    end
    else
      for I := 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        ibdsMain.GotoBookmark(Pointer(ibgrMain.SelectedRows.Items[I]));
        GetIKey;
        if IKey <> -1 then
          MakeInvoice(IKey, ibdsMain.FieldByName('documentkey').AsInteger);
      end;
    ibdsMain.DisableControls;

    ibdsMain.Close;
    ibdsMain.Open;

    ibdsMain.EnableControls;
    ibdsMain.GotoBookmark(BookMark);
  finally
    Free;
  end;
end;

procedure Tctl_frmCattleReceipt.actRecallUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ibdsMain.RecordCount > 0;
end;

procedure Tctl_frmCattleReceipt.actSelectExecute(Sender: TObject);
var
  B: TBookMark;
begin
  with Tctl_dlgDate.Create(Self) do
  try
    if ShowModal = mrOk then
    begin
      ibdsMain.First;
      b := ibdsMain.GetBookmark;
      ibdsMain.DisableControls;
      while not ibdsMain.Eof do
      begin
        if ibdsMain.FieldByName('documentdate').AsdateTime = MonthCalendar.Date then
        begin
          ibgrMain.SelectedRows.CurrentRowSelected := True;
          B := ibdsMain.GetBookmark;
        end;
        ibdsMain.Next;
      end;
      ibdsMain.GotoBookmark(B);
      ibdsMain.EnableControls;
    end;
  finally
    Free;
  end;
end;

initialization

  ctl_frmCattleReceipt := nil;
  RegisterClass(Tctl_frmCattleReceipt);

end.
