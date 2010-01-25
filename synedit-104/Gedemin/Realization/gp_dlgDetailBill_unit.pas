unit gp_dlgDetailBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ExtCtrls, Grids, DBGrids, gsDBGrid, Db,
  DBClient, ActnList, IBDatabase, dmDatabase_unit, IBSQL, gd_security,
  at_Classes, IBExtract, IBCustomDataSet,  Menus, FrmPlSvr,
  contnrs, xCalc;

type
  TdlgDetailBill = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    gsiblcBaseDocument: TgsIBLookupComboBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    lblContact: TLabel;
    gsiblcCompany: TgsIBLookupComboBox;
    lblNumberBill: TLabel;
    edNumBill: TEdit;
    bNew: TButton;
    bReplace: TButton;
    bDel: TButton;
    gsdbgrContact: TgsDBGrid;
    cdsListContact: TClientDataSet;
    cdsListContactContactKey: TIntegerField;
    cdsListContactContactName: TStringField;
    cdsListContactDocumentKey: TIntegerField;
    cdsListContactDocumentNumber: TStringField;
    dsListContact: TDataSource;
    gsdbgrGoodPos: TgsDBGrid;
    cdsGoodPos: TClientDataSet;
    cdsGoodPosDocRealPosKey: TIntegerField;
    cdsGoodPosGoodKey: TIntegerField;
    cdsGoodPosGoodName: TStringField;
    cdsGoodPosQuantityBase: TIBBCDField;
    cdsGoodPosQuantityRest: TIBBCDField;
    cdsGoodPosQuantity1: TIBBCDField;
    cdsGoodPosQuantity2: TIBBCDField;
    cdsGoodPosQuantity3: TIBBCDField;
    cdsGoodPosQuantity4: TIBBCDField;
    cdsGoodPosQuantity5: TIBBCDField;
    cdsGoodPosQuantity6: TIBBCDField;
    cdsGoodPosQuantity7: TIBBCDField;
    cdsGoodPosQuantity8: TIBBCDField;
    cdsGoodPosQuantity9: TIBBCDField;
    cdsGoodPosQuantity10: TIBBCDField;
    cdsGoodPosQuantity11: TIBBCDField;
    cdsGoodPosQuantity12: TIBBCDField;
    cdsGoodPosQuantity13: TIBBCDField;
    cdsGoodPosQuantity14: TIBBCDField;
    cdsGoodPosQuantity15: TIBBCDField;
    cdsGoodPosQuantity16: TIBBCDField;
    cdsGoodPosQuantity17: TIBBCDField;
    cdsGoodPosQuantity18: TIBBCDField;
    cdsGoodPosQuantity19: TIBBCDField;
    cdsGoodPosQuantity20: TIBBCDField;
    dsGoodPos: TDataSource;
    Panel7: TPanel;
    bOk: TButton;
    bNext: TButton;
    bCancel: TButton;
    bHelp: TButton;
    ActionList1: TActionList;
    actNew: TAction;
    actReplace: TAction;
    actDelete: TAction;
    actOk: TAction;
    actNext: TAction;
    actCancel: TAction;
    actHelp: TAction;
    IBTransaction: TIBTransaction;
    bMake: TButton;
    actMake: TAction;
    ibsqlDocument: TIBSQL;
    ibsqlDocRealization: TIBSQL;
    ibsqlDocRealPos: TIBSQL;
    cdsGoodPosValueKey: TIntegerField;
    cdsGoodPosMainQuantity: TIBBCDField;
    cdsGoodPosTrTypeKey: TIntegerField;
    cdsListContactFieldName: TStringField;
    cdsGoodPosWeight: TIBBCDField;
    cdsGoodPosWeightKey: TIntegerField;
    cdsAmount: TClientDataSet;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    StringField1: TStringField;
    IBBCDField1: TIBBCDField;
    IBBCDField2: TIBBCDField;
    IBBCDField3: TIBBCDField;
    IBBCDField4: TIBBCDField;
    IBBCDField5: TIBBCDField;
    IBBCDField6: TIBBCDField;
    IBBCDField7: TIBBCDField;
    IBBCDField8: TIBBCDField;
    IBBCDField9: TIBBCDField;
    IBBCDField10: TIBBCDField;
    IBBCDField11: TIBBCDField;
    IBBCDField12: TIBBCDField;
    IBBCDField13: TIBBCDField;
    IBBCDField14: TIBBCDField;
    IBBCDField15: TIBBCDField;
    IBBCDField16: TIBBCDField;
    IBBCDField17: TIBBCDField;
    IBBCDField18: TIBBCDField;
    IBBCDField19: TIBBCDField;
    IBBCDField20: TIBBCDField;
    IBBCDField21: TIBBCDField;
    IBBCDField22: TIBBCDField;
    dsAmount: TDataSource;
    PopupMenu1: TPopupMenu;
    actCalcAmount: TAction;
    N1: TMenuItem;
    cdsGoodPosAmountNCU: TCurrencyField;
    cdsGoodPosCostNCU: TCurrencyField;
    cbCheckQuantity: TCheckBox;
    FormPlaceSaver1: TFormPlaceSaver;
    ibdsDocRealInfo: TIBDataSet;
    gsdbgrName: TgsDBGrid;
    Panel8: TPanel;
    gsdbgrAmount: TgsDBGrid;
    gsDBGrid1: TgsDBGrid;
    cdsListContactContractKey: TIntegerField;
    cdsListContactContractName: TStringField;
    cdsGoodPosCostNCU1: TIBBCDField;
    cdsGoodPosCostNCU2: TIBBCDField;
    cdsGoodPosCostNCU3: TIBBCDField;
    cdsGoodPosCostNCU4: TIBBCDField;
    cdsGoodPosCostNCU5: TIBBCDField;
    cdsGoodPosCostNCU6: TIBBCDField;
    cdsGoodPosCostNCU7: TIBBCDField;
    cdsGoodPosCostNCU8: TIBBCDField;
    cdsGoodPosCostNCU9: TIBBCDField;
    cdsGoodPosCostNCU10: TIBBCDField;
    cdsGoodPosCostNCU11: TIBBCDField;
    cdsGoodPosCostNCU12: TIBBCDField;
    cdsGoodPosCostNCU13: TIBBCDField;
    cdsGoodPosCostNCU14: TIBBCDField;
    cdsGoodPosCostNCU15: TIBBCDField;
    cdsGoodPosCostNCU16: TIBBCDField;
    cdsGoodPosCostNCU17: TIBBCDField;
    cdsGoodPosCostNCU18: TIBBCDField;
    cdsGoodPosCostNCU19: TIBBCDField;
    cdsGoodPosCostNCU20: TIBBCDField;
    actNaturalLoss: TAction;
    rgCostType: TRadioGroup;
    lPrice: TLabel;
    gsiblcPrice: TgsIBLookupComboBox;
    lPriceField: TLabel;
    cbPriceField: TComboBox;
    Label2: TLabel;
    edOtherBill: TEdit;
    Label4: TLabel;
    cdsListContactPriceKey: TIntegerField;
    cdsListContactTypeCost: TIntegerField;
    xFoCal: TxFoCal;
    cdsListContactpricefield: TStringField;
    lblDateDocument: TLabel;
    cdsListContactcontacttype: TIntegerField;
    cdsGoodPosQuantity21: TIBBCDField;
    cdsGoodPosQuantity22: TIBBCDField;
    cdsGoodPosQuantity23: TIBBCDField;
    cdsGoodPosQuantity24: TIBBCDField;
    cdsGoodPosQuantity25: TIBBCDField;
    cdsGoodPosQuantity26: TIBBCDField;
    cdsGoodPosQuantity27: TIBBCDField;
    cdsGoodPosQuantity28: TIBBCDField;
    cdsGoodPosQuantity29: TIBBCDField;
    cdsGoodPosQuantity30: TIBBCDField;
    cdsGoodPosQuantity31: TIBBCDField;
    cdsGoodPosQuantity32: TIBBCDField;
    cdsGoodPosQuantity33: TIBBCDField;
    cdsGoodPosQuantity34: TIBBCDField;
    cdsGoodPosQuantity35: TIBBCDField;
    cdsGoodPosCostNCU21: TIBBCDField;
    cdsGoodPosCostNCU22: TIBBCDField;
    cdsGoodPosCostNCU23: TIBBCDField;
    cdsGoodPosCostNCU24: TIBBCDField;
    cdsGoodPosCostNCU25: TIBBCDField;
    cdsGoodPosCostNCU26: TIBBCDField;
    cdsGoodPosCostNCU27: TIBBCDField;
    cdsGoodPosCostNCU28: TIBBCDField;
    cdsGoodPosCostNCU29: TIBBCDField;
    cdsGoodPosCostNCU30: TIBBCDField;
    cdsGoodPosCostNCU31: TIBBCDField;
    cdsGoodPosCostNCU32: TIBBCDField;
    cdsGoodPosCostNCU33: TIBBCDField;
    cdsGoodPosCostNCU34: TIBBCDField;
    cdsGoodPosCostNCU35: TIBBCDField;
    cdsAmountQuantity21: TIBBCDField;
    cdsAmountQuantity22: TIBBCDField;
    cdsAmountQuantity23: TIBBCDField;
    cdsAmountQuantity24: TIBBCDField;
    cdsAmountQuantity25: TIBBCDField;
    cdsAmountQuantity26: TIBBCDField;
    cdsAmountQuantity27: TIBBCDField;
    cdsAmountQuantity28: TIBBCDField;
    cdsAmountQuantity29: TIBBCDField;
    cdsAmountQuantity30: TIBBCDField;
    cdsAmountQuantity31: TIBBCDField;
    cdsAmountQuantity32: TIBBCDField;
    cdsAmountQuantity33: TIBBCDField;
    cdsAmountQuantity34: TIBBCDField;
    cdsAmountQuantity35: TIBBCDField;
    cdsGoodPosNaturalLoss: TIBBCDField;
    ibsqlGroupInfo: TIBSQL;
    N2: TMenuItem;
    cdsListContactAmountBill: TIBBCDField;
    cdsGoodPosGroupKey: TIntegerField;
    dsDocReal: TDataSource;
    ibdsDocReal: TIBDataSet;
    ibdsRealPos: TIBDataSet;
    dsRealPos: TDataSource;
    procedure actMakeExecute(Sender: TObject);
    procedure actMakeUpdate(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actReplaceUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cdsGoodPosBeforePost(DataSet: TDataSet);
    procedure cdsGoodPosBeforeInsert(DataSet: TDataSet);
    procedure cdsGoodPosQuantity1Validate(Sender: TField);
    procedure cdsListContactAfterScroll(DataSet: TDataSet);
    procedure actCalcAmountExecute(Sender: TObject);
    procedure gsdbgrGoodPosColEnter(Sender: TObject);
    procedure gsdbgrGoodPosCellClick(Column: TColumn);
    procedure actNaturalLossExecute(Sender: TObject);
    procedure gsiblcBaseDocumentExit(Sender: TObject);
  private
    FDate: TDateTime;
    FFromContactKey, FToContactKey, FForwarderKey: Integer;
    FPriceKey: Integer;
    FFieldName: String;
    FTaxList: TObjectList;
    FDistance: Integer;

    FOk: Boolean;

    FIsLocal: Boolean;
    FNaturalLossList: TObjectList;
    FTaraGroup: TStringList;        // Список кодов с группами тары

    procedure MakeBill;
    function GetFieldName(const NameCustomer: String): String;
    function AddContact(const aContactKey, aDocumentKey, aPriceKey: Integer;
      const aContactName, aDocumentNumber, aPriceField: String): String;
    function GetCostField(const NameQuantityField: String): String;
    procedure MakeNew;
    function SaveData: Boolean;
    procedure AddUserField;
    function CalcRest(const ExcludeField: String): Currency;
    procedure CalcAmount(const FieldName: String);
    procedure SetAmountNCU(const FieldName: String; const AmountNCU: Currency);
    procedure SetPriceField;
    procedure SetCostGood(const NameField, NamePriceField: String;
      const TypeCost, PriceKey: Integer);
    function CalcTax(const GoodKey, CurrentTax: Integer; const Quantity,
      Cost: Currency): Currency;
    procedure SetCurPriceField(const aFieldName: String);
    procedure ReadNaturalLossInfo;
    function GetNaturalLoss(const GoodKey: Integer; Weight: Currency): Currency;
    procedure SetNaturalLoss;
    function GetDistance: Integer;
    procedure SetGroupTara;
  public
    { Public declarations }
    property Ok: Boolean read FOk write FOk;
  end;

var
  dlgDetailBill: TdlgDetailBill;

implementation

{$R *.DFM}

uses
  gp_common_real_unit, gsStorage, gp_dlgEnterDistance_unit,
  Storages;

type
  TDetailTaxField = class
    TaxField: String;
    Amount: Double;
    constructor Create(const aTaxField: String; aAmount: Double);
  end;

  TNaturalLossInfo = class
    GroupKey: Integer;
    LB: Integer;
    RB: Integer;
    Distance: Integer;
    IsIncMode: Boolean;
    Koef: Currency;
    constructor Create(const aGroupKey, aLB, aRB, aDistance: Integer; S: String);
  end;

constructor TDetailTaxField.Create(const aTaxField: String; aAmount: Double);
begin
  TaxField := aTaxField;
  Amount := aAmount;
end;

{ TNaturalLossInfo }

constructor TNaturalLossInfo.Create(const aGroupKey, aLB, aRB,
  aDistance: Integer; S: String);
begin
  GroupKey := aGroupKey;
  LB := aLB;
  RB := aRB;
  Distance := aDistance;
  if Pos('+', S) > 0 then
  begin
    isIncMode := True;
    S := copy(S, Pos('+', S) + 1, Length(S));
  end
  else
    isIncMode := False;
  try    
    Koef := StrToFloat(S);
  except
    Koef := 0;
  end;
end;

procedure TdlgDetailBill.AddUserField;
var
  i: Integer;
  F: TField;
  S: String;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption ';
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      FTaxList.Add(TTaxField.Create(
         UpperCase(Trim(ibsql.FieldByName('relationname').AsString)),
        ibsql.FieldByName('fieldname').AsString,
        ibsql.FieldByName('expression').AsString,
        ibsql.FieldByName('taxkey').AsInteger,
        ibsql.FieldByName('includetax').AsInteger = 1,
        ibsql.FieldByName('iscurrency').AsInteger = 1,
        ibsql.FieldByName('rounding').AsCurrency,
        ibsql.FieldByName('rate').AsCurrency));

      F := TIBBCDField.Create(Self);
      F.FieldName := ibsql.FieldByName('fieldname').AsString;
      F.Visible := False;
      F.DataSet := cdsGoodPos;

      ibsql.Next;
      
    end;
  finally
    ibsql.Free;
  end;

  S := 'INSERT INTO gd_docrealpos (documentkey, goodkey, trtypekey,' +
       '  quantity, mainquantity, amountncu, valuekey, weightkey, weight ';
  for i:= 0 to FTaxList.Count - 1 do
    if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
      S := S + ', ' + TTaxField(FTaxList[i]).FieldName;

  S := S + ') VALUES (:documentkey, :goodkey, :trtypekey, :quantity, :mainquantity,' +
           ' :amountncu, :valuekey, :weightkey, :weight ';

  for i:= 0 to FTaxList.Count - 1 do
    if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
      S := S + ', :' + TTaxField(FTaxList[i]).FieldName;

  ibsqlDocRealPos.SQL.Text := S + ')';


end;

function TdlgDetailBill.GetFieldName(const NameCustomer: String): String;
var
  i: Integer;
begin
  Result := '';
  for i:= cdsGoodPos.FieldCount - 1 downto 3 do
  begin
    if not cdsGoodPos.Fields[i].Visible and (Pos('Quantity', cdsGoodPos.Fields[i].FieldName) > 0)
    then
    begin
      cdsGoodPos.Fields[i].DisplayLabel := NameCustomer;
      cdsGoodPos.Fields[i].Visible := True;
      Result := cdsGoodPos.Fields[i].FieldName;
      Break;
    end;
  end;
  if Result > '' then
  begin
    cdsAmount.FieldByName(Result).DisplayLabel := NameCustomer;
    cdsAmount.FieldByName(Result).Visible := True;
    gsdbgrGoodPos.ColumnByField(cdsGoodPos.FieldByName(Result)).Visible := True;
    gsdbgrAmount.ColumnByField(cdsAmount.FieldByName(Result)).Visible := True;
  end;  
end;

function TdlgDetailBill.AddContact(const aContactKey, aDocumentKey, aPriceKey: Integer;
  const aContactName, aDocumentNumber, aPriceField: String): String;
var
  ibsql: TIBSQL;
  S: String;
  ContractKey, ContactType: Integer;
begin
  Result := GetFieldName(aContactName);
  if Result > '' then
  begin
    S := '';
    ContractKey := -1;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := 'SELECT doc.id, doc.number, doc.documentdate FROM gd_contract c ' +
        ' JOIN gd_document doc ON c.documentkey = doc.id and c.contactkey = :ck ' +
        ' ORDER BY doc.documentdate ';
      ibsql.ParamByName('ck').AsInteger := aContactKey;
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        if ibsql.FieldByName('documentdate').AsDateTime > FDate
        then
          Break;
        S := '№ ' + ibsql.FieldByName('number').AsString + ' от ' +
          ibsql.FieldByName('documentdate').AsString;
        ContractKey := ibsql.FieldByName('id').AsInteger;
        ibsql.Next;
      end;
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT contacttype FROM gd_contact WHERE ID = :ck';
      ibsql.ParamByName('ck').AsInteger := aContactKey;
      ibsql.ExecQuery;
      ContactType := ibsql.FieldByName('contacttype').AsInteger;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
    cdsListContact.Insert;
    cdsListContact.FieldByName('contactkey').AsInteger :=
      aContactKey;
    cdsListContact.FieldByName('contacttype').AsInteger :=
      ContactType;
    cdsListContact.FieldByName('documentkey').AsInteger :=
      aDocumentKey;
    cdsListContact.FieldByName('contactname').AsString :=
      aContactName;
    cdsListContact.FieldByName('documentnumber').AsString :=
      aDocumentNumber;
    cdsListContact.FieldByName('fieldname').AsString :=
      Result;

    cdsListContact.FieldByName('typecost').AsInteger :=
      rgCostType.ItemIndex;

    cdsListContact.FieldByName('pricekey').AsInteger := aPriceKey;

    cdsListContact.FieldByName('pricefield').AsString := aPriceField;

    if S > '' then
    begin
      cdsListContact.FieldByName('contractkey').AsInteger := ContractKey;
      cdsListContact.FieldByName('contractname').AsString := S;
    end;
    cdsListContact.Post;
    gsiblcPrice.CurrentKey := IntToStr(aPriceKey);
  end;
end;

procedure TdlgDetailBill.MakeBill;
var
  ibsql: TIBSQL;
  DocumentKey: Integer;
  i: Integer;
  NameField, S, S1, S2: String;

function GotoGoodPos(const GoodKey: Integer; const Quantity: Currency): Boolean;
var
  Bookmark: TBookmark;
begin
  Result := False;
  Bookmark := cdsGoodPos.GetBookmark;
  cdsGoodPos.DisableControls;
  try
    cdsGoodPos.First;
    while not cdsGoodPos.EOF do
    begin
      if cdsGoodPos.FieldByName('GoodKey').AsInteger = GoodKey then
      begin
        Result := True;
        Break;
      end;
      cdsGoodPos.Next;
    end;
  finally
    if not Result then
      cdsGoodPos.GotoBookmark(Bookmark);
    cdsGoodPos.FreeBookmark(Bookmark);
    cdsGoodPos.EnableControls;
  end;
end;

begin
  ibsql := TIBSQL.Create(Self);
  ibsql.Transaction := IBTransaction;

  FisLocal := True;
  try

    ibsql.SQL.Text  := 'SELECT * FROM gd_documentlink l ' +
     ' JOIN gd_document doc ON l.sourcedockey = doc.id ' +
     ' WHERE l.destdockey = :destkey AND doc.documenttypekey = 802001 ';
    ibsql.ParamByName('destkey').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      MessageBox(HANDLE, 'Нельзя отчитывать дополнительную накладную.', 'Внимание',
        mb_OK or mb_IconInformation)
    else
    begin
{ Заполняем данные из базовой накладной (накладной выданной экспедитору) }
      ibsql.Close;
      cdsListContact.Close;
      cdsListContact.CreateDataSet;

      cdsGoodPos.Close;
      cdsGoodPos.CreateDataSet;

      for i:= 1 to 35 do
        gsdbgrGoodPos.ColumnByField(cdsGoodPos.FieldByName(Format('Quantity%d', [i]))).Visible := False;

      cdsGoodPos.FieldByName('GoodName').ReadOnly := False;
      cdsGoodPos.FieldByName('QuantityBase').ReadOnly := False;
      cdsGoodPos.FieldByName('QuantityRest').ReadOnly := False;
      cdsGoodPos.FieldByName('CostNCU').ReadOnly := False;
      cdsGoodPos.FieldByName('AmountNCU').ReadOnly := False;

      cdsAmount.Close;
      cdsAmount.CreateDataSet;

      ibsql.SQL.Text := 'SELECT d.documentdate, dr.fromcontactkey, dr.pricekey, dr.pricefield ' +
       ' , dr.tocontactkey, di.forwarderkey ' +
       ' FROM gd_docrealization dr JOIN gd_docrealinfo di ON dr.documentkey = di.documentkey ' +
       ' JOIN gd_document d ON dr.documentkey = d.id ' +
       ' WHERE dr.documentkey = ' + gsiblcBaseDocument.CurrentKey;
      ibsql.ExecQuery;

      if ibsql.FieldByName('forwarderkey').IsNull then
        MessageBox(Handle, 'Не определен экспедитор. Будут созданы не все накладные!',
          'Внимание!', MB_OK or MB_ICONEXCLAMATION);

      FDate := ibsql.FieldByName('documentdate').AsDateTime;
      lblDateDocument.Caption := DateToStr(FDate);
      FFromContactKey := ibsql.FieldByName('fromcontactkey').AsInteger;
      FToContactKey := ibsql.FieldByName('tocontactkey').AsInteger;
      FPriceKey := ibsql.FieldByName('pricekey').AsInteger;
      FFieldName := ibsql.FieldByName('pricefield').AsString;
      FForwarderKey := ibsql.FieldByName('forwarderkey').AsInteger;
      ibsql.Close;

      S :=
        ' SELECT dp.goodkey, dp.trtypekey, dp.valuekey, ' +
        '  dp.weightkey, g.name, g.groupkey, ' +
        '  SUM(dp.quantity) as Quantity, SUM(dp.mainquantity) as MainQuantity, ' +
        '  SUM(dp.amountncu) as AmountNCU, SUM(dp.amountcurr) as AmountCurr, ' +
        '  SUM(dp.weight) as Weight ';

      for i:= 0 to FTaxList.Count - 1 do
        if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
          S := S + ', SUM(dp. ' + TTaxField(FTaxList[i]).FieldName + ') as ' +
            TTaxField(FTaxList[i]).FieldName;

      S := S + ' FROM gd_docrealpos dp JOIN gd_good g ON dp.goodkey = g.id ' +
        ' JOIN gd_document d ON dp.documentkey = d.id ' +
        ' JOIN gd_docrealization dr ON dp.documentkey = dr.documentkey ' +
        ' WHERE ' +
        ' d.number IN ( ''' +  gsiblcBaseDocument.Text + '''';

      if edOtherBill.Text > '' then
      begin
        S2 := edOtherBill.Text;
        while Pos(',', S2) > 0 do
        begin
          S1 := copy(S2, 1, Pos(',', S2) - 1);
          S := S + ', ''' + S1 + '''';
          S2 := copy(S2, Pos(',', S2) + 1, Length(S2));
        end;
        S := S + ', ''' + S2 + '''';
      end;

      S := S + ') AND dr.fromdocumentkey IS NULL ' +
               '  GROUP BY dp.goodkey, dp.trtypekey, dp.valuekey, ' +
               '  dp.weightkey, g.name, g.groupkey ';

      ibsql.SQL.Text := S;
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        cdsGoodPos.Insert;
        cdsGoodPos.FieldByName('goodkey').AsInteger := ibsql.FieldByName('goodkey').AsInteger;
        cdsGoodPos.FieldByName('groupkey').AsInteger := ibsql.FieldByName('groupkey').AsInteger;
        cdsGoodPos.FieldByName('goodname').AsString := ibsql.FieldByName('name').AsString;
        cdsGoodPos.FieldByName('quantitybase').AsCurrency := ibsql.FieldByName('quantity').AsCurrency;
        cdsGoodPos.FieldByName('quantityrest').AsCurrency := ibsql.FieldByName('quantity').AsCurrency;
        cdsGoodPos.FieldByName('amountncu').AsCurrency := ibsql.FieldByName('amountncu').AsCurrency;
        cdsGoodPos.FieldByName('costncu').AsCurrency :=
          ibsql.FieldByName('amountncu').AsCurrency / ibsql.FieldByName('quantity').AsCurrency;
        cdsGoodPos.FieldByName('mainquantity').AsCurrency :=
          ibsql.FieldByName('mainquantity').AsCurrency;
        cdsGoodPos.FieldByName('valuekey').AsInteger :=
          ibsql.FieldByName('valuekey').AsInteger;
        cdsGoodPos.FieldByName('trtypekey').AsInteger :=
          ibsql.FieldByName('trtypekey').AsInteger;
        cdsGoodPos.FieldByName('weight').AsCurrency :=
          ibsql.FieldByName('weight').AsCurrency;
        cdsGoodPos.FieldByName('weightkey').AsInteger :=
          ibsql.FieldByName('weightkey').AsInteger;

        for i:= 0 to FTaxList.Count - 1 do
          if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
            cdsGoodPos.FieldByName(TTaxField(FTaxList[i]).FieldName).Value := ibsql.FieldByName(
              TTaxField(FTaxList[i]).FieldName).Value;

        cdsGoodPos.Post;
        ibsql.Next;
      end;
      ibsql.Close;

      MessageBox(Handle, 'Сформировали позиции', '1', mb_OK);

  { Проверяем наличие уже сформированных накладных на основании отчета }

      ibsql.SQL.Text :=
        'SELECT dd.number, dd.id, d.tocontactkey, c.Name, dp.*, d.pricekey, d.pricefield ' +
        '  FROM gd_docrealization d ' +
        '  JOIN gd_docrealpos dp ON d.documentkey = dp.documentkey and d.fromdocumentkey = :id ' +
        '  JOIN gd_contact c ON  d.tocontactkey = c.id ' +
        '  JOIN gd_document dd ON d.documentkey = dd.id';
      ibsql.Prepare;
      ibsql.ParamByName('id').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
      ibsql.ExecQuery;

      MessageBox(Handle, 'Проверили старые', '1', mb_OK);
      DocumentKey := -1;
      while not ibsql.EOF do
      begin
        if DocumentKey <> ibsql.FieldByName('documentkey').AsInteger then
        begin
          DocumentKey := ibsql.FieldByName('documentkey').AsInteger;
          NameField := AddContact(ibsql.FieldByName('tocontactkey').AsInteger,
            DocumentKey, ibsql.FieldByName('pricekey').AsInteger,
            ibsql.FieldByName('name').AsString,
            ibsql.FieldByName('number').AsString,
            ibsql.FieldByName('pricefield').AsString);
        end;
        if (NameField > '') and
           GotoGoodPos(ibsql.FieldByName('goodkey').AsInteger,
                       ibsql.FieldByName('quantity').AsCurrency)
        then
        begin
          cdsGoodPos.Edit;
          cdsGoodPos.FieldByName(NameField).AsCurrency :=
            cdsGoodPos.FieldByName(NameField).AsCurrency + ibsql.FieldByName('quantity').AsCurrency;
          cdsGoodPos.FieldByName('quantityrest').AsCurrency :=
            cdsGoodPos.FieldByName('quantityrest').AsCurrency -
            ibsql.FieldByName('quantity').AsCurrency;
          cdsGoodPos.FieldByName(GetCostField(NameField)).AsCurrency :=
            ibsql.FieldByName('amountncu').AsCurrency /
            ibsql.FieldByName('quantity').AsCurrency;
          cdsGoodPos.Post;
        end;
        ibsql.Next;
      end;
      ibsql.Close;

      if DocumentKey = -1 then
      begin
        gsiblcPrice.CurrentKey := IntToStr(FPriceKey);
        SetCurPriceField(FFieldName);
      end;

      MessageBox(Handle, 'Дошли до итого', '1', mb_OK);

      cdsAmount.Insert;
      cdsAmount.FieldByName('goodname').AsString := 'Итого (для расчета нажмите клавиши Alt+С)';
      cdsAmount.Post;

      cdsGoodPos.FieldByName('GoodName').ReadOnly := True;
      cdsGoodPos.FieldByName('QuantityBase').ReadOnly := True;
      cdsGoodPos.FieldByName('QuantityRest').ReadOnly := True;
      cdsGoodPos.FieldByName('CostNCU').ReadOnly := True;
      cdsGoodPos.FieldByName('AmountNCU').ReadOnly := True;
      MessageBox(Handle, 'Посчитали итого', '1', mb_OK);
    end;
  finally
    ibsql.Free;
    FisLocal := False;
  end;
end;

procedure TdlgDetailBill.SetPriceField;
var
  R: TatRelation;
  i: Integer;
  ibsql: TIBSQL;
begin
  R := atDatabase.Relations.ByRelationName('GD_PRICEPOS');
  if Assigned(R) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.SQL.Text := 'SELECT currkey FROM gd_priceposoption WHERE fieldname = :fn';
      ibsql.Transaction := IBTransaction;
      ibsql.Prepare;
      for i:= 0 to R.RelationFields.Count - 1 do
        if R.RelationFields[i].IsUserDefined then
        begin
          ibsql.ParamByName('fn').AsString := R.RelationFields[i].FieldName;
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            cbPriceField.Items.AddObject(R.RelationFields[i].LName,
              TPriceField.Create(R.RelationFields[i].FieldName,
                R.RelationFields[i].LShortName, ibsql.FieldByName('currkey').AsInteger))
          else
            cbPriceField.Items.AddObject(R.RelationFields[i].LName,
              TPriceField.Create(R.RelationFields[i].FieldName,
                R.RelationFields[i].LShortName, 0));
          ibsql.Close;
        end;
    finally
      ibsql.Free;
    end;
  end;
end;

function TdlgDetailBill.CalcTax(const GoodKey, CurrentTax: Integer;
  const Quantity, Cost: Currency): Currency;
var
  ibsql: TIBSQL;
  i: Integer;
  Rate, Value: Currency;
  RF: TatRelationField;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT gt.*, t.shot FROM gd_goodtax gt JOIN gd_tax t ON gt.taxkey = t.id ' +
                      'WHERE goodkey = :gk and taxkey = :tk and ' +
                      'datetax = (SELECT MAX(gt1.datetax) FROM gd_goodtax gt1 WHERE gt1.datetax <= :d and ' +
                      'gt1.goodkey = :gk and gt1.taxkey = :tk)';
    ibsql.Prepare;
    ibsql.ParamByName('gk').AsInteger := GoodKey;
    ibsql.ParamByName('d').AsDateTime := FDate;

    Result := 0;
    
    if TTaxField(FTaxList[CurrentTax]).expression > '' then
    begin
      xFocal.ClearVariablesList;    
      RF := atDatabase.FindRelationField('GD_DOCREALPOS', 'AmountNCU');
      if Assigned(RF) and Assigned(RF.Relation) then
        xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
          Cost * Quantity);

      RF := atDatabase.FindRelationField('GD_DOCREALPOS', 'Quantity');
      if Assigned(RF) and Assigned(RF.Relation) then
        xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
          Quantity);
          
      for i:= 0 to CurrentTax do
        if Trim(TTaxField(FTaxList[i]).RelationName) = 'GD_DOCREALPOS' then
        begin
          ibsql.ParamByName('tk').AsInteger := TTaxField(FTaxList[i]).TaxKey;
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            Rate := ibsql.FieldByName('rate').AsCurrency
          else
            Rate := 0;
          ibsql.Close;
          xFocal.AssignVariable(ibsql.FieldByName('shot').AsString, Rate);
          xFocal.Expression := TTaxField(FTaxList[i]).expression;
          Result :=
            RoundCurrency(xFocal.Value, TTaxField(FTaxList[i]).Rounding);
          if i < CurrentTax then
          begin
            RF := atDatabase.FindRelationField('GD_DOCREALPOS', TTaxField(FTaxList[i]).FieldName);
            if Assigned(RF) and Assigned(RF.Relation) then
              xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
                Result);
          end;
        end;
      end
      else
      begin

        ibsql.ParamByName('tk').AsInteger := TTaxField(FTaxList[CurrentTax]).TaxKey;
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
          Rate := ibsql.FieldByName('rate').AsCurrency
        else
          Rate := 0;
        ibsql.Close;

        Value := Cost * Quantity;
        if TTaxField(FTaxList[CurrentTax]).IsInclude then
          Rate := Rate / (100 + Rate)
        else
          Rate := Rate / 100;
        Result :=
          RoundCurrency(Value * Rate, TTaxField(FTaxList[CurrentTax]).Rounding);
          
      end;

  finally
    ibsql.Free;
  end;
end;

function TdlgDetailBill.SaveData: Boolean;
var
  i: Integer;
  DocumentKey: Integer;
  ibsql: TIBSQL;
  S, S1, S2: String;
  IdDocReal: String;
begin
  FisLocal := True;

  ibdsRealPos.SelectSQL.Text := 'SELECT * FROM GD_DOCREALPOS WHERE documentkey = :ID';
  ibdsDocReal.SelectSQL.Text := 'SELECT * FROM GD_DOCREALIZATION docr ' +
		' JOIN  GD_DOCUMENT doc ON docr.documentkey = doc.id ' +
		' WHERE doc.documenttypekey = 802001 and doc.id in (';

  IdDocReal := '';

  cdsListContact.DisableControls;
  cdsGoodPos.DisableControls;
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;

    if edOtherBill.Text > '' then
    begin
      ibsql.SQL.Text := 'DELETE FROM gd_documentlink WHERE sourcedockey = :id';
      ibsql.ParamByName('id').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
      ibsql.ExecQuery;
      ibsql.Close;
      ibsql.SQL.Text := Format('INSERT INTO gd_documentlink (sourcedockey, destdockey) ' +
        ' SELECT %d, id FROM gd_document WHERE number IN (',
        [gsiblcBaseDocument.CurrentKeyInt]);
      S := '';
      if edOtherBill.Text > '' then
      begin
        S2 := edOtherBill.Text;
        while Pos(',', S2) > 0 do
        begin
          S1 := copy(S2, 1, Pos(',', S2) - 1);
          if S > '' then
            S := S + ', ';
          S := S + '''' + S1 + '''';
          S2 := copy(S2, Pos(',', S2) + 1, Length(S2));
        end;
        if S > '' then
          S := S + ', ';
        S := S + '''' + S2 + ''')';
      end;
      ibsql.SQL.Text := ibsql.SQL.Text + S;
      ibsql.ExecQuery;
      ibsql.Close;
    end;

    ibsqlDocument.Prepare;
    ibsqlDocRealization.Prepare;
    ibsqlDocRealPos.Prepare;
    ibdsDocRealInfo.Open;

    cdsListContact.First;
    while not cdsListContact.EOF do
    begin
      if cdsListContact.FieldByName('documentkey').AsInteger > 0 then
      begin
        ibsql.SQL.Text := 'DELETE FROM gd_docrealpos WHERE documentkey = :id';
        ibsql.Prepare;
        DocumentKey := cdsListContact.FieldByName('documentkey').AsInteger;
        ibsql.ParamByName('id').AsInteger := DocumentKey;
        ibsql.ExecQuery;
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_docrealization SET tocontactkey = :ck WHERE documentkey = :id';
        ibsql.Prepare;
        ibsql.ParamByName('ck').AsInteger := cdsListContact.FieldByName('contactkey').AsInteger;
        ibsql.ParamByName('id').AsInteger := DocumentKey;
        ibsql.ExecQuery;
        ibsql.Close;
        IdDocReal := IdDocReal + IntToStr(DocumentKey) + ',';

      end
      else
      begin
        ibsql.SQL.Text := 'SELECT * FROM gd_docrealization WHERE documentkey = :dk';
        ibsql.Prepare;
        ibsql.ParamByName('dk').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
        ibsql.ExecQuery;

        DocumentKey := GenUniqueID;
        ibsqlDocument.Params.ByName('id').AsInteger := DocumentKey;
        if cdsListContact.FieldByName('contacttype').AsInteger <> 4 then
          ibsqlDocument.Params.ByName('documenttypekey').AsInteger := 802001
        else
          ibsqlDocument.Params.ByName('documenttypekey').AsInteger := 802003;
        ibsqlDocument.Params.ByName('trtypekey').Clear;
        ibsqlDocument.Params.ByName('number').AsString :=
          cdsListContact.FieldByName('documentnumber').AsString;
        ibsqlDocument.Params.ByName('documentdate').AsDateTime := FDate;
        ibsqlDocument.Params.ByName('afull').AsInteger := -1;
        ibsqlDocument.Params.ByName('achag').AsInteger := -1;
        ibsqlDocument.Params.ByName('aview').AsInteger := -1;
        ibsqlDocument.Params.ByName('companykey').AsInteger := IBLogin.CompanyKey;
        ibsqlDocument.Params.ByName('creatorkey').AsInteger := IBLogin.ContactKey;
        ibsqlDocument.Params.ByName('creationdate').AsDateTime := Now;
        ibsqlDocument.Params.ByName('editorkey').AsInteger := IBLogin.ContactKey;
        ibsqlDocument.Params.ByName('editiondate').AsDateTime := Now;
        ibsqlDocument.Params.ByName('disabled').AsInteger := 0;
        ibsqlDocument.Params.ByName('reserved').Clear;
        ibsqlDocument.ExecQuery;
        ibsqlDocument.Close;

        cdsListContact.Edit;
        cdsListContact.FieldByName('documentkey').AsInteger := DocumentKey;
        cdsListContact.Post;

        IdDocReal := IdDocReal + IntToStr(DocumentKey) + ',';
        ibsqlDocRealization.ParamByName('documentkey').AsInteger := DocumentKey;
        if cdsListContact.FieldByName('contacttype').AsInteger <> 4 then
          ibsqlDocRealization.ParamByName('fromcontactkey').AsInteger := FFromContactKey
        else
          ibsqlDocRealization.ParamByName('fromcontactkey').AsInteger := FForwarderKey;
        ibsqlDocRealization.ParamByName('tocontactkey').AsInteger :=
          cdsListContact.FieldByName('contactkey').AsInteger;
        ibsqlDocRealization.ParamByName('fromdocumentkey').AsInteger :=
          gsiblcBaseDocument.CurrentKeyInt;
        ibsqlDocRealization.ParamByName('pricekey').AsInteger :=
          cdsListContact.FieldByName('pricekey').AsInteger;
        if cdsListContact.FieldByName('pricefield').AsString > '' then
          ibsqlDocRealization.ParamByName('pricefield').AsString :=
            cdsListContact.FieldByName('pricefield').AsString
        else
          ibsqlDocRealization.ParamByName('pricefield').AsString :=
            FFieldName;
        ibsqlDocRealization.ParamByName('transsumncu').AsCurrency :=
          ibsql.FieldByName('transsumncu').AsCurrency;
        ibsqlDocRealization.ParamByName('transsumcurr').AsCurrency :=
          ibsql.FieldByName('transsumcurr').AsCurrency;

        ibsqlDocRealization.ExecQuery;
        ibsqlDocRealization.Close;
        ibsql.Close;

        ibsql.SQL.Text := 'SELECT * FROM gd_docrealinfo WHERE documentkey = :dk';
        ibsql.Prepare;
        ibsql.ParamByName('dk').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
        begin
          ibdsDocRealInfo.Insert;
          ibdsDocRealInfo.FieldByName('documentkey').AsInteger := DocumentKey;
          for i:= 1 to ibsql.Current.Count - 1 do
            if not ibsql.Fields[i].IsNull then
              ibdsDocRealInfo.Fields[i].AsString := ibsql.Fields[i].AsString;

          if not cdsListContact.FieldByName('contractkey').IsNull then
          begin
            ibdsDocRealInfo.FieldByName('contractkey').AsInteger :=
              cdsListContact.FieldByName('contractkey').AsInteger;
            ibdsDocRealInfo.FieldByName('contractnum').AsString :=
              cdsListContact.FieldByName('contractname').AsString;
          end;
          ibdsDocRealInfo.Post;
        end
        else
        begin
          if not cdsListContact.FieldByName('contractkey').IsNull then
          begin
            ibdsDocRealInfo.Insert;
            ibdsDocRealInfo.FieldByName('documentkey').AsInteger := DocumentKey;
              ibdsDocRealInfo.FieldByName('contractkey').AsInteger :=
              cdsListContact.FieldByName('contractkey').AsInteger;
            ibdsDocRealInfo.FieldByName('contractnum').AsString :=
              cdsListContact.FieldByName('contractname').AsString;
            ibdsDocRealInfo.Post;
          end;
        end;
        ibsql.Close;
      end;

      cdsGoodPos.First;
      while not cdsGoodPos.EOF do
      begin
        if cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency <> 0
        then
        begin
          ibsqlDocRealPos.ParamByName('documentkey').AsInteger := DocumentKey;
          ibsqlDocRealPos.ParamByName('goodkey').AsInteger :=
            cdsGoodPos.FieldByName('goodkey').AsInteger;
          if cdsGoodPos.FieldByName('trtypekey').AsInteger > 0 then
            ibsqlDocRealPos.ParamByName('trtypekey').AsInteger :=
              cdsGoodPos.FieldByName('trtypekey').AsInteger
          else
            ibsqlDocRealPos.ParamByName('trtypekey').Clear;
          if cdsGoodPos.FieldByName('valuekey').AsInteger > 0 then
            ibsqlDocRealPos.ParamByName('valuekey').AsInteger :=
              cdsGoodPos.FieldByName('valuekey').AsInteger
          else
            ibsqlDocRealPos.ParamByName('valuekey').Clear;
          ibsqlDocRealPos.ParamByName('quantity').AsCurrency :=
            cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency;

          ibsqlDocRealPos.ParamByName('mainquantity').AsCurrency :=
            cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency *
            cdsGoodPos.FieldByName('mainquantity').AsCurrency /
            cdsGoodPos.FieldByName('quantitybase').AsCurrency;

          ibsqlDocRealPos.ParamByName('amountncu').AsCurrency :=
            cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency *
            cdsGoodPos.FieldByName(
              GetCostField(cdsListContact.FieldByName('fieldname').AsString)).AsCurrency;

          if ibsqlDocRealPos.ParamByName('amountncu').AsCurrency = 0 then
            ibsqlDocRealPos.ParamByName('amountncu').AsCurrency :=
              cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency *
              cdsGoodPos.FieldByName('costncu').AsCurrency;


          if cdsGoodPos.FieldByName('weightkey').AsInteger > 0 then
            ibsqlDocRealPos.ParamByName('weightkey').AsInteger :=
               cdsGoodPos.FieldByName('weightkey').AsInteger
          else
            ibsqlDocRealPos.ParamByName('weightkey').Clear;

          if cdsGoodPos.FieldByName('weight').AsCurrency > 0 then
          begin
            ibsqlDocRealPos.ParamByName('weight').AsCurrency :=
              cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency *
              cdsGoodPos.FieldByName('weight').AsCurrency /
              cdsGoodPos.FieldByName('quantitybase').AsCurrency;
          end
          else
            ibsqlDocRealPos.ParamByName('weight').Clear;


          for i:= 0 to FTaxList.Count - 1 do
            if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
            begin
              if (cdsGoodPos.FieldByName(
                 GetCostField(cdsListContact.FieldByName('fieldname').AsString)).AsCurrency =
                 cdsGoodPos.FieldByName('costncu').AsCurrency) or
                 (cdsGoodPos.FieldByName(
                    GetCostField(cdsListContact.FieldByName('fieldname').AsString)).AsCurrency = 0)
              then
                ibsqlDocRealPos.ParamByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
                  cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency *
                  cdsGoodPos.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency /
                  cdsGoodPos.FieldByName('quantitybase').AsCurrency
              else
                ibsqlDocRealPos.ParamByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
                CalcTax(cdsGoodPos.FieldByName('GoodKey').AsInteger, i,
                  cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).AsCurrency,
                  cdsGoodPos.FieldByName(
                    GetCostField(cdsListContact.FieldByName('fieldname').AsString)).AsCurrency);


            end;
          ibsqlDocRealPos.ExecQuery;
          ibsqlDocRealPos.Close;
        end;
        cdsGoodPos.Next;
      end;
      cdsListContact.Next;
    end;
    Ok := True;
    Result := True;

    IBTransaction.Commit;
  finally
    ibsql.Free;
    cdsListContact.EnableControls;
    cdsGoodPos.EnableControls;
    FisLocal := False;
  end;
