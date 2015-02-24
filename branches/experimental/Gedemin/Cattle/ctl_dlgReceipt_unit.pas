
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgReceipt_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgReceipt_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_dlgG_unit, ActnList, StdCtrls, gsIBLookupComboBox, Mask, DBCtrls,
  ComCtrls, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, ToolWin,
  gsIBCtrlGrid, Db, IBCustomDataSet, IBDatabase, at_Container,
  FrmPlSvr, at_sql_setup, xCalc, gsTransaction;

type
  Tctl_dlgReceipt = class(Tgd_dlgG)
    pcReceipt: TPageControl;
    tsReceipt: TTabSheet;
    lblNumber: TLabel;
    dbeNumber: TDBEdit;
    lblDate: TLabel;
    dbeDate: TDBEdit;
    Label4: TLabel;
    dbeSheet: TDBEdit;
    Bevel1: TBevel;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actCopy: TAction;
    ibgrdReceiptLine: TgsIBCtrlGrid;
    dsReceipt: TDataSource;
    ibtrReceipt: TIBTransaction;
    ibdsReceipt: TIBDataSet;
    ibdsInvoiceLine: TIBDataSet;
    dsInvoiceLines: TDataSource;
    dsDocument: TDataSource;
    ibdsDocument: TIBDataSet;
    Label1: TLabel;
    dbeSumTotal: TDBEdit;
    atContainer: TatContainer;
    Label2: TLabel;
    dbeSumNCU: TDBEdit;
    FormPlaceSaver: TFormPlaceSaver;
    atSQLSetup: TatSQLSetup;
    actCompute: TAction;
    Button1: TButton;
    ibdsInvoice: TIBDataSet;
    DataSource1: TDataSource;
    gsTransaction: TgsTransaction;

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ibdsInvoiceLineAfterInsert(DataSet: TDataSet);
    procedure actComputeExecute(Sender: TObject);

  private
    FDataSet: TIBDataSet;
    FTransaction: TIBTransaction;
    FReceiptID: Integer;
    FKind: String;
    FTestChange: Boolean;

    procedure KillRequired;

    procedure MakeStartingSettings;
    procedure MakeFinishingSettings;

    function GetDataSet: TIBDataSet;
    function GetIsOwnDataSet: Boolean;
    function GetTransaction: TIBTransaction;
    procedure OnChange(Sender: TField);

  protected
    procedure CheckConsistency;

    property Transaction: TIBTransaction read GetTransaction;
    property IsOwnDataSet: Boolean read GetIsOwnDataSet;
    property DataSet: TIBDataSet read GetDataSet;

  public
    function EditReceipt: Boolean; overload;
    function EditReceipt(ADataSet: TIBDataSet): Boolean; overload;

    property ReceiptID: Integer read FReceiptID write FReceiptID;

  end;

  Ectl_dlgReceiptError = class(Exception);

var
  ctl_dlgReceipt: Tctl_dlgReceipt;

implementation

uses
  dmImages_unit, dmDataBase_unit, gd_security, ctl_ReceiptCalculator_unit,
  tr_type_unit, Storages;

{$R *.DFM}

const
  cst_small = 0.00000000001;

procedure Tctl_dlgReceipt.OnChange(Sender: TField);
begin
  if FTestChange then
  begin
    FTestChange := False;
    if FKind = 'M' then
    begin
      if Sender.FieldName = 'PRICE' then
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency := Round(
          ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsCurrency + cst_small)
      else
        if ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsInteger = 0 then
          ibdsInvoiceLine.FieldByName('PRICE').AsCurrency := 0
        else
          ibdsInvoiceLine.FieldByName('PRICE').AsCurrency :=
            Round(ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency /
            ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsInteger + cst_small)
    end
    else
    begin
      if Sender.FieldName = 'PRICE' then
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency :=
          Round(ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('REALWEIGHT').AsInteger + cst_small)
      else
        if ibdsInvoiceLine.FieldByName('REALWEIGHT').AsInteger = 0 then
          ibdsInvoiceLine.FieldByName('PRICE').AsCurrency := 0
        else
          ibdsInvoiceLine.FieldByName('PRICE').AsCurrency :=
            Round(ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency /
            ibdsInvoiceLine.FieldByName('REALWEIGHT').AsInteger + cst_small);
    end;
    FTestChange := True;
  end;
end;

function Tctl_dlgReceipt.EditReceipt: Boolean;
var
  T: TTransaction;
