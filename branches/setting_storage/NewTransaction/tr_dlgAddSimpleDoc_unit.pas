unit tr_dlgAddSimpleDoc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, xDateEdits, gsIBLookupComboBox, ActnList, Db,
  IBCustomDataSet, IBDatabase, dmDatabase_unit, gsTransaction, gd_security,
  contnrs, gsTransactionComboBox, gdcBase;

type
  TdlgAddSimpleDoc = class(TForm)
    Label1: TLabel;
    dbedDocumentNumber: TDBEdit;
    Label2: TLabel;
    xddbedDocumentDate: TxDateDBEdit;
    Label3: TLabel;
    dbedSumNDE: TDBEdit;
    Label5: TLabel;
    dbedDescription: TDBEdit;
    btnOk: TButton;
    btnNext: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    ibdsDocument: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsDocument: TDataSource;
    lAmountCurr: TLabel;
    dbedSumCurr: TDBEdit;
    lCurr: TLabel;
    gsiblcCurr: TgsIBLookupComboBox;
    gsTransaction: TgsTransaction;
    lRate: TLabel;
    edRate: TEdit;
    btnEntry: TButton;
    actEntry: TAction;
    Label4: TLabel;
    gstcbTransaction: TgsTransactionComboBox;
    actCurrnecyEnabled: TAction;
    sbAnalyze: TScrollBox;
    Label6: TLabel;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gsiblcCurrChange(Sender: TObject);
    procedure edRateExit(Sender: TObject);
    procedure dbedSumNDEExit(Sender: TObject);
    procedure dbedSumCurrExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actEntryExecute(Sender: TObject);
    procedure actEntryUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    FDocumentKey: Integer;
    FTransactionKey: Integer;
    FisAppendMode: Boolean;
    FDocumentNumber: String;
    FDocumentDate: TDateTime;

    procedure AppendDocument;
    procedure EditDocument;
    procedure CalcCurrency(const TypeCur: Integer);
    procedure SetAnalyzeList(aAnalyzeList: TObjectList);
    procedure TrTypeKeyChange(Sender: TField);
    procedure AnalyzeChange(Sender: TObject);
    procedure CurrChange(Sender: TField);
    procedure SetCurrencyEnabled(const aTransactionKey: Integer);
    function Save: Boolean;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure SetupDialog(const aDocumentKey, aTransactionKey: Integer);
    property DocumentKey: Integer read FDocumentKey;
  end;

var
  dlgAddSimpleDoc: TdlgAddSimpleDoc;

implementation

{$R *.DFM}

uses tr_type_unit;

procedure TdlgAddSimpleDoc.AppendDocument;
begin
  FDocumentKey := GenUniqueID;

  ibdsDocument.Insert;
  ibdsDocument.FieldByName('id').AsInteger := FDocumentKey;
  ibdsDocument.FieldByName('DocumentDate').AsDateTime := FDocumentDate;
  ibdsDocument.FieldByName('Number').AsString := FDocumentNumber;
  ibdsDocument.FieldByName('documenttypekey').AsInteger := gsTransaction.DocumentType;

  if FTransactionKey <> -1 then
    ibdsDocument.FieldByName('trtypekey').AsInteger := FTransactionKey;

  ibdsDocument.FieldByName('afull').AsInteger := -1;
  ibdsDocument.FieldByName('achag').AsInteger := -1;
  ibdsDocument.FieldByName('aview').AsInteger := -1;
  ibdsDocument.FieldByName('companykey').AsInteger := IBLogin.CompanyKey;
  ibdsDocument.FieldByName('creatorkey').AsInteger := IBLogin.ContactKey;
  ibdsDocument.FieldByName('creationdate').AsDateTime := Now;
  ibdsDocument.FieldByName('editorkey').AsInteger := IBLogin.ContactKey;
  ibdsDocument.FieldByName('editiondate').AsDateTime := Now;
  ibdsDocument.FieldByName('disabled').AsInteger := 0;

  if FTransactionKey <> -1 then
    gsTransaction.SetAnalyzeControl(FTransactionKey, sbAnalyze, AnalyzeChange, IBTransaction);

end;

procedure TdlgAddSimpleDoc.EditDocument;
begin

  gsTransaction.SetAnalyzeControl(FTransactionKey, sbAnalyze, AnalyzeChange, IBTransaction);

  ibdsDocument.Edit;

end;

