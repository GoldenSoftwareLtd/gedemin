// ShlTanya, 11.03.2019

unit gp_dlgRealizationBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gp_dlgBill_unit, FrmPlSvr, Menus,  boCurrency,
  gsTransaction, xCalc, at_sql_setup, IBSQL, ActnList, Db,
  IBDatabase, IBCustomDataSet, gsTransactionComboBox, ComCtrls, StdCtrls,
  ToolWin, Grids, DBGrids, gsDBGrid, gsIBGrid, gsIBCtrlGrid, at_Container,
  DBCtrls, gsIBLookupComboBox, Mask, xDateEdits, Buttons, ExtCtrls, contnrs,
  dmDatabase_unit;

type
  TdlgRealizationBill = class(Tgp_dlgBill)
    tsAddInfo: TTabSheet;
    Panel5: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label27: TLabel;
    Label30: TLabel;
    iblcCargoReceiver: TgsIBLookupComboBox;
    ibdblcCarOwner: TgsIBLookupComboBox;
    dbedDriver: TDBEdit;
    dbedLOADINGPOINT: TDBEdit;
    dbedUNLOADINGPOINT: TDBEdit;
    dbedHooked: TDBEdit;
    dbedROUTE: TDBEdit;
    dbedREADDRESSING: TDBEdit;
    dbedWAYSHEETNUMBER: TDBEdit;
    gsiblcSURRENDER: TgsIBLookupComboBox;
    dbedWarrantNumber: TDBEdit;
    ddbWarrantDate: TxDateDBEdit;
    dbedReception: TDBEdit;
    gsiblcForwarder: TgsIBLookupComboBox;
    dbcbCar: TDBComboBox;
    dbedGarage: TDBEdit;
    Label24: TLabel;
    dbgrTypeTransport: TDBRadioGroup;
    Label26: TLabel;
    dbedTransSumNCU: TDBEdit;
    dbcbIsRealization: TDBCheckBox;
    ToolButton3: TToolButton;
    actChooseBill: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actChooseBillExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBillPositionInfo: TObjectList;
    procedure AddFromBill(const BillKey: TID);
    { Private declarations }
  protected
    function BeforeSave: Boolean; override;
    function BeforeSetup: Boolean; override;
    function AfterSetup: Boolean; override;
    function AfterSave: Boolean; override;
    procedure MakeOnChangeField(Sender: TField); override;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  dlgRealizationBill: TdlgRealizationBill;

implementation

{$R *.DFM}

uses
  gd_security_OperationConst, gp_dlgChooseBill_unit, Storages;

type
  TBillPositionInfo = class
    SourcePositionKey: TID;
    SourceGoodKey: TID;
    DestPositionKey: TID;
    Quantity: Currency;
    FirstQuantity: Currency;
    constructor Create(const aSourcePositionKey, aDestPositionKey, aSourceGoodKey: TID;
      aQuantity: Currency);
  end;

{ TBillPositionInfo }

constructor TBillPositionInfo.Create(
  const aSourcePositionKey, aDestPositionKey, aSourceGoodKey: TID;
  aQuantity: Currency);
begin
  SourcePositionKey := aSourcePositionKey;
  SourceGoodKey := aSourceGoodKey;
  DestPositionKey := aDestPositionKey;
  Quantity := aQuantity;
  FirstQuantity := aQuantity;
end;

{ TdlgRealizationBill }

function TdlgRealizationBill.AfterSetup: Boolean;
begin
  Result := True;  
end;

function TdlgRealizationBill.BeforeSave: Boolean;
begin
  Result := True;
  if (ibdsDocRealInfo.FieldByName('Reception').AsString = '') and
     (GetTID(ibdsDocRealInfo.FieldByName('ForwarderKey')) > 0)
  then
  begin
    if not (ibdsDocRealInfo.State in [dsEdit, dsInsert]) then
      ibdsDocRealInfo.Edit;
    ibdsDocRealInfo.FieldByName('Reception').AsString :=
      gsiblcForwarder.Text;
  end;

end;

function TdlgRealizationBill.BeforeSetup: Boolean;
begin
  FBillPositionInfo.Clear;
  Result := True;
end;

procedure TdlgRealizationBill.FormCreate(Sender: TObject);
begin
  inherited;
  FBillPositionInfo := TObjectList.Create;
end;

procedure TdlgRealizationBill.AddFromBill(const BillKey: TID);
var
  ibsql: TIBSQL;
  i: Integer;