begin
  ibdsDocument.Close;

  if IsOwnDataSet then
    DataSet.Close;

  if not Transaction.Active then
    Transaction.StartTransaction;

  ibdsDocument.Params.ByName('DOCUMENTKEY').AsInteger := FReceiptID;
  ibdsDocument.Open;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('DOCUMENTKEY').AsInteger := FReceiptID;
    DataSet.Open;
  end;

  gsTransaction.AddConditionDataSet([ibdsDocument, dsReceipt.DataSet as TIBCustomDataSet,
    ibdsInvoice]);
  gsTransaction.SetStartTransactionInfo;

  if ibdsDocument.IsEmpty or DataSet.IsEmpty then
    raise Ectl_dlgReceiptError.Create('Can''t find record by identifier!');

  KillRequired;

  ibdsInvoice.Close;
  ibdsInvoice.ParamByName('RECEIPTKEY').AsInteger :=
    DataSet.FieldByName('DOCUMENTKEY').AsInteger;
  ibdsInvoice.Open;
  FKind := ibdsInvoice.FieldByName('KIND').AsString;

  ibdsDocument.Edit;
  DataSet.Edit;

  with ibdsDocument do
    FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;

  MakeStartingSettings;

  Result := ShowModal = mrOk;

  if Result then
  begin
    MakeFinishingSettings;

    if ibdsDocument.FieldByName('trtypekey').IsNull then
    begin
      T := gsTransaction.GetTransaction(nil);
      if Assigned(T) then
        ibdsDocument.FieldByName('trtypekey').AsInteger := T.TransactionKey;
    end;
    
    ibdsDocument.Post;
    DataSet.Post;

   //  позиции накладной необходимо сохранить
    ibdsInvoiceLine.ApplyUpdates;

    gsTransaction.CreateTransactionOnDataSet(-1,
      ibdsDocument.FieldByName('documentdate').AsDateTime);

    if IsOwnDataSet then
      Transaction.Commit;
  end else begin
    ibdsDocument.Cancel;
    DataSet.Cancel;

    if IsOwnDataSet then
      Transaction.Rollback;
  end;
end;

function Tctl_dlgReceipt.EditReceipt(ADataSet: TIBDataSet): Boolean;
begin
  FDataSet := ADataSet;
  FTransaction := FDataSet.Transaction;

  dsReceipt.DataSet := FDataSet;
  ibdsDocument.Transaction := FTransaction;

  ibdsInvoiceLine.Transaction := FTransaction;

  ibdsInvoice.Transaction := FTransaction;

  FReceiptID := FDataSet.FieldByName('DOCUMENTKEY').AsInteger;

  Result := EditReceipt;

  if Result then
  begin
    Transaction.CommitRetaining
  end
  else
    Transaction.RollbackRetaining;
end;

procedure Tctl_dlgReceipt.MakeFinishingSettings;
begin

end;

procedure Tctl_dlgReceipt.MakeStartingSettings;
var
  I: Integer;
begin
  pcReceipt.ActivePage := tsReceipt;
  ActiveControl := dbeDate;

  //
  //  список позиций накладной

  ibdsInvoiceLine.ParamByName('DOCUMENTKEY').AsInteger := FReceiptID;
  ibdsInvoiceLine.CachedUpdates := True;
  ibdsInvoiceLine.Open;
  ibdsInvoiceLine.FieldByName('PRICE').OnChange := OnChange;
  ibdsInvoiceLine.FieldByName('SUMNCU').OnChange := OnChange;

  //
  //  Делаем установки для колонок

  for I := 0 to ibgrdReceiptLine.Columns.Count - 1 do
  with ibgrdReceiptLine.Columns[I] do
  begin
    ReadOnly :=
      (AnsiCompareText(FieldName, 'PRICE') <> 0) and
      (AnsiCompareText(FieldName, 'SUMNCU') <> 0);
  end;
end;  

procedure Tctl_dlgReceipt.KillRequired;
var
  I: Integer;
begin
  for I := 0 to ibdsDocument.FieldCount - 1 do
    ibdsDocument.Fields[I].Required := False;

  for I := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[I].Required := False;
end;

function Tctl_dlgReceipt.GetDataSet: TIBDataSet;
begin
  if Assigned(FDataSet) then
    Result := FDataSet
  else
    Result := ibdsReceipt;
end;

function Tctl_dlgReceipt.GetIsOwnDataSet: Boolean;
begin
  Result := FDataSet = ibdsReceipt;
end;

function Tctl_dlgReceipt.GetTransaction: TIBTransaction;
begin
  if Assigned(FTransaction) then
    Result := FTransaction
  else
    Result := ibtrReceipt;
end;