function TdlgAddSimpleDoc.Save: Boolean;
var
  AnalyzeList: TObjectList;
begin
  Result := True;
  try
    if ibdsDocument.FieldByName('trtypekey').AsInteger = 0 then
    begin
      MessageBox(HANDLE, 'Необходимо указать операцию по данному документу.',
        'Внимание', mb_Ok or mb_IconInformation);
      gstcbTransaction.SetFocus;
      Result := False;
      exit;
    end;

    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Post;

    FDocumentNumber := ibdsDocument.FieldByName('number').AsString;
    FDocumentDate := ibdsDocument.FieldByName('documentdate').AsDateTime;  

    FTransactionKey := ibdsDocument.FieldByName('trtypekey').AsInteger;

    AnalyzeList := TObjectList.Create;
    try
      SetAnalyzeList(AnalyzeList);
      gsTransaction.CreateTransactionOnDataSet(ibdsDocument.FieldByName('currkey').AsInteger,
        ibdsDocument.FieldByName('documentdate').AsDateTime, nil, AnalyzeList);
    finally
      AnalyzeList.Free;
    end;

    if IBTransaction.InTransaction then
      IBTransaction.Commit;

  except
    on E: Exception do
    begin
      MessageBox(HANDLE,
        PChar(Format('При сохранении возникла ошибка %s.', [E.Message])), 'Внимание',
        mb_Ok or mb_IconInformation);
      Result := False;
    end;
  end;
end;

procedure TdlgAddSimpleDoc.SetupDialog(const aDocumentKey, aTransactionKey: Integer);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  FDocumentKey := aDocumentKey;
  FTransactionKey := aTransactionKey;

  FisAppendMode := FDocumentKey = -1;

  ibdsDocument.ParamByName('dk').AsInteger := FDocumentKey;
  ibdsDocument.Open;

  ibdsDocument.FieldByName('trtypekey').OnChange := TrTypeKeyChange;

  if FDocumentKey = -1 then
    AppendDocument
  else
    EditDocument;

  ibdsDocument.FieldByName('currkey').OnChange := CurrChange;

  SetCurrencyEnabled(FTransactionKey);

  if Visible then
    dbedDocumentNumber.SetFocus;

  gsTransaction.Refresh;
end;

procedure TdlgAddSimpleDoc.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgAddSimpleDoc.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgAddSimpleDoc.actNextExecute(Sender: TObject);
begin
  if Save then
  begin
    SetupDialog(-1, FTransactionKey);
  end;
end;

procedure TdlgAddSimpleDoc.FormCreate(Sender: TObject);
begin
  //boCurrency.NCU := 200010;
  gsTransaction.AddConditionDataSet([ibdsDocument]);
end;

procedure TdlgAddSimpleDoc.gsiblcCurrChange(Sender: TObject);
//var
//  Rate: Double;
begin
  if gsiblcCurr.CurrentKey > '' then
  begin
    {
    Rate :=
      boCurrency.GetRate(gsiblcCurr.CurrentKeyInt,
        ibdsDocument.FieldByName('documentdate').AsDateTime);
    edRate.Text := FloatToStr(Rate);
    }

    { TODO : Внимание! временно мы отключили пересчет по курсу валюты! }

    edRate.Text := '1';
    CalcCurrency(-1);
  end;
end;

procedure TdlgAddSimpleDoc.edRateExit(Sender: TObject);
begin
  if edRate.Text > '' then
    CalcCurrency(-1);
end;

procedure TdlgAddSimpleDoc.CalcCurrency(const TypeCur: Integer);
var
  Rate: Double;
begin
  try
    Rate := StrToFloat(edRate.Text);
  except
    Rate := 0;
  end;
  if TypeCur = -1 then
  begin
    if (ibdsDocument.FieldByName('SumCurr').AsFloat = 0) and (Rate <> 0) then
      ibdsDocument.FieldByName('SumCurr').AsFloat :=
        ibdsDocument.FieldByName('SumNCU').AsFloat / Rate;
    if (ibdsDocument.FieldByName('SumNCU').AsFloat = 0) then
      ibdsDocument.FieldByName('SumNCU').AsFloat :=
        ibdsDocument.FieldByName('SumCurr').AsFloat * Rate;
  end
  else
    if TypeCur = 0 then
    begin
      if (Rate <> 0) then
        ibdsDocument.FieldByName('SumCurr').AsFloat :=
          ibdsDocument.FieldByName('SumNCU').AsFloat / Rate;
    end
    else
      ibdsDocument.FieldByName('SumNCU').AsFloat :=
        ibdsDocument.FieldByName('SumCurr').AsFloat * Rate;