function SearchPosition(const GoodKey: TID; Cost: Currency): Boolean;
begin
  Result := False;
  ibdsDocRealPos.First;
  while not ibdsDocRealPos.EOF do
  begin
    if (GoodKey = GetTID(ibdsDocRealPos.FieldByName('GoodKey'))) and
       (Cost = ibdsDocRealPos.FieldByName('CostNCU').AsCurrency)
    then
    begin
      Result := True;
      Break;
    end;
    ibdsDocRealPos.Next;
  end;
end;

procedure SetSQL;
begin
  ibsql.SQL.Assign(ibdsDocRealPos.SelectSQL);
  SetTID(ibsql.ParamByName('dockey'), BillKey);
end;

begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealization docr LEFT JOIN gd_docrealinfo doci ' +
      ' ON docr.documentkey = doci.documentkey WHERE docr.documentkey = ' + TID2S(BillKey);
    ibsql.ExecQuery;

    if (GetTID(ibdsDocRealization.FieldByName('tocontactkey')) =
       GetTID(ibsql.FieldByName('tocontactkey'))) or
        ibdsDocRealization.FieldByName('tocontactkey').IsNull
    then
    begin
      if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
        ibdsDocRealization.Edit;
      SetTID(ibdsDocRealization.FieldByName('fromcontactkey'),
        ibsql.FieldByName('fromcontactkey'));
      SetTID(ibdsDocRealization.FieldByName('tocontactkey'),
        ibsql.FieldByName('tocontactkey'));
      if not ibsql.FieldByName('pricekey').IsNull then
        SetTID(ibdsDocRealization.FieldByName('pricekey'),
          ibsql.FieldByName('pricekey'));
      if not ibsql.FieldByName('pricefield').IsNull then
        ibdsDocRealization.FieldByName('pricefield').AsString :=
          ibsql.FieldByName('pricefield').AsString;
      if not (ibdsDocRealInfo.State in [dsEdit, dsInsert]) then
        ibdsDocRealInfo.Edit;
      if not ibsql.FieldByName('contractkey').IsNull then
        SetTID(ibdsDocRealInfo.FieldByName('contractkey'),
          ibsql.FieldByName('contractkey'));

      ibsql.Close;

      SetSQL;

      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        if SearchPosition(GetTID(ibsql.FieldByName('GoodKey')),
         ibsql.FieldByName('CostNCU').AsCurrency)
        then
        begin
          ibdsDocRealPos.Edit;
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
            ibdsDocRealPos.FieldByName('Quantity').AsCurrency +
            ibsql.FieldByName('Quantity').AsCurrency -
            ibsql.FieldByName('PerformQuantity').AsCurrency;
          LocalChange := False;

          ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency :=
            ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency +
            ibsql.FieldByName('AmountNCU').AsCurrency -
            ibsql.FieldByName('AmountNCU').AsCurrency /
            ibsql.FieldByName('Quantity').AsCurrency *
            ibsql.FieldByName('PerformQuantity').AsCurrency;
            
          LocalChange := True;
          ibdsDocRealPos.Post;
        end
        else
        begin
          ibdsDocRealPos.Insert;
          for i:= 0 to ibsql.Current.Count - 1 do
            if (UpperCase(Trim(ibsql.Fields[i].Name)) <> 'DOCUMENTKEY') AND
               (UpperCase(Trim(ibsql.Fields[i].Name)) <> 'ID') AND
               (UpperCase(Trim(ibsql.Fields[i].Name)) <> 'PERFORMQUANTITY')
            then
            begin
              SetVar2Field(ibdsDocRealPos.FieldByName(ibsql.Fields[i].Name),
                GetFieldAsVar(ibsql.Fields[i]));
            end;
          if ibsql.FieldByName('PerformQuantity').AsCurrency > 0 then
          begin
            LocalChange := False;
            ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
              ibdsDocRealPos.FieldByName('Quantity').AsCurrency -
              ibsql.FieldByName('PerformQuantity').AsCurrency;
            LocalChange := True;
          end;
          ibdsDocRealPos.Post;
        end;
        FBillPositionInfo.Add(TBillPositionInfo.Create(GetTID(ibsql.FieldByName('ID')),
          GetTID(ibdsDocRealPos.FieldByName('ID')),
          GetTID(ibsql.FieldByName('GoodKey')),
          ibsql.FieldByName('Quantity').AsCurrency -
          ibsql.FieldByName('PerformQuantity').AsCurrency));
        ibsql.Next;
      end;
    end;
  finally
    ibsql.Free;
  end;
