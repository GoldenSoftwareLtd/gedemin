{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgWeightInvoice_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgWeightInvoice_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, gsIBLookupComboBox, DBCtrls, Mask,
  xDateEdits, gsIBLargeTreeView, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ToolWin, Db, IBCustomDataSet, IBDatabase,
  DBClient, gsIBCtrlGrid, IBSQL, FrmPlSvr, gsDocNumerator, at_sql_setup,
  gd_createable_form;

type
  Tctl_dlgWeightInvoice = class(TCreateableForm)
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pcInvoice: TPageControl;
    tsInvoice: TTabSheet;
    tsInvoicePos: TTabSheet;
    luDepartment: TgsIBLookupComboBox;
    lblDate: TLabel;
    lblDepartment: TLabel;
    dbeDate: TxDateDBEdit;
    dbeNumber: TDBEdit;
    lblNumber: TLabel;
    lblTTN: TLabel;
    dbeTTN: TDBEdit;
    lblPurchaseKind: TLabel;
    lblSuplier: TLabel;
    luSupplier: TgsIBLookupComboBox;
    lblDeliveryKind: TLabel;
    dbeWasteCount: TDBEdit;
    lblWasteCount: TLabel;
    Bevel1: TBevel;
    cbForceSlaughter: TDBCheckBox;
    Bevel2: TBevel;
    Bevel3: TBevel;
    alMain: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actDuplicate: TAction;
    cbMain: TControlBar;
    tbMain: TToolBar;
    tbtNew: TToolButton;
    tbtEdit: TToolButton;
    tbtDelete: TToolButton;
    tbtDuplicate: TToolButton;
    ibgrdInvoiceLine: TgsIBCtrlGrid;
    ibtrInvoice: TIBTransaction;
    ibdsDocument: TIBDataSet;
    ibdsInvoice: TIBDataSet;
    dsDocument: TDataSource;
    dsInvoice: TDataSource;
    cbPurchaseKind: TComboBox;
    cbDeliveryKind: TComboBox;
    ibdsInvoiceLine: TIBDataSet;
    dsInvoiceLine: TDataSource;
    actOk: TAction;
    actCancel: TAction;
    cbKind: TComboBox;
    lblKind: TLabel;
    FormPlaceSaver: TFormPlaceSaver;
    dnInvoice: TgsDocNumerator;
    dbeDistance: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    dbeFarmTax: TDBEdit;
    Label3: TLabel;
    dbeVAT: TDBEdit;
    ibdsContactProps: TIBDataSet;
    atSQLSetup: TatSQLSetup;
    dsContactProps: TDataSource;
    lblDestination: TLabel;
    luDestination: TgsIBLookupComboBox;
    gbTotal: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    lbQuantity: TLabel;
    lbMeatWeight: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbLiveWeight: TLabel;
    lbRealWeight: TLabel;
    IBSQLDoubleList: TIBSQL;
    ibsqlUpdateLine: TIBSQL;
    IBSQLDeletePos: TIBSQL;
    Label8: TLabel;
    dbeNDSTrans: TDBEdit;
    pnlControlValues: TPanel;
    Label9: TLabel;
    lbWeight: TLabel;
    edQuantity: TEdit;
    edMeatWeight: TEdit;
    btnNext: TButton;
    actNext: TAction;
    Label11: TLabel;
    luRegion: TgsIBLookupComboBox;
    actChangeParams: TAction;
    ibsqlDistrict: TIBSQL;

    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ibgrdInvoiceLineDblClick(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure cbKindChange(Sender: TObject);
    procedure ibdsContactPropsAfterInsert(DataSet: TDataSet);
    procedure luSupplierChange(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure cbForceSlaughterKeyPress(Sender: TObject; var Key: Char);
    procedure cbPurchaseKindChange(Sender: TObject);
    procedure luRegionChange(Sender: TObject);
    procedure ibgrdInvoiceLineEnter(Sender: TObject);

  private
    FDataSet: TIBDataSet;
    FTransaction: TIBTransaction;
    FInvoiceID: Integer;
    FIsNew: Boolean;

    FirstTime: Boolean;

    function GetDataSet: TIBDataSet;
    function GetIsOwnDataSet: Boolean;
    function GetTransaction: TIBTransaction;

    procedure KillRequired;

    procedure MakeStartingSettings;
    procedure MakeFinishingSettings;

    procedure CalcCount;
    procedure GroupPosition;

  protected
    procedure CheckConsistency;
    procedure SynchronizeControls;

    property Transaction: TIBTransaction read GetTransaction;
    property IsOwnDataSet: Boolean read GetIsOwnDataSet;
    property DataSet: TIBDataSet read GetDataSet;

  public
    function AddInvoice: Boolean; overload;
    function AddInvoice(ADataSet: TIBDataSet): Boolean; overload;

    function EditInvoice: Boolean; overload;
    function EditInvoice(ADataSet: TIBDataSet): Boolean; overload;

    property InvoiceID: Integer read FInvoiceID write FInvoiceID;
  end;

  Ectl_WeightInvoiceError = class(Exception);

var
  ctl_dlgWeightInvoice: Tctl_dlgWeightInvoice;

implementation

{$R *.DFM}

uses
  dmDataBase_unit, ctl_dlgWeightInvoiceLine_unit, gd_security_OperationConst,
  gd_security,     gsStorage,                     ctl_CattleConstants_unit,
  Storages,        gdcBaseInterface;

const
  //константы для Березы (вид приемки)
  ctl_Cattle    = 147122985;   //по живой массе
  ctl_Meat      = 147122943;     //по мясу

type
  TWinControlCracker = class(TWinControl);

{ TdlgWeightInvoice }

procedure Tctl_dlgWeightInvoice.GroupPosition;
var
  LIVEWEIGHT: Double;
  MEATWEIGHT: Double;
  QUANTITY: Integer;
  REALWEIGHT: Double;
  FoodKey, ID: Integer;

  procedure EditFood;
  begin
    if FoodKey <> -1 then
    begin
      ibsqlUpdateLine.ParamByName('id').AsInteger := ID;
      ibsqlUpdateLine.ParamByName('LIVEWEIGHT').AsFloat := LIVEWEIGHT;
      ibsqlUpdateLine.ParamByName('MEATWEIGHT').AsFloat := MEATWEIGHT;
      ibsqlUpdateLine.ParamByName('QUANTITY').AsInteger := QUANTITY;
      ibsqlUpdateLine.ParamByName('REALWEIGHT').AsFloat := REALWEIGHT;
      ibsqlUpdateLine.ExecQuery;
    end;
  end;

begin
  if not FTransaction.Active then
    FTransaction.StartTransaction;

  IBSQLDoubleList.Transaction := FTransaction;
  ibsqlUpdateLine.Transaction := FTransaction;
  IBSQLDeletePos.Transaction := FTransaction;

  IBSQLDoubleList.Close;
  IBSQLDoubleList.ParamByName('invoicekey').AsInteger := FInvoiceID;
  IBSQLDoubleList.ExecQuery;

  FoodKey := -1;
  LIVEWEIGHT := 0;
  MEATWEIGHT := 0;
  QUANTITY := 0;
  REALWEIGHT := 0;
  ID := -1;

  while not IBSQLDoubleList.Eof do
  begin
    if FoodKey <> IBSQLDoubleList.FieldByName('goodKey').AsInteger then
    begin
      EditFood;

      FoodKey := IBSQLDoubleList.FieldByName('goodKey').AsInteger;
      ID := IBSQLDoubleList.FieldByName('id').AsInteger;
      LIVEWEIGHT := IBSQLDoubleList.FieldByName('LIVEWEIGHT').AsFloat;
      MEATWEIGHT := IBSQLDoubleList.FieldByName('MEATWEIGHT').AsFloat;
      QUANTITY := IBSQLDoubleList.FieldByName('QUANTITY').AsInteger;
      REALWEIGHT := IBSQLDoubleList.FieldByName('REALWEIGHT').AsFloat;
    end
    else
    begin
      LIVEWEIGHT := LIVEWEIGHT + IBSQLDoubleList.FieldByName('LIVEWEIGHT').AsFloat;
      MEATWEIGHT := MEATWEIGHT + IBSQLDoubleList.FieldByName('MEATWEIGHT').AsFloat;
      QUANTITY := QUANTITY + IBSQLDoubleList.FieldByName('QUANTITY').AsInteger;
      REALWEIGHT := REALWEIGHT + IBSQLDoubleList.FieldByName('REALWEIGHT').AsFloat;
      IBSQLDeletePos.ParamByName('id').AsInteger := IBSQLDoubleList.FieldByName('id').AsInteger;
      IBSQLDeletePos.ExecQuery;
    end;
    IBSQLDoubleList.Next;
  end;
  EditFood;
  FTransaction.CommitRetaining;
end;

procedure Tctl_dlgWeightInvoice.CalcCount;
var
  B: TBookmark;
begin
  if ibdsInvoiceLine.RecordCount > 0 then
  begin
    B := ibdsInvoiceLine.GetBookmark;
    ibdsInvoiceLine.DisableControls;
    ibdsInvoiceLine.First;
    lbQuantity.Caption := '0';
    lbRealWeight.Caption := '0';
    lbMeatWeight.Caption := '0';
    lbLiveWeight.Caption := '0';
    while not ibdsInvoiceLine.Eof do
    begin
      lbQuantity.Caption := FloatToStr(StrToFloat(lbQuantity.Caption) +
        ibdsInvoiceLine.FieldByName('QUANTITY').AsFloat);
      lbRealWeight.Caption := FloatToStr(StrToFloat(lbRealWeight.Caption) +
        ibdsInvoiceLine.FieldByName('RealWeight').AsFloat);
      lbMeatWeight.Caption := FloatToStr(StrToFloat(lbMeatWeight.Caption) +
        ibdsInvoiceLine.FieldByName('MeatWeight').AsFloat);
      lbLiveWeight.Caption := FloatToStr(StrToFloat(lbLiveWeight.Caption) +
        ibdsInvoiceLine.FieldByName('LiveWeight').AsFloat);
      ibdsInvoiceLine.Next;
    end;
    ibdsInvoiceLine.GotoBookmark(B);
    ibdsInvoiceLine.EnableControls;
  end;
end;

function Tctl_dlgWeightInvoice.AddInvoice: Boolean;
begin
  FIsNew := True;

  ibdsDocument.Close;

  if IsOwnDataSet then
    DataSet.Close;

  if not Transaction.Active then
    Transaction.StartTransaction;

  FInvoiceID := gdcBaseManager.GetNextID;

  ibdsDocument.Params.ByName('DOCUMENTKEY').AsInteger := FInvoiceID;
  ibdsDocument.Open;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('DOCUMENTKEY').AsInteger := FInvoiceID;
    DataSet.Open;
  end;

  ibdsContactProps.Open;

  with ibdsDocument do
  begin
    Insert;
    FieldByName('ID').AsInteger := FInvoiceID;
    FieldByName('DOCUMENTTYPEKEY').AsInteger := CTL_DOC_INVOICE;
    FieldByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
    FieldByName('CREATORKEY').AsInteger := IBLogin.ContactKey;
    FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;
    FieldByName('DOCUMENTDATE').AsDateTime := Now;

    FieldByName('AFULL').AsInteger := -1;
    FieldByName('ACHAG').AsInteger := -1;
    FieldByName('AVIEW').AsInteger := -1;
  end;

  with DataSet do
  begin
    Insert;
    FieldByName('DOCUMENTKEY').AsInteger := FInvoiceID;
  end;

  MakeStartingSettings;

  KillRequired;

  Result := ShowModal = mrOk;

  if Result then
  begin
    MakeFinishingSettings;
    ibdsDocument.Post;
    DataSet.Post;

    //  позиции накладной необходимо сохранить
    ibdsInvoiceLine.ApplyUpdates;

    if IsOwnDataSet then
      Transaction.Commit;
    GroupPosition;

  end else begin
    ibdsDocument.Cancel;
    DataSet.Cancel;

    if IsOwnDataSet then
      Transaction.Rollback;
  end;
end;

function Tctl_dlgWeightInvoice.AddInvoice(ADataSet: TIBDataSet): Boolean;
begin
  FDataSet := ADataSet;
  FTransaction := FDataSet.Transaction;

  dsInvoice.DataSet := FDataSet;
  ibdsDocument.Transaction := FTransaction;

  ibdsInvoiceLine.Transaction := FTransaction;

  Result := AddInvoice;

  if Result then
  begin
    Transaction.CommitRetaining;
    GroupPosition;
  end
  else
    Transaction.RollbackRetaining;
end;

function Tctl_dlgWeightInvoice.EditInvoice: Boolean;
var
  WeightFieldName: String;
begin
  ibdsDocument.Close;

  if IsOwnDataSet then
    DataSet.Close;

  if not Transaction.Active then
    Transaction.StartTransaction;

  ibdsDocument.Params.ByName('DOCUMENTKEY').AsInteger := FInvoiceID;
  ibdsDocument.Open;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('DOCUMENTKEY').AsInteger := FInvoiceID;
    DataSet.Open;
  end;

  ibdsContactProps.Open;

  if ibdsDocument.IsEmpty or DataSet.IsEmpty then
    raise Ectl_WeightInvoiceError.Create('Can''t find record by identifier!');

  ibdsDocument.Edit;
  DataSet.Edit;

  with ibdsDocument do
    FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;

  cbKind.Enabled := False;

  MakeStartingSettings;

  if ibdsInvoiceLine.RecordCount > 0 then
    luDestination.CurrentKeyInt := ibdsInvoiceLine.FieldByName('destkey').AsInteger;

  KillRequired;

  ibdsInvoiceLine.First;
  edQuantity.Text := '0';
  edMeatWeight.Text := '0';

  if cbKind.ItemIndex = 0 then //на скот
    WeightFieldName := 'RealWeight'
  else // на мясо
    WeightFieldName := 'MeatWeight';

  while not ibdsInvoiceLine.Eof do
  begin
    edQuantity.Text := FloatToStr(StrToFloat(edQuantity.Text) +
      ibdsInvoiceLine.FieldByName('QUANTITY').AsFloat);
    edMeatWeight.Text := FloatToStr(StrToFloat(edMeatWeight.Text) +
      ibdsInvoiceLine.FieldByName(WeightFieldName).AsFloat);
    ibdsInvoiceLine.Next;
  end;

  Result := ShowModal = mrOk;

  if Result then
  begin
    MakeFinishingSettings;
    ibdsDocument.Post;
    DataSet.Post;

    //  позиции накладной необходимо сохранить
    ibdsInvoiceLine.ApplyUpdates;

    if IsOwnDataSet then
      Transaction.Commit;

  end else begin
    ibdsDocument.Cancel;
    DataSet.Cancel;

    if IsOwnDataSet then
      Transaction.Rollback;
  end;
end;

function Tctl_dlgWeightInvoice.EditInvoice(ADataSet: TIBDataSet): Boolean;
begin
  FDataSet := ADataSet;
  FTransaction := FDataSet.Transaction;

  dsInvoice.DataSet := FDataSet;
  ibdsDocument.Transaction := FTransaction;

  ibdsInvoiceLine.Transaction := FTransaction;

  FInvoiceID := FDataSet.FieldByName('DOCUMENTKEY').AsInteger;

  Result := EditInvoice;

  if Result then
  begin
    Transaction.CommitRetaining;
    GroupPosition;
  end
  else
    Transaction.RollbackRetaining;
end;

function Tctl_dlgWeightInvoice.GetDataSet: TIBDataSet;
begin
  if Assigned(FDataSet) then
    Result := FDataSet
  else
    Result := ibdsInvoice;
end;

function Tctl_dlgWeightInvoice.GetIsOwnDataSet: Boolean;
begin
  Result := FDataSet = ibdsInvoice;
end;

function Tctl_dlgWeightInvoice.GetTransaction: TIBTransaction;
begin
  if Assigned(FTransaction) then
    Result := FTransaction
  else
    Result := ibtrInvoice;
end;

procedure Tctl_dlgWeightInvoice.KillRequired;
var
  I: Integer;
  C: TColumn;
begin
  for I := 0 to ibdsDocument.FieldCount - 1 do
    ibdsDocument.Fields[I].Required := False;

  for I := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[I].Required := False;

  for I := 0 to ibdsInvoiceLine.FieldCount - 1 do
  begin
    if ibdsInvoiceLine.Fields[I].Required then
    begin
      C := ibgrdInvoiceLine.ColumnByField(ibdsInvoiceLine.Fields[I]);

      if ibdsInvoiceLine.Fields[I].Required and
        (ibdsInvoiceLine.Fields[I] is TIntegerField)
      then
        C.ReadOnly := True;
    end;

    ibdsInvoiceLine.Fields[I].Required := False;
  end;

end;

procedure Tctl_dlgWeightInvoice.MakeFinishingSettings;
var
  F: TgsStorageFolder;
begin
  //
  //  вид накладной

  case cbKind.ItemIndex of
    0: // на скот
      DataSet.FieldByName('KIND').AsString := 'C';
    1: // на мясо
      DataSet.FieldByName('KIND').AsString := 'M';
  end;

  //
  // вид закупки

  case cbPurchaseKind.ItemIndex of
    0: // гос. закупка
      DataSet.FieldByName('PURCHASEKIND').AsString := 'G';
    1: // закупка у населения
      DataSet.FieldByName('PURCHASEKIND').AsString := 'P';
    2: // частный сектор
      DataSet.FieldByName('PURCHASEKIND').AsString := 'C';
  end;

  //
  // вид доставки

  case cbDeliveryKind.ItemIndex of
    0: // центровывоз
      DataSet.FieldByName('DELIVERYKIND').AsString := 'C';
    1: // самовызов
      DataSet.FieldByName('DELIVERYKIND').AsString := 'S';
    2: // самовывоз разгрузочный пост
      DataSet.FieldByName('DELIVERYKIND').AsString := 'P';
  end;

  //
  //  Настройки по умолчанию

  if FIsNew then
  begin
    F := UserStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);

    F.WriteInteger(LAST_CATTLE_KIND, cbKind.ItemIndex);
    F.WriteString(LAST_CATTLE_DEPARTMENT, luDepartment.CurrentKey);
    F.WriteInteger(LAST_CATTLE_PURCHASEKIND, cbPurchaseKind.ItemIndex);
    F.WriteString(LAST_CATTLE_REGION, luRegion.CurrentKey);
    F.WriteString(LAST_CATTLE_SUPPLIER, luSupplier.CurrentKey);
    F.WriteInteger(LAST_CATTLE_DELIVERYKIND, cbDeliveryKind.ItemIndex);
//    F.WriteString(LAST_CATTLE_RECEIVING, luReceivingKey.CurrentKey);
    F.WriteInteger(LAST_CATTLE_FORCESLAUGHTER, cbForceSlaughter.Field.AsInteger);
    F.WriteInteger(LAST_CATTLE_DESTINATION, luDestination.CurrentKeyInt);

    UserStorage.CloseFolder(F, True);
  end;
end;

procedure Tctl_dlgWeightInvoice.MakeStartingSettings;
var
  F: TgsStorageFolder;
begin
  pcInvoice.ActivePage := tsInvoice;
  ActiveControl := dbeDate;

  //
  //  вид накладной

  // на скот
  if DataSet.FieldByName('KIND').AsString = 'C' then
    cbKind.ItemIndex := 0 else
  // на мясо
  if DataSet.FieldByName('KIND').AsString = 'M' then
    cbKind.ItemIndex := 1
  else
    cbKind.ItemIndex := -1;

  tsInvoicePos.TabVisible := cbKind.ItemIndex <> -1;

  //
  //  вид закупки

  // гос. закупка
  if DataSet.FieldByName('PURCHASEKIND').AsString = 'G' then
    cbPurchaseKind.ItemIndex := 0 else
  // закупка у населения
  if DataSet.FieldByName('PURCHASEKIND').AsString = 'P' then
    cbPurchaseKind.ItemIndex := 1 else
  // частный сектор
  if DataSet.FieldByName('PURCHASEKIND').AsString = 'C' then
    cbPurchaseKind.ItemIndex := 2
  else
    cbPurchaseKind.ItemIndex := -1;

  //
  //  вид доставки

  // центровывоз
  if DataSet.FieldByName('DELIVERYKIND').AsString = 'C' then
    cbDeliveryKind.ItemIndex := 0 else
  // самовызов
  if DataSet.FieldByName('DELIVERYKIND').AsString = 'S' then
    cbDeliveryKind.ItemIndex := 1 else
  // самовывоз разгрузочный пост
  if DataSet.FieldByName('DELIVERYKIND').AsString = 'P' then
    cbDeliveryKind.ItemIndex := 2
  else
    cbDeliveryKind.ItemIndex := -1;

  //
  //  вынужденный убой

  if DataSet.FieldByName('FORCESLAUGHTER').IsNull then
    DataSet.FieldByName('FORCESLAUGHTER').AsInteger := 0;

  //
  //  список позиций накладной

  ibdsInvoiceLine.ParamByName('DOCUMENTKEY').AsInteger := FInvoiceID;
  ibdsInvoiceLine.CachedUpdates := True;
  ibdsInvoiceLine.Open;
  CalcCount;

  ibgrdInvoiceLine.ColumnByField(ibdsInvoiceLine.FieldByName('ALIAS')).
    ReadOnly := True;

  //
  //  Настройки по умолчанию

  if FIsNew then
  begin
    F := UserStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);

    cbKind.ItemIndex := F.ReadInteger(LAST_CATTLE_KIND, -1);
    luDepartment.CurrentKey := F.ReadString(LAST_CATTLE_DEPARTMENT, '');
    cbPurchaseKind.ItemIndex := F.ReadInteger(LAST_CATTLE_PURCHASEKIND, -1);
    luRegion.CurrentKey := F.ReadString(LAST_CATTLE_REGION, '');
    luSupplier.CurrentKey := F.ReadString(LAST_CATTLE_SUPPLIER, '');
    cbDeliveryKind.ItemIndex := F.ReadInteger(LAST_CATTLE_DELIVERYKIND, -1);
//    luReceivingKey.CurrentKey := F.ReadString(LAST_CATTLE_RECEIVING, '');
    cbForceSlaughter.Field.AsInteger := F.ReadInteger(LAST_CATTLE_FORCESLAUGHTER, 0);
    luDestination.CurrentKeyInt := F.ReadInteger(LAST_CATTLE_DESTINATION, -1);

    dbeWasteCount.Field.AsInteger := 0;

    UserStorage.CloseFolder(F, False);
  end;

  //
  // Зависимости от вида закупки

  cbKindChange(cbKind);

  SynchronizeControls;
end;

procedure Tctl_dlgWeightInvoice.actNewExecute(Sender: TObject);
begin
  with Tctl_dlgWeightInvoiceLine.Create(Self) do
  try
    if Self.luDestination.CurrentKey = '' then
    begin
      MessageBox(Handle, 'Выберите вид назначения', 'Внимание!', MB_OK);
      FocusControl(luDestination);
      exit;
    end;
    DestinationKey := Self.luDestination.CurrentKeyInt;
    CanCommit := False;
    InvoiceID := Self.InvoiceID;

    if cbKind.ItemIndex = 0 then
      InvoiceKind := 'C' else
    if cbKind.ItemIndex = 1 then
      InvoiceKind := 'M';

    if AddInvoiceLine(Self.ibdsInvoiceLine, StrToFloat(edQuantity.Text) -
      StrToFloat(lbQuantity.Caption)) then
    begin
      Self.ibdsInvoiceLine.Refresh;
      CalcCount;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_dlgWeightInvoice.actEditExecute(Sender: TObject);
begin
  with Tctl_dlgWeightInvoiceLine.Create(Self) do
  try
    CanCommit := False;
    InvoiceID := Self.InvoiceID;

    if cbKind.ItemIndex = 0 then
      InvoiceKind := 'C' else
    if cbKind.ItemIndex = 1 then
      InvoiceKind := 'M';

    EditInvoiceLine(Self.ibdsInvoiceLine, StrToFloat(edQuantity.Text) -
      StrToFloat(lbQuantity.Caption));
    CalcCount;
  finally
    Free;
  end;
end;

procedure Tctl_dlgWeightInvoice.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Удалить позицию накладной?', 'Внимание!',
    MB_YESNO or MB_ICONEXCLAMATION) = ID_YES then
  begin
    ibdsInvoiceLine.Delete;
    CalcCount;
  end;