end;

procedure TdlgDetailBill.MakeNew;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  cdsListContact.Close;
  cdsListContact.CreateDataSet;

  cdsGoodPos.Close;
  cdsGoodPos.CreateDataSet;

  cdsAmount.Close;
  cdsAmount.CreateDataSet;

  FDistance := 0;

end;

function TdlgDetailBill.CalcRest(const ExcludeField: String): Currency;
var
  i: Integer;
begin
  Result := cdsGoodPos.FieldByName('quantitybase').AsCurrency;
  for i:= 0 to cdsGoodPos.FieldCount - 1 do
  begin
    if (UPPERCASE(cdsGoodPos.Fields[i].FieldName) <> 'QUANTITYREST') AND
       (UPPERCASE(cdsGoodPos.Fields[i].FieldName) <> 'QUANTITYBASE') AND
       (UPPERCASE(cdsGoodPos.Fields[i].FieldName) <> UPPERCASE(ExcludeField)) AND
       (Pos('QUANTITY', UPPERCASE(cdsGoodPos.Fields[i].FieldName)) > 0) AND
       cdsGoodPos.Fields[i].Visible
    then
      Result := Result - cdsGoodPos.Fields[i].AsCurrency;
  end;
end;

procedure TdlgDetailBill.actMakeExecute(Sender: TObject);
begin
  MakeBill;