end;

procedure TdlgRealizationBill.actChooseBillExecute(Sender: TObject);
var
  i: Integer;
begin
  { Формирование накладной по счет фактуре }
  
  with Tgp_dlgChooseBill.Create(Self) do
    try
      if ShowModal = mrOk then
      begin
        LocalChange := True;
        ibdsDocRealPos.DisableControls;
        try
          for i:= 0 to BillCount - 1 do
            if BillKey[i] <> -1 then
              AddFromBill(BillKey[i]);
        finally
          LocalChange := False;
          ibdsDocRealPos.EnableControls;
        end;
      end;
    finally
      Free;
    end;
end;

procedure TdlgRealizationBill.FormDestroy(Sender: TObject);
begin
  if Assigned(FBillPositionInfo) then
    FreeAndNil(FBillPositionInfo);
  inherited;
end;

function TdlgRealizationBill.AfterSave: Boolean;
var
  i: Integer;
  ibsql: TIBSQL;
begin
  Result := inherited AfterSave;
  if Result and (FBillPositionInfo.Count > 0) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := 'INSERT INTO gd_docrealposrel VALUES (:Source, :Dest, :Quantity) ';
      ibsql.Prepare;
      for i:= 0 to FBillPositionInfo.Count - 1 do
      begin
        SetTID(ibsql.ParamByName('Source'),
          TBillPositionInfo(FBillPositionInfo[i]).SourcePositionKey);
        SetTID(ibsql.ParamByName('Dest'),
          TBillPositionInfo(FBillPositionInfo[i]).DestPositionKey);
        ibsql.ParamByName('Quantity').AsCurrency :=
          TBillPositionInfo(FBillPositionInfo[i]).Quantity;
        try
          ibsql.ExecQuery;
        except
        end;  
        ibsql.Close;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure TdlgRealizationBill.MakeOnChangeField(Sender: TField);
var
  i: Integer;
  PerQuantity: Currency;
begin
  inherited;
  if FBillPositionInfo.Count > 0 then
  begin
    if UpperCase(Sender.FieldName) = 'QUANTITY' then
    begin
      PerQuantity := 0;
      for i:= 0 to FBillPositionInfo.Count - 1 do
        if (TBillPositionInfo(FBillPositionInfo[i]).DestPositionKey =
           GetTID(ibdsDocRealPos.FieldByName('id')))
        then
          PerQuantity := PerQuantity + TBillPositionInfo(FBillPositionInfo[i]).FirstQuantity;
      if PerQuantity > Sender.AsCurrency then
      begin
        PerQuantity := Sender.AsCurrency;
        for i:= 0 to FBillPositionInfo.Count - 1 do
          if (TBillPositionInfo(FBillPositionInfo[i]).DestPositionKey =
             GetTID(ibdsDocRealPos.FieldByName('id'))) and
             (TBillPositionInfo(FBillPositionInfo[i]).FirstQuantity > PerQuantity)
          then
          begin
            TBillPositionInfo(FBillPositionInfo[i]).Quantity := PerQuantity;
            PerQuantity := 0;
          end
          else
            if (TBillPositionInfo(FBillPositionInfo[i]).DestPositionKey =
               GetTID(ibdsDocRealPos.FieldByName('id'))) then
            begin
              PerQuantity := PerQuantity - TBillPositionInfo(FBillPositionInfo[i]).FirstQuantity;
              if PerQuantity < 0 then
                PerQuantity := 0;
            end;
      end;
    end
    else
      if UpperCase(Sender.FieldName) = 'GOODKEY' then
      begin
        i:= 0;
        while i <= FBillPositionInfo.Count - 1 do
          if (TBillPositionInfo(FBillPositionInfo[i]).DestPositionKey =
             GetTID(ibdsDocRealPos.FieldByName('id'))) and
             (TBillPositionInfo(FBillPositionInfo[i]).SourceGoodKey <> GetTID(Sender))
          then
            FBillPositionInfo.Delete(i);
      end;
  end;
end;

class function TdlgRealizationBill.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgRealizationBill) then
  begin
    dlgRealizationBill := TdlgRealizationBill.Create(AnOwner);
    dlgRealizationBill.DocumentType := 802001;
  end;  

  Result := dlgRealizationBill;

end;

end.
