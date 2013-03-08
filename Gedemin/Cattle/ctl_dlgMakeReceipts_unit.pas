{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgMakeReceipts_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgMakeReceipts_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, ToolWin,
  ActnList, StdCtrls, Db, IBDatabase, IBCustomDataSet, IBSQL, DBClient,
  gd_createable_form, gsIBCtrlGrid, Contnrs, ctl_CattleConstants_unit,
  xCalc, at_sql_setup, FrmPlSvr, gsDocNumerator, Menus, gsTransaction, gdcConst;

type
  Tctl_dlgMakeReceipts = class(TForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    alMain: TActionList;
    actOk: TAction;
    actCancel: TAction;
    pnlMain: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Bevel1: TBevel;
    ibtrNewReceipt: TIBTransaction;
    dsReceipt: TDataSource;
    ibdsReceipt: TIBDataSet;
    ibsqlPricePos: TIBSQL;
    ibsqlContactProps: TIBSQL;
    ibdsDocument: TIBDataSet;
    dsDocument: TDataSource;
    ibdsInvoiceLine: TIBDataSet;
    dsInvoiceLine: TDataSource;
    ibdsInvoice: TIBDataSet;
    dsInvoice: TDataSource;
    btnSetup: TButton;
    actSetup: TAction;
    Calculator: TxFoCal;
    atSQLSetup: TatSQLSetup;
    ibsqlAutoTariff: TIBSQL;
    FormPlaceSaver: TFormPlaceSaver;
    dnReceipt: TgsDocNumerator;
    pmList: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    gsTransaction: TgsTransaction;
    ibsqlCustomerPricePos: TIBSQL;
    ibgrInvoice: TgsIBGrid;
    ibsqlDeleteReceipt: TIBSQL;
    ibdsGoodGroup: TIBDataSet;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
  // ���������� � ������� Compute
//    CoeffTariff: Currency;

    procedure Compute;
    procedure MakeVisibleList;

    function ChoosePrice(APurchaseKind, AKind: String): String;

  protected

  public
    LastReceiptKey: Integer;

    constructor Create(AnOwner: TComponent); override;

    function ProceedReceiptCreation: Boolean;
    function MakeInvoice(Invoicekey, ReceiptKey: Integer): Boolean;
  end;

  Ectl_dlgMakeReceipts = class(Exception);

var
  ctl_dlgMakeReceipts: Tctl_dlgMakeReceipts;

implementation

uses
  dmDataBase_unit, ctl_frmReferences_unit, ctl_dlgSetupPrice_unit,
  gd_security, gsStorage, gd_security_OperationConst,
  ctl_dlgSetupReceipt_unit, at_classes, Storages, gdcBaseInterface;

{$R *.DFM}

const
  cst_small = 0.00000000001;
  //�������� ��������� ��� ���������� ������������� ������
  cst_AutoTariff = 'AutoTariff';


function Round3(const Value: Double): Double;
begin
  Result := Round(Value * 1000 + cst_small) / 1000;
end;

function GetDateOnly(const D: TdateTime): TDateTime;
begin
  Result := D;
  ReplaceTime(Result, 0);
end;

function IsPriceListSetup: Boolean;
var
  F: TgsStorageFolder;
  S1, S2, S3, S4: String;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    S1 := F.ReadString(VALUE_PRICELIST_COMPANYCATTLE, '');
    S2 := F.ReadString(VALUE_PRICELIST_COMPANYMEATCATTLE, '');

    S3 := F.ReadString(VALUE_PRICELIST_FACECATTLE, '');
    S4 := F.ReadString(VALUE_PRICELIST_FACEMEATCATTLE, '');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;

  Result := (S1 > '') and (S2 > '') and (S3 > '') and (S4 > '');
end;

procedure ReadPriceListSetup(out Field1, Field2, Field3, Field4: String);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    Field1 := F.ReadString(VALUE_PRICELIST_COMPANYCATTLE, '');
    Field2 := F.ReadString(VALUE_PRICELIST_COMPANYMEATCATTLE, '');

    Field3 := F.ReadString(VALUE_PRICELIST_FACECATTLE, '');
    Field4 := F.ReadString(VALUE_PRICELIST_FACEMEATCATTLE, '');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

procedure ReadContactProps(out VAT, FarmTax, Distance, NDSTrans: String);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    VAT := Trim(F.ReadString(VALUE_SUPPLIER_VAT, ''));
    FarmTax := Trim(F.ReadString(VALUE_SUPPLIER_FARMTAX, ''));
    Distance := Trim(F.ReadString(VALUE_SUPPLIER_DISTANCE, ''));
    NDSTrans := Trim(F.ReadString(VALUE_SUPPLIER_NDSTRANS, ''));
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

function ReadFormulaStream: TStream;
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    Result := TMemoryStream.Create;
    F.ReadStream(VALUE_RECEIPT_FORMULA, Result);
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

{ Tctl_dlgMakeReceipts }

function Tctl_dlgMakeReceipts.MakeInvoice(Invoicekey, ReceiptKey: Integer): Boolean;
begin
  ibsqlDeleteReceipt.Close;
  ibsqlDeleteReceipt.ParamByName('documentkey').AsInteger := ReceiptKey;
  ibsqlDeleteReceipt.ExecQuery;

  ibdsInvoice.Close;
  ibdsInvoice.SelectSQL.Text :=
    ' SELECT ' +
    '   I.DOCUMENTKEY, ' +
    '   D.NUMBER, D.DOCUMENTDATE, ' +
    '   C.NAME AS SUPPLIER, ' +
    '   I.SUPPLIERKEY, ' +
    '   I.KIND, ' +
    '   I.PURCHASEKIND, ' +
    '   I.DELIVERYKIND, ' +
    '   I.RECEIPTKEY, ' +
    '   I.WASTECOUNT, ' +
    '   I.TTNNUMBER ' +
    ' FROM ' +
    '   CTL_INVOICE I ' +
    '     JOIN GD_DOCUMENT D ON ' +
    '       D.ID = I.DOCUMENTKEY ' +
    '     JOIN GD_CONTACT C ON ' +
    '       C.ID = I.SUPPLIERKEY ' +
    ' WHERE ' +
    '   I.DOCUMENTKEY = ' + IntToStr(InvoiceKey);
  MakeVisibleList;
  if not ibtrNewReceipt.Active then
    ibtrNewReceipt.StartTransaction;

  Result := ibdsInvoice.RecordCount > 0;
  if Result then
    Compute;
end;

procedure Tctl_dlgMakeReceipts.FormCreate(Sender: TObject);
begin
  if not ibtrNewReceipt.InTransaction then
    ibtrNewReceipt.StartTransaction;

  gsTransaction.AddConditionDataSet([ibdsDocument, ibdsReceipt, ibdsInvoice]);
  gsTransaction.SetStartTransactionInfo(False);

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrInvoice, ibgrInvoice.LoadFromStream);
end;

procedure Tctl_dlgMakeReceipts.FormDestroy(Sender: TObject);
begin
  if Assigned(UserStorage) then
    UserStorage.SaveComponent(ibgrInvoice, ibgrInvoice.SaveToStream);
end;

function Tctl_dlgMakeReceipts.ProceedReceiptCreation: Boolean;
begin
  //
  //  ���������� ��������� ��������� �����-�����

  if not IsPriceListSetup then
  begin
    MessageBox(Handle, PChar('��� �������� �������� ��������� ���������� ' +
      '��������� ����� � �����-������!'), '��������!', MB_OK or MB_ICONEXCLAMATION);

    //
    //  ���� ���� ��������� ��� - ����������
    //  �� �����������

    with Tctl_dlgSetupPrice.Create(Self) do
    try
      if not Execute then
        raise Ectl_dlgMakeReceipts.Create('���������� ������� ��������� ��� �������� �����!');
    finally
      Free;
    end;
  end;

  MakeVisibleList;

  Result := ShowModal = mrOk;
end;

procedure Tctl_dlgMakeReceipts.actOkExecute(Sender: TObject);
begin
  if not ibtrNewReceipt.Active then
    ibtrNewReceipt.StartTransaction;

  try
    Compute;

    if ibdsInvoice.Active then
    begin
      LastReceiptKey := ibdsInvoice.FieldByName('receiptkey').AsInteger;
    end else
      LastReceiptKey := -1;

    ibtrNewReceipt.Commit;
  except
    ibtrNewReceipt.Rollback;
    raise;
  end;
end;

procedure Tctl_dlgMakeReceipts.actCancelExecute(Sender: TObject);
begin
//
end;

function Tctl_dlgMakeReceipts.ChoosePrice(APurchaseKind, AKind: String): String;
var
  F1, F2, F3, F4: String;
begin
  ReadPriceListSetup(F1, F2, F3, F4);

  //  ��� ������ ���� ���������� ������:
  //  ��� ���������: �� ����, �� ����
  //  ��� �������: � ���-��, � �����

  if AKind = 'C' then
  begin
    if (APurchaseKind = 'G') or (APurchaseKind = 'C') then
      Result := F1 else

    if (APurchaseKind = 'P') then
      Result := F3;
  end else

  if AKind = 'M' then
  begin
    if (APurchaseKind = 'G') or (APurchaseKind = 'C') then
      Result := F2 else

    if (APurchaseKind = 'P') then
      Result := F4;
  end else
    raise Ectl_dlgMakeReceipts.Create('Invalid invoice kind!')
end;

procedure Tctl_dlgMakeReceipts.Compute;

const
  CoeffTransport = 1;

var
  Field: String;
  VATField, FarmTaxField, DistanceField, NDSTransField: String;
  TransactionKey: Integer;

  TotalAmount: Currency;
  Quantity: Integer;
  OnCostsCoeff: Currency;
  MeatWeight: Currency;
  LiveWeight: Currency;
  RealWeight: Currency;

  Distance: Currency;

  WasteCount: Integer;

  K: Integer;
  F: TField;

  List: TCalculationList;
  Results: array of Double;


  function CountTotalAmount: Currency;
  var
    Z: Integer;
    ReadStream: TStream;
  begin
    Calculator.Expression := '';

    Result := 0;
    //
    //  ��������� ��������� �������

    ReadStream := ReadFormulaStream;
    try
      if ReadStream <> nil then
        List.LoadFromStream(ReadStream)
      else
        raise Ectl_dlgMakeReceipts.Create(
          '���������� ������� ��������� ��� �������� �����!');

      SetLength(Results, List.Count);

      //
      //  ������������ ������� �����������

      for Z := 0 to List.Count - 1 do
      begin
        Calculator.Expression := List[Z].Formula;

        if AnsiCompareText(Calculator.Expression, 'Error') = 0 then
          raise Ectl_dlgMakeReceipts.Create('������ � ������� �������!');

        Calculator.AssignVariable(List[Z].VariableName, Calculator.Value);
        Results[Z] := Calculator.Value;
      end;

      Result := Calculator.Value;
    finally
      ReadStream.Free;
    end;
  end;

  function CountTransport: Currency;
  var
    Dist, Dist2: Currency; // ����������
    Coefficient, Coefficient1, CoefficientD, Coefficient1D: Currency; //: Double;
    Weight: Currency;
    Amount2: Currency;
    //TransConst: TgdcConst;
    CoeffTariff: Currency;
  begin
    Result := 0;

    // ���������, ��������� ������������ ����
    // � ��� �� ������� �� ���������
    if (ibdsInvoice.FieldByName('DELIVERYKIND').AsString = 'C') or
       (ibdsInvoice.FieldByName('contacttype').AsInteger = 2)
      {(ibdsInvoice.FieldByName('purchasekind').AsString = 'P')} then
      exit;

    //���������� ������������ �����
    {TransConst := TgdcConst.Create(Self);
    try}
      {CoeffTariff := StrToCurr(TransConst.GetValue(cst_AutoTariff,
        ibdsInvoice.FieldByName('DOCUMENTDATE').AsDateTime));}
      CoeffTariff := TgdcConst.QGetValueByNameAndDate(cst_AutoTariff,
        ibdsInvoice.FieldByName('DOCUMENTDATE').AsDateTime);


      //
      //  ���������� ���������� �� ����������

      if Distance < 200 then
      begin
        Dist := Distance;
        Dist2 := 0;
      end else begin
        Dist := 200;
        Dist2 := Distance - 200;
      end;

      { TODO 1 -o����� -c������� : ������� �������� �� ����������������� }
      if True then
        Weight := RealWeight
      else
        Weight := RealWeight;

      //
      //  �������� ������ �� ����������

      ibsqlAutoTariff.Close;

      ibsqlAutoTariff.ParamByName('DISTANCE').AsFloat := Dist;
      ibsqlAutoTariff.ExecQuery;

      if ibsqlAutoTariff.RecordCount = 0 then
      begin
        if MessageBox(
          Handle,
          PChar('�� ������ ����� ��� ������� ����������! ��������, ' +
          '�� ������� "' + ibdsInvoice.FieldByName('SUPPLIER').AsString +
          '" �� ������� ����������. ���������� ������?'),
          '��������!',
          MB_YESNO or MB_ICONQUESTION) = ID_YES
        then
          Abort;
      end;

      Coefficient1 := 0;

      // ��� ������ 500
      if Weight < 500 then
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_500').AsCurrency else

      // ��� ������ 1000
      if Weight < 1000 then
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_1000').AsCurrency else

      // ��� ������ 1500
      if Weight < 1500 then
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_1500').AsCurrency else

      // ��� ������ 2000
      if Weight < 2000 then
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_2000').AsCurrency else

      // ��� ������ 5000
      if Weight < 5000 then
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_5000').AsCurrency

      // ��� ������ 5000
      else begin
        Coefficient := ibsqlAutoTariff.FieldByName('TARIFF_5000').AsCurrency;
        Coefficient1 := ibsqlAutoTariff.FieldByName('TARIFF_S5000').AsCurrency;
      end;

      ibsqlAutoTariff.Close;

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      //
      //  �������� ������ �� ����������

      CoefficientD := 0;
      Coefficient1D := 0;

      if Dist2 > 0 then
      begin
        ibsqlAutoTariff.ParamByName('DISTANCE').AsFloat := 201;
        ibsqlAutoTariff.ExecQuery;

        if ibsqlAutoTariff.RecordCount = 0 then
        begin
          if MessageBox(
            Handle,
            PChar('�� ������ ����� ��� ������� ����������! ��������, ' +
            '�� ������� "' + ibdsInvoice.FieldByName('SUPPLIER').AsString +
            '" �� ������� ����������. ���������� ������?'),
            '��������!',
            MB_YESNO or MB_ICONQUESTION) = ID_YES
          then
            Abort;
        end;

        Coefficient1D := 0;

        // ��� ������ 500
        if Weight < 500 then
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_500').AsCurrency else

        // ��� ������ 1000
        if Weight < 1000 then
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_1000').AsCurrency else

        // ��� ������ 1500
        if Weight < 1500 then
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_1500').AsCurrency else

        // ��� ������ 2000
        if Weight < 2000 then
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_2000').AsCurrency else

        // ��� ������ 5000
        if Weight < 5000 then
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_5000').AsCurrency

        // ��� ������ 5000
        else begin
          CoefficientD := ibsqlAutoTariff.FieldByName('TARIFF_5000').AsCurrency;
          Coefficient1D := ibsqlAutoTariff.FieldByName('TARIFF_S5000').AsCurrency;
        end;

        ibsqlAutoTariff.Close;
      end;

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//      Coefficient := Coefficient + {Round3(}Dist2 * Coefficient{)};
//      Coefficient1 := Coefficient1 + {Round3(}Dist2 * Coefficient1{)};

      Coefficient := Coefficient + {Round3(}Dist2 * CoefficientD{)};
      Coefficient1 := Coefficient1 + {Round3(}Dist2 * Coefficient1D{)};

      Coefficient := Coefficient * CoeffTariff;
      Coefficient1 := Coefficient1 * CoeffTariff;

      // ��� ������ 2000
      if Weight < 2000 then
        Amount2 := Coefficient else

      // ��� ������ 5000
      if Weight < 5000 then
        Amount2:= {Round3(}Coefficient * Weight / 1000{)}

      // ��� ������ 5000
      else
        Amount2 := {Round3(}Coefficient * 5 + (Weight - 5000) * Coefficient1 / 1000{)};

      Result := Round(Amount2 * CoeffTransport);

    {finally
      TransConst.Free;
    end;}
  end;

  procedure MakeReceipt;
  var
    I: Integer;
  begin
    TotalAmount := 0;
    Quantity := 0;
    OnCostsCoeff := -1;
    MeatWeight := 0;
    LiveWeight := 0;
    RealWeight := 0;

    ibdsInvoiceLine.Close;
    ibdsInvoiceLine.ParamByName('DOCUMENTKEY').AsInteger :=
      ibdsInvoice.FieldByName('DOCUMENTKEY').AsInteger;
    ibdsInvoiceLine.Open;

    while not ibdsInvoiceLine.EOF do
    begin
      ibdsInvoiceLine.Edit;

      //
      //  ������� ������ �� �����-�����

      ibsqlPricePos.Close;
      ibsqlCustomerPricePos.Close;

      Field := ChoosePrice(
        ibdsInvoice.FieldByName('PURCHASEKIND').AsString,
        ibdsInvoice.FieldByName('KIND').AsString);

      //
      //  ������������ ����� ������ � ����������� �������
      //  ������� ������ ����� �����
      //  ���� �� ����, �� ������ ����� ��� ������ �������
      //  �� ������ � ��������, ��� ���� ������ ������-����� ����
      //  ������ ������

      ibsqlPricePos.Close;

      ibsqlPricePos.ParamByName('GOODKEY').AsInteger :=
        ibdsInvoiceLine.FieldByName('GOODKEY').AsInteger;

      ibsqlPricePos.ParamByName('INVOICEDATE').AsDateTime :=
        ibdsInvoice.FieldByName('DOCUMENTDATE').AsDateTime;

      ibsqlPricePos.ExecQuery;

      ibsqlCustomerPricePos.ParamByName('CONTACTKEY').AsInteger :=
        ibdsInvoice.FieldByName('SUPPLIERKEY').AsInteger;

      ibsqlCustomerPricePos.ParamByName('CONTACTKEY2').AsInteger :=
        ibdsInvoice.FieldByName('SUPPLIERKEY').AsInteger;

      ibsqlCustomerPricePos.ParamByName('GOODKEY').AsInteger :=
        ibdsInvoiceLine.FieldByName('GOODKEY').AsInteger;

      ibsqlCustomerPricePos.ParamByName('INVOICEDATE').AsDateTime :=
        ibdsInvoice.FieldByName('DOCUMENTDATE').AsDateTime;

      ibsqlCustomerPricePos.ExecQuery;

      if (ibsqlCustomerPricePos.RecordCount > 0) and
        (ibsqlCustomerPricePos.FieldByName('relevancedate').AsDateTime >= ibsqlPricePos.FieldByName('relevancedate').AsDateTime) then
      begin
        ibdsInvoiceLine.FieldByName('PRICEKEY').AsInteger :=
          ibsqlCustomerPricePos.FieldByName('PRICEKEY').AsInteger;

        ibdsInvoiceLine.FieldByName('PRICE').AsCurrency :=
          ibsqlCustomerPricePos.FieldByName(Field).AsCurrency;
      end else
      begin
        if ibsqlPricePos.RecordCount = 0 then
        begin
          raise Exception.Create('�� ��������� �������� ����� ������ ��� ����� ��:' + IntToStr(ibdsInvoiceLine.FieldByName('GOODKEY').AsInteger));
        end;

        ibdsInvoiceLine.FieldByName('PRICEKEY').AsInteger :=
          ibsqlPricePos.FieldByName('PRICEKEY').AsInteger;

        ibdsInvoiceLine.FieldByName('PRICE').AsCurrency :=
          ibsqlPricePos.FieldByName(Field).AsCurrency;
      end;

      ibsqlPricePos.Close;
      ibsqlCustomerPricePos.Close;

      //
      //  ������������ �����

      if ibdsInvoice.FieldByName('KIND').AsString = 'M' then
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency :=
          Round(ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsCurrency + cst_small)
      else
        ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency :=
          Round(ibdsInvoiceLine.FieldByName('PRICE').AsCurrency *
          ibdsInvoiceLine.FieldByName('REALWEIGHT').AsCurrency + cst_small);

      //
      //  ���������� �������� ����������

      TotalAmount := TotalAmount + ibdsInvoiceLine.FieldByName('SUMNCU').AsCurrency;
      Quantity := Quantity + ibdsInvoiceLine.FieldByName('QUANTITY').AsInteger;

      MeatWeight := MeatWeight + ibdsInvoiceLine.FieldByName('MEATWEIGHT').AsCurrency;
      LiveWeight := LiveWeight + ibdsInvoiceLine.FieldByName('LIVEWEIGHT').AsCurrency;
      RealWeight := RealWeight + ibdsInvoiceLine.FieldByName('REALWEIGHT').AsCurrency;

      if OnCostsCoeff = -1 then
      begin
        if (ibdsInvoice.FieldByName('kind').AsString = 'C') and
          (ibdsInvoice.FieldByName('purchasekind').AsString = 'P') and
          (ibdsInvoice.FieldByName('contacttype').AsInteger = 3) then
        begin
          ibdsGoodGroup.Close;
          ibdsGoodGroup.ParamByName('ID').AsInteger := ibdsInvoiceLine.FieldByName('goodkey').AsInteger;
          ibdsGoodGroup.Open;
          if (ibdsGoodGroup.FindField('usr$oncostscoeff') <> nil) and (not ibdsGoodGroup.FieldByName('usr$oncostscoeff').IsNull) then
            OnCostsCoeff := ibdsGoodGroup.FieldByName('usr$oncostscoeff').AsCurrency;
          ibdsGoodGroup.Close;
        end;
      end;

      //
      //  ���������,
      //  ��������� �� ��������� ������

      ibdsInvoiceLine.Post;
      ibdsInvoiceLine.Next;
    end;

    WasteCount := ibdsInvoice.FieldByName('WASTECOUNT').AsInteger;

    //
    //  ������������ ������ ��������� �� ������
    //  �������� ������

    ibsqlContactProps.Prepare;
    ibsqlContactProps.ParamByName('CONTACTKEY').AsInteger :=
      ibdsInvoice.FieldByName('SUPPLIERKEY').AsInteger;

    ibsqlContactProps.ExecQuery;

    //
    //  ��������� �������

    Calculator.ClearVariablesList;

    if ibsqlContactProps.RecordCount > 0 then
    begin
      Calculator.AssignVariable('�������_���',
        ibsqlContactProps.FieldByName(VATField).AsFloat);
      Calculator.AssignVariable('�������_���_������',
        ibsqlContactProps.FieldByName(NDSTransField).AsFloat);
      if ibdsInvoice.FieldByName('kind').AsString = 'M' then
        Calculator.AssignVariable('�������_������_��',
          ibsqlContactProps.FieldByName(FarmTaxField).AsFloat)
      else
        Calculator.AssignVariable('�������_������_��', 0);

      Distance := ibsqlContactProps.FieldByName(DistanceField).AsFloat;
    end else begin
      Calculator.AssignVariable('�������_���', 0);
      Calculator.AssignVariable('�������_������_��', 0);
      Calculator.AssignVariable('�������_���_������', 0);
      Distance := 0;
    end;

    if ibdsInvoice.FieldByName('purchasekind').AsString = 'P' then
    begin
      // �� 19.02.2002 ��� ������� �� ��������� �� �������� ���
      if ibdsInvoice.FieldByName('documentdate').AsDateTime < StrToDate('19.02.2002') then
        Calculator.AssignVariable('�������_���', 0);
      Calculator.AssignVariable('�������_������_��', 0);
    end;

    Calculator.AssignVariable('�����_���������', CountTransport);

    ibsqlContactProps.Close;

    Calculator.AssignVariable('�����_�����', TotalAmount);

    Calculator.AssignVariable('����������_�����', Quantity);
    Calculator.AssignVariable('����������_�����_��������', WasteCount);

    Calculator.AssignVariable('�����_�������', MeatWeight);
    Calculator.AssignVariable('�����_�����', LiveWeight);
    Calculator.AssignVariable('�����_�����_������', RealWeight);
    Calculator.AssignVariable('���_����_����_�����', OnCostsCoeff);

    // ���������� ����� � CountTotalAmount. �� �����
    // ��������� ��� ���������� ���������

    //
    //  ������� ���������

    ibdsDocument.Insert;
    ibdsDocument.FieldByName('ID').AsInteger := gdcBaseManager.GetNextID;
    ibdsDocument.FieldByName('DOCUMENTTYPEKEY').AsInteger := CTL_DOC_RECEIPT;
    ibdsDocument.FieldByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
    ibdsDocument.FieldByName('CREATORKEY').AsInteger := IBLogin.ContactKey;
    ibdsDocument.FieldByName('CREATIONDATE').AsDateTime := Now;
    ibdsDocument.FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;
    ibdsDocument.FieldByName('EDITIONDATE').AsDateTime := Now;
    ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime :=
      ibdsInvoice.FieldByName('DOCUMENTDATE').AsDateTime;

    if TransactionKey <> -1 then
      ibdsDocument.FieldByName('trtypekey').AsInteger := TransactionKey;

    ibdsDocument.FieldByName('AFULL').AsInteger := -1;
    ibdsDocument.FieldByName('ACHAG').AsInteger := -1;
    ibdsDocument.FieldByName('AVIEW').AsInteger := -1;

    ibdsDocument.FieldByName('number').AsString := ibdsInvoice.FieldByName('number').AsString;

    ibdsDocument.Post;

    ibdsReceipt.Insert;
    ibdsReceipt.FieldByName('DOCUMENTKEY').AsInteger :=
      ibdsDocument.FieldByName('ID').AsInteger;
    ibdsReceipt.FieldByName('SUMTOTAL').AsCurrency := Round(TotalAmount + cst_small);
    ibdsReceipt.FieldByName('REGISTERSHEET').AsString :=
      ibdsInvoice.FieldByName('TTNNUMBER').AsString;

    //
    //  ������ ���������� � ����������� �������� � ����

    ibdsReceipt.FieldByName('SUMNCU').AsCurrency := Round(CountTotalAmount + cst_small);

    for I := 0 to List.Count - 1 do
    begin
      F := ibdsReceipt.FindField(List[I].FieldName);
      if not Assigned(F) then Continue;

      F.AsFloat := Results[I];
    end;

    ibdsReceipt.Post;


    //
    // �������� ��������� �� ��������� � ���������

    ibdsInvoice.Edit;

    ibdsInvoice.FieldByName('RECEIPTKEY').AsInteger :=
      ibdsReceipt.FieldByName('DOCUMENTKEY').AsInteger;

    ibdsInvoice.Post;

    gsTransaction.CreateTransactionOnPosition(-1,
      ibdsInvoice.FieldByName('documentdate').AsDateTime,
      nil, nil, False);

    dmDatabase.ibdbGAdmin.ApplyUpdates(
    [ {ibdsDocument,}
      ibdsReceipt,
      ibdsInvoice,
      ibdsInvoiceLine]);

  end;


begin
  //
  //  ������������ ����������

  List := TCalculationList.Create;
  SetLength(Results, 0);

  TransactionKey := StrToIntDef(GlobalStorage.ReadString(FOLDER_CATTLE_SETTINGS,
    VALUE_RECEIPT_TRANSACTION, ''), -1);

  try

    //
    //  ���������� ������ � �������

    ReadContactProps(VATField, FarmTaxField, DistanceField, NDSTransField);

    ibsqlContactProps.SQL.Text := Format(
      'SELECT P.%s, P.%s, P.%s, P.%s FROM GD_CONTACTPROPS P WHERE P.CONTACTKEY = :CONTACTKEY',
      [Trim(VATField), Trim(FarmTaxField), Trim(DistanceField), Trim(NDSTransField)]);

    //
    //  ��������� �������, ��������� ������

    ibdsInvoice.Open;
    ibdsInvoice.First;

    ibdsInvoiceLine.Open;

    ibdsDocument.Open;

    ibdsReceipt.Open;

    if ibgrInvoice.SelectedRows.Count = 0 then
      MakeReceipt
    else
    begin
      ibdsInvoice.DisableControls;
      try
        for K := 0 to ibgrInvoice.SelectedRows.Count - 1 do
        begin
          ibdsInvoice.GotoBookmark(Pointer(ibgrInvoice.SelectedRows.Items[K]));
          MakeReceipt;
        end;
      finally
        ibdsInvoice.EnableControls;
      end;
    end;

    gsTransaction.AppendEntryToBase;
  finally
    List.Free;
  end;
end;

procedure Tctl_dlgMakeReceipts.MakeVisibleList;
begin
  ibdsInvoice.Open;

  ibdsInvoice.First;

{  while not ibdsInvoice.EOF do
  begin
    Item := lvReceipts.Items.Add;
    Item.Caption := ibdsInvoice.FieldByName('DOCUMENTDATE').AsString;
    Item.SubItems.Add(ibdsInvoice.FieldByName('SUPPLIER').AsString);
    Item.Data := Pointer(ibdsInvoice.FieldByName('documentkey').AsInteger);

    ibdsInvoice.Next;
  end;}
end;

procedure Tctl_dlgMakeReceipts.actSetupExecute(Sender: TObject);
begin
  with Tctl_dlgSetupReceipt.Create(Self) do
  try
    Execute;
  finally
    Free;
  end;
end;

procedure Tctl_dlgMakeReceipts.N1Click(Sender: TObject);
begin
  ibdsInvoice.First;
  ibdsInvoice.DisableControls;
  while not ibdsInvoice.Eof do
  begin
    ibgrInvoice.SelectedRows.CurrentRowSelected := True;
    ibdsInvoice.Next;
  end;
  ibdsInvoice.EnableControls;
end;

procedure Tctl_dlgMakeReceipts.N2Click(Sender: TObject);
begin
  ibgrInvoice.SelectedRows.Clear;
end;

procedure Tctl_dlgMakeReceipts.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ibdsInvoice.Active and (ibdsInvoice.RecordCount > 0);
end;

constructor Tctl_dlgMakeReceipts.Create(AnOwner: TComponent);
begin
  inherited;
  LastReceiptKey := -1;
end;

procedure Tctl_dlgMakeReceipts.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ibtrNewReceipt.InTransaction then
    ibtrNewReceipt.RollBack;
end;

end.