end;

procedure TdlgDetailBill.actMakeUpdate(Sender: TObject);
begin
  actMake.Enabled := gsiblcBaseDocument.CurrentKey > '';
  lblContact.Enabled := actMake.Enabled;
  lblNumberBill.Enabled := actMake.Enabled;
  gsiblcCompany.Enabled := actMake.Enabled;
  edNumBill.Enabled := actMake.Enabled;
  rgCostType.Enabled := actMake.Enabled;
  lPriceField.Enabled := actMake.Enabled;
  cbPriceField.Enabled := actMake.Enabled;
  gsiblcPrice.Enabled := actMake.Enabled;
  lPrice.Enabled := actMake.Enabled;
end;

procedure TdlgDetailBill.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled := (gsiblcBaseDocument.CurrentKey > '') and
    (gsiblcCompany.CurrentKey > '') and (edNumBill.Text > '');
end;

procedure TdlgDetailBill.actReplaceUpdate(Sender: TObject);
begin
  actReplace.Enabled := (gsiblcBaseDocument.CurrentKey > '') and
    (gsiblcCompany.CurrentKey > '') and (edNumBill.Text > '') and
    (cdsListContact.FieldByName('ContactKey').AsInteger > 0);
end;

procedure TdlgDetailBill.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := (gsiblcBaseDocument.CurrentKey > '') and
    (cdsListContact.FieldByName('ContactKey').AsInteger > 0);