procedure Tctl_dlgReceipt.CheckConsistency;
begin
  //
  //  Реквизиты накладной

  try
    if ibdsDocument.FieldByName('DOCUMENTDATE').IsNull then
    begin
      pcReceipt.ActivePage := tsReceipt;
      dbeDate.SetFocus;
      raise Ectl_dlgReceiptError.Create('Введите дату!');
    end else

    if ibdsDocument.FieldByName('NUMBER').IsNull then
    begin
      pcReceipt.ActivePage := tsReceipt;
      dbeNumber.SetFocus;
      raise Ectl_dlgReceiptError.Create('Введите номер накладной!');
    end else

    if DataSet.FieldByName('SUMTOTAL').IsNull then
    begin
      pcReceipt.ActivePage := tsReceipt;
      dbeSumTotal.SetFocus;
      raise Ectl_dlgReceiptError.Create('Укажите сумму по накладной!');
    end else

    if DataSet.FieldByName('SUMNCU').IsNull then
    begin
      pcReceipt.ActivePage := tsReceipt;
      dbeSumNCU.SetFocus;
      raise Ectl_dlgReceiptError.Create('Укажите поставщика!');
    end;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

procedure Tctl_dlgReceipt.actOkExecute(Sender: TObject);
begin
  CheckConsistency;
end;

procedure Tctl_dlgReceipt.actCancelExecute(Sender: TObject);
begin
  inherited;
//
end;

procedure Tctl_dlgReceipt.FormCreate(Sender: TObject);
begin
  inherited;
  FTestChange := True;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrdReceiptLine, ibgrdReceiptLine.LoadFromStream);
end;

procedure Tctl_dlgReceipt.FormDestroy(Sender: TObject);
begin
  inherited;

  if Assigned(UserStorage) then
    UserStorage.SaveComponent(ibgrdReceiptLine, ibgrdReceiptLine.SaveToStream);
end;

procedure Tctl_dlgReceipt.ibdsInvoiceLineAfterInsert(DataSet: TDataSet);
begin
  ibdsInvoiceLine.Cancel;
end;

procedure Tctl_dlgReceipt.actComputeExecute(Sender: TObject);
var
  BM: TBookmark;

  I: Integer;
  F: TField;
begin
  if MessageBox(Handle, 'Произвести перерасчет показателей квитанции?',
    'Внимание!', MB_YESNO or MB_ICONQUESTION) = ID_NO
  then
    Exit;

  BM := ibdsInvoiceLine.GetBookmark;
  ibdsInvoiceLine.DisableControls;

  ibdsInvoice.Close;
  ibdsInvoice.ParamByName('RECEIPTKEY').AsInteger :=
    DataSet.FieldByName('DOCUMENTKEY').AsInteger;
  ibdsInvoice.Open;

  with Tctl_ReceiptCalculator.Create do
  try
    SupplierKey := ibdsInvoice.FieldByName('SUPPLIERKEY').AsInteger;
    WasteCount := ibdsInvoice.FieldByName('WASTECOUNT').AsInteger;

    if ibdsInvoice.FieldByName('DELIVERYKIND').AsString > '' then
      DeliveryKind := ibdsInvoice.FieldByName('DELIVERYKIND').AsString[1];

    Database := dmDatabase.ibdbGAdmin;
    Transaction := Self.Transaction;

    ibdsInvoiceLine.First;

    while not ibdsInvoiceLine.EOF do
    begin

      //
      //  Рассчитываем итого

      ibdsInvoiceLine.Edit;
      FTestChange := False;

      if ibdsInvoice.FieldByName('KIND').AsString = 'M' then
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency :=
          Round(ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsCurrency + cst_small)
      else
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency :=
          Round(ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('REALWEIGHT').AsCurrency + cst_small);

      ibdsInvoiceLine.Post;

      //
      //  Определяем значения переменных

      TotalAmount := TotalAmount + ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency;
      Quantity := Quantity + ibdsInvoiceLine.FieldByName('QUANTITY').AsInteger;

      MeatWeight := MeatWeight + ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsCurrency;
      LiveWeight := LiveWeight + ibdsInvoiceLine.FieldByName('LIVEWEIGHT').AsCurrency;
      RealWeight := RealWeight + ibdsInvoiceLine.FieldByName('REALWEIGHT').AsCurrency;

      ibdsInvoiceLine.Next;
    end;

    //
    //  Осуществляем расчет

    Compute;

    if not (DataSet.State in [dsEdit, dsInsert]) then
      DataSet.Edit;

    DataSet.FieldByName('SUMTOTAL').AsCurrency := TotalAmount;
    DataSet.FieldByName('SUMNCU').AsCurrency := SumNCU;

    for I := 0 to CalculationList.Count - 1 do
    begin
      F := DataSet.FindField(CalculationList[I].FieldName);
      if not Assigned(F) then Continue;

      F.AsFloat := CalculationList[I].Calculation;
    end;

  finally
    Free;

    if ibdsInvoiceLine.BookmarkValid(BM) then
      ibdsInvoiceLine.GotoBookmark(BM);

    ibdsInvoiceLine.EnableControls;
    ibdsInvoice.Close;
  end;
end;

end.

