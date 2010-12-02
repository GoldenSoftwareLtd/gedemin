unit gp_frmNewRealization_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmMDHIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid, IBSQL, at_sql_setup, gsReportRegistry,
  gsReportManager;

type
  TForm1 = class(Tgd_frmMDHIBF)
    pPrintMenu: TPopupMenu;
    ToolButton6: TToolButton;
    gsReportRegistry: TgsReportRegistry;
    atSQLSetup: TatSQLSetup;
    ibsqlDocRealInfo: TIBSQL;
    ibsqlOurFirm: TIBSQL;
    ibsqlCustomer: TIBSQL;
    ibsqlUpdateGroupPrint: TIBSQL;
    ibdsPrintDocRealPos: TIBDataSet;
    dsPrintDocRealPos: TDataSource;
    actDetailBill: TAction;
    actOption: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    actEntry: TAction;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure gsReportRegistryBeforePrint(Sender: TObject; isRegistry,
      isQuick: Boolean);
    procedure actDetailBillExecute(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure actEntryExecute(Sender: TObject);
  private
    { Private declarations }
    FCurDocumentKey: Integer;
    function EditDocument(const aDocumentKey: Integer): Boolean;
    procedure SetDocRealPos;
  protected
    procedure InternalOpen; override;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses gp_dlgRealizationBill_unit, gp_dlgRealizatoinOption_unit, gp_dlgDetailBill_unit,
  gp_dlgMakeEntry_unit;

{ TForm1 }

class function TForm1.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmRealizationBill) then
    frmRealizationBill := TfrmRealizationBill.Create(AnOwner);

  Result := frmRealizationBill;

end;

function TForm1.EditDocument(const aDocumentKey: Integer): Boolean;
begin


  if not Assigned(dlgRealizationBill) then
    dlgRealizationBill := TdlgRealizationBill.Create(Self);

  with dlgRealizationBill do
  begin
    SetupDialog(aDocumentKey);
    Result := ShowModal = mrOk;
    if Result then
      FCurDocumentKey := DocumentKey;
  end;


end;

procedure TForm1.InternalOpen;
begin
  SetDocRealPos;

  ibdsDocRealization.Close;

  ibdsDocRealization.ParamByName('ck').AsInteger := IBLogin.CompanyKey;
  ibdsDocRealization.Open;
  ibdsDocRealization.Close;
  ibdsDocRealization.Open;
  ibdsDocRealPos.Open;

end;

procedure TForm1.SetDocRealPos;
var
  ibsql: TIBSQL;
  S, S1: String;

function InsertTax(const SQLText, TaxField, AmountField: String; IncludeTax: Boolean): String;
begin
  Result := SQLText;

  if not IncludeTax then
  begin
    Insert(
      Format(
       'CAST(%s / (%s + 0.0001) * 100 as INTEGER) as %0:sPERC,',
       [TaxField, AmountField]),
       Result, Pos('SELECT', UpperCase(SQLText)) + 6);
    Insert(Format(' %s + %s as E%1:s, ', [AmountField, TaxField]),
      Result, Pos('SELECT', UpperCase(SQLText)) + 6);
  end
  else
  begin
    Insert(
      Format(
       'CAST(%s / (%s - %0:s + 0.0001) * 100 as INTEGER) as %0:sPERC,',
       [TaxField, AmountField]),
       Result, Pos('SELECT', UpperCase(SQLText)) + 6);
    Insert(Format(' %s - %s as E%1:s, ', [AmountField, TaxField]),
      Result, Pos('SELECT', UpperCase(Result)) + 6);
  end;
end;