end;

procedure TdlgDetailBill.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (gsiblcBaseDocument.CurrentKey > '') and
    (cdsListContact.RecordCount > 0);
end;

procedure TdlgDetailBill.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := (gsiblcBaseDocument.CurrentKey > '') and
    (cdsListContact.RecordCount > 0);
end;

procedure TdlgDetailBill.actNewExecute(Sender: TObject);
var
  NameField, PriceField: String;
  PriceKey, TypeCost: Integer;

function CheckNumberBill: Boolean;
begin
  Result := False;
  FIsLocal := True;
  cdsListContact.DisableControls;
  try
    cdsListContact.First;
    while not cdsListContact.EOF do
    begin
      if (cdsListContact.FieldByName('ContactKey').AsInteger =
         gsiblcCompany.CurrentKeyInt) and
         (cdsListContact.FieldByName('DocumentNumber').AsString =
         edNumBill.Text)
      then
      begin
        Result := True;
        Break;
      end;
      cdsListContact.Next;
    end;
  finally
    FIsLocal := False;
    if Result then
      cdsListContactAfterScroll(cdsListContact);
    cdsListContact.EnableControls;
  end;
end;

procedure SetQuantity;
var
  ibsql: TIBSQL;
  DocKey: Integer;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT id FROM gd_document WHERE number = :number and documenttypekey = 154368553 and parent is null';
    ibsql.ParamByName('number').AsString := cdsListContact.FieldByName('DocumentNumber').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      DocKey := ibsql.FieldByName('id').AsInteger;
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM USR$BER_ADDPRODUCTLINE WHERE masterkey = :dockey AND usr$goodkey = :goodkey';
      ibsql.ParamByName('dockey').AsInteger := DocKey;
      cdsGoodPos.First;
      while not cdsGoodPos.EOF do
      begin
        cdsGoodPos.Edit;
        ibsql.Close;
        ibsql.ParamByName('goodkey').AsInteger := cdsGoodPos.FieldByName('goodkey').AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          cdsGoodPos.FieldByName(NameField).AsCurrency := ibsql.FieldByName('USR$QUANTITY').AsCurrency;
        cdsGoodPos.Post;
        cdsGoodPos.Next;
      end;

    end;
  finally
    ibsql.Free;
  end;