end;

procedure TdlgAddSimpleDoc.dbedSumNDEExit(Sender: TObject);
begin
  if ibdsDocument.FieldByName('Currkey').AsInteger > 0 then
    CalcCurrency(0);
end;

procedure TdlgAddSimpleDoc.dbedSumCurrExit(Sender: TObject);
begin
  if ibdsDocument.FieldByName('Currkey').AsInteger > 0 then
    CalcCurrency(1);
end;

procedure TdlgAddSimpleDoc.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Cancel;

    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;
end;

procedure TdlgAddSimpleDoc.actEntryExecute(Sender: TObject);
var
  AnalyzeList: TObjectList;
  CurrKey: Integer;
begin
  if ibdsDocument.FieldByName('trtypekey').AsInteger > 0 then
  begin
    AnalyzeList := TObjectList.Create;
    try
      SetAnalyzeList(AnalyzeList);
      if gsiblcCurr.CurrentKey > '' then
        CurrKey := gsiblcCurr.CurrentKeyInt
      else
        CurrKey := -1;
      gsTransaction.CreateTransactionOnPosition(
        CurrKey,
        ibdsDocument.FieldByName('documentdate').AsDateTime, nil,
        AnalyzeList);
    finally
      AnalyzeList.Free;
    end;
  end;
end;

procedure TdlgAddSimpleDoc.actEntryUpdate(Sender: TObject);
begin
  actEntry.Enabled := ibdsDocument.FieldByName('trtypekey').AsInteger > 0;
end;

procedure TdlgAddSimpleDoc.SetAnalyzeList(aAnalyzeList: TObjectList);
var
  i: Integer;
begin
  for i:= 0 to sbAnalyze.ControlCount - 1 do
    if sbAnalyze.Controls[i] is TgsIBLookupComboBox then
    begin
      if (sbAnalyze.Controls[i] as TgsIBLookupComboBox).CurrentKeyInt > 0 then
      begin
        aAnalyzeList.Add(TAnalyze.Create('', '',
          (sbAnalyze.Controls[i] as TgsIBLookupComboBox).ListTable,
          '', (sbAnalyze.Controls[i] as TgsIBLookupComboBox).CurrentKeyInt));
      end;
    end;
end;

procedure TdlgAddSimpleDoc.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := ibdsDocument.Active and
    (ibdsDocument.FieldByName('trtypekey').AsInteger > 0);
end;

procedure TdlgAddSimpleDoc.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := FisAppendMode and
    (ibdsDocument.FieldByName('trtypekey').AsInteger > 0);
end;

procedure TdlgAddSimpleDoc.TrTypeKeyChange(Sender: TField);
begin
  SetCurrencyEnabled(Sender.AsInteger);
  if FTransactionKey <> Sender.AsInteger then
  begin
    FTransactionKey := Sender.AsInteger;
    gsTransaction.SetAnalyzeControl(FTransactionKey, sbAnalyze, AnalyzeChange, IBTransaction);
  end;  
end;

procedure TdlgAddSimpleDoc.SetCurrencyEnabled(
  const aTransactionKey: Integer);
begin
  lCurr.Enabled := gsTransaction.IsCurrencyTransaction(aTransactionKey);
  gsiblcCurr.Enabled := lCurr.Enabled;
  lRate.Enabled := lCurr.Enabled and (gsiblcCurr.CurrentKey > '');
  edRate.Enabled := lRate.Enabled;
  lAmountCurr.Enabled := lRate.Enabled;
  dbedSumCurr.Enabled := lRate.Enabled;
end;

procedure TdlgAddSimpleDoc.CurrChange(Sender: TField);
begin
  SetCurrencyEnabled(ibdsDocument.FieldByName('TrTypeKey').AsInteger);
end;

procedure TdlgAddSimpleDoc.AnalyzeChange(Sender: TObject);
begin
  gsTransaction.Changed := True;
end;

procedure TdlgAddSimpleDoc.FormActivate(Sender: TObject);
begin
  if not FisAppendMode then
    dbedDocumentNumber.SetFocus;
end;

constructor TdlgAddSimpleDoc.Create(AnOwner: TComponent);
begin
  inherited;
  FDocumentNumber := '';
  FDocumentDate := Now;
end;

end.