end;

procedure Tctl_dlgWeightInvoice.CheckConsistency;
//var
//  WeightText: String;
begin
  if (cbDeliveryKind.ItemIndex > 0) and (dbeDistance.Field.AsFloat = 0)
   and (cbPurchaseKind.ItemIndex <> 1) then
  begin
    raise Exception.Create('Введите расстояние до клиента или укажите центровывоз!');
  end;

  //
  //  Реквизиты накладной
  try
    if ibdsDocument.FieldByName('DOCUMENTDATE').IsNull then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(dbeDate);
      raise Ectl_WeightInvoiceError.Create('Введите дату!');
    end else

    if ibdsDocument.FieldByName('NUMBER').IsNull then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(dbeNumber);
      raise Ectl_WeightInvoiceError.Create('Введите номер накладной!');
    end else

    if DataSet.FieldByName('TTNNUMBER').IsNull then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(dbeTTN);
      raise Ectl_WeightInvoiceError.Create('Введите номер ТТН!');
    end else

    if cbKind.ItemIndex = -1 then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(cbKind);
      raise Ectl_WeightInvoiceError.Create('Укажите вид накладной!');
    end else

    if DataSet.FieldByName('DEPARTMENTKEY').IsNull then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(luDepartment);
      raise Ectl_WeightInvoiceError.Create('Укажите подразделение предприятия!');
    end else

    if cbPurchaseKind.ItemIndex = -1 then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(cbPurchaseKind);
      raise Ectl_WeightInvoiceError.Create('Укажите вид закупки!');
    end else

    if DataSet.FieldByName('SUPPLIERKEY').IsNull then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(luSupplier);
      raise Ectl_WeightInvoiceError.Create('Укажите поставщика!');
    end else

    if cbDeliveryKind.ItemIndex = -1 then
    begin
      pcInvoice.ActivePage := tsInvoice;
      SetFocusedControl(cbDeliveryKind);
      raise Ectl_WeightInvoiceError.Create('Укажите вид доставки!');
    end else

    //Подставляем автоматичеки вид приемки
    if cbKind.ItemIndex = 0 then
    begin
      DataSet.FieldByName('RECEIVINGKEY').AsInteger := ctl_Cattle;
      if edMeatWeight.Text <> lbRealWeight.Caption then
      begin
        MessageBox(Handle, 'Не правильно введен живой вес со скидкой. Продолжить?', 'Внимание !',
          MB_YESNO or MB_ICONQUESTION);
        Abort;
      end;
    end
    else
    begin
      DataSet.FieldByName('RECEIVINGKEY').AsInteger := ctl_Meat;
      if edMeatWeight.Text <> lbMeatWeight.Caption then
      begin
        MessageBox(Handle, 'Не правильно введена убойная масса. Продолжить?', 'Внимание !',
          MB_YESNO or MB_ICONQUESTION);
        Abort;
      end;
    end;

    if edQuantity.Text <> lbQuantity.Caption then
    begin
      MessageBox(Handle, 'Неправильно введено количество голов. Продолжить?', 'Внимание !',
        MB_YESNO or MB_ICONQUESTION);
      Abort;
    end;

  except
    ModalResult := mrNone;
    raise;
  end;