end;

begin
  if gsiblcPrice.CurrentKey > '' then
    PriceKey := gsiblcPrice.CurrentKeyInt
  else
    PriceKey := -1;

  if cbPriceField.ItemIndex > 0 then
    PriceField := TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).FieldName
  else
    PriceField := '';

  TypeCost := rgCostType.ItemIndex;

  if not CheckNumberBill then
  begin
    NameField := AddContact(gsiblcCompany.CurrentKeyInt, -1, PriceKey, gsiblcCompany.Text,
      edNumBill.Text, PriceField);
    SetCostGood(NameField, PriceField, TypeCost, PriceKey);
    SetQuantity;

    gsdbgrGoodPos.SelectedField :=
      cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString);
    gsdbgrAmount.SelectedField :=
      cdsAmount.FieldByName(cdsListContact.FieldByName('fieldname').AsString);
    gsdbgrGoodPos.SetFocus;
  end
  else
    MessageBox(HANDLE, 'Даннный номер и организация уже есть в отчете', 'Внимание',
      mb_Ok or mb_IconInformation);

end;

procedure TdlgDetailBill.actReplaceExecute(Sender: TObject);
var
  OldTypeCost: Integer;
begin
  OldTypeCost := cdsListContact.FieldByName('typecost').AsInteger;
  cdsListContact.Edit;
  cdsListContact.FieldByName('contactkey').AsInteger :=
    gsiblcCompany.CurrentKeyInt;
  cdsListContact.FieldByName('contactname').AsString :=
    gsiblcCompany.Text;
  cdsListContact.FieldByName('documentnumber').AsString :=
    edNumBill.Text;
  cdsListContact.FieldByName('typecost').AsInteger :=
    rgCostType.ItemIndex;
  if gsiblcPrice.CurrentKey > '' then
    cdsListContact.FieldByName('pricekey').AsString := gsiblcPrice.CurrentKey;
  if cbPriceField.ItemIndex > 0 then
    cdsListContact.FieldByName('pricefield').AsString :=
    TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).FieldName;
  cdsListContact.Post;

  if OldTypeCost <> cdsListContact.FieldByName('typecost').AsInteger then
    SetCostGood(cdsListContact.FieldByName('FieldName').AsString,
      cdsListContact.FieldByName('pricefield').AsString,
      cdsListContact.FieldByName('typecost').AsInteger,
      cdsListContact.FieldByName('pricekey').AsInteger);