begin
  ibsql := TIBSQL.Create(Self);
  try
    S := ibdsDocRealPos.SelectSQL.Text;
    S1 := ibdsPrintDocRealPos.SelectSQL.Text;
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption WHERE relationname = ''GD_DOCREALPOS''';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      if ibsql.FieldByName('iscurrency').AsInteger = 1 then
      begin
        S := InsertTax(S, ibsql.FieldByName('fieldname').AsString, 'AMOUNTCURR',
               (ibsql.FieldByName('includetax').AsInteger = 1));
        S1 := InsertTax(S1, ibsql.FieldByName('fieldname').AsString, 'AMOUNTCURR',
               (ibsql.FieldByName('includetax').AsInteger = 1));
      end
      else
      begin
        S := InsertTax(S, ibsql.FieldByName('fieldname').AsString, 'AMOUNTNCU',
               (ibsql.FieldByName('includetax').AsInteger = 1));
        S1 := InsertTax(S1, ibsql.FieldByName('fieldname').AsString, 'AMOUNTNCU',
               (ibsql.FieldByName('includetax').AsInteger = 1));
      end;

      ibsql.Next;
    end;
    ibsql.Close;
    ibdsDocRealPos.SelectSQL.Text := S;
    ibdsPrintDocRealPos.SelectSQL.Text := S1;
  finally
    ibsql.Free;
  end;
end;

procedure TForm1.actNewExecute(Sender: TObject);
begin
  { Добавление нового документа }
  if EditDocument(-1) then
  begin
    ibdsDocRealization.Close;
    ibdsDocRealization.Open;
    ibdsDocRealization.Locate('documentkey', FCurDocumentKey, []);

    ibdsDocRealPos.Close;
    ibdsDocRealPos.Open;
  end;

end;

procedure TForm1.actEditExecute(Sender: TObject);
begin
  { Изменение существующего документа }
  if EditDocument(ibdsDocRealization.FieldByName('documentkey').AsInteger) then
  begin
    ibdsDocRealization.Refresh;

    ibdsDocRealPos.Close;
    ibdsDocRealPos.Open;
  end;

end;

procedure TForm1.actDeleteExecute(Sender: TObject);
begin
  { Удаление существующего документа }
  if MessageBox(HANDLE, PChar(Format('Удалить документ ''%s''?',
    [ibdsDocRealization.FieldbyName('Number').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = id_Yes
  then
  begin
    ibdsDocRealization.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

procedure TForm1.actPrintExecute(Sender: TObject);
begin
  {}
end;

type
  TTaxInfo = class
    FTaxName: String;
    FStavka: Integer;
    FAmount: Currency;
    constructor Create(const aTaxName: String; aStavka: Integer; aAmount: Currency);
  end;

constructor TTaxInfo.Create(const aTaxName: String; aStavka: Integer; aAmount: Currency);
begin
  FTaxName := aTaxName;
  FStavka := aStavka;
  FAmount := aAmount;
end;

procedure TForm1.gsReportRegistryBeforePrint(Sender: TObject; isRegistry,
  isQuick: Boolean);

var
  i, OrderRec: Integer;
  ibsql: TIBSQL;
  TaxFields: TStringList;
  Taxes: TObjectList;
  CountPrintGroup: Integer;
  CodeGroup: Integer;
  OrderPrint: Integer;
  Variable: String;

procedure AddTaxAmount(const aTaxName: String; const aStavka: Integer; aAmount: Currency);
var
  j, Num: Integer;
begin
  Num := -1;
  for j:= 0 to Taxes.Count - 1 do
    if (aTaxName = TTaxInfo(Taxes[j]).FTaxName) and
       (aStavka = TTaxInfo(Taxes[j]).FStavka)
    then
    begin
      Num := j;
      Break;
    end;

  if Num = -1 then
    Taxes.Add(TTaxInfo.Create(aTaxName, aStavka, aAmount))
  else
    TTaxInfo(Taxes[Num]).FAmount := TTaxInfo(Taxes[Num]).FAmount + aAmount;
end;

begin
  gsReportRegistry.VariableList.Clear;

  if not ibsqlDocRealInfo.Prepared then
    ibsqlDocRealInfo.Prepare;

  ibsqlDocRealInfo.ParamByName('dk').AsInteger :=
    ibdsDocRealization.FieldByName('documentkey').AsInteger;

  ibsqlDocRealInfo.ExecQuery;

  for i:= 0 to ibsqlDocRealInfo.Current.Count - 1 do
    gsReportRegistry.VariableList.Add(ibsqlDocRealInfo.Fields[i].Name + '=' +
      ibsqlDocRealInfo.Fields[i].AsString);

  if ibsqlDocRealInfo.FieldByName('TypeTransport').AsString = '' then
    gsReportRegistry.VariableList.Add('TypeTransName=')
  else
    case ibsqlDocRealInfo.FieldByName('TypeTransport').AsString[1] of
    'C': gsReportRegistry.VariableList.Add('TypeTransName=Центровывоз');
    'S': gsReportRegistry.VariableList.Add('TypeTransName=Самовывоз');
    'A': gsReportRegistry.VariableList.Add('TypeTransName=Арендованный');
    'O': gsReportRegistry.VariableList.Add('TypeTransName=');
    end;

  ibsqlDocRealInfo.Close;

  if not ibsqlOurFirm.Prepared then
    ibsqlOurFirm.Prepare;

  ibsqlOurFirm.ParamByName('id').AsInteger := IBLogin.CompanyKey;
  ibsqlOurFirm.ExecQuery;

  for i:= 0 to ibsqlOurFirm.Current.Count - 1 do
    gsReportRegistry.VariableList.Add(ibsqlOurFirm.Fields[i].Name + '=' +
      ibsqlOurFirm.Fields[i].AsString);

  ibsqlOurFirm.Close;

  ibsqlCustomer.ParamByName('id').AsInteger :=
    ibdsDocRealization.FieldByName('tocontactkey').AsInteger;

  ibsqlCustomer.ExecQuery;

  for i:= 0 to ibsqlCustomer.Current.Count - 1 do
    gsReportRegistry.VariableList.Add(ibsqlCustomer.Fields[i].Name + '=' +
      ibsqlCustomer.Fields[i].AsString);

  ibsqlCustomer.Close;

  for i:= 0 to ibdsDocRealization.FieldCount - 1 do
    gsReportRegistry.VariableList.Add(ibdsDocRealization.Fields[i].FieldName + '=' +
      ibdsDocRealization.Fields[i].AsString);

  ibdsPrintDocRealPos.Close;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      'UPDATE gd_docrealpos SET orderprint = 0, printgrouptext = NULL, varprint = NULL '+
      'WHERE documentkey = ' + ibdsDocRealization.FieldByName('documentkey').AsString;
    ibsql.ExecQuery;
    ibsql.Close;

    CountPrintGroup := GlobalStorage.ReadInteger('realizationoption', 'countprintgroup', 0);
    if CountPrintGroup > 0 then
    begin
      ibsql.SQL.Text := 'SELECT name, lb, rb FROM gd_goodgroup WHERE id = :id';
      ibsql.Prepare;
      for i:= 1 to CountPrintGroup do
      begin
        CodeGroup := GlobalStorage.ReadInteger('realizationoption',
          Format('printgroupkey%d', [i]), 0);
        if CodeGroup > 0 then
        begin
          OrderPrint := GlobalStorage.ReadInteger('realizationoption',
            Format('printgroupseq%d', [i]), 0);
          Variable := GlobalStorage.ReadString('realizationoption', 'printgroupvariable',
            '');
          ibsql.ParamByName('id').AsInteger := CodeGroup;
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
          begin
            ibsqlUpdateGroupPrint.Prepare;
            ibsqlUpdateGroupPrint.ParamByName('t').AsString := ibsql.FieldByName('name').AsString;
            ibsqlUpdateGroupPrint.ParamByName('o').AsInteger := OrderPrint;
            ibsqlUpdateGroupPrint.ParamByName('v').AsString := Variable;
            ibsqlUpdateGroupPrint.ParamByName('lb').AsInteger := ibsql.FieldByName('lb').AsInteger;
            ibsqlUpdateGroupPrint.ParamByName('rb').AsInteger := ibsql.FieldByName('rb').AsInteger;
            ibsqlUpdateGroupPrint.ParamByName('id').AsInteger :=
              ibdsDocRealization.FieldByName('documentkey').AsInteger;
            ibsqlUpdateGroupPrint.ExecQuery;
            ibsqlUpdateGroupPrint.Close;
          end;
          ibsql.Close;
          IBTransaction.CommitRetaining;
        end;
      end;
    end;

    OrderRec := -1;
    for i:= ibdsPrintDocRealPos.SelectSQL.Count - 1 downto 0 do
      if Pos('ORDER BY', ibdsPrintDocRealPos.SelectSQL[i]) > 0 then
      begin
        OrderRec := i;
        Break;
      end;

    if OrderRec <> -1 then
    begin
      if CountPrintGroup > 0 then
        ibdsPrintDocRealPos.SelectSQL[OrderRec] := 'ORDER BY pos.orderprint, pos.id '
      else
        ibdsPrintDocRealPos.SelectSQL[OrderRec] := 'ORDER BY pos.id '
    end;

    for i:= OrderRec + 1 to ibdsPrintDocRealPos.SelectSQL.Count - 1 do
       ibdsPrintDocRealPos.SelectSQL.Delete(ibdsPrintDocRealPos.SelectSQL.Count - 1);

    ibdsPrintDocRealPos.ParamByName('dockey').AsInteger :=
      ibdsDocRealization.FieldByName('documentkey').AsInteger;

    ibdsPrintDocRealPos.Open;

    Taxes := TObjectList.Create;
    TaxFields := TStringList.Create;
    try
      ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption WHERE relationname = ''GD_DOCREALPOS''';
      ibsql.ExecQuery;
      while not ibsql.Eof do
      begin
        TaxFields.Add(ibsql.FieldByName('fieldname').AsString);
        ibsql.Next;
      end;
      ibsql.Close;

      while not ibdsPrintDocRealPos.EOF do
      begin
        for i:= 0 to TaxFields.Count - 1 do
        begin
          AddTaxAmount(TaxFields[i], ibdsPrintDocRealPos.FieldByName(TaxFields[i] + 'PERC').AsInteger,
            ibdsPrintDocRealPos.FieldByName(TaxFields[i]).AsCurrency);
          AddTaxAmount('AMT$' + TaxFields[i], ibdsPrintDocRealPos.FieldByName(TaxFields[i] + 'PERC').AsInteger,
            ibdsPrintDocRealPos.FieldByName('AmountNCU').AsCurrency);
        end;
        
        if ibdsPrintDocRealPos.FieldByName('varprint').AsString > '' then
        begin
          AddTaxAmount(ibdsPrintDocRealPos.FieldByName('varprint').AsString,
            100,
            ibdsPrintDocRealPos.FieldByName('AmountNCU').AsCurrency);
          for i:= 0 to TaxFields.Count - 1 do
          begin
            AddTaxAmount(ibdsPrintDocRealPos.FieldByName('varprint').AsString,
              ibdsPrintDocRealPos.FieldByName(TaxFields[i] + 'PERC').AsInteger,
              ibdsPrintDocRealPos.FieldByName('AmountNCU').AsCurrency);
            AddTaxAmount(ibdsPrintDocRealPos.FieldByName('varprint').AsString + '_' +
              TaxFields[i], ibdsPrintDocRealPos.FieldByName(TaxFields[i] + 'PERC').AsInteger,
              ibdsPrintDocRealPos.FieldByName(TaxFields[i]).AsCurrency);
          end;
        end;
        
        ibdsPrintDocRealPos.Next;
      end;

      ibdsPrintDocRealPos.First;

      for i:= 0 to Taxes.Count - 1 do
        gsReportRegistry.VariableList.Add(Format('%s%d=%f', [TTaxInfo(Taxes[i]).FTaxName,
          TTaxInfo(Taxes[i]).FStavka, TTaxInfo(Taxes[i]).FAmount])); 

    finally
      Taxes.Free;
      TaxFields.Free;
    end;
  finally
    ibsql.Free;
  end;
end;

procedure TForm1.actDetailBillExecute(Sender: TObject);
begin
  with TdlgDetailBill.Create(Self) do
    try
      ShowModal;
      if Ok then
      begin
        ibdsDocRealization.Close;
        ibdsDocRealization.Open;
        ibdsDocRealPos.Close;
        ibdsDocRealPos.Open;
      end;  
    finally
      Free;
    end;
end;

procedure TForm1.actOptionExecute(Sender: TObject);
begin
  with TdlgRealizatoinOption.Create(Self) do
    try
      SetupDialog;
      ShowModal;
    finally
      Free;
    end;

end;

procedure TForm1.actEntryExecute(Sender: TObject);
begin
  with TdlgMakeEntry.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

initialization
  RegisterClass(TfrmRealizationBill);


end.