end;

procedure Tctl_dlgWeightInvoice.actOkExecute(Sender: TObject);
begin
  CheckConsistency;
  ModalResult := mrOk;
end;

procedure Tctl_dlgWeightInvoice.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tctl_dlgWeightInvoice.FormCreate(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  { TODO : 
а если форма используется несколько раз без удаления?
FirstTime надо присваивать в ФормАктивате }
  FirstTime := True;
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    dbeVAT.DataField := Trim(F.ReadString(VALUE_SUPPLIER_VAT, ''));
    dbeFarmTax.DataField := Trim(F.ReadString(VALUE_SUPPLIER_FARMTAX, ''));
    dbeDistance.DataField := Trim(F.ReadString(VALUE_SUPPLIER_DISTANCE, ''));
    dbeNDSTRANS.DataField := Trim(F.ReadString(VALUE_SUPPLIER_NDSTRANS, ''));
  finally
    GlobalStorage.CloseFolder(F, False);
  end;

  UserStorage.LoadComponent(ibgrdInvoiceLine, ibgrdInvoiceLine.LoadFromStream);

  SynchronizeControls;

  FIsNew := False;
end;

procedure Tctl_dlgWeightInvoice.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(ibgrdInvoiceLine, ibgrdInvoiceLine.SaveToStream);
end;

procedure Tctl_dlgWeightInvoice.ibgrdInvoiceLineDblClick(Sender: TObject);
begin
  if (ibdsInvoiceLine.RecordCount > 0) and (ibdsInvoiceLine.State = dsBrowse) then
    actEdit.Execute;
end;

procedure Tctl_dlgWeightInvoice.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled := cbKind.ItemIndex <> -1;
end;

procedure Tctl_dlgWeightInvoice.cbKindChange(Sender: TObject);
begin
  tsInvoicePos.TabVisible := cbKind.ItemIndex <> -1;
  if cbKind.ItemIndex = 0 then
    lbWeight.Caption := 'Живой вес со скидкой:'
  else
    lbWeight.Caption := 'Убойная масса:';
end;

procedure Tctl_dlgWeightInvoice.ibdsContactPropsAfterInsert(
  DataSet: TDataSet);
begin
  if luSupplier.CurrentKey = '' then
    ibdsContactProps.Cancel
  else
    ibdsContactProps.FieldByName('CONTACTKEY').AsInteger :=
      Self.DataSet.FieldByName('SUPPLIERKEY').AsInteger;
end;

procedure Tctl_dlgWeightInvoice.luSupplierChange(Sender: TObject);
begin
  ibdsContactProps.Close;
  ibdsContactProps.Open;
  if (luSupplier.CurrentKey > '') {and (luRegion.CurrentKey = '')} then
  begin
    ibsqlDistrict.Close;
    ibsqlDistrict.ParamByName('id').AsInteger := luSupplier.CurrentKeyInt;
    ibsqlDistrict.ExecQuery;
    if ibsqlDistrict.RecordCount > 0 then
      luRegion.CurrentKeyInt := ibsqlDistrict.FieldByName('id').AsInteger;
  end;
end;

procedure Tctl_dlgWeightInvoice.actNextExecute(Sender: TObject);
var
  WC: TWinControl;
  L: TList;
  I: Integer;
begin
  if (Screen.ActiveControl <> nil) and (Screen.ActiveControl.Parent <> nil) then
  begin
    L := TList.Create;
    try
      Screen.ActiveControl.Parent.GetTabOrderList(L);
      for I := L.Count - 1 downto 0 do
        if not TWinControl(L[I]).TabStop then L.Delete(I);
      if ((L.Count = 0) or (Screen.ActiveControl = L[L.Count - 1])) and (Screen.ActiveControl.Parent.Parent <> nil) then
      begin
        if Screen.ActiveControl.Parent.Parent is TPageControl then
        begin
          if (Screen.ActiveControl.Parent.Parent as TPageControl).ActivePageIndex =
            (Screen.ActiveControl.Parent.Parent as TPageControl).PageCount - 1 then
          begin
            if Screen.ActiveControl.Parent.Parent.Parent <> nil then
            TWinControlCracker(Screen.ActiveControl.Parent.Parent.Parent).SelectNext(Screen.ActiveControl.Parent.Parent, True, False);
          end else
          begin
            WC := Screen.ActiveControl.Parent.Parent;
            (Screen.ActiveControl.Parent.Parent as TPageControl).SelectNextPage(True);
            Application.ProcessMessages;
            (WC as TPageControl).ActivePage.GetTabOrderList(L);
            for I := 0 to L.Count - 1 do
              if TWinControl(L[I]).TabStop then
                break;
  //          SetFocusedControl(TWinControl(L[I]));
  //          ActiveControl := TWinControl(L[I]);
          end;
        end else
        begin
          TWinControlCracker(Screen.ActiveControl.Parent.Parent).SelectNext(Screen.ActiveControl, True, True);
        end;
      end else
      begin
        TWinControlCracker(Screen.ActiveControl.Parent).SelectNext(Screen.ActiveControl, True, True);
      end;
    finally
      L.Free;
    end;
  end;
end;

procedure Tctl_dlgWeightInvoice.cbForceSlaughterKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key = '+')  then
    cbForceSlaughter.Checked := True
  else if (Key = '-') then
    cbForceSlaughter.Checked := False;