end;

procedure TdlgDetailBill.actDeleteExecute(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  if MessageBox(HANDLE, PChar(Format('Удалить организацию ''%s'' из отчета?',
     [gsdbgrContact.SelectedField.Text])),
    'Внимание',
    mb_YesNo or mb_IconQuestion) = idYes
  then
  begin
    if (cdsListContact.FieldByName('documentkey').AsInteger = -1) or
       (MessageBox(HANDLE, 'Удалить сформированную накладную по клиенту?', 'Внимание',
       mb_YesNo or mb_IconQuestion) = idYes)
    then
    begin
      if cdsListContact.FieldByName('documentkey').AsInteger > -1 then
      begin
        ibsql := TIBSQL.Create(Self);
        try
          ibsql.Transaction := IBTransaction;
          ibsql.SQL.Text := 'DELETE FROM gd_document WHERE id = :id';
          ibsql.Prepare;
          ibsql.ParamByName('id').AsInteger :=
            cdsListContact.FieldByName('documentkey').AsInteger;
          try
            ibsql.ExecQuery;
          except
            MessageBox(HANDLE, 'Невозможно удалить накладную.', 'Внимание',
              mb_Ok or mb_IconInformation);
            exit;
          end;
        finally
          ibsql.Free;
        end;
      end;
      gsdbgrGoodPos.ColumnByField(
        cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString)).Visible := False;
      gsdbgrAmount.ColumnByField(
        cdsAmount.FieldByName(cdsListContact.FieldByName('fieldname').AsString)).Visible := False;
      cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString).Visible := False;
      cdsAmount.FieldByName(cdsListContact.FieldByName('fieldname').AsString).Visible := False;
      cdsListContact.Delete;
    end;
  end;