end;

procedure Tctl_dlgWeightInvoice.cbPurchaseKindChange(Sender: TObject);
begin
  SynchronizeControls;
end;

procedure Tctl_dlgWeightInvoice.luRegionChange(Sender: TObject);
begin
  SynchronizeControls;
end;

procedure Tctl_dlgWeightInvoice.SynchronizeControls;
begin
  inherited;

  luSupplier.Condition := 'contacttype IN (2, 3, 5)';
  luSupplier.gdClassName := 'TgdcBaseContact';

  {
  if cbPurchaseKind.ItemIndex = 1 then //закупка у населения
  begin
    luSupplier.Condition := 'contacttype = 2';
    luSupplier.gdClassName := 'TgdcContact';
  end
  else
  begin
    luSupplier.Condition := 'contacttype = 3';
    luSupplier.gdClassName := 'TgdcCompany';
  end;
  }

  if luRegion.CurrentKey > '' then
  begin
    luSupplier.Condition := luSupplier.Condition + ' and district = ''' + TrimRight(luRegion.Text) + '''';
  end;

end;

procedure Tctl_dlgWeightInvoice.ibgrdInvoiceLineEnter(Sender: TObject);
begin
// открываем окно для редактирования позиций только в первый раз
  if (ibdsDocument.State = dsInsert) and FirstTime then
  begin
    actNewExecute(Self);
    FirstTime := False;
  end;
end;

end.