end;

procedure TdlgDetailBill.actOkExecute(Sender: TObject);
begin
  if SaveData then
    ModalResult := mrOk;
end;

procedure TdlgDetailBill.actNextExecute(Sender: TObject);
begin
  if SaveData then
    MakeNew;
end;

procedure TdlgDetailBill.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgDetailBill.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if IBTransaction.InTransaction then
    IBTransaction.RollBack;

  UserStorage.WriteInteger('detailbox', 'checkquantity', Integer(cbCheckQuantity.Checked));
end;

procedure TdlgDetailBill.FormCreate(Sender: TObject);
begin
  FIsLocal := False;
  FOk := False;
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  FDistance := 0;
  FToContactKey := 0;
  FTaxList := TObjectList.Create;
  FNaturalLossList := TObjectList.Create;
  FTaraGroup := TStringList.Create;

  SetPriceField;

  cbCheckQuantity.Checked := UserStorage.ReadInteger('detailbox', 'checkquantity', 1) = 1;

  ReadNaturalLossInfo;

  AddUserField;

  MakeNew;
  SetGroupTara;

end;

procedure TdlgDetailBill.FormDestroy(Sender: TObject);
begin
  if Assigned(FTaxList) then
    FreeAndNil(FTaxList);

  if Assigned(FNaturalLossList) then
    FreeAndNil(FNaturalLossList);

  if Assigned(FTaraGroup) then
    FreeAndNil(FTaraGroup);    
end;

procedure TdlgDetailBill.SetGroupTara;
var
  CountGroup, i: Integer;
begin
  FTaraGroup.Clear;
  CountGroup := GlobalStorage.ReadInteger('realizationoption', 'countprintgroup', 0);
  for i:= 1 to CountGroup do
    FTaraGroup.Add(
    IntToStr(
    GlobalStorage.ReadInteger('realizationoption', Format('printgroupkey%d', [i]), 0)));
end;


procedure TdlgDetailBill.cdsGoodPosBeforePost(DataSet: TDataSet);
begin
  if FisLocal then exit;
  cdsGoodPos.FieldByName('quantityrest').ReadOnly := False;
  cdsGoodPos.FieldByName('quantityrest').AsCurrency := CalcRest('');
  cdsGoodPos.FieldByName('quantityrest').ReadOnly := True;
end;

procedure TdlgDetailBill.cdsGoodPosBeforeInsert(DataSet: TDataSet);
begin
  if not FisLocal then abort;
end;

procedure TdlgDetailBill.cdsGoodPosQuantity1Validate(Sender: TField);
begin
  if cbCheckQuantity.Checked and not FisLocal and (Sender.AsCurrency > CalcRest(Sender.FieldName))
  then
  begin
    MessageBox(HANDLE, 'Нельзя указывать количество больше чем было отпущено.',
     'Внимание', mb_Ok or mb_IconExclamation);
    abort;
  end;   
end;

procedure TdlgDetailBill.cdsListContactAfterScroll(DataSet: TDataSet);
begin
  if not FisLocal then
  begin
    gsiblcCompany.CurrentKey := cdsListContact.FieldByName('contactkey').AsString;
    edNumBill.Text := cdsListContact.FieldByName('documentnumber').AsString;
    gsiblcPrice.CurrentKey := cdsListContact.FieldByName('pricekey').AsString;
    SetCurPriceField(cdsListContact.FieldByName('pricefield').AsString);
    rgCostType.ItemIndex := cdsListContact.FieldByName('typecost').AsInteger;

    if cdsListContact.FieldByName('fieldname').AsString > '' then
    begin
      gsdbgrGoodPos.SelectedField :=
        cdsGoodPos.FieldByName(cdsListContact.FieldByName('fieldname').AsString);
      gsdbgrAmount.SelectedField :=
        cdsAmount.FieldByName(cdsListContact.FieldByName('fieldname').AsString);
    end;
  end;
end;

procedure TdlgDetailBill.CalcAmount(const FieldName: String);
var
  Amount: Currency;
  AmountNCU: Currency;
  Bookmark: TBookmark;
  i: Integer;
  S: String;
begin
  if (Pos('Quantity', FieldName) > 0) and (cdsAmount.FindField(FieldName) <> nil)
  then
  begin
    Bookmark := cdsGoodPos.GetBookmark;
    cdsGoodPos.DisableControls;
    try
      Amount := 0;
      AmountNCU := 0;
      cdsGoodPos.First;
      S := GetCostField(FieldName);
      while not cdsGoodPos.EOF do
      begin
        if FTaraGroup.IndexOf(cdsGoodPos.FieldByName('GroupKey').AsString) < 0 then
        begin

          Amount := Amount + cdsGoodPos.FieldByName(FieldName).AsCurrency;
          if Assigned(cdsGoodPos.FindField(S)) then
          begin
            AmountNCU := AmountNCU + cdsGoodPos.FieldByName(FieldName).AsCurrency *
             cdsGoodPos.FieldByName(S).AsCurrency;
            for i:= 0 to FTaxList.Count - 1 do
              if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
              begin
                if not TTaxField(FTaxList[i]).IsInclude and
                  (cdsGoodPos.FieldByName('QuantityBase').AsCurrency <> 0)
                then
                  AmountNCU := AmountNCU +
                    cdsGoodPos.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency /
                    cdsGoodPos.FieldByName('QuantityBase').AsCurrency *
                    cdsGoodPos.FieldByName(FieldName).AsCurrency;
              end;
          end;
        end;
        cdsGoodPos.Next;
      end;


      cdsAmount.Edit;
      cdsAmount.FieldByName(FieldName).AsCurrency := Amount;
      cdsAmount.Post;
      if Assigned(cdsGoodPos.FindField(S)) then
        SetAmountNCU(FieldName, AmountNCU);
    finally
      cdsGoodPos.GotoBookmark(Bookmark);
      cdsGoodPos.FreeBookmark(Bookmark);
      cdsGoodPos.EnableControls;
    end;
  end;
end;

procedure TdlgDetailBill.actCalcAmountExecute(Sender: TObject);
var
  i: Integer;
begin
  for i:= 0 to cdsAmount.FieldCount - 1 do
    if cdsAmount.Fields[i].Visible then
      CalcAmount(cdsAmount.Fields[i].FieldName);
end;

procedure TdlgDetailBill.gsdbgrGoodPosColEnter(Sender: TObject);
begin
  gsdbgrAmount.SelectedField :=
    cdsAmount.FieldByName(gsdbgrGoodPos.SelectedField.FieldName);
end;

procedure TdlgDetailBill.gsdbgrGoodPosCellClick(Column: TColumn);
begin
  gsdbgrAmount.SelectedField :=
    cdsAmount.FieldByName(gsdbgrGoodPos.SelectedField.FieldName);
end;

procedure TdlgDetailBill.actNaturalLossExecute(Sender: TObject);
begin
  SetNaturalLoss;
end;

procedure TdlgDetailBill.SetCostGood(const NameField, NamePriceField: String;
  const TypeCost, PriceKey: Integer);
var
  ibsql: TIBSQL;
  NameCostField: String;
  Bookmark: TBookmark;
begin
  NameCostField := GetCostField(NameField);
  Bookmark := cdsGoodPos.GetBookmark;
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    if NamePriceField > '' then
    begin
      ibsql.SQL.Text := Format(
        'SELECT %s FROM gd_pricepos WHERE goodkey = :gk and pricekey = %d',
        [NamePriceField, PriceKey]);
      ibsql.Prepare;
    end;
    if cdsGoodPos.State in [dsEdit, dsInsert] then
      cdsGoodPos.Post;

    cdsGoodPos.First;
    while not cdsGoodPos.EOF do
    begin
      cdsGoodPos.Edit;
      if (TypeCost = 0) or (NamePriceField > '') then
        cdsGoodPos.FieldByName(NameCostField).AsCurrency :=
         cdsGoodPos.FieldByName('CostNCU').AsCurrency
      else
      begin
        ibsql.ParamByName('gk').AsInteger := cdsGoodPos.FieldByName('goodkey').AsInteger;
        ibsql.ExecQuery;
        try
          if ibsql.RecordCount > 0 then
            cdsGoodPos.FieldByName(NameCostField).AsCurrency :=
              ibsql.Fields[0].AsCurrency;
        finally
          ibsql.Close;
        end;
      end;
      cdsGoodPos.Post;
      cdsGoodPos.Next;
    end;
  finally
    cdsGoodPos.GotoBookmark(Bookmark);
    cdsGoodPos.FreeBookmark(Bookmark);
    ibsql.Free;
  end;
end;

function TdlgDetailBill.GetCostField(
  const NameQuantityField: String): String;
begin
  Result := 'CostNCU' + copy(NameQuantityField, 9, Length(NameQuantityField));
end;

procedure TdlgDetailBill.SetCurPriceField(const aFieldName: String);
var
  i: Integer;
begin
  for i := 0 to cbPriceField.Items.Count - 1 do
    if UPPERCASE(Trim(TPriceField(cbPriceField.Items.Objects[i]).FieldName)) =
       UPPERCASE(Trim(aFieldName))
    then
    begin
      cbPriceField.ItemIndex := i;
      Break;
    end;
end;

procedure TdlgDetailBill.ReadNaturalLossInfo;
var
  i, j: Integer;
  CountDist, CountGroup: Integer;
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder('realzaitionoption');
  with F do
  try
    CountDist := ReadInteger('lossdistancecount', 3);
    CountGroup := ReadInteger('lossgroupcount', 0);
    for i:= 1 to CountDist do
      for j:= 1 to CountGroup do

        FNaturalLossList.Add(TNaturalLossInfo.Create(
          ReadInteger(Format('lossgroupkey%d', [j]), 0),
          ReadInteger(Format('losslb%d', [j]), 0),
          ReadInteger(Format('lossrb%d', [j]), 0),
          ReadInteger(Format('lostdestvalue%d', [i]), 0),
          ReadString(Format('lossvalue%d_%d', [i, j]), '')));
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure TdlgDetailBill.SetNaturalLoss;
begin
  cdsGoodPos.DisableControls;
  try
    if FDistance = 0 then
    begin
      FDistance := GetDistance;
      if FDistance = 0 then
      begin
        with Tgp_dlgEnterDistance.Create(Self) do
          try
            if ShowModal = mrOk then
            begin
              FDistance := Distance;
              GlobalStorage.WriteInteger('distance', Format('value_%d', [FToContactKey]), FDistance);
            end;  
          finally
            Free;
          end;
      end;
    end;
    cdsGoodPos.First;
    while not cdsGoodPos.EOF do
    begin
      cdsGoodPos.Edit;
      cdsGoodPos.FieldByName('NaturalLoss').AsCurrency :=
        GetNaturalLoss(cdsGoodPos.FieldByName('GoodKey').AsInteger,
        cdsGoodPos.FieldByName('QuantityBase').AsCurrency);
      cdsGoodPos.Post;
      cdsGoodPos.Next;
    end;
  finally
    cdsGoodPos.First;
    cdsGoodPos.EnableControls;
  end;
end;

function TdlgDetailBill.GetNaturalLoss(const GoodKey: Integer; Weight: Currency): Currency;
var
  i: Integer;
begin
  Result := 0;
  ibsqlGroupInfo.ParamByName('ID').AsInteger := GoodKey;
  ibsqlGroupInfo.ExecQuery;
  try
    if ibsqlGroupInfo.RecordCount > 0 then
    begin
      for i:= 0 to FNaturalLossList.Count - 1 do
        if (TNaturalLossInfo(FNaturalLossList[i]).RB >=
              ibsqlGroupInfo.FieldByName('RB').AsInteger) and
           (TNaturalLossInfo(FNaturalLossList[i]).LB <=
              ibsqlGroupInfo.FieldByName('LB').AsInteger) and
           (FDistance >= TNaturalLossInfo(FNaturalLossList[i]).Distance)
        then
        begin
          if not TNaturalLossInfo(FNaturalLossList[i]).IsIncMode then
            Result := Weight * TNaturalLossInfo(FNaturalLossList[i]).Koef / 100
          else
            Result := Result +
              Weight *
              ((FDistance - TNaturalLossInfo(FNaturalLossList[i]).Distance) div
              TNaturalLossInfo(FNaturalLossList[i]).Distance) *
              TNaturalLossInfo(FNaturalLossList[i]).Koef / 100;
        end;
    end;
  finally
    ibsqlGroupInfo.Close;
  end;
end;

function TdlgDetailBill.GetDistance: Integer;
begin
  Result := GlobalStorage.ReadInteger('distance', Format('value_%d', [FToContactKey]), 0);
end;

procedure TdlgDetailBill.SetAmountNCU(const FieldName: String;
  const AmountNCU: Currency);
begin
  if cdsListContact.FieldByName('FieldName').AsString <> FieldName then
  begin
    cdsListContact.DisableControls;
    FisLocal := True;
    try
      cdsListContact.First;
      while not cdsListContact.EOF do
      begin
        if cdsListContact.FieldByName('FieldName').AsString = FieldName then
          Break;
        cdsListContact.Next;
      end;
    finally
      cdsListContact.EnableControls;
      FisLocal := False;
    end;
  end;
  if cdsListContact.FieldByName('FieldName').AsString = FieldName then
  begin
    cdsListContact.Edit;
    cdsListContact.FieldByName('AmountBill').AsCurrency := AmountNCU;
    cdsListContact.Post;
  end;
end;

procedure TdlgDetailBill.gsiblcBaseDocumentExit(Sender: TObject);
var
  ibsql: TIBSQL;
  S: String;
begin
  ibsql := TIBSQL.Create(Self);
  ibsql.Transaction := IBTransaction;
  try
    ibsql.SQL.Text := 'SELECT * FROM gd_documentlink l ' +
      ' JOIN gd_document doc ON l.destdockey = doc.id ' +
      ' WHERE l.sourcedockey = :sourcekey AND doc.documenttypekey = 802001 ';
    ibsql.ParamByName('sourcekey').AsInteger := gsiblcBaseDocument.CurrentKeyInt;
    ibsql.ExecQuery;
    S := '';
    while not ibsql.EOF do
    begin
      if s <> '' then
        S := S + ',';
      S := S + ibsql.FieldByName('number').AsString;
      ibsql.Next;
    end;
    ibsql.Close;
    edOtherBill.Text := S;
  finally
    ibsql.Free;
  end;
end;

end.
